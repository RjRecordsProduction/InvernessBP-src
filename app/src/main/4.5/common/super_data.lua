if not bInUGCLuaTool then
  local super_data
  pcall(function()
    super_data = require("cpp_super_data")
  end)
  if super_data then
    return super_data
  end
end
local SuperData = {}
local Leaf = {}
local LeafData = {}
local string_format = string.format
local table_remove = table.remove
local local local local local local local local local SuperData_newIndex = "__NI__"
local CustomNext = function(t, k)
  local v
  k, v = next(t, k)
  if k == "_isLeaf" then
    k, v = next(t, k)
  end
  if v ~= nil then
    return k, v
  end
end
function LeafData:__pairs()
  return CustomNext, self, nil
end
local CheckLeafDataMeta = function(data)
  local mt = getmetatable(data)
  if not mt then
    setmetatable(data, LeafData)
  end
end
function Leaf:__pairs()
  return CustomNext, self._data, nil
end
function Leaf:__len()
  local len = 0
  for _, _ in pairs(self) do
    len = len + 1
  end
  return len
end
function Leaf:__newindex(key, newValue)
  local data = self._data
  local oldValue = data[key]
  data[key] = newValue
  if oldValue ~= newValue then
    local listeners = self._listeners
    for i = 1, #listeners do
      listeners[i](key, oldValue, newValue)
    end
  end
end
function Leaf:__index(k)
  if Leaf[k] then
    return Leaf[k]
  end
  local data = self._data
  return data[k]
end
function Leaf:IsEmpty()
  for _, _ in pairs(self) do
    return false
  end
  return true
end
function Leaf:AddNewIndexListener(callback)
  self._listeners[#self._listeners + 1] = callback
end
function Leaf:RemoveNewIndexListener(callback)
  local listeners = self._listeners
  for i, cb in pairs(listeners) do
    if cb == callback then
      table_remove(listeners, i)
      break
    end
  end
end
local CreateLeafData = function(leafData)
  local superLeaf = setmetatable({
    _data = leafData,
    _listeners = {}
  }, Leaf)
  return superLeaf
end
function SuperData:__index(k)
  if SuperData[k] then
    return SuperData[k]
  end
  local d = self._data[k]
  if type(d) ~= "table" then
    return d
  end
  if self._child[k] then
    return self._child[k]
  end
  if d._isLeaf then
    local child = CreateLeafData(d)
    self._child[k] = child
    CheckLeafDataMeta(d)
    return child
  else
    local child = SuperData.CreateSuperData(self._data[k], self, k)
    self._child[k] = child
    return child
  end
end
function SuperData:__newindex(key, value)
  local oldValue = self._data[key]
  local typeOfOldValue = type(oldValue)
  if typeOfOldValue ~= "nil" and typeOfOldValue ~= "userdata" and typeOfOldValue ~= type(value) then
    log_warning(bWriteLog and string_format("Data key[%s] expect type of %s, but got %s", key, typeOfOldValue, type(value)))
    if not assert(value ~= nil, bWriteLog and string_format("Unsupport delete key of %s", key)) then
      return
    end
  end
  local changed = true
  if typeOfOldValue ~= "table" then
    self._data[key] = value
    changed = oldValue ~= value
  elseif oldValue._isLeaf then
    local newValue = value._data or value
    self._data[key] = newValue
    newValue._isLeaf = true
    CheckLeafDataMeta(newValue)
    local childLeaf = self._child[key]
    if not childLeaf then
      self._child[key] = CreateLeafData(newValue)
    else
      childLeaf._data = newValue
    end
    changed = true
  else
    local child = self[key]
    for _k, _value in pairs(value) do
      child[_k] = _value
    end
  end
  if oldValue == nil then
    self:_TriggerListenerByFullKey(SuperData_newIndex, self, key, key)
  end
  if changed then
    self:_TriggerListenerByFullKey(key, self, key, oldValue)
  end
end
function SuperData:_TriggerListenerByFullKey(fullKey, root, key, oldValue)
  local listeners = root._listeners[fullKey]
  if listeners then
    local value = self._data[key]
    local utility = require("common.utility")
    for _, callback in pairs(listeners) do
      xpcall(callback, utility.ErrorMessageHandler, oldValue, value)
    end
  end
end
function SuperData:Update(newData)
  if not assert(type(newData) == "table", bWriteLog and "SuperData:Update newData should be table ") then
    return
  end
  for k, v in pairs(newData) do
    self[k] = v
  end
end
function SuperData:AddListener(key, callback, notFirstCallBack)
  self:_AddListener(key, callback)
  if not notFirstCallBack then
    local value = self
    if type(key) ~= "table" then
      value = value[key]
    else
      for _, k in pairs(key) do
        value = value[k]
        if value == nil then
          break
        end
      end
    end
    if value ~= nil then
      callback(value, value)
    end
  end
end
function SuperData:AddNewIndexListener(callback)
  return self:_AddListener(SuperData_newIndex, callback)
end
function SuperData:RemoveNewIndexListener(callback)
  return self:_RemoveListener(SuperData_newIndex, callback)
end
function SuperData:_AddListener(key, callback)
  local listeners = self._listeners[key]
  if not listeners then
    listeners = {}
    self._listeners[key] = listeners
  end
  listeners[#listeners + 1] = callback
end
function SuperData:RemoveListener(key, callback)
  return self:_RemoveListener(key, callback)
end
function SuperData:_RemoveListener(key, callback)
  local listeners = self._listeners[key]
  for i, v in pairs(listeners) do
    if v == callback then
      table_remove(listeners, i)
      break
    end
  end
end
function SuperData:__pairs()
  local Iter = function(self, k)
    local v
    k, v = next(self._data, k)
    if v ~= nil then
      return k, self[k]
    end
  end
  return Iter, self, nil
end
function SuperData:GetParent()
  return self._parent
end
function SuperData.CreateSuperData(data, parent, key)
  if data == nil then
    return nil
  end
  local superData = setmetatable({
    _parent = parent,
    _data = data,
    _listeners = {},
    _child = {}
  }, SuperData)
  return superData
end
function SuperData.CreateSuperLeafData(data)
  return CreateLeafData(data)
end
return SuperData