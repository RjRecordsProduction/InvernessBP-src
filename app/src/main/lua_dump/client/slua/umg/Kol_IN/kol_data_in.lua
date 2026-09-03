local kol_data_in = {}
local kol_cfg_in = require("client.slua.umg.Kol_IN.kol_cfg_in")
local TimeUtil = require("client.common.time_util")
local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
local Util = require("client.slua_ui_framework.util")
local StringUtil = require("common.string_util")
local kol_handler = require("client.network.Protocol.kol_handler")
function kol_data_in:ctor()
  self.oldKolDataUpdateTimes = nil
  self.bKolSwitchOpen = false
  self.bOpenSeason = false
  self.seasonBeginTimer = nil
  self.bSeasonWarmup = false
  self.seasonEndTimer = nil
  self.bShowKolGuide = true
  self.curSeasonId = nil
  self.curSeasonCfg = nil
  self.curSeasonAllTeamCfg = nil
  self.curSeasonBeginToEndTime = nil
  self.curTeamId = nil
  self.curTeamCfg = nil
  self.teamIdCache = nil
  self.joinTeamTime = nil
  self.kol_list_this_week_data = nil
  self.kol_list_this_season_data = nil
  self.kol_list_historical_season_datas = nil
  self.kol_list_sub_tabId = nil
  self.my_kol_data = nil
  self.historySeasons = nil
  self.top_fans_data = nil
  self.team_detail_datas = nil
  self.curShowTeamIndex = nil
  self.teamDetailList = nil
  self.bShowBuinessCard = true
  self.team_top5_fans = nil
  self.bSeasonPage = false
  self.ClientVersionAndRegionStatus = kol_const.ClientVersionAndRegionStatus_Default
end
function kol_data_in:DefineAndResetData()
  self:ClearAll()
end
function kol_data_in:OnInitialize()
end
function kol_data_in:OnLogOut()
  self:ClearAll()
end
function kol_data_in:OnDestroy()
  self:ClearAll()
end
function kol_data_in:GetMyKolData()
  return self.my_kol_data
end
function kol_data_in:SetMyKolData(my_kol_data)
  self.end
function kol_data_in:SetMyKolAwardState(level, state)
  if self.my_kol_data and self.my_kol_data.award_status then
    self.my_kol_data.award_status[level] = state
  end
end
function kol_data_in:GetTopFansDatas()
  return self.top_fans_data
end
function kol_data_in:SetTopFansDatas(top_fans_data, user_top_fans_data)
  self.top_fans_data = {}
  self.top_fans_data.fansData = top_fans_data
  self.top_fans_data.userData = user_top_fans_data
end
function kol_data_in:GetCurTeamId()
  return self.curTeamId
end
function kol_data_in:GetCurTeamCfg()
  if self.curTeamId and not self.curTeamCfg then
    kol_handler.send_get_kol_list_req(self.curSeasonId)
    return kol_cfg_in.GetTeamCfgByTeamId(self.curTeamId)
  end
  return self.curTeamCfg
end
function kol_data_in:SetCurTeamCfg()
  if self.curTeamId and self.curSeasonAllTeamCfg and next(self.curSeasonAllTeamCfg) then
    for index, teamCfg in pairs(self.curSeasonAllTeamCfg) do
      if teamCfg.team_id == self.curTeamId then
        self.curTeamCfg = teamCfg
        log_tree("xcc kol_data_in:SetCurTeamCfg", self.curTeamCfg)
      end
    end
  end
end
function kol_data_in:GetCurSeasonAllTeamCfg()
  return self.curSeasonAllTeamCfg
end
function kol_data_in:GetCurSeasonOneTeamCfg(team_id)
  if self.curSeasonAllTeamCfg and next(self.curSeasonAllTeamCfg) then
    for index, teamCfg in pairs(self.curSeasonAllTeamCfg) do
      if team_id == teamCfg.team_id then
        return teamCfg
      end
    end
  end
end
function kol_data_in:SetCurSeasonAllTeamCfg(seasonAllTeamCfg)
  self.curSeasonAllTeamCfg = seasonAllTeamCfg
  self:SetCurTeamCfg()
  if self.curTeamId then
    self:GetMyKolPageTeamData()
  end
