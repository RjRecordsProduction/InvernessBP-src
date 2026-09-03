local puffer_res_downloader = {}
local PufferConst = require("client.slua.logic.download.puffer_const")
local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
function puffer_res_downloader:OnPostSwitchGameStatus(preState, nextState)
  if nextState == GameStatus.Lobby and preState == GameStatus.Fighting then
    local LogicNewbie = require("client.logic.newbie.logic_newbie")
    if LogicNewbie.newbieTotalGameCnt == 2 then
      self:Download(PufferConst.PUFFERPATCH, PufferTlog.Enum_TLog_From.Auto)
    end
  end
end
function puffer_res_downloader:OnDownloadProgress(task, curSize, totalSize, curStage)
  local PufferResManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_res_manager)
  local key = task.resKey
  if task.resKey == PufferConst.PUFFERPATCH then
    key = task.pakName
    PufferResManager.ResPaks[PufferConst.PUFFERPATCH].state = PufferConst.ENUM_DownloadState.Download
    PufferResManager.ResPaks[PufferConst.PUFFERPATCH].downloadingSize = curSize * 1024
  end
  PufferResManager.ResPaks[key].state = PufferConst.ENUM_DownloadState.Download
  local proportion = PufferDownloader.StageTimeProportion[curStage]
  PufferResManager.ResPaks[key].percent = curSize / totalSize * 1000 * proportion[1] + proportion[2] * 1000
  PufferResManager.ResPaks[key].curSize = PufferResManager.ResPaks[key].totalSize * math.min(math.max(PufferResManager.ResPaks[key].percent - 50, 0), 700) / 700
  puffer_res_downloader.__super:OnDownloadProgress(task, curSize, totalSize, curStage)
end
function puffer_res_downloader:OnDownloadFinish(task, outterTaskID, isSuccess, errorCode)
  local corruptFileName = string.StrReplace(task.pakName, ".pak", ".corrupted", 1)
  local corrupt = PufferDownloader.IsFileExistByExtension(GameFrontendHUD, corruptFileName, "corrupted")
  if corrupt then
    log(bWriteLog and string.format("puffer_res_downloader:OnDownloadFinish %s is corrupted", task.pakName))
    PufferDownloader.DeleteFile(corruptFileName)
    isSuccess = false
    errorCode = PufferDownloader.ERR_PAK_CORRUPTED
  end
  local key = task.resKey
  if task.resKey == PufferConst.PUFFERPATCH then
    key = task.pakName
  end
  local PufferResManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_res_manager)
  local data = PufferResManager.ResPaks[key] or {}
  if isSuccess then
    data.state = PufferConst.ENUM_DownloadState.Done
    data.curSize = data.totalSize
    data.percent = 1000
    PufferDownloader.SetDownloadKeyRecord(key, true)
    if task.resKey == PufferConst.PUFFERPATCH then
      if PufferResManager:GetLowestNotDownloadPufferPatch() == "" then
        PufferResManager.ResPaks[PufferConst.PUFFERPATCH].state = PufferConst.ENUM_DownloadState.Done
        ShowNotice(24962)
      else
        self:Download(PufferConst.PUFFERPATCH, task.from)
      end
      PufferResManager.ResPaks[PufferConst.PUFFERPATCH].curSize = PufferResManager.ResPaks[PufferConst.PUFFERPATCH].curSize + data.totalSize
      PufferResManager.ResPaks[PufferConst.PUFFERPATCH].downloadingSize = 0
      PufferResManager:ShowRestartTips()
    elseif task.resKey == PufferConst.FIT_SHADER_KEY then
      local path = Client.ProjectSavedDir() .. PufferConst.PAKS_RELATIVE_DIR .. task.pakName
      log(bWriteLog and "puffer_res_downloader:OnDownloadFinish. shader path = " .. tostring(path))
      local mountSuccess = Client.MountPakFile(path, "")
      log(bWriteLog and "puffer_res_downloader:OnDownloadFinish. mountSuccess = " .. tostring(mountSuccess))
      Client.OpenShaderCodeLibrary("../../../ShadowTrackerExtra/Content/", "")
      Client.EnableShaderGroup("map_lobby_CSM")
      log(bWriteLog and "puffer_res_downloader:OnDownloadFinish. map_lobby_CSM")
    elseif IsWoWEditor then
      local LobbyRes = PufferResManager.LobbyResMap[task.resKey]
      if LobbyRes then
        local Path = Client.ProjectSavedDir() .. PufferConst.PAKS_RELATIVE_DIR .. LobbyRes.pakName
        log(bWriteLog and "puffer_res_downloader:OnDownloadFinish. lobby res path = " .. tostring(Path))
        local bMountSuccess = Client.MountPakFile(Path, "")
        log(bWriteLog and "puffer_res_downloader:OnDownloadFinish. lobby res mountSuccess = " .. tostring(bMountSuccess))
      end
    end
    PufferTlog.SendTLog(data.from, PufferTlog.Enum_TLog_Optype.Finish, key)
    local PufferDeleteManager = require("client.slua.logic.download.delete.puffer_delete_manager")
    PufferDeleteManager.UpdateDeviceFreeSpace(true)
  else
    data.state = PufferConst.ENUM_DownloadState.Not
    data.curSize = 0
    data.percent = 0
    if task.resKey == PufferConst.PUFFERPATCH then
      PufferResManager.ResPaks[PufferConst.PUFFERPATCH].state = PufferConst.ENUM_DownloadState.Pause
      PufferResManager.ResPaks[PufferConst.PUFFERPATCH].downloadingSize = 0
    end
  end
  local pakName = task.pakName
  local StringUtil = require("common.string_util")
  if StringUtil.Starts(pakName, PufferConst.PUFFERPATCH) then
    local version = string.sub(pakName, string.len(PufferConst.PUFFERPATCH) + 2, string.len(pakName) - string.len(".pak"))
    log_format("puffer_res_downloader:OnDownloadFinish. version=%s", version)
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    local versionData = PufferManager.resourceVersionMap[version]
    if versionData then
      local ret = Client.MountPakFile(Client.ProjectSavedDir() .. PufferConst.PAKS_RELATIVE_DIR .. pakName, "")
      log_format("puffer_res_downloader:OnDownloadFinish. ret=%s", ret)
      local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
      PufferMapManager:UploadClientMapState(pakName)
    end
  end
  if task.resKey == "res_baltichd" then
  end
  puffer_res_downloader.__super:OnDownloadFinish(task, errorCode)
