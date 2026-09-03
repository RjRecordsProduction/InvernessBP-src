local Login_UIBP = {}
local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
local LanguageMacros = require("client.slua.config.ClientMacros.LanguageMacros")
local LoginSubUIUtil = require("client.slua.logic.login.login_subui_util")
local isJk = PublishRegionMacros.IsJapanOrKorea()
local region = Client.GetPublishRegion()
local isKorea = region == PublishRegionMacros.KOREA
local isBlueHole = PublishRegionMacros.IsBLUEHOLE()
local ENUM_LOGIN_MODE = {
  ByChannel = 1,
  NoAuth = 2,
  Selecting = 3
}
function Login_UIBP:ctor()
  self.nPrivacyVersion = 0
  self.nNeedPrivacyVersion = 0
  self.bPrivacyChecked = false
  self.bNeedPopupPrivacy = false
  self.nUserAgreementVersion = 0
  self.bUserAgreementChecked = false
  self.ageClauseChecked = false
  self.reportedConnectSuccess = false
  self.nLoginCount = 0
  self.nLoginTime = 0
  self.autoLogin = true
  self.loginChannels = {}
  self.firstLoginChannel = ""
  self.secondLoginChannel = ""
  self.thirdLoginChannel = ""
  self.useRecommendMode = false
  self.playerData = {}
  self.curLoginMode = ENUM_LOGIN_MODE.ByChannel
  self.bUsingOfflineServer = false
  self.AnimaPlayPromise = nil
end
function Login_UIBP:OnInitialize()
  Login_UIBP.__super.OnInitialize(self)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_AgeLimited, isKorea)
  local device_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.device_module)
  device_module:DelayToInitFacebookSDK()
  local DataMigrationSystem = require("client.slua.logic.data_migration.data_migration_logic")
  if DataMigrationSystem.noticeId then
    ShowNotice(DataMigrationSystem.noticeId)
    DataMigrationSystem.SetNoticeId(nil)
  end
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  self.quickLoginHDmpveChannelID = IMSDKHelperInstance:GetHDmpveChannelID()
  local logic_clicker = require("client.slua.logic.clicker.logic_clicker")
  logic_clicker.InitUDObj()
end
function Login_UIBP:OnPostInitialize()
  Login_UIBP.__super.OnPostInitialize(self)
  local time_step_macros = require("client.slua.logic.performance.time_step_macros")
  local logic_time_cost_report = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_time_cost_report)
  logic_time_cost_report:ReportTimeCost(time_step_macros.ENUM_TIME_STEP.UpdatePatchEndToLoginUIShow)
  if not Client.IsReleaseVersion(NetInterface) then
    log_shipping_client("Login_UIBP:OnPostInitialize IsCEVersion or dev")
    UIManager.ShowUI(UIManager.UI_Config.Lobby_Watermark_BP, true)
  else
    local GM_DefaultOpen = RequireBlackList("blacklist.slua.logic.gm.Common.GM_DefaultOpen")
    if GM_DefaultOpen then
      GM_DefaultOpen.OpenLogAndXpCallReport()
    end
  end
  local utility = require("common.utility")
  xpcall(self.InitializeUserSettingAndXYSystem, utility.ErrorMessageHandler, self)
  local device_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.device_module)
  device_module:EnablePlanarReflection()
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  login_module:SetLoginAble(true)
  login_module:DelayInitThirdPartSDK()
  logic_connection_waiting:Hide(1)
  local callback = login_module.showLoginCallback
  if callback then
    login_module:AddShowLoginCallback(nil)
    callback()
  end
  FuncUtil.AddCrashContextMainFlow("60")
  self:SetWidgetVisible(self.UIRoot.TextBlock_2, false)
  local hideHelpBtn = false
  if region == PublishRegionMacros.VNG then
    hideHelpBtn = true
  end
  self:SetWidgetVisible(self.UIRoot.btnHelpLogin, not hideHelpBtn, true)
  local ban_login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ban_login_module)
  if ban_login_module.forceRepair then
    self:AddTimerOnce(0, function()
      UIManager.ShowUI(UIManager.UI_Config.login_forcerepair)
    end)
  end
  self:AddTimerOnce(0.5, function()
    local guestFind = require("client.slua.logic.guest_bind.logic_guest_find")
    guestFind.ShowSuccess()
  end)
  if Client.IsMatchVersion() then
    self:SetLoginMode(ENUM_LOGIN_MODE.Selecting)
  else
    self:SetLoginMode(ENUM_LOGIN_MODE.ByChannel)
  end
  self:GetSavedLoginCountAndTime()
  if not Client.IsDevelopment() then
    PufferUpdater.CheckCorrupted()
    if PufferUpdater.needRestartAfterDeleteCorruptFile then
      self.autoLogin = false
      login_module:OnRestartGame()
    end
  end
  self.AnimaPlayPromise = self:PlayAnimationWithPromise("Fadein", 0, 1, 0, 1)
  self:RefreshUI()
  self:CheckAccountAutoLogin()
  local Logic_Mini_Pak_Gem = require("client.slua.logic.download.report.logic_mini_pak_gem")
  Logic_Mini_Pak_Gem.ReportGemLog("ReturnLogin")
  log_shipping_client(bWriteLog and "rain profile VersionUpdate -> Login")
  self:EnsureSettingCrashMsg()
  local auto_login_tools = RequireBlackList("blacklist.Login.auto_login_tools")
  if auto_login_tools then
    auto_login_tools.StartAutoLogin()
    auto_login_tools.ProcMainCityGM()
  end
  require("client.logic.bp_adapter.adapter_gyroscope")
  local MainCityConfig = require("GameLua.Mod.MainCity.Gameplay.Config.MainCityConfig")
  if MainCityConfig.bOptimization then
    FuncUtil.UE4ExecuteConsoleCommand("ini.IniCacheEnable 1")
  end
  self:SetWidgetVisible(self.UIRoot.Button_Bulletin, false)
  self:SetWidgetVisible(self.UIRoot.TextBlock_Bulletin, false)
  if self.UIRoot.TextBlock_Bulletin then
    self.UIRoot.TextBlock_Bulletin:SetText(LocUtil.GetLocalizeResStr(655665))
  end
  login_module:PreLoadAssets()
  xpcall(self.CheckAndShowTimeStamp, utility.ErrorMessageHandler, self)
  self:BlockEntrances()
  self:WoWEditorAutoLogin()
end
function Login_UIBP:RegistEvents()
  Login_UIBP.__super.RegistEvents(self)
  self.LoopScrollBox_Channel = self:InitChildClassScrollBox(self.UIRoot.LoopScrollBox_Channel, "client.slua.umg.NewLogin.Login_BtnItemUIBP")
  self:AddOnClickedEventByControl(self.UIRoot.Button_Service_Privacy, self.ShowPrivacyPolicy, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Privacy, self.CheckPrivacyPolicy, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Service_Agreement, self.ShowUserAgreement, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Agreement, self.CheckUserAgreement, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Clause, self.CheckageClause, self)
  self:AddOnClickedEventByControl(self.UIRoot.btnHelpLogin, self.OnClickHelpgBtn, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Language, self.OnClickLanguageBtn, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Repair, self.OnClickRepaireBtn, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_MORE, self.OnClickMoreLogin, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_CloseFBWebLogin, self.OnClickCloseFBWebLogin, self)
  self:AddControlEventByControl(self.UIRoot.FBWebLoginBrowser, "OnUrlChanged", self.OnFBWebloginUrlChanged, self)
  self:AddControlEventByControl(self.UIRoot.FBWebLoginBrowser, "OnHttpResponed", self.OnFBWebloginHttpResponed, self)
  self:AddCommonEvent(EVENTTYPE_NETWORK, EVENTID_LOBBY_SERVER_CONNECT_SUCCESS, self.OnConnectServerSuccess, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_LOADING_BEGIN, self.OnBeginLoadingLobby, self)
  self:AddCommonEvent(EVENTTYPE_SETTING, EVENTID_IEGAL_PRIVAY_CHOICE_CHANGE, self.OnPrivacyCheckChanged, self)
  self:AddCommonEvent(EVENTTYPE_SETTING, EVENTID_VERSION_UPDATE_IOS_CHECK, self.OnUpdateIOSCheck, self)
  self:AddCommonEvent(EVENTTYPE_LOGIN, EVENTID_LOGIN_FAIL_NETUTIL, self.OnMSDKLoginFail, self)
  self:AddCommonEvent(EVENTTYPE_LOGIN, EVENTID_LOGIN_WIN_FB_CALLBACK, self.OnFBWinLogin, self)
  if self.UIRoot.Button_BackToSelect then
    self:AddOnClickedEventByControl(self.UIRoot.Button_BackToSelect, self.OnClickBackToSelect, self)
  end
  if self.UIRoot.Button_LoginByChannel then
    self:AddOnClickedEventByControl(self.UIRoot.Button_LoginByChannel, self.OnClickLoginByChannel, self)
  end
  if self.UIRoot.Button_LoginByPassword then
    self:AddOnClickedEventByControl(self.UIRoot.Button_LoginByPassword, self.OnClickLoginByPassword, self)
  end
  if self.UIRoot.Button_NoAuthLogin then
    self:AddOnClickedEventByControl(self.UIRoot.Button_NoAuthLogin, self.OnClickNoAuthLogin, self)
  end
  if self.UIRoot.Button_OfflineServer then
    self:AddOnClickedEventByControl(self.UIRoot.Button_OfflineServer, self.OnClickOfflineServer, self)
  end
  if self.UIRoot.RichText_PrivacyPolicy then
    self:AddControlEventByControl(self.UIRoot.RichText_PrivacyPolicy, "OnHyperlinkClicked", self.OnHyperlinkClicked, self)
  end
  local ClientEVOConfig = require("client.logic.client_evo_config.client_evo_config")
  ClientEVOConfig.Init()
end
function Login_UIBP:OnShow()
  Login_UIBP.__super.OnShow(self)
  self:HideContentPanelInCloudVersion()
  local logic_cloud_game = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cloud_game)
  if logic_cloud_game:GetCloudGameType() == logic_cloud_game.CLOUD_GAME_TYPE.WL_TIME then
    self:TryCloudVersionLogin()
  end
  if Client.IsWindows() and not IsWoWEditor then
    local world = slua.getWorld()
    local StreamingLevelsPrefix = world and world.StreamingLevelsPrefix
    log_format("Login_UIBP:OnShow. StreamingLevelsPrefix=%s", StreamingLevelsPrefix)
    if StreamingLevelsPrefix and not string.find(StreamingLevelsPrefix, "PIE") then
      local PufferSwitch = require("client.slua.logic.download.puffer_switch")
      PufferSwitch.BanDownload = true
      log_format("Login_UIBP:OnShow. PufferSwitch.BanDownload")
    end
  end
end
function Login_UIBP:CheckAndShowTimeStamp()
  local logic_loginlobby_timestamp = GetModuleForBlackList(ModuleManager.CommonModuleConfig.logic_loginlobby_timestamp)
  if not logic_loginlobby_timestamp then
    return
  end
  logic_loginlobby_timestamp:CheckAndShowUI()
end
function Login_UIBP:CheckageClause()
  self:PlayAudio(sound_config.click_v1)
  if self.ageClauseChecked == true then
    self.ageClauseChecked = false
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(0)
  else
    self.ageClauseChecked = true
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(1)
  end
