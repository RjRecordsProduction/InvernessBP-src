local LeagalMsgSystem = {
  Enum_Tab_Choose = {
    Privacy = 1,
    AvatarRule = 2,
    Ads = 3,
    MarketingAgreement = 4,
    UserAgreement = 5
  },
  allNeedUserConfirmConfig = {},
  saveTabData = nil,
  afterChoosePrivacyFunc = nil,
  makeChooseList = {},
  needSyncPrivacyList = {},
  needHideAcceptAll = false,
  needHideEUAgreement = true
}
function LeagalMsgSystem.InitConfig()
  LeagalMsgSystem.allNeedUserConfirmConfig = {
    {
      getTxtFunc = LeagalMsgSystem.GetAvatarTxt,
      tabType = LeagalMsgSystem.Enum_Tab_Choose.AvatarRule,
      btnOKText = LocUtil.GetLocalizeResStr(301346),
      btnCancleText = LocUtil.GetLocalizeResStr(4111),
      tipsText = "",
      checkPopFunc = LeagalMsgSystem.CheckAvatarTipsStatus,
      acceptFunc = LeagalMsgSystem.AgreeAvatarRule,
      refuseFunc = LeagalMsgSystem.RefuseAgreeAvatar
    },
    {
      getTxtFunc = LeagalMsgSystem.GetAdsTxt,
      tabType = LeagalMsgSystem.Enum_Tab_Choose.Ads,
      btnOKText = LocUtil.GetLocalizeResStr(301346),
      btnCancleText = LocUtil.GetLocalizeResStr(4111),
      tipsText = "",
      checkPopFunc = LeagalMsgSystem.CheckAdsTipsStatus,
      acceptFunc = LeagalMsgSystem.AgreeAdsLaw,
      refuseFunc = LeagalMsgSystem.RefuseAdsLaw,
      showAfter = true
    },
    {
      getTxtFunc = LeagalMsgSystem.GetMarketingAgreementTxt,
      tabType = LeagalMsgSystem.Enum_Tab_Choose.MarketingAgreement,
      btnOKText = LocUtil.GetLocalizeResStr(301346),
      btnCancleText = LocUtil.GetLocalizeResStr(4111),
      tipsText = "",
      checkPopFunc = LeagalMsgSystem.CheckMarketingAgreementTipsStatus,
      acceptFunc = LeagalMsgSystem.AgreeMarketingAgreement,
      refuseFunc = LeagalMsgSystem.RefuseMarketingAgreement
    },
    {
      getTxtFunc = LeagalMsgSystem.GetUserAgreementTxt,
      tabType = LeagalMsgSystem.Enum_Tab_Choose.UserAgreement,
      btnOKText = LeagalMsgSystem.GetUserAgreementBtnOKTxt(),
      btnCancleText = LocUtil.GetLocalizeResStr(4111),
      tipsText = LocUtil.GetLocalizeResStr(7217),
      checkPopFunc = LeagalMsgSystem.CheckUserAgreementStatus,
      acceptFunc = LeagalMsgSystem.AgreeUserAgreement,
      refuseFunc = LeagalMsgSystem.RejectUserAgreement
    }
  }
  LeagalMsgSystem.Tab_Order = {
    [LeagalMsgSystem.Enum_Tab_Choose.MarketingAgreement] = 1,
    [LeagalMsgSystem.Enum_Tab_Choose.Privacy] = 2,
    [LeagalMsgSystem.Enum_Tab_Choose.UserAgreement] = 3,
    [LeagalMsgSystem.Enum_Tab_Choose.AvatarRule] = 4,
    [LeagalMsgSystem.Enum_Tab_Choose.Ads] = 5
  }
end
function LeagalMsgSystem.CheckAvatarTipsStatus()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eAgreeIllegalAvatarRule) or {}
  LeagalMsgSystem.makeChooseList[LeagalMsgSystem.Enum_Tab_Choose.AvatarRule] = nil
  if saveData.codeAgreeAvatar ~= nil then
    if saveData.codeAgreeAvatar == 1 then
      LeagalMsgSystem.makeChooseList[LeagalMsgSystem.Enum_Tab_Choose.AvatarRule] = true
    else
      LeagalMsgSystem.makeChooseList[LeagalMsgSystem.Enum_Tab_Choose.AvatarRule] = false
    end
  end
  log(bWriteLog and "[v_wllwu] LeagalMsgSystem.CheckAvatarTipsStatus === " .. tostring(saveData.codeAgreeAvatar))
  if saveData.codeAgreeAvatar == nil then
    log(bWriteLog and "[v_wllwu] LeagalMsgSystem.CheckAvatarTipsStatus auto agree")
    LeagalMsgSystem.AgreeAvatarRule()
    saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eAgreeIllegalAvatarRule) or {}
  end
  return saveData.codeAgreeAvatar == nil
