local GdprSystem = {}
local NStatus = 0
local NType
local EUGDPR_RegionType = 0
local EUGDPR_BirthdayType = 1
local EUGDPR_ChangeAgeTime, EUGDPR_DeleteTime, EUGDPR_ParentAgreeTime, bNewUser, bEuCountry
local gdpr_config = require("client.slua.logic.gdpr.gdpr_config")
local EUGDPR_Asia = 1
local EUGDPR_North_America = 2
local EUGDPR_South_America = 3
local EUGDPR_Europe = 4
local EUGDPR_Africa = 5
local EUGDPR_Oceania = 6
local SNormalWord = "--"
local SRecommendNation, SEUGDPR_Recommend, GdprNations, GdprEuNations, SelectCountry, EUGDPR_IsAdult, year, month, lobbySign
local 
function GdprSystem.InitOnlyOne()
  log(bWriteLog and "GdprSystem.InitOnlyOne")
end
function GdprSystem.InitData()
  DataMgr.roleData.eugdpr = nil
  NType = EUGDPR_RegionType
  NStatus = gdpr_config.GDPRState.EUGDPR_DefaultState
  GdprSystem.SetEugdprNewUser(false)
  SEUGDPR_Recommend = "--"
  SRecommendNation = "--"
  SelectCountry = "--"
  bEuCountry = false
  GdprNations = {}
  GdprEuNations = {}
  local ecTable = CDataTable.GetTable("EuropeanCountries")
  for _, v in pairs(ecTable) do
    local country = {}
    country.id = v.CountryID
    country.code = v.CountryCode
    country.nation = v.CountryName
    table.insert(GdprNations, country)
    if v.isEEU == true then
      table.insert(GdprEuNations, v.CountryName)
    end
  end
end
function GdprSystem.IsGdpr()
  local SettingUtil = require("client.slua.logic.setting.setting_util")
  local region = DataMgr.RegionData.region
  log(bWriteLog and "  :GdprSystem.IsGdpr region" .. tostring(region))
  local gameFrontendHUD = SettingUtil.GetGameFrontendHUD()
  local condition = gameFrontendHUD.GDPRSettingSwitch and gameFrontendHUD.GDPRUserType > 1
  log(bWriteLog and "  :GdprSystem.IsGdpr condition" .. tostring(condition))
  return condition
end
function GdprSystem.ShowSettingNoticeBox(style, title, msg, btnOKText, btnCancelText, clickOkCallback, clickCloseCallback, policyCallback, delaytime)
  UIManager.CloseUI(UIManager.UI_Config.gdpr_setting_notice)
  UIManager.ShowUI(UIManager.UI_Config.gdpr_setting_notice, style, title, msg, btnOKText, btnCancelText, clickOkCallback, clickCloseCallback, policyCallback, delaytime)
end
function GdprSystem.ShowSettingSelectBox(title, msg, choice1, choice2, choice1Callback, choice2Callback, policyCallback)
  UIManager.ShowUI(UIManager.UI_Config.gdpr_setting_select, title, msg, choice1, choice2, choice1Callback, choice2Callback, policyCallback)
end
function GdprSystem.LessThan16()
  log(bWriteLog and "GdprSystem.LessThan16")
  if not DataMgr.roleData.eugdpr then
    log(bWriteLog and "GdprSystem.LessThan16 DataMgr.roleData.eugdpr is nil")
    return false
  end
  return DataMgr.roleData.eugdpr.user_type == gdpr_config.EUserType.EUGDPR_EU_PARENT_WAIT or DataMgr.roleData.eugdpr.user_type == gdpr_config.EUserType.EUGDPR_EU_PARENT_AGREE or DataMgr.roleData.eugdpr.user_type == gdpr_config.EUserType.EUGDPR_EU_PARENT_NOT_AGREE
end
function GdprSystem.AskForDeleteAccount()
  log(bWriteLog and "  : GdprSystem.AskForDeleteAccount")
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local confirmDelete = function()
    local strRegion = Client.GetPublishRegion()
    log(bWriteLog and "  GdprSystem.AskForDeleteAccount  confirmDelete strRegion=" .. strRegion)
    if strRegion ~= PublishRegionMacros.GLOBAL and strRegion ~= PublishRegionMacros.FIT then
      GdprSystem.KoreaDeleteAccountShowUI()
    else
      GdprSystem.ConfirmDeleteAccount()
    end
  end
  local regretDelete = function()
    log(bWriteLog and "  GdprSystem.AskForDeleteAccount  regretDelete")
    local EUGDPRSystem = require("client.logic.countryarea.logic_eugdpr")
    EUGDPRSystem.SendPrivacyToServer(1)
  end
  local strDelTips = LocUtil.GetLocalizeResStr(4379)
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  local timeSecond = 604800
  if login_module.commonSwitch.KRJPDelAccountTime ~= nil then
    timeSecond = login_module.commonSwitch.KRJPDelAccountTime
    log(bWriteLog and "  GdprSystem.AskForDeleteAccount, timeSecond = " .. timeSecond)
  end
  local strRegion = Client.GetPublishRegion()
  if strRegion ~= PublishRegionMacros.GLOBAL and strRegion ~= PublishRegionMacros.FIT then
    local day = timeSecond / 86400
    strDelTips = LocUtil.LocalizeResFormat(4707, math.floor(day))
  end
  local SettingUtil = require("client.slua.logic.setting.setting_util")
  if strRegion ~= PublishRegionMacros.GLOBAL and strRegion ~= PublishRegionMacros.FIT and SettingUtil.KRJPDelAccountLeftTime > 0 then
    GdprSystem.KoreaDeleteAccountConfirm()
  else
    GdprSystem.ShowSettingNoticeBox(1, LocUtil.GetLocalizeResStr(101001), strDelTips, LocUtil.GetLocalizeResStr(4113), LocUtil.GetLocalizeResStr(4112), confirmDelete, regretDelete, nil, 10)
  end
end
function GdprSystem.ConfirmDeleteAccount()
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  local deleteAccount = function()
    log(bWriteLog and "  GdprSystem.ConfirmDeleteAccount  deleteAccount")
    if LobbySystem.isInLobby == true and LobbySystem.isCanDeleteOp == true then
      local EUGDPRSystem = require("client.logic.countryarea.logic_eugdpr")
      EUGDPRSystem.DeleteAccountReq(true, true)
    end
  end
  local regretDelete = function()
    log(bWriteLog and "  GdprSystem.ConfirmDeleteAccount  regretDelete")
    if LobbySystem.isInLobby == true and LobbySystem.isCanDeleteOp == true then
      local EUGDPRSystem = require("client.logic.countryarea.logic_eugdpr")
      EUGDPRSystem.SendPrivacyToServer(1)
    end
  end
  local timeSecond = 604800
  if login_module.commonSwitch.EUGDPRDelAccountTime ~= nil then
    timeSecond = login_module.commonSwitch.EUGDPRDelAccountTime
    log(bWriteLog and "  GdprSystem.ConfirmDeleteAccount, timeSecond = " .. timeSecond)
  end
  local TimeUtil = require("client.common.time_util")
  local timeStr = TimeUtil.FormatCountDownTime_D_or_HMS(timeSecond, 1)
  local msg = LocUtil.LocalizeResFormat(4487, timeStr) .. "\n"
  GdprSystem.ShowSettingNoticeBox(0, LocUtil.GetLocalizeResStr(101001), msg, LocUtil.GetLocalizeResStr(4114), LocUtil.GetLocalizeResStr(4112), deleteAccount, regretDelete)
