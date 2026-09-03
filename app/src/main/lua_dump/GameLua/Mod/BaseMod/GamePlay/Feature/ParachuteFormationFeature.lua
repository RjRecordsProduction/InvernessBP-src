local ParachuteFormationFeature = {
  ServerRPC = {},
  ClientRPC = {},
  LuaEventContainer = {
    "OnFormationStateChanged"
  }
}
local EParachuteState = import("EParachuteState")
local EFollowState = import("EFollowState")
local EJumpFromPlaneType = import("EJumpFromPlaneType")
local UGameplayStatics = import("GameplayStatics")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local FormationConfig = {
  DSSwitchID = 120,
  DSSwitchID_Spread = 121,
  bEnabled = true,
  bFormationEnabled = true,
  bSpreadEnabled = true,
  bCameraEnabled = true,
  bVFormationEnabled = true,
  FormationFOVMultiplier = 1.18,
  FormationCameraTransitionTime = 0,
  FormationCameraTransitionTickInterval = 0.016,
  FormationCameraLagSpeed = 0,
  Opening = {ArmLengthAdd = 100.0, RelativeLocationZAdd = 0.0},
  FreeFall = {ArmLengthAdd = 250.0, RelativeLocationZAdd = -10.0},
  TacticalSpreadPushedTipID = 12400
}
function ParachuteFormationFeature:ctor()
  print(bWriteLog and "ParachuteFormationFeature:ctor")
  self.bInFormation = false
  self.CameraTransitionTimer = nil
  self.nFormationState = 0
  self.nSwitchFlags = 0
  self.bFormationCameraApplied = false
  self.AppliedStateConfig = nil
end
local IsFormationFollowState = function(FollowState)
  return FollowState == EFollowState.Leader or FollowState == EFollowState.Follower
end
function ParachuteFormationFeature:ApplyFormationCameraForCurrentState(uCharacter)
  local OwnerCharacter = uCharacter or self:GetOwnerCharacter()
  if not slua.isValid(OwnerCharacter) or not self:ShouldApplyFormationCamera() then
    return
  end
  local ParachuteState = OwnerCharacter.ParachuteState
  if ParachuteState == EParachuteState.PS_Opening then
    OwnerCharacter:SwitchCameraToParachuteOpening()
    print(bWriteLog and "ParachuteFormationFeature:ApplyFormationCameraForCurrentState - Applied opening camera")
  elseif ParachuteState == EParachuteState.PS_FreeFall then
    OwnerCharacter:SwitchCameraToParachuteFalling()
    print(bWriteLog and "ParachuteFormationFeature:ApplyFormationCameraForCurrentState - Applied freefall camera")
  end
end
function ParachuteFormationFeature:RefreshClientFormationStateFromOwner(bApplyCamera)
  if not Client then
    return
  end
  local uCharacter = self:GetOwnerCharacter()
  if not slua.isValid(uCharacter) then
    return
  end
  if not self:IsSwitchEnabled("bFormationEnabled") then
    self.bInFormation = false
    if self.bFormationCameraApplied then
      self:RestoreCameraViaReInvoke()
    end
    return
  end
  local bWasInFormation = self.bInFormation
  local bShouldBeInFormation = IsFormationFollowState(uCharacter.FollowState)
  self.bInFormation = bShouldBeInFormation
  if bShouldBeInFormation and bApplyCamera and (not bWasInFormation or not self.bFormationCameraApplied) then
    self:ApplyFormationCameraForCurrentState(uCharacter)
  elseif not bShouldBeInFormation and self.bFormationCameraApplied then
    self:RestoreCameraViaReInvoke()
  end
end
function ParachuteFormationFeature:GetOwnerCharacter()
  if self.Owner and slua.isValid(self.Owner.Object) then
    return self.Owner.Object
  end
  return nil
end
function ParachuteFormationFeature:GetOwnerPlayerController()
  local uCharacter = self:GetOwnerCharacter()
  if slua.isValid(uCharacter) then
    return uCharacter:GetPlayerControllerSafety()
  end
  return nil
