local NetManager = require("client.network.comm.NetManager")
local NewModeHandler = {}
function NewModeHandler.send_get_mode_shield_v2_req(file_timestamp)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eModeSelectionMsg) or {}
  if not file_timestamp and cfg.file_timestamp and cfg.sub_mode_to_view and cfg.sub_mode_to_mutiviews then
    file_timestamp = cfg.file_timestamp
  end
  NetManager.SendPkg(1221327655, file_timestamp)
end
function NewModeHandler.on_get_mode_shield_v2_rsp(menu_object, default_view_id, current_choose, sub_mode_to_view, default_viewid, sub_mode_to_mutiviews, selection_details, file_timestamp)
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eModeSelectionMsg) or {}
  if sub_mode_to_view and sub_mode_to_mutiviews and file_timestamp then
    cfg.    cfg.    cfg.    PlayerPrefsSystem.SaveTableToFile_N(cfg, PlayerPrefsSystem.ePlayerPrefsType.eModeSelectionMsg)
  elseif not sub_mode_to_view and not sub_mode_to_mutiviews then
    sub_mode_to_view = cfg.sub_mode_to_view
    sub_mode_to_mutiviews = cfg.sub_mode_to_mutiviews
  end
  logic_mode_selection:OnGetModeShield(menu_object, default_view_id, current_choose, sub_mode_to_view, default_viewid, sub_mode_to_mutiviews, selection_details)
end
function NewModeHandler.send_get_hunter_vs_hunted_career_data_req()
  NetManager.SendPkg(851945063)
end
function NewModeHandler.on_get_hunter_vs_hunted_career_data_rsp(career_data)
  local logic_mode_asymmertric = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_asymmertric)
  local data = logic_mode_asymmertric:proc_get_hunter_vs_hunted_career_data_rsp(career_data)
end
return NewModeHandler