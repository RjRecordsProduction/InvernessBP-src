local RatingCardBuffConfig = {
  ExtraCheckActivityList = {
    [ActivityType.HAPPY_TO_TEAM] = {
      modulePath = "client.slua.logic.activity.rating_protect_activity.logic_rating_protect_activity",
      isModuleBase = false,
      checkFunc = "IsShowRatingProtected",
      countFunc = "GetRatingProtectedCount"
    },
    [ActivityType.DAY_FIRST_WIN] = {
      modulePath = "client.slua.logic.activity.day_first_win.logic_day_first_win",
      isModuleBase = false,
      checkFunc = "CheckShowDayFirstWinTask",
      countFunc = "GetDayFirstWinTaskProgress"
    },
    [ActivityType.Peak_GAME_ADD_SCORE] = {
      modulePath = "client.slua.logic.activity.rating_protect_activity.logic_rating_protect_peak",
      isModuleBase = false,
      checkFunc = "CheckAddActivity",
      countFunc = "GetAddActivityProgress",
      checkAndCountListFunc = "checkAndCountListFunc"
    },
    [ActivityType.Peak_GAME_NOT_SCORE] = {
      modulePath = "client.slua.logic.activity.rating_protect_activity.logic_rating_protect_peak",
      isModuleBase = false,
      checkFunc = "CheckProtectctivity",
      countFunc = "GetProtectActivityProgress"
    }
  },
  MultiProtect = {
    [ActivityType.Peak_GAME_ADD_SCORE] = true
  },
  BuffSourceType = {
    Normal = 1,
    Activity = 2,
    ItemCard = 3,
    ChallengeProtect = 4
  },
  BuffType = {SegmentProtect = 1, AddScore = 2}
}
return RatingCardBuffConfig