end
function ParachuteFormationFeature:IsVehicleParachuteEnabled()
  local uCharacter = self:GetOwnerCharacter()
  if not slua.isValid(uCharacter) then
    return false
  end
  local uPC = uCharacter:GetPlayerControllerSafety()
  if not slua.isValid(uPC) then
    return false
  end
  local CGameMode = GameplayData.GetGameMode()
  if not slua.isValid(CGameMode) or not slua.isValid(CGameMode.TeamModeComponent) then
    local VehicleInfo = uPC:GetParachutingVehicleInfo()
    if VehicleInfo and 0 < #VehicleInfo then
      print(bWriteLog and "ParachuteFormationFeature:IsVehicleParachuteEnabled - Self has vehicle parachute (no TeamModeComponent)")
      return true
    end
    return false
  end
  local TeamID = uPC.TeamID
  local Members = CGameMode.TeamModeComponent:GetTeamates(TeamID)
  if not Members then
    local VehicleInfo = uPC:GetParachutingVehicleInfo()
    if VehicleInfo and 0 < #VehicleInfo then
      print(bWriteLog and "ParachuteFormationFeature:IsVehicleParachuteEnabled - Self has vehicle parachute (no Members)")
      return true
    end
    return false
  end
  for _, uPlayerState in pairs(Members) do
    if slua.isValid(uPlayerState) then
      local uMemberPawn = uPlayerState:GetPlayerCharacter()
      if slua.isValid(uMemberPawn) then
        local uMemberPC = uMemberPawn:GetPlayerControllerSafety()
        if slua.isValid(uMemberPC) and uMemberPC.GetParachutingVehicleInfo then
          local VehicleInfo = uMemberPC:GetParachutingVehicleInfo()
          if VehicleInfo and 0 < #VehicleInfo then
            print(bWriteLog and string.format("ParachuteFormationFeature:IsVehicleParachuteEnabled - Teammate has vehicle parachute, UID=%s", tostring(uPlayerState.UID or "unknown")))
            return true
          end
        end
      end
    end
  end
  return false
end
function ParachuteFormationFeature:ReceiveBeginPlay()
  ParachuteFormationFeature.__super.ReceiveBeginPlay(self)
  print(bWriteLog and "ParachuteFormationFeature:ReceiveBeginPlay")
  local uCharacter = self:GetOwnerCharacter()
  if not slua.isValid(uCharacter) then
    return
  end
  if self:HasAuthority() then
    self:LoadSwitchesFromConfig()
    print(bWriteLog and string.format("ParachuteFormationFeature:ReceiveBeginPlay - DS: Loaded switches, nSwitchFlags=0x%X", self.nSwitchFlags))
    self:SyncSwitchesToCpp()
    self:AddControlEvent(uCharacter, "OnFollowStateChanged", self.OnFollowStateChanged, self)
    print(bWriteLog and "ParachuteFormationFeature:ReceiveBeginPlay - Server: Registered follow state listener")
    self:AddCommonEventWithConditions(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, {
      [1] = "FightingState"
    }, self.OnEnterFightingStateCheckVehicleParachute, self)
    print(bWriteLog and "ParachuteFormationFeature:ReceiveBeginPlay - DS: Registered FightingState listener for vehicle parachute check")
  end
  if Client then
    self:SyncSwitchesToCpp()
    self:AddControlEvent(uCharacter, "OnFollowStateChanged", self.OnClientFollowStateChanged, self)
    self:RefreshClientFormationStateFromOwner(true)
    print(bWriteLog and "ParachuteFormationFeature:ReceiveBeginPlay - Client: Registered follow state listener and refreshed formation state")
  end
end
function ParachuteFormationFeature:ReceivePossessed(InController)
  print(bWriteLog and "ParachuteFormationFeature:ReceivePossessed")
  if not slua.isValid(InController) then
    return
  end
  print(bWriteLog and "ParachuteFormationFeature:ReceivePossessed" .. tostring(self:IsSwitchEnabled("bSpreadEnabled")) .. tostring(InController.OnCanTacticalSpread))
  if self:HasAuthority() and self:IsSwitchEnabled("bSpreadEnabled") and InController.OnCanTacticalSpread then
    self:AddControlEvent(InController, "OnCanTacticalSpread", self.OnCanTacticalSpreadFromCpp, self)
    self:AddControlEvent(InController, "OnForceTacticalSpread", self.OnForceTacticalSpreadFromCpp, self)
    self:AddControlEvent(InController, "OnTacticalSpreadPushed", self.OnTacticalSpreadPushedFromCpp, self)
    print(bWriteLog and "ParachuteFormationFeature:ReceivePossessed - Server: Registered tactical spread delegates")
  end
