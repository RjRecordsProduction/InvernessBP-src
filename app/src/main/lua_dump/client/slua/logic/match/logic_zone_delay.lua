local logic_zone_delay = {
  delayAdjustParams = {
    paramA = 90,
    paramK0 = 100,
    paramK = 0.3,
    RegionPingParamVersion = 0,
    RegionPingParam1 = 0,
    RegionPingParam2 = 0,
    RegionPingParam3 = 0,
    switch = false
  },
  keptAllShadowPingList = {},
  shadowRegionKey = "",
  bUseNewZoneMenuStyle = false
}
local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
local ShadowZoneSystem = require("client.slua.logic.teamup.logic_shadow_zone")
local E_QueryPingStrategy = {
  Default = 1,
  MinPing = 2,
  MinShadowPing = 3,
  Specified = 4
}
local C_PingExceptionFormatStr = "desired:%i,but:%i"
local C_MinimumRangeDiff = 5
function logic_zone_delay.InitPingAdjustParam(paramA, paramK0, paramK, switch, range_info)
  logic_zone_delay.delayAdjustParams.  logic_zone_delay.delayAdjustParams.  logic_zone_delay.delayAdjustParams.  logic_zone_delay.delayAdjustParams.  if type(range_info) == "table" then
    log_tree("[DeanJYT] logic_zone_delay.InitPingAdjustParam range_info = ", range_info)
    logic_zone_delay.bUseNewZoneMenuStyle = true
    logic_zone_delay.delayRangeConfig = range_info.ping_reduce_tbl
    logic_zone_delay.showRangeConfig = range_info.ping_define_tbl
  else
    log(bWriteLog and "[DeanJYT] logic_zone_delay.InitPingAdjustParam range_info is nil, use old style")
    logic_zone_delay.bUseNewZoneMenuStyle = false
  end
end
function logic_zone_delay.InitRegionPingParam(paramStr)
  if type(paramStr) ~= "string" or #paramStr < 1 then
    log(bWriteLog and "logic_zone_delay.InitRegionPingParam paramStr is null or empty ")
    return
  end
  log(bWriteLog and "logic_zone_delay.InitRegionPingParam paramStr = " .. paramStr)
  local StringUtil = require("common.string_util")
  local params = StringUtil.Split(paramStr, ",")
  local paramlength = #params
  if paramlength < 1 then
    log(bWriteLog and "logic_zone_delay.InitRegionPingParam paramlength<1")
    return
  end
  if params[1] == "1" and paramlength == 4 then
    local TmpRegionPingParam1 = tonumber(params[2])
    local TmpRegionPingParam2 = tonumber(params[3])
    local TmpRegionPingParam3 = tonumber(params[4])
    if 0 < TmpRegionPingParam1 then
      logic_zone_delay.delayAdjustParams.RegionPingParamVersion = 1
      logic_zone_delay.delayAdjustParams.RegionPingParam1 = TmpRegionPingParam1
      logic_zone_delay.delayAdjustParams.RegionPingParam2 = TmpRegionPingParam2
      logic_zone_delay.delayAdjustParams.RegionPingParam3 = TmpRegionPingParam3
      log(bWriteLog and "logic_zone_delay.InitRegionPingParam RegionPingParamVersion " .. tostring(logic_zone_delay.delayAdjustParams.RegionPingParamVersion))
      log(bWriteLog and "logic_zone_delay.InitRegionPingParam RegionPingParam1 " .. tostring(logic_zone_delay.delayAdjustParams.RegionPingParam1))
      log(bWriteLog and "logic_zone_delay.InitRegionPingParam RegionPingParam2 " .. tostring(logic_zone_delay.delayAdjustParams.RegionPingParam2))
      log(bWriteLog and "logic_zone_delay.InitRegionPingParam RegionPingParam3 " .. tostring(logic_zone_delay.delayAdjustParams.RegionPingParam3))
    end
  end
end
function logic_zone_delay.CalculateKeptShadowServerAverage(zoneID, svrID, ping)
  if ping < 0 then
    return
  end
  if not logic_zone_delay.keptAllShadowPingList[tostring(zoneID)] then
    logic_zone_delay.keptAllShadowPingList[tostring(zoneID)] = {}
  end
  local curSvrPingInfo = logic_zone_delay.keptAllShadowPingList[tostring(zoneID)][svrID]
  if not curSvrPingInfo or 0 >= curSvrPingInfo.pingNum then
    logic_zone_delay.keptAllShadowPingList[tostring(zoneID)][svrID] = {savedPing = ping, pingNum = 1}
    return
  end
  local curAverage = curSvrPingInfo.savedPing
  curSvrPingInfo.savedPing = (curAverage * curSvrPingInfo.pingNum + ping) / (curSvrPingInfo.pingNum + 1)
  curSvrPingInfo.pingNum = curSvrPingInfo.pingNum + 1