end
function GdprSystem.AskForPrivacyPolicy()
  local privacyCfg = CDataTable.GetTableData("PolicyUrlConfig", "Privacy_Policy")
  if privacyCfg and privacyCfg.JumpUrl then
    log(bWriteLog and "GdprSystem.AskForPrivacyPolicy Privacy_Policy config exists")
    GlobalData.JumpUrl(privacyCfg.JumpUrl)
    return
  end
  local strRegion = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if strRegion == PublishRegionMacros.KOREA then
    local WebviewSDK = require("client.slua.logic.url.logic_webview_sdk")
    WebviewSDK:OpenURL(FuncUtil.GetDomainByID(3366067) .. "/ko/policy/privacy/latest")
  else
    local long_txt_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.long_txt_manager)
    long_txt_manager:ShowPrivacyPolicy()
  end
end
function GdprSystem.AskForEUGDPR()
  local confirmRejectEUGDPR = function()
    log(bWriteLog and "  GdprSystem.AskForEUGDPR  confirmRejectEUGDPR")
    local EUGDPRSystem = require("client.logic.countryarea.logic_eugdpr")
    EUGDPRSystem.SendPrivacyToServer(2)
    GdprSystem.ConfirmRejectEUGDPR()
  end
  local acceptFunc = function()
    log(bWriteLog and "  GdprSystem.AskForEUGDPR  acceptFunc")
    local EUGDPRSystem = require("client.logic.countryarea.logic_eugdpr")
    EUGDPRSystem.SendPrivacyToServer(gdpr_config.EPRIVICY_ACTION.EUGDPR_PRIVICY_AGREE)
  end
  GdprSystem.ShowSettingSelectBox(LocUtil.GetLocalizeResStr(4378), LocUtil.GetLocalizeResStr(4380), LocUtil.GetLocalizeResStr(301346), LocUtil.GetLocalizeResStr(4111), acceptFunc, confirmRejectEUGDPR)
end
function GdprSystem.BackToAskForEUGDPR()
  GdprSystem.AskForEUGDPR()
  local EUGDPRSystem = require("client.logic.countryarea.logic_eugdpr")
  EUGDPRSystem.SendPrivacyToServer(1)
end
function GdprSystem.ConfirmRejectEUGDPR()
  local deleteAccount = function()
    log(bWriteLog and "  GdprSystem.ConfirmRejectEUGDPR deleteAccount")
    local EUGDPRSystem = require("client.logic.countryarea.logic_eugdpr")
    EUGDPRSystem.SendPrivacyToServer(2)
    GdprSystem.AskForDeleteAccountForGDPR()
  end
  GdprSystem.ShowSettingNoticeBox(0, LocUtil.GetLocalizeResStr(101001), LocUtil.GetLocalizeResStr(4373), LocUtil.GetLocalizeResStr(4113), LocUtil.GetLocalizeResStr(4142), deleteAccount, GdprSystem.BackToAskForEUGDPR)
end
function GdprSystem.AskForDeleteAccountForGDPR()
  local confirmDelete = function()
    log(bWriteLog and "  GdprSystem.AskForDeleteAccountForGDPR  confirmDelete")
    GdprSystem.ConfirmDeleteAccountForGDPR()
  end
  GdprSystem.ShowSettingNoticeBox(1, LocUtil.GetLocalizeResStr(101001), LocUtil.GetLocalizeResStr(4379), LocUtil.GetLocalizeResStr(4113), LocUtil.GetLocalizeResStr(4112), confirmDelete, GdprSystem.BackToAskForEUGDPR, nil, 10)
end
function GdprSystem.ConfirmDeleteAccountForGDPR()
  local deleteAccount = function()
    log(bWriteLog and "  GdprSystem.ConfirmDeleteAccountForGDPR  deleteAccount")
    local EUGDPRSystem = require("client.logic.countryarea.logic_eugdpr")
    EUGDPRSystem.DeleteAccountReq(true, true)
  end
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  local timeSecond = 604800
  if login_module.commonSwitch.EUGDPRDelAccountTime ~= nil then
    timeSecond = login_module.commonSwitch.EUGDPRDelAccountTime
    log(bWriteLog and "  GdprSystem.ConfirmDeleteAccountForGDPR, timeSecond = " .. timeSecond)
  end
  local TimeUtil = require("client.common.time_util")
  local timeStr = TimeUtil.FormatCountDownTime_D_or_HMS(timeSecond, 1)
  local msg = LocUtil.LocalizeResFormat(4356, timeStr)
  GdprSystem.ShowSettingNoticeBox(0, LocUtil.GetLocalizeResStr(101001), msg, LocUtil.GetLocalizeResStr(4114), LocUtil.GetLocalizeResStr(4112), deleteAccount, GdprSystem.BackToAskForEUGDPR)
end
function GdprSystem.AskForParentAllow()
  GdprSystem.ShowSettingSelectBox(LocUtil.GetLocalizeResStr(4381), LocUtil.GetLocalizeResStr(4391), LocUtil.GetLocalizeResStr(4110), LocUtil.GetLocalizeResStr(4115), nil, GdprSystem.ConfirmParentNotAllow)
end
function GdprSystem.ConfirmParentNotAllow()
  local confirm = function()
    log(bWriteLog and "  GdprSystem.ConfirmParentNotAllow  confirm")
    local EUGDPRSystem = require("client.logic.countryarea.logic_eugdpr")
    local gdpr_config = require("client.slua.logic.gdpr.gdpr_config")
    EUGDPRSystem.SendStateToServer(gdpr_config.EUserType.EUGDPR_EU_PARENT_NOT_AGREE)
    EUGDPRSystem.DeleteAccountReq(true, false)
    GdprSystem.ParentNotAllow()
  end
  GdprSystem.ShowSettingNoticeBox(1, LocUtil.GetLocalizeResStr(101001), LocUtil.GetLocalizeResStr(4392), LocUtil.GetLocalizeResStr(110036), LocUtil.GetLocalizeResStr(110035), confirm, GdprSystem.AskForParentAllow, nil, 10)
end
local sendLogout = function()
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  login_module:sendLogout()
end
function GdprSystem.ParentNotAllow()
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  local timeSecond = 129600
  if login_module.commonSwitch.EUGDPRChangeParentAgreeTime ~= nil then
    timeSecond = login_module.commonSwitch.EUGDPRChangeParentAgreeTime
    log(bWriteLog and "  GdprSystem.ParentNotAllow, timeSecond = " .. timeSecond)
  end
  GdprSystem.ShowSettingNoticeBox(0, LocUtil.GetLocalizeResStr(101001), LocUtil.GetLocalizeResStr(4375), LocUtil.GetLocalizeResStr(4114), LocUtil.GetLocalizeResStr(4353), sendLogout, GdprSystem.AskForDeleteAccountimmediately)
end
function GdprSystem.AskForDeleteAccountimmediately()
  local deleteAccountimmediately = function()
    local EUGDPRSystem = require("client.logic.countryarea.logic_eugdpr")
    EUGDPRSystem.DeleteAccountImmediatelyReq()
  end
  GdprSystem.ShowSettingNoticeBox(0, LocUtil.GetLocalizeResStr(101001), LocUtil.GetLocalizeResStr(4447), LocUtil.GetLocalizeResStr(4114), LocUtil.GetLocalizeResStr(110036), sendLogout, deleteAccountimmediately)
