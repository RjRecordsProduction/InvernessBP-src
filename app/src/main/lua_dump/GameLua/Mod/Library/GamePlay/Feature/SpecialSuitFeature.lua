local EPawnState = import("EPawnState")
local ENetRole = import("ENetRole")
local USTExtraGameplayStatics = import("STExtraGameplayStatics")
local UTSkillStopReason = import("UTSkillStopReason")
local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local BackpackUtils = import("BackpackUtils")
local EBattleItemPickupReason = import("EBattleItemPickupReason")
local EBattleItemDropReason = import("EBattleItemDropReason")
local SuitSkillConfig = require("GameLua.ExtraModule.SkillCore.Gameplay.InflatableSuit.Skill.InflatableSuitConfig")
local SpecialSuitFeature = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {}
}
SpecialSuitFeature.MulticastRPC.MulticastRPC_HitEffect = {
  Reliable = false,
  Params = {
    import("/Script/CoreUObject.Vector")
  }
}
function SpecialSuitFeature:MulticastRPC_HitEffect(uInLocation)
  if not Client then
    return
  end
  local uLocation = uInLocation
  self:AsyncLoadAsset(SuitSkillConfig.HitEffectSound, function(AKEvent)
    if AKEvent and self and self.Owner and slua.isValid(self.Owner.Object) then
      local UAkGameplayStatics = import("AkGameplayStatics")
      UAkGameplayStatics.PostEventAtLocation(AKEvent, uLocation, FRotator(0, 0, 0), "", CGameWorld)
    end
  end)
  self:AsyncLoadAsset(SuitSkillConfig.HitEffectParticle, function(uPartcileSystem)
    if uPartcileSystem and self and self.Owner and slua.isValid(self.Owner.Object) then
      local UGameplayStatics = import("GameplayStatics")
      UGameplayStatics.SpawnEmitterAtLocation(CGameWorld, uPartcileSystem, uLocation, FRotator(0, 0, 0), FVector(1, 1, 1), true)
    end
  end)
end
function SpecialSuitFeature:_PostConstruct()
  SpecialSuitFeature.__super._PostConstruct(self)
end
function SpecialSuitFeature:ReceiveBeginPlay()
  print(bWriteLog and string.format("SpecialSuitFeature:ReceiveBeginPlay"))
  SpecialSuitFeature.__super.ReceiveBeginPlay(self)
  local uMyCharacter = self:GetMyCharacter()
  self.CanPlayeInflatableSuitEffectTime = 0
  if Client then
  elseif slua.isValid(uMyCharacter) then
    self:AddControlEventWithCondition(uMyCharacter, "StateEnterHandler", {
      state = {
        EPawnState.SpecialSuit
      }
    }, self.HandleOnEnterState, self)
    self:AddControlEventWithCondition(uMyCharacter, "StateLeaveHandler", {
      state = {
        EPawnState.SpecialSuit
      }
    }, self.HandleOnLeaveState, self)
    self:AddControlEventWithCondition(uMyCharacter, "StateInterruptedHandlerBP", {
      State = {
        EPawnState.SpecialSuit
      }
    }, self.HandleOnInterrupted, self)
    self:AddControlEvent(uMyCharacter, "OnHandleSkillStartDelegate", self.OnPawnSkillStart, self)
    self:AddControlEvent(uMyCharacter, "OnHandleSkillEndDelegate", self.OnPawnSkillEnd, self)
  else
    print(bWriteLog and string.format("SpecialSuitFeature:ReceiveBeginPlay uMyCharacter is nil for AddControlEvent"))
  end
end
function SpecialSuitFeature:OnPawnSkillStart(uSkillCharacter, SkillID)
  if Client then
  elseif SuitSkillConfig.SuitDashSkillID == SkillID then
    print(bWriteLog and string.format("SpecialSuitFeature:OnPawnSkillStart SuitDashSkill"))
    if slua.isValid(uSkillCharacter) then
      local uCharMoveComp = uSkillCharacter.STCharacterMovement
      if not slua.isValid(uCharMoveComp) then
        return
      end
      uCharMoveComp.ExtraLocDiffScale = 3.0
    end
  end
