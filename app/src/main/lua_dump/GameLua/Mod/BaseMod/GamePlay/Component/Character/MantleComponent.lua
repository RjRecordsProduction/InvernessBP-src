local MantleComponent = {}
local ENetRole = import("ENetRole")
local ECoopVaultRole = import("ECoopVaultRole")
local ECoopVaultStage = import("ECoopVaultStage")
local UGameplayStatics = import("GameplayStatics")
local EGameModeCPPType = import("EGameModeType")
local ESTEPoseState = import("ESTEPoseState")
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
function MantleComponent:ReceiveBeginPlay()
  if not Client then
    self.bServerTickCheckCrossWall = true
  end
  self:ChangeVauleByMapType()
  if CGameState and slua.isValid(CGameState) then
    self.bTPlanMod = CGameState.GameModeType == EGameModeCPPType.EXAndT
    if self.bTPlanMod then
      self.bCheckNoCharacterBelow = true
    end
    print(bWriteLog and "MantleComponent:ReceiveBeginPlay TPlan " .. tostring(self.bTPlanMod))
    self.bTDM = CGameState.GameModeType == EGameModeCPPType.EDeathMatchGameMode
    print(bWriteLog and "MantleComponent:ReceiveBeginPlay TDM " .. tostring(self.bTDM))
  end
  self.CachedRegularMaxDis = self.MaxCheckDis
  self.CachedRegularMaxHeight = self.MaxCheckHeight
  print(bWriteLog and "MantleComponent:ReceiveBeginPlay self.ServerCheckMaxTickTime = 2")
  if Client then
    self:AddControlEvent(self, "OnLiftVaultSatisfied", self.HandleNearbyCoopCharacterChanged, self)
    self:AddControlEvent(self, "OnPullVaultSatisfied", self.HandleNearbyCoopCharacterChanged, self)
    self:AddControlEvent(self, "OnCoopVaultTriggerChanged", self.HandleCheckCoopVaultStateChanged, self)
  end
  if not Client then
    self:AddGameTimer(2.0, false, function()
      self:AddCooperationVaultItem()
    end)
  end
end
function MantleComponent:ReceiveEndPlay(EndPlayReason)
  if Client then
    self:RemoveControlEvent(self, "OnLiftVaultSatisfied")
    self:RemoveControlEvent(self, "OnPullVaultSatisfied")
    self:RemoveControlEvent(self, "OnCoopVaultTriggerChanged")
  end
  MantleComponent.__super.ReceiveEndPlay(self, EndPlayReason)
end
function MantleComponent:ChangeVauleByMapType()
  print(bWriteLog and "MantleComponent:ChangeVauleByMapType")
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local MapType = GameMainConfig.GetMapType()
  if MapType == "Neon" then
    self.ForwardMaxCheckHeight = 200
    self.JumpOverMinHeightDiff = 30
  end
