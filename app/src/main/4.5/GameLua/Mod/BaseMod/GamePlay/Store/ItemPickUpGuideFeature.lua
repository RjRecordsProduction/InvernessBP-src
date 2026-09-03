local ItemPickUpGuideFeature = {
  ServerRPC = {},
  ClientRPC = {}
}
local GUIDE_ENOUGH_THRESHOLD = 3
local GUIDE_VIEW_DELTA = 100
local PICKUP_FEATURE_START_VERSION = 4500
local GUIDE_VERSION_KEEP_COUNT = 7
local EGuideDisplayType = {
  NONE = 0,
  TIPS_ONLY = 1,
  NEW_ONLY = 2,
  BOTH = 3
}
ItemPickUpGuideFeature.ServerRPC.ServerAskItemCountChange = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int,
    UEnums.EPropertyClass.Int
  }
}
ItemPickUpGuideFeature.ServerRPC.ServerAskVersionFilter = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Str
  }
}
function ItemPickUpGuideFeature:_PostConstruct()
end
function ItemPickUpGuideFeature:ctor()
  self.NeedGuideItemMap = {}
  self.ItemConfigMap = {}
  self.ClientItemGuideCounterMap = {}
  self.bInitCompleted = false
  self.sPendingClientVersion = nil
  self.bIsRejoinPlayer = false
  self.ClientGuideDisplayTypeMap = {}
end
function ItemPickUpGuideFeature:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  local RepTable = {
    {
      "ItemGuideCounterKey",
      ELifetimeCondition.COND_OwnerOnly,
      UEnums.EPropertyClass.Array,
      UEnums.EPropertyClass.Int
    },
    {
      "ItemGuideCounterValue",
      ELifetimeCondition.COND_OwnerOnly,
      UEnums.EPropertyClass.Array,
      UEnums.EPropertyClass.Int
    }
  }
  if ItemPickUpGuideFeature.__super.GetLifetimeReplicatedProps then
    local BaseRepTable = ItemPickUpGuideFeature.__super.GetLifetimeReplicatedProps(self)
    table.move(BaseRepTable, 1, #BaseRepTable, #RepTable + 1, RepTable)
  end
  return RepTable
end
function ItemPickUpGuideFeature:ReceiveBeginPlay()
  if Client then
    self:_BuildClientGuideDisplayTypeMap()
    local version_util = require("client.common.version_util")
    local sClientVersion = version_util.GetAppVersion()
    self:ServerAskVersionFilter(sClientVersion)
  else
    self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PLAYER_JOIN, self.OnPlayerJoin, self)
  end
end
function ItemPickUpGuideFeature:OnPlayerJoin(_, _, uPlayer)
  if not slua.isValid(uPlayer) then
    return
  end
  local uPlayerState = self.Owner.Object
  if not uPlayerState then
    return
  end
  if not uPlayerState.bIsABot then
    self:InitItemGuideCounterFromServer()
    self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_ITEM, EVENTID_PLAYEREVENT_PICKUPITEM, self.OnPlayerPickItem, self)
  end
end
function ItemPickUpGuideFeature:OnRep_ItemGuideCounterKey()
  self:RebuildGuideCounterMap()
end
function ItemPickUpGuideFeature:OnRep_ItemGuideCounterValue()
  self:RebuildGuideCounterMap()
end
function ItemPickUpGuideFeature:RebuildGuideCounterMap()
  local KeyArray = self.ItemGuideCounterKey
  local ValueArray = self.ItemGuideCounterValue
  if not KeyArray or not ValueArray then
    return
  end
  local nNum = KeyArray:Num()
  local nValueNum = ValueArray:Num()
  if nNum ~= nValueNum then
    log_error("ItemPickUpGuideFeature:RebuildGuideCounterMap - KeyNum = " .. tostring(nNum) .. ", ValueNum = " .. tostring(nValueNum))
    return
  end
  print(bWriteLog and "ItemPickUpGuideFeature:RebuildGuideCounterMap, KeyNum = " .. tostring(nNum) .. ", ValueNum = " .. tostring(nValueNum))
  self.ClientItemGuideCounterMap = {}
  for i = 0, nNum - 1 do
    local nKey = KeyArray:Get(i)
    local nVal = ValueArray:Get(i)
    if nKey then
      self.ClientItemGuideCounterMap[nKey] = nVal or 0
    end
  end
