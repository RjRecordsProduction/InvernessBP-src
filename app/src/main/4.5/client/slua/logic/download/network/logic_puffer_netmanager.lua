local PufferNetManager = {
  TimeOut = false,
  IsMeasuringSpeed = false,
  DynamicSpeedSwitch = false,
  IsInFastSpeed = false,
  FullSpeed = 0,
  LimitSpeed = 0,
  MeasureFullSpeedCD = 35,
  MeasureFullSpeedTime = 0,
  DebugFullSpeedTime = 0,
  MeasureFullSpeedTimer = nil,
  HeartReserveSpeed = 60,
  BaseReserveSpeed = 100,
  ProtocolReserveSpeed = 200,
  UseNewTimeOutHandler = true,
  NewTimeOutParams = {
    TimeOutSpeedDownTime = 10,
    ReconnectMeasureTime = 5,
    SpeedDownRate = 2
  },
  TimeOutTimer = nil,
  MeasureTimer = nil,
  GM_TEST = false
}
local KB = 1024
local MB = 1048576
local NoLimitSpeed = 100 * MB
local PufferSwitch = require("client.slua.logic.download.puffer_switch")
local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
function PufferNetManager.Tick(DeltaTime)
  PufferNetManager.DebugFullSpeedTime = PufferNetManager.DebugFullSpeedTime + DeltaTime
  if PufferNetManager.DebugFullSpeedTime >= 0.5 then
    EventSystem:postEvent(EVENTTYPE_DEBUG, EVENTID_DEBUG_PUFFER_SPEED)
    PufferNetManager.DebugFullSpeedTime = 0
  end
  PufferNetManager.MeasureFullSpeedTime = PufferNetManager.MeasureFullSpeedTime + DeltaTime
  if PufferNetManager.MeasureFullSpeedTime >= PufferNetManager.MeasureFullSpeedCD then
    log(bWriteLog and "PufferNetManager.Tick time to measure FullSpeed")
    local cnt = 0
    cnt = PufferManager.GetDownloadingCnt()
    if 0 < cnt then
      local speed = GCPufferDownloader.GetCurrentSpeed(Puffer) / 1024
      if speed then
        gem_report_utils.ReportLobbyClickEvent(gem_report_utils.SubEventName_DownloadSpeed, speed)
        local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
        tlog_report_utils.ReportTLogEvent(TLogEventDefine.DownloadSpeed, 0, tostring(speed))
      end
    end
    PufferNetManager.MeasureFullSpeed(true)
    PufferNetManager.MeasureFullSpeedTime = 0
  end
end
function PufferNetManager.NetTypeChange(eventType, eventID, netType)
  if not GameStatus.IsInLobbyOrMainCity() then
    return
  end
  log(bWriteLog and "NetTypeChange netType new_type = " .. tostring(netType.new_type))
  if netType.new_type then
    if netType.new_type == "Wifi" then
      PufferNetManager.MeasureFullSpeed(true)
      if not PufferSwitch.GetAutoDownloadWIFISwitch() then
        PufferManager.PauseAllDownloadTasks()
        EventSystem:postEvent(EVENTTYPE_DOWNLOAD, EVENTID_ODPAKS_STOP_ALL_TASK)
      end
    else
      local cnt = PufferManager.GetDownloadingCnt()
      if 0 < cnt and (not PufferSwitch.AutoDownloadCfg.AutoDownload4GSwitch or netType.new_type == "error" or netType.new_type == "NULL") then
        PufferManager.PauseAllDownloadTasks()
        EventSystem:postEvent(EVENTTYPE_DOWNLOAD, EVENTID_ODPAKS_STOP_ALL_TASK)
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_MATCH_UPDATE_ZONE)
end
function PufferNetManager.SetRegionReserveSpeed()
  local cfg = CDataTable.GetTableData("RegionConfig", DataMgr.RegionData.region)
  if DataMgr.RegionData.setRegionList and next(DataMgr.RegionData.setRegionList) then
    log(bWriteLog and "PufferNetManager.SetRegionReserveSpeed DataMgr.RegionData.setRegionList[1].region = " .. DataMgr.RegionData.setRegionList[1].region)
    cfg = CDataTable.GetTableData("RegionConfig", DataMgr.RegionData.setRegionList[1].region)
  end
  local StringUtil = require("common.string_util")
  if cfg and cfg.reserveSpeed ~= "" then
    log(bWriteLog and "PufferNetManager.SetRegionReserveSpeed cfg.reserveSpeed = " .. tostring(cfg.reserveSpeed))
    local list = StringUtil.Split(cfg.reserveSpeed, "|")
    PufferNetManager.HeartReserveSpeed = tonumber(list[1]) or PufferNetManager.HeartReserveSpeed
    PufferNetManager.BaseReserveSpeed = tonumber(list[2]) or PufferNetManager.BaseReserveSpeed
    PufferNetManager.ProtocolReserveSpeed = tonumber(list[2]) or PufferNetManager.ProtocolReserveSpeed
  end
