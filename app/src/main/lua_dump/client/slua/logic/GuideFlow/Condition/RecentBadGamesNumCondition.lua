local RecentBadGamesNumCondition = {}
function RecentBadGamesNumCondition.Check(conditionId, lastRound, minNum, maxNum)
  local GuideFlowLog = require("client.slua.logic.GuideFlow.GuideFlowLog")
  GuideFlowLog.log(GuideFlowLog.bLog and "RecentBadGamesNumCondition .Check lastRound = " .. lastRound .. ", minNum = " .. minNum .. ", maxNum = " .. maxNum)
  local FightRecordHandler = require("client.network.Protocol.FightRecordHandler")
  local records = FightRecordHandler.alive_records
  if records == nil then
    GuideFlowLog.log(GuideFlowLog.bLog and "RecentBadGamesNumCondition Check records == nil")
    return false
  end
  lastRound = tonumber(lastRound)
  local record_num = #records
  if lastRound > record_num then
    GuideFlowLog.log(GuideFlowLog.bLog and "RecentBadGamesNumCondition Check record_num < lastRound")
    return false
  end
  local DefaultGuideFlowMode = require("client.slua.logic.GuideFlow.DefaultGuideFlowMode")
  local roundNum = 0
  for i = record_num, record_num - lastRound + 1, -1 do
    local record = records[i]
    local t = record.survive_time
    local sub_mode = record.sub_mode
    local cfg = CDataTable.GetTableData("GuideFlowModeAliveTb", sub_mode)
    cfg = DefaultGuideFlowMode.CheckForDefault(cfg, sub_mode)
    if cfg then
      GuideFlowLog.log(GuideFlowLog.bLog and "RecentBadGamesNumCondition cfg: " .. tostring(cfg.minTime) .. ", " .. tostring(cfg.maxTime))
      if t >= cfg.minTime and t <= cfg.maxTime then
        roundNum = roundNum + 1
      end
    else
      GuideFlowLog.log(GuideFlowLog.bLog and "RecentBadGamesNumCondition Check sub_mode not exist " .. sub_mode)
    end
  end
  GuideFlowLog.log(GuideFlowLog.bLog and "RecentBadGamesNumCondition Check roundNum = " .. roundNum)
  if roundNum >= tonumber(minNum) and roundNum <= tonumber(maxNum) then
    return true
  else
    return false
  end
end
return RecentBadGamesNumCondition