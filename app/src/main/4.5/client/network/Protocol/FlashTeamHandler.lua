local NetManager = require("client.network.comm.NetManager")
local FlashTeamHandler = {}
local flash_match_team_const = require("client.slua.logic.friend.flash_match_team_const")
local logic_wedding_red_envelope = require("client.slua.logic.red_envelope.logic_wedding_red_envelope")
function FlashTeamHandler.send_create_flash_squad_req(name, active_slots, need_apply, allow_member_message, invite_uids, is_private)
  log_format(bWriteLog and "FlashTeamHandler.send_create_flash_squad_req name:%s, active_slots:%s, allow_member_message:%s, need_apply:%s", name, active_slots, allow_member_message, need_apply)
  log_tree(bWriteLog and "FlashTeamHandler.send_create_flash_squad_req invite_uids:", invite_uids)
  NetManager.SendPkg(1479256327, name, active_slots, need_apply, allow_member_message, invite_uids, is_private)
end
function FlashTeamHandler.on_create_flash_squad_rsp(ret, squad_id, squad_summary, members_brief)
  if ret ~= 0 then
    ShowNotice(ret)
    return
  end
  log_format(bWriteLog and "FlashTeamHandler.on_create_flash_squad_rsp ret:%s, squad_id:%s", ret, squad_id)
  log_tree(bWriteLog and "FlashTeamHandler.on_create_flash_squad_rsp squad_summary:", squad_summary)
  log_tree(bWriteLog and "FlashTeamHandler.on_create_flash_squad_rsp members_brief:", members_brief)
  UIManager.CloseUI(UIManager.UI_Config.TeamQuick_Create_UIBP)
  ShowNotice(817067)
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  logic_flash_match_team:AddMyTeam(squad_summary)
  logic_flash_match_team:addToSaveFlashTeam({
    [squad_id] = squad_summary
  })
  logic_flash_match_team:addToSaveFlashMemberTeam({
    [squad_id] = members_brief
  })
  logic_flash_match_team:SaveRapportClaimed(squad_id, {})
  UIManager.ShowUI(UIManager.UI_Config.TeamQuick_Main_UIBP, squad_id)
  EventSystem:postEvent(EVENTTYPE_FLASH_TEAM, EVENTID_FLASH_TEAM_CREATE)
end
function FlashTeamHandler.send_join_flash_squad_req(squad_id, source, checkRepetitive)
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  if logic_flash_match_team:IsMyTeam(squad_id) then
    log_format(bWriteLog and string.format("FlashTeamHandler.send_join_flash_squad_req already in team squad_id=%d", squad_id))
    return
  end
  if checkRepetitive and logic_flash_match_team:CheckRepetitiveApply(squad_id) then
    ShowNotice(441023)
    return
  end
  log_format(bWriteLog and "FlashTeamHandler.send_join_flash_squad_req squad_id:%s, source:%s", squad_id, source)
  NetManager.SendPkg(1436867623, squad_id, source)
end
function FlashTeamHandler.on_join_flash_squad_rsp(ret, squad_id, squad_summary, apply_id)
  log_format(bWriteLog and "FlashTeamHandler.on_join_flash_squad_rsp ret:%s, squad_id:%s, squad_summary:%s, apply_id:%s", ret, squad_id, squad_summary, apply_id)
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  if ret ~= 0 then
    ShowNotice(ret)
    if ret == 441001 or ret == 441022 or ret == 441024 then
      logic_flash_match_team:ClearMyFlashTeamInviteList(squad_id, true)
    end
    return
  end
  logic_flash_match_team:OnJoinFlashSquad(squad_id, squad_summary, apply_id)
  EventSystem:postEvent(EVENTTYPE_FLASH_TEAM, EVENTID_FLASH_TEAM_JOIN_CHG, squad_id)
end
function FlashTeamHandler.send_quit_flash_squad_req(squad_ids, force_dismiss)
  log_format(bWriteLog and "FlashTeamHandler.send_quit_flash_squad_req squad_ids:%s, force_dismiss:%s", squad_ids, force_dismiss)
  NetManager.SendPkg(2056588647, squad_ids, force_dismiss)
