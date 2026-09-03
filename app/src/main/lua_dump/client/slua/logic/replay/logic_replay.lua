local logic_replay = {
  isPermitRecordReplay = false,
  ReplayTipPopVersion = nil,
  ReplaySwitchOpVersion = nil,
  bHaveReplay = nil,
  HideRoleModeList = {
    [64101] = 1,
    [64102] = 1,
    [64103] = 1
  }
}
local isInitedSetting = false
local isNeedCheckUID = true
local replayMapCache = {}
local replayDataMap = {}
local deathReplayDataMap = {}
local bReadFlag = false
local bMoveFile = false
local REPLAY_DIR_PATH = "Demos/UserReplay"
local DEATH_REPLAY_DIR_PATH = "Demos/ReplayCollect"
local REPLAY_NET_PATH = "Replay"
local eventFlag = false
local recordFunc
local playingFileTbl = {}
local MaxSaveCount = 20
local InfoToRepalyCache = {}
local recordBeginFlag = false
local loading_timer
local isReplaying = false
local replay_version_table = {}
local replay_type_priority_table
local wonderful_play_lua_interface = require("client.slua.logic.replay.wonderful_play_lua_interface")
local death_play_lua_interface = require("client.slua.logic.replay.death_play_lua_interface")
local replay_macro = require("client.slua.logic.replay.replay_macro")
local data_config_marco = require("client.logic.data.data_config_marco")
local FileType = replay_macro.FileType
local PathType = replay_macro.PathType
local WonderFulErrorCode = replay_macro.WonderFulErrorCode
local Main_Scene = replay_macro.TLOG.Main_Scene
local OWNER = replay_macro.TLOG.OWNER
function logic_replay.InitReplayFileFromLocalFile()
  if bReadFlag == false then
    logic_replay.MoveReplayFileByUid()
    local uid = DataMgr.roleData.uid
    local DirPath = string.format("%s%s/%s", Client.ProjectSavedDir(), REPLAY_DIR_PATH, uid)
    local SavedFileUtil = import("SavedFileUtil")
    local dirArr = SavedFileUtil.FindFiles(DirPath, "*", false)
    for k, filename in pairs(dirArr) do
      local fileSaveKey = uid .. "/" .. filename
      logic_replay.SaveFilenameToCache(fileSaveKey)
    end
    bReadFlag = true
  end
  log_tree("[yw] InitReplayFileFromLocalFile", replayDataMap)
end
function logic_replay.InitDeathFileFromLocalFile()
  log(bWriteLog and "logic_replay.InitDeathFileFromLocalFile.")
  deathReplayDataMap = {}
  local uid = tonumber(DataMgr.roleData.uid)
  local DirPath = string.format("%s%s/", Client.ProjectSavedDir(), DEATH_REPLAY_DIR_PATH)
  local SavedFileUtil = import("SavedFileUtil")
  local dirArr = SavedFileUtil.FindFiles(DirPath, FileType.DEATH_INFO, false)
  for k, filename in pairs(dirArr) do
    local filepath = DirPath .. filename
    local data = death_play_lua_interface.GetJsonFromInfo(filepath)
    deathReplayDataMap[DEATH_REPLAY_DIR_PATH .. "/" .. filename] = data
  end
  log_tree("logic_replay.InitDeathFileFromLocalFile. deathDataMap = ", deathReplayDataMap)
end
function logic_replay.MoveReplayFileByUid()
  if bMoveFile then
    return
  end
  bMoveFile = true
  local sourceDir = Client.ProjectSavedDir() .. REPLAY_DIR_PATH .. "/"
  local SavedFileUtil = import("SavedFileUtil")
  local fileList = SavedFileUtil.FindFiles(sourceDir, FileType.REPLAY, false)
  for _, fileName in pairs(fileList) do
    log(bWriteLog and "MoveReplayFileByUid fileName: " .. fileName)
    local replayFilePath = logic_replay.GetPathByType(fileName, PathType.RELATIVE)
    local jsonFilePath = logic_replay.GetRelativeFileByType(replayFilePath, FileType.REPLAY, FileType.INFO)
    local jsonFileName = string.gsub(fileName, FileType.REPLAY, FileType.INFO)
    local jsonInfo = logic_replay.GetJsonInfoByFilePath(jsonFilePath)
    if jsonInfo then
      local uid = jsonInfo.UID
      log(bWriteLog and "MoveReplayFileByUid uid: " .. tostring(uid))
      if uid ~= nil then
        if tostring(uid) == DataMgr.roleData.uid then
          local fileSaveKey = uid .. "/" .. jsonFileName
          replayDataMap[fileSaveKey] = jsonInfo
        end
        local desReplayFilePath = string.format("%s%s/%s", sourceDir, tostring(uid), fileName)
        local desJsonFilePath = string.format("%s%s/%s", sourceDir, tostring(uid), jsonFileName)
        local dirPath = string.format("%s/%s/", REPLAY_DIR_PATH, tostring(uid))
        log(bWriteLog and "MoveReplayFileByUid replayFilePath: " .. replayFilePath)
        log(bWriteLog and "MoveReplayFileByUid desReplayFilePath: " .. desReplayFilePath)
        Client.SaveStringToFile("", dirPath)
        Client.MoveFile(replayFilePath, desReplayFilePath)
        Client.MoveFile(jsonFilePath, desJsonFilePath)
      else
        log(bWriteLog and "MoveReplayFileByUid uid is nil jsonFilePath =  " .. tostring(jsonFilePath))
      end
    end
  end
end
function logic_replay.CheckFileExist(filename)
  logic_replay.InitReplayFileFromLocalFile()
  if replayMapCache[filename] or replayDataMap[filename] then
    return true
  end
  local FilePath = logic_replay.GetPathByType(filename, PathType.FULL)
  log(bWriteLog and "FilePath = " .. tostring(FilePath))
  if Client.IsFileExistByFileName(FilePath) then
    logic_replay.SaveFilenameToCache(filename)
    return true
  end
  return false
end
function logic_replay.CheckInfoIsOK(filename)
  local errorCode = WonderFulErrorCode
  local jsonInfo = replayDataMap[filename]
  if jsonInfo and jsonInfo.ErrorCode == errorCode.None then
    return true
  end
  return false
end
function logic_replay.CheckFileExistAndOK(filename)
  if logic_replay.CheckFileExist(filename) and logic_replay.CheckInfoIsOK(replayDataMap[filename]) then
    return true
  end
  return false
end
function logic_replay.DeleteCacheReplayFile()
  if not LobbySystem.CheckOpen(BP_ENUM_WONDERFUL_REPLAY_SWITCH) then
    log(bWriteLog and "[v_wllwu] logic_replay.DeleteCacheReplayFile return, switch is not open")
    return
  end
  local fileList = logic_replay.GetAllSavedReplayInfoList()
  local _maxSaveCount = logic_replay.GetMaxSaveCount()
  if _maxSaveCount >= #fileList then
    return
  end
  for i = _maxSaveCount + 1, #fileList do
    local info = fileList[i]
    local fileName = info.fileName
    local replayFileName = logic_replay.GetReplayFileByInfoFile(fileName)
    logic_replay.DeleteFile(fileName)
    logic_replay.DeleteFile(replayFileName)
    replayDataMap[fileName] = nil
    replayMapCache[fileName] = nil
  end
end
function logic_replay.DeleteFile(filename)
  local filePath = logic_replay.GetRelativePath(filename)
  Client.DeleteFile(filePath)