end
function PufferNetManager.MeasureFullSpeed(bForce)
  if not PufferNetManager.DynamicSpeedSwitch then
    log(bWriteLog and "PufferNetManager.MeasureFullSpeed DynamicSpeedSwitch = false")
    return
  end
  if PufferNetManager.MeasureFullSpeedTimer then
    return
  end
  if not bForce then
    if PufferNetManager.FullSpeed > 0 then
      return
    end
    if 0 >= PufferManager.GetDownloadingCnt() then
      return
    end
  end
  log(bWriteLog and "PufferNetManager.MeasureFullSpeed start measure")
  if PufferDownloader.isFightingMode() then
    PufferNetManager.SetImmDLMaxSpeed(NoLimitSpeed)
  else
    PufferNetManager.SetImmDLMaxSpeed(NoLimitSpeed)
  end
  local time_ticker = require("common.time_ticker")
  PufferNetManager.MeasureFullSpeedTimer = time_ticker.AddTimerOnce(3, function()
    PufferNetManager.FullSpeed = GCPufferDownloader.GetCurrentSpeed(Puffer)
    PufferNetManager.SetDownloadLimitSpeed()
    PufferNetManager.MeasureFullSpeedTimer = nil
  end)
end
function PufferNetManager.SetDownloadLimitSpeed()
  if PufferNetManager.DynamicSpeedSwitch then
    if PufferNetManager.IsInFastSpeed then
      PufferNetManager.SetDownloadFastSpeed()
    else
      PufferNetManager.SetDownloadLimitSpeedNew()
    end
  end
end
function PufferNetManager.SetDownloadLimitSpeedNew()
  log(bWriteLog and "PufferNetManager.SetDownloadLimitSpeedNew FullSpeed = " .. tostring(PufferNetManager.FullSpeed))
  if PufferNetManager.FullSpeed <= 0 then
    return
  end
  local reserveSpeed = 0
  if PufferNetManager.FullSpeed <= 2 * PufferNetManager.ProtocolReserveSpeed * KB then
    reserveSpeed = PufferNetManager.BaseReserveSpeed * KB
  else
    reserveSpeed = PufferNetManager.ProtocolReserveSpeed * KB
  end
  local limitSpeed = 0
  if PufferNetManager.FullSpeed - reserveSpeed > 0 then
    limitSpeed = PufferNetManager.FullSpeed - reserveSpeed
  end
  PufferNetManager.SetImmDLMaxSpeed(limitSpeed)
end
function PufferNetManager.SetDownloadFastSpeed()
  log(bWriteLog and "PufferNetManager.SetDownloadFastSpeed FullSpeed = " .. tostring(PufferNetManager.FullSpeed))
  if PufferNetManager.FullSpeed <= 0 then
    return
  end
  if 0 >= PufferManager.GetDownloadingCnt() then
    return
  end
  local reserveSpeed = 0
  if PufferNetManager.FullSpeed <= 2 * PufferNetManager.ProtocolReserveSpeed * KB then
    reserveSpeed = PufferNetManager.HeartReserveSpeed * KB
  else
    reserveSpeed = PufferNetManager.ProtocolReserveSpeed * KB
  end
  local limitSpeed = 0
  if PufferNetManager.FullSpeed - reserveSpeed > 0 then
    limitSpeed = PufferNetManager.FullSpeed - reserveSpeed
  end
  PufferNetManager.SetImmDLMaxSpeed(limitSpeed)
end
function PufferNetManager.OnNetTimeOut()
  if PufferNetManager.GM_TEST then
    log_format("PufferNetManager.OnNetTimeOut. TEST RETURN")
    return
  end
  PufferNetManager.TimeOut = true
  if PufferNetManager.LimitSpeed > 0 then
    if PufferNetManager.UseNewTimeOutHandler then
      PufferNetManager._OnNetTimeOutNew()
    else
      PufferNetManager._OnNetTimeOutOld()
    end
    PufferNetManager.MeasureFullSpeedCD = 999999
  end
