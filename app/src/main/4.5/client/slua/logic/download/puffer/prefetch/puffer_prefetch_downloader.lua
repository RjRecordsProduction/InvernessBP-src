local puffer_prefetch_downloader = {}
local PufferConst = require("client.slua.logic.download.puffer_const")
local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
function puffer_prefetch_downloader:OnPostSwitchGameStatus(preState, nextState)
end
function puffer_prefetch_downloader:OnDownloadProgress(task, curSize, totalSize, curStage)
  local pakName = task.pakName
  local PufferPrefetchManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_prefetch_manager)
  PufferPrefetchManager.PrefetchPaks[pakName].state = PufferConst.ENUM_DownloadState.Download
  local proportion = PufferDownloader.StageTimeProportion[curStage]
  PufferPrefetchManager.PrefetchPaks[pakName].percent = curSize / totalSize * 1000 * proportion[1] + proportion[2] * 1000
  PufferPrefetchManager.PrefetchPaks[pakName].curSize = PufferPrefetchManager.PrefetchPaks[pakName].totalSize * math.min(math.max(PufferPrefetchManager.PrefetchPaks[pakName].percent - 50, 0), 700) / 700
  puffer_prefetch_downloader.__super.OnDownloadProgress(self, task, curSize, totalSize, curStage)
end
function puffer_prefetch_downloader:OnDownloadFinish(task, outterTaskID, isSuccess, errorCode)
  local corruptFileName = string.StrReplace(task.pakName, ".pak", ".corrupted", 1)
  local corrupt = PufferDownloader.IsFileExistByExtension(GameFrontendHUD, corruptFileName, "corrupted")
  if corrupt then
    log(bWriteLog and string.format("puffer_prefetch_downloader:OnDownloadFinish %s is corrupted", task.pakName))
    PufferDownloader.DeleteFile(corruptFileName)
    isSuccess = false
    errorCode = PufferDownloader.ERR_PAK_CORRUPTED
  end
  local pakName = task.pakName
  local PufferPrefetchManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_prefetch_manager)
  if isSuccess then
    PufferPrefetchManager.PrefetchPaks[pakName].state = PufferConst.ENUM_DownloadState.Done
    PufferPrefetchManager.PrefetchPaks[pakName].curSize = PufferPrefetchManager.PrefetchPaks[pakName].totalSize
    PufferPrefetchManager.PrefetchPaks[pakName].percent = 1000
    PufferTlog.SendTLog(PufferPrefetchManager.PrefetchPaks[pakName].from, PufferTlog.Enum_TLog_Optype.Finish, pakName, nil, true)
    local PufferDeleteManager = require("client.slua.logic.download.delete.puffer_delete_manager")
    PufferDeleteManager.UpdateDeviceFreeSpace(true)
  else
    PufferPrefetchManager.PrefetchPaks[pakName].state = PufferConst.ENUM_DownloadState.Not
    PufferPrefetchManager.PrefetchPaks[pakName].curSize = 0
    PufferPrefetchManager.PrefetchPaks[pakName].percent = 0
  end
  EventSystem:postEvent(EVENTTYPE_PUFFER, EVENTID_PUFFER_PREFETCH_DOWNLOADFINISH)
  puffer_prefetch_downloader.__super.OnDownloadFinish(self, task, errorCode)
  self:Download()
end
function puffer_prefetch_downloader:DownloadByKeyList(downloadType, keyList, from, callback, extraData)
  self:Download()
end
function puffer_prefetch_downloader:Download()
  local PufferPrefetchManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_prefetch_manager)
  if PufferPrefetchManager:GetState() == PufferConst.ENUM_DownloadState.Download then
    return
  end
  local prefetchPak
  for k, v in pairs(PufferPrefetchManager.PrefetchPaks) do
    if v.state ~= PufferConst.ENUM_DownloadState.Done then
      prefetchPak = v
      break
    end
  end
  if not prefetchPak then
    return
  end
  log(bWriteLog and string.format("puffer_prefetch_downloader:Download"))
  local task = {}
  task.pakName = prefetchPak.pakName
  task.from = PufferTlog.Enum_TLog_From.Prefetch
  task.downloadType = PufferConst.ENUM_DownloadType.PREFETCH
  prefetchPak.from = PufferTlog.Enum_TLog_From.Prefetch
  prefetchPak.state = PufferConst.ENUM_DownloadState.Download
  puffer_prefetch_downloader.__super.Download(self, task, extraData)
  PufferTlog.SendTLog(PufferTlog.Enum_TLog_From.Prefetch, PufferTlog.Enum_TLog_Optype.Start, prefetchPak.pakName, nil, true)
end
function puffer_prefetch_downloader:PauseByKeyList(downloadType, keyList, bWait, bNotStartDownload)
  self:Pause()
end
function puffer_prefetch_downloader:Pause()
  local PufferPrefetchManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_prefetch_manager)
  for k, v in pairs(PufferPrefetchManager.PrefetchPaks) do
    if v.state == PufferConst.ENUM_DownloadState.Download then
      v.state = PufferConst.ENUM_DownloadState.Pause
      puffer_prefetch_downloader.__super.Pause(self, v.pakName, false, false)
    end
  end
end
local class = require("class")
local CPufferBase = require("client.slua.logic.download.puffer.puffer_base_downloader")
local CPufferRes = class(CPufferBase, nil, puffer_prefetch_downloader)
return CPufferRes