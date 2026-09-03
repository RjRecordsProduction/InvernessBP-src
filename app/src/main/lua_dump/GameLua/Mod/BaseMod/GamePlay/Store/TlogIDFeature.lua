local TlogIDFeature = {
  ServerRPC = {},
  ClientRPC = {}
}
local TeammateTakeOverConfig = require("GameLua.Mod.BaseMod.GamePlay.AI.TeammateTakeOverConfig")
TlogIDFeature.ServerRPC.ServerAskTlogIdCount = {
  Reliable = true,
  Params = {
    {
      UEnums.EPropertyClass.Array,
      UEnums.EPropertyClass.Int
    },
    {
      UEnums.EPropertyClass.Array,
      UEnums.EPropertyClass.Int
    },
    UEnums.EPropertyClass.Int64
  }
}
TlogIDFeature.ServerRPC.ServerAskTlogIdChange = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Int64,
    UEnums.EPropertyClass.Int,
    UEnums.EPropertyClass.Int
  }
}
function TlogIDFeature:_PostConstruct()
end
function TlogIDFeature:ctor()
  self.NeedTlogGameGuideItem = {}
  self.ItemID = {}
  self.GuideTlogMaxCount = 3
end
function TlogIDFeature:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  local RepTable = {
    {
      "GuideTlogIDEnoughArray",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Array,
      UEnums.EPropertyClass.Int
    }
  }
  if TlogIDFeature.__super.GetLifetimeReplicatedProps then
    local BaseRepTable = TlogIDFeature.__super.GetLifetimeReplicatedProps(self)
    table.move(BaseRepTable, 1, #BaseRepTable, #RepTable + 1, RepTable)
  end
  return RepTable
end
function TlogIDFeature:ReceiveBeginPlay()
  local uPlayerState = self.Owner.Object
  if not uPlayerState then
    return
  end
  if Client then
    self:InitGameGuideTlogCount()
    self:AddCommonEvent(EVENTTYPE_INGAME_MAINCONTROLUI_PANEL, EVENTID_MAINCONTROLPANELUI_ONGAMEGUIDE_TRIGGER, self.OnMainControlPanelUIOnGameGuideTrigger, self)
    return
  end
  if not uPlayerState.bIsABot then
    self:AddControlEvent(uPlayerState, "OnGenerelCountChanged", self.OnHandleGenerelCountChanged, self)
    self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_ITEM, EVENTID_PLAYEREVENT_PICKUPITEM, self.OnPlayerPickItem, self)
  end
end
function TlogIDFeature:OnMainControlPanelUIOnGameGuideTrigger(EventType, EventID, nItemID)
  local uPlayerState = self.Owner.Object
  if not uPlayerState then
    return
  end
  local nTlogID = self.ItemID[nItemID]
  if not nTlogID then
    return
  end
  print(bWriteLog and "TlogIDFeature:OnMainControlPanelUIOnGameGuideTrigger, nTlogID = " .. tostring(nTlogID))
  self:ServerAskTlogIdChange(uPlayerState.PlayerKey, nTlogID, 99)
end
function TlogIDFeature:ServerAskTlogIdChange(PlayerKey, nTlogID, nCount)
  if Client then
    return
  end
  local uPlayerState = self.Owner.Object
  if not uPlayerState then
    return
  end
  if uPlayerState.PlayerKey ~= PlayerKey then
    return
  end
  uPlayerState:AddGeneralCount(nTlogID, nCount, false)
end
function TlogIDFeature:OnPlayerPickItem(EventType, EventID, PlayerKey, nItemId, nCount, nReason)
  local uPlayerState = self.Owner.Object
  if not uPlayerState or uPlayerState.PlayerKey ~= PlayerKey then
    return
  end
  local nTlogID = self.ItemID[nItemId]
  if not nTlogID then
    return
  end
  local nCurrentCount = uPlayerState:GetValueByTLogIDInCounter(nTlogID)
  nCurrentCount = nCurrentCount or 0
  print(bWriteLog and "TlogIDFeature:OnPlayerPickItem, nTlogID = " .. tostring(nTlogID) .. ", nCurrentCount = " .. tostring(nCurrentCount))
  uPlayerState:AddGeneralCount(nTlogID, 1, false)
end
function TlogIDFeature:OnHandleGenerelCountChanged(TLogID, DeltaCnt, CurCnt)
  if not TLogID or not CurCnt then
    return
  end
  self:GuideTlogIDChanged(TLogID, CurCnt)
