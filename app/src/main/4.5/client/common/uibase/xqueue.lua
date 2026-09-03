local xqueue = {}
function xqueue.Create(maxSize)
  local mt = {__index = xqueue}
  local data = {}
  setmetatable(data, mt)
  data:New(maxSize)
  return data
end
function xqueue:New(maxSize)
  self.dataList = {}
  self.end
function xqueue:Len()
  return #self.dataList
end
function xqueue:Get(i)
  return self.dataList[i]
end
function xqueue:Push(val)
  if self.maxSize then
    local len = self:Len()
    if len >= self.maxSize then
      table.remove(self.dataList, 1)
    end
  end
  table.insert(self.dataList, val)
end
function xqueue:Pop()
  local len = self:Len()
  if len <= 0 then
    return nil
  end
  local val = self.dataList[1]
  table.remove(self.dataList, 1)
  return val
end
function xqueue:Top()
  local len = self:Len()
  if len <= 0 then
    return nil
  end
  local val = self.dataList[1]
  return val
end
function xqueue:Clear()
  self.dataList = {}
end
function xqueue:Print()
  log_tree("xqueue:Print = ", self.dataList)
end
return xqueue