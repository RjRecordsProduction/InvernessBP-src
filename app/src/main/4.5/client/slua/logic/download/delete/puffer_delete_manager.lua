local PufferDeleteManager = {
  RECOMMEND_RES_KEY = "RECOMMEND_RES_KEY",
  SAVED_CACHE_KEY = "SAVED_CACHE_KEY",
  LOGIN_DELETE_KEY = "LOGIN_DELETE_KEY",
  savedCacheSize = 0,
  savedCacheDirSize = {},
  appSize = 0,
  otherPaksSize = 0,
  deviceFreeSpace = 0,
  lastUpdateSpaceTime = 0,
  spaceAlertSwitch = false,
  spaceAlertSize = 0,
  spaceAlertCDTime = 0,
  spaceAlertTime = 0,
  SilentCleanup = false,
  spaceAlertAutoDelete = false,
  needQuitGame = false,
  PakMountTimes = nil,
  ignoreFileDeleteNotify = false,
  uploadDeleteCrashFileList = {}
}
PufferDeleteManager.CacheDirs = {}
local PufferConst = require("client.slua.logic.download.puffer_const")
function PufferDeleteManager.OnGameStateChange(eventType, eventID, vars)
  if vars.current ~= GameStatus.Lobby then
    PufferDeleteManager.Destroy()
  end
  if vars.current == GameStatus.Lobby and vars.pre == GameStatus.Login then
    PufferDeleteManager.InitSpaceAlertSize()
  end
end
function PufferDeleteManager.Destroy()
  if PufferDeleteManager.TimerDeletePak then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(PufferDeleteManager.TimerDeletePak)
    PufferDeleteManager.TimerDeletePak = nil
  end
end
function PufferDeleteManager.InitSpaceAlertSize()
  log(bWriteLog and "PufferDeleteManager.InitSpaceAlertSize.")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local isFitVersion = PublishRegionMacros.IsFITVersion()
  if isFitVersion then
    PufferDeleteManager.spaceAlertSwitch = true
  end
  local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSpaceAlertSize)
  if data and next(data) then
    PufferDeleteManager.spaceAlertSwitch = data.spaceAlertSwitch
    PufferDeleteManager.spaceAlertSize = data.spaceAlertSize
    PufferDeleteManager.spaceAlertTime = data.spaceAlertTime or 0
    PufferDeleteManager.spaceAlertAutoDelete = data.spaceAlertAutoDelete == true
  end
end
function PufferDeleteManager.SaveSpaceAlertData()
  local data = {
    spaceAlertSwitch = PufferDeleteManager.spaceAlertSwitch,
    spaceAlertSize = PufferDeleteManager.spaceAlertSize,
    spaceAlertTime = PufferDeleteManager.spaceAlertTime,
    spaceAlertAutoDelete = PufferDeleteManager.spaceAlertAutoDelete
  }
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.eSpaceAlertSize)
  log(bWriteLog and "PufferDeleteManager.SaveSpaceAlertData.")
end
function PufferDeleteManager.SetSpaceAlert(switch, size)
  PufferDeleteManager.spaceAlertSwitch = switch
  PufferDeleteManager.spaceAlertSize = size
  log(bWriteLog and string.format("PufferDeleteManager.SetSpaceAlert. switch=%s, size=%s", tostring(switch), tostring(size)))
  PufferDeleteManager.SaveSpaceAlertData()
  if not switch then
    local PufferSwitch = require("client.slua.logic.download.puffer_switch")
    PufferSwitch.BanAutoDownload = false
  end
end
function PufferDeleteManager.SaveUISpaceAlertTime(isCheck)
  if isCheck then
    PufferDeleteManager.SetSpaceAlertAddTime(518400)
  else
    PufferDeleteManager.SetSpaceAlertAddTime()
  end
  PufferDeleteManager.SaveSpaceAlertData()
end
function PufferDeleteManager.ShowSizeAlertUI(itemWhitelist)
  log(bWriteLog and "PufferDeleteManager.ShowSizeAlertUI.")
  if UIManager.IsUIShow(UIManager.UI_Config.Download_Main_UIBP) then
    return
  end
  if PufferDeleteManager.spaceAlertAutoDelete and itemWhitelist then
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    PufferManager.PauseAllDownloadTasks()
    local DownloadDelSystem = require("client.slua.logic.download.delete.logic_download_delete")
    local allList = DownloadDelSystem.GetMainSwitchData(itemWhitelist, PufferDeleteManager.GetDeleteTargetSize(itemWhitelist))
    local delList = DownloadDelSystem.GetDeleteList(allList)
    if next(delList) then
      DownloadDelSystem.HandleDeleteFunc(delList, itemWhitelist, false, false)
      PufferDeleteManager.SilentCleanup = true
      log(bWriteLog and "PufferDeleteManager.ShowSizeAlertUI. SilentCleanup")
    else
      log(bWriteLog and "PufferDeleteManager.ShowSizeAlertUI. emptySize")
    end
    return
  end
  local title = LocUtil.GetLocalizeResStr(5077)
  local tips = LocUtil.LocalizeResFormat(62923)
  local okText = LocUtil.GetLocalizeResStr(39199)
  local ok = function(isCheck)
    PufferDeleteManager.ShowDeleteUI(false, nil, nil, itemWhitelist)
    local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
    PufferTlog.SendTLog(PufferTlog.Enum_TLog_From.SpaceAlert, PufferTlog.Enum_TLog_Optype.Finish, "EnterDeleteUI")
    PufferDeleteManager.SaveUISpaceAlertTime(isCheck)
  end
  local cancelText = LocUtil.GetLocalizeResStr(62926)
  local cancel = function(isCheck)
    PufferDeleteManager.SaveUISpaceAlertTime(isCheck)
    UIManager.ShowUI(UIManager.UI_Config.Download_Setting_UIBP)
    local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
    PufferTlog.SendTLog(PufferTlog.Enum_TLog_From.SpaceAlert, PufferTlog.Enum_TLog_Optype.Finish, "EnterSpaceAlertSetting")
  end
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  local checkBoxText = LocUtil.GetLocalizeResStr(62924)
  local closeCallback = function(isCheck)
    PufferDeleteManager.SaveUISpaceAlertTime(isCheck)
  end
  local extraData = {
    isShowCheckBox = true,
    checkBoxText = checkBoxText,
    clickCloseCallback = closeCallback,
    isDefaultCheck = true
  }
  CommonMsgBoxMgr.Show(CommonMsgBoxMgr.SHOW_TYPE_FOUR, title, tips, ok, cancel, okText, cancelText, extraData)
  PufferDeleteManager.SetSpaceAlertAddTime()
  PufferDeleteManager.SaveSpaceAlertData()
