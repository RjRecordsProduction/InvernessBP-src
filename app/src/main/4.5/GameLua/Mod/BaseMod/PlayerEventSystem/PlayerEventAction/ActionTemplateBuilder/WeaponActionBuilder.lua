local WeaponActionBuilder = {}
function WeaponActionBuilder:Init(bClient)
  WeaponActionBuilder.__super.Init(self, bClient)
end
function WeaponActionBuilder:Clear()
end
function WeaponActionBuilder:BuildActionTemplate(eventID, targetCharacter, actionDataTable)
  if eventID == EVENTID_PLAYEREVENT_WEAPON_CUSTOMUI then
    local TempList = {}
    table.insert(TempList, self:GetCustomUIAction(actionDataTable, targetCharacter))
    return TempList
  end
end
function WeaponActionBuilder:IsActionDataEqual(actionDataTable1, actionDataTable2)
  if actionDataTable1.CustomUIName and actionDataTable1.CustomUIName == actionDataTable2.CustomUIName then
    return true
  end
  return false
end
function WeaponActionBuilder:GetCustomUIAction(actionDataTable, targetCharacter)
  local CustomUIAction = require("GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEventAction.Action.AddCustomUIAction")
  local NewCustomUIAction = CustomUIAction()
  NewCustomUIAction:Init(self.bIsClient, actionDataTable)
  return NewCustomUIAction
end
local class = require("class")
local CBuilderBase = require("GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEventAction.ActionTemplateBuilder.ActionBuilderBase")
local CWeaponActionBuilder = class(CBuilderBase, nil, WeaponActionBuilder)
return CWeaponActionBuilder