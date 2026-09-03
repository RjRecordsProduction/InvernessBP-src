local SkillModButtonSlot = {}
function SkillModButtonSlot:ctor(selfType)
end
function SkillModButtonSlot:OnInitialize()
  SkillModButtonSlot.__super.OnInitialize(self)
  print(bWriteLog and "SkillModButtonSlot:OnInitialize()")
end
function SkillModButtonSlot:RegistEvents()
  SkillModButtonSlot.__super.RegistEvents(self)
  print(bWriteLog and "SkillModButtonSlot:RegistEvents()")
end
local class = require("class")
local SkillButtonSlotBase = require("GameLua.Mod.BaseMod.Client.SkillPanel.SkillButtonSlotBase")
return class(SkillButtonSlotBase, nil, SkillModButtonSlot)