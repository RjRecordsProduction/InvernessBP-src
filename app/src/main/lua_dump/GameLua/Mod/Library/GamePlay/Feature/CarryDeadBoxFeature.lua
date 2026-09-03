local EPawnState = import("EPawnState")
local ENetRole = import("ENetRole")
local EAttachmentRule = import("EAttachmentRule")
local DeadBoxCfg = require("GameLua.Mod.Library.GamePlay.Config.CarryDeadBoxConfig")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local EViewTargetBlendFunction = import("EViewTargetBlendFunction")
local UKismetSystemLibrary = import("KismetSystemLibrary")
local ECollisionChannel = import("ECollisionChannel")
local EDrawDebugTrace = import("EDrawDebugTrace")
local USTExtraGameplayStatics = import("STExtraGameplayStatics")
local UTSkillStopReason = import("UTSkillStopReason")
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
local CarryDeadBoxFeature = {
  ServerRPC = {},
  ClientRPC = {}
}
CarryDeadBoxFeature.ClientRPC.ClientRPC_RejectCarryBox = {
  Reliable = true,
  Params = {}
}
function CarryDeadBoxFeature:_PostConstruct()
  CarryDeadBoxFeature.__super._PostConstruct(self)
end
function CarryDeadBoxFeature:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  return {
    {
      "AttachedDeadBox",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Object
    }
  }
end
function CarryDeadBoxFeature:OnRep_AttachedDeadBox(OldValue)
  local uMyCharacter = self:GetMyCharacter()
  if not slua.isValid(uMyCharacter) then
    print(bWriteLog and string.format("DeadBoxLog CarryDeadBoxFeature:OnRep_AttachedDeadBox uMyCharacter is nil"))
    return
  end
  print(bWriteLog and string.format("DeadBoxLog CarryDeadBoxFeature:OnRep_AttachedDeadBox OldValue:%s AttachedDeadBox:%s PlayerKey:%s PlayerName:%s", tostring(OldValue), tostring(self.AttachedDeadBox), tostring(uMyCharacter.PlayerKey), tostring(uMyCharacter:GetPlayerNameSafety())))
  if slua.isValid(OldValue) and self.AttachedDeadBox == nil then
    self:RefreshDeadBoxAvatarOnClient(OldValue, true)
    local uPlayerController = uMyCharacter:GetPlayerControllerSafety()
    if slua.isValid(uPlayerController) and uPlayerController.bIsForReplay then
      print(bWriteLog and string.format("DeadBoxLog CarryDeadBoxFeature:OnRep_AttachedDeadBox uPlayerController  is ForReplay"))
      local EDetachmentRule = import("EDetachmentRule")
      OldValue:K2_DetachFromActor(EDetachmentRule.KeepWorld, EDetachmentRule.KeepWorld, EDetachmentRule.KeepWorld)
      uMyCharacter:DeactiveAdditiveModify()
      if OldValue.bReplicateMovement then
        OldValue:OnRep_ReplicatedMovement()
      end
    end
  end
  if slua.isValid(self.AttachedDeadBox) then
    if uMyCharacter.Role == ENetRole.ROLE_AutonomousProxy and slua.isValid(uMyCharacter.SearchOtherComponent) then
      local ECharacterSearchEnum = import("ECharacterSearchEnum")
      local EExecutionCondition = import("EExecutionCondition")
      uMyCharacter.SearchOtherComponent:ResetSearchResult(ECharacterSearchEnum.CanCarryPlayerTombBox, EExecutionCondition.Client)
      uMyCharacter.SearchOtherComponent:ResetTickCheckTime(ECharacterSearchEnum.CanCarryPlayerTombBox, 0, EExecutionCondition.Client, false)
      uMyCharacter.SearchOtherComponent:ResetSearchResult(ECharacterSearchEnum.CanCarryPawn, EExecutionCondition.Client)
      uMyCharacter.SearchOtherComponent:ResetTickCheckTime(ECharacterSearchEnum.CanCarryPawn, 0, EExecutionCondition.Client, false)
    end
    self:UpdatCameraOnCarryed(self.AttachedDeadBox)
    self:RefreshAttachInfoOnClient()
    self:RefreshDeadBoxAvatarOnClient(self.AttachedDeadBox, false)
    self:RefreshAdditiveBlendData()
    if uMyCharacter.Role == ENetRole.ROLE_AutonomousProxy then
      EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_CARRY_BOX_DONE, uMyCharacter)
    end
  else
    if uMyCharacter.Role == ENetRole.ROLE_AutonomousProxy then
      EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_CARRY_BOX_INTERUPT, uMyCharacter)
      if slua.isValid(uMyCharacter.SearchOtherComponent) then
        local ECharacterSearchEnum = import("ECharacterSearchEnum")
        local EExecutionCondition = import("EExecutionCondition")
        uMyCharacter.SearchOtherComponent:ResetTickCheckTime(ECharacterSearchEnum.CanCarryPlayerTombBox, 0.1, EExecutionCondition.Client, false)
      end
    end
    EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_CARRY_BOX_SOMEONE_PUT_DOWN, uMyCharacter, OldValue)
  end
