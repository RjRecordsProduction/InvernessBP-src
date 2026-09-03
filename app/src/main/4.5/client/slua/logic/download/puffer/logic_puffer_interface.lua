PufferInterface = PufferInterface or {}
PufferInterface.INPROGRESS_PAK_SUFFIX = "_inprog"
PufferInterface.DOWNLOAD_DIR_RELATIVE = "Paks/"
PufferInterface.maxOutterTaskID = 1
PufferInterface.MAX_RETRY_TIMES = 3
PufferInterface.INVALID_FILE_ID = -1
PufferInterface.INVALID_TASK_ID = -1
PufferInterface.STAGE_INITIALIZING = 1
PufferInterface.STAGE_FILE_DOWNLOADING = 3
PufferInterface.STAGE_FILE_MERGING = 4
PufferInterface.STAGE_FILE_CHECKING = 5
PufferInterface.STAGE_RETRY = 6
PufferInterface.STAGE_FINISH = 7
PufferInterface.STAGE_PRECHECK_OLDFILE = 8
PufferInterface.STAGE_GET_DIFFERFILE = 9
PufferInterface.STAGE_MOUNTING = 10
PufferInterface.ERR_INVALID_TASK_ID = 1
PufferInterface.ERR_NOT_INITIALIZED = 2
PufferInterface.ERR_CHECK_FILE_FAILED = 3
PufferInterface.ERR_REQUEST_DUPLICATE = 4
PufferInterface.ERR_DIFFERFILE_NOT_FOUND = 5
PufferInterface.ERR_SELFDEFINE_MAX = 16
PufferInterface.ERR_DIFF_NOT_EXIST = 17
PufferInterface.filestateList = {}
PufferInterface.outterTaskIDFilenameMapping = {}
PufferInterface.InitCallbackFuncList = {}
PufferInterface.InitProgressCallbackFuncList = {}
PufferInterface.ErrReportNameMap = {}
PufferInterface.ParallelActSerialMode = false
PufferInterface.retryTimes = 0
local TimeUtil = require("client.common.time_util")
local logic_puffer_common = require("client.slua.logic.download.puffer.logic_puffer_common")
local MergeFileFSM = function(filestate, isSucessed)
  log(bWriteLog and "MergeFileFSM last stage is " .. tostring(isSucessed) .. " turn to Stage:")
  if filestate.curStage == PufferInterface.STAGE_INITIALIZING then
    filestate.startTime = TimeUtil.OSTime()
    if isSucessed then
      PufferInterface.PufferStageFunction[PufferInterface.STAGE_GET_DIFFERFILE](filestate)
    end
  elseif filestate.curStage == PufferInterface.STAGE_GET_DIFFERFILE then
    if isSucessed then
      filestate.downloadStartTime = TimeUtil.OSTime()
      filestate.mergeStartTime = TimeUtil.OSTime()
      PufferInterface.PufferStageFunction[PufferInterface.STAGE_FILE_MERGING](filestate)
    else
      filestate.EndTime = TimeUtil.OSTime()
      PufferInterface.PufferStageFunction[PufferInterface.STAGE_FINISH](filestate)
    end
  elseif filestate.curStage == PufferInterface.STAGE_FILE_MERGING then
    if isSucessed then
      PufferInterface.PufferStageFunction[PufferInterface.STAGE_FILE_CHECKING](filestate)
    else
      filestate.EndTime = TimeUtil.OSTime()
      PufferInterface.PufferStageFunction[PufferInterface.STAGE_FINISH](filestate)
    end
  elseif filestate.curStage == PufferInterface.STAGE_FILE_CHECKING then
    filestate.EndTime = TimeUtil.OSTime()
    PufferInterface.PufferStageFunction[PufferInterface.STAGE_FINISH](filestate)
  else
    filestate.EndTime = TimeUtil.OSTime()
    PufferInterface.PufferStageFunction[PufferInterface.STAGE_FINISH](filestate)
  end
end
local DifferDownloadWithoutMergeFSM = function(filestate, isSucessed)
  log(bWriteLog and "DifferDownloadFSM last stage is " .. tostring(isSucessed) .. " turn to Stage:")
  if filestate.curStage == PufferInterface.STAGE_INITIALIZING then
    filestate.startTime = TimeUtil.OSTime()
    if isSucessed then
      PufferInterface.PufferStageFunction[PufferInterface.STAGE_GET_DIFFERFILE](filestate)
    end
  elseif filestate.curStage == PufferInterface.STAGE_GET_DIFFERFILE then
    if isSucessed then
      filestate.downloadStartTime = TimeUtil.OSTime()
      PufferInterface.PufferStageFunction[PufferInterface.STAGE_FILE_DOWNLOADING](filestate, filestate.diffFilename)
    else
      filestate.EndTime = TimeUtil.OSTime()
      PufferInterface.PufferStageFunction[PufferInterface.STAGE_FINISH](filestate)
    end
  elseif filestate.curStage == PufferInterface.STAGE_FILE_DOWNLOADING then
    if isSucessed then
      filestate.mergeStartTime = TimeUtil.OSTime()
      PufferInterface.PufferStageFunction[PufferInterface.STAGE_FINISH](filestate, false)
    else
      PufferInterface.PufferStageFunction[PufferInterface.STAGE_RETRY](filestate)
    end
  else
    filestate.EndTime = TimeUtil.OSTime()
    PufferInterface.PufferStageFunction[PufferInterface.STAGE_FINISH](filestate)
  end
