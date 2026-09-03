local M = {
  grome_sdk_time_out = 6,
  game_grome_map = {},
  is_grome_enable = nil,
  is_grome_fec_enable = nil,
  svr_notify_close = false,
  current_grome_link_url = "",
  grome_svr_index = 0,
  grome_timeout_timer = nil,
  current_gameid = 0,
  is_re_enter = false,
  current_svr_key = "ori",
  enter_battle_start_time = 0,
  first_time_enter_battle = true,
  loop_counter = 0,
  open_notify_gromelink_open_stat = false,
  last_ping_test_time = 0,
  svr_grome_info = {
    use_cloud_control = false,
    is_in_white_list = false,
    experiment_group = false,
    ping_duallink = ""
  },
  enter_battle_extra_info = {},
  ENUM_NOT_SUPPORT_REASON = {
    OK = "check_ok",
    NO_SIM_CARD = "no_sim",
    NO_WIFI = "no_wifi",
    SVR_NOTIFY_CLOSE = "check_no_support",
    USING_VPN = "is_vpn",
    USING_GAME_MASTER = "is_xunyou",
    NO_GROME_INFO = "no_grome_info",
    CLIENT_DISABLE = "client_disable"
  },
  ENUM_TLOG_REASON = {
    GROME_FAILED = -1,
    GROME_SUCCESS = 0,
    PING_CHECKED = 1
  },
  ENUM_ENTER_GAME_RET = {SUCC = "ok", TIMEOUT = "timeout"},
  ENUM_ENTER_GAME_REASON = {
    NOT_SUPPORT = "not_support_grome",
    CONNECT_TIMEOUT = "connect_time_out"
  },
  ENUM_ENTER_PING_TEST_SCENS = {LOGIN = 1, START_MATCH = 2}
}
function M:OnSyncBaseInfoWithGRomeControl(grome_info)
  if grome_info then
    log_tree("logic_grome_link:OnSyncBaseInfoWithGRomeControl", grome_info)
    self.svr_grome_info.use_cloud_control = grome_info.use_cloud_control or false
    self.svr_grome_info.is_in_white_list = grome_info.is_in_white_list or false
    self.svr_grome_info.experiment_group = grome_info.experiment_group or false
    self.svr_grome_info.ping_duallink = grome_info.PingDuallink_param or ""
    self.open_notify_gromelink_open_stat = grome_info.open_notify_gromelink_open_stat or false
  end
  EventSystem:registEvent(EVENTTYPE_MATCH, EVENTID_MATCH_UPDATE_STATUS_MATCHING_OR_NOT, function(eventType, eventID, state)
    if state == ENUM_MatchStatus.Matching then
      log(bWriteLog and string.format("logic_grome_link:OnSyncBaseInfoWithGRomeControl matching"))
      self:ExecuteGRomePingTest(M.ENUM_ENTER_PING_TEST_SCENS.START_MATCH)
    end
  end)
  self:ExecuteGRomePingTest(M.ENUM_ENTER_PING_TEST_SCENS.LOGIN)
end
function M:HasPingDuallink()
  return self.svr_grome_info.ping_duallink and #self.svr_grome_info.ping_duallink > 0
