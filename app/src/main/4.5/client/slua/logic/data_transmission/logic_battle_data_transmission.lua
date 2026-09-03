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
local C_BatchFlushInterval = 0.2
local C_BatchRateLimitInterval = 1.0
local C_BatchInFlightTimeout = 15
local C_BatchMaxItems = 20
function logic_battle_data_transmission:OnInitialize()
  log(bWriteLog and "logic_battle_data_transmission:OnInitialize")
  self.dataCache = {}
  self.dataStateMap = {}
  self.callbackQueue = {}
  self.timeoutHandles = {}
  self.bIsSendingData = false
  self.PlayerArchiveDataKey = "PlayerArchiveData"
  self.PlayerGeneralDataKey = "PlayerSettingData"
  self.pendingGetItems = {}
  self.pendingSetItems = {}
  self.batchGetFlushTimer = nil
  self.batchSetFlushTimer = nil
  self.batchGetCooldownTimer = nil
  self.batchSetCooldownTimer = nil
  self.bBatchGetCoolingDown = false
  self.bBatchSetCoolingDown = false
  self.bBatchGetInFlight = false
  self.bBatchSetInFlight = false
  self.batchGetInFlightTimer = nil
  self.batchSetInFlightTimer = nil
end
function logic_battle_data_transmission:GetOrReqPlayerArchiveData(sModName, callback, bForceRefresh, bImmediate)
  if sModName and type(sModName) == "string" then
    self:_GetOrReqTransmissionDataByDefaultKey(self.PlayerArchiveDataKey, sModName, callback, bForceRefresh, bImmediate)
  else
    log_error("logic_battle_data_transmission:GetOrReqPlayerArchiveData. Invalid paramKey")
  end
end
function logic_battle_data_transmission:GetOrReqPlayerGeneralData(sModName, callback, bForceRefresh, bImmediate)
  if sModName and type(sModName) == "string" then
    self:_GetOrReqTransmissionDataByDefaultKey(self.PlayerGeneralDataKey, sModName, callback, bForceRefresh, bImmediate)
  else
    log_error("logic_battle_data_transmission:GetOrReqPlayerGeneralData. Invalid paramKey")
  end
end
function logic_battle_data_transmission:SetPlayerGeneralData(sModName, data, sPrimaryKey, sSecondaryKey, bDelaySet, bImmediate)
  log(bWriteLog and "logic_battle_data_transmission:SetPlayerGeneralData, sModName: " .. tostring(sModName) .. ", sPrimaryKey: " .. tostring(sPrimaryKey) .. ", sSecondaryKey: " .. tostring(sSecondaryKey) .. ", bDelaySet: " .. tostring(bDelaySet) .. ", bImmediate: " .. tostring(bImmediate))
  log_tree("logic_battle_data_transmission:SetPlayerGeneralData data = ", data)
  if not self:PlayerGeneralDataKeyChecker(sModName, data, sPrimaryKey, sSecondaryKey) then
    log_warning("logic_battle_data_transmission:SetPlayerGeneralData. Invalid param")
    return false
  end
  if not self.PlayerGeneralDataKey or not sModName then
    log_warning("logic_battle_data_transmission:SetPlayerGeneralData. Invalid param")
    return false
  end
  if data == nil or type(data) ~= "table" then
    log_warning("logic_battle_data_transmission:SetPlayerGeneralData. Invalid data")
    return false
  end
  local sCachekey = sModName .. "_" .. self.PlayerGeneralDataKey
  self.dataCache[sCachekey] = data
  self:_SetDataState(sCachekey, E_DataState.MODIFIED)
  if not bDelaySet then
    self:SendTransmissionData(self.PlayerGeneralDataKey, true, sModName, bImmediate)
  end
  return true
end
function logic_battle_data_transmission:PlayerGeneralDataKeyChecker(sModName, data, sPrimaryKey, sSecondaryKey)
  if not sModName then
    log_warning("logic_battle_data_transmission:PlayerGeneralDataKeyChecker. Invalid params")
    return false
  end
  local sConfigPath = string.format("GameLua.Mod.%s.Client.Config.DataTransmissionRuleConfig", sModName)
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  if not GamePlayTools.LuaFileExits(sConfigPath) then
    return true
  end
  if not sPrimaryKey or not sSecondaryKey then
    log_warning("logic_battle_data_transmission:PlayerGeneralDataKeyChecker. Invalid params")
    return false
  end
  local DataTransmissionRuleConfig = require(sConfigPath)
  if not DataTransmissionRuleConfig or not DataTransmissionRuleConfig.PlayerGeneralDataKeyList then
    log_warning("logic_battle_data_transmission:PlayerGeneralDataKeyChecker. PlayerGeneralDataKeyList not found in config")
    return true
  end
  local KeyList = DataTransmissionRuleConfig.PlayerGeneralDataKeyList
  local PrimaryTable = KeyList[sPrimaryKey]
  if not PrimaryTable then
    log_warning(string.format("logic_battle_data_transmission:PlayerGeneralDataKeyChecker. sPrimaryKey[%s] not found in whitelist", tostring(sPrimaryKey)))
    return false
  end
  if not PrimaryTable[sSecondaryKey] then
    log_warning(string.format("logic_battle_data_transmission:PlayerGeneralDataKeyChecker. sSecondaryKey[%s] not found under sPrimaryKey[%s]", tostring(sSecondaryKey), tostring(sPrimaryKey)))
    return false
  end
  return true
