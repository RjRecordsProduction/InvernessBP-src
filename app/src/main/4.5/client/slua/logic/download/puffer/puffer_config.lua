local puffer_config = {
  DOWNLOAD_PHASE = {
    NORMAL = 1,
    FIGHTING = 2,
    BASE = 3
  },
  CONST_BIG_FILE_MAX_DOWNLOAD_TASK = 3,
  CONST_BIG_FILE_MAX_DOWNLOAD_PER_TASK = 9,
  CONST_SMALL_FILE_MAX_DOWNLOAD_TASK = 7,
  CONST_SMALL_FILE_MAX_DOWNLOAD_PER_TASK = 4
}
local PufferSwitch = require("client.slua.logic.download.puffer_switch")
local PufferDefine = require("client.slua.logic.download.puffer.puffer_define")
function puffer_config:GetDefaultConfig(pufferDownlodPhase)
  local logic_http_dns = require("client.slua.logic.httpdns.logic_http_dns")
  local maxDownloadsPerTask = puffer_config.CONST_SMALL_FILE_MAX_DOWNLOAD_PER_TASK
  local maxDownTask = puffer_config.CONST_SMALL_FILE_MAX_DOWNLOAD_TASK
  local maxDownloadSpeed = 20971520
  local enableAverageShardingStrategy = 1
  local PufferDownloadFuncDictJson = ""
  maxDownloadsPerTask = HDmpveRemote.HDmpveRemoteConfigGetInt("PFRMaxDownloadsPerTask", maxDownloadsPerTask)
  maxDownTask = HDmpveRemote.HDmpveRemoteConfigGetInt("PFRMaxDownTask", maxDownTask)
  maxDownloadSpeed = HDmpveRemote.HDmpveRemoteConfigGetInt("PFRMaxDownloadSpeed", maxDownloadSpeed)
  enableAverageShardingStrategy = HDmpveRemote.HDmpveRemoteConfigGetInt("PFEnableAverageSharding", enableAverageShardingStrategy)
  local strategy = 100
  if enableAverageShardingStrategy ~= 1 then
    strategy = 0
  end
  local PufferDownloadFuncDict = {
    OptiHttpConfig_uEnableAverageShardingStrategy = strategy,
    OptiHttpConfig_uAverageShardingSize = 3145728,
    OptiHttpConfig_uEnableDynamicExpansionMaxTask = strategy,
    OptiHttpConfig_uEnableReuseRedirectHttp = strategy
  }
  PufferDownloadFuncDictJson = json.encode(PufferDownloadFuncDict)
  if pufferDownlodPhase == puffer_config.DOWNLOAD_PHASE.BASE then
    local baseNeedToDownloadFileList = PufferUpdater.GetNeedDownLoadFileList()
    if baseNeedToDownloadFileList == nil or #baseNeedToDownloadFileList == 0 then
      pufferDownlodPhase = puffer_config.DOWNLOAD_PHASE.NORMAL
    end
  end
  local downloadStageType = PufferDefine.PufferDownloadStageType.DownloadStageTypeUnknown
  if pufferDownlodPhase ~= nil and pufferDownlodPhase == puffer_config.DOWNLOAD_PHASE.BASE then
    downloadStageType = PufferDefine.PufferDownloadStageType.DownloadStageTypeLoading
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  local downloadEngineType = PufferDefine.PufferDownloadEngineType.Normal
  if pufferDownlodPhase ~= nil and pufferDownlodPhase == puffer_config.DOWNLOAD_PHASE.BASE and not PublishRegionMacros.IsBLUEHOLE() then
    if Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS then
      downloadEngineType = PufferDefine.PufferDownloadEngineType.HCDN
    else
      local os_version = Client.GetOSVersion()
      local so_version = Client.GetAndroidSOVersion()
      if so_version and so_version == 32 and os_version then
        downloadEngineType = PufferDefine.PufferDownloadEngineType.Normal
      else
        downloadEngineType = PufferDefine.PufferDownloadEngineType.HCDN
      end
    end
  end
  local defaultConfig = {
    MaxDownloadsPerTask = maxDownloadsPerTask,
    MaxDownTask = maxDownTask,
    MaxDownloadSpeed = maxDownloadSpeed,
    PufferDownloadFuncDict = PufferDownloadFuncDictJson,
    HttpDnsType = logic_http_dns:GetHttpDnsType(),
    DownloadStageType = downloadStageType,
    DownloadEngineType = downloadEngineType
  }
  log_tree("GetPufferDefaultConfig", defaultConfig)
  return defaultConfig
