local xMission_Prepare_Data = {}
local xMission_macro = require("client.slua.umg.TxMission.xMission.xmission_macro")
local SlotItemTable = {}
local BagItemList = {}
local BagDefaultCapacity = 0
local BagAddedCapacity = 0
local BagAddedExtendBuffCapacity = 0
local BagWeight = 0
local SafeBagItemList = {}
local SafeBagDefaultCapacity = 0
local SafeBagAddedCapacity = 0
local SafeBagWeight = 0
local PrepareItemTable = {}
function xMission_Prepare_Data.InitData(metro)
  xMission_Prepare_Data.Destroy()
  xMission_Prepare_Data.InitDefaultCapacity()
  xMission_Prepare_Data.InitSlotItemTable(metro)
  xMission_Prepare_Data.InitBagItemList(metro)
  xMission_Prepare_Data.InitSafeBagItemList(metro)
end
function xMission_Prepare_Data.AddItem(inst_id, item, dst_desc, dst_slot, dst_inst_id)
  if dst_desc == xMission_macro.Enum_Dst_Desc.EnumDst_Slot then
    xMission_Prepare_Data.AddSlotItem(dst_slot, item)
  elseif dst_desc == xMission_macro.Enum_Dst_Desc.EnumDst_PartSlot then
    xMission_Prepare_Data.AddPartSlotItem(dst_inst_id, dst_slot, item)
  elseif dst_desc == xMission_macro.Enum_Dst_Desc.EnumDst_Bag then
    item.    xMission_Prepare_Data.AddBagItem(item)
  elseif dst_desc == xMission_macro.Enum_Dst_Desc.EnumDst_SafeBag then
    item.    xMission_Prepare_Data.AddSafeBagItem(item)
  end
end
function xMission_Prepare_Data.RemoveItemByInstID(inst_id)
  xMission_Prepare_Data.RemoveSlotItem(inst_id)
  xMission_Prepare_Data.RemoveBagItem(inst_id)
  xMission_Prepare_Data.RemoveSafeBagItem(inst_id)
  xMission_Prepare_Data.RemovePrepareItem(inst_id)
end
function xMission_Prepare_Data.Destroy()
  SlotItemTable = {}
  BagItemList = {}
  BagDefaultCapacity = 0
  BagAddedCapacity = 0
  BagAddedExtendBuffCapacity = 0
  BagWeight = 0
  SafeBagItemList = {}
  SafeBagDefaultCapacity = 0
  SafeBagAddedCapacity = 0
  SafeBagWeight = 0
  PrepareItemTable = {}
end
function xMission_Prepare_Data.InitDefaultCapacity()
  local bagCapacity = CDataTable.GetTableData("TxMissionExtra", "bag_default_cap")
  xMission_Prepare_Data.SetBagDefaultCapacity(bagCapacity.value)
  local safeBagCapacity = CDataTable.GetTableData("TxMissionExtra", "safe_bag_default_cap")
  xMission_Prepare_Data.SetSafeBagDefaultCapacity(safeBagCapacity.value)
end
function xMission_Prepare_Data.InitSlotItemTable(metro)
  if metro and metro.slots and next(metro.slots) then
    for k, v in pairs(metro.slots) do
      SlotItemTable[k] = v
      xMission_Prepare_Data.AddPrepareItem(v.inst_id, v)
    end
  end
end
function xMission_Prepare_Data.AddSlotItem(slot_id, item)
  SlotItemTable[slot_id] = item
  xMission_Prepare_Data.AddPrepareItem(item.inst_id, item)
end
function xMission_Prepare_Data.AddPartSlotItem(dst_inst_id, dst_slot, item)
  local weaponInfo = xMission_Prepare_Data.GetItemByInstID(dst_inst_id)
  if not weaponInfo then
    return
  end
  weaponInfo.slots = weaponInfo.slots or {}
  weaponInfo.slots[dst_slot] = item
  xMission_Prepare_Data.AddPrepareItem(item.inst_id, item)
  if xMission_Prepare_Data.IsInBag(dst_inst_id) then
    xMission_Prepare_Data.CalculateBagWeight()
  elseif xMission_Prepare_Data.IsInSafeBag(dst_inst_id) then
    xMission_Prepare_Data.CalculateSafeBagWeight()
  end
