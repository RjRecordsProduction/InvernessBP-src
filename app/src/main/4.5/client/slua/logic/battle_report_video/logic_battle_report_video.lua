local LogicBattleReportVideo = {
  NEWBIE_GUIDE_GEN_ENTRANCE_1 = 1,
  NEWBIE_GUIDE_GEN_ENTRANCE_2 = 2,
  NEWBIE_GUIDE_LOSS_REPLAY = 3
}
local report_macro = require("client.slua.logic.battle_report_video.battle_report_macro")
local ovb_domain_name = ""
local data_config_marco = require("client.logic.data.data_config_marco")
local PlayLimitServerCfgName = data_config_marco.ovb_ram_limit_table
local play_limit_table
local play_count = 0
function LogicBattleReportVideo.OnLogOut()
  log(bWriteLog and "[janesjiang][BattleReport] OnLogOut")
  play_limit_table = nil
end
function LogicBattleReportVideo.GetOvbDomainName()
  return ovb_domain_name
end
function LogicBattleReportVideo.GetDefaultBG()
  return "/Game/UMG/Texture/Lobby_NoAtlas/Share_Video_BG3.Share_Video_BG3"
end
function LogicBattleReportVideo.GetExpiredBg()
  return "/Game/UMG/Texture/Lobby_NoAtlas/DL_bigmap_bg01.DL_bigmap_bg01"
end
function LogicBattleReportVideo.GetClientVodState(server_vod_state)
  local s = report_macro.ENUM_REPORT_VOD_STATE.CAN_NOT_VOD
  if server_vod_state == 0 then
    s = report_macro.ENUM_REPORT_VOD_STATE.CAN_BE_VOD
  elseif server_vod_state == 1 then
    s = report_macro.ENUM_REPORT_VOD_STATE.VODING
  elseif server_vod_state == 2 then
    s = report_macro.ENUM_REPORT_VOD_STATE.VODED
  end
  return s
end
function LogicBattleReportVideo.OnGetGameReportRsp(game_report)
  if game_report == nil then
    return
  end
  log_tree(bWriteLog and "[janesjiang][BattleReport] OnGetGameReportRsp:", game_report)
  EventSystem:postEvent(EVENTTYPE_BATTLE_REPORT_VIDEO, EVENTID_ON_GET_GAME_REPORT_RSP, game_report)
end
function LogicBattleReportVideo.OnSyncBattleReportSwitch(server_switch, params_tbl)
  if params_tbl then
    ovb_domain_name = params_tbl.ovb_domain_name or ""
  end
end
local sortFunction = function(a, b)
  if a.device_ram and b.device_ram then
    return a.device_ram < b.device_ram
  else
    log(bWriteLog and string.format("[janesjiang][BattleReport] table [%s] sort error", PlayLimitServerCfgName))
    return true
  end
end
function LogicBattleReportVideo.ReqPlayLimitConfig(callback)
  if play_limit_table == nil then
    local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
    local on_req = function(table_name, table_data)
      play_limit_table = BasicDataServerTable:GetCacheData(PlayLimitServerCfgName) or {}
      table.sort(play_limit_table, sortFunction)
      if callback then
        callback()
      end
    end
    BasicDataServerTable:GetOrReqData(PlayLimitServerCfgName, on_req)
  elseif callback then
    callback()
  end
end
function LogicBattleReportVideo.IsReachPlayLimit()
  if play_limit_table == nil then
    return false
  end
  local device_mem_size = Client.GetMemorySize()
  local m
  for k, v in pairs(play_limit_table) do
    m = tonumber(v.device_ram)
    if m and device_mem_size <= m and v.play_limit then
      if play_count < v.play_limit then
        log(bWriteLog and string.format("[janesjiang][BattleReport] Not Reach Play Limit DeviceMemory[%d] CurPlayCount[%d]", device_mem_size, play_count))
        return false
      else
        log(bWriteLog and string.format("[janesjiang][BattleReport] Reach Play Limit DeviceMemory[%d] CurPlayCount[%d]", device_mem_size, play_count))
        return true
      end
    end
  end
  log(bWriteLog and string.format("[janesjiang][BattleReport] No Play Limit DeviceMemory[%d] CurPlayCount[%d]", device_mem_size, play_count))
  return false
end
function LogicBattleReportVideo.IncreasePlayCount()
  play_count = play_count + 1
end
return LogicBattleReportVideo