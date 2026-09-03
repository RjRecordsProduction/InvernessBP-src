local LogicGuideFlowSystem = {
  treeAttrMap = {},
  treeMap = {},
  resAllTree = {},
  updateTimer = nil,
  bDoingAction = false
}
local GuideFlowEventMap
local GuideFlowLog = require("client.slua.logic.GuideFlow.GuideFlowLog")
function LogicGuideFlowSystem.Init()
  log(bWriteLog and "LogicGuideFlowSystem.Init")
  GuideFlowEventMap = require("client.slua.logic.GuideFlow.Event.GuideFlowEventMap")
  if _G.IsEditor or Client.IsShipping() then
    GuideFlowLog.bLog = false
  else
    GuideFlowLog.bLog = true
  end
  local GuideFlowNodeCounter = require("client.slua.logic.GuideFlow.GuideFlowNodeCounter")
  GuideFlowNodeCounter.Init()
end
function LogicGuideFlowSystem.OnLogin(bReLogin)
  log(bWriteLog and "LogicGuideFlowSystem.OnLogin bReLogin = " .. tostring(bReLogin))
  local FightRecordHandler = require("client.network.Protocol.FightRecordHandler")
  local PlayerLabelHandler = require("client.network.Protocol.PlayerLabelHandler")
  local GuideFlowHandler = require("client.network.Protocol.GuideFlowHandler")
  local GuideFlowCondition = require("client.slua.logic.GuideFlow.GuideFlowCondition")
  GuideFlowCondition.Init()
  GuideFlowHandler.bGetRspAllTree = false
  GuideFlowHandler.bGetRspCfg = false
  GuideFlowHandler.bGetRspBlockRule = false
  PlayerLabelHandler.send_get_growup_mark_label_req()
  FightRecordHandler.send_get_classical_record_req()
  if bReLogin == false then
    local logic_guide_flow_config = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_guide_flow_config)
    logic_guide_flow_config:send_get_guide_flow_cfg_req()
  end
  GuideFlowHandler.send_get_node_count_req()
end
function LogicGuideFlowSystem.IsOpen()
  return LobbySystem.CheckOpen(10232)
end
function LogicGuideFlowSystem.OnRecvAllTree(resAllTree)
  if not LogicGuideFlowSystem.IsOpen() then
    GuideFlowLog.log(GuideFlowLog.bLog and "LogicGuideFlowSystem.OnRecvAllTree not open")
    return
  end
  LogicGuideFlowSystem.  LogicGuideFlowSystem.LoadAllTreeAttr()
  LogicGuideFlowSystem.LoadAllTree()
  LogicGuideFlowSystem.StartTimer()
end
function LogicGuideFlowSystem.LoadAllTreeAttr()
  local TimeUtil = require("client.common.time_util")
  local GuideFlowTools = require("client.slua.logic.GuideFlow.GuideFlowTools")
  local GuideFlowHandler = require("client.network.Protocol.GuideFlowHandler")
  local treeAttrMap = {}
  local tb
  local bUseCfg = false
  if GuideFlowHandler.GuideFlowTreeAttrTb then
    tb = GuideFlowHandler.GuideFlowTreeAttrTb
    bUseCfg = false
  else
    tb = CDataTable.GetTable("GuideFlowTreeAttrTb")
    bUseCfg = true
  end
  local tNow = TimeUtil.GetServerTimeInSec()
  for k, v in pairs(tb) do
    local info = {
      startTime = TimeUtil.TimeStringToUnixstamp(v.startTime, true),
      endTime = TimeUtil.TimeStringToUnixstamp(v.endTime, true),
      treeMutexList = GuideFlowTools.ParseNumList(v.treeMutexList),
      priority = v.priority
    }
    info.inValidTime = tNow >= info.startTime and tNow <= info.endTime
    if bUseCfg then
      treeAttrMap[v.treeNo] = info
    else
      treeAttrMap[k] = info
    end
  end
  LogicGuideFlowSystem.end
