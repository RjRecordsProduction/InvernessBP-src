local logic_version_update_slap = {
  SaveLocalVersion = {}
}
function logic_version_update_slap.CheckCanSlap()
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  if LogicNewbie.IsNewbie() then
    log_warning(bWriteLog and "logic_version_update_slap.CheckCanSlap is IsNewbie")
    return false
  end
  log(bWriteLog and "logic_version_update_slap.CheckCanSlap")
  if DataMgr.roleData.back_user_data then
    log_warning(bWriteLog and "logic_version_update_slap.CheckCanSlap is return player")
    return false
  end
  if logic_version_update_slap.CheckCurrentVersionIsSlap() then
    log_warning(bWriteLog and "logic_version_update_slap.CheckCanSlap is current version show")
    return false
  end
  if not logic_version_update_slap.CheckHasSlapConfig() then
    log_warning(bWriteLog and "logic_version_update_slap.CheckCanSlap is not has slap config")
    logic_version_update_slap._SaveLocalData()
    return false
  end
  return true
end
function logic_version_update_slap.CheckCanReturnSlap()
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  if LogicNewbie.IsNewbie() then
    log_warning(bWriteLog and "logic_version_update_slap.CheckCanSlap is IsNewbie")
    return false
  end
  local back_user_data = DataMgr.roleData.back_user_data
  if not back_user_data or not back_user_data.quick_battle_switch then
    log_warning_format("logic_version_update_slap.CheckCanReturnSlap is not return player. back_user_data = [%s], quick_battle_switch = [%s]", back_user_data, back_user_data and back_user_data.quick_battle_switch)
    return false
  end
  if logic_version_update_slap.CheckCurrentVersionIsSlap() then
    log_warning(bWriteLog and "logic_version_update_slap.CheckCanReturnSlap is current version show")
    return false
  end
  if not logic_version_update_slap.CheckHasSlapConfig() then
    log_warning(bWriteLog and "logic_version_update_slap.CheckCanReturnSlap is not has slap config")
    logic_version_update_slap._SaveLocalData()
    return false
  end
  return true
end
function logic_version_update_slap.ShowSlap(ignoreParam)
  local ParamTable
  if type(ignoreParam) ~= "boolean" or ignoreParam ~= true then
    local ui_show_queue_config = require("client.common.uibase.ui_show_queue_config")
    ParamTable = ui_show_queue_config.GetParamTable(nil, "IsSlapUI")
  end
  log(bWriteLog and "logic_version_update_slap.ShowSlap")
  local uiInfo, isInQueue = UIManager.ShowUI(UIManager.UI_Config.Lobby_VersionUpdateSlap_UIBP, nil, ParamTable)
  if uiInfo or isInQueue then
    logic_version_update_slap._SaveLocalData()
  end
end
function logic_version_update_slap.CheckHasSlapConfig()
  local version = logic_version_update_slap.GetValidVersion()
  local configList = CDataTable.GetTableByFilter("VersionUpdateSlapConfig", "Version", version)
  local count = 0
  for k, v in pairs(configList) do
    count = count + 1
  end
  log_format("logic_version_update_slap.CheckHasSlapConfig count = %d, version = %s", count, version)
  return 0 < count
end
function logic_version_update_slap.GetValidVersion()
  local version_util = require("client.common.version_util")
  local appVersion = Client.GetAppVersion()
  local version = version_util.GetMainFormat(appVersion)
  log_format("logic_version_update_slap._GetValidVersion version = [%s], appVersion = [%s]", version, appVersion)
  return version
end
function logic_version_update_slap.CheckCurrentVersionIsSlap()
  logic_version_update_slap._LoadLocalData()
  local savedVersion = logic_version_update_slap.SaveLocalVersion[DataMgr.roleData.uid]
  if savedVersion then
    local version = logic_version_update_slap.GetValidVersion()
    log_format("logic_version_update_slap.CheckCurrentVersionIsSlap version = %s, savedVersion = %s", version, savedVersion)
    return version == savedVersion
  end
  return false
end
function logic_version_update_slap._SaveLocalData()
  local version = logic_version_update_slap.GetValidVersion()
  logic_version_update_slap.SaveLocalVersion[DataMgr.roleData.uid] = version
  log_tree("logic_version_update_slap._SaveLocalData SaveLocalVersion = ", logic_version_update_slap.SaveLocalVersion)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(logic_version_update_slap.SaveLocalVersion, PlayerPrefsSystem.ePlayerPrefsType.eVersionUpdateSlap)
end
function logic_version_update_slap._LoadLocalData()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  logic_version_update_slap.SaveLocalVersion = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eVersionUpdateSlap) or {}
  log_tree("logic_version_update_slap._LoadLocalData SaveLocalVersion = ", logic_version_update_slap.SaveLocalVersion)
end
return logic_version_update_slap