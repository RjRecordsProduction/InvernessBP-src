local LogicPeakGame = {}
local LogicPeakGameUtil = require("client.logic.PeakGame.LogicPeakGameUtil")
local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
function LogicPeakGame:DefineAndResetData()
  self.peakgame_info = nil
  self.peakgame_time_info = nil
  self.rating_info = nil
  self.peakSeasonId = nil
  self.peakgame_change_rank_rule_info = {}
  self.isShowPeakGameHideNameSelection = false
  self.peakgameHideName = 0
  self.peakgame_anchorName = ""
end
function LogicPeakGame:OnInitialize()
  LogicPeakGame.__super.OnInitialize(self)
end
function LogicPeakGame:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ROLE_RANK_CHANGE, self.OnClassicSegmentChange, self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_SEASON_CHANGE, self.OnSeasonChange, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_ENTERLOBBY, self.RequestNewAnchorName, self)
end
function LogicPeakGame:OnLogOut()
  log(bWriteLog and "LogicPeakGame OnLogOut")
  self:ResetAllCacheData()
end
function LogicPeakGame:OnPostSwitchGameStatus(preState, nextState)
  if GameStatus.IsInLobbyOrMainCity() then
    self:ShowLevelUpSlap()
  end
end
function LogicPeakGame:CheckCanPlayPeakGame()
  log(bWriteLog and "LogicPeakGame:CheckCanPlayPeakGame")
  local canPeakGame = self.peakgame_info and self.peakgame_info.can_peakgame
  return canPeakGame or false
end
function LogicPeakGame:GetPeakGameMinSeg()
  log(bWriteLog and "LogicPeakGame:GetPeakGameMinSeg")
  return self.peakgame_info and self.peakgame_info.can_peakgame_min_segment_id
end
function LogicPeakGame:GetCurSeasonId()
  log(bWriteLog and "LogicPeakGame:GetCurSeasonId")
  local season_id = DataMgr.season_id
  log(bWriteLog and "LogicPeakGame:GetCurSeasonId season_id = " .. tostring(season_id))
  return season_id
end
function LogicPeakGame:GetPeakGameCurSeasonTime()
  log(bWriteLog and "LogicPeakGame:GetPeakGameCurSeasonTime")
  if not self.peakgame_info then
    log(bWriteLog and "LogicPeakGame:GetPeakGameCurSeasonTime no peakgame_info")
    return
  end
  return self.peakgame_info.begin_time, self.peakgame_info.end_time
end
function LogicPeakGame:GetCurPeakGameState()
  log(bWriteLog and "LogicPeakGame:GetCurPeakGameState")
  local beginTS, endTS = self:GetPeakGameCurSeasonTime()
  local TimeUtil = require("client.common.time_util")
  if not (beginTS and endTS) or TimeUtil.UnixTimeBetween(beginTS, endTS) ~= 0 then
    log(bWriteLog and "LogicPeakGame:GetCurPeakGameState 1")
    return PeakGameConfig.EnumPeakGameState.NotInSeasonTime
  end
  if self:CheckCanPlayPeakGame() then
    local LogicPeakGameUtil = require("client.logic.PeakGame.LogicPeakGameUtil")
    local zone_id = LogicPeakGameUtil.GetCurSelectZoneId()
    log(bWriteLog and "LogicPeakGame:GetCurPeakGameState zone_id = " .. tostring(zone_id))
    local dayBeginTS, dayEndTS = self:GetPeakGameTodayValidTime(zone_id)
    if dayBeginTS and dayEndTS and TimeUtil.UnixTimeBetween(dayBeginTS, dayEndTS) == 0 then
      log(bWriteLog and "LogicPeakGame:GetCurPeakGameState 2")
      return PeakGameConfig.EnumPeakGameState.CanPlayPeakGame
    else
      log(bWriteLog and "LogicPeakGame:GetCurPeakGameState 3")
      return PeakGameConfig.EnumPeakGameState.NotInPeakGameStartTime
    end
  else
    log(bWriteLog and "LogicPeakGame:GetCurPeakGameState 4")
    return PeakGameConfig.EnumPeakGameState.CannotPlayPeakGame
  end