end
local DifferDownloadFSM = function(filestate, isSucessed)
  log(bWriteLog and "DifferDownloadFSM last stage is " .. tostring(isSucessed) .. " turn to Stage:")
  if filestate.curStage == PufferInterface.STAGE_INITIALIZING then
    filestate.startTime = TimeUtil.OSTime()
    if isSucessed then
      PufferInterface.PufferStageFunction[PufferInterface.STAGE_GET_DIFFERFILE](filestate)
    end
  elseif filestate.curStage == PufferInterface.STAGE_GET_DIFFERFILE then
    if isSucessed then
      filestate.downloadStartTime = TimeUtil.OSTime()
      PufferInterface.PufferStageFunction[PufferInterface.STAGE_FILE_DOWNLOADING](filestate, filestate.diffFilename)
    else
      filestate.EndTime = TimeUtil.OSTime()
      PufferInterface.PufferStageFunction[PufferInterface.STAGE_FINISH](filestate)
    end
  elseif filestate.curStage == PufferInterface.STAGE_FILE_DOWNLOADING then
    if isSucessed then
      filestate.mergeStartTime = TimeUtil.OSTime()
      PufferInterface.PufferStageFunction[PufferInterface.STAGE_FILE_MERGING](filestate)
    else
      PufferInterface.PufferStageFunction[PufferInterface.STAGE_RETRY](filestate)
    end
  elseif filestate.curStage == PufferInterface.STAGE_FILE_MERGING then
    if isSucessed then
      PufferInterface.PufferStageFunction[PufferInterface.STAGE_FILE_CHECKING](filestate)
    else
      filestate.EndTime = TimeUtil.OSTime()
      PufferInterface.PufferStageFunction[PufferInterface.STAGE_FINISH](filestate)
    end
  elseif filestate.curStage == PufferInterface.STAGE_FILE_CHECKING then
    filestate.EndTime = TimeUtil.OSTime()
    PufferInterface.PufferStageFunction[PufferInterface.STAGE_FINISH](filestate)
  else
    filestate.EndTime = TimeUtil.OSTime()
    PufferInterface.PufferStageFunction[PufferInterface.STAGE_FINISH](filestate)
  end
end
local NormalDownloadFSM = function(filestate, isSucessed)
  log(bWriteLog and "NormalDownloadFSM last stage is " .. tostring(isSucessed) .. " turn to Stage:")
  if filestate.curStage == PufferInterface.STAGE_INITIALIZING then
    filestate.startTime = TimeUtil.OSTime()
    if isSucessed then
      filestate.downloadStartTime = TimeUtil.OSTime()
      PufferInterface.PufferStageFunction[PufferInterface.STAGE_FILE_DOWNLOADING](filestate)
    end
  elseif filestate.curStage == PufferInterface.STAGE_FILE_DOWNLOADING then
    if isSucessed then
      filestate.EndTime = TimeUtil.OSTime()
      PufferInterface.PufferStageFunction[PufferInterface.STAGE_FINISH](filestate)
    else
      PufferInterface.PufferStageFunction[PufferInterface.STAGE_RETRY](filestate)
    end
  else
    filestate.EndTime = TimeUtil.OSTime()
    PufferInterface.PufferStageFunction[PufferInterface.STAGE_FINISH](filestate)
  end
end
local DefaultFSM = function(filestate, isSucessed)
  log(bWriteLog and "[LogicPufferInterfaceLUA] fsm is not initialized")
