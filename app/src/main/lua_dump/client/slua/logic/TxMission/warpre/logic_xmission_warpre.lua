local xMission_macro = require("client.slua.umg.TxMission.xMission.xmission_macro")
local xMission_Prepare_Data = require("client.slua.logic.TxMission.warpre.xmission_prepare_data")
local xMission_Wardrobe_Data = require("client.slua.logic.TxMission.warpre.xmission_wardrobe_data")
local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
local LogicTxMissionWarPre = {
  MAX_SLOT_NUM = 9,
  WEAPON_MAX_ATTRIBUTES = {}
}
function LogicTxMissionWarPre.ShowPrepareView()
  UIManager.ShowUI(UIManager.UI_Config.TMVP_Prepare)
end
function LogicTxMissionWarPre.on_metro_move_item_rsp(inst_id, dst_desc, dst_slot, dst_inst_id)
  EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_T_METRO_ITEM_NOTIFY)
  LogicTxMissionWarPre.show_metro_move_item_tips(dst_desc)
end
function LogicTxMissionWarPre.show_metro_move_item_tips(dst_desc)
  if dst_desc == xMission_macro.Enum_Dst_Desc.EnumDst_Depot then
    ShowNotice(LocUtil.LocalizeResFormat(11339))
  elseif dst_desc == xMission_macro.Enum_Dst_Desc.EnumDst_Bag then
    ShowNotice(LocUtil.LocalizeResFormat(11336))
  elseif dst_desc == xMission_macro.Enum_Dst_Desc.EnumDst_Slot then
    ShowNotice(LocUtil.LocalizeResFormat(11338))
  elseif dst_desc == xMission_macro.Enum_Dst_Desc.EnumDst_PartSlot then
    ShowNotice(LocUtil.LocalizeResFormat(11337))
  elseif dst_desc == xMission_macro.Enum_Dst_Desc.EnumDst_SafeBag then
    ShowNotice(LocUtil.LocalizeResFormat(11334))
  end
end
function LogicTxMissionWarPre.on_metro_item_change_ntfy(inst_id, item, dst_desc, dst_slot, dst_inst_id)
  if dst_desc then
    if item and item.item_id then
      LogicTxMissionWarPre.AddItem(inst_id, item, dst_desc, dst_slot, dst_inst_id)
    else
      LogicTxMissionWarPre.RemoveItem(inst_id)
    end
    local xmission_wardrobe_data = require("client.slua.logic.TxMission.warpre.xmission_wardrobe_data")
    if not xmission_wardrobe_data.CheckUndercoverCapacity(nil, true) then
      local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
      local MatchSystem = require("client.slua.logic.match.logic_match")
      local status = MatchSystem.nMatchStatus
      if not status then
        log_error("LogicTxMissionWarPre.on_metro_item_change_ntfy nil state")
        return
      end
      log(bWriteLog and "LogicTxMissionWarPre.on_metro_item_change_ntfy, status=" .. tostring(status))
      if status == ENUM_MatchStatus.Ready and not TeamUpNewSystem.IsTeamLeader() then
        EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_FORCE_CANCEL_READY)
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_BAG_ITEM_CHANGE)
end
function LogicTxMissionWarPre.SetMetroBagAddedExtendCapacity(added)
  xMission_Prepare_Data.SetBagAddedExtendBuffCapacity(added)
end
function LogicTxMissionWarPre.on_metro_bag_capacity_ntfy(bag_type, added)
  if bag_type == "bag" then
    xMission_Prepare_Data.SetBagAddedCapacity(added)
    EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_CHANGE_BAG_CAPACITY)
  elseif bag_type == "safe_bag" then
    xMission_Prepare_Data.SetSafeBagAddedCapacity(added)
    EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_CHANGE_SAFE_BAG_CAPACITY)
  end
end
function LogicTxMissionWarPre.InitData(depot_capacity, metro)
  xMission_Prepare_Data.InitData(metro)
  xMission_Wardrobe_Data.InitData(metro, depot_capacity)
end
function LogicTxMissionWarPre.DestroyData()
  xMission_Prepare_Data.Destroy()
  xMission_Wardrobe_Data.Destroy()
  LogicTxMissionWarPre.SetAutoOpenBagFlag(false)
end
function LogicTxMissionWarPre.GetItemByInstID(inst_id, onlyDepot)
  local info = xMission_Wardrobe_Data.GetItemByInstID(inst_id)
  if onlyDepot then
    return info
  end
  info = info or xMission_Prepare_Data.GetItemByInstID(inst_id)
  return info
end
function LogicTxMissionWarPre.RemoveItem(inst_id)
  xMission_Wardrobe_Data.RemoveItemByInstID(inst_id)
  xMission_Prepare_Data.RemoveItemByInstID(inst_id)
end
function LogicTxMissionWarPre.AddItem(inst_id, item, dst_desc, dst_slot, dst_inst_id)
  if not (item and item.item_id) or item.item_id <= 0 then
    return
  end
  local itemCfg = xMission_Wardrobe_Data.FastGetItemData(item.item_id)
  if itemCfg and itemCfg.ItemSubType == xMission_macro.Enum_Sub_Type.EnumType_Sub_ResearchChest then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eXMissionOperationGetRecord) or {}
    if not saveData[DataMgr.roleData.uid] then
      saveData[DataMgr.roleData.uid] = {}
      saveData[DataMgr.roleData.uid].isGet = true
      PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eXMissionOperationGetRecord)
    end
  end
  if dst_desc == xMission_macro.Enum_Dst_Desc.EnumDst_Depot then
    xMission_Wardrobe_Data.AddItem(inst_id, item, dst_desc, dst_slot, dst_inst_id)
  elseif dst_desc == xMission_macro.Enum_Dst_Desc.EnumDst_PartSlot and xMission_Wardrobe_Data.GetItemByInstID(dst_inst_id) then
    xMission_Wardrobe_Data.AddItem(inst_id, item, dst_desc, dst_slot, dst_inst_id)
  else
    xMission_Prepare_Data.AddItem(inst_id, item, dst_desc, dst_slot, dst_inst_id)
  end
