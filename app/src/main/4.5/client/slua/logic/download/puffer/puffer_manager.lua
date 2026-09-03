local PufferManager = {
  downloadManagerModules = {},
  resourcePatchCfg = {},
  resourceVersionMap = {},
  resourcePatchInited = false
}
local PufferSwitch = require("client.slua.logic.download.puffer_switch")
local PufferDeleteManager = require("client.slua.logic.download.delete.puffer_delete_manager")
local PufferConst = require("client.slua.logic.download.puffer_const")
local StringUtil = require("common.string_util")
local ENUM_DownloadType = PufferConst.ENUM_DownloadType
local ModuleCfg_Downloader = {
  [ENUM_DownloadType.ODPAK] = ModuleManager.CommonModuleConfig.puffer_odpak_downloader,
  [ENUM_DownloadType.ODPACK] = ModuleManager.CommonModuleConfig.puffer_odpak_downloader,
  [ENUM_DownloadType.MAP] = ModuleManager.CommonModuleConfig.puffer_map_downloader,
  [ENUM_DownloadType.RES] = ModuleManager.CommonModuleConfig.puffer_res_downloader,
  [ENUM_DownloadType.SHADER] = ModuleManager.CommonModuleConfig.puffer_shader_downloader,
  [ENUM_DownloadType.PREFETCH] = ModuleManager.CommonModuleConfig.puffer_prefetch_downloader,
  [ENUM_DownloadType.UGCPAK] = ModuleManager.CommonModuleConfig.puffer_ugcpak_downloader,
  [ENUM_DownloadType.UGCPACK] = ModuleManager.CommonModuleConfig.puffer_ugcpak_downloader
}
local ModuleCfg_Manager = {
  [ENUM_DownloadType.ODPAK] = ModuleManager.CommonModuleConfig.puffer_odpak_manager,
  [ENUM_DownloadType.ODPACK] = ModuleManager.CommonModuleConfig.puffer_odpak_manager,
  [ENUM_DownloadType.MAP] = ModuleManager.CommonModuleConfig.puffer_map_manager,
  [ENUM_DownloadType.RES] = ModuleManager.CommonModuleConfig.puffer_res_manager,
  [ENUM_DownloadType.SHADER] = ModuleManager.CommonModuleConfig.puffer_shader_manager,
  [ENUM_DownloadType.PREFETCH] = ModuleManager.CommonModuleConfig.puffer_prefetch_manager,
  [ENUM_DownloadType.UGCPAK] = ModuleManager.CommonModuleConfig.puffer_ugcpak_manager,
  [ENUM_DownloadType.UGCPACK] = ModuleManager.CommonModuleConfig.puffer_ugcpak_manager
}
local StreamExtraData = {bFirst = true}
function PufferManager.Download(downloadType, keyList, from, callback, extraData)
  if not (keyList and next(keyList)) or not downloadType then
    return
  end
  extraData = extraData or {}
  if extraData.bAutoDownload then
    if PufferSwitch.BanAutoDownload then
      log(bWriteLog and "PufferManager.BanAutoDownload return")
      return
    end
    if not PufferSwitch.CanAutoDownload() then
      log(bWriteLog and "PufferManager.CanAutoDownload() return")
      return
    end
  end
  if PufferSwitch.BanDownload then
    log(bWriteLog and "PufferManager.Download bandownload true")
    return
  end
  if not PufferDownloader.InitSuccess then
    PufferDownloader.ReInitializePuffer(false)
    return
  end
  if not PufferDownloader.PufferJsonDownloadReturn then
    PufferDownloader.ReportPufferWarning()
    return
  end
  if PufferDownloader.NeedSkipDownload() then
    log(bWriteLog and "PufferManager.Download ban download in fight")
    return
  end
  if not PufferDeleteManager.HaveEnoughSpace(downloadType, keyList) then
    log(bWriteLog and "PufferManager.Download HaveEnoughSpace false")
    return
  end
  local ModuleConfig = ModuleCfg_Downloader[downloadType]
  if not ModuleConfig then
    return
  end
  local downloader = ModuleManager.GetModule(ModuleConfig)
  downloader:DownloadByKeyList(downloadType, keyList, from, callback, extraData)
end
function PufferManager.Pause(downloadType, keyList, bWait, bNotStartDownload, extraData)
  if not keyList or not next(keyList) then
    return
  end
  local downloader = ModuleManager.GetModule(ModuleCfg_Downloader[downloadType])
  downloader:PauseByKeyList(downloadType, keyList, bWait, bNotStartDownload, extraData)
