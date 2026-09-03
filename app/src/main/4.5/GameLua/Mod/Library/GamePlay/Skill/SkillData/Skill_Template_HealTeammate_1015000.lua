local SkillInstData = {
  Inst = {
    SkillData = {bAutoShowRegisteredSkillUI = true}
  }
}
local tMedicalItemIDToSkillID = {
  [601004] = 10010030,
  [601005] = 10010050,
  [601006] = 10010070
}
function SkillInstData:GetPromtConfig(SkillID)
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(uPlayerCharacter) then
    return nil
  end
  local uSkillManager = uPlayerCharacter:GetSkillManager()
  if not slua.isValid(uSkillManager) then
    return 0
  end
  local nMedicalItemID = uSkillManager:GetValueAsUInt(SkillID, "ItemID")
  if nMedicalItemID == 0 then
    return nil
  end
  local RelateSkillID = tMedicalItemIDToSkillID[nMedicalItemID]
  if RelateSkillID == 0 then
    return nil
  end
  local PromptConfig = CDataTable.GetTableData("PromptConfigTable", RelateSkillID)
  return PromptConfig
end
local class = require("class")
local CSkillActorBase = require("GameLua.GameCore.Module.Skill.SkillLua.SkillActorBase")
local CSkillActorInst = class(CSkillActorBase, nil, SkillInstData)
return CSkillActorInst