end
function CarryDeadBoxFeature:ReceiveBeginPlay()
  print(bWriteLog and string.format("DeadBoxLog CarryDeadBoxFeature:ReceiveBeginPlay"))
  CarryDeadBoxFeature.__super.ReceiveBeginPlay(self)
  if Client then
    local Util = require("client.slua_ui_framework.util")
    Util.GetAssetAsync(DeadBoxCfg.BlendData, function(LoadObj)
      if slua.isValid(LoadObj) and self.Owner and slua.isValid(self.Owner.Object) then
        self.BlendData = LoadObj
        local uMyCharacter = self:GetMyCharacter()
        if slua.isValid(uMyCharacter) and uMyCharacter:HasState(EPawnState.CarryBox) then
          print(bWriteLog and string.format("DeadBoxLog CarryDeadBoxFeature:ReceiveBeginPlay uMyCharacter HasState CarryBox Refresh By OnPlayerEnterCarryBoxState"))
          self:OnPlayerEnterCarryBoxState()
        end
      end
    end)
    local uMyCharacter = self:GetMyCharacter()
    if slua.isValid(uMyCharacter) then
      self:BindLuaObjEvent(uMyCharacter, "OnCharacterAnimInstanceInit", self.HandleOnCharacterAnimInstanceInit, self)
      self:AddControlEvent(uMyCharacter, "OnCharacterWeaponEquipDelegate", self.HandleCharacterWeaponEquip, self)
    else
      print(bWriteLog and string.format("DeadBoxLog CarryDeadBoxFeature:ReceiveBeginPlay uMyCharacter is nil"))
    end
    GameplayData.AddSelfPlayerControllerEvent(self, "OnPostViewTargetChangeDelegate", self.OnViewTargetChange, self)
  else
  end
  local uMyCharacter = self:GetMyCharacter()
  if slua.isValid(uMyCharacter) then
    self:AddControlEvent(uMyCharacter, "OnHandleSkillStartDelegate", self.OnPawnSkillStart, self)
    self:AddControlEvent(uMyCharacter, "OnHandleSkillEndDelegate", self.OnPawnSkillEnd, self)
  else
    print(bWriteLog and string.format("DeadBoxLog CarryDeadBoxFeature:ReceiveBeginPlay uMyCharacter is nil for AddControlEvent"))
  end
end
function CarryDeadBoxFeature:HandleCharacterWeaponEquip(uWeapon, nSlot)
  print(bWriteLog and "CarryDeadBoxFeature:HandleCharacterWeaponEquip")
  if not slua.isValid(uWeapon) then
    print(bWriteLog and "CarryDeadBoxFeature:HandleCharacterWeaponEquip not slua.isValid(uWeapon)")
    return
  end
  local uCharacter = self:GetMyCharacter()
  if uCharacter == nil or not slua.isValid(uCharacter) then
    return
  end
  local ESurviveWeaponPropSlotDef = import("ESurviveWeaponPropSlot")
  if uCharacter:HasState(EPawnState.CarryBox) then
    uCharacter:SwitchWeaponBySlot(ESurviveWeaponPropSlotDef.SWPS_None, false, true, true)
    print(bWriteLog and "CarryDeadBoxFeature:HandleCharacterWeaponEquip SwitchWeaponBySlot SWPS_None")
  end
end
function CarryDeadBoxFeature:OnPawnSkillStart(uSkillCharacter, SkillID)
  if Client then
  elseif DeadBoxCfg.CarryDeadBoxSkillID == SkillID and self.CacheDeadBox and slua.isValid(self.CacheDeadBox) then
    self.CacheDeadBox:SetIsOccupied(true)
  end
end
function CarryDeadBoxFeature:OnPawnSkillEnd(Character, Reason, SkillID)
  if Client then
    local uMyCharacter = self:GetMyCharacter()
    if (DeadBoxCfg.CarryDeadBoxSkillID == SkillID or DeadBoxCfg.PutDownDeadBoxSkillID == SkillID) and slua.isValid(uMyCharacter) and uMyCharacter.Role == ENetRole.ROLE_AutonomousProxy then
      print(bWriteLog and string.format("DeadBoxLog CarryDeadBoxFeature:OnPawnSkillEnd CarryDeadBoxSkill or PutDownDeadBoxSkillID"))
      self:ResetSearchAndTickCheck()
      if DeadBoxCfg.PutDownDeadBoxSkillID == SkillID then
        EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_CARRY_BOX_DONE, uMyCharacter)
      end
    end
  elseif DeadBoxCfg.CarryDeadBoxSkillID == SkillID and self.CacheDeadBox and slua.isValid(self.CacheDeadBox) then
    self.CacheDeadBox:SetIsOccupied(false)
  end
