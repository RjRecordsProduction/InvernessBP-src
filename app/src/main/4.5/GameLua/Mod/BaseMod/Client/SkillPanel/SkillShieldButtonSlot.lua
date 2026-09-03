local SkillShieldButtonSlot = {}
function SkillShieldButtonSlot:ctor(selfType)
end
function SkillShieldButtonSlot:OnInitialize()
  SkillShieldButtonSlot.__super.OnInitialize(self)
  print(bWriteLog and "SkillShieldButtonSlot:OnInitialize()")
end
function SkillShieldButtonSlot:RegistEvents()
  SkillShieldButtonSlot.__super.RegistEvents(self)
  print(bWriteLog and "SkillShieldButtonSlot:RegistEvents()")
end
local class = require("class")
local SkillButtonSlotBase = require("GameLua.Mod.BaseMod.Client.SkillPanel.SkillButtonSlotBase")
return class(SkillButtonSlotBase, nil, SkillShieldButtonSlot)