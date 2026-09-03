local SkillBuffActionBuilder = {}
function SkillBuffActionBuilder:Init(bClient)
  SkillBuffActionBuilder.__super.Init(self, bClient)
end
function SkillBuffActionBuilder:Clear()
end
function SkillBuffActionBuilder:BuildActionTemplate(eventID, targetCharacter, actionDataTable)
  if eventID == EVENTID_PLAYEREVENT_PICKUPITEM then
  end
end
function SkillBuffActionBuilder:IsActionDataEqual(actionDataTable1, actionDataTable2)
  return false
end
local class = require("class")
local CBuilderBase = require("GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEventAction.ActionTemplateBuilder.ActionBuilderBase")
local CSkillBuffActionBuilder = class(CBuilderBase, nil, SkillBuffActionBuilder)
return CSkillBuffActionBuilder