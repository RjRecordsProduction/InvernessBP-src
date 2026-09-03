local login_module = {}
local TimeUtil = require("client.common.time_util")
local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
local local local local strRegion = Client and Client.GetPublishRegion()
local platform = Client and Client.GetDevicePlatformName()
local extraData5s = {
  showUIKey = "com_msg_box_5s",
  androidCallback = function()
    return true
  end
}
local Show_All_Login_Btn = HDmpveRemote.HDmpveRemoteConfigGetBool("Show_All_Login_Btn", false)
local IsHideBgBgGuest = function()
  if Client.IsDevelopment() then
    log(bWriteLog and "IsHideBgBgGuest, dev version return false")
    return false
  end
  if not globalConfig.IsDirectConnect() then
    log(bWriteLog and "IsHideBgBgGuest, not direct connect version return false")
    return false
  end
  log(bWriteLog and "IsHideBgBgGuest, shipping and direct connect version return true")
  return true
end
local ENUM_Type = {
  None = 0,
  RequestVerifyCode = 1,
  ChangePassword = 2,
  ModifyAccount = 3,
  CheckIsRegisted = 4,
  CheckVerifyCodeValid = 5
}
local ELoginFsmState = {
  State_SplashScreen = 1,
  State_VersionUpdate = 2,
  State_Login = 3,
  State_ChooseServer = 4
}
local ELoginFSMEvent = {
  Event_SSTVU = 1,
  Event_VUTL = 2,
  Event_SSTL = 3,
  Event_LTCS = 4,
  Event_CSTL = 5
}
function login_module:DefineAndResetData()
  log_warning(bWriteLog and "  :login_module: DefineAndResetData")
  self.nLoginType = 0
  self.sIpRegion = nil
  self.LoginTypeList = nil
  self.CPhone_mail = "phonemail"
  self.nLoginFsmState = ELoginFsmState.State_SplashScreen
  self.nReportedSkippedError = nil
  self.versionInfo = nil
  self.sIgnoreResourceVersion = nil
  self.sIgnoreAppVersion = nil
  self.beEnableCDNGetVersion = nil
  self.bPlayedSplash = nil
  self.phoneMailType = 0
  self.lastAddrArray = nil
  self.lastAddrID = nil
  self.lastAreaID = nil
  self.nSelServerTab = 1
  self.nSelServerIdx = 1
  self.nSelPufferIdx = 1
  self.loginLobbyInfo = {}
  self.bIsRelogin = nil
  self.bIsInitLogin = false
  self.bHasLogout = false
  self.bLoginNextRsp = nil
  self.logoutCallback = nil
  self.showLoginCallback = nil
  self.no_auth_username = nil
  self.no_auth_password = nil
  self.no_auth_isRelogin = nil
  self.commonSwitch = {}
  self.bUsingOfflineServer = false
  self.bHasSendLogin = nil
  self.bJustScanLogin = nil
  self.sBanNickname = nil
  self.sBancountry = nil
  self.nAppeal_switch = 0
  self.nLink_type = nil
  self.bIsFirstInVietnam = nil
  self.bIsChooseVietnam = nil
  self.nCountDownRetryRefreshedTime = 0
  self.nCountDownRetryRefreshPassedTime = 0
  self.nLastIsScan = nil
  self.recommendStatus = nil
  self.recommendChannels = nil
  self.recommendLastRaw = nil
  self.logoutSvrThenLogoutSDK = true
  local playerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  self.playerData = playerPrefsSystem.LoadFileToTable_N(playerPrefsSystem.ePlayerPrefsType.eLoginData)
  if not self.playerData then
    self:LoadPlayerData()
  end
  self.bRecvCloudToken = false
  self.CloudTokenInfo = nil
  self.bRecvSyncBaseInfo = true
  self.gmLoginChannel = nil
  self.loginAccountData = {
    reLoginNum = 0,
    accountNum = 0,
    firstLoginTime = nil
  }
  self.historyLoginAccount = {}
  self.bReLoginAccount = false
  self.bBanIOSCheckAppleFirstLogin = false
  self.bGmCloudPhoneCode = nil
end
function login_module:OnPreSwitchGameStatus(preState, nextState)
  if nextState ~= GameStatus.Lobby and not GameStatus.IsInMainCity() then
    FuncUtil.OpenFlushAsyncLoading(false)
  end
  if nextState == GameStatus.Login then
    log(bWriteLog and string.format("login_module:OnPreSwitchGameStatus, nextState:%s", nextState))
    self:CacheSDKAdjustAttr()
  end
end
function login_module:OnPostSwitchGameStatus(preStatus, currentStatus)
  log_warning(bWriteLog and "  : login_module:OnPostSwitchGameStatus:" .. tostring(currentStatus) .. " preStatus:" .. tostring(preStatus))
  local callBack = self.logoutCallback
  self.logoutCallback = nil
  if currentStatus == GameStatus.Login then
    log_warning(bWriteLog and "  login_module:OnPostSwitchGameStatus.  bIsRelogin = nil")
    self.bIsRelogin = nil
    self:InitAfterSwitchedGameStatus()
    if callBack then
      log(bWriteLog and "login_module:backLogin callback")
      callBack()
    end
  end
  if currentStatus == GameStatus.Lobby then
    self.bHasSendLogin = nil
    self:SaveLastLoginChannel()
    if Client.IsDevelopment() then
      UIManager.ShowUI(UIManager.UI_Config.GM_WhitePoint)
    end
    local EnableFileModifiedProtect = HDmpveRemote.HDmpveRemoteConfigGetInt("EnableFileModifiedProtectMode", 0)
    log(bWriteLog and "posidon EnableFileModifiedProtect finished " .. tostring(EnableFileModifiedProtect))
    if 0 < EnableFileModifiedProtect then
      self:PakMonitorStart(EnableFileModifiedProtect)
    end
    if not self.bRecvSyncBaseInfo then
      NetUtil.tryConnect(Enum_LOGIN_REPORT_CFG.UN_RECV_SYNC_BASE_INFO)
    end
  end
  if preStatus == GameStatus.Login then
    ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyModelPossess)
  end
end
function login_module:OnShowUpdate()
  log(bWriteLog and "login_module:OnShowUpdate.  ")
end
local UpdateToLogin
function login_module:OnShowLogin()
  log(bWriteLog and "login_module:OnShowLogin.  ")
  if not UpdateToLogin then
    UpdateToLogin = true
    self:FromUpdateToLogin()
  end
end
function login_module:DisableParticleStreamingOnPostLoad()
  log(bWriteLog and "DisableParticleStreamingOnPostLoad start")
  local STExtraGameInstance = import("STExtraGameInstance")
  local gameInstance = STExtraGameInstance.GetInstance()
  local DisableParticleStreamingOnPostLoad = HDmpveRemote.HDmpveRemoteConfigGetInt("DisableParticleStreamingOnPostLoad", 1)
  gameInstance:ExecuteCMD("r.CVarParticleDisableStreamingOnPostLoad", DisableParticleStreamingOnPostLoad)
  log(bWriteLog and "DisableParticleStreamingOnPostLoad end")
end
function login_module:EncryptionManagerPre()
  log(bWriteLog and "EncryptionManagerPre beg")
  local StringUtil = require("common.string_util")
  local STExtraGameInstance = import("STExtraGameInstance")
  local gameInstance = STExtraGameInstance.GetInstance()
  local OpenEncryptionManager = HDmpveRemote.HDmpveRemoteConfigGetInt("OpenEncryptionManager", 1)
  gameInstance:ExecuteCMD("r.OpenEncryptionManager", OpenEncryptionManager)
  log(bWriteLog and "EncryptionManagerPre manager set enable: " .. tostring(OpenEncryptionManager))
  local BypassAllZeroPak = HDmpveRemote.HDmpveRemoteConfigGetInt("BypassAllZeroPak", 1)
  gameInstance:ExecuteCMD("r.BypassAllZeroPak", BypassAllZeroPak)
  log(bWriteLog and "BypassAllZeroPak set enable: " .. tostring(BypassAllZeroPak))
  local PakEncryptionKeys = HDmpveRemote.HDmpveRemoteConfigGetString("PakEncryptionKeysPre", "")
  if string.len(PakEncryptionKeys) > 0 then
    local PakEncryptionKeyList = StringUtil.Split(PakEncryptionKeys, "%")
    for _, KeyParamString in pairs(PakEncryptionKeyList) do
      local StringUtil = require("common.string_util")
      local KeyParams = StringUtil.Split(KeyParamString, "|")
      if 4 <= #KeyParams then
        local EncKey = KeyParams[2]
        local KeyChainId = tonumber(KeyParams[3])
        local KeyIndex = tonumber(KeyParams[4])
        Client.SetEncryptKey(KeyChainId, KeyIndex, EncKey)
        log(bWriteLog and "EncryptionManagerPre key set: " .. tostring(EncKey) .. " " .. tostring(KeyChainId) .. " " .. tostring(KeyIndex))
      else
        log(bWriteLog and "EncryptionManagerPre return for KeyParams < 4: " .. tostring(KeyParamString))
      end
    end
  end
  log(bWriteLog and "EncryptionManagerPre end")
end
function login_module:FromUpdateToLogin()
  log(bWriteLog and "login_module:FromUpdateToLogin.  ")
  if HDmpveRemote.HDmpveRemoteConfigGetBool("UseNewLoginLogic410", true) then
    self:RunLogicOnUpdateFinished()
    local logic_puffer_file = require("client.slua.logic.download.puffer.logic_puffer_common")
    logic_puffer_file.USFCacheInitProcessPreDownload()
    local PufferDeleteManager = require("client.slua.logic.download.delete.puffer_delete_manager")
    PufferDeleteManager.DeleteLogicInLogin()
    PufferDeleteManager.HandleDeleteCrashFile()
    local version_up_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.version_up_module)
    version_up_module:DeleteOldNeedUpdateFiles()
    local EnableVirtualMerge = HDmpveRemote.HDmpveRemoteConfigGetBool("EnableVirtualMerge", false)
    if EnableVirtualMerge then
      log(bWriteLog and "VersionUpdateUI:AfterFinishedUpdate EnableVirtualMerge")
      local Enabled = Client.EnableMergeVirtual()
      log(bWriteLog and "VersionUpdateUI:AfterFinishedUpdate EnableVirtualMerge " .. tostring(Enabled))
    end
    self:SetupFilenameHideKeywords()
    self:DisableParticleStreamingOnPostLoad()
    if HDmpveRemote.HDmpveRemoteConfigGetBool("InitPufferFileListInLoginUI", true) then
      log_format("VersionUpdateUI:OnUpdateFinished. InitPufferFileListInLoginUI")
      local list = PufferDownloader.ReadPufferFileListJson()
      if list and next(list) then
        PufferDownloader.InitODPakManager()
      end
    end
    self:EncryptionManagerPre()
  end
  local STExtraGameInstance = import("STExtraGameInstance")
  local gameInstance = STExtraGameInstance.GetInstance()
  local FileCRCGuardCheckInterval = HDmpveRemote.HDmpveRemoteConfigGetInt("FileCRCGuardCheckInterval", 9999)
  log_format("login_module:FromUpdateToLogin pak.FileCRCGuardCheckInterval: %s", FileCRCGuardCheckInterval)
  gameInstance:ExecuteCMD("pak.FileCRCGuardCheckInterval", FileCRCGuardCheckInterval)
  local TableGuardCheckInterval = HDmpveRemote.HDmpveRemoteConfigGetInt("TableGuardCheckInterval", 9999)
  log_format("login_module:FromUpdateToLogin higgs.TableGuardCheckInterval: %s", TableGuardCheckInterval)
  gameInstance:ExecuteCMD("higgs.TableGuardCheckInterval", TableGuardCheckInterval)
end
function login_module:SetupFilenameHideKeywords()
  log(bWriteLog and "[SetupFilenameHideKeywords] Start setup keywords")
  local FileHideKeywords = HDmpveRemote.HDmpveRemoteConfigGetString("SecurityFileHideKeywords", "")
  if string.len(FileHideKeywords) <= 0 then
    return
  end
  local STExtraGameInstance = import("STExtraGameInstance")
  local gameInstance = STExtraGameInstance.GetInstance()
  gameInstance:ExecuteCMD("r.UseFilenameHideKeyword", 1)
  local FileHideKeywordsList = string.StrSplit(FileHideKeywords, ",")
  Client.SetFileHideKeywords(FileHideKeywordsList)
end
function login_module:RunLogicOnUpdateFinished()
  log_format("login_module:RunLogicOnUpdateFinished.")
  local ForceDisableCvm = HDmpveRemote.HDmpveRemoteConfigGetInt("ForceDisableCvm", 0)
  if ForceDisableCvm == 0 and Client.InitializeCvmWithRunPhase then
    Client.InitializeCvmWithRunPhase(3)
  end
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS then
    local IOSCheckSymbolSource = HDmpveRemote.HDmpveRemoteConfigGetInt("IOSCheckSymbolSource", 1)
    if 0 < IOSCheckSymbolSource and Client.CheckMemorySymbolSource and Client.CheckMemorySymbolSource() == 0 then
      local DocumentDir = Client.GetPureIOSDocumentsDirectory()
      local FlagFilePath = DocumentDir .. "/OSMallocJudge.flag"
      local file = io.open(FlagFilePath, "w")
      if file then
        file:write("1")
        file:close()
        log(bWriteLog and "CheckSymbolSource SaveStringToFile:" .. FlagFilePath)
      else
        log(bWriteLog and "CheckSymbolSource create failed:" .. FlagFilePath)
      end
    end
  end
  local StuckSwitchGameStatusInterval = HDmpveRemote.HDmpveRemoteConfigGetInt("StuckSwitchGameStatusInterval", 0)
  if 0 < StuckSwitchGameStatusInterval then
    FuncUtil.UE4ExecuteConsoleCommand("s.IosStuckSwitchGameStatusInterval " .. StuckSwitchGameStatusInterval)
  end
end
function login_module:PakMonitorStart(EnableMode)
  local targetDir = Client.ProjectSavedDir() .. "Paks/"
  local file_util = require("client.common.file_util")
  local paklist = file_util.FindFiles(targetDir, "pak", false, true)
  if not Client.IsShipping() or not Client.IsReleaseVersion() then
    log(bWriteLog and "Add Translate to white list")
    for i, value in ipairs(paklist) do
      if value == "translation_patch.pak" then
        table.remove(paklist, i)
        break
      end
    end
  end
  local path = Client.ProjectSavedDir() .. "Paks"
  Client.StartMonitorFileModified(path, 8)
  log(bWriteLog and "posidon EnableFileModifiedProtect ModifiedDelegate Set: " .. tostring(self.ModifiedDelegate))
  if self.ModifiedDelegate then
    slua_GameFrontendHUD.OnFileModifiedDelegate:Remove(self.ModifiedDelegate)
    log(bWriteLog and "posidon EnableFileModifiedProtect ModifiedDelegate Set Revmoed: " .. tostring(self.ModifiedDelegate))
  end
  self.ModifiedDelegate = slua_GameFrontendHUD.OnFileModifiedDelegate:Add(function(filename)
    local checkmate = false
    local SavedPrefix = Client.ProjectSavedDir() .. "Paks/"
    local ContentPrefix = Client.ProjectContentDir() .. "Paks/"
    for idx, pakname in pairs(paklist) do
      log(bWriteLog and "posidon EnableFileModifiedProtect " .. tostring(idx) .. " " .. tostring(pakname))
      if pakname == filename then
        local SubEvent = "PakOverwrite"
        local ParamTable = {
          tostring(filename),
          tostring(EnableMode)
        }
        Client.GEMReportSubEvent(GameFrontendHUD, "GRomeLinkEvent", SubEvent, ParamTable)
        log(bWriteLog and "posidon EnableFileModifiedProtect checkmate " .. tostring(filename) .. " file modified! Report It")
        if 1 < EnableMode then
          checkmate = true
          Client.DeleteFile(SavedPrefix .. filename)
          Client.DeleteFile(ContentPrefix .. filename)
          log(bWriteLog and "posidon EnableFileModifiedProtect checkmate " .. tostring(filename) .. " file modified! Delete It")
        end
      end
    end
    log(bWriteLog and "posidon EnableFileModifiedProtect " .. tostring(filename) .. " file modified by download")
    if checkmate then
      local tip = LocUtil.GetLocalizeResStr(25147)
      local title = LocUtil.GetLocalizeResStr(301137)
      local time_ticker = require("common.time_ticker")
      log(bWriteLog and "Trigger Req CHK List")
      time_ticker.AddTimerOnce(1, function()
        local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
        CommonMsgBoxMgr.Show(1, title, tip, function()
          GameStatus.QuitGame()
          return true
        end)
      end)
    end
  end)
  log(bWriteLog and "posidon EnableFileModifiedProtect Finished")
end
function login_module:RegistEvents()
  login_module.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_SETTING, EVENTID_SETTING_CHANGE_LANGUAGE, self.OnLanguageChanged, self)
  local IMSDKLoginFlowChcker = require("client.logic.login.logic_imsdk_login_flow_chcker")
  IMSDKLoginFlowChcker:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_PIPEMSG, EVENTID_PIPEMSG_LOGIN, self.OnPipeMsgLogin, self)
  self:AddCommonEvent(EVENTTYPE_PIPEMSG, EVENTID_PIPEMSG_GENERAL, self.OnPipeMsgGeneral, self)
  self:AddCommonEvent(EVENTTYPE_PIPEMSG, EVENTID_PIPEMSG_DEV_INFO, self.OnPipeMsgDevInfo, self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_LOGINUSERPROTOCOL, self.UserAgreementTips, self)
end
function login_module:GetLoginUI()
  return UIManager.GetUI(UIManager.UI_Config.Login_UIBP)
end
function login_module:CanShowMoreLoginChannel()
  log_warning(bWriteLog and "  login_module:CanShowMoreLoginChannel. Show_All_Login_Btn: " .. tostring(Show_All_Login_Btn))
  return Show_All_Login_Btn
end
function login_module:ContinueLoginAfterNotice()
  log(bWriteLog and "login_module.ContinueLoginAfterNotice")
  local loginUI = self:GetLoginUI()
  if loginUI then
    loginUI:AutoLoginWhenNeed()
  else
    log(bWriteLog and "login_module.ContinueLoginAfterNotice, version_update is not showing?")
  end
end
function login_module:ContinueLoginAfterVNGAdult()
  local loginUI = self:GetLoginUI()
  self:SetPlayerData("isVNGAdult", true)
  if loginUI then
    loginUI:LoginImplementation()
  else
    log(bWriteLog and "login_module.ContinueLoginAfterVNGAdult, login is not showing?")
  end
end
function login_module:ClearLoginCountAndTime()
  self.playerData.LoginCount = 0
  self.playerData.LoginTime = 0
  self:SaveTable()
  local loginUI = self:GetLoginUI()
  if loginUI then
    loginUI:ClearLoginCountAndTime()
  else
    log(bWriteLog and "login_module.ClearLoginCountAndTime, login is not showing?")
  end
end
function login_module:UpdateLoginCountAndTime()
  local loginUI = self:GetLoginUI()
  if loginUI then
    loginUI:UpdateLoginCountAndTime()
  else
    log(bWriteLog and "login_module.UpdateLoginCountAndTime, login is not showing?")
  end
end
function login_module:LoginByChannel(channel)
  local loginUI = self:GetLoginUI()
  if loginUI then
    loginUI:OnClickLogin(channel)
  else
    log(bWriteLog and "login_module.LoginByChannel, login is not showing?")
  end