end
function logic_zone_delay.KeepCurZonePing(zoneID, svrID, ping)
  if not logic_zone_delay.keptAllShadowPingList[tostring(zoneID)] then
    logic_zone_delay.keptAllShadowPingList[tostring(zoneID)] = {}
  end
  local curSvrPingInfo = logic_zone_delay.keptAllShadowPingList[tostring(zoneID)][svrID]
  if not curSvrPingInfo or curSvrPingInfo.pingNum <= 0 then
    logic_zone_delay.keptAllShadowPingList[tostring(zoneID)][svrID] = {savedPing = ping, pingNum = 1}
    return
  end
  curSvrPingInfo.savedPing = ping
  curSvrPingInfo.pingNum = curSvrPingInfo.pingNum + 1
end
function logic_zone_delay.ResetData()
  logic_zone_delay.keptAllShadowPingList = {}
end
function logic_zone_delay.ReportAllZoneDetailedPingResult(bIsRecheckAll)
  log(bWriteLog and "[DeanJYT] logic_zone_delay.ReportAllZoneDetailedPingResult bIsRecheckAll = " .. tostring(bIsRecheckAll))
  local zoneList = ZoneSystem.chooseZoneList
  local allResults = {}
  local UPLOAD_MAX_PING = 10000
  for _, v in pairs(zoneList) do
    allResults[v.zone_id] = logic_zone_delay.GetDetailedZoneDelay(v.zone_id)
  end
  local TeamupHandler = require("client.network.Protocol.TeamupHandler")
  local GetZoneDelay = function(zoneID)
    local ms = logic_zone_delay.GetZoneDelay(zoneID, 360, UPLOAD_MAX_PING, true)
    return ms
  end
  local curZoneID = ZoneSystem.nChooseZoneID
  local cur_zone_real_ping = math.ceil(curZoneID and allResults[curZoneID] and allResults[curZoneID].source_ping or 0)
  local cur_zone_display_ping = math.ceil(GetZoneDelay(curZoneID))
  local extraInfo = {
    gray_status = 0,
    cur_zone_id = curZoneID,
    best_zone_id = curZoneID,
    cur_zone_real_ping = cur_zone_real_ping,
    cur_zone_display_ping = cur_zone_display_ping,
    best_zone_real_ping = 0,
    best_zone_display_ping = 0
  }
  if type(ZoneSystem.extraPingInfo) == "table" and ZoneSystem.extraPingInfo.BestShadowZoneId then
    local bestZoneID = ZoneSystem.extraPingInfo.BestShadowZoneId
    local best_zone_real_ping = math.ceil(bestZoneID and allResults[bestZoneID] and allResults[bestZoneID].source_ping or 0)
    local best_zone_display_ping = 0
    if UPLOAD_MAX_PING < best_zone_real_ping then
      best_zone_real_ping = UPLOAD_MAX_PING
      best_zone_display_ping = UPLOAD_MAX_PING
    else
      best_zone_display_ping = math.ceil(GetZoneDelay(bestZoneID))
    end
    extraInfo.gray_status = 1
    extraInfo.best_zone_id = bestZoneID
    extraInfo.    extraInfo.  end
  if bIsRecheckAll then
    extraInfo.is_recheck_all = true
  end
  log_tree("[DeanJYT] logic_zone_delay.ReportAllZoneDetailedPingResult allResults = ", allResults)
  log_tree("[DeanJYT] logic_zone_delay.ReportAllZoneDetailedPingResult extraInfo = ", extraInfo)
  TeamupHandler.send_zone_select_ping_display_details_req(allResults, extraInfo)
end
function logic_zone_delay.GetAllZoneDelay(handleExtraDelay)
  local zoneList = ZoneSystem.chooseZoneList
  local delayList = {}
  for _, v in pairs(zoneList) do
    if v.zone_id then
      delayList[v.zone_id] = logic_zone_delay.GetZoneDelay(v.zone_id, 360, 10000, handleExtraDelay)
    end
  end
  return delayList
