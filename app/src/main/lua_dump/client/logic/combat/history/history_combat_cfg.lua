local history_combat_cfg = {
  EBattleType = {
    All = 1,
    Rank = 2,
    PeakGame = 3,
    Match = 4,
    Team = 5,
    Others = 6,
    Escape = 7
  }
}
history_combat_cfg.ETypeToTLog = {
  [history_combat_cfg.EBattleType.All] = nil,
  [history_combat_cfg.EBattleType.Rank] = TLogEventDefine.HistoryRank,
  [history_combat_cfg.EBattleType.PeakGame] = TLogEventDefine.HistoryPeakGame,
  [history_combat_cfg.EBattleType.Match] = TLogEventDefine.HistoryMatch,
  [history_combat_cfg.EBattleType.Team] = TLogEventDefine.HistoryTeam,
  [history_combat_cfg.EBattleType.Escape] = TLogEventDefine.Escape,
  [history_combat_cfg.EBattleType.Others] = TLogEventDefine.HistoryOthers
}
history_combat_cfg.EHvHCampType = {Hunter = 1, Hunted = 2}
return history_combat_cfg