local ReddotDriver = {}
local string_format = string.format
local local local local local reddot_util = require("client.slua.logic.reddot.reddot_util")
local reddot_config = require("client.slua.logic.reddot.reddot_config")
local reddot_message_center = require("client.slua.logic.reddot.reddot_message_center")
local reddot_manager
local AddSuperDataDelegate = function(superdata, fieldname, notFirstCallBack, callback)
  return superdata:AddListener(fieldname, callback, notFirstCallBack)
end
local AddSuperDataNewIndexListener = function(superdata, callback)
  return superdata:AddNewIndexListener(callback)
end
local AddLeafDataNewIndexListener = function(superdata, callback)
  return superdata:AddNewIndexListener(callback)
end
local TimeRecorder = {}
local GenDefaultSystemRecord = function()
  return {
    subIDs = {},
    maxEliminateTime = 0,
    extraNewCount = 0
  }
end
local GetNodeTimeReddots = function(systemName, subID)
  if not TimeRecorder[systemName] then
    TimeRecorder[systemName] = GenDefaultSystemRecord()
  end
  local nodeTime = TimeRecorder[systemName].subIDs[subID]
  if not nodeTime then
    nodeTime = {
      reddots = {}
    }
    TimeRecorder[systemName].subIDs[subID] = nodeTime
  end
  return nodeTime.reddots
end
local GetLeafTime = function(rootNode, node, id)
  local reddots = GetNodeTimeReddots(rootNode, node)
  local leafTime = reddots[id]
  local isNew = false
  if not leafTime then
    leafTime = {}
    isNew = true
    reddots[id] = leafTime
  end
  return leafTime, isNew
end
local OnReddotIncrease = function(rootNode, node, id)
  local systemName = rootNode.desc
  local now = reddot_util:GetTimestamp()
  local leafTime, isNew = GetLeafTime(rootNode, node, id)
  if isNew then
    leafTime.startTime = now
    leafTime.showTime = node.realCount > 0 and now or 0
    leafTime.showLastTime = 0
  end
  if not leafTime.isRead then
    reddot_message_center:OnReddotAdd(systemName, node, id)
  end
  return true, isNew