end
function LogicPeakGame:GetPeakGameTodayValidTime(zoneId)
  log(bWriteLog and "LogicPeakGame:GetPeakGameTodayValidTime zoneId = " .. tostring(zoneId))
  if not (self.peakgame_time_info and zoneId) or not self.peakgame_time_info[zoneId] then
    log(bWriteLog and "LogicPeakGame:GetPeakGameTodayValidTime invalid data")
    return 0, 0
  end
  return self.peakgame_time_info[zoneId].day_begin_time or 0, self.peakgame_time_info[zoneId].day_end_time or 0
end
function LogicPeakGame:ShowLevelUpSlap()
  if not GameStatus.IsInLobbyOrMainCity() then
    log(bWriteLog and "LogicPeakGame:ShowLevelUpSlap in fight")
    return
  end
  if not self.slapLevelUpFlag then
    log(bWriteLog and string.format("LogicPeakGame:ShowLevelUpSlap, not self.slapLevelUpFlag:%s", self.slapLevelUpFlag))
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.PeakGame_Rank_LevelUP_UIBP)
  self.slapLevelUpFlag = false
end
function LogicPeakGame:CheckLevelUpSlap(newRatingInfo)
  local LogicPeakGameUtil = require("client.logic.PeakGame.LogicPeakGameUtil")
  local zone_id = LogicPeakGameUtil.GetCurSelectZoneId()
  log(bWriteLog and string.format("LogicPeakGame:CheckLevelUpSlap, zone_id:%s", zone_id))
  local battleType = PeakGameConfig.BattleType.Squad
  local logic_season_util = require("client.logic.season.logic_season_util")
  if logic_season_util.IsModReady() then
    return false
  end
  if not (newRatingInfo and newRatingInfo[zone_id]) or not newRatingInfo[zone_id][battleType] then
    log(bWriteLog and "LogicPeakGame:CheckLevelUpSlap newRatingInfo no new data")
    return false
  end
  local newMaxSegmentID = newRatingInfo[zone_id][battleType].max_segment_id
  local lastRatingInfo = DataMgr.roleData.peakgame_rating_info
  local lastMaxSegmentID = PeakGameConfig.DefaultPeakGameSegment
  if lastRatingInfo and next(lastRatingInfo) then
    if not lastRatingInfo[zone_id] or not lastRatingInfo[zone_id][battleType] then
      log(bWriteLog and "LogicPeakGame:CheckLevelUpSlap no last data")
      return false
    else
      lastMaxSegmentID = lastRatingInfo[zone_id][battleType].max_segment_id
    end
  else
  end
  local LogicPeakGameUtil = require("client.logic.PeakGame.LogicPeakGameUtil")
  local newConfig = LogicPeakGameUtil.GetPeakRankTableData(newMaxSegmentID)
  local lastConfig = LogicPeakGameUtil.GetPeakRankTableData(lastMaxSegmentID)
  if not newConfig or not lastConfig then
    log(bWriteLog and "LogicPeakGame:CheckLevelUpSlap return of not newConfig or not lastConfig")
    return false
  end
  if lastConfig.IntegralType >= newConfig.IntegralType then
    log(bWriteLog and "LogicPeakGame:CheckLevelUpSlap return of lastConfig.IntegralType >= newConfig.IntegralType")
    return false
  end
  self.slapLevelUpFlag = true
  return true
end
function LogicPeakGame:GetChangeRankRuleInfo()
  log(bWriteLog and "LogicPeakGame:GetChangeRankRuleInfo")
  return self.peakgame_change_rank_rule_info
end
function LogicPeakGame:MapCustomGetSizeFunc(downloadType, mapKeyList, bSkipDepend)
  log(bWriteLog and "LogicPeakGame:MapCustomGetSizeFunc downloadType" .. downloadType)
  log_tree("LogicPeakGame:MapCustomGetSizeFunc mapKeyList = ", mapKeyList)
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  if not self.MapBaseSize or self.TMapBaseSize > 1 then
    local _, totalSize = PufferManager.GetSize(PufferConst.ENUM_DownloadType.MAP, {"map_desert"})
    self.MapBaseSize = totalSize
    log(bWriteLog and "LogicPeakGame:MapCustomGetSizeFunc self.MapBaseSize" .. totalSize)
  end
  local downloadSize, totalSize = PufferManager.GetSize(downloadType, mapKeyList, bSkipDepend)
  if downloadSize >= self.MapBaseSize then
    downloadSize = downloadSize - self.MapBaseSize
    totalSize = totalSize - self.MapBaseSize
  end
  return downloadSize, totalSize
