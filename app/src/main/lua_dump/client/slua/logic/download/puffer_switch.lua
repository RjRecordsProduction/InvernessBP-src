local PufferConst = require("client.slua.logic.download.puffer_const")
local PufferSwitch = {
  AutoDownloadPrefetchSwitch = true,
  BanAutoDownload = false,
  BanDownload = false,
  MapsAutoDownloadAllSwitch = false,
  MapsAutoDownloadAllSwitch_Newbie = false,
  ODPackDownloadFinishPopUpSwitch = true,
  isToggleDownloadingAll = false,
  isDownloadingAllInSmartMode = false,
  MainCitySmartDownload = false,
  AutoDownloadCfg = {
    AutoDownload4GSwitch = false,
    AutoDownloadWIFISwitch = true,
    RecordDownloadPakID = true,
    AutoDownloadSet = PufferConst.Enum_AutoDownloadSet.OnlyWifi,
    RecommendType = PufferConst.Enum_RecommendType.None,
    NeedShowDownloadSelectGuide = true,
    FullSpeedDownload = false
  },
  SmartDownloadCfg = {
    DownloadCfg = {},
    DownloadCfgFromDefault = false,
    DeleteCfg = {},
    DeleteCfgFromDefault = false
  },
  DeleteDefaultCfg = {},
  DownloadDefaultCfg = {},
  DeleteNeedKeys = {},
  SmartDownloadTipsCfg = {
    DownloadTipsShow = false,
    SettingTipsShow = false,
    FirstClickDownloadAll = true,
    FirstClickSmartDownload = true
  },
  SmartDownloadSelectSize = 0,
  SmartDeleteSelectSize = 0,
  uploadDownloadSuccess = false
}
if IsWoWEditor then
  PufferSwitch.SmartDownloadTipsCfg.DownloadTipsShow = true
  PufferSwitch.SmartDownloadTipsCfg.SettingTipsShow = true
end
local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
local PlayerPrefsConfig = PlayerPrefsSystem.ePlayerPrefsType
local MAIN_CITY_SMART_DOWNLOAD_MIN_PLAYER_COUNT = 8
function PufferSwitch.OnLogin()
  PufferSwitch.InitAutoDownloadSwitch()
  PufferSwitch.InitAutoDownloadPrefetchSwitch()
  PufferSwitch.InitSmartDownloadSetting()
  if PufferDownloader then
    PufferDownloader.LoadDownloadKeyRecord()
  end
  PufferSwitch.isToggleDownloadingAll = false
  local logic_lobby_downloader_tlog = require("client.slua.logic.download.report.logic_lobby_downloader_tlog")
  logic_lobby_downloader_tlog.ReportResourceSnapShot()
end
function PufferSwitch.InitAutoDownloadSwitch()
  local autoDownloadCfg = PufferSwitch.AutoDownloadCfg
  PufferSwitch.LoadPlayerPref(autoDownloadCfg, PlayerPrefsConfig.eAutoDownloadSetting)
  local IsLowMemoryDevice = Client.IsLowMemoryDevice()
  if IsLowMemoryDevice then
    autoDownloadCfg.AutoDownloadWIFISwitch = false
  end
  if not PufferSwitch.GetShowWIFIAutoDownloadSwitch() then
    autoDownloadCfg.AutoDownloadWIFISwitch = not IsLowMemoryDevice
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsFITVersion() then
    autoDownloadCfg.RecommendType = PufferConst.Enum_RecommendType.FIT
  end
  local closeAutoDownload = false
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if DevicePlatformNameMacros.IOS == Client.GetDevicePlatformName() and GlobalData.IsIOSCheck() then
    closeAutoDownload = true
  end
  local forceCloseAutoDownload = HDmpveRemote.HDmpveRemoteConfigGetBool("GForceCloseAutoDownload", false)
  if forceCloseAutoDownload then
    closeAutoDownload = true
  end
  if closeAutoDownload then
    log(bWriteLog and "PufferSwitch.InitAutoDownloadSwitch. closeAutoDownload")
    autoDownloadCfg.AutoDownload4GSwitch = false
    autoDownloadCfg.AutoDownloadWIFISwitch = false
  end
end
function PufferSwitch.LoadPlayerPref(defaultTable, fileType)
  log(bWriteLog and "PufferSwitch.LoadPlayerPref. fileType = " .. tostring(fileType))
  local loadData = PlayerPrefsSystem.LoadFileToTable_N(fileType)
  if loadData and next(loadData) then
    for k, _ in pairs(defaultTable) do
      local saveData = loadData[k]
      if saveData ~= nil then
        defaultTable[k] = saveData
      end
    end
  end
end
function PufferSwitch.SaveAutoDownloadSetting()
  log(bWriteLog and "PufferSwitch.SaveAutoDownloadSetting.")
  PufferSwitch.SavePlayerPref(PufferSwitch.AutoDownloadCfg, PlayerPrefsConfig.eAutoDownloadSetting)