end
function LeagalMsgSystem.UpdateAvatarTipsStatus(bAgree)
  LeagalMsgSystem.makeChooseList[LeagalMsgSystem.Enum_Tab_Choose.AvatarRule] = bAgree
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eAgreeIllegalAvatarRule) or {}
  log(bWriteLog and "[v_wllwu] LeagalMsgSystem.UpdateAvatarTipsStatus LoadFileToTable code === " .. tostring(cfg.codeAgreeAvatar))
  local code = 2
  if bAgree then
    code = 1
  end
  if cfg.codeAgreeAvatar == nil or cfg.codeAgreeAvatar ~= code then
    cfg.codeAgreeAvatar = code
    log(bWriteLog and "[v_wllwu] LeagalMsgSystem.SaveTableToFile === " .. tostring(code))
    PlayerPrefsSystem.SaveTableToFile_N(cfg, PlayerPrefsSystem.ePlayerPrefsType.eAgreeIllegalAvatarRule)
    LeagalMsgSystem.SetEnableSyncAvatarInfo()
  end
end
function LeagalMsgSystem.SetEnableSyncAvatarInfo()
  LeagalMsgSystem.needSyncPrivacyList[LeagalMsgSystem.Enum_Tab_Choose.AvatarRule] = true
end
function LeagalMsgSystem.AgreeAvatarRule()
  LeagalMsgSystem.UpdateAvatarTipsStatus(true)
end
function LeagalMsgSystem.RefuseAgreeAvatar(isClose, showSingleFunc)
  local title = LocUtil.GetLocalizeResStr(101001)
  local text = LocUtil.GetLocalizeResStr(21280)
  local btnOK = LocUtil.GetLocalizeResStr(4410)
  local btnCancel = LocUtil.GetLocalizeResStr(6752)
  local GdprSystem = require("client.slua.logic.gdpr.logic_gdpr")
  GdprSystem.ShowSettingNoticeBox(0, title, text, btnCancel, btnOK, function()
    LeagalMsgSystem.UpdateAvatarTipsStatus(false)
    LeagalMsgSystem.CheckHaveNextTab(LeagalMsgSystem.Enum_Tab_Choose.AvatarRule, isClose)
  end, function()
    if showSingleFunc ~= nil then
      showSingleFunc()
    else
      LeagalMsgSystem.ReConsiderChoose(LeagalMsgSystem.Enum_Tab_Choose.AvatarRule)
    end
  end)
end
function LeagalMsgSystem.CheckAdsTipsStatus()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  if LeagalMsgSystem.needHideEUAgreement then
    log(bWriteLog and "LeagalMsgSystem.CheckAdsTipsStatus return needHideEUAgreement")
    return false
  end
  local IPCode = FuncUtil.GetCountryIPCode()
  log(bWriteLog and "LeagalMsgSystem.CheckAdsTipsStatus IPCode : " .. tostring(IPCode))
  if LeagalMsgSystem.IsInEUCountry(IPCode) == false then
    LeagalMsgSystem.needHideAcceptAll = false
    local forceIPCode = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.bAgreeForceIPCode)
    if forceIPCode and type(forceIPCode) == "string" and forceIPCode ~= "" then
      IPCode = forceIPCode
      log(bWriteLog and "LeagalMsgSystem.CheckAdsTipsStatus forceIPCode : " .. tostring(IPCode))
      if LeagalMsgSystem.IsInEUCountry(IPCode) == false then
        return false
      end
    else
      return false
    end
  end
  LeagalMsgSystem.needHideAcceptAll = true
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eAgreeAdsLaw) or {}
  LeagalMsgSystem.makeChooseList[LeagalMsgSystem.Enum_Tab_Choose.Ads] = nil
  if saveData.AgreeAdsLaw ~= nil then
    if saveData.AgreeAdsLaw == 1 then
      LeagalMsgSystem.makeChooseList[LeagalMsgSystem.Enum_Tab_Choose.Ads] = true
    else
      LeagalMsgSystem.makeChooseList[LeagalMsgSystem.Enum_Tab_Choose.Ads] = false
    end
  end
  log(bWriteLog and " LeagalMsgSystem.CheckAdsTipsStatus === " .. tostring(saveData.AgreeAdsLaw))
  if saveData.AgreeAdsLaw == nil then
    return true
  else
    return saveData.AgreeAdsLaw == 0
  end