end
function LogicTxMissionWarPre.GetMaxSlotList(item_id)
  local list = {}
  local itemCfg = xMission_Wardrobe_Data.FastGetItemData(item_id)
  if itemCfg then
    for i = 1, LogicTxMissionWarPre.MAX_SLOT_NUM do
      if itemCfg["Slot" .. tostring(i)] and itemCfg["Slot" .. tostring(i)] ~= "" and itemCfg["Slot" .. tostring(i)] ~= "0" then
        table.insert(list, {
          idx = i,
          types = itemCfg["Slot" .. tostring(i)]
        })
      end
    end
  end
  return list
end
function LogicTxMissionWarPre.GetPartEquipIdxByInstID(weapon_ins_id, part_ins_id)
  local weapon_info = LogicTxMissionWarPre.GetItemByInstID(weapon_ins_id)
  local part_info = LogicTxMissionWarPre.GetItemByInstID(part_ins_id)
  if weapon_info and weapon_info.item_id and part_info and part_info.item_id then
    local partCfg = xMission_Wardrobe_Data.FastGetItemData(part_info.item_id)
    local list = LogicTxMissionWarPre.GetMaxSlotList(weapon_info.item_id)
    if partCfg and list and next(list) then
      for _, v in pairs(list) do
        local StringUtil = require("common.string_util")
        local itemSubTypeList = StringUtil.Split(v.types, ";")
        for _, vv in pairs(itemSubTypeList) do
          if tonumber(vv) == partCfg.ItemSubType and not LogicTxMissionWarPre.GetPartSlotInfo(weapon_ins_id, v.idx) then
            return v.idx
          end
        end
      end
    end
    if partCfg and list and next(list) then
      for _, v in pairs(list) do
        local StringUtil = require("common.string_util")
        local itemSubTypeList = StringUtil.Split(v.types, ";")
        for _, vv in pairs(itemSubTypeList) do
          if tonumber(vv) == partCfg.ItemSubType then
            return v.idx
          end
        end
      end
    end
  end
  return 0
end
function LogicTxMissionWarPre.GetPartLightIdxByInstID(weapon_ins_id, part_ins_id)
  local weapon_info = LogicTxMissionWarPre.GetItemByInstID(weapon_ins_id)
  local part_info = LogicTxMissionWarPre.GetItemByInstID(part_ins_id)
  if weapon_info and weapon_info.item_id and part_info and part_info.item_id then
    local partCfg = xMission_Wardrobe_Data.FastGetItemData(part_info.item_id)
    local list = LogicTxMissionWarPre.GetMaxSlotList(weapon_info.item_id)
    if partCfg and list and next(list) then
      for _, v in pairs(list) do
        local StringUtil = require("common.string_util")
        local itemSubTypeList = StringUtil.Split(v.types, ";")
        for _, vv in pairs(itemSubTypeList) do
          if tonumber(vv) == partCfg.ItemSubType and not LogicTxMissionWarPre.GetPartSlotInfo(weapon_ins_id, v.idx) then
            return v.idx
          end
        end
      end
    end
    if partCfg and list and next(list) then
      for _, v in pairs(list) do
        local StringUtil = require("common.string_util")
        local itemSubTypeList = StringUtil.Split(v.types, ";")
        for _, vv in pairs(itemSubTypeList) do
          if tonumber(vv) == partCfg.ItemSubType then
            return v.idx
          end
        end
      end
    end
  end
  return 0
end
function LogicTxMissionWarPre.GetItemPrepareSlots(item_id)
  local itemCfg = xMission_Wardrobe_Data.FastGetItemData(item_id)
  if itemCfg and itemCfg.PrepareSlot and itemCfg.PrepareSlot ~= "" and itemCfg.PrepareSlot ~= "0" then
    local StringUtil = require("common.string_util")
    local slots = StringUtil.Split(itemCfg.PrepareSlot, ";")
    return slots
  end
  return nil
end
function LogicTxMissionWarPre.GetItemTabIndex(item_id)
  local itemCfg = xMission_Wardrobe_Data.FastGetItemData(item_id)
  if itemCfg and itemCfg.WardrobeTab and tonumber(itemCfg.WardrobeTab) > 0 then
    return tonumber(itemCfg.WardrobeTab)
  end
  return 0
end
function LogicTxMissionWarPre.GetItemType(item_id)
  local itemCfg = xMission_Wardrobe_Data.FastGetItemData(item_id)
  if itemCfg and itemCfg.ItemType then
    return itemCfg.ItemType
  end
  return 0
end
function LogicTxMissionWarPre.PutOnItemByAuto(ins_id)
  if not LogicTxMissionWarPre.IsCanSendMetroMoveItemReq() then
    log(bWriteLog and "LogicTxMissionWarPre.PutOnItemByAuto return")
    return
  end
  local itemInfo = LogicTxMissionWarPre.GetItemByInstID(ins_id)
  if itemInfo then
    LogicTxMissionWarPre.PlayAudioAndReportTLog(itemInfo.item_id, true)
    local prepareSlots = LogicTxMissionWarPre.GetItemPrepareSlots(itemInfo.item_id)
    if prepareSlots and next(prepareSlots) then
      local TxMissionHandler = require("client.network.Protocol.TxMissionHandler")
      for _, v in pairs(prepareSlots) do
        local slotInfo = xMission_Prepare_Data.GetItemBySlotID(tonumber(v))
        if not slotInfo then
          TxMissionHandler.send_metro_move_item_req(itemInfo.inst_id, itemInfo.item_num, xMission_macro.Enum_Dst_Desc.EnumDst_Slot, tonumber(v), 0)
          return true
        end
      end
      TxMissionHandler.send_metro_move_item_req(itemInfo.inst_id, itemInfo.item_num, xMission_macro.Enum_Dst_Desc.EnumDst_Slot, tonumber(prepareSlots[1]), 0)
      return true
    end
  end
  return false
