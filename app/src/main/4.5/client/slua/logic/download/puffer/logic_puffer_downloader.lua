PufferDownloader = PufferDownloader or {
  InitErrorCode = false,
  InitSuccess = false,
  lastProductID = {},
  nProgressCD = 0.1,
  nProgressTime = 0,
  bWaitInitReturn = false,
  ReInitFailTime = 0,
  ReInitFailCD = 30,
  ReInitTimestamp = 0,
  ODPaksRequestNumber = 0,
  ODPaksRequestFailedNumber = 0,
  ODPaksRequestReportTimeThreshold = 40,
  ODPaksRequestReportTimeLast = 0,
  ODPaksRequestReportNumberThreshold = 100,
  ODPaksRequestReportErrorMaxTimes = 50,
  ODPaksRequestReportedError = {},
  FILE_LIST_ADDTIONAL_NAME = "PufferFileListAddtional.json",
  FILE_LIST_PREFETCH_NAME = "PufferFileListPrefetch.json",
  INPROGRESS_PAK_SUFFIX = "_inprog",
  DOWNLOAD_DIR_RELATIVE = "Paks/",
  DOWNLOAD_ODPAKS_RELATIVE = "ODPaks/",
  DOWNLOAD_UGCPAKS_RELATIVE = "ODPaks/",
  DOWNLOAD_PREFETCH_RELATIVE = ".prefetch",
  DOWNLOAD_CACHEPAKS_RELATIVE = "CachePaks/",
  ClearPufferInGame = false,
  BattleDownloadSwitch = false,
  HaveReportPufferWarningTimer = false,
  uploadDownloadSize = 0,
  uploadDeleteSize = 0,
  forceInitMapPaks = false,
  gemUploadBuildInfo = nil,
  gemUploadSodaInfo = nil,
  MergingDiffCount = 0,
  EnableBackpackCache = true,
  backpackCacheVal = 2,
  bStopPufferDownloader = false,
  diffList = nil,
  diffCheckTimer = nil,
  RecordExistPaks = nil,
  InitODPakManagerCalled = false,
  InitProgressSize = {},
  outputDownloadStack = false
}
local logic_puffer_common = require("client.slua.logic.download.puffer.logic_puffer_common")
local PufferConst = require("client.slua.logic.download.puffer_const")
local local local TimeUtil = require("client.common.time_util")
local StringUtil = require("common.string_util")
PufferDownloader.INVALID_FILE_ID = -1
PufferDownloader.INVALID_TASK_ID = -1
PufferDownloader.STAGE_INITIALIZING = 1
PufferDownloader.STAGE_FETCH_FILE_LIST = 2
PufferDownloader.STAGE_FILE_DOWNLOADING = 3
PufferDownloader.STAGE_FILE_MERGING = 4
PufferDownloader.STAGE_FILE_CHECKING = 5
PufferDownloader.STAGE_RETRY = 6
PufferDownloader.STAGE_FINISH = 7
PufferDownloader.STAGE_PRECHECK_OLDFILE = 8
PufferDownloader.ERR_INVALID_TASK_ID = 1
PufferDownloader.ERR_INVALID_TASK_ID_CALLBACK = 2
PufferDownloader.ERR_INVALID_STAGE_DOWNLOAD_RETURN = 3
PufferDownloader.ERR_INVALID_REQUEST_FILENAME = 4
PufferDownloader.ERR_RETRYING_RETRY_STAGE = 5
PufferDownloader.ERR_NOT_INITIALIZED = 6
PufferDownloader.ERR_PAK_WRAPPER_NOT_EXIST = 7
PufferDownloader.ERR_MOVE_FILE_FAILED = 8
PufferDownloader.ERR_CHECK_FILE_FAILED = 9
PufferDownloader.ERR_PAK_CORRUPTED = 10
PufferDownloader.maxOutterTaskID = 1
PufferDownloader.fileListPufferTaskID = 0
PufferDownloader.ODPaksBinPufferTaskID = 0
PufferDownloader.langDownloadTaskID = -1
PufferDownloader.MAX_RETRY_TIMES = 3
PufferDownloader.MERGE_DUMMY_WAIT_TIME = 60
PufferDownloader.filestateList = {}
PufferDownloader.outterTaskIDFilenameMapping = {}
PufferDownloader.ODPaksDownloadStatesInFighting = {}
PufferDownloader.mergeFailedTimes = {}
PufferDownloader.PufferJsonDownloadReturn = false
PufferDownloader.UpdateGrayStep = 0
PufferDownloader.hasDesertReportedError = false
PufferDownloader.hasSavageReportedError = false
PufferDownloader.hasDihoroReportedError = false
PufferDownloader.hasReportedError = {
  map_desert_ = false,
  map_savagemain_ = false,
  map_dihorotok_ = false,
  res_comml_ = false
}
PufferDownloader.DownloadRewardCfg = {}
PufferDownloader.DownloadKeyRecord = {}
PufferDownloader.RecommendReddot = false
PufferDownloader.DisableInBattle = true
PufferDownloader.DisableInBattleThreshold = 1
PufferDownloader.PufferStageFunction = {
  [PufferDownloader.STAGE_INITIALIZING] = function(filestate)
    PufferDownloader.RequestFile(GameFrontendHUD, filestate.filename, filestate.forceUpdate)
  end,
  [PufferDownloader.STAGE_FETCH_FILE_LIST] = function(filestate)
    PufferDownloader.FetchFileList(filestate)
  end,
  [PufferDownloader.STAGE_FILE_DOWNLOADING] = function(filestate)
    PufferDownloader.DownloadFileImp(filestate)
  end,
  [PufferDownloader.STAGE_FILE_MERGING] = function(filestate)
    PufferDownloader.MergeFile(filestate)
  end,
  [PufferDownloader.STAGE_FILE_CHECKING] = function(filestate)
    PufferDownloader.CheckFile(filestate)
  end,
  [PufferDownloader.STAGE_RETRY] = function(filestate)
    log_error("PufferDownloader OnDownloadProgress Retry should not retry self")
    filestate.lastErrno = PufferDownloader.ERR_RETRYING_RETRY_STAGE * 100 + filestate.lastErrno
    PufferDownloader.FinishRequestFile(filestate)
    return false
  end,
  [PufferDownloader.STAGE_FINISH] = function(filestate)
    PufferDownloader.FinishRequestFile(filestate)
  end
}
PufferDownloader.StageTimeProportion = {
  {0.0, 0.0},
  {0.05, 0.0},
  {0.7, 0.05},
  {0.15, 0.75},
  {0.1, 0.9},
  {0.0, 0.0},
  {0.0, 1.0},
  {0.05, 0.95}
}
PufferDownloader.StandardSpeed = 0
function PufferDownloader.OnGameStateChange(eventType, eventID, vars)
  log(bWriteLog and "PufferDownloader.OnGameStateChange " .. tostring(vars.current) .. "  " .. tostring(vars.pre))
  if IsWoWEditor and vars.pre == GameStatus.Login then
    PufferDownloader.ReInitializePuffer(false)
  end
  if vars.current == GameStatus.Login then
    PufferDownloader.lastProductID = {}
  elseif vars.current ~= GameStatus.InSupportDownloadState() and PufferDownloader.mergeTimer then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(PufferDownloader.mergeTimer)
    PufferDownloader.mergeTimer = nil
  end
end
function PufferDownloader.LoadDownloadKeyRecord()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local record = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eDownloadKeyRecord) or {}
  PufferDownloader.DownloadKeyRecord = record
  log_tree("record = ", record)
end
function PufferDownloader.SaveDownloadKeyRecord()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(PufferDownloader.DownloadKeyRecord, PlayerPrefsSystem.ePlayerPrefsType.eDownloadKeyRecord)
end
function PufferDownloader.LoadDownloadSizeInfo()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local sizeInfo = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eDownloadSizeInfo) or {}
  PufferDownloader.uploadDownloadSize = sizeInfo.uploadDownloadSize or 0
  PufferDownloader.uploadDeleteSize = sizeInfo.uploadDeleteSize or 0
  log(bWriteLog and string.format("PufferDownloader.LoadDownloadSizeInfo uploadDownloadSize: %s, uploadDeleteSize = %s", tostring(PufferDownloader.uploadDownloadSize), tostring(PufferDownloader.uploadDeleteSize)))
end
function PufferDownloader.SaveDownloadSizeInfo()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local sizeInfo = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eDownloadSizeInfo) or {}
  sizeInfo.uploadDownloadSize = PufferDownloader.uploadDownloadSize
  sizeInfo.uploadDeleteSize = PufferDownloader.uploadDeleteSize
  PlayerPrefsSystem.SaveTableToFile_N(sizeInfo, PlayerPrefsSystem.ePlayerPrefsType.eDownloadSizeInfo)
  log(bWriteLog and string.format("PufferDownloader.SaveDownloadSizeInfo uploadDownloadSize: %s, uploadDeleteSize = %s", tostring(PufferDownloader.uploadDownloadSize), tostring(PufferDownloader.uploadDeleteSize)))
end
function PufferDownloader.AddDownloadSize(mbSize)
  PufferDownloader.uploadDownloadSize = PufferDownloader.uploadDownloadSize + mbSize
  PufferDownloader.SaveDownloadSizeInfo()
end
function PufferDownloader.AddDeleteSize(mbSize)
  PufferDownloader.uploadDeleteSize = PufferDownloader.uploadDeleteSize + mbSize
  PufferDownloader.SaveDownloadSizeInfo()
end
function PufferDownloader.FileState(filename, forceUpdate, curStage, pufferTaskID)
  log(bWriteLog and string.format("PufferDownloader.FileState filename:%s, maxOutterTaskID:%s", filename, pufferTaskID))
  local val = {
    outterTaskID = PufferDownloader.maxOutterTaskID,
    filename = filename,
    forceUpdate = forceUpdate or false,
    curStage = curStage or PufferDownloader.STAGE_INITIALIZING,
    pufferTaskID = pufferTaskID or PufferDownloader.INVALID_TASK_ID,
    retryTimes = 0,
    retryStage = 0,
    lastErrno = 0,
    diffFilename = nil,
    oldFilename = nil,
    mergePassedProg = 0,
    mergeTotalProg = 1,
    suspended = false,
    slient = false,
    preCheckPassed = nil
  }
  local metaTable = {
    __tostring = function(t)
      local str = "{ outterTaskID = %d, filename = %s, forceUpdate = %s, curStage = %d, pufferTaskID = %d, retryTimes = %d, retryStage = %d, lastErrno=%d, diffFilename=%s, oldFilename=%s, mergePassedProg=%f, mergeTotalProg=%f, suspended=%s, slient=%s, preCheckPassed=%s}"
      return string.format(str, t.outterTaskID, t.filename, t.forceUpdate, t.curStage, t.pufferTaskID, t.retryTimes, t.retryStage, t.lastErrno, t.diffFilename, t.oldFilename, t.mergePassedProg, t.mergeTotalProg, t.suspended, t.slient, t.preCheckPassed)
    end
  }
  PufferDownloader.maxOutterTaskID = PufferDownloader.maxOutterTaskID + 1
  return setmetatable(val, metaTable)
end
function PufferDownloader.ReInitializePuffer(force)
  if PufferDownloader.bWaitInitReturn then
    log(bWriteLog and "PufferDownloader.PufferReinitialize waitting for init ")
    if not _G.IsEditor then
      if not PufferDownloader.WaitTimeStamp then
        PufferDownloader.WaitTimeStamp = TimeUtil.GetServerTimeInSec()
      elseif TimeUtil.GetServerTimeInSec() - PufferDownloader.WaitTimeStamp > 60 then
        PufferDownloader.WaitTimeStamp = TimeUtil.GetServerTimeInSec()
        ShowNotice(32543)
      end
    end
    return
  end
  log(bWriteLog and "PufferDownloader.ReInitializePuffer force: " .. tostring(force))
  local InitRes = PufferDownloader.InitSuccess
  local InitErr = PufferDownloader.InitErrorCode
  if InitRes == false and InitErr == 0 and not force then
    log(bWriteLog and "PufferDownloader.PufferReinitialize Last initialization is still pending")
    return
  end
  if not InitRes and PufferDownloader.ReInitFailTime >= 3 then
    if TimeUtil.GetServerTimeInSec() - PufferDownloader.ReInitTimestamp < PufferDownloader.ReInitFailCD then
      log(bWriteLog and "PufferDownloader.PufferReinitialize ReInitFailTime = " .. tostring(PufferDownloader.ReInitFailTime))
      return
    end
    PufferDownloader.ReInitFailTime = 0
  end
  if force then
    local filePath = Client.ProjectSavedDir() .. PufferDownloader.DOWNLOAD_DIR_RELATIVE .. logic_puffer_common.GetPufferFileListName()
    GCPufferDownloader.DeleteFile(filePath)
  end
  PufferDownloader.bWaitInitReturn = true
  PufferDownloader.ReInitTimestamp = TimeUtil.GetServerTimeInSec()
  local PufferConfigSys = require("client.slua.logic.download.puffer.puffer_config")
  local PufferConfig = PufferConfigSys:GetDefaultConfig()
  Client.ReInitializePuffer(GameFrontendHUD, false, PufferConfig.MaxDownloadsPerTask, PufferConfig.MaxDownTask, PufferConfig.MaxDownloadSpeed, true, false, 1, PufferConfig.PufferDownloadFuncDict, PufferConfig.HttpDnsType, PufferConfig.DownloadStageType, PufferConfig.DownloadEngineType)
