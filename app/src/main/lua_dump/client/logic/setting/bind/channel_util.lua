local channel_util = {}
local SettingAccount = require("client.logic.setting.logic_setting_account")
local local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
local PlatformName = Client and Client.GetDevicePlatformName()
local strRegion = Client and Client.GetPublishRegion()
local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
local channel2Path = {
  [ShareSource.Facebook] = "/Game/UMG/Texture_200/Atlas/LoginUI/Frames/Login_FB_png.Login_FB_png",
  [ShareSource.Twitter] = "/Game/UMG/Texture_200/Atlas/LoginUI/Frames/Login_TW_png.Login_TW_png",
  [ShareSource.Noschat] = "/Game/UMG/Texture_200/Atlas/LoginUI/Frames/Login_noschat_png.Login_noschat_png",
  [ShareSource.VK] = "/Game/UMG/Texture_200/Atlas/LoginUI/Frames/Login_VK_png.Login_VK_png",
  [ShareSource.GooglePlay] = "/Game/UMG/Texture_200/Atlas/LoginUI/Frames/Login_GG_png.Login_GG_png",
  [ShareSource.GameCenter] = "/Game/UMG/Texture_200/Atlas/LoginUI/Frames/Login_GC_png.Login_GC_png",
  [ShareSource.Line] = "/Game/UMG/Texture_200/Atlas/LoginUI/Frames/Login_line_png.Login_line_png",
  [ShareSource.Guest] = "/Game/UMG/Texture_200/Atlas/LoginUI/Frames/login_youke_png.login_youke_png",
  [ShareSource.BgBg] = "/Game/UMG/Texture_200/Atlas/LoginUI/Frames/Login_BGBG_png.Login_BGBG_png",
  [ShareSource.Hms] = "/Game/UMG/Texture_200/Atlas/LoginUI/Frames/Login_term_001_png.Login_term_001_png",
  [ShareSource.Discord] = "/Game/UMG/Texture_200/Atlas/LoginUI/Frames/Login_discord_png.Login_discord_png",
  [ShareSource.Scan] = "/Game/UMG/Texture_200/Atlas/LoginUI/Frames/Login_ScanCode_png.Login_ScanCode_png",
  [ShareSource.Apple] = "/Game/UMG/Texture_200/Atlas/LoginUI/Frames/Login_icon_apple_png.Login_icon_apple_png",
  [ShareSource.Whatsapp] = "/Game/UMG/Texture_200/Atlas/LoginUI/Frames/Login_Icon_Whatsapp_png.Login_Icon_Whatsapp_png",
  [ShareSource.TikTok] = "/Game/UMG/Texture_200/Atlas/LoginUI/Frames/Login_TikTok_png.Login_TikTok_png"
}
local Show_All_Login_Btn = HDmpveRemote.HDmpveRemoteConfigGetBool("Show_All_Login_Btn", false)
local Macros = {
  "Hide",
  "IsAos",
  "IsIos",
  "IsAos5Lower",
  "IsIos13Lower",
  "notInstalled",
  "DisableDiscordLogin",
  "IsGlobal",
  "NotThirdParty",
  "IsJk",
  "IsBlueHole",
  "IsCE",
  "NotIosCheck",
  "IsAmazon",
  "IsHiddenIP",
  "Close950004",
  "NotJk",
  "IsFit"
}
local channelToFunc = {
  apple = "IsAlreadyBindApple",
  gamecenter = "IsAlreadyBindGameCenter",
  googleplay = "IsAlreadyBindGooglePlay",
  twitter = "IsAlreadyBindTwitter",
  facebook = "IsAlreadyBindFB",
  [ShareSource.Noschat] = "IsAlreadyBindNosChat",
  vk = "IsAlreadyBindVK",
  [ShareSource.BgBg] = "IsAlreadyBindBgBg",
  discord = "IsAlreadyBindDiscord",
  line = "IsAlreadyBindLine",
  whatsapp = "IsAlreadyBindWhatsApp",
  tiktok = "IsAlreadyBindTikTok"
}
local StringUtil = require("common.string_util")
local 
function channel_util.GetIconByChannel(channel)
  channel = channel or ShareSource.Guest
  return channel2Path[channel]
end
function channel_util.HideWithCondition(condition, channel)
  local subConditions = StringUtil.Split(condition, "_")
  for _, funcIndex in ipairs(subConditions) do
    local funcName = Macros[tonumber(funcIndex)]
    local func = channel_util[funcName]
    if not func then
      log_error("bind_util LoginHideCfg channel is error" .. tostring(channel))
      return true
    end
    if not func(channel) then
      log(bWriteLog and "  channel_util.HideWithCondition false. condition: " .. tostring(condition))
      return false
    end
  end
  return true
end
function channel_util.CanShowLogin(channel)
  log(bWriteLog and "  bind_util.CanShowLogin. channel: " .. tostring(channel))
  if not channel then
    return false
  end
  if channel == ShareSource.Apple and Client.IsIOSVersionAbove13() and strRegion ~= PublishRegionMacros.CE and strRegion ~= PublishRegionMacros.FITCE then
    return true
  end
  local cfg = CDataTable.GetTableData("LoginHideCfg", channel)
  if not cfg then
    return true
  end
  local Rule_an = cfg.Rule_an
  for _, condition in pairs(Rule_an) do
    if channel_util.HideWithCondition(condition, channel) then
      return false
    end
  end
  return true