end
function logic_zone_delay.GetZoneMinPing(zoneID)
  local list = logic_zone_delay.keptAllShadowPingList[tostring(zoneID)]
  if not list then
    return -1
  end
  local minPing
  local svrKey = ""
  for k, v in pairs(list) do
    if not minPing and v.savedPing > 0 then
      minPing = v.savedPing
      svrKey = k
    elseif v.savedPing and v.savedPing > 0 and minPing and minPing > v.savedPing then
      minPing = v.savedPing
      svrKey = k
    end
  end
  return minPing or -1, svrKey
end
function logic_zone_delay.GetZonePingByShadowSvrKey(zoneID, shadowSvrKey)
  local list = logic_zone_delay.keptAllShadowPingList[tostring(zoneID)]
  local AppointZonePing = logic_zone_delay.GetZoneMinPing(zoneID)
  if list and list[shadowSvrKey] then
    AppointZonePing = tonumber(list[shadowSvrKey].savedPing)
  end
  return AppointZonePing or -1
end
function logic_zone_delay.SetShadowRegion(shadowRegion)
  log(bWriteLog and "[DeanJYT] logic_zone_delay.SetShadowRegion shadowRegion = " .. tostring(shadowRegion))
  logic_zone_delay.shadowRegionKey = shadowRegion or ""
end
function logic_zone_delay.GetShadowRegionKey()
  return logic_zone_delay.shadowRegionKey
end
function logic_zone_delay.GetCurRoomMinPing()
  local list = logic_zone_delay.keptAllShadowPingList[tostring(RoomSystem.CurrentRoomInfo.zone_id)]
  if not list then
    return -1
  end
  local idc_flag = RoomSystem.idc_flag
  if not list[idc_flag] then
    return -1
  end
  local minPing = list[idc_flag].savedPing or -1
  return minPing
end
function logic_zone_delay.GetChoosenZoneDelay(fakeShowDelay, maxDelay, handleExtraDelay)
  local zoneID = ZoneSystem.nChooseZoneID
  return logic_zone_delay.GetZoneDelay(zoneID, fakeShowDelay, maxDelay, handleExtraDelay)
end
function logic_zone_delay.GetZoneDelay(zoneID, fakeShowDelay, maxDelay, handleExtraDelay)
  local pingResult = logic_zone_delay.GetZoneDelayBeforeAdjust(zoneID)
  local ping = pingResult.source_ping
  local isLocalServer = zoneID == ZoneSystem.nChooseZoneID
  if isLocalServer and handleExtraDelay then
    ping = ZoneSystem.GetZoneDelay(zoneID, ping)
  end
  local adjustedPing = logic_zone_delay.AdjustPingRange(ping, isLocalServer)
  if logic_zone_delay.bUseNewZoneMenuStyle then
    local range = logic_zone_delay.GetComputedLatencyRange(adjustedPing)
    return range.max
  end
  return adjustedPing
end
function logic_zone_delay.GetZoneDelayRange(zoneID, handleExtraDelay)
  local pingResult = logic_zone_delay.GetZoneDelayBeforeAdjust(zoneID)
  local ping = pingResult.source_ping
  local isLocalServer = zoneID == ZoneSystem.nChooseZoneID
  if isLocalServer and handleExtraDelay then
    ping = ZoneSystem.GetZoneDelay(zoneID, ping)
  end
  local adjustedPing = logic_zone_delay.AdjustPingRange(ping, isLocalServer)
  return logic_zone_delay.GetComputedLatencyRange(adjustedPing)
end
function logic_zone_delay.GetChoosenZoneDelayRange(fakeShowDelay, maxDelay, handleExtraDelay)
  local zoneID = ZoneSystem.nChooseZoneID
  return logic_zone_delay.GetZoneDelayRange(zoneID, fakeShowDelay, maxDelay, handleExtraDelay)
end
function logic_zone_delay.GetDetailedZoneDelay(zoneID)
  local pingResult = logic_zone_delay.GetZoneDelayBeforeAdjust(zoneID)
  pingResult.display_ping = logic_zone_delay.AdjustPingRange(pingResult.source_ping, zoneID == ZoneSystem.nChooseZoneID)
  pingResult.source_ping = math.ceil(pingResult.source_ping)
  return pingResult
end
local PingCompare = function(a, b)
  if a < 0 then
    return false
  end
  if b < 0 then
    return true
  end
  return a < b
