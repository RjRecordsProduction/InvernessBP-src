local GameMaster = require("client.slua.logic.gamemaster.logic_gamemaster")
SVPNSystem = SVPNSystem or {
  enableVPNServerSwitch = false,
  vpnNodeServerConfig = "",
  vpnPermissionError = false,
  isVPNSDKInited = false,
  isVPNRunning = false,
  vpnAvailableNodes = {},
  vpnCoroutine = nil,
  lastLoginErrorTable = {},
  lastLoginChannel = "",
  vpnLoginErrorTable = {},
  vpnPermissionCancelLimit = 2,
  vpnBackupServer = "",
  vpnBackupPortMin = 0,
  vpnBackupPortMax = 0
}
local E_VPNErrorCode = {
  Succ = 0,
  EnginErr = 1001,
  RepeatCalled = 1002,
  EnvNotSupport = 1003,
  JobWorking = 1004,
  UserInfoNotSet = 1009,
  ParameterErr = 1012,
  TearDownCalled = 1013,
  OSVerNotSupport = 1014,
  ServiceStartFail = 1015,
  NeedPermission = 8000,
  ServiceNotStart = 8007
}
SVPNSystem.local E_VPNStep = {
  Start = 0,
  Prepare = 1,
  Init = 2,
  SetUserInfo = 3,
  DialUp = 4,
  DialUpAsync = 5,
  HangUp = 6,
  HangUpAsync = 7,
  TearDown = 8,
  GetNodes = 9,
  AskPermission = 99
}
SVPNSystem.
function SVPNSystem.Init()
  log(bWriteLog and "SVPNSystem.Init")
  GameMaster.Init()
end
function SVPNSystem.TryStartVPN(channel)
  SVPNSystem.enableVPNServerSwitch = false
  SVPNSystem.vpnNodeServerConfig = ""
  SVPNSystem.vpnPermissionError = false
  SVPNSystem.lastLoginChannel = channel
  if SVPNSystem.IsEnvVailable() == false then
    log(bWriteLog and "SVPNSystem.TryStartVPN return by env unvailable")
    return false
  end
  if SVPNSystem.IsLocalEnableVPN(channel) == false then
    log(bWriteLog and "SVPNSystem.TryStartVPN return by local record")
    return false
  end
  SVPNSystem.enableVPNServerSwitch = SVPNSystem.LoadRemoteConfig(channel)
  if SVPNSystem.enableVPNServerSwitch == false then
    log(bWriteLog and "SVPNSystem.TryStartVPN return by remote switcher disable")
    return false
  end
  if SVPNSystem.InitVPNSDK() == false then
    log(bWriteLog and "SVPNSystem.TryStartVPN return by init failed")
    return false
  end
  local sdkRet = SVPNSystem.StartVPN()
  return sdkRet
end
function SVPNSystem.OnIMSDKLoginResult(resutlCode)
  log(bWriteLog and "SVPNSystem.OnIMSDKLoginResult:" .. tostring(resutlCode))
  local loginSucc = resutlCode == 0
  if loginSucc ~= true and resutlCode ~= 1001 and resutlCode ~= 1002 and SVPNSystem.lastLoginChannel ~= nil and 0 < #SVPNSystem.lastLoginChannel then
    log(bWriteLog and "SVPNSystem.OnIMSDKLoginResult Add:" .. tostring(SVPNSystem.lastLoginChannel))
    local channelLoginRecord = SVPNSystem.lastLoginErrorTable[SVPNSystem.lastLoginChannel]
    if channelLoginRecord == nil then
      channelLoginRecord = 0
    end
    channelLoginRecord = channelLoginRecord + 1
    log(bWriteLog and "SVPNSystem.OnIMSDKLoginResult set local record:" .. tostring(channelLoginRecord) .. " ," .. SVPNSystem.lastLoginChannel)
    SVPNSystem.lastLoginErrorTable[SVPNSystem.lastLoginChannel] = channelLoginRecord
  end
  SVPNSystem.CloseVPN(loginSucc)
end
function SVPNSystem.IsEnvVailable()
  if GameMaster.IsEnvVailable() == false then
    log(bWriteLog and "AccelSystem.OnLogin return by env unvailable")
    return false
  end
  local OSVersionName = Client.GetOSVersion()
  log(bWriteLog and "[SVPNSystem.IsEnvVailable] OSVersionName:" .. tostring(OSVersionName))
  local OSMajorVersion = 0
  local endPos = string.find(OSVersionName, "%.")
  if endPos == nil and 0 < #OSVersionName then
    OSMajorVersion = tonumber(OSVersionName)
  else
    OSMajorVersion = tonumber(string.sub(OSVersionName, 1, endPos - 1))
  end
  if OSMajorVersion == nil or OSMajorVersion < 5 then
    log(bWriteLog and "[SVPNSystem.IsEnvVailable] return with OSMajorVersion < 5")
    return false
  end
  return true