end
function LeagalMsgSystem.UpdateAdsTipsStatus(bAgree)
  LeagalMsgSystem.makeChooseList[LeagalMsgSystem.Enum_Tab_Choose.Ads] = bAgree
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eAgreeAdsLaw) or {}
  log(bWriteLog and " LeagalMsgSystem.UpdateAdsTipsStatus LoadFileToTable code === " .. tostring(cfg.AgreeAdsLaw))
  local code = 0
  if bAgree then
    code = 1
  end
  if cfg.AgreeAdsLaw == nil or cfg.AgreeAdsLaw ~= code then
    cfg.AgreeAdsLaw = code
    log(bWriteLog and " LeagalMsgSystem.SaveTableToFile === " .. tostring(code))
    PlayerPrefsSystem.SaveTableToFile_N(cfg, PlayerPrefsSystem.ePlayerPrefsType.eAgreeAdsLaw)
  end
end
function LeagalMsgSystem.AgreeAdsLaw()
  LeagalMsgSystem.UpdateAdsTipsStatus(true)
end
function LeagalMsgSystem.RefuseAdsLaw(isClose, showSingleFunc)
  local title = LocUtil.GetLocalizeResStr(101001)
  local text = LocUtil.GetLocalizeResStr(4485)
  local btnOK = LocUtil.GetLocalizeResStr(4410)
  local btnCancel = LocUtil.GetLocalizeResStr(4486)
  local GdprSystem = require("client.slua.logic.gdpr.logic_gdpr")
  GdprSystem.ShowSettingNoticeBox(0, title, text, btnCancel, btnOK, function()
    LeagalMsgSystem.UpdateAdsTipsStatus(false)
  end, function()
    if showSingleFunc ~= nil then
      showSingleFunc()
    else
      LeagalMsgSystem.ReConsiderChoose(LeagalMsgSystem.Enum_Tab_Choose.Ads)
    end
  end)
end
function LeagalMsgSystem.CheckMarketingAgreementTipsStatus()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if not PublishRegionMacros.IsGlobalVersion() and not PublishRegionMacros.IsCEVersion() then
    log(bWriteLog and "LeagalMsgSystem.CheckMarketingAgreementTipsStatus not global version")
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eAgreeMarketingAgreement) or {}
  if cfg.hasCheck then
    return false
  end
  return true
end
function LeagalMsgSystem.UpdateMarketingAgreementTipsStatus(bAgree)
  LeagalMsgSystem.makeChooseList[LeagalMsgSystem.Enum_Tab_Choose.MarketingAgreement] = bAgree
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eAgreeMarketingAgreement) or {}
  cfg.hasCheck = true
  cfg.  PlayerPrefsSystem.SaveTableToFile_N(cfg, PlayerPrefsSystem.ePlayerPrefsType.eAgreeMarketingAgreement)
  EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_IEGAL_MARKETING_ARGEE_CHOICE_CHANGE, bAgree)
end
function LeagalMsgSystem.AgreeMarketingAgreement()
  LeagalMsgSystem.UpdateMarketingAgreementTipsStatus(true)
end
function LeagalMsgSystem.RefuseMarketingAgreement(isClose, showSingleFunc)
  LeagalMsgSystem.UpdateMarketingAgreementTipsStatus(false)
  if showSingleFunc ~= nil then
    showSingleFunc()
  end
  if isClose then
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    if PublishRegionMacros.IsGlobalVersion() or PublishRegionMacros.IsCEVersion() then
      UIManager.CloseUI(UIManager.UI_Config.Login_Agreement_UIBP)
    else
      UIManager.CloseUI(UIManager.UI_Config.Common_Legal_01_UIBP)
    end
    UIManager.CloseUI(UIManager.UI_Config.common_protocol_msg)
  end