end
function M:ExecuteGRomePingTest(src)
  if not self:HasPingDuallink() then
    log(bWriteLog and string.format("logic_grome_link:ExecuteGRomePingTest no ping_duallink"))
    return
  end
  local EnableMatchPing = HDmpveRemote.HDmpveRemoteConfigGetBool("EnableMatchPing", true)
  if EnableMatchPing == false and src == M.ENUM_ENTER_PING_TEST_SCENS.START_MATCH then
    log(bWriteLog and string.format("logic_grome_link:ExecuteGRomePingTest match ping disabled by cloud config"))
    return
  end
  local current_time = os.time()
  if self.last_ping_test_time > 0 and current_time - self.last_ping_test_time < 30 then
    log(bWriteLog and string.format("logic_grome_link:ExecuteGRomePingTest ping test cooldown, remaining: %d seconds", 30 - (current_time - self.last_ping_test_time)))
    return
  end
  self.last_ping_test_time = current_time
  local HDmpveSDKObj = ShareMgr.GetHDmpveSDKObj()
  HDmpveSDKObj:GRomePingDuallink(self.svr_grome_info.ping_duallink)
  local async = require("client.common.async")
  async.Run(function(co)
    async.AwaitEvent(co, 5, EVENTTYPE_GAMELET, EVENTID_GAMELET_DELAY_OPEN)
    local HDmpveSDKObjA = ShareMgr.GetHDmpveSDKObj()
    if HDmpveSDKObjA ~= nil then
      local GRomelinkPingStatus = HDmpveSDKObjA:GRomeGetDuallinkStatus()
      log(bWriteLog and string.format("logic_grome_link:ExecuteGRomePingTest GRomelinkPingStatus: %d", GRomelinkPingStatus))
      local tlog_info = {
        result = self.ENUM_TLOG_REASON.PING_CHECKED,
        ping_ret_support_grome = GRomelinkPingStatus
      }
      self:ReportGRomeTlog(tlog_info)
    end
  end)
end
function M:EnterBattle(game_id, grome_info, extra_info)
  self.current_gameid = game_id
  self.grome_svr_index = 0
  self:SetGRomeInfo(game_id, grome_info)
  local TimeUtil = require("client.common.time_util")
  self.enter_battle_start_time = TimeUtil.GetMiliseconds()
  self.enter_battle_extra_info = extra_info or {}
  local ClientNotSupportReason, lwipurl = self:GetEnterGameGRomeUrl(game_id, self.grome_svr_index)
  self:ReportClientCheckResult(ClientNotSupportReason)
  if lwipurl ~= nil and 1 < #lwipurl then
    Client.GameRegisterGRomeLink()
    self:UpdateCurrentSvrKey(lwipurl)
    self:SetNetDriverGRomeLink(lwipurl)
    self.loop_counter = 6
    local TimeTicker = require("common.time_ticker")
    self.grome_timeout_timer = TimeTicker.AddTimerLoop(self.grome_sdk_time_out, function()
      log(bWriteLog and "logic_grome_link:EnterBattle grome_timeout_timer " .. tostring(self.loop_counter))
      if self.loop_counter <= 0 then
        TimeTicker.RemoveTimer(self.grome_timeout_timer)
      else
        self.loop_counter = self.loop_counter - 1
      end
      local tlog_info = {
        result = self.ENUM_TLOG_REASON.GROME_SUCCESS,
        network = Client.GetNetWorkType(),
        reason = "ok",
        url = self.current_grome_link_url or "",
        dev_info = Client.GetDevicePlatformName()
      }
      local UKismetSystemLibrary = import("KismetSystemLibrary")
      local GRomelinkReceivePacketNum = UKismetSystemLibrary.GetConsoleVariableIntValue("n.GRomelinkReceivePacketNum")
      log(bWriteLog and string.format("logic_grome_link:EnterBattle GRomelinkReceivePacketNum: %d", GRomelinkReceivePacketNum))
      if GRomelinkReceivePacketNum < 3 then
        tlog_info.result = self.ENUM_TLOG_REASON.GROME_FAILED
        local EnableRetry = HDmpveRemote.HDmpveRemoteConfigGetBool("GRomeEnableRetry", true)
        if EnableRetry then
          tlog_info.reason = "timeout_with_retry"
          self.grome_svr_index = self.grome_svr_index + 1
          local ClientNotSupportReason, lwipurl = self:GetEnterGameGRomeUrl(game_id, self.grome_svr_index)
          if lwipurl ~= nil and 1 < #lwipurl then
            self:UpdateCurrentSvrKey(lwipurl)
            self:SetNetDriverGRomeLink(lwipurl)
          else
            log(bWriteLog and "logic_grome_link:EnterBattle remove grome_timeout_timer")
            TimeTicker.RemoveTimer(self.grome_timeout_timer)
            self:UpdateCurrentSvrKey()
            self:SetNetDriverGRomeLink()
          end
          Client.GRromelinkRecreateGameSocket()
        else
          tlog_info.reason = "timeout_without_retry"
          log(bWriteLog and "logic_grome_link:EnterBattle remove grome_timeout_timer")
          TimeTicker.RemoveTimer(self.grome_timeout_timer)
        end
      else
        log(bWriteLog and "logic_grome_link:EnterBattle remove grome_timeout_timer")
        TimeTicker.RemoveTimer(self.grome_timeout_timer)
      end
      self:ReportGRomeTlog(tlog_info)
    end, 0, self.grome_sdk_time_out)
  else
    self:UpdateCurrentSvrKey()
    self:SetNetDriverGRomeLink()
  end
