local rank_util = {}
local rank_data_mgr = require("client.slua.logic.rank.rank_data_mgr")
local RankConfig = require("client.slua.logic.rank.rank_config")
function rank_util.calc_topn_percentage(score, tenThousand, rankType, rankNo, maxRank)
  maxRank = maxRank or 10000
  if rankNo ~= nil and 0 < rankNo and rankNo <= maxRank then
    return tostring(rankNo)
  end
  if tenThousand == nil or score == nil or tenThousand == 0 then
    return tostring(LocUtil.GetLocalizeResStr(102127))
  end
  local middle_score = 0
  if rank_data_mgr.IsClassicRanking(rankType) then
    local mod = 1080
    if rankType == RankConfig.RankSelectEnum.win or rankType == RankConfig.RankSelectEnum.beat then
      mod = 900
    end
    middle_score = (score - mod) / (tenThousand - mod) * 5 - 1
  else
    middle_score = score / tenThousand * 5 - 1
  end
  local cTemp = (1 / (1 + math.exp(-0.65 * middle_score)) - 0.5) * 1.72 + 0.2585
  local miTemp = math.min(cTemp, 1)
  local maTemp = math.max(miTemp, 0)
  local nLeft = maTemp % 0.01
  maTemp = maTemp - nLeft
  local percentage = (1 - maTemp) * 100
  log(bWriteLog and "[rank_util] calc_topn_percentage percentage" .. percentage)
  if percentage == 0 then
    return tostring(LocUtil.GetLocalizeResStr(102127))
  end
  local tFormat = LocUtil.GetLocalizeResStr(108036)
  return string.format(tFormat, percentage)
end
function rank_util.FilterPlatformsFriendList(friend_list)
  local rankSelectType = rank_data_mgr.GetRankSelectType()
  if rankSelectType ~= RankConfig.RankSelectEnum.upass and rankSelectType ~= RankConfig.RankSelectEnum.achievement then
    return friend_list
  end
  local post_filter_list = {}
  if FuncUtil.IsPlayerJPKR() then
    for _, uid in ipairs(friend_list) do
      if not FuncUtil.IsUidGlobal(uid) then
        table.insert(post_filter_list, uid)
      end
    end
  else
    for _, uid in ipairs(friend_list) do
      if not FuncUtil.IsUidJPKR(uid) then
        table.insert(post_filter_list, uid)
      end
    end
  end
  return post_filter_list
end
function rank_util.RankScoreRound(score)
  score = score or 0
  return math.floor(score + 0.5 + FLOAT_NUMBER_TRAIL)
end
function rank_util.GetRankRewardCfg(nRankId, bIsCheckJK)
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if bIsCheckJK and PublishRegionMacros.IsJapanOrKorea() and CDataTable.GetTableDataByFilter("JKRankRewardTable", "RankType", nRankId) then
    return CDataTable.GetTableByFilter("JKRankRewardTable", "RankType", nRankId)
  end
  return CDataTable.GetTableByFilter("RankRewardTable", "RankType", nRankId)
end
return rank_util