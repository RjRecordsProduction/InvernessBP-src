PufferUpdater = PufferUpdater or {}
local local local PufferUpdater.downloadCoroutine = nil
PufferUpdater.stageTipsPreFix = ""
PufferUpdater.errorTimes = 0
PufferUpdater.maxRetryTimes = 1
PufferUpdater.currentDownloadFileName = ""
PufferUpdater.DownloadFileProgress = {}
PufferUpdater.firstError = 0
PufferUpdater.needDownLoadFileList = {}
PufferUpdater.needRestartAfterDeleteCorruptFile = false
local extraData = {
  showUIKey = "com_msg_box_5s"
}
function PufferUpdater.IsLowLevel()
  local HighQualityThreshold = HDmpveRemote.HDmpveRemoteConfigGetInt("HighQualityThreshold", 3)
  log_shipping_client("PufferUpdater HighQualityThreshold = " .. tostring(HighQualityThreshold))
  local TCDeviceLevel = Client.GetTCDeviceLevel()
  log_shipping_client("PufferUpdater TCDeviceLevel = " .. tostring(TCDeviceLevel))
  if HighQualityThreshold > TCDeviceLevel then
    return true
  end
  return false
end
function PufferUpdater.DownloadFileList(isSuccess, errorCode)
  log(bWriteLog and "PufferUpdater.DownloadFileList " .. tostring(isSuccess) .. tostring(errorCode))
  if isSuccess == true then
    local msgConfig = LocUtil.GetLocalizeResStr(201026)
    local tips = ""
    if msgConfig then
      tips = PufferUpdater.stageTipsPreFix .. " (" .. tostring(msgConfig) .. ")"
    end
    local version_up_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.version_up_module)
    version_up_module:UpdateStageText(tips)
    PufferInterface.DownloadFilelist(PufferUpdater.ProcBasePak, PufferUpdater.OnPufferIniFailed)
  else
    PufferUpdater.OnPufferIniFailed("", errorCode)
  end
end
function PufferUpdater.UpdateUIOnInitProgress(curSize, totalSize)
  local msgConfig = LocUtil.GetLocalizeResStr(201027)
  local tips = ""
  if msgConfig then
    tips = PufferUpdater.stageTipsPreFix .. " (" .. tostring(msgConfig) .. ")"
  end
  local version_up_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.version_up_module)
  version_up_module:UpdateStageText(tips)
  version_up_module:UpdateProgressBar(curSize / totalSize * 100)
  version_up_module:ShowTipsWhenWiFi4GSwitched()
end
function PufferUpdater.OnPufferIniFailed(filename, errorcode)
  log(bWriteLog and "PufferUpdater InitializePuffer failed" .. tostring(filename) .. tostring(errorcode))
  PufferUpdater.ShowErrorTips(errorcode)
end
function PufferUpdater.IsDeviceNeedShaderPak(PakName)
  local NeedPak = true
  if string.find(PakName, "shader_") then
    local APILevel = tostring(Client.GetCurrentRHILevel(GameFrontendHUD))
    NeedPak = false
    if string.find(PakName, "es2shader_") and string.find(APILevel, "ES2") then
      NeedPak = true
    elseif string.find(PakName, "es3shader_") and string.find(APILevel, "ES3") then
      NeedPak = true
    end
    log(bWriteLog and "PufferUpdater.IsDeviceNeedShaderPak APILevel=" .. APILevel .. " PakName=" .. PakName .. " NeedPak=" .. tostring(NeedPak))
  end
  return NeedPak
end
function PufferUpdater.IsDeviceNeedPak(PakName)
  log(bWriteLog and "PufferUpdater.DeviceNoNeedPak: " .. PakName)
  local lowDevice = false
  if not PufferUpdater.bDownloadHighQuality then
    lowDevice = true
  end
  local ExportKeyWords = {
    LowLevel = {"md_", "hd_"},
    MidLevel = {"ld_", "hd_"},
    HighLevel = {"ld_", "md_"}
  }
  local NeedPak = true
  local KeyWords = {}
  if lowDevice then
    KeyWords = ExportKeyWords.LowLevel
  else
    KeyWords = ExportKeyWords.MidLevel
  end
  for k, v in ipairs(KeyWords) do
    log(bWriteLog and tostring(k) .. ": " .. tostring(v))
    if string.find(PakName, v) then
      NeedPak = false
      break
    end
  end
  if NeedPak and not PufferUpdater.IsDeviceNeedShaderPak(PakName) then
    NeedPak = false
  end
  log(bWriteLog and "NeedPak: " .. tostring(NeedPak))
  return NeedPak
