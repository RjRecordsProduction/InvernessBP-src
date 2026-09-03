local EPawnState = import("EPawnState")
local EMovementMode = import("EMovementMode")
local ECustomMovmentMode = import("ECustomMovmentMode")
local ESpecialMovementType = import("ESpecialMovementType")
local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
local ESplineCoordinateSpace = import("ESplineCoordinateSpace")
local ECollisionChannel = import("ECollisionChannel")
local ECollisionEnabled = import("ECollisionEnabled")
local ECollisionResponse = import("ECollisionResponse")
local FHitResult = import("/Script/Engine.HitResult")
local STExtraBaseCharacterClass = import("/Script/ShadowTrackerExtra.STExtraBaseCharacter")
local KismetSystemLibrary = import("KismetSystemLibrary")
local util = require("client.slua_ui_framework.util")
local ZiplineUtil = require("GameLua.Mod.Library.GamePlay.Actor.Zipline.ZiplineUtil")
local ActorTools = require("GameLua.Mod.BaseMod.Common.ActorTools")
local CharacterLifterControlFeature = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {}
}
local Config = {
  TickInterval = 0.033,
  BaseVelocity = 500,
  CannotEnterTipsId = 69565,
  PulleyClassPath = "/Game/Mod/EvoBase/Arts_PlayerBluePrints/Lifter/BP_LifterPulley.BP_LifterPulley",
  LiftControlAnimInstancePath = "/Game/Arts_Player/Characters/Animation/Base_AnimBP/Feature/CH_Base_AnimBP_LifterControl.CH_Base_AnimBP_LifterControl_C",
  Audio = {
    Enter = "/Game/WwiseEvent/Character_Action_new/Play_Char_Action_Lift_Start.Play_Char_Action_Lift_Start",
    Leave = "/Game/WwiseEvent/Character_Action_new/Play_Char_Action_Lift_Stop.Play_Char_Action_Lift_Stop",
    Moving = "/Game/WwiseEvent/Character_Action_new/Play_Char_Action_Lift_Loop.Play_Char_Action_Lift_Loop",
    MovingStop = "/Game/WwiseEvent/Character_Action_new/Stop_Char_Action_Lift_Loop.Stop_Char_Action_Lift_Loop"
  },
  CheckWeaponSkillId = 1014405
}
function CharacterLifterControlFeature:ctor()
  self.bSwitchedWeapon = false
  self.nWeaponSlot = 0
  self.SplineDistance = 0
  self.bUp = true
end
function CharacterLifterControlFeature:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  return {
    {
      "UsingLifter",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Object
    },
    {
      "MoveState",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    }
  }
end
function CharacterLifterControlFeature:ReceiveBeginPlay()
  CharacterLifterControlFeature.__super.ReceiveBeginPlay(self)
  print(bWriteLog and string.format("CharacterLifterControlFeature:ReceiveBeginPlay"))
  self.MoveState = 0
  if self:HasAuthority() then
    self.PreIsFPPRecords = {}
    if slua.isValid(self.Owner.NearDeatchComponent) then
      self:AddControlEvent(self.Owner.NearDeatchComponent, "OnEnterNearDeathState", self.OnPawnNearDeath, self)
    end
    self:AddControlEvent(self.Owner, "OnDeathDelegate", self.OnDeath, self)
  else
    self:AddCommonEvent(EVENTTYPE_INGAME_REPLAY, EVENTID_INIT_REPLAYUI, self.OnInitReplayUI, self)
    self.BeginPlayCheckTimer = self:AddGameTimer(0.1, false, function()
      if slua.isValid(self.Owner.Object) then
        local IsEnter = self:IsUsingLifter()
        self:SetControllerState(self.Owner.Object, IsEnter)
      end
    end)
  end
end
function CharacterLifterControlFeature:ReceiveEndPlay(EndPlayReason)
  print(bWriteLog and string.format("CharacterLifterControlFeature:ReceiveEndPlay"))
  self:TryRemoveNamedGameTimer("BeginPlayCheckTimer")
  self:TryRemoveNamedGameTimer("CheckMovementBlockTimer")
  CharacterLifterControlFeature.__super.ReceiveEndPlay(self, EndPlayReason)
