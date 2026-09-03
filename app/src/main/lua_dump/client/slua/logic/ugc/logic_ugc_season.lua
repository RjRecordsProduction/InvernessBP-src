local Logic_UGC_Season = {
  WOWSeasonTimeConfig = {},
  UGCSegmentData = {},
  UGCSeasonID = 0,
  SegmentCfg = {},
  tmp_begin_timestamp = 0,
  tmp_end_timestamp = 0,
  temp_season_index = 0,
  SegmentMax = 1,
  wow_season_in_reward = {},
  wow_season_rating = {},
  wow_best_segment = 0,
  season_in_reward = {},
  C_MatchModDefaultNum = 0,
  C_MatchImagePath = "/Game/UMG/Texture_200/Lobby_NoAtlas/Ugc/MapEntrance/type/Lobby_match_MapEntrance_Ugc_004.Lobby_match_MapEntrance_Ugc_004",
  MatchModMap = nil,
  MatchModIDList = nil,
  bSegmentUp = false,
  AchievementData = nil,
  BModUpdate = false,
  ChangeModTable = {},
  StoreItemList = nil,
  UGC_season_ad_score = 0,
  BannerShowList = {}
}
local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
local TableUtil = require("common.table_util")
function Logic_UGC_Season:OnInitialize()
  self.SegmentCfg = CDataTable.GetTable("UGCSegmentData")
  if self.SegmentCfg then
    for index, value in pairs(self.SegmentCfg) do
      if value.segment_id > self.SegmentMax then
        self.SegmentMax = value.segment_id
      end
    end
  end
  self:ReqGetUGCSeasonCfgData()
end
function Logic_UGC_Season:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_NEXTDAY, EVENTID_NEXTDAY_ZERO, self.OnNextDayZeroCome, self)
end
function Logic_UGC_Season:OnLogOut()
  self.WOWSeasonTimeConfig = nil
  self.UGCSegmentData = nil
  self.SegmentCfg = nil
  self.bSegmentUp = false
  self.AchievementData = nil
  self.BModUpdate = false
  self.ChangeModTable = nil
  self.StoreItemList = nil
  self.UGCSeasonData = {}
  self.BannerShowList = {}
  self.ThemeData = {}
  self.allFriendList = nil
end
function Logic_UGC_Season:OnLogin(bReLogin)
  self.AchievementData = nil
end
function Logic_UGC_Season:OnPostSwitchGameStatus(per, next)
  if per == GameStatus.Fighting and next == GameStatus.Lobby then
    log(bWriteLog and "[v_yibxu] Logic_UGC_Season:OnPostSwitchGameStatus")
    self.AchievementData = nil
  end
