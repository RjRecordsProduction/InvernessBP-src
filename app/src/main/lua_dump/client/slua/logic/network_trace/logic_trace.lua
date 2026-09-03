local TraceSystem = {
  LOCAL_DATA_FILE = "ChannelChecker",
  MAX_TRACE_SHADOW_SVR_COUNT = 4,
  DEFAULT_MAX_TTL = 15,
  Switcher = -1,
  NetworkBrokenTracingDests = {},
  NetworkBrokenTraceResult = {},
  ShadowTraceSvrCfg = {},
  TraceGameId = 0
}
function TraceSystem.StartTraceTriggerByNetworkBroken()
  log(bWriteLog and "[WSL]TraceSystem.StartTraceTriggerByNetworkBroken")
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  local ShadowZoneSystem = require("client.slua.logic.teamup.logic_shadow_zone")
  local SDKMacros = require("client.slua.config.ClientMacros.SDKMacros")
  local ServerSwitcer = TraceSystem.ShadowTraceSvrCfg.is_open or false
  local MaxTTL = TraceSystem.ShadowTraceSvrCfg.default_ttl or TraceSystem.DEFAULT_MAX_TTL
  MaxTTL = MaxTTL > TraceSystem.DEFAULT_MAX_TTL and TraceSystem.DEFAULT_MAX_TTL or MaxTTL
  local MaxPingShadowSvrNum = TraceSystem.GetMaxPingShadowSvrNum()
  log(bWriteLog and string.format("[WSL]TraceSystem.StartTraceTriggerByNetworkBroken ServerSwitcer,MaxTTL,MaxPingShadowSvrNum: %s, %d, %d", tostring(ServerSwitcer), MaxTTL, MaxPingShadowSvrNum))
  if ServerSwitcer == false then
    log(bWriteLog and "[WSL]TraceSystem.StartTraceTriggerByNetworkBroken return by server switcher close")
    return
  end
  if #TraceSystem.NetworkBrokenTracingDests > 0 then
    log(bWriteLog and "[WSL]TraceSystem.StartTraceTriggerByNetworkBroken return by runing network broken trace")
    return
  end
  if TraceSystem.TraceGameId == g_game_id then
    log(bWriteLog and "[WSL]TraceSystem.StartTraceTriggerByNetworkBroken return by gameid have traced")
    return
  end
  TraceSystem.TraceGameId = g_game_id
  TraceSystem.NetworkBrokenTraceResult = {}
  TraceSystem.NetworkBrokenTracingDests = {}
  local extra = {
    battle_id = g_game_id,
    shadow_svr_id = 0
  }
  local DSIP = Client.GetDSConnectionIP()
  table.insert(TraceSystem.NetworkBrokenTracingDests, DSIP)
  TraceSystem.StartTrace(SDKMacros.TraceTrigger.NetworkBroken, DSIP, MaxTTL, extra)
  local list = ShadowZoneSystem.shadowPingsvrList[ZoneSystem.nChooseZoneID]
  if list then
    local temp_shadow_svr_list = {}
    local temp_shadow_svr_id_list = {}
    for k, v in pairs(list) do
      if TraceSystem.isAllDigitsString(tostring(k)) then
        table.insert(temp_shadow_svr_id_list, k)
        table.insert(temp_shadow_svr_list, v)
      end
    end
    if MaxPingShadowSvrNum < #temp_shadow_svr_list then
      temp_shadow_svr_list = TraceSystem.GetRandomShadowSvr(temp_shadow_svr_list, MaxPingShadowSvrNum)
    end
    for i = 1, #temp_shadow_svr_list do
      extra.shadow_svr_id = temp_shadow_svr_id_list[i]
      table.insert(TraceSystem.NetworkBrokenTracingDests, temp_shadow_svr_list[i])
      TraceSystem.StartTrace(SDKMacros.TraceTrigger.NetworkBroken, temp_shadow_svr_list[i], MaxTTL, extra)
    end
  end
