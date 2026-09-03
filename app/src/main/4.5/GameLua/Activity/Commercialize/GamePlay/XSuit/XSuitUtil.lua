local XSuitUtil = {
  bUpgradeInfoInited = false,
  itemInfoList = {},
  upgradeInfo = {},
  bornIslandActionCache = nil,
  MaxPeriod = 0
}
function XSuitUtil:Contains_Util(Table, tb)
  if Table == nil then
    return false
  end
  if Table.__name == "LuaSet" then
    for k, v in pairs(Table) do
      if v == tb then
        return true
      end
    end
  elseif Table.__name == "LuaMap" then
    for k, v in pairs(Table) do
      if k == tb then
        return true
      end
    end
  else
    for k, v in pairs(Table) do
      if v == tb then
        return true
      end
    end
  end
  return false
end
function XSuitUtil:HasXSuit(uCharacter, XSuitIDs)
  if not Game or not Game:IsValid(uCharacter) then
    return false
  end
  local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local EAvatarSlotType = import("EAvatarSlotType")
  local XSuitID = STExtraBlueprintFunctionLibrary.GetPlayerWearingGoldenSuitID(uCharacter, uCharacter, EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot)
  return self:Contains_Util(XSuitIDs, XSuitID)
end
function XSuitUtil:InitUpgradeInfo()
  local cfg
  cfg = CDataTable.GetTable("GoldenSuitUpgradeCfg")
  self.MaxPeriod = 0
  for _, j in pairs(cfg) do
    if j.Period > self.MaxPeriod then
      self.MaxPeriod = j.Period
    end
    if self.upgradeInfo[j.Period] == nil then
      self.upgradeInfo[j.Period] = {}
    end
    if self.upgradeInfo[j.Period][j.BranchId] == nil then
      self.upgradeInfo[j.Period][j.BranchId] = {}
    end
    local info = {
      item_id = j.ItemID
    }
    self.upgradeInfo[j.Period][j.BranchId][j.Star] = info
    self.itemInfoList[j.ItemID] = {
      period = j.Period,
      level = j.Star,
      BranchId = j.BranchId
    }
  end
  local stateCfg = CDataTable.GetTable("ClothingStateConfig")
  if stateCfg then
    for _, v in pairs(stateCfg) do
      if v.State == 2 and v.OriginClothID and v.NewClothID then
        local itemInfo = self.itemInfoList[v.OriginClothID]
        local branchId = 0
        if itemInfo then
          self.upgradeInfo[itemInfo.period][branchId][itemInfo.level].second_item_id = v.NewClothID
          itemInfo.second_item_id = v.NewClothID
          self.itemInfoList[v.NewClothID] = {
            period = itemInfo.period,
            level = itemInfo.level,
            BranchId = branchId
          }
        end
      end
    end
  end
  self.bUpgradeInfoInited = true
end
function XSuitUtil:GetCfgByItemId(itemID)
  if not self.bUpgradeInfoInited then
    self:InitUpgradeInfo()
  end
  return self.itemInfoList[itemID]
end
function XSuitUtil:GetPeriodByItemId(itemID)
  if not self.bUpgradeInfoInited then
    self:InitUpgradeInfo()
  end
  if self.itemInfoList[itemID] then
    return self.itemInfoList[itemID].period
  end
  return nil
end
function XSuitUtil:GetLevelByItemId(itemID)
  if not self.bUpgradeInfoInited then
    self:InitUpgradeInfo()
  end
  if self.itemInfoList[itemID] then
    return self.itemInfoList[itemID].level
  end
  return 0
end
function XSuitUtil:GetBranchIdByItemId(itemID)
  if not self.bUpgradeInfoInited then
    self:InitUpgradeInfo()
  end
  if self.itemInfoList[itemID] then
    return self.itemInfoList[itemID].BranchId
  end