end
function M:SetIsReEnter(is_re_enter)
  self.  log(bWriteLog and string.format("logic_grome_link:SetIsReEnter is_re_enter: %s", tostring(is_re_enter)))
end
function M:OnEnterBattleResult(ret)
  local have_grome_info = 0
  if self.game_grome_map ~= nil and self.game_grome_map[self.current_gameid] ~= nil then
    have_grome_info = 1
  end
  local TimeUtil = require("client.common.time_util")
  local enter_battle_time_span = TimeUtil.GetMiliseconds() - self.enter_battle_start_time
  local extra_info = {
    reason = "",
    re_try_times = self.grome_svr_index,
    game_id = self.current_gameid,
    enter_battle_node_used = self.current_svr_key,
    enter_battle_time_span = enter_battle_time_span,
    have_grome_info = have_grome_info,
    is_re_enter = self.is_re_enter or false,
    version = Client.GetApplicationVersion(),
    res_version = Client.GetAppVersion(),
    ip = self.enter_battle_extra_info.ip or "",
    port = self.enter_battle_extra_info.port or 0,
    sub_mode = self.enter_battle_extra_info.sub_mode or 0,
    mode = self.enter_battle_extra_info.mode or 0,
    grome_info = have_grome_info == 1 and self.game_grome_map[self.current_gameid] or nil
  }
  if ret == self.ENUM_ENTER_GAME_RET.SUCC then
    M:SetSvrNotifyCloseFlag(self.current_svr_key)
  end
  if ret == self.ENUM_ENTER_GAME_RET.TIMEOUT then
    extra_info.reason = self.ENUM_ENTER_GAME_REASON.CONNECT_TIMEOUT
  end
  log_tree("logic_grome_link:OnEnterBattleResult", extra_info)
  if self.enter_battle_start_time == nil or self.enter_battle_start_time == 0 then
    return
  end
  if enter_battle_time_span < 2000 then
    return
  end
  self.enter_battle_start_time = 0
  local MatchHandler = require("client.network.Protocol.MatchHandler")
  MatchHandler.send_grome_enter_battle_result(ret, extra_info)
end
function M:SetNetDriverGRomeLink(URL)
  URL = URL or "nil"
  log(bWriteLog and string.format("logic_grome_link:SetNetDriverGRomeLink URL: %s", URL))
  URL = string.format("=%s", URL)
  local gameInstance = slua.getGameInstance()
  gameInstance:ExecuteCMD("s.EnterGameGRomelinkURL", URL)
  if string.find(self.current_grome_link_url, URL) == nil then
    self.current_grome_link_url = URL
  end
end
function M:UpdateCurrentSvrKey(URL)
  URL = URL or "nil"
  if 5 <= #URL and self.grome_svr_index == 0 then
    self.current_svr_key = "svr"
  elseif 5 <= #URL and self.grome_svr_index > 0 then
    self.current_svr_key = "svr" .. tonumber(self.grome_svr_index)
  else
    self.current_svr_key = "ori"
  end
end
function M:IsEnterBattleUsingGRomeLink()
  if self.current_svr_key ~= "ori" then
    return true
  end
  return false
end
function M:SetSvrNotifyCloseFlag(current_svr_key)
  if string.find(current_svr_key, "svr") ~= nil and self.first_time_enter_battle == true then
    self.first_time_enter_battle = false
    self.svr_notify_close = true
  end
  log(bWriteLog and string.format("logic_grome_link:SetSvrNotifyCloseFlag current_svr_key, svr_nofity_close %s, %s", current_svr_key, tostring(self.svr_notify_close)))