end
function logic_replay.CheckReplayCanPlay(fileName)
  if logic_replay.CheckPatchVersionMatch(fileName) == false then
    return false
  end
  local fileInfo = logic_replay.GetJsonTableByFilename(fileName)
  if not fileInfo then
    log(bWriteLog and "logic_replay.CheckReplayCanPlay fileInfo is nil")
    return false
  end
  local version = fileInfo.AppVersion
  local version_util = require("client.common.version_util")
  if not version_util.IsMatchVersion(version) then
    return false
  end
  return true
end
function logic_replay.GetReplayURLByFilename(filename)
  if logic_replay.IsOnlineUrl(filename) then
    return filename
  end
  return ""
end
function logic_replay.GetPathByType(filename, _pathType)
  local realFilename = filename
  local prefix = REPLAY_DIR_PATH
  if logic_replay.IsOnlineUrl(filename) then
    local recordTbl = InfoToRepalyCache[filename]
    log_tree(bWriteLog and "InfoToRepalyCache = ", InfoToRepalyCache)
    log_tree(bWriteLog and "recordTbl = " .. tostring(filename), recordTbl)
    if logic_replay.CheckFileIsReplay(filename) then
      realFilename = recordTbl.uid .. "/" .. recordTbl.decrypt .. FileType.REPLAY
    else
      realFilename = recordTbl.uid .. "/" .. recordTbl.decrypt .. FileType.INFO
    end
    prefix = REPLAY_NET_PATH
  end
  local fullPath = prefix .. "/" .. realFilename
  local relativePath = Client.ProjectSavedDir() .. fullPath
  local retPath
  if PathType.RELATIVE == _pathType then
    retPath = relativePath
  elseif PathType.ABSOLUTE == _pathType then
    local ScriptHelperClient = import("ScriptHelperClient")
    retPath = ScriptHelperClient.ConvertRelativePathToFull(relativePath)
  elseif PathType.FULL == _pathType then
    retPath = fullPath
  end
  return retPath
end
function logic_replay.GetRelativePath(filename)
  return logic_replay.GetPathByType(filename, PathType.RELATIVE)
