local MontageCameraSubsystem = {}
MontageCameraSubsystem.CalculateMethod = {ByTrace = 1, ByVector = 2}
function MontageCameraSubsystem:OnInit()
  print(bWriteLog and "MontageCameraSubsystem:OnInit")
  self.ShowDebug = false
  self.Method = self.CalculateMethod.ByVector
  self.uCharacter = nil
  self.uController = nil
  self.bPlaying = false
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  self.Config = GamePlayTools.GetCurrentConfig("MontageCameraConfig")
end
function MontageCameraSubsystem:Play(LookAtLocation, Radius, Time, StopCallback)
  if self.bPlaying then
    print(bWriteLog and "MontageCameraSubsystem:Play, is Playing")
    return false
  end
  if self:IsPawnAttached() then
    print(bWriteLog and "MontageCameraSubsystem:Play, Pawn is Attached")
    return false
  end
  print(bWriteLog and "MontageCameraSubsystem:Play, LookAtLocation = " .. tostring(LookAtLocation:ToStringShort()) .. ", Radius = " .. tostring(Radius) .. ", Time = " .. tostring(Time) .. ", StopCallback = " .. tostring(StopCallback))
  local Result = false
  self.bPlaying = true
  self.TargetActorLocation = LookAtLocation
  self.Target  self.BlendTime = self:CalculateBlendTime(Time)
  self.  self:CreateTargetActor()
  local CameraLocation = self:CalculateCameraLocation()
  if CameraLocation then
    local Target = self:CreateViewTarget(CameraLocation)
    Result = self:MoveCameraToTarget(Target, self.BlendTime)
    if Result then
      self:AddGameTimer(self.BlendTime * 2, false, function()
        print(bWriteLog and "MontageCameraSubsystem:Play, set bPlaying = false")
        self.bPlaying = false
      end)
    else
      print(bWriteLog and "MontageCameraSubsystem:Play, set bPlaying = false")
      self.bPlaying = false
    end
  else
    print(bWriteLog and "MontageCameraSubsystem:Play, set bPlaying = false")
    self.bPlaying = false
  end
  return Result
end
function MontageCameraSubsystem:CalculateBlendTime(Time)
  if Time then
    return Time
  end
  local Pawn = self:GetMyPlayerPawn()
  local CurrentLocation = Pawn:K2_GetActorLocation()
  local Distance = FVector.Distance(CurrentLocation, self.TargetActorLocation)
  local CalculateTime = Distance / (self.Config.CameraMoveSpeed * 100)
  if CalculateTime < self.Config.MinimumTime then
    CalculateTime = self.Config.MinimumTime
  end
  print(bWriteLog and "MontageCameraSubsystem:CalculateBlendTime, Distance = " .. tostring(Distance) .. ", CalculateTime = " .. tostring(CalculateTime))
  return CalculateTime
end
function MontageCameraSubsystem:CreateTargetActor()
  if self.Method == self.CalculateMethod.ByVector then
    print(bWriteLog and "MontageCameraSubsystem:CreateTargetActor, ByVector")
    return
  end
  local NeedCreate = true
  if self.TargetActor and slua.isValid(self.TargetActor) then
    NeedCreate = false
    self.TargetActor:K2_SetActorLocation(self.TargetActorLocation, false, nil, true)
    self.TargetActor.Sphere.SphereRadius = self.TargetRadius
    print(bWriteLog and "MontageCameraSubsystem:CreateTargetActor, reuse")
    self:DrawDebugSphere(self.TargetActorLocation, self.TargetRadius, FLinearColor(1, 0, 0, 1), 30)
    return
  end
  self.TargetActor = nil
  local Path = self.Config.TargetActorPath
  local uWorld = CGameState:GetWorld()
  local ActorClass = slua.loadClass(Path)
  if uWorld and ActorClass then
    local Location = self.TargetActorLocation
    self.TargetActor = uWorld:SpawnActor(ActorClass, Location, FRotator(0, 0, 0), nil)
    if self.TargetActor then
      print(bWriteLog and "MontageCameraSubsystem:CreateTargetActor, succeeded")
      self.TargetActor.Sphere.SphereRadius = self.TargetRadius
      self:DrawDebugSphere(self.TargetActorLocation, self.TargetRadius, FLinearColor(1, 0, 0, 1), 30)
    else
      print(bWriteLog and "MontageCameraSubsystem:CreateTargetActor, failed")
    end
  else
    print(bWriteLog and "MontageCameraSubsystem:CreateTargetActor, uWorld = " .. tostring(uWorld) .. ", ActorClass = " .. tostring(ActorClass))
  end