end
function GdprSystem.KoreaDeleteAccountShowUI()
  UIManager.ShowUI(UIManager.UI_Config.setting_korea_delete_account)
end
function GdprSystem.KoreaDeleteAccountConfirm()
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  local deleteAccount = function()
    log(bWriteLog and "  GdprSystem.KoreaDeleteAccountConfirm  deleteAccount isInLobby " .. tostring(LobbySystem.isInLobby) .. " isCanDeleteOp " .. tostring(LobbySystem.isCanDeleteOp))
    if LobbySystem.isInLobby == true and LobbySystem.isCanDeleteOp == true then
      local EUGDPRSystem = require("client.logic.countryarea.logic_eugdpr")
      EUGDPRSystem.DeleteKoreaAccountReq(true, true)
    end
  end
  local regretDelete = function()
    log(bWriteLog and "  GdprSystem.KoreaDeleteAccountConfirm  regretDelete isInLobby " .. tostring(LobbySystem.isInLobby) .. " isCanDeleteOp " .. tostring(LobbySystem.isCanDeleteOp))
    if LobbySystem.isInLobby == true and LobbySystem.isCanDeleteOp == true then
      local EUGDPRSystem = require("client.logic.countryarea.logic_eugdpr")
      EUGDPRSystem.SendKoreaCancelDeleteAccount()
    end
  end
  local timeSecond = 604800
  if login_module.commonSwitch and login_module.commonSwitch.KRJPDelAccountTime then
    timeSecond = login_module.commonSwitch.KRJPDelAccountTime
  end
  log(bWriteLog and "  GdprSystem.KoreaDeleteAccountConfirm, timeSecond = " .. timeSecond)
  local TimeUtil = require("client.common.time_util")
  local timeStr = TimeUtil.FormatCountDownTime_D_or_HMS(timeSecond, 1)
  local msg = LocUtil.LocalizeResFormat(4708, timeStr)
  GdprSystem.ShowSettingNoticeBox(0, LocUtil.GetLocalizeResStr(101001), msg, LocUtil.GetLocalizeResStr(4114), LocUtil.GetLocalizeResStr(4112), deleteAccount, regretDelete)
end
function GdprSystem.ShowFirstBuy()
  UIManager.ShowUI(UIManager.UI_Config.gdpr_jpage)
end
function GdprSystem.GoToFaceSlapSystem()
  log(bWriteLog and "GdprSystem.GoToFaceSlapSystem")
  local MinorVerificationSystem = require("client.slua.logic.minor_verification.logic_minor_verification")
  local DataMigrationSystem = require("client.slua.logic.data_migration.data_migration_logic")
  local NextStep = function()
    log(bWriteLog and "GdprSystem.GoToFaceSlapSystem NextStep")
    DataMigrationSystem.isDoneNextStep = true
    DataMigrationSystem.nextStep = nil
    MinorVerificationSystem.BeginVerificationFlow(function()
      local NewFaceSlapSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NewFaceSlapSystem)
      NewFaceSlapSystem:StartFaceSlap2DLobby()
    end)
  end
  DataMigrationSystem.DataMigrationOrNextStep(NextStep)
end
function GdprSystem.SetType(status)
  NType = status
end
function GdprSystem.GetType()
  return NType
end
function GdprSystem.SetStatus(status)
  log(bWriteLog and "   GdprSystem.SetStatus   :status" .. tostring(status))
  NStatus = status
end
function GdprSystem.GetStatus()
  return NStatus
end
function GdprSystem.ShowGDPRAbortPanel()
  log(bWriteLog and "  :GdprSystem.ShowGDPRAbortPanel")
  UIManager.ShowUI(UIManager.UI_Config.gdpr_jpage_delete)
end
function GdprSystem.OnHyperLinkClicked(MetaData)
  log(bWriteLog and "GdprSystem.OnHyperLinkClicked")
  local id = MetaData:Get("id")
  local url = MetaData:Get("url")
  if id == "GDPRHyperLink" and url == "privacy" then
    GdprSystem.AskForPrivacyPolicy()
  elseif id == "GDPRHyperLink" and url == "CustomerService" then
    local LogicCustomerService = require("client.slua.logic.CustomerService.LogicCustomerService")
    LogicCustomerService.Open(LogicCustomerService.E_EntranceType.Settings)
  end
end
function GdprSystem.OnHyperLinkClicked1543(MetaData)
  log_tree("  :GdprSystem.OnHyperLinkClicked1543 MetaData", MetaData)
  local id = MetaData:Get("id")
  local url = MetaData:Get("url")
  if id == "GDPRHyperLink" and url == "privacy" then
    local long_txt_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.long_txt_manager)
    local title = long_txt_manager:GetPrivacyAgreementTitle()
    local content = long_txt_manager:GetPrivacyAgreementContent()
    UIManager.ShowUI(UIManager.UI_Config.HelpTip, 0, title, content)
  elseif id == "GDPRHyperLink" and url == "CustomerService" then
    local LogicCustomerService = require("client.slua.logic.CustomerService.LogicCustomerService")
    LogicCustomerService.Open(LogicCustomerService.E_EntranceType.Settings)
  end
end
function GdprSystem.SetEugdprNewUser(flag)
  bNewUser = flag
end
function GdprSystem.GetIsNewUser()
  log(bWriteLog and "  :GdprSystem.GetIsNewUser bNewUser" .. tostring(bNewUser))
  return bNewUser
end
function GdprSystem.SetIsEUCountry(flag)
  bEuCountry = flag
end
function GdprSystem.EventEuCountry()
  for _, v in pairs(GdprEuNations) do
    if v == SelectCountry then
      bEuCountry = true
      return
    end
  end
  bEuCountry = false
end
function GdprSystem.GetIsEUCountry()
  log(bWriteLog and "  :GdprSystem.GetIsEUCountry bEuCountry" .. tostring(bEuCountry))
  return bEuCountry
end
function GdprSystem.SetEUGDPR_IsAdult(flag)
  log(bWriteLog and "GdprSystem.SetEUGDPR_IsAdult flag = " .. tostring(flag))
  EUGDPR_IsAdult = flag
end
function GdprSystem.GetEUGDPR_IsAdult()
  return EUGDPR_IsAdult
