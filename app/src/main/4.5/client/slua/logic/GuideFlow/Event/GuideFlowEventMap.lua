local GuideFlowEventMap = {
  eventMap = {}
}
local local local local utility = require("common.utility")
local xpcallHandle = utility.ErrorMessageHandler
local GuideFlowTools = require("client.slua.logic.GuideFlow.GuideFlowTools")
local GuideFlowLog = require("client.slua.logic.GuideFlow.GuideFlowLog")
local TimeUtil = require("client.common.time_util")
local logic_guide_flow = require("client.slua.logic.GuideFlow.logic_guide_flow")
function GuideFlowEventMap.Init()
  GuideFlowLog.log(GuideFlowLog.bLog and "GuideFlowEventMap.Init")
  EventSystem:registEvent(EVENTTYPE_LOBBY, EVENTID_LOADING_FINISH, GuideFlowEventMap.OnLoadingFinish)
  EventSystem:registEvent(EVENTID_UI, BP_ENUM_UI_SHOW, GuideFlowEventMap.OnUIShow)
  EventSystem:registEvent(EVENTTYPE_OLD_WIDGET, EVENTID_ON_ALL_WIDGET_HIDE, GuideFlowEventMap.OnUIHide)
  EventSystem:registEvent(EVENTTYPE_UGC, EVENTID_UGC_OPENDED_UI_GUIDE, GuideFlowEventMap.OnUGCOpendedUI)
end
function GuideFlowEventMap.AddNodeEvent(eventid, node)
  GuideFlowLog.log(GuideFlowLog.bLog and "GuideFlowEventMap.AddNodeEvent eventid = " .. eventid .. ", node.id = " .. node.id)
  if GuideFlowEventMap.eventMap[eventid] == nil then
    GuideFlowEventMap.eventMap[eventid] = {}
  end
  local bFind = false
  local nodeList = GuideFlowEventMap.eventMap[eventid]
  for k, v in pairs(nodeList) do
    if v == node then
      bFind = true
      break
    end
  end
  if not bFind then
    table.insert(nodeList, node)
  end
end
function GuideFlowEventMap.AddEvent(node)
  GuideFlowLog.log(GuideFlowLog.bLog and "GuideFlowEventMap.AddEvent node.id = " .. node.id)
  if node.eventList == nil then
    return false
  end
  local GuideFlowNodeBlockRule = require("client.slua.logic.GuideFlow.GuideFlowNodeBlockRule")
  GuideFlowNodeBlockRule.RemoveAllOutdateRule()
  if GuideFlowNodeBlockRule.IsInBlockRule(node.id) then
    GuideFlowLog.log(GuideFlowLog.bLog and "GuideFlowEventMap.AddEvent IsInBlockRule node.id = " .. node.id)
    return false
  end
  node.status = 1
  for k, v in pairs(node.eventList) do
    GuideFlowEventMap.AddNodeEvent(v, node)
  end
  return true
end
function GuideFlowEventMap.RemoveNodeEvent(node)
  GuideFlowLog.log(GuideFlowLog.bLog and "GuideFlowEventMap.RemoveNodeEvent node.id = " .. node.id)
  if node.eventList == nil then
    return
  end
  for k, eventid in pairs(node.eventList) do
    local nodeList = GuideFlowEventMap.eventMap[eventid]
    if nodeList then
      for index, v in pairs(nodeList) do
        if v == node then
          table.remove(nodeList, index)
          if #nodeList <= 0 then
            GuideFlowEventMap.eventMap[eventid] = nil
          end
          break
        end
      end
    end
  end