end
function MontageCameraSubsystem:CalculateCameraLocation()
  if self.Method == self.CalculateMethod.ByVector then
    return self:CalculateLocationByVector()
  else
    return self:CalculateLocationByTrace()
  end
end
function MontageCameraSubsystem:CalculateLocationByTrace()
  local CameraLocation
  local uCharacter = self:GetMyPlayerPawn()
  if uCharacter and slua.isValid(uCharacter) then
    local Start = uCharacter:K2_GetActorLocation() + FVector(0, 0, self.Config.HalfHeight)
    local End = self.TargetActorLocation
    local KismetSystemLibrary = import("KismetSystemLibrary")
    local IgnoreActors = slua.Array(UEnums.EPropertyClass.Object, import("/Script/Engine.Actor"))
    IgnoreActors:Add(uCharacter)
    local ECollisionChannel = import("ECollisionChannel")
    local TraceType = Game:ConvertToTraceType(ECollisionChannel.ECC_GameTraceChannel2)
    local bHit, uHitResults = KismetSystemLibrary.LineTraceMulti(CGameState, Start, End, TraceType, false, IgnoreActors, 2, slua.Array(UEnums.EPropertyClass.Struct, import("/Script/Engine.HitResult")), false, FLinearColor.Green, FLinearColor.Red, 5)
    if bHit then
      local TargetActorClass = import(self.Config.TargetActorPath .. "_C")
      local Count = uHitResults:Num()
      local bHitTarget = false
      for i = 0, Count - 1 do
        print(bWriteLog and "MontageCameraSubsystem:CalculateLocationByTrace, i = " .. tostring(i))
        local uHitResult = uHitResults:Get(i)
        if Game:IsClassOf(uHitResult.Actor, TargetActorClass) then
          bHitTarget = true
          CameraLocation = FVector(uHitResult.ImpactPoint.X, uHitResult.ImpactPoint.Y, uHitResult.ImpactPoint.Z)
          break
        end
      end
      if bHitTarget then
        print(bWriteLog and "MontageCameraSubsystem:CalculateLocationByTrace, bHit = " .. tostring(bHit) .. ", Count = " .. tostring(Count) .. ", CameraLocation = " .. tostring(CameraLocation:ToStringShort()))
      else
        print(bWriteLog and "MontageCameraSubsystem:CalculateLocationByTrace, bHit = " .. tostring(bHit) .. ", Count = " .. tostring(Count) .. ", but bHitTarget = " .. tostring(bHitTarget))
      end
    else
      print(bWriteLog and "MontageCameraSubsystem:CalculateLocationByTrace, bHit = " .. tostring(bHit))
    end
  end
  return CameraLocation
end
function MontageCameraSubsystem:CalculateLocationByVector()
  local CameraLocation
  local uCharacter = self:GetMyPlayerPawn()
  if uCharacter and slua.isValid(uCharacter) then
    local Start = uCharacter:K2_GetActorLocation() + FVector(0, 0, self.Config.HalfHeight)
    local End = self.TargetActorLocation
    local _Vector = Start - End
    local Normalized_Vector = _Vector:GetSafeNormal(0.001)
    local Radius_Vector = Normalized_Vector * self.TargetRadius
    local Vector = End - Start
    Vector = Vector + Radius_Vector
    CameraLocation = Start + Vector
    self:DrawDebugSphere(self.TargetActorLocation, self.TargetRadius, FLinearColor(1, 0, 0, 1), 30)
  end
  print(bWriteLog and "MontageCameraSubsystem:CalculateLocationByVector, CameraLocation = " .. tostring(CameraLocation:ToStringShort()))
  return CameraLocation
end
function MontageCameraSubsystem:CreateViewTarget(Location)
  local NeedCreate = true
  if self.ViewActor and slua.isValid(self.ViewActor) then
    NeedCreate = false
    self.ViewActor:K2_SetActorLocation(Location, false, nil, true)
    local UKismetMathLibrary = import("KismetMathLibrary")
    local Rotation = UKismetMathLibrary.FindLookAtRotation(Location, self.TargetActorLocation)
    self.ViewActor:K2_SetActorRotation(Rotation, false)
    print(bWriteLog and "MontageCameraSubsystem:CreateViewTarget, reuse")
    self:DrawDebugSphere(Location, 50, FLinearColor(0, 1, 0, 1), 30)
    return self.ViewActor
  end
  self.ViewActor = nil
  local Path = self.Config.ViewActorPath
  local uWorld = CGameState:GetWorld()
  local ActorClass = slua.loadClass(Path)
  if uWorld and ActorClass then
    local UKismetMathLibrary = import("KismetMathLibrary")
    local Rotation = UKismetMathLibrary.FindLookAtRotation(Location, self.TargetActorLocation)
    self.ViewActor = uWorld:SpawnActor(ActorClass, Location, Rotation, nil)
    if self.ViewActor then
      print(bWriteLog and "MontageCameraSubsystem:CreateViewTarget, succeeded")
      self:DrawDebugSphere(Location, 50, FLinearColor(0, 1, 0, 1), 30)
    else
      print(bWriteLog and "MontageCameraSubsystem:CreateViewTarget, failed")
    end
  else
    print(bWriteLog and "MontageCameraSubsystem:CreateViewTarget, uWorld = " .. tostring(uWorld) .. ", ActorClass = " .. tostring(ActorClass))
  end
  return self.ViewActor
