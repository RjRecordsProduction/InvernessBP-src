local NetManager = require("client.network.comm.NetManager")
local NewbieActivityHandle = {}
function NewbieActivityHandle.send_newbie_activity_get_rank_reward_req(task_id)
  NetManager.SendPkg(1280438283, task_id)
end
function NewbieActivityHandle.on_newbie_activity_get_rank_reward_rsp(error_code, task_id)
  if error_code ~= 0 then
    log(bWriteLog and "NewbieActivityHandle.on_newbie_activity_get_rank_reward_rsp = " .. tostring(error_code))
    ShowNotice(error_code)
    return
  end
  local NewbieActivitySystem = require("client.slua.logic.activity.newbie.logic_newbie_activity")
  NewbieActivitySystem.on_newbie_activity_get_rank_reward_rsp(task_id)
end
function NewbieActivityHandle.send_newbie_activity_get_gift_reward_req(task_id)
  NetManager.SendPkg(139466019, task_id)
end
function NewbieActivityHandle.on_newbie_activity_get_gift_reward_rsp(error_code, task_id)
  if error_code ~= 0 then
    log(bWriteLog and "NewbieActivityHandle.on_newbie_activity_get_gift_reward_rsp = " .. tostring(error_code))
    ShowNotice(error_code)
    return
  end
  local NewbieActivitySystem = require("client.slua.logic.activity.newbie.logic_newbie_activity")
  NewbieActivitySystem.on_newbie_activity_get_gift_reward_rsp(task_id)
end
function NewbieActivityHandle.on_newbie_activity_init(activity_data)
  log(bWriteLog and "NewbieActivityHandle.on_newbie_activity_init")
  local NewbieActivitySystem = require("client.slua.logic.activity.newbie.logic_newbie_activity")
  NewbieActivitySystem.on_newbie_activity_init(activity_data)
  local level_unlock_award_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_award_manager)
  level_unlock_award_manager:on_newbie_activity_init(activity_data.newbie_level_unlock)
end
function NewbieActivityHandle.on_newbie_activity_sync_status(activity_data)
  local NewbieActivitySystem = require("client.slua.logic.activity.newbie.logic_newbie_activity")
  NewbieActivitySystem.on_newbie_activity_sync_status(activity_data)
end
function NewbieActivityHandle.send_newbie_activity_get_sign_reward_req(day, reward_index)
  NetManager.SendPkg(810901335, day, reward_index)
end
function NewbieActivityHandle.on_newbie_activity_get_sign_reward_rsp(error_code, day, reward_index)
  if error_code ~= 0 then
    log(bWriteLog and "NewbieActivityHandle.on_newbie_activity_get_sign_reward_rsp = " .. tostring(error_code))
    ShowNotice(error_code)
    return
  end
  local NewbieActivitySystem = require("client.slua.logic.activity.newbie.logic_newbie_activity")
  NewbieActivitySystem.on_newbie_activity_get_sign_reward_rsp(day, reward_index)
end
function NewbieActivityHandle.on_newbie_celebration_init(celebration_info)
  log_tree("on_newbie_celebration_init celebration_info = ", celebration_info)
  local logic_new_player_spin = require("client.slua.logic.growth_project.logic_new_player_spin")
  log_tree("[qintong] on_newbie_celebration_init", celebration_info)
  logic_new_player_spin.OnRecvData(celebration_info)
  local logic_newbie_achievement = require("client.slua.logic.activity.newbie.logic_newbie_achievement")
  logic_newbie_achievement.OnRecvData(celebration_info)
end
function NewbieActivityHandle.send_newbie_celebration_get_mission_reward_req(mission_type, mission_index)
  NetManager.SendPkg(816728279, mission_type, mission_index)
end
function NewbieActivityHandle.on_newbie_celebration_get_mission_reward_rsp(err_code, mission_type, mission_index)
  if err_code == 0 then
    local logic_new_player_spin = require("client.slua.logic.growth_project.logic_new_player_spin")
    logic_new_player_spin.UpdateTaskReward(mission_type, mission_index)
    local logic_newbie_achievement = require("client.slua.logic.activity.newbie.logic_newbie_achievement")
    logic_newbie_achievement.UpdateTaskReward(mission_type, mission_index)
  else
    ShowNotice(err_code)
  end
end
function NewbieActivityHandle.send_newbie_celebration_get_drop_points_reward_req(points_id)
  NetManager.SendPkg(353512491, points_id)
end
function NewbieActivityHandle.on_newbie_celebration_get_drop_points_reward_rsp(err_code, points_id, total_points)
  if err_code == 0 then
    local logic_new_player_spin = require("client.slua.logic.growth_project.logic_new_player_spin")
    logic_new_player_spin.UpdateSingleScoreRewardStatus(points_id)
  else
    ShowNotice(err_code)
  end
