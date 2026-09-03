local LobbyThemeParallaxManager = {}
local PARALLAX_TICK_INTERVAL = 0.033
local PARALLAX_MAX_OFFSET_X = 150
local PARALLAX_MAX_OFFSET_Y = 40
local PARALLAX_INPUT_SCALE = 5
local PARALLAX_INTERP_SPEED = 5
function LobbyThemeParallaxManager:DefineAndResetData()
  self.TargetOffsetX = 0
  self.TargetOffsetY = 0
  self.CurrentOffsetX = 0
  self.CurrentOffsetY = 0
  self.bParallaxEnabled = false
  self.ParallaxTickTimer = nil
  self.ParallaxActors = {}
  self.BaseRelativeOffsets = {}
  self.BoundOnGyroscopeInput = nil
  self.BoundOnCameraSwitched = nil
  self.SimulateGyroTimer = nil
end
function LobbyThemeParallaxManager:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_GYROSCOPE, EVENTID_GYROSCOPE_INPUT, self._OnGyroscopeInput, self)
  self:AddCommonEvent(EVENTTYPE_CAMERA, EVENTID_CAMERA_SWITCHED, self._OnCameraSwitched, self)
end
function LobbyThemeParallaxManager:OnInitialize()
end
function LobbyThemeParallaxManager:OnLogOut()
end
function LobbyThemeParallaxManager:OnPreSwitchGameStatus(preState, nextState)
  self:StopParallax()
end
function LobbyThemeParallaxManager:StartParallax()
  self:StopParallax()
  local UIUtil = require("client.common.ui_util")
  local deviceLevel = UIUtil.GetGameInstance():GetDeviceLevel()
  if deviceLevel < 2 then
    return
  end
  self:_StartParallaxTick()
end
function LobbyThemeParallaxManager:StopParallax()
  self:_StopParallax()
end
function LobbyThemeParallaxManager:IsParallaxRunning()
  return self.bParallaxEnabled
end
function LobbyThemeParallaxManager:SimulateGyroscope(Amplitude, Frequency)
  self:StopSimulateGyroscope()
  Amplitude = Amplitude or 5
  Frequency = Frequency or 0.5
  local ElapsedTime = 0
  local TwoPiFreq = 2 * math.pi * Frequency
  local PrevAngleX = 0
  local PrevAngleY = 0
  self.SimulateGyroTimer = self:AddTimerLoop(0, function()
    ElapsedTime = ElapsedTime + PARALLAX_TICK_INTERVAL
    local CurAngleX = Amplitude * math.sin(TwoPiFreq * ElapsedTime)
    local DeltaX = CurAngleX - PrevAngleX
    PrevAngleX = CurAngleX
    local CurAngleY = Amplitude * math.cos(TwoPiFreq * ElapsedTime)
    local DeltaY = CurAngleY - PrevAngleY
    PrevAngleY = CurAngleY
    EventSystem:postEvent(EVENTTYPE_GYROSCOPE, EVENTID_GYROSCOPE_INPUT, DeltaX, DeltaY, 0)
  end, TIMER_INFINITE, PARALLAX_TICK_INTERVAL)
end
function LobbyThemeParallaxManager:StopSimulateGyroscope()
  if self.SimulateGyroTimer then
    self:RemoveTimer(self.SimulateGyroTimer)
    self.SimulateGyroTimer = nil
  end
end
function LobbyThemeParallaxManager:_StopParallax()
  self.bParallaxEnabled = false
  self.CurrentOffsetX = 0
  self.CurrentOffsetY = 0
  self:_ApplyOffsetToBackground()
  self:_StopParallaxTick()
  self.TargetOffsetX = 0
  self.TargetOffsetY = 0
  self.CurrentOffsetX = 0
  self.CurrentOffsetY = 0
  self.ParallaxActors = {}
  self.BaseRelativeOffsets = {}