end
function login_module:ShowLoginUI()
  local loginUI = self:GetLoginUI()
  if loginUI then
    loginUI:Show()
  else
    local begintime = slua.getMiliseconds()
    local logic_login_background = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_login_background)
    logic_login_background:ShowBackground(logic_login_background.ENUM_PHASE.LOGIN)
    UIManager.ShowUI(UIManager.UI_Config.Login_UIBP)
    local endtime = slua.getMiliseconds()
    log_shipping_client("login_module.ShowLoginUI useTime " .. tostring(endtime - begintime))
  end
end
function login_module:ShowButtonsAfterLoginFailed()
  self:SetLoginAble(true)
  local loginUI = self:GetLoginUI()
  if loginUI then
    loginUI:ShowLoginButtons()
  else
    log_warning(bWriteLog and "  : login_module:ShowButtonsAfterLoginFailed login is not showing?")
  end
end
function login_module:ShowFreezePopupUI(openid, channel, banEndTime)
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  local imsdkChannelName = IMSDKHelperInstance:ConvertIMSDKChannelToStr(channel, false)
  local SettingAccount = require("client.logic.setting.logic_setting_account")
  local imsdkChannelDisplayName = SettingAccount.GetPlatformDisplayName(imsdkChannelName)
  local TimeUtil = require("client.common.time_util")
  local time = TimeUtil.FormatTime_YMDHMS(banEndTime, true)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  local content = LocUtil.LocalizeResFormat(180001, imsdkChannelDisplayName, time, imsdkChannelDisplayName)
  local subContent = "##\229\166\130\230\158\156\232\191\153\228\184\141\230\152\175\230\130\168\229\148\175\228\184\128\231\153\187\229\189\149\232\174\190\229\164\135\239\188\140\230\130\168\232\191\152\229\143\175\228\187\165\228\189\191\231\148\168\230\137\171\231\160\129\231\153\187\229\189\149\239\188\140\233\129\191\229\133\141\232\180\166\229\143\183\231\154\132\229\174\137\229\133\168\233\163\142\233\153\169\227\128\130##"
  local TimeUtil = require("client.common.time_util")
  local scanCallback = function()
    UIManager.ShowUI(UIManager.UI_Config.Login_QRCode_Popup_UIBP)
  end
  local goReleaseCallback = function()
    local webModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.webModule)
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eAccountFreezeAppeal) or {}
    local TimeUtil = require("client.common.time_util")
    local time = TimeUtil.GetServerTimeInSec()
    saveData[time] = openid
    PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eAccountFreezeAppeal)
    local url = FuncUtil.GetDomainByID(3366187)
    local IntlHelper = import("IntlHelper")
    local DeviceOSInfo = require("client.logic.data.data_device_os")
    DeviceOSInfo.getDeviceOSInfo()
    local enc_openid = webModule:GetEncryptedDeviceInfoUrlValue(2, string.format("openid=%s", openid))
    local enc = webModule:GetEncryptedDeviceInfoUrlValue(2, "&device={device_name}&deviceId={device_id}&xwid={xwid}&scene=4")
    local game_id = Client.GetITopGameId(NetInterface)
    local country = self:GetIpRegion()
    local timezone = IntlHelper.GetLocalTimezone()
    local language = Client.GetCurrentLanguage()
    local params = "?enc=%s&game_id=%s&country=%s&language=%s&timezone=%s&enc_openid=%s"
    params = string.format(params, enc, game_id, country, language, timezone, enc_openid)
    url = url .. params
    webModule:JumpToWebPage(url, false)
  end
  UIManager.ShowUI(UIManager.UI_Config.login_scanlogin, LocUtil.GetLocalizeResStr(101001), content, nil, LocUtil.GetLocalizeResStr(200000052), LocUtil.GetLocalizeResStr(49265), scanCallback, goReleaseCallback)
end
function login_module:ConnectToGate(addrArray, addrID, areaID, addrName)
  local logic_cost_collector = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cost_collector)
  logic_cost_collector:MarkEventEnd(logic_cost_collector.EVENT_KEYS.LOGIN)
  logic_cost_collector:MarkEventEnd(logic_cost_collector.EVENT_KEYS.CHOOSE_SERVER)
  logic_cost_collector:MarkEventStart(logic_cost_collector.EVENT_KEYS.CONNECT_SERVER)
  logic_cost_collector:MarkIsolatedEventStart(logic_cost_collector.ISOLATED_EVENT_NAMES.WaitConnectToGate)
  FuncUtil.AddCrashContextMainFlow("61")
  Client.TriggerLoginCrashTest(0)
  if Tss then
    Tss.InvokeSDKIoctl(18, "AllowAPKCollect")
  end
  if addrArray then
    self.lastAddrArray = addrArray
  else
    addrArray = self.lastAddrArray
  end
  if addrID then
    self.lastAddrID = addrID
  else
    addrID = self.lastAddrID
  end
  if areaID then
    self.lastAreaID = areaID
  else
    areaID = self.lastAreaID
  end
  log(bWriteLog and "UpdateAndLoginFSM.ConnectToGate, addrID = " .. tostring(addrID))
  log_tree("UpdateAndLoginFSM.ConnectToGate, addrArray = ", addrArray)
  local login_protect_utils = require("client.slua.logic.login.login_protect_utils")
  local bCanLogin, iCD = login_protect_utils.CheckCanLogin()
  if not bCanLogin then
    if iCD and tonumber(iCD) >= 300 then
      local SettingAccount = require("client.logic.setting.logic_setting_account")
      SettingAccount.ClientLogout()
    end
    return
  end
  local NetManager = require("client.network.comm.NetManager")
  NetManager.Init()
  local logic_manager = require("client.logic.common.logic_manager")
  logic_manager.Init()
  local _addrArray
  local _addrID = 0
  local _serverName = "\230\173\163\229\188\143\230\156\141"
  local logic_login_server_utils = require("client.logic.update_login.logic_login_server_utils")
  if globalConfig.isSupervision then
    self.serverInfo = logic_login_server_utils.GetServerInfoByTypeAndRegion("SupervisionServer", PublishRegionMacros.GLOBAL)
    _addrArray = self.serverInfo.addr
    _serverName = "\231\155\145\228\191\174\230\156\141"
  elseif globalConfig.IsDirectConnect() == false then
    _    _    _serverName = addrName or _serverName
  else
    if PublishRegionMacros.IsCEVersion() then
      self.serverInfo = logic_login_server_utils.GetServerInfoByTypeAndRegion("CustomerExperienceServer", PublishRegionMacros.CE)
      _serverName = "CE\230\156\141"
    else
      local type = "OfficialServer"
      if Client.IsMatchVersion() then
        type = "CompetitionServer"
        local bOnline = true
        if Client.IsMatchNoAuthMode and Client.IsMatchNoAuthMode() then
          bOnline = not self.bUsingOfflineServer
        end
        strRegion = bOnline and "ONLINE" or "OFFLINE"
      elseif GlobalData.IsIOSCheck() then
        type = "ReviewServer"
      end
      local PublishAreaMgr = import("PublishAreaMgr")
      local area = PublishAreaMgr.GetArea()
      log(bWriteLog and "[muidarzhang] type: " .. type .. " strRegion: " .. strRegion .. " area: " .. area)
      if area == "DEFAULT" then
        self.serverInfo = logic_login_server_utils.GetServerInfoByTypeAndRegion(type, strRegion)
      else
        self.serverInfo = logic_login_server_utils.GetServerInfoByTypeAndRegion(type, strRegion, area)
      end
    end
    if self.serverInfo ~= nil then
      _addrArray = self.serverInfo.addr
    end
  end
  if _addrArray and 0 < #_addrArray then
    local utility = require("common.utility")
    local logic_login_backup = require("client.logic.login.logic_login_backup")
    xpcall(logic_login_backup.InitBackUpIPs, utility.ErrorMessageHandler, _addrArray)
    log(bWriteLog and "addrArray length: " .. #_addrArray)
    self.loginLobbyInfo.AddrID = _addrID
    self:connectLobby()
    local TournamentsManager = require("client.slua.logic.tournament.TournamentsManager")
    TournamentsManager.addrId = _addrID
  else
    log(bWriteLog and "not selected addr info\239\188\129")
  end
  local GdprSystem = require("client.slua.logic.gdpr.logic_gdpr")
  GdprSystem.InitData()
  if _serverName and _serverName ~= "" then
    log(bWriteLog and "UpdateAndLoginFSM.ConnectToGate _serverName: " .. _serverName)
    Client.AddCrashContextData(1009, _serverName, false, 100)
  end
end
function login_module:connectLobby()
  local loginLobbyInfo = self.loginLobbyInfo
  log(bWriteLog and "lobby url = " .. tostring(loginLobbyInfo.Url) .. " url id = " .. tostring(loginLobbyInfo.AddrID))
  if not loginLobbyInfo.Url or loginLobbyInfo.Url == "" then
    return
  end
  NetUtil.gameTick = false
  logic_connection_waiting:Show(1)
  local enableAutoReconnect = true
  local AutoReconnectType = HDmpveRemote.HDmpveRemoteConfigGetInt("AutoReconnectType", 0)
  if AutoReconnectType ~= 0 then
    if AutoReconnectType & 1 ~= 0 then
      enableAutoReconnect = false
    end
    if enableAutoReconnect == true and AutoReconnectType & 2 ~= 0 and Client.GetIsPlayerUsingVPN() then
      enableAutoReconnect = false
    end
    if enableAutoReconnect == true and AutoReconnectType & 4 ~= 0 and Client.GetAndroidCurrentFDNum() >= 700 then
      enableAutoReconnect = false
    end
  end
  if not enableAutoReconnect then
    local STExtraGameInstance = import("STExtraGameInstance")
    local gameInstance = STExtraGameInstance.GetInstance()
    gameInstance:ExecuteCMD("dmp.ConnectorAutoReconnect", 0)
  end
  local AccelSystem = require("client.slua.logic.gamemaster.logic_accel")
  local severID = loginLobbyInfo.AddrID and loginLobbyInfo.AddrID or 0
  if AccelSystem.IsEnableLobbyAccel() then
    AccelSystem.AddAccelLobbyAddress(loginLobbyInfo.Url, function()
      NetUtil.SendTime = TimeUtil.OSTime()
      NetUtil.ConnectToURL(loginLobbyInfo.Url)
      Client.SetGameSrvID(GameFrontendHUD, severID)
    end)
  else
    NetUtil.SendTime = TimeUtil.OSTime()
    NetUtil.ConnectToURL(loginLobbyInfo.Url)
    Client.SetGameSrvID(GameFrontendHUD, severID)
  end
end
function login_module:reconnectGateway()
  local logic_login_backup = require("client.logic.login.logic_login_backup")
  if logic_login_backup.PollingNextIp() then
    self:connectLobby()
    return true
  else
    return false
  end
end
function login_module:on_sync_lobby_info(ret, addr, key, updateAtRuntime)
  log(bWriteLog and "sync_lobby_info ret=" .. ret .. ",ip=" .. addr .. ",key=" .. key .. ",updateAtRuntime=" .. updateAtRuntime)
  if ret == NetErrorCode_NONE then
    self.loginLobbyInfo = {
      Url = addr,
      Key = key,
      UpdateAtRuntime = updateAtRuntime
    }
    self:connectLobby()
  else
    log(bWriteLog and "sync_lobby_info not ok:" .. ret)
  end
end
function login_module:on_redirect(url)
  NetUtil.ConnectReason = Enum_LOGIN_REPORT_CFG.REDIRECT
  self.loginLobbyInfo.Url = url
  log_warning(bWriteLog and "  :login_module:on_redirect url: " .. tostring(url))
  self:connectLobby()
end
function login_module:OnConnected(report)
  local logic_cost_collector = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cost_collector)
  logic_cost_collector:MarkIsolatedEventEnd(logic_cost_collector.ISOLATED_EVENT_NAMES.WaitConnectToGate)
  report = report or Enum_LOGIN_REPORT_CFG.CONNECT
  local sendLogin = function()
    self.bJustScanLogin = nil
    self:reqLoginLobby(self.bIsInitLogin, report)
  end
  local gs = GameStatus.GetGameStatus()
  log(bWriteLog and "  login_module:OnConnected. self.bJustScanLogin: " .. tostring(self.bJustScanLogin))
  if gs ~= GameStatus.Login or PublishRegionMacros.IsBLUEHOLE() or self.bJustScanLogin then
    log(bWriteLog and "  login_module:OnConnected.  is bluehole or not login, sendLogin")
    sendLogin()
    return
  end
  local LoginHandler = require("client.network.Protocol.LoginHandler")
  local hasRsp
  local device_id = Client.GetPhoneDeviceID()
  log(bWriteLog and "  login_module:OnConnected. device_id: " .. tostring(device_id))
  LoginHandler.send_check_online_req(device_id):Then(function(_, status, rsp_data)
    hasRsp = true
    log(bWriteLog and "  login_module:OnConnected. status: " .. tostring(status))
    if status == 0 then
      sendLogin()
    else
      self:AskFlushOut(rsp_data, sendLogin)
    end
  end)
  self:AddTimerOnce(2, function()
    if not hasRsp then
      logic_connection_waiting:Hide(2)
      sendLogin()
    end
  end)
end
local channelToStr = {
  [BP_ENUM_IMSDK_CHANNEL_FACEBOOK] = "Facebook",
  [BP_ENUM_IMSDK_CHANNEL_GAMECENTER] = "GameCenter",
  [BP_ENUM_IMSDK_CHANNEL_GOOGLEPLAY] = "Google",
  [BP_ENUM_IMSDK_CHANNEL_NOSCHAT] = FuncUtil.GetKeywordByID(3377008),
  [BP_ENUM_IMSDK_CHANNEL_GUEST] = "Guest",
  [BP_ENUM_IMSDK_CHANNEL_VK] = "VK",
  [BP_ENUM_IMSDK_CHANNEL_TWITTER] = "TWITTER",
  [BP_ENUM_IMSDK_CHANNEL_LINE] = "LINE",
  [BP_ENUM_IMSDK_CHANNEL_BGBG] = FuncUtil.GetKeywordByID(3377007),
  [BP_ENUM_IMSDK_CHANNEL_DISCORD] = "Discord",
  [BP_ENUM_IMSDK_CHANNEL_APPLE] = "Apple",
  [BP_ENUM_IMSDK_CHANNEL_UNIFIEDACCOUNT] = "Phone/Mail",
  [BP_ENUM_IMSDK_CHANNEL_HMS] = FuncUtil.GetKeywordByID(3377003),
  [BP_ENUM_IMSDK_CHANNEL_UNIFIEDACCOUNT_MAIL] = "Mail",
  [BP_ENUM_IMSDK_CHANNEL_UNIFIEDACCOUNT_PHONE] = "Phone",
  FF = "QrCode",
  [BP_ENUM_IMSDK_CHANNEL_WHATS] = "WhatsApp",
  [BP_ENUM_IMSDK_CHANNEL_TIKTOK] = "TikTok"
}
function login_module:GetChannelName(channel)
  return channel and channelToStr[channel]
end
function login_module:AskFlushOut(rsp_data, callback)
  rsp_data = rsp_data or {}
  log(bWriteLog and "  login_module:AskFlushOut. rsp_data.device_name: " .. tostring(rsp_data.device_name))
  log_tree("login_module:AskFlushOut", rsp_data)
  local channelStr = "Unknown"
  if rsp_data.account_type then
    channelStr = channelToStr[rsp_data.account_type]
  end
  channelStr = channelStr or "Unknown"
  if rsp_data.is_qrcode_login then
    channelStr = LocUtil.GetLocalizeResStr(200000062)
  end
  local name = rsp_data.device_name or ""
  local text = LocUtil.LocalizeResFormat(200000467, channelStr, name, rsp_data.region)
  local CancelLogin = function()
    self:backLogin()
  end
  UIManager.ShowUI(UIManager.UI_Config.Setting_ToKickOut_Popup, text, callback, CancelLogin)
