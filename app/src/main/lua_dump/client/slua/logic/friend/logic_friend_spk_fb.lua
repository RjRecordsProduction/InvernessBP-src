local logic_friend_spk_fb = {}
function logic_friend_spk_fb:OnInitialize()
  log(bWriteLog and "logic_friend_spk_fb:OnInitialize")
end
function logic_friend_spk_fb:OnDestroy()
  log(bWriteLog and "logic_friend_spk_fb:OnDestroy")
end
function logic_friend_spk_fb:RegistEvents()
  log(bWriteLog and "logic_friend_spk_fb:RegistEvents")
  self:AddCommonEvent(EVENTTYPE_WEBVIEW, EVENTID_CLOSEWEBVIEW_FROMH5, self.OnCloseWebview, self)
end
function logic_friend_spk_fb:proc_notify_rela_need_login(iNeedLogin)
  log(bWriteLog and "logic_friend_spk_fb:proc_notify_rela_need_login " .. tostring(iNeedLogin))
  self.end
function logic_friend_spk_fb:IsValid()
  log(bWriteLog and "logic_friend_spk_fb:IsValid" .. tostring(self.iNeedLogin))
  local ModuleManager = require("client.module_framework.ModuleManager")
  local logic_cloud_game = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cloud_game)
  local bIsCloudVersion = logic_cloud_game:IsCloudVersion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local PRegion = Client.GetPublishRegion()
  local bIsPublishFIT = PRegion == PublishRegionMacros.FITCE or PRegion == PublishRegionMacros.FIT
  log(bWriteLog and "logic_friend_spk_fb:IsValid region" .. tostring(PRegion))
  return bIsCloudVersion or bIsPublishFIT or self.bForceValid
end
function logic_friend_spk_fb:ForceValid(inValue)
  self.bForceValid = inValue
end
function logic_friend_spk_fb:NeedShowRefresh()
  log(bWriteLog and "logic_friend_spk_fb:NeedShowRefresh" .. tostring(self.iNeedLogin))
  if self:IsValid() then
    if self.iNeedLogin == 1 then
      return true
    end
    return false
  else
    log(bWriteLog and "logic_friend_spk_fb:NeedShowRefresh not FIT")
    return false
  end
end
function logic_friend_spk_fb:GetH5Url()
  log(bWriteLog and "logic_friend_spk_fb:GetH5Url")
  local loginUrlDomainId = 3366226
  local loginUrl = FuncUtil.GetDomainByID(loginUrlDomainId)
  if Client.GetIMSDKEnv() == 0 or loginUrl == "" then
    loginUrlDomainId = 3366225
    loginUrl = FuncUtil.GetDomainByID(loginUrlDomainId)
  end
  local ModuleManager = require("client.module_framework.ModuleManager")
  local webModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.webModule)
  local gameid = Client.GetITopGameId()
  local areaid = DataMgr.roleData.idip_area_id
  local sign = webModule:SignOpenidAndLanguage()
  local lang = webModule:GetCurrentLanguage()
  local url = string.format("%s?gameid=%s&areaid=%s&from=%s&lang=%s", loginUrl, gameid, tostring(areaid), sign, lang)
  log(bWriteLog and "URL: " .. tostring(url))
  return url
end
function logic_friend_spk_fb:LaunchLoginAutho()
  log(bWriteLog and "logic_friend_spk_fb:LaunchLoginAutho")
  local ScriptHelperClient = import("ScriptHelperClient")
  if ScriptHelperClient.ClearH5WebViewCookie then
    ScriptHelperClient.ClearH5WebViewCookie(".facebook.com")
  end
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  local isAndroid = Client.GetDevicePlatformName() == DevicePlatformNameMacros.Android
  if isAndroid then
    local appDataDir = Client.GetInternalFilesDir() .. "/.."
    local cookiePath = appDataDir .. "/app_webview_imsdk_inner_webview/Default/Cookies"
    log(bWriteLog and "logic_friend_spk_fb:LaunchLoginAutho cookiePath: " .. tostring(cookiePath))
    os.remove(cookiePath)
  end
  local webModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.webModule)
  Client.OpenURLInSDK(self:GetH5Url(), true, false, true, "{}")
  self.isInProgress = true
end
function logic_friend_spk_fb:OnCloseWebview(_, _, str)
  log(bWriteLog and "logic_friend_spk_fb:OnCloseWebview  " .. tostring(str))
  if not self:IsValid() then
    return
  end
  if not self.isInProgress then
    log(bWriteLog and "logic_friend_spk_fb:OnCloseWebview not in progress")
    return
  end
  self.isInProgress = false
  if str == nil or str == "" then
    log(bWriteLog and "logic_friend_spk_fb:OnCloseWebview nil")
    return
  end
  local url
  local result = json.decode(str)
  if result ~= nil then
    log(bWriteLog and "logic_friend_spk_fb:OnCloseWebviews result ~= nil")
    url = result.url
  else
    log(bWriteLog and "logic_friend_spk_fb:OnCloseWebviews result = nil")
  end
  log(bWriteLog and "logic_friend_spk_fb:OnCloseWebview url" .. tostring(url))
  if url == nil or url == "" then
    ShowNotice(51028)
    return
  end
  if self:VerifyLoginAutho(url) then
    local FriendHandler = require("client.network.Protocol.FriendHandler")
    FriendHandler:send_spk_grant_success_req()
    ShowNotice(8179)
  else
    log(bWriteLog and "logic_friend_spk_fb:OnCloseWebview failed")
    ShowNotice(18010137)
  end
end
function logic_friend_spk_fb:GetOpenIdFromDeeplink(deeplink)
  log(bWriteLog and "logic_friend_spk_fb:GetOpenIdFromDeeplink " .. tostring(deeplink))
  local openID = DataMgr.roleData.openID
  local StringUtil = require("common.string_util")
  local params = StringUtil.ParseURLParams(deeplink)
  if params.openid then
    openID = tostring(params.openid)
  else
    log(bWriteLog and "logic_friend_spk_fb:GetOpenIdFromDeeplink  failed to get openid")
  end
  return openID
end
function logic_friend_spk_fb:VerifyLoginAutho(deeplink)
  log(bWriteLog and "logic_friend_spk_fb:VerifyLoginAutho " .. tostring(deeplink))
  local openId = DataMgr.roleData.openID
  if not openId then
    log(bWriteLog and "logic_friend_spk_fb:VerifyLoginAutho failed no openid")
    return false
  end
  local authoOpenId = self:GetOpenIdFromDeeplink(deeplink)
  log(bWriteLog and "logic_friend_spk_fb:VerifyLoginAutho openid " .. tostring(authoOpenId))
  return tostring(openId) == tostring(authoOpenId)
end
function logic_friend_spk_fb:RefreshFriends()
  log(bWriteLog and "logic_friend_spk_fb:RefreshFriends")
  if not self:IsValid() then
    return
  end
  self.iNeedLogin = 0
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  LogicFriend.get_all_friendlist_req(true)
end
local class = require("class")
local ModuleBase = require("client.module_framework.ModuleBase")
return class(ModuleBase, nil, logic_friend_spk_fb)