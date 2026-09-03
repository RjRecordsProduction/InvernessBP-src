local logic_lobby_main = {
  lobbyTopNewsStatus = {
    [ENUM_LobbyPageType.Left] = false,
    [ENUM_LobbyPageType.Mid] = false,
    [ENUM_LobbyPageType.Right] = false
  },
  isCurrentShow = false
}
local NotifyPageType = {
  Left = 1,
  Mid = 2,
  Right = 3
}
function logic_lobby_main.ShowLobbyUI()
  local lobbyMain = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  local Lobby_Main_Control = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
  log(bWriteLog and "logic_lobby_main.ShowLobbyUI lobbyMain:" .. tostring(lobbyMain))
  if not lobbyMain then
    return
  end
  local LobbyThemeManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyThemeManager)
  LobbyThemeManager:EndPreviewTheme()
  lobbyMain:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  if not IsWoWEditor then
    local lobbyMidShop = lobbyMain:GetChildUI(UIManager.UI_Config.Lobby_Mid_Shop_UIBP)
    if lobbyMidShop then
      lobbyMidShop:UpdateLobbyMallReddot()
    end
    local Lobby_Main_Switch_UIBP = lobbyMain:GetChildUI(UIManager.UI_Config.Lobby_Main_Switch_UIBP)
    if Lobby_Main_Switch_UIBP then
      Lobby_Main_Switch_UIBP:HandleExitFromXmission()
      Lobby_Main_Switch_UIBP:CheckShowRightScreenNewbie()
    end
    local Lobby_Mid_Activity_UIBP = lobbyMain:GetChildUI(UIManager.UI_Config.Lobby_Mid_Activity_UIBP)
    if Lobby_Mid_Activity_UIBP then
      Lobby_Mid_Activity_UIBP:UpdateLobbySpecialReddot()
    end
    Lobby_Main_Control.RecoverCameraPos()
    if Lobby_Main_Control.curPage == ENUM_LobbyPageType.Left then
      local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
      LobbySocialSystem.Recover()
    elseif Lobby_Main_Control.curPage == ENUM_LobbyPageType.Mid then
      local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
      TeamUpNewSystem.ShowTeamUI()
    end
  end
  logic_lobby_main.isCurrentShow = true
  if UIManager.GetUI(UIManager.UI_Config.Lobby_SimpleUI_Main_UIBP) then
    UIManager.CloseUI(UIManager.UI_Config.Lobby_SimpleUI_Main_UIBP)
  end
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_SHOW_LOBBY)
end
function logic_lobby_main.HideLobbyUI()
  local lobbyMain = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  log(bWriteLog and "logic_lobby_main.HideLobbyUI lobbyMain:" .. tostring(lobbyMain))
  if lobbyMain then
    lobbyMain:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if not IsWoWEditor then
    local logic_home_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_switch)
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    TeamUpNewSystem.HideTeamUI()
  end
  UIManager.CloseUI(UIManager.UI_Config.Lab_Main_Newbie_Slide_UIBP)
  logic_lobby_main.isCurrentShow = false
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_HIDE_LOBBY)
end
function logic_lobby_main.RecordLobbyTopReddotData(data)
  if data ~= nil then
    logic_lobby_main.lobbyTopNewsStatus[ENUM_LobbyPageType.Left] = data[NotifyPageType.Left] and data[NotifyPageType.Left].state
    logic_lobby_main.lobbyTopNewsStatus[ENUM_LobbyPageType.Mid] = data[NotifyPageType.Mid] and data[NotifyPageType.Mid].state
    logic_lobby_main.lobbyTopNewsStatus[ENUM_LobbyPageType.Right] = data[NotifyPageType.Right] and data[NotifyPageType.Right].state
    EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_ON_NOTIFY_LOBBY_TOP_NEWS)
  end
end
function logic_lobby_main.send_get_top_red_point_req()
  require("client.network.Protocol.LobbyHandler").send_get_top_red_point_req()
end
function logic_lobby_main.on_top_red_point_notify(top_red_point_info, type, subtype)
  log(bWriteLog and "logic_lobby_main.on_top_red_point_notify - top_red_point_info:" .. tostring(top_red_point_info) .. ", typ:" .. tostring(type) .. ", subtype:" .. tostring(subtype))
  log_tree("logic_lobby_main.on_top_red_point_notify", top_red_point_info)
  logic_lobby_main.RecordLobbyTopReddotData(top_red_point_info)
end
function logic_lobby_main.close_top_red_point_req(type)
  if logic_lobby_main.lobbyTopNewsStatus[type - 1] then
    log(bWriteLog and "[DeanJYT] logic_lobby_main.close_top_red_point_req closing lobby top redpoint of type: " .. tostring(type))
    logic_lobby_main.lobbyTopNewsStatus[type - 1] = false
    require("client.network.Protocol.LobbyHandler").send_close_top_red_point_req(type)
  end
end
function logic_lobby_main.on_close_top_red_point_rsp(err, type)
  log(bWriteLog and "logic_lobby_main.on_close_top_red_point_rsp - err: " .. tostring(err) .. ", type: " .. tostring(type))
end
return logic_lobby_main