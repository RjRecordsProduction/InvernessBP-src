local NewbieGuideItem = {DefaultGroup = 0, DefaultRunningMaxTime = 10}
local ENGRunningState = {
  STOP = 0,
  WAITING = 1,
  RUNNING = 2
}
function NewbieGuideItem:ctor(selfType, ID, GuideConfig)
  log(bWriteLog and "NewbieGuideItem:ctor " .. tostring(ID))
  self.RuningState = ENGRunningState.STOP
  self.bLegal = false
  self.  self.ActionTable = {}
  self.bLegal = false
  self.SyncGuideDataAtStart = false
  self.LastTriggerEndTime = -10000
  local NewbieGuideMgr = require("GameLua.GameCore.Module.NewbieGuide.NewbieGuideMgr")
  if not NewbieGuideMgr then
    return
  end
  if not GuideConfig then
    sandbox.LogError("NewbieGuideItem construct fail! GuideConfig is nil")
    return
  end
  self.GuideGroup = GuideConfig.GuideGroup or self.DefaultGroup
  self.MaxRunningTime = GuideConfig.RuningMaxTime or self.DefaultRunningMaxTime
  self.TriggerIntervalTime = GuideConfig.TriggerIntervalTime or 0
  self.TriggerDelayTime = GuideConfig.TriggerDelayTime or 0.1
  self.GuideClearCode = GuideConfig.GuideClearCode or ""
  self.SyncGuideDataAtStart = GuideConfig.SyncGuideDataAtStart or false
  self.TriggerConditions = {}
  self.EndConditions = {}
  self.EndConditionsExtra = {}
  local TriggerCustomCondition = GuideConfig.TriggerEvent and GuideConfig.TriggerEvent.CustomCondition
  if not self:InitEvent(GuideConfig.TriggerEvent, "TriggerConditions", self.CheckCanRunGuide, self.HandleRunAction) and not TriggerCustomCondition then
    sandbox.LogError("Debug NewbieGuide: NewbieGuideItem construct fail! GuideID:" .. tostring(self.ID))
    return
  end
  self:InitEvent(GuideConfig.EndEvent, "EndConditions", nil, self.HandleEndGuide)
  self:InitEvent(GuideConfig.EndEventExtra, "EndConditionsExtra", nil, self.HandleEndGuideExtra)
  self:AddCommonEvent(EVENTTYPE_NEWBIE_GUIDE, EVENTID_NEWBIE_GUIDE_BTN_CLICK, self.HandleGuideBtnClick, self)
  self:AddCommonEvent(EVENTTYPE_NEWBIE_GUIDE, EVENTID_NEWBIE_GUIDE_END_GUIDE_BY_ACTION, self.HandleGuideEndWithReason, self)
  self.ActionTable = {}
  if GuideConfig.Actions then
    for _, ActionInfo in pairs(GuideConfig.Actions) do
      if ActionInfo.LuaPath then
        local ActionC = require(ActionInfo.LuaPath)
        if ActionC then
          local Action = ActionC(ActionInfo.Params)
          table.insert(self.ActionTable, Action)
        end
      end
    end
  end
  self.EndActionTable = {}
  if GuideConfig.EndActions then
    for _, ActionInfo in pairs(GuideConfig.EndActions) do
      if ActionInfo.LuaPath then
        local ActionC = require(ActionInfo.LuaPath)
        if ActionC then
          local Action = ActionC(ActionInfo.Params)
          table.insert(self.EndActionTable, Action)
        end
      end
    end
  end
  self.bLegal = true
  if GuideConfig.GuideInitCode and GuideConfig.GuideInitCode ~= "" then
    log(bWriteLog and "NewbieGuideItem:ctor() GuideInitCode" .. GuideConfig.GuideInitCode)
    load(GuideConfig.GuideInitCode)()
  end
  if TriggerCustomCondition then
    local timer_ticker = require("common.time_ticker")
    self.customConditionTimer_Start = timer_ticker.AddTimerLoop(TriggerCustomCondition.Interval, function()
      xpcall(function()
        local NewbieGuieSubsystem = SubsystemMgr:Get("CreativeModeNewbieGuideSubsystem")
        if NewbieGuieSubsystem and NewbieGuieSubsystem:IsTutorialOn() and TriggerCustomCondition.OnCheck() then
          timer_ticker.RemoveTimer(self.customConditionTimer_Start)
          self.customConditionTimer_Start = nil
          self:HandleRunAction()
        end
      end, function(err)
      end)
    end, TIMER_INFINITE, TriggerCustomCondition.Interval)
  end
  local EndCustomCondition = GuideConfig.EndEvent and GuideConfig.EndEvent.CustomCondition
  if EndCustomCondition then
    local timer_ticker = require("common.time_ticker")
    self.customConditionTimer_End = timer_ticker.AddTimerLoop(EndCustomCondition.Interval, function()
      xpcall(function()
        local NewbieGuieSubsystem = SubsystemMgr:Get("CreativeModeNewbieGuideSubsystem")
        if self.RuningState == ENGRunningState.RUNNING and NewbieGuieSubsystem and NewbieGuieSubsystem:IsTutorialOn() and EndCustomCondition.OnCheck() then
          timer_ticker.RemoveTimer(self.customConditionTimer_End)
          self.customConditionTimer_End = nil
          self:HandleEndGuide()
        end
      end, function(err)
      end)
    end, TIMER_INFINITE, EndCustomCondition.Interval)
  end