end
function NewbieActivityHandle.on_newbie_mission_sync(mission_id, value, finish_status)
  local logic_new_player_spin = require("client.slua.logic.growth_project.logic_new_player_spin")
  log(bWriteLog and "[qintong] logic_new_player_spin.UpdateTask mission_id = " .. mission_id .. "   value =" .. value .. "  finish_status=" .. finish_status)
  logic_new_player_spin.UpdateTaskStatus(mission_id, value, finish_status)
  local logic_newbie_achievement = require("client.slua.logic.activity.newbie.logic_newbie_achievement")
  logic_newbie_achievement.UpdateTaskStatus(mission_id, value, finish_status)
end
function NewbieActivityHandle.send_newbie_celebration_lucky_draw_req(drop_num)
  NetManager.SendPkg(475296335, drop_num)
end
function NewbieActivityHandle.on_newbie_celebration_lucky_draw_rsp(error_code, draw_num, award_list)
  log(bWriteLog and "NewbieActivityHandle.on_newbie_celebration_lucky_draw_rsp error_code = " .. tostring(error_code) .. " draw_num = " .. tostring(draw_num))
  log_tree("NewbieActivityHandle.on_newbie_celebration_lucky_draw_rsp award_list = ", award_list)
  if error_code == 0 then
    EventSystem:postEvent(EVENTTYPE_ACTION, EVENTID_GROWTH_PROJECT_DROP_EVENT, award_list)
  else
    ShowNotice(error_code)
  end
end
function NewbieActivityHandle.on_newbie_celebration_sync_status(celebration_status)
  local logic_new_player_spin = require("client.slua.logic.growth_project.logic_new_player_spin")
  logic_new_player_spin.UpdateAllScoreReawrdStatus(celebration_status.drop_points_status)
end
function NewbieActivityHandle.on_newbie_celebration_points_notify_chg(newbie_points)
  log(bWriteLog and "[qintong] on_newbie_celebration_points_notify_chg" .. tostring(newbie_points))
  DataMgr.roleData.  EventSystem:postEvent(EVENTTYPE_ACTION, EVENTID_GROWTH_PROJECT_POINT_CHANGE)
end
function NewbieActivityHandle.send_get_newbie_all_social_task_req()
  NetManager.SendPkg(39102823)
end
function NewbieActivityHandle.on_get_newbie_all_social_task_rsp(res, sync_task_info, all_task_award)
  log(bWriteLog and "[FriendsGathering] on_get_newbie_all_social_task_rsp res " .. tostring(res))
  log_tree(bWriteLog and "sync_task_info", sync_task_info)
  log_tree(bWriteLog and "all_task_award", all_task_award)
  if res == 0 then
    local newFriendsGathering = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.module_newbie_friends_gathering)
    if sync_task_info then
      for _, task_status in pairs(sync_task_info) do
        newFriendsGathering:UpdateTaskStatus(task_status)
      end
    end
    newFriendsGathering:UpdateAllTaskAward(all_task_award)
    EventSystem:postEvent(EVENTTYPE_NEWBIE_ACTIVITY, EVENTID_NEWBIE_ACTIVITY_DATA)
  else
    ShowNotice(res)
  end
end
function NewbieActivityHandle.on_newbie_social_task_sync(sync_task_info, all_task_award)
  log(bWriteLog and "[FriendsGathering] on_newbie_social_task_sync res ")
  log_tree(bWriteLog and "sync_task_info", sync_task_info)
  log_tree(bWriteLog and "all_task_award", all_task_award)
  local newFriendsGathering = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.module_newbie_friends_gathering)
  newFriendsGathering:UpdateTaskStatus(sync_task_info)
  newFriendsGathering:UpdateAllTaskAward(all_task_award)
  EventSystem:postEvent(EVENTTYPE_NEWBIE_ACTIVITY, EVENTID_NEWBIE_ACTIVITY_DATA)
end
function NewbieActivityHandle.send_dont_show_friend_recommend_req(is_dont_show_all, is_show_today)
  NetManager.SendPkg(499444583, is_dont_show_all, is_show_today)
end
function NewbieActivityHandle.on_dont_show_friend_recommend_rsp(res, result)
  local newFriendsGathering = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.module_newbie_friends_gathering)
  newFriendsGathering:OnDontShowFriendRecommendRsp(res, result)
end
function NewbieActivityHandle.send_batch_newbie_cel_get_mission_reward_req()
  NetManager.SendPkg(1075421875)
end
function NewbieActivityHandle.on_batch_newbie_cel_get_mission_reward_rsp(err_code, misson_state)
  log(bWriteLog and "NewbieActivityHandle.on_batch_newbie_cel_get_mission_reward_rsp err_code = " .. tostring(err_code))
  log_tree(bWriteLog and "NewbieActivityHandle.on_batch_newbie_cel_get_mission_reward_rsp misson_state = ", misson_state)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local logic_newbie_achievement = require("client.slua.logic.activity.newbie.logic_newbie_achievement")
  logic_newbie_achievement.OnGetBatchNewbieMissonAward(misson_state)
end
return NewbieActivityHandle