end
function MontageCameraSubsystem:MoveCameraToTarget(Target, Time, Exit)
  local Result = false
  if Target == nil or slua.isValid(Target) == false then
    print("MontageCameraSubsystem:MoveCameraToTarget, Target == nil")
    return Result
  end
  local uCharacter, uPlayerController = self:GetMyPlayerPawn()
  if uPlayerController then
    local ViewActorClass = import(self.Config.ViewActorPath .. "_C")
    if Game:IsClassOf(Target, ViewActorClass) then
      print("MontageCameraSubsystem:MoveCameraToTarget, ViewActor")
      self:TryExitSprintState(uPlayerController)
      self:EnableCharacterMovement(uCharacter, false)
      self:HiddenOrRecoveryUI(true, uPlayerController)
    elseif uCharacter:IsAlive() then
      print("MontageCameraSubsystem:MoveCameraToTarget, Character")
      local UKismetMathLibrary = import("KismetMathLibrary")
      local Rotation = UKismetMathLibrary.FindLookAtRotation(uCharacter:K2_GetActorLocation(), self.TargetActorLocation)
      uPlayerController:SetControlRotation(Rotation, "MontageCameraSubsystem")
      self:AddGameTimer(Time, false, function()
        print("MontageCameraSubsystem:MoveCameraToTarget, RecoverUI")
        self:EnableCharacterMovement(uCharacter, true)
        self:HiddenOrRecoveryUI(false, uPlayerController)
        if self.StopCallback and type(self.StopCallback) == "function" then
          self.StopCallback()
        end
      end)
    else
      print("MontageCameraSubsystem:MoveCameraToTarget, Character Dead")
      self:EnableCharacterMovement(uCharacter, true)
      self:HiddenOrRecoveryUI(false, uPlayerController)
      if self.StopCallback and type(self.StopCallback) == "function" then
        self.StopCallback()
      end
    end
    Result = true
    local EViewTargetBlendFunction = import("EViewTargetBlendFunction")
    uPlayerController:SetViewTargetWithBlend(Target, Time, EViewTargetBlendFunction.VTBlend_EaseInOut, 2, false)
    if not Exit then
      self:AddGameTimer(Time, false, function()
        self:MoveCameraToTarget(uCharacter, Time, true)
      end)
    end
  else
    print("MontageCameraSubsystem:MoveCameraToTarget, uPlayerController = nil")
  end
  return Result
end
function MontageCameraSubsystem:TryExitSprintState(uPlayerController)
  print(bWriteLog and "MontageCameraSubsystem:TryExitSprintState, bAutoSprint = " .. tostring(uPlayerController.bAutoSprint))
  if uPlayerController.bAutoSprint then
    uPlayerController.bAutoSprint = false
    local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
    if OperateSubsystem then
      OperateSubsystem:ActiveSprint()
    else
      uPlayerController:SetVirtualStickAutoSprintStatus(false)
    end
  end
end
function MontageCameraSubsystem:EnableCharacterMovement(uPlayerCharacter, bEnable)
  print(bWriteLog and "MontageCameraSubsystem:EnableCharacterMovement, bEnable = " .. tostring(bEnable) .. ", bClient = " .. tostring(Client ~= nil))
  if uPlayerCharacter and slua.isValid(uPlayerCharacter) then
    local uCharactersMovement = uPlayerCharacter.STCharacterMovement
    if Game:IsValid(uCharactersMovement) then
      if bEnable == false then
        local EMovementMode = import("EMovementMode")
        uCharactersMovement:StopMovementImmediately()
        if not Client then
          uCharactersMovement:SetMovementMode(EMovementMode.MOVE_None, 0)
        end
        uCharactersMovement:Deactivate()
      else
        local EMovementMode = import("EMovementMode")
        uCharactersMovement:SetMovementMode(EMovementMode.MOVE_Walking, 0)
        uCharactersMovement:Activate(true)
      end
    else
      print(bWriteLog and "MontageCameraSubsystem:EnableCharacterMovement, bEnable = " .. tostring(bEnable) .. ", uCharactersMovement = " .. tostring(uCharactersMovement))
    end
    uPlayerCharacter:SetReplicateMovement(bEnable)
  else
    print(bWriteLog and "MontageCameraSubsystem:EnableCharacterMovement, bEnable = " .. tostring(bEnable) .. ", uPlayerCharacter = " .. tostring(uPlayerCharacter))
  end