end
function ParachuteFormationFeature:ReceiveEndPlay()
  print(bWriteLog and "ParachuteFormationFeature:ReceiveEndPlay")
  if self.CameraTransitionTimer then
    self:RemoveGameTimer(self.CameraTransitionTimer)
    self.CameraTransitionTimer = nil
  end
  self.bFormationCameraApplied = false
  ParachuteFormationFeature.__super.ReceiveEndPlay(self)
end
local SWITCH_BIT_ENABLED = 0
local SWITCH_BIT_FORMATION = 1
local SWITCH_BIT_SPREAD = 2
local SWITCH_BIT_CAMERA = 3
local SWITCH_BIT_VFORMATION = 4
local SwitchNameToBit = {
  bEnabled = SWITCH_BIT_ENABLED,
  bFormationEnabled = SWITCH_BIT_FORMATION,
  bSpreadEnabled = SWITCH_BIT_SPREAD,
  bCameraEnabled = SWITCH_BIT_CAMERA,
  bVFormationEnabled = SWITCH_BIT_VFORMATION
}
function ParachuteFormationFeature:IsDSSwitchOpen(nSwitchID)
  local uGameState = GameplayData.GetGameState()
  if not slua.isValid(uGameState) or not uGameState.CheckDSSwitchOpen then
    return false
  end
  local SwitchID = nSwitchID or FormationConfig.DSSwitchID
  return uGameState:CheckDSSwitchOpen(SwitchID) or IsEditor
end
function ParachuteFormationFeature:LoadSwitchesFromConfig()
  local bDSSwitchOpen = self:IsDSSwitchOpen(FormationConfig.DSSwitchID)
  local bDSSwitchSpreadOpen = self:IsDSSwitchOpen(FormationConfig.DSSwitchID_Spread)
  print(bWriteLog and string.format("ParachuteFormationFeature:LoadSwitchesFromConfig - DSSwitchID=%d, bDSSwitchOpen=%s, DSSwitchID_Spread=%d, bDSSwitchSpreadOpen=%s", FormationConfig.DSSwitchID, tostring(bDSSwitchOpen), FormationConfig.DSSwitchID_Spread, tostring(bDSSwitchSpreadOpen)))
  local bAnyDSSwitchOpen = bDSSwitchOpen or bDSSwitchSpreadOpen
  local bMasterEnabled = FormationConfig.bEnabled and bAnyDSSwitchOpen
  local Flags = 0
  if bMasterEnabled then
    Flags = Flags + (1 << SWITCH_BIT_ENABLED)
    if bDSSwitchOpen then
      if FormationConfig.bFormationEnabled then
        Flags = Flags + (1 << SWITCH_BIT_FORMATION)
      end
      if FormationConfig.bCameraEnabled then
        Flags = Flags + (1 << SWITCH_BIT_CAMERA)
      end
      if FormationConfig.bVFormationEnabled then
        Flags = Flags + (1 << SWITCH_BIT_VFORMATION)
      end
    end
    if bDSSwitchSpreadOpen and FormationConfig.bSpreadEnabled then
      Flags = Flags + (1 << SWITCH_BIT_SPREAD)
    end
  end
  self.nSwitchend