end
function PufferDownloader.IsAllPufferFileListJsonTaskReturn()
  if not PufferDownloader.IsPufferFileListJsonExist() then
    log(bWriteLog and string.format("PufferDownloader.IsAllPufferFileListJsonTaskReturn false"))
    return false
  end
  if Client.IsReleaseVersion(NetInterface) then
    log(bWriteLog and string.format("PufferDownloader.IsAllPufferFileListJsonTaskReturn true"))
    return true
  end
  if PufferDownloader.extraPufferListJsonTaskIDs then
    for i, v in pairs(PufferDownloader.extraPufferListJsonTaskIDs) do
      if not v then
        log_format("PufferDownloader.IsAllPufferFileListJsonTaskReturn false. taskID=%s", i)
        return false
      end
    end
  end
  log(bWriteLog and string.format("PufferDownloader.IsAllPufferFileListJsonTaskReturn true"))
  return true
end
function PufferDownloader.IsPufferFileListJsonExist()
  return Client.IsFileExistsWithOutPakCheck(Client.ProjectSavedDir() .. PufferDownloader.DOWNLOAD_DIR_RELATIVE .. logic_puffer_common.GetPufferFileListName())
end
function PufferDownloader.IsExtraJsonTaskID(taskID)
  if not PufferDownloader.extraPufferListJsonTaskIDs or not next(PufferDownloader.extraPufferListJsonTaskIDs) then
    return false
  end
  for i, v in pairs(PufferDownloader.extraPufferListJsonTaskIDs) do
    if i == taskID then
      return true
    end
  end
  return false
end
function PufferDownloader.RequestExtraPufferListJson()
  if not Client.IsDevelopment() then
    return
  end
  local PufferListJson = PufferDownloader.ReadPufferFileListJson()
  if not PufferListJson or not PufferListJson.tasknum then
    return
  end
  local num = tonumber(PufferListJson.tasknum)
  PufferDownloader.extraPufferListJsonTaskIDs = {}
  PufferDownloader.SetImmDLTaskConfig()
  local PufferUA = PufferDownloader.GetPufferUA(0)
  for i = 1, num do
    local fileName = string.format("PufferFileList_%s.json", i)
    local taskID = GCPufferDownloader.RequestFile(Puffer, fileName, true, PufferUA)
    if taskID ~= -1 then
      log_format("PufferDownloader.RequestExtraPufferListJson. taskID=%s", taskID)
      PufferDownloader.extraPufferListJsonTaskIDs[taskID] = false
    end
  end
end
function PufferDownloader.ReportPufferWarning()
  if PufferDownloader.HaveReportPufferWarningTimer then
    return
  end
  PufferDownloader.HaveReportPufferWarningTimer = true
  local time_ticker = require("common.time_ticker")
  time_ticker.AddTimerOnce(0, function()
    local TimeUtil = require("client.common.time_util")
    if not PufferDownloader.StartDownloadJsonTime then
      Client.AddCrashContextData(1002, "NotStartDownloadJson", false, 1200)
    end
    if PufferDownloader.StartDownloadJsonTime and not PufferDownloader.FinishDownloadJsonTime then
      log(bWriteLog and "PufferFileList.json NotFinish:" .. tostring(TimeUtil.GetServerTimeInSec()))
      local cost = TimeUtil.GetServerTimeInSec() - PufferDownloader.StartDownloadJsonTime
      if cost < 10 then
        Client.AddCrashContextData(1002, "NotFinishDownloadCost_0~10s", false, 1200)
      elseif cost < 20 then
        Client.AddCrashContextData(1002, "NotFinishDownloadCost_10~20s", false, 1200)
      else
        Client.AddCrashContextData(1002, "NotFinishDownloadCost_20s+", false, 1200)
      end
      log(bWriteLog and "PufferFileList.json Cost:" .. tostring(cost))
    end
    PufferDownloader.HaveReportPufferWarningTimer = false
    local PakLocalInfoRemote = HDmpveRemote.HDmpveRemoteConfigGetBool("PakLocalInfoRemote", false)
    if PakLocalInfoRemote then
      log(bWriteLog and "PufferFileList.json pin....")
      local a = PufferDownloader.PufferWarning() + 1
    else
      log(bWriteLog and "PufferFileList.json skip for PakLocalInfoRemote: " .. tostring(PakLocalInfoRemote))
    end
  end)
end
function PufferDownloader.ODPaksBinLoaded()
  log(bWriteLog and "PufferDownloader.ODPaksBinLoaded.")
end
function PufferDownloader.CheckAndInit(skipReload)
  if not PufferDownloader.IsAllPufferFileListJsonTaskReturn() then
    return
  end
  Client.AddCrashContextData(1002, "CheckAndInit", false, 1200)
  log(bWriteLog and string.format("PufferDownloader.CheckAndInit"))
  local needPostProcess = false
  local PufferListJson = PufferDownloader.GetPufferFileListJson()
  if not PufferListJson or next(PufferListJson) == nil then
    needPostProcess = true
  end
  local oldVersion = PufferListJson and PufferListJson.version
  local oldBuildTime = PufferListJson and PufferListJson.BuildTime
  local oldResVer = PufferListJson and PufferListJson.res_ver
  if not skipReload or needPostProcess then
    PufferListJson = PufferDownloader.ReadPufferFileListJson(true)
  end
  if PufferListJson and next(PufferListJson) then
    log_format("PufferDownloader.CheckAndInit. version = %s -> %s, BuildTime = %s ->%s\239\188\140res_ver = %s -> %s", oldVersion, PufferListJson.version, oldBuildTime, PufferListJson.BuildTime, oldResVer, PufferListJson.res_ver)
    if oldVersion ~= PufferListJson.version or oldBuildTime ~= PufferListJson.BuildTime or oldResVer ~= PufferListJson.res_ver then
      needPostProcess = true
    end
    if not PufferDownloader.HaveCheckAndInit then
      needPostProcess = true
    end
    log_format("PufferDownloader.CheckAndInit needPostProcess:%s", needPostProcess)
    if needPostProcess then
      PufferDownloader.PufferJsonDownloadReturn = false
      log_format("PufferDownloader.CheckAndInit. PufferJsonPostProcess")
      PufferDownloader.PufferJsonPostProcess()
    end
    log_format("PufferDownloader.CheckAndInit. HaveCheckAndInit = true")
    PufferDownloader.HaveCheckAndInit = true
  end
  log_format("PufferDownloader.CheckAndInit. end")
end
function PufferDownloader.CheckCorrupted()
  log(bWriteLog and "PufferDownloader:CheckCorrupted")
  if PufferUpdater.SelPufferId or PufferUpdater.bHaveChangePufferID then
    return
  end
  local PufferFileListJson = PufferDownloader.GetPufferFileListJson()
  if not PufferFileListJson or not next(PufferFileListJson) then
    return
  end
  local PufferDeleteManager = require("client.slua.logic.download.delete.puffer_delete_manager")
  local ret = GCPufferDownloader.ReturnLocalFiles(PufferDownloader.DOWNLOAD_DIR_RELATIVE, "")
  local delList = {}
  for _, fileName in pairs(ret) do
    local preFileName = string.match(fileName, "(.+_.+_).*")
    if preFileName and not string.find(preFileName, "patch") then
      local appPakName = preFileName .. Client.GetApplicationVersion() .. ".pak"
      local pakName = PufferDownloader.GetRealFilename(appPakName)
      log(bWriteLog and "PufferDownloader.CheckCorrupted pakName = " .. tostring(pakName))
      if pakName ~= fileName then
        local pakPreVersion, pakEndVersion = string.match(pakName, ".+_.+_(.+%..+%..+)%.(.+)%.pak")
        local filePreVersion, fileEndVersion = string.match(fileName, ".+_.+_(.+%..+%..+)%.(.+)%.pak")
        if pakPreVersion and pakEndVersion and filePreVersion and fileEndVersion and pakPreVersion == filePreVersion then
          table.insert(delList, fileName)
        end
      end
    end
  end
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  local title = LocUtil.GetLocalizeResStr(101001)
  local stTips = "\229\134\133\231\189\145\230\143\144\231\164\186\239\188\154\230\163\128\230\159\165\229\136\176\232\181\132\230\186\144\229\188\130\229\184\184\239\188\140\230\152\175\229\144\166\229\136\160\233\153\164\229\185\182\233\135\141\229\144\175\239\188\159\239\188\136\233\128\130\233\133\141\230\181\139\232\175\149\229\143\175\233\128\137\232\183\179\232\191\135\239\188\137"
  local stDel = LocUtil.GetLocalizeResStr(102020)
  local stSkip = LocUtil.GetLocalizeResStr(19520)
  local delCallback = function()
    for i, v in pairs(delList) do
      PufferDeleteManager.DeletePak(v)
    end
    local msg = LocUtil.GetLocalizeResStr(25147)
    local cb = function()
      Client.RestartGame()
    end
    CommonMsgBoxMgr.Show(1, title, msg, cb)
  end
  if next(delList) then
    if Client.IsReleaseVersion(NetInterface) then
      delCallback()
    else
      CommonMsgBoxMgr.Show(2, title, stTips, delCallback, nil, stDel, stSkip)
    end
  end
end
function PufferDownloader.ShowPufferInitProgressNotice()
  local pct = 0
  if PufferDownloader.InitSuccess then
    return
  end
  local totalCurSize = 0
  local totalTotalSize = 0
  for _, data in pairs(PufferDownloader.InitProgressSize) do
    totalCurSize = totalCurSize + data.nowSize
    totalTotalSize = totalTotalSize + data.totalSize
  end
  log_format("PufferDownloader.ShowPufferInitProgressNotice. totalCurSize=%s, totalTotalSize=%s", totalCurSize, totalTotalSize)
  if 0 < totalTotalSize then
    pct = totalCurSize * 100 // totalTotalSize
    ShowNotice(LocUtil.LocalizeResFormat(468890071, pct))
  else
    ShowNotice(46880156)
  end
end
function PufferDownloader.OnInitProgress(stage, nowSize, totalSize, PufferInstID)
  log_format("PufferDownloader.OnInitProgress. stage=%s, nowSize=%s, totalSize=%s, PufferInstID=%s", stage, nowSize, totalSize, PufferInstID)
  local data = PufferDownloader.InitProgressSize[PufferInstID] or {}
  data.  data.  PufferDownloader.InitProgressSize[PufferInstID] = data
end
function PufferDownloader.OnInitReturn(isSuccess, errorCode)
  log_shipping_client(bWriteLog and "PufferDownloader.OnInitReturn isSuccess: " .. tostring(isSuccess) .. " errorCode: " .. tostring(errorCode))
  PufferDownloader.InitProgressSize = {}
  PufferDownloader.InitErrorCode = errorCode
  PufferDownloader.InitSuccess = isSuccess
  PufferDownloader.bWaitInitReturn = false
  PufferDownloader.RefreshDownloadInBattleSwitch()
  PufferDownloader.LoadDownloadSizeInfo()
  PufferDownloader.LoadDownloadKeyRecord()
  PufferDownloader.HaveCheckAndInit = false
  PufferDownloader.StartDownloadJsonTime = TimeUtil.GetServerTimeInSec()
  log(bWriteLog and "PufferFileList.json StartDownloadJsonTime:" .. tostring(PufferDownloader.StartDownloadJsonTime))
  Client.AddCrashContextData(1002, "StartDownloadJson_" .. PufferDownloader.StartDownloadJsonTime, false, 1200)
  PufferDownloader.SetImmDLTaskConfig()
  local PufferUA = PufferDownloader.GetPufferUA(0)
  PufferDownloader.fileListPufferTaskID = GCPufferDownloader.RequestFile(Puffer, logic_puffer_common.GetPufferFileListName(), true, PufferUA)
  PufferDownloader.fileListAddtionalPufferTaskID = GCPufferDownloader.RequestFile(Puffer, PufferDownloader.FILE_LIST_ADDTIONAL_NAME, true, PufferUA)
  PufferDownloader.fileListPrefetchPufferTaskID = GCPufferDownloader.RequestFile(Puffer, PufferDownloader.FILE_LIST_PREFETCH_NAME, true, PufferUA)
  local curProductID = GCPufferDownloader.GetProductID(Puffer)
  for _, v in pairs(curProductID) do
    log(bWriteLog and "PufferDownloader.OnInitReturn curProductID = " .. tostring(v))
  end
  local TableUtil = require("common.table_util")
  if next(PufferDownloader.lastProductID) and not TableUtil.IsSameTable(PufferDownloader.lastProductID, curProductID) then
    PufferDownloader.lastProductID = {}
  end
  Client.AddAttachFileString("PufferResState", true, tostring(isSuccess))
  PufferDownloader.AddDownloadTimeOutTimer()
  if not isSuccess then
    ShowNotice(32543)
    PufferDownloader.ReInitFailTime = PufferDownloader.ReInitFailTime + 1
    log_shipping_client("PufferDownloader.OnInitReturn ReInitFailTime = " .. tostring(PufferDownloader.ReInitFailTime))
    local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
    PufferTlog.SendTLog(PufferTlog.Enum_TLog_From.InitFail, PufferTlog.Enum_TLog_Optype.Finish)
    local time_ticker = require("common.time_ticker")
    if not PufferDownloader.bHaveRetriedInit then
      time_ticker.AddTimerOnce(3, function()
        PufferDownloader.ReInitializePuffer(false)
      end)
      PufferDownloader.bHaveRetriedInit = true
    end
    Client.AddCrashContextData(1001, "PufferInitError_" .. tostring(errorCode), false, 1200)
    PufferDownloader.ReportPufferWarning()
    PufferDownloader.UploadGemReport(errorCode, "PufferInitError", string.format("ReInitFailTime %s", tostring(PufferDownloader.ReInitFailTime)), FuncUtil.GetHDmpveInstanceId())
  else
    PufferDownloader.ReInitFailTime = 0
    Client.AddCrashContextData(1001, "PufferInitSuccess" .. tostring(errorCode), false, 1200)
    PufferDownloader.CheckAndInit(true)
    PufferDownloader.UploadGemReport(errorCode, "PufferInitSuccess", string.format("ReInitFailTime %s", tostring(PufferDownloader.ReInitFailTime)), FuncUtil.GetHDmpveInstanceId())
    local GCPufferDownloader = slua_GameFrontendHUD:GetPufferDownloader()
    local PufferDefine = require("client.slua.logic.download.puffer.puffer_define")
    local PufferConfigSys = require("client.slua.logic.download.puffer.puffer_config")
    GCPufferDownloader:DynamicAdjustPufferSystemParameter(PufferDefine.PufferSystemParameterKey.PufferHttpCurlRecvBufferSize, PufferConfigSys.GetCurlBuffSize())
    EventSystem:postEvent(EVENTTYPE_PUFFER, EVENTID_DOWNLOAD_DATA_INIT_SUC)
  end
  local PufferInitTracker = require("client.slua.logic.download.puffer.puffer_init_tracker")
  PufferInitTracker:OnInitPufferResult(errorCode)
