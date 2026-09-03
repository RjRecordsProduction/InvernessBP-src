local UGameplayStatics = import("GameplayStatics")
local SkillConfig = require("GameLua.Mod.Library.GamePlay.Skill.SkillConfig")
local UltraHandBeCatchedFeature = {bCanBeCatched = true}
local ASTExtraBaseCharacter = import("/Script/ShadowTrackerExtra.STExtraBaseCharacter")
local EMovementMode = import("EMovementMode")
local SkillUtils = require("GameLua.GameCore.Module.Skill.SkillUtils")
local ESurviveWeaponPropSlot = import("ESurviveWeaponPropSlot")
local EPawnState = import("EPawnState")
local EMechaState = import("EMechaState")
local AMechaVehicle = import("MechaVehicle")
function UltraHandBeCatchedFeature:_PostConstruct()
  UltraHandBeCatchedFeature.__super._PostConstruct(self)
  self.isReconnectInit = true
  self.CastCharacter = nil
  self.LastCastCharacter = nil
end
function UltraHandBeCatchedFeature:ReceiveBeginPlay()
  UltraHandBeCatchedFeature.__super.ReceiveBeginPlay(self)
  if not Client then
    self.BeTeammateCatchTime = -SkillConfig.UltraHandSkill.CatchTeammateInternal
  end
end
function UltraHandBeCatchedFeature:GetLastCatchCharacter()
  return self.LastCastCharacter
end
function UltraHandBeCatchedFeature:SetBeTeammateCatchCD(bSet)
  if bSet then
    self.BeTeammateCatchTime = CGameState:GetServerWorldTimeSeconds()
  else
    self.BeTeammateCatchTime = -SkillConfig.UltraHandSkill.CatchTeammateInternal
  end
end
function UltraHandBeCatchedFeature:CanBeTeammateCatched()
  local CurSeconds = CGameState:GetServerWorldTimeSeconds()
  local ElapseTime = CurSeconds - self.BeTeammateCatchTime
  if ElapseTime >= SkillConfig.UltraHandSkill.CatchTeammateInternal then
    return true, 0
  end
  local nRemainSeconds = math.ceil(SkillConfig.UltraHandSkill.CatchTeammateInternal - ElapseTime)
  return false, nRemainSeconds
end
function UltraHandBeCatchedFeature:SetBeCatched(uCharacter, nSkillID)
  self.CastCharacter = uCharacter
  self.SkillID = nSkillID
  if uCharacter and uCharacter.PlayerKey then
    printf("DebugUltraHand UltraHandBeCatchedFeature SetBeCatched PlayerKey:%u Role:%d nSkillID:%d", uCharacter.PlayerKey, uCharacter.Role, nSkillID)
  end
  if self:IsAuthority() then
    if Game:IsClassOf(self.Owner.Object, ASTExtraBaseCharacter) then
      if self.CastCharacter ~= nil and slua.isValid(self.CastCharacter) then
        self.LastCastCharacter = self.CastCharacter
        self.CacheWeaponMgr = self.Owner:GetWeaponManager()
        if slua.isValid(self.CacheWeaponMgr) then
          self:AddControlEvent(self.CacheWeaponMgr, "LocalEquipWeaponFromBackpackFinishedDelegate", self.UnEquipWeapon, self)
        end
        self:AddControlEvent(self.Owner.Object, "MovementModeChangedDelegate", self.ResetMovementMode, self)
        self:AddControlEvent(self.Owner.Object, "OnDeathDelegate", self.HandCharacterDead, self)
        if self.Owner:IsCastingSkill() then
          local UTSkillStopReason = import("UTSkillStopReason")
          self.Owner:StopAllSkills(UTSkillStopReason.SkillStopReason_Interrupted)
        end
        local uCarryBackComp = self.Owner:GetCarryBackComp()
        self:AddControlEvent(uCarryBackComp, "OnEnterCarryBackState", self.HandleCarryCharacter, self)
      else
        self:UnBindBeCatchedEvent()
      end
    end
    if Game:IsClassOf(self.Owner.Object, AMechaVehicle) then
      if self.CastCharacter ~= nil and slua.isValid(self.CastCharacter) then
        self:AddControlEvent(self.Owner.Object, "OnMechaEnterState", self.HandOnMechaEnterState, self)
      else
        self:UnBindBeCatchedEvent()
      end
    end
    if self.CastCharacter ~= nil and slua.isValid(self.CastCharacter) then
      self.bCanBeCatched = false
    else
      self.bCanBeCatched = true
    end
    self:ForceNetUpdate()
  end
