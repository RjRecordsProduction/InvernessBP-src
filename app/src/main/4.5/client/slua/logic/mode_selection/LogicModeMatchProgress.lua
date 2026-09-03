local LogicModeMatchProgress = {}
function LogicModeMatchProgress.CanShowHighLevelMatchTips()
  local MatchSystem = require("client.slua.logic.match.logic_match")
  local MatchingTime = MatchSystem.nMatchingTime
  local teamSegment = MatchSystem.team_rating
  local tipsLocID = 817284
  log_format(bWriteLog and "LogicModeMatchProgress.CanShowHighLevelMatchTips: MatchingTime:%s, teamSegment:%s", MatchingTime, teamSegment)
  if 60 < MatchingTime and 4200 < teamSegment then
    local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
    local filterInfo = logic_mode_selection:GetFilterInfo()
    local TeamNum = filterInfo.teamNum
    local needFourTeammates = TeamNum == 4
    local isFPP = tonumber(filterInfo.perspective) == 100054
    log_format(bWriteLog and "LogicModeMatchProgress.CanShowHighLevelMatchTips: TeamNum:%s, perspective:%s", TeamNum, logic_mode_selection.perspective)
    local matchMode = logic_mode_selection:GetCurSelectInfo()
    local IsClassicRankMode = logic_mode_selection:IsClassicRankMode(matchMode)
    local canShow = needFourTeammates and IsClassicRankMode and isFPP
    log_format(bWriteLog and "LogicModeMatchProgress.CanShowHighLevelMatchTips:  IsClassicRankMode:%s, isFPP:%s, needFourTeammates:%s", IsClassicRankMode, isFPP, needFourTeammates)
    return canShow, tipsLocID
  end
  return false, tipsLocID
end
function LogicModeMatchProgress.SplitIncremental(curPro, isFirstTime)
  log(bWriteLog and "SplitIncremental: curPro:", curPro)
  local MatchSystem = require("client.slua.logic.match.logic_match")
  local process_detail = MatchSystem.process_detail
  if process_detail and next(process_detail) then
    log(bWriteLog and "SplitIncremental: process_detail")
    local match_progress_update = require("client.slua.umg.MainCity.Main.Match.match_progress_update")
    if tostring(match_progress_update.ProgressIncrementalArray) == tostring(MatchSystem.process_detail) then
      log(bWriteLog and "match_progress_update.UpdateIncrementalArray clear old progress info")
      MatchSystem.process_detail = {}
    end
    return MatchSystem.process_detail
  end
  local actualPro = MatchSystem.nCurrentProgress or 0
  local MaxIndex = MatchSystem.sync_interval
  local MaxUpdatePerInternal = LogicModeMatchProgress.GetProgressMaxUpdatePerInternal(isFirstTime) or 1
  local diff = actualPro - curPro
  local negativeRate = diff < 0 and -1 or 1
  diff = math.abs(diff)
  local remainingIncrement = math.min(diff, MaxUpdatePerInternal)
  log_format(bWriteLog and "SplitIncremental: actualPro:%s, curPro:%s, remainingIncrement:%s", actualPro, curPro, remainingIncrement)
  local incrementArray = {}
  if remainingIncrement <= 0 then
    log(bWriteLog and "SplitIncremental: No increment needed")
    return
  end
  for i = 1, MaxIndex - 1 do
    if remainingIncrement < 1 then
      incrementArray[i] = incrementArray[i - 1] or curPro
    else
      local maxPossible = remainingIncrement - (MaxIndex - i)
      local min = math.min(maxPossible, 1)
      local max = math.max(maxPossible, 1)
      local increment = math.random(min, max)
      if increment < 0 then
        increment = 0
      end
      remainingIncrement = remainingIncrement - increment
      increment = negativeRate * increment
      local curProgress = incrementArray[i - 1] or curPro
      incrementArray[i] = increment + curProgress
    end
    log(bWriteLog and string.format("SplitIncremental1: incrementArray[%s]:%s", i, incrementArray[i]))
  end
  local lastPro = incrementArray[MaxIndex - 1] or curPro
  if remainingIncrement < 1 then
    incrementArray[MaxIndex] = lastPro
  else
    incrementArray[MaxIndex] = negativeRate * remainingIncrement + lastPro
  end
  log(bWriteLog and string.format("SplitIncremental1: incrementArray[%s]:%s", MaxIndex, incrementArray[MaxIndex]))
  return incrementArray
end
function LogicModeMatchProgress.GetProgressMaxUpdatePerInternal(isFirstTime)
  local MatchSystem = require("client.slua.logic.match.logic_match")
  local maxCount = MatchSystem.nTotalProgress or -1
  if maxCount < 0 then
    log(bWriteLog and "GetProgressMaxUpdatePerInternal: maxCount is negative")
    return
  end
  local cfg = {}
  if isFirstTime then
    cfg = CDataTable.GetTableData("MatchProgressParams", "MatchUpdateLimit_0")
  elseif 60 < maxCount then
    cfg = CDataTable.GetTableData("MatchProgressParams", "MatchUpdateLimit_100")
  else
    cfg = CDataTable.GetTableData("MatchProgressParams", "MatchUpdateLimit_50")
  end
  local value = cfg and cfg.value or 1
  log(bWriteLog and string.format("GetProgressMaxUpdatePerInternal: isFirstTime:%s, value:%f", isFirstTime, value))
  return value
end
return LogicModeMatchProgress