function ParachuteFormationFeature:OnEnterFightingStateCheckVehicleParachute()
  print(bWriteLog and "ParachuteFormationFeature:OnEnterFightingStateCheckVehicleParachute")
  if not self:HasAuthority() then
    return
  end
  if not self:IsSwitchEnabled("bEnabled") then
    print(bWriteLog and "ParachuteFormationFeature:OnEnterFightingStateCheckVehicleParachute - Feature already disabled, skip")
    return
  end
  local bVehicleParachuteEnabled = self:IsVehicleParachuteEnabled()
  if bVehicleParachuteEnabled then
    print(bWriteLog and "ParachuteFormationFeature:OnEnterFightingStateCheckVehicleParachute - Vehicle parachute detected, disable formation/camera/vformation (keep spread)")
    local Flags = self.nSwitchFlags or 0
    Flags = Flags & ~(1 << SWITCH_BIT_FORMATION)
    Flags = Flags & ~(1 << SWITCH_BIT_CAMERA)
    Flags = Flags & ~(1 << SWITCH_BIT_VFORMATION)
    self.nSwitch    self:SyncSwitchesToCpp()
    print(bWriteLog and string.format("ParachuteFormationFeature:OnEnterFightingStateCheckVehicleParachute - Formation/Camera/VFormation disabled, nSwitchFlags=0x%X", self.nSwitchFlags))
  else
    print(bWriteLog and "ParachuteFormationFeature:OnEnterFightingStateCheckVehicleParachute - No vehicle parachute detected, formation stays enabled")
  end
end
function ParachuteFormationFeature:SetSwitchByGM(SwitchName, bValue)
  print(bWriteLog and string.format("ParachuteFormationFeature:SetSwitchByGM - %s = %s", tostring(SwitchName), tostring(bValue)))
  if not self:HasAuthority() then
    print(bWriteLog and "ParachuteFormationFeature:SetSwitchByGM - Not authority, skip")
    return
  end
  local BitIndex = SwitchNameToBit[SwitchName]
  if BitIndex == nil then
    print(bWriteLog and string.format("ParachuteFormationFeature:SetSwitchByGM - Unknown switch: %s", tostring(SwitchName)))
    return
  end
  local Flags = self.nSwitchFlags or 0
  if bValue then
    Flags = Flags | 1 << BitIndex
  else
    Flags = Flags & ~(1 << BitIndex)
  end
  self.nSwitch  print(bWriteLog and string.format("ParachuteFormationFeature:SetSwitchByGM - nSwitchFlags updated to 0x%X", self.nSwitchFlags))
  self:SyncSwitchesToCpp()
end
function ParachuteFormationFeature:GetSwitchBitDirect(BitIndex)
  local Flags = self.nSwitchFlags or 0
  return Flags & 1 << BitIndex ~= 0
end
function ParachuteFormationFeature:SyncSwitchesToCpp()
  local uCharacter = self:GetOwnerCharacter()
  if not slua.isValid(uCharacter) then
    return
  end
  local ParaComp = uCharacter.ParachuteComponent
  if not slua.isValid(ParaComp) then
    return
  end
  local bSpreadEnabled = self:GetSwitchBitDirect(SWITCH_BIT_ENABLED) and self:GetSwitchBitDirect(SWITCH_BIT_SPREAD)
  local bVFormationEnabled = self:GetSwitchBitDirect(SWITCH_BIT_ENABLED) and self:GetSwitchBitDirect(SWITCH_BIT_VFORMATION)
  ParaComp.bEnableTacticalSpread = bSpreadEnabled
  ParaComp.bUseVFormation = bVFormationEnabled
  print(bWriteLog and string.format("ParachuteFormationFeature:SyncSwitchesToCpp - bEnableTacticalSpread=%s, bUseVFormation=%s", tostring(bSpreadEnabled), tostring(bVFormationEnabled)))
end
function ParachuteFormationFeature:IsSwitchEnabled(SwitchName)
  local Flags = self.nSwitchFlags or 0
  if Flags & 1 << SWITCH_BIT_ENABLED == 0 then
    return false
  end
  if not SwitchName then
    return true
  end
  local BitIndex = SwitchNameToBit[SwitchName]
  if BitIndex == nil then
    return true
  end
  return Flags & 1 << BitIndex ~= 0
end
function ParachuteFormationFeature:ShouldApplyFormationCamera()
  if not self:IsSwitchEnabled("bCameraEnabled") then
    return false
  end
  return self.bInFormation
end
function ParachuteFormationFeature:GetStateCameraConfig()
  local uCharacter = self:GetOwnerCharacter()
  if not slua.isValid(uCharacter) then
    return nil, "unknown"
  end
  local ParachuteState = uCharacter.ParachuteState
  if ParachuteState == EParachuteState.PS_Opening then
    return FormationConfig.Opening, "Opening"
  elseif ParachuteState == EParachuteState.PS_FreeFall then
    return FormationConfig.FreeFall, "FreeFall"
  end
  return nil, "unknown"