end
function logic_replay.GetRelativeFileByType(file, OriginType, TargetType)
  if string.find(file, OriginType) ~= nil then
    return string.sub(file, 1, #file - #OriginType) .. TargetType
  end
end
function logic_replay.GetReplayFileByInfoFile(file)
  local retFile
  if logic_replay.IsOnlineUrl(file) then
    local recordTbl = InfoToRepalyCache[file]
    if recordTbl then
      retFile = recordTbl.replay
    end
  else
    retFile = logic_replay.GetRelativeFileByType(file, FileType.INFO, FileType.REPLAY)
  end
  if retFile == nil then
    log(bWriteLog and "the file is relay file is not found !!!" .. tostring(file))
  end
  return retFile
end
function logic_replay.ShowCanNotReplayTip()
  local title = LocUtil.GetLocalizeResStr(5077)
  local msg = LocUtil.GetLocalizeResStr(501128)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(1, title, msg)
end
function logic_replay.ShowDownloadMapTip(fileName)
  local fileInfo = logic_replay.GetJsonTableByFilename(fileName)
  local UGCModID
  if fileInfo.AdditionData and fileInfo.AdditionData.UGCModID then
    UGCModID = tonumber(fileInfo.AdditionData.UGCModID)
  end
  local title = LocUtil.GetLocalizeResStr(5077)
  local msg = ""
  if UGCModID == nil then
    local mapName = ""
    local subModeCfg = CDataTable.GetTableData("BTMode", fileInfo.ModeID)
    if subModeCfg then
      local mapInfo = CDataTable.GetTableData("Map", subModeCfg.MapID)
      log(bWriteLog and "logic_replay.ShowDownloadMapTip subModeCfg.MapID = " .. tostring(subModeCfg.MapID))
      if mapInfo and mapInfo.ShowName then
        mapName = mapInfo.ShowName
      end
    end
    msg = LocUtil.LocalizeResFormat(24661, mapName)
  else
    msg = LocUtil.LocalizeResFormat(8502065, UGCModID)
  end
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(1, title, msg)
end
function logic_replay.PlayReplayFileWithCheckUidBan(jsonInfoUrl, replayInfoUrl, playType, handler1, handler2, handler3, index)
  log(bWriteLog and "PlayReplayFile " .. tostring(jsonInfoUrl) .. tostring(replayInfoUrl))
  if jsonInfoUrl == nil or replayInfoUrl == nil then
    ShowNotice(7488)
    return
  end
  local jsonTbl = logic_replay.GetJsonTableByFilename(jsonInfoUrl)
  if tostring(jsonTbl.UID) == tostring(DataMgr.roleData.uid) then
    log(bWriteLog and "Play My ReplayFile ")
    logic_replay.PlayReplayFile(jsonInfoUrl, replayInfoUrl, playType, handler1, handler2, handler3, index)
    return
  end
  local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
  local profile = LobbySocialSystem.GetProfileByUID(jsonTbl.UID)
  local callback = function()
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    if not logic_profile:IsPlayerBannedBeforeTime(jsonTbl.UID, jsonTbl.SaveTimestamp) then
      logic_replay.PlayReplayFile(jsonInfoUrl, replayInfoUrl, playType, handler1, handler2, handler3, index)
    else
      ShowNotice(24506)
    end
  end
  if profile then
    callback()
  else
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles({
      jsonTbl.UID
    }, function(list)
      callback()
    end, Enum_PROFILE_REPORT_CFG.REPLAY, 0, false)
  end
end
function logic_replay.PlayReplayFile(jsonInfoUrl, replayInfoUrl, playType, handler1, handler2, handler3, index)
  log(bWriteLog and "PlayReplayFile " .. tostring(jsonInfoUrl) .. tostring(replayInfoUrl))
  if jsonInfoUrl == nil or replayInfoUrl == nil then
    ShowNotice(7488)
    return
  end
  local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
  local jsonTbl = logic_replay.GetJsonTableByFilename(jsonInfoUrl)
  if logic_replay.CheckReplayCanPlay(jsonInfoUrl) == false then
    log(bWriteLog and "CheckReplayCanPlay !!!")
    if handler1 then
      handler1()
    else
      logic_replay.ShowCanNotReplayTip()
    end
  elseif logic_replay.checkMapDownloadSuccess(jsonTbl) == false then
    log(bWriteLog and "checkMapDownloadSuccess !!!")
    if handler2 then
      handler2()
    else
      logic_replay.ShowDownloadMapTip(jsonInfoUrl)
    end
  elseif logic_replay.CheckFileExist(replayInfoUrl) then
    log(bWriteLog and "CheckFileExist !!!!" .. tostring(replayInfoUrl))
    logic_replay.RealPlayReplayFile(jsonInfoUrl, replayInfoUrl, playType, handler3, jsonTbl.ModeID, index)
  else
    log(bWriteLog and "download url : " .. tostring(replayInfoUrl))
    logic_replay.DownloadReplayFile({url = replayInfoUrl})
    ShowNotice(7421)
  end
end
function logic_replay.RealPlayReplayFile(jsonInfoUrl, replayInfoUrl, playType, handler, subMode, index)
  if LobbySystem.isInMatch then
    ShowNotice(500061)
    return
  end
  print(bWriteLog and "logic_replay.RealPlayReplayFile", jsonInfoUrl, replayInfoUrl, playType, handler, subMode)
  local path = logic_replay.GetReplayFullPathByFilename(replayInfoUrl)
  local LoadingSystem = require("client.slua.logic.loading.logic_loading")
  LoadingSystem.ShowLoading(false)
  logic_replay.ReleaseLoadingTimer()
  local timer_tick = require("common.time_ticker")
  loading_timer = timer_tick.AddTimerOnce(0.1, function()
    local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
    MatchModeMgrSystem.SetInGameModeID(0)
    local bSuccess = wonderful_play_lua_interface.RealPlayReplayFile(path, playType, subMode, index)
    if bSuccess then
      logic_replay.DoPrePlayFunc(jsonInfoUrl, replayInfoUrl)
    else
      UIManager.CloseUI(UIManager.UI_Config.loading)
    end
    if handler then
      handler(bSuccess)
    end
  end)
end
function logic_replay.RealPlayDeathReplayFile(path, playType, handler, subMode, index)
  print(bWriteLog and "logic_replay.RealPlayDeathReplayFile", path, playType, subMode)
  if LobbySystem.isInMatch then
    ShowNotice(500061)
    return
  end
  print(bWriteLog and "logic_replay.RealPlayDeathReplayFile", playType, handler, subMode)
  local LoadingSystem = require("client.slua.logic.loading.logic_loading")
  LoadingSystem.ShowLoading(false)
  logic_replay.ReleaseLoadingTimer()
  local timer_tick = require("common.time_ticker")
  loading_timer = timer_tick.AddTimerOnce(0.1, function()
    local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
    MatchModeMgrSystem.SetInGameModeID(0)
    local bSuccess = death_play_lua_interface.RealPlayReplayFile(path, playType, subMode, index)
    if bSuccess then
      logic_replay.DoPrePlayFunc(nil, nil)
    else
      UIManager.CloseUI(UIManager.UI_Config.loading)
    end
    if handler then
      handler(bSuccess)
    end
  end)
end
function logic_replay.HandleMainCity()
  log(bWriteLog and "logic_replay.HandleMainCity")
  local isInMainCity = GameStatus.IsInMainCity()
  log(bWriteLog and "logic_replay.HandleMainCity isInMainCity = " .. tostring(isInMainCity))
  local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
  if isInMainCity then
    Lobby_Main_City_Enter.bEnterGameFromMainCity = true
  end
  local bConnectDS = Lobby_Main_City_Enter.bConnectDS
  log(bWriteLog and "logic_replay.HandleMainCity bConnectDS = " .. tostring(bConnectDS))
  if bConnectDS then
    Lobby_Main_City_Enter.LeaveMainCity(true, false, false)
  end
end
function logic_replay.DownloadReplayFile(data)
  data.path = logic_replay.GetPathByType(data.url, PathType.ABSOLUTE)
  log(bWriteLog and "[v_ywuyuan] logic.replay DownloadReplayFile url = " .. tostring(data.url) .. " path = " .. tostring(data.path))
  if replayMapCache[data.url] or replayDataMap[data.url] then
    EventSystem:postEvent(EVENTTYPE_REPLAY, EVENTTYPE_REPLAY_DOWNLOAD_SUCCESS, data.url, data.path)
  elseif logic_replay.CheckFileExist(data.url) then
    logic_replay.OnDownloadCompleteCallBack(data.url, data.path, true)
  else
    local cdn_downloader = require("client.common.cdn_downloader")
    cdn_downloader.download(data.url, data.path, logic_replay.OnDownloadCompleteCallBack, data.retryTimes or 3)
  end
end
function logic_replay.OnDownloadCompleteCallBack(url, path, bIsDownloaded)
  log(bWriteLog and "[v_ywuyuan ] OnDownloadCompleteCallBack url : " .. tostring(url) .. " path : " .. tostring(path) .. "bIsDownloaded : " .. tostring(bIsDownloaded))
  local fullFilePath = logic_replay.GetPathByType(url, PathType.FULL)
  log(bWriteLog and "[v_ywuyuan] fileExists" .. tostring(fullFilePath) .. " " .. tostring(Client.IsFileExistByFileName(fullFilePath)))
  if Client.IsFileExistByFileName(fullFilePath) and bIsDownloaded then
    logic_replay.SaveFilenameToCache(url)
    EventSystem:postEvent(EVENTTYPE_REPLAY, EVENTTYPE_REPLAY_DOWNLOAD_SUCCESS, url, path)
  else
    EventSystem:postEvent(EVENTTYPE_REPLAY, EVENTTYPE_REPLAY_DOWNLOAD_FAIL, url)
  end
end
function logic_replay.UploadReplayFile(file1, file2, handler)
  logic_replay.UploadFileList({file1, file2}, handler)
end
function logic_replay.UploadFileList(filelist, handler, extendedParams)
  local replayUrlList = {}
  local uploadFlie
  function uploadFlie(index)
    if index > #filelist then
      if 1 < #replayUrlList and logic_replay.CheckFileIsInfo(replayUrlList[1]) and logic_replay.CheckFileIsReplay(replayUrlList[2]) then
        handler(true, replayUrlList)
      else
        handler(false)
      end
      return
    end
    local ShareMgr = require("client.logic.share.share_logic")
    local path = ScriptHelperClient.ConvertRelativePathToFull(filelist[index])
    log(bWriteLog and "[YW] path = " .. path)
    ShareMgr.HDmpveUploadFile(path, function(isSuccess, replayUrl)
      log(bWriteLog and "[YW] replayUrl = " .. tostring(replayUrl))
      if isSuccess then
        replayUrlList[index] = replayUrl
        uploadFlie(index + 1)
      else
        handler(isSuccess, replayUrlList)
      end
    end, 0, ShareMgr.ShareFileType.Replay, extendedParams and extendedParams.dontShowWaitingUI)
  end
  uploadFlie(1)
end
function logic_replay.checkMapDownloadSuccess(jsonTbl)
  local modeID = jsonTbl.ModeID
  local UGCModID
  if jsonTbl.AdditionData and jsonTbl.AdditionData.UGCModID then
    UGCModID = tonumber(jsonTbl.AdditionData.UGCModID)
  end
  log(bWriteLog and "logic_replay.CheckMapDownloadSuccess UGCModID:" .. tostring(UGCModID))
  local DownloadSuccess = true
  if UGCModID == nil then
    local subModeCfg = CDataTable.GetTableData("BTMode", modeID)
    if subModeCfg ~= nil then
      local mapInfo = CDataTable.GetTableData("Map", subModeCfg.MapID)
      if mapInfo then
        local mapKey = mapInfo.MapKey
        log(bWriteLog and "logic_replay.checkMapDownloadSuccess mapKey = " .. mapKey)
        local PufferConst = require("client.slua.logic.download.puffer_const")
        local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
        local eventState = PufferManager.GetState(PufferConst.ENUM_DownloadType.MAP, {mapKey})
        DownloadSuccess = eventState == PufferConst.ENUM_DownloadState.Done
      else
        log(bWriteLog and "[yw] modeInfo is nil, " .. tostring(subModeCfg.MapID))
        DownloadSuccess = false
      end
    else
      log(bWriteLog and "[yw] subModeCfg is nil, " .. tostring(modeID))
      DownloadSuccess = false
    end
  else
    local UGCMapID, ResList
    if jsonTbl.AdditionData then
      local UGCMapIDStr = jsonTbl.AdditionData.UGCMapID
      local ResListStr = jsonTbl.AdditionData.ResList
      log(bWriteLog and "CheckMapDownloadSuccess UGCMapIDStr:" .. tostring(UGCMapIDStr) .. " ResListStr:" .. tostring(ResListStr))
      if UGCMapIDStr then
        UGCMapID = tonumber(UGCMapIDStr)
      end
      if ResListStr then
        ResList = load("return " .. ResListStr)()
      end
    end
    if UGCMapID ~= nil and ResList ~= nil then
      local PufferConst = require("client.slua.logic.download.puffer_const")
      local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
      local mapInfo = CDataTable.GetTableData("Map", UGCMapID)
      if mapInfo then
        local mapKey = mapInfo.MapKey
        log(bWriteLog and "logic_replay.checkMapDownloadSuccess mapKey = " .. mapKey)
        local eventState = PufferManager.GetState(PufferConst.ENUM_DownloadType.MAP, {mapKey})
        DownloadSuccess = eventState == PufferConst.ENUM_DownloadState.Done
      else
        log(bWriteLog and "modeInfo is nil")
        DownloadSuccess = false
      end
      if DownloadSuccess == true then
        local resManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCResManager)
        log_tree(bWriteLog and "CheckMapDownloadSuccess res_list:", ResList)
        local ResIdList = resManager:GetDependIdsByIntMap(ResList)
        log_tree(bWriteLog and "CheckMapDownloadSuccess id_list:", ResIdList)
        local idState = PufferManager.GetState(PufferConst.ENUM_DownloadType.UGCPAK, ResIdList)
        DownloadSuccess = idState == PufferConst.ENUM_DownloadState.Done
      else
        log(bWriteLog and "MapRes DownloadSuccess is false")
      end
    else
      log(bWriteLog and "ResInfo is nil UGCMapID:" .. tostring(UGCMapID) .. " ResList:" .. tostring(ResList))
      DownloadSuccess = false
    end
  end
  return DownloadSuccess
