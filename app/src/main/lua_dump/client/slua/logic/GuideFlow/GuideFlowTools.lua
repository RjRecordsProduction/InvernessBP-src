local GuideFlowTools = {}
function GuideFlowTools.ParseNumList(numList)
  if numList == "" then
    return nil
  end
  local StringUtil = require("common.string_util")
  local arr1 = StringUtil.Split(numList, "|")
  for k, v in pairs(arr1) do
    arr1[k] = tonumber(v)
  end
  return arr1
end
function GuideFlowTools.ParseIdList(idList)
  if idList == "" then
    return nil
  end
  local StringUtil = require("common.string_util")
  local arr1 = StringUtil.Split(idList, "|")
  for k, v in pairs(arr1) do
    arr1[k] = v
  end
  return arr1
end
function GuideFlowTools.ParseNumberList(numList, sep)
  if numList == "" then
    return nil
  end
  local string_util = require("common.string_util")
  local arr1 = string_util.Split(numList, sep)
  for k, v in pairs(arr1) do
    arr1[k] = tonumber(v)
  end
  return arr1
end
function GuideFlowTools.ParseChildNodeExpress(childNodeList)
  if not childNodeList or childNodeList == "" then
    return nil, nil
  end
  local idList, cdMap
  local StringUtil = require("common.string_util")
  local arr1 = StringUtil.Split(childNodeList, "|")
  for k, v in pairs(arr1) do
    local idcd = string.gsub(v, "%(", "")
    idcd = string.gsub(idcd, "%)", "")
    if idList == nil then
      idList = {}
    end
    if string.find(idcd, ":") then
      local arr2 = StringUtil.Split(idcd, ":")
      table.insert(idList, arr2[1])
      if cdMap == nil then
        cdMap = {}
      end
      cdMap[tonumber(arr2[1])] = tonumber(arr2[2])
    else
      table.insert(idList, idcd)
    end
  end
  return idList, cdMap
end
function GuideFlowTools.ParseTimeoutExpress(timeoutList)
  if not timeoutList or timeoutList == "" then
    return nil, nil, nil
  end
  local noTimeoutNodeIdList, timeoutNodeId, timeout
  local StringUtil = require("common.string_util")
  local arr1 = StringUtil.Split(timeoutList, "|")
  if arr1 == nil or #arr1 <= 1 then
    return nil, nil, nil
  end
  noTimeoutNodeIdList = {}
  for i = 1, #arr1 - 1 do
    table.insert(noTimeoutNodeIdList, tonumber(arr1[i]))
  end
  local arr2 = StringUtil.Split(arr1[#arr1], ":")
  if arr2 == nil or #arr2 <= 1 then
    return nil, nil, nil
  end
  timeoutNodeId = tonumber(arr2[1])
  timeout = tonumber(arr2[2])
  return noTimeoutNodeIdList, timeoutNodeId, timeout
end
function GuideFlowTools.ParseAutoDelayFinish(delayAutoFinish)
  if delayAutoFinish == nil or delayAutoFinish == "" then
    return nil, nil
  end
  local arr1 = GuideFlowTools.ParseNumList(delayAutoFinish)
  if arr1 == nil or #arr1 < 2 then
    return nil, nil
  end
  return arr1[1], arr1[2]
end
function GuideFlowTools.FindChildNode(node, childNodeId)
  if node == nil or childNodeId == nil or childNodeId == 0 or node.childList == nil or 0 >= #node.childList then
    return nil
  end
  for k, v in pairs(node.childList) do
    if v.id == childNodeId then
      return v
    end
  end
  return nil
end
function GuideFlowTools.GetOneParent(node)
  if node == nil or node.parentMap == nil then
    return nil
  end
  for k, v in pairs(node.parentMap) do
    return v
  end
  return nil
end
function GuideFlowTools.GetLastFinishParent(node)
  if node == nil or node.parentMap == nil then
    return nil
  end
  local maxFinishedTime = 0
  local lastParentNode
  for k, v in pairs(node.parentMap) do
    if maxFinishedTime < v.finishedTime then
      maxFinishedTime = v.finishedTime
      lastParentNode = v
    end
  end
  return lastParentNode
end
function GuideFlowTools.UTCDayDis(time1, time2)
  return math.floor(time1 / 86400) - math.floor(time2 / 86400)
end
function GuideFlowTools.UTCDayAfter(time, days)
  if days <= 0 then
    return time
  end
  return (math.floor(time / 86400) + 1) * 86400 + 86400 * (days - 1)
end
function GuideFlowTools.MergeList(list1, list2)
  if list1 == nil or list2 == nil then
    return
  end
  local visitMap = {}
  for k, v in pairs(list1) do
    visitMap[v] = true
  end
  for k, v in pairs(list2) do
    if visitMap[v] == nil then
      table.insert(list1, v)
    end
  end
end
return GuideFlowTools