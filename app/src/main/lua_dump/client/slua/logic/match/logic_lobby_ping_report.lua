local logic_lobby_ping_report = {
  heartbeatRecord = {},
  toWaitRecord = {},
  toReportRecord = {},
  receivedRecordKeys = {},
  reportTimer = nil,
  sendReportTime = 120,
  heartbeatTimeout = 7000,
  connectRecord = {
    sendTimestamp = -1,
    receiveTimestamp = -1,
    ping = 0
  },
  connectTimeout = 15000,
  loginRecord = {
    sendTimestamp = -1,
    receiveTimestamp = -1,
    ping = 0
  },
  loginTimeout = 8000,
  reportType = {
    connect = 1,
    login = 2,
    heartbeat = 3
  },
  uploadSeq = 0,
  tickTimer = nil,
  lastTickTimestamp = 0,
  lastLastTickTimestamp = 0,
  isApplicationActivated = true
}
local table_pool = require("common.table_pool")
local tablePool = table_pool.Create()
local TimeUtil = require("client.common.time_util")
local RemoveHeartbeatRecord = function(key)
  tablePool:Recycle(logic_lobby_ping_report.heartbeatRecord[key])
  logic_lobby_ping_report.heartbeatRecord[key] = nil
end
local OnApplicationReactivated = function()
  logic_lobby_ping_report.isApplicationActivated = true
  for key, record in pairs(logic_lobby_ping_report.heartbeatRecord) do
    if record.ping <= 0 then
      log(bWriteLog and "Remove heartbeat record after reactivate! key: " .. key .. " record.sendTimestamp: " .. record.sendTimestamp .. " record.receiveTimestamp: " .. record.receiveTimestamp .. " record.ping:" .. record.ping)
      RemoveHeartbeatRecord(key)
    end
  end
  log(bWriteLog and "OnApplicationReactivated()")
end
local OnApplicationDeactivated = function()
  logic_lobby_ping_report.isApplicationActivated = false
  log(bWriteLog and "OnApplicationDeactivated()")
end
local SendReport = function(reportType, networkType, uploadSeq, lostRate, avgNoOutlier, stdNoOutlier, numNoOutlier, HeartNum)
  local LobbyPingReportHandler = require("client.network.Protocol.LobbyPingReportHandler")
  LobbyPingReportHandler.send_report_lobby_ping(reportType, networkType, uploadSeq, lostRate, avgNoOutlier, stdNoOutlier, numNoOutlier, HeartNum)
end
local Init = function()
  EventSystem:registEvent(EVENTTYPE_APPLICATION_ACTIVE_STATE, EVENTID_APPLICATION_REACTIVATED, OnApplicationReactivated)
  EventSystem:registEvent(EVENTTYPE_APPLICATION_ACTIVE_STATE, EVENTID_APPLICATION_DEACTIVATED, OnApplicationDeactivated)
  if logic_lobby_ping_report.lastTickTimestamp <= 0 then
    logic_lobby_ping_report.lastTickTimestamp = TimeUtil.GetMiliseconds()
  end
  if 0 >= logic_lobby_ping_report.lastLastTickTimestamp then
    logic_lobby_ping_report.lastLastTickTimestamp = logic_lobby_ping_report.lastTickTimestamp
  end
  local time_ticker = require("common.time_ticker")
  if not logic_lobby_ping_report.tickTimer then
    logic_lobby_ping_report.tickTimer = time_ticker.AddTimerLoop(0, function()
      local curTickTimestamp = TimeUtil.GetMiliseconds()
      logic_lobby_ping_report.Tick()
      logic_lobby_ping_report.lastLastTickTimestamp = logic_lobby_ping_report.lastTickTimestamp
      logic_lobby_ping_report.lastTickTimestamp = curTickTimestamp
    end, TIMER_INFINITE, time_ticker.MINIMUM_STEP_TIME)
  end
  if not logic_lobby_ping_report.reportTimer then
    logic_lobby_ping_report.reportTimer = time_ticker.AddTimerLoop(logic_lobby_ping_report.sendReportTime, function()
      logic_lobby_ping_report.SendHeartbeatReport()
    end, TIMER_INFINITE, logic_lobby_ping_report.sendReportTime)
  end