end
PufferInterface.PufferStageFunction = {
  [PufferInterface.STAGE_INITIALIZING] = function(filestate)
    log(bWriteLog and "[LogicPufferInterfaceLUA] PufferStageFunction STAGE_INITIALIZING")
    PufferInterface.RequestFile(GameFrontendHUD, filestate.filename, filestate.forceUpdate)
  end,
  [PufferInterface.STAGE_FILE_DOWNLOADING] = function(filestate, downloadFileName)
    log(bWriteLog and "[LogicPufferInterfaceLUA] PufferStageFunction STAGE_FILE_DOWNLOADING")
    PufferInterface.DownloadFileImp(filestate, downloadFileName)
  end,
  [PufferInterface.STAGE_FILE_MERGING] = function(filestate)
    log(bWriteLog and "[LogicPufferInterfaceLUA] PufferStageFunction STAGE_FILE_MERGING")
    PufferInterface.MergeFile(filestate)
  end,
  [PufferInterface.STAGE_FILE_CHECKING] = function(filestate)
    log(bWriteLog and "[LogicPufferInterfaceLUA] PufferStageFunction STAGE_FILE_CHECKING")
    PufferInterface.CheckFile(filestate)
  end,
  [PufferInterface.STAGE_RETRY] = function(filestate)
    log(bWriteLog and "[LogicPufferInterfaceLUA] PufferStageFunction STAGE_RETRY")
    PufferInterface.RetryCurStage(filestate)
  end,
  [PufferInterface.STAGE_FINISH] = function(filestate, clearDiff)
    log(bWriteLog and "[LogicPufferInterfaceLUA] PufferStageFunction STAGE_FINISH")
    PufferInterface.FinishRequestFile(filestate, clearDiff)
  end,
  [PufferInterface.STAGE_GET_DIFFERFILE] = function(filestate)
    log(bWriteLog and "[LogicPufferInterfaceLUA] PufferStageFunction STAGE_GET_DIFFERFILE")
    PufferInterface.GetDifferFile(filestate)
  end
}
function PufferInterface.FileState(filename, forceUpdate, FSMFunction, successCallback, errorCallback, progressCallback)
  log(bWriteLog and "PufferInterface.FileState maxOutterTaskID=" .. PufferInterface.maxOutterTaskID)
  local val = {
    outterTaskID = PufferInterface.maxOutterTaskID,
    filename = filename,
    forceUpdate = forceUpdate or false,
    curStage = PufferInterface.STAGE_INITIALIZING,
    pufferTaskID = PufferInterface.INVALID_TASK_ID,
    retryTimes = 0,
    retryStage = 0,
    lastErrno = 0,
    lastErrStage = 0,
    diffFilename = nil,
    oldFilename = nil,
    mergePassedProg = 0,
    mergeTotalProg = 1,
    slient = false,
    preCheckPassed = nil,
    RunNextStage = FSMFunction or DefaultFSM,
    successCallback = successCallback,
    errorCallback = errorCallback,
    progressCallback = progressCallback,
    startTime = 0,
    downloadStartTime = 0,
    mergeStartTime = 0,
    EndTime = 0
  }
  local metaTable = {
    __tostring = function(t)
      local str = "{ outterTaskID = %d, filename = %s, forceUpdate = %s, curStage = %d, pufferTaskID = %d, retryTimes = %d, retryStage = %d, lastErrno=%d, lastErrStage = %s, diffFilename=%s, oldFilename=%s, mergePassedProg=%f, mergeTotalProg=%f, slient=%s, preCheckPassed=%s, startTime = %s, downloadStartTime = %s, mergeStartTime = %s, EndTime= %s }"
      return string.format(str, t.outterTaskID, t.filename, t.forceUpdate, t.curStage, t.pufferTaskID, t.retryTimes, t.retryStage, t.lastErrno, t.lastErrStage, t.diffFilename, t.oldFilename, t.mergePassedProg, t.mergeTotalProg, t.slient, t.preCheckPassed, t.startTime, t.downloadStartTime, t.mergeStartTime, t.EndTime)
    end
  }
  PufferInterface.maxOutterTaskID = PufferInterface.maxOutterTaskID + 1
  return setmetatable(val, metaTable)
end
function PufferInterface.OnInitProgress(stage, curSize, totalSize, PufferInstID)
  log_format("PufferInterface.OnInitProgress. stage=%s, curSize=%s, totalSize=%s, PufferInstID=%s", stage, curSize, totalSize, PufferInstID)
  if totalSize == nil then
    totalSize = curSize
    curSize = stage
  end
  for k, v in ipairs(PufferInterface.InitProgressCallbackFuncList) do
    v(curSize, totalSize)
  end
end
function PufferInterface.OnInitReturn(isSuccess, errorCode)
  for k, v in ipairs(PufferInterface.InitCallbackFuncList) do
    v(isSuccess, errorCode)
  end
  PufferInterface.InitCallbackFuncList = {}
  PufferInterface.InitProgressCallbackFuncList = {}
end
function PufferInterface.DownloadFilelist(successCallback, errorCallback, progressCallback)
  PufferInterface.RequestFile(nil, logic_puffer_common.GetPufferFileListName(), NormalDownloadFSM, successCallback, errorCallback, progressCallback, true)
end
function PufferInterface.DifferDownloadFile(filename, successCallback, errorCallback, progressCallback)
  return PufferInterface.RequestFile(nil, filename, DifferDownloadFSM, successCallback, errorCallback, progressCallback, false)
end
function PufferInterface.DifferDownloadWithoutMergeFile(filename, successCallback, errorCallback, progressCallback)
  return PufferInterface.RequestFile(nil, filename, DifferDownloadWithoutMergeFSM, successCallback, errorCallback, progressCallback, false)
end
function PufferInterface.MergeDownloadFile(filename, successCallback, errorCallback, progressCallback)
  return PufferInterface.RequestFile(nil, filename, MergeFileFSM, successCallback, errorCallback, progressCallback, false, true)
end
function PufferInterface.NormalDownloadFile(filename, successCallback, errorCallback, progressCallback)
  return PufferInterface.RequestFile(nil, filename, NormalDownloadFSM, successCallback, errorCallback, progressCallback, false)
end
function PufferInterface.RequestFile(gameFrontendHUD, filename, FSMFunction, successCallback, errorCallback, progressCallback, forceUpdate, bNotCheck)
  if not bNotCheck and not PufferInterface.ShowNoEnoughSpaceTips(filename) then
    return false
  end
  if not GCPufferDownloader.IsInitSuccess(Puffer) then
    return false
  end
  log(bWriteLog and "[LogicPufferInterfaceLUA] RequestFile start")
  local filestate = PufferInterface.GetfilestateByFilename(filename)
  if filestate == nil then
    filestate = PufferInterface.FileState(filename, forceUpdate, FSMFunction, successCallback, errorCallback, progressCallback)
    log(bWriteLog and "PufferInterface.RequestFile outterTaskIDFilenameMapping")
    local outterTaskID = PufferInterface.outterTaskIDFilenameMapping[filename]
    if outterTaskID ~= nil then
      filestate.    else
      PufferInterface.outterTaskIDFilenameMapping[filename] = filestate.outterTaskID
    end
    log(bWriteLog and "[LogicPufferInterfaceLUA] RequestFile new filestate: " .. tostring(filestate))
    log(bWriteLog and "[LogicPufferInterfaceLUA] RequestFile After create new filestate. maxOutterTaskID=" .. PufferInterface.maxOutterTaskID)
    PufferInterface.filestateList[filestate.outterTaskID] = filestate
    filestate.curStage = PufferInterface.STAGE_INITIALIZING
    return true
  else
    log(bWriteLog and "[LogicPufferInterfaceLUA] RequestFile duplicated " .. tostring(filestate))
    return false
  end