end
function LogicTxMissionWarPre.PutOnItemByManual(ins_id, slot_id)
  if not LogicTxMissionWarPre.IsCanSendMetroMoveItemReq() then
    log(bWriteLog and "LogicTxMissionWarPre.PutOnItemByManual return")
    return
  end
  if LogicTxMissionWarPre.CanPutOnItem(ins_id, slot_id) then
    local itemInfo = LogicTxMissionWarPre.GetItemByInstID(ins_id)
    if itemInfo then
      LogicTxMissionWarPre.PlayAudioAndReportTLog(itemInfo.item_id, true)
      local TxMissionHandler = require("client.network.Protocol.TxMissionHandler")
      TxMissionHandler.send_metro_move_item_req(itemInfo.inst_id, itemInfo.item_num, xMission_macro.Enum_Dst_Desc.EnumDst_Slot, slot_id, 0)
    end
  end
end
function LogicTxMissionWarPre.CanPutOnItem(ins_id, slot_id)
  local xMission_Prepare_Data = require("client.slua.logic.TxMission.warpre.xmission_prepare_data")
  local slotInfo = xMission_Prepare_Data.GetItemBySlotID(slot_id)
  if slotInfo then
    return tonumber(ins_id) ~= slotInfo.inst_id
  end
  return true
end
function LogicTxMissionWarPre.PutOffItem(ins_id, count, isBag)
  if not LogicTxMissionWarPre.IsCanSendMetroMoveItemReq() then
    log(bWriteLog and "LogicTxMissionWarPre.PutOffItem return")
    return
  end
  if LogicTxMissionWarPre.CanPutOffItem(ins_id) then
    local itemInfo = LogicTxMissionWarPre.GetItemByInstID(ins_id, false)
    if itemInfo then
      LogicTxMissionWarPre.PlayAudioAndReportTLog(itemInfo.item_id, false, isBag)
      local TxMissionHandler = require("client.network.Protocol.TxMissionHandler")
      TxMissionHandler.send_metro_move_item_req(itemInfo.inst_id, count or itemInfo.item_num, xMission_macro.Enum_Dst_Desc.EnumDst_Depot, 0, 0)
      EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_PUT_OFF_ITEM, ins_id)
    end
  end
end
function LogicTxMissionWarPre.CanPutOffItem(inst_id)
  local isInWardrobe = xMission_Wardrobe_Data.IsInWardrobeByInstID(inst_id)
  return not isInWardrobe
end
function LogicTxMissionWarPre.PutIntoBag(ins_id, count, show_tip, silent)
  if UIManager.IsUIShow(UIManager.UI_Config.xmission_beginner_guide) then
    local LogicXMissionBeginnerGuide = require("client.slua.logic.TxMission.logic_xmission_beginner_guide")
    if LogicXMissionBeginnerGuide.IsGuidingEquipItem(3) or LogicXMissionBeginnerGuide.IsGuidingEquipItem(4) then
      local xmission_wardrobe_data = require("client.slua.logic.TxMission.warpre.xmission_wardrobe_data")
      local itemData = xmission_wardrobe_data.GetItemByInstID(ins_id)
      local itemCfg = itemData and xmission_wardrobe_data.FastGetItemData(itemData.item_id)
      if itemCfg ~= nil then
        local LogicXMissionBlackMarket = require("client.slua.logic.TxMission.logic_xmission_black_market")
        if LogicXMissionBlackMarket.IsBulletByType(itemCfg.ItemType, itemCfg.ItemSubType) and LogicXMissionBeginnerGuide.IsGuidingEquipItem(3) or LogicXMissionBlackMarket.IsPartByType(itemCfg.ItemType, itemCfg.ItemSubType) and LogicXMissionBeginnerGuide.IsGuidingEquipItem(4) then
          EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_DRAG_GUIDE_END)
        else
          LogicXMissionBeginnerGuide.currentProgress = 4
          EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_DRAG_GUIDE_END)
        end
      end
    else
      LogicXMissionBeginnerGuide.currentProgress = 4
      EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_DRAG_GUIDE_END)
    end
  end
  if not LogicTxMissionWarPre.IsCanSendMetroMoveItemReq() then
    log(bWriteLog and "LogicTxMissionWarPre.PutIntoBag return")
    return
  end
  if not xMission_Prepare_Data.IsInBag(ins_id) and LogicTxMissionWarPre.CanPutIntoBag(ins_id, show_tip) then
    local itemInfo = LogicTxMissionWarPre.GetItemByInstID(ins_id, false)
    if itemInfo then
      LogicTxMissionWarPre.PlayAudioAndReportTLog(itemInfo.item_id, true, true)
      local TxMissionHandler = require("client.network.Protocol.TxMissionHandler")
      TxMissionHandler.send_metro_move_item_req(itemInfo.inst_id, count or itemInfo.item_num, xMission_macro.Enum_Dst_Desc.EnumDst_Bag, 0, 0, silent)
      return true
    end
  end
  return false
end
function LogicTxMissionWarPre.CanPutIntoBag(inst_id, show_tip)
  local itemInfo = LogicTxMissionWarPre.GetItemByInstID(inst_id, false)
  if itemInfo then
    local itemCfg = xMission_Wardrobe_Data.FastGetItemData(itemInfo.item_id)
    if itemCfg and itemCfg.CanIntoBag and itemCfg.CanIntoBag == 1 then
      return true
    end
  end
  if show_tip then
    ShowNotice(LocUtil.LocalizeResFormat(11307))
  end
  return false