end
function PufferManager.PauseAllDownloadTasks()
  log(bWriteLog and string.format("PufferManager.PauseAllDownloadTasks"))
  local puffer_odpak_downloader = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_downloader)
  puffer_odpak_downloader:PauseAllDownloadTasks()
  local puffer_map_downloader = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_downloader)
  puffer_map_downloader:PauseAllDownloadTasks()
  local puffer_res_downloader = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_res_downloader)
  puffer_res_downloader:PauseAllDownloadTasks()
  local puffer_prefetch_downloader = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_prefetch_downloader)
  puffer_prefetch_downloader:Pause()
  local puffer_ugcpak_downloader = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_ugcpak_downloader)
  puffer_ugcpak_downloader:PauseAllDownloadTasks()
  local puffer_queue = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_queue)
  puffer_queue:Clear()
  local LogicUGCAssetHub = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAssetHub)
  LogicUGCAssetHub:PauseAll()
  PufferSwitch.isToggleDownloadingAll = false
  EventSystem:postEvent(EVENTTYPE_PUFFER, EVENTID_PUFFER_PAUSEALLDOWNLOAD)
end
function PufferManager.DownloadAllPack()
  log(bWriteLog and "PufferManager.DownloadAllPack.")
  local PufferODPakManager = PufferManager.GetDownloadManager(ENUM_DownloadType.ODPAK)
  if not PufferODPakManager.ODPaks then
    log(bWriteLog and "PufferManager.DownloadAllPack. no pack data")
    return
  end
  local puffer_odpak_downloader = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_downloader)
  for packID, v in pairs(PufferODPakManager.ODPaks) do
    log(bWriteLog and "PufferManager.DownloadAllPack. packID = " .. tostring(packID))
    puffer_odpak_downloader:DownloadByPackID(packID)
  end
end
function PufferManager.GetDownloadType(key)
  local PufferMapManager = PufferManager.GetDownloadManager(ENUM_DownloadType.MAP)
  if PufferMapManager:IsMap(key) then
    return ENUM_DownloadType.MAP
  end
  local PufferResManager = PufferManager.GetDownloadManager(ENUM_DownloadType.RES)
  if PufferResManager:IsRes(key) then
    return ENUM_DownloadType.RES
  end
  local PufferShaderManager = PufferManager.GetDownloadManager(ENUM_DownloadType.SHADER)
  if PufferShaderManager:IsShader(key) then
    return ENUM_DownloadType.SHADER
  end
  local PufferPrefetchManager = PufferManager.GetDownloadManager(ENUM_DownloadType.PREFETCH)
  if PufferPrefetchManager:IsPrefetch(key) then
    return ENUM_DownloadType.PREFETCH
  end
  return nil
end
function PufferManager.GetDownloadManager(downloadType)
  if downloadType == nil then
    return nil
  end
  local manager = PufferManager.downloadManagerModules[downloadType]
  if not manager then
    manager = ModuleManager.GetModule(ModuleCfg_Manager[downloadType])
    PufferManager.downloadManagerModules[downloadType] = manager
  end
  return manager
end
function PufferManager.GetSize(downloadType, keyList, bSkipDepends, excludeKeys)
  local manager = PufferManager.GetDownloadManager(downloadType)
  return manager:GetSizeByKeyList(downloadType, keyList, bSkipDepends, excludeKeys)
end
function PufferManager.GetState(downloadType, keyList, bSkipDepends, bSkipVidepDepends, excludeKeys)
  if PufferSwitch.BanDownload or Client.IsWindowOB() then
    log(bWriteLog and "PufferManager.GetState. ban download" .. tostring(PufferSwitch.BanDownload))
    return PufferConst.ENUM_DownloadState.Done
  end
  local manager = PufferManager.GetDownloadManager(downloadType)
  if not manager then
    log(bWriteLog and "PufferManager.GetState. mananger is nil, downloadType = " .. tostring(downloadType))
    return PufferConst.ENUM_DownloadState.Done
  end
  return manager:GetStateByKeyList(downloadType, keyList, bSkipDepends, bSkipVidepDepends, excludeKeys)
end
function PufferManager.GetStateWhenBanDownload(downloadType, keyList, bSkipDepends, bSkipVidepDepends, excludeKeys)
  local manager = PufferManager.GetDownloadManager(downloadType)
  if not manager then
    log(bWriteLog and "PufferManager.GetState. mananger is nil, downloadType = " .. tostring(downloadType))
    return PufferConst.ENUM_DownloadState.Done
  end
  return manager:GetStateByKeyList(downloadType, keyList, bSkipDepends, bSkipVidepDepends, excludeKeys)
