local NetManager = require("client.network.comm.NetManager")
local MiniTvRewardHandler = {}
function MiniTvRewardHandler.send_mini_tv_get_all_reward_req(activity_list, mail_list, download_list, achieve_list)
  log(bWriteLog and "[zxq] send_mini_tv_get_all_reward_req :")
  NetManager.SendPkg(1372365415, activity_list, mail_list, download_list, achieve_list)
end
function MiniTvRewardHandler.on_mini_tv_get_all_reward_rsp(reason, result)
  log(bWriteLog and "[zxq] MiniTvRewardHandler.on_mini_tv_get_all_reward_rsp")
  if 1 < reason then
    ShowNotice(reason)
    log_error("[zxq] MiniTvRewardHandler.on_mini_tv_get_all_reward_rsp error  reason :" .. tostring(reason))
    return
  end
  local OneClickReward = require("client.slua.logic.mini_tv.logic_oneclick_reward")
  OneClickReward.HandleNormalReward(reason, result)
end
function MiniTvRewardHandler.on_get_all_corps_active_goal_reward_rsp(ret, all_award_list)
  printf("MiniTvRewardHandler.on_get_all_corps_active_goal_reward_rsp ret:%d", ret)
  log_tree("MiniTvRewardHandler.on_get_all_corps_active_goal_reward_rsp", all_award_list)
  if ret ~= 0 then
    return
  end
  local OneClickReward = require("client.slua.logic.mini_tv.logic_oneclick_reward")
  OneClickReward.HandleCorpsActiveGoalReward(all_award_list)
end
return MiniTvRewardHandler