end
function CarryDeadBoxFeature:HandleOnCharacterAnimInstanceInit()
  print(bWriteLog and string.format("DeadBoxLog CarryDeadBoxFeature:HandleOnCharacterAnimInstanceInit"))
  local uMyCharacter = self:GetMyCharacter()
  if slua.isValid(uMyCharacter) and uMyCharacter:HasState(EPawnState.CarryBox) then
    self:RefreshAdditiveBlendData()
  end
end
function CarryDeadBoxFeature:GetMyCharacter()
  if self.Owner then
    return self.Owner.Object
  end
end
function CarryDeadBoxFeature:OnPlayerEnterCarryBoxState()
  local uMyCharacter = self:GetMyCharacter()
  if not slua.isValid(uMyCharacter) then
    print(bWriteLog and string.format("DeadBoxLog CarryDeadBoxFeature:OnPlayerEnterCarryBoxState uMyCharacter is nil"))
    return
  end
  if not slua.isValid(uMyCharacter.SkillManager) then
    print(bWriteLog and string.format("DeadBoxLog CarryDeadBoxFeature:OnPlayerEnterCarryBoxState Role:%s PlayerKey:%s Name:%s", tostring(uMyCharacter.Role), tostring(uMyCharacter.PlayerKey), tostring(uMyCharacter:GetPlayerNameSafety())))
    return
  end
  local ESurviveWeaponPropSlotDef = import("ESurviveWeaponPropSlot")
  local CurrentWeapon = uMyCharacter:GetCurrentWeapon()
  if CurrentWeapon and slua.isValid(CurrentWeapon) then
    uMyCharacter:SwitchWeaponBySlot(ESurviveWeaponPropSlotDef.SWPS_None, false, true, true)
    print(bWriteLog and "DeadBoxLog CarryDeadBoxFeature:OnPlayerEnterCarryBoxState SwitchWeaponBySlot SWPS_None")
  end
  if Client then
    self:RefreshAdditiveBlendData()
    self:RefreshAttachInfoOnClient()
    local uController = uMyCharacter:GetPlayerControllerSafety()
    local bFpp = uMyCharacter:GetIsFPP()
    if bFpp and uMyCharacter.Role == ENetRole.ROLE_AutonomousProxy and slua.isValid(uController) then
      uController:ExitFreeCamera(true)
      uController:BroadcastUIMessage("UIMsg_HideFreeCamera", 0, "", "")
      print(bWriteLog and string.format("DeadBoxLog CarryDeadBoxFeature:OnPlayerEnterCarryBoxState Pawn:%s ExitFreeCamera for FPP", tostring(uMyCharacter:GetPlayerNameSafety())))
    end
    if uMyCharacter.Role == ENetRole.ROLE_AutonomousProxy and slua.isValid(uController) then
      uController.IsPlayerUnableToDoAutoSprintOperation = true
    end
  elseif slua.isValid(self.CacheDeadBox) then
    self.AttachedDeadBox = self.CacheDeadBox
    if self.AttachedDeadBox and self.AttachedDeadBox.RemoveFromAIList then
      self.AttachedDeadBox:RemoveFromAIList()
    end
    if slua.isValid(self.AttachedDeadBox.PickupListWrapper) then
      Game:UnregisterRegionObject(self.AttachedDeadBox.PickupListWrapper)
    end
    Game:UnregisterRegionObject(self.AttachedDeadBox)
    self.AttachedDeadBox:K2_AttachToActor(uMyCharacter, "None", EAttachmentRule.SnapToTarget, EAttachmentRule.SnapToTarget, EAttachmentRule.SnapToTarget, false)
    if self.AttachedDeadBox.SetAttachCharacterOnServer then
      self.AttachedDeadBox:SetAttachCharacterOnServer(uMyCharacter)
    end
    self.AttachedDeadBox.NetConsiderFrequency = DeadBoxCfg.CarryedDeadBoxUpdateFrequency
    self.AttachedDeadBox.NetUpdateFrequency = DeadBoxCfg.CarryedDeadBoxUpdateFrequency
    self.AttachedDeadBox.AttachedActor = uMyCharacter
    self.AttachedDeadBox:ForceNetUpdate()
    print(bWriteLog and string.format("DeadBoxLog CarryDeadBoxFeature:OnPlayerEnterCarryBoxState AttachedDeadBox Attach To Pawn:%s", tostring(uMyCharacter:GetPlayerNameSafety())))
    self:RecordTlog(DeadBoxCfg.TlogCarryDeadBoxTimes, false)
    uMyCharacter:AddSkillToken(DeadBoxCfg.PutDownDeadBoxSkillID)
  else
    uMyCharacter:LeaveState(EPawnState.CarryBox)
    print(bWriteLog and string.format("DeadBoxLog CarryDeadBoxFeature:OnPlayerEnterCarryBoxState AttachedDeadBox is nil auto leave CarryBox state"))
  end
