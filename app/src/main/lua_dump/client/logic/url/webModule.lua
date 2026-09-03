local webModule = {
  h5Parameter = {
    rolename = "roleName",
    nickname = "nickname",
    head_pic = "head_pic",
    headbox = "headbox",
    id = "id",
    gameid = "gameid",
    itop_openid = "itop_openid",
    sTicket = "sTicket",
    itop_ticket = "itop_ticket",
    game_season = "game_season",
    game_area = "game_area",
    language = "language",
    timeZone = "timeZone",
    loginType = "loginType",
    country = "country",
    region = "region",
    version = "version",
    areaid = "areaid",
    token = "token"
  }
}
local SLaterUrl
local _bIsInitWebViewCacheDelegate = false
local _local OnHandleWebViewCache = function(code)
  log(bWriteLog and "[edward] WebSystem.OnHandleWebViewCache, code = " .. tostring(code))
  EventSystem:postEvent(EVENTTYPE_IGH5CACHE, EVENTID_IGH5CACHE, code)
end
function webModule:DefineAndResetData()
  self.needLogoutOnCloseWeb = nil
end
function webModule:SetneedLogoutOnCloseWeb(flag)
  self.needLogoutOnCloseWeb = flag
  log_warning(bWriteLog and "  :SetneedLogoutOnCloseWeb flag: " .. tostring(flag))
end
function webModule:OnPostSwitchGameStatus(_, next)
  log(bWriteLog and "webModule:OnModePostSwitch next = " .. tostring(next))
  if next == GameStatus.Lobby then
    webModule:OpenEagleWeb()
  end
  if not _bIsInitWebViewCacheDelegate then
    local delegate = slua.createDelegate(OnHandleWebViewCache)
    local ScriptHelperClient = import("ScriptHelperClient")
    ScriptHelperClient.SetWebViewCacheInfoDelegate(delegate)
    _bIsInitWebViewCacheDelegate = true
  end
end
function webModule:GetCurrentLanguage()
  local myLanguage = Client.GetCurrentLanguage()
  if myLanguage == nil then
    local LanguageMacros = require("client.slua.config.ClientMacros.LanguageMacros")
    myLanguage = LanguageMacros.EN
  end
  return myLanguage
end
function webModule:SignOpenidAndLanguage()
  local SeasonPrivateKey = "XEPPTNsQV5BAkGDA"
  local openid = DataMgr.roleData.openID
  local language = webModule:GetCurrentLanguage()
  local paramList = {
    {key = "openid", val = openid},
    {key = "language", val = language}
  }
  local signUrl = webModule:TableToStringParam(paramList, false)
  signUrl = _string.gsub(signUrl, "&", "", 1)
  local encryptionStr = SeasonPrivateKey .. signUrl .. SeasonPrivateKey
  local sign = Client.MD5HashAnsiString(encryptionStr)
  log(bWriteLog and "WebSystem sign:" .. sign)
  return sign
end
function webModule:TableToStringParam(paramList, startWithQuestionMark)
  table.sort(paramList, function(a, b)
    return a.key < b.key
  end)
  local param = ""
  local isFirstParam = true
  local seprate = ""
  for _, v in ipairs(paramList) do
    if startWithQuestionMark and isFirstParam then
      seprate = "?"
      isFirstParam = false
    else
      seprate = "&"
    end
    param = param .. seprate .. v.key .. "=" .. v.val
  end
  return param