end
function xMission_Prepare_Data.RemoveSlotItem(inst_id)
  if SlotItemTable and next(SlotItemTable) then
    for i, v in pairs(SlotItemTable) do
      if v.inst_id == inst_id then
        SlotItemTable[i] = nil
        break
      elseif v.slots and next(v.slots) then
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
function xMission_Prepare_Data.GetItemBySlotID(slot_id)
  slot_id = tonumber(slot_id)
  if SlotItemTable and SlotItemTable[slot_id] then
    return SlotItemTable[slot_id]
  end
  return nil
end
function xMission_Prepare_Data.GetSlotItemTable()
  return SlotItemTable
end
function xMission_Prepare_Data.IsItemEquiped(inst_id, weapon_inst_id)
  if SlotItemTable and next(SlotItemTable) then
    for _, v in pairs(SlotItemTable) do
      if inst_id == v.inst_id then
        return true
      elseif v.slots and next(v.slots) then
        for _, vv in pairs(v.slots) do
          if inst_id == vv.inst_id and (not weapon_inst_id or weapon_inst_id and weapon_inst_id == v.inst_id) then
            return true
          end
        end
      end
    end
  end
  if BagItemList and next(BagItemList) then
    for _, v in pairs(BagItemList) do
      if v.slots and next(v.slots) then
        for _, vv in pairs(v.slots) do
          if inst_id == vv.inst_id and (not weapon_inst_id or weapon_inst_id and weapon_inst_id == v.inst_id) then
            return true
          end
        end
      end
    end
  end
  if SafeBagItemList and next(SafeBagItemList) then
    for _, v in pairs(SafeBagItemList) do
      if v.slots and next(v.slots) then
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
function xMission_Prepare_Data.IsItemEquippedOnSlot(inst_id, slot_id)
  local slotInfo = xMission_Prepare_Data.GetItemBySlotID(slot_id)
  if slotInfo then
    return slotInfo.inst_id == inst_id
  end
  return false
end
function xMission_Prepare_Data.GetPartSlotInfo(inst_id, part_slot)
  if SlotItemTable and next(SlotItemTable) then
    for _, v in pairs(SlotItemTable) do
      if inst_id == v.inst_id and v.slots and next(v.slots) then
        return v.slots[part_slot]
      end
    end
  end
  if BagItemList and next(BagItemList) then
    for _, v in pairs(BagItemList) do
      if inst_id == v.inst_id and v.slots and next(v.slots) then
        return v.slots[part_slot]
      end
    end
  end
  if SafeBagItemList and next(SafeBagItemList) then
    for _, v in pairs(SafeBagItemList) do
      if inst_id == v.inst_id and v.slots and next(v.slots) then
        return v.slots[part_slot]
      end
    end
  end
  return nil
end
function xMission_Prepare_Data.GetFirstEquipWeapon()
  local slotInfo = xMission_Prepare_Data.GetItemBySlotID(xMission_macro.Enum_Slot.EnumSlot_Main_Weapon_1)
  if slotInfo and slotInfo.item_id and slotInfo.item_num > 0 then
    return slotInfo
  end
  slotInfo = xMission_Prepare_Data.GetItemBySlotID(xMission_macro.Enum_Slot.EnumSlot_Main_Weapon_2)
  if slotInfo and slotInfo.item_id and slotInfo.item_num > 0 then
    return slotInfo
  end
  slotInfo = xMission_Prepare_Data.GetItemBySlotID(xMission_macro.Enum_Slot.EnumSlot_Pistol)
  if slotInfo and slotInfo.item_id and slotInfo.item_num > 0 then
    return slotInfo
  end
  return nil