end
function SVPNSystem.OnGameMasterEvent(eventName, result)
  log(bWriteLog and "SVPNSystem.OnGameMasterEvent:" .. eventName .. ", " .. tostring(result))
  if eventName == "DIAL_UP_RESULT" then
    logic_connection_waiting:Hide(1)
    SVPNSystem.ReportVPNEvent(SVPNSystem.E_VPNStep.DialUpAsync, result)
    coroutine.resume(SVPNSystem.vpnCoroutine)
  elseif eventName == "VPN_PERMISSION_RESULT" then
    SVPNSystem.ReportVPNEvent(SVPNSystem.E_VPNStep.AskPermission, result)
  end
end
function SVPNSystem.InitVPNSDK()
  log(bWriteLog and "SVPNSystem.InitSDKVPN")
  if SVPNSystem.isVPNSDKInited == true then
    return true
  end
  if SVPNSystem.enableVPNServerSwitch == false then
    return false
  end
  if SVPNSystem.vpnPermissionCancelLimit <= 0 then
    log(bWriteLog and "SVPNSystem.InitVPNSDK cancel by reached limited")
    return false
  end
  if Client.IsSystemVPNOpened() == true then
    log(bWriteLog and "SVPNSystem.InitVPNSDK cancel by system vpn opened")
    return false
  end
  SVPNSystem.ReportVPNEvent(SVPNSystem.E_VPNStep.Start, 0)
  local sdkRet = Client.VPNPrepare()
  if sdkRet ~= SVPNSystem.E_VPNErrorCode.Succ then
    log(bWriteLog and "SVPNSystem.InitVPNSDK prepare fail:" .. tostring(sdkRet))
    if sdkRet == 1 then
      SVPNSystem.vpnPermissionCancelLimit = SVPNSystem.vpnPermissionCancelLimit - 1
      SVPNSystem.vpnPermissionError = true
    end
    SVPNSystem.ReportVPNEvent(SVPNSystem.E_VPNStep.Prepare, sdkRet)
    return false
  end
  local appVer = Client.GetAppVersion()
  sdkRet = Client.InitVPN(GameMaster.GetGUID(), appVer)
  if sdkRet ~= SVPNSystem.E_VPNErrorCode.Succ and sdkRet ~= SVPNSystem.E_VPNErrorCode.RepeatCalled then
    log(bWriteLog and "SVPNSystem.InitVPNSDK InitVPN fail:" .. tostring(sdkRet))
    SVPNSystem.ReportVPNEvent(SVPNSystem.E_VPNStep.Init, sdkRet)
    return false
  end
  if SVPNSystem.HasSetupVPNBackupSvr() then
    Client.VPNSetNodelist(SVPNSystem.vpnBackupServer)
  end
  if SVPNSystem.vpnBackupPortMin ~= 0 and SVPNSystem.vpnBackupPortMax ~= 0 then
    Client.VPNSetPortRange(SVPNSystem.vpnBackupPortMin, SVPNSystem.vpnBackupPortMax)
  end
  local userId, token = SVPNSystem.GetVPNUserInfo()
  log(bWriteLog and "SVPNSystem.InitVPNSDK VPNSetUserInfo with:" .. userId .. ", " .. token)
  sdkRet = Client.VPNSetUserInfo(userId, token, "")
  if sdkRet ~= SVPNSystem.E_VPNErrorCode.Succ then
    log(bWriteLog and "SVPNSystem.InitVPNSDK VPNSetUserInfo fail:" .. tostring(sdkRet))
    SVPNSystem.ReportVPNEvent(SVPNSystem.E_VPNStep.SetUserInfo, sdkRet)
    return false
  end
  local nodeList = Client.VPNGetNodeRegionList()
  if nodeList == nil or #nodeList <= 0 then
    log(bWriteLog and "SVPNSystem.InitVPNSDK VPNGetNodeRegionList nodeList is empty")
    SVPNSystem.ReportVPNEvent(SVPNSystem.E_VPNStep.GetNodes, 1)
    if SVPNSystem.HasSetupVPNBackupSvr() == false then
      return false
    end
  end
  log(bWriteLog and "SVPNSystem.InitVPNSDK VPNGetNodeRegionList nodeList:" .. tostring(nodeList))
  local StringUtil = require("common.string_util")
  SVPNSystem.vpnAvailableNodes = StringUtil.Split(nodeList, "|")
  SVPNSystem.isVPNSDKInited = true
  return true
