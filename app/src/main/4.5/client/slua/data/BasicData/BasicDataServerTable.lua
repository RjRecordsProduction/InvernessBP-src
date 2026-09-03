local DataModuleConfig = require("client.slua.data.BasicData.Config.DataModuleConfig")
local BasicDataServerTable = {}
local maxTableDataSize = 16384
local BaseAddr = "TableDatas/"
local getTime = slua.getMiliseconds
local errcode_invalid_table_name = 502036
local errcode_table_not_change = 502035
local unknow_pass_errcode_param = 502001
local _nCheckQueueInterval = 0.2
local _nTimeLimit = 3
local _nTimeLimitCount = 9
local _nSendLimitMaxCount = DataModuleConfig.BasicDataServerTable.BatchProcessingMaxCount
local _bIsGmSetDisableLRUCache = false
function BasicDataServerTable.SetDisableLRUCache(bIsUseLRU)
  _bIsGmSetDisableLRUCache = bIsUseLRU
end
function BasicDataServerTable:DefineAndResetData()
  BasicDataServerTable.__super.DefineAndResetData(self)
  self.TableCfgs = nil
  self.tAllSendTimeRecord = {}
  self._tQueueReqTableData = {}
  self._nCheckQueueTimerId = nil
  self._tCacheRelationReqKey = {}
  self._tCacheBatchReqList = {}
  self._tCacheReadLocalData = {}
  self._nLRUCacheSize = 80
end
function BasicDataServerTable:OnInitialize()
  BasicDataServerTable.__super.OnInitialize(self)
  local DeviceUtils = require("common.DeviceUtils")
  local nMemoryType = DeviceUtils.GetDeviceMemoryType()
  local ENum_MemorySize = DeviceUtils.ENum_MemorySize
  if nMemoryType == ENum_MemorySize.GreaterThan2G then
    self._nLRUCacheSize = 60
  elseif nMemoryType == ENum_MemorySize.GreaterThan1G then
    self._nLRUCacheSize = 40
  elseif nMemoryType == ENum_MemorySize.LessThan1G then
    self._nLRUCacheSize = 30
  end
end
function BasicDataServerTable:OnSendBatchReqMsg(keyMap, reqKey)
  if not (keyMap and reqKey) or not next(keyMap) then
    return
  end
  local bEnableLRUCache = HDmpveRemote.HDmpveRemoteConfigGetBool("bEnableServerTableLRU", true)
  if not bEnableLRUCache then
    self:_SendBatchGetTableReq(keyMap, reqKey)
    log(bWriteLog and " BasicDataServerTable:OnSendBatchReqMsg >>>> bEnableServerTableLRU = false")
    return true
  end
  local TableUtil = require("common.table_util")
  local tCurBatchReqList = TableUtil.CopyTable(keyMap)
  if #self._tQueueReqTableData <= 0 then
    local bIsCanSend = self:_GetIsCanSend()
    if bIsCanSend then
      local bIsQueue = false
      local nCurRepCount = #tCurBatchReqList
      if nCurRepCount > _nSendLimitMaxCount then
        for i = nCurRepCount, _nSendLimitMaxCount + 1 do
          local sTableName = table.remove(tCurBatchReqList, i)
          table.insert(self._tQueueReqTableData, {sTableName = sTableName, nRelationReqKey = reqKey})
          bIsQueue = true
        end
      end
      if bIsQueue then
        self:_AddCheckQueueTimer()
      end
    else
      if Client and Client.IsDevelopment() then
        log_tree(" BasicDataServerTable:OnSendBatchReqMsg >>>> tCurBatchReqList:", tCurBatchReqList)
      end
      for _, v in ipairs(tCurBatchReqList) do
        table.insert(self._tQueueReqTableData, {sTableName = v, nRelationReqKey = reqKey})
      end
      self:_AddCheckQueueTimer()
      return
    end
  else
    for _, v in ipairs(tCurBatchReqList) do
      table.insert(self._tQueueReqTableData, {sTableName = v, nRelationReqKey = reqKey})
    end
    self:_AddCheckQueueTimer()
    return
  end
  self:_SendBatchGetTableReq(tCurBatchReqList, reqKey)