end
function Login_UIBP:OnUpdateIOSCheck()
  self:UpdateUIByIOSCheck()
  self:UpdateLoginButtons()
end
function Login_UIBP:OnBeginLoadingLobby()
  self:CloseSelf()
end
function Login_UIBP:OnConnectServerSuccess()
  log(bWriteLog and "Login_UIBP:OnConnectServerSuccess")
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  if login_module.nReportedSkippedError and not self.reportedConnectSuccess then
    local param = {
      error_code = tostring(login_module.nReportedSkippedError),
      type = "2"
    }
    log(bWriteLog and "Login_UIBP:OnConnectServerSuccess, report connected after update error.")
    Client.GEMReportEvent(GameFrontendHUD, "71XButHasNet", param)
    login_module:SetReportedSkippedError(nil)
    self.reportedConnectSuccess = true
  end
end
function Login_UIBP:OnClickLogin(channel)
  log_warning(bWriteLog and "Login_UIBP:OnClickLogin, channel = " .. tostring(channel))
  if channel == ShareSource.Facebook and Client.IsWindows() and not IsWoWEditor then
    local WinLoginSystem = require("client.logic.login.logic_winlogin")
    WinLoginSystem.LoginFacebook()
    return
  end
  if channel == "phonemail" and Client.IsWindowOB() then
    self:OnClickWinMailLogin()
    return
  end
  local version_up_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.version_up_module)
  if version_up_module:CheckContinueUpdate() then
    return
  end
  local LeagalMsgSystem = require("client.slua.logic.common.logic_common_legal_msg")
  LeagalMsgSystem.SetEnableSyncAvatarInfo()
  self.loginChannel = channel
  self:PlayAudio(sound_config.click_v1)
  local BusinessHelper = import("BusinessHelper")
  local haveBasePak = BusinessHelper.HasDownloadedBasePak()
  if haveBasePak then
    if channel == ShareSource.Noschat then
      if slua_GameFrontendHUD and slua_GameFrontendHUD:IsInstallPlatform(ShareSource.Noschat) then
        self:Login()
      else
        local title = ""
        local msg = LocUtil.GetLocalizeResStr(110126)
        CommonMsgBoxMgr.Show(1, title, msg)
      end
    elseif channel == ShareSource.VK then
      if slua_GameFrontendHUD and slua_GameFrontendHUD:IsInstallPlatform(ShareSource.VK) then
        self:Login()
      else
        local title = ""
        local msg = LocUtil.GetLocalizeResStr(4303)
        CommonMsgBoxMgr.Show(1, title, msg)
      end
    else
      self:Login()
    end
  else
    self:ShowHelpshiftConversion()
    local param = {}
    Client.GEMReportEvent(GameFrontendHUD, "LoginWithoutBase", param)
  end
end
function Login_UIBP:AllPrivacyHasChecked()
  if not self.bPrivacyChecked then
    return false
  else
    local LeagalMsgSystem = require("client.slua.logic.common.logic_common_legal_msg")
    if LeagalMsgSystem.CheckNeedPopLegalMsgUI() then
      log_warning(bWriteLog and " [v_wllwu] NewLoginUI:CheckNeedPopLegalMsgUI is true")
      return false
    end
  end
  return true
end
function Login_UIBP:Login()
  log(bWriteLog and "Login_UIBP:Login")
  log_shipping_client(bWriteLog and "rain profile Login -> Lobby start")
  if IsWoWEditor then
    self:LoginImplementation()
    return
  end
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  if isKorea then
    if self.ageClauseChecked then
      if self:AllPrivacyHasChecked() then
        if self.bUserAgreementChecked then
          local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
          local TimeUtil = require("client.common.time_util")
          local curTime = TimeUtil.FormatTime_YMDHMS(TimeUtil.OSTime(), true)
          tlog_report_utils.ReportTLogEvent(TLogEventDefine.KoreaAgeLimite, 0, curTime)
          if region == PublishRegionMacros.VNG then
            if GlobalData.IsIOSCheck() or login_module.playerData.isVNGAdult then
              self:LoginImplementation()
            else
              local GdprSystem = require("client.slua.logic.gdpr.logic_gdpr")
              GdprSystem.TryToShowVNGBirthPanel()
            end
          else
            self:LoginImplementation()
          end
        else
          self:PopupUserAgreement(function()
            self:AfterAcceptUserAgreement()
          end)
        end
      else
        self:PopupPrivacyPolicy(function()
          self:TryAfterAcceptPrivacyPolicy()
        end)
      end
    else
      self:PopupageClause()
    end
  elseif self:AllPrivacyHasChecked() then
    if self.bUserAgreementChecked then
      if region == PublishRegionMacros.VNG then
        if GlobalData.IsIOSCheck() or login_module.playerData.isVNGAdult then
          self:LoginImplementation()
        else
          local GdprSystem = require("client.slua.logic.gdpr.logic_gdpr")
          GdprSystem.TryToShowVNGBirthPanel()
        end
      else
        self:LoginImplementation()
      end
    else
      self:PopupUserAgreement(function()
        self:AfterAcceptUserAgreement()
      end)
    end
  else
    self:PopupPrivacyPolicy(function()
      self:TryAfterAcceptPrivacyPolicy()
    end)
  end
end
function Login_UIBP:TimeTips()
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.FormatTime_YMDHMS(TimeUtil.OSTime(), true)
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.KoreaAgeLimite, 0, curTime)
  local title = LocUtil.GetLocalizeResStr(101001)
  local notice = "\235\176\176\237\139\128\234\183\184\235\157\188\236\154\180\235\147\156 \235\170\168\235\176\148\236\157\188 \236\157\180\236\154\169 \236\149\189\234\180\128 \235\143\153\236\157\152 \n(\237\145\184\236\139\156 \236\149\140\235\166\188 \236\136\152\236\139\160 \235\143\153\236\157\152 \237\143\172\237\149\168) \235\176\143 \234\176\156\236\157\184\236\160\149\235\179\180 \236\136\152\236\167\145 \235\176\143 \236\157\180\236\154\169 \235\143\153\236\157\152\234\176\128 \236\178\152\235\166\172\235\144\152\236\151\136\236\138\181\235\139\136\235\139\164.\n " .. TimeUtil.OSDate("%Y\235\133\132/%m\236\155\148/%d\236\157\188/%H\236\139\156/%M\235\182\132")
  CommonMsgBoxMgr.Show(1, title, notice, function()
    self:LoginImplementation()
  end)
end
local local channel2BpVar = {
  scan = BP_ENUM_PLAYFORM_QRCODE,
  guest = BP_ENUM_PLAYFORM_TOURIST,
  facebook = BP_ENUM_PLAYFORM_BGBG,
  gamecenter = BP_ENUM_PLAYFORM_GAMECENTER,
  googleplay = BP_ENUM_PLAYFORM_GOOGLEPLAY,
  twitter = BP_ENUM_PLAYFORM_TWITTER,
  vk = BP_ENUM_PLAYFORM_VK,
  line = BP_ENUM_PLAYFORM_LINE,
  apple = BP_ENUM_PLAYFORM_AppleByiTOP,
  unifiedaccount = BP_ENUM_PLAYFORM_UnifiedAccountByiTOP,
  hms = BP_ENUM_PLAYFORM_HMSByiTOP,
  discord = BP_ENUM_PLAYFORM_DiscordByiTOP,
  [FuncUtil.GetKeywordByID(3377005)] = BP_ENUM_PLAYFORM_WX,
  [FuncUtil.GetKeywordByID(3377006)] = BP_ENUM_PLAYFORM_BGBGByiTOP,
  whatsapp = BP_ENUM_PLAYFORM_WHATSAPP,
  tiktok = BP_ENUM_PLAYFORM_TIKTOK
}
function Login_UIBP:LoginCoroutine()
  log(bWriteLog and "Login_UIBP:LoginCoroutine")
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  login_module:OnShowLogin()
  self.canAddLoginCount = true
  if self:CheckLoginFrequency() then
    return
  end
  if self.loginChannel == login_module.CPhone_mail then
    if PublishRegionMacros.IsBLUEHOLE() then
      UIManager.ShowUI(UIManager.UI_Config.LoginPhoneBH_UIBP)
    else
      local IMSDKHelper = import("IMSDKHelper")
      local IMSDKHelperInstance = IMSDKHelper.GetInstance()
      local localCacheLoginChannel = IMSDKHelperInstance:GetHDmpveChannelID()
      if self.bUnifiedAccountTryQuickLogin and localCacheLoginChannel == BP_ENUM_PLAYFORM_UnifiedAccountByiTOP then
        self.bUnifiedAccountTryQuickLogin = false
        log(bWriteLog and "Login_UIBP:LoginCoroutine UnifiedAccountByiTOP")
        local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
        self.autoLogin = false
        login_module:quickLogin()
      else
        LoginSubUIUtil.OpenMailLogin()
      end
    end
    login_module:SetLoginType(0)
  else
    local var = channel2BpVar[self.loginChannel]
    if var then
      login_module:SdkLogin(var)
    else
      log_warning(bWriteLog and "  :Login_UIBP:LoginCoroutine can\226\128\152t login var: " .. tostring(self.loginChannel))
    end
  end
  Client.CrashLog(NetInterface, 4, "Login", "StartLogin" .. tostring(self.loginChannel))
end
function Login_UIBP:GetLoginTime()
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.OSTime()
  local remainTime = math.abs(self.nLoginTime - curTime)
  if remainTime > BP_ENUM_LOGINLIMIT_TIME2 and curTime < self.nLoginTime then
    self.nLoginTime = curTime + BP_ENUM_LOGINLIMIT_TIME2
    local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
    login_module:SetPlayerData("LoginTime", self.nLoginTime)
    remainTime = BP_ENUM_LOGINLIMIT_TIME2
  end
  local min = math.floor(remainTime / 60)
  local sec = remainTime % 60
  local text = LocUtil.LocalizeResFormat(301162, min)
  if min == 0 then
    text = LocUtil.LocalizeResFormat(301163, sec)
  end
  log_warning(bWriteLog and "Login_UIBP:GetLoginTime, curTime = " .. tostring(curTime) .. ", text = " .. tostring(text))
  return curTime, text
end
function Login_UIBP:LoginFrequencyFast(title, text, shouldLogout)
  CommonMsgBoxMgr.Show(1, title, text, function()
    if shouldLogout then
      local SettingAccount = require("client.logic.setting.logic_setting_account")
      SettingAccount.ClientLogout()
    end
    self:ShowLoginButtons()
  end, nil, nil, nil, false, function()
    self:TimerInvoke()
  end)
end
function Login_UIBP:CheckLoginFrequency()
  log(bWriteLog and "Login_UIBP:CheckLoginFrequency")
  local curTime, text = self:GetLoginTime()
  if curTime > self.nLoginTime then
    return false
  end
  local title = LocUtil.GetLocalizeResStr(101001)
  if self.nLoginCount > BP_ENUM_LOGINLIMIT_COUNT2 then
    self:LoginFrequencyFast(title, text, true)
  elseif self.nLoginCount > BP_ENUM_LOGINLIMIT_COUNT1 then
    self:LoginFrequencyFast(title, text, false)
  end
  return true
