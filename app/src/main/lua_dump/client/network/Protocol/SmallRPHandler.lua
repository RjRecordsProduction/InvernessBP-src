local NetManager = require("client.network.comm.NetManager")
local SmallRPHandler = {}
function SmallRPHandler.send_small_rp_player_data_req()
  NetManager.SendPkg(945117863)
end
function SmallRPHandler.on_small_rp_player_data_rsp(err_code, small_rp, control_cfg)
  if err_code ~= 0 then
    if err_code == 18120001 then
      log(bWriteLog and " SmallRP not Opened >>>>>")
      return
    end
    ShowNotice(err_code)
    return
  end
  local Logic_SmallRP = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SmallRP)
  Logic_SmallRP:on_small_rp_player_data_rsp(small_rp, control_cfg)
end
function SmallRPHandler.send_small_rp_unlock_req(sourceType, if_by_unlock_card)
  NetManager.SendPkg(1652991127, sourceType, if_by_unlock_card)
end
function SmallRPHandler.on_small_rp_unlock_rsp(err_code)
  if err_code == "qrcode_login_limit" then
    local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
    QRcodeRestrictManager:ShowRestrictTips()
    return
  end
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local Logic_SmallRP = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SmallRP)
  Logic_SmallRP:on_small_rp_unlock_rsp()
end
function SmallRPHandler.send_small_rp_buy_score_req(diff_score, cur_score)
  NetManager.SendPkg(1383652999, diff_score, cur_score)
end
function SmallRPHandler.on_small_rp_buy_score_rsp(err_code, diff_score, cur_score)
  local Logic_SmallRP = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SmallRP)
  Logic_SmallRP:on_small_rp_buy_score_rsp(err_code, diff_score, cur_score)
end
function SmallRPHandler.send_small_rp_get_level_award_req(level, index)
  NetManager.SendPkg(1717829223, level, index)
end
function SmallRPHandler.on_small_rp_get_level_award_rsp(err_code, level, items, decompose_list, addition_awards)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local Logic_SmallRP = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SmallRP)
  Logic_SmallRP:on_small_rp_get_level_award_rsp(level, items, decompose_list, addition_awards)
end
function SmallRPHandler.send_small_rp_batch_get_level_award_req(selects)
  NetManager.SendPkg(1676253863, selects)
end
function SmallRPHandler.on_small_rp_batch_get_level_award_rsp(err_code, items, decompose_list, addition_awards)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local Logic_SmallRP = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SmallRP)
  Logic_SmallRP:on_small_rp_batch_get_level_award_rsp(items, decompose_list, addition_awards)
end
function SmallRPHandler.send_small_rp_level_award_cfg_req()
  NetManager.SendPkg(1974357735)
end
function SmallRPHandler.on_small_rp_level_award_cfg_rsp(err_code, level_award_cfg)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local Logic_SmallRP = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SmallRP)
  Logic_SmallRP:on_small_rp_level_award_cfg_rsp(level_award_cfg)
end
function SmallRPHandler.send_sync_small_rp_task_data_req()
  NetManager.SendPkg(1613165458)
end
function SmallRPHandler.on_sync_small_rp_task_data_info(small_rp_task)
  local Logic_SmallRP = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SmallRP)
  Logic_SmallRP:on_sync_small_rp_task_data_info(small_rp_task)
end
function SmallRPHandler.send_small_rp_get_task_award_req(task_id)
  NetManager.SendPkg(680571279, task_id)
end
function SmallRPHandler.on_small_rp_get_task_award_rsp(err_code, task_id, task_data, reward_score, decomposed_score, items)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local Logic_SmallRP = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SmallRP)
  Logic_SmallRP:on_small_rp_get_task_award_rsp(task_id, task_data, reward_score, decomposed_score, items)
end
function SmallRPHandler.send_small_rp_batch_get_task_award_req()
  NetManager.SendPkg(1862359467)
end
function SmallRPHandler.on_small_rp_batch_get_task_award_rsp(err_code, reward_score, decomposed_score, items)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local Logic_SmallRP = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SmallRP)
  Logic_SmallRP:on_small_rp_batch_get_task_award_rsp(reward_score, decomposed_score, items)
end
function SmallRPHandler.on_small_rp_score_notify_change(diff_score, new_score, reason)
  local Logic_SmallRP = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SmallRP)
  Logic_SmallRP:on_small_rp_score_notify_change(diff_score, new_score, reason)
end
function SmallRPHandler.send_small_rp_batch_get_stage_award_req()
  NetManager.SendPkg(1711653415)
end
function SmallRPHandler.on_small_rp_batch_get_stage_award_rsp(err_code, award)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local Logic_SmallRP = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SmallRP)
  Logic_SmallRP:on_small_rp_batch_get_stage_award_rsp(award)
end
return SmallRPHandler