local collect_introduction_module = {}
local _nCheckColorShapeIsOwned = function(nItemId, nTotalScore, nOwnedScore, fInsertFun)
  local Logic_ColorShapeUtils = require("client.slua.logic.wardrobe.Logic_ColorShapeUtils")
  local bIsOwnedOneShape = Logic_ColorShapeUtils.CheckMultiColorShapeOwnedStatus(nItemId)
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local nCurItemScore = collect_module:GetScoreByItemId(nItemId)
  if bIsOwnedOneShape then
    nOwnedScore = nOwnedScore + nCurItemScore
  end
  fInsertFun(nItemId, nCurItemScore, bIsOwnedOneShape)
  nTotalScore = nTotalScore + nCurItemScore
  return nTotalScore, nOwnedScore
end
function collect_introduction_module:GetBannerList(key)
  local bannerData = {}
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local configs = collect_module:GetSplitTable("RankPointsInstructions", collect_module.E_ColCfgMode.DifJK)
  if not configs then
    return bannerData
  end
  local config = configs[key]
  if not config then
    return bannerData
  end
  local subThemes = collect_module:GetSplitTable("CollectRankSubTheme", collect_module.E_ColCfgMode.DifJK)
  local themeIDStr = tostring(config.Parameter)
  log(bWriteLog and string.format("Collect_Popup_TimeLimitedRank_UIBP:SetClothesBanner themeIDStr = %s", themeIDStr))
  local StringUtil = require("common.string_util")
  local list = StringUtil.Split(themeIDStr, "|")
  if list then
    for i, v in ipairs(list) do
      local themeID = tonumber(v)
      local config = subThemes[themeID]
      if config then
        bannerData[#bannerData + 1] = config
      end
    end
  end
  local collect_encryption_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_encryption_module)
  local TimeUtil = require("client.common.time_util")
  local current = TimeUtil.GetServerTimeInSec()
  local getWeight = function(config)
    if config.EndTime then
      local show = TimeUtil.TimeStringToUnixstamp(config.EndTime)
      if show <= current then
        return 1
      end
    end
    if collect_encryption_module:IsEncryptionSeries(config.Version, config.Time) then
      return 2
    end
    return 3
  end
  table.sort(bannerData, function(a, b)
    return getWeight(a) > getWeight(b)
  end)
  return bannerData
end
function collect_introduction_module:GetClothesScoreConfig(key, style)
  local list = {}
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local configs = collect_module:GetSplitTable("RankPointsInstructions", collect_module.E_ColCfgMode.DifJK)
  if not configs then
    return list
  end
  local config = configs[key]
  if not config then
    return list
  end
  local clothesScoreStr = tostring(config.Parameter)
  log(bWriteLog and string.format("Collect_Popup_TimeLimitedRank_UIBP:GetClothesScoreConfig clothesScoreStr = %s", clothesScoreStr))
  local StringUtil = require("common.string_util")
  local group = StringUtil.Split(clothesScoreStr, "|")
  if group then
    for i, v in ipairs(group) do
      local temp = StringUtil.Split(v, ";")
      local scoreStr = temp[2] or ""
      if StringUtil.StrFind(scoreStr, "~") then
        local sTemp = StringUtil.Split(scoreStr, "~")
        scoreStr = LocUtil.LocalizeResFormat(77664, sTemp[1] or 0, sTemp[2] or 0)
      else
        scoreStr = LocUtil.LocalizeResFormat(77622, scoreStr or 0)
      end
      list[#list + 1] = {
        tiers = tonumber(temp[1] or 0),
        score = scoreStr,
              }
    end
  end
  return list
