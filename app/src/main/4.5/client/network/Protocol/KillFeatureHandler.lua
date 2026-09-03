local NetManager = require("client.network.comm.NetManager")
local KillFeatureHandler = {}
function KillFeatureHandler.send_get_accumulation_kill_info_req(target_uid)
  if target_uid == tonumber(DataMgr.roleData.uid) then
    target_uid = nil
  end
  log(bWriteLog and "KillFeatureHandler.send_get_accumulation_kill_info_req target_uid:" .. tostring(target_uid))
  NetManager.SendPkg(1982414663, target_uid)
end
function KillFeatureHandler.on_get_accumulation_kill_info_rsp(err_code, uid, table_info)
  log(bWriteLog and "KillFeatureHandler.on_get_accumulation_kill_info_rsp err_code:" .. tostring(err_code))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  log_tree(bWriteLog and "KillFeatureHandler.on_get_accumulation_kill_info_rsp table_info:", table_info)
  local LogicKillCounter = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicKillCounter)
  LogicKillCounter:on_get_accumulation_kill_info_rsp(uid, table_info)
end
function KillFeatureHandler.send_arm_accumulate_feature_req(oper_type, feature_id, weapon_id)
  log(bWriteLog and "KillFeatureHandler.send_arm_accumulate_feature_req oper_type:" .. tostring(oper_type) .. " feature_id:" .. tostring(feature_id) .. " weapon_id:" .. tostring(weapon_id))
  NetManager.SendPkg(2114581831, oper_type, feature_id, weapon_id)
end
function KillFeatureHandler.on_arm_accumulate_feature_rsp(err_code, cur_arm_list)
  log(bWriteLog and "KillFeatureHandler.on_arm_accumulate_feature_rsp err_code:" .. tostring(err_code))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  log_tree(bWriteLog and "KillFeatureHandler.on_arm_accumulate_feature_rsp cur_arm_list:", cur_arm_list)
  local LogicKillCounter = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicKillCounter)
  LogicKillCounter:on_arm_accumulate_feature_rsp(cur_arm_list)
end
function KillFeatureHandler.send_get_last_kill_special_effects_req()
  NetManager.SendPkg(1968179343)
end
function KillFeatureHandler.on_get_last_kill_special_effects_rsp(err_code, data_list)
  log(bWriteLog and "KillFeatureHandler.on_get_last_kill_special_effects_rsp err_code:" .. tostring(err_code))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  log_tree(bWriteLog and "KillFeatureHandler.on_get_last_kill_special_effects_rsp data_list:", data_list)
  local LogicLastKillEffecs = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicLastKillEffecs)
  LogicLastKillEffecs:on_get_last_kill_special_effects_rsp(data_list)
end
function KillFeatureHandler.send_last_kill_special_effects_oper_req(oper_type, effect_id)
  NetManager.SendPkg(1692587559, oper_type, effect_id)
end
function KillFeatureHandler.on_last_kill_special_effects_oper_rsp(err_code, cur_effect_list)
  log(bWriteLog and "KillFeatureHandler.on_last_kill_special_effects_oper_rsp err_code:" .. tostring(err_code))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  log_tree(bWriteLog and "KillFeatureHandler.on_last_kill_special_effects_oper_rsp cur_effect_list:", cur_effect_list)
  local LogicLastKillEffecs = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicLastKillEffecs)
  LogicLastKillEffecs:on_last_kill_special_effects_oper_rsp(cur_effect_list)
end
return KillFeatureHandler