end
function XSuitUtil:GetSwitchItemByItemAndSwitchLevel(itemID, switchLevel)
  if not self.bUpgradeInfoInited then
    self.InitUpgradeInfo()
  end
  local period = self:GetPeriodByItemId(itemID)
  if period == nil then
    return itemID
  end
  local originalLevel = self.itemInfoList[itemID].level
  if switchLevel > originalLevel then
    return itemID
  else
    local putOnLevel = originalLevel
    if switchLevel == 1 then
      if originalLevel == 1 then
        putOnLevel = 1
      else
        putOnLevel = 2
      end
    elseif switchLevel == 3 then
      if 5 <= originalLevel then
        putOnLevel = 5
      else
        putOnLevel = originalLevel
      end
    elseif switchLevel == 6 then
      putOnLevel = 6
    elseif switchLevel == 7 then
      putOnLevel = 7
    end
    local branchId = self:GetBranchIdByItemId(itemID)
    return self.upgradeInfo[period][branchId][putOnLevel].item_id
  end
end
function XSuitUtil:GetAllUpgradeInfo()
  if not self.bUpgradeInfoInited then
    self.InitUpgradeInfo()
  end
  return self.upgradeInfo
end
function XSuitUtil:GetUpgradeInfoByPeriodAndBranchId(period, branchId)
  if not period or not branchId then
    return nil
  end
  if not self.bUpgradeInfoInited then
    self.InitUpgradeInfo()
  end
  return self.upgradeInfo[period][branchId]
end
function XSuitUtil:ChangeItemIDByState(itemID, state)
  if itemID and self.itemInfoList[itemID] then
    local secondID = self.itemInfoList[itemID].second_item_id
    if state == 2 and secondID ~= 0 then
      return secondID
    end
  end
  return itemID
end
function XSuitUtil:InitBornIslandAction()
  self.bornIslandActionCache = {}
  local GoldenSuitMapCfg = CDataTable.GetTable("GoldenSuitMapCfg")
  if GoldenSuitMapCfg then
    for _, v in pairs(GoldenSuitMapCfg) do
      self.bornIslandActionCache[v.Period] = self.bornIslandActionCache[v.Period] or {}
      self.bornIslandActionCache[v.Period][v.BranchId] = v.BattleActionID
    end
  end
  local EmotionLimitCfgCfg = CDataTable.GetTable("EmotionLimitCfg")
  if EmotionLimitCfgCfg then
    for _, v in pairs(EmotionLimitCfgCfg) do
      if v.IsShow == 1 then
        for _, u in pairs(v.ItemID_a) do
          self.bornIslandActionCache[tonumber(u)] = v.EmotionID
        end
      end
    end
  end
end
function XSuitUtil:GetBornIslandAction(ID, branchId)
  if not ID or ID == 0 then
    return 0
  end
  if not self.bornIslandActionCache then
    self:InitBornIslandAction()
  end
  if ID and branchId then
    return self.bornIslandActionCache[ID] and self.bornIslandActionCache[ID][branchId] or 0
  end
  if self.bornIslandActionCache[ID] then
    return self.bornIslandActionCache[ID] or 0
  end
  return 0
end
function XSuitUtil:GetBornIslandActionByItemID(ItemID, uAvatarComp2)
  if not ItemID or not slua.isValid(uAvatarComp2) then
    return 0
  end
  local period = self:GetPeriodByItemId(ItemID)
  local EmotionID = 0
  if period and 0 < period then
    local branchId = self:GetBranchIdByItemId(ItemID)
    EmotionID = XSuitUtil:GetBornIslandAction(period, branchId)
  end
  if EmotionID <= 0 then
    EmotionID = XSuitUtil:GetBornIslandAction(ItemID)
    local EmotionLimitCfg = CDataTable.GetTableData("EmotionLimitCfg", EmotionID)
    if 0 < EmotionID and EmotionLimitCfg and EmotionLimitCfg.IsShow == 1 and EmotionLimitCfg.ItemID_a then
      for _, u in pairs(EmotionLimitCfg.ItemID_a) do
        if tonumber(u) ~= ItemID and not uAvatarComp2:IsEquippedItemID(tonumber(u)) then
          print(bWriteLog and "XSuitUtil:GetBornIslandActionByItemID return of " .. tostring(u) .. " not equipped. ItemID:" .. tostring(ItemID) .. " period:" .. tostring(period) .. " EmotionID:" .. tostring(EmotionID))
          return 0
        end
      end
    end
  end
  print(bWriteLog and "XSuitUtil:GetBornIslandActionByItemID ItemID:" .. tostring(ItemID) .. " period:" .. tostring(period) .. " EmotionID:" .. tostring(EmotionID))
  return EmotionID
