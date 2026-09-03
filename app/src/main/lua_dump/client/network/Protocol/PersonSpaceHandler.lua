local NetManager = require("client.network.comm.NetManager")
local PersonSpaceHandler = {}
function PersonSpaceHandler.send_remove_intimacy_reddot(reddot_type)
  NetManager.SendPkg(996111764, reddot_type)
end
function PersonSpaceHandler.send_get_other_intimacy_relation_req(other_uid)
  log(bWriteLog and "PersonSpaceHandler.send_get_other_intimacy_relation_req other_uid = " .. other_uid)
  NetManager.SendPkg(1862470287, other_uid)
end
function PersonSpaceHandler.on_get_other_intimacy_relation_rsp(other_uid, list, visible_switchs, partner_uid)
  log(bWriteLog and "PersonSpaceHandler.on_get_other_intimacy_relation_rsp other_uid = " .. other_uid .. ", partner_uid = " .. tostring(partner_uid))
  log_tree("list = ", list)
  log_tree("visible_switchs = ", visible_switchs)
  local logic_friend_intimacy = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_intimacy)
  logic_friend_intimacy:proc_get_other_intimacy_relation_rsp(other_uid, list, visible_switchs, partner_uid)
  local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
  PersonSpaceSystem.get_other_intimacy_relation_rsp(other_uid, list, visible_switchs, partner_uid)
end
function PersonSpaceHandler.on_notify_client_intimacy_data_chg(reddot_type)
  local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
  PersonSpaceSystem.notify_client_intimacy_data_chg(reddot_type)
end
function PersonSpaceHandler.send_make_intimacy_partner_req(target_uid)
  NetManager.SendPkg(999680891, target_uid)
end
function PersonSpaceHandler.on_make_intimacy_partner_rsp(target_uid, res, intimacy_partner_data)
  local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
  PersonSpaceSystem.make_intimacy_partner_rsp(target_uid, res, intimacy_partner_data)
end
function PersonSpaceHandler.send_agree_make_intimacy_partner_req(target_uid)
  NetManager.SendPkg(757391055, target_uid)
end
function PersonSpaceHandler.on_agree_make_intimacy_partner_rsp(target_uid, res, intimacy_partner_data)
  local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
  PersonSpaceSystem.agree_make_intimacy_partner_rsp(target_uid, res, intimacy_partner_data)
end
function PersonSpaceHandler.send_refuse_make_intimacy_partner_req(target_uid)
  NetManager.SendPkg(785122215, target_uid)
end
function PersonSpaceHandler.on_refuse_make_intimacy_partner_rsp(target_uid, res, intimacy_partner_data)
  local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
  PersonSpaceSystem.refuse_make_intimacy_partner_rsp(target_uid, res, intimacy_partner_data)
end
function PersonSpaceHandler.send_release_intimacy_partner_req(target_uid)
  NetManager.SendPkg(940551655, target_uid)
end
function PersonSpaceHandler.on_release_intimacy_partner_rsp(target_uid, res, intimacy_partner_data)
  local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
  PersonSpaceSystem.release_intimacy_partner_rsp(target_uid, res, intimacy_partner_data)
end
function PersonSpaceHandler.send_cancle_make_intimacy_partner_req(target_uid)
  NetManager.SendPkg(1424525863, target_uid)
end
function PersonSpaceHandler.on_cancle_make_intimacy_partner_rsp(target_uid, res, intimacy_partner_data)
  local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
  PersonSpaceSystem.cancle_make_intimacy_partner_rsp(target_uid, res, intimacy_partner_data)
end
function PersonSpaceHandler.send_set_intimacy_relation_visible_req(switch_list)
  log(bWriteLog and "PersonSpaceHandler.send_set_intimacy_relation_visible_req")
  log_tree("switch_list = ", switch_list)
  NetManager.SendPkg(1492744711, switch_list)