end
function GdprSystem.TryToShowEuGdpr()
  log(bWriteLog and "GdprSystem.TryToShowEuGdpr")
  log_tree(bWriteLog and "GdprSystem.TryToShowEuGdpr eugdpr = ", DataMgr.roleData.eugdpr)
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local LogicDeleteAccount = require("client.slua.logic.gdpr.logic_deleteaccount")
  if (GdprSystem.CheckDataValidity() == false or Client.GetPublishRegion() ~= PublishRegionMacros.GLOBAL and Client.GetPublishRegion() ~= PublishRegionMacros.FIT) and not LogicDeleteAccount.IsIosDeleting() and not LogicDeleteAccount.IsAosDeleting() then
    GdprSystem.GoToFaceSlapSystem()
    log(bWriteLog and "  :GdprSystem.TryToShowEuGdpr GoToFaceSlapSystem")
    return
  end
  local logic_compliance = require("client.slua.logic.gdpr.logic_compliance")
  logic_compliance.bForceCert = true
  if GdprSystem.CheckForNeedAgeGate() then
    log(bWriteLog and "[boteliu], GdprSystem.TryToShowEuGdpr US old user input Gdpr")
    return
  end
  if DataMgr.roleData ~= nil and DataMgr.roleData.eugdpr ~= nil and DataMgr.roleData.eugdpr.user_type == gdpr_config.EUserType.EUGDPR_EU_ADULT then
    log(bWriteLog and "  GdprSystem.TryToShowEuGdpr, old adult user")
    GdprSystem.SetEUGDPR_IsAdult(true)
  end
  if GdprSystem.ManageDeleting() == true then
    log(bWriteLog and "  : GdprSystem.TryToShowEuGdpr ManageDeleting == true")
    return
  end
  local logic_multiple_area = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_multiple_area)
  local isRussiaVersion = logic_multiple_area:IsRussiaVersion()
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  if login_module.commonSwitch.EUGDPRFunctionSwitch == false then
    log(bWriteLog and "  GdprSystem.TryToShowEuGdpr, FunctionSwitch = false")
    GdprSystem.GoToFaceSlapSystem()
  elseif DataMgr.minor_cert_status == logic_compliance.Enum_Minor_Cert_Status.Finish then
    log(bWriteLog and "[boteliu]GdprSystem.TryToShowEuGdpr minor_cert_status, finished")
    GdprSystem.GoToFaceSlapSystem()
  elseif isRussiaVersion then
    log(bWriteLog and "GdprSystem.TryToShowEuGdpr isRussiaVersion")
    GdprSystem.GoToFaceSlapSystem()
  elseif GdprSystem.NeedAgeGate() and logic_compliance.CanUseAgeGate() and GdprSystem.GetIsNewUser() then
    log(bWriteLog and "[boteliu]GdprSystem.TryToShowEuGdpr, NeedAgeGate")
    if GdprSystem.GetIsNewUser() then
      GdprSystem.ShowAgeGatePage()
    else
      GdprSystem.GoToFaceSlapSystem()
    end
  elseif DataMgr.roleData.eugdpr == nil or DataMgr.roleData.eugdpr.user_type == nil or DataMgr.roleData.eugdpr.user_type == 0 then
    log(bWriteLog and "  GdprSystem.TryToShowEuGdpr, eugdpr = nil or user_type = nil or 0")
    GdprSystem.SetStatus(gdpr_config.GDPRState.EUGDPR_DefaultState)
    GdprSystem.GetRecommendInfo()
    UIManager.ShowUI(UIManager.UI_Config.eu_gdpr_jpage, 0)
    GdprSystem.SetBtnId(10)
  elseif DataMgr.roleData.eugdpr.user_type == gdpr_config.EUserType.EUGDPR_NON_EU then
    log(bWriteLog and "  GdprSystem.TryToShowEuGdpr, user_type = 1 (not EU)")
    GdprSystem.SetType(EUGDPR_BirthdayType)
    GdprSystem.SetStatus(gdpr_config.GDPRState.EUGDPR_NotEUState)
    GdprSystem.GoToFaceSlapSystem()
  elseif DataMgr.roleData.eugdpr.user_type == gdpr_config.EUserType.EUGDPR_EU_PERSON then
    log(bWriteLog and "  GdprSystem.TryToShowEuGdpr, user_type = 6 (EU)")
    GdprSystem.SetType(EUGDPR_BirthdayType)
    GdprSystem.SetStatus(gdpr_config.GDPRState.EUGDPR_EUState)
    local canUseAgeGate = logic_compliance.CanUseAgeGate()
    log(bWriteLog and "GdprSystem.TryToShowEuGdpr canUseAgeGate = " .. tostring(canUseAgeGate))
    if canUseAgeGate and DataMgr.roleData.eugdpr and DataMgr.roleData.eugdpr.is_agegate then
      logic_compliance.SDKSetUserProfile("")
      logic_compliance.SDKQueryUserStatus(function(jsonData)
        log(bWriteLog and "logic_compliance SDKQueryUserStatus")
        if jsonData.adultStatus == 1 then
          local compliance_util = require("client.slua.logic.gdpr.compliance_util")
          compliance_util.GDPRAgegateAdult(jsonData.region)
          logic_compliance.ReportToSvrReq(2)
          return
        end
        local compliance_util = require("client.slua.logic.gdpr.compliance_util")
        local regionCode = compliance_util.GetRegionCodeByRegion(jsonData.region)
        local isEEAUseAgeGate = compliance_util.CheckEEAUseAgeGate(regionCode)
        if not isEEAUseAgeGate then
          local KeyPlayVideoSystem = require("client.slua.logic.lobby_activity.logic_keyplayvideo")
          KeyPlayVideoSystem.bShowedEUGDPR = true
          GdprSystem.ShowBirth()
        else
          logic_compliance.FlowNotStartCertificate(jsonData)
        end
      end)
    else
      local KeyPlayVideoSystem = require("client.slua.logic.lobby_activity.logic_keyplayvideo")
      KeyPlayVideoSystem.bShowedEUGDPR = true
      GdprSystem.ShowBirth()
    end
  elseif DataMgr.roleData.eugdpr.user_type == gdpr_config.EUserType.EUGDPR_EU_ADULT then
    log(bWriteLog and "  GdprSystem.TryToShowEuGdpr, user_type = 2 (EU Adult)")
    if DataMgr.roleData.eugdpr and DataMgr.roleData.eugdpr.is_agegate then
      GdprSystem.GoToFaceSlapSystem()
      return
    end
    if GdprSystem.ManagePrivacy() == false then
      GdprSystem.GoToFaceSlapSystem()
    end
  elseif DataMgr.roleData.eugdpr.user_type == gdpr_config.EUserType.EUGDPR_EU_PARENT_WAIT then
    log(bWriteLog and "  GdprSystem.TryToShowEuGdpr, user_type = 3 (EU young)")
    GdprSystem.SetType(EUGDPR_BirthdayType)
    GdprSystem.SetStatus(gdpr_config.GDPRState.EUGDPR_YoungState)
    local canUseAgeGate = logic_compliance.CanUseAgeGate()
    log(bWriteLog and "GdprSystem.TryToShowEuGdpr canUseAgeGate = " .. tostring(canUseAgeGate))
    if canUseAgeGate and DataMgr.roleData.eugdpr and DataMgr.roleData.eugdpr.is_agegate then
      logic_compliance.SDKSetUserProfile("")
      logic_compliance.SDKQueryUserStatus(function(jsonData)
        log(bWriteLog and "logic_compliance SDKQueryUserStatus")
        if jsonData.adultStatus == 1 then
          local compliance_util = require("client.slua.logic.gdpr.compliance_util")
          compliance_util.GDPRAgegateAdult(jsonData.region)
          logic_compliance.ReportToSvrReq(2)
          return
        end
        local compliance_util = require("client.slua.logic.gdpr.compliance_util")
        local regionCode = compliance_util.GetRegionCodeByRegion(jsonData.region)
        local isEEAUseAgeGate = compliance_util.CheckEEAUseAgeGate(regionCode)
        if not isEEAUseAgeGate then
          GdprSystem.ShowGDPRagreementPanel()
        else
          logic_compliance.FlowSelfCertification(jsonData)
        end
      end)
    else
      GdprSystem.ShowGDPRagreementPanel()
    end
  elseif DataMgr.roleData.eugdpr.user_type == gdpr_config.EUserType.EUGDPR_EU_PARENT_AGREE then
    log(bWriteLog and "  GdprSystem.TryToShowEuGdpr, user_type = 4 (EU young, and agree)")
    if DataMgr.roleData.eugdpr and DataMgr.roleData.eugdpr.is_agegate then
      GdprSystem.GoToFaceSlapSystem()
      return
    end
    if GdprSystem.CanChangeAge() == false and GdprSystem.ManagePrivacy() == false then
      GdprSystem.GoToFaceSlapSystem()
    end
  elseif DataMgr.roleData.eugdpr.user_type == gdpr_config.EUserType.EUGDPR_EU_PARENT_NOT_AGREE then
    log(bWriteLog and "  GdprSystem.TryToShowEuGdpr, user_type = 5 (EU young, not agree)")
    local canUseAgeGate = logic_compliance.CanUseAgeGate()
    log(bWriteLog and "GdprSystem.TryToShowEuGdpr canUseAgeGate = " .. tostring(canUseAgeGate))
    if canUseAgeGate and DataMgr.roleData.eugdpr and DataMgr.roleData.eugdpr.is_agegate then
      logic_compliance.SDKSetUserProfile("")
      logic_compliance.SDKQueryUserStatus(function(jsonData)
        log(bWriteLog and "logic_compliance SDKQueryUserStatus")
        if jsonData.adultStatus == 1 then
          local compliance_util = require("client.slua.logic.gdpr.compliance_util")
          compliance_util.GDPRAgegateAdult(jsonData.region)
          logic_compliance.ReportToSvrReq(2)
          return
        end
        local compliance_util = require("client.slua.logic.gdpr.compliance_util")
        local regionCode = compliance_util.GetRegionCodeByRegion(jsonData.region)
        local isEEAUseAgeGate = compliance_util.CheckEEAUseAgeGate(regionCode)
        if isEEAUseAgeGate then
          logic_compliance.FlowSelfCertification(jsonData)
        end
      end)
      return
    end
    if GdprSystem.CanChangeAge() == false then
      EUGDPR_ChangeAgeTime = DataMgr.roleData.eugdpr.left_parent_agree_time
      if 0 >= DataMgr.roleData.eugdpr.left_parent_agree_time then
        GdprSystem.SetType(EUGDPR_BirthdayType)
        GdprSystem.SetStatus(gdpr_config.GDPRState.EUGDPR_ParentNotAgreeAndDeleteState)
        GdprSystem.ShowGDPRAbortPanel()
      else
        GdprSystem.SetType(EUGDPR_BirthdayType)
        GdprSystem.SetStatus(gdpr_config.GDPRState.EUGDPR_ParentNotAgreeDeleteAndCantLoginState)
        GdprSystem.ShowGDPRAbortPanel()
      end
    end
  else
    log(bWriteLog and "  GdprSystem.TryToShowEuGdpr, what happend? user_type = " .. tostring(DataMgr.roleData.eugdpr.user_type))
    GdprSystem.GoToFaceSlapSystem()
  end
