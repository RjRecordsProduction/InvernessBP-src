local LogicPeakGameHall = {}
local LogicPeakGameUtil = require("client.logic.PeakGame.LogicPeakGameUtil")
function LogicPeakGameHall:DefineAndResetData()
  self.weekly_rank_data_list = {}
  self.hof_rank_data_list = {}
  self.ability_rank_data_list = {}
  self.weekly_rank_time = nil
  self.hall_req_profile_map = {}
end
function LogicPeakGameHall:OpenPeakRankHallUI(index)
  log(bWriteLog and "LogicPeakGameHall:OpenPeakRankHallUI index = " .. tostring(index))
  if not LogicPeakGameUtil.IsOpen() then
    log(bWriteLog and "LogicPeakGameHall:OpenPeakRankHallUI not open")
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.PeakGame_Rank_UIBP, index)
end
function LogicPeakGameHall:GetPeakGameHallTabs()
  log(bWriteLog and "LogicPeakGameHall:GetPeakGameHallTabs")
  local RankConfig = require("client.slua.logic.rank.rank_config")
  local tabs
  local season_id = DataMgr.season_id
  log(bWriteLog and "LogicPeakGameHall:GetPeakGameHallTabs season_id = " .. tostring(season_id))
  if season_id < 41 then
    tabs = {
      [1] = {
        text = LocUtil.GetLocalizeResStr(68205),
        rank_requird_id = RankConfig.ScoreType.peakgame_week_rating
      },
      [2] = {
        text = LocUtil.GetLocalizeResStr(68206),
        rank_requird_id = RankConfig.ScoreType.peakgame_hof_rating
      }
    }
  else
    tabs = {
      [1] = {
        text = LocUtil.GetLocalizeResStr(68205),
        rank_requird_id = RankConfig.ScoreType.peakgame_week_rating
      },
      [2] = {
        text = LocUtil.GetLocalizeResStr(68206),
        rank_requird_id = RankConfig.ScoreType.peakgame_hof_rating
      },
      [3] = {
        text = LocUtil.GetLocalizeResStr(68547),
        rank_requird_id = RankConfig.ScoreType.peakgame_ability_kd_rating
      }
    }
  end
  return tabs
end
function LogicPeakGameHall:GetPeakGameHallJumpTabs()
  log(bWriteLog and "LogicPeakGameHall:GetPeakGameHallJumpTabs")
  local common_tab_cfg = require("client.slua.component.common.config.common_tab_cfg")
  local jumpTabs = {
    [1] = {
      text = LocUtil.LocalizeResFormat(68207),
      style = common_tab_cfg.jump_item_style.Yellow,
      showFunc = function()
        return LogicPeakGameUtil.IsInRankOpenTime()
      end,
      clickFunc = function(wdiget, index)
        log(bWriteLog and "LogicPeakGameHall:GetPeakGameHallJumpTabs OnClick jumpTabs index = " .. tostring(index))
        GlobalData.JumpUrl("game://?module=1000100&to=peak")
      end
    }
  }
  local canShowJumpTabs = {}
  for _, v in ipairs(jumpTabs) do
    if v.showFunc() then
      table.insert(canShowJumpTabs, v)
    end
  end
  return canShowJumpTabs