end
function logic_replay.IsOnlineUrl(url)
  local util = require("client.slua_ui_framework.util")
  return util.IsOnlineImageUrl(url)
end
function logic_replay.GetRecordSwitchValue()
  if not isInitedSetting then
    logic_replay.isPermitRecordReplay = logic_replay.LoadSettingsInfo()
    isInitedSetting = true
  end
  return logic_replay.isPermitRecordReplay
end
function logic_replay.SetRecordSwitchValue(bOn)
  logic_replay.isPermitRecordReplay = bOn
  logic_replay.SaveSettingsInfo(bOn)
end
function logic_replay.LoadSettingsInfo()
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  return SettingConfig.bRecordWonderfulReplayOpen or false
end
function logic_replay.SaveSettingsInfo(bOn)
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  SettingConfig.bRecordWonderfulReplayOpen = bOn
  slua_GameFrontendHUD:FinishModifyUserSettings()
end
function logic_replay.CheckFilenameValid(filename)
  local s = string.find(filename, "/")
  if s == nil then
    return true
  end
  return false
end
function logic_replay.GetJsonTableByFilename(filename)
  if replayDataMap[filename] then
    return replayDataMap[filename]
  end
  local filePath = logic_replay.GetPathByType(filename, PathType.RELATIVE)
  local data
  data = logic_replay.GetJsonInfoByFilePath(filePath)
  return data
end
function logic_replay.GetJsonInfoByFilePath(filepath)
  local data = wonderful_play_lua_interface.GetJsonFromInfo(filepath)
  return data
end
function logic_replay.GetReplayFullPathByFilename(filename)
  if replayMapCache[filename] then
    return replayMapCache[filename]
  end
  local filePath = logic_replay.GetPathByType(filename, PathType.ABSOLUTE)
  return filePath
end
function logic_replay.SaveFilenameToCache(filename)
  if logic_replay.CheckFileIsInfo(filename) then
    replayDataMap[filename] = logic_replay.GetJsonTableByFilename(filename)
  elseif logic_replay.CheckFileIsReplay(filename) then
    replayMapCache[filename] = logic_replay.GetReplayFullPathByFilename(filename)
  else
    log(bWriteLog and "[yw]SaveFilenameToCache  filename:" .. filename)
  end
end
function logic_replay.CheckFileIsJson(filename)
  return string.find(filename, FileType.JSON, nil, true) ~= nil
end
function logic_replay.CheckFileIsReplay(filename)
  return string.find(filename, FileType.REPLAY, nil, true) ~= nil
end
function logic_replay.CheckFileIsInfo(filename)
  return string.find(filename, FileType.INFO, nil, true) ~= nil
end
function logic_replay.GetAllSavedReplayInfoList()
  logic_replay.InitReplayFileFromLocalFile()
  local replayInfoList = {}
  for name, data in pairs(replayDataMap) do
    if not logic_replay.IsOnlineUrl(name) and (not isNeedCheckUID or tostring(data.UID) == DataMgr.roleData.uid) then
      local tempData = {}
      tempData.saveTimestamp = data.SaveTimestamp
      tempData.fileName = name
      table.insert(replayInfoList, tempData)
    end
  end
  if 0 < #replayInfoList then
    table.sort(replayInfoList, function(a, b)
      return a.saveTimestamp > b.saveTimestamp
    end)
  end
  return replayInfoList
end
function logic_replay.InitWonderFulTypePriorityConfig()
  if replay_type_priority_table ~= nil then
    return
  end
  replay_type_priority_table = {}
  local priorityConfig = CDataTable.GetTable("WonderfulTypePriority")
  if priorityConfig ~= nil then
    for _, v in pairs(priorityConfig) do
      replay_type_priority_table[v.WonderfulType] = {
        priority = v.Priority,
        titleID = v.TitleID
      }
    end
  end
end
function logic_replay.GetTitleByInfo(TypeInfoArray)
  if not TypeInfoArray then
    return ""
  end
  if next(TypeInfoArray) == nil then
    return ""
  end
  logic_replay.InitWonderFulTypePriorityConfig()
  local thisWonderfulType = TypeInfoArray[1].WonderfulType
  if 1 < #TypeInfoArray then
    local typeArray = {}
    for _, v in pairs(TypeInfoArray) do
      local info = {
        WonderfulType = v.WonderfulType,
        sortIndex = 0
      }
      if replay_type_priority_table[v.WonderfulType] then
        info.sortIndex = replay_type_priority_table[v.WonderfulType].priority or 0
      end
      table.insert(typeArray, info)
    end
    if 0 < #typeArray then
      table.sort(typeArray, function(a, b)
        return a.sortIndex < b.sortIndex
      end)
      thisWonderfulType = typeArray[1].WonderfulType
    end
  end
  local tipsId = 24672
  if replay_type_priority_table and replay_type_priority_table[thisWonderfulType] then
    tipsId = replay_type_priority_table[thisWonderfulType].titleID
  end
  return LocUtil.GetLocalizeResStr(tipsId)
end
function logic_replay.GetDescByModeID(modeID)
  local subModeCfg = CDataTable.GetTableData("BTMode", modeID)
  if subModeCfg == nil then
    log(bWriteLog and "[v_wllwu] logic_replay.GetDescByModeID subModeCfg = nil, modeID is " .. tostring(modeID))
    subModeCfg = CDataTable.GetTableData("BTMode", 1001)
    if subModeCfg == nil then
      return ""
    end
  end
  local logic_mode_utils = require("client.slua.logic.mode_selection.logic_mode_utils")
  local mapName = logic_mode_utils.GetModeNameByModeID(modeID)
  local PersonPerspective
  if subModeCfg.IsFpp then
    PersonPerspective = LocUtil.GetLocalizeResStr(100053)
  else
    PersonPerspective = LocUtil.GetLocalizeResStr(100054)
  end
  local numberPlayer = LocUtil.GetLocalizeResStr(subModeCfg.NumberShowId)
  return LocUtil.LocalizeResFormat(25701, mapName, PersonPerspective, numberPlayer)
end
function logic_replay.GetDuration(TotalTime)
  local TimeUtil = require("client.common.time_util")
  return TimeUtil.FormatCountDownTime_MS(TotalTime)
