local logic_battle_data_transmission = {}
local TableUtil = require("common.table_util")
local E_DataState = {
  NONE = 0,
  LOADING = 1,
  LOADED = 2,
  MODIFIED = 3,
  FAILED = 4
}
local C_RequestTimeout = 30
local C_MaxRetryCount = 3
function logic_battle_data_transmission:OnInitialize()
  log(bWriteLog and "logic_battle_data_transmission:OnInitialize")
  self.dataCache = {}
  self.dataStateMap = {}
  self.callbackQueue = {}
  self.timeoutHandles = {}
  self.bIsSendingData = false
  self.PlayerArchiveDataKey = "PlayerArchiveData"
  self.PlayerSettingDataKey = "PlayerSettingData"
end
function logic_battle_data_transmission:GetOrReqPlayerArchiveData(sModName, callback, bForceRefresh)
  if sModName and type(sModName) == "string" then
    self:_GetOrReqTransmissionDataByDefaultKey(self.PlayerArchiveDataKey, sModName, callback, bForceRefresh)
  else
    log_error("logic_battle_data_transmission:GetOrReqPlayerArchiveData. Invalid paramKey")
  end
end
function logic_battle_data_transmission:GetOrReqPlayerSettingData(sModName, callback, bForceRefresh)
  if sModName and type(sModName) == "string" then
    self:_GetOrReqTransmissionDataByDefaultKey(self.PlayerSettingDataKey, sModName, callback, bForceRefresh)
  else
    log_error("logic_battle_data_transmission:GetOrReqPlayerSettingData. Invalid paramKey")
  end
end
function logic_battle_data_transmission:SetPlayerSettingData(sModName, data, bDelaySet)
  if not self.PlayerSettingDataKey or not sModName then
    log_warning("logic_battle_data_transmission:SetPlayerSettingData. Invalid param")
    return false
  end
  if data == nil or type(data) ~= "table" then
    log_warning("logic_battle_data_transmission:SetPlayerSettingData. Invalid data")
    return false
  end
  local sCachekey = sModName .. "_" .. self.PlayerSettingDataKey
  self.dataCache[sCachekey] = data
  self:_SetDataState(sCachekey, E_DataState.MODIFIED)
  if not bDelaySet then
    self:SendTransmissionData(self.PlayerSettingDataKey, true, sModName)
  end
  return true
end
function logic_battle_data_transmission:GetOrReqTransmissionData(paramKey, callback, bForceRefresh)
  local paramCfg = CDataTable.GetTableData("DSDataTransmissionCfg", paramKey)
  if not paramCfg then
    log_warning("logic_battle_data_transmission:GetOrReqTransmissionData. Invalid paramKey")
    if callback then
      callback(false, nil)
    end
    return
  end
  if not self:_CheckAppVersionAndRegionValid(paramCfg, true) then
    if callback then
      callback(false, nil)
    end
    return
  end
  local paramID = paramCfg.ParamID
  self:_GetOrReqTransmissionDataByParamID(paramID, callback, bForceRefresh)
end
function logic_battle_data_transmission:GetCachedTransmissionData(paramKey)
  local paramCfg = CDataTable.GetTableData("DSDataTransmissionCfg", paramKey)
  if not paramCfg then
    log_warning("logic_battle_data_transmission:GetCachedTransmissionData. Invalid paramKey")
    return nil
  end
  local paramID = paramCfg.ParamID
  return self.dataCache[paramID]
end
function logic_battle_data_transmission:SetTransmissionData(paramKey, data, bDelaySet)
  local paramCfg = CDataTable.GetTableData("DSDataTransmissionCfg", paramKey)
  if not paramCfg then
    log_warning("logic_battle_data_transmission:SetTransmissionData. Invalid paramKey")
    return false
  end
  local paramID = paramCfg.ParamID
  if data == nil or type(data) ~= "table" then
    log_warning("logic_battle_data_transmission:SetTransmissionData. Invalid data")
    return false
  end
  self.dataCache[paramID] = data
  self:_SetDataState(paramID, E_DataState.MODIFIED)
  if not bDelaySet then
    self:SendTransmissionData(paramKey)
  end
  return true
