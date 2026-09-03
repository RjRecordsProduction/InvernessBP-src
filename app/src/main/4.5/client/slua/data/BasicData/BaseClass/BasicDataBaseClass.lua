local BasicDataBaseClass = {}
local DataModuleMacro = require("client.slua.data.BasicData.Config.DataModuleMacro")
local GMDebugLog = false
local DefaultKey = "DefaultKey"
function BasicDataBaseClass:DefineAndResetData()
  self._cacheDataMaxCount = 30
  self._isOpenCacheLimitCount = false
  self._cacheDataMap = {
    data = nil,
    state = nil,
    dataExpirationTimestamp = nil,
    waitingTimeoutTimestamp = nil,
    cacheKeyList = nil
  }
  self._callbackMap = nil
end
function BasicDataBaseClass:OnLogOut()
  self:DefineAndResetData()
end
function BasicDataBaseClass:OnSendReqMsg(key, ...)
end
function BasicDataBaseClass:OnPostSwitchGameStatus(preState, nextState)
  log(bWriteLog and "BasicDataBaseClass:OnPostSwitchGameStatus")
end
function BasicDataBaseClass:GetCacheData(key)
  key = key or DefaultKey
  if not self._cacheDataMap or not self._cacheDataMap.data then
    return nil
  end
  if GMDebugLog then
    log(bWriteLog and "BasicDataBaseClass:GetCacheData key:" .. key)
  end
  self:UpdateCacheKeyList(key)
  return self._cacheDataMap.data[key]
end
function BasicDataBaseClass:GetOrReqData(key, callback, extraParams, ...)
  if not key then
    log_error("BasicDataBaseClass:GetOrReqData key = nil")
    return nil
  end
  if type(key) == "string" and key == "" then
    log_error("BasicDataBaseClass:GetOrReqData key = empty")
    return nil
  end
  if type(key) == "number" and key == 0 then
    log_error("BasicDataBaseClass:GetOrReqData key = 0")
    return nil
  end
  if extraParams and extraParams.bForceReq then
    self:_ReqData(key, callback, ...)
    return nil
  end
  local state = self:_GetCacheDataState(key)
  if state == DataModuleMacro.ENUM_DataState.ENUM_DataState_Valid then
    local info = self:GetCacheData(key)
    if info then
      if callback then
        callback(key, info)
      end
      return info
    end
  end
  self:_ReqData(key, callback, ...)
  return nil
end
function BasicDataBaseClass:OnHandleMsgDataAndCallback(key, info)
  if not info then
    log_error("BasicDataBaseClass:OnHandleMsgDataAndCallback info = nil key:" .. key)
  end
  if GMDebugLog then
    log(bWriteLog and "BasicDataBaseClass:OnHandleMsgDataAndCallback key:" .. key)
  end
  self._cacheDataMap.state = self._cacheDataMap.state or {}
  self._cacheDataMap.state[key] = DataModuleMacro.ENUM_DataState.ENUM_DataState_Valid
  self._cacheDataMap.waitingTimeoutTimestamp = self._cacheDataMap.waitingTimeoutTimestamp or {}
  self._cacheDataMap.waitingTimeoutTimestamp[key] = nil
  if self._config.TimeSensitive then
    local TimeUtil = require("client.common.time_util")
    self._cacheDataMap.dataExpirationTimestamp = self._cacheDataMap.dataExpirationTimestamp or {}
    self._cacheDataMap.dataExpirationTimestamp[key] = TimeUtil.GetServerTimeInSec() + DataModuleMacro.TimeSensitiveGap[self._config.TimeSensitive]
  end
  self:_SetDataCache(key, info)
  self._callbackMap = self._callbackMap or {}
  local callbackList = self._callbackMap[key]
  if callbackList then
    for _, callback in ipairs(callbackList) do
      callback(key, info)
    end
  end
  self._callbackMap[key] = nil
end
function BasicDataBaseClass:SetCacheMaxCount(nMaxCount)
  if nMaxCount <= 1 then
    return
  end
  self._isOpenCacheLimitCount = true
  self._cacheDataMaxCount = nMaxCount
end
function BasicDataBaseClass:UpdateCacheKeyList(key)
  if not self._isOpenCacheLimitCount or key == DefaultKey then
    return
  end
  self._cacheDataMap.cacheKeyList = self._cacheDataMap.cacheKeyList or {}
  if tostring(self._cacheDataMap.cacheKeyList[1]) == tostring(key) then
    return
  end
  for i, v in ipairs(self._cacheDataMap.cacheKeyList) do
    if v == key then
      table.remove(self._cacheDataMap.cacheKeyList, i)
      break
    end
  end
  table.insert(self._cacheDataMap.cacheKeyList, 1, key)
  self:CheckIsRemoveCache()