end
function logic_zone_delay.GetZoneDelayBeforeAdjust(zoneID)
  local logic_setzone_control = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_setzone_control)
  local bOnlyUseShadowSvr = logic_setzone_control:CheckIsOnlyUseShadowSvr()
  local specifiedPing, specifiedSvrKey = logic_zone_delay.GetSpecifiedShadowSvrPing(zoneID)
  local defaultPing, defaultSvrKey = logic_zone_delay.GetDefaultPing(zoneID)
  local minPing, minPingSvrKey = logic_zone_delay.GetZoneMinPing(zoneID)
  local TableUtil = require("common.table_util")
  local specifiedSvr = TableUtil.GetTableValue(ShadowZoneSystem.shadowPingsvrList, zoneID, specifiedSvrKey) or ""
  local result = {
    source_ping = -1,
    display_ping = -1,
    strategy = 1,
    if_has_except = 0,
    except_reason = "",
    shadowid = "",
    specified_ping = specifiedPing,
    min_shadow_ping = minPing,
    default_ping = defaultPing,
    default_svr = defaultSvrKey,
    specified_svr = specifiedSvr
  }
  if bOnlyUseShadowSvr then
    if 0 < specifiedPing then
      result.source_ping = specifiedPing
      result.strategy = E_QueryPingStrategy.Specified
      result.shadowid = specifiedSvrKey
    else
      result.source_ping = minPing
      result.strategy = E_QueryPingStrategy.MinPing
      result.shadowid = minPingSvrKey
      result.if_has_except = 1
      result.except_reason = string.format(C_PingExceptionFormatStr, E_QueryPingStrategy.Specified, E_QueryPingStrategy.MinPing)
    end
  elseif not logic_zone_delay.delayAdjustParams.switch and logic_zone_delay.shadowRegionKey == "" then
    if PingCompare(defaultPing, specifiedPing) then
      result.source_ping = defaultPing
      result.strategy = E_QueryPingStrategy.Default
      result.shadowid = defaultSvrKey
    else
      result.source_ping = specifiedPing
      result.strategy = E_QueryPingStrategy.Specified
      result.shadowid = specifiedSvrKey
    end
  end
  if result.source_ping < 0 then
    local bestPing = minPing
    result.shadowid = minPingSvrKey
    if PingCompare(defaultPing, minPing) then
      bestPing = defaultPing
    end
    result.source_ping = bestPing
    if logic_zone_delay.delayAdjustParams.switch then
      result.strategy = E_QueryPingStrategy.MinPing
    else
      result.strategy = E_QueryPingStrategy.MinShadowPing
    end
  end
  return result
end
function logic_zone_delay.GetSpecifiedShadowSvrPing(zoneID)
  local logic_setzone_control = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_setzone_control)
  local ping = -1
  local shadowDefault = logic_setzone_control:GetShadow_default()
  if not shadowDefault then
    return -1, ""
  end
  local svrKey = shadowDefault[zoneID]
  if ZoneSystem.nChooseZoneID == zoneID then
    local mostUsedKey = logic_setzone_control:GetMostUsedShadow()
    if mostUsedKey and mostUsedKey ~= "" then
      svrKey = mostUsedKey
    end
  end
  ping = logic_zone_delay.GetZonePingByShadowSvrKey(zoneID, svrKey)
  return ping, svrKey
end
function logic_zone_delay.GetDefaultPing(zoneID)
  local ip = ""
  local zoneList = ZoneSystem.chooseZoneList
  for _, v in pairs(zoneList) do
    if zoneID == v.zone_id then
      ip = v.tpingsvr_ip
      break
    end
  end
  local UDPPingCollector = slua_GameFrontendHUD.UDPPingCollector
  local defaultPing = UDPPingCollector:GetZoneServerDelay(tostring(ip))
  return defaultPing, ip
end
function logic_zone_delay.GetCurRoomDelay(fakeShowDelay)
  local zoneID = tonumber(RoomSystem.CurrentRoomInfo.zone_id or 0)
  local ip = ""
  local zoneList = ZoneSystem.chooseZoneList
  for _, v in ipairs(zoneList) do
    if zoneID == v.zone_id then
      ip = v.tpingsvr_ip
      break
    end
  end
  if ip == "" then
    return fakeShowDelay
  end
  local UDPPingCollector = slua_GameFrontendHUD.UDPPingCollector
  local defaultPing = UDPPingCollector:GetZoneServerDelay(tostring(ip))
  if not RoomSystem.IsNeedPingShadow() then
    return logic_zone_delay.AdjustPingRange(defaultPing)
  end
  local bestPing = defaultPing
  local shadowBestPing = logic_zone_delay.GetCurRoomMinPing()
  if 0 < shadowBestPing and bestPing > shadowBestPing then
    bestPing = shadowBestPing
  end
  return logic_zone_delay.AdjustPingRange(bestPing)
