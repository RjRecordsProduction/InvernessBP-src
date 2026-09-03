local NetManager = require("client.network.comm.NetManager")
local AskForHandler = {}
function AskForHandler.send_cadge_req(receiver_uid, cadge_id, text)
  NetManager.SendPkg(1427812907, receiver_uid, cadge_id, text)
end
function AskForHandler.on_cadge_rsp(res, receiver, cadge_id)
  log(bWriteLog and "on_cadge_rsp: res: " .. tostring(res))
  if res and res == 0 then
    local title = LocUtil.LocalizeResFormat(101001)
    local str = LocUtil.LocalizeResFormat(7306)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(1, title, str)
    UIManager.CloseUI(UIManager.UI_Config.GiftMessage_Popup_UIBP)
    UIManager.CloseUI(UIManager.UI_Config.GivingGifts_Popup_UIBP)
  elseif res == 100010009 then
    local cObj_askLimitCfg = CDataTable.GetTableData("AskForLimitCfg", cadge_id)
    if cObj_askLimitCfg then
      ShowNotice(LocUtil.LocalizeResFormat(100010009, cObj_askLimitCfg.UserEveryDayLimit))
    else
      ShowNotice(12909)
    end
  elseif res == 100010013 then
    local cObj_askLimitCfg = CDataTable.GetTableData("AskForLimitCfg", cadge_id)
    if cObj_askLimitCfg then
      ShowNotice(LocUtil.LocalizeResFormat(100010013, cObj_askLimitCfg.EveryDayLimit))
    else
      ShowNotice(12909)
    end
  elseif res == 100010029 then
    local title = LocUtil.GetLocalizeResStr(101001)
    local content = LocUtil.GetLocalizeResStr(44791)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, title, content)
  else
    ShowNotice(tonumber(res))
  end
end
function AskForHandler.on_cadge_notify()
  log(bWriteLog and "[chub]AskForHandler.on_cadge_notify")
  AskForHandler.send_cadge_list_req()
end
function AskForHandler.send_cadge_info_req()
  log(bWriteLog and "[chub]AskForHandler.send_cadge_info_req")
  NetManager.SendPkg(1467421991)
end
function AskForHandler.on_cadge_info_rsp(res, cadge_info_data)
  log_tree("[chub]AskForHandler.on_cadge_info_rsp, cadge_info_data = ", cadge_info_data)
  if cadge_info_data and next(cadge_info_data) then
    local AskForSystem = require("client.slua.logic.ask_for.logic_ask_for")
    AskForSystem.CachedCadgeData(cadge_info_data)
  end
end
function AskForHandler.send_cadge_list_req()
  log(bWriteLog and "send_cadge_list_req")
  NetManager.SendPkg(1865800999)
end
function AskForHandler.on_cadge_list_rsp(res, list, uid)
  log_tree("on_cadge_list_rsp", list)
  local giftSystem = require("client.slua.logic.store.logic_store_gift")
  giftSystem.GetCadgeList(list)
end
function AskForHandler.send_handsel_req(index, letter_style, msg)
  NetManager.SendPkg(1664190887, index, letter_style, msg)
end
function AskForHandler.on_handsel_rsp(res, cadge_id)
  EventSystem:postEvent(EVENTTYPE_AskFor, EVENTID_ASKFOR_HANDSEL_RESULT, cadge_id)
  local OnAnimEnd = function()
    local giftPacketSystem = require("client.slua.logic.store.logic_store_gift_packet")
    local title = LocUtil.LocalizeResFormat(101001)
    local str = LocUtil.LocalizeResFormat(200018)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(1, title, str, giftPacketSystem.CloseUI, nil, LocUtil.GetLocalizeResStr("110036"))
    UIManager.CloseUI(UIManager.UI_Config.ui_ask_for_lookfor)
    local giftSystem = require("client.slua.logic.store.logic_store_gift")
    giftSystem.DeleteAlreadySend(cadge_id)
  end
  if res and res == 0 then
    EventSystem:postEvent(EVENTTYPE_STORE, EVENTID_PLAY_GIFT_PACKET_ANIM, OnAnimEnd)
  elseif res == 100010018 then
    ShowNotice(LocUtil.LocalizeResFormat(100010018, 10))
  elseif res == 100010027 then
    log(bWriteLog and "AskForHandler.on_handsel_rsp(res,cadge_id) \229\143\130\230\149\176\233\148\153\232\175\175 ")
  elseif res == 100010028 then
    log(bWriteLog and "AskForHandler.on_handsel_rsp(res,cadge_id) \230\148\175\228\187\152\229\164\177\232\180\165 ")
  elseif res == 100010029 then
    log(bWriteLog and "AskForHandler.on_handsel_rsp msg is inappropriate")
    local title = LocUtil.GetLocalizeResStr(101001)
    local content = LocUtil.GetLocalizeResStr(44791)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, title, content)
  elseif res == StoreConst.error_code_have_car then
    ShowNotice(271622)
  else
    log(bWriteLog and "AskForHandler.on_handsel_rsp(res,cadge_id) res: " .. tostring(res) .. " cadge_id: " .. tostring(cadge_id))
    ShowNotice(tonumber(res))
  end
end
function AskForHandler.send_refuse_cadge_req(index)
  NetManager.SendPkg(910260199, index)
