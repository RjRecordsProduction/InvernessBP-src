local CharacterAnimInstance = {}
local EParachuteState = import("EParachuteState")
local EMovementMode = import("EMovementMode")
local ECustomMovmentMode = import("ECustomMovmentMode")
function CharacterAnimInstance:BpOnActived()
  self.uCharacter = self.C_OwnerCharacter
  if self.uCharacter == nil then
    return
  end
  self:AddControlEvent(self.uCharacter, "OnPerspectiveChanged", self.HandleFPPChange, self)
  self:AddControlEvent(self.uCharacter, "OnCharacterCameraModeChange", self.HandleFPPChange, self)
  self:AddControlEvent(self.uCharacter, "OnHandleSkillStartDelegate", self.HandleSkillStart, self)
  self:AddControlEvent(self.uCharacter, "OnHandleSkillEndDelegate", self.HandleSkillEnd, self)
  self:AddControlEvent(self.uCharacter, "OnClientCurrentVehicleChange", self.HandleAttachedToVehicle, self)
  self:AddControlEvent(self.uCharacter, "OnClientCurrentVehicleCharacterAnimChange", self.RefreshCharacterAnim, self)
  self:AddControlEvent(self.uCharacter, "OnDetachedFromVehicle", self.HandleDetachedFromVehicle, self)
  self:AddControlEvent(self.uCharacter, "OnCharacterWeaponEquipDelegate", self.HandleWeaponEquip, self)
  self:AddControlEvent(self.uCharacter, "OnCharacterWeaponUnEquipDelegate", self.HandleWeaponUnEquip, self)
  self:AddControlEvent(self.uCharacter, "OnCharacerEnterWater", self.HandleEnterWater, self)
  self:AddControlEvent(self.uCharacter, "OnCharacterExitWater", self.HandleExitWater, self)
  self:AddControlEvent(self.uCharacter, "HandleParachuteStateChangedOver", self.HandleParachuteStateChange, self)
  self:AddControlEvent(self.uCharacter, "OnCharacterEnableMoveLayer", self.HandleEnableMoveLayer, self)
  self:AddControlEvent(self.uCharacter, "IsEnterNearDeathDelegate", self.HandleEnterNearDeath, self)
  self:AddControlEvent(self.uCharacter, "OnCharacterUseLadder", self.HandleOnCharacterUseLadder, self)
  self:AddControlEvent(self.uCharacter, "OnSetAnimBpFinished", self.HandleOnSetAnimBpFinished, self)
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  if UKismetSystemLibrary.IsStandalone(self.uCharacter) and slua.isValid(self.uCharacter:GetPlayerControllerSafety()) then
    self:AddControlEvent(self.uCharacter:GetPlayerControllerSafety(), "OnEnterVehicleDelegate", self.HandleOnEnterVehicleDelegate, self)
  end
  self:InitCheckAddInstance()
