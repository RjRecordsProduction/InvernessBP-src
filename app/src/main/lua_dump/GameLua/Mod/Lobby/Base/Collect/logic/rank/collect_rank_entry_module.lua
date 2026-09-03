local collect_rank_entry_module = {}
function collect_rank_entry_module:GetActivityID()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if GlobalData.IsJapanOrKorea() then
    return ActivityFixedID.RANK_COLLEC_RANK_JK
  elseif Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
    return ActivityFixedID.RANK_COLLEC_RANK_IN
  else
    return ActivityFixedID.RANK_COLLEC_RANK
  end
end
function collect_rank_entry_module:GetActivityAward()
  local activityID = self:GetActivityID()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local activity = ActivityNewSystem.GetServerDataByID(activityID)
  if not activity then
    log(bWriteLog and string.format("Collect_TimeLimitedRanking_UIBP:RefreshActivityAward act data is nil. self.activityID = %s", self.activityID))
    return
  end
  local actConfig = activity.cfg
  local actData = activity.data
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  if not actConfig or not actData then
    log(bWriteLog and string.format("collect_rank_season_module:GetActivityAward actConfig or actData is nil"))
    return
  end
  if not actConfig.start_time or now < actConfig.start_time then
    log(bWriteLog and string.format("collect_rank_season_module:GetActivityAward actConfig.start_time = %s", actConfig.start_time))
    return
  end
  if not actConfig.end_time or now > actConfig.end_time then
    log(bWriteLog and string.format("collect_rank_season_module:GetActivityAward actConfig.end_time = %s", actConfig.end_time))
    return
  end
  local curScore = 0
  if actData.other and actData.other.total_score then
    curScore = actData.other.total_score
  end
  local curIndex = 0
  local awardStatus = actData.award or {}
  for i, v in ipairs(awardStatus) do
    if v.status ~= ActivityProgressStatus.Get and v.status ~= ActivityProgressStatus.Expired then
      curIndex = i
      break
    end
  end
  if curIndex == 0 then
    curIndex = #awardStatus
  end
  local awardConfig = actConfig.award[1]
  local cond = 0
  if awardConfig.cond_list then
    cond = awardConfig.cond_list[curIndex]
  end
  local award = awardConfig.drop[curIndex]
  log(bWriteLog and string.format("collect_rank_season_module:RefreshActivityAward curScore = %s", curScore))
  log(bWriteLog and string.format("collect_rank_season_module:GetActivityAward curIndex = %s", curIndex))
  log_tree("collect_rank_season_module:RefreshActivityAward awardStatus", awardStatus)
  log_tree("collect_rank_season_module:RefreshActivityAward cond_list", awardConfig.cond_list)
  log_tree("collect_rank_season_module:RefreshActivityAward awardConfig.drop", awardConfig.drop)
  return award, curIndex, awardStatus[curIndex].status, cond, curScore
end
function collect_rank_entry_module:GetActivityEndTime()
  local activityID = self:GetActivityID()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local activity = ActivityNewSystem.GetServerDataByID(activityID)
  if not activity then
    log(bWriteLog and string.format("Collect_TimeLimitedRanking_UIBP:RefreshActivityAward act data is nil. self.activityID = %s", self.activityID))
    return
  end
  local actConfig = activity.cfg
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  if actConfig and actConfig.start_time and now >= actConfig.start_time and actConfig.end_time and now <= actConfig.end_time then
    return actConfig.end_time
  end
  return
end
local class = require("class")
local collect_rank_module = require("GameLua.Mod.Lobby.Base.Collect.logic.rank.collect_rank_module_base")
local CModuleTemplate = class(collect_rank_module, nil, collect_rank_entry_module)
return CModuleTemplate