end
function LobbyThemeParallaxManager:_OnGyroscopeInput(_, _, deltaX, deltaY, deltaZ)
  self.TargetOffsetX = self.TargetOffsetX + deltaX * PARALLAX_INPUT_SCALE
  self.TargetOffsetY = self.TargetOffsetY + deltaY * PARALLAX_INPUT_SCALE
  if self.TargetOffsetX > PARALLAX_MAX_OFFSET_X then
    self.TargetOffsetX = PARALLAX_MAX_OFFSET_X
  elseif self.TargetOffsetX < -PARALLAX_MAX_OFFSET_X then
    self.TargetOffsetX = -PARALLAX_MAX_OFFSET_X
  end
  if self.TargetOffsetY > PARALLAX_MAX_OFFSET_Y then
    self.TargetOffsetY = PARALLAX_MAX_OFFSET_Y
  elseif self.TargetOffsetY < -PARALLAX_MAX_OFFSET_Y then
    self.TargetOffsetY = -PARALLAX_MAX_OFFSET_Y
  end
end
function LobbyThemeParallaxManager:_OnCameraSwitched(_, _, cameraId)
  self.TargetOffsetX = 0
  self.TargetOffsetY = 0
end
function LobbyThemeParallaxManager:_StartParallaxTick()
  self:_StopParallaxTick()
  self.ParallaxTickTimer = self:AddTimerLoop(0, function()
    self:_UpdateParallaxOffset()
  end, TIMER_INFINITE, PARALLAX_TICK_INTERVAL)
end
function LobbyThemeParallaxManager:_StopParallaxTick()
  if self.ParallaxTickTimer then
    self:RemoveTimer(self.ParallaxTickTimer)
    self.ParallaxTickTimer = nil
  end
end
function LobbyThemeParallaxManager:_UpdateParallaxOffset()
  local KismetMathLibrary = import("/Script/Engine.KismetMathLibrary")
  self.CurrentOffsetX = KismetMathLibrary.FInterpTo(self.CurrentOffsetX, self.TargetOffsetX, PARALLAX_TICK_INTERVAL, PARALLAX_INTERP_SPEED)
  self.CurrentOffsetY = KismetMathLibrary.FInterpTo(self.CurrentOffsetY, self.TargetOffsetY, PARALLAX_TICK_INTERVAL, PARALLAX_INTERP_SPEED)
  self:_ApplyOffsetToBackground()
end
function LobbyThemeParallaxManager:_ApplyOffsetToBackground()
  local World = slua_GameFrontendHUD:GetWorld()
  if not slua.isValid(World) then
    return
  end
  local UGameplayStatics = import("/Script/Engine.GameplayStatics")
  local bCacheValid = next(self.ParallaxActors) ~= nil
  if bCacheValid then
    for i = 1, #self.ParallaxActors do
      if not slua.isValid(self.ParallaxActors[i]) then
        bCacheValid = false
        break
      end
    end
  end
  if not bCacheValid then
    self.ParallaxActors = {}
    self.BaseRelativeOffsets = {}
    local ActorClass = import("/Script/Engine.Actor")
    local ActorArray = slua.Array(UEnums.EPropertyClass.Object, ActorClass)
    ActorArray = UGameplayStatics.GetAllActorsWithTag(World, "Parallax", ActorArray)
    if ActorArray and ActorArray:Num() > 0 then
      for i = 1, ActorArray:Num() do
        self.ParallaxActors[i] = ActorArray:Get(i - 1)
      end
    end
  end
  if #self.ParallaxActors == 0 then
    self:_StopParallaxTick()
    return
  end
  local Offset = FVector(self.CurrentOffsetX, 0, self.CurrentOffsetY)
  for i = 1, #self.ParallaxActors do
    local Actor = self.ParallaxActors[i]
    if not self.BaseRelativeOffsets[i] then
      self.BaseRelativeOffsets[i] = Actor:K2_GetActorLocation()
    end
    Actor:K2_SetActorLocation(self.BaseRelativeOffsets[i] + Offset, false, nil, false)
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLobbyThemeParallaxManager = class(CModuleBase, nil, LobbyThemeParallaxManager)
return CLobbyThemeParallaxManager