end
function PufferManager.GetListIsDownloaded(downloadType, keyList, bSkipDepends, bSkipVideoDepends, excludeKeys)
  local nStatus = PufferManager.GetState(downloadType, keyList, bSkipDepends, bSkipVideoDepends, excludeKeys)
  return nStatus == PufferConst.ENUM_DownloadState.Done
end
function PufferManager.ResSizeToMBStr(nResSize)
  nResSize = nResSize / PufferConst.MB
  if nResSize < 0.1 then
    nResSize = 0.1
  end
  return LocUtil.LocalizeResFormat(8400005, string.format("%.1f", nResSize))
end
function PufferManager.GetSize2MBStr(downloadType, keyList, bSkipDepends, excludeKeys)
  local curSize, totalSize = PufferManager.GetSize(downloadType, keyList, bSkipDepends, excludeKeys)
  local size = 0
  if downloadType ~= ENUM_DownloadType.ODPACK then
    size = (totalSize - curSize) / PufferConst.MB
  else
    size = totalSize - curSize
  end
  local sizeStr = ""
  if size < 0.1 then
    sizeStr = "0.1"
  else
    sizeStr = string.format("%.1f", size)
  end
  return LocUtil.LocalizeResFormat(8400005, sizeStr)
end
function PufferManager.CheckAutoDownloadByItemID(itemID)
  local PufferODPakManager = PufferManager.GetDownloadManager(ENUM_DownloadType.ODPAK)
  return PufferODPakManager:CheckAutoDownloadByItemID(itemID)
end
function PufferManager.SyncProgressToCallback(outterTaskID, nowSize, totalSize, curStage)
  local filestate = PufferDownloader.filestateList[outterTaskID]
  if filestate == nil or filestate.slient then
    log_error("PufferHandler:SyncFinishToCallback filestate == nil or filestate is slient")
    return
  end
  local puffer_queue = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_queue)
  local task = puffer_queue:GetTask(filestate.filename)
  if not task then
    return
  end
  local downloader = ModuleManager.GetModule(ModuleCfg_Downloader[task.downloadType])
  downloader:OnDownloadProgress(task, nowSize, totalSize, curStage)
end
function PufferManager.SyncFinishToCallback(outterTaskID, isSuccess, errorCode)
  local filestate = PufferDownloader.filestateList[outterTaskID]
  if filestate == nil or filestate.slient then
    log_error("PufferHandler:SyncFinishToCallback filestate == nil or filestate is slient")
    return nil
  end
  local puffer_queue = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_queue)
  local task = puffer_queue:GetTask(filestate.filename)
  task = task or puffer_queue:GetMergeTask(filestate.filename)
  if not task then
    log(bWriteLog and "PufferManager.SyncFinishToCallback. error not found task " .. tostring(filestate.filename))
    return nil
  end
  local downloader = ModuleManager.GetModule(ModuleCfg_Downloader[task.downloadType])
  downloader:OnDownloadFinish(task, outterTaskID, isSuccess, errorCode)
  if isSuccess then
    local fileSizeMB = 0
    if filestate.totalSize then
      fileSizeMB = filestate.totalSize / 1024.0
    else
      fileSizeMB = PufferManager.GetSize(filestate.downloadType, {
        filestate.filename
      }, false) / PufferConst.MB
    end
    PufferDownloader.AddDownloadSize(fileSizeMB)
  end
  return task
end
function PufferManager.InitResourcePatchCfg()
  if PufferManager.resourcePatchInited then
    return
  end
  PufferManager.resourcePatchCfg = {}
  PufferManager.resourceVersionMap = {}
  local ResourcePatchCfg = CDataTable.GetTable("ResourcePatchCfg")
  for _, cfg in pairs(ResourcePatchCfg) do
    PufferManager.resourcePatchCfg[cfg.Res] = cfg.Version
    PufferManager.resourceVersionMap[cfg.Version] = true
  end
  local remoteStr = HDmpveRemote.HDmpveRemoteConfigGetString("PufferResourcePatchCfg", "")
  log_format("PufferManager.InitResourcePatchCfg remoteStr:%s", remoteStr)
  if remoteStr and remoteStr ~= "" then
    local cfgList = StringUtil.Split(remoteStr, "|")
    for _, cfg in pairs(cfgList) do
      local data = StringUtil.Split(cfg, ":")
      if data and data[1] and data[2] then
        local path = data[1]
        local version = data[2]
        local itemID = tonumber(path)
        if itemID then
          PufferManager.resourcePatchCfg[itemID] = version
        else
          PufferManager.resourcePatchCfg[path] = version
        end
        PufferManager.resourceVersionMap[version] = true
      end
    end
  end
  log_tree("PufferManager.InitResourcePatchCfg", PufferManager.resourcePatchCfg)
  PufferManager.resourcePatchInited = true