end
function LeagalMsgSystem.SyncMarketingAgreementState()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if not PublishRegionMacros.IsGlobalVersion() and not PublishRegionMacros.IsCEVersion() then
    log(bWriteLog and "LeagalMsgSystem.SyncMarketingAgreementState not global version")
    return
  end
  local logic_marketing_agreement = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_marketing_agreement)
  if logic_marketing_agreement then
    logic_marketing_agreement:LoadPlayerPrefs()
    log_format(bWriteLog and "LeagalMsgSystem.SyncMarketingAgreementState send_report_marketing_agreement bAgree = %s", tostring(logic_marketing_agreement.bAgree))
    logic_marketing_agreement:send_report_marketing_agreement(logic_marketing_agreement.bAgree)
  end
end
function LeagalMsgSystem.IsMenuOpen(tabType)
  local strRegion = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() then
    return false
  elseif strRegion == PublishRegionMacros.BLUEHOLE then
    return false
  end
  return true
end
function LeagalMsgSystem.IsCanShowAvatarPrivacy()
  return LeagalMsgSystem.IsMenuOpen(LeagalMsgSystem.Enum_Tab_Choose.AvatarRule)
end
function LeagalMsgSystem.CheckNeedPopLegalMsgUI()
  if Client.IsCloudVersion and Client.IsCloudVersion() then
    return false
  end
  local list = {}
  local afterList = {}
  local bHaveMsg = false
  LeagalMsgSystem.InitConfig()
  for i = 1, #LeagalMsgSystem.allNeedUserConfirmConfig do
    local TableUtil = require("common.table_util")
    local configInfo = TableUtil.CopyTable(LeagalMsgSystem.allNeedUserConfirmConfig[i])
    if LeagalMsgSystem.IsMenuOpen(configInfo.tabType) and configInfo.checkPopFunc then
      local bNeedShow = configInfo.checkPopFunc()
      if bNeedShow then
        bHaveMsg = true
        if configInfo.getTxtFunc then
          configInfo.title, configInfo.content = configInfo.getTxtFunc()
        end
        if configInfo.showAfter then
          table.insert(afterList, configInfo)
        else
          table.insert(list, configInfo)
        end
      end
    end
  end
  return bHaveMsg, list, afterList
end
function LeagalMsgSystem.CheckShowLegalUI(bPrivacyChecked, tips, btnOKText, btnCancleText, acceptPolicy, rejectPolicy)
  LeagalMsgSystem.ClearAfterShowInfo()
  LeagalMsgSystem.ResetData()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local bShow, list, afterList = LeagalMsgSystem.CheckNeedPopLegalMsgUI()
  if not bShow and not PublishRegionMacros.IsGlobalVersion() and not PublishRegionMacros.IsCEVersion() then
    return
  end
  if not bPrivacyChecked then
    local privacyTabInfo = {}
    privacyTabInfo.tabType = LeagalMsgSystem.Enum_Tab_Choose.Privacy
    privacyTabInfo.    privacyTabInfo.    privacyTabInfo.tipsText = tips
    privacyTabInfo.title, privacyTabInfo.content = LeagalMsgSystem.GetPrivacyContent()
    privacyTabInfo.acceptFunc = acceptPolicy
    privacyTabInfo.refuseFunc = rejectPolicy
    table.insert(list, privacyTabInfo)
  else
    LeagalMsgSystem.SetAfterChoosePrivacyFunc(acceptPolicy)
  end
  table.sort(list, function(a, b)
    return LeagalMsgSystem.Tab_Order[a.tabType] < LeagalMsgSystem.Tab_Order[b.tabType]
  end)
  table.sort(afterList, function(a, b)
    return LeagalMsgSystem.Tab_Order[a.tabType] < LeagalMsgSystem.Tab_Order[b.tabType]
  end)
  local len = #list
  if 0 < len then
    LeagalMsgSystem.AfterShowInfoList = afterList
    local bHasMainProtocol = false
    for _, info in ipairs(list) do
      if info.tabType == LeagalMsgSystem.Enum_Tab_Choose.Privacy or info.tabType == LeagalMsgSystem.Enum_Tab_Choose.UserAgreement then
        bHasMainProtocol = true
        break
      end
    end
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    if (1 < #list or bHasMainProtocol) and (PublishRegionMacros.IsGlobalVersion() or PublishRegionMacros.IsCEVersion()) then
      LeagalMsgSystem.SetSaveTabListData(list)
      UIManager.ShowUI(UIManager.UI_Config.Login_Agreement_UIBP, list)
    elseif 1 < #list then
      LeagalMsgSystem.SetSaveTabListData(list)
      UIManager.ShowUI(UIManager.UI_Config.Common_Legal_01_UIBP, list, nil, LeagalMsgSystem.needHideAcceptAll)
    else
      LeagalMsgSystem.ShowOnePopUI(list[1])
    end
    return true
  end
  if 0 < #afterList then
    LeagalMsgSystem.AfterShowInfoList = afterList
    local info = table.remove(LeagalMsgSystem.AfterShowInfoList, 1)
    LeagalMsgSystem.ShowOnePopUI(info)
  end
  return true
end
function LeagalMsgSystem.ShowOnePopUI(info)
  if not info then
    log(bWriteLog and "[v_wllwu] LeagalMsgSystem.ShowOnePopUI info is nil")
    return
  end
  local acceptFunc = function()
    if info.acceptFunc then
      info.acceptFunc()
    end
    LeagalMsgSystem.CallAfterChoosePrivacyFunc()
    LeagalMsgSystem.ResetData()
  end
  local refuseFunc
  if info.tabType == LeagalMsgSystem.Enum_Tab_Choose.MarketingAgreement then
    function refuseFunc()
      if info.refuseFunc then
        info.refuseFunc()
      end
      LeagalMsgSystem.CallAfterChoosePrivacyFunc()
      LeagalMsgSystem.ResetData()
    end
  else
    function refuseFunc()
      if info.refuseFunc then
        info.refuseFunc(true, function()
          LeagalMsgSystem.ShowOnePopUI(info)
        end)
      end
    end
  end
  UIManager.ShowUI(UIManager.UI_Config.common_protocol_msg, 2, info.title, info.content, info.tipsText, info.btnOKText, info.btnCancleText, acceptFunc, refuseFunc)
end
function LeagalMsgSystem.GetPrivacyContent()
  local long_txt_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.long_txt_manager)
  local title = long_txt_manager:GetPrivacyAgreementTitle()
  local content = long_txt_manager:GetPrivacyAgreementContent()
  return title, content