end
function MantleComponent:ReceiveStartVault()
  if slua.isValid(self.PlayerPawn) then
    if self.PlayerPawn.Role == ENetRole.ROLE_Authority then
      self.PlayerPawn:SetReplicateMovement(false)
    else
      self.PlayerPawn.bReplicateMovement = false
    end
  end
  if slua.isValid(self.PlayerPawn) and self.PlayerPawn.Role == ENetRole.ROLE_SimulatedProxy then
    local CharMovementComp = self.PlayerPawn.CharacterMovement
    if slua.isValid(CharMovementComp) and not self:VaultFollowBase() then
      CharMovementComp.bAbandonReplicatedMovement = true
    end
  end
  if slua.isValid(self.PlayerPawn) and slua.isValid(self.PlayerPawn.STCharacterMovement) and self.PlayerPawn.Role == ENetRole.ROLE_SimulatedProxy then
    self.PlayerPawn.STCharacterMovement:SetClientReceiveServerStateTimestamp(UGameplayStatics.GetTimeSeconds(CGameWorld))
  end
  if slua.isValid(self.PlayerPawn) and self.PlayerPawn.Role == ENetRole.ROLE_AutonomousProxy then
    local CurWeapon = self.PlayerPawn:GetCurrentWeapon()
    local WeaponManager = self.PlayerPawn:GetWeaponManager()
    local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
    if slua.isValid(WeaponManager) then
      WeaponManager:SetNextUseWeaponSlot(ESurviveWeaponPropSlot.SWPS_None)
    end
    if slua.isValid(CurWeapon) and slua.isValid(WeaponManager) and CurWeapon:GetWeaponEntityComponent() and not CurWeapon:GetWeaponEntityComponent().bEnableVaultHolding then
      local Slot = WeaponManager:GetCurrentUsingPropSlot()
      self.PlayerPawn:SwitchWeaponBySlot(ESurviveWeaponPropSlot.SWPS_None, false, false, true)
      WeaponManager:SetNextUseWeaponSlot(Slot)
    end
  end
  if slua.isValid(self.PlayerPawn) and self.PlayerPawn.Role == ENetRole.ROLE_Authority and self.NowVaultData.IsJump then
    local uPlayerState = self.PlayerPawn:GetPlayerStateSafety()
    if slua.isValid(uPlayerState) then
      uPlayerState:AddGeneralCount(804, 1, false)
      print(bWriteLog and "MantleComponent:ReceiveStartVault Record Tlog")
    end
  end
  if not self.bTPlanMod and slua.isValid(self.PlayerPawn) and self.PlayerPawn.Role == ENetRole.ROLE_Authority and not self:VaultFollowBase() then
    local uPlayerState = self.PlayerPawn:GetPlayerStateSafety()
    if slua.isValid(uPlayerState) then
      local nPing = uPlayerState.Ping * 4
      if nPing < 250 then
        self:DisableMovementModeCheck(true)
        self:DisableVaultModeCheck(true)
      end
    end
  end
  if slua.isValid(self.PlayerPawn) and self.PlayerPawn.Role == ENetRole.ROLE_AutonomousProxy then
    self.LastVaultCheckFlag = 0
    self.OnVaultCheckFlagChange:BroadCast(false)
  end
  if slua.isValid(self.PlayerPawn) and self.PlayerPawn.Role == ENetRole.ROLE_Authority then
    local CharMovementComp = self.PlayerPawn.CharacterMovement
    if slua.isValid(CharMovementComp) then
      CharMovementComp.bServerMoveCheckPassWall = false
      CharMovementComp.bForbiddenDragOnGround = true
    end
  end
  if slua.isValid(self.PlayerPawn) then
    local uAnimBP = self.PlayerPawn:GetExtraAnimInstanceBase(false)
    if slua.isValid(uAnimBP) then
      uAnimBP.C_MaxFallingSpeed = 0
    end
  end
  if slua.isValid(self.PlayerPawn) then
    self:ToggleCheckOverlapVehicle(true)
  end
  if Client and self.bTDM and slua.isValid(self.PlayerPawn) then
    local uMesh = self.PlayerPawn.Mesh
    if slua.isValid(uMesh) then
      print(bWriteLog and "MantleComponent:ReceiveStartVault NeedUpdateEveryFrame true")
      uMesh.NeedUpdateEveryFrame = true
    end
  end
  if self.DelayStuckCheckTimer then
    self:RemoveGameTimer(self.DelayStuckCheckTimer)
    self.DelayStuckCheckTimer = nil
  end