end
function xMission_Prepare_Data.IsEquipHelmet()
  return xMission_Prepare_Data.GetItemBySlotID(xMission_macro.Enum_Slot.EnumSlot_Helmet)
end
function xMission_Prepare_Data.IsEquipArmor()
  return xMission_Prepare_Data.GetItemBySlotID(xMission_macro.Enum_Slot.EnumSlot_Armor)
end
function xMission_Prepare_Data.InitBagItemList(metro)
  if metro and metro.bag then
    xMission_Prepare_Data.SetBagAddedCapacity(metro.bag.added)
    if metro.bag.items and next(metro.bag.items) then
      for k, v in pairs(metro.bag.items) do
        v.inst_id = k
        table.insert(BagItemList, v)
        xMission_Prepare_Data.AddPrepareItem(v.inst_id, v)
      end
      xMission_Prepare_Data.SortBagList()
      xMission_Prepare_Data.CalculateBagWeight()
    end
  end
end
function xMission_Prepare_Data.AddBagItem(item)
  local exist = false
  if BagItemList and 0 < #BagItemList then
    for i, v in pairs(BagItemList) do
      if v.inst_id == item.inst_id then
        BagItemList[i] = item
        exist = true
        break
      end
    end
  end
  if not exist then
    table.insert(BagItemList, item)
    xMission_Prepare_Data.SortBagList()
  end
  xMission_Prepare_Data.AddPrepareItem(item.inst_id, item)
  xMission_Prepare_Data.CalculateBagWeight()
end
function xMission_Prepare_Data.RemoveBagItem(inst_id)
  if BagItemList and 0 < #BagItemList then
    for i, v in pairs(BagItemList) do
      if v.inst_id == inst_id then
        table.remove(BagItemList, i)
        xMission_Prepare_Data.CalculateBagWeight()
        break
      elseif v.slots and next(v.slots) then
        for kk, vv in pairs(v.slots) do
          if vv.inst_id == inst_id then
            v.slots[kk] = nil
            xMission_Prepare_Data.CalculateBagWeight()
            return
          end
        end
      end
    end
  end
end
function xMission_Prepare_Data.GetBagList()
  return BagItemList
end
function xMission_Prepare_Data.GetBagCapacity()
  log(bWriteLog and "xMission_Prepare_Data.GetBagCapacity" .. " bagDefault : " .. BagDefaultCapacity .. " bagAdded : " .. BagAddedCapacity .. " bagExtend: " .. tostring(BagAddedExtendBuffCapacity))
  return BagDefaultCapacity + BagAddedCapacity + BagAddedExtendBuffCapacity
end
function xMission_Prepare_Data.SetBagDefaultCapacity(default)
  BagDefaultCapacity = default
end
function xMission_Prepare_Data.GetBagAddedCapacity()
  return BagAddedCapacity
end
function xMission_Prepare_Data.SetBagAddedCapacity(added)
  log(bWriteLog and "xMission_Prepare_Data.SetBagAddedCapacity added: " .. added)
  BagAddedCapacity = added or 0
end
function xMission_Prepare_Data.SetBagAddedExtendBuffCapacity(added)
  log(bWriteLog and "xMission_Prepare_Data.SetBagAddedCapacity extendAdded: " .. added)
  BagAddedExtendBuffCapacity = added or 0
end
function xMission_Prepare_Data.SetBagWeight(weight)
  log(bWriteLog and "xMission_Prepare_Data.SetBagWeight " .. weight)
  BagWeight = weight
end
function xMission_Prepare_Data.GetBagWeight()
  log(bWriteLog and "xMission_Prepare_Data.GetBagWeight " .. BagWeight)
  return BagWeight
end
function xMission_Prepare_Data.IsOverWeight()
  local isOverWeight = xMission_Prepare_Data.GetBagWeight() > xMission_Prepare_Data.GetBagCapacity()
  log(bWriteLog and "xMission_Prepare_Data.IsOverWeight = " .. tostring(isOverWeight))
  return isOverWeight
