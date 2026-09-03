local SkillButtonSlotBase = {}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local SkillUtils = require("GameLua.GameCore.Module.Skill.SkillUtils")
function SkillButtonSlotBase:ctor(selfType)
  print(bWriteLog and "SkillButtonSlotBase:ctor")
end
function SkillButtonSlotBase:OnInitialize()
  SkillButtonSlotBase.__super.OnInitialize(self)
  print(bWriteLog and "SkillButtonSlotBase:OnInitialize")
end
function SkillButtonSlotBase:OnShow()
  print(bWriteLog and "SkillButtonSlotBase:OnShow")
  local uCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(uCharacter) and slua.isValid(uCharacter.SkillManager) then
    uCharacter.SkillManager:RefreshWaitLoadSkillUI()
  end
end
local class = require("class")
local UIBase = require("GameLua.Mod.BaseMod.Client.DynamicMountUIBase")
return class(UIBase, nil, SkillButtonSlotBase)