end
function MantleComponent:ReceiveEndVault()
  if slua.isValid(self.PlayerPawn) and self.PlayerPawn.Role == ENetRole.ROLE_SimulatedProxy then
    local CharMovementComp = self.PlayerPawn.CharacterMovement
    if slua.isValid(CharMovementComp) then
      CharMovementComp.bAbandonReplicatedMovement = false
    end
  end
  if slua.isValid(self.PlayerPawn) and self.PlayerPawn.Role == ENetRole.ROLE_AutonomousProxy then
    local WeaponManager = self.PlayerPawn:GetWeaponManager()
    if slua.isValid(WeaponManager) then
      local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
      if WeaponManager:GetNextUseWeaponSlot() ~= ESurviveWeaponPropSlot.SWPS_None then
        self.PlayerPawn:SwitchWeaponBySlot(WeaponManager:GetNextUseWeaponSlot(), true, true, false)
        WeaponManager:SetNextUseWeaponSlot(ESurviveWeaponPropSlot.SWPS_None)
      end
    end
  end
  self:DisableMovementModeCheck(false)
  self:AddGameTimer(0.2, false, function()
    self:DisableVaultModeCheck(false)
  end)
  if slua.isValid(self.PlayerPawn) then
    if self.PlayerPawn.Role == ENetRole.ROLE_Authority then
      self.PlayerPawn:SetReplicateMovement(true)
      if slua.isValid(self.PlayerPawn.STCharacterMovement) then
        self.PlayerPawn.STCharacterMovement.Velocity.X = 0.1
        self.PlayerPawn.STCharacterMovement:Activate(false)
        self.PlayerPawn.STCharacterMovement:FakeLastServerMoveTime()
      end
      self.PlayerPawn:ForceNetUpdate()
    else
      self.PlayerPawn.bReplicateMovement = true
      if slua.isValid(self.PlayerPawn.STCharacterMovement) then
        self.PlayerPawn.STCharacterMovement:Activate(false)
      end
    end
  end
  if slua.isValid(self.PlayerPawn) and slua.isValid(self.PlayerPawn.STCharacterMovement) and self.PlayerPawn.Role == ENetRole.ROLE_SimulatedProxy then
    self.PlayerPawn.STCharacterMovement:SetClientReceiveServerStateTimestamp(UGameplayStatics.GetTimeSeconds(CGameWorld))
  end
  if slua.isValid(self.PlayerPawn) then
    self.PlayerPawn:StopAnimMontage(self.VaultMontage)
  end
  if slua.isValid(self.PlayerPawn) and self.PlayerPawn.Role == ENetRole.ROLE_Authority then
    local CharMovementComp = self.PlayerPawn.CharacterMovement
    if slua.isValid(CharMovementComp) then
      CharMovementComp.bServerMoveCheckPassWall = true
      CharMovementComp.bForbiddenDragOnGround = false
    end
  end
  if slua.isValid(self.PlayerPawn) then
    self:ToggleCheckOverlapVehicle(false)
  end
  if Client and self.bTDM and slua.isValid(self.PlayerPawn) then
    local uMesh = self.PlayerPawn.Mesh
    if slua.isValid(uMesh) then
      print(bWriteLog and "MantleComponent:ReceiveStartVault NeedUpdateEveryFrame false")
      uMesh.NeedUpdateEveryFrame = false
    end
  end
  self:PlayerStuckCheckAndResolve()
  self:DelayPlayerStuckCheckAndResolve()
  self:NotifyEndVault()