end
function PufferDeleteManager.SetSpaceAlertAddTime(addTime)
  addTime = addTime or 0
  local time = FuncUtil.GetServerTimeInSec() + addTime
  log(bWriteLog and string.format("PufferDeleteManager.SetSpaceAlertTime new Data = %d, oldData = %d", time, PufferDeleteManager.spaceAlertTime))
  if time <= PufferDeleteManager.spaceAlertTime then
    return
  end
  PufferDeleteManager.spaceAlertTime = time
end
function PufferDeleteManager.IsGameSizeNeedAlert()
  local gameSize = PufferDeleteManager.GetGameSize()
  gameSize = gameSize / 1000
  gameSize = tonumber(string.format("%.1f", gameSize))
  local alertSize = PufferDeleteManager.GetSpaceAlertSize()
  log(bWriteLog and string.format("PufferDeleteManager.IsGameSizeNeedAlert gameSize:%s, alertSize: %s", gameSize, alertSize))
  if PufferDeleteManager.spaceAlertSwitch and 0 < alertSize and gameSize >= alertSize then
    local PufferSwitch = require("client.slua.logic.download.puffer_switch")
    PufferSwitch.BanAutoDownload = true
    return true
  end
  return false
end
function PufferDeleteManager.GetCurPaksSize()
  local curSize = 0
  local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
  local mapSize = PufferMapManager:GetAllMapCurSize()
  curSize = curSize + mapSize
  local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
  local odPakSize = PufferODPakManager:GetAllODPakCurSize()
  curSize = curSize + odPakSize
  local PufferResManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_res_manager)
  local resSize = PufferResManager:GetAllResCurSize()
  curSize = curSize + resSize
  local PufferUGCPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_ugcpak_manager)
  local ugcPakSize = PufferUGCPakManager:GetAllUGCPakCurSize()
  curSize = curSize + ugcPakSize
  local PufferPrefetchManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_prefetch_manager)
  local prefetchCurSize, _ = PufferPrefetchManager:GetSize()
  prefetchCurSize = prefetchCurSize / PufferConst.MB
  curSize = curSize + prefetchCurSize
  return curSize, mapSize, odPakSize, resSize, ugcPakSize, prefetchCurSize
end
function PufferDeleteManager.GetAppsize()
  if PufferDeleteManager.appSize ~= 0 then
    return PufferDeleteManager.appSize
  end
  local PufferListJson = PufferDownloader.GetPufferFileListJson()
  if not PufferListJson or next(PufferListJson) == nil then
    return 0
  end
  PufferDeleteManager.appSize = tonumber(PufferListJson.AppSize) or 0
  return PufferDeleteManager.appSize
end
function PufferDeleteManager.GetOtherPaksSize()
  if PufferDeleteManager.otherPaksSize ~= 0 then
    return PufferDeleteManager.otherPaksSize
  end
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local size = 0
  local ret = GCPufferDownloader.ReturnLocalFiles(PufferDownloader.DOWNLOAD_DIR_RELATIVE, "")
  for _, filename in pairs(ret) do
    local key = string.match(filename, "(.+_.+)_")
    if not PufferManager.GetDownloadType(key) then
      local filenameFullPath = Client.ProjectSavedDir() .. PufferDownloader.DOWNLOAD_DIR_RELATIVE .. filename
      size = size + Client.GetFileSizeOnDisk(filenameFullPath) / 1024.0
    end
  end
  PufferDeleteManager.otherPaksSize = size
  log(bWriteLog and string.format("PufferDeleteManager.GetOtherPaksSize :%s", size))
  return PufferDeleteManager.otherPaksSize
end
function PufferDeleteManager.GetGameSize()
  local pakSize = PufferDeleteManager.GetCurPaksSize()
  log(bWriteLog and "PufferDeleteManager.GetGameSize. pakSize = " .. tostring(pakSize))
  local appSize = PufferDeleteManager.GetAppsize()
  log(bWriteLog and "PufferDeleteManager.GetGameSize. appSize = " .. tostring(appSize))
  local otherPaksSize = PufferDeleteManager.GetOtherPaksSize()
  log(bWriteLog and "PufferDeleteManager.GetGameSize. otherPaksSize = " .. tostring(otherPaksSize))
  local cacheSize = PufferDeleteManager.GetSavedCacheSize() / PufferConst.MB
  log(bWriteLog and "PufferDeleteManager.GetGameSize. cacheSize = " .. tostring(cacheSize))
  local gameSize = appSize + pakSize + otherPaksSize + cacheSize
  log(bWriteLog and "PufferDeleteManager.GetGameSize. gameSize = " .. tostring(gameSize))
  return gameSize
end
function PufferDeleteManager.GetSavedCacheDirs()
  if Client and not next(PufferDeleteManager.CacheDirs) then
    PufferDeleteManager.CacheDirs = {
      Client.ProjectSavedDir() .. "LiveVideo/",
      Client.ProjectSavedDir() .. "Pandora/",
      Client.ProjectSavedDir() .. "MoviesPakDir/",
      Client.ProjectContentDir() .. "MoviesPakDir/"
    }
  end
  return PufferDeleteManager.CacheDirs
end
function PufferDeleteManager.GetSavedCacheSize()
  local cacheSize = PufferDeleteManager.savedCacheSize
  return cacheSize
end
local _TmpAllCacheDirs = {}
local _TmpTotalCacheDirSize = 0
function PufferDeleteManager.OnGetCacheSizeCallback(dir, dirSize)
  if dirSize == nil or dir == nil then
    return
  end
  dirSize = dirSize * 1024
  log(bWriteLog and string.format("PufferDeleteManager.OnGetCacheSizeCallback. dir=%s, dir=%s", tostring(dir), tostring(dirSize / PufferConst.MB)))
  PufferDeleteManager.savedCacheDirSize[dir] = dirSize
  _TmpTotalCacheDirSize = _TmpTotalCacheDirSize + dirSize
  _TmpAllCacheDirs[dir] = nil
  if not next(_TmpAllCacheDirs) then
    PufferDeleteManager.savedCacheSize = _TmpTotalCacheDirSize
    EventSystem:postEvent(EVENTTYPE_PUFFER, EVENTID_PUFFER_CACHE_DIR_SIZE_COMPLETE)
    if PufferDeleteManager.CacheSizeCallback then
      local callback = PufferDeleteManager.CacheSizeCallback
      PufferDeleteManager.CacheSizeCallback = nil
      callback()
    end
  end