end
function GdprSystem.NeedAgeGate()
  log(bWriteLog and "[boteliu]: GdprSystem.NeedAgeGate minor_cert_status: " .. tostring(DataMgr.minor_cert_status))
  local logic_compliance = require("client.slua.logic.gdpr.logic_compliance")
  return logic_compliance.IsEntryOpen() and DataMgr.minor_cert_status ~= logic_compliance.Enum_Minor_Cert_Status.Finish
end
function GdprSystem.ShowAgeGatePage()
  GdprSystem.GetRecommendInfo()
  local logic_compliance = require("client.slua.logic.gdpr.logic_compliance")
  if _G.IsEditor then
    log(bWriteLog and "[boteliu]: GdprSystem.ShowAgeGatePage finished in editor")
    return
  end
  log(bWriteLog and "[boteliu]: GdprSystem.ShowAgeGatePage")
  logic_compliance.SDKSetUserProfile("")
  logic_compliance.BeginFlow(function()
    log(bWriteLog and "[boteliu]: GdprSystem.ShowAgeGatePage finished")
  end, function()
    log(bWriteLog and "[boteliu]: GdprSystem.ShowAgeGatePage forbiden return to login")
    sendLogout()
  end)
end
function GdprSystem.CheckForNeedAgeGate()
  local logic_compliance = require("client.slua.logic.gdpr.logic_compliance")
  if not logic_compliance.IsEntryOpen() then
    log(bWriteLog and "[boteliu] GdprSystem.CheckForNeedAgeGate compliance is not open ")
    return false
  end
  if GdprSystem.GetIsNewUser() == true then
    log(bWriteLog and "GdprSystem.CheckForNeedAgeGate NewUser")
    return false
  end
  if logic_compliance.IsIpRegionBrazil() then
    GdprSystem.ShowAgeGatePage()
    return true
  end
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  if not login_module.commonSwitch then
    log(bWriteLog and "[boteliu]GdprSystem.CheckForNeedAgeGate commonSwitch is nil ")
    return false
  end
  local logic_multiple_area = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_multiple_area)
  if logic_multiple_area:IsRussiaVersion() then
    log(bWriteLog and "[sherlock] GdprSystem.CheckForNeedAgeGate need not show AgeGatePage for russian version")
    return false
  end
  if not login_module.commonSwitch.MinorCertSwitch then
    log(bWriteLog and "[boteliu] GdprSystem.CheckForNeedAgeGate MinorCertSwitch: " .. tostring(login_module.commonSwitch.MinorCertSwitch))
    return false
  end
  if DataMgr.minor_cert_status == logic_compliance.Enum_Minor_Cert_Status.Finish then
    log(bWriteLog and "[boteliu] LoginSystem.CheckForNeedAgeGate minor_cert_status is finished ")
    return false
  end
  if DataMgr.roleData.eugdpr and DataMgr.roleData.eugdpr.user_type ~= gdpr_config.EUserType.EUGDPR_NON_EU then
    log(bWriteLog and "GdprSystem.CheckForNeedAgeGate DataMgr.roleData.eugdpr.user_type = " .. tostring(DataMgr.roleData.eugdpr.user_type))
    return false
  end
  GdprSystem.ShowAgeGatePage()
  return true