end
function LogicPeakGameHall:GetWeeklyRankRewardData(requireRankId, rankNo)
  log(bWriteLog and "LogicPeakGameHall:GetWeeklyRankRewardData requireRankId = " .. tostring(requireRankId) .. " rankNo = " .. tostring(rankNo))
  if not (requireRankId and rankNo) or rankNo <= 0 then
    return nil
  end
  local RankConfig = require("client.slua.logic.rank.rank_config")
  if requireRankId ~= RankConfig.ScoreType.peakgame_week_rating then
    return nil
  end
  local RankDataMgr = require("client.slua.logic.rank.rank_data_mgr")
  local rewardCfg, rewardTableCfg
  local LogicPeakGameUtil = require("client.logic.PeakGame.LogicPeakGameUtil")
  local select_zone_id = LogicPeakGameUtil.GetCurSelectZoneId()
  if select_zone_id == 6 then
    rewardTableCfg = CDataTable.GetTableByFilter("JKRankRewardTable", "RankType", requireRankId)
  else
    rewardTableCfg = CDataTable.GetTableByFilter("RankRewardTable", "RankType", requireRankId)
  end
  if rewardTableCfg then
    for _, v in pairs(rewardTableCfg) do
      if rankNo >= v.RankCeilling and rankNo <= v.RankFloor then
        rewardCfg = {
          [1] = {
            rewardItemID = v.RewardItemID1,
            rewardItemCnt = v.RewardItemCnt1,
            rewardItemLimit = RankDataMgr.GetRankRewardItemTime(v.RewardItemLimitType1, v.RewardItemTimeLimit1)
          },
          [2] = {
            rewardItemID = v.RewardItemID2,
            rewardItemCnt = v.RewardItemCnt2,
            rewardItemLimit = RankDataMgr.GetRankRewardItemTime(v.RewardItemLimitType2, v.RewardItemTimeLimit2)
          },
          [3] = {
            rewardItemID = v.RewardItemID3,
            rewardItemCnt = v.RewardItemCnt3,
            rewardItemLimit = RankDataMgr.GetRankRewardItemTime(v.RewardItemLimitType3, v.RewardItemTimeLimit3)
          }
        }
        break
      end
    end
    return rewardCfg
  end
  return nil
end
function LogicPeakGameHall:GetHofRankRewardData(requireRankId, rankNo, zone_id, season_id)
  log(bWriteLog and "LogicPeakGameHall:GetHofRankRewardData requireRankId = " .. tostring(requireRankId) .. " rankNo = " .. tostring(rankNo) .. " zone_id = " .. tostring(zone_id) .. " season_id = " .. tostring(season_id))
  if not (requireRankId and rankNo and zone_id) or not season_id then
    return nil
  end
  local RankConfig = require("client.slua.logic.rank.rank_config")
  if requireRankId ~= RankConfig.ScoreType.peakgame_hof_rating then
    return nil
  end
  local rewardTableCfg = CDataTable.GetTableByFilter("TopNextRankRewardTable", "TemplateInstance", requireRankId, "SubTemplateType", zone_id, "RankType", season_id)
  if rewardTableCfg then
    local rewardCfg
    local RankDataMgr = require("client.slua.logic.rank.rank_data_mgr")
    for _, v in pairs(rewardTableCfg) do
      if rankNo >= v.RankCeilling and rankNo <= v.RankFloor then
        rewardCfg = {
          [1] = {
            rewardItemID = v.RewardItemID1,
            rewardItemCnt = v.RewardItemCnt1,
            rewardItemLimit = RankDataMgr.GetRankRewardItemTime(v.RewardItemLimitType1, v.RewardItemLimitTime1)
          },
          [2] = {
            rewardItemID = v.RewardItemID2,
            rewardItemCnt = v.RewardItemCnt2,
            rewardItemLimit = RankDataMgr.GetRankRewardItemTime(v.RewardItemLimitType2, v.RewardItemLimitTime2)
          },
          [3] = {
            rewardItemID = v.RewardItemID3,
            rewardItemCnt = v.RewardItemCnt3,
            rewardItemLimit = RankDataMgr.GetRankRewardItemTime(v.RewardItemLimitType3, v.RewardItemLimitTime3)
          }
        }
        break
      end
    end
    return rewardCfg
  end
  return nil
end
function LogicPeakGameHall:GetDefaultSelectSeason()
  log(bWriteLog and "LogicPeakGameHall:GetDefaultSelectSeason")
  local defaultSelectSeason = DataMgr.season_id - 1
  log(bWriteLog and "LogicPeakGameHall:GetDefaultSelectSeason defaultSelectSeason = " .. tostring(defaultSelectSeason))
  local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
  if defaultSelectSeason <= PeakGameConfig.MinPeakGameSeasonId then
    return PeakGameConfig.MinPeakGameSeasonId
  end
  return defaultSelectSeason