end
function PersonSpaceHandler.on_set_intimacy_relation_visible_rsp(res, switch_list)
  log(bWriteLog and "PersonSpaceHandler.on_set_intimacy_relation_visible_rsp res = " .. res)
  log_tree("switch_list = ", switch_list)
  if res ~= "ok" then
    ShowNotice(res)
    return
  end
  local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
  PersonSpaceSystem.proc_set_intimacy_relation_visible_rsp(switch_list)
end
function PersonSpaceHandler.send_get_intimacy_relation_visible_req()
  NetManager.SendPkg(1799379383)
end
function PersonSpaceHandler.on_get_intimacy_relation_visible_rsp(switch_list)
  local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
  PersonSpaceSystem.get_intimacy_relation_visible_rsp(switch_list)
end
function PersonSpaceHandler.send_set_intimacy_relation_prior_show(prior_type)
  log(bWriteLog and "PersonSpaceHandler.send_set_intimacy_relation_prior_show prior_type = " .. prior_type)
  NetManager.SendPkg(1094925516, prior_type)
end
function PersonSpaceHandler.on_set_intimacy_relation_prior_show_rsp(ret, prior_type)
  log(bWriteLog and "PersonSpaceHandler.on_set_intimacy_relation_prior_show_rsp ret = " .. ret .. ", prior_type = " .. tostring(prior_type))
  if ret ~= 0 then
    ShowNotice(ret)
    return
  end
  local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
  PersonSpaceSystem.proc_set_intimacy_relation_prior_show_rsp(prior_type)
end
function PersonSpaceHandler.send_get_intimacy_relation_prior_show()
  log(bWriteLog and "PersonSpaceHandler.send_get_intimacy_relation_prior_show")
  NetManager.SendPkg(87973068)
end
function PersonSpaceHandler.on_get_intimacy_relation_prior_show_rsp(ret, relationPrior)
  log(bWriteLog and "PersonSpaceHandler.on_get_intimacy_relation_prior_show_rsp ret = " .. ret)
  log_tree("relationPrior = ", relationPrior)
  if ret ~= 0 then
    ShowNotice(ret)
    return
  end
  local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
  PersonSpaceSystem.proc_get_intimacy_relation_prior_show_rsp(relationPrior)
end
function PersonSpaceHandler.send_get_interact_avatar_req()
  log(bWriteLog and "PersonSpaceHandler.send_get_interact_avatar_req")
  NetManager.SendPkg(383579175)
end
function PersonSpaceHandler.on_get_interact_avatar_rsp(err, rela_frd_list, relation_crystal_info, partner_srystal_info, cur_interact_avatar_posture)
  log(bWriteLog and "PersonSpaceHandler.on_get_interact_avatar_rsp err = " .. err)
  if err ~= 0 then
    if err == 13070028 then
      ShowNotice(77838)
      return
    end
    ShowNotice(err)
    return
  end
  log_tree("rela_frd_list = ", rela_frd_list)
  log_tree("relation_crystal_info = ", relation_crystal_info)
  log_tree("partner_srystal_info = ", partner_srystal_info)
  local logic_person_relation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_person_relation)
  logic_person_relation:proc_get_interact_avatar_rsp(rela_frd_list, relation_crystal_info, partner_srystal_info, cur_interact_avatar_posture)
end
function PersonSpaceHandler.send_set_interact_avatar_req(frd_list, pos_mod_id)
  NetManager.SendPkg(411250807, frd_list, pos_mod_id)
end
function PersonSpaceHandler.on_set_interact_avatar_rsp(err_list, uid_list, pos_mod_id)
  local logic_person_relation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_person_relation)
  logic_person_relation:on_set_interact_avatar_rsp(err_list, uid_list, pos_mod_id)
end
function PersonSpaceHandler.send_set_interact_crystal_req(crystal_list, is_partner)
  printf("PersonSpaceHandler.send_set_interact_crystal_req crystal_list:%s, is_partner:%s", crystal_list, is_partner)
  NetManager.SendPkg(1759661095, crystal_list, is_partner)