end
function kol_data_in:GetCurSeasonId()
  return self.curSeasonId
end
function kol_data_in:GetCurSeasonCfg()
  return self.curSeasonCfg
end
function kol_data_in:GeturSeasonBeginToEndTime()
  return self.curSeasonBeginToEndTime or ""
end
function kol_data_in:GetThisSeasonKolData()
  return self.kol_list_this_season_data
end
function kol_data_in:GetThisWeekKolData()
  return self.kol_list_this_week_data
end
function kol_data_in:GetHistoryKolData(season_id, bOnlyGetData)
  if season_id then
    if self.kol_list_historical_season_datas[season_id] then
      return self.kol_list_historical_season_datas[season_id]
    elseif not bOnlyGetData then
      kol_handler.send_get_history_season_rank_req(season_id)
    end
  end
end
function kol_data_in:GetSeasonWarmup()
  return self.bSeasonWarmup
end
function kol_data_in:GetSeasonOpen()
  return self.bOpenSeason
end
function kol_data_in:GetShowKolGuide()
  return self.bShowKolGuide
end
function kol_data_in:SetThisWeekOrSeasonKolData(kolData, userData)
  self:RankSort(kolData, userData)
  if self.kol_list_sub_tabId == kol_const.page_id_kol_list_this_season then
    self.kol_list_this_season_data = {}
    self.kol_list_this_season_data.    self.kol_list_this_season_data.  elseif self.kol_list_sub_tabId == kol_const.page_id_kol_list_this_week then
    self.kol_list_this_week_data = {}
    self.kol_list_this_week_data.    self.kol_list_this_week_data.  end
  self:UpdateTimeWhenGetServerDataSuccess(self.kol_list_sub_tabId)
  self.kol_list_sub_tabId = nil
end
function kol_data_in:GetNewTeamDataByType(type)
  local teamDatas
  if type == kol_const.page_id_kol_list_this_season then
    teamDatas = self.kol_list_this_season_data and self.kol_list_this_season_data.kolData
  elseif type == kol_const.page_id_kol_list_this_week then
    teamDatas = self.kol_list_this_week_data and self.kol_list_this_week_data.kolData
  end
  for index, data in pairs(teamDatas or {}) do
    if data.team_id == self.curTeamId then
      return data
    end
  end
end
function kol_data_in:SetHistoryKolData(kolData, userData, season_id)
  self:RankSort(kolData, userData)
  self.kol_list_historical_season_datas[season_id] = {}
  self.kol_list_historical_season_datas[season_id].  self.kol_list_historical_season_datas[season_id].end
function kol_data_in:RankSort(rankDatas, userData)
  for key, value in pairs(rankDatas or {}) do
    value.rank_no = key
    if userData and value.team_id == userData.team_id then
      userData.rank_no = key
    end
  end
end
function kol_data_in:SetTeamTop5FansList(team_id, fans_list)
  if fans_list and next(fans_list) then
    self.team_top5_fans[team_id] = fans_list
  end
end
function kol_data_in:GetTop5FansByTeamId(team_id)
  if self.team_top5_fans[team_id] then
    return self.team_top5_fans[team_id]
  end
end
function kol_data_in:GetShortString(num)
  if num then
    return StringUtil.GetShortStringByNum(num)
  end
  return "-"
end
function kol_data_in:GetClientVersionAndRegionStatus()
  return self.ClientVersionAndRegionStatus
end
function kol_data_in:SetClientVersionAndRegionStatus()
  self:ClearAll()
  self:InitAll()