end
function PufferInterface.SetImmDLTaskConfig(downloadType)
  local PufferConfigSys = require("client.slua.logic.download.puffer.puffer_config")
  local maxTask, maxDownloadsPerTask = PufferConfigSys.GetImmDLTaskConfig(downloadType)
  local result1 = GCPufferDownloader.SetImmDLMaxTask(Puffer, maxTask)
  local reuslt2 = GCPufferDownloader.SetImmDLMaxDownloadsPerTask(Puffer, maxDownloadsPerTask)
  GCPufferDownloader.SetImmDLMaxSpeed(Puffer, 104857600)
  local PufferConfigSys = require("client.slua.logic.download.puffer.puffer_config")
  local PollintTime = PufferConfigSys.GetImmDLPollingTime(PufferConfigSys.DOWNLOAD_PHASE.BASE)
  GCPufferDownloader.SetImmDLPollingTime(Puffer, PollintTime)
  local PufferDefine = require("client.slua.logic.download.puffer.puffer_define")
  GCPufferDownloader.DynamicAdjustPufferSystemParameter(Puffer, PufferDefine.PufferSystemParameterKey.PufferHttpCurlRecvBufferSize, PufferConfigSys.GetCurlBuffSize())
  return result1 and reuslt2
end
function PufferInterface.GetPufferUA(resType)
  local PufferConfigSys = require("client.slua.logic.download.puffer.puffer_config")
  return PufferConfigSys:GetPufferUA(resType)
end
function PufferInterface.DownloadFileImp(filestate, downloadFileName)
  filestate.curStage = PufferInterface.STAGE_FILE_DOWNLOADING
  filestate.downloadStartTime = TimeUtil.OSTime()
  local downloadType = filestate.downloadType or PufferInterface.GetDownloadTypeByFileName(filestate.filename)
  if not PufferInterface.SetImmDLTaskConfig(downloadType) then
    log(bWriteLog and "PufferDownloader.DownloadFileImp: failed to set ImmDLTaskCfg")
  end
  log(bWriteLog and "[LogicPufferInterfaceLUA] DownloadFileImp start download:" .. tostring(filestate.filename))
  local PufferUA = PufferInterface.GetPufferUA(downloadType)
  local taskID = GCPufferDownloader.RequestFile(Puffer, downloadFileName or filestate.filename, filestate.forceUpdate, PufferUA)
  log(bWriteLog and "[LogicPufferInterfaceLUA] DownloadFileImp start download: pufferTaskID" .. tostring(taskID))
  filestate.pufferTaskID = taskID
  if taskID == PufferInterface.INVALID_TASK_ID then
    log_error("[LogicPufferInterfaceLUA] DownloadFileImp RequestFile Failed")
    filestate.lastErrno = PufferInterface.ERR_INVALID_TASK_ID
    filestate.lastErrStage = PufferInterface.STAGE_FILE_DOWNLOADING
    return filestate.RunNextStage(filestate, false)
  end
end
function PufferInterface.OnDownloadReturn(taskId, isSuccess, errorCode)
  local PufferQuic = require("client.slua.logic.download.puffer.puffer_quic")
  PufferQuic:OnDownloadReturn(taskId, isSuccess, errorCode)
  local filestate = PufferInterface.GetfilestateByPufferTaskID(taskId)
  if filestate == nil then
    log_error("[LogicPufferInterfaceLUA] OnDownloadReturn pufferTaskID is not mapping to filestate " .. tostring(taskId))
    return
  end
  log(bWriteLog and "[LogicPufferInterfaceLUA] OnDownloadReturn: isSuccess " .. tostring(isSuccess))
  if isSuccess == false then
    log_error("[LogicPufferInterfaceLUA] OnDownloadReturn Error:" .. tostring(errorCode))
    filestate.lastErrno = errorCode
    filestate.lastErrStage = PufferInterface.STAGE_FILE_DOWNLOADING
  end
  local time_ticker = require("common.time_ticker")
  time_ticker.AddTimerOnce(0, function()
    filestate.RunNextStage(filestate, isSuccess)
  end)
