local Channel_Id = {
  [1] = BP_ENUM_IMSDK_CHANNEL_FACEBOOK,
  [2] = BP_ENUM_IMSDK_CHANNEL_TWITTER,
  [3] = BP_ENUM_IMSDK_CHANNEL_GAMECENTER,
  [4] = BP_ENUM_IMSDK_CHANNEL_GOOGLEPLAY,
  [5] = BP_ENUM_IMSDK_CHANNEL_NOSCHAT,
  [6] = BP_ENUM_IMSDK_CHANNEL_VK,
  [7] = BP_ENUM_IMSDK_CHANNEL_LINE,
  [8] = BP_ENUM_IMSDK_CHANNEL_GUEST,
  [9] = BP_ENUM_IMSDK_CHANNEL_BGBG,
  [10] = BP_ENUM_IMSDK_CHANNEL_APPLE,
  [11] = BP_ENUM_IMSDK_CHANNEL_HMS,
  [12] = BP_ENUM_IMSDK_CHANNEL_DISCORD,
  [13] = BP_ENUM_IMSDK_CHANNEL_WHATS,
  [14] = BP_ENUM_IMSDK_CHANNEL_TIKTOK
}
local channel2Name = {
  [BP_ENUM_IMSDK_CHANNEL_FACEBOOK] = ShareSource.Facebook,
  [BP_ENUM_IMSDK_CHANNEL_TWITTER] = ShareSource.Twitter,
  [BP_ENUM_IMSDK_CHANNEL_GAMECENTER] = ShareSource.GameCenter,
  [BP_ENUM_IMSDK_CHANNEL_GOOGLEPLAY] = ShareSource.GooglePlay,
  [BP_ENUM_IMSDK_CHANNEL_NOSCHAT] = ShareSource.Noschat,
  [BP_ENUM_IMSDK_CHANNEL_VK] = ShareSource.VK,
  [BP_ENUM_IMSDK_CHANNEL_LINE] = ShareSource.Line,
  [BP_ENUM_IMSDK_CHANNEL_GUEST] = ShareSource.Guest,
  [BP_ENUM_IMSDK_CHANNEL_BGBG] = ShareSource.BgBg,
  [BP_ENUM_IMSDK_CHANNEL_APPLE] = ShareSource.Apple,
  [BP_ENUM_IMSDK_CHANNEL_HMS] = ShareSource.Hms,
  [BP_ENUM_IMSDK_CHANNEL_DISCORD] = ShareSource.Discord,
  [BP_ENUM_IMSDK_CHANNEL_WHATS] = ShareSource.Whatsapp,
  [BP_ENUM_IMSDK_CHANNEL_TIKTOK] = ShareSource.TikTok
}
local login_platform_trans_map = {
  [BP_ENUM_PLAYFORM_MORE] = 0,
  [BP_ENUM_PLAYFORM_WX] = BP_ENUM_IMSDK_CHANNEL_NOSCHAT,
  [BP_ENUM_PLAYFORM_BGBG] = BP_ENUM_IMSDK_CHANNEL_FACEBOOK,
  [BP_ENUM_PLAYFORM_TOURIST] = BP_ENUM_IMSDK_CHANNEL_GUEST,
  [BP_ENUM_PLAYFORM_GAMECENTER] = BP_ENUM_IMSDK_CHANNEL_GAMECENTER,
  [BP_ENUM_PLAYFORM_GOOGLEPLAY] = BP_ENUM_IMSDK_CHANNEL_GOOGLEPLAY,
  [BP_ENUM_PLAYFORM_TWITTER] = BP_ENUM_IMSDK_CHANNEL_TWITTER,
  [BP_ENUM_PLAYFORM_VK] = BP_ENUM_IMSDK_CHANNEL_VK,
  [BP_ENUM_PLAYFORM_LINE] = BP_ENUM_IMSDK_CHANNEL_LINE,
  [BP_ENUM_PLAYFORM_BGBGByiTOP] = BP_ENUM_IMSDK_CHANNEL_BGBG,
  [BP_ENUM_PLAYFORM_AppleByiTOP] = BP_ENUM_IMSDK_CHANNEL_APPLE,
  [BP_ENUM_PLAYFORM_UnifiedAccountByiTOP] = BP_ENUM_IMSDK_CHANNEL_UNIFIEDACCOUNT,
  [BP_ENUM_PLAYFORM_HMSByiTOP] = BP_ENUM_IMSDK_CHANNEL_HMS,
  [BP_ENUM_PLAYFORM_DiscordByiTOP] = BP_ENUM_IMSDK_CHANNEL_DISCORD,
  [BP_ENUM_PLAYFORM_WHATSAPP] = BP_ENUM_IMSDK_CHANNEL_WHATS,
  [BP_ENUM_PLAYFORM_TIKTOK] = BP_ENUM_IMSDK_CHANNEL_TIKTOK
}
local Unbind_Mgr = {
  channel_index = 0,
  unbind_time = 0,
  unbind_channel = 0,
  login_channel = 0,
  is_open = false
}
Unbind_Mgr.
function Unbind_Mgr.GetNameByChannelID(channelID)
  log(bWriteLog and "Unbind_Mgr.GetNameByChannelID. channelID: " .. tostring(channelID))
  if type(channelID) ~= "number" then
    channelID = tonumber(channelID)
  end
  return channel2Name[channelID]