end
function logic_battle_data_transmission:SendTransmissionData(paramKey, bDefaultKey, sModName)
  local paramID
  local nMaxLen = 1024
  if bDefaultKey then
    if paramKey and sModName then
      paramID = sModName .. "_" .. paramKey
    else
      log_warning("logic_battle_data_transmission:SendTransmissionData. Invalid paramKey or sModName")
      return false
    end
  else
    local paramCfg = CDataTable.GetTableData("DSDataTransmissionCfg", paramKey)
    if not paramCfg then
      log_warning("logic_battle_data_transmission:SendTransmissionData. Invalid paramKey")
      return false
    end
    if not self:_CheckAppVersionAndRegionValid(paramCfg, true) then
      return false
    end
    paramID = paramCfg.ParamID
    nMaxLen = paramCfg.MaxLen
  end
  if not self.dataCache[paramID] then
    log_warning("logic_battle_data_transmission:SendTransmissionData. Data is not cached")
    return false
  end
  local encodedData = slua.LuaArchiverEncode(LuaStateWrapper, self.dataCache[paramID])
  if type(encodedData) ~= "string" then
    log_warning("logic_battle_data_transmission:SendTransmissionData. Failed to encode data")
    return false
  end
  if nMaxLen < #encodedData then
    log_warning("logic_battle_data_transmission:SendTransmissionData. Data length exceeds the maximum length")
    return false
  end
  if bDefaultKey then
    self:_SendTransmissionData(nil, encodedData, sModName, paramKey)
  else
    self:_SendTransmissionData(paramID, encodedData)
  end
end
function logic_battle_data_transmission:ClearAllTransmissionData()
  log(bWriteLog and "logic_battle_data_transmission:ClearAllTransmissionData")
  self:_ClearAllTimeoutHandles()
  self.dataCache = {}
  self.dataStateMap = {}
  self.callbackQueue = {}
  self.bIsSendingData = false
end
function logic_battle_data_transmission:HasCachedData(paramKey)
  local paramCfg = CDataTable.GetTableData("DSDataTransmissionCfg", paramKey)
  if not paramCfg then
    log_warning("logic_battle_data_transmission:HasCachedData. Invalid paramKey")
    return false
  end
  local paramID = paramCfg.ParamID
  return self:_HasValidCache(paramID)
end
function logic_battle_data_transmission:GetDataState(paramKey)
  local paramCfg = CDataTable.GetTableData("DSDataTransmissionCfg", paramKey)
  if not paramCfg then
    log_warning("logic_battle_data_transmission:GetDataState. Invalid paramKey")
    return E_DataState.NONE
  end
  local paramID = paramCfg.ParamID
  return self.dataStateMap[paramID] or E_DataState.NONE
end
function logic_battle_data_transmission:_GetOrReqTransmissionDataByDefaultKey(sDefaultKey, sModName, callback, bForceRefresh)
  if not sDefaultKey or not sModName then
    log_warning("logic_battle_data_transmission:_GetOrReqTransmissionDataByDefaultKey. Invalid param")
    return
  end
  local sCachekey = sModName .. "_" .. sDefaultKey
  if not bForceRefresh and self:_HasValidCache(sCachekey) then
    log(bWriteLog and string.format("logic_battle_data_transmission:_GetOrReqTransmissionDataByDefaultKey. Return cached data for cacheKey:%s", tostring(sCachekey)))
    if callback then
      callback(true, TableUtil.FastCopyTable(self.dataCache[sCachekey]))
    end
    return
  end
  if self:_IsLoading(sCachekey) then
    log(bWriteLog and string.format("logic_battle_data_transmission:_GetOrReqTransmissionDataByDefaultKey. cacheKey:%s is loading, add callback to queue", tostring(sCachekey)))
    self:_AddCallbackToQueue(sCachekey, callback)
    return
  end
  self:_RequestTransmissionData(sCachekey, sModName, sDefaultKey, callback)