end
function PufferDeleteManager.GetSavedCacheSizeAsync(callback)
  log(bWriteLog and "PufferDeleteManager.GetSavedCacheSizeAsync.")
  if PufferDeleteManager.savedCacheSize ~= 0 then
    callback()
    return
  end
  local time_ticker = require("common.time_ticker")
  time_ticker.AddTimerOnce(0.1, function()
    PufferDeleteManager.savedCacheDirSize = {}
    local CacheDirs = PufferDeleteManager.GetSavedCacheDirs()
    _TmpAllCacheDirs = {}
    _TmpTotalCacheDirSize = 0
    PufferDeleteManager.CacheSizeCallback = callback
    for i, dir in ipairs(CacheDirs) do
      _TmpAllCacheDirs[dir] = true
      local SavedFileUtil = import("SavedFileUtil")
      SavedFileUtil.GetDirSizeAsync(dir, true, PufferDeleteManager.OnGetCacheSizeCallback)
    end
  end)
end
function PufferDeleteManager.GetDirSize(dir)
  local SavedFileUtil = import("SavedFileUtil")
  return SavedFileUtil.GetDirSize(dir, true)
end
function PufferDeleteManager.NeedShowCacheDelete()
  local size = PufferDeleteManager.GetSavedCacheSize()
  return size >= 100 * PufferConst.MB
end
function PufferDeleteManager.NeedShowCacheDeleteReddot()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  if PufferDeleteManager.NeedShowCacheDelete() then
    local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eCacheReddot)
    if not data then
      data = {}
      data.CacheReddot = false
      PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.eCacheReddot)
      return true
    elseif not data.CacheReddot then
      return true
    end
  end
  return false
end
function PufferDeleteManager.UpdateDeviceFreeSpace(force)
  local TimeUtil = require("client.common.time_util")
  if not force and TimeUtil.GetServerTimeInSec() - PufferDeleteManager.lastUpdateSpaceTime <= 10 then
    return
  end
  PufferDeleteManager.deviceFreeSpace = Client.GetDeviceFreeSpace()
  PufferDeleteManager.lastUpdateSpaceTime = TimeUtil.GetServerTimeInSec()
end
function PufferDeleteManager.GetDeviceFreeSpace()
  PufferDeleteManager.UpdateDeviceFreeSpace(PufferDeleteManager.deviceFreeSpace == 0)
  return PufferDeleteManager.deviceFreeSpace
end
function PufferDeleteManager.HaveEnoughSpace(downloadType, keyList)
  PufferDeleteManager.UpdateDeviceFreeSpace()
  local PufferSwitch = require("client.slua.logic.download.puffer_switch")
  if _G.IsEditor or PufferDeleteManager.deviceFreeSpace >= 1000 then
    return true
  end
  if PufferDeleteManager.IsShowDeleteUI() then
    return false
  end
  if PufferDeleteManager.deviceFreeSpace - 100 <= 0 then
    if UIManager.IsAndroidStackEmpty() or UIManager.IsUIShow(UIManager.UI_Config.Download_Main_UIBP) then
      log(bWriteLog and "PufferDeleteManager.HaveEnoughSpace deviceFreeSpace = " .. tostring(PufferDeleteManager.deviceFreeSpace))
      ShowNotice(33208)
      PufferDeleteManager.ShowDeleteUI(false)
    end
    PufferSwitch.BanAutoDownload = true
    return false
  end
  if downloadType == PufferConst.ENUM_DownloadType.MAP or downloadType == PufferConst.ENUM_DownloadType.RES then
    log(bWriteLog and "PufferDeleteManager.HaveEnoughSpace keyList[1] = " .. tostring(keyList[1]))
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    local _, totalSize = PufferManager.GetSize(downloadType, keyList)
    if 0 >= PufferDeleteManager.deviceFreeSpace - totalSize / PufferConst.MB then
      ShowNotice(33208)
      PufferDeleteManager.ShowDeleteUI(false)
      PufferSwitch.BanAutoDownload = true
      return false
    end
  end
  return true
end
function PufferDeleteManager.IsShowDeleteUI()
  if UIManager.IsUIShow(UIManager.UI_Config.notify_recommend_delete) then
    return true
  end
  local Download_Main_UIBP = UIManager.GetUI(UIManager.UI_Config.Download_Main_UIBP)
  if Download_Main_UIBP and not Download_Main_UIBP:IsViewMode() then
    return true
  end
  return false
end
function PufferDeleteManager.ShowDeleteUI(bRecommend, totalSize, code, itemWhitelist, targetSize)
  printf("PufferDeleteManager.ShowDeleteUI. bRecommend=%s, totalSize=%s, code=%s, itemWhitelist=%s, targetSize=%s", tostring(bRecommend), tostring(totalSize), tostring(code), tostring(itemWhitelist), tostring(targetSize))
  if not GameStatus.InSupportDownloadState() then
    log(bWriteLog and "PufferDeleteManager.ShowDeleteUI. not support download state")
    return
  end
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.bEnterXMissionReq then
    log_format("PufferDeleteManager:ShowDeleteUI block, reason:enter_xmission_in_progress, bRecommend:%s", tostring(bRecommend))
    return
  end
  if targetSize == nil then
    targetSize = PufferDeleteManager.GetDeleteTargetSize(itemWhitelist)
  end
  local deviceFreeSpace = PufferDeleteManager.GetDeviceFreeSpace() / 1000
  log(bWriteLog and string.format("PufferDeleteManager.ShowDeleteUI targetSize %f, deviceFreeSpace = %f", targetSize, deviceFreeSpace))
  if bRecommend then
    UIManager.ShowUI(UIManager.UI_Config.notify_recommend_delete, bRecommend, totalSize, code, itemWhitelist, targetSize)
    return
  end
  local Download_Main_UIBP = UIManager.GetUI(UIManager.UI_Config.Download_Main_UIBP)
  if Download_Main_UIBP and Download_Main_UIBP:IsShow() then
    Download_Main_UIBP:SwitchToDeleteMode(targetSize)
  else
    UIManager.ShowUI(UIManager.UI_Config.Download_Main_UIBP, {targetSize = targetSize})
  end