end
function Login_UIBP:TimerInvoke()
  log(bWriteLog and "Login_UIBP:TimerInvoke")
  local curTime, text = self:GetLoginTime()
  if curTime > self.nLoginTime then
    CommonMsgBoxMgr.HidePanel()
    return
  end
  CommonMsgBoxMgr.UpdateMsg(text)
end
function Login_UIBP:LoginImplementation()
  log(bWriteLog and "Login_UIBP:LoginImplementation")
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  local startLogin = false
  if self.loginChannel == ShareSource.Guest then
    if login_module.playerData.GuestWarningAccepted then
      startLogin = true
    else
      startLogin = false
    end
  else
    startLogin = true
  end
  if startLogin then
    self:LoginCoroutine()
  else
    local acceptTouristNotice = function()
      login_module:SetPlayerData("GuestWarningAccepted", true)
      self:LoginImplementation()
    end
    local logic_cloud_game = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cloud_game)
    if logic_cloud_game:IsCloudVersion() then
      acceptTouristNotice()
    else
      local title = LocUtil.GetLocalizeResStr(101001)
      local content = LocUtil.GetLocalizeResStr(4647)
      local ok = LocUtil.GetLocalizeResStr(110036)
      CommonMsgBoxMgr.Show(1, title, content, acceptTouristNotice, nil, ok)
    end
  end
end
function Login_UIBP:ShowHelpshiftConversion()
  local title = LocUtil.GetLocalizeResStr(301137)
  local content = LocUtil.GetLocalizeResStr(5049)
  local helpLabel = LocUtil.GetLocalizeResStr(4539)
  local exitLabel = LocUtil.GetLocalizeResStr(4486)
  CommonMsgBoxMgr.Show(2, title, content, function()
    GameStatus.QuitGame()
  end, function()
    local time_ticker = require("common.time_ticker")
    if self.repairTimer ~= nil then
      time_ticker.RemoveTimer(self.repairTimer)
      self.repairTimer = nil
    end
    self.repairTimer = time_ticker.AddTimerOnce(1, function()
      self:ShowHelpshiftConversion()
      time_ticker.RemoveTimer(self.repairTimer)
      self.repairTimer = nil
    end)
    local LogicCustomerService = require("client.slua.logic.CustomerService.LogicCustomerService")
    LogicCustomerService.Open(LogicCustomerService.E_EntranceType.Login)
  end, exitLabel, helpLabel)
end
function Login_UIBP:OnClickHelpgBtn()
  log(bWriteLog and "Login_UIBP:OnClickHelpgBtn")
  local BasicDataTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataTLogReport)
  BasicDataTLogReport:ReportImmediate(TLogEventDefine.LoginHelp, 0)
  local LogicCustomerService = require("client.slua.logic.CustomerService.LogicCustomerService")
  if LogicCustomerService.CheckAppVersionShouldUseNewInterface() then
    LogicCustomerService.EnterNewHelp(LogicCustomerService.E_EntranceType.Login)
  else
    LogicCustomerService.HelpshiftShowFAQsWithInfo()
  end
  self:PlayAudio(sound_config.click_v1)
end
function Login_UIBP:OnClickLanguageBtn()
  log(bWriteLog and "Login_UIBP:OnClickLanguageBtn")
  Client.CrashLog(NetInterface, 4, "Login", "EnterLang")
  self:PlayAudio(sound_config.click_v1)
  UIManager.ShowUI(UIManager.UI_Config.ui_select_language, 0, true)
end
local ShowScanUI = function()
  local SettingAccount = require("client.logic.setting.logic_setting_account")
  local AllQRCodeLoginResults = SettingAccount.GetAllQRCodeLoginResults()
  if next(AllQRCodeLoginResults) then
    UIManager.ShowUI(UIManager.UI_Config.AccountScanLogin_UIBP)
  else
    UIManager.ShowUI(UIManager.UI_Config.Login_QRCode_Popup_UIBP)
  end
end
function Login_UIBP:OnClickRepaireBtn()
  log(bWriteLog and "Login_UIBP:OnClickRepaireBtn")
  self:PlayAudio(sound_config.click_v1)
  UIManager.ShowUI(UIManager.UI_Config.repair)
  Client.CrashLog(NetInterface, 4, "Login", "OnClickRepaireBtn")
end
function Login_UIBP:OnClickUniLogin()
  log(bWriteLog and "Login_UIBP:OnClickUniLogin")
  self:PlayAudio(sound_config.click_v1)
  self:OnClickLogin("phonemail")
end
function Login_UIBP:OnClickGuestLogin()
  self:OnClickLogin(ShareSource.Guest)
end
function Login_UIBP:OnClickBGBGLogin()
  self:OnClickLogin(ShareSource.BgBg)
end
function Login_UIBP:OnClickScanLogin()
  self:OnClickLogin(ShareSource.Scan)
end
function Login_UIBP:OnClickNosChatLogin()
  self:OnClickLogin(ShareSource.Noschat)
end
function Login_UIBP:OnClickVKLogin()
  self:OnClickLogin(ShareSource.VK)
end
function Login_UIBP:OnClickGPLogin()
  self:OnClickLogin(ShareSource.GooglePlay)
end
function Login_UIBP:OnClickGCLogin()
  self:OnClickLogin(ShareSource.GameCenter)
end
function Login_UIBP:OnClickLineLogin()
  self:OnClickLogin(ShareSource.Line)
end
function Login_UIBP:OnClickTwitterLogin()
  self:OnClickLogin(ShareSource.Twitter)
end
function Login_UIBP:OnClickFBLogin()
  self:OnClickLogin(ShareSource.Facebook)
end
function Login_UIBP:OnClickWinMailLogin()
  local WinLoginSystem = require("client.logic.login.logic_winlogin")
  local cacheData = WinLoginSystem.LoadMailLoginCache()
  if WinLoginSystem.IsMailLoginCacheValid(cacheData) then
    log(bWriteLog and string.format("Login_UIBP:OnClickWinMailLogin use local cache, openid=%s, localExpireTime=%s", tostring(cacheData.openid), tostring(cacheData.localExpireTime)))
    slua_GameFrontendHUD:SetAccountByWebLogin(42, cacheData.openid, cacheData.userid, cacheData.token, cacheData.expireTime)
    return
  end
  local authorUrlIndex = 3366196
  local BusinessHelper = import("BusinessHelper")
  if BusinessHelper.GetIMSDKEnv() == 0 then
    authorUrlIndex = 3366197
  end
  local authUrl = string.format("%s?did=%s", FuncUtil.GetDomainByID(authorUrlIndex), Client.GetPhoneDeviceID())
  log(bWriteLog and "Login_UIBP:OnClickWinMailLogin open login url: " .. authUrl)
  self.UIRoot.FBWebLoginBrowser:LoadURL(authUrl)
  self.UIRoot.WINSDKFacebookLoginContainer:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
end
function Login_UIBP:OnClickAppleLogin()
  self:OnClickLogin(ShareSource.Apple)
end
function Login_UIBP:OnClickWhatsAppLogin()
  self:OnClickLogin(ShareSource.Whatsapp)
end
function Login_UIBP:OnClickHMSLogin()
  self:OnClickLogin(ShareSource.Hms)
end
function Login_UIBP:OnClickDiscordLogin()
  self:OnClickLogin(ShareSource.Discord)
end
function Login_UIBP:OnClickTikTokLogin()
  self:OnClickLogin(ShareSource.TikTok)
end
function Login_UIBP:OnClickMoreLogin()
  log(bWriteLog and "Login_UIBP:OnClickMoreLogin")
  local logic_cloud_game = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cloud_game)
  local para
  if not logic_cloud_game:IsCloudVersion() then
    para = {
      LoginTypeList = self.loginChannels,
      FirstLoginChannel = self.firstLoginChannel or "",
      SecondLoginChannel = self.secondLoginChannel or "",
      ThirdLoginChannel = self.thirdLoginChannel or ""
    }
  else
    para = {
      LoginTypeList = self.loginChannels,
      FirstLoginChannel = self.loginChannels[1],
      SecondLoginChannel = self.loginChannels[2],
      ThirdLoginChannel = self.loginChannels[3]
    }
  end
  UIManager.ShowUI(UIManager.UI_Config.login_choice, para)
  self:PlayAudio(sound_config.click_v1)
end
function Login_UIBP:TryHideNotices()
  log(bWriteLog and "Login_UIBP:TryHideNotices")
  local NoticesModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NoticesModule)
  NoticesModule:ClearNoticesScene()
  UIManager.CloseUI(UIManager.UI_Config.Notices_Main_UIBP)
end
function Login_UIBP:RefreshUI()
  log_warning(bWriteLog and "Login_UIBP:RefreshUI")
  self:UpdateLoginButtons()
  self:UpdateUIByIOSCheck()
  self:UpdateLogo()
  self:UpdateVulkanFlag()
  self:UpdateDisplayVersion()
  self:UpdateUIByClientRegion()
  self:UpdatePrivacyPolicyCheckState()
  self:UpdateUserAgreementCheckState()
  self:UpdateQRCodeLogin()
  local ForcePopUpPrivacyPolicyAcceptedCallback = function()
    self.bPrivacyChecked = true
    if self.UIRoot then
      self.UIRoot.WidgetSwitcher_PrivacyCheckBox:SetActiveWidgetIndex(1)
    end
    local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
    login_module:SetPlayerData("PrivacyPolicyAcceptedVersion", self.nPrivacyVersion)
    local BusinessHelper = import("BusinessHelper")
    local haveBasePak = BusinessHelper.HasDownloadedBasePak()
    if self:AllPrivacyHasChecked() and self.bUserAgreementChecked and haveBasePak then
      self.autoLogin = false
      login_module:quickLogin()
    end
  end
  self:ShowNoticeBeforeLogin()
  if self.bNeedPopupPrivacy then
    self.bNeedPopupPrivacy = false
    self:PopupPrivacyPolicy(ForcePopUpPrivacyPolicyAcceptedCallback)
  end
  self:CheckCPUArchMisMatch()
  local GdprSystem = require("client.slua.logic.gdpr.logic_gdpr")
  GdprSystem.CloseAllGDPRUI()
end
function Login_UIBP:UpdateUIByIOSCheck()
  local result = GlobalData.IsIOSCheck()
  log_warning(bWriteLog and "Login_UIBP:UpdateUIByIOSCheck, result = " .. tostring(result))
  if result then
    self:SetWidgetVisible(self.UIRoot.Button_Repair, false)
    self:SetWidgetVisible(self.UIRoot.btnHelpLogin, false)
    self:SetWidgetVisible(self.UIRoot.age18, false)
  end
end
function Login_UIBP:AutoLoginWhenNeed()
  local platformName = Client.GetDevicePlatformName()
  log_warning(bWriteLog and "Login_UIBP:AutoLoginWhenNeed, autoLogin = " .. tostring(self.autoLogin) .. ", platformName = " .. tostring(platformName))
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if DevicePlatformNameMacros.IsPC() then
  elseif self.autoLogin == true then
    local BusinessHelper = import("BusinessHelper")
    local haveBasePak = BusinessHelper.HasDownloadedBasePak()
    if self:AllPrivacyHasChecked() and self.bUserAgreementChecked == true and haveBasePak then
      self.autoLogin = false
      local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
      login_module:quickLogin()
    end
  end
