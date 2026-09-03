local FuncLibrary = {
  SEQ120 = {
    1,
    2,
    0
  },
  BOOL_FT = {false, true}
}
function FuncLibrary.GetValue(key)
  local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
  return SettingModule:GetOptionValue(key)
end
function FuncLibrary.SetValue(key, value)
  local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
  return SettingModule:SetOptionValue(key, value)
end
function FuncLibrary.BShow_InLobby()
  if IsWoWEditor then
    return false
  end
  return not GameStatus or GameStatus.IsInLobbyOrMainCity()
end
function FuncLibrary.BShow_bRecordWonderfulReplayOpen()
  if IsWoWEditor then
    return false
  end
  if not GameStatus or not LobbySystem then
    return true
  end
  return GameStatus.IsInLobbyOrMainCity() and LobbySystem.CheckOpen(BP_ENUM_WONDERFUL_REPLAY_SWITCH)
end
function FuncLibrary.BShow_IsNotWoWEditor()
  return not IsWoWEditor
end
return FuncLibrary