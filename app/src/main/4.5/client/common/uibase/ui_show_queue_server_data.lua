local TimeUtil = require("client.common.time_util")
local timer_ticker = require("common.time_ticker")
local BatchReportDelay = 3
local ui_show_queue_server_data = {
  ServerData = {},
  isDirty = false,
  reportTimer = nil
}
function ui_show_queue_server_data.SetServerData(data)
  log_tree("ui_show_queue_server_data.SetServerData data = ", data)
  ui_show_queue_server_data.ServerData = data ~= nil and data or {}
  if ui_show_queue_server_data.ServerData.LastTime and not TimeUtil.IsSameDay(ui_show_queue_server_data.ServerData.LastTime, TimeUtil.GetServerTimeInSec()) then
    ui_show_queue_server_data._OnNextDayZeroCome()
  end
end
function ui_show_queue_server_data._OnNextDayZeroCome()
  log(bWriteLog and "ui_show_queue_server_data._OnNextDayZeroCome")
  local showTable = {}
  showTable.LastTime = TimeUtil.GetServerTimeInSec()
  local LogicLobbyPopuiHandler = require("client.network.Protocol.LogicLobbyPopuiHandler")
  LogicLobbyPopuiHandler.send_report_popui_show_info_req(showTable)
  LogicLobbyPopuiHandler.send_get_popui_show_count_req()
end
function ui_show_queue_server_data.GetCurShowCount(UIKey, timeSpanIndex)
  log(bWriteLog and "ui_show_queue_server_data._GetCurShowCount UIKey = " .. tostring(UIKey) .. " timeSpanIndex = " .. tostring(timeSpanIndex))
  if not ui_show_queue_server_data.ServerData or not ui_show_queue_server_data.ServerData[UIKey] then
    return 0
  end
  local count = ui_show_queue_server_data.ServerData[UIKey].ShowCountList[timeSpanIndex]
  if count then
    return count
  end
  return 0
end
function ui_show_queue_server_data._FlushReport(skipRemoveTimer)
  if ui_show_queue_server_data.reportTimer and not skipRemoveTimer then
    timer_ticker.RemoveTimer(ui_show_queue_server_data.reportTimer)
  end
  ui_show_queue_server_data.reportTimer = nil
  if not ui_show_queue_server_data.isDirty then
    return
  end
  ui_show_queue_server_data.isDirty = false
  local LogicLobbyPopuiHandler = require("client.network.Protocol.LogicLobbyPopuiHandler")
  LogicLobbyPopuiHandler.send_report_popui_show_info_req(ui_show_queue_server_data.ServerData)
end
function ui_show_queue_server_data.SetShowInfo(UIKey, timeSpanIndex, Count)
  log(bWriteLog and "ui_show_queue_server_data.SetShowInfo UIKey = " .. tostring(UIKey) .. " timeSpanIndex = " .. tostring(timeSpanIndex) .. " Count = " .. tostring(Count))
  if not ui_show_queue_server_data.ServerData[UIKey] then
    ui_show_queue_server_data.ServerData[UIKey] = {}
    ui_show_queue_server_data.ServerData[UIKey].ShowCountList = {}
  end
  ui_show_queue_server_data.ServerData[UIKey].ShowCountList[timeSpanIndex] = Count
  ui_show_queue_server_data.ServerData.LastTime = TimeUtil.GetServerTimeInSec()
  ui_show_queue_server_data.isDirty = true
  if not ui_show_queue_server_data.reportTimer then
    ui_show_queue_server_data.reportTimer = timer_ticker.AddTimerOnce(BatchReportDelay, function()
      ui_show_queue_server_data._FlushReport(true)
    end)
  end
end
function ui_show_queue_server_data.Clear()
  ui_show_queue_server_data._FlushReport()
  ui_show_queue_server_data.ServerData = {}
end
return ui_show_queue_server_data