end
function kol_data_in:InitData()
  self.ClientVersionAndRegionStatus = kol_cfg_in.GetClientVersionAndRegionStatus()
  log(bWriteLog and "xcc kol_data_in.InitData ClientVersionAndRegionStatus: " .. tostring(self.ClientVersionAndRegionStatus))
  if self.ClientVersionAndRegionStatus == kol_const.ClientVersionAndRegionStatus_Default then
    return false
  end
  self.bKolSwitchOpen = LobbySystem.CheckOpen(BP_ENUM_MODULE_KOL_RANK_OPEN)
  if not self.bKolSwitchOpen then
    log(bWriteLog and "xcc kol_data_in.InitData bKolSwitchOpen: false")
    return false
  end
  local season_id
  self.bSeasonWarmup, season_id = self:CheckSeasonWarmup()
  if self.bSeasonWarmup then
    self.curSeasonId = season_id
    log(bWriteLog and "xcc kol_data_in.InitData bSeasonWarmup season_id: " .. tostring(season_id) .. "")
  end
  self.curTeamId = DataMgr.roleData.kol_leaderboard and DataMgr.roleData.kol_leaderboard.team_id
  self.bOpenSeason, season_id = self:CheckSeasonOpen()
  if self.bOpenSeason then
    self.curSeasonId = season_id
    log(bWriteLog and "xcc kol_data_in.InitData bOpenSeason season_id: " .. tostring(season_id) .. "")
  end
  if not self.bSeasonWarmup and not self.bOpenSeason then
    self.curSeasonId = nil
    log(bWriteLog and "xcc kol_data_in.InitData bSeasonEnd: true")
  end
  if self.curSeasonId then
    self.curSeasonCfg = kol_cfg_in.GetSeasonCfgBySeasonId(self.curSeasonId)
    kol_handler.send_get_kol_list_req(self.curSeasonId)
  else
    self.curSeasonCfg = self:GetPreSeasonCfg()
    self.curSeasonId = self.curSeasonCfg and self.curSeasonCfg.season_id or 1
    kol_handler.send_get_kol_list_req(self.curSeasonId)
  end
  if self.curSeasonCfg then
    local beginTime = TimeUtil.TimeStringToUnixstamp(self.curSeasonCfg.beginTime)
    local endTime = TimeUtil.TimeStringToUnixstamp(self.curSeasonCfg.endTime)
    self.curSeasonBeginToEndTime = string.format("%s-%s", TimeUtil.FormatTime_YMDHM(beginTime, true), TimeUtil.FormatTime_YMDHM(endTime, true))
  end
  local kolCacheData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eKolCacheData)
  if kolCacheData and kolCacheData.bShowKolGuide ~= nil then
    self.bShowKolGuide = kolCacheData.bShowKolGuide
  end
  self.kol_list_historical_season_datas = {}
  self.team_detail_datas = {}
  self.oldKolDataUpdateTimes = {}
  self.joinTeamTime = {}
  self.team_top5_fans = {}
  self:AddOrRemoveReddot(true)
end
function kol_data_in:ClearData()
  self.bKolSwitchOpen = false
  self.bOpenSeason = false
  self.seasonBeginTimer = nil
  self.bSeasonWarmup = false
  self.seasonEndTimer = nil
  self.bShowKolGuide = true
  self.curSeasonId = nil
  self.curSeasonCfg = nil
  self.curSeasonAllTeamCfg = nil
  self.curSeasonBeginToEndTime = nil
  self.curTeamId = nil
  self.curTeamCfg = nil
  self.teamIdCache = nil
  self.kol_list_this_week_data = nil
  self.kol_list_this_season_data = nil
  self.kol_list_historical_season_datas = nil
  self.kol_list_sub_tabId = nil
  self.my_kol_data = nil
  self.historySeasons = nil
  self.top_fans_data = nil
  self.team_detail_datas = nil
  self.curShowTeamIndex = nil
  self.teamDetailList = nil
  self.bShowBuinessCard = true
  self.joinTeamTime = nil
  self.oldKolDataUpdateTimes = nil
  self.ClientVersionAndRegionStatus = kol_const.ClientVersionAndRegionStatus_Default
end
function kol_data_in:InitBeginTimer()
  if not self.seasonBeginTimer and self.curSeasonCfg and self.bSeasonWarmup then
    log(bWriteLog and "xcc kol_data_in:InitBeginTimer " .. self.curSeasonCfg.beginTime)
    local beginTime = TimeUtil.TimeStringToUnixstamp(self.curSeasonCfg.beginTime)
    local delayTime = tonumber(beginTime - TimeUtil.GetServerTimeInSec())
    self.seasonBeginTimer = self:AddTimerOnce(delayTime, function()
      self:ClearAll()
      self:InitAll()
      log(bWriteLog and "xcc kol_data_in:InitBeginTimer end")
    end)
    log(bWriteLog and "xcc kol_data_in:InitBeginTimer delayTime" .. tostring(delayTime))
  end