end
function PufferInterface.MergeFile(filestate)
  log(bWriteLog and "[LogicPufferInterfaceLUA] MergeFile Start Merge")
  filestate.curStage = PufferInterface.STAGE_FILE_MERGING
  PufferInterface.SyncProgressToCallback(filestate.outterTaskID, 0, 100, filestate.curStage)
  log(bWriteLog and "[LogicPufferInterfaceLUA] MergeFile " .. tostring(filestate))
  local downloadPath = GCPufferDownloader.GetDownloadPath(Puffer)
  local oldFileSize = GCPufferDownloader.GetFileSize(Puffer, downloadPath .. filestate.oldFilename)
  local diffFileSize = GCPufferDownloader.GetFileSize(Puffer, downloadPath .. filestate.diffFilename)
  local newFileSize = GCPufferDownloader.GetFileSizeCompressed(Puffer, filestate.filename)
  if oldFileSize == -1 or diffFileSize == -1 or newFileSize == -1 then
    log_error("[LogicPufferInterfaceLUA] MergeFile GetFileSizeFailed oldFile:" .. tostring(filestate.oldFilename) .. " " .. tostring(filestate.oldFileSize) .. " diffFile:" .. tostring(filestate.diffFilename) .. " " .. tostring(filestate.diffFileSize))
    filestate.mergeTotalProg = -1
    filestate.lastErrno = PufferInterface.ERR_DIFF_NOT_EXIST
    filestate.lastErrStage = PufferInterface.STAGE_FILE_MERGING
    return filestate.RunNextStage(filestate, false)
  else
    filestate.mergeTotalProg = newFileSize / 1024.0
    GCPufferDownloader.MergeBinDiffPak(Puffer, filestate.outterTaskID, downloadPath .. filestate.oldFilename, downloadPath .. filestate.diffFilename, downloadPath .. filestate.filename .. PufferInterface.INPROGRESS_PAK_SUFFIX, true)
  end
end
function PufferInterface.OnMergeBinDiffPakReturn(outterTaskID, errorCode)
  log(bWriteLog and "[LogicPufferInterfaceLUA] MergeFile Merge return outterTaskID:" .. tostring(outterTaskID) .. " errorCode:" .. tostring(errorCode))
  local filestate = PufferInterface.filestateList[outterTaskID]
  if filestate == nil then
    log_error("[LogicPufferInterfaceLUA] OnMergeBinDiffPakReturn cannot find correspond filestate for merge callback or the filestate is suspended" .. tostring(outterTaskID) .. "MergeErrorCode:" .. errorCode)
    return
  end
  log(bWriteLog and "[LogicPufferInterfaceLUA] OnMergeBinDiffPakReturn filestate " .. tostring(filestate))
  PufferInterface.SyncProgressToCallback(filestate.outterTaskID, 100, 100, filestate.curStage)
  if errorCode == 0 then
    return filestate.RunNextStage(filestate, true)
  else
    filestate.lastErrno = errorCode
    filestate.lastErrStage = PufferInterface.STAGE_FILE_MERGING
    return filestate.RunNextStage(filestate, false)
  end
end
function PufferInterface.CheckFile(filestate)
  filestate.curStage = PufferInterface.STAGE_FILE_CHECKING
  PufferInterface.SyncProgressToCallback(filestate.outterTaskID, 0, 100, filestate.curStage)
  log(bWriteLog and "[LogicPufferInterfaceLUA] CheckFile start check File" .. tostring(filestate))
  local downloadPath = GCPufferDownloader.GetDownloadPath(Puffer)
  GCPufferDownloader.CheckDownloadFileFraming(Puffer, filestate.outterTaskID, downloadPath .. filestate.filename .. PufferInterface.INPROGRESS_PAK_SUFFIX, 4194304)
end
function PufferInterface.OnHashGenerateFinished(outterTaskID, hashcode)
  log(bWriteLog and "[LogicPufferInterfaceLUA] CheckFile return outterTaskID:" .. tostring(outterTaskID) .. " hashCode:" .. tostring(hashcode))
  local filestate = PufferInterface.filestateList[outterTaskID]
  if filestate == nil then
    log_error("[LogicPufferInterfaceLUA] OnHashGenerateFinished cannot find correspond filestate for hashGen callback " .. tostring(outterTaskID))
    return
  end
  local checkList = PufferInterface.GetPufferFileListJson().check_list or {}
  local checkPassed = false
  if checkList[filestate.filename] == nil or #checkList[filestate.filename] == 0 then
    log_warning("[LogicPufferInterfaceLUA] CheckFile skip check, because checkList does not contain corresponding Hash" .. tostring(filestate))
    checkPassed = true
  else
    for i = 1, #checkList[filestate.filename] do
      log(bWriteLog and "[LogicPufferInterfaceLUA] CheckFile: targetHash=" .. tostring(checkList[filestate.filename][i]))
      if string.lower(checkList[filestate.filename][i]) == string.lower(hashcode) then
        checkPassed = true
      end
    end
    if not checkPassed then
      filestate.lastErrno = PufferInterface.ERR_CHECK_FILE_FAILED
      filestate.lastErrStage = PufferInterface.STAGE_FILE_CHECKING
    end
  end
  if checkPassed then
    local downloadPath = GCPufferDownloader.GetDownloadPath(Puffer)
    log(bWriteLog and "[LogicPufferDownloaderLUA] CheckFile: move file from " .. tostring(downloadPath .. filestate.filename .. PufferInterface.INPROGRESS_PAK_SUFFIX) .. " " .. tostring(downloadPath .. filestate.filename))
    local ret = GCPufferDownloader.MoveFile(Puffer, downloadPath .. filestate.filename .. PufferInterface.INPROGRESS_PAK_SUFFIX, downloadPath .. filestate.filename)
    if ret ~= 0 then
      log_error("[LogicPufferPufferInterfaceLUA] OnMergeBinDiffPakReturn MoveFileTo Operation Error " .. tostring(ret) .. "From:" .. tostring(filestate.filename .. PufferInterface.INPROGRESS_PAK_SUFFIX) .. "To:" .. tostring(downloadPath .. filestate.filename))
      filestate.lastErrno = ret
      filestate.lastErrStage = PufferInterface.STAGE_FILE_CHECKING
      return filestate.RunNextStage(filestate, false)
    end
  end
  return filestate.RunNextStage(filestate, checkPassed)