end
function UltraHandBeCatchedFeature:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  local RepTable = {
    {
      "bCanBeCatched",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Bool
    }
  }
  return RepTable
end
function UltraHandBeCatchedFeature:OnRep_bCanBeCatched()
  if Game:IsClassOf(self.Owner.Object, ASTExtraBaseCharacter) then
    if self:IsAutonomousProxy() then
      EventSystem:postEvent(EVENTTYPE_INGAME_SKILL, EVENTID_INGAME_ULTRAHAND_RESET_SELECT)
    end
    if self.isReconnectInit and not self.bCanBeCatched then
      self.isReconnectInit = false
      self:BeCatchedCharacterReconnected()
    end
  end
  SkillUtils.ShowActorOutline(self.Owner.Object, not self.bCanBeCatched, FLinearColor(0.0, 0.25, 1, 1), 0.5)
end
function UltraHandBeCatchedFeature:BeCatchedCharacterReconnected()
  local uCharacterMoveComp = self.Owner.STCharacterMovement
  if slua.isValid(uCharacterMoveComp) then
    uCharacterMoveComp:Deactivate()
    local EMovementMode = import("EMovementMode")
    printf("CharacterBase:HandleParachuteStateChangedEvent BeCatchedCharacterReconnected call")
    uCharacterMoveComp:SetMovementMode(EMovementMode.MOVE_None, 0)
    uCharacterMoveComp.bDisableResetWhenSimulateNoReceive = true
    uCharacterMoveComp.bAbandonReplicatedMovement = true
    if self.Owner.CharacterUltraHandRepFeature and self.Owner.CharacterUltraHandRepFeature.StartCheckBeCatchedStateRecover then
      self.Owner.CharacterUltraHandRepFeature:StartCheckBeCatchedStateRecover()
    end
  end
end
function UltraHandBeCatchedFeature:CanBeCatched(PickParams)
  if self.bCanBeCatched then
    return true
  else
    self:SyncDsNotBeCatched(PickParams)
    return false
  end
end
function UltraHandBeCatchedFeature:SyncDsNotBeCatched(PickParams)
  if not Client and PickParams then
    local uCastCharacter = PickParams.OwnerActor
    if slua.isValid(uCastCharacter) and uCastCharacter.SkillManager then
      local uSkillMgr = uCastCharacter.SkillManager
      if slua.isValid(uSkillMgr) then
        uSkillMgr:SetValueAsObject(PickParams.SkillID, "TargetObject", nil)
      end
    end
  end
end
function UltraHandBeCatchedFeature:UnEquipWeapon()
  local uWeapon = self.Owner:GetCurrentWeapon()
  if uWeapon and slua.isValid(uWeapon) then
    self.Owner:SwitchWeaponBySlot(ESurviveWeaponPropSlot.SWPS_None, false, true, true)
  end
end
function UltraHandBeCatchedFeature:ResetMovementMode(uCharacter, preMovementMode, preCustomMode)
  if self.Owner:HasState(EPawnState.Arrest) then
    local uMovemoment = self.Owner.STCharacterMovement
    if slua.isValid(uMovemoment) and uMovemoment.MovementMode ~= EMovementMode.MOVE_None then
      printf("DebugUltraHand UltraHandBeCatchedFeature ResetMovementMode uCharacter PlayerKey:%u, Role:%d", uCharacter.PlayerKey, uCharacter.Role)
      uMovemoment:Deactivate()
      uMovemoment:SetMovementMode(EMovementMode.MOVE_None, 0)
    end
  end
end
function UltraHandBeCatchedFeature:HandCharacterDead(uCharacter)
  printf("DebugUltraHand UltraHandBeCatchedFeature HandCharacterDead uCharacter PlayerKey:%u, Role:%d", uCharacter.PlayerKey, uCharacter.Role)
  self:TriggerSkillInterrupt()