end
function XSuitUtil:IsValidBornIslandAction(action, UnlockLevel)
  if not action or action == 0 then
    return false
  end
  if not self.bornIslandActionCache then
    self:InitBornIslandAction()
  end
  local period
  for k, v in pairs(self.bornIslandActionCache) do
    if k <= 100 then
      for branch, act in pairs(v) do
        if act == action then
          period = k
          break
        end
      end
    end
  end
  if not period or not UnlockLevel then
    return false
  end
  local LowLevelEffect = require("GameLua.Activity.Commercialize.GamePlay.XSuit.LowLevelEffect")
  local effect_level = self:GetEffectMinLevel(LowLevelEffect.BornIslandAction)
  if UnlockLevel < effect_level then
    return false
  end
  return UnlockLevel >= effect_level
end
function XSuitUtil:IsMultiStateXSuit(ItemID)
  local cfg = self:GetCfgByItemId(ItemID)
  if not cfg then
    return false
  end
  local stateCfg = CDataTable.GetTableData("ClothingStateConfig", ItemID)
  if not stateCfg then
    return false
  end
  return true
end
function XSuitUtil:GetStateIcon(ItemID)
  local stateCfg = CDataTable.GetTableData("ClothingStateConfig", ItemID)
  if stateCfg and stateCfg.BattleIcon ~= "" then
    return stateCfg.BattleIcon
  end
  return nil
end
function XSuitUtil:GetEffectMinLevel(EffectType)
  local EffectInfo = CDataTable.GetTableData("LowLevelEffect", EffectType)
  if not EffectInfo or not EffectInfo.EffectLevel then
    return 0
  end
  return EffectInfo.EffectLevel
end
function XSuitUtil:IsOpenLowLevelEffect(ItemID, EffectType, Period)
  if not Period or Period <= 0 then
    return false
  end
  local XSuitBattleEffectCfg = CDataTable.GetTableData("GoldClothBattleEffect", ItemID)
  if not XSuitBattleEffectCfg then
    return false
  end
  local EffectInfo = CDataTable.GetTableData("LowLevelEffect", EffectType)
  if not EffectInfo or not EffectInfo.LowLevelPeriod_a then
    return false
  end
  for _, v in pairs(EffectInfo.LowLevelPeriod_a) do
    if Period == v then
      return true
    end
  end
  return false
end
function XSuitUtil:IsValidXSuitEffect(ItemID, EffectType, UnlockLevel)
  local ShowLevel = self:GetLevelByItemId(ItemID)
  local Period = self:GetPeriodByItemId(ItemID)
  local bOpen = self:IsOpenLowLevelEffect(ItemID, EffectType, Period)
  local EffectLevel = self:GetEffectMinLevel(EffectType)
  local bValid = false
  if bOpen then
    bValid = UnlockLevel >= EffectLevel
  else
    bValid = ShowLevel >= EffectLevel
  end
  return bValid
end
function XSuitUtil.IsUserOpenSpecialGlideSetting(UID, ItemID)
  print(bWriteLog and "[XSuitGlide] CommerFeature IsUserOpenSpecialGlideSetting UID" .. tostring(UID))
  local ServerPlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
  local ExtendAttribute = require("Server.config.ExtendAttribute")
  local SpecialGlideSetting = ServerPlayerDataMgr.GetPlayerProgressFromServer(UID, ExtendAttribute.SpecialGlideSetting)
  if SpecialGlideSetting and SpecialGlideSetting[ItemID] == false then
    return false
  end
  return true
end
function XSuitUtil:GetMaxPeriod()
  return self.MaxPeriod
end
function XSuitUtil:GetPeriodByBattleActionID(EmoteID)
  if not EmoteID or EmoteID <= 0 then
    return 0
  end
  local config = CDataTable.GetTableDataByFilter("GoldenSuitMapCfg", "BattleActionID", EmoteID)
  return config and config.Period or 0
