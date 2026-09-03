local NetManager = require("client.network.comm.NetManager")
local ConscribeHandler = {}
local HandleErrorCode = function(res)
  if res ~= 0 then
    log(bWriteLog and "[v_wllwu] ConscribeHandler.HandleErrorCode errcode is " .. tostring(res))
    if res == 100211001 then
      local MatchSystem = require("client.slua.logic.match.logic_match")
      MatchSystem.ShowBanTip(MatchSystem.GetTeamUpBanTip())
    elseif res == 12020001 then
      local MatchSystem = require("client.slua.logic.match.logic_match")
      MatchSystem.ShowBanTip(LocUtil.GetLocalizeResStr(29113))
    elseif res == 100220026 then
      local logic_access_restriction = require("client.logic.common.logic_access_restriction")
      local tips = logic_access_restriction.GetPopTips(logic_access_restriction.EAccessType.TeamPlatform)
      if tips then
        ShowNotice(tips)
      else
        ShowNotice(logic_access_restriction.EAccessType.TeamPlatform)
      end
    elseif res == 100220031 then
      ShowNotice(7568)
    elseif res == 100220032 then
      ShowNotice(46072)
    else
      ShowNotice(res)
    end
    return true
  end
  return false
end
local IsModeSelectDataError = function(res)
  log(bWriteLog and "[v_wllwu] ConscribeHandler IsModeSelectDataError, res = " .. tostring(res))
  if res == 100220030 then
    ShowNotice(100220030)
    log(bWriteLog and "[v_wllwu] ConscribeHandler ModeSelectDataError")
    local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
    logic_mode_selection:RequireModeData()
    return true
  end
  return false
end
function ConscribeHandler.send_publish_team_conscribe_req(conscribe)
  log_tree("[muidarzhang] ConscribeHandler.send_publish_team_conscribe_req", conscribe)
  NetManager.SendPkg(2118431400, conscribe)
end
function ConscribeHandler.on_publish_team_conscribe_res(res, msg)
  if IsModeSelectDataError(res) then
    return
  end
  if HandleErrorCode(res) then
    return
  end
  local TeamPlatformSystem = require("client.slua.logic.teamup.logic_team_platform")
  TeamPlatformSystem.OnPublishTeamConscribeRes(res)
  if msg then
    log_tree(bWriteLog and "[v_wllwu] ConscribeHandler.on_publish_team_conscribe_res, msg is:", msg)
    local logic_chat_recruit_msg = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_recruit_msg)
    logic_chat_recruit_msg:OnReceiveSelfPublishTeamRecruitMsg(msg)
  end
end
function ConscribeHandler.send_cancel_team_conscribe_req(need_no_rsp)
  NetManager.SendPkg(997178144, need_no_rsp)
end
function ConscribeHandler.on_cancel_team_conscribe_res(res, team_id)
  local logic_team_my_team = require("client.slua.logic.teamup.logic_lobby_my_team")
  logic_team_my_team.on_cancel_team_conscribe_res(res, team_id)
end
function ConscribeHandler.send_quick_join_team_conscribe_req(condition)
  if condition then
    condition.lang = 0
  end
  log_tree(bWriteLog and "[v_wllwu] ConscribeHandler.send_quick_join_team_conscribe_req", condition)
  NetManager.SendPkg(697296992, condition)
end
function ConscribeHandler.on_quick_join_team_conscribe_res(res)
  log(bWriteLog and "[v_wllwu] ConscribeHandler.on_quick_join_team_conscribe_res, res is:" .. tostring(res))
  if IsModeSelectDataError(res) then
    return
  end
  HandleErrorCode(res)
end
function ConscribeHandler.send_search_team_conscribe_req(condition, search_reason)
  log(bWriteLog and "send_search_team_conscribe_req condition = " .. tostring(condition) .. "search_reason = " .. tostring(search_reason))
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local list = LogicFriend.GetAllFriendList(true, 10)
  if condition then
    condition.friend_uids = list
    condition.lang = 0
  end
  log_tree(bWriteLog and "[v_wllwu] ConscribeHandler.send_search_team_conscribe_req", condition)
  NetManager.SendPkg(1815455760, condition, search_reason)
end
function ConscribeHandler.on_search_team_conscribe_res(res, conscribes)
  local TeamPlatformSystem = require("client.slua.logic.teamup.logic_team_platform")
  log(bWriteLog and "[v_wllwu] ConscribeHandler.on_search_team_conscribe_res errcode is " .. tostring(res))
  if res == 100220000 then
    if not UIManager.IsUIShow(UIManager.UI_Config.TeamPlatform_Recruit_UIBP) and UIManager.IsUIShow(UIManager.UI_Config.TeamPlatform_Filter_UIBP) then
      ShowNotice(883003)
    end
    TeamPlatformSystem.ClearLastSearchTeamList()
    local logic_team_platform_new = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_team_platform_new)
    logic_team_platform_new:UpdateCurSelectFilterInfo()
    return
  elseif res == 100220002 then
    ShowNotice(res)
    TeamPlatformSystem.HandleRequestTimeLimitError()
    return
  end
  if HandleErrorCode(res) then
    return
  end
  log_tree("on_search_team_conscribe_res", conscribes)
  TeamPlatformSystem.OnSearchTeamConscribeRes(res, conscribes)
end
function ConscribeHandler.send_batch_get_team_conscribes_req(team_id_list)
  NetManager.SendPkg(1161472384, team_id_list)
