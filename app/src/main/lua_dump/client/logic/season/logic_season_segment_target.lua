local logic_season_segment_target = {}
local EnumTargetState = {
  NoSet = 0,
  Unachieved = 1,
  Achieved = 2,
  Received = 3
}
local ConquerorSegment = 801
local FirstSegment = 101
function logic_season_segment_target:OnInitialize()
  logic_season_segment_target.__super.OnInitialize(self)
  self:InitData()
end
function logic_season_segment_target:Destory()
  log(bWriteLog and "logic_season_segment_target Destory")
  self:ClearData()
end
function logic_season_segment_target:OnPreSwitchGameStatus(preState, nextState)
  log(bWriteLog and "logic_season_segment_target OnPreSwitchGameStatus")
  self:ClearData()
end
function logic_season_segment_target:OnLogOut()
  log(bWriteLog and "logic_season_segment_target OnLogOut")
  self:ClearData()
end
function logic_season_segment_target:GetSegmentTargetSettingList(lastSeasonBestSegment)
  return self:GetSegmentShowList(lastSeasonBestSegment, true)
end
function logic_season_segment_target:GetSegmentTargetShowList(curSegment)
  return self:GetSegmentShowList(curSegment, false)
end
function logic_season_segment_target:GetLastSeasonBestSegmentAndRating()
  if not (self.segment_target and self.segment_target.rank_ids) or not self.segment_target.rank_ids.highest_rank_last_season then
    log(bWriteLog and "logic_season_segment_target:GetCurSegmentAndRating data is nil")
    return nil, nil
  end
  return self.segment_target.rank_ids.highest_rank_last_season.level, self.segment_target.rank_ids.highest_rank_last_season.score
end
function logic_season_segment_target:GetSegmentTargetStatus()
  if not self.segment_target then
    return nil
  end
  return self.segment_target.segment_target_state
end
function logic_season_segment_target:GetSegmentTargetAllSegmentData()
  if not self.segment_target then
    return nil
  end
  return self.segment_target.rank_ids
end
function logic_season_segment_target:GetCurTargetSegmentIdAndRating()
  if not (self.segment_target and self.segment_target.rank_ids) or not self.segment_target.rank_ids.goal_rank then
    log(bWriteLog and "logic_season_segment_target:GetCurTargetSegmentIdAndRating data is nil")
    return nil, nil
  end
  local goalRank = self.segment_target.rank_ids.goal_rank
  return goalRank.level, goalRank.score
end
function logic_season_segment_target:GetCurMaxSegmentAndRating()
  if not (self.segment_target and self.segment_target.rank_ids) or not self.segment_target.rank_ids.curr_highest_rank then
    log(bWriteLog and "logic_season_segment_target:GetCurSegmentAndRating data is nil")
    return nil, nil
  end
  local curData = self.segment_target.rank_ids.curr_highest_rank
  return curData.level, curData.score
end
function logic_season_segment_target:GetTargetProgressData()
  if not (self.segment_target and self.segment_target.rank_ids) or not self.segment_target.rank_ids.goal_progress then
    log(bWriteLog and "logic_season_segment_target:GetTargetProgressData data is nil")
    return nil, nil
  end
  local goalProgress = self.segment_target.rank_ids.goal_progress
  return goalProgress.goal_complete_percent, goalProgress.today_change_score
end
function logic_season_segment_target:GetTargetSettingReward(segment)
  if not segment then
    log(bWriteLog and "logic_season_segment_target:GetTargetSettingReward segment is nil")
    return nil
  end
  if not self.target_config or not self.target_config.setting_reward then
    log(bWriteLog and "logic_season_segment_target:GetTargetSettingReward setting_reward is nil")
    return nil
  end
  if self.notify_config and self.notify_config.MinTargetSegment and segment < tonumber(self.notify_config.MinTargetSegment) then
    log(bWriteLog and "logic_season_segment_target:GetTargetSettingReward ChangeSegment")
    local minTargetSeg = tonumber(self.notify_config.MinTargetSegment)
    segment = minTargetSeg
  end
  local maxAceSeg = self:GetMaxAceShowSegment()
  if maxAceSeg and segment > maxAceSeg and segment < ConquerorSegment then
    segment = maxAceSeg
  end
  return self.target_config.setting_reward[segment]