end
function Logic_UGC_Season:InitMatchModInfoList()
  local MatchModInfoList = {}
  for k, ModInfo in pairs(self.MatchModMap) do
    table.insert(MatchModInfoList, ModInfo)
  end
  table.sort(MatchModInfoList, function(a, b)
    if a.sort_id == b.sort_id then
      return a.mod_id > b.mod_id
    else
      return a.sort_id < b.sort_id
    end
  end)
  self.MatchModIDList = {}
  for k, ModInfo in ipairs(MatchModInfoList) do
    table.insert(self.MatchModIDList, ModInfo.mod_id)
  end
  if LobbySystem.CheckOpen(BP_ENUM_UGC_SEGMENT_SWITCH) and self.UGCSeasonID ~= 0 then
    self:SetBannerList()
    log(bWriteLog and "Logic_UGC_Season:InitMatchModInfoList self.UGCSeasonID = " .. tostring(self.UGCSeasonID))
  else
    log(bWriteLog and "Logic_UGC_Season:InitMatchModInfoList \232\181\155\229\173\163\230\156\170\229\188\128\229\144\175")
  end
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local ReqIdList = TableUtil.CopyTable(self.MatchModIDList)
  if self.HistoryMatchModList then
    for _, ModId in pairs(self.HistoryMatchModList) do
      table.insert(ReqIdList, ModId)
    end
  end
  local ModInfoList, ReqList = LogicUGC:BatchGetModInfo(ReqIdList, LogicUGC.C_ModListTypes.Season)
  if ModInfoList and next(ModInfoList) and (not ReqList or not (0 < #ReqList)) then
    self:OnModInfoBatchRsp(ModInfoList, LogicUGC.C_ModListTypes.Season)
  end
  self:RefreshMatchBanList()
end
function Logic_UGC_Season:GetAllModIDList()
  return self.MatchModIDList
end
function Logic_UGC_Season:GetSelectModList()
  if not self.MatchModIDList then
    return nil
  end
  local BanList = self:GetMatchBanList()
  local SelectList = {}
  for _, ModID in ipairs(self.MatchModIDList) do
    if not BanList[ModID] then
      table.insert(SelectList, ModID)
    end
  end
  return SelectList
end
function Logic_UGC_Season:GetSelectBundleName()
  return LocUtil.GetLocalizeResStr(79488)
end
function Logic_UGC_Season:GetSelectBundlePic()
  local UGCSeasonCfg = self:GetUGCSeasonCfg()
  if UGCSeasonCfg and UGCSeasonCfg.mod_pic_url and UGCSeasonCfg.mod_pic_url ~= "" then
    return UGCSeasonCfg.mod_pic_url
  end
  return self.C_MatchImagePath
end
function Logic_UGC_Season:GetSelectBundleModList()
  if not self.MatchModMap then
    return nil
  end
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local ModList = {}
  local BanList = self.GetMatchBanList and self:GetMatchBanList() or {}
  for ModID, _ in pairs(self.MatchModMap) do
    if not BanList[ModID] then
      local ModInfo = LogicUGC:GetModByAllCache(ModID)
      if ModInfo then
        table.insert(ModList, ModID)
      end
    end
  end
  return ModList
end
function Logic_UGC_Season:CheckModListReady()
  if not self.MatchModMap then
    self:ReqQuerySeasonRank()
    return false
  end
  return true
end
function Logic_UGC_Season:ReqGetUGCSeasonData()
  log(bWriteLog and "[v_yibxu] Logic_UGC_Season:ReqGetUGCSeasonData")
  self:ReqQuerySeasonRank()
end
function Logic_UGC_Season:ReqGetUGCSeasonCfgData()
  log(bWriteLog and "[v_yibxu] Logic_UGC_Season:ReqGetUGCSeasonCfgData")
  local RspGetUGCSeasonData = function(_, WOWSeasonTimeConfig)
    log(bWriteLog and "[v_yibxu]  Logic_UGC_Season:RspGetUGCSeasonData")
    if not WOWSeasonTimeConfig then
      log(bWriteLog and "[v_yibxu] Logic_UGC:ReqGetUGCSeasonCfgData WOWSeasonTimeConfig is nil")
      return
    end
    self.    self.UGCSeasonID = self:get_cur_season_index()
    self:AddTimerOnce(0.1, function()
      EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_GET_SEASON_CONFIG)
    end)
  end
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  BasicDataServerTable:GetOrReqData(data_config_marco.ugc_wowseason_rating_time_cfg, RspGetUGCSeasonData)
end
function Logic_UGC_Season:ReqQuerySeasonRank()
  if not LobbySystem.CheckOpen(BP_ENUM_UGC_SEGMENT_SWITCH) then
    return
  end
  print(bWriteLog and "Logic_UGC_Season:ReqQuerySeasonRank")
  if self:IsDuringSeasonFrozen() or self:IsBeforeS4LegacyAPIEnabled() then
    log(bWriteLog and "Logic_UGC_Season:ReqQuerySeasonRank is during season frozen")
    return
  end
  if self.UGCSeasonID == 0 then
    return
  end
  if self:IsBeforeS4LegacyAPIEnabled() then
    self:SetBannerList()
  end
end
function Logic_UGC_Season:OnQuerySeasonRankRsp(SeasonID, ModList)
  local ModTable = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCSeasonModUpdate)
  if not ModTable or not next(ModTable) then
    PlayerPrefsSystem.SaveTableToFile_N(ModList, PlayerPrefsSystem.ePlayerPrefsType.eUGCSeasonModUpdate)
  else
    self.ChangeModTable = {}
    for key, value in pairs(ModList) do
      if not ModTable[key] then
        self.ChangeModTable[key] = value
      end
    end
    if next(self.ChangeModTable) then
      self.BModUpdate = true
      log_tree(" Logic_UGC_Season:OnQuerySeasonRankRsp ChangeModTable = ", self.ChangeModTable)
      self.MatchBanList = ModList
      self:SetMatchBanList()
      if not self:IsBeforeS4LegacyAPIEnabled() then
        local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
        PlayerPrefsSystem.SaveTableToFile_N(ModList, PlayerPrefsSystem.ePlayerPrefsType.eUGCSeasonModUpdate)
      end
    else
      self.BModUpdate = false
      log_tree(" Logic_UGC_Season:OnQuerySeasonRankRsp ModTable = ", ModTable)
      log_tree(" Logic_UGC_Season:OnQuerySeasonRankRsp ModList = ", ModList)
      PlayerPrefsSystem.SaveTableToFile_N(ModList, PlayerPrefsSystem.ePlayerPrefsType.eUGCSeasonModUpdate)
    end
  end
  self.Svr  self.MatchModMap = ModList
  self.LatestModMap = ModList
  self.HistoryMatchModList = HistoryModList
  self:InitMatchModInfoList()
