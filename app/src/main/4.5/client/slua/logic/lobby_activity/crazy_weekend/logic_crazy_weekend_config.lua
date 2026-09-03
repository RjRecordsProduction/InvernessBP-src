local actType = ActivityType
local logic_crazy_weekend_config = {
  GroupTitleInfo = {
    [1] = 85730,
    [2] = 85739
  },
  GroupChildInfo = {
    [1] = {
      actType.WORLDCUP_SCORE_PROTECT,
      actType.WORLDCUP_DOUBLE_CHALLENGE,
      actType.WORLDCUP_TEAMUP_ADD_RATING,
      actType.RANK_NO_SEGMENT_LIMIT
    },
    [2] = {
      actType.DOUBLE_EXP,
      actType.WORLDCUP_UPVOTE_DOUBLE_POPULARITY,
      actType.WORLDCUP_TEAMUP_DOUBLE_INTIMACY,
      actType.ACTIVITY_TYPE_LINK
    }
  },
  TypeToSegmentProtectInfo = {
    [actType.WORLDCUP_SCORE_PROTECT] = {id = 16},
    [actType.WORLDCUP_TEAMUP_ADD_RATING] = {
      id = 17,
      icon = "/Game/UMG/Texture/Lobby_NoAtlas/Lobby_Season_Review/S20/Lobby_season_new_icon28.Lobby_season_new_icon28"
    },
    [actType.WORLDCUP_DOUBLE_CHALLENGE] = {id = 18},
    [actType.WORLDCUP_UPVOTE_DOUBLE_POPULARITY] = {
      id = 19,
      icon = "/Game/UMG/Texture/Lobby_NoAtlas/Lobby_Season_Review/S20/Lobby_season_new_icon25.Lobby_season_new_icon25"
    },
    [actType.WORLDCUP_TEAMUP_DOUBLE_INTIMACY] = {
      id = 20,
      icon = "/Game/UMG/Texture/Lobby_NoAtlas/Lobby_Season_Review/S20/Lobby_season_new_icon24.Lobby_season_new_icon24"
    },
    [actType.DOUBLE_EXP] = {
      id = 36,
      icon = "/Game/UMG/Texture/Lobby_NoAtlas/Lobby_Season_Review/S20/Lobby_season_new_icon23.Lobby_season_new_icon23"
    },
    [actType.RANK_NO_SEGMENT_LIMIT] = {
      id = 5,
      icon = "/Game/UMG/Texture/Lobby_NoAtlas/Lobby_Season_Review/S20/Lobby_season_new_icon26.Lobby_season_new_icon26",
      TitleID = 85822,
      DescID = 85823
    },
    [actType.ACTIVITY_TYPE_LINK] = {
      icon = "/Game/UMG/Texture/Lobby_NoAtlas/Lobby_Season_Review/S20/Lobby_season_new_icon27.Lobby_season_new_icon27"
    }
  },
  audioPath = "/Game/WwiseEvent/UI/UI_400/Play_UI_Lobby_CrazyWeekend_Music.Play_UI_Lobby_CrazyWeekend_Music",
  ActivityLabelType = 323232,
  TeamUpTwiceLabelType = 323231,
  TeamUpFourLabelType = 323233
}
return logic_crazy_weekend_config