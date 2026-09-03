local ShadowZoneSystem = {
  pingTimer = nil,
  nPingTime = 0,
  nPingMaxNum = 0,
  nReceivePingNum = 0,
  nPingAllCount = 0,
  bIsPingAll = true,
  receivePingList = {},
  bIsStartPing = false,
  nPingTimeoutTime = 0,
  nReportPingCount = 0,
  unresolvableRecord = {},
  zoneMenuAllReceiveList = {},
  bIsPingAllInZoneMenu = false,
  bShouldRecPingMethod = false,
  pingMethodRecord = {},
  pingMethodRecordCount = 0
}
local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
local C_PingCheckFrequency = 0.5
local C_PingRecordReportCount = 5
local E_PingMethodType = {thread = 0, epoll = 1}
local EIcmpResponseStatus = {
  Success = 0,
  Timeout = 1,
  Unreachable = 2,
  Unresolvable = 3,
  InternalError = 4,
  NotImplemented = 5
}
function ShadowZoneSystem.OnLogin(bReLogin)
  if bReLogin then
    ShadowZoneSystem.ResetShadowServer()
    ShadowZoneSystem.ResetZoneMenuCheckList()
    ShadowZoneSystem.ResetPingMethodRecord()
  end
end
function ShadowZoneSystem.OnModePostSwitch(preState, nextState)
  log(bWriteLog and "[edward][logic_match] ShadowZoneSystem.OnModePostSwitch, nextState = " .. tostring(nextState))
  if GameStatus.IsInLobbyOrMainCity() and slua_GameFrontendHUD.UDPPingCollector and slua_GameFrontendHUD.UDPPingCollector.UDPPingShadowResultToLuaDelegate then
    slua_GameFrontendHUD.UDPPingCollector.UDPPingShadowResultToLuaDelegate:Add(ShadowZoneSystem.OnReceiveServerPing)
  end
end
function ShadowZoneSystem.OnModePreSwitch(preState, nextState)
  log(bWriteLog and "[edward][logic_shadow_zone] ShadowZoneSystem.OnModePreSwitch, nextState = " .. tostring(nextState))
  if nextState ~= GameStatus.Lobby then
    if slua_GameFrontendHUD.UDPPingCollector and slua_GameFrontendHUD.UDPPingCollector.UDPPingShadowResultToLuaDelegate then
      slua_GameFrontendHUD.UDPPingCollector.UDPPingShadowResultToLuaDelegate:Clear()
    end
    ShadowZoneSystem.StopPingShadowServer()
    if nextState == GameStatus.Login then
      ShadowZoneSystem.ResetShadowServer()
      ShadowZoneSystem.ResetZoneMenuCheckList()
    end
  end
end
function ShadowZoneSystem.InitOnlyOne()
  EventSystem:registEvent(EVENTTYPE_APPLICATION_ACTIVE_STATE, EVENTID_APPLICATION_DEACTIVATED, ShadowZoneSystem.OnApplicationDeactivated)
  EventSystem:registEvent(EVENTTYPE_LOBBY, EVENTID_LOADING_FINISH, ShadowZoneSystem.HandleAfterLoadingFinish)
end
function ShadowZoneSystem.OnApplicationDeactivated()
  if GameStatus.IsInLobbyOrMainCity() then
    ShadowZoneSystem.CheckLastPingReceiveAtOnce()
  end