end
function PufferManager.GetPakName(path)
  if Client and Client.bEditorSkipDownload then
    return ""
  end
  local tempPath = StringUtil.Split(path, ".")[1]
  if not tempPath then
    return ""
  end
  PufferManager.InitResourcePatchCfg()
  local version = PufferManager.resourcePatchCfg[tempPath]
  if version then
    return PufferConst.PUFFERPATCH .. "_" .. version .. ".pak"
  end
  local pakName = Client.GetODPakName(tempPath)
  return pakName
end
function PufferManager.GetPakNamesByItemID(itemID)
  local PufferODPakManager = PufferManager.GetDownloadManager(ENUM_DownloadType.ODPAK)
  return PufferODPakManager:GetPakNamesByItemID(itemID)
end
function PufferManager.GetPakNamesByFeatureID(FeatureKey)
  local PufferODPakManager = PufferManager.GetDownloadManager(ENUM_DownloadType.ODPAK)
  return PufferODPakManager:GetPakNamesByFeatureID(FeatureKey)
end
function PufferManager.GetPakNameByVideoPath(path)
  local ODPakName = ""
  local videoPath = DataMgr.GetVideoDownloadPath(path)
  ODPakName = PufferManager.GetPakName(videoPath)
  return ODPakName
end
function PufferManager.GetPakNameByTableKey(Key)
  local PufferODPakManager = PufferManager.GetDownloadManager(ENUM_DownloadType.ODPAK)
  return PufferODPakManager:GetPakNameByTableKey(Key)
end
function PufferManager.GetDownloadingCnt()
  local puffer_queue = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_queue)
  return puffer_queue:GetDownloadingCnt()
end
function PufferManager.IsBankExist(bankName, downloadIfNotExist)
  if not bankName or bankName == "" then
    log(bWriteLog and "PufferManager.IsBankExist bankName not valid")
    return false
  end
  local path
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS then
    path = "/Game/WwiseAudio/iOS/" .. bankName
  else
    path = "/Game/WwiseAudio/Android/" .. bankName
  end
  log(bWriteLog and string.format("PufferManager.IsBankExist, path:%s, downloadIfNotExist=%s", path, tostring(downloadIfNotExist)))
  local ODPakName = PufferManager.GetPakName(path)
  if ODPakName ~= "" and not GCPufferDownloader.IsODFileExists(Puffer, path) then
    log(bWriteLog and "PufferManager.IsBankExist, return false. ")
    if downloadIfNotExist then
      PufferManager.DownBankPak(bankName)
    end
    return false
  end
  log(bWriteLog and "PufferManager.IsBankExist, return true. ")
  return true
end
function PufferManager.DownloadAssociateBankByActorID(actorID)
  local cfg = CDataTable.GetTableData("VoiceActorCfg", actorID)
  if not cfg then
    return false
  end
  local ActorVoiceSystem = require("client.slua.logic.actor_voice.logic_actor_voice")
  local associateBankNameList = ActorVoiceSystem.GetAssociateBankNameListByActorID(actorID)
  local bDownloaded = true
  if associateBankNameList then
    for _, bankName in pairs(associateBankNameList) do
      if not PufferManager.IsBankExist(bankName) then
        bDownloaded = false
        break
      end
    end
  end
  if bDownloaded then
    return true
  end
  local bankPathList = ActorVoiceSystem.GetAssociateBankPathListByActorID(actorID)
  if bankPathList then
    PufferManager.Download(ENUM_DownloadType.ODPAK, bankPathList)
  end
end
function PufferManager.IsBankExistByActorID(actorID)
  local cfg = CDataTable.GetTableData("VoiceActorCfg", actorID)
  if not cfg then
    log(bWriteLog and "PufferManager.IsBankExistByActorID, not cfg. ")
    return false
  end
  local bankName = cfg.BankName
  return PufferManager.IsBankExist(bankName)
end
function PufferManager.DownBankPak(bankName)
  local path
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS then
    path = "/Game/WwiseAudio/iOS/" .. bankName
  else
    path = "/Game/WwiseAudio/Android/" .. bankName
  end
  PufferManager.Download(ENUM_DownloadType.ODPAK, {path})
end
function PufferManager.DownBankListPak(bankList)
  local pathList = {}
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  for _, bankName in ipairs(bankList) do
    local path
    if Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS then
      path = "/Game/WwiseAudio/iOS/" .. bankName
    else
      path = "/Game/WwiseAudio/Android/" .. bankName
    end
    table.insert(pathList, path)
  end
  PufferManager.Download(ENUM_DownloadType.ODPAK, pathList)