end
function UltraHandBeCatchedFeature:HandleCarryCharacter()
  printf("DebugUltraHand UltraHandBeCatchedFeature HandleCarryCharacter")
  self:TriggerSkillInterrupt()
end
function UltraHandBeCatchedFeature:HandOnMechaEnterState(eState)
  if eState == EMechaState.Combine or eState == EMechaState.Uncombine then
    printf("DebugUltraHand UltraHandBeCatchedFeature HandOnMechaEnterState")
    self:TriggerSkillInterrupt()
  end
end
function UltraHandBeCatchedFeature:UnBindBeCatchedEvent()
  if self:IsAuthority() then
    printf("DebugUltraHand UltraHandBeCatchedFeature UnBindBeCatchedEvent")
    if Game:IsClassOf(self.Owner.Object, ASTExtraBaseCharacter) then
      if self.CacheWeaponMgr then
        self:RemoveControlEvent(self.CacheWeaponMgr, "LocalEquipWeaponFromBackpackFinishedDelegate")
        self.CacheWeaponMgr = nil
      end
      self:RemoveControlEvent(self.Owner.Object, "MovementModeChangedDelegate")
      self:RemoveControlEvent(self.Owner.Object, "OnDeathDelegate")
      local uCarryBackComp = self.Owner:GetCarryBackComp()
      self:RemoveControlEvent(uCarryBackComp, "OnEnterCarryBackState")
    elseif Game:IsClassOf(self.Owner.Object, AMechaVehicle) then
      self:RemoveControlEvent(self.Owner.Object, "OnMechaEnterState")
    end
  end
end
function UltraHandBeCatchedFeature:TriggerSkillInterrupt()
  if self:IsAuthority() and slua.isValid(self.CastCharacter) then
    local uSkillMgr = self.CastCharacter:GetSkillManager()
    if slua.isValid(uSkillMgr) and self.SkillID > 0 then
      printf("DebugUltraHand UltraHandBeCatchedFeature TriggerSkillInterrupt PlayerKey:%u Role:%d", self.CastCharacter.PlayerKey, self.CastCharacter.Role)
      uSkillMgr:TriggerStringEvent(self.SkillID, "Cancle")
    end
    self.CastCharacter = nil
  end
  self:UnBindBeCatchedEvent()
end
function UltraHandBeCatchedFeature:ReceiveEndPlay(EndPlayReason)
  printf("DebugUltraHand UltraHandBeCatchedFeature ReceiveEndPlay")
  self:TriggerSkillInterrupt()
  UltraHandBeCatchedFeature.__super.ReceiveEndPlay(self, EndPlayReason)
end
function UltraHandBeCatchedFeature:ClientSetCasterAndSkillID(InCaster, InSkillID)
  self.CastCharacter = InCaster
  self.SkillID = InSkillID
end
function UltraHandBeCatchedFeature:DelayTriggerStringEvent(DelaySeconds, StrEvent, bOnlyLocal)
  self:AddGameTimer(DelaySeconds, false, function()
    printf("DebugUltraHand UltraHandBeCatchedFeature DelayTriggerStringEvent StrEvent:%s", StrEvent)
    if slua.isValid(self.CastCharacter) and self.Owner.HasState and self.Owner:HasState(EPawnState.Arrest) then
      local SkillManager = self.CastCharacter:GetSkillManager()
      if slua.isValid(SkillManager) then
        printf("DebugUltraHand UltraHandBeCatchedFeature DelayTriggerStringEvent self.CastCharacter:%d self.SkillID:%d", self.CastCharacter.PlayerKey, self.SkillID)
        if self.Owner.TeamID == self.CastCharacter.TeamID then
          SkillManager:SetValueAsInt(self.SkillID, "CatchedAnimType", 0)
        else
          SkillManager:SetValueAsInt(self.SkillID, "CatchedAnimType", 1)
        end
        if bOnlyLocal then
          SkillManager:TriggerStringEventLocal(self.SkillID, StrEvent)
        else
          SkillManager:TriggerStringEvent(self.SkillID, StrEvent)
        end
      end
    else
      printf("DebugUltraHand UltraHandBeCatchedFeature DelayTriggerStringEvent self.CastCharacter == nil")
    end
  end)
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
return class(CFeatureBase, nil, UltraHandBeCatchedFeature)