end
function logic_battle_data_transmission:GetOrReqTransmissionData(paramKey, callback, bForceRefresh, bImmediate)
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
  self:_GetOrReqTransmissionDataByParamID(paramID, callback, bForceRefresh, bImmediate)
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
function logic_battle_data_transmission:SetTransmissionData(paramKey, data, bDelaySet, bImmediate)
  log_tree("logic_battle_data_transmission:SetTransmissionData paramKey = " .. tostring(paramKey) .. ", bDelaySet = " .. tostring(bDelaySet) .. ", bImmediate = " .. tostring(bImmediate), data)
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
    self:SendTransmissionData(paramKey, nil, nil, bImmediate)
  end
  return true
end
function logic_battle_data_transmission:SendTransmissionData(paramKey, bDefaultKey, sModName, bImmediate)
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
    self:_SendTransmissionData(nil, encodedData, sModName, paramKey, bImmediate)
  else
    self:_SendTransmissionData(paramID, encodedData, nil, nil, bImmediate)
  end
end
function logic_battle_data_transmission:ClearAllTransmissionData()
  log(bWriteLog and "logic_battle_data_transmission:ClearAllTransmissionData")
  self:_ClearAllTimeoutHandles()
  if self.batchGetFlushTimer then
    self:RemoveGameTimer(self.batchGetFlushTimer)
    self.batchGetFlushTimer = nil
  end
  if self.batchSetFlushTimer then
    self:RemoveGameTimer(self.batchSetFlushTimer)
    self.batchSetFlushTimer = nil
  end
  if self.batchGetCooldownTimer then
    self:RemoveGameTimer(self.batchGetCooldownTimer)
    self.batchGetCooldownTimer = nil
  end
  if self.batchSetCooldownTimer then
    self:RemoveGameTimer(self.batchSetCooldownTimer)
    self.batchSetCooldownTimer = nil
  end
  if self.batchGetInFlightTimer then
    self:RemoveGameTimer(self.batchGetInFlightTimer)
    self.batchGetInFlightTimer = nil
  end
  if self.batchSetInFlightTimer then
    self:RemoveGameTimer(self.batchSetInFlightTimer)
    self.batchSetInFlightTimer = nil
  end
  self.bBatchGetCoolingDown = false
  self.bBatchSetCoolingDown = false
  self.bBatchGetInFlight = false
  self.bBatchSetInFlight = false
  self.pendingGetItems = {}
  self.pendingSetItems = {}
  self.dataCache = {}
  self.dataStateMap = {}
  self.callbackQueue = {}
  self.bIsSendingData = false
end
function logic_battle_data_transmission:FlushPendingRequests()
  log(bWriteLog and "logic_battle_data_transmission:FlushPendingRequests")
  if #self.pendingGetItems > 0 then
    self:_ScheduleBatchGetFlush(true)
  end
  if 0 < #self.pendingSetItems then
    self:_ScheduleBatchSetFlush(true)
  end
end
function logic_battle_data_transmission:FlushPendingGetRequests()
  log(bWriteLog and "logic_battle_data_transmission:FlushPendingGetRequests")
  if #self.pendingGetItems > 0 then
    self:_ScheduleBatchGetFlush(true)
  end
end
function logic_battle_data_transmission:FlushPendingSetRequests()
  log(bWriteLog and "logic_battle_data_transmission:FlushPendingSetRequests")
  if #self.pendingSetItems > 0 then
    self:_ScheduleBatchSetFlush(true)
  end
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
function logic_battle_data_transmission:_GetOrReqTransmissionDataByDefaultKey(sDefaultKey, sModName, callback, bForceRefresh, bImmediate)
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
  self:_RequestTransmissionData(sCachekey, sModName, sDefaultKey, callback, bImmediate)
end
function logic_battle_data_transmission:_GetOrReqTransmissionDataByParamID(paramID, callback, bForceRefresh, bImmediate)
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
  self:_RequestTransmissionData(paramID, nil, nil, callback, bImmediate)
