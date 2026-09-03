local GameMaster = require("client.slua.logic.gamemaster.logic_gamemaster")
AccelSystem = AccelSystem or {
  enableAccelServerSwitch = false,
  accelSDKReady = false,
  enableAccelLocalSwitch = true,
  onlyWifiAccelLocalSwitch = false,
  echoServerPort = 8030,
  resolveIPTimer = nil,
  enableLobbyProxyServerSwitch = false,
  lobbyProxyBackupServer = "",
  lobbyProxyBackupPort = "",
  lobbyEchoBackupPort = "",
  MAX_TRY_RESOLVE_IP = 6,
  gameMasterUserId = "",
  latestDSIP = nil,
  latestDSPort = nil,
  latestDSProtocol = nil
}
local E_AccelerationUserStatus = {
  Not = 0,
  New = 1,
  Trial = 2,
  TrialExpired = 3,
  Vip = 4,
  VipExpired = 5,
  Debuging = 6,
  Free = 99
}
AccelSystem.local E_ResovleIPEventType = {
  NothingToDo = 0,
  Succ = 1,
  Failed = 2
}
AccelSystem.
function AccelSystem.Init()
  if AccelSystem.accelSDKReady == true then
    log(bWriteLog and "AccelSystem.Init return by already!")
    return
  end
  GameMaster.Init()
  if GameMaster.IsEnvVailable() == false then
    AccelSystem.enableAccelServerSwitch = false
    AccelSystem.enableAccelLocalSwitch = false
    AccelSystem.enableLobbyProxyServerSwitch = false
    log(bWriteLog and "AccelSystem.Init return by env unvailable")
    return
  end
  AccelSystem.LoadConfig()
  AccelSystem.LoadRemoteConfig()
  local accelMode = -1
  local accelLibs = ""
  local encrypt_util = require("client.common.encrypt_util")
  if AccelSystem.enableAccelServerSwitch and AccelSystem.enableLobbyProxyServerSwitch then
    accelMode = 3
    accelLibs = encrypt_util:CommonXORDecryption("3aba7bd0c606d96607917300c4fcb3e797885c650084")
  elseif AccelSystem.enableAccelServerSwitch then
    accelMode = 1
    accelLibs = "libUE4.so"
  elseif AccelSystem.enableLobbyProxyServerSwitch then
    accelMode = 0
    accelLibs = encrypt_util:CommonXORDecryption("3aba7be2e05e98600c936c06")
  else
    log(bWriteLog and "AccelSystem.Init return by server config not setup")
    return
  end
  if accelMode ~= -1 and 0 < #accelLibs then
    Client.GameMasterSetUsableRegion("sg")
    local initSDKRet = Client.GameMasterInit(accelMode, GameMaster.GetGUID(), accelLibs, AccelSystem.echoServerPort)
    if initSDKRet == 0 then
      AccelSystem.accelSDKReady = true
      Client.LobbySetUserRegion(GameMaster.GetPlayerCountryNo())
      log(bWriteLog and "AccelSystem.Init LobbySetUserRegion:" .. tostring(GameMaster.GetPlayerCountryNo()))
      if AccelSystem.IsEnableLobbyAccel() then
        if AccelSystem.lobbyProxyBackupServer ~= nil and AccelSystem.lobbyProxyBackupServer ~= "" then
          Client.LobbySetProxyNodelist(AccelSystem.lobbyProxyBackupServer)
        end
        if AccelSystem.lobbyProxyBackupPort ~= nil and AccelSystem.lobbyProxyBackupPort ~= "" then
          Client.LobbySetProxyPortlist(AccelSystem.lobbyProxyBackupPort)
        end
        if AccelSystem.lobbyEchoBackupPort ~= nil and AccelSystem.lobbyEchoBackupPort ~= "" then
          Client.LobbySetEchoPortlist(AccelSystem.lobbyEchoBackupPort)
        end
      end
    else
      log(bWriteLog and "AccelSystem.Init init SDK failed")
      AccelSystem.accelSDKReady = false
    end
  else
    log(bWriteLog and "AccelSystem.Init do nothing by mode or libs is zero")
  end
