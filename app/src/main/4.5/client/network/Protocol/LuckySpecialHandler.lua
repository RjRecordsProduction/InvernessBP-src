local NetManager = require("client.network.comm.NetManager")
local LuckySpecialHandler = {}
function LuckySpecialHandler.send_get_draw_act_info_req(activity_id)
  NetManager.SendPkg(1568979703, activity_id)
end
function LuckySpecialHandler.on_get_draw_act_info_rsp(err_code, activity_id, pool_info, price_info, ext_info)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local SpecialLuckNetWork = require("client.slua.logic.lobby_activity.special_luck_network")
  SpecialLuckNetWork.on_get_draw_act_info_rsp(activity_id, pool_info, price_info, ext_info)
end
function LuckySpecialHandler.send_do_draw_act_req(activity_id, voucher_id, currency_id, cost_times, ext_info)
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckUCRestrict() then
    return
  end
  NetManager.SendPkg(620217751, activity_id, voucher_id, currency_id, cost_times, ext_info)
end
function LuckySpecialHandler.on_do_draw_act_rsp(err_code, activity_id, item_list, decompose_list, ext_info)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local SpecialLuckNetWork = require("client.slua.logic.lobby_activity.special_luck_network")
  SpecialLuckNetWork.on_do_draw_act_rsp(activity_id, item_list, decompose_list, ext_info)
end
function LuckySpecialHandler.send_get_draw_sum_reward_req(activity_id, sum_times, is_take_all)
  NetManager.SendPkg(1824978567, activity_id, sum_times, is_take_all)
end
function LuckySpecialHandler.on_get_draw_sum_reward_rsp(err_code, activity_id, award_list, decompose_list)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local SpecialLuckNetWork = require("client.slua.logic.lobby_activity.special_luck_network")
  SpecialLuckNetWork.on_get_draw_sum_reward_rsp(activity_id, award_list, decompose_list)
end
function LuckySpecialHandler.send_get_extra_reward_req(activity_id, reward_type)
  NetManager.SendPkg(1630625127, activity_id, reward_type)
end
function LuckySpecialHandler.on_get_extra_reward_rsp(err_code, activity_id, item_list)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local SpecialLuckNetWork = require("client.slua.logic.lobby_activity.special_luck_network")
  SpecialLuckNetWork.on_get_extra_reward_rsp(activity_id, item_list)
end
function LuckySpecialHandler.send_get_collected_reward_req(activity_id)
  NetManager.SendPkg(1106171367, activity_id)
end
function LuckySpecialHandler.on_get_collected_reward_rsp(err_code, activity_id)
  if err_code == 0 then
    local LuckyMixActivitySystem = require("client.slua.logic.lobby_activity.logic_luckmix_activity")
    LuckyMixActivitySystem.on_get_collected_reward_rsp(activity_id)
  else
    ShowNotice(err_code)
  end
end
function LuckySpecialHandler.send_do_draw_discount_req(activity_id)
  NetManager.SendPkg(1747972263, activity_id)
end
function LuckySpecialHandler.on_do_draw_discount_rsp(err_code, activity_id, discount_value, discount_draw_time)
  if err_code == 0 then
    local SpecialLuckNetWork = require("client.slua.logic.lobby_activity.special_luck_network")
    SpecialLuckNetWork.on_do_draw_discount_rsp(activity_id, discount_value, discount_draw_time)
  elseif err_code == 17010007 and type(discount_value) == "number" and type(discount_draw_time) == "number" and discount_draw_time ~= 0 then
    local SpecialLuckNetWork = require("client.slua.logic.lobby_activity.special_luck_network")
    log(bWriteLog and "[SY]LuckySpecialHandler.on_do_draw_discount_rsp.ERROR 17010007")
    SpecialLuckNetWork.on_do_draw_discount_rsp(activity_id, discount_value, discount_draw_time)
  else
    ShowNotice(err_code)
  end
end
return LuckySpecialHandler