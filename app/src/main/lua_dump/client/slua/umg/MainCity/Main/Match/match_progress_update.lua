local match_progress_update = {
  curProgress = 1,
  white = FSlateColor(FLinearColor(1, 1, 1, 0.5)),
  yellow = FSlateColor(FLinearColor(0.693872, 0.14996, 0, 1)),
  black = FSlateColor(FLinearColor(0, 0, 0, 0.7)),
  MatchFontSize = 26,
  MatchSoonFontSize = 12
}
local initUpdateIndex = 99999
function match_progress_update.UpdateIncrementalArray()
  log(bWriteLog and "match_progress_update.UpdateIncrementalArray")
  local match = match_progress_update
  local MatchSystem = require("client.slua.logic.match.logic_match")
  local MaxIndex = MatchSystem.sync_interval
  if MaxIndex <= match.UpdateIndex then
    log(bWriteLog and "match_progress_update.UpdateIncrementalArray match.UpdateIndex > MaxIndex startNextRound")
    local isFirstTime = match.UpdateIndex == initUpdateIndex
    match.UpdateIndex = 0
    local LogicModeMatchProgress = require("client.slua.logic.mode_selection.LogicModeMatchProgress")
    match.ProgressIncrementalArray = LogicModeMatchProgress.SplitIncremental(match.curProgress, isFirstTime)
  end
end
function match_progress_update.ClearProgressInfo()
  local MatchSystem = require("client.slua.logic.match.logic_match")
  local match = match_progress_update
  match.ProgressIncrementalArray = nil
  match.curProgress = 1
  match.UpdateIndex = initUpdateIndex
  MatchSystem.ClearSyncMatchInfo()
end
function match_progress_update.GetProgress()
  log(bWriteLog and "match_progress_update.GetProgress")
  local match = match_progress_update
  local MatchSystem = require("client.slua.logic.match.logic_match")
  local matchingTime = MatchSystem.nMatchingTime
  local totalProgress = MatchSystem.nTotalProgress or 0
  local str = LocUtil.LocalizeResFormat(6830, match.curProgress, totalProgress)
  if match.OldMatchingTime == matchingTime then
    log(bWriteLog and "match_progress_update.GetProgress match.OldMatchingTime == matchingTime, process no change")
    return str
  end
  match.OldMatchingTime = matchingTime
  match.UpdateIncrementalArray()
  match.UpdateIndex = match.UpdateIndex + 1
  log_format(bWriteLog and "match_progress_update.GetProgress match.UpdateIndex = %s", match.UpdateIndex)
  if not match.ProgressIncrementalArray then
    log(bWriteLog and "match_progress_update.GetProgress match.ProgressIncrementalArray is nil, process no change")
    return str
  end
  local ProgressIncremental = match.ProgressIncrementalArray[match.UpdateIndex]
  if not ProgressIncremental then
    log(bWriteLog and "match_progress_update.GetProgress ProgressIncremental is nil")
    return str
  end
  match.curProgress = ProgressIncremental
  str = LocUtil.LocalizeResFormat(6830, match.curProgress, totalProgress)
  log_format(bWriteLog and "match_progress_update.GetProgress match.UpdateIndex = %s, new process = %s", match.UpdateIndex, str)
  return str
end
return match_progress_update