end
function PufferManager.CheckAndDownload(downloadType, keyList, fromType, callback, extraData)
  if not keyList then
    log(bWriteLog and string.format("PufferManager.ShowDownloadTips keyList nil"))
    return false
  end
  log(bWriteLog and string.format("PufferManager.CheckAndDownload, keyList:%s", tostring(keyList[1])))
  local state = PufferManager.GetState(downloadType, keyList)
  log(bWriteLog and string.format("PufferManager.CheckAndDownload state:%s", tostring(state)))
  if state == PufferConst.ENUM_DownloadState.Done then
    return false
  end
  if not PufferDownloader.PufferJsonDownloadReturn and not _G.IsEditor then
    ShowNotice(7421)
    return true
  end
  PufferManager.Download(downloadType, keyList, fromType, callback, extraData)
  return true
end
function PufferManager.ShowAlertSizeTips(downloadType, keyList, fromType, callback, extraData)
  log_format("PufferManager.ShowAlertSizeTips")
  log(bWriteLog and string.format("PufferManager.ShowAlertSizeTips, keyList:%s", tostring(keyList[1])))
  local state = PufferManager.GetState(downloadType, keyList)
  log(bWriteLog and string.format("PufferManager.ShowAlertSizeTips state:%s", tostring(state)))
  if state == PufferConst.ENUM_DownloadState.Done then
    return false
  end
  if not PufferDownloader.PufferJsonDownloadReturn and not _G.IsEditor then
    ShowNotice(7421)
    return true
  end
  local title = LocUtil.GetLocalizeResStr(5077)
  local askTips = LocUtil.LocalizeResFormat(468890076)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
  local okCallback = function()
    PufferTlog.SendTLog(PufferTlog.Enum_TLog_From.Click, PufferTlog.Enum_TLog_Optype.UIOperate, "Size_Popup_Action", 1, true)
    if extraData.nResDownloadScene then
      PufferManager.SendDoubleConfirmTLog(TLogEventDefine.CommonDownloadUI_DoubleConfirm_Ok, extraData.nResDownloadScene, extraData.nResDownloadSize)
    end
    extraData.bSkipPopUp = true
    PufferManager.Download(downloadType, keyList, fromType, callback, extraData)
  end
  local cancelCallback = function()
    PufferTlog.SendTLog(PufferTlog.Enum_TLog_From.Click, PufferTlog.Enum_TLog_Optype.UIOperate, "Size_Popup_Action", 0, true)
    if extraData.nResDownloadScene then
      PufferManager.SendDoubleConfirmTLog(TLogEventDefine.CommonDownloadUI_DoubleConfirm_Cancel, extraData.nResDownloadScene, extraData.nResDownloadSize)
    end
  end
  CommonMsgBoxMgr.Show(CommonMsgBoxMgr.SHOW_TYPE_FOUR, title, askTips, okCallback, cancelCallback)
end
function PufferManager.SendDoubleConfirmTLog(TLogType, nScene, nSize)
  local bIsWifi = Client.HasActiveWifi()
  local sTLogStr = string.format("Scene:%s_Size:%s_Wifi:%s", nScene, nSize, bIsWifi and 1 or 0)
  local TLogReportUtils = require("client.slua.config.tlog.tlog_report_utils")
  TLogReportUtils.ReportTLogEvent(TLogType, 0, sTLogStr)
end
function PufferManager.ShowDownloadTips(downloadType, keyList, askTips, fromType, callback, extraData)
  if not keyList then
    log(bWriteLog and string.format("PufferManager.ShowDownloadTips keyList nil"))
    return false
  end
  log(bWriteLog and string.format("PufferManager.ShowDownloadTips, keyList:%s", tostring(keyList[1])))
  local state = PufferManager.GetState(downloadType, keyList)
  log(bWriteLog and string.format("PufferManager.ShowDownloadTips state:%s", tostring(state)))
  if state == PufferConst.ENUM_DownloadState.Done then
    return false
  end
  if not PufferDownloader.PufferJsonDownloadReturn and not _G.IsEditor then
    ShowNotice(7421)
    return true
  end
  if PufferSwitch.CanAutoDownload() and not askTips then
    PufferManager.Download(downloadType, keyList, fromType, callback, extraData)
    ShowNotice(7421)
    return true
  end
  local title = LocUtil.GetLocalizeResStr(5077)
  local curSize, totalSize = PufferManager.GetSize(downloadType, keyList)
  local size = 0
  if downloadType ~= ENUM_DownloadType.ODPACK then
    size = (totalSize - curSize) / PufferConst.MB
  else
    size = totalSize - curSize
  end
  if size < 0.1 then
    size = 0.1
  end
  local strSize = string.format("%.2f MB", size)
  if not askTips then
    askTips = LocUtil.LocalizeResFormat(45436, strSize)
    if downloadType == ENUM_DownloadType.ODPACK then
      local cfg = CDataTable.GetTableData("PakInfoTable", keyList[1])
      if cfg and 0 < cfg.DownloadTipsID then
        strSize = string.format("%.2f", size)
        askTips = LocUtil.LocalizeResFormat(cfg.DownloadTipsID, strSize)
      end
    elseif downloadType == ENUM_DownloadType.UGCPAK or downloadType == ENUM_DownloadType.UGCPACK then
      local okCallback = function()
        PufferManager.Download(ENUM_DownloadType.UGCPAK, keyList, fromType)
      end
      local title = LocUtil.GetLocalizeResStr(5077)
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.Show(2, title, askTips, okCallback)
      return
    end
  end
  local ok = function()
    if not extraData then
      extraData = {}
    end
    extraData.bSkipPopUp = true
    PufferManager.Download(downloadType, keyList, fromType, callback, extraData)
  end
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, title, askTips, ok)
  return true