end
function PufferDeleteManager.ShowDeleteHintMsgBox(totalSize, forceType)
  local totalSizeStr = string.format("%.1f", totalSize)
  log(bWriteLog and string.format("PufferDeleteManager.ShowDeleteHintMsgBox totalSize=%s", totalSizeStr))
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  local title = LocUtil.GetLocalizeResStr(468890072)
  local msg = LocUtil.LocalizeResFormat(468890073, totalSizeStr)
  local clearStr = LocUtil.GetLocalizeResStr(468890074)
  local closeStr = LocUtil.GetLocalizeResStr(468890075)
  local disableOpenSystemStorage = Client.HDmpveRemoteConfigGetBool("DisableOpenSystemStorage", false)
  local exitFunction = function()
    log(bWriteLog and "PufferDeleteManager.ShowDeleteHintMsgBox, exit game")
    GameStatus.QuitGame()
  end
  local clearFunction = function()
    log(bWriteLog and "PufferDeleteManager.ShowDeleteHintMsgBox click clear, jump to system storage setting")
    if not disableOpenSystemStorage then
      Client.OpenSystemStorage()
    end
    GameStatus.QuitGame()
  end
  local isIOS = Client.GetDevicePlatformName() == "IOS"
  local msgBoxType = Client.GetDevicePlatformName() == "IOS" and CommonMsgBoxMgr.SHOW_TYPE_THREE or CommonMsgBoxMgr.SHOW_TYPE_FOUR
  if Client.GetDevicePlatformName() == "IOS" or forceType == 0 then
    CommonMsgBoxMgr.Show(CommonMsgBoxMgr.SHOW_TYPE_THREE, title, msg, exitFunction, nil, closeStr, nil, {
      showUIKey = "com_msg_small_box_slua",
      clickCloseCallback = exitFunction
    })
  elseif Client.GetDevicePlatformName() ~= "IOS" or forceType == 1 then
    CommonMsgBoxMgr.Show(CommonMsgBoxMgr.SHOW_TYPE_FOUR, title, msg, clearFunction, exitFunction, clearStr, closeStr, {
      showUIKey = "com_msg_small_box_slua",
      clickCloseCallback = exitFunction
    })
  end
end
function PufferDeleteManager.GetDeleteTargetSize(itemWhitelist)
  local deleteSize = -1
  local targetSize = 0
  local deviceFreeSpace = PufferDeleteManager.GetDeviceFreeSpace() / 1000
  printf("PufferDeleteManager.GetDeleteTargetSize. deviceFreeSpace=%s", tostring(deviceFreeSpace))
  if itemWhitelist ~= nil then
    local STExtraGameInstance = import("STExtraGameInstance")
    local GameInstance = STExtraGameInstance.GetInstance()
    local nDeviceLevel = GameInstance:GetDeviceLevel()
    log(bWriteLog and "DownloadSystem._InitSmartDownloadDownloadSelect. nDeviceLevel = " .. tostring(nDeviceLevel))
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    local isFitVersion = PublishRegionMacros.IsFITVersion()
    local data = CDataTable.GetTableByFilter("RecommendDeleteTable", "DeviceTier", nDeviceLevel + 1, "IsFitVersion", isFitVersion)
    if data then
      local alertSize = PufferDeleteManager.GetSpaceAlertSize()
      for k, v in pairs(data) do
        if deviceFreeSpace <= v.Condition and alertSize > v.TargetNumber then
          targetSize = v.TargetNumber * 1000
          break
        elseif alertSize > v.TargetNumber then
          targetSize = v.TargetNumber * 1000
        end
      end
    end
    if targetSize <= 0 then
      targetSize = 10000
    end
    local gameSize = PufferDeleteManager.GetGameSize()
    printf("PufferDeleteManager.GetDeleteTargetSize. gameSize=%s, targetSize=%s", tostring(gameSize), tostring(targetSize))
    deleteSize = gameSize - targetSize
    if deleteSize < 0 then
      deleteSize = -1
    end
    if PufferDeleteManager.testDeleteSize then
      deleteSize = PufferDeleteManager.testDeleteSize
    end
  end
  log(bWriteLog and "PufferDeleteManager.GetDeleteTargetSize. deleteSize = " .. tostring(deleteSize))
  return deleteSize
end
function PufferDeleteManager.DeleteODPak(pakName)
  local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
  local PufferUGCPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_ugcpak_manager)
  local tempPakName = string.gsub(pakName, "ODPaks/", "")
  if Client.IsODPakMonted(tempPakName) then
    local Logic_Download_Delete = require("client.slua.logic.download.delete.logic_download_delete")
    Logic_Download_Delete.SaveHasMountODPak(pakName)
    log(bWriteLog and string.format("PufferDeleteManager.DeleteODPak %s IsODPakMonted:", pakName))
    return false
  end
  PufferODPakManager.itemToPaks = {}
  local filenameFullPath = Client.ProjectSavedDir() .. PufferDownloader.DOWNLOAD_DIR_RELATIVE .. pakName
  if GCPufferDownloader.DeleteFile(filenameFullPath) then
    Client.AddCrashContextData(30, pakName, false, 1200)
    local deleteSize = PufferODPakManager:ResetPakData(pakName)
    deleteSize = deleteSize + PufferUGCPakManager:ResetPakData(pakName)
    PufferDownloader.AddDeleteSize(deleteSize)
    return true
  end
  return false
