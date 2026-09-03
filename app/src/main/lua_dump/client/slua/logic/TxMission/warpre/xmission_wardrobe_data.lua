local xMission_Wardrobe_Data = {}
local WardrobeItemList = {}
local WardrobeItemTable = {}
local Size = 0
local Capacity = 0
local super_data = require("common.super_data")
local currentPageData = super_data.CreateSuperData({pageId = -1})
function xMission_Wardrobe_Data.AddItem(inst_id, item, dst_desc, dst_slot, dst_inst_id)
  local xMission_macro = require("client.slua.umg.TxMission.xMission.xmission_macro")
  if dst_desc == xMission_macro.Enum_Dst_Desc.EnumDst_PartSlot then
    xMission_Wardrobe_Data.AddPartSlotItem(dst_inst_id, dst_slot, item)
  elseif dst_desc == xMission_macro.Enum_Dst_Desc.EnumDst_Depot then
    item.    xMission_Wardrobe_Data.AddWardrobeItemListItem(item)
    EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_WARDROBE_DATA_CHANGE, item)
  end
end
function xMission_Wardrobe_Data.RemoveItemByInstID(inst_id)
  xMission_Wardrobe_Data.RemoveWardrobeItemListItem(inst_id)
  xMission_Wardrobe_Data.RemoveWardrobeItemTableItem(inst_id)
end
function xMission_Wardrobe_Data.Destroy()
  WardrobeItemList = {}
  WardrobeItemTable = {}
  Size = 0
  Capacity = 0
end
function xMission_Wardrobe_Data.InitData(metro, depot_capacity)
  xMission_Wardrobe_Data.Destroy()
  if metro and metro.depot then
    xMission_Wardrobe_Data.SetWardrobeCapacity(depot_capacity)
    if metro.depot.items and next(metro.depot.items) then
      for k, v in pairs(metro.depot.items) do
        v.inst_id = k
        table.insert(WardrobeItemList, v)
        xMission_Wardrobe_Data.AddWardrobeItemTableItem(v)
      end
      xMission_Wardrobe_Data.CalculateWardrobeSize()
      EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_WARDROBE_DATA_INIT, metro.depot.items)
    end
  end
end
function xMission_Wardrobe_Data.AddWardrobeItemListItem(item)
  local exist = false
  if WardrobeItemList and 0 < #WardrobeItemList then
    for i, v in pairs(WardrobeItemList) do
      if v and v.inst_id == item.inst_id then
        WardrobeItemList[i] = item
        exist = true
        break
      end
    end
  end
  if not exist then
    table.insert(WardrobeItemList, item)
  end
  xMission_Wardrobe_Data.AddWardrobeItemTableItem(item)
  xMission_Wardrobe_Data.CalculateWardrobeSize()
end
function xMission_Wardrobe_Data.AddPartSlotItem(dst_inst_id, dst_slot, item)
  local weaponInfo = xMission_Wardrobe_Data.GetItemByInstID(dst_inst_id)
  weaponInfo.slots = weaponInfo.slots or {}
  weaponInfo.slots[dst_slot] = item
  xMission_Wardrobe_Data.AddWardrobeItemTableItem(item)
end
function xMission_Wardrobe_Data.RemoveWardrobeItemListItem(inst_id)
  if WardrobeItemList and next(WardrobeItemList) then
    for i, v in pairs(WardrobeItemList) do
      if v and v.inst_id == inst_id then
        table.remove(WardrobeItemList, i)
        xMission_Wardrobe_Data.CalculateWardrobeSize()
        v.new = false
        EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_WARDROBE_DATA_CHANGE, v)
        break
      elseif v and v.slots and next(v.slots) then
        for kk, vv in pairs(v.slots) do
          if vv.inst_id == inst_id then
            v.slots[kk] = nil
            return
          end
        end
      end
    end
  end
end
function xMission_Wardrobe_Data.GetItemList()
  return WardrobeItemList