end
local buttons = {
  "HorizontalBox_autoHide_2",
  "Panel_LoginBtn",
  "HorizontalBox_autoHide_3"
}
function Login_UIBP:ShowLoginButtons()
  log(bWriteLog and "Login_UIBP:ShowLoginButtons")
  if not self.UIRoot then
    return
  end
  logic_connection_waiting:Hide(1)
  if _G.bFromLauncher then
    return
  end
  local root = self.UIRoot
  for _, name in ipairs(buttons) do
    self:SetWidgetVisible(root[name], true)
  end
  local TableUtil = require("common.table_util")
  local num = TableUtil.CountTable(self.loginChannels)
  self:SetWidgetVisible(root.Button_MORE, 1 < num, true)
  if root.WidgetSwitcher_LoginMode then
    root.WidgetSwitcher_LoginMode:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
end
function Login_UIBP:HideLoginButtons()
  log(bWriteLog and "Login_UIBP:HideLoginButtons")
  logic_connection_waiting:Show(1)
  local root = self.UIRoot
  for _, name in ipairs(buttons) do
    self:SetWidgetVisible(root[name], false)
  end
  if root.WidgetSwitcher_LoginMode then
    self:SetWidgetVisible(root.WidgetSwitcher_LoginMode, false)
  end
end
function Login_UIBP:UpdateLogo()
  if region == PublishRegionMacros.BLUEHOLE then
    self.UIRoot.WidgetSwitcher_Logo:SetActiveWidgetIndex(1)
  end
end
function Login_UIBP:UpdateVulkanFlag()
  local STExtraGameInstance = import("STExtraGameInstance")
  if STExtraGameInstance then
    local gameInstance = STExtraGameInstance.GetInstance()
    local bVulkan = gameInstance:IsRunningOnVulkan()
    Client.CrashLog(NetInterface, 4, "Login", "IsRunningOnVulkan:" .. tostring(bVulkan))
  end
  self:SetWidgetVisible(self.UIRoot.TURBO, false)
end
function Login_UIBP:UpdateDisplayVersion()
  local version = Client.GetAppVersion()
  log_warning(bWriteLog and "Login_UIBP:UpdateDisplayVersion, version = " .. tostring(version))
  if Client.GetLoginChannel(NetInterface) == 0 then
    self.isTokenValid = 0
  else
    self.isTokenValid = 1
  end
  local isEmulator = Client.IsEmulatorWhenInit()
  log_warning(bWriteLog and "Login_UIBP:UpdateDisplayVersion, isTokenValid = " .. tostring(self.isTokenValid) .. ", isEmulator = " .. tostring(isEmulator))
  self.UIRoot.TextBlock_Version:SetText(version)
end
function Login_UIBP:UpdateUIByClientRegion()
  log(bWriteLog and "Login_UIBP:UpdateUIByClientRegion")
  self:SetWidgetVisible(self.UIRoot.Image_25, isJk)
  self:SetWidgetVisible(self.UIRoot.TextGuestTips, isJk)
  local text = LocUtil.GetLocalizeResStr(4442)
  self.UIRoot.TextBlock_UserAgreement:SetText(text)
  if region ~= PublishRegionMacros.GLOBAL and region ~= PublishRegionMacros.FIT then
    if isJk then
      local language = Client.GetCurrentLanguage()
      if language == LanguageMacros.EN then
        self.UIRoot.TextBlock_UserAgreement:SetText("USER AGREEMENT")
      end
    elseif region == PublishRegionMacros.BLUEHOLE then
      local language = Client.GetCurrentLanguage()
      if language == LanguageMacros.EN then
        self.UIRoot.TextBlock_UserAgreement:SetText("TERMS OF SERVICE")
      end
    end
  end
  local path
  if region == PublishRegionMacros.TW then
    path = "/Game/UMG/Texture_200/Atlas/LoadingUI/Frames/LD_image_logo_TW_png.LD_image_logo_TW_png"
  else
    path = "/Game/UMG/Texture_200/Atlas/LoginUI/Frames/LOGIN_image_dataosha_png.LOGIN_image_dataosha_png"
  end
  local asset_util = require("common.asset_util")
  local sprite = asset_util.GetAssetSync(path)
  local PaperSpriteBlueprintLibrary = import("PaperSpriteBlueprintLibrary")
  local brush = PaperSpriteBlueprintLibrary.MakeBrushFromSprite(sprite, 0, 0)
  self.UIRoot.Image_logo:SetBrush(brush)
  local _18X = region == PublishRegionMacros.VNG and GlobalData.IsIOSCheck() == false
  self:SetWidgetVisible(self.UIRoot.age18, _18X)
