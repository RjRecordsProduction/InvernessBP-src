local popular_home_pk_macros = {
  ENUM_HOME_PK_TAB_TYPE = {
    Sign = 1,
    PK = 2,
    Square = 3,
    Style = 4,
    Award = 5
  },
  ENUM_STATE = {
    OTHER = 0,
    CLOSE = 1,
    SIGN = 2,
    PK = 3
  },
  ENUM_PLAYER_STATE = {
    CLOSE = 0,
    SIGN = 1,
    SIGNED = 2,
    MATCH = 3,
    PK = 4,
    RESULT = 5
  },
  ENUM_GAME_RESULT = {
    LOSS = -1,
    TIE = 0,
    WIN = 1
  },
  ENUM_PK_RECORD_SOURCE = {ALL = 1, RECENT = 2},
  ENUM_PK_LEVEL_AWARD_STATUS = {
    LOCK = 0,
    UNLOCK = 1,
    RECEIVED = 2
  },
  ENUM_TASK_AWARD_STATUS = {
    Finish = 1,
    NotFinish = 2,
    Award = 3
  },
  VOTE_ITEM_ID = 1534093,
  ENUM_HOME_STYLE_NOMINATE_SOURCE = {RECOMMEND = 1, FRIEND = 2}
}
return popular_home_pk_macros