end
function ParachuteFormationFeature:OverlayFormationCameraParams()
  print(bWriteLog and "ParachuteFormationFeature:OverlayFormationCameraParams")
  if not self:IsSwitchEnabled("bCameraEnabled") then
    print(bWriteLog and "ParachuteFormationFeature:OverlayFormationCameraParams - Camera disabled, skip")
    return
  end
  local uCharacter = self:GetOwnerCharacter()
  if not slua.isValid(uCharacter) then
    return
  end
  local StateConfig, StateName = self:GetStateCameraConfig()
  if not StateConfig then
    print(bWriteLog and string.format("ParachuteFormationFeature:OverlayFormationCameraParams - No config for state: %s", StateName))
    return
  end
  self.Applied  local SpringArm = uCharacter.SpringArmComp
  if slua.isValid(SpringArm) then
    SpringArm.TargetArmLength = SpringArm.TargetArmLength + StateConfig.ArmLengthAdd
    local CurRelLoc = SpringArm:GetRelativeTransform():GetLocation()
    SpringArm:K2_SetRelativeLocation(FVector(CurRelLoc.X, CurRelLoc.Y, CurRelLoc.Z + StateConfig.RelativeLocationZAdd), false, nil, true)
    SpringArm.bEnableCameraLag = true
    SpringArm.CameraLagSpeed = FormationConfig.FormationCameraLagSpeed
    print(bWriteLog and string.format("ParachuteFormationFeature:OverlayFormationCameraParams - State: %s, ArmLength: %.1f, RelLoc.Z: %.1f, LagSpeed: %.1f", StateName, SpringArm.TargetArmLength, CurRelLoc.Z + StateConfig.RelativeLocationZAdd, SpringArm.CameraLagSpeed))
  end
  local Camera = uCharacter:GetThirdPersonCamera()
  if slua.isValid(Camera) then
    Camera.FieldOfView = Camera.FieldOfView * FormationConfig.FormationFOVMultiplier
    print(bWriteLog and string.format("ParachuteFormationFeature:OverlayFormationCameraParams - FOV: %.1f", Camera.FieldOfView))
  end
  self.bFormationCameraApplied = true
end
function ParachuteFormationFeature:RestoreCameraViaReInvoke()
  print(bWriteLog and "ParachuteFormationFeature:RestoreCameraViaReInvoke")
  if not self.bFormationCameraApplied then
    return
  end
  local uCharacter = self:GetOwnerCharacter()
  if not slua.isValid(uCharacter) then
    self.bFormationCameraApplied = false
    return
  end
  local WasInFormation = self.bInFormation
  self.bInFormation = false
  local ParachuteState = uCharacter.ParachuteState
  if ParachuteState == EParachuteState.PS_Opening then
    uCharacter:SwitchCameraToParachuteOpening()
    print(bWriteLog and "ParachuteFormationFeature:RestoreCameraViaReInvoke - Restored via SwitchCameraToParachuteOpening")
  elseif ParachuteState == EParachuteState.PS_FreeFall then
    uCharacter:SwitchCameraToParachuteFalling()
    print(bWriteLog and "ParachuteFormationFeature:RestoreCameraViaReInvoke - Restored via SwitchCameraToParachuteFalling")
  elseif ParachuteState == EParachuteState.PS_None then
    print(bWriteLog and "ParachuteFormationFeature:RestoreCameraViaReInvoke - Already landed (PS_None), clearing state only")
  else
    print(bWriteLog and string.format("ParachuteFormationFeature:RestoreCameraViaReInvoke - Unknown parachute state (%s), clearing state", tostring(ParachuteState)))
  end
  self.bInFormation = WasInFormation
  self.bFormationCameraApplied = false
  self.AppliedStateConfig = nil
end
function ParachuteFormationFeature:OnLandingClearFormationCamera()
  print(bWriteLog and "ParachuteFormationFeature:OnLandingClearFormationCamera")
  if self.CameraTransitionTimer then
    self:RemoveGameTimer(self.CameraTransitionTimer)
    self.CameraTransitionTimer = nil
    print(bWriteLog and "ParachuteFormationFeature:OnLandingClearFormationCamera - Stopped transition timer")
  end
  self.bFormationCameraApplied = false
  self.AppliedStateConfig = nil
  self.bInFormation = false
  self.nFormationState = 0
  print(bWriteLog and "ParachuteFormationFeature:OnLandingClearFormationCamera - Formation state cleared")