end
function PufferDownloader.OnDownloadReturn(taskId, isSuccess, errorCode)
  local PufferSwitch = require("client.slua.logic.download.puffer_switch")
  if PufferSwitch.BanDownload then
    log(bWriteLog and "PufferDownloader.OnDownloadReturn. BanDownload return")
    return
  end
  local PufferQuic = require("client.slua.logic.download.puffer.puffer_quic")
  PufferQuic:OnDownloadReturn(taskId, isSuccess, errorCode)
  local processedFilestateList = {}
  if taskId == PufferDownloader.fileListPufferTaskID then
    log(bWriteLog and "PufferDownloader.OnDownloadReturn PufferFileList.json download done ")
    for outterTaskID, filestate in pairs(PufferDownloader.filestateList) do
      if filestate.curStage == PufferDownloader.STAGE_FETCH_FILE_LIST then
        processedFilestateList[outterTaskID] = filestate
      end
    end
    PufferDownloader.FinishDownloadJsonTime = TimeUtil.GetServerTimeInSec()
    log(bWriteLog and "PufferFileList.json FinishDownloadJsonTime:" .. tostring(PufferDownloader.FinishDownloadJsonTime))
    local cost = PufferDownloader.FinishDownloadJsonTime - PufferDownloader.StartDownloadJsonTime
    Client.AddCrashContextData(1002, "FinishDownloadCost_" .. cost, false, 1200)
    PufferDownloader.fileListPufferTaskID = 0
    PufferDownloader.RemoveDownloadTimeOutTimer()
    PufferDownloader.RequestExtraPufferListJson()
    PufferDownloader.CheckAndInit()
    PufferDownloader.CheckCorrupted()
    local ListJson = logic_puffer_common.PufferFileListJson
    local JsonVersion = "err"
    local JsonBuildTime = "err"
    if ListJson then
      JsonVersion = ListJson.version or "0.0.0.0"
      JsonBuildTime = ListJson.BuildTime or "0-0-0 0:0:0"
    end
    PufferDownloader.UploadGemReport(errorCode, "PufferFileList.json", string.format("ver %s, buildTime %s, cost %s", tostring(JsonVersion), string.gsub(tostring(JsonBuildTime), ":", "_"), tostring(cost)))
  elseif taskId == PufferDownloader.ODPaksBinPufferTaskID then
    processedFilestateList = {}
    PufferDownloader.ODPaksPostProcess()
  elseif taskId == PufferDownloader.langDownloadTaskID then
    log_format("PufferDownloader.OnDownloadReturn. lang download done")
    local version_update_ui = UIManager.GetUI(UIManager.UI_Config.version_update)
    local LanguageDownload = require("client.slua.logic.download.recommend.logic_language_download")
    LanguageDownload.SetCurrentLanguageAndLocale(LanguageDownload.GetSystemDefaultLanguage())
    if version_update_ui then
      version_update_ui:GoToNextStepLogin()
    end
  elseif PufferDownloader.IsExtraJsonTaskID(taskId) then
    log(bWriteLog and "PufferDownloader.OnDownloadReturn extra json download done taskId = " .. tostring(taskId))
    processedFilestateList = {}
    PufferDownloader.extraPufferListJsonTaskIDs[taskId] = true
    PufferDownloader.CheckAndInit()
  elseif taskId == PufferDownloader.fileListAddtionalPufferTaskID or taskId == PufferDownloader.fileListPrefetchPufferTaskID then
    processedFilestateList = {}
  else
    local filestate = PufferDownloader.GetfilestateByPufferTaskID(taskId)
    if filestate == nil then
      log_error("PufferDownloader.OnDownloadReturn pufferTaskID is not mapping to filestate " .. tostring(taskId))
      return
    end
    local isODPaks = string.find(filestate.filename, PufferDownloader.DOWNLOAD_ODPAKS_RELATIVE) ~= nil
    if isODPaks and PufferDownloader.isFightingMode() then
      if isSuccess == false then
        log_error("PufferDownloader.OnDownloadReturn Error:" .. tostring(errorCode))
        filestate.lastErrno = errorCode
        PufferDownloader.RetryCurStage(filestate)
      else
        PufferDownloader.FinishRequestFile(filestate)
      end
      return
    end
    local isUGCPaks = string.find(filestate.filename, PufferDownloader.DOWNLOAD_UGCPAKS_RELATIVE) ~= nil
    if not isUGCPaks or PufferDownloader.isFightingMode() then
    end
    processedFilestateList[filestate.outterTaskID] = filestate
  end
  log(bWriteLog and "PufferDownloader.OnDownloadReturn isSuccess " .. tostring(isSuccess))
  for outterTaskID, filestate in pairs(processedFilestateList) do
    if not filestate.suspended then
      if isSuccess == false then
        log_error("PufferDownloader.OnDownloadReturn Error:" .. tostring(errorCode))
        filestate.lastErrno = errorCode
        PufferDownloader.RetryCurStage(filestate)
      elseif filestate.curStage == PufferDownloader.STAGE_FETCH_FILE_LIST then
        log(bWriteLog and "PufferDownloader.OnDownloadReturn Fetch FileList finish " .. tostring(filestate))
        filestate.filename = PufferDownloader.GetRealFilename(filestate.filename)
        PufferDownloader.DownloadFileImp(filestate)
      elseif filestate.curStage == PufferDownloader.STAGE_FILE_DOWNLOADING then
        log(bWriteLog and "PufferDownloader.OnDownloadReturn Fetch File finish over " .. tostring(filestate))
        if filestate.diffFilename ~= nil then
          PufferDownloader.MergeFile(filestate)
        else
          PufferDownloader.FinishRequestFile(filestate)
        end
        local puffer_odpak_manager = require("client.slua.logic.download.puffer.odpak.puffer_odpak_manager")
        puffer_odpak_manager:UFSSUpdatePkgMapType(filestate)
      else
        log_error("PufferDownloader.OnDownloadReturn filestate curStage is invalid")
        filestate.lastErrno = PufferDownloader.ERR_INVALID_STAGE_DOWNLOAD_RETURN
        PufferDownloader.RetryCurStage(filestate)
      end
    end
  end
end
function PufferDownloader.AddDownloadTimeOutTimer()
  log_format("PufferDownloader.AddDownloadTimeOutTimer.")
  PufferDownloader.RemoveDownloadTimeOutTimer()
  local time_ticker = require("common.time_ticker")
  PufferDownloader.JsonDownloadTimeOutTimer = time_ticker.AddTimer(5, function()
    log_format("PufferDownloader.AddDownloadTimeOutTimer. delay call")
    if PufferDownloader.IsAllPufferFileListJsonTaskReturn() and not PufferDownloader.PufferJsonDownloadReturn and not next(PufferDownloader.lastProductID) then
      local curProductID = GCPufferDownloader.GetProductID(Puffer)
      PufferDownloader.lastProductID = curProductID
      PufferDownloader.PufferJsonPostProcess()
    end
  end)
end
function PufferDownloader.RemoveDownloadTimeOutTimer()
  if PufferDownloader.JsonDownloadTimeOutTimer then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(PufferDownloader.JsonDownloadTimeOutTimer)
    PufferDownloader.JsonDownloadTimeOutTimer = nil
  end
end
function PufferDownloader.SyncProgressToCallback(outterTaskID, nowSize, totalSize, curStage)
  local PufferNetManager = require("client.slua.logic.download.network.logic_puffer_netmanager")
  PufferNetManager.MeasureFullSpeed()
  if PufferDownloader.NeedSkipDownload() then
    return
  end
  local filestate = PufferDownloader.filestateList[outterTaskID]
  if filestate == nil or filestate.slient then
    return
  end
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  PufferManager.SyncProgressToCallback(outterTaskID, nowSize, totalSize, curStage)
end
function PufferDownloader.SyncFinishToCallback(outterTaskID, isSuccess, errorCode)
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local task = PufferManager.SyncFinishToCallback(outterTaskID, isSuccess, errorCode)
  local filestate = PufferDownloader.filestateList[outterTaskID]
  local itemID = task and task.itemID or 0
  local path = task and task.path or ""
  if errorCode ~= 0 then
    if filestate == nil then
      PufferDownloader.UploadGemReport(errorCode, "", "SyncFinish filestate is nil")
    elseif filestate.slient then
      PufferDownloader.UploadGemReport(errorCode, filestate.filename or "", "SyncFinish filestate is filestate slient")
    else
      PufferDownloader.UploadGemReport(errorCode, filestate.filename, string.format("SyncFinish Error. Item %s, Path %s", tostring(itemID), tostring(path)))
    end
  else
    local PufferSwitch = require("client.slua.logic.download.puffer_switch")
    if PufferSwitch.uploadDownloadSuccess then
      PufferDownloader.UploadGemReport(errorCode, filestate.filename, string.format("SyncFinish Success. Item %s, Path %s", tostring(itemID), tostring(path)))
    end
  end
end
function PufferDownloader.ReadAddtionalPufferjson()
  local fileListContent = ""
  log(bWriteLog and "PufferDownloader LoadPufferFileListJson Addtional: " .. PufferDownloader.FILE_LIST_ADDTIONAL_NAME)
  fileListContent = GCPufferDownloader.ReadFile(Puffer, PufferDownloader.FILE_LIST_ADDTIONAL_NAME)
  local append_json = json.decode(fileListContent) or {}
  local PufferListJson = PufferDownloader.GetPufferFileListJson()
  if PufferListJson == nil or next(PufferListJson) == nil then
    return
  end
  PufferListJson.res_ver = append_json.res_ver
  if append_json.version_mapping ~= nil then
    for key, val in pairs(append_json.version_mapping) do
      PufferListJson.version_mapping[key] = val
    end
  end
  if append_json.version_mapping ~= nil then
    PufferListJson.prefetch = append_json.prefetch
  end
  if append_json.MapAdditionalShaderInfo then
    PufferListJson.MapAdditionalShaderInfo = append_json.MapAdditionalShaderInfo
  end
  return
end
function PufferDownloader.ReadPufferFileListJson(force)
  if logic_puffer_common.PufferFileListJson and next(logic_puffer_common.PufferFileListJson) and not force then
    return logic_puffer_common.PufferFileListJson
  end
  log_format("PufferDownloader.ReadPufferFileListJson. force=%s, match app version=%s", tostring(force), tostring(logic_puffer_common.PufferVersionMatchAppVersion))
  local skipReadFile = false
  if not Client.IsDevelopment() and logic_puffer_common.PufferVersionMatchAppVersion then
    skipReadFile = true
  end
  log_format("PufferDownloader.ReadPufferFileListJson. skipReadFile=%s", skipReadFile)
  local begintime = slua.getMiliseconds()
  if not skipReadFile then
    logic_puffer_common.PufferVersionMatchAppVersion = false
    if Puffer then
      logic_puffer_common.ReadPufferFileListContent()
    end
  end
  local endtime = slua.getMiliseconds()
  log_format("PufferDownloader.ReadPufferFileListJson cost time = %s", endtime - begintime)
  local jsonVersion = logic_puffer_common.PufferFileListJson.version
  printf("PufferDownloader.ReadPufferFileListJson. jsonVersion=%s", tostring(jsonVersion))
  if jsonVersion == nil then
    logic_puffer_common.PufferFileListJson = {}
    Client.AddCrashContextData(1003, "ReadJsonFail", false, 1200)
  else
    if Client.IsJaguar() then
      local jsonPufferID = logic_puffer_common.PufferFileListJson.pufferid
      if jsonPufferID then
        local savedProductID = StringUtil.Split(jsonPufferID, ",")
        local curProductID = GCPufferDownloader.GetProductID(Puffer)
        log_format("PufferDownloader.ReadPufferFileListJson savedProductID:%s curProductID:%s", savedProductID[2], curProductID[1])
        if tonumber(savedProductID[2]) > 0 and tostring(savedProductID[2]) ~= tostring(curProductID[1]) then
          logic_puffer_common.PufferFileListJson = {}
          return logic_puffer_common.PufferFileListJson
        end
      else
        logic_puffer_common.PufferFileListJson = {}
        jsonVersion = nil
        return logic_puffer_common.PufferFileListJson
      end
    end
    Client.AddCrashContextData(1003, "ReadJsonSuccess", false, 1200)
    local version_util = require("client.common.version_util")
    local appVersion = Client.GetApplicationVersion()
    if version_util.CompareVersionStandard(jsonVersion, appVersion) ~= 0 then
      log_error_format("PufferDownloader.GetPufferFileListJson jsonVersion(%s) < appVersion(%s)", jsonVersion, appVersion)
      Client.AddCrashContextData(1003, "ReadJsonFail_JsonVersion<AppVersion", false, 1200)
      logic_puffer_common.PufferFileListJson = {}
      jsonVersion = nil
    else
      logic_puffer_common.PufferVersionMatchAppVersion = true
    end
  end
  if PufferDownloader.IsAllPufferFileListJsonTaskReturn() and not skipReadFile then
    local pufferListJson = logic_puffer_common.PufferFileListJson
    if pufferListJson and pufferListJson.tasknum then
      local num = tonumber(pufferListJson.tasknum)
      if 0 < num then
        local basePath = Client.ProjectSavedDir() .. PufferDownloader.DOWNLOAD_DIR_RELATIVE
        for i = 1, num do
          local fileName = string.format("PufferFileList_%s.json", i)
          local fullPath = basePath .. fileName
          if Client.IsFileExistsWithOutPakCheck(fullPath) then
            local file = GCPufferDownloader.ReadFile(Puffer, fileName)
            local extraJson = json.decode(file) or {}
            for ODPackID, data in pairs(extraJson.ODPaks) do
              if not pufferListJson.ODPaks[ODPackID] then
                pufferListJson.ODPaks[ODPackID] = data
              else
                pufferListJson.ODPaks[ODPackID].size = pufferListJson.ODPaks[ODPackID].size + data.size
                for _, pakName in pairs(data.fileList) do
                  table.insert(pufferListJson.ODPaks[ODPackID].fileList, pakName)
                end
              end
            end
          end
        end
      end
    end
  end
  log(bWriteLog and string.format("PufferDownloader.ReadPufferFileListJson version:%s", tostring(jsonVersion)))
  PufferDownloader.ReadAddtionalPufferjson()
  if jsonVersion and logic_puffer_common.PufferFileListJson.PipeLineID then
    Client.SetPufferBuildInfo(tostring(logic_puffer_common.PufferFileListJson.PipeLineID), tostring(logic_puffer_common.PufferFileListJson.BuildNo))
  end
  return logic_puffer_common.PufferFileListJson
