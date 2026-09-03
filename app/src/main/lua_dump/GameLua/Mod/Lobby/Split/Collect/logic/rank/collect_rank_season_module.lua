local collect_rank_season_module = {}
function collect_rank_season_module:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_ACTIVITY, EVEMTID_DATAMGR_ACTIVITY_REWARDS_COMMON, self.OnRewardsGet, self)
end
function collect_rank_season_module:OnRewardsGet(_, _, activityId, arrayItemData)
  local collect_rank_entry_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_rank_entry_module)
  if activityId ~= collect_rank_entry_module:GetActivityID() then
    return
  end
  local collect_rank_entry_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_rank_entry_module)
  local award, curIndex, status, cond, curScore = collect_rank_entry_module:GetActivityAward()
  if award then
    local roleinfo_red_data = require("client.logic.roleinfo.roleinfo_red_data")
    roleinfo_red_data.SetCollectRankRed(status == ActivityProgressStatus.Done)
  end
end
function collect_rank_season_module:CustomizeDerivedConfig()
  if GlobalData.IsJapanOrKorea() then
    self.rankID = 73006
  else
    self.rankID = 73004
  end
  self.userRankMark = "CollectActPersonRank"
  self.profileScene = Enum_PROFILE_REPORT_CFG.COLLECT_RANK_ACT
end
function collect_rank_season_module:GetActivityID()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if GlobalData.IsJapanOrKorea() then
    return ActivityFixedID.RANK_COLLEC_RANK_JK
  elseif Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
    return ActivityFixedID.RANK_COLLEC_RANK_IN
  else
    return ActivityFixedID.RANK_COLLEC_RANK
  end
end
function collect_rank_season_module:GetActivityCurrentScore()
  local collect_rank_entry_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_rank_entry_module)
  local activityID = collect_rank_entry_module:GetActivityID()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local activity = ActivityNewSystem.GetServerDataByID(activityID)
  if not activity then
    log(bWriteLog and string.format("Collect_TimeLimitedRanking_UIBP:RefreshActivityAward act data is nil. self.activityID = %s", self.activityID))
    return 0
  end
  local actData = activity.data
  local curScore = 0
  if actData.other and actData.other.total_score then
    curScore = actData.other.total_score
  end
  return curScore
end
local class = require("class")
local collect_rank_module = require("GameLua.Mod.Lobby.Base.Collect.logic.rank.collect_rank_module_base")
local CModuleTemplate = class(collect_rank_module, nil, collect_rank_season_module)
return CModuleTemplate