end
function PufferManager.GetResourceCfgByModuleIDActivityID(moduleID, activityID)
  moduleID = tonumber(moduleID)
  activityID = tonumber(activityID)
  local cfg
  if activityID then
    cfg = CDataTable.GetTableDataByFilter("ActivityResourcesCfg", "ActivityID", activityID)
  elseif moduleID then
    cfg = CDataTable.GetTableDataByFilter("ActivityResourcesCfg", "ModuleID", moduleID)
  end
  return cfg
end
function PufferManager.GetResourcePathByModuleIDAndActivityID(moduleID, activityID)
  activityID = tonumber(activityID)
  local result = PufferManager.GetResourceCfgByModuleIDActivityID(moduleID, activityID)
  if result and result.BPPath and result.BPPath ~= "" then
    return result.BPPath
  end
  if not LobbySystem.CheckOpen(BP_ENUM_SUPPLY_LUCKY_SPINE_SWITCH) and Client and not Client.IsShipping() then
    ShowDevNotice("###\231\188\186\229\176\145\233\133\141\231\189\174\230\136\150\233\133\141\231\189\174\233\148\153\232\175\175\239\188\140\232\175\183\230\163\128\230\159\165\227\128\144\229\136\134\229\140\133\228\184\139\232\189\189\229\165\150\229\138\177-\230\180\187\229\138\168\232\181\132\230\186\144\230\152\160\229\176\132\232\161\168\227\128\145\233\133\141\231\189\174\232\161\168")
  end
  return nil
end
function PufferManager.GetDownloadListByModuleIDActivityID(moduleID, activityID)
  local list = {}
  local cfg = PufferManager.GetResourceCfgByModuleIDActivityID(moduleID, activityID)
  if not cfg then
    log(bWriteLog and string.format("PufferManager.GetDownloadListByModuleIDActivityID cfg not find moduleID:%s activityID:%s", tostring(moduleID), tostring(activityID)))
    return {}
  end
  if cfg.BPPath and cfg.BPPath ~= "" then
    log(bWriteLog and "PufferManager.GetDownloadListByModuleIDActivityID actInfo.BPPath = " .. cfg.BPPath)
    table.insert(list, cfg.BPPath)
    if moduleID ~= BP_ENUM_MODULE_LADDER_DRAW then
      table.insert(list, PufferConst.ActivityAudioItemID)
    end
  end
  if cfg.AudioActorID and cfg.AudioActorID > 0 then
    log(bWriteLog and "PufferManager.GetDownloadListByModuleIDActivityID actInfo.AudioActorID = " .. cfg.AudioActorID)
    table.insert(list, cfg.AudioActorID)
  end
  return list
end
function PufferManager.GetStateByModuleIDActivityID(moduleID, activityID)
  local list = PufferManager.GetDownloadListByModuleIDActivityID(moduleID, activityID)
  if not next(list) then
    return PufferConst.ENUM_DownloadState.Done
  end
  local state = PufferManager.GetState(ENUM_DownloadType.ODPAK, list)
  if state ~= PufferConst.ENUM_DownloadState.Done then
    local title = LocUtil.GetLocalizeResStr(5077)
    local _, size = PufferManager.GetSize(ENUM_DownloadType.ODPAK, list)
    size = size / PufferConst.MB
    local strSize = string.format("%.2f MB", size)
    local askTips = LocUtil.LocalizeResFormat(7921, strSize)
    local ok = function()
      local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
      PufferManager.Download(ENUM_DownloadType.ODPAK, list, PufferTlog.Enum_TLog_From.Click)
    end
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, title, askTips, ok)
    return state
  end
  return PufferConst.ENUM_DownloadState.Done
