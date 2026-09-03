local level_unlock_get_widget_config = {}
local Get_lobby_mode_entry_Button_Enter = function()
  local LobbyMain = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  local match_new_entry = LobbyMain:GetChildUI(UIManager.UI_Config.match_new_entry)
  if match_new_entry then
    local uiInfo = match_new_entry:GetChildWindow(UIManager.UI_Config.lobby_mode_entry)
    if uiInfo then
      return uiInfo.UIRoot.Button_Enter
    end
  end
end
function level_unlock_get_widget_config.GetWidgetMatchMode()
  return Get_lobby_mode_entry_Button_Enter()
end
function level_unlock_get_widget_config.GetWidgetMatchModeStep2()
  local uiInfo = UIManager.GetUI(UIManager.UI_Config.mode_selection_main)
  if uiInfo == nil then
    log_warning(bWriteLog and "level_unlock_get_widget_config.GetWidgetMatchModeStep2 uiInfo is nil")
    return nil
  end
  local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
  local widget = uiInfo:GetAlphaMenuItemWidgetByTabID(mode_selection_macro.Enum_TabID.RankClassic)
  return widget
end
function level_unlock_get_widget_config.GetWidgetTeamCompetitionStep2()
  local uiInfo = UIManager.GetUI(UIManager.UI_Config.mode_selection_main)
  if uiInfo == nil then
    log_warning(bWriteLog and "level_unlock_get_widget_config.GetWidgetTeamCompetitionStep2 uiInfo is nil")
    return nil
  end
  local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
  local widget = uiInfo:GetBetaMenuItemWidgetByTabID(mode_selection_macro.Enum_TabID.MatchArena)
  return widget
end
function level_unlock_get_widget_config.GetWidgetEntertainMode()
  return Get_lobby_mode_entry_Button_Enter()
end
function level_unlock_get_widget_config.GetWidgetEntertainModeStep2()
  local uiInfo = UIManager.GetUI(UIManager.UI_Config.mode_selection_main)
  if uiInfo == nil then
    log_warning(bWriteLog and "level_unlock_get_widget_config.GetWidgetEntertainModeStep2 uiInfo is nil")
    return nil
  end
  local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
  local widget = uiInfo:GetBetaMenuItemWidgetByTabID(mode_selection_macro.Enum_TabID.Other, true)
  return widget
end
function level_unlock_get_widget_config.GetWidgetPVE()
  return Get_lobby_mode_entry_Button_Enter()
end
function level_unlock_get_widget_config.GetWidgetPVEStep2()
  local uiInfo = UIManager.GetUI(UIManager.UI_Config.mode_selection_main)
  if uiInfo == nil then
    log_warning(bWriteLog and "level_unlock_get_widget_config.GetWidgetPVEStep2 uiInfo is nil")
    return nil
  end
  local widget = uiInfo:GetViewMapItemByViewID(10353)
  return widget
end
function level_unlock_get_widget_config.GetWidgetSocialIsland()
  return Get_lobby_mode_entry_Button_Enter()
end
function level_unlock_get_widget_config.GetWidgetTeamCompetition()
  return Get_lobby_mode_entry_Button_Enter()
end
function level_unlock_get_widget_config.GetWidgetHome()
  local lobbyMain = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  if lobbyMain then
    local LobbyMidMessageUIBP = lobbyMain:GetChildUI(UIManager.UI_Config.Lobby_Mid_Message_UIBP)
    if LobbyMidMessageUIBP then
      local uiInfo = LobbyMidMessageUIBP:GetChildWindow(UIManager.UI_Config.Lobby_Home_Entrance_Item_UIBP)
      if uiInfo then
        return uiInfo.UIRoot
      end
    end
  end
end
return level_unlock_get_widget_config