end
function BasicDataServerTable:BatchGetOrReqData(keyList, callback)
  if not keyList then
    return
  end
  if #keyList > _nSendLimitMaxCount and Client and Client.IsDevelopment() then
    log_tree(" BasicDataServerTable:BatchGetOrReqData keyList:", keyList)
    log(bWriteLog and [[
BasicDataServerTable:BatchGetOrReqData keyList > self._nLRUCacheSize 
:]] .. debug.traceback())
  end
  local tAllTableName, bAllGet, tTableCfgMap = self:_BatchGetCheckFilterCached(keyList)
  if bAllGet then
    if callback then
      callback(tTableCfgMap)
    end
    return tTableCfgMap
  end
  for _, v in pairs(keyList) do
    self:_SetWaiting(v)
  end
  self:AddBatchGetCache(keyList, callback)
  self:OnSendBatchReqMsg(tAllTableName, self._batchReqKey)
end
function BasicDataServerTable:AddBatchGetCache(keyMap, fCallback)
  local cObj_super = self.__super
  cObj_super.AddBatchGetCache(self, keyMap, fCallback)
  local TableUtil = require("common.table_util")
  self._tCacheBatchReqList[self._batchReqKey] = TableUtil.CopyTable(keyMap)
end
function BasicDataServerTable:OnHandleBatchMsgCallback(infoMap, reqKey)
  if not reqKey or reqKey == 0 or reqKey == "" then
    return
  end
  if self._tCacheRelationReqKey[reqKey] then
    local tCheckedReqKey = {}
    for _, v in ipairs(self._tCacheRelationReqKey[reqKey]) do
      if not tCheckedReqKey[v] then
        self:OnHandleBatchMsgCallback(infoMap, v)
        tCheckedReqKey[v] = true
      end
    end
  end
  local bAllGet = false
  local tAllMapData = infoMap
  if self._tCacheBatchReqList[reqKey] then
    bAllGet, tAllMapData = self:GetCacheDataStateByList(self._tCacheBatchReqList[reqKey])
  else
    bAllGet = true
  end
  if bAllGet then
    self._tCacheBatchReqList[reqKey] = nil
    if self._batchReqDelegates and self._batchReqDelegates[reqKey] then
      self._batchReqDelegates[reqKey](tAllMapData)
      self._batchReqDelegates[reqKey] = nil
    end
  end
  self._tCacheRelationReqKey[reqKey] = nil
end
function BasicDataServerTable:_SetDataCache(key, info)
  if not self:GetIsLRUCache() then
    local cObj_super = self.__super
    cObj_super._SetDataCache(self, key, info)
    return
  end
  local cObj_LRUCache = self._cacheDataMap.data
  if not self._cacheDataMap.data then
    local LRU = require("common.LRU")
    cObj_LRUCache = LRU(self._nLRUCacheSize)
    self._cacheDataMap.data = cObj_LRUCache
  end
  cObj_LRUCache:Set(key, info)
end
function BasicDataServerTable:GetCacheData(key)
  if not self:GetIsLRUCache() then
    local cObj_super = self.__super
    return cObj_super.GetCacheData(self, key)
  end
  local cObj_LRUCache = self._cacheDataMap.data
  if not cObj_LRUCache then
    return
  end
  local tTableData = cObj_LRUCache:Get(key)
  if not tTableData and self._tCacheReadLocalData[key] then
    tTableData = self:_LoadLocalCache(key)
  end
  return tTableData
end
function BasicDataServerTable:on_client_table_batch_rsp(res, keyMap, reqKey)
  if self.TableCfgs == nil then
    self:_LoadTableCfgs()
  end
  local infoMap = self:_ProcessRspData(res, keyMap, reqKey)
  self:OnHandleBatchMsgDataAndCallback(infoMap, reqKey)
end
function BasicDataServerTable:GetLRUCacheSize()
  return self._nLRUCacheSize