end
function CarryDeadBoxFeature:OnPlayerLeaveCarryBoxState(bInIsInterrupt)
  local uMyCharacter = self:GetMyCharacter()
  if not slua.isValid(uMyCharacter) then
    print(bWriteLog and string.format("DeadBoxLog CarryDeadBoxFeature:OnPlayerLeaveCarryBoxState uMyCharacter is nil"))
    return
  end
  if not slua.isValid(uMyCharacter.SkillManager) then
    print(bWriteLog and string.format("DeadBoxLog CarryDeadBoxFeature:OnPlayerLeaveCarryBoxState SkillManager is nil Role:%s PlayerKey:%s Name:%s", tostring(uMyCharacter.Role), tostring(uMyCharacter.PlayerKey), tostring(uMyCharacter:GetPlayerNameSafety())))
    return
  end
  print(bWriteLog and string.format("DeadBoxLog CarryDeadBoxFeature:OnPlayerLeaveCarryBoxState PlayerKey:%s PlayerName:%s bInIsInterrupt:%s", tostring(uMyCharacter.PlayerKey), tostring(uMyCharacter:GetPlayerNameSafety()), tostring(bInIsInterrupt)))
  if Client then
    uMyCharacter:DeactiveAdditiveModify()
    if uMyCharacter.Role == ENetRole.ROLE_AutonomousProxy then
      uMyCharacter:SwitchToLastNoneGrenageWeapon(true, false, false, false)
      local uController = uMyCharacter:GetPlayerControllerSafety()
      if slua.isValid(uController) then
        uController:BroadcastUIMessage("UIMsg_ShowFreeCamera", 0, "", "")
        print(bWriteLog and "DeadBoxLog CarryDeadBoxFeature:OnPlayerLeaveCarryBoxState UIMsg_ShowFreeCamera")
        uController.IsPlayerUnableToDoAutoSprintOperation = false
      end
    end
  else
    if slua.isValid(self.AttachedDeadBox) then
      self.AttachedDeadBox:K2_DetachFromActor(1, 1, 1)
      if self.AttachedDeadBox.DelayResetUpdateFrequency then
        self.AttachedDeadBox:DelayResetUpdateFrequency()
      else
        self.AttachedDeadBox.NetConsiderFrequency = DeadBoxCfg.PutDownDeadBoxUpdateFrequency
        self.AttachedDeadBox.NetUpdateFrequency = DeadBoxCfg.PutDownDeadBoxUpdateFrequency
      end
      self.AttachedDeadBox:ForceNetUpdate()
      local uBottomLoc = uMyCharacter:GetCapsuleEdgeLocation(FVector(0, 0, -1))
      local uPutdownLocation, uDownActor = self:FindPutLocation(uMyCharacter, self.AttachedDeadBox)
      self.AttachedDeadBox:K2_SetActorLocation(uPutdownLocation, false, nil, true)
      if IsEditor then
        USTExtraGameplayStatics.ClientDrawDebugBox(uPutdownLocation, DeadBoxCfg.PutLocationCheckBox, FLinearColor.Red, self.AttachedDeadBox:K2_GetActorRotation(), 10, 2)
      end
      print(bWriteLog and string.format("DeadBoxLog CarryDeadBoxFeature:OnPlayerLeaveCarryBoxState Putdown DeadBox SetActorLocation:%s", tostring(uPutdownLocation:ToString())))
      if uDownActor and slua.isValid(uDownActor) and self.AttachedDeadBox.TryAttachToActorOnPutDown then
        self.AttachedDeadBox:TryAttachToActorOnPutDown(uDownActor)
        print(bWriteLog and string.format("DeadBoxLog CarryDeadBoxFeature:OnPlayerLeaveCarryBoxState Putdown DeadBox Try AttachTo Actor:%s", tostring(UKismetSystemLibrary.GetObjectName(uDownActor))))
      end
      if self.AttachedDeadBox and self.AttachedDeadBox.AddToAIList then
        self.AttachedDeadBox:AddToAIList()
      end
      self.AttachedDeadBox:SetIsOccupied(false)
      self.AttachedDeadBox:FlushNetDormancyOnceForReplay()
    end
    self.AttachedDeadBox = nil
    self.CacheDeadBox = nil
    uMyCharacter:ClearSkillToken(DeadBoxCfg.PutDownDeadBoxSkillID)
  end
