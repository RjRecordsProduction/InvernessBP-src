local local local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
local StoreUtils = require("client.slua.logic.store.utils.store_utils_config")
function StoreUtils.CheckIsChest(itemID)
  local itemCfg = CDataTable.GetTableData("Item", itemID)
  if itemCfg ~= nil then
    return itemCfg.ItemType == ENUM_ITEM_TYPE.Starter_Pack and itemCfg.ItemSubType == 1503
  end
  return false
end
function StoreUtils.CheckIsSupplyChest(itemID)
  local itemCfg = CDataTable.GetTableData("Item", itemID)
  if itemCfg ~= nil then
    return itemCfg.ItemType == ENUM_ITEM_TYPE.Starter_Pack and itemCfg.ItemSubType == 1501
  end
  return false
end
function StoreUtils.IsWeapon(itemID)
  local itemCfg = CDataTable.GetTableData("Item", itemID)
  if itemCfg ~= nil then
    return itemCfg.ItemType == 1
  end
  return false
end
function StoreUtils.IsVoidCard(itemID)
  local itemCfg = CDataTable.GetTableData("Item", itemID)
  if itemCfg ~= nil then
    return itemCfg.ItemType == ENUM_ITEM_TYPE.Voice_Pack
  end
  return false
end
function StoreUtils.IsVoid(itemID)
  local itemCfg = CDataTable.GetTableData("Item", itemID)
  if itemCfg ~= nil then
    return itemCfg.ItemType == ENUM_ITEM_TYPE.Victor_Speech
  end
  return false
end
function StoreUtils.IsPetItemID(itemID)
  local itemCfg = CDataTable.GetTableData("Item", itemID)
  if itemCfg ~= nil then
    return itemCfg.ItemType == 500
  end
  return false
end
function StoreUtils.IsPetDressItemID(itemID)
  local itemCfg = CDataTable.GetTableData("Item", itemID)
  if itemCfg ~= nil then
    return itemCfg.ItemType == 501
  end
  return false
end
function StoreUtils.CalcTotalDerateNum(BoxList)
  if not BoxList then
    return 0
  end
  local totalDerateNum = 0
  for i, dropData in ipairs(BoxList) do
    if dropData.is_owned then
      if StoreUtils.IsPetItemID(dropData.DropItemID) then
        totalDerateNum = totalDerateNum + dropData.reducedPrice
      else
        local itemList = wardrobe_data:GetHallDepotItemListByResID(dropData.DropItemID)
        for j, item in ipairs(itemList) do
          if item.expireTS == nil or item.expireTS == 0 then
            totalDerateNum = totalDerateNum + dropData.reducedPrice
          end
        end
      end
    end
  end
  return totalDerateNum
end
function StoreUtils.HasItem(itemId, colorID, patternID, detectionLevel)
  colorID = colorID or 0
  patternID = patternID or 0
  local ItemList = wardrobe_data:GetHallDepotItemListByResID(itemId)
  for i, v in pairs(ItemList) do
    if v.resID ~= itemId or v.colorID ~= nil and v.colorID ~= colorID or v.patternID ~= nil and v.patternID ~= patternID or v.validHours ~= nil and 0 < v.validHours then
    else
      return true
    end
  end
  local logic_suit_dye = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_suit_dye)
  local cfg = CDataTable.GetTableData("Item", itemId)
  if cfg then
    local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
    if cfg.ItemType == ENUM_ITEM_TYPE.HeadBorder then
      return StoreUtils.HasAvatarFrame(itemId)
    elseif cfg.ItemType == ENUM_ITEM_TYPE.HeadIcon then
      return StoreUtils.HasHeadPortrait(itemId)
    elseif StoreUtils.IsPetItemID(itemId) or StoreUtils.IsPetDressItemID(itemId) then
      local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
      return logic_pet:HasPetPermanently(itemId) or logic_pet:HasPetDressPermanently(itemId)
    elseif cfg.ItemType == ENUM_ITEM_TYPE.Victor_Speech then
      local ActorVoiceSystem = require("client.slua.logic.actor_voice.logic_actor_voice")
      if ActorVoiceSystem.CheckIsVoiceUnLock(cfg.itemSubType) then
        local isPermanent = ActorVoiceSystem.GetExpireDataByItemId(itemId)
        if isPermanent then
          return true
        end
      end
    elseif cfg.ItemType == ENUM_ITEM_TYPE.Voice_Pack then
      local ActorVoiceSystem = require("client.slua.logic.actor_voice.logic_actor_voice")
      if ActorVoiceSystem.CheckIsActorValidByItemID(itemId) then
        local isPermanent = ActorVoiceSystem.GetExpireDataByItemId(itemId)
        if isPermanent then
          return true
        end
      end
    elseif cfg.ItemType == ENUM_ITEM_TYPE.Extra and (cfg.ItemSubType == 400 or cfg.ItemSubType == 408 or cfg.ItemSubType == 406) then
      return DataMgr.HasAvatarById(itemId)
    elseif ModelDisplayTypeHelper.IsWeapon(cfg.ItemType) and not detectionLevel then
      local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
      return ItemUpgradeMgr:CheckHasSameGroupItemAndRefitItemWithTime(itemId, false)
    elseif ModelDisplayTypeHelper.IsVehicle(cfg.ItemType) then
      return StoreUtils.CheckHaveSameGroupVehicle(itemId)
    elseif LogicXSuit.IsXSuit(itemId) and not detectionLevel then
      return LogicXSuit.CheckHasSameGroupItem(itemId)
    elseif logic_suit_dye:IsDyeSuit(itemId) and not detectionLevel then
      return logic_suit_dye:CheckHasSameGroupItem(itemId)
    elseif cfg.itemSubType == ENUM_ITEM_SUBTYPE.Friend_Circle_Bg then
      local logic_moment_background = require("client.slua.logic.moment.logic_moment_background")
      local itemInfo = logic_moment_background.GetItemInfo(itemId)
      if itemInfo or itemId == logic_moment_background.defaultBgId then
        return true
      end
    elseif cfg.ItemType == ENUM_ITEM_TYPE.Medicine then
      local ItemUpGradeHandler = require("client.network.Protocol.ItemUpGradeHandler")
      return ItemUpGradeHandler.HasItem(itemId)
    elseif cfg.ItemType == ENUM_ITEM_TYPE.VehicleAccessory then
      local LogicVehicleAccessory = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicVehicleAccessory)
      return LogicVehicleAccessory:CheckHasGetAccessoryItem(itemId)
    elseif ModelDisplayTypeHelper.IsVehiclePartDisplay(cfg.ItemType, cfg.ItemSubType) then
      local LogicVehicleExtendedFeature = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicVehicleExtendedFeature)
      return LogicVehicleExtendedFeature:CheckHasGetFeatureItem(itemId)
    end
  end
  return false