end
function PufferInterface.ReInitializePuffer()
  log_shipping_client("PufferInterface.PufferReinitialize Start trigger")
  local filePath = Client.ProjectSavedDir() .. PufferDownloader.DOWNLOAD_DIR_RELATIVE .. logic_puffer_common.GetPufferFileListName()
  GCPufferDownloader.DeleteFile(filePath)
  logic_puffer_common.ProcessDownloadEifsInBase()
  local PufferConfigSys = require("client.slua.logic.download.puffer.puffer_config")
  local PufferConfig = PufferConfigSys:GetDefaultConfig(PufferConfigSys.DOWNLOAD_PHASE.BASE)
  Client.ReInitializePuffer(GameFrontendHUD, false, PufferConfig.MaxDownloadsPerTask, PufferConfig.MaxDownTask, PufferConfig.MaxDownloadSpeed, false, false, 1, PufferConfig.PufferDownloadFuncDict, PufferConfig.HttpDnsType, PufferConfig.DownloadStageType, PufferConfig.DownloadEngineType)
  log_shipping_client("PufferInterface.PufferReinitialize trigger end")
end
function PufferInterface.RetryCurStage(filestate)
  log(bWriteLog and "[LogicPufferInterfaceLUA] RetryCurStage: filestate ??" .. tostring(filestate))
  if PufferInterface.filestateList[filestate.outterTaskID] == nil then
    log(bWriteLog and "[LogicPufferInterfaceLUA] RetryCurStage: outerTask:" .. filestate.outterTaskID .. " has been stopped do not continue retrying")
    return
  end
  filestate.retryStage = filestate.curStage
  filestate.curStage = PufferInterface.STAGE_RETRY
  filestate.retryTimes = filestate.retryTimes + 1
  log(bWriteLog and "[LogicPufferInterfaceLUA] RetryCurStage: filestate " .. tostring(filestate))
  if filestate.retryTimes >= PufferInterface.MAX_RETRY_TIMES then
    log(bWriteLog and "[LogicPufferInterfaceLUA] RetryCurStage: Over Max RetryTimes ")
    return filestate.RunNextStage(filestate, false)
  end
  if PufferInterface.ParallelActSerialMode then
    PufferInterface.retryTimes = PufferInterface.retryTimes + 1
    log(bWriteLog and "[LogicPufferInterfaceLUA] [ParallelActSerialMode]RetryCurStage: RetryTimes " .. tostring(PufferInterface.retryTimes))
    if PufferInterface.retryTimes >= PufferInterface.MAX_RETRY_TIMES then
      log(bWriteLog and "[LogicPufferInterfaceLUA] [ParallelActSerialMode]RetryCurStage: Over Max RetryTimes ")
      return filestate.RunNextStage(filestate, false)
    end
  end
  local callback = function()
    PufferInterface.PufferStageFunction[filestate.retryStage](filestate)
  end
  local time_ticker = require("common.time_ticker")
  time_ticker.AddTimerOnce(3, function()
    callback()
  end)
end
function PufferInterface.FinishRequestFile(filestate, clearDiff)
  if clearDiff == nil then
    clearDiff = true
  end
  filestate.curStage = PufferInterface.STAGE_FINISH
  log(bWriteLog and "[LogicPufferInterfaceLUA] FinishRequestFile: errno is " .. tostring(filestate.lastErrno))
  local downloadTime = -1
  local mergeTime = -1
  if filestate.diffFilename then
    downloadTime = os.difftime(filestate.mergeStartTime, filestate.downloadStartTime)
    mergeTime = os.difftime(filestate.EndTime, filestate.mergeStartTime)
  else
    downloadTime = os.difftime(filestate.EndTime, filestate.downloadStartTime)
    mergeTime = 0
  end
  if PufferInterface.ErrReportNameMap[filestate.filename] == nil then
    local param = {
      tostring(filestate.filename),
      tostring(os.difftime(filestate.EndTime, filestate.startTime)),
      tostring(downloadTime),
      tostring(mergeTime),
      tostring(filestate.diffFilename ~= nil),
      tostring(filestate.lastErrno)
    }
    PufferUpdater.GEMReportSubEvent("PufferFinishDownload", param)
    if filestate.lastErrno ~= 0 then
      PufferInterface.ErrReportNameMap[filestate.filename] = filestate.lastErrno
    end
  end
  PufferInterface.filestateList[filestate.outterTaskID] = nil
  local downloadPath = GCPufferDownloader.GetDownloadPath(Puffer)
  if clearDiff and filestate.diffFilename ~= nil then
    GCPufferDownloader.DeleteFile(downloadPath .. filestate.diffFilename)
  end
  if filestate.filename ~= nil then
    GCPufferDownloader.DeleteFile(downloadPath .. filestate.filename .. PufferDownloader.INPROGRESS_PAK_SUFFIX)
  end
  if filestate.lastErrno == 0 and filestate.successCallback ~= nil then
    log(bWriteLog and "[LogicPufferInterfaceLUA] filestate.successCallback")
    filestate.successCallback(filestate.filename, filestate)
  elseif filestate.errorCallback ~= nil then
    log(bWriteLog and "[LogicPufferInterfaceLUA] filestate.errorCallback," .. filestate.filename .. "error is" .. tostring(filestate.lastErrno) .. " stage is" .. tostring(filestate.lastErrStage))
    filestate.errorCallback(filestate.filename, filestate.lastErrno, filestate.lastErrStage, filestate)
  end
  if filestate.lastErrno == 0 then
    local filePathPak = Client.ProjectSavedDir() .. "Paks/" .. filestate.filename
    local fileSizePak = Client.GetFileSizeOnDiskBytes(filePathPak)
    local fileNamePak = tostring(filestate.filename) .. string.format("(%s)|", tostring(fileSizePak))
    Client.AddAttachFileString("pakname", false, fileNamePak)
  end