end
function PufferDeleteManager.DeleteMap(mapKey, bNotPostEvent)
  log(bWriteLog and string.format("PufferDeleteManager.DeleteMap mapKey:%s", mapKey))
  local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
  local map = PufferMapManager.MapPaks[mapKey]
  if not map or map.notInPuffer then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local history = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eDeleteHistory)
  history = history or {}
  local targetName = PufferDownloader.GetRealFilename(map.pakName)
  targetName = PufferDownloader.GetTargetFilenameByName(targetName)
  local filePath = Client.ProjectSavedDir() .. PufferDownloader.DOWNLOAD_DIR_RELATIVE .. targetName
  Client.UnmountPakFile(filePath)
  Client.AddCrashContextData(31, targetName, false, 1200)
  GCPufferDownloader.DeleteFileEvenIfUnfinished(Puffer, targetName)
  local appVersion = Client.GetApplicationVersion()
  local StringUtil = require("common.string_util")
  local splitResult = StringUtil.Split(appVersion, ".")
  local bigVersion = string.format("%s.%s.%s", splitResult[1], splitResult[2], splitResult[3])
  local pre = map.filepre .. bigVersion
  local allPakFiles = GCPufferDownloader.ReturnLocalFiles(PufferDownloader.DOWNLOAD_DIR_RELATIVE, "")
  for _, fileName in pairs(allPakFiles) do
    if string.find(fileName, pre) then
      filePath = Client.ProjectSavedDir() .. PufferDownloader.DOWNLOAD_DIR_RELATIVE .. fileName
      Client.UnmountPakFile(filePath)
      GCPufferDownloader.DeleteFile(filePath)
    end
  end
  history[map.filepre] = true
  PlayerPrefsSystem.SaveTableToFile_N(history, PlayerPrefsSystem.ePlayerPrefsType.eDeleteHistory)
  PufferMapManager:ResetMapDataByPath(map.pakName, function(key, mapData)
    PufferDownloader.AddDeleteSize(mapData.curSize / PufferConst.MB)
  end)
  if not bNotPostEvent then
    EventSystem:postEvent(EVENTTYPE_DOWNLOAD, EVENTID_PUFFER_DELETE_SUCCESS)
  end
end
function PufferDeleteManager.DeleteRes(resKey)
  log(bWriteLog and string.format("PufferDeleteManager.DeleteRes resKey:%s", tostring(resKey)))
  local PufferResManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_res_manager)
  local res = PufferResManager.ResPaks[resKey]
  if not res or not res.pakName then
    return
  end
  local targetName = PufferDownloader.GetRealFilename(res.pakName)
  targetName = PufferDownloader.GetTargetFilenameByName(targetName)
  local filePath = Client.ProjectSavedDir() .. PufferDownloader.DOWNLOAD_DIR_RELATIVE .. targetName
  Client.UnmountPakFile(filePath)
  GCPufferDownloader.DeleteFileEvenIfUnfinished(Puffer, targetName)
  local allPakFiles = GCPufferDownloader.ReturnLocalFiles(PufferDownloader.DOWNLOAD_DIR_RELATIVE, "")
  for _, fileName in pairs(allPakFiles) do
    if string.find(fileName, resKey) then
      filePath = Client.ProjectSavedDir() .. PufferDownloader.DOWNLOAD_DIR_RELATIVE .. fileName
      Client.UnmountPakFile(filePath)
      GCPufferDownloader.DeleteFile(filePath)
      log(bWriteLog and string.format("PufferDeleteManager.DeleteRes fileName:%s", fileName))
    end
  end
  PufferDownloader.AddDeleteSize(res.curSize / PufferConst.MB)
  res.percent = 0
  res.state = PufferConst.ENUM_DownloadState.Not
  res.curSize = 0
  if resKey == "res_umgtexmd" then
    PufferDeleteManager.needQuitGame = true
  end
  EventSystem:postEvent(EVENTTYPE_DOWNLOAD, EVENTID_PUFFER_DELETE_SUCCESS)
end
function PufferDeleteManager.DeleteUGCPak(pakName)
  local PufferUGCPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_ugcpak_manager)
  local tempPakName = string.gsub(pakName, PufferDownloader.DOWNLOAD_UGCPAKS_RELATIVE, "")
  if Client.IsODPakMonted(tempPakName) then
    local Logic_Download_Delete = require("client.slua.logic.download.delete.logic_download_delete")
    Logic_Download_Delete.SaveHasMountODPak(pakName)
    log(bWriteLog and string.format("PufferDeleteManager.DeleteODPak %s IsODPakMonted:", pakName))
    return false
  end
  PufferUGCPakManager.assetToPaks = {}
  local filenameFullPath = Client.ProjectSavedDir() .. PufferDownloader.DOWNLOAD_DIR_RELATIVE .. pakName
  if GCPufferDownloader.DeleteFile(filenameFullPath) then
    Client.AddCrashContextData(30, pakName, false, 1200)
    PufferDownloader.AddDeleteSize(PufferUGCPakManager:ResetPakData(pakName))
    return true
  end
  return false
end
function PufferDeleteManager.DeletePak(pakName)
  log(bWriteLog and string.format("PufferDeleteManager.DeletePak pakName:%s", pakName))
  local result = false
  local filePath = Client.ProjectSavedDir() .. PufferConst.PAKS_RELATIVE_DIR .. pakName
  if Client.IsFileExistsWithOutPakCheck(filePath) then
    Client.UnmountPakFile(filePath)
    local deleteSize = Client.GetFileSizeOnDisk(filePath) / 1024.0
    result = GCPufferDownloader.DeleteFile(filePath)
    if result then
      PufferDownloader.AddDeleteSize(deleteSize)
    end
  end
  return result
end
function PufferDeleteManager.DeleteSavedCache()
  local CacheDirs = PufferDeleteManager.GetSavedCacheDirs()
  for i, dir in ipairs(CacheDirs) do
    Client.DeleteDirectory(dir)
  end
  local VideoLibrary = require("client.slua.logic.video.lobby_video_function_library")
  VideoLibrary.ClearHaveCopiedVideos()
  local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
  PufferTlog.SendTLog(PufferTlog.DeleteSavedCache, PufferTlog.Enum_TLog_Optype.Finish)
  PufferDownloader.AddDeleteSize(PufferDeleteManager.savedCacheSize)
  PufferDeleteManager.savedCacheSize = 0
