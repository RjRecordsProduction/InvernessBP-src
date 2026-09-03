local StoreGameHelper = import("StoreGameHelper")
local SDKMacros = require("client.slua.config.ClientMacros.SDKMacros")
local IMSDKErrorCode = SDKMacros.IMSDKErrorCode
local M = {
  CMD = {
    GCNotify = 1,
    GCAuthenticateLocalPlayer = 2,
    GCReportScore = 3,
    GCReportAchievement = 4,
    GCLoadFriends = 5,
    GCLoadLeaderboard = 6,
    GCLoadAchievement = 7,
    GCLoadReceivedChallenges = 8,
    PGSInited = 9,
    PGSSignIn = 10,
    PGSLoadAchieve = 11,
    PGSUnlockAchieve = 12,
    PGSIncreaseAchieve = 13,
    PGSRequestServerAuthCode = 14
  },
  ERR = {
    Succ = 1,
    NotInited = 2,
    NotAuthenticate = 3,
    Timeout = 4,
    SDKErr = 5,
    Duplicated = 6
  },
  Inited = false,
  IsAuthenticate = false
}
function M.OnLogin()
  log(bWriteLog and "logic_store_game_interface:OnLogin")
end
function M.OnLogout()
  log(bWriteLog and "logic_store_game_interface:OnLogout")
  M.PGSLoginInfo = nil
  M.LastAuthCodeRequestTime = nil
end
function M:Init()
  log(bWriteLog and "logic_store_game_interface:Init")
  if not self:IsStoreGameSupported() then
    log(bWriteLog and "logic_store_game_interface:Init return by not supported")
    return
  end
  if M.Inited then
    log(bWriteLog and "logic_store_game_interface:Init already")
    return
  end
  StoreGameHelper.Get():Initialize()
  StoreGameHelper.Get().StoreGameCallback:Add(function(cmd, retJson)
    log(bWriteLog and string.format("logic_store_game_interface:StoreGameCallback: %d, %s", cmd, tostring(retJson)))
    self:StoreGameCallbackHandler(cmd, retJson)
  end)
  StoreGameHelper.Get():InitGP()
  M.Inited = true
end
function M:StoreGameCallbackHandler(cmd, retJson)
  log(bWriteLog and string.format("logic_store_game_interface:StoreGameCallbackHandler, cmd:%s", cmd))
  log(bWriteLog and string.format("logic_store_game_interface:StoreGameCallbackHandler, retJson:%s", retJson))
  local ret = json.decode(retJson)
  if cmd == M.CMD.GCAuthenticateLocalPlayer then
    log(bWriteLog and "logic_store_game_interface:StoreGameCallbackHandler author ret")
    if ret.imsdkRetCode == IMSDKErrorCode.SUCCESS then
      self:OnAuthenticateCallback(M.ERR.Succ)
    else
      log(bWriteLog and "logic_store_game_interface:StoreGameCallbackHandler author error: " .. tostring(ret.imsdkRetCode) .. ", " .. tostring(ret.thirdRetCode))
      self:OnAuthenticateCallback(M.ERR.SDKErr)
    end
  elseif cmd == M.CMD.PGSInited or cmd == M.CMD.PGSSignIn then
    if ret.imsdkRetCode == IMSDKErrorCode.SUCCESS and ret.retExtraJson and string.find(ret.retExtraJson, "playerName", 1, true) then
      self:OnAuthenticateCallback(M.ERR.Succ)
    end
  elseif cmd == M.CMD.GCReportAchievement then
    log(bWriteLog and "logic_store_game_interface:StoreGameCallbackHandler report achievement ret")
  elseif cmd == M.CMD.PGSRequestServerAuthCode then
    if ret.imsdkRetCode == IMSDKErrorCode.SUCCESS then
      local PGSLoginInfo = json.decode(ret.retExtraJson)
      self.      self:TrySendReportPGSInfo(PGSLoginInfo)
    else
      log(bWriteLog and "logic_store_game_interface:StoreGameCallbackHandler author error: " .. tostring(ret.imsdkRetCode) .. ", " .. tostring(ret.thirdRetCode))
    end
  else
    log(bWriteLog and "logic_store_game_interface:StoreGameCallbackHandler not handler", cmd)
  end
end
function M:OnAuthenticateCallback(err)
  log(bWriteLog and string.format("logic_store_game_interface:OnAuthenticateCallback, err:%s", tostring(err)))
  if err == M.ERR.Succ then
    M.IsAuthenticate = true
    self:PGSRequestServerAuthCode()
  end
