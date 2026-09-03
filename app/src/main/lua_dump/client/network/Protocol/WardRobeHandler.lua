local NetManager = require("client.network.comm.NetManager")
local WardRobeHandler = {}
local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
local wardrobe_fashion_utils = require("client.slua.logic.wardrobe.fashionbag.wardrobe_fashion_utils")
function WardRobeHandler.send_depot_put_on_req(insID, extra)
  log(bWriteLog and "WardRobeHandler.send_depot_put_on_req insID = " .. insID)
  local logic_package_send_control = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_package_send_control)
  if not logic_package_send_control:CanSendPackage("depot_put_on_req", true) then
    log(bWriteLog and "WardRobeHandler.send_depot_put_on_req limit")
    return
  end
  logic_package_send_control:MarkSendPackage("depot_put_on_req")
  NetManager.SendPkg(1988771047, insID, extra)
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  if WardrobeLogicManager:GetWardrobeEditMode() ~= wardrobe_macro.EWardrobeEditMode.None and wardrobe_fashion_utils.CanBeShared(insID) then
    WardRobeHandler.send_shared_backpack_put_on_req(insID)
  end
  local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
  if PlanPH_GamePlay_Tools.IsLocalBoot() then
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local itemData = wardrobe_data:GetHallDepotItemDataByInsID(insID)
    local item = {
      res_id = itemData.resID,
      count = itemData.count
    }
    local olditem
    local index = 1
    local oldinstid = 0
    WardRobeHandler.on_depot_put_on_rsp("ok", item, olditem, index, insID, oldinstid)
  end
end
function WardRobeHandler.on_depot_put_on_rsp(res, item, olditem, index, instid, oldinstid, extra)
  log_format("WardRobeHandler.on_depot_put_on_rsp res = %s, index = %s, instid = %s, oldinstid = %s", res, index, instid, oldinstid)
  log_tree("item = ", item)
  log_tree("olditem = ", olditem)
  if item and instid then
    item.  end
  if olditem and oldinstid then
    olditem.instid = oldinstid
  end
  local wardrobeLogic = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  wardrobeLogic:on_puton_rsp(res, item, olditem, index, extra)
  local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
  if PlanPH_GamePlay_Tools.IsLocalBoot() then
    local MainCity_Depot_Client_Handler = require("GameLua.Mod.MainCity.Client.Handler.MainCity_Depot_Client_Handler")
    MainCity_Depot_Client_Handler.send_maincity_depot_put_on_req(instid, item.res_id, item.count)
  end
end
function WardRobeHandler.send_depot_put_down_req(insID)
  log(bWriteLog and "WardRobeHandler.send_depot_put_down_req insID = " .. insID)
  local logic_package_send_control = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_package_send_control)
  if not logic_package_send_control:CanSendPackage("depot_put_down_req", true) then
    log(bWriteLog and "WardRobeHandler.send_depot_put_down_req limit")
    return
  end
  logic_package_send_control:MarkSendPackage("depot_put_down_req")
  NetManager.SendPkg(512199271, insID)
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  if WardrobeLogicManager:GetWardrobeEditMode() ~= wardrobe_macro.EWardrobeEditMode.None and wardrobe_fashion_utils.CanBeShared(insID) then
    WardRobeHandler.send_shared_backpack_put_down_req(insID)
  end
  local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
  if PlanPH_GamePlay_Tools.IsLocalBoot() then
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local itemData = wardrobe_data:GetHallDepotItemDataByInsID(insID)
    local item = {
      res_id = itemData.resID,
      count = itemData.count
    }
    WardRobeHandler.on_depot_put_down_rsp("ok", item, insID)
  end
end
function WardRobeHandler.on_depot_put_down_rsp(res, item, instid)
  log(bWriteLog and "WardRobeHandler.on_depot_put_down_rsp res = " .. res .. ", instid = " .. tostring(instid))
  log_tree("item = ", item)
  if item and instid then
    item.  end
  local wardrobeLogic = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  wardrobeLogic:on_putdown_rsp(res, item)
  local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
  if PlanPH_GamePlay_Tools.IsLocalBoot() then
    local MainCity_Depot_Client_Handler = require("GameLua.Mod.MainCity.Client.Handler.MainCity_Depot_Client_Handler")
    MainCity_Depot_Client_Handler.send_maincity_depot_put_down_req(instid, item.res_id, item.count)
  end
end
function WardRobeHandler.send_get_all_skin_list(client_data)
  NetManager.SendPkg(1547223713, client_data)
end
function WardRobeHandler.on_get_weapon_skin_list_rsp(client_data, errorCode, rsp_list)
  local ArmorySystem = require("client.logic.armory.logic_armory")
  ArmorySystem.get_weapon_skin_list_rsp(client_data, errorCode, rsp_list)
end
function WardRobeHandler.send_get_avatar_box_list()
  NetManager.SendPkg(1509401454)
end
function WardRobeHandler.on_get_avatar_box_list_rsp(ok, list, cur_avatar_box_id)
  local RoleInfoAvatarFrameSystem = require("client.slua.logic.roleInfo.logic_RoleInfoAvatarFrame")
  RoleInfoAvatarFrameSystem.get_avatar_box_list_rsp(ok, list, cur_avatar_box_id)
end
function WardRobeHandler.send_get_item_decompose_info(list)
  NetManager.SendPkg(738526078, list)
end
function WardRobeHandler.on_get_item_decompose_info_rsp(res, list)
  local logic_decompose = require("client.logic.decompose.logic_decompose")
  logic_decompose.get_item_decompose_info_rsp(res, list)
end
function WardRobeHandler.on_notify_knapsack_chg_index(index, notify_knapsack_show_info)
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  local info = notify_knapsack_show_info
  HallThemeUtils.proc_skin_list_chg("weapon_skin", info.weapon_id_show, info.weapon_skin_show, index, info.ext_info)
  fashionbag_data:SetHeadShow(info.head_show or 0, index)
  if not info.is_trigger_by_user then
    local fashionbag_logic = require("client.slua.logic.wardrobe.fashionbag.fashionbag_logic")
    fashionbag_logic:on_select_use_rolewear_rsp(NetErrorCode_NONE, index, info.pspace_rolewear_index)
  end
end
function WardRobeHandler.send_depot_set_head_show_req(insID)
  log(bWriteLog and "send_depot_set_head_show_req : " .. tostring(insID))
  NetManager.SendPkg(1212123099, insID)
end
function WardRobeHandler.on_depot_set_head_show_rsp(err_code, id)
end
function WardRobeHandler.send_use_item(instID, count, params)
  if instID ~= "" and 0 < count then
    instID = tonumber(instID)
    local INT64_MAX = 9223372036854775807
    local INT64_MIN = -9223372036854775808
    if not Client.IsShipping() and instID and (instID > INT64_MAX or instID < INT64_MIN) then
      local utility = require("common.utility")
      utility.ErrorMessageHandler("WardRobeHandler.send_use_item, instID is " .. instID)
    end
    NetManager.SendPkg(1238013580, instID, count, params)
  end
end
function WardRobeHandler.on_use_item_rsp(res, itemData, params)
  local wardrobeLogic = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  wardrobeLogic:on_use_item_rsp(res, itemData, params)
