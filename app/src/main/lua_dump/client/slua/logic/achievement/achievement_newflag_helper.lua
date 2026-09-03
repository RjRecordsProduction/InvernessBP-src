local achievement_newflag_helper = {SaveInfo = nil}
function achievement_newflag_helper.Init()
  achievement_newflag_helper.InitData()
  local logic_achievement_float_tip = require("client.slua.logic.achievement.logic_achievement_float_tip")
  logic_achievement_float_tip.Init()
end
function achievement_newflag_helper.InitData()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local fileName = PlayerPrefsSystem.ePlayerPrefsType.eAchievementData
  achievement_newflag_helper.SaveInfo = PlayerPrefsSystem.LoadFileToTable_N(fileName) or {}
end
function achievement_newflag_helper.GetIsNewWithCfg(id, cfg)
  if cfg == nil then
    cfg = CDataTable.GetTableData("AchievementCfg", id)
  end
  if not cfg then
    log(bWriteLog and "achievement_newflag_helper.GetIsNewWithCfg not cfg")
    return false
  end
  local MultiLvGroupID = cfg.MultiLvGroupID
  if cfg.MultiLvGroupID == 0 then
    MultiLvGroupID = cfg.ID
  end
  if achievement_newflag_helper.IsHidenAch(cfg) then
    return false
  end
  local achievement_cfg_helper = require("client.slua.logic.achievement.achievement_cfg_helper")
  if achievement_cfg_helper.IsValidAchievementID(id, cfg) == false then
    return false
  end
  local version_util = require("client.common.version_util")
  if version_util.IsMatchVersion(cfg.Version) == false then
    return false
  end
  local AchieveHandler = require("client.network.Protocol.AchieveHandler")
  if AchieveHandler.IsExtinctByID(id) then
    return false
  end
  if achievement_newflag_helper.SaveInfo == nil then
    achievement_newflag_helper.InitData()
  end
  if achievement_newflag_helper.SaveInfo[MultiLvGroupID] ~= nil then
    return false
  end
  return true
end
function achievement_newflag_helper.IsHidenAch(cfg)
  return cfg.AchType == 2
end
function achievement_newflag_helper.SetIsNew(id, bNew, bSaveFile)
  local cfg = CDataTable.GetTableData("AchievementCfg", id)
  if cfg == nil then
    return
  end
  local MultiLvGroupID = cfg.MultiLvGroupID
  if cfg.MultiLvGroupID == 0 then
    MultiLvGroupID = cfg.ID
  end
  if achievement_newflag_helper.SaveInfo == nil then
    achievement_newflag_helper.SaveInfo = {}
  end
  achievement_newflag_helper.SaveInfo[MultiLvGroupID] = bNew
  if bSaveFile then
    achievement_newflag_helper.SaveFile()
  end
end
function achievement_newflag_helper.SaveFile()
  if achievement_newflag_helper.SaveInfo == nil then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local fileName = PlayerPrefsSystem.ePlayerPrefsType.eAchievementData
  PlayerPrefsSystem.SaveTableToFile_N(achievement_newflag_helper.SaveInfo, fileName)
end
return achievement_newflag_helper