end
function webModule:OpenURL(url, paramList, need_sign, additionParam)
  local StringUtil = require("common.string_util")
  if StringUtil.Starts(url, "http") or StringUtil.Starts(url, "https") then
    local paramList2 = {}
    if paramList then
      for _, v in pairs(paramList) do
        if v == "openid" then
          local openId = tostring(DataMgr.roleData.openID)
          table.insert(paramList2, {key = "openid", val = openId})
        elseif v == "language" then
          local myLanguage = webModule:GetCurrentLanguage()
          table.insert(paramList2, {key = "language", val = myLanguage})
        elseif v == "uid" then
          local uid = DataMgr.roleData.uid
          table.insert(paramList2, {key = "uid", val = uid})
        elseif v == "game_season" then
          local game_season = UnknowPassSystem.Season
          table.insert(paramList2, {
            key = "game_season",
            val = game_season
          })
        elseif v == "gameid" then
          local gameid = Client.GetITopGameId(NetInterface)
          table.insert(paramList2, {key = "gameid", val = gameid})
        elseif v == "sTicket" then
          local ticket = Client.GetWebViewTicket(NetInterface)
          table.insert(paramList2, {key = "sTicket", val = ticket})
        elseif v == "networkType" then
          local networkType = 0
          if Client.HasActiveWifi() then
            networkType = 1
          else
            networkType = 2
          end
          table.insert(paramList2, {
            key = "networkType",
            val = networkType
          })
        elseif v == "game_area" then
          local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
          local region = ZoneSystem.GetChooseZone()
          table.insert(paramList2, {key = "game_area", val = region})
        end
      end
    end
    if need_sign == true then
      local sign = webModule:SignOpenidAndLanguage()
      table.insert(paramList2, {key = "sign", val = sign})
    end
    if additionParam then
      for k, v in pairs(additionParam) do
        table.insert(paramList2, {key = k, val = v})
      end
    end
    webModule:CheckNeedTiming(url)
    local startWithQuestionMark = false
    if _string.find(url, "?") == nil then
      startWithQuestionMark = true
    end
    local paramUrl = webModule:TableToStringParam(paramList2, startWithQuestionMark)
    url = url .. paramUrl
    log(bWriteLog and "AppendTokenToUrl url = " .. url)
    local WebviewSDK = require("client.slua.logic.url.logic_webview_sdk")
    WebviewSDK:OpenURL(url)
  end
end
function webModule:AddPersonalInfoPropertyAndPlaceholder(url, property, placeholder, withoutConnChar, value)
  withoutConnChar = withoutConnChar or false
  placeholder = placeholder or property
  local ConnChar = withoutConnChar and "" or "&"
  url = url .. ConnChar .. property .. "={" .. placeholder .. "}"
  return url
end
function webModule:AddPersonalInfoPropertyAndValue(url, property, value, withoutConnChar)
  withoutConnChar = withoutConnChar or false
  value = value or property
  local ConnChar = withoutConnChar and "" or "&"
  url = url .. ConnChar .. property .. "=" .. value .. ""
  return url
end
function webModule:AddParameterByPersonalInfo(url, useSettingRegion, dontAdd, dontNeedDate)
  log(bWriteLog and "WebSystem.AddParameterByPersonalInfo, before url = " .. tostring(url) .. ", useSettingRegion = " .. tostring(useSettingRegion) .. ", dontAdd = " .. tostring(dontAdd))
  if not url or type(url) ~= "string" or url == "" then
    log(bWriteLog and "WebSystem.AddParameterByPersonalInfo,  after url = ")
    return ""
  end
  local IntlHelper = import("IntlHelper")
  local nickName = self:URLEncode(tostring(DataMgr.roleData.nickName))
  log(bWriteLog and "  :nickName" .. tostring(nickName))
  local head_pic = self:URLEncode(tostring(DataMgr.roleData.headIconUrl))
  local headbox = self:URLEncode(tostring(DataMgr.roleData.cur_avatar_box_id))
  url = _string.StrReplace(url, "{nickname}", nickName, 1)
  url = _string.StrReplace(url, "{head_pic}", head_pic, 1)
  url = _string.StrReplace(url, "{headbox}", headbox, 1)
  url = _string.StrReplace(url, "{gameid}", Client.GetITopGameId(), 1)
  url = _string.StrReplace(url, "{itop_openid}", DataMgr.roleData.openID, 1)
  url = _string.StrReplace(url, "{itop_ticket}", Client.GetWebViewTicket(NetInterface), 1)
  url = _string.StrReplace(url, "{game_season}", DataMgr.season_id, 1)
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  url = _string.StrReplace(url, "{game_area}", ZoneSystem.GetChooseZone(), 1)
  url = _string.StrReplace(url, "{language}", webModule:GetCurrentLanguage(), 1)
  url = _string.StrReplace(url, "{timeZone}", IntlHelper.GetLocalTimezone(), 1)
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  url = _string.StrReplace(url, "{loginType}", login_module.nLoginType or 0, 1)
  if useSettingRegion then
    url = _string.StrReplace(url, "{country}", tostring(FuncUtil.GetAccountRegionForBP()), 1)
  else
    url = _string.StrReplace(url, "{country}", tostring(login_module.sIpRegion), 1)
  end
  url = _string.StrReplace(url, "{version}", tostring(Client.GetApplicationVersion()), 1)
  url = _string.StrReplace(url, "{areaid}", tostring(DataMgr.roleData.idip_area_id), 1)
  url = _string.StrReplace(url, "{level}", tostring(DataMgr.roleData.level), 1)
  local device_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.device_module)
  local OSAbi = device_module:GetOSArch()
  url = _string.StrReplace(url, "{abi}", OSAbi, 1)
  local logic_gamelet_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_gamelet_interface)
  local nonage = logic_gamelet_interface.nonage
  log(bWriteLog and string.format("webModule:AddParameterByPersonalInfo  logic_gamelet_interface.nonage = %s", tostring(logic_gamelet_interface.nonage)))
  url = _string.StrReplace(url, "{nonage}", nonage, 1)
  if dontAdd == true then
    url = _string.StrReplace(url, "{openid}", tostring(DataMgr.roleData.openID), 1)
    url = _string.StrReplace(url, "{uid}", tostring(DataMgr.roleData.uid) or "0", 1)
    url = _string.StrReplace(url, "{sign}", webModule:SignOpenidAndLanguage(), 1)
  else
    if _string.find(url, "sign=") == nil then
      local separator = webModule:CheckQuestionMark(url) and "&" or "?"
      local sign = webModule:SignOpenidAndLanguage()
      url = _string.format("%s%ssign=%s", url, separator, sign)
    end
    if _string.find(url, "openid=") == nil then
      local openid = tostring(DataMgr.roleData.openID)
      url = _string.format("%s&openid=%s", url, openid)
    end
    if _string.find(url, "uid=") == nil then
      local uid = tostring(DataMgr.roleData.uid) or "0"
      url = _string.format("%s&uid=%s", url, uid)
    end
    if _string.find(url, "language=") == nil then
      url = _string.format("%s&language=%s", url, webModule:GetCurrentLanguage())
    end
    if dontNeedDate ~= true then
      url = webModule:AddDateParameters(url)
    end
  end
  if _string.find(url, "publishRegion=") == nil then
    if _string.find(url, "?") then
      url = _string.format("%s&publishRegion=%s", url, Client.GetPublishRegion())
    else
      url = _string.format("%s?publishRegion=%s", url, Client.GetPublishRegion())
    end
  else
    url = _string.StrReplace(url, "{publishRegion}", Client.GetPublishRegion(), 1)
  end
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  local canpay
  if QRcodeRestrictManager:IsRestrictUC() then
    canpay = 1
  else
    canpay = 0
  end
  if string.find(url, "?") then
    url = url .. string.format("&canpay=%s", tostring(canpay))
  else
    url = url .. string.format("?canpay=%s", tostring(canpay))
  end
  log(bWriteLog and "WebSystem.AddParameterByPersonalInfo,  after url = " .. tostring(url))
  return url