end
function ShadowZoneSystem.SyncShadowServer(shadow_pingsvr_list, shadow_pingsvr_param, shadow_ping_wartermark_map, should_recheck_allzone, thread_epoll_module_params)
  log_tree("[DeanJYT] ShadowZoneSystem.SyncShadowServer shadow_pingsvr_list", shadow_pingsvr_list)
  log_tree("[DeanJYT] ShadowZoneSystem.SyncShadowServer shadow_pingsvr_param", shadow_pingsvr_param)
  log_tree("[DeanJYT] ShadowZoneSystem.SyncShadowServer thread_epoll_module_params", thread_epoll_module_params)
  log(bWriteLog and "[DeanJYT] ShadowZoneSystem.SyncShadowServer should_recheck_allzone = " .. tostring(should_recheck_allzone))
  ShadowZoneSystem.shadowPingsvrList = shadow_pingsvr_list
  for _, svrList in pairs(ShadowZoneSystem.shadowPingsvrList) do
    for k, v in pairs(svrList) do
      if not v then
        svrList[k] = nil
      end
    end
  end
  ShadowZoneSystem.shadowPingsvrParam = shadow_pingsvr_param
  ShadowZoneSystem.shadowPingWatermarkMap = shadow_ping_wartermark_map or {}
  ShadowZoneSystem.should_recheck_allzone = should_recheck_allzone or false
  thread_epoll_module_params = thread_epoll_module_params or {}
  thread_epoll_module_params.take_effect_module = thread_epoll_module_params.take_effect_module or 0
  ShadowZoneSystem.  if not ShadowZoneSystem.thread_epoll_module_params.take_effect_module then
    ShadowZoneSystem.thread_epoll_module_params.take_effect_module = 0
  end
  if shadow_pingsvr_param and shadow_pingsvr_param.svr_port then
    log(bWriteLog and "[edward][logic_match] ShadowZoneSystem.SyncShadowServer, port =" .. shadow_pingsvr_param.svr_port)
  end
  local UDPPingCollector = slua_GameFrontendHUD.UDPPingCollector
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  local take_module = 1
  if Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS then
    take_module = HDmpveRemote.HDmpveRemoteConfigGetInt("PingTakeEffectIOS", -1)
  else
    take_module = HDmpveRemote.HDmpveRemoteConfigGetInt("PingTakeEffect", 1)
  end
  if 0 <= take_module then
    thread_epoll_module_params.take_effect_module = take_module
  else
    if not Client.IsReleaseVersion(NetInterface) then
      thread_epoll_module_params.take_effect_module = 1
    elseif Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS then
      thread_epoll_module_params.take_effect_module = 0
      thread_epoll_module_params.epoll_report_tlog = false
      log(bWriteLog and "SyncShadowServer iOS force closed")
    end
    take_module = thread_epoll_module_params.take_effect_module or 0
  end
  log(bWriteLog and "SyncShadowServer take_module:" .. tostring(take_module) .. " take_effect_ios:" .. tostring(ShadowZoneSystem.thread_epoll_module_params.take_effect_ios))
  local thread_log = HDmpveRemote.HDmpveRemoteConfigGetInt("PingThreadReportTlog", -1)
  if thread_log < 0 then
    thread_log = thread_epoll_module_params.thread_report_tlog and 1 or 0
  else
    thread_epoll_module_params.thread_report_tlog = thread_log
  end
  local epoll_log = HDmpveRemote.HDmpveRemoteConfigGetInt("PingEpollReportTlog", -1)
  if epoll_log < 0 then
    epoll_log = thread_epoll_module_params.epoll_report_tlog and 1 or 0
  else
    thread_epoll_module_params.epoll_report_tlog = epoll_log
  end
  UDPPingCollector:SetPingSystemControlFlag(take_module, thread_log, epoll_log)
  ShadowZoneSystem.ResetPingMethodRecord()
  if not thread_epoll_module_params.thread_report_tlog and not thread_epoll_module_params.epoll_report_tlog then
    ShadowZoneSystem.bShouldRecPingMethod = false
  else
    ShadowZoneSystem.bShouldRecPingMethod = true
  end
end
function ShadowZoneSystem.UpdateShadowServer(updated_shadow_pingsvr)
  log(bWriteLog and "[DeanJYT] ShadowZoneSystem.UpdateShadowServer")
  for k, v in pairs(updated_shadow_pingsvr) do
    for _, svrList in pairs(ShadowZoneSystem.shadowPingsvrList) do
      if not v then
        svrList[k] = nil
      else
        svrList[k] = v
      end
    end
  end
  log_tree("[DeanJYT] ShadowZoneSystem.UpdateShadowServer ShadowZoneSystem.shadowPingsvrList after update = ", ShadowZoneSystem.shadowPingsvrList)
end
function ShadowZoneSystem.ResetShadowServer()
  ShadowZoneSystem.nPingMaxNum = 0
  ShadowZoneSystem.nPingTime = 0
  ShadowZoneSystem.nPingAllCount = 0
  ShadowZoneSystem.nReceivePingNum = 0
  ShadowZoneSystem.bIsPingAll = true
  ShadowZoneSystem.receivePingList = {}
  ShadowZoneSystem.bIsStartPing = false
  ShadowZoneSystem.nPingTimeoutTime = 0
  ShadowZoneSystem.nReportPingCount = 0