end
function PufferManager.GetStateByModuleIDActivityIDForSupply(moduleID, activityID, callback)
  local list = PufferManager.GetDownloadListByModuleIDActivityID(moduleID, activityID, callback)
  if not next(list) then
    return PufferConst.ENUM_DownloadState.Done
  end
  local state = PufferManager.GetState(ENUM_DownloadType.ODPAK, list)
  if state ~= PufferConst.ENUM_DownloadState.Done then
    local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
    PufferManager.Download(ENUM_DownloadType.ODPAK, list, PufferTlog.Enum_TLog_From.Click, callback)
    return state
  end
  return PufferConst.ENUM_DownloadState.Done
end
function PufferManager.SetDownEventByModuleIDActivityIDForSupply(moduleID, activityID, doneCallEvent)
  local list = PufferManager.GetDownloadListByModuleIDActivityID(moduleID, activityID)
  if not next(list) then
    return PufferConst.ENUM_DownloadState.Done
  end
  local state = PufferManager.GetState(ENUM_DownloadType.ODPAK, list)
  if state ~= PufferConst.ENUM_DownloadState.Done then
    local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
    PufferManager.Download(ENUM_DownloadType.ODPAK, list, PufferTlog.Enum_TLog_From.Click, doneCallEvent)
    return state
  end
  return PufferConst.ENUM_DownloadState.Done
end
function PufferManager.UpdateResourceStream()
  local PufferODPakManager = PufferManager.GetDownloadManager(PufferConst.ENUM_DownloadType.ODPAK)
  local InfoList = Client.GetKnownMissingPackage("/Game/", "")
  local Count = 0
  local list = {}
  local pak_util = require("client.common.pak_util")
  local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
  for _, AssetId in pairs(InfoList) do
    log(bWriteLog and AssetId)
    if not PufferODPakManager.BlackListPaks[AssetId] then
      local ODPakName = Client.GetODPakName(AssetId)
      if ODPakName == PufferConst.LOCK_PAKNAME or ODPakName == PufferConst.CE_LOCK_PAKNAME then
      elseif "" ~= ODPakName then
        local bExist = pak_util.IsFileExist(AssetId)
        if bExist then
          Client.RemoveKnownMissingPackage(AssetId)
          log(bWriteLog and "PufferManager.UpdateResourceStream. RemoveKnownMissingPackage bExist is true AssetId: " .. AssetId)
          PufferTlog.SendTLog(PufferTlog.Enum_TLog_From.Stream, PufferTlog.Enum_TLog_Optype.Finish, "StreamDownloadFinish")
        elseif not PufferODPakManager.PauseDontAutoDownloadPaks[ODPakName] then
          log(bWriteLog and "PufferManager.UpdateResourceStream. download path = " .. AssetId)
          table.insert(list, AssetId)
          Count = Count + 1
        end
      else
        Client.RemoveKnownMissingPackage(AssetId)
        log(bWriteLog and "PufferManager.UpdateResourceStream. RemoveKnownMissingPackage ODPakName is nil AssetId: " .. AssetId)
      end
      if 3 < Count then
        break
      end
    end
  end
  PufferManager.Download(ENUM_DownloadType.ODPAK, list, PufferTlog.Enum_TLog_From.Stream, nil, StreamExtraData)
