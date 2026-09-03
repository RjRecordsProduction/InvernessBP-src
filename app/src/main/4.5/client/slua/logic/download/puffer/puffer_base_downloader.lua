local puffer_base_downloader = {}
local PufferConst = require("client.slua.logic.download.puffer_const")
function puffer_base_downloader:OnDownloadProgress(task, nowSize, totalSize, curStage, bNotPost)
  task.state = PufferConst.ENUM_DownloadState.Download
  if not bNotPost then
    local eventData = self:GetEventData(task)
    EventSystem:postEvent(EVENTTYPE_PUFFER, EVENTID_PUFFER_DOWNLOADPROGRESS, eventData)
  end
end
function puffer_base_downloader:OnDownloadFinish(task, errorCode, bNotPost)
  log(bWriteLog and string.format("puffer_base_downloader:OnDownloadFinish errorCode:%s pakName:%s itemID:%s path:%s,AssetID:%s,featureKey:%s packID:%s downloadType=%s", tostring(errorCode), task.pakName, tostring(task.itemID), tostring(task.path), tostring(task.assetID), tostring(task.featureKey), tostring(task.packID), tostring(task.downloadType)))
  local PufferErrorHandler = require("client.slua.logic.download.puffer.puffer_error_handler")
  PufferErrorHandler.ShowErrorTips(errorCode)
  if errorCode ~= 0 then
    local PufferGM = require("client.slua.logic.download.gm.puffer_gm")
    task.    PufferGM.ErrorTasks[task.pakName] = task
    log(bWriteLog and string.format("puffer_base_downloader:OnDownloadFinish pakName = %s, errorCode:%s", task.pakName, errorCode))
    if task.itemID then
      log(bWriteLog and string.format("puffer_base_downloader:OnDownloadFinish itemID = %s", task.itemID))
    end
    if task.path then
      log(bWriteLog and string.format("puffer_base_downloader:OnDownloadFinish path = %s", task.path))
    end
  end
  local puffer_queue = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_queue)
  puffer_queue:Erase(task.pakName)
  if type(task.callback) == "function" then
    task.callback()
  end
  if not bNotPost then
    local eventData = self:GetEventData(task, errorCode)
    EventSystem:postEvent(EVENTTYPE_PUFFER, EVENTID_PUFFER_DOWNLOADFINISH, eventData)
  end
  puffer_queue:StartDownload()
end
function puffer_base_downloader:DownloadByKeyList(downloadType, keyList, from, callback, extraData)
end
function puffer_base_downloader:Download(task, bNotPost)
  local puffer_queue = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_queue)
  puffer_queue:Push(task)
  puffer_queue:StartDownload()
  if (task.downloadType == PufferConst.ENUM_DownloadType.MAP or task.downloadType == PufferConst.ENUM_DownloadType.RES) and not bNotPost then
    local eventData = self:GetEventData(task)
    EventSystem:postEvent(EVENTTYPE_PUFFER, EVENTID_PUFFER_DOWNLOADPROGRESS, eventData)
  end
end
function puffer_base_downloader:PauseByKeyList(downloadType, keyList, bWait, bNotStartDownload)
end
function puffer_base_downloader:Pause(pakName, bWait, bNotStartDownload, bNotPost)
  local puffer_queue = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_queue)
  local task = puffer_queue:GetTask(pakName)
  if task then
    puffer_queue:Erase(pakName, bWait)
    if not bNotStartDownload then
      puffer_queue:StartDownload()
    end
    if not bNotPost then
      local eventData = self:GetEventData(task)
      EventSystem:postEvent(EVENTTYPE_PUFFER, EVENTID_PUFFER_DOWNLOADPROGRESS, eventData)
    end
  end
end
function puffer_base_downloader:GetEventData(task, errorCode)
  local eventData = {}
  eventData.pakName = task.pakName
  eventData.itemID = task.itemID
  eventData.packID = task.packID
  eventData.path = task.path
  eventData.resKey = task.resKey
  eventData.mapKey = task.mapKey
  eventData.downloadType = task.downloadType
  eventData.assetID = task.assetID
  eventData.  return eventData
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CPufferBase = class(CModuleBase, nil, puffer_base_downloader)
return CPufferBase