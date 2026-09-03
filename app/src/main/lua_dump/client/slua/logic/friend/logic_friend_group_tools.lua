local logic_friend_group_tools = {}
function logic_friend_group_tools.GetRecentInteractLabel(type, idsep)
  log(bWriteLog and string.format("logic_friend_group_tools.GetRecentInteractLabel. type=%s, idsep=%s", tostring(type), tostring(idsep)))
  idsep = idsep or 3
  local cfg = CDataTable.GetTableData("RecentInteractCfg", type)
  if not cfg then
    return ""
  end
  if idsep == 1 then
    return cfg.InteractLocID1
  elseif idsep == 2 then
    return cfg.InteractLocID2
  elseif idsep == 3 then
    return cfg.InteractLocID3
  end
  return ""
end
function logic_friend_group_tools.GetRecentInteractSourceLabel(sourceID)
  log(bWriteLog and "logic_friend_group_tools.GetRecentInteractSourceLabel sourceID = " .. sourceID)
  local config = CDataTable.GetTableData("RecentInteractCfg", sourceID)
  local text = ""
  if config and config.InteractSourceLocID > 0 then
    text = LocUtil.GetLocalizeResStr(config.InteractSourceLocID)
  end
  return text
end
function logic_friend_group_tools.NeedShowDropGuide()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eTeamupSideBarComboBoxGuide) or {}
  if cfg and cfg[DataMgr.roleData.uid] then
    log(bWriteLog and "logic_friend_group:NeedShowDropGuide finish guide")
    return false
  end
  log(bWriteLog and "logic_friend_group:NeedShowDropGuide show guide")
  return true
end
function logic_friend_group_tools.SetHasShowDropGuide()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eTeamupSideBarComboBoxGuide) or {}
  cfg[DataMgr.roleData.uid] = true
  PlayerPrefsSystem.SaveTableToFile_N(cfg, PlayerPrefsSystem.ePlayerPrefsType.eTeamupSideBarComboBoxGuide)
end
return logic_friend_group_tools