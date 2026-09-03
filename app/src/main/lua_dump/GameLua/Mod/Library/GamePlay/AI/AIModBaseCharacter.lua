local AIModBaseCharacter = {
  MulticastRPC = {}
}
function AIModBaseCharacter:ctor()
end
function AIModBaseCharacter:ReceiveBeginPlay()
  AIModBaseCharacter.__super.ReceiveBeginPlay(self)
  local uSTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local AIBasePawnNetCullDistanceSqrOverride = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableFloatValue("r.char.AIBasePawnNetCullDistanceSqrOverride")
  if 10 < AIBasePawnNetCullDistanceSqrOverride then
    self:SetNetCullDistanceSquared(AIBasePawnNetCullDistanceSqrOverride)
    print(bWriteLog and "AIModBaseCharacter SetNetCullDistanceSquared:", AIBasePawnNetCullDistanceSqrOverride)
  end
end
function AIModBaseCharacter:_PostConstruct()
  AIModBaseCharacter.__super._PostConstruct(self)
end
function AIModBaseCharacter:GetSourceSpawner()
  if self.uSourceSpawner ~= nil and slua.isValid(self.uSourceSpawner) then
    return self.uSourceSpawner
  end
  local uAIC = self:GetController()
  if not slua.isValid(uAIC) or nil == uAIC.OwnedSpawnerID then
    return nil
  end
  local USubsystemBlueprintLibrary = import("SubsystemBlueprintLibrary")
  local UAESpawnSubsystem = import("AESpawnSubsystem")
  local uSubSystem = USubsystemBlueprintLibrary.GetWorldSubsystem(CGameWorld, UAESpawnSubsystem)
  if not uSubSystem then
    return nil
  end
  self.uSourceSpawner = uSubSystem:FindSpawner(uAIC.OwnedSpawnerID)
  return self.uSourceSpawner
end
local class = require("class")
local CLuaBaseCharacter = require("GameLua.Mod.BRMod.Gameplay.Core.BRPlayerCharacterBase")
local CAIModBaseCharacter = class(CLuaBaseCharacter, nil, AIModBaseCharacter)
return require("combine_class").DeclareFeature(CAIModBaseCharacter, {
  {
    ChangeAttributeFeature = "GameLua.GameCore.Module.AI.Feature.ChangeAttributeFeature"
  },
  {
    ChangeWeaponAttributeFeature = "GameLua.GameCore.Module.AI.Feature.ChangeWeaponAttributeFeature"
  },
  {
    UGCLevelFeature = "GameLua.GameCore.Module.AI.Feature.UGCLevelFeature"
  },
  {
    UGCCharacterAnimFeature = "GameLua.GameCore.Module.AI.Feature.UGCCharacterAnimFeature"
  },
  {
    UGCAISkillFeature = "GameLua.GameCore.Module.AI.Feature.UGCAISkillFeature"
  }
}, "AIModBaseCharacter")