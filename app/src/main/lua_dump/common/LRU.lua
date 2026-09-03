local LRU = {}
local TimeUtil = require("client.common.time_util")
function LRU:ctor(_, capacity, ttl)
  self.capacity = capacity or 100
  self.  self.size = 0
  self.cache = {}
  self.keys = {head = nil, tail = nil}
end
function LRU:Get(key, bCheckTtl)
  local node = self.cache[key]
  if node then
    if self.ttl and bCheckTtl then
      local time = TimeUtil.GetServerTimeInSec()
      if node.cachedTimeInSec and time - node.cachedTimeInSec > self.ttl then
        self:Remove(key)
        return nil
      end
    end
    self:_MoveToEnd(node)
    return node.value
  end
  return nil
end
function LRU:Set(key, value, bRemove)
  if key == nil or value == nil then
    log(bWriteLog and "LRU:Set invalid key or invalid value")
    return
  end
  local node = self.cache[key]
  if node then
    node.    if self.ttl then
      local time = TimeUtil.GetServerTimeInSec()
      node.cachedTimeInSec = time
    end
    self:_MoveToEnd(node)
  else
    node = {
      key = key,
      value = value,
      prev = self.keys.tail,
      next = nil
    }
    if self.ttl then
      local time = TimeUtil.GetServerTimeInSec()
      node.cachedTimeInSec = time
    end
    if self.keys.tail then
      self.keys.tail.next = node
    else
      self.keys.head = node
    end
    self.keys.tail = node
    self.cache[key] = node
    self.size = self.size + 1
    bRemove = bRemove ~= false
    if bRemove and self.size > self.capacity then
      self:_RemoveOldest()
    end
  end
end
function LRU:Remove(key)
  log(bWriteLog and "LRU:Remove with key = " .. tostring(key))
  local node = self.cache[key]
  if node then
    if node.prev then
      node.prev.next = node.next
    else
      self.keys.head = node.next
    end
    if node.next then
      node.next.prev = node.prev
    else
      self.keys.tail = node.prev
    end
    self.cache[key] = nil
    self.size = self.size - 1
  end
end
function LRU:RemoveOutOfRangeNodes()
  while self.size > self.capacity do
    self:_RemoveOldest()
  end
end
function LRU:Clear()
  log(bWriteLog and "LRU:Clear")
  self.cache = {}
  self.size = 0
  self.keys = {head = nil, tail = nil}
end
function LRU:GetCacheDataMap()
  local tAllData = {}
  for k, v in pairs(self.cache) do
    tAllData[k] = v.value
  end
  return tAllData
end
function LRU:_MoveToEnd(node)
  if node.next then
    if node.prev then
      node.prev.next = node.next
      node.next.prev = node.prev
    else
      self.keys.head = node.next
      node.next.prev = nil
    end
    node.prev = self.keys.tail
    node.next = nil
    self.keys.tail.next = node
    self.keys.tail = node
  end
end
function LRU:_RemoveOldest()
  local head = self.keys.head
  self.keys.head = head.next
  if self.keys.head then
    self.keys.head.prev = nil
  else
    self.keys.tail = nil
  end
  self.cache[head.key] = nil
  self.size = self.size - 1
end
local class = require("class")
local object = require("object")
local CLRU = class(object, nil, LRU)
return CLRU