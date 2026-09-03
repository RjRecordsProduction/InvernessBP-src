local season_year_config = {}
season_year_config.CSeasonYearCoin = 1703321
season_year_config.CrownTaskMaxCount = 10
season_year_config.ETabMenuIDs = {
  Badge = 1,
  Task = 2,
  Task_Sub = {ContinuousChallenge = 201, TrialChallenge = 202},
  Treasure = 3
}
season_year_config.ERankTaskStatus = {
  NotCompleted = 0,
  NotReceived = 1,
  Completed = 2
}
season_year_config.ERankTaskSeasonStatus = {NotCompleted = false, Completed = true}
season_year_config.ERankTaskRemedyStatus = {
  NotMet = 1,
  CanRemedy = 2,
  NoNeed = 3
}
season_year_config.ESeasonYearCoinType = {
  SeasonYearCoin = 1703321,
  SeasonYearCore = 1703322,
  SeasonYearTrialScore = 1703323
}
season_year_config.EPopupSeasonType = {RankDisplay = 1, AnnualAchievement = 2}
season_year_config.EBadgePartType = {
  Gem = 1,
  Base = 2,
  Glow = 3,
  Crown = 4
}
season_year_config.ETaskType = {
  ClassicSegment = 12,
  PeakGameSegment = 270,
  AchieveTrialChallenge = 271,
  TotalLoginPerSeason = 272
}
season_year_config.EStoreFilter = {
  All = 1,
  Own = 2,
  NotOwn = 3
}
season_year_config.EBadgeShowType = {Hide = 0, Show = 1}
season_year_config.SRankTaskData = {
  status = -1,
  season_status = nil,
  remedyStatus = season_year_config.ERankTaskRemedyStatus.NotMet
}
season_year_config.SRankTaskSeasonStatus = {preStatus = -1, nowStatus = -1}
season_year_config.SRankTaskRemedyConfig = {itemID = -1}
season_year_config.BlueHoleSpecialSeasonYear = {
  [46] = 11
}
function season_year_config.GetSeasonYearReward(seasonYearId)
  local SeasonYear_AnnualTitle = CDataTable.GetTable("SeasonYear_AnnualTitle")
  local StringUtil = require("common.string_util")
  for _, cfg in pairs(SeasonYear_AnnualTitle) do
    local years = StringUtil.Split(cfg.SeasonYearId, "|")
    for _, year in ipairs(years) do
      if year == tostring(seasonYearId) then
        return cfg
      end
    end
  end
  return nil
end
return season_year_config