function LogicGuideFlowSystem.LoadAllTree()
  LogicGuideFlowSystem.treeMap = {}
  GuideFlowEventMap.eventMap = {}
  local GuideFlowTreeMap = require("client.slua.logic.GuideFlow.GuideFlowTreeMap")
  GuideFlowTreeMap.Init(LogicGuideFlowSystem.treeMap, GuideFlowEventMap.eventMap)
  local treeTb
  local bUseCfg = false
  local GuideFlowHandler = require("client.network.Protocol.GuideFlowHandler")
  if GuideFlowHandler.GuideFlowTreeTb then
    treeTb = GuideFlowHandler.GuideFlowTreeTb
    bUseCfg = false
  else
    treeTb = CDataTable.GetTable("GuideFlowTreeTb")
    bUseCfg = true
  end
  for k, v in pairs(treeTb) do
    if v.isRoot and v.isRoot == 1 and LogicGuideFlowSystem.treeAttrMap[v.treeNo] and LogicGuideFlowSystem.treeAttrMap[v.treeNo].inValidTime then
      local tree = {
        rootNode = {},
        ActiveList = {},
        HaveActivedList = {}
      }
      LogicGuideFlowSystem.treeMap[v.treeNo] = tree
      local rootNode = tree.rootNode
      local visitedNodeMap = {}
      if bUseCfg then
        rootNode.id = v.ID
        visitedNodeMap[v.ID] = rootNode
      else
        rootNode.id = k
        visitedNodeMap[k] = rootNode
      end
      rootNode.finishedTime = 0
      local bActiveChild = false
      local resTree = LogicGuideFlowSystem.resAllTree[v.treeNo]
      if resTree and resTree.activited and resTree.activited[rootNode.id] and (resTree.blocked == nil or resTree.blocked[rootNode.id] == nil) then
        tree.HaveActivedList[rootNode.id] = rootNode
        rootNode.finishedTime = resTree.activited[rootNode.id].time
        bActiveChild = true
      end
      rootNode.parentFinishedTime = 0
      LogicGuideFlowSystem.FillNodeFromCfg(rootNode, v, visitedNodeMap, bActiveChild, nil)
      if resTree == nil then
        local bAdd = GuideFlowEventMap.AddEvent(rootNode)
        if bAdd then
          table.insert(tree.ActiveList, rootNode)
        end
      end
    end
  end
  GuideFlowTreeMap.PrintTree()
  GuideFlowTreeMap.PrintEventMap()
end
function LogicGuideFlowSystem.InValidTime(treeNo)
  local info = LogicGuideFlowSystem.treeAttrMap[treeNo]
  if info == nil then
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local tNow = TimeUtil.GetServerTimeInSec()
  if tNow >= info.startTime and tNow <= info.endTime then
    return true
  else
    return false
  end
end
function LogicGuideFlowSystem.FillNodeFromCfg(node, cfg, visitedNodeMap, bAddChildActive, parent)
  local GuideFlowTools = require("client.slua.logic.GuideFlow.GuideFlowTools")
  if parent then
    node.treeNo = parent.treeNo
  else
    node.treeNo = cfg.treeNo
  end
  node.cfgEventList = cfg.eventList
  node.eventList = GuideFlowTools.ParseNumList(cfg.eventList)
  node.nodeMutexList = GuideFlowTools.ParseNumList(cfg.nodeMutex)
  node.nodePriority = cfg.nodePriority or 0
  node.condexp = cfg.conditionList
  node.actionID = tonumber(cfg.action)
  node.TickInBattle = cfg.TickInBattle
  node.status = 0
  node.noTimeoutNodeIdList, node.timeoutNodeId, node.timeout = GuideFlowTools.ParseTimeoutExpress(cfg.timeoutList)
  node.delayAutoFinishType, node.delayAutoFinishTime = GuideFlowTools.ParseAutoDelayFinish(cfg.delayAutoFinish)
  if parent then
    node.parentMap = {}
    node.parentMap[parent.id] = parent
  end
  LogicGuideFlowSystem.GetChildList(cfg.childNodeList, visitedNodeMap, bAddChildActive, node)
  LogicGuideFlowSystem.ParentParamToChild(node, cfg)
