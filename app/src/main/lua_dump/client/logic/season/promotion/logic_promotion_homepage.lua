local logic_promotion_homepage = {}
function logic_promotion_homepage:ctor()
  self.E_PROMOTION_STATUS = {
    LOCK = 1,
    UNLOCK = 2,
    ING = 3,
    COMPLETE_NOT_CERTIFIED = 4,
    COMPLETE_AND_CERTIFIED = 5
  }
end
function logic_promotion_homepage:DefineAndResetData()
  self.bInit = false
  self.promotion_base_config = nil
  self.nShowPromotionStatus = nil
end
function logic_promotion_homepage:OnInitialize()
  self:_ReqPromotionBaseConfig()
end
function logic_promotion_homepage:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_NEXTDAY, EVENTID_NEXTDAY_ZERO, self.OnNextDayZero, self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_SEASON_CHANGE, self.OnSeasonChange, self)
end
function logic_promotion_homepage:IsOpen()
  local promotion_match_util = require("client.logic.season.promotion_match.promotion_match_util")
  local bSwitch = promotion_match_util.GetPromotionSwitch()
  local cur_season = DataMgr.season_id
  local start_season = promotion_match_util.GetPromotionStartSeasonId()
  if start_season == nil then
    log(bWriteLog and "logic_promotion_homepage:IsOpen start_season is nil from server")
    local Start_Season_ID = CDataTable.GetTableData("PromotionParams", "Start_Season_ID")
    start_season = tonumber(Start_Season_ID.Value)
  end
  local bSeason = cur_season >= start_season
  log_format(bWriteLog and "logic_promotion_homepage:IsOpen bSwitch: %s, bSeason: %s", bSwitch, bSeason)
  return bSwitch and bSeason
end
function logic_promotion_homepage.IsMaxPromoOpen(season_id)
  local promotion_match_util = require("client.logic.season.promotion_match.promotion_match_util")
  local bSwitch = promotion_match_util.GetPromotionSwitch()
  season_id = tonumber(season_id)
  local start_season = promotion_match_util.GetPromotionStartSeasonId()
  if start_season == nil then
    log(bWriteLog and "logic_promotion_homepage.IsMaxPromoOpen start_season is nil from server")
    local Start_Season_ID = CDataTable.GetTableData("PromotionParams", "Start_Season_ID")
    start_season = tonumber(Start_Season_ID.Value)
  end
  local bSeason = season_id > start_season
  log_format(bWriteLog and "logic_promotion_homepage.IsMaxPromoOpen bSwitch: %s, bSeason: %s", bSwitch, bSeason)
  return bSwitch and bSeason
end
function logic_promotion_homepage.IsNoPromoRating(season_id)
  local promotion_match_util = require("client.logic.season.promotion_match.promotion_match_util")
  season_id = tonumber(season_id)
  local start_season = promotion_match_util.GetPromotionStartSeasonId()
  if start_season == nil then
    log(bWriteLog and "logic_promotion_homepage.IsNoPromoRating start_season is nil from server")
    local Start_Season_ID = CDataTable.GetTableData("PromotionParams", "Start_Season_ID")
    start_season = tonumber(Start_Season_ID.Value)
  end
  local bSeason = season_id > start_season + 1
  log_format(bWriteLog and "logic_promotion_homepage.IsNoPromoRating bSeason: %s", bSeason)
  return bSeason
end
function logic_promotion_homepage.GetPromoChallengeScoreOpen()
  local promotion_match_util = require("client.logic.season.promotion_match.promotion_match_util")
  local bSwitch = promotion_match_util.GetPromotionChallengeSwitch()
  local start_season = promotion_match_util.GetPromotionChallengeScoreStartSeasonId()
  if start_season == nil then
    log(bWriteLog and "logic_promotion_homepage.IsNoPromoRating start_season is nil from server")
    local Start_Season_ID = CDataTable.GetTableData("PromotionParams", "Challenge_Score_Season_ID")
    start_season = tonumber(Start_Season_ID.Value)
  end
  local bSeason = start_season <= DataMgr.season_id
  log_format(bWriteLog and "logic_promotion_homepage.GetPromotionChallengeScoreStartSeasonId bSeason: %s", bSeason)
  return bSeason and bSwitch
