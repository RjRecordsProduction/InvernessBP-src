local LogicTeamUpLimit = {
  minSegmentId = 0,
  maxSegmentId = 0,
  isDataInit = false,
  allModeSegmentLimit = nil,
  userSquardLimit = nil,
  teamLimitData = nil
}
local E_PerspectiveType = ENUM_PerspectiveType
LogicTeamUpLimit.enum_SegmentType = {
  solo = 101,
  double = 102,
  team = 103,
  fpp_solo = 401,
  fpp_double = 402,
  fpp_team = 403
}
LogicTeamUpLimit.enum_SelfSquardLimitType = {tpp = 1, fpp = 2}
function LogicTeamUpLimit.OnLogin()
end
function LogicTeamUpLimit.send_get_pre_team_limit_req(is_squad)
  if LobbySystem.CheckOpen(BP_ENUM_TEAM_UP_LIMIT_SWITCH) then
    local TeamupHandler = require("client.network.Protocol.TeamupHandler")
    TeamupHandler.send_get_pre_team_limit_req(is_squad)
  end
end
function LogicTeamUpLimit.on_get_pre_team_limit_rsp(min_seg_id, max_seg_id)
  LogicTeamUpLimit.isDataInit = true
  LogicTeamUpLimit.minSegmentId = min_seg_id or 0
  LogicTeamUpLimit.maxSegmentId = max_seg_id or 0
  EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_SEGMENT_LIMIT_CHANGE)
end
function LogicTeamUpLimit.send_get_all_pre_team_limit_req()
  if LobbySystem.CheckOpen(BP_ENUM_TEAM_UP_LIMIT_SWITCH) then
    local TeamupHandler = require("client.network.Protocol.TeamupHandler")
    TeamupHandler.send_get_all_pre_team_limit_req()
  end
end
function LogicTeamUpLimit.on_get_all_pre_team_limit_rsp(segment_tabs)
  LogicTeamUpLimit.allModeSegmentLimit = segment_tabs
  EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_ALL_MODE_TEAMUP_SEGMENT_LIMIT_DATA)
end
function LogicTeamUpLimit.send_get_single_squad_pre_team_limit_req()
  if LobbySystem.CheckOpen(BP_ENUM_TEAM_UP_LIMIT_SWITCH) then
    local TeamupHandler = require("client.network.Protocol.TeamupHandler")
    TeamupHandler.send_get_all_pre_team_limit_req()
  end
end
function LogicTeamUpLimit.on_get_single_squad_pre_team_limit_rsp(segment_tabs)
  if segment_tabs ~= nil then
    LogicTeamUpLimit.userSquardLimit = segment_tabs
  end
end
function LogicTeamUpLimit.send_get_pre_team_limit_info_req()
  if LobbySystem.CheckOpen(BP_ENUM_TEAM_UP_LIMIT_SWITCH) then
    local TeamupHandler = require("client.network.Protocol.TeamupHandler")
    TeamupHandler.send_get_pre_team_limit_info_req()
  end
end
function LogicTeamUpLimit.on_get_pre_team_limit_info_rsp(team_segment_limit_info)
  if not LobbySystem.CheckOpen(BP_ENUM_TEAM_UP_LIMIT_SWITCH) then
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if not TeamUpNewSystem.IsTeamLeader() then
    return
  end
  if team_segment_limit_info == nil or team_segment_limit_info.uid_list == nil or team_segment_limit_info.leader_seg == nil then
    log(bWriteLog and "on_get_pre_team_limit_info_rsp team_segment_limit_info is nil")
    return
  end
  log(bWriteLog and "on_get_pre_team_limit_info_rsp ShowUI")
end
function LogicTeamUpLimit.CheckSegmentCanTeamUp(segment)
  if not LobbySystem.CheckOpen(BP_ENUM_TEAM_UP_LIMIT_SWITCH) then
    return true
  end
  if segment == nil then
    log_error(bWriteLog and " LogicTeamUpLimit.CheckSegmentCanTeamUp Segment is nil")
    return true
  end
  log(bWriteLog and "CheckSegmentCanTeamUp: segment = " .. tostring(segment) .. ", minSegmentId = " .. tostring(LogicTeamUpLimit.minSegmentId) .. ", maxSegmentId = " .. tostring(LogicTeamUpLimit.maxSegmentId))
  if LogicTeamUpLimit.minSegmentId == 0 and LogicTeamUpLimit.maxSegmentId == 0 then
    return true
  end
  return segment >= LogicTeamUpLimit.minSegmentId and segment <= LogicTeamUpLimit.maxSegmentId
