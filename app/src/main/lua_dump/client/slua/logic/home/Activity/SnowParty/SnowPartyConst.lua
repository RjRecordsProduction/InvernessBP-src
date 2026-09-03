local SnowPartyConst = {
  activityID = 1003,
  snowBallGameTimeLimit = 300,
  snowBallDefaultSize = 20,
  snowBallVehiclePath = "/Game/Library/Res/Hero/SnowBall/Art_Player/SnowBall/VH_SnowBall.VH_SnowBall",
  snowBallResetCD = 5,
  snowHeapGenerateDelay = 0,
  snowHeapGenerateInterval = 10,
  snowHeapGenerateNum = 10,
  snowHeapGenerateLimit = 30,
  snowManRankType = "snowManRankType",
  snowManRankID = 90007,
  snowManScaleLimt = 10.0,
  snowManTitleShowMaxDistance = 1600.0,
  snowManAcitivityID = 334246104,
  snowManAcitivityID_JK = 235001137,
  snowManRewardHeightLimit = 5,
  EExitGameReason = {
    PlayerExit = 1,
    PlayerDefeat = 2,
    Timeout = 3,
    Other = 4
  },
  ERetCode = {
    Success = 0,
    InvalidParams = 101,
    EnterGameFailed_AlreadyInGame = 201,
    EnterGameFailed_FailedToJoinGame = 202,
    EnterGameFailed_NotInActivityTime = 203,
    ExitGameFailed_NotInGame = 301
  },
  AudioList = {
    SizeIncrease = "/Game/Library/Res/Hero/SnowBall/WwiseEvent/Snow_350/Play_Snow_Snowball_Bigger.Play_Snow_Snowball_Bigger",
    SnowBallEat = "/Game/Library/Res/Hero/SnowBall/WwiseEvent/Snow_350/Play_Snow_Snowball_Eat.Play_Snow_Snowball_Eat",
    SnowBallBeEat = "/Game/Library/Res/Hero/SnowBall/WwiseEvent/Snow_350/Play_Snow_Snowball_UI_Fail.Play_Snow_Snowball_UI_Fail"
  }
}
SnowPartyConst.ErrorMsg = {
  [SnowPartyConst.ERetCode.Success] = 9054,
  [SnowPartyConst.ERetCode.InvalidParams] = 15010002,
  [SnowPartyConst.ERetCode.EnterGameFailed_AlreadyInGame] = 83607,
  [SnowPartyConst.ERetCode.EnterGameFailed_FailedToJoinGame] = 83606,
  [SnowPartyConst.ERetCode.EnterGameFailed_NotInActivityTime] = 4002,
  [SnowPartyConst.ERetCode.ExitGameFailed_NotInGame] = 83608
}
return SnowPartyConst