end
function TraceSystem.StartTrace(trigger, destination, ttl, extra)
  log(bWriteLog and string.format("[WSL]TraceSystem.StartTrace trigger, dest: %s %s", tostring(trigger), destination))
  if TraceSystem.Switcher == -1 then
    TraceSystem.Switcher = HDmpveRemote.HDmpveRemoteConfigGetInt("TraceSwitcherState", 1)
  end
  if TraceSystem.Switcher & trigger <= 0 then
    log(bWriteLog and string.format("[WSL]TraceSystem.StartTrace return by switcher %d", TraceSystem.Switcher))
    return
  end
  local runType = TraceSystem.ShadowTraceSvrCfg.run_type or 2
  local start_jump_ttl = TraceSystem.ShadowTraceSvrCfg.start_jump_ttl or 3
  local offset = TraceSystem.ShadowTraceSvrCfg.offset or 3
  local extraDataObj = extra or {}
  extraDataObj.  extraDataObj.dest = destination
  extraDataObj.ping_ttl_node = true
  extraDataObj.ping_timeout = 2
  extraDataObj.ping_  extraDataObj.ping_  extraDataObj.ping_customer_judgment_local_ip = true
  ttl = ttl or TraceSystem.DEFAULT_MAX_TTL
  log_tree("[WSL] TraceSystem.StartTrace: ", extraDataObj)
  Client.StartTrace(destination, runType, ttl, 1, json.encode(extraDataObj))
end
function TraceSystem.OnLogin()
  TraceSystem.CheckTraceInfoToReport()
end
function TraceSystem.UpdateTraceSvrCfg(ServerCfg)
  log_tree(bWriteLog and "[WSL]TraceSystem.UpdateTraceSvrCfg:", ServerCfg)
  TraceSystem.ShadowTraceSvrCfg = ServerCfg
end
function TraceSystem.OnTraceCallback(retCode, extraJson)
  log(bWriteLog and "[WSL]TraceSystem.OnTraceCallback parameter: " .. tostring(retCode) .. " json: " .. extraJson)
  local SDKMacros = require("client.slua.config.ClientMacros.SDKMacros")
  if tostring(retCode) ~= "1" then
    log(bWriteLog and "[WSL]TraceSystem.OnTraceCallback return")
    return
  end
  local extraObj = json.decode(extraJson or "{}")
  local pingInfos = json.decode(extraObj.pingInfos or "{}")
  local extraDataObj = json.decode(extraObj.extraData or "{}")
  if extraDataObj.trigger == SDKMacros.TraceTrigger.Server then
    TraceSystem.OnServerTrggerTraceCallback(retCode, pingInfos, extraDataObj)
  elseif extraDataObj.trigger == SDKMacros.TraceTrigger.NetworkBroken then
    TraceSystem.OnNetBrokenTraceCallback(retCode, pingInfos, extraDataObj)
  else
    log(bWriteLog and "[WSL]TraceSystem.OnTraceCallback nothing todo")
  end
end
function TraceSystem.OnServerTrggerTraceCallback(retCode, pingInfos, extraData)
  log(bWriteLog and "[WSL]TraceSystem.OnServerTrggerTraceCallback")
  local data = TraceSystem.Convert2TraceData(pingInfos, extraData)
  local LobbyHandler = require("client.network.Protocol.LobbyHandler")
  LobbyHandler.send_mtr_report(retCode, data)
end
function TraceSystem.OnNetBrokenTraceCallback(retCode, pingInfos, extraData)
  log(bWriteLog and "[WSL]TraceSystem.OnNetBrokenTraceCallback code:" .. tostring(retCode))
  local data = TraceSystem.Convert2TraceData(pingInfos, extraData)
  local dsConnectionState = Client.GetDSConnectionState()
  data.ds_conn_state = dsConnectionState
  local IsLobbyConnected = Client.IsConnected(NetInterface)
  data.lobby_conn_state = IsLobbyConnected
  table.insert(TraceSystem.NetworkBrokenTraceResult, data)
  if #TraceSystem.NetworkBrokenTraceResult < #TraceSystem.NetworkBrokenTracingDests then
    log(bWriteLog and "[WSL]TraceSystem.OnNetBrokenTraceCallback return by not finish")
    return
  end
  local data_to_report = {
    battle_id = extraData.battle_id or 0,
    trace_data = TraceSystem.NetworkBrokenTraceResult
  }
  if IsLobbyConnected then
    local LobbyHandler = require("client.network.Protocol.LobbyHandler")
    LobbyHandler.send_report_net_trace_infos(data_to_report)
  else
    local base64 = require("client.slua.logic.lobby_watermark.base64")
    local dataJson = base64.enc(json.encode(data_to_report))
    Client.SaveStringToFile(dataJson, TraceSystem.LOCAL_DATA_FILE)
  end
  TraceSystem.NetworkBrokenTraceResult = {}
  TraceSystem.NetworkBrokenTracingDests = {}