end
function CarryDeadBoxFeature:FindPutLocation(uInCharacter, uInDeadBox)
  local OutLocation = uInCharacter:GetCapsuleEdgeLocation(FVector(0, 0, -1))
  local OutActor
  local TraceType = Game:ConvertToTraceType(ECollisionChannel.ECC_GameTraceChannel12)
  local uForwardOffset = uInCharacter:GetActorForwardVector() * DeadBoxCfg.PutLocationCheckOffset.X
  local uUpOffset = uInCharacter:GetActorUpVector() * DeadBoxCfg.PutLocationCheckOffset.Z
  local Start = uInCharacter:K2_GetActorLocation() + uForwardOffset + uUpOffset
  local End = Start - FVector(0, 0, DeadBoxCfg.PutLocationTraceDownOffset)
  local HalfSize = DeadBoxCfg.PutLocationCheckBox
  local BoxRotation = uInDeadBox:K2_GetActorRotation()
  local bForwardHit, uForwardHitResult
  bForwardHit, uForwardHitResult = self:TraceWithBoxShape(uInDeadBox, uInCharacter:K2_GetActorLocation(), Start, TraceType)
  if bForwardHit then
    print(bWriteLog and string.format("DeadBoxLog CarryDeadBoxFeature:FindPutLocation trace forward hit something"))
  end
  local bForwardDownHit, uForwardDownHitLoc, uForwardDownHitActor
  bForwardDownHit, uForwardDownHitLoc, uForwardDownHitActor = self:TraceWithBoxShape(uInDeadBox, Start, End, TraceType)
  if bForwardDownHit then
    OutLocation = FVector(uForwardDownHitLoc.X, uForwardDownHitLoc.Y, uForwardDownHitLoc.Z) + DeadBoxCfg.PutLocationUpOffset
    OutActor = uForwardDownHitActor
    print(bWriteLog and string.format("DeadBoxLog CarryDeadBoxFeature:FindPutLocation trace forward forward Start:%s, HitLoc:%s", tostring(Start:ToString()), tostring(OutLocation:ToString())))
    if slua.isValid(uForwardDownHitActor) and uForwardDownHitActor:ActorHasTag("NotAllowPutDeadBox") then
      bForwardDownHit = false
      OutActor = nil
      print(bWriteLog and string.format("DeadBoxLog CarryDeadBoxFeature:FindPutLocation trace forward forward hit NotAllowDeadBox"))
    end
  end
  local bCharacterToForwardDownHit, uCharacterToForwardDownHitLoc, uCharacterToForwardDownActor
  local bUseCharacterDownLoc = false
  if not bForwardHit and bForwardDownHit then
    bCharacterToForwardDownHit, uCharacterToForwardDownHitLoc, uCharacterToForwardDownActor = self:TraceWithBoxShape(uInDeadBox, uInCharacter:K2_GetActorLocation(), OutLocation, TraceType)
    if bCharacterToForwardDownHit then
      bUseCharacterDownLoc = true
    end
  else
    bUseCharacterDownLoc = true
  end
  local bCharacterToDownHit, uCharacterToDownHitLoc, uCharacterToDownHitActor
  if bUseCharacterDownLoc then
    bCharacterToDownHit, uCharacterToDownHitLoc, uCharacterToDownHitActor = self:TraceWithBoxShape(uInDeadBox, uInCharacter:K2_GetActorLocation(), uInCharacter:K2_GetActorLocation() - FVector(0, 0, DeadBoxCfg.PutLocationTraceDownOffset), TraceType)
    uCharacterToDownHitLoc = uCharacterToDownHitLoc or uInCharacter:GetCapsuleEdgeLocation(FVector(0, 0, -1))
    OutLocation = FVector(uCharacterToDownHitLoc.X, uCharacterToDownHitLoc.Y, uCharacterToDownHitLoc.Z)
    OutActor = uCharacterToDownHitActor
  end
  return OutLocation, OutActor
end
function CarryDeadBoxFeature:TraceWithBoxShape(uInDeadBox, Start, End, TraceType)
  local OutLocation
  local HalfSize = DeadBoxCfg.PutLocationCheckBox
  local BoxRotation = uInDeadBox:K2_GetActorRotation()
  local bHit, uHitResult
  bHit, uHitResult = UKismetSystemLibrary.BoxTraceSingle(CGameWorld, Start, End, HalfSize, BoxRotation, TraceType, true, {}, EDrawDebugTrace.None, uHitResult, true, FLinearColor.Green, FLinearColor.Red, 1)
  if bHit then
    OutLocation = FVector(uHitResult.Location.X, uHitResult.Location.Y, uHitResult.Location.Z)
    print(bWriteLog and string.format("DeadBoxLog CarryDeadBoxFeature:TraceWithBoxShape Start:%s, HitLoc:%s", tostring(Start:ToString()), tostring(OutLocation:ToString())))
  end
  if uHitResult and slua.isValid(uHitResult.Actor) then
    return bHit, OutLocation, uHitResult.Actor
  end
  return bHit, OutLocation, nil