end
function PufferDownloader.GetPufferFileListJson()
  return logic_puffer_common.PufferFileListJson
end
function PufferDownloader.RequestFile(gameFrontendHUD, filename, forceUpdate, downloadType)
  if not GCPufferDownloader.IsInitSuccess(Puffer) then
    log(bWriteLog and "PufferDownloader RequestFile Not Initialized")
    return PufferDownloader.INVALID_TASK_ID
  end
  local ModuleManager = require("client.module_framework.ModuleManager")
  local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
  PufferODPakManager.PauseDontAutoDownloadPaks[filename] = nil
  local filestate = PufferDownloader.GetfilestateByFilename(filename)
  if filestate == nil then
    filestate = PufferDownloader.FileState(filename, forceUpdate)
    local outterTaskID = PufferDownloader.outterTaskIDFilenameMapping[filename]
    if outterTaskID ~= nil then
      filestate.    else
      PufferDownloader.outterTaskIDFilenameMapping[filename] = filestate.outterTaskID
    end
    log(bWriteLog and "PufferDownloader RequestFile new filestate: " .. tostring(filestate))
    log(bWriteLog and "PufferDownloader RequestFile After create new filestate. maxOutterTaskID=" .. PufferDownloader.maxOutterTaskID)
    PufferDownloader.filestateList[filestate.outterTaskID] = filestate
  else
    filestate.suspended = false
    log(bWriteLog and "PufferDownloader RequestFile filestate is existed " .. tostring(filestate))
  end
  filestate.  return filestate.outterTaskID
end
function PufferDownloader.IsFileListExist()
  if not GCPufferDownloader.IsInitSuccess(Puffer) then
    return false
  end
  local json = PufferDownloader.GetPufferFileListJson() or {}
  return next(json) ~= nil
end
function PufferDownloader.GetfilestateByFilename(filename)
  return PufferDownloader.filestateList[PufferDownloader.outterTaskIDFilenameMapping[filename]]
end
function PufferDownloader.GetfilestateByPufferTaskID(pufferTaskID)
  for outterTaskID, filestate in pairs(PufferDownloader.filestateList) do
    if filestate.pufferTaskID == pufferTaskID then
      return filestate
    end
  end
  return nil
end
function PufferDownloader.isFightingMode()
  return not GameStatus.InSupportDownloadState()
end
function PufferDownloader.SetBattleDownloadSwitch(switch)
  log(bWriteLog and string.format("PufferDownloader.SetBattleDownloadSwitch. switch=%s", tostring(switch)))
  PufferDownloader.BattleDownloadSwitch = switch
  GCPufferDownloader.SetBattleDownloadSwitch(Puffer, switch)
end
function PufferDownloader.EnableDownloadInBattle()
  if not GameStatus.IsInFightingStatus() then
    log(bWriteLog and "PufferDownloader.EnableDownloadInBattle, not in battle")
    return
  end
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  if not MatchModeMgrSystem.IsCreativeMode() then
    log(bWriteLog and "PufferDownloader.EnableDownloadInBattle, not is ugc mode")
    return
  end
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  PufferManager.PauseAllDownloadTasks()
  local PufferNetManager = require("client.slua.logic.download.network.logic_puffer_netmanager")
  PufferNetManager.SetDownloadLimitSpeed()
  PufferDownloader.SetBattleDownloadSwitch(true)
  local ScriptHelperEngine = import("ScriptHelperEngine")
  if PufferDownloader.bStopPufferDownloader then
    log(bWriteLog and "PufferDownloader.EnableDownloadInBattle, is low meory Device")
    local PufferConfigSys = require("client.slua.logic.download.puffer.puffer_config")
    local PufferConfig = PufferConfigSys:GetDefaultConfig()
    Client.ReInitializePuffer(GameFrontendHUD, false, PufferConfig.MaxDownloadsPerTask, PufferConfig.MaxDownTask, PufferConfig.MaxDownloadSpeed, true, false, 1, PufferConfig.PufferDownloadFuncDict, PufferConfig.HttpDnsType, PufferConfig.DownloadStageType, PufferConfig.DownloadEngineType)
    PufferDownloader.bStopPufferDownloader = false
  else
    Client.SetActivePufferTick(GameFrontendHUD, true)
    local PufferConfigSys = require("client.slua.logic.download.puffer.puffer_config")
    local PollintTime = PufferConfigSys.GetImmDLPollingTime(PufferConfigSys.DOWNLOAD_PHASE.NORMAL)
    GCPufferDownloader.SetImmDLPollingTime(Puffer, PollintTime)
  end
end
function PufferDownloader.NeedSkipDownload()
  if PufferDownloader.BattleDownloadSwitch then
    return false
  end
  if PufferDownloader.isFightingMode() then
    return true
  end
  return false
end
local ResourceStreamTimes = 0
function PufferDownloader.Tick(DeltaTime)
  if PufferDownloader.NeedSkipDownload() then
    return
  end
  for outterTaskID, filestate in pairs(PufferDownloader.filestateList) do
    local curStage = filestate.curStage
    if curStage == PufferDownloader.STAGE_INITIALIZING then
      PufferDownloader.FetchFileList(filestate)
    elseif curStage == PufferDownloader.STAGE_FILE_MERGING then
      local dummyProgress = 0
      if filestate.mergeTotalProg == -1 then
        filestate.mergePassedProg = filestate.mergePassedProg + DeltaTime
        dummyProgress = filestate.mergePassedProg / PufferDownloader.MERGE_DUMMY_WAIT_TIME * 100
      else
        local downloadPath = GCPufferDownloader.GetDownloadPath(Puffer)
        filestate.mergePassedProg = GCPufferDownloader.GetFileSize(Puffer, downloadPath .. filestate.filename .. PufferDownloader.INPROGRESS_PAK_SUFFIX)
        dummyProgress = filestate.mergePassedProg / filestate.mergeTotalProg * 100
      end
      PufferDownloader.SyncProgressToCallback(filestate.outterTaskID, dummyProgress, 100, filestate.curStage)
    end
  end
  if not PufferDownloader.isFightingMode() then
    PufferDownloader.ODPaksRequestReportTimeLast = PufferDownloader.ODPaksRequestReportTimeLast + DeltaTime
    if PufferDownloader.ODPaksRequestReportTimeLast >= PufferDownloader.ODPaksRequestReportTimeThreshold and PufferDownloader.ODPaksRequestNumber ~= 0 then
      local param = {
        tostring(PufferDownloader.ODPaksRequestNumber),
        tostring(PufferDownloader.ODPaksRequestFailedNumber)
      }
      PufferDownloader.GEMReportSubEvent("PufferODPaksRequestFinished", param)
      PufferDownloader.ODPaksRequestNumber = 0
      PufferDownloader.ODPaksRequestFailedNumber = 0
      PufferDownloader.ODPaksRequestReportTimeLast = 0
    end
  end
  local PufferNetManager = require("client.slua.logic.download.network.logic_puffer_netmanager")
  PufferNetManager.Tick(DeltaTime)
  PufferDownloader.nProgressTime = PufferDownloader.nProgressTime + DeltaTime
  if PufferDownloader.nProgressTime >= PufferDownloader.nProgressCD then
    local min
    local index = 0
    for i, v in pairs(PufferDownloader.filestateList) do
      if v.nowSize and v.totalSize then
        if not v.lastProgressTime then
          v.lastProgressTime = TimeUtil.GetMiliseconds()
          PufferDownloader.SyncProgressToCallback(v.outterTaskID, v.nowSize, v.totalSize, v.curStage)
          index = 0
          break
        elseif not min or min > v.lastProgressTime then
          min = v.lastProgressTime
          index = i
        end
      end
    end
    if 0 < index then
      local task = PufferDownloader.filestateList[index]
      task.lastProgressTime = TimeUtil.GetMiliseconds()
      PufferDownloader.SyncProgressToCallback(task.outterTaskID, task.nowSize, task.totalSize, task.curStage)
    end
    PufferDownloader.nProgressTime = 0
  end
  if GameStatus.InSupportDownloadState() then
    ResourceStreamTimes = ResourceStreamTimes + 1
    if 60 < ResourceStreamTimes then
      local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
      PufferManager.UpdateResourceStream()
      ResourceStreamTimes = 0
    end
  end
end
function PufferDownloader.FetchFileList(filestate)
  if not GCPufferDownloader.IsInitSuccess(Puffer) then
    filestate.lastErrno = PufferDownloader.ERR_NOT_INITIALIZED
    PufferDownloader.FinishRequestFile(filestate)
    return false
  end
  filestate.curStage = PufferDownloader.STAGE_FETCH_FILE_LIST
  PufferDownloader.ReportStageChange(filestate)
  local isODPaks = string.find(filestate.filename, PufferDownloader.DOWNLOAD_ODPAKS_RELATIVE) ~= nil
  local isUGCPaks = string.find(filestate.filename, PufferDownloader.DOWNLOAD_UGCPAKS_RELATIVE) ~= nil
  if PufferDownloader.IsFileListExist() or isODPaks or isUGCPaks then
    local PufferConst = require("client.slua.logic.download.puffer_const")
    if not isODPaks and not isUGCPaks and filestate.downloadType ~= PufferConst.ENUM_DownloadType.PREFETCH then
      filestate.filename = PufferDownloader.GetRealFilename(filestate.filename)
    end
    PufferDownloader.SyncProgressToCallback(filestate.outterTaskID, 100, 100, filestate.curStage)
    PufferDownloader.DownloadFileImp(filestate)
  else
    log(bWriteLog and "PufferDownloader FetchFileList FileList NOT existed, Start Fetch FileList fileListPufferTaskID=" .. tostring(PufferDownloader.fileListPufferTaskID))
    PufferDownloader.SyncProgressToCallback(filestate.outterTaskID, 0, 100, filestate.curStage)
    if PufferDownloader.fileListPufferTaskID <= 0 then
      local PufferUA = PufferDownloader.GetPufferUA(0)
      PufferDownloader.fileListPufferTaskID = GCPufferDownloader.RequestFile(Puffer, logic_puffer_common.GetPufferFileListName(), true, PufferUA)
      log(bWriteLog and "PufferDownloader FetchFileList Fetch FileList pufferTaskID " .. tostring(PufferDownloader.fileListPufferTaskID))
      if PufferDownloader.fileListPufferTaskID == PufferDownloader.INVALID_TASK_ID then
        log_error("PufferDownloader FetchFileList FetchFileList Failed")
        filestate.lastErrno = PufferDownloader.ERR_INVALID_TASK_ID
        PufferDownloader.RetryCurStage(filestate)
      end
    end
  end
  return true
end
function PufferDownloader.ParsePakName(name)
  return string.match(name, "^([%a_%d]+)(%d+%.%d+%.%d+%.%d+)%.pak$")
end
function PufferDownloader.CompareVersion(version1, version2)
  local version1_splited = StringUtil.Split(version1, ".")
  local version2_splited = StringUtil.Split(version2, ".")
  for i = 1, 4 do
    if version1_splited[i] ~= version2_splited[i] then
      local val1 = tonumber(version1_splited[i])
      local val2 = tonumber(version2_splited[i])
      return val1 - val2
    end
  end
  return 0
end
function PufferDownloader.GetTargetFilenameByName(filename)
  local filestate = PufferDownloader.FileState(filename)
  return PufferDownloader.GetTargetFilename(filestate)
