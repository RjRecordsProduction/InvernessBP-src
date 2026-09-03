local BasicDataBatchClass = {}
local time_ticker = require("common.time_ticker")
local DataModuleMacro = require("client.slua.data.BasicData.Config.DataModuleMacro")
local GMDebugLog = true
function BasicDataBatchClass:DefineAndResetData()
  BasicDataBatchClass.__super.DefineAndResetData(self)
  self._batchReqKeyTable = {}
  self._batchReqKeyTableCount = 0
  self._batchReqKey = 0
  self._batchReqDelegates = {}
end
function BasicDataBatchClass:OnSendBatchReqMsg(keyMap, reqKey)
end
function BasicDataBatchClass:OnMergeReqMsg(key, ...)
  table.insert(self._batchReqKeyTable, key)
end
function BasicDataBatchClass:GetKeyMapInfo(keyMap)
  local infoMap = {}
  for _, v in pairs(keyMap) do
    infoMap[v] = self:GetCacheData(v)
  end
  return infoMap
end
function BasicDataBatchClass:BatchGetOrReqData(keyList, callback)
  if not keyList then
    log_error("BasicDataBatchClass:BatchGetOrReqData keyList is not valid")
    return nil
  end
  local bAllGet, dataMap = self:GetCacheDataStateByList(keyList)
  if bAllGet then
    if callback then
      callback(dataMap)
    end
    return dataMap
  end
  self:AddBatchGetCache(keyList, callback)
  self:OnSendBatchReqMsg(keyList, self._batchReqKey)
  return nil
end
function BasicDataBatchClass:AddBatchGetCache(_, fCallback)
  self._batchReqKey = self._batchReqKey + 1
  self._batchReqDelegates = self._batchReqDelegates or {}
  self._batchReqDelegates[self._batchReqKey] = fCallback
end
function BasicDataBatchClass:OnHandleBatchMsgDataAndCallback(infoMap, reqKey)
  if not infoMap then
    log_error("BasicDataBatchClass:OnHandleBatchMsgDataAndCallback infoMap = nil")
    return
  end
  for key, value in pairs(infoMap) do
    self:OnHandleMsgDataAndCallback(key, value)
  end
  self:OnHandleBatchMsgCallback(infoMap, reqKey)
end
function BasicDataBatchClass:OnHandleBatchMsgCallback(infoMap, reqKey)
  if reqKey and reqKey ~= 0 and reqKey ~= "" and self._batchReqDelegates then
    local callback = self._batchReqDelegates[reqKey]
    if callback then
      callback(infoMap)
    end
    self._batchReqDelegates[reqKey] = nil
  end
end
function BasicDataBatchClass:GetCacheDataStateByList(tKeyList)
  local bAllGet = true
  local tDataMap = {}
  for _, v in pairs(tKeyList) do
    local info = self:GetCacheData(v)
    if not info then
      bAllGet = false
      break
    else
      tDataMap[v] = info
    end
  end
  return bAllGet, tDataMap
end
function BasicDataBatchClass:_SendReqMsg(key, ...)
  if not self._config.BatchProcessingGap then
    log_error("BasicDataBatchClass:_SendReqMsg self._config.BatchProcessingGap = nil key:" .. tostring(key))
    return
  end
  self:_BatchProcessing(key, ...)
end
function BasicDataBatchClass:_BatchProcessing(key, ...)
  self._batchReqKeyTable = self._batchReqKeyTable or {}
  self._batchReqKeyTableCount = self._batchReqKeyTableCount + 1
  self:OnMergeReqMsg(key, ...)
  local maxCount = self._config.BatchProcessingMaxCount or 9
  if self._batchReqKeyTableCount == 1 then
    self.nTimer = self:AddTimerOnce(DataModuleMacro.BatchProcessingGap[self._config.BatchProcessingGap], function()
      self:_BatchReqMsg()
    end)
  elseif maxCount <= self._batchReqKeyTableCount then
    self:_BatchReqMsg()
  end
end
function BasicDataBatchClass:_BatchReqMsg()
  if GMDebugLog then
    log(bWriteLog and "BasicDataBatchClass:_BatchReqMsg  num:" .. self._batchReqKeyTableCount)
  end
  self._batchReqKey = self._batchReqKey + 1
  self:OnSendBatchReqMsg(self._batchReqKeyTable, self._batchReqKey)
  self._batchReqKeyTable = {}
  self._batchReqKeyTableCount = 0
  self:_RemoveTimer()
end
function BasicDataBatchClass:_RemoveTimer()
  if self.nTimer then
    time_ticker.RemoveTimer(self.nTimer)
    self.nTimer = nil
  end
end
local class = require("class")
local BasicDataBaseClass = require("client.slua.data.BasicData.BaseClass.BasicDataBaseClass")
local CBasicDataBatchClass = class(BasicDataBaseClass, nil, BasicDataBatchClass)
return CBasicDataBatchClass