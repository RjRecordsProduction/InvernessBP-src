local logic_friend_list_utils = {}
function logic_friend_list_utils.HideLobby_InviteFriend_BP_Menu()
  local Lobby_InviteFriend_BP = UIManager.GetUI(UIManager.UI_Config.Lobby_InviteFriend_BP)
  if not Lobby_InviteFriend_BP then
    return
  end
  Lobby_InviteFriend_BP:HideMenu()
end
function logic_friend_list_utils.HideLobby_InviteFriend_BP_Newbie()
  local Lobby_InviteFriend_BP = UIManager.GetUI(UIManager.UI_Config.Lobby_InviteFriend_BP)
  if not Lobby_InviteFriend_BP then
    return
  end
  Lobby_InviteFriend_BP:HideNewbie()
end
function logic_friend_list_utils.ShowLobby_InviteFriend_BP_Menu(uid)
  local Lobby_InviteFriend_BP = UIManager.GetUI(UIManager.UI_Config.Lobby_InviteFriend_BP)
  if not Lobby_InviteFriend_BP then
    return
  end
  Lobby_InviteFriend_BP:ShowMenu(uid)
end
return logic_friend_list_utils