end
function CharacterAnimInstance:InitCheckAddInstance()
  local uOwnerCharacter = self.C_OwnerCharacter
  if uOwnerCharacter == nil then
    return
  end
  local uAnimParamsComp = uOwnerCharacter:GetAnimParamsComponent()
  if not uAnimParamsComp then
    return
  end
  local bIsFPP = uOwnerCharacter:GetIsFPP()
  print(bWriteLog and "CharacterAnimInstance InitCheckAddInstance, bIsFPP:" .. tostring(bIsFPP) .. ",bIsFPPAnimInstace:" .. tostring(self.bIsFPPAnimInstace))
  uAnimParamsComp:ActiveAnimContainer("AC.Locomotion", false)
  if self.FEATURE_HitAnimInstanceID ~= nil then
    local HitAnimClass = uAnimParamsComp:GetCustomizableAnimBP(self.FEATURE_HitAnimInstanceID)
    if HitAnimClass then
      uAnimParamsComp:ActiveAnimContainerWithInstance("AC.Hit", HitAnimClass, false)
    end
  end
  local uSkillMgr = uOwnerCharacter:GetSkillManager()
  if uSkillMgr and uSkillMgr:IsCastingSkill() then
    local nSkillID = uSkillMgr:GetCurSkillID(nil)
    self:HandleSkillStart(uOwnerCharacter, nSkillID)
  end
  local uVehicle = uOwnerCharacter:GetCurrentVehicle()
  if slua.isValid(uVehicle) then
    self:HandleAttachedToVehicle(uVehicle)
  end
  local uWeapon = uOwnerCharacter:GetCurrentWeapon()
  if slua.isValid(uWeapon) then
    self:HandleWeaponEquip(uWeapon, 0)
  end
  local uMoveComp = uOwnerCharacter.STCharacterMovement
  if not uMoveComp then
    return
  end
  if uMoveComp.MovementMode == EMovementMode.MOVE_Swimming then
    self:HandleEnterWater("Normal")
  else
    local uDivingComp = uOwnerCharacter.DivingComponent
    if slua.isValid(uDivingComp) and uDivingComp:IsInDivingRegion() then
      self:HandleEnterWater("Diving")
    end
  end
  if uOwnerCharacter.ParachuteState ~= EParachuteState.PS_None then
    self:HandleParachuteStateChange(uOwnerCharacter.ParachuteState)
  end
  if uOwnerCharacter:EnableLinkedMoveLayer() then
    self:HandleEnableMoveLayer("1", uOwnerCharacter.EnableAnimLayerIns)
  end
  if uOwnerCharacter:IsNearDeath() then
    self:HandleEnterNearDeath(true)
  end
  if uOwnerCharacter.LifterControl and uMoveComp.MovementMode == EMovementMode.MOVE_Custom and uMoveComp.CustomMovementMode == ECustomMovmentMode.CUSTOM_MOVE_LifterControl then
    uOwnerCharacter.LifterControl:SetLiftControlInstance(true)
  end
  if uMoveComp.MovementMode == EMovementMode.MOVE_Custom and uMoveComp.CustomMovementMode == ECustomMovmentMode.CUSTOM_MOVE_Climb then
    self:HandleOnCharacterUseLadder("Enter")
  end
  if slua.isValid(uOwnerCharacter) then
    uOwnerCharacter:LuaBroadcast("OnCharacterAnimInstanceInit")
    self:AddGameTimer(0, false, function()
      if not self or not slua.isValid(self.Object) then
        return
      end
      if slua.isValid(self.C_OwnerCharacter) then
        self.C_OwnerCharacter:LuaBroadcast("OnCharacterAnimInstanceInitFrameDelay")
        printf(bWriteLog and "CharacterAnimInstance:Init, Broadcast OnCharacterAnimInstanceInitFrameDelay")
      end
    end)
  end
end
function CharacterAnimInstance:BpOnDeactived()
  print(bWriteLog and "CharacterAnimInstance:BpOnDeactived 0")
  self:Dispose()
  local uOwnerCharacter = self.C_OwnerCharacter
  if not slua.isValid(uOwnerCharacter) then
    print(bWriteLog and "CharacterAnimInstance:BpOnDeactived 1")
    return
  end
  local uAnimParamsComp = uOwnerCharacter:GetAnimParamsComponent()
  if not uAnimParamsComp then
    print(bWriteLog and "CharacterAnimInstance:BpOnDeactived 2")
    return
  end
  self.bFPP = nil
  printf(bWriteLog and "CharacterAnimInstance BpOnDeactived %u", uOwnerCharacter.PlayerKey)
  uAnimParamsComp:DeactiveAnimContainer("AC.Locomotion", false)
  uAnimParamsComp:DeactiveAnimContainer("AC.Parachute", false)
  uAnimParamsComp:DeactiveAnimContainerWithInstance("AC.Hit", nil, false)
  uAnimParamsComp:DeactiveAnimContainerWithInstance("AC.Swim", nil, false)
  uAnimParamsComp:DeactiveAnimContainerWithInstance("AC.Skill", nil, false)
  uAnimParamsComp:DeactiveAnimContainerWithInstance("AC.Vehicle", nil, false)
  uAnimParamsComp:DeactiveAnimContainerWithInstance("AC.Weapon", nil, false)
  uAnimParamsComp:DeactiveAnimContainerWithInstance("AC.MoveLayer", nil, false)
  uAnimParamsComp:DeactiveAnimContainerWithInstance("AC.NearDeath", nil, false)
  uAnimParamsComp:DeactiveAnimContainerWithInstance("AC.Ladder", nil, false)
end
function CharacterAnimInstance:HandleFPPChange(IsFPP)
  local uOwnerCharacter = self.C_OwnerCharacter
  if uOwnerCharacter == nil or uOwnerCharacter.GetIsFPP == nil then
    return
  end
  local bFPP = uOwnerCharacter:GetIsFPP()
  if self.bFPP == nil or self.bFPP ~= bFPP then
    self.    self:InitCheckAddInstance()
  end
