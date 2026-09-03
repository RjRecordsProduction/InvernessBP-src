local logic_popular_pk_fun_awards = {}
function logic_popular_pk_fun_awards:DefineAndResetData()
  self.fun_awards_configs = nil
  self.top_rank_data = {}
  self.my_rank_data = {}
end
function logic_popular_pk_fun_awards:OnInitialize()
  self:send_get_topn_rank(72041)
end
function logic_popular_pk_fun_awards:GetFunAwardsConfigs()
  if self.fun_awards_configs then
    return self.fun_awards_configs
  end
  self.fun_awards_configs = {}
  local fun_awards_configs = CDataTable.GetTable("PopularityFunAwardsCfg")
  for _, cfg in pairs(fun_awards_configs) do
    self.fun_awards_configs[cfg.ID] = {
      ID = cfg.ID,
      Name = cfg.Name,
      Content = cfg.Content,
      RankID = cfg.RankID
    }
    local rank_reward_config = CDataTable.GetTableDataByFilter("RankRewardTable", "RankType", cfg.RankID)
    if rank_reward_config then
      self.fun_awards_configs[cfg.ID].AwardID = rank_reward_config.RewardItemID1
      self.fun_awards_configs[cfg.ID].AwardCount = rank_reward_config.RewardItemCnt1
      self.fun_awards_configs[cfg.ID].AwardLimitTime = rank_reward_config.RewardItemTimeLimit1
    end
  end
  log_tree(bWriteLog and "logic_popular_pk_fun_awards:GetFunAwardsConfigs self.fun_awards_configs", self.fun_awards_configs)
  return self.fun_awards_configs
end
function logic_popular_pk_fun_awards:GetFunAwardsTop1Data(rank_id)
  return self.top_rank_data[rank_id]
end
function logic_popular_pk_fun_awards:GetMyFunAwardsData(rank_id)
  return self.my_rank_data[rank_id]
end
function logic_popular_pk_fun_awards:IsPopularPKFunAwardsRank(rank_id)
  local configs = self:GetFunAwardsConfigs()
  for _, v in pairs(configs) do
    if v.RankID == rank_id then
      return true
    end
  end
  return false
end
function logic_popular_pk_fun_awards:send_get_topn_rank(rank_id)
  log(bWriteLog and "logic_popular_pk_fun_awards:send_get_topn_rank")
  local RankHandler = require("client.network.Protocol.RankHandler")
  RankHandler.send_get_topn_rank(0, rank_id, 1, {})
end
function logic_popular_pk_fun_awards:proc_get_topn_rank_rsp(res, rank_requird_id, rank_data_list)
  local RankConfig = require("client.slua.logic.rank.rank_config")
  if rank_requird_id == RankConfig.ScoreType.star_gift_giver_rating or rank_requird_id == RankConfig.ScoreType.star_most_gifted_rating or rank_requird_id == RankConfig.ScoreType.star_generosity_rating or rank_requird_id == RankConfig.ScoreType.star_wide_friend_rating or rank_requird_id == RankConfig.ScoreType.star_lucky_chicken_rating or rank_requird_id == RankConfig.ScoreType.star_golden_jet_rating then
    log(bWriteLog and string.format("logic_popular_pk_fun_awards:proc_get_topn_rank_rsp, res:%s", res))
    log(bWriteLog and string.format("logic_popular_pk_fun_awards:proc_get_topn_rank_rsp, rankID:%s", rank_requird_id))
    log_tree(bWriteLog and "logic_popular_pk_fun_awards:proc_get_topn_rank_rsp rank_data_list", rank_data_list)
  end
  if res == 0 then
    local TableUtil = require("common.table_util")
    self.top_rank_data[rank_requird_id] = TableUtil.CopyTable(rank_data_list[1])
    log_tree(bWriteLog and "logic_popular_pk_fun_awards:proc_get_topn_rank_rsp self.top_rank_data:", self.top_rank_data)
  end
  EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULAR_GIFT_PK_FUN_AWARD_RANK_UPDATE_LIST)
  local callback = function(profiles)
    log_tree(bWriteLog and "logic_home_car_parking_rank:proc_get_topn_rank_rsp callback profiles", profiles)
    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULAR_GIFT_PK_FUN_AWARD_RANK_UPDATE_ITEM)
  end
  if self.top_rank_data[rank_requird_id] and next(self.top_rank_data[rank_requird_id]) then
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles({
      tonumber(self.top_rank_data[rank_requird_id].uid)
    }, callback, Enum_PROFILE_REPORT_CFG.POPULARITY_PK, 0, true)
  end
end
function logic_popular_pk_fun_awards:send_get_one_user_rank(rank_id)
  log(bWriteLog and "logic_popular_pk_fun_awards:send_get_one_user_rank")
  local RankHandler = require("client.network.Protocol.RankHandler")
  RankHandler.send_get_one_user_rank("PopularityPKFunAwards", 0, 0, rank_id)
  self.my_rank_data[rank_id] = {}
end
function logic_popular_pk_fun_awards:proc_get_one_user_rank(rank_source, res, rank_info)
  if rank_source == "PopularityPKFunAwards" and res == 0 and rank_info and rank_info.score_type then
    rank_info = rank_info or {}
    local TableUtil = require("common.table_util")
    self.my_rank_data[rank_info.score_type] = TableUtil.CopyTable(rank_info)
  end
  if rank_source == "PopularityPKFunAwards" then
    log(bWriteLog and string.format("logic_popular_pk_fun_awards:proc_get_one_user_rank, res:%s", res))
    log_tree(bWriteLog and "logic_popular_pk_fun_awards:proc_get_one_user_rank rank_info", rank_info)
    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULAR_GIFT_PK_FUN_AWARD_RANK_UPDATE_SELF)
  end
end
function logic_popular_pk_fun_awards:RankDataEqual(data1, data2)
  if data1 == nil or data2 == nil then
    return false
  end
  local bUid = tonumber(data1.uid) == tonumber(data2.uid)
  local bRankNo = data1.rank_no == data2.rank_no
  local bScore = data1.score == data2.score
  if bUid and bRankNo and bScore then
    log(bWriteLog and "logic_popular_pk_fun_awards:RankDataEqual return true")
    return true
  end
  if not bUid then
    log(bWriteLog and string.format("logic_popular_pk_fun_awards:RankDataEqual return false, uid1:%s, uid2:%s", tostring(data1.uid), tostring(data2.uid)))
  end
  if not bRankNo then
    log(bWriteLog and string.format("logic_popular_pk_fun_awards:RankDataEqual return false, rank_no1:%s, rank_no2:%s", tostring(data1.rank_no), tostring(data2.rank_no)))
  end
  if not bScore then
    log(bWriteLog and string.format("logic_popular_pk_fun_awards:RankDataEqual return false, score1:%s, score2:%s", tostring(data1.score), tostring(data2.score)))
  end
  return false
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_popular_pk_fun_awards = class(CModuleBase, nil, logic_popular_pk_fun_awards)
return Clogic_popular_pk_fun_awards