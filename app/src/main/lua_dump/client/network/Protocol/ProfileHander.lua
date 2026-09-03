local NetManager = require("client.network.comm.NetManager")
local ProfileHander = {bLog = false, bUseNewLogic = false}
function ProfileHander.send_batch_get_bin_profile_req(sendSeq, binListUid, rankDataFlag, count, module_id, incl_flag)
  log(bWriteLog and "ProfileHander.send_batch_get_bin_profile_req sendseq = " .. sendSeq .. ", rankDataFlag = " .. tostring(rankDataFlag) .. ", count = " .. tostring(count) .. ", incl_flag = " .. tostring(incl_flag))
  if ProfileHander.bLog then
    local uidList = slua.LuaArchiverDecode(LuaStateWrapper, binListUid)
    log_tree("ProfileHander.send_batch_get_bin_profile_req = ", uidList)
  end
  NetManager.SendPkg(619845007, sendSeq, binListUid, rankDataFlag, count, module_id, incl_flag)
end
function ProfileHander.on_batch_get_bin_profile_rsp(sendSeq, res, bin_profiles, hasRankData, incl_flag)
  if res ~= NetErrorCode_NONE then
    EventSystem:postEvent(EVENTTYPE_PROFILE, EVENTID_PROFILE_FAIL, sendSeq)
    return
  end
  local profiles = slua.LuaArchiverDecode(LuaStateWrapper, bin_profiles) or {}
  if profiles == nil then
    log(bWriteLog and "ProfileHander.on_batch_get_bin_profile_rsp profiles == nil")
    return
  end
  local logic_profile_security = require("client.slua.logic.profile.logic_profile_security")
  logic_profile_security.ProcRoleDataList(profiles)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  logic_profile:proc_batch_get_bin_profile_rsp(sendSeq, profiles, hasRankData)
  EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTTYPE_SEX_TEAM_DISPLAY)
end
function ProfileHander.send_get_avatar_show_req(uid, source)
  log(bWriteLog and "ProfileHander.send_get_avatar_show_req uid = " .. uid .. ", source = " .. tostring(source))
  NetManager.SendPkg(1481802315, uid, source)
end
function ProfileHander.on_get_avatar_show_rsp(res, target_uid, data)
  log(bWriteLog and "ProfileHander.on_get_avatar_show_rsp res = " .. res .. ", target_uid = " .. tostring(target_uid))
  local BasicDataAvatarWearInfo = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataAvatarWearInfo)
  BasicDataAvatarWearInfo:on_get_avatar_show_rsp(res, target_uid, data)
  EventSystem:postEvent(EVENTTYPE_PLAYER_PROFILE, EVENTID_GOT_PROFILE_AVATAR_DATA, target_uid)
end
function ProfileHander.send_chg_avatar_show_switch_req(showRole)
  NetManager.SendPkg(2005102823, showRole)
end
function ProfileHander.on_chg_avatar_show_switch_rsp(res, bShow)
  local LogicSettingBasic = require("client.slua.logic.setting.logic_setting_basic")
  LogicSettingBasic.OnChangeAvatarShowSwitchRoleInfoRsp()
  if res ~= NetErrorCode_NONE then
    return
  end
  local roleUid = DataMgr.roleData.uid
  local BasicDataAvatarWearInfo = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataAvatarWearInfo)
  local playerInfo = BasicDataAvatarWearInfo:GetCacheData(roleUid)
  if nil == playerInfo then
    return
  end
  playerInfo.bshow = bShow
  xpcall(function()
    EventSystem:postEvent(BP_ENUM_MODULE_SETTING, EVENTID_NET_ROLE_INFO_RSP)
  end, function()
    log_error("on_chg_avatar_show_switch_rsp event handle error")
  end)
end
function ProfileHander.send_get_evaluation_req(player_uid)
  NetManager.SendPkg(498733479, player_uid)
end
function ProfileHander.on_get_evaluation_rsp(error_code, player_uid, evaluation)
  local logic_team_evaluation_view = require("client.slua.logic.team_evaluation.logic_team_evaluation_view")
  logic_team_evaluation_view.on_get_evaluation_rsp(error_code, player_uid, evaluation)
end
function ProfileHander.send_set_evaluation_privacy(privacy_type)
  NetManager.SendPkg(638055551, privacy_type)
end
function ProfileHander.on_evaluation_privacy_rsp(error_code, privacy_type)
  local logic_team_evaluation_view = require("client.slua.logic.team_evaluation.logic_team_evaluation_view")
  logic_team_evaluation_view.on_evaluation_privacy_rsp(error_code, privacy_type)
end
function ProfileHander.send_finish_evaluation_guide_req()
  NetManager.SendPkg(2022436831)
end
function ProfileHander.on_finish_evaluation_guide_rsp()
  local logic_team_evaluation_view = require("client.slua.logic.team_evaluation.logic_team_evaluation_view")
  logic_team_evaluation_view.on_finish_evaluation_guide_rsp()
end
return ProfileHander