end
function Logic_UGC_Season:GetHistoryMatchModList()
  return self.HistoryMatchModList or {}
end
function Logic_UGC_Season:IsBeforeS4LegacyAPIEnabled()
  if self.ForceAbandonLegacyAPI then
    return false
  end
  if self.UGCSeasonID and self.UGCSeasonID > 4 then
    return false
  end
  return true
end
function Logic_UGC_Season:IsAfterS5Season()
  if self.UGCSeasonID and self.UGCSeasonID >= 6 then
    return true
  end
  if self.UGCSeasonID == 5 and self:IsDuringSeasonFrozen() then
    return true
  end
  return false
end
function Logic_UGC_Season:GMSetForceAbandonLegacyAPI(Val)
  self.ForceAbandonLegacyAPI = Val
end
function Logic_UGC_Season.get_season_award_list_rsp(ok, season, cur_season_id, is_idle_time, pre_best_segment)
  log_tree("Logic_UGC_Season.get_season_award_list_rsp=", {
    ok,
    season,
    cur_season_id,
    is_idle_time,
    pre_best_segment
  })
  if ok ~= 0 then
    ShowNotice(ok)
    return
  end
  Logic_UGC_Season.  Logic_UGC_Season.wow_best_segment = pre_best_segment.segment_id
  Logic_UGC_Season.wow_season_rating = pre_best_segment.segment_rating
  Logic_UGC_Season.  Logic_UGC_Season.wow_season_in_reward = season
  local LogicUGCSeasonAward = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCSeasonAward)
  LogicUGCSeasonAward:get_wowtask_state_list_rsp(season)
end
function Logic_UGC_Season:OnModInfoBatchRsp(MetaList, ListType, Param, FilterOfflineModList)
  local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
  if UGCMacros.CheckMetaType(ListType, UGCMacros.ENUM_MODE_TYPE.Season) then
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_SEASON_GET_MOD_LIST)
  elseif UGCMacros.CheckMetaType(ListType, UGCMacros.ENUM_MODE_TYPE.SeasonAchievement) then
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_WOW_SEASON_ACHIEVEMENTDATA_REFRESH)
  end
end
function Logic_UGC_Season:SetUGCSeasonSegmentData(ugcSegmentData)
  if not ugcSegmentData then
    log(bWriteLog and "[v_yibxu] Logic_UGC_Season:SetUGCSeasonSegmentData ugcseasonData = nil")
    return
  end
  self.UGCSegmentData = ugcSegmentData
  self.UGCSeasonID = ugcSegmentData.season_index
  log(bWriteLog and "[v_yibxu] Logic_UGC_Season:SetUGCSeasonSegmentData UGCSeasonID = " .. self.UGCSeasonID)
  if self.UGCSegmentData.daily_add_rating ~= nil and self.UGCSegmentData.max_daily_add_rating ~= nil and self.UGCSegmentData.daily_add_rating > self.UGCSegmentData.max_daily_add_rating then
    log(bWriteLog and "[v_yibxu] Logic_UGC_Season:SetUGCSeasonSegmentData daily_add_rating = " .. self.UGCSegmentData.daily_add_rating .. " max_daily_add_rating = self.UGCSegmentData.max_daily_add_rating ")
    self.UGCSegmentData.daily_add_rating = self.UGCSegmentData.max_daily_add_rating
  end