end
function LogicTxMissionWarPre.PutIntoSafeBag(ins_id, count, show_tip)
  local logic_xmission_room = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_room)
  if logic_xmission_room:IsBanSafetyBox() then
    return
  end
  if not LogicTxMissionWarPre.IsCanSendMetroMoveItemReq() then
    log(bWriteLog and "LogicTxMissionWarPre.PutIntoSafeBag return")
    return
  end
  if not xMission_Prepare_Data.IsInSafeBag(ins_id) and LogicTxMissionWarPre.CanPutIntoSafeBag(ins_id, show_tip) then
    local itemInfo = LogicTxMissionWarPre.GetItemByInstID(ins_id, false)
    if itemInfo then
      LogicTxMissionWarPre.PlayAudioAndReportTLog(itemInfo.item_id, true, true)
      local TxMissionHandler = require("client.network.Protocol.TxMissionHandler")
      TxMissionHandler.send_metro_move_item_req(itemInfo.inst_id, count or itemInfo.item_num, xMission_macro.Enum_Dst_Desc.EnumDst_SafeBag, 0, 0)
      return true
    end
  end
  return false
end
function LogicTxMissionWarPre.CanPutIntoSafeBag(inst_id, show_tip)
  local itemInfo = LogicTxMissionWarPre.GetItemByInstID(inst_id, false)
  if itemInfo then
    local itemCfg = xMission_Wardrobe_Data.FastGetItemData(itemInfo.item_id)
    if itemCfg and itemCfg.CanIntoBag and itemCfg.CanIntoBag == 1 then
      return true
    end
  end
  if show_tip then
    ShowNotice(LocUtil.LocalizeResFormat(11335))
  end
  return false
end
function LogicTxMissionWarPre.PutOnPart(weapon_ins_id, part_ins_id, show_tip)
  if not LogicTxMissionWarPre.IsCanSendMetroMoveItemReq() then
    log(bWriteLog and "LogicTxMissionWarPre.PutOnPart return")
    return
  end
  if not LogicTxMissionWarPre.CanPutOnPart(weapon_ins_id, part_ins_id, show_tip) then
    return false
  end
  local part_info = LogicTxMissionWarPre.GetItemByInstID(part_ins_id)
  local idx = LogicTxMissionWarPre.GetPartEquipIdxByInstID(weapon_ins_id, part_ins_id)
  local TxMissionHandler = require("client.network.Protocol.TxMissionHandler")
  TxMissionHandler.send_metro_move_item_req(part_info.inst_id, part_info.item_num, xMission_macro.Enum_Dst_Desc.EnumDst_PartSlot, idx, weapon_ins_id)
  LogicTxMissionWarPre.PlayAudioAndReportTLog(part_info.item_id, true, true)
  return true
end
function LogicTxMissionWarPre.CanPutOnPart(weapon_ins_id, part_ins_id, show_tip)
  local idx = LogicTxMissionWarPre.GetPartEquipIdxByInstID(weapon_ins_id, part_ins_id)
  if idx <= 0 then
    if show_tip then
      ShowNotice(LocUtil.LocalizeResFormat(11308))
    end
    return false
  end
  return true
end
function LogicTxMissionWarPre.GetPartSlotInfo(inst_id, part_slot, onlyDepot)
  local info = xMission_Wardrobe_Data.GetPartSlotInfo(inst_id, part_slot)
  if onlyDepot then
    return info
  end
  info = info or xMission_Prepare_Data.GetPartSlotInfo(inst_id, part_slot)
  return info
end
function LogicTxMissionWarPre.IsItemEquiped(inst_id, weapon_inst_id, onlyDepot)
  local equiped = xMission_Wardrobe_Data.IsItemEquiped(inst_id, weapon_inst_id)
  if onlyDepot or equiped then
    return equiped
  end
  return xMission_Prepare_Data.IsItemEquiped(inst_id, weapon_inst_id)
end
function LogicTxMissionWarPre.GetItemWorth(itemInfo)
  if not itemInfo then
    return 0
  end
  local worth = 0
  local itemCfg = xMission_Wardrobe_Data.FastGetItemData(itemInfo.item_id)
  if itemCfg then
    worth = worth + itemCfg.SellPrice * itemInfo.item_num
  end
  if itemInfo.slots and next(itemInfo.slots) then
    for _, vv in pairs(itemInfo.slots) do
      local partCfg = xMission_Wardrobe_Data.FastGetItemData(vv.item_id)
      if partCfg then
        worth = worth + partCfg.SellPrice * vv.item_num
      end
    end
  end
  return worth
end
function LogicTxMissionWarPre.GetItemCurrentDurability(inst_id)
  local itemInfo = LogicTxMissionWarPre.GetItemByInstID(inst_id)
  if itemInfo then
    if itemInfo.durability then
      return itemInfo.durability
    else
      return LogicTxMissionWarPre.GetItemTotalDurability(inst_id)
    end
  end
  log_error("LogicTxMissionWarPre.GetItemCurrentDurability TxMissionItem Error")
  return 0
end
function LogicTxMissionWarPre.GetItemTotalDurability(inst_id)
  local totalDurability = 0
  local itemInfo = LogicTxMissionWarPre.GetItemByInstID(inst_id)
  if not itemInfo then
    return totalDurability
  end
  local itemCfg = xMission_Wardrobe_Data.FastGetItemData(itemInfo.item_id)
  if not itemCfg then
    return totalDurability
  end
  local xmission_affix_util = require("client.slua.umg.TxMission.xMission.affix.xmission_affix_util")
  totalDurability = itemCfg.totalDurability + xmission_affix_util:GetAffixDurability(inst_id)
  return totalDurability
end
function LogicTxMissionWarPre.on_metro_repaire_rsp(err, inst_id)
  if err == 0 then
    local itemInfo = LogicTxMissionWarPre.GetItemByInstID(inst_id)
    if itemInfo then
      itemInfo.durability = nil
      EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_REPAIR_SUCCESS, inst_id)
    end
  else
    ShowNotice(LocUtil.LocalizeResFormat(err))
  end