end
function FlashTeamHandler.on_quit_flash_squad_rsp(ret, squad_id, dismissed, new_leader_uid)
  log_format(bWriteLog and "FlashTeamHandler.on_quit_flash_squad_rsp ret:%s, squad_id:%s", ret, squad_id)
  if ret ~= 0 then
    return
  end
  if dismissed then
    ShowNotice(817033)
  else
    ShowNotice(817030)
  end
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  local ownTeamInfo = logic_flash_match_team:getOwnFlashTeamInfo()
  if ownTeamInfo and ownTeamInfo.squads then
    ownTeamInfo.squads[squad_id] = nil
    ownTeamInfo.squad_count = ownTeamInfo.squad_count - 1
  end
  logic_flash_match_team:SetReserJoinPopTimer()
  EventSystem:postEvent(EVENTTYPE_FLASH_TEAM, EVENTID_FLASH_TEAM_DATA_CHG)
end
function FlashTeamHandler.send_transfer_flash_squad_req(squad_id, target_uid)
  NetManager.SendPkg(475237095, squad_id, target_uid)
end
function FlashTeamHandler.on_transfer_flash_squad_rsp(ret)
  log_format(bWriteLog and "FlashTeamHandler.on_transfer_flash_squad_rsp ret:%s", ret)
  if ret == 0 then
    ShowNotice(8179)
    local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
    logic_flash_match_team:reqMyTeamData()
  end
end
function FlashTeamHandler.send_update_flash_squad_setting_req(squad_id, setting)
  log(bWriteLog and "FlashTeamHandler.send_update_flash_squad_setting_req squad_id = " .. tostring(squad_id))
  log_tree(bWriteLog and "FlashTeamHandler.send_update_flash_squad_setting_req setting = ", setting)
  NetManager.SendPkg(1112355719, squad_id, setting)
  FlashTeamHandler.isSettingSquad = squad_id
end
function FlashTeamHandler.on_update_flash_squad_setting_rsp(ret)
  log(bWriteLog and "FlashTeamHandler.on_update_flash_squad_setting_rsp ret = " .. tostring(ret))
  if ret ~= 0 then
    local ret2notice = {
      [441013] = 655323,
      [441011] = 20400014
    }
    if ret2notice[ret] then
      ShowNotice(ret2notice[ret])
    else
      ShowNotice(ret)
    end
    return
  end
  EventSystem:postEvent(EVENTTYPE_FLASH_TEAM, EVENTID_FLASH_TEAM_SETTING_CHG, ret)
  if FlashTeamHandler.isSettingSquad then
    log(bWriteLog and "FlashTeamHandler.on_update_flash_squad_setting_rsp re-fetch squad_id = " .. tostring(FlashTeamHandler.isSettingSquad))
    FlashTeamHandler.send_batch_get_flash_squad_summary_req({
      FlashTeamHandler.isSettingSquad
    })
    FlashTeamHandler.isSettingSquad = nil
  end
end
function FlashTeamHandler.send_batch_get_flash_squad_summary_req(squad_ids)
  if not squad_ids then
    local TimeUtil = require("client.common.time_util")
    local BATCH_SUMMARY_REQ_INTERVAL = 0.5
    local nowTime = TimeUtil.GetServerTimeInSecWithFraction()
    local lastTime = FlashTeamHandler._lastBatchSummaryReqTime or 0
    local subtractTime = nowTime - lastTime
    if 0 <= subtractTime and BATCH_SUMMARY_REQ_INTERVAL > subtractTime then
      log_format(bWriteLog and "FlashTeamHandler.send_batch_get_flash_squad_summary_req throttled, interval:%s", nowTime - lastTime)
      return
    end
    FlashTeamHandler._lastBatchSummaryReqTime = nowTime
  end
  log("FlashTeamHandler.send_batch_get_flash_squad_summary_req")
  NetManager.SendPkg(1031386731, squad_ids)