end
function Login_UIBP:UpdateLoginButtons()
  log(bWriteLog and "Login_UIBP:UpdateLoginButtons")
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  self.loginChannels = login_module:GetLoginTypeList()
  log_tree("self.loginChannels", self.loginChannels)
  self.useRecommendMode = false
  local recommendStatus, recommendList = login_module:GetRecommendLoginChannels()
  local logic_cloud_game_forCheck = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cloud_game)
  if recommendStatus == login_module.RecommendStatus.Succeed and recommendList and 0 < #recommendList and not logic_cloud_game_forCheck:IsCloudVersion() and not self:_HasSpecialCaseOverride() then
    log(bWriteLog and "Login_UIBP:UpdateLoginButtons - use ITOP recommend channels")
    self:_ApplyRecommendChannels(recommendList)
    return
  end
  log(bWriteLog and string.format("Login_UIBP:UpdateLoginButtons - fallback to legacy, recommendStatus=%s", tostring(recommendStatus)))
  for _, v in pairs(self.loginChannels) do
    if login_module:IsAvailableChannel(v) then
      self.firstLoginChannel = v
      break
    end
  end
  self.secondLoginChannel = ""
  log_warning(bWriteLog and "  : self.firstLoginChannel: " .. tostring(self.firstLoginChannel))
  local last = self:GetSavedLoginChanel()
  if last ~= "" and last ~= self.firstLoginChannel then
    self.secondLoginChannel = last
  else
    for _, v in pairs(self.loginChannels) do
      if login_module:IsAvailableChannel(v) and self.firstLoginChannel ~= v and self.secondLoginChannel == "" then
        self.secondLoginChannel = v
        break
      end
    end
  end
  log_warning(bWriteLog and "  : self.secondLoginChannel: " .. tostring(self.secondLoginChannel))
  local logic_cloud_game = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cloud_game)
  local btns = {}
  local hasAddGuest
  if not logic_cloud_game:IsCloudVersion() then
    if self.secondLoginChannel ~= "" then
      btns[#btns + 1] = self.secondLoginChannel
    end
    if self.firstLoginChannel ~= "" then
      btns[#btns + 1] = self.firstLoginChannel
    end
    if isJk and self.firstLoginChannel ~= ShareSource.Guest and self.secondLoginChannel ~= ShareSource.Guest then
      btns[#btns + 1] = ShareSource.Guest
      hasAddGuest = true
    end
    if isBlueHole then
      local bDisable = Client.HDmpveRemoteConfigGetInt("OpenBlueHoleWhatsApp", 0) == 1
      log_format("Login_UIBP:UpdateLoginButtons. bDisable: %s", bDisable)
      if bDisable then
        if self.firstLoginChannel ~= ShareSource.Whatsapp and self.secondLoginChannel ~= ShareSource.Whatsapp then
          if login_module:IsAvailableChannel(ShareSource.Whatsapp) then
            btns[#btns + 1] = ShareSource.Whatsapp
          end
        else
          for _, v in pairs(self.loginChannels) do
            if v ~= self.firstLoginChannel and v ~= self.secondLoginChannel and login_module:IsAvailableChannel(v) then
              btns[#btns + 1] = v
              self.thirdLoginChannel = v
              break
            end
          end
        end
      end
    end
    if login_module:CanShowPhoneMailLogin() then
      btns[#btns + 1] = login_module.CPhone_mail
    end
  elseif self.loginChannels then
    for i = 1, 3 do
      if self.loginChannels[i] then
        btns[#btns + 1] = self.loginChannels[i]
      end
    end
  end
  local device_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.device_module)
  local StringUtil = require("common.string_util")
  if StringUtil.StrFind(device_module.sDeviceName, "matrix") then
    log(bWriteLog and "Login_UIBP:UpdateLoginButtons.  is matrix")
    if self.firstLoginChannel ~= ShareSource.Guest and self.secondLoginChannel ~= ShareSource.Guest and not hasAddGuest then
      btns[#btns + 1] = ShareSource.Guest
      log(bWriteLog and "Login_UIBP:UpdateLoginButtons.  add guest")
    end
  end
  if login_module.nLastIsScan == 1 then
    btns[1] = ShareSource.Scan
    self.secondLoginChannel = ShareSource.Scan
  end
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if DevicePlatformNameMacros.IOS == Client.GetDevicePlatformName() and GlobalData.IsIOSCheck() and not login_module.bBanIOSCheckAppleFirstLogin and btns[1] ~= ShareSource.Apple then
    local appleIndex = 0
    for i, v in ipairs(btns) do
      if v == ShareSource.Apple then
        appleIndex = i
        break
      end
    end
    if 0 < appleIndex then
      table.remove(btns, appleIndex)
    end
    table.insert(btns, 1, ShareSource.Apple)
    self.firstLoginChannel = ShareSource.Apple
  end
  if not self.thirdLoginChannel or self.thirdLoginChannel == "" then
    self.thirdLoginChannel = btns[3] or ""
  end
  log_tree("btns", btns)
  log_warning(bWriteLog and "  : #btns: " .. tostring(#btns))
  local DoSetButtonData = function()
    self.LoopScrollBox_Channel:SetData(btns)
    self:ShowLoginButtons()
  end
  if self.AnimaPlayPromise and self.AnimaPlayPromise.status == "pending" then
    log(bWriteLog and "Login_UIBP:UpdateLoginButtons - Waiting for animation to complete")
    self.AnimaPlayPromise:Then(function()
      DoSetButtonData()
    end):Catch(function(error)
      log(bWriteLog and string.format("Login_UIBP:UpdateLoginButtons - Animation failed: %s", error))
      DoSetButtonData()
    end)
  else
    log(bWriteLog and "Login_UIBP:UpdateLoginButtons - Animation completed or not exist, update immediately")
    DoSetButtonData()
  end
end
function Login_UIBP:_HasSpecialCaseOverride()
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  if login_module.nLastIsScan == 1 then
    log(bWriteLog and "Login_UIBP:_HasSpecialCaseOverride - nLastIsScan = 1")
    return true
  end
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if DevicePlatformNameMacros.IOS == Client.GetDevicePlatformName() and GlobalData.IsIOSCheck() and not login_module.bBanIOSCheckAppleFirstLogin then
    log(bWriteLog and "Login_UIBP:_HasSpecialCaseOverride - iOS review build")
    return true
  end
  if isBlueHole and Client.HDmpveRemoteConfigGetInt("OpenBlueHoleWhatsApp", 0) == 1 then
    log(bWriteLog and "Login_UIBP:_HasSpecialCaseOverride - BlueHole WhatsApp switch on")
    return true
  end
  local device_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.device_module)
  local StringUtil = require("common.string_util")
  if device_module and device_module.sDeviceName and StringUtil.StrFind(device_module.sDeviceName, "matrix") then
    log(bWriteLog and "Login_UIBP:_HasSpecialCaseOverride - matrix device")
    return true
  end
  return false
end
function Login_UIBP:_ApplyRecommendChannels(recommendList)
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  local btns = {}
  local inBtns = {}
  local tryAppend = function(ch)
    if not ch or ch == "" then
      return false
    end
    if ch == ShareSource.Google then
      ch = ShareSource.GooglePlay
    end
    if inBtns[ch] then
      return false
    end
    if not self:IsOneOfConfigChannel(ch) then
      log(bWriteLog and "Login_UIBP:_ApplyRecommendChannels tryAppend - not in config, ch=" .. tostring(ch))
      return false
    end
    if not login_module:IsAvailableChannel(ch) then
      log(bWriteLog and "Login_UIBP:_ApplyRecommendChannels tryAppend - not available, ch=" .. tostring(ch))
      return false
    end
    btns[#btns + 1] = ch
    inBtns[ch] = true
    return true
  end
  for _, ch in ipairs(recommendList) do
    if 3 <= #btns then
      break
    end
    tryAppend(ch)
  end
  log_tree("Login_UIBP:_ApplyRecommendChannels after ITOP", btns)
  for _, ch in pairs(self.loginChannels) do
    if 3 <= #btns then
      break
    end
    tryAppend(ch)
  end
  if #btns < 3 and isJk then
    tryAppend(ShareSource.Guest)
  end
  if #btns < 3 and isBlueHole then
    local bDisable = Client.HDmpveRemoteConfigGetInt("OpenBlueHoleWhatsApp", 0) == 1
    if bDisable then
      tryAppend(ShareSource.Whatsapp)
    end
  end
  if #btns < 3 and login_module:CanShowPhoneMailLogin() then
    tryAppend(login_module.CPhone_mail)
  end
  local device_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.device_module)
  local StringUtil = require("common.string_util")
  if #btns < 3 and device_module and device_module.sDeviceName and StringUtil.StrFind(device_module.sDeviceName, "matrix") then
    tryAppend(ShareSource.Guest)
  end
  self.firstLoginChannel = btns[1] or ""
  self.secondLoginChannel = btns[2] or ""
  self.thirdLoginChannel = btns[3] or ""
  self.useRecommendMode = true
  log_tree("Login_UIBP:_ApplyRecommendChannels final btns", btns)
  log_warning(bWriteLog and "Login_UIBP:_ApplyRecommendChannels count: " .. tostring(#btns))
  local DoSetButtonData = function()
    self.LoopScrollBox_Channel:SetData(btns)
    self:ShowLoginButtons()
  end
  if self.AnimaPlayPromise and self.AnimaPlayPromise.status == "pending" then
    log(bWriteLog and "Login_UIBP:_ApplyRecommendChannels - waiting animation")
    self.AnimaPlayPromise:Then(function()
      DoSetButtonData()
    end):Catch(function(err)
      log(bWriteLog and "Login_UIBP:_ApplyRecommendChannels - animation failed: " .. tostring(err))
      DoSetButtonData()
    end)
  else
    DoSetButtonData()
  end
end
local canSaveChannelTb = {
  gamecenter = 1,
  googleplay = 1,
  google = 1,
  facebook = 1,
  discord = 1,
  guest = 1,
  twitter = 1,
  line = 1,
  apple = 1,
  whatsapp = 1,
  tiktok = 1
}
local canSaveChannelNeedInstall = {
  [FuncUtil.GetKeywordByID(3377005)] = 1,
  [FuncUtil.GetKeywordByID(3377006)] = 1,
  vk = 1,
  tiktok = 1
}
function Login_UIBP:GetSavedLoginChanel()
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  if login_module.gmLoginChannel then
    log(bWriteLog and "  Login_UIBP:GetSavedLoginChanel.  use gm")
    return login_module.gmLoginChannel
  end
  local channel = ""
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  if IMSDKHelperInstance ~= nil then
    local channelId = IMSDKHelperInstance:GetLastIMSDKChannelID()
    local channelStr = IMSDKHelperInstance:ConvertIMSDKChannelToStr(channelId, false)
    log_warning(bWriteLog and "  Login_UIBP:GetSavedLoginChanel. channelStr " .. tostring(channelStr))
    if channelStr == ShareSource.Google then
      channel = ShareSource.GooglePlay
    end
    if channelStr and self:IsOneOfConfigChannel(channelStr) then
      log_warning(bWriteLog and "  Login_UIBP:GetSavedLoginChanel. channelStr " .. tostring(channelStr))
      log_warning(bWriteLog and "  Login_UIBP:GetSavedLoginChanel. canSaveChannelTb[channelStr] " .. tostring(canSaveChannelTb[channelStr]))
      if canSaveChannelTb[channelStr] then
        log_warning(bWriteLog and "Login_UIBP:GetSavedLoginChanel, canSaveChannelTb channel = " .. tostring(channelStr))
        return channelStr
      elseif canSaveChannelNeedInstall[channelStr] then
        if slua_GameFrontendHUD and slua_GameFrontendHUD:IsInstallPlatform(channelStr) then
          log_warning(bWriteLog and "Login_UIBP:GetSavedLoginChanel, canSaveChannelNeedInstall channel = " .. tostring(channelStr))
          return channelStr
        end
      elseif channelStr == ShareSource.Hms then
        local BusinessHelper = import("BusinessHelper")
        if BusinessHelper ~= nil and BusinessHelper.GetAOSSHOPID() == 6 then
          channel = ShareSource.Hms
        end
      end
    end
  end
  log_warning(bWriteLog and "Login_UIBP:GetSavedLoginChanel, channel = " .. tostring(channel))
  return channel
end
function Login_UIBP:IsOneOfConfigChannel(strChannel)
  local result = false
  for _, v in pairs(self.loginChannels) do
    if v == strChannel then
      result = true
      break
    end
  end
  log_warning(bWriteLog and "Login_UIBP:IsOneOfConfigChannel, channel = " .. tostring(strChannel) .. ", result = " .. tostring(result))
  return result
end
local noPopupPrivacyPolicy = {
  JAPAN = 1,
  KOREA = 1,
  VNG = 1,
  TW = 1
}
function Login_UIBP:UpdatePrivacyPolicyCheckState()
  if not isBlueHole then
    if isKorea then
      self.UIRoot.WidgetSwitcher_1:SetActiveWidgetIndex(1)
      local language = Client.GetCurrentLanguage()
      if language == LanguageMacros.EN then
        self.UIRoot.RichText_PrivacyPolicy:SetText("For details on how we process personal information, please refer to our [Privacy Policy <a id=\"HyperlinkDecorator\" style=\"New_MailLink\" url=\"https://esports.pubgmobile.kr/ko/policy/privacy/latest\">(LINK)</>].")
      else
        self.UIRoot.RichText_PrivacyPolicy:SetText("\234\176\156\236\157\184\236\160\149\235\179\180 \236\178\152\235\166\172\236\151\144 \234\180\128\237\149\156 \236\130\172\237\149\173\236\157\128 \234\176\156\236\157\184\236\160\149\235\179\180 \236\178\152\235\166\172\235\176\169\236\185\168<a id=\"HyperlinkDecorator\" style=\"New_MailLink\" url=\"https://esports.pubgmobile.kr/ko/policy/privacy/latest\">(LINK)</>\235\165\188 \237\153\149\236\157\184\237\149\180\236\163\188\236\132\184\236\154\148.")
      end
    elseif self.UIRoot.WidgetSwitcher_1 then
      self.UIRoot.WidgetSwitcher_1:SetActiveWidgetIndex(0)
    end
  end
  self.UIRoot.TextBlock_3:SetText(LocUtil.GetLocalizeResStr(11082))
  self.nPrivacyVersion = 0
  self.nNeedPrivacyVersion = 0
  local long_txt_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.long_txt_manager)
  self.nPrivacyVersion = long_txt_manager:GetPrivacyAgreementVersion()
  if not noPopupPrivacyPolicy[region] then
    self.nNeedPrivacyVersion = 8
  end
  self.bPrivacyChecked = false
  self.bNeedPopupPrivacy = false
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  local playerData = login_module.playerData
  self.bPrivacyChecked = self.nPrivacyVersion <= playerData.PrivacyPolicyAcceptedVersion
  self.bNeedPopupPrivacy = self.nNeedPrivacyVersion > (playerData.PrivacyPolicyPopupVersion or 0)
  self.bUnifiedAccountTryQuickLogin = self.bNeedPopupPrivacy or not self.bPrivacyChecked
  if self.bNeedPopupPrivacy then
    login_module:SetPlayerData("PrivacyPolicyPopupVersion", self.nNeedPrivacyVersion)
  end
  if region == PublishRegionMacros.VNG and (0 >= self.quickLoginHDmpveChannelID or login_module.bHasLogout) then
    self.bPrivacyChecked = false
    self.bNeedPopupPrivacy = true
  end
  if Client.IsWindowsClientReplay() or IsWoWEditor then
    log(bWriteLog and "Login_UIBP:UpdatePrivacyPolicyCheckState IsWindowsClientReplay or IsWoWEditor")
    self.bPrivacyChecked = true
    self.bNeedPopupPrivacy = false
  end
  if self.bPrivacyChecked then
    self.UIRoot.WidgetSwitcher_PrivacyCheckBox:SetActiveWidgetIndex(1)
  else
    self.UIRoot.WidgetSwitcher_PrivacyCheckBox:SetActiveWidgetIndex(0)
    if self.bNeedPopupPrivacy then
      self.autoLogin = false
    end
  end
  log_warning(bWriteLog and "Login_UIBP:UpdatePrivacyPolicyCheckState, privacyVersion = " .. tostring(self.nPrivacyVersion) .. ", needPopupVersion = " .. tostring(self.nNeedPrivacyVersion) .. ", privacyChecked = " .. tostring(self.bPrivacyChecked) .. ", needPopupPrivacy = " .. tostring(self.bNeedPopupPrivacy) .. ", autoLogin = " .. tostring(self.autoLogin))
end
function Login_UIBP:UpdateUserAgreementCheckState()
  self.UIRoot.TextBlock_24:SetText(LocUtil.GetLocalizeResStr(11083))
  self.UIRoot.TextBlock_AgeLimited:SetText(LocUtil.GetLocalizeResStr(48683))
  local long_txt_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.long_txt_manager)
  self.nUserAgreementVersion = long_txt_manager:GetUserAgreementVersion()
  self.bUserAgreementChecked = false
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  local saveGame = login_module.playerData
  if saveGame then
    self.bUserAgreementChecked = self.nUserAgreementVersion <= saveGame.UserAgreementAcceptedVersion
    self.ageClauseChecked = self.nUserAgreementVersion <= saveGame.UserAgreementAcceptedVersion
  end
  if region == PublishRegionMacros.VNG and (self.quickLoginHDmpveChannelID <= 0 or login_module.bHasLogout) then
    self.bUserAgreementChecked = false
  end
  if Client.IsWindowsClientReplay() then
    log(bWriteLog and "Login_UIBP:UpdateUserAgreementCheckState IsWindowsClientReplay")
    self.bUserAgreementChecked = true
  end
  if self.bUserAgreementChecked then
    self.UIRoot.WidgetSwitcher_AgreementCheckBox:SetActiveWidgetIndex(1)
  else
    self.UIRoot.WidgetSwitcher_AgreementCheckBox:SetActiveWidgetIndex(0)
  end
  if self.bUserAgreementChecked and isKorea then
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(1)
  else
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(0)
  end
  log_warning(bWriteLog and "Login_UIBP:UpdateUserAgreementCheckState, userAgreementVersion = " .. tostring(self.nUserAgreementVersion) .. ", userAgreementChecked = " .. tostring(self.bUserAgreementChecked))
end
function Login_UIBP:UpdateQRCodeLogin()
  if self.UIRoot.Button_QRCode then
    self:SetWidgetVisible(self.UIRoot.Button_QRCode, false)
  end
end
function Login_UIBP:GetSavedLoginCountAndTime()
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  local saveGame = login_module.playerData
  if saveGame then
    self.nLoginCount = saveGame.LoginCount or 0
    self.nLoginTime = saveGame.LoginTime or 0
  else
    self.nLoginCount = 0
    self.nLoginTime = 0
  end
  log_warning(bWriteLog and "Login_UIBP:GetSavedLoginCountAndTime, loginCount = " .. tostring(self.nLoginCount) .. ", loginTime = " .. tostring(self.nLoginTime))
end
function Login_UIBP:ShowNoticeBeforeLogin()
  log(bWriteLog and "Login_UIBP:ShowNoticeBeforeLogin")
  local doNext = function()
    local NoticesModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NoticesModule)
    local NoticesConst = require("client.logic.Notice.NoticesConst")
    if NoticesModule:CanShowNotice(NoticesConst.Scene.Login) then
      NoticesModule:ShowNotice(NoticesConst.Scene.Login)
    else
      local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
      login_module:ContinueLoginAfterNotice()
    end
  end
  local memoryStaus = Client.GetMemoryStats()
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local availablePhysical = memoryStaus.AvailablePhysical / PufferConst.MB
  if availablePhysical == 0 or 100 < availablePhysical then
    doNext()
  else
    local tip = LocUtil.GetLocalizeResStr(101014)
    local tipTitle = LocUtil.GetLocalizeResStr(101001)
    CommonMsgBoxMgr.Show(1, tipTitle, tip, doNext, doNext)
  end
end
function Login_UIBP:CheckCPUArchMisMatch()
  log(bWriteLog and "Login_UIBP:CheckCPUArchMisMatch - Start checking CPU architecture mismatch")
  local bMisMatch = Client.IsCPUArchMisMatch()
  if not bMisMatch then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local PlayerPrefsConfig = require("client.slua.config.PlayerPrefsConfig")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsConfig.CPUArchMisMatchNotice) or {}
  if cfg.noticed then
    return
  end
  local tipTitle = LocUtil.GetLocalizeResStr(101001)
  local notice = LocUtil.GetLocalizeResStr(578811)
  local saveCPUArchMisMatchNotice = function()
    cfg.noticed = true
    PlayerPrefsSystem.SaveTableToFile_N(cfg, PlayerPrefsConfig.CPUArchMisMatchNotice)
  end
  CommonMsgBoxMgr.Show(CommonMsgBoxMgr.SHOW_TYPE_ONE, tipTitle, notice, saveCPUArchMisMatchNotice, nil, nil, nil, {androidCallback = saveCPUArchMisMatchNotice})
end
function Login_UIBP:CheckPrivacyPolicy()
  self:PlayAudio(sound_config.click_v1)
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  if self.bPrivacyChecked == true then
    self.bPrivacyChecked = false
    self.UIRoot.WidgetSwitcher_PrivacyCheckBox:SetActiveWidgetIndex(0)
    login_module:SetPlayerData("PrivacyPolicyAcceptedVersion", 0)
  else
    self.bPrivacyChecked = true
    self.UIRoot.WidgetSwitcher_PrivacyCheckBox:SetActiveWidgetIndex(1)
    login_module:SetPlayerData("PrivacyPolicyAcceptedVersion", self.nPrivacyVersion)
  end
end
function Login_UIBP:ShowPrivacyPolicy()
  self:PlayAudio(sound_config.click_v1)
  local privacyCfg = CDataTable.GetTableData("PolicyUrlConfig", "Privacy_Policy")
  if privacyCfg and privacyCfg.JumpUrl then
    GlobalData.JumpUrl(privacyCfg.JumpUrl)
    log(bWriteLog and "Login_UIBP:ShowPrivacyPolicy Privacy_Policy config exists")
    return
  end
  local long_txt_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.long_txt_manager)
  local LeagalMsgSystem = require("client.slua.logic.common.logic_common_legal_msg")
  LeagalMsgSystem.ShowPrivacyPolicy()
end
function Login_UIBP:PopupageClause()
  local btnOKText = LocUtil.GetLocalizeResStr(29020)
  local btnCancleText = LocUtil.GetLocalizeResStr(4111)
  if region == PublishRegionMacros.BLUEHOLE then
    btnOKText = LocUtil.GetLocalizeResStr(117035)
  end
  local tips = ""
  local acceptClause = function()
    self:AfterAcceptageClause()
  end
  local rejectClause = function()
    local title = LocUtil.GetLocalizeResStr(101001)
    local text = LocUtil.GetLocalizeResStr(4485)
    local btnOK = LocUtil.GetLocalizeResStr(4410)
    local btnCancel = LocUtil.GetLocalizeResStr(4486)
    local GdprSystem = require("client.slua.logic.gdpr.logic_gdpr")
    GdprSystem.ShowSettingNoticeBox(0, title, text, btnCancel, btnOK, nil, function()
      self:PopupageClause()
    end)
  end
  local long_txt_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.long_txt_manager)
  local uTitle = long_txt_manager:GetageLimiteTitle()
  local uContent = long_txt_manager:GetageLimiteContent()
  local rejectClauseTemp
  if not noPopupPrivacyPolicy[region] then
    rejectClauseTemp = rejectClause
  end
  UIManager.ShowUI(UIManager.UI_Config.common_protocol_msg, 2, uTitle, uContent, tips, btnOKText, btnCancleText, acceptClause, rejectClauseTemp)
end
function Login_UIBP:PopupPrivacyPolicy(acceptCallback)
  local btnOKText = LocUtil.GetLocalizeResStr(301346)
  if region == PublishRegionMacros.BLUEHOLE then
    btnOKText = LocUtil.GetLocalizeResStr(117035)
  end
  local btnCancleText = LocUtil.GetLocalizeResStr(4111)
  local tips = LocUtil.GetLocalizeResStr(4431)
  local onReconsider = function()
    local StatManager = import("StatManager")
    StatManager.GetInstance():ReportEventWithNoParam(68, true)
    self:PopupPrivacyPolicy(acceptCallback)
  end
  local onExit = function()
    local StatManager = import("StatManager")
    StatManager.GetInstance():ReportEventWithNoParam(67, true)
  end
  local rejectPolicy = function()
    local title = LocUtil.GetLocalizeResStr(101001)
    local text = LocUtil.GetLocalizeResStr(4485)
    local btnOK = LocUtil.GetLocalizeResStr(4410)
    local btnCancel = LocUtil.GetLocalizeResStr(4486)
    local GdprSystem = require("client.slua.logic.gdpr.logic_gdpr")
    GdprSystem.ShowSettingNoticeBox(0, title, text, btnCancel, btnOK, onExit, onReconsider)
  end
  local acceptPolicy = acceptCallback or function()
    self.UIRoot.WidgetSwitcher_PrivacyCheckBox:SetActiveWidgetIndex(1)
    self.bPrivacyChecked = true
    local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
    login_module:SetPlayerData("PrivacyPolicyAcceptedVersion", self.nPrivacyVersion)
  end
  local LeagalMsgSystem = require("client.slua.logic.common.logic_common_legal_msg")
  if LeagalMsgSystem.CheckShowLegalUI(self.bPrivacyChecked, tips, btnOKText, btnCancleText, acceptPolicy, rejectPolicy) then
    log_warning(bWriteLog and "v_wllwu CheckShowLegalUI is true")
    return
  end
  local long_txt_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.long_txt_manager)
  local pTitle = long_txt_manager:GetPrivacyAgreementTitle()
  local pContent = long_txt_manager:GetPrivacyAgreementContent()
  if noPopupPrivacyPolicy[region] then
    UIManager.ShowUI(UIManager.UI_Config.common_protocol_msg, 2, pTitle, pContent, tips, btnOKText, btnCancleText, acceptPolicy)
  else
    UIManager.ShowUI(UIManager.UI_Config.common_protocol_msg, 2, pTitle, pContent, tips, btnOKText, btnCancleText, acceptPolicy, rejectPolicy)
  end
end
function Login_UIBP:TryAfterAcceptPrivacyPolicy()
  log(bWriteLog and "Login_UIBP:TryAfterAcceptPrivacyPolicy")
  local callback = function()
    self:AfterAcceptPrivacyPolicy()
  end
  local LeagalMsgSystem = require("client.slua.logic.common.logic_common_legal_msg")
  if LeagalMsgSystem.TryShowAfterShowInfoPopUp(callback) then
    log(bWriteLog and "Login_UIBP:TryAfterAcceptPrivacyPolicy ClearAfterChoosePrivacyFunc is true")
    return
  end
  callback()
end
function Login_UIBP:AfterAcceptPrivacyPolicy()
  if not self.UIRoot then
    return
  end
  self.UIRoot.WidgetSwitcher_PrivacyCheckBox:SetActiveWidgetIndex(1)
  self.bPrivacyChecked = true
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  login_module:SetPlayerData("PrivacyPolicyAcceptedVersion", self.nPrivacyVersion)
  if self.bUserAgreementChecked then
    if region == PublishRegionMacros.VNG then
      if GlobalData.IsIOSCheck() or login_module.playerData.isVNGAdult then
        self:LoginImplementation()
      else
        local GdprSystem = require("client.slua.logic.gdpr.logic_gdpr")
        GdprSystem.TryToShowVNGBirthPanel()
      end
    elseif isKorea then
      if self:PopupTimeTips() then
        self:TimeTips()
      end
    else
      self:LoginImplementation()
    end
  else
    self:PopupUserAgreement(function()
      self:AfterAcceptUserAgreement()
    end)
  end
end
function Login_UIBP:PopupTimeTips()
  if self.ageClauseChecked and self:AllPrivacyHasChecked() and self.bUserAgreementChecked then
    return true
  end
  return false
end
function Login_UIBP:CheckUserAgreement()
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  if self.bUserAgreementChecked == true then
    self.bUserAgreementChecked = false
    self.UIRoot.WidgetSwitcher_AgreementCheckBox:SetActiveWidgetIndex(0)
    login_module:SetPlayerData("UserAgreementAcceptedVersion", 0)
  else
    self.bUserAgreementChecked = true
    self.UIRoot.WidgetSwitcher_AgreementCheckBox:SetActiveWidgetIndex(1)
    login_module:SetPlayerData("UserAgreementAcceptedVersion", self.nUserAgreementVersion)
  end
  self:PlayAudio(sound_config.click_v1)
end
function Login_UIBP:ShowUserAgreement()
  self:PlayAudio(sound_config.click_v1)
  local privacyCfg = CDataTable.GetTableData("PolicyUrlConfig", "EULA")
  if privacyCfg and privacyCfg.JumpUrl then
    GlobalData.JumpUrl(privacyCfg.JumpUrl)
    log(bWriteLog and "Login_UIBP:ShowUserAgreement EULA config exists")
    return
  end
  GlobalData.JumpUrl("game://?module=" .. tostring(BP_ENUM_MODULE_LOGINUSERPROTOCOL))
end
function Login_UIBP:PopupUserAgreement(acceptPolicy)
  local btnOKText = LocUtil.GetLocalizeResStr(29020)
  local btnCancleText = LocUtil.GetLocalizeResStr(4111)
  if region == PublishRegionMacros.BLUEHOLE then
    btnOKText = LocUtil.GetLocalizeResStr(117035)
  end
  local tips = LocUtil.GetLocalizeResStr(7217)
  local rejectPolicy = function()
    local title = LocUtil.GetLocalizeResStr(101001)
    local text = LocUtil.GetLocalizeResStr(4485)
    local btnOK = LocUtil.GetLocalizeResStr(4410)
    local btnCancel = LocUtil.GetLocalizeResStr(4486)
    local GdprSystem = require("client.slua.logic.gdpr.logic_gdpr")
    GdprSystem.ShowSettingNoticeBox(0, title, text, btnCancel, btnOK, nil, function()
      self:PopupUserAgreement(function()
        self:AfterAcceptUserAgreement()
      end)
    end)
  end
  local long_txt_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.long_txt_manager)
  local uTitle = long_txt_manager:GetUserAgreementTitle()
  local uContent = long_txt_manager:GetUserAgreementContent()
  if noPopupPrivacyPolicy[region] then
    UIManager.ShowUI(UIManager.UI_Config.common_protocol_msg, 2, uTitle, uContent, tips, btnOKText, btnCancleText, acceptPolicy)
  else
    UIManager.ShowUI(UIManager.UI_Config.common_protocol_msg, 2, uTitle, uContent, tips, btnOKText, btnCancleText, acceptPolicy, rejectPolicy)
  end
end
function Login_UIBP:AfterAcceptUserAgreement()
  if not self.UIRoot then
    return
  end
  self.UIRoot.WidgetSwitcher_AgreementCheckBox:SetActiveWidgetIndex(1)
  self.bUserAgreementChecked = true
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  login_module:SetPlayerData("UserAgreementAcceptedVersion", self.nUserAgreementVersion)
  if region == PublishRegionMacros.VNG then
    if GlobalData.IsIOSCheck() or login_module.playerData.isVNGAdult then
      self:LoginImplementation()
    else
      local GdprSystem = require("client.slua.logic.gdpr.logic_gdpr")
      GdprSystem.TryToShowVNGBirthPanel()
    end
  elseif isKorea then
    if self:PopupTimeTips() then
      self:TimeTips()
    end
  elseif self:AllPrivacyHasChecked() then
    if isKorea then
      local title = LocUtil.GetLocalizeResStr(101001)
      local TimeUtil = require("client.common.time_util")
      local notice = "\235\176\176\237\139\128\234\183\184\235\157\188\236\154\180\235\147\156 \235\170\168\235\176\148\236\157\188 \236\157\180\236\154\169 \236\149\189\234\180\128 \235\143\153\236\157\152 \n(\237\145\184\236\139\156 \236\149\140\235\166\188 \236\136\152\236\139\160 \235\143\153\236\157\152 \237\143\172\237\149\168) \235\176\143 \234\176\156\236\157\184\236\160\149\235\179\180 \236\136\152\236\167\145 \235\176\143 \236\157\180\236\154\169 \235\143\153\236\157\152\234\176\128 \236\178\152\235\166\172\235\144\152\236\151\136\236\138\181\235\139\136\235\139\164.\n " .. TimeUtil.OSDate("%Y\235\133\132/%m\236\155\148/%d\236\157\188/%H\236\139\156/%M\235\182\132")
      CommonMsgBoxMgr.Show(1, title, notice, function()
        self:LoginImplementation()
      end)
    else
      self:LoginImplementation()
    end
  else
    self:PopupPrivacyPolicy(function()
      self:TryAfterAcceptPrivacyPolicy()
    end)
  end
end
function Login_UIBP:AfterAcceptageClause()
  self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(1)
  self.ageClauseChecked = true
  if self:PopupTimeTips() then
    self:TimeTips()
  else
    self:Login()
  end
end
function Login_UIBP:ClearLoginCountAndTime()
  self.nLoginCount = 0
  self.nLoginTime = 0
end
function Login_UIBP:UpdateLoginCountAndTime()
  local BusinessHelper = import("BusinessHelper")
  local networkState = BusinessHelper.GetCurrentNetworkState()
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  if networkState ~= 0 then
    if self.canAddLoginCount == true then
      self.nLoginCount = self.nLoginCount + 1
      login_module:SetPlayerData("LoginCount", self.nLoginCount, true)
      local TimeUtil = require("client.common.time_util")
      if self.nLoginCount > BP_ENUM_LOGINLIMIT_COUNT2 then
        self.nLoginTime = TimeUtil.OSTime() + BP_ENUM_LOGINLIMIT_TIME2
      elseif self.nLoginCount > BP_ENUM_LOGINLIMIT_COUNT1 then
        self.nLoginTime = TimeUtil.OSTime() + BP_ENUM_LOGINLIMIT_TIME1
      end
      login_module:SetPlayerData("LoginTime", self.nLoginTime)
    end
  else
    log(bWriteLog and "Login_UIBP:AddLoginCount, network is not reachable.")
  end
end
function Login_UIBP:OnClose()
  log(bWriteLog and "Login_UIBP:OnClose")
  logic_connection_waiting:Hide(1)
  if self.AnimaPlayPromise then
    self.AnimaPlayPromise:ClearCallbacks()
    self.AnimaPlayPromise = nil
  end
  self:TryHideNotices()
end
function Login_UIBP:OnClickCloseFBWebLogin()
  self:PlayAudio(sound_config.click)
  self:SetWidgetVisible(self.UIRoot.WINSDKFacebookLoginContainer, false)
end
function Login_UIBP:OnHyperlinkClicked(m_mete_data)
  local mete_data = m_mete_data.metaData
  if not mete_data then
    return
  end
  local url = mete_data:Get("url")
  if url and url ~= "" then
    GlobalData.JumpUrl(url)
  end
end
function Login_UIBP:OnFBWebloginUrlChanged(url)
  log_warning(bWriteLog and "OnFBWebloginUrlChanged: " .. tostring(url))
  local WinLoginSystem = require("client.logic.login.logic_winlogin")
  local retCode, iTopLoginUrl = WinLoginSystem.GetWinMSDKLoginURL(url)
  if retCode ~= -9999 then
    if retCode == "1" then
      if iTopLoginUrl ~= nil and string.len(iTopLoginUrl) > 0 then
        self.UIRoot.FBWebLoginBrowser:DoHttpRequest(iTopLoginUrl)
      end
    else
      log_warning(bWriteLog and "OnChangeFBWebloginUrlChanged:" .. tostring(url))
      local msg = "Facebook login failed: " .. tostring(retCode)
      self:ShowErrorTips(msg)
    end
    self.UIRoot.WINSDKFacebookLoginContainer:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  self:OnMailWebloginUrlChanged(url)
end
function Login_UIBP:OnMailWebloginUrlChanged(url)
  local WinLoginSystem = require("client.logic.login.logic_winlogin")
  log_warning(bWriteLog and "OnMailWebloginUrlChanged: " .. tostring(url))
  local params, retCode, token, openid, userid, expireTime, channelId = WinLoginSystem.GetWebMSDKLogin(url)
  if tonumber(retCode) == 1 then
    log_warning(bWriteLog and "OnMailWebloginUrlChanged: Login suc " .. tostring(retCode))
    self.UIRoot.WINSDKFacebookLoginContainer:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    WinLoginSystem.SaveMailLoginCache(channelId, openid, userid, token, expireTime)
    slua_GameFrontendHUD:SetAccountByWebLogin(42, openid, userid, token, expireTime)
  end
end
function Login_UIBP:OnFBWebloginHttpResponed(_, responedContent)
  local WinLoginSystem = require("client.logic.login.logic_winlogin")
  local code, openid, userid, token, expireTime = WinLoginSystem.GetWinLoginRet(responedContent)
  if code == 1 then
    WinLoginSystem.StopWS()
    slua_GameFrontendHUD:SetAccountByWebLogin(1, openid, userid, token, expireTime)
  else
    log_warning(bWriteLog and "Login_UIBP:OnFBWebloginHttpResponed:" .. tostring(responedContent))
    local msg = "Login failed: " .. tostring(code)
    self:ShowErrorTips(msg)
  end
end
function Login_UIBP:ShowErrorTips(msg)
  local title = "Login Failed"
  CommonMsgBoxMgr.Show(1, title, msg, nil)
end
function Login_UIBP:OnPrivacyCheckChanged(_, _, tabType, bCheck)
  local LeagalMsgSystem = require("client.slua.logic.common.logic_common_legal_msg")
  if tabType ~= LeagalMsgSystem.Enum_Tab_Choose.Privacy then
    return
  end
  if bCheck then
    self.bPrivacyChecked = true
    self.UIRoot.WidgetSwitcher_PrivacyCheckBox:SetActiveWidgetIndex(1)
  else
    self.bPrivacyChecked = false
    self.UIRoot.WidgetSwitcher_PrivacyCheckBox:SetActiveWidgetIndex(0)
  end
end
function Login_UIBP:InitializeUserSettingAndXYSystem()
  local logicSettingGraphics = require("client.slua.logic.setting.logic_setting_graphics")
  logicSettingGraphics.InitializeUserSetting()
  local AccelSystem = require("client.slua.logic.gamemaster.logic_accel")
  AccelSystem:Init()
  local SVPNSystem = require("client.slua.logic.gamemaster.logic_svpn")
  SVPNSystem:Init()
end
function Login_UIBP:EnsureSettingCrashMsg()
  local LoadGameSlotCrashInfo = Client.GetLoadGameSlotCrashInfo()
  if LoadGameSlotCrashInfo == "" then
    print(bWriteLog and "Login_UIBP:EnsureSettingCrashMsg LoadGameSlotCrashInfo=empty")
    return
  end
  print(bWriteLog and "Login_UIBP:EnsureSettingCrashMsg LoadGameSlotCrashInfo=" .. LoadGameSlotCrashInfo)
  local StringUtil = require("common.string_util")
  local Infos = StringUtil.Split(LoadGameSlotCrashInfo, "|")
  local bShowMsgBox = Infos[2] == "1"
  print(bWriteLog and "Login_UIBP:EnsureSettingCrashMsg bShowMsgBox=" .. tostring(bShowMsgBox))
  if bShowMsgBox then
    local Title = LocUtil.GetLocalizeResStr(43910)
    local Content = LocUtil.LocalizeResFormat(43906, Infos[4] or "")
    local OnClickFix = function()
      print(bWriteLog and "Login_UIBP:EnsureSettingCrashMsg OnClickFix")
      self:AutoLoginWhenNeed()
      Client.ClearHasLoadGameSlotCrashFlag()
      FixCrash = {
        OpenID = Infos[3]
      }
    end
    local OnClickLogin = function()
      print(bWriteLog and "Login_UIBP:EnsureSettingCrashMsg OnClickLogin")
      self:AutoLoginWhenNeed()
    end
    UIManager.ShowUI(UIManager.UI_Config.common_protocol_msg, 2, Title, Content, nil, LocUtil.GetLocalizeResStr(43909), LocUtil.GetLocalizeResStr(43908), OnClickFix, OnClickLogin)
  end
end
function Login_UIBP:OnMSDKLoginFail()
  local LoginTypeEventIDMap = {
    k2 = 69,
    k41 = 70,
    k42 = 71,
    k46 = 72
  }
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  local EventID = LoginTypeEventIDMap["k" .. tostring(login_module.nLoginType)]
  if EventID ~= nil and EventID ~= 0 then
    local StatManager = import("StatManager")
    StatManager.GetInstance():ReportEventWithNoParam(EventID, true)
  end
end
function Login_UIBP:OnFBWinLogin(_, _, url)
  self:OnFBWebloginUrlChanged(url)
end
function Login_UIBP:SetLoginMode(loginMode)
  local strRegion = Client.GetPublishRegion()
  if strRegion == PublishRegionMacros.BLUEHOLE then
    return
  end
  if not Client.IsMatchVersion() then
    loginMode = ENUM_LOGIN_MODE.ByChannel
  end
  self.curLoginMode = loginMode
  self:UpdateLoginModeUI()
end
function Login_UIBP:UpdateLoginModeUI()
  if not self.UIRoot.WidgetSwitcher_LoginMode then
    return
  end
  local bMatchVersion = Client.IsMatchVersion()
  if self.curLoginMode == ENUM_LOGIN_MODE.NoAuth then
    self.UIRoot.WidgetSwitcher_LoginMode:SetActiveWidgetIndex(1)
    self:SetWidgetVisible(self.UIRoot.Button_BackToSelect, bMatchVersion, true)
    self:RefreshNoAuthPanel()
  elseif self.curLoginMode == ENUM_LOGIN_MODE.Selecting then
    self.UIRoot.WidgetSwitcher_LoginMode:SetActiveWidgetIndex(2)
    self:SetWidgetVisible(self.UIRoot.Button_BackToSelect, false, true)
  else
    self.UIRoot.WidgetSwitcher_LoginMode:SetActiveWidgetIndex(0)
    self:SetWidgetVisible(self.UIRoot.Button_BackToSelect, bMatchVersion, true)
  end
  self.UIRoot.WidgetSwitcher_OfflineServer:SetActiveWidgetIndex(self.bUsingOfflineServer and 1 or 0)
  local logoSlot = self.UIRoot.WidgetSwitcher_Logo.Slot
  if slua.isValid(logoSlot) then
    if self.curLoginMode == ENUM_LOGIN_MODE.NoAuth then
      logoSlot:SetPadding(FMargin(0, 0, 0, 65))
    else
      logoSlot:SetPadding(FMargin(0, 0, 0, 0))
    end
  end
end
function Login_UIBP:OnClickBackToSelect()
  self:PlayAudio(sound_config.click_v1)
  self:SetLoginMode(ENUM_LOGIN_MODE.Selecting)
end
function Login_UIBP:OnClickLoginByChannel()
  self:PlayAudio(sound_config.click_v1)
  Client.SetMatchNoAuthMode(false)
  self:SetLoginMode(ENUM_LOGIN_MODE.ByChannel)
end
function Login_UIBP:OnClickLoginByPassword()
  self:PlayAudio(sound_config.click_v1)
  Client.SetMatchNoAuthMode(true)
  self:SetLoginMode(ENUM_LOGIN_MODE.NoAuth)
end
function Login_UIBP:RefreshNoAuthPanel()
  self.UIRoot.Login_InputOfflineLoginItem_UIBP_Username.WidgetSwitcher_Image:SetActiveWidgetIndex(1)
  self.UIRoot.Login_InputOfflineLoginItem_UIBP_Password.WidgetSwitcher_Image:SetActiveWidgetIndex(0)
end
function Login_UIBP:GetUserName()
  return self.UIRoot.Login_InputOfflineLoginItem_UIBP_Username.Input_Username:GetText()
end
function Login_UIBP:GetPassword()
  return self.UIRoot.Login_InputOfflineLoginItem_UIBP_Password.Input_Password:GetText()
end
function Login_UIBP:OnClickNoAuthLogin()
  self:PlayAudio(sound_config.click_v1)
  local username = self:GetUserName()
  local password = self:GetPassword()
  if not (username and username ~= "" and password) or password == "" then
    ShowNotice("Please input username and password")
    return
  end
  self:LoginByAccount(username, password, self.bUsingOfflineServer)
end
function Login_UIBP:LoginByAccount(username, password, bUsingOfflineServer)
  log_warning(bWriteLog and "  Login_UIBP:LoginByAccount. username: " .. tostring(username))
  log_warning(bWriteLog and "  Login_UIBP:LoginByAccount. password: " .. tostring(password))
  log_warning(bWriteLog and "  Login_UIBP:LoginByAccount. bUsingOfflineServer: " .. tostring(bUsingOfflineServer))
  local logic_no_auth_util = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_no_auth_util)
  local openid = logic_no_auth_util:GetCustomOpenIdFromUserName(username, password)
  local IMSDKHelper = import("IMSDKHelper")
  IMSDKHelper.SetNoAuthOpenid(openid)
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  login_module:Setno_auth_username(username)
  login_module:Setno_auth_password(password)
  login_module:SetOfflineServer(bUsingOfflineServer)
  if username == self:GetUserName() then
    log_warning(bWriteLog and "  Login_UIBP:LoginByAccount.  save password")
    local playerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    playerPrefsSystem.SaveTableToFile_N({
      username = username,
      password = password,
          }, playerPrefsSystem.ePlayerPrefsType.eAccountLoginData)
  end
  self:OnClickGuestLogin()
end
function Login_UIBP:CheckAccountAutoLogin()
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  if login_module.bHasSendLogin then
    log(bWriteLog and "  Login_UIBP:CheckAccountAutoLogin.  has send login")
    return
  end
  local playerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local eAccountLoginData = playerPrefsSystem.LoadFileToTable_N(playerPrefsSystem.ePlayerPrefsType.eAccountLoginData)
  if eAccountLoginData and eAccountLoginData.username then
    log_warning(bWriteLog and "  Login_UIBP:CheckAccountAutoLogin.  ")
    self.UIRoot.Login_InputOfflineLoginItem_UIBP_Username.Input_Username:SetText(eAccountLoginData.username)
    self.UIRoot.Login_InputOfflineLoginItem_UIBP_Password.Input_Password:SetText(eAccountLoginData.password)
  end
end
function Login_UIBP:OnClickOfflineServer()
  self:PlayAudio(sound_config.click_v1)
  log(bWriteLog and "NewLoginUI:OnClickOfflineServer self.bUsingOfflineServer before change: " .. tostring(self.bUsingOfflineServer))
  self.bUsingOfflineServer = not self.bUsingOfflineServer
  self.UIRoot.WidgetSwitcher_OfflineServer:SetActiveWidgetIndex(self.bUsingOfflineServer and 1 or 0)
end
function Login_UIBP:HideContentPanelInCloudVersion()
  if not self.UIRoot.CanvasPanel_Content then
    return
  end
  local logic_cloud_game = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cloud_game)
  if logic_cloud_game:GetCloudGameType() == logic_cloud_game.CLOUD_GAME_TYPE.WL_TIME then
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_Content, false, false)
  else
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_Content, true, false)
  end