end
function LogicTxMissionWarPre.LoadTxMissionExtra()
  LogicTxMissionWarPre.WEAPON_MAX_ATTRIBUTES = {}
  local maxPowerCfg = CDataTable.GetTableData("TxMissionExtra", "max_power")
  if maxPowerCfg then
    table.insert(LogicTxMissionWarPre.WEAPON_MAX_ATTRIBUTES, maxPowerCfg.value)
  end
  local maxFireRange = CDataTable.GetTableData("TxMissionExtra", "max_fire_range")
  if maxFireRange then
    table.insert(LogicTxMissionWarPre.WEAPON_MAX_ATTRIBUTES, maxFireRange.value)
  end
  local maxFireRate = CDataTable.GetTableData("TxMissionExtra", "max_fire_rate")
  if maxFireRate then
    table.insert(LogicTxMissionWarPre.WEAPON_MAX_ATTRIBUTES, maxFireRate.value)
  end
  local maxCapacity = CDataTable.GetTableData("TxMissionExtra", "max_capacity")
  if maxCapacity then
    table.insert(LogicTxMissionWarPre.WEAPON_MAX_ATTRIBUTES, maxCapacity.value)
  end
  local maxStability = CDataTable.GetTableData("TxMissionExtra", "max_stability")
  if maxStability then
    table.insert(LogicTxMissionWarPre.WEAPON_MAX_ATTRIBUTES, maxStability.value)
  end
end
function LogicTxMissionWarPre.CanPutIntoPrepareSlot(item_id, slot_id)
  local slots = LogicTxMissionWarPre.GetItemPrepareSlots(item_id)
  if not slots then
    return false
  end
  for _, v in pairs(slots) do
    if tonumber(v) == slot_id then
      return true
    end
  end
  return false
end
function LogicTxMissionWarPre.GetItemWeightByInstId(inst_id)
  local weight = 0
  local itemInfo = LogicTxMissionWarPre.GetItemByInstID(inst_id)
  if itemInfo then
    weight = weight + LogicTxMissionWarPre.GetItemWeightByItemId(itemInfo.item_id) * itemInfo.item_num
    if itemInfo.slots and next(itemInfo.slots) then
      for _, vv in pairs(itemInfo.slots) do
        weight = weight + LogicTxMissionWarPre.GetItemWeightByItemId(vv.item_id) * vv.item_num
      end
    end
  end
  return weight
end
function LogicTxMissionWarPre.GetItemWeightByItemId(item_id)
  local itemCfg = xMission_Wardrobe_Data.FastGetItemData(item_id)
  if itemCfg then
    local logic_xmission_main = require("client.slua.logic.TxMission.logic_xmission_main")
    return logic_xmission_main.AdjustWeightAccuracy(itemCfg.weight_f)
  end
  return 0
end
function LogicTxMissionWarPre.NeedRepair(inst_id)
  local totalDurability = LogicTxMissionWarPre.GetItemTotalDurability(inst_id)
  local currentDurability = LogicTxMissionWarPre.GetItemCurrentDurability(inst_id)
  return totalDurability > currentDurability
end
function LogicTxMissionWarPre.ShowNeedRepair(inst_id)
  if not inst_id then
    return false
  end
  local totalDurability = LogicTxMissionWarPre.GetItemTotalDurability(inst_id)
  local currentDurability = LogicTxMissionWarPre.GetItemCurrentDurability(inst_id)
  local cfg = CDataTable.GetTableData("TxMissionExtra", "show_repair_icon_limit")
  local changedTotalDurability = 0
  if cfg.value then
    changedTotalDurability = totalDurability * (cfg.value / 100)
  end
  return currentDurability < changedTotalDurability
end
local hasAutoOpenBag = false
function LogicTxMissionWarPre.GetAutoOpenBagFlag()
  return hasAutoOpenBag
end
function LogicTxMissionWarPre.SetAutoOpenBagFlag(opened)
  hasAutoOpenBag = opened
end
function LogicTxMissionWarPre.CanUseItem(item_id, ins_id)
  local JumpUtils = require("client.logic.store.jump_utils")
  local itemCfg = xMission_Wardrobe_Data.FastGetItemData(item_id)
  local bIsInBag = xMission_Prepare_Data.IsInBag(ins_id)
  if itemCfg and itemCfg.ItemType == xMission_macro.Enum_Type.EnumType_Chest and not bIsInBag then
    return true
  end
  if itemCfg and itemCfg.ItemType == xMission_macro.Enum_Type.EnumType_RedPacket and not bIsInBag then
    return true
  end
  if itemCfg and itemCfg.ItemType == xMission_macro.Enum_Type.EnumType_Other and (itemCfg.ItemSubType == xMission_macro.Enum_Sub_Type.EnumType_Sub_ResearchChest or itemCfg.ItemSubType == xMission_macro.Enum_Sub_Type.EnumType_Sub_UseItem) then
    return true
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if itemCfg and itemCfg.ItemType == xMission_macro.Enum_Type.EnumType_Other and itemCfg.ItemSubType == xMission_macro.Enum_Sub_Type.EnumType_Sub_Identification and PublishRegionMacros.IsJapanOrKorea() then
    return false
  end
  local jumpCfg = CDataTable.GetTableData("XMJumpUrl", item_id)
  if jumpCfg and (JumpUtils.IsGameJumpUrl(jumpCfg.JumpUrl) or JumpUtils.IsPanDoraJumpUrl(jumpCfg.JumpUrl)) then
    return true
  end
  return false
