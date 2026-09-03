local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
local PufferConst = require("client.slua.logic.download.puffer_const")
local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
local logic_lobby_downloader_tlog = {}
function logic_lobby_downloader_tlog.ReportDownloadMainUIDownloadPage(tabId, isDownloading)
  local reason_str = string.format("%s ; %s", tabId, isDownloading and "pause" or "start")
  log(bWriteLog and string.format("logic_lobby_downloader_tlog.ReportDownloadMainUIDownloadPage reason_str:%s", reason_str))
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.DownloadMainUIDownloadPage, 0, reason_str)
end
function logic_lobby_downloader_tlog.ReportSmartDownloadWakeUp(totalSize, needDownloadSize)
  if not totalSize or totalSize <= 0 then
    log_warning(bWriteLog and "logic_lobby_downloader_tlog.ReportSmartDownloadWakeUp totalSize is invalid")
    return
  end
  if not needDownloadSize or needDownloadSize < 0 then
    log_warning(bWriteLog and "logic_lobby_downloader_tlog.ReportSmartDownloadWakeUp needDownloadSize is invalid")
    return
  end
  local cSize = totalSize - needDownloadSize
  local reason_str = tonumber(cSize / totalSize)
  log(bWriteLog and string.format("logic_lobby_downloader_tlog.ReportSmartDownloadWakeUp cSize:%s, tSize:%s, rate:%s", cSize, totalSize, reason_str))
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.SmartDownloadWakeUp, 0, reason_str)
end
function logic_lobby_downloader_tlog.ReportSelectSmartDownloadPlan(planType, MemoryPlanEnable)
  local plane = planType == 1 and "memory" or "custom"
  local reason_str = string.format("%s ; %s", plane, MemoryPlanEnable and "memory enable" or "memory disable")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.SelectSmartDownloadPlan, 0, reason_str)