end
function BasicDataBaseClass:CheckIsRemoveCache()
  if not self._isOpenCacheLimitCount or not self._cacheDataMap.cacheKeyList then
    return
  end
  local nCurMaxCount = #self._cacheDataMap.cacheKeyList
  if nCurMaxCount > self._cacheDataMaxCount then
    local nOldestKey = table.remove(self._cacheDataMap.cacheKeyList, nCurMaxCount)
    self._cacheDataMap.data[nOldestKey] = nil
    self._cacheDataMap.state[nOldestKey] = nil
    if self._cacheDataMap.dataExpirationTimestamp then
      self._cacheDataMap.dataExpirationTimestamp[nOldestKey] = nil
    end
  end
end
function BasicDataBaseClass:_SetDataCache(key, info)
  self._cacheDataMap.data = self._cacheDataMap.data or {}
  self._cacheDataMap.data[key] = info
  self:UpdateCacheKeyList(key)
end
function BasicDataBaseClass:_ReqData(key, callback, ...)
  local NetManager = require("client.network.comm.NetManager")
  if not NetManager.bConnected then
    log_error("BasicDataBaseClass:_ReqData bConnected is false key:" .. tostring(key))
    return
  end
  if self:_CheckInWaiting(key) then
    if GMDebugLog then
      log(bWriteLog and "BasicDataBaseClass:_ReqData ENUM_DataState_Waiting key:" .. key)
    end
    self:_SetCallback(key, callback)
    return
  end
  if GMDebugLog then
    log(bWriteLog and "BasicDataBaseClass:_ReqData key:" .. key)
  end
  self:_SetWaiting(key)
  self:_SetCallback(key, callback)
  self:_SendReqMsg(key, ...)
end
function BasicDataBaseClass:_CheckInWaiting(key)
  local TimeUtil = require("client.common.time_util")
  local dataState = self:_GetCacheDataState(key)
  if dataState and dataState == DataModuleMacro.ENUM_DataState.ENUM_DataState_Waiting and TimeUtil.GetServerTimeInSec() < self._cacheDataMap.waitingTimeoutTimestamp[key] then
    return true
  end
  return false
end
function BasicDataBaseClass:_SetWaiting(key)
  local TimeUtil = require("client.common.time_util")
  self._cacheDataMap.state = self._cacheDataMap.state or {}
  self._cacheDataMap.state[key] = DataModuleMacro.ENUM_DataState.ENUM_DataState_Waiting
  self._cacheDataMap.waitingTimeoutTimestamp = self._cacheDataMap.waitingTimeoutTimestamp or {}
  self._cacheDataMap.waitingTimeoutTimestamp[key] = TimeUtil.GetServerTimeInSec() + DataModuleMacro.WaitingTimeout
end
function BasicDataBaseClass:_SetCallback(key, callback)
  self._callbackMap = self._callbackMap or {}
  self._callbackMap[key] = self._callbackMap[key] or {}
  if callback then
    table.insert(self._callbackMap[key], callback)
  end
end
function BasicDataBaseClass:_ClearCallbackAndWaiting(key)
  self._callbackMap = self._callbackMap or {}
  self._callbackMap[key] = nil
  self._cacheDataMap.state = self._cacheDataMap.state or {}
  self._cacheDataMap.state[key] = nil
  self._cacheDataMap.waitingTimeoutTimestamp = self._cacheDataMap.waitingTimeoutTimestamp or {}
  self._cacheDataMap.waitingTimeoutTimestamp[key] = nil
end
function BasicDataBaseClass:_SendReqMsg(key, ...)
  self:OnSendReqMsg(key, ...)
end
function BasicDataBaseClass:_GetCacheDataState(key)
  self._cacheDataMap = self._cacheDataMap or {}
  self._cacheDataMap.state = self._cacheDataMap.state or {}
  if not self._cacheDataMap.state[key] then
    return DataModuleMacro.ENUM_DataState.ENUM_DataState_None
  end
  if self._config.TimeSensitive and self._cacheDataMap.state[key] == DataModuleMacro.ENUM_DataState.ENUM_DataState_Valid then
    local TimeUtil = require("client.common.time_util")
    if TimeUtil.GetServerTimeInSec() >= self._cacheDataMap.dataExpirationTimestamp[key] then
      self._cacheDataMap.state[key] = DataModuleMacro.ENUM_DataState.ENUM_DataState_TimeSensitiveExpired
      return DataModuleMacro.ENUM_DataState.ENUM_DataState_TimeSensitiveExpired
    end
  end
  return self._cacheDataMap.state[key]
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CBasicDataBaseClass = class(CModuleBase, nil, BasicDataBaseClass)
return CBasicDataBaseClass