end
function CarryDeadBoxFeature:RefreshAdditiveBlendData()
  local uMyCharacter = self:GetMyCharacter()
  if not slua.isValid(uMyCharacter) then
    print(bWriteLog and string.format("DeadBoxLog CarryDeadBoxFeature:RefreshAdditiveBlendData uMyCharacter is nil"))
    return
  end
  if not slua.isValid(self.BlendData) then
    self.BlendData = slua.loadObject(DeadBoxCfg.BlendData)
    print(bWriteLog and "DeadBoxLog CarryDeadBoxFeature:RefreshAdditiveBlendData BlendData is nil, so loadObject")
  end
  uMyCharacter:ActiveAdditiveModify(self.BlendData)
end
function CarryDeadBoxFeature:RefreshAttachInfoOnClient()
  local uMyCharacter = self:GetMyCharacter()
  if not slua.isValid(uMyCharacter) then
    print(bWriteLog and string.format("DeadBoxLog CarryDeadBoxFeature:RefreshAttachInfoOnClient uMyCharacter is nil"))
    return
  end
  if not slua.isValid(self.AttachedDeadBox) then
    print(bWriteLog and string.format("DeadBoxLog CarryDeadBoxFeature:RefreshAttachInfoOnClient AttachedDeadBox is nil for PlayerKey:%s PlayerName:%s", tostring(uMyCharacter.PlayerKey), tostring(uMyCharacter:GetPlayerNameSafety())))
    return
  end
  if slua.isValid(self.AttachedDeadBox.TeammateParticleSystem) then
    self.AttachedDeadBox.TeammateParticleSystem:Deactivate()
  end
  if slua.isValid(uMyCharacter.Mesh) and self.AttachedDeadBox.K2_AttachToComponent then
    self.AttachedDeadBox:K2_AttachToComponent(uMyCharacter.Mesh, DeadBoxCfg.AttachSocket, EAttachmentRule.SnapToTarget, EAttachmentRule.SnapToTarget, EAttachmentRule.SnapToTarget, false)
  else
    print(bWriteLog and string.format("DeadBoxLog CarryDeadBoxFeature:RefreshAttachInfoOnClient uMyCharacter.Mesh is nil for PlayerKey:%s PlayerName:%s", tostring(uMyCharacter.PlayerKey), tostring(uMyCharacter:GetPlayerNameSafety())))
  end
end
function CarryDeadBoxFeature:RefreshDeadBoxAvatarOnClient(uInDeadBox, bIsDetach)
  if not slua.isValid(uInDeadBox) then
    print(bWriteLog and string.format("DeadBoxLog CarryDeadBoxFeature:RefreshDeadBoxAvatarOnClient uInDeadBox is nil"))
    return
  end
  if bIsDetach then
    uInDeadBox.bUseDefault = false
    uInDeadBox.bNotShowParticle = true
    uInDeadBox:OnRep_AvatarId()
    print(bWriteLog and string.format("DeadBoxLog CarryDeadBoxFeature:RefreshDeadBoxAvatarOnClient uInDeadBox OnRep_AvatarId %s", tostring(uInDeadBox:GetAvatarId())))
  elseif uInDeadBox.ResetToDefaultMesh then
    uInDeadBox.bUseDefault = true
    uInDeadBox:ResetToDefaultMesh()
    if slua.isValid(uInDeadBox.DeadBoxAvatarComponent_BP) then
      uInDeadBox.DeadBoxAvatarComponent_BP:StopCurrentSequenceActor()
    end
  else
    print(bWriteLog and string.format("DeadBoxLog CarryDeadBoxFeature:RefreshDeadBoxAvatarOnClient uInDeadBox ResetToDefaultMesh is nil"))
  end
end
function CarryDeadBoxFeature:OnViewTargetChange(NewViewTarget, PreViewTarget)
  if Game:IsClassOf(NewViewTarget, import("/Script/ShadowTrackerExtra.PlayerTombBox")) and slua.isValid(self.AttachedDeadBox) then
    self:UpdatCameraOnCarryed(self.AttachedDeadBox)
  end
end
function CarryDeadBoxFeature:UpdatCameraOnCarryed(uInDeadBox)
  if not Client then
    return
  end
  if not slua.isValid(uInDeadBox) then
    print(bWriteLog and string.format("DeadBoxLog CarryDeadBoxFeature:UpdatCameraOnCarryed uInDeadBox is nil"))
    return
  end
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) then
    local uViewTarget = uPlayerController:GetViewTarget()
    if slua.isValid(uViewTarget) and Game:IsClassOf(uViewTarget, import("/Script/ShadowTrackerExtra.PlayerTombBox")) then
      local uTargetClass = slua.loadClass(DeadBoxCfg.FakeViewTargetClass)
      local uLoc = uInDeadBox:K2_GetActorLocation()
      local uRot = uInDeadBox:K2_GetActorRotation()
      if uTargetClass then
        local uTargetActor = CGameWorld:SpawnActor(uTargetClass, uLoc, FRotator(uRot.Pitch, uRot.Yaw, 0), nil)
        if slua.isValid(uTargetActor) then
          uPlayerController:SetViewTargetWithBlend(uTargetActor, 0, EViewTargetBlendFunction.VTBlend_Linear, 0, false)
        end
      end
    end
  end
