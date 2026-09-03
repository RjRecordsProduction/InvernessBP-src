local PeakGameConfig = {
  DefaultPeakGameSegment = 1101,
  DefaultPeakGameRating = 1000,
  MinPeakGameSeasonId = 39,
  SeasonCoinId = 1702156,
  MaxSegmentID = 1570,
  MinSegmentID = 1101,
  MinScore = 1000,
  MaxIntegralType = 5,
  EnumPeakGameState = {
    NotInSeasonTime = 0,
    CannotPlayPeakGame = 1,
    NotInPeakGameStartTime = 2,
    CanPlayPeakGame = 3
  },
  EnumPeakGameAwardState = {
    CanNotTakeAward = 0,
    CanTakeAward = 1,
    HaveTakeAward = 2
  },
  EnumPeakGameHallRankTab = {Week = 1, Hof = 2},
  BattleType = {Squad = 11201},
  PeakGameModeMap = {
    [12001] = true,
    [12002] = true,
    [12004] = true
  },
  EnumSegmentShowType = {Rank = 1, PeakGame = 2},
  RewardType = {RankRewards = 1, SettlementReward = 2},
  LevelList = {
    [1] = 1101,
    [2] = 1201,
    [3] = 1301,
    [4] = 1401,
    [5] = 1501
  },
  Activity = {
    AllExtraPoints = 335010109,
    MiLExtraPoints = 335010110,
    NoPointsLost = 335010111
  },
  ActivityType = {AddScoreActivity = 250, NotScoreActivity = 249},
  ProtectCard = {
    PointsProtectionCard = 2210001,
    PeakGame20AddCardLast = 2208001,
    PeakGame10AddCardLast = 2208002,
    PeakGame20AddCard = 2208003,
    PeakGame10AddCard = 2208004
  },
  MainAddScoreTips = {
    AddScore10 = 2000021,
    AddScore20 = 2000022,
    NotLostScore = 2000004,
    NotLostActivity = 2000007,
    AddScoreActivity = 2000023
  },
  E_AddScoreTipsType = {
    PeakGameScoreProtected = 30,
    PeakGameRatingShieldCard = 31,
    PeakGameExtraPointMatch = 32,
    PeakGameDayNoPoints = 33,
    PeakGame10AddCard = 34,
    PeakGame20AddCard = 35
  },
  EGuideType = {
    PeakGameGuide = 1,
    SeasonYear = 2,
    Promotion = 3,
    Imprint = 4,
    NewbiePromotion = 5
  }
}
return PeakGameConfig