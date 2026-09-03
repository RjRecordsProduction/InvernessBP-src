local NetManager = require("client.network.comm.NetManager")
local SubscribeHandler = {}
function SubscribeHandler.send_query_prime_info()
  log(bWriteLog and "SubscribeHandler.send_query_prime_info")
  NetManager.SendPkg(1510025356)
end
function SubscribeHandler.on_query_prime_info_rsp(prime_success, cfg, prime, discountbuy, coupons_tb, activity_table, prime_notice_flag, prime_refund_ban_time)
  log(bWriteLog and "SubscribeHandler.on_query_prime_info_rsp prime_success = " .. tostring(prime_success))
  log_tree("prime = ", prime)
  log_tree("discountbuy = ", discountbuy)
  log_tree("coupons_tb = ", coupons_tb)
  log_tree("activity_table = ", activity_table)
  log_tree("prime_notice_flag = ", prime_notice_flag)
  local logic_subscribe_handler = require("client.slua.logic.subscribe.logic_subscribe_handler")
  local subscribeModuleObj = logic_subscribe_handler.GetSubscribeModuleObj()
  subscribeModuleObj:on_query_prime_info(prime_success, cfg, prime, discountbuy, coupons_tb, activity_table, prime_notice_flag, prime_refund_ban_time)
end
function SubscribeHandler.on_notify_prime_change(data, dailyinfo, redpoint)
  local logic_subscribe_handler = require("client.slua.logic.subscribe.logic_subscribe_handler")
  local subscribeModuleObj = logic_subscribe_handler.GetSubscribeModuleObj()
  subscribeModuleObj:on_notify_prime_change(data, dailyinfo, redpoint)
end
function SubscribeHandler.send_take_first_award(Enum_SubId)
  NetManager.SendPkg(1574048524, Enum_SubId)
end
function SubscribeHandler.on_take_first_award_rsp(ret, res)
  local logic_subscribe_handler = require("client.slua.logic.subscribe.logic_subscribe_handler")
  local subscribeModuleObj = logic_subscribe_handler.GetSubscribeModuleObj()
  subscribeModuleObj:On_take_first_award_rsp(ret, res)
end
function SubscribeHandler.send_take_daily_uc_priv()
  NetManager.SendPkg(322631692)
end
function SubscribeHandler.on_take_daily_uc_priv_rsp(ret, number, super_times, normal_times)
  local logic_subscribe_handler = require("client.slua.logic.subscribe.logic_subscribe_handler")
  local subscribeModuleObj = logic_subscribe_handler.GetSubscribeModuleObj()
  subscribeModuleObj:On_take_daily_uc_priv(ret, number, super_times, normal_times)
end
function SubscribeHandler.send_take_daily_rp_priv()
  NetManager.SendPkg(454039692)
end
function SubscribeHandler.on_take_daily_rp_priv_rsp(ret)
end
function SubscribeHandler.send_buy_discount_sale_item(uniq_id)
  NetManager.SendPkg(531976780, uniq_id)
end
function SubscribeHandler.on_buy_discount_sale_item_rsp(ret, item_id, item_num)
  local logic_subscribe_handler = require("client.slua.logic.subscribe.logic_subscribe_handler")
  local subscribeModuleObj = logic_subscribe_handler.GetSubscribeModuleObj()
  subscribeModuleObj:On_buy_discount_sale_item_rsp(ret, item_id, item_num)
end
function SubscribeHandler.send_jpkr_take_daily_fp()
  NetManager.SendPkg(538443340)
end
function SubscribeHandler.on_jpkr_take_daily_fp_rsp(prime_success, pp_priv_num, pp_times)
  local logic_subscribe_handler = require("client.slua.logic.subscribe.logic_subscribe_handler")
  local subscribeModuleObj = logic_subscribe_handler.GetSubscribeModuleObj()
  subscribeModuleObj:on_jpkr_take_daily_fp_rsp(prime_success, pp_priv_num, pp_times)
end
function SubscribeHandler.send_jpkr_take_daily_uc()
  NetManager.SendPkg(132059468)
end
function SubscribeHandler.on_jpkr_take_daily_uc_rsp(prime_success, pb_priv_num, pb_times)
  local logic_subscribe_handler = require("client.slua.logic.subscribe.logic_subscribe_handler")
  local subscribeModuleObj = logic_subscribe_handler.GetSubscribeModuleObj()
  subscribeModuleObj:on_jpkr_take_daily_uc_rsp(prime_success, pb_priv_num, pb_times)
end
function SubscribeHandler.send_jpkr_discount_buy(uniq_id)
  NetManager.SendPkg(354120044, uniq_id)
end
function SubscribeHandler.on_jpkr_discount_buy_rsp(prime_success, item_id, item_num, is_plus)
  local logic_subscribe_handler = require("client.slua.logic.subscribe.logic_subscribe_handler")
  local subscribeModuleObj = logic_subscribe_handler.GetSubscribeModuleObj()
  subscribeModuleObj:on_jpkr_discount_buy_rsp(prime_success, item_id, item_num, is_plus)
end
function SubscribeHandler.send_take_coupons()
  NetManager.SendPkg(1112185612)
