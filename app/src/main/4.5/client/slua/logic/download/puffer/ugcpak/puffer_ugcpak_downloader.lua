local puffer_ugcpak_downloader = {}
local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
local PufferConst = require("client.slua.logic.download.puffer_const")
local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
function puffer_ugcpak_downloader:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_PUFFER, EVENTID_PUFFERQUEUE_CLEAR, self.OnQueueClear, self)
end
function puffer_ugcpak_downloader:OnDownloadProgress(task, nowSize, totalSize, curStage)
  task.totalSize = totalSize / 1024
  if task.packID then
    local PufferUGCPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_ugcpak_manager)
    if PufferUGCPakManager.paks[task.packID] then
      PufferUGCPakManager.paks[task.packID].state = PufferConst.ENUM_DownloadState.Download
    end
  end
  puffer_ugcpak_downloader.__super.OnDownloadProgress(self, task, nowSize, totalSize, curStage)
end
function puffer_ugcpak_downloader:OnDownloadFinish(task, outterTaskID, isSuccess, errorCode)
  if isSuccess then
    local isPakFileExist = Client.IsFileExistsWithOutPakCheck(Client.ProjectSavedDir() .. PufferDownloader.DOWNLOAD_DIR_RELATIVE .. task.pakName)
    if not isPakFileExist then
      log(bWriteLog and "PufferManager.SyncFinishToCallback pak is corrupt pakName = " .. tostring(task.pakName))
      isSuccess = false
      errorCode = PufferDownloader.ERR_PAK_CORRUPTED
      PufferDownloader.filestateList[outterTaskID].lastErrno = PufferDownloader.ERR_PAK_CORRUPTED
    end
    PufferDownloader.SetPakExist(task.pakName, isPakFileExist)
    print(bWriteLog and "puffer_ugcpak_downloader:OnDownloadFinish pakName = " .. tostring(task.pakName))
  end
  local PufferUGCPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_ugcpak_manager)
  PufferUGCPakManager:OnDownloadFinish(task, isSuccess, errorCode)
  local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
  PufferODPakManager:OnDownloadFinish(task, isSuccess, errorCode, true)
  puffer_ugcpak_downloader.__super.OnDownloadFinish(self, task, errorCode)
  if isSuccess then
    local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
    PufferMapManager:UploadClientMapState(task.pakName)
  end
end
function puffer_ugcpak_downloader:OnQueueClear()
  local PufferUGCPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_ugcpak_manager)
  for i, v in pairs(PufferUGCPakManager.paks) do
    if v.state == PufferConst.ENUM_DownloadState.Download or v.state == PufferConst.ENUM_DownloadState.Wait then
      v.state = PufferConst.ENUM_DownloadState.Pause
    end
  end
  EventSystem:postEvent(EVENTTYPE_PUFFER, EVENTID_PUFFER_PAUSEALLDOWNLOAD)
end
function puffer_ugcpak_downloader:DownloadByKeyList(downloadType, keyList, from, callback, extraData)
  for i, v in pairs(keyList) do
    if downloadType == PufferConst.ENUM_DownloadType.UGCPAK then
      if type(v) == "number" then
        self:DownloadByAssetID(v, from, callback, extraData)
      elseif string.sub(v, 1, 7) == PufferConst.UGCPAKS_RELATIVE_DIR then
        self:Download(v, from, callback, extraData)
      else
        self:DownloadByPath(v, from, callback, extraData)
      end
    elseif downloadType == PufferConst.ENUM_DownloadType.UGCPACK then
      self:DownloadByPackID(v, from, callback, extraData)
    end
  end
end
function puffer_ugcpak_downloader:DownloadByAssetID(assetID, from, callback, extraData)
  local PufferUGCPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_ugcpak_manager)
  local bMinDepends = false
  if extraData and extraData.bMinDepends then
    bMinDepends = extraData.bMinDepends
  end
  local paks = PufferUGCPakManager:GetPakNamesByAssetID(assetID)
  for pakName, _ in pairs(paks) do
    self:Download(pakName, assetID, nil, from, callback, extraData)
  end
  local TableUtil = require("common.table_util")
  local dependExtraData = TableUtil.CopyTable(extraData)
  dependExtraData.bSkipPopUp = true
  local NecessaryFeatureKeys = PufferUGCPakManager:GetNecessaryFeatureDepends(assetID)
  local puffer_odpak_downloader = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_downloader)
  puffer_odpak_downloader:DownloadByKeyList(PufferConst.ENUM_DownloadType.ODPAK, NecessaryFeatureKeys, from, callback, dependExtraData)
  if bMinDepends then
  else
    local DependFeatureKeys, DependAssetIDs = PufferUGCPakManager:GetDepends(assetID)
    puffer_odpak_downloader:DownloadByKeyList(PufferConst.ENUM_DownloadType.ODPAK, DependFeatureKeys, from, callback, dependExtraData)
    local puffer_ugcpak_downloader = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_ugcpak_downloader)
    puffer_ugcpak_downloader:DownloadByKeyList(PufferConst.ENUM_DownloadType.UGCPAK, DependAssetIDs, nil, nil, {bMinDepends = true})
  end