end
function PufferDownloader.GetTargetFilename(filestate)
  if string.find(filestate.filename, PufferDownloader.DOWNLOAD_ODPAKS_RELATIVE) then
    return filestate.filename
  elseif string.find(filestate.filename, PufferDownloader.DOWNLOAD_UGCPAKS_RELATIVE) then
    return filestate.filename
  elseif string.find(filestate.filename, PufferDownloader.DOWNLOAD_PREFETCH_RELATIVE) then
    return filestate.filename
  elseif not string.find(filestate.filename, ".pak", nil, true) then
    return filestate.filename
  end
  if filestate and filestate.downloadType == PufferConst.ENUM_DownloadType.MAP and not HDmpveRemote.HDmpveRemoteConfigGetBool("MapPakDownloadDiffFile", true) then
    log_format("PufferDownloader.GetTargetFilename. diff return filestate.filename=%s", filestate.filename)
    return filestate.filename
  end
  local table = PufferDownloader.GetPufferFileListJson()
  local diffList = table.diff_list or {}
  local downloadFilename = filestate.filename
  local targetFilePrefix, targetFileVersionNo = PufferDownloader.ParsePakName(filestate.filename)
  if targetFilePrefix == nil or targetFileVersionNo == nil then
    filestate.lastErrno = PufferDownloader.ERR_INVALID_REQUEST_FILENAME
    return nil
  end
  local localOldPak = {}
  local ret = GCPufferDownloader.ReturnLocalFiles(PufferDownloader.DOWNLOAD_DIR_RELATIVE, "")
  for idx, filename in pairs(ret) do
    local prefix, versionNo = PufferDownloader.ParsePakName(filename)
    if prefix ~= nil and versionNo ~= nil then
      if localOldPak[prefix] ~= nil then
        if PufferDownloader.CompareVersion(versionNo, localOldPak[prefix]) > 0 then
          localOldPak[prefix] = versionNo
        end
      else
        localOldPak[prefix] = versionNo
      end
    end
  end
  local oldVersion = localOldPak[targetFilePrefix]
  if oldVersion then
    if diffList[oldVersion] then
      filestate.diffFilename = diffList[oldVersion][filestate.filename]
      filestate.oldFilename = targetFilePrefix .. oldVersion .. ".pak"
    else
    end
    downloadFilename = filestate.diffFilename
    if downloadFilename == nil then
      downloadFilename = filestate.filename
    end
  end
  return downloadFilename
end
function PufferDownloader.SetImmDLTaskConfig(downloadType)
  local PufferConfigSys = require("client.slua.logic.download.puffer.puffer_config")
  local maxTask, maxDownloadsPerTask = PufferConfigSys.GetImmDLTaskConfig(downloadType)
  local result1 = GCPufferDownloader.SetImmDLMaxTask(Puffer, maxTask)
  local reuslt2 = GCPufferDownloader.SetImmDLMaxDownloadsPerTask(Puffer, maxDownloadsPerTask)
  return result1 and reuslt2
end
function PufferDownloader.GetPufferUA(resType)
  local PufferConfigSys = require("client.slua.logic.download.puffer.puffer_config")
  return PufferConfigSys:GetPufferUA(resType)
end
function PufferDownloader.DownloadFileImp(filestate)
  if not GCPufferDownloader.IsInitSuccess(Puffer) then
    filestate.lastErrno = PufferDownloader.ERR_NOT_INITIALIZED
    PufferDownloader.FinishRequestFile(filestate)
    return false
  end
  filestate.curStage = PufferDownloader.STAGE_FILE_DOWNLOADING
  PufferDownloader.ReportStageChange(filestate)
  local downloadFilename = PufferDownloader.GetTargetFilename(filestate)
  if downloadFilename == nil then
    log_error("PufferDownloader DownloadFileImp target filename parse error " .. tostring(filestate.filename))
    PufferDownloader.FinishRequestFile(filestate)
    return false
  end
  if PufferDownloader.isFightingMode() or not Client.IsFileExistsWithOutPakCheck(Client.ProjectSavedDir() .. PufferDownloader.DOWNLOAD_DIR_RELATIVE .. downloadFilename) then
    if not PufferDownloader.SetImmDLTaskConfig(filestate.downloadType) then
      log(bWriteLog and "PufferDownloader.DownloadFileImp: failed to set ImmDLTaskCfg")
    end
    local PufferUA = PufferDownloader.GetPufferUA(filestate.downloadType)
    local taskID = GCPufferDownloader.RequestFile(Puffer, downloadFilename, filestate.forceUpdate, PufferUA)
    filestate.pufferTaskID = taskID
    PufferDownloader.SyncProgressToCallback(filestate.outterTaskID, 0, 100, filestate.curStage)
    if taskID == PufferDownloader.INVALID_TASK_ID then
      log_error("PufferDownloader.DownloadFileImp RequestFile Failed ErrorCode = -1")
      filestate.lastErrno = PufferDownloader.ERR_INVALID_TASK_ID
      PufferDownloader.RetryCurStage(filestate)
    end
  else
    log(bWriteLog and "PufferDownloader DownloadFileImp " .. tostring(downloadFilename) .. " is ready")
    PufferDownloader.SyncProgressToCallback(filestate.outterTaskID, 100, 100, filestate.curStage)
    if filestate.diffFilename ~= nil then
      PufferDownloader.MergeFile(filestate)
    else
      PufferDownloader.FinishRequestFile(filestate)
    end
  end
  return true
end
function PufferDownloader._MergeFileDo(filestate)
  if not filestate then
    log(bWriteLog and "LogicPufferDownloaderLUA _MergeFileDo filestate=nil")
    return
  end
  PufferDownloader.MergingDiffCount = 1
  log(bWriteLog and "LogicPufferDownloaderLUA _MergeFileDo MergingDiffCount = 1 ")
  filestate.curStage = PufferDownloader.STAGE_FILE_MERGING
  PufferDownloader.ReportStageChange(filestate)
  PufferDownloader.SyncProgressToCallback(filestate.outterTaskID, 0, 100, filestate.curStage)
  local downloadPath = GCPufferDownloader.GetDownloadPath(Puffer)
  local tempWorkPath = GCPufferDownloader.GetTempWorkPath(Puffer)
  log(bWriteLog and "LogicPufferDownloaderLUA _MergeFileDo filestate=" .. tostring(filestate) .. ", tempWorkPath=" .. tostring(tempWorkPath) .. ", downloadPath=" .. tostring(downloadPath))
  GCPufferDownloader.MergeBinDiffPak(Puffer, filestate.outterTaskID, downloadPath .. filestate.oldFilename, downloadPath .. filestate.diffFilename, downloadPath .. filestate.filename .. PufferDownloader.INPROGRESS_PAK_SUFFIX, true)
  local oldFileSize = GCPufferDownloader.GetFileSize(Puffer, downloadPath .. filestate.oldFilename)
  local diffFileSize = GCPufferDownloader.GetFileSize(Puffer, downloadPath .. filestate.diffFilename)
  local newFileSize = GCPufferDownloader.GetFileSizeCompressed(Puffer, filestate.filename)
  if oldFileSize == -1 or diffFileSize == -1 or newFileSize == -1 then
    log_error("LogicPufferDownloaderLUA _MergeFileDo GetFileSizeFailed oldFile:" .. tostring(filestate.oldFilename) .. " " .. tostring(filestate.oldFileSize) .. " diffFile:" .. tostring(filestate.diffFilename) .. " " .. tostring(filestate.diffFileSize))
    filestate.mergeTotalProg = -1
  else
    filestate.mergeTotalProg = newFileSize / 1024.0
  end