end
function BasicDataServerTable:_SendBatchGetTableReq(tBatchReqCfgName, reqKey)
  if self.TableCfgs == nil then
    self:_LoadTableCfgs()
  end
  log_tree("BasicDataServerTable:_SendBatchGetTableReq >>>> tBatchReqCfgName", tBatchReqCfgName)
  local tDatatableMap = {}
  for _, tableName in ipairs(tBatchReqCfgName) do
    local cfg = self.TableCfgs[tableName]
    local version = cfg and cfg.Version or 0
    tDatatableMap[tableName] = version
  end
  local TableDataHandler = require("client.network.Protocol.TableDataHandler")
  TableDataHandler.send_client_table_batch_req(tDatatableMap, reqKey)
  local TimeUtil = require("client.common.time_util")
  local nCurTime = TimeUtil.GetServerTimeInSec()
  table.insert(self.tAllSendTimeRecord, nCurTime)
end
function BasicDataServerTable:_LoadLocalCache(sTableName)
  local tTableData = self:_LoadLuaFromTable(sTableName)
  if tTableData then
    self:_SetDataCache(sTableName, tTableData)
    self._tCacheReadLocalData[sTableName] = true
  end
  return tTableData
end
function BasicDataServerTable:_ProcessRspData(res, tables, reqKey)
  if res == unknow_pass_errcode_param then
    log_error("BasicDataServerTable:_ProcessRspData cnt over limit ")
    return
  end
  local table_datas = {}
  if res == 0 then
    local FailedLoadTables = {}
    local VersionChanged = false
    for table_name, cfg in pairs(tables) do
      if cfg and type(cfg) == "table" then
        if cfg.err == 0 then
          local _beginTime = getTime()
          local tableData = self:GetCacheData(table_name)
          if cfg.saved_flag then
            tableData = slua.LuaArchiverDecode(LuaStateWrapper, cfg.data) or {}
          else
            tableData = cfg.data
          end
          table_datas[table_name] = tableData
          self:_SetDataCache(table_name, tableData)
          self.TableCfgs[table_name] = self.TableCfgs[table_name] or {}
          local tableCfg = self.TableCfgs[table_name]
          tableCfg.Version = cfg.version
          VersionChanged = true
          self:_SaveLuaToTable(table_name, tableData)
          self._tCacheReadLocalData[table_name] = true
          local _cost = getTime() - _beginTime
          log(bWriteLog and "BasicDataServerTable:_ProcessRspData table: " .. tostring(table_name) .. " cost: " .. tostring(_cost) .. "ms")
        elseif cfg.err == errcode_table_not_change then
          log(bWriteLog and "BasicDataServerTable:_ProcessRspData errcode_table_not_change:" .. tostring(table_name))
          local tableData = self:GetCacheData(table_name)
          tableData = tableData or self:_LoadLocalCache(table_name)
          if not tableData then
            local tableCfg = self.TableCfgs[table_name]
            if tableCfg then
              tableCfg.Version = 0
              VersionChanged = true
            end
            table.insert(FailedLoadTables, table_name)
          else
            table_datas[table_name] = tableData
          end
        elseif cfg.err == errcode_invalid_table_name then
          self:_SetDataCache(table_name, {})
          log(bWriteLog and "BasicDataServerTable:_ProcessRspData errcode_invalid_table_name:" .. tostring(table_name))
        end
      end
      if VersionChanged then
        self:_SaveTableCfgs()
      end
      if next(FailedLoadTables) ~= nil then
        log_tree("FailedLoadTables", FailedLoadTables)
        self:OnSendBatchReqMsg(FailedLoadTables, reqKey)
        return table_datas
      end
    end
  end
  return table_datas
end
function BasicDataServerTable:_LoadTableCfgs()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  self.TableCfgs = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eTableCfg)
  self.TableCfgs = self.TableCfgs or {}
