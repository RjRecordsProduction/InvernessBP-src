local LuaBTDecorator_FlyPetNeedTeleport = {}
function LuaBTDecorator_FlyPetNeedTeleport:ctor()
  self.TaskNodeName = "LuaBTDecorator_FlyPetNeedTeleport"
end
local PetUtil = require("GameLua.Mod.BaseMod.Actor.Pet.PetUtil")
local TeleDis = PetUtil.FlyTeleDis
function LuaBTDecorator_FlyPetNeedTeleport:PerformConditionCheck(AIController)
  local pet = AIController.Pawn
  if not slua.isValid(pet) then
    return false
  end
  local player = pet:GetPetOwnerCharacter()
  if not slua.isValid(player) then
    return false
  end
  local EPawnState = import("EPawnState")
  if player:HasState(EPawnState.Swim) then
    return false
  end
  local disQ = pet:GetSquaredDistanceTo(player)
  if disQ > TeleDis * TeleDis then
    log(bWriteLog and "LuaBTDecorator_FlyPetNeedTeleport:PerformConditionCheck. disQ: " .. tostring(disQ))
    return true
  end
  return false
end
local class = require("class")
local CLuaNodeBase = require("GameLua.Mod.Library.GamePlay.AI.LuaNode.Decorator.LuaBTDecoratorBase")
local CLuaBTDecorator_PetNeedMove = class(CLuaNodeBase, nil, LuaBTDecorator_FlyPetNeedTeleport)
return CLuaBTDecorator_PetNeedMove