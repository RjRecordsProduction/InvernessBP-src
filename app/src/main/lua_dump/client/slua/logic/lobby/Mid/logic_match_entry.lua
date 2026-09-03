local LogicMatchEntry = {}
local MatchSystem = require("client.slua.logic.match.logic_match")
local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
local TeammateMatchNum = 0
local DisplayMatchTip = false
local DisplayWaitForMatch = false
local DisplayTeamMateMatch = false
local DisplayParachuteTactics = false
local DisplaySameLanguageMatch = false
function LogicMatchEntry.ResetDisplayState()
  DisplayMatchTip = false
  DisplayWaitForMatch = false
  DisplayTeamMateMatch = false
  DisplayParachuteTactics = false
  DisplaySameLanguageMatch = false
end
function LogicMatchEntry.IsShowWaitForMatch()
  return DisplayWaitForMatch
end
function LogicMatchEntry.IsShowMatchTip()
  return DisplayMatchTip
end
function LogicMatchEntry.IsShowTeammateMatch()
  return DisplayTeamMateMatch
end
function LogicMatchEntry.IsShowParachuteTactics()
  return DisplayParachuteTactics
end
function LogicMatchEntry.IsShowSameLanguageMatch()
  return DisplaySameLanguageMatch
end
function LogicMatchEntry.GetTeammateMatchNum()
  return TeammateMatchNum
end
function LogicMatchEntry.CalculateMatchDisplay()
  LogicMatchEntry.FigureSameLanguageMatch()
  LogicMatchEntry.FigureParachuteTactics()
  LogicMatchEntry.FigureMatchTip()
  LogicMatchEntry.FigureTeammateMatch()
end
function LogicMatchEntry.IsMatchingSocialIsland()
  if MatchModeMgrSystem.bIsMatchingSocialIsland and TeamUpNewSystem.GetTeamNum() == 1 then
    return true
  else
    return false
  end
end
function LogicMatchEntry.GetMatchLanguage()
  if TeamUpNewSystem.IsTeamLeader() then
    return DataMgr.MatchLanguage
  else
    return MatchSystem.matchLanguageData
  end
end
function LogicMatchEntry.FigureSameLanguageMatch()
  if LogicMatchEntry.IsMatchingSocialIsland() then
    return false
  end
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  if LogicUGCMatch:IsCreativeWoW() then
    return false
  end
  local MatchLanguage = LogicMatchEntry.GetMatchLanguage()
  if MatchLanguage then
    DisplaySameLanguageMatch = MatchLanguage.only_match and MatchModeMgrSystem.bAutoMatch
  end
  local playerNum = LogicMatchEntry.GetModeMaxTeamNum()
  if playerNum == 1 or playerNum == TeamUpNewSystem.GetTeamNum() or MatchModeMgrSystem.bIsMatchingTrainMode then
    DisplaySameLanguageMatch = false
  end
  log(bWriteLog and "[LogicMatchEntry] FigureSameLanguageMatch : " .. tostring(DisplaySameLanguageMatch))
  return DisplaySameLanguageMatch
end
function LogicMatchEntry.FigureParachuteTactics()
  if LogicMatchEntry.IsMatchingSocialIsland() then
    return false
  end
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  if LogicUGCMatch:IsCreativeWoW() then
    return false
  end
  if MatchSystem.IsMatchStrategyOpen() and DataMgr.MatchStrategy > 1 then
    DisplayParachuteTactics = true
  end
  log(bWriteLog and "[LogicMatchEntry] FigureParachuteTactics : " .. tostring(DisplayParachuteTactics))
  return DisplayParachuteTactics
end
function LogicMatchEntry.GetModeMaxTeamNum()
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local teamNum = 4
  local filterInfo = logic_mode_selection:GetFilterInfo()
  teamNum = filterInfo.teamNum
  return teamNum
end
function LogicMatchEntry.FigureTeammateMatch()
  if LogicMatchEntry.IsMatchingSocialIsland() then
    return false
  end
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  if LogicUGCMatch:IsCreativeWoW() then
    return false
  end
  local playerNum = LogicMatchEntry.GetModeMaxTeamNum()
  if playerNum ~= 1 and playerNum ~= TeamUpNewSystem.GetTeamNum() and MatchModeMgrSystem.bAutoMatch ~= false then
    TeammateMatchNum = TeamUpNewSystem.GetTeamNum()
    DisplayTeamMateMatch = true
  end
  log(bWriteLog and "[LogicMatchEntry] FigureTeammateMatch : " .. tostring(DisplayTeamMateMatch))
  return DisplayTeamMateMatch