end
function kol_data_in:InitEndTimer()
  if not self.seasonEndTimer and self.curSeasonCfg and self.bOpenSeason then
    log(bWriteLog and "xcc kol_data_in:InitEndTimer " .. self.curSeasonCfg.endTime)
    local endTime = TimeUtil.TimeStringToUnixstamp(self.curSeasonCfg.endTime)
    local delayTime = tonumber(endTime - TimeUtil.GetServerTimeInSec())
    self.seasonEndTimer = self:AddTimerOnce(delayTime, function()
      self:AddOrRemoveReddot(false)
      self:ClearAll()
      self:InitAll()
      EventSystem:postEvent(EVENTTYPE_KOL_IN, EVENTID_KOL_PAGE_REFRESH_IN)
      self.historySeasons = nil
      log(bWriteLog and "xcc kol_data_in:InitEndTimer end")
    end)
    log(bWriteLog and "xcc kol_data_in:InitEndTimer delayTime" .. tostring(delayTime))
  end
end
function kol_data_in:InitWarmupTimer()
  if self.ClientVersionAndRegionStatus ~= kol_const.ClientVersionAndRegionStatus_Default and not self.seasonWarmupTimer and not self.bSeasonWarmup and not self.bOpenSeason then
    local cfg = self:GetNextSeasonCfg()
    if cfg then
      local endTime = TimeUtil.TimeStringToUnixstamp(cfg.warmupTime)
      local delayTime = tonumber(endTime - TimeUtil.GetServerTimeInSec())
      self.seasonWarmupTimer = self:AddTimerOnce(delayTime, function()
        self:ClearAll()
        self:InitAll()
        log(bWriteLog and "xcc kol_data_in:InitWarmupTimer end")
      end)
      log(bWriteLog and "xcc kol_data_in:InitWarmupTimer delayTime" .. tostring(delayTime))
    end
  end
end
function kol_data_in:ClearBeginTimer()
  if self.seasonBeginTimer then
    self:RemoveTimer(self.seasonBeginTimer)
    self.seasonBeginTimer = nil
    log(bWriteLog and "xcc kol_data_in:ClearBeginTimer")
  end
end
function kol_data_in:ClearEndTimer()
  if self.seasonEndTimer then
    self:RemoveTimer(self.seasonEndTimer)
    self.seasonEndTimer = nil
    log(bWriteLog and "xcc kol_data_in:ClearEndTimer")
  end
end
function kol_data_in:ClearWarmupTimer()
  if self.seasonWarmupTimer then
    self:RemoveTimer(self.seasonWarmupTimer)
    self.seasonWarmupTimer = nil
    log(bWriteLog and "xcc kol_data_in:ClearWarmupTimer")
  end
end
function kol_data_in:ClearAll()
  self:ClearBeginTimer()
  self:ClearEndTimer()
  self:ClearWarmupTimer()
  self:ClearData()
end
function kol_data_in:InitAll()
  self:InitData()
  self:InitBeginTimer()
  self:InitWarmupTimer()
  self:InitEndTimer()
end
function kol_data_in:CheckSeasonOpen()
  if self.ClientVersionAndRegionStatus == kol_const.ClientVersionAndRegionStatus_Default or not self.bKolSwitchOpen then
    return false
  end
  local seasonCfg = kol_cfg_in.GetAllSeasonCfg()
  for season_id, cfg in pairs(seasonCfg) do
    if TimeUtil.CheckAfterTimeStr(cfg.beginTime) and not TimeUtil.CheckAfterTimeStr(cfg.endTime) then
      return true, cfg.season_id
    end
  end
  return false