end
function SpecialSuitFeature:OnPawnSkillEnd(Character, Reason, SkillID)
  if Client then
  elseif SuitSkillConfig.SuitDashSkillID == SkillID then
    print(bWriteLog and string.format("SpecialSuitFeature:OnPawnSkillEnd SuitDashSkill"))
    if slua.isValid(Character) then
      local uCharMoveComp = Character.STCharacterMovement
      if not slua.isValid(uCharMoveComp) then
        return
      end
      uCharMoveComp.ExtraLocDiffScale = 1.0
    end
  end
end
function SpecialSuitFeature:HandleOnEnterState(InState)
  if InState == EPawnState.SpecialSuit then
    self:OnCharacterStatesChange(EPawnState.SpecialSuit, true)
  end
end
function SpecialSuitFeature:HandleOnLeaveState(InState)
  if InState == EPawnState.SpecialSuit then
    self:OnCharacterStatesChange(EPawnState.SpecialSuit, false)
  end
end
function SpecialSuitFeature:HandleOnInterrupted(InState, _)
  if InState == EPawnState.SpecialSuit then
    self:OnCharacterStatesChange(EPawnState.SpecialSuit, false)
  end
end
function SpecialSuitFeature:OnCharacterStatesChange(PawnState, bEnterState)
  if PawnState == EPawnState.SpecialSuit then
    local uMyCharacter = self:GetMyCharacter()
    if not slua.isValid(uMyCharacter) then
      print(bWriteLog and string.format("SpecialSuitFeature:OnCharacterStatesChange uMyCharacter is nil"))
      return
    end
    if bEnterState then
      self:PickUpSuit()
      self:AddControlEvent(uMyCharacter, "OnMoveBlockDelegate", self.OnServerMoveBlock, self)
    else
      self:TakeOffSuit()
      self:RemoveControlEvent(uMyCharacter, "OnMoveBlockDelegate")
    end
  end
end
function SpecialSuitFeature:PickUpSuit()
  local uMyCharacter = self:GetMyCharacter()
  if not slua.isValid(uMyCharacter) then
    print(bWriteLog and string.format("SpecialSuitFeature:PickUpSuit uMyCharacter is nil"))
    return
  end
  print(bWriteLog and string.format("SpecialSuitFeature:PickUpSuit"))
  local BackPackComp = USTExtraBlueprintFunctionLibrary.GetBackpackComponentFromCharacter(uMyCharacter)
  if slua.isValid(BackPackComp) then
    local nCount = Game:GetItemNumByResID(uMyCharacter, SuitSkillConfig.SuitAvatarID)
    if 0 < nCount then
      print(bWriteLog and string.format("SpecialSuitFeature:PickUpSuit uMyCharacter has InflatableSuit"))
      return
    end
    local SuitItemHandle = BackpackUtils.GenerateItemDefineIDByItemTableIDWithRandomInstanceID(SuitSkillConfig.SuitAvatarID)
    local PickupInfo = {}
    PickupInfo.Count = 1
    BackPackComp:PickupItem(SuitItemHandle, PickupInfo, EBattleItemPickupReason.Initial, 0)
    if slua.isValid(uMyCharacter.SkillManager) then
      uMyCharacter.SkillManager:TryAddOneSkill(SuitSkillConfig.SuitDashSkillID, true, 0)
      uMyCharacter:AddSkillToken(SuitSkillConfig.SuitDashSkillID)
    else
      print(bWriteLog and string.format("SpecialSuitFeature:PickUpSuit uMyCharacter.SkillManager is nil"))
    end
  end
