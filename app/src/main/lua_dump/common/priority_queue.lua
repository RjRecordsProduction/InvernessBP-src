if not bInUGCLuaTool then
  local cpp_priority_queue
  pcall(function()
    cpp_priority_queue = require("cpp_priority_queue")
  end)
  if cpp_priority_queue then
    return cpp_priority_queue
  end
end
local floor = math.floor
local PriorityQueue = {}
PriorityQueue.__index = PriorityQueue
setmetatable(PriorityQueue, {
  __call = function(selfType, cmpFunc, eqFunc)
    local obj = setmetatable({}, selfType)
    obj:_Initialize(cmpFunc, eqFunc)
    return obj
  end
})
function PriorityQueue:_Initialize(cmpFunc, eqFunc)
  self.heap = {}
  self.currentSize = 0
  self.  self.  if not eqFunc then
    function self.eqFunc(a, b)
      return a == b
    end
  end
end
function PriorityQueue:Empty()
  return self.currentSize == 0
end
function PriorityQueue:Size()
  return self.currentSize
end
function PriorityQueue:Top()
  return self.currentSize > 0 and self.heap[1]
end
function PriorityQueue:_Swim(i)
  local heap = self.heap
  local cmpFunc = self.cmpFunc
  while i // 2 > 0 do
    local half = i // 2
    if cmpFunc(heap[i], heap[half]) then
      heap[i], heap[half] = heap[half], heap[i]
    end
    i = half
  end
end
function PriorityQueue:Push(element)
  self.heap[self.currentSize + 1] = element
  self.currentSize = self.currentSize + 1
  self:_Swim(self.currentSize)
end
function PriorityQueue:_Remove(index)
  local heap = self.heap
  if index == self.currentSize then
    heap[index] = nil
    self.currentSize = self.currentSize - 1
    return
  end
  heap[index] = heap[self.currentSize]
  heap[self.currentSize] = nil
  self.currentSize = self.currentSize - 1
  local half = floor(index / 2)
  if 0 < half and self.cmpFunc(heap[index], heap[half]) then
    self:_Swim(index)
  else
    self:_Sink(index)
  end
end
function PriorityQueue:Remove(element)
  local eqFunc = self.eqFunc
  for i, v in pairs(self.heap) do
    if eqFunc(v, element) then
      self:_Remove(i)
      return true
    end
  end
  return false
end
function PriorityQueue:_Modify(index)
  local heap = self.heap
  local half = floor(index / 2)
  if 0 < half and self.cmpFunc(heap[index], heap[half]) then
    self:_Swim(index)
  else
    self:_ModifySink(index)
  end
end
function PriorityQueue:_ModifySink(index)
  local heap = self.heap
  local left = index << 1
  if left <= self.currentSize then
    local right = left + 1
    if right <= self.currentSize and self.cmpFunc(heap[right], heap[left]) then
      left = right
    end
    if self.cmpFunc(heap[left], heap[index]) then
      heap[left], heap[index] = heap[index], heap[left]
      self:_ModifySink(left)
    end
  end
end
function PriorityQueue:Modify(element)
  local eqFunc = self.eqFunc
  for i, v in pairs(self.heap) do
    if eqFunc(v, element) then
      self:_Modify(i)
      return true
    end
  end
  return false
end
function PriorityQueue:_Sink(i)
  local size = self.currentSize
  local heap = self.heap
  local cmpFunc = self.cmpFunc
  while size >= i * 2 do
    local mc = self:_MinChild(i)
    if cmpFunc(heap[mc], heap[i]) then
      heap[i], heap[mc] = heap[mc], heap[i]
    end
    i = mc
  end
end
function PriorityQueue:_MinChild(i)
  local cmpFunc = self.cmpFunc
  if i * 2 + 1 > self.currentSize then
    return i * 2
  elseif cmpFunc(self.heap[i * 2], self.heap[i * 2 + 1]) then
    return i * 2
  else
    return i * 2 + 1
  end
end
function PriorityQueue:Pop()
  local heap = self.heap
  local retval = heap[1]
  heap[1] = heap[self.currentSize]
  heap[self.currentSize] = nil
  self.currentSize = self.currentSize - 1
  self:_Sink(1)
  return retval
end
function PriorityQueue:Clear()
  self.heap = {}
  self.currentSize = 0
end
function PriorityQueue:__pairs()
  local Iter = function(self, k)
    local v
    k, v = next(self.heap, k)
    return k, v
  end
  return Iter, self, nil
end
return PriorityQueue