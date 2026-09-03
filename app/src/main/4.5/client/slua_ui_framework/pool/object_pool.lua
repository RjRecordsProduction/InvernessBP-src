local object_pool = {}
local string_format = string.format
local local local local local local local local local local Client_IsDevelopment = Client.IsDevelopment
local slua_isValid = slua.isValid
local utility = require("common.utility")
GMDisableObjectPool = false
local GMDebugDefalut = false
local GMRecordTracebackDefalult = false
local loadFromCacheHandleID = 0
local CreatePool = function(objPath)
  if not assert(type(objPath) == "string", "CreatePool eventtype should be string ") then
    return
  end
  local pool = {
    objList = {},
    usedCount = 0,
    path = objPath,
    loadingCount = 0
  }
  return pool
end
function object_pool:_DestroyPool(pool)
  log(bWriteLog and "object_pool:_DestroyPool poolName:" .. self.extendedParams.poolName .. " Path: " .. pool.path)
  self.objectPool[pool.path] = nil
  for obj, path in pairs(self.objPathMap) do
    if path == pool.path then
      self:_SetObjPathMap(obj, nil)
    end
  end
  pool.left.right = pool.right
  pool.right.left = pool.left
end
function object_pool:ctor(selfType, constructFunc, destructFunc, onRelease, extendedParams)
  self.  self.  self.  self.  self.constructASyFunc = extendedParams.constructASyFunc
  self.cancelFunc = extendedParams.cancelFunc
  self.extendedParams.bDebug = self.extendedParams.bDebug or GMDebugDefalut
  if self.extendedParams.bDebug then
    self.TimeUtil = require("client.common.time_util")
  end
  local lruHead = {left = nil, right = nil}
  lruHead.left = lruHead
  lruHead.right = lruHead
  self.  self.totalPoolObjectNum = 0
  self.minPoolObjectNum = 2
  self.maxPoolObjectNum = 30
  self.objectPool = {}
  self.objPathMap = {}
  self.AsyncHandleIDAMap = {}
  self.GMRecordTraceback = GMRecordTracebackDefalult
  function self.onModePreSwitchEnd()
    self:Clear()
    if self.GMRecordTraceback then
      local logic_leak_check_UI = RequireBlackList("blacklist.slua.logic.lobby.logic_leak_check_UI")
      for path, pool in pairs(self.objectPool) do
        if logic_leak_check_UI then
          logic_leak_check_UI.CheckPoolLeak(path)
        end
      end
    end
  end
  EventSystem:registEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_PRE_SWITCH_END, self.onModePreSwitchEnd)
end
function object_pool:SetPoolLimit(min, max)
  self.minPoolObjectNum = min
  self.maxPoolObjectNum = max
  log(bWriteLog and "object_pool:SetPoolLimit poolName:" .. self.extendedParams.poolName .. " min: " .. min .. " max:" .. max)
end
function object_pool:_CreateTouchPool(objPath)
  if not assert(objPath ~= nil, " object_pool:_CreateTouchPool objPath ~= nil ") then
    return
  end
  if not assert(objPath ~= "", " object_pool:_CreateTouchPool objPath ~=  ") then
    return
  end
  local pool = self.objectPool[objPath]
  if not pool then
    pool = CreatePool(objPath)
    self.objectPool[objPath] = pool
  end
  self:_TouchPool(pool)
  return pool
end
function object_pool:_GetPoolObject(pool)
  local index, objFromPool = next(pool.objList)
  pool.objList[index] = nil
  self.totalPoolObjectNum = self.totalPoolObjectNum - 1
  return objFromPool
end
function object_pool:_SetPoolMap(pool, obj, objPath)
  self:_SetObjPathMap(obj, objPath)
  pool.usedCount = pool.usedCount + 1
end
function object_pool:_TouchPool(pool)
  if pool.left and pool.right then
    pool.left.right = pool.right
    pool.right.left = pool.left
  end
  local lruHead = self.lruHead
  pool.left = lruHead
  pool.right = lruHead.right
  lruHead.right.left = pool
  lruHead.right = pool
  return pool
