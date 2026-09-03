local SkillBuffEventData = {}
function SkillBuffEventData:Init(bClient)
  SkillBuffEventData.__super.Init(self, bClient)
end
function SkillBuffEventData:Clear()
  SkillBuffEventData.__super.Clear(self)
end
local class = require("class")
local CEventDataBase = require("GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEventData.EventData.EventDataBase")
local CSkillBuffEventData = class(CEventDataBase, nil, SkillBuffEventData)
return CSkillBuffEventData