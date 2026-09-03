local ugc_newbieguide_step = {}
function ugc_newbieguide_step:ctor(_, GuideID, GuideConfig)
  self.  self._  local ActionCfg = GuideConfig.Action
  if ActionCfg and ActionCfg.LuaPath then
    local ActionCls = require(ActionCfg.LuaPath)
    if ActionCls then
      self._ActionInst = ActionCls(ActionCfg.Params)
    end
  end
  self:RefreshStep()
  self._ExpectedTriggeredNum = 0
  self._ExpectedEndedNum = 0
  self._ExpectedAbortedNum = 0
  self:RegisterNewbieEvents()
  if self._GuideConfig.OnStepTick then
    self:AddTimerLoop(0, function()
      if self._bHasBeenTriggerred and not self._bHasBeenEnded then
        self._GuideConfig.OnStepTick(self)
      end
    end, TIMER_INFINITE, 0.5)
  end
end
function ugc_newbieguide_step:RegisterNewbieEvents()
  if self._GuideConfig.TriggerEvent then
    for Idx, EventConfig in pairs(self._GuideConfig.TriggerEvent.Events) do
      local EventType = load("return " .. EventConfig.EventType)()
      local EventID = load("return " .. EventConfig.EventID)()
      if EventType and EventID then
        local Trigger        self:AddCommonEventWithConditions(EventType, EventID, EventConfig.Conditions or {}, function()
          self:OnTriggerEventInvoked(TriggerIdx)
        end, self)
        self._ExpectedTriggeredNum = self._ExpectedTriggeredNum + 1
      end
    end
  end
  if self._GuideConfig.EndEvent and self._GuideConfig.EndEvent.Events then
    for Idx, EventConfig in pairs(self._GuideConfig.EndEvent.Events) do
      local EventType = load("return " .. EventConfig.EventType)()
      local EventID = load("return " .. EventConfig.EventID)()
      if EventType and EventID then
        local Trigger        self:AddCommonEventWithConditions(EventType, EventID, EventConfig.Conditions or {}, function()
          self:OnEndedEventInvoked(TriggerIdx)
        end, self)
        self._ExpectedEndedNum = self._ExpectedEndedNum + 1
      end
    end
  end
  if self._GuideConfig.AbortEvent and self._GuideConfig.AbortEvent.Events then
    for Idx, EventConfig in pairs(self._GuideConfig.AbortEvent.Events) do
      local EventType = load("return " .. EventConfig.EventType)()
      local EventID = load("return " .. EventConfig.EventID)()
      if EventType and EventID then
        local Trigger        self:AddCommonEventWithConditions(EventType, EventID, EventConfig.Conditions or {}, function()
          self:OnAbortedEventInvoked(TriggerIdx)
        end, self)
        self._ExpectedAbortedNum = self._ExpectedAbortedNum + 1
      end
    end
  end
end
function ugc_newbieguide_step:IsEventRepeatable()
  return self._GuideConfig.bRepeated
end
function ugc_newbieguide_step:IsEventRepeatableOnAborted()
  return self._GuideConfig.bRepeatedOnAborted
end
function ugc_newbieguide_step:OnTriggerEventInvoked(TriggerIdx)
  print(bWriteLog and "ugc_newbieguide_step:OnTriggerEventInvoked GuideID = " .. tostring(self.GuideID))
  print(bWriteLog and "ugc_newbieguide_step:OnTriggerEventInvoked TriggerIdx = " .. tostring(TriggerIdx))
  if not self._bHasBeenTriggerred then
    if not self._HasTriggeredEvent[TriggerIdx] then
      self._HasTriggeredEvent[TriggerIdx] = true
      self._HasTriggeredNum = self._HasTriggeredNum + 1
    end
    if self._HasTriggeredNum == self._ExpectedTriggeredNum then
      self:OnAllEventsTriggered()
    end
  end
end
function ugc_newbieguide_step:OnEndedEventInvoked(TriggerIdx)
  print(bWriteLog and "ugc_newbieguide_step:OnEndedEventInvoked GuideID = " .. tostring(self.GuideID))
  print(bWriteLog and "ugc_newbieguide_step:OnEndedEventInvoked TriggerIdx = " .. tostring(TriggerIdx))
  if self._bHasBeenTriggerred and not self._bHasBeenEnded then
    if not self._HasEndedEvents[TriggerIdx] then
      self._HasEndedEvents[TriggerIdx] = true
      self._HasEndedNum = self._HasEndedNum + 1
    end
    if self._HasEndedNum == self._ExpectedEndedNum then
      self:OnEndedEventsTriggered()
    end
  end
end
function ugc_newbieguide_step:OnAbortedEventInvoked(TriggerIdx)
  print(bWriteLog and "ugc_newbieguide_step:OnAbortedEventInvoked GuideID = " .. tostring(self.GuideID))
  print(bWriteLog and "ugc_newbieguide_step:OnAbortedEventInvoked TriggerIdx = " .. tostring(TriggerIdx))
  if self._bHasBeenTriggerred and not self._bHasBeenEnded then
    if not self._HasAbortedEvents[TriggerIdx] then
      self._HasAbortedEvents[TriggerIdx] = true
      self._HasAbortedNum = self._HasAbortedNum + 1
    end
    if self._HasAbortedNum == self._ExpectedAbortedNum then
      self:OnAbortedEventsTriggered()
    end
  end