end
function CharacterLifterControlFeature:OnPawnNearDeath()
  if self.UsingLifter then
    print(bWriteLog and string.format("CharacterLifterControlFeature:OnPawnNearDeath %s leave lifter", self.Owner:ToString()))
    self:SetLocalUsingLifter(nil)
  end
end
function CharacterLifterControlFeature:OnDeath()
  if self.UsingLifter then
    print(bWriteLog and string.format("CharacterLifterControlFeature:OnDeath %s leave lifter", self.Owner:ToString()))
    self:SetLocalUsingLifter(nil)
  end
end
function CharacterLifterControlFeature:OnCharacterDiedPre(_, __, uKilledPawn)
  if not slua.isValid(uKilledPawn) or uKilledPawn.PlayerKey ~= self.Owner.PlayerKey then
    return
  end
  if self.UsingLifter then
    print(bWriteLog and string.format("CharacterLifterControlFeature:OnCharacterDiedPre %s leave lifter", self.Owner:ToString()))
    self:SetLocalUsingLifter(nil)
  end
end
function CharacterLifterControlFeature:EnterLifter(Lifter)
  local uSkillManagerComp = self.Owner:GetSkillManager()
  if not slua.isValid(uSkillManagerComp) then
    return false
  end
  if uSkillManagerComp:IsCastingSkillID(Config.CheckWeaponSkillId) then
    print(bWriteLog and string.format("CharacterLifterControlFeature:EnterLifter %s enter failed (IsCastingSkillIDFix CheckWeaponSkill)", self.Owner:ToString()))
    return false
  end
  local UTSkillStopReason = import("UTSkillStopReason")
  uSkillManagerComp:StopSkillAll(UTSkillStopReason.SkillStopReason_Interrupted)
  local bUsed = self:SetLocalUsingLifter(Lifter)
  if not Client then
    self.DistanceCheckTimer = self:AddGameTimer(0.5, true, function()
      if self.Owner and slua.isValid(Lifter.Object) then
        local PlayerLoc = self.Owner:K2_GetActorLocation()
        local LifterLoc = Lifter:K2_GetActorLocation()
        local Dis = (PlayerLoc - LifterLoc):Size2D()
        if 1000 < Dis then
          self:ServerRPC_ExitLifter()
        end
      end
    end)
  end
  return bUsed
end
function CharacterLifterControlFeature:RequestExitLifter()
  self:ServerRPC_ExitLifter()
end
CharacterLifterControlFeature.ServerRPC.ServerRPC_ExitLifter = {
  Reliable = true,
  Params = {}
}
function CharacterLifterControlFeature:ServerRPC_ExitLifter()
  if not self:HasAuthority() then
    return
  end
  if not slua.isValid(self.UsingLifter) then
    return
  end
  print(bWriteLog and string.format("CharacterLifterControlFeature:ServerRPC_ExitLifter"))
  self:SetLocalUsingLifter(nil)
end
function CharacterLifterControlFeature:OnRep_UsingLifter()
  print(bWriteLog and string.format("CharacterLifterControlFeature:OnRep_UsingLifter %s", self.UsingLifter))
  if self.UsingLifter ~= nil and not self:IsLifterClass(self.UsingLifter) then
    print(bWriteLog and string.format("CharacterLifterControlFeature:OnRep_UsingLifter self.UsingLifter is not Lifter (SHOULD NOT HAPPENED), return"))
    return
  end
  if self.UsingLifter ~= nil then
    self.LastUsingLifter = self.UsingLifter
  end
  self:SetLocalUsingLifter(self.UsingLifter)
  if self.UsingLifter then
    self:AddControlEvent(self.Owner, "MovementModeChangedDelegate", self.HandleOnMovementModeChanged, self)
  else
    self:RemoveControlEvent(self.Owner, "MovementModeChangedDelegate")
  end
  self:CheckCameraBlocker()
  local audio_util = require("client.common.audio_util")
  local AudioAssetPath = self.UsingLifter ~= nil and Config.Audio.Enter or Config.Audio.Leave
  audio_util.PlayAudioByActorAsync(AudioAssetPath, self.Owner.Object, nil, true)
end
function CharacterLifterControlFeature:HandleOnMovementModeChanged(Character, PrevMovementMode, PreviousCustomMode)
  print(bWriteLog and string.format("CharacterLifterControlFeature:HandleOnMovementModeChanged %s %s", PrevMovementMode, PreviousCustomMode))
  local IsEnter = self:IsUsingLifter()
  self:SetMovementMode(IsEnter, self.UsingLifter)