end
function webModule:CheckQuestionMark(url)
  return _string.match(url, "([%w_]+)=(%w+)") and true or false
end
function webModule:AddDateParameters(url)
  if _string.find(url, "date_format=") == nil then
    local logic_setting_time_display = require("client.logic.setting.logic_setting_time_display")
    local dateFormat = logic_setting_time_display.dateFormat
    local encodedFormat = Client.UrlEncode(Client.HtmlEncode(dateFormat))
    url = _string.format("%s&date_format=%s", url, encodedFormat)
  end
  return url
end
function webModule:SaveURLForComebackAfterShare(param)
  webModule.comebackURL = param
end
function webModule:GetURLForComebackAfterShare()
  local temp = webModule.comebackURL
  webModule.comebackURL = nil
  log(bWriteLog and "WebSystem.GetURLForComebackAfterShare, comebackURL = " .. tostring(temp))
  return temp
end
function webModule:JumpToWebPage(url, isneedticket)
  GlobalData.StopLobbyBGM()
  EventSystem:postEvent(EVENTTYPE_WEB, EVENTID_WEB_DEACTIVATED)
  webModule:CheckNeedTiming(url)
  local extraObj = {}
  if _string.find(url, "never_adjust=1") ~= nil then
    extraObj.adjustType = "never"
  end
  if _string.find(url, "notch=0") ~= nil then
    extraObj.useNotch = "false"
  else
    extraObj.useNotch = "true"
  end
  if _string.find(url, "personal=1") ~= nil then
    url = self:AddParameterByPersonalInfo(url)
  end
  extraObj.bgColor = "#FF000000"
  extraObj.  local WebviewSDK = require("client.slua.logic.url.logic_webview_sdk")
  WebviewSDK:OpenURLWithExtra(url, extraObj)