end
function logic_battle_data_transmission:_RequestTransmissionData(paramID, sModName, sDefaultKey, callback, bImmediate)
  log(bWriteLog and string.format("logic_battle_data_transmission:_RequestTransmissionData. paramID:%s", tostring(paramID)))
  self:_SetDataState(paramID, E_DataState.LOADING)
  self:_AddCallbackToQueue(paramID, callback)
  self:_StartTimeoutTimer(paramID)
  local item
  if sModName and sDefaultKey then
    item = {mod_name = sModName, default_key = sDefaultKey}
  else
    item = {uniq_id = paramID}
  end
  table.insert(self.pendingGetItems, item)
  self:_ScheduleBatchGetFlush(bImmediate)
end
function logic_battle_data_transmission:_SendTransmissionData(paramID, data, sModName, sDefaultKey, bImmediate)
  local item
  if paramID == nil and sModName and sDefaultKey then
    item = {
      mod_name = sModName,
      default_key = sDefaultKey,
      pass_    }
  else
    item = {uniq_id = paramID, pass_data = data}
  end
  table.insert(self.pendingSetItems, item)
  self:_ScheduleBatchSetFlush(bImmediate)
end
function logic_battle_data_transmission:_ScheduleBatchGetFlush(bImmediate)
  if self.bBatchGetInFlight then
    return
  end
  if self.bBatchGetCoolingDown then
    return
  end
  if bImmediate and self.batchGetFlushTimer then
    self:RemoveGameTimer(self.batchGetFlushTimer)
    self.batchGetFlushTimer = nil
  end
  if self.batchGetFlushTimer then
    return
  end
  local interval = bImmediate and 0 or C_BatchFlushInterval
  self.batchGetFlushTimer = self:AddGameTimer(interval, false, function()
    self.batchGetFlushTimer = nil
    self:_FlushBatchGet()
  end)
end
function logic_battle_data_transmission:_ScheduleBatchSetFlush(bImmediate)
  if self.bBatchSetInFlight then
    return
  end
  if self.bBatchSetCoolingDown then
    return
  end
  if bImmediate and self.batchSetFlushTimer then
    self:RemoveGameTimer(self.batchSetFlushTimer)
    self.batchSetFlushTimer = nil
  end
  if self.batchSetFlushTimer then
    return
  end
  local interval = bImmediate and 0 or C_BatchFlushInterval
  self.batchSetFlushTimer = self:AddGameTimer(interval, false, function()
    self.batchSetFlushTimer = nil
    self:_FlushBatchSet()
  end)