end
function ParachuteFormationFeature:OnFollowStateChanged(LastFollowState, NewFollowState)
  print(bWriteLog and string.format("ParachuteFormationFeature:OnFollowStateChanged - Last: %s, New: %s", tostring(LastFollowState), tostring(NewFollowState)))
  if self:IsSwitchEnabled("bSpreadEnabled") then
    print(bWriteLog and "ParachuteFormationFeature:OnFollowStateChanged - bSpreadEnabled")
    if NewFollowState == EFollowState.Leader then
      self.nFormationState = 1
      print(bWriteLog and "ParachuteFormationFeature:OnFollowStateChanged - Entered formation as leader")
    elseif NewFollowState == EFollowState.Follower then
      self.nFormationState = 1
      print(bWriteLog and "ParachuteFormationFeature:OnFollowStateChanged - Entered formation as follower")
    else
      self.nFormationState = 0
      print(bWriteLog and "ParachuteFormationFeature:OnFollowStateChanged - Left formation")
    end
  end
end
function ParachuteFormationFeature:OnCanTacticalSpreadFromCpp()
  print(bWriteLog and "ParachuteFormationFeature:OnCanTacticalSpreadFromCpp")
  if not self:IsSwitchEnabled("bSpreadEnabled") then
    print(bWriteLog and "ParachuteFormationFeature:OnCanTacticalSpreadFromCpp - Spread disabled, skip")
    return
  end
  if not self:IsBornIslandLeader() then
    print(bWriteLog and "ParachuteFormationFeature:OnCanTacticalSpreadFromCpp - Skip: not born-island leader")
    return
  end
  self.nFormationState = 2
  print(bWriteLog and "ParachuteFormationFeature:OnCanTacticalSpreadFromCpp - nFormationState set to 2 (spread available)")
end
function ParachuteFormationFeature:OnTacticalSpreadPushedFromCpp()
  print(bWriteLog and "ParachuteFormationFeature:OnTacticalSpreadPushedFromCpp")
  local PlayerCharacter = self:GetOwnerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return
  end
  Game:UIShowImageTips(PlayerCharacter.PlayerKey, FormationConfig.TacticalSpreadPushedTipID)
  print(bWriteLog and "ParachuteFormationFeature:OnTacticalSpreadPushedFromCpp - States reset, event broadcast")
end
function ParachuteFormationFeature:OnForceTacticalSpreadFromCpp()
  print(bWriteLog and "ParachuteFormationFeature:OnForceTacticalSpreadFromCpp")
  if not self:IsSwitchEnabled("bSpreadEnabled") then
    print(bWriteLog and "ParachuteFormationFeature:OnForceTacticalSpreadFromCpp - Spread disabled, skip")
    return
  end
  print(bWriteLog and "ParachuteFormationFeature:OnForceTacticalSpreadFromCpp - States reset after force spread")
end
function ParachuteFormationFeature:ExecuteTacticalSpread()
  print(bWriteLog and "ParachuteFormationFeature:ExecuteTacticalSpread")
  if not self:IsSwitchEnabled("bSpreadEnabled") then
    print(bWriteLog and "ParachuteFormationFeature:ExecuteTacticalSpread - Spread disabled, skip")
    return
  end
  local uCharacter = self:GetOwnerCharacter()
  if not slua.isValid(uCharacter) then
    return
  end
  uCharacter:TacticalSpread()
  self.nFormationState = 0
  print(bWriteLog and "ParachuteFormationFeature:ExecuteTacticalSpread - Spread executed, nFormationState reset")
