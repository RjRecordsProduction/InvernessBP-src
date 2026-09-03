local GuideFlowTreeMap = {}
function GuideFlowTreeMap.Init(treeMap, eventMap)
  GuideFlowTreeMap.  GuideFlowTreeMap.end
function GuideFlowTreeMap._SpaceLen(len)
  local str = ""
  for i = 1, len do
    str = str .. "--"
  end
  return str
end
function GuideFlowTreeMap._PrintNode(node, level, visitMap)
  local lineSpace = GuideFlowTreeMap._SpaceLen(level)
  local lineSpace1 = lineSpace .. "--"
  local GuideFlowLog = require("client.slua.logic.GuideFlow.GuideFlowLog")
  if visitMap[node] then
    GuideFlowLog.log(GuideFlowLog.bLog and lineSpace .. "(loop point to node.id = " .. node.id .. ")")
    return
  end
  visitMap[node] = true
  local nameList = {
    "id",
    "cfgEventList",
    "finishedTime"
  }
  for k, v in pairs(nameList) do
    GuideFlowLog.log(GuideFlowLog.bLog and lineSpace .. v .. ":" .. node[v])
  end
  GuideFlowLog.log(GuideFlowLog.bLog and lineSpace .. "childList")
  if node.childList and #node.childList > 0 then
    for i = 1, #node.childList do
      GuideFlowLog.log(GuideFlowLog.bLog and lineSpace1 .. i)
      GuideFlowTreeMap._PrintNode(node.childList[i], level + 2, visitMap)
    end
  else
    GuideFlowLog.log(GuideFlowLog.bLog and lineSpace1 .. "0")
  end
end
function GuideFlowTreeMap._PrintEventNode(node, level)
  local lineSpace = GuideFlowTreeMap._SpaceLen(level)
  local GuideFlowLog = require("client.slua.logic.GuideFlow.GuideFlowLog")
  GuideFlowLog.log(GuideFlowLog.bLog and lineSpace .. "id:" .. node.id)
end
function GuideFlowTreeMap.PrintTree()
  local treeMap = GuideFlowTreeMap.treeMap
  local GuideFlowLog = require("client.slua.logic.GuideFlow.GuideFlowLog")
  GuideFlowLog.log(GuideFlowLog.bLog and "treeMap = ")
  for k, v in pairs(treeMap) do
    GuideFlowLog.log(GuideFlowLog.bLog and "--treeNo:" .. k)
    GuideFlowLog.log(GuideFlowLog.bLog and "----rootNode")
    local visitMap = {}
    GuideFlowTreeMap._PrintNode(v.rootNode, 3, visitMap)
  end
end
function GuideFlowTreeMap.PrintEventMap()
  local eventMap = GuideFlowTreeMap.eventMap
  local GuideFlowLog = require("client.slua.logic.GuideFlow.GuideFlowLog")
  GuideFlowLog.log(GuideFlowLog.bLog and "eventMap = ")
  for k, v in pairs(eventMap) do
    GuideFlowLog.log(GuideFlowLog.bLog and "--eventId:" .. k)
    GuideFlowLog.log(GuideFlowLog.bLog and "--nodeList " .. #v)
    for kk, vv in pairs(v) do
      GuideFlowTreeMap._PrintEventNode(vv, 3)
    end
  end
end
return GuideFlowTreeMap