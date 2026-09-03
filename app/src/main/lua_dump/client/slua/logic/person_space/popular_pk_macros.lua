local Popular_PK_Macros = {
  ENUM_STATE = {
    CLOSE = 0,
    SIGN = 1,
    SIGNED = 2,
    RESULT = 3,
    PK = 4,
    COMINGEND = 5
  },
  ENUM_DETAIL_STATUS = {
    DUEL = "duel",
    MATCHING = "matching",
    SEGMENT = "segment",
    ANNUAL = "annual"
  },
  ENUM_VIEW_PK_SWITCH = {
    CLOSE = 0,
    OPEN = 1,
    ONLYFRIEND = 2
  },
  ENUM_GAME_RESULT = {
    LOSS = -1,
    TIE = 0,
    WIN = 1
  },
  ENUM_REDDOT_TYPE = {
    SIGN = 1,
    PK = 2,
    Reward = 3
  },
  ENUM_RANK_STATUS = {
    Promotion = 1,
    Retention = 2,
    Demotion = 3
  },
  CELEBRATION_CONTRIBUTION_RANK_COUNT = 5,
  ENUM_STREAK_REWARD_STATUS = {
    NoFinish = 0,
    CanGet = 1,
    HasGot = 2
  }
}
return Popular_PK_Macros