end
function LogicGuideFlowSystem.ParentParamToChild(node, cfg)
  if node == nil or node.childList == nil or #node.childList <= 0 then
    return
  end
  local GuideFlowTools = require("client.slua.logic.GuideFlow.GuideFlowTools")
  local afterDayList = GuideFlowTools.ParseNumList(cfg.afterDay)
  if afterDayList then
    for i = 1, #node.childList do
      local child = node.childList[i]
      child.afterDay = afterDayList[i]
    end
  end
  if node.cdMap then
    for k, v in pairs(node.cdMap) do
      for i = 1, #node.childList do
        local child = node.childList[i]
        if child.id == k then
          child.cd = v
          break
        end
      end
    end
  end
  if node.timeoutNodeId then
    for i = 1, #node.childList do
      local child = node.childList[i]
      if child.id == node.timeoutNodeId then
        child.bTimeoutNode = true
        break
      end
    end
  end
  LogicGuideFlowSystem.PushFinishTimeToChild(node)
end
function LogicGuideFlowSystem.GetChildList(childNodeList, visitedNodeMap, bActiveChild, parent)
  local GuideFlowTools = require("client.slua.logic.GuideFlow.GuideFlowTools")
  local idList, cdMap = GuideFlowTools.ParseChildNodeExpress(childNodeList)
  if idList == nil then
    return
  end
  parent.childIdList = idList
  parent.  local GuideFlowHandler = require("client.network.Protocol.GuideFlowHandler")
  for k, v in pairs(idList) do
    local id = tonumber(v)
    local cfg
    if GuideFlowHandler.GuideFlowTreeTb then
      cfg = GuideFlowHandler.GuideFlowTreeTb[id]
    else
      cfg = CDataTable.GetTableData("GuideFlowTreeTb", id)
    end
    if not cfg then
      break
    end
    if parent.childList == nil then
      parent.childList = {}
    end
    if visitedNodeMap[id] then
      local thisNode = visitedNodeMap[id]
      table.insert(parent.childList, thisNode)
      if thisNode.parentMap == nil then
        thisNode.parentMap = {}
      end
      thisNode.parentMap[parent.id] = parent
      local isOld = LogicGuideFlowSystem.CheckParentNewer2(thisNode.id, parent.id, parent.treeNo)
      if bActiveChild and isOld and GuideFlowEventMap.NotInDelayConditionBlock(thisNode) then
        local bAdd = GuideFlowEventMap.AddEvent(thisNode)
        if bAdd then
          table.insert(LogicGuideFlowSystem.treeMap[thisNode.treeNo].ActiveList, thisNode)
        end
      end
      LogicGuideFlowSystem.ParentParamToChild(thisNode, cfg)
    else
      local treeNode = {}
      visitedNodeMap[id] = treeNode
      treeNode.      treeNode.finishedTime = 0
      local nextChildActived = false
      local resTree = LogicGuideFlowSystem.resAllTree[parent.treeNo]
      if resTree and resTree.activited and resTree.activited[id] then
        LogicGuideFlowSystem.treeMap[parent.treeNo].HaveActivedList[id] = treeNode
        treeNode.finishedTime = resTree.activited[id].time
        nextChildActived = true
      end
      treeNode.parentFinishedTime = 0
      LogicGuideFlowSystem.FillNodeFromCfg(treeNode, cfg, visitedNodeMap, nextChildActived, parent)
      if bActiveChild and GuideFlowEventMap.NotInDelayConditionBlock(treeNode) then
        local resTree2 = LogicGuideFlowSystem.resAllTree[parent.treeNo]
        if resTree2 and resTree2.activited and resTree2.activited[treeNode.id] then
          if LogicGuideFlowSystem.CheckParentNewer(idList, parent.id, parent.treeNo) then
            local bAdd = GuideFlowEventMap.AddEvent(treeNode)
            if bAdd then
              table.insert(LogicGuideFlowSystem.treeMap[treeNode.treeNo].ActiveList, treeNode)
            end
          end
        else
          local bAdd = GuideFlowEventMap.AddEvent(treeNode)
          if bAdd then
            table.insert(LogicGuideFlowSystem.treeMap[treeNode.treeNo].ActiveList, treeNode)
          end
        end
      end
      table.insert(parent.childList, treeNode)
    end
  end