end
function logic_battle_data_transmission:_FlushBatchGet()
  if #self.pendingGetItems == 0 then
    return
  end
  if self.bBatchGetInFlight or self.bBatchGetCoolingDown then
    return
  end
  local total = #self.pendingGetItems
  local takeCnt = math.min(C_BatchMaxItems, total)
  local batch = {}
  for i = 1, takeCnt do
    batch[i] = self.pendingGetItems[i]
  end
  if takeCnt == total then
    self.pendingGetItems = {}
  else
    local remaining = {}
    for i = takeCnt + 1, total do
      remaining[#remaining + 1] = self.pendingGetItems[i]
    end
    self.pendingGetItems = remaining
  end
  log(bWriteLog and string.format("logic_battle_data_transmission:_FlushBatchGet. send batch size:%d remain:%d", #batch, #self.pendingGetItems))
  log_tree("logic_battle_data_transmission:_FlushBatchGet batch = ", batch)
  local MatchHandler = require("client.network.Protocol.MatchHandler")
  MatchHandler.send_batch_get_data_pass_to_ds_req(batch)
  self:_StartBatchGetInFlight()
end
function logic_battle_data_transmission:_FlushBatchSet()
  if #self.pendingSetItems == 0 then
    return
  end
  if self.bBatchSetInFlight or self.bBatchSetCoolingDown then
    return
  end
  local total = #self.pendingSetItems
  local takeCnt = math.min(C_BatchMaxItems, total)
  local batch = {}
  for i = 1, takeCnt do
    batch[i] = self.pendingSetItems[i]
  end
  if takeCnt == total then
    self.pendingSetItems = {}
  else
    local remaining = {}
    for i = takeCnt + 1, total do
      remaining[#remaining + 1] = self.pendingSetItems[i]
    end
    self.pendingSetItems = remaining
  end
  log(bWriteLog and string.format("logic_battle_data_transmission:_FlushBatchSet. send batch size:%d remain:%d", #batch, #self.pendingSetItems))
  log_tree("logic_battle_data_transmission:_FlushBatchSet batch = ", batch)
  local MatchHandler = require("client.network.Protocol.MatchHandler")
  MatchHandler.send_batch_set_data_pass_to_ds_req(batch)
  self:_StartBatchSetInFlight()
end
function logic_battle_data_transmission:_StartBatchGetInFlight()
  self.bBatchGetInFlight = true
  if self.batchGetInFlightTimer then
    self:RemoveGameTimer(self.batchGetInFlightTimer)
  end
  self.batchGetInFlightTimer = self:AddGameTimer(C_BatchInFlightTimeout, false, function()
    log_warning("logic_battle_data_transmission:_StartBatchGetInFlight. timeout, force release in-flight")
    self.batchGetInFlightTimer = nil
    self:_OnBatchGetResponseArrived()
  end)
end
function logic_battle_data_transmission:_StartBatchSetInFlight()
  self.bBatchSetInFlight = true
  if self.batchSetInFlightTimer then
    self:RemoveGameTimer(self.batchSetInFlightTimer)
  end
  self.batchSetInFlightTimer = self:AddGameTimer(C_BatchInFlightTimeout, false, function()
    log_warning("logic_battle_data_transmission:_StartBatchSetInFlight. timeout, force release in-flight")
    self.batchSetInFlightTimer = nil
    self:_OnBatchSetResponseArrived()
  end)
end
function logic_battle_data_transmission:_OnBatchGetResponseArrived()
  self.bBatchGetInFlight = false
  if self.batchGetInFlightTimer then
    self:RemoveGameTimer(self.batchGetInFlightTimer)
    self.batchGetInFlightTimer = nil
  end
  self:_StartBatchGetCooldown()
end
function logic_battle_data_transmission:_OnBatchSetResponseArrived()
  self.bBatchSetInFlight = false
  if self.batchSetInFlightTimer then
    self:RemoveGameTimer(self.batchSetInFlightTimer)
    self.batchSetInFlightTimer = nil
  end
  self:_StartBatchSetCooldown()
end
function logic_battle_data_transmission:_StartBatchGetCooldown()
  self.bBatchGetCoolingDown = true
  if self.batchGetCooldownTimer then
    self:RemoveGameTimer(self.batchGetCooldownTimer)
  end
  self.batchGetCooldownTimer = self:AddGameTimer(C_BatchRateLimitInterval, false, function()
    self.batchGetCooldownTimer = nil
    self.bBatchGetCoolingDown = false
    if #self.pendingGetItems > 0 then
      self:_FlushBatchGet()
    end
  end)
end
function logic_battle_data_transmission:_StartBatchSetCooldown()
  self.bBatchSetCoolingDown = true
  if self.batchSetCooldownTimer then
    self:RemoveGameTimer(self.batchSetCooldownTimer)
  end
  self.batchSetCooldownTimer = self:AddGameTimer(C_BatchRateLimitInterval, false, function()
    self.batchSetCooldownTimer = nil
    self.bBatchSetCoolingDown = false
    if #self.pendingSetItems > 0 then
      self:_FlushBatchSet()
    end
  end)
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
  log(bWriteLog and string.format("logic_battle_data_transmission:proc_on_set_data_pass_to_ds_rsp. paramID:%s err:%s mod_name:%s default_key:%s", tostring(paramID), tostring(err), tostring(mod_name), tostring(default_key)))
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
function logic_battle_data_transmission:proc_on_batch_get_data_pass_to_ds_rsp(err_code, results)
  log(bWriteLog and string.format("logic_battle_data_transmission:proc_on_batch_get_data_pass_to_ds_rsp. err_code:%s result_cnt:%s", tostring(err_code), tostring(results and #results or 0)))
  log_tree("logic_battle_data_transmission:proc_on_batch_get_data_pass_to_ds_rsp. results = ", results)
  self:_OnBatchGetResponseArrived()
  if not results or type(results) ~= "table" then
    log_warning("logic_battle_data_transmission:proc_on_batch_get_data_pass_to_ds_rsp. invalid results")
    return
  end
  for _, item in ipairs(results) do
    if type(item) == "table" then
      self:proc_on_get_data_pass_to_ds_rsp(item.err, item.uniq_id, item.data, item.mod_name, item.default_key)
    end
  end
end
function logic_battle_data_transmission:proc_on_batch_set_data_pass_to_ds_rsp(err_code, results)
  log(bWriteLog and string.format("logic_battle_data_transmission:proc_on_batch_set_data_pass_to_ds_rsp. err_code:%s result_cnt:%s", tostring(err_code), tostring(results and #results or 0)))
  self:_OnBatchSetResponseArrived()
  if not results or type(results) ~= "table" then
    log_warning("logic_battle_data_transmission:proc_on_batch_set_data_pass_to_ds_rsp. invalid results")
    return
  end
  for _, item in ipairs(results) do
    if type(item) == "table" then
      self:proc_on_set_data_pass_to_ds_rsp(item.err, item.uniq_id, item.mod_name, item.default_key)
    end
  end
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