end
function NewbieGuideItem:InitEvent(EventConfig, ConditionType, ConditionFunction, RegisterFunction)
  if not EventConfig then
    return false
  end
  if not EventConfig.Events or #EventConfig.Events == 0 then
    return
  end
  local ConditionTable = {}
  if ConditionType == "TriggerConditions" then
    ConditionTable = self.TriggerConditions
  elseif ConditionType == "EndConditions" then
    ConditionTable = self.EndConditions
  elseif ConditionType == "EndConditionsExtra" then
    ConditionTable = self.EndConditionsExtra
  end
  if EventConfig.Conditions then
    for _, ConditionInfo in pairs(EventConfig.Conditions) do
      if ConditionInfo.LuaPath then
        local ConditionC = require(ConditionInfo.LuaPath)
        if ConditionC then
          local Condition = ConditionC(ConditionInfo.Params)
          Condition.GuideID = self.ID
          table.insert(ConditionTable, Condition)
        end
      end
    end
  end
  local bHasLegalEvent = false
  for _, EventCompare in pairs(EventConfig.Events) do
    local EventType = _G[EventCompare.EventType]
    local EventID = _G[EventCompare.EVENTID]
    if EventType and EventID then
      bHasLegalEvent = true
      if RegisterFunction then
        self:AddCommonEventWithConditionsWithoutCoroutine(EventType, EventID, EventCompare.Conditions, function(EventType, EventID, TriggerID, ...)
          if not RegisterFunction then
            return
          end
          if ConditionFunction and not ConditionFunction(self) then
            return
          end
          local ConditionOK = true
          if 0 < #ConditionTable then
            if EventConfig.ConditionsJudgment == nil or EventConfig.ConditionsJudgment == "And" then
              ConditionOK = true
              for _, Condition in pairs(ConditionTable) do
                if Condition and Condition.CheckConditionOK and not Condition:CheckConditionOK(...) then
                  ConditionOK = false
                  break
                end
              end
            else
              ConditionOK = false
              for _, Condition in pairs(ConditionTable) do
                if Condition and Condition.CheckConditionOK and Condition:CheckConditionOK(...) then
                  ConditionOK = true
                  break
                end
              end
            end
          end
          if ConditionOK then
            RegisterFunction(self, ...)
          end
        end)
      end
    end
  end
  return bHasLegalEvent
end
function NewbieGuideItem:CheckCanRunGuide()
  local nCurTime = os.time()
  if nCurTime - self.LastTriggerEndTime < self.TriggerIntervalTime - self.TriggerDelayTime then
    log(bWriteLog and "Guide " .. tostring(self.ID) .. " trigger interval less than " .. tostring(self.TriggerIntervalTime))
    return false
  end
  local NewbieGuideMgr = require("GameLua.GameCore.Module.NewbieGuide.NewbieGuideMgr")
  if not NewbieGuideMgr then
    return false
  end
  if not NewbieGuideMgr.CheckCanRunGuide(self) then
    sandbox.LogNormal(bWriteLog and "Debug NewbieGuide: Can not run newbie guide now! " .. self.ID)
    return false
  end
  return true
end
function NewbieGuideItem:HandleRunAction(...)
  if self.RuningState == ENGRunningState.STOP then
    self.RuningState = ENGRunningState.WAITING
    local args = {
      ...
    }
    if self.TriggerDelayTime < 0 then
      self:RunActions(table.unpack(args))
    else
      self.DelayTimeHandler = self:AddGameTimer(self.TriggerDelayTime, false, function()
        self:RunActions(table.unpack(args))
      end)
    end
  end
end
function NewbieGuideItem:HandleEndAction()
  for i, Action in ipairs(self.EndActionTable) do
    if Action and Action.RunAction then
      Action:RunAction(self.ID)
    end
  end