end
function LogicTxMissionWarPre.metro_open_chest_rsp(items)
  log_tree("metro_open_chest_rsp items:", items)
  local arrayItemList = {}
  for k, v in pairs(items) do
    local arrayItem = {
      res_id = v.item_id,
      count = v.item_num,
      extra = v.dyn_attr
    }
    table.insert(arrayItemList, arrayItem)
  end
  local logic_xmission_operation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_operation)
  if logic_xmission_operation:GetIsReceivingChset() then
    logic_xmission_operation:ShowItemGetPanel(arrayItemList)
    return
  end
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(arrayItemList)
end
function LogicTxMissionWarPre.GetItemNumByItemId(itemId, onlyDepot)
  local count = 0
  local xmission_wardrobe_data = require("client.slua.logic.TxMission.warpre.xmission_wardrobe_data")
  count = xmission_wardrobe_data.GetItemNumByItemId(itemId)
  if onlyDepot then
    return count
  end
  local xMission_Prepare_Data = require("client.slua.logic.TxMission.warpre.xmission_prepare_data")
  count = count + xMission_Prepare_Data.GetItemNumByItemId(itemId)
  log(bWriteLog and "LogicTxMissionWarPre.GetItemNumByItemId, itemId = " .. tostring(itemId) .. ", onlyDepot = " .. tostring(onlyDepot) .. ", count = " .. tostring(count))
  return count
end
function LogicTxMissionWarPre.GetItemNumByItemIdAndAffix(itemId, onlyDepot, haveAffix)
  log(bWriteLog and "LogicTxMissionWarPre.GetItemNumByItemIdAndAffix itemId = " .. itemId .. ", onlyDepot = " .. tostring(onlyDepot) .. ", haveAffix = " .. tostring(haveAffix))
  local count = 0
  local xmission_wardrobe_data = require("client.slua.logic.TxMission.warpre.xmission_wardrobe_data")
  count = xmission_wardrobe_data.GetItemNumByItemIdAndAffix(itemId, haveAffix)
  log(bWriteLog and "LogicTxMissionWarPre.GetItemNumByItemIdAndAffix 1 count = " .. count)
  if onlyDepot then
    return count
  end
  local xMission_Prepare_Data = require("client.slua.logic.TxMission.warpre.xmission_prepare_data")
  count = count + xMission_Prepare_Data.GetItemNumByItemIdAndAffix(itemId, haveAffix)
  log(bWriteLog and "LogicTxMissionWarPre.GetItemNumByItemIdAndAffix 2 count = " .. count)
  return count
end
function LogicTxMissionWarPre.PlayAudioAndReportTLog(item_id, isEquip, isBag)
  local itemCfg = CDataTable.GetTableData("TxMissionItem", item_id)
  if itemCfg and itemCfg.ItemType then
    local strSoundEquip = sound_config.TPlan_UI_Equip
    local strSoundPut = sound_config.TPlan_UI_Put
    if itemCfg.ItemType == xMission_macro.Enum_Type.EnumType_Main_Weapon or itemCfg.ItemType == xMission_macro.Enum_Type.EnumType_Pistol or itemCfg.ItemType == xMission_macro.Enum_Type.EnumType_Knife then
      if itemCfg.ItemSubType == xMission_macro.Enum_Sub_Type.EnumType_Sub_Pan then
        strSoundEquip = sound_config.TPlan_UI_Equip_Pan
        strSoundPut = sound_config.TPlan_UI_Put_Pan
      else
        strSoundEquip = sound_config.TPlan_UI_Equip_Gun
        strSoundPut = sound_config.TPlan_UI_Put_Gun
      end
    end
    local audio_util = require("client.common.audio_util")
    audio_util.PlayAudio(strSoundEquip)
    if isEquip then
      if isBag then
        tlog_report_utils.ReportTLogEvent(TLogEventDefine.TPlan_Wardrobe_PutInBag)
      else
        tlog_report_utils.ReportTLogEvent(TLogEventDefine.TPlan_Wardrobe_PutOn)
      end
    elseif isBag then
      tlog_report_utils.ReportTLogEvent(TLogEventDefine.TPlan_Wardrobe_PutOff)
    else
      tlog_report_utils.ReportTLogEvent(TLogEventDefine.TPlan_Wardrobe_PutOutBag)
    end
  end
end
function LogicTxMissionWarPre.HasPart(inst_id)
  for i = 1, LogicTxMissionWarPre.MAX_SLOT_NUM do
    local slotInfo = LogicTxMissionWarPre.GetPartSlotInfo(inst_id, i)
    if slotInfo then
      return true
    end
  end
  return false
end
function LogicTxMissionWarPre.SellItem(inst_id, item_num)
  if LogicTxMissionWarPre.HasPart(inst_id) then
    local title = LocUtil.LocalizeResFormat(101001)
    local msg = LocUtil.LocalizeResFormat(60058)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.ShowTPlan(2, title, msg, function()
      local LogicXMissionBlackMarket = require("client.slua.logic.TxMission.logic_xmission_black_market")
      LogicXMissionBlackMarket.SellOneItemReq(inst_id, item_num)
    end)
  else
    local LogicXMissionBlackMarket = require("client.slua.logic.TxMission.logic_xmission_black_market")
    LogicXMissionBlackMarket.SellOneItemReq(inst_id, item_num)
  end
end
function LogicTxMissionWarPre.IsItemWithAffixs(inst_id)
  local itemInfo = LogicTxMissionWarPre.GetItemByInstID(inst_id)
  if not (itemInfo and itemInfo.affixs) or not next(itemInfo.affixs) then
    return false
  end
  return true
end
function LogicTxMissionWarPre.IsCanModifyAffixs(inst_id)
  local itemInfo = LogicTxMissionWarPre.GetItemByInstID(inst_id)
  local logic_xmission_operation_make_affix = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_operation_make_affix)
  return logic_xmission_operation_make_affix:CheckCanOperateItem(itemInfo)