end
function CharacterLifterControlFeature:HandleMovementBaseChanged(uCharacter, uNewBase, uOldBase)
  if uNewBase ~= nil then
    self:ServerRPC_ExitLifter()
  end
end
function CharacterLifterControlFeature:SetLocalUsingLifter(Lifter)
  local IsEnter = Lifter ~= nil
  print(bWriteLog and string.format("CharacterLifterControlFeature:SetLocalUsingLifter %s IsEnter = %s", self.Owner:ToString(), IsEnter))
  if self:HasAuthority() then
    if IsEnter and not self:TestCanTeleportToEnterPoint(Lifter) then
      print(bWriteLog and string.format("CharacterLifterControlFeature:SetLocalUsingLifter %s enter failed (NOT TestCanTeleportToEnterPoint)", self.Owner:ToString()))
      Game:UIShowTips(self.Owner.PlayerKey, Config.CannotEnterTipsId)
      return false
    end
    self.Using    if self.UsingLifter then
      self.LastUsingLifter = self.UsingLifter
    end
    if not IsEnter then
      self.MoveState = 0
    end
    if not self.bUp and not self.LandingPointLocation then
      self:SetOverlappedAnchor(2)
    end
  else
    self:CheckPulley(IsEnter)
  end
  self:SetMovementMode(IsEnter, Lifter)
  self:SetCollision(IsEnter)
  self:SetControllerState(self.Owner.Object, IsEnter)
  self:CheckTeleport(IsEnter)
  self:ForceNetUpdate()
  if not IsEnter and self.DistanceCheckTimer then
    self:RemoveGameTimer(self.DistanceCheckTimer)
    self.DistanceCheckTimer = nil
  end
  return true
end
function CharacterLifterControlFeature:SetMovementMode(IsEnter, Lifter)
  local MoveObj = self:GetMoveObj()
  if not slua.isValid(MoveObj) then
    return
  end
  if self:HasAuthority() then
    if IsEnter then
      self:AddControlEvent(self.Owner, "OnMovementBaseChanged", self.HandleMovementBaseChanged, self)
    else
      self:RemoveControlEvent(self.Owner, "HandleMovementBaseChanged")
    end
  end
  if IsEnter then
    MoveObj:Enter()
    if Lifter and slua.isValid(Lifter.Spline) then
      local MinZ = math.floor(Lifter.Spline:GetLocationAtSplinePoint(0, ESplineCoordinateSpace.World).Z)
      local MaxZ = math.floor(Lifter.Spline:GetLocationAtSplinePoint(1, ESplineCoordinateSpace.World).Z)
      self.      self.      MoveObj:Setup(Config.BaseVelocity, MinZ, MaxZ)
      print(bWriteLog and string.format("CharacterLifterControlFeature:SetMovementMode MoveObj:Setup(%d, %d, %d)", Config.BaseVelocity, MinZ, MaxZ))
    else
      print(bWriteLog and string.format("CharacterLifterControlFeature:SetMovementMode Lifter or Lifter.Spline is not valid"))
    end
  else
    MoveObj:Leave()
  end
  if self:HasAuthority() then
    local MovementComponent = self.Owner.STCharacterMovement
    if slua.isValid(MovementComponent) then
      MovementComponent.bServerMoveCheckPassWall = not IsEnter
      print(bWriteLog and string.format("CharacterLifterControlFeature:SetMovementMode MovementComponent.bServerMoveCheckPassWall = %s", MovementComponent.bServerMoveCheckPassWall))
    end
  end
end
function CharacterLifterControlFeature:SetLiftControlInstance(bActive)
  local uAnimParamsComp = self.Owner:GetAnimParamsComponent()
  if not slua.isValid(uAnimParamsComp) then
    print(bWriteLog and "CharacterLifterControlFeature:SetLiftControlInstance, uAnimParamsComp not found!")
    return
  end
  if bActive then
    util.GetAssetAsync(Config.LiftControlAnimInstancePath, function(LoadedAnimInstance)
      if slua.isValid(self.Owner.Object) and slua.isValid(LoadedAnimInstance) and slua.isValid(uAnimParamsComp) then
        uAnimParamsComp:ActiveAnimContainerWithInstance("AC.LiftControl", LoadedAnimInstance, false)
        print(bWriteLog and "CharacterLifterControlFeature:SetLiftControlInstance, Active LiftControl SubInstance")
      else
        print(bWriteLog and "CharacterLifterControlFeature:SetLiftControlInstance, AnimClass invalid!")
      end
    end)
  else
    uAnimParamsComp:DeactiveAnimContainerWithInstance("AC.LiftControl", nil, false)
    print(bWriteLog and "CharacterLifterControlFeature:SetLiftControlInstance, Deactive LiftControl SubInstance")
  end
