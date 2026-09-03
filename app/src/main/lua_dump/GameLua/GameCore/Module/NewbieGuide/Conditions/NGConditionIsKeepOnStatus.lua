local NGConditionIsKeepOnStatus = {}
function NGConditionIsKeepOnStatus:ctor(selfType, Params)
  self.CharacterState = Params.CharacterState or -1
  self.CheckIntervalTime = Params.CheckIntervalTime or 2.0
  if self.CheckIntervalTime < 0.2 then
    self.CheckIntervalTime = 0.2
  end
  self.TriggerThresholdTime = Params.TriggerThresholdTime or 3.0
  self.TriggerThresholdTime = (self.TriggerThresholdTime + self.CheckIntervalTime / 2) * 1000000
  self.nLastCheckFailedTime = slua.getMicroseconds()
  self.bCheckOK = false
  local timer_ticker = require("common.time_ticker")
  self.TimerHander = timer_ticker.AddTimer(0, function()
    while true do
      coroutine.yield(self.CheckIntervalTime)
      local nCurTime = slua.getMicroseconds()
      if self:IsCharacterInState() then
        if nCurTime - self.nLastCheckFailedTime > self.TriggerThresholdTime and not self.bCheckOK then
          self.bCheckOK = true
          log(bWriteLog and "Debug Trigger Event:EVENTID_NEWBIE_GUIDE_KEEP_ON_STATUS, bCheckOK:true, CharacterStatus:" .. tostring(self.CharacterState))
          EventSystem:postEvent(EVENTTYPE_NEWBIE_GUIDE, EVENTID_NEWBIE_GUIDE_KEEP_ON_STATUS, true, self.CharacterState)
        end
      else
        self.nLastCheckFailedTime = slua.getMicroseconds()
        if self.bCheckOK then
          self.bCheckOK = false
          log(bWriteLog and "Debug Trigger Event:EVENTID_NEWBIE_GUIDE_KEEP_ON_STATUS, bCheckOK:false, CharacterStatus:" .. tostring(self.CharacterState))
          EventSystem:postEvent(EVENTTYPE_NEWBIE_GUIDE, EVENTID_NEWBIE_GUIDE_KEEP_ON_STATUS, false, self.CharacterState)
        end
      end
    end
  end)
end
function NGConditionIsKeepOnStatus:CheckConditionOK(...)
  log(bWriteLog and "Debug NewbieGuide: NGConditionIsKeepOnStatus CheckConditionOK: " .. tostring(self.bCheckOK))
  local bSuperOk = NGConditionIsKeepOnStatus.__super.CheckConditionOK(self, ...)
  if not bSuperOk then
    return false
  end
  return self.bCheckOK
end
function NGConditionIsKeepOnStatus:IsCharacterInState()
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(uPlayerController) or not uPlayerController.GetPlayerCharacterSafety then
    return false
  end
  local uPlayerPawn = uPlayerController:GetPlayerCharacterSafety()
  if not slua.isValid(uPlayerPawn) then
    return false
  end
  return uPlayerPawn:HasState(self.CharacterState)
end
function NGConditionIsKeepOnStatus:Clear()
  if self.TimerHander then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(self.TimerHander)
    self.TimerHander = nil
    log(bWriteLog and "Debug Clear timer, Stop Check CharacterState:" .. tostring(self.CharacterState))
  end
end
local class = require("class")
local CObject = require("GameLua.GameCore.Module.NewbieGuide.Conditions.NewbieGuideConditionBase")
local CNGConditionIsKeepOnStatus = class(CObject, nil, NGConditionIsKeepOnStatus)
return CNGConditionIsKeepOnStatus