end
function PufferDownloader.MergeFile(filestate)
  local PufferDownloaderMergeTickTime = HDmpveRemote.HDmpveRemoteConfigGetInt("PufferDownloaderMergeTickTime", 1)
  if PufferDownloader.MergingDiffCount == 0 or PufferDownloaderMergeTickTime <= 0 then
    log(bWriteLog and "LogicPufferDownloaderLUA MergeFile Merge filestate=" .. tostring(filestate))
    PufferDownloader._MergeFileDo(filestate)
    return
  end
  PufferDownloader.MergeFileList = PufferDownloader.MergeFileList or {}
  table.insert(PufferDownloader.MergeFileList, filestate)
  log(bWriteLog and "LogicPufferDownloaderLUA MergeFile Merge 1 len=" .. tostring(#PufferDownloader.MergeFileList) .. ", filestate=" .. tostring(filestate))
  if not PufferDownloader.mergeTimer then
    local time_ticker = require("common.time_ticker")
    PufferDownloader.mergeTimer = time_ticker.AddTimerLoop(0, function()
      if #PufferDownloader.MergeFileList <= 0 then
        time_ticker.RemoveTimer(PufferDownloader.mergeTimer)
        PufferDownloader.mergeTimer = nil
        return
      end
      if PufferDownloader.MergingDiffCount == 0 then
        local tempFileState = PufferDownloader.MergeFileList[1]
        log(bWriteLog and "LogicPufferDownloaderLUA MergeFile Merge 2 len=" .. tostring(#PufferDownloader.MergeFileList) .. ", tempFileState=" .. tostring(tempFileState))
        table.remove(PufferDownloader.MergeFileList, 1)
        if tempFileState then
          PufferDownloader._MergeFileDo(tempFileState)
        end
      end
    end, TIMER_INFINITE, 1)
  end
end
function PufferDownloader.OnMergeBinDiffPakReturn(outterTaskID, errorCode)
  log(bWriteLog and "LogicPufferDownloaderLUA OnMergeBinDiffPakReturn return MergingDiffCount = 0 outterTaskID:" .. tostring(outterTaskID) .. " errorCode:" .. tostring(errorCode))
  PufferDownloader.MergingDiffCount = 0
  local filestate = PufferDownloader.filestateList[outterTaskID]
  if filestate == nil then
    log_error("PufferDownloader OnMergeBinDiffPakReturn cannot find correspond filestate for merge callback or the filestate is suspended" .. tostring(outterTaskID) .. "MergeErrorCode:" .. errorCode)
    return
  end
  log(bWriteLog and "PufferDownloader OnMergeBinDiffPakReturn filestate " .. tostring(filestate))
  PufferDownloader.SyncProgressToCallback(filestate.outterTaskID, 100, 100, filestate.curStage)
  if errorCode == 0 then
    PufferDownloader.CheckFile(filestate)
  else
    filestate.lastErrno = errorCode
    PufferDownloader.FinishRequestFile(filestate)
    PufferDownloader.UploadGemReport(errorCode, filestate.filename, "MergeBinDiffPak Error")
  end
end
function PufferDownloader.PreCheckOldFile(filestate)
  filestate.curStage = PufferDownloader.STAGE_PRECHECK_OLDFILE
  PufferDownloader.SyncProgressToCallback(filestate.outterTaskID, 0, 100, filestate.curStage)
  log(bWriteLog and "PufferDownloader CheckFile start PRE check olf File" .. tostring(filestate))
  local downloadPath = GCPufferDownloader.GetDownloadPath(Puffer)
  if filestate.oldFilename then
    GCPufferDownloader.CheckDownloadFileFraming(Puffer, filestate.outterTaskID, downloadPath .. filestate.oldFilename, 4194304)
  end
end
function PufferDownloader.CheckFile(filestate)
  filestate.curStage = PufferDownloader.STAGE_FILE_CHECKING
  PufferDownloader.ReportStageChange(filestate)
  PufferDownloader.SyncProgressToCallback(filestate.outterTaskID, 0, 100, filestate.curStage)
  log(bWriteLog and "PufferDownloader CheckFile start check File" .. tostring(filestate))
  local downloadPath = GCPufferDownloader.GetDownloadPath(Puffer)
  GCPufferDownloader.CheckDownloadFileFraming(Puffer, filestate.outterTaskID, downloadPath .. filestate.filename .. PufferDownloader.INPROGRESS_PAK_SUFFIX, 4194304)
end
function PufferDownloader.OnHashGenerateFinished(outterTaskID, hashcode)
  log(bWriteLog and "PufferDownloader CheckFile return outterTaskID:" .. tostring(outterTaskID) .. " hashCode:" .. tostring(hashcode))
  local filestate = PufferDownloader.filestateList[outterTaskID]
  if filestate == nil then
    log_error("PufferDownloader OnHashGenerateFinished cannot find correspond filestate for hashGen callback " .. tostring(outterTaskID))
    return
  end
  local checkList = PufferDownloader.GetPufferFileListJson().check_list or {}
  local checkPassed = false
  if filestate.curStage == PufferDownloader.STAGE_PRECHECK_OLDFILE then
    if filestate.oldFilename ~= nil and checkList[filestate.oldFilename] ~= nil and #checkList[filestate.oldFilename] ~= 0 then
      filestate.preCheckPassed = false
      for i = 1, #checkList[filestate.oldFilename] do
        log(bWriteLog and "PufferDownloader CheckFile: Pre check targetHash=" .. tostring(checkList[filestate.oldFilename][i]))
        if string.lower(checkList[filestate.oldFilename][i]) == string.lower(hashcode) then
          filestate.preCheckPassed = true
          log(bWriteLog and "PufferDownloader CheckFile: Pre check success")
        end
      end
      if filestate.preCheckPassed == false then
        log(bWriteLog and "PufferDownloader CheckFile: Pre check failed")
      end
      filestate.slient = false
      PufferDownloader.SyncProgressToCallback(filestate.outterTaskID, 100, 100, filestate.curStage)
      PufferDownloader.FinishRequestFile(filestate)
    else
      filestate.preCheckPassed = false
      log_warning("PufferDownloader PRE CheckFile skip check, filestate:" .. tostring(filestate))
      PufferDownloader.FinishRequestFile(filestate)
    end
    return
  elseif checkList[filestate.filename] == nil or #checkList[filestate.filename] == 0 then
    log_warning("PufferDownloader CheckFile skip check, because checkList does not contain corresponding Hash" .. tostring(filestate))
    checkPassed = true
  else
    checkPassed = false
    for i = 1, #checkList[filestate.filename] do
      log(bWriteLog and "PufferDownloader CheckFile: targetHash=" .. tostring(checkList[filestate.filename][i]))
      if string.lower(checkList[filestate.filename][i]) == string.lower(hashcode) then
        checkPassed = true
      end
    end
    if not checkPassed then
      filestate.lastErrno = PufferDownloader.ERR_CHECK_FILE_FAILED
    end
  end
  if checkPassed then
    local downloadPath = GCPufferDownloader.GetDownloadPath(Puffer)
    log(bWriteLog and "PufferDownloader CheckFile: move file from " .. tostring(downloadPath .. filestate.filename .. PufferDownloader.INPROGRESS_PAK_SUFFIX) .. " " .. tostring(downloadPath .. filestate.filename))
    local ret = GCPufferDownloader.MoveFile(Puffer, downloadPath .. filestate.filename .. PufferDownloader.INPROGRESS_PAK_SUFFIX, downloadPath .. filestate.filename)
    if ret ~= 0 then
      log_error("PufferDownloader OnMergeBinDiffPakReturn MoveFileTo Operation Error " .. tostring(ret) .. "From:" .. tostring(filestate.filename .. PufferDownloader.INPROGRESS_PAK_SUFFIX) .. "To:" .. tostring(downloadPath .. filestate.filename))
      filestate.lastErrno = ret
      PufferDownloader.FinishRequestFile(filestate)
    end
  end
  filestate.slient = false
  PufferDownloader.SyncProgressToCallback(filestate.outterTaskID, 100, 100, filestate.curStage)
  PufferDownloader.FinishRequestFile(filestate)
end
function PufferDownloader.ReportStageChange(filestate)
  if string.find(filestate.filename, PufferDownloader.DOWNLOAD_ODPAKS_RELATIVE) then
    return
  end
  if string.find(filestate.filename, PufferDownloader.DOWNLOAD_UGCPAKS_RELATIVE) then
    return
  end
  local param = {
    tostring(filestate.diffFilename ~= nil),
    tostring(filestate.filename),
    tostring(filestate.curStage)
  }
  PufferDownloader.GEMReportSubEvent("PufferStageChanged", param)
end
function PufferDownloader.ReportPakInfoToTLog()
  local PufferDownloadHandler = require("client.network.Protocol.PufferDownloadHandler")
  local PakNum = GCPufferDownloader.GetODPakNum(Puffer)
  log(bWriteLog and "Current ODPaks Num is " .. tostring(PakNum))
  PufferDownloadHandler.send_client_pak_report(PakNum)
end
function PufferDownloader.FinishRequestFile(filestate)
  local prefix = PufferDownloader.ParsePakName(filestate.filename)
  local errorStage = filestate.curStage
  if filestate.curStage == PufferDownloader.STAGE_RETRY or filestate.curStage == PufferDownloader.STAGE_PRECHECK_OLDFILE then
    errorStage = filestate.retryStage
  end
  if (errorStage == PufferDownloader.STAGE_FILE_MERGING or errorStage == PufferDownloader.STAGE_FILE_CHECKING) and filestate.lastErrno ~= 0 then
    log_error("PufferDownloader DownloadFileImp Merge/Check Error" .. tostring(filestate))
    if filestate.preCheckPassed == nil then
      filestate.retryStage = filestate.curStage
      PufferDownloader.PreCheckOldFile(filestate)
      return
    end
  end
  local isODPaks = string.find(filestate.filename, PufferDownloader.DOWNLOAD_ODPAKS_RELATIVE)
  local isUGCPaks = string.find(filestate.filename, PufferDownloader.DOWNLOAD_UGCPAKS_RELATIVE)
  if isODPaks or isUGCPaks then
    PufferDownloader.ODPaksRequestNumber = PufferDownloader.ODPaksRequestNumber + 1
    if filestate.lastErrno ~= 0 then
      local ErrNum = 0
      for k, v in pairs(PufferDownloader.ODPaksRequestReportedError) do
        ErrNum = ErrNum + 1
      end
      if PufferDownloader.ODPaksRequestReportedError[filestate.filename] == nil and ErrNum < PufferDownloader.ODPaksRequestReportErrorMaxTimes then
        local param = {
          tostring(filestate.filename),
          tostring(filestate.lastErrno)
        }
        PufferDownloader.GEMReportSubEvent("PufferODPaksRequestError", param)
        PufferDownloader.ODPaksRequestReportedError[filestate.filename] = true
      end
      PufferDownloader.ODPaksRequestFailedNumber = PufferDownloader.ODPaksRequestFailedNumber + 1
    end
    if PufferDownloader.ODPaksRequestNumber >= PufferDownloader.ODPaksRequestReportNumberThreshold then
      local param = {
        tostring(PufferDownloader.ODPaksRequestNumber),
        tostring(PufferDownloader.ODPaksRequestFailedNumber)
      }
      PufferDownloader.GEMReportSubEvent("PufferODPaksRequestFinished", param)
      PufferDownloader.ODPaksRequestNumber = 0
      PufferDownloader.ODPaksRequestFailedNumber = 0
      PufferDownloader.ODPaksRequestReportTimeLast = 0
    end
  else
    local param = {
      isSuccess = tostring(filestate.lastErrno == 0),
      isIncremental = tostring(filestate.diffFilename ~= nil),
      filename = tostring(filestate.filename),
      errorCode = tostring(filestate.lastErrno),
      stage = tostring(errorStage),
      preCheckPassed = tostring(filestate.preCheckPassed)
    }
    for k, v in pairs(param) do
      log(bWriteLog and "GEM PufferFileRequestFinished PARAM " .. tostring(k) .. " " .. tostring(v))
    end
    if filestate.lastErrno == 0 then
      Client.GEMReportEvent(GameFrontendHUD, "PufferFileRequestFinished", param)
    elseif PufferDownloader.hasReportedError[prefix] == false then
      PufferDownloader.hasReportedError[prefix] = true
      Client.GEMReportEvent(GameFrontendHUD, "PufferFileRequestFinished", param)
    end
  end
  if (errorStage == PufferDownloader.STAGE_FILE_MERGING or errorStage == PufferDownloader.STAGE_FILE_CHECKING) and filestate.lastErrno ~= 0 then
    PufferDownloader.mergeFailedTimes[filestate.outterTaskID] = (PufferDownloader.mergeFailedTimes[filestate.outterTaskID] or 0) + 1
    if 1 <= PufferDownloader.mergeFailedTimes[filestate.outterTaskID] then
      PufferDownloader.DeleteAllOldPak(prefix)
      local param = {
        tostring(filestate.filename),
        tostring(errorStage),
        tostring(filestate.lastErrno)
      }
      PufferDownloader.GEMReportSubEvent("PufferTriggerFullDownload", param)
    end
  end
  filestate.curStage = PufferDownloader.STAGE_FINISH
  PufferDownloader.ReportStageChange(filestate)
  local downloadPath = GCPufferDownloader.GetDownloadPath(Puffer)
  if not isODPaks and not isUGCPaks then
    if filestate.diffFilename ~= nil then
      GCPufferDownloader.DeleteFile(downloadPath .. filestate.diffFilename)
    end
    if filestate.filename ~= nil then
      GCPufferDownloader.DeleteFile(downloadPath .. filestate.filename .. PufferDownloader.INPROGRESS_PAK_SUFFIX)
    end
    log(bWriteLog and "PufferDownloader DownloadFileImp cleanUp diffFile and tmpFile" .. tostring(filestate))
  end
  if filestate.lastErrno ~= 0 then
    log_error("PufferDownloader DownloadFileImp RequestFile Failed " .. tostring(filestate))
    PufferDownloader.SyncFinishToCallback(filestate.outterTaskID, false, filestate.lastErrno)
  elseif isODPaks then
    log(bWriteLog and tostring(filestate))
    PufferDownloader.SyncFinishToCallback(filestate.outterTaskID, true, filestate.lastErrno)
  elseif string.find(filestate.filename, PufferConst.PUFFERPATCH) then
    log(bWriteLog and "PufferPatch Finished")
    local isSuccess = filestate.lastErrno == 0
    PufferDownloader.SyncFinishToCallback(filestate.outterTaskID, isSuccess, filestate.lastErrno)
  else
    log(bWriteLog and "PufferDownloader DownloadFileImp RequestFile Success " .. tostring(filestate))
    local isSuccess = filestate.lastErrno == 0
    local param = {
      tostring(isSuccess),
      tostring(filestate.diffFilename ~= nil),
      tostring(filestate.filename)
    }
    PufferDownloader.GEMReportSubEvent("PufferMountPak", param)
    PufferDownloader.SyncFinishToCallback(filestate.outterTaskID, isSuccess, filestate.lastErrno)
    local filePathPak = Client.ProjectSavedDir() .. "Paks/" .. filestate.filename
    local fileSizePak = Client.GetFileSizeOnDiskBytes(filePathPak)
    local fileNamePak = tostring(filestate.filename) .. string.format("(%s)|", tostring(fileSizePak))
    Client.AddAttachFileString("pakname", false, fileNamePak)
  end
  PufferDownloader.filestateList[filestate.outterTaskID] = nil
end
function PufferDownloader.RetryCurStage(filestate)
  if PufferDownloader.filestateList[filestate.outterTaskID] == nil then
    log(bWriteLog and "PufferDownloader RetryCurStage: outerTask:" .. filestate.outterTaskID .. " has been stopped do not continue retrying")
    return
  end
  filestate.retryStage = filestate.curStage
  filestate.curStage = PufferDownloader.STAGE_RETRY
  filestate.retryTimes = filestate.retryTimes + 1
  PufferDownloader.ReportStageChange(filestate)
  if filestate.retryTimes >= PufferDownloader.MAX_RETRY_TIMES then
    log(bWriteLog and "PufferDownloader RetryCurStage: Over Max RetryTimes ")
    PufferDownloader.FinishRequestFile(filestate)
    return false
  end
  local callback = function()
    if filestate and filestate.retryStage and PufferDownloader.PufferStageFunction[filestate.retryStage] then
      PufferDownloader.PufferStageFunction[filestate.retryStage](filestate)
    end
  end
  local time_ticker = require("common.time_ticker")
  PufferDownloader.retryTimer = time_ticker.AddTimerOnce(3, callback)
  return true
end
function PufferDownloader.SwitchToFighting()
  if GameStatus.InSupportDownloadState() then
    PufferDownloader.SetBattleDownloadSwitch(true)
    Client.EnableAutoObjectRefreshStage(true)
    return
  end
  Client.FlushKnownMissingPackageRefObject()
  Client.EnableAutoObjectRefreshStage(false)
  local PufferNetManager = require("client.slua.logic.download.network.logic_puffer_netmanager")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  PufferManager.PauseAllDownloadTasks()
  PufferNetManager.SetImmDLMaxSpeed(81920)
  local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
  PufferDownloader.ODPaksDownloadStatesInFighting = {}
  local ScriptHelperEngine = import("ScriptHelperEngine")
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if ScriptHelperEngine.IsLowMemoryDevice() then
    Client.StopPuffer(GameFrontendHUD)
    Client.SetActivePufferTick(GameFrontendHUD, false)
    PufferDownloader.bStopPufferDownloader = true
    log(bWriteLog and "ClearPuffer")
  else
    local ShutdownPufferMemLimit = 8
    local ShutdownPufferMemAvailable = 6
    local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
    local memoryStatus = Client.GetMemoryStats()
    local memlimit = memoryStatus.AvailablePhysical / 1073741824
    local memavail = memoryStatus.TotalPhysical / 1024 / 1024
    if ShutdownPufferMemLimit > memlimit and not MatchModeMgrSystem.IsCreativeMode() then
      Client.StopPuffer(GameFrontendHUD)
      Client.SetActivePufferTick(GameFrontendHUD, false)
      PufferDownloader.bStopPufferDownloader = true
      local PufferInitTracker = require("client.slua.logic.download.puffer.puffer_init_tracker")
      PufferInitTracker:OnStopPuffer(PufferInitTracker.EStopStage.BeforeBattle)
      log(bWriteLog and "Set puffer tick to low")
    end
    if not MatchModeMgrSystem.IsCreativeMode() then
      local PufferConfigSys = require("client.slua.logic.download.puffer.puffer_config")
      local PollintTime = PufferConfigSys.GetImmDLPollingTime(PufferConfigSys.DOWNLOAD_PHASE.FIGHTING)
      GCPufferDownloader.SetImmDLPollingTime(Puffer, PollintTime)
    end
  end
  PufferDownloader.RemoveDiffCheckTimer()
  log(bWriteLog and "Puffer In Switch To Fighting")
end
function PufferDownloader.UploadPufferDownladerStateInfo(param)
  if param == nil or next(param) == nil then
    return
  end
  log(bWriteLog and "PufferDownloader Reprot PufferJsonState " .. tostring(next(param)))
  Client.GEMReportSubEvent(GameFrontendHUD, "PufferEvent", "PufferDownloaderStateInfo", param)
end
function PufferDownloader.SwitchToLobby()
  if PufferDownloader.RecordExistPaks ~= nil then
    PufferDownloader.RecordExistPaks = nil
  end
  local PufferNetManager = require("client.slua.logic.download.network.logic_puffer_netmanager")
  PufferNetManager.MeasureFullSpeed(true)
  Client.SetActivePufferTick(GameFrontendHUD, true)
  local PufferConfigSys = require("client.slua.logic.download.puffer.puffer_config")
  local PollintTime = PufferConfigSys.GetImmDLPollingTime(PufferConfigSys.DOWNLOAD_PHASE.NORMAL)
  GCPufferDownloader.SetImmDLPollingTime(Puffer, PollintTime)
  local totalBytes = 0
  local totalTime = 0
  local reqCnt = 0
  local successTimes = 0
  log(bWriteLog and "Puffer In Switch To Lobby")
  if PufferDownloader.ODPaksDownloadStatesInFighting and next(PufferDownloader.ODPaksDownloadStatesInFighting) ~= nil then
    log(bWriteLog and "Puffer In report")
    for outterTaskID, stat in pairs(PufferDownloader.ODPaksDownloadStatesInFighting) do
      if 0 <= stat.success then
        if stat.success == 1 then
          successTimes = successTimes + 1
        end
        reqCnt = reqCnt + 1
        totalBytes = totalBytes + stat.totalBytes
        totalTime = totalTime + os.difftime(stat.endTime, stat.startTime)
      end
    end
    local param = {
      tostring(successTimes),
      tostring(reqCnt),
      tostring(totalTime),
      tostring(totalBytes)
    }
    PufferDownloader.GEMReportSubEvent("PufferODPaksReqInFight", param)
  end
  PufferDownloader.CheckUFSDiffList()
end
function PufferDownloader.CheckUFSDiffList()
  local needCheck = HDmpveRemote.HDmpveRemoteConfigGetBool("DownloaderCheckUFSDiffList", true)
  if not needCheck then
    log(bWriteLog and "PufferDownloader.CheckUFSDiffList. not needCheck")
    return
  end
  log(bWriteLog and "PufferDownloader.CheckUFSDiffList.")
  local time_ticker = require("common.time_ticker")
  PufferDownloader.RemoveDiffCheckTimer()
  if Client.USFSIsNewestVersion() then
    log(bWriteLog and "PufferDownloader.CheckUFSDiffList. Is NewestVersion")
    return
  end
  PufferDownloader.diffCheckTimer = time_ticker.AddTimerLoop(0, function()
    if not PufferDownloader.diffList then
      local list = Client.USFSGetUpgradeDiffList()
      if next(list) then
        PufferDownloader.diffList = {}
        for k, fileName in pairs(list) do
          PufferDownloader.diffList[fileName] = true
        end
        log_tree("PufferDownloader.SwitchToLobby. PufferDownloader.diffList = ", PufferDownloader.diffList)
      else
        log(bWriteLog and "PufferDownloader.CheckUFSDiffList. list is empty!")
        PufferDownloader.RemoveDiffCheckTimer()
        return
      end
    end
    log(bWriteLog and "PufferDownloader.CheckUFSDiffList. check")
    local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
    local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
    for fileName, v in pairs(PufferDownloader.diffList) do
      if Client.IsFileExistInCSCWithCheck(fileName) then
        log(bWriteLog and "PufferDownloader.CheckUFSDiffList. fileName = " .. tostring(fileName))
        PufferDownloader.SetPakExist(fileName, true)
        local task = {
          pakName = fileName,
          from = PufferTlog.Enum_TLog_From.UFS
        }
        PufferODPakManager:OnDownloadFinish(task, true, 0, false)
        PufferDownloader.diffList[fileName] = nil
      end
    end
    if not next(PufferDownloader.diffList) then
      log(bWriteLog and "PufferDownloader.CheckUFSDiffList. complete")
      PufferDownloader.RemoveDiffCheckTimer()
    end
  end, TIMER_INFINITE, 10)
end
function PufferDownloader.RemoveDiffCheckTimer()
  log(bWriteLog and "PufferDownloader.RemoveDiffCheckTimer.")
  local time_ticker = require("common.time_ticker")
  if PufferDownloader.diffCheckTimer then
    time_ticker.RemoveTimer(PufferDownloader.diffCheckTimer)
  end
end
function PufferDownloader.OnDownloadProgress(taskId, nowSize, totalSize)
  local processedFilestateList = {}
  if taskId == PufferDownloader.fileListPufferTaskID then
    for outterTaskID, filestate in pairs(PufferDownloader.filestateList) do
      if filestate.curStage == PufferDownloader.STAGE_FETCH_FILE_LIST then
        processedFilestateList[outterTaskID] = filestate
      end
    end
    for outterTaskID, filestate in pairs(processedFilestateList) do
      PufferDownloader.SyncProgressToCallback(filestate.outterTaskID, nowSize, totalSize, filestate.curStage)
    end
  elseif PufferDownloader.IsExtraJsonTaskID(taskId) then
    return
  elseif taskId == PufferDownloader.fileListAddtionalPufferTaskID or taskId == PufferDownloader.fileListPrefetchPufferTaskID then
    return
  elseif taskId == PufferDownloader.ODPaksBinPufferTaskID then
    return
  else
    local filestate = PufferDownloader.GetfilestateByPufferTaskID(taskId)
    if filestate == nil then
      log_error("PufferDownloader OnDownloadProgress pufferTaskID is not mapping to filestate")
      return
    end
    local outterTaskID = filestate.outterTaskID
    PufferDownloader.filestateList[outterTaskID].    PufferDownloader.filestateList[outterTaskID].  end
end
function PufferDownloader.ODPaksPostProcess()
  log(bWriteLog and "PufferDownloader.ODPaksPostProcess")
  PufferDownloader.ODPaksBinPufferTaskID = 0
  GCPufferDownloader.InitializeODPaks(Puffer)
  GCPufferDownloader.ClearUselessODPaks(Puffer)
end
function PufferDownloader.PufferJsonPostProcess()
  log(bWriteLog and "PufferDownloader.PufferJsonPostProcess PufferJsonDownloadReturn:" .. tostring(PufferDownloader.PufferJsonDownloadReturn))
  if PufferDownloader.PufferJsonDownloadReturn then
    return
  end
  local list = PufferDownloader.ReadPufferFileListJson()
  if list == nil or next(list) == nil then
    log(bWriteLog and "PufferDownloader.PufferJsonPostProcess GetPufferFileListJson fail")
    return
  end
  local logic_cost_collector = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cost_collector)
  logic_cost_collector:MarkIsolatedEventStart(logic_cost_collector.ISOLATED_EVENT_NAMES.PufferJsonPostProcess)
  Client.AddAttachFileString("PufferResState", false, tostring(list.version))
  Client.AddCrashContextData(1002, "PufferJsonPostProcess", false, 1200)
  local begintime = slua.getMiliseconds()
  PufferDownloader.InitODPakManager(function(existPaks)
    local PufferShaderManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_shader_manager)
    PufferShaderManager:InitShaderPaks()
    local PufferResManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_res_manager)
    PufferResManager:InitResPaks()
    PufferResManager:InitLobbyResPaks()
    local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
    PufferMapManager.bHaveInitMapPaks = false
    if GameStatus.IsInLobbyOrMainCity() or PufferDownloader.forceInitMapPaks == true then
      PufferDownloader.forceInitMapPaks = false
      PufferMapManager:InitMapPaks()
    end
    local PufferPrefetchManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_prefetch_manager)
    PufferPrefetchManager:InitPretechPaks(existPaks)
    local LogicPufferBundle = require("client.slua.logic.download.bundle.logic_puffer_bundle")
    LogicPufferBundle.needCheckSlap = true
    if next(LogicPufferBundle.bundles) then
      LogicPufferBundle:InitBundle()
    end
    local endtime = slua.getMiliseconds()
    log(bWriteLog and "raintest total cost time = " .. tostring(endtime - begintime))
    GCPufferDownloader.ClearUselessODPaks(Puffer)
    LobbySystem.RecreateActivityBanner()
    PufferDownloader.PufferJsonDownloadReturn = true
    log(bWriteLog and "PufferDownloader.PufferJsonPostProcess PufferJsonDownloadReturn:" .. tostring(PufferDownloader.PufferJsonDownloadReturn))
    local RecommendHandler = require("client.slua.logic.download.recommend.logic_recommend_handler")
    RecommendHandler.AutoDownload()
    RecommendHandler.AutoDownloadPaksByPriority()
    EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_LOBBY_DOWNLOAD)
    EventSystem:postEvent(EVENTTYPE_DOWNLOAD, EVENTID_PUFFER_JSON_POSTPROCESS)
    EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_DOWNLOAD_REFRESH)
    if GameStatus.GetGameStatus() ~= GameStatus.Login then
      PufferDownloader.RecordExistPaks = nil
    end
    logic_cost_collector:MarkIsolatedEventEnd(logic_cost_collector.ISOLATED_EVENT_NAMES.PufferJsonPostProcess)
  end)