end
local Destroy = function()
  EventSystem:unregistEvent(EVENTTYPE_APPLICATION_ACTIVE_STATE, EVENTID_APPLICATION_REACTIVATED, OnApplicationReactivated)
  EventSystem:unregistEvent(EVENTTYPE_APPLICATION_ACTIVE_STATE, EVENTID_APPLICATION_DEACTIVATED, OnApplicationDeactivated)
  tablePool:RecycleAll(logic_lobby_ping_report.heartbeatRecord)
  logic_lobby_ping_report.heartbeatRecord = tablePool:Get()
  logic_lobby_ping_report.toWaitRecord = {}
  logic_lobby_ping_report.toReportRecord = {}
  local time_ticker = require("common.time_ticker")
  if logic_lobby_ping_report.reportTimer then
    time_ticker.RemoveTimer(logic_lobby_ping_report.reportTimer)
    logic_lobby_ping_report.reportTimer = nil
  end
  if logic_lobby_ping_report.tickTimer then
    time_ticker.RemoveTimer(logic_lobby_ping_report.tickTimer)
    logic_lobby_ping_report.tickTimer = nil
    logic_lobby_ping_report.lastTickTimestamp = 0
  end
end
function logic_lobby_ping_report.OnModePreSwitch(preState, nextState)
  if nextState == GameStatus.Fighting then
    Destroy()
  end
end
function logic_lobby_ping_report.OnModePostSwitch(preState, nextState)
  if nextState == GameStatus.Lobby then
    Init()
  end
end
function logic_lobby_ping_report.OnLogin(isRelogin)
  log(bWriteLog and "logic_lobby_ping_report.OnLogin(isRelogin)")
  if not isRelogin then
    logic_lobby_ping_report.SendConnectReport()
    logic_lobby_ping_report.SendLoginReport()
  end
end
function logic_lobby_ping_report.Tick()
  if not logic_lobby_ping_report.lastLastTickTimestamp then
    logic_lobby_ping_report.lastLastTickTimestamp = 0
  end
  local lastTickTime = logic_lobby_ping_report.lastTickTimestamp - logic_lobby_ping_report.lastLastTickTimestamp
  local needClearReceivedRecord = false
  for _, key in pairs(logic_lobby_ping_report.receivedRecordKeys) do
    local record = logic_lobby_ping_report.heartbeatRecord[key]
    if record then
      local deltaTime = record.receiveTimestamp - logic_lobby_ping_report.lastTickTimestamp
      if 50 < lastTickTime or 50 < deltaTime then
        RemoveHeartbeatRecord(key)
      else
        record.      end
    end
    needClearReceivedRecord = true
  end
  if needClearReceivedRecord then
    logic_lobby_ping_report.receivedRecordKeys = tablePool:Get()
  end
