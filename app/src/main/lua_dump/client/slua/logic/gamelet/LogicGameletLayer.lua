local LogicGameletLayer = {}
function LogicGameletLayer:InitData()
  self.DepthStack = {}
end
function LogicGameletLayer:DestroyData()
  self.DepthStack = nil
end
function LogicGameletLayer:Push(newNode)
  if not self.DepthStack then
    self.DepthStack = {}
  end
  local node, nodeIndex
  local equalFlag = false
  local Equal = function(oldNode, newNode)
    if oldNode.appType ~= newNode.appType then
      return false
    end
    if oldNode.appId ~= newNode.appId then
      return false
    end
    if oldNode.appPage ~= newNode.appPage then
      return false
    end
    return true
  end
  for index, ownedNode in ipairs(self.DepthStack) do
    if Equal(ownedNode, newNode) then
      node = ownedNode
      nodeIndex = index
      equalFlag = true
    end
  end
  if not equalFlag then
    node = newNode
  else
    table.remove(self.DepthStack, nodeIndex)
  end
  table.insert(self.DepthStack, node)
end
function LogicGameletLayer:Pop()
  if self:Empty() then
    return
  end
  local length = #self.DepthStack
  local node = table.remove(self.DepthStack, length)
  return node
end
function LogicGameletLayer:Empty()
  if not self.DepthStack or #self.DepthStack == 0 then
    return true
  end
  return false
end
function LogicGameletLayer:Front()
  if self:Empty() then
    return
  end
  return self.DepthStack[#self.DepthStack]
end
function LogicGameletLayer:End()
  if self:Empty() then
    return
  end
  return self.DepthStack[1]
end
function LogicGameletLayer:Size()
  return #self.DepthStack
end
function LogicGameletLayer:Clear()
  self.DepthStack = {}
end
return LogicGameletLayer