end
function MontageCameraSubsystem:HiddenOrRecoveryUI(bHidden, uPlayerController)
  local UAESequenceUtils = require("GameLua.Mod.BaseMod.GamePlay.SequenceMgr.UAESequenceUtils")
  if bHidden == true then
    UAESequenceUtils:HideAllUI()
  else
    UAESequenceUtils:RecoveryUI()
  end
  local hud = uPlayerController:GetHUD()
  if hud and slua.isValid(hud) then
    if bHidden == true then
      hud.bShowHUD = false
    else
      hud.bShowHUD = true
    end
  end
end
function MontageCameraSubsystem:DrawDebugSphere(Center, Radius, Color, Duration)
  if not self.ShowDebug then
    return
  end
  if Client and Client.IsDevelopment() then
    if Center then
      print(bWriteLog and "MontageCameraSubsystem:DrawDebugSphere, Center = " .. tostring(Center:ToStringShort()))
      local UKismetSystemLibrary = import("KismetSystemLibrary")
      UKismetSystemLibrary.DrawDebugSphere(CGameState, Center, Radius, 12, Color or FLinearColor(1, 0, 0, 1), Duration or 10, 10)
    else
      print(bWriteLog and "MontageCameraSubsystem:DrawDebugSphere, Center = nil")
    end
  end
end
function MontageCameraSubsystem:GetMyPlayerPawn()
  if slua.isValid(self.uCharacter) and slua.isValid(self.uController) then
    return self.uCharacter, self.uController
  end
  self.uCharacter = nil
  self.uController = nil
  local uCharacter = true
  local UGameplayStatics = import("GameplayStatics")
  local uPlayerController = UGameplayStatics.GetPlayerController(CGameState, 0)
  if uPlayerController and slua.isValid(uPlayerController) then
    if uPlayerController.GetPlayerCharacterSafety then
      uCharacter = uPlayerController:GetPlayerCharacterSafety()
      if uCharacter and slua.isValid(uCharacter) then
        self.        self.uController = uPlayerController
      end
    else
      print(bWriteLog and "MontageCameraSubsystem:GetMyPlayerPawn, have no function GetPlayerCharacterSafety, PlayerKey = " .. tostring(uPlayerController.PlayerKey))
    end
  else
    print(bWriteLog and "MontageCameraSubsystem:GetMyPlayerPawn, uPlayerController = nil")
  end
  print(bWriteLog and "MontageCameraSubsystem:GetMyPlayerPawn, PlayerKey = " .. tostring(self.uCharacter and self.uCharacter.PlayerKey) .. ", uCharacter = " .. tostring(self.uCharacter))
  return self.uCharacter, self.uController
end
function MontageCameraSubsystem:IsPawnAttached()
  local Result = false
  local Pawn = self:GetMyPlayerPawn()
  if Pawn and slua.isValid(Pawn) then
    local ParentActor = Pawn:GetAttachParentActor()
    if ParentActor then
      Result = true
      print(bWriteLog and "MontageCameraSubsystem:IsPawnAttached, ParentActor = " .. tostring(ParentActor))
    end
    if Result == false and slua.isValid(Pawn.RootComponent) then
      local AttachParent = Pawn.RootComponent:GetAttachParent()
      if AttachParent then
        Result = true
        print(bWriteLog and "MontageCameraSubsystem:IsPawnAttached, AttachParent = " .. tostring(AttachParent))
      end
    end
  else
    Result = true
    print(bWriteLog and "MontageCameraSubsystem:IsPawnAttached, Pawn = nil")
  end
  return Result
end
function MontageCameraSubsystem:DestroyRelativeActors()
  if self.TargetActor and slua.isValid(self.TargetActor) then
    self.TargetActor:K2_DestroyActor()
    self.TargetActor = nil
    print(bWriteLog and "MontageCameraSubsystem:DestroyRelativeActors, TargetActor")
  end
  if self.ViewActor and slua.isValid(self.ViewActor) then
    self.ViewActor:K2_DestroyActor()
    self.ViewActor = nil
    print(bWriteLog and "MontageCameraSubsystem:DestroyRelativeActors, ViewActor")
  end
end
function MontageCameraSubsystem:OnRelease()
  print(bWriteLog and "MontageCameraSubsystem:OnRelease")
  self:DestroyRelativeActors()
  MontageCameraSubsystem.__super.OnRelease(self)
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, MontageCameraSubsystem)