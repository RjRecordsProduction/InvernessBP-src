local ui_show_queue_server_data = {
  ServerData = {}
}
function ui_show_queue_server_data.SetServerData(data)
  log_tree("ui_show_queue_server_data.SetServerData data = ", data)
  ui_show_queue_server_data.ServerData = data ~= nil and data or {}
  if ui_show_queue_server_data.ServerData.LastTime then
    local TimeUtil = require("client.common.time_util")
    if not TimeUtil.IsSameDay(ui_show_queue_server_data.ServerData.LastTime, TimeUtil.GetServerTimeInSec()) then
      ui_show_queue_server_data._OnNextDayZeroCome()
    end
  end
end
function ui_show_queue_server_data._OnNextDayZeroCome()
  log(bWriteLog and "ui_show_queue_server_data._OnNextDayZeroCome")
  local showTable = {}
  local LogicLobbyPopuiHandler = require("client.network.Protocol.LogicLobbyPopuiHandler")
  local TimeUtil = require("client.common.time_util")
  showTable.LastTime = TimeUtil.GetServerTimeInSec()
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
function ui_show_queue_server_data.SetShowInfo(UIKey, timeSpanIndex, Count)
  log(bWriteLog and "ui_show_queue_server_data.SetShowInfo UIKey = " .. tostring(UIKey) .. " timeSpanIndex = " .. tostring(timeSpanIndex) .. " Count = " .. tostring(Count))
  local LogicLobbyPopuiHandler = require("client.network.Protocol.LogicLobbyPopuiHandler")
  if not ui_show_queue_server_data.ServerData[UIKey] then
    ui_show_queue_server_data.ServerData[UIKey] = {}
    ui_show_queue_server_data.ServerData[UIKey].ShowCountList = {}
  end
  ui_show_queue_server_data.ServerData[UIKey].ShowCountList[timeSpanIndex] = Count
  local TimeUtil = require("client.common.time_util")
  ui_show_queue_server_data.ServerData.LastTime = TimeUtil.GetServerTimeInSec()
  LogicLobbyPopuiHandler.send_report_popui_show_info_req(ui_show_queue_server_data.ServerData)
end
function ui_show_queue_server_data.Clear()
  ui_show_queue_server_data.ServerData = {}
end
return ui_show_queue_server_data