end
ParachuteFormationFeature.ServerRPC.RPC_ServerTacticalSpread = {
  Reliable = true,
  Params = {}
}
function ParachuteFormationFeature:RPC_ServerTacticalSpread()
  print(bWriteLog and "ParachuteFormationFeature:RPC_ServerTacticalSpread")
  if not self:IsSwitchEnabled("bSpreadEnabled") then
    print(bWriteLog and "ParachuteFormationFeature:RPC_ServerTacticalSpread - Spread disabled")
    return
  end
  local uCharacter = self:GetOwnerCharacter()
  if not slua.isValid(uCharacter) then
    return
  end
  if not self:IsBornIslandLeader() then
    print(bWriteLog and "ParachuteFormationFeature:RPC_ServerTacticalSpread - Cannot spread, not born-island leader")
    return
  end
  self:ExecuteTacticalSpread()
end
function ParachuteFormationFeature:OnClientFollowStateChanged(LastFollowState, NewFollowState)
  print(bWriteLog and string.format("ParachuteFormationFeature:OnClientFollowStateChanged - Last: %s, New: %s", tostring(LastFollowState), tostring(NewFollowState)))
  if not self:IsSwitchEnabled("bFormationEnabled") then
    print(bWriteLog and "ParachuteFormationFeature:OnClientFollowStateChanged - Formation disabled, skip")
    return
  end
  if IsFormationFollowState(NewFollowState) then
    self.bInFormation = true
    print(bWriteLog and "ParachuteFormationFeature:OnClientFollowStateChanged - Entered formation")
    self:ApplyFormationCameraForCurrentState()
  else
    local WasInFormation = self.bInFormation
    self.bInFormation = false
    print(bWriteLog and "ParachuteFormationFeature:OnClientFollowStateChanged - Left formation")
    if WasInFormation and self.bFormationCameraApplied then
      self:TransitionCameraToBase()
    end
  end
end
function ParachuteFormationFeature:TransitionCameraToBase()
  print(bWriteLog and "ParachuteFormationFeature:TransitionCameraToBase")
  if self.CameraTransitionTimer then
    self:RemoveGameTimer(self.CameraTransitionTimer)
    self.CameraTransitionTimer = nil
  end
  local TransitionDuration = FormationConfig.FormationCameraTransitionTime
  if TransitionDuration <= 0 then
    self:RestoreCameraViaReInvoke()
    print(bWriteLog and "ParachuteFormationFeature:TransitionCameraToBase - Zero duration, restored immediately")
    return
  end
  local TickInterval = math.max(FormationConfig.FormationCameraTransitionTickInterval or 0.016, 0.01)
  local StartArmLength, StartFOV, StartRelLocZ, TargetArmLength, TargetFOV, TargetRelLocZ
  local uCharacter = self:GetOwnerCharacter()
  if not slua.isValid(uCharacter) then
    self.bFormationCameraApplied = false
    return
  end
  local StartTime = UGameplayStatics.GetTimeSeconds(uCharacter)
  local StateConfig = self.AppliedStateConfig
  StateConfig = StateConfig or self:GetStateCameraConfig()
  if not StateConfig then
    self:RestoreCameraViaReInvoke()
    self.bFormationCameraApplied = false
    return
  end
  local SpringArm = uCharacter.SpringArmComp
  if slua.isValid(SpringArm) then
    StartArmLength = SpringArm.TargetArmLength
    TargetArmLength = StartArmLength - StateConfig.ArmLengthAdd
    local CurRelLoc = SpringArm:GetRelativeTransform():GetLocation()
    StartRelLocZ = CurRelLoc.Z
    TargetRelLocZ = StartRelLocZ - StateConfig.RelativeLocationZAdd
  end
  local Camera = uCharacter:GetThirdPersonCamera()
  if slua.isValid(Camera) then
    StartFOV = Camera.FieldOfView
    TargetFOV = StartFOV / FormationConfig.FormationFOVMultiplier
  end
  self.CameraTransitionTimer = self:AddGameTimer(TickInterval, true, function()
    local CurCharacter = self:GetOwnerCharacter()
    if not slua.isValid(CurCharacter) then
      if self.CameraTransitionTimer then
        self:RemoveGameTimer(self.CameraTransitionTimer)
        self.CameraTransitionTimer = nil
      end
      self.bFormationCameraApplied = false
      return
    end
    local ElapsedTime = math.max(UGameplayStatics.GetTimeSeconds(CurCharacter) - StartTime, 0.0)
    local Alpha = math.min(ElapsedTime / TransitionDuration, 1.0)
    local SmoothAlpha = 1.0 - (1.0 - Alpha) * (1.0 - Alpha)
    local CurSpringArm = CurCharacter.SpringArmComp
    if slua.isValid(CurSpringArm) then
      if StartArmLength and TargetArmLength then
        CurSpringArm.TargetArmLength = StartArmLength + (TargetArmLength - StartArmLength) * SmoothAlpha
        CurSpringArm.CameraLagSpeed = FormationConfig.FormationCameraLagSpeed + (10.0 - FormationConfig.FormationCameraLagSpeed) * SmoothAlpha
      end
      if StartRelLocZ and TargetRelLocZ then
        local CurRelLoc = CurSpringArm:GetRelativeTransform():GetLocation()
        local NewZ = StartRelLocZ + (TargetRelLocZ - StartRelLocZ) * SmoothAlpha
        CurSpringArm:K2_SetRelativeLocation(FVector(CurRelLoc.X, CurRelLoc.Y, NewZ), false, nil, true)
      end
    end
    if StartFOV and TargetFOV then
      local CurCamera = CurCharacter:GetThirdPersonCamera()
      if slua.isValid(CurCamera) then
        CurCamera.FieldOfView = StartFOV + (TargetFOV - StartFOV) * SmoothAlpha
      end
    end
    if CurCharacter.ParachuteState == EParachuteState.PS_None then
      if self.CameraTransitionTimer then
        self:RemoveGameTimer(self.CameraTransitionTimer)
        self.CameraTransitionTimer = nil
      end
      self.bFormationCameraApplied = false
      print(bWriteLog and "ParachuteFormationFeature:TransitionCameraToBase - Landed during transition, stopped")
      return
    end
    if 1.0 <= Alpha then
      self:RestoreCameraViaReInvoke()
      if self.CameraTransitionTimer then
        self:RemoveGameTimer(self.CameraTransitionTimer)
        self.CameraTransitionTimer = nil
      end
      print(bWriteLog and "ParachuteFormationFeature:TransitionCameraToBase - Transition complete, restored via re-invoke")
    end
  end)