end
function logic_battle_data_transmission:_GetOrReqTransmissionDataByParamID(paramID, callback, bForceRefresh)
  if not bForceRefresh and self:_HasValidCache(paramID) then
    log(bWriteLog and string.format("logic_battle_data_transmission:GetOrReqTransmissionData. Return cached data for paramID:%s", tostring(paramID)))
    if callback then
      callback(true, TableUtil.FastCopyTable(self.dataCache[paramID]))
    end
    return
  end
  if self:_IsLoading(paramID) then
    log(bWriteLog and string.format("logic_battle_data_transmission:GetOrReqTransmissionData. paramID:%s is loading, add callback to queue", tostring(paramID)))
    self:_AddCallbackToQueue(paramID, callback)
    return
  end
  self:_RequestTransmissionData(paramID, nil, nil, callback)
end
function logic_battle_data_transmission:_RequestTransmissionData(paramID, sModName, sDefaultKey, callback)
  log(bWriteLog and string.format("logic_battle_data_transmission:_RequestTransmissionData. paramID:%s", tostring(paramID)))
  self:_SetDataState(paramID, E_DataState.LOADING)
  self:_AddCallbackToQueue(paramID, callback)
  self:_StartTimeoutTimer(paramID)
  local MatchHandler = require("client.network.Protocol.MatchHandler")
  if sModName and sDefaultKey then
    MatchHandler.send_get_data_pass_to_ds_req(nil, sModName, sDefaultKey)
  else
    MatchHandler.send_get_data_pass_to_ds_req(paramID)
  end
end
function logic_battle_data_transmission:_SendTransmissionData(paramID, data, sModName, sDefaultKey)
  local MatchHandler = require("client.network.Protocol.MatchHandler")
  if paramID == nil and sModName and sDefaultKey then
    MatchHandler.send_set_data_pass_to_ds_req(paramID, data, sModName, sDefaultKey)
  else
    MatchHandler.send_set_data_pass_to_ds_req(paramID, data)
  end
end
function logic_battle_data_transmission:proc_on_get_data_pass_to_ds_rsp(err, paramID, data, mod_name, default_key)
  log(bWriteLog and string.format("logic_battle_data_transmission:proc_on_get_data_pass_to_ds_rsp. id:%s err:%s", tostring(paramID), tostring(err)))
  local CacheKey = paramID
  if CacheKey == nil and mod_name and default_key then
    CacheKey = mod_name .. "_" .. default_key
  end
  if not CacheKey then
    log(bWriteLog and "logic_battle_data_transmission:proc_on_get_data_pass_to_ds_rsp. CacheKey is nil")
    return
  end
  log(bWriteLog and "logic_battle_data_transmission:proc_on_get_data_pass_to_ds_rsp. CacheKey = " .. tostring(CacheKey))
  self:_ClearTimeoutHandle(CacheKey)
  if err == "ok" then
    local decodedData = slua.LuaArchiverDecode(LuaStateWrapper, data) or {}
    log_tree("logic_battle_data_transmission:proc_on_get_data_pass_to_ds_rsp decodedData = ", decodedData)
    self.dataCache[CacheKey] = decodedData or {}
    self:_SetDataState(CacheKey, E_DataState.LOADED)
    self:_TriggerCallbackQueue(CacheKey, true, decodedData)
    EventSystem:postEvent(EVENTTYPE_DATA_TRANSMISSION, EVENTID_DATA_TRANSMISSION_GET_DATA, CacheKey, decodedData)
  else
    log(bWriteLog and "logic_battle_data_transmission:proc_on_get_data_pass_to_ds_rsp. failed to get data err:" .. tostring(err))
    self:_SetDataState(CacheKey, E_DataState.FAILED)
    self:_TriggerCallbackQueue(CacheKey, false, nil)
  end
end
function logic_battle_data_transmission:proc_on_set_data_pass_to_ds_rsp(err, paramID, mod_name, default_key)
  log(bWriteLog and string.format("logic_battle_data_transmission:proc_on_set_data_pass_to_ds_rsp. paramID:%s err:%s", tostring(paramID), tostring(err)))
  if err ~= "ok" then
    return
  end
  local CacheKey = paramID
  if CacheKey == nil and mod_name and default_key then
    CacheKey = mod_name .. "_" .. default_key
  end
  log(bWriteLog and "logic_battle_data_transmission:proc_on_set_data_pass_to_ds_rsp. CacheKey = " .. tostring(CacheKey))
  self:_ClearTimeoutHandle(CacheKey)
  EventSystem:postEvent(EVENTTYPE_DATA_TRANSMISSION, EVENTID_DATA_TRANSMISSION_SEND_DATA, CacheKey)