end
function PufferSwitch.SaveSmartDownloadSetting()
  log_tree("PufferSwitch.SaveSmartDownloadSetting. PufferSwitch.SmartDownloadCfg = ", PufferSwitch.SmartDownloadCfg)
  PufferSwitch.SavePlayerPref(PufferSwitch.SmartDownloadCfg, PlayerPrefsConfig.eSmartDownloadSetting)
end
function PufferSwitch.SaveSmartDownloadTipsCfg()
  log(bWriteLog and "PufferSwitch.SaveSmartDownloadTipsCfg.")
  PufferSwitch.SavePlayerPref(PufferSwitch.SmartDownloadTipsCfg, PlayerPrefsConfig.eSmartDownloadTipsCfg)
end
function PufferSwitch.SavePlayerPref(data, fileType)
  log_tree("PufferSwitch.SaveSmartDownloadSetting. data = ", data)
  PlayerPrefsSystem.SaveTableToFile_N(data, fileType)
end
function PufferSwitch.SetAutoDownload(autoDownload)
  log(bWriteLog and string.format("PufferSwitch.SetAutoDownload. autoDownload=%s", tostring(autoDownload)))
  local needStopDownload = false
  local PrefCfgs = PufferSwitch.AutoDownloadCfg
  if autoDownload then
    local hasWifi = Client.HasActiveWifi()
    if PrefCfgs.AutoDownloadSet == PufferConst.Enum_AutoDownloadSet.OnlyWifi then
      PrefCfgs.AutoDownloadWIFISwitch = true
      PrefCfgs.AutoDownload4GSwitch = false
      if not hasWifi then
        needStopDownload = true
      end
      ShowNotice(83623)
    elseif PrefCfgs.AutoDownloadSet == PufferConst.Enum_AutoDownloadSet.Only4G then
      PrefCfgs.AutoDownloadWIFISwitch = false
      PrefCfgs.AutoDownload4GSwitch = true
      if hasWifi then
        needStopDownload = true
      end
      ShowNotice(83624)
    elseif PrefCfgs.AutoDownloadSet == PufferConst.Enum_AutoDownloadSet.WifiAnd4G then
      PrefCfgs.AutoDownloadWIFISwitch = true
      PrefCfgs.AutoDownload4GSwitch = true
      ShowNotice(83625)
    end
    EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_DOWNLOAD_REFRESH)
  else
    PrefCfgs.AutoDownloadWIFISwitch = false
    PrefCfgs.AutoDownload4GSwitch = false
    needStopDownload = true
    ShowNotice(83615)
  end
  PufferSwitch.SaveAutoDownloadSetting()
  if needStopDownload then
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    PufferManager.PauseAllDownloadTasks()
  end
end
function PufferSwitch.SetAutoDownload4GSwitch(bOpen)
  log(bWriteLog and string.format("PufferSwitch.SetAutoDownload4GSwitch bOpen:%s", bOpen))
  PufferSwitch.AutoDownloadCfg.AutoDownload4GSwitch = bOpen
  if bOpen then
    ShowNotice(29923)
  else
    ShowNotice(29924)
  end
  PufferSwitch.SaveAutoDownloadSetting()
end
function PufferSwitch.SetAutoDownloadWIFISwitch(bOpen)
  log(bWriteLog and string.format("PufferSwitch.SetAutoDownloadWIFISwitch bOpen:%s", bOpen))
  PufferSwitch.AutoDownloadCfg.AutoDownloadWIFISwitch = bOpen
  if bOpen then
    ShowNotice(512304)
  else
    ShowNotice(512306)
  end
  PufferSwitch.SaveAutoDownloadSetting()
end
function PufferSwitch.GetAutoDownloadWIFISwitch()
  return PufferSwitch.AutoDownloadCfg.AutoDownloadWIFISwitch
end
function PufferSwitch.InitAutoDownloadPrefetchSwitch()
  local autoDownloadPrefetchSetting = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eAutoDownloadPrefetchSetting)
  if autoDownloadPrefetchSetting and next(autoDownloadPrefetchSetting) then
    PufferSwitch.AutoDownloadPrefetchSwitch = autoDownloadPrefetchSetting.AutoDownloadPrefetchSwitch
  end
  if PufferSwitch.AutoDownloadPrefetchSwitch then
    local PufferDownloadHandler = require("client.network.Protocol.PufferDownloadHandler")
    PufferDownloadHandler.send_reserve_download(1)
  end
  log(bWriteLog and "PufferSwitch.InitAutoDownloadPrefetchSwitch = " .. tostring(PufferSwitch.AutoDownloadPrefetchSwitch))
end
function PufferSwitch.InitSmartDownloadSetting()
  PufferSwitch.LoadPlayerPref(PufferSwitch.SmartDownloadCfg, PlayerPrefsConfig.eSmartDownloadSetting)
  PufferSwitch.LoadPlayerPref(PufferSwitch.SmartDownloadTipsCfg, PlayerPrefsConfig.eSmartDownloadTipsCfg)