end
function Logic_UGC_Season:SetUGCSeasonData(seasonid, ugcSegmentData)
  if not seasonid or not ugcSegmentData then
    log(bWriteLog and "[v_yibxu] Logic_UGC_Season:SetUGCSeasonData seasonid = nil  or ugcseasonData = nil")
    return
  end
  log(bWriteLog and "[v_yibxu] Logic_UGC_Season:SetUGCSeasonData seasonid = " .. seasonid)
  log_tree(bWriteLog and "[v_yibxu] Logic_UGC_Season:SetUGCSeasonData ugcSegmentData = ", ugcSegmentData)
  if not self.UGCSegmentData.segment_id then
    self.UGCSegmentData.segment_id = 1
  end
  if not self.UGCSegmentData.season_index then
    self.UGCSegmentData.season_index = 1
  end
  if self.UGCSegmentData.segment_id < ugcSegmentData.segment_id or self.UGCSegmentData.season_index < ugcSegmentData.season_index then
    self.bSegmentUp = true
    if self:CheckShopOpen() then
      self:ResetStoreItemList()
    end
    log(bWriteLog and "[v_yibxu] Logic_UGC_Season:SetUGCSeasonData self.UGCSegmentData.segment_id = " .. tostring(self.UGCSegmentData.segment_id) .. " ugcSegmentData.segment_id = " .. tostring(ugcSegmentData.segment_id))
  else
    self.bSegmentUp = false
  end
  log(bWriteLog and "[v_yibxu] Logic_UGC_Season:SetUGCSeasonData  self.bSegmentUp = " .. tostring(self.bSegmentUp))
  self.UGCSegmentData = ugcSegmentData
  self.UGCSeasonID = seasonid
end
function Logic_UGC_Season:get_cur_season_index()
  return self:calculate_cur_season_index()
end
function Logic_UGC_Season:calculate_cur_season_index()
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  for i = #self.WOWSeasonTimeConfig, 1, -1 do
    local SeasonCfg = self.WOWSeasonTimeConfig[i]
    if not SeasonCfg then
      log(bWriteLog and "[v_yibxu] Logic_UGC_Season:calculate_cur_season_index  SeasonCfg = nil")
      return 0
    end
    if nowTime >= SeasonCfg.begin_time and nowTime <= SeasonCfg.end_time then
      log(bWriteLog and "[v_yibxu] Logic_UGC_Season:calculate_cur_season_index  SeasonID = " .. i)
      return i
    end
    if nowTime > SeasonCfg.end_time then
      log(bWriteLog and "[v_yibxu] Logic_UGC_Season:calculate_cur_season_index  SeasonID = " .. i .. "\231\169\186\231\170\151\230\156\159")
      return i
    end
  end
  log(bWriteLog and "[v_yibxu]  Logic_UGC_Season:calculate_cur_season_index  \232\181\155\229\173\163\230\156\170\228\184\138\231\186\191")
  return 0
end
function Logic_UGC_Season:IsDuringSeasonFrozen()
  print(bWriteLog and bWrriteLog and "Logic_UGC_Season:IsDuringSeasonFrozen")
  if self.WOWSeasonTimeConfig == nil then
    log(bWriteLog and "Logic_UGC_Season:IsDuringSeasonFrozen  WOWSeasonTimeConfig = nil")
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  for i = #self.WOWSeasonTimeConfig, 1, -1 do
    local SeasonCfg = self.WOWSeasonTimeConfig[i]
    if not SeasonCfg then
      log(bWriteLog and "Logic_UGC_Season:IsDuringSeasonFrozen  SeasonCfg = nil")
      return true
    end
    if nowTime >= SeasonCfg.begin_time and nowTime <= SeasonCfg.end_time then
      log(bWriteLog and "Logic_UGC_Season:IsDuringSeasonFrozen  SeasonID = " .. i)
      return false
    end
  end
  return true