end
function WardRobeHandler.send_equip_motion_req(instid, dst_slot)
  instid = tostring(instid)
  NetManager.SendPkg(176171431, instid, dst_slot)
end
function WardRobeHandler.on_equip_motion_rsp(result, slot, item, old_item)
  if result == NetErrorCode_NONE then
  elseif tostring(result) == "9910138" then
    ShowNotice(6014)
  elseif result ~= nil then
    ShowNotice(result)
  end
end
function WardRobeHandler.send_unequip_motion_req(instid, slot)
  NetManager.SendPkg(102989895, instid, slot)
end
function WardRobeHandler.on_unequip_motion_rsp(result, slot, old_item)
  if result == NetErrorCode_NONE then
  elseif result ~= nil then
    ShowNotice(result)
  end
end
function WardRobeHandler.send_exchange_motion_req(src_slot, dst_slot)
  NetManager.SendPkg(838246995, src_slot, dst_slot)
end
function WardRobeHandler.on_exchange_motion_rsp(result, src_item, dst_item)
  if result == NetErrorCode_NONE then
  elseif result ~= nil then
    ShowNotice(result)
  end
end
function WardRobeHandler.send_select_use_rolewear(index)
  local gem_report_utils = require("client.logic.store.gem_report_utils")
  index = tonumber(index)
  NetManager.SendPkg(1872657140, index)
  gem_report_utils.ReportBtnClickEvent(gem_report_utils.SubEventName_Wardrobe_Knapsack .. tostring(index))
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.Wardrobe_Knapsack, 0, tostring(index))
end
function WardRobeHandler.on_select_use_rolewear_rsp(res, index, pspace_rolewear_index)
  local fashionbag_logic = require("client.slua.logic.wardrobe.fashionbag.fashionbag_logic")
  fashionbag_logic:on_select_use_rolewear_rsp(res, index, pspace_rolewear_index)
end
function WardRobeHandler.send_unlock_rolewear(index, change_idx)
  index = tonumber(index)
  if change_idx ~= nil then
    log(bWriteLog and "WardRobeHandler.send_unlock_rolewear index:" .. index .. " change_idx:" .. change_idx)
    change_idx = tonumber(change_idx)
  else
    log(bWriteLog and "WardRobeHandler.send_unlock_rolewear index:" .. index)
  end
  if index == 3 then
    local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
    if QRcodeRestrictManager:CheckUCRestrict() then
      return
    end
  end
  NetManager.SendPkg(1146308804, index, change_idx)
end
function WardRobeHandler.on_unlock_rolewear_rsp(res, index, change_idx, timestamp)
  log_format(bWriteLog and "WardRobeHandler.on_unlock_rolewear_rsp res:%s, index:%s, change_idx:%s, timestamp:%s", tostring(res), tostring(index), tostring(change_idx), tostring(timestamp))
  local fashionbag_logic = require("client.slua.logic.wardrobe.fashionbag.fashionbag_logic")
  fashionbag_logic:on_unlock_rolewear_rsp(res, index, change_idx, timestamp)
end
function WardRobeHandler.send_on_item_compose(instid, count)
  NetManager.SendPkg(1351345308, instid, count)
end
function WardRobeHandler.on_on_item_compose_rsp(res, item_list)
  log_tree("item_list", item_list)
  if res == NetErrorCode_NONE then
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle(item_list)
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_ITEM_COMPOSE)
    EventSystem:postEvent(EVENTTYPE_SHOP, EVENTID_SUPPLY_REF_PRICE)
  else
    ShowNotice(res)
  end
end
function WardRobeHandler.send_depot_set_skin_info_req(bag, helmet)
  local level = {}
  level.bag_level = bag
  level.helmet_level = helmet
  bag = level
  NetManager.SendPkg(1695792499, bag, helmet)
  log_tree("WardRobeHandler.send_depot_set_skin_info_req ", level)
end
function WardRobeHandler.on_depot_set_skin_info_rsp(error_code, skin_info)
  local wardrobeLogic = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  wardrobeLogic:on_depot_set_skin_info_rsp(error_code, skin_info)
end
function WardRobeHandler.on_update_rolewear_state(rolewear_state, rolewear, use_rolewear, all_knapsack_ext_info, pspace_rolewear_index)
  local fashionbag_logic = require("client.slua.logic.wardrobe.fashionbag.fashionbag_logic")
  fashionbag_logic:on_update_rolewear_state(rolewear_state, rolewear, use_rolewear, all_knapsack_ext_info, pspace_rolewear_index)
end
function WardRobeHandler.on_notify_depot_item_change(changelist)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  wardrobe_data:OnHallDepotDataNotify(changelist)
end
function WardRobeHandler.send_depot_batch_put_down_req(instid_list)
  NetManager.SendPkg(2043709095, instid_list)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  for _, insId in ipairs(instid_list) do
    local itemData = wardrobe_data:GetHallDepotItemDataByInsID(insId)
    if itemData then
      local golden_suit_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.golden_suit_module)
      golden_suit_module:ModifyVehicleWhenPutOff(itemData)
    end
  end
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  if WardrobeLogicManager:GetWardrobeEditMode() ~= wardrobe_macro.EWardrobeEditMode.None then
    for i, insID in pairs(instid_list) do
      if wardrobe_fashion_utils.CanBeShared(insID) then
        WardRobeHandler.send_shared_backpack_put_down_req(insID)
      end
    end
  end
end
function WardRobeHandler.on_depot_batch_put_down_rsp(res, item_list, instid_list)
  log(bWriteLog and "WardRobeHandler.on_depot_batch_put_down_rsp res:" .. res)
  log_tree("WardRobeHandler.on_depot_batch_put_down_rsp item_list:", item_list)
  if res == NetErrorCode_NONE then
    for k, item in ipairs(item_list) do
      if item and instid_list and instid_list[k] then
        item.instid = instid_list[k]
      end
      local wardrobeLogic = require("client.slua.logic.wardrobe.logic_wardrobe_new")
      wardrobeLogic:on_putdown_rsp(res, item)
    end
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_BATCH_PUTDOWN, item_list)
  else
    ShowNotice(res)
  end
end
function WardRobeHandler.send_get_plating_req()
  NetManager.SendPkg(649491291)
end
function WardRobeHandler.on_get_plating_rsp(list, pos_count)
  log_tree("WardRobeHandler.on_get_plating_rsp list:", list)
  log(bWriteLog and string.format("WardRobeHandler.on_get_plating_rsp pos_count : %s", pos_count))
  local logic_wardrobe_plating = require("client.slua.logic.wardrobe.logic_wardrobe_plating")
  logic_wardrobe_plating:on_get_plating_rsp(list, pos_count)
end
function WardRobeHandler.send_set_plating_req(pos, inst_id)
  local logic_package_send_control = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_package_send_control)
  if not logic_package_send_control:CanSendPackage("set_plating_req", true) then
    log(bWriteLog and "WardRobeHandler.send_set_plating_req limit")
    return
  end
  logic_package_send_control:MarkSendPackage("set_plating_req")
  NetManager.SendPkg(1072851979, pos, inst_id)
