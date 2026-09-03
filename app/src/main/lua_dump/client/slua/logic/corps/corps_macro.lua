local corps_macro = {WeekRank = 1, SeasonRank = 2}
corps_macro.EnergyType = {
  NoType = 0,
  Active = 1,
  Athletics = 2,
  Evolve = 3,
  RP = 4
}
corps_macro.RankIndexToType = {
  [101] = corps_macro.WeekRank,
  [102] = corps_macro.SeasonRank,
  [103] = corps_macro.WeekRank,
  [104] = corps_macro.SeasonRank,
  [105] = corps_macro.WeekRank,
  [106] = corps_macro.SeasonRank,
  [107] = corps_macro.WeekRank,
  [108] = corps_macro.SeasonRank
}
corps_macro.RanIndexToEnergyType = {
  [101] = corps_macro.EnergyType.Active,
  [102] = corps_macro.EnergyType.Active,
  [103] = corps_macro.EnergyType.Athletics,
  [104] = corps_macro.EnergyType.Athletics,
  [105] = corps_macro.EnergyType.Evolve,
  [106] = corps_macro.EnergyType.Evolve,
  [107] = corps_macro.EnergyType.RP,
  [108] = corps_macro.EnergyType.RP
}
corps_macro.RankTypeToIndex = {
  [corps_macro.EnergyType.RP] = {
    [corps_macro.WeekRank] = 107,
    [corps_macro.SeasonRank] = 108
  },
  [corps_macro.EnergyType.Active] = {
    [corps_macro.WeekRank] = 101,
    [corps_macro.SeasonRank] = 102
  },
  [corps_macro.EnergyType.Evolve] = {
    [corps_macro.WeekRank] = 105,
    [corps_macro.SeasonRank] = 106
  },
  [corps_macro.EnergyType.Athletics] = {
    [corps_macro.WeekRank] = 103,
    [corps_macro.SeasonRank] = 104
  }
}
corps_macro.SearchType = {Normal = 1, Fuzzy = 2}
corps_macro.NoticeClickFrom = {MainUI = 1, Chat = 2}
return corps_macro