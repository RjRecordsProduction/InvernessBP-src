local dolphin_updater_config = {dolphin_channel_id = 0}
function dolphin_updater_config:GetIntConfigFromIni(key)
  return Client.GetConfigInt(Client.ProjectDir() .. "Config/DefaultUpdater.ini", "/Script/Client.GDolphinUpdater", key)
end
function dolphin_updater_config:GetStrConfigFromIni(key)
  return Client.GetConfigString(Client.ProjectDir() .. "Config/DefaultUpdater.ini", "/Script/Client.GDolphinUpdater", key)
end
function dolphin_updater_config:GetDolphinChannelId()
  if self.dolphin_channel_id == 0 then
    local key = "UpdateChannelAndroid"
    local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
    if Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS then
      key = "UpdateChannelIOS"
    end
    self.dolphin_channel_id = self:GetIntConfigFromIni(key)
  end
  log(bWriteLog and "GetDolphinChannelId: " .. tostring(self.dolphin_channel_id))
  return self.dolphin_channel_id
end
function dolphin_updater_config:GetAppStoreUrl()
  local url = ""
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS then
    url = dolphin_updater_config:GetStrConfigFromIni("AppStoreUrl")
  else
    local AOSSHOPMacros = require("client.slua.config.ClientMacros.AOSSHOPMacros")
    local AOSShop = Client.GetAOSSHOP()
    local DolphinConfig = require("client.slua.umg.NewUpdate.dolphin_updater_config")
    url = DolphinConfig:GetStrConfigFromIni("GooglePlayUrl")
    if AOSShop == AOSSHOPMacros.Samsung then
      url = DolphinConfig:GetStrConfigFromIni("SamSungPlayUrl")
    elseif AOSShop == AOSSHOPMacros.Amazon then
      url = DolphinConfig:GetStrConfigFromIni("AmazonPlayUrl")
    elseif AOSShop == AOSSHOPMacros.HMS then
      url = DolphinConfig:GetStrConfigFromIni("HMSPlayUrl")
    end
  end
  return url
end
function dolphin_updater_config:ExecuteDolphinInitParameters()
  local gameInstance = slua.getGameInstance()
  local strategy = 100
  local AppUpdateConfigFuncDic = {
    uDLMaxTaskNum = 1,
    uDLMaxPerTaskNum = 25,
    uDLPollingTime = 5000,
    bUseDLProConfig = strategy,
    OptiHttpConfig_uEnableAverageShardingStrategy = strategy,
    OptiHttpConfig_uEnableReuseRedirectHttp = strategy,
    OptiHttpConfig_uEnableDynamicExpansionMaxTask = strategy,
    OptiHttpConfig_uAverageShardingSize = 3145728
  }
  gameInstance:ExecuteCMD("s.DolphinAppUpdateFuncDic", json.encode(AppUpdateConfigFuncDic))
  local ResUpdateConfigFuncDic = {
    uDLMaxTaskNum = 3,
    uDLMaxPerTaskNum = 9,
    uDLPollingTime = 5000,
    bUseDLProConfig = strategy,
    OptiHttpConfig_uEnableAverageShardingStrategy = strategy,
    OptiHttpConfig_uEnableReuseRedirectHttp = strategy,
    OptiHttpConfig_uEnableDynamicExpansionMaxTask = strategy,
    OptiHttpConfig_uAverageShardingSize = 3145728
  }
  gameInstance:ExecuteCMD("s.DolphinResUpdateFuncDic", json.encode(ResUpdateConfigFuncDic))
  gameInstance:ExecuteCMD("n.DolphinDownloadJsonTimeout", HDmpveRemote.HDmpveRemoteConfigGetInt("DJsonTimeout", 10000000))
  gameInstance:ExecuteCMD("n.DolphinDownloadJsonType", HDmpveRemote.HDmpveRemoteConfigGetInt("DJsonType", 2))
  gameInstance:ExecuteCMD("n.DolphinDownloadJsonRetryTimes", HDmpveRemote.HDmpveRemoteConfigGetInt("DJsonRetryTimes", 4))
  gameInstance:ExecuteCMD("n.DolphinDownloadEngine", HDmpveRemote.HDmpveRemoteConfigGetInt("DolphinDownloadEngine", 6))
end
return dolphin_updater_config