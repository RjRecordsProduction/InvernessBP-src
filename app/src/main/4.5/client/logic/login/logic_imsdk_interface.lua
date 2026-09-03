local logic_imsdk_interface = {NeedToRecovertBGM = false}
function logic_imsdk_interface:NewLogin()
  return false
end
function logic_imsdk_interface:Login(loginType, extraJson, skipLocalCacheCheck)
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  local imsdkLoginChannelId = IMSDKHelperInstance:ConvertTConndChannel2IMSDKChannel(loginType)
  local device_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.device_module)
  local OSMajorVersion = device_module:GetOSMajorVersion()
  if Client.GetDevicePlatformName() == DevicePlatformNameMacros.Android and OSMajorVersion <= 7 then
    IMSDKHelperInstance:SetMSDKConfig({IMSDK_TWITTER_LOGIN_USING_WEB = "false"}, false)
  end
  if imsdkLoginChannelId == BP_ENUM_IMSDK_CHANNEL_VK then
    self.NeedToRecovertBGM = true
    self:StopBGM()
  else
    self.NeedToRecovertBGM = false
  end
  local useNewLogin = self:NewLogin()
  if useNewLogin then
    local permissions = {}
    local imsdkLoginChannelName = IMSDKHelperInstance:ConvertIMSDKChannelToStr(imsdkLoginChannelId, true)
    local imsdkLoginType = ""
    if imsdkLoginChannelId == BP_ENUM_IMSDK_CHANNEL_FACEBOOK then
      if not PublishRegionMacros.IsCEVersion() then
        if PublishRegionMacros.IsBLUEHOLE() then
          local EnableFBFriends = HDmpveRemote.HDmpveRemoteConfigGetBool("EnableFBFriends", false)
          if EnableFBFriends then
            permissions = {
              "user_friends"
            }
          end
        else
          permissions = {
            "user_friends"
          }
        end
      end
    elseif imsdkLoginChannelId == BP_ENUM_IMSDK_CHANNEL_MIGRATE then
      imsdkLoginType = imsdkLoginChannelName
      imsdkLoginChannelName = "Migrate"
    elseif imsdkLoginChannelId == BP_ENUM_IMSDK_CHANNEL_VK then
      permissions = {
        "WALL",
        "FRIENDS",
        "PHOTOS",
        "OFFLINE"
      }
      if not PublishRegionMacros.IsBLUEHOLE() then
        permissions.append("MESSAGES")
      end
    elseif imsdkLoginChannelId == BP_ENUM_IMSDK_CHANNEL_DISCORD and not PublishRegionMacros.IsGlobalVersion() and Client.GetDevicePlatformName() == DevicePlatformNameMacros.Android then
      permissions = {"IDENTIFY"}
    end
    if imsdkLoginChannelId ~= BP_ENUM_IMSDK_CHANNEL_MIGRATE then
      IMSDKHelperInstance:SetupLoginCacheInfo(imsdkLoginChannelId, false)
      IMSDKHelperInstance:SaveLastIMSDKChannelID(imsdkLoginChannelId)
    end
    if Client.IsMatchVersion() then
      local UKismetSystemLibrary = import("KismetSystemLibrary")
      local CVarUsingNoAuth = UKismetSystemLibrary.GetConsoleVariableIntValue("client.bUsingNoAuth")
      if CVarUsingNoAuth ~= 0 then
        return
      end
    end
    IMSDKHelperInstance:SetChannel(imsdkLoginChannelName)
    if imsdkLoginType ~= "" then
      IMSDKHelperInstance:SetLoginType(imsdkLoginType)
    end
    if extraJson == nil then
      local loginExtraObj = self:GetLoginExtraObj(imsdkLoginChannelId)
      extraJson = json.encode(loginExtraObj)
    end
    if skipLocalCacheCheck or self:ForbidLoginWithLocalCache(imsdkLoginChannelId) then
      IMSDKHelperInstance:OriginalLogin(extraJson, permissions, true)
    else
      IMSDKHelperInstance:ContinueLoginWithLocalResult()
    end
  else
    if extraJson == nil then
      local loginExtraObj = self:GetLoginExtraObj(imsdkLoginChannelId)
      extraJson = json.encode(loginExtraObj)
    end
    Client.LoginWithExtraInfo(NetInterface, loginType, extraJson, skipLocalCacheCheck)
  end
end
function logic_imsdk_interface:GetLoginExtraObj(imsdkLoginChannelId)
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local extraObj = {}
  if imsdkLoginChannelId == BP_ENUM_IMSDK_CHANNEL_GUEST then
    local xid = ""
    if not PublishRegionMacros.IsBLUEHOLE() then
      local DeviceOSInfo = require("client.logic.data.data_device_os")
      xid = DeviceOSInfo.GetXID()
    end
    if #xid ~= 64 then
      xid = ""
    end
    extraObj = {ugId = xid, ugId1 = ""}
  elseif imsdkLoginChannelId == BP_ENUM_IMSDK_CHANNEL_WHATS then
    extraObj = {
      langType = FuncUtil.TransLanguageToImsdkLanguage()
    }
  end
  return extraObj
end
function logic_imsdk_interface:ForbidLoginWithLocalCache(imsdkLoginChannelId)
  local ForbidLoginWithLocalCache = HDmpveRemote.HDmpveRemoteConfigGetBool("ForbidLoginWithLocalCache", false)
  if ForbidLoginWithLocalCache then
    return true
  end
  if imsdkLoginChannelId == BP_ENUM_IMSDK_CHANNEL_MIGRATE then
    return true
  end
  if Client.IsMatchVersion() then
    return true
  end
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  if IMSDKHelperInstance:CheckLocalForceLoginFlag(imsdkLoginChannelId) then
    return true
  end
  local imsdkLoginResult = IMSDKHelperInstance:GetLoginResult()
  if imsdkLoginResult.imsdkRetCode ~= 1 or imsdkLoginResult.guid_channel_id ~= imsdkLoginChannelId then
    return true
  end
  local TimeUtil = require("client.common.time_util")
  local currentTime = TimeUtil.OSTime()
  if currentTime + 86400 < imsdkLoginResult.guid_token_expire then
    return false
  else
    return true
  end
  return false
end
function logic_imsdk_interface:OnMSDKLogin()
  if self.NeedToRecovertBGM then
    self:RestoreBGM()
  end
end
function logic_imsdk_interface:RestoreBGM()
  log("logic_imsdk_interface:RestoreBGM")
  local userSettings = slua_GameFrontendHUD:GetUserSettings()
  local audio_util = require("client.common.audio_util")
  if userSettings.BGMVolumSwitcher then
    audio_util.SetRTPCValue("VolumeControl_Music", userSettings.BGMVolumValue * 100, 200)
    audio_util.SetRTPCValue("MusicPlayer_Volume", userSettings.BGMVolumValue, 200)
  else
    audio_util.SetRTPCValue("VolumeControl_Music", 0, 200)
    audio_util.SetRTPCValue("MusicPlayer_Volume", 0, 200)
  end
end
function logic_imsdk_interface:StopBGM()
  log("logic_imsdk_interface:StopBGM")
  local audio_util = require("client.common.audio_util")
  audio_util.SetRTPCValue("VolumeControl_Music", 20, 200)
  audio_util.SetRTPCValue("MusicPlayer_Volume", 0.2, 200)
end
return logic_imsdk_interface