end
function puffer_ugcpak_downloader:DownloadByPath(path, from, callback, extraData)
  local PufferUGCPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_ugcpak_manager)
  if PufferUGCPakManager:GetStateByPath(path) == PufferConst.ENUM_DownloadState.Done then
    return
  end
  local pakName = PufferManager.GetPakName(path)
  if pakName ~= "" then
    self:Download(pakName, nil, path, from, callback, extraData)
  end
end
function puffer_ugcpak_downloader:DownloadByPackID(packID, from, callback, extraData)
  local PufferUGCPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_ugcpak_manager)
  if PufferUGCPakManager:GetStateByPackID(packID) == PufferConst.ENUM_DownloadState.Done then
    return
  end
  extraData = extraData or {}
  local okCallback = function()
    local pack = PufferUGCPakManager.paks[packID]
    if pack and pack.paks then
      local puffer_queue = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_queue)
      for pakName, v in pairs(pack.paks) do
        if v.state ~= PufferConst.ENUM_DownloadState.Done then
          local task = {}
          task.          task.          task.          task.downloadType = PufferConst.ENUM_DownloadType.UGCPACK
          task.          puffer_queue:Push(task)
        end
      end
      pack.state = PufferConst.ENUM_DownloadState.Download
      puffer_queue:StartDownload()
    end
    log_format("puffer_ugcpak_downloader:DownloadByPackID PackID %s", packID)
    local TableUtil = require("common.table_util")
    local dependExtraData = TableUtil.CopyTable(extraData)
    dependExtraData.bSkipPopUp = true
    local puffer_odpak_downloader = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_downloader)
    puffer_odpak_downloader:DownloadByPackID(packID, from, callback, dependExtraData)
    PufferTlog.SendTLog(from, PufferTlog.Enum_TLog_Optype.Start, packID)
  end
  local PufferSwitch = require("client.slua.logic.download.puffer_switch")
  if extraData.bSkipPopUp or PufferSwitch.CanAutoDownload() then
    okCallback()
  else
    local title = LocUtil.GetLocalizeResStr(5077)
    local curSize, totalSize = PufferManager.GetSize(PufferConst.ENUM_DownloadType.UGCPACK, {packID})
    local size = totalSize - curSize
    local strSize = string.format("%.2f MB", size)
    local askTips = LocUtil.LocalizeResFormat(7921, strSize)
    local cfg = CDataTable.GetTableData("PakInfoTable", packID)
    if cfg and cfg.DownloadTipsID > 0 then
      strSize = string.format("%.2f", size)
      askTips = LocUtil.LocalizeResFormat(cfg.DownloadTipsID, strSize)
    end
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, title, askTips, okCallback)
  end
end
function puffer_ugcpak_downloader:Download(pakName, assetID, path, from, callback, extraData)
  local PufferUGCPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_ugcpak_manager)
  if PufferUGCPakManager.blackListPaks[pakName] then
    local PufferErrorHandler = require("client.slua.logic.download.puffer.puffer_error_handler")
    PufferErrorHandler.ShowErrorTips(1)
    return
  end
  if PufferUGCPakManager:GetStateByPakName(pakName) == PufferConst.ENUM_DownloadState.Done then
    return
  end
  extraData = extraData or {}
  local task = {}
  task.  task.  task.  task.  task.  task.downloadType = PufferConst.ENUM_DownloadType.UGCPAK
  for packID, v in pairs(PufferUGCPakManager.paks) do
    if v.paks and v.paks[pakName] then
      if extraData.bAutoDownload and v.paks[pakName].haveDeleted then
        return
      end
      if v.paks[pakName].cSize == 0 then
        v.paks[pakName].cSize = v.paks[pakName].cSize + v.paks[pakName].tSize / 15
      end
      v.state = PufferConst.ENUM_DownloadState.Download
      task.      break
    end
  end
  if pakName == PufferConst.LOCK_PAKNAME then
    log(bWriteLog and string.format("puffer_ugcpak_downloader:Download pakName:%s, assetID:%s, path:%s", pakName, tostring(assetID), tostring(path)))
  end
  log(bWriteLog and "[DebugUGC] puffer_ugcpak_downloader:Download AssetID = " .. tostring(assetID) .. ",pakName = " .. tostring(pakName))
  puffer_ugcpak_downloader.__super.Download(self, task)