end
function PufferNetManager.OnNetRecvPkg()
  if PufferNetManager.GM_TEST then
    log_format("PufferNetManager.OnNetRecvPkg. TEST RETURN")
    return
  end
  if PufferNetManager.TimeOut then
    log(bWriteLog and "PufferNetManager.OnNetRecvPkg")
    PufferNetManager.RemoveTimeoutTimer()
    if PufferNetManager.UseNewTimeOutHandler then
      local time_ticker = require("common.time_ticker")
      log_format("PufferNetManager.OnNetRecvPkg. add Timer")
      PufferNetManager.MeasureTimer = time_ticker.AddTimerOnce(PufferNetManager.NewTimeOutParams.ReconnectMeasureTime, function()
        PufferNetManager.MeasureFullSpeedTime = PufferNetManager.MeasureFullSpeedCD
        PufferNetManager.MeasureTimer = nil
      end)
    end
    PufferNetManager.MeasureFullSpeedCD = 35
    PufferNetManager.TimeOut = false
  end
end
function PufferNetManager.RemoveTimeoutTimer()
  log_format("PufferNetManager.RemoveTimeoutTimer.")
  local time_ticker = require("common.time_ticker")
  if PufferNetManager.TimeOutTimer then
    time_ticker.RemoveTimer(PufferNetManager.TimeOutTimer)
    PufferNetManager.TimeOutTimer = nil
    log_format("PufferNetManager.RemoveTimeoutTimer. remove TimeOutTimer")
  end
  if PufferNetManager.MeasureTimer then
    time_ticker.RemoveTimer(PufferNetManager.MeasureTimer)
    PufferNetManager.MeasureTimer = nil
    log_format("PufferNetManager.RemoveTimeoutTimer. remove MeasureTimer")
  end
end
function PufferNetManager._OnNetTimeOutNew()
  log(bWriteLog and "PufferNetManager._OnNetTimeOutNew")
  if PufferNetManager.TimeOutTimer then
    return
  end
  local time_ticker = require("common.time_ticker")
  log_format("PufferNetManager._OnNetTimeOutNew. Add Timer")
  PufferNetManager.TimeOutTimer = time_ticker.AddTimerLoop(0, function()
    if not PufferNetManager.TimeOut then
      PufferNetManager.RemoveTimeoutTimer()
      return
    end
    log(bWriteLog and "PufferNetManager._OnNetTimeOutNew LimitSpeed = " .. tostring(PufferNetManager.LimitSpeed))
    PufferNetManager.LimitSpeed = PufferNetManager.LimitSpeed / PufferNetManager.NewTimeOutParams.SpeedDownRate
    PufferNetManager.SetImmDLMaxSpeed(PufferNetManager.LimitSpeed)
  end, TIMER_INFINITE, PufferNetManager.NewTimeOutParams.TimeOutSpeedDownTime)
end
function PufferNetManager._OnNetTimeOutOld()
  log(bWriteLog and "PufferNetManager._OnNetTimeOutOld")
  log(bWriteLog and "PufferNetManager._OnNetTimeOutOld LimitSpeed = " .. tostring(PufferNetManager.LimitSpeed))
  PufferNetManager.LimitSpeed = PufferNetManager.LimitSpeed / 2
  PufferNetManager.SetImmDLMaxSpeed(PufferNetManager.LimitSpeed)
end
function PufferNetManager.SetImmDLMaxSpeed(speed)
  if not speed then
    return
  end
  if speed < 0 then
    speed = 0
  end
  if not PufferDownloader.PufferJsonDownloadReturn and speed == 0 then
    speed = 200 * KB
  end
  if PufferNetManager.TestMxSpeed and speed > PufferNetManager.TestMxSpeed then
    log_format("PufferNetManager.SetImmDLMaxSpeed. resetSpeed " .. tostring(speed))
    speed = PufferNetManager.TestMxSpeed
  end
  PufferNetManager.LimitSpeed = math.floor(speed)
  if PufferNetManager.LimitSpeed == 0 then
    PufferNetManager.LimitSpeed = 1 * KB
  end
  log(bWriteLog and "PufferNetManager.SetImmDLMaxSpeed LimitSpeed = " .. tostring(PufferNetManager.LimitSpeed))
  local result = GCPufferDownloader.SetImmDLMaxSpeed(Puffer, PufferNetManager.LimitSpeed)
  if not result then
    PufferNetManager.DynamicSpeedSwitch = false
    log(bWriteLog and "PufferNetManager.OnNetTimeOut SetImmDLMaxSpeed fail")
  end
end
return PufferNetManager