end
function ParachuteFormationFeature:CanShowTacticalSpreadButton()
  if not self:IsSwitchEnabled("bSpreadEnabled") then
    return false
  end
  local uCharacter = self:GetOwnerCharacter()
  if not slua.isValid(uCharacter) then
    return false
  end
  if uCharacter.FollowState ~= EFollowState.Leader then
    return false
  end
  if uCharacter.JumpFromPlaneType ~= EJumpFromPlaneType.Born then
    return false
  end
  return self.nFormationState >= 2
end
function ParachuteFormationFeature:RequestTacticalSpread()
  print(bWriteLog and "ParachuteFormationFeature:RequestTacticalSpread")
  if not self:CanShowTacticalSpreadButton() then
    print(bWriteLog and "ParachuteFormationFeature:RequestTacticalSpread - Cannot spread")
    return
  end
  self:RPC_ServerTacticalSpread()
end
function ParachuteFormationFeature:IsBornIslandLeader()
  local uCharacter = self:GetOwnerCharacter()
  if not slua.isValid(uCharacter) then
    return false
  end
  if uCharacter.FollowState ~= EFollowState.Leader then
    return false
  end
  if uCharacter.JumpFromPlaneType ~= EJumpFromPlaneType.Born then
    return false
  end
  return true
end
function ParachuteFormationFeature:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  return {
    {
      "nFormationState",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    },
    {
      "nSwitchFlags",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    }
  }
end
function ParachuteFormationFeature:OnRep_nFormationState()
  print(bWriteLog and string.format("ParachuteFormationFeature:OnRep_nFormationState - State: %d", self.nFormationState))
  if Client then
    self:RefreshClientFormationStateFromOwner(true)
    self:LuaBroadcast("OnFormationStateChanged", self.nFormationState)
  end
end
function ParachuteFormationFeature:OnRep_nSwitchFlags()
  print(bWriteLog and string.format("ParachuteFormationFeature:OnRep_nSwitchFlags - Flags: 0x%X", self.nSwitchFlags))
  self:SyncSwitchesToCpp()
  self:RefreshClientFormationStateFromOwner(true)
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
return class(CFeatureBase, nil, ParachuteFormationFeature)