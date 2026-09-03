local LuaBTTask_PetTeleport = {}
function LuaBTTask_PetTeleport:ctor()
  self.TaskNodeName = "LuaBTTask_PetTeleport"
end
function LuaBTTask_PetTeleport:ReceiveExecute(AIController)
  local pet = AIController.Pawn
  if not pet then
    self:FinishExecute(true)
    return
  end
  local owner = pet:GetPetOwnerCharacter()
  if not owner then
    self:FinishExecute(true)
    return
  end
  pet:DSTeleportImp(false)
  self:FinishExecute(true)
end
local class = require("class")
local CLuaNodeBase = require("GameLua.Mod.Library.GamePlay.AI.LuaNode.TaskNode.LuaBTTaskBase")
local CLuaBTTaskBase = class(CLuaNodeBase, nil, LuaBTTask_PetTeleport)
return CLuaBTTaskBase