end
function PufferManager.OnDeleteFileNotify(fileList)
end
function PufferManager.DownloadRelateActionList(itemID)
  local ItemMacros = require("client.slua.config.ClientMacros.ItemMacros")
  local itemCfg = CDataTable.GetTableData("Item", itemID)
  if not itemCfg or itemCfg.ItemType ~= ENUM_ITEM_TYPE.Extra or itemCfg.ItemQuality < ItemMacros.QUALITY_RED then
    return
  end
  local ActionList = {}
  local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
  local period = LogicXSuit.GetPeriodByItemId(itemID)
  if period then
    local periodCfg = LogicXSuit.GetBranchMapData(period, LogicXSuit.GetBranchByItemId(itemID))
    if periodCfg then
      if periodCfg.TeamupActionID > 0 then
        table.insert(ActionList, periodCfg.TeamupActionID)
      end
      if 0 < periodCfg.InviterActionID then
        table.insert(ActionList, periodCfg.InviterActionID)
        local InviteeActionList = LogicXSuit.GetInviteeActionList(periodCfg.InviterActionID)
        if InviteeActionList and 0 < #InviteeActionList then
          for _, v in pairs(InviteeActionList) do
            table.insert(ActionList, v)
          end
        end
      end
      if 0 < periodCfg.BattleActionID then
        table.insert(ActionList, periodCfg.BattleActionID)
      end
    end
  end
  local GoldSuitFeatureCfg = CDataTable.GetTableData("RealGoldenSuitFeature", itemID)
  if GoldSuitFeatureCfg and 0 < GoldSuitFeatureCfg.TemmupEmote then
    table.insert(ActionList, GoldSuitFeatureCfg.TemmupEmote)
  end
  local IslandShowEmoteCfg = CDataTable.GetTableByFilter("BornIslandShowEmoteCfg", "ItemID", itemID)
  if IslandShowEmoteCfg then
    for _, v in pairs(IslandShowEmoteCfg) do
      if v then
        if 0 < v.EmotionID then
          table.insert(ActionList, v.EmotionID)
        end
        if 0 < v.PrepareEmotionID then
          table.insert(ActionList, v.PrepareEmotionID)
        end
      end
    end
  end
  local EmotionLimitCfgCfg = CDataTable.GetTableByFilter("EmotionLimitCfg", "IsShow", 1)
  if EmotionLimitCfgCfg then
    for _, v in pairs(EmotionLimitCfgCfg) do
      local bExist = false
      for _, u in pairs(v.ItemID_a) do
        if u == itemID then
          table.insert(ActionList, v.EmotionID)
          bExist = true
        end
      end
      if bExist then
        break
      end
    end
  end
  if #ActionList <= 0 then
    return
  end
  local state = PufferManager.GetState(ENUM_DownloadType.ODPAK, ActionList)
  if state ~= ENUM_DownloadState.Done and state ~= ENUM_DownloadState.Download then
    PufferManager.Download(ENUM_DownloadType.ODPAK, ActionList, nil, nil, {bAutoDownload = true})
  end
end
function PufferManager.ReqDownloadBatchODPaks(_, _, hashCode, priority)
  if not GameStatus.IsInFightingStatus() then
    printf("PufferManager.ReqDownloadBatchODPaks. not in fight")
    return
  end
  if not hashCode then
    printf("PufferManager.ReqDownloadBatchODPaks. hashCode nil")
    return
  end
  printf("PufferManager.ReqDownloadBatchODPaks. hashCode=%s, priority=%s", tostring(hashCode), tostring(priority))
  local itemList = GCPufferDownloader.GetBatchODPaksDownloadList(Puffer, hashCode)
  log_tree("PufferManager.ReqDownloadBatchODPaks. itemList = ", itemList)
  local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
  local extraData = {bFirst = true, bAutoDownload = true}
  PufferManager.Download(ENUM_DownloadType.ODPAK, itemList, PufferTlog.Enum_TLog_From.Battle, nil, extraData)
  local PufferODPakManager = PufferManager.GetDownloadManager(ENUM_DownloadType.ODPAK)
  PufferODPakManager:AddBattleDownloadItem(hashCode, itemList)
end
function PufferManager.CheckDownloadEnvironment(path)
  if PufferSwitch.BanDownload then
    local state = PufferManager.GetStateWhenBanDownload(ENUM_DownloadType.ODPAK, {path})
    log(bWriteLog and string.format("PufferManager.CheckDownloadEnvironment assetPath = %s, state = %s", path, state))
    if state ~= PufferConst.ENUM_DownloadState.Done then
      log(bWriteLog and string.format("PufferManager.CheckDownloadEnvironment download is banned."))
      return false
    end
  end
  log(bWriteLog and string.format("PufferManager.CheckDownloadEnvironment download is allowed."))
  return true
end
function PufferManager.CheckDownloadOnJump(path, needShowDownMsg)
  if not PufferManager:CheckDownloadEnvironment(path) then
    return false
  end
  local state = PufferManager.GetState(ENUM_DownloadType.ODPAK, {path})
  if state ~= PufferConst.ENUM_DownloadState.Done then
    if not needShowDownMsg then
      return false
    end
    local title = LocUtil.GetLocalizeResStr(5077)
    local _, size = PufferManager.GetSize(ENUM_DownloadType.ODPAK, {path})
    size = size / PufferConst.MB
    local strSize = string.format("%.2f MB", size)
    local askTips = LocUtil.LocalizeResFormat(7921, strSize)
    local ok = function()
      local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
      PufferManager.Download(ENUM_DownloadType.ODPAK, {path}, PufferTlog.Enum_TLog_From.Click)
    end
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, title, askTips, ok)
    return false
  end
  return true
end
function PufferManager.GetMixDownloadState(state, newState)
  local curPriority = PufferConst.DownloadStatePriority[newState]
  local prePriority = PufferConst.DownloadStatePriority[state]
  if curPriority and prePriority and curPriority > prePriority then
    state = newState
  end
  return state
end
return PufferManager