end
function object_pool:Get(objPath, callback, bSingleton)
  if GMDisableObjectPool then
    return self:_GetForDisablePool(objPath, callback, bSingleton)
  end
  local startTime
  if self.extendedParams.bDebug then
    if not self.TimeUtil then
      self.TimeUtil = require("client.common.time_util")
    end
    startTime = self.TimeUtil.GetMiliseconds()
  end
  local pool = self:_CreateTouchPool(objPath)
  local obj, bPoolCtor
  if next(pool.objList) then
    obj = self:_GetPoolObject(pool)
    bPoolCtor = false
  else
    obj = self.constructFunc(objPath, bSingleton)
    if not obj then
      log_warning(string_format("Can't load object of [%s]!", objPath))
      return
    end
    bPoolCtor = true
  end
  self:_SetPoolMap(pool, obj, objPath)
  if self.GMRecordTraceback then
    local logic_leak_check_UI = RequireBlackList("blacklist.slua.logic.lobby.logic_leak_check_UI")
    if logic_leak_check_UI then
      logic_leak_check_UI.AddPoolTraceForSynLoad(objPath, obj)
    end
  end
  if self.extendedParams.bDebug then
    local timeSpan = self.TimeUtil.GetMiliseconds() - startTime
    log(bWriteLog and "TimeTracer object_pool:Get poolName:" .. self.extendedParams.poolName .. " obj: " .. tostring(obj) .. " isReuse:" .. tostring(not bPoolCtor) .. " time(ms):" .. timeSpan .. " totalPoolObjectNum: " .. self.totalPoolObjectNum .. " pool.usedCount:" .. pool.usedCount)
  end
  if callback then
    callback(bPoolCtor)
  end
  return obj
end
function object_pool:GetAsy(objPath, callback, bSingleton)
  if GMDisableObjectPool then
    return self:_GetAsyForDisablePool(objPath, callback, bSingleton)
  end
  local startTime
  if self.extendedParams.bDebug then
    startTime = self.TimeUtil.GetMiliseconds()
  end
  local pool = self:_CreateTouchPool(objPath)
  local obj, bPoolCtor
  if next(pool.objList) then
    obj = self:_GetPoolObject(pool)
    self:_SetPoolMap(pool, obj, objPath)
    if self.GMRecordTraceback then
      local logic_leak_check_UI = RequireBlackList("blacklist.slua.logic.lobby.logic_leak_check_UI")
      if logic_leak_check_UI then
        logic_leak_check_UI.AddPoolTraceForSynLoad(objPath, obj)
      end
    end
    bPoolCtor = false
    if self.extendedParams.bDebug then
      local timeSpan = self.TimeUtil.GetMiliseconds() - startTime
      log(bWriteLog and "TimeTracer object_pool:GetAsy cache poolName:" .. self.extendedParams.poolName .. " obj: " .. tostring(obj) .. " isReuse:" .. tostring(not bPoolCtor) .. " time(ms):" .. timeSpan .. " totalPoolObjectNum: " .. self.totalPoolObjectNum .. " pool.usedCount:" .. pool.usedCount)
    end
    if callback then
      callback(obj, bPoolCtor)
    end
  else
    pool.loadingCount = pool.loadingCount + 1
    local traceStr
    if self.GMRecordTraceback then
      traceStr = debug.traceback("AddPoolTrace AsynLoad Get Path", 2)
    end
    local HandleID = loadFromCacheHandleID
    HandleID = self.constructASyFunc(objPath, function(cbHandleID, CallObj)
      if not CallObj then
        if callback then
          callback(CallObj, bPoolCtor)
        end
        return
      end
      self:_SetPoolMap(pool, CallObj, objPath)
      if self.GMRecordTraceback then
        local logic_leak_check_UI = RequireBlackList("blacklist.slua.logic.lobby.logic_leak_check_UI")
        if logic_leak_check_UI then
          logic_leak_check_UI.AddPoolTraceForAsynLoad(objPath, CallObj, traceStr)
        end
      end
      pool.loadingCount = pool.loadingCount - 1
      self.AsyncHandleIDAMap[cbHandleID] = nil
      bPoolCtor = true
      if self.extendedParams.bDebug then
        local timeSpan = self.TimeUtil.GetMiliseconds() - startTime
        log(bWriteLog and "TimeTracer object_pool:GetAsy poolName:" .. self.extendedParams.poolName .. " obj: " .. tostring(CallObj) .. " isReuse:" .. tostring(not bPoolCtor) .. " time(ms):" .. timeSpan .. " totalPoolObjectNum: " .. self.totalPoolObjectNum .. " pool.usedCount:" .. pool.usedCount)
      end
      if callback then
        callback(CallObj, bPoolCtor)
      end
    end, bSingleton)
    if HandleID ~= loadFromCacheHandleID then
      self.AsyncHandleIDAMap[HandleID] = pool
    end
    return HandleID
  end
  return nil
end
function object_pool:Cancel(HandleID)
  local pool = self.AsyncHandleIDAMap[HandleID]
  if pool then
    pool.loadingCount = pool.loadingCount - 1
    self.AsyncHandleIDAMap[HandleID] = nil
  end
  return self.cancelFunc(HandleID)