end
local GetHeartbeatPingInfo = function()
  local totalNum = 0
  local validNum = 0
  local lostNum = 0
  local avgPing = 0
  local countNoOutlier = 0
  local avgNoOutlier = 0
  local stdNoOutlier = 0
  local lostRate = 0
  local validSum = 0
  for _, record in pairs(logic_lobby_ping_report.toReportRecord) do
    if 0 < record.ping and record.ping <= logic_lobby_ping_report.heartbeatTimeout then
      validSum = validSum + record.ping
      validNum = validNum + 1
    else
      log(bWriteLog and "LOST!!! record.sendTimestamp: " .. record.sendTimestamp .. " record.receiveTimestamp: " .. record.receiveTimestamp .. " record.ping: " .. record.ping)
      lostNum = lostNum + 1
    end
    totalNum = totalNum + 1
  end
  if 0 < validNum then
    avgPing = validSum / validNum
    local stdv = 0
    for _, record in pairs(logic_lobby_ping_report.toReportRecord) do
      if 0 < record.ping then
        stdv = stdv + (record.ping - avgPing) * (record.ping - avgPing)
      end
    end
    stdv = math.sqrt(stdv / validNum)
    local threshold = avgPing + 3 * stdv
    local totalNoOutlier = 0
    for _, record in pairs(logic_lobby_ping_report.toReportRecord) do
      if 0 < record.ping and record.ping <= logic_lobby_ping_report.heartbeatTimeout and threshold > record.ping then
        totalNoOutlier = totalNoOutlier + record.ping
        countNoOutlier = countNoOutlier + 1
      end
    end
    if 1 < countNoOutlier then
      avgNoOutlier = totalNoOutlier / countNoOutlier
      for _, record in pairs(logic_lobby_ping_report.toReportRecord) do
        if threshold > record.ping then
          stdNoOutlier = stdNoOutlier + (record.ping - avgNoOutlier) * (record.ping - avgNoOutlier)
        end
      end
      stdNoOutlier = math.sqrt(stdNoOutlier / (countNoOutlier - 1))
    end
  end
  if 0 < validNum + lostNum then
    lostRate = lostNum / (validNum + lostNum)
  end
  log(bWriteLog and "validNum: " .. validNum .. " lostNum: " .. lostNum .. " avgPing: " .. avgPing)
  local info = {
    reportType = logic_lobby_ping_report.reportType.heartbeat,
    networkType = FuncUtil.GetNetworkTypeAsNum(),
    uploadSeq = logic_lobby_ping_report.uploadSeq,
    lostRate = lostRate,
    avgNoOutlier = avgNoOutlier,
    stdNoOutlier = stdNoOutlier,
    numNoOutlier = totalNum - countNoOutlier,
    HeartNum = totalNum
  }
  return info
end
local PreprocessHeartbeatRecord = function()
  local curTimestamp = TimeUtil.GetMiliseconds()
  logic_lobby_ping_report.toReportRecord = {}
  logic_lobby_ping_report.toWaitRecord = {}
  for i, record in pairs(logic_lobby_ping_report.heartbeatRecord) do
    if record.ping <= 0 and curTimestamp - record.sendTimestamp <= logic_lobby_ping_report.heartbeatTimeout then
      log(bWriteLog and "toWait!!! record.sendTimestamp: " .. record.sendTimestamp .. " curTimestamp: " .. curTimestamp .. " curTimestamp - record.sendTimestamp: " .. curTimestamp - record.sendTimestamp)
      logic_lobby_ping_report.toWaitRecord[i] = record
    else
      logic_lobby_ping_report.toReportRecord[i] = record
    end
  end
end
local PostprocessHeartbeatRecord = function()
  logic_lobby_ping_report.heartbeatRecord = logic_lobby_ping_report.toWaitRecord
end
function logic_lobby_ping_report.OnSendHeartbeat(key)
  if not GameStatus.IsInLobbyOrMainCity() then
    return
  end
  local curTimestamp = TimeUtil.GetMiliseconds()
  local record = tablePool:Get()
  record.sendTimestamp = curTimestamp
  record.receiveTimestamp = -1
  record.ping = 0
  record.deltaTime = 0
  logic_lobby_ping_report.heartbeatRecord[key] = record
end
function logic_lobby_ping_report.OnReceiveHeartbeat(key)
  if not GameStatus.IsInLobbyOrMainCity() then
    return
  end
  local curTimestamp = TimeUtil.GetMiliseconds()
  local record = logic_lobby_ping_report.heartbeatRecord[key]
  if not record then
    return
  end
  if not logic_lobby_ping_report.isApplicationActivated then
    log(bWriteLog and "Remove heartbeat record when packet is received in background!")
    RemoveHeartbeatRecord(key)
    return
  end
  record.receiveTimestamp = curTimestamp
  record.ping = record.receiveTimestamp - record.sendTimestamp
  table.insert(logic_lobby_ping_report.receivedRecordKeys, key)
end
function logic_lobby_ping_report.SendHeartbeatReport()
  if not GameStatus.IsInLobbyOrMainCity() then
    return
  end
  PreprocessHeartbeatRecord()
  local info = GetHeartbeatPingInfo()
  SendReport(info.reportType, info.networkType, info.uploadSeq, info.lostRate, info.avgNoOutlier, info.stdNoOutlier, info.numNoOutlier, info.HeartNum)
  PostprocessHeartbeatRecord()
  logic_lobby_ping_report.uploadSeq = logic_lobby_ping_report.uploadSeq + 1
