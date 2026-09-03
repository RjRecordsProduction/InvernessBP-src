local NetManager = require("client.network.comm.NetManager")
local NewbieModeHandler = {}
function NewbieModeHandler.send_get_newbie_upgrade_data_req()
  NetManager.SendPkg(39266095)
end
function NewbieModeHandler.on_get_newbie_upgrade_data_rsp(err_code, data, newbie_view_cfg, award_cfg, death_cfg, video_url_cfg)
  log(bWriteLog and "[NewbieModeSelection] on_get_newbie_upgrade_data_rsp errcode " .. tostring(err_code))
  if err_code == 0 then
    local logic_newbie_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_mode_selection)
    logic_newbie_mode_selection:OnGetNewbieUpgradeDataRsp(data, newbie_view_cfg, award_cfg, death_cfg, video_url_cfg)
  end
end
function NewbieModeHandler.send_newbie_upgrade_total_reward_req(cfg_id)
  NetManager.SendPkg(45680075, cfg_id)
end
function NewbieModeHandler.on_newbie_upgrade_total_reward_rsp(err_code, cfg_id, data)
  log(bWriteLog and "[NewbieModeSelection] on_newbie_upgrade_total_reward_rsp errcode " .. tostring(err_code))
  if err_code == 0 then
    local logic_newbie_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_mode_selection)
    logic_newbie_mode_selection:OnNewbieUpgradeTotalRewardRsp(cfg_id, data)
  end
end
function NewbieModeHandler.send_newbie_upgrade_train_detail_req(view_id, detail)
  NetManager.SendPkg(1277905819, view_id, detail)
end
function NewbieModeHandler.on_newbie_upgrade_train_detail_rsp(err_code, view_id, detail)
  log(bWriteLog and "[NewbieModeSelection] on_newbie_upgrade_train_detail_rsp errcode " .. tostring(err_code))
  if err_code == 0 then
  end
end
function NewbieModeHandler.on_newbie_upgrade_sync_data(view_id, data)
  log_tree("[NewbieModeSelection] on_newbie_upgrade_sync_data errcode", data)
  local logic_newbie_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_mode_selection)
  logic_newbie_mode_selection:OnNewbieUpgradeSyncData(view_id, data)
end
function NewbieModeHandler.send_newbie_upgrade_award_show_req(view_id)
  NetManager.SendPkg(1601382047, view_id)
end
function NewbieModeHandler.on_newbie_upgrade_award_show_rsp(err_code, data)
  log(bWriteLog and "[NewbieModeSelection] on_newbie_upgrade_award_show_rsp errcode " .. tostring(err_code))
  if err_code == 0 then
    local logic_newbie_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_mode_selection)
    logic_newbie_mode_selection:OnNewbieUpgradeAwardShowRsp(data)
  end
end
function NewbieModeHandler.on_newbie_upgrade_train_recommand_ntf(cfg_id)
  log(bWriteLog and "[NewbieModeSelection] on_newbie_upgrade_train_recommand_ntf cfg_id " .. tostring(cfg_id))
  local logic_newbie_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_mode_selection)
  logic_newbie_mode_selection:OnNewbieUpgradeTrainRecommandNtf(cfg_id)
end
function NewbieModeHandler.send_newbie_upgrade_view_award_req(view_id)
  NetManager.SendPkg(1139286327, view_id)
end
function NewbieModeHandler.on_newbie_upgrade_view_award_rsp(err_code, view_id, data)
  log(bWriteLog and "[NewbieModeSelection] on_newbie_upgrade_view_award_rsp err_code " .. tostring(err_code))
  if err_code == 0 then
    local logic_newbie_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_mode_selection)
    logic_newbie_mode_selection:OnNewbieUpgradeViewAwardRsp(view_id, data)
  end
end
return NewbieModeHandler