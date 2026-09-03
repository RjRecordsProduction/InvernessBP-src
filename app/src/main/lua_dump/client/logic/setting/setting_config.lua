local SettingMacro = require("client.slua.logic.setting.setting_macro")
local NDoubleHHeight = SettingMacro.NDoubleHHeight
local SettingCfg = {
  OverLay = {
    itemType = SettingMacro.EItemType.OverLay
  },
  TitleFire = {
    itemType = SettingMacro.EItemType.Title,
    localRes = 25392
  },
  LeftHandFire = {
    itemType = SettingMacro.EItemType.Treble,
    localRes = {
      33157,
      33210,
      33223,
      6402
    }
  },
  SingleShotWeaponShootMode = {
    itemType = SettingMacro.EItemType.DoubleVWord,
    localRes = {
      4368,
      4369,
      4370
    },
    isNormal = true
  },
  ShotGunShootMode = {
    itemType = SettingMacro.EItemType.DoubleVWord,
    localRes = {
      4371,
      4369,
      4370
    },
    isNormal = true
  },
  TitleTimes = {
    itemType = SettingMacro.EItemType.Title,
    localRes = 25245
  },
  OpenMirrorMode = {
    itemType = SettingMacro.EItemType.Treble,
    localRes = {
      33160,
      33215,
      33216,
      33217
    },
    needHelp = 10272,
    isNormal = true
  },
  RotateViewWithSniperSwitch = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 33161,
    isNormal = true,
    needHelp = 116031
  },
  QuasiMirrorSwitch = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 33162,
    isNormal = true
  },
  SideMirrorMode = {
    itemType = SettingMacro.EItemType.DoubleVWord,
    localRes = {
      33163,
      33220,
      33221
    },
    isNormal = true
  },
  FocalLengthModifySwitch = {
    itemType = SettingMacro.EItemType.DoubleVWord,
    localRes = {
      33164,
      33215,
      33216
    }
  },
  TitleShootProbe = {
    itemType = SettingMacro.EItemType.Title,
    localRes = 25247
  },
  LeftRightShoot = {
    itemType = SettingMacro.EItemType.DoubleParent,
    localRes = 25248,
    subItems = {
      "SidewaysMode",
      "LRShootSniperSwitch",
      "RotateViewWithPeekSwitch"
    },
    nRecommendIndex = 1,
    isNormal = true
  },
  SidewaysMode = {
    itemType = SettingMacro.EItemType.Treble,
    localRes = {
      33166,
      33215,
      33216,
      33217
    },
    needHelp = 10271,
    isNormal = true
  },
  LRShootSniperSwitch = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 33167,
    isNormal = true
  },
  RotateViewWithPeekSwitch = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 33168,
    isNormal = true,
    needHelp = 116030
  },
  bCanIntelligentSign = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 67368,
    isNormal = true,
    needHelp = 67369
  },
  TitleFeature = {
    itemType = SettingMacro.EItemType.Title,
    localRes = 25251
  },
  UniversalSignSwitch = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 33169,
    isNormal = true,
    needHelp = 8726
  },
  bCloseHitHeadAudio = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 33170
  },
  HitBodyAudio = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 612401075
  },
  KnockOutAudio = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 612401076
  },
  bSeperateShootMBtn = {
    itemType = SettingMacro.EItemType.DoubleVWord,
    localRes = {
      83251,
      37267,
      37266
    },
    needHelp = 83252
  },
  VaultBtnSwitch = {
    itemType = SettingMacro.EItemType.DoubleVWord,
    localRes = {
      33171,
      37267,
      37266
    },
    isNormal = true
  },
  OneKeyProneAndCrouchSwitch = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 33172,
    isNormal = true,
    needHelp = 24946
  },
  RingThrowSwitch = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 33173,
    isNormal = true,
    needHelp = true
  },
  RingThrowPressSwitch = {
    itemType = SettingMacro.EItemType.DoubleVWord,
    localRes = {
      33174,
      9834,
      18373
    },
    isNormal = true,
    needHelp = true
  },
  bConsumeThrow = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 33177,
    isNormal = true,
    needHelp = true
  },
  bHideIngameUIAvailable = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 33178,
    isNormal = true,
    needHelp = true
  },
  OldMarkStyle = {
    itemType = SettingMacro.EItemType.DoubleVWord,
    localRes = {
      32994,
      32995,
      32996
    },
    isNormal = true,
    needHelp = true,
    nRecommendIndex = 2
  },
  bSpectatingPetVisible = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 49272,
    isNormal = true
  },
  bOtherPlayingWeapon = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 44728,
    isNormal = true
  },
  ShovelSwitch = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 8700099,
    isNormal = true
  },
  FpViewSwitch = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 33180,
    isNormal = true,
    needHelp = 10270
  },
  DynamicHoldGun = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 33181,
    isNormal = true,
    needHelp = 116036
  },
  TpViewValue = {
    itemType = SettingMacro.EItemType.Slider2Btn,
    max = 90,
    min = 80,
    localRes = 33182,
    bIsPercent = false
  },
  JoystickSprintSensitity = {
    itemType = SettingMacro.EItemType.Slider2Btn,
    max = 100,
    min = 0,
    localRes = 33183,
    needHelp = 25239
  },
  FpViewValue = {
    itemType = SettingMacro.EItemType.Slider2Btn,
    max = 103,
    min = 80,
    localRes = 33184,
    bIsPercent = false
  },
  PeekToSprintSwitch = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 77836,
    isNormal = true,
    needHelp = 77837
  },
  TitleAimAssist = {
    itemType = SettingMacro.EItemType.Title,
    localRes = 25254
  },
  AimAssist = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 33185,
    isNormal = true
  },
  SoundVisualizationType = {
    itemType = SettingMacro.EItemType.Treble,
    localRes = {
      33186,
      46208,
      46209,
      100048
    },
    needHelp = true,
    isNormal = true
  },
  AutoHitMark = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 33187,
    isNormal = true,
    needHelp = 29410,
    nRecommendIndex = 1
  },
  IntelligentDrugs = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 33188,
    isNormal = true
  },
  Weapon_LowAmmo = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 86798,
    isNormal = true,
    needHelp = 86799,
    nRecommendIndex = 1
  },
  GromeLinkOpen = {
    itemType = SettingMacro.EItemType.DoubleH,
    localRes = 86035,
    isNormal = true,
    needHelp = 86036
  },
  AutoContinueHeal = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 33189,
    isNormal = true
  },
  AutoOpenDoor = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 33190,
    isNormal = true
  },
  WallFeedBack = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 33191,
    isNormal = true
  },
  UseDisOrSpeedMove = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 32732,
    isNormal = true,
    needHelp = 32733
  },
  GrenadeSettingPredictLine = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 48375,
    isNormal = true,
    needHelp = 48376
  },
  AutoEquipMelleeWeapon = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 48661,
    isNormal = true,
    needHelp = 48662
  },
  OpenSilentChat = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 43352,
    isNormal = true,
    needHelp = 44440
  },
  AmmoRemain = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 34154,
    isNormal = true,
    needHelp = 37270
  },
  AutoParachute = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 33175,
    isNormal = true
  },
  MapMarkEnable = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 33176,
    isNormal = true,
    needHelp = 65040
  },
  AutoFollowJump = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 30172,
    needHelp = 30178
  },
  ParachuteJumpPathMark = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 791155,
    needHelp = 791156
  },
  TitleGyroscope = {
    itemType = SettingMacro.EItemType.Title,
    localRes = 10971
  },
  Gyroscope = {
    itemType = SettingMacro.EItemType.TrebleParent,
    localRes = {
      10971,
      33210,
      33223,
      39267
    },
    subItems = {
      "GyroReverse",
      "HoldGrenadeStateEnableGyro"
    },
    SuggestionLocalizationID = 66315
  },
  GyroReverse = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 21108,
    needHelp = 21109,
    isNormal = true
  },
  HoldGrenadeStateEnableGyro = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 612401099,
    needHelp = 612401100,
    isNormal = true,
    RefreshFunc = "RefreshHoldGrenadeStateEnableGyro"
  },
  TitleShoulder = {
    itemType = SettingMacro.EItemType.Title,
    localRes = 210041
  },
  ShoulderEnable = {
    itemType = SettingMacro.EItemType.DoubleParent,
    localRes = 210042,
    subItems = {
      "ShoulderMode",
      "RotateViewWithShoulderSwitch"
    },
    needHelp = 49236
  },
  ShoulderMode = {
    itemType = SettingMacro.EItemType.Treble,
    localRes = {
      210041,
      33215,
      33216,
      33217
    },
    needHelp = 210046,
    isNormal = true
  },
  RotateViewWithShoulderSwitch = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 210043,
    needHelp = 210047,
    isNormal = true
  },
  TitleRecording = {
    itemType = SettingMacro.EItemType.Title,
    localRes = 27730
  },
  bRecordWonderfulReplayOpen = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 24503,
    needHelp = 24659
  },
  DeathPlaybackSwitch = {
    itemType = SettingMacro.EItemType.DoubleV,
    needHelp = 9122,
    localRes = 9173,
    isNormal = true
  },
  bUserSaveWonderfulReplaySwitch = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 8700085,
    needHelp = 8700086
  },
  LowTickRateInSpectating = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 1050301,
    needHelp = 1050302
  },
  BattleNewSwitch = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 25398,
    needHelp = 25156
  },
  AutoUseMelee = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 62921,
    isNormal = true,
    needHelp = 62922
  },
  InterruptReloadType = {
    itemType = SettingMacro.EItemType.Treble,
    localRes = {
      62936,
      62937,
      62938,
      62939
    },
    needHelp = 62940
  },
  DefaultMeleeWeaponType = {
    itemType = SettingMacro.EItemType.DoubleVWord,
    localRes = {
      64650,
      18734,
      64649
    },
    needHelp = 64651
  },
  ShowMapGunLine = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 11603,
    isNormal = true,
    needHelp = 11604
  },
  TitleMetroFashionShow = {
    itemType = SettingMacro.EItemType.Title,
    localRes = 774823
  },
  MetroFashionLobbySwitcher = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 774824,
    needHelp = 774826
  },
  MetroFashionGameSwitcher = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 774825,
    needHelp = 774826
  },
  DrivingViewMode = {
    itemType = SettingMacro.EItemType.DoubleVWord,
    localRes = {
      78541,
      99009927,
      99009926
    },
    needHelp = 11482,
    isNormal = true
  },
  CarMusicSwitch = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 78542,
    isNormal = true
  },
  CarPreciseChangeSeat = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 78543,
    isNormal = true
  },
  DriftMode = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 876160
  },
  bMotorGliderFlipJoystick = {
    itemType = SettingMacro.EItemType.DoubleSlim,
    localRes = 78050,
    needHelp = 78051
  },
  bAvoidObstacle = {
    itemType = SettingMacro.EItemType.DoubleSlim,
    localRes = 75403,
    needHelp = 76922
  },
  bJumpOverObstacle = {
    itemType = SettingMacro.EItemType.DoubleSlim,
    localRes = 75404,
    needHelp = 76921
  },
  TransformerAudioSwitch = {
    itemType = SettingMacro.EItemType.DoubleSlim,
    localRes = 792588,
    needHelp = 792589
  },
  AutoPickupSwitcher = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 69624
  },
  AutoPickupSwitcherCombo = {
    itemType = SettingMacro.EItemType.Treble,
    localRes = {
      69624,
      6401,
      6402,
      67872
    },
    needHelp = 10255
  },
  AutoPickUpLevel3Backpack = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 69625,
    isNormal = true
  },
  AutoPickUpPistol = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 69626,
    isNormal = true
  },
  AutoPickMirror = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 69627,
    isNormal = true
  },
  AutoPickUpSideSight = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 69628,
    isNormal = true
  },
  DisableAutoPickDropMirror = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 69629,
    needHelp = 21146,
    isNormal = true
  },
  DisableAutoPickupSwitcher = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 69630,
    isNormal = true
  },
  AutoPickClipType = {
    itemType = SettingMacro.EItemType.Treble,
    localRes = {
      69631,
      69634,
      69635,
      69636
    }
  },
  AutoPickMeleeType = {
    itemType = SettingMacro.EItemType.Treble,
    localRes = {
      69632,
      8340468,
      64649,
      18734
    },
    isNormal = true
  },
  bDropUnusefulMelee = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 69633,
    needHelp = 45674,
    nRecommendIndex = 1,
    isNormal = true
  },
  AutoEquipAim = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 69647,
    isNormal = true
  },
  TitleSocial = {
    itemType = SettingMacro.EItemType.Title,
    localRes = 25256
  },
  UseIngameLike = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 33130,
    isNormal = true
  },
  ActorAnimationSwitch = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 33131,
    isNormal = true
  },
  IslandBroadCast = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 33132,
    isNormal = true
  },
  OpenOthersPet = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 33133,
    isNormal = true
  },
  OpenMyPetFPP = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 33134,
    isNormal = true
  },
  OpenMyPet = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 33135,
    isNormal = true
  },
  OpenPetSound = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 62958,
    isNormal = true
  },
  DoubleAllowRecommendedFriend = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 8889
  },
  OpenMotivation = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 37072,
    isNormal = true
  },
  bCanMapLongPress = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 44588,
    isNormal = true
  },
  TitlePrivacy = {
    itemType = SettingMacro.EItemType.Title,
    localRes = 25257
  },
  DoubleCanShowHistory = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 33136
  },
  DoubleCanShowRole = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 33137
  },
  DoubleCanShowPopularity = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 33138
  },
  DoubleCanShowPlayDay = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 33139
  },
  DoubleEvaluation = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 33140
  },
  DoublePublicCareer = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 33141
  },
  DoubleNotFriendInvite = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 31057
  },
  DoubleWatchingOpen = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 33292
  },
  DoubleIntimacyHint = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 44137,
    isNormal = true
  },
  DoublePeakGameHideId = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 68649,
    needHelp = 68650
  },
  DoubleReserve = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 44046
  },
  CollectionHallVisit = {
    itemType = SettingMacro.EItemType.TrebleParent,
    localRes = {
      880060080,
      773319,
      773318,
      773320
    }
  },
  Relation = {
    itemType = SettingMacro.EItemType.DoubleParent,
    localRes = 33144,
    needHelp = 77122,
    subItems = {
      "RelationLove",
      "RelationGay",
      "RelationBuddies",
      "RelationSisters",
      "RelationFamily"
    }
  },
  DoublePopularGiftPK = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 45954
  },
  DoubleSouvenirs = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 49146
  },
  RelationLove = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 8075914
  },
  RelationGay = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 33146
  },
  RelationBuddies = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 33147
  },
  RelationSisters = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 33148
  },
  RelationFamily = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 73243
  },
  ProfileShow = {
    itemType = SettingMacro.EItemType.DoubleParent,
    localRes = 47373,
    subItems = {
      "ProfileShowFight",
      "ProfileShowSocial"
    }
  },
  ProfileShowFight = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 47374
  },
  ProfileShowSocial = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 47375
  },
  TeammateTakeOver = {
    itemType = SettingMacro.EItemType.DoubleV,
    height = 90,
    localRes = 86035,
    needHelp = 86036
  },
  RelationShowOrder = {
    itemType = SettingMacro.EItemType.OneChoose,
    height = 90
  },
  bCanShowUnknownPass = {
    itemType = SettingMacro.EItemType.DoubleParent,
    localRes = 33149,
    subItems = {
      "bUnknownPassRecordShow",
      "bUnknownPassBattleShow"
    }
  },
  bUnknownPassRecordShow = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 33150
  },
  bUnknownPassBattleShow = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 33151
  },
  DoubleShowSubscribeBadge = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 62900
  },
  DoubleAllowFriendIsland = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 33152
  },
  DoubleAllowStrangerIsland = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 33153
  },
  SocialIslandCanAcceptDuel = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 33154,
    isNormal = true
  },
  DoubleOfflineInvite = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 33290
  },
  DoubleGlobalInvite = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 38708
  },
  DoublePokeInvite = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 73607
  },
  DoubleHideVisitRecord = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 43197
  },
  DoubleCanShowPround = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 43257
  },
  bLbsMain = {
    itemType = SettingMacro.EItemType.DoubleParentWithChoose,
    localRes = 24568,
    subItems = {
      "bLBSNear",
      "bLbsChat",
      "bLBSWarZone",
      "bLBSPlace"
    }
  },
  bLBSNear = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 24565
  },
  bLbsChat = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 24566
  },
  bLBSWarZone = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 24567
  },
  bLBSPlace = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 39033
  },
  DoubleTeamRecommend = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 39190
  },
  DoubleAllowChatHorn = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 33155
  },
  DoubleAllowFriendSeason = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 33156
  },
  DoubleAllowPush = {
    itemType = SettingMacro.EItemType.DoubleH,
    localRes = 33291,
    height = NDoubleHHeight
  },
  DoubleAllowPushNight = {
    itemType = SettingMacro.EItemType.DoubleH,
    localRes = 33288,
    height = NDoubleHHeight
  },
  DoubleTimeDisplay = {
    itemType = SettingMacro.EItemType.DoubleHWord,
    localRes = 25262,
    wordRes = 24612,
    height = NDoubleHHeight
  },
  DoubleMatchServer = {
    itemType = SettingMacro.EItemType.DoubleH,
    localRes = 33293,
    height = NDoubleHHeight
  },
  ShowBirthdaySwitch = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 38673
  },
  ShowGenderSwitch = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 43258
  },
  DoubleSeasonLookBackShow = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 512144
  },
  WoWShow = {
    itemType = SettingMacro.EItemType.DoubleParent,
    localRes = 67750,
    subItems = {
      "WoWPlay",
      "WoWCollectMod",
      "WoWLikeAuthor",
      "WoWHeadShwo",
      "WoWModCollectionShow",
      "WoWPassDisplay"
    }
  },
  WoWPlay = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 67751
  },
  WoWCollectMod = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 67752
  },
  WoWLikeAuthor = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 67753
  },
  WoWHeadShwo = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 69350
  },
  WoWModCollectionShow = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 77910
  },
  WoWPassDisplay = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 1050125
  },
  WoWCopilotDisplay = {
    itemType = SettingMacro.EItemType.DoubleParent,
    localRes = 97000020
  },
  ShowMiniTvInFighting = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 89947
  },
  ShowOtherMiniTvInFighting = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 89948
  },
  DoubleShowCollectLevel = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 48248
  },
  DoubleStrangerCDetail = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 48249
  },
  DoubleFriendCDetail = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 48250
  },
  DoubleShowChatRoom = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 62376
  },
  MainCitySocial = {
    itemType = SettingMacro.EItemType.Title,
    localRes = 73339
  },
  EnterMainCity = {
    itemType = SettingMacro.EItemType.DoubleVWord,
    localRes = {
      73328,
      73329,
      73330
    }
  },
  MainCityNoInteract_Stranger = {
    itemType = SettingMacro.EItemType.DoubleVWord,
    localRes = {
      656072,
      6402,
      6401
    }
  },
  MainCityNoInteract_Friend = {
    itemType = SettingMacro.EItemType.DoubleVWord,
    localRes = {
      656073,
      6402,
      6401
    }
  },
  QuickEnterMainCity = {
    itemType = SettingMacro.EItemType.DoubleVWord,
    localRes = {
      656183,
      6402,
      6401
    }
  },
  DoubleFlashMatchTeamRecommend = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 817034
  },
  DoubleFlashMatchTeamInsidePreTeamInvite = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 817035
  },
  DoubleFriendInviteJoinFlashMatchTeam = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 817036
  },
  DoubleOpenPreTeamIsLeader = {
    itemType = SettingMacro.EItemType.DoubleV,
    localRes = 817037
  }
}
SettingCfg.SettingOnlfFrinedConfig = {
  DoubleCanShowHistory = {
    itemType = SettingMacro.EItemType.Treble,
    localRes = {
      33136,
      773319,
      773318,
      773320
    }
  },
  DoubleCanShowPopularity = {
    itemType = SettingMacro.EItemType.Treble,
    localRes = {
      33138,
      773319,
      773318,
      773320
    }
  },
  DoubleEvaluation = {
    itemType = SettingMacro.EItemType.Treble,
    localRes = {
      33140,
      773319,
      773318,
      773320
    }
  },
  DoubleCanShowPround = {
    itemType = SettingMacro.EItemType.Treble,
    localRes = {
      43257,
      773319,
      773318,
      773320
    }
  },
  DoublePopularGiftPK = {
    itemType = SettingMacro.EItemType.Treble,
    localRes = {
      45954,
      773319,
      773318,
      773320
    }
  },
  DoubleCanShowRole = {
    itemType = SettingMacro.EItemType.Treble,
    localRes = {
      33137,
      773319,
      773318,
      773320
    }
  },
  ShowBirthdaySwitch = {
    itemType = SettingMacro.EItemType.Treble,
    localRes = {
      38673,
      773319,
      773318,
      773320
    }
  },
  Relation = {
    itemType = SettingMacro.EItemType.TrebleParent,
    localRes = {
      33144,
      773319,
      773318,
      773320
    },
    needHelp = 77122,
    subItems = {
      "RelationLove",
      "RelationGay",
      "RelationBuddies",
      "RelationSisters",
      "RelationFamily"
    }
  }
}
return SettingCfg