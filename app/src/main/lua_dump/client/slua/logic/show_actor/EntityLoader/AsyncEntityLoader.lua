local AsyncEntityLoader = {}
local ForwardIndex = function(t, k)
  local class_index = rawget(t, "_ClassIndex")
  if type(class_index) == "function" then
    local v = class_index(t, k)
    if v ~= nil then
      return v
    end
  end
  local Target = rawget(t, "_Entity")
  if Target then
    local targetValue = Target[k]
    if type(targetValue) == "function" then
      return function(_, ...)
        return targetValue(Target, ...)
      end
    end
    return targetValue
  end
  return nil
end
local ForwardMetatable = {__index = ForwardIndex}
function AsyncEntityLoader:ctor(_, Entity)
  if not Entity then
    log_error("AsyncEntityLoader:ctor Entity is nil")
    return
  end
  self._  self._bReady = false
  self._PendingOps = {}
  local instance_mt = getmetatable(self)
  local class_index = instance_mt and instance_mt.__index
  if type(class_index) == "function" then
    rawset(self, "_ClassIndex", class_index)
    setmetatable(self, ForwardMetatable)
  end
end
function AsyncEntityLoader:SetReady()
  log(bWriteLog and "AsyncEntityLoader SetReady pending " .. tostring(#self._PendingOps))
  self._bReady = true
  self:_FlushPendingOps()
end
function AsyncEntityLoader:_FlushPendingOps()
  local PendingOps = self._PendingOps
  self._PendingOps = {}
  log(bWriteLog and "AsyncEntityLoader FlushPendingOps count " .. tostring(#PendingOps))
  for _, op in ipairs(PendingOps) do
    local Entity = self._Entity
    if Entity and op.method and Entity[op.method] then
      Entity[op.method](Entity, table.unpack(op.args or {}))
    end
  end
end
function AsyncEntityLoader:_ForwardGet(methodName, defaultRet, ...)
  if self._bReady and self._Entity then
    local Entity = self._Entity
    if Entity[methodName] then
      return Entity[methodName](Entity, ...)
    end
  end
  return defaultRet
end
function AsyncEntityLoader:_ForwardSet(methodName, ...)
  if self._bReady and self._Entity then
    local Entity = self._Entity
    if Entity[methodName] then
      return Entity[methodName](Entity, ...)
    end
  end
  self._PendingOps[#self._PendingOps + 1] = {
    method = methodName,
    args = {
      ...
    }
  }
  log(bWriteLog and "AsyncEntityLoader Enqueue " .. tostring(methodName) .. " size " .. tostring(#self._PendingOps))
end
function AsyncEntityLoader:ShowModel(ItemID, BPID)
  local Entity = self._Entity
  if not Entity then
    return
  end
  log(bWriteLog and "AsyncEntityLoader ShowModel ItemID" .. tostring(ItemID) .. " BPID " .. tostring(BPID))
  local Loader = self
  if Entity.ShowModelWithResolve then
    Entity:ShowModelWithResolve(ItemID, BPID, function()
      Loader:SetReady()
    end)
  else
    function Entity.OnChangeAvatarComplete()
      Loader:SetReady()
    end
    Entity:ShowModel(ItemID, BPID)
  end
end
function AsyncEntityLoader:OnDownLoadFinish(ItemID, BPID)
  local Entity = self._Entity
  if Entity then
    Entity:OnDownLoadFinish(ItemID, BPID)
  end
end
function AsyncEntityLoader:OnDestroy()
  local Entity = self._Entity
  if Entity then
    Entity.OnChangeAvatarComplete = nil
    Entity:RequestCancelAsyncLoad()
    Entity:OnDestroy()
  end
  self._PendingOps = {}
  self._bReady = false
end
function AsyncEntityLoader:Dispose()
  local Entity = self._Entity
  if Entity and Entity.Dispose then
    Entity:Dispose()
  end
  self._Entity = nil
end
local EntityLoaderAPI = require("client.slua.logic.show_actor.EntityLoader.EntityLoaderAPI")
for name, meta in pairs(EntityLoaderAPI) do
  if meta.type == "get" then
    AsyncEntityLoader[name] = function(self, ...)
      return self:_ForwardGet(name, meta.default, ...)
    end
  elseif meta.type == "set" then
    AsyncEntityLoader[name] = function(self, ...)
      return self:_ForwardSet(name, ...)
    end
  end
end
local class = require("class")
local object = require("object")
local CAsyncEntityLoader = class(object, nil, AsyncEntityLoader)
return CAsyncEntityLoader