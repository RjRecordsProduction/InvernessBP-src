local LuaMiniTvAnimInstance = {}
local INTERVAL_IDEL_TO_SLEEP_START = 10.0
local INTERVAL_SLEEP_START_TO_SLEEP_LOOP = 3.5
function LuaMiniTvAnimInstance:ctor()
  log(bWriteLog and "LuaMiniTvAnimInstance:ctor")
  self.IdleTimerHandle = nil
end
function LuaMiniTvAnimInstance:AnimNotify_OnEnterIdle()
  log(bWriteLog and "LuaMiniTvAnimInstance:AnimNotify_OnEnterIdle - Entered Idle state")
  if not Client then
    return
  end
  if self.IdleTimerHandle then
    self:RemoveGameTimer(self.IdleTimerHandle)
    self.IdleTimerHandle = nil
  end
  self.IdleTimerHandle = self:AddGameTimer(INTERVAL_IDEL_TO_SLEEP_START, false, function()
    if slua.isValid(self.Object) then
      log(bWriteLog and "LuaMiniTvAnimInstance:IdleTimer - 10 seconds elapsed, set bShouldSleep")
      self.bCanEnterSleep = true
    end
    self.IdleTimerHandle = nil
  end)
end
function LuaMiniTvAnimInstance:AnimNotify_OnLeftIdle()
  log(bWriteLog and "LuaMiniTvAnimInstance:AnimNotify_OnLeftIdle - Left Idle state")
  if not Client then
    return
  end
  if self.IdleTimerHandle then
    self:RemoveGameTimer(self.IdleTimerHandle)
    self.IdleTimerHandle = nil
  end
  self.bCanEnterSleep = false
end
function LuaMiniTvAnimInstance:AnimNotify_OnEnterSleepStart()
  log(bWriteLog and "LuaMiniTvAnimInstance:AnimNotify_OnEnterSleepStart - Entered SleepStart state")
  if not Client then
    return
  end
  if self.SleepTimerHandle then
    self:RemoveGameTimer(self.SleepTimerHandle)
    self.SleepTimerHandle = nil
  end
  self.SleepTimerHandle = self:AddGameTimer(INTERVAL_SLEEP_START_TO_SLEEP_LOOP, false, function()
    if slua.isValid(self.Object) then
      log(bWriteLog and "LuaMiniTvAnimInstance:SleepTimer - 3.5 seconds elapsed, set bEnterSleepLoop")
      self.bEnterSleepLoop = true
    end
    self.SleepTimerHandle = nil
  end)
end
function LuaMiniTvAnimInstance:AnimNotify_OnLeftSleepStart()
  log(bWriteLog and "LuaMiniTvAnimInstance:AnimNotify_OnLeftSleepStart - Left SleepStart state")
  if not Client then
    return
  end
  if self.SleepTimerHandle then
    self:RemoveGameTimer(self.SleepTimerHandle)
    self.SleepTimerHandle = nil
  end
  self.bEnterSleepLoop = false
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
local CLuaMiniTvAnimInstance = class(CDelegateContainer, nil, LuaMiniTvAnimInstance)
return CLuaMiniTvAnimInstance