end
function logic_zone_delay.GetIPDelay(ip, fakeShowDelay, maxDelay)
  local UDPPingCollector = slua_GameFrontendHUD.UDPPingCollector
  local defaultPing = UDPPingCollector:GetZoneServerDelay(tostring(ip))
  return logic_zone_delay.AdjustPing(defaultPing, fakeShowDelay, maxDelay)
end
function logic_zone_delay.IsChoosingZoneAccess()
  local zoneID = ZoneSystem.nChooseZoneID
  local netDelay = logic_zone_delay.GetZoneDelayBeforeAdjust(zoneID)
  if netDelay and netDelay.source_ping > 1000 then
    return false
  end
  return true
end
function logic_zone_delay.AdjustPing(ping, fakeShowDelay, maxDelay)
  fakeShowDelay = fakeShowDelay or 360
  maxDelay = maxDelay or 1000
  if ping <= 0 or ping > maxDelay then
    return fakeShowDelay
  end
  local a = logic_zone_delay.delayAdjustParams.paramA
  local k0 = logic_zone_delay.delayAdjustParams.paramK0
  local k = logic_zone_delay.delayAdjustParams.paramK
  local decreaseRatio = math.max(0, k * (1 - (0.036 * a / 100 + 0.96) ^ (ping - k0)))
  if logic_zone_delay.delayAdjustParams.RegionPingParamVersion == 1 and 20 < ping and ping < logic_zone_delay.delayAdjustParams.RegionPingParam1 then
    decreaseRatio = (logic_zone_delay.delayAdjustParams.RegionPingParam2 * ping - logic_zone_delay.delayAdjustParams.RegionPingParam3 * ping * ping) / 100
    decreaseRatio = FuncUtil.Clamp(decreaseRatio, 0, 0.9)
  end
  return math.floor(ping * (1 - decreaseRatio))
end
local ConstPingRange = {
  localMinPing = 120,
  otherMinPing = 150,
  maxPing = 360
}
function logic_zone_delay.AdjustPingRange(ping, isLocalServer)
  local minPing = ConstPingRange.localMinPing
  if isLocalServer == false then
    minPing = ConstPingRange.otherMinPing
  end
  if ping <= 0 then
    return minPing
  end
  if not logic_zone_delay.bUseNewZoneMenuStyle and ping > ConstPingRange.maxPing then
    return ConstPingRange.maxPing
  end
  local a = logic_zone_delay.delayAdjustParams.paramA
  local k0 = logic_zone_delay.delayAdjustParams.paramK0
  local k = logic_zone_delay.delayAdjustParams.paramK
  local decreaseRatio = math.max(0, k * (1 - (0.036 * a / 100 + 0.96) ^ (ping - k0)))
  return math.floor(ping * (1 - decreaseRatio))
end
function logic_zone_delay.IsCanShowDelayTips()
  local time = 0
  local lastShowTime
  if LobbySystem.roleData.net_anomaly_popup_info then
    time = LobbySystem.roleData.net_anomaly_popup_info.cnt
    lastShowTime = LobbySystem.roleData.net_anomaly_popup_info.ts
  end
  if time == 0 then
    return true
  end
  local CD = logic_zone_delay.GetCurShowDelayTipsCD(time)
  local TimeUtil = require("client.common.time_util")
  local isCanShow = not TimeUtil.WithinInNDay(lastShowTime, CD)
  return isCanShow
