local ItemUpgradeModule = {}
function ItemUpgradeModule:DefineAndResetData()
  log(bWriteLog and "ItemUpgradeModule:DefineAndResetData")
  self.bIsInitAll = false
  self.itemUpgradeConfigsKeyByGroupID = {}
  self.itemUpgradeConfigsKeyByItemID = {}
  self.itemUpgradeConfigsKeyByGroupIDAndLevel = {}
  if not self.itemIDToMicroDataMap then
    self.itemIDToMicroDataMap = {}
  end
  self.itemUpgradeMaterialList = {}
  self.itemUpgradePartsUnlock = {}
  self.openAll = false
  self.partIDListByGroupID = {}
  self.basePartIdToLevelListCache = {}
  self.SelID2IsUpdateGun = {}
  self.MultiStateIDToBaseIDMap = {}
  self.MultiStateBaseIDSameMap = {}
  self.itemRefitConditionCfg = {}
  self.itemRefitInfo = {}
  self.refitGroupToOriginGroupMap = {}
  self.itemRefitUnlockList = nil
  self.specialMaterialList = {}
  self.groupIdToBindItemIDMap = {}
  self.ValidRetCache = nil
  self.NormalWeaponIDCache = {}
  self.SwitchWeaponActionPlan = {}
  self.ItemUpgradeSoundSwitchInfoMap = {}
  self.bPendantInfoInitialize = false
  self.bIsInPendantEffect = false
  self.PendantInfo = {}
  self.TimeLimitPendant = {}
  self.TemporaryPendantID = nil
  self.MaterialFragmentMap = nil
  self.ENUM_MaxWeaponSubEffectType = {
    Noraml = 1,
    Crazy = 2,
    AvatarStandby = 3,
    WeaponEmote = 4,
    HitEffect = 5,
    ExplosionFx = 6,
    WeaponPendant = 7,
    KillCounter = 9,
    SwitchWeapon = 14,
    KillBroadcast = 16,
    TeamKillBroadcast = 22,
    FormSwitch = 26
  }
  self.ENUM_NormalWeaponShowEffectType = {
    BaseForm = 1,
    AdvanceForm = 2,
    FinalForm = 3,
    FormSwitch = 15,
    DualForm = 16
  }
end
function ItemUpgradeModule:OnInitialize()
  log(bWriteLog and "ItemUpgradeModule:OnInitialize")
  self.bIsInitAll = false
  self:InitItemUpgradeConfig()
end
function ItemUpgradeModule:InitItemUpgradeConfig()
  if self.bIsInitAll then
    return
  end
  log(bWriteLog and "ItemUpgradeModule:InitItemUpgradeConfig")
  local itemUpgradeCfgs = CDataTable.GetTable("ItemUpgradeConfig")
  for id, cfg in pairs(itemUpgradeCfgs) do
    local GroupID = cfg.GroupID
    local Level = cfg.Level
    local ItemID = cfg.ItemID
    if self.itemUpgradeConfigsKeyByGroupID[GroupID] == nil then
      self.itemUpgradeConfigsKeyByGroupID[GroupID] = {}
    end
    local groupCfgListLength = #self.itemUpgradeConfigsKeyByGroupID[GroupID]
    if Level > groupCfgListLength then
      self.itemUpgradeConfigsKeyByGroupID[GroupID][groupCfgListLength + 1] = cfg
      self.itemUpgradeConfigsKeyByItemID[ItemID] = cfg
      if self.itemIDToMicroDataMap[ItemID] == nil then
        self.itemUpgradeConfigsKeyByGroupIDAndLevel[GroupID .. "|" .. Level] = ItemID
        self.itemIDToMicroDataMap[ItemID] = {GroupID = GroupID, Level = Level}
        if cfg.IsPendant then
          self.itemIDToMicroDataMap[ItemID].IsPendant = 1
        end
      end
    end
  end
  self.bIsInitAll = true
end
function ItemUpgradeModule:CreateMaterialList(cfg)
  local index = 1
  local keyItem = "CostItem" .. index
  local keyNum = "CostItemNum" .. index
  local keyDisNum = "CostItemDisNum" .. index
  local list = {}
  while cfg[keyItem] ~= nil and cfg[keyItem] ~= 0 and cfg[keyNum] ~= nil and cfg[keyNum] ~= 0 do
    list[index] = {
      CostItem = cfg[keyItem],
      CostItemNum = cfg[keyNum],
      CostItemDisNum = cfg[keyDisNum]
    }
    index = index + 1
    keyItem = "CostItem" .. index
    keyNum = "CostItemNum" .. index
    keyDisNum = "CostItemDisNum" .. index
  end
  return list
end
function ItemUpgradeModule:OnTimeDataRes()
  log(bWriteLog and "ItemUpgradeModule:OnTimeDataRes")
  local ResearchRedDot = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ResearchRedDot)
  ResearchRedDot:SetItemUpgradeRedDot()
  EventSystem:postEvent(EVENTTYPE_ITEM_UPGRADE, EVENTID_ITEM_UPGRADE_TIME_DATA_RSP)
end
function ItemUpgradeModule:InitRefitCfgData()
  if self.itemRefitConditionCfg and next(self.itemRefitConditionCfg) then
    return
  end
  log(bWriteLog and "ItemUpgradeModule:InitRefitCfgData")
  local cfg = CDataTable.GetTable("RefitConditionCfg")
  for key, cfgData in pairs(cfg) do
    local data = {}
    data.groupID = cfgData.groupID
    data.refitNumber = cfgData.refitNumber
    data.refitName = cfgData.refitName
    data.refitGroupID = cfgData.refitGroupID
    data.minLevel = cfgData.minLevel
    data.CostItem1 = cfgData.refitCostItem1
    data.CostItemNum1 = cfgData.refitCostItemNum1
    data.CostItem2 = cfgData.refitCostItem2
    data.CostItemNum2 = cfgData.refitCostItemNum2
    data.refitFlag = cfgData.refitFlag
    data.unlockAllLevel = cfgData.unlockAllLevel
    if not self.itemRefitConditionCfg[data.groupID] then
      self.itemRefitConditionCfg[data.groupID] = {}
    end
    self.itemRefitConditionCfg[data.groupID] = data
    self.itemRefitInfo[data.refitGroupID] = true
    self.refitGroupToOriginGroupMap[data.refitGroupID] = cfgData.groupID
    if data.CostItem1 and data.CostItem1 ~= 0 then
      self.specialMaterialList[data.CostItem1] = data.refitGroupID
    end
  end
end
function ItemUpgradeModule:InitMultiStateCfgData()
  if self.MultiStateIDToBaseIDMap and next(self.MultiStateIDToBaseIDMap) then
    return
  end
  log(bWriteLog and "ItemUpgradeModule:InitMultiStateCfgData")
  local cfg = CDataTable.GetTable("WeaponMultiStateCfg")
  for ID, CfgData in pairs(cfg) do
    if not self.MultiStateBaseIDSameMap[CfgData.baseID] then
      self.MultiStateBaseIDSameMap[CfgData.baseID] = {}
    end
    table.insert(self.MultiStateBaseIDSameMap[CfgData.baseID], CfgData.ItemID)
    self.MultiStateIDToBaseIDMap[CfgData.ItemID] = CfgData.baseID
  end
end
function ItemUpgradeModule:CheckIsValid(GroupID)
  local TimeUtil = require("client.common.time_util")
  if not self.ValidRetCache then
    self.ValidRetCache = {}
    self:AddTimer(20, function()
      self.ValidRetCache = nil
    end)
  end
  if self.ValidRetCache[GroupID] ~= nil then
    return self.ValidRetCache[GroupID]
  end
  local StringUtil = require("common.string_util")
  local nAppId = "1320"
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() then
    nAppId = "1321"
  elseif PublishRegionMacros.IsBLUEHOLE() then
    nAppId = "1450"
  end
  local version_util = require("client.common.version_util")
  local sClientVersion3 = version_util.GetClientFormat(Client.GetAppVersion())
  local uUpgradeItemShowCfg = CDataTable.GetTableByFilter("UpgradeItemShowCfg", "GroupID", GroupID, "AppId", nAppId)
  for _, v in pairs(uUpgradeItemShowCfg) do
    local now = TimeUtil.GetServerTimeInSec()
    local startUnix = TimeUtil.TimeStringToUnixstamp(v.OpenTime)
    local endUnix = TimeUtil.TimeStringToUnixstamp(v.CloseTime)
    if not (now >= startUnix) or not (now <= endUnix) then
      log(bWriteLog and "ItemUpgradeModule.CheckIsValid Time Not Open GroupID:" .. GroupID)
      self.ValidRetCache[GroupID] = false
      return false
    end
    local isCEVersion = PublishRegionMacros.IsCEVersion()
    if isCEVersion and tonumber(v.IsCeOpen) ~= 1 then
      log(bWriteLog and "ItemUpgradeModule.CheckIsValid Ce Not Open GroupID:" .. GroupID)
      self.ValidRetCache[GroupID] = false
      return false
    end
    if v.LowerVersion and v.LowerVersion ~= "" and version_util.CompareVersionStandard(sClientVersion3, v.LowerVersion) < 0 then
      log(bWriteLog and "ItemUpgradeModule.CheckIsValid Version Not Open GroupID:" .. GroupID)
      self.ValidRetCache[GroupID] = false
      return false
    end
    if v.Region and v.Region ~= "" then
      local tAllRegion = StringUtil.Split(v.Region, "|")
      log(bWriteLog and "ItemUpgradeModule.CheckIsValid Need RegionCheck GroupID:" .. GroupID)
      local curRegion = FuncUtil.GetAccountRegionForBP()
      for _, vv in pairs(tAllRegion) do
        if curRegion == vv then
          log(bWriteLog and "ItemUpgradeModule.CheckIsValid Region Open GroupID:" .. GroupID)
          self.ValidRetCache[GroupID] = true
          return true
        end
      end
      if not self:CheckHasGroup(GroupID) then
        log(bWriteLog and "ItemUpgradeModule.CheckIsValid Region Not Open GroupID:" .. GroupID)
        self.ValidRetCache[GroupID] = false
        return false
      end
    end
    self.ValidRetCache[GroupID] = true
    return true
  end
  log(bWriteLog and "ItemUpgradeModule.CheckIsValid Not Exist GroupID:" .. GroupID)
  self.ValidRetCache[GroupID] = true
  return true