end
function kol_data_in:CheckSeasonWarmup()
  if self.ClientVersionAndRegionStatus == kol_const.ClientVersionAndRegionStatus_Default or not self.bKolSwitchOpen then
    return false
  end
  local seasonCfg = kol_cfg_in.GetAllSeasonCfg()
  for season_id, cfg in pairs(seasonCfg) do
    if TimeUtil.CheckAfterTimeStr(cfg.warmupTime) and not TimeUtil.CheckAfterTimeStr(cfg.beginTime) then
      return true, cfg.season_id
    end
  end
  return false
end
function kol_data_in:CheckLobbyEntranceOpen()
  if self.ClientVersionAndRegionStatus == kol_const.ClientVersionAndRegionStatus_Default or not self.bKolSwitchOpen then
    return false
  end
  if self.bSeasonWarmup or self.bOpenSeason then
    return true
  end
  if self.curSeasonCfg then
    return true
  end
  return false
end
function kol_data_in:CheckSeasonEnd()
  return not self.bSeasonWarmup and not self.bOpenSeason
end
function kol_data_in:KolGuideComplete()
  local kolCacheData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eKolCacheData) or {}
  kolCacheData.bShowKolGuide = false
  self.bShowKolGuide = false
  PlayerPrefsSystem.SaveTableToFile_N(kolCacheData, PlayerPrefsSystem.ePlayerPrefsType.eKolCacheData)
end
function kol_data_in:CheckCanShowWarmupGuide()
  if self.bSeasonWarmup and not UIManager.IsUIShow(UIManager.UI_Config.Common_Popup_Reward_Base) then
    local cache = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eKolCacheData) or {}
    local versionData = cache.VersionData and cache.VersionData[self.ClientVersionAndRegionStatus] and cache.VersionData[self.ClientVersionAndRegionStatus][self.curSeasonId]
    if versionData and versionData.warmUpGuide then
      return false
    else
      cache.VersionData = cache.VersionData or {}
      cache.VersionData[self.ClientVersionAndRegionStatus] = cache.VersionData[self.ClientVersionAndRegionStatus] or {}
      cache.VersionData[self.ClientVersionAndRegionStatus][self.curSeasonId] = cache.VersionData[self.ClientVersionAndRegionStatus][self.curSeasonId] or {}
      cache.VersionData[self.ClientVersionAndRegionStatus][self.curSeasonId].warmUpGuide = true
      PlayerPrefsSystem.SaveTableToFile_N(cache, PlayerPrefsSystem.ePlayerPrefsType.eKolCacheData)
      return true
    end
  end
  return false
end
function kol_data_in:CheckCanShowLobbyKolTip()
  if self.bSeasonWarmup and not self.curTeamId then
    local kolCacheData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eKolCacheData) or {}
    local oldShowTime = kolCacheData.oldShowTime
    local curTime = TimeUtil.GetServerTimeInSec()
    if not oldShowTime or not TimeUtil.IsSameDay(curTime, oldShowTime) then
      kolCacheData.oldShowTime = curTime
      PlayerPrefsSystem.SaveTableToFile_N(kolCacheData, PlayerPrefsSystem.ePlayerPrefsType.eKolCacheData)
      return true
    end
  end
  return false
end
function kol_data_in:GetTabDataByKolHandler(tabId, subTabId)
  if tabId == kol_const.page_id_my_kol then
    self:GetMyKolPageTeamData()
  elseif tabId == kol_const.page_id_top_fans then
    if self:CheckCanGetServerData(kol_const.page_id_top_fans) then
      kol_handler.send_get_top_fans_req()
    end
  elseif tabId == kol_const.page_id_kol_list then
    if subTabId and subTabId == kol_const.page_id_kol_list_historical_season or self:CheckSeasonEnd() then
      local season = self:GetPreSeasonCfg()
      self:GetHistoryKolData(season and season.season_id or 1)
    elseif self.bOpenSeason then
      local index = subTabId and subTabId == kol_const.page_id_kol_list_this_season and 1 or 2
      if self:CheckCanGetServerData(subTabId) then
        kol_handler.send_get_kol_ranks_req(index)
      end
      self.kol_list_sub_tabId = subTabId or kol_const.page_id_kol_list_this_week
    end
  end