end
function ItemPickUpGuideFeature:InitItemGuideCounterFromServer()
  local uPlayerState = self.Owner.Object
  if not uPlayerState then
    return
  end
  self:_BuildNeedGuideItemMap()
  local ExtendAttribute = require("Server.config.ExtendAttribute")
  local PlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
  local ServerData = PlayerDataMgr.GetPlayerProgressFromServer(tonumber(uPlayerState.UID), ExtendAttribute.ItemGuideCounter)
  log_tree("ItemPickUpGuideFeature:InitItemGuideCounterFromServer ServerData", ServerData)
  local ServerDataMap = {}
  if ServerData then
    for k, v in pairs(ServerData) do
      if k and k ~= 0 and v then
        ServerDataMap[k] = v
      end
    end
  end
  local sChurnVersion
  local nChurnVersionNum = 0
  local bIsRejoinPlayer = false
  local tPlayerInfo = PlayerDataMgr.GetPlayerInfo(tonumber(uPlayerState.UID))
  if tPlayerInfo and tPlayerInfo.last_rejoin_time then
    sChurnVersion = tPlayerInfo.last_cli_sub_ver
    if sChurnVersion then
      nChurnVersionNum = self:_ParseVersionMainMinor(sChurnVersion)
      if 0 < nChurnVersionNum then
        bIsRejoinPlayer = true
      else
        log_error("ItemPickUpGuideFeature:InitItemGuideCounterFromServer - rejoin player but invalid churn version, sChurnVersion = " .. tostring(sChurnVersion))
      end
    end
  end
  self.  print(bWriteLog and "ItemPickUpGuideFeature:InitItemGuideCounterFromServer - bIsRejoinPlayer = " .. tostring(bIsRejoinPlayer) .. ", sChurnVersion = " .. tostring(sChurnVersion) .. ", nChurnVersionNum = " .. tostring(nChurnVersionNum))
  if next(self.NeedGuideItemMap) == nil then
    log_error("ItemPickUpGuideFeature:InitItemGuideCounterFromServer - NeedGuideItemMap is empty, import all server data to avoid data")
    for k, v in pairs(ServerDataMap) do
      if not self:_IsItemGuideCounterExist(k) then
        self.ItemGuideCounterKey:Add(k)
        self.ItemGuideCounterValue:Add(v)
      end
    end
  else
    for ItemID, _ in pairs(self.NeedGuideItemMap) do
      if not self:_IsItemGuideCounterExist(ItemID) then
        local nValue = ServerDataMap[ItemID] or 0
        if 0 < nChurnVersionNum then
          local ConfigInfo = self.ItemConfigMap[ItemID]
          if ConfigInfo and ConfigInfo.RejoinVersion then
            local nItemRejoinVersionNum = self:_ParseVersionMainMinor(ConfigInfo.RejoinVersion)
            if 0 < nItemRejoinVersionNum then
              if nChurnVersionNum >= nItemRejoinVersionNum then
                nValue = GUIDE_VIEW_DELTA
              end
              print(bWriteLog and "ItemPickUpGuideFeature:InitItemGuideCounterFromServer - churn adjust ItemID:" .. tostring(ItemID) .. " rejoinVer:" .. tostring(ConfigInfo.RejoinVersion) .. " -> nValue:" .. tostring(nValue))
            end
          end
        end
        self.ItemGuideCounterKey:Add(ItemID)
        self.ItemGuideCounterValue:Add(nValue)
      end
    end
  end
  print(bWriteLog and "ItemPickUpGuideFeature:InitItemGuideCounterFromServer, KeyNum = " .. tostring(self.ItemGuideCounterKey:Num()))
  self.bInitCompleted = true
  if self.sPendingClientVersion then
    print(bWriteLog and "ItemPickUpGuideFeature:InitItemGuideCounterFromServer - applying pending version filter, version = " .. tostring(self.sPendingClientVersion))
    self:ServerAskVersionFilter(self.sPendingClientVersion)
    self.sPendingClientVersion = nil
  else
    self:ForceNetUpdate()
  end
