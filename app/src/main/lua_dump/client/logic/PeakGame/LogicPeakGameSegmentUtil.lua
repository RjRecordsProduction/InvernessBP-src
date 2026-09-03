local LogicPeakGameSegmentUtil = {}
function LogicPeakGameSegmentUtil.GetSelfCurZonePeakGameRating()
  log(bWriteLog and "LogicPeakGameSegmentUtil.GetSelfCurZonePeakGameRating")
  local LogicPeakGameUtil = require("client.logic.PeakGame.LogicPeakGameUtil")
  local zone_id = LogicPeakGameUtil.GetCurSelectZoneId()
  local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
  local battleType = PeakGameConfig.BattleType.Squad
  local peakgame_rating_info = DataMgr.roleData.peakgame_rating_info
  if peakgame_rating_info and peakgame_rating_info[zone_id] and peakgame_rating_info[zone_id][battleType] and peakgame_rating_info[zone_id][battleType].rating then
    local rating = peakgame_rating_info[zone_id][battleType].rating
    log(bWriteLog and "LogicPeakGameSegmentUtil.GetSelfCurZonePeakGameRating rating = " .. tostring(rating))
    return rating
  end
  return nil
end
function LogicPeakGameSegmentUtil.GetSelfCurZonePeakGameSegmentId()
  log(bWriteLog and "LogicPeakGameSegmentUtil.GetSelfCurZonePeakGameSegmentId")
  local LogicPeakGameUtil = require("client.logic.PeakGame.LogicPeakGameUtil")
  local zone_id = LogicPeakGameUtil.GetCurSelectZoneId()
  local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
  local battleType = PeakGameConfig.BattleType.Squad
  local peakgame_rating_info = DataMgr.roleData.peakgame_rating_info
  if peakgame_rating_info and peakgame_rating_info[zone_id] and peakgame_rating_info[zone_id][battleType] and peakgame_rating_info[zone_id][battleType].segment_id then
    local segment_id = peakgame_rating_info[zone_id][battleType].segment_id
    log(bWriteLog and "LogicPeakGameSegmentUtil.GetSelfCurZonePeakGameSegmentId segment_id = " .. tostring(segment_id))
    return segment_id
  end
  return nil
end
function LogicPeakGameSegmentUtil.GetSelfPeakGameRatingWithZone(zone_id)
  log(bWriteLog and "LogicPeakGameSegmentUtil.GetSelfPeakGameRatingWithZone")
  local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
  local battleType = PeakGameConfig.BattleType.Squad
  local peakgame_rating_info = DataMgr.roleData.peakgame_rating_info
  if peakgame_rating_info and peakgame_rating_info[zone_id] and peakgame_rating_info[zone_id][battleType] and peakgame_rating_info[zone_id][battleType].rating then
    local rank_rating = peakgame_rating_info[zone_id][battleType].rating
    log(bWriteLog and "LogicPeakGameSegmentUtil.GetSelfPeakGameRatingWithZone rank_rating = " .. tostring(rank_rating))
    return rank_rating
  end
  return nil
end
function LogicPeakGameSegmentUtil.GetSelfCurZoneCurSeasonMaxSegmentId()
  log(bWriteLog and "LogicPeakGameSegmentUtil.GetSelfCurZoneCurSeasonMaxSegmentId")
  local LogicPeakGameUtil = require("client.logic.PeakGame.LogicPeakGameUtil")
  local zone_id = LogicPeakGameUtil.GetCurSelectZoneId()
  local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
  local battleType = PeakGameConfig.BattleType.Squad
  local peakgame_rating_info = DataMgr.roleData.peakgame_rating_info
  if peakgame_rating_info and peakgame_rating_info[zone_id] and peakgame_rating_info[zone_id][battleType] and peakgame_rating_info[zone_id][battleType].max_segment_id then
    local max_segment_id = peakgame_rating_info[zone_id][battleType].max_segment_id
    log(bWriteLog and "LogicPeakGameSegmentUtil.GetSelfCurZoneCurSeasonMaxSegmentId max_segment_id = " .. tostring(max_segment_id))
    return max_segment_id
  end
  return nil