end
function ShadowZoneSystem.ResetPartShadowServer()
  ShadowZoneSystem.nPingMaxNum = 0
  ShadowZoneSystem.nPingTime = 0
  ShadowZoneSystem.nReceivePingNum = 0
  ShadowZoneSystem.receivePingList = {}
  ShadowZoneSystem.bIsStartPing = true
  ShadowZoneSystem.nPingTimeoutTime = 0
end
function ShadowZoneSystem.ResetZoneMenuCheckList()
  print(bWriteLog and "[DeanJYT] ShadowZoneSystem.ResetZoneMenuCheckList")
  ShadowZoneSystem.zoneMenuAllReceiveList = {}
  ShadowZoneSystem.bShouldRecPingMethod = false
end
function ShadowZoneSystem.ResetPingMethodRecord()
  print(bWriteLog and "[DeanJYT] ShadowZoneSystem.ResetZoneMenuCheckList")
  ShadowZoneSystem.pingMethodRecord = {}
  ShadowZoneSystem.bIsPingAllInZoneMenu = false
  ShadowZoneSystem.pingMethodRecordCount = 0
end
function ShadowZoneSystem.StartZoneMenuCheckPing()
  print(bWriteLog and "[DeanJYT] ShadowZoneSystem.StartZoneMenuCheckPing")
  if not ShadowZoneSystem.should_recheck_allzone then
    print(bWriteLog and "[DeanJYT] ShadowZoneSystem.StartZoneMenuCheckPing switch not open, do not process")
    return
  end
  if ShadowZoneSystem.bIsPingAllInZoneMenu then
    print(bWriteLog and "[DeanJYT] ShadowZoneSystem.StartZoneMenuCheckPing is checking now, do not need to restart")
    return
  end
  ShadowZoneSystem.ResetZoneMenuCheckList()
  local logic_setzone_control = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_setzone_control)
  local defaultList = logic_setzone_control:GetShadow_default()
  for _, v in pairs(defaultList) do
    ShadowZoneSystem.zoneMenuAllReceiveList[v] = false
  end
  ShadowZoneSystem.bIsPingAllInZoneMenu = true
  local timer_ticker = require("common.time_ticker")
  if ShadowZoneSystem.stopRecheckAllTimer then
    timer_ticker.RemoveTimer(ShadowZoneSystem.stopRecheckAllTimer)
    ShadowZoneSystem.stopRecheckAllTimer = nil
  end
end
function ShadowZoneSystem.DelayedStopRecheckAllZone()
  print(bWriteLog and "[DeanJYT] ShadowZoneSystem.DelayedStopRecheckAllZone")
  if not ShadowZoneSystem.bIsPingAllInZoneMenu then
    print(bWriteLog and "[DeanJYT] ShadowZoneSystem.DelayedStopRecheckAllZone not rechecking, do not need to force stop")
    return
  end
  local timer_ticker = require("common.time_ticker")
  if ShadowZoneSystem.stopRecheckAllTimer then
    timer_ticker.RemoveTimer(ShadowZoneSystem.stopRecheckAllTimer)
    ShadowZoneSystem.stopRecheckAllTimer = nil
  end
  ShadowZoneSystem.stopRecheckAllTimer = timer_ticker.AddTimerOnce(2, function()
    if not ShadowZoneSystem.bIsPingAllInZoneMenu then
      print(bWriteLog and "[DeanJYT] ShadowZoneSystem.DelayedStopRecheckAllZone currently rechecking is done, not need to force stop")
      return
    end
    local logic_zone_delay = require("client.slua.logic.match.logic_zone_delay")
    logic_zone_delay.ReportAllZoneDetailedPingResult(true)
    ShadowZoneSystem.ResetZoneMenuCheckList()
    ShadowZoneSystem.stopRecheckAllTimer = nil
    print(bWriteLog and "[DeanJYT] ShadowZoneSystem.DelayedStopRecheckAllZone rechecking not done, force stop")
  end)
end
function ShadowZoneSystem.HandleAfterLoadingFinish()
  if GameStatus.GetGameStatus() == GameStatus.Lobby then
    local XMissionSystem = require("client.slua.logic.TxMission.logic_xmission_main")
    if XMissionSystem.IsInXMission() then
      return
    end
    ShadowZoneSystem.StartPingShadowServer()
  end