end
local AOSSHOPMacros = require("client.slua.config.ClientMacros.AOSSHOPMacros")
local AOS2Index = {
  [AOSSHOPMacros.Google] = 0,
  [AOSSHOPMacros.Samsung] = 1,
  [AOSSHOPMacros.ThirdPartyPayment] = 2,
  [AOSSHOPMacros.Amazon] = 5,
  [AOSSHOPMacros.Simulator] = 4,
  [AOSSHOPMacros.HMS] = 6
}
function login_module:reqLoginLobby(isRelogin, reportId)
  local time_step_macros = require("client.slua.logic.performance.time_step_macros")
  local logic_time_cost_report = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_time_cost_report)
  logic_time_cost_report:SetStepStart(time_step_macros.ENUM_TIME_STEP.LoginToSyncBaseInfoStart)
  local DeviceOSInfo = require("client.logic.data.data_device_os")
  log_shipping_client("[Login process] LoginSystem.reqLoginLobby isRelogin:" .. tostring(isRelogin))
  log(bWriteLog and "LoginSystem.reqLoginLobby, isRelogin = " .. tostring(isRelogin))
  if not self.loginLobbyInfo then
    log(bWriteLog and "login_module.reqLoginLobby failed")
    return
  end
  local logic_enter_game = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_enter_game)
  if not logic_enter_game.priKey then
    Client.InitDH("2", "373578232348234253", -1)
    logic_enter_game:SetKey()
  end
  log(bWriteLog and "[seat]login_module.reqLoginLobby, pubKey = " .. tostring(logic_enter_game.pubKey))
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  local openId = IMSDKHelperInstance:getOpenID()
  local Unbind_Mgr = require("client.slua.logic.unbind_account.logic_unbind")
  Unbind_Mgr.login_channel = 0
  if self.nLoginType ~= 0 then
    Unbind_Mgr.login_channel = Unbind_Mgr.GetChannelIdByLoginPlatform(self.nLoginType)
  else
    Unbind_Mgr.login_channel = Unbind_Mgr.GetChannelIdByLoginPlatform(IMSDKHelperInstance:GetHDmpveChannelID())
  end
  local DolphinConfig = require("client.slua.umg.NewUpdate.dolphin_updater_config")
  local dolphinID = DolphinConfig:GetDolphinChannelId()
  if strRegion == PublishRegionMacros.TW or strRegion == PublishRegionMacros.VNG or strRegion == PublishRegionMacros.BLUEHOLE then
    local BusinessHelper = import("BusinessHelper")
    local fromStore = BusinessHelper.IsAppFromStore()
    if not fromStore then
      local isMiniApk = Client.IsSplitMiniPakVersion()
      if not isMiniApk then
        dolphinID = dolphinID + 1000
      else
        dolphinID = dolphinID + 2000
      end
    end
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local info = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eLoginHDmpveErr)
  PlayerPrefsSystem.SaveTableToFile_N({}, PlayerPrefsSystem.ePlayerPrefsType.eLoginHDmpveErr)
  local reason = 0
  if info and info.reason then
    reason = info.reason
  end
  local pufferIDArr = GCPufferDownloader.GetProductID(Puffer) or {}
  local pufferID = pufferIDArr[1] or 0
  self:UpdateAccountDataWithLogin(isRelogin, openId)
  local ext_info = {
    relogin = isRelogin,
    isTimeOutRelogin = NetUtil.bIsTimeOutReconnect,
    ob_version = GetWindowOBState(),
    reportId = reportId,
    src_itop_channel = Unbind_Mgr.login_channel,
    connect_url = tostring(self.loginLobbyInfo.Url),
    cli_pub_key = logic_enter_game.pubKey,
    dolphin_channel_id = dolphinID,
    puffer_channel_id = pufferID,
    ver117 = true,
    check_filler = true,
    installchannel = Client.GetNativePackageTag(),
    area_ip_no = Client.GetAreaIPNo(),
    gloud_connect_err = reason,
    bCrash = Client.IsLastSessionCrash(),
    login_sdk_info = IMSDKHelperInstance:GetIMSDKClientApiParams(),
    soda_autobuild = global_package_make_time_map and global_package_make_time_map.SODA_AutoBuild,
    is_small_pkg = false,
    loginAccountData = self.loginAccountData
  }
  if Client.GetYYXDeviceModel then
    ext_info.cloud_game_src = Client.GetYYXDeviceModel()
  end
  if strRegion == PublishRegionMacros.FIT then
    ext_info.is_small_pkg = true
  end
  local StatManager = import("StatManager")
  StatManager.GetInstance():ReportEventWithString(91, tostring(ext_info.cloud_game_src), true)
  local logic_cloud_game = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cloud_game)
  if logic_cloud_game:IsCloudVersion() then
    local TmpCloudTokenInfo = {}
    if logic_cloud_game:GetCloudGameType() == logic_cloud_game.CLOUD_GAME_TYPE.WL_TIME then
      TmpCloudTokenInfo = self.CloudTokenInfo
    elseif logic_cloud_game:GetCloudGameType() == logic_cloud_game.CLOUD_GAME_TYPE.PIONEER_CLOUD then
      TmpCloudTokenInfo = logic_cloud_game:GetCloudTokenInfo()
    end
    if TmpCloudTokenInfo ~= nil then
      ext_info.cloud_game_ip = TmpCloudTokenInfo.ip
      ext_info.cloud_game_deviceid = TmpCloudTokenInfo.deviceid
      ext_info.cloud_game_xid = TmpCloudTokenInfo.xid
      ext_info.cloud_game_channel = TmpCloudTokenInfo.clientType or 0
      ext_info.cloud_game_device_type = TmpCloudTokenInfo.deviceType or 0
    else
      print(bWriteLog and "TmpCloudTokenInfo = nil")
    end
  end
  ext_info.unified_type = 0
  local channel = Client.GetLoginChannel(NetInterface)
  print(bWriteLog and "LoginSystem.reqLoginLobby channel = " .. tostring(channel))
  if channel == BP_ENUM_PLAYFORM_UnifiedAccountByiTOP then
    if self.phoneMailType ~= 0 then
      ext_info.unified_type = self.phoneMailType
    else
      local tb = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eMailPhoneLoginType)
      if tb and tb.unified_type then
        print(bWriteLog and "LoginSystem.reqLoginLobby load unified_type = " .. tostring(tb.unified_type))
        ext_info.unified_type = tb.unified_type
      else
        print(bWriteLog and "LoginSystem.reqLoginLobby load unified_type = nil")
      end
    end
  end
  local desktool_launch = false
  local AdjustSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.AdjustSystem)
  if AdjustSystem:IsAwakedByAdjust() then
    local adjustLink = AdjustSystem:GetDeepLinkUrl()
    log(bWriteLog and "LoginSystem.reqLoginLobby is awaked by adjust! link url : " .. tostring(adjustLink))
    if string.find(adjustLink, "from=app_widget") then
      local match = string.match(adjustLink, "type=(%d+)")
      if match then
        local logic_activity_util = require("client.slua.logic.lobby.logic_activity_util")
        local desktopToolType = logic_activity_util.GetActivityDesktopToolType(tonumber(match))
        log(bWriteLog and "LoginSystem.reqLoginLobby adjustLink : " .. tostring(adjustLink) .. " desktopToolType : " .. tostring(desktopToolType))
        if desktopToolType and desktopToolType ~= ActivityDesktopToolType.None then
          desktool_launch = desktopToolType
        end
      end
    end
    if string.find(adjustLink, "module=" .. BP_ENUM_MODULE_ASSEMBLY) then
      local uid = string.match(adjustLink, "uid=(%d+)")
      if uid then
        ext_info.adjust_link_return_type = 0
        ext_info.adjust_link_return_uid = tonumber(uid)
      end
    end
  else
    log(bWriteLog and "LoginSystem.reqLoginLobby isn't awake by adjust!")
  end
  log(bWriteLog and "LoginSystem.reqLoginLobby desktool_launch : " .. tostring(desktool_launch))
  ext_info.  local PushSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PushSystem)
  if PushSystem:IsLaunchedByNotification() then
    if PushSystem:IsLaunchedByLocal() then
      ext_info.fcm_click_login_type = 1
      ext_info.fcm_click_login_id = PushSystem:GetLocalPushId()
      ext_info.fcm_click_login_msg_type = PushSystem:GetLocalPushType()
    elseif PushSystem:IsLaunchedByFCM() then
      ext_info.fcm_click_login_type = 2
      ext_info.fcm_click_login_id = PushSystem:GetFCMId()
      ext_info.fcm_click_login_msg_type = PushSystem:GetFCMMsgType()
    end
  else
    ext_info.fcm_click_login_type = 0
  end
  log_format("login_module:reqLoginLobby. fcm_click_login_type=%s, fcm_click_login_id=%s, fcm_click_login_msg_type=%s", tostring(ext_info.fcm_click_login_type), tostring(ext_info.fcm_click_login_id), tostring(ext_info.fcm_click_login_msg_type))
  if Client.IsMatchNoAuthMode and Client.IsMatchNoAuthMode() then
    ext_info.check_password = true
    ext_info.competition_account = self.no_auth_username
    ext_info.competition_password = self.no_auth_password
  end
  NetUtil.StartCheckLoginRsp()
  self.bIsRelogin = isRelogin
  local isEmulator = Client.IsEmulator()
  log(bWriteLog and "IsEmulator:" .. tostring(isEmulator))
  local device_type = isEmulator == true and 1 or 0
  if IsWoWEditor and not IsEditor then
    device_type = 4
  end
  DeviceOSInfo.getDeviceOSInfo()
  log_tree("DeviceOSInfo.InfoList", DeviceOSInfo.InfoList)
  local emulatorName = Client.GetEmulatorName()
  DeviceOSInfo.InfoList.EmulatorName = emulatorName
  DeviceOSInfo.InfoList.system_lang = Client.GetSystemLanguage()
  log(bWriteLog and "LoginSystem.reqLoginLobby system_lang = " .. DeviceOSInfo.InfoList.system_lang)
  log(bWriteLog and string.format("LoginSystem EmulatorName %s", DeviceOSInfo.InfoList.EmulatorName))
  local device_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.device_module)
  local startup_type = device_module:getStartUpType()
  local channelID = Client.GetInstallChannelID(NetInterface)
  local registerchannelID = Client.GetRegisterChannelID(NetInterface)
  log(bWriteLog and string.format("reqLoginLobby channelID = %s, registerchannelID = %s", tostring(channelID), tostring(registerchannelID)))
  local channelInfo = CDataTable.GetTableData("ChannelInfo", tostring(channelID))
  if channelInfo and channelInfo.IsExternal == 1 then
    BP_IS_EXTERNAL_CHANNEL = true
  else
    BP_IS_EXTERNAL_CHANNEL = false
  end
  log(bWriteLog and string.format("BP_IS_EXTERNAL_CHANNEL = %s", tostring(BP_IS_EXTERNAL_CHANNEL)))
  local currentTime = TimeUtil.OSDate("%Y-%m-%d %H:%M:%S")
  local IntlHelper = import("IntlHelper")
  local timezone = IntlHelper.GetLocalTimezone()
  local language = Client.GetCurrentLanguage()
  local logic_payment_api = require("client.logic.pay.logic_payment_api")
  local payPF = logic_payment_api:get_Centauri_pf()
  local aosShopIndex = 0
  local aosShop = Client.GetAOSSHOP()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if Client.GetDevicePlatformName() == DevicePlatformNameMacros.Android then
    if AOS2Index[aosShop] then
      aosShopIndex = AOS2Index[aosShop]
    end
  else
    if _G.IsEditor then
      aosShopIndex = 0
    else
      aosShopIndex = 1000
    end
    aosShop = "NonAndroid"
  end
  log(bWriteLog and string.format("AOSSHOP = %s, aosIndex = %d", tostring(aosShop), aosShopIndex))
  local appVersion = Client.GetApplicationVersion()
  log(bWriteLog and "LoginSystem.reqLoginLobby version = " .. appVersion)
  if Client.GetDevicePlatformName() == DevicePlatformNameMacros.Android then
    local NativeAppVersion = Client.GetNativeVersion()
    if NativeAppVersion ~= nil and NativeAppVersion ~= "" then
      appVersion = NativeAppVersion
      log(bWriteLog and "LoginSystem.reqLoginLobby version(use native in android) = " .. appVersion)
    end
  end
  self:RemoveLoginTimer()
  self.loginTimer = self:AddTimerOnce(20, function()
    self:LoginTimeOut()
  end)
  local logic_wardrobe_new = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  logic_wardrobe_new.clearSyncDepotItemInfo()
  local version_up_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.version_up_module)
  local tssVersion = version_up_module:GetTssVersion()
  local newloginFlag = 1
  log_tree("logic_lobby_ping_report", ext_info)
  local subsideFeatureLevel = Client.GetSubsideFeatureLevel()
  local HighestPufferPatch = ""
  local PufferResManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_res_manager)
  HighestPufferPatch = PufferResManager:GetHighestPufferPatchName()
  log(bWriteLog and "LoginSystem.reqLoginLobby HighestPufferPatch = " .. HighestPufferPatch)
  local extra = {}
  extra.pufferpatch = HighestPufferPatch
  local Logic_Offline_Invite = require("client.slua.logic.teamup.logic_offline_invite")
  local token = Logic_Offline_Invite.GetTokenByOperate()
  for k, v in pairs(DeviceOSInfo.InfoList) do
    if type(v) == "string" and string.find(v, "|") then
      log(bWriteLog and "[jonahwei]LoginSystem.reqLoginLobby: TLog Contain |, key = " .. tostring(k) .. "  value = " .. v)
      DeviceOSInfo.InfoList[k] = string.gsub(v, "|", "+")
    end
  end
  local version_util = require("client.common.version_util")
  local clientVersion = Client.GetAppVersion()
  local Versions = {}
  Versions.  Versions.  Versions.  Versions.patchVersion = version_util.GetAppVersion()
  log(bWriteLog and string.format("LoginSystem.reqLoginLobby appVersion: %s, clientVersion: %s, tssVersion: %s, patchVersion: %s", appVersion, clientVersion, tssVersion, Versions.patchVersion))
  local logic_return_activity_guide = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_activity_guide)
  local adjust_link_return_type = logic_return_activity_guide:GetADjustLinkReturnType(self.SDKAdjustAttr)
  if adjust_link_return_type then
    extra.  end
  local LoginHandler = require("client.network.Protocol.LoginHandler")
  log_tree("reqLoginLobby DeviceOSInfo.InfoList", DeviceOSInfo.InfoList)
  LoginHandler.send_login(clientVersion, DeviceOSInfo.InfoList, startup_type, ext_info, device_type, channelID, registerchannelID, currentTime, language, timezone, payPF, aosShopIndex, appVersion, tssVersion, Client.GetAndroidSOVersion(), newloginFlag, subsideFeatureLevel, extra, token, Versions)
  self.bRecvSyncBaseInfo = false
  local logic_lobby_ping_report = require("client.slua.logic.match.logic_lobby_ping_report")
  logic_lobby_ping_report.OnSendLogin()
  local NetManager = require("client.network.comm.NetManager")
  NetManager.InitLogRequestMsg()
  self.bHasSendLogin = true
  if reportId and reportId == Enum_LOGIN_REPORT_CFG.NET_MSG_TIME_OUT then
    self:AddTimerOnce(10, function()
      local LobbyHandler = require("client.network.Protocol.LobbyHandler")
      LobbyHandler.send_client_timeout_report_req("heart_beat")
    end)
  end
end
function login_module:ShowScanLoginUI()
  if IsWoWEditor then
    local ScriptHelperClient = import("ScriptHelperClient")
    ScriptHelperClient:OneUp_GLauncherGetLoginInfoJsonStr()
    return
  end
  local SettingAccount = require("client.logic.setting.logic_setting_account")
  local AllQRCodeLoginResults = SettingAccount.GetAllQRCodeLoginResults()
  if next(AllQRCodeLoginResults) then
    UIManager.ShowUI(UIManager.UI_Config.AccountScanLogin_UIBP)
  else
    UIManager.ShowUI(UIManager.UI_Config.Login_QRCode_Popup_UIBP)
  end
end
function login_module:SdkLogin(loginType)
  log_warning(bWriteLog and "login_module.SdkLogin, loginType = " .. tostring(loginType))
  local doLoginFunc = function(loginType)
    if loginType == BP_ENUM_PLAYFORM_QRCODE then
      self:ShowScanLoginUI()
      return
    end
    local StatManager = import("StatManager")
    StatManager.GetInstance():ReportEventWithNoParam(23, true)
    self.bHasLogout = false
    self.nLoginType = loginType
    local logic_imsdk_deeplink_login = require("client.logic.login.logic_imsdk_deeplink_login")
    logic_imsdk_deeplink_login:Init()
    if logic_imsdk_deeplink_login:LoginViaSystemWebview(loginType) then
      return
    end
    self:LoginWithExtraInfo(loginType)
  end
  if not self:CheckLoginChannelAvailability(loginType) then
    local IMSDKHelper = import("IMSDKHelper")
    local IMSDKHelperInstance = IMSDKHelper.GetInstance()
    local imsdkChannelId = IMSDKHelperInstance:ConvertTConndChannel2IMSDKChannel(loginType)
    local imsdkChannelName = IMSDKHelperInstance:ConvertIMSDKChannelToStr(imsdkChannelId, false)
    local SettingAccount = require("client.logic.setting.logic_setting_account")
    local imsdkChannelDisplayName = SettingAccount.GetPlatformDisplayName(imsdkChannelName)
    local title = LocUtil.GetLocalizeResStr(5077)
    local okbtnLabel = LocUtil.GetLocalizeResStr(43908)
    local text = LocUtil.LocalizeResFormatByStr(LocUtil.GetLocalizeResStr(46880122), imsdkChannelDisplayName)
    CommonMsgBoxMgr.Show(3, title, text, function()
      doLoginFunc(loginType)
    end, nil, okbtnLabel, nil, nil)
  else
    doLoginFunc(loginType)
  end
end
function login_module:LoginWithExtraInfo(loginType, extraJson, skipLocalCacheCheck)
  log_warning(bWriteLog and "  login_module:LoginWithExtraInfo. self.nLastIsScan: " .. tostring(self.nLastIsScan))
  if not self:CheckLoginAble() then
    return
  end
  log_warning(bWriteLog and "  login_module:LoginWithExtraInfo. loginType: " .. tostring(loginType))
  local isScan = false
  if self.nLastIsScan == 1 then
    isScan = true
  end
  local IMSDKSystem = require("client.logic.login.logic_imsdk")
  IMSDKSystem.StartIMSDKTimer(2)
  local logic_imsdk_interface = require("client.logic.login.logic_imsdk_interface")
  logic_imsdk_interface:Login(loginType, extraJson, skipLocalCacheCheck or isScan)
end
function login_module:CheckLoginChannelAvailability(loginType)
  local StringUtil = require("common.string_util")
  local unvilableChannles = HDmpveRemote.HDmpveRemoteConfigGetString("UnvilableChannles", "")
  local splits = StringUtil.Split(unvilableChannles, ",")
  for i, v in ipairs(splits) do
    if v == tostring(loginType) then
      return false
    end
  end
  return true
end
function login_module:quickLogin()
  self:OnShowLogin()
  local isForceAppUpdating = false
  local info = self.versionInfo
  if info and info.isNeedUpdating == "1" and info.isAppUpdating == "1" and info.isForcedUpdating == "1" then
    isForceAppUpdating = true
  end
  if not isForceAppUpdating then
    log(bWriteLog and "gavin LoginSystem.quickLogin")
    local refreshTokenBeforeExpDays = 0
    local rcStr = HDmpveRemote.HDmpveRemoteConfigGetString("ITOP_RefreshToken", "")
    log(bWriteLog and "LoginSystem.quickLogin  Config:" .. rcStr)
    local IMSDKHelper = import("IMSDKHelper")
    local IMSDKHelperInstance = IMSDKHelper.GetInstance()
    local quickLoginHDmpveChannelID = IMSDKHelperInstance:GetHDmpveChannelID()
    if rcStr and 2 < #rcStr then
      local rcDict = json.decode(rcStr)
      local SettingAccount = require("client.logic.setting.logic_setting_account")
      local quickLoginItopChannelName = SettingAccount.GetNameByHDmpveChannel(quickLoginHDmpveChannelID)
      if rcDict[quickLoginItopChannelName] ~= nil then
        local countNo = Client.GetIPRegion()
        local channelConfig = rcDict[quickLoginItopChannelName]
        local cuntryKey = "c" .. tostring(countNo)
        log(bWriteLog and "LoginSystem.quickLogin :" .. cuntryKey)
        if channelConfig[cuntryKey] then
          refreshTokenBeforeExpDays = tonumber(channelConfig[cuntryKey])
          refreshTokenBeforeExpDays = refreshTokenBeforeExpDays or 0
          log(bWriteLog and "LoginSystem.quickLogin refreshTokenBeforeExpDays:" .. tostring(refreshTokenBeforeExpDays))
        end
      end
    end
    local StatManager = import("StatManager")
    StatManager.GetInstance():ReportEventWithNoParam(23, true)
    log(bWriteLog and "LoginSystem.quickLogin, refreshTokenBeforeExpDays = " .. tostring(refreshTokenBeforeExpDays))
    Client.QuickLogin(NetInterface, refreshTokenBeforeExpDays)
    if 0 < quickLoginHDmpveChannelID then
      local IMSDKSystem = require("client.logic.login.logic_imsdk")
      IMSDKSystem.StartIMSDKTimer(1)
    end
  end
end
function login_module:on_login_next(login_next_interval)
  log(bWriteLog and "LoginSystem.on_login_next login_next_interval = " .. login_next_interval)
  login_next_interval = tonumber(login_next_interval)
  if login_next_interval == nil or login_next_interval <= 1 then
    log(bWriteLog and "LoginSystem.on_login_next err param")
    return
  end
  self.bLoginNextRsp = true
  local status = GameStatus.GetGameStatus()
  if not GameStatus.IsInFightingNotMainCity() then
    logic_connection_waiting:Show(1)
  end
  self:AddTimerOnce(login_next_interval, function()
    log(bWriteLog and "login_module.OnLoginNextCallBack")
    logic_connection_waiting:Hide(1)
    local isConnected = Client.IsConnected(NetInterface)
    log(bWriteLog and "  login_module:on_login_next. isConnected: " .. tostring(isConnected))
    if status == GameStatus.Login and isConnected then
      self:reqLoginLobby(self.bIsInitLogin)
    else
      NetUtil.Disconnect()
      NetUtil.tryConnect(Enum_LOGIN_REPORT_CFG.NET_CONNECT_CALLBACK)
    end
  end)