end
function kol_data_in:GetNextSeasonCfg()
  local seasonCfg = kol_cfg_in.GetAllSeasonCfg()
  for _, cfg in pairs(seasonCfg) do
    if not TimeUtil.CheckAfterTimeStr(cfg.warmupTime) then
      return cfg
    end
  end
end
function kol_data_in:GetPreSeasonCfg()
  local seasonCfg = kol_cfg_in.GetAllSeasonCfg()
  local season
  for _, cfg in pairs(seasonCfg) do
    if TimeUtil.CheckAfterTimeStr(cfg.endTime) and (not season or season.season_id < cfg.season_id) then
      season = cfg
    end
  end
  return season
end
function kol_data_in:GetPreAllSeasonCfg()
  local seasonCfg = kol_cfg_in.GetAllSeasonCfg()
  local seasons = {}
  for _, cfg in pairs(seasonCfg) do
    if TimeUtil.CheckAfterTimeStr(cfg.endTime) then
      table.insert(seasons, {
        config = cfg,
        text = string.format("S%s", cfg.season_id)
      })
    end
  end
  table.sort(seasons, function(a, b)
    return a.config.season_id > b.config.season_id
  end)
  return seasons
end
function kol_data_in:GetMyKolPageTeamData()
  if self.curTeamId and self:CheckCanGetServerData(self.curTeamId) then
    kol_handler.send_get_kol_detail_req(self.curTeamId)
    kol_handler.send_get_kol_topfans5_req(self.curTeamId)
    self.bShowBuinessCard = false
  end
  kol_handler.send_get_user_homepage_req()
end
function kol_data_in:JoinTeamByTeamId(team_id)
  log(bWriteLog and "xcc kol_data_in:JoinTeamByTeamId")
  if self.curTeamId then
    ShowNotice(20010004)
    return
  end
  local serverTime = FuncUtil.GetServerTimeInSec()
  local len = self.joinTeamTime and next(self.joinTeamTime) and #self.joinTeamTime or 0
  if 3 <= len then
    local beginTime = self.joinTeamTime[len - 2]
    local endTime = self.joinTeamTime[len]
    if endTime - beginTime < 3600 then
      ShowNotice(19810127)
      return
    end
  end
  table.insert(self.joinTeamTime, serverTime)
  kol_handler.send_join_kol_team_req(team_id)
  self.teamIdCache = team_id
end
function kol_data_in:JoinTeamHandler()
  self.curTeamId = self.teamIdCache
  self.teamIdCache = nil
  self:SetCurTeamCfg()
  self:GetMyKolPageTeamData()
  EventSystem:postEvent(EVENTTYPE_KOL_IN, EVENTID_KOL_TEAM_CHANGE_IN, self.curTeamId)
  EventSystem:postEvent(EVENTTYPE_KOL_IN, EVENTID_KOL_PAGE_REFRESH_IN)
  ShowNotice(20010020)
  if DataMgr.roleData.kol_leaderboard then
    DataMgr.roleData.kol_leaderboard.team_id = self.curTeamId
  end
end
function kol_data_in:ExitTeamWithTeamId()
  log(bWriteLog and "xcc kol_data_in:ExitTeamWithTeamId")
  if not self.curTeamId then
    ShowNotice(505070)
    return
  end
  if self.bOpenSeason then
    local config = kol_cfg_in.GetOneOtherCfgByName("season_week_leave_restriction_start")
    local limitWeek = config and config.value or 0
    if 0 < limitWeek then
      local limitTime = TimeUtil.TimeStringToUnixstamp(self.curSeasonCfg.beginTime) + 604800 * (limitWeek - 1)
      if limitTime < TimeUtil.GetServerTimeInSec() then
        ShowNotice(20010005)
        return
      end
    end
    kol_handler.send_leave_kol_team_req(self.curTeamId)
  end
