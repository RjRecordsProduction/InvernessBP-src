local VehicleEventData = {}
function VehicleEventData:Init(bClient)
  VehicleEventData.__super.Init(self, bClient)
end
function VehicleEventData:Clear()
  VehicleEventData.__super.Clear(self)
end
local class = require("class")
local CEventDataBase = require("GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEventData.EventData.EventDataBase")
local CVehicleEventData = class(CEventDataBase, nil, VehicleEventData)
return CVehicleEventData