end
function PufferInterface.GetDifferFileImp(filename)
  local localOldPak = {}
  local ret = GCPufferDownloader.ReturnLocalFiles(PufferInterface.DOWNLOAD_DIR_RELATIVE, "")
  for idx, filename in pairs(ret) do
    local prefix, versionNo = PufferInterface.ParsePakName(filename)
    if prefix ~= nil and versionNo ~= nil then
      if localOldPak[prefix] ~= nil then
        if PufferInterface.CompareVersion(versionNo, localOldPak[prefix]) > 0 then
          localOldPak[prefix] = versionNo
        end
      else
        localOldPak[prefix] = versionNo
      end
    end
  end
  local table = PufferInterface.GetPufferFileListJson()
  local diffList = table.diff_list or {}
  local targetFilePrefix, targetFileVersionNo = PufferInterface.ParsePakName(filename)
  local oldVersion = localOldPak[targetFilePrefix]
  log(bWriteLog and "targetFilePrefix " .. tostring(targetFilePrefix) .. " targetFileVersionNo:" .. tostring(targetFileVersionNo) .. "oldversion:" .. tostring(oldVersion))
  if oldVersion ~= nil then
    log(bWriteLog and "[LogicPufferInterfaceLUA] GetDifferFile diffList pak " .. tostring(diffList[oldVersion]))
    if diffList[oldVersion] ~= nil then
      log(bWriteLog and "[LogicPufferInterfaceLUA] GetDifferFile return" .. tostring(diffList[oldVersion][filename]) .. " " .. tostring(targetFilePrefix .. oldVersion .. ".pak"))
      return diffList[oldVersion][filename], targetFilePrefix .. oldVersion .. ".pak"
    else
      log_error("[LogicPufferInterfaceLUA] GetDifferFile target version not in difflist " .. tostring(filename))
      for k, v in pairs(diffList) do
        log_error("[LogicPufferInterfaceLUA] GetDifferFile diffList: " .. tostring(k) .. " : " .. tostring(v))
      end
    end
  end
  log(bWriteLog and "PufferInterface.GetDifferFailed return nil")
  return nil
end
function PufferInterface.GetDifferFile(filestate)
  filestate.curStage = PufferInterface.STAGE_GET_DIFFERFILE
  local diffFilename, oldFilename = PufferInterface.GetDifferFileImp(filestate.filename)
  if diffFilename ~= nil then
    filestate.    filestate.    return filestate.RunNextStage(filestate, true)
  end
  filestate.lastErrno = PufferInterface.ERR_DIFFERFILE_NOT_FOUND
  filestate.lastErrStage = PufferInterface.STAGE_GET_DIFFERFILE
  return filestate.RunNextStage(filestate, false)
end
function PufferInterface.Tick(DeltaTime)
  local outerIDs = {}
  for outterTaskID, _ in pairs(PufferInterface.filestateList) do
    table.insert(outerIDs, outterTaskID)
  end
  for id, outerid in ipairs(outerIDs) do
    local filestate = PufferInterface.filestateList[outerid]
    local curStage = filestate.curStage
    if curStage == PufferInterface.STAGE_INITIALIZING then
      filestate.RunNextStage(filestate, true)
    elseif curStage == PufferInterface.STAGE_FILE_MERGING then
      local downloadPath = GCPufferDownloader.GetDownloadPath(Puffer)
      filestate.mergePassedProg = GCPufferDownloader.GetFileSize(Puffer, downloadPath .. filestate.filename .. PufferInterface.INPROGRESS_PAK_SUFFIX)
      PufferInterface.SyncProgressToCallback(filestate.outterTaskID, filestate.mergePassedProg, filestate.mergeTotalProg, filestate.curStage)
    end
  end
end
function PufferInterface.SyncProgressToCallback(outterTaskID, nowSize, totalSize, curStage)
  local filestate = PufferInterface.filestateList[outterTaskID]
  if filestate ~= nil and filestate.progressCallback ~= nil then
    filestate.progressCallback(nowSize, totalSize, curStage, filestate)
  end
end
function PufferInterface.OnDownloadProgress(taskId, nowSize, totalSize)
  local filestate = PufferInterface.GetfilestateByPufferTaskID(taskId)
  if filestate == nil then
    log_error("[LogicPufferInterfaceLUA] OnDownloadProgress pufferTaskID is not mapping to filestate")
    return
  end
  printf("PufferInterface.OnDownloadProgress. taskId=%s, nowSize=%s, totalSize=%s", tostring(taskId), tostring(nowSize), tostring(totalSize))
  local time_ticker = require("common.time_ticker")
  time_ticker.AddTimerOnce(0, function()
    PufferInterface.SyncProgressToCallback(filestate.outterTaskID, nowSize, totalSize, filestate.curStage)
    log(bWriteLog and "[LogicPufferInterfaceLUA] OnDownloadProgress: filestate " .. tostring(filestate))
  end)