end
function GdprSystem.CheckDataValidity()
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  if login_module.commonSwitch == nil then
    log(bWriteLog and "  GdprSystem.CheckDataValidity, LoginSystem.commonSwitch = nil")
    return false
  else
    if login_module.commonSwitch.EUGDPRDelAccountTime ~= nil then
      EUGDPR_DeleteTime = login_module.commonSwitch.EUGDPRDelAccountTime
      log(bWriteLog and "  GdprSystem.CheckDataValidity, BP_EUGDPR_DeleteTime = " .. EUGDPR_DeleteTime)
    end
    if login_module.commonSwitch.EUGDPRChangeParentAgreeTime ~= nil then
      EUGDPR_ParentAgreeTime = login_module.commonSwitch.EUGDPRChangeParentAgreeTime
      log(bWriteLog and "  GdprSystem.CheckDataValidity, PB_EUGDPR_ParentAgreeTime = " .. EUGDPR_ParentAgreeTime)
    end
    if login_module.commonSwitch.EUGDPRFunctionSwitch == nil then
      log(bWriteLog and "  GdprSystem.CheckDataValidity, LoginSystem.commonSwitch.EUGDPRFunctionSwitch = nil")
      return false
    end
  end
  local logic_compliance = require("client.slua.logic.gdpr.logic_compliance")
  if GdprSystem.GetIsNewUser() == true then
    if GdprSystem.GetStatus() ~= gdpr_config.GDPRState.EUGDPR_DefaultState then
      GdprSystem.SetEugdprNewUser(false)
      log(bWriteLog and "  GdprSystem.CheckDataValidity, reset BP_EUGDPR_IsNewUser = false and return")
      return false
    elseif DataMgr.minor_cert_status == logic_compliance.Enum_Minor_Cert_Status.Finish then
      log(bWriteLog and "[boteliu]GdprSystem.CheckDataValidity, minor_cert_status finish")
      return false
    end
  elseif DataMgr.roleData.eugdpr == nil then
    log(bWriteLog and "  GdprSystem.CheckDataValidity, DataMgr.roleData.eugdpr = nil")
    return false
  elseif DataMgr.roleData.eugdpr.user_type == nil then
    log(bWriteLog and "  GdprSystem.CheckDataValidity, DataMgr.roleData.eugdpr.user_type = nil")
    return false
  elseif DataMgr.roleData.eugdpr.policy_state == nil then
    log(bWriteLog and "  GdprSystem.CheckDataValidity, DataMgr.roleData.eugdpr.policy_state = nil")
    return false
  elseif DataMgr.roleData.eugdpr.is_deleting == nil then
    log(bWriteLog and "  GdprSystem.CheckDataValidity, DataMgr.roleData.eugdpr.is_deleting = nil")
    return false
  end
  return true
end
function GdprSystem.ManageDeleting()
  log(bWriteLog and "  : GdprSystem.ManageDeleting start")
  local LogicDeleteAccount = require("client.slua.logic.gdpr.logic_deleteaccount")
  if DataMgr.roleData.eugdpr ~= nil and DataMgr.roleData.eugdpr.is_deleting == true then
    log(bWriteLog and "  GdprSystem.ManageDeleting, is_deleting = true, lefttime = " .. DataMgr.roleData.eugdpr.left_del_time)
    EUGDPR_DeleteTime = DataMgr.roleData.eugdpr.left_del_time
    if DataMgr.roleData.eugdpr.policy_state == gdpr_config.EPRIVICY_ACTION.EUGDPR_DATA_TRANS_REJECT then
      log(bWriteLog and "  GdprSystem.ManageDeleting, policy_state = 3")
      GdprSystem.SetType(EUGDPR_BirthdayType)
      GdprSystem.SetStatus(gdpr_config.GDPRState.EUGDPR_NotAgreeDataAndDeleteState)
      GdprSystem.ShowGDPRAbortPanel()
    elseif DataMgr.roleData.eugdpr.policy_state == gdpr_config.EPRIVICY_ACTION.EUGDPR_PRIVICY_REJECT then
      log(bWriteLog and "  GdprSystem.ManageDeleting, policy_state = 2")
      GdprSystem.SetType(EUGDPR_BirthdayType)
      GdprSystem.SetStatus(gdpr_config.GDPRState.EUGDPR_NotAgreePrivacyAndDeleteState)
      GdprSystem.ShowGDPRAbortPanel()
    elseif DataMgr.roleData.eugdpr.user_type == gdpr_config.EUserType.EUGDPR_EU_PARENT_NOT_AGREE then
      log(bWriteLog and "  GdprSystem.ManageDeleting, user_type = 5")
      if DataMgr.roleData.eugdpr.left_parent_agree_time <= 0 then
        GdprSystem.SetType(EUGDPR_BirthdayType)
        GdprSystem.SetStatus(gdpr_config.GDPRState.EUGDPR_ParentNotAgreeAndDeleteState)
      else
        GdprSystem.SetType(EUGDPR_BirthdayType)
        GdprSystem.SetStatus(gdpr_config.GDPRState.EUGDPR_ParentNotAgreeDeleteAndCantLoginState)
      end
      GdprSystem.ShowGDPRAbortPanel()
    else
      log(bWriteLog and "  GdprSystem.ManageDeleting, deleting without reason.")
      GdprSystem.SetType(EUGDPR_BirthdayType)
      GdprSystem.SetStatus(gdpr_config.GDPRState.EUGDPR_DeleteWithoutReasonState)
      GdprSystem.ShowGDPRAbortPanel()
    end
    return true
  elseif LogicDeleteAccount.IsIosDeleting() then
    UIManager.ShowUI(UIManager.UI_Config.ios_delete)
    return true
  elseif LogicDeleteAccount.IsAosDeleting() then
    UIManager.ShowUI(UIManager.UI_Config.aos_delete)
    return true
  else
    return false
  end
end
function GdprSystem.GetRecommendInfo()
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  SRecommendNation = "--"
  if login_module.continent == EUGDPR_Asia then
    SEUGDPR_Recommend = LocUtil.GetLocalizeResStr("4089")
  elseif login_module.continent == EUGDPR_North_America then
    SEUGDPR_Recommend = LocUtil.GetLocalizeResStr("4087")
  elseif login_module.continent == EUGDPR_South_America then
    SEUGDPR_Recommend = LocUtil.GetLocalizeResStr("4088")
  elseif SEUGDPR_Recommend.continent == EUGDPR_Europe then
    SEUGDPR_Recommend = LocUtil.GetLocalizeResStr("4092")
    if login_module.sIpRegion ~= "G1" then
      for _, v in pairs(GdprNations) do
        if login_module.sIpRegion == v.code then
          SRecommendNation = v.nation
          SelectCountry = SRecommendNation
          break
        end
      end
    end
  elseif login_module.continent == EUGDPR_Africa then
    SEUGDPR_Recommend = LocUtil.GetLocalizeResStr("4090")
  elseif login_module.continent == EUGDPR_Oceania then
    SEUGDPR_Recommend = LocUtil.GetLocalizeResStr("4091")
  else
    SEUGDPR_Recommend = "--"
  end
end
function GdprSystem.SetSelectCountry(country)
  log_tree("  :GdprSystem.SetSelectCountry country", country)
  SelectCountry = country
end
function GdprSystem.GetRecommendNation()
  return SRecommendNation or SNormalWord
end
function GdprSystem.GetRecommend()
  return SEUGDPR_Recommend or SNormalWord
end
function GdprSystem.SetBtnId(id)
  log(bWriteLog and "  : GdprSystem.SetBtnId id" .. tostring(id))
  if DataMgr.roleData.eugdpr ~= nil and DataMgr.roleData.eugdpr.is_deleting == true then
    if id == 241 then
      id = 261
    elseif id == 242 then
      id = 262
    elseif id == 341 then
      id = 361
    elseif id == 342 then
      id = 362
    end
  end
  local EUGDPRSystem = require("client.logic.countryarea.logic_eugdpr")
  EUGDPRSystem.ReportBtnClick(GdprSystem.GetIsNewUser(), id)
