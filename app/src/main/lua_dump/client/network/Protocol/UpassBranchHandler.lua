local NetManager = require("client.network.comm.NetManager")
local UpassBranchHandler = {}
function UpassBranchHandler.send_rp_branch_player_data_req()
  NetManager.SendPkg(1398139539)
end
function UpassBranchHandler.on_rp_branch_player_data_rsp(err_code, rp_branch)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local Logic_BonusPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_BonusPass)
  Logic_BonusPass:on_rp_branch_player_data_rsp(rp_branch)
end
function UpassBranchHandler.send_rp_branch_buy_score_req(diff_score, cur_score)
  NetManager.SendPkg(1148181215, diff_score, cur_score)
end
function UpassBranchHandler.on_rp_branch_buy_score_rsp(err_code, diff_score, cur_score)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local Logic_BonusPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_BonusPass)
  Logic_BonusPass:on_rp_branch_buy_score_rsp(diff_score, cur_score)
end
function UpassBranchHandler.send_rp_branch_get_level_award_req(level, index)
  NetManager.SendPkg(1654017711, level, index)
end
function UpassBranchHandler.on_rp_branch_get_level_award_rsp(err_code, level, items)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local Logic_BonusPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_BonusPass)
  Logic_BonusPass:on_rp_branch_get_level_award_rsp(level, items)
end
function UpassBranchHandler.send_rp_branch_batch_get_level_award_req(selects)
  NetManager.SendPkg(1513609547, selects)
end
function UpassBranchHandler.on_rp_branch_batch_get_level_award_rsp(err_code, items)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local Logic_BonusPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_BonusPass)
  Logic_BonusPass:on_rp_branch_batch_get_level_award_rsp(items)
end
function UpassBranchHandler.send_sync_rp_branch_task_data_req()
  NetManager.SendPkg(953210702)
end
function UpassBranchHandler.on_sync_rp_branch_task_data_info(rp_branch_task, task_type)
  local Logic_BonusPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_BonusPass)
  Logic_BonusPass:on_sync_rp_branch_task_data_info(rp_branch_task, task_type)
end
function UpassBranchHandler.send_rp_branch_get_task_award_req(task_id, task_type)
  NetManager.SendPkg(61194727, task_id, task_type)
end
function UpassBranchHandler.on_rp_branch_get_task_award_rsp(err_code, task_id, task_data, reward_score, task_type)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local Logic_BonusPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_BonusPass)
  Logic_BonusPass:on_rp_branch_get_task_award_rsp(task_id, task_data, reward_score, task_type)
end
function UpassBranchHandler.send_rp_branch_batch_get_task_award_req()
  NetManager.SendPkg(1368515239)
end
function UpassBranchHandler.on_rp_branch_batch_get_task_award_rsp(err_code, reward_score)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local Logic_BonusPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_BonusPass)
  Logic_BonusPass:on_rp_branch_batch_get_task_award_rsp(reward_score)
end
function UpassBranchHandler.on_rp_branch_score_notify_change(diff_score, new_score)
  local Logic_BonusPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_BonusPass)
  Logic_BonusPass:on_rp_branch_score_notify_change(diff_score, new_score)
end
function UpassBranchHandler.send_rp_branch_get_special_reward_req()
  NetManager.SendPkg(1649805863)
end
function UpassBranchHandler.on_rp_branch_get_special_reward_rsp(err_code, awards)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local Logic_BonusPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_BonusPass)
  Logic_BonusPass:on_rp_branch_get_special_reward_rsp(awards)
end
function UpassBranchHandler.send_rp_branch_get_extra_chest_req(expected_cnt)
  NetManager.SendPkg(284969535, expected_cnt)
end
function UpassBranchHandler.on_rp_branch_get_extra_chest_rsp(err_code, chest_id, item_list, decompose_list, score_idx)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local Logic_BonusPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_BonusPass)
  Logic_BonusPass:on_rp_branch_get_extra_chest_rsp(chest_id, item_list, decompose_list, score_idx)
end
function UpassBranchHandler.send_rp_branch_common_buy_req(buy_id, vouchers)
  NetManager.SendPkg(1223261991, buy_id, vouchers)
end
function UpassBranchHandler.on_rp_branch_common_buy_rsp(err_code, RPBranchCommonBuyClientSync)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local Logic_BonusPass_Buy = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_BonusPass_Buy)
  Logic_BonusPass_Buy:on_rp_branch_common_buy_rsp(err_code, RPBranchCommonBuyClientSync)
end
function UpassBranchHandler.send_unknown_pass_type_req()
  NetManager.SendPkg(1569625047)
end
function UpassBranchHandler.on_unknown_pass_type_rsp(err_code, pass_type)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local Logic_BonusPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_BonusPass)
  Logic_BonusPass:on_unknown_pass_type_rsp(pass_type)
end
return UpassBranchHandler