end
function AccelSystem.OnLogin()
  log(bWriteLog and "AccelSystem.OnLogin")
  if GameMaster.IsEnvVailable() == false then
    log(bWriteLog and "AccelSystem.OnLogin return by env unvailable")
    return
  end
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  if login_module.ClientBasicCfg == nil then
    local time_ticker = require("common.time_ticker")
    time_ticker.AddTimerOnce(1, function()
      AccelSystem.LoadServerConfig()
    end)
  else
    AccelSystem.LoadServerConfig()
  end
  AccelSystem.ReportAccelSwitcherStatus()
end
function AccelSystem.InitAccelSDK()
  log(bWriteLog and "AccelSystem.InitAccelSDK")
  if AccelSystem.IsServerEnableAccel() == true then
    Client.GameMasterSetUdpEchoPort(AccelSystem.echoServerPort)
    if AccelSystem.accelSDKReady then
      Client.GameMasterSetUserInfo(AccelSystem.gameMasterUserId, "", "PUBGM")
      Client.GameMasterSetOnlyWifiAccel(AccelSystem.onlyWifiAccelLocalSwitch)
    end
  else
    log(bWriteLog and "AccelSystem.InitAccelSDK do nothing by disable accl")
  end
end
function AccelSystem.BeginRound(roundId)
  log(bWriteLog and "AccelSystem.BeginRound")
  if AccelSystem.IsEnableAccel() == true then
    Client.GameMasterBeginRound(DataMgr.roleData.openID, roundId)
  else
    log(bWriteLog and "AccelSystem.BeginRound do nothing by disable accl")
  end
end
function AccelSystem.AddAccelLobbyAddress(connectUrl, on_add_addr_finish)
  log(bWriteLog and "AccelSystem.AddAccelLobbyAddress() " .. connectUrl)
  if AccelSystem.IsEnableLobbyAccel() then
    local ip = ""
    local port = 0
    local lobbyProtocol = "TCP"
    if string.find(connectUrl, "udp") ~= nil then
      lobbyProtocol = "UDP"
    end
    local StringUtil = require("common.string_util")
    local rt = StringUtil.Split(connectUrl, ":")
    if #rt == 3 then
      ip = string.sub(rt[2], 3)
      port = tonumber(rt[3])
    else
      log(bWriteLog and "AccelSystem.AddAccelLobbyAddress() return by connectUrl format error!!")
      on_add_addr_finish()
      return
    end
    log(bWriteLog and "AccelSystem.AddAccelLobbyAddress() protocol: " .. lobbyProtocol .. " ip:" .. ip .. " port:" .. tostring(port))
    AccelSystem.TryResolveIP(ip, function(real_ip)
      if real_ip ~= nil and real_ip ~= "" and AccelSystem.IsIPAddrFormat(real_ip) then
        Client.LobbyAddAddress(lobbyProtocol, real_ip, port)
      end
      on_add_addr_finish()
    end)
  else
    log(bWriteLog and "AccelSystem.AddAccelLobbyAddress() do nothing by disable")
    on_add_addr_finish()
  end
end
function AccelSystem.AddNewArenaAddress(protocol, ip, port, on_add_addr_finish)
  log(bWriteLog and "AccelSystem.AddNewArenaAddress")
  if AccelSystem.IsEnableAccel() == true then
    if AccelSystem.AccelerationAvailable() == true then
      AccelSystem.TryResolveIP(ip, function(real_ip)
        if real_ip ~= nil and real_ip ~= "" and AccelSystem.IsIPAddrFormat(real_ip) then
          AccelSystem.latestDSIP = real_ip
          AccelSystem.latestDSPort = port
          AccelSystem.latestDSProtocol = protocol
          Client.GameMasterAddNewArenaAddress(protocol, real_ip, port)
        end
        on_add_addr_finish()
      end)
    else
      log(bWriteLog and "AccelSystem.AddNewArenaAddress do nothing by acceleration: " .. tostring(AccelSystem.GetAccelerationStatus()))
      on_add_addr_finish()
    end
  else
    log(bWriteLog and "AccelSystem.AddNewArenaAddress do nothing by disable accl")
    on_add_addr_finish()
  end