end
function M:SetGRomeInfo(game_id, grome_info)
  if not self:GRomeLinkEnable() then
    log(bWriteLog and "logic_grome_link:SetGRomeInfo return by GRome disable")
    return
  end
  if grome_info == nil then
    log(bWriteLog and "logic_grome_link:SetGRomeInfo return by empty grome_info")
    return
  end
  if grome_info.svr == nil or #grome_info.svr <= 0 then
    log(bWriteLog and "logic_grome_link:SetGRomeInfo return by empty svr")
    return
  end
  self.grome_sdk_time_out = grome_info.grome_sdk_time_out_s or 6
  local local_grome_info = self.game_grome_map[game_id]
  if local_grome_info == nil then
    local_grome_info = {call_count = 0}
  end
  for k, v in pairs(grome_info) do
    local_grome_info[k] = v
  end
  self.game_grome_map[game_id] = local_grome_info
  log_tree(string.format("logic_grome_link:SetGRomeInfo game_id: %s", game_id), self.game_grome_map[game_id])
end
function M:GetEnterGameGRomeUrl(game_id, svr_idx)
  local ClientNotSupportReason = M.ENUM_NOT_SUPPORT_REASON.OK
  local game_url = self:GetGRomeUrl(game_id, svr_idx, false)
  if game_url == "" then
    if not self:GRomeLinkEnable() then
      ClientNotSupportReason = M.ENUM_NOT_SUPPORT_REASON.CLIENT_DISABLE
    else
      ClientNotSupportReason = M.ENUM_NOT_SUPPORT_REASON.NO_GROME_INFO
    end
  else
    ClientNotSupportReason = self:CheckClientRuntimeAvailability()
    if ClientNotSupportReason ~= M.ENUM_NOT_SUPPORT_REASON.OK then
      game_url = ""
    end
  end
  local lwipurl = ""
  if game_url ~= nil and 1 < #game_url then
    local base_url, params = self:ParseURLParams(game_url)
    lwipurl = params.lwipurl
  end
  return ClientNotSupportReason, lwipurl
end
function M:GetGRomeUrl(game_id, svr_idx, skip_counter)
  log(bWriteLog and string.format("logic_grome_link:GetGRomeUrl svr_idx: %d", svr_idx))
  local game_url = ""
  if not self:GRomeLinkEnable() then
    log(bWriteLog and "logic_grome_link:GetGRomeUrl return nil by GRome disable")
    return game_url
  end
  local local_grome_info = self.game_grome_map[game_id]
  if local_grome_info == nil then
    return game_url
  end
  local svr = ""
  local svr_key = "svr"
  if svr_idx ~= nil and 0 < svr_idx then
    svr_key = "svr" .. tostring(svr_idx)
  end
  for k, v in pairs(local_grome_info) do
    if k == svr_key then
      svr = v
      break
    end
  end
  if svr == nil or svr == "" then
    log(bWriteLog and "logic_grome_link:GetGRomeUrl return nil by empty svr")
    return game_url
  end
  local base_url, params = self:ParseURLParams(svr)
  local lwipurl_hex = params.lwipurl
  local lwipurl_real_value = self:HexToStr(lwipurl_hex)
  local lwipurl_base_url, lwipurl_params = self:ParseURLParams(lwipurl_real_value)
  local lwipurl_id_real_value = lwipurl_params.id
  if not skip_counter then
    local_grome_info.call_count = local_grome_info.call_count + 1
  end
  local StringUtil = require("common.string_util")
  local lwipurl_id_arr = StringUtil.Split(lwipurl_id_real_value, "_")
  lwipurl_id_arr[4] = tostring(local_grome_info.call_count)
  local lwipurl_id_after_modify = table.concat(lwipurl_id_arr, "_")
  lwipurl_params.id = lwipurl_id_after_modify
  local lwipurl_after_modify = self:RebuildURL(lwipurl_base_url, lwipurl_params)
  log(bWriteLog and string.format("logic_grome_link:GetGRomeUrl lwipurl_after_modify: %s", lwipurl_after_modify))
  params.lwipurl = self:StrToHex(lwipurl_after_modify)
  game_url = self:RebuildURL(base_url, params)
  log_tree("logic_grome_link:GetGRomeUrl lwipurl_params", params)
  self.current_grome_link_url = game_url
  return game_url