end
function MantleComponent:PlayerStuckCheckAndResolve()
  if not Client and slua.isValid(self.PlayerPawn) then
    local USTExtraGameplayStatics = import("STExtraGameplayStatics")
    local Actor = import("/Script/Engine.Actor")
    local ActorsToIgnore = slua.Array(UEnums.EPropertyClass.Object, Actor)
    ActorsToIgnore:Add(self.PlayerPawn)
    local InLocation = self.PlayerPawn:K2_GetActorLocation()
    local InRotation = self.PlayerPawn:K2_GetActorRotation()
    local CheckHalfHeight = 60
    local STExtraHouseActor = import("/Script/ShadowTrackerExtra.STExtraHouseActor")
    if Game:IsClassOf(self.VaultingActor, STExtraHouseActor) and self.NowVaultData.IsJump then
      CheckHalfHeight = 75
    end
    local bBlockingHit = USTExtraGameplayStatics.CapsuleOverlapBlockingTestByProfile(CGameWorld, InLocation, InRotation, "Pawn", 25, CheckHalfHeight, ActorsToIgnore)
    if bBlockingHit then
      local FResolvePenetrationParams = import("/Script/ShadowTrackerExtra.ResolvePenetrationParams")
      local SafetyResolveParams = FResolvePenetrationParams()
      slua.IndexReference(SafetyResolveParams, "OverlapIgnoreActors"):Add(self.PlayerPawn)
      slua.IndexReference(SafetyResolveParams, "PassWallIgnoreActors"):Add(self.PlayerPawn)
      SafetyResolveParams.bLineTracePassWall = true
      SafetyResolveParams.AdjustMaxHeight = 60
      local bFound = false
      local uNoPassWallLocation = FVector(0, 0, 0)
      if not self.IsInStopVaulting then
        local CheckLocation = InLocation - self.WorldVaultDir * 5
        bFound, uNoPassWallLocation = self.PlayerPawn:FindActorLocationSafetyWithParams(uNoPassWallLocation, CheckLocation, SafetyResolveParams)
      end
      if bFound then
        print(bWriteLog and "MantleComponent:ReceiveEndVault Set Actor To Safety Backward Location.")
        self.PlayerPawn:SetActorLocationSafetyWithParams(uNoPassWallLocation, SafetyResolveParams)
      else
        local CheckLocation = InLocation
        bFound, uNoPassWallLocation = self.PlayerPawn:FindActorLocationSafetyWithParams(uNoPassWallLocation, CheckLocation, SafetyResolveParams)
        if bFound then
          print(bWriteLog and "MantleComponent:ReceiveEndVault Set Actor To Safety Forward Location.")
          self.PlayerPawn:SetActorLocationSafetyWithParams(uNoPassWallLocation, SafetyResolveParams)
        elseif self.BeforeVaultPosition and not self:VaultFollowBase() then
          print(bWriteLog and "MantleComponent:ReceiveEndVault Set Actor To Before Location.")
          self.PlayerPawn:K2_SetActorLocation(self.BeforeVaultPosition, false, nil, false)
        end
      end
    end
  end
end
function MantleComponent:DelayPlayerStuckCheckAndResolve()
  if self.DelayStuckCheckTimer then
    self:RemoveGameTimer(self.DelayStuckCheckTimer)
    self.DelayStuckCheckTimer = nil
  end
  if not slua.isValid(self.PlayerPawn) then
    return
  end
  self.RecordEndVaultLocation = self.PlayerPawn:K2_GetActorLocation()
  self.DelayStuckCheckTimer = self:AddGameTimer(0.5, false, function()
    if not slua.isValid(self.PlayerPawn) then
      return
    end
    local uCharacterMovement = self.PlayerPawn.STCharacterMovement
    if not slua.isValid(uCharacterMovement) then
      return
    end
    if not uCharacterMovement:IsWalking() then
      return
    end
    local CurLocation = self.PlayerPawn:K2_GetActorLocation()
    if self.RecordEndVaultLocation and (self.RecordEndVaultLocation - CurLocation):Size() < 100 then
      self:PlayerStuckCheckAndResolve()
    end
  end)
end
function MantleComponent:DisableMovementModeCheck(bDisable)
  if bDisable then
    if slua.isValid(self.PlayerPawn) and self.PlayerPawn.Role == ENetRole.ROLE_Authority then
      print(bWriteLog and "MantleComponent:DisableMovementModeCheck bIgnoreClientMovementModeErrorChecks", bDisable)
      local CharMovementComp = self.PlayerPawn.CharacterMovement
      if slua.isValid(CharMovementComp) then
        CharMovementComp.bIgnoreClientMovementModeErrorChecks = true
      end
    end
  elseif slua.isValid(self.PlayerPawn) and self.PlayerPawn.Role == ENetRole.ROLE_Authority then
    print(bWriteLog and "MantleComponent:DisableMovementModeCheck bIgnoreClientMovementModeErrorChecks", bDisable)
    local CharMovementComp = self.PlayerPawn.CharacterMovement
    if slua.isValid(CharMovementComp) then
      CharMovementComp.bIgnoreClientMovementModeErrorChecks = false
    end
  end
