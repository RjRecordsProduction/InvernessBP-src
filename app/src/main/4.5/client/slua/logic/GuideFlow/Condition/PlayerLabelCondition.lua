local PlayerLabelCondition = {
  GuideFlowLog = nil,
  GuideFlowTools = nil,
  PlayerLabelHandler = nil,
  labelConditionMap = {}
}
function PlayerLabelCondition.Check(conditionId, labelList, isAnd)
  if PlayerLabelCondition.GuideFlowLog == nil then
    PlayerLabelCondition.GuideFlowLog = require("client.slua.logic.GuideFlow.GuideFlowLog")
    PlayerLabelCondition.GuideFlowTools = require("client.slua.logic.GuideFlow.GuideFlowTools")
    PlayerLabelCondition.PlayerLabelHandler = require("client.network.Protocol.PlayerLabelHandler")
  end
  local GuideFlowLog = PlayerLabelCondition.GuideFlowLog
  local GuideFlowTools = PlayerLabelCondition.GuideFlowTools
  local PlayerLabelHandler = PlayerLabelCondition.PlayerLabelHandler
  GuideFlowLog.log(GuideFlowLog.bLog and "PlayerLabelCondition.Check labelList = " .. labelList .. ", isAnd = " .. isAnd)
  local labelConditionMap = PlayerLabelCondition.labelConditionMap
  if labelConditionMap[conditionId] ~= nil then
    return labelConditionMap[conditionId]
  end
  local arr = GuideFlowTools.ParseNumList(labelList)
  if arr == nil or #arr <= 0 then
    GuideFlowLog.log(GuideFlowLog.bLog and "PlayerLabelCondition.Check arr len = 0")
    labelConditionMap[conditionId] = false
    return false
  end
  local result = PlayerLabelHandler.labelResult
  if result == nil then
    GuideFlowLog.log(GuideFlowLog.bLog and "PlayerLabelCondition.Check result == nil")
    labelConditionMap[conditionId] = false
    return false
  end
  if tonumber(isAnd) == 1 then
    for k, v in pairs(arr) do
      if result[v] == nil then
        GuideFlowLog.log(GuideFlowLog.bLog and "PlayerLabelCondition.Check must have, but no label = .." .. v)
        labelConditionMap[conditionId] = false
        return false
      end
    end
    GuideFlowLog.log(GuideFlowLog.bLog and "PlayerLabelCondition.Check has all label, return true")
    labelConditionMap[conditionId] = true
    return true
  else
    for k, v in pairs(arr) do
      if result[v] then
        GuideFlowLog.log(GuideFlowLog.bLog and "PlayerLabelCondition.Check must not have, but has label = " .. v)
        labelConditionMap[conditionId] = true
        return true
      end
    end
    GuideFlowLog.log(GuideFlowLog.bLog and "PlayerLabelCondition.Check no any label, return false")
    labelConditionMap[conditionId] = false
    return false
  end
end
return PlayerLabelCondition