end
function M:ReportGRomeTlog(tlog_info)
  log_tree("logic_grome_link:ReportGRomeTlog: ", tlog_info)
  local MatchHandler = require("client.network.Protocol.MatchHandler")
  MatchHandler.send_report_grome_link_err(tlog_info)
end
function M:ValidateGRomelinkActivation()
  local is_valid = false
  if self.svr_grome_info.is_in_white_list then
    is_valid = true
  elseif self.svr_grome_info.experiment_group == true and self.svr_grome_info.use_cloud_control == false then
    is_valid = true
  elseif self.svr_grome_info.experiment_group == true and self.svr_grome_info.use_cloud_control == true then
    local EnableGRomelinkCountry = HDmpveRemote.HDmpveRemoteConfigGetBool("EnableGRomelinkCountry", false)
    if EnableGRomelinkCountry then
      is_valid = true
    end
  end
  log(bWriteLog and string.format("logic_grome_link:ValidateGRomelinkActivation is_valid: %s", is_valid))
  return is_valid
end
function M:OnNotifyGRomelinkOpenStat(stat, game_id)
  self.svr_notify_close = false
  log(bWriteLog and string.format("logic_grome_link:OnNotifyGRomelinkOpenStat stat, svr_nofity_close: %s, %s", tostring(stat), tostring(self.svr_notify_close)))
end
function M:ReportClientCheckResult(reason, extra_info)
  log(bWriteLog and string.format("logic_grome_link:ReportCheckResult: %s", reason))
  if extra_info == nil then
    extra_info = {}
  end
  local bClientDisable = false
  if reason == M.ENUM_NOT_SUPPORT_REASON.CLIENT_DISABLE then
    bClientDisable = true
  end
  local bNoGromeInfo = false
  if reason == M.ENUM_NOT_SUPPORT_REASON.NO_GROME_INFO then
    bNoGromeInfo = true
  elseif self.game_grome_map == nil or self.game_grome_map[self.current_gameid] == nil then
    bNoGromeInfo = true
  end
  local bCheckNoSupport = false
  if reason == M.ENUM_NOT_SUPPORT_REASON.CHECK_NO_SUPPORT then
    bCheckNoSupport = true
  elseif self.open_notify_gromelink_open_stat == true and self.svr_notify_close then
    bCheckNoSupport = true
  end
  local bNoSim = false
  if reason == M.ENUM_NOT_SUPPORT_REASON.NO_SIM then
    bNoSim = true
  elseif not self:HasSimCard() then
    bNoSim = true
  end
  local bNoWifi = false
  if reason == M.ENUM_NOT_SUPPORT_REASON.NO_WIFI then
    bNoWifi = true
  elseif not self:HasWifi() then
    bNoWifi = true
  end
  local bIsVPN = false
  if reason == M.ENUM_NOT_SUPPORT_REASON.USING_VPN then
    bIsVPN = true
  else
    local DeviceOSInfo = require("client.logic.data.data_device_os")
    if DeviceOSInfo.GetIsPlayerUsingVPN() then
      bIsVPN = true
    end
  end
  local bIsXunyou = false
  if reason == M.ENUM_NOT_SUPPORT_REASON.USING_GAME_MASTER then
    bIsXunyou = true
  else
    local AccelSystem = require("client.slua.logic.gamemaster.logic_accel")
    if AccelSystem.IsEnableAccel() then
      bIsXunyou = true
    end
  end
  extra_info.client_disable = bClientDisable
  extra_info.no_grome_info = bNoGromeInfo
  extra_info.check_no_support = bCheckNoSupport
  extra_info.no_sim = bNoSim
  extra_info.no_wifi = bNoWifi
  extra_info.is_vpn = bIsVPN
  extra_info.is_xunyou = bIsXunyou
  log_tree("logic_grome_link:ReportClientCheckResult extra_info: ", extra_info)
  local MatchHandler = require("client.network.Protocol.MatchHandler")
  MatchHandler.send_device_not_support_grome_link(reason, extra_info)
