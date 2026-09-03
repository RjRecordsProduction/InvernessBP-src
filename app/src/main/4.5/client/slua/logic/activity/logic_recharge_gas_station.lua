local RechargeGasStationSystem = {
  Enum_Refresh_Type = {Pay = 0, Percent = 1},
  cur_count = 0,
  cur_market_id = 0,
  cur_pay = 0,
  cur_percent = 0,
  cur_pay_refresh_count = 0,
  cur_percent_refresh_count = 0,
  drop_count = 0,
  max_count = 0,
  pay_list = nil,
  percent_list = nil,
  pay_refresh_max = 0,
  pay_refresh_cost = 30,
  pay_refresh_itemid = 0,
  percent_refresh_max = 0,
  percent_refresh_cost = 0,
  percent_refresh_itemid = 0,
  total_charge_uc = 0,
  productInfoList = {},
  purchaseInfoList = {},
  store_page_id = 49,
  hasEnterAct = nil
}
function RechargeGasStationSystem.ReqGetGasStationInfo()
  local RechargeGasStationHandler = require("client.network.Protocol.RechargeGasStationHandler")
  RechargeGasStationHandler.send_get_gas_station_info_req()
end
function RechargeGasStationSystem.OpenActivityUI()
  if not RechargeGasStationSystem.IsInActivityTime() then
    ShowNotice(4002)
    return
  end
  if not UIManager.IsUIShow(UIManager.UI_Config.ui_recharge_gas_station) then
    log(bWriteLog and "[PXY]RechargeGasStationSystem.OpenActivityUI.RechargeGasStationSystem.IsBanner")
    UIManager.ShowUI(UIManager.UI_Config.ui_recharge_gas_station)
  end
end
function RechargeGasStationSystem.OnGetGasStationInfo(err_code, info)
  if err_code == 0 then
    if info then
      log_tree("[v_wllwu] RechargeGasStationSystem:OnGetGasStationInfo", info)
      if not RechargeGasStationSystem.pay_list or not RechargeGasStationSystem.percent_list then
        RechargeGasStationSystem.max_count = info.max
        RechargeGasStationSystem.pay_refresh_max = info.pay_refresh_max
        RechargeGasStationSystem.percent_refresh_max = info.percent_refresh_max
        RechargeGasStationSystem.pay_list = info.pay_list
        RechargeGasStationSystem.percent_list = info.percent_list
        RechargeGasStationSystem.pay_refresh_cost = info.pay_refresh_cost
        RechargeGasStationSystem.pay_refresh_itemid = info.pay_refresh_itemid
        RechargeGasStationSystem.percent_refresh_cost = info.percent_refresh_cost
        RechargeGasStationSystem.percent_refresh_itemid = info.percent_refresh_itemid
      end
      RechargeGasStationSystem.cur_market_id = info.market_id
      RechargeGasStationSystem.cur_pay = info.pay
      RechargeGasStationSystem.cur_percent = info.percent
      RechargeGasStationSystem.cur_pay_refresh_count = info.pay_count
      RechargeGasStationSystem.cur_percent_refresh_count = info.percent_count
      RechargeGasStationSystem.total_charge_uc = info.charge_uc
      RechargeGasStationSystem.drop_count = info.drop_count or 0
      if GlobalData.IsJapanOrKorea() then
        RechargeGasStationSystem.cur_count = info.buy_count
      else
        RechargeGasStationSystem.cur_count = info.count
      end
      EventSystem:postEvent(EVENTTYPE_ACTIVITY_RECHARGE_GASSTATION, EVENTID_RECHARGE_GASSTATION_UPDATE_INFO)
    end
  else
    ShowNotice(err_code)
  end
end
function RechargeGasStationSystem.ReqRefreshCurChoice(type)
  local RechargeGasStationHandler = require("client.network.Protocol.RechargeGasStationHandler")
  RechargeGasStationHandler.send_refresh_gas_station_req(type)
end
function RechargeGasStationSystem.OnRefreshChoice(err_code, type, pay, percent, market_id, pay_refresh_count, percent_refresh_count, charge_uc)
  if err_code == 0 then
    RechargeGasStationSystem.cur_    RechargeGasStationSystem.cur_    RechargeGasStationSystem.cur_    RechargeGasStationSystem.cur_    RechargeGasStationSystem.cur_    RechargeGasStationSystem.total_    log(bWriteLog and "[v_wllwu] OnRefreshChoice total_charge_uc = " .. tostring(charge_uc))
    EventSystem:postEvent(EVENTTYPE_ACTIVITY_RECHARGE_GASSTATION, EVENTID_RECHARGE_GASSTATION_REFRESH_PAYPERCENT, type)
  else
    ShowNotice(err_code)
  end
end
function RechargeGasStationSystem.ReqGiveUpWelfare()
  local RechargeGasStationHandler = require("client.network.Protocol.RechargeGasStationHandler")
  RechargeGasStationHandler.send_drop_gas_station_req()
end
function RechargeGasStationSystem.OnGiveUpRsp(err_code, count, maxcount, dropcount, percent_refresh_count, pay_refresh_count)
  if err_code == 0 then
    RechargeGasStationSystem.cur_    RechargeGasStationSystem.max_count = maxcount
    RechargeGasStationSystem.cur_market_id = 0
    RechargeGasStationSystem.cur_pay = 0
    RechargeGasStationSystem.cur_percent = 0
    RechargeGasStationSystem.cur_    RechargeGasStationSystem.cur_    RechargeGasStationSystem.drop_count = dropcount or 0
    EventSystem:postEvent(EVENTTYPE_ACTIVITY_RECHARGE_GASSTATION, EVENTID_RECHARGE_GASSTATION_GIVEUP_WELFARE)
  else
    ShowNotice(err_code)
  end