end
function LogicMatchEntry.FigureMatchTip()
  if DisplaySameLanguageMatch or DisplayParachuteTactics then
    DisplayMatchTip = true
  else
    DisplayMatchTip = false
  end
  log(bWriteLog and "[LogicMatchEntry] FigureMatchTip : " .. tostring(DisplayMatchTip))
  return DisplayMatchTip
end
function LogicMatchEntry.FigureWaitForMatch()
  local waitLine = MatchSystem.waitLine
  if not (waitLine.nPos and waitLine.nSpeed) or waitLine.nPos <= 0 then
    DisplayWaitForMatch = false
  else
    DisplayWaitForMatch = true
  end
  log(bWriteLog and "[LogicMatchEntry] FigureWaitForMatch : " .. tostring(DisplayWaitForMatch))
  return DisplayWaitForMatch
end
function LogicMatchEntry.HasMatchInfoToDisplay()
  local HasMatchInfoToDisplay = false
  if DisplayMatchTip or DisplaySameLanguageMatch or DisplayParachuteTactics or DisplayTeamMateMatch then
    HasMatchInfoToDisplay = true
  else
    HasMatchInfoToDisplay = false
  end
  log(bWriteLog and "[LogicMatchEntry] HasMatchInfoToDisplay : " .. tostring(HasMatchInfoToDisplay))
  log(bWriteLog and string.format("LogicMatchEntry:HasMatchInfoToDisplay - DisplayMatchTip = %s, DisplaySameLanguageMatch = %s, DisplayParachuteTactics = %s, DisplayTeamMateMatch = %s", tostring(DisplayMatchTip), tostring(DisplaySameLanguageMatch), tostring(DisplayParachuteTactics), tostring(DisplayTeamMateMatch)))
  return HasMatchInfoToDisplay
end
function LogicMatchEntry.DummyTeammateMatchNum()
  local playerNum = LogicMatchEntry.GetModeMaxTeamNum()
  if not (DisplayTeamMateMatch and TeammateMatchNum) or not playerNum then
    return
  end
  local nEstimateTime = MatchSystem.nEstimateTime or 0
  if 0 < nEstimateTime then
    local teammateRatio = TeammateMatchNum / playerNum
    local elapsedTimeRatio = MatchSystem.nMatchingTime / MatchSystem.nEstimateTime
    if teammateRatio <= elapsedTimeRatio and playerNum > TeammateMatchNum then
      TeammateMatchNum = TeammateMatchNum + 1
    end
  elseif MatchSystem.is_sync_match_process then
    local matchTeammateNum = math.max(MatchSystem.teammate_cnt, TeammateMatchNum)
    log_format("[LogicMatchEntry] DummyTeammateMatchNum MatchSystem.teammate_cnt = %s, TeamNum = %s", MatchSystem.teammate_cnt, TeammateMatchNum)
    TeammateMatchNum = math.min(playerNum, matchTeammateNum)
  end
end
function LogicMatchEntry.GMSetFakeDisplayData()
  DisplayTeamMateMatch = true
  TeammateMatchNum = 2
  DisplaySameLanguageMatch = true
  DisplayMatchTip = true
  MatchSystem.waitLine = {nPos = 150, nSpeed = 10}
  DisplayWaitForMatch = true
  if not MatchSystem.matchLanguageData or not next(MatchSystem.matchLanguageData) then
    MatchSystem.matchLanguageData = {
      [1] = 1,
      [2] = 2,
      only_match = true
    }
  end
  MatchSystem.sameLanguageMatchTimeOut = false
  if not MatchSystem.nMatchingTime or MatchSystem.nMatchingTime <= 0 then
    MatchSystem.nMatchingTime = 120
  end
  if not MatchSystem.nEstimateTime or 0 >= MatchSystem.nEstimateTime then
    MatchSystem.nEstimateTime = 180
  end
  log(bWriteLog and "[LogicMatchEntry] GMSetFakeDisplayData: all display flags set to true")
end
return LogicMatchEntry