end
function LogicGuideFlowSystem.CheckParentNewer(childIdList, parentId, treeNo)
  local resTree = LogicGuideFlowSystem.resAllTree[treeNo]
  if resTree == nil or resTree.activited == nil or resTree.activited[parentId] == nil then
    return false
  end
  local parentFinishTime = resTree.activited[parentId].time
  for k, v in pairs(childIdList) do
    local id = tonumber(v)
    if resTree.activited[id] then
      local childFinishTime = resTree.activited and resTree.activited[id].time or 0
      if parentFinishTime > childFinishTime then
        return true
      end
    end
  end
  return false
end
function LogicGuideFlowSystem.CheckParentNewer2(id, parentId, treeNo)
  local resTree = LogicGuideFlowSystem.resAllTree[treeNo]
  if resTree == nil or resTree.activited == nil or resTree.activited[id] == nil then
    return true
  end
  if resTree == nil or resTree.activited == nil or resTree.activited[parentId] == nil then
    return true
  end
  local thisFinishTime = resTree.activited[id].time
  local parentFinishTime = resTree.activited[parentId].time
  if thisFinishTime <= parentFinishTime then
    return true
  end
  return false
end
function LogicGuideFlowSystem.ProcBlockedByConditionNodeMap(blockedByConditionNodeMap, changedTreeIDTable)
  local TimeUtil = require("client.common.time_util")
  local tNow = TimeUtil.GetServerTimeInSec()
  for k, nodeList in pairs(blockedByConditionNodeMap) do
    local resTree = LogicGuideFlowSystem.resAllTree[k]
    if resTree == nil then
      LogicGuideFlowSystem.resAllTree[k] = {}
      resTree = LogicGuideFlowSystem.resAllTree[k]
    end
    if resTree.blocked == nil then
      resTree.blocked = {}
    end
    for kk, node in pairs(nodeList) do
      GuideFlowEventMap.RemoveNodeEvent(node)
      resTree.blocked[node.id] = tNow
    end
    changedTreeIDTable[k] = 1
  end
end
function LogicGuideFlowSystem.DoActionNodeMap(doActionNodeMap, changedTreeIDTable, eventName, param1, param2, param3)
  doActionNodeMap = LogicGuideFlowSystem.ProcTreeMutexAndPro(doActionNodeMap)
  doActionNodeMap = LogicGuideFlowSystem.ProcNodeMutexAndPro(doActionNodeMap)
  local TimeUtil = require("client.common.time_util")
  local tNow = TimeUtil.GetServerTimeInSec()
  for k, nodeList in pairs(doActionNodeMap) do
    for kk, node in pairs(nodeList) do
      node.status = 2
      node.finishedTime = tNow
      LogicGuideFlowSystem.MoveToNextActiveNode(node)
      node.status = 3
      changedTreeIDTable[node.treeNo] = 1
    end
  end
  LogicGuideFlowSystem.bDoingAction = true
  for k, nodeList in pairs(doActionNodeMap) do
    for kk, node in pairs(nodeList) do
      LogicGuideFlowSystem.DoAction(node, eventName, param1, param2, param3)
    end
  end
  LogicGuideFlowSystem.bDoingAction = false
  LogicGuideFlowSystem.SendChangedTree(changedTreeIDTable)
end
function LogicGuideFlowSystem.ProcTreeMutexAndPro(doActionNodeMap)
  local treeList = {}
  for k, v in pairs(doActionNodeMap) do
    table.insert(treeList, v)
  end
  table.sort(treeList, function(a, b)
    local info1 = LogicGuideFlowSystem.treeAttrMap[a[1].treeNo]
    local info2 = LogicGuideFlowSystem.treeAttrMap[b[1].treeNo]
    return info1.priority > info2.priority
  end)
  for k, v in pairs(treeList) do
    if 0 < #v then
      local info = LogicGuideFlowSystem.treeAttrMap[v[1].treeNo]
      local treeMutexList = info.treeMutexList
      if treeMutexList then
        for kk, vv in pairs(treeMutexList) do
          for kkk, vvv in pairs(treeList) do
            if 0 < #vvv and vv == vvv[1].treeNo then
              treeList[kkk] = {}
            end
          end
        end
      end
    end
  end
  local filterMap = {}
  for k, v in pairs(treeList) do
    if 0 < #v then
      filterMap[k] = v
    end
  end
  return filterMap
