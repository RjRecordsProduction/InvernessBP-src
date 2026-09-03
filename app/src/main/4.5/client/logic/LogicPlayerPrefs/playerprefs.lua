local PlayerPrefsSystem = {
  fileFolder = "SaveGames/%s.json",
  UIElemLayoutObjectDict = {},
  FriendHistoryChat = {}
}
local local local local local local string_format = string.format
local string_sub = string.sub
local json = require("common.json_util")
local PlayerPrefsConfig = require("client.slua.config.PlayerPrefsConfig")
local TimeUtil = require("client.common.time_util")
PlayerPrefsSystem.ePlayerPrefsType = PlayerPrefsConfig
local _SaveTableToFile = function(tableData, fileType, needOpenIDTag, outSavePath)
  local LogicPlayerPrefs = require("client.logic.LogicPlayerPrefs.LogicPlayerPrefs")
  LogicPlayerPrefs.SaveDataToFile(tableData, fileType, needOpenIDTag, outSavePath)
end
local _LoadFileToTable = function(fileType, needOpenIDTag, outSavePath)
  local record
  xpcall(function()
    local LogicPlayerPrefs = require("client.logic.LogicPlayerPrefs.LogicPlayerPrefs")
    record = LogicPlayerPrefs.LoadFileToData(fileType, needOpenIDTag, outSavePath)
  end, require("common.utility").ErrorMessageHandler)
  return record
end
function PlayerPrefsSystem.Init()
  log(bWriteLog and "[PlayerPrefsSystem]init")
  PlayerPrefsSystem.FriendHistoryChat = {}
end
function PlayerPrefsSystem.SaveTableToFile_DynamicPath(tableData, fileType, pathTail)
  local fullFileName = string_format("%s/%s", fileType.path, pathTail)
  _SaveTableToFile(tableData, fullFileName, fileType.needOpenIDTag, fileType.outSavePath)
end
function PlayerPrefsSystem.LoadFileToTable_DynamicPath(fileType, pathTail)
  local fullFileName = string_format("%s/%s", fileType.path, pathTail)
  return _LoadFileToTable(fullFileName, fileType.needOpenIDTag, fileType.outSavePath)
end
function PlayerPrefsSystem.SaveTableToFile_N(tableData, fileType)
  if fileType == nil then
    log_error("PlayerPrefsSystem.SaveTableToFile_N: fileType is nil!")
    return
  end
  if fileType.path == nil then
    log_error("PlayerPrefsSystem.SaveTableToFile_N: fileType.path is nil! fileType: " .. tostring(fileType))
    return
  end
  local LogicPlayerPrefs = require("client.logic.LogicPlayerPrefs.LogicPlayerPrefs")
  LogicPlayerPrefs.SaveDataToFile(tableData, fileType.path, fileType.needOpenIDTag, fileType.outSavePath)
end
function PlayerPrefsSystem.LoadFileToTable_N(fileType)
  if fileType == nil then
    log_error("PlayerPrefsSystem.LoadFileToTable_N: fileType is nil!")
    return nil
  end
  if fileType.path == nil then
    log_error("PlayerPrefsSystem.LoadFileToTable_N: fileType.path is nil! fileType: " .. tostring(fileType))
    return nil
  end
  return _LoadFileToTable(fileType.path, fileType.needOpenIDTag, fileType.outSavePath)
end
function PlayerPrefsSystem.SaveTableToFileByFileName(table, fileName)
  local fullFileName = string_format("SaveGames/%s.json", fileName)
  local saveStr = json.encode(table)
  Client.SaveStringToFile(saveStr, fullFileName)
end
function PlayerPrefsSystem.LoadFileToTableByFileName(fileName)
  local fullFileName = string_format("SaveGames/%s.json", fileName)
  local str = Client.LoadFileToString(fullFileName)
  if str and str ~= "" then
    local data = json.decode(str)
    return data
  end
  return nil
end
local C_UGCLOG_COOKIE_LENGTH = 10
function PlayerPrefsSystem._UGCMagicNum(content)
  print(bWriteLog and bWritelog and "PlayerPrefsSystem._UGCMagicNum")
  local UCreativeModeBlueprintLibrary = import("CreativeModeBlueprintLibrary")
  local BinaryDataMd5 = UCreativeModeBlueprintLibrary.MD5HashByteArray(content)
  print(bWriteLog and "PlayerPrefsSystem.SaveUGCLogTableToFileByFileName, Md5: " .. BinaryDataMd5)
  local FNV_offset_basis = 2166136261
  local FNV_prime = 16777619
  local hash = FNV_offset_basis
  for i = 1, #BinaryDataMd5 do
    hash = hash * FNV_prime % 4294967296
    hash = hash ~ BinaryDataMd5:byte(i)
  end
  local shift = 5
  hash = hash << shift | hash >> 32 - shift
  local maxLength = C_UGCLOG_COOKIE_LENGTH
  hash = string_format("%0" .. maxLength .. "d", hash)
  hash = string_sub(tostring(hash), 1, maxLength)
  hash = tostring(hash)
  return hash