end
function PufferInterface.GetfilestateByPufferTaskID(pufferTaskID)
  for outterTaskID, filestate in pairs(PufferInterface.filestateList) do
    if filestate.pufferTaskID == pufferTaskID then
      return filestate
    end
  end
  return nil
end
function PufferInterface.GetfilestateByFilename(filename)
  return PufferInterface.filestateList[PufferInterface.outterTaskIDFilenameMapping[filename]]
end
function PufferInterface.ParsePakName(name)
  if name == nil then
    return nil
  end
  return string.match(name, "^([%a%d_]+)(%d+%.%d+%.%d+%.%d+)%.pak$")
end
function PufferInterface.CompareVersion(version1, version2)
  local StringUtil = require("common.string_util")
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
function PufferInterface.GetPufferFileListJson()
  return logic_puffer_common.PufferFileListJson
end
function PufferInterface.ReturnSplitMiniPakFilelist()
  local target_list = GCPufferDownloader.ReturnSplitMiniPakFilelist()
  local transed_filename = {}
  if target_list ~= nil then
    for k, v in ipairs(target_list) do
      transed_filename[#transed_filename + 1] = PufferInterface.GetRealFilename(v)
    end
    return transed_filename
  end
  return nil
end
function PufferInterface.GetRealFilename(filename)
  if Client.IsFileExistsWithOutPakCheck(Client.ProjectSavedDir() .. PufferDownloader.DOWNLOAD_DIR_RELATIVE .. filename) then
    return filename
  end
  local basename, ext = string.match(filename, "(.+)(%..+)")
  local table = PufferInterface.GetPufferFileListJson()
  if table == nil or next(table) == nil then
    if not IsEditor then
      log_error("[PufferInterface] GetRealFilename parse json FAILED!")
    end
    return filename
  end
  local versionMapping = table.version_mapping
  if versionMapping == nil then
    log_error("PufferInterface.GetRealFilename parse json KEY version_mapping NOT found " .. filename)
    return filename
  end
  local retName = ""
  if basename and versionMapping[basename] == nil then
    local prefix = string.match(basename, "(.+_.+_).*")
    if prefix == nil then
      log_error("[PufferInterface] GetRealFilename Cant match name " .. tostring(filename))
      return filename
    end
    retName = versionMapping[prefix .. "default"]
    if retName == nil then
      log_warning("[PufferInterface] GetRealFilename versionMapping do not have default value, filename = " .. filename)
      return filename
    end
  else
    retName = versionMapping[basename]
  end
  log(bWriteLog and "[PufferInterface] name mapping from " .. filename .. " to " .. retName .. ext)
  return retName .. ext
end
function PufferInterface.GetFileSizeCompressed(filename, fullsize)
  local isDiffFile = false
  filename = PufferInterface.GetRealFilename(filename)
  if filename then
    local downloadFilename = filename
    if not fullsize then
      downloadFilename = PufferInterface.GetDifferFileImp(filename)
      if downloadFilename == nil then
        downloadFilename = filename
      else
        isDiffFile = true
      end
    end
    log(bWriteLog and "[PufferInterface] GetFileSizeCompressed: targetFilename:" .. downloadFilename)
    local fileSize = GCPufferDownloader.GetFileSizeCompressed(Puffer, downloadFilename)
    if 0 < fileSize and fileSize < 104858 then
      fileSize = 104858
    end
    return fileSize, isDiffFile
  else
    log(bWriteLog and "[PufferInterface] GetFileSizeCompressed: filelist Not Exist")
    return 0, isDiffFile
  end
end
function PufferInterface.ShowNoEnoughSpaceTips(filename)
  local space = Client.GetDeviceFreeSpace() - 100
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local size = PufferInterface.GetFileSizeCompressed(filename, true) / PufferConst.MB
  local Logic_Download_Delete = require("client.slua.logic.download.delete.logic_download_delete")
  size = Logic_Download_Delete.GetBaseRealSize(filename, size)
  log(bWriteLog and string.format("PufferInterface.ShowNoEnoughSpaceTips size:%s", tostring(size)))
  if space > size or string.lower(Client.GetDevicePlatformName()) == "windows" then
    return true
  else
    local notice = LocUtil.GetLocalizeResStr(4179)
    ShowNotice(notice)
    size = size - space + 20
    log(bWriteLog and string.format("[zyh] PufferInterface.ShowNoEnoughSpaceTips space:%s", tostring(space)))
    local PufferDeleteManager = require("client.slua.logic.download.delete.puffer_delete_manager")
    PufferDeleteManager.ShowDeleteHintMsgBox(size)
    log_format("PufferInterface.ShowNoEnoughSpaceTips. report")
    local StatManager = import("StatManager")
    StatManager.GetInstance():ReportEventWithNoParam(109, true)
  end
  return false
end
function PufferInterface.GetDownloadTypeByFileName(fileName)
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local downdloadType = PufferConst.ENUM_DownloadType.ODPAK
  if fileName ~= nil then
    local StringUtil = require("common.string_util")
    if StringUtil.Starts(fileName, PufferConst.RES_FILE_PREFIX) or StringUtil.Starts(fileName, PufferConst.BASE_PREFIX) then
      downdloadType = PufferConst.ENUM_DownloadType.RES
    elseif StringUtil.Starts(fileName, PufferConst.MAP_PREFIX) then
      downdloadType = PufferConst.ENUM_DownloadType.MAP
    end
  end
  return downdloadType
end