end
function LogicPeakGameHall:GetSeasonComboboxData()
  log(bWriteLog and "LogicPeakGameHall:GetSeasonComboboxData")
  local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
  local minPeakGameSeasonId = PeakGameConfig.MinPeakGameSeasonId
  local currSeasonId = DataMgr.season_id
  log(bWriteLog and "LogicPeakGameHall:GetSeasonComboboxData minPeakGameSeasonId = " .. tostring(minPeakGameSeasonId) .. " currSeasonId = " .. tostring(currSeasonId))
  local seasonList = {}
  if not minPeakGameSeasonId or not currSeasonId then
    log(bWriteLog and "LogicPeakGameHall:GetSeasonComboboxData 1")
    return seasonList
  end
  if minPeakGameSeasonId >= currSeasonId then
    log(bWriteLog and "LogicPeakGameHall:GetSeasonComboboxData 2")
    return seasonList
  end
  for index = minPeakGameSeasonId, currSeasonId - 1 do
    local seasondata = CDataTable.GetTableData("SeasonInfo", index)
    if seasondata then
      table.insert(seasonList, {
        text = seasondata.SeasonName,
        season_id = index
      })
    end
  end
  log_tree("LogicPeakGameHall:GetSeasonComboboxData seasonList = ", seasonList)
  return seasonList
end
function LogicPeakGameHall:GetZoneComboboxData()
  log(bWriteLog and "LogicPeakGameHall:GetZoneComboboxData")
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local bIsBluehole = PublishRegionMacros.IsBLUEHOLE()
  log(bWriteLog and "LogicPeakGameHall:GetZoneComboboxData bIsBluehole = " .. tostring(bIsBluehole))
  local logic_multiple_area = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_multiple_area)
  local isRussiaArea = logic_multiple_area:IsConnectToRussiaArea()
  log(bWriteLog and "LogicPeakGameHall:GetZoneComboboxData isRussiaArea = " .. tostring(isRussiaArea))
  local zoneList = {}
  if bIsBluehole then
    table.insert(zoneList, {
      zone_id = 3,
      text = logic_multiple_area:GetDisplayNameByZoneID(3)
    })
  elseif isRussiaArea then
    table.insert(zoneList, {
      zone_id = 2,
      text = logic_multiple_area:GetDisplayNameByZoneID(2)
    })
  else
    local cfg = CDataTable.GetTable("ZoneConfig")
    for _, v in pairs(cfg) do
      table.insert(zoneList, {
        zone_id = v.ZoneID,
        text = v.NameInChinese
      })
    end
  end
  table.sort(zoneList, function(a, b)
    local zone_id_a = a.zone_id
    local zone_id_b = b.zone_id
    return zone_id_a < zone_id_b
  end)
  log_tree("LogicPeakGameHall:GetZoneComboboxData zoneList = ", zoneList)
  return zoneList
end
function LogicPeakGameHall:GetWeeklyRankData(zone_id)
  log(bWriteLog and "LogicPeakGameHall:GetWeeklyRankData zone_id = " .. tostring(zone_id))
  if not (zone_id and self.weekly_rank_data_list) or not self.weekly_rank_data_list[zone_id] then
    log(bWriteLog and "LogicPeakGameHall:GetWeeklyRankData data is invalid")
    return nil
  end
  local weekly_rank_data = self.weekly_rank_data_list[zone_id]
  return weekly_rank_data
end
function LogicPeakGameHall:GetHofRankData(season_id, zone_id)
  log(bWriteLog and "LogicPeakGameHall:GetHofRankData season_id = " .. tostring(season_id) .. " zone_id = " .. tostring(zone_id))
  if not (season_id and zone_id and self.hof_rank_data_list and self.hof_rank_data_list[season_id]) or not self.hof_rank_data_list[season_id][zone_id] then
    log(bWriteLog and "LogicPeakGameHall:GetHofRankData data is invalid")
    return nil
  end
  local hof_rank_data = self.hof_rank_data_list[season_id][zone_id]
  return hof_rank_data
end
function LogicPeakGameHall:GetAbilityRankData(rank_requird_id, zone_id)
  log(bWriteLog and "LogicPeakGameHall:GetAbilityRankData rank_requird_id = " .. tostring(rank_requird_id) .. " zone_id = " .. tostring(zone_id))
  if not (rank_requird_id and zone_id and self.ability_rank_data_list and self.ability_rank_data_list[rank_requird_id]) or not self.ability_rank_data_list[rank_requird_id][zone_id] then
    log(bWriteLog and "LogicPeakGameHall:GetAbilityRankData data is invalid")
    return nil
  end
  local ability_rank_data = self.ability_rank_data_list[rank_requird_id][zone_id]
  return ability_rank_data