end
function ShadowZoneSystem.StartPingShadowServer()
  log(bWriteLog and "[DeanJYT] ShadowZoneSystem.StartPingShadowServer")
  if not ShadowZoneSystem.shadowPingsvrParam or not ShadowZoneSystem.shadowPingsvrList then
    return
  end
  if not ShadowZoneSystem.shadowPingsvrParam.switch then
    return
  end
  if ShadowZoneSystem.nPingAllCount < ShadowZoneSystem.shadowPingsvrParam.allsvr_max_count then
    ShadowZoneSystem.nPingTime = ShadowZoneSystem.shadowPingsvrParam.allsvr_tick_s
  end
  local time_ticker = require("common.time_ticker")
  if ShadowZoneSystem.pingTimer then
    time_ticker.RemoveTimer(ShadowZoneSystem.pingTimer)
  end
  ShadowZoneSystem.pingTimer = time_ticker.AddTimerLoop(C_PingCheckFrequency, function()
    if ShadowZoneSystem.bIsStartPing then
      ShadowZoneSystem.nPingTimeoutTime = ShadowZoneSystem.nPingTimeoutTime + C_PingCheckFrequency
      local minTickSecond = ShadowZoneSystem.bIsPingAll and ShadowZoneSystem.shadowPingsvrParam.allsvr_tick_s - 1 or ShadowZoneSystem.shadowPingsvrParam.onesvr_tick_s - 1
      if minTickSecond <= ShadowZoneSystem.nPingTimeoutTime then
        ShadowZoneSystem.nPingTimeoutTime = 0
        ShadowZoneSystem.CheckLastPingReceive()
      end
    end
    ShadowZoneSystem.nPingTime = ShadowZoneSystem.nPingTime + 1
    if ShadowZoneSystem.nPingAllCount < ShadowZoneSystem.shadowPingsvrParam.allsvr_max_count and ShadowZoneSystem.nPingTime >= ShadowZoneSystem.shadowPingsvrParam.allsvr_tick_s or ShadowZoneSystem.bIsPingAllInZoneMenu then
      ShadowZoneSystem.nPingTime = 0
      ShadowZoneSystem.PingAllShadowServer()
    end
    if ShadowZoneSystem.nPingTime >= ShadowZoneSystem.shadowPingsvrParam.onesvr_tick_s then
      ShadowZoneSystem.PingShadowServer()
    end
  end, TIMER_INFINITE, C_PingCheckFrequency)
end
function ShadowZoneSystem.StopPingShadowServer()
  log(bWriteLog and "ShadowZoneSystem.StopPingShadowServer")
  if ShadowZoneSystem.pingTimer then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(ShadowZoneSystem.pingTimer)
  end
  ShadowZoneSystem.pingTimer = nil
end
function ShadowZoneSystem.GetFilteredSvrList()
  local list = {}
  local table_util = require("common.table_util")
  for k, v in pairs(ShadowZoneSystem.shadowPingsvrList) do
    for kk, vv in pairs(v) do
      if table_util.IsInTable(list, vv) then
      else
        table.insert(list, vv)
      end
    end
  end
  return list
end
function ShadowZoneSystem.PingAllShadowServer()
  ShadowZoneSystem.ResetPartShadowServer()
  ShadowZoneSystem.bIsPingAll = true
  ShadowZoneSystem.nPingAllCount = ShadowZoneSystem.nPingAllCount + 1
  local port = ShadowZoneSystem.shadowPingsvrParam.svr_port
  local timeout_s = ShadowZoneSystem.shadowPingsvrParam.timeout_s
  local UDPPingCollector = slua_GameFrontendHUD.UDPPingCollector
  local filterList = ShadowZoneSystem.GetFilteredSvrList()
  for k, v in pairs(filterList) do
    local ip = string.format("%s:%d", v, port)
    UDPPingCollector:PingServer(ip, timeout_s, ShadowZoneSystem.shadowPingWatermarkMap[v] or 0)
    ShadowZoneSystem.nPingMaxNum = ShadowZoneSystem.nPingMaxNum + 1
  end