end
function PufferDownloader.InitODPakManager(callback)
  log_format("PufferDownloader.InitODPakManager.")
  if PufferDownloader.InitODPakManagerCalled and PufferDownloader.RecordExistPaks then
    log_format("PufferDownloader.InitODPakManager. already called")
    if callback then
      callback(PufferDownloader.RecordExistPaks)
    end
    return
  end
  local PufferODPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
  local existPaks = {}
  if not PufferDownloader.RecordExistPaks then
    local ret = GCPufferDownloader.ReturnLocalFiles(PufferDownloader.DOWNLOAD_DIR_RELATIVE .. PufferDownloader.DOWNLOAD_ODPAKS_RELATIVE, "")
    local odpakNum = 0
    for _, filename in pairs(ret) do
      existPaks[PufferDownloader.DOWNLOAD_ODPAKS_RELATIVE .. filename] = true
      odpakNum = odpakNum + 1
    end
    local DownloadDelSystem = require("client.slua.logic.download.delete.logic_download_delete")
    DownloadDelSystem.    log(bWriteLog and "PufferDownloader.InitODPakManager. odpakNum = " .. tostring(odpakNum))
    PufferDownloader.RecordExistPaks = existPaks
  else
    existPaks = PufferDownloader.RecordExistPaks
  end
  log_format("PufferDownloader.InitODPakManager. isInitODPaks = %s", PufferODPakManager.isInitODPakData)
  PufferODPakManager:InitODPaks(existPaks, function(paks)
    local PufferUGCPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_ugcpak_manager)
    PufferUGCPakManager:InitPaks(paks)
    PufferUGCPakManager:OnPufferJsonPostProcess()
    logic_puffer_common.PufferFileItemData = {}
    PufferDownloader.InitODPakManagerCalled = true
    PufferDownloader.RecordExistPaks = existPaks
    if callback then
      callback(paks)
    end
    log_format("PufferDownloader.InitODPakManager. end")
  end)
end
function PufferDownloader.ShouldSlapDownloadVoice()
  log(bWriteLog and "PufferDownloader.ShouldSlapDownloadVoice")
  if not GlobalData.IsJapanOrKorea() then
    return false
  end
  if not GameStatus.IsInLobbyOrMainCity() then
    return false
  end
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPACK, {
    PufferConst.EODPackID.Audio
  })
  if state == PufferConst.ENUM_DownloadState.Done then
    return false
  end
  return true
end
function PufferDownloader.StopTask(gameFrontendHUD, outterTaskID)
  log(bWriteLog and "PufferDownloader StopTask: outterTaskID:" .. tostring(outterTaskID))
  local filestate = PufferDownloader.filestateList[outterTaskID]
  if filestate then
    filestate.suspended = true
    local stageToStop = filestate.curStage
    if stageToStop == PufferDownloader.STAGE_RETRY then
      if PufferDownloader.retryTimer then
        log(bWriteLog and "PufferDownloader StopTask: RemoveRetry Timer")
        local time_ticker = require("common.time_ticker")
        time_ticker.RemoveTimer(PufferDownloader.retryTimer)
        PufferDownloader.retryTimer = nil
      end
      stageToStop = filestate.retryStage
    end
    if stageToStop == PufferDownloader.STAGE_INITIALIZING then
      log(bWriteLog and "PufferDownloader StopTask: INITIALIZING nothing to process")
    elseif stageToStop == PufferDownloader.STAGE_FETCH_FILE_LIST then
      log(bWriteLog and "PufferDownloader StopTask: FETCH_FILE_LIST just let fetch finished")
    elseif stageToStop == PufferDownloader.STAGE_FILE_DOWNLOADING then
      log(bWriteLog and "PufferDownloader StopTask: FILE_DOWNLOADING stop download")
      if filestate.pufferTaskID ~= nil then
        GCPufferDownloader.StopTask(Puffer, filestate.pufferTaskID)
      end
    elseif stageToStop == PufferDownloader.STAGE_FILE_MERGING then
      log(bWriteLog and "PufferDownloader StopTask: FILE_MERGING merge thread became slient")
      filestate.slient = true
      return true
    elseif stageToStop == PufferDownloader.STAGE_FILE_CHECKING then
      log(bWriteLog and "PufferDownloader StopTask: FILE_CHECKING stop checking")
      GCPufferDownloader.StopCheckDownloadFileFraming(Puffer, outterTaskID)
    elseif stageToStop == PufferDownloader.STAGE_RETRY then
      log(bWriteLog and "PufferDownloader StopTask: RETRY do nothing")
    elseif stageToStop == PufferDownloader.STAGE_FINISH then
      log(bWriteLog and "PufferDownloader StopTask: FINISH Let it finish")
      return true
    end
    PufferDownloader.filestateList[filestate.outterTaskID] = nil
    log(bWriteLog and "PufferDownloader current filestateList")
    for k, v in pairs(PufferDownloader.filestateList) do
      log(bWriteLog and "PufferDownloader " .. tostring(k) .. " " .. tostring(v))
    end
  else
    log_error("PufferDownloader StopTask: unknownOutterTaskID:" .. tostring(outterTaskID))
  end
  return true
end
function PufferDownloader.GetFileSizeCompressed(gamefrontedendhud, filename, fullsize)
  filename = PufferDownloader.GetRealFilename(filename)
  if not PufferDownloader.IsFileListExist() or not filename then
    return 0
  end
  local downloadFilename = filename
  fullsize = fullsize or false
  if not fullsize then
    local filestate = PufferDownloader.FileState(filename)
    downloadFilename = PufferDownloader.GetTargetFilename(filestate)
  end
  if not downloadFilename then
    return 0
  end
  local fileSize = GCPufferDownloader.GetFileSizeCompressed(Puffer, downloadFilename)
  local PufferConst = require("client.slua.logic.download.puffer_const")
  if 0 < fileSize and fileSize < 0.1 * PufferConst.MB then
    fileSize = 0.1 * PufferConst.MB
  end
  return fileSize