end
function M:GRomeLinkEnable()
  if self.is_grome_enable == nil then
    self.is_grome_enable = HDmpveRemote.HDmpveRemoteConfigGetBool("GRomeLinkEnable", true)
  end
  return self.is_grome_enable
end
function M:GRomeLinkFECSwitcherEnable()
  if self.is_grome_fec_enable == nil then
    self.is_grome_fec_enable = HDmpveRemote.HDmpveRemoteConfigGetBool("GRomeLinkFECEnable", false)
  end
  log(bWriteLog and string.format("logic_grome_link:GRomeLinkFECEnable is_grome_fec_enable: %s", tostring(self.is_grome_fec_enable)))
  return self.is_grome_fec_enable
end
function M:ParseURLParams(url)
  local base_url, query_string = url:match("^([^?]*)%?(.*)$")
  if not base_url then
    base_    query_string = ""
  end
  local StringUtil = require("common.string_util")
  local params = StringUtil.ParseURLParams(query_string)
  return base_url, params
end
function M:RebuildURL(base_url, params)
  local new_params = {}
  for k, v in pairs(params) do
    table.insert(new_params, k .. "=" .. v)
  end
  if 0 < #new_params then
    return base_url .. "?" .. table.concat(new_params, "&")
  else
    return base_url
  end
end
function M:HexToStr(hex)
  if not hex then
    return ""
  end
  hex = hex:gsub("%s+", "")
  local str = hex:gsub("%x%x", function(byte)
    return string.char(tonumber(byte, 16))
  end)
  return str
end
function M:StrToHex(str, options)
  local opt = {
    uppercase = true,
    separator = "",
    prefix = ""
  }
  if options then
    for k, v in pairs(options) do
      opt[k] = v
    end
  end
  local format_str = opt.uppercase and "%02X" or "%02x"
  local buffer = {}
  local len = #str
  local sep_len = #opt.separator
  buffer.len = len * (2 + sep_len) + #opt.prefix
  if buffer.len > 0 then
    buffer[1] = opt.prefix
  end
  for i = 1, len do
    local b = string.byte(str, i)
    buffer[#buffer + 1] = string.format(format_str, b)
    if i < len and 0 < sep_len then
      buffer[#buffer + 1] = opt.separator
    end
  end
  return table.concat(buffer)
end
function M:CheckClientRuntimeAvailability()
  if self.open_notify_gromelink_open_stat == true and self.svr_notify_close then
    return M.ENUM_NOT_SUPPORT_REASON.SVR_NOTIFY_CLOSE
  end
  if not self:HasSimCard() then
    return M.ENUM_NOT_SUPPORT_REASON.NO_SIM_CARD
  end
  if not self:HasWifi() then
    return M.ENUM_NOT_SUPPORT_REASON.NO_WIFI
  end
  local DeviceOSInfo = require("client.logic.data.data_device_os")
  if DeviceOSInfo.GetIsPlayerUsingVPN() then
    return M.ENUM_NOT_SUPPORT_REASON.USING_VPN
  end
  local AccelSystem = require("client.slua.logic.gamemaster.logic_accel")
  if AccelSystem.IsEnableAccel() then
    return M.ENUM_NOT_SUPPORT_REASON.USING_GAME_MASTER
  end
  return M.ENUM_NOT_SUPPORT_REASON.OK
end
function M:HasSimCard()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if Client.GetDevicePlatformName() == DevicePlatformNameMacros.Android then
    local logic_cloud_game = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cloud_game)
    local carrierInfoStrs = logic_cloud_game:GetCarrierInfo()
    if carrierInfoStrs == "" then
      carrierInfoStrs = Client.GetCarrierInfo()
    end
    local carrierInfos = json.decode(carrierInfoStrs)
    log_tree("logic_grome_link:HasSimCard carrierInfos", carrierInfos)
    for i, s in ipairs(carrierInfos) do
      if s.mcc ~= "" then
        return true
      end
    end
  elseif Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS then
    return true
  end
  return false
end
function M:HasWifi()
  if Client.GetNetWorkType() == "Wifi" then
    return true
  end
  return false
end
return M