end
function MantleComponent:DisableVaultModeCheck(bDisable)
  if bDisable then
    if slua.isValid(self.PlayerPawn) and self.PlayerPawn.Role == ENetRole.ROLE_Authority then
      print(bWriteLog and "MantleComponent:DisableMovementModeCheck bIgnoreClientMovementModeVaultChecks", bDisable)
      local CharMovementComp = self.PlayerPawn.CharacterMovement
      if slua.isValid(CharMovementComp) then
        CharMovementComp.bIgnoreClientMovementModeVaultChecks = true
      end
    end
  elseif slua.isValid(self.PlayerPawn) and self.PlayerPawn.Role == ENetRole.ROLE_Authority then
    print(bWriteLog and "MantleComponent:DisableMovementModeCheck bIgnoreClientMovementModeVaultChecks", bDisable)
    local CharMovementComp = self.PlayerPawn.CharacterMovement
    if slua.isValid(CharMovementComp) then
      CharMovementComp.bIgnoreClientMovementModeVaultChecks = false
    end
  end
end
function MantleComponent:ToggleCheckOverlapVehicle(bStart)
  if bStart then
    if self.NowVaultData.forceStartSync then
      self.bVaultingStop = false
    else
      self.bVaultingStop = true
    end
    self.CheckOverlapVehicleTimer = self:AddGameTimer(0.3, false, function()
      self.bVaultingStop = true
      self.CheckOverlapVehicleTimer = nil
    end)
  else
    self.bVaultingStop = true
    if self.CheckOverlapVehicleTimer then
      self:RemoveGameTimer(self.CheckOverlapVehicleTimer)
      self.CheckOverlapVehicleTimer = nil
    end
  end
end
function MantleComponent:AddCooperationVaultItem()
  if not slua.isValid(self.Object) then
    return
  end
  local uCharacterOwner = self:GetOwner()
  if not slua.isValid(uCharacterOwner) then
    return
  end
  if not uCharacterOwner:HasAuthority() then
    return
  end
  if CGameState and CGameState:IsCreativeMode() then
    self.bEnableCoopVault = false
    return
  end
  if self.bTPlanMod then
    self.bEnableCoopVault = false
    return
  end
  if CGameState and slua.isValid(CGameState) and CGameState.GameModeType ~= EGameModeCPPType.ETypicalGameMode and CGameState.GameModeType ~= EGameModeCPPType.EHeavyWeaponGameMode and CGameState.GameModeType ~= EGameModeCPPType.EFourInOneGameMode then
    self.bEnableCoopVault = false
    return
  end
  if not self.bEnableCoopVault then
    return
  end
  if Game:AddItemByResID(uCharacterOwner, 602420, 1, false, 0, -1, 0, false) then
    print(bWriteLog and "MantleComponent:AddCooperationVaultItem Success")
  end
  if uCharacterOwner:HasAuthority() then
    local uController = uCharacterOwner:GetPlayerControllerSafety()
    if slua.isValid(uController) then
      self:AddControlEvent(uController, "PlayerControllerLostDelegate", function()
        local EPawnState = import("EPawnState")
        if slua.isValid(self.PlayerPawn) and self.PlayerPawn:HasState(EPawnState.CoopVaultPrepare) then
          print(bWriteLog and "MantleComponent:PlayerControllerLostDelegate EndCooperationVault")
          self:EndCooperationVault()
        end
      end)
    end
  end
end
function MantleComponent:HandleCheckCoopVaultStateChanged(Role)
  EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_COOPVAULT_UI_TRIGGER_STATE_CHANGED, false, Role)
end
function MantleComponent:TriggerCooperationVault()
  if not slua.isValid(self.PlayerPawn) then
    return
  end
  local bPreCheck = false
  local FailReason = 0
  if self.PlayerPawn.PoseState ~= ESTEPoseState.Crouch and self.PlayerPawn.PoseState ~= ESTEPoseState.Stand then
    self:OnFailedCooperationVault(ECoopVaultRole.Unknown, 1)
    return
  end
  bPreCheck, FailReason = self:CheckCooperationVault(ECoopVaultRole.Puller, FailReason)
  if bPreCheck then
    self:StartCooperationVault(ECoopVaultRole.Puller)
  else
    bPreCheck, FailReason = self:CheckCooperationVault(ECoopVaultRole.Lifter, FailReason)
    if bPreCheck then
      self:StartCooperationVault(ECoopVaultRole.Lifter)
    end
  end
  if bPreCheck then
    local CharMovementComp = self.PlayerPawn.CharacterMovement
    if slua.isValid(CharMovementComp) then
      CharMovementComp.Velocity = FVector(0, 0, 0)
    end
  else
    self:OnFailedCooperationVault(ECoopVaultRole.Unknown, FailReason)
  end
