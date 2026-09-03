local RankNetHandler = {}
function RankNetHandler.ReqFetchRankData(zoneId)
  local rank_ctrl = require("client.slua.logic.rank.rank_ctrl")
  rank_ctrl.GetRankDataReq(zoneId)
end
function RankNetHandler.RspSelfRankData(client_data, ok, zoneId, rank_info)
  local rank_ctrl = require("client.slua.logic.rank.rank_ctrl")
  rank_ctrl.GetOneUserRankRsp(client_data, ok, zoneId, rank_info)
end
function RankNetHandler.RspFetchRankData(ok, zone_id, score_type, list, page, extra_data)
  local rank_ctrl = require("client.slua.logic.rank.rank_ctrl")
  rank_ctrl.GetTopNRankRsp(ok, zone_id, score_type, list, page, extra_data)
end
function RankNetHandler.ReqFriendRankRole(zoneid)
  local rank_ctrl = require("client.slua.logic.rank.rank_ctrl")
  rank_ctrl.GetFriendRankReq(zoneid)
end
function RankNetHandler.RspFriendRankRole(ok, zoneid, list)
  local rank_ctrl = require("client.slua.logic.rank.rank_ctrl")
  rank_ctrl.GetNormalFriendRankRsp(ok, zoneid, list)
end
function RankNetHandler.RspBatchPopularitInfo(res, result, reqType)
  local rank_ctrl = require("client.slua.logic.rank.rank_ctrl")
  rank_ctrl.GetGiftFriendRankRsp(res, result, reqType)
end
function RankNetHandler.RspGetSpecialUserRankInfo(err_code, client_data, zone_id, rank_info, extra_data)
  local rank_ctrl = require("client.slua.logic.rank.rank_ctrl")
  rank_ctrl.ParseSpecialUserRank(err_code, client_data, rank_info)
end
function RankNetHandler.QueryRankRoleInfoByScroll(indexFrom)
  local rank_ctrl = require("client.slua.logic.rank.rank_ctrl")
  rank_ctrl.QueryRankRoleInfoByScroll(indexFrom)
end
return RankNetHandler