end
function WardRobeHandler.on_set_plating_rsp(err_code, pos, old_inst_id, new_inst_id)
  log(bWriteLog and string.format("WardRobeHandler.on_set_plating_rsp err_code:%s pos:%s old_inst_id:%s new_inst_id:%s", err_code, pos, old_inst_id, new_inst_id))
  if err_code == 5 then
    local logic_wardrobe_plating = require("client.slua.logic.wardrobe.logic_wardrobe_plating")
    logic_wardrobe_plating:RequestPlatingInfo()
  end
end
function WardRobeHandler.send_depot_batch_put_on_req(instid_list, pu_on_extra)
  log_tree("WardRobeHandler.send_depot_batch_put_on_req instid_list:", instid_list)
  log_tree("WardRobeHandler.send_depot_batch_put_on_req pu_on_extra:", pu_on_extra)
  if not instid_list or #instid_list == 0 then
    print(bWriteLog and "WardRobeHandler:send_depot_batch_put_on_req - Invalid instid_list")
    return
  end
  NetManager.SendPkg(282763943, instid_list, pu_on_extra)
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  if WardrobeLogicManager:GetWardrobeEditMode() ~= wardrobe_macro.EWardrobeEditMode.None then
    for i, insID in pairs(instid_list) do
      if wardrobe_fashion_utils.CanBeShared(insID) then
        WardRobeHandler.send_shared_backpack_put_on_req(insID)
      end
    end
  end
end
function WardRobeHandler.on_depot_batch_put_on_rsp(res, item_list, pu_on_extra)
  if res == NetErrorCode_NONE then
    log_tree("WardRobeHandler.on_depot_batch_put_on_rsp item_list:", item_list)
    log_tree("WardRobeHandler.on_depot_batch_put_on_rsp pu_on_extra:", pu_on_extra)
    for _, item in ipairs(item_list) do
      if item.new and item.new_inst then
        item.new.instid = item.new_inst
      end
      if item.old and item.old_inst then
        item.old.instid = item.old_inst
      end
      local wardrobeLogic = require("client.slua.logic.wardrobe.logic_wardrobe_new")
      wardrobeLogic:on_puton_rsp(res, item.new, item.old, nil, pu_on_extra)
    end
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_BATCH_PUTON, item_list)
  else
    ShowNotice(res)
  end
end
function WardRobeHandler.send_set_show_info_req(set_list)
  log(bWriteLog and "WardRobeHandler.send_set_show_info_req")
  log_tree("set_list = ", set_list)
  NetManager.SendPkg(405159263, set_list)
end
function WardRobeHandler.on_set_show_info_rsp(error_code, set_list)
  log(bWriteLog and "WardRobeHandler.on_set_show_info_rsp error_code = " .. error_code)
  log_tree("set_list = ", set_list)
  if error_code ~= 0 then
    ShowNotice(error_code)
    return
  end
  local logic_display_setting = require("client.slua.logic.wardrobe.logic_display_setting")
  logic_display_setting.UpdateDepotShowSettings(set_list)
  EventSystem:postEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_SOCIAL_LOBBY_REFRESH_AVATAR)
end
function WardRobeHandler.send_set_item_expired_notified(records)
  NetManager.SendPkg(1511285693, records)
end
function WardRobeHandler.send_put_on_weapon_wear(client_data, weapon_id, extra_weapon_id_list)
  log(bWriteLog and "WardRobeHandler.send_put_on_weapon_wear " .. tostring(weapon_id))
  NetManager.SendPkg(382030028, client_data, weapon_id, extra_weapon_id_list)
end
function WardRobeHandler.on_put_on_weapon_wear_rsp(client_data, res, weapon_id, new_skin_id, ext_weapon_info)
  local wardrobeLogicGun = require("client.slua.logic.wardrobe.logic_wardrobe_gun")
  wardrobeLogicGun:on_put_on_weapon_wear_rsp(client_data, res, weapon_id, new_skin_id, ext_weapon_info)
end
function WardRobeHandler.send_pspace_put_on_weapon_wear(client_data, weapon_id, extra_weapon_id_list)
  log(bWriteLog and "WardRobeHandler.send_put_on_weapon_wear " .. tostring(weapon_id))
  NetManager.SendPkg(908257422, client_data, weapon_id, extra_weapon_id_list)
end
function WardRobeHandler.on_pspace_put_on_weapon_wear_rsp(client_data, res, weapon_id, pspace_wear_idex)
  local wardrobeLogicGun = require("client.slua.logic.wardrobe.logic_wardrobe_gun")
end
function WardRobeHandler.send_equip_holography_req(instid, dst_slot)
  NetManager.SendPkg(483952679, instid, dst_slot)
end
function WardRobeHandler.on_equip_holography_rsp(err_code, new_holography_slot_list)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_wardrobe_holography = require("client.slua.logic.wardrobe.logic_wardrobe_holography")
  logic_wardrobe_holography:on_equip_holography_rsp(new_holography_slot_list)
end
function WardRobeHandler.send_get_holography_equip_slot_req()
  NetManager.SendPkg(50108811)
end
function WardRobeHandler.on_get_holography_equip_slot_rsp(holography_slot_list)
  if holography_slot_list then
    local logic_wardrobe_holography = require("client.slua.logic.wardrobe.logic_wardrobe_holography")
    logic_wardrobe_holography:on_get_holography_equip_slot_rsp(holography_slot_list)
  else
    log_warning("WardRobeHandler.on_get_holography_equip_slot_rsp: no data")
  end
end
function WardRobeHandler.send_shared_backpack_unlocked_req()
  log(bWriteLog and " WardRobeHandler.send_shared_backpack_unlocked_req")
  NetManager.SendPkg(1339010407)
end
function WardRobeHandler.on_shared_backpack_unlocked_rsp(res, uid, intimValue)
  print(bWriteLog and string.format(" WardRobeHandler.on_shared_backpack_unlocked_rsp res:%s, uid:%s, intimValue:%s", res, uid, intimValue))
  if res then
    EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_SHARED_BAG_RSP, uid, intimValue)
  end
end
function WardRobeHandler.send_get_shared_backpack_info_req()
  log(bWriteLog and " WardRobeHandler.send_get_shared_backpack_info_req")
  NetManager.SendPkg(1326667751)