end
function LogicPeakGame:DoesMatchGame()
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local matchMode = logic_mode_selection:GetCurSelectInfo()
  local IsClassicRank = logic_mode_selection:IsClassicRankMode(matchMode)
  local LogicPeakGameUtil = require("client.logic.PeakGame.LogicPeakGameUtil")
  local IsPeakGame = LogicPeakGameUtil.IsPeakGameBattleTypeIgnoreSwitch(matchMode)
  print(bWriteLog and string.format("LogicPeakGame:DoesHideName IsClassRank:%s IsPeakGame:%s", tostring(IsClassicRank), tostring(IsPeakGame)))
  return IsClassicRank or IsPeakGame
end
function LogicPeakGame:DoesHideName()
  print(bWriteLog and string.format("LogicPeakGame:DoesHideName bHideNameSwitchOn:%s anchor_random_name:%s", tostring(self.peakgameHideName), self.peakgame_anchorName))
  return self:DoesMatchGame() and self.peakgameHideName == 1
end
function LogicPeakGame:ReqPeakGameInfo(forceUpdate)
  log(bWriteLog and "LogicPeakGame:ReqPeakGameInfo forceUpdate = " .. tostring(forceUpdate))
  if not LogicPeakGameUtil.IsOpen() then
    log(bWriteLog and "LogicPeakGame:ReqPeakGameInfo not open")
    return
  end
  if not forceUpdate and self.peakgame_info then
    log(bWriteLog and "LogicPeakGame:ReqPeakGameInfo has cache")
    return
  end
  local PeakGameHandler = require("client.network.Protocol.PeakGameHandler")
  PeakGameHandler.send_get_peakgame_info_req()
end
function LogicPeakGame:OnGetPeakGameInfo(peakgame_info)
  log(bWriteLog and "LogicPeakGame:OnGetPeakGameInfo")
  if not peakgame_info then
    log(bWriteLog and "LogicPeakGame:OnGetPeakGameInfo no peakgame_info")
    return
  end
  if not LogicPeakGameUtil.IsOpen() then
    log(bWriteLog and "LogicPeakGame:OnGetPeakGameInfo not open")
    return
  end
  self.  self.peakSeasonId = peakgame_info and peakgame_info.curr_season_id
  if peakgame_info and peakgame_info.begin_time then
    DataMgr.roleData.peakgame_start_time = peakgame_info.begin_time
  end
  EventSystem:postEvent(EVENTTYPE_PEAKGAME, EVENTID_PEAKGAME_INFO_UPDATE)
end
function LogicPeakGame:ReqPeakGameAllRatingInfo(forceUpdate)
  log(bWriteLog and "LogicPeakGame:ReqPeakGameAllRatingInfo forceUpdate = " .. tostring(forceUpdate))
  if not LogicPeakGameUtil.IsOpen() then
    log(bWriteLog and "LogicPeakGame:ReqPeakGameAllRatingInfo not open")
    return
  end
  if not forceUpdate and self.rating_info then
    log(bWriteLog and "LogicPeakGame:ReqPeakGameAllRatingInfo has cache")
    return
  end
  local PeakGameHandler = require("client.network.Protocol.PeakGameHandler")
  PeakGameHandler.send_get_peakgame_all_rating_info_req()
end
function LogicPeakGame:ReqPeakGameRatingInfo()
  log(bWriteLog and "LogicPeakGame:ReqPeakGameAllRatingInfo")
  if not LogicPeakGameUtil.IsOpen() then
    log(bWriteLog and "LogicPeakGame:ReqPeakGameRatingInfo not open")
    return
  end
  if self.rating_info then
    log(bWriteLog and "LogicPeakGame:ReqPeakGameRatingInfo has cache")
    return
  end
  local PeakGameHandler = require("client.network.Protocol.PeakGameHandler")
  PeakGameHandler.send_get_peakgame_rating_info_req()