end
function CharacterAnimInstance:HandleSkillStart(uOwnerCharacter, nSkillID)
  if not slua.isValid(uOwnerCharacter) or nSkillID <= 0 then
    return
  end
  if uOwnerCharacter.GetIsFPP == nil then
    return
  end
  if uOwnerCharacter:GetIsFPP() ~= self.bIsFPPAnimInstace then
    return
  end
  local SkillAnimClass = uOwnerCharacter:GetCharacterSkillAnimBP(nSkillID)
  if SkillAnimClass then
    local uAnimParamsComp = uOwnerCharacter:GetAnimParamsComponent()
    if uAnimParamsComp then
      uAnimParamsComp:ActiveAnimContainerWithInstance("AC.Skill", SkillAnimClass, false)
      self.bShouldUseSkillContainer = true
    end
  end
end
function CharacterAnimInstance:HandleSkillEnd(uOwnerCharacter, eStopReason, nSkillID)
  if not slua.isValid(uOwnerCharacter) or nSkillID <= 0 then
    return
  end
  if uOwnerCharacter:GetIsFPP() ~= self.bIsFPPAnimInstace then
    return
  end
  local SkillAnimClass = uOwnerCharacter:GetCharacterSkillAnimBP(nSkillID)
  if SkillAnimClass then
    local uAnimParamsComp = uOwnerCharacter:GetAnimParamsComponent()
    if uAnimParamsComp then
      uAnimParamsComp:DeactiveAnimContainerWithInstance("AC.Skill", SkillAnimClass, true)
      self.bShouldUseSkillContainer = false
    end
  end
end
function CharacterAnimInstance:HandleAttachedToVehicle(uVehicle)
  self:RefreshCharacterAnim(uVehicle)
end
function CharacterAnimInstance:RefreshCharacterAnim(uVehicle)
  if not slua.isValid(uVehicle) then
    return
  end
  local uOwnerCharacter = self.C_OwnerCharacter
  if uOwnerCharacter == nil then
    return
  end
  if uOwnerCharacter:GetIsFPP() ~= self.bIsFPPAnimInstace then
    return
  end
  local nVehicleIndex = uOwnerCharacter:GetVehicleSeatSafetyIndex()
  if nVehicleIndex == -1 then
    printf(bWriteLog and "CharacterAnimInstance HandleAttachedToVehicle nVehicleIndex == -1 %u", uOwnerCharacter.PlayerKey)
    return
  end
  local uAnimClass = uVehicle:GetCharacterInVehicleAnimBP(nVehicleIndex)
  local uMesh = self:GetOwningComponent()
  if uAnimClass and uMesh then
    printf(bWriteLog and "CharacterAnimInstance HandleAttachedToVehicle Set Vehicle SubInstance")
    uMesh:SetSubInstance("Vehicle", uAnimClass)
    local uRunningVehicleInstance = uMesh:GetSubInstance("Vehicle")
    if slua.isValid(uRunningVehicleInstance) and uRunningVehicleInstance.IsFPPVehicleAnimInstace ~= nil then
      uRunningVehicleInstance.IsFPPVehicleAnimInstace = self.bIsFPPAnimInstace
    end
  end
end
function CharacterAnimInstance:HandleDetachedFromVehicle(uVehicle)
  local uOwnerCharacter = self.C_OwnerCharacter
  if uOwnerCharacter == nil then
    return
  end
  local uMesh = self:GetOwningComponent()
  if uMesh then
    printf(bWriteLog and "CharacterAnimInstance HandleDetachedFromVehicle, Clear Vehicle SubInstance")
    uMesh:SetSubInstance("Vehicle", nil)
  end
end
function CharacterAnimInstance:HandleOnEnterVehicleDelegate(bEnter, uVehicle)
  if bEnter then
    self:HandleAttachedToVehicle(uVehicle)
  else
    self:HandleDetachedFromVehicle(nil)
  end
end
function CharacterAnimInstance:HandleWeaponEquip(uWeapon, nSlot)
  if not slua.isValid(uWeapon) then
    return
  end
  self:HandleOverrideWeaponEquip(uWeapon, nSlot)
  local uOwnerCharacter = self.C_OwnerCharacter
  if uOwnerCharacter == nil or uOwnerCharacter.GetIsFPP == nil then
    return
  end
  if uOwnerCharacter:GetIsFPP() ~= self.bIsFPPAnimInstace then
    return
  end
  if uWeapon.GetCharWeaponAnimBP == nil then
    return
  end
  local uWeaponAnimClass = uWeapon:GetCharWeaponAnimBP()
  local uAnimParamsComp = uOwnerCharacter:GetAnimParamsComponent()
  if uWeaponAnimClass and uAnimParamsComp then
    uAnimParamsComp:ActiveAnimContainerWithInstance("AC.Weapon", uWeaponAnimClass, false)
    self.bEnableWeaponAnimContainer = true
  end
