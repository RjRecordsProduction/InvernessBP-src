local PickAxeDiggingRadius = 150.0
local NeonConfig = require("GameLua.Mod.Neon.Gameplay.Config.NeonConfig")
local PickAxeDiggingCameraDistance = 200.0
local ECollisionChannel = import("ECollisionChannel")
local SkillAction_Digging = {
  sObjectName = "SkillAction_Digging",
  ItemID = 0
}
function SkillAction_Digging:ctor(selfType)
end
function SkillAction_Digging:LuaRealDoAction()
  local OwnerPawn = self:GetOwnerPawn()
  if slua.isValid(OwnerPawn) then
    local Weapon = OwnerPawn:GetCurrentWeapon()
    if slua.isValid(Weapon) and Weapon.ServerRPC_RequestDigging then
      local PlayerController = OwnerPawn:GetPlayerControllerSafety()
      if not slua.isValid(PlayerController) then
        return false
      end
      local PlayerCameraManager = PlayerController.PlayerCameraManager
      if not slua.isValid(PlayerCameraManager) then
        return false
      end
      local Start = PlayerCameraManager:GetCameraLocation()
      local End = PlayerCameraManager:GetCameraLocation() + PlayerCameraManager:GetCameraRotation():Vector() * NeonConfig.PickAxeDiggingConfig.PickAxeDiggingDist
      local UKismetSystemLibrary = import("KismetSystemLibrary")
      local Actor_C = import("/Script/Engine.Actor")
      local ActorsToIgnore = slua.Array(UEnums.EPropertyClass.Object, Actor_C)
      ActorsToIgnore:Add(OwnerPawn)
      local bHit, OutHit = UKismetSystemLibrary.LineTraceSingleForObjects(OwnerPawn, Start, End, {
        Game:ConvertToObjectType(ECollisionChannel.ECC_WorldStatic),
        Game:ConvertToObjectType(ECollisionChannel.ECC_WorldDynamic)
      }, false, ActorsToIgnore, 0, nil, true, FLinearColor.Green, FLinearColor.Red, 5)
      if IsEditor then
        local USTExtraGameplayStatics = import("STExtraGameplayStatics")
        USTExtraGameplayStatics.ClientDrawDebugSphere(End, 5, 8, FLinearColor.Yellow, 25, 1)
      end
      if bHit and slua.isValid(OutHit.Actor) then
        local ALandscapeProxy = import("LandscapeProxy")
        Weapon:ServerRPC_RequestDigging(OutHit.Location, Game:IsClassOf(OutHit.Actor, ALandscapeProxy) or OutHit.Actor.ActorLabel == "Landscape")
      end
    end
  end
  return true
end
local class = require("GameLua.GameCore.Module.Skill.SkillLua.noctor_class")
local CSkillNodeBase = require("GameLua.GameCore.Module.Skill.SkillLua.SkillActionBase")
local CSkillAction_Digging = class(CSkillNodeBase, nil, SkillAction_Digging)
return CSkillAction_Digging