end
function collect_introduction_module:GetSubThemeItems(subThemeID, nType)
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local configs = collect_module:GetSplitTableByFilter("CollectRankItem", collect_module.E_ColCfgMode.DifJK, "SubThemeID", subThemeID)
  if not configs then
    return {}
  end
  local items = {}
  for i, v in pairs(configs) do
    if nType then
      if v.Type == nType then
        items[#items + 1] = v.ItemID
      end
    else
      items[#items + 1] = v.ItemID
    end
  end
  return items
end
function collect_introduction_module:GetOwnedAndTotal(items)
  local logic_suit_dye = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_suit_dye)
  local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
  local StoreUtils = require("client.slua.logic.store.utils.store_utils_config")
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local ItemUpgradeModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
  local total, owned = 0, 0
  local normalProcessing = function(itemId)
    if StoreUtils.HasItem(itemId, 0, 0, true) then
      owned = owned + 1
    end
    total = total + 1
  end
  local multiStateMarkers = {}
  local multiStateProcessing = function(itemId)
    local MultiLevelItemCfg = CDataTable.GetTableData("MultiLevelItem", itemId)
    if MultiLevelItemCfg and MultiLevelItemCfg.GroupID ~= 0 then
      if not multiStateMarkers[MultiLevelItemCfg.GroupID] then
        normalProcessing(itemId)
        multiStateMarkers[MultiLevelItemCfg.GroupID] = true
      end
    else
      normalProcessing(itemId)
    end
  end
  local upgradeWeaponGroupo = {}
  local weaponProcessing = function(itemId)
    local groupID = ItemUpgradeModule:GetRefitGroupID(itemId)
    if groupID <= 0 then
      normalProcessing(itemId)
      return
    end
    local refitCfg = ItemUpgradeModule:GetRefitCfgData(groupID)
    if refitCfg and refitCfg.refitGroupID then
      groupID = refitCfg.refitGroupID
    end
    if upgradeWeaponGroupo[groupID] then
      return
    end
    if StoreUtils.HasItem(itemId) then
      owned = owned + 1
    end
    if not upgradeWeaponGroupo[groupID] then
      upgradeWeaponGroupo[groupID] = itemId
    end
    total = total + 1
  end
  local upgradeVehicle = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.upgradeVehicle)
  local oldVehicle2GroupKey, oldGroupKey2Vehicles = upgradeVehicle:GetVehicleUpgradeConfig()
  local oldVehicleUpgradeGroup = {}
  local refitVehicleGroup = {}
  local multiLevelVehicleGroup = {}
  local vehicleProcessing = function(itemId)
    if oldVehicle2GroupKey[itemId] then
      local groupID = oldVehicle2GroupKey[itemId]
      if oldVehicleUpgradeGroup[groupID] then
        return
      end
      if oldGroupKey2Vehicles[groupID] then
        for _, ID in ipairs(oldGroupKey2Vehicles[groupID]) do
          if wardrobe_data:CheckHasPermanentItem(ID) then
            owned = owned + 1
            oldVehicleUpgradeGroup[groupID] = ID
            break
          end
        end
      end
      if not oldVehicleUpgradeGroup[groupID] then
        oldVehicleUpgradeGroup[groupID] = itemId
      end
      total = total + 1
      return
    else
      local group = 0
      local carCfg = CDataTable.GetTableData("VehicleRefitInfo", itemId)
      if carCfg then
        group = carCfg.vehicle_group_id
        if refitVehicleGroup[group] then
          return
        end
        local carItemIDS = upgradeVehicle:GetAssociatedCars(itemId)
        for _, v in pairs(carItemIDS) do
          if wardrobe_data:CheckHasPermanentItem(v) then
            refitVehicleGroup[group] = v
            owned = owned + 1
            break
          end
        end
        if not refitVehicleGroup[group] then
          refitVehicleGroup[group] = itemId
        end
        total = total + 1
        return
      else
        local MultiLevelItemCfg = CDataTable.GetTableData("MultiLevelItem", itemId)
        if MultiLevelItemCfg then
          local groupID = MultiLevelItemCfg.GroupID
          if multiLevelVehicleGroup[groupID] then
            return
          end
          local MultiLevelItemGroupCfg = CDataTable.GetTableByFilter("MultiLevelItem", "GroupID", groupID)
          for _, v in pairs(MultiLevelItemGroupCfg) do
            if wardrobe_data:CheckHasPermanentItem(v) then
              multiLevelVehicleGroup[groupID] = v
              owned = owned + 1
              break
            end
          end
          if not multiLevelVehicleGroup[groupID] then
            multiLevelVehicleGroup[groupID] = itemId
          end
          total = total + 1
          return
        end
      end
    end
    normalProcessing(itemId)
  end
  local suitUpgradeGroup = {}
  local suitProcessing = function(itemId)
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local period = LogicXSuit.GetPeriodByItemId(itemId)
    if period then
      if suitUpgradeGroup[period] then
        return
      end
      local groupList = LogicXSuit.GetUpgradeInfo(period)
      if groupList then
        for _, info in ipairs(groupList) do
          if wardrobe_data:CheckHasPermanentItem(info.item_id) then
            owned = owned + 1
            suitUpgradeGroup[period] = info.item_id
            break
          end
        end
      end
      if not suitUpgradeGroup[period] then
        suitUpgradeGroup[period] = itemId
      end
      total = total + 1
    else
      normalProcessing(itemId)
    end
  end
  local LogicFusionModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicFusionModule)
  for _, itemId in pairs(items) do
    local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local cfg = CDataTable.GetTableData("Item", itemId)
    if cfg and not LogicFusionModule:IsFusionTargetItem(itemId) then
      if ModelDisplayTypeHelper.IsWeapon(cfg.ItemType) then
        weaponProcessing(itemId)
      elseif ModelDisplayTypeHelper.IsVehicle(cfg.ItemType) then
        vehicleProcessing(itemId)
      elseif LogicXSuit.IsXSuit(itemId) or logic_suit_dye:IsDyeSuit(itemId) then
        suitProcessing(itemId)
      else
        multiStateProcessing(itemId)
      end
    end
  end
  return owned, total
