local SkillHangGliderButtonSlot = {}
function SkillHangGliderButtonSlot:ctor(selfType)
end
function SkillHangGliderButtonSlot:OnInitialize()
  SkillHangGliderButtonSlot.__super.OnInitialize(self)
  print(bWriteLog and "SkillHangGliderButtonSlot:OnInitialize()")
end
function SkillHangGliderButtonSlot:RegistEvents()
  SkillHangGliderButtonSlot.__super.RegistEvents(self)
  print(bWriteLog and "SkillHangGliderButtonSlot:RegistEvents()")
end
local class = require("class")
local SkillButtonSlotBase = require("GameLua.Mod.BaseMod.Client.SkillPanel.SkillButtonSlotBase")
return class(SkillButtonSlotBase, nil, SkillHangGliderButtonSlot)