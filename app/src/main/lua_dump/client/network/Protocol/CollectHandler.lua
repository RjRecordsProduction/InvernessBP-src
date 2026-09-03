local NetManager = require("client.network.comm.NetManager")
local CollectHandler = {}
function CollectHandler.send_get_collect_sys_main_data_req()
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  if not collect_module:CanShowCollect() then
    return
  end
  NetManager.SendPkg(371367955)
end
function CollectHandler.on_get_collect_sys_main_data_rsp(err_code, collect_data, param)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  return collect_module:OnGetMainData(err_code, collect_data, param)
end
function CollectHandler.send_set_collect_sys_privacy_req(switch_type, switch_value)
  log_warning(bWriteLog and string.format("CollectHandler.send_set_collect_sys_privacy_req. switch_type: %s, switch_value: %s", switch_type, switch_value))
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  if not collect_module:CanShowCollect() then
    return
  end
  NetManager.SendPkg(1551383643, switch_type, switch_value)
end
function CollectHandler.on_set_collect_sys_privacy_rsp(err_code, switch_type, switch_value)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local collect_privacy_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_privacy_module)
  return collect_privacy_module:OnChangePrivacySetting(err_code, switch_type, switch_value)
end
function CollectHandler.send_get_collect_sys_privacy_req()
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  if not collect_module:CanShowCollect() then
    return
  end
  NetManager.SendPkg(804358059)
end
function CollectHandler.on_get_collect_sys_privacy_rsp(err_code, privacy)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
  local collect_privacy_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_privacy_module)
  return collect_privacy_module:OnGetPrivacy(err_code, privacy)
end
function CollectHandler.send_get_collect_detail_req(uid, source)
  log(bWriteLog and string.format("CollectHandler.send_get_collect_detail_req. uid: %s, source: %s", uid, source))
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  if not collect_module:CanShowCollect() then
    return
  end
  NetManager.SendPkg(1121297703, uid, source)
end
function CollectHandler.on_get_collect_detail_rsp(err_code, other_uid, source, data)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return true
  end
  log(bWriteLog and string.format("CollectHandler.on_get_collect_detail_rsp. other_uid: %s, source: %s", other_uid, source))
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  collect_module:OnGetItemData(other_uid, data)
  EventSystem:postEvent(EVENTTYPE_COLLECT, EVENTID_COLLECT_DETAIL_DATA, data, other_uid)
  collect_module:UpdateCollectDetailData(nil, nil, other_uid)
  local collect_inherit_data = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_inherit_data)
  collect_inherit_data:SetInviteCollectData(other_uid, data)
end
function CollectHandler.send_get_collect_award_privilege_req()
  NetManager.SendPkg(873633767)
end
function CollectHandler.on_get_collect_award_privilege_rsp(err_code, data)
  if err_code ~= 0 then
    ShowNotice(err_code)
    return true
  end
  local NicknameColorManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NicknameColorManager)
  NicknameColorManager:on_get_collect_award_privilege_rsp(data)
  local logic_share_bag_privilege_util = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_share_bag_privilege_util)
  logic_share_bag_privilege_util:on_get_collect_award_privilege_rsp(data)
  local collect_limit_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_limit_module)
  collect_limit_module:on_get_collect_award_privilege_rsp(data)
  local LogicKillCucolorisRecolor = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicKillCucolorisRecolor)
  LogicKillCucolorisRecolor:on_get_collect_award_privilege_rsp(data)
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  logic_pet:on_get_collect_award_privilege_rsp(data)
  local collect_inherit_data = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_inherit_data)
  collect_inherit_data:SetExpireTime(data and data.inherit_priv)
  local LogicEliminationKingEffect = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicEliminationKingEffect)
  LogicEliminationKingEffect:on_get_collect_award_privilege_rsp(data)
end
function CollectHandler.send_set_collect_privilege_req(item_id, optype)
  NetManager.SendPkg(1885336543, item_id, optype)
end
function CollectHandler.on_set_collect_privilege_rsp(err_code, item_id, optype)
  log(bWriteLog and string.format("CollectHandler.on_set_collect_privilege_rsp %s %s", tostring(item_id), tostring(optype)))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return true
  end
