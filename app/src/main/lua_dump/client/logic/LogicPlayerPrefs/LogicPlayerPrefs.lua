local LogicPlayerPrefs = {
  fileFolder = "SaveGames/%s.json",
  PlayerDataDict = {}
}
local local local local local local local local local string_format = string.format
local json = require("common.json_util")
local mmkvPlayerPrefs = require("client.logic.LogicPlayerPrefs.mmkv_playerprefs")
local PlayerPrefsConfig = require("client.slua.config.PlayerPrefsConfig")
local StringUtil = require("common.string_util")
function LogicPlayerPrefs.Init()
  log(bWriteLog and "LogicPlayerPrefs -- init")
  LogicPlayerPrefs.PlayerDataDict = {}
end
function LogicPlayerPrefs.SaveDataToFile_N(tableData, fileType)
  if fileType == nil then
    log_error("logicplayerprefs --- SaveDataToFile_N: fileType is nil!")
    return
  end
  if fileType.path == nil then
    log_error("logicplayerprefs --- SaveDataToFile_N: fileType.path is nil! fileType: " .. tostring(fileType))
    return
  end
  LogicPlayerPrefs.SaveDataToFile(tableData, fileType.path, fileType.needOpenIDTag, fileType.outSavePath)
end
function LogicPlayerPrefs.SaveDataToFile(tableData, fileType, needOpenIDTag, outSavePath)
  if not LogicPlayerPrefs.CheckSaveDataValid(tableData, fileType) then
    log_error("logicplayerprefs --- SaveTableToFile save fail!")
    return
  end
  if type(tableData) == "table" and getmetatable(tableData) then
    local TableUtil = require("common.table_util")
    tableData = TableUtil.CopyTable(tableData)
    log_error("logicplayerprefs --- dont save a table that has metatable!")
  end
  if needOpenIDTag and (not (DataMgr and DataMgr.roleData) or not DataMgr.roleData.openID) then
    log_warning("LogicPlayerPrefs.SaveDataToFile --- DataMgr or openID is nil! fileType:" .. tostring(fileType))
    needOpenIDTag = false
  end
  LogicPlayerPrefs.PlayerDataDict[fileType] = tableData
  local fileName = fileType or PlayerPrefsConfig.eDefault
  local filePath
  if needOpenIDTag then
    filePath = string_format("SaveGames/%s_%s.json", fileName, tostring(DataMgr.roleData.openID))
  else
    filePath = string_format("SaveGames/%s.json", fileName)
  end
  if outSavePath then
    local pos = StringUtil.StrFind(filePath, "/")
    if pos then
      filePath = filePath:sub(1, pos) .. "Intermediate/" .. filePath:sub(pos + 1)
    end
    local saveStr = slua.LuaArchiverEncode(LuaStateWrapper, tableData)
    mmkvPlayerPrefs.SaveIntermediateData(filePath, saveStr)
  else
    local saveStr = ""
    pcall(function(...)
      saveStr = slua.LuaArchiverEncode(LuaStateWrapper, tableData)
    end)
    if needOpenIDTag then
      mmkvPlayerPrefs.SaveRoleData(filePath, saveStr)
    else
      mmkvPlayerPrefs.SaveGameData(filePath, saveStr)
    end
  end
end
function LogicPlayerPrefs.LoadFileToData_N(fileType)
  if fileType == nil then
    log_error("logicplayerprefs --- LoadFileToData_N: fileType is nil!")
    return nil
  end
  return LogicPlayerPrefs.LoadFileToData(fileType.path, fileType.needOpenIDTag, fileType.outSavePath)