end
function logic_promotion_homepage:GetCurPromotionBaseConfig()
  if not self.bInit then
    return nil
  end
  local promotion_match_util = require("client.logic.season.promotion_match.promotion_match_util")
  local promotion_data = promotion_match_util.GetPromotionData()
  if not promotion_data then
    log(bWriteLog and "logic_promotion_homepage:GetCurPromotionBaseConfig promotion_data is nil")
    return self.promotion_base_config[1]
  end
  local index = promotion_data.cur_lock_index
  return self.promotion_base_config[index]
end
function logic_promotion_homepage:IsCanSelectPromotionMode()
  local promotion_match_util = require("client.logic.season.promotion_match.promotion_match_util")
  local promotion_data = promotion_match_util.GetPromotionData()
  if not promotion_data then
    return false
  end
  if promotion_data.season_id ~= DataMgr.season_id then
    log(bWriteLog and "logic_promotion_homepage:IsCanSelectPromotionMode promotion_data.season_id ~= DataMgr.season_id")
    return false
  end
  for i, v in ipairs(promotion_data.locked_info) do
    if v.status == self.E_PROMOTION_STATUS.UNLOCK or v.status == self.E_PROMOTION_STATUS.ING then
      return true
    end
  end
  return false
end
function logic_promotion_homepage:IsInPromotionStatus()
  local promotion_match_util = require("client.logic.season.promotion_match.promotion_match_util")
  local promotion_data = promotion_match_util.GetPromotionData()
  if not promotion_data then
    return false
  end
  if promotion_data.season_id ~= DataMgr.season_id then
    log(bWriteLog and "logic_promotion_homepage:IsInPromotionStatus promotion_data.season_id ~= DataMgr.season_id")
    return false
  end
  for i, v in ipairs(promotion_data.locked_info) do
    if v.status == self.E_PROMOTION_STATUS.UNLOCK or v.status == self.E_PROMOTION_STATUS.ING or v.status == self.E_PROMOTION_STATUS.COMPLETE_NOT_CERTIFIED then
      return true
    end
  end
  return false
end
function logic_promotion_homepage:IsAllComplete()
  local promotion_match_util = require("client.logic.season.promotion_match.promotion_match_util")
  local promotion_data = promotion_match_util.GetPromotionData()
  if not promotion_data then
    return false
  end
  return promotion_data.all_tier_unlocked
end
function logic_promotion_homepage:GetNextPromotionSegmentLevel()
  if not self.bInit then
    return nil
  end
  local promotion_match_util = require("client.logic.season.promotion_match.promotion_match_util")
  local promotion_data = promotion_match_util.GetPromotionData()
  if not promotion_data then
    return nil
  end
  local index = promotion_data.cur_lock_index
  local segment_level = self.promotion_base_config[index].segment_level
  return segment_level
end
function logic_promotion_homepage:GetCurProtectCount()
  if not self.bInit then
    return -1, -1
  end
  local promotion_match_util = require("client.logic.season.promotion_match.promotion_match_util")
  local promotion_data = promotion_match_util.GetPromotionData()
  if not promotion_data then
    return -1, -1
  end
  local index = promotion_data.cur_lock_index
  local max_protect_cnt = self.promotion_base_config[index].protect_cnt
  local cur_protect_cnt = max_protect_cnt - promotion_data.locked_info[index].protect_cnt
  return cur_protect_cnt, max_protect_cnt