end
function logic_replay.GetBattleSaveTime(SaveTimestamp)
  local TimeUtil = require("client.common.time_util")
  return TimeUtil.FormatTime_YMDHMS(SaveTimestamp)
end
function logic_replay.GetPreviewImagePathByModeID(modeID)
  local cfg = CDataTable.GetTableData("WonderfulImageConfig", modeID)
  log(bWriteLog and "logic_replay.GetPreviewImagePathByModeID modeID: " .. tostring(modeID))
  if not cfg then
    local baseModeID = logic_replay.GetBaseMapModeID(modeID)
    log(bWriteLog and "logic_replay.GetPreviewImagePathByModeID. baseModeID = " .. tostring(baseModeID))
    cfg = CDataTable.GetTableData("WonderfulImageConfig", baseModeID)
  end
  return cfg.image
end
function logic_replay.GetBaseMapModeID(modeID)
  local modeCfg = CDataTable.GetTableData("BTMode", modeID)
  if modeCfg then
    local mapCfg = CDataTable.GetTableData("Map", modeCfg.MapID)
    if mapCfg then
      local baseMapCfg = CDataTable.GetTableDataByFilter("Map", "MapPath", mapCfg.MapPath)
      if baseMapCfg.ResId then
        local data = CDataTable.GetTableData("WonderfulMappingCfg", baseMapCfg.ResId)
        if data then
          return data.ModeID
        end
      end
    end
  end
  return 1001
end
function logic_replay.GetReplayDataMap()
  logic_replay.InitReplayFileFromLocalFile()
  return replayDataMap
end
function logic_replay.GetDeathReplayDataMap()
  return deathReplayDataMap
end
function logic_replay.SetPlayingFileTbl(info, replay)
  playingFileTbl = {info = info, replay = replay}
  log(bWriteLog and "[v_ywuyuan] logic_Replay SetPlayingFileTbl info = " .. tostring(info) .. " replay = " .. tostring(replay))
end
function logic_replay.GetPlayingFileTbl()
  return playingFileTbl
end
function logic_replay.SetMaxSaveCount(count)
  MaxSaveCount = count
end
function logic_replay.GetMaxSaveCount()
  return MaxSaveCount
end
function logic_replay.AddEntryToCache(info, replay, decrypt, uid)
  if info == nil or decrypt == nil then
    log(bWriteLog and "[v_Wllwu] logic_Replay AddEntryToCache info = " .. tostring(info) .. " replay = " .. tostring(replay) .. " decrypt = " .. tostring(decrypt))
    return
  end
  local recordTbl = {
    info = info,
    replay = replay,
    decrypt = decrypt,
      }
  InfoToRepalyCache[info] = recordTbl
  InfoToRepalyCache[replay] = recordTbl
  log(bWriteLog and "[v_ywuyuan] AddEntryToCache info: " .. tostring(info) .. " replay: " .. tostring(replay) .. " decrypt: " .. tostring(decrypt) .. " uid: " .. tostring(uid))
end
function logic_replay.GetDecryptStr(filename)
  log(bWriteLog and "GetDecryptStr" .. filename .. FileType.REPLAY)
  local iFind = string.find(filename, FileType.REPLAY)
  local iBeginFind = string.find(filename, "/") or 0
  log(bWriteLog and "GetDecryptStr" .. tostring(iFind) .. tostring(iBeginFind))
  if iFind then
    log(bWriteLog and "GetDecryptStr" .. string.sub(filename, iBeginFind + 1, iFind - 1))
    return string.sub(filename, iBeginFind + 1, iFind - 1)
  end
  return ""
end
function logic_replay.GetDecryptStrByOnlineUrl(url)
  log(bWriteLog and "GetDecryptStr url" .. tostring(url))
  if InfoToRepalyCache[url] then
    log(bWriteLog and "GetDecryptStr decrypt" .. InfoToRepalyCache[url].decrypt)
    return InfoToRepalyCache[url].decrypt
  end
  return ""
end
function logic_replay.GetDecryptStrByUrl(json_url, replay_url)
  if not json_url then
    return ""
  end
  if logic_replay.IsOnlineUrl(json_url) then
    return logic_replay.GetDecryptStrByOnlineUrl(replay_url)
  end
  return logic_replay.GetDecryptStr(logic_replay.GetReplayFileByInfoFile(json_url))
end
function logic_replay.PlayingIsOnlineUrl()
  if playingFileTbl and playingFileTbl.info then
    return logic_replay.IsOnlineUrl(playingFileTbl.info)
  end
  return false
end
function logic_replay.IsPlayingReplay()
  return isReplaying
end
function logic_replay.CheckPatchVersionMatch(filename)
  if not global_package_make_time_map or not next(global_package_make_time_map) then
    return true
  end
  local app_version = global_package_make_time_map["App Version"]
  local patch_version = global_patch_make_time_map["Patch Version"]
  if patch_version and not string.find(patch_version, "N/A") then
  else
    patch_version = app_version
  end
  log(bWriteLog and "patch_version: " .. patch_version .. " app_version: " .. app_version)
  log_tree(bWriteLog and "replay_version_table", replay_version_table)
  if LobbySystem.CheckOpen(BP_ENUM_WONDERFUL_REPLAY_VERSION_MATCH_SWITCH) then
    local jsonTbl = logic_replay.GetJsonTableByFilename(filename)
    if not jsonTbl then
      return false
    end
    for i, v in pairs(replay_version_table) do
      if v.mode_id == jsonTbl.ModeID and v.cur_ver == patch_version then
        local iFind = string.find(v.play_ver, jsonTbl.SrcVersion, 1, true)
        log(bWriteLog and "iFind " .. tostring(iFind))
        if iFind ~= nil then
          return true
        else
          log(bWriteLog and "[v_ywuyuan] CheckPatchVersionMatch small version match is false")
          return false
        end
      end
    end
  end
  return true
end
function logic_replay.GetReplayIsSelfDetail(filename)
  local jsonTbl = logic_replay.GetJsonTableByFilename(filename)
  if jsonTbl and jsonTbl.UID and tostring(jsonTbl.UID) == tostring(DataMgr.roleData.uid) then
    return OWNER.SELF
  end
  return OWNER.OTHER
end
function logic_replay.SetCheckUIDFlag(flag)
  isNeedCheckUID = flag
end
function logic_replay.GetCheckUIDFlag()
  return isNeedCheckUID
end
function logic_replay.OnLogin()
  log(bWriteLog and "logic_replay.OnLogin")
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  BasicDataServerTable:GetOrReqData(data_config_marco.replay_version_table, logic_replay.InitCfg)
  local config = CDataTable.GetTableData("WonderfulReplayParamConfig", "MaxSaveReplayNum")
  if config and config.Value then
    logic_replay.SetMaxSaveCount(config.Value)
  end
  logic_replay.ReplayTipPopVersion = nil
  logic_replay.ReplaySwitchOpVersion = nil
  logic_replay.bHaveReplay = nil
  local SettingHandler = require("client.network.Protocol.SettingHandler")
  local SettingSystem = require("client.logic.setting.logic_setting")
  SettingHandler.send_get_custom_settings_new_req(SettingSystem.SettingPopVersion)
  SettingHandler.send_get_custom_settings_new_req(SettingSystem.SettingSwitchOpVersion)
end
function logic_replay.InitCfg(_, cfg)
  log_tree("[v_ywuyuan] logic_replay.replay_version_table cfg = ", cfg)
  if not cfg then
    return
  end
  replay_version_table = cfg
