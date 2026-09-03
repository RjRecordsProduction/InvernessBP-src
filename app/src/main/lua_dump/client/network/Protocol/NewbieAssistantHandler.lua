local NewbieAssistantHandler = {}
function NewbieAssistantHandler.on_get_total_match_cnt_rsp(total_match_cnt, classic_match_count)
  NewbieAssistantHandler.matchCount = total_match_cnt
  NewbieAssistantHandler.totalMatchCount = total_match_cnt
  NewbieAssistantHandler.classicMatchCount = classic_match_count
  local logic_season_guide_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_guide_manager)
  logic_season_guide_manager:RecordClassicRankCount(classic_match_count)
end
return NewbieAssistantHandler