end
function LogicGuideFlowSystem.ProcNodeMutexAndPro(doActionNodeMap)
  local nodeList = {}
  for k, v in pairs(doActionNodeMap) do
    for kk, vv in pairs(v) do
      table.insert(nodeList, vv)
    end
  end
  table.sort(nodeList, function(a, b)
    return (a.nodePriority or 0) > (b.nodePriority or 0)
  end)
  local toRemoveNodeList = {}
  for _, node in pairs(nodeList) do
    local nodeMutexList = node.nodeMutexList
    if nodeMutexList then
      for _, nodeMutexID in pairs(nodeMutexList) do
        for k, v in pairs(nodeList) do
          if v.id == nodeMutexID then
            table.insert(toRemoveNodeList, nodeMutexID)
            nodeList[k] = {}
          end
        end
      end
    end
  end
  for _, toRemoveNodeID in pairs(toRemoveNodeList) do
    for treeIdx, treeNodeList in pairs(doActionNodeMap) do
      for treeNodeIdx, treeNode in pairs(treeNodeList) do
        if toRemoveNodeID == treeNode.id then
          doActionNodeMap[treeIdx][treeNodeIdx] = {}
        end
      end
    end
  end
  local filterMap = {}
  for k, v in pairs(doActionNodeMap) do
    if 0 < #v then
      local curNodeList = {}
      for kk, vv in pairs(v) do
        if next(vv) then
          table.insert(curNodeList, vv)
        end
      end
      filterMap[k] = curNodeList
    end
  end
  return filterMap
end
function LogicGuideFlowSystem.SendChangedTree(changedTreeIDTable)
  for treeNo, _ in pairs(changedTreeIDTable) do
    local sendData = {
      activited = {},
      blocked = {}
    }
    local tree = LogicGuideFlowSystem.treeMap[treeNo]
    if tree and tree.HaveActivedList then
      for k, node in pairs(tree.HaveActivedList) do
        sendData.activited[k] = {
          status = 1,
          time = node.finishedTime
        }
      end
      if LogicGuideFlowSystem.resAllTree[treeNo] then
        sendData.blocked = LogicGuideFlowSystem.resAllTree[treeNo].blocked
      end
      local GuideFlowHandler = require("client.network.Protocol.GuideFlowHandler")
      GuideFlowHandler.send_guide_flow_change_tree_req(treeNo, sendData)
    end
  end
end
function LogicGuideFlowSystem.CheckCondition(node)
  GuideFlowLog.log(GuideFlowLog.bLog and "LogicGuideFlowSystem.CheckCondition node.id = " .. node.id)
  if LogicGuideFlowSystem.InValidTime(node.treeNo) == false then
    GuideFlowLog.log(GuideFlowLog.bLog and "LogicGuideFlowSystem.CheckCondition InValidTime")
    return false
  end
  if node.afterDay and node.afterDay > 0 then
    local TimeUtil = require("client.common.time_util")
    local tNow = TimeUtil.GetServerTimeInSec()
    local day1 = math.floor(tNow / 86400)
    local day2 = math.floor(node.parentFinishedTime / 86400)
    if day1 - day2 < node.afterDay then
      return false
    end
  end
  if node.cd and 0 < node.cd then
    local TimeUtil = require("client.common.time_util")
    local tNow = TimeUtil.GetServerTimeInSec()
    if tNow - node.parentFinishedTime < node.cd then
      return false
    end
  end
  if not node.condexp or node.condexp == "" then
    return true
  end
  local GuideFlowCondition = require("client.slua.logic.GuideFlow.GuideFlowCondition")
  local val = GuideFlowCondition.ComputeValue(node.id, node.condexp)
  GuideFlowLog.log(GuideFlowLog.bLog and "LogicGuideFlowSystem.CheckCondition val = " .. tostring(val) .. ", node.id = " .. node.id)
  return val