end
function logic_replay.Init()
  log(bWriteLog and "logic_replay.Init")
  EventSystem:unregistEvent(EVENTTYPE_INGAME_REPLAY, EVENTID_REPLAY_CLICK_REPLAY, logic_replay.GoWonderfulBackInBattle)
  EventSystem:unregistEvent(EVENTTYPE_SETTING, EVENTID_ON_GET_CUSTOM_SETTING_NEW_RSP, logic_replay.OnGetCustomSettingNew)
  EventSystem:unregistEvent(EVENTTYPE_SETTING, EVENTID_ON_SAVE_CUSTOM_SETTING_NEW_RSP, logic_replay.OnGetCustomSettingNew)
  EventSystem:unregistEvent(EVENTTYPE_INGAME_REPLAY, EVENTID_PERIOD_UPDATE, logic_replay.OnPeriodUpdate)
  EventSystem:registEvent(EVENTTYPE_INGAME_REPLAY, EVENTID_REPLAY_CLICK_REPLAY, logic_replay.GoWonderfulBackInBattle)
  EventSystem:registEvent(EVENTTYPE_SETTING, EVENTID_ON_GET_CUSTOM_SETTING_NEW_RSP, logic_replay.OnGetCustomSettingNew)
  EventSystem:registEvent(EVENTTYPE_SETTING, EVENTID_ON_SAVE_CUSTOM_SETTING_NEW_RSP, logic_replay.OnGetCustomSettingNew)
  EventSystem:registEvent(EVENTTYPE_INGAME_REPLAY, EVENTID_PERIOD_UPDATE, logic_replay.OnPeriodUpdate)
end
function logic_replay.OnModePostSwitch(preState, nextState)
  local curStatus = GameStatus.GetGameStatus()
  if curStatus == GameStatus.Lobby then
    local lastStatus = GameStatus.GetLastGameStatus()
    if lastStatus == GameStatus.Fighting then
      logic_replay.GoToLobby()
    end
  elseif curStatus == GameStatus.Login then
    logic_replay.GoToLogin()
  elseif curStatus == GameStatus.Fighting and not GameStatus.IsInMainCity() then
    logic_replay.GoToFight()
  end
end
function logic_replay.GoToLogin()
  isInitedSetting = false
  recordBeginFlag = false
  recordFunc = nil
  logic_replay.ReleaseResource()
  logic_replay.DoAfterPlayFunc()
  wonderful_play_lua_interface.StopReplay()
end
function logic_replay.GoToLobby()
  if recordBeginFlag then
    logic_replay.DoRecordFunc()
    logic_replay.HideOtherUI()
  end
  logic_replay.SetRecordFunc()
  recordBeginFlag = false
  logic_replay.DeleteCacheReplayFile()
  logic_replay.DoAfterPlayFunc()
  wonderful_play_lua_interface.StopReplay()
end
function logic_replay.GoToFight()
  recordBeginFlag = false
  logic_replay.ReleaseResource()
end
function logic_replay.DoPrePlayFunc(info, replay)
  print(bWriteLog and "logic_replay.DoPrePlayFunc")
  logic_replay.HandleMainCity()
  logic_replay.SetPlayingFileTbl(info, replay)
  logic_replay.RegisterReplayEvent()
  isReplaying = true
end
function logic_replay.DoAfterPlayFunc()
  print(bWriteLog and "logic_replay.DoAfterPlayFunc")
  logic_replay.SetPlayingFileTbl(nil, nil)
  logic_replay.unRegisterReplayEvent()
  isReplaying = false
end
function logic_replay.RegisterReplayEvent()
  logic_replay.unRegisterReplayEvent()
  print(bWriteLog and "logic_replay.RegisterReplayEvent")
  EventSystem:registEvent(EVENTTYPE_INGAME_REPLAY, EVENTID_RETURN_TO_LOBBY, logic_replay.BackToLobby)
  EventSystem:registEvent(EVENTTYPE_INGAME_REPLAY, EVENTID_REPLAY_CLICK_SENDCHAT, logic_replay.OpenSendChatUI)
  EventSystem:registEvent(EVENTTYPE_INGAME_REPLAY, EVENTID_REPLAY_CLICK_SHARE, logic_replay.ShowSharePopUI)
  EventSystem:registEvent(EVENTTYPE_INGAME_REPLAY, EVENTID_RETURN_TO_BATTLERESULT, logic_replay.BackToBattle)
  EventSystem:registEvent(EVENTTYPE_INGAME_REPLAY, EVENTID_PLAY_REPLAY_FILE, logic_replay.PlayReplayFileException)
  eventFlag = true
end
function logic_replay.unRegisterReplayEvent()
  print(bWriteLog and "logic_replay.unRegisterReplayEvent", eventFlag)
  if eventFlag then
    EventSystem:unregistEvent(EVENTTYPE_INGAME_REPLAY, EVENTID_RETURN_TO_LOBBY, logic_replay.BackToLobby)
    EventSystem:unregistEvent(EVENTTYPE_INGAME_REPLAY, EVENTID_REPLAY_CLICK_SENDCHAT, logic_replay.OpenSendChatUI)
    EventSystem:unregistEvent(EVENTTYPE_INGAME_REPLAY, EVENTID_REPLAY_CLICK_SHARE, logic_replay.ShowSharePopUI)
    EventSystem:unregistEvent(EVENTTYPE_INGAME_REPLAY, EVENTID_RETURN_TO_BATTLERESULT, logic_replay.BackToBattle)
    EventSystem:unregistEvent(EVENTTYPE_INGAME_REPLAY, EVENTID_PLAY_REPLAY_FILE, logic_replay.PlayReplayFileException)
  end
  eventFlag = false
end
function logic_replay.GoWonderfulBackInBattle()
  logic_replay.RegisterReplayEvent()
  log(bWriteLog and "GoWonderfulBackInBattle")
  local filename = wonderful_play_lua_interface.GetNewestWonderfulFileName()
  logic_replay.InitReplayFileFromLocalFile()
  local prefix = DataMgr.roleData.uid .. "/"
  local infofile = prefix .. filename .. FileType.INFO
  local replayfile = prefix .. filename .. FileType.REPLAY
  logic_replay.SetPlayingFileTbl(infofile, replayfile)
end
function logic_replay.BackToBattle()
  log(bWriteLog and "BackToBattle")
  logic_replay.DoAfterPlayFunc()
end
function logic_replay.PlayReplayFileException(_, _, bNoException)
  log(bWriteLog and "PlayReplayFileException")
  if bNoException == false then
    logic_replay.BackToLobby()
  end
end
function logic_replay.BackToLobby()
  log(bWriteLog and "logic_replay OnBackToLobby")
  local LoadingSystem = require("client.slua.logic.loading.logic_loading")
  LoadingSystem.ShowLoading(true)
  logic_replay.DoAfterPlayFunc()
  recordBeginFlag = true
  local timer_tick = require("common.time_ticker")
  logic_replay.ReleaseLoadingTimer()
  loading_timer = timer_tick.AddTimerOnce(0.1, function()
    logic_replay.ReturnToLobby()
  end)
end
function logic_replay.ReturnToLobby()
  local ScriptHelperEngine = import("ScriptHelperEngine")
  if ScriptHelperEngine.IsLowMemoryDevice() then
    local gc_util = require("common.gc_util")
    gc_util.FullGC()
  end
  Client.ReturnToLobby(GameFrontendHUD)
end
function logic_replay.ShowReleaseMoment()
  log(bWriteLog and "logic_replay ShowReleaseMoment")
  if playingFileTbl and playingFileTbl.info and playingFileTbl.replay then
    local logic_moment_replay = require("client.slua.logic.moment.logic_moment_replay")
    logic_moment_replay.ShowMomentReleaseUI(playingFileTbl.info)
  end