end
function LeagalMsgSystem.GetAvatarTxt()
  local AvatarTxt = require("client.slua.config.longs.avatar.avatar_txt")
  local titleText = AvatarTxt.Title or ""
  titleText = LocUtil.GetLocalizeResStr(44544)
  local contentText = AvatarTxt.Content or ""
  return titleText, contentText
end
function LeagalMsgSystem.GetMarketingAgreementTxt()
  local titleText = LocUtil.GetLocalizeResStr(75452)
  local contentText = LocUtil.GetLocalizeResStr(75453)
  return titleText, contentText
end
function LeagalMsgSystem.GetUserAgreementTxt()
  local long_txt_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.long_txt_manager)
  local title = long_txt_manager:GetUserAgreementTitle()
  local content = long_txt_manager:GetUserAgreementContent()
  return title, content
end
function LeagalMsgSystem.GetUserAgreementBtnOKTxt()
  local btnOKText = LocUtil.GetLocalizeResStr(29020)
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
    btnOKText = LocUtil.GetLocalizeResStr(117035)
  end
  return btnOKText
end
local PrivacyLanguageMapping = {
  pt = "pt-BR",
  TW = "zh-TW",
  HK = "zh-TW",
  zh = "zh-CN"
}
local UserAgreementUrlMapping = {
  ar = "ARA",
  de = "GER",
  en = "GBR",
  es = "ESP",
  fr = "FRA",
  id = "INA",
  ms = "MAS",
  pt = "POR",
  ru = "RUS",
  th = "THA",
  tr = "TUR",
  vi = "VIE",
  TW = "CNT",
  HK = "CNT"
}
local GetClientLanguage = function()
  local webModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.webModule)
  return webModule:GetCurrentLanguage()
end
function LeagalMsgSystem.GetPrivacyPolicyH5Url()
  local clientLang = GetClientLanguage()
  local serverLang = PrivacyLanguageMapping[clientLang] or clientLang
  local url = FuncUtil.GetDomainByID(3366241)
  if url and url ~= "" then
    return url .. "&language=" .. serverLang
  end
  return nil
end
function LeagalMsgSystem.GetUserAgreementH5Url()
  local clientLang = GetClientLanguage()
  local suffix = UserAgreementUrlMapping[clientLang] or "GBR"
  local baseUrl = FuncUtil.GetDomainByID(3366242)
  if baseUrl and baseUrl ~= "" then
    return baseUrl .. suffix
  end
  return nil