end
function AccelSystem.AddAccelAddress(protocol, ip, port, on_add_addr_finish)
  log(bWriteLog and "AccelSystem.AddAccelAddress")
  if AccelSystem.IsEnableAccel() == true then
    if AccelSystem.AccelerationAvailable() == true then
      AccelSystem.TryResolveIP(ip, function(real_ip)
        if real_ip ~= nil and real_ip ~= "" and AccelSystem.IsIPAddrFormat(real_ip) then
          Client.GameMasterAddAccelAddr(protocol, real_ip, port)
        end
        on_add_addr_finish()
      end)
    else
      log(bWriteLog and "AccelSystem.AddAccelAddress do nothing by acceleration: " .. tostring(AccelSystem.GetAccelerationStatus()))
      on_add_addr_finish()
    end
  else
    log(bWriteLog and "AccelSystem.AddAccelAddress do nothing by disable accl")
    on_add_addr_finish()
  end
end
function AccelSystem.Switch2FastMode()
  log(bWriteLog and "AccelSystem.Switch2FastMode")
  if AccelSystem.IsEnableAccel() == true and AccelSystem.AccelerationAvailable() and AccelSystem.latestDSIP ~= nil and AccelSystem.latestDSIP ~= "" and AccelSystem.IsIPAddrFormat(AccelSystem.latestDSIP) then
    Client.GameMasterAddAccelAddr(AccelSystem.latestDSProtocol, AccelSystem.latestDSIP, AccelSystem.latestDSPort)
  end
end
function AccelSystem.ClearAccelAddress()
  log(bWriteLog and "AccelSystem.ClearAccelAddress")
  if AccelSystem.IsEnableAccel() == true then
    AccelSystem.latestDSIP = nil
    AccelSystem.latestDSPort = nil
    AccelSystem.latestDSProtocol = nil
    Client.GameMasterClearAccelAddr()
  else
    log(bWriteLog and "AccelSystem.ClearAccelAddress do nothing by disable accl")
  end
end
function AccelSystem.OnPostSceneLoad(eventType, eventID, status)
  log(bWriteLog and "AccelSystem.OnPostSceneLoad:" .. status.current)
  local gameStatus = status.current
  if gameStatus == GameStatus.Lobby and AccelSystem.IsEnableAccel() == true then
    AccelSystem.ClearAccelAddress()
  end
end
function AccelSystem.SaveConfig()
  log(bWriteLog and "AccelSystem.SaveConfig")
  local PlayerPrefs = require("client.logic.LogicPlayerPrefs.playerprefs")
  local localStoreDic = PlayerPrefs.LoadFileToTable_N(PlayerPrefs.ePlayerPrefsType.ePersonalRecord)
  if localStoreDic == nil then
    localStoreDic = {}
  end
  localStoreDic.EnableAccel = AccelSystem.enableAccelLocalSwitch
  localStoreDic.OnlyWifiAccel = AccelSystem.onlyWifiAccelLocalSwitch
  PlayerPrefs.SaveTableToFile_N(localStoreDic, PlayerPrefs.ePlayerPrefsType.ePersonalRecord)
end
function AccelSystem.LoadConfig()
  log(bWriteLog and "AccelSystem.LoadConfig")
  local PlayerPrefs = require("client.logic.LogicPlayerPrefs.playerprefs")
  local localAccelData = PlayerPrefs.LoadFileToTable_N(PlayerPrefs.ePlayerPrefsType.ePersonalRecord)
  if localAccelData ~= nil then
    if localAccelData.EnableAccel ~= nil then
      AccelSystem.enableAccelLocalSwitch = localAccelData.EnableAccel
    end
    if localAccelData.OnlyWifiAccel ~= nil then
      AccelSystem.onlyWifiAccelLocalSwitch = localAccelData.OnlyWifiAccel
    end
  end