end
function LogicPeakGameSegmentUtil.GetSelfAllZoneCurSeasonMaxSegmentId()
  log(bWriteLog and "LogicPeakGameSegmentUtil.GetSelfAllZoneCurSeasonMaxSegmentId")
  local peakgame_rating_info = DataMgr.roleData.peakgame_rating_info
  if peakgame_rating_info == nil or not next(peakgame_rating_info) then
    return nil
  end
  local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
  local max_segment_id = PeakGameConfig.DefaultPeakGameSegment
  for zone_id, battle_info in pairs(peakgame_rating_info) do
    for battle_type, rating_info in pairs(battle_info) do
      local segment_id = rating_info.max_segment_id
      if segment_id and max_segment_id < segment_id then
        max_      end
    end
  end
  log(bWriteLog and "LogicPeakGameSegmentUtil.GetSelfAllZoneCurSeasonMaxSegmentId max_segment_id = " .. tostring(max_segment_id))
  return max_segment_id
end
function LogicPeakGameSegmentUtil.GetSelfHistoryMaxSegmentId()
  log(bWriteLog and "LogicPeakGameSegmentUtil.GetSelfHistoryMaxSegmentId")
  local peakgame_history_max_segment = DataMgr.roleData.peakgame_history_max_segment
  log(bWriteLog and "LogicPeakGameSegmentUtil.GetSelfHistoryMaxSegmentId peakgame_history_max_segment = " .. tostring(peakgame_history_max_segment))
  return peakgame_history_max_segment
end
function LogicPeakGameSegmentUtil.GetSelfAllZoneCurSeasonMaxRatingInfo()
  log(bWriteLog and "LogicPeakGameSegmentUtil.GetSelfCurZoneCurSeasonMaxRating")
  local peakgame_rating_info = DataMgr.roleData.peakgame_rating_info
  if peakgame_rating_info == nil or not next(peakgame_rating_info) then
    log(bWriteLog and "LogicPeakGameSegmentUtil.GetSelfCurZoneCurSeasonMaxRating 1")
    return nil
  end
  local max_rating = 0
  local max_rating_info
  for zone_id, battle_info in pairs(peakgame_rating_info) do
    for battle_type, rating_info in pairs(battle_info) do
      if rating_info.rating and max_rating < rating_info.rating then
        max_rating = rating_info.rating
        max_      end
    end
  end
  log_tree("LogicPeakGameSegmentUtil.GetSelfAllZoneCurSeasonMaxRatingInfo max_rating_info = ", max_rating_info)
  return max_rating_info
end
function LogicPeakGameSegmentUtil.GetSelfPeakKDByZoneId(zone_id)
  log(bWriteLog and "LogicPeakGameSegmentUtil.GetSelfPeakKDByZoneId zone_id = " .. tostring(zone_id))
  if not zone_id then
    return nil
  end
  local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
  local battleType = PeakGameConfig.BattleType.Squad
  local peakgame_rating_info = DataMgr.roleData.peakgame_rating_info
  if peakgame_rating_info and peakgame_rating_info[zone_id] and peakgame_rating_info[zone_id][battleType] and peakgame_rating_info[zone_id][battleType].kd_v2 then
    local kd_v2 = peakgame_rating_info[zone_id][battleType].kd_v2
    log(bWriteLog and "LogicPeakGameSegmentUtil.GetSelfPeakKDByZoneId kd_v2 = " .. tostring(kd_v2))
    return kd_v2
  end
  return nil
end
function LogicPeakGameSegmentUtil.GetSelfPeakWinNum(zone_id, type, mode)
  log(bWriteLog and "LogicPeakGameSegmentUtil.GetSelfPeakWinNum zone_id = " .. tostring(zone_id) .. " type = " .. tostring(type) .. " mode = " .. tostring(mode))
  if not (zone_id and type) or not mode then
    return nil
  end
  local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
  local battleType = PeakGameConfig.BattleType.Squad
  local peakgame_rating_info = DataMgr.roleData.peakgame_rating_info
  if not (peakgame_rating_info and peakgame_rating_info[zone_id]) or not peakgame_rating_info[zone_id][battleType] then
    log(bWriteLog and "LogicPeakGameSegmentUtil.GetSelfPeakWinNum no segment info")
    return nil
  end
  local win_num
  if type == 1 then
    if not peakgame_rating_info[zone_id][battleType].win_stat or not peakgame_rating_info[zone_id][battleType].win_stat[mode] then
      return nil
    end
    win_num = peakgame_rating_info[zone_id][battleType].win_stat[mode]
  elseif type == 2 then
    if not peakgame_rating_info[zone_id][battleType].win_week_stat or not peakgame_rating_info[zone_id][battleType].win_week_stat[mode] then
      return nil
    end
    win_num = peakgame_rating_info[zone_id][battleType].win_week_stat[mode]
  end
  log(bWriteLog and "LogicPeakGameSegmentUtil.GetSelfPeakWinNum win_num = " .. tostring(win_num))
  return win_num