end
function CarryDeadBoxFeature:LegalityCheck(uInDeadBox)
  if not slua.isValid(uInDeadBox) then
    print(bWriteLog and string.format("DeadBoxLog CarryDeadBoxFeature:LegalityCheck uInDeadBox is nil"))
    return false
  end
  local uMyCharacter = self:GetMyCharacter()
  if not slua.isValid(uMyCharacter) then
    print(bWriteLog and string.format("DeadBoxLog CarryDeadBoxFeature:LegalityCheck uMyCharacter is nil"))
    return false
  end
  local uDeadBoxParent = uInDeadBox:GetAttachParentActor()
  if slua.isValid(uDeadBoxParent) and Game:IsClassOf(uDeadBoxParent, import("/Script/ShadowTrackerExtra.STExtraBaseCharacter")) then
    print(bWriteLog and string.format("DeadBoxLog CarryDeadBoxFeature:LegalityCheck uDeadBoxParent is STExtraBaseCharacter"))
    return false
  end
  if not uMyCharacter:AllowState(EPawnState.CarryBox, true) then
    print(bWriteLog and string.format("DeadBoxLog CarryDeadBoxFeature:LegalityCheck not allow state CarryBox"))
    return false
  end
  if uInDeadBox.bIsOccupied then
    print(bWriteLog and string.format("DeadBoxLog CarryDeadBoxFeature:LegalityCheck bIsOccupied"))
    return false
  end
  local DiffLoc = (uInDeadBox:K2_GetActorLocation() - uMyCharacter:K2_GetActorLocation()):Size()
  print(bWriteLog and string.format("DeadBoxLog CarryDeadBoxFeature:LegalityCheck Role:%s PlayerKey:%s BoxName:%s PlayerLocation:%s BoxLocation:%s DiffLoc:%s", tostring(uMyCharacter.Role), tostring(uMyCharacter.PlayerKey), tostring(uInDeadBox.TombName), tostring(uMyCharacter:K2_GetActorLocation():ToString()), tostring(uInDeadBox:K2_GetActorLocation():ToString()), tostring(DiffLoc)))
  if DiffLoc > DeadBoxCfg.DeadBoxCheckDistance then
    print(bWriteLog and string.format("DeadBoxLog Error CarryDeadBoxFeature:LegalityCheck DiffLoc:%s > DeadBoxCheckDistance:%s", tostring(DiffLoc), tostring(DeadBoxCfg.DeadBoxCheckDistance)))
    return false
  end
  local uBoxCheckLoc = uInDeadBox:K2_GetActorLocation() + FVector(0, 0, 15)
  local uPawnCenterLoc = uMyCharacter:K2_GetActorLocation()
  local uPawnLeftLoc = uMyCharacter:GetCapsuleEdgeLocation(FVector(0, 2, 0))
  local uPawnRightLoc = uMyCharacter:GetCapsuleEdgeLocation(FVector(0, -2, 0))
  local uPawnUpLoc = uMyCharacter:GetCapsuleEdgeLocation(FVector(0, 0, 1))
  local uPawnDownLoc = uMyCharacter:GetCapsuleEdgeLocation(FVector(0, 0, -1))
  local uLocTable = {
    uPawnCenterLoc,
    uPawnLeftLoc,
    uPawnRightLoc,
    uPawnUpLoc,
    uPawnDownLoc
  }
  local bIsAllHit = true
  for i, uLoc in ipairs(uLocTable) do
    local bHit, OutHit = UKismetSystemLibrary.LineTraceSingleForObjects(uMyCharacter, uLoc, uBoxCheckLoc, {
      ECollisionChannel.ECC_WorldStatic
    }, true, nil, EDrawDebugTrace.ForDuration, nil, false, FLinearColor.Green, FLinearColor.Red, 1)
    print(bWriteLog and string.format("DeadBoxLog CarryDeadBoxFeature:LegalityCheck i = %d uLoc:%s uBoxCheckLoc:%s", i, tostring(uLoc:ToString()), tostring(uBoxCheckLoc:ToString())))
    if _G.IsEditor then
      USTExtraGameplayStatics.ClientDrawDebugLine(uLoc, uBoxCheckLoc, bHit and FLinearColor.Red or FLinearColor.Green, 5, 2)
    end
    if not bHit then
      bIsAllHit = false
      break
    end
  end
  if bIsAllHit then
    return false
  end
  return true