end
function AskForHandler.on_refuse_cadge_rsp(res, cadge_id)
  if res and res == 0 then
    local title = LocUtil.LocalizeResFormat(101001)
    local str = LocUtil.LocalizeResFormat(7310)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(1, title, str)
    UIManager.CloseUI(UIManager.UI_Config.ui_ask_for_lookfor)
    local giftSystem = require("client.slua.logic.store.logic_store_gift")
    giftSystem.RefreshDelete(cadge_id)
  else
    ShowNotice(tonumber(res))
  end
end
function AskForHandler.send_refuse_cadge_switch_req(is_refuse)
  NetManager.SendPkg(1889525003, is_refuse)
end
function AskForHandler.on_refuse_cadge_switch_rsp(res, refuse_time)
  if res and res == 0 then
    local AskForSystem = require("client.slua.logic.ask_for.logic_ask_for")
    if refuse_time then
      AskForSystem.GetCadgeData().      ShowNotice(7311)
    else
      AskForSystem.GetCadgeData().refuse_time = nil
    end
    EventSystem:postEvent(EVENTTYPE_STORE, EVENTID_STORE_GIFT_RE_BEG_UI)
  else
    ShowNotice(tonumber(res))
  end
end
function AskForHandler.send_cadge_set_read_req(index)
  NetManager.SendPkg(1658787143, index)
end
function AskForHandler.on_cadge_set_read_rsp(res, cadge_index)
  if res and res == 0 then
    local giftSystem = require("client.slua.logic.store.logic_store_gift")
    giftSystem.OnGetSetRead(12, cadge_index)
  else
    ShowNotice(tonumber(res))
  end
end
function AskForHandler.send_del_all_read_cadge_req()
  NetManager.SendPkg(1870259175)
end
function AskForHandler.on_del_all_read_cadge_rsp(res, del_msgs)
  if res and res == 0 then
    ShowNotice(102018)
    log_tree("del_msgs", del_msgs)
    if next(del_msgs) then
      local giftSystem = require("client.slua.logic.store.logic_store_gift")
      giftSystem.DeleteReadMsg(del_msgs)
    end
  else
    ShowNotice(tonumber(res))
  end
end
function AskForHandler.on_handsel_notify(res)
  if res then
    log(bWriteLog and "on_handsel_notify" .. tostring(res))
  end
  local ShopGiftPacketLogic = require("client.logic.shop.logic_shop_gift_packet")
  ShopGiftPacketLogic.SendGetGiftMsgList(11)
end
function AskForHandler.send_cadge_item_is_got_req(index)
  NetManager.SendPkg(506816491, index)
end
function AskForHandler.on_cadge_item_is_got_rsp(res, cadge_index)
  log(bWriteLog and "[chub]AskForHandler.on_cadge_item_is_got_rsp, res =  " .. tostring(res) .. " cadge_index = " .. tostring(cadge_index))
  if res and res == 0 then
    log(bWriteLog and "cadge_item_is_got_rsp_res" .. res)
    EventSystem:postEvent(EVENTTYPE_AskFor, EVENTID_ASKFOR_SEND)
  else
    log(bWriteLog and "cadge_item_is_got_rsp: res: " .. tostring(res) .. " cadge_index: " .. tostring(cadge_index))
    if tonumber(res) == 100010025 then
      EventSystem:postEvent(EVENTTYPE_AskFor, EVENTID_ASKFOR_HAVE_UPASS)
    elseif tonumber(res) == 100010026 then
      EventSystem:postEvent(EVENTTYPE_AskFor, EVENTID_ASKFOR_HAD)
    else
      ShowNotice(tonumber(res))
      AskForHandler.send_cadge_list_req()
    end
  end
end
function AskForHandler.send_del_cadge_req(cadge_index)
  log(bWriteLog and "[chub]AskForHandler.send_del_cadge_req, cadge_index = " .. tostring(cadge_index))
  NetManager.SendPkg(3886003, cadge_index)
end
function AskForHandler.on_del_cadge_rsp(retcode, cadge_index)
  log(bWriteLog and "[chub]AskForHandler.on_del_cadge_rsp, retcode = " .. tostring(retcode))
  log(bWriteLog and "[chub]AskForHandler.on_del_cadge_rsp, cadge_index = " .. tostring(cadge_index))
  if retcode ~= 0 then
    ShowNotice(retcode)
    return
  end
  ShowNotice(102011)
  AskForHandler.send_cadge_list_req()
end
function AskForHandler.send_batch_load_cadge_profile_req(friends_uids)
  NetManager.SendPkg(479510823, friends_uids)
end
function AskForHandler.on_batch_load_cadge_profile_rsp(res, cadge_profiles)
  if res ~= 0 then
    ShowNotice(res)
    return
  end
  local BasicDataGiftAskSysStatus = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataGiftAskSysStatus)
  BasicDataGiftAskSysStatus:on_batch_load_cadge_profile_rsp(cadge_profiles)
  log_tree(" on_batch_load_cadge_profile_rsp:", cadge_profiles)
end
function AskForHandler.on_update_cadge_status_notify(serial_num, new_status)
  local AskForSystem = require("client.slua.logic.ask_for.logic_ask_for")
  AskForSystem.UpdateCachedCadgeDataStatus(serial_num, new_status)
end
return AskForHandler