end
function PlayerPrefsSystem.SaveUGCLogTableToFileByFileName(table, fileName)
  local startTime = TimeUtil.GetMiliseconds()
  local saveStr = json.encode(table)
  local UCreativeModeBlueprintLibrary = import("CreativeModeBlueprintLibrary")
  saveStr = UCreativeModeBlueprintLibrary.EncryptToBase64(saveStr)
  local cookie = PlayerPrefsSystem._UGCMagicNum(saveStr)
  saveStr = cookie .. saveStr
  local openID = DataMgr.roleData.openID
  local fullFileName = string_format("SaveGames/WoWLog/%s/wowlog_%s.ugclog", openID, fileName)
  Client.SaveStringToFile(saveStr, fullFileName)
  local useTime = TimeUtil.GetMiliseconds() - startTime
  log(bWriteLog and "PlayerPrefsSystem.SaveUGCLogTableToFileByFileName filePath:" .. fileName .. "use time:" .. useTime)
end
function PlayerPrefsSystem.LoadUGCLogToTableByFileName(fileName)
  print(bWriteLog and "PlayerPrefsSystem.LoadUGCLogToTableByFileName " .. tostring(fileName))
  local tgtfilename = string_format("wowlog_%s.ugclog", fileName)
  local files = PlayerPrefsSystem.ListAllUGCLogs()
  local bFound = false
  for i, filename in pairs(files) do
    if filename == tgtfilename then
      bFound = true
    end
  end
  if bFound then
    local openID = DataMgr.roleData.openID
    local fullFileName = string_format("SaveGames/WoWLog/%s/%s", openID, tgtfilename)
    local content = Client.LoadFileToString(fullFileName)
    local retrieveCookie = string_sub(content, 1, C_UGCLOG_COOKIE_LENGTH)
    local rawcontent = string_sub(content, C_UGCLOG_COOKIE_LENGTH + 1)
    local expectedCookie = PlayerPrefsSystem._UGCMagicNum(rawcontent)
    if retrieveCookie == expectedCookie then
      local UCreativeModeBlueprintLibrary = import("CreativeModeBlueprintLibrary")
      content = UCreativeModeBlueprintLibrary.DecryptFromBase64(rawcontent)
      return json.decode(content)
    else
      print(bWriteLog and "PlayerPrefsSystem.LoadUGCLogToTableByFileName failed magic num check")
    end
  else
    print(bWriteLog and "PlayerPrefsSystem.LoadUGCLogToTableByFileName failed to find file")
  end
end
function PlayerPrefsSystem.ListAllUGCLogs()
  local openID = DataMgr and DataMgr.roleData.openID or 0
  local fullDirName = string_format("SaveGames/WoWLog/%s", openID)
  return Client.ListDirectoryFiles(fullDirName)
end
function PlayerPrefsSystem.IsUGCLogExist(tgtfilename)
  if tgtfilename == nil then
    print(bWriteLog and "PlayerPrefsSystem.IsUGCLogExist name is nil")
    return false
  end
  local files = PlayerPrefsSystem.ListAllUGCLogs()
  tgtfilename = string_format("wowlog_%s.ugclog", tgtfilename)
  for i, filename in pairs(files) do
    if tgtfilename == filename then
      return true
    end
  end
  return false
end
function PlayerPrefsSystem.DeleteUGCLog(tgtfilename)
  local openID = DataMgr.roleData.openID or "0"
  if tgtfilename == nil then
    print(bWriteLog and "PlayerPrefsSystem.DeleteUGCLog name is nil")
    return false
  end
  tgtfilename = string_format("wowlog_%s.ugclog", tgtfilename)
  local files = PlayerPrefsSystem.ListAllUGCLogs()
  for i, filename in pairs(files) do
    if tgtfilename == filename then
      local filePath = string_format("%sSaveGames/WoWLog/%s/%s", Client.ProjectSavedDir(), tostring(openID), filename)
      local result = Client.DeleteFile(filePath)
      log(bWriteLog and "PlayerPrefsSystem.DeleteUGCLog delete filepath " .. filePath .. " " .. tostring(result))
    end
  end
end
function PlayerPrefsSystem.SaveFriendHistroyChat(table, fileName, key)
  PlayerPrefsSystem.FriendHistoryChat[key] = table
  local filePath = string_format("SaveGames/%s.json", fileName)
  local saveStr = json.encode(table)
  Client.SaveStringToFile(saveStr, filePath)
end
function PlayerPrefsSystem.LoadFriendHistroyChat(fileName, key)
  if PlayerPrefsSystem.FriendHistoryChat[key] ~= nil then
    return PlayerPrefsSystem.FriendHistoryChat[key]
  end
  local filePath = string_format("SaveGames/%s.json", fileName)
  log(bWriteLog and "god test filepath " .. filePath)
  local str = Client.LoadFileToString(filePath)
  if str == nil or str == "" then
    return nil
  else
    local data = json.decode(str)
    PlayerPrefsSystem.FriendHistoryChat[key] = data
    return data
  end