end
function webModule:BackLobbyAndOpenWeb()
  log(bWriteLog and "  : BackLobbyAndOpenWeb")
  SLaterUrl = FuncUtil.GetDomainByID(3366036) .. "/act/a20211125aqz/index.html?"
  SLaterUrl = webModule:AddPersonalInfoPropertyAndPlaceholder(SLaterUrl, webModule.h5Parameter.region, webModule.h5Parameter.country, true)
  SLaterUrl = webModule:AddPersonalInfoPropertyAndPlaceholder(SLaterUrl, webModule.h5Parameter.sTicket, webModule.h5Parameter.itop_ticket)
  SLaterUrl = webModule:AddPersonalInfoPropertyAndPlaceholder(SLaterUrl, webModule.h5Parameter.gameid, webModule.h5Parameter.gameid)
  SLaterUrl = webModule:AddPersonalInfoPropertyAndPlaceholder(SLaterUrl, webModule.h5Parameter.nickname, webModule.h5Parameter.nickname)
  SLaterUrl = webModule:AddPersonalInfoPropertyAndPlaceholder(SLaterUrl, webModule.h5Parameter.head_pic, webModule.h5Parameter.head_pic)
  SLaterUrl = webModule:AddPersonalInfoPropertyAndPlaceholder(SLaterUrl, webModule.h5Parameter.game_area, webModule.h5Parameter.game_area)
  SLaterUrl = webModule:AddPersonalInfoPropertyAndPlaceholder(SLaterUrl, webModule.h5Parameter.version, webModule.h5Parameter.version)
  SLaterUrl = webModule:AddPersonalInfoPropertyAndPlaceholder(SLaterUrl, webModule.h5Parameter.language, webModule.h5Parameter.language)
  SLaterUrl = SLaterUrl .. "&never_adjust=1"
  SLaterUrl = webModule:AddParameterByPersonalInfo(SLaterUrl, true) .. "#/team/eagleEye"
  log(bWriteLog and "  :SLaterUrl" .. tostring(SLaterUrl))
  if GameStatus.IsInFightingStatus() then
    local SettingSystem = require("client.logic.setting.logic_setting")
    SettingSystem.ConfirmBackLobby()
  else
    webModule:OpenEagleWeb()
  end
end
function webModule:OpenEagleWeb()
  if SLaterUrl then
    log(bWriteLog and "  :SLaterUrl" .. tostring(SLaterUrl))
    GlobalData.JumpUrl(SLaterUrl)
    SLaterUrl = nil
  end
end
function webModule:GetTotalOpenSecond()
  return webModule.totalSecond or 0
end
function webModule:CheckNeedTiming(url)
  local needTime = false
  webModule.openUrlTime = nil
  webModule.totalSecond = nil
  if _string.find(url, "need_timing=1") ~= nil then
    needTime = true
  end
  if needTime then
    local TimeUtil = require("client.common.time_util")
    webModule.openUrlTime = TimeUtil.OSTime()
  end
end
function webModule:RestoreFromWebPage(str)
  log(bWriteLog and "WebSystem.RestoreFromWebPage str = " .. tostring(str))
  GlobalData.RestoreLobbyBGM()
  local SDKMacro = require("client.slua.config.ClientMacros.SDKMacros")
  if str ~= SDKMacro.IMSDKWebviewAction.EnterFullScreen and str ~= SDKMacro.IMSDKWebviewAction.ExitFullScreen then
    log(bWriteLog and "WebSystem.RestoreFromWebPage 1")
    EventSystem:postEvent(EVENTTYPE_WEB, EVENTID_WEB_REACTIVATED, str)
    if self.needLogoutOnCloseWeb == true and GameStatus.GetGameStatus() == GameStatus.Login then
      log(bWriteLog and "WebSystem.RestoreFromWebPage needLogoutOnCloseWeb")
      NetUtil.Disconnect()
      gem_report_utils.ReportEventDelay(gem_report_utils.EventName_Network, "disconnect", "h5")
      local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
      login_module:sendLogout()
      self.needLogoutOnCloseWeb = false
    end
  end
  if str == SDKMacro.IMSDKWebviewAction.Close and webModule.openUrlTime then
    local TimeUtil = require("client.common.time_util")
    local now = TimeUtil.OSTime()
    webModule.totalSecond = now - webModule.openUrlTime
  end
  if str == SDKMacro.IMSDKWebviewAction.Close or str == SDKMacro.IMSDKWebviewAction.EnterFullScreen or str == SDKMacro.IMSDKWebviewAction.ExitFullScreen or str == SDKMacro.IMSDKWebviewAction.OpenFailed then
    EventSystem:postEvent(EVENTTYPE_WEBVIEWACTION, EVENTID_WEBVIEWACTION, str)
  else
    log(bWriteLog and "WebSystem.RestoreFromWebPage 2")
    self:AddTimerOnce(0.5, function()
      log(bWriteLog and "WebSystem.RestoreFromWebPage 3")
      local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
      ActivityNewSystem.HandleH5WebViewJson(str)
    end)
  end
  if str == SDKMacro.IMSDKWebviewAction.OpenFailed then
    ShowNotice(9891)
  end
  local logic_vng_personal_info = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_vng_personal_info)
  logic_vng_personal_info:CheckVNGPersonalProfile()