end
function ItemUpgradeModule:RegistEvents()
  log(bWriteLog and "ItemUpgradeModule:RegistEvents")
  if Client then
    self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_CHANGE, self.OnWardrobeUpdateItem, self)
  end
end
function ItemUpgradeModule:HasMultiState(ItemID)
  local StateCfg = CDataTable.GetTableData("WeaponMultiStateCfg", ItemID)
  if StateCfg then
    return true
  else
    return false
  end
end
function ItemUpgradeModule:GetCurrentStateItemID(ItemID)
  self:InitMultiStateCfgData()
  if not self.MultiStateIDToBaseIDMap[ItemID] then
    return ItemID
  end
  local WardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  local BaseID = self.MultiStateIDToBaseIDMap[ItemID]
  if self.MultiStateBaseIDSameMap[BaseID] and next(self.MultiStateBaseIDSameMap[BaseID]) then
    for _, StateID in pairs(self.MultiStateBaseIDSameMap[BaseID]) do
      if WardrobeData:GetHallDepotItemDataByResID(StateID) then
        return StateID
      end
    end
  end
  return ItemID
end
function ItemUpgradeModule:GetBaseItemID(ItemID)
  self:InitMultiStateCfgData()
  if self.MultiStateIDToBaseIDMap[ItemID] then
    return self.MultiStateIDToBaseIDMap[ItemID]
  else
    return ItemID
  end
end
function ItemUpgradeModule:OnPostSwitchGameStatus(preState, nextState)
  log(bWriteLog and "ItemUpgradeModule:OnPostSwitchGameStatus")
  if nextState == GameStatus.Lobby then
    self:OnTimeDataRes()
  elseif nextState == GameStatus.Fighting and not GameStatus.IsInLobbyOrMainCity() then
    self.itemUpgradeConfigsKeyByGroupID = {}
    self.itemUpgradeConfigsKeyByItemID = {}
    self.bIsInitAll = false
  end
end
function ItemUpgradeModule:CheckHasGroup(groupId)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local groupList = self:GetUpgradeGroupByID(groupId)
  local LogicCardCollectionGun = require("client.slua.logic.card_collection.LogicCardCollectionGun")
  for _, cfg in ipairs(groupList) do
    local itemInfo = wardrobe_data:GetHallDepotItemDataByResIDAndTimeliness(self:GetCurrentStateItemID(cfg.ItemID), false)
    if not itemInfo and LogicCardCollectionGun.IsCardCollectionGun(cfg.GroupID) then
      itemInfo = wardrobe_data:GetHallDepotItemDataByResIDAndTimeliness(self:GetCurrentStateItemID(cfg.ItemID), true)
    end
    if itemInfo ~= nil then
      return true
    end
  end
  return false
end
function ItemUpgradeModule:CheckSpecialMaterialIsHave(itemID)
  self:InitItemUpgradeConfig()
  if self.specialMaterialList[itemID] then
    return self:CheckHasGroup(self.specialMaterialList[itemID])
  end
  return false
end
function ItemUpgradeModule:GetUpgradeGroupByID(groupID)
  if not groupID or groupID < 0 then
    return nil
  end
  local cached = self.itemUpgradeConfigsKeyByGroupID[groupID]
  if cached ~= nil then
    if cached == 0 then
      return nil
    end
    return cached
  end
  self:InitItemUpgradeConfig()
  local result = self.itemUpgradeConfigsKeyByGroupID[groupID]
  if not result then
    self.itemUpgradeConfigsKeyByGroupID[groupID] = 0
    log(bWriteLog and "ItemUpgradeModule:GetUpgradeGroupByID groupID not found\239\188\154" .. tostring(groupID))
    return nil
  end
  log(bWriteLog and "ItemUpgradeModule:GetUpgradeGroupByID groupID\239\188\154" .. tostring(groupID))
  return result
end
function ItemUpgradeModule:_GetOrFillMicroData(itemID)
  local cached = self.itemIDToMicroDataMap[itemID]
  if cached ~= nil then
    return cached ~= 0 and cached or nil
  end
  local cfg = self:GetUpgradeCfg(itemID)
  if cfg then
    self.itemIDToMicroDataMap[itemID] = {
      GroupID = cfg.GroupID,
      Level = cfg.Level
    }
    if cfg.IsPendant == 1 then
      self.itemIDToMicroDataMap[itemID].IsPendant = 1
    end
    return self.itemIDToMicroDataMap[itemID]
  end
  self.itemIDToMicroDataMap[itemID] = 0
  return nil
end
function ItemUpgradeModule:CheckHasPendantByItemID(itemID)
  itemID = tonumber(itemID)
  if not itemID or itemID <= 0 then
    return nil
  end
  local micro = self:_GetOrFillMicroData(itemID)
  return micro and micro.IsPendant or nil
end
function ItemUpgradeModule:GetGroupID(itemID)
  itemID = tonumber(itemID)
  if not itemID or itemID <= 0 then
    return nil
  end
  local micro = self:_GetOrFillMicroData(itemID)
  return micro and micro.GroupID or nil
end
function ItemUpgradeModule:GetLevel(itemID)
  itemID = tonumber(itemID)
  if not itemID or itemID <= 0 then
    return nil
  end
  local micro = self:_GetOrFillMicroData(itemID)
  return micro and micro.Level or nil
end
function ItemUpgradeModule:GetUpgradeCfg(itemID)
  itemID = tonumber(itemID)
  if not itemID or itemID <= 0 then
    return nil
  end
  local CacheData = self.itemUpgradeConfigsKeyByItemID[itemID]
  if CacheData then
    if CacheData == 0 then
      return nil
    end
    return CacheData
  end
  local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
  if not ModelDisplayTypeHelper.IsWeaponById(itemID) then
    return nil
  end
  self:InitItemUpgradeConfig()
  local cfgData = self.itemUpgradeConfigsKeyByItemID[itemID]
  if cfgData and cfgData ~= 0 then
    log(bWriteLog and "ItemUpgradeModule:GetUpgradeCfg itemID:" .. tostring(itemID) .. " GroupID:" .. tostring(cfgData.GroupID))
    return cfgData
  end
  self.itemUpgradeConfigsKeyByItemID[itemID] = 0
  log(bWriteLog and "ItemUpgradeModule:GetUpgradeCfg itemID:" .. tostring(itemID) .. " GroupID:0")
  return nil
end
function ItemUpgradeModule:GetUpgradeGroupByItemID(itemID)
  local GroupID = self:GetGroupID(itemID)
  if GroupID then
    return self:GetUpgradeGroupByID(GroupID)
  end
  return {}
end
function ItemUpgradeModule:GetNextUpgradeItemID(resID)
  local groupList = self:GetUpgradeGroupByItemID(resID)
  local nextLevel = self:GetItemEffectLevel(resID) + 1
  if groupList[nextLevel] then
    return groupList[nextLevel].ItemID
  end
  return -1
