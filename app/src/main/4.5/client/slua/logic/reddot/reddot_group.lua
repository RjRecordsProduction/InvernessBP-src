local ReddotGroup = {}
local super_data = require("common.super_data")
local groups = {}
local containers = {}
local systemToGroupMap = {}
function ReddotGroup:AddGroup(name)
  local groupData = super_data.CreateSuperData({
    newCount = 0,
    realCount = 0,
    realWeight = 0,
    isGroup = true,
    subID = 0,
    desc = ""
  })
  groups[name] = groupData
  return groupData
end
function ReddotGroup:AddToGroup(rootNode, groupName)
  local systemName = rootNode and rootNode.desc or ""
  groupName = groupName or ""
  if systemName == "" or groupName == "" then
    log_error(string.format("ReddotGroup:AddToGroup system[%s] add to group[%s].", systemName, groupName))
    return
  end
  groups[groupName][systemName] = {
    newCount = 0,
    realCount = 0,
    realWeight = 0,
    subID = 0
  }
  systemToGroupMap[systemName] = groupName
  local group = groups[groupName]
  local groupSystem = groups[groupName][systemName]
  local delegateGroup = containers[groupName]
  if not delegateGroup then
    delegateGroup = {}
    containers[groupName] = delegateGroup
  end
  local delegateContainer = delegateGroup[systemName]
  if not delegateContainer then
    local CDelegateContainer = require("common.delegate_container")
    delegateContainer = CDelegateContainer()
    delegateGroup[systemName] = delegateContainer
  else
    delegateContainer:Dispose()
  end
  local ListenGroupSystemIncrease = function(fieldName)
    delegateContainer:AddDataListener(groupSystem, fieldName, function(oldValue, value)
      group[fieldName] = group[fieldName] + value - oldValue
    end)
  end
  local ListenGroupSystemCompare = function(fieldName)
    local isInited = true
    delegateContainer:AddDataListener(groupSystem, fieldName, function(oldValue, value)
      if isInited or oldValue < value and group.desc ~= systemName then
        if value > group[fieldName] then
          print(bWriteLog and string.format("Reddot group \230\153\139\231\186\167: \231\179\187\231\187\159[%s]\230\140\164\228\184\138\231\187\132[%s]\231\154\132\229\137\141\229\164\180\239\188\140\232\128\129\231\179\187\231\187\159[%s]", systemName, groupName, group.desc))
          group[fieldName] = value
          group.desc = systemName
          group.subID = groupSystem.subID
        end
        isInited = false
      elseif value < oldValue and group.desc == systemName and value < group[fieldName] then
        local max = 0
        local maxSys = ""
        local maxSubID = 0
        for sysName, groupSys in pairs(group) do
          if type(groupSys) == "table" and max < groupSys[fieldName] then
            max = groupSys[fieldName]
            maxSys = sysName
            maxSubID = groupSys.subID
          end
        end
        print(bWriteLog and string.format("Reddot group \233\153\141\231\186\167: \231\179\187\231\187\159[%s]\230\140\164\228\184\138\231\187\132[%s]\231\154\132\229\137\141\229\164\180\239\188\140\232\128\129\231\179\187\231\187\159[%s]", maxSys, groupName, group.desc))
        group[fieldName] = max
        group.desc = maxSys
        group.subID = maxSubID
      end
    end)
  end
  ListenGroupSystemIncrease("realCount")
  ListenGroupSystemIncrease("newCount")
  ListenGroupSystemCompare("realWeight")
  delegateContainer:AddDataListener(group, "realCount", function(oldValue, value)
    rootNode.groupShow = 0 < value
  end)
  delegateContainer:AddDataListener(groupSystem, "subID", function(oldValue, value)
    if group.desc == systemName then
      group.subID = value
    end
  end)
  local ListenRootNode = function(fieldName)
    delegateContainer:AddDataListener(rootNode, fieldName, function(oldValue, value)
      groupSystem[fieldName] = value
    end)
  end
  ListenRootNode("realCount")
  ListenRootNode("newCount")
  ListenRootNode("realWeight")
  ListenRootNode("subID")
end
function ReddotGroup:RemoveFromGroup(rootNode, groupName)
  local systemName = rootNode.desc
  print(bWriteLog and string.format("Reddot System[%s] remove from group[%s].", systemName, groupName))
  local groupSystem = groups[groupName][systemName]
  groupSystem.newCount = 0
  groupSystem.realCount = 0
  groupSystem.realWeight = 0
  if containers[groupName] then
    local delegateContainer = containers[groupName][systemName]
    if delegateContainer then
      delegateContainer:Dispose()
    end
  end
  systemToGroupMap[systemName] = nil
end
function ReddotGroup:IsInGroup(systemName, groupName)
  local isInGroup = systemToGroupMap[systemName] ~= nil
  if isInGroup and groupName then
    local group = groups[groupName]
    if not group then
      return false
    end
    local groupSystem = group[systemName]
    return groupSystem ~= nil
  end
  return isInGroup
end
function ReddotGroup:GetSystemGroupName(systemName)
  return systemToGroupMap[systemName]
end
function ReddotGroup:OnLogin()
end
function ReddotGroup:OnLogout()
  for _, delegateGroup in pairs(containers) do
    for _, delegateContainer in pairs(delegateGroup) do
      delegateContainer:Dispose()
    end
  end
  containers = {}
  for _, groupSystem in pairs(groups) do
    groupSystem.realCount = 0
    groupSystem.newCount = 0
    groupSystem.realWeight = 0
    groupSystem.subID = 0
    groupSystem.desc = ""
  end
end
return ReddotGroup