end
function LeagalMsgSystem.JumpPrivacyPolicyH5()
  local url = LeagalMsgSystem.GetPrivacyPolicyH5Url()
  if url then
    GlobalData.JumpWebUrl(url)
    return true
  end
  return false
end
function LeagalMsgSystem.JumpUserAgreementH5()
  local url = LeagalMsgSystem.GetUserAgreementH5Url()
  if url then
    GlobalData.JumpWebUrl(url)
    return true
  end
  return false
end
function LeagalMsgSystem.ShowPrivacyPolicy()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if (PublishRegionMacros.IsGlobalVersion() or PublishRegionMacros.IsCEVersion()) and LeagalMsgSystem.JumpPrivacyPolicyH5() then
    return
  end
  local long_txt_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.long_txt_manager)
  local title = long_txt_manager:GetPrivacyAgreementTitle()
  local content = long_txt_manager:GetPrivacyAgreementContent()
  UIManager.ShowUI(UIManager.UI_Config.common_protocol_msg, 0, title, content)
end
function LeagalMsgSystem.ShowUserAgreement()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if (PublishRegionMacros.IsGlobalVersion() or PublishRegionMacros.IsCEVersion()) and LeagalMsgSystem.JumpUserAgreementH5() then
    return
  end
  local long_txt_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.long_txt_manager)
  local title = long_txt_manager:GetUserAgreementTitle()
  local content = long_txt_manager:GetUserAgreementContent()
  UIManager.ShowUI(UIManager.UI_Config.common_protocol_msg, 0, title, content)
end
function LeagalMsgSystem.CheckUserAgreementStatus()
  local bUserAgreementChecked = false
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  local quickLoginHDmpveChannelID = IMSDKHelperInstance:GetHDmpveChannelID()
  local long_txt_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.long_txt_manager)
  local nUserAgreementVersion = long_txt_manager:GetUserAgreementVersion()
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  local saveGame = login_module.playerData
  if saveGame then
    bUserAgreementChecked = nUserAgreementVersion <= saveGame.UserAgreementAcceptedVersion
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if Client.GetPublishRegion() == PublishRegionMacros.VNG and (quickLoginHDmpveChannelID <= 0 or login_module.bHasLogout) then
    bUserAgreementChecked = false
  end
  if Client.IsWindowsClientReplay() then
    log(bWriteLog and "Login_UIBP:UpdateUserAgreementCheckState IsWindowsClientReplay")
    bUserAgreementChecked = true
  end
  return not bUserAgreementChecked
end
function LeagalMsgSystem.AgreeUserAgreement()
  LeagalMsgSystem.makeChooseList[LeagalMsgSystem.Enum_Tab_Choose.UserAgreement] = true
  local long_txt_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.long_txt_manager)
  local nUserAgreementVersion = long_txt_manager:GetUserAgreementVersion()
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  login_module:SetPlayerData("UserAgreementAcceptedVersion", nUserAgreementVersion)
  local info = UIManager.GetUI(UIManager.UI_Config.Login_UIBP)
  if info then
    info:UpdateUserAgreementCheckState()
  end
end
function LeagalMsgSystem.RejectUserAgreement()
  local title = LocUtil.GetLocalizeResStr(101001)
  local text = LocUtil.GetLocalizeResStr(4485)
  local btnOK = LocUtil.GetLocalizeResStr(4410)
  local btnCancel = LocUtil.GetLocalizeResStr(4486)
  local GdprSystem = require("client.slua.logic.gdpr.logic_gdpr")
  GdprSystem.ShowSettingNoticeBox(0, title, text, btnCancel, btnOK, nil, function()
    LeagalMsgSystem.ReConsiderChoose(LeagalMsgSystem.Enum_Tab_Choose.UserAgreement)
  end)
end
function LeagalMsgSystem.IsInEUCountry(ipCode)
  local long_txt_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.long_txt_manager)
  return long_txt_manager:IsInEUCountry(ipCode)
end
function LeagalMsgSystem.GetAdsTxt()
  local long_txt_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.long_txt_manager)
  local title = long_txt_manager:GetAdsTitle()
  local content = long_txt_manager:GetAdsContent()
  return title, content