end
function LogicTeamUpLimit.GetSegmentLimitRange()
  if not LobbySystem.CheckOpen(BP_ENUM_TEAM_UP_LIMIT_SWITCH) then
    return 0, 0
  end
  return LogicTeamUpLimit.minSegmentId, LogicTeamUpLimit.maxSegmentId
end
function LogicTeamUpLimit.GetSegmentTypeNewLimitRange()
  if not LobbySystem.CheckOpen(BP_ENUM_TEAM_UP_LIMIT_SWITCH) then
    return 0, 0
  end
  if LogicTeamUpLimit.minSegmentId == 0 and LogicTeamUpLimit.maxSegmentId == 0 then
    return 0, 0
  end
  if LogicTeamUpLimit.minSegmentId == -1 and LogicTeamUpLimit.maxSegmentId == -1 then
    return -1, -1
  end
  local minSegCfg = FuncUtil.GetRankTableData(LogicTeamUpLimit.minSegmentId)
  local maxSegCfg = FuncUtil.GetRankTableData(LogicTeamUpLimit.maxSegmentId)
  if minSegCfg == nil or maxSegCfg == nil then
    return 0, 0
  end
  return minSegCfg.IntegralTypeNew, maxSegCfg.IntegralTypeNew
end
function LogicTeamUpLimit.GetSpecifiedModeSegmentLimit(nPerspective, nPlayerNum)
  if not LobbySystem.CheckOpen(BP_ENUM_TEAM_UP_LIMIT_SWITCH) then
    return 0, 0
  end
  if nPerspective == nil or nPlayerNum == nil or LogicTeamUpLimit.allModeSegmentLimit == nil or next(LogicTeamUpLimit.allModeSegmentLimit) == nil then
    return 0, 0
  end
  if nPerspective == E_PerspectiveType.FPP then
    if nPlayerNum == 4 then
      local segLimit = LogicTeamUpLimit.allModeSegmentLimit[LogicTeamUpLimit.enum_SegmentType.fpp_team] or {}
      return segLimit.min_segment_id or 0, segLimit.max_segment_id or 0
    end
    if nPlayerNum == 2 then
      local segLimit = LogicTeamUpLimit.allModeSegmentLimit[LogicTeamUpLimit.enum_SegmentType.fpp_double] or {}
      return segLimit.min_segment_id or 0, segLimit.max_segment_id or 0
    end
  else
    if nPlayerNum == 4 then
      local segLimit = LogicTeamUpLimit.allModeSegmentLimit[LogicTeamUpLimit.enum_SegmentType.team] or {}
      return segLimit.min_segment_id or 0, segLimit.max_segment_id or 0
    end
    if nPlayerNum == 2 then
      local segLimit = LogicTeamUpLimit.allModeSegmentLimit[LogicTeamUpLimit.enum_SegmentType.double] or {}
      return segLimit.min_segment_id or 0, segLimit.max_segment_id or 0
    end
  end
  return 0, 0
end
function LogicTeamUpLimit.GetSpecifiedModeSegmentTypeNewLimit(nPerspective, nPlayerNum)
  if nPerspective == nil or nPlayerNum == nil or LogicTeamUpLimit.allModeSegmentLimit == nil then
    return 0, 0
  end
  local minSegId, maxSegId = LogicTeamUpLimit.GetSpecifiedModeSegmentLimit(nPerspective, nPlayerNum)
  if minSegId == 0 and maxSegId == 0 then
    return 0, 0
  end
  if minSegId == -1 and maxSegId == -1 then
    return -1, -1
  end
  local minSegCfg = FuncUtil.GetRankTableData(minSegId)
  local maxSegCfg = FuncUtil.GetRankTableData(maxSegId)
  if minSegCfg == nil or maxSegCfg == nil then
    return 0, 0
  end
  return minSegCfg.IntegralTypeNew, maxSegCfg.IntegralTypeNew