end
function LogicGuideFlowSystem.DoAction(node, eventName, param1, param2, param3)
  GuideFlowLog.log(GuideFlowLog.bLog and "LogicGuideFlowSystem.DoAction node.id = " .. node.id)
  local GuideFlowHandler = require("client.network.Protocol.GuideFlowHandler")
  local actionCfg
  if GuideFlowHandler.GuideFlowActionTb then
    actionCfg = GuideFlowHandler.GuideFlowActionTb[node.actionID]
  else
    actionCfg = CDataTable.GetTableData("GuideFlowActionTb", node.actionID)
  end
  if not actionCfg then
    return
  end
  local luaFile = string.format("client.slua.logic.GuideFlow.Action.%sAction", actionCfg.action)
  local action = require(luaFile)
  if not action then
    return
  end
  local GuideFlowNodeCounter = require("client.slua.logic.GuideFlow.GuideFlowNodeCounter")
  GuideFlowNodeCounter.AccumulateNodeCounter(node.id)
  action.Run(node, actionCfg.param1, actionCfg.param2, actionCfg.param3)
  if LobbySystem.CheckOpen(BP_ENUM_GUILD_FLOW_TLOG_MASTER_SWITCH) then
    local bTLog = true
    if LobbySystem.CheckOpen(BP_ENUM_GUILD_FLOW_TLOG_BY_CONFIG_SWITCH) then
      local cfgNode
      if GuideFlowHandler.GuideFlowTreeTb then
        cfgNode = GuideFlowHandler.GuideFlowTreeTb[node.id]
      else
        cfgNode = CDataTable.GetTableData("GuideFlowTreeTb", node.id)
      end
      if cfgNode and cfgNode.isReportTlog and cfgNode.isReportTlog == 1 then
        bTLog = true
      else
        bTLog = false
      end
    end
    if bTLog then
      local GuideFlowTlog = require("client.slua.logic.GuideFlow.GuideFlowTlog")
      GuideFlowTlog.SendTLog(node, eventName, param1, param2, param3)
    end
  end
end
function LogicGuideFlowSystem.MoveToNextActiveNode(node)
  GuideFlowEventMap.RemoveNodeEvent(node)
  LogicGuideFlowSystem.treeMap[node.treeNo].HaveActivedList[node.id] = node
  if node.childList then
    for _, childNode in pairs(node.childList) do
      GuideFlowEventMap.ClearDelayConditionBlock(childNode)
      local bAdd = GuideFlowEventMap.AddEvent(childNode)
      if bAdd then
        table.insert(LogicGuideFlowSystem.treeMap[childNode.treeNo].ActiveList, childNode)
      end
    end
  end
  GuideFlowLog.log(GuideFlowLog.bLog and "LogicGuideFlowSystem.MoveToNextActiveNode after move node id = " .. node.id)
  local GuideFlowTreeMap = require("client.slua.logic.GuideFlow.GuideFlowTreeMap")
  GuideFlowTreeMap.PrintEventMap()
  LogicGuideFlowSystem.PushFinishTimeToChild(node)
end
function LogicGuideFlowSystem.PushFinishTimeToChild(node)
  if node == nil or node.childList == nil then
    return
  end
  for i = 1, #node.childList do
    local child = node.childList[i]
    if node.finishedTime > child.parentFinishedTime then
      child.parentFinishedTime = node.finishedTime
    end
  end
end
function LogicGuideFlowSystem.StartTimer()
  GuideFlowLog.log(GuideFlowLog.bLog and "LogicGuideFlowSystem.StartTimer")
  local time_ticker = require("common.time_ticker")
  if LogicGuideFlowSystem.updateTimer then
    time_ticker.RemoveTimer(LogicGuideFlowSystem.updateTimer)
    LogicGuideFlowSystem.updateTimer = nil
  end
  LogicGuideFlowSystem.updateTimer = time_ticker.AddTimerLoop(1, function()
    LogicGuideFlowSystem.UpdateByTimer()
  end, TIMER_INFINITE, 1)
end
function LogicGuideFlowSystem.UpdateByTimer()
  local bInFighting = not GameStatus.IsInLobbyOrMainCity() and NetUtil.BBattleResultRecieved == false
  if bInFighting then
    return
  end
  GuideFlowEventMap.UpdateTimeoutNode(bInFighting)
  GuideFlowEventMap.UpdateDelayAutoFinish(bInFighting)
end
return LogicGuideFlowSystem