end
function CharacterAnimInstance:HandleOverrideWeaponEquip(uWeapon, nSlot)
  local uOwnerCharacter = self.C_OwnerCharacter
  if not slua.isValid(uOwnerCharacter) or not slua.isValid(uOwnerCharacter.Mesh) then
    return
  end
  local WeaponEntity = uWeapon:GetWeaponEntityComponent()
  if slua.isValid(WeaponEntity) and slua.isValid(WeaponEntity.WeaponOverrideAnimBP) then
    uOwnerCharacter.Mesh:SetSubInstance("WeaponOverride", WeaponEntity.WeaponOverrideAnimBP)
    print(bWriteLog and string.format("CharacterAnimInstance:HandleOverrideWeaponEquip, Active WeaponOverride SubInstance! %s, %s", WeaponEntity.WeaponOverrideAnimBP, uOwnerCharacter:GetPlayerNameSafety()))
  end
end
function CharacterAnimInstance:HandleWeaponUnEquip(uWeapon)
  local uOwnerCharacter = self.C_OwnerCharacter
  if uOwnerCharacter == nil then
    return
  end
  self:HandleOverrideWeaponUnEquip(uWeapon)
  if uOwnerCharacter:GetIsFPP() ~= self.bIsFPPAnimInstace then
    return
  end
  local uAnimParamsComp = uOwnerCharacter:GetAnimParamsComponent()
  if uAnimParamsComp then
    uAnimParamsComp:DeactiveAnimContainerWithInstance("AC.Weapon", nil, true)
    self.bEnableWeaponAnimContainer = false
  end
end
function CharacterAnimInstance:HandleOverrideWeaponUnEquip(uWeapon)
  local uOwnerCharacter = self.C_OwnerCharacter
  if not slua.isValid(uOwnerCharacter) or not slua.isValid(uOwnerCharacter.Mesh) then
    return
  end
  uOwnerCharacter.Mesh:SetSubInstance("WeaponOverride", nil)
  print(bWriteLog and string.format("CharacterAnimInstance:HandleOverrideWeaponEquip, Deactive WeaponOverride SubInstance! %s", uOwnerCharacter:GetPlayerNameSafety()))
end
function CharacterAnimInstance:HandleEnterWater(sTag)
  local uOwnerCharacter = self.C_OwnerCharacter
  if uOwnerCharacter == nil or uOwnerCharacter.GetIsFPP == nil then
    return
  end
  local uAnimParamsComp = uOwnerCharacter:GetAnimParamsComponent()
  if not uAnimParamsComp then
    return
  end
  if uOwnerCharacter:GetIsFPP() ~= self.bIsFPPAnimInstace then
    return
  end
  local uAnimClass
  if sTag == "Diving" then
    uAnimClass = uAnimParamsComp:GetCustomizableAnimBP(100)
  else
    uAnimClass = self.SwimAnimDefaultABP
  end
  if self.DelayExitWaterTimer ~= nil then
    self:RemoveGameTimer(self.DelayExitWaterTimer)
    self.DelayExitWaterTimer = nil
  end
  uAnimParamsComp:ActiveAnimContainerWithInstance("AC.Swim", uAnimClass, true)
end
function CharacterAnimInstance:HandleExitWater(sTag)
  local uOwnerCharacter = self.C_OwnerCharacter
  if uOwnerCharacter == nil then
    return
  end
  local uAnimParamsComp = uOwnerCharacter:GetAnimParamsComponent()
  if not uAnimParamsComp then
    return
  end
  if uOwnerCharacter:GetIsFPP() ~= self.bIsFPPAnimInstace then
    return
  end
  self:DelayHandleExitWater()
end
function CharacterAnimInstance:DelayHandleExitWater()
  if self.DelayExitWaterTimer ~= nil then
    self:RemoveGameTimer(self.DelayExitWaterTimer)
    self.DelayExitWaterTimer = nil
  end
  self.DelayExitWaterTimer = self:AddGameTimer(1, false, function()
    self.DelayExitWaterTimer = nil
    local uOwnerCharacter = self.C_OwnerCharacter
    if not slua.isValid(uOwnerCharacter) then
      return
    end
    local uAnimParamsComp = uOwnerCharacter:GetAnimParamsComponent()
    if not uAnimParamsComp then
      return
    end
    local uMovementComp = uOwnerCharacter.STCharacterMovement
    if slua.isValid(uMovementComp) and uMovementComp.MovementMode ~= EMovementMode.MOVE_Swimming then
      uAnimParamsComp:DeactiveAnimContainerWithInstance("AC.Swim", nil, false)
    end
  end)