end
function logic_lobby_ping_report.GetLobbyDelay()
  if not GameStatus.IsInLobbyOrMainCity() then
    return 0
  end
  local info = GetHeartbeatPingInfo()
  return info.avgNoOutlier
end
local ResetConnectRecord = function()
  local record = logic_lobby_ping_report.connectRecord
  record.sendTimestamp = -1
  record.receiveTimestamp = -1
  record.ping = 0
end
local GetConnectPingInfo = function()
  local info = {
    reportType = logic_lobby_ping_report.reportType.connect,
    networkType = FuncUtil.GetNetworkTypeAsNum(),
    uploadSeq = logic_lobby_ping_report.uploadSeq,
    lostRate = 0.0,
    avgNoOutlier = 0,
    stdNoOutlier = 0.0,
    numNoOutlier = 0,
    HeartNum = 1
  }
  if 0 < logic_lobby_ping_report.connectRecord.ping and logic_lobby_ping_report.connectRecord.ping <= logic_lobby_ping_report.connectTimeout then
    info.lostRate = 0.0
    info.avgNoOutlier = logic_lobby_ping_report.connectRecord.ping
  else
    info.lostRate = 1.0
    info.avgNoOutlier = 0.0
  end
  return info
end
function logic_lobby_ping_report.OnSendConnectToURL()
  logic_lobby_ping_report.connectRecord.sendTimestamp = TimeUtil.GetMiliseconds()
end
function logic_lobby_ping_report.OnReceiveConnected(isConnected)
  local curTimestamp = TimeUtil.GetMiliseconds()
  local record = logic_lobby_ping_report.connectRecord
  if isConnected then
    record.receiveTimestamp = curTimestamp
    record.ping = record.receiveTimestamp - record.sendTimestamp
  end
end
function logic_lobby_ping_report.SendConnectReport()
  local info = GetConnectPingInfo()
  SendReport(info.reportType, info.networkType, info.uploadSeq, info.lostRate, info.avgNoOutlier, info.stdNoOutlier, info.numNoOutlier, info.HeartNum)
  ResetConnectRecord()
  logic_lobby_ping_report.uploadSeq = logic_lobby_ping_report.uploadSeq + 1
end
local ResetLoginRecord = function()
  local record = logic_lobby_ping_report.loginRecord
  record.sendTimestamp = -1
  record.receiveTimestamp = -1
  record.ping = 0
end
local GetLoginPingInfo = function()
  local info = {
    reportType = logic_lobby_ping_report.reportType.login,
    networkType = FuncUtil.GetNetworkTypeAsNum(),
    uploadSeq = logic_lobby_ping_report.uploadSeq,
    lostRate = 0.0,
    avgNoOutlier = 0,
    stdNoOutlier = 0.0,
    numNoOutlier = 0,
    HeartNum = 1
  }
  if 0 < logic_lobby_ping_report.loginRecord.ping and logic_lobby_ping_report.loginRecord.ping <= logic_lobby_ping_report.loginTimeout then
    info.lostRate = 0.0
    info.avgNoOutlier = logic_lobby_ping_report.loginRecord.ping
  else
    info.lostRate = 1.0
    info.avgNoOutlier = 0.0
  end
  return info
end
function logic_lobby_ping_report.OnSendLogin()
  logic_lobby_ping_report.loginRecord.sendTimestamp = TimeUtil.GetMiliseconds()
end
function logic_lobby_ping_report.OnReceiveLoginRsp(isSuccess)
  local curTimestamp = TimeUtil.GetMiliseconds()
  local record = logic_lobby_ping_report.loginRecord
  if isSuccess then
    record.receiveTimestamp = curTimestamp
    record.ping = record.receiveTimestamp - record.sendTimestamp
  end
end
function logic_lobby_ping_report.SendLoginReport()
  local info = GetLoginPingInfo()
  SendReport(info.reportType, info.networkType, info.uploadSeq, info.lostRate, info.avgNoOutlier, info.stdNoOutlier, info.numNoOutlier, info.HeartNum)
  ResetLoginRecord()
  logic_lobby_ping_report.uploadSeq = logic_lobby_ping_report.uploadSeq + 1
end
return logic_lobby_ping_report