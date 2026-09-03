local BattleEvaluationCondition = {
  battleType = 0,
  score = 0,
  newScore = 0,
  lastBattleID = 0
}
function BattleEvaluationCondition.Check(conditionId, battleType, scoreRange)
  log(bWriteLog and "BattleEvaluationCondition.Check")
  local min, max = string.match(scoreRange, "(%d+)%s*|%s*(%d+)")
  min = tonumber(min)
  max = tonumber(max)
  local gameType = {
    [1] = {
      [101] = true,
      [102] = true,
      [103] = true,
      [401] = true,
      [402] = true,
      [403] = true
    },
    [2] = {
      [111] = true,
      [112] = true,
      [113] = true,
      [411] = true,
      [412] = true,
      [413] = true
    }
  }
  battleType = battleType or 0
  if not BattleEvaluationCondition.score then
    BattleEvaluationCondition.score = -1
  end
  if battleType ~= 1 or battleType ~= 2 then
    battleType = 1
  end
  log(bWriteLog and "BattleEvaluationCondition.Check battleType" .. battleType .. "score" .. BattleEvaluationCondition.score)
  if gameType[battleType][BattleEvaluationCondition.battleType] and min <= BattleEvaluationCondition.score and max >= BattleEvaluationCondition.score then
    return true
  else
    return false
  end
end
function BattleEvaluationCondition.SetBattleType(battleType)
  if battleType == nil then
    battleType = 0
  end
  log(bWriteLog and "ruikkSetBattleType" .. battleType)
  BattleEvaluationCondition.end
function BattleEvaluationCondition.SetScore(score)
  if not BattleEvaluationCondition.score then
    BattleEvaluationCondition.score = -1
  end
  log(bWriteLog and "BattleEvaluationCondition.SetScore" .. score)
  BattleEvaluationCondition.end
function BattleEvaluationCondition.SetNewScore(newScore)
  if not BattleEvaluationCondition.newScore then
    BattleEvaluationCondition.newScore = -1
  end
  log(bWriteLog and "BattleEvaluationCondition.SetNewScore" .. newScore)
  BattleEvaluationCondition.end
function BattleEvaluationCondition.SetLastBattleID(lastBattleID)
  log(bWriteLog and "BattleEvaluationCondition.SetlastBattleID" .. lastBattleID)
  BattleEvaluationCondition.end
function BattleEvaluationCondition.GetData()
  local data = {}
  data.battleType = BattleEvaluationCondition.battleType
  data.score = BattleEvaluationCondition.score
  return data
end
function BattleEvaluationCondition.IsRankingType()
  local gameType = {
    [1] = {
      [101] = true,
      [102] = true,
      [103] = true,
      [401] = true,
      [402] = true,
      [403] = true
    },
    [2] = {
      [111] = true,
      [112] = true,
      [113] = true,
      [411] = true,
      [412] = true,
      [413] = true
    }
  }
  if gameType[1][BattleEvaluationCondition.battleType] then
    return true
  else
    return false
  end
end
function BattleEvaluationCondition.IsMatchingType()
  local gameType = {
    [1] = {
      [101] = true,
      [102] = true,
      [103] = true,
      [401] = true,
      [402] = true,
      [403] = true
    },
    [2] = {
      [111] = true,
      [112] = true,
      [113] = true,
      [411] = true,
      [412] = true,
      [413] = true
    }
  }
  if gameType[2][BattleEvaluationCondition.battleType] then
    return true
  else
    return false
  end
end
return BattleEvaluationCondition