end
function xMission_Prepare_Data.SortBagList()
  if BagItemList and 0 < #BagItemList then
    local LogicTxMissionWarPre = require("client.slua.logic.TxMission.warpre.logic_xmission_warpre")
    local onCmpData = function(a, b)
      local typeA = LogicTxMissionWarPre.GetItemType(a.item_id)
      local typeB = LogicTxMissionWarPre.GetItemType(b.item_id)
      return typeA < typeB
    end
    table.sort(BagItemList, onCmpData)
  end
end
function xMission_Prepare_Data.CalculateBagWeight()
  local weight = 0
  if BagItemList and 0 < #BagItemList then
    local LogicTxMissionWarPre = require("client.slua.logic.TxMission.warpre.logic_xmission_warpre")
    for _, v in pairs(BagItemList) do
      weight = weight + LogicTxMissionWarPre.GetItemWeightByItemId(v.item_id) * v.item_num
      if v.slots and next(v.slots) then
        for _, vv in pairs(v.slots) do
          weight = weight + LogicTxMissionWarPre.GetItemWeightByItemId(vv.item_id) * vv.item_num
        end
      end
    end
  end
  xMission_Prepare_Data.SetBagWeight(weight)
end
function xMission_Prepare_Data.IsInBag(inst_id)
  inst_id = tonumber(inst_id)
  if BagItemList and 0 < #BagItemList then
    for _, v in pairs(BagItemList) do
      if v.inst_id == inst_id then
        return true
      end
    end
  end
  return false
end
function xMission_Prepare_Data.GetItemNumInBag(item_id, _)
  local num = 0
  if BagItemList and 0 < #BagItemList then
    for _, v in pairs(BagItemList) do
      if v.item_id == item_id then
        num = num + v.item_num
      end
    end
  end
  num = num + xMission_Prepare_Data.GetItemNumInSafeBag(item_id)
  return num
end
function xMission_Prepare_Data.GetBagItemInstID(item_id)
  local inst_id = 0
  if BagItemList and 0 < #BagItemList then
    for _, v in pairs(BagItemList) do
      if v.item_id == item_id then
        inst_id = v.inst_id
      end
    end
  end
  return inst_id
end
function xMission_Prepare_Data.IsBagEmpty()
  return #BagItemList == 0
end
function xMission_Prepare_Data.IsEquipDrugsInBag(needSafeBag)
  local xmission_wardrobe_data = require("client.slua.logic.TxMission.warpre.xmission_wardrobe_data")
  local itemCfg
  if BagItemList and 0 < #BagItemList then
    for _, v in pairs(BagItemList) do
      if v.item_id and 0 < v.item_num then
        itemCfg = xmission_wardrobe_data.FastGetItemData(v.item_id)
        if itemCfg and itemCfg.ItemSubType == xMission_macro.Enum_Sub_Type.EnumType_Sub_Drug then
          return true
        end
      end
    end
  end
  if needSafeBag and SafeBagItemList and 0 < #SafeBagItemList then
    for _, v in pairs(SafeBagItemList) do
      if v.item_id and 0 < v.item_num then
        itemCfg = xmission_wardrobe_data.FastGetItemData(v.item_id)
        if itemCfg and itemCfg.ItemSubType == xMission_macro.Enum_Sub_Type.EnumType_Sub_Drug then
          return true
        end
      end
    end
  end
  return false
