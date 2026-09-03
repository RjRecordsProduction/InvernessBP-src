local season_year_config = {}
season_year_config.CSeasonYearCoin = 1703321
season_year_config.CrownTaskMaxCount = 10
season_year_config.ETabMenuIDs = {
  Badge = 1,
  Badge_Sub = {Cur_Badge = 101, History_Badge = 102},
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
season_year_config.EShowSceneType = {
  pre_team = "pre_team",
  social_hall = "social_hall",
  battle_load = "battle_load"
}
season_year_config.PointTabInfo = {
  [season_year_config.EBadgePartType.Gem] = {
    name = 85254,
    title = 85258,
    desc = 18010483,
    icon = "/Game/Mod/Lobby/Base/NewSeason/SeasonYear/Atlas/Frames/LobbySeason_Icon_Crown_png.LobbySeason_Icon_Crown_png"
  },
  [season_year_config.EBadgePartType.Base] = {
    name = 85255,
    title = 85259,
    desc = 18010484,
    icon = "/Game/Mod/Lobby/Base/NewSeason/SeasonYear/Atlas/Frames/LobbySeason_Icon_Frame_png.LobbySeason_Icon_Frame_png"
  },
  [season_year_config.EBadgePartType.Glow] = {
    name = 85256,
    title = 85260,
    desc = 18010485,
    icon = "/Game/Mod/Lobby/Base/NewSeason/SeasonYear/Atlas/Frames/LobbySeason_Icon_LightEffect_png.LobbySeason_Icon_LightEffect_png"
  },
  [season_year_config.EBadgePartType.Crown] = {
    name = 85257,
    title = 85261,
    desc = 18010486,
    icon = "/Game/Mod/Lobby/Base/NewSeason/SeasonYear/Atlas/Frames/LobbySeason_Icon_StarStone_png.LobbySeason_Icon_StarStone_png"
  }
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