end
function PlayerPrefsSystem.DeleteFriendHistoryChat(fileName, key)
  if PlayerPrefsSystem.FriendHistoryChat[key] ~= nil then
    PlayerPrefsSystem.FriendHistoryChat[key] = nil
  end
  local filePath = string_format("%s/SaveGames/%s.json", Client.ProjectSavedDir(), fileName)
  log(bWriteLog and "god test delete filepath " .. filePath)
  local result = Client.DeleteFile(filePath)
  if result then
    log(bWriteLog and "delete history chat suc!filepath is " .. filePath)
  else
    log_warning("delelte file failed!filepath is " .. filePath)
  end
end
function PlayerPrefsSystem.CheckAndSaveCurrentDate(fileType, bNeedOpenIDTag, bOnlyCheck, days)
  days = days or 1
  local bIsDifferentDate = false
  local curTime = TimeUtil.GetServerTimeInSec()
  local curDate = TimeUtil.OSDate("!*t", curTime)
  local curTimeWithZeroHMS = TimeUtil.UnixTimeToUnixstamp(curDate.year, curDate.month, curDate.day)
  local savedTable = _LoadFileToTable(fileType, bNeedOpenIDTag)
  if savedTable == nil then
    savedTable = {}
    bIsDifferentDate = true
  elseif savedTable.savedTime == nil then
    bIsDifferentDate = true
  else
    local daysToLastRecord = math.abs(curTimeWithZeroHMS - savedTable.savedTime) / 86400
    bIsDifferentDate = days <= daysToLastRecord
  end
  if bOnlyCheck or not bIsDifferentDate then
    return bIsDifferentDate
  end
  savedTable.savedTime = curTimeWithZeroHMS
  _SaveTableToFile(savedTable, fileType, bNeedOpenIDTag)
  return bIsDifferentDate
end
function PlayerPrefsSystem.CheckAndSaveCurrentDate_N(fileType, bOnlyCheck, days)
  return PlayerPrefsSystem.CheckAndSaveCurrentDate(fileType.path, fileType.needOpenIDTag, bOnlyCheck, days)
end
function PlayerPrefsSystem.CheckAndSaveCurrentDate_DynamicPath(fileType, pathTail, bOnlyCheck, days)
  local fullFileName = string_format("%s/%s", fileType.path, pathTail)
  return PlayerPrefsSystem.CheckAndSaveCurrentDate(fullFileName, fileType.needOpenIDTag, bOnlyCheck, days)
end
function PlayerPrefsSystem.CheckAndSaveCurInt(fileType, bNeedOpenIDTag, intValue, bOnlyCheck, days)
  days = days or 1
  local curTime = TimeUtil.GetServerTimeInSec()
  local curDate = TimeUtil.OSDate("!*t", curTime)
  local curTimeWithZeroHMS = TimeUtil.UnixTimeToUnixstamp(curDate.year, curDate.month, curDate.day)
  local savedTable = _LoadFileToTable(fileType, bNeedOpenIDTag)
  local savedIntValue = 0
  local isNewDay = false
  if savedTable == nil or savedTable.savedTime == nil then
    savedTable = {}
    isNewDay = true
  else
    local daysToLastRecord = math.abs(curTimeWithZeroHMS - (savedTable.savedTime or 0)) / 86400
    isNewDay = days <= daysToLastRecord
    savedIntValue = tonumber(savedTable.intValue) or 0
  end
  if isNewDay then
    savedIntValue = 0
  end
  local isDifValue = false
  if intValue ~= nil then
    isDifValue = savedIntValue ~= tonumber(intValue)
  end
  if bOnlyCheck and not isDifValue then
    return savedIntValue, isNewDay
  end
  if intValue == nil and bOnlyCheck then
    return savedIntValue, isNewDay
  end
  if intValue ~= nil and not isDifValue and not isNewDay then
    return savedIntValue, false
  end
  savedTable.savedTime = curTimeWithZeroHMS
  savedTable.intValue = tonumber(intValue) or savedIntValue
  _SaveTableToFile(savedTable, fileType, bNeedOpenIDTag)
  return savedTable.intValue, true
end
function PlayerPrefsSystem.CheckAndSaveCurInt_N(fileType, intValue, bOnlyCheck, days)
  return PlayerPrefsSystem.CheckAndSaveCurInt(fileType.path, fileType.needOpenIDTag, intValue, bOnlyCheck, days)
end
function PlayerPrefsSystem.CheckAndSaveCurInt_DynamicPath(fileType, pathTail, intValue, bOnlyCheck, days)
  local fullFileName = string_format("%s/%s", fileType.path, pathTail)
  return PlayerPrefsSystem.CheckAndSaveCurInt(fullFileName, fileType.needOpenIDTag, intValue, bOnlyCheck, days)
end
return PlayerPrefsSystem