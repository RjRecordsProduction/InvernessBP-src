local psSkill_sprint_config = require("client.slua.logic.psSkill_sprint.psSkill_sprint_config")
local psSkill_sprint_util = {}
function psSkill_sprint_util.InitConfig()
  local roleConfig = {}
  local TableUtil = require("common.table_util")
  local PSKillSprint_RoleConfig = CDataTable.GetTable("PSKillSprint_RoleConfig")
  for _, v in pairs(PSKillSprint_RoleConfig) do
    local data = TableUtil.FastCopyTable(psSkill_sprint_config.SRoleConfig)
    data.ID = v.ID
    data.Name = v.Name
    data.LabelColor = v.LabelColor
    data.Icon = v.Icon
    data.LobbyIcon = v.LobbyIcon
    data.GrayIcon = v.GrayIcon
    data.LeftColorBg = v.LeftColorBg
    data.RightColorBg = v.RightColorBg
    data.SelectSound = v.SelectSound
    data.skillLevelList = {}
    roleConfig[v.ID] = data
  end
  local PSKillSprint_LevelSkillConfig = CDataTable.GetTable("PSKillSprint_LevelSkillConfig")
  for k, v in pairs(PSKillSprint_LevelSkillConfig) do
    local data = TableUtil.FastCopyTable(psSkill_sprint_config.SLevelSkillConfig)
    data.LevelID = v.LevelID
    data.SkillName = v.SkillName
    data.SkillDesc = v.SkillDesc
    data.SkillIcon = v.SkillIcon
    data.SkillTipPic1 = v.SkillTipPic1
    data.SkillTipPic2 = v.SkillTipPic2
    local roleID = v.RoleID
    local LevelID = v.LevelID
    local config = roleConfig[roleID]
    config.skillLevelList[LevelID] = data
  end
  log_tree("psSkill_sprint_util.InitConfig. roleConfig = ", roleConfig)
  local levelConfig = {}
  local PSKillSprint_LevelConfig = CDataTable.GetTable("PSKillSprint_LevelConfig")
  for k, v in pairs(PSKillSprint_LevelConfig) do
    local data = TableUtil.FastCopyTable(psSkill_sprint_config.SLevelConfig)
    data.ID = v.ID
    data.Name = v.Name
    data.LevelIcon = v.LevelIcon
    levelConfig[v.ID] = data
  end
  log_tree("psSkill_sprint_util.InitConfig. levelConfig = ", levelConfig)
  return roleConfig, levelConfig
end
function psSkill_sprint_util.GetShowData()
  local logic_psSkill_sprint = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_psSkill_sprint)
  local roleConfig = logic_psSkill_sprint:GetRoleConfig()
  return roleConfig
end
function psSkill_sprint_util.GetCurrentRoleConfig()
  local logic_psSkill_sprint = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_psSkill_sprint)
  return logic_psSkill_sprint:GetCurrentRoleConfig()
end
function psSkill_sprint_util.GetLevelConfigByID(levelID)
  local logic_psSkill_sprint = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_psSkill_sprint)
  return logic_psSkill_sprint:GetLevelConfigByID(levelID)
end
function psSkill_sprint_util.OpenMainUI()
  log(bWriteLog and "psSkill_sprint_util.OpenMainUI")
  UIManager.ShowUI(UIManager.UI_Config.PSKillSprint_Popup_UIBP)
end
function psSkill_sprint_util.CheckIsSelectedTargetView()
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local isThemeMatch = logic_mode_selection:CheckIsSelectedThemeView()
  log_format("psSkill_sprint_util.CheckIsSelectedTargetView. isThemeMatch = [%s]", isThemeMatch)
  if not isThemeMatch then
    return false
  end
  local _, selectViewID, _ = logic_mode_selection:GetCurSelectInfo()
  local modeID = logic_mode_selection:GetModeIDByViewID(selectViewID)
  local paramCfg = CDataTable.GetTableData("DSDataTransmissionCfg", psSkill_sprint_config.CTransmissionKey)
  local whiteListStr = paramCfg.SubModeWhiteList or ""
  local StringUtil = require("common.string_util")
  local subModeWhiteList = StringUtil.SplitToNum(whiteListStr, ";")
  local TableUtil = require("common.table_util")
  local isInWhiteList = TableUtil.IsInTable(subModeWhiteList, modeID)
  log_format("psSkill_sprint_util.CheckIsSelectedTargetView. isInWhiteList = [%s]", isInWhiteList)
  if not isInWhiteList then
    log_warning_format("psSkill_sprint_util.CheckIsSelectedTargetView. modeID = [%s]", modeID)
    log_tree("psSkill_sprint_util.CheckIsSelectedTargetView. subModeWhiteList = ", subModeWhiteList)
    return false
  end
  return true
end
return psSkill_sprint_util