end
function BasicDataServerTable:_SaveTableCfgs()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(self.TableCfgs, PlayerPrefsSystem.ePlayerPrefsType.eTableCfg)
end
function BasicDataServerTable:_SaveLuaToTable(tableName, luaTb)
  local data = slua.LuaArchiverEncode(LuaStateWrapper, luaTb)
  if #data >= maxTableDataSize then
    log_error("BasicDataServerTable:_SaveLuaToTable tableName:" .. tostring(tableName) .. ", data is to large" .. " size:" .. #data)
  end
  local ScriptHelperClient = import("ScriptHelperClient")
  ScriptHelperClient.SaveArrayToFile(data, BaseAddr .. tableName)
end
function BasicDataServerTable:_LoadLuaFromTable(tableName)
  local ScriptHelperClient = import("ScriptHelperClient")
  local data = ScriptHelperClient.LoadFileToArray(BaseAddr .. tableName)
  if #data >= maxTableDataSize then
    log_error("BasicDataServerTable:_LoadLuaFromTable tableName:" .. tostring(tableName) .. ", data is to large" .. " size:" .. #data)
  end
  local luaTb = slua.LuaArchiverDecode(LuaStateWrapper, data)
  return luaTb
end
function BasicDataServerTable:_GetIsCanSend()
  local TimeUtil = require("client.common.time_util")
  local nCurTime = TimeUtil.GetServerTimeInSec()
  local nCount = 0
  for i = #self.tAllSendTimeRecord, 1, -1 do
    if nCurTime - self.tAllSendTimeRecord[i] <= _nTimeLimit then
      nCount = nCount + 1
    else
      table.remove(self.tAllSendTimeRecord, i)
    end
  end
  if nCount > _nTimeLimitCount then
    return false
  end
  return true
end
function BasicDataServerTable:_AddCheckQueueTimer()
  if self._nCheckQueueTimerId then
    return
  end
  self._nCheckQueueTimerId = self:AddTimerOnce(_nCheckQueueInterval, function()
    self._nCheckQueueTimerId = nil
    log(bWriteLog and " BasicDataServerTable:_AddCheckQueueTimer  >>> BasicDataServerTable:_CheckQueueReq")
    self:_CheckQueueReq()
  end)
end
function BasicDataServerTable:_CheckQueueReq()
  local bIsCanSend = self:_GetIsCanSend()
  if not bIsCanSend then
    self:_AddCheckQueueTimer()
    return
  else
    local tCanReqTable = {}
    local nCurBatchRepKey = self._batchReqKey + 1
    self._batchReqKey = nCurBatchRepKey
    local tCurCacheRelation = self._tCacheRelationReqKey[nCurBatchRepKey] or {}
    for _ = 1, _nSendLimitMaxCount do
      if self._tQueueReqTableData[1] then
        local tRepItem = table.remove(self._tQueueReqTableData, 1)
        table.insert(tCanReqTable, tRepItem.sTableName)
        table.insert(tCurCacheRelation, tRepItem.nRelationReqKey)
      else
        break
      end
    end
    self._tCacheRelationReqKey[nCurBatchRepKey] = tCurCacheRelation
    self:_SendBatchGetTableReq(tCanReqTable, nCurBatchRepKey)
    log(bWriteLog and " BasicDataServerTable:_CheckQueueReq _tQueueReqTableData Remaining quantity:" .. tostring(#self._tQueueReqTableData))
    if #self._tQueueReqTableData > 0 then
      self:_AddCheckQueueTimer()
    end
  end
end
function BasicDataServerTable:_BatchGetCheckFilterCached(tAllTableName)
  local tAllTempName = {}
  local bAllGet = true
  local tDataMap = {}
  for _, v in pairs(tAllTableName) do
    local tInfo = self:GetCacheData(v)
    if not tInfo then
      bAllGet = false
      if not self:_CheckInWaiting(v) then
        table.insert(tAllTempName, v)
      end
    else
      tDataMap[v] = tInfo
    end
  end
  return tAllTempName, bAllGet, tDataMap
end
function BasicDataServerTable:GetIsLRUCache()
  if _bIsGmSetDisableLRUCache then
    return false
  end
  local bEnableLRUCache = HDmpveRemote.HDmpveRemoteConfigGetBool("bEnableServerTableLRU", true)
  return bEnableLRUCache
end
local class = require("class")
local CModuleBase = require("client.slua.data.BasicData.BaseClass.BasicDataBatchClass")
local CBasicDataX = class(CModuleBase, nil, BasicDataServerTable)
return CBasicDataX