end
function Login_UIBP:TryCloudVersionLogin()
  log_warning(bWriteLog and "Login_UIBP:TryCloudVersionLogin")
  local LeagalMsgSystem = require("client.slua.logic.common.logic_common_legal_msg")
  LeagalMsgSystem.SetEnableSyncAvatarInfo()
  local BusinessHelper = import("BusinessHelper")
  local haveBasePak = BusinessHelper.HasDownloadedBasePak()
  if haveBasePak then
    self:CloudVersionLogin()
  else
    self:ShowHelpshiftConversion()
    local param = {}
    Client.GEMReportEvent(GameFrontendHUD, "LoginWithoutBase", param)
  end
end
function Login_UIBP:CloudVersionLogin()
  log(bWriteLog and "Login_UIBP:CloudVersionLogin")
  log_shipping_client(bWriteLog and "rain profile Login -> Lobby start")
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  if self.loginChannel == login_module.CPhone_mail then
    LoginSubUIUtil.OpenMailLogin()
    login_module:SetLoginType(0)
  else
    local var = channel2BpVar[self.loginChannel]
    if var then
      login_module:SdkLogin(var)
    else
      log_warning(bWriteLog and "  :Login_UIBP:LoginCoroutine can\226\128\152t login var: " .. tostring(self.loginChannel))
    end
  end
  login_module:StartCloudVersionLogin()
