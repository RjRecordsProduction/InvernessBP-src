local logic_TxMission_in_lobby = {}
function logic_TxMission_in_lobby.GetTPlanIconInLobby(rankIntegral)
  log(bWriteLog and "logic_TxMission_in_lobby.GetTPlanIconInLobby")
  if not rankIntegral then
    log(bWriteLog and "logic_TxMission_in_lobby.GetTPlanIconInLobby not rankIntegral")
    return
  end
  local rankCfg = CDataTable.GetTableData("TxMissionSegment", rankIntegral)
  if not rankCfg then
    log(bWriteLog and "logic_TxMission_in_lobby.GetTPlanIconInLobby rankCfg is nil")
    return
  end
  local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
  PufferMapManager:MountMapPak("map_tplan")
  return rankCfg
end
return logic_TxMission_in_lobby