end
function SVPNSystem.StartVPN()
  log(bWriteLog and "SVPNSystem.StartVPN")
  if SVPNSystem.isVPNSDKInited ~= true or SVPNSystem.isVPNRunning then
    log(bWriteLog and "SVPNSystem.StartVPN StartVPN do nothing by vpn not inited or vpn running!")
    return false
  end
  if Client.IsSystemVPNOpened() == true then
    log(bWriteLog and "SVPNSystem.StartVPN cancel by system vpn opened")
    return false
  end
  local region = ""
  if SVPNSystem.HasSetupVPNBackupSvr() then
    region = ""
  else
    if SVPNSystem.vpnAvailableNodes == nil or #SVPNSystem.vpnAvailableNodes <= 0 then
      log(bWriteLog and "SVPNSystem.StartVPN VPNGetNodeRegionList return by vpnNodes is empty")
      return false
    end
    local TimeUtil = require("client.common.time_util")
    math.randomseed(TimeUtil.OSTime())
    local randomNodeIndex = math.random(1, #SVPNSystem.vpnAvailableNodes)
    region = SVPNSystem.vpnAvailableNodes[randomNodeIndex]
    if region == nil then
      log(bWriteLog and "SVPNSystem.StartVPN return by available node is nil")
      return false
    end
    for index = 1, #SVPNSystem.vpnAvailableNodes do
      local vpnNode = SVPNSystem.vpnAvailableNodes[index]
      if vpnNode == SVPNSystem.vpnNodeServerConfig then
        region = SVPNSystem.vpnNodeServerConfig
        break
      end
    end
  end
  log(bWriteLog and "SVPNSystem.StartVPN Dialup with:" .. region .. " regionConfiged:" .. SVPNSystem.vpnNodeServerConfig)
  Client.SetVpnServiceStrategy("filterMode", 5)
  local sdkRet = Client.VPNDialUp(region)
  if sdkRet ~= SVPNSystem.E_VPNErrorCode.Succ then
    log(bWriteLog and "SVPNSystem.StartVPN VPNDialUp fail:" .. tostring(sdkRet))
    SVPNSystem.ReportVPNEvent(SVPNSystem.E_VPNStep.DialUp, sdkRet)
    return false
  else
    logic_connection_waiting:Show(1)
  end
  SVPNSystem.isVPNRunning = true
  return true
end
function SVPNSystem.CloseVPN(withLoginSucc)
  log(bWriteLog and "SVPNSystem.CloseVPN")
  if SVPNSystem.isVPNRunning and withLoginSucc == false then
    local channelLoginRecord = SVPNSystem.vpnLoginErrorTable[SVPNSystem.lastLoginChannel]
    if channelLoginRecord == nil then
      channelLoginRecord = 0
    end
    channelLoginRecord = channelLoginRecord + 1
    SVPNSystem.vpnLoginErrorTable[SVPNSystem.lastLoginChannel] = channelLoginRecord
  end
  if SVPNSystem.enableVPNServerSwitch == false then
    log(bWriteLog and "SVPNSystem.CloseVPN do nothing by server switch closed")
    return
  end
  local sdkRet = Client.VPNHandUp()
  if sdkRet ~= SVPNSystem.E_VPNErrorCode.Succ and sdkRet ~= SVPNSystem.E_VPNErrorCode.JobWorking then
    log(bWriteLog and "SVPNSystem.CloseVPN VPNHandUp fail:" .. tostring(sdkRet))
    SVPNSystem.ReportVPNEvent(SVPNSystem.E_VPNStep.HangUp, sdkRet)
    return
  end
  if withLoginSucc == true then
    sdkRet = Client.VPNTearDown()
    if sdkRet ~= SVPNSystem.E_VPNErrorCode.Succ then
      SVPNSystem.ReportVPNEvent(SVPNSystem.E_VPNStep.TearDown, sdkRet)
    end
    log(bWriteLog and "SVPNSystem.CloseVPN VPNTearDown:" .. tostring(sdkRet))
  end
  SVPNSystem.isVPNRunning = false
end
function SVPNSystem.LoadRemoteConfig(channel)
  local enableSwitch = false
  local remoteConfig4VPNJson = HDmpveRemote.HDmpveRemoteConfigGetString("GM_VPNLogin", "")
  log(bWriteLog and "SVPNSystem.LoadServerVPNConfig  Config:" .. tostring(remoteConfig4VPNJson))
  if remoteConfig4VPNJson ~= nil and 2 < #remoteConfig4VPNJson then
    local remoteConfig4VPN = json.decode(remoteConfig4VPNJson)
    local countNo = GameMaster.GetPlayerCountryNo()
    local allLoginChannel = "all"
    if remoteConfig4VPN[allLoginChannel] ~= nil then
      local channelConfig = remoteConfig4VPN[allLoginChannel]
      local cuntryKey = "c" .. tostring(countNo)
      if channelConfig[cuntryKey] ~= nil then
        enableSwitch = true
        SVPNSystem.vpnNodeServerConfig = channelConfig[cuntryKey]
      end
    end
    if enableSwitch == false and remoteConfig4VPN[channel] ~= nil then
      local channelConfig = remoteConfig4VPN[channel]
      local cuntryKey = "c" .. tostring(countNo)
      if channelConfig[cuntryKey] ~= nil then
        enableSwitch = true
        SVPNSystem.vpnNodeServerConfig = channelConfig[cuntryKey]
      end
    end
    local remoteConfigValue = HDmpveRemote.HDmpveRemoteConfigGetString("GM_VPNSvrs", "")
    if remoteConfigValue ~= nil and remoteConfigValue ~= "null" and remoteConfigValue ~= "" then
      SVPNSystem.vpnBackupServer = remoteConfigValue
    else
      SVPNSystem.vpnBackupServer = ""
    end
    remoteConfigValue = HDmpveRemote.HDmpveRemoteConfigGetString("GM_VPNPortRange", "")
    if remoteConfigValue ~= nil and 2 <= #remoteConfigValue then
      local remoteConfigDict = json.decode(remoteConfigValue)
      SVPNSystem.vpnBackupPortMin = remoteConfigDict.min or 0
      SVPNSystem.vpnBackupPortMax = remoteConfigDict.max or 0
    end
  end
  return enableSwitch
end
function SVPNSystem.IsLocalEnableVPN(channel)
  local ret = false
  if SVPNSystem.lastLoginErrorTable ~= nil and SVPNSystem.lastLoginErrorTable[channel] ~= nil and SVPNSystem.lastLoginErrorTable[channel] >= 1 then
    ret = true
  else
    ret = false
    log(bWriteLog and "SVPNSystem.IsLocalEnableVPN return by first login")
  end
  if ret == true and SVPNSystem.vpnLoginErrorTable ~= nil and SVPNSystem.vpnLoginErrorTable[channel] ~= nil and SVPNSystem.vpnLoginErrorTable[channel] >= 3 then
    ret = false
    log(bWriteLog and "SVPNSystem.IsLocalEnableVPN return by login failed too many")
  end
  return ret
end
function SVPNSystem.HasSetupVPNBackupSvr()
  if SVPNSystem.vpnBackupServer == nil or SVPNSystem.vpnBackupServer == "" or SVPNSystem.vpnBackupServer == "null" then
    return false
  else
    return true
  end
end
function SVPNSystem.GetVPNUserInfo()
  local userId = ""
  local token = ""
  if Client.IsShipping() == false then
    local testingUserInfos = {
      {
        "pubgmD35F1test",
        "4D5Xpeaag#XF"
      },
      {
        "pubgmD35F2test",
        "$2Ge&nlLt5ru"
      },
      {
        "pubgmD35F3test",
        "bKSTZ%4nZkPQ"
      }
    }
    local TimeUtil = require("client.common.time_util")
    math.randomseed(TimeUtil.OSTime())
    local testingUser = testingUserInfos[math.random(1, #testingUserInfos)]
    userId = testingUser[1]
    token = testingUser[2]
  elseif DataMgr ~= nil and DataMgr.roleData ~= nil and DataMgr.roleData.openID ~= nil and DataMgr.roleData.openID ~= "0" and DataMgr.roleData.openID ~= 0 then
    userId = DataMgr.roleData.openID
    token = userId
  else
    userId = FuncUtil.GetDVID()
    token = userId
  end
  return userId, token
end
function SVPNSystem.ReportVPNEvent(step, ret)
  local param = {}
  table.insert(param, tostring(step))
  table.insert(param, tostring(ret))
  log(bWriteLog and "SVPNSystem.ReportVPNEvent: NetProxyEvent, subEvent: VPNStep" .. ", step:" .. tostring(step) .. ", ret:" .. tostring(ret))
  Client.GEMReportSubEvent(GameFrontendHUD, "NetProxyEvent", "VPNStep", param)
end
return SVPNSystem