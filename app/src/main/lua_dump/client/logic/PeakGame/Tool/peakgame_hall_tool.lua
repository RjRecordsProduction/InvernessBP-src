local peakgame_hall_tool = {}
function peakgame_hall_tool.IsWeeklyRank(rank_requird_id, extra_data)
  log(bWriteLog and "peakgame_hall_tool.IsWeeklyRank rank_requird_id = " .. tostring(rank_requird_id))
  log_tree("peakgame_hall_tool.IsWeeklyRank extra_data = ", extra_data)
  local RankConfig = require("client.slua.logic.rank.rank_config")
  if extra_data and extra_data.reqFromType ~= RankConfig.ReqFromType.peakRankHall then
    return false
  end
  if rank_requird_id == RankConfig.ScoreType.peakgame_week_rating then
    return true
  end
  return false
end
function peakgame_hall_tool.CheckAbilityRank(rank_requird_id, extra_data)
  log(bWriteLog and "peakgame_hall_tool.CheckAbilityRank rank_requird_id = " .. tostring(rank_requird_id))
  log_tree("peakgame_hall_tool.CheckAbilityRank extra_data = ", extra_data)
  local RankConfig = require("client.slua.logic.rank.rank_config")
  if extra_data and extra_data.reqFromType ~= RankConfig.ReqFromType.peakRankHall then
    return false
  end
  return peakgame_hall_tool.IsAbilityRank(rank_requird_id)
end
function peakgame_hall_tool.IsAbilityRank(rank_requird_id)
  log(bWriteLog and "peakgame_hall_tool.IsAbilityRank rank_requird_id = " .. tostring(rank_requird_id))
  local RankConfig = require("client.slua.logic.rank.rank_config")
  if rank_requird_id == RankConfig.ScoreType.peakgame_ability_kd_rating or rank_requird_id == RankConfig.ScoreType.peakgame_ability_solo_win_total_rating or rank_requird_id == RankConfig.ScoreType.peakgame_ability_multi_win_total_rating or rank_requird_id == RankConfig.ScoreType.peakgame_ability_squad_win_total_rating then
    return true
  end
  return false
end
function peakgame_hall_tool.GetAbilityComboboxData()
  log(bWriteLog and "peakgame_hall_tool.GetAbilityComboboxData")
  local RankConfig = require("client.slua.logic.rank.rank_config")
  local abilityRank = {
    [1] = {
      text = LocUtil.GetLocalizeResStr(68550),
      rank_requird_id = RankConfig.ScoreType.peakgame_ability_kd_rating
    },
    [2] = {
      text = LocUtil.GetLocalizeResStr(68551),
      rank_requird_id = RankConfig.ScoreType.peakgame_ability_solo_win_total_rating
    },
    [3] = {
      text = LocUtil.GetLocalizeResStr(68552),
      rank_requird_id = RankConfig.ScoreType.peakgame_ability_multi_win_total_rating
    },
    [4] = {
      text = LocUtil.GetLocalizeResStr(68553),
      rank_requird_id = RankConfig.ScoreType.peakgame_ability_squad_win_total_rating
    }
  }
  return abilityRank
end
function peakgame_hall_tool.GetAbilityRankRewardData(requireRankId, rankNo, season_id)
  log(bWriteLog and "peakgame_hall_tool.GetAbilityRankRewardData requireRankId = " .. tostring(requireRankId) .. " rankNo = " .. tostring(rankNo) .. " season_id = " .. tostring(season_id))
  if not (requireRankId and rankNo) or rankNo <= 0 or not season_id then
    return nil
  end
  if not peakgame_hall_tool.IsAbilityRank(requireRankId) then
    return nil
  end
  local RankDataMgr = require("client.slua.logic.rank.rank_data_mgr")
  local rewardCfg
  local rewardTableCfg = CDataTable.GetTableByFilter("RankRewardTable", "RankType", requireRankId, "SeasonId", season_id)
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
function peakgame_hall_tool.GetAbilityRankTitleCfg()
  log(bWriteLog and "peakgame_hall_tool.GetAbilityRankTitleCfg")
  local titleCfg = {
    [1] = LocUtil.GetLocalizeResStr(68550),
    [2] = LocUtil.GetLocalizeResStr(68551),
    [3] = LocUtil.GetLocalizeResStr(68552),
    [4] = LocUtil.GetLocalizeResStr(68553)
  }
  return titleCfg
end
return peakgame_hall_tool