end
function PufferSwitch.GetSmartDownloadSelectMap()
  local selectMap = {}
  local PufferDownloader = require("client.slua.logic.download.puffer.logic_puffer_downloader")
  if PufferSwitch.AutoDownloadCfg.RecordDownloadPakID then
    return PufferDownloader.DownloadKeyRecord or {}
  end
  return PufferSwitch.SmartDownloadCfg.DownloadCfg.selectMap or {}
end
function PufferSwitch.SetAutoDownloadPrefetchSwitch(bOpen)
  PufferSwitch.AutoDownloadPrefetchSwitch = bOpen
  if bOpen then
    ShowNotice(512303)
  else
    ShowNotice(512305)
  end
  local table = {}
  table.AutoDownloadPrefetchSwitch = PufferSwitch.AutoDownloadPrefetchSwitch
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(table, PlayerPrefsSystem.ePlayerPrefsType.eAutoDownloadPrefetchSetting)
end
function PufferSwitch.GetPrefetchSwitch()
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  if not login_module.ClientBasicCfg then
    return false
  end
  if not login_module.ClientBasicCfg.PrefetchSwitch or login_module.ClientBasicCfg.PrefetchSwitch == "" then
    return false
  end
  local bigVersion = string.match(Client.GetApplicationVersion(), "%d.%d")
  if bigVersion ~= login_module.ClientBasicCfg.PrefetchSwitch then
    return false
  end
  return true
end
function PufferSwitch.GetPreDownloadBatchSwitch()
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  if not login_module.ClientBasicCfg or not next(login_module.ClientBasicCfg) then
    return true
  end
  local newbeeTime = 259200
  local TimeUtil = require("client.common.time_util")
  local time = TimeUtil.GetServerTimeInSec() - DataMgr.registertime
  if 0 < time and newbeeTime > time then
    return login_module.ClientBasicCfg.PreDownloadBatchSwitch_Newbie
  else
    return login_module.ClientBasicCfg.PreDownloadBatchSwitch
  end
end
function PufferSwitch.GetSpaceAlertSwitch()
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  if not login_module.ClientBasicCfg or not next(login_module.ClientBasicCfg) then
    return true
  end
  if login_module.ClientBasicCfg.SpaceAlertSwitch == nil then
    return true
  end
  return login_module.ClientBasicCfg.SpaceAlertSwitch
end
function PufferSwitch.GetShowWIFIAutoDownloadSwitch()
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  if not login_module.ClientBasicCfg or not next(login_module.ClientBasicCfg) then
    return true
  end
  if login_module.ClientBasicCfg.ShowWIFIAutoDownloadSwitch == nil then
    return true
  end
  return login_module.ClientBasicCfg.ShowWIFIAutoDownloadSwitch
end
function PufferSwitch.GetMapsAutoDownloadAllSwitch()
  local newbeeTime = 259200
  local TimeUtil = require("client.common.time_util")
  local time = TimeUtil.GetServerTimeInSec() - DataMgr.registertime
  if 0 < time and newbeeTime > time then
    return PufferSwitch.MapsAutoDownloadAllSwitch_Newbie
  else
    return PufferSwitch.MapsAutoDownloadAllSwitch
  end
end
function PufferSwitch.CanAutoDownload()
  if Client.GetDeviceFreeSpace() < 10000 then
    return false
  end
  if Client.HasActiveWifi() then
    if PufferSwitch.AutoDownloadCfg.AutoDownloadWIFISwitch then
      return true
    end
  elseif PufferSwitch.AutoDownloadCfg.AutoDownload4GSwitch then
    return true
  end
  return false
end
function PufferSwitch.GetRecommendIndex()
  local logic_newbie_assist = require("client.slua.logic.activity.newbie.logic_newbie_assist")
  local logic_player_return = require("client.slua.logic.player_return.logic_player_return")
  local downloadRecommendIndex = 1
  local isNewBie = logic_newbie_assist.CheckIsNewBie()
  if isNewBie then
    downloadRecommendIndex = PufferConst.Enum_RecommendType.New
  elseif logic_player_return.isPlayerReturnOpenNew() then
    downloadRecommendIndex = PufferConst.Enum_RecommendType.Recall
  else
    downloadRecommendIndex = PufferConst.Enum_RecommendType.Mentor
  end
  return downloadRecommendIndex
end
function PufferSwitch.UpdateMainCitySmartDownload()
  local MainCity_PlayerCharacter_Manager = require("GameLua.Mod.MainCity.Gameplay.Core.MainCity_PlayerCharacter_Manager")
  local playerCount = MainCity_PlayerCharacter_Manager.GetPlayerCount()
  log(bWriteLog and "PufferSwitch.UpdateMainCitySmartDownload. playerCount = " .. tostring(playerCount))
  local inMainCity = GameStatus.IsInMainCity()
  PufferSwitch.MainCitySmartDownload = inMainCity and playerCount >= MAIN_CITY_SMART_DOWNLOAD_MIN_PLAYER_COUNT
end
return PufferSwitch