end
function MantleComponent:ReceiveCooperationVault()
  local bPreCheck = false
  local FailReason = 0
  bPreCheck, FailReason = self:CheckCooperationVault(ECoopVaultRole.Jumper, FailReason)
  if bPreCheck then
    self:StartCooperationVault(ECoopVaultRole.Jumper)
  else
    bPreCheck, FailReason = self:CheckCooperationVault(ECoopVaultRole.Climber, FailReason)
    if bPreCheck then
      self:StartCooperationVault(ECoopVaultRole.Climber)
    end
  end
  if not bPreCheck then
    self:OnFailedCooperationVault(ECoopVaultRole.Unknown, FailReason)
  end
end
function MantleComponent:LuaOnEnterCoopVault(Role, NewStage)
  if not slua.isValid(self.PlayerPawn) then
    return
  end
  print(bWriteLog and "MantleComponent:LuaOnEnterCoopVault")
  if slua.isValid(self.PlayerPawn) then
    self.PlayerPawn.bAllowToInteract = false
  end
  if slua.isValid(self.PlayerPawn) and self.PlayerPawn.Role == ENetRole.ROLE_AutonomousProxy and (Role == ECoopVaultRole.Jumper or Role == ECoopVaultRole.Climber) then
    local WeaponManager = self.PlayerPawn:GetWeaponManager()
    if slua.isValid(WeaponManager) then
      local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
      local Slot = WeaponManager:GetCurrentUsingPropSlot()
      self.PlayerPawn:SwitchWeaponBySlot(ESurviveWeaponPropSlot.SWPS_None, false, false, true)
      WeaponManager:SetNextUseWeaponSlot(Slot)
    end
  end
  if self.PlayerPawn.Role == ENetRole.ROLE_AutonomousProxy then
    EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_COOPVAULT_UI_TRIGGER_STATE_CHANGED, true, Role)
  end
  if Client and (Role == ECoopVaultRole.Lifter or Role == ECoopVaultRole.Puller) then
    self:SendCoopVaultReadyChat()
  end
  if Server and self.PlayerPawn:HasAuthority() and (Role == ECoopVaultRole.Jumper or Role == ECoopVaultRole.Climber) then
    local uSelfPlayerState = self.PlayerPawn:GetPlayerStateSafety()
    if self.CoopVaultState and slua.isValid(self.CoopVaultState.CoopCharacter) then
      local uPartnerPlayerState = self.CoopVaultState.CoopCharacter:GetPlayerStateSafety()
      if slua.isValid(uSelfPlayerState) and slua.isValid(uPartnerPlayerState) then
        EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_PLAYER_INTERACTIVE_BEHAVIOR, uSelfPlayerState.UID, uPartnerPlayerState.UID, "CoopVault")
      end
    end
  end
end
function MantleComponent:LuaOnLeaveCoopVault(Role, OldStage)
  if not slua.isValid(self.PlayerPawn) then
    return
  end
  print(bWriteLog and "MantleComponent:LuaOnLeaveCoopVault")
  if slua.isValid(self.PlayerPawn) then
    self.PlayerPawn.bAllowToInteract = true
  end
  self:DisableMovementModeCheck(false)
  if slua.isValid(self.PlayerPawn) and self.PlayerPawn.Role == ENetRole.ROLE_AutonomousProxy then
    if Role == ECoopVaultRole.Climber then
      local WeaponManager = self.PlayerPawn:GetWeaponManager()
      if slua.isValid(WeaponManager) then
        local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
        if WeaponManager:GetNextUseWeaponSlot() ~= ESurviveWeaponPropSlot.SWPS_None then
          self.PlayerPawn:SwitchWeaponBySlot(WeaponManager:GetNextUseWeaponSlot(), true, true, false)
          WeaponManager:SetNextUseWeaponSlot(ESurviveWeaponPropSlot.SWPS_None)
        end
      end
    end
    if Role == ECoopVaultRole.Jumper and slua.isValid(self.PlayerPawn.STCharacterMovement) and self.PlayerPawn.STCharacterMovement:IsFalling() then
      self:AddCharacterFirstLandedDelegate()
    end
  end
  if self.PlayerPawn.Role == ENetRole.ROLE_AutonomousProxy then
    EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_COOPVAULT_UI_TRIGGER_STATE_CHANGED, false, Role)
  end
