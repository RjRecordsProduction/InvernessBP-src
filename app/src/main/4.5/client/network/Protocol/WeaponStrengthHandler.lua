local NetManager = require("client.network.comm.NetManager")
local WeaponStrengthHandler = {}
function WeaponStrengthHandler.send_get_weapon_power_data_req()
  log(bWriteLog and "WeaponStrengthHandler.send_get_weapon_power_data_req")
  NetManager.SendPkg(1164671595)
end
function WeaponStrengthHandler.on_get_weapon_power_data_rsp(cur_weapon_power_data, history_weapon_power_data)
  log(bWriteLog and "WeaponStrengthHandler.on_get_weapon_power_data_rsp")
  log_tree("WeaponStrengthHandler.on_get_weapon_power_data_rsp cur_weapon_power_data", cur_weapon_power_data)
  log_tree("WeaponStrengthHandler.on_get_weapon_power_data_rsp history_weapon_power_data", history_weapon_power_data)
  local logic_weapon_strength = require("client.slua.logic.weapon_strength.logic_weapon_strength")
  logic_weapon_strength:proc_get_weapon_power_data_rsp(cur_weapon_power_data, history_weapon_power_data)
end
function WeaponStrengthHandler.send_get_weapon_power_rank_req(zone_id, weapon_rank_id, extra_data)
  log(bWriteLog and string.format("WeaponStrengthHandler.send_get_weapon_power_rank_req zone_id = %s, weapon_rank_id = %s", tostring(zone_id), tostring(weapon_rank_id)))
  NetManager.SendPkg(526652867, zone_id, weapon_rank_id, extra_data)
end
function WeaponStrengthHandler.on_get_weapon_power_rank_rsp(err_code, rank_list, zone_id, rank_id, extra_data)
  log(bWriteLog and "WeaponStrengthHandler.on_get_weapon_power_rank_rsp")
  log_tree(bWriteLog and "WeaponStrengthHandler.on_get_weapon_power_rank_rsp rank_list", rank_list)
  if err_code ~= 0 then
    log(bWriteLog and string.format("WeaponStrengthHandler.on_get_weapon_power_rank_rsp err_code = %s", tostring(err_code)))
  end
  if extra_data and extra_data.from == "rank_ctrl" then
    local RankNetHandler = require("client.slua.logic.rank.rank_net_handler")
    local RankConfig = require("client.slua.logic.rank.rank_config")
    RankNetHandler.RspFetchRankData(err_code, zone_id, RankConfig.ScoreType.weapon_usage_score_rating, rank_list, 1, extra_data)
  else
    local logic_weapon_strength_rank = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_weapon_strength_rank)
    logic_weapon_strength_rank:proc_get_weapon_power_rank_rsp(err_code, rank_list, zone_id, rank_id, extra_data)
  end
end
function WeaponStrengthHandler.on_notify_weapon_power_result(weapon_power_add_result, max_power_count)
  log(bWriteLog and "WeaponStrengthHandler.on_notify_weapon_power_result")
  log_tree("weapon_power_add_result", weapon_power_add_result)
  log(bWriteLog and string.format("WeaponStrengthHandler.on_notify_weapon_power_result max_power_count = %s", tostring(max_power_count)))
  local logic_weaponstrength_result = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_weaponstrength_result)
  logic_weaponstrength_result:proc_notify_weapon_power_result(weapon_power_add_result, max_power_count)
end
function WeaponStrengthHandler.send_get_last_weapon_power_rank_reward_req()
  log(bWriteLog and "WeaponStrengthHandler.send_get_last_weapon_power_rank_reward_req")
  NetManager.SendPkg(695440831)
end
function WeaponStrengthHandler.on_get_last_weapon_power_rank_reward_rsp(reward_data)
  log(bWriteLog and "WeaponStrengthHandler.on_get_last_weapon_power_rank_reward_rsp")
  log_tree("WeaponStrengthHandler.on_get_last_weapon_power_rank_reward_rsp reward_data", reward_data)
  local logic_weapon_strength_weekly_award = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_weapon_strength_weekly_award)
  logic_weapon_strength_weekly_award:proc_get_last_weapon_power_rank_reward_rsp(reward_data)
end
function WeaponStrengthHandler.send_get_on_user_weapon_power_rank_req(rank_uid, zone_id, weapon_rank_id, extra_data)
  log(bWriteLog and string.format("WeaponStrengthHandler.send_get_on_user_weapon_power_rank_req rank_uid = %s, zone_id = %s, weapon_rank_id = %s", tostring(rank_uid), tostring(zone_id), tostring(weapon_rank_id)))
  NetManager.SendPkg(1124172387, rank_uid, zone_id, weapon_rank_id, extra_data)
end
function WeaponStrengthHandler.on_get_on_user_weapon_power_rank_rsp(is_ok, rank_uid, one_weapon_power_rank_data)
  log(bWriteLog and string.format("WeaponStrengthHandler.on_get_on_user_weapon_power_rank_rsp is_ok = %s, rank_uid = %s", tostring(is_ok), tostring(rank_uid)))
  log_tree("WeaponStrengthHandler.on_get_on_user_weapon_power_rank_rs one_weapon_power_rank_data", one_weapon_power_rank_data)
  if is_ok ~= 0 then
    log(bWriteLog and string.format("WeaponStrengthHandler.on_get_on_user_weapon_power_rank_rsp is_ok = %s", tostring(is_ok)))
  end
  if one_weapon_power_rank_data.extra_data and one_weapon_power_rank_data.extra_data.from == "rank_ctrl" then
    local RankNetHandler = require("client.slua.logic.rank.rank_net_handler")
    local my_rank = {
      uid = tonumber(DataMgr.roleData.uid),
      score = 0,
      rank_no = 0
    }
    if one_weapon_power_rank_data.score and one_weapon_power_rank_data.rank_no and one_weapon_power_rank_data.score ~= 0 then
      my_rank = {
        uid = tonumber(rank_uid),
        score = one_weapon_power_rank_data.score,
        rank_no = one_weapon_power_rank_data.rank_no
      }
    end
    RankNetHandler.RspSelfRankData("rank", is_ok, one_weapon_power_rank_data.zone_id, my_rank, one_weapon_power_rank_data.extra_data)
  else
    local logic_weapon_strength_rank = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_weapon_strength_rank)
    logic_weapon_strength_rank:proc_get_on_user_weapon_power_rank_rsp(is_ok, rank_uid, one_weapon_power_rank_data)
  end
end
function WeaponStrengthHandler.send_get_weapon_history_segment_data_req(weapon_id)
  log(bWriteLog and string.format("WeaponStrengthHandler.send_get_weapon_history_segment_data_req weapon_id = %s", tostring(weapon_id)))
  NetManager.SendPkg(1774290343, weapon_id)
end
function WeaponStrengthHandler.on_get_weapon_history_segment_data_rsp(errcode, record)
  log(bWriteLog and "WeaponStrengthHandler.on_get_weapon_history_segment_data_rsp")
  if errcode ~= 0 then
    log(bWriteLog and string.format("WeaponStrengthHandler.on_get_weapon_history_segment_data_rsp errcode = %s", tostring(errcode)))
    return
  end
  local logic_weapon_strength = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_weapon_strength)
  logic_weapon_strength:proc_get_weapon_history_segment_data_rsp(record)
end
return WeaponStrengthHandler