end
local function Drive(rootNode, node, nodeKey, currentDepth)
  node.depth = currentDepth
  if not reddot_manager:IsValidForUserLabel(rootNode.desc, node.subID) then
    return
  end
  local isLeaf = true
  local HandleLeaf = function(childData, childKeyName)
    local scope = -1
    local isInvalid = false
    local Increase = function(key)
      if type(key) ~= "number" then
        log_warning(string_format("reddot_driver:Drive Increase [%s] key[%s] is not num", rootNode.desc, key))
      end
      local valid, isNew = OnReddotIncrease(rootNode, node, key)
      if valid then
        node.newCount = node.newCount + 1
        if isNew then
          rootNode.extraNewCount = rootNode.extraNewCount + 1
        end
      else
        isInvalid = true
        childData[key] = nil
        isInvalid = false
      end
    end
    AddLeafDataNewIndexListener(childData, function(key, oldValue, newValue)
      scope = scope + 1
      if scope <= 0 then
        if oldValue == nil then
          Increase(key)
        elseif newValue == nil and not isInvalid then
          local count = node.newCount - 1
          node.newCount = count
          if count < 0 then
            log_warning(bWriteLog and string_format("reddot_driver:Drive HandleLeaf Invalid leaf time of %s.%d.%s", rootNode.desc, node.subID, key))
          end
        end
      end
      scope = scope - 1
    end)
    AddSuperDataDelegate(node, childKeyName, true, function(oldValue, value)
      if oldValue == value then
        return
      end
      local decreaseCount = 0
      for key, _ in pairs(oldValue) do
        if value[key] == nil then
          decreaseCount = decreaseCount + 1
        end
      end
      for key, _ in pairs(value) do
        if oldValue[key] == nil then
          Increase(key)
        end
      end
      node.newCount = node.newCount - decreaseCount
    end)
    for instanceId, _ in pairs(childData) do
      Increase(instanceId)
    end
  end
  if node.isDynamic then
    isLeaf = false
    AddSuperDataNewIndexListener(node, function(keyName, childData)
      if type(childData) == "table" then
        if childData._isLeaf == nil then
          Drive(rootNode, node[keyName], keyName, currentDepth + 1)
          isLeaf = false
        else
          HandleLeaf(node[keyName], keyName)
        end
      end
    end)
  end
  local isHandleLeafInstance = false
  for childKey, child in pairs(node) do
    if type(child) == "table" then
      if child._isLeaf == nil then
        isLeaf = false
        Drive(rootNode, child, childKey, currentDepth + 1)
      else
        isHandleLeafInstance = true
        HandleLeaf(child, childKey)
      end
    end
  end
  if isLeaf then
    node.isLeafNode = isLeaf
    local systemName = rootNode.desc
    local inQueueDepth = reddot_config:GetInQueueTransferDepth(systemName, node)
    local outQueueDepth = reddot_config:GetOutQueueTransferDepth(systemName, node)
    local DriveLeaf = function()
      local isInitedQueue = true
      local isInQueue
      reddot_manager:ListenIsInReddotQueue(systemName, function(oldValue, value)
        isInQueue = value
        if isInitedQueue or oldValue ~= value then
          isInitedQueue = false
          local delta = node.newCount
          local parent = node:GetParent()
          local depthA = oldValue and inQueueDepth or outQueueDepth
          local depthB = value and inQueueDepth or outQueueDepth
          while parent do
            local newCount = parent.newCount
            if depthA < parent.depth and depthB < parent.depth then
            elseif depthA < parent.depth then
              parent.newCount = newCount - delta
            elseif depthB < parent.depth then
              parent.newCount = newCount + delta
            else
              break
            end
            parent = parent:GetParent()
          end
        end
      end)
      local isInited = true
      local scope = -1
      if not isHandleLeafInstance and type(nodeKey) ~= "number" then
        log_warning(string_format("reddot_driver:Drive DriveLeaf [%s] Key[%s] is not num", rootNode.desc, nodeKey))
      end
      AddSuperDataDelegate(node, "newCount", false, function(oldValue, value)
        scope = scope + 1
        if scope <= 0 then
          local delta = value - oldValue
          if isInited then
            delta = value
            isInited = false
            if 0 < value and not isHandleLeafInstance then
              local valid, isNew = OnReddotIncrease(rootNode, node, nodeKey)
              if not valid then
                node.newCount = oldValue
                scope = scope - 1
                return
              end
              if isNew then
                rootNode.extraNewCount = rootNode.extraNewCount + 1
              end
            end
          elseif not isHandleLeafInstance and 0 < delta then
            local valid, isNew = OnReddotIncrease(rootNode, node, nodeKey)
            if not valid then
              node.newCount = oldValue
              scope = scope - 1
              return
            end
            if isNew then
              rootNode.extraNewCount = rootNode.extraNewCount + 1
            end
          end
          if delta ~= 0 then
            local parent = node:GetParent()
            local depth = isInQueue and inQueueDepth or outQueueDepth
            while parent and depth < parent.depth do
              local newCount = parent.newCount + delta
              parent.newCount = 0 < newCount and newCount or 0
              parent = parent:GetParent()
            end
          end
        end
        scope = scope - 1
      end)
      if node.isDynamicCategory and not isHandleLeafInstance then
        AddSuperDataDelegate(node, "category", true, function(oldCategory, newCategory)
          if oldCategory ~= newCategory then
            reddot_message_center:OnCategoryChange(rootNode.desc, node, oldCategory, newCategory, nodeKey)
          end
        end)
      end
    end
    if reddot_manager:IsValidForUserLevel(rootNode.desc, node.subID) then
      DriveLeaf()
    end
  end
end
function ReddotDriver:_TreeDrive(rootNode)
  local systemName = rootNode.desc
  reddot_manager = reddot_manager or require("client.slua.logic.reddot.reddot_manager")
  if not reddot_manager:IsSystemValidForUserLabel(systemName) then
    return
  end
  rootNode.extraNewCount = 0
  Drive(rootNode, rootNode, "", 0)
  if rootNode.isEliminatePrimary then
    AddSuperDataDelegate(rootNode, "newCount", true, function(_, value)
      if value == 0 then
        rootNode.extraNewCount = 0
      end
    end)
  end
end
function ReddotDriver:_Dispose()
  TimeRecorder = {}
end
return ReddotDriver