local GuideFlowNodeBlockRule = {
  blockRuleMap = {}
}
function GuideFlowNodeBlockRule.Init()
  GuideFlowNodeBlockRule.blockRuleMap = {}
end
function GuideFlowNodeBlockRule.OnRecvServerData(guide_flow_block_rule)
  GuideFlowNodeBlockRule.blockRuleMap = guide_flow_block_rule or {}
end
function GuideFlowNodeBlockRule.GetBlockRule(nodeId)
  return GuideFlowNodeBlockRule.blockRuleMap[nodeId]
end
function GuideFlowNodeBlockRule.AddRemoveNode(node, timeType, timeLen, nodeIdList)
  local GuideFlowLog = require("client.slua.logic.GuideFlow.GuideFlowLog")
  if node == nil then
    GuideFlowLog.log(GuideFlowLog.bLog and "GuideFlowNodeBlockRule.AddRemoveNode node == nil")
    return
  end
  GuideFlowLog.log(GuideFlowLog.bLog and "GuideFlowNodeBlockRule.AddRemoveNode node.id = " .. node.id .. ", timeType = " .. timeType .. ", timeLen = " .. timeLen)
  local GuideFlowTools = require("client.slua.logic.GuideFlow.GuideFlowTools")
  local blockTb = GuideFlowNodeBlockRule.blockRuleMap[node.id]
  local TimeUtil = require("client.common.time_util")
  local endTime = TimeUtil.GetServerTimeInSec()
  if timeType == 1 then
    endTime = endTime + timeLen
  else
    endTime = GuideFlowTools.UTCDayAfter(endTime, timeLen)
  end
  if blockTb == nil then
    GuideFlowNodeBlockRule.blockRuleMap[node.id] = {}
    blockTb = GuideFlowNodeBlockRule.blockRuleMap[node.id]
    for k, v in pairs(nodeIdList) do
      blockTb[v] = endTime
    end
  else
    for k, v in pairs(nodeIdList) do
      if blockTb[v] then
        if endTime > blockTb[v] then
          blockTb[v] = endTime
        end
      else
        blockTb[v] = endTime
      end
    end
  end
  local GuideFlowHandler = require("client.network.Protocol.GuideFlowHandler")
  GuideFlowHandler.send_set_guide_flow_block_rule_req(node.id, blockTb)
end
function GuideFlowNodeBlockRule.IsInBlockRule(nodeId)
  for k, v in pairs(GuideFlowNodeBlockRule.blockRuleMap) do
    if v[nodeId] then
      return true
    end
  end
  return false
end
function GuideFlowNodeBlockRule.RemoveOutdateRule(blockTb)
  if blockTb == nil then
    return
  end
  local TimeUtil = require("client.common.time_util")
  local tNow = TimeUtil.GetServerTimeInSec()
  local newBlockTb = {}
  for k, v in pairs(blockTb) do
    if v > tNow then
      newBlockTb[k] = v
    end
  end
  return newBlockTb
end
function GuideFlowNodeBlockRule.RemoveAllOutdateRule()
  for k, v in pairs(GuideFlowNodeBlockRule.blockRuleMap) do
    GuideFlowNodeBlockRule.blockRuleMap[k] = GuideFlowNodeBlockRule.RemoveOutdateRule(v)
  end
end
return GuideFlowNodeBlockRule