end
function CharacterAnimInstance:HandleParachuteStateChange(eState)
  local uOwnerCharacter = self.C_OwnerCharacter
  if uOwnerCharacter == nil or uOwnerCharacter.GetIsFPP == nil then
    return
  end
  local uAnimParamsComp = uOwnerCharacter:GetAnimParamsComponent()
  if not uAnimParamsComp then
    return
  end
  local bFPP = uOwnerCharacter:GetIsFPP()
  if bFPP ~= self.bIsFPPAnimInstace then
    return
  end
  if eState == EParachuteState.PS_None then
    uAnimParamsComp:DeactiveAnimContainer("AC.Parachute", false)
  else
    uAnimParamsComp:ActiveAnimContainer("AC.Parachute", false)
  end
end
function CharacterAnimInstance:HandleEnableMoveLayer(sEnable, AnimInstance)
  local uOwnerCharacter = self.C_OwnerCharacter
  if uOwnerCharacter == nil then
    return
  end
  local bIsFPP = uOwnerCharacter:GetIsFPP()
  if bIsFPP ~= self.bIsFPPAnimInstace then
    print(bWriteLog and "[Warning]CharacterAnimInstance HandleEnableMoveLayer Failed, bIsFPP:" .. tostring(bIsFPP) .. ",bIsFPPAnimInstace:" .. tostring(self.bIsFPPAnimInstace))
    return
  end
  print(bWriteLog and "CharacterAnimInstance HandleEnableMoveLayer sEnable:" .. tostring(sEnable) .. ",AnimInstance:" .. tostring(AnimInstance) .. ",bIsFPP" .. tostring(bIsFPP) .. ",bIsFPPAnimInstace:" .. tostring(self.bIsFPPAnimInstace))
  local uAnimParamsComp = uOwnerCharacter:GetAnimParamsComponent()
  if not uAnimParamsComp then
    return
  end
  if sEnable then
    if AnimInstance then
      uAnimParamsComp:ActiveAnimContainerWithInstance("AC.MoveLayer", AnimInstance, false)
    end
  else
    uAnimParamsComp:DeactiveAnimContainerWithInstance("AC.MoveLayer", nil, false)
  end
end
function CharacterAnimInstance:HandleEnterNearDeath(bNearDeath)
  local uOwnerCharacter = self.C_OwnerCharacter
  if uOwnerCharacter == nil then
    return
  end
  if uOwnerCharacter:GetIsFPP() ~= self.bIsFPPAnimInstace then
    return
  end
  local uAnimParamsComp = uOwnerCharacter:GetAnimParamsComponent()
  if not uAnimParamsComp then
    return
  end
  if bNearDeath then
    local uNearDeathClass = uAnimParamsComp:GetCustomizableAnimBP(self.FEATURE_NearDeathAnimInstanceID)
    if uNearDeathClass then
      uAnimParamsComp:ActiveAnimContainerWithInstance("AC.NearDeath", uNearDeathClass, false)
    end
  else
    uAnimParamsComp:DeactiveAnimContainerWithInstance("AC.NearDeath", nil, false)
  end
end
function CharacterAnimInstance:HandleOnCharacterUseLadder(sEvent)
  local uOwnerCharacter = self.C_OwnerCharacter
  if uOwnerCharacter == nil then
    return
  end
  print(bWriteLog and "CharacterAnimInstance HandleOnCharacterUseLadder  %u", uOwnerCharacter.PlayerKey)
  if uOwnerCharacter:GetIsFPP() ~= self.bIsFPPAnimInstace then
    return
  end
  local uAnimParamsComp = uOwnerCharacter:GetAnimParamsComponent()
  if not uAnimParamsComp then
    return
  end
  if sEvent == "Enter" then
    local uLadderAnimClass = self.LadderAnimDefaultABP
    if uLadderAnimClass then
      print(bWriteLog and "CharacterAnimInstance HandleOnCharacterUseLadder ActiveAnimContainerWithInstance %u", uOwnerCharacter.PlayerKey)
      uAnimParamsComp:ActiveAnimContainerWithInstance("AC.Ladder", uLadderAnimClass, false)
    end
  else
    uAnimParamsComp:DeactiveAnimContainerWithInstance("AC.Ladder", nil, false)
  end
end
function CharacterAnimInstance:HandleOnSetAnimBpFinished()
  local uOwnerCharacter = self.C_OwnerCharacter
  if uOwnerCharacter == nil then
    return
  end
  print(bWriteLog and "CharacterAnimInstance HandleOnSetAnimBpFinished  %u", uOwnerCharacter.PlayerKey)
  self:InitCheckAddInstance()
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
local CCharacterAnimInstance = class(CDelegateContainer, nil, CharacterAnimInstance)
return CCharacterAnimInstance