local rank_config = {
  RankInfoListItem = {
    no = 0,
    uid = "",
    score = 0,
    name = "",
    nation = "",
    url = "",
    level = 0,
    city = "",
    gender = 0,
    content1 = "",
    content2 = "",
    content3 = "",
    is_buy = 0,
    keep_buy = 0,
    uishow = false,
    upass_level = 0,
    cur_value = 0,
    segment = 0,
    arena_rating_and_segment = {},
    cur_avatar_box_id = 0,
    startup_type = 0,
    aliasId = 0,
    aliasTitle = "",
    aliasNation = "",
    aliasRankId = 0,
    ext_data = {}
  },
  Const = {
    C_OnePageCount = 5,
    C_DefaultScore = 1200,
    C_DefaultSegment = 101
  },
  ColorConfig = {
    grayBlue_parentSelect = FSlateColor(FLinearColor(1, 0.723, 0.0152, 1)),
    whiteBlue_parentUnSelect = FSlateColor(FLinearColor(1, 1, 1, 0.5)),
    black = FSlateColor(FLinearColor(0, 0, 0, 1)),
    grayBlue = FSlateColor(FLinearColor(0.015996, 0.0185, 0.020289, 1)),
    whiteBlue = FSlateColor(FLinearColor(0.597202, 0.672443, 0.730461, 1)),
    orange = FSlateColor(FLinearColor(1, 0.610496, 0, 1)),
    white = FSlateColor(FLinearColor(1, 1, 1, 1)),
    black0P7Alpha = FSlateColor(FLinearColor(0, 0, 0, 0.7)),
    blackBlue = FSlateColor(FLinearColor(0.020289, 0.025187, 0.039546, 1)),
    orange2 = FSlateColor(FLinearColor(0.991102, 0.571125, 0, 1)),
    orange3 = FSlateColor(FLinearColor(1, 0.623961, 0, 1)),
    whiteHalfAlpha = FSlateColor(FLinearColor(1, 1, 1, 0.5))
  },
  ScoreType = {
    total_rating = 1000,
    solo_total_rating = 1001,
    solo_win_rating = 1002,
    solo_kill_rating = 1003,
    duo_total_rating = 2001,
    duo_win_rating = 2002,
    duo_kill_rating = 2003,
    squad_total_rating = 3001,
    squad_win_rating = 3002,
    squad_kill_rating = 3003,
    fpp_total_rating = 4000,
    fpp_solo_total_rating = 4001,
    fpp_solo_win_rating = 4002,
    fpp_solo_kill_rating = 4003,
    fpp_duo_total_rating = 5001,
    fpp_duo_win_rating = 5002,
    fpp_duo_kill_rating = 5003,
    fpp_squad_total_rating = 6001,
    fpp_squad_win_rating = 6002,
    fpp_squad_kill_rating = 6003,
    weapon_usage_score_rating = 96009601,
    unknown_pass_acc_score_rating = 99001,
    unknown_pass_acc_score_rating_Global = 99002,
    unknown_pass_acc_score_rating_KRJP = 99003,
    popularity_total_rating = 72001,
    popularity_weekly_rating = 72002,
    popularity_total_rating_jk = 72003,
    popularity_weekly_rating_jk = 72004,
    pround_total_rating = 72005,
    pround_weekly_rating = 72006,
    pround_total_rating_jk = 72007,
    pround_weekly_rating_jk = 72008,
    guardian_total_rating = 72009,
    guardian_weekly_rating = 72010,
    guardian_total_rating_jk = 72011,
    guardian_weekly_rating_jk = 72012,
    popularity_pk_rating = 72013,
    popularity_pk_rating_jk = 72014,
    popularity_team_pk_rating = 72015,
    pve_rating = 10001,
    arena_rating = 20001,
    like_rating = 71003,
    recent_like_rating = 71004,
    charisma_rating = 73001,
    career_rating = 77001,
    anniversary_rating = 10002,
    anniversary_jk_rating = 10003,
    achievement_rating = 74001,
    achievement_rating_jk = 74002,
    xmission_raven_rating = 75001,
    xmission_kill_rating = 75002,
    xmission_kill_military = 75003,
    xmission_zombie_rating = 75004,
    xmission_raven_week_rating = 75101,
    xmission_kill_week_rating = 75102,
    xmission_zombie_week_rating = 75103,
    sink_rating = 80001,
    peakgame_rating = 9001,
    peakgame_week_rating = 9002,
    peakgame_hof_rating = 9003,
    peakgame_kd_rating = 9004,
    peakgame_solo_win_total_rating = 9005,
    peakgame_multi_win_total_rating = 9006,
    peakgame_squad_win_total_rating = 9007,
    peakgame_solo_win_weekly_rating = 9008,
    peakgame_multi_win_weekly_rating = 9009,
    peakgame_squad_win_weekly_rating = 9010,
    peakgame_kd_weekly_rating = 9011,
    peakgame_ability_kd_rating = 9014,
    peakgame_ability_solo_win_total_rating = 9015,
    peakgame_ability_multi_win_total_rating = 9016,
    peakgame_ability_squad_win_total_rating = 9017,
    planph_prosperity = 91001,
    planph_popularity = 91002,
    planph_total_heat = 91003,
    planph_week_heat = 91004,
    planph_newest = 90005,
    planph_highest_prosperity = 90006,
    planph_snowman_height = 90007,
    planph_style_score = 90008,
    planph_car_parking = 90009,
    wow_author_level = 92101,
    wow_mod_popularity = 92102,
    wow_mod_popularity_week = 92103,
    wow_play_level = 92104,
    intimacy_lover_total_rating = 72016,
    intimacy_lover_weekly_rating = 72017,
    intimacy_lover_total_rating_krjp = 72018,
    intimacy_lover_weekly_rating_krjp = 72019,
    intimacy_bestie_total_rating = 72020,
    intimacy_bestie_weekly_rating = 72021,
    intimacy_bestie_total_rating_krjp = 72022,
    intimacy_bestie_weekly_rating_krjp = 72023,
    intimacy_homie_total_rating = 72024,
    intimacy_homie_weekly_rating = 72025,
    intimacy_homie_total_rating_krjp = 72026,
    intimacy_homie_weekly_rating_krjp = 72027,
    intimacy_bestfriend_total_rating = 72028,
    intimacy_bestfriend_weekly_rating = 72029,
    intimacy_bestfriend_total_rating_krjp = 72030,
    intimacy_bestfriend_weekly_rating_krjp = 72031,
    intimacy_family_total_rating = 72034,
    intimacy_family_weekly_rating = 72035,
    intimacy_family_total_rating_krjp = 72036,
    intimacy_family_weekly_rating_krjp = 72037,
    home_pk_season_rating = 72032,
    home_pk_square_rating = 72033,
    manor_style_select_rating = 72039,
    collect_upvote_rating = 74003,
    collect_upvote_rating_jpkr = 74004,
    star_gift_giver_rating = 72041,
    star_most_gifted_rating = 72042,
    star_generosity_rating = 72043,
    star_wide_friend_rating = 72044,
    star_lucky_chicken_rating = 72045,
    star_golden_jet_rating = 72046
  },
  ReqFromType = {
    lobbyRank = 1,
    modeSelection = 2,
    homeCollectionRank = 3,
    peakRankHall = 4
  }
}
rank_config.RankSelectEnum = {
  peakgame = "peakgame",
  peak = "peak",
  peakgame_kd = "peakgame_kd",
  peakgame_win = "peakgame_win",
  tpp = "tpp",
  sum = "sum",
  win = "win",
  beat = "beat",
  total = "total",
  fpp = "fpp",
  fpp_sum = "fpp_sum",
  fpp_win = "fpp_win",
  fpp_beat = "fpp_beat",
  fpp_total = "fpp_total",
  weapon_usage_score = "weapon_usage_score",
  gift = "gift",
  popularity = "popularity",
  pround = "pround",
  guardian = "guardian",
  intimacy = "intimacy",
  lover = "lover",
  bestie = "bestie",
  homie = "homie",
  bestFriend = "bestFriend",
  family = "family",
  like = "like",
  upass = "upass",
  pve = "pve",
  charisma = "charisma",
  arena = "arena",
  achievement = "achievement",
  career = "career",
  planPH = "planPH",
  sink = "sink",
  wow = "wow",
  wow_author = "wow_author",
  wow_play_level = "wow_play_level",
  wow_author_level = "wow_author_level",
  wow_mod_popularity = "wow_mod_popularity",
  anniversary = "anniversary",
  xmission_raven = "xmission_raven",
  xmission_kill = "xmission_kill",
  xmission_military = "xmission_military",
  xmission_raven_week = "xmission_raven_week",
  xmission_kill_week = "xmission_kill_week",
  xmission_zombie = "xmission_zombie",
  xmission_zombie_week = "xmission_zombie_week"
}
rank_config.VerticalTabConfig = {
  {
    tabID = rank_config.RankSelectEnum.peakgame,
    locID = 46065,
    subData = {
      {
        subTabID = rank_config.RankSelectEnum.peak,
        locID = 102100
      },
      {
        subTabID = rank_config.RankSelectEnum.peakgame_kd,
        locID = 615
      },
      {
        subTabID = rank_config.RankSelectEnum.peakgame_win,
        locID = 613
      }
    }
  },
  {
    tabID = rank_config.RankSelectEnum.tpp,
    locID = 46049,
    subData = {
      {
        subTabID = rank_config.RankSelectEnum.sum,
        locID = 102100
      },
      {
        subTabID = rank_config.RankSelectEnum.win,
        locID = 102101
      },
      {
        subTabID = rank_config.RankSelectEnum.beat,
        locID = 102102
      },
      {
        subTabID = rank_config.RankSelectEnum.total,
        locID = 102103
      }
    }
  },
  {
    tabID = rank_config.RankSelectEnum.fpp,
    locID = 46050,
    subData = {
      {
        subTabID = rank_config.RankSelectEnum.fpp_sum,
        locID = 102100
      },
      {
        subTabID = rank_config.RankSelectEnum.fpp_win,
        locID = 102101
      },
      {
        subTabID = rank_config.RankSelectEnum.fpp_beat,
        locID = 102102
      },
      {
        subTabID = rank_config.RankSelectEnum.fpp_total,
        locID = 102103
      }
    }
  },
  {
    tabID = rank_config.RankSelectEnum.weapon_usage_score,
    locID = 68218
  },
  {
    tabID = rank_config.RankSelectEnum.gift,
    locID = 43698,
    subData = {
      {
        subTabID = rank_config.RankSelectEnum.popularity,
        locID = 43208
      },
      {
        subTabID = rank_config.RankSelectEnum.pround,
        locID = 43272
      },
      {
        subTabID = rank_config.RankSelectEnum.guardian,
        locID = 43209
      }
    }
  },
  {
    tabID = rank_config.RankSelectEnum.intimacy,
    locID = 77125,
    subData = {
      {
        subTabID = rank_config.RankSelectEnum.lover,
        locID = 77126
      },
      {
        subTabID = rank_config.RankSelectEnum.bestie,
        locID = 77127
      },
      {
        subTabID = rank_config.RankSelectEnum.homie,
        locID = 77128
      },
      {
        subTabID = rank_config.RankSelectEnum.bestFriend,
        locID = 77129
      },
      {
        subTabID = rank_config.RankSelectEnum.family,
        locID = 73281
      }
    }
  },
  {
    tabID = rank_config.RankSelectEnum.planPH,
    locID = 648040
  },
  {
    tabID = rank_config.RankSelectEnum.wow,
    locID = 82244,
    subData = {
      {
        subTabID = rank_config.RankSelectEnum.wow_author,
        locID = 82240
      },
      {
        subTabID = rank_config.RankSelectEnum.wow_play_level,
        locID = 82241
      }
    }
  },
  {
    tabID = rank_config.RankSelectEnum.arena,
    locID = 9126
  },
  {
    tabID = rank_config.RankSelectEnum.upass,
    locID = 46046
  },
  {
    tabID = rank_config.RankSelectEnum.achievement,
    locID = 46047
  },
  {
    tabID = rank_config.RankSelectEnum.pve,
    locID = 6885
  },
  {
    tabID = rank_config.RankSelectEnum.like,
    locID = 46048
  },
  {
    tabID = rank_config.RankSelectEnum.career,
    locID = 24834
  }
}
rank_config.InspectEnum = {
  notSet = 1,
  accepted = 2,
  notAccepted = 3
}
rank_config.PopularityReqType = {
  friendReq = "FriendReq",
  selfReq = "SelfReq",
  teamPKReq = "teamPKReq"
}
rank_config.ReqType = {
  friendReq = "FriendReq",
  selfReq = "SelfReq",
  rank = "Rank"
}
rank_config.PeriodEnum = {total = "total", week = "week"}
rank_config.RegionEnum = {all = "all", friend = "friend"}
rank_config.ProgramVersionEnum = {jpkr = "jpkr", global = "global"}
rank_config.MemberEnum = {
  single = "single",
  double = "double",
  team = "team"
}
rank_config.MemberEnumIndexMap = {
  [rank_config.MemberEnum.single] = 1,
  [rank_config.MemberEnum.double] = 2,
  [rank_config.MemberEnum.team] = 3
}
rank_config.PlanPHEnum = {
  prosperity = 1,
  popularity = 2,
  total_heat = 3,
  week_heat = 4,
  newest = 5
}
rank_config.PlanPHComboBoxConfig = {
  {
    Type = rank_config.PlanPHEnum.prosperity,
    LocID = 64754
  },
  {
    Type = rank_config.PlanPHEnum.popularity,
    LocID = 64755
  },
  {
    Type = rank_config.PlanPHEnum.total_heat,
    LocID = 64756
  },
  {
    Type = rank_config.PlanPHEnum.week_heat,
    LocID = 64757
  },
  {
    Type = rank_config.PlanPHEnum.newest,
    LocID = 64758
  }
}
rank_config.WoWAuthorEnum = {level = 1, popularity = 2}
rank_config.WoWAuthorComboBoxConfig = {
  {
    Type = rank_config.WoWAuthorEnum.level,
    LocID = 82242
  },
  {
    Type = rank_config.WoWAuthorEnum.popularity,
    LocID = 82243
  }
}
rank_config.SegmentType = {
  classic = 1,
  noSegment = 2,
  arenaSegment = 3,
  maxSegment = 4
}
rank_config.GEMReportString = {
  SubEventName_RankRP = "SubEventName_RankRP",
  SubEventName_RankEvo = "SubEventName_RankEvo",
  SubEventName_RankArena = "SubEventName_RankArena",
  SubEventName_RankCharisma = "SubEventName_RankCharisma",
  SubEventName_RankAchievement = "SubEventName_RankAchievement",
  SubEventName_RankTPP = "SubEventName_RankTPP",
  SubEventName_RankFPP = "SubEventName_RankFPP",
  SubEventName_RankServer = "SubEventName_RankServer",
  SubEventName_RankFriend = "SubEventName_RankFriend",
  SubEventName_RankPlanPH = "SubEventName_RankPlanPH",
  SubEventName_RankWoWAuthorLevel = "SubEventName_RankWoWAuthorLevel",
  SubEventName_RankWoWModPopularity = "SubEventName_RankWoWModPopularity",
  SubEventName_RankWowPlayLevel = "SubEventName_RankWowPlayLevel",
  SubEventName_RankLike = "SubEventName_RankLike",
  SubEventName_RankGift = "SubEventName_RankGift",
  SubEventName_RankPopularity = "SubEventName_RankPopularity",
  SubEventName_RankPround = "SubEventName_RankPround",
  SubEventName_RankGuardian = "SubEventName_RankGuardian",
  SubEventName_RankFppSum = "SubEventName_RankFppSum",
  SubEventName_RankFppWin = "SubEventName_RankFppWin",
  SubEventName_RankFppBeat = "SubEventName_RankFppBeat",
  SubEventName_RankFppTotal = "SubEventName_RankFppTotal",
  SubEventName_RankSum = "SubEventName_RankSum",
  SubEventName_RankWin = "SubEventName_RankWin",
  SubEventName_RankBeat = "SubEventName_RankBeat",
  SubEventName_RankTotal = "SubEventName_RankTotal",
  SubEventName_RankCareer = "SubEventName_RankCareer",
  SubEventName_RankLover = "SubEventName_RankLover",
  SubEventName_RankBestie = "SubEventName_RankBestie",
  SubEventName_RankHomie = "SubEventName_RankHomie",
  SubEventName_RankBestFriend = "SubEventName_RankBestFriend",
  SubEventName_RankFamily = "SubEventName_RankFamily",
  SubEventName_RankWeaponUsageScore = "SubEventName_RankWeaponUsageScore",
  SubEventName_RankPeakgame = "SubEventName_RankPeakgame",
  SubEventName_RankPeak = "SubEventName_RankPeak",
  SubEventName_RankPeakgameKd = "SubEventName_RankPeakgameKd",
  SubEventName_RankPeakgameWin = "SubEventName_RankPeakgameWin"
}
rank_config.RankInfoDiffConfig = {
  [rank_config.RankSelectEnum.sum] = {
    SegmentType = rank_config.SegmentType.classic,
    HeaderConfig = {
      total = 102106,
      exist = 102107,
      beat = 102108,
      time = 102110,
      total_narrow = 102106,
      playerName = 102105,
      open_charisma = nil,
      close_charisma = nil
    }
  },
  [rank_config.RankSelectEnum.win] = {
    SegmentType = rank_config.SegmentType.classic,
    HeaderConfig = {
      total = 102107,
      exist = 102114,
      beat = 102117,
      time = 102111,
      total_narrow = 102107,
      playerName = 102105,
      open_charisma = nil,
      close_charisma = nil
    }
  },
  [rank_config.RankSelectEnum.beat] = {
    SegmentType = rank_config.SegmentType.classic,
    HeaderConfig = {
      total = 102108,
      exist = 102115,
      beat = 102118,
      time = 102112,
      total_narrow = 102108,
      playerName = 102105,
      open_charisma = nil,
      close_charisma = nil
    }
  },
  [rank_config.RankSelectEnum.total] = {
    SegmentType = rank_config.SegmentType.classic,
    HeaderConfig = {
      total = 102109,
      exist = 102116,
      beat = 102119,
      time = 102113,
      total_narrow = 102109,
      playerName = 102105,
      open_charisma = nil,
      close_charisma = nil
    }
  },
  [rank_config.RankSelectEnum.fpp_sum] = {
    SegmentType = rank_config.SegmentType.classic,
    HeaderConfig = {
      total = 102106,
      exist = 102107,
      beat = 102108,
      time = 102110,
      total_narrow = 102106,
      playerName = 102105,
      open_charisma = nil,
      close_charisma = nil
    }
  },
  [rank_config.RankSelectEnum.fpp_win] = {
    SegmentType = rank_config.SegmentType.classic,
    HeaderConfig = {
      total = 102107,
      exist = 102114,
      beat = 102117,
      time = 102111,
      total_narrow = 102107,
      playerName = 102105,
      open_charisma = nil,
      close_charisma = nil
    }
  },
  [rank_config.RankSelectEnum.fpp_beat] = {
    SegmentType = rank_config.SegmentType.classic,
    HeaderConfig = {
      total = 102108,
      exist = 102115,
      beat = 102118,
      time = 102112,
      total_narrow = 102108,
      playerName = 102105,
      open_charisma = nil,
      close_charisma = nil
    }
  },
  [rank_config.RankSelectEnum.fpp_total] = {
    SegmentType = rank_config.SegmentType.classic,
    HeaderConfig = {
      total = 102109,
      exist = 102116,
      beat = 102119,
      time = 102113,
      total_narrow = 102109,
      playerName = 102105,
      open_charisma = nil,
      close_charisma = nil
    }
  },
  [rank_config.RankSelectEnum.weapon_usage_score] = {
    SegmentType = rank_config.SegmentType.classic,
    HeaderConfig = {
      total = 68229,
      exist = nil,
      beat = nil,
      time = nil,
      total_narrow = nil,
      playerName = 102105,
      open_charisma = nil,
      close_charisma = nil
    }
  },
  [rank_config.RankSelectEnum.like] = {
    SegmentType = rank_config.SegmentType.maxSegment,
    HeaderConfig = {
      total = 6286,
      exist = nil,
      beat = nil,
      time = nil,
      total_narrow = 6286,
      playerName = 102105,
      open_charisma = nil,
      close_charisma = nil
    }
  },
  [rank_config.RankSelectEnum.popularity] = {
    SegmentType = rank_config.SegmentType.maxSegment,
    HeaderConfig = {
      total = 6807,
      exist = nil,
      beat = nil,
      time = nil,
      total_narrow = 6807,
      playerName = 102105,
      open_charisma = 6807,
      close_charisma = 6807
    }
  },
  [rank_config.RankSelectEnum.pround] = {
    SegmentType = rank_config.SegmentType.maxSegment,
    HeaderConfig = {
      total = 43273,
      exist = nil,
      beat = nil,
      time = nil,
      total_narrow = 43273,
      playerName = 102105,
      open_charisma = 43273,
      close_charisma = 43273
    }
  },
  [rank_config.RankSelectEnum.guardian] = {
    HeaderConfig = {
      total = 6807,
      exist = nil,
      beat = nil,
      time = nil,
      total_narrow = 6807,
      open_charisma = 6807,
      close_charisma = 6807
    }
  },
  [rank_config.RankSelectEnum.lover] = {
    HeaderConfig = {playerName = 200031}
  },
  [rank_config.RankSelectEnum.bestie] = {
    HeaderConfig = {playerName = 200033}
  },
  [rank_config.RankSelectEnum.homie] = {
    HeaderConfig = {playerName = 200030}
  },
  [rank_config.RankSelectEnum.bestFriend] = {
    HeaderConfig = {playerName = 200032}
  },
  [rank_config.RankSelectEnum.family] = {
    HeaderConfig = {playerName = 73243}
  },
  [rank_config.RankSelectEnum.upass] = {
    SegmentType = rank_config.SegmentType.maxSegment,
    HeaderConfig = {
      total = 4541,
      exist = nil,
      beat = 102106,
      time = 4542,
      total_narrow = 4541,
      playerName = 102105,
      open_charisma = nil,
      close_charisma = nil
    }
  },
  [rank_config.RankSelectEnum.pve] = {
    SegmentType = rank_config.SegmentType.noSegment,
    HeaderConfig = {
      total = 6884,
      exist = nil,
      beat = nil,
      time = nil,
      total_narrow = 6884,
      playerName = 102105,
      open_charisma = nil,
      close_charisma = nil
    }
  },
  [rank_config.RankSelectEnum.charisma] = {
    SegmentType = rank_config.SegmentType.maxSegment,
    HeaderConfig = {
      total = 6920,
      exist = nil,
      beat = nil,
      time = nil,
      total_narrow = 6920,
      playerName = 102105,
      open_charisma = 6920,
      close_charisma = 6920
    }
  },
  [rank_config.RankSelectEnum.arena] = {
    SegmentType = rank_config.SegmentType.arenaSegment,
    HeaderConfig = {
      total = 102106,
      exist = nil,
      beat = nil,
      time = nil,
      total_narrow = 102106,
      playerName = 102105,
      open_charisma = nil,
      close_charisma = nil
    }
  },
  [rank_config.RankSelectEnum.achievement] = {
    SegmentType = rank_config.SegmentType.maxSegment,
    HeaderConfig = {
      total = 102106,
      exist = nil,
      beat = nil,
      time = nil,
      total_narrow = 102106,
      playerName = 102105,
      open_charisma = nil,
      close_charisma = nil
    }
  },
  [rank_config.RankSelectEnum.career] = {
    SegmentType = rank_config.SegmentType.maxSegment,
    HeaderConfig = {
      total = 24835,
      exist = nil,
      beat = nil,
      time = nil,
      total_narrow = 24835,
      playerName = 102105,
      open_charisma = nil,
      close_charisma = nil
    }
  },
  [rank_config.RankSelectEnum.anniversary] = {
    SegmentType = rank_config.SegmentType.maxSegment,
    HeaderConfig = {playerName = 102105}
  },
  [rank_config.RankSelectEnum.planPH] = {
    SegmentType = rank_config.SegmentType.maxSegment,
    HeaderConfig = {playerName = 102105}
  },
  [rank_config.RankSelectEnum.wow_author] = {
    SegmentType = rank_config.SegmentType.maxSegment
  },
  [rank_config.RankSelectEnum.wow_author_level] = {
    SegmentType = rank_config.SegmentType.maxSegment,
    HeaderConfig = {
      total = 4541,
      total_narrow = 82032001,
      playerName = 102105
    }
  },
  [rank_config.RankSelectEnum.wow_mod_popularity] = {
    SegmentType = rank_config.SegmentType.maxSegment,
    HeaderConfig = {
      total = 87810,
      total_narrow = 87810,
      playerName = 102105
    }
  },
  [rank_config.RankSelectEnum.wow_play_level] = {
    SegmentType = rank_config.SegmentType.maxSegment,
    HeaderConfig = {
      total = 4541,
      total_narrow = 82032001,
      playerName = 102105
    }
  },
  [rank_config.RankSelectEnum.peak] = {
    SegmentType = rank_config.SegmentType.maxSegment,
    HeaderConfig = {
      total = 68386,
      playerName = 102105,
      total_narrow = 68386
    }
  },
  [rank_config.RankSelectEnum.peakgame_kd] = {
    SegmentType = rank_config.SegmentType.maxSegment,
    HeaderConfig = {playerName = 102105, total_narrow = 102118}
  },
  [rank_config.RankSelectEnum.peakgame_win] = {
    SegmentType = rank_config.SegmentType.maxSegment,
    HeaderConfig = {playerName = 102105}
  }
}
rank_config.selectButtonInfo = {
  [rank_config.RankSelectEnum.upass] = {
    GEMReportStr = rank_config.GEMReportString.SubEventName_RankRP,
    TLog = TLogEventDefine.RankRP
  },
  [rank_config.RankSelectEnum.like] = {
    GEMReportStr = rank_config.GEMReportString.SubEventName_RankLike,
    TLog = TLogEventDefine.RankLike
  },
  [rank_config.RankSelectEnum.gift] = {
    GEMReportStr = rank_config.GEMReportString.SubEventName_RankGift,
    TLog = TLogEventDefine.RankGift
  },
  [rank_config.RankSelectEnum.popularity] = {
    GEMReportStr = rank_config.GEMReportString.SubEventName_RankPopularity,
    TLog = TLogEventDefine.RankPopularity
  },
  [rank_config.RankSelectEnum.pround] = {
    GEMReportStr = rank_config.GEMReportString.SubEventName_RankPround,
    TLog = TLogEventDefine.RankPround
  },
  [rank_config.RankSelectEnum.guardian] = {
    GEMReportStr = rank_config.GEMReportString.SubEventName_RankGuardian,
    TLog = TLogEventDefine.RankGuardian
  },
  [rank_config.RankSelectEnum.pve] = {
    GEMReportStr = rank_config.GEMReportString.SubEventName_RankEvo,
    TLog = TLogEventDefine.RankEvo
  },
  [rank_config.RankSelectEnum.charisma] = {
    GEMReportStr = rank_config.GEMReportString.SubEventName_RankCharisma,
    TLog = TLogEventDefine.RankCharisma
  },
  [rank_config.RankSelectEnum.arena] = {
    GEMReportStr = rank_config.GEMReportString.SubEventName_RankArena,
    TLog = TLogEventDefine.RankArena
  },
  [rank_config.RankSelectEnum.achievement] = {
    GEMReportStr = rank_config.GEMReportString.SubEventName_RankAchievement,
    TLog = TLogEventDefine.RankAchievement
  },
  [rank_config.RankSelectEnum.tpp] = {
    GEMReportStr = rank_config.GEMReportString.SubEventName_RankTPP,
    TLog = TLogEventDefine.RankTPP
  },
  [rank_config.RankSelectEnum.fpp] = {
    GEMReportStr = rank_config.GEMReportString.SubEventName_RankFPP,
    TLog = TLogEventDefine.RankFPP
  },
  [rank_config.RankSelectEnum.fpp_sum] = {
    GEMReportStr = rank_config.GEMReportString.SubEventName_RankFppSum,
    TLog = TLogEventDefine.RankFppSum
  },
  [rank_config.RankSelectEnum.fpp_win] = {
    GEMReportStr = rank_config.GEMReportString.SubEventName_RankFppWin,
    TLog = TLogEventDefine.RankFppWin
  },
  [rank_config.RankSelectEnum.fpp_beat] = {
    GEMReportStr = rank_config.GEMReportString.SubEventName_RankFppBeat,
    TLog = TLogEventDefine.RankFppBeat
  },
  [rank_config.RankSelectEnum.fpp_total] = {
    GEMReportStr = rank_config.GEMReportString.SubEventName_RankFppTotal,
    TLog = TLogEventDefine.RankFppTotal
  },
  [rank_config.RankSelectEnum.sum] = {
    GEMReportStr = rank_config.GEMReportString.SubEventName_RankSum,
    TLog = TLogEventDefine.RankSum
  },
  [rank_config.RankSelectEnum.win] = {
    GEMReportStr = rank_config.GEMReportString.SubEventName_RankWin,
    TLog = TLogEventDefine.RankWin
  },
  [rank_config.RankSelectEnum.beat] = {
    GEMReportStr = rank_config.GEMReportString.SubEventName_RankBeat,
    TLog = TLogEventDefine.RankBeat
  },
  [rank_config.RankSelectEnum.total] = {
    GEMReportStr = rank_config.GEMReportString.SubEventName_RankTotal,
    TLog = TLogEventDefine.RankTotal
  },
  [rank_config.RankSelectEnum.career] = {
    GEMReportStr = rank_config.GEMReportString.SubEventName_RankCareer,
    TLog = TLogEventDefine.RankCareer
  },
  [rank_config.RankSelectEnum.planPH] = {
    GEMReportStr = rank_config.GEMReportString.SubEventName_RankPlanPH,
    TLog = TLogEventDefine.RankPlanPH
  },
  [rank_config.RankSelectEnum.lover] = {
    GEMReportStr = rank_config.GEMReportString.SubEventName_RankLover,
    TLog = TLogEventDefine.RankLover
  },
  [rank_config.RankSelectEnum.bestie] = {
    GEMReportStr = rank_config.GEMReportString.SubEventName_RankBestie,
    TLog = TLogEventDefine.RankBestie
  },
  [rank_config.RankSelectEnum.homie] = {
    GEMReportStr = rank_config.GEMReportString.SubEventName_RankHomie,
    TLog = TLogEventDefine.RankHomie
  },
  [rank_config.RankSelectEnum.bestFriend] = {
    GEMReportStr = rank_config.GEMReportString.SubEventName_RankBestFriend,
    TLog = TLogEventDefine.RankBestFriend
  },
  [rank_config.RankSelectEnum.family] = {
    GEMReportStr = rank_config.GEMReportString.SubEventName_RankFamily,
    TLog = TLogEventDefine.RankFamily
  },
  [rank_config.RankSelectEnum.wow_author] = {
    GEMReportStr = rank_config.GEMReportString.SubEventName_RankWoWAuthorLevel,
    TLog = TLogEventDefine.RankWoWAuthorLevel
  },
  [rank_config.RankSelectEnum.wow_play_level] = {
    GEMReportStr = rank_config.GEMReportString.SubEventName_RankWowPlayLevel,
    TLog = TLogEventDefine.RankWowPlayLevel
  },
  [rank_config.RankSelectEnum.peakgame] = {
    GEMReportStr = rank_config.GEMReportString.SubEventName_RankPeakgame,
    TLog = TLogEventDefine.RankPeakgame
  },
  [rank_config.RankSelectEnum.peak] = {
    GEMReportStr = rank_config.GEMReportString.SubEventName_RankPeak,
    TLog = TLogEventDefine.RankPeak
  },
  [rank_config.RankSelectEnum.peakgame_kd] = {
    GEMReportStr = rank_config.GEMReportString.SubEventName_RankPeakgameKd,
    TLog = TLogEventDefine.RankPeakgameKd
  },
  [rank_config.RankSelectEnum.peakgame_win] = {
    GEMReportStr = rank_config.GEMReportString.SubEventName_RankPeakgameWin,
    TLog = TLogEventDefine.RankPeakgameWin
  },
  [rank_config.RankSelectEnum.weapon_usage_score] = {
    GEMReportStr = rank_config.GEMReportString.SubEventName_RankWeaponUsageScore,
    TLog = TLogEventDefine.RankWeaponUsageScore
  }
}
rank_config.NewRankInfoDiffConfig = {
  [rank_config.RankSelectEnum.sum] = {
    SegmentType = rank_config.SegmentType.classic,
    HeaderConfig = {
      title0 = 102106,
      title1 = 102107,
      title2 = 102108,
      title3 = 102110,
      playerName = 102105
    },
    Short_HeaderConfig = {title0 = 102106, playerName = 102105}
  },
  [rank_config.RankSelectEnum.win] = {
    SegmentType = rank_config.SegmentType.classic,
    HeaderConfig = {
      title0 = 102107,
      title1 = 102114,
      title2 = 102117,
      title3 = 102111,
      playerName = 102105
    },
    Short_HeaderConfig = {title0 = 102107, playerName = 102105}
  },
  [rank_config.RankSelectEnum.beat] = {
    SegmentType = rank_config.SegmentType.classic,
    HeaderConfig = {
      title0 = 102108,
      title1 = 102115,
      title2 = 102118,
      title3 = 102112,
      playerName = 102105
    },
    Short_HeaderConfig = {title0 = 102108, playerName = 102105}
  },
  [rank_config.RankSelectEnum.total] = {
    SegmentType = rank_config.SegmentType.classic,
    HeaderConfig = {
      title0 = 102109,
      title1 = 102116,
      title2 = 102119,
      title3 = 102113,
      playerName = 102105
    },
    Short_HeaderConfig = {title0 = 102109, playerName = 102105}
  },
  [rank_config.RankSelectEnum.fpp_sum] = {
    SegmentType = rank_config.SegmentType.classic,
    HeaderConfig = {
      title0 = 102106,
      title1 = 102107,
      title2 = 102108,
      title3 = 102110,
      playerName = 102105
    },
    Short_HeaderConfig = {title0 = 102106, playerName = 102105}
  },
  [rank_config.RankSelectEnum.fpp_win] = {
    SegmentType = rank_config.SegmentType.classic,
    HeaderConfig = {
      title0 = 102107,
      title1 = 102114,
      title2 = 102117,
      title3 = 102111,
      playerName = 102105
    },
    Short_HeaderConfig = {title0 = 102107, playerName = 102105}
  },
  [rank_config.RankSelectEnum.fpp_beat] = {
    SegmentType = rank_config.SegmentType.classic,
    HeaderConfig = {
      title0 = 102108,
      title1 = 102115,
      title2 = 102118,
      title3 = 102112,
      playerName = 102105
    },
    Short_HeaderConfig = {title0 = 102108, playerName = 102105}
  },
  [rank_config.RankSelectEnum.fpp_total] = {
    SegmentType = rank_config.SegmentType.classic,
    HeaderConfig = {
      title0 = 102109,
      title1 = 102116,
      title2 = 102119,
      title3 = 102113,
      playerName = 102105
    },
    Short_HeaderConfig = {title0 = 102109, playerName = 102105}
  },
  [rank_config.RankSelectEnum.weapon_usage_score] = {
    SegmentType = rank_config.SegmentType.classic,
    HeaderConfig = {
      title0 = 68229,
      playerName = 102105,
      showReward = true
    }
  },
  [rank_config.RankSelectEnum.like] = {
    SegmentType = rank_config.SegmentType.maxSegment,
    HeaderConfig = {title0 = 6286, playerName = 102105}
  },
  [rank_config.RankSelectEnum.popularity] = {
    SegmentType = rank_config.SegmentType.maxSegment,
    HeaderConfig = {
      title0 = 6807,
      playerName = 102105,
      showReward = true
    }
  },
  [rank_config.RankSelectEnum.pround] = {
    SegmentType = rank_config.SegmentType.maxSegment,
    HeaderConfig = {
      title0 = 43273,
      playerName = 102105,
      showReward = true
    }
  },
  [rank_config.RankSelectEnum.guardian] = {
    HeaderConfig = {
      title0 = 43256,
      playerName = 34456,
      showReward = true
    }
  },
  [rank_config.RankSelectEnum.lover] = {
    HeaderConfig = {
      title0 = 43229,
      playerName = 200031,
      showReward = true
    }
  },
  [rank_config.RankSelectEnum.bestie] = {
    HeaderConfig = {
      title0 = 43229,
      playerName = 200033,
      showReward = true
    }
  },
  [rank_config.RankSelectEnum.homie] = {
    HeaderConfig = {
      title0 = 43229,
      playerName = 200030,
      showReward = true
    }
  },
  [rank_config.RankSelectEnum.bestFriend] = {
    HeaderConfig = {
      title0 = 43229,
      playerName = 200032,
      showReward = true
    }
  },
  [rank_config.RankSelectEnum.family] = {
    HeaderConfig = {
      title0 = 43229,
      playerName = 73243,
      showReward = true
    }
  },
  [rank_config.RankSelectEnum.upass] = {
    SegmentType = rank_config.SegmentType.maxSegment,
    HeaderConfig = {
      title0 = 4541,
      title1 = 102106,
      title2 = 4542,
      playerName = 102105
    },
    Short_HeaderConfig = {title0 = 4541, playerName = 102105}
  },
  [rank_config.RankSelectEnum.pve] = {
    SegmentType = rank_config.SegmentType.noSegment,
    HeaderConfig = {title0 = 6884, playerName = 102105}
  },
  [rank_config.RankSelectEnum.charisma] = {
    SegmentType = rank_config.SegmentType.maxSegment,
    HeaderConfig = {title0 = 6920, playerName = 102105}
  },
  [rank_config.RankSelectEnum.arena] = {
    SegmentType = rank_config.SegmentType.arenaSegment,
    HeaderConfig = {title0 = 102106, playerName = 102105}
  },
  [rank_config.RankSelectEnum.achievement] = {
    SegmentType = rank_config.SegmentType.maxSegment,
    HeaderConfig = {title0 = 102106, playerName = 102105}
  },
  [rank_config.RankSelectEnum.career] = {
    SegmentType = rank_config.SegmentType.maxSegment,
    HeaderConfig = {title0 = 24835, playerName = 102105}
  },
  [rank_config.RankSelectEnum.anniversary] = {
    SegmentType = rank_config.SegmentType.maxSegment,
    HeaderConfig = {playerName = 102105}
  },
  [rank_config.RankSelectEnum.planPH] = {
    SegmentType = rank_config.SegmentType.maxSegment,
    HeaderConfig = {title0 = 65120, playerName = 102105}
  },
  [rank_config.RankSelectEnum.wow_author] = {
    SegmentType = rank_config.SegmentType.maxSegment
  },
  [rank_config.RankSelectEnum.wow_author_level] = {
    SegmentType = rank_config.SegmentType.maxSegment,
    HeaderConfig = {
      title0 = 4541,
      title1 = 82032001,
      playerName = 102105
    }
  },
  [rank_config.RankSelectEnum.wow_mod_popularity] = {
    SegmentType = rank_config.SegmentType.maxSegment,
    HeaderConfig = {title0 = 87810, playerName = 102105}
  },
  [rank_config.RankSelectEnum.wow_play_level] = {
    SegmentType = rank_config.SegmentType.maxSegment,
    HeaderConfig = {
      title0 = 4541,
      title1 = 82032001,
      playerName = 102105
    }
  },
  [rank_config.RankSelectEnum.peak] = {
    SegmentType = rank_config.SegmentType.maxSegment,
    HeaderConfig = {playerName = 102105, title0 = 68386}
  },
  [rank_config.RankSelectEnum.peakgame_kd] = {
    SegmentType = rank_config.SegmentType.maxSegment,
    HeaderConfig = {playerName = 102105, title0 = 615}
  },
  [rank_config.RankSelectEnum.peakgame_win] = {
    SegmentType = rank_config.SegmentType.maxSegment,
    HeaderConfig = {
      title0 = 613,
      playerName = 102105,
      showReward = true
    }
  }
}
rank_config.RankRequireConfig = {
  [rank_config.ScoreType.total_rating] = {
    rank_type = rank_config.RankSelectEnum.total
  },
  [rank_config.ScoreType.solo_total_rating] = {
    rank_type = rank_config.RankSelectEnum.sum,
    member_type = rank_config.MemberEnum.single
  },
  [rank_config.ScoreType.solo_win_rating] = {
    rank_type = rank_config.RankSelectEnum.win,
    member_type = rank_config.MemberEnum.single
  },
  [rank_config.ScoreType.solo_kill_rating] = {
    rank_type = rank_config.RankSelectEnum.beat,
    member_type = rank_config.MemberEnum.single
  },
  [rank_config.ScoreType.duo_total_rating] = {
    rank_type = rank_config.RankSelectEnum.sum,
    member_type = rank_config.MemberEnum.double
  },
  [rank_config.ScoreType.duo_win_rating] = {
    rank_type = rank_config.RankSelectEnum.win,
    member_type = rank_config.MemberEnum.double
  },
  [rank_config.ScoreType.duo_kill_rating] = {
    rank_type = rank_config.RankSelectEnum.beat,
    member_type = rank_config.MemberEnum.double
  },
  [rank_config.ScoreType.squad_total_rating] = {
    rank_type = rank_config.RankSelectEnum.sum,
    member_type = rank_config.MemberEnum.team
  },
  [rank_config.ScoreType.squad_win_rating] = {
    rank_type = rank_config.RankSelectEnum.win,
    member_type = rank_config.MemberEnum.team
  },
  [rank_config.ScoreType.squad_kill_rating] = {
    rank_type = rank_config.RankSelectEnum.beat,
    member_type = rank_config.MemberEnum.team
  },
  [rank_config.ScoreType.fpp_total_rating] = {
    rank_type = rank_config.RankSelectEnum.fpp_total
  },
  [rank_config.ScoreType.fpp_solo_total_rating] = {
    rank_type = rank_config.RankSelectEnum.fpp_sum,
    member_type = rank_config.MemberEnum.single
  },
  [rank_config.ScoreType.fpp_solo_win_rating] = {
    rank_type = rank_config.RankSelectEnum.fpp_win,
    member_type = rank_config.MemberEnum.single
  },
  [rank_config.ScoreType.fpp_solo_kill_rating] = {
    rank_type = rank_config.RankSelectEnum.fpp_beat,
    member_type = rank_config.MemberEnum.single
  },
  [rank_config.ScoreType.fpp_duo_total_rating] = {
    rank_type = rank_config.RankSelectEnum.fpp_sum,
    member_type = rank_config.MemberEnum.double
  },
  [rank_config.ScoreType.fpp_duo_win_rating] = {
    rank_type = rank_config.RankSelectEnum.fpp_win,
    member_type = rank_config.MemberEnum.double
  },
  [rank_config.ScoreType.fpp_duo_kill_rating] = {
    rank_type = rank_config.RankSelectEnum.fpp_beat,
    member_type = rank_config.MemberEnum.double
  },
  [rank_config.ScoreType.fpp_squad_total_rating] = {
    rank_type = rank_config.RankSelectEnum.fpp_sum,
    member_type = rank_config.MemberEnum.team
  },
  [rank_config.ScoreType.fpp_squad_win_rating] = {
    rank_type = rank_config.RankSelectEnum.fpp_win,
    member_type = rank_config.MemberEnum.team
  },
  [rank_config.ScoreType.fpp_squad_kill_rating] = {
    rank_type = rank_config.RankSelectEnum.fpp_beat,
    member_type = rank_config.MemberEnum.team
  },
  [rank_config.ScoreType.unknown_pass_acc_score_rating_Global] = {
    rank_type = rank_config.RankSelectEnum.upass,
    program_type = rank_config.ProgramVersionEnum.global
  },
  [rank_config.ScoreType.unknown_pass_acc_score_rating_KRJP] = {
    rank_type = rank_config.RankSelectEnum.upass,
    program_type = rank_config.ProgramVersionEnum.jpkr
  },
  [rank_config.ScoreType.like_rating] = {
    rank_type = rank_config.RankSelectEnum.like,
    period_type = rank_config.PeriodEnum.total
  },
  [rank_config.ScoreType.recent_like_rating] = {
    rank_type = rank_config.RankSelectEnum.like,
    period_type = rank_config.PeriodEnum.week
  },
  [rank_config.ScoreType.popularity_total_rating] = {
    rank_type = rank_config.RankSelectEnum.popularity,
    period_type = rank_config.PeriodEnum.total,
    program_type = rank_config.ProgramVersionEnum.global
  },
  [rank_config.ScoreType.popularity_weekly_rating] = {
    rank_type = rank_config.RankSelectEnum.popularity,
    period_type = rank_config.PeriodEnum.week,
    program_type = rank_config.ProgramVersionEnum.global
  },
  [rank_config.ScoreType.popularity_total_rating_jk] = {
    rank_type = rank_config.RankSelectEnum.popularity,
    period_type = rank_config.PeriodEnum.total,
    program_type = rank_config.ProgramVersionEnum.jpkr
  },
  [rank_config.ScoreType.popularity_weekly_rating_jk] = {
    rank_type = rank_config.RankSelectEnum.popularity,
    period_type = rank_config.PeriodEnum.week,
    program_type = rank_config.ProgramVersionEnum.jpkr
  },
  [rank_config.ScoreType.pround_total_rating] = {
    rank_type = rank_config.RankSelectEnum.pround,
    period_type = rank_config.PeriodEnum.total,
    program_type = rank_config.ProgramVersionEnum.global
  },
  [rank_config.ScoreType.pround_weekly_rating] = {
    rank_type = rank_config.RankSelectEnum.pround,
    period_type = rank_config.PeriodEnum.week,
    program_type = rank_config.ProgramVersionEnum.global
  },
  [rank_config.ScoreType.pround_total_rating_jk] = {
    rank_type = rank_config.RankSelectEnum.pround,
    period_type = rank_config.PeriodEnum.total,
    program_type = rank_config.ProgramVersionEnum.jpkr
  },
  [rank_config.ScoreType.pround_weekly_rating_jk] = {
    rank_type = rank_config.RankSelectEnum.pround,
    period_type = rank_config.PeriodEnum.week,
    program_type = rank_config.ProgramVersionEnum.jpkr
  },
  [rank_config.ScoreType.guardian_total_rating] = {
    rank_type = rank_config.RankSelectEnum.guardian,
    period_type = rank_config.PeriodEnum.total,
    program_type = rank_config.ProgramVersionEnum.global
  },
  [rank_config.ScoreType.guardian_weekly_rating] = {
    rank_type = rank_config.RankSelectEnum.guardian,
    period_type = rank_config.PeriodEnum.week,
    program_type = rank_config.ProgramVersionEnum.global
  },
  [rank_config.ScoreType.guardian_total_rating_jk] = {
    rank_type = rank_config.RankSelectEnum.guardian,
    period_type = rank_config.PeriodEnum.total,
    program_type = rank_config.ProgramVersionEnum.jpkr
  },
  [rank_config.ScoreType.guardian_weekly_rating_jk] = {
    rank_type = rank_config.RankSelectEnum.guardian,
    period_type = rank_config.PeriodEnum.week,
    program_type = rank_config.ProgramVersionEnum.jpkr
  },
  [rank_config.ScoreType.pve_rating] = {
    rank_type = rank_config.RankSelectEnum.pve
  },
  [rank_config.ScoreType.arena_rating] = {
    rank_type = rank_config.RankSelectEnum.arena
  },
  [rank_config.ScoreType.charisma_rating] = {
    rank_type = rank_config.RankSelectEnum.charisma
  },
  [rank_config.ScoreType.anniversary_rating] = {
    rank_type = rank_config.RankSelectEnum.anniversary,
    program_type = rank_config.ProgramVersionEnum.global
  },
  [rank_config.ScoreType.anniversary_jk_rating] = {
    rank_type = rank_config.RankSelectEnum.anniversary,
    program_type = rank_config.ProgramVersionEnum.jpkr
  },
  [rank_config.ScoreType.achievement_rating] = {
    rank_type = rank_config.RankSelectEnum.achievement,
    program_type = rank_config.ProgramVersionEnum.global
  },
  [rank_config.ScoreType.achievement_rating_jk] = {
    rank_type = rank_config.RankSelectEnum.achievement,
    program_type = rank_config.ProgramVersionEnum.jpkr
  },
  [rank_config.ScoreType.xmission_raven_rating] = {
    rank_type = rank_config.RankSelectEnum.xmission_raven
  },
  [rank_config.ScoreType.xmission_kill_rating] = {
    rank_type = rank_config.RankSelectEnum.xmission_kill
  },
  [rank_config.ScoreType.xmission_kill_military] = {
    rank_type = rank_config.RankSelectEnum.xmission_military
  },
  [rank_config.ScoreType.xmission_raven_week_rating] = {
    rank_type = rank_config.RankSelectEnum.xmission_raven_week
  },
  [rank_config.ScoreType.xmission_kill_week_rating] = {
    rank_type = rank_config.RankSelectEnum.xmission_kill_week
  },
  [rank_config.ScoreType.xmission_zombie_rating] = {
    rank_type = rank_config.RankSelectEnum.xmission_zombie
  },
  [rank_config.ScoreType.xmission_zombie_week_rating] = {
    rank_type = rank_config.RankSelectEnum.xmission_zombie_week
  },
  [rank_config.ScoreType.career_rating] = {
    rank_type = rank_config.RankSelectEnum.career
  },
  [rank_config.ScoreType.sink_rating] = {
    rank_type = rank_config.RankSelectEnum.sink
  },
  [rank_config.ScoreType.planph_prosperity] = {
    rank_type = rank_config.RankSelectEnum.planPH,
    planPH_type = rank_config.PlanPHEnum.prosperity
  },
  [rank_config.ScoreType.planph_popularity] = {
    rank_type = rank_config.RankSelectEnum.planPH,
    planPH_type = rank_config.PlanPHEnum.popularity
  },
  [rank_config.ScoreType.planph_total_heat] = {
    rank_type = rank_config.RankSelectEnum.planPH,
    planPH_type = rank_config.PlanPHEnum.total_heat
  },
  [rank_config.ScoreType.planph_week_heat] = {
    rank_type = rank_config.RankSelectEnum.planPH,
    planPH_type = rank_config.PlanPHEnum.week_heat
  },
  [rank_config.ScoreType.planph_newest] = {
    rank_type = rank_config.RankSelectEnum.planPH,
    planPH_type = rank_config.PlanPHEnum.newest
  },
  [rank_config.ScoreType.intimacy_lover_total_rating] = {
    rank_type = rank_config.RankSelectEnum.lover,
    period_type = rank_config.PeriodEnum.total,
    program_type = rank_config.ProgramVersionEnum.global
  },
  [rank_config.ScoreType.intimacy_lover_weekly_rating] = {
    rank_type = rank_config.RankSelectEnum.lover,
    period_type = rank_config.PeriodEnum.week,
    program_type = rank_config.ProgramVersionEnum.global
  },
  [rank_config.ScoreType.intimacy_lover_total_rating_krjp] = {
    rank_type = rank_config.RankSelectEnum.lover,
    period_type = rank_config.PeriodEnum.total,
    program_type = rank_config.ProgramVersionEnum.jpkr
  },
  [rank_config.ScoreType.intimacy_lover_weekly_rating_krjp] = {
    rank_type = rank_config.RankSelectEnum.lover,
    period_type = rank_config.PeriodEnum.week,
    program_type = rank_config.ProgramVersionEnum.jpkr
  },
  [rank_config.ScoreType.intimacy_bestie_total_rating] = {
    rank_type = rank_config.RankSelectEnum.bestie,
    period_type = rank_config.PeriodEnum.total,
    program_type = rank_config.ProgramVersionEnum.global
  },
  [rank_config.ScoreType.intimacy_bestie_weekly_rating] = {
    rank_type = rank_config.RankSelectEnum.bestie,
    period_type = rank_config.PeriodEnum.week,
    program_type = rank_config.ProgramVersionEnum.global
  },
  [rank_config.ScoreType.intimacy_bestie_total_rating_krjp] = {
    rank_type = rank_config.RankSelectEnum.bestie,
    period_type = rank_config.PeriodEnum.total,
    program_type = rank_config.ProgramVersionEnum.jpkr
  },
  [rank_config.ScoreType.intimacy_bestie_weekly_rating_krjp] = {
    rank_type = rank_config.RankSelectEnum.bestie,
    period_type = rank_config.PeriodEnum.week,
    program_type = rank_config.ProgramVersionEnum.jpkr
  },
  [rank_config.ScoreType.intimacy_homie_total_rating] = {
    rank_type = rank_config.RankSelectEnum.homie,
    period_type = rank_config.PeriodEnum.total,
    program_type = rank_config.ProgramVersionEnum.global
  },
  [rank_config.ScoreType.intimacy_homie_weekly_rating] = {
    rank_type = rank_config.RankSelectEnum.homie,
    period_type = rank_config.PeriodEnum.week,
    program_type = rank_config.ProgramVersionEnum.global
  },
  [rank_config.ScoreType.intimacy_homie_total_rating_krjp] = {
    rank_type = rank_config.RankSelectEnum.homie,
    period_type = rank_config.PeriodEnum.total,
    program_type = rank_config.ProgramVersionEnum.jpkr
  },
  [rank_config.ScoreType.intimacy_homie_weekly_rating_krjp] = {
    rank_type = rank_config.RankSelectEnum.homie,
    period_type = rank_config.PeriodEnum.week,
    program_type = rank_config.ProgramVersionEnum.jpkr
  },
  [rank_config.ScoreType.intimacy_bestfriend_total_rating] = {
    rank_type = rank_config.RankSelectEnum.bestFriend,
    period_type = rank_config.PeriodEnum.total,
    program_type = rank_config.ProgramVersionEnum.global
  },
  [rank_config.ScoreType.intimacy_bestfriend_weekly_rating] = {
    rank_type = rank_config.RankSelectEnum.bestFriend,
    period_type = rank_config.PeriodEnum.week,
    program_type = rank_config.ProgramVersionEnum.global
  },
  [rank_config.ScoreType.intimacy_bestfriend_total_rating_krjp] = {
    rank_type = rank_config.RankSelectEnum.bestFriend,
    period_type = rank_config.PeriodEnum.total,
    program_type = rank_config.ProgramVersionEnum.jpkr
  },
  [rank_config.ScoreType.intimacy_bestfriend_weekly_rating_krjp] = {
    rank_type = rank_config.RankSelectEnum.bestFriend,
    period_type = rank_config.PeriodEnum.week,
    program_type = rank_config.ProgramVersionEnum.jpkr
  },
  [rank_config.ScoreType.intimacy_family_total_rating] = {
    rank_type = rank_config.RankSelectEnum.family,
    period_type = rank_config.PeriodEnum.total,
    program_type = rank_config.ProgramVersionEnum.global
  },
  [rank_config.ScoreType.intimacy_family_weekly_rating] = {
    rank_type = rank_config.RankSelectEnum.family,
    period_type = rank_config.PeriodEnum.week,
    program_type = rank_config.ProgramVersionEnum.global
  },
  [rank_config.ScoreType.intimacy_family_total_rating_krjp] = {
    rank_type = rank_config.RankSelectEnum.family,
    period_type = rank_config.PeriodEnum.total,
    program_type = rank_config.ProgramVersionEnum.jpkr
  },
  [rank_config.ScoreType.intimacy_family_weekly_rating_krjp] = {
    rank_type = rank_config.RankSelectEnum.family,
    period_type = rank_config.PeriodEnum.week,
    program_type = rank_config.ProgramVersionEnum.jpkr
  },
  [rank_config.ScoreType.peakgame_rating] = {
    rank_type = rank_config.RankSelectEnum.peak
  },
  [rank_config.ScoreType.peakgame_kd_rating] = {
    rank_type = rank_config.RankSelectEnum.peakgame_kd
  },
  [rank_config.ScoreType.peakgame_solo_win_total_rating] = {
    rank_type = rank_config.RankSelectEnum.peakgame_win,
    period_type = rank_config.PeriodEnum.total,
    member_type = rank_config.MemberEnum.single
  },
  [rank_config.ScoreType.peakgame_multi_win_total_rating] = {
    rank_type = rank_config.RankSelectEnum.peakgame_win,
    period_type = rank_config.PeriodEnum.total,
    member_type = rank_config.MemberEnum.double
  },
  [rank_config.ScoreType.peakgame_squad_win_total_rating] = {
    rank_type = rank_config.RankSelectEnum.peakgame_win,
    period_type = rank_config.PeriodEnum.total,
    member_type = rank_config.MemberEnum.team
  },
  [rank_config.ScoreType.peakgame_solo_win_weekly_rating] = {
    rank_type = rank_config.RankSelectEnum.peakgame_win,
    period_type = rank_config.PeriodEnum.week,
    member_type = rank_config.MemberEnum.single
  },
  [rank_config.ScoreType.peakgame_multi_win_weekly_rating] = {
    rank_type = rank_config.RankSelectEnum.peakgame_win,
    period_type = rank_config.PeriodEnum.week,
    member_type = rank_config.MemberEnum.double
  },
  [rank_config.ScoreType.peakgame_squad_win_weekly_rating] = {
    rank_type = rank_config.RankSelectEnum.peakgame_win,
    period_type = rank_config.PeriodEnum.week,
    member_type = rank_config.MemberEnum.team
  },
  [rank_config.ScoreType.wow_author_level] = {
    rank_type = rank_config.RankSelectEnum.wow_author,
    planPH_type = rank_config.WoWAuthorEnum.level
  },
  [rank_config.ScoreType.wow_mod_popularity] = {
    rank_type = rank_config.RankSelectEnum.wow_author,
    planPH_type = rank_config.WoWAuthorEnum.popularity,
    period_type = rank_config.PeriodEnum.total
  },
  [rank_config.ScoreType.wow_mod_popularity_week] = {
    rank_type = rank_config.RankSelectEnum.wow_author,
    planPH_type = rank_config.WoWAuthorEnum.popularity,
    period_type = rank_config.PeriodEnum.week
  },
  [rank_config.ScoreType.wow_play_level] = {
    rank_type = rank_config.RankSelectEnum.wow_play_level
  },
  [rank_config.ScoreType.weapon_usage_score_rating] = {
    rank_type = rank_config.RankSelectEnum.weapon_usage_score
  }
}
rank_config.ContentSize = {
  totalShortWidth = 700,
  totalLongWidth = 870,
  rankWidth = 130,
  avatarWidth = 276,
  rewardWidth = 180
}
return rank_config