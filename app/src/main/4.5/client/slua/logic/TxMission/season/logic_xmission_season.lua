local LogicTxMissionSeason = {
  level = 1,
  exp = 0,
  max_level = 0,
  season_id = 1,
  total_kill = 0,
  total_session = 0,
  total_kd = 0,
  avg_plunder = 0,
  award_status = {},
  season_award_list = {},
  segment_list = {},
  max_cfg_level = 0,
  max_cfg_main_level = 0,
  levelupData = nil,
  isNewSeason = false
}
local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
function LogicTxMissionSeason.InitData(season)
  if season then
    LogicTxMissionSeason.isNewSeason = false
    if season.military then
      local curLvl = season.military.level or 1
      if curLvl > LogicTxMissionSeason.level then
        LogicTxMissionSeason.isNewSeason = true
      end
      LogicTxMissionSeason.level = curLvl
      LogicTxMissionSeason.max_level = season.military.max_level or 0
      LogicTxMissionSeason.exp = season.military.value or 0
      LogicTxMissionSeason.award_status = season.military.awards or {}
    end
    LogicTxMissionSeason.season_id = season.season_id or LogicTxMissionSeason.season_id
    LogicTxMissionSeason.total_kill = season.kill_player or 0
    LogicTxMissionSeason.total_session = season.game_num or 0
    LogicTxMissionSeason.total_kd = math.floor((season.kd or 0) * 100) / 100
    LogicTxMissionSeason.avg_plunder = 0
    if 0 < LogicTxMissionMain.GetCurProfit() and 0 < LogicTxMissionSeason.total_session then
      local avg = LogicTxMissionMain.GetCurProfit() / LogicTxMissionSeason.total_session
      LogicTxMissionSeason.avg_plunder = FuncUtil.TransformNumToFormatStr(math.floor(avg))
    end
  end
end
function LogicTxMissionSeason.DestroyData()
  LogicTxMissionSeason.season_award_list = {}
  LogicTxMissionSeason.segment_list = {}
end
function LogicTxMissionSeason.GetSeasonConfig(seasonId)
  local TxMissionSeasonTime = CDataTable.GetTable("TxMissionSeasonTime")
  local TableUtil = require("common.table_util")
  local value
  if not TxMissionSeasonTime then
    return value
  end
  if seasonId and seasonId ~= 1 then
    value = TableUtil.GetTableValue(TxMissionSeasonTime, seasonId)
  elseif LogicTxMissionSeason.season_id and LogicTxMissionSeason.season_id ~= 1 then
    value = TableUtil.GetTableValue(TxMissionSeasonTime, LogicTxMissionSeason.season_id)
  else
    local max = LogicTxMissionSeason.season_id
    for k, _ in ipairs(TxMissionSeasonTime) do
      if k > max then
        max = k
      end
    end
    value = TableUtil.GetTableValue(TxMissionSeasonTime, max)
  end
  return value
end
function LogicTxMissionSeason.IsOpenDoubleExp(seasonId)
  local seasonCfg
  if seasonId then
    seasonCfg = LogicTxMissionSeason.GetSeasonConfig(seasonId)
  else
    seasonCfg = LogicTxMissionSeason.GetSeasonConfig(LogicTxMissionSeason.season_id)
  end
  if seasonCfg and seasonCfg.IsDoubleExp then
    return tonumber(seasonCfg.IsDoubleExp) == 1
  end
  return false
end
function LogicTxMissionSeason.IsOpenDoublePrestige(seasonId)
  local seasonCfg
  if seasonId then
    seasonCfg = LogicTxMissionSeason.GetSeasonConfig(seasonId)
  else
    seasonCfg = LogicTxMissionSeason.GetSeasonConfig(LogicTxMissionSeason.season_id)
  end
  if seasonCfg and seasonCfg.IsDoublePrestige then
    return tonumber(seasonCfg.IsDoublePrestige) == 1
  end
  return false
