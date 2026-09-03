local NetManager = require("client.network.comm.NetManager")
local NewbieGuideHandler = {create_role_video_id = nil}
function NewbieGuideHandler.OnLogin()
  log(bWriteLog and "NewbieGuideHandler.OnLogin")
  NewbieGuideHandler.create_role_video_id = nil
end
function NewbieGuideHandler.OnLogOut()
  log(bWriteLog and "NewbieGuideHandler.OnLogOut")
  local NewbieGuideMgr = require("GameLua.GameCore.Module.NewbieGuide.NewbieGuideMgr")
  NewbieGuideMgr.ClearCacheServerData()
end
function NewbieGuideHandler.send_get_weak_guidance_conditions_req(condition_ids)
  log(bWriteLog and "NewbieGuideHandler.send_get_weak_guidance_conditions_req")
  log_tree("condition_ids = ", condition_ids)
  NetManager.SendPkg(2009574631, condition_ids)
end
function NewbieGuideHandler.on_get_weak_guidance_conditions_rsp(err, res, back_flow)
  log(bWriteLog and "NewbieGuideHandler.on_get_weak_guidance_conditions_rsp err " .. tostring(err))
  log_tree("res = ", res)
  log_tree("back_flow = ", back_flow)
  local NewbieGuideMgr = require("GameLua.GameCore.Module.NewbieGuide.NewbieGuideMgr")
  NewbieGuideMgr.HandleGetServerData(res, back_flow)
end
function NewbieGuideHandler.send_save_weak_guidance_conditions_req(conditions)
  NetManager.SendPkg(1741785275, conditions)
end
function NewbieGuideHandler.on_save_weak_guidance_conditions_rsp(conditons)
end
function NewbieGuideHandler.on_region_play_video(video)
  log(bWriteLog and "NewbieGuideHandler.on_region_play_video video = " .. video)
  NewbieGuideHandler.create_role_video_id = video
end
function NewbieGuideHandler.send_newbie_guide_log_report(module_id)
  NetManager.SendPkg(1052619901, module_id)
end
function NewbieGuideHandler.send_set_newbie_unlock_level_status_req(level, enter_season)
  NetManager.SendPkg(684584519, level, enter_season)
end
function NewbieGuideHandler.on_set_newbie_unlock_level_status_rsp(err, level_id, enter_season)
  log(bWriteLog and "get on_set_newbie_unlock_level_status_rsp err: " .. tostring(err) .. " level id: " .. tostring(level_id) .. " enter season: " .. tostring(enter_season))
  local logic_season_guide_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_guide_manager)
  logic_season_guide_manager:OnSyncEnterSeason(enter_season)
end
function NewbieGuideHandler.send_newbie_level_unlock_get_reward_req(reward_level)
  NetManager.SendPkg(252936679, reward_level)
end
function NewbieGuideHandler.on_newbie_level_unlock_get_reward_rsp(err, reward_level)
  if err == 0 then
    local level_unlock_award_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_award_manager)
    level_unlock_award_manager:on_newbie_level_unlock_get_reward_rsp(reward_level)
    EventSystem:postEvent(EVENTTYPE_LEVEL_UNLOCK, EVENTID_LEVEL_UNLOCK_GET_AWARD, reward_level)
  else
    log(bWriteLog and "on_newbie_level_unlock_get_reward_rsp: " .. tostring(err))
  end
end
function NewbieGuideHandler.on_get_newbie_level_unlock_data_rsp(unlock_data)
end
function NewbieGuideHandler.on_sync_newbie_level_unlock_data(unlock_data)
end
function NewbieGuideHandler.on_newbie_activity_cfg_init(persist_cfg)
  log_tree("NewbieGuideHandler.on_newbie_activity_cfg_init persist_cfg = ", persist_cfg)
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  level_unlock_manager:OnGetUnlockData(persist_cfg.newbie_level_unlock)
  local level_unlock_award_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_award_manager)
  level_unlock_award_manager:InitByData(persist_cfg.newbie_level_unlock)
  local logic_season_guide_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_guide_manager)
  logic_season_guide_manager:OnGetUnlockData(persist_cfg.newbie_level_unlock)
end
function NewbieGuideHandler.send_newbie_tutorial_level_req(total_time, avg_ttk, level_stay_time_list)
  log(bWriteLog and "NewbieGuideHandler.send_newbie_tutorial_level_req " .. tostring(total_time) .. " " .. tostring(avg_ttk) .. " " .. tostring(level_stay_time_list))
  NetManager.SendPkg(923480075, total_time, avg_ttk, level_stay_time_list)
end
function NewbieGuideHandler.on_newbie_tutorial_level_rsp(res)
  log(bWriteLog and "NewbieGuideHandler.on_newbie_tutorial_level_rsp" .. res)
  if res ~= 0 then
  end
end
function NewbieGuideHandler.send_new_newbie_perfect_excessive_level_up_req()
  NetManager.SendPkg(1704388699)
end
function NewbieGuideHandler.on_new_newbie_perfect_excessive_level_up_rsp(err_code)
  local logic_newbie_guide_force_rank = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_guide_force_rank)
  logic_newbie_guide_force_rank:on_new_newbie_perfect_excessive_level_up_rsp(err_code)
end
return NewbieGuideHandler