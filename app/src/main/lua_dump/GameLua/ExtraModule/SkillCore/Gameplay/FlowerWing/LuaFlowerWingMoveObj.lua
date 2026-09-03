local LuaFlowerWingMoveObj = {}
local EPawnState = import("EPawnState")
local EMovementMode = import("EMovementMode")
local EFlowerWingMoveState = import("EFlowerWingMoveState")
local UGameplayStatics = import("GameplayStatics")
local FlowerWingConfig = require("GameLua.ExtraModule.SkillCore.Gameplay.FlowerWing.FlowerWingConfig")
function LuaFlowerWingMoveObj:ctor()
  print(bWriteLog and "LuaFlowerWingMoveObj:ctor")
end
function LuaFlowerWingMoveObj:OnEnterCustomMove(CustomMode)
  if not slua.isValid(self.CharacterOwner) then
    return
  end
  if not slua.isValid(self.CharacterOwner.STCharacterMovement) then
    return
  end
  print(bWriteLog and "LuaFlowerWingMoveObj:OnEnterCustomMove")
  self.CharacterOwner.STCharacterMovement.bIgnoreClientMovementModeErrorChecks = false
  self:SetMoveState(EFlowerWingMoveState.Float)
  if not Client then
    self:ConsumeEnergy(true)
  end
end
function LuaFlowerWingMoveObj:OnLeaveCustomMove(CustomMode)
  if not slua.isValid(self.CharacterOwner) then
    return
  end
  if not slua.isValid(self.CharacterOwner.STCharacterMovement) then
    return
  end
  print(bWriteLog and "LuaFlowerWingMoveObj:OnLeaveCustomMove")
  self.CharacterOwner.STCharacterMovement.Velocity = FVector(0, 0, 0)
  self.CharacterOwner.STCharacterMovement.bIgnoreClientMovementModeErrorChecks = false
  if not Client then
    self:ConsumeEnergy(false)
  end
end
function LuaFlowerWingMoveObj:ConsumeEnergy(bEnable, nEnergy)
  if Client then
    return
  end
  print(bWriteLog and "LuaFlowerWingMoveObj:ConsumeEnergy:" .. tostring(bEnable))
  if not slua.isValid(self.CharacterOwner) then
    print(bWriteLog and "LuaFlowerWingMoveObj:ConsumeEnergy CharacterOwner is nil")
    return
  end
  local uSkillManager = self.CharacterOwner.SkillManager
  if not slua.isValid(uSkillManager) then
    print(bWriteLog and "LuaFlowerWingMoveObj:ConsumeEnergy uSkillManager is nil")
    return
  end
  local SkillID = FlowerWingConfig.SkillID
  local uSkill = uSkillManager:GetSkill(SkillID)
  if not slua.isValid(uSkill) then
    print(bWriteLog and "LuaFlowerWingMoveObj:ConsumeEnergy uSkill is nil")
    return
  end
  local SkillCDs = uSkillManager:GetSkillBaseData(SkillID).SkillCDs
  local uEnergyCDObject
  if SkillCDs:Num() > 2 then
    uEnergyCDObject = SkillCDs:Get(2)
  end
  if not slua.isValid(uEnergyCDObject) then
    print(bWriteLog and "LuaFlowerWingMoveObj:ConsumeEnergy uEnergyCDObject is nil")
    return false
  end
  if nEnergy then
    local ECDOperationType = import("ECDOperationType")
    local CDOperationData = {
      nEnergy = nEnergy,
      EnergyOp = ECDOperationType.CD_Add
    }
    uSkillManager:SetNewCD(FlowerWingConfig.SkillID, 2, CDOperationData)
  end
  if bEnable then
    uSkill:DoSkillCoolDown(uSkillManager, 2)
  else
    uSkill:StopSkillCoolDown(uSkillManager, 2)
  end
end
function LuaFlowerWingMoveObj:HasEnergy(nEnergy)
  if not slua.isValid(self.CharacterOwner) then
    print(bWriteLog and "LuaFlowerWingMoveObj:HasEnergy CharacterOwner is nil")
    return false
  end
  local uSkillManager = self.CharacterOwner.SkillManager
  if not slua.isValid(uSkillManager) then
    print(bWriteLog and "LuaFlowerWingMoveObj:HasEnergy uSkillManager is nil")
    return false
  end
  local SkillID = FlowerWingConfig.SkillID
  local SkillCDs = uSkillManager:GetSkillBaseData(SkillID).SkillCDs
  local uEnergyCDObject
  if SkillCDs:Num() > 2 then
    uEnergyCDObject = SkillCDs:Get(2)
  end
  if not slua.isValid(uEnergyCDObject) then
    print(bWriteLog and "LuaFlowerWingMoveObj:HasEnergy uEnergyCDObject is nil")
    return false
  end
  return nEnergy <= uEnergyCDObject:GetCurrentEnergy()
end
local class = require("class")
local object = require("common.delegate_container")
local CLuaFlowerWingMoveObj = class(object, nil, LuaFlowerWingMoveObj)
return CLuaFlowerWingMoveObj