end
function Unbind_Mgr.GetBindList()
  local already_bind = {}
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  if IMSDKHelperInstance:IsAlreadyBindFB() then
    table.insert(already_bind, 1)
  end
  if IMSDKHelperInstance:IsAlreadyBindTwitter() then
    table.insert(already_bind, 2)
  end
  if IMSDKHelperInstance:IsAlreadyBindGameCenter() then
    table.insert(already_bind, 3)
  end
  if IMSDKHelperInstance:IsAlreadyBindGooglePlay() then
    table.insert(already_bind, 4)
  end
  if IMSDKHelperInstance:IsAlreadyBindNosChat() then
    table.insert(already_bind, 5)
  end
  if IMSDKHelperInstance:IsAlreadyBindVK() then
    table.insert(already_bind, 6)
  end
  if IMSDKHelperInstance:IsAlreadyBindLine() then
    table.insert(already_bind, 7)
  end
  if IMSDKHelperInstance:IsAlreadyBindBgBg() then
    table.insert(already_bind, 9)
  end
  if IMSDKHelperInstance:IsAlreadyBindApple() then
    table.insert(already_bind, 10)
  end
  if IMSDKHelperInstance:IsAlreadyBindWhatsApp() then
    table.insert(already_bind, 13)
  end
  if IMSDKHelperInstance:IsAlreadyBindDiscord() then
    table.insert(already_bind, 12)
  end
  if IMSDKHelperInstance:IsAlreadyBindTikTok() then
    table.insert(already_bind, 14)
  end
  local isLoginSocialPlatform = 0
  for k, v in ipairs(already_bind) do
    if Channel_Id[v] == Unbind_Mgr.login_channel then
      table.remove(already_bind, k)
      isLoginSocialPlatform = 1
      break
    end
  end
  return already_bind, isLoginSocialPlatform
end
function Unbind_Mgr._GMGetBindList()
  local AlreadyBind = {
    "1.facebook",
    "2.twitter",
    "3.gamecenter",
    "4.googleplay",
    "5.noschat",
    "6.vk",
    "7.line",
    "8.guest",
    "9.bgbg",
    "10.apple",
    "11.hms",
    "12.discord",
    "13.tiktok"
  }
  log_format(bWriteLog and "Unbind_Mgr.GMGetBindList: return all channels, count:%s", #AlreadyBind)
  return AlreadyBind
end
function Unbind_Mgr.GetChannel(index)
  return Channel_Id[index]
end
function Unbind_Mgr.SetIndexByChannel(channel)
  Unbind_Mgr.channel_index = 0
  for k, v in pairs(Channel_Id) do
    if v == channel then
      Unbind_Mgr.channel_index = k
      break
    end
  end
end
function Unbind_Mgr.SyncUnbindData(data)
  if data and type(data) == "table" and data.req_ts and data.req_channel then
    Unbind_Mgr.unbind_time = data.req_ts
    Unbind_Mgr.unbind_channel = data.req_channel
  else
    Unbind_Mgr.unbind_time = 0
    Unbind_Mgr.unbind_channel = 0
  end
end
function Unbind_Mgr.GetChannelIdByLoginPlatform(platform)
  if not platform or not login_platform_trans_map[platform] then
    return 0
  else
    return login_platform_trans_map[platform]
  end
end
function Unbind_Mgr.SyncUnbindTime(time)
  if Unbind_Mgr.channel_index and Channel_Id[Unbind_Mgr.channel_index] then
    Unbind_Mgr.unbind_    Unbind_Mgr.unbind_channel = Channel_Id[Unbind_Mgr.channel_index]
    local SettingSystem = require("client.logic.setting.logic_setting")
    SettingSystem.NewRefreshBindInfo()
  end
end
function Unbind_Mgr.SyncUnbindOpen(sever_flag)
  Unbind_Mgr.is_open = sever_flag or false
end
return Unbind_Mgr