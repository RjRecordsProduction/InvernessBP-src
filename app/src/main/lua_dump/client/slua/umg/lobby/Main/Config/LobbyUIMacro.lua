local LobbyUIMacro = {
  lobbyUIArr = {
    UIManager.UI_Config.Lobby_Main_Wifi_UIBP,
    UIManager.UI_Config.Lobby_Main_Money_UIBP,
    UIManager.UI_Config.Lobby_Main_Switch_UIBP,
    UIManager.UI_Config.match_new_entry,
    UIManager.UI_Config.Lobby_Mid_Friend_UIBP,
    UIManager.UI_Config.Lobby_Mid_Message_UIBP,
    UIManager.UI_Config.Lobby_Mid_Activity_UIBP,
    UIManager.UI_Config.Lobby_Mid_Banner_UIBP,
    UIManager.UI_Config.lobby_downloader_btn,
    UIManager.UI_Config.lobby_main_right_bottom_tab,
    UIManager.UI_Config.lobby_main_chat_entrance,
    UIManager.UI_Config.lobby_bottom_right_uibp,
    UIManager.UI_Config.lobby_news,
    UIManager.UI_Config.WoW_CommonEnterRoomTips_UIBP
  },
  rightModeUIArr = {
    UIManager.UI_Config.ModeSelection_Custom_UIBP,
    UIManager.UI_Config.ModeSelection_Opening_Train_UIBP
  },
  lobbyChildUIPreloadArr = {
    UIManager.UI_Config.Lobby_Main_UIBP,
    UIManager.UI_Config.lobby_mode_entry,
    UIManager.UI_Config.Lobby_Mid_Binner_More_UIBP,
    UIManager.UI_Config.loading,
    UIManager.UI_Config.team_main
  },
  lobbyModulePreloadArr = {
    "logic_lobby_actor_voice"
  }
}
if IsWoWEditor then
  LobbyUIMacro.lobbyUIArr = {
    UIManager.UI_Config.ugc_mine_main
  }
  LobbyUIMacro.socialUIArr = {}
  LobbyUIMacro.rightModeUIArr = {}
  LobbyUIMacro.lobbyChildUIPreloadArr = {
    UIManager.UI_Config.ugc_mine_main,
    UIManager.UI_Config.loading
  }
  LobbyUIMacro.lobbyModulePreloadArr = {}
end
return LobbyUIMacro