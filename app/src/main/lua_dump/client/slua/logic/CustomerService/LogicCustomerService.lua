local LogicCustomerService = {
  E_EntranceType = {
    Recharge = "kf9016",
    Events = "kf9020",
    Login = "kf9023",
    Settings = "kf9024",
    ScanQRCode = 1717490930213727,
    AccountSecurity = 1717490763068205,
    BindGuide = 1720505869965800,
    MailNotReceive = 1731377102897158,
    PhoneNotReceive = 1731377120412941
  },
  bShouldUseGameletSDK = false
}
function LogicCustomerService.CheckAppVersionShouldUseNewInterface()
  local version = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local bVersionCheck = version == PublishRegionMacros.GLOBAL or version == PublishRegionMacros.CE or version == PublishRegionMacros.TW or version == PublishRegionMacros.VNG or version == PublishRegionMacros.FIT or version == PublishRegionMacros.FITCE
  return bVersionCheck
end
function LogicCustomerService.Open(scene)
  log(bWriteLog and "LogicCustomerService.Open " .. tostring(scene))
  local LogicSafeStation = require("client.slua.logic.CustomerService.LogicSafeStation")
  LogicSafeStation.SetIGProxyData()
  local IntlHelper = import("IntlHelper")
  local IsHelpshiftEnable4CurrentChannel = IntlHelper.IsHelpshiftEnable4CurrentChannel()
  log(bWriteLog and "LogicCustomerService.Open:" .. tostring(IsHelpshiftEnable4CurrentChannel))
  if LogicCustomerService.ShouldUseNewInterface() and LogicCustomerService.CheckAppVersionShouldUseNewInterface() then
    LogicCustomerService.EnterNewHelp(scene)
  elseif IsHelpshiftEnable4CurrentChannel then
    LogicCustomerService.HelpshiftShowFAQsWithInfo()
  else
    local LinkSdkSystem = require("client.slua.logic.vlink_sdk.logic_vlink_sdk")
    LinkSdkSystem.EventShowVLinkConversion()
  end
end
function LogicCustomerService.HelpshiftShowFAQsWithInfo(tag)
  if LogicCustomerService.ShouldUseNewInterface() and LogicCustomerService.CheckAppVersionShouldUseNewInterface() then
    LogicCustomerService.EnterNewHelp(0)
    return
  end
  local LogicSafeStation = require("client.slua.logic.CustomerService.LogicSafeStation")
  LogicSafeStation.SetIGProxyData()
  local IntlHelper = import("IntlHelper")
  if not IntlHelper.IsHelpshiftEnable() then
    return
  end
  local payment_status = "False"
  local userPaidType = "unpaid"
  if DataMgr.Recharge ~= nil and DataMgr.Recharge == 0 then
    userPaidType = "paid"
    payment_status = "True"
  end
  local nRegisterTime = DataMgr.registertime or 8
  local TimeUtil = require("client.common.time_util")
  local registerDays = TimeUtil.GetTimeShow(nRegisterTime, false, true, 1, "%H:%M:%S")
  local hsMetaInfo = {
    nickname = tostring(DataMgr.roleData.nickName or ""),
    level = tostring(DataMgr.roleData.level or 1),
    gold = tostring(DataMgr.gold or 0),
    usertype = userPaidType,
    registrationTime = registerDays,
    payment_status = payment_status,
    payment_amount = tostring(DataMgr.save_sum or 0)
  }
  if tag == nil or tag == "" then
    tag = userPaidType
  else
    tag = tag .. "," .. userPaidType
  end
  local issueFields = {
    {
      Key = "payment_status",
      Type = "singleline",
      Value = payment_status
    },
    {
      Key = "payment_amount",
      Type = "number",
      Value = tostring(DataMgr.save_sum or 0)
    }
  }
  log_tree("IntlHelper.HelpshiftShowConversionWithInfo hsMetaInfo = ", hsMetaInfo)
  log_tree("IntlHelper.HelpshiftShowConversionWithInfo issueFields =", issueFields)
  IntlHelper.HelpshiftShowFAQsWithInfo(hsMetaInfo, tag, json.encode(issueFields))
