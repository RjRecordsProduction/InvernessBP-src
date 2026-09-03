local smart_download_monitor = {
  SmartDownloadQueueState = {},
  TaskErrorCode = {},
  BeginTime = 0,
  SaveData = {
    SmartDownloadQueueRecord = {},
    SmartDownloadSize = 0,
    SmartDownloadCount = 0
  }
}
local STORAGE_FULL_ERROR_CODES = {
  [269811740] = true,
  [203423772] = true,
  [271581189] = true
}
local NETWORK_TIMEOUT_ERROR_CODES = {
  [269615110] = true,
  [269615111] = true,
  [269549569] = true,
  [269615507] = true,
  [269615156] = true,
  [269615160] = true,
  [269615520] = true,
  [269615508] = true,
  [269550069] = true
}
function smart_download_monitor:OnInitialize()
  self:LoadSmartDownloadQueueRecord()
  self:AddCommonEvent(EVENTTYPE_PUFFER, EVENTID_PUFFER_DOWNLOADFINISH, self.OnDownloadFinish, self)
end
function smart_download_monitor:RecoverSmartDownloadQueue(extra)
  log(bWriteLog and "smart_download_monitor:RecoverSmartDownloadQueue")
  local PufferSwitch = require("client.slua.logic.download.puffer_switch")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local pufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local downloaderTlog = require("client.slua.logic.download.report.logic_lobby_downloader_tlog")
  local hasWifi = Client.HasActiveWifi()
  local autoDownloadCfg = PufferSwitch.AutoDownloadCfg
  local canAutoDownload = false
  if autoDownloadCfg.AutoDownloadWIFISwitch and hasWifi then
    canAutoDownload = true
  elseif autoDownloadCfg.AutoDownload4GSwitch and not hasWifi then
    canAutoDownload = true
  end
  if canAutoDownload then
    if not self.SaveData.SmartDownloadQueueRecord or not next(self.SaveData.SmartDownloadQueueRecord) then
      log(bWriteLog and "smart_download_monitor:RecoverSmartDownloadQueue no record")
      return
    end
    local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
    for k, v in pairs(self.SaveData.SmartDownloadQueueRecord) do
      if v then
        local downloadType = PufferConst.ENUM_DownloadType.ODPAK
        local keyList = {}
        local packID = tonumber(k)
        if packID then
          downloadType = PufferConst.ENUM_DownloadType.ODPACK
          keyList = {packID}
        else
          downloadType = pufferManager.GetDownloadType(k)
          keyList = {k}
        end
        pufferManager.Download(downloadType, keyList, PufferTlog.Enum_TLog_From.Auto, nil, extra)
      end
    end
    PufferSwitch.isToggleDownloadingAll = true
    self.SmartDownloadQueueState = {}
    self.BeginTime = os.time()
    local pufferSwitch = require("client.slua.logic.download.puffer_switch")
    local smartDownloadPlan = downloaderTlog.QueuePlan.Memory
    if pufferSwitch.AutoDownloadCfg.RecordDownloadPakID then
      smartDownloadPlan = downloaderTlog.QueuePlan.Custom
      if pufferSwitch.SmartDownloadCfg.DownloadCfgFromDefault then
        smartDownloadPlan = downloaderTlog.QueuePlan.Recommend
      end
    end
    log_tree("smart_download_monitor:RecoverSmartDownloadQueue begin download:", self.SaveData.SmartDownloadQueueRecord)
    downloaderTlog.ReportSmartDownloadQueueBegin(smartDownloadPlan, self.SaveData.SmartDownloadSize, self.SaveData.SmartDownloadCount)
  end
end
function smart_download_monitor:OnSmartDownloadQueueBegin(smartDownloadSelectMap, smartDownloadSize, smartDownloadCount)
  local TableUtil = require("common.table_util")
  local downloaderTlog = require("client.slua.logic.download.report.logic_lobby_downloader_tlog")
  local pufferSwitch = require("client.slua.logic.download.puffer_switch")
  self.SaveData.SmartDownloadQueueRecord = TableUtil.CopyTable(smartDownloadSelectMap)
  self.SaveData.SmartDownloadSize = smartDownloadSize
  self.SaveData.SmartDownloadCount = smartDownloadCount
  self.SmartDownloadQueueState = {}
  self.BeginTime = os.time()
  local smartDownloadPlan = downloaderTlog.QueuePlan.Memory
  if pufferSwitch.AutoDownloadCfg.RecordDownloadPakID then
    smartDownloadPlan = downloaderTlog.QueuePlan.Custom
    if pufferSwitch.SmartDownloadCfg.DownloadCfgFromDefault then
      smartDownloadPlan = downloaderTlog.QueuePlan.Recommend
    end
  end
  downloaderTlog.ReportSmartDownloadQueueBegin(smartDownloadPlan, smartDownloadSize, smartDownloadCount)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(self.SaveData, PlayerPrefsSystem.ePlayerPrefsType.eSmartDownloadQueueRecord)
  log_tree("smart_download_monitor:RecordSmartDownloadQueue DownloadQueueRecord=", self.SaveData)
end
function smart_download_monitor:ResetSmartDownloadQueueRecord()
  self.SaveData.SmartDownloadQueueRecord = {}
  self.SaveData.SmartDownloadSize = 0
  self.SaveData.SmartDownloadCount = 0
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(self.SaveData, PlayerPrefsSystem.ePlayerPrefsType.eSmartDownloadQueueRecord)
end
function smart_download_monitor:LoadSmartDownloadQueueRecord()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local record = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSmartDownloadQueueRecord) or {}
  self.SaveData.SmartDownloadQueueRecord = record.SmartDownloadQueueRecord or {}
  self.SaveData.SmartDownloadCount = record.SmartDownloadCount or {}
  self.SaveData.SmartDownloadSize = record.SmartDownloadSize or 0
  log_tree("smart_download_monitor:LoadSmartDownloadQueueRecord DownloadQueueRecord= ", record)