end
function Logic_UGC_Season:calculate_cur_season_tab_index()
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  for i = #self.WOWSeasonTimeConfig, 1, -1 do
    local SeasonCfg = self.WOWSeasonTimeConfig[i]
    local filter_begin_time = SeasonCfg.filter_begin_time or 0
    local filter_end_time = SeasonCfg.filter_end_time or 0
    if not SeasonCfg then
      log(bWriteLog and "[v_chenxxue] Logic_UGC_Season:calculate_cur_season_index  SeasonCfg = nil")
      return 0
    end
    if type(SeasonCfg.filter_begin_time) == "string" and type(SeasonCfg.filter_end_time) == "string" then
      return 0
    end
    if filter_begin_time == 0 or filter_end_time == 0 then
      return 0
    end
    if nowTime >= SeasonCfg.filter_begin_time and nowTime <= SeasonCfg.filter_end_time then
      log(bWriteLog and "[v_chenxxue] Logic_UGC_Season:calculate_cur_season_index  SeasonID = " .. i)
      return i
    end
    if nowTime > SeasonCfg.filter_end_time then
      log(bWriteLog and "[v_chenxxue] Logic_UGC_Season:calculate_cur_season_index  SeasonID = " .. i .. "\231\169\186\231\170\151\230\156\159")
      return i
    end
  end
  log(bWriteLog and "[v_chenxxue]  Logic_UGC_Season:calculate_cur_season_index  \232\181\155\229\173\163\230\156\170\228\184\138\231\186\191")
  return 0
end
function Logic_UGC_Season:GetUGCSeasonCfg()
  if not self.WOWSeasonTimeConfig or not self.WOWSeasonTimeConfig[self.UGCSeasonID] then
    self:ReqGetUGCSeasonCfgData()
    log(bWriteLog and "[v_yibxu] Logic_UGC_Season:GetUGCSeasonCfg self.WOWSeasonTimeConfig = nil or self.WOWSeasonTimeConfig[self.UGCSeasonID] = nil")
    return nil
  end
  return self.WOWSeasonTimeConfig[self.UGCSeasonID]
end
function Logic_UGC_Season:GetUGCAllSegmentData()
  return self.SegmentCfg
end
function Logic_UGC_Season:GetUGCSegmentDataBySegmentID(id)
  if not id then
    log(bWriteLog and "[v_yibxu] Logic_UGC_Season:GetUGCSegmentDataBySegmentID id = nil")
    return
  end
  if id == 0 then
    id = 1
  end
  if not self.SegmentCfg or not self.SegmentCfg[id] then
    log(bWriteLog and "[v_yibxu] Logic_UGC_Season:GetUGCSegmentDataBySegmentID self.SegmentCfg = nil  or  self.SegmentCfg[id] = nil")
    return nil
  end
  return self.SegmentCfg[id]
end
function Logic_UGC_Season:GetQuestionInfo(type, title)
  local rulesConfig = CDataTable.GetTable("RulesData")
  local showRuleList = {}
  local E_StyleType = require("client.slua.umg.common.questionmark.questionmark_style_cfg").E_StyleType
  for _, tabConfig in pairs(rulesConfig) do
    local sessionId = tabConfig.SessionId or 0
    if sessionId == 0 or self.UGCSeasonID == nil or sessionId == self.UGCSessionId then
      local contentList = {}
      if tonumber(tabConfig.TabContentId) == 79511 then
        local ugc_season_daily_first_two_scores = 50
        local TableData = CDataTable.GetTableData("WoWSeasonParamsTable")
        if TableData then
          for _, Row in pair(TableData) do
            if Row.cfg_name == "ugc_season_daily_first_two_scores" then
              ugc_season_daily_first_two_scores = Row.cfg_value
              break
            end
          end
        end
        local content = LocUtil.GetLocalizeStrConcatenation(tonumber(tabConfig.TabContentId))
        content = LocUtil.GeneralFormat(content, ugc_season_daily_first_two_scores)
        table.insert(contentList, {
          type = E_StyleType.TEXT,
          content1 = content
        })
      else
        table.insert(contentList, {
          type = E_StyleType.TEXT,
          content1 = LocUtil.GetLocalizeStrConcatenation(tonumber(tabConfig.TabContentId))
        })
      end
      local infoTab = {
        tab = LocUtil.GetLocalizeResStr(tabConfig.TabTextId),
        title = LocUtil.GetLocalizeResStr(title),
        textInfo = contentList,
        ruleSortPriority = tabConfig.Priority or 0
      }
      if infoTab and infoTab.tab then
        table.insert(showRuleList, infoTab)
      end
    end
  end
  table.sort(showRuleList, function(a, b)
    return a.ruleSortPriority < b.ruleSortPriority
  end)
  return showRuleList