end
function LogicPeakGameSegmentUtil.GetProfileCurZoneRating(profile)
  log(bWriteLog and "LogicPeakGameSegmentUtil.GetProfileCurZoneRating")
  local LogicPeakGameUtil = require("client.logic.PeakGame.LogicPeakGameUtil")
  local zone_id = LogicPeakGameUtil.GetCurSelectZoneId()
  local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
  local battleType = PeakGameConfig.BattleType.Squad
  local segmentInfo = LogicPeakGameSegmentUtil.GetProfileSegmentInfo(profile)
  if not (segmentInfo and segmentInfo[zone_id]) or not segmentInfo[zone_id][battleType] then
    log(bWriteLog and "LogicPeakGameSegmentUtil.GetProfileCurZoneRating no segment info")
    return nil
  end
  local rating = segmentInfo[zone_id][battleType].rating
  log(bWriteLog and "LogicPeakGameSegmentUtil.GetProfileCurZoneRating rating = " .. tostring(rating))
  return rating
end
function LogicPeakGameSegmentUtil.GetProfilePeakGameRatingWithZone(profile, zone_id)
  log(bWriteLog and "LogicPeakGameSegmentUtil.GetProfilePeakGameRatingWithZone")
  local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
  local battleType = PeakGameConfig.BattleType.Squad
  local segmentInfo = LogicPeakGameSegmentUtil.GetProfileSegmentInfo(profile)
  if not (segmentInfo and segmentInfo[zone_id]) or not segmentInfo[zone_id][battleType] then
    log(bWriteLog and "LogicPeakGameSegmentUtil.GetProfilePeakGameRatingWithZone no segment info")
    return nil
  end
  local rating = segmentInfo[zone_id][battleType].rating
  log(bWriteLog and "LogicPeakGameSegmentUtil.GetProfilePeakGameRatingWithZone rating = " .. tostring(rating))
  return rating
end
function LogicPeakGameSegmentUtil.GetProfileCurZoneSegmentId(profile)
  log(bWriteLog and "LogicPeakGameSegmentUtil.GetProfileCurZoneSegmentId")
  local LogicPeakGameUtil = require("client.logic.PeakGame.LogicPeakGameUtil")
  local zone_id = LogicPeakGameUtil.GetCurSelectZoneId()
  local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
  local battleType = PeakGameConfig.BattleType.Squad
  local segmentInfo = LogicPeakGameSegmentUtil.GetProfileSegmentInfo(profile)
  if not (segmentInfo and segmentInfo[zone_id]) or not segmentInfo[zone_id][battleType] then
    log(bWriteLog and "LogicPeakGameSegmentUtil.GetProfileCurZoneSegmentId no segment info")
    return nil
  end
  local segment_id = segmentInfo[zone_id][battleType].segment_id
  log(bWriteLog and "LogicPeakGameSegmentUtil.GetProfileCurZoneSegmentId segment_id = " .. tostring(segment_id))
  return segment_id
end
function LogicPeakGameSegmentUtil.GetProfileCurZoneMaxSegmentId(profile)
  log(bWriteLog and "LogicPeakGameSegmentUtil.GetProfileCurZoneMaxSegmentId")
  local LogicPeakGameUtil = require("client.logic.PeakGame.LogicPeakGameUtil")
  local zone_id = LogicPeakGameUtil.GetCurSelectZoneId()
  local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
  local battleType = PeakGameConfig.BattleType.Squad
  local segmentInfo = LogicPeakGameSegmentUtil.GetProfileSegmentInfo(profile)
  if not (segmentInfo and segmentInfo[zone_id]) or not segmentInfo[zone_id][battleType] then
    log(bWriteLog and "LogicPeakGameSegmentUtil.GetProfileCurZoneMaxSegmentId no segment info")
    return nil
  end
  local max_segment_id = segmentInfo[zone_id][battleType].max_segment_id
  log(bWriteLog and "LogicPeakGameSegmentUtil.GetProfileCurZoneMaxSegmentId max_segment_id = " .. tostring(max_segment_id))
  return max_segment_id