end
function xMission_Wardrobe_Data.GetWardrobeCapacity()
  return Capacity
end
function xMission_Wardrobe_Data.SetWardrobeCapacity(value)
  Capacity = value
end
function xMission_Wardrobe_Data.on_metro_depot_capacity_notify(after)
  log(bWriteLog and "on_metro_depot_capacity_notify after:" .. tostring(after))
  xMission_Wardrobe_Data.SetWardrobeCapacity(after)
  EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_CHANGE_WARDROBE_CAPACITY)
end
function xMission_Wardrobe_Data.GetWardrobeSize()
  return Size
end
function xMission_Wardrobe_Data.SetWardrobeSize(nSize)
  Size = nSize
end
function xMission_Wardrobe_Data.GetPartSlotInfo(inst_id, part_slot)
  if WardrobeItemList and next(WardrobeItemList) then
    for k, v in pairs(WardrobeItemList) do
      if v and inst_id == v.inst_id and v.slots and next(v.slots) then
        return v.slots[part_slot]
      end
    end
  end
  return nil
end
function xMission_Wardrobe_Data.IsItemEquiped(inst_id, weapon_inst_id)
  if WardrobeItemList and next(WardrobeItemList) then
    for _, v in pairs(WardrobeItemList) do
      if v and v.slots and next(v.slots) then
        for _, vv in pairs(v.slots) do
          if inst_id == vv.inst_id and (not weapon_inst_id or weapon_inst_id and weapon_inst_id == v.inst_id) then
            return true
          end
        end
      end
    end
  end
  return false