end
function WardRobeHandler.on_get_shared_backpack_info_rsp(res, data, times)
  if data then
    print(bWriteLog and string.format(" WardRobeHandler.on_get_shared_backpack_info_rsp res:%s, #data:%s, times:%s", res, #data, times))
    log_tree(" WardRobeHandler.on_get_shared_backpack_info_rsp", data)
  else
    print(bWriteLog and string.format(" WardRobeHandler.on_get_shared_backpack_info_rsp res:%s", res))
  end
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SHARED_BACKPACK_INFO_RSP, res)
  fashionbag_data:UpdateSharedBag(data, res, times)
end
function WardRobeHandler.send_shared_backpack_put_on_req(instid)
  log(bWriteLog and " WardRobeHandler.send_shared_backpack_put_on_req instid:" .. instid)
  NetManager.SendPkg(2092197895, instid)
end
function WardRobeHandler.on_shared_backpack_put_on_rsp(err_code)
  log(bWriteLog and string.format(" WardRobeHandler.on_shared_backpack_put_on_rsp err_code:%s", err_code))
end
function WardRobeHandler.send_shared_backpack_put_down_req(instid)
  log(bWriteLog and " WardRobeHandler.send_shared_backpack_put_down_req instid:" .. instid)
  NetManager.SendPkg(1714684903, instid)
end
function WardRobeHandler.on_shared_backpack_put_down_rsp(err_code)
  log(bWriteLog and string.format(" WardRobeHandler.on_shared_backpack_put_down_rsp err_code:%s", err_code))
end
function WardRobeHandler.send_shared_backpack_batch_put_on_req(instid_list)
  print(bWriteLog and " WardRobeHandler.send_shared_backpack_batch_put_on_req #instid_list:" .. #instid_list)
  WardRobeHandler.pending_  NetManager.SendPkg(597479463, instid_list)
end
function WardRobeHandler.on_shared_backpack_batch_put_on_rsp(err_code)
  print(bWriteLog and string.format(" WardRobeHandler.on_shared_backpack_batch_put_on_rsp err_code:%s", err_code))
  if err_code == "ok" then
    fashionbag_data:UpdateSharedBag(WardRobeHandler.pending_instid_list)
  end
  WardRobeHandler.pending_instid_list = nil
end
function WardRobeHandler.send_set_teamup_action_type_req(action_type)
  log(bWriteLog and string.format("WardRobeHandler.send_set_teamup_action_type_req. action_type=%s", tostring(action_type)))
  NetManager.SendPkg(460715367, action_type)
end
function WardRobeHandler.on_set_teamup_action_type_rsp(err_code, action_type)
  log(bWriteLog and string.format("WardRobeHandler.on_set_teamup_action_type_rsp. err_code=%s, action_type=%s", tostring(err_code), tostring(action_type)))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_display_setting = require("client.slua.logic.wardrobe.logic_display_setting")
  logic_display_setting.UpdateTeamUpActionSetting(action_type)
end
function WardRobeHandler.send_set_mvp_action_type_req(action_type)
  log(bWriteLog and string.format("WardRobeHandler.send_set_mvp_action_type_req. action_type=%s", tostring(action_type)))
  NetManager.SendPkg(1629943675, action_type)
end
function WardRobeHandler.on_set_mvp_action_type_rsp(err_code, action_type)
  log(bWriteLog and string.format("WardRobeHandler.on_set_mvp_action_type_rsp. err_code=%s, action_type=%s", tostring(err_code), tostring(action_type)))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_display_setting = require("client.slua.logic.wardrobe.logic_display_setting")
  logic_display_setting.UpdateMVPActionSetting(action_type)
end
function WardRobeHandler.send_get_shared_backpack_config_info_req(shared_type)
  NetManager.SendPkg(547751079, shared_type)
end
function WardRobeHandler.on_get_shared_backpack_config_info_rsp(err_code, shared_type, shared_items_info)
  log(bWriteLog and "WardRobeHandler.on_get_shared_backpack_config_info_rsp")
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_share_bag_privilege_util = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_share_bag_privilege_util)
  logic_share_bag_privilege_util:on_get_shared_backpack_config_info_rsp(shared_type, shared_items_info)
end
function WardRobeHandler.send_shared_backpack_batch_config_item_req(shared_type, instid_list)
  NetManager.SendPkg(1975731275, shared_type, instid_list)
end
function WardRobeHandler.on_shared_backpack_batch_config_item_rsp(err_code, shared_type, shared_items_info)
  log(bWriteLog and "WardRobeHandler.on_shared_backpack_batch_config_item_rsp")
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_share_bag_privilege_util = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_share_bag_privilege_util)
  logic_share_bag_privilege_util:on_shared_backpack_batch_config_item_rsp(shared_type, shared_items_info)
end
function WardRobeHandler.send_shared_backpack_select_item_req(shared_uid, shared_type, item_list)
  log(bWriteLog and string.format("[share_bag_priv]  WardRobeHandler.send_shared_backpack_select_item_req, shared_uid: %s, self: %s", tostring(shared_uid), tostring(DataMgr.roleData.uid)))
  NetManager.SendPkg(382807879, shared_uid, shared_type, item_list)
end
function WardRobeHandler.on_shared_backpack_select_item_rsp(err_code, shared_uid, shared_type, item_list)
  log(bWriteLog and "[share_bag_priv] WardRobeHandler.on_shared_backpack_select_item_rsp shared_uid: " .. tostring(shared_uid))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
end
function WardRobeHandler.send_get_shared_backpack_selected_item_info_req(shared_type)
  log(bWriteLog and string.format("WardRobeHandler.send_get_shared_backpack_selected_item_info_req. shared_type=%s", tostring(shared_type)))
  NetManager.SendPkg(1905941895, shared_type)
end
function WardRobeHandler.on_get_shared_backpack_selected_item_info_rsp(err_code, shared_type, use_uid, use_times, slected_item_list, max_use_times)
  log(bWriteLog and string.format("WardRobeHandler.on_get_shared_backpack_selected_item_info_rsp. err_code=%s, shared_type=%s, use_uid=%s, use_times=%s, slected_item_list=%s, max_use_times=%s", tostring(err_code), tostring(shared_type), tostring(use_uid), tostring(use_times), tostring(slected_item_list), tostring(max_use_times)))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_share_bag_team_util = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_share_bag_team_util)
  local share_bag_macros = require("client.slua.logic.share_bag.share_bag_macros")
  logic_share_bag_team_util:SetRemainUseTimes(share_bag_macros.ShareType2ShareItemTypeMap[shared_type], use_times, max_use_times)
end
function WardRobeHandler.on_team_update_shared_backpack(shared_uid, shared_type, shared_items_info, selected_uid, flag)
  log(bWriteLog and "WardRobeHandler.on_team_update_shared_backpack shared_uid: " .. tostring(shared_uid))
  local logic_share_bag_team_util = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_share_bag_team_util)
  logic_share_bag_team_util:CheckShowShareeBagUsingTips(shared_uid, shared_type, shared_items_info, selected_uid)
  local bOffline = flag == 1
  logic_share_bag_team_util:UpdateShareBagsInfo(shared_uid, shared_type, shared_items_info, bOffline)
end
function WardRobeHandler.send_get_shared_backpack_table_params_req()
  NetManager.SendPkg(1707771246)
end
function WardRobeHandler.on_get_shared_backpack_params_rsp(err_code, params)
  if err_code ~= 0 then
    return
  end
  log_tree("WardRobeHandler.on_get_shared_backpack_params_rsp ", params)
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  WardrobeLogicManager:SetSharedBackpackParams(params)
end
function WardRobeHandler.on_shared_backpack_selected_item_info_notify(shared_type, use_uid, use_times, selected_item_list, max_use_times, reason)
end
function WardRobeHandler.send_effect_motion_setting_req(show_effect)
  NetManager.SendPkg(724719231, show_effect)