end
function LogicTxMissionSeason.GetMaxSegmentLevel()
  if not LogicTxMissionSeason.max_cfg_level or LogicTxMissionSeason.max_cfg_level == 0 then
    LogicTxMissionSeason.max_cfg_level = 0
    local awardCfg = CDataTable.GetTable("TxMissionSegment")
    for k, v in pairs(awardCfg) do
      if LogicTxMissionSeason.max_cfg_level < v.Level then
        LogicTxMissionSeason.max_cfg_level = v.Level
      end
    end
  end
  return LogicTxMissionSeason.max_cfg_level
end
function LogicTxMissionSeason.GetMaxMainSegmentLevel()
  if not LogicTxMissionSeason.max_cfg_main_level or LogicTxMissionSeason.max_cfg_main_level == 0 then
    LogicTxMissionSeason.max_cfg_main_level = 0
    local awardCfg = CDataTable.GetTable("TxMissionSegment")
    for k, v in pairs(awardCfg) do
      if LogicTxMissionSeason.max_cfg_main_level < v.TypeID then
        LogicTxMissionSeason.max_cfg_main_level = v.TypeID
      end
    end
  end
  return LogicTxMissionSeason.max_cfg_main_level
end
function LogicTxMissionSeason.GetCurSeasonAwardByGameID(gameid)
  local award_list = {}
  local awardCfg = CDataTable.GetTable("TxMissionSeasonAward")
  for k, v in pairs(awardCfg) do
    if v.Season and tonumber(v.Season) == LogicTxMissionSeason.season_id and v.AppID and tonumber(v.AppID) == tonumber(gameid) then
      table.insert(award_list, {
        ID = v.ID,
        Season = v.Season,
        MilitaryLevel = v.MilitaryLevel,
        AwardID1 = v.AwardID1,
        AwardNum1 = v.AwardNum1,
        AwardID2 = v.AwardID2,
        AwardNum2 = v.AwardNum2
      })
    end
  end
  return award_list
end
function LogicTxMissionSeason.GetCurSeasonAwardList()
  if LogicTxMissionSeason.season_award_list == nil or #LogicTxMissionSeason.season_award_list <= 0 then
    local gameid = Client.GetITopGameId()
    LogicTxMissionSeason.season_award_list = LogicTxMissionSeason.GetCurSeasonAwardByGameID(gameid)
    if not LogicTxMissionSeason.season_award_list or #LogicTxMissionSeason.season_award_list <= 0 then
      LogicTxMissionSeason.season_award_list = LogicTxMissionSeason.GetCurSeasonAwardByGameID(1320)
    end
  end
  return LogicTxMissionSeason.season_award_list
end
function LogicTxMissionSeason.GetCurTXSeasonID()
  log(bWriteLog and "LogicTxMissionSeason.GetCurTXSeasonID season_id:" .. tostring(LogicTxMissionSeason.season_id))
  return LogicTxMissionSeason.season_id
end
function LogicTxMissionSeason.GetSegmentList()
  if not LogicTxMissionSeason.segment_list or #LogicTxMissionSeason.segment_list then
    LogicTxMissionSeason.segment_list = {}
    local segmentCfg = CDataTable.GetTable("TxMissionSegment")
    for k, v in pairs(segmentCfg) do
      local bExist = false
      for kk, vv in pairs(LogicTxMissionSeason.segment_list) do
        if vv.TypeID == v.TypeID then
          table.insert(vv.Sub, v)
          bExist = true
          break
        end
      end
      if not bExist then
        local segItem = {
          TypeID = v.TypeID,
          TypeName = v.TypeName,
          BigIcon = v.BigIcon,
          Sub = {}
        }
        table.insert(segItem.Sub, v)
        table.insert(LogicTxMissionSeason.segment_list, segItem)
      end
    end
  end
  return LogicTxMissionSeason.segment_list
