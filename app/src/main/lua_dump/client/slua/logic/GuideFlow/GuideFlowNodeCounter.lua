local GuideFlowNodeCounter = {
  updateTimer = nil,
  nodeCounter = {},
  nodeIdMapCache = nil
}
local GuideFlowHandler = require("client.network.Protocol.GuideFlowHandler")
function GuideFlowNodeCounter.Init()
  local GuideFlowLog = require("client.slua.logic.GuideFlow.GuideFlowLog")
  GuideFlowLog.log(GuideFlowLog.bLog and "GuideFlowNodeCounter.Init")
  local time_ticker = require("common.time_ticker")
  GuideFlowNodeCounter.nodeCounter = {}
  if GuideFlowNodeCounter.updateTimer then
    time_ticker.RemoveTimer(GuideFlowNodeCounter.updateTimer)
    GuideFlowNodeCounter.updateTimer = nil
  end
  GuideFlowNodeCounter.updateTimer = time_ticker.AddTimerLoop(60, function()
    GuideFlowNodeCounter.UpdateByTimer()
  end, TIMER_INFINITE, 60)
end
function GuideFlowNodeCounter.UpdateByTimer()
  local bInFighting = not GameStatus.IsInLobbyOrMainCity() and NetUtil.BBattleResultRecieved == false
  if bInFighting then
    return
  end
  GuideFlowNodeCounter.SendCacheAndClear()
end
function GuideFlowNodeCounter.UpdateNodeCounter(updateNodeCounter)
  for nodeID, dayList in pairs(updateNodeCounter) do
    if GuideFlowNodeCounter.nodeCounter[nodeID] == nil then
      GuideFlowNodeCounter.nodeCounter[nodeID] = {}
    end
    for pastDay, counterData in pairs(dayList) do
      if GuideFlowNodeCounter.nodeCounter[nodeID][pastDay] == nil then
        GuideFlowNodeCounter.nodeCounter[nodeID][pastDay] = {}
      end
      GuideFlowNodeCounter.nodeCounter[nodeID][pastDay] = counterData.count
    end
  end
end
function GuideFlowNodeCounter.AccumulateNodeCounter(nodeId)
  if GuideFlowNodeCounter.nodeIdMapCache == nil then
    GuideFlowNodeCounter.nodeIdMapCache = {}
  end
  if GuideFlowNodeCounter.nodeIdMapCache[nodeId] == nil then
    GuideFlowNodeCounter.nodeIdMapCache[nodeId] = 1
  else
    GuideFlowNodeCounter.nodeIdMapCache[nodeId] = GuideFlowNodeCounter.nodeIdMapCache[nodeId] + 1
  end
  if GuideFlowNodeCounter.nodeCounter[nodeId] == nil then
    local info = {}
    local i = 0
    for i = 1, 7 do
      info[i] = 0
    end
    GuideFlowNodeCounter.nodeCounter[nodeId] = info
  end
  local today = 1
  if GuideFlowNodeCounter.nodeCounter[nodeId][today] == nil then
    GuideFlowNodeCounter.nodeCounter[nodeId][today] = 1
  else
    GuideFlowNodeCounter.nodeCounter[nodeId][today] = GuideFlowNodeCounter.nodeCounter[nodeId][today] + 1
  end
end
function GuideFlowNodeCounter.SendCacheAndClear()
  if GuideFlowNodeCounter.nodeIdMapCache == nil then
    return
  end
  GuideFlowHandler.send_update_node_count_req(GuideFlowNodeCounter.nodeIdMapCache)
  GuideFlowNodeCounter.nodeIdMapCache = nil
end
return GuideFlowNodeCounter