end
function xMission_Prepare_Data.GetBagItemListBySubType(itemSubType)
  local xmission_wardrobe_data = require("client.slua.logic.TxMission.warpre.xmission_wardrobe_data")
  local itemList = {}
  if BagItemList and 0 < #BagItemList then
    for _, v in pairs(BagItemList) do
      if v.item_id and 0 < v.item_num then
        local itemCfg = xmission_wardrobe_data.FastGetItemData(v.item_id)
        if itemCfg and itemCfg.ItemSubType == itemSubType then
          table.insert(itemList, v)
        end
      end
    end
  end
  if SafeBagItemList and 0 < #SafeBagItemList then
    for _, v in pairs(SafeBagItemList) do
      if v.item_id and 0 < v.item_num then
        local itemCfg = xmission_wardrobe_data.FastGetItemData(v.item_id)
        if itemCfg and itemCfg.ItemSubType == itemSubType then
          table.insert(itemList, v)
        end
      end
    end
  end
  table.sort(itemList, function(itemInfoA, itemInfoB)
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local itemCfgA = CDataTable.GetTableData("Item", itemInfoA.item_id)
    local itemCfgB = CDataTable.GetTableData("Item", itemInfoB.item_id)
    if not itemCfgA or not itemCfgB then
      return false
    end
    if itemCfgA.ItemQuality ~= itemCfgB.ItemQuality then
      return itemCfgA.ItemQuality > itemCfgB.ItemQuality
    end
  end)
  return itemList
end
function xMission_Prepare_Data.InitSafeBagItemList(metro)
  if metro and metro.safe_bag then
    xMission_Prepare_Data.SetSafeBagAddedCapacity(metro.safe_bag.added)
    if metro.safe_bag.items and next(metro.safe_bag.items) then
      for k, v in pairs(metro.safe_bag.items) do
        v.inst_id = k
        table.insert(SafeBagItemList, v)
        xMission_Prepare_Data.AddPrepareItem(v.inst_id, v)
      end
      xMission_Prepare_Data.SortSafeBagList()
      xMission_Prepare_Data.CalculateSafeBagWeight()
    end
  end
end
function xMission_Prepare_Data.AddSafeBagItem(item)
  local exist = false
  if SafeBagItemList and 0 < #SafeBagItemList then
    for i, v in pairs(SafeBagItemList) do
      if v.inst_id == item.inst_id then
        SafeBagItemList[i] = item
        exist = true
        break
      end
    end
  end
  if not exist then
    table.insert(SafeBagItemList, item)
    xMission_Prepare_Data.SortSafeBagList()
  end
  xMission_Prepare_Data.AddPrepareItem(item.inst_id, item)
  xMission_Prepare_Data.CalculateSafeBagWeight()
end
function xMission_Prepare_Data.RemoveSafeBagItem(inst_id)
  if SafeBagItemList and 0 < #SafeBagItemList then
    for i, v in pairs(SafeBagItemList) do
      if v.inst_id == inst_id then
        table.remove(SafeBagItemList, i)
        xMission_Prepare_Data.CalculateSafeBagWeight()
        break
      elseif v.slots and next(v.slots) then
        for kk, vv in pairs(v.slots) do
          if vv.inst_id == inst_id then
            v.slots[kk] = nil
            xMission_Prepare_Data.CalculateSafeBagWeight()
            return
          end
        end
      end
    end
  end
end
function xMission_Prepare_Data.GetSafeBagList()
  return SafeBagItemList
end
function xMission_Prepare_Data.GetSafeBagCapacity()
  return SafeBagDefaultCapacity + SafeBagAddedCapacity
end
function xMission_Prepare_Data.SetSafeBagDefaultCapacity(default)
  SafeBagDefaultCapacity = default
end
function xMission_Prepare_Data.SetSafeBagAddedCapacity(added)
  SafeBagAddedCapacity = added or 0
end
function xMission_Prepare_Data.SetSafeBagWeight(weight)
  SafeBagWeight = weight
end
function xMission_Prepare_Data.GetSafeBagWeight()
  return SafeBagWeight
end
function xMission_Prepare_Data.SortSafeBagList()
  if SafeBagItemList and 0 < #SafeBagItemList then
    local LogicTxMissionWarPre = require("client.slua.logic.TxMission.warpre.logic_xmission_warpre")
    local onCmpData = function(a, b)
      local typeA = LogicTxMissionWarPre.GetItemType(a.item_id)
      local typeB = LogicTxMissionWarPre.GetItemType(b.item_id)
      return typeA < typeB
    end
    table.sort(SafeBagItemList, onCmpData)
  end