end
function CollectHandler.on_notify_collect_sys_data(collect_data)
  if collect_data then
    local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
    collect_module:NotifyCollectData(collect_data)
    collect_module:UpdateCollectDetailData(true)
    EventSystem:postEvent(EVENTTYPE_COLLECT, EVENTID_COLLECT_DATA_NOTIFY)
  end
end
function CollectHandler.on_notify_collect_privilege_data(data)
  local logic_share_bag_privilege_util = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_share_bag_privilege_util)
  logic_share_bag_privilege_util:on_notify_collect_privilege_data(data)
  local LogicKillCucolorisRecolor = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicKillCucolorisRecolor)
  LogicKillCucolorisRecolor:on_notify_collect_privilege_data(data)
  local NicknameColorManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NicknameColorManager)
  NicknameColorManager:on_notify_collect_privilege_data(data)
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  logic_pet:on_notify_collect_privilege_data(data)
end
function CollectHandler.on_notify_collect_score_change(ret, total_score_change, total_score)
  if GameStatus and not GameStatus.IsInLobbyOrMainCity() then
    log(bWriteLog and string.format("CollectHandler.on_notify_collect_score_change Outside trigger only."))
    return
  end
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  if not growthprojectMgrB.IsFinishAllNewGuide() then
    log(bWriteLog and string.format("CollectHandler.on_notify_collect_score_change No need to display during the novice period."))
    return
  end
  if ret ~= 0 then
    ShowNotice(ret)
    return
  end
  log(bWriteLog and string.format("CollectHandler.on_notify_collect_score_change total_score_change = %s, total_score = %s", total_score_change, total_score))
  local collect_up_level = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_up_level)
  collect_up_level:ShowCollectProgressBar(total_score_change, total_score)
end
function CollectHandler.send_get_inherit_relation_req()
  NetManager.SendPkg(1434691367)
end
function CollectHandler.on_get_inherit_relation_rsp(ret_code, inherit_datas)
  log(bWriteLog and "xcc on_get_inherit_relation_rsp ret_code:" .. tostring(ret_code))
  if ret_code ~= 0 then
    ShowNotice(ret_code)
    return
  end
  log_tree(bWriteLog and "xcc on_get_inherit_relation_rsp owner", inherit_datas.inherit_owner)
  log_tree(bWriteLog and "xcc on_get_inherit_relation_rsp other", inherit_datas.inherit_other)
  local collect_inherit_data = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_inherit_data)
  collect_inherit_data:UpdateInheritDatas(true, inherit_datas.inherit_owner, true)
  collect_inherit_data:UpdateInheritDatas(false, inherit_datas.inherit_other, true)
  collect_inherit_data:ReSetTimer()
end
function CollectHandler.send_build_inherit_relation_req(target_uid)
  NetManager.SendPkg(2032147175, target_uid)
end
function CollectHandler.on_build_inherit_relation_rsp(retcode, target_uid)
  log(bWriteLog and "xcc on_build_inherit_relation_rsp retcode:" .. tostring(retcode))
  if retcode ~= 0 then
    ShowNotice(retcode)
    return
  end
  log(bWriteLog and "xcc on_build_inherit_relation_rsp target_uid:" .. tostring(target_uid))
  local collect_inherit_data = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_inherit_data)
  collect_inherit_data:UpdateInheritDatas(true, {
    other = target_uid,
    state = collect_inherit_data:GetStates().wait_used,
    end_time = collect_inherit_data:GetMailOutTime()
  })
  collect_inherit_data:ReSetTimer()
end
function CollectHandler.on_build_inherit_relation_notify(source_uid, invite_time)
  log(bWriteLog and "xcc on_build_inherit_relation_notify source_uid:" .. tostring(source_uid))
  log(bWriteLog and "xcc on_build_inherit_relation_notify invite_time" .. tostring(invite_time))
  local collect_inherit_data = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_inherit_data)
  collect_inherit_data:AddInvitedOnLine(source_uid, invite_time)
end
function CollectHandler.send_build_inherit_relation_op_req(source_uid, op_type)
  NetManager.SendPkg(71387815, source_uid, op_type)