end
function WardRobeHandler.on_effect_motion_setting_rsp(err_code, flag)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local LogicParticleEmote = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicParticleEmote)
  LogicParticleEmote:on_effect_motion_setting_rsp(flag)
end
function WardRobeHandler.send_effect_motion_levelup_req(action_id, ins_id)
  NetManager.SendPkg(926498291, action_id, ins_id)
end
function WardRobeHandler.on_effect_motion_levelup_rsp(err_code, action_id, level)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local LogicParticleEmote = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicParticleEmote)
  LogicParticleEmote:on_effect_motion_levelup_rsp(action_id, level)
end
function WardRobeHandler.send_set_xsuit_glide_req(resid, flag)
  log(bWriteLog and "[XSuitGlide] send_set_xsuit_glide_req resid:" .. tostring(resid) .. " flag:" .. tostring(flag))
  NetManager.SendPkg(1710386307, resid, flag)
end
function WardRobeHandler.on_set_xsuit_glide_rsp(err_code, resid, flag)
  log(bWriteLog and "[XSuitGlide] on_set_xsuit_glide_rsp err_code:" .. tostring(err_code) .. " resid:" .. tostring(resid) .. " flag:" .. tostring(flag))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local GlideSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.GlideSystem)
  GlideSystem:UpdateGlideSettingData(resid, flag)
end
function WardRobeHandler.send_get_shared_backpack_permission_info_req(shared_type)
  log(bWriteLog and "[share_bag_priv] WardRobeHandler.send_get_shared_backpack_permission_info_req shared_type: " .. shared_type)
  NetManager.SendPkg(501833067, shared_type)
end
function WardRobeHandler.on_get_shared_backpack_permission_info_rsp(err_code, shared_type, grant_permission, granted_permission)
  log(bWriteLog and "[share_bag_priv] WardRobeHandler.on_get_shared_backpack_permission_info_rsp err_code: " .. err_code)
  local logic_share_bag_privilege_util = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_share_bag_privilege_util)
  if not logic_share_bag_privilege_util:IsAnyShardBagValid() then
    return
  end
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  if shared_type == 1 or shared_type == 2 then
    local logic_share_bag_team_util = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_share_bag_team_util)
    logic_share_bag_team_util:UpdateShareBagPrivilige(grant_permission, granted_permission)
  end
end
function WardRobeHandler.send_grant_shared_backpack_permission_req(shared_type, other_uid)
  log(bWriteLog and "[share_bag_priv] WardRobeHandler.send_grant_shared_backpack_permission_req shared_type: " .. shared_type .. " other_uid: " .. tonumber(other_uid))
  NetManager.SendPkg(1104786087, shared_type, other_uid)
end
function WardRobeHandler.on_grant_shared_backpack_permission_rsp(err_code, shared_type, other_uid)
  log(bWriteLog and "[share_bag_priv] WardRobeHandler.on_grant_shared_backpack_permission_rsp err_code: " .. err_code)
  local logic_share_bag_privilege_util = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_share_bag_privilege_util)
  if not logic_share_bag_privilege_util:IsAnyShardBagValid() then
    return
  end
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  if shared_type == 1 or shared_type == 2 then
    local logic_share_bag_team_util = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_share_bag_team_util)
    logic_share_bag_team_util:GiveShareBagPriviligeUID(other_uid)
  end
end
function WardRobeHandler.on_shared_backpack_permission_info_notify(shared_type, shared_uid, grant_permission, granted_permission)
  log(bWriteLog and "[share_bag_priv] WardRobeHandler.on_shared_backpack_permission_info_notify shared_uid: " .. tostring(shared_uid))
  local logic_share_bag_privilege_util = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_share_bag_privilege_util)
  if not logic_share_bag_privilege_util:IsAnyShardBagValid() then
    return
  end
  if shared_type == 1 or shared_type == 2 then
    local logic_share_bag_team_util = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_share_bag_team_util)
    if not shared_uid then
      logic_share_bag_team_util:UpdateShareBagPrivilige(grant_permission, granted_permission)
    else
      logic_share_bag_team_util:RecvShareBagPriviligeUID(shared_uid)
    end
  end
end
function WardRobeHandler.send_check_buy_item_type_req(res_id)
  NetManager.SendPkg(2049905491, res_id)
end
function WardRobeHandler.on_check_buy_item_type_rsp(res)
  local LogicParticleEmote = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicParticleEmote)
  LogicParticleEmote:CheckBuyItemTypeRsp(res == 0)
end
function WardRobeHandler.send_get_shared_backpack_guide_status_req(shared_type)
  log(bWriteLog and "WardRobeHandler.send_get_shared_backpack_guide_status_req shared_type: " .. tostring(shared_type))
  NetManager.SendPkg(1610768231, shared_type)
end
function WardRobeHandler.on_get_shared_backpack_guide_status_rsp(err_code, shared_type, status_table)
  log(bWriteLog and string.format("WardRobeHandler.on_get_shared_backpack_guide_status_rsp err_code: %s, shared_type: %s", tostring(err_code), tostring(shared_type)))
  log_tree("on_get_shared_backpack_guide_status_rsp status_table", status_table)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_share_bag_guide = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_share_bag_guide)
  logic_share_bag_guide:OnGetShareBagTipsDataRsp(shared_type, status_table)
end
function WardRobeHandler.send_set_shared_backpack_guide_status_req(shared_type, guide_type, status)
  log(bWriteLog and string.format("WardRobeHandler.send_set_shared_backpack_guide_status_req shared_type: %s, guide_type: %s, status: %s", tostring(shared_type), tostring(guide_type), tostring(status)))
  NetManager.SendPkg(1137756263, shared_type, guide_type, status)
end
function WardRobeHandler.on_set_shared_backpack_guide_status_rsp(err_code, shared_type, guide_type, status)
  log(bWriteLog and string.format("WardRobeHandler.on_set_shared_backpack_guide_status_rsp err_code: %s, shared_type: %s, guide_type: %s, status: %s", tostring(err_code), tostring(shared_type), tostring(guide_type), tostring(status)))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_share_bag_guide = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_share_bag_guide)
  logic_share_bag_guide:OnSetShareBagTipsDataRsp(shared_type, guide_type, status)
end
function WardRobeHandler.send_change_depot_tag_name_req(tag_list)
  NetManager.SendPkg(1190500691, tag_list)
end
function WardRobeHandler.on_change_depot_tag_name_rsp(err_code, tag_list)
  log(bWriteLog and "WardRobeHandler.on_change_depot_tag_name_rsp. " .. tostring(err_code))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_wardrobe_tag_mgr = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_wardrobe_tag_mgr)
  logic_wardrobe_tag_mgr:RspSetItemName(tag_list)
end
function WardRobeHandler.send_set_res_tag_req(resid, add_tag_list, del_tag_list)
  NetManager.SendPkg(361884267, resid, add_tag_list, del_tag_list)
end
function WardRobeHandler.on_set_res_tag_rsp(err_code, resid, add_tag_list, del_tag_list)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_wardrobe_tag_mgr = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_wardrobe_tag_mgr)
  logic_wardrobe_tag_mgr:RspSetItemTag(resid, add_tag_list, del_tag_list)
