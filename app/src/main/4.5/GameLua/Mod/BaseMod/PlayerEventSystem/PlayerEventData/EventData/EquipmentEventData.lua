local EquipmentEventData = {}
function EquipmentEventData:Init(bClient)
  EquipmentEventData.__super.Init(self, bClient)
end
function EquipmentEventData:Clear()
  EquipmentEventData.__super.Clear(self)
end
local class = require("class")
local CEventDataBase = require("GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEventData.EventData.EventDataBase")
local CEquipmentEventData = class(CEventDataBase, nil, EquipmentEventData)
return CEquipmentEventData