end
function ShadowZoneSystem.PingShadowServer(zoneID)
  ShadowZoneSystem.ResetPartShadowServer()
  ShadowZoneSystem.bIsPingAll = false
  local list = ShadowZoneSystem.shadowPingsvrList[zoneID or ZoneSystem.nChooseZoneID]
  if list then
    local port = ShadowZoneSystem.shadowPingsvrParam.svr_port
    local timeout_s = ShadowZoneSystem.shadowPingsvrParam.timeout_s
    local UDPPingCollector = slua_GameFrontendHUD.UDPPingCollector
    for k, v in pairs(list) do
      UDPPingCollector:PingServer(string.format("%s:%d", v, port), timeout_s, ShadowZoneSystem.shadowPingWatermarkMap[v] or 0)
      ShadowZoneSystem.nPingMaxNum = ShadowZoneSystem.nPingMaxNum + 1
    end
  end
end
function ShadowZoneSystem.PingShadowServerAtOnce(zoneID)
  if not ShadowZoneSystem.shadowPingsvrParam or not ShadowZoneSystem.shadowPingsvrList then
    return
  end
  if not ShadowZoneSystem.shadowPingsvrParam.switch then
    return
  end
  ShadowZoneSystem.PingShadowServer(zoneID)
end
function ShadowZoneSystem.RecordPingResultByType(svr, delay, type)
  if not ShadowZoneSystem.bShouldRecPingMethod then
    return
  end
  if type == 0 then
    if not ShadowZoneSystem.thread_epoll_module_params.thread_report_tlog then
      return
    end
  elseif type == 1 then
    if not ShadowZoneSystem.thread_epoll_module_params.epoll_report_tlog then
      return
    end
  else
    return
  end
  local svrKey
  for k, v in pairs(ShadowZoneSystem.shadowPingsvrList) do
    for kk, vv in pairs(v) do
      if svr == vv then
        svrKey = kk
        break
      end
    end
  end
  if not svrKey then
    log(bWriteLog and "[DeanJYT] ShadowZoneSystem.RecordPingResultByType svr cannot match to key, this should never happen")
    return
  end
  local records = ShadowZoneSystem.pingMethodRecord[type]
  if not records then
    records = {}
    ShadowZoneSystem.pingMethodRecord[type] = records
  end
  if not records[svrKey] then
    records[svrKey] = {}
  end
  records[svrKey][#records[svrKey] + 1] = delay
end
function ShadowZoneSystem.ProcessSinglePingMethodRecord(records, orderData)
  log_tree("[DeanJYT] ShadowZoneSystem.ProcessSinglePingMethodRecord records = ", records)
  if not records then
    return nil
  end
  local result = ""
  for svrKey, _ in pairs(orderData) do
    local data = records[svrKey] or {}
    result = result .. tostring(svrKey) .. ":"
    local totalCount = #data
    local failCount = 0
    local successCount = 0
    local sum = 0
    for i, vv in ipairs(data) do
      result = result .. tostring(vv)
      if i ~= totalCount then
        result = result .. ","
      else
        result = result .. "_"
      end
      if 0 < vv then
        successCount = successCount + 1
        sum = sum + vv
      else
        failCount = failCount + 1
      end
    end
    local average = 0
    if 0 < successCount then
      average = sum / successCount
    end
    result = result .. string.format("%.0f", average) .. "," .. tostring(totalCount) .. "," .. tostring(failCount) .. "," .. tostring(successCount) .. ";"
  end
  log(bWriteLog and "[DeanJYT] ShadowZoneSystem.ProcessSinglePingMethodRecord result = " .. result)
  return result
end
function ShadowZoneSystem.ProcessPingMethodResult()
  local result = {}
  local orderData = ShadowZoneSystem.pingMethodRecord[E_PingMethodType.thread] or ShadowZoneSystem.pingMethodRecord[E_PingMethodType.epoll]
  if not orderData then
    log(bWriteLog and "[DeanJYT] ShadowZoneSystem.ProcessPingMethodResult empty record, this should not happen")
    return result
  end
  for k, v in pairs(E_PingMethodType) do
    result[k] = ShadowZoneSystem.ProcessSinglePingMethodRecord(ShadowZoneSystem.pingMethodRecord[v], orderData)
  end
  if Client.IsDevelopment() then
    result.detail = ShadowZoneSystem.pingMethodRecord
  end
  return result
end
function ShadowZoneSystem.ProcessEpollPingStatInfo()
  local shadow_ping_stat = {}
  for svrKey, data in pairs(ShadowZoneSystem.pingMethodRecord[E_PingMethodType.epoll]) do
    local sum = 0
    local lossCount = 0
    local dnsErrCount = 0
    local successCount = 0
    for i, vv in ipairs(data) do
      if 0 < vv then
        successCount = successCount + 1
        sum = sum + vv
      elseif vv == -2 then
        dnsErrCount = dnsErrCount + 1
      else
        lossCount = lossCount + 1
      end
    end
    local mean = 0
    if 0 < successCount then
      mean = sum / successCount
    end
    local standardDeviation = 0
    for i, vv in ipairs(data) do
      if 0 < vv then
        standardDeviation = standardDeviation + (vv - mean) * (vv - mean)
      end
    end
    if 0 < successCount then
      standardDeviation = math.sqrt(sum / successCount)
    end
    shadow_ping_stat[svrKey] = {
      mean = math.ceil(mean),
      dns_err = dnsErrCount,
      sd = math.ceil(standardDeviation),
      seq = #data,
      loss = lossCount
    }
  end
  log_tree("ShadowZoneSystem.ProcessEpollPingStatInfo shadow_ping_stat = ", shadow_ping_stat)
  return slua.LuaArchiverEncode(LuaStateWrapper, shadow_ping_stat)
end
function ShadowZoneSystem.ReportPingMethodResult()
  log(bWriteLog and "[DeanJYT] ShadowZoneSystem.ReportPingMethodResult")
  local result = ShadowZoneSystem.ProcessPingMethodResult()
  if not result then
    log(bWriteLog and "[DeanJYT] ShadowZoneSystem.ReportPingMethodResult empty result, this should not happen")
    return
  end
  local MatchHandler = require("client.network.Protocol.MatchHandler")
  MatchHandler.send_report_epl_thd_ping_data(result)
  if ShadowZoneSystem.thread_epoll_module_params.epoll_report_tlog then
    local MatchHandler = require("client.network.Protocol.MatchHandler")
    MatchHandler.send_report_epoll_ping_info(ShadowZoneSystem.ProcessEpollPingStatInfo())
  end
end
function ShadowZoneSystem.OnReceiveServerPing(svr, Status, delay, type)
  type = type or 0
  log(bWriteLog and string.format("[DeanJYT] ShadowZoneSystem.OnReceiveServerPing svr = %s, nextState = %s, delay= %s, type = %s", svr, Status, delay, type))
  local result = 0
  if Status == EIcmpResponseStatus.Success then
    result = math.ceil(delay)
  elseif Status == EIcmpResponseStatus.Unresolvable then
    result = -2
  else
    result = -1
  end
  ShadowZoneSystem.RecordPingResultByType(svr, result, type)
  if not ShadowZoneSystem.bIsStartPing then
    return
  end
  ShadowZoneSystem.nReceivePingNum = ShadowZoneSystem.nReceivePingNum + 1
  if type ~= ShadowZoneSystem.thread_epoll_module_params.take_effect_module then
    return
  end
  local logic_zone_delay = require("client.slua.logic.match.logic_zone_delay")
  if ShadowZoneSystem.bIsPingAll or ShadowZoneSystem.bIsPingAllInZoneMenu then
    local list = ShadowZoneSystem.shadowPingsvrList
    for k, v in pairs(list) do
      for kk, vv in pairs(v) do
        if svr == vv then
          if not ShadowZoneSystem.receivePingList[kk] then
            ShadowZoneSystem.receivePingList[kk] = result
          end
          if k == ZoneSystem.nChooseZoneID then
            logic_zone_delay.KeepCurZonePing(k, kk, result)
          else
            logic_zone_delay.CalculateKeptShadowServerAverage(k, kk, result)
          end
          if result == -2 then
            ShadowZoneSystem.unresolvableRecord[kk] = svr
          end
          ShadowZoneSystem.CheckAllPingReceive()
          if ShadowZoneSystem.bIsPingAllInZoneMenu then
            if not ShadowZoneSystem.zoneMenuAllReceiveList[kk] then
              ShadowZoneSystem.zoneMenuAllReceiveList[kk] = result
            end
            ShadowZoneSystem.CheckAllPingReceivedForZoneMenu()
          end
        end
      end
    end
  else
    local list = ShadowZoneSystem.shadowPingsvrList[ZoneSystem.nChooseZoneID]
    if list then
      for k, v in pairs(list) do
        if svr == v then
          if not ShadowZoneSystem.receivePingList[k] then
            ShadowZoneSystem.receivePingList[k] = result
          end
          logic_zone_delay.KeepCurZonePing(ZoneSystem.nChooseZoneID, k, result)
          if result == -2 then
            ShadowZoneSystem.unresolvableRecord[k] = svr
          end
          ShadowZoneSystem.CheckAllPingReceive()
          return
        end
      end
    end
  end
end
function ShadowZoneSystem.CheckAllPingReceive()
  if ShadowZoneSystem.nReceivePingNum >= ShadowZoneSystem.nPingMaxNum and ShadowZoneSystem.receivePingList and next(ShadowZoneSystem.receivePingList) then
    ShadowZoneSystem.SendPingReport()
    ShadowZoneSystem.ResetPartShadowServer()
    ShadowZoneSystem.bIsStartPing = false
    if ShadowZoneSystem.bShouldRecPingMethod and not ShadowZoneSystem.bIsPingAll then
      ShadowZoneSystem.pingMethodRecordCount = ShadowZoneSystem.pingMethodRecordCount + 1
      log(bWriteLog and "[DeanJYT] ShadowZoneSystem.CheckAllPingReceive self.pingMethodRecordCount = " .. tostring(ShadowZoneSystem.pingMethodRecordCount))
      if ShadowZoneSystem.pingMethodRecordCount > C_PingRecordReportCount then
        ShadowZoneSystem.bShouldRecPingMethod = false
        ShadowZoneSystem.ReportPingMethodResult()
      end
    end
  end
end
function ShadowZoneSystem.CheckAllPingReceivedForZoneMenu()
  log(bWriteLog and "[DeanJYT] ShadowZoneSystem.CheckAllPingReceivedForZoneMenu")
  for k, v in pairs(ShadowZoneSystem.zoneMenuAllReceiveList) do
    if not v then
      return
    end
  end
  log(bWriteLog and "[DeanJYT] ShadowZoneSystem.CheckAllPingReceivedForZoneMenu all received, should report")
  local logic_zone_delay = require("client.slua.logic.match.logic_zone_delay")
  logic_zone_delay.ReportAllZoneDetailedPingResult(true)
  ShadowZoneSystem.ResetZoneMenuCheckList()
end
function ShadowZoneSystem.CheckLastPingReceive()
  log(bWriteLog and "[edward][logic_match] ShadowZoneSystem.CheckLastPingReceive")
  if ShadowZoneSystem.receivePingList and next(ShadowZoneSystem.receivePingList) then
    if ShadowZoneSystem.bIsPingAll then
      local list = ShadowZoneSystem.shadowPingsvrList
      for k, v in pairs(list) do
        for kk, vv in pairs(v) do
          if not ShadowZoneSystem.receivePingList[kk] then
            ShadowZoneSystem.receivePingList[kk] = -1
          end
        end
      end
    else
      local list = ShadowZoneSystem.shadowPingsvrList[ZoneSystem.nChooseZoneID]
      for k, v in pairs(list) do
        if not ShadowZoneSystem.receivePingList[k] then
          ShadowZoneSystem.receivePingList[k] = -1
        end
      end
    end
    ShadowZoneSystem.SendPingReport()
  end
  ShadowZoneSystem.ResetPartShadowServer()
  ShadowZoneSystem.bIsStartPing = false
end
function ShadowZoneSystem.SendPingReport()
  local logic_zone_delay = require("client.slua.logic.match.logic_zone_delay")
  local MatchHandler = require("client.network.Protocol.MatchHandler")
  MatchHandler.send_report_test_battle_ping(ShadowZoneSystem.receivePingList, logic_zone_delay.GetAllZoneDelay(), ShadowZoneSystem.unresolvableRecord)
  ShadowZoneSystem.unresolvableRecord = {}
end
function ShadowZoneSystem.CheckLastPingReceiveAtOnce()
  if not ShadowZoneSystem.shadowPingsvrParam or not ShadowZoneSystem.shadowPingsvrList then
    return
  end
  if not ShadowZoneSystem.shadowPingsvrParam.switch then
    return
  end
  if not ShadowZoneSystem.receivePingList then
    return
  end
  ShadowZoneSystem.CheckLastPingReceive()
end
return ShadowZoneSystem