end
function ItemPickUpGuideFeature:_IsItemGuideCounterExist(nItemID)
  local Num = self.ItemGuideCounterKey:Num()
  for index = 0, Num - 1 do
    if self.ItemGuideCounterKey:Get(index) == nItemID then
      return true
    end
  end
  return false
end
function ItemPickUpGuideFeature:GetValueByItemIDInGuideCounter(nItemID)
  local Num = self.ItemGuideCounterKey:Num()
  for index = 0, Num - 1 do
    if self.ItemGuideCounterKey:Get(index) == nItemID then
      return self.ItemGuideCounterValue:Get(index)
    end
  end
  return 0
end
function ItemPickUpGuideFeature:AddItemGuideCount(nItemID, nDeltaCount, bReset)
  if not nItemID or not nDeltaCount then
    return
  end
  local nOldValue = 0
  local nNewValue = 0
  local Num = self.ItemGuideCounterKey:Num()
  local nFoundIndex = -1
  for index = 0, Num - 1 do
    if self.ItemGuideCounterKey:Get(index) == nItemID then
      nFoundIndex = index
      nOldValue = self.ItemGuideCounterValue:Get(index)
      break
    end
  end
  if bReset then
    nNewValue = nDeltaCount
  else
    nNewValue = nOldValue + nDeltaCount
  end
  if 0 <= nFoundIndex then
    self.ItemGuideCounterValue:Set(nFoundIndex, nNewValue)
  else
    log_error("ItemPickUpGuideFeature:AddItemGuideCount - ItemID not found in array, skip. ItemID = " .. tostring(nItemID))
    return
  end
  print(bWriteLog and "ItemPickUpGuideFeature:AddItemGuideCount, ItemID = " .. tostring(nItemID) .. ", OldValue = " .. tostring(nOldValue) .. ", NewValue = " .. tostring(nNewValue))
  local bWasEnough = nOldValue > GUIDE_ENOUGH_THRESHOLD
  local bIsEnough = nNewValue > GUIDE_ENOUGH_THRESHOLD
  if bWasEnough ~= bIsEnough then
    self:ForceNetUpdate()
  end
end
function ItemPickUpGuideFeature:ServerAskVersionFilter(sClientVersion)
  if Client then
    return
  end
  if not sClientVersion or sClientVersion == "" then
    return
  end
  if not self.bInitCompleted then
    print(bWriteLog and "ItemPickUpGuideFeature:ServerAskVersionFilter - init not completed, pending version = " .. tostring(sClientVersion))
    self.sPendingClientVersion = sClientVersion
    return
  end
  local nClientVersionNum = self:_ParseVersionMainMinor(sClientVersion)
  if nClientVersionNum <= 0 then
    return
  end
  self.sCurrentClientVersion = sClientVersion
  print(bWriteLog and "ItemPickUpGuideFeature:ServerAskVersionFilter, sClientVersion = " .. tostring(sClientVersion) .. ", nClientVersionNum = " .. tostring(nClientVersionNum))
  if self.bIsRejoinPlayer then
    print(bWriteLog and "ItemPickUpGuideFeature:ServerAskVersionFilter - returning player, skip version filter")
    self:ForceNetUpdate()
    return
  end
  for index = self.ItemGuideCounterKey:Num() - 1, 0, -1 do
    local nItemID = self.ItemGuideCounterKey:Get(index)
    local ConfigInfo = self.ItemConfigMap[nItemID]
    local bStale = false
    if ConfigInfo and ConfigInfo.Version then
      local nItemVersionNum = self:_ParseVersionMainMinor(ConfigInfo.Version)
      if 0 < nItemVersionNum then
        if nItemVersionNum < PICKUP_FEATURE_START_VERSION then
          bStale = true
        else
          local nVersionDiff = nClientVersionNum - nItemVersionNum
          if nVersionDiff >= GUIDE_VERSION_KEEP_COUNT * 100 then
            bStale = true
          end
        end
      end
    end
    if bStale then
      print(bWriteLog and "ItemPickUpGuideFeature:ServerAskVersionFilter - removing stale ItemID:" .. tostring(nItemID))
      self.ItemGuideCounterKey:Remove(index)
      self.ItemGuideCounterValue:Remove(index)
      self.NeedGuideItemMap[nItemID] = nil
    end
  end
  self:ForceNetUpdate()