end
function LogicPeakGameSegmentUtil.GetProfileSegmentInfo(profile)
  log(bWriteLog and "LogicPeakGameSegmentUtil.GetProfileSegmentInfo")
  local LogicPeakGameUtil = require("client.logic.PeakGame.LogicPeakGameUtil")
  if not LogicPeakGameUtil.IsOpen() then
    log(bWriteLog and "LogicPeakGameSegmentUtil.GetProfileSegmentInfo not open")
    return nil
  end
  if not (profile and profile.peakgame_segment_info and profile.peakgame_segment_info.curr_season_id) or not profile.peakgame_segment_info.list then
    log(bWriteLog and "LogicPeakGameSegmentUtil.GetProfileSegmentInfo no data")
    return nil
  end
  local curSeasonId = DataMgr.season_id
  log(bWriteLog and "LogicPeakGameSegmentUtil.GetProfileSegmentInfo curr_season_id = " .. tostring(profile.peakgame_segment_info.curr_season_id) .. " curSeasonId = " .. tostring(curSeasonId))
  if curSeasonId ~= profile.peakgame_segment_info.curr_season_id then
    log(bWriteLog and "LogicPeakGameSegmentUtil.GetProfileSegmentInfo not current season data")
    local default_peakgame_profile = require("client.logic.PeakGame.default_peakgame_profile")
    local TableUtil = require("common.table_util")
    local new_default_peakgame_profile = TableUtil.CopyTable(default_peakgame_profile)
    return new_default_peakgame_profile.list
  end
  return profile.peakgame_segment_info.list
end
function LogicPeakGameSegmentUtil.GetProfileCurMaxSegmentId(profile)
  log(bWriteLog and "LogicPeakGameSegmentUtil.GetProfileCurMaxSegmentId")
  local segmentInfo = LogicPeakGameSegmentUtil.GetProfileSegmentInfo(profile)
  if not segmentInfo then
    log(bWriteLog and "LogicPeakGameSegmentUtil.GetProfileCurMaxSegmentId no segment info")
    return nil
  end
  local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
  local max_segment_id = PeakGameConfig.DefaultPeakGameSegment
  for i, v in pairs(segmentInfo) do
    for ii, vv in pairs(v) do
      if vv.max_segment_id and max_segment_id < vv.max_segment_id then
        max_segment_id = vv.max_segment_id
      end
    end
  end
  log(bWriteLog and "LogicPeakGameSegmentUtil.GetProfileCurMaxSegmentId max_segment_id = " .. tostring(max_segment_id))
  return max_segment_id
end
function LogicPeakGameSegmentUtil.GetProfileHistoryMaxSegmentId(profile)
  log(bWriteLog and "LogicPeakGameSegmentUtil.GetProfileHistoryMaxSegmentId")
  if profile and profile.peakgame_history_max_segment then
    local peakgame_history_max_segment = profile.peakgame_history_max_segment
    log(bWriteLog and "LogicPeakGameSegmentUtil.GetProfileHistoryMaxSegmentId peakgame_history_max_segment = " .. tostring(peakgame_history_max_segment))
    return peakgame_history_max_segment
  end
  return nil
end
function LogicPeakGameSegmentUtil.GetPeakKDByZoneId(profile, zone_id)
  log(bWriteLog and "LogicPeakGameSegmentUtil.GetPeakKDByZoneId zone_id = " .. tostring(zone_id))
  if not zone_id then
    return nil
  end
  local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
  local battleType = PeakGameConfig.BattleType.Squad
  local segmentInfo = LogicPeakGameSegmentUtil.GetProfileSegmentInfo(profile)
  if not (segmentInfo and segmentInfo[zone_id]) or not segmentInfo[zone_id][battleType] then
    log(bWriteLog and "LogicPeakGameSegmentUtil.GetPeakKDByZoneId no segment info")
    return nil
  end
  local kd_v2 = segmentInfo[zone_id][battleType].kd_v2
  log(bWriteLog and "LogicPeakGameSegmentUtil.GetPeakKDByZoneId kd_v2 = " .. tostring(kd_v2))
  return kd_v2