end
function login_module:on_login_rsp(ip_region, nation_switch, continent, commonSwitch, pingSvrPars, province)
  local gem_report_utils = require("client.logic.store.gem_report_utils")
  PufferDownloader.ReportPakInfoToTLog()
  log_shipping_client("[Login process] LoginSystem: login_rsp ip_region=" .. ip_region)
  local logic_lobby_ping_report = require("client.slua.logic.match.logic_lobby_ping_report")
  logic_lobby_ping_report.OnReceiveLoginRsp(true)
  self:RemoveLoginTimer()
  NetUtil.StopCheckLoginRsp()
  self.sIpRegion = ip_region
  Client.AddCrashContextData(6, tostring(ip_region), false, 100)
  log(bWriteLog and "LoginSystem: continent = " .. tostring(continent))
  self.  log(bWriteLog and "[DeanJYT] LoginSystem.on_login_rsp province = " .. tostring(province))
  self.  log(bWriteLog and "LoginSystem: self.commonSwitch.ReportBugSwitch = " .. tostring(type(self.commonSwitch) == "table" and self.commonSwitch.ReportBugSwitch))
  if commonSwitch then
    log_tree("LoginSystem: commonSwitch", commonSwitch)
    assert(type(commonSwitch) == "table", "commonSwitch need to be a table")
    self.    Client.SetVoiceSwitch(GameFrontendHUD, self.commonSwitch.FirstVoicePopupSwitch, self.commonSwitch.EUGDPRFunctionSwitch, self.commonSwitch.EUGDPRSettingSwitch)
    Client.SetSelfieSwitch(GameFrontendHUD, self.commonSwitch.SelfieInBattleSwitch)
    Client.SetReportBugSwitch(GameFrontendHUD, self.commonSwitch.ReportBugSwitch)
    gem_report_utils.SetReportLobbyEventEnable(self.commonSwitch.GEMUpdateEnable)
    if self.commonSwitch.ClientExceptionReportEnable then
      gem_report_utils.SetClientExceptionReportEnable(self.commonSwitch.ClientExceptionReportEnable)
    end
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    tlog_report_utils.SetMarketStayUpdateEnable(self.commonSwitch.MarketStayUpdateEnable)
    tlog_report_utils.SetBusinessReportEnable(self.commonSwitch.BusinessReportEnable or false)
    if self.commonSwitch.DevCloseWatermark then
      local LobbyWaterMarkSystem = require("client.slua.logic.lobby_watermark.logic_lobby_watermark")
      LobbyWaterMarkSystem.SetDevCloseWatermarkSwitch(self.commonSwitch.DevCloseWatermark)
    end
    local login_timeout_set = commonSwitch.BaseinfoTimeout
    if login_timeout_set and type(login_timeout_set) == "number" then
      NET_UTIL_LOGIN_WAIT_TIME = login_timeout_set
    end
  end
  if nation_switch then
    self.    self.nation_switch.updated = true
    Client.SetNationSwitch(GameFrontendHUD, self.nation_switch.NationAllSwitch, self.nation_switch.NationBattleSwitch, self.nation_switch.NationRankSwitch)
  end
  if PublishRegionMacros.IsJapanOrKorea() then
    local iTOP_country_no = Client.GetIPRegion()
    local AccountRegionForBPMacros = require("client.slua.config.ClientMacros.AccountRegionForBPMacros")
    local same_with_gamesvr = false
    if ip_region == AccountRegionForBPMacros.JP and iTOP_country_no == 392 or ip_region == AccountRegionForBPMacros.KR and iTOP_country_no == 410 then
      same_with_gamesvr = true
    end
    local iTOPLbsDelay = Client.GetiTOPLbsDelay()
    local iTOPLbsEvent = {
      success = tostring(iTOP_country_no ~= 0),
      country_no = tostring(iTOP_country_no),
      sameWithGameServer = tostring(same_with_gamesvr),
      delay = tostring(iTOPLbsDelay)
    }
    Client.GEMReportEvent(GameFrontendHUD, "iTOPLbs", iTOPLbsEvent)
    if iTOP_country_no == 0 then
      local gamesvr_country_no = 0
      if ip_region == AccountRegionForBPMacros.JP then
        gamesvr_country_no = 392
      end
      if ip_region == AccountRegionForBPMacros.KR then
        gamesvr_country_no = 410
      end
      Client.SetIPRegion(gamesvr_country_no)
    end
  end
  self:ReportLocalResourcePakGEM()
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  ZoneSystem.SetUDPPingIntervalTime(pingSvrPars)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local PlayerStatusEnum = require("client.slua.logic.player_status.PlayerStatusEnum")
  LogicFriend.teamState = PlayerStatusEnum.Enum_TeamState.Idle
  EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_MY_ONLINE_STATE_CHANGE)
  log(bWriteLog and "LoginSystem.teamState Idle")
  local supply_collect_chest_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.supply_collect_chest_manager)
  supply_collect_chest_manager:SetShowTipTime(0)
  local serverListUI = UIManager.GetUI(UIManager.UI_Config.ServerList_UIBP)
  if serverListUI then
    UIManager.CloseUI(UIManager.UI_Config.ServerList_UIBP)
    log_shipping_client("[Login process] LoginSystem: close ServerList_UIBP on login_rsp")
  end
  self:CloudGameTlogReport(true)
end
function login_module:CloudGameTlogReport(isLogin)
  local BusinessHelper = import("BusinessHelper")
  local openid = BusinessHelper.GetOpenId()
  if openid then
    log(bWriteLog and "login_module:CloudGameTlogReport openid:" .. openid)
    if isLogin then
      local logic_cloud_game = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cloud_game)
      log(bWriteLog and "login_module:CloudGameTlogReport SendMessageToCloudGame login")
      logic_cloud_game:SendMessageToCloudGame(logic_cloud_game.ProtocolName.LoginInfo, openid)
    else
      local logic_cloud_game = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cloud_game)
      log(bWriteLog and "login_module:CloudGameTlogReport SendMessageToCloudGame logOut")
      logic_cloud_game:SendMessageToCloudGame(logic_cloud_game.ProtocolName.LogOutInfo, openid)
    end
  else
    log(bWriteLog and "login_module:CloudGameTlogReport openid = nil")
  end
end
local accountType2Num = {4201, 4202}
function login_module:SetPhoneMail(accountType)
  log_warning(bWriteLog and "  :SetPhoneMail: " .. tostring(accountType))
  if accountType and accountType2Num[accountType] then
    self.phoneMailType = accountType2Num[accountType]
  end
end
function login_module:SetJustScanLogin(flag)
  self.bJustScanLogin = flag
  log_warning(bWriteLog and "  :login_module:bJustScanLogin flag: " .. tostring(flag))
end
function login_module:SetNIpRegion(region)
  self.sIpRegion = region
  log_warning(bWriteLog and "  : login_module:SetNIpRegion: " .. tostring(region))
end
function login_module:Setno_auth_isRelogin(flag)
  self.no_auth_isRelogin = flag
  log_warning(bWriteLog and "  :login_module:Setno_auth_isRelogin flag: " .. tostring(flag))
end
function login_module:Setno_auth_username(name)
  self.no_auth_userend
function login_module:Setno_auth_password(pass)
  self.no_auth_password = pass
end
function login_module:SetOfflineServer(offlineServer)
  self.bUsingOfflineServer = offlineServer
end
function login_module:Setlink_type(link_type)
  self.nLink_type = link_type
  log_warning(bWriteLog and "  :login_module Setlink_type: " .. tostring(link_type))
end
function login_module:SetbLoginNextRsp(LoginNextRsp)
  self.bend
function login_module:SethasLogout(flag)
  self.bHasLogout = flag
end
function login_module:SetisInitLogin(flag)
  self.bIsInitLogin = flag
  self.bReLoginAccount = true
end
function login_module:SetLoginType(loginType)
  self.nLoginType = loginType
end
function login_module:SetLobbyUrl(url)
  self.loginLobbyInfo.Url = url
  log_warning(bWriteLog and "  :login_module:SetLobbyUrl url: " .. tostring(url))
end
function login_module:SetnSeverTab(tab)
  self.nSelServerTab = tab
  log_warning(bWriteLog and "  :login_module:SetnSeverTab self.nSelServerTab: " .. tostring(self.nSelServerTab))
end
function login_module:SetnSeverIdx(tab)
  self.nSelServerIdx = tab
  log_warning(bWriteLog and "  :login_module:SetnSeverIdx self.nSelServerIdx: " .. tostring(self.nSelServerIdx))
end
function login_module:SetnPufferIdx(tab)
  self.nSelPufferIdx = tab
  log_warning(bWriteLog and "  :login_module:SetnPufferIdx self.nSelPufferIdx: " .. tostring(self.nSelPufferIdx))
end
function login_module:SetReportedSkippedError(errorCode)
  log_warning(bWriteLog and "  : SetReportedSkippedError errorCode: " .. tostring(errorCode))
  self.nReportedSkippedError = errorCode
end
function login_module:SetIgnoreResourceVersion(version)
  log_warning(bWriteLog and "  :SetIgnoreResourceVersion version: " .. tostring(version))
  self.sIgnoreResourceVersion = version
end
function login_module:SetsIgnoreAppVersion(version)
  log_warning(bWriteLog and "  :SetsIgnoreAppVersion version: " .. tostring(version))
  self.sIgnoreAppVersion = version
end
local saveKeyTb = {
  LoginCount = 0,
  LoginTime = 0,
  isVNGAdult = false,
  GuestWarningAccepted = false,
  PrivacyPolicyAcceptedVersion = 0,
  UserAgreementAcceptedVersion = 0,
  PrivacyPolicyPopupVersion = 0
}
function login_module:LoadPlayerData()
  log_warning(bWriteLog and string.format("login_module:LoadPlayerData. firstIn no data"))
  self.playerData = {}
  local PlayerPrefs = import("/Game/UMG/UI_Utility/PlayerPrefs.PlayerPrefs_C")
  local saveGame = PlayerPrefs:LoadData()
  for k, value in pairs(saveKeyTb) do
    self.playerData[k] = saveGame and saveGame[k] or value
    if saveGame then
      log_warning(bWriteLog and "  login_module:LoadPlayerData. k " .. tostring(k))
      log_warning(bWriteLog and "  login_module:LoadPlayerData. saveGame[k] " .. tostring(saveGame[k]))
    end
  end
end
function login_module:SetPlayerData(key, value, dontSave)
  log_warning(bWriteLog and string.format("login_module:SavePlayerData. key=%s, value=%s", tostring(key), tostring(value)))
  if key then
    self.playerData[key] = value
  end
  if not dontSave then
    self:SaveTable()
  end
end
function login_module:SaveTable()
  local playerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  playerPrefsSystem.SaveTableToFile_N(self.playerData, playerPrefsSystem.ePlayerPrefsType.eLoginData)
end
function login_module:GetLobbyUrl()
  return self.loginLobbyInfo and self.loginLobbyInfo.Url
end
function login_module:RemoveLoginTimer()
  logic_connection_waiting:Hide(1)
  if self.loginTimer then
    self:RemoveTimer(self.loginTimer)
    self.loginTimer = nil
  end
end
local backLogin = function()
  local login = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  login:backLogin()
end
local sendLogout = function()
  local ban_login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ban_login_module)
  ban_login_module:sendLogout()
end
function login_module:LoginTimeOut()
  if GameStatus.IsInFightingNotMainCity() then
    return
  end
  local title = LocUtil.GetLocalizeResStr(101001)
  local text = LocUtil.GetLocalizeResStr(301228)
  local extraData = {
    androidCallback = function()
      return true
    end
  }
  CommonMsgBoxMgr.Show(1, title, text, backLogin, nil, nil, nil, extraData)
end
function login_module:OnDolphinVersionInfoEvent(VerData)
  self.versionInfo = VerData
  local updateUI = UIManager.GetUI(UIManager.UI_Config.version_update)
  if updateUI then
    updateUI:OnDolphinVersionInfo(VerData)
  else
    log(bWriteLog and "OnDolphinVersionInfoEvent, version_update is not showing?")
  end
end
function login_module:OnRepairOverMaxTimes()
  log(bWriteLog and "login_module.OnRepairOverMaxTimes ")
  local title = LocUtil.GetLocalizeResStr(201001)
  local content = LocUtil.GetLocalizeResStr(5049)
  local helpLabel = LocUtil.GetLocalizeResStr(4539)
  local exitLabel = LocUtil.GetLocalizeResStr(4486)
  CommonMsgBoxMgr.Show(2, title, content, GameStatus.QuitGame, function()
    self:AddTimerOnce(1, function()
      self:OnRepairOverMaxTimes()
    end)
    local LogicCustomerService = require("client.slua.logic.CustomerService.LogicCustomerService")
    LogicCustomerService.Open(LogicCustomerService.E_EntranceType.Login)
  end, exitLabel, helpLabel, extraData5s)
end
function login_module:OnRestartGame()
  log(bWriteLog and "login_module.OnRestartGame")
  local title = LocUtil.GetLocalizeResStr(201007)
  local content = LocUtil.GetLocalizeResStr(201008)
  CommonMsgBoxMgr.Show(1, title, content, function()
    Client.StopPuffer(GameFrontendHUD)
    local IntlHelper = import("IntlHelper")
    if IntlHelper.IsAwakedByAdjust() then
      local validDeepLink = IntlHelper.GetDeepLinkUrl()
      if validDeepLink ~= "" then
        local playerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
        log(bWriteLog and "login_module:OnRestartGame, SaveTableToFile validDeepLink = " .. tostring(validDeepLink))
        playerPrefsSystem.SaveTableToFile_N({
          url = validDeepLink,
          time = TimeUtil.OSTime()
        }, playerPrefsSystem.ePlayerPrefsType.eRestartGameAdjust)
      end
    end
    Client.RestartGame()
  end, nil, nil, nil, extraData5s)
end
function login_module:OnInitIMSDKEnv()
  log(bWriteLog and "login_module.OnInitIMSDKEnv")
  local ComplianceHelper = import("IntlSDKComplianceHelper")
  local ComplianceHelperInstance = ComplianceHelper.GetInstance()
  if (globalConfig.IsDirectConnect() == false or Client.IsShipping() == false) and Client.IsCEVersion() == false then
    log_warning(bWriteLog and "  login_module:OnInitIMSDKEnv msdkEnvRecord")
    local playerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local msdkEnvRecord = playerPrefsSystem.LoadFileToTable_N(playerPrefsSystem.ePlayerPrefsType.eiMSDKEnv) or {}
    local imsdkEnv = 0
    if msdkEnvRecord and msdkEnvRecord.imsdkEnv then
      imsdkEnv = msdkEnvRecord.imsdkEnv
    end
    log_warning(bWriteLog and "  login_module:OnInitIMSDKEnv imsdkEnv:" .. tostring(imsdkEnv))
    Client.InitIMSDKEnv(NetInterface, imsdkEnv)
    ComplianceHelperInstance:OnMSDKEvnSwitched(imsdkEnv)
  else
    Client.InitIMSDKEnv(NetInterface, 1)
    ComplianceHelperInstance:OnMSDKEvnSwitched(1)
  end
end
function login_module:OnGetEnableCDNGetVersion(enable)
  log(bWriteLog and "login_module.OnGetEnableCDNGetVersion" .. tostring(enable))
  self.beEnableCDNGetVersion = enable
end
function login_module:OnAfterLoadedEditorLogin()
  log(bWriteLog and "login_module.OnAfterLoadedEditorLogin")
  local KismetSystemLibrary = import("KismetSystemLibrary")
  KismetSystemLibrary.ControlScreensaver(false)
end
function login_module:InitAfterSwitchedGameStatus()
  if not self.nLastIsScan then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    self.nLastIsScan = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eLastLoginChannel)
    log_warning(bWriteLog and "  login_module:InitAfterSwitchedGameStatus. self.nLastIsScan: " .. tostring(self.nLastIsScan))
  end
  if self.recommendStatus == nil or self.recommendStatus == self.RecommendStatus.NotStarted then
    self:RequestRecommendLoginChannels()
  end
  if not IsEditor and not self.bPlayedSplash then
    self.bPlayedSplash = true
    self:OnInitState(ELoginFsmState.State_SplashScreen)
  else
    self:OnInitState(ELoginFsmState.State_VersionUpdate)
  end
end
function login_module:OnClearUIBeforeReInitLuaState()
  log(bWriteLog and "login_module.ClearUIBeforeReInitLuaState")
  UIManager.ClearAll()
end
local loginState2Const = {
  [ELoginFsmState.State_SplashScreen] = "SPLASH",
  [ELoginFsmState.State_VersionUpdate] = "UPDATE",
  [ELoginFsmState.State_Login] = "LOGIN",
  [ELoginFsmState.State_ChooseServer] = "CHOOSE_SERVER"
}
local UI_Config = UIManager.UI_Config
local allUICfg = {
  UI_Config.splash_screen,
  UI_Config.version_update,
  UI_Config.Login_UIBP,
  UI_Config.ServerList_UIBP,
  UI_Config.login_phone_mail,
  UI_Config.LoginFormMail_UIBP,
  UI_Config.LoginFormPhone_UIBP,
  UI_Config.LoginResetPass_UIBP
}
local loginState2ShowUI = {
  [ELoginFsmState.State_SplashScreen] = UI_Config.splash_screen,
  [ELoginFsmState.State_VersionUpdate] = UI_Config.version_update,
  [ELoginFsmState.State_Login] = UI_Config.Login_UIBP,
  [ELoginFsmState.State_ChooseServer] = UI_Config.ServerList_UIBP
}
local loginState2bShowBack = {
  [ELoginFsmState.State_VersionUpdate] = "VERSION_UPDATE",
  [ELoginFsmState.State_Login] = "LOGIN"
}
function login_module:IsDevLoginEnabled()
  local UScriptGameplayStatics = import("ScriptGameplayStatics")
  if UScriptGameplayStatics.IsOfflineBuild and UScriptGameplayStatics.IsOfflineBuild() then
    return false
  end
  return true
end
function login_module:OnInitState(state)
  log(bWriteLog and "login_module:OnInitState" .. tostring(state))
  self.nLoginFsmState = state
  if Client.IsDevelopment() and not self:IsDevLoginEnabled() then
    log(bWriteLog and "[yintaoxu]: login_module:OnInitState Login Banned")
    return
  end
  if Client.IsDevelopment() and type(RequireBlackList) == "function" then
    local LuaAPITimeTracer = RequireBlackList("blacklist.editor.runtime_check.LuaAPITimeTracer")
    if LuaAPITimeTracer then
      log(bWriteLog and "UpdateAndLoginFSM.InitState StartTracer")
      LuaAPITimeTracer.StartTracer()
    end
  end
  local mackConst = state and loginState2Const[state] or "SPLASH"
  local needShowUI = state and loginState2ShowUI[state] or UI_Config.splash_screen
  log_warning(bWriteLog and "  : login_module:OnInitState mackConst: " .. tostring(mackConst))
  log_warning(bWriteLog and "  : login_module:OnInitState needShowUI: " .. tostring(needShowUI))
  local logic_cost_collector = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cost_collector)
  logic_cost_collector:MarkEventStart(logic_cost_collector.EVENT_KEYS[mackConst])
  local begintime = slua.getMiliseconds()
  for _, cfg in ipairs(allUICfg) do
    UIManager.CloseUI(cfg)
  end
  local param = state and loginState2bShowBack[state]
  self:ShowOrHideBackground(param)
  UIManager.ShowUI(needShowUI)
  local endtime = slua.getMiliseconds()
  log_shipping_client("login_module:OnInitState.InitState " .. string.format("%s   ", mackConst) .. tostring(endtime - begintime))