end
function ConscribeHandler.on_batch_get_team_conscribes_res(res, conscribes)
  if HandleErrorCode(res) then
    return
  end
  local TeamPlatformSystem = require("client.slua.logic.teamup.logic_team_platform")
  TeamPlatformSystem.OnBatchGetTeamConscribesRes(res, conscribes)
end
function ConscribeHandler.on_team_conscribe_sync(team_id, conscribe, reason)
  local TeamPlatformSystem = require("client.slua.logic.teamup.logic_team_platform")
  TeamPlatformSystem.OnTeamConscribeSync(team_id, conscribe, reason)
  log_tree("on_team_conscribe_sync conscribe ", conscribe)
end
function ConscribeHandler.send_register_idle_player_req(condition)
  if condition then
    condition.lang = 0
  end
  log_tree(bWriteLog and "[v_wllwu] ConscribeHandler.send_register_idle_player_req", condition)
  NetManager.SendPkg(1589435080, condition)
end
function ConscribeHandler.on_register_idle_player_res(res, kd)
  local TeamPlatformSystem = require("client.slua.logic.teamup.logic_team_platform")
  if HandleErrorCode(res) then
    TeamPlatformSystem.registerSuc = false
    return
  end
  TeamPlatformSystem.UpdateSelfKdValue(kd)
  TeamPlatformSystem.registerSuc = true
end
function ConscribeHandler.send_unregister_idle_player_req()
  NetManager.SendPkg(1321300744)
end
function ConscribeHandler.on_unregister_idle_player_res(res)
  log(bWriteLog and "god test on_unregister_idle_player_rsp")
  if res == 0 then
    local TeamPlatformSystem = require("client.slua.logic.teamup.logic_team_platform")
    TeamPlatformSystem.registerSuc = false
  end
end
function ConscribeHandler.send_search_idle_player_req(cnt, player_ids)
  log(bWriteLog and "ConscribeHandler.send_search_idle_player_req cnt = " .. cnt)
  log_tree("player_ids = ", player_ids)
  NetManager.SendPkg(713077256, cnt, player_ids)
end
function ConscribeHandler.on_search_idle_player_res(res, player_list, replaced_uids, cnt)
  log(bWriteLog and "ConscribeHandler.on_search_idle_player_res res = " .. res .. ", cnt = " .. tostring(cnt))
  log_tree("player_list = ", player_list)
  log_tree("replaced_uids = ", replaced_uids)
  if HandleErrorCode(res) then
    return
  end
  local logic_team_my_team = require("client.slua.logic.teamup.logic_lobby_my_team")
  logic_team_my_team.on_search_idle_player_res(res, player_list, replaced_uids, cnt)
end
function ConscribeHandler.send_team_conscribe_info_req()
  NetManager.SendPkg(1583769344)
end
function ConscribeHandler.send_voice_feedback_req()
  NetManager.SendPkg(2098039431)
end
function ConscribeHandler.on_voice_feedback_rsp(res, respondent_info, questionnaire_list)
  local logic_mic_evaluation = require("client.slua.logic.teamup.logic_mic_evaluation")
  logic_mic_evaluation.on_voice_feedback_rsp(res, respondent_info, questionnaire_list)
end
function ConscribeHandler.send_voice_feedback_report_req(respondent_uid, score, questionnaire_answer, conscirbe_platform)
  log_tree("send_voice_feedback_report_req", {
    respondent_uid,
    score,
    questionnaire_answer,
    conscirbe_platform
  })
  conscirbe_platform = conscirbe_platform or 0
  NetManager.SendPkg(516535063, respondent_uid, score, questionnaire_answer, conscirbe_platform)
end
function ConscribeHandler.on_voice_feedback_report_rsp(res)
end
function ConscribeHandler.on_voice_feedback_notify(res, respondent_info, questionnaire_list, conscirbe_platform)
  local logic_mic_evaluation = require("client.slua.logic.teamup.logic_mic_evaluation")
  logic_mic_evaluation.on_voice_feedback_notify(res, respondent_info, questionnaire_list, conscirbe_platform)
end
function ConscribeHandler.send_get_team_conscribe_entry_status_req()
  NetManager.SendPkg(996502688)
end
function ConscribeHandler.on_get_team_conscribe_entry_status_res(res, kd)
  local TeamPlatformSystem = require("client.slua.logic.teamup.logic_team_platform")
  TeamPlatformSystem.CheckPersonalCredit(res, kd)
end
function ConscribeHandler.on_voice_feedback_update_notify(voice_feedback)
  local TeamPlatformSystem = require("client.slua.logic.teamup.logic_team_platform")
  TeamPlatformSystem.on_voice_feedback_update_notify(voice_feedback)
end
function ConscribeHandler.send_broadcast_team_conscribe_req()
  NetManager.SendPkg(1606367143)
end
function ConscribeHandler.on_broadcast_team_conscribe_rsp(err_code, left_time, msg)
  log(bWriteLog and "[v_wllwu] ConscribeHandler.on_roadcast_team_conscribe_rsp:" .. tostring(err_code) .. " left_time = " .. tostring(left_time))
  if err_code == 100220010 then
    ShowNotice(100220010)
  elseif err_code == 100220002 and 0 < left_time then
    ShowNotice(LocUtil.LocalizeResFormat(19370, left_time))
  end
  if err_code == 0 and msg then
    log_tree(bWriteLog and "[v_wllwu] ConscribeHandler.on_broadcast_team_conscribe_rsp, msg is:", msg)
    local logic_chat_recruit_msg = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_recruit_msg)
    logic_chat_recruit_msg:OnReceiveSelfPublishTeamRecruitMsg(msg)
  end
end
return ConscribeHandler