end
function FlashTeamHandler.on_batch_get_flash_squad_summary_rsp(ret, summaries, members_briefs)
  if ret ~= 0 then
    log_format(bWriteLog and string.format("FlashTeamHandler.on_batch_get_flash_squad_summary_rsp ret = %s", ret))
    return
  end
  local unpackSummaries = {}
  for k, v in pairs(summaries) do
    unpackSummaries[k] = slua.LuaArchiverDecode(LuaStateWrapper, v)
  end
  local unpackMembersBriefs = {}
  for k, v in pairs(members_briefs) do
    unpackMembersBriefs[k] = slua.LuaArchiverDecode(LuaStateWrapper, v)
  end
  log_tree(bWriteLog and "FlashTeamHandler.on_batch_get_flash_squad_summary_rsp unpackSummaries:", unpackSummaries)
  log_tree(bWriteLog and "FlashTeamHandler.on_batch_get_flash_squad_summary_rsp unpackMembersBriefs:", unpackMembersBriefs)
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  logic_flash_match_team:addToSaveFlashTeam(unpackSummaries)
  logic_flash_match_team:addToSaveFlashMemberTeam(unpackMembersBriefs)
  logic_flash_match_team:SetReserJoinPopTimer()
  EventSystem:postEvent(EVENTTYPE_FLASH_TEAM, EVENTID_FLASH_TEAM_DATA_CHG)
end
function FlashTeamHandler.send_get_all_flash_squad_apply_list_req()
  log(bWriteLog and "FlashTeamHandler.send_get_all_flash_squad_apply_list_req")
  NetManager.SendPkg(507021575)
