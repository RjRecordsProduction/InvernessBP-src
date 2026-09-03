local NetManager = require("client.network.comm.NetManager")
local RankHandler = {}
function RankHandler.send_get_one_user_rank(type, zoneId, uid, total_rating, extra_data)
  log(bWriteLog and "RankHandler.send_get_one_user_rank uid = " .. tostring(uid))
  log(bWriteLog and "RankHandler.send_get_one_user_rank zoneId = " .. tostring(zoneId))
  if zoneId == 7 then
    log(bWriteLog and "RankHandler.send_get_one_user_rank zoneId == 7")
    return
  end
  RankHandler.SendUID = uid
  NetManager.SendPkg(445841892, type, zoneId, uid, total_rating, extra_data)
end
function RankHandler.on_get_one_user_rank_rsp(client_data, ok, zoneId, rank_info, extra_data)
  log_format("RankHandler.on_get_one_user_rank_rsp, client_data:%s, ok:%s, zoneId:%s", client_data, ok, zoneId)
  log_tree(bWriteLog and "RankHandler.on_get_one_user_rank_rsp rank_info", rank_info)
  local RankNetHandler = require("client.slua.logic.rank.rank_net_handler")
  RankNetHandler.RspSelfRankData(client_data, ok, zoneId, rank_info, extra_data)
  local logic_rank_creativity = require("client.slua.logic.activity.logic_rank_creativity")
  logic_rank_creativity.GetSelfRankRsp(client_data, ok, zoneId, rank_info, extra_data)
end
function RankHandler.send_get_topn_rank(zoneId, st, page, extra_data)
  log(bWriteLog and string.format("RankHandler.send_get_topn_rank, zoneId:%s", zoneId))
  log(bWriteLog and string.format("RankHandler.send_get_topn_rank, st:%s", st))
  log(bWriteLog and string.format("RankHandler.send_get_topn_rank, page:%s", page))
  log_tree(bWriteLog and "RankHandler.send_get_topn_rank extra_data", extra_data)
  if zoneId == 100 then
    log(bWriteLog and "RankHandler.send_get_topn_rank zoneId == 100")
    return
  end
  NetManager.SendPkg(286918582, zoneId, st, page, extra_data)
end
function RankHandler.on_get_topn_rank_rsp(ok, zone_id, score_type, list, page, extra_data)
  log_format("RankHandler.on_get_topn_rank_rsp, ok:%s, zone_id:%s, score_type:%s, page:%s", ok, zone_id, score_type, page)
  log_tree(bWriteLog and "RankHandler.on_get_topn_rank_rsp list", list)
  log_tree(bWriteLog and "RankHandler.on_get_topn_rank_rsp extra_data", extra_data)
  local RankNetHandler = require("client.slua.logic.rank.rank_net_handler")
  RankNetHandler.RspFetchRankData(ok, zone_id, score_type, list, page, extra_data)
  local logic_rank_creativity = require("client.slua.logic.activity.logic_rank_creativity")
  logic_rank_creativity.GetRankListRsp(ok, zone_id, score_type, list, page, extra_data)
end
function RankHandler.send_get_friend_rank(zoneid, partList)
  NetManager.SendPkg(1037082820, zoneid, partList)
end
function RankHandler.on_get_friend_rank_rsp(ok, zoneid, list)
  log_tree("RankHandler.on_get_friend_rank_rsp list = ", list)
  local RankNetHandler = require("client.slua.logic.rank.rank_net_handler")
  RankNetHandler.RspFriendRankRole(ok, zoneid, list)
end
function RankHandler.on_get_topn_1w_score_rsp(ok, zoneid, list)
  local RankNetHandler = require("client.slua.logic.rank.rank_net_handler")
  RankNetHandler.RspFriendRankRole(ok, zoneid, list)
end
function RankHandler.send_batch_get_popularit_summary_req(lstFriendUid, reqType)
  NetManager.SendPkg(1963995031, lstFriendUid, reqType)
end
function RankHandler.on_batch_get_popularit_summary_rsp(res, result, reqType)
  local RankNetHandler = require("client.slua.logic.rank.rank_net_handler")
  RankNetHandler.RspBatchPopularitInfo(res, result, reqType)
end
function RankHandler.send_rank_replay_switch_req(is_agree)
  NetManager.SendPkg(2007034056, is_agree)
end
function RankHandler.on_rank_replay_switch_res(err, is_agree)
  local rankInspectSystem = require("client.slua.logic.rank.logic_rank_inspect")
  rankInspectSystem.ResSelectResult(err, is_agree)
end
function RankHandler.on_rank_replay_choice_notify(zone_id, score_type, score)
  local rankInspectSystem = require("client.slua.logic.rank.logic_rank_inspect")
  rankInspectSystem.NotifyAfterSettlement(zone_id, score_type, score)
end
function RankHandler.send_get_special_user_rank(client_data, zone_id, target_uids, score_type, extra_data)
  log(bWriteLog and "RankHandler.send_get_special_user_rank client_data = " .. tostring(client_data) .. ", zone_id = " .. tostring(zone_id) .. ", score_type = " .. tostring(score_type))
  log_tree("RankHandler.send_get_special_user_rank target_uids", target_uids)
  NetManager.SendPkg(42195118, client_data, zone_id, target_uids, score_type, extra_data)
end
function RankHandler.on_get_special_user_rank_rsp(err_code, client_data, zone_id, rank_info, extra_data)
  log(bWriteLog and "RankHandler.on_get_special_user_rank_rsp err_code = " .. tostring(err_code) .. ", client_data = " .. tostring(client_data) .. ", zone_id = " .. tostring(zone_id))
  log_tree("RankHandler.on_get_special_user_rank_rsp rank_info", rank_info)
  local RankNetHandler = require("client.slua.logic.rank.rank_net_handler")
  RankNetHandler.RspGetSpecialUserRankInfo(err_code, client_data, zone_id, rank_info, extra_data)
end
return RankHandler