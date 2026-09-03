local logic_tt_ban = {
  BlockType = {
    Disable = 1,
    CheckAndBlock = 4,
    CheckAndUnblock = 5
  },
  InvalidConfig = {
    InvalidBrand = "cXEsdWMsc29nb3UsMzYwLGxpZWJhbyxhb3lvdSxxdWFyaw==",
    InvalidTimezone = "YXNpYS9zaGFuZ2hhaSxhc2lhL2Nob25ncWluZyxhc2lhL2NodW5na2luZyxhc2lhL2hhcmJpbixhc2lhL2thc2hnYXIsYXNpYS91cnVtcWkscHJj",
    InvalidLanguage = "emgtY24semgtaGFucw=="
  }
}
local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
function logic_tt_ban:CheckIfCanCreateRole()
  local SkipNewPlayerCheck = self:GetTTBlockType()
  if SkipNewPlayerCheck == logic_tt_ban.BlockType.Disable then
    log(bWriteLog and "logic_tt_ban.CheckIfCanCreateRole return true skip NewPlayerCheck")
    return true
  end
  local logic_cloud_game = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cloud_game)
  if logic_cloud_game:IsCloudGameWeb() then
    return self:WebClientCheckFlow(SkipNewPlayerCheck)
  else
    return self:NatvieClientCheckFlow(SkipNewPlayerCheck)
  end
