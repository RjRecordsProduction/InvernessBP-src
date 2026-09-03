local NetManager = require("client.network.comm.NetManager")
local EveryDayPackHandler = {}
function EveryDayPackHandler.send_daily_direct_buy_get_cfg()
  log(bWriteLog and "[dailybuy]EveryDayPackHandler.send_daily_direct_buy_get_cfg")
  NetManager.SendPkg(1691926392)
end
function EveryDayPackHandler.on_sync_daily_direct_buy(sync_data)
  log_tree("[dailybuy]on_sync_daily_direct_buy:", sync_data)
  local EveryDayPackSystem = require("client.logic.everyday_pack.logic_everydaypack")
  EveryDayPackSystem.everydaySystemData = sync_data or {}
  if sync_data and next(sync_data) then
    EveryDayPackSystem.everydaySystemData.is_big_prize_got = sync_data and sync_data.big_prize_got_ts ~= nil
  end
  EveryDayPackSystem.uiSwitch = EveryDayPackSystem.open_ui_type.everydaypack
  EventSystem:postEvent(EVENTTYPE_EVERYDAYPACK, EVENTID_EVERYDAYPACK_SYNC_CONFIG, sync_data, EveryDayPackSystem.uiSwitch)
  EventSystem:postEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_SPECIAL_OFFER_REFRESH_PAGE)
end
function EveryDayPackHandler.send_daily_direct_buy_pre_req(day, currency)
  log(bWriteLog and "[dailybuy]EveryDayPackHandler.send_daily_direct_buy_pre_req day" .. tostring(day) .. "currency" .. tostring(currency))
  NetManager.SendPkg(461521191, day, currency)
end
function EveryDayPackHandler.on_daily_direct_buy_pre_rsp(errcode)
  log(bWriteLog and "[dailybuy]EveryDayPackHandler.on_daily_direct_buy_pre_rsp code" .. tostring(errcode))
  if errcode == 0 then
    EventSystem:postEvent(EVENTTYPE_EVERYDAYPACK, EVENTID_EVERYDAYPACK_PRE_REQ_SUCCESS)
  elseif errcode == 880307 then
    ShowNotice(errcode)
  elseif errcode == 880308 then
    log(bWriteLog and "EveryDayPackHandler.on_daily_direct_buy_pre_rsp" .. tostring(errcode))
    EventSystem:postEvent(EVENTTYPE_EVERYDAYPACK, EVENTID_EVERYDAYPACK_BUY_AGAIN_TRUE)
  else
    EventSystem:postEvent(EVENTTYPE_EVERYDAYPACK, EVENTID_EVERYDAYPACK_PRE_REQ_FAIL, errcode)
  end
end
function EveryDayPackHandler.on_daily_direct_buy_success(sync_data)
  log(bWriteLog and "[dailybuy]EveryDayPackHandler.on_daily_direct_buy_success day" .. tostring(sync_data.day) .. " buy_cnt:" .. tostring(sync_data.buy_cnt) .. "is_buy_today" .. tostring(sync_data.is_today_buy))
  local EveryDayPackSystem = require("client.logic.everyday_pack.logic_everydaypack")
  log_tree("[daiybuy] on_daily_direct_buy_success", sync_data)
  if EveryDayPackSystem.everydaySystemData then
    EveryDayPackSystem.everydaySystemData.buy_cnt = sync_data.buy_cnt or 0
    EveryDayPackSystem.RefreshTodayAndBuyStatus()
    local day = sync_data.day
    local currentDay = EveryDayPackSystem.GetToday()
    if day >= currentDay then
      EveryDayPackSystem.everydaySystemData.is_today_buy = sync_data.is_today_buy
    end
  end
  EventSystem:postEvent(EVENTTYPE_EVERYDAYPACK, EVENTID_EVERYDAYPACK_BUY_SUCCESS, sync_data)
end
function EveryDayPackHandler.send_daily_direct_buy_get_big_prize_req()
  log(bWriteLog and "[dailybuy]EveryDayPackHandler.send_daily_direct_buy_get_big_prize_req")
  NetManager.SendPkg(1096734311)
end
function EveryDayPackHandler.on_daily_direct_buy_get_big_prize_rsp(errcode, items)
  log(bWriteLog and "[dailybuy]EveryDayPackHandler.on_daily_direct_buy_get_big_prize_rsp")
  local EveryDayPackSystem = require("client.logic.everyday_pack.logic_everydaypack")
  if EveryDayPackSystem.everydaySystemData then
    EveryDayPackSystem.everydaySystemData.is_big_prize_got = true
  end
  EventSystem:postEvent(EVENTTYPE_EVERYDAYPACK, EVENTID_EVERYDAYPACK_DRAW_LOTTERY, errcode, items)
end
function EveryDayPackHandler.send_daily_direct_buy_get_little_prize_req()
  log(bWriteLog and "[dailybuy]EveryDayPackHandler.send_daily_direct_buy_get_little_prize_req")
  NetManager.SendPkg(845167183)
end
function EveryDayPackHandler.on_daily_direct_buy_get_little_prize_rsp(errcode, items)
  log(bWriteLog and "[dailybuy]EveryDayPackHandler.on_daily_direct_buy_get_little_prize_rsp")
  local EveryDayPackSystem = require("client.logic.everyday_pack.logic_everydaypack")
  if EveryDayPackSystem.everydaySystemData then
    EveryDayPackSystem.everydaySystemData.little_prize_count = EveryDayPackSystem.everydaySystemData.little_prize_count or 0
    EveryDayPackSystem.everydaySystemData.little_prize_count = EveryDayPackSystem.everydaySystemData.little_prize_count + 1
  end
  EventSystem:postEvent(EVENTTYPE_EVERYDAYPACK, EVENTID_EVERYDAYPACK_GET_LITTLE_PRIZE, errcode, items)
end
function EveryDayPackHandler.send_daily_direct_buy_success()
  log(bWriteLog and "[dailybuy]EveryDayPackHandler.send_daily_direct_buy_success")
  NetManager.SendPkg(-1970895314)
end
return EveryDayPackHandler