end
function Logic_UGC_Season:IsShowSeasonDetail()
  if self.UGCSeasonID == 0 or not LobbySystem.CheckOpen(BP_ENUM_UGC_SEGMENT_SWITCH) then
    ShowNotice(505014)
    return false
  else
    local SeasonVerCfg = self:GetUGCSeasonCfg()
    local version_util = require("client.common.version_util")
    local _clientVersion3 = version_util.GetClientFormat(Client.GetAppVersion())
    if not SeasonVerCfg then
      return false
    end
    if SeasonVerCfg and 0 > version_util.CompareVersionStandard(_clientVersion3, SeasonVerCfg.min_version) then
      ShowNotice(9409)
      return false
    end
    return true
  end
end
function Logic_UGC_Season:IsShowChoseMapReddot()
  return self.BModUpdate
end
function Logic_UGC_Season:IsShowRewardReddot()
  local season_redpoint_data = require("client.slua.logic.ugc.ugcSeason.ugc_season_reddot_data")
  local awardRedData = season_redpoint_data.GetWowSeasonRedDotData()
  local HasReddot = false
  if awardRedData and awardRedData.newCount >= 1 then
    HasReddot = true
  end
  return HasReddot
end
function Logic_UGC_Season:GetExp()
  local BLimit = false
  local Percent = 1
  local CurSegmentEXPMax = 0
  if self.UGCSegmentData then
    if self.UGCSegmentData.segment_id == self.SegmentMax then
      Percent = 1
    else
      local UGCSegmentNextData
      if self.UGCSegmentData.segment_id then
        UGCSegmentNextData = self:GetUGCSegmentDataBySegmentID(self.UGCSegmentData.segment_id + 1)
      end
      if UGCSegmentNextData then
        CurSegmentEXPMax = UGCSegmentNextData.next_segment_score
        Percent = self.UGCSegmentData.segment_rating / CurSegmentEXPMax
      else
        log(bWriteLog and "[v_yibxu]  Logic_UGC_Season:GetExp UGCSegmentNextData = nil")
      end
    end
    if self.UGCSegmentData.daily_add_rating and self.UGCSegmentData.max_daily_add_rating then
      if self.UGCSegmentData.daily_add_rating < self.UGCSegmentData.max_daily_add_rating then
        BLimit = false
      else
        BLimit = true
      end
    end
  end
  return BLimit, Percent, CurSegmentEXPMax
end
function Logic_UGC_Season:GetWowSeasonReward()
  return Logic_UGC_Season.wow_season_in_reward
end
function Logic_UGC_Season:SelectSeasonModId(mod_id)
  print(bWriteLog and "Logic_UGC_Season:SelectSeasonModId mod_id = " .. tostring(mod_id))
  if mod_id and self:IsModIdCouldBeSelected(mod_id) then
    self:StartSelectMod()
    self:ClearMatchBanList()
    for ModID, _ in pairs(self.MatchModMap) do
      if ModID ~= mod_id then
        self:SwitchMatchModBanState(ModID, true)
      end
    end
    self:EndSelectMod(true)
  end
end
function Logic_UGC_Season:GetFirstCurrentSelectModId()
  if self.MatchBanList and self.MatchModMap then
    for ModID, _ in pairs(self.MatchModMap) do
      if self.MatchBanList[ModID] == nil then
        return ModID
      end
    end
  end
end
function Logic_UGC_Season:IsModIdCouldBeSelected(mod_id)
  if mod_id and self.MatchModMap then
    return self.MatchModMap[mod_id] ~= nil
  end
  return false
end
function Logic_UGC_Season:GetModInfo(mod_id)
  if mod_id and self.LatestModMap then
    return self.LatestModMap[mod_id]
  end
end
function Logic_UGC_Season:HasModInfo()
  return self.LatestModMap ~= nil
end
function Logic_UGC_Season:GetUGCModRemoveTime(mod_id)
  if mod_id then
    if self.MatchModMap and self.MatchModMap[mod_id] then
      local ModInfo = self.MatchModMap[mod_id]
      if ModInfo.estimated_remove_time then
        return ModInfo.estimated_remove_time
      else
        print(bWriteLog and "Logic_UGC_Season:GetUGCModRemoveTime ModInfo.estimated_remove_time = nil")
      end
    else
      print(bWriteLog and "Logic_UGC_Season:GetUGCModRemoveTime self.MatchModMap[mod_id] = nil")
    end
  else
    print(bWriteLog and "Logic_UGC_Season:GetUGCModRemoveTime mod_id = nil")
  end