end
function kol_data_in:ExitTeamHandler()
  self.curTeamId = nil
  self.curTeamCfg = nil
  EventSystem:postEvent(EVENTTYPE_KOL_IN, EVENTID_KOL_TEAM_CHANGE_IN)
  EventSystem:postEvent(EVENTTYPE_KOL_IN, EVENTID_KOL_PAGE_REFRESH_IN)
  ShowNotice(20010021)
  if DataMgr.roleData.kol_leaderboard then
    DataMgr.roleData.kol_leaderboard.team_id = nil
  end
  self.oldKolDataUpdateTimes = {}
end
function kol_data_in:GetCurTeamDetailData(team_id, index)
  if team_id then
    self.curShowTeamIndex = index
    self.bShowBuinessCard = true
    if self:CheckCanGetServerData(team_id) then
      kol_handler.send_get_kol_detail_req(team_id)
      kol_handler.send_get_kol_topfans5_req(team_id)
    elseif self.team_detail_datas[team_id] then
      self:ShowBusinessCard(self.team_detail_datas[team_id])
    end
  end
end
function kol_data_in:GetOneTeamDetailByTeamId(team_id)
  if team_id and self.team_detail_datas[team_id] then
    return self.team_detail_datas[team_id]
  end
end
function kol_data_in:ResetCurShowTeamIndex()
  self.curShowTeamIndex = nil
  self.teamDetailList = nil
  self.bShowBuinessCard = false
end
function kol_data_in:ChangeBusinessCard(diff)
  if self.teamDetailList and self.curShowTeamIndex then
    self.curShowTeamIndex = self.curShowTeamIndex + diff
    local teamCfg = self.teamDetailList[self.curShowTeamIndex]
    self:GetCurTeamDetailData(teamCfg.team_id, self.curShowTeamIndex)
  end
end
function kol_data_in:SetShowTeamDetailList(teamDetailList, bSeasonPage)
  self.  self.end
function kol_data_in:CheckCanShowSwitcher(bNext)
  if bNext and self.teamDetailList and self.curShowTeamIndex and self.curShowTeamIndex < #self.teamDetailList then
    return true
  elseif bNext == false and self.teamDetailList and self.curShowTeamIndex and self.curShowTeamIndex > 1 then
    return true
  end
  return false
end
function kol_data_in:ShowBusinessCard(detailData)
  self.team_detail_datas[detailData.team_id] = detailData
  if not self.bShowBuinessCard then
  elseif not UIManager.IsUIShow(UIManager.UI_Config.kol_business_card_in) then
    UIManager.ShowUI(UIManager.UI_Config.kol_business_card_in, detailData)
  else
    EventSystem:postEvent(EVENTTYPE_KOL_IN, EVENTID_KOL_DETAIL_CHANGE_IN, detailData)
  end
end
function kol_data_in:ApplyShowUserHistorySeason(fromIndex, count)
  if not fromIndex or not count then
    self:ShowUserHistorySeason(nil)
  end
  if not self.historySeasons or not next(self.historySeasons) then
    kol_handler.send_get_user_historical_records_req(fromIndex, count)
    return
  end
  self:ShowUserHistorySeason(self.historySeasons)
end
function kol_data_in:ShowUserHistorySeason(seasonDatas)
  self.historySeasons = seasonDatas or self.historySeasons
  log_tree("xcc kol_data_in:ShowUserHistorySeason", seasonDatas or {})
  UIManager.ShowUI(UIManager.UI_Config.kol_user_history_season, seasonDatas)
end
function kol_data_in:CheckCanGetServerData(id)
  if id and self.oldKolDataUpdateTimes then
    local time = TimeUtil:GetServerTimeInSec()
    if self.oldKolDataUpdateTimes[id] and time - self.oldKolDataUpdateTimes[id] < kol_const.kol_data_refresh_time then
      return false
    end
  end
  return true
end
function kol_data_in:UpdateTimeWhenGetServerDataSuccess(id, newTime)
  if self.oldKolDataUpdateTimes and id then
    local time = newTime or TimeUtil:GetServerTimeInSec()
    self.oldKolDataUpdateTimes[id] = time
  end
