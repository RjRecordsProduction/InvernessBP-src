local treasure_chest_manager = {}
function treasure_chest_manager:DefineAndResetData()
  self.chest_info = {}
end
function treasure_chest_manager:GetChestInfo(market_id)
  if self.chest_info[market_id] ~= nil then
    EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_CHEST_INFO, {
      marketId = market_id,
      info = self.chest_info[market_id].data,
      defaultPreviewItems = self.chest_info[market_id].preview_items
    })
  else
    local StoreHandler = require("client.network.Protocol.StoreHandler")
    StoreHandler.send_get_market_chest_info_req(market_id)
  end
end
function treasure_chest_manager:ResponseChestInfo(res, market_id, data, preview_items)
  if res ~= 0 then
    return
  end
  self.chest_info[market_id] = {data = data, preview_items = preview_items}
  EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_CHEST_INFO, {
    marketId = market_id,
    info = data,
    defaultPreviewItems = preview_items
  })
end
function treasure_chest_manager:ClearChestInfo()
  self.chest_info = {}
end
function treasure_chest_manager:UpdateStoreBoxFinalPrice(ItemData)
  if not (ItemData and ItemData.itemId) or not ItemData.shopId then
    return 0, false
  end
  local discountPrice = ItemData.discountPrice or 0
  local StoreUtils = require("client.slua.logic.store.utils.store_utils")
  if not StoreUtils.CheckIsChest(ItemData.itemId) then
    return discountPrice, false
  end
  if not self.chest_info or not self.chest_info[ItemData.shopId] then
    return discountPrice, false
  end
  local marketInfo = self.chest_info[ItemData.shopId].data or {}
  if not next(marketInfo) then
    return discountPrice, false
  end
  local BoxList = {}
  for i, v in ipairs(marketInfo) do
    BoxList[#BoxList + 1] = self:MakeChestDropInfo(v)
  end
  if self:CheckAllHasOwned(BoxList) then
    return discountPrice, true
  end
  local totalDeduction = StoreUtils.CalcTotalDerateNum(BoxList)
  local finalPrice = math.max(0, ItemData.discountPrice - totalDeduction)
  return finalPrice, false
end
function treasure_chest_manager:CheckAllHasOwned(BoxList)
  if not BoxList or #BoxList < 1 then
    return false
  end
  local isAllOwned = true
  for i, v in ipairs(BoxList) do
    if v.is_owned == false then
      isAllOwned = false
      break
    end
  end
  return isAllOwned
end
function treasure_chest_manager:GetChestAwards(info)
  info = info or {}
  local tempList = {}
  for _, v in ipairs(info) do
    local tItemData = self:MakeChestDropInfo(v)
    if tItemData then
      table.insert(tempList, tItemData)
    end
  end
  table.sort(tempList, function(left, right)
    if left.DropItemSort == right.DropItemSort then
      return left.DropItemID > right.DropItemID
    else
      return left.DropItemSort > right.DropItemSort
    end
  end)
  return tempList
end
function treasure_chest_manager:SetChestAwardsEquips(chestItemList)
  if not chestItemList or not next(chestItemList) then
    return
  end
  local cacheList = {}
  local StoreUtils = require("client.slua.logic.store.utils.store_utils")
  for _, v in ipairs(chestItemList) do
    if not cacheList[v.DropItemID] then
      v.equiped = StoreUtils.IsEquippedByItemId(v.DropItemID)
      cacheList[v.DropItemID] = true
    end
  end
end
function treasure_chest_manager:MakeChestDropInfo(data)
  local StoreUtils = require("client.slua.logic.store.utils.store_utils")
  local dropData = {
    DropItemID = data[StoreConst.label_drop_index_item_id] or 0,
    DropItemNum = data[StoreConst.label_drop_index_item_num] or 0,
    DropRate = data[StoreConst.label_drop_index_chance],
    DropType = data[StoreConst.label_drop_index_type],
    DropWeight = data[StoreConst.label_drop_index_weight] or 0,
    DropItemSort = data[StoreConst.label_drop_index_item_sort] or 0,
    is_limit_time = 0 < data[StoreConst.label_drop_index_item_time],
    item_time_limit = data[StoreConst.label_drop_index_item_time] or 0,
    reducedPrice = data[StoreConst.label_drop_index_return_money],
    is_optional = data[StoreConst.label_drop_index_is_optional]
  }
  local cfg = CDataTable.GetTableData("Item", dropData.DropItemID)
  if cfg == nil then
    log(bWriteLog and string.format("treasure_chest_manager:MakeChestDropInfo  could not found itemId = %s", dropData.DropItemID))
    return nil
  end
  if dropData.is_limit_time == false then
    dropData.is_limit_time, dropData.item_time_limit = StoreUtils.GetValidFlag(cfg.ValidTimes, cfg.ExTime)
  end
  if cfg then
    dropData.specialIconPath = cfg.SpecialIcon
    dropData.type = cfg.ItemType
    dropData.subType = cfg.ItemSubType
    dropData.preview = cfg.Preview
    dropData.showSpecialIcon = cfg.SpecialIcon ~= ""
  end
  dropData.is_hot = false
  dropData.is_new = false
  dropData.equiped = false
  dropData.selected = false
  dropData.is_new = false
  local UIUtil = require("client.common.ui_util")
  dropData.bigIcon = UIUtil.GetItemBigIcon(dropData.DropItemID)
  local ItemMacros = require("client.slua.config.ClientMacros.ItemMacros")
  local Enum_GetTagType = ItemMacros.Enum_GetTagType
  dropData.is_must_drop = dropData.DropRate >= 1
  if dropData.is_must_drop then
    dropData.DropType = Enum_GetTagType.Must
  end
  if dropData.DropType == Enum_GetTagType.Must and dropData.is_optional and dropData.is_optional == 1 then
    dropData.DropType = Enum_GetTagType.SelectBox
  end
  dropData.is_owned = self:CheckIsOwnedOfItem(cfg, dropData)
  return dropData
end
function treasure_chest_manager:CheckIsOwnedOfItem(cfg, data)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  if not cfg then
    return false
  end
  local store_commodity_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_commodity_manager)
  local canHaveType = store_commodity_manager:CheckAlreadyOwnByType(cfg.ItemType, cfg.ItemSubType, data.DropItemID)
  local isHave = wardrobe_data:GetHallDepotItemDataByResID(data.DropItemID) ~= nil or logic_pet:HasPetPermanently(data.DropItemID) or logic_pet:HasPetDressPermanently(data.DropItemID)
  if canHaveType and data.is_must_drop == true and not data.is_limit_time and isHave then
    return true
  end
  return false
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, treasure_chest_manager)
return CModuleTemplate