end
function SubscribeHandler.on_take_coupons_rsp(prime_success, plus_table, basic_table)
  if prime_success then
    if prime_success == 0 then
      local showtable = {}
      local logic_subscribe_handler = require("client.slua.logic.subscribe.logic_subscribe_handler")
      local subscribeModuleObj = logic_subscribe_handler.GetSubscribeModuleObj()
      subscribeModuleObj:CachedCouponsDataStatus(false)
      if basic_table and next(basic_table) then
        for i, iteminfo in pairs(basic_table) do
          local temptable = {}
          local itemcfg = CDataTable.GetTableData("Item", iteminfo.resid)
          if itemcfg then
            temptable.valid_hours = itemcfg.ValidTimes
          end
          temptable.res_id = iteminfo.resid
          temptable.count = iteminfo.count
          table.insert(showtable, temptable)
        end
      end
      if plus_table and next(plus_table) then
        for i, iteminfo in pairs(plus_table) do
          local temptable = {}
          local itemcfg = CDataTable.GetTableData("Item", iteminfo.resid)
          if itemcfg then
            temptable.valid_hours = itemcfg.ValidTimes
          end
          temptable.res_id = iteminfo.resid
          temptable.count = iteminfo.count
          table.insert(showtable, temptable)
        end
      end
      if 0 < #showtable then
        local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
        Logic_CommonItemGet.ShowPanel_DefaultStyle(showtable)
      end
      local special_offer_cfg = require("client.slua.logic.specialoffer.special_offer_cfg")
      EventSystem:postEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_SPECIAL_RED_CHANGE, special_offer_cfg.subscribe)
    else
      log(bWriteLog and "prime_success " .. tostring(prime_success))
      if prime_success == 109 then
        ShowNotice(433021)
      end
    end
  end
end
function SubscribeHandler.on_prime_notify_valid_activity(activity_data_table)
  local logic_subscribe_handler = require("client.slua.logic.subscribe.logic_subscribe_handler")
  local subscribeModuleObj = logic_subscribe_handler.GetSubscribeModuleObj()
  subscribeModuleObj:SetOpenSubscribeActivity(activity_data_table)
end
function SubscribeHandler.send_take_primer_item(ss, prime_type)
  NetManager.SendPkg(1671296844, ss, prime_type)
end
function SubscribeHandler.on_take_primer_item_rsp(prime_success, pp_priv_num, pp_times)
  local logic_subscribe_handler = require("client.slua.logic.subscribe.logic_subscribe_handler")
  local subscribeModuleObj = logic_subscribe_handler.GetSubscribeModuleObj()
  subscribeModuleObj:on_take_primer_item_rsp(prime_success, pp_priv_num, pp_times)
end
function SubscribeHandler.send_get_primeshop_info()
  NetManager.SendPkg(838042028)
end
function SubscribeHandler.on_get_primeshop_info_rsp(prime_data, primeshop_cfg, prime_award_cfg)
end
function SubscribeHandler.on_notify_primeshop_change(prime_data)
end
function SubscribeHandler.on_primeshop_reward_notify(res_list)
end
function SubscribeHandler.send_take_prime_privilege_award_req()
  NetManager.SendPkg(822717543)
end
function SubscribeHandler.on_take_prime_privilege_award_rsp(prime_success, total_res_list, total_dyn_list)
  if prime_success == 0 then
    local logic_subscribe_handler = require("client.slua.logic.subscribe.logic_subscribe_handler")
    local subscribeModuleObj = logic_subscribe_handler.GetSubscribeModuleObj()
    subscribeModuleObj:ShowReceiveReward(total_res_list, total_dyn_list)
  elseif prime_success == 102 or prime_success == 105 then
    ShowNotice(49003)
  elseif prime_success == 103 then
    ShowNotice(6503)
  elseif prime_success == 104 then
    ShowNotice(6494)
  end
end
function SubscribeHandler.on_notify_instant_reward(prime_success, res_list, dyn_dic)
  if prime_success ~= 0 then
    return
  end
  if GameStatus.IsInLobbyOrMainCity() then
    local tAllItem = {}
    for k, v in pairs(res_list) do
      local tItemCfg = CDataTable.GetTableData("Item", k) or {}
      local nQuality = tItemCfg.ItemQuality or 1
      table.insert(tAllItem, {
        res_id = k,
        count = v,
        valid_hours = dyn_dic and dyn_dic[k] and dyn_dic[k].valid_hours or 0,
              })
    end
    local tExtraData
    local cObj_BFSubscribeModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_BFSubscribeModule)
    local nSubItemId = cObj_BFSubscribeModule:GetFirstBuySubItemId()
    if nSubItemId and cObj_BFSubscribeModule:GetActIsOpen() then
      tExtraData = {
        fCloseCallback = function()
          cObj_BFSubscribeModule:HandlerFirstBuySubItemIdGuide()
        end
      }
    end
    table.sort(tAllItem, function(a, b)
      return a.nQuality > b.nQuality
    end)
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle(tAllItem, false, true, tExtraData)
  end
end
function SubscribeHandler.send_report_finish_upgrade_260_guide_req()
  NetManager.SendPkg(513625471)
end
function SubscribeHandler.on_report_finish_upgrade_260_guide_rsp()
end
function SubscribeHandler.send_set_prime_badge_no_show_flag(flag)
  NetManager.SendPkg(527806782, flag)
end
function SubscribeHandler.on_set_prime_badge_no_show_flag(err_code, flag)
  if err_code ~= 0 then
    log(bWriteLog and "SubscribeHandler.on_set_prime_badge_no_show_flag error")
  end
  log(bWriteLog and "SubscribeHandler.on_set_prime_badge_no_show_flag" .. tostring(flag))
  local LogicSettingBasic = require("client.slua.logic.setting.logic_setting_basic")
  if flag == 0 then
    LogicSettingBasic.bShowSubscribeBadge = true
  else
    LogicSettingBasic.bShowSubscribeBadge = false
  end
end
function SubscribeHandler.on_notify_prime_ban_time(refund_ban_time)
  local logic_subscribe_handler = require("client.slua.logic.subscribe.logic_subscribe_handler")
  local subscribeModuleObj = logic_subscribe_handler.GetSubscribeModuleObj()
  subscribeModuleObj:on_notify_prime_ban_time(refund_ban_time)
end
return SubscribeHandler