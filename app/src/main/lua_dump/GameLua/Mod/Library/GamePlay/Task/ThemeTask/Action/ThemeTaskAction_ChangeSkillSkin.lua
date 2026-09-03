local ThemeTaskAction_ChangeSkillSkin = {
  sActionName = "ThemeTaskAction_ChangeSkillSkin",
  RunEvn = "DS"
}
function ThemeTaskAction_ChangeSkillSkin:Select(RewardID, tConfig, Owner)
  local uPlayerCharacter = self:GetPlayerCharacter(Owner)
  if slua.isValid(uPlayerCharacter) and tConfig and type(tConfig) == "table" then
    for SkillID, SkinID in pairs(tConfig) do
      uPlayerCharacter:SetSkillSkinID(SkillID, SkinID)
    end
  end
end
function ThemeTaskAction_ChangeSkillSkin:UnSelect(RewardID, tConfig, Owner)
  local uPlayerCharacter = self:GetPlayerCharacter(Owner)
  if slua.isValid(uPlayerCharacter) and tConfig and type(tConfig) == "table" then
    for SkillID, SkinID in pairs(tConfig) do
      uPlayerCharacter:SetSkillSkinID(SkillID, 0)
    end
  end
end
local class = require("class")
local ThemeTaskActionBase = require("GameLua.Mod.Library.GamePlay.Task.ThemeTask.Action.ThemeTaskActionBase")
local CThemeTaskAction_ChangeSkillSkin = class(ThemeTaskActionBase, nil, ThemeTaskAction_ChangeSkillSkin)
return CThemeTaskAction_ChangeSkillSkin