end
function AccelSystem.LoadRemoteConfig()
  log(bWriteLog and "AccelSystem.LoadRemoteConfig")
  local remoteConfig4SwitcherJson = HDmpveRemote.HDmpveRemoteConfigGetString("GM_Switcher", "")
  if remoteConfig4SwitcherJson ~= nil and 2 < #remoteConfig4SwitcherJson then
    local remoteConfig4Switcher = json.decode(remoteConfig4SwitcherJson)
    if remoteConfig4Switcher ~= nil then
      local gameAccelCountry = remoteConfig4Switcher.game
      if gameAccelCountry ~= nil then
        if string.find(gameAccelCountry, "all") ~= nil or string.find(gameAccelCountry, tostring(GameMaster.GetPlayerCountryNo())) ~= nil then
          AccelSystem.enableAccelServerSwitch = true
        else
          AccelSystem.enableAccelServerSwitch = false
        end
      else
        log(bWriteLog and "AccelSystem.LoadRemoteConfig  key:game is nil:")
        AccelSystem.enableAccelServerSwitch = false
      end
      local lobbyProxyCountry = remoteConfig4Switcher.lobby
      if lobbyProxyCountry ~= nil then
        if string.find(lobbyProxyCountry, "all") ~= nil or string.find(lobbyProxyCountry, tostring(GameMaster.GetPlayerCountryNo())) ~= nil then
          AccelSystem.enableLobbyProxyServerSwitch = true
        else
          AccelSystem.enableLobbyProxyServerSwitch = false
        end
      else
        log(bWriteLog and "AccelSystem.LoadRemoteConfig  key:lobby is nil:")
        AccelSystem.enableLobbyProxyServerSwitch = false
      end
    end
    local remoteConfigValue = HDmpveRemote.HDmpveRemoteConfigGetString("GM_LobbySvrs", "")
    if remoteConfigValue ~= nil and remoteConfigValue ~= "null" and remoteConfigValue ~= "" then
      AccelSystem.lobbyProxyBackupServer = remoteConfigValue
    else
      AccelSystem.lobbyProxyBackupServer = ""
    end
    remoteConfigValue = HDmpveRemote.HDmpveRemoteConfigGetString("GM_LobbyPorts", "")
    if remoteConfigValue ~= nil and remoteConfigValue ~= "null" and remoteConfigValue ~= "" then
      AccelSystem.lobbyProxyBackupPort = remoteConfigValue
    else
      AccelSystem.lobbyProxyBackupPort = ""
    end
    remoteConfigValue = HDmpveRemote.HDmpveRemoteConfigGetString("GM_LobbyEchoPorts", "")
    if remoteConfigValue ~= nil and remoteConfigValue ~= "null" and remoteConfigValue ~= "" then
      AccelSystem.lobbyEchoBackupPort = remoteConfigValue
    else
      AccelSystem.lobbyEchoBackupPort = ""
    end
  end
  log(bWriteLog and "AccelSystem.LoadRemoteConfig svrswitch: " .. tostring(AccelSystem.enableAccelServerSwitch) .. " lobbyswitch:" .. tostring(AccelSystem.enableLobbyProxyServerSwitch) .. " lbsvr:" .. AccelSystem.lobbyProxyBackupServer .. " lbport:" .. AccelSystem.lobbyProxyBackupPort)
end
function AccelSystem.LoadServerConfig()
  log(bWriteLog and "AccelSystem.LoadServerConfig")
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  if not login_module.ClientBasicCfg then
    log(bWriteLog and "AccelSystem.LoadServerConfig skip for config is nil")
    return
  end
  AccelSystem.echoServerPort = DataMgr.echo_port or 8030
  if DataMgr.xy_userid ~= nil and #DataMgr.xy_userid > 0 then
    AccelSystem.gameMasterUserId = DataMgr.xy_userid
    log(bWriteLog and "AccelSystem.LoadServerConfig xy_userid: " .. AccelSystem.gameMasterUserId)
    AccelSystem.InitAccelSDK()
  else
    AccelSystem.GenAndReportXYUserId()
  end
  EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_MATCH_UPDATE_ZONE)
