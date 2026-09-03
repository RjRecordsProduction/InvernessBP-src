local GuideFlowCondition = {
  conditionFuncMap = {},
  GuideFlowHandler = nil,
  GuideFlowLog = nil,
  conditionLuaFileMap = {}
}
function GuideFlowCondition.Init()
  GuideFlowCondition.conditionFuncMap = {}
  GuideFlowCondition.GuideFlowHandler = require("client.network.Protocol.GuideFlowHandler")
  GuideFlowCondition.GuideFlowLog = require("client.slua.logic.GuideFlow.GuideFlowLog")
  GuideFlowCondition.conditionLuaFileMap = {}
end
function GuideFlowCondition.ComputeValue(nodeId, expression)
  local func = GuideFlowCondition.conditionFuncMap[nodeId]
  if func == nil then
    local exp2 = string.gsub(expression, "%d+", "A(%0)")
    func = load("return " .. exp2, "condition eval", "t", GuideFlowCondition)
    GuideFlowCondition.conditionFuncMap[nodeId] = func
  end
  if func then
    return func()
  else
    return false
  end
end
function GuideFlowCondition.A(ID)
  local GuideFlowHandler = GuideFlowCondition.GuideFlowHandler
  local GuideFlowLog = GuideFlowCondition.GuideFlowLog
  local condCfg
  if GuideFlowHandler.GuideFlowConditionTb then
    condCfg = GuideFlowHandler.GuideFlowConditionTb[ID]
  else
    condCfg = CDataTable.GetTableData("GuideFlowConditionTb", ID)
  end
  if not condCfg then
    GuideFlowLog.log(GuideFlowLog.bLog and "LogicGuideFlowSystem condCfg not exist " .. ID)
    return false
  end
  local condition = GuideFlowCondition.conditionLuaFileMap[ID]
  if condition == nil then
    local luaFile = string.format("client.slua.logic.GuideFlow.Condition.%sCondition", condCfg.condition)
    condition = require(luaFile)
    GuideFlowCondition.conditionLuaFileMap[ID] = condition
  end
  if not condition then
    GuideFlowLog.log(GuideFlowLog.bLog and "LogicGuideFlowSystem condition no luaFile = " .. condCfg.condition)
    return false
  end
  return condition.Check(ID, condCfg.param1, condCfg.param2, condCfg.param3)
end
return GuideFlowCondition