end
function CharacterLifterControlFeature:CheckTeleport(IsEnter)
  if IsEnter then
    local Lifter = self.UsingLifter
    local Dir = Lifter:GetActorRightVector()
    local ReverseDir = FVector(-Dir.X, -Dir.Y, -Dir.Z)
    local Rotation = ReverseDir:ToOrientationRotator()
    local Location = self:GetClosestSplineLocation(Lifter)
    if self:HasAuthority() then
      Game:TeleportPawn(self.Owner.Object, Location, Rotation, false, false, false, true)
    else
      self.Owner:K2_SetActorRotation(Rotation, true)
      self.Owner:SetActorLocationSafety(Location)
    end
  else
    local OwnerLocation = self.Owner:K2_GetActorLocation()
    local IsHealthyAlive = self.Owner:IsHealthyAlive()
    print(bWriteLog and string.format("CharacterLifterControlFeature:CheckTeleport OwnerLocation = %s, IsHealthyAlive = %s", OwnerLocation:ToString(), IsHealthyAlive))
    if IsHealthyAlive then
      if self.LandingPointLocation and self.LandingPointRotation then
        local Location = self.LandingPointLocation + FVector(0, 0, 50)
        print(bWriteLog and string.format("CharacterLifterControlFeature:CheckTeleport LandingPointLocation = %s -> %s", self.LandingPointLocation:ToString(), Location:ToString()))
        if self:HasAuthority() then
          Game:TeleportPawn(self.Owner.Object, Location, self.LandingPointRotation, false, false, false, true)
        else
          self.Owner:K2_SetActorRotation(self.LandingPointRotation, true)
          self.Owner:SetActorLocationSafety(Location)
        end
      else
        local Dir = slua.isValid(self.LastUsingLifter) and self.LastUsingLifter:GetActorRightVector() or FVector(1, 0, 0)
        local LeavingLocation = OwnerLocation + Dir * 50
        self.Owner:SetActorLocationSafety(LeavingLocation)
      end
    else
      local Dir = slua.isValid(self.LastUsingLifter) and self.LastUsingLifter:GetActorRightVector() or FVector(1, 0, 0)
      local LeavingLocation = OwnerLocation + Dir * 50
      self.Owner:SetActorLocationSafety(LeavingLocation)
    end
  end
end
function CharacterLifterControlFeature:SetCollision(IsEnter)
  if slua.isValid(self.Owner.CapsuleComponent) then
    local CollisionResponse = IsEnter == true and ECollisionResponse.ECR_Ignore or ECollisionResponse.ECR_Block
    self.Owner.CapsuleComponent:SetCollisionResponseToChannel(ECollisionChannel.ECC_WorldStatic, CollisionResponse)
  end
end
function CharacterLifterControlFeature:CheckPulley(IsEnter)
  if IsEnter then
    if not self.PulleyActor then
      self.PulleyActor = ActorTools.SpawnActor(self.Owner.Object, Config.PulleyClassPath, self.Owner:K2_GetActorLocation(), self.Owner:K2_GetActorRotation(), FVector.OneVector)
      self.PulleyActor:K2_AttachToComponent(self.Owner.Mesh, "None", 2, 2, 1, false)
      self.PulleyActor.Pulley:K2_SetRelativeLocationAndRotation(FVector(0, 0, 88), FRotator.ZeroRotator, false, nil, false)
      self.PulleyActor.ParticleSystem:SetVisibility(false, true)
      print(bWriteLog and string.format("CharacterLifterControlFeature:CheckPulley create %s", self.PulleyActor))
    end
  elseif slua.isValid(self.PulleyActor) then
    print(bWriteLog and string.format("CharacterLifterControlFeature:CheckPulley destroy %s", self.PulleyActor))
    self.PulleyActor:K2_DestroyActor()
    self.PulleyActor = nil
  end