end
function ItemPickUpGuideFeature:_ParseVersionMainMinor(sVersion)
  if not sVersion or sVersion == "" then
    return 0
  end
  local nMajor, nMinor = string.match(sVersion, "^(%d+)%.(%d+)")
  if not nMajor or not nMinor then
    return 0
  end
  return tonumber(nMajor) * 1000 + tonumber(nMinor) * 100
end
function ItemPickUpGuideFeature:OnPlayerPickItem(EventType, EventID, PlayerKey, nItemId, nCount, nReason)
  local uPlayerState = self.Owner.Object
  if not uPlayerState or uPlayerState.PlayerKey ~= PlayerKey then
    return
  end
  if not self.NeedGuideItemMap[nItemId] then
    return
  end
  print(bWriteLog and "ItemPickUpGuideFeature:OnPlayerPickItem, nItemId = " .. tostring(nItemId))
  self:AddItemGuideCount(nItemId, 1, false)
end
function ItemPickUpGuideFeature:ServerAskItemCountChange(nItemID, nCount)
  if Client then
    return
  end
  if not nItemID or not nCount then
    log_error("ItemPickUpGuideFeature:ServerAskItemCountChange - invalid params, nItemID = " .. tostring(nItemID) .. ", nCount = " .. tostring(nCount))
    return
  end
  if not self.NeedGuideItemMap[nItemID] then
    log_error("ItemPickUpGuideFeature:ServerAskItemCountChange - itemID not in NeedGuideItemMap, skip. ItemID = " .. tostring(nItemID))
    return
  end
  if nCount == GUIDE_VIEW_DELTA then
    local nCurCnt = self:GetValueByItemIDInGuideCounter(nItemID)
    if nCurCnt >= GUIDE_VIEW_DELTA then
      print(bWriteLog and "ItemPickUpGuideFeature:ServerAskItemCountChange - guide already viewed, skip. ItemID:" .. tostring(nItemID))
      return
    end
    if nCurCnt > GUIDE_ENOUGH_THRESHOLD then
      print(bWriteLog and "ItemPickUpGuideFeature:ServerAskItemCountChange - pick count exceeded threshold, skip. ItemID:" .. tostring(nItemID))
      return
    end
  end
  self:AddItemGuideCount(nItemID, nCount, false)
end
function ItemPickUpGuideFeature:CheckItemNeedGuide(nItemID, bIsItemInBackpack)
  if not nItemID then
    return false
  end
  local nLimit = bIsItemInBackpack and GUIDE_ENOUGH_THRESHOLD + 1 or GUIDE_ENOUGH_THRESHOLD
  local KeyArray = self.ItemGuideCounterKey
  local ValueArray = self.ItemGuideCounterValue
  if not KeyArray or not ValueArray then
    print(bWriteLog and "ItemPickUpGuideFeature:CheckItemNeedGuide, KeyArray or ValueArray is nil")
    return false
  end
  local Num = KeyArray:Num()
  for i = 0, Num - 1 do
    if KeyArray:Get(i) == nItemID then
      local nCurCnt = ValueArray:Get(i) or 0
      return nLimit > nCurCnt
    end
  end
  return false
end
function ItemPickUpGuideFeature:CheckIsSpecialTips(nItemID)
  return self:CheckItemNeedGuide(nItemID, false)
end
function ItemPickUpGuideFeature:GetItemGuideDisplayType(nItemID)
  if not nItemID then
    return EGuideDisplayType.BOTH
  end
  if not Client then
    local ConfigInfo = self.ItemConfigMap[nItemID]
    if ConfigInfo and ConfigInfo.GuideDisplayType ~= nil then
      return ConfigInfo.GuideDisplayType
    end
    return EGuideDisplayType.BOTH
  end
  local nCachedType = self.ClientGuideDisplayTypeMap[nItemID]
  if nCachedType ~= nil then
    return nCachedType
  end
  return EGuideDisplayType.BOTH