end
function logic_promotion_homepage:IsShowPromotionStatus(uid)
  if not self:IsOpen() then
    return false
  end
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(uid)
  log_format(bWriteLog and "logic_promotion_homepage:IsShowPromotionStatus uid: %s", uid)
  if profile then
    log_tree(bWriteLog and "logic_promotion_homepage:IsShowPromotionStatus profile.promotion_info: ", profile.promotion_info)
  end
  if uid == tonumber(DataMgr.roleData.uid) and self.nShowPromotionStatus ~= nil then
    log_format(bWriteLog and "logic_promotion_homepage:IsShowPromotionStatus nShowPromotionStatus: %s", self.nShowPromotionStatus)
    local promotion_match_util = require("client.logic.season.promotion_match.promotion_match_util")
    local promotion_data = promotion_match_util.GetPromotionData()
    if promotion_data and self:IsCanSelectPromotionMode() then
      return self.nShowPromotionStatus == 0
    else
      return false
    end
  end
  if not (profile and profile.promotion_info) or profile.promotion_info.is_progressing == false then
    return false
  end
  if profile.promotion_info.season_id ~= DataMgr.season_id then
    return false
  end
  local nPrivacy = profile.promotion_info.privacy
  if nPrivacy == 1 then
    return false
  end
  if nPrivacy == 0 then
    return true
  end
  return false
end
function logic_promotion_homepage:IsDimondOrCrownRank(rank_id)
  local level_cfg = FuncUtil.GetRankTableData(rank_id, DataMgr.season_id)
  return level_cfg and (level_cfg.IntegralTypeNew == 5 or level_cfg.IntegralTypeNew == 6)
end
function logic_promotion_homepage:IsPromotionLevel(rank_id)
  log_format(bWriteLog and "logic_promotion_homepage:IsPromotionLevel self.bInit: %s, rank_id: %s", self.bInit, rank_id)
  if self.bInit then
    local promotion_cfgs = self.promotion_base_config
    for i, v in ipairs(promotion_cfgs) do
      if v.segment_level == rank_id then
        return true
      end
    end
    return false
  else
    local promotion_cfgs = CDataTable.GetTableDataByFilter("PromotionBasicRules", "RankID", rank_id)
    if promotion_cfgs then
      return true
    end
    return false
  end
end
function logic_promotion_homepage:IsBestRank(rank_id)
  if rank_id then
    return 800 <= rank_id
  end
  return false
end
function logic_promotion_homepage:send_set_promotion_privacy_req(value)
  log_format(bWriteLog and "logic_promotion_homepage:send_set_promotion_privacy_req value: %s", value)
  local PromotionHandler = require("client.network.Protocol.PromotionHandler")
  PromotionHandler.send_set_promotion_privacy_req(value)
end
function logic_promotion_homepage:proc_set_promotion_privacy_rsp(err, value)
  log_format(bWriteLog and "logic_promotion_homepage:proc_set_promotion_privacy_rsp err: %s, value: %s", err, value)
  if err == 0 then
    self.nShowPromotionStatus = value
    EventSystem:postEvent(EVENTTYPE_PROMOTION, EVENTID_PROMOTION_STATUS_PRIVACY_SET_RSP)
  end
end
function logic_promotion_homepage:_ReqPromotionBaseConfig()
  if not self:IsOpen() then
    return
  end
  log(bWriteLog and "logic_promotion_homepage:_ReqPromotionBaseConfig")
  local callback = function(table_data)
    log_tree(bWriteLog and "logic_promotion_homepage:_ReqPromotionBaseConfig callback table_data: ", table_data)
    self.bInit = true
    self.promotion_base_config = table_data
    EventSystem:postEvent(EVENTTYPE_PROMOTION, EVENTID_PROMOTION_BASE_CONFIG)
  end
  local promotion_match_util = require("client.logic.season.promotion_match.promotion_match_util")
  promotion_match_util.ReqPromotionBaseConfig(callback)
end
function logic_promotion_homepage:OnNextDayZero()
  self:_ReqPromotionBaseConfig()
end
function logic_promotion_homepage:OnSeasonChange()
  self:_ReqPromotionBaseConfig()