end
function CharacterLifterControlFeature:TestCanTeleportToEnterPoint(Lifter)
  local EnterPointLocation = self:GetClosestSplineLocation(Lifter)
  local ActorClass = import("/Script/Engine.Actor")
  local ActorsToIgnore = slua.Array(UEnums.EPropertyClass.Object, ActorClass)
  ActorsToIgnore:Add(self.Owner.Object)
  local CapsuleComponent = self.Owner.CapsuleComponent
  local bHit, uOverlapObjectsArr = KismetSystemLibrary.CapsuleOverlapActors(CGameMode, EnterPointLocation, CapsuleComponent.CapsuleRadius, CapsuleComponent.CapsuleHalfHeight, {
    ECollisionChannel.ECC_Pawn
  }, STExtraBaseCharacterClass, ActorsToIgnore, nil)
  if uOverlapObjectsArr:Num() <= 0 then
    return true
  end
  return false
end
function CharacterLifterControlFeature:GetClosestSplineLocation(Lifter)
  if not slua.isValid(Lifter.Object) or not slua.isValid(Lifter.Spline) then
    return FVector.ZeroVector
  end
  local CurLoc = self.Owner:K2_GetActorLocation()
  local ClosetLoc = Lifter.Spline:FindLocationClosestToWorldLocation(CurLoc, ESplineCoordinateSpace.World)
  return ClosetLoc
end
function CharacterLifterControlFeature:SetOverlappedAnchor(AnchorLabel)
  if AnchorLabel == 2 and slua.isValid(self.UsingLifter) and slua.isValid(self.UsingLifter.LandingPointUpper) then
    self.LandingPointLocation = self.UsingLifter.LandingPointUpper:K2_GetComponentLocation()
    self.LandingPointRotation = self.UsingLifter.LandingPointUpper:K2_GetComponentRotation()
  else
    self.LandingPointLocation = nil
    self.LandingPointRotation = nil
  end
  print(bWriteLog and string.format("CharacterLifterControlFeature:SetOverlappedAnchor %s LandingPointLocation = %s", AnchorLabel, self.LandingPointLocation ~= nil and self.LandingPointLocation:ToString() or "nil"))
end
function CharacterLifterControlFeature:RequestSlideLifter(IsUp, IsActive)
  self:ServerRPC_SlideLifter(IsUp, IsActive)
  self:TryRemoveNamedGameTimer("HeartbeatSlideRPCTimer")
  if IsActive then
    self.HeartbeatSlideRPCTimer = self:AddGameTimer(1, true, function()
      self:ServerRPC_SlideLifter(IsUp, IsActive)
    end)
  end
end
CharacterLifterControlFeature.ServerRPC.ServerRPC_SlideLifter = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Bool,
    UEnums.EPropertyClass.Bool
  }
}
function CharacterLifterControlFeature:ServerRPC_SlideLifter(IsUp, IsActive)
  self:LocalSetMoveState(IsUp, IsActive)
end
function CharacterLifterControlFeature:LocalSetMoveState(IsUp, IsActive)
  if not slua.isValid(self.UsingLifter) then
    return
  end
  local NewMoveState = 0
  if IsActive then
    NewMoveState = IsUp == true and 1 or -1
  else
    NewMoveState = 0
  end
  print(bWriteLog and string.format("CharacterLifterControlFeature:LocalSetMoveState IsUp = %s, IsActive = %s", IsUp, IsActive))
  self.MoveState = NewMoveState
  self:ForceNetUpdate()
  self:RefreshMoveObjMoveState()
  if self:HasAuthority() then
    self:TryRemoveNamedGameTimer("StopMoveStateTimer")
    if IsActive then
      self.StopMoveStateTimer = self:AddGameTimer(2, false, function()
        print(bWriteLog and string.format("CharacterLifterControlFeature:LocalSetMoveState %s StopMoveStateTimer timeout", self.Owner:ToString()))
        self.MoveState = 0
        self:ForceNetUpdate()
        self:RefreshMoveObjMoveState()
      end)
    end
  end