end
function FlashTeamHandler.on_get_all_flash_squad_apply_list_rsp(ret, squad_applies)
  log_format(bWriteLog and "FlashTeamHandler.on_get_all_flash_squad_apply_list_rsp ret:%s squad_apply_num:%s", ret, #squad_applies)
  log_tree(bWriteLog and "FlashTeamHandler.on_get_all_flash_squad_apply_list_rsp applications:", squad_applies)
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  logic_flash_match_team:OnGetFlashSquadApplyList(squad_applies)
end
function FlashTeamHandler.send_handle_flash_squad_apply_req(squad_id, apply_id, action)
  log_format(bWriteLog and "FlashTeamHandler.send_handle_flash_squad_apply_req squad_id:%s, apply_id:%s, action:%s", squad_id, apply_id, action)
  NetManager.SendPkg(2033474407, squad_id, apply_id, action)
  FlashTeamHandler.lastHandleApplyAction = action
end
function FlashTeamHandler.on_handle_flash_squad_apply_rsp(ret, squad_id, apply_id)
  log_format(bWriteLog and "FlashTeamHandler.on_handle_flash_squad_apply_rsp ret:%s", ret)
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  logic_flash_match_team:OnHandleFlashSquadApply(ret, squad_id, apply_id)
  if ret == 0 and (FlashTeamHandler.lastHandleApplyAction == 1 or FlashTeamHandler.lastHandleApplyAction == 3) then
    ShowNotice(817100)
  end
end
function FlashTeamHandler.send_get_flash_squad_invite_list_req()
  log(bWriteLog and "FlashTeamHandler.send_get_flash_squad_invite_list_req")
  NetManager.SendPkg(919055711)
end
function FlashTeamHandler.on_get_flash_squad_invite_list_rsp(ret, invites)
  log_format(bWriteLog and "FlashTeamHandler.on_get_flash_squad_invite_list_rsp ret:%s", ret)
  log_tree(bWriteLog and "FlashTeamHandler.on_get_flash_squad_invite_list_rsp invites:", invites)
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  logic_flash_match_team:OnGetFlashSquadInviteList(invites)
end
function FlashTeamHandler.on_flash_squad_invite_notify(invite_info)
  log_format(bWriteLog and "FlashTeamHandler.on_flash_squad_invite_notify")
  log_tree(bWriteLog and "FlashTeamHandler.on_flash_squad_invite_notify inviteInfo:", invite_info)
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  logic_flash_match_team:OnFlashSquadInviteNotify(invite_info)
  EventSystem:postEvent(EVENTTYPE_FLASH_TEAM, EVENTID_FLASH_TEAM_APPLY_LIST_CHANGE)
end
function FlashTeamHandler.on_notify_flash_squad_change(squad_id, notify_type, notify_info)
  log(bWriteLog and "FlashTeamHandler.on_notify_flash_squad_change squad_id:" .. squad_id .. ", notify_type:" .. notify_type)
  log_tree(bWriteLog and "FlashTeamHandler.on_notify_flash_squad_change notify_info:", notify_info)
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  if notify_type == flash_match_team_const.SquadNotifyType.NewApply then
    local application_info = notify_info
    if application_info.apply_id then
      logic_flash_match_team:OnFlashSquadApplyNotify(application_info)
    end
    EventSystem:postEvent(EVENTTYPE_FLASH_TEAM, EVENTID_FLASH_TEAM_APPLY_LIST_CHANGE)
  elseif notify_type == flash_match_team_const.SquadNotifyType.ApplyHandled then
    local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
    logic_flash_match_team:reqMyTeamData()
  elseif notify_type == flash_match_team_const.SquadNotifyType.AppliesChanged and squad_id then
    local squadSummary = logic_flash_match_team:GetFlashTeamSummaryById(squad_id)
    if squadSummary then
      local bIsLeader = squadSummary.leader_uid == tonumber(DataMgr.roleData.uid)
      if bIsLeader then
        FlashTeamHandler.send_get_all_flash_squad_apply_list_req()
        FlashTeamHandler.send_get_flash_squad_invite_list_req()
      end
    end
  end
  if notify_type == flash_match_team_const.SquadNotifyType.MemberKicked then
    log(bWriteLog and "FlashTeamHandler.on_notify_flash_squad_change notify_type:MemberKicked be kicked!")
    logic_flash_match_team:reqMyTeamData()
  end
  if notify_type == flash_match_team_const.SquadNotifyType.LeaderTransfer then
    log(bWriteLog and "FlashTeamHandler.on_notify_flash_squad_change notify_type:LeaderTransfer leader transferred!")
    FlashTeamHandler.send_batch_get_flash_squad_summary_req({squad_id})
  end
end
function FlashTeamHandler.send_get_flash_squad_info_req(squad_id)
  log_format(bWriteLog and "FlashTeamHandler.send_get_flash_squad_info_req suqad_id:%s", squad_id)
  NetManager.SendPkg(56229607, squad_id)
end
function FlashTeamHandler.on_get_flash_squad_info_rsp(ret, squad_data)
  log_format(bWriteLog and "FlashTeamHandler.on_get_flash_squad_info_rsp ret:%d", ret)
  log_tree(bWriteLog and "FlashTeamHandler.on_get_flash_squad_info_rsp squad_data:", squad_data)
  if ret ~= 0 then
    return
  end
  local logic_teamquick_res = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_teamquick_res)
  logic_teamquick_res:on_get_flash_squad_info_rsp(ret, squad_data)
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  logic_flash_match_team:UpdateFlashTeamDetail(squad_data.squad_id, squad_data)
end
function FlashTeamHandler.send_invite_join_flash_squad_req(squad_id, target_uid)
  log_format(bWriteLog and "FlashTeamHandler.send_invite_join_flash_squad_req squad_id:%s, target_uid:%s", squad_id, target_uid)
  log_tree(bWriteLog and "FlashTeamHandler.send_invite_join_flash_squad_req target_uid:", target_uid)
  NetManager.SendPkg(1944001363, squad_id, target_uid)
end
function FlashTeamHandler.on_invite_join_flash_squad_rsp(ret, squad_id, target_uid)
  log_format(bWriteLog and "FlashTeamHandler.on_invite_join_flash_squad_rsp ret:%s, squad_id:%s, target_uid:%s", ret, squad_id, target_uid)
  if ret ~= 0 then
    ShowNotice(ret)
    return
  else
    ShowNotice(817111)
  end
  if not target_uid or #target_uid == 0 then
    return
  end
  local flash_team_data_handler = require("client.slua.logic.friend.flash_team.flash_team_data_handler")
  for _, inviteResult in ipairs(target_uid) do
    if inviteResult and inviteResult.ret == 0 then
      flash_team_data_handler:SaveInviteJoinSuccessUid(squad_id, inviteResult.target_uid)
    end
  end
end
function FlashTeamHandler.send_update_flash_squad_msg_req(squad_id, msg)
  NetManager.SendPkg(747097511, squad_id, msg)