end
function WardRobeHandler.send_query_depot_tag_req()
  NetManager.SendPkg(237494691)
end
function WardRobeHandler.on_query_depot_tag_rsp(err_code, depot_tag_list)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_wardrobe_tag_mgr = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_wardrobe_tag_mgr)
  logic_wardrobe_tag_mgr:RspQueryDepotTag(depot_tag_list)
end
function WardRobeHandler.send_put_on_weapon_pendant_req(skin_ins_id, pendant_ins_id)
  NetManager.SendPkg(750165895, skin_ins_id, pendant_ins_id)
end
function WardRobeHandler.on_put_on_weapon_pendant_rsp(retcode, skin_ins_id, pendant_ins_id, old_pendant_ins_id)
  local logic_weapon_pendant = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_weapon_pendant)
  logic_weapon_pendant:on_put_on_weapon_pendant_rsp(retcode, skin_ins_id, pendant_ins_id, old_pendant_ins_id)
end
function WardRobeHandler.send_put_off_weapon_pendant_req(skin_ins_id, pendant_ins_id)
  NetManager.SendPkg(937681383, skin_ins_id, pendant_ins_id)
end
function WardRobeHandler.on_put_off_weapon_pendant_rsp(retcode, skin_ins_id, pendant_ins_id)
  local logic_weapon_pendant = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_weapon_pendant)
  logic_weapon_pendant:on_put_off_weapon_pendant_rsp(retcode, skin_ins_id, pendant_ins_id)
end
function WardRobeHandler.send_get_all_weapon_pendant_req()
  NetManager.SendPkg(921255623)
end
function WardRobeHandler.on_get_all_weapon_pendant_rsp(ret_code, weapon_pendants)
  local logic_weapon_pendant = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_weapon_pendant)
  logic_weapon_pendant:on_get_all_weapon_pendant_rsp(ret_code, weapon_pendants)
end
function WardRobeHandler.send_get_gold_cloth_bind_info_req()
  NetManager.SendPkg(1284698599)
end
function WardRobeHandler.on_get_gold_cloth_bind_info_rsp(err_code, bind_info_table, unlock_state)
  log(bWriteLog and string.format("WardRobeHandler.on_get_gold_cloth_bind_info_rsp. err_code=%s, bind_info_table=%s, unlock_state=%s", tostring(err_code), tostring(bind_info_table), tostring(unlock_state)))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_suit_multi_shape = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_suit_multi_shape)
  logic_suit_multi_shape:on_get_gold_cloth_bind_info_rsp(bind_info_table, unlock_state)
end
function WardRobeHandler.send_put_on_gold_dress_bind_req(inst_id, head_inst_id)
  log(bWriteLog and string.format("WardRobeHandler.send_put_on_gold_dress_bind_req. inst_id=%s, head_inst_id=%s", tostring(inst_id), tostring(head_inst_id)))
  NetManager.SendPkg(1375221447, inst_id, head_inst_id)
end
function WardRobeHandler.on_put_on_gold_dress_bind_rsp(err_code, inst_id, head_inst_id, other_state)
  log(bWriteLog and string.format("WardRobeHandler.on_put_on_gold_dress_bind_rsp. err_code=%s, inst_id=%s, head_inst_id=%s", tostring(err_code), tostring(inst_id), tostring(head_inst_id)))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_suit_multi_shape = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_suit_multi_shape)
  logic_suit_multi_shape:on_put_on_gold_dress_bind_rsp(inst_id, head_inst_id)
  if other_state and next(other_state) then
    for other_state_inst_id, other_state_res_id in pairs(other_state) do
      if other_state_inst_id then
        logic_suit_multi_shape:on_put_on_gold_dress_bind_rsp(other_state_inst_id, head_inst_id, other_state_res_id)
      end
    end
  end
end
function WardRobeHandler.send_put_off_gold_dress_bind_req(inst_id)
  NetManager.SendPkg(1702002907, inst_id)
end
function WardRobeHandler.on_put_off_gold_dress_bind_rsp(err_code, inst_id, other_state)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_suit_multi_shape = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_suit_multi_shape)
  logic_suit_multi_shape:on_put_off_gold_dress_bind_rsp(inst_id)
  if other_state and next(other_state) then
    for other_state_inst_id, _ in pairs(other_state) do
      if other_state_inst_id then
        logic_suit_multi_shape:on_put_off_gold_dress_bind_rsp(other_state_inst_id)
      end
    end
  end
end
function WardRobeHandler.send_take_car_page_award_req()
  NetManager.SendPkg(1144947219)
end
function WardRobeHandler.on_take_car_page_award_rsp(retcode)
  if retcode ~= 0 then
    ShowNotice(retcode)
    return
  end
  local itemData = {
    res_id = ENUM_HALLTHEME_ID.GarageTheme,
    count = 1,
    valid_hours = 0,
    expire_ts = 0,
    color_id = 0,
    pattern_id = 0
  }
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle({itemData})
  local GarageThemeSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.GarageThemeSystem)
  GarageThemeSystem:IsHaveThemeCanCollect()
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_RECEIVED_GARAGE)
end
function WardRobeHandler.send_get_xsuit_glide_req()
  NetManager.SendPkg(1476600371)
end
function WardRobeHandler.on_get_xsuit_glide_rsp(err_code, settings)
  if err_code ~= 0 then
    ShowNotice(retcode)
    return
  end
  local GlideSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.GlideSystem)
  GlideSystem:UpdateGlideSetting(settings)
end
function WardRobeHandler.send_change_special_weapon_skin_req(weapon_id, instid)
  log(bWriteLog and string.format("WardRobeHandler.send_change_special_weapon_skin_req weapon_id = %s, instid = %s", weapon_id, instid))
  NetManager.SendPkg(1729770087, weapon_id, instid)
end
function WardRobeHandler.on_change_special_weapon_skin_rsp(ret_code, weapon_id, instid)
  log(bWriteLog and string.format("WardRobeHandler.on_change_special_weapon_skin_rsp ret_code = %s, weapon_id = %s, instid = %s", ret_code, weapon_id, instid))
  if ret_code == 0 then
    local wardrobeGunLogic = require("client.slua.logic.wardrobe.logic_wardrobe_gun")
    wardrobeGunLogic:on_change_special_weapon_skin_rsp(weapon_id, instid)
  elseif ret_code ~= nil then
    ShowNotice(ret_code)
  end
end
function WardRobeHandler.send_get_special_weapon_wear_info_req()
  NetManager.SendPkg(431491623)
end
function WardRobeHandler.on_get_special_weapon_wear_info_rsp(retcode, wear_info)
  log_tree("on_get_special_weapon_wear_info_rsp", wear_info)
  if retcode == 0 then
    local wardrobeGunLogic = require("client.slua.logic.wardrobe.logic_wardrobe_gun")
    wardrobeGunLogic:ResSpecialWeaponData(wear_info)
  elseif retcode ~= nil then
    ShowNotice(retcode)
  end