end
function logic_season_segment_target:GetCurTargetAchieveReward()
  if not self.segment_target or not self.segment_target.achieve_reward then
    log(bWriteLog and "logic_season_segment_target:GetCurTargetAchieveReward segment_target.achieve_reward is nil")
    return nil
  end
  return self.segment_target.achieve_reward
end
function logic_season_segment_target:GetSegmentAchieveReward(segment)
  if not segment then
    log(bWriteLog and "logic_season_segment_target:GetSegmentAchieveReward segment is nil")
    return nil
  end
  if not self.achieve_reward_list or not next(self.achieve_reward_list) then
    log(bWriteLog and "logic_season_segment_target:GetSegmentAchieveReward achieve_reward_list is nil")
    return nil
  end
  if segment == ConquerorSegment then
    log(bWriteLog and "logic_season_segment_target:GetSegmentAchieveReward achieve_reward_list is ConquerorSegment")
    return self.achieve_reward_list[#self.achieve_reward_list]
  end
  local lastSeasonBestSegment, lastSeasonBestSegmentRating = self:GetLastSeasonBestSegmentAndRating()
  if not lastSeasonBestSegment or not lastSeasonBestSegmentRating then
    log(bWriteLog and "logic_season_segment_target:GetSegmentAchieveReward lastSeasonBestSegment is nil")
    return nil
  end
  local segmentCfg = FuncUtil.GetRankTableData(segment)
  if not segmentCfg or not segmentCfg.MinIntegral then
    log(bWriteLog and "logic_season_segment_target:GetSegmentAchieveReward segmentCfg is nil")
    return nil
  end
  local diff = segmentCfg.MinIntegral - lastSeasonBestSegmentRating
  if diff < 0 then
    diff = 0
  end
  local rewardData
  for _, data in ipairs(self.achieve_reward_list) do
    if lastSeasonBestSegment >= data.rank_min and lastSeasonBestSegment <= data.rank_max then
      if diff >= data.rank_diff then
        rewardData = data
      else
        break
      end
    end
  end
  return rewardData
end
function logic_season_segment_target:GetSeasonRemainDays()
  if not self.segment_target or not self.segment_target.season_info then
    log(bWriteLog and "logic_season_segment_target:GetSeasonRemainDays setting_reward is nil")
    return nil
  end
  return self.segment_target.season_info.remain_days
end
function logic_season_segment_target:CheckAndGetSeasonRemainDays()
  if not self.notify_config or not self.notify_config.season_end_notify_day then
    log(bWriteLog and "logic_season_segment_target:CheckAndGetSeasonRemainDays notify_config is nil")
    return false, nil
  end
  local remainDays = self:GetSeasonRemainDays()
  if remainDays <= tonumber(self.notify_config.season_end_notify_day) then
    return true, remainDays
  end
  return false, nil
end
function logic_season_segment_target:ConvertSegmentShowId(segment)
  if not segment then
    log(bWriteLog and "logic_season_segment_target:ConvertSegment Segment is nil")
    return nil
  end
  local maxAceSeg = self:GetMaxAceShowSegment()
  if maxAceSeg and segment > maxAceSeg and segment < ConquerorSegment then
    segment = maxAceSeg
  end
  return segment
end
function logic_season_segment_target:GetMaxAceShowSegment()
  if not self.notify_config then
    return 724, "5600+", "15+"
  end
  local MaxAceShowSegment = tonumber(self.notify_config.MaxAceShowSegment or 724)
  local MaxAceShowRating = self.notify_config.MaxAceShowRating or "5600+"
  local MaxAceShowStarNum = self.notify_config.MaxAceShowStarNum or "15+"
  return MaxAceShowSegment, MaxAceShowRating, MaxAceShowStarNum
end
function logic_season_segment_target:GetConquerorShowData()
  if not (self.segment_target and self.segment_target.rank_ids) or not self.segment_target.rank_ids.curr_highest_rank then
    log(bWriteLog and "logic_season_segment_target:GetCurSegmentAndRating data is nil")
    return nil, nil
  end
  local curData = self.segment_target.rank_ids.curr_highest_rank
  return curData.mode, curData.god_score
end
function logic_season_segment_target:CheckCanGetNewTargetAchieveReward(segment)
  if not segment then
    log(bWriteLog and "logic_season_segment_target:CheckCanGetNewTargetAchieveReward segment is nil")
    return false
  end
  if not self:CheckSwitchOpen() then
    log(bWriteLog and "logic_season_segment_target:CheckCanGetNewTargetAchieveReward switch close")
    return false
  end
  local curMaxSeg = self:GetCurMaxSegmentAndRating()
  if not curMaxSeg or segment > curMaxSeg then
    log(bWriteLog and "logic_season_segment_target:CheckCanGetNewTargetAchieveReward false")
    return false
  end
  log(bWriteLog and "logic_season_segment_target:CheckCanGetNewTargetAchieveReward true")
  return true
end
function logic_season_segment_target:CheckShouldSlapInSeason()
  if not self:CheckSwitchOpen() then
    log(bWriteLog and "logic_season_segment_target:CheckShouldSlapInSeason switch close")
    return false
  end
  if not self.segment_target then
    log(bWriteLog and "logic_season_segment_target:CheckShouldSlapInSeason no data")
    return false
  end
  if not self.should_slap_flag then
    log(bWriteLog and "logic_season_segment_target:CheckShouldSlapInSeason false 1")
    return false
  end
  local targetStatus = self:GetSegmentTargetStatus()
  if not targetStatus then
    log(bWriteLog and "logic_season_segment_target:CheckShouldSlapInSeason false 2")
    return false
  end
  log(bWriteLog and "logic_season_segment_target:CheckShouldSlapInSeason targetStatus:" .. tostring(targetStatus))
  return targetStatus == EnumTargetState.NoSet
end
function logic_season_segment_target:UpdateSlapFlag()
  self.should_slap_flag = false
end
function logic_season_segment_target:CheckSwitchOpen()
  if not (DataMgr and DataMgr.season_id) or not self.start_sesaon then
    return false
  end
  log(bWriteLog and "logic_season_segment_target:CheckSwitchOpen start_sesaon:" .. tostring(self.start_sesaon) .. " curSeason:" .. tostring(DataMgr.season_id))
  return DataMgr.season_id >= self.start_sesaon
end
function logic_season_segment_target:GetProgressShowData()
  if not self.progress_id_list then
    return {}
  end
  return {
    self.progress_id_list[1],
    self.progress_id_list[2]
  }
end
function logic_season_segment_target:GetCheckIsShowPlusSegmentInProgress(segment)
  local progressRewardPlusSegment = self:GetProgressRewardPlusSegment()
  local logic_season_const = require("client.logic.season.logic_season_const")
  return segment >= progressRewardPlusSegment.segment and segment ~= logic_season_const.ClassicSeasonSegmentID_Conqueror
end
function logic_season_segment_target:GetProgressRewardData(segment)
  return self.progress_reward and self.progress_reward[segment]
end
function logic_season_segment_target:GetProgressRewardRedPoint()
  if not self.progress_reward then
    return false
  end
  local EClassicProgressRewardStatus = require("client.logic.season.logic_season_const").EClassicProgressRewardStatus
  local showData = self:GetProgressShowData()
  for _, v in pairs(showData) do
    local segment = v.Level
    if segment then
      local rewardData = self:GetProgressRewardData(segment)
      if rewardData and rewardData.status == EClassicProgressRewardStatus.HasAchieved then
        return true
      end
    end
  end
  return false
end
function logic_season_segment_target:GetProgressRewardPlusSegment()
  if not self.progressRewardPlusSegment then
    self.progressRewardPlusSegment = {}
    local SegmentTargetParamConfig = CDataTable.GetTable("SegmentTargetParamConfig")
    for k, v in pairs(SegmentTargetParamConfig) do
      if v.ParamName == "MaxAceShowSegment" then
        self.progressRewardPlusSegment.segment = tonumber(v.ParamValue)
      elseif v.ParamName == "MaxAceShowRating" then
        self.progressRewardPlusSegment.showRating = v.ParamValue
      elseif v.ParamName == "MaxAceShowStarNum" then
        self.progressRewardPlusSegment.showStarNum = v.ParamValue
      end
    end
    log_tree("logic_season_segment_target:GetProgressRewardPlusSegment self.progressRewardPlusSegment = ", self.progressRewardPlusSegment)
  end
  return self.progressRewardPlusSegment
end
function logic_season_segment_target:GetOpenPanelConfig(isTarget)
  local ProgressStartSeason = CDataTable.GetTableData("SegmentTargetParamConfig", "ProgressStartSeason")
  local openSeason = ProgressStartSeason and tonumber(ProgressStartSeason.ParamValue) or 0
  local currentSeason = DataMgr.season_id or 0
  if openSeason <= currentSeason then
    return UIManager.UI_Config.Lobby_Season_Target_Tab_UIBP
  end
  return isTarget and UIManager.UI_Config.Lobby_Season_Target_UIBP or UIManager.UI_Config.Lobby_Season_Target_Setting_UIBP
end
function logic_season_segment_target:send_get_segment_target_info_req()
  log(bWriteLog and "logic_season_segment_target:send_get_segment_target_info_req")
  local SeasonSegmentTargetHandler = require("client.network.Protocol.SeasonSegmentTargetHandler")
  SeasonSegmentTargetHandler.send_get_segment_target_info_req()
end
function logic_season_segment_target:on_get_segment_target_info_rsp(segment_target, target_config, notify_config, progress_reward)
  log(bWriteLog and "logic_season_segment_target:on_get_segment_target_info_rsp")
  if segment_target then
    self.    self.should_slap_flag = segment_target.pop_up_flag == 0
  end
  if target_config then
    self.    if target_config.achieve_reward and next(target_config.achieve_reward) then
      self.achieve_reward_list = target_config.achieve_reward
      table.sort(self.achieve_reward_list, function(a, b)
        if a.rank_min == b.rank_min then
          return a.rank_diff < b.rank_diff
        else
          return a.rank_min < b.rank_min
        end
      end)
    end
  end
  if notify_config then
    self.    if notify_config.StartSeason then
      self.start_sesaon = tonumber(notify_config.StartSeason)
    end
  end
  if segment_target and segment_target.progress_goals then
    self:UpdateProgressReward(segment_target.progress_goals)
  end
  EventSystem:postEvent(EVENTTYPE_SEGMENT_TARGET, EVENTID_SEGMENT_TARGET_GET_INFO_RSP)
end
function logic_season_segment_target:send_set_segment_target_rank_req(targetSegmentid)
  log(bWriteLog and "logic_season_segment_target:send_set_segment_target_rank_req")
  if not targetSegmentid then
    log(bWriteLog and "logic_season_segment_target:send_set_segment_target_rank_req targetSegmentid is nil")
    return
  end
  local SeasonSegmentTargetHandler = require("client.network.Protocol.SeasonSegmentTargetHandler")
  SeasonSegmentTargetHandler.send_set_segment_target_rank_req(targetSegmentid)
end
function logic_season_segment_target:on_set_segment_target_rank_rsp(segment_target, reward_list)
  log(bWriteLog and "logic_season_segment_target:on_set_segment_target_rank_rsp")
  if segment_target then
    self.  end
  if reward_list and 0 < #reward_list then
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle(reward_list)
  end
  EventSystem:postEvent(EVENTTYPE_SEGMENT_TARGET, EVENTID_SEGMENT_TARGET_SET_RSP)
end
function logic_season_segment_target:send_get_segment_target_award_req()
  log(bWriteLog and "logic_season_segment_target:send_get_segment_target_award_req")
  local status = self:GetSegmentTargetStatus()
  if not status or status ~= EnumTargetState.Achieved then
    log(bWriteLog and "logic_season_segment_target:send_get_segment_target_award_req not accomplish")
    return
  end
  local SeasonSegmentTargetHandler = require("client.network.Protocol.SeasonSegmentTargetHandler")
  SeasonSegmentTargetHandler.send_get_segment_target_award_req()
end
function logic_season_segment_target:on_get_segment_target_award_rsp(segment_target, reward_list)
  log(bWriteLog and "logic_season_segment_target:on_get_segment_target_award_rsp")
  if segment_target then
    self.  end
  if reward_list and 0 < #reward_list then
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle(reward_list)
  end
  EventSystem:postEvent(EVENTTYPE_SEGMENT_TARGET, EVENTID_SEGMENT_TARGET_TAKE_AWARD_RSP)
end
function logic_season_segment_target:send_report_segment_target_pop_up_req()
  log(bWriteLog and "logic_season_segment_target:send_report_segment_target_pop_up_req")
  if not (self.segment_target and self.segment_target.pop_up_flag) or self.segment_target.pop_up_flag ~= 0 then
    log(bWriteLog and "logic_season_segment_target:send_report_segment_target_pop_up_req has report")
    return
  end
  local SeasonSegmentTargetHandler = require("client.network.Protocol.SeasonSegmentTargetHandler")
  SeasonSegmentTargetHandler.send_report_segment_target_pop_up_req()
end
function logic_season_segment_target:on_report_segment_target_pop_up_rsp()
  log(bWriteLog and "logic_season_segment_target:on_report_segment_target_pop_up_rsp")
  if not self.segment_target then
    log(bWriteLog and "logic_season_segment_target:on_report_segment_target_pop_up_rsp no data")
    return
  end
  self.segment_target.pop_up_flag = 1
end
function logic_season_segment_target:send_get_segment_progress_award_req(segment)
  if not self.progress_reward then
    return
  end
  local SeasonSegmentTargetHandler = require("client.network.Protocol.SeasonSegmentTargetHandler")
  SeasonSegmentTargetHandler.send_get_segment_progress_award_req(segment)
end
function logic_season_segment_target:on_get_segment_progress_award_rsp(progress_reward, reward_list)
  log(bWriteLog and "logic_season_segment_target:on_get_segment_progress_award_rsp")
  if progress_reward then
    self:UpdateProgressReward(progress_reward)
  end
  if reward_list then
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    local showData = {}
    for itemID, itemCount in pairs(reward_list) do
      table.insert(showData, {resid = itemID, count = itemCount})
    end
    Logic_CommonItemGet.ShowPanel_DefaultStyle(showData)
  end
  EventSystem:postEvent(EVENTTYPE_SEGMENT_TARGET, EVENTID_SEGMENT_PROGRESS_TAKE_AWARD_RSP)
end
function logic_season_segment_target:InitData()
  log(bWriteLog and "logic_season_segment_target:InitData")
  self.segment_target = nil
  self.target_config = nil
  self.notify_config = nil
  self.achieve_reward_list = nil
  self.start_sesaon = nil
  self.should_slap_flag = false
  self.progress_reward = nil
  self.progress_id_list = nil
end
function logic_season_segment_target:ClearData()
  log(bWriteLog and "logic_season_segment_target:ClearData")
  self.segment_target = nil
  self.target_config = nil
  self.notify_config = nil
  self.achieve_reward_list = nil
  self.start_sesaon = nil
  self.should_slap_flag = false
  self.progress_reward = nil
  self.progress_id_list = nil
end
function logic_season_segment_target:GetSegmentShowList(segment, ifTargetSetting)
  if not segment then
    log(bWriteLog and "logic_season_segment_target:GetSegmentShowList Segment is nil")
    return nil
  end
  log(bWriteLog and "logic_season_segment_target:GetSegmentShowList, lastSeasonBestSegment:" .. tostring(segment) .. " ifTargetSetting:" .. tostring(ifTargetSetting))
  if not self:CheckSwitchOpen() then
    log(bWriteLog and "logic_season_segment_target:GetSegmentShowList switch close")
    return nil
  end
  local maxAceSeg = self:GetMaxAceShowSegment()
  if maxAceSeg and segment > maxAceSeg and segment < ConquerorSegment then
    segment = maxAceSeg
  end
  if not self.target_config or not self.target_config.can_set_goal_ids then
    log(bWriteLog and "logic_season_segment_target:GetSegmentShowList config is nil")
    return nil
  end
  local segmentTargetList = self.target_config.can_set_goal_ids
  local rankIntegralLevel = FuncUtil.GetRankTable()
  if not rankIntegralLevel then
    log(bWriteLog and "logic_season_segment_target:GetSegmentShowList rankconfig is nil")
    return nil
  end
  local targetList = {}
  for segId, isTarget in pairs(segmentTargetList) do
    if segId and segId >= segment and rankIntegralLevel[segId] then
      local isValid = isTarget == 1
      if not ifTargetSetting then
        isValid = true
      end
      if isValid then
        local target = {
          segment = segId,
          rating = rankIntegralLevel[segId].MinIntegral or 0,
          isConqueror = false
        }
        if segId == ConquerorSegment then
          local _, ConquerorScore = self:GetConquerorShowData()
          if ConquerorScore then
            target.rating = ConquerorScore
          end
          target.isConqueror = true
        elseif segId == FirstSegment then
          target.rating = rankIntegralLevel[segId].NextSeasonIntegralScore or 1500
        end
        table.insert(targetList, target)
      end
    end
  end
  table.sort(targetList, function(a, b)
    return a.segment < b.segment
  end)
  return targetList
end
function logic_season_segment_target:UpdateProgressReward(data)
  if not data then
    log(bWriteLog and "logic_season_segment_target:UpdateProgressReward data is nil")
    return
  end
  self.progress_reward = data
  log_tree("logic_season_segment_target:UpdateProgressReward progress_reward = ", self.progress_reward)
  self.progress_id_list = {}
  for rankID, v in pairs(self.progress_reward) do
    local rankCfg = FuncUtil.GetRankTableData(rankID)
    if rankCfg then
      table.insert(self.progress_id_list, {
        Level = rankID,
        IntegralTypeNew = rankCfg.IntegralTypeNew
      })
    else
      log_warning(bWriteLog and "logic_season_segment_target:UpdateProgressReward rankID = " .. tostring(rankID) .. " rankCfg is nil")
    end
  end
  table.sort(self.progress_id_list, function(a, b)
    local typeA = a.IntegralTypeNew
    local typeB = b.IntegralTypeNew
    if typeA == typeB then
      return a.Level < b.Level
    end
    return typeA < typeB
  end)
  log_tree("logic_season_segment_target:UpdateProgressReward progress_id_list = ", self.progress_id_list)
  local redPoint = 0
  local EClassicProgressRewardStatus = require("client.logic.season.logic_season_const").EClassicProgressRewardStatus
  for _, v in pairs(self.progress_id_list) do
    local segment = v.Level
    if segment then
      local rewardData = self:GetProgressRewardData(segment)
      if rewardData and rewardData.status == EClassicProgressRewardStatus.HasAchieved then
        redPoint = 1
        break
      end
    end
  end
  local season_redpoint_data = require("client.logic.season.red_point.season_redpoint_data")
  season_redpoint_data.SetRedByType(season_redpoint_data.ReddotType.classicProgressReward, redPoint)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicSeasonSegmentTarget = class(CModuleBase, nil, logic_season_segment_target)
return CLogicSeasonSegmentTarget