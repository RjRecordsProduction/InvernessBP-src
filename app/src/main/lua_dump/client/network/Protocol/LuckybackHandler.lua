local NetManager = require("client.network.comm.NetManager")
local LuckybackHandler = {bShowCommonExchange = false}
function LuckybackHandler.send_get_lucky_draw_back_activity_req(act_Id)
  NetManager.SendPkg(695104167, act_Id)
end
function LuckybackHandler.on_get_lucky_draw_back_activity_rsp(rs, cfg, myData, activity_data)
  local LuckybackActivitySystem = require("client.slua.logic.lobby_activity.logic_luckyback_activity")
  LuckybackActivitySystem.get_lucky_draw_back_activity_rsp(rs, cfg, myData, activity_data)
end
function LuckybackHandler.send_do_one_draw_back_by_activity_req(act_Id, draw_type, data_info, coupon_id)
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckUCRestrict() then
    return
  end
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_SPIN_STOP_COIN_UPDATE)
  NetManager.SendPkg(1478162855, act_Id, draw_type, data_info, coupon_id)
end
function LuckybackHandler.on_do_one_draw_back_by_activity_rsp(rs, myData, award_info, decompose_list, draw_type, addition_awards)
  local LuckybackActivitySystem = require("client.slua.logic.lobby_activity.logic_luckyback_activity")
  LuckybackActivitySystem.do_one_draw_back_by_activity_rsp(rs, myData, award_info, decompose_list, draw_type, addition_awards)
end
function LuckybackHandler.send_get_sum_draw_award_by_activity_req(act_Id, times, is_take_all)
  NetManager.SendPkg(1355510887, act_Id, times, is_take_all)
end
function LuckybackHandler.on_get_sum_draw_award_by_activity_rsp(rs, myData, award_info)
  local LuckybackActivitySystem = require("client.slua.logic.lobby_activity.logic_luckyback_activity")
  LuckybackActivitySystem.get_sum_draw_award_by_activity_rsp(rs, myData, award_info)
end
function LuckybackHandler.send_do_exchange_by_activity_id_req(exchangeActId, id, times, req_params)
  local LogicVehicleAccessory = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicVehicleAccessory)
  if not LogicVehicleAccessory:CheckCanExchangeVehicleAccessory(id) then
    log(bWriteLog and "LuckybackHandler.send_do_exchange_by_activity_id_req CheckCanExchangeVehicleAccessory false")
    ShowNotice(9920326)
    return
  end
  NetManager.SendPkg(745299879, exchangeActId, id, times, req_params)
end
function LuckybackHandler.on_do_exchange_by_activity_id_rsp(rs, myData, award_info, activity_id)
  local logic_theme_system = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_theme_system)
  local logic_lucky_exchange = require("client.slua.logic.lobby_activity.lucky_exchange.logic_lucky_exchange")
  if logic_lucky_exchange.IsInActicityList(activity_id) then
    if rs ~= 0 then
      ShowNotice(rs)
      return
    end
    logic_lucky_exchange.on_do_exchange_by_activity_id_rsp(myData, award_info, activity_id)
  elseif logic_theme_system:CheckThemeExchange(activity_id) then
    logic_theme_system:UpdateExchangeInfo(rs, myData, award_info, activity_id)
  else
    local LuckybackActivitySystem = require("client.slua.logic.lobby_activity.logic_luckyback_activity")
    LuckybackActivitySystem.do_exchange_by_activity_id_rsp(rs, myData, award_info, activity_id)
  end
end
function LuckybackHandler.send_get_exchange_activity_info_req(id)
  if not id or id <= 0 then
    log_error("[cw] LuckybackHandler.send_get_exchange_activity_info_req with nil id")
    return
  end
  NetManager.SendPkg(581313127, id)
end
function LuckybackHandler.on_get_exchange_activity_info_rsp(rs, exchange_table, mydata, activity_id, discount_cfg, sheet_shield_cfg)
  local logic_theme_system = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_theme_system)
  if logic_theme_system:CheckThemeExchange(activity_id) then
    logic_theme_system:OnRespExchangeInfo(rs, exchange_table, mydata, activity_id)
    return
  end
  local LuckybackActivitySystem = require("client.slua.logic.lobby_activity.logic_luckyback_activity")
  local logic_lucky_exchange = require("client.slua.logic.lobby_activity.lucky_exchange.logic_lucky_exchange")
  if logic_lucky_exchange.IsInActicityList(activity_id) then
    if rs ~= 0 then
      ShowNotice(rs)
      return
    end
    logic_lucky_exchange.on_get_exchange_activity_info_rsp(exchange_table, mydata, activity_id, discount_cfg, sheet_shield_cfg)
  else
    LuckybackActivitySystem.get_exchange_activity_info_rsp(rs, exchange_table, mydata, activity_id, discount_cfg, sheet_shield_cfg)
  end
  if LuckybackHandler.bShowCommonExchange and rs == LuckybackActivitySystem.Enum_Err_Code.success then
    local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
    if not ActivityNewSystem.GetActivityByID(activity_id) then
      local ActivityHandler = require("client.network.Protocol.ActivityHandler")
      local activity_list = {
        [1] = activity_id
      }
      ActivityHandler.send_get_activity_batch_req(activity_list)
    end
    if LuckybackHandler.highLevelItemID then
      UIManager.ShowUI(UIManager.UI_Config.jk_common_exchange_high, tonumber(activity_id), tonumber(LuckybackHandler.highLevelItemID))
    else
      UIManager.ShowUI(UIManager.UI_Config.common_exchange, tonumber(activity_id))
    end
  end
  LuckybackHandler.highLevelItemID = nil
  LuckybackHandler.bShowCommonExchange = false