end
function LogicPeakGame:OnGetPeakGameRatingInfoNotify(can_peakgame, rating_info)
  log(bWriteLog and "LogicPeakGame:OnGetPeakGameRatingInfoNotify")
  if self.peakgame_info then
    self.peakgame_info.  end
  if not can_peakgame then
    self.rating_info = nil
    DataMgr.roleData.peakgame_rating_info = nil
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local profile = logic_profile:GetLocalProfile(DataMgr.roleData.uid)
    if profile then
      profile.peakgame_segment_info = nil
    end
    EventSystem:postEvent(EVENTTYPE_PEAKGAME, EVENTID_PEAKGAME_RATING_NOTIFY)
    return
  end
  self:OnGetPeakGameRatingInfo(rating_info)
end
function LogicPeakGame:OnGetPeakGameRatingInfo(rating_info)
  log(bWriteLog and "LogicPeakGame:OnGetPeakGameRatingInfo")
  if not rating_info then
    log(bWriteLog and "LogicPeakGame:OnGetPeakGameRatingInfo no rating_info")
    return
  end
  if not LogicPeakGameUtil.IsOpen() then
    log(bWriteLog and "LogicPeakGame:OnGetPeakGameRatingInfo not open")
    return
  end
  self:CheckLevelUpSlap(rating_info)
  self.  DataMgr.roleData.peakgame_  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(DataMgr.roleData.uid)
  if profile then
    log_tree("LogicPeakGame:OnGetPeakGameRatingInfo 1 profile.peakgame_segment_info = ", profile.peakgame_segment_info)
    self:UpdateProfilePeakGameInfo(profile, rating_info)
    log_tree("LogicPeakGame:OnGetPeakGameRatingInfo 2 profile.peakgame_segment_info = ", profile.peakgame_segment_info)
  end
  local LogicPeakGameSegmentUtil = require("client.logic.PeakGame.LogicPeakGameSegmentUtil")
  local max_segment_id = LogicPeakGameSegmentUtil.GetSelfAllZoneCurSeasonMaxSegmentId()
  if not DataMgr.roleData.peakgame_history_max_segment then
    DataMgr.roleData.peakgame_history_max_segment = max_segment_id
  elseif max_segment_id and max_segment_id > DataMgr.roleData.peakgame_history_max_segment then
    DataMgr.roleData.peakgame_history_max_segment = max_segment_id
  end
  self:ShowLevelUpSlap()
  EventSystem:postEvent(EVENTTYPE_PEAKGAME, EVENTID_PEAKGAME_RATING_NOTIFY)
end
function LogicPeakGame:UpdateProfilePeakGameInfo(profile, rating_info)
  log(bWriteLog and "LogicPeakGame:UpdateProfilePeakGameInfo")
  local default_peakgame_profile = require("client.logic.PeakGame.default_peakgame_profile")
  local TableUtil = require("common.table_util")
  local new_default_peakgame_profile = TableUtil.CopyTable(default_peakgame_profile)
  profile.peakgame_segment_info = profile.peakgame_segment_info or {}
  profile.peakgame_segment_info.list = profile.peakgame_segment_info.list or new_default_peakgame_profile.list
  profile.peakgame_segment_info.curr_season_id = DataMgr.season_id
  local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
  local list = profile.peakgame_segment_info.list
  for i = 1, 6 do
    local rating, segment_id, max_segment_id, kd_v2, win_stat, win_week_stat
    if rating_info[i] and rating_info[i][PeakGameConfig.BattleType.Squad] then
      rating = rating_info[i][PeakGameConfig.BattleType.Squad].rating or PeakGameConfig.DefaultPeakGameRating
      segment_id = rating_info[i][PeakGameConfig.BattleType.Squad].segment_id or PeakGameConfig.DefaultPeakGameSegment
      max_segment_id = rating_info[i][PeakGameConfig.BattleType.Squad].max_segment_id or PeakGameConfig.DefaultPeakGameSegment
      kd_v2 = rating_info[i][PeakGameConfig.BattleType.Squad].kd_v2 or 0
      win_stat = rating_info[i][PeakGameConfig.BattleType.Squad].win_stat or {}
      win_week_stat = rating_info[i][PeakGameConfig.BattleType.Squad].win_week_stat or {}
    end
    list[i] = list[i] or {}
    list[i][PeakGameConfig.BattleType.Squad] = list[i][PeakGameConfig.BattleType.Squad] or {}
    list[i][PeakGameConfig.BattleType.Squad].    list[i][PeakGameConfig.BattleType.Squad].    list[i][PeakGameConfig.BattleType.Squad].    list[i][PeakGameConfig.BattleType.Squad].    list[i][PeakGameConfig.BattleType.Squad].    list[i][PeakGameConfig.BattleType.Squad].  end
