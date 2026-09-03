local VehicleActionBuilder = {}
function VehicleActionBuilder:Init(bClient)
  VehicleActionBuilder.__super.Init(self, bClient)
end
function VehicleActionBuilder:Clear()
end
function VehicleActionBuilder:BuildActionTemplate(eventID, targetCharacter, actionDataTable)
  if eventID == EVENTID_PLAYEREVENT_PICKUPITEM then
  end
end
function VehicleActionBuilder:IsActionDataEqual(actionDataTable1, actionDataTable2)
  return false
end
local class = require("class")
local CBuilderBase = require("GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEventAction.ActionTemplateBuilder.ActionBuilderBase")
local CVehicleActionBuilder = class(CBuilderBase, nil, VehicleActionBuilder)
return CVehicleActionBuilder