end
function FlashTeamHandler.on_update_flash_squad_msg_rsp(ret)
  if ret ~= 0 then
    log_format(bWriteLog and string.format("FlashTeamHandler.on_update_flash_squad_msg_rsp ret:%s", ret))
    ShowNotice(ret)
    return
  end
  EventSystem:postEvent(EVENTTYPE_FLASH_TEAM, EVENTID_FLASH_TEAM_MESSAGE_CHG)
end
function FlashTeamHandler.send_batch_get_flash_squad_members_brief_req(squad_ids)
  log_tree(bWriteLog and "FlashTeamHandler.send_batch_get_flash_squad_members_brief_req", squad_ids)
  NetManager.SendPkg(1181710403, squad_ids)
end
function FlashTeamHandler.on_batch_get_flash_squad_members_brief_rsp(ret, members_briefs)
  log_tree(bWriteLog and "FlashTeamHandler.on_batch_get_flash_squad_members_brief_rsp", members_briefs)
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  local unpackMembersBriefs = {}
  for k, v in pairs(members_briefs) do
    unpackMembersBriefs[k] = slua.LuaArchiverDecode(LuaStateWrapper, v)
  end
  logic_flash_match_team:addToSaveFlashMemberTeam(unpackMembersBriefs)
  EventSystem:postEvent(EVENTTYPE_FLASH_TEAM, EVENTID_FLASH_TEAM_DATA_CHG)
  EventSystem:postEvent(EVENTTYPE_FLASH_TEAM, EVENTID_FLASH_TEAM_MEMBER_RSP)
end
function FlashTeamHandler.send_get_flash_squad_recommend_req(count, filter)
  local TimeUtil = require("client.common.time_util")
  local GET_FLASH_SQUAD_RECOMMEND_REQ_INTERVAL = 1
  local nowTime = TimeUtil.GetServerTimeInSecWithFraction()
  local lastTime = FlashTeamHandler._lastGetFlashSquadRecommendReqTime or 0
  local subtractTime = nowTime - lastTime
  if 0 <= subtractTime and GET_FLASH_SQUAD_RECOMMEND_REQ_INTERVAL > subtractTime then
    log_format(bWriteLog and "FlashTeamHandler.send_get_flash_squad_recommend_req throttled, interval:%s", nowTime - lastTime)
    return
  end
  FlashTeamHandler._lastGetFlashSquadRecommendReqTime = nowTime
  log_tree(bWriteLog and "FlashTeamHandler.send_get_flash_squad_recommend_req filter:", filter)
  NetManager.SendPkg(1901055263, count, filter)
end
function FlashTeamHandler.on_get_flash_squad_recommend_rsp(ret, squads)
  log_tree(bWriteLog and "FlashTeamHandler.on_get_flash_squad_recommend_rsp", squads)
  if ret ~= 0 then
    log_format(bWriteLog and string.format("FlashTeamHandler.on_get_flash_squad_recommend_rsp"))
    return
  end
  if not squads or #squads == 0 then
    log_format(bWriteLog and "FlashTeamHandler.on_get_flash_squad_recommend_rsp squads is empty")
  end
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  logic_flash_match_team:saveRecomSquad(squads)
  local logic_teamquick_join = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_teamquick_join)
  logic_teamquick_join:proc_get_flash_squad_recommend_rsp(ret, squads)
end
function FlashTeamHandler.send_get_flash_squad_data_req()
  log(bWriteLog and "FlashTeamHandler.send_get_flash_squad_data_req")
  NetManager.SendPkg(710332583)
end
function FlashTeamHandler.on_get_flash_squad_data_rsp(ret, flash_squad)
  log(bWriteLog and "FlashTeamHandler.on_get_flash_squad_data_rsp ret = " .. tostring(ret))
  log_tree("flash_squad = ", flash_squad)
  if ret ~= 0 then
    log(bWriteLog and "FlashTeamHandler.on_get_flash_squad_data_rsp")
    return
  end
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  logic_flash_match_team:setOwnFlashTeamInfo(flash_squad)
end
function FlashTeamHandler.send_pin_flash_squad_req(pinned_squad_ids)
  log_tree(bWriteLog and "FlashTeamHandler.send_pin_flash_squad_req", pinned_squad_ids)
  NetManager.SendPkg(1049658311, pinned_squad_ids)
  FlashTeamHandler._pendingPinnedSquadIds = pinned_squad_ids
