local VehicleCommonComponent = {
  LuaEventContainer = {
    "OnBoneHpZero"
  }
}
function VehicleCommonComponent:ctor()
  self.OnBoneHpZeroDelegate = "OnBoneHpZero"
end
function VehicleCommonComponent:ReceiveBeginPlay()
  self:InitCommonFromConfig()
  self.bUseDriverDamageScale = false
end
function VehicleCommonComponent:InitCommonFromConfig()
  local MyOwner = self:GetOwner()
  if not slua.isValid(MyOwner) then
    return
  end
  local TargetConfig = self:GetCommonConfig()
  if TargetConfig then
    for Key, Value in pairs(TargetConfig) do
      self[Key] = Value
    end
  end
end
function VehicleCommonComponent:GetCommonConfig()
  local MyOwner = self:GetOwner()
  if not slua.isValid(MyOwner) then
    return nil
  end
  local TargetConfig
  local ModPath = Game.GetCurrentModPath()
  local ModCommonConfigPath = ModPath .. ".Gameplay.Module.Vehicle.Config.VehicleCommonConfig"
  if slua.IsLuaModuleExists(ModCommonConfigPath) then
    local ModCommonConfig = require(ModCommonConfigPath)
    if ModCommonConfig and ModCommonConfig[MyOwner.VehicleShapeType] then
      TargetConfig = ModCommonConfig[MyOwner.VehicleShapeType]
      TargetConfig = TargetConfig or ModCommonConfig.Default
    end
  end
  if not TargetConfig then
    local BaseCommonConfigPath = "GameLua.GameCore.Module.Vehicle.Config.VehicleCommonConfig"
    if slua.IsLuaModuleExists(BaseCommonConfigPath) then
      local BaseCommonConfig = require(BaseCommonConfigPath)
      TargetConfig = BaseCommonConfig[MyOwner.VehicleShapeType]
      TargetConfig = TargetConfig or BaseCommonConfig.Default
    end
  end
  return TargetConfig
end
function VehicleCommonComponent:CalcDamage(Damage, Instigator, DamageCauser)
  local MyOwner = self:GetOwner()
  if self.bUseDriverDamageScale then
    Damage = Damage * self:GetDriverDamageScale()
  end
  if slua.isValid(DamageCauser) and DamageCauser.CalVehicleDamage then
    return DamageCauser:CalVehicleDamage(Damage, Instigator, MyOwner)
  end
  if not slua.isValid(Instigator) or not slua.isValid(MyOwner) then
    return Damage
  end
  local MyController = MyOwner:GetController()
  if Instigator == MyController then
    return Damage
  end
  if Game:IsAIController(Instigator) then
    local uMobPawn = Instigator:K2_GetPawn()
    if slua.isValid(uMobPawn) and Game:IsMonster(uMobPawn) then
      return Damage
    end
  end
  if not Instigator.GetPlayerCharacterSafety then
    return Damage
  end
  local Killer = Instigator:GetPlayerCharacterSafety()
  if not slua.isValid(Killer) then
    return Damage
  end
  return Damage * self:GetDamageScale(Killer)
end
function VehicleCommonComponent:GetDamageScale(uShooter)
  local HasTeammate, HasOther = self:CheckVehicleSeatOccupiers(uShooter)
  local EVehicleDamageScaleReason = import("EVehicleDamageScaleReason")
  local Scale = 1
  if HasTeammate and HasOther then
    Scale = self.DamageScaleMap:Get(EVehicleDamageScaleReason.HasTeammateAndOthers) or Scale
  elseif HasTeammate then
    Scale = self.DamageScaleMap:Get(EVehicleDamageScaleReason.OnlyHasTeammate) or Scale
  else
    Scale = HasOther and self.DamageScaleMap:Get(EVehicleDamageScaleReason.OnlyHasOther) or Scale
  end
  return Scale
end
function VehicleCommonComponent:GetDriverDamageScale()
  local MyOwner = self:GetOwner()
  if not slua.isValid(MyOwner) then
    return 1
  end
  local uDriver = MyOwner:GetDriver()
  if slua.isValid(uDriver) then
    local VehicleDamageReduction = uDriver:GetAttributeValue("VehicleDamageReduction")
    if 0 < VehicleDamageReduction then
      local VehicleDamageReductionScale = math.min(math.max(1 - VehicleDamageReduction, 0), 1)
      print(bWriteLog and string.format("VehicleDamageReduction:GetDriverDamageScale-Scale: %f", VehicleDamageReductionScale))
      return VehicleDamageReductionScale
    end
  end
  return 1
end
function VehicleCommonComponent:SetVehicleWheelInvincible(bIsInvincible)
  if not self:CheckCanModVehicleWheel() then
    return
  end
  if not self.WheelsHP then
    return false
  end
  print(bWriteLog and string.format("VehicleCommonComponent:SetVehicleWheelInvincible Mod %s", tostring(bIsInvincible)))
  for i = 0, self.WheelsHP:Num() - 1 do
    local wheelHP = self.WheelsHP:Get(i)
    if slua.isValid(wheelHP) then
      wheelHP.DontDamageWheels = bIsInvincible
      self.WheelsHP:Set(i, wheelHP)
    end
  end
end
function VehicleCommonComponent:CheckCanModVehicleWheel()
  if not self.WheelsHP then
    return false
  end
  if self.bCanModifyVehicleWheel ~= nil then
    return self.bCanModifyVehicleWheel
  end
  print(bWriteLog and string.format("VehicleCommonComponent:SetVehicleWheelInvincible Mod %s", tostring(bIsInvincible)))
  for i = 0, self.WheelsHP:Num() - 1 do
    local wheelHP = self.WheelsHP:Get(i)
    if slua.isValid(wheelHP) then
      if wheelHP.DontDamageWheels then
        self.bCanModifyVehicleWheel = false
        return self.bCanModifyVehicleWheel
      else
        self.bCanModifyVehicleWheel = true
      end
    end
  end
  return self.bCanModifyVehicleWheel
end
function VehicleCommonComponent:CheckVehicleSeatOccupiers(Killer)
  local HasTeammate = false
  local HasOther = false
  local MyOwner = self:GetOwner()
  if not slua.isValid(MyOwner) then
    return HasTeammate, HasOther
  end
  if not slua.isValid(Killer) then
    return HasTeammate, HasOther
  end
  local VehicleSeat = MyOwner:GetVehicleSeats()
  if not slua.isValid(VehicleSeat) then
    return HasTeammate, HasOther
  end
  for _, Character in pairs(VehicleSeat.SeatOccupiers) do
    if slua.isValid(Character) then
      if Killer:IsSameTeam(Character) and Killer ~= Character then
        HasTeammate = true
      else
        HasOther = true
      end
    end
  end
  return HasTeammate, HasOther
end
function VehicleCommonComponent:OnBoneHpZeroExt(InBoneName)
  self:LuaBroadcast(self.OnBoneHpZeroDelegate, InBoneName)
end
local class = require("class")
local CDelegateContainer = require("GameLua.Mod.BaseMod.Common.Core.ActorComponentBase")
return class(CDelegateContainer, nil, VehicleCommonComponent)