end
function PufferDeleteManager.AsynDeletePaks(paks, callback, blockInput, checkList)
  log_tree("PufferDeleteManager.AsynDeletePaks", paks)
  Client.AddCrashContextData(30, "AsynDeletePaks", false, 1200)
  PufferDeleteManager.WaitDeleteMap = {}
  for pakName, downloadType in pairs(paks) do
    if not PufferDeleteManager.WaitDeleteMap[pakName] then
      PufferDeleteManager.WaitDeleteMap[pakName] = downloadType
    end
  end
  if not next(PufferDeleteManager.WaitDeleteMap) then
    log(bWriteLog and string.format("PufferDeleteManager.AsynDeletePaks WaitDeleteMap nil"))
    return
  end
  if not PufferDeleteManager.TimerDeletePak then
    if blockInput then
      logic_connection_waiting:Show(1)
    end
    PufferDeleteManager.ignoreFileDeleteNotify = true
    local time_ticker = require("common.time_ticker")
    local StringUtil = require("common.string_util")
    local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
    PufferDeleteManager.TimerDeletePak = time_ticker.AddTimerLoop(0, function()
      if next(PufferDeleteManager.WaitDeleteMap) then
        local cnt = 0
        while cnt < 30 do
          local key, downloadType = next(PufferDeleteManager.WaitDeleteMap)
          if not key then
            break
          end
          if key == PufferDeleteManager.SAVED_CACHE_KEY or downloadType == PufferDeleteManager.SAVED_CACHE_KEY then
            PufferDeleteManager.DeleteSavedCache()
          elseif downloadType == PufferDeleteManager.LOGIN_DELETE_KEY then
            PufferDeleteManager.DeletePak(key)
          elseif downloadType == PufferConst.ENUM_DownloadType.ODPAK then
            if PufferDeleteManager.DeleteODPak(key) then
              PufferMapManager.ResDeleteKey[key] = true
            end
          elseif downloadType == PufferConst.ENUM_DownloadType.MAP then
            if StringUtil.Starts(key, PufferConst.MAP_PACK_SET_PREFIX) then
              if IsWoWEditor then
                local LogicPufferBundle = require("client.slua.logic.download.bundle.logic_puffer_bundle")
                local _, KeyList = LogicPufferBundle.GetPackDownloadTypeAndResList(key)
                for _, MapKey in ipairs(KeyList) do
                  PufferDeleteManager.DeleteMap(MapKey)
                end
              end
            else
              PufferDeleteManager.DeleteMap(key)
            end
            PufferMapManager.ResDeleteKey[key] = true
          elseif downloadType == PufferConst.ENUM_DownloadType.RES then
            if key == PufferConst.LOBBY_MAPKEY then
              if IsWoWEditor then
                local PufferResManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_res_manager)
                if PufferResManager.LobbyResKeyList then
                  for _, ResKey in ipairs(PufferResManager.LobbyResKeyList) do
                    PufferDeleteManager.DeleteRes(ResKey)
                  end
                end
              end
            else
              PufferDeleteManager.DeleteRes(key)
            end
          elseif downloadType == PufferConst.ENUM_DownloadType.PREFETCH then
            local PufferPrefetchManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_prefetch_manager)
            for pakName, _ in pairs(PufferPrefetchManager.PrefetchPaks) do
              PufferDeleteManager.DeletePak(pakName)
              PufferPrefetchManager.PrefetchPaks[pakName].state = PufferConst.ENUM_DownloadState.Not
              PufferPrefetchManager.PrefetchPaks[pakName].percent = 0
              PufferPrefetchManager.PrefetchPaks[pakName].curSize = 0
            end
          elseif downloadType == PufferConst.ENUM_DownloadType.UGCPAK then
            PufferDeleteManager.DeleteUGCPak(key)
          end
          PufferDeleteManager.WaitDeleteMap[key] = nil
          cnt = cnt + 1
        end
      else
        PufferMapManager:UploadMapStateByDeleteNotify()
        if blockInput then
          logic_connection_waiting:Hide(1)
        end
        if callback then
          callback(checkList)
        end
        time_ticker.RemoveTimer(PufferDeleteManager.TimerDeletePak)
        PufferDeleteManager.TimerDeletePak = nil
        PufferDeleteManager.ignoreFileDeleteNotify = false
        local Logic_UGC_Res_Manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCResManager)
        Logic_UGC_Res_Manager:ClearCacheInfos()
        local Logic_Download_Delete = require("client.slua.logic.download.delete.logic_download_delete")
        Logic_Download_Delete.UploadGemPufferSizeInfo("AsynDeletePaks", true)
      end
    end, TIMER_INFINITE, 0.1)
  end
end
function PufferDeleteManager.DeleteExpiredVideo()
  local deleteMap = {}
  for i, v in pairs(CDataTable.GetTable("VideoTable")) do
    if v.VideoState == 2 then
      if string.find(i, "%.mp4") or string.find(i, "%.MP4") then
        local videoName = string.match(i, "MoviesPak%/(.+)%.")
        if videoName and videoName ~= "" then
          deleteMap[videoName] = true
        end
      elseif string.find(i, "MoviesPak") then
        local videoName = string.match(i, "MoviesPak.*%/(.+)")
        if videoName and videoName ~= "" then
          deleteMap[videoName] = true
        end
      end
    end
  end
  log_tree("RecommendHandler videoMap = ", deleteMap)
  local TargetDir = Client.ProjectContentDir() .. "MoviesPakDir/"
  local SavedFileUtil = import("SavedFileUtil")
  local filelist = SavedFileUtil.FindFiles(TargetDir, "mp4", false)
  for _, filename in pairs(filelist) do
    log(bWriteLog and "RecommendHandler.DeleteExpiredVideo filename: " .. filename)
    local StringUtil = require("common.string_util")
    local videoName = StringUtil.Split(filename, ".")[1]
    if deleteMap[videoName] then
      local filepath = TargetDir .. filename
      local fileSize = Client.GetFileSizeOnDisk(filepath) / 1024.0
      Client.DeleteFile(filepath)
      PufferDownloader.AddDeleteSize(fileSize)
    end
  end
  TargetDir = Client.ProjectSavedDir() .. "MoviesPakDir/"
  filelist = SavedFileUtil.FindFiles(TargetDir, "mp4", false)
  for _, filename in pairs(filelist) do
    log(bWriteLog and "RecommendHandler.DeleteExpiredVideo filename: " .. filename)
    local StringUtil = require("common.string_util")
    local videoName = StringUtil.Split(filename, ".")[1]
    if deleteMap[videoName] then
      local filepath = TargetDir .. filename
      local fileSize = Client.GetFileSizeOnDisk(filepath) / 1024.0
      Client.DeleteFile(filepath)
      PufferDownloader.AddDeleteSize(fileSize)
    end
  end