end
function LogicPeakGameHall:GetWeeklyRankTime()
  log(bWriteLog and "LogicPeakGameHall:GetWeeklyRankTime")
  log_tree("LogicPeakGameHall:GetWeeklyRankTime self.weeklyRankTime = ", self.weeklyRankTime)
  if not self.weeklyRankTime then
    return nil, nil
  end
  return self.weeklyRankTime.startTimestamp, self.weeklyRankTime.endTimestamp
end
function LogicPeakGameHall:ResetAllCacheData()
  log(bWriteLog and "LogicPeakGameHall:ResetAllCacheData")
  self:DefineAndResetData()
end
function LogicPeakGameHall:GetHallPlayerProfile(uid)
  log(bWriteLog and "LogicPeakGameHall:GetHallPlayerProfile uid = " .. tostring(uid))
  if not uid then
    lof(bWriteLog and "LogicPeakGameHall:GetHallPlayerProfile uid is invalid")
    return nil
  end
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(tonumber(uid))
  if profile then
    return profile
  end
  self:AddHallProfileReqList(tonumber(uid))
  return nil
end
function LogicPeakGameHall:AddHallProfileReqList(uid)
  log(bWriteLog and "LogicPeakGameHall:AddHallProfileReqList uid = " .. tostring(uid))
  if not uid then
    log(bWriteLog and "LogicPeakGameHall:AddHallProfileReqList no uid")
    return
  end
  uid = tonumber(uid)
  if self.hall_req_profile_map[uid] then
    log(bWriteLog and "LogicPeakGameHall:AddHallProfileReqList uid has in map")
    return
  end
  log(bWriteLog and "LogicPeakGameHall:AddHallProfileReqList add uid = " .. tostring(uid))
  self.hall_req_profile_map[uid] = 1
end
function LogicPeakGameHall:ReqHallProfileData()
  if not self.hall_req_profile_map or not next(self.hall_req_profile_map) then
    return
  end
  local uidList = {}
  for uid, _ in pairs(self.hall_req_profile_map) do
    table.insert(uidList, uid)
  end
  log_tree("LogicPeakGameHall:ReqHallProfileData uidList", uidList)
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetNormalProfiles(uidList, function(list)
    self.hall_req_profile_map = {}
    if list and next(list) then
      EventSystem:postEvent(EVENTTYPE_PEAKGAME, EVENTID_PEAKGAME_RANK_PROFILE)
    end
  end, Enum_PROFILE_REPORT_CFG.PEAKGAME_RANK_HALL)
end
function LogicPeakGameHall:ReqTopnWeeklyRankData(zone_id, extra_data)
  log(bWriteLog and "LogicPeakGameHall:ReqTopnWeeklyRankData zone_id = " .. tostring(zone_id))
  log_tree("LogicPeakGameHall:ReqTopnWeeklyRankData extra_data = ", extra_data)
  if not LogicPeakGameUtil.IsOpen() then
    log(bWriteLog and "LogicPeakGameHall:ReqTopnWeeklyRankData not open")
    return
  end
  if not zone_id then
    return
  end
  local RankConfig = require("client.slua.logic.rank.rank_config")
  local rank_requird_id = RankConfig.ScoreType.peakgame_week_rating
  if self.weekly_rank_data_list and self.weekly_rank_data_list[zone_id] then
    log(bWriteLog and "LogicPeakGameHall:ReqTopnWeeklyRankData weekly_rank_data_list has cache")
    EventSystem:postEvent(EVENTTYPE_PEAKGAME, EVENTID_GET_PEAKGAME_WEEKLY_RANK_LIST_SUCCESS, rank_requird_id, extra_data)
    return
  end
  extra_data = extra_data or {}
  extra_data.reqFromType = RankConfig.ReqFromType.peakRankHall
  local RankHandler = require("client.network.Protocol.RankHandler")
  RankHandler.send_get_topn_rank(zone_id, rank_requird_id, 1, extra_data)