end
function logic_replay.OpenSendChatUI()
  log(bWriteLog and "logic_replay OpenSendChatUI")
  if playingFileTbl and playingFileTbl.info and playingFileTbl.replay then
    local logic_share_replay = require("client.slua.logic.replay.logic_share_replay")
    logic_share_replay.OpenSendChatUI(nil, playingFileTbl.info, playingFileTbl.replay)
  end
end
function logic_replay.ShowSharePopUI()
  log(bWriteLog and "logic_replay ShowSharePopUI")
  if playingFileTbl and playingFileTbl.info and playingFileTbl.replay then
    local logic_share_replay = require("client.slua.logic.replay.logic_share_replay")
    logic_share_replay.OpenShareLinkUI(nil, playingFileTbl.info, playingFileTbl.replay)
  end
end
function logic_replay.SetRecordFunc(_recordFunc)
  recordFunc = _recordFunc
end
function logic_replay.DoRecordFunc()
  if type(recordFunc) == "function" then
    recordFunc()
  end
end
function logic_replay.reportTlog(logParas)
  if GameStatus.IsInLobbyOrMainCity() then
    table.insert(logParas, Main_Scene.LOBBY)
  else
    table.insert(logParas, Main_Scene.BATTLE)
  end
  logParas = replay_macro.SortLog(logParas)
  local logs = table.concat(logParas, ";")
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.WONDERFUL_REPLAY_TLOG_ID, 0, "REPLAY;" .. logs)
  log(bWriteLog and "[v_ywuyuan] : logic_replay reportTlog domain_id :REPLAY;" .. tostring(logs))
end
function logic_replay.send_share_replay_req(domain_id, replayName, source)
  local shareFileType = replay_macro.ShareFileType.LOCAL
  if string.find(replayName, "http") then
    shareFileType = replay_macro.ShareFileType.ONLINE
  end
  local ShareHandler = require("client.network.Protocol.ShareHandler")
  log(bWriteLog and "[v_ywuyuan] : send_share_replay_req domain_id : " .. tostring(domain_id) .. "replayName " .. tostring(replayName) .. "source " .. tostring(source) .. "fileType " .. tostring(shareFileType))
  ShareHandler.send_share_replay_req(domain_id, replayName, source, shareFileType)
end
local err_share_replay_level_state = 116100004
function logic_replay.on_share_replay_rsp(err, url, source, min_level)
  log(bWriteLog and "[v_ywuyuan] : on_share_replay_rsp err : " .. tostring(err) .. "url " .. tostring(url) .. "source " .. tostring(source) .. "min_level " .. tostring(min_level))
  if err == 0 then
    log(bWriteLog and "logic_replay.on_share_replay_rsp success")
    EventSystem:postEvent(EVENTTYPE_REPLAY, EVENTTYPE_REPLAY_SHARE_SUCCESS, url)
  else
    log(bWriteLog and "[v_wllwu] on_share_replay_rsp " .. tostring(err))
    if err == err_share_replay_level_state then
      ShowNotice(LocUtil.LocalizeResFormat(err, min_level))
    else
      ShowNotice(err)
    end
    EventSystem:postEvent(EVENTTYPE_REPLAY, EVENTTYPE_REPLAY_SHARE_FAIL, err, url)
  end
end
function logic_replay.send_share_replay_report(domain_id, replay_url, source)
  local ShareHandler = require("client.network.Protocol.ShareHandler")
  log(bWriteLog and "[v_ywuyuan] : send_share_replay_report domain_id : " .. tostring(domain_id) .. "replay_url " .. tostring(replay_url) .. "source " .. tostring(source))
  ShareHandler.send_share_replay_report(domain_id, replay_url, source)
end
function logic_replay.RefreshBaseVideoInfo(jsonInfo, uiTbl)
  if jsonInfo == nil or uiTbl == nil then
    return
  end
  log_tree(bWriteLog and "logic_replay.RefreshBaseVideoInfo jsonInfo:", jsonInfo)
  local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
  local profile = LobbySocialSystem.GetProfileByUID(jsonInfo.UID)
  if profile then
    uiTbl.TextBlock_CompletePlayerName:SetText(LocUtil.LocalizeResFormat(25611, profile.nickName))
  end
  logic_replay.RefreshRoleRank(jsonInfo, uiTbl)
  if uiTbl.TextBlock_CompleteModeName then
    local logic_mode_utils = require("client.slua.logic.mode_selection.logic_mode_utils")
    local mapName = logic_mode_utils.GetModeNameByModeID(jsonInfo.ModeID)
    uiTbl.TextBlock_CompleteModeName:SetText(mapName)
  end
  if uiTbl.TextBlock_CompletePlayerTime then
    uiTbl.TextBlock_CompletePlayerTime:SetText(LocUtil.LocalizeResFormat(25613, logic_replay.GetBattleSaveTime(jsonInfo.SaveTimestamp) or ""))
  end
  if uiTbl.TextBlock_CompleteDetail then
    uiTbl.TextBlock_CompleteDetail:SetText(logic_replay.GetTitleByInfo(jsonInfo.TypeInfoArray))
  end
  logic_replay.RefreshRoleImage(jsonInfo, uiTbl)
end
function logic_replay.RefreshRoleRank(jsonInfo, uiTbl)
  if not (uiTbl and uiTbl.Common_RankIntegralLevel_UIBP) or not uiTbl.CanvasPanel_RankIntegralLevel then
    return
  end
  uiTbl.CanvasPanel_RankIntegralLevel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  local modeID = jsonInfo.ModeID or 0
  local LogicPeakGameUtil = require("client.logic.PeakGame.LogicPeakGameUtil")
  local isPeakGame = LogicPeakGameUtil.IsPeakGameMode(modeID)
  log(bWriteLog and "logic_replay.RefreshRoleRank. isPeakGameMode" .. tostring(isPeakGame))
  local LogicTxMissionMatch = require("client.slua.logic.TxMission.match.logic_xmission_match")
  local UIBase = uiTbl.UIBase
  local PeakGame_RankIntegralLevel_Style_Small_UIBP
  if UIBase then
    if uiTbl.Image_PeakGame then
      UIBase:SetWidgetVisible(uiTbl.Image_PeakGame, isPeakGame)
    end
    local widget = uiTbl.PeakGame_RankIntegralLevel_Style_Small_UIBP
    log(bWriteLog and "logic_replay.RefreshRoleRank. widget is " .. tostring(widget))
    if widget then
      UIBase:SetWidgetVisible(widget, isPeakGame)
      if isPeakGame then
        PeakGame_RankIntegralLevel_Style_Small_UIBP = LogicPeakGameUtil.InitSmallPeakRankIntegralWidget(UIBase, widget)
      end
    end
    if uiTbl.Common_RankIntegralLevel_UIBP then
      UIBase:SetWidgetVisible(uiTbl.Common_RankIntegralLevel_UIBP, not isPeakGame)
    end
  end
  local visibility = UEnums.ESlateVisibility.SelfHitTestInvisible
  if isPeakGame and jsonInfo.AdditionData and jsonInfo.AdditionData.PeakSegmentID then
    uiTbl.CanvasPanel_RankIntegralLevel:SetWidgetVisibility(visibility)
    log(bWriteLog and "logic_replay.RefreshRoleRank. PeakSegmentID = " .. tostring(jsonInfo.AdditionData.PeakSegmentID))
    if PeakGame_RankIntegralLevel_Style_Small_UIBP then
      PeakGame_RankIntegralLevel_Style_Small_UIBP:SetPeakRankIntegral(tonumber(jsonInfo.AdditionData.PeakSegmentID))
    end
  elseif LogicTxMissionMatch.IsXMissionMode(modeID) then
    log(bWriteLog and "logic_replay.RefreshRoleRank XMission")
    if jsonInfo.AdditionData then
      local militaryLevel = tonumber(jsonInfo.AdditionData.Military or 0)
      log(bWriteLog and "logic_replay.RefreshRoleRank militaryLevel:" .. tostring(militaryLevel))
      if 26 <= militaryLevel then
        uiTbl.CanvasPanel_RankIntegralLevel:SetWidgetVisibility(visibility)
        uiTbl.Common_RankIntegralLevel_UIBP:SetRankInteralInXMission(militaryLevel)
      end
    end
  elseif jsonInfo.SegmentLevel >= 601 then
    uiTbl.CanvasPanel_RankIntegralLevel:SetWidgetVisibility(visibility)
    uiTbl.Common_RankIntegralLevel_UIBP:SetRankInteral(jsonInfo.SegmentLevel, nil)
  end