end
local Event2StartConst = {
  [ELoginFSMEvent.Event_SSTVU] = "SPLASH",
  [ELoginFSMEvent.Event_VUTL] = "UPDATE",
  [ELoginFSMEvent.Event_SSTL] = "SPLASH",
  [ELoginFSMEvent.Event_LTCS] = "LOGIN",
  [ELoginFSMEvent.Event_CSTL] = "CHOOSE_SERVER"
}
local Event2EndConst = {
  [ELoginFSMEvent.Event_SSTVU] = "UPDATE",
  [ELoginFSMEvent.Event_VUTL] = "LOGIN",
  [ELoginFSMEvent.Event_SSTL] = "LOGIN",
  [ELoginFSMEvent.Event_LTCS] = "CHOOSE_SERVER",
  [ELoginFSMEvent.Event_CSTL] = "LOGIN"
}
local Event2State = {
  [ELoginFSMEvent.Event_SSTVU] = ELoginFsmState.State_VersionUpdate,
  [ELoginFSMEvent.Event_VUTL] = ELoginFsmState.State_Login,
  [ELoginFSMEvent.Event_SSTL] = ELoginFsmState.State_Login,
  [ELoginFSMEvent.Event_LTCS] = ELoginFsmState.State_ChooseServer,
  [ELoginFSMEvent.Event_CSTL] = ELoginFsmState.State_Login
}
function login_module:Transition(event)
  log_shipping_client("login_module:Transition, event = " .. tostring(event))
  local   local logic_cost_collector = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cost_collector)
  local startConst = event and Event2StartConst[event] or "SPLASH"
  local endConst = event and Event2EndConst[event] or "LOGIN"
  logic_cost_collector:MarkTransition(logic_cost_collector.EVENT_KEYS[startConst], logic_cost_collector.EVENT_KEYS[endConst])
  local begintime = slua.getMiliseconds()
  self.nLoginFsmState = Event2State[event]
  log(bWriteLog and "login_module:Transition, set currentState = " .. tostring(self.nLoginFsmState))
  for _, cfg in ipairs(allUICfg) do
    if UIManager.IsUIShow(cfg) then
      UIManager.CloseUI(cfg)
    end
  end
  local param = loginState2bShowBack[self.nLoginFsmState]
  self:ShowOrHideBackground(param)
  local needShowUI = loginState2ShowUI[self.nLoginFsmState] or UI_Config.splash_screen
  UIManager.ShowUI(needShowUI)
  local endtime = slua.getMiliseconds()
  log_shipping_client("login_module:Transition UseTime" .. string.format("%s   ", event) .. tostring(endtime - begintime))
end
function login_module:ShowOrHideBackground(param)
  local utility = require("common.utility")
  local logic_login_background = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_login_background)
  log_warning(bWriteLog and "  :login_module  param: " .. tostring(param))
  if param then
    xpcall(logic_login_background.ShowBackground, utility.ErrorMessageHandler, logic_login_background, logic_login_background.ENUM_PHASE[param])
  else
    xpcall(logic_login_background.CloseBackground, utility.ErrorMessageHandler, logic_login_background)
  end
end
function login_module:OnStartPufferUpdate()
  log(bWriteLog and "login_module.OnStartPufferUpdate")
  local updateUI = UIManager.GetUI(UIManager.UI_Config.version_update)
  if updateUI and updateUI.gray then
    Client.FinishPufferUpdateInDolphin(GameFrontendHUD)
    return
  end
  log(bWriteLog and "PufferUpdater.CheckUasability")
  PufferUpdater.PreCheckBaseUsability()
  local needDownload = false
  if Client.IsJaguar() then
    local pufferlistjson = PufferDownloader.ReadPufferFileListJson()
    if pufferlistjson and next(pufferlistjson) == nil then
      local jsonPufferID = pufferlistjson.pufferid
      if jsonPufferID then
        local StringUtil = require("common.string_util")
        local savedProductID = StringUtil.Split(jsonPufferID, ",")
        local curProductID = GCPufferDownloader.GetProductID(Puffer)
        log(bWriteLog and string.format("PufferUpdater.StartPufferUpdate savedProductID:%s curProductID:%s", tostring(savedProductID[2]), tostring(curProductID[1])))
        if tonumber(savedProductID[2]) > 0 and tostring(savedProductID[2]) ~= tostring(curProductID[1]) then
          needDownload = true
        end
      end
    end
  end
  log(bWriteLog and "PufferUpdater.Check End")
  PufferUpdater.CheckCorrupted()
  if Client.HasDownloadedBasePak() and not needDownload then
    log(bWriteLog and "PufferUpdater.HasDownloaded all SkipPufferDownload")
    Client.FinishPufferUpdateInDolphin(GameFrontendHUD)
    return
  end
  local PufferInitFunc = function(ret)
    table.insert(PufferInterface.InitCallbackFuncList, PufferUpdater.DownloadFileList)
    table.insert(PufferInterface.InitProgressCallbackFuncList, PufferUpdater.UpdateUIOnInitProgress)
    log(bWriteLog and "PufferUpdater.Init start")
    local version_up_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.version_up_module)
    version_up_module:InitializePuffer(false)
  end
  local LogicTouchTransmission = require("client.slua.logic.touch_transmission.logic_touch_transmission")
  LogicTouchTransmission:HandleReceivedPakFiles(PufferInitFunc)
end
function login_module:OnGetRegionNoByCountryNo(country)
  log(bWriteLog and "login_module.GetRegionNoByCountryNo, country = " .. country)
  local data = CDataTable.GetTableData("RegionNo", country)
  if data then
    log(bWriteLog and "LoginSystem.GetRegionNoByCountryNo, region = " .. tostring(data.region))
    Client.SetRegionNoByLua(NetInterface, data.region)
  else
    log(bWriteLog and "LoginSystem.GetRegionNoByCountryNo, not found country")
    Client.SetRegionNoByLua(NetInterface, 0)
  end
end
function login_module:OnQuickLoginEvent(wrapper)
  log_warning(bWriteLog and "  : OnQuickLoginEvent: ")
  log_tree("wrapper", wrapper)
  local wakeupinfo = wrapper.FWakeupInfoMap
  self:OnQuickLogin(wakeupinfo)
end
function login_module:OnQuickLogin(wakeupinfo)
  if wakeupinfo.roominfo then
    log(bWriteLog and "QRCode OnQuickLogin")
    local roominfo = wakeupinfo.roominfo
    local roompwpos = string.find(roominfo, "rmpw")
    local roomttpos = string.find(roominfo, "t:")
    if RoomSystem.QRCodeRoomInfo == nil then
      RoomSystem.QRCodeRoomInfo = {}
    end
    RoomSystem.QRCodeRoomInfo.game_roomid = string.sub(roominfo, 6, roompwpos - 2)
    if roomttpos == nil then
      RoomSystem.QRCodeRoomInfo.game_roompw = string.sub(roominfo, roompwpos + 5, -1)
      RoomSystem.QRCodeRoomInfo.game_roomtime = 0
    else
      RoomSystem.QRCodeRoomInfo.game_roompw = string.sub(roominfo, roompwpos + 5, roomttpos - 2)
      RoomSystem.QRCodeRoomInfo.game_roomtime = string.sub(roominfo, roomttpos + 2, -1)
    end
    local nNow = math.floor(TimeUtil.OSTime() / 60)
    local QRCodeTime = tonumber(RoomSystem.QRCodeRoomInfo.game_roomtime)
    if nNow > QRCodeTime + 360 then
      log(bWriteLog and "QRCode Expired")
      RoomSystem.QRCodeRoomInfo = nil
      ShowNotice(110131)
      return
    end
    ClientSendBAReport(TLogEventDefine.ShareRoomQRCode, 0)
    if wakeupinfo.roominfoImm ~= nil and wakeupinfo.roominfoImm == "true" then
      RoomSystem.OnQuickJoinRoom(RoomSystem.QRCodeRoomInfo)
    end
    return
  end
  local state = math.floor(tonumber(wakeupinfo.Base_State))
  log(bWriteLog and "state" .. tostring(state))
  local _platform = math.floor(tonumber(wakeupinfo.Base_Platform))
  log(bWriteLog and "platform" .. tostring(_platform))
  local device_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.device_module)
  device_module:SetWakeupInfo(wakeupinfo)
  device_module:CheckWakeupInfo(wakeupinfo)
  if state == 2 then
    local toLoginPlatform = ""
    if _platform == BP_ENUM_PLAYFORM_WX then
      toLoginPlatform = LocUtil.GetLocalizeResStr(101012)
    elseif _platform == BP_ENUM_PLAYFORM_BGBG then
      toLoginPlatform = LocUtil.GetLocalizeResStr(301288)
    end
    if BP_Platform == BP_ENUM_PLAYFORM_WX then
    elseif BP_Platform == BP_ENUM_PLAYFORM_BGBG then
    end
    local tip = string.format(LocUtil.GetLocalizeResStr(301138), toLoginPlatform)
    CommonMsgBoxMgr.Show(2, LocUtil.GetLocalizeResStr(301137), tip, function()
      Client.SwitchUser(NetInterface, true)
      self:sendLogout(1)
    end, nil, nil, nil, extraData5s)
  end
end
function login_module:OnPhoneMailLoginCallbackDelegate(type, retCode, extraJson)
  log(bWriteLog and "LoginSystem.OnPhoneMailLoginCallback" .. tostring(type) .. ", " .. tostring(retCode) .. ", " .. extraJson)
  local resultDic = json.decode(extraJson)
  local code = resultDic and resultDic.thirdRetCode
  if type == ENUM_Type.RequestVerifyCode then
    EventSystem:postEvent(EVENTTYPE_LOGIN, EVENTID_LOGIN_GET_CODE_RES, retCode, code, resultDic)
  end
  local SDKMacros = require("client.slua.config.ClientMacros.SDKMacros")
  if retCode == SDKMacros.IMSDKErrorCode.SUCCESS then
    if type ~= ENUM_Type.CheckIsRegisted then
      ShowNotice(8179)
    end
    if type == ENUM_Type.ChangePassword then
      EventSystem:postEvent(EVENTTYPE_LOGIN, EVENTID_PHONE_MAIL_RESET_SUCCESS)
    elseif type == ENUM_Type.CheckIsRegisted and resultDic.isRegister ~= nil then
      EventSystem:postEvent(EVENTTYPE_LOGIN, EVENTID_LOGIN_GET_REGIST_INFO, resultDic.isRegister == 1)
    elseif type == ENUM_Type.ModifyAccount then
      local Handler = require("client.network.Protocol.PhoneMailLoginHandler")
      Handler.request_self_build_account()
      EventSystem:postEvent(EVENTTYPE_LOGIN, EVENTID_LOGIN_BIND_SUCCESS)
      log(bWriteLog and "  : resultDic.accountType" .. tostring(resultDic.accountType))
      local _code = tonumber(resultDic.accountType)
      local LogicLoginVerify = require("client.slua.logic.login.logic_login_verify")
      if _code == 1 or _code == 2 then
        local LoginVerifyHandler = require("client.network.Protocol.LoginVerifyHandler")
        LoginVerifyHandler.send_report_account_bind_log(_code - 1)
      else
        LogicLoginVerify.PostTLog()
      end
    end
  elseif retCode == SDKMacros.IMSDKErrorCode.BIND_CMD_NEED_PROCESS_BY_SVR then
    if type == ENUM_Type.ModifyAccount then
      local ret = resultDic.imsdkRetMsg
      local base64 = require("client.slua.logic.lobby_watermark.base64")
      local LoginVerifyHandler = require("client.network.Protocol.LoginVerifyHandler")
      local clientBase64Str = string.gsub(ret, "-", "+")
      clientBase64Str = string.gsub(clientBase64Str, "_", "/")
      local afterDecode = base64.DecodeBase64(clientBase64Str)
      log_tree(bWriteLog and "login_module:OnPhoneMailLoginCallbackDelegate imsdkRetMsgTable", afterDecode)
      local imsdkRetMsgTable = json.decode(afterDecode)
      if imsdkRetMsgTable.sacc_params ~= nil then
        local logic_account_sensitive_aciton = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_account_sensitive_aciton)
        if logic_account_sensitive_aciton:IsGrayNew() then
          logic_account_sensitive_aciton:ExtraBindSelfBuildReq(ret, imsdkRetMsgTable.sacc_params)
        else
          LoginVerifyHandler.send_account_modify_sacc_req(ret, imsdkRetMsgTable.sacc_params.account_modify, imsdkRetMsgTable.sacc_params.account_type_modify, imsdkRetMsgTable.sacc_params.verify_code_modify, imsdkRetMsgTable.sacc_params.area_code_modify)
        end
      end
    end
  else
    if type == ENUM_Type.ChangePassword then
      EventSystem:postEvent(EVENTTYPE_LOGIN, EVENTID_PHONE_MAIL_RESET_FAIL, retCode, code)
    end
    local error_id = retCode
    if retCode == 5 or retCode == 9999 then
      error_id = code
    end
    local tb = CDataTable.GetTable("AccountErrorCfg")
    local resId = 0
    local errorType = 1
    for _, data in pairs(tb) do
      if data.itopId == error_id then
        resId = data.resId
        errorType = data.errorType
      end
    end
    local errorCode = resId
    if resId == 0 then
      if type == ENUM_Type.ModifyAccount and retCode == 10 and code == -1 then
        errorCode = 16194
      else
        local ParameterErrorTips = LocUtil.LocalizeResFormat(540001, string.format("(%s, %s)", tostring(retCode), tostring(code)))
        if retCode == 2 then
          ParameterErrorTips = LocUtil.GetLocalizeResStr(119600036)
        end
        errorCode = ParameterErrorTips
      end
    end
    if type == ENUM_Type.ModifyAccount then
      EventSystem:postEvent(EVENTTYPE_LOGIN, EVENTID_ERRORCODE_PHONE_MAIL, errorCode, errorType, retCode, resultDic)
    else
      EventSystem:postEvent(EVENTTYPE_LOGIN, EVENTID_ERRORCODE_PHONE_MAIL, errorCode, errorType, retCode)
    end
  end
end
function login_module:OnLoginSDKCallbackDelegate(type, _, _)
  if type == 1 then
    GlobalData.StopLobbyBGM()
  elseif type == 2 then
    GlobalData.RestoreLobbyBGM()
  end
end
function login_module:LoadLoginTypeTable()
  local table = CDataTable.GetTable("LoginTypeListCfg")
  local default
  local language = Client.GetCurrentLanguage()
  local logic_cloud_game = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cloud_game)
  local bCloudVersion = logic_cloud_game:IsCloudVersion()
  log_warning(bWriteLog and "  login_module:LoadLoginTypeTable. language " .. tostring(language) .. " IsCloudVersion: " .. tostring(bCloudVersion))
  local FacadeRegion = strRegion
  if bCloudVersion then
    local buildVersion = global_package_make_time_map.SODA_AutoBuild
    if Client.IsDevelopment() or buildVersion == "Pre" then
      FacadeRegion = "CLOUD_PRE"
    else
      FacadeRegion = "CLOUD"
    end
  end
  for _, v in pairs(table) do
    if v.ID == FacadeRegion then
      if v.language == language then
        return v
      elseif v.language == "default" then
        default = v
      end
    end
  end
  return default
end
function login_module:GetLoginTypeTable()
  if not self.LoginTypeTable then
    self.LoginTypeTable = self:LoadLoginTypeTable()
  end
  return self.LoginTypeTable
end
local local channel2Enum = {
  facebook = ShareSource.Facebook,
  twitter = ShareSource.Twitter,
  noschat = ShareSource.Noschat,
  googleplay = ShareSource.GooglePlay,
  gamecenter = ShareSource.GameCenter,
  apple = ShareSource.Apple,
  line = ShareSource.Line,
  bgbg = ShareSource.BgBg,
  hms = ShareSource.Hms,
  scan = ShareSource.Scan,
  discord = ShareSource.Discord,
  vk = ShareSource.VK,
  guest = ShareSource.Guest,
  whatsapp = ShareSource.Whatsapp,
  tiktok = ShareSource.TikTok
}
local AndroidUseAppleReginTb = {
  [PublishRegionMacros.GLOBAL] = 1,
  [PublishRegionMacros.VNG] = 1,
  [PublishRegionMacros.TW] = 1,
  [PublishRegionMacros.BLUEHOLE] = 1,
  [PublishRegionMacros.JAPAN] = 1,
  [PublishRegionMacros.KOREA] = 1,
  [PublishRegionMacros.FIT] = 1
}
login_module.RecommendStatus = {
  NotStarted = 0,
  Pending = 1,
  Succeed = 2,
  Failed = 3
}
local _NormalizeRecommendChannel = function(ch)
  if not ch or ch == "" then
    return ch
  end
  if ch == ShareSource.Google then
    return ShareSource.GooglePlay
  end
  return ch
end
function login_module:RequestRecommendLoginChannels(callback)
  log(bWriteLog and "login_module:RequestRecommendLoginChannels - begin")
  if self.recommendStatus == self.RecommendStatus.Pending then
    log(bWriteLog and "login_module:RequestRecommendLoginChannels - already pending, skip")
    return
  end
  self.recommendStatus = self.RecommendStatus.Pending
  self.recommendChannels = nil
  self.recommendLastRaw = nil
  local MOCK_RECOMMEND_CHANNELS = {
    "facebook",
    "google",
    "discord"
  }
  local MOCK_DELAY_SECONDS = 1
  log_warning(bWriteLog and string.format("[MOCK] login_module:RequestRecommendLoginChannels - scheduled mock reply in %ds, channels=%s", MOCK_DELAY_SECONDS, table.concat(MOCK_RECOMMEND_CHANNELS, ",")))