end
function CharacterLifterControlFeature:OnRep_MoveState()
  print(bWriteLog and string.format("CharacterLifterControlFeature:OnRep_MoveState MoveState = %s", self.MoveState))
  self:RefreshMoveObjMoveState()
  self:TryRemoveNamedGameTimer("CheckMovementBlockTimer")
  if self.MoveState ~= 0 and not self:IsMovementBlock() then
    self:PlayMovingAudio(true)
    self.CheckMovementBlockTimer = self:AddGameTimer(0.1, true, function()
      if self:IsMovementBlock() then
        print(bWriteLog and string.format("CharacterLifterControlFeature:OnRep_MoveState MovementBlock"))
        self:PlayMovingAudio(false)
        self:TryRemoveNamedGameTimer("CheckMovementBlockTimer")
      end
    end)
  else
    self:PlayMovingAudio(false)
  end
end
function CharacterLifterControlFeature:RefreshMoveObjMoveState()
  local MoveObj = self:GetMoveObj()
  if slua.isValid(MoveObj) then
    MoveObj:SetMoveState(self.MoveState)
  end
end
function CharacterLifterControlFeature:GetMoveObj()
  local MovementComponent = self.Owner.STCharacterMovement
  if not slua.isValid(MovementComponent) then
    return
  end
  local MoveObj = MovementComponent:GetSpecialMoveObjBySpecialMoveType(ESpecialMovementType.SPECIAL_MOVE_LifterControl)
  return MoveObj
end
function CharacterLifterControlFeature:IsMovementBlock()
  if self.MoveState == 0 then
    return false
  end
  if not slua.isValid(self.Owner.STCharacterMovement) then
    return false
  end
  if self.Owner.STCharacterMovement.Velocity.Z == 0 then
    return true
  end
  local OldLocation = self.Owner:K2_GetActorLocation()
  local NewLocation = OldLocation + self.Owner.STCharacterMovement.Velocity.Z * 0.033
  if self.MinZ and self.MaxZ and (NewLocation.Z > self.MaxZ or NewLocation.Z < self.MinZ) then
    return true
  end
  return false
end
function CharacterLifterControlFeature:PlayMovingAudio(IsMoving)
  local audio_util = require("client.common.audio_util")
  local AudioPath = IsMoving == true and Config.Audio.Moving or Config.Audio.MovingStop
  audio_util.PlayAudioByActorAsync(AudioPath, self.Owner.Object, nil, true)
end
function CharacterLifterControlFeature:SetControllerState(uCharacter, IsEnter)
  if IsEnter then
    uCharacter:EnterState(EPawnState.InZipline)
  elseif uCharacter:HasState(EPawnState.InZipline) then
    uCharacter:LeaveState(EPawnState.InZipline)
  end
  if Client then
    if self.Owner:IsLocallyControlled() or self.Owner:IsLocalViewed() then
      uCharacter.bUseControllerRotationYaw = not IsEnter
      self:ForceTPP(IsEnter)
      print(bWriteLog and string.format("CharacterLifterControlFeature:SetControllerState 1 %s IsEnter = %s", self.Owner:ToString(), IsEnter))
    end
    if self.Owner:IsLocallyControlled() then
      EventSystem:postEvent(EVENTTYPE_PLAYEREVENT_CHARACTER, EVENTTYPE_PLAYEREVENT_LIFTER_CONTROL_STATE_CHANGED, IsEnter)
      print(bWriteLog and string.format("CharacterLifterControlFeature:SetControllerState 2 %s IsEnter = %s", self.Owner:ToString(), IsEnter))
    end
    self:EnsureCameraLag(IsEnter)
    self:SetLiftControlInstance(IsEnter)
  else
    uCharacter.bUseControllerRotationYaw = not IsEnter
    self:ForceTPP(IsEnter)
    self:CharacterSwitchWeapon(IsEnter)
    ZiplineUtil.EnablePet(uCharacter, not IsEnter)
  end
end
function CharacterLifterControlFeature:EnsureCameraLag(IsEnter)
  if self.Owner:IsLocallyControlled() or self.Owner:IsLocalViewed() then
    local SpringArmComp = self.Owner.SpringArmComp
    if slua.isValid(SpringArmComp) then
      SpringArmComp.bEnableCameraLag = not IsEnter
      print(bWriteLog and string.format("CharacterLifterControlFeature:EnsureCameraLag SpringArmComp.bEnableCameraLag = %s", SpringArmComp.bEnableCameraLag))
    end
  end