end
function XSuitUtil:GetUnLockLevelByFeature(ItemID, Period, XSuitUnlockLevelList)
  if not (Period and not (Period <= 0) and XSuitUnlockLevelList) or 0 >= XSuitUnlockLevelList:Num() then
    return 0
  end
  local UnLockLevel = XSuitUnlockLevelList:Get(Period - 1)
  local ShowLevel = XSuitUtil:GetLevelByItemId(ItemID)
  if not UnLockLevel or UnLockLevel < ShowLevel then
    UnLockLevel = ShowLevel
  end
  return UnLockLevel
end
function XSuitUtil:IsUnlockedFeature(Period, branchId, UnLockFeatureType)
  branchId = branchId or 0
  local config = CDataTable.GetTableDataByFilter("UnLockFeatureCfg", "EffectType", UnLockFeatureType, "Period", Period, "BranchId", branchId)
  if not config then
    return false
  end
  return true, config.EffectLevel, config.UnlockIndex
end
function XSuitUtil:GetUnlockFeatureCfg(UnLockFeatureType)
  local UnLockFeatureCfgs = CDataTable.GetTableByFilter("UnLockFeatureCfg", "EffectType", UnLockFeatureType)
  return UnLockFeatureCfgs
end
function XSuitUtil:IsExecutePlanResourceReady(PlanID)
  if not PlanID or PlanID <= 0 then
    return false
  end
  local PlanRow = CDataTable.GetTableData("ExecuteSkinTable", PlanID)
  if not PlanRow then
    return false
  end
  local ExecutorPath = PlanRow.ExecutorMontage
  if not ExecutorPath or ExecutorPath == "" then
    return false
  end
  local PathList = {ExecutorPath}
  local TargetPath = PlanRow.TargetMontage
  if TargetPath and TargetPath ~= "" then
    table.insert(PathList, TargetPath)
  end
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  if not PufferManager.GetListIsDownloaded(PufferConst.ENUM_DownloadType.ODPAK, PathList) then
    print(bWriteLog and string.format("[Execute] resource not ready PlanID=%d Executor=%s Target=%s", PlanID, ExecutorPath, tostring(TargetPath)))
    return false
  end
  return true
end
function XSuitUtil:GetEquippedExecutePlanID(uOwner)
  if not slua.isValid(uOwner) then
    return 0
  end
  local uAvatarComp = uOwner.getAvatarComponent2 and uOwner:getAvatarComponent2()
  if not slua.isValid(uAvatarComp) then
    return 0
  end
  local EAvatarSlotType = import("EAvatarSlotType")
  local SyncData = uAvatarComp.GetSlotSyncData and uAvatarComp:GetSlotSyncData(EAvatarSlotType.EAvatarSlotType_ClothesEquipemtSlot)
  local ItemID = SyncData and SyncData.ItemID or 0
  if ItemID <= 0 then
    return 0
  end
  local Cfg = CDataTable.GetTableData("GoldClothBattleEffect", ItemID)
  if not Cfg then
    return 0
  end
  local PlanID = Cfg.ExecutePlanID or 0
  if PlanID <= 0 then
    return 0
  end
  local FLAG_LEVEL_EXECUTE = 5
  local period = self:GetPeriodByItemId(ItemID)
  local branchId = self:GetBranchIdByItemId(ItemID) or 0
  if period and uAvatarComp.XSuitFeatureFlagMap then
    local XSuitFeatureSwitchType = require("GameLua.Activity.Commercialize.GamePlay.XSuit.XSuitFeatureSwitchType")
    local flagItem = uAvatarComp.XSuitFeatureFlagMap[period] and uAvatarComp.XSuitFeatureFlagMap[period][branchId] and uAvatarComp.XSuitFeatureFlagMap[period][branchId][FLAG_LEVEL_EXECUTE] and uAvatarComp.XSuitFeatureFlagMap[period][branchId][FLAG_LEVEL_EXECUTE][XSuitFeatureSwitchType.Execute]
    if flagItem and flagItem.flag_state == 0 then
      print(bWriteLog and string.format("[Execute]XSuitUtil:GetEquippedExecutePlanID flag closed by player ItemID=%d Period=%s Branch=%s", ItemID, tostring(period), tostring(branchId)))
      return 0
    end
  end
  return PlanID
end
return XSuitUtil