end
function object_pool:Release(obj)
  if GMDisableObjectPool then
    return
  end
  if not obj or not slua_isValid(obj) then
    return
  end
  if self.onRelease then
    self.onRelease(obj)
  end
  local objPath = self.objPathMap[obj]
  self:_SetObjPathMap(obj, nil)
  if not assert_format(objPath ~= nil and objPath ~= "", "object_pool:Release objPath should be not nil and objPath should be [%s]", objPath) then
    return
  end
  if self.GMRecordTraceback then
    local logic_leak_check_UI = RequireBlackList("blacklist.slua.logic.lobby.logic_leak_check_UI")
    if logic_leak_check_UI then
      logic_leak_check_UI.RemovePoolTrace(objPath, obj)
    end
  end
  local pool = self.objectPool[objPath]
  if not assert_format(pool ~= nil, "object_pool:Release pool should not be nil Path : [%s]", objPath) then
    return
  end
  pool.usedCount = pool.usedCount - 1
  if not assert_format(pool.usedCount >= 0, "object_pool:Release pool pool.usedCount >= 0 : [%s]", objPath) then
    return
  end
  pool.objList[#pool.objList + 1] = obj
  self.totalPoolObjectNum = self.totalPoolObjectNum + 1
  if self.extendedParams.bDebug then
    log(bWriteLog and "object_pool:Release poolName:" .. self.extendedParams.poolName .. " obj:" .. tostring(obj) .. " totalPoolObjectNum: " .. self.totalPoolObjectNum .. " pool.usedCount:" .. pool.usedCount)
  end
end
function object_pool:_ReleasePoolToNum(num)
  local head = self.lruHead
  local tail = head.left
  local objsToDestruct = {}
  if self.extendedParams.bDebug then
    log(bWriteLog and "object_pool:_ReleasePoolToNum poolName:" .. self.extendedParams.poolName .. " totalPoolObjectNum: " .. self.totalPoolObjectNum .. " goalNum" .. num)
  end
  while num < self.totalPoolObjectNum and tail ~= head do
    local objList = tail.objList
    for k, obj in pairs(objList) do
      objsToDestruct[#objsToDestruct + 1] = obj
      objList[k] = nil
      self.totalPoolObjectNum = self.totalPoolObjectNum - 1
      if num >= self.totalPoolObjectNum then
        break
      end
    end
    if not next(objList) and tail.usedCount and tail.usedCount <= 0 and tail.loadingCount and 0 >= tail.loadingCount then
      self:_DestroyPool(tail)
    end
    tail = tail.left
  end
  local destructFunc = self.destructFunc
  for _, obj in pairs(objsToDestruct) do
    xpcall(destructFunc, utility.ErrorMessageHandler, obj)
  end
end
function object_pool:Clear()
  local objsToDestruct = {}
  for path, pool in pairs(self.objectPool) do
    for k, obj in pairs(pool.objList) do
      objsToDestruct[#objsToDestruct + 1] = obj
      pool.objList[k] = nil
      self.totalPoolObjectNum = self.totalPoolObjectNum - 1
    end
    if pool.usedCount <= 0 and not next(pool.objList) and 0 >= pool.loadingCount then
      self:_DestroyPool(pool)
    end
  end
  local destructFunc = self.destructFunc
  for _, obj in pairs(objsToDestruct) do
    xpcall(destructFunc, utility.ErrorMessageHandler, obj)
  end
end
function object_pool:Dispose()
  EventSystem:unregistEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_PRE_SWITCH_END, self.onModePreSwitchEnd)
  self:Clear()
  self.constructFunc = nil
  self.constructASyFunc = nil
  self.destructFunc = nil
  self.cancelFunc = nil
  self.onRelease = nil
end
function object_pool:_SetObjPathMap(obj, path)
  if not assert(obj ~= nil, "object_pool:_SetObjPathMap obj should not be nil") then
    return
  end
  self.objPathMap[obj] = path
end
function object_pool:_GetForDisablePool(objPath, callback, bSingleton)
  local obj = self.constructFunc(objPath, bSingleton)
  if callback then
    callback(true)
  end
  return obj
end
function object_pool:_GetAsyForDisablePool(objPath, callback, bSingleton)
  local HandleID = self.constructASyFunc(objPath, function(_, CallObj)
    if callback then
      callback(CallObj, true)
    end
  end, bSingleton)
  return HandleID
end
function object_pool:SetGMRecordTraceback(bValue)
  if not Client_IsDevelopment() then
    return
  end
  local ui_util = require("client.common.ui_util")
  local deviceLevel = ui_util.GetGameInstance():GetDeviceLevel()
  if deviceLevel < 2 then
    return
  end
  self.GMRecordTraceback = bValue
  log(bWriteLog and "object_pool:SetGMRecordTraceback poolName:" .. self.extendedParams.poolName .. " bValue: " .. tostring(bValue))
end
local class = require("class")
local object = require("object")
local CObjectPool = class(object, nil, object_pool)
return CObjectPool