end
function puffer_config.GetPufferUA(resType)
  local StringUtil = require("common.string_util")
  local appVer = Client.GetApplicationVersion()
  local appVerArr = StringUtil.Split(appVer, ".")
  local appShortVer = string.format("%s.%s.%s", appVerArr[1], appVerArr[2], appVerArr[3])
  local UA = string.format("OS/%s;AppVer/%s;Scene/%s", Client.GetDevicePlatformName(), appShortVer, GameStatus.GetGameStatus())
  return UA
end
function puffer_config.GetImmDLPollingTime(pollingType)
  local PufferTickInterval = 10000
  if pollingType ~= nil and pollingType == puffer_config.DOWNLOAD_PHASE.BASE then
    PufferTickInterval = HDmpveRemote.HDmpveRemoteConfigGetInt("PufferTickIntervalInBase", 5000)
  elseif pollingType ~= nil and pollingType == puffer_config.DOWNLOAD_PHASE.FIGHTING then
    PufferTickInterval = HDmpveRemote.HDmpveRemoteConfigGetInt("PufferTickIntervalInFighting", 300000)
  elseif PufferSwitch.AutoDownloadCfg.FullSpeedDownload then
    PufferTickInterval = HDmpveRemote.HDmpveRemoteConfigGetInt("PufferTickIntervalFull", 5000)
  else
    PufferTickInterval = HDmpveRemote.HDmpveRemoteConfigGetInt("PufferTickInterval", 10000)
  end
  log(bWriteLog and "puffer_config:GetImmDLPollingTime: " .. tostring(PufferTickInterval))
  return PufferTickInterval
end
function puffer_config.GetImmDLTaskConfig(downloadType)
  local maxTask = puffer_config.CONST_SMALL_FILE_MAX_DOWNLOAD_TASK
  local maxDownloadsPerTask = puffer_config.CONST_SMALL_FILE_MAX_DOWNLOAD_PER_TASK
  local bIsBigFile = puffer_config.IsBigFile(downloadType)
  if bIsBigFile then
    maxTask = HDmpveRemote.HDmpveRemoteConfigGetInt("PFRBigMaxDownTask", puffer_config.CONST_BIG_FILE_MAX_DOWNLOAD_TASK)
    maxDownloadsPerTask = HDmpveRemote.HDmpveRemoteConfigGetInt("PFRBigMaxDownloadsPerTask", puffer_config.CONST_BIG_FILE_MAX_DOWNLOAD_PER_TASK)
    log(bWriteLog and "puffer_config:GetImmDLTaskConfig: Apply BIG File config")
  else
    maxTask = HDmpveRemote.HDmpveRemoteConfigGetInt("PFRMaxDownTask", puffer_config.CONST_SMALL_FILE_MAX_DOWNLOAD_TASK)
    maxDownloadsPerTask = HDmpveRemote.HDmpveRemoteConfigGetInt("PFRMaxDownloadsPerTask", puffer_config.CONST_SMALL_FILE_MAX_DOWNLOAD_PER_TASK)
    log(bWriteLog and "puffer_config:GetImmDLTaskConfig: Apply SMALL File config")
  end
  return maxTask, maxDownloadsPerTask
end
function puffer_config.IsBigFile(downloadType)
  if downloadType then
    local PufferConst = require("client.slua.logic.download.puffer_const")
    local bIsMap = downloadType == PufferConst.ENUM_DownloadType.MAP
    local bIsRes = downloadType == PufferConst.ENUM_DownloadType.RES
    local bIsShader = downloadType == PufferConst.ENUM_DownloadType.SHADER
    return bIsMap or bIsRes or bIsShader
  end
  return false
end
function puffer_config.GetCurlBuffSize()
  return "131072"
end
return puffer_config