end
function logic_zone_delay.GetCurShowDelayTipsCD(time)
  local CDsCfg = CDataTable.GetTableData("SystemConfig", "MatchStartDelayTipsCD")
  local CDs = {
    1,
    3,
    5
  }
  if CDsCfg then
    CDs = CDsCfg.ConfigValue
  end
  local StringUtil = require("common.string_util")
  CDs = StringUtil.Split(CDs, ";")
  local CD = CDs[FuncUtil.Clamp(time, 1, #CDs)]
  return tonumber(CD)
end
function logic_zone_delay.ShowDelayTips(okCallback)
  if not logic_zone_delay.IsCanShowDelayTips() then
    okCallback()
    return
  end
  local time = 0
  local lastShowTime
  if LobbySystem.roleData.net_anomaly_popup_info then
    time = LobbySystem.roleData.net_anomaly_popup_info.cnt
    lastShowTime = LobbySystem.roleData.net_anomaly_popup_info.ts
  end
  local title = LocUtil.GetLocalizeResStr(101001)
  local msg = LocUtil.GetLocalizeResStr(1011)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, title, msg, okCallback)
  time = time + 1
  local TimeUtil = require("client.common.time_util")
  lastShowTime = TimeUtil.GetServerTimeInSec()
  if not LobbySystem.roleData.net_anomaly_popup_info then
    LobbySystem.roleData.net_anomaly_popup_info = {}
  end
  LobbySystem.roleData.net_anomaly_popup_info.cnt = time
  LobbySystem.roleData.net_anomaly_popup_info.ts = lastShowTime
  local TeamupHandler = require("client.network.Protocol.TeamupHandler")
  TeamupHandler.send_record_net_anomaly_date_req({cnt = time, ts = lastShowTime})
end
function logic_zone_delay.GetPingLevel(ms)
  local level = 1
  for i, v in pairs(logic_zone_delay.showRangeConfig) do
    if ms > v.min_show_val and ms <= v.max_show_val then
      level = i
      break
    end
  end
  return level
end
function logic_zone_delay.GetPingColor(ms)
  if logic_zone_delay.bUseNewZoneMenuStyle then
    local level = 1
    for i, v in pairs(logic_zone_delay.showRangeConfig) do
      if ms > v.min_show_val and ms <= v.max_show_val then
        level = i
        break
      end
    end
    return logic_zone_delay.GetPingColorByLatencyLevel(level)
  end
  if 0 <= ms and ms < 200 then
    return FLinearColor(0.030713, 0.423268, 0.201556, 1)
  elseif 200 <= ms and ms < 500 then
    return FLinearColor(1, 0.603828, 0, 1)
  end
  return FLinearColor(1, 0.012983, 0, 1)
end
function logic_zone_delay.GetPingColorByLatencyLevel(level)
  if level == 1 then
    return FLinearColor(0.030713, 0.423268, 0.201556, 1)
  elseif level == 2 then
    return FLinearColor(0.693872, 0.14996, 0, 1)
  end
  return FLinearColor(1, 0.012983, 0, 1)
end
function logic_zone_delay.GetComputedLatencyRange(ms)
  local rangeConfig = logic_zone_delay.delayRangeConfig
  ms = math.floor(ms)
  local range
  for k, v in pairs(rangeConfig) do
    if ms > v.min_ping and ms <= v.max_ping then
      local max = ms - v.up_random_val
      local min = max - v.low_random_val
      if max - min < C_MinimumRangeDiff then
        min = max - C_MinimumRangeDiff
      end
      if min < 1 then
        min = 1
      end
      if max < C_MinimumRangeDiff then
        max = C_MinimumRangeDiff
      end
      range = {min = min, max = max}
    end
  end
  local maxLevel = #logic_zone_delay.showRangeConfig
  if not range then
    log(bWriteLog and "[DeanJYT] logic_zone_delay.GetComputedLatencyRange range is nil, should not happen")
    local max = logic_zone_delay.showRangeConfig[maxLevel].max_show_val
    range = {
      min = max - C_MinimumRangeDiff,
          }
    return range
  end
  if range.max > logic_zone_delay.showRangeConfig[maxLevel].max_show_val then
    log(bWriteLog and "[DeanJYT] logic_zone_delay.GetComputedLatencyRange exceed max range, adjust to max")
    local rangeDiff = range.max - range.min
    range.max = logic_zone_delay.showRangeConfig[maxLevel].max_show_val
    range.min = range.max - rangeDiff
  end
  return range
end
function logic_zone_delay.GetShowLatencyRange(level)
  if not logic_zone_delay.showRangeConfig then
    return nil
  end
  return logic_zone_delay.showRangeConfig[level]
end
function logic_zone_delay.GetPingBySvrId(shadow_id)
  log(bWriteLog and "logic_zone_delay.GetPingBySvrId shadow_id = " .. tostring(shadow_id))
  if not shadow_id then
    return nil
  end
  local ping
  for _, svr_ping_table in pairs(logic_zone_delay.keptAllShadowPingList or {}) do
    for svr_id, svr_ping_info in pairs(svr_ping_table) do
      if shadow_id == svr_id then
        ping = svr_ping_info.savedPing
        break
      end
    end
    if ping then
      break
    end
  end
  log(bWriteLog and "logic_zone_delay.GetPingBySvrId ping = " .. tostring(ping))
  return ping
end
return logic_zone_delay