end
function GuideFlowEventMap.PostEvent(eventName, param1, param2, param3)
  GuideFlowLog.log(GuideFlowLog.bLog and "GuideFlowEventMap.PostEvent eventName = " .. eventName)
  xpcall(function()
    if not logic_guide_flow.IsOpen() then
      GuideFlowLog.log(GuideFlowLog.bLog and "GuideFlowEventMap.PostEvent not open")
      return
    end
    if logic_guide_flow.bDoingAction then
      GuideFlowLog.log(GuideFlowLog.bLog and "GuideFlowEventMap.PostEvent recursive post event return")
      return
    end
    local eventid = GuideFlowEventMap.EventParamToId(eventName, param1, param2, param3)
    if eventid <= 0 then
      GuideFlowLog.log(GuideFlowLog.bLog and "GuideFlowEventMap.PostEvent eventid <= 0")
      return
    end
    GuideFlowLog.log(GuideFlowLog.bLog and "GuideFlowEventMap.PostEvent eventid = " .. eventid)
    local nodeList = GuideFlowEventMap.eventMap[eventid]
    local doActionNodeMap = {}
    local bSatisfy = false
    local nodeIdMap = {}
    if nodeList then
      for k, node in pairs(nodeList) do
        if not nodeIdMap[node.id] then
          nodeIdMap[node.id] = true
          if logic_guide_flow.CheckCondition(node) then
            if doActionNodeMap[node.treeNo] == nil then
              doActionNodeMap[node.treeNo] = {}
            end
            table.insert(doActionNodeMap[node.treeNo], node)
            bSatisfy = true
          end
        end
      end
    end
    if bSatisfy == false then
      return
    end
    local changedTreeIDTable = {}
    logic_guide_flow.DoActionNodeMap(doActionNodeMap, changedTreeIDTable, eventName, param1, param2, param3)
  end, xpcallHandle)
end
function GuideFlowEventMap.EventParamToId(eventName, param1, param2, param3)
  local GuideFlowEvent = require("client.slua.logic.GuideFlow.Event.GuideFlowEvent")
  if eventName == GuideFlowEvent.LoginToLobby then
    return 1
  elseif eventName == GuideFlowEvent.FightToLobby then
    return 2
  elseif eventName == GuideFlowEvent.OpenUI then
    if param1 == "AnyUI" then
      return 3
    elseif param1 == "teamup_side_bar" then
      return 501
    elseif param1 == "TeamPlatform_UIBP" then
      return 502
    elseif param1 == "mentor_mentee_change" then
      return 503
    end
  elseif eventName == GuideFlowEvent.ClickDepotnGuide then
    return 102
  elseif eventName == GuideFlowEvent.ClickXmissionGuide then
    return 103
  elseif eventName == GuideFlowEvent.ClickRPGuide then
    return 104
  elseif eventName == GuideFlowEvent.CloseUI then
    if param1 == "new_player_gifts_panel" then
      return 101
    end
  elseif eventName == GuideFlowEvent.EnterGame then
    return 5
  elseif eventName == GuideFlowEvent.ClassicalGameResult then
    return 6
  elseif eventName == GuideFlowEvent.RankingToLobby then
    return 601
  elseif eventName == GuideFlowEvent.MatchingToLobby then
    return 602
  elseif eventName == GuideFlowEvent.OpenedUGC then
    if param1 == "Lobby" then
      return 701
    elseif param1 == "Recommend" then
      return 702
    elseif param1 == "Create" then
      return 703
    elseif param1 == "Mine" then
      return 704
    elseif param1 == "SelecetTemplateDone" then
      return 705
    elseif param1 == "OpenModeSelection" then
      return 706
    end
  end
  return 0
end
function GuideFlowEventMap.RemoveEventMapNodeByBlockRule(blockRule)
  local needRemoveNodeList = {}
  for k, v in pairs(GuideFlowEventMap.eventMap) do
    for kk, vv in pairs(v) do
      if blockRule[vv.id] then
        GuideFlowLog.log(GuideFlowLog.bLog and "GuideFlowEventMap RemoveEventMapNodeByBlockRule remove node id = " .. vv.id)
        table.insert(needRemoveNodeList, vv)
      end
    end
  end
  for k, v in pairs(needRemoveNodeList) do
    GuideFlowEventMap.RemoveNodeEvent(v)
  end