end
function WardRobeHandler.send_shared_backpack_select_item_v2_req(shared_uid, shared_list_info)
  if not (shared_uid and shared_list_info) or not next(shared_list_info) then
    log_error(bWriteLog and string.format("[share_bag][empty] WardRobeHandler.send_shared_backpack_select_item_v2_req error shared_uid=%s, shared_list_info=%s next(shared_list_info)=%s", tostring(shared_uid), tostring(shared_list_info), tostring(shared_list_info and next(shared_list_info))))
  end
  NetManager.SendPkg(408935175, shared_uid, shared_list_info)
end
function WardRobeHandler.on_shared_backpack_select_item_v2_rsp(err_code, shared_uid, all_shared_item_list)
  log(bWriteLog and "[share_bag_priv] WardRobeHandler.on_shared_backpack_select_item_v2_rsp shared_uid: " .. tostring(shared_uid))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
end
function WardRobeHandler.send_unlock_gold_dress_bind_req()
  log(bWriteLog and "WardRobeHandler.send_unlock_gold_dress_bind_req. ")
  NetManager.SendPkg(408926631)
end
function WardRobeHandler.on_unlock_gold_dress_bind_rsp(err_code)
  log(bWriteLog and string.format("WardRobeHandler.on_unlock_gold_dress_bind_rsp. err_code=%s", tostring(err_code)))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_suit_multi_shape = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_suit_multi_shape)
  logic_suit_multi_shape:on_unlock_gold_dress_bind_rsp()
end
function WardRobeHandler.send_metro_use_item(instID, count, params)
  NetManager.SendPkg(1713407596, instID, count, params)
end
function WardRobeHandler.on_metro_use_item_rsp(res, itemData, params)
  if res ~= 0 then
    ShowNotice(res)
  end
end
function WardRobeHandler.send_change_bind_relation_req(op_type, show_pos)
  NetManager.SendPkg(454104103, op_type, show_pos)
end
function WardRobeHandler.on_change_bind_relation_rsp(err_code, op_type, show_pos, depot_bind_relation)
  log(bWriteLog and string.format("WardRobeHandler.on_change_bind_relation_rsp %s %s", tostring(op_type), tostring(show_pos)))
  log_tree("on_change_bind_relation_rsp, depot_bind_relation", depot_bind_relation)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return true
  end
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  if not fashionbag_data:GetDepotBindRelation(show_pos) then
    local insID
    local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
    local useIndex = fashionbag_data:GetFashionBagUseIndex()
    local bagInfo = fashionbag_data:GetKnapsackExtInfoByIndex(useIndex)
    if show_pos == HallThemeUtils.CONST_RELATION_TYPE.BAG then
      insID = fashionbag_data:GetBagSkin()
      if not bagInfo.bag_skin_list then
        bagInfo.bag_skin_list = {}
      end
      for i = 1, 3 do
        fashionbag_data:SetBagSkinByLevel(insID, i)
        bagInfo.bag_skin_list[i] = insID
      end
    elseif show_pos == HallThemeUtils.CONST_RELATION_TYPE.HELMET then
      insID = fashionbag_data:GetHelmetSkin()
      local changeHeadShow = false
      if not bagInfo.helmet_skin_list then
        bagInfo.helmet_skin_list = {}
      end
      for i = 1, 3 do
        fashionbag_data:SetHelmetSkinByLevel(insID, i)
        if bagInfo.helmet_skin_list[i] == bagInfo.head_show then
          changeHeadShow = true
        end
        bagInfo.helmet_skin_list[i] = insID
      end
      if changeHeadShow then
        bagInfo.head_show = insID
      end
    end
    log(bWriteLog and "first set " .. tostring(show_pos) .. "  insID = ")
    HallThemeUtils.ProcSetSkinInfo({})
  elseif depot_bind_relation[show_pos] == HallThemeUtils.CONST_RELATION_OP_TYPE.BIND then
    local insID
    local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
    local useIndex = fashionbag_data:GetFashionBagUseIndex()
    local bagInfo = fashionbag_data:GetKnapsackExtInfoByIndex(useIndex)
    if show_pos == HallThemeUtils.CONST_RELATION_TYPE.BAG then
      HallThemeUtils.PutOffBag(useIndex)
      insID = fashionbag_data:GetBagSkinByLevel(fashionbag_data:GetBagLevel())
      for i = 1, 3 do
        fashionbag_data:SetBagSkinByLevel(insID, i)
        if bagInfo and bagInfo.bag_skin_list then
          bagInfo.bag_skin_list[i] = insID
        end
      end
      fashionbag_data:SetBagSkin(insID)
      HallThemeUtils.PutOnBag(useIndex)
    elseif show_pos == HallThemeUtils.CONST_RELATION_TYPE.HELMET then
      HallThemeUtils.PutOffBag(useIndex)
      insID = fashionbag_data:GetHelmetSkinByLevel(fashionbag_data:GetHelmetLevel())
      for i = 1, 3 do
        fashionbag_data:SetHelmetSkinByLevel(insID, i)
        if bagInfo and bagInfo.helmet_skin_list then
          bagInfo.helmet_skin_list[i] = insID
        end
      end
      bagInfo.head_show = insID
      fashionbag_data:SetHelmetSkin(insID)
      HallThemeUtils.PutOnBag(useIndex)
    end
    log(bWriteLog and "set from level 3 " .. tostring(show_pos) .. "  insID = ")
  end
  fashionbag_data:SetDepotBindRelationAll(depot_bind_relation)
end
function WardRobeHandler.send_get_item_jump_info_by_itemlist_req(item_list)
  NetManager.SendPkg(1192281095, item_list)
end
function WardRobeHandler.on_get_item_jump_info_by_itemlist_rsp(err_code, ret_tbl)
  log(bWriteLog and "WardRobeHandler.on_get_item_jump_info_by_itemlist_rsp. ")
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  if ret_tbl then
    log_tree("WardRobeHandler.on_get_item_jump_info_by_itemlist_rsp. ret_tbl:", ret_tbl)
  else
    log(bWriteLog and "WardRobeHandler.on_get_item_jump_info_by_itemlist_rsp. ret_tbl is nil")
  end
  local logic_suit_multi_shape = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_suit_multi_shape)
  logic_suit_multi_shape:on_get_item_jump_info_by_itemlist_rsp(ret_tbl)
end
function WardRobeHandler.send_use_plating_req(inst_id, count)
  NetManager.SendPkg(98535239, inst_id, count)
end
function WardRobeHandler.on_use_plating_rsp(err, inst_id, count)
  if err ~= 0 then
    ShowNotice(err)
    return
  end
  log(bWriteLog and "WardRobeHandler.on_use_plating_rsp " .. tostring(inst_id) .. " count = " .. tostring(count))
  EventSystem:postEvent(EVENTTYPE_LOBBY_PAINT, EVENTID_LOBBY_PAINT_USE, inst_id, count)
end
function WardRobeHandler.on_notify_plating_show(team_id, user_uid, resid)
  local logic_lobby_paint = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lobby_paint)
  logic_lobby_paint:on_notify_plating_show(team_id, user_uid, resid)
end
function WardRobeHandler.send_unlock_multi_color_req(target_item, unlock_item)
  NetManager.SendPkg(2034884679, target_item, unlock_item)