end
function StoreUtils.HasAvatarFrame(itemId)
  local RoleInfoAvatarFrameSystem = require("client.slua.logic.roleInfo.logic_RoleInfoAvatarFrame")
  if RoleInfoAvatarFrameSystem.HasAvatarFrame(itemId) == true then
    return true
  end
  return false
end
function StoreUtils.HasHeadPortrait(itemId)
  local RoleInfoAvatarSystem = require("client.slua.logic.roleInfo.logic_roleInfo_Avatar")
  if RoleInfoAvatarSystem.HasOwnHeadPortrait(itemId) == true then
    return true
  end
  return false
end
function StoreUtils.CheckHaveSameGroupVehicle(itemId)
  local vehicleUpgradeConfig = {}
  local temp = {}
  local upgradeCfgs = CDataTable.GetTable("VehicleUpgradeConfig")
  for id, cfg in pairs(upgradeCfgs) do
    local groupKey = cfg.ActivityID .. cfg.Series
    if temp[groupKey] == nil then
      temp[groupKey] = {}
    end
    table.insert(temp[groupKey], cfg.ItemID)
    if vehicleUpgradeConfig[cfg.ItemID] == nil then
      vehicleUpgradeConfig[cfg.ItemID] = temp[groupKey]
    end
  end
  local series = vehicleUpgradeConfig[itemId]
  if series ~= nil then
    for k, v in pairs(series) do
      if wardrobe_data:GetHallDepotItemDataByResID(v) ~= nil then
        return true, v
      end
    end
  end
  local upgradeVehicle = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.upgradeVehicle)
  local carItemIDS = upgradeVehicle:GetAssociatedCars(itemId)
  if carItemIDS then
    for _, v in pairs(carItemIDS) do
      if wardrobe_data:GetHallDepotItemDataByResID(v) ~= nil then
        return true, v
      end
    end
  end
  local LogicMultiItemModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicMultiItemModule)
  if LogicMultiItemModule:IsUpgradeItem(itemId) then
    local Num = LogicMultiItemModule:GetMultiItemNumForever(itemId)
    return 0 < Num
  end
  return false
end
function StoreUtils.IsTreasuresAndSpecialChests(type, subType)
  if type == ENUM_ITEM_TYPE.Starter_Pack and subType == ENUM_ITEM_SUBTYPE.Treasure_Box then
    return true
  end
  return false
end
function StoreUtils.IsSelectChestBox(type, subType)
  if type == ENUM_ITEM_TYPE.Starter_Pack and subType == ENUM_ITEM_SUBTYPE.CustomSelectChest then
    return true
  end
  return false
end
function StoreUtils.IsWithCount(itemType, subType)
  local IsWithCount = true
  local typeCfg = CDataTable.GetTableByFilter("ItemIsWithCount", "ItemType", itemType)
  for type, cfg in pairs(typeCfg or {}) do
    if cfg.IsWithCount == 0 and (cfg.ItemSubType == 0 or cfg.ItemSubType == subType) then
      IsWithCount = false
      break
    elseif cfg.IsWithCount == 1 then
      if cfg.ItemSubType == 0 or cfg.ItemSubType == subType then
        IsWithCount = true
        break
      end
      IsWithCount = false
    end
  end
  return IsWithCount
end
function StoreUtils.IsParachuteItemID(itemID)
  local itemCfg = CDataTable.GetTableData("Item", itemID)
  if itemCfg ~= nil then
    return itemCfg.ItemType == ENUM_ITEM_TYPE.Extra and itemCfg.ItemSubType == 701
  end
  return false
end
function StoreUtils.IsBetterVehicle(itemID)
  local BetterVehicleEffect = CDataTable.GetTableData("BetterVehicleEffect", itemID)
  if BetterVehicleEffect then
    return true
  end
  return false
end
function StoreUtils.GetSkinIDByLevelID(itemID)
  local BackpackMapping = CDataTable.GetTableDataByFilter("BackpackMapping", "SkinItemIDLv1", itemID)
  BackpackMapping = BackpackMapping or CDataTable.GetTableDataByFilter("BackpackMapping", "SkinItemIDLv2", itemID)
  BackpackMapping = BackpackMapping or CDataTable.GetTableDataByFilter("BackpackMapping", "SkinItemIDLv3", itemID)
  if BackpackMapping and BackpackMapping.SkinID > 0 then
    itemID = BackpackMapping.SkinID
  end
  return itemID
end