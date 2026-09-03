local LuaBTTask_FlyPetTeleport = {}
local PetUtil = require("GameLua.Mod.BaseMod.Actor.Pet.PetUtil")
local FlyTelePos = PetUtil.FlyTelePos
local FlyTeleRandom = PetUtil.FlyTeleRandom
local 
function LuaBTTask_FlyPetTeleport:ctor()
  self.TaskNodeName = "LuaBTTask_FlyPetTeleport"
end
function LuaBTTask_FlyPetTeleport:ReceiveExecute(AIController)
  local pet = AIController.Pawn
  if not pet then
    return false
  end
  local player = pet:GetPetOwnerCharacter()
  if not player then
    return false
  end
  local uPlayerLocation = player:K2_GetActorLocation()
  local x = math.random(1, FlyTeleRandom)
  local y = math.random(1, FlyTeleRandom)
  local TargetLocation = FVector(x + uPlayerLocation.X, y + uPlayerLocation.Y, FlyTelePos + uPlayerLocation.Z)
  pet:K2_SetActorLocation(TargetLocation, false, nil, true)
  local component = pet:GetSyncSmoothComponent()
  if component then
    component:TeleportNextSync()
    component:ForceNetUpdate()
  end
  self:FinishExecute(true)
end
local class = require("class")
local CLuaNodeBase = require("GameLua.Mod.Library.GamePlay.AI.LuaNode.TaskNode.LuaBTTaskBase")
local CLuaBTTaskBase = class(CLuaNodeBase, nil, LuaBTTask_FlyPetTeleport)
return CLuaBTTaskBase