end
function ugc_newbieguide_step:IsRunning()
  if self._bHasBeenTriggerred and not self._bHasBeenEnded then
    return true
  end
  return false
end
function ugc_newbieguide_step:OnAllEventsTriggered()
  print(bWriteLog and "ugc_newbieguide_step:OnAllEventsTriggered " .. tostring(self.GuideID))
  if self._ActionInst then
    if self._GuideConfig.DelayTime and not self._HasTimerInDelayed then
      self._HasTimerInDelayed = true
      UIManager.ShowUI(UIManager.UI_Config.Common_NewbieGuide_Ban_Masked_UIBP)
      self:AddGameTimer(self._GuideConfig.DelayTime, false, function()
        self:AddGameTimer(0, false, function()
          local UIConfigName = "Common_NewbieGuide_Ban_Masked_UIBP"
          if UIManager.UI_Config[UIConfigName] and UIManager.IsUIShow(UIManager.UI_Config[UIConfigName]) then
            UIManager.CloseUI(UIManager.UI_Config[UIConfigName])
          end
        end)
        local UIConfigName = "Common_NewbieGuide_Ban_Masked_UIBP"
        if UIManager.UI_Config[UIConfigName] and UIManager.IsUIShow(UIManager.UI_Config[UIConfigName]) then
          UIManager.CloseUI(UIManager.UI_Config[UIConfigName])
        end
        self._HasTimerInDelayed = false
        if self._GuideConfig.Condition() then
          local ui = UIManager.ShowUI(UIManager.UI_Config.Common_NewbieGuide_Ban_Masked_UIBP)
          ui:SetBanTouch(false)
          self._bHasBeenTriggerred = true
          self._ActionInst:RunAction(self.GuideID)
        else
          self._bHasBeenTriggerred = false
        end
      end)
    elseif self._GuideConfig.Condition() then
      local ui = UIManager.ShowUI(UIManager.UI_Config.Common_NewbieGuide_Ban_Masked_UIBP)
      ui:SetBanTouch(false)
      self._bHasBeenTriggerred = true
      self._ActionInst:RunAction(self.GuideID)
      if self._GuideConfig.EndEvent == nil or self._GuideConfig.EndEvent.Events and #self._GuideConfig.EndEvent.Events == 0 then
        self:OnEndedEventsTriggered()
      end
    else
      self._bHasBeenTriggerred = false
    end
  end
end
function ugc_newbieguide_step:OnEndedEventsTriggered()
  print(bWriteLog and "ugc_newbieguide_step:OnEndedEventsTriggered " .. tostring(self.GuideID))
  if self._ActionInst then
    self._ActionInst:EndAction(self.GuideID)
  end
  if self._GuideConfig.AfterActionEnded then
    self._GuideConfig.AfterActionEnded(self.GuideID)
  end
  local UIConfigName = "Common_NewbieGuide_Ban_Masked_UIBP"
  if UIManager.UI_Config[UIConfigName] and UIManager.IsUIShow(UIManager.UI_Config[UIConfigName]) then
    UIManager.HideUI(UIManager.UI_Config[UIConfigName])
  end
  self._bHasBeenEnded = true
  if self.GuideID then
    if self:IsEventRepeatable() then
      self:RefreshStep()
    else
      local Util_UGC = require("client.slua.logic.ugc.util_ugc")
      if type(self.GuideID) ~= "userdata" then
        Util_UGC.SetUGCNewbieGuideFinish(self.GuideID)
      else
        print(bWriteLog and "ugc_newbieguide_step:OnEndedEventsTriggered GuideID is userdata")
      end
    end
    if type(self.GuideID) ~= "userdata" then
      EventSystem:postEvent(EVENTTYPE_NEWBIE_GUIDE, EVENTID_NEWBIE_GUIDE_END, self.GuideID)
    else
      print(bWriteLog and "ugc_newbieguide_step:OnEndedEventsTriggered GuideID is userdata")
    end
  end
end
function ugc_newbieguide_step:OnAbortedEventsTriggered()
  print(bWriteLog and "ugc_newbieguide_step:OnAbortedEventsTriggered " .. tostring(self.GuideID))
  if self._ActionInst then
    self._ActionInst:EndAction(self.GuideID)
  end
  if self._GuideConfig.AfterActionEnded then
    self._GuideConfig.AfterActionEnded(self.GuideID)
  end
  self._bHasBeenEnded = true
  if self.GuideID and (self:IsEventRepeatable() or self:IsEventRepeatableOnAborted()) then
    self:RefreshStep()
  end
end
function ugc_newbieguide_step:RefreshStep(bResetProgress)
  self._bHasBeenTriggerred = false
  self._bHasBeenEnded = false
  self._HasTriggeredEvent = {}
  self._HasTriggeredNum = 0
  self._HasEndedEvents = {}
  self._HasEndedNum = 0
  self._HasAbortedEvents = {}
  self._HasAbortedNum = 0
  if bResetProgress then
    Util_UGC.ResetUGCNewbieGuideFinish(self.GuideID)
  end
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
local Cugc_newbieguide_step = class(CDelegateContainer, nil, ugc_newbieguide_step)
return Cugc_newbieguide_step