end
function PufferDeleteManager.GetPakMountTime()
  if not PufferDeleteManager.PakMountTimes then
    PufferDeleteManager.PakMountTimes = {}
    local data = Client.GetODPaksFileUseTime("Logs/FileUseTime.txt")
    for _, v in pairs(data) do
      local pakName = string.sub(v, 1, 51)
      local mountTime = string.sub(v, 53)
      PufferDeleteManager.PakMountTimes[pakName] = tonumber(mountTime)
    end
  end
  return PufferDeleteManager.PakMountTimes
end
function PufferDeleteManager.DeleteExpiredMap()
  if not PufferDownloader.PufferJsonDownloadReturn then
    return
  end
  local PufferListJson = PufferDownloader.GetPufferFileListJson()
  if not PufferListJson or not next(PufferListJson) then
    return
  end
  local ret = GCPufferDownloader.ReturnLocalFiles(PufferDownloader.DOWNLOAD_DIR_RELATIVE, "")
  local appVersion = Client.GetApplicationVersion()
  local StringUtil = require("common.string_util")
  local splitResult = StringUtil.Split(appVersion, ".")
  local bigAppVersion = tonumber(string.format("%s%s%s", splitResult[1], splitResult[2], splitResult[3]))
  log(bWriteLog and string.format("PufferDeleteManager.DeleteExpiredMap bigVersion:%s", tostring(bigAppVersion)))
  for _, filename in pairs(ret) do
    local mapKey = string.match(filename, "(map_.+)_%d%.%d%.%d%.%d+%.pak")
    if mapKey then
      local mapKeyDefault = mapKey .. "_default"
      local version_mapping = PufferListJson.version_mapping
      if not version_mapping[mapKeyDefault] then
        local split1 = StringUtil.Split(filename, "_")
        local split2 = StringUtil.Split(split1[#split1], ".")
        local bigPakVersion = tonumber(string.format("%s%s%s", split2[1], split2[2], split2[3]))
        if bigPakVersion and bigAppVersion > bigPakVersion then
          PufferDeleteManager.DeletePak(filename)
        end
      end
    end
  end
  local Logic_Download_Delete = require("client.slua.logic.download.delete.logic_download_delete")
  Logic_Download_Delete.UploadGemPufferSizeInfo("PufferDeleteManager.DeleteExpiredMap")
end
function PufferDeleteManager.GetSpaceAlertSize()
  local alertSize = PufferDeleteManager.spaceAlertSize
  if alertSize == 0 then
    local freeSpace = PufferDeleteManager.GetDeviceFreeSpace() / 1000
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    local isFitVersion = PublishRegionMacros.IsFITVersion()
    local data = CDataTable.GetTableByFilter("RecommendDeleteTable", "IsFitVersion", isFitVersion)
    if data ~= nil then
      for k, v in pairs(data) do
        if freeSpace <= v.Condition then
          alertSize = v.StartupThreshold
          break
        end
      end
    end
    log(bWriteLog and "freeSpace = " .. tostring(freeSpace) .. " alertSpaceSize = " .. tostring(alertSize))
  end
  return alertSize
end
function PufferDeleteManager.OnDeleteFileNotify(fileList)
  log_tree("fileList = ", fileList)
  if not fileList then
    return
  end
  local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
  local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
  local PufferUGCPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_ugcpak_manager)
  local puffer_res_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_res_manager)
  local StringUtil = require("common.string_util")
  local deleteKeyList = PufferMapManager.ResDeleteKey
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local isFitVersion = PublishRegionMacros.IsFITVersion()
  local needUpdateFitState = false
  for k, filePath in pairs(fileList) do
    if StringUtil.Starts(filePath, PufferConst.ODPAKS_RELATIVE_DIR) then
      PufferODPakManager.itemToPaks = {}
      PufferODPakManager:ResetPakData(filePath)
      deleteKeyList[filePath] = true
      PufferUGCPakManager:ResetPakData(filePath)
    elseif StringUtil.Starts(filePath, PufferConst.MAP_PREFIX) then
      if isFitVersion and StringUtil.StrFind(filePath, PufferConst.FIT_ES_SHADER_PREFIX) then
        needUpdateFitState = true
      end
      PufferMapManager:ResetMapDataByPath(filePath, function(mapKey, mapData)
        deleteKeyList[mapKey] = true
      end)
    end
  end
  if needUpdateFitState then
    local data = puffer_res_manager.ResPaks[PufferConst.FIT_SHADER_KEY]
    if data then
      data.curSize = 0
      data.state = PufferConst.ENUM_DownloadState.Not
      data.percent = 0
    end
  end
  if not GameStatus.IsInLobbyOrMainCity() then
    return
  end
  PufferMapManager:UploadMapStateByDeleteNotify()
end
function PufferDeleteManager.DeleteCheckAlways(saveData, newData)
  return true
end
function PufferDeleteManager.DeleteCheckDaily(saveData, newData)
  if saveData and newData then
    local TimeUtil = require("client.common.time_util")
    local second = 86400
    local num = TimeUtil.GetServerTimeInSec() // second
    if saveData.checkDay ~= num then
      newData.checkDay = num
      return true
    else
      return false
    end
  end
  return true
end
function PufferDeleteManager.DeleteCheckByVersion(saveData, newData)
  if saveData and newData then
    local version_util = require("client.common.version_util")
    local version = version_util.GetAppVersion()
    local ret = version_util.CompareVersionStandard(saveData.checkVersion, version)
    log_format("PufferDeleteManager.DeleteCheckByVersion. ret=%s", ret)
    if ret ~= 0 then
      newData.checkVersion = version
      return true
    else
      return false
    end
  end
  return true
