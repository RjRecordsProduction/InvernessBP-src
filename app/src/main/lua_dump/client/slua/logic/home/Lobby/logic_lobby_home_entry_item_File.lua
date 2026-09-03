local logic_lobby_home_entry_item_File = {}
function logic_lobby_home_entry_item_File.LoadFile()
  log(bWriteLog and "logic_lobby_home_entry_item_File.LoadFile")
  local playerprefs = require("client.logic.LogicPlayerPrefs.playerprefs")
  local fileTb = playerprefs.LoadFileToTable_N(playerprefs.ePlayerPrefsType.eLobbyHomeEntryItemInfo)
  fileTb = fileTb or {
    qipao_info = {},
    show_info = {}
  }
  logic_lobby_home_entry_item_File.  log_tree("fileTb 2 = ", fileTb)
  return fileTb
end
function logic_lobby_home_entry_item_File.SaveFile(fileTb)
  log(bWriteLog and "logic_lobby_home_entry_item_File.SaveFile")
  if fileTb == nil then
    log(bWriteLog and "logic_lobby_home_entry_item_File.SaveFile 1")
    return
  end
  logic_lobby_home_entry_item_File.  log_tree("fileTb = ", fileTb)
  local playerprefs = require("client.logic.LogicPlayerPrefs.playerprefs")
  playerprefs.SaveTableToFile_N(logic_lobby_home_entry_item_File.fileTb, playerprefs.ePlayerPrefsType.eLobbyHomeEntryItemInfo)
end
return logic_lobby_home_entry_item_File