end
function TlogIDFeature:CheckIsSpecialTips(nItemID)
  if not nItemID then
    return false
  end
  local nTlogID = self.ItemID[nItemID]
  if not nTlogID then
    return false
  end
  for _, EnabledTlogID in pairs(self.GuideTlogIDEnoughArray) do
    if nTlogID == EnabledTlogID then
      printf("BRDealCardPlayerControllerFeature:EnableCard Already Enabled")
      return false
    end
  end
  return true
end
function TlogIDFeature:InitGameGuideTlogCount()
  local GameGuideUIConfig = CDataTable.GetTable("GameGuideUIConfig")
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsBLUEHOLE() then
    GameGuideUIConfig = CDataTable.GetTable("GameGuideUIConfigBluehole")
  end
  if not GameGuideUIConfig then
    return
  end
  local uPlayerState = self.Owner.Object
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local ModeID = GameMainConfig.GetModeID()
  local GameGuideUITable = CDataTable.GetTableData("GameGuideUITable", ModeID)
  local CurrentTag
  if GameGuideUITable then
    CurrentTag = GameGuideUITable.Tag
  end
  local version_util = require("client.common.version_util")
  local curVersion = Client.GetAppVersion()
  local nCurVersionNum = version_util.ConvertVersionToNumber(curVersion, 3)
  local TlogIDArray = slua.Array(UEnums.EPropertyClass.Int)
  local ItemIDArray = slua.Array(UEnums.EPropertyClass.Int)
  for _, Config in pairs(GameGuideUIConfig) do
    local nVersionNum = version_util.ConvertVersionToNumber(Config.Version, 3)
    if Config.Tlogid and Config.Itemid and nCurVersionNum == nVersionNum then
      if not CurrentTag then
        print(bWriteLog and "TlogIDFeature:InitGameGuideTlogCount, CurrentTag = nil")
        self.NeedTlogGameGuideItem[Config.Tlogid] = false
        self.ItemID[Config.Itemid] = Config.Tlogid
        TlogIDArray:Add(Config.Tlogid)
        ItemIDArray:Add(Config.Itemid)
      else
        for _, Tag in pairs(Config.Tag_as) do
          if Tag == CurrentTag then
            print(bWriteLog and "TlogIDFeature:InitGameGuideTlogCount, Tag = " .. tostring(Tag))
            self.NeedTlogGameGuideItem[Config.Tlogid] = false
            self.ItemID[Config.Itemid] = Config.Tlogid
            TlogIDArray:Add(Config.Tlogid)
            ItemIDArray:Add(Config.Itemid)
          end
        end
      end
    end
  end
  if Client then
    self:ServerAskTlogIdCount(TlogIDArray, ItemIDArray, uPlayerState.PlayerKey)
  end
end
function TlogIDFeature:ServerAskTlogIdCount(TlogIdArray, ItemIdArray, PlayerKey)
  print(bWriteLog and "TlogIDFeature:ServerAskTlogIdCount, TlogIdArray = " .. tostring(TlogIdArray) .. ", ItemIdArray = " .. tostring(ItemIdArray) .. ", PlayerKey = " .. tostring(PlayerKey))
  local uPlayerState = self.Owner.Object
  if not uPlayerState then
    return
  end
  if uPlayerState.PlayerKey ~= PlayerKey then
    return
  end
  if TlogIdArray:Num() > 0 then
    for i = 0, TlogIdArray:Num() - 1 do
      local TLogID = TlogIdArray:Get(i)
      local ItemID = ItemIdArray:Get(i)
      if TLogID and ItemID then
        self.NeedTlogGameGuideItem[TLogID] = false
        self.ItemID[ItemID] = TLogID
      end
    end
  end
  local uPlayerState = self.Owner.Object
  for TlogID, value in pairs(self.NeedTlogGameGuideItem) do
    local nCurrentCount = uPlayerState:GetValueByTLogIDInCounter(TlogID)
    print(bWriteLog and "TlogIDFeature:InitGameGuideTlogCount, TlogID = " .. tostring(TlogID) .. ", nCurrentCount = " .. tostring(nCurrentCount))
    self:GuideTlogIDChanged(TlogID, nCurrentCount)
  end
end
function TlogIDFeature:GuideTlogIDChanged(TlogID, CurCnt)
  if self.NeedTlogGameGuideItem[TlogID] == nil then
    return
  end
  if CurCnt and CurCnt >= self.GuideTlogMaxCount then
    self.GuideTlogIDEnoughArray:Add(TlogID)
    self.NeedTlogGameGuideItem[TlogID] = true
  end
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
local CTlogIDFeature = class(CFeatureBase, nil, TlogIDFeature)
return CTlogIDFeature