end
function logic_promotion_homepage:NeedPromotionRewardGuide()
  if not self:IsOpen() then
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.ePromotionHomepageGuide) or {}
  log_tree(bWriteLog and "logic_promotion_homepage:NeedPromotionRewardGuide data: ", data)
  if data[DataMgr.season_id] and data[DataMgr.season_id].hasGuide then
    return false
  end
  return true
end
function logic_promotion_homepage:RecordPromotionRewardGuide()
  if not self:IsOpen() then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.ePromotionHomepageGuide) or {}
  if data[DataMgr.season_id] == nil then
    data[DataMgr.season_id] = {}
  end
  data[DataMgr.season_id].hasGuide = true
  log_tree(bWriteLog and "logic_promotion_homepage:RecordPromotionRewardGuide data: ", data)
  PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.ePromotionHomepageGuide)
  local season_redpoint_data = require("client.logic.season.red_point.season_redpoint_data")
  season_redpoint_data.RefreshPromotionNewSeasonStart()
end
function logic_promotion_homepage:NeedShowFirstEffect()
  if not self:IsOpen() then
    return false
  end
  local promotion_match_util = require("client.logic.season.promotion_match.promotion_match_util")
  local promotion_data = promotion_match_util.GetPromotionData()
  if not promotion_data then
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.ePromotionHomepageGuide) or {}
  log_tree(bWriteLog and "logic_promotion_homepage:NeedShowEffect data: ", data)
  if data[DataMgr.season_id] and data[DataMgr.season_id].isFirstOpenHomaPage then
    return false
  end
  return true
end
function logic_promotion_homepage:RecordHasShowFirstEffect()
  if not self:IsOpen() then
    return
  end
  local promotion_match_util = require("client.logic.season.promotion_match.promotion_match_util")
  local promotion_data = promotion_match_util.GetPromotionData()
  if not promotion_data then
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.ePromotionHomepageGuide) or {}
  if data[DataMgr.season_id] == nil then
    data[DataMgr.season_id] = {}
  end
  data[DataMgr.season_id].isFirstOpenHomaPage = true
  log_tree(bWriteLog and "logic_promotion_homepage:RecordHasShowEffect data: ", data)
  PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.ePromotionHomepageGuide)
  local season_redpoint_data = require("client.logic.season.red_point.season_redpoint_data")
  season_redpoint_data.RefreshPromotionNewSeasonUnlock()
end
function logic_promotion_homepage:ShowHelpGuide()
  local config = CDataTable.GetTable("PeakGameGuideList")
  local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
  local promotionGuideItems = {}
  local slapType = PeakGameConfig.EGuideType.Promotion
  local SeasonSystem = require("client.logic.season.logic_season")
  local nSegment = SeasonSystem.GetMaxSegment()
  if nSegment <= 202 then
    slapType = PeakGameConfig.EGuideType.NewbiePromotion
  end
  local season_id = DataMgr.season_id
  log(bWriteLog and "logic_promotion_homepage:ShowHelpGuide season_id = " .. tostring(season_id))
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local isBLUEHOLE = PublishRegionMacros.IsBLUEHOLE()
  log(bWriteLog and "logic_promotion_homepage:ShowHelpGuide isBLUEHOLE = " .. tostring(isBLUEHOLE))
  for _, value in pairs(config) do
    if isBLUEHOLE then
      if value.FunctionType == slapType and value.BlueHoleSeasonID and season_id >= value.BlueHoleSeasonID then
        table.insert(promotionGuideItems, value)
      end
    elseif value.FunctionType == slapType and value.SeasonID and season_id >= value.SeasonID then
      table.insert(promotionGuideItems, value)
    end
  end
  UIManager.ShowUI(UIManager.UI_Config.Lobby_Season_Guide_UIBP, promotionGuideItems)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_promotion_homepage = class(CModuleBase, nil, logic_promotion_homepage)
return Clogic_promotion_homepage