end
function logic_replay.RefreshRoleImage(jsonInfo, uiTbl)
  if not uiTbl or not uiTbl.Image_Role then
    return
  end
  local mode = jsonInfo.ModeID or 0
  local LogicTxMissionMatch = require("client.slua.logic.TxMission.match.logic_xmission_match")
  if LogicTxMissionMatch.IsXMissionMode(mode) then
    uiTbl.Image_Role:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    local util = require("client.slua_ui_framework.util")
    util.SetTexture(uiTbl.Image_Role, "/Game/UMG/Texture/Lobby_NoAtlas/TShare_Video_BG02.TShare_Video_BG02")
  elseif logic_replay.HideRoleModeList[mode] then
    uiTbl.Image_Role:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    uiTbl.Image_Role:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    local util = require("client.slua_ui_framework.util")
    util.SetTexture(uiTbl.Image_Role, "/Game/UMG/Texture/Lobby_NoAtlas/Share_Video_BG1.Share_Video_BG1")
  end
end
function logic_replay.HideOtherUI()
  if UIManager.IsUIShow(UIManager.UI_Config.ui_season_switch_mgr) then
    UIManager.CloseUI(UIManager.UI_Config.ui_season_switch_mgr)
  end
  local NewFaceSlapSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NewFaceSlapSystem)
  NewFaceSlapSystem:BlockSlap()
end
function logic_replay.ReleaseLoadingTimer()
  if loading_timer then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(loading_timer)
    loading_timer = nil
  end
end
function logic_replay.ReleaseResource()
  replayMapCache = {}
  replayDataMap = {}
  bReadFlag = false
  bMoveFile = false
end
function logic_replay.OnGetCustomSettingNew(_, __, page_name, settings)
  local SettingSystem = require("client.logic.setting.logic_setting")
  if page_name == SettingSystem.SettingPopVersion then
    logic_replay.ReplayTipPopVersion = settings
  elseif page_name == SettingSystem.SettingSwitchOpVersion then
    logic_replay.ReplaySwitchOpVersion = settings
  end
end
function logic_replay.OnPeriodUpdate()
  local uGameState = slua_GameFrontendHUD:GetGameState()
  if slua.isValid(uGameState) then
    log(bWriteLog and "[WonderfulReplayTip] logic_replay.OnPeriodUpdate EGameModeType " .. tostring(uGameState.GameModeType))
    local EGameModeType = import("EGameModeType")
    if uGameState.GameModeType == EGameModeType.ETypicalGameMode or uGameState.GameModeType == EGameModeType.EActivityGameMode then
      logic_replay.bHaveReplay = true
    end
  end
end
function logic_replay.ShowWonderfulReplaySwitchTip()
  local bHave = logic_replay.bHaveReplay
  logic_replay.bHaveReplay = false
  if not bHave then
    log(bWriteLog and "[WonderfulReplayTip] logic_replay.bHaveReplay false")
    return
  end
  local SettingBasic = require("client.slua.logic.setting.logic_setting_basic")
  local WonderfulReplaySwitch = SettingBasic.GetOneSettingValue("bRecordWonderfulReplayOpen")
  if WonderfulReplaySwitch == true then
    log(bWriteLog and "[WonderfulReplayTip] bRecordWonderfulReplayOpen false")
    return
  end
  local version_util = require("client.common.version_util")
  local OriginVersion = Client.GetAppVersion()
  local ClientVersion = version_util.GetMainFormat(OriginVersion)
  local uCfg = CDataTable.GetTableData("TriggerOpenRecommend", ClientVersion)
  if not uCfg then
    log(bWriteLog and string.format("[WonderfulReplayTip] [%s] is nil", uCfg))
    return
  end
  local open_time = uCfg.StartTime
  if not open_time then
    log(bWriteLog and string.format("[WonderfulReplayTip] OriginVersion[%s] ClientVersion[%s] not tip", OriginVersion, ClientVersion))
    return
  end
  if open_time ~= "" then
    local TimeUtil = require("client.common.time_util")
    local time = TimeUtil.TimeStringToUnixstamp(open_time, nil)
    local now = TimeUtil.GetServerTimeInSec()
    if time > now then
      log(bWriteLog and string.format("[WonderfulReplayTip] Not reach open time [%s]", open_time))
      return
    end
  end
  if logic_replay.ReplaySwitchOpVersion and not (version_util.CompareVersionStandard(ClientVersion, logic_replay.ReplaySwitchOpVersion) > 0) then
    log(bWriteLog and string.format("[WonderfulReplayTip] Change wondeful replay switch recently[%s]", logic_replay.ReplaySwitchOpVersion))
    return
  end
  if logic_replay.ReplayTipPopVersion and not (0 < version_util.CompareVersionStandard(ClientVersion, logic_replay.ReplayTipPopVersion)) then
    log(bWriteLog and string.format("[WonderfulReplayTip] ReplayTipPopVersion[%s], ClientVersion[%s] already pop tip", logic_replay.ReplayTipPopVersion, ClientVersion))
    return
  end
  local content = LocUtil.GetLocalizeResStr(44746)
  local jumpBtn = {
    callback = function()
      log(bWriteLog and "[WonderfulReplayTip] Wonderful replay popup tip jump")
      local SettingUtil = require("client.slua.logic.setting.setting_util")
      local SettingMacro = require("client.slua.logic.setting.setting_macro")
      SettingUtil.Enter("Game", {
        jumpKey = "bRecordWonderfulReplayOpen",
        bForceHighlight = true
      })
      local BasicDataTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataTLogReport)
      BasicDataTLogReport:ReportDelay(TLogEventDefine.ClickWonderfulReplaySwitchPopup)
    end
  }
  local onShowCallback = function()
    log(bWriteLog and "[WonderfulReplayTip] Wonderful replay popup tip on show")
    local SettingHandler = require("client.network.Protocol.SettingHandler")
    local SettingSystem = require("client.logic.setting.logic_setting")
    SettingHandler.send_save_custom_settings_new_req(SettingSystem.SettingPopVersion, ClientVersion)
  end
  local BasicDataTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataTLogReport)
  BasicDataTLogReport:ReportDelay(TLogEventDefine.ShowWonderfulReplaySwitchPopup)
  local RightPopSystem = require("client.slua.logic.lobby_popui.logic_right_popup")
  RightPopSystem.ShowPopupTip(content, true, nil, jumpBtn, 10, nil, onShowCallback)
end
function IsWonderfulReplayOpen()
  return LobbySystem.CheckOpen(BP_ENUM_WONDERFUL_REPLAY_SWITCH)
end
return logic_replay