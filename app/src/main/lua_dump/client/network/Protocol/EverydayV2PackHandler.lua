local NetManager = require("client.network.comm.NetManager")
local EverydayV2PackHandler = {}
function EverydayV2PackHandler.send_daily_direct_buy_v2_get_cfg_req()
  NetManager.SendPkg(1747444167)
end
function EverydayV2PackHandler.on_daily_direct_buy_v2_get_cfg_rsp(err_code, data)
  log(bWriteLog and "on_daily_direct_buy_v2_get_cfg_rsp, err_code:" .. tostring(err_code))
  if not data or err_code ~= 0 then
    log(bWriteLog and "[v_gpinban] on_daily_direct_buy_v2_get_cfg_rsp no sever data")
    return
  end
  local EveryDayPackSystem = require("client.logic.everyday_pack.logic_everydaypack")
  local special_offer_cfg = require("client.slua.logic.specialoffer.special_offer_cfg")
  EveryDayPackSystem.uiSwitch = EveryDayPackSystem.open_ui_type.everydaypack_v2
  EveryDayPackSystem.everydayV2SystemData = EveryDayPackSystem.SetEverydayPackData(data)
  EventSystem:postEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_SPECIAL_OFFER_REFRESH_PAGE)
  EventSystem:postEvent(EVENTTYPE_EVERYDAYPACK, EVENTID_EVERYDAYPACK_ACTIVITY_V2_DATA, data)
  EventSystem:postEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_SPECIAL_RED_CHANGE, special_offer_cfg.DailyFortunePack)
end
function EverydayV2PackHandler.send_daily_direct_buy_v2_can_buy_req(chest_index, chest_item_id)
  NetManager.SendPkg(1623736191, chest_index, chest_item_id)
end
function EverydayV2PackHandler.on_daily_direct_buy_v2_can_buy_rsp(err_code)
  log(bWriteLog and "on_daily_direct_buy_v2_can_buy_rsp err_code:" .. tostring(err_code))
  if not err_code or err_code ~= 0 then
    if err_code == 4 then
      ShowNotice(44589)
    else
      ShowNotice(err_code)
    end
    return
  end
  EventSystem:postEvent(EVENTTYPE_EVERYDAYPACK, EVENTID_EVERYDAYPACK_ACTIVITY_V2_CAN_BUY)
end
function EverydayV2PackHandler.on_daily_direct_buy_v2_buy_success_rsp(err_code, ret_item_list, ret_lucky_list)
  log(bWriteLog and "on_daily_direct_buy_v2_buy_success_rsp err_code:" .. tostring(err_code))
  if err_code ~= 0 or not ret_item_list then
    ShowNotice(err_code)
    return
  end
  EventSystem:postEvent(EVENTTYPE_EVERYDAYPACK, EVENTID_EVERYDAYPACK_ACTIVITY_V2_MIDS_SUCCESS, ret_item_list, ret_lucky_list)
end
function EverydayV2PackHandler.send_daily_direct_buy_v2_exchange_reward_req(final_item_id)
  NetManager.SendPkg(1729890199, final_item_id)
end
function EverydayV2PackHandler.on_daily_direct_buy_v2_exchange_reward_rsp(err_code, item_list)
  log(bWriteLog and "on_daily_direct_buy_v2_exchange_reward_rsp err_code:" .. tostring(err_code))
  if err_code ~= 0 or not item_list then
    ShowNotice(err_code)
    return
  end
  log_tree("on_daily_direct_buy_v2_exchange_reward_rsp item_list:", item_list)
  EventSystem:postEvent(EVENTTYPE_EVERYDAYPACK, EVENTID_EVERYDAYPACK_ACTIVITY_V2_FINIAL_AWARD, item_list)
end
function EverydayV2PackHandler.send_daily_direct_buy_v2_buy_success_req(chest_index)
  NetManager.SendPkg(1834480677, chest_index)
end
return EverydayV2PackHandler