end
function LogicPeakGameHall:OnGetTopnRankRsp(res, zone_id, rank_requird_id, rank_data_list, extra_data)
  log(bWriteLog and "LogicPeakGameHall:OnGetTopnRankRsp res = " .. tostring(res) .. " zone_id = " .. tostring(zone_id) .. " rank_requird_id = " .. tostring(rank_requird_id))
  log_tree("LogicPeakGameHall:OnGetTopnRankRsp rank_data_list", rank_data_list)
  if not LogicPeakGameUtil.IsOpen() then
    log(bWriteLog and "LogicPeakGameHall:OnGetTopnRankRsp not open")
    return
  end
  if res ~= 0 then
    EventSystem:postEvent(EVENTTYPE_PEAKGAME, EVENTID_GET_PEAKGAME_WEEKLY_RANK_LIST_FAILED, rank_requird_id, extra_data)
    return
  end
  local RankConfig = require("client.slua.logic.rank.rank_config")
  if rank_requird_id ~= RankConfig.ScoreType.peakgame_week_rating then
    return
  end
  self.weekly_rank_data_list[zone_id] = rank_data_list
  EventSystem:postEvent(EVENTTYPE_PEAKGAME, EVENTID_GET_PEAKGAME_WEEKLY_RANK_LIST_SUCCESS, rank_requird_id, extra_data)
end
function LogicPeakGameHall:ReqTopnHofRankData(season_id, zone_id, extra_data)
  log(bWriteLog and "LogicPeakGameHall:ReqTopnHofRankData season_id = " .. tostring(season_id) .. " zone_id = " .. tostring(zone_id))
  log_tree("LogicPeakGameHall:ReqTopnHofRankData extra_data = ", extra_data)
  if not LogicPeakGameUtil.IsOpen() then
    log(bWriteLog and "LogicPeakGameHall:ReqTopnHofRankData not open")
    return
  end
  if not season_id or not zone_id then
    return
  end
  local RankConfig = require("client.slua.logic.rank.rank_config")
  local rank_requird_id = RankConfig.ScoreType.peakgame_hof_rating
  if self.hof_rank_data_list and self.hof_rank_data_list[season_id] and self.hof_rank_data_list[season_id][zone_id] then
    log(bWriteLog and "LogicPeakGameHall:ReqTopnHofRankData hof_rank_data_list has cache")
    EventSystem:postEvent(EVENTTYPE_PEAKGAME, EVENTID_GET_PEAKGAME_HOF_RANK_LIST_SUCCESS, rank_requird_id, extra_data)
    return
  end
  extra_data = extra_data or {}
  extra_data.reqFromType = RankConfig.ReqFromType.peakRankHall
  local PeakGameHandler = require("client.network.Protocol.PeakGameHandler")
  PeakGameHandler.send_get_peakgame_fame_rank_req(rank_requird_id, zone_id, season_id, extra_data)
end
function LogicPeakGameHall:OnGetTopnHofRankData(err_code, rank_list, zone_id, season_id, extra_data)
  log(bWriteLog and "LogicPeakGameHall:OnGetTopnHofRankData")
  if not LogicPeakGameUtil.IsOpen() then
    log(bWriteLog and "LogicPeakGameHall:OnGetTopnHofRankData not open")
    return
  end
  local RankConfig = require("client.slua.logic.rank.rank_config")
  local rank_requird_id = RankConfig.ScoreType.peakgame_hof_rating
  if err_code ~= 0 then
    EventSystem:postEvent(EVENTTYPE_PEAKGAME, EVENTID_GET_PEAKGAME_HOF_RANK_LIST_FAILED, rank_requird_id, extra_data)
    return
  end
  self.hof_rank_data_list[season_id] = self.hof_rank_data_list[season_id] or {}
  self.hof_rank_data_list[season_id][zone_id] = rank_list
  EventSystem:postEvent(EVENTTYPE_PEAKGAME, EVENTID_GET_PEAKGAME_HOF_RANK_LIST_SUCCESS, rank_requird_id, extra_data)