end
function PufferUpdater.BasePrefetchFileProcess()
  log(bWriteLog and "PufferUpdater.BasePrefetchFileProcess")
  local OpenSwitch = false
  log(bWriteLog and FuncUtil.remoteCfgBasePreFetch)
  if FuncUtil.remoteCfgBasePreFetch ~= nil and FuncUtil.remoteCfgBasePreFetch > 0 then
    OpenSwitch = true
    log(bWriteLog and "PufferUpdater.BasePrefetchFileProcess 111")
  end
  if Client.IsBasePrefecthOpen() then
    OpenSwitch = true
    log(bWriteLog and "PufferUpdater.BasePrefetchFileProcess Client.IsBasePrefecthOpen true")
  end
  local BasePrefecthKey = "baseprefetch"
  local BaseDiffPrefecthKey = "basediffprefetch"
  local version = Client.GetAppVersion()
  local version_util = require("client.common.version_util")
  version = version_util.ExcludeTheBuildNumber(version)
  local TargetDir = Client.ProjectSavedDir() .. "Paks/"
  local file_util = require("client.common.file_util")
  local basePrefetchFilelist = file_util.FindFiles(TargetDir, BasePrefecthKey, false, true)
  local baseDiffPrefetchFilelist = file_util.FindFiles(TargetDir, BaseDiffPrefecthKey, false, true)
  if OpenSwitch then
    local space = Client.GetDeviceFreeSpace()
    if space < 400 then
      log(bWriteLog and "PufferUpdater.BasePrefetchFileProcess space < 400MB ")
      return
    end
    for index, filename in pairs(basePrefetchFilelist) do
      log(bWriteLog and "PufferUpdater.BasePrefetchFileProcess filename: " .. filename)
      if string.find(filename, version) then
        local filepath = TargetDir .. filename
        local DesFilePath = string.gsub(filepath, BasePrefecthKey, "pak", 1)
        log(bWriteLog and "chg filepath: " .. filepath)
        log(bWriteLog and "chg DesFilePath: " .. DesFilePath)
        Client.MoveFile(filepath, DesFilePath)
        Client.MountPakFile(DesFilePath, "")
        basePrefetchFilelist[index] = nil
        log(bWriteLog and "songGT Mount: " .. DesFilePath)
      end
    end
    for index, filename in pairs(baseDiffPrefetchFilelist) do
      log(bWriteLog and "PufferUpdater.BasePrefetchFileProcess filename: " .. filename)
      if string.find(filename, version) then
        local filepath = TargetDir .. filename
        local DesFilePath = string.gsub(filepath, BaseDiffPrefecthKey, "diffpak", 1)
        log(bWriteLog and "chg filepath: " .. filepath)
        log(bWriteLog and "chg DesFilePath: " .. DesFilePath)
        Client.MoveFile(filepath, DesFilePath)
        baseDiffPrefetchFilelist[index] = nil
      end
    end
  end
  for _, filename in pairs(basePrefetchFilelist) do
    log(bWriteLog and "PufferUpdater.BasePrefetchFileProcess filename: " .. filename)
    if string.find(filename, version) then
      local filepath = TargetDir .. filename
      Client.DeleteFile(filepath)
      log(bWriteLog and "PufferUpdater.BasePrefetchFileProcess delete filename: " .. filepath)
    end
  end
  for _, filename in pairs(baseDiffPrefetchFilelist) do
    log(bWriteLog and "PufferUpdater.BasePrefetchFileProcess filename: " .. filename)
    if string.find(filename, version) then
      local filepath = TargetDir .. filename
      Client.DeleteFile(filepath)
      log(bWriteLog and "PufferUpdater.BasePrefetchFileProcess delete filename: " .. filepath)
    end
  end