end
function puffer_ugcpak_downloader:PauseByKeyList(downloadType, keyList, bWait, bNotStartDownload, extraData)
  for i, v in pairs(keyList) do
    if downloadType == PufferConst.ENUM_DownloadType.UGCPAK then
      if type(v) == "number" then
        self:PauseByAssetID(v, bWait, true, extraData)
      elseif string.sub(v, 1, 7) == PufferConst.UGCPAKS_RELATIVE_DIR then
        self:Pause(v, bWait, true)
      else
        self:PauseByPath(v, bWait, true)
      end
    elseif downloadType == PufferConst.ENUM_DownloadType.UGCPACK then
      self:PauseByPackID(v)
    end
  end
  if not bNotStartDownload then
    local puffer_queue = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_queue)
    puffer_queue:StartDownload()
  end
end
function puffer_ugcpak_downloader:PauseByAssetID(assetID, bWait, bNotStartDownload, extraData)
  local PufferUGCPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_ugcpak_manager)
  if PufferUGCPakManager.assetToPaks[assetID] then
    for pakName, _ in pairs(PufferUGCPakManager.assetToPaks[assetID].paks) do
      self:Pause(pakName, bWait, bNotStartDownload)
    end
  end
  local bMinDepends = false
  if extraData and extraData.bMinDepends then
    bMinDepends = extraData.bMinDepends
  end
  local NecessaryFeatureKeys = PufferUGCPakManager:GetNecessaryFeatureDepends(assetID)
  local puffer_odpak_downloader = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_downloader)
  puffer_odpak_downloader:PauseByKeyList(PufferConst.ENUM_DownloadType.ODPAK, NecessaryFeatureKeys, bWait, bNotStartDownload)
  if bMinDepends then
  else
    local DependFeatureKeys, DependAssetIDs = PufferUGCPakManager:GetDepends(assetID)
    puffer_odpak_downloader:PauseByKeyList(PufferConst.ENUM_DownloadType.ODPAK, DependFeatureKeys, bWait, bNotStartDownload)
    local puffer_ugcpak_downloader = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_ugcpak_downloader)
    puffer_ugcpak_downloader:PauseByKeyList(PufferConst.ENUM_DownloadType.UGCPAK, DependAssetIDs, nil, nil, {bMinDepends = true})
  end
end
function puffer_ugcpak_downloader:PauseByPath(path, bWait, bNotStartDownload)
  local pakName = PufferManager.GetPakName(path)
  self:Pause(pakName, bWait, bNotStartDownload)
end
function puffer_ugcpak_downloader:PauseByPackID(packID)
  local PufferUGCPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_ugcpak_manager)
  if PufferUGCPakManager:GetStateByPackID(packID) == PufferConst.ENUM_DownloadState.Done then
    return
  end
  local puffer_odpak_downloader = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_downloader)
  puffer_odpak_downloader:PauseByPackID(packID)
  local pack = PufferUGCPakManager.paks[packID]
  if not pack or not pack.paks then
    return
  end
  local puffer_queue = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_queue)
  puffer_queue:EraseByPaks(pack.paks)
  pack.state = PufferConst.ENUM_DownloadState.Pause
end
function puffer_ugcpak_downloader:Pause(pakName, bWait, bNotStartDownload)
  local PufferUGCPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_ugcpak_manager)
  for _, v in pairs(PufferUGCPakManager.paks) do
    if v.paks and v.paks[pakName] then
      v.state = PufferConst.ENUM_DownloadState.Pause
      break
    end
  end
  puffer_ugcpak_downloader.__super.Pause(self, pakName, bWait, bNotStartDownload)
end
function puffer_ugcpak_downloader:PauseAllDownloadTasks()
  local PufferUGCPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_ugcpak_manager)
  for i, v in pairs(PufferUGCPakManager.paks) do
    if v.state == PufferConst.ENUM_DownloadState.Download or v.state == PufferConst.ENUM_DownloadState.Wait then
      v.state = PufferConst.ENUM_DownloadState.Pause
    end
  end
end
local class = require("class")
local CPufferBase = require("client.slua.logic.download.puffer.puffer_base_downloader")
local CPufferUGCPak = class(CPufferBase, nil, puffer_ugcpak_downloader)
return CPufferUGCPak