end
function login_module:_OnRecommendReply(rawReply)
  self.recommendLastRaw = rawReply
  local channels = {}
  local rawList = rawReply and rawReply.channels
  if type(rawList) == "table" then
    for _, ch in ipairs(rawList) do
      local norm = _NormalizeRecommendChannel(ch)
      if norm and norm ~= "" then
        channels[#channels + 1] = norm
      end
    end
  end
  self.recommendChannels = channels
  self.recommendStatus = self.RecommendStatus.Succeed
  log_tree("login_module:_OnRecommendReply channels", channels)
  self:_NotifyRecommendUpdated()
end
function login_module:_OnRecommendFailed(reason)
  log_warning(bWriteLog and "login_module:_OnRecommendFailed reason: " .. tostring(reason))
  self.recommendStatus = self.RecommendStatus.Failed
  self.recommendChannels = nil
  self:_NotifyRecommendUpdated()
end
function login_module:_NotifyRecommendUpdated()
  local loginUI = UIManager.GetUI(UIManager.UI_Config.Login_UIBP)
  if loginUI and loginUI.UpdateLoginButtons then
    log(bWriteLog and "login_module:_NotifyRecommendUpdated - refresh Login_UIBP buttons")
    loginUI:UpdateLoginButtons()
  end
end
function login_module:GetRecommendLoginChannels()
  local status = self.recommendStatus or self.RecommendStatus.NotStarted
  return status, self.recommendChannels
end
function login_module:IsRecommendReady()
  return self.recommendStatus == self.RecommendStatus.Succeed or self.recommendStatus == self.RecommendStatus.Failed
end
function login_module:GetLoginTypeList()
  if self.LoginTypeList and (not PublishRegionMacros.IsBLUEHOLE() or not GlobalData.IsIOSCheck()) then
    return self.LoginTypeList
  end
  local arrLoginType = {}
  local cfg = self:GetLoginTypeTable()
  local   local isValid = function(v)
    local num = tonumber(v)
    if num and num ~= 0 then
      return num
    end
  end
  local channel_util = require("client.logic.setting.bind.channel_util")
  if cfg then
    for n, enum in pairs(channel2Enum) do
      n = isValid(cfg[n])
      if n then
        arrLoginType[n] = enum
      end
    end
    for k, channel in pairs(arrLoginType) do
      if not channel_util.CanShowLogin(channel) then
        arrLoginType[k] = nil
      end
    end
  end
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if not PublishRegionMacros.IsCEVersion() then
    if DevicePlatformNameMacros.IOS == Client.GetDevicePlatformName() or Client.IsIOSVersionAbove13() then
      table.insert(arrLoginType, ShareSource.Apple)
    elseif AndroidUseAppleReginTb[strRegion] and not IsWoWEditor then
      table.insert(arrLoginType, ShareSource.Apple)
    end
  end
  self.LoginTypeList = arrLoginType
  log_tree("  login_module:GetLoginTypeList. arrLoginType ", arrLoginType)
  return arrLoginType
end
function login_module:OnLanguageChanged()
  log_warning(bWriteLog and string.format("login_module:OnLanguageChanged. "))
  self.LoginTypeList = nil
  self.LoginTypeTable = nil
  local loginUI = UIManager.GetUI(UIManager.UI_Config.Login_UIBP)
  if loginUI ~= nil then
    loginUI:RefreshUI()
  end
end
function login_module:DelayInitThirdPartSDK()
  local DefaultValue = 1
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if PublishRegionMacros.IsBLUEHOLE() and Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS then
    DefaultValue = 0
  end
  local IGShareUseCrossPlatformBackend = HDmpveRemote.HDmpveRemoteConfigGetInt("IGShareUseCrossPlatformBackend", DefaultValue)
  log_warning(bWriteLog and string.format("login_module:DelayInitThirdPartSDK. IGShareUseCrossPlatformBackend=%d", IGShareUseCrossPlatformBackend))
  FuncUtil.UE4ExecuteConsoleCommand("IGShare.UseCrossPlatformBackend " .. IGShareUseCrossPlatformBackend)
  local loginTypes = self:GetLoginTypeList()
  for _, channel in pairs(loginTypes) do
    if channel == ShareSource.Discord then
      log(bWriteLog and "Discord enable: ")
      Client.DelayInitThirdPartSDK()
      break
    end
  end
  local device_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.device_module)
  device_module:CheckIfCanUseGyrSensor()
  if strRegion ~= PublishRegionMacros.BLUEHOLE then
    if Client and Client.LoadSideLoadSOFromOBB then
      Client.LoadSideLoadSOFromOBB()
    end
    local DeviceOSInfo = require("client.logic.data.data_device_os")
    local xid = DeviceOSInfo.GetXID()
    local IMSDKHelper = import("IMSDKHelper")
    local IMSDKHelperInstance = IMSDKHelper.GetInstance()
    local xid_after_check = ""
    if #xid == 64 then
      xid_after_check = xid
    end
    IMSDKHelperInstance:SetUgId(xid_after_check)
    IMSDKHelperInstance:SetGameDeviceId(Client.GetPhoneDeviceID())
    if (strRegion == PublishRegionMacros.CE or Client.IsReleaseVersion(NetInterface) ~= true) and (login_module.HasReportXID == nil or login_module.HasReportXID == false) then
      local ParamTable = {}
      table.insert(ParamTable, "1")
      table.insert(ParamTable, IMSDKHelperInstance:getOpenID())
      table.insert(ParamTable, strRegion)
      table.insert(ParamTable, device_module.sDeviceName)
      table.insert(ParamTable, xid)
      Client.GEMReportSubEvent(GameFrontendHUD, "GRomeLinkEvent", "CollectEvent", ParamTable)
      login_module.HasReportXID = true
    end
  end
end
local canShowChannelTb = {
  facebook = 1,
  twitter = 1,
  gamecenter = 1,
  googleplay = 1,
  line = 1,
  discord = 1,
  apple = 1
}
if IsWoWEditor then
  canShowChannelTb = {scan = 1}
end
function login_module:IsAvailableChannel(channel)
  local result = false
  result = canShowChannelTb[channel]
  if result then
    return true
  elseif channel == ShareSource.Noschat then
    if slua_GameFrontendHUD then
      result = slua_GameFrontendHUD:IsInstallPlatform(ShareSource.Noschat)
    end
  elseif channel == ShareSource.VK then
    if slua_GameFrontendHUD then
      result = slua_GameFrontendHUD:IsInstallPlatform(ShareSource.VK)
    end
  elseif channel == ShareSource.Guest then
    result = not GlobalData.IsJapanOrKorea()
  elseif channel == ShareSource.BgBg then
    if GlobalData.IsJapanOrKorea() then
      result = false
    elseif IsHideBgBgGuest() then
      result = false
    elseif slua_GameFrontendHUD then
      result = slua_GameFrontendHUD:IsInstallPlatform(ShareSource.BgBg)
    end
  elseif channel == ShareSource.Hms then
    local BusinessHelper = import("BusinessHelper")
    if BusinessHelper ~= nil then
      result = BusinessHelper.GetAOSSHOPID() == 6
    end
  elseif channel == ShareSource.TikTok then
    if slua_GameFrontendHUD then
      result = slua_GameFrontendHUD:IsInstallPlatform(ShareSource.TikTok)
    end
  elseif channel == ShareSource.Whatsapp then
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    local IsBLUEHOLE = PublishRegionMacros.IsBLUEHOLE()
    if IsBLUEHOLE and slua_GameFrontendHUD then
      local bDisable = Client.HDmpveRemoteConfigGetInt("OpenBlueHoleWhatsApp", 0) == 1
      log_format("Login_UIBP:IsAvailableChannel. bDisable: %s", bDisable)
      if bDisable then
        result = slua_GameFrontendHUD:IsInstallPlatform(ShareSource.Whatsapp)
      end
    end
  end
  log_warning(bWriteLog and "Login_UIBP:IsAvailableChannel, channel = " .. tostring(channel) .. ", result = " .. tostring(result))
  return result
end
local showMailTb = {GLOBAL = 1, FIT = 1}
function login_module:CanShowPhoneMailLogin()
  if IsWoWEditor then
    return false
  end
  local logic_cloud_game = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cloud_game)
  if logic_cloud_game:IsCloudVersion() then
    return false
  end
  local showButton = false
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local save_table = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eMailPhoneLogin)
  if save_table and save_table.show_login_btn then
    showButton = save_table.show_login_btn
  else
    showButton = true
  end
  if showButton then
    if showMailTb[strRegion] then
      return true
    else
      return false
    end
  else
    return false
  end
end
function login_module:GetIpRegion()
  local countryID = Client.GetIPRegion()
  if countryID ~= nil then
    local country = CDataTable.GetTableData("IPCountry", countryID)
    if country then
      log(bWriteLog and "LoginSystem.GetCurrentRegionNumber, region = " .. tostring(country.regionCountry))
      return tostring(country.regionCountry)
    end
    return ""
  end
  return ""
end
function login_module:DelaybanLoginCancelCallback()
  local language = Client.GetCurrentLanguage()
  if self.nAppeal_switch and self.nAppeal_switch == 1 then
    local webModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.webModule)
    local url = FuncUtil.GetDomainByID(3366181)
    url = webModule:AddPersonalInfoPropertyAndPlaceholder(url, webModule.h5Parameter.sTicket, webModule.h5Parameter.itop_ticket)
    url = webModule:AddPersonalInfoPropertyAndPlaceholder(url, FuncUtil.GetKeywordByID(3377009) .. "Id", webModule.h5Parameter.gameid)
    url = webModule:AddPersonalInfoPropertyAndPlaceholder(url, webModule.h5Parameter.language, webModule.h5Parameter.language)
    url = webModule:AddPersonalInfoPropertyAndPlaceholder(url, webModule.h5Parameter.timeZone, webModule.h5Parameter.timeZone)
    url = webModule:AddPersonalInfoPropertyAndPlaceholder(url, webModule.h5Parameter.loginType, webModule.h5Parameter.loginType)
    log(bWriteLog and "DelaybanLoginCancelCallback url1 = " .. tostring(url))
    url = url .. "&platId=" .. string.lower(platform)
    url = url .. "&channel=" .. BanChannelDefine.BanLogin
    local country = self.sBancountry or self:GetIpRegion()
    local nickName = self.sBanNickname or DataMgr.roleData.nickName
    nickName = webModule:URLEncode(tostring(nickName))
    url = webModule:AddPersonalInfoPropertyAndValue(url, webModule.h5Parameter.country, country)
    url = webModule:AddPersonalInfoPropertyAndValue(url, webModule.h5Parameter.rolename, nickName)
    url = webModule:AddParameterByPersonalInfo(url, false, true)
    local Logic_Offline_Invite = require("client.slua.logic.teamup.logic_offline_invite")
    local token = Logic_Offline_Invite.GetTokenByOperate()
    url = webModule:AddPersonalInfoPropertyAndValue(url, webModule.h5Parameter.token, token)
    log(bWriteLog and "DelaybanLoginCancelCallback url3 = (new)" .. tostring(url))
    GlobalData.JumpUrl(url)
    return
  end
  if strRegion == PublishRegionMacros.BLUEHOLE then
    ShowNotice(31001)
    local time_ticker = require("common.time_ticker")
    time_ticker.AddTimerOnce(2, function()
      local LogicCustomerService = require("client.slua.logic.CustomerService.LogicCustomerService")
      LogicCustomerService.HelpshiftShowConversionWithInfo()
    end)
    return
  end
  if strRegion == PublishRegionMacros.GLOBAL or strRegion == PublishRegionMacros.FIT then
    log(bWriteLog and "DelaybanLoginCancelCallback language = " .. language)
    local baseUrl = ""
    local BusinessHelper = import("BusinessHelper")
    if BusinessHelper.GetIMSDKEnv() == 1 then
      baseUrl = FuncUtil.GetDomainByID(3366048) .. "/"
    else
      baseUrl = FuncUtil.GetDomainByID(3366049) .. "/"
    end
    local ticket = Client.GetWebViewTicket(NetInterface)
    local loginType = self.nLoginType
    local IntlHelper = import("IntlHelper")
    local timezone = IntlHelper.GetLocalTimezone()
    local openid = BusinessHelper.GetOpenId()
    local country = self:GetIpRegion()
    local roleJson = DataMgr.GetLocalSegmentInfo()
    local solo = roleJson.solo or ""
    local double = roleJson.double or ""
    local team = roleJson.team or ""
    local fpp_solo = roleJson.fpp_solo or ""
    local fpp_double = roleJson.fpp_double or ""
    local fpp_team = roleJson.fpp_team or ""
    local device_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.device_module)
    local equipment = device_module:GetCurEquipment()
    local finalUrl = baseUrl .. "xiaoyue.abroad.logic/Redirect?gameId=80001&source=h5_block&sTicket=" .. ticket .. "&loginType=" .. loginType .. "&openid=" .. openid .. "&language=" .. language .. "&timeZone=" .. timezone .. "&country=" .. country .. "&soloSegment=" .. solo .. "&doubleSegment=" .. double .. "&teamSegment=" .. team .. "&fppsoloSegment=" .. fpp_solo .. "&fppdoubleSegment=" .. fpp_double .. "&fppteamSegment=" .. fpp_team .. "&equipment=" .. equipment
    log(bWriteLog and "DelaybanLoginCancelCallback finalUrl = " .. finalUrl)
    local WebviewSDK = require("client.slua.logic.url.logic_webview_sdk")
    WebviewSDK:OpenURL(finalUrl)
    local webModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.webModule)
    webModule:SetneedLogoutOnCloseWeb(true)
  elseif strRegion == PublishRegionMacros.BLUEHOLE then
    local WebviewSDK = require("client.slua.logic.url.logic_webview_sdk")
    WebviewSDK:OpenURL(FuncUtil.GetDomainByID(3366050) .. "/a/support/")
  else
    local LogicCustomerService = require("client.slua.logic.CustomerService.LogicCustomerService")
    LogicCustomerService.HelpshiftShowFAQsWithInfo()
    return
  end
end
function login_module:ReportLocalResourcePakGEM()
  local ApplicationVersionVersion = Client.GetApplicationVersion()
  local fileNameIndexMap = {
    ["map_savagemain_" .. ApplicationVersionVersion .. ".pak"] = 1,
    ["map_desert_" .. ApplicationVersionVersion .. ".pak"] = 2,
    ["map_dihorotok_" .. ApplicationVersionVersion .. ".pak"] = 3,
    ["map_hpcity_" .. ApplicationVersionVersion .. ".pak"] = 4,
    ["map_livik_" .. ApplicationVersionVersion .. ".prefetch"] = 5,
    ["map_forest_" .. ApplicationVersionVersion .. ".prefetch"] = 6
  }
  local param = {
    "false",
    "false",
    "false",
    "false",
    "false",
    "false"
  }
  local ret = GCPufferDownloader.ReturnLocalFiles(PufferDownloader.DOWNLOAD_DIR_RELATIVE, ".pak")
  local paknames = ""
  local   local   local saveDirPath = Client.ProjectSavedDir()
  local fileExistMap = {}
  for _, filename in pairs(ret) do
    fileExistMap[filename] = true
    local paramIndex = fileNameIndexMap[filename]
    if paramIndex then
      param[paramIndex] = "true"
    end
    local filePathPak = saveDirPath .. PufferDownloader.DOWNLOAD_DIR_RELATIVE .. filename
    local fileSizePak = Client.GetFileSizeOnDiskBytes(filePathPak)
    local fileNamePak = tostring(filename) .. string.format("(%s)|", tostring(fileSizePak))
    paknames = fileNamePak .. paknames
  end
  Client.AddAttachFileString("pakname", true, paknames)
  local ReportLocalResourcesGem = HDmpveRemote.HDmpveRemoteConfigGetBool("ReportLocalResourcesGem", false)
  if not ReportLocalResourcesGem then
    return
  end
  Client.GEMReportSubEvent(GameFrontendHUD, "PufferEvent", "UserLocalResources", param)
  local map_cfg = Client.GetSplitMapConfigInfo()
  local uniq_cfg = {}
  local StringUtil = require("common.string_util")
  for _, line in ipairs(StringUtil.Split(map_cfg, "+")) do
    local res = string.match(line, "PakName=\"(.-)\"")
    if res ~= nil then
      uniq_cfg[res] = 1
    end
  end
  for name, _ in pairs(uniq_cfg) do
    local isExist = fileExistMap[name .. ".pak"] == true
    local param1 = {
      tostring(name),
      tostring(isExist)
    }
    Client.GEMReportSubEvent(GameFrontendHUD, "PufferEvent", "UserLocalResEx", param1)
  end
end
function login_module:ReportSysInfoToGEM()
  log(bWriteLog and "login_module:ReportSysInfoToGEM")
  Client.CrashLog(NetInterface, 4, "SC", "PatchVersion: " .. tostring(Client.GetAppVersion()))
  local platName = Client.GetDevicePlatformName()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if platName == DevicePlatformNameMacros.Android then
    local gem_report_utils = require("client.logic.store.gem_report_utils")
    local res = tostring(Client.GetAndroidSysInfo()) .. ",mem:" .. tostring(Client.GetMemorySize())
    gem_report_utils.ReportEventImmediate(gem_report_utils.EventName_CommonEvent, gem_report_utils.SubEventName_AndroidSysInfo, res)
    log(bWriteLog and "login_module:ReportSysInfoToGEM, SysInfo:" .. tostring(res))
    res = tostring(Client.GetAndroidSysInfo())
    gem_report_utils.ReportEventImmediate(gem_report_utils.EventName_CommonEvent, gem_report_utils.SubEventName_AndroidSysInfo2, res)
    log(bWriteLog and "login_module:ReportSysInfoToGEM, SysInfo2:" .. tostring(res))
    res = tostring("AndroidMaxFDNum:" .. Client.GetAndroidMaxFDNum())
    gem_report_utils.ReportEventImmediate(gem_report_utils.EventName_CommonEvent, gem_report_utils.SubEventName_AndroidSysInfoGetMaxFDNum, res)
    log(bWriteLog and "login_module:ReportSysInfoToGEM, " .. tostring(res))
    res = tostring("ApkType:" .. Client.GetAndroidBuildForArm())
    gem_report_utils.ReportEventImmediate(gem_report_utils.EventName_CommonEvent, gem_report_utils.SubEventName_AndroidApkType, res)
    log(bWriteLog and "login_module:ReportSysInfoToGEM, " .. tostring(res))
    res = tostring("SOType:" .. Client.GetAndroidSOVersion())
    gem_report_utils.ReportEventImmediate(gem_report_utils.EventName_CommonEvent, gem_report_utils.SubEventName_AndroidSOType, res)
    log(bWriteLog and "login_module:ReportSysInfoToGEM, " .. tostring(res))
    res = tostring("ApkType:" .. Client.GetAndroidBuildForArm() .. ",SOType:" .. Client.GetAndroidSOVersion())
    gem_report_utils.ReportEventImmediate(gem_report_utils.EventName_CommonEvent, gem_report_utils.SubEventName_AndroidApkSOType, res)
    log(bWriteLog and "login_module:ReportSysInfoToGEM, " .. tostring(res))
  end
  if Client.GetDevicePlatformName() == DevicePlatformNameMacros.Android then
    local VulkanStat = {
      CurrentRHI = tostring(Client.GetCurrentRHILevel(GameFrontendHUD))
    }
    Client.GEMReportEvent(GameFrontendHUD, "VulkanInfo", VulkanStat)
    log(bWriteLog and "login_module:ReportSysInfoToGEM, IsVulkanRunning = " .. VulkanStat.CurrentRHI)
    Client.CrashLog(NetInterface, 4, "SC", "isMiniPak: " .. tostring(Client.IsSplitMiniPakVersion()))
  end
  Client.AddCrashContextData(12, Client.GetPublishRegion(), false, 100)
  Client.AddCrashContextData(13, Client.GetAOSSHOP(), false, 100)
  Client.AddCrashContextData(14, tostring(Client.IsSplitMiniPakVersion()), false, 100)
end
function login_module:HandlemServerMigrationAndConnect()
  self:HandlemServerMigration()
  self:ConnectToGate()
end
function login_module:HandlemServerMigration()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local info = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eLoginMigrate)
  if info and info.IsMigrate then
    info = {}
    info.IsMigrate = false
    PlayerPrefsSystem.SaveTableToFile_N(info, PlayerPrefsSystem.ePlayerPrefsType.eLoginMigrate)
  else
    info = {}
    info.IsMigrate = true
    PlayerPrefsSystem.SaveTableToFile_N(info, PlayerPrefsSystem.ePlayerPrefsType.eLoginMigrate)
  end
end
function login_module:PreLoadAssets()
  local pool = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ui_pool)
  pool:GetAsy(UIManager.UI_Config.LoginFormPhone_UIBP.path, function(obj)
    pool:Release(obj)
  end)
  pool:GetAsy(UIManager.UI_Config.LoginResetPass_UIBP.path, function(obj)
    pool:Release(obj)
  end)
end
function login_module:on_notify_game_rest_remind(isAcc, reachTime)
  log(bWriteLog and "on_notify_game_rest_remind " .. isAcc .. " " .. reachTime)
  local title = LocUtil.GetLocalizeResStr(101001)
  local a = reachTime / 3600
  if isAcc == 1 then
    local text = LocUtil.LocalizeResFormat(115001, a)
    CommonMsgBoxMgr.Show(1, title, text, nil, nil, nil, nil, extraData5s)
  else
    local text = LocUtil.LocalizeResFormat(115002, a)
    CommonMsgBoxMgr.Show(1, title, text, nil, nil, nil, nil, extraData5s)
  end