end
PufferUpdater.DOWNLOAD_STAGE_DIFFDOWNLOAD = 1
PufferUpdater.DOWNLOAD_STAGE_MERGE = 2
PufferUpdater.DOWNLOAD_STAGE_FULLDOWNLOAD = 3
PufferUpdater.DOWNLOAD_STAGE_STATUS_PENDING = 4
PufferUpdater.DOWNLOAD_STAGE_STATUS_SUCCESS = 5
PufferUpdater.DOWNLOAD_STAGE_STATUS_FAILED = 6
function PufferUpdater.DownloadBasePak()
  FuncUtil.AddCrashContextMainFlow("35")
  PufferUpdater.BasePrefetchFileProcess()
  PufferUpdater.needDownLoadFileList = PufferUpdater.GetNeedDownLoadFileList()
  local DownloadingPrefix = ""
  local msgConfig = LocUtil.GetLocalizeResStr(201027)
  if msgConfig then
    DownloadingPrefix = msgConfig
  end
  local param = {
    tostring(#PufferUpdater.needDownLoadFileList)
  }
  PufferUpdater.GEMReportSubEvent("PufferStartDownload", param)
  local TimeUtil = require("client.common.time_util")
  local startTime = TimeUtil.OSTime()
  local i = 0
  PufferUpdater.ResetDownloadProgress()
  local lastState = PufferUpdater.DOWNLOAD_STAGE_DIFFDOWNLOAD
  local lastStatus = PufferUpdater.DOWNLOAD_STAGE_STATUS_PENDING
  local skipProcess = false
  log(bWriteLog and "PufferUpdater.Process start remain file:" .. tostring(#PufferUpdater.needDownLoadFileList))
  local downloadBaseRes = #PufferUpdater.needDownLoadFileList > 0
  PufferUpdater.stageTipsPreFix = DownloadingPrefix
  PufferInterface.ParallelActSerialMode = true
  log(bWriteLog and "PufferUpdate Set ParallelActSerialMode")
  while #PufferUpdater.needDownLoadFileList ~= 0 do
    local processFunc = function(filename)
      log(bWriteLog and "Placeholder" .. tostring(filename))
    end
    log(bWriteLog and "######## Download Stage before. STAGE: " .. tostring(lastState) .. " " .. tostring(lastStatus))
    if lastState == PufferUpdater.DOWNLOAD_STAGE_DIFFDOWNLOAD then
      if lastStatus == PufferUpdater.DOWNLOAD_STAGE_STATUS_PENDING then
        PufferUpdater.stageTipsPreFix = DownloadingPrefix
        PufferUpdater.ResetFinished()
        processFunc = PufferUpdater.DifferDownloadBasePakWithOutMerge
        skipProcess = false
      elseif lastStatus == PufferUpdater.DOWNLOAD_STAGE_STATUS_SUCCESS then
        lastState = PufferUpdater.DOWNLOAD_STAGE_MERGE
        lastStatus = PufferUpdater.DOWNLOAD_STAGE_STATUS_PENDING
        skipProcess = true
      elseif lastStatus == PufferUpdater.DOWNLOAD_STAGE_STATUS_FAILED then
        PufferUpdater.ShowErrorTips(PufferUpdater.firstError)
        coroutine.yield()
        lastStatus = PufferUpdater.DOWNLOAD_STAGE_STATUS_PENDING
        skipProcess = true
      end
    elseif lastState == PufferUpdater.DOWNLOAD_STAGE_MERGE then
      if lastStatus == PufferUpdater.DOWNLOAD_STAGE_STATUS_PENDING then
        PufferUpdater.ResetFinished()
        PufferUpdater.stageTipsPreFix = DownloadingPrefix
        processFunc = PufferUpdater.MergeBasePak
        skipProcess = false
      elseif lastStatus == PufferUpdater.DOWNLOAD_STAGE_STATUS_SUCCESS then
        lastState = PufferUpdater.DOWNLOAD_STAGE_DIFFDOWNLOAD
        lastStatus = PufferUpdater.DOWNLOAD_STAGE_STATUS_PENDING
        skipProcess = true
      elseif lastStatus == PufferUpdater.DOWNLOAD_STAGE_STATUS_FAILED then
        PufferUpdater.ShowErrorTips(PufferUpdater.firstError)
        coroutine.yield()
        lastState = PufferUpdater.DOWNLOAD_STAGE_FULLDOWNLOAD
        lastStatus = PufferUpdater.DOWNLOAD_STAGE_STATUS_PENDING
        skipProcess = true
      end
    elseif lastState == PufferUpdater.DOWNLOAD_STAGE_FULLDOWNLOAD then
      if lastStatus == PufferUpdater.DOWNLOAD_STAGE_STATUS_PENDING then
        PufferUpdater.ResetFinished()
        processFunc = PufferUpdater.FullDownloadBasePak
        skipProcess = false
      elseif lastStatus == PufferUpdater.DOWNLOAD_STAGE_STATUS_SUCCESS then
        lastState = PufferUpdater.DOWNLOAD_STAGE_DIFFDOWNLOAD
        lastStatus = PufferUpdater.DOWNLOAD_STAGE_STATUS_PENDING
        skipProcess = true
      elseif lastStatus == PufferUpdater.DOWNLOAD_STAGE_STATUS_FAILED then
        PufferUpdater.ShowErrorTips(PufferUpdater.firstError)
        coroutine.yield()
        lastState = PufferUpdater.DOWNLOAD_STAGE_FULLDOWNLOAD
        lastStatus = PufferUpdater.DOWNLOAD_STAGE_STATUS_PENDING
        skipProcess = true
      end
    end
    if not skipProcess then
      log(bWriteLog and "######## Download Stage after. STAGE: " .. tostring(lastState) .. " " .. tostring(lastStatus))
      log(bWriteLog and "Total File: " .. tostring(#PufferUpdater.needDownLoadFileList))
      for k, v in ipairs(PufferUpdater.needDownLoadFileList) do
        log(bWriteLog and "######## PufferUpdater.needDownLoadFileList: " .. tostring(v))
        if not string.find(v, "_patch") then
          i = i + 1
          log(bWriteLog and "PufferUpdater.Process File:" .. v)
          processFunc(v)
        else
          log(bWriteLog and "PufferUpdater skip file " .. tostring(v))
        end
        if lastState == PufferUpdater.DOWNLOAD_STAGE_MERGE then
          coroutine.yield()
        end
      end
      log(bWriteLog and "Update download dispatched PufferUpdater.coroutine.yield remain file:" .. tostring(#PufferUpdater.needDownLoadFileList))
      if lastState == PufferUpdater.DOWNLOAD_STAGE_DIFFDOWNLOAD or lastState == PufferUpdater.DOWNLOAD_STAGE_FULLDOWNLOAD then
        local isEnbaleBGDownloadNotification = HDmpveRemote.HDmpveRemoteConfigGetBool("EnbaleBGDownloadNotification", false)
        if isEnbaleBGDownloadNotification == true then
          local time_ticker = require("common.time_ticker")
          time_ticker.AddTimerOnce(1, function()
            local size = PufferUpdater.GetGatheredProgress()
            local sizeNum = tonumber(size.download[1])
            if sizeNum ~= nil then
              GCPufferDownloader.StartBGDownloadNotification(Puffer, math.floor(sizeNum))
            end
          end)
        end
        coroutine.yield()
      end
      PufferUpdater.needDownLoadFileList = PufferUpdater.GetNeedDownLoadFileList()
      if PufferUpdater.firstError ~= 0 then
        lastStatus = PufferUpdater.DOWNLOAD_STAGE_STATUS_FAILED
      else
        lastStatus = PufferUpdater.DOWNLOAD_STAGE_STATUS_SUCCESS
      end
    else
      log(bWriteLog and "PufferUpdater skip process")
    end
  end
  param = {
    tostring(i),
    tostring(os.difftime(TimeUtil.OSTime(), startTime))
  }
  PufferUpdater.GEMReportSubEvent("PufferFinishAllDownload", param)
  log(bWriteLog and "Client.UpdateMemResource beg")
  Client.UpdateMemResource("Texture", "/Game/")
  log(bWriteLog and "Client.UpdateMemResource end")
  log(bWriteLog and "LEO Finish")
  local Logic_Mini_Pak_Gem = require("client.slua.logic.download.report.logic_mini_pak_gem")
  Logic_Mini_Pak_Gem.ReportGemLog("Base")
  local enbaleBGDownloadNotification = HDmpveRemote.HDmpveRemoteConfigGetBool("EnbaleBGDownloadNotification", false)
  if enbaleBGDownloadNotification == true then
    GCPufferDownloader.StopBGDownloadNotification(Puffer)
  end
  local HDmpveDownloadBaseRestartGame = HDmpveRemote.HDmpveRemoteConfigGetBool("HDmpveDownloadBaseRestartGame", true)
  if downloadBaseRes and HDmpveDownloadBaseRestartGame then
    local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
    login_module:OnRestartGame()
    local StatManager = import("StatManager")
    StatManager.GetInstance():ReportEventWithParam(124, {
      wifi = tostring(Client.HasActiveWifi())
    }, true)
    return
  end
  Client.FinishPufferUpdateInDolphin(GameFrontendHUD)
end
function PufferUpdater.PreCheckBaseUsability()
  local target_list = PufferInterface.ReturnSplitMiniPakFilelist()
  if target_list ~= nil then
    for k, v in ipairs(target_list) do
      local pakPath = Client.ProjectSavedDir() .. "Paks/" .. v
      if Client.IsFileExistsWithOutPakCheck(pakPath) then
        local isMountSuccess = Client.MountPakFile(pakPath, "")
        if not isMountSuccess then
          log(bWriteLog and tostring(v) .. " is existed, But Mount Failed! Redownloading...")
        end
      end
    end
  end
end
function PufferUpdater.GetNeedDownLoadFileList()
  local target_list = PufferInterface.ReturnSplitMiniPakFilelist()
  local needDownLoadFileList = {}
  if target_list ~= nil then
    for k, v in ipairs(target_list) do
      local pakPath = Client.ProjectSavedDir() .. "Paks/" .. v
      if not Client.IsFileExistsWithOutPakCheck(pakPath) and PufferUpdater.IsDeviceNeedPak(v) then
        log(bWriteLog and tostring(v) .. " add into download list")
        table.insert(needDownLoadFileList, v)
      else
        log(bWriteLog and tostring(v) .. " is existed, skip download")
      end
    end
  end
  return needDownLoadFileList
end
function PufferUpdater.ProgressCallback(nowSize, totalSize, curStage, filestate)
  local tips = ""
  local size = PufferUpdater.GetGatheredProgress()
  if curStage == PufferInterface.STAGE_FILE_DOWNLOADING then
    log(bWriteLog and "UpdateAndLoginFSM.UpdateProgressBar, progres Info = " .. tostring(nowSize))
    PufferUpdater.DownloadFileProgress[filestate.filename].download[1] = nowSize
    PufferUpdater.DownloadFileProgress[filestate.filename].download[2] = totalSize
    nowSize = size.download[1]
    totalSize = size.download[2]
    local readableNowSize = nowSize / 1024.0
    if readableNowSize <= 0 then
      readableNowSize = 0.1
    end
    local readableTotalSize = totalSize / 1024.0
    if readableTotalSize <= 0 then
      readableTotalSize = 0.1
    end
    local msgConfig = LocUtil.GetLocalizeResStr(201019)
    if msgConfig then
      local strCur = string.format("%.1f", readableNowSize)
      local strTotal = string.format("%.1f", readableTotalSize)
      local strText = LocUtil.LocalizeResFormat(16190, strCur, strTotal)
      tips = string.format("%s %s", msgConfig, strText)
    end
    local version_up_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.version_up_module)
    version_up_module:ShowTipsWhenWiFi4GSwitched()
  elseif curStage == PufferInterface.STAGE_FILE_MERGING then
    PufferUpdater.DownloadFileProgress[filestate.filename].merge[1] = 1.0 * nowSize / totalSize * 100
    nowSize = size.merge[1] + size.check[1]
    totalSize = size.merge[2] + size.check[2]
    tips = LocUtil.LocalizeResFormat(19603, LocUtil.GetLocalizeResStr(19110), string.format("%.1f%%", nowSize / totalSize * 100))
  elseif curStage == PufferInterface.STAGE_FILE_CHECKING then
    PufferUpdater.DownloadFileProgress[filestate.filename].check[1] = 1.0 * nowSize / totalSize * 100
    nowSize = size.merge[1] + size.check[1]
    totalSize = size.merge[2] + size.check[2]
    tips = LocUtil.LocalizeResFormat(19603, LocUtil.GetLocalizeResStr(19110), string.format("%.1f%%", nowSize / totalSize * 100))
  else
    tips = PufferUpdater.stageTipsPreFix .. ""
  end
  local version_up_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.version_up_module)
  version_up_module:UpdateStageText(tips, nowSize, totalSize, curStage)
  version_up_module:UpdateProgressBar(nowSize / totalSize * 100)
  version_up_module:ShowSystemNotifyEntry(102400 <= totalSize and curStage == PufferInterface.STAGE_FILE_DOWNLOADING)
  PufferUpdater.ReportUAEvent(nowSize / totalSize * 100)
end
function PufferUpdater.ProcBasePak()
  log(bWriteLog and "PufferUpdater.ProcBasePak")
  local logic_puffer_file = require("client.slua.logic.download.puffer.logic_puffer_common")
  logic_puffer_file.ReadPufferFileListJson()
  PufferUpdater.CheckCorrupted()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if PufferUpdater.SelPufferId or Client.GetDevicePlatformName() ~= DevicePlatformNameMacros.Android then
    PufferUpdater.downloadCoroutine = coroutine.create(PufferUpdater.DownloadBasePak)
    PufferUpdater.ResumeDownloadProc()
  else
    UIManager.ShowUI(UIManager.UI_Config.login_download_choice)
  end
  local USFSUpgradeDiffPreBaseProcess = HDmpveRemote.HDmpveRemoteConfigGetInt("USFSUpgradeDiffPreBaseProcess_390", 1)
  if USFSUpgradeDiffPreBaseProcess == 1 then
    logic_puffer_file.USFCacheInitProcessPreDownload()
  end
end
function PufferUpdater.CheckCorrupted()
  local   local   local   local   local   local   log(bWriteLog and "PufferUpdater:CheckCorrupted")
  if PufferUpdater.SelPufferId or PufferUpdater.bHaveChangePufferID then
    return
  end
  local PufferFileListJson = PufferInterface.GetPufferFileListJson()
  if not PufferFileListJson or not next(PufferFileListJson) then
    local logic_puffer_file = require("client.slua.logic.download.puffer.logic_puffer_common")
    PufferFileListJson = logic_puffer_file.ReadPufferFileListJson()
    if not PufferFileListJson or not next(PufferFileListJson) then
      return
    end
  end
  log(bWriteLog and "PufferUpdater:CheckCorrupted. Start")
  local PufferDeleteManager = require("client.slua.logic.download.delete.puffer_delete_manager")
  local ret = GCPufferDownloader.ReturnLocalFiles(PufferDownloader.DOWNLOAD_DIR_RELATIVE, "")
  local isDeleteFile = false
  Client.AddAttachFileString("PufferUpdater.CheckCorrupted", true, "start")
  local appVersion = Client.GetApplicationVersion()
  for _, fileName in pairs(ret) do
    local preFileName = string.match(fileName, "(.+_.+_).*")
    if preFileName and not string.find(preFileName, "patch") then
      local appPakName = preFileName .. appVersion .. ".pak"
      local pakName = PufferInterface.GetRealFilename(appPakName)
      log(bWriteLog and "PufferUpdater.CheckCorrupted pakName = " .. tostring(pakName))
      if pakName ~= fileName then
        local pakPreVersion, pakEndVersion = string.match(pakName, ".+_.+_(.+%..+%..+)%.(.+)%.pak")
        local filePreVersion, fileEndVersion = string.match(fileName, ".+_.+_(.+%..+%..+)%.(.+)%.pak")
        if pakPreVersion and pakEndVersion and filePreVersion and fileEndVersion and pakPreVersion == filePreVersion then
          PufferDeleteManager.DeletePak(fileName)
          isDeleteFile = true
          PufferUpdater.needRestartAfterDeleteCorruptFile = true
        end
      end
    end
  end
  log(bWriteLog and "PufferUpdater:CheckCorrupted. isDeleteFile = " .. tostring(isDeleteFile))
  Client.AddAttachFileString("PufferUpdater.CheckCorrupted", false, "end. " .. tostring(isDeleteFile))
end
function PufferUpdater.ResumeDownloadProc()
  if not PufferUpdater.downloadCoroutine then
    PufferUpdater.downloadCoroutine = coroutine.create(PufferUpdater.DownloadBasePak)
  end
  local res, msg = coroutine.resume(PufferUpdater.downloadCoroutine)
  if not res then
    local utility = require("common.utility")
    utility.ErrorMessageHandlerCo(PufferUpdater.downloadCoroutine, msg)
    PufferUpdater.downloadCoroutine = nil
  end
end
function PufferUpdater.GetGatheredProgress()
  local size = {
    download = {0, 0},
    merge = {0, 0},
    check = {0, 0}
  }
  for i, filename in pairs(PufferUpdater.needDownLoadFileList) do
    local progress = PufferUpdater.DownloadFileProgress[filename]
    if progress.download then
      size.download[1] = size.download[1] + progress.download[1]
      size.download[2] = size.download[2] + progress.download[2]
    end
    if progress.merge then
      size.merge[1] = size.merge[1] + progress.merge[1]
      size.merge[2] = size.merge[2] + progress.merge[2]
    end
    if progress.check then
      size.check[1] = size.check[1] + progress.check[1]
      size.check[2] = size.check[2] + progress.check[2]
    end
  end
  for key, value in pairs(size) do
    log(bWriteLog and "PufferUpdater.GetGatheredProgress " .. tostring(key) .. ":" .. tostring(value[1]) .. " " .. tostring(value[2]))
  end
  return size
end
function PufferUpdater.ResetDownloadProgress()
  local progress = {}
  for index, filename in ipairs(PufferUpdater.needDownLoadFileList) do
    local filesize = PufferInterface.GetFileSizeCompressed(filename) / 1024.0
    progress[filename] = {
      download = {0, filesize},
      merge = {0, 100},
      check = {0, 100},
      finished = false
    }
  end
  PufferUpdater.firstError = 0
  PufferUpdater.DownloadFileProgress = progress
end
function PufferUpdater.ResetFinished()
  for i, filename in pairs(PufferUpdater.needDownLoadFileList) do
    if PufferUpdater.DownloadFileProgress[filename] == nil then
      local filesize = PufferInterface.GetFileSizeCompressed(filename) / 1024.0
      PufferUpdater.DownloadFileProgress[filename] = {
        download = {0, filesize},
        merge = {0, 100},
        check = {0, 100},
        finished = false
      }
    end
    PufferUpdater.DownloadFileProgress[filename].finished = false
    log(bWriteLog and "PufferUpdater.ResetFinished Debug FIlename" .. tostring(filename))
  end
  PufferInterface.retryTimes = 0
end
function PufferUpdater.StopAll()
end
function PufferUpdater.DownloadFinished(state)
  local finished = true
  for i, filename in pairs(PufferUpdater.needDownLoadFileList) do
    finished = PufferUpdater.DownloadFileProgress[filename].finished
    if not finished then
      log(bWriteLog and "PufferUpdater.Download Finished " .. tostring(filename) .. " not finish")
      break
    end
  end
  log(bWriteLog and "PufferUpdater.DownloadFinished " .. tostring(finished))
  return finished
end
function PufferUpdater.SetDownloadProgressFinished(fileName, state, success)
  if success then
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    if Client.IsSplitMiniPakVersion() == true and string.find(tostring(fileName), "shader") and PublishRegionMacros.IsFITVersion() == false then
      local ShaderPrecompileProgress = Client.GetShaderPrecompileProgress()
      if ShaderPrecompileProgress == 0 or ShaderPrecompileProgress == 100 then
        log(bWriteLog and "PufferUpdater.SetDownloadProgressFinished, Call Client.OpenShaderCodeLibrary")
        Client.OpenShaderCodeLibrary("../../../ShadowTrackerExtra/Content/", "", true)
        Client.RestartShaderPrecompileBackend()
      end
    end
    if state == PufferUpdater.DOWNLOAD_STAGE_DIFFDOWNLOAD then
      PufferUpdater.DownloadFileProgress[fileName].download[1] = PufferUpdater.DownloadFileProgress[fileName].download[2]
      log_warning("PufferUpdater.set DiffDownload finish" .. tostring(fileName) .. " " .. tostring(state))
    elseif state == PufferUpdater.DOWNLOAD_STAGE_MERGE then
      PufferUpdater.DownloadFileProgress[fileName].merge[1] = PufferUpdater.DownloadFileProgress[fileName].merge[2]
      PufferUpdater.DownloadFileProgress[fileName].check[1] = PufferUpdater.DownloadFileProgress[fileName].check[2]
      log_warning("PufferUpdater.set Merge finish" .. tostring(fileName) .. " " .. tostring(state))
    else
      log_warning("PufferUpdater.set finish for abnormal state " .. tostring(fileName) .. " " .. tostring(state))
    end
  end
  PufferUpdater.DownloadFileProgress[fileName].finished = true
end
function PufferUpdater.MakeDowloadFinishCallback(success, state)
  local originalFunc = function(fileName, errorCode, errorStage)
    if success then
      local filePath = GCPufferDownloader.GetDownloadPath(Puffer) .. fileName
      if Client.IsFileExistsWithOutPakCheck(filePath) then
        local isMountSuccess = Client.MountPakFile(filePath, "")
        if not isMountSuccess then
          errorCode = 20
          errorStage = PufferInterface.STAGE_MOUNTING
          success = false
        end
      end
    end
    if not success and PufferUpdater.firstError == 0 then
      PufferUpdater.firstError = errorCode or -99
    end
    PufferUpdater.SetDownloadProgressFinished(fileName, state, success)
    if state == PufferUpdater.DOWNLOAD_STAGE_DIFFDOWNLOAD then
      log(bWriteLog and "PufferUpdater.Callback DiffDownload " .. tostring(state))
    elseif state == PufferUpdater.DOWNLOAD_STAGE_MERGE then
      log(bWriteLog and "PufferUpdater.Callback Merge " .. tostring(state))
      PufferUpdater.ResumeDownloadProc()
      return
    elseif state == PufferUpdater.DOWNLOAD_STAGE_FULLDOWNLOAD then
      log(bWriteLog and "PufferUpdater.Callback FULLDownlaod " .. tostring(state))
    else
      log_error("PufferUpdater.Callback abnormal state " .. tostring(state))
    end
    if PufferUpdater.DownloadFinished(state) then
      PufferUpdater.ResumeDownloadProc()
    end
  end
  return originalFunc
end
function PufferUpdater.DifferDownloadBasePakWithOutMerge(fileName)
  log(bWriteLog and "PufferUpdater.DifferDownloadBasePakWithOutMerge" .. tostring(fileName))
  local diffname, oldname = PufferInterface.GetDifferFileImp(fileName)
  log(bWriteLog and "PufferUpdater.Before diffname:" .. tostring(diffname) .. " oldname:" .. tostring(oldname))
  local succCallback = PufferUpdater.MakeDowloadFinishCallback(true, PufferUpdater.DOWNLOAD_STAGE_DIFFDOWNLOAD)
  local failedCallback = PufferUpdater.MakeDowloadFinishCallback(false, PufferUpdater.DOWNLOAD_STAGE_DIFFDOWNLOAD)
  if diffname ~= nil then
    local diffPakPath = Client.ProjectSavedDir() .. "Paks/" .. diffname
    if Client.IsFileExistsWithOutPakCheck(diffPakPath) then
      log(bWriteLog and "PufferUpdater.DifferDownloadBasePakWithOutMerge DiffExist Skip")
      local time_ticker = require("common.time_ticker")
      time_ticker.AddTimerOnce(0.1, function()
        succCallback(fileName)
      end)
      return
    end
    log(bWriteLog and "PufferUpdater.DifferDownloadBasePakWithOutMerge" .. fileName)
    PufferInterface.DifferDownloadWithoutMergeFile(fileName, succCallback, failedCallback, PufferUpdater.ProgressCallback)
  else
    local pakPath = Client.ProjectSavedDir() .. "Paks/" .. fileName
    if Client.IsFileExistsWithOutPakCheck(pakPath) then
      log(bWriteLog and "PufferUpdater.DifferDownloadBasePakWithOutMerge FileExist Skip")
      local time_ticker = require("common.time_ticker")
      time_ticker.AddTimerOnce(0.1, function()
        succCallback(fileName)
      end)
      return
    end
    log(bWriteLog and "PufferUpdater.DifferDownloadBasePakWithOutMerge" .. fileName)
    PufferInterface.NormalDownloadFile(fileName, succCallback, failedCallback, PufferUpdater.ProgressCallback)
  end
end
function PufferUpdater.FullDownloadBasePak(fileName)
  log(bWriteLog and "PufferUpdater.FullDownloadBasePak" .. tostring(fileName))
  local succCallback = PufferUpdater.MakeDowloadFinishCallback(true, PufferUpdater.DOWNLOAD_STAGE_FULLDOWNLOAD)
  local failedCallback = PufferUpdater.MakeDowloadFinishCallback(false, PufferUpdater.DOWNLOAD_STAGE_FULLDOWNLOAD)
  local pakPath = Client.ProjectSavedDir() .. "Paks/" .. fileName
  if Client.IsFileExistsWithOutPakCheck(pakPath) then
    local time_ticker = require("common.time_ticker")
    time_ticker.AddTimerOnce(0.1, function()
      succCallback(fileName)
    end)
    return
  end
  log(bWriteLog and "PufferUpdater.FullDownloadBasePak" .. fileName)
  PufferInterface.NormalDownloadFile(fileName, succCallback, failedCallback, PufferUpdater.ProgressCallback)
end
function PufferUpdater.MergeBasePak(fileName)
  log(bWriteLog and "PufferUpdater.MergeBasePak" .. tostring(fileName))
  local succCallback = PufferUpdater.MakeDowloadFinishCallback(true, PufferUpdater.DOWNLOAD_STAGE_MERGE)
  local failedCallback = PufferUpdater.MakeDowloadFinishCallback(false, PufferUpdater.DOWNLOAD_STAGE_MERGE)
  local pakPath = Client.ProjectSavedDir() .. "Paks/" .. tostring(fileName)
  if Client.IsFileExistsWithOutPakCheck(pakPath) then
    log(bWriteLog and "PufferUpdater.MergeBasePak FileExist Skip")
    local time_ticker = require("common.time_ticker")
    time_ticker.AddTimerOnce(0.1, function()
      succCallback(fileName)
    end)
    return
  end
  local diffname, oldname = PufferInterface.GetDifferFileImp(fileName)
  if diffname ~= nil and oldname ~= nil then
    local diffPakPath = Client.ProjectSavedDir() .. "Paks/" .. diffname
    local oldPakPath = Client.ProjectSavedDir() .. "Paks/" .. oldname
    local oldFileExist = Client.IsFileExistsWithOutPakCheck(oldPakPath)
    local diffFileExist = Client.IsFileExistsWithOutPakCheck(diffPakPath)
    if not oldFileExist or not diffFileExist then
      local time_ticker = require("common.time_ticker")
      time_ticker.AddTimerOnce(0.1, function()
        failedCallback(fileName, PufferInterface.ERR_DIFF_NOT_EXIST, PufferInterface.STAGE_FILE_MERGING)
      end)
      log_warning("PufferUpdater.MergeBasePak Difffile exist:" .. tostring(diffFileExist) .. "oldFile exist" .. tostring(oldFileExist))
      return
    end
  else
    PufferUpdater.firstError = PufferInterface.ERR_DIFF_NOT_EXIST
    local time_ticker = require("common.time_ticker")
    time_ticker.AddTimerOnce(0.1, function()
      failedCallback(fileName, PufferInterface.ERR_DIFF_NOT_EXIST, PufferInterface.STAGE_FILE_MERGING)
    end)
    log_warning("PufferUpdater.MergeBasePak Difffile not Contains")
    return
  end
  PufferInterface.MergeDownloadFile(fileName, succCallback, failedCallback, PufferUpdater.ProgressCallback)
end
function PufferUpdater.ClickRetryBtn()
  local time_ticker = require("common.time_ticker")
  if Client.GetPufferInitResult(GameFrontendHUD) then
    local logic_puffer_common = require("client.slua.logic.download.puffer.logic_puffer_common")
    local fileListPath = Client.ProjectSavedDir() .. PufferInterface.DOWNLOAD_DIR_RELATIVE .. logic_puffer_common.GetPufferFileListName()
    if not Client.IsFileExistsWithOutPakCheck(fileListPath) then
      time_ticker.AddTimerOnce(0.1, function()
        PufferUpdater.DownloadFileList(true, 0)
      end)
      return
    end
    time_ticker.AddTimerOnce(3, function()
      local RetryingPrefix = ""
      local msgConfig = LocUtil.GetLocalizeResStr(7425)
      if msgConfig then
        RetryingPrefix = msgConfig
      end
      PufferUpdater.stageTipsPreFix = RetryingPrefix
      PufferUpdater.ResetDownloadProgress()
      PufferUpdater.ResumeDownloadProc()
    end)
  else
    time_ticker.AddTimerOnce(0.1, function()
      table.insert(PufferInterface.InitCallbackFuncList, PufferUpdater.DownloadFileList)
      table.insert(PufferInterface.InitProgressCallbackFuncList, PufferUpdater.UpdateUIOnInitProgress)
      PufferInterface.ReInitializePuffer()
    end)
  end
end
function PufferUpdater.ShowErrorTips(errorCode)
  log(bWriteLog and "PufferUpdater ShowErrorTips" .. tostring(errorCode))
  if not errorCode or errorCode == 0 then
    return
  end
  if Client.HasDownloadedBasePak() then
    PufferUpdater.errorTimes = PufferUpdater.errorTimes + 1
  end
  local tips = ""
  if PufferUpdater.errorTimes > PufferUpdater.maxRetryTimes then
    log(bWriteLog and "Over Max Retry times" .. tostring(errorCode))
    Client.FinishPufferUpdateInDolphin(GameFrontendHUD)
  else
    local msgConfig = LocUtil.GetLocalizeResStr(201015)
    if msgConfig then
      tips = string.format(msgConfig, tostring(errorCode))
    end
    local hdmpveLogic = require("client.slua.logic.hdmpve.logic_hdmpve")
    local hdmpInstanceIdMapper = hdmpveLogic:FetchInstanceIdMapper()
    local getErrorExtraInfo = function(errorCode, hdmpInstanceIdMapper, withoutParentheses)
      local fmt = "(%s, %s)"
      if withoutParentheses == true then
        fmt = "%s, %s"
      end
      return string.format(fmt, tostring(errorCode), hdmpInstanceIdMapper)
    end
    local code = errorCode
    if code == 689045511 or code == 689045510 or code == 353501190 or code == 353435649 or code == 353501191 or code == 353502185 or code == 353501240 or code == 353501600 or code == 353501588 or code == 353501587 or code == 353501236 or code == 353501207 or code == 353502189 or code == 353501202 or code == 353502085 or code == 353501684 or code == 353501584 or code == 353501687 or code == 353501598 or code == 353501212 or code == 353501686 or code == 353501585 or code == 353501219 or code == 689045908 or code == 689045556 or code == 554827782 or code == 554827832 or code == 554827828 or code == 554828180 or code == 554762241 or code == 554828781 or code == 554827783 or code == 154140673 or code == 154140674 or code == 154140675 or 154140677 <= code and code <= 154140697 or code == 154140711 or code == 154140712 or code == 87031824 or code == 420610452 or code == 154140706 or code == 353501185 or code == 154140713 or code == 154140714 or code == 154140715 or code == 154140716 or code == 154140719 or code == 154140720 or code == 554827804 or code == 689045532 or code == 269615508 or code == 269615160 or code == 269615520 or code == 269549569 or code == 269615111 or code == 269615110 then
      local msgConfig = LocUtil.GetLocalizeResStr(201010)
      if msgConfig then
        tips = string.format(msgConfig, getErrorExtraInfo(errorCode, hdmpInstanceIdMapper, true))
      end
    elseif code == 355471270 or code == 355467269 or code == 355469265 or code == 691011599 or code == 556793868 or code == 556793861 or code == 691011598 then
      local msgConfig = LocUtil.GetLocalizeResStr(201011)
      if msgConfig then
        tips = string.format(msgConfig, getErrorExtraInfo(errorCode, hdmpInstanceIdMapper, true))
      end
    elseif code == 353697820 or code == 555745297 or code == 689963036 or code == 689242140 then
      local msgConfig = LocUtil.GetLocalizeResStr(201012)
      if msgConfig then
        tips = string.format(msgConfig, getErrorExtraInfo(errorCode, hdmpInstanceIdMapper, true))
      end
    elseif code == 688914441 or code == 556793859 or code == 288358404 or 422576129 <= code and code <= 422576148 or 420478976 <= code and code <= 421527551 or 489684993 <= code and code <= 489685003 or 487587840 <= code and code <= 488636415 or 87031809 <= code and code <= 87031821 or code == 87031823 or code == 691011591 or code == 691011585 then
      local msgConfig = LocUtil.GetLocalizeResStr(201012)
      if msgConfig then
        tips = string.format(msgConfig, getErrorExtraInfo(errorCode, hdmpInstanceIdMapper, true))
      end
    elseif code == 154140709 or code == 154140688 then
      local msgConfig = LocUtil.GetLocalizeResStr(201013)
      if msgConfig then
        tips = string.format(msgConfig, getErrorExtraInfo(errorCode, hdmpInstanceIdMapper, true))
      end
    elseif code == 353697796 or code == 353697914 or code == 353697822 or code == 353697794 or code == 353697797 or code == 353697805 or code == 556793857 or code == 555745310 or code == 556793874 or code == 289407004 or code == 289406980 or code == 289406993 or code == 289407098 or code == 289407085 or code == 288358406 or code == 289407006 or code == 289407071 or code == 691011585 then
      local msgConfig = LocUtil.GetLocalizeResStr(48105)
      if msgConfig then
        tips = msgConfig .. getErrorExtraInfo(errorCode, hdmpInstanceIdMapper)
      end
    elseif code == 555745308 or code == 555024412 or code == 203423772 or code == 269811740 or code == 271581189 then
      local msgConfig = LocUtil.GetLocalizeResStr(201032)
      if msgConfig then
        tips = string.format(msgConfig, getErrorExtraInfo(errorCode, hdmpInstanceIdMapper, true))
      end
      local version_up_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.version_up_module)
      version_up_module:ShowConfirmPanelWhenLowMemory(tips)
      return
    elseif code == 554828179 then
      local msgConfig = LocUtil.GetLocalizeResStr(5060)
      if msgConfig then
        tips = string.format(msgConfig, getErrorExtraInfo(errorCode, hdmpInstanceIdMapper, true))
      end
    else
      local msgConfig = LocUtil.GetLocalizeResStr(48107)
      if msgConfig then
        tips = msgConfig .. getErrorExtraInfo(errorCode, hdmpInstanceIdMapper)
      end
    end
    tips = tips or errorCode
    PufferUpdater.ShowRetryDownloadPanel(tips)
    local time_ticker = require("common.time_ticker")
    time_ticker.AddTimerOnce(0.1, function()
      GCPufferDownloader.StopAllTask(Puffer)
    end)
  end
end
function PufferUpdater.ShowRetryDownloadPanel(tips)
  log(bWriteLog and "PufferUpdater showretrydownloadpanel" .. tips)
  local title = ""
  local msgConfig = LocUtil.GetLocalizeResStr(201001)
  if msgConfig then
    title = msgConfig
  end
  local okLabel = ""
  local okConfig = LocUtil.GetLocalizeResStr(201002)
  if okConfig then
    okLabel = okConfig
  end
  local cancelLabel = ""
  local cancelConfig = LocUtil.GetLocalizeResStr(4539)
  if cancelConfig then
    cancelLabel = cancelConfig
  end
  local warning = ""
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, title, tips .. warning, PufferUpdater.ClickRetryBtn, function()
    local LogicCustomerService = require("client.slua.logic.CustomerService.LogicCustomerService")
    LogicCustomerService.Open(LogicCustomerService.E_EntranceType.Login)
    local time_ticker = require("common.time_ticker")
    time_ticker.AddTimerOnce(1, function()
      PufferUpdater.ShowRetryDownloadPanel(tips)
    end)
  end, okLabel, cancelLabel, extraData)
end
function PufferUpdater.GEMReportSubEvent(SubEventName, array)
  return Client.GEMReportSubEvent(GameFrontendHUD, "BasePakDownload", SubEventName, array)
end
function PufferUpdater.ReportUAEvent(progress)
  local UAEventID = require("client.slua.logic.adjust.UAEventID")
  local UABaseDownloadProgressEventID = {
    HQ = {
      [25] = {
        UAEventID.hd_res_1st_down_proc_25,
        UAEventID.hd_res_down_proc_25
      },
      [50] = {
        UAEventID.hd_res_1st_down_proc_50,
        UAEventID.hd_res_down_proc_50
      },
      [75] = {
        UAEventID.hd_res_1st_down_proc_75,
        UAEventID.hd_res_down_proc_75
      },
      [100] = {
        UAEventID.hd_res_1st_down_proc_100,
        UAEventID.hd_res_down_proc_100
      }
    },
    LQ = {
      [25] = {
        UAEventID.lite_res_1st_down_proc_25,
        UAEventID.lite_res_down_proc_25
      },
      [50] = {
        UAEventID.lite_res_1st_down_proc_50,
        UAEventID.lite_res_down_proc_50
      },
      [75] = {
        UAEventID.lite_res_1st_down_proc_75,
        UAEventID.lite_res_down_proc_75
      },
      [100] = {
        UAEventID.lite_res_1st_down_proc_100,
        UAEventID.lite_res_down_proc_100
      }
    }
  }
  local progressEvents = UABaseDownloadProgressEventID.HQ
  if not PufferUpdater.bDownloadHighQuality then
    progressEvents = UABaseDownloadProgressEventID.LQ
  end
  local progressInt = math.ceil(progress)
  local progressEvent = progressEvents[progressInt]
  if progressEvent ~= nil and PufferUpdater.ReportedProgress ~= progressInt then
    PufferUpdater.ReportedProgress = progressInt
    for _, v in ipairs(progressEvent) do
      log(bWriteLog and "PufferUpdater ReportUAEvent " .. v)
      local StatManager = import("StatManager")
      StatManager.GetInstance():ReportEventWithParam(v, {
        wifi = tostring(Client.HasActiveWifi())
      }, true)
    end
  end
end