end
function LeagalMsgSystem.ResetData()
  LeagalMsgSystem.saveTabData = nil
  LeagalMsgSystem.makeChooseList = {}
  LeagalMsgSystem.ClearAfterChoosePrivacyFunc()
end
function LeagalMsgSystem.SetAfterChoosePrivacyFunc(func)
  log(bWriteLog and "agalMsgSystem.SetAfterChoosePrivacyFunc")
  LeagalMsgSystem.makeChooseList[LeagalMsgSystem.Enum_Tab_Choose.Privacy] = true
  LeagalMsgSystem.afterChoosePrivacyFunc = func
end
function LeagalMsgSystem.CallAfterChoosePrivacyFunc()
  log(bWriteLog and "LeagalMsgSystem.CallAfterChoosePrivacyFunc")
  if LeagalMsgSystem.TryShowAfterShowInfoPopUp() then
    log_warning(bWriteLog and "LeagalMsgSystem.CallAfterChoosePrivacyFunc TryAfterShowInfoList")
    return
  end
  if LeagalMsgSystem.afterChoosePrivacyFunc then
    LeagalMsgSystem.afterChoosePrivacyFunc()
    LeagalMsgSystem.ClearAfterChoosePrivacyFunc()
  end
end
function LeagalMsgSystem.ClearAfterChoosePrivacyFunc()
  log(bWriteLog and "LeagalMsgSystem.ClearAfterChoosePrivacyFunc")
  if LeagalMsgSystem.AfterShowInfoList and #LeagalMsgSystem.AfterShowInfoList > 0 then
    log_warning(bWriteLog and "LeagalMsgSystem.ClearAfterChoosePrivacyFunc return AfterShowInfoList is not empty")
    return
  end
  LeagalMsgSystem.afterChoosePrivacyFunc = nil
end
function LeagalMsgSystem.TryShowAfterShowInfoPopUp(acceptPolicyCallBack)
  log(bWriteLog and "agalMsgSystem.TryAfterShowInfoList acceptPolicy: " .. tostring(acceptPolicyCallBack))
  if LeagalMsgSystem.AfterShowInfoList and #LeagalMsgSystem.AfterShowInfoList > 0 then
    local info = table.remove(LeagalMsgSystem.AfterShowInfoList, 1)
    LeagalMsgSystem.ShowOnePopUI(info)
    if acceptPolicyCallBack then
      local timer_tick = require("common.time_ticker")
      timer_tick.AddTimerOnce(0, function()
        log(bWriteLog and "agalMsgSystem.TryAfterShowInfoList Delay 1 frame")
        if not LeagalMsgSystem.afterChoosePrivacyFunc then
          LeagalMsgSystem.SetAfterChoosePrivacyFunc(acceptPolicyCallBack)
        end
      end)
    end
    return true
  end
  return false
end
function LeagalMsgSystem.ClearAfterShowInfo()
  log(bWriteLog and "agalMsgSystem.ClearAfterShowInfo")
  LeagalMsgSystem.AfterShowInfoList = {}
end
function LeagalMsgSystem.SetSaveTabListData(data)
  LeagalMsgSystem.saveTabData = data
end
function LeagalMsgSystem.ReConsiderChoose(tabType)
  if not LeagalMsgSystem.saveTabData then
    log(bWriteLog and "[wuling] LeagalMsgSystem.ReConsiderChoose error")
    return
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsGlobalVersion() or PublishRegionMacros.IsCEVersion() then
    UIManager.ShowUI(UIManager.UI_Config.Login_Agreement_UIBP, LeagalMsgSystem.saveTabData)
  else
    UIManager.ShowUI(UIManager.UI_Config.Common_Legal_01_UIBP, LeagalMsgSystem.saveTabData, tabType, LeagalMsgSystem.needHideAcceptAll)
  end
end
function LeagalMsgSystem.CheckHaveNextTab(tabType, isClose)
  local saveTabData = LeagalMsgSystem.saveTabData or {}
  local nextTabInfo
  if 0 < #saveTabData then
    for i = 1, #saveTabData do
      if not LeagalMsgSystem.CheckHasChoose(saveTabData[i].tabType) then
        nextTabInfo = saveTabData[i]
        break
      end
    end
  end
  if nextTabInfo ~= nil then
    if isClose then
      LeagalMsgSystem.ResetData()
    else
      LeagalMsgSystem.ReConsiderChoose(nextTabInfo.tabType)
    end
  else
    LeagalMsgSystem.CallAfterChoosePrivacyFunc()
    LeagalMsgSystem.ResetData()
  end