end
function PufferDownloader.DeleteAllOldPak(target_prefix)
  local version = Client.GetApplicationVersion()
  if target_prefix == nil then
    target_prefix = ".+_.+_"
  end
  local ret = GCPufferDownloader.ReturnLocalFiles(PufferDownloader.DOWNLOAD_DIR_RELATIVE, "")
  for idx, filename in pairs(ret) do
    local prefix, localMapVersion = PufferDownloader.ParsePakName(filename)
    log(bWriteLog and "PufferDownloader DeleteAllOldPak parse local filename " .. filename .. " Prefix:" .. tostring(prefix) .. " versionNo " .. tostring(localMapVersion))
    if prefix ~= nil and localMapVersion ~= nil and string.match(prefix, target_prefix) ~= nil and PufferDownloader.CompareVersion(localMapVersion, version) < 0 then
      local filePath = Client.ProjectSavedDir() .. PufferDownloader.DOWNLOAD_DIR_RELATIVE .. filename
      GCPufferDownloader.DeleteFile(filePath)
      log(bWriteLog and "PufferDownloader DeleteAllOldPak delete filename " .. filePath)
    end
  end
end
function PufferDownloader:CheckAllMapPak(callback, target_prefix)
  local gem_report_utils = require("client.logic.store.gem_report_utils")
  if gem_report_utils.IsPublishVersion() then
    return true
  end
  log(bWriteLog and "CheckAllMapPak")
  local version = Client.GetApplicationVersion()
  if target_prefix == nil then
    target_prefix = ".+_.+_"
  end
  local ret = GCPufferDownloader.ReturnLocalFiles(PufferDownloader.DOWNLOAD_DIR_RELATIVE, "")
  for idx, filename in pairs(ret) do
    local prefix, localMapVersion = PufferDownloader.ParsePakName(filename)
    log(bWriteLog and "PufferDownloader CheckAllMapPak parse local filename " .. filename .. " Prefix:" .. tostring(prefix) .. " versionNo " .. tostring(localMapVersion))
    if prefix ~= nil and localMapVersion ~= nil and string.match(prefix, target_prefix) ~= nil and string.find(filename, PufferConst.MAP_PREFIX) ~= nil and PufferDownloader.CompareFront3PartVersion(localMapVersion, version) >= 0 and PufferDownloader.CompareVersion(localMapVersion, version) ~= 0 then
      local content = string.format("\229\173\152\229\156\168\229\156\176\229\155\190\232\181\132\230\186\144\228\184\142\229\174\162\230\136\183\231\171\175\231\137\136\230\156\172\228\184\141\229\140\185\233\133\141~(%s), \230\152\175\229\144\166\231\187\167\231\187\173?", filename)
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.Show(2, "Warning", content, function()
        if callback then
          if self then
            callback(self, true)
          else
            callback(true)
          end
        end
      end, function()
        if callback then
          if self then
            callback(self, false)
          else
            callback(false)
          end
        end
      end)
      return false
    end
  end
  return true
end
function PufferDownloader.UploadGemReport(errorCode, fileName, extraInfo, HDmpveInstanceId)
  local pufferID = GCPufferDownloader.GetProductID(Puffer)
  if not PufferDownloader.gemUploadBuildInfo then
    PufferDownloader.gemUploadBuildInfo = string.format("mode %s, buildTime %s, pufferID %s", tostring(global_package_make_time_map.Mode), string.gsub(tostring(global_package_make_time_map["Mfg. Date"]), ":", "_"), table.concat(pufferID, ","))
  end
  if not PufferDownloader.gemUploadSodaInfo then
    PufferDownloader.gemUploadSodaInfo = string.format("buildVersion %s", tostring(global_package_make_time_map.SODA_AutoBuild))
  end
  local param = {
    tostring(errorCode),
    string.format("fileName %s", fileName),
    extraInfo or "",
    tostring(PufferDownloader.PufferJsonDownloadReturn),
    string.format("freeSpace %s", tostring(Client.GetDeviceFreeSpace())),
    PufferDownloader.gemUploadBuildInfo,
    PufferDownloader.gemUploadSodaInfo,
    HDmpveInstanceId
  }
  Client.GEMReportSubEvent(GameFrontendHUD, "PufferEvent", "PufferDownloaderStateInfo", param)
end
function PufferDownloader.GEMReportSubEvent(SubEventName, array)
  return Client.GEMReportSubEvent(GameFrontendHUD, "PufferEvent", SubEventName, array)
end
function PufferDownloader.GetRealFilename(filename)
  if not filename then
    return ""
  end
  if string.find(filename, PufferDownloader.DOWNLOAD_ODPAKS_RELATIVE) ~= nil or string.find(filename, PufferDownloader.DOWNLOAD_UGCPAKS_RELATIVE) ~= nil or Client.IsFileExistsWithOutPakCheck(Client.ProjectSavedDir() .. PufferDownloader.DOWNLOAD_DIR_RELATIVE .. filename) or string.find(filename, PufferConst.PUFFERPATCH) ~= nil then
    return filename
  end
  local basename, ext = string.match(filename, "(.+)(%..+)")
  if not basename then
    log_error("PufferDownloader.GetRealFilename basename = nil filename = " .. filename)
    return filename
  end
  local table = PufferDownloader.GetPufferFileListJson()
  if table == nil or next(table) == nil then
    return filename
  end
  local versionMapping = table.version_mapping
  if not versionMapping then
    log_error("PufferDownloader.GetRealFilename parse json KEY version_mapping NOT found " .. filename)
    return filename
  end
  local retName = ""
  if not versionMapping[basename] then
    local prefix = string.match(basename, "(.+_.+_).*")
    if prefix == nil then
      log_error("PufferDownloader GetRealFilename Cant match name " .. tostring(filename))
      return filename
    end
    retName = versionMapping[prefix .. "default"]
    if retName == nil then
      log_warning("PufferDownloader GetRealFilename versionMapping do not have default value, filename = " .. filename)
      return filename
    end
  else
    retName = versionMapping[basename]
  end
  return retName .. ext
end
function PufferDownloader.IsFileExist(gamefrontendhud, filename)
  local realFilename = PufferDownloader.GetRealFilename(filename)
  return Client.IsFileExistsWithOutPakCheck(Client.ProjectSavedDir() .. PufferDownloader.DOWNLOAD_DIR_RELATIVE .. realFilename)
end
function PufferDownloader.IsFileExistByExtension(gamefrontendhud, filename, extension)
  local realFilename = PufferDownloader.GetRealFilename(filename)
  return Client.IsFileExistsWithOutPakCheck(Client.ProjectSavedDir() .. PufferDownloader.DOWNLOAD_DIR_RELATIVE .. realFilename)
end
function PufferDownloader.DeleteFile(filename)
  local realFilename = PufferDownloader.GetRealFilename(filename)
  local fullName = Client.ProjectSavedDir() .. PufferDownloader.DOWNLOAD_DIR_RELATIVE .. realFilename
  log(bWriteLog and "PufferDownloader.DeleteFile " .. filename .. " (i.e. " .. realFilename .. ")")
  return GCPufferDownloader.DeleteFile(fullName)
end
function PufferDownloader.RefreshDownloadInBattleSwitch()
  local UIUtil = require("client.common.ui_util")
  local gameInstance = UIUtil.GetGameInstance()
  local deviceLevel = gameInstance:GetExactDeviceLevel()
  PufferDownloader.DisableInBattle = deviceLevel < PufferDownloader.DisableInBattleThreshold
  log(bWriteLog and "PufferDownloader.DeviceLevel " .. tostring(deviceLevel))
  log(bWriteLog and "PufferDownloader.DisableInBattle " .. tostring(PufferDownloader.DisableInBattle))
end
function PufferDownloader.triggerDownloadLobbyRes(ItemType, ItemID)
  local UBackpackUtils_C = import("BackpackUtils")
  local itemDefineID = FItemDefineID(ItemType, tostring(ItemID))
  local uBackpackUtils = UBackpackUtils_C.GetBPUtils()
  local LobbyResPath = uBackpackUtils:GetBattleItemHandlePath(itemDefineID, true, true)
  if LobbyResPath and LobbyResPath ~= "" then
    LobbyResPath = StringUtil.Split(LobbyResPath, ".")[1]
    log(bWriteLog and "Lobby Show res Path:" .. LobbyResPath)
    local exist = GCPufferDownloader.IsODFileExists(Puffer, LobbyResPath)
    if not exist then
      log(bWriteLog and "Lobby trigger download res:" .. LobbyResPath)
      local PufferConst = require("client.slua.logic.download.puffer_const")
      local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
      PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {LobbyResPath})
      return true
    end
  end
  return false
end
function PufferDownloader.CompareFront3PartVersion(version1, version2)
  local verArray1 = StringUtil.Split(version1, ".")
  local verArray2 = StringUtil.Split(version2, ".")
  verArray1[4] = "1000"
  verArray2[4] = "1000"
  verArray1 = table.concat(verArray1, ".")
  verArray2 = table.concat(verArray2, ".")
  local res = PufferDownloader.CompareVersion(verArray1, verArray2)
  return res
end
function PufferDownloader.GetPufferCheckInfo()
  local json = logic_puffer_common.PufferFileListJson
  if json == nil or next(json) == nil then
    return "Error:PufferFileListJson is Empty"
  end
  if not json.version then
    return "Error:PufferFileListJson version is Null"
  end
  local strInfo = ""
  local jsonVersion = json.version
  local appVersion = Client.GetApplicationVersion()
  if jsonVersion ~= appVersion then
    strInfo = strInfo .. "Puffer\232\181\132\230\186\144\228\184\142\229\174\162\230\136\183\231\171\175\231\137\136\230\156\172\228\184\141\229\140\185\233\133\141\239\188\129\232\166\129\228\189\147\233\170\140\229\174\140\230\149\180\229\149\134\228\184\154\229\140\150\232\181\132\230\186\144\239\188\140\232\175\183\228\189\191\231\148\168\229\140\185\233\133\141\231\137\136\230\156\172\239\188\129\n"
  end
  if json.PipeLineID then
    local pufferID = GCPufferDownloader.GetProductID(Puffer)
    local pufferIDStr
    if pufferID then
      pufferIDStr = table.concat(pufferID, ",")
    else
      pufferIDStr = "invalid"
    end
    strInfo = strInfo .. "PufferVersion:" .. tostring(jsonVersion) .. "\n" .. "AppVersion:" .. tostring(appVersion) .. "\n" .. "BuildNo:" .. tostring(json.BuildNo) .. "\n" .. "PipeLineID:" .. tostring(json.PipeLineID) .. "\n" .. "HostName:" .. tostring(json.HostName) .. "\n" .. "BuildTime:" .. tostring(json.BuildTime) .. "\n" .. "PufferID:" .. pufferIDStr .. "\n"
  end
  return strInfo
end
function PufferDownloader.SetDownloadKeyRecord(key, done)
  if not key then
    return
  end
  local preValue = PufferDownloader.DownloadKeyRecord[key] or false
  if preValue ~= done then
    log(bWriteLog and string.format("PufferDownloader.SetDownloadKeyRecord. key=%s, done=%s", tostring(key), tostring(done)))
    PufferDownloader.DownloadKeyRecord[key] = done
    PufferDownloader.SaveDownloadKeyRecord()
  end
end
local UBackpackUtils = import("BackpackUtils")
function PufferDownloader.SetPakExist(path, exist)
  if not PufferDownloader.EnableBackpackCache or path == "" or path == nil then
    return
  end
  if UBackpackUtils.SetPakExist then
    log(bWriteLog and string.format("PufferDownloader.SetPakExist. path=%s, exist=%s", tostring(path), tostring(exist)))
    UBackpackUtils.SetPakExist(path, exist)
  end
end
function PufferDownloader.GetPakExist(pakName, skipCache)
  if pakName == "" or pakName == nil then
    return false
  end
  local isPakExist = false
  if PufferDownloader.EnableBackpackCache and not skipCache and UBackpackUtils.GetPakExist then
    isPakExist = UBackpackUtils.GetPakExist(pakName)
  else
    local PufferConst = require("client.slua.logic.download.puffer_const")
    isPakExist = Client.IsFileExistsWithOutPakCheck(Client.ProjectSavedDir() .. PufferConst.PAKS_RELATIVE_DIR .. pakName)
    PufferDownloader.SetPakExist(pakName, isPakExist)
  end
  return isPakExist
end
function PufferDownloader.ClearPakPathMap()
  if UBackpackUtils.ClearPakPathMap then
    log(bWriteLog and "PufferDownloader.ClearPakPathMap.")
    UBackpackUtils.ClearPakPathMap()
  end
end
function PufferDownloader.ClearPakCache(pakName)
  if UBackpackUtils.ClearPakCache then
    log(bWriteLog and string.format("PufferDownloader.ClearPakCache. pakName=%s", tostring(pakName)))
    UBackpackUtils.ClearPakCache(pakName)
  end
end
function PufferDownloader.SetEnableBackpackCache(val)
  log(bWriteLog and string.format("PufferDownloader.SetEnableBackpackCache. val=%s", tostring(val)))
  if val == PufferDownloader.backpackCacheVal then
    log(bWriteLog and "PufferDownloader.SetEnableBackpackCache. same val")
    return
  end
  if val == nil then
    val = 0
  end
  PufferDownloader.backpackCacheVal = val
  PufferDownloader.EnableBackpackCache = 0 < val
  local UIUtil = require("client.common.ui_util")
  local UGameInstance = UIUtil.GetGameInstance()
  UGameInstance:ExecuteCMD("backpack.EnableBackpackPakCache", val)
end
return PufferDownloader