end
function ItemUpgradeModule:GetWeaponPendantInfo(resID)
  if not self.bPendantInfoInitialize then
    self:InitPendantInfo()
  end
  if not self.PendantInfo or not next(self.PendantInfo) then
    log(bWriteLog and "[ItemUpgradeModule] have no pendant")
    return {}
  end
  self:CheckTimeLimitPendant()
  local logic_weapon_pendant = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_weapon_pendant)
  local result = {}
  local pendantId = logic_weapon_pendant:GetWeaponPendantBySkinID(DataMgr.roleData.uid, resID)
  local equippedInsID = -1
  for _, pendantInfo in pairs(self.PendantInfo) do
    local MapPendantId = logic_weapon_pendant:GetWeaponPendantByBackPack(pendantInfo.resID)
    if pendantId == MapPendantId then
      table.insert(result, 1, pendantInfo)
      equippedInsID = pendantInfo.insID
    else
      result[#result + 1] = pendantInfo
    end
  end
  table.sort(result, function(a, b)
    if a.insID == equippedInsID then
      return true
    elseif b.insID == equippedInsID then
      return false
    else
      return a.itemQuality > b.itemQuality
    end
  end)
  return result
end
function ItemUpgradeModule:InitPendantInfo()
  log(bWriteLog and "ItemUpgradeModule:InitPendantInfo")
  self.PendantInfo = {}
  local logic_weapon_pendant = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_weapon_pendant)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local arrayHallDepotItemInfo = wardrobe_data:GetArrayHallDepotItemInfo()
  for _, v in pairs(arrayHallDepotItemInfo) do
    self:CacheWeaponOrPendantInfo(v)
  end
  self.bPendantInfoInitialize = true
end
function ItemUpgradeModule:OnWardrobeUpdateItem(_, __, changelist)
  for _, changeData in pairs(changelist) do
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local itemData = wardrobe_data:GetHallDepotItemDataByInsID(changeData.instid)
    self:CacheWeaponOrPendantInfo(itemData, changeData.isRemoved, changeData.res_id, changeData.instid)
  end
end
function ItemUpgradeModule:CacheWeaponOrPendantInfo(itemData, bIsRemoved, itemID, itemInsID)
  if bIsRemoved then
    if itemID and itemInsID then
      itemID = tostring(itemID)
      itemInsID = tostring(itemInsID)
      if self.PendantInfo[itemInsID] then
        self.PendantInfo[itemInsID] = nil
      end
      if self.TimeLimitPendant[itemInsID] then
        self.TimeLimitPendant[itemInsID] = nil
      end
    end
  elseif itemData and itemData.itemType then
    local logic_weapon_pendant = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_weapon_pendant)
    if itemData.itemType == ENUM_ITEM_TYPE.Extra and itemData.itemSubType == ENUM_ITEM_SUBTYPE.Backpack_Pendant_Skin and logic_weapon_pendant:IsWeaponPendant(itemData.resID) then
      self.PendantInfo[tostring(itemData.insID)] = itemData
      if itemData.expireTS ~= 0 then
        self.TimeLimitPendant[tostring(itemData.insID)] = itemData
      end
    end
  end
end
function ItemUpgradeModule:CheckTimeLimitPendant()
  local judge = false
  for insID, PendantInfo in pairs(self.TimeLimitPendant) do
    if PendantInfo.expireTS ~= 0 then
      local validHour = 0
      local TimeUtil = require("client.common.time_util")
      local validTime = TimeUtil.GetDeltaTimeWithCurTime(PendantInfo.expireTS)
      validHour = TimeUtil.GetHouseByTotalSec(validTime)
      if validHour <= 0 then
        judge = true
        self.PendantInfo[tostring(insID)] = nil
        self.TimeLimitPendant[tostring(insID)] = nil
      end
    end
  end
  return judge
end
function ItemUpgradeModule:IsValidTimeLimitPendant(insID)
  if not insID then
    return false
  end
  insID = tostring(insID)
  if not self.bPendantInfoInitialize then
    return true
  end
  if self.PendantInfo[insID] == nil then
    return false
  end
  local PendantInfo = self.TimeLimitPendant[insID]
  if PendantInfo and PendantInfo.expireTS ~= 0 then
    local validHour = 0
    local TimeUtil = require("client.common.time_util")
    local validTime = TimeUtil.GetDeltaTimeWithCurTime(PendantInfo.expireTS)
    validHour = TimeUtil.GetHouseByTotalSec(validTime)
    if validHour <= 0 then
      self.PendantInfo[insID] = nil
      self.TimeLimitPendant[insID] = nil
      return false
    end
  end
  return true
end
function ItemUpgradeModule:SetIsInPendantEffect(inStatus)
  log(bWriteLog and "[v_jrrhhuang] SetIsInPendantEffect : " .. tostring(inStatus))
  self.bIsInPendantEffect = inStatus
  if inStatus == false then
    self.TemporaryPendantID = nil
  end
end
function ItemUpgradeModule:GetIsInPendantEffect()
  log(bWriteLog and "[v_jrrhhuang] GetIsInPendantEffect : " .. tostring(self.bIsInPendantEffect))
  return self.bIsInPendantEffect
end
function ItemUpgradeModule:SetTemporaryPendantID(itemId)
  if itemId then
    local logic_weapon_pendant = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_weapon_pendant)
    local pendantId = logic_weapon_pendant:GetWeaponPendantByBackPack(itemId)
    if pendantId ~= 0 then
      self.TemporaryPendantID = pendantId
    end
  else
    self.TemporaryPendantID = nil
  end
end
function ItemUpgradeModule:GetWeaponPendantID(itemID, uid)
  log(bWriteLog and string.format("ItemUpgradeModule:GetWeaponPendantID itemID=%s, uid=%s", tostring(itemID), tostring(uid)))
  local logic_weapon_pendant = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_weapon_pendant)
  if logic_weapon_pendant:CanSkinWithPendant(itemID) then
    log(bWriteLog and "ItemUpgradeModule:GetWeaponPendantID Can skin with pendant!")
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    local PufferConst = require("client.slua.logic.download.puffer_const")
    local DownloadState = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {itemID})
    if DownloadState == PufferConst.ENUM_DownloadState.Done then
      log(bWriteLog and string.format("ItemUpgradeModule:GetWeaponPendantID itemID=%s has downloaded", tostring(itemID)))
      uid = uid ~= "" and uid or DataMgr.roleData.uid
      local pendantId = logic_weapon_pendant:GetWeaponPendantBySkinID(uid, itemID)
      log(bWriteLog and string.format("ItemUpgradeModule:GetWeaponPendantID Saved pendantId:%s", tostring(pendantId)))
      if self:GetIsInPendantEffect() and tostring(uid) == tostring(DataMgr.roleData.uid) and not self:IsUnlockWeapon(itemID) then
        log(bWriteLog and "ItemUpgradeModule:GetWeaponPendantID is temporary pendant!")
        pendantId = 0
      end
      if pendantId ~= 0 then
        log(bWriteLog and string.format("ItemUpgradeModule:GetWeaponPendantID Return the custom pendant ID :%s", tostring(pendantId)))
        return pendantId
      else
        if self:GetIsInPendantEffect() then
          if self.TemporaryPendantID then
            log(bWriteLog and string.format("ItemUpgradeModule:GetWeaponPendantID Return the temporary pendant id : %s!", tostring(self.TemporaryPendantID)))
            return self.TemporaryPendantID
          else
            log(bWriteLog and string.format("ItemUpgradeModule:GetWeaponPendantID Return the projection pendant id : 418004001!"))
            return 418004001
          end
        end
        log(bWriteLog and "ItemUpgradeModule:GetWeaponPendantID, Can put custom pendant but without pendant, and don't show projection")
        return 0
      end
    end
    log(bWriteLog and string.format("ItemUpgradeModule:GetWeaponPendantID itemID=%s hasn't download", tostring(itemID)))
    return 0
  else
    local UBackpackUtils = import("BackpackUtils")
    local pendantId = UBackpackUtils.GetPendantIDByWeaponID(itemID)
    log(bWriteLog and string.format("ItemUpgradeModule:GetWeaponPendantID  Can't skin with pendant, return default pendant ID : " .. tostring(pendantId)))
    return pendantId
  end