end
function RechargeGasStationSystem.ReqDrawWelfare()
  local RechargeGasStationHandler = require("client.network.Protocol.RechargeGasStationHandler")
  RechargeGasStationHandler.send_draw_gas_station_req()
end
function RechargeGasStationSystem.OnDrawWelfareRsp(err_code, count, maxcount, pay, percent, market_id, charge_uc)
  if err_code == 0 then
    log(bWriteLog and "[v_wllwu] RechargeGasStationSystem.OnDrawWelfareRsp cur_count == " .. tostring(count))
    RechargeGasStationSystem.cur_    RechargeGasStationSystem.max_count = maxcount
    RechargeGasStationSystem.cur_    RechargeGasStationSystem.cur_    RechargeGasStationSystem.cur_    RechargeGasStationSystem.total_    log(bWriteLog and "[v_wllwu] OnDrawWelfareRsp market_id" .. tostring(market_id) .. "total_charge_uc = " .. tostring(charge_uc))
    EventSystem:postEvent(EVENTTYPE_ACTIVITY_RECHARGE_GASSTATION, EVENTID_RECHARGE_GASSTATION_REFRESH_CURWEALFARE)
  else
    ShowNotice(err_code)
  end
end
function RechargeGasStationSystem.OnRechargeSuccessRsp(market_id, item_id, uc, percent_refresh_count, pay_refresh_count, buy_count)
  log(bWriteLog and "[v_wllwu] RechargeGasStationSystem.OnRechargeSuccessRsp cur_count == " .. tostring(buy_count))
  RechargeGasStationSystem.total_charge_uc = 0
  RechargeGasStationSystem.cur_pay = 0
  RechargeGasStationSystem.cur_percent = 0
  RechargeGasStationSystem.cur_market_id = 0
  RechargeGasStationSystem.cur_  RechargeGasStationSystem.cur_  if GlobalData.IsJapanOrKorea() then
    RechargeGasStationSystem.cur_count = buy_count
  end
  EventSystem:postEvent(EVENTTYPE_ACTIVITY_RECHARGE_GASSTATION, EVENTID_RECHARGE_GASSTATION_ADDUC_SUCCESS, item_id, uc)
end
function RechargeGasStationSystem.SetPurchaseInfoList()
  local RechargePurchaseSystem = require("client.logic.recharge.logic_recharge_purchase")
  if next(RechargeGasStationSystem.productInfoList) then
    local req_id_list = {}
    local save_list = {}
    for k, v in pairs(RechargeGasStationSystem.productInfoList) do
      if not RechargeGasStationSystem.purchaseInfoList[v.product_id] and not save_list[v.product_id] then
        save_list[v.product_id] = true
        table.insert(req_id_list, v.product_id)
      end
    end
    if 1 <= #req_id_list then
      RechargePurchaseSystem.GetPurchaseInfoReq(req_id_list)
    end
  end
end
function RechargeGasStationSystem.IsEnterActivityUI()
  if RechargeGasStationSystem.hasEnterAct == nil then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local cacheInfo = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eRechargeGasStation)
    if cacheInfo and cacheInfo.hasEnterAct then
      RechargeGasStationSystem.hasEnterAct = true
    else
      RechargeGasStationSystem.hasEnterAct = false
    end
  end
  return RechargeGasStationSystem.hasEnterAct
end
function RechargeGasStationSystem.SaveRedDotCacheInfo()
  if RechargeGasStationSystem.hasEnterAct then
    return
  end
  RechargeGasStationSystem.hasEnterAct = true
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local data = {}
  data.hasEnterAct = true
  PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.eRechargeGasStation)
end
function RechargeGasStationSystem.RefreshRedDot()
  local b_show = RechargeGasStationSystem.IsEnterActivityUI()
  LobbySystem.LobbyRedPointUpdate(BP_ENUM_MODULE_RECHARGE_GAS_STATION, not b_show)
end
function RechargeGasStationSystem.IsInActivityTime()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  if ActivityNewSystem.IsActivityOpenByActivityType(ActivityType.RECHARGE_GAS_STATION) then
    return true
  end
  return false
end
function RechargeGasStationSystem.DealayRefreshRedDot()
  local time_ticker = require("common.time_ticker")
  if RechargeGasStationSystem.timer_ticker then
    time_ticker.RemoveTimer(RechargeGasStationSystem.timer_ticker)
    RechargeGasStationSystem.timer_ticker = nil
  end
  RechargeGasStationSystem.timer_ticker = time_ticker.AddTimerOnce(3, function()
    if RechargeGasStationSystem.IsInActivityTime() then
      RechargeGasStationSystem.RefreshRedDot()
    end
  end)
end
function RechargeGasStationSystem.ResetData()
  RechargeGasStationSystem.hasEnterAct = nil
end
function RechargeGasStationSystem.OnModePostSwitch(preState, nextState)
  if nextState == GameStatus.Lobby then
    RechargeGasStationSystem.DealayRefreshRedDot()
  elseif nextState == GameStatus.Login then
    RechargeGasStationSystem.ResetData()
  end
end
return RechargeGasStationSystem