end
function CarryDeadBoxFeature:CarryDeadBox(uInDeadBox)
  if Client then
    print(bWriteLog and string.format("DeadBoxLog CarryDeadBoxFeature:CarryDeadBox Only On Server"))
    return
  end
  if not slua.isValid(uInDeadBox) then
    print(bWriteLog and string.format("DeadBoxLog CarryDeadBoxFeature:CarryDeadBox uInDeadBox is nil"))
    return
  end
  local uMyCharacter = self:GetMyCharacter()
  if not slua.isValid(uMyCharacter) then
    print(bWriteLog and string.format("DeadBoxLog CarryDeadBoxFeature:CarryDeadBox uMyCharacter is nil"))
    return
  end
  local bReject = false
  local bLegality = self:LegalityCheck(uInDeadBox)
  if not bLegality then
    print(bWriteLog and string.format("DeadBoxLog CarryDeadBoxFeature:CarryDeadBox Not Legality"))
    bReject = true
  end
  if not slua.isValid(uMyCharacter.SkillManager) then
    print(bWriteLog and string.format("DeadBoxLog CarryDeadBoxFeature:CarryDeadBox uMyCharacter.SkillManager is nil"))
    bReject = true
  end
  local bCastingCarry = uMyCharacter.SkillManager:IsCastingSkillID(DeadBoxCfg.CarryDeadBoxSkillID)
  if bCastingCarry then
    print(bWriteLog and string.format("DeadBoxLog CarryDeadBoxFeature:CarryDeadBox Is Casting CarryDeadBox Skill"))
    bReject = true
  end
  local bCastingPutDown = uMyCharacter.SkillManager:IsCastingSkillID(DeadBoxCfg.PutDownDeadBoxSkillID)
  if bCastingPutDown then
    print(bWriteLog and string.format("DeadBoxLog CarryDeadBoxFeature:CarryDeadBox Is Casting PutDown DeadBox Skill"))
    bReject = true
  end
  if uMyCharacter:HasState(EPawnState.CarryBox) then
    print(bWriteLog and string.format("DeadBoxLog CarryDeadBoxFeature:CarryDeadBox Is In CarryBox State"))
    bReject = true
  end
  if bReject then
    self:ClientRPC_RejectCarryBox()
    print(bWriteLog and string.format("DeadBoxLog CarryDeadBoxFeature:CarryDeadBox Reject"))
    return
  end
  self.CacheDeadBox = uInDeadBox
  self.CacheDeadBox:SetIsOccupied(true)
  uMyCharacter:AddSkillToken(DeadBoxCfg.CarryDeadBoxSkillID)
  uMyCharacter:TriggerEntrySkillWithID(DeadBoxCfg.CarryDeadBoxSkillID, true)
  uMyCharacter:ClearSkillToken(DeadBoxCfg.CarryDeadBoxSkillID)
end
function CarryDeadBoxFeature:ClientRPC_RejectCarryBox()
  print(bWriteLog and string.format("DeadBoxLog CarryDeadBoxFeature:ClientRPC_RejectCarryBox"))
  self:ResetSearchAndTickCheck()
  IngameTipsTools.BattleNormalTipsByTextID(69956)
end
function CarryDeadBoxFeature:ResetSearchAndTickCheck()
  print(bWriteLog and string.format("DeadBoxLog CarryDeadBoxFeature:ResetSearchAndTickCheck"))
  local uMyCharacter = self:GetMyCharacter()
  if slua.isValid(uMyCharacter) and slua.isValid(uMyCharacter.SearchOtherComponent) and uMyCharacter.Role == ENetRole.ROLE_AutonomousProxy then
    local ECharacterSearchEnum = import("ECharacterSearchEnum")
    local EExecutionCondition = import("EExecutionCondition")
    uMyCharacter.SearchOtherComponent:ResetSearchResult(ECharacterSearchEnum.CanCarryPlayerTombBox, EExecutionCondition.Client)
    uMyCharacter.SearchOtherComponent:ResetTickCheckTime(ECharacterSearchEnum.CanCarryPlayerTombBox, 0, EExecutionCondition.Client, false)
  end
end
function CarryDeadBoxFeature:RecordTlog(nTlogID, bInReset)
  if Client then
    return
  end
  print(bWriteLog and string.format("DeadBoxLog CarryDeadBoxFeature:RecordTlog nTlogID:%s bInReset:%s", tostring(nTlogID), tostring(bInReset)))
  local uMyCharacter = self:GetMyCharacter()
  if not slua.isValid(uMyCharacter) then
    return
  end
  local uPlayerState = uMyCharacter:GetPlayerStateSafety()
  if uPlayerState == nil or not slua.isValid(uPlayerState) then
    return
  end
  uPlayerState:AddGeneralCount(nTlogID, 1, bInReset)
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
local CCarryDeadBoxFeature = class(CFeatureBase, nil, CarryDeadBoxFeature)
return CCarryDeadBoxFeature