end
function ItemUpgradeModule:_GetPartLevelListByBasePartId(basePartId)
  local cache = self.basePartIdToLevelListCache
  if not cache[basePartId] then
    local rows = CDataTable.GetTableByFilter("ItemUpgradePartLevelMap", "BasePartId", basePartId)
    local list = {}
    for _, row in pairs(rows) do
      list[#list + 1] = row
    end
    cache[basePartId] = list
  end
  return cache[basePartId]
end
function ItemUpgradeModule:GetLevelMatchedPartId(basePartId, nGroupId, weaponLevel)
  local list = self:_GetPartLevelListByBasePartId(basePartId)
  if #list == 0 then
    return basePartId
  end
  for _, row in ipairs(list) do
    local minLv = row.MinActiveLevel or 0
    local maxLv = row.MaxActiveLevel or 0
    if (minLv == 0 or weaponLevel >= minLv) and (maxLv == 0 or weaponLevel <= maxLv) and (not row.GroupID or row.GroupID == 0 or row.GroupID == nGroupId) then
      return row.PartID
    end
  end
  return nil
end
function ItemUpgradeModule:GetLevelBasePartId(nAttachmentResId)
  local config = CDataTable.GetTableData("ItemUpgradePartLevelMap", nAttachmentResId)
  local basePartId = config and config.BasePartId
  if not basePartId then
    return nAttachmentResId
  end
  return basePartId
end
function ItemUpgradeModule:GetLevelRelativePartIdList(nAttachmentResId, nGroupId)
  local config = CDataTable.GetTableData("ItemUpgradePartLevelMap", nAttachmentResId)
  local basePartId = config and config.BasePartId
  if not basePartId then
    return {nAttachmentResId}
  end
  local list = self:_GetPartLevelListByBasePartId(basePartId)
  if #list == 0 then
    return {nAttachmentResId}
  end
  local result = {}
  for _, row in ipairs(list) do
    if not row.GroupID or row.GroupID == 0 or row.GroupID == nGroupId then
      result[#result + 1] = row.PartID
    end
  end
  return result
end
function ItemUpgradeModule:GetPartsDic(groupId, nLevel)
  local cfg = CDataTable.GetTableByFilter("ItemUpgradeUnLockConfig", "GroupID", groupId)
  local partsDic = {}
  for _, info in pairs(cfg) do
    local partId = info.PartId
    local levelCfg = CDataTable.GetTableData("ItemUpgradePartLevelMap", partId)
    if levelCfg then
      local minLv = levelCfg.MinActiveLevel or 0
      local maxLv = levelCfg.MaxActiveLevel or 0
      if minLv ~= 0 and nLevel < minLv or maxLv ~= 0 and nLevel > maxLv then
        goto lbl_54
      end
    end
    local item = CDataTable.GetTableData("Item", partId)
    if item then
      local type = item.ItemSubType
      if not partsDic[type] then
        partsDic[type] = {}
      end
      table.insert(partsDic[type], partId)
    end
    ::lbl_54::
  end
  return partsDic
end
function ItemUpgradeModule:GetPartIDList(groupId)
  if groupId == nil then
    return {}
  end
  local list = self.partIDListByGroupID[groupId]
  if not list then
    list = {}
    local cfg = CDataTable.GetTableByFilter("ItemUpgradeUnLockConfig", "GroupID", groupId)
    for _, info in pairs(cfg) do
      table.insert(list, info.PartId)
    end
    self.partIDListByGroupID[groupId] = list
  end
  return list
end
function ItemUpgradeModule:PartIDSwitch(resID, bInDiffColor)
  log(bWriteLog and string.format("ItemUpgradeModule:PartIDSwitch begin resID=%s, bForceDiff=%s", tostring(resID), tostring(bInDiffColor)))
  if bInDiffColor then
    local info = CDataTable.GetTableData("ItemUpgradeDiffColorPart", resID)
    if info and info.DiffColorPartID then
      resID = info.DiffColorPartID
    end
  else
    local info = CDataTable.GetTableDataByFilter("ItemUpgradeDiffColorPart", "DiffColorPartID", resID)
    if info and info.PartID then
      resID = info.PartID
    end
  end
  log(bWriteLog and string.format("ItemUpgradeModule:PartIDSwitch end resID=%s", tostring(resID)))
  return resID
end
function ItemUpgradeModule:IsUnlockWeapon(itemId)
  if not itemId then
    return false
  end
  itemId = self:GetCurrentStateItemID(itemId)
  local groupId = self:GetRefitGroupID(itemId)
  if groupId then
    local curLevel = self:GetCurLevelByGroupID(groupId)
    if curLevel == 0 then
      return false
    end
    local itemLevel = self:GetItemEffectLevel(itemId)
    if curLevel >= itemLevel then
      return true
    end
  end
  return false
end
function ItemUpgradeModule:CheckCanUpgrade(itemID)
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() then
    return LobbySystem.CheckOpen(BP_ENUM_ITEM_UPGRADE) == true and self:GetUpgradeCfg(itemID) ~= nil
  else
    return LobbySystem.CheckOpen(BP_ENUM_ITEM_UPGRADE) == true and self:GetUpgradeCfg(itemID) ~= nil
  end
end
function ItemUpgradeModule:CheckCanUpgradeInPandoraAct(itemID)
  return LobbySystem.CheckHasPandoraItemUpgradeActWithItemID(itemID)
end
function ItemUpgradeModule:GetItemEffectLevel(itemID)
  itemID = self:GetCurrentStateItemID(itemID)
  local cfg = self:GetUpgradeCfg(itemID)
  if cfg then
    return cfg.Level
  end
  return 0
end
function ItemUpgradeModule:IsItemEffectMaxLevel(ItemID)
  return self:GetNextUpgradeItemID(ItemID) == -1
end
function ItemUpgradeModule:GetAllUpgradeItemsExceptPadora()
  local itemList = {}
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local pandoraItemUpgradeGroupMap = LobbySystem.CheckPandoraItemUpgradeActRefGroupID()
  self:InitItemUpgradeConfig()
  for groupID, cfgs in pairs(self.itemUpgradeConfigsKeyByGroupID) do
    if type(cfgs) == "table" and pandoraItemUpgradeGroupMap[groupID] == nil then
      itemList[#itemList + 1] = cfgs[1]
      for i = #cfgs, 1, -1 do
        if wardrobe_data:GetHallDepotItemDataByResIDAndTimeliness(self:GetCurrentStateItemID(cfgs[i].ItemID), false) ~= nil then
          itemList[#itemList] = cfgs[i]
          break
        elseif wardrobe_data:GetHallDepotItemDataByResIDAndTimeliness(self:GetCurrentStateItemID(self:GetRefitItemID(cfgs[i].ItemID)), false) then
          itemList[#itemList] = cfgs[i]
          break
        end
      end
    end
  end
  if #itemList == 0 then
    log(bWriteLog and "ItemUpgradeModule.GetAllUpgradeItemsExceptPadora #itemList = 0")
  end
  return itemList
end
function ItemUpgradeModule:GetItemUpgradeEffectList(resID)
  local list = {}
  local cfgs = self:GetUpgradeGroupByItemID(resID)
  if cfgs ~= nil then
    for _, cfg in ipairs(cfgs) do
      local subEffectCfg = CDataTable.GetTableData("ItemUpgradeSubEffect", cfg.ItemID)
      list[#list + 1] = {
        resID = cfg.ItemID,
        effectID = cfg.EffectID,
        subEffects = subEffectCfg
      }
    end
  end
  return list
end
function ItemUpgradeModule:GetSubEffectUnlockLevel(itemID, subEffectType)
  if not itemID or not subEffectType then
    return nil
  end
  local cfgs = self:GetUpgradeGroupByItemID(itemID)
  if not cfgs or type(cfgs) ~= "table" then
    return nil
  end
  for _, cfg in ipairs(cfgs) do
    local subCfg = CDataTable.GetTableData("ItemUpgradeSubEffect", cfg.ItemID)
    if subCfg then
      for i = 1, 4 do
        if subCfg["subEffect" .. i .. "Type"] == subEffectType then
          return cfg.Level
        end
      end
    end
  end
  return nil
end
function ItemUpgradeModule:GetItemUpgradeMaterialList(resID)
  local cfg = self:GetUpgradeCfg(resID)
  if not cfg then
    log(bWriteLog and "ItemUpgradeModule:GetItemUpgradeMaterialList Error item is not upgradeItem" .. tostring(resID))
    return {}
  end
  if self.itemUpgradeMaterialList[cfg.ItemID] then
  else
    self.itemUpgradeMaterialList[cfg.ItemID] = self:CreateMaterialList(cfg)
  end
  return self.itemUpgradeMaterialList[resID] or {}
end
function ItemUpgradeModule:GetUpgradeNextLevelCostList(resID)
  local nextItemID = self:GetNextUpgradeItemID(resID)
  local list = self:GetItemUpgradeMaterialList(nextItemID)
  if list ~= nil then
    local costList = {}
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    for _, costCfg in ipairs(list) do
      local needNum = costCfg.CostItemNum
      local itemList = wardrobe_data:GetHallDepotItemListByResID(costCfg.CostItem)
      for _, item in ipairs(itemList) do
        if needNum <= item.count then
          costList[item.insID] = needNum
          needNum = 0
        else
          costList[item.insID] = item.count
          needNum = needNum - item.count
        end
        if needNum == 0 then
          break
        end
      end
    end
    return costList
  end
  return nil
end
function ItemUpgradeModule:GetUpgradeDiscountTime(resID)
  if not resID then
    return
  end
  local tItemCfg = self:GetUpgradeCfg(resID)
  if not tItemCfg then
    return
  end
  return tItemCfg.UpDisStartTime, tItemCfg.UpDisEndTime
end
function ItemUpgradeModule:GetItemSourceJumpConfig(itemID)
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() then
    return CDataTable.GetTableData("ItemSourceJumpJKConfig", itemID)
  elseif PublishRegionMacros.IsBLUEHOLE() then
    return CDataTable.GetTableData("ItemSourceJumpINConfig", itemID)
  else
    return CDataTable.GetTableData("ItemSourceJumpConfig", itemID)
  end
end
function ItemUpgradeModule:GetItemJumpTypeIDList(itemID)
  local list = {}
  local itemJumpCfg = self:GetItemSourceJumpConfig(itemID)
  if itemJumpCfg == nil then
    return list
  end
  local jumpStr = itemJumpCfg.JumpType or ""
  local StringUtil = require("common.string_util")
  if jumpStr ~= "" then
    local jumpTypeList = StringUtil.Split(jumpStr, "|")
    for i, jType in ipairs(jumpTypeList) do
      local nJumpID = tonumber(jType)
      if GlobalData.CheckCanJumpByTypeID(itemID, nJumpID) then
        table.insert(list, nJumpID)
      end
    end
  end
  return list
end
function ItemUpgradeModule:CheckHasSameGroupItem(resID)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local groupList = self:GetUpgradeGroupByItemID(resID)
  for _, cfg in ipairs(groupList) do
    if wardrobe_data:GetHallDepotItemDataByResID(self:GetCurrentStateItemID(cfg.ItemID)) ~= nil then
      return true
    end
  end
  return false
end
function ItemUpgradeModule:CheckHasSameGroupItemAndRefitItem(resID)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local groupList = self:GetUpgradeGroupByItemID(resID)
  for _, cfg in ipairs(groupList) do
    local ItemId = self:GetCurrentStateItemID(cfg.ItemID)
    if wardrobe_data:GetHallDepotItemDataByResID(ItemId) ~= nil then
      return true, ItemId
    end
    ItemId = self:GetRefitItemIdByResID(cfg.ItemID)
    ItemId = self:GetCurrentStateItemID(ItemId)
    if ItemId then
      return true, ItemId
    end
  end
  return false
end
function ItemUpgradeModule:CheckHasSameGroupItemAndRefitItemWithTime(resID, bIsTimeliness)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local groupList = self:GetUpgradeGroupByItemID(resID)
  for _, cfg in ipairs(groupList) do
    if wardrobe_data:GetHallDepotItemDataByResIDAndTimeliness(self:GetCurrentStateItemID(cfg.ItemID), bIsTimeliness) ~= nil then
      return true, cfg.ItemID
    end
    local ItemId = self:GetRefitItemIdByResID(cfg.ItemID)
    ItemId = self:GetCurrentStateItemID(ItemId)
    if ItemId then
      return true, ItemId
    end
  end
  return false
end
function ItemUpgradeModule:GetLevel1ItemID(resID)
  local groupList = self:GetUpgradeGroupByItemID(resID)
  if groupList and groupList[1] then
    return groupList[1].ItemID
  end
  return resID
end
function ItemUpgradeModule:GetSameGroupItem(resID)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local groupList = self:GetUpgradeGroupByItemID(resID)
  for _, cfg in ipairs(groupList) do
    if wardrobe_data:GetHallDepotItemDataByResID(self:GetCurrentStateItemID(cfg.ItemID)) ~= nil then
      return cfg.ItemID
    end
  end
  if 0 < #groupList then
    return groupList[1].ItemID
  end
  return -1
end
function ItemUpgradeModule:GetMaxLevelItem(itemID)
  if self:GetUpgradeCfg(itemID) ~= nil then
    local list = self:GetUpgradeGroupByItemID(itemID)
    if list ~= nil then
      return list[#list].ItemID
    end
  end
  local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
  local period = LogicXSuit.GetPeriodByItemId(itemID)
  local branchId = LogicXSuit.GetBranchByItemId(itemID)
  if period then
    local baseInfo = LogicXSuit.GetBaseInfo(period, true, branchId)
    if baseInfo ~= nil then
      return baseInfo.max_item_id
    end
  end
  return -1
end
function ItemUpgradeModule:IsUpdateGun(curSelID)
  if not curSelID then
    return
  end
  if self.SelID2IsUpdateGun[curSelID] then
    return self.SelID2IsUpdateGun[curSelID] == 1
  end
  local itemConfig = CDataTable.GetTableData("Item", curSelID)
  if itemConfig and itemConfig.ItemType == ENUM_ITEM_TYPE.Weapon and self:GetMaxLevelItem(curSelID) > 0 then
    self.SelID2IsUpdateGun[curSelID] = 1
    return true
  end
  self.SelID2IsUpdateGun[curSelID] = 0
  return false
end
function ItemUpgradeModule:GetConfigByGroupIDAndLevel(groupID, level)
  local groupList = self:GetUpgradeGroupByID(groupID)
  if not groupList then
    log(bWriteLog and "ItemUpgradeModule:GetConfigByGroupIDAndLevel groupList nil id:" .. tostring(groupID))
    return nil
  end
  return groupList[level]
end
function ItemUpgradeModule:GetCurLevelByGroupID(groupID)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local groupList = self:GetUpgradeGroupByID(groupID)
  if groupList ~= nil then
    for _, cfg in ipairs(groupList) do
      if wardrobe_data:GetHallDepotItemDataByResID(self:GetCurrentStateItemID(cfg.ItemID)) ~= nil then
        return cfg.Level
      end
    end
  else
    log_error("ItemUpgradeModule.GetCurLevelByGroupID groupList is nil, groupID = " .. tostring(groupID))
  end
  return 0
end
function ItemUpgradeModule:GetCurItemIDOrFirstItemIDByGroupID(groupID)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local groupList = self:GetUpgradeGroupByID(groupID)
  if groupList ~= nil then
    for _, cfg in ipairs(groupList) do
      if wardrobe_data:GetHallDepotItemDataByResID(self:GetCurrentStateItemID(cfg.ItemID)) ~= nil then
        return cfg.ItemID
      end
    end
  else
    log_error("ItemUpgradeModule.GetCurItemIDByGroupID groupList is nil, groupID = " .. tostring(groupID))
    return 0
  end
  return groupList[1].ItemID
end
function ItemUpgradeModule:GetLevelByGroupIDPure(groupID)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local LogicCardCollectionGun = require("client.slua.logic.card_collection.LogicCardCollectionGun")
  local groupList = self:GetUpgradeGroupByID(groupID)
  if groupList then
    for level, cfg in ipairs(groupList) do
      local itemInfo = wardrobe_data:GetHallDepotItemDataByResIDAndTimeliness(self:GetCurrentStateItemID(cfg.ItemID), false)
      if not itemInfo and LogicCardCollectionGun.IsCardCollectionGun(groupID) then
        itemInfo = wardrobe_data:GetHallDepotItemDataByResIDAndTimeliness(self:GetCurrentStateItemID(cfg.ItemID), true)
      end
      if itemInfo ~= nil then
        log(bWriteLog and string.format("ItemUpgradeModule:GetLevelByGroupIDPure. level=%s", tostring(level)))
        return level
      end
    end
  else
    log_error("ItemUpgradeModule:GetLevelByGroupIDPure groupList nil")
  end
  return 0
end
function ItemUpgradeModule:GetLevelByGroupIDFull(groupID)
  local maxLevel = self:GetLevelByGroupIDPure(groupID)
  local pairGroupID = self:GetPairGroup(groupID)
  if pairGroupID ~= -1 then
    return math.max(maxLevel, self:GetLevelByGroupIDPure(pairGroupID))
  else
    return maxLevel
  end
end
function ItemUpgradeModule:GetPairGroup(groupID)
  self:InitRefitCfgData()
  if self.itemRefitConditionCfg[groupID] then
    return self.itemRefitConditionCfg[groupID].refitGroupID
  elseif self.itemRefitInfo[groupID] then
    return self.refitGroupToOriginGroupMap[groupID]
  else
    return -1
  end
end
function ItemUpgradeModule:GetObtainedMaxLevelItemByGroupID(groupID)
  local groupList = self:GetUpgradeGroupByID(groupID)
  if not groupList then
    log_error("ItemUpgradeModule:GetObtainedMaxLevelItemByGroupID groupList nil groupid:" .. groupID)
    return 0
  end
  local maxLevel = self:GetLevelByGroupIDFull(groupID)
  if maxLevel == 0 then
    maxLevel = 1
  end
  return groupList[maxLevel].ItemID
end
function ItemUpgradeModule:GetMaxLevelItemByGroupID(groupID)
  local groupList = self:GetUpgradeGroupByID(groupID)
  if not groupList then
    log_error("ItemUpgradeModule:GetObtainedMaxLevelItemByGroupID groupList nil groupid:" .. groupID)
    return 0
  end
  return groupList[#groupList].ItemID
end
function ItemUpgradeModule:upgrade_item_req(instid, group_id, item_level, item_cost, form_choice)
  log(bWriteLog and "ItemUpgradeModule.upgrade_item_req")
  log_tree("ItemUpgradeModule.upgrade_item_req item_cost = ", item_cost)
  log(bWriteLog and "ItemUpgradeModule.upgrade_item_req item_level = " .. tostring(item_level))
  log(bWriteLog and "ItemUpgradeModule.upgrade_item_req form_choice = " .. tostring(form_choice))
  local ItemUpGradeHandler = require("client.network.Protocol.ItemUpGradeHandler")
  ItemUpGradeHandler.send_upgrade_item_req(instid, group_id, item_level, item_cost, form_choice)
end
function ItemUpgradeModule:upgrade_item_rsp(error_code, ret)
  log(bWriteLog and "ItemUpgradeModule.upgrade_item_rsp error_code = " .. tostring(error_code))
  log_tree("ItemUpgradeModule.upgrade_item_rsp ret = ", ret)
  if error_code ~= 0 then
    ShowNotice(error_code)
    return
  end
  EventSystem:postEvent(EVENTTYPE_ITEM_UPGRADE, EVENTID_ITEM_UPGRADE_UPGRADE_RSP, ret)
end
function ItemUpgradeModule:send_upgrade_query_refit_req()
  local ItemUpGradeHandler = require("client.network.Protocol.ItemUpGradeHandler")
  ItemUpGradeHandler.send_upgrade_query_refit_req()
end
function ItemUpgradeModule:on_upgrade_query_refit_rsp(refit_info)
  log_tree(bWriteLog and "[bgp] on_upgrade_query_refit_rsp->refit_info:", refit_info)
  self.itemRefitUnlockList = refit_info or {}
  EventSystem:postEvent(EVENTTYPE_ITEM_UPGRADE, EVENTID_ITEM_UPGRADE_GET_REFIT_UNLOCK, refit_info)
end
function ItemUpgradeModule:IsCanSetRefitCfgTableInfo(group_id)
  self:InitRefitCfgData()
  if self.itemRefitConditionCfg and self.itemRefitConditionCfg[group_id] then
    return true
  end
  return false
end
function ItemUpgradeModule:GetRefitMaterialData(group_id)
  self:InitRefitCfgData()
  local cfg = self.itemRefitConditionCfg[group_id]
  if not cfg then
    log(bWriteLog and "[bgp] not materialCfg data")
    return {}
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local costData01 = wardrobe_data:GetHallDepotItemDataByResID(cfg.CostItem1)
  local costData02 = wardrobe_data:GetHallDepotItemDataByResID(cfg.CostItem2)
  if not costData01 or not costData02 then
    return {}
  end
  if costData01.count < cfg.CostItemNum1 or costData02.count < cfg.CostItemNum2 then
    return {}
  end
  return {
    [tonumber(costData01.insID)] = tonumber(cfg.CostItemNum1),
    [tonumber(costData02.insID)] = tonumber(cfg.CostItemNum2)
  }
end
function ItemUpgradeModule:GetNeedUnlockRefitResIDList(group_id, inst_id)
  local list = {}
  log(bWriteLog and "GetNeedUnlockRefitResIDList==inst_id" .. tostring(inst_id))
  local resID_list = self:GetUpgradeGroupByID(group_id) or {}
  for key, value in pairs(resID_list) do
    local effectID = value.EffectID
    if effectID == 1 or effectID == 2 or effectID == 3 then
      list[#list + 1] = {
        resID = value.ItemID,
        effectID = value.EffectID,
        Level = value.Level,
        isUnlock = self:CheckHasSameGroupItem(value.ItemID) == true
      }
    end
  end
  table.sort(list, function(a, b)
    return a.Level < b.Level
  end)
  return list
end
function ItemUpgradeModule:GetRefitItemMaterialList(refit_group_id)
  self:InitRefitCfgData()
  local refitTableCfg = self.itemRefitConditionCfg or {}
  for groupID, cfgData in pairs(refitTableCfg) do
    if cfgData.refitGroupID == refit_group_id then
      return self:CreateMaterialList(cfgData)
    end
  end
  return {}
end
function ItemUpgradeModule:IsRefitUnlockComplete(base_groupID, res_id)
  if self.itemRefitUnlockList and self.itemRefitUnlockList[base_groupID] then
    return true
  end
  return false
end
function ItemUpgradeModule:IsRefitUnlockComplete3(refit_groupID, res_id)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemData = wardrobe_data:GetHallDepotItemDataByResID(res_id)
  if not itemData then
    local itemID = self:ChangeItemIDByRefitGroupID(refit_groupID) or res_id
    itemData = wardrobe_data:GetHallDepotItemDataByResID(itemID)
  end
  if itemData then
    return true
  end
  return false
end
function ItemUpgradeModule:IsRefitComplete(group_id)
  self:InitRefitCfgData()
  return self.itemRefitInfo[group_id]
end
function ItemUpgradeModule:GetRefitGroupID(res_id)
  return self:GetGroupID(res_id) or 0
end
function ItemUpgradeModule:IsRefitItemID(res_id)
  self:InitRefitCfgData()
  local group_id = self:GetRefitGroupID(res_id)
  if self.itemRefitConditionCfg[group_id] or self.itemRefitInfo[group_id] then
    log(bWriteLog and "[bgp] IsRefitItemID======" .. tostring(group_id))
    return true
  end
  return false
end
function ItemUpgradeModule:_GetRefitConditionCfg(groupID)
  if not groupID then
    return nil
  end
  self:InitRefitCfgData()
  if self.itemRefitConditionCfg[groupID] then
    return self.itemRefitConditionCfg[groupID]
  end
  local baseGroupID = self.refitGroupToOriginGroupMap[groupID]
  if baseGroupID and self.itemRefitConditionCfg[baseGroupID] then
    return self.itemRefitConditionCfg[baseGroupID]
  end
  return nil
end
function ItemUpgradeModule:IsDualFormGroup(groupID)
  local cfg = self:_GetRefitConditionCfg(groupID)
  return cfg ~= nil and tonumber(cfg.refitFlag) == 2
end
function ItemUpgradeModule:GetForkLevel(groupID)
  local cfg = self:_GetRefitConditionCfg(groupID)
  return cfg and tonumber(cfg.minLevel) or 0
end
function ItemUpgradeModule:GetFullUnlockLevel(groupID)
  local cfg = self:_GetRefitConditionCfg(groupID)
  return cfg and tonumber(cfg.unlockAllLevel) or 0
end
function ItemUpgradeModule:IsAtForkLevel(groupID, curLevel)
  if not curLevel then
    return false
  end
  if not self:IsDualFormGroup(groupID) then
    return false
  end
  local fork = self:GetForkLevel(groupID)
  return 0 < fork and tonumber(curLevel + 1) == fork
end
function ItemUpgradeModule:IsItemExactlyOnFullUnlockLevel(nItemID)
  local groupID = self:GetGroupID(nItemID)
  if not groupID then
    return false
  end
  if not self:IsDualFormGroup(groupID) then
    return false
  end
  local nLevel = self:GetLevel(nItemID)
  local nFullUnlockLevel = self:GetFullUnlockLevel(groupID)
  return nLevel == nFullUnlockLevel
end
function ItemUpgradeModule:IsReachFullUnlockLevel(groupID, newLevel)
  if not newLevel then
    return false
  end
  if not self:IsDualFormGroup(groupID) then
    return false
  end
  local target = self:GetFullUnlockLevel(groupID)
  return 0 < target and tonumber(newLevel) == target
end
function ItemUpgradeModule:GetDualFormLevels(baseGroupID)
  local cfg = self:_GetRefitConditionCfg(baseGroupID)
  if not cfg or tonumber(cfg.refitFlag) ~= 2 then
    return nil
  end
  local groupX = cfg.groupID
  local groupY = cfg.refitGroupID
  if not groupX or not groupY then
    return nil
  end
  return {
    lvX = self:GetCurLevelByGroupID(groupX) or 0,
    lvY = self:GetCurLevelByGroupID(groupY) or 0,
    groupX = groupX,
      }
end
function ItemUpgradeModule:InferDualFormStage(baseGroupID)
  local levels = self:GetDualFormLevels(baseGroupID)
  if not levels then
    return "L0"
  end
  local lvX, lvY = levels.lvX, levels.lvY
  local forkLevel = self:GetForkLevel(baseGroupID)
  local fullLevel = self:GetFullUnlockLevel(baseGroupID)
  if forkLevel <= 0 then
    return "L0"
  end
  local maxLv = math.max(lvX, lvY)
  if forkLevel > maxLv then
    return "L0"
  end
  if maxLv == forkLevel then
    return "Fork"
  end
  if 0 < fullLevel and lvX >= fullLevel and lvY >= fullLevel then
    return "L2"
  end
  if lvX > forkLevel and lvY <= forkLevel then
    return "L1_X"
  end
  if lvY > forkLevel and lvX <= forkLevel then
    return "L1_Y"
  end
  if lvX >= lvY then
    return "L1_X"
  else
    return "L1_Y"
  end
end
function ItemUpgradeModule:IsDualFormRefitUnlocked(groupID)
  if not self:IsDualFormGroup(groupID) then
    return false
  end
  local levels = self:GetDualFormLevels(groupID)
  if not levels then
    return false
  end
  return levels.lvX > 0 or 0 < levels.lvY
end
function ItemUpgradeModule:GetPairFormItemID(ItemID)
  if not ItemID then
    return nil
  end
  local groupID = self:GetGroupID(ItemID)
  if not groupID then
    return nil
  end
  if not self:IsDualFormGroup(groupID) then
    return nil
  end
  local pairGroupID = self:GetPairGroup(groupID)
  if not pairGroupID or pairGroupID == -1 or pairGroupID == 0 then
    return nil
  end
  local level = self:GetLevel(ItemID)
  if not level or level <= 0 then
    return nil
  end
  local cfg = self:GetConfigByGroupIDAndLevel(pairGroupID, level)
  return cfg and cfg.ItemID or nil
end
function ItemUpgradeModule:UpdateRefitUnlockData(refit_info)
  log_tree(bWriteLog and "[bgp] UpdateRefitUnlockData->refit_info:", refit_info)
  for group_id, time in pairs(refit_info) do
    if not self.itemRefitUnlockList then
      self.itemRefitUnlockList = {}
    end
    self.itemRefitUnlockList[group_id] = time
  end
  EventSystem:postEvent(EVENTTYPE_ITEM_UPGRADE, EVENTID_ITEM_UPGRADE_REFIT_UNLOCK_SUCCESS, refit_info)
end
function ItemUpgradeModule:GetNeedUnlockLevel(effect_list, cur_effect_level)
  if not effect_list or not next(effect_list) then
    return 1
  end
  for idx, value in pairs(effect_list) do
    if tonumber(value.Level) >= tonumber(cur_effect_level) then
      return idx
    end
  end
  return 1
end
function ItemUpgradeModule:GetRefitCfgData(group_id)
  self:InitRefitCfgData()
  for groupID, cfg in pairs(self.itemRefitConditionCfg) do
    if groupID == group_id or cfg.refitGroupID == group_id then
      return cfg
    end
  end
  return {}
end
function ItemUpgradeModule:GetNormalGroupID(group_id)
  local GunID = self:GetCurItemIDOrFirstItemIDByGroupID(group_id)
  local BaseGunID = self:GetBaseItemID(GunID)
  if GunID ~= BaseGunID then
    group_id = self:GetRefitGroupID(BaseGunID)
  end
  local refitCfg = self:GetRefitCfgData(group_id)
  if refitCfg and next(refitCfg) then
    group_id = refitCfg.groupID
  end
  return group_id
end
function ItemUpgradeModule:GetNormalGroupIDOfWeaponID(WeaponID)
  local BaseWeaponID = self:GetBaseItemID(WeaponID)
  local GroupID = self:GetRefitGroupID(BaseWeaponID)
  local refitCfg = self:GetRefitCfgData(GroupID)
  if refitCfg and next(refitCfg) then
    GroupID = refitCfg.groupID
  end
  return GroupID
end
function ItemUpgradeModule:GetNormalWeaponID(WeaponID)
  if self.NormalWeaponIDCache and self.NormalWeaponIDCache[WeaponID] then
    return self.NormalWeaponIDCache[WeaponID]
  end
  local BaseWeaponID = self:GetBaseItemID(WeaponID)
  local GroupID = self:GetGroupID(BaseWeaponID)
  local Level = self:GetLevel(BaseWeaponID)
  if GroupID and Level then
    local refitCfg = self:GetRefitCfgData(GroupID)
    if refitCfg and next(refitCfg) then
      self:InitItemUpgradeConfig()
      local key = GroupID .. "|" .. Level
      local ItemID = self.itemUpgradeConfigsKeyByGroupIDAndLevel[key]
      if ItemID then
        BaseWeaponID = ItemID
      end
    end
  end
  if self.NormalWeaponIDCache then
    self.NormalWeaponIDCache[WeaponID] = BaseWeaponID
  end
  return BaseWeaponID
end
function ItemUpgradeModule:GetRefitResIdByEffectID(group_id, cur_effect_level)
  local refitCfg = self:GetRefitCfgData(group_id)
  local effectCfg = self:GetUpgradeGroupByID(refitCfg.refitGroupID or 0) or {}
  for _, effect_cfg in pairs(effectCfg) do
    if effect_cfg.Level == cur_effect_level then
      return effect_cfg.ItemID
    end
  end
  return effectCfg[1] and effectCfg[1].ItemID or 0
end
function ItemUpgradeModule:ChangeItemIDByRefitGroupID(group_id)
  self:InitRefitCfgData()
  local refitCfg = self.itemRefitConditionCfg[group_id] or {}
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local groupList = self:GetUpgradeGroupByID(refitCfg.refitGroupID)
  if groupList ~= nil then
    for _, cfg in ipairs(groupList) do
      local resid = self:GetCurrentStateItemID(cfg.ItemID)
      if wardrobe_data:GetHallDepotItemDataByResID(resid) ~= nil then
        return resid
      end
    end
  end
  return nil
end
function ItemUpgradeModule:GetRefitGuideSubTabIndex(item_list, is_group_id)
  if not item_list or not next(item_list) then
    return 0
  end
  for index, v in pairs(item_list) do
    local group_id = v.groupID
    if is_group_id then
      if is_group_id == group_id then
        return index
      end
    elseif self:IsCanSetRefitCfgTableInfo(group_id) then
      return index
    end
  end
  log(bWriteLog and "[bgp] GetRefitGuideSubTabIndex")
  return 1
end
function ItemUpgradeModule:IsRefershRefitMaterial(res_id)
  local group_id = self:GetRefitGroupID(res_id)
  local isRefit = self:IsRefitComplete(group_id)
  local isUnlock = self:IsRefitUnlockComplete(group_id, res_id) or self:IsDualFormRefitUnlocked(group_id)
  if isRefit or isUnlock then
    return false
  end
  return true
end
function ItemUpgradeModule:GetRefitItemIdByResID(res_id)
  local groupID = self:GetRefitGroupID(res_id)
  local isRefitID = self:IsCanSetRefitCfgTableInfo(groupID)
  if isRefitID then
    return self:ChangeItemIDByRefitGroupID(groupID)
  end
end
function ItemUpgradeModule:GetRefitSwitcherID(ItemID)
  if self:IsWeaponIsRefit(ItemID) then
    return self:GetNormalItemID(ItemID)
  else
    return self:GetRefitItemID(ItemID)
  end
end
function ItemUpgradeModule:GetNormalItemID(ItemID)
  if not self:IsWeaponIsRefit(ItemID) then
    return ItemID
  end
  local groupID = self:GetRefitGroupID(ItemID)
  local refitCfg = self:GetRefitCfgData(groupID)
  local CurLevel = self:GetItemEffectLevel(ItemID)
  local cfg = self:GetConfigByGroupIDAndLevel(refitCfg.groupID, CurLevel)
  return cfg.ItemID
end
function ItemUpgradeModule:GetRefitItemIDByGroupID(GroupID, ItemID)
  if not GroupID or not ItemID then
    return 0
  end
  local CurLevel = self:GetItemEffectLevel(ItemID)
  local cfg = self:GetConfigByGroupIDAndLevel(GroupID, CurLevel)
  return cfg and cfg.ItemID or ItemID
end
function ItemUpgradeModule:GetRefitItemIDByNormalID(ItemID)
  local RefitgroupID = self:GetRefitWeaponGroupID(ItemID)
  if not RefitgroupID or RefitgroupID <= 0 then
    return ItemID
  end
  local CurLevel = self:GetItemEffectLevel(ItemID)
  local cfg = self:GetConfigByGroupIDAndLevel(RefitgroupID, CurLevel)
  return cfg and cfg.ItemID or ItemID
end
function ItemUpgradeModule:GetRefitItemID(ItemID)
  if self:IsWeaponIsRefit(ItemID) then
    return ItemID
  end
  local RefitgroupID = self:GetRefitWeaponGroupID(ItemID)
  local CurLevel = self:GetItemEffectLevel(ItemID)
  if not RefitgroupID then
    return ItemID
  end
  local cfg = self:GetConfigByGroupIDAndLevel(RefitgroupID, CurLevel)
  return cfg and cfg.ItemID or ItemID
end
function ItemUpgradeModule:IsWeaponIsRefit(ItemID)
  self:InitRefitCfgData()
  local groupID = self:GetRefitGroupID(ItemID)
  return self.itemRefitInfo[groupID]
end
function ItemUpgradeModule:GetRefitWeaponGroupID(ItemID)
  local groupID = self:GetRefitGroupID(ItemID)
  local refitCfg = self:GetRefitCfgData(groupID)
  return refitCfg.refitGroupID
end
function ItemUpgradeModule:GetWeaponSwitchIcon(ItemID)
  local Level1ItemID = self:GetLevel1ItemID(ItemID)
  local WeaponSwitchConfig = CDataTable.GetTableData("WeaponSwitchConfig", Level1ItemID)
  if not WeaponSwitchConfig then
    log_error("ItemUpgradeModule GetWeaponSwitchIcon  not WeaponSwitchConfig ItemID" .. tostring(ItemID) .. " Level1ItemID:" .. tostring(Level1ItemID))
    return ""
  end
  return WeaponSwitchConfig.SwtichICON
end
function ItemUpgradeModule:IsSwitchStateWeapon(ItemID)
  local Level1ItemID = self:GetLevel1ItemID(ItemID)
  local WeaponSwitchConfig = CDataTable.GetTableData("WeaponSwitchConfig", Level1ItemID)
  if WeaponSwitchConfig then
    return true
  end
  return false
end
function ItemUpgradeModule:GetSwitchWeaponState(ItemID)
  local Level1ItemID = self:GetLevel1ItemID(ItemID)
  local WeaponSwitchConfig = CDataTable.GetTableData("WeaponSwitchConfig", Level1ItemID)
  if WeaponSwitchConfig then
    return WeaponSwitchConfig.Status
  end
  return nil
end
function ItemUpgradeModule:IsRefitUnlockComplete2(ItemID, Source)
  local NormalID = self:GetNormalItemID(ItemID)
  local normal_group_id = self:GetRefitGroupID(NormalID)
  local UnlockList
  if Source == EWardrobeDataSource.InheritWardrobe then
    local LogicInheritWardrobe = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicInheritWardrobe)
    UnlockList = LogicInheritWardrobe:GetRefitMapInherit()
  else
    UnlockList = self.itemRefitUnlockList
  end
  if UnlockList and UnlockList[normal_group_id] then
    return true
  end
  if Source ~= EWardrobeDataSource.InheritWardrobe and self:IsDualFormRefitUnlocked(normal_group_id) then
    return true
  end
  return false
end
function ItemUpgradeModule:IsRefitMaterialByResID(item_id)
  self:InitRefitCfgData()
  if not self.itemRefitConditionCfg or not next(self.itemRefitConditionCfg) then
    return false
  end
  for group_id, data in pairs(self.itemRefitConditionCfg) do
    if tonumber(item_id) == tonumber(data.CostItem1) then
      return true
    end
  end
  return false
end
function ItemUpgradeModule:GetGroupIDByMaterialID(item_id)
  self:InitRefitCfgData()
  if not self.itemRefitConditionCfg or not next(self.itemRefitConditionCfg) then
    return nil
  end
  for group_id, data in pairs(self.itemRefitConditionCfg) do
    if tonumber(item_id) == tonumber(data.CostItem1) then
      return group_id
    end
  end
  return nil
end
function ItemUpgradeModule:GetMaterialFragment(material_id)
  if not self.MaterialFragmentMap then
    self.MaterialFragmentMap = {}
    local tb = CDataTable.GetTable("MaterialFragmentMap")
    for materialItemID, cfg in pairs(tb) do
      self.MaterialFragmentMap[tostring(materialItemID)] = tostring(cfg.FragItemID)
    end
  end
  return self.MaterialFragmentMap[tostring(material_id)]
end
function ItemUpgradeModule:HasFragment(material_id)
  return self:GetMaterialFragment(material_id) ~= nil
end
function ItemUpgradeModule:ShowUI(itemID)
  if LobbySystem.CheckLobbyMenuOpen(BP_ENUM_ITEM_UPGRADE, true) == false then
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.item_upgrade, itemID)
end
function ItemUpgradeModule:CloseUI()
  self:SetIsInPendantEffect(false)
  UIManager.CloseUI(UIManager.UI_Config.item_upgrade)
end
function ItemUpgradeModule:OnJumpUrl(eventType, eventID, vars)
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  if not level_unlock_manager:IsFeatureUnlocked(level_unlock_manager.featureDef.workshop) then
    ShowNotice(level_unlock_manager:GetLockTip(level_unlock_manager.featureDef.workshop))
    return
  end
  if vars == nil or vars.itemId == nil then
    self:ShowUI()
  else
    log(bWriteLog and "ItemUpgradeModule.OnJumpUrl itemid = " .. tostring(vars.itemId))
    self:ShowUI(tonumber(vars.itemId))
  end
end
function ItemUpgradeModule:GetBindItem(resId)
  local itemUpgradeCfg = self:GetUpgradeCfg(resId)
  local groupID = itemUpgradeCfg and itemUpgradeCfg.GroupID or nil
  if not groupID then
    return nil
  end
  return self:GetBindItemByGroupID(groupID)
end
function ItemUpgradeModule:GetBindItemByGroupID(groupID)
  if not next(self.groupIdToBindItemIDMap) then
    local bindCfgTable = CDataTable.GetTable("GrenadeKillGunBindMap")
    if bindCfgTable then
      for bindItemID, bindCfg in pairs(bindCfgTable) do
        if bindCfg.GrenadeID ~= 0 then
          local GunID = bindCfg.GunIDList_a:Get(0)
          local cfg = self:GetUpgradeCfg(GunID)
          local TmpGroupID = cfg and cfg.GroupID or nil
          if TmpGroupID then
            if not self.groupIdToBindItemIDMap[TmpGroupID] then
              self.groupIdToBindItemIDMap[TmpGroupID] = {}
            end
            table.insert(self.groupIdToBindItemIDMap[TmpGroupID], bindItemID)
          end
        end
      end
    end
  end
  return self.groupIdToBindItemIDMap[groupID]
end
function ItemUpgradeModule:IsWeaponEmoteUnlockedWithOutCheckWeapon(EmoteID)
  if EmoteID == 0 then
    return false
  end
  local Cfg = CDataTable.GetTableData("ItemUpgradeCollectEmote", EmoteID)
  if not Cfg then
    return true
  end
  local XSuitID = Cfg.CollectItemID_a:Get(0)
  local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
  if LogicXSuit.CheckHasSameGroupItem(XSuitID) then
    return true
  else
    return false
  end
end
function ItemUpgradeModule:GetWeaponEmoteCollectID(EmoteID)
  if EmoteID == 0 then
    return 0
  end
  local Cfg = CDataTable.GetTableData("ItemUpgradeCollectEmote", EmoteID)
  if not Cfg then
    return 0
  end
  return Cfg.CollectItemID_a:Get(0)
end
function ItemUpgradeModule:IsWeaponEmoteUnlocked(EmoteID)
  local Cfg = CDataTable.GetTableData("ItemUpgradeCollectEmote", EmoteID)
  if not Cfg then
    return true
  end
  local WeaponID = Cfg.BindWeaponID_a:Get(0)
  local UpgradeCfg = self:GetUpgradeCfg(WeaponID)
  if UpgradeCfg then
    local level = self:GetLevelByGroupIDFull(UpgradeCfg.GroupID)
    if level < 5 then
      return false
    end
  end
  local XSuitID = Cfg.CollectItemID_a:Get(0)
  local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
  if LogicXSuit.CheckHasSameGroupItem(XSuitID) then
    return true
  else
    return false
  end
end
function ItemUpgradeModule:GetSwitchWeaponAction(PreSkin, AfterSkin)
  if not PreSkin or not AfterSkin then
    return nil
  end
  local preGroup = self:GetGroupID(PreSkin)
  local afterGroup = self:GetGroupID(AfterSkin)
  if not preGroup or not afterGroup then
    return nil
  end
  local config = CDataTable.GetTableDataByFilter("ItemUpgradeSwitchAction", "BeforeGroup", preGroup, "AfterGroup", afterGroup)
  if config then
    return config
  end
  return nil
end
function ItemUpgradeModule:SetSwitchWeaponActionPlan(UID, ID)
  log(bWriteLog and "ItemUpgradeModule:SetSwitchWeaponAction UID = " .. tostring(UID) .. ",  ID = " .. tostring(ID))
  if not UID or UID == "" then
    return
  end
  UID = tonumber(UID)
  self.SwitchWeaponActionPlan[UID] = ID
end
function ItemUpgradeModule:GetSwitchWeaponActionPlan(UID)
  UID = tonumber(UID)
  return self.SwitchWeaponActionPlan[UID]
end
local class = require("class")
local CItemUpgradeModule = require("client.module_framework.ModuleBase")
local CItemGetModule = class(CItemUpgradeModule, nil, ItemUpgradeModule)
return CItemGetModule