end
function logic_lobby_downloader_tlog.ReportDownloadByPreference(orderList)
  if not orderList or not next(orderList) then
    return
  end
  local reason_str = table.concat(orderList, "+")
  log(bWriteLog and string.format("logic_lobby_downloader_tlog:ReportDownloadPreference selectItemKeys: %s", reason_str))
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.DownloadByPreference, 0, reason_str)
end
logic_lobby_downloader_tlog.SourceQueue = {
  Memory = "memory",
  Custom = "custom",
  Click = "click"
}
function logic_lobby_downloader_tlog.ReportItemDownloaded(itemKey, sourceQueue)
  local reason_str = string.format("%s;%s", tostring(itemKey), sourceQueue)
  log(bWriteLog and string.format("logic_lobby_downloader_tlog.ReportItemDownloaded itemKey: %s", tostring(itemKey)))
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.FinishItemDownload, 0, reason_str)
end
logic_lobby_downloader_tlog.QueuePlan = {
  Memory = "memory",
  Recommend = "recommend",
  Custom = "custom"
}
function logic_lobby_downloader_tlog.ReportSmartDownloadQueueBegin(plan, size, count)
  local freeSpace = Client.GetDeviceFreeSpace()
  local netType = Client.HasActiveWifi()
  local netTypeStr = netType and "wifi" or "4g"
  local reason_str = string.format("%s;%s;%s;%s;%s", plan, size, count, freeSpace, netTypeStr)
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.SmartDownloadQueueBegin, 0, reason_str)
end
logic_lobby_downloader_tlog.QueueEndReason = {
  AllSuccess = "all success",
  Pause = "pause",
  ApplyNewPlan = "apply new plan",
  StorageFull = "storage full",
  NetTimeout = "net timeout"
}
function logic_lobby_downloader_tlog.ReportSmartDownloadQueueEnd(endReason)
  local smart_download_monitor = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.smart_download_monitor)
  if not smart_download_monitor.SaveData.SmartDownloadQueueRecord then
    return
  end
  local DownloadSystem = require("client.slua.logic.download.logic_lobby_downloader")
  local totalSize = 0
  local downloadedSize = 0
  for key, v in pairs(smart_download_monitor.SaveData.SmartDownloadQueueRecord) do
    if v then
      if key == PufferConst.EODPackID.UserCurEquipment then
        if DownloadSystem.userEquipmentItems then
          local cSize, tSize = PufferManager.GetSize(PufferConst.ENUM_DownloadType.ODPAK, DownloadSystem.userEquipmentItems, true)
          downloadedSize = downloadedSize + cSize
          totalSize = totalSize + tSize
        end
      elseif key == PufferConst.EODPackID.UserWardrobe then
        if DownloadSystem.userWardrobeItems then
          local cSize, tSize = PufferManager.GetSize(PufferConst.ENUM_DownloadType.ODPAK, DownloadSystem.userWardrobeItems, true)
          downloadedSize = downloadedSize + cSize
          totalSize = totalSize + tSize
        end
      else
        local _, curSizeInBytes, totalSizeInBytes = DownloadSystem.GetItemData(key)
        downloadedSize = downloadedSize + (curSizeInBytes or 0)
        totalSize = totalSize + (totalSizeInBytes or 0)
      end
    end
  end
  local duration = 0
  if smart_download_monitor.BeginTime and 0 < smart_download_monitor.BeginTime then
    duration = math.floor((os.time() - smart_download_monitor.BeginTime) / 60)
  end
  local remainSize = totalSize - downloadedSize
  if remainSize < 0 then
    remainSize = 0
  end
  local reason_str = string.format("%s;%s;%s;%s", endReason, tostring(downloadedSize), tostring(duration), tostring(remainSize))
  log(bWriteLog and string.format("logic_lobby_downloader_tlog.ReportSmartDownloadEnd endReason: %s", reason_str))
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.SmartDownloadQueueEnd, 0, reason_str)
end
function logic_lobby_downloader_tlog.ReportDownloadAllWarn(reason)
  local reason_str = "popup"
  if reason == 2 then
    reason_str = "apply"
  elseif reason == 3 then
    reason_str = "cancel"
  end
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.DownloadAllWarn, 0, reason_str)
end
function logic_lobby_downloader_tlog.ReportApplyNewDownloadPlan(reason)
  local reason_str = "popup"
  if reason == 2 then
    reason_str = "apply"
  elseif reason == 3 then
    reason_str = "cancel"
  end
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.ApplyNewDownloadPlan, 0, reason_str)
end
function logic_lobby_downloader_tlog.ReportResourceSnapShot()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  if not PlayerPrefsSystem.ePlayerPrefsType.eCurReportResourceSnapShotTime then
    return
  end
  local needReport = PlayerPrefsSystem.CheckAndSaveCurrentDate(PlayerPrefsSystem.ePlayerPrefsType.eCurReportResourceSnapShotTime.path, PlayerPrefsSystem.ePlayerPrefsType.eCurReportResourceSnapShotTime.needOpenIDTag, true, 7)
  if not needReport then
    return
  end
  local appVersion = Client.GetApplicationVersion()
  local PufferDeleteManager = require("client.slua.logic.download.delete.puffer_delete_manager")
  local curPaksSize = PufferDeleteManager.GetCurPaksSize()
  local reason_str = string.format("%s;%s", tostring(appVersion), tostring(math.floor(curPaksSize)))
  log(bWriteLog and string.format("logic_lobby_downloader_tlog.ReportResourceSnapShot appVersion:%s, curPaksSize:%s", tostring(appVersion), tostring(curPaksSize)))
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.ResourceSnapShot, 0, reason_str)
  PlayerPrefsSystem.CheckAndSaveCurrentDate(PlayerPrefsSystem.ePlayerPrefsType.eCurReportResourceSnapShotTime.path, PlayerPrefsSystem.ePlayerPrefsType.eCurReportResourceSnapShotTime.needOpenIDTag, false, 7)
end
return logic_lobby_downloader_tlog