end
function xMission_Wardrobe_Data.CalculateWardrobeSize()
  log(bWriteLog and "xMission_Wardrobe_Data.CalculateWardrobeSize:" .. tostring(#WardrobeItemList))
  xMission_Wardrobe_Data.SetWardrobeSize(#WardrobeItemList)
end
function xMission_Wardrobe_Data.IsInWardrobeByInstID(inst_id)
  inst_id = tonumber(inst_id)
  if WardrobeItemList and next(WardrobeItemList) then
    for _, v in pairs(WardrobeItemList) do
      if v and v.inst_id == inst_id then
        return true
      end
    end
  end
  return false
end
function xMission_Wardrobe_Data.IsInWardrobeByItemID(item_id)
  if WardrobeItemList and next(WardrobeItemList) then
    for _, v in pairs(WardrobeItemList) do
      if v and v.item_id == item_id then
        return true
      end
    end
  end
  return false
end
local _HaveItemByType = function(itemType)
  if WardrobeItemList and next(WardrobeItemList) then
    for k, v in pairs(WardrobeItemList) do
      local cfg = xMission_Wardrobe_Data.FastGetItemData(v and v.item_id)
      if cfg and cfg.ItemType == itemType then
        return true
      end
    end
  end
  return false
end
local _HaveItemByTypeAndSubType = function(itemType, itemSubType)
  if WardrobeItemList and next(WardrobeItemList) then
    for k, v in pairs(WardrobeItemList) do
      local cfg = xMission_Wardrobe_Data.FastGetItemData(v and v.item_id)
      if cfg and cfg.ItemType == itemType and cfg.ItemSubType == itemSubType then
        return true
      end
    end
  end
  return false
end
function xMission_Wardrobe_Data.HaveWeapon()
  local xMission_macro = require("client.slua.umg.TxMission.xMission.xmission_macro")
  local enum = xMission_macro.Enum_Type
  return _HaveItemByType(enum.EnumType_Main_Weapon)
end
function xMission_Wardrobe_Data.HaveBullet(weaponID)
  local LogicTxMissionMatch = require("client.slua.logic.TxMission.match.logic_xmission_match")
  local bulletList, originBulletID = LogicTxMissionMatch.GetBulletListByWeaponID(weaponID)
  local num = 0
  if bulletList and 0 < #bulletList then
    for k, v in pairs(bulletList) do
      num = num + xMission_Wardrobe_Data.GetItemNumByItemId(v)
    end
  end
  return 0 < num, originBulletID, bulletList[1]
end
function xMission_Wardrobe_Data.HaveDrug()
  local xMission_macro = require("client.slua.umg.TxMission.xMission.xmission_macro")
  local enum = xMission_macro.Enum_Sub_Type
  if WardrobeItemList and next(WardrobeItemList) then
    for k, v in pairs(WardrobeItemList) do
      local cfg = xMission_Wardrobe_Data.FastGetItemData(v.item_id)
      if cfg and cfg.ItemSubType == enum.EnumType_Sub_Drug then
        return true
      end
    end
  end
  return false
end
function xMission_Wardrobe_Data.HaveHelmet()
  local xMission_macro = require("client.slua.umg.TxMission.xMission.xmission_macro")
  local enum = xMission_macro.Enum_Type
  return _HaveItemByType(enum.EnumType_Helmet)
end
function xMission_Wardrobe_Data.HaveArmor()
  local xMission_macro = require("client.slua.umg.TxMission.xMission.xmission_macro")
  local enum = xMission_macro.Enum_Type
  return _HaveItemByType(enum.EnumType_Armor)
end
function xMission_Wardrobe_Data.HaveResearchChest()
  local xMission_macro = require("client.slua.umg.TxMission.xMission.xmission_macro")
  return _HaveItemByTypeAndSubType(xMission_macro.Enum_Type.EnumType_Other, xMission_macro.Enum_Sub_Type.EnumType_Sub_ResearchChest)
end
function xMission_Wardrobe_Data.HaveSouvenirDropItem()
  local xMission_macro = require("client.slua.umg.TxMission.xMission.xmission_macro")
  return _HaveItemByTypeAndSubType(xMission_macro.Enum_Type.EnumType_Other, xMission_macro.Enum_Sub_Type.EnumType_Sub_Souvenirs_Drop)
end
function xMission_Wardrobe_Data.HaveAffixsItem()
  if WardrobeItemList and next(WardrobeItemList) then
    for k, v in pairs(WardrobeItemList) do
      if v.affixs and next(v.affixs) then
        return true
      end
    end
  end
  return false
end
function xMission_Wardrobe_Data.AddWardrobeItemTableItem(item)
  WardrobeItemTable[item.inst_id] = item
  if item.slots and next(item.slots) then
    for _, vv in pairs(item.slots) do
      WardrobeItemTable[vv.inst_id] = vv
    end
  end
end
function xMission_Wardrobe_Data.RemoveWardrobeItemTableItem(inst_id)
  if WardrobeItemTable and WardrobeItemTable[inst_id] then
    local v = WardrobeItemTable[inst_id]
    if v.slots and next(v.slots) then
      for _, vv in pairs(v.slots) do
        WardrobeItemTable[vv.inst_id] = nil
      end
    end
    WardrobeItemTable[inst_id] = nil
  end
end
function xMission_Wardrobe_Data.GetItemNumByItemId(itemId)
  local count = 0
  for _, v in ipairs(WardrobeItemList) do
    if v.item_id == itemId then
      count = count + tonumber(v.item_num)
    end
  end
  return count
end
function xMission_Wardrobe_Data.GetItemNumByItemIdAndAffix(itemId, haveAffix)
  local count = 0
  haveAffix = haveAffix or false
  for _, v in pairs(WardrobeItemTable) do
    local bHaveAffix = false
    if v.affixs then
      bHaveAffix = true
    end
    if v.item_id == itemId and bHaveAffix == haveAffix then
      count = count + tonumber(v.item_num)
    end
  end
  log(bWriteLog and "xMission_Wardrobe_Data.GetItemNumByItemIdAndAffix.itemId" .. tostring(itemId) .. "haveAffix" .. tostring(haveAffix))
  return count
end
function xMission_Wardrobe_Data.GetItemByInstID(inst_id)
  inst_id = tonumber(inst_id)
  if WardrobeItemTable and WardrobeItemTable[inst_id] then
    return WardrobeItemTable[inst_id]
  end
  return nil
end
function xMission_Wardrobe_Data.GetItemByItemID(itemId)
  for _, v in pairs(WardrobeItemTable) do
    if v.item_id == itemId then
      return v
    end
  end
  return nil
end
function xMission_Wardrobe_Data.GetItemListByItemID(itemId)
  local tItemList = {}
  for _, v in pairs(WardrobeItemTable) do
    if v.item_id == itemId then
      table.insert(tItemList, v)
    end
  end
  return tItemList
end
function xMission_Wardrobe_Data.GetItemListByFilter(filterFunc)
  if not filterFunc then
    return WardrobeItemList
  end
  local tItemList = {}
  for _, v in pairs(WardrobeItemTable) do
    if filterFunc(v) then
      table.insert(tItemList, v)
    end
  end
  return tItemList
end
local onCmpData = function(itemInfoA, itemInfoB)
  if itemInfoA.insured ~= itemInfoB.insured then
    return itemInfoA.insured
  end
  if itemInfoA.new ~= itemInfoB.new then
    return itemInfoA.new
  end
  local xMissionItemCfgA = xMission_Wardrobe_Data.FastGetItemData(itemInfoA.item_id)
  local xMissionItemCfgB = xMission_Wardrobe_Data.FastGetItemData(itemInfoB.item_id)
  if not xMissionItemCfgA or not xMissionItemCfgB then
    return false
  end
  if xMissionItemCfgA.WardrobeTab ~= xMissionItemCfgB.WardrobeTab then
    return xMissionItemCfgA.WardrobeTab < xMissionItemCfgB.WardrobeTab
  end
  local logic_xmission_warpre = require("client.slua.logic.TxMission.warpre.logic_xmission_warpre")
  local pveAffixCountA = logic_xmission_warpre.GetItemPVEAffixCount(itemInfoA.inst_id)
  local pveAffixCountB = logic_xmission_warpre.GetItemPVEAffixCount(itemInfoB.inst_id)
  if pveAffixCountA ~= pveAffixCountB then
    return pveAffixCountA > pveAffixCountB
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemCfgA = CDataTable.GetTableData("Item", itemInfoA.item_id)
  local itemCfgB = CDataTable.GetTableData("Item", itemInfoB.item_id)
  if not itemCfgA or not itemCfgB then
    return false
  end
  if itemCfgA.ItemQuality ~= itemCfgB.ItemQuality then
    return itemCfgA.ItemQuality > itemCfgB.ItemQuality
  end
  local affixCountA = logic_xmission_warpre.GetItemAffixCount(itemInfoA.inst_id)
  local affixCountB = logic_xmission_warpre.GetItemAffixCount(itemInfoB.inst_id)
  if affixCountA ~= affixCountB then
    return affixCountA > affixCountB
  end
  if xMissionItemCfgA.SellPrice ~= xMissionItemCfgB.SellPrice then
    return xMissionItemCfgA.SellPrice > xMissionItemCfgB.SellPrice
  end
  if xMissionItemCfgA.ItemType ~= xMissionItemCfgB.ItemType then
    return xMissionItemCfgA.ItemType < xMissionItemCfgB.ItemType
  end
  local xMission_macro = require("client.slua.umg.TxMission.xMission.xmission_macro")
  if xMissionItemCfgA.ItemSubType == xMissionItemCfgB.ItemSubType and xMissionItemCfgA.ItemSubType == xMission_macro.Enum_Sub_Type.EnumType_Sub_Bullet then
    return itemInfoA.item_id > itemInfoB.item_id
  end
  return xMissionItemCfgA.ItemSubType < xMissionItemCfgB.ItemSubType
end
local SortWardrobeByDefault = function(itemList)
  if itemList and 0 < #itemList then
    table.sort(itemList, onCmpData)
  end
end
local SortWardrobeByPrepareConfig = function(itemList, inst_id)
  if itemList and 0 < #itemList then
    local logic_xmission_warpre = require("client.slua.logic.TxMission.warpre.logic_xmission_warpre")
    if 1 < #itemList then
      local cmp = function(itemInfoA, itemInfoB)
        local canA = logic_xmission_warpre.CanPutOnPart(inst_id, itemInfoA.inst_id)
        local canB = logic_xmission_warpre.CanPutOnPart(inst_id, itemInfoB.inst_id)
        xMission_Wardrobe_Data.SetCanUse(itemInfoA, canA)
        xMission_Wardrobe_Data.SetCanUse(itemInfoB, canB)
        if canA ~= canB then
          return canA
        end
        return onCmpData(itemInfoA, itemInfoB)
      end
      table.sort(itemList, cmp)
    else
      do
        local itemInfo = itemList[1]
        local can = logic_xmission_warpre.CanPutOnPart(inst_id, itemInfo.inst_id)
        xMission_Wardrobe_Data.SetCanUse(itemInfo, can)
      end
    end
  end
end
local SortWardrobeByCanIntoBag = function(itemList)
  if itemList and 0 < #itemList then
    if 1 < #itemList then
      local cmp = function(itemInfoA, itemInfoB)
        local xMissionItemCfgA = xMission_Wardrobe_Data.FastGetItemData(itemInfoA.item_id)
        local xMissionItemCfgB = xMission_Wardrobe_Data.FastGetItemData(itemInfoB.item_id)
        if xMissionItemCfgA and xMissionItemCfgB then
          xMission_Wardrobe_Data.SetCanUse(itemInfoA, xMissionItemCfgA.CanIntoBag and xMissionItemCfgA.CanIntoBag == 1)
          xMission_Wardrobe_Data.SetCanUse(itemInfoB, xMissionItemCfgB.CanIntoBag and xMissionItemCfgB.CanIntoBag == 1)
          if xMissionItemCfgA.CanIntoBag ~= xMissionItemCfgB.CanIntoBag then
            return xMissionItemCfgA.CanIntoBag and xMissionItemCfgA.CanIntoBag == 1
          end
        end
        return onCmpData(itemInfoA, itemInfoB)
      end
      table.sort(itemList, cmp)
    else
      local itemInfo = itemList[1]
      local xMissionItemCfg = xMission_Wardrobe_Data.FastGetItemData(itemInfo.item_id)
      if xMissionItemCfg then
        xMission_Wardrobe_Data.SetCanUse(itemInfo, xMissionItemCfg.CanIntoBag and xMissionItemCfg.CanIntoBag == 1)
      else
        xMission_Wardrobe_Data.SetCanUse(itemInfo, false)
      end
    end
  end
end
local SortWardrobeByPrepareSlotId = function(itemList, slotId)
  if itemList and 0 < #itemList then
    local logic_xmission_warpre = require("client.slua.logic.TxMission.warpre.logic_xmission_warpre")
    if 1 < #itemList then
      local cmp = function(itemInfoA, itemInfoB)
        local canA = logic_xmission_warpre.CanPutIntoPrepareSlot(itemInfoA.item_id, slotId)
        local canB = logic_xmission_warpre.CanPutIntoPrepareSlot(itemInfoB.item_id, slotId)
        xMission_Wardrobe_Data.SetCanUse(itemInfoA, canA)
        xMission_Wardrobe_Data.SetCanUse(itemInfoB, canB)
        if canA ~= canB then
          return canA
        end
        return onCmpData(itemInfoA, itemInfoB)
      end
      table.sort(itemList, cmp)
    else
      do
        local itemInfo = itemList[1]
        local can = logic_xmission_warpre.CanPutIntoPrepareSlot(itemInfo.item_id, slotId)
        xMission_Wardrobe_Data.SetCanUse(itemInfo, can)
      end
    end
  end
end
local SortWardrobeByWeaponSlotIdx = function(itemList, tbParam)
  if itemList and 0 < #itemList then
    local logic_xmission_warpre = require("client.slua.logic.TxMission.warpre.logic_xmission_warpre")
    if 1 < #itemList then
      local cmp = function(itemInfoA, itemInfoB)
        local indexA = logic_xmission_warpre.GetPartEquipIdxByInstID(tbParam.weapon_id, itemInfoA.inst_id)
        local indexB = logic_xmission_warpre.GetPartEquipIdxByInstID(tbParam.weapon_id, itemInfoB.inst_id)
        local canA = indexA == tbParam.slot_id
        local canB = indexB == tbParam.slot_id
        xMission_Wardrobe_Data.SetCanUse(itemInfoA, canA)
        xMission_Wardrobe_Data.SetCanUse(itemInfoB, canB)
        if canA ~= canB then
          return canA
        end
        return onCmpData(itemInfoA, itemInfoB)
      end
      table.sort(itemList, cmp)
    else
      do
        local itemInfo = itemList[1]
        local idx = logic_xmission_warpre.GetPartEquipIdxByInstID(tbParam.weapon_id, itemInfo.inst_id)
        xMission_Wardrobe_Data.SetCanUse(itemInfo, idx == tbParam.slot_id)
      end
    end
  end
end
function xMission_Wardrobe_Data.SortWardrobeList(itemList, sort_type, param)
  local xMission_macro = require("client.slua.umg.TxMission.xMission.xmission_macro")
  if sort_type == xMission_macro.ENUM_WARDROBE_SORT_TYPE.SORT_BY_DEFAULT then
    SortWardrobeByDefault(itemList)
  elseif sort_type == xMission_macro.ENUM_WARDROBE_SORT_TYPE.SORT_BY_PREPARE_CONFIG then
    SortWardrobeByPrepareConfig(itemList, param)
  elseif sort_type == xMission_macro.ENUM_WARDROBE_SORT_TYPE.SORT_BY_CAN_INTO_BAG then
    SortWardrobeByCanIntoBag(itemList)
  elseif sort_type == xMission_macro.ENUM_WARDROBE_SORT_TYPE.SORT_BY_PREPARE_SLOT_ID then
    SortWardrobeByPrepareSlotId(itemList, param)
  elseif sort_type == xMission_macro.ENUM_WARDROBE_SORT_TYPE.SORT_BY_WEAPON_SLOT_INDEX then
    SortWardrobeByWeaponSlotIdx(itemList, param)
  end
end
function xMission_Wardrobe_Data.SetCanUse(itemInfo, canUse)
  itemInfo.end
function xMission_Wardrobe_Data.FastGetItemData(item_id)
  return CDataTable.GetTableData("TxMissionItem", item_id)
end
function xMission_Wardrobe_Data.GetCurrentPageData()
  return currentPageData
end
function xMission_Wardrobe_Data.SetCurrentPageId(pageId)
  currentPageData.end
function xMission_Wardrobe_Data.IsNearWeapon(item_id)
  local itemCfg = xMission_Wardrobe_Data.FastGetItemData(item_id)
  if itemCfg then
    return itemCfg.ItemType == 3
  end
  return false
end
function xMission_Wardrobe_Data.IsOptionChest(item_id)
  local xMission_macro = require("client.slua.umg.TxMission.xMission.xmission_macro")
  local itemCfg = xMission_Wardrobe_Data.FastGetItemData(item_id)
  if itemCfg and itemCfg.ItemType == xMission_macro.Enum_Type.EnumType_Chest and itemCfg.ItemSubType == xMission_macro.Enum_Sub_Type.EnumType_Sub_Option_Chest then
    return true
  else
    return false
  end
end
function xMission_Wardrobe_Data.GetCurUndercoverCapacity()
  local logic_xmission_match = require("client.slua.logic.TxMission.match.logic_xmission_match")
  local sel_model = modeID and modeID or logic_xmission_match.GetSelModel()
  log(bWriteLog and string.format("Xmission_Operations_Area_UIBP, sel_model:%s", sel_model))
  if sel_model == 0 then
    return 0
  end
  local modeInfo = CDataTable.GetTableData("TxMissionMapMode", sel_model)
  if not modeInfo then
    log(bWriteLog and "LogicTxMissionMatch.JustifyModForTeamNum data return")
    return 0
  end
  local UndercoverCapacity = modeInfo.UndercoverCapacity
  return UndercoverCapacity
end
function xMission_Wardrobe_Data.CheckUndercoverCapacity(modeID, isShowTips)
  local logic_xmission_match = require("client.slua.logic.TxMission.match.logic_xmission_match")
  local sel_model = modeID and modeID or logic_xmission_match.GetSelModel()
  log(bWriteLog and string.format("xMission_Wardrobe_Data.CheckUndercoverCapacity, sel_model:%s", sel_model))
  if sel_model == 0 then
    return false
  end
  local modeInfo = CDataTable.GetTableData("TxMissionMapMode", sel_model)
  if not modeInfo then
    log(bWriteLog and "xMission_Wardrobe_Data.CheckUndercoverCapacity data return")
    return false
  end
  local UndercoverCapacity = modeInfo.UndercoverCapacity
  if 0 < UndercoverCapacity then
    log(bWriteLog and string.format("xMission_Wardrobe_Data.CheckUndercoverCapacity, UndercoverCapacity:%s", UndercoverCapacity))
    local xmission_wardrobe_data = require("client.slua.logic.TxMission.warpre.xmission_wardrobe_data")
    local size = xmission_wardrobe_data.GetWardrobeSize()
    local capacity = xmission_wardrobe_data.GetWardrobeCapacity()
    local remain = capacity - size
    if UndercoverCapacity > remain then
      if isShowTips then
        local text = LocUtil.LocalizeResFormat(66682, UndercoverCapacity)
        ShowNotice(text)
      end
      return false
    end
  end
  return true
end
function xMission_Wardrobe_Data.IsTOptionChest(itemID)
  local xMission_macro = require("client.slua.umg.TxMission.xMission.xmission_macro")
  local itemCfg = xMission_Wardrobe_Data.FastGetItemData(itemID)
  if itemCfg and itemCfg.ItemType == xMission_macro.Enum_Type.EnumType_Chest and itemCfg.ItemSubType == xMission_macro.Enum_Sub_Type.EnumType_Sub_Option_Chest then
    return true
  end
  return false
end
function xMission_Wardrobe_Data.OpenTChest(instID)
  local logic_xmission_warpre = require("client.slua.logic.TxMission.warpre.logic_xmission_warpre")
  local itemInfo = logic_xmission_warpre.GetItemByInstID(instID)
  if itemInfo then
    local xMission_macro = require("client.slua.umg.TxMission.xMission.xmission_macro")
    local itemCfg = xMission_Wardrobe_Data.FastGetItemData(itemInfo.item_id)
    if itemInfo.item_num > 1 then
      local xMission_macro = require("client.slua.umg.TxMission.xMission.xmission_macro")
      UIManager.ShowUI(UIManager.UI_Config.xmission_select_quantity, itemInfo, function(count)
        if xMission_Wardrobe_Data.IsTOptionChest(itemInfo.item_id) then
          local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
          WardRobeHandler.send_metro_use_item(instID, count)
        else
          local TxMissionHandler = require("client.network.Protocol.TxMissionHandler")
          TxMissionHandler.send_metro_open_chest_req(instID, count)
        end
      end, xMission_macro.ENUM_SELECT_UI_TYPE.EnumType_OpenChest)
    elseif xMission_Wardrobe_Data.IsTOptionChest(itemInfo.item_id) then
      local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
      WardRobeHandler.send_metro_use_item(instID, 1)
    else
      local TxMissionHandler = require("client.network.Protocol.TxMissionHandler")
      TxMissionHandler.send_metro_open_chest_req(instID, 1)
    end
  end
end
return xMission_Wardrobe_Data