end
function logic_tt_ban:NatvieClientCheckFlow(SkipNewPlayerCheck)
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  local StepToReturn = 0
  local isSystemVPNOpenning = false
  local enableVPNCheck = HDmpveRemote.HDmpveRemoteConfigGetInt("NewPlayerVPNCheck", 1)
  if enableVPNCheck == 1 then
    isSystemVPNOpenning = self:IsVPNConnected()
    if not isSystemVPNOpenning then
      log(bWriteLog and "logic_tt_ban.CheckIfCanCreateRole return true by vpn not opened")
      StepToReturn = 1
    end
  end
  local forbidenTZNameNotFound = true
  local tzName = ""
  local enableTZCheck = HDmpveRemote.HDmpveRemoteConfigGetInt("NewPlayerTZCheck", 1)
  if enableTZCheck == 1 then
    tzName = self:GetSysTimeZone()
    if Client.GetDevicePlatformName() == DevicePlatformNameMacros.Android then
      local forbidenRegisterTimezoneName = self:ConvertInvalidConfig2Arr(logic_tt_ban.InvalidConfig.InvalidTimezone)
      for i, s in ipairs(forbidenRegisterTimezoneName) do
        if s == tzName then
          forbidenTZNameNotFound = false
          break
        end
      end
    elseif Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS then
      local StringUtil = require("common.string_util")
      if StringUtil.Ends(tzName, "_cn") then
        forbidenTZNameNotFound = false
      end
    end
    if forbidenTZNameNotFound then
      log(bWriteLog and "logic_tt_ban.CheckIfCanCreateRole return true tz name not match. " .. tzName)
      if StepToReturn == 0 then
        StepToReturn = 2
      end
    end
  end
  local mccinfo = ""
  local forbidenOperatorNotFound = true
  local enableMCCCheck = HDmpveRemote.HDmpveRemoteConfigGetInt("NewPlayerMCCCheck", 1)
  if enableMCCCheck == 1 then
    if Client.GetDevicePlatformName() == DevicePlatformNameMacros.Android then
      local carrierInfoStrs = self:GetCarrierInfo()
      local carrierInfos = json.decode(carrierInfoStrs)
      local foundForbidenOperatorCount = 0
      for i, s in ipairs(carrierInfos) do
        if string.lower(s.mcc) == "cn" then
          foundForbidenOperatorCount = foundForbidenOperatorCount + 1
        end
        if 1 < #mccinfo then
          mccinfo = mccinfo .. "," .. string.lower(s.mcc)
        else
          mccinfo = string.lower(s.mcc)
        end
      end
      if #carrierInfos ~= 0 and #carrierInfos == foundForbidenOperatorCount then
        forbidenOperatorNotFound = false
      end
      log(bWriteLog and "logic_tt_ban.CheckIfCanCreateRole carrier cn infos: " .. tostring(#carrierInfos) .. ", " .. tostring(foundForbidenOperatorCount))
    elseif Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS then
      local opRegionName = Client.GetOperator()
      if string.lower(opRegionName) == "cn" then
        forbidenOperatorNotFound = false
      end
      mccinfo = opRegionName
    else
      log(bWriteLog and "logic_tt_ban.CheckIfCanCreateRole do nothing")
    end
    if forbidenOperatorNotFound then
      log(bWriteLog and "logic_tt_ban.CheckIfCanCreateRole return true operator not match")
      if StepToReturn == 0 then
        StepToReturn = 3
      end
    end
  end
  if StepToReturn ~= 0 then
    self:ReportForbidRegist(StepToReturn, isSystemVPNOpenning, tzName, mccinfo)
    return true
  end
  if SkipNewPlayerCheck == logic_tt_ban.BlockType.CheckAndUnblock then
    self:ReportForbidRegist(5, isSystemVPNOpenning, tzName, mccinfo)
    return true
  end
  self:ReportForbidRegist(4, isSystemVPNOpenning, tzName, mccinfo)
  self:BlockAndReturnLogin()
  return false
end
function logic_tt_ban:WebClientCheckFlow(SkipNewPlayerCheck)
  local logic_cloud_game = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cloud_game)
  local BrowserCoreBrandTag = logic_cloud_game:GetClientBrowserBrand()
  local tzName = self:GetSysTimeZone()
  local timeOffset = logic_cloud_game:GetClientTimeOffset()
  local language = logic_cloud_game:GetClientLanuage()
  local httpAcceptLanuage = logic_cloud_game:GetClientHttpAcceptLanguage()
  local forbidenBrowserNotFound = true
  local enableBrowserCheck = HDmpveRemote.HDmpveRemoteConfigGetInt("NewPlayerBrowserCheck", 1)
  if enableBrowserCheck == 1 then
    local forbidenRegisterBrowser = self:ConvertInvalidConfig2Arr(logic_tt_ban.InvalidConfig.InvalidBrand)
    local StringUtil = require("common.string_util")
    local CoreBrandTag = StringUtil.Split(BrowserCoreBrandTag, "_")
    local webBrowserBrand = ""
    if #CoreBrandTag == 2 then
      webBrowserBrand = CoreBrandTag[2]
      if webBrowserBrand ~= nil and webBrowserBrand ~= "" then
        for i, s in ipairs(forbidenRegisterBrowser) do
          if s == webBrowserBrand then
            forbidenBrowserNotFound = false
            break
          end
        end
      end
    end
    if forbidenBrowserNotFound then
      log(bWriteLog and "logic_tt_ban.CheckIfCanCreateRole return true browser brand not match. " .. BrowserCoreBrandTag)
      self:ReportForbidRegist(1, BrowserCoreBrandTag, tzName, language, httpAcceptLanuage, timeOffset)
      return true
    end
  end
  local forbidenTZNameNotFound = true
  local enableTZCheck = HDmpveRemote.HDmpveRemoteConfigGetInt("NewPlayerTZCheck", 1)
  if enableTZCheck == 1 then
    local forbidenRegisterTimezoneName = self:ConvertInvalidConfig2Arr(logic_tt_ban.InvalidConfig.InvalidTimezone)
    for i, s in ipairs(forbidenRegisterTimezoneName) do
      if s == tzName and -480 == timeOffset then
        forbidenTZNameNotFound = false
        break
      end
    end
    if forbidenTZNameNotFound then
      log(bWriteLog and string.format("logic_tt_ban.CheckIfCanCreateRole return true tz name not match. %s, %s ", tzName, tostring(timeOffset)))
      self:ReportForbidRegist(2, BrowserCoreBrandTag, tzName, language, httpAcceptLanuage, timeOffset)
      return true
    end
  end
  local forbidenLanaugeNotFound = true
  local enableLanuageCheck = HDmpveRemote.HDmpveRemoteConfigGetInt("NewPlayerLanguageCheck", 1)
  if enableLanuageCheck == 1 then
    local forbidenRegisterLanguageName = self:ConvertInvalidConfig2Arr(logic_tt_ban.InvalidConfig.InvalidLanguage)
    for i, s in ipairs(forbidenRegisterLanguageName) do
      local lowerHttpAcceptLanuage = string.lower(httpAcceptLanuage)
      if s == string.lower(language) and string.find(lowerHttpAcceptLanuage, s, 1, true) then
        forbidenLanaugeNotFound = false
        break
      end
    end
    if forbidenLanaugeNotFound then
      log(bWriteLog and "logic_tt_ban.CheckIfCanCreateRole return true language not match. " .. language)
      self:ReportForbidRegist(3, BrowserCoreBrandTag, tzName, language, httpAcceptLanuage, timeOffset)
      return true
    end
  end
  if SkipNewPlayerCheck == logic_tt_ban.BlockType.CheckAndUnblock then
    self:ReportForbidRegist(5, BrowserCoreBrandTag, tzName, language, httpAcceptLanuage, timeOffset)
    log(bWriteLog and "logic_tt_ban.CheckIfCanCreateRole return true only detect")
    return true
  end
  self:ReportForbidRegist(4, BrowserCoreBrandTag, tzName, language, httpAcceptLanuage, timeOffset)
  self:BlockAndReturnLogin()
  return false
end
function logic_tt_ban:BlockAndReturnLogin()
  local TimeTicker = require("common.time_ticker")
  TimeTicker.AddTimerOnce(1, function()
    local strTitle = LocUtil.GetLocalizeResStr(101001)
    local strContent = LocUtil.GetLocalizeResStr(82217) .. "(Login_Error)"
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(1, strTitle, strContent, nil)
  end)
  local SettingAccount = require("client.logic.setting.logic_setting_account")
  SettingAccount.ClientLogout()
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  login_module:backLogin()
end
function logic_tt_ban:ReportForbidRegist(entry, vpn, tz, carrier, httpAcceptLanuage, timeOffset)
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  local openid = IMSDKHelperInstance:getOpenID()
  local logic_cloud_game = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cloud_game)
  local cloudGameClientType = logic_cloud_game:GetClientType()
  if carrier == nil or carrier == "" then
    carrier = "_"
  end
  local SubEvent = "NewPlayerEvent"
  local ParamTable = {
    tostring(entry),
    tostring(openid),
    tostring(vpn or "_"),
    tostring(tz or "_"),
    carrier,
    tostring(cloudGameClientType or "_"),
    tostring(timeOffset or "_"),
    tostring(httpAcceptLanuage or "_")
  }
  log_tree("logic_tt_ban.ReportForbidRegist reprt GRomeLinkEvent,NewPlayerEvent", ParamTable)
  Client.GEMReportSubEvent(GameFrontendHUD, "GRomeLinkEvent", SubEvent, ParamTable)
