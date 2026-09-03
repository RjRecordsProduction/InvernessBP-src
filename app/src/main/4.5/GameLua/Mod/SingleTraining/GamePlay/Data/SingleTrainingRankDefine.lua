local SingleTrainingRankDefine = {
  Symbol = "single_training_rank",
  ETrainingType = {
    NormalShooting = 1,
    AI = 2,
    ThrowBomb = 3,
    ReactionShooting = 4
  },
  ERankID = {
    [1] = {
      [1] = 76001,
      [2] = 76002,
      [3] = 76003,
      [4] = 76004
    },
    [2] = {
      [1] = 76005,
      [2] = 76006,
      [3] = 76007,
      [4] = 76008
    },
    [3] = {
      [1] = 76009,
      [2] = 76010,
      [3] = 76011,
      [4] = 76012
    },
    [4] = {
      [1] = 76013,
      [2] = 76014,
      [3] = 76015,
      [4] = 76016
    }
  }
}
function SingleTrainingRankDefine:TypeToID(TrainingType, Level)
  local TrainingT = self.ERankID[TrainingType]
  if TrainingT == nil then
    print(bWriteLog and string.format("SingleTrainingRankDefine:TypeToID, Type:{%d}, Level:{%d}", TrainingType, Level))
    return nil
  end
  return TrainingT[Level]
end
function SingleTrainingRankDefine:IDToType(RankID)
  for TrainingType, Ranks in pairs(self.ERankID) do
    for Level, TargetID in pairs(Ranks) do
      if TargetID == RankID then
        return TrainingType, Level
      end
    end
  end
  return nil, nil
end
return SingleTrainingRankDefine