end
function LeagalMsgSystem.GetOneTabDataByType(tabType)
  LeagalMsgSystem.InitConfig()
  for i = 1, #LeagalMsgSystem.allNeedUserConfirmConfig do
    local configData = LeagalMsgSystem.allNeedUserConfirmConfig[i]
    if configData and configData.tabType == tabType then
      return configData
    end
  end
  return nil
end
function LeagalMsgSystem.GetAvatarPrivacyState()
  if not LeagalMsgSystem.IsMenuOpen(LeagalMsgSystem.Enum_Tab_Choose.AvatarRule) then
    return true
  end
  if LeagalMsgSystem.makeChooseList[LeagalMsgSystem.Enum_Tab_Choose.AvatarRule] == nil then
    LeagalMsgSystem.CheckAvatarTipsStatus()
  end
  return LeagalMsgSystem.makeChooseList[LeagalMsgSystem.Enum_Tab_Choose.AvatarRule]
end
function LeagalMsgSystem.ShowlegalAvatarRule()
  local tabType = LeagalMsgSystem.Enum_Tab_Choose.AvatarRule
  local tabData = LeagalMsgSystem.GetOneTabDataByType(tabType)
  if not tabData then
    log(bWriteLog and "[v_wllwu] LeagalMsgSystem.ShowlegalAvatarRule return, tabType is:" .. tostring(tabType))
    return
  end
  local content = ""
  local title = ""
  if tabData.getTxtFunc then
    title, content = tabData.getTxtFunc()
  end
  local acceptPolicy = function()
    if tabData.acceptFunc then
      tabData.acceptFunc()
    end
    EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_IEGAL_PRIVAY_CHOICE_CHANGE, tabType, true)
  end
  local rejectPolicy = function()
    local strTitle = LocUtil.GetLocalizeResStr(101001)
    local text = LocUtil.GetLocalizeResStr(21280)
    local btnOK = LocUtil.GetLocalizeResStr(4410)
    local btnCancel = LocUtil.GetLocalizeResStr(6752)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, strTitle, text, function()
      LeagalMsgSystem.ShowlegalAvatarRule()
    end, nil, btnOK, btnCancel)
  end
  UIManager.ShowUI(UIManager.UI_Config.common_protocol_msg, 2, title, content, nil, tabData.btnOKText, tabData.btnCancleText, acceptPolicy, rejectPolicy)
end
function LeagalMsgSystem.SyncAvatarPrivacyState()
  if not LeagalMsgSystem.IsMenuOpen(LeagalMsgSystem.Enum_Tab_Choose.AvatarRule) then
    return
  end
  local disagree = true
  if LeagalMsgSystem.makeChooseList[LeagalMsgSystem.Enum_Tab_Choose.AvatarRule] == nil then
    LeagalMsgSystem.CheckAvatarTipsStatus()
  end
  if LeagalMsgSystem.makeChooseList[LeagalMsgSystem.Enum_Tab_Choose.AvatarRule] then
    disagree = false
  end
  log(bWriteLog and "[v_wllwu] LeagalMsgSystem.SyncAvatarPrivacyState " .. tostring(disagree))
  LeagalMsgSystem.ReqSendChoice(disagree)
end
local accept_avatar_privacy_policy = 1
local not_accept_avatar_privacy_policy = 2
function LeagalMsgSystem.ReqSendChoice(b_disAgree)
  local code = accept_avatar_privacy_policy
  if b_disAgree then
    code = not_accept_avatar_privacy_policy
  end
  log(bWriteLog and "[v_wllwu] send_set_avatar_privacy_policy ===" .. tostring(code))
  local SettingHandler = require("client.network.Protocol.SettingHandler")
  SettingHandler.send_set_avatar_privacy_policy(code)
end
function LeagalMsgSystem.OnLogin()
  LeagalMsgSystem.SyncAvatarPrivacyState()
end
function LeagalMsgSystem.CheckHasChoose(tabType)
  return LeagalMsgSystem.makeChooseList[tabType] and LeagalMsgSystem.makeChooseList[tabType] or false
end
function LeagalMsgSystem.CheckHasAgree(tabType)
  return LeagalMsgSystem.makeChooseList[tabType]
end
return LeagalMsgSystem