local EquipmentActionBuilder = {}
function EquipmentActionBuilder:Init(bClient)
  EquipmentActionBuilder.__super.Init(self, bClient)
end
function EquipmentActionBuilder:Clear()
end
function EquipmentActionBuilder:BuildActionTemplate(eventID, targetCharacter, actionDataTable)
  return self:CreatePlayerActionArray(actionDataTable.ActionData, actionDataTable.ActionParam, targetCharacter)
end
local class = require("class")
local CBuilderBase = require("GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEventAction.ActionTemplateBuilder.ActionBuilderBase")
local CEquipmentActionBuilder = class(CBuilderBase, nil, EquipmentActionBuilder)
return CEquipmentActionBuilder