end
function CharacterLifterControlFeature:CharacterSwitchWeapon(IsEnter)
  if IsEnter then
    if not self.bSwitchedWeapon then
      self.bSwitchedWeapon = true
      local uWeaponManager = self.Owner:GetWeaponManager()
      self.nWeaponSlot = uWeaponManager:GetCurrentUsingPropSlot()
      self.Owner:SwitchWeaponBySlot(ESurviveWeaponPropSlot.SWPS_None, false, true, true)
    end
  else
    if self.bSwitchedWeapon then
      self.Owner:SwitchWeaponBySlot(self.nWeaponSlot, false, true, true)
    end
    self.bSwitchedWeapon = false
  end
end
function CharacterLifterControlFeature:ForceTPP(IsEnter)
  local IsFPPGameMode = CGameState ~= nil and CGameState.IsFPPGameMode
  local uCharacter = self.Owner
  local PlayerKey = uCharacter.PlayerKey
  if IsFPPGameMode then
    if not Client then
      print(bWriteLog and string.format("CharacterLifterControlFeature:ForceTPP [DS] IsFPPGameMode = %s, IsEnter = %s", IsFPPGameMode, IsEnter))
      if IsEnter then
        self.PreIsFPPRecords[PlayerKey] = uCharacter.IsNetFPP
        uCharacter.IsNetFPP = false
      elseif self.PreIsFPPRecords[PlayerKey] ~= nil then
        uCharacter.IsNetFPP = self.PreIsFPPRecords[PlayerKey]
      else
        uCharacter.IsNetFPP = IsFPPGameMode
      end
      uCharacter:ForceNetUpdate()
    end
  elseif Client then
    print(bWriteLog and string.format("CharacterLifterControlFeature:ForceTPP [Client] IsFPPGameMode = %s, IsEnter = %s", IsFPPGameMode, IsEnter))
    if IsEnter and uCharacter:GetIsFPP() then
      uCharacter:SetCurrentPersonPerspective(false, true)
      self.bChangedPP = true
    end
    if not IsEnter then
      if self.bChangedPP then
        uCharacter:SetCurrentPersonPerspective(true, true)
      end
      self.bChangedPP = false
    end
  end
end
function CharacterLifterControlFeature:IsUsingLifter()
  return self.UsingLifter ~= nil and self:IsLifterClass(self.UsingLifter)
end
function CharacterLifterControlFeature:IsLifterClass(UsingLifter)
  if UsingLifter == nil then
    return false
  end
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local MapType = GameMainConfig.GetMapType()
  if MapType == "Neon" then
    local CNeonLifter = import("/Game/Mod/Neon/BluePrints/Actor/BP_Ascender.BP_Ascender_C")
    return Game:IsClassOf(UsingLifter, CNeonLifter)
  else
    local CLifter = import("/Game/Mod/EvoBase/Arts_PlayerBluePrints/Lifter/BP_ControllableLifter.BP_ControllableLifter_C")
    return Game:IsClassOf(UsingLifter, CLifter)
  end
end
function CharacterLifterControlFeature:OnInitReplayUI()
  local IsOwnerLocalViewed = self.Owner.IsLocalViewed ~= nil and self.Owner:IsLocalViewed()
  print(bWriteLog and string.format("CharacterLifterControlFeature:OnInitReplayUI IsOwnerLocalViewed = %s", IsOwnerLocalViewed))
  if IsOwnerLocalViewed then
    UIManager.HideUI(UIManager.UI_Config_InGame.LifterControlPanel)
  end
end
function CharacterLifterControlFeature:CheckCameraBlocker()
  if self:IsAutonomousProxy() then
    local IsEnter = self:IsUsingLifter()
    local CheckLifter = self.LastUsingLifter
    if slua.isValid(CheckLifter) and slua.isValid(CheckLifter.CameraSpringArmBlocker) then
      local Collision = IsEnter == true and ECollisionEnabled.QueryOnly or ECollisionEnabled.NoCollision
      print(bWriteLog and string.format("CharacterLifterControlFeature:CheckCameraBlocker SetCollisionEnabled(%s)", Collision))
      CheckLifter.CameraSpringArmBlocker:SetCollisionEnabled(Collision)
    end
  end
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
local CCharacterLifterControlFeature = class(CFeatureBase, nil, CharacterLifterControlFeature)
return require("combine_class").SetFeatureDynamic(CCharacterLifterControlFeature)