end
function LogicCustomerService.HelpshiftShowConversionWithInfo()
  if LogicCustomerService.ShouldUseNewInterface() and LogicCustomerService.CheckAppVersionShouldUseNewInterface() then
    LogicCustomerService.EnterNewHelp(0)
    return
  end
  local LogicSafeStation = require("client.slua.logic.CustomerService.LogicSafeStation")
  LogicSafeStation.SetIGProxyData()
  local IntlHelper = import("IntlHelper")
  if not IntlHelper.IsHelpshiftEnable() then
    return
  end
  local payment_status = "False"
  if DataMgr.Recharge ~= nil and DataMgr.Recharge == 0 then
    payment_status = "True"
  end
  local hsMetaInfo = {
    nickname = tostring(DataMgr.roleData.nickName or ""),
    level = tostring(DataMgr.roleData.level or 1),
    gold = tostring(DataMgr.gold or 0),
    payment_status = payment_status,
    payment_amount = tostring(DataMgr.save_sum or 0)
  }
  local issueFields = {
    {
      Key = "payment_status",
      Type = "singleline",
      Value = payment_status
    },
    {
      Key = "payment_amount",
      Type = "number",
      Value = tostring(DataMgr.save_sum or 0)
    }
  }
  log_tree("IntlHelper.HelpshiftShowConversionWithInfo hsMetaInfo = ", hsMetaInfo)
  log_tree("IntlHelper.HelpshiftShowConversionWithInfo issueFields =", issueFields)
  IntlHelper.HelpshiftShowConversionWithInfo(hsMetaInfo, json.encode(issueFields))
end
function LogicCustomerService.HelpshiftShowSingleFAQ(publishID, tag)
  if LogicCustomerService.ShouldUseNewInterface() and LogicCustomerService.CheckAppVersionShouldUseNewInterface() then
    LogicCustomerService.EnterNewHelp(0)
    return
  end
  local LogicSafeStation = require("client.slua.logic.CustomerService.LogicSafeStation")
  LogicSafeStation.SetIGProxyData()
  local IntlHelper = import("IntlHelper")
  if not IntlHelper.IsHelpshiftEnable() then
    return
  end
  local payment_status = "False"
  local userPaidType = "unpaid"
  if DataMgr.Recharge ~= nil and DataMgr.Recharge == 0 then
    userPaidType = "paid"
    payment_status = "True"
  end
  local nRegisterTime = DataMgr.registertime or 8
  local TimeUtil = require("client.common.time_util")
  local registerDays = TimeUtil.GetTimeShow(nRegisterTime, false, true, 1, "%H:%M:%S")
  local hsMetaInfo = {
    nickname = tostring(DataMgr.roleData.nickName or ""),
    level = tostring(DataMgr.roleData.level or 1),
    gold = tostring(DataMgr.gold or 0),
    usertype = userPaidType,
    registrationTime = registerDays,
    payment_status = payment_status,
    payment_amount = tostring(DataMgr.save_sum or 0)
  }
  if tag == nil or tag == "" then
    tag = userPaidType
  else
    tag = tag .. "," .. userPaidType
  end
  local issueFields = {
    {
      Key = "payment_status",
      Type = "singleline",
      Value = payment_status
    },
    {
      Key = "payment_amount",
      Type = "number",
      Value = tostring(DataMgr.save_sum or 0)
    }
  }
  log_tree("IntlHelper.HelpshiftShowConversionWithInfo hsMetaInfo = ", hsMetaInfo)
  log_tree("IntlHelper.HelpshiftShowConversionWithInfo issueFields =", issueFields)
  IntlHelper.HelpshiftShowSingleFAQWithInfo(publishID or "", hsMetaInfo, tag, json.encode(issueFields))
end
function LogicCustomerService.EnterNewHelp(scene)
  log(bWriteLog and "[DeanJYT] LogicCustomerService.EnterNewHelp scene is: " .. tostring(scene))
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if Client.GetPublishRegion() == PublishRegionMacros.VNG then
    LogicCustomerService.EnterVNH5()
  else
    local ui_jump_manager = require("client.common.uibase.ui_jump_manager")
    if ui_jump_manager.IsInit() then
      local JumpUtils = require("client.logic.store.jump_utils")
      JumpUtils.OpenJumpModule(BP_ENUM_MODULE_HOSTED_CS, scene)
    else
      local CSJumpModule = ModuleManager.GetModule(ModuleManager.JumpModuleConfig.CSJumpModule)
      CSJumpModule:JumpButNotReady(scene)
    end
  end