end
function LogicPeakGame:ReqPeakGameTimeInfo(forceUpdate)
  log(bWriteLog and "LogicPeakGame:ReqPeakGameTimeInfo forceUpdate = " .. tostring(forceUpdate))
  if not LogicPeakGameUtil.IsOpen() then
    log(bWriteLog and "LogicPeakGame:ReqPeakGameTimeInfo not open")
    return
  end
  if not forceUpdate and self.peakgame_time_info then
    log(bWriteLog and "LogicPeakGame:ReqPeakGameTimeInfo has cache")
    return
  end
  local PeakGameHandler = require("client.network.Protocol.PeakGameHandler")
  PeakGameHandler.send_get_peakgame_time_req()
end
function LogicPeakGame:OnGetPeakGameTimeInfo(peakgame_time_info)
  log(bWriteLog and "LogicPeakGame:OnGetPeakGameTimeInfo")
  if not peakgame_time_info then
    log(bWriteLog and "LogicPeakGame:OnGetPeakGameTimeInfo no peakgame_time_info")
    return
  end
  if not LogicPeakGameUtil.IsOpen() then
    log(bWriteLog and "LogicPeakGame:OnGetPeakGameTimeInfo not open")
    return
  end
  self.  EventSystem:postEvent(EVENTTYPE_PEAKGAME, EVENTID_PEAKGAME_TIME_UPDATE)
end
function LogicPeakGame:IsPeakMode(submode)
  if not submode then
    return false
  end
  return LogicPeakGameUtil.IsPeakGameMode(submode)
end
function LogicPeakGame:ReqPeakGameChangeRankRuleInfo()
  log(bWriteLog and "LogicPeakGame:ReqPeakGameChangeRankRuleInfo")
  log_tree(bWriteLog and "LogicPeakGame.ReqPeakGameChangeRankRuleInfo peakgame_change_rank_rule_info = ", self.peakgame_change_rank_rule_info)
  if self.peakgame_change_rank_rule_info and self.peakgame_change_rank_rule_info.change_day_ts then
    return
  end
  local PeakGameHandler = require("client.network.Protocol.PeakGameHandler")
  PeakGameHandler.send_query_peak_game_change_day_req()
end
function LogicPeakGame:OnGetPeakGameChangeRankRuleInfo(peakgame_info)
  log(bWriteLog and "LogicPeakGame:OnGetPeakGameChangeRankRuleInfo")
  self.peakgame_change_rank_rule_info = peakgame_info
end
function LogicPeakGame:ResetAllCacheData()
  self.peakgame_info = nil
  self.peakgame_time_info = nil
  self.rating_info = nil
  self.peakSeasonId = nil
end
function LogicPeakGame:OnClassicSegmentChange()
  log(bWriteLog and "LogicPeakGame:OnClassicSegmentChange")
  self:ReqPeakGameInfo(true)
end
function LogicPeakGame:OnSeasonChange(_, _, bOnlineTran)
  log(bWriteLog and "LogicPeakGame:OnSeasonChange bOnlineTran = " .. tostring(bOnlineTran))
  if bOnlineTran then
    self:ReqPeakGameInfo(true)
  end
end
function LogicPeakGame:RequestNewAnchorName()
  print(bWriteLog and "LogicPeakGame:RequestNewAnchorName " .. self.peakgameHideName)
  if self.peakgameHideName == 1 then
    local SettingHandler = require("client.network.Protocol.SettingHandler")
    SettingHandler.send_gen_new_anchor_random_name(DataMgr.roleData.uid)
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicPeakGame = class(CModuleBase, nil, LogicPeakGame)
return CLogicPeakGame