end
function FlashTeamHandler.on_pin_flash_squad_rsp(ret)
  log_format(bWriteLog and "FlashTeamHandler.on_pin_flash_squad_rsp ret:%s", tostring(ret))
  if ret ~= 0 then
    return
  end
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  logic_flash_match_team:UpdatePinnedSquads(FlashTeamHandler._pendingPinnedSquadIds)
  FlashTeamHandler._pendingPinnedSquadIds = nil
end
function FlashTeamHandler.send_report_flash_squad_name_req(squad_id, report_type, description)
  log_format(bWriteLog and "FlashTeamHandler.send_report_flash_squad_name_req squad_id:%d, report_type:%d, description:%s", squad_id, report_type, description)
  NetManager.SendPkg(1644624715, squad_id, report_type, description)
end
function FlashTeamHandler.on_report_flash_squad_name_rsp(err)
  log_format(bWriteLog and "FlashTeamHandler.on_report_flash_squad_name_rsp err:%d", err)
  if err ~= 0 then
    ShowNotice(err)
  else
    ShowNotice(97000024)
  end
end
function FlashTeamHandler.send_get_flash_squad_chat_history_req(squad_id)
  NetManager.SendPkg(1706865831, squad_id)
end
function FlashTeamHandler.on_get_flash_squad_chat_history_rsp(ret, chat_list)
  log_tree(bWriteLog and "FlashTeamHandler.on_get_flash_squad_chat_history_rsp ret:%d ", ret, chat_list)
  if ret == 0 then
    local logic_chat_channel_flash_match_team = require("client.slua.logic.lobby_chat.logic_chat_channel_flash_match_team")
    logic_chat_channel_flash_match_team.on_get_flash_squad_chat_history_rsp(chat_list)
  end
end
function FlashTeamHandler.send_delete_flash_squad_invite_req(inviter_id, squad_id, delete_all)
  log_format(bWriteLog and "FlashTeamHandler.send_delete_flash_squad_invite_req inviter_id:%s, squad_id:%s, delete_all:%s", inviter_id, squad_id, delete_all)
  NetManager.SendPkg(1787334007, inviter_id, squad_id, delete_all)
end
function FlashTeamHandler.on_delete_flash_squad_invite_rsp(ret, inviter_id, squad_id)
  log_format(bWriteLog and "FlashTeamHandler.on_delete_flash_squad_invite_rsp ret:%s, inviter_id:%s, squad_id:%s", ret, inviter_id, squad_id)
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  logic_flash_match_team:OnDeleteFlashSquadInvite(ret, inviter_id, squad_id)
end
function FlashTeamHandler.send_clear_squad_perk_red_dot_req(squad_id, perk_types)
  log_format(bWriteLog and "FlashTeamHandler.send_clear_squad_perk_red_dot_req squad_id:%s, perk_types:%s", squad_id, perk_types)
  NetManager.SendPkg(696331367, squad_id, perk_types)
end
function FlashTeamHandler.on_clear_squad_perk_red_dot_rsp(ret)
  log_format(bWriteLog and "FlashTeamHandler.on_clear_squad_perk_red_dot_rsp ret:%s", ret)
end
function FlashTeamHandler.send_claim_rapport_reward_req(squad_id, condition_param)
  log_format(bWriteLog and "FlashTeamHandler.send_claim_rapport_reward_req squad_id:%s, condition_param:%s", squad_id, condition_param)
  NetManager.SendPkg(988388199, squad_id, condition_param)
end
function FlashTeamHandler.on_claim_rapport_reward_rsp(ret, squad_id, reward_items)
  log_format(bWriteLog and "FlashTeamHandler.on_claim_rapport_reward_rsp, ret:%s, squad_id:%s", ret, squad_id)
  log_tree(bWriteLog and "FlashTeamHandler.on_claim_rapport_reward_rsp reward_items", reward_items)
  if ret ~= 0 then
    ShowNotice(ret)
    return
  end
  local logic_teamquick_res = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_teamquick_res)
  logic_teamquick_res:on_claim_rapport_reward_rsp(ret, squad_id, reward_items)
  local FlashTeamHandler = require("client.network.Protocol.FlashTeamHandler")
  FlashTeamHandler.send_get_rapport_claimed_req(squad_id)