end
function Logic_UGC_Season:GetFriendLeaderboard(ModInfo)
  local friend_scores = {}
  local all_friend_lists = self:GetFriendList()
  local mod_id = ModInfo.mod_id
  if mod_id == nil then
    print(bWriteLog and "Logic_UGC_Season:GetFriendLeaderboard mod_id = nil")
    return {}
  end
  local leaderboard = ModInfo.setting and ModInfo.setting.leaderboard or 0
  if leaderboard == 0 then
    print(bWriteLog and "Logic_UGC_Season:GetFriendLeaderboard leaderboard = 0")
    return {}
  end
  local reset_lb_date = ModInfo.reset_lb_date or 0
  local lb_order = ModInfo.setting and ModInfo.setting.lb_order or 0
  for _, friend_info in pairs(all_friend_lists) do
    if friend_info.ugc_season_rank_records and type(friend_info.ugc_season_rank_records) == "table" then
      for friend_played_mod_id, v in pairs(friend_info.ugc_season_rank_records) do
        if friend_played_mod_id == mod_id and reset_lb_date == v.reset_lb_date then
          table.insert(friend_scores, {
            uid = friend_info.uid or 0,
            score = v.origin_value or 0
          })
        end
      end
    end
  end
  local LogicUGCModRank = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCModRank)
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  local myRankInfo = LogicUGCModRank:GetPlayerRankInfo(mod_id, Config_UGC.ModRankType.Season)
  if myRankInfo and myRankInfo.rank_score then
    table.insert(friend_scores, {
      uid = tonumber(DataMgr.roleData.uid),
      score = myRankInfo.rank_score or 0
    })
  end
  if lb_order == 0 then
    table.sort(friend_scores, function(a, b)
      return a.score > b.score
    end)
  else
    table.sort(friend_scores, function(a, b)
      return a.score < b.score
    end)
  end
  for idx, friend_info in ipairs(friend_scores) do
    friend_info.rank_no = idx
  end
  return friend_scores
end
function Logic_UGC_Season:GetFriendList()
  if self.allFriendList == nil then
    self.allFriendList = {}
    local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
    local list = LogicFriend.GetInnerList(true)
    for _, v in ipairs(list) do
      local temp = self:MakeFriendInfo(v)
      if temp and temp.ugc_season_rank_records then
        table.insert(self.allFriendList, temp)
      end
    end
  end
  return self.allFriendList
end
function Logic_UGC_Season:ClearFriendCache()
  self.allFriendList = nil
end
function Logic_UGC_Season:MakeFriendInfo(uid)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local friendData = logic_profile:GetLocalProfile(uid)
  if friendData then
    local temp = {}
    temp.uid = friendData.uid
    temp.ugc_season_rank_records = friendData.ugc_season_rank_records
    return temp
  end
  return nil
end
local C_LEADERBOARD_REQ_CD = 1
function Logic_UGC_Season:ReqSeasonRankInfo(mod_id)
  if mod_id == nil then
    print(bWriteLog and "Logic_UGC_Season:ReqSeasonRankInfo error mod_id = nil")
    return
  end
  print(bWriteLog and "Logic_UGC_Season:ReqSeasonRankInfo mod_id = " .. tostring(mod_id))
  local ElapsedTime = 999999
  if self.LastReqTime then
    ElapsedTime = os.time() - self.LastReqTime
  end
  if ElapsedTime <= C_LEADERBOARD_REQ_CD then
    print(bWriteLog and "Logic_UGC_Season:ReqSeasonRankInfo In CD")
    self.PendingReqModID = mod_id
    if self.PendingReqTimer == nil then
      self.PendingReqTimer = self:AddGameTimer(math.max(C_LEADERBOARD_REQ_CD - ElapsedTime, 1) + 0.1, false, function()
        self.PendingReqTimer = nil
        local ReqModID = self.PendingReqModID
        self.PendingReqModID = nil
        self:ReqSeasonRankInfo(ReqModID)
      end)
    end
    return
  end
  self.LastReqTime = os.time()
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogic_UGC_Season = class(CModuleBase, nil, Logic_UGC_Season)
return require("combine_class").GenerateFeatureClass(CLogic_UGC_Season, "client.slua.logic.ugc.logic_ugc_season_s4_legacy", "client.slua.logic.ugc.logic_ugc_season_store_legacy")