end
function PersonSpaceHandler.on_set_interact_crystal_rsp(err, crystal_list, is_partner, failed_uid, failed_season_id)
  printf("PersonSpaceHandler.on_set_interact_crystal_rsp err:%s, crystal_list:%s, is_partner:%s, failed_uid:%s, failed_season_id:%s", err, crystal_list, is_partner, failed_uid, failed_season_id)
  if err ~= 0 then
    return true
  end
  local logic_person_relation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_person_relation)
  logic_person_relation:on_set_interact_crystal_rsp(crystal_list, is_partner, failed_uid, failed_season_id)
end
function PersonSpaceHandler.send_batch_get_frd_interact_info_req(frd_uid, target_uid_list)
  NetManager.SendPkg(823584179, frd_uid, target_uid_list)
end
function PersonSpaceHandler.on_batch_get_frd_interact_info_rsp(err_code, frd_uid, frd_interact_info_list)
  if err_code ~= 0 then
    log(bWriteLog and "PersonSpaceHandler.on_batch_get_frd_interact_info_rsp err:" .. tostring(err_code))
    return
  end
  local logic_person_relation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_person_relation)
  logic_person_relation:on_batch_get_frd_interact_info_rsp(frd_uid, frd_interact_info_list)
end
function PersonSpaceHandler.send_soulmate_certification_set_show_req(is_show)
  printf("PersonSpaceHandler.send_soulmate_certification_set_show_req is_show:%s", is_show)
end
function PersonSpaceHandler.on_soulmate_certification_set_show_rsp(err, is_show)
  printf("PersonSpaceHandler.on_soulmate_certification_set_show_rsp err:%s, is_show:%s", err, is_show)
  if err ~= 0 then
    ShowNotice(err)
    return true
  end
end
function PersonSpaceHandler.send_soulmate_keepsake_show_switch_set_req(keepsake_show_switchs, is_partner)
  printf("PersonSpaceHandler.send_soulmate_keepsake_show_switch_set_req is_partner:%s, switch[1]:%s, switch[2]:%s", is_partner, keepsake_show_switchs[1], keepsake_show_switchs[2])
  NetManager.SendPkg(1475471803, keepsake_show_switchs, is_partner)
end
function PersonSpaceHandler.on_soulmate_keepsake_show_switch_set_rsp(err, keepsake_show_switchs, is_partner)
  if err ~= 0 then
    printf("PersonSpaceHandler.on_soulmate_keepsake_show_switch_set_rsp err:%s", err)
    ShowNotice(err)
    return true
  end
  printf("PersonSpaceHandler.on_soulmate_keepsake_show_switch_set_rsp is_partner:%s, switch[1]:%s, switch[2]:%s", is_partner, keepsake_show_switchs[1], keepsake_show_switchs[2])
  local uid = DataMgr.roleData.uid
  local update_profile = function()
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local myProfile = logic_profile:GetLocalProfile(uid)
    if not myProfile.soulmate_summary then
      printf("[WARN] PersonSpaceHandler.on_soulmate_keepsake_show_switch_set_rsp myProfile.soulmate_summary is nil. uid:%s", uid)
      return
    end
    if is_partner then
      myProfile.soulmate_summary.partner_    else
      myProfile.soulmate_summary.relation_    end
  end
  update_profile()
  EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_SOULMATE_CERTIFICATION_SET_SHOW_RSP)
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetNormalProfiles({uid}, function()
    update_profile()
  end, Enum_PROFILE_REPORT_CFG.PERSON_SPACE_INTIMACY, nil, true)
end
local reqRsp = {
  send_soulmate_keepsake_show_switch_set_req = "on_soulmate_keepsake_show_switch_set_rsp"
}
local ProtoPromiseHookTool = require("client.network.comm.ProtoPromiseHookTool")
ProtoPromiseHookTool.HookPair(reqRsp, PersonSpaceHandler)
return PersonSpaceHandler