end
function GuideFlowEventMap.UpdateTimeoutNode(bInFighting)
  local tNow = TimeUtil.GetServerTimeInSec()
  local doActionNodeMap = {}
  local bSatisfy = false
  local needRemoveNodeList = {}
  for k, v in pairs(GuideFlowEventMap.eventMap) do
    for kk, vv in pairs(v) do
      if vv.bTimeoutNode and (bInFighting == false or vv.TickInBattle == 1) then
        local oneParent = GuideFlowTools.GetOneParent(vv)
        if oneParent then
          local tDis = tNow - vv.parentFinishedTime
          if tDis > oneParent.timeout then
            for kkk, vvv in pairs(oneParent.noTimeoutNodeIdList) do
              local node = GuideFlowTools.FindChildNode(oneParent, vvv)
              if node then
                table.insert(needRemoveNodeList, node)
              end
            end
            local timeoutNode = GuideFlowTools.FindChildNode(oneParent, oneParent.timeoutNodeId)
            if timeoutNode then
              GuideFlowLog.log(GuideFlowLog.bLog and "GuideFlowEventMap has timeoutNode")
              if doActionNodeMap[vv.treeNo] == nil then
                doActionNodeMap[vv.treeNo] = {}
              end
              table.insert(doActionNodeMap[vv.treeNo], timeoutNode)
              bSatisfy = true
            end
          end
        end
      end
    end
  end
  for k, v in pairs(needRemoveNodeList) do
    GuideFlowEventMap.RemoveNodeEvent(v)
  end
  if bSatisfy then
    local changedTreeIDTable = {}
    logic_guide_flow.DoActionNodeMap(doActionNodeMap, changedTreeIDTable, "timeoutEvent")
  end
end
function GuideFlowEventMap.UpdateDelayAutoFinish(bInFighting)
  local tNow = TimeUtil.GetServerTimeInSec()
  local doActionNodeMap = {}
  local blockedByConditionNodeMap = {}
  local bSatisfy = false
  local bHasBlocked = false
  for k, v in pairs(GuideFlowEventMap.eventMap) do
    for kk, vv in pairs(v) do
      if vv.delayAutoFinishType and (bInFighting == false or vv.TickInBattle == 1) then
        local oneParent = GuideFlowTools.GetOneParent(vv)
        if oneParent then
          local bFinish = false
          if vv.delayAutoFinishType == 1 then
            local tDis = tNow - vv.parentFinishedTime
            if tDis > vv.delayAutoFinishTime then
              GuideFlowLog.log(GuideFlowLog.bLog and "GuideFlowEventMap UpdateDelayAutoFinish 4 tDis = " .. tDis)
              GuideFlowLog.log(GuideFlowLog.bLog and "GuideFlowEventMap UpdateDelayAutoFinish 4 tDis = " .. tDis)
              bFinish = true
            end
          elseif vv.delayAutoFinishType == 2 then
            local dayDis = GuideFlowTools.UTCDayDis(tNow, vv.parentFinishedTime)
            if dayDis >= vv.delayAutoFinishTime then
              GuideFlowLog.log(GuideFlowLog.bLog and "GuideFlowEventMap UpdateDelayAutoFinish 5 tDis = " .. dayDis)
              bFinish = true
            end
          end
          if bFinish then
            GuideFlowLog.log(GuideFlowLog.bLog and "GuideFlowEventMap UpdateDelayAutoFinish delay auto finish id = " .. vv.id)
            local GuideFlowNodeBlockRule = require("client.slua.logic.GuideFlow.GuideFlowNodeBlockRule")
            if GuideFlowNodeBlockRule.IsInBlockRule(vv.id) then
              GuideFlowLog.log(GuideFlowLog.bLog and "GuideFlowEventMap.UpdateDelayAutoFinish IsInBlockRule node.id = " .. vv.id)
            elseif logic_guide_flow.CheckCondition(vv) then
              if doActionNodeMap[vv.treeNo] == nil then
                doActionNodeMap[vv.treeNo] = {}
              end
              table.insert(doActionNodeMap[vv.treeNo], vv)
              bSatisfy = true
            else
              if blockedByConditionNodeMap[vv.treeNo] == nil then
                blockedByConditionNodeMap[vv.treeNo] = {}
              end
              table.insert(blockedByConditionNodeMap[vv.treeNo], vv)
              bHasBlocked = true
            end
          end
        end
      end
    end
  end
  local changedTreeIDTable = {}
  if bHasBlocked then
    logic_guide_flow.ProcBlockedByConditionNodeMap(blockedByConditionNodeMap, changedTreeIDTable)
  end
  if bSatisfy then
    logic_guide_flow.DoActionNodeMap(doActionNodeMap, changedTreeIDTable, "delayAutoFinish")
  end