end
function TraceSystem.CheckTraceInfoToReport()
  log(bWriteLog and "[WSL]TraceSystem.CheckTraceInfoToReport")
  local LocalDataStr = Client.LoadFileToString(TraceSystem.LOCAL_DATA_FILE)
  if LocalDataStr == nil or LocalDataStr == "" then
    return
  end
  local base64 = require("client.slua.logic.lobby_watermark.base64")
  local LocalDataJson = base64.dec(LocalDataStr)
  log(bWriteLog and "[WSL]TraceSystem.CheckTraceInfoToReport: " .. LocalDataJson)
  local LocalData = json.decode(LocalDataJson)
  if LocalData then
    local LobbyHandler = require("client.network.Protocol.LobbyHandler")
    LobbyHandler.send_report_net_trace_infos(LocalData)
  end
  Client.SaveStringToFile("", TraceSystem.LOCAL_DATA_FILE)
end
function TraceSystem.Convert2TraceData(pingInfos, extraData)
  local TimeUtil = require("client.common.time_util")
  local reportData = {}
  local reportSourceData = pingInfos
  local index = 1
  table.sort(reportSourceData, function(a, b)
    return a.ExeSeq < b.ExeSeq
  end)
  for _, v in pairs(reportSourceData) do
    local pingInfo = {
      ip = v.IP,
      avg = v.Time,
      loss = 1,
      ttl = v.ExeSeq
    }
    if v.TTL == 0 then
      pingInfo.loss = 1
    else
      pingInfo.loss = 0
    end
    reportData[index] = pingInfo
    index = index + 1
  end
  local data = {
    dest = extraData.dest or "",
    begin_ts = TimeUtil.GetServerTimeInSec(),
    report = reportData,
    shadow_svr_id = extraData.shadow_svr_id or 0
  }
  return data
end
function TraceSystem.GetRandomShadowSvr(array, count)
  local result = {}
  local arrayCopy = {}
  math.randomseed(os.time())
  for i, v in ipairs(array) do
    arrayCopy[i] = v
  end
  for i = 1, count do
    local index = math.random(1, #arrayCopy)
    table.insert(result, arrayCopy[index])
    table.remove(arrayCopy, index)
  end
  return result
end
function TraceSystem.isAllDigitsString(str)
  return string.match(str, "^%d+$") ~= nil
end
function TraceSystem.GetMaxPingShadowSvrNum()
  local MaxTraceCount = TraceSystem.ShadowTraceSvrCfg.trace_limit_cnt or TraceSystem.MAX_TRACE_SHADOW_SVR_COUNT
  MaxTraceCount = MaxTraceCount > TraceSystem.MAX_TRACE_SHADOW_SVR_COUNT and TraceSystem.MAX_TRACE_SHADOW_SVR_COUNT or MaxTraceCount
  local UIUtil = require("client.common.ui_util")
  local GameInst = UIUtil.GetGameInstance()
  if slua.isValid(GameInst) and TraceSystem.ShadowTraceSvrCfg.diff_gear_limit then
    if GameInst:GetExactDeviceLevel() <= -1 then
      MaxTraceCount = TraceSystem.ShadowTraceSvrCfg.diff_gear_limit[4] or 1
    elseif GameInst:GetExactDeviceLevel() == 0 then
      MaxTraceCount = TraceSystem.ShadowTraceSvrCfg.diff_gear_limit[3] or 2
    elseif GameInst:GetExactDeviceLevel() == 1 then
      MaxTraceCount = TraceSystem.ShadowTraceSvrCfg.diff_gear_limit[2] or 4
    elseif GameInst:GetExactDeviceLevel() == 2 then
      MaxTraceCount = TraceSystem.ShadowTraceSvrCfg.diff_gear_limit[1] or 4
    end
  end
  log(bWriteLog and string.format("[WSL]TraceSystem.GetMaxPingShadowSvrNum return %d", MaxTraceCount))
  return MaxTraceCount
end
return TraceSystem