end
function LogicPeakGameSegmentUtil.GetPeakWinNum(profile, zone_id, type, mode)
  log(bWriteLog and "LogicPeakGameSegmentUtil.GetPeakWinNum zone_id = " .. tostring(zone_id) .. " type = " .. tostring(type) .. " mode = " .. tostring(mode))
  if not (zone_id and type) or not mode then
    return nil
  end
  local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
  local battleType = PeakGameConfig.BattleType.Squad
  local segmentInfo = LogicPeakGameSegmentUtil.GetProfileSegmentInfo(profile)
  if not (segmentInfo and segmentInfo[zone_id]) or not segmentInfo[zone_id][battleType] then
    log(bWriteLog and "LogicPeakGameSegmentUtil.GetPeakWinNum no segment info")
    return nil
  end
  local win_num
  if type == 1 then
    if not segmentInfo[zone_id][battleType].win_stat or not segmentInfo[zone_id][battleType].win_stat[mode] then
      return nil
    end
    win_num = segmentInfo[zone_id][battleType].win_stat[mode]
  elseif type == 2 then
    if not segmentInfo[zone_id][battleType].win_week_stat or not segmentInfo[zone_id][battleType].win_week_stat[mode] then
      return nil
    end
    win_num = segmentInfo[zone_id][battleType].win_week_stat[mode]
  end
  log(bWriteLog and "LogicPeakGameSegmentUtil.GetPeakWinNum win_num = " .. tostring(win_num))
  return win_num
end
function LogicPeakGameSegmentUtil.GetPeakSegmentIdByRating(rating)
  log(bWriteLog and "LogicPeakGameSegmentUtil.GetPeakSegmentIdByRating rating = " .. tostring(rating) .. "type = " .. tostring(type(rating)))
  rating = tonumber(rating)
  if not rating then
    log(bWriteLog and " LogicPeakGameSegmentUtil.GetPeakSegmentIdByRating no rating")
    return nil
  end
  local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
  local segment = PeakGameConfig.DefaultPeakGameSegment
  local LogicPeakGameUtil = require("client.logic.PeakGame.LogicPeakGameUtil")
  local peakRankTable = LogicPeakGameUtil.GetPeakRankTable()
  for _, segmentCfg in pairs(peakRankTable) do
    if rating >= segmentCfg.MinIntegral then
      segment = segmentCfg.Level
    else
      break
    end
  end
  log(bWriteLog and "LogicPeakGameSegmentUtil.GetPeakSegmentIdByRating segment = " .. tostring(segment))
  return segment
end
function LogicPeakGameSegmentUtil.GetPeakSegmentFromTeamMemberInfo(teamMemberInfo, zoneId, battleType)
  log(bWriteLog and "LogicPeakGameSegmentUtil.GetPeakSegmentFromTeamMemberInfo zoneId = " .. tostring(zoneId) .. " battleType" .. tostring(battleType))
  log_tree("LogicPeakGameSegmentUtil.GetPeakSegmentFromTeamMemberInfo teamMemberInfo = ", teamMemberInfo)
  local LogicPeakGameUtil = require("client.logic.PeakGame.LogicPeakGameUtil")
  if not LogicPeakGameUtil.IsOpen() then
    log(bWriteLog and "LogicPeakGameSegmentUtil.GetPeakSegmentFromTeamMemberInfo switch not open")
    return nil
  end
  if not zoneId or not battleType then
    log(bWriteLog and "LogicPeakGameSegmentUtil.GetPeakSegmentFromTeamMemberInfo invalid param")
    return nil
  end
  if not (teamMemberInfo and teamMemberInfo.peakgame_segment_info) or not teamMemberInfo.peakgame_segment_info.list then
    log(bWriteLog and "LogicPeakGameSegmentUtil.GetPeakSegmentFromTeamMemberInfo no data")
    return nil
  end
  local segmentInfo = teamMemberInfo.peakgame_segment_info.list
  if not segmentInfo[zoneId] or not segmentInfo[zoneId][battleType] then
    log(bWriteLog and "LogicPeakGameSegmentUtil.GetPeakSegmentFromTeamMemberInfo no segmentid")
    return nil
  end
  return segmentInfo[zoneId][battleType].segment_id
end
return LogicPeakGameSegmentUtil