end
function WardRobeHandler.on_unlock_multi_color_rsp(err_code, unlock_item, target_item)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  EventSystem:postEvent(EVENTTYPE_COLOR_SHAPE, EVENTID_USE_UNLOCK_ITEM_UNLOCK_COLOR_SHAPE, target_item)
  local ItemGetModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.rare_item_get_module)
  ItemGetModule:ShowColorfulPanel(target_item)
end
function WardRobeHandler.send_batch_get_shared_backpack_selected_item_info_req(shared_type_list)
  NetManager.SendPkg(21526311, shared_type_list)
end
function WardRobeHandler.on_batch_get_shared_backpack_selected_item_info_rsp(err_code, shared_info)
  log(bWriteLog and string.format("WardRobeHandler.on_batch_get_shared_backpack_selected_item_info_rsp. err_code=%s, shared_info=%s", tostring(err_code), tostring(shared_info)))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  if not shared_info then
    return
  end
  local logic_share_bag_team_util = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_share_bag_team_util)
  for shared_type, info in pairs(shared_info) do
    if info then
      local share_bag_macros = require("client.slua.logic.share_bag.share_bag_macros")
      logic_share_bag_team_util:SetRemainUseTimes(share_bag_macros.ShareType2ShareItemTypeMap[shared_type], info.use_times or 0, info.max_use_times or 10)
    end
  end
end
function WardRobeHandler.send_equip_mini_robot_motion_req(instid, dst_slot, category_id)
  log(bWriteLog and string.format("WardRobeHandler.send_equip_mini_robot_motion_req. instid=%s, dst_slot=%s, category_id=%s", tostring(instid), tostring(dst_slot), tostring(category_id)))
  NetManager.SendPkg(1236759619, instid, dst_slot, category_id)
end
function WardRobeHandler.on_equip_mini_robot_motion_rsp(err_code, dst_slot, item, old_item)
  log(bWriteLog and string.format("WardRobeHandler.on_equip_mini_robot_motion_rsp. err_code=%s, dst_slot=%s, item=%s, old_item=%s", tostring(err_code), tostring(dst_slot), tostring(item), tostring(old_item)))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_mini_tv_util = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mini_tv_util)
  logic_mini_tv_util:on_equip_mini_robot_motion_rsp(dst_slot, item, old_item)
end
function WardRobeHandler.send_exchange_mini_robt_motion_req(src_slot, dst_slot, category_id)
  log(bWriteLog and string.format("WardRobeHandler.send_exchange_mini_robt_motion_rsp. src_slot=%s, dst_slot=%s, category_id=%s", tostring(src_slot), tostring(dst_slot), tostring(category_id)))
  NetManager.SendPkg(1063994371, src_slot, dst_slot, category_id)
end
function WardRobeHandler.on_exchange_mini_robt_motion_rsp(err_code, src_item, dst_item)
  log(bWriteLog and string.format("WardRobeHandler.on_exchange_mini_robt_motion_rsp. err_code=%s, src_item=%s, dst_item=%s", tostring(err_code), tostring(src_item), tostring(dst_item)))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_mini_tv_util = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mini_tv_util)
  logic_mini_tv_util:on_exchange_mini_robt_motion_rsp(src_item, dst_item)
end
function WardRobeHandler.send_unequip_mini_robot_motion_req(slot_id, category_id)
  log(bWriteLog and string.format("WardRobeHandler.send_unequip_mini_robot_motion_req. slot_id=%s, category_id=%s", tostring(slot_id), tostring(category_id)))
  NetManager.SendPkg(515926247, slot_id, category_id)
end
function WardRobeHandler.on_unequip_mini_robot_motion_rsp(err_code, old_item)
  log(bWriteLog and string.format("WardRobeHandler.on_unequip_mini_robot_motion_rsp. err_code=%s, old_item=%s", tostring(err_code), tostring(old_item)))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_mini_tv_util = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mini_tv_util)
  logic_mini_tv_util:on_unequip_mini_robot_motion_rsp(old_item)
end
function WardRobeHandler.on_sync_mini_robot_motion_notify(mini_robot_motion_info)
  log(bWriteLog and string.format("WardRobeHandler.on_sync_mini_robot_motion_info. mini_robot_motion_info=%s", tostring(mini_robot_motion_info)))
  if not mini_robot_motion_info or not next(mini_robot_motion_info) then
    return
  end
  local logic_mini_tv_util = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mini_tv_util)
  logic_mini_tv_util:SetMiniTVMotionInfo(mini_robot_motion_info)
end
function WardRobeHandler.send_get_mini_robot_motion_info_req()
  NetManager.SendPkg(649901223)
end
function WardRobeHandler.on_get_mini_robot_motion_info_rsp(err_code, mini_robot_motion_info)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  if not mini_robot_motion_info or not next(mini_robot_motion_info) then
    return
  end
  local logic_mini_tv_util = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mini_tv_util)
  logic_mini_tv_util:SetMiniTVMotionInfo(mini_robot_motion_info)
end
function WardRobeHandler.send_card_collect_set_depot_ds_req(ds_type, inst_id)
  log_format(bWriteLog and "WardRobeHandler.send_card_collect_set_depot_ds_req ds_type:%s inst_id:%s", tostring(ds_type), tostring(inst_id))
  NetManager.SendPkg(2109963911, ds_type, inst_id)
end
function WardRobeHandler.on_card_collect_set_depot_ds_rsp(err_code, ds_type, inst_id)
  log_format(bWriteLog and "WardRobeHandler.on_card_collect_set_depot_ds_rsp err_code:%s ds_type:%s inst_id:%s", tostring(err_code), tostring(ds_type), tostring(inst_id))
  local logic_card_collect_wardrobe_show = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_card_collect_wardrobe_show)
  logic_card_collect_wardrobe_show:on_card_collect_set_depot_ds_rsp(err_code, ds_type, inst_id)
end
function WardRobeHandler.send_card_collect_get_depot_ds_req()
  log(bWriteLog and "WardRobeHandler.send_card_collect_get_depot_ds_req")
  NetManager.SendPkg(239626455)
end
function WardRobeHandler.on_card_collect_get_depot_ds_rsp(err_code, item_data)
  log(bWriteLog and "WardRobeHandler.on_card_collect_get_depot_ds_rsp err_code:" .. tostring(err_code))
  log_tree("WardRobeHandler.on_card_collect_get_depot_ds_rsp item_data:", item_data)
  local logic_card_collect_wardrobe_show = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_card_collect_wardrobe_show)
  logic_card_collect_wardrobe_show:on_card_collect_get_depot_ds_rsp(err_code, item_data)
end
function WardRobeHandler.on_mini_dress_newest_notify(dress_id)
  DataMgr.UpdateMiniTvDress(dress_id or 1601019)
  EventSystem:postEvent(EVENTTYPE_LOGIN_ROLEDATA, EVENTID_LOGIN_ROLEDATA_SYNC)
  ShowNotice(89233)
end
local reqRsp = {
  send_change_bind_relation_req = "on_change_bind_relation_rsp"
}
local ProtoPromiseHookTool = require("client.network.comm.ProtoPromiseHookTool")
ProtoPromiseHookTool.HookPair(reqRsp, WardRobeHandler)
return WardRobeHandler