end
function GdprSystem.ShowBirth()
  log_tree("  :GdprSystem.ShowBirth DataMgr.roleData", DataMgr.roleData)
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  if login_module.commonSwitch.EUGDPRAgePopupSwitch == false then
    log(bWriteLog and "  GdprSystem.ShowBirth, EUGDPRAgePopupSwitch = false")
    GdprSystem.GoToFaceSlapSystem()
    return
  end
  log_tree("  :GdprSystem.ShowBirth DataMgr.roleData.eugdpr", DataMgr.roleData.eugdpr)
  if DataMgr.roleData.eugdpr ~= nil and DataMgr.roleData.eugdpr.left_change_age_time > 0 then
    log(bWriteLog and "  GdprSystem.ShowBirth, left_change_age_time = " .. DataMgr.roleData.eugdpr.left_change_age_time)
    GdprSystem.GoToFaceSlapSystem()
    return
  else
    local adultAge = GdprSystem.CalculateMinAgeDateOfBirth()
    UIManager.ShowUI(UIManager.UI_Config.agegate_select_age, adultAge, function(selectAge)
      GdprSystem.AfterSetAge(selectAge, adultAge)
    end)
  end
  return true
end
function GdprSystem.GetYearMonth()
  return year, month
end
function GdprSystem.ManagePrivacy()
  if DataMgr.roleData.eugdpr.policy_state == gdpr_config.EPRIVICY_ACTION.EUGDPR_DATA_TRANS_REJECT then
    log(bWriteLog and "  GdprSystem.ManagePrivacy, policy_state = 3")
    GdprSystem.SetType(EUGDPR_BirthdayType)
    GdprSystem.SetStatus(gdpr_config.GDPRState.EUGDPR_NotAgreeDataState)
    GdprSystem.ShowGDPRAbortPanel()
    return true
  elseif DataMgr.roleData.eugdpr.policy_state == gdpr_config.EPRIVICY_ACTION.EUGDPR_PRIVICY_REJECT then
    log(bWriteLog and "  GdprSystem.ManagePrivacy, policy_state = 2")
    GdprSystem.SetType(EUGDPR_BirthdayType)
    GdprSystem.SetStatus(gdpr_config.GDPRState.EUGDPR_NotAgreePrivacyState)
    GdprSystem.ShowGDPRAbortPanel()
    return true
  elseif DataMgr.roleData.eugdpr.policy_state == gdpr_config.EPRIVICY_ACTION.EUGDPR_DATA_TRANS_AGREE then
    log(bWriteLog and "  GdprSystem.ManagePrivacy, policy_state = 4")
    GdprSystem.SetType(EUGDPR_BirthdayType)
    GdprSystem.SetStatus(gdpr_config.GDPRState.EUGDPR_AgreeDataState)
    GdprSystem.ShowGDPRagreementPanel()
    return true
  elseif DataMgr.roleData.eugdpr.policy_state == gdpr_config.EPRIVICY_ACTION.EUGDPR_PRIVICY_DEFAULT then
    log(bWriteLog and "  GdprSystem.ManagePrivacy, policy_state = 0")
    GdprSystem.SetType(EUGDPR_BirthdayType)
    if DataMgr.roleData.eugdpr.user_type == gdpr_config.EUserType.EUGDPR_EU_ADULT then
      GdprSystem.SetStatus(gdpr_config.GDPRState.EUGDPR_AdultState)
    else
      GdprSystem.SetStatus(gdpr_config.GDPRState.EUGDPR_ParentAgreeState)
    end
    GdprSystem.ShowGDPRagreementPanel()
    return true
  else
    log(bWriteLog and "  GdprSystem.ManagePrivacy, policy_state = " .. DataMgr.roleData.eugdpr.policy_state)
    return false
  end
end
function GdprSystem.ShowGDPRagreementPanel()
  log(bWriteLog and "  :GdprSystem.ShowGDPRagreementPanel NStatus" .. tostring(NStatus))
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  if (NStatus == gdpr_config.GDPRState.EUGDPR_AdultState or NStatus == gdpr_config.GDPRState.EUGDPR_YoungState) and login_module.commonSwitch.EUGDPRAgreePopupSwitch == false then
    log(bWriteLog and "  GdprSystem.ShowGDPRagreementPanel, EUGDPRAgreePopupSwitch = false")
    GdprSystem.GoToFaceSlapSystem()
    return
  end
  if NStatus == gdpr_config.GDPRState.EUGDPR_AdultState or NStatus == gdpr_config.GDPRState.EUGDPR_ParentAgreeState then
    if login_module.commonSwitch.EUGDPRDataTranPopupSwitch == false then
      log(bWriteLog and "  GdprSystem.ShowGDPRagreementPanel, EUGDPRDataTranPopupSwitch = false")
      GdprSystem.GoToFaceSlapSystem()
      return
    end
  elseif NStatus == gdpr_config.GDPRState.EUGDPR_AgreeDataState and login_module.commonSwitch.EUGDPRPrivacyPopupSwitch == false then
    log(bWriteLog and "  GdprSystem.ShowGDPRagreementPanel, EUGDPRPrivacyPopupSwitch = false")
    GdprSystem.GoToFaceSlapSystem()
    return
  end
  log(bWriteLog and "  GdprSystem.ShowGDPRagreementPanel state=" .. NStatus)
  UIManager.ShowUI(UIManager.UI_Config.eu_gdpr_agreement)
end
function GdprSystem.CanChangeAge()
  log(bWriteLog and "  GdprSystem.CanChangeAge, left_change_age_time = " .. DataMgr.roleData.eugdpr.left_change_age_time)
  EUGDPR_ChangeAgeTime = DataMgr.roleData.eugdpr.left_change_age_time
  if DataMgr.roleData.eugdpr.left_change_age_time <= 0 then
    GdprSystem.SetType(EUGDPR_BirthdayType)
    GdprSystem.SetStatus(gdpr_config.GDPRState.EUGDPR_EUState)
    GdprSystem.ShowBirth()
    return true
  else
    return false
  end
end
function GdprSystem.SyncEUGDPRCancelDeleteAccount()
  log(bWriteLog and "  : GdprSystem.SyncEUGDPRCancelDeleteAccount")
  if DataMgr.roleData.eugdpr ~= nil and DataMgr.roleData.eugdpr.is_deleting == true then
    local EUGDPRSystem = require("client.logic.countryarea.logic_eugdpr")
    EUGDPRSystem.CancelDeleteAccountReq()
  end
end
function GdprSystem.SyncEUGDPRDeleteAccount()
  local EUGDPRSystem = require("client.logic.countryarea.logic_eugdpr")
  EUGDPRSystem.DeleteAccountReq(true, true)
end
function GdprSystem.CloseAllGDPRUI()
  local cfgs = {
    "gdpr_jpage_delete",
    "eu_gdpr_jpage",
    "eu_gdpr_jpage",
    "eu_gdpr_delete_box"
  }
  for _, v in pairs(cfgs) do
    UIManager.CloseUI(UIManager.UI_Config[v])
  end