end
function webModule:URLEncode(str)
  log(bWriteLog and "webModule:URLEncode, before str = " .. tostring(str))
  if str ~= nil then
    str = string.gsub(str, "([^%w%.%- ])", function(c)
      return string.format("%%%02x", string.byte(c))
    end)
    str = string.gsub(str, " ", "+")
  end
  log(bWriteLog and "webModule:URLEncode, after str = " .. tostring(str))
  return str
end
function webModule:URLDecode(str)
  log(bWriteLog and "webModule:URLDecode, before str = " .. tostring(str))
  if str ~= nil then
    str = string.gsub(str, "+", " ")
    str = string.gsub(str, "%%(%x%x)", function(h)
      return string.char(tonumber(h, 16))
    end)
  end
  log(bWriteLog and "webModule:URLDecode, after str = " .. tostring(str))
  return str
end
function webModule:GetEncryptedDeviceInfoUrlValue(entrance, template, encrypt_method)
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  local TimeUtil = require("client.common.time_util")
  local StringUtil = require("common.string_util")
  local encrypt_util = require("client.common.encrypt_util")
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if encrypt_method == nil then
    encrypt_method = self:GetDefaultEncryptMetod()
  end
  if _string.find(template, "{device_name}") ~= nil then
    local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
    local device_name = DevicePlatformNameMacros.GetDeviceName()
    template = _string.StrReplace(template, "{device_name}", device_name, 1)
  end
  if _string.find(template, "{device_id}") ~= nil then
    local device_id = Client.GetPhoneDeviceID()
    template = _string.StrReplace(template, "{device_id}", device_id, 1)
  end
  if _string.find(template, "{info_time}") ~= nil then
    local clientTimeStamp = TimeUtil.OSTime()
    template = _string.StrReplace(template, "{info_time}", tostring(clientTimeStamp), 1)
  end
  if _string.find(template, "{xwid}") ~= nil then
    local xid = ""
    if Client.GetPublishRegion() ~= PublishRegionMacros.BLUEHOLE then
      local DeviceOSInfo = require("client.logic.data.data_device_os")
      xid = DeviceOSInfo.GetXID()
    end
    template = _string.StrReplace(template, "{xwid}", xid, 1)
  end
  if _string.find(template, "{openid}") ~= nil then
    local BusinessHelper = import("BusinessHelper")
    local openid = BusinessHelper.GetOpenId() or ""
    template = _string.StrReplace(template, "{openid}", openid, 1)
  end
  local deviceDataStr = template
  log(bWriteLog and "webModule:GetEncryptedDeviceInfoUrlValue, deviceDataStr: " .. tostring(deviceDataStr))
  local data_enc = ""
  if encrypt_method == 1 then
    local xor_key = "e1ad0b6401d97bf9d3db38b37627548b0996e10d8abe4ec4bd2f66e431326162a7d1605b6eb920d7dafb02d70092de62d29d6b17fdecf0b55c684b3527a43d49"
    if entrance == 2 then
      xor_key = "56d319858332f71568bd1f69a69bd08bf8fd384b73eba9afd4e2f4f1db7deccb27d028b0fd546faad6b473a5902b6de78a012e52467e8260e3aa0d8786d711cf"
    elseif entrance == 3 then
      xor_key = "bf2c7efabeb57ecea65760c9f6c0c2de5b29d9e13201c7dd0a96d334c81253afd85d02a7a6fcc8f3851c022b4666945e6a93c584a6057614321a55337b1d60d6"
    end
    data_enc = StringUtil.EncodeXOR(deviceDataStr, true, xor_key)
  elseif encrypt_method == 2 then
    data_enc = encrypt_util:TEA2Encryption(deviceDataStr, true)
    data_enc = self:URLEncode(data_enc)
  elseif encrypt_method == 3 then
    data_enc = encrypt_util:RSAEncryption(deviceDataStr, true)
    data_enc = self:URLEncode(data_enc)
  end
  return data_enc
end
function webModule:GetDefaultEncryptMetod()
  local encrypt_method = HDmpveRemote.HDmpveRemoteConfigGetInt("SecMethod", 3)
  return encrypt_method
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CWebModule = class(CModuleBase, nil, webModule)
return CWebModule