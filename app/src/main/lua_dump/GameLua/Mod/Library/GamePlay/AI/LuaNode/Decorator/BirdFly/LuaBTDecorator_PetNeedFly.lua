local LuaBTDecorator_PetNeedFly = {}
function LuaBTDecorator_PetNeedFly:ctor()
  self.TaskNodeName = "LuaBTDecorator_PetNeedFly"
end
local PetUtil = require("GameLua.Mod.BaseMod.Actor.Pet.PetUtil")
local FlyDis = PetUtil.FlyDis
function LuaBTDecorator_PetNeedFly:PerformConditionCheck(AIController)
  local pet = AIController.Pawn
  if not slua.isValid(pet) then
    return false
  end
  local player = pet:GetPetOwnerCharacter()
  if not slua.isValid(player) then
    return false
  end
  local PetOwner = Game:GetAIBlackboardValue(pet, UEnums.EBlackBoardKeyType.Object, "PetOwner")
  if not slua.isValid(PetOwner) then
    log(bWriteLog and "LuaBTDecorator_PetNeedFly:PerformConditionCheck.  no PetOwner")
    log(bWriteLog and "LuaBTDecorator_PetNeedFly:PerformConditionCheck. player: " .. tostring(player))
    Game:SetAIBlackboardValue(pet, UEnums.EBlackBoardKeyType.Object, "PetOwner", player)
  end
  local petZ = pet:K2_GetActorLocation().Z
  local playerZ = player:K2_GetActorLocation().Z
  local disQ = pet:GetSquaredDistanceTo(player)
  if disQ > FlyDis * FlyDis then
    log(bWriteLog and "LuaBTDecorator_PetNeedFly:PerformConditionCheck. disQ: " .. tostring(disQ))
    return true
  end
  if petZ < playerZ then
    return true
  end
  return false
end
local class = require("class")
local CLuaNodeBase = require("GameLua.Mod.Library.GamePlay.AI.LuaNode.Decorator.LuaBTDecoratorBase")
local CLuaBTDecorator_PetNeedMove = class(CLuaNodeBase, nil, LuaBTDecorator_PetNeedFly)
return CLuaBTDecorator_PetNeedMove