end
function SpecialSuitFeature:TakeOffSuit()
  local uMyCharacter = self:GetMyCharacter()
  if not slua.isValid(uMyCharacter) then
    print(bWriteLog and string.format("SpecialSuitFeature:TakeOffSuit uMyCharacter is nil"))
    return
  end
  print(bWriteLog and string.format("SpecialSuitFeature:TakeOffSuit"))
  local BackPackComp = USTExtraBlueprintFunctionLibrary.GetBackpackComponentFromCharacter(uMyCharacter)
  if slua.isValid(BackPackComp) then
    local SuitItemHandle = BackPackComp:GetFirstItemByDefineIDIgnoreInstance(BackpackUtils.GetItemDefineIDByItemID(SuitSkillConfig.SuitAvatarID))
    BackPackComp:DropItem(SuitItemHandle.DefineID, 1, EBattleItemDropReason.Force)
    if slua.isValid(uMyCharacter.SkillManager) then
      uMyCharacter.SkillManager:TryDeleteOneSkill(SuitSkillConfig.SuitDashSkillID, true, false)
      uMyCharacter:ClearSkillToken(SuitSkillConfig.SuitDashSkillID)
    else
      print(bWriteLog and string.format("SpecialSuitFeature:PickUpSuit uMyCharacter.SkillManager is nil"))
    end
  end
end
function SpecialSuitFeature:OnServerMoveBlock(uSelfCharacter, uInHitResult)
  if not slua.isValid(uSelfCharacter) or not uSelfCharacter.SpecialSuitFeature then
    return
  end
  if not (uInHitResult and uInHitResult.Actor and slua.isValid(uInHitResult.Actor)) or not uInHitResult.Actor.SpecialSuitFeature then
    return
  end
  local uOtherCharacter = uInHitResult.Actor
  local CurrentTime = CGameState:GetServerWorldTimeSeconds()
  if uSelfCharacter.CanPlayeInflatableSuitEffectTime and CurrentTime < uSelfCharacter.CanPlayeInflatableSuitEffectTime and uOtherCharacter.CanPlayeInflatableSuitEffectTime and CurrentTime < uOtherCharacter.CanPlayeInflatableSuitEffectTime then
    return
  end
  if not uSelfCharacter:HasState(EPawnState.SpecialSuit) or not uOtherCharacter:HasState(EPawnState.SpecialSuit) then
    return
  end
  if not uSelfCharacter:IsCastingSkillIDFix(SuitSkillConfig.SuitDashSkillID) and not uOtherCharacter:IsCastingSkillIDFix(SuitSkillConfig.SuitDashSkillID) then
    return
  end
  uSelfCharacter.CanPlayeInflatableSuitEffectTime = CurrentTime + SuitSkillConfig.HitEffectCD
  uOtherCharacter.CanPlayeInflatableSuitEffectTime = CurrentTime + SuitSkillConfig.HitEffectCD
  print(bWriteLog and string.format("SpecialSuitFeature:OnServerMoveBlock Update Hit Time Self:%s, Other:%s , Time:%s", tostring(uSelfCharacter.PlayerKey), tostring(uOtherCharacter.PlayerKey), tostring(uSelfCharacter.CanPlayeInflatableSuitEffectTime)))
  local HitPos = FVector(uInHitResult.Location.X + SuitSkillConfig.EffectOffset.X, uInHitResult.Location.Y + SuitSkillConfig.EffectOffset.Y, uInHitResult.Location.Z + SuitSkillConfig.EffectOffset.Z)
  self:MulticastRPC_HitEffect(HitPos)
  print(bWriteLog and string.format("SpecialSuitFeature:OnServerMoveBlock HitPos:%s Self:%s, Other:%s", tostring(HitPos:ToString()), tostring(uSelfCharacter.PlayerKey), tostring(uOtherCharacter.PlayerKey)))
end
function SpecialSuitFeature:GetMyCharacter()
  if self.Owner then
    return self.Owner.Object
  end
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
local CSpecialSuitFeature = class(CFeatureBase, nil, SpecialSuitFeature)
return CSpecialSuitFeature