local LuaVehicleOperator = {}
function LuaVehicleOperator:ReceiveBeginPlay()
  self.Super:ReceiveBeginPlay()
  LuaVehicleOperator.__super.ReceiveBeginPlay(self)
end
function LuaVehicleOperator:GetVehicleOperationMode()
  local VehicleOperationMode = self.VehicleOperationMode
  return VehicleOperationMode or -1
end
function LuaVehicleOperator:GetShowStateUI()
  local ShowStateUI = self.ShowStateUI
  return ShowStateUI ~= false
end
local class = require("class")
local CActorBase = require("GameLua.Mod.BaseMod.Common.Core.ActorBase")
local CLuaVehicleOperator = class(CActorBase, nil, LuaVehicleOperator)
return CLuaVehicleOperator