end
function LogicTxMissionSeason.GetSubSegmentList(TypeID)
  if LogicTxMissionSeason.segment_list and next(LogicTxMissionSeason.segment_list) then
    for _, v in pairs(LogicTxMissionSeason.segment_list) do
      if TypeID == v.TypeID then
        return v.Sub
      end
    end
  end
  return nil
end
function LogicTxMissionSeason.GetMatchTime()
  log(bWriteLog and "[mxiliu]UI_XMission_Main:GetMatchTime season_id " .. tostring(LogicTxMissionSeason.season_id))
  local seasonCfg = LogicTxMissionSeason.GetSeasonConfig(LogicTxMissionSeason.season_id)
  log(bWriteLog and "[mxiliu]UI_XMission_Main:GetMatchTime MatchStartTime " .. tostring(seasonCfg.MatchStartTime))
  return seasonCfg.MatchStartTime
end
function LogicTxMissionSeason.CheckShowMatchBtn()
  local seasonCfg = LogicTxMissionSeason.GetSeasonConfig(LogicTxMissionSeason.season_id)
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  log(bWriteLog and "LogicTxMissionSeason.CheckShowMatchBtn nowTime =" .. tostring(nowTime))
  if seasonCfg and seasonCfg.MatchStartTime and seasonCfg.MatchStartTime ~= "" then
    local matchtime = TimeUtil.TimeStringToUnixstamp(seasonCfg.MatchStartTime)
    log(bWriteLog and "LogicTxMissionSeason.CheckShowMatchBtn matchtime =" .. tostring(matchtime))
    if nowTime <= matchtime then
      return true
    end
  end
  return false
end
function LogicTxMissionSeason.CheckShowSeasonLevelup()
  if LogicTxMissionSeason.levelUpData then
    UIManager.ShowUI(UIManager.UI_Config.xmission_season_levelup, LogicTxMissionSeason.levelUpData.old_level, LogicTxMissionSeason.levelUpData.new_level)
    LogicTxMissionSeason.levelUpData = nil
    return true
  end
  LogicTxMissionSeason.levelUpData = nil
  return false
end
function LogicTxMissionSeason.on_notify_military_level_change(old_level, new_level, new_exp)
  LogicTxMissionSeason.level = new_level
  LogicTxMissionSeason.exp = new_exp
  EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_NOTIFY_MILITARY_LEVEL)
  if new_level <= old_level then
    return
  end
  if GameStatus.IsInLobbyOrMainCity() and LogicTxMissionMain.IsInXMission() then
    UIManager.ShowUI(UIManager.UI_Config.xmission_season_levelup, old_level, new_level)
    return
  end
  LogicTxMissionSeason.levelUpData = {
    old_level = old_level,
    new_level = new_level,
      }
end
function LogicTxMissionSeason.on_metro_get_season_award_rsp(id, awards_list)
  if awards_list and next(awards_list) then
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle(awards_list)
  end
  LogicTxMissionSeason.award_status = LogicTxMissionSeason.award_status or {}
  LogicTxMissionSeason.award_status[id] = 1
  EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_GET_SEASON_AWARD_RSP)
end
function LogicTxMissionSeason.HasRedDot()
  local logic_xmission_info = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_info)
  local season_awards = LogicTxMissionSeason.GetCurSeasonAwardList()
  for k, v in pairs(season_awards) do
    local status = logic_xmission_info:GetSeasonAwardStatus(v.ID)
    if status == 1 then
      return true
    end
  end
  local LogicXmissionTask = require("client.slua.logic.TxMission.xmission_task.logic_xmission_task")
  local week_awards = LogicXmissionTask.GetMilitaryTaskList()
  for k, v in pairs(week_awards) do
    local status = LogicXmissionTask.GetMilitaryTaskStatus(v)
    if status == 3 then
      return true
    end
  end
  return false
end
return LogicTxMissionSeason