local NetManager = require("client.network.comm.NetManager")
local BattleReportHandler = {}
local logic_battle_report = require("client.slua.logic.battle_report_video.logic_battle_report_video")
local report_macro = require("client.slua.logic.battle_report_video.battle_report_macro")
function BattleReportHandler.send_vod_game_report_req(battle_id, wesee_info)
  NetManager.SendPkg(1504171095, battle_id, wesee_info)
end
function BattleReportHandler.on_vod_game_report_rsp(errcode, battle_id)
end
function BattleReportHandler.send_batch_get_vod_info_req(battle_ids)
  NetManager.SendPkg(1850176647, battle_ids)
end
function BattleReportHandler.on_batch_get_vod_info_rsp(errcode, vod_info)
end
function BattleReportHandler.send_get_game_report_req(battle_id)
  log(bWriteLog and "[janesjing][BattleReport] send_get_game_report_req battle_id " .. tostring(battle_id))
  NetManager.SendPkg(1600762259, battle_id)
end
function BattleReportHandler.on_get_game_report_rsp(errcode, game_report)
  if errcode ~= 0 then
    log_error("[janesjing][BattleReport] on_get_game_report_rsp error errcode:" .. tostring(errcode))
    return
  end
  if logic_battle_report then
    logic_battle_report.OnGetGameReportRsp(game_report)
  end
end
function BattleReportHandler.send_batch_get_game_report_req()
  NetManager.SendPkg(1911420135)
end
function BattleReportHandler.on_batch_get_game_report_rsp(errcode, game_report)
end
function BattleReportHandler.on_notify_vod_game_report_state_update(battle_id, vod_state)
end
function BattleReportHandler.on_sync_microvision_report_switch(mv_report_switch, params_tbl)
  if mv_report_switch then
    log(bWriteLog and "[janesjiang][BattleReport] on_sync_microvision_report_switch true:")
  else
    log(bWriteLog and "[janesjiang][BattleReport] on_sync_microvision_report_switch false")
  end
  if params_tbl and params_tbl.ovb_domain_name then
    log(bWriteLog and "[janesjiang][BattleReport] on_sync_microvision_report_switch ovb_domain_name[" .. params_tbl.ovb_domain_name .. "]")
  else
    log(bWriteLog and "[janesjiang][BattleReport] on_sync_microvision_report_switch ovb_domain_name is nil")
  end
  if logic_battle_report then
    logic_battle_report.OnSyncBattleReportSwitch(mv_report_switch, params_tbl)
  end
end
function BattleReportHandler.send_get_game_report_by_uid_req(battle_id, uid)
  NetManager.SendPkg(881710055, battle_id, uid)
end
function BattleReportHandler.on_get_game_report_by_uid_rsp(errcode, game_report)
  if errcode ~= 0 then
    log_error("[janesjing][BattleReport] on_get_game_report_by_uid_rsp error errcode:" .. tostring(errcode))
    return
  end
  if logic_battle_report then
    logic_battle_report.OnGetGameReportRsp(game_report)
  end
end
return BattleReportHandler