end
function LuckybackHandler.on_get_lucky_draw_back_redpoint_rsp(need_redpoint_activity)
  local LuckybackActivitySystem = require("client.slua.logic.lobby_activity.logic_luckyback_activity")
  LuckybackActivitySystem.get_lucky_draw_back_redpoint_rsp(need_redpoint_activity)
end
function LuckybackHandler.send_get_lucky_draw_back_voucher_req(activity_id)
  NetManager.SendPkg(1020051431, activity_id)
end
function LuckybackHandler.on_get_lucky_draw_back_voucher_rsp(rs, todayConpon, nextCoupon)
  log_tree("[ljw] nextCoupon", nextCoupon)
  local LuckybackActivitySystem = require("client.slua.logic.lobby_activity.logic_luckyback_activity")
  LuckybackActivitySystem.on_get_lucky_draw_back_voucher_rsp(rs, todayConpon)
end
function LuckybackHandler.send_do_one_to_batch_exchange_by_activity_id_req(activity_id, award_item_list)
  NetManager.SendPkg(2029256911, activity_id, award_item_list)
end
function LuckybackHandler.on_do_one_to_batch_exchange_by_activity_id_rsp(err_code, my_activity_data, award_list, activity_id)
end
function LuckybackHandler.send_draw_exchange_discount_by_actid_req(activity_id, itemid)
  NetManager.SendPkg(1494187987, activity_id, itemid)
end
function LuckybackHandler.on_draw_exchange_discount_by_actid_rsp(errcode, activity_id, itemid, discount)
  if errcode == 0 then
    local LuckybackActivitySystem = require("client.slua.logic.lobby_activity.logic_luckyback_activity")
    LuckybackActivitySystem.on_draw_exchange_discount_by_actid_rsp(activity_id, itemid, discount)
  else
    log(bWriteLog and "LuckybackHandler.on_draw_exchange_discount_by_actid_rsp error , " .. tostring(errcode))
  end
end
function LuckybackHandler.send_get_lucky_draw_collect_award_req(activity_id)
  NetManager.SendPkg(1890567399, activity_id)
end
function LuckybackHandler.on_get_lucky_draw_collect_award_rsp(err_code, activity_id)
  if err_code == 0 then
    local LuckybackActivitySystem = require("client.slua.logic.lobby_activity.logic_luckyback_activity")
    LuckybackActivitySystem.on_get_lucky_draw_collect_award_rsp(activity_id)
  else
    ShowNotice(err_code)
  end
end
function LuckybackHandler.send_car_compose_req(higher_car_id, lower_car_id, activity_id)
  log(bWriteLog and "[jinqiang] higher_car_id == " .. tostring(higher_car_id) .. " lower_car_id == " .. tostring(lower_car_id))
  NetManager.SendPkg(2011924111, higher_car_id, lower_car_id, activity_id)
end
function LuckybackHandler.on_car_compose_rsp(err_code, higher_car_id, lower_car_id)
  log(bWriteLog and "[jinqiang] err_code == " .. tostring(err_code) .. " higher_car_id == " .. tostring(higher_car_id) .. " lower_car_id == " .. tostring(lower_car_id))
  if err_code == 0 then
    local data = {
      [1] = {}
    }
    data[1].res_id = higher_car_id
    data[1].count = 1
    data[1].valid_hours = 0
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle(data)
    EventSystem:postEvent(EVENTTYPE_JUMP, EVENTID_LUCKYBACK_COMPOSE_REFRESH)
  elseif err_code == 9920320 then
    ShowNotice(3018)
  elseif err_code == 9920321 then
    ShowNotice(9920321)
  elseif err_code == 9920322 then
    ShowNotice(9920322)
  elseif err_code == 9920323 then
    ShowNotice(9920323)
  elseif err_code == 9920324 then
    ShowNotice(11345)
  end
end
local reqRsp = {
  send_get_lucky_draw_back_activity_req = "on_get_lucky_draw_back_activity_rsp"
}
local ProtoPromiseHookTool = require("client.network.comm.ProtoPromiseHookTool")
ProtoPromiseHookTool.HookPair(reqRsp, LuckybackHandler)
return LuckybackHandler