end
function login_module:on_notify_game_rest_force(isAcc, reachTime, restTime)
  log(bWriteLog and "on_notify_game_rest_force " .. isAcc .. " " .. reachTime .. " " .. restTime)
  local title = LocUtil.GetLocalizeResStr(101001)
  local a = reachTime / 3600
  local b = math.floor(restTime / 60)
  if isAcc == 1 then
    local text = LocUtil.LocalizeResFormat(115003, a, b)
    CommonMsgBoxMgr.Show(1, title, text, backLogin, nil, nil, nil, extraData5s)
  else
    local text = LocUtil.LocalizeResFormat(115004, a, b)
    CommonMsgBoxMgr.Show(1, title, text, backLogin, nil, nil, nil, extraData5s)
  end
end
function login_module:on_notify_game_aas_ban(banEndTime)
  log(bWriteLog and "notify_game_aas_ban " .. banEndTime)
  local title = LocUtil.GetLocalizeResStr(101001)
  local date = TimeUtil.FormatTime_YMDHMS(banEndTime, true)
  local textvalue = LocUtil.GetLocalizeResStr(115011)
  local text = string.format(textvalue, date)
  CommonMsgBoxMgr.Show(1, title, text, backLogin, nil, nil, nil, extraData5s)
end
function login_module:on_need_show_first_in_vietnam()
  self.bIsFirstInVietnam = true
  self:AddTimerOnce(10, function()
    if self.bIsFirstInVietnam then
      self:ShowFirstInVietnam()
    end
  end)
end
function login_module:ShowFirstInVietnam()
  local title = LocUtil.GetLocalizeResStr(101001)
  local exitLabel = LocUtil.GetLocalizeResStr(4486)
  local okLabel = LocUtil.GetLocalizeResStr(110036)
  local tips = LocUtil.GetLocalizeResStr(16018)
  local countdownTime = 60
  self.nCountDownRetryRefreshedTime = TimeUtil.OSTime()
  self.nCountDownRetryRefreshPassedTime = 0
  local timeString = LocUtil.LocalizeResFormat("16019", countdownTime)
  local cancelString = exitLabel .. "(" .. countdownTime .. ")"
  local message_box = UIManager.ShowUI(UIManager.UI_Config.common_messagebox_timer)
  local clickLogout = function()
    self.bIsFirstInVietnam = false
    self:sendLogout()
  end
  local ClickContinue = function()
    log(bWriteLog and "login_module.ClickContinue")
    if GameStatus.GetGameStatus() ~= GameStatus.Lobby and not GameStatus.IsInMainCity() then
      return
    end
    self.bIsChooseVietnam = true
    self.bIsFirstInVietnam = false
    local LoginHandler = require("client.network.Protocol.LoginHandler")
    LoginHandler.send_set_vietnam_user_req()
  end
  message_box:SetShowInfo(title, tips .. "\n" .. tostring(timeString), ClickContinue, clickLogout, okLabel, cancelString, function()
    self.nCountDownRetryRefreshPassedTime = self.nCountDownRetryRefreshPassedTime + TimeUtil.OSTime() - self.nCountDownRetryRefreshedTime
    if 0 < countdownTime and self.nCountDownRetryRefreshPassedTime > 1 then
      self.nCountDownRetryRefreshPassedTime = self.nCountDownRetryRefreshPassedTime - 1
      countdownTime = countdownTime - 1
      local remainTimeString = LocUtil.LocalizeResFormat("16019", countdownTime)
      local cancelStr = exitLabel .. "(" .. countdownTime .. ")"
      message_box:UpdateContentText(tips .. "\n" .. remainTimeString)
      message_box:UpdateCancelText(cancelStr)
    end
    if countdownTime == 0 or self.bIsFirstInVietnam == false then
      UIManager.CloseUI(UIManager.UI_Config.common_messagebox_timer)
      if not self.bIsChooseVietnam then
        self.bIsFirstInVietnam = false
        self:sendLogout()
      end
    end
  end)
end
function login_module:competition_login_res(res)
  log(bWriteLog and "LoginSystem.competition_login_res, res = " .. tostring(res))
  if res == true then
    UIManager.CloseUI(UIManager.UI_Config.login_no_auth)
    self:reqLoginLobby(self.no_auth_isRelogin, Enum_LOGIN_REPORT_CFG.NO_AUTH)
  else
    ShowNotice(101710)
  end
end
function login_module:TryNoAuthRelogin()
  if not self.no_auth_username or not self.no_auth_password then
    ShowNotice(103017)
    EventAndroidQuitGame()
  else
    local LoginHandler = require("client.network.Protocol.LoginHandler")
    LoginHandler.send_competition_login(self.no_auth_password)
  end
end
function login_module:on_get_client_basic_cfg_rsp(configTbl)
  local PufferNetManager = require("client.slua.logic.download.network.logic_puffer_netmanager")
  self.ClientBasicCfg = configTbl
  if bWriteLog then
    for k, v in pairs(configTbl) do
      log(bWriteLog and "LoginSystem.on_get_client_basic_cfg_rsp " .. tostring(k) .. " " .. tostring(v))
    end
  end
  local Logic_Mini_Pak_Gem = require("client.slua.logic.download.report.logic_mini_pak_gem")
  Logic_Mini_Pak_Gem.bIsGary = configTbl.MiniPakGemLogSwitch or false
  local PufferSwitch = require("client.slua.logic.download.puffer_switch")
  PufferSwitch.MapsAutoDownloadAllSwitch = configTbl.MapsAutoDownloadAllSwitch or false
  PufferSwitch.MapsAutoDownloadAllSwitch_Newbie = configTbl.MapsAutoDownloadAllSwitch_Newbie or false
  local RecommendHandler = require("client.slua.logic.download.recommend.logic_recommend_handler")
  RecommendHandler.RecommendDownloadNewPlayerSwitch = configTbl.RecommendDownloadNewPlayerSwitch or false
  RecommendHandler.RecommendDownloadOldPlayerSwitch = configTbl.RecommendDownloadOldPlayerSwitch or false
  RecommendHandler.RecommendDeleteSwitch = configTbl.RecommendDeleteSwitch or false
  self.forceRepairLevel = configTbl.ForceRepairLevel or 1
  PufferNetManager.DynamicSpeedSwitch = configTbl.DynamicSpeedSwitch or false
  PufferNetManager.FastSpeedSwitch = configTbl.FastSpeedSwitch or false
  PufferNetManager.ProtocolReserveSpeed = configTbl.ProtocolReserveSpeed or 200
  PufferNetManager.HeartReserveSpeed = configTbl.HeartReserveSpeed or 60
  PufferNetManager.BaseReserveSpeed = configTbl.BaseReserveSpeed or 100
  PufferNetManager.SetRegionReserveSpeed()
  PufferDownloader.ODPaksRequestReportTimeThreshold = configTbl.ODPaksReportFlushInterval or 40
  PufferDownloader.ODPaksRequestReportNumberThreshold = configTbl.ODPaksReportBatchSize or 100
  PufferDownloader.ODPaksRequestReportErrorMaxTimes = configTbl.ODPaksReportMaxError or 50
  PufferDownloader.ClearPufferInGame = configTbl.ClearPufferInGame or false
  local device_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.device_module)
  device_module:EnablePreFetchPaks()
  device_module:EnableReportAntsVoiceEvent(configTbl)
  RecommendHandler.AutoDownload()
  PufferSwitch.InitAutoDownloadSwitch()
  local AkAudioSystem = require("client.slua.logic.audio.logic_ak_audio")
  local bluetoothOption = configTbl.BluetoothOption or -1
  local delayTime = configTbl.BluetoothOptimizationDelay or 80
  AkAudioSystem.OnClientBaseConfigRsp(bluetoothOption, delayTime)
  local ScriptHelperClient = import("ScriptHelperClient")
  ScriptHelperClient.SetIosStuckEnableByServerConfig(configTbl.IosStuckEnable or 0)
  ScriptHelperClient.SetCrashContextReportLevel(configTbl.CrashContextReport or -1)
  ScriptHelperClient.SetUDPPingControlFlag(configTbl.UDPPingSequenceLock or 0, configTbl.UDPPingBindType or 0)
  local SmartBearerManagerLuaBridge = import("SmartBearerManagerLuaBridge")
  if SmartBearerManagerLuaBridge then
    local ClientEVOConfig = require("client.logic.client_evo_config.client_evo_config")
    ClientEVOConfig.OnPreBackEndSwitcherSet(configTbl.SmartBearerSwitcher or 0, configTbl.SuperFrameSwitcher or 0, configTbl.ClientBackEndSwitcherA or 0, configTbl.ClientBackEndSwitcherB or 0, configTbl.ClientBackEndSwitcherC or 0, configTbl.PostLoadThreadSwitcher or 0)
    if SmartBearerManagerLuaBridge.SetSmartBearerNumData then
      SmartBearerManagerLuaBridge.SetSmartBearerNumData(configTbl.SmartBearerNum or "42|38|11|11|40|40|40|11-42|38|11|11|40|40|40|15")
    end
    if SmartBearerManagerLuaBridge.SetSmartBearerOptSwitcher then
      SmartBearerManagerLuaBridge.SetSmartBearerOptSwitcher(configTbl.SmartBearerSwitcher or 0)
    end
    if SmartBearerManagerLuaBridge.SetSuperFrameOptSwitcher then
      SmartBearerManagerLuaBridge.SetSuperFrameOptSwitcher(configTbl.SuperFrameSwitcher or 0)
    end
    if SmartBearerManagerLuaBridge.SetClientBackEndSwitcherA then
      SmartBearerManagerLuaBridge.SetClientBackEndSwitcherA(configTbl.ClientBackEndSwitcherA or 0)
    end
    if SmartBearerManagerLuaBridge.SetClientBackEndSwitcherB then
      SmartBearerManagerLuaBridge.SetClientBackEndSwitcherB(configTbl.ClientBackEndSwitcherB or 0)
    end
    if SmartBearerManagerLuaBridge.SetClientBackEndSwitcherC then
      SmartBearerManagerLuaBridge.SetClientBackEndSwitcherC(configTbl.ClientBackEndSwitcherC or 0)
    end
    if SmartBearerManagerLuaBridge.SetPostLoadThreadSwitcher then
      SmartBearerManagerLuaBridge.SetPostLoadThreadSwitcher(configTbl.PostLoadThreadSwitcher or 0)
    end
    ClientEVOConfig.PostBackEndSwitcherSet(configTbl.SmartBearerSwitcher or 0, configTbl.SuperFrameSwitcher or 0, configTbl.ClientBackEndSwitcherA or 0, configTbl.ClientBackEndSwitcherB or 0, configTbl.ClientBackEndSwitcherC or 0, configTbl.PostLoadThreadSwitcher or 0)
  end
  local newbeeTime = 259200
  local time = TimeUtil.GetServerTimeInSec() - DataMgr.registertime
  log(bWriteLog and "FuncUtil.GetServerTimeInSec() = " .. tostring(TimeUtil.GetServerTimeInSec()) .. " DataMgr.registertime = " .. tostring(DataMgr.registertime))
  if 0 < time and newbeeTime > time then
    PufferDownloader.DisableInBattleThreshold = configTbl.DownloadInBattleEnableDeviceLevel_Newbie or 1
  else
    PufferDownloader.DisableInBattleThreshold = configTbl.DownloadInBattleEnableDeviceLevel or 1
  end
  PufferDownloader.RefreshDownloadInBattleSwitch()
  local enable_lagging = configTbl.LagContextEnable or false
  Client.InitializeLaggingReporter(GameFrontendHUD, enable_lagging)
end
function login_module:lobbyShowBox(styleType, title, msg, clickOkCallback, clickCancelCallback, btnOK, btnCancel, extraData)
  if GameStatus.IsInFightingNotMainCity() then
    log_shipping_client("lobbyShowBox: is in Fighting, don't show box")
    return
  end
  CommonMsgBoxMgr.Show(styleType, title, msg, clickOkCallback, clickCancelCallback, btnOK, btnCancel, extraData)
end
function login_module:UserAgreementTips()
  local LeagalMsgSystem = require("client.slua.logic.common.logic_common_legal_msg")
  LeagalMsgSystem.ShowUserAgreement()
end
local reason2wordIdPop = {
  ip_limit_1 = 101101,
  ip_limit_2 = 101103,
  ip_limit_3 = 101104,
  ip_limit_4 = 101106,
  ip_limit_5 = 101110,
  device_limit_1 = 101112,
  device_limit_2 = 101113,
  device_limit_3 = 101301,
  device_limit_4 = 101302,
  device_limit_5 = 101307,
  metro_kick_out = 11975,
  security_device_limit = 29087,
  minor_reach_daily_limit = 44549,
  ["not-in-open-time"] = 101702,
  ["server-maintenance"] = 7175,
  ["restrict-area-guest"] = 7401,
  ["bluehole-user-in-M"] = 7401,
  ["register-ip-limit"] = 301121,
  ["tss-version-invalid"] = 35118
}
local reason2wordId = {qrcode_login_switch_close = 200000127}
local reason2wordIdLogOut = {
  nonage_limit_1 = 101115,
  nonage_limit_2 = 101116,
  nonage_limit_3 = 101117,
  nonage_limit_4 = 101118,
  verify_code_err = 27472,
  self_bind_err = 48604,
  qrcode_login_limit = 200000065
}
local no_popup_error = {login_error = 1}
function login_module:on_login_failed(conn_idx, reason, banInfo, banTime, uid, extra_table)
  local fail = "conn_idx = " .. tostring(conn_idx) .. ", reason = " .. tostring(reason) .. ", banTime = " .. tostring(banTime)
  log_shipping_client("on_login_failed:" .. fail)
  log_error("login_module:on_login_failed, " .. fail)
  log_warning(bWriteLog and "  : uid: " .. tostring(uid))
  log(bWriteLog and "LoginSystem.on_login_failed, banInfo = " .. tostring(banInfo))
  self:SetLoginAble(true)
  EventSystem:postEvent(EVENTTYPE_LOGIN, EVENTID_LOGIN_FAIL_PRE)
  FuncUtil.AddCrashContextMainFlow("60", tostring(reason))
  local gem_report_utils = require("client.logic.store.gem_report_utils")
  local login_protect_utils = require("client.slua.logic.login.login_protect_utils")
  login_protect_utils.RecordLoginFailTime()
  local IntlHelper = import("IntlHelper")
  IntlHelper.AddErrorCodeToHistory(string.format("svr-%s", reason))
  NetUtil.StopCheckLoginRsp()
  self.bHasLogout = true
  self.bIsInitLogin = false
  log_tree("LoginSystem.on_login_failed extra_table", extra_table)
  if extra_table and type(extra_table) == "table" then
    self.nLink_type = extra_table.link_type
    self.sBanNickname = extra_table.nick_name
    self.sBancountry = extra_table.country
    self.nAppeal_switch = extra_table.appeal_switch
  end
  NetUtil.gameTick = false
  if reason ~= "ban-login" then
    log(bWriteLog and "not ban-login -> NetUtil.Disconnect")
    NetUtil.Disconnect()
    gem_report_utils.ReportEventDelay(gem_report_utils.EventName_Network, "disconnect", "fail")
  end
  self:RemoveLoginTimer()
  Client.GEMReportEnterLobbyEvent(GameFrontendHUD, false, "kick out by server," .. reason)
  local title = LocUtil.GetLocalizeResStr(101001)
  local text = LocUtil.GetLocalizeResStr(101703)
  text = text .. reason
  local needLogout
  local textId = reason2wordIdPop[reason]
  if textId then
    text = LocUtil.GetLocalizeResStr(textId) .. string.format(" (%d)", textId)
  elseif reason2wordId[reason] then
    text = LocUtil.GetLocalizeResStr(reason2wordId[reason])
  elseif reason2wordIdLogOut[reason] then
    needLogout = true
    textId = reason2wordIdLogOut[reason]
    text = LocUtil.GetLocalizeResStr(textId) .. string.format(" (%d)", textId)
  elseif string.find(reason, "unverified") then
    text = string.format([[
%s 
(dev version: reason=%s)]], text, tostring(reason))
    local openid = string.match(reason, "unverified openid: (%d+)")
    local url = string.format("%s?openid=%s", FuncUtil.GetDomainByID(3366228), tostring(openid))
    local sExtraText = "<a id=\"HyperlinkDecorator\" style=\"PrivacyPolicyLink\" url=\"GM\">(apply for the whitelist)</>"
    text = text .. sExtraText
    local OpenUrl = function()
      local WebviewSDK = require("client.slua.logic.url.logic_webview_sdk")
      WebviewSDK:OpenURL(url)
    end
    local extraData = {
      showUIKey = "com_msg_box_5s",
      urlHandle = OpenUrl
    }
    CommonMsgBoxMgr.Show(2, title, text, OpenUrl, nil, LocUtil.GetLocalizeResStr(5078), LocUtil.GetLocalizeResStr(44498), extraData)
    return
  else
    local func = self[reason]
    if type(func) == "function" then
      local result = func(self, conn_idx, reason, banInfo, banTime, uid, extra_table)
      if not result then
        return
      else
        log_warning(bWriteLog and "  : result: " .. tostring(result))
        if type(result) == "string" then
          text = result
        end
      end
    else
      log_warning(bWriteLog and "  : funcName is Error: " .. tostring(reason))
    end
  end
  local AfterCloseTips = function()
    if needLogout then
      local SettingAccount = require("client.logic.setting.logic_setting_account")
      SettingAccount.ClientLogout()
    end
    backLogin()
  end
  local extraData = {
    showUIKey = "com_msg_box_5s",
    androidCallback = AfterCloseTips
  }
  if no_popup_error[reason] then
    self:lobbyShowBox(1, title, text, AfterCloseTips, nil, nil, nil, extraData)
  else
    CommonMsgBoxMgr.Show(1, title, text, AfterCloseTips, nil, nil, nil, extraData)
  end
end
login_module["not-in-white-list"] = function(self)
  local text = LocUtil.GetLocalizeResStr(101704)
  local btnWord = LocUtil.GetLocalizeResStr(110034)
  local title = LocUtil.GetLocalizeResStr(101001)
  CommonMsgBoxMgr.Show(1, title, text, nil, nil, btnWord, nil, extraData5s)
  self:Transition(ELoginFSMEvent.Event_CSTL)
end
login_module["activation-code-not-exists"] = login_module["not-in-white-list"]
login_module["need-activation-code"] = login_module["not-in-white-list"]
local kickoutCountdownTimerCallback = function()
  local ban_login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ban_login_module)
  ban_login_module:kickoutCountdownTimerCallback()
end
login_module["ban-login"] = function(_, _, _, banInfo, banTime, uid, _)
  local text
  if banInfo == "migrate-kick-out" then
    local date = TimeUtil.FormatTime_YMDHMS(banTime, true)
    text = LocUtil.LocalizeResFormat(21175, date)
    local title = LocUtil.GetLocalizeResStr(101001)
    CommonMsgBoxMgr.Show(1, title, text, backLogin, nil, nil, nil, extraData5s)
    return
  end
  if banInfo == "migrate-ban-login" then
    text = LocUtil.GetLocalizeResStr(21253)
    local title = LocUtil.GetLocalizeResStr(101001)
    CommonMsgBoxMgr.Show(1, title, text, backLogin, nil, nil, nil, extraData5s)
    return
  end
  banInfo = LocUtil.LocalizeServerText(banInfo)
  local extraData = {
    showUIKey = "com_msg_box_5s",
    onTimerInvoke = kickoutCountdownTimerCallback
  }
  if banTime < 0 then
    local title = LocUtil.GetLocalizeResStr(101001)
    CommonMsgBoxMgr.Show(1, title, banInfo, backLogin, nil, nil, nil, extraData)
  else
    local ban_login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ban_login_module)
    ban_login_module:ShowIDIPBanTips(banInfo, banTime, uid)
  end