end
function AccelSystem.IsEnableAccel()
  local isSystemVPNOpened = false
  local isEnable = AccelSystem.enableAccelLocalSwitch and AccelSystem.enableAccelServerSwitch and isSystemVPNOpened == false
  return isEnable
end
function AccelSystem.IsServerEnableAccel()
  local isSystemVPNOpened = Client.IsSystemVPNOpened()
  local canOpen = isSystemVPNOpened == false and AccelSystem.enableAccelServerSwitch
  return canOpen
end
function AccelSystem.IsLocalEnableAccel()
  return AccelSystem.enableAccelLocalSwitch
end
function AccelSystem.SetEnableAccel(isEnable)
  log(bWriteLog and "AccelSystem.SetEnableAccel" .. tostring(isEnable))
  AccelSystem.enableAccelLocalSwitch = isEnable
  AccelSystem.SaveConfig()
end
function AccelSystem.GetAccelerationStatus()
  return Client.GameMasterGetAccelerationStatus()
end
function AccelSystem.AccelerationAvailable()
  local accelerationStatus = AccelSystem.GetAccelerationStatus()
  if accelerationStatus == AccelSystem.E_AccelerationUserStatus.Free or accelerationStatus == AccelSystem.E_AccelerationUserStatus.Trial or accelerationStatus == AccelSystem.E_AccelerationUserStatus.Vip or accelerationStatus == AccelSystem.E_AccelerationUserStatus.Debuging then
    return true
  else
    return false
  end
end
function AccelSystem.IsOnlyWiFiAccel()
  return AccelSystem.onlyWifiAccelLocalSwitch
end
function AccelSystem.SetOnlyWifiAccel(wifiOnly)
  log(bWriteLog and "AccelSystem.SetOnlyWifiAccel")
  AccelSystem.onlyWifiAccelLocalSwitch = wifiOnly
  if AccelSystem.IsEnableAccel() then
    Client.GameMasterSetOnlyWifiAccel(wifiOnly)
  end
  AccelSystem.SaveConfig()
end
function AccelSystem.AccelOpened()
  if AccelSystem.IsEnableAccel() and Client.GameMasterIsAccelOpened() then
    return 1
  else
    return 0
  end
end
function AccelSystem.IsEnableLobbyAccel()
  local isSystemVPNOpened = Client.IsSystemVPNOpened()
  return AccelSystem.enableLobbyProxyServerSwitch and isSystemVPNOpened == false
