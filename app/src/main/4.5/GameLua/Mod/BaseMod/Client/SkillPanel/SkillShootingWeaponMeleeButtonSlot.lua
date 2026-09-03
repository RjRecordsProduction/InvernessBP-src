local SkillShootingWeaponMeleeButtonSlot = {}
function SkillShootingWeaponMeleeButtonSlot:ctor(selfType)
end
function SkillShootingWeaponMeleeButtonSlot:OnInitialize()
  SkillShootingWeaponMeleeButtonSlot.__super.OnInitialize(self)
  print(bWriteLog and "SkillShootingWeaponMeleeButtonSlot:OnInitialize()")
end
function SkillShootingWeaponMeleeButtonSlot:RegistEvents()
  SkillShootingWeaponMeleeButtonSlot.__super.RegistEvents(self)
  print(bWriteLog and "SkillShootingWeaponMeleeButtonSlot:RegistEvents()")
end
local class = require("class")
local SkillButtonSlotBase = require("GameLua.Mod.BaseMod.Client.SkillPanel.SkillButtonSlotBase")
return class(SkillButtonSlotBase, nil, SkillShootingWeaponMeleeButtonSlot)