end
function LogicCustomerService.ShouldUseNewInterface()
  local ScriptHelperEngine = import("ScriptHelperEngine")
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS and ScriptHelperEngine.IsLowMemoryDevice() then
    return false
  else
    return LogicCustomerService.bShouldUseGameletSDK
  end
end
function LogicCustomerService.SetGameletSDKSwitch(bShouldUseGameletSDK)
  log(bWriteLog and "[DeanJYT] LogicCustomerService.SetGameletSDKSwitch bShouldUseGameletSDK = " .. tostring(bShouldUseGameletSDK))
  LogicCustomerService.end
function LogicCustomerService.OnJumpByUrl(_, __, args)
  local sceneID = args and args.scene_id
  LogicCustomerService.Open(sceneID)
end
function LogicCustomerService.GetVNCustomerServiceH5()
  local h5_url = FuncUtil.GetDomainByID(3366182)
  local PandoraSystem = require("client.slua.logic.Pandora.pandora_system")
  local webModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.webModule)
  local os_version = Client.GetOSVersion()
  local regist_time = tostring(DataMgr.registertime or 0)
  local device_model = string.lower(Client.GetDeviceModel())
  local gameVersion = PandoraSystem.GetMainAppVersion()
  local net_type = Client.GetNetWorkType()
  local open_id = DataMgr.roleData.openID or ""
  local paied_user = DataMgr.roleData.recharge_viplevel or 0
  if paied_user ~= nil and paied_user ~= 0 then
    paied_user = "paid"
  else
    paied_user = "unpaid"
  end
  local embed_param = {
    OSVersion = os_version,
    NetworkType = net_type,
    DeviceModel = device_model,
    ApplicationVersion = gameVersion,
    RegistrationTime = regist_time,
    UserType = paied_user,
    OpenId = open_id
  }
  local embed_data = ""
  for k, v in pairs(embed_param) do
    if embed_data == "" then
      embed_data = string.format("%s=%s", k, v)
    else
      embed_data = string.format("%s.%s=%s", embed_data, k, v)
    end
  end
  local base64 = require("client.slua.logic.lobby_watermark.base64")
  embed_data = base64.encode(embed_data)
  local product_id = "664"
  local user_id = tostring(DataMgr.roleData.uid or "")
  local signin_type = string.lower(Client.GetDevicePlatformName())
  local language = webModule:GetCurrentLanguage()
  local region = FuncUtil.GetAccountRegionForBP()
  local time_ms = string.format("%.0f", slua.getMicroseconds() / 1000)
  local url_param = {
    country = region,
    embeddedData = embed_data,
    lang = language,
    productId = product_id,
    signInType = signin_type,
    ts = time_ms,
    userId = user_id
  }
  local secret_key = "ZFpFeDFnaEUxa1FmUTN2cXphR3JmNzlnNkxnbnJoNUg="
  local signature = string.format("%s#%s#%s#%s#%s#%s#%s#%s", secret_key, url_param.country, url_param.embeddedData, url_param.lang, url_param.productId, url_param.signInType, url_param.ts, url_param.userId)
  signature = string.lower(Client.SHA1(signature))
  local url_query_string = ""
  for k, v in pairs(url_param) do
    if url_query_string == "" then
      url_query_string = string.format("%s=%s", k, v)
    else
      url_query_string = string.format("%s&%s=%s", url_query_string, k, v)
    end
  end
  if url_query_string ~= "" then
    h5_url = string.format("%saccess?%s&sig=%s", h5_url, url_query_string, signature)
  end
  log(bWriteLog and string.format("LogicCustomerService.GetVNCustomerServiceH5: %s", h5_url))
  return h5_url
end
function LogicCustomerService.EnterVNH5()
  local url = LogicCustomerService.GetVNCustomerServiceH5()
  local WebviewSDK = require("client.slua.logic.url.logic_webview_sdk")
  WebviewSDK:OpenURLWithExtra(url, {
    adjustType = "never",
    hideToolBar = true,
    disableShareButton = true,
    isneedticket = false
  })
end
return LogicCustomerService