end
function FlashTeamHandler.send_get_rapport_claimed_req(squad_id)
  log_format(bWriteLog and "FlashTeamHandler.send_get_rapport_claimed_req squad_id:%s", squad_id)
  NetManager.SendPkg(1734808527, squad_id)
end
function FlashTeamHandler.on_get_rapport_claimed_rsp(ret, squad_id, squad_claimed)
  log_format(bWriteLog and "FlashTeamHandler.on_get_rapport_claimed_rsp")
  if ret ~= 0 then
    log_format(bWriteLog and string.format("FlashTeamHandler.on_get_rapport_claimed_rsp"))
    return
  end
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  logic_flash_match_team:SaveRapportClaimed(squad_id, squad_claimed)
end
function FlashTeamHandler.send_kick_flash_squad_member_req(squad_id, uid_list)
  log_format(bWriteLog and "FlashTeamHandler.send_kick_flash_squad_member_req squad_id:%s, uid_list:%s", squad_id, table.concat(uid_list, ";"))
  NetManager.SendPkg(1828581135, squad_id, uid_list)
end
function FlashTeamHandler.on_kick_flash_squad_member_rsp(ret, squad_id, uid_list)
  log_format(bWriteLog and "FlashTeamHandler.on_kick_flash_squad_member_rsp ret:%s, squad_id:%s, uid_list:%s", ret, squad_id, table.concat(uid_list, ";"))
  if ret ~= 0 then
    ShowNotice(ret)
    return
  end
  ShowNotice(68034)
  FlashTeamHandler.send_batch_get_flash_squad_summary_req({squad_id})
end
function FlashTeamHandler.send_get_prefer_modes_for_flash_squad_req()
  NetManager.SendPkg(1364165351)
end
function FlashTeamHandler.on_get_prefer_modes_for_flash_squad_rsp(res, data)
  log_tree(bWriteLog and "FlashTeamHandler.on_get_prefer_modes_for_flash_squad_rsp prefer_modes:", data)
  if not (res == 0 and data) or not next(data) then
    return
  end
  local logic_teamquick_join = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_teamquick_join)
  logic_teamquick_join:proc_get_prefer_modes_for_flash_squad_rsp(data)
end
function FlashTeamHandler.send_get_flash_squad_apply_count_req()
  log(bWriteLog and "FlashTeamHandler.send_get_flash_squad_apply_count_req")
  NetManager.SendPkg(371107711)
end
function FlashTeamHandler.on_get_flash_squad_apply_count_rsp(ret, total_count)
  log(bWriteLog and "FlashTeamHandler.on_get_flash_squad_apply_count_rsp ret = " .. tostring(ret) .. " total_count = " .. tostring(total_count))
  if ret ~= 0 then
    return
  end
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  logic_flash_match_team:SetPreFetchApplyCnt(total_count)
end
function FlashTeamHandler.send_flash_squad_create_arrange_req(squad_id, mode_name_id, arrange_time)
  log(bWriteLog and string.format("FlashTeamHandler.send_flash_squad_create_arrange_req squad_id:%s, mode_name_id:%s, arrange_time:%s", squad_id, mode_name_id, arrange_time))
  NetManager.SendPkg(414595367, squad_id, mode_name_id, arrange_time)
end
function FlashTeamHandler.on_flash_squad_create_arrange_rsp(err, squad_id, arrange_id, mode_name_id, arrange_time)
  if err ~= 0 then
    ShowNotice(err)
    return
  end
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  logic_flash_match_team:proc_flash_squad_create_arrange_rsp(squad_id, arrange_id, mode_name_id, arrange_time)
end
function FlashTeamHandler.send_flash_squad_like_arrange_req(squad_id, arrange_id, like_counts)
  NetManager.SendPkg(852412967, squad_id, arrange_id, like_counts)