end
function collect_introduction_module:GetOwnedScoreAndTotalScore(items, isTotle)
  local logic_suit_dye = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_suit_dye)
  local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
  local StoreUtils = require("client.slua.logic.store.utils.store_utils_config")
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local itemInfo = {}
  local insertNewItems = function(itemID, score, bOwned)
    itemInfo[itemID] = {ItemScore = score, Owned = bOwned}
  end
  local totalScore, ownedScore = 0, 0
  local normalProcessing = function(itemId)
    local itemScore = collect_module:GetScoreByItemId(itemId)
    local bOwned = false
    if StoreUtils.HasItem(itemId, 0, 0, true) then
      ownedScore = ownedScore + itemScore
      bOwned = true
    end
    insertNewItems(itemId, itemScore, bOwned)
    totalScore = totalScore + itemScore
  end
  local upgradeWeaponGroupo = {}
  local weaponProcessing = function(itemId)
    local ItemUpgradeModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
    local groupID = 0
    local cfg = ItemUpgradeModule:GetUpgradeCfg(itemId)
    if not cfg then
      normalProcessing(itemId)
      return
    end
    groupID = cfg.GroupID
    if upgradeWeaponGroupo[cfg.GroupID] then
      return
    end
    local upgradeCfgList = ItemUpgradeModule:GetUpgradeGroupByID(groupID)
    if not upgradeCfgList or #upgradeCfgList == 0 then
      normalProcessing(itemId)
      return
    end
    local maxLevel, maxID = 0, 0
    for _, cfg in ipairs(upgradeCfgList) do
      if wardrobe_data:CheckHasPermanentItem(cfg.ItemID) then
        local itemScore = collect_module:GetScoreByItemId(cfg.ItemID)
        ownedScore = ownedScore + itemScore
        upgradeWeaponGroupo[cfg.GroupID] = cfg.ItemID
        insertNewItems(cfg.ItemID, itemScore, true)
      end
      local ItemId = ItemUpgradeModule:GetRefitItemIdByResID(cfg.ItemID)
      if ItemId then
        local itemScore = collect_module:GetScoreByItemId(ItemId)
        ownedScore = ownedScore + itemScore
        upgradeWeaponGroupo[cfg.GroupID] = cfg.ItemID
        insertNewItems(cfg.ItemID, itemScore, true)
      end
      if maxLevel < cfg.Level then
        maxLevel = cfg.Level
        maxID = cfg.ItemID
      end
    end
    if not upgradeWeaponGroupo[cfg.GroupID] then
      local itemScore = collect_module:GetScoreByItemId(itemId)
      upgradeWeaponGroupo[cfg.GroupID] = itemId
      insertNewItems(itemId, itemScore, false)
    end
    local maxScore = collect_module:GetScoreByItemId(maxID)
    totalScore = totalScore + maxScore
  end
  local suitUpgradeGroup = {}
  local suitProcessing = function(itemId)
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local period = LogicXSuit.GetPeriodByItemId(itemId)
    if period and 0 < period then
      if suitUpgradeGroup[period] then
        log(bWriteLog and string.format("suitProcessing"))
        return
      end
      local maxLevel, maxID = 0, 0
      local groupList = LogicXSuit.GetUpgradeInfo(period)
      if groupList then
        for _, info in ipairs(groupList) do
          if wardrobe_data:CheckHasPermanentItem(info.item_id) then
            local itemScore = collect_module:GetScoreByItemId(info.item_id)
            ownedScore = ownedScore + itemScore
            suitUpgradeGroup[period] = info.item_id
            insertNewItems(info.item_id, itemScore, true)
          end
          if maxLevel < info.Level then
            maxLevel = info.Level
            maxID = info.item_id
          end
        end
      end
      if not suitUpgradeGroup[period] then
        local score = collect_module:GetScoreByItemId(itemId)
        suitUpgradeGroup[period] = itemId
        insertNewItems(itemId, score, false)
      end
      local itemScore = collect_module:GetScoreByItemId(maxID)
      totalScore = totalScore + itemScore
    else
      period = logic_suit_dye:GetPeriodBySuitId(itemId)
      if period and 0 < period then
        if suitUpgradeGroup[period] then
          log(bWriteLog and string.format("suitProcessing"))
          return
        end
        local maxLevel, maxID = 0, 0
        local groupList = logic_suit_dye:GetDyeSuitLevels(period)
        if groupList then
          for level, info in ipairs(groupList) do
            if wardrobe_data:CheckHasPermanentItem(info.suitId) then
              local itemScore = collect_module:GetScoreByItemId(info.suitId)
              ownedScore = ownedScore + itemScore
              suitUpgradeGroup[period] = info.suitId
              insertNewItems(info.suitId, itemScore, true)
            end
            if level > maxLevel then
              maxLevel = level
              maxID = info.suitId
            end
          end
        end
        if not suitUpgradeGroup[period] then
          local score = collect_module:GetScoreByItemId(itemId)
          suitUpgradeGroup[period] = itemId
          insertNewItems(itemId, score, false)
        end
        local itemScore = collect_module:GetScoreByItemId(maxID)
        totalScore = totalScore + itemScore
      else
        normalProcessing(itemId)
      end
    end
  end
  local core = function(itemId)
    local Logic_ColorShapeUtils = require("client.slua.logic.wardrobe.Logic_ColorShapeUtils")
    local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
    local cfg = CDataTable.GetTableData("Item", itemId)
    if cfg then
      if ModelDisplayTypeHelper.IsWeapon(cfg.ItemType) then
        weaponProcessing(itemId)
      elseif LogicXSuit.IsXSuit(itemId) or logic_suit_dye:IsDyeSuit(itemId) then
        suitProcessing(itemId)
      elseif Logic_ColorShapeUtils.CheckIsColorShapeItemId(itemId) then
        totalScore, ownedScore = _nCheckColorShapeIsOwned(itemId, totalScore, ownedScore, insertNewItems)
      else
        normalProcessing(itemId)
      end
    end
  end
  for _, data in pairs(items) do
    local itemId = data.ItemId or data.ItemID
    core(itemId or 0)
  end
  return ownedScore, totalScore, itemInfo
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, collect_introduction_module)
return CModuleTemplate