end
function CollectHandler.on_build_inherit_relation_op_rsp(retcode, source_uid, op_type)
  log(bWriteLog and "xcc on_build_inherit_relation_op_rsp retcode:" .. tostring(retcode))
  log(bWriteLog and "xcc on_build_inherit_relation_op_rsp source_uid:" .. tostring(source_uid))
  if retcode ~= 0 then
    ShowNotice(retcode)
    return
  end
  local collect_inherit_data = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_inherit_data)
  local state = op_type == 1 and collect_inherit_data:GetStates().using or collect_inherit_data:GetStates().denied
  collect_inherit_data:UpdateInheritDatas(false, {owner = source_uid, state = state})
  collect_inherit_data:RemoveInvitedOnLine(source_uid)
  EventSystem:postEvent(EVENTTYPE_COLLECT, EVENTID_COLLECT_INHERIT_BUTTON_REFRESH)
end
function CollectHandler.on_build_inherit_relation_op_notify(target_uid, op_type, reasonId)
  log(bWriteLog and "xcc on_build_inherit_relation_op_notify target_uid:" .. tostring(target_uid))
  log(bWriteLog and "xcc on_build_inherit_relation_op_notify op_type:" .. tostring(op_type))
  log(bWriteLog and "xcc on_build_inherit_relation_op_notify reasonId:" .. tostring(reasonId))
  local collect_inherit_data = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_inherit_data)
  if op_type == 1 then
    collect_inherit_data:UpdateInheritDatas(true, {
      state = collect_inherit_data:GetStates().using
    })
  else
    collect_inherit_data:UpdateInheritDatas(true, {
      state = collect_inherit_data:GetStates().denied
    })
    collect_inherit_data:ReSetTimer()
    EventSystem:postEvent(EVENTTYPE_COLLECT, EVENTID_COLLECT_INHERIT_BUTTON_REFRESH)
    ShowNotice(reasonId)
  end
end
function CollectHandler.send_del_inherit_relation_req(target_uid, optype)
  NetManager.SendPkg(1532097831, target_uid, optype)
end
function CollectHandler.on_del_inherit_relation_rsp(retcode, target_uid, optype)
  log(bWriteLog and "xcc on_del_inherit_relation_rsp retcode:" .. tostring(retcode))
  if retcode ~= 0 then
    ShowNotice(retcode)
    return
  end
  log(bWriteLog and "xcc on_del_inherit_relation_rsp target_uid:" .. tostring(target_uid))
  log(bWriteLog and "xcc on_del_inherit_relation_rsp optype:" .. tostring(optype))
  local collect_inherit_data = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_inherit_data)
  if optype == 0 then
    collect_inherit_data:UpdateInheritDatas(true, {
      state = collect_inherit_data:GetStates().lifted
    })
    ShowNotice(77705)
  else
    collect_inherit_data:UpdateInheritDatas(false, {
      state = collect_inherit_data:GetStates().lifted
    })
  end
  collect_inherit_data:ReSetTimer()
end
function CollectHandler.on_del_inherit_relation_notify(source_uid, optype)
  log(bWriteLog and "xcc on_del_inherit_relation_notify source_uid:" .. tostring(source_uid))
  log(bWriteLog and "xcc on_del_inherit_relation_notify optype:" .. tostring(optype))
  local collect_inherit_data = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_inherit_data)
  if optype == 1 then
    collect_inherit_data:UpdateInheritDatas(false, {
      state = collect_inherit_data:GetStates().lifted
    })
    collect_inherit_data:RemoveInvitedOnLine(source_uid)
  else
    collect_inherit_data:UpdateInheritDatas(true, {
      state = collect_inherit_data:GetStates().lifted
    })
  end
end
function CollectHandler.send_set_elimination_king_effect_req(resid)
  NetManager.SendPkg(1164988723, resid)
end
function CollectHandler.on_set_elimination_king_effect_rsp(recode, resid)
  local LogicEliminationKingEffect = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicEliminationKingEffect)
  LogicEliminationKingEffect:on_set_elimination_king_effect_rsp(resid)
end
function CollectHandler.send_report_collect_detail_tlog(tlog_table)
  NetManager.SendPkg(272454958, tlog_table)
  log_tree("CollectHandler.send_report_collect_detail_tlog tlog_table:", tlog_table)
end
local reqRsp = {
  send_set_collect_privilege_req = "on_set_collect_privilege_rsp"
}
local ProtoPromiseHookTool = require("client.network.comm.ProtoPromiseHookTool")
ProtoPromiseHookTool.HookPair(reqRsp, CollectHandler)
return CollectHandler