end
function xMission_Prepare_Data.CalculateSafeBagWeight()
  local weight = 0
  if SafeBagItemList and 0 < #SafeBagItemList then
    local LogicTxMissionWarPre = require("client.slua.logic.TxMission.warpre.logic_xmission_warpre")
    for _, v in pairs(SafeBagItemList) do
      weight = weight + LogicTxMissionWarPre.GetItemWeightByItemId(v.item_id) * v.item_num
      if v.slots and next(v.slots) then
        for _, vv in pairs(v.slots) do
          weight = weight + LogicTxMissionWarPre.GetItemWeightByItemId(vv.item_id) * vv.item_num
        end
      end
    end
  end
  xMission_Prepare_Data.SetSafeBagWeight(weight)
end
function xMission_Prepare_Data.IsInSafeBag(inst_id)
  inst_id = tonumber(inst_id)
  if SafeBagItemList and 0 < #SafeBagItemList then
    for _, v in pairs(SafeBagItemList) do
      if v.inst_id == inst_id then
        return true
      end
    end
  end
  return false
end
function xMission_Prepare_Data.GetItemNumInSafeBag(item_id)
  local num = 0
  if SafeBagItemList and 0 < #SafeBagItemList then
    for _, v in pairs(SafeBagItemList) do
      if v.item_id == item_id then
        num = num + v.item_num
      end
    end
  end
  return num
end
function xMission_Prepare_Data.GetSafeBagItemInstID(item_id)
  if SafeBagItemList and 0 < #SafeBagItemList then
    for _, v in pairs(SafeBagItemList) do
      if v.item_id == item_id then
        return v.inst_id
      end
    end
  end
  return nil
end
function xMission_Prepare_Data.IsSafeBagEmpty()
  return #SafeBagItemList == 0
end
function xMission_Prepare_Data.AddPrepareItem(inst_id, v)
  PrepareItemTable[inst_id] = v
  if v.slots and next(v.slots) then
    for _, vv in pairs(v.slots) do
      PrepareItemTable[vv.inst_id] = vv
    end
  end
end
function xMission_Prepare_Data.RemovePrepareItem(inst_id)
  if PrepareItemTable and PrepareItemTable[inst_id] then
    local v = PrepareItemTable[inst_id]
    if v.slots and next(v.slots) then
      for _, vv in pairs(v.slots) do
        PrepareItemTable[vv.inst_id] = nil
      end
    end
    PrepareItemTable[inst_id] = nil
  end
end
function xMission_Prepare_Data.GetItemByInstID(inst_id)
  inst_id = tonumber(inst_id)
  if PrepareItemTable and PrepareItemTable[inst_id] then
    return PrepareItemTable[inst_id]
  end
  return nil
end
function xMission_Prepare_Data.GetItemNumByItemId(itemId)
  local count = 0
  for k, v in pairs(PrepareItemTable) do
    if v.item_id == itemId then
      count = count + tonumber(v.item_num)
    end
  end
  log(bWriteLog and "xMission_Prepare_Data.GetItemNumByItemId, itemId = " .. tostring(itemId) .. ", count = " .. tostring(count))
  return count
end
function xMission_Prepare_Data.GetItemNumByItemIdAndAffix(itemId, haveAffix)
  local count = 0
  haveAffix = haveAffix or false
  for k, v in pairs(PrepareItemTable) do
    local bHaveAffix = false
    if v.affixs then
      bHaveAffix = true
    end
    if v.item_id == itemId and bHaveAffix == haveAffix then
      count = count + tonumber(v.item_num)
    end
  end
  log(bWriteLog and "xMission_Prepare_Data.GetItemNumByItemIdAndAffix, itemId = " .. tostring(itemId) .. ", count = " .. tostring(count))
  return count
end
return xMission_Prepare_Data