end
function puffer_res_downloader:DownloadByKeyList(downloadType, keyList, from, callback, extraData)
  for _, resKey in pairs(keyList) do
    self:Download(resKey, from, callback)
  end
end
function puffer_res_downloader:Download(resKey, from, callback)
  local PufferResManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_res_manager)
  if PufferResManager:GetState(resKey) == PufferConst.ENUM_DownloadState.Done then
    return
  end
  local res = PufferResManager.ResPaks[resKey]
  if not res then
    return
  end
  local puffer_queue = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_queue)
  local downloadTask = puffer_queue:GetDownloadingMapOrResTask()
  if downloadTask then
    if downloadTask.downloadType == PufferConst.ENUM_DownloadType.RES then
      log(bWriteLog and string.format("puffer_res_downloader:Download pause:%s", downloadTask.resKey))
      self:Pause(downloadTask.resKey, true, true)
    elseif downloadTask.downloadType == PufferConst.ENUM_DownloadType.MAP then
      local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
      log(bWriteLog and string.format("puffer_res_downloader:Download pause:%s", downloadTask.mapKey))
      PufferManager.Pause(PufferConst.ENUM_DownloadType.MAP, {
        downloadTask.mapKey
      }, true, true)
    end
  end
  local pakName = res.pakName
  if resKey == PufferConst.PUFFERPATCH then
    pakName = PufferResManager:GetLowestNotDownloadPufferPatch()
    local PufferShaderManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_shader_manager)
    if PufferShaderManager:GetState(pakName) ~= PufferConst.ENUM_DownloadState.Done then
      local puffer_shader_downloader = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_shader_downloader)
      puffer_shader_downloader:Download(pakName)
    end
  end
  if pakName == "" then
    return
  end
  local task = {}
  task.  task.  task.  task.  task.downloadType = PufferConst.ENUM_DownloadType.RES
  PufferResManager.ResPaks[resKey].  PufferResManager.ResPaks[resKey].state = PufferConst.ENUM_DownloadState.Download
  puffer_res_downloader.__super:Download(task)
  PufferTlog.SendTLog(from, PufferTlog.Enum_TLog_Optype.Start, res.pakName)
  if string.find(resKey, "res_baltichd") then
    local LogicSettingGraphics = require("client.slua.logic.setting.logic_setting_graphics")
    LogicSettingGraphics.SetUltraHighRedPoint()
  end
end
function puffer_res_downloader:PauseByKeyList(downloadType, keyList, bWait, bNotStartDownload)
  for _, resKey in pairs(keyList) do
    self:Pause(resKey, bWait, bNotStartDownload)
  end
end
function puffer_res_downloader:Pause(resKey, bWait, bNotStartDownload)
  local PufferResManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_res_manager)
  local res = PufferResManager.ResPaks[resKey]
  if not res then
    return
  end
  local pakName = res.pakName
  if res.state == PufferConst.ENUM_DownloadState.Done then
    return
  elseif res.state == PufferConst.ENUM_DownloadState.Download or res.state == PufferConst.ENUM_DownloadState.Wait then
    if bWait then
      PufferResManager.ResPaks[resKey].state = PufferConst.ENUM_DownloadState.Wait
    else
      PufferResManager.ResPaks[resKey].state = PufferConst.ENUM_DownloadState.Pause
    end
    if resKey == PufferConst.PUFFERPATCH then
      pakName = PufferResManager:GetLowestNotDownloadPufferPatch()
      local pakData = PufferResManager.ResPaks[pakName]
      if pakData then
        if bWait then
          pakData.state = PufferConst.ENUM_DownloadState.Wait
        else
          pakData.state = PufferConst.ENUM_DownloadState.Pause
        end
      end
    end
  end
  puffer_res_downloader.__super:Pause(pakName, bWait, bNotStartDownload)
end
function puffer_res_downloader:PauseAllDownloadTasks()
  local PufferResManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_res_manager)
  for resKey, res in pairs(PufferResManager.ResPaks) do
    if res.state == PufferConst.ENUM_DownloadState.Wait or res.state == PufferConst.ENUM_DownloadState.Download then
      self:Pause(resKey, false, true)
    end
  end
end
local class = require("class")
local CPufferBase = require("client.slua.logic.download.puffer.puffer_base_downloader")
local CPufferRes = class(CPufferBase, nil, puffer_res_downloader)
return CPufferRes