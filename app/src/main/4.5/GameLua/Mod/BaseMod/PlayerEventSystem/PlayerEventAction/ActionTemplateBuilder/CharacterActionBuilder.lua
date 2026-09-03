local CharacterActionBuilder = {}
function CharacterActionBuilder:Init(bClient)
  CharacterActionBuilder.__super.Init(self, bClient)
end
function CharacterActionBuilder:Clear()
end
function CharacterActionBuilder:BuildActionTemplate(eventID, targetCharacter, actionDataTable)
  if eventID == EVENTID_PLAYEREVENT_TALENT_INIT then
    return self:CreatePlayerActionArray(actionDataTable.tActionData, actionDataTable.tParam, targetCharacter)
  end
  return self:CreatePlayerActionArray(actionDataTable, {}, targetCharacter)
end
function CharacterActionBuilder:IsActionDataEqual(actionDataTable1, actionDataTable2)
  if not actionDataTable1 and not actionDataTable2 then
    return true
  end
  if not (actionDataTable1 and actionDataTable2) or actionDataTable1.ID == nil then
    return false
  end
  if actionDataTable1.ID == actionDataTable2.ID then
    return true
  end
  return false
end
local class = require("class")
local CBuilderBase = require("GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEventAction.ActionTemplateBuilder.ActionBuilderBase")
local CCharacterActionBuilder = class(CBuilderBase, nil, CharacterActionBuilder)
return CCharacterActionBuilder