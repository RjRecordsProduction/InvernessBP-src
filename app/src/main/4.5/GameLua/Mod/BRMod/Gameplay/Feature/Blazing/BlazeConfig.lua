local BlazeConfig = {
  BLAZE_SCORE_THRESHOLD = 100,
  BLAZE_SCORE_FADEOUT_THRESHOLD = 60,
  BLAZE_SCORE_VISUAL_FULL_THRESHOLD = 80,
  SCORE_KNOCKDOWN = 20,
  SCORE_ELIMINATE = 10,
  SCORE_DOUBLE_KILL_BONUS = 10,
  SCORE_TRIPLE_KILL_BONUS = 20,
  SCORE_TEAM_KILL_BONUS = 30,
  ComboTimeWindow = 15,
  GraceKeepTime = 60,
  GraceFadeKeepTime = 15,
  GraceFadeScorePerSecond = 2,
  NormalKeepTime = 15,
  NormalFadeScorePerSecond = 1,
  EBlazeState = {
    None = 0,
    Active = 1,
    FadeOut = 2
  },
  ActiveModType = {
    [101] = true,
    [102] = true,
    [103] = true,
    [401] = true,
    [402] = true,
    [403] = true,
    [111] = true,
    [112] = true,
    [113] = true,
    [411] = true,
    [412] = true,
    [413] = true
  }
}
return BlazeConfig