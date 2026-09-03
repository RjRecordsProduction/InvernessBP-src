local CharacterUtils = require("GameLua.Mod.Lobby.Base.NewCharacter.logic.Utils.ConstUtils")
local StringUtil = require("common.string_util")
function CharacterUtils:GetCharacterNextSkillCfgByID(CharacterID, skill_id)
  local CharacterSkillCfg = CDataTable.GetTableByFilter("character_skill", "character_id", CharacterID)
  if not CharacterSkillCfg then
    return nil
  end
  local curSkillCfg = CDataTable.GetTableData("character_skill", skill_id)
  if not curSkillCfg then
    return nil
  end
  for _, v in pairs(CharacterSkillCfg) do
    if curSkillCfg.skill_type == v.skill_type and curSkillCfg.level + 1 == v.level then
      return v
    end
  end
  return nil
end
function CharacterUtils:GetLevelConfigByUnlockSkill(CharacterID, skill_id)
  local CharLevelCfg = CDataTable.GetSplitTableByFilter("Lobby", "NewCharacter", "character_level", "character_id", CharacterID)
  if not CharLevelCfg then
    return nil
  end
  for _, v in pairs(CharLevelCfg) do
    if v.unlock_skill and v.unlock_skill ~= "" then
      local TempList = StringUtil.Split(v.unlock_skill, "|")
      if TempList then
        for _, u in pairs(TempList) do
          if skill_id == tonumber(u) then
            return v
          end
        end
      end
    end
  end
  return nil
end
function CharacterUtils:HasCharacterSkillConfigured(CharacterID)
  local CharLevelCfg = CDataTable.GetSplitTableByFilter("Lobby", "NewCharacter", "character_level", "character_id", CharacterID)
  if not CharLevelCfg then
    return nil
  end
  for _, v in pairs(CharLevelCfg) do
    if v.unlock_skill and v.unlock_skill ~= "" then
      return true
    end
  end
  return false
end
function CharacterUtils:GetSkillCfgByIndex(CharacterID, Index)
  local CharLevelCfg = CDataTable.GetSplitTableByFilter("Lobby", "NewCharacter", "character_level", "character_id", CharacterID)
  if not CharLevelCfg then
    return nil
  end
  local SkillType = {}
  local Total = 0
  for _, v in pairs(CharLevelCfg) do
    if v.unlock_skill and v.unlock_skill ~= "" then
      local TempList = StringUtil.Split(v.unlock_skill, "|")
      if TempList then
        for _, u in pairs(TempList) do
          local skillCfg = CDataTable.GetTableData("character_skill", tonumber(u))
          if skillCfg then
            if not SkillType[skillCfg.skill_type] then
              Total = Total + 1
            end
            SkillType[skillCfg.skill_type] = tonumber(u)
            if Total == Index then
              return skillCfg
            end
          end
        end
      end
    end
  end
  return nil
end
function CharacterUtils:GetOldSkillCfgByIndex(CharacterID, Index)
  local CharLevelCfg = CDataTable.GetSplitTableByFilter("Lobby", "NewCharacter", "character_level", "character_id", CharacterID)
  if not CharLevelCfg then
    return nil
  end
  local SkillType = {}
  local Total = 0
  for _, v in pairs(CharLevelCfg) do
    if v.unlock_old_skills and v.unlock_old_skills ~= "" then
      local TempList = StringUtil.Split(v.unlock_old_skills, "|")
      if TempList then
        for _, u in pairs(TempList) do
          local skillCfg = CDataTable.GetTableData("character_skill", tonumber(u))
          if skillCfg then
            if not SkillType[skillCfg.skill_type] then
              Total = Total + 1
            end
            SkillType[skillCfg.skill_type] = tonumber(u)
            if Total == Index then
              return skillCfg
            end
          end
        end
      end
    end
  end
  return nil
end
function CharacterUtils:GetSkillIDByIndex(CharacterID, Index, bNeedUnlock)
  local NewCharacterNetSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.NewCharacterNetSystem)
  local CharacterData = NewCharacterNetSystem:GetCharacterDataByID(CharacterID)
  if CharacterData and CharacterData.skills then
    local temIdx = 0
    for _, v in pairs(CharacterData.skills) do
      temIdx = temIdx + 1
      if temIdx == Index then
        return v
      end
    end
  end
  if not bNeedUnlock then
    local skillCfg = self:GetSkillCfgByIndex(CharacterID, Index)
    return skillCfg and skillCfg.id or 0
  end
  return 0
end