end
function ItemPickUpGuideFeature:ShouldShowPickUpTips(nItemID)
  local nType = self:GetItemGuideDisplayType(nItemID)
  return nType == EGuideDisplayType.TIPS_ONLY or nType == EGuideDisplayType.BOTH
end
function ItemPickUpGuideFeature:ShouldShowBackpackNew(nItemID)
  local nType = self:GetItemGuideDisplayType(nItemID)
  return nType == EGuideDisplayType.NEW_ONLY or nType == EGuideDisplayType.BOTH
end
function ItemPickUpGuideFeature:GetClientItemGuideCount(nItemID)
  if not nItemID then
    return 0
  end
  return self.ClientItemGuideCounterMap[nItemID] or 0
end
function ItemPickUpGuideFeature:OnGameGuideTrigger(nItemID)
  if not self:CheckItemNeedGuide(nItemID, true) then
    return
  end
  local nCurCnt = self:GetClientItemGuideCount(nItemID)
  if nCurCnt >= GUIDE_VIEW_DELTA then
    print(bWriteLog and "ItemPickUpGuideFeature:OnGameGuideTrigger - already viewed, skip. ItemID:" .. tostring(nItemID))
    return
  end
  if nCurCnt > GUIDE_ENOUGH_THRESHOLD then
    print(bWriteLog and "ItemPickUpGuideFeature:OnGameGuideTrigger - pick count exceeded threshold, skip. ItemID:" .. tostring(nItemID))
    return
  end
  print(bWriteLog and "ItemPickUpGuideFeature:OnGameGuideTrigger, nItemID = " .. tostring(nItemID))
  self:ServerAskItemCountChange(nItemID, GUIDE_VIEW_DELTA)
end
function ItemPickUpGuideFeature:GetItemGuideCounterTable()
  local Result = {}
  local Num = self.ItemGuideCounterKey:Num()
  for index = 0, Num - 1 do
    local k = self.ItemGuideCounterKey:Get(index)
    local v = self.ItemGuideCounterValue:Get(index)
    if k and k ~= 0 and v and v ~= 0 then
      Result[k] = v
    end
  end
  return Result
end
function ItemPickUpGuideFeature:_BuildClientGuideDisplayTypeMap()
  self.ClientGuideDisplayTypeMap = {}
  local GameGuideUIConfig = CDataTable.GetTable("GameGuideUIConfig")
  if not GameGuideUIConfig then
    return
  end
  local nCount = 0
  for _, Config in pairs(GameGuideUIConfig) do
    if Config.Itemid and Config.Itemid ~= 0 then
      local nType = Config.GuideDisplayType
      if nType == nil then
        nType = EGuideDisplayType.BOTH
      end
      self.ClientGuideDisplayTypeMap[Config.Itemid] = nType
      nCount = nCount + 1
    end
  end
  print(bWriteLog and "ItemPickUpGuideFeature:_BuildClientGuideDisplayTypeMap, count = " .. tostring(nCount))
end
function ItemPickUpGuideFeature:_BuildNeedGuideItemMap()
  local GameGuideUIConfig = CDataTable.GetTable("GameGuideUIConfig")
  if not GameGuideUIConfig then
    return
  end
  local nCount = 0
  for _, Config in pairs(GameGuideUIConfig) do
    if Config.Itemid and Config.Itemid ~= 0 then
      self.NeedGuideItemMap[Config.Itemid] = true
      self.ItemConfigMap[Config.Itemid] = {
        Version = Config.Version or nil,
        RejoinVersion = Config.RejoinVersion or nil
      }
      nCount = nCount + 1
    end
  end
  print(bWriteLog and "ItemPickUpGuideFeature:_BuildNeedGuideItemMap(DS), count = " .. tostring(nCount))
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
local CItemPickUpGuideFeature = class(CFeatureBase, nil, ItemPickUpGuideFeature)
return CItemPickUpGuideFeature