end
local convertChannelTb = {
  [ShareSource.Noschat] = "noschat",
  [ShareSource.BgBg] = "bgbg"
}
function channel_util.CanShowBind(channel)
  log(bWriteLog and "  bind_util.CanShowBind. channel: " .. tostring(channel))
  if not channel then
    return false
  end
  local hideCfg = {
    [ShareSource.Guest] = 1,
    [ShareSource.Scan] = 1
  }
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if channel_util.IsChannelBind(channel) and not PublishRegionMacros.IsCEVersion() then
    printf("channel_util.CanShowBind. binded return")
    return false
  end
  local fchannel = tostring(SettingAccount.sFirstChannel)
  if fchannel then
    hideCfg[fchannel] = 1
  end
  local schannel = tostring(SettingAccount.sSecondChannel)
  if schannel then
    hideCfg[schannel] = 1
  end
  if hideCfg[channel] then
    log(bWriteLog and "  channel_util.CanShowBind.  hide")
    return false
  end
  if convertChannelTb[channel] then
    channel = convertChannelTb[channel]
    log(bWriteLog and "  channel_util.CanShowBind.convertChannelTb channel: " .. tostring(channel))
  end
  local cfg = CDataTable.GetTableData("BindHideCfg", channel)
  if not cfg then
    return true
  end
  local Rule_an = cfg.Rule_an
  for _, condition in pairs(Rule_an) do
    if channel_util.HideWithCondition(condition, channel) then
      return false
    end
  end
  return true
end
function channel_util.Hide()
  return true
end
function channel_util.IsAos()
  return PlatformName == DevicePlatformNameMacros.Android
end
function channel_util.IsIos()
  return PlatformName == DevicePlatformNameMacros.IOS
end
function channel_util.IsAos5Lower()
  local device_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.device_module)
  local OSMajorVersion = device_module:GetOSMajorVersion()
  return OSMajorVersion < 6
end
function channel_util.IsIos13Lower()
  return channel_util.IsIos() and not Client.IsIOSVersionAbove13()
end
function channel_util.notInstalled(channel)
  if Show_All_Login_Btn then
    return false
  end
  local result = false
  if channel == ShareSource.Discord then
    result = not Client.IsInstallDiscord(NetInterface)
  elseif not slua_GameFrontendHUD:IsInstallPlatform(channel) then
    result = true
  end
  log(bWriteLog and "  bind_util.notInstalled. result: " .. tostring(result))
  return result
end
function channel_util.DisableDiscordLogin()
  local enbaleDiscordByRemoteConfig = HDmpveRemote.HDmpveRemoteConfigGetBool("EnableDiscordLogin", false)
  return not enbaleDiscordByRemoteConfig
end
function channel_util.IsGlobal()
  return strRegion == PublishRegionMacros.GLOBAL or strRegion == PublishRegionMacros.FIT
end
function channel_util.IsFit()
  return strRegion == PublishRegionMacros.FIT
end
function channel_util.NotThirdParty()
  local BusinessHelper = import("BusinessHelper")
  return BusinessHelper == nil or BusinessHelper.GetAOSSHOPID() ~= 2
end
function channel_util.IsJk()
  return PublishRegionMacros.IsJapanOrKorea()
end
function channel_util.NotJk()
  return not PublishRegionMacros.IsJapanOrKorea()
end
function channel_util.IsBlueHole()
  return PublishRegionMacros.IsBLUEHOLE()
end
function channel_util.IsCE()
  return PublishRegionMacros.IsCEVersion()
end
function channel_util.NotIosCheck()
  return not GlobalData.IsIOSCheck()
end
function channel_util.IsAmazon()
  local BusinessHelper = import("BusinessHelper")
  if PlatformName == DevicePlatformNameMacros.Android and BusinessHelper.GetAOSSHOPID() == 5 then
    return true
  end
  return false
end
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
function channel_util.IsHiddenIP()
  local HideGuestButtonIPTb = {
    [356] = 1,
    [156] = 1
  }
  local HideGuestButtonChannelTb = {HMS = 1}
  local HideGuestButtonIPIOSTb = {
    [156] = 1
  }
  if Client.IsCloudVersion() and not IsHideBgBgGuest() then
    HideGuestButtonIPTb[156] = nil
  end
  local iTOP_country_no = Client.GetIPRegion()
  local result = false
  if PlatformName == DevicePlatformNameMacros.Android then
    if strRegion == PublishRegionMacros.GLOBAL or strRegion == PublishRegionMacros.BLUEHOLE or strRegion == PublishRegionMacros.FIT then
      local aosShop = Client.GetAOSSHOP()
      if HideGuestButtonIPTb[iTOP_country_no] then
        result = true
      elseif HideGuestButtonChannelTb[aosShop] then
        result = true
      end
    end
  elseif (strRegion == PublishRegionMacros.GLOBAL or strRegion == PublishRegionMacros.FIT) and HideGuestButtonIPIOSTb[iTOP_country_no] then
    result = true
  end
  log(bWriteLog and "  bind_util.IsHiddenIP. result: " .. tostring(result))
  return result
end
function channel_util.Close950004()
  return not LobbySystem.CheckOpen(950004)
end
function channel_util.IsChannelBind(channel)
  log(bWriteLog and "  channel_util.IsChannelBind.  channel: " .. tostring(channel) .. "")
  if not Client.IsReleaseVersion(NetInterface) then
    local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
    if login_module.gmLoginChannel == channel then
      log(bWriteLog and "  channel_util.IsChannelBind.  use gm")
      return true
    end
  end
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  local funcName = channelToFunc[channel]
  if not funcName then
    log(bWriteLog and string.format("channel_util.IsChannelBind, not funcName channel:%s", channel))
    return false
  end
  if not IMSDKHelperInstance[funcName] then
    log(bWriteLog and "channel_util.IsChannelBind return of sdk not find func")
    return false
  end
  if not IMSDKHelperInstance[funcName](IMSDKHelperInstance) then
    log(bWriteLog and "channel_util.IsChannelBind return of sdk not bind")
    return false
  end
  return true
end
return channel_util