end
function LogicPeakGameHall:ReqAbilityRankData(rank_requird_id, zone_id, extra_data)
  log(bWriteLog and "LogicPeakGameHall:ReqAbilityRankData rank_requird_id = " .. tostring(rank_requird_id) .. " zone_id = " .. tostring(zone_id))
  log_tree("LogicPeakGameHall:ReqAbilityRankData extra_data = ", extra_data)
  if not LogicPeakGameUtil.IsOpen() then
    log(bWriteLog and "LogicPeakGameHall:ReqAbilityRankData not open")
    return
  end
  if not zone_id then
    return
  end
  if self.ability_rank_data_list and self.ability_rank_data_list[rank_requird_id] and self.ability_rank_data_list[rank_requird_id][zone_id] then
    log(bWriteLog and "LogicPeakGameHall:ReqAbilityRankData ability_rank_data_list has cache")
    EventSystem:postEvent(EVENTTYPE_PEAKGAME, EVENTID_GET_PEAKGAME_ABILITU_RANK_LIST_SUCCESS, rank_requird_id, extra_data)
    return
  end
  extra_data = extra_data or {}
  local RankConfig = require("client.slua.logic.rank.rank_config")
  extra_data.reqFromType = RankConfig.ReqFromType.peakRankHall
  local RankHandler = require("client.network.Protocol.RankHandler")
  RankHandler.send_get_topn_rank(zone_id, rank_requird_id, 1, extra_data)
end
function LogicPeakGameHall:OnGetAbilityTopnRankRsp(res, zone_id, rank_requird_id, rank_data_list, extra_data)
  log(bWriteLog and "LogicPeakGameHall:OnGetAbilityTopnRankRsp res = " .. tostring(res) .. " zone_id = " .. tostring(zone_id) .. " rank_requird_id = " .. tostring(rank_requird_id))
  log_tree("LogicPeakGameHall:OnGetAbilityTopnRankRsp rank_data_list", rank_data_list)
  if not LogicPeakGameUtil.IsOpen() then
    log(bWriteLog and "LogicPeakGameHall:OnGetTopnRankRsp not open")
    return
  end
  local RankConfig = require("client.slua.logic.rank.rank_config")
  if rank_requird_id == RankConfig.ScoreType.peakgame_ability_kd_rating then
    for raw_index, raw_rank_data in pairs(rank_data_list or {}) do
      if raw_rank_data.score then
        raw_rank_data.score = raw_rank_data.score / 100
      end
    end
    log_tree(bWriteLog and "LogicPeakGameHall:OnGetAbilityTopnRankRsp rank_data_list = ", rank_data_list)
  end
  if res ~= 0 then
    EventSystem:postEvent(EVENTTYPE_PEAKGAME, EVENTID_GET_PEAKGAME_ABILITU_RANK_LIST_FAILED, rank_requird_id, extra_data)
    return
  end
  self.ability_rank_data_list[rank_requird_id] = self.ability_rank_data_list[rank_requird_id] or {}
  self.ability_rank_data_list[rank_requird_id][zone_id] = rank_data_list
  EventSystem:postEvent(EVENTTYPE_PEAKGAME, EVENTID_GET_PEAKGAME_ABILITU_RANK_LIST_SUCCESS, rank_requird_id, extra_data)
end
function LogicPeakGameHall:ReqWeeklyRankTime()
  log(bWriteLog and "LogicPeakGameHall:ReqWeeklyRankTime")
  if not LogicPeakGameUtil.IsOpen() then
    log(bWriteLog and "LogicPeakGameHall:ReqWeeklyRankTime not open")
    return
  end
  local PeakGameHandler = require("client.network.Protocol.PeakGameHandler")
  PeakGameHandler.send_get_peak_week_rank_time_req()
end
function LogicPeakGameHall:OnGetPeakGameWeeklyRankTime(start_timestamp, end_timestamp)
  log(bWriteLog and "LogicPeakGameHall:OnGetPeakGameWeeklyRankTime")
  if not LogicPeakGameUtil.IsOpen() then
    log(bWriteLog and "LogicPeakGameHall:OnGetPeakGameWeeklyRankTime not open")
    return
  end
  self.weeklyRankTime = {startTimestamp = start_timestamp, endTimestamp = end_timestamp}
  EventSystem:postEvent(EVENTTYPE_PEAKGAME, EVENTID_PEAKGAME_RANK_WEEK_TIME_RSP)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicPeakGameReward = class(CModuleBase, nil, LogicPeakGameHall)
return CLogicPeakGameReward