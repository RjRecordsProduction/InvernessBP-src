local popularity_macro = {
  ENUM_TAB_TYPE = {
    ContriList = 1,
    RecentList = 2,
    Message = 3,
    GiftRecord = 4,
    MyGuard = 5,
    Store = 6,
    PopularityPK = 7,
    PopularityTeamPK = 8
  },
  ENUM_SUB_TAB_TYPE = {
    Popular_PK = 1,
    Popular_PK_Award = 2,
    Popular_Team_PK = 3,
    Popular_Team_PK_Team = 4,
    Popular_Team_PK_Award = 5,
    Popular_PK_Celebration = 6,
    Popular_PK_Introduction = 7,
    Popular_PK_TreasureBox = 8,
    Popular_PK_FunAward = 9
  },
  ENUM_ANNUAL_TAB_TYPE = {
    Annual_Reward = 1,
    Annual_Rule = 2,
    Level_Reward = 3,
    TreasureBox_Reward = 4,
    Fun_Award = 5
  },
  COIN_ITEM_ID = 1703265,
  ENUM_EXCHANGE_PREVIEW_TYPE = {
    Avatar = 1,
    AvatarFrame = 2,
    InvitePopup = 3,
    ChatBubble = 4,
    NickName = 5,
    CDNImage = 6
  },
  ENUM_PK_LEVEL_AWARD_STATUS = {
    LOCK = 0,
    UNLOCK = 1,
    RECEIVED = 2
  },
  ENUM_HIGH_VALUE_GIFT_REQ_SOURCE = {TOOLCARD = 1, MAINCITY = 2}
}
local TLog_TabClick = {
  [popularity_macro.ENUM_TAB_TYPE.PopularityPK] = TLogEventDefine.PopularPKTabClick,
  [popularity_macro.ENUM_TAB_TYPE.PopularityTeamPK] = TLogEventDefine.PopularTeamPKTabClick
}
popularity_macro.return popularity_macro