end
function Login_UIBP:BlockEntrances()
  if not IsWoWEditor then
    return
  end
  self:SetWidgetVisible(self.UIRoot.VerticalBox_autoHide_3, false)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Privacy, false)
  self:SetWidgetVisible(self.UIRoot.WidgetSwitcher_LoginMode, false)
  self:SetWidgetVisible(self.UIRoot.Button_BackToSelect, false)
  self:SetWidgetVisible(self.UIRoot.VerticalBox_FuncButtons, false)
  self:SetWidgetVisible(self.UIRoot.btnHelpLogin, false)
  self:SetWidgetVisible(self.UIRoot.Button_Language, false)
  self:SetWidgetVisible(self.UIRoot.Panel_Repair, false)
  if _G.bFromLauncher then
    self:HideLoginButtons()
  end
end
function Login_UIBP:WoWEditorAutoLogin()
  log(bWriteLog and "Login_UIBP:WoWEditorAutoLogin .. " .. tostring(_G.bFromLauncher))
  if not IsWoWEditor then
    return
  end
  self:AddTimerOnce(0.1, function()
    if IsEditor then
      self:OnClickLogin(ShareSource.Guest)
    else
      local Utility = require("common.utility")
      if _G.WoWEditorSubSystemIns then
        if _G.bFromLauncher then
          log(bWriteLog and "Login_UIBP:WoWEditorAutoLogin Login from Launcher")
          self:OnClickLogin(ShareSource.Scan)
        elseif Utility.IsReleaseVersion() then
          log(bWriteLog and "Login_UIBP:WoWEditorAutoLogin Launcher is error")
        else
          log(bWriteLog and "Login_UIBP:WoWEditorAutoLogin Login Directly by Guest")
          self:OnClickLogin(ShareSource.Guest)
        end
      elseif Utility.IsReleaseVersion() then
        log(bWriteLog and "Login_UIBP:WoWEditorAutoLogin can't find WoWEditorSubSystem in ReleaseVersion")
      else
        log(bWriteLog and "Login_UIBP:WoWEditorAutoLogin can't find WoWEditorSubSystem in InnerVersion, Login by Guest")
        self:OnClickLogin(ShareSource.Guest)
      end
    end
  end)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CNewLoginUI = class(ui_base, nil, Login_UIBP)
return CNewLoginUI