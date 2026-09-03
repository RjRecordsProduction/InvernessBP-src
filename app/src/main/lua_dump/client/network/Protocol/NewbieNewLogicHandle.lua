local NetManager = require("client.network.comm.NetManager")
local NewbieNewLogicHandle = {}
function NewbieNewLogicHandle.on_newbie_login_day_notify(login_day)
  log(bWriteLog and "NewbieNewLogicHandle.on_newbie_login_day_notify login_day is " .. tostring(login_day))
  local logic_newbie_new_abtest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_new_abtest)
  logic_newbie_new_abtest:UpdateNewbieNewDataLoginDay(login_day)
end
function NewbieNewLogicHandle.send_newbie_task_reward_req(task_id)
  NetManager.SendPkg(482362119, task_id)
end
function NewbieNewLogicHandle.on_newbie_task_reward_rsp(err, task_id, awards)
  if err ~= 0 then
    ShowNotice(err)
    return
  end
  local logic_newbie_new_abtest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_new_abtest)
  logic_newbie_new_abtest:UpdateNewbieNewDataTaskData(task_id)
  logic_newbie_new_abtest:ShowNewbieAward(awards)
end
function NewbieNewLogicHandle.send_newbie_upgrade_reward_req(level)
  NetManager.SendPkg(1000750119, level)
end
function NewbieNewLogicHandle.on_newbie_upgrade_reward_rsp(err, level, awards)
  log_format("NewbieNewLogicHandle.on_newbie_upgrade_reward_rsp. err = [%s], level = [%s]", err, level)
  log_tree("NewbieNewLogicHandle.on_newbie_upgrade_reward_rsp. awards = ", awards)
  if err ~= 0 then
    ShowNotice(err)
    return
  end
  local logic_newbie_new_abtest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_new_abtest)
  logic_newbie_new_abtest:UpdateNewbieNewDataLevelData(level)
  local level_unlock_award_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_award_manager)
  level_unlock_award_manager:on_newbie_upgrade_reward_rsp(level)
  logic_newbie_new_abtest:ShowNewbieAward(awards)
end
function NewbieNewLogicHandle.send_newbie_login_reward_req(day, award_idx)
  NetManager.SendPkg(53821459, day, award_idx)
end
function NewbieNewLogicHandle.on_newbie_login_reward_rsp(err, day, award_idx, awards)
  if err ~= 0 then
    ShowNotice(err)
    return
  end
  local logic_newbie_new_abtest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_new_abtest)
  logic_newbie_new_abtest:UpdateNewbieNewDataLoginData(day)
  logic_newbie_new_abtest:ShowNewbieAward(awards)
end
function NewbieNewLogicHandle.send_newbie_points_reward_req(points_id, award_idx)
  NetManager.SendPkg(697350887, points_id, award_idx)
end
function NewbieNewLogicHandle.on_newbie_points_reward_rsp(err, points_id, award_idx, awards)
  if err ~= 0 then
    ShowNotice(err)
    return
  end
  local logic_newbie_new_abtest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_new_abtest)
  logic_newbie_new_abtest:UpdateNewbieNewDataPointData(points_id)
  logic_newbie_new_abtest:ShowNewbieAward(awards)
end
function NewbieNewLogicHandle.send_newbie_reward_all_task_and_points_req()
  NetManager.SendPkg(398184995)
end
function NewbieNewLogicHandle.on_newbie_reward_all_task_and_points_rsp(err, awards)
  if err ~= 0 then
    ShowNotice(err)
    return
  end
  local logic_newbie_new_abtest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_new_abtest)
  logic_newbie_new_abtest:ShowNewbieAward(awards)
end
function NewbieNewLogicHandle.send_newbie_new_info_req()
  NetManager.SendPkg(1067437083)
end
function NewbieNewLogicHandle.on_newbie_new_info_rsp(err, newbie_new_data)
  log_tree(bWriteLog and "NewbieNewLogicHandle.on_newbie_new_info_rsp data = ", newbie_new_data)
  if err ~= 0 then
    ShowNotice(err)
    return
  end
  local logic_newbie_new_abtest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_new_abtest)
  logic_newbie_new_abtest:UpdateNewbieNewData(newbie_new_data)
end
function NewbieNewLogicHandle.on_newbie_new_info_notify(newbie_new_data)
  log_tree(bWriteLog and "NewbieNewLogicHandle.on_newbie_new_info_notify data = ", newbie_new_data)
  local logic_newbie_new_abtest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_new_abtest)
  logic_newbie_new_abtest:UpdateNewbieNewData(newbie_new_data)
  logic_newbie_new_abtest:LoadConfig(newbie_new_data.group_id)
  local level_unlock_award_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_award_manager)
  level_unlock_award_manager:InitByNewConfig(newbie_new_data.group_id)
  level_unlock_award_manager:on_newbie_new_info_notify(newbie_new_data)
end
return NewbieNewLogicHandle