end
function MantleComponent:LuaHandleCoopVaultStageChanged(Role, OldStage, NewStage)
  if not slua.isValid(self.PlayerPawn) then
    return
  end
  if self.PlayerPawn:HasAuthority() then
    if Role == ECoopVaultRole.Puller and NewStage == ECoopVaultStage.Pull_Ready then
      self:RefreshPullPositionTimer(true)
    else
      self:RefreshPullPositionTimer(false)
    end
  end
  if self.PlayerPawn:HasAuthority() then
    local uPlayerState = self.PlayerPawn:GetPlayerStateSafety()
    if slua.isValid(uPlayerState) then
      if Role == ECoopVaultRole.Lifter and NewStage == ECoopVaultStage.Lift_Preparing then
        uPlayerState:AddGeneralCount(1965, 1, false)
      end
      if Role == ECoopVaultRole.Puller and NewStage == ECoopVaultStage.Pull_Preparing then
        uPlayerState:AddGeneralCount(1966, 1, false)
      end
      if Role == ECoopVaultRole.Lifter and NewStage == ECoopVaultStage.Lift_Boosting then
        uPlayerState:AddGeneralCount(1967, 1, false)
      end
      if Role == ECoopVaultRole.Puller and NewStage == ECoopVaultStage.Pull_Leap then
        uPlayerState:AddGeneralCount(1968, 1, false)
      end
      if Role == ECoopVaultRole.Jumper and NewStage == ECoopVaultStage.Lift_Boosting then
        uPlayerState:AddGeneralCount(1969, 1, false)
      end
      if Role == ECoopVaultRole.Climber and NewStage == ECoopVaultStage.Pull_Leap then
        uPlayerState:AddGeneralCount(1970, 1, false)
      end
    end
  end
end
function MantleComponent:RefreshPullPositionTimer(bEnable)
  if bEnable then
    if self.RefreshPullerTimer then
      self:RemoveGameTimer(self.RefreshPullerTimer)
      self.RefreshPullerTimer = nil
    end
    self.RefreshPullerTimer = self:AddGameTimer(1.5, true, function()
      if self.CoopVaultState and self.CoopVaultState.Role == ECoopVaultRole.Puller and self.CoopVaultState.Stage == ECoopVaultStage.Pull_Ready then
        local bValid = self:RefreshPullerPositionData()
      end
    end)
  elseif self.RefreshPullerTimer then
    self:RemoveGameTimer(self.RefreshPullerTimer)
    self.RefreshPullerTimer = nil
  end
end
function MantleComponent:OnFailedCooperationVault(Role, Reason)
  print(bWriteLog and "MantleComponent:OnFailedCooperationVault " .. tostring(Reason))
  local nTextID = 81558
  if Reason == 1 then
    nTextID = 81558
  elseif Reason == 2 then
    nTextID = 81559
  elseif Reason == 3 then
    nTextID = 81559
  elseif Reason == 4 then
    nTextID = 81561
  end
  if Client then
    IngameTipsTools.BattleNormalTipsByTextID(nTextID)
  else
    Game:UIShowTips(self.PlayerPawn.PlayerKey, nTextID)
  end
end
function MantleComponent:HandleCharacterFirstLanded()
  local WeaponManager = self.PlayerPawn:GetWeaponManager()
  if slua.isValid(WeaponManager) then
    local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
    if WeaponManager:GetNextUseWeaponSlot() ~= ESurviveWeaponPropSlot.SWPS_None then
      self.PlayerPawn:SwitchWeaponBySlot(WeaponManager:GetNextUseWeaponSlot(), true, true, false)
      WeaponManager:SetNextUseWeaponSlot(ESurviveWeaponPropSlot.SWPS_None)
    end
  end