end
function FlashTeamHandler.on_flash_squad_like_arrange_rsp(err, squad_id, arrange_id, like_total)
  if err ~= 0 then
    ShowNotice(err)
    return
  end
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  logic_flash_match_team:proc_flash_squad_like_arrange_rsp(squad_id, arrange_id, like_total)
end
function FlashTeamHandler.send_flash_squad_join_arrange_team_req(squad_id, arrange_id)
  NetManager.SendPkg(1413377655, squad_id, arrange_id)
end
function FlashTeamHandler.on_flash_squad_join_arrange_team_rsp(err, squad_id, arrange_id, team_id)
  if err ~= 0 then
    ShowNotice(err)
    return
  end
end
function FlashTeamHandler.on_flash_squad_bond_notify(battle_id, teammates)
  local teamData = {battle_id = battle_id, teammates = teammates}
  log_tree(bWriteLog and "FlashTeamHandler.on_flash_squad_bond_notify teamData:", teamData)
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  logic_flash_match_team:proc_flash_squad_bond_notify(teamData)
end
function FlashTeamHandler.send_flash_squad_bond_agree_req(battle_id)
  log_format(bWriteLog and "FlashTeamHandler.send_flash_squad_bond_agree_req battle_id:%s", battle_id)
  NetManager.SendPkg(272588935)
  local flash_team_data_handler = require("client.slua.logic.friend.flash_team.flash_team_data_handler")
  flash_team_data_handler:AddPlayerAgreeState(battle_id, DataMgr.roleData.uid)
  EventSystem:postEvent(EVENTTYPE_FLASH_TEAM, EVENTID_RECIEVE_VOTE_TEAM_NOTIFY)
end
function FlashTeamHandler.on_flash_squad_bond_agree_rsp()
end
function FlashTeamHandler.on_flash_squad_bond_agree_notify(battle_id, teammates)
  log_format(bWriteLog and "FlashTeamHandler.on_flash_squad_bond_agree_notify battle_id:%s", battle_id)
  log_tree(bWriteLog and "FlashTeamHandler.on_flash_squad_bond_agree_notify", teammates)
  local flash_team_data_handler = require("client.slua.logic.friend.flash_team.flash_team_data_handler")
  for idx, uid in pairs(teammates) do
    flash_team_data_handler:AddPlayerAgreeState(battle_id, uid)
  end
  EventSystem:postEvent(EVENTTYPE_FLASH_TEAM, EVENTID_RECIEVE_VOTE_TEAM_NOTIFY)
end
function FlashTeamHandler.send_flash_squad_bond_block_today_req(is_shield)
  log(bWriteLog and "FlashTeamHandler.send_flash_squad_bond_block_today_req is_shield:", is_shield)
  NetManager.SendPkg(1855362983, is_shield)
end
function FlashTeamHandler.on_flash_squad_bond_block_today_rsp(err, is_shield)
  if err ~= 0 then
    return
  end
end
function FlashTeamHandler.on_flash_squad_bond_join_notify(squad_id, squad_summary, members_brief)
  log_format(bWriteLog and "FlashTeamHandler.on_flash_squad_bond_join_notify Create squad_id: %s", squad_id)
  log_tree(bWriteLog and "FlashTeamHandler.on_flash_squad_bond_join_notify squad_summary:", squad_summary)
  log_tree(bWriteLog and "FlashTeamHandler.on_flash_squad_bond_join_notify members_brief:", members_brief)
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  logic_flash_match_team:AddMyTeam(squad_summary)
  logic_flash_match_team:addToSaveFlashMemberTeam({
    [members_brief.squad_id] = members_brief
  })
  local logic_flash_team_utils = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_team_utils)
  logic_flash_team_utils:SetNewCreateTeam(squad_id)
  EventSystem:postEvent(EVENTTYPE_FLASH_TEAM, ENTRY_SPECIFIC_REMIND_TIPS, LocUtil.LocalizeResFormat(818261))
  EventSystem:postEvent(EVENTTYPE_FLASH_TEAM, EVENTID_FLASH_TEAM_DATA_CHG)
  EventSystem:postEvent(EVENTTYPE_FLASH_TEAM, EVENTID_RECIEVE_VOTE_TEAM_SUCCESS)
end
return FlashTeamHandler