end
function LogicPlayerPrefs.LoadFileToData(fileType, needOpenIDTag, outSavePath)
  if fileType == nil then
    log_error("logicplayerprefs --- LoadFileType is nil!")
    return nil
  end
  if LogicPlayerPrefs.PlayerDataDict[fileType] ~= nil then
    return LogicPlayerPrefs.PlayerDataDict[fileType]
  end
  if needOpenIDTag and (not (DataMgr and DataMgr.roleData) or not DataMgr.roleData.openID) then
    log_warning("LogicPlayerPrefs.LoadFileToData --- DataMgr or openID is nil! fileType:" .. tostring(fileType))
    needOpenIDTag = false
  end
  local fileName = fileType or PlayerPrefsConfig.eDefault
  local filePath
  if needOpenIDTag then
    filePath = string_format("SaveGames/%s_%s.json", fileName, tostring(DataMgr.roleData.openID))
  else
    filePath = string_format("SaveGames/%s.json", fileName)
  end
  local str
  local isJsonData = false
  local bMMKVInit = false
  local data
  if outSavePath then
    local pos = StringUtil.StrFind(filePath, "/")
    if pos then
      filePath = filePath:sub(1, pos) .. "Intermediate/" .. filePath:sub(pos + 1)
    end
    str = mmkvPlayerPrefs.LoadIntermediateData(filePath)
    if str == "" then
      str = Client.LoadIntermediateFileToString(filePath)
      isJsonData = true
    end
  elseif needOpenIDTag then
    str = mmkvPlayerPrefs.LoadRoleData(filePath)
  else
    str = mmkvPlayerPrefs.LoadGameData(filePath)
  end
  if str == nil or str == "" then
    log(bWriteLog and "logicplayerprefs --- LoadFileToData  str is nil! fileType:" .. tostring(fileType))
  elseif isJsonData then
    data = json.decode(str)
    if data and type(data) == "table" then
      setmetatable(data, nil)
    end
    LogicPlayerPrefs.SaveDataToFile(data, fileType, needOpenIDTag, outSavePath)
  else
    local utility = require("common.utility")
    xpcall(function()
      data = slua.LuaArchiverDecode(LuaStateWrapper, str)
    end, utility.ErrorMessageHandler)
  end
  LogicPlayerPrefs.PlayerDataDict[fileType] = data
  return data
end
function LogicPlayerPrefs.CheckSaveDataValid(tableData, fileType)
  local dt = type(tableData)
  if not tableData or dt ~= "number" and dt ~= "string" and dt ~= "table" then
    log_error("logicplayerprefs --- CheckSaveDataValid dont save type " .. type(tableData) .. " as local data")
    return false
  end
  if not fileType or fileType == "" then
    log_error("logicplayerprefs --- CheckSaveDataValid filetype is nil or empty!")
    return false
  end
  if Client.IsDevelopment() and not LogicPlayerPrefs.IsValid(tableData) then
    log_error("logicplayerprefs --- CheckSaveDataValid Invalid tabledata\239\188\129")
    return false
  end
  return true
end
function LogicPlayerPrefs.CheckTableValueValid(saveData, visitedData)
  local valid = true
  visitedData = visitedData or {}
  for k, v in pairs(saveData or {}) do
    local kt = type(k)
    if kt ~= "string" and kt ~= "number" then
      valid = false
      log_error("type " .. kt .. " is not supported as a key by luaarchieve!")
      break
    end
    local vt = type(v)
    if vt == "table" then
      if visitedData[vt] then
        goto lbl_57
      end
      visitedData[vt] = true
      valid = LogicPlayerPrefs.CheckTableValueValid(v)
      if not valid then
        break
      end
    elseif vt ~= "number" and vt ~= "string" and vt ~= "boolean" then
      valid = false
      log_error("type " .. vt .. " is not supported as a value by luaarchieve!")
      break
    end
    ::lbl_57::
  end
  return valid
end
function LogicPlayerPrefs.IsValid(saveData)
  local valid = true
  local dataType = type(saveData)
  if dataType == "table" then
    valid = LogicPlayerPrefs.CheckTableValueValid(saveData)
  elseif dataType ~= "number" and dataType ~= "string" and dataType ~= "boolean" then
    valid = false
    log_error("type " .. saveData .. " is not supported as a value by luaarchieve!")
  end
  return valid
end
function LogicPlayerPrefs.SaveMMKVSwitcher(switch)
  log(bWriteLog and "logicplayerprefs --- SaveMMKVSwitcher")
  local data = {is_open = switch}
  local fileName = PlayerPrefsConfig.eNewPlayerprefsSwitcher
  local filePath = string_format(LogicPlayerPrefs.fileFolder, fileName)
  local newStr = json.encode(data)
  Client.SaveStringToFile(newStr, filePath)
end
return LogicPlayerPrefs