end
function kol_data_in:GetOtherPlayersProfiles(playerDatas)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local playerList = {}
  for key, value in pairs(playerDatas or {}) do
    local uid = type(value) == "table" and value.uid or value
    local profile = logic_profile:GetLocalProfile(uid)
    if not profile then
      table.insert(playerList, tonumber(uid))
    end
  end
  if next(playerList) then
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetRankProfiles(Enum_PROFILE_REPORT_CFG.KOL_RANK_IN, playerList, function(list)
      if list and next(list) then
        EventSystem:postEvent(EVENTTYPE_KOL_IN, EVENTID_KOL_TOP_FANS)
      end
    end)
  end
end
function kol_data_in:AddOrRemoveReddot(bAdd)
  if not self.bOpenSeason and not self.bSeasonWarmup then
    log(bWriteLog and "xcc kol_data_in:AddOrRemoveReddot season has be ended")
    return
  end
  local time = TimeUtil:GetServerTimeInSec()
  local kol_reddot_config = require("client.slua.umg.Kol_IN.kol_reddot_config")
  local kolCacheData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eKolCacheData) or {}
  local reddotData = kolCacheData.reddotData or {}
  reddotData[self.curSeasonId] = reddotData[self.curSeasonId] or {
    [kol_const.kol_reddot_warmup] = {},
    [kol_const.kol_reddot_open] = {}
  }
  local reddot_const = (not self.bSeasonWarmup or not kol_const.kol_reddot_warmup) and self.bOpenSeason and kol_const.kol_reddot_open
  local data = reddotData[self.curSeasonId] and reddotData[self.curSeasonId][reddot_const]
  if bAdd and data.beginTime and not data.endTime then
    kol_reddot_config.AddReddot(reddot_const)
  elseif bAdd and not data.beginTime then
    data.beginTime = time
    kol_reddot_config.AddReddot(reddot_const)
  elseif not bAdd and data.beginTime and not data.endTime then
    data.endTime = time
    kol_reddot_config.RemoveReddot(reddot_const)
  end
  kolCacheData.  PlayerPrefsSystem.SaveTableToFile_N(kolCacheData, PlayerPrefsSystem.ePlayerPrefsType.eKolCacheData)
end
function kol_data_in:PlayVoiceAndReportTlog(team, widget)
  local teamCfg = kol_cfg_in.GetTeamCfgByTeamId(team and team.team_id) or {}
  if teamCfg.kol_voice_list and teamCfg.kol_voice_list ~= "" then
    local id_list = StringUtil.Split(teamCfg.kol_voice_list, "|")
    local index = math.random(1, #id_list)
    local voice_id = tonumber(id_list[index])
    log(bWriteLog and "xcc kol_data_in:PlayVoiceAndReportTlog voice_id: " .. tostring(voice_id) .. "")
    local ActorVoiceSystem = require("client.slua.logic.actor_voice.logic_actor_voice")
    ActorVoiceSystem.PlayMultiLanguageSound(voice_id, widget)
    local TLogReasonStrTable = {
      TeamID = team.team_id
    }
    local TLogReasonStr = json.encode(TLogReasonStrTable)
    log(bWriteLog and "xcc kol_data_in:PlayVoiceAndReportTlog TLogReasonStr: " .. tostring(TLogReasonStr) .. "")
    ClientSendTLogReport(TLogEventDefine.kol_voice_click, 0, TLogReasonStr)
    return voice_id
  end
end
function kol_data_in:SetImageShowByModuleName(widget, module_name)
  local imageConfigs = kol_cfg_in.GetImageConfigsByModuleName(module_name, self.curSeasonId)
  for root_name, bg_path in pairs(imageConfigs) do
    if widget[root_name] then
      Util.SetTexture(widget[root_name], bg_path)
    end
  end
end
function kol_data_in:CheckNeedExHandle(type)
  local state = self:GetClientVersionAndRegionStatus()
  if type == kol_const.Ex_Not_History then
    return state == kol_const.ClientVersionAndRegionStatus_JP or state == kol_const.ClientVersionAndRegionStatus_KR
  elseif type == kol_const.Ex_Not_History_Score then
    return state == kol_const.ClientVersionAndRegionStatus_IN
  end
  return false
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Ckol_data_in = class(CModuleBase, nil, kol_data_in)
return Ckol_data_in