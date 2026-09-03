local LuaBTDecorator_PetNeedMove = {}
local EPawnState = import("EPawnState")
function LuaBTDecorator_PetNeedMove:ctor()
  self.TaskNodeName = "LuaBTDecorator_PetNeedMove"
end
function LuaBTDecorator_PetNeedMove:PerformConditionCheck(AIController)
  local pet = AIController.Pawn
  if not slua.isValid(pet) then
    return false
  end
  local player = pet:GetPetOwnerCharacter()
  if not slua.isValid(player) then
    return false
  end
  if player:HasState(EPawnState.GunADS) or player:HasState(EPawnState.GunFire) or player:HasState(EPawnState.HoldShield) then
    return true
  end
  return false
end
local class = require("class")
local CLuaNodeBase = require("GameLua.Mod.Library.GamePlay.AI.LuaNode.Decorator.LuaBTDecoratorBase")
local CLuaBTDecorator_PetNeedMove = class(CLuaNodeBase, nil, LuaBTDecorator_PetNeedMove)
return CLuaBTDecorator_PetNeedMove