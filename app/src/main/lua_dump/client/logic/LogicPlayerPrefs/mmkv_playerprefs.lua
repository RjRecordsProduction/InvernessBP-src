local mmkv_playerprefs = {
  roleData = nil,
  gameData = nil,
  intermediateData = nil,
  openId = nil,
  setErrorHandle = false
}
local local local string_format = string.format
local 
function mmkv_playerprefs.InitRoleData()
  if mmkv_playerprefs.openId == DataMgr.roleData.openID and mmkv_playerprefs.roleData then
    log(bWriteLog and " mmkv_playerprefs.InitRoleData has init")
    return
  end
  if DataMgr.roleData.openID == 0 or DataMgr.roleData.openID == nil then
    log(bWriteLog and " mmkv_playerprefs.InitRoleData openID is nil")
    return
  end
  if mmkv_playerprefs.roleData then
    log(bWriteLog and "destroy roledata")
    mmkv_playerprefs.roleData = nil
  end
  local MMKVObject = import("MMKVObject")
  local mmkvObj = MMKVObject()
  local fileName = string_format("PlayerPrefs_%s", tostring(DataMgr.roleData.openID))
  mmkvObj:Init(fileName, "")
  mmkv_playerprefs.roleData = mmkvObj
  mmkv_playerprefs.openId = DataMgr.roleData.openID
  log(bWriteLog and "destroy create roledata")
end
function mmkv_playerprefs.InitGameData()
  if mmkv_playerprefs.gameData then
    return
  end
  local MMKVObject = import("MMKVObject")
  local mmkvObj = MMKVObject()
  local fileName = string_format("PlayerPrefs")
  mmkvObj:Init(fileName, "")
  mmkv_playerprefs.gameData = mmkvObj
  log(bWriteLog and "destroy create gameData")
end
function mmkv_playerprefs.InitIntermediateData()
  if mmkv_playerprefs.intermediateData then
    return
  end
  local MMKVObject = import("MMKVObject")
  local mmkvObj = MMKVObject()
  local fileName = string_format("Intermediates")
  mmkvObj:Init(fileName, "")
  mmkv_playerprefs.intermediateData = mmkvObj
  log(bWriteLog and "destroy create intermediateData")
end
function mmkv_playerprefs.SaveRoleData(key, strData)
  if not mmkv_playerprefs.roleData or mmkv_playerprefs.openId ~= DataMgr.roleData.openID then
    mmkv_playerprefs.InitRoleData()
  end
  if mmkv_playerprefs.roleData then
    return mmkv_playerprefs.roleData:SetBuffer(tostring(key), strData)
  else
    return false
  end
end
function mmkv_playerprefs.LoadRoleData(key)
  if not mmkv_playerprefs.roleData or mmkv_playerprefs.openId ~= DataMgr.roleData.openID then
    mmkv_playerprefs.InitRoleData()
  end
  if mmkv_playerprefs.roleData then
    return mmkv_playerprefs.roleData:GetBuffer(tostring(key))
  else
    return ""
  end
end
function mmkv_playerprefs.SaveGameData(key, strData)
  if not mmkv_playerprefs.gameData then
    mmkv_playerprefs.InitGameData()
  end
  return mmkv_playerprefs.gameData:SetBuffer(tostring(key), strData)
end
function mmkv_playerprefs.LoadGameData(key)
  if not mmkv_playerprefs.gameData then
    mmkv_playerprefs.InitGameData()
  end
  return mmkv_playerprefs.gameData:GetBuffer(tostring(key))
end
function mmkv_playerprefs.SaveIntermediateData(key, strData)
  if not mmkv_playerprefs.intermediateData then
    mmkv_playerprefs.InitIntermediateData()
  end
  return mmkv_playerprefs.intermediateData:SetBuffer(tostring(key), strData)
end
function mmkv_playerprefs.LoadIntermediateData(key)
  if not mmkv_playerprefs.intermediateData then
    mmkv_playerprefs.InitIntermediateData()
  end
  return mmkv_playerprefs.intermediateData:GetBuffer(tostring(key))
end
local OnLogout = function()
  if mmkv_playerprefs.roleData then
    log(bWriteLog and "destroy roleData from OnLogout")
    mmkv_playerprefs.roleData = nil
  end
end
function mmkv_playerprefs.OnGameStateChange(_, _, gameState)
  log(bWriteLog and "destroy OnGameStateChange")
  if gameState.current == GameStatus.Login and gameState.pre ~= GameStatus.Login and gameState.pre ~= GameStatus.None then
    OnLogout()
  end
  if not mmkv_playerprefs.setErrorHandle then
    local MMKVObject = import("MMKVObject")
    local delegate = slua.createDelegate(mmkv_playerprefs.MMKVErrorReport)
    MMKVObject.SetErrorLogDelegate(delegate)
    mmkv_playerprefs.setErrorHandle = true
    log(bWriteLog and "setErrorHandle")
  end
end
function mmkv_playerprefs.MMKVErrorReport(mmapId, type)
  log(bWriteLog and "MMKVErrorReport " .. tostring(mmapId) .. " type " .. tostring(type))
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.MMKVLogError, type, mmapId)
end
return mmkv_playerprefs