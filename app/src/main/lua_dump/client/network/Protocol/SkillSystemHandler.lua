local NetManager = require("client.network.comm.NetManager")
local SkillSystemHandler = {}
function SkillSystemHandler.send_skill_trial_select_skill_req(skill_id)
  NetManager.SendPkg(2003434407, skill_id)
end
function SkillSystemHandler.on_skill_trial_select_skill_rsp(err_code, skill_id)
  local skill_selection_system = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.skill_selection_system)
  skill_selection_system:OnEquipSkillRsp(err_code, skill_id)
end
function SkillSystemHandler.send_skill_trial_get_skill_req()
  NetManager.SendPkg(1505511695)
end
function SkillSystemHandler.on_skill_trial_get_skill_rsp(err_code, skill_id)
  local skill_selection_system = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.skill_selection_system)
  skill_selection_system:OnGetSkillRsp(err_code, skill_id)
end
function SkillSystemHandler.send_get_skill_trial_task_req(activity_id)
  NetManager.SendPkg(246806503, activity_id)
end
function SkillSystemHandler.on_get_skill_trial_task_rsp(err_code, skill_tasks)
  local skill_task_system = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.skill_task_system)
  skill_task_system:OnGetTaskDataRsp(err_code, skill_tasks)
end
function SkillSystemHandler.send_receive_skill_trial_task_reward_req(activity_id, task_id)
  NetManager.SendPkg(447388323, activity_id, task_id)
end
function SkillSystemHandler.on_receive_skill_trial_task_reward_rsp(retcode, activity_id, task_id, reward_table)
  local skill_task_system = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.skill_task_system)
  skill_task_system:OnGetTaskRewardRsp(retcode, activity_id, task_id, reward_table)
end
function SkillSystemHandler.on_sync_skill_task_change(sync_task_list)
  local skill_task_system = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.skill_task_system)
  skill_task_system:OnSyncTaskList(sync_task_list)
end
return SkillSystemHandler