end
function GdprSystem.SyncEUGDPRStateToServer()
  log(bWriteLog and "  :GdprSystem.SyncEUGDPRStateToServer NStatus" .. tostring(NStatus))
  local EUGDPRSystem = require("client.logic.countryarea.logic_eugdpr")
  if NStatus == gdpr_config.GDPRState.EUGDPR_NotEUState then
    EUGDPRSystem.SendStateToServer(gdpr_config.EUserType.EUGDPR_NON_EU)
  elseif NStatus == gdpr_config.GDPRState.EUGDPR_EUState then
    EUGDPRSystem.SendStateToServer(gdpr_config.EUserType.EUGDPR_EU_PERSON)
  elseif NStatus == gdpr_config.GDPRState.EUGDPR_NotAgreeDataState or NStatus == gdpr_config.GDPRState.EUGDPR_NotAgreeDataAndDeleteState then
    EUGDPRSystem.SendPrivacyToServer(gdpr_config.EPRIVICY_ACTION.EUGDPR_DATA_TRANS_REJECT)
  elseif NStatus == gdpr_config.GDPRState.EUGDPR_AgreeDataState then
    EUGDPRSystem.SendPrivacyToServer(gdpr_config.EPRIVICY_ACTION.EUGDPR_DATA_TRANS_AGREE)
  elseif NStatus == gdpr_config.GDPRState.EUGDPR_NotAgreePrivacyState or NStatus == gdpr_config.GDPRState.EUGDPR_NotAgreePrivacyAndDeleteState then
    EUGDPRSystem.SendPrivacyToServer(gdpr_config.EPRIVICY_ACTION.EUGDPR_PRIVICY_REJECT)
  elseif NStatus == gdpr_config.GDPRState.EUGDPR_BothAgreeState then
    EUGDPRSystem.SendPrivacyToServer(gdpr_config.EPRIVICY_ACTION.EUGDPR_PRIVICY_AGREE)
  elseif NStatus == gdpr_config.GDPRState.EUGDPR_AdultState then
    GdprSystem.SetEUGDPR_IsAdult(true)
    EUGDPRSystem.SendStateToServer(gdpr_config.EUserType.EUGDPR_EU_ADULT)
  elseif NStatus == gdpr_config.GDPRState.EUGDPR_YoungState then
    GdprSystem.SetEUGDPR_IsAdult(false)
    EUGDPRSystem.SendStateToServer(gdpr_config.EUserType.EUGDPR_EU_PARENT_WAIT)
  elseif NStatus == gdpr_config.GDPRState.EUGDPR_ParentNotAgreeState or NStatus == gdpr_config.GDPRState.EUGDPR_ParentNotAgreeAndDeleteState then
    EUGDPRSystem.SendStateToServer(gdpr_config.EUserType.EUGDPR_EU_PARENT_NOT_AGREE)
  elseif NStatus == gdpr_config.GDPRState.EUGDPR_ParentAgreeState then
    EUGDPRSystem.SendStateToServer(gdpr_config.EUserType.EUGDPR_EU_PARENT_AGREE)
  end
end
function GdprSystem.GetWordByState()
  log(bWriteLog and "GdprSystem.GetWordByState")
  local state = GdprSystem.GetStatus()
  local words = gdpr_config.StatusWords[state]
  log(bWriteLog and "GdprSystem.GetWordByState words = " .. tostring(words))
  return LocUtil.GetLocalizeResStr(words)
end
function GdprSystem.GetTimeWordByState()
  local state = GdprSystem.GetStatus()
  local wordId = gdpr_config.StatusWords[state]
  log(bWriteLog and "GdprSystem.GetTimeWordByState wordId = " .. tostring(wordId))
  local result = LocUtil.GetLocalizeResStr(wordId)
  if 20 <= state then
    if state == 20 then
      result = LocUtil.LocalizeResFormat(wordId, GdprSystem.ConvertTimespanToText(EUGDPR_DeleteTime), GdprSystem.ConvertTimespanToText(EUGDPR_ParentAgreeTime))
    elseif state == 21 then
      result = LocUtil.LocalizeResFormat(wordId, GdprSystem.ConvertTimespanToText(EUGDPR_DeleteTime, true))
    end
  elseif state == 13 or state == 15 or state == 19 then
    result = LocUtil.LocalizeResFormat(wordId, GdprSystem.ConvertTimespanToText(EUGDPR_DeleteTime, true))
  end
  log(bWriteLog and "  :GdprSystem.GetTimeWordByState   state" .. tostring(state))
  log(bWriteLog and "  :GdprSystem.GetTimeWordByState result" .. tostring(result))
  return result
end
function GdprSystem.ConvertTimespanToText(time, needHours)
  local TimeUtil = require("client.common.time_util")
  local timeText = TimeUtil.GetTimeLengthStr(time, needHours)
  return timeText
end
function GdprSystem.TryToShowVNGBirthPanel()
  log(bWriteLog and "GdprSystem.TryToShowVNGBirthPanel")
  GdprSystem.InitData()
  GdprSystem.SetType(EUGDPR_BirthdayType)
  GdprSystem.SetStatus(gdpr_config.GDPRState.EUGDPR_EUState)
  local adultAge = GdprSystem.CalculateMinAgeDateOfBirth()
  log(bWriteLog and "GdprSystem.TryToShowVNGBirthPanel adultAge = " .. tostring(adultAge))
  UIManager.ShowUI(UIManager.UI_Config.agegate_select_age, adultAge, function(selectAge)
    GdprSystem.AfterSetAge(selectAge, adultAge)
  end)
end
function GdprSystem.CalculateMinAgeDateOfBirth()
  local age = 16
  local strRegion = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if strRegion == PublishRegionMacros.VNG then
    age = 18
  end
  local TimeUtil = require("client.common.time_util")
  local currentTime = TimeUtil.OSDate("*t")
  local currentYear = currentTime.year
  local currentMonth = currentTime.month
  year = currentYear - age
  month = currentMonth - 1
  if month == 0 then
    month = 12
    year = year - 1
  end
  return age
end
function GdprSystem.EventVNGIsNotAdult()
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(1, LocUtil.GetLocalizeResStr(101001), LocUtil.GetLocalizeResStr(16017))
end
function GdprSystem.AfterSetAge(selectAge, adultAge)
  log(bWriteLog and "GdprSystem.AfterSetAge selectAge = " .. tostring(selectAge) .. " adultAge = " .. tostring(adultAge))
  local isAdult = adultAge <= selectAge
  local strRegion = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if strRegion ~= PublishRegionMacros.VNG then
    if isAdult then
      GdprSystem.SetStatus(gdpr_config.GDPRState.EUGDPR_AdultState)
    else
      GdprSystem.SetStatus(gdpr_config.GDPRState.EUGDPR_YoungState)
    end
    GdprSystem.SyncEUGDPRStateToServer()
    GdprSystem.ShowGDPRagreementPanel()
  elseif isAdult then
    local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
    login_module:ContinueLoginAfterVNGAdult()
  else
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(1, LocUtil.GetLocalizeResStr(101001), LocUtil.GetLocalizeResStr(16017))
  end
end
function GdprSystem.ShowCountDownPanel()
  UIManager.ShowUI(UIManager.UI_Config.eu_gdpr_delete_box)
end
function GdprSystem.EventShowGDPRPrivacyPanel()
  local long_txt_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.long_txt_manager)
  local title = long_txt_manager:GetPrivacyAgreementTitle()
  local content = long_txt_manager:GetPrivacyAgreementContent()
  UIManager.ShowUI(UIManager.UI_Config.HelpTip, 0, title, content)
end
function GdprSystem.EUGDPRReturnToLogin()
  sendLogout()
end
function GdprSystem.CloseJpage()
  UIManager.CloseUI(UIManager.UI_Config.gdpr_jpage)
end
function GdprSystem.IsEUGDPRUser(userType)
  return userType ~= gdpr_config.EUserType.EUGDPR_NON_EU
end
function GdprSystem.CanAccessClub(userType)
  return userType == gdpr_config.EUserType.EUGDPR_EU_ADULT or userType == gdpr_config.EUserType.EUGDPR_EU_PARENT_AGREE
end
return GdprSystem