end
function login_module:Login_Failed(_, _, banInfo, _, _, _)
  local text = banInfo
  if type(banInfo) == "number" then
    text = LocUtil.GetLocalizeResStr(banInfo)
  end
  text = string.format("%s(Login_Failed)", text)
  local title = LocUtil.GetLocalizeResStr(101001)
  self:lobbyShowBox(1, title, text, backLogin, nil, nil, nil, extraData5s)
end
function login_module:aas_ban(_, _, _, banTime, _, _)
  local date = TimeUtil.FormatTime_YMDHMS(banTime, true)
  local textvalue = LocUtil.GetLocalizeResStr(115011)
  local text = string.format(textvalue, date)
  local title = LocUtil.GetLocalizeResStr(101001)
  CommonMsgBoxMgr.Show(1, title, text, backLogin, nil, nil, nil, extraData5s)
end
login_module["low-version"] = function()
  local text = LocUtil.GetLocalizeResStr(101706)
  local cancelLabel = LocUtil.GetLocalizeResStr(4539)
  local helpCallback = function()
    local LogicCustomerService = require("client.slua.logic.CustomerService.LogicCustomerService")
    LogicCustomerService.HelpshiftShowFAQsWithInfo()
  end
  local title = LocUtil.GetLocalizeResStr(101001)
  CommonMsgBoxMgr.Show(2, title, text, function()
    GameStatus.QuitGame()
  end, helpCallback, nil, cancelLabel, extraData5s)
end
login_module["low-version-diff"] = function()
  local text = LocUtil.GetLocalizeResStr(101707)
  local title = LocUtil.GetLocalizeResStr(101001)
  if IsWoWEditor then
    local MsgBody = {}
    MsgBody.isGray = 1
    Client.OneUp_GLauncherAsyncGameEventNotify(3, json.encode(MsgBody))
    CommonMsgBoxMgr.Show(1, title, text, function()
      backLogin()
    end, nil, nil, nil, extraData5s)
  else
    CommonMsgBoxMgr.Show(1, title, text, backLogin, nil, nil, nil, extraData5s)
  end
end
login_module["register-exceed-limit"] = function()
  local text = LocUtil.GetLocalizeResStr(101708)
  local title = LocUtil.GetLocalizeResStr(101001)
  CommonMsgBoxMgr.Show(1, title, text, backLogin, nil, nil, nil, extraData5s)
end
login_module["device-in-blacklist"] = function()
  local text = LocUtil.GetLocalizeResStr(101716)
  local title = LocUtil.GetLocalizeResStr(101001)
  CommonMsgBoxMgr.Show(1, title, text, GameStatus.QuitGame, GameStatus.QuitGame, nil, nil, extraData5s)
end
login_module["idip-kick-out"] = function()
  local text = LocUtil.GetLocalizeResStr(115006)
  local extraData = {
    showUIKey = "com_msg_box_5s",
    onTimerInvoke = kickoutCountdownTimerCallback
  }
  local title = LocUtil.GetLocalizeResStr(101001)
  CommonMsgBoxMgr.Show(1, title, text, sendLogout, nil, nil, nil, extraData)
end
login_module["Vietnam-user-in-M"] = function()
  local text = LocUtil.GetLocalizeResStr(6300)
  local extraData = {
    showUIKey = "com_msg_box_5s",
    onTimerInvoke = kickoutCountdownTimerCallback
  }
  local title = LocUtil.GetLocalizeResStr(101001)
  CommonMsgBoxMgr.Show(1, title, text, sendLogout, nil, nil, nil, extraData)
end
function login_module.device_num_limit()
  local text = LocUtil.GetLocalizeResStr(29606)
  local title = LocUtil.GetLocalizeResStr(101001)
  CommonMsgBoxMgr.Show(1, title, text, sendLogout, nil, nil, nil, extraData5s)
end
login_module["register-forbidden"] = function(_, _, _, banInfo, banTime, _, _)
  log(bWriteLog and "[DeanJYT] register-forbidden")
  if banInfo and tostring(banInfo) ~= "" and banTime then
    local logic_region_block = require("client.logic.logic_region_block.logic_region_block")
    logic_region_block.ShowBlockRegionNotice(tostring(banInfo), banTime)
    return
  end
  return LocUtil.GetLocalizeResStr(14259)
end
login_module["login-overload"] = function(self)
  self.hasLogout = false
  if self:reconnectGateway() then
    return
  end
  return true
end
login_module["data-migration"] = function(self)
  self:HandlemServerMigrationAndConnect()
end
function login_module:wait_migrate_query()
  self:wait_migrate_queryOrmigrating()
end
function login_module:migrating()
  self:wait_migrate_queryOrmigrating()
end
function login_module:wait_migrate_queryOrmigrating()
  logic_connection_waiting:Show(0)
  ShowNotice(100280009)
  self:AddTimerOnce(10, function()
    logic_connection_waiting:Hide(0)
    backLogin()
  end)
end
login_module["etc-restrict-area"] = function(_, _, _, banInfo, banTime, _, _)
  local logic_region_block = require("client.logic.logic_region_block.logic_region_block")
  if banInfo then
    logic_region_block.ShowBlockRegionNotice(tostring(banInfo), banTime)
    return
  end
  return LocUtil.GetLocalizeResStr(14259)
end
local banLoginAppeal = function()
  local ban = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ban_login_module)
  ban:banLoginAppeal()
end
function login_module.aq_ban()
  local text = LocUtil.LocalizeResFormat(31148)
  local btnCancel = LocUtil.GetLocalizeResStr(4004)
  local title = LocUtil.GetLocalizeResStr(101001)
  CommonMsgBoxMgr.Show(2, title, text, banLoginAppeal, nil, btnCancel)
end
function login_module:backLogin(reason)
  local gem_report_utils = require("client.logic.store.gem_report_utils")
  log_shipping_client("[Login process] login_module backLogin")
  EventSystem:postEvent(EVENTTYPE_LOGIN, EVENTID_BACKLOGIN)
  local curStatus = GameStatus.GetGameStatus()
  if curStatus ~= GameStatus.Login then
    log_warning(bWriteLog and "  . backLogin is not in login ")
    GameStatus.SwitchToLoginState()
  end
  if reason ~= 1 then
    local device_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.device_module)
    device_module:SetisFromBgBgGameCenter(false)
    device_module:SetisFromWXGameCenter(false)
  end
  self.bHasLogout = true
  self.bIsInitLogin = false
  local ban_login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ban_login_module)
  ban_login_module:ResethasKickOut()
  NetUtil.gameTick = false
  local pandoraSystem = require("client.slua.logic.Pandora.pandora_system")
  pandoraSystem.Release()
  log(bWriteLog and "backLogin, curStatus = " .. tostring(curStatus))
  log(bWriteLog and "  login_module:backLogin. slua_GameFrontendHUD.PendingGameStatus: " .. tostring(slua_GameFrontendHUD.PendingGameStatus))
  local showLoginUI = function()
    self:Transition(login_module.ELoginFSMEvent.Event_CSTL)
    self:ShowButtonsAfterLoginFailed()
  end
  if curStatus == GameStatus.Login then
    showLoginUI()
  elseif slua_GameFrontendHUD.PendingGameStatus == GameStatus.Login then
    local async = require("client.common.async")
    async.Run(function(co)
      async.AwaitEvent(co, 60, EVENTTYPE_STATE, EVENTID_ON_MODE_POST_SWITCH)
      if GameStatus.GetGameStatus() == GameStatus.Login then
        log(bWriteLog and "  login_module:backLogin.  is login")
        showLoginUI()
      end
    end)
  end
  self:RemoveLoginTimer()
  local LoadingSystem = require("client.slua.logic.loading.logic_loading")
  LoadingSystem.RefreshLoadPercent(1)
  NetUtil.Disconnect()
  gem_report_utils.ReportEventDelay(gem_report_utils.EventName_Network, "disconnect", "back")
  local NetManager = require("client.network.comm.NetManager")
  NetManager.mustArrivePkgMap = {}
  if IsWoWEditor and not IsEditor then
    GameStatus.QuitGame()
  end
end
function login_module:BackLoginWithCallback(callback)
  logic_connection_waiting:Show(1)
  self:AddShowLoginCallback(callback)
  self.logoutSvrThenLogoutSDK = false
  local ban_login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ban_login_module)
  ban_login_module:sendLogoutWithoutLogoutAccount()
end
function login_module:sendLogout(reason)
  local ban_login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ban_login_module)
  ban_login_module:sendLogout(reason)
end
function login_module:SaveLastLoginChannel()
  local IMSDKQRCodeSystem = require("client.logic.login.logic_imsdk_qrcode")
  local isQRCode = IMSDKQRCodeSystem:IsQRCodeLogined()
  local savedFlag = 0
  if isQRCode then
    self.logoutSvrThenLogoutSDK = false
    savedFlag = 1
  end
  self.nLastIsScan = savedFlag
  log_warning(bWriteLog and "  login_module:SaveLastLoginChannel. self.nLastIsScan: " .. tostring(self.nLastIsScan))
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(savedFlag, PlayerPrefsSystem.ePlayerPrefsType.eLastLoginChannel)
end
function login_module:on_logout(msg)
  log(bWriteLog and "on_logout " .. tostring(msg))
  local gem_report_utils = require("client.logic.store.gem_report_utils")
  local LoadingSystem = require("client.slua.logic.loading.logic_loading")
  LoadingSystem.ShowLoading(true)
  self.bHasLogout = true
  self.bIsInitLogin = false
  NetUtil.gameTick = false
  self:SaveLastLoginChannel()
  self:backLogin()
  if self.logoutSvrThenLogoutSDK then
    local SettingAccount = require("client.logic.setting.logic_setting_account")
    SettingAccount.ClientLogout()
    local SettingSystem = require("client.logic.setting.logic_setting")
    if SettingSystem.NBindChannel ~= nil and SettingSystem.NBindChannel ~= 0 then
      local IMSDKHelper = import("IMSDKHelper")
      local IMSDKHelperInstance = IMSDKHelper.GetInstance()
      IMSDKHelperInstance:LogoutWith(SettingSystem.NBindChannel)
    end
  else
    self.logoutSvrThenLogoutSDK = true
  end
  NetUtil.Disconnect()
  gem_report_utils.ReportEventDelay(gem_report_utils.EventName_Network, "disconnect", "logout")
  self.bRecvCloudToken = false
  self.CloudTokenInfo = nil
  self:CloudGameTlogReport(false)
end
function login_module:addLogoutCallback(callback)
  if callback and type(callback) == "function" then
    log(bWriteLog and "login_module:addLogoutCallback")
    self.logoutCallback = callback
  end
end
function login_module:AddShowLoginCallback(callback)
  log_warning(bWriteLog and string.format("login_module:AddShowLoginCallback. callback %s", callback))
  self.showLoginCallback = callback
end
function login_module:SetGmLoginChannel(channel)
  if not Client.IsReleaseVersion(NetInterface) then
    self.gmLoginChannel = channel
    log(bWriteLog and "  login_module:SetGmLoginChannel. channel: " .. tostring(channel))
  end
end
function login_module:OnPipeMsgLogin(_, __, MsgKey, MsgBody)
  log(bWriteLog and string.format("login_module:OnPipeMsgLogin. MsgKey=%s, MsgBody=%s", tostring(MsgKey), tostring(MsgBody)))
  if MsgKey == "LoginRsp" then
    self:OnProcessPipeMsgLoginInfo(MsgBody)
  end
end
function login_module:OnPipeMsgGeneral(_, __, MsgKey, MsgBody)
end
function login_module:ConvertIMSDKChannelToHDmpveChannel(iMSDKChannel)
  local HDmpveChannelID = 0
  if iMSDKChannel == 1 then
    HDmpveChannelID = 2
  elseif iMSDKChannel == 4 then
    HDmpveChannelID = 1
  elseif iMSDKChannel == 5 then
    HDmpveChannelID = 5
  elseif iMSDKChannel == 3 then
    HDmpveChannelID = 41
  elseif iMSDKChannel == 2 then
    HDmpveChannelID = 40
  elseif iMSDKChannel == 35 then
    HDmpveChannelID = 42
  elseif iMSDKChannel == 14 then
    HDmpveChannelID = 43
  elseif iMSDKChannel == 36 then
    HDmpveChannelID = 44
  elseif iMSDKChannel == 31 then
    HDmpveChannelID = 45
  elseif iMSDKChannel == 40 then
    HDmpveChannelID = 46
  elseif iMSDKChannel == 42 then
    HDmpveChannelID = 47
  elseif iMSDKChannel == 44 then
    HDmpveChannelID = 48
  elseif iMSDKChannel == 39 then
    HDmpveChannelID = 49
  end
  log(bWriteLog and string.format("login_module:ConvertIMSDKChannelToHDmpveChannel. iMSDKChannel=%s, HDmpveChannelID=%s", tostring(iMSDKChannel), tostring(HDmpveChannelID)))
  return HDmpveChannelID
end
function login_module:OnProcessPipeMsgLoginInfo(MsgBody)
  if not (MsgBody and MsgBody.Token) or not MsgBody.Guid then
    return
  end
  self.CloudTokenInfo = MsgBody
  self.bRecvCloudToken = true
  local CloudLoginInfo = self.CloudTokenInfo
  local HDmpveChannel = self:ConvertIMSDKChannelToHDmpveChannel(CloudLoginInfo.ChannelID)
  slua_GameFrontendHUD:SetAccountByWebLogin(HDmpveChannel, CloudLoginInfo.Guid or "", CloudLoginInfo.Guid or "", CloudLoginInfo.Token or "", CloudLoginInfo.TokenExpire or 0)
end
function login_module:StartCloudVersionLogin()
  self:ReGetCloudLoginInfo()
end
function login_module:ReGetCloudLoginInfo()
  local MsgInfo = {
    MsgKey = "LoginRetry",
    MsgBody = {}
  }
  local logic_pipeline_helper = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pipeline_helper)
  logic_pipeline_helper:SendData(MsgInfo)
end
function login_module:ReGetCloudDevInfo()
  local MsgInfo = {
    MsgKey = "LoginInfo",
    MsgBody = {
      "ip",
      "deviceid",
      "xid"
    }
  }
  local logic_pipeline_helper = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pipeline_helper)
  logic_pipeline_helper:SendData(MsgInfo)
end
function login_module:OnPipeMsgDevInfo(_, __, MsgKey, MsgBody)
  self.CloudDevInfo = MsgBody
  local logic_pipeline_helper = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pipeline_helper)
  logic_pipeline_helper:SendData({
    MsgKey = "LoginInfoRec"
  })
end
function login_module:CacheSDKAdjustAttr()
  log(bWriteLog and "login_module:CacheSDKAdjustAttr")
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  if IMSDKHelperInstance.GetAdjustAttr then
    log(bWriteLog and "login_module:CacheSDKAdjustAttr IMSDKHelperInstance.GetAdjustAttr")
  end
  local jsonStr = IMSDKHelperInstance.GetAdjustAttr and IMSDKHelperInstance:GetAdjustAttr()
  log(bWriteLog and string.format("login_module:CacheSDKAdjustAttr, jsonStr:%s", jsonStr))
  if jsonStr and jsonStr ~= "" then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    PlayerPrefsSystem.SaveTableToFile_N({jsonStr = jsonStr}, PlayerPrefsSystem.ePlayerPrefsType.eAdjustrReattribution)
    self.SDKAdjustAttr = jsonStr
  end
end
function login_module:UpdateAccountDataWithLogin(isReLogin, openId)
  log(bWriteLog and "login_module:UpdateAccountDataWithLogin isReLogin: " .. tostring(isReLogin))
  if isReLogin then
    return
  end
  if not self.bReLoginAccount then
    self.loginAccountData.firstLoginTime = TimeUtil.GetServerTimeInSec()
  else
    self.loginAccountData.reLoginNum = self.loginAccountData.reLoginNum + 1
  end
  log(bWriteLog and "login_module:UpdateAccountDataWithLogin openId: " .. tostring(openId))
  if openId and openId ~= "" and not self.historyLoginAccount[openId] then
    self.loginAccountData.accountNum = self.loginAccountData.accountNum + 1
    self.historyLoginAccount[openId] = true
  end
end
function login_module:SetBGmCloudPhoneCode(flag)
  log(bWriteLog and "login_module:SetBGmCloudPhoneCode. flag: " .. tostring(flag))
  self.bGmCloudPhoneCode = flag
end
function login_module:LoginByCp(serverName)
  log(bWriteLog and "login_module:LoginByCp.  serverName: " .. tostring(serverName))
  local UIManager = require("client.slua_ui_framework.manager")
  local serverlist = UIManager.ShowUI(UIManager.UI_Config.ServerList_UIBP)
  self:AddTimer(0, function()
    while not next(serverlist.arr_TabData_ServerList) do
      coroutine.yield(1)
    end
    for tab, list in ipairs(serverlist.arr_TabData_ServerList) do
      for i, v in pairs(list) do
        if v.name == serverName then
          serverlist:CloseSelf()
          login_module:SetnSeverTab(tab)
          login_module:SetnSeverIdx(i)
          login_module:ConnectToGate(v.addr, i, v.areaid)
          local logic_gm_server = RequireBlackList("blacklist.slua.logic.lobby_gm.logic_gm_server")
          logic_gm_server._cur_server = serverName
          break
        end
      end
    end
  end)
end
function login_module:SetLoginAble(able)
  log(bWriteLog and "login_module:SetLoginAble. able: " .. tostring(able))
  self.bLoginAble = able
end
local BCheckLoginAble = HDmpveRemote.HDmpveRemoteConfigGetBool("BCheckLoginAble", true)
function login_module:CheckLoginAble()
  if not BCheckLoginAble then
    log(bWriteLog and "login_module:CheckLoginAble.  not BCheckLoginAble")
    return true
  end
  if self.bLoginAble then
    self:SetLoginAble(false)
  else
    log(bWriteLog and "login_module:CheckLoginAble.  not")
    return false
  end
  return true
end
function login_module:LoginToServer(servername)
  local UIManager = require("client.slua_ui_framework.manager")
  local serverlist = UIManager.ShowUI(UIManager.UI_Config.ServerList_UIBP)
  serverlist:Hide()
  local time_ticker = require("common.time_ticker")
  time_ticker.AddTimer(0, function()
    local LogFilter = require("common.log_filter")
    LogFilter.SetLogTreeEnable(true)
    log(bWriteLog and "[jwm]UpdateEndCallBack. #serverlist.arr_TabData_ServerList: " .. tostring(#serverlist.arr_TabData_ServerList))
    log_tree("arr_TabData_ServerList", serverlist.arr_TabData_ServerList)
    while not next(serverlist.arr_TabData_ServerList) do
      coroutine.yield(1)
    end
    log(bWriteLog and "[ori]UEPUBGMServerName: " .. tostring(servername))
    for tab, list in ipairs(serverlist.arr_TabData_ServerList) do
      for i, v in pairs(list) do
        if v.name == servername then
          log("client_entry: Find Server: " .. tostring(servername))
          serverlist:CloseSelf()
          login_module:SetnSeverTab(tab)
          login_module:SetnSeverIdx(i)
          login_module:ConnectToGate(v.addr, i, v.areaid)
          local logic_gm_server = RequireBlackList("blacklist.slua.logic.lobby_gm.logic_gm_server")
          logic_gm_server._cur_server = servername
          break
        end
      end
    end
  end)
end
login_module.local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogin_module = class(CModuleBase, nil, login_module)
return Clogin_module