end
function smart_download_monitor:OnDownloadFinish(_, _, task)
  local pufferConst = require("client.slua.logic.download.puffer_const")
  local downloaderTlog = require("client.slua.logic.download.report.logic_lobby_downloader_tlog")
  local pufferSwitch = require("client.slua.logic.download.puffer_switch")
  local packKeys = self:GetPackKeyFromTask(task)
  for _, packKey in ipairs(packKeys) do
    local state = self:GetItemStateByPackKey(packKey)
    if self.SaveData.SmartDownloadQueueRecord[packKey] then
      local errorCode = task.errorCode ~= 0 and task.errorCode or nil
      self.TaskErrorCode[packKey] = errorCode or self.TaskErrorCode[packKey]
      self.SmartDownloadQueueState[packKey] = state
      if state == pufferConst.ENUM_DownloadState.Done then
        local sourceQueue = pufferSwitch.AutoDownloadCfg.RecordDownloadPakID and downloaderTlog.SourceQueue.Memory or downloaderTlog.SourceQueue.Custom
        downloaderTlog.ReportItemDownloaded(packKey, sourceQueue)
      end
    elseif state == pufferConst.ENUM_DownloadState.Done then
      downloaderTlog.ReportItemDownloaded(packKey, downloaderTlog.SourceQueue.Click)
    end
  end
  if not self.SaveData.SmartDownloadQueueRecord or not next(self.SaveData.SmartDownloadQueueRecord) then
    return
  end
  local allDone, allSuccess = self:CheckSmartDownloadState()
  if not allDone then
    return
  end
  if allSuccess then
    downloaderTlog.ReportSmartDownloadQueueEnd(downloaderTlog.QueueEndReason.AllSuccess)
    self:ResetSmartDownloadQueueRecord()
    return
  end
  local errorCode
  for k, v in pairs(self.TaskErrorCode) do
    if v and v ~= 0 then
      errorCode = v
      break
    end
  end
  if STORAGE_FULL_ERROR_CODES[errorCode] then
    downloaderTlog.ReportSmartDownloadQueueEnd(downloaderTlog.QueueEndReason.StorageFull)
  elseif NETWORK_TIMEOUT_ERROR_CODES[errorCode] then
    downloaderTlog.ReportSmartDownloadQueueEnd(downloaderTlog.QueueEndReason.NetTimeout)
  end
  self:ResetSmartDownloadQueueRecord()
end
function smart_download_monitor:GetPackKeyFromTask(task)
  if not task then
    return {}
  end
  local DownloadSystem = require("client.slua.logic.download.logic_lobby_downloader")
  local pufferConst = require("client.slua.logic.download.puffer_const")
  local result = {}
  local key = task.packID or task.mapKey or task.resKey
  if key then
    table.insert(result, key)
  end
  if DownloadSystem.userEquipmentPaks and DownloadSystem.userEquipmentPaks[task.pakName] then
    table.insert(result, pufferConst.EODPackID.UserCurEquipment)
  end
  if DownloadSystem.userWardrobePaks and DownloadSystem.userWardrobePaks[task.pakName] then
    table.insert(result, pufferConst.EODPackID.UserWardrobe)
  end
  return result
end
function smart_download_monitor:CheckSmartDownloadState(forceUpdateState)
  local pufferConst = require("client.slua.logic.download.puffer_const")
  local downloadSelectMap = self.SaveData.SmartDownloadQueueRecord
  if not downloadSelectMap or not next(downloadSelectMap) then
    return false, false
  end
  local allSuccess = true
  for k, v in pairs(downloadSelectMap) do
    if v then
      local state = self.SmartDownloadQueueState[k]
      if not state or forceUpdateState then
        state = self:GetItemStateByPackKey(k)
      end
      if state == pufferConst.ENUM_DownloadState.Download or state == pufferConst.ENUM_DownloadState.Wait then
        return false, false
      end
      if state ~= pufferConst.ENUM_DownloadState.Done then
        allSuccess = false
      end
    end
  end
  return true, allSuccess
end
function smart_download_monitor:GetItemStateByPackKey(packKey)
  local DownloadSystem = require("client.slua.logic.download.logic_lobby_downloader")
  local pufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  if packKey == pufferConst.EODPackID.UserCurEquipment and DownloadSystem.userEquipmentItems then
    return PufferManager.GetState(pufferConst.ENUM_DownloadType.ODPAK, DownloadSystem.userEquipmentItems)
  elseif packKey == pufferConst.EODPackID.UserWardrobe and DownloadSystem.userWardrobeItems then
    return PufferManager.GetState(pufferConst.ENUM_DownloadType.ODPAK, DownloadSystem.userWardrobeItems)
  else
    local itemData = DownloadSystem.GetItemData(packKey)
    return itemData.state
  end
end
function smart_download_monitor:OnPauseSmartDownload(key)
  if not self.SaveData.SmartDownloadQueueRecord then
    return
  end
  local logic_lobby_downloader_tlog = require("client.slua.logic.download.report.logic_lobby_downloader_tlog")
  local allDone, allSuccess = self:CheckSmartDownloadState(true)
  if allDone then
    logic_lobby_downloader_tlog.ReportSmartDownloadQueueEnd(logic_lobby_downloader_tlog.QueueEndReason.Pause)
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CSmartDownloadMonitor = class(CModuleBase, nil, smart_download_monitor)
return CSmartDownloadMonitor