end
function AccelSystem.IsIPAddrFormat(ipStr)
  if type(ipStr) ~= "string" then
    return false
  end
  local len = string.len(ipStr)
  if len < 7 or 15 < len then
    return false
  end
  local point = string.find(ipStr, "%p", 1)
  local pointNum = 0
  while point ~= nil do
    if string.sub(ipStr, point, point) ~= "." then
      return false
    end
    pointNum = pointNum + 1
    point = string.find(ipStr, "%p", point + 1)
    if 3 < pointNum then
      return false
    end
  end
  if pointNum ~= 3 then
    return false
  end
  local num = {}
  for w in string.gmatch(ipStr, "%d+") do
    num[#num + 1] = w
    local kk = tonumber(w)
    if kk == nil or 255 < kk then
      return false
    end
  end
  if #num ~= 4 then
    return false
  end
  return true
end
function AccelSystem.ReportAccelEvent(subEvent, k0, k1)
  if subEvent == nil or k0 == nil then
    return
  end
  local param = {}
  table.insert(param, tostring(k0))
  if k1 == nil then
    k1 = 0
  end
  table.insert(param, tostring(k1))
  log(bWriteLog and "AccelSystem.ReportAccelEvent: NetProxyEvent, subEvent: " .. subEvent .. ", K0:" .. tostring(k0) .. ", K1:" .. tostring(k1))
  Client.GEMReportSubEvent(GameFrontendHUD, "NetProxyEvent", subEvent, param)
end
function AccelSystem.ReportAccelSwitcherStatus()
  local switchStatus = 0
  if GameMaster.IsEnvVailable() == false then
    return
  end
  if AccelSystem.enableAccelServerSwitch then
    switchStatus = switchStatus | 1
  end
  if AccelSystem.enableAccelLocalSwitch then
    switchStatus = switchStatus | 2
  end
  if AccelSystem.onlyWifiAccelLocalSwitch then
    switchStatus = switchStatus | 4
  end
  AccelSystem.ReportAccelEvent("AccelSwitcher", switchStatus)
end
function AccelSystem.TryResolveIP(domain, on_finish_callback)
  local TimeUtil = require("client.common.time_util")
  if AccelSystem.IsIPAddrFormat(domain) == true then
    on_finish_callback(domain)
    AccelSystem.ReportAccelEvent("ReovleIP", AccelSystem.E_ResovleIPEventType.NothingToDo)
  else
    local realIP
    local tryCounter = AccelSystem.MAX_TRY_RESOLVE_IP
    local startTime = TimeUtil.GetMiliseconds()
    local timer_ticker = require("common.time_ticker")
    AccelSystem.resolveIPTimer = timer_ticker.AddTimerLoop(0, function()
      realIP = Client.GetIpAddrByHost(domain)
      tryCounter = tryCounter - 1
      if realIP ~= nil and 0 < #realIP or tryCounter <= 0 then
        timer_ticker.RemoveTimer(AccelSystem.resolveIPTimer)
        AccelSystem.resolveIPTimer = nil
        log(bWriteLog and "AccelSystem.TryResolveIP IP:" .. realIP)
        if AccelSystem.IsIPAddrFormat(realIP) == true then
          local endTime = TimeUtil.GetMiliseconds()
          AccelSystem.ReportAccelEvent("ReovleIP", AccelSystem.E_ResovleIPEventType.Succ, endTime - startTime)
        else
          realIP = nil
          AccelSystem.ReportAccelEvent("ReovleIP", AccelSystem.E_ResovleIPEventType.Failed)
        end
        on_finish_callback(realIP)
      end
    end, TIMER_INFINITE, 0.05)
  end
end
function AccelSystem.GenAndReportXYUserId()
  if AccelSystem.IsServerEnableAccel() == true then
    local GameMasterHandler = require("client.network.Protocol.GameMasterHandler")
    GameMasterHandler.send_report_gamemaster_info_req(Client.GetITopGameId(), GameMaster.GetGUID(), GameMaster.GetUserId())
  end
end
function AccelSystem.OnReportGamemasterInfoResp(code, xy_userid)
  log(bWriteLog and "AccelSystem.OnReportGamemasterInfoResp:" .. tostring(code) .. ", " .. tostring(xy_userid))
  if code == 0 then
    log(bWriteLog and "AccelSystem.OnReportGamemasterInfoResp succ")
    AccelSystem.gameMasterUserId = xy_userid
    AccelSystem.InitAccelSDK()
  elseif code == 100290001 then
    log(bWriteLog and "AccelSystem.OnReportGamemasterInfoResp err_xunyou_invalid_params")
    AccelSystem.gameMasterUserId = ""
  elseif code == 100290002 then
    log(bWriteLog and "AccelSystem.OnReportGamemasterInfoResp err_xunyou_xyuid_already_exist")
    AccelSystem.gameMasterUserId = xy_userid
    AccelSystem.InitAccelSDK()
  else
    log(bWriteLog and "AccelSystem.OnReportGamemasterInfoResp do notthing")
    AccelSystem.gameMasterUserId = ""
  end
end
return AccelSystem