end
function LogicTxMissionWarPre.GetItemAffixs(inst_id)
  if not LogicTxMissionWarPre.IsItemWithAffixs(inst_id) then
    return nil
  end
  local itemInfo = LogicTxMissionWarPre.GetItemByInstID(inst_id)
  local affix_array = {}
  for affix_id, order_id in pairs(itemInfo.affixs or {}) do
    table.insert(affix_array, {affix_id = affix_id, order_id = order_id})
  end
  table.sort(affix_array, function(a, b)
    return a.order_id < b.order_id
  end)
  local sorted_affix_ids = {}
  for _, entry in ipairs(affix_array) do
    table.insert(sorted_affix_ids, entry.affix_id)
  end
  return sorted_affix_ids
end
function LogicTxMissionWarPre.IsItemWithPVEAffixs(inst_id)
  local itemInfo = LogicTxMissionWarPre.GetItemByInstID(inst_id)
  if not (itemInfo and itemInfo.pve_affixs) or not next(itemInfo.pve_affixs) then
    return false
  end
  return true
end
function LogicTxMissionWarPre.IsItemWithMaxPVPAffixs(inst_id)
  local affixList = LogicTxMissionWarPre.GetItemPVPAffixs(inst_id)
  if not affixList or not next(affixList) then
    return false
  end
  if LogicTxMissionWarPre.IsAffixListWithMaxLevel(affixList) then
    return true
  end
  return false
end
function LogicTxMissionWarPre.IsAffixListWithMaxLevel(affixList)
  local logic_affix_pictorial_book = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_affix_pictorial_book)
  for _, affixID in pairs(affixList) do
    if logic_affix_pictorial_book:IsAffixMaxLevel(affixID) then
      return true
    end
  end
  return false
end
function LogicTxMissionWarPre.GetItemPVEAffixs(inst_id)
  if not inst_id then
    return nil
  end
  if not LogicTxMissionWarPre.IsItemWithAffixs(inst_id) then
    return nil
  end
  local itemInfo = LogicTxMissionWarPre.GetItemByInstID(inst_id)
  local affix_array = {}
  for affix_id, order_id in pairs(itemInfo.pve_affixs or {}) do
    table.insert(affix_array, {affix_id = affix_id, order_id = order_id})
  end
  table.sort(affix_array, function(a, b)
    return a.order_id < b.order_id
  end)
  local sorted_affix_ids = {}
  for _, entry in ipairs(affix_array) do
    table.insert(sorted_affix_ids, entry.affix_id)
  end
  return sorted_affix_ids
end
function LogicTxMissionWarPre.GetItemPVPAffixs(inst_id)
  if not inst_id then
    return nil
  end
  if not LogicTxMissionWarPre.IsItemWithAffixs(inst_id) then
    return nil
  end
  local itemInfo = LogicTxMissionWarPre.GetItemByInstID(inst_id)
  local affixList = {}
  if itemInfo.affixs then
    for affixID, _ in pairs(itemInfo.affixs) do
      table.insert(affixList, affixID)
    end
  end
  return affixList
end
function LogicTxMissionWarPre.GetItemPVERefineAffixs(inst_id)
  local itemInfo = LogicTxMissionWarPre.GetItemByInstID(inst_id)
  if not itemInfo.pve_refine_affixs then
    return nil
  end
  local affixList = {}
  if itemInfo.pve_refine_affixs then
    for affixID, _ in pairs(itemInfo.pve_refine_affixs) do
      table.insert(affixList, affixID)
    end
  end
  return affixList
end
function LogicTxMissionWarPre.ChangeItemPVEAffixs(inst_id, affixs)
  local itemInfo = LogicTxMissionWarPre.GetItemByInstID(inst_id)
  itemInfo.pve_  EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_CHANGE_PVE_AFFIX, inst_id)
end
function LogicTxMissionWarPre.ChangeItemInfo(inst_id, item)
  local itemInfo = LogicTxMissionWarPre.GetItemByInstID(inst_id)
  if itemInfo then
    itemInfo.affixs = item.affixs
    itemInfo.durability = item.durability
    itemInfo.left_upgrade_num = item.left_upgrade_num
  end
end
function LogicTxMissionWarPre.ChangeItemPVERefineAffixs(inst_id, affixs)
  local itemInfo = LogicTxMissionWarPre.GetItemByInstID(inst_id)
  itemInfo.pve_refine_end
function LogicTxMissionWarPre.GetItemAffixCount(inst_id)
  local affixList = LogicTxMissionWarPre.GetItemAffixs(inst_id)
  if not affixList then
    return 0
  end
  return #affixList
end
function LogicTxMissionWarPre.GetItemPVEAffixCount(inst_id)
  local affixList = LogicTxMissionWarPre.GetItemPVEAffixs(inst_id)
  if not affixList then
    return 0
  end
  return #affixList
end
function LogicTxMissionWarPre.GetSlotNeedRepairItem()
  local xMission_Prepare_Data = require("client.slua.logic.TxMission.warpre.xmission_prepare_data")
  local logic_xmission_warpre = require("client.slua.logic.TxMission.warpre.logic_xmission_warpre")
  local xmission_affix_util = require("client.slua.umg.TxMission.xMission.affix.xmission_affix_util")
  local Slot_Type_List = {
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8
  }
  local instIdList = {}
  for i = 1, #Slot_Type_List do
    local slot_type = Slot_Type_List[i]
    local info = xMission_Prepare_Data.GetItemBySlotID(slot_type)
    if info and info.inst_id and logic_xmission_warpre.NeedRepair(info.inst_id) then
      table.insert(instIdList, info.inst_id)
    end
  end
  return instIdList