end
function GuideFlowEventMap.NotInDelayConditionBlock(node)
  local resTree = logic_guide_flow.resAllTree[node.treeNo]
  if resTree == nil or resTree.blocked == nil then
    return true
  end
  if resTree.blocked[node.id] == nil then
    return true
  end
  return false
end
function GuideFlowEventMap.ClearDelayConditionBlock(node)
  local resTree = logic_guide_flow.resAllTree[node.treeNo]
  if resTree == nil or resTree.blocked == nil then
    return
  end
  resTree.blocked[node.id] = nil
end
function GuideFlowEventMap.OnLoadingFinish()
  local curStatus = GameStatus.GetGameStatus()
  local lastStatus = GameStatus.GetLastGameStatus()
  local GuideFlowEvent = require("client.slua.logic.GuideFlow.Event.GuideFlowEvent")
  GuideFlowLog.log(GuideFlowLog.bLog and "GuideFlowEventMap.OnLoadingFinish lastStatus = " .. lastStatus .. ", curStatus = " .. curStatus)
  if (lastStatus == GameStatus.Login or lastStatus == GameStatus.Createrole) and curStatus == GameStatus.Lobby then
    local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
    if LogicTxMissionMain.IsInXMission() == false then
      GuideFlowLog.log(GuideFlowLog.bLog and "GuideFlowEventMap.OnLoadingFinish LoginToLobby")
      GuideFlowEventMap.PostEvent(GuideFlowEvent.LoginToLobby)
    end
  else
    if lastStatus == GameStatus.Fighting and curStatus == GameStatus.Lobby then
      GuideFlowLog.log(GuideFlowLog.bLog and "GuideFlowEventMap.OnLoadingFinish FightToLobby")
      GuideFlowEventMap.PostEvent(GuideFlowEvent.FightToLobby)
      local BattleEvaluationCondition = require("client.slua.logic.GuideFlow.Condition.BattleEvaluationCondition")
      if BattleEvaluationCondition.IsRankingType() then
        GuideFlowLog.log(GuideFlowLog.bLog and "GuideFlowEventMap.OnLoadingFinish RankingToLobby")
        GuideFlowEventMap.PostEvent(GuideFlowEvent.RankingToLobby)
      elseif BattleEvaluationCondition.IsMatchingType() then
        GuideFlowLog.log(GuideFlowLog.bLog and "GuideFlowEventMap.OnLoadingFinish MatchingToLobby")
        GuideFlowEventMap.PostEvent(GuideFlowEvent.MatchingToLobby)
      end
    else
    end
  end
end
function GuideFlowEventMap.OnUIShow(_, _, config)
  GuideFlowLog.log(GuideFlowLog.bLog and "GuideFlowEventMap.OnUIShow keyName = " .. config.keyName)
  local GuideFlowEvent = require("client.slua.logic.GuideFlow.Event.GuideFlowEvent")
  GuideFlowEventMap.PostEvent(GuideFlowEvent.OpenUI, config.keyName)
end
function GuideFlowEventMap.OnUIHide(_, _, keyName)
  GuideFlowLog.log(GuideFlowLog.bLog and "GuideFlowEventMap.OnUIHide keyName = " .. tostring(keyName))
  local GuideFlowEvent = require("client.slua.logic.GuideFlow.Event.GuideFlowEvent")
  local ui_config = UIManager.GetConfigByKey(keyName)
  if ui_config then
    GuideFlowEventMap.PostEvent(GuideFlowEvent.CloseUI, ui_config.moduleName)
    GuideFlowEventMap.PostEvent(GuideFlowEvent.CloseUI, "AnyUI")
  end
end
function GuideFlowEventMap.OnUGCOpendedUI(_, _, uiTag)
  local GuideFlowEvent = require("client.slua.logic.GuideFlow.Event.GuideFlowEvent")
  GuideFlowLog.log(GuideFlowLog.bLog and "GuideFlowEventMap.OnUGCOpendedUI uiTag = " .. uiTag)
  GuideFlowEventMap.PostEvent(GuideFlowEvent.OpenedUGC, uiTag)
end
return GuideFlowEventMap