end
function MantleComponent:ShouldShowCoopVaultButton()
  if slua.isValid(self.NearbyLifter) or slua.isValid(self.NearbyPuller) then
    return true
  end
  if self.CoopVaultState and self.CoopVaultState.Role == ECoopVaultRole.Jumper then
    return true
  end
end
function MantleComponent:HandleNearbyCoopCharacterChanged()
  if Client then
    print(bWriteLog and "MantleComponent:HandleNearbyCoopCharacterChanged")
    local CoopVaultBtn = UIManager.GetUI(UIManager.UI_Config.CoopVaultBtn)
    if self:ShouldShowCoopVaultButton() then
      print(bWriteLog and "MantleComponent:HandleNearbyCoopCharacterChanged Show CoopVaultBtn")
      if CoopVaultBtn then
        CoopVaultBtn:SelfHitTestInvisible()
      else
        UIManager.ShowUI(UIManager.UI_Config.CoopVaultBtn)
      end
    else
      print(bWriteLog and "MantleComponent:HandleNearbyCoopCharacterChanged Hide CoopVaultBtn")
      if CoopVaultBtn then
        CoopVaultBtn:Collapsed()
      end
    end
  end
end
function MantleComponent:SendCoopVaultReadyChat()
  local LocalController = GameplayData.GetPlayerController()
  if slua.isValid(LocalController) and slua.isValid(self.PlayerPawn) then
    if self.PlayerPawn.TeamID ~= LocalController.TeamID then
      return
    end
    local ESpectatorReplayFlag = import("ESpectatorReplayFlag")
    if LocalController:HasAnySpectatorReplayFlag(ESpectatorReplayFlag.ESpectatorReplayFlag_HawkEye | ESpectatorReplayFlag.ESpectatorReplayFlag_CompletePlayback) then
      return
    end
    local bIsSelf = false
    local uOwnerController = self.PlayerPawn:GetController()
    if slua.isValid(uOwnerController) and uOwnerController == LocalController then
      bIsSelf = true
    end
    local ChatComponent = LocalController:GetChatComponent()
    local sMsgString = LocUtil.GetLocalizeResStr(81553)
    local sMsgContent = "<ChatQuickMsg>" .. sMsgString .. "</>"
    local PlayerName = self.PlayerPawn:GetPlayerNameSafety()
    local NewName = "***"
    if bIsSelf then
      local EGameReplayType = import("EGameReplayType")
      if slua.isValid(LocalController) and LocalController.GameReplayType == EGameReplayType.EGameReplayType_CompletePlayback then
        NewName = "Reported Player"
        return "<ChatSelfName>" .. NewName .. LocUtil.GetLocalizeResStr(4164) .. "</>" .. sMsgContent
      end
      sMsgContent = "<ChatSelfName>" .. LocUtil.GetLocalizeResStr(101717) .. LocUtil.GetLocalizeResStr(4164) .. "</>" .. sMsgContent
    else
      local EGameReplayType = import("EGameReplayType")
      if slua.isValid(LocalController) and LocalController.GameReplayType == EGameReplayType.EGameReplayType_CompletePlayback then
        if PlayerName == "Teammate 1" or PlayerName == "Teammate 2" or PlayerName == "Teammate 3" or PlayerName == "Teammate 4" then
          NewName = PlayerName
        end
        sMsgContent = "<ChatOtherName>" .. NewName .. LocUtil.GetLocalizeResStr(4164) .. "</>" .. sMsgContent
      end
      sMsgContent = "<ChatOtherName>" .. PlayerName .. LocUtil.GetLocalizeResStr(4164) .. "</>" .. sMsgContent
    end
    ChatComponent.addToUIText = sMsgContent
    ChatComponent:AddOneMsgToUIInner(false)
  end
end
local Class = require("class")
local Object = require("GameLua.Mod.BaseMod.GamePlay.Component.XComponent")
local CMantleComponent = Class(Object, nil, MantleComponent)
return CMantleComponent