end
function LogicTxMissionWarPre.CheckRepairBeforeGameMatch(callback)
  local xMission_Prepare_Data = require("client.slua.logic.TxMission.warpre.xmission_prepare_data")
  local logic_xmission_warpre = require("client.slua.logic.TxMission.warpre.logic_xmission_warpre")
  local xmission_affix_util = require("client.slua.umg.TxMission.xMission.affix.xmission_affix_util")
  local Slot_Type_List = {
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8
  }
  local cfg = CDataTable.GetTableData("TxMissionExtra", "repair_check_percent_limit")
  local repair_check_percent_limit = 0.5
  if cfg then
    repair_check_percent_limit = tonumber(cfg.Value) / 100
  end
  local instIdList = {}
  local lowPercentItemInstIdList = {}
  for i = 1, #Slot_Type_List do
    local slot_type = Slot_Type_List[i]
    local info = xMission_Prepare_Data.GetItemBySlotID(slot_type)
    if info and info.inst_id and logic_xmission_warpre.NeedRepair(info.inst_id) then
      local totalDurability = LogicTxMissionWarPre.GetItemTotalDurability(info.inst_id)
      local currentDurability = LogicTxMissionWarPre.GetItemCurrentDurability(info.inst_id)
      if repair_check_percent_limit >= currentDurability / totalDurability then
        table.insert(lowPercentItemInstIdList, info.inst_id)
      end
      table.insert(instIdList, info.inst_id)
    end
  end
  local cfg = CDataTable.GetTableData("TxMissionExtra", "repair_check_count_limit")
  local repair_check_count_limit = 1
  if cfg then
    repair_check_count_limit = tonumber(cfg.Value)
  end
  if repair_check_count_limit > #lowPercentItemInstIdList then
    log(bWriteLog and string.format("LogicTxMissionWarPre.CheckRepairBeforeGameMatch,nedd repair num:%s < repair_check_count_limit:%s", #instIdList, repair_check_count_limit))
    return false
  end
  LogicTxMissionWarPre.BatchRepairItems(instIdList, 66929, callback)
  return true
end
function LogicTxMissionWarPre.BatchRepairItems(instIdList, locId, callback)
  if not next(instIdList) then
    return
  end
  local logic_xmission_warpre = require("client.slua.logic.TxMission.warpre.logic_xmission_warpre")
  local xmission_affix_util = require("client.slua.umg.TxMission.xMission.affix.xmission_affix_util")
  local costNum = 0
  for _, inst_id in ipairs(instIdList) do
    if logic_xmission_warpre.NeedRepair(inst_id) then
      costNum = costNum + xmission_affix_util:GetAffixRepairCost(inst_id)
    end
  end
  local logic_xmission_main = require("client.slua.logic.TxMission.logic_xmission_main")
  local money = logic_xmission_main.GetMoney()
  local title = LocUtil.LocalizeResFormat(101001)
  local msg = LocUtil.LocalizeResFormat(locId, costNum)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  if locId == 66929 then
    CommonMsgBoxMgr.ShowTPlan(4, title, msg, function()
      if money < costNum then
        ShowNotice(66931)
      else
        local TxMissionHandler = require("client.network.Protocol.TxMissionHandler")
        TxMissionHandler.send_metro_batch_repaire_req(instIdList)
      end
    end, callback, LocUtil.GetLocalizeResStr(66933), LocUtil.GetLocalizeResStr(60039))
  else
    CommonMsgBoxMgr.ShowTPlan(2, title, msg, function()
      if money < costNum then
        ShowNotice(66931)
      else
        local TxMissionHandler = require("client.network.Protocol.TxMissionHandler")
        TxMissionHandler.send_metro_batch_repaire_req(instIdList)
      end
    end)
  end
end
function LogicTxMissionWarPre.isNeedShowPrepareGuide()
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  local step = DataMgr.GetNewbieGuideValue(LogicNewbie.NEWBIE_GUIDE_MODULE_ID_XMISSION_WAR_PRESET, 11)
  if step and 1 <= step then
    log(bWriteLog and "LogicTxMissionWarPre.isNeedShowPrepareGuide, is already comolete")
    return false
  end
  local instIdList = LogicTxMissionWarPre.GetSlotNeedRepairItem()
  if not next(instIdList) then
    log(bWriteLog and "LogicTxMissionWarPre.isNeedShowPrepareGuide, no item need to repair")
    return
  end
  local logic_xmission_history_record = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_history_record)
  local recordList = logic_xmission_history_record:GetSummaryRecordList()
  local logic_xmission_season = require("client.slua.logic.TxMission.season.logic_xmission_season")
  local curSeasonId = logic_xmission_season.GetCurTXSeasonID()
  local seasonConfig = logic_xmission_season.GetSeasonConfig(curSeasonId)
  local TimeUtil = require("client.common.time_util")
  local startTime = TimeUtil.TimeStringToUnixstamp(seasonConfig.StartTime)
  local endTime = TimeUtil.TimeStringToUnixstamp(seasonConfig.EndTime)
  local isHaveHistory = false
  for i, v in ipairs(recordList) do
    if startTime <= v.time and endTime >= v.time then
      isHaveHistory = true
      break
    end
  end
  if not isHaveHistory then
    log(bWriteLog and "LogicTxMissionWarPre.isNeedShowPrepareGuide, no fight history")
    return false
  end
  return true
end
function LogicTxMissionWarPre.IsCanSendMetroMoveItemReq()
  local MatchSystem = require("client.slua.logic.match.logic_match")
  local status = MatchSystem.nMatchStatus
  log(bWriteLog and "LogicTxMissionWarPre.IsCanSendMetroMoveItemReq, status=" .. tostring(status))
  if status == ENUM_MatchStatus.Not then
    return true
  elseif status == ENUM_MatchStatus.Ready then
    ShowNotice(3202013)
  else
    ShowNotice(3202014)
  end
  return false
end
function LogicTxMissionWarPre.IsShowGifted(itemId)
  local logic_xmission_heirloom_equip = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_heirloom_equip)
  return logic_xmission_heirloom_equip:GetIsGiftedHeirloomEuqipData(itemId) > 0
end
return LogicTxMissionWarPre