end
function logic_battle_data_transmission:_StartTimeoutTimer(paramID)
  self:_ClearTimeoutHandle(paramID)
  local TimerHandle = self:AddGameTimer(C_RequestTimeout, false, function()
    self:_OnRequestTimeout(paramID)
  end)
  self.timeoutHandles[paramID] = TimerHandle
end
function logic_battle_data_transmission:_ClearTimeoutHandle(paramID)
  local TimerHandle = self.timeoutHandles[paramID]
  if TimerHandle then
    self:RemoveGameTimer(TimerHandle)
    self.timeoutHandles[paramID] = nil
  end
end
function logic_battle_data_transmission:_ClearAllTimeoutHandles()
  for id, TimerHandle in pairs(self.timeoutHandles) do
    if TimerHandle then
      self:RemoveGameTimer(TimerHandle)
    end
  end
  self.timeoutHandles = {}
end
function logic_battle_data_transmission:_OnRequestTimeout(paramID)
  log_warning(string.format("logic_battle_data_transmission:_OnRequestTimeout. paramID:%s", tostring(paramID)))
  self.timeoutHandles[paramID] = nil
  self:_SetDataState(paramID, E_DataState.FAILED)
  self:_TriggerCallbackQueue(paramID, false, nil)
end
function logic_battle_data_transmission:_AddCallbackToQueue(paramID, callback)
  if not callback then
    return
  end
  if not self.callbackQueue[paramID] then
    self.callbackQueue[paramID] = {}
  end
  table.insert(self.callbackQueue[paramID], callback)
end
function logic_battle_data_transmission:_TriggerCallbackQueue(paramID, bSuccess, Data)
  local callbackList = self.callbackQueue[paramID]
  if not callbackList or #callbackList == 0 then
    return
  end
  log(bWriteLog and string.format("logic_battle_data_transmission:_TriggerCallbackQueue. id:%s CallbackCount:%s", tostring(paramID), tostring(#callbackList)))
  for _, callback in ipairs(callbackList) do
    if callback then
      callback(bSuccess, TableUtil.FastCopyTable(Data))
    end
  end
  self.callbackQueue[paramID] = nil
end
function logic_battle_data_transmission:_SetDataState(paramID, State)
  self.dataStateMap[paramID] = State
end
function logic_battle_data_transmission:_HasValidCache(paramID)
  local state = self.dataStateMap[paramID]
  return state == E_DataState.LOADED or state == E_DataState.MODIFIED
end
function logic_battle_data_transmission:_IsLoading(paramID)
  return self.dataStateMap[paramID] == E_DataState.LOADING
end
function logic_battle_data_transmission:_CheckAppVersionAndRegionValid(paramCfg, bShowNotice)
  if not paramCfg then
    log_warning("logic_battle_data_transmission:_CheckAppVersionAndTimeValid. Invalid paramCfg")
    if bShowNotice then
    end
    return false
  end
  local version_util = require("client.common.version_util")
  local version = Client.GetAppVersion()
  if version_util.LowerVersion(version, paramCfg.MinVer) or version_util.HigherVersion(version, paramCfg.MaxVer) then
    if bShowNotice then
    end
    log_warning("logic_battle_data_transmission:_CheckAppVersionAndTimeValid. Invalid app version, version: " .. version .. " minVer: " .. paramCfg.MinVer .. " maxVer: " .. paramCfg.MaxVer)
    return false
  end
  local region = Client.GetPublishRegion()
  local StringUtil = require("common.string_util")
  local blockRegionList = StringUtil.Split(paramCfg.BlockRegion, "|")
  for _, blockRegion in ipairs(blockRegionList) do
    if blockRegion == region then
      if bShowNotice then
      end
      log_warning("logic_battle_data_transmission:_CheckAppVersionAndTimeValid. Invalid region, region: " .. region .. " blockRegion: " .. blockRegion)
      return false
    end
  end
  return true
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicBattleDataTansmission = class(CModuleBase, nil, logic_battle_data_transmission)
return CLogicBattleDataTansmission