end
function logic_tt_ban:IsVPNConnected()
  if self:GetTTBlockType() == logic_tt_ban.BlockType.Disable then
    log(bWriteLog and "logic_tt_ban.GetSysTimeZone return true by bh version")
    return false
  end
  local logic_cloud_game = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cloud_game)
  local isSystemVPNOpenning = logic_cloud_game:IsClientVPNConnected()
  if isSystemVPNOpenning == false then
    isSystemVPNOpenning = Client.IsSystemVPNOpened()
  end
  return isSystemVPNOpenning
end
function logic_tt_ban:GetSysTimeZone()
  if self:GetTTBlockType() == logic_tt_ban.BlockType.Disable then
    log(bWriteLog and "logic_tt_ban.GetSysTimeZone return true by bh version")
    return ""
  end
  local logic_cloud_game = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cloud_game)
  local tzName = logic_cloud_game:GetClientTimeZone()
  if tzName == "" then
    tzName = Client.GetTimezoneName()
  end
  tzName = string.lower(tzName)
  return tzName
end
function logic_tt_ban:GetCarrierInfo()
  local logic_cloud_game = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cloud_game)
  local carrierInfoStrs = logic_cloud_game:GetCarrierInfo()
  if carrierInfoStrs == "" then
    carrierInfoStrs = Client.GetCarrierInfo()
  end
  return carrierInfoStrs
end
function logic_tt_ban:GetShortCarrier()
  local mccinfo = ""
  if self:GetTTBlockType() == logic_tt_ban.BlockType.Disable then
    log(bWriteLog and "logic_tt_ban.GetShortCarrier return true by bh version")
    return ""
  end
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if Client.GetDevicePlatformName() == DevicePlatformNameMacros.Android then
    local carrierInfoStrs = self:GetCarrierInfo()
    local carrierInfos = json.decode(carrierInfoStrs)
    for i, s in ipairs(carrierInfos) do
      if 1 < #mccinfo then
        mccinfo = mccinfo .. "," .. string.lower(s.mcc)
      else
        mccinfo = string.lower(s.mcc)
      end
    end
  elseif Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS then
    mccinfo = Client.GetOperator()
  end
  return mccinfo
end
function logic_tt_ban:ConvertInvalidConfig2Arr(InvalidConfig)
  local base64 = require("client.slua.logic.lobby_watermark.base64")
  local invalidOriginalStr = base64.DecodeBase64(InvalidConfig)
  local StringUtil = require("common.string_util")
  local invalidOriginalArr = StringUtil.Split(invalidOriginalStr, ",")
  return invalidOriginalArr
end
function logic_tt_ban:GetTTBlockType()
  local publishRegion = Client.GetPublishRegion()
  local defaultValue = logic_tt_ban.BlockType.Disable
  if publishRegion == PublishRegionMacros.GLOBAL or publishRegion == PublishRegionMacros.FIT then
    defaultValue = logic_tt_ban.BlockType.CheckAndBlock
  end
  local TTBlockType = HDmpveRemote.HDmpveRemoteConfigGetInt("SkipNewPlayerEventCheck", defaultValue)
  return TTBlockType
end
return logic_tt_ban