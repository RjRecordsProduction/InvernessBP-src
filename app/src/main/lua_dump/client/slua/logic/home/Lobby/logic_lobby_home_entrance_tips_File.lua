local logic_lobby_home_entrance_tips_File = {}
function logic_lobby_home_entrance_tips_File.OnModePostSwitch(_, nNextState)
  if nNextState ~= GameStatus.Lobby then
    logic_lobby_home_entrance_tips_File.fileTb = nil
  end
end
function logic_lobby_home_entrance_tips_File.LoadFile()
  log(bWriteLog and "logic_lobby_home_entrance_tips_File.LoadFile")
  if logic_lobby_home_entrance_tips_File.fileTb then
    return logic_lobby_home_entrance_tips_File.fileTb
  end
  local playerprefs = require("client.logic.LogicPlayerPrefs.playerprefs")
  local fileTb = playerprefs.LoadFileToTable_N(playerprefs.ePlayerPrefsType.eLobbyHomeEntranceTipsItemInfo)
  fileTb = fileTb or {
    show_info = {}
  }
  logic_lobby_home_entrance_tips_File.  log_tree(bWriteLog and "logic_lobby_home_entrance_tips_File fileTb 2 = ", fileTb)
  return fileTb
end
function logic_lobby_home_entrance_tips_File.SaveFile(fileTb)
  log(bWriteLog and "logic_lobby_home_entrance_tips_File.SaveFile")
  if fileTb == nil then
    log(bWriteLog and "logic_lobby_home_entrance_tips_File.SaveFile 1")
    return
  end
  logic_lobby_home_entrance_tips_File.  log_tree(bWriteLog and "logic_lobby_home_entrance_tips_File SaveFile fileTb = ", fileTb)
  local playerprefs = require("client.logic.LogicPlayerPrefs.playerprefs")
  playerprefs.SaveTableToFile_N(logic_lobby_home_entrance_tips_File.fileTb, playerprefs.ePlayerPrefsType.eLobbyHomeEntranceTipsItemInfo)
end
return logic_lobby_home_entrance_tips_File