end
function PufferDeleteManager.HandleDeleteStrategy(dir, timeoutDay, exclusiveFiles)
  log(bWriteLog and string.format("PufferDeleteManager.HandleDeleteStrategy. dir=%s, timeoutDay=%s", tostring(dir), tostring(timeoutDay)))
  if dir == nil then
    return
  end
  local SavedFileUtil = import("SavedFileUtil")
  if type(timeoutDay) == "number" then
    local startTime = slua.getMiliseconds()
    if PufferDeleteManager.startTime == nil then
      PufferDeleteManager.startTime = {}
    end
    PufferDeleteManager.startTime[dir] = startTime
    local timeoutSec = timeoutDay * 24 * 3600
    local TimeUtil = require("client.common.time_util")
    local now = TimeUtil.GetServerTimeInSec()
    log(bWriteLog and "PufferDeleteManager.HandleDeleteStrategy. now = " .. tostring(now))
    SavedFileUtil.FindFilesAsync(dir, "*", false, function(list)
      log(bWriteLog and "PufferDeleteManager.HandleDeleteStrategy. dir = " .. tostring(dir))
      local num = 0
      if list then
        for i, file in pairs(list) do
          if not exclusiveFiles or not exclusiveFiles[file] then
            local filePath = dir .. file
            local time = SavedFileUtil.GetFileCreationTime(filePath)
            if 0 <= time and now - time >= timeoutSec then
              log(bWriteLog and "PufferDeleteManager.HandleDeleteStrategy. delete timeout file = " .. tostring(file))
              Client.DeleteFile(filePath)
            end
          end
        end
      end
      log(bWriteLog and "PufferDeleteManager.HandleDeleteStrategy. num = " .. tostring(num))
      local costTime = slua.getMiliseconds() - PufferDeleteManager.startTime[dir]
      log(bWriteLog and "PufferDeleteManager.HandleDeleteStrategy. costTime = " .. tostring(costTime))
    end)
  else
    SavedFileUtil.DeleteDirectoryAsync(dir, function()
      log(bWriteLog and "PufferDeleteManager.HandleDeleteStrategy. delete complete:" .. dir)
    end)
  end
end
function PufferDeleteManager.DeleteLogicInLogin()
  log(bWriteLog and "PufferDeleteManager.DeleteLogicInLogin.")
  local saveDir = Client.ProjectSavedDir()
  local deleteCfgs = {
    {
      dir = saveDir .. "ImageDownload/",
      checkStrategy = PufferDeleteManager.DeleteCheckAlways
    },
    {
      dir = saveDir .. "Logs/",
      checkStrategy = PufferDeleteManager.DeleteCheckDaily,
      timeoutDay = 7,
      exclusiveFiles = {
        ["FileUseTime.txt"] = true
      }
    },
    {
      dir = saveDir .. "image_download_mgr/",
      checkStrategy = PufferDeleteManager.DeleteCheckByVersion,
      timeoutDay = 90
    },
    {
      dir = saveDir .. "Pandora/",
      checkStrategy = PufferDeleteManager.DeleteCheckByVersion
    },
    {
      dir = saveDir .. "MoviesPakDir/",
      checkStrategy = PufferDeleteManager.DeleteCheckDaily,
      timeoutDay = 7
    }
  }
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local fileType = PlayerPrefsSystem.ePlayerPrefsType.eLoginDeleteHistory
  local newData = PlayerPrefsSystem.LoadFileToTable_N(fileType) or {}
  log_tree("PufferDeleteManager.DeleteLogicInLogin. historyData = ", newData)
  local TableUtil = require("common.table_util")
  local saveData = TableUtil.CopyTable(newData)
  for _, v in ipairs(deleteCfgs) do
    if v.checkStrategy and v.checkStrategy(saveData, newData) then
      PufferDeleteManager.HandleDeleteStrategy(v.dir, v.timeoutDay, v.exclusiveFiles)
    end
  end
  log_tree("PufferDeleteManager.DeleteLogicInLogin. historyData = ", newData)
  PlayerPrefsSystem.SaveTableToFile_N(newData, fileType)
end
function PufferDeleteManager.HandleDeleteCrashFile()
  log_format("PufferDeleteManager.HandleDeleteCrashFile.")
  if not HDmpveRemote.HDmpveRemoteConfigGetBool("LoginDeleteCrashFileEnable", true) then
    log_format("PufferDeleteManager.HandleDeleteCrashFile. remote return")
    return
  end
  PufferDeleteManager.uploadDeleteCrashFileList = {}
  local saveDirPath = Client.ProjectSavedDir()
  local filePath = PufferConst.PAKS_RELATIVE_DIR .. PufferConst.ODPAKS_RELATIVE_DIR .. "AsyncLoadingFileCrash.txt"
  if not Client.IsFileExistsWithOutPakCheck(saveDirPath .. filePath) then
    log_format("PufferDeleteManager.HandleDeleteCrashFile. file not exist")
    return
  end
  local fileContent = Client.LoadFileToString(filePath)
  Client.DeleteFile(saveDirPath .. filePath)
  if fileContent == "" then
    log_format("PufferDeleteManager.HandleDeleteCrashFile. fileContent empty")
    return
  end
  local StringUtil = require("common.string_util")
  fileContent = StringUtil.StrReplace(fileContent, "\r", "")
  local Array = StringUtil.Split(fileContent, "\n")
  log_tree("PufferDeleteManager.HandleDeleteCrashFile. Array = ", Array)
  if type(Array) == "table" then
    for i, resPath in ipairs(Array) do
      log_format("PufferDeleteManager.HandleDeleteCrashFile. resPath=%s", resPath)
      local pakName
      local deleteUSFS = true
      if StringUtil.Starts(resPath, PufferConst.ODPAKS_RELATIVE_DIR) then
        pakName = resPath
        deleteUSFS = false
      else
        pakName = Client.GetODPakName(resPath)
      end
      log_format("PufferDeleteManager.HandleDeleteCrashFile. pakName=%s", pakName)
      if pakName ~= "" then
        local DelPakPath = saveDirPath .. PufferConst.PAKS_RELATIVE_DIR .. pakName
        local needDeletePakFile = Client.IsFileExistInCSCWithCheckRaw(pakName) or deleteUSFS
        log_format("PufferDeleteManager.HandleDeleteCrashFile. needDeletePakFile=%s", needDeletePakFile)
        if needDeletePakFile and GCPufferDownloader.DeleteFile(DelPakPath) then
          table.insert(PufferDeleteManager.uploadDeleteCrashFileList, resPath)
          Client.AddCrashContextData(30, pakName, false, 1200)
          local deleteSize = Client.GetFileSizeOnDiskBytes(DelPakPath) / PufferConst.MB
          PufferDownloader.AddDeleteSize(deleteSize)
        end
        if deleteUSFS then
          Client.USFSDeletePkg_V2(pakName)
        end
      end
    end
  end
end
return PufferDeleteManager