end
function LogicTeamUpLimit.GetSelfSquardSegmentTypeNew(nPerspective)
  if not LobbySystem.CheckOpen(BP_ENUM_TEAM_UP_LIMIT_SWITCH) then
    return 0, 0
  end
  if LogicTeamUpLimit.userSquardLimit == nil or nPerspective == nil then
    return 0, 0
  end
  local minSegId, maxSegId
  if nPerspective == E_PerspectiveType.TPP then
    minSegId = LogicTeamUpLimit.userSquardLimit[1].min_segment_id or 0
    maxSegId = LogicTeamUpLimit.userSquardLimit[1].max_segment_id or 0
  else
    minSegId = LogicTeamUpLimit.userSquardLimit[2].min_segment_id or 0
    maxSegId = LogicTeamUpLimit.userSquardLimit[2].max_segment_id or 0
  end
  local minSegCfg = FuncUtil.GetRankTableData(minSegId)
  local maxSegCfg = FuncUtil.GetRankTableData(maxSegId)
  if minSegCfg == nil or maxSegCfg == nil then
    return 0, 0
  end
  return minSegCfg.IntegralTypeNew, maxSegCfg.IntegralTypeNew
end
function LogicTeamUpLimit.GetSegmentTypeNew(segment)
  if segment == nil or segment == 0 then
    return 0
  end
  local segCfg = FuncUtil.GetRankTableData(segment)
  if segCfg == nil then
    return 0
  end
  return segCfg.IntegralTypeNew
end
function LogicTeamUpLimit.SetCurTeamLimitStatusAndRange(isLimited, leaderSegmentRange)
  if leaderSegmentRange == nil or isLimited == nil then
    log(bWriteLog and "LogicTeamUpLimit.SetCurTeamLimitStatusAndRange params is invalid")
    return
  end
  if LogicTeamUpLimit.teamLimitData == nil then
    LogicTeamUpLimit.teamLimitData = {}
  end
  log(bWriteLog and "LogicTeamUpLimit.SetCurTeamLimitStatusAndRange isLimited" .. tostring(isLimited))
  log_tree("LogicTeamUpLimit.SetCurTeamLimitStatusAndRange leaderSegmentRange", leaderSegmentRange)
  LogicTeamUpLimit.teamLimitData.  LogicTeamUpLimit.teamLimitData.end
function LogicTeamUpLimit.ClearCurTeamLimitStatusAndRange()
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.IsInTeam() then
    log(bWriteLog and "LogicTeamUpLimit.ClearCurTeamLimitStatusAndRange is in team. don't clear!")
    return
  end
  log(bWriteLog and "LogicTeamUpLimit.ClearCurTeamLimitStatusAndRange")
  LogicTeamUpLimit.teamLimitData = nil
end
function LogicTeamUpLimit.GetCurTeamLimitStatusAndRange()
  if not LobbySystem.CheckOpen(BP_ENUM_TEAM_UP_LIMIT_SWITCH) then
    return nil, nil
  end
  if LogicTeamUpLimit.teamLimitData == nil then
    log(bWriteLog and "LogicTeamUpLimit.GetCurTeamLimitStatusAndRange teamLimitData is nil")
    return nil, nil
  end
  log(bWriteLog and "LogicTeamUpLimit.GetCurTeamLimitStatusAndRange teamLimitData is " .. tostring(LogicTeamUpLimit.teamLimitData.isLimited))
  log_tree("LogicTeamUpLimit.GetCurTeamLimitStatusAndRange leaderSegmentRange", LogicTeamUpLimit.teamLimitData.leaderSegmentRange)
  return LogicTeamUpLimit.teamLimitData.isLimited or false, LogicTeamUpLimit.teamLimitData.leaderSegmentRange
end
function LogicTeamUpLimit.GetSegmentRangeName(segmentRange)
  local minSeg = segmentRange.min_segment_id
  local maxSeg = segmentRange.max_segment_id
  if minSeg == nil or maxSeg == nil then
    return "", ""
  end
  if minSeg == 0 or maxSeg == 0 then
    return "", ""
  end
  local minSegCfg = FuncUtil.GetRankTableData(minSeg)
  local maxSegCfg = FuncUtil.GetRankTableData(maxSeg)
  if minSegCfg == nil or maxSegCfg == nil then
    return "", ""
  end
  return minSegCfg.IntegralTypeName, maxSegCfg.IntegralTypeName
end
return LogicTeamUpLimit