end
function NewbieGuideItem:RunActions(...)
  if self.RuningState == ENGRunningState.WAITING then
    log(bWriteLog and "NewbieGuideItem:RunActions GuideID:" .. tostring(self.ID))
    if self.ActionTable then
      local bDoActionRes = true
      for ActionIndex = 1, #self.ActionTable do
        local Action = self.ActionTable[ActionIndex]
        if Action and Action.RunAction then
          local res = Action:RunAction(self.ID, ...)
          bDoActionRes = bDoActionRes and res
        end
      end
      self.RuningState = ENGRunningState.RUNNING
      if not bDoActionRes then
        log(bWriteLog and "NewbieGuideItem:HandleRunAction() Failed GuideID:" .. tostring(self.ID))
        self:EndGuide("RunActionFailed")
        return
      end
      EventSystem:postEvent(EVENTTYPE_NEWBIE_GUIDE, EVENTID_NEWBIE_GUIDE_BEGIN, self.ID, self.GuideGroup)
      if self.MaxRunningTime > 0 then
        self.EndActionTimeHandler = self:AddGameTimer(self.MaxRunningTime, false, function()
          self:EndGuide("TimeOut")
        end)
      end
      if #self.ActionTable == 0 then
        self:EndGuide("RecieveEndEvent")
      end
    end
  end
end
function NewbieGuideItem:HandleEndGuide()
  self:EndGuide("RecieveEndEvent")
end
function NewbieGuideItem:HandleEndGuideExtra()
  self:EndGuide("RecieveEndEventExtra")
end
function NewbieGuideItem:EndGuide(EndType)
  self:ClearEndActionTimeHandler()
  if self.RuningState == ENGRunningState.RUNNING then
    log(bWriteLog and "Debug NewbieGuide " .. tostring(self.ID) .. " end by reason " .. tostring(EndType))
    self.LastTriggerEndTime = os.time()
    self.RuningState = ENGRunningState.STOP
    for ActionIndex = 1, #self.ActionTable do
      local Action = self.ActionTable[ActionIndex]
      if Action and Action.EndAction then
        Action:EndAction(self.ID, EndType)
      end
    end
    if EndType ~= "RunActionFailed" and EndType ~= "ShutDown" then
      self:HandleEndAction()
      EventSystem:postEvent(EVENTTYPE_NEWBIE_GUIDE, EVENTID_NEWBIE_GUIDE_END, self.ID, self.GuideGroup, EndType)
    end
  elseif self.RuningState == ENGRunningState.WAITING then
    log(bWriteLog and "Debug NewbieGuide " .. tostring(self.ID) .. " exit waiting state by reason " .. tostring(EndType))
    self:ClearDelayTimeHandler()
    self.RuningState = ENGRunningState.STOP
    self:HandleEndAction()
    EventSystem:postEvent(EVENTTYPE_NEWBIE_GUIDE, EVENTID_NEWBIE_GUIDE_END, self.ID, self.GuideGroup, "WaitingInterrupt")
  end
end
function NewbieGuideItem:HandleGuideBtnClick(EventType, EventID, GuideID)
  if GuideID and GuideID == self.ID then
    self:EndGuide("ClickBtn")
  end
end
function NewbieGuideItem:HandleGuideEndWithReason(EventType, EventID, GuideID, EndReson)
  if GuideID and GuideID == self.ID then
    self:EndGuide(EndReson)
  end
end
function NewbieGuideItem:Clear()
  if self.GuideClearCode and self.GuideClearCode ~= "" then
    log(bWriteLog and "NewbieGuideItem:Clear() RunGuideClearCode" .. self.GuideClearCode)
    load(self.GuideClearCode)()
  end
  self:Dispose()
  for ActionIndex = 1, #self.ActionTable do
    local Action = self.ActionTable[ActionIndex]
    if Action and Action.Clear then
      Action:Clear()
    end
  end
  for ConditionIndex = 1, #self.TriggerConditions do
    local Condition = self.TriggerConditions[ConditionIndex]
    if Condition and Condition.Clear then
      Condition:Clear()
    end
  end
  for ConditionIndex = 1, #self.EndConditions do
    local Condition = self.EndConditions[ConditionIndex]
    if Condition and Condition.Clear then
      Condition:Clear()
    end
  end
  for ConditionIndex = 1, #self.EndConditionsExtra do
    local Condition = self.EndConditionsExtra[ConditionIndex]
    if Condition and Condition.Clear then
      Condition:Clear()
    end
  end
end
function NewbieGuideItem:ClearDelayTimeHandler()
  if self.DelayTimeHandler then
    self:RemoveGameTimer(self.DelayTimeHandler)
    self.DelayTimeHandler = nil
  end
end
function NewbieGuideItem:ClearEndActionTimeHandler()
  if self.EndActionTimeHandler then
    self:RemoveGameTimer(self.EndActionTimeHandler)
    self.EndActionTimeHandler = nil
  end
  if self.customConditionTimer_Start then
    local timer_ticker = require("common.time_ticker")
    timer_ticker.RemoveTimer(self.customConditionTimer_Start)
    self.customConditionTimer_Start = nil
  end
  if self.customConditionTimer_End then
    local timer_ticker = require("common.time_ticker")
    timer_ticker.RemoveTimer(self.customConditionTimer_End)
    self.customConditionTimer_End = nil
  end
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
local CNewbieGuideItem = class(CDelegateContainer, nil, NewbieGuideItem)
return CNewbieGuideItem