end
function M:AuthenticateLocalPlayer()
  log(bWriteLog and "logic_store_game_interface:AuthenticateLocalPlayer")
  if not M.Inited then
    log(bWriteLog and "logic_store_game_interface:AuthenticateLocalPlayer return by not inited ")
    return M.ERR.NotInited
  end
  M.IsAuthenticate = false
  StoreGameHelper.Get():AuthenticateLocalPlayer()
  local timer_ticker = require("common.time_ticker")
  M.timeout_timer = timer_ticker.AddTimer(45, function()
    self:OnAuthenticateCallback(M.ERR.Timeout)
  end)
  return M.ERR.Succ
end
function M:ReportAchievement(achievmentID, percent)
  log(bWriteLog and string.format("logic_store_game_interface, achievmentID:%s", achievmentID))
  log(bWriteLog and string.format("logic_store_game_interface, percent:%s", percent))
  if not M.Inited then
    log(bWriteLog and "logic_store_game_interface:ReportAchievement return by not inited ")
    return M.ERR.NotInited
  end
  if not self:IsGCAuthenticate() then
    log(bWriteLog and "logic_store_game_interface:ReportAchievement return by not authenticate ")
    return M.ERR.NotAuthenticate
  end
  StoreGameHelper.Get():ReportAchievement(achievmentID, percent)
  return M.ERR.Succ
end
function M:LoginGPManual()
  log(bWriteLog and "logic_store_game_interface:LoginGPManual")
  if not M.Inited then
    log(bWriteLog and "logic_store_game_interface:LoginGPManual return by not inited ")
    return M.ERR.NotInited
  end
  StoreGameHelper.Get():LoginGPManual()
  return M.ERR.Succ
end
function M:PGSRequestServerAuthCode()
  log(bWriteLog and "logic_store_game_interface:PGSRequestServerAuthCode")
  if not M.Inited then
    log(bWriteLog and "logic_store_game_interface:PGSRequestServerAuthCode return by not inited ")
    return M.ERR.NotInited
  end
  local now = os.time()
  local AuthCodeRequestThrottleSeconds = 2
  if self.LastAuthCodeRequestTime and AuthCodeRequestThrottleSeconds > now - self.LastAuthCodeRequestTime then
    log(bWriteLog and "logic_store_game_interface:PGSRequestServerAuthCode - skip, throttled within 2s")
    return M.ERR.Duplicated
  end
  self.LastAuthCodeRequestTime = now
  StoreGameHelper.Get():RequestServerAuthCode()
end
function M:UnlockGPAchievement(achievmentID)
  log(bWriteLog and "logic_store_game_interface:UnlockGPAchievement")
  if not M.Inited then
    log(bWriteLog and "logic_store_game_interface:UnlockGPAchievement return by not inited ")
    return M.ERR.NotInited
  end
  if not self:IsGCAuthenticate() then
    log(bWriteLog and "logic_store_game_interface:UnlockGPAchievement return by not authenticate ")
    return M.ERR.NotAuthenticate
  end
  StoreGameHelper.Get():UnlockGPAchievement(achievmentID)
  return M.ERR.Succ
end
function M:IncreaseGPAchievement(achievmentID, step)
  log(bWriteLog and "logic_store_game_interface:IncreaseGPAchievement")
  if not M.Inited then
    log(bWriteLog and "logic_store_game_interface:IncreaseGPAchievement return by not inited ")
    return M.ERR.NotInited
  end
  if not self:IsGCAuthenticate() then
    log(bWriteLog and "logic_store_game_interface:IncreaseGPAchievement return by not authenticate ")
    return M.ERR.NotAuthenticate
  end
  StoreGameHelper.Get():IncreaseGPAchievement(achievmentID, step)
  return M.ERR.Succ
end
function M:IsGCAuthenticate()
  return M.IsAuthenticate
end
function M:Destroy()
  self:ClearPGSAuthCodeTimeout()
  M.Inited = false
  M.IsAuthenticate = false
  StoreGameHelper.Get().StoreGameCallback:Clear()
  StoreGameHelper.Get():UnInitialize()
  StoreGameHelper.Destroy()
end
function M:NotifyGetPGSLoginInfo()
  self.HasNotifiedGetPGSLoginInfo = true
  if not self:IsStoreGameSupported() then
    log(bWriteLog and "logic_store_game_interface:NotifyGetPGSLoginInfo - not supported, send empty data")
    local EmptyPGSLoginInfo = {
      serverAuthCode = "",
      playerName = "",
      playerId = "",
      reason = "NOT_SUPPORT"
    }
    self:TrySendReportPGSInfo(EmptyPGSLoginInfo)
    return
  end
  if not self:IsGCAuthenticate() then
    log(bWriteLog and "logic_store_game_interface:NotifyGetPGSLoginInfo - not authenticated, send empty data")
    local EmptyPGSLoginInfo = {
      serverAuthCode = "",
      playerName = "",
      playerId = "",
      reason = "NOT_AUTHOR"
    }
    self:TrySendReportPGSInfo(EmptyPGSLoginInfo)
    return
  end
  self:PGSRequestServerAuthCode()
  self:ClearPGSAuthCodeTimeout()
  local timer_ticker = require("common.time_ticker")
  self.PGSAuthCodeTimeoutTimer = timer_ticker.AddTimer(8, function()
    log(bWriteLog and "logic_store_game_interface:NotifyGetPGSLoginInfo - PGSRequestServerAuthCode timeout, send empty data")
    self.PGSAuthCodeTimeoutTimer = nil
    local EmptyPGSLoginInfo = {
      serverAuthCode = "",
      playerName = "",
      playerId = "",
      reason = "TIME_OUT"
    }
    self:TrySendReportPGSInfo(EmptyPGSLoginInfo)
  end)
end
function M:TrySendReportPGSInfo(loginInfo)
  self:ClearPGSAuthCodeTimeout()
  local currentGameStatus = GameStatus.GetGameStatus()
  if currentGameStatus ~= GameStatus.Login and currentGameStatus ~= GameStatus.None and self.HasNotifiedGetPGSLoginInfo == true then
    self.HasNotifiedGetPGSLoginInfo = false
    log_tree("send_report_pgs_info_req", loginInfo)
    local LobbyHandler = require("client.network.Protocol.LobbyHandler")
    LobbyHandler.send_report_pgs_info_req(loginInfo)
  end
end
function M:ClearPGSAuthCodeTimeout()
  if self.PGSAuthCodeTimeoutTimer then
    local timer_ticker = require("common.time_ticker")
    timer_ticker.RemoveTimer(self.PGSAuthCodeTimeoutTimer)
    self.PGSAuthCodeTimeoutTimer = nil
  end
end
function M:IsStoreGameSupported()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS then
    local miniSupportOSVer = HDmpveRemote.HDmpveRemoteConfigGetInt("MiniSupportStoreGameOSVer", 13)
    local device_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.device_module)
    local OSMajorVersion = device_module:GetOSMajorVersion()
    if miniSupportOSVer > OSMajorVersion then
      log(bWriteLog and "logic_store_game_interface:IsStoreGameSupported return by lower os version")
      return false
    end
  elseif Client.GetDevicePlatformName() == DevicePlatformNameMacros.Android then
    local googleServiceVersionCode = tonumber(Client.GetGoogleServiceVersionCode()) or 0
    if googleServiceVersionCode == 0 then
      log(bWriteLog and "logic_store_game_interface:IsStoreGameSupported return by google service error")
      return false
    end
    local DisablePGS = HDmpveRemote.HDmpveRemoteConfigGetInt("DisablePGS", 0)
    if DisablePGS == 1 then
      Client.SaveToSharedPreferences("PGSDisabled", "true")
      log(bWriteLog and "logic_store_game_interface:IsStoreGameSupported return by DisablePGS")
      return false
    elseif DisablePGS == 2 then
      Client.SaveToSharedPreferences("PGSDisabled", "false")
    end
    local aosShop = Client.GetAOSSHOP()
    local AOSSHOPMacros = require("client.slua.config.ClientMacros.AOSSHOPMacros")
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    if not PublishRegionMacros.IsGlobalVersion() and not PublishRegionMacros.IsCEVersion() then
      log(bWriteLog and "logic_store_game_interface:IsStoreGameSupported return by not global/ce region")
      return false
    end
    if aosShop ~= AOSSHOPMacros.Google then
      log(bWriteLog and "logic_store_game_interface:IsStoreGameSupported return by not google play shop")
      return false
    end
  else
    log(bWriteLog and "logic_store_game_interface:IsStoreGameSupported return by not ios/android")
    return false
  end
  return true
end
return M