local CorpsMemberSystem = {
  ApplyList = {},
  InvitedList = {},
  applyList = {},
  accept_yes = 1,
  accept_no = 2,
  isInit = false,
  waitForMemberList = false,
  invitedRemainNum = 0,
  memberReqCount = 10,
  lastGetCorpsMemberOnlineInfoReq = 0,
  GetCorpsMemberOnlineInfoRspTime = 0,
  member_online_info_interval = 5,
  MemberOnlineInfo = {}
}
local MemberPosition = {
  Commander = 1,
  SecCommander = 2,
  Elite = 3,
  Member = 11
}
function CorpsMemberSystem.GetOnlineStatus(uid)
  return CorpsMemberSystem.GetOnlineStatusWithDefault(uid)
end
local defaultOnlineInfo = {
  online = 0,
  game_id = 0,
  land_id = 0,
  teamState = 0,
  maxTeamAmount = 4,
  socialland_type = 0,
  currentTeamAmount = 1,
  tplan_type = 0,
  sub_mode = 0,
  cwow_type = 0
}
function CorpsMemberSystem.GetOnlineStatusWithDefault(uid)
  local OnlineInfo = CorpsMemberSystem.MemberOnlineInfo[uid]
  if OnlineInfo then
    return OnlineInfo
  else
    local member = CorpsMemberSystem.FindMemberByID(uid)
    if member then
      local TableUtil = require("common.table_util")
      local newInfo = TableUtil.CopyTable(defaultOnlineInfo)
      newInfo.online = member.online_state
      return newInfo
    else
      return defaultOnlineInfo
    end
  end
end
function CorpsMemberSystem.OnStatusChanged(packet)
  log_tree("CorpsMemberSystem OnStatusChanged", packet)
  if not packet then
    log(bWriteLog and "CorpsMemberSystem.OnStatusChanged:packet == nil")
    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_MEMBER_NO_UPDATE)
    return
  end
  if not next(packet) then
    log(bWriteLog and "CorpsMemberSystem.OnStatusChanged empty packet")
    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_MEMBER_NO_UPDATE)
    return
  end
  CorpsMemberSystem.MemberOnlineInfo = {}
  local uids = {}
  for i, v in pairs(packet) do
    CorpsMemberSystem.MemberOnlineInfo[i] = v
    CorpsMemberSystem.SetStatusExtra(v)
    table.insert(uids, i)
  end
  EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_MEMBER_ONLINE_INFO, uids)
  EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_MEMBER_ONLINE_INFO_UPDATE, uids)
end
function CorpsMemberSystem.on_notify_online_status_chg(uid, isOnline)
  local info = CorpsMemberSystem.MemberOnlineInfo[uid]
  if info then
    info.online = isOnline
    if tostring(uid) == tostring(DataMgr.roleData.uid) then
      info.online = 1
    end
    if isOnline == 0 then
      info.tplan_type = 0
      if info.is_video_inspect then
        info.is_video_inspect = false
      end
    end
    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_MEMBER_ONLINE_INFO, {uid})
  end
end
function CorpsMemberSystem.on_notify_group_status_chg(uid, status)
  if CorpsMemberSystem.UpdateStatus(uid, status) then
    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_MEMBER_ONLINE_INFO, {uid})
  end
end
function CorpsMemberSystem.on_add_corps_active_achievement(member_info)
  local TableUtil = require("common.table_util")
  TableUtil.OverrideTable(DataMgr.corpsInfo.selfMember, member_info.member)
  EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_GET_MEMBERLIST, DataMgr.corpsInfo.corpsMemberList)
end
function CorpsMemberSystem.on_batch_get_group_and_online_rsp(_, res, cacheData)
  log(bWriteLog and "CorpsMemberSystem.on_batch_get_group_and_online_rsp")
  if res ~= NetErrorCode_NONE then
    return
  end
  local uids = {}
  for uid, status in pairs(cacheData) do
    if CorpsMemberSystem.UpdateStatus(uid, status) then
      table.insert(uids, uid)
    end
  end
  if 0 < #uids then
    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_MEMBER_ONLINE_INFO, uids)
  end
end
function CorpsMemberSystem.UpdateStatus(uid, status)
  local info = CorpsMemberSystem.MemberOnlineInfo[uid]
  if info then
    if info.is_video_inspect then
      log(bWriteLog and "CorpsMemberSystem.UpdateStatus info.is_video_inspect = " .. tostring(info.is_video_inspect))
      info.is_video_inspect = status.is_video_inspect or false
    end
    CorpsMemberSystem.SetStatusExtra(status)
    for i, v in pairs(status) do
      info[i] = v
    end
  end
  return info
end
function CorpsMemberSystem.SetStatusExtra(status)
  local TimeUtil = require("client.common.time_util")
  if tostring(status.id) == tostring(DataMgr.roleData.uid) then
    status.online = 1
  end
  local PlayerStatusUtil = require("client.slua.logic.player_status.PlayerStatusUtil")
  PlayerStatusUtil.HandleCommonStatusInfo(status)
  local gameBeginTime = status.gameBeginTime or 0
  status.timeSinceGameBeginStr = TimeUtil.GetOpenedTimeStr(TimeUtil.GetServerTimeInSec() - gameBeginTime)
end
function CorpsMemberSystem.GetMemberProfile(memberIdList)
  local CorpsMgr = require("client.slua.logic.corps.corps_mgr")
  log(bWriteLog and "CorpsMemberSystem.GetMemberProfile:" .. tostring(#memberIdList))
  local callback = function(profileList)
    local infoList = {}
    for _, profileInfo in ipairs(profileList) do
      local info = CorpsMgr.ConvertProfileToBaseInfo(profileInfo)
      infoList[tonumber(profileInfo.uid)] = info
      info.profile = profileInfo
    end
    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_MEMBERINFO)
  end
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetNormalProfiles(memberIdList, callback, Enum_PROFILE_REPORT_CFG.CORPS_GET_MEM)
end
function CorpsMemberSystem.GetCorpsMemberList()
  local CorpsMgr = require("client.slua.logic.corps.corps_mgr")
  log(bWriteLog and "CorpsMemberSystem.GetCorpsMemberList", "corps")
  if not CorpsMgr.IsInCorps() then
    log(bWriteLog and "CorpsMemberSystem.GetCorpsMemberList 1", "corps")
    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_GET_MEMBERLIST, {})
    return
  end
  if CorpsMemberSystem.isInit then
    log(bWriteLog and "CorpsMemberSystem.GetCorpsMemberList 2", "corps")
    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_GET_MEMBERLIST, DataMgr.corpsInfo.corpsMemberList, true)
  else
    log(bWriteLog and "CorpsMemberSystem.GetCorpsMemberList 3", "corps")
    if CorpsMgr.onCorpsDataRsp == nil then
      CorpsMgr.SendCorpsDataReq()
    end
  end
end
function CorpsMemberSystem.InitMembers(corps_members)
  log(bWriteLog and "CorpsMemberSystem.InitMembers")
  DataMgr.corpsInfo.corpsMemberList = {}
  DataMgr.corpsInfo.memberList = {}
  for uId, info in pairs(corps_members) do
    info.id = uId
    table.insert(DataMgr.corpsInfo.corpsMemberList, info)
    table.insert(DataMgr.corpsInfo.memberList, uId)
    if uId == tonumber(DataMgr.roleData.uid) then
      DataMgr.corpsInfo.selfMember = info
    end
  end
  CorpsMemberSystem.get_corps_member_online_info_req()
  CorpsMemberSystem.isInit = true
  CorpsMemberSystem.UpdateMemberPosition()
  DataMgr.corpsInfo.memberNum = #DataMgr.corpsInfo.corpsMemberList
  EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_GET_MEMBERLIST, DataMgr.corpsInfo.corpsMemberList)
end
function CorpsMemberSystem.UpdateMemberPosition()
  DataMgr.corpsInfo.secCommanderList = {}
  DataMgr.corpsInfo.eliteList = {}
  DataMgr.corpsInfo.memberList = {}
  for _, memberInfo in ipairs(DataMgr.corpsInfo.corpsMemberList) do
    if memberInfo.position == MemberPosition.Commander then
      DataMgr.corpsInfo.commanderId = memberInfo.id
    elseif memberInfo.position == MemberPosition.SecCommander then
      DataMgr.corpsInfo.secCommanderList[memberInfo.id] = true
    elseif memberInfo.position == MemberPosition.Elite then
      DataMgr.corpsInfo.eliteList[memberInfo.id] = true
    elseif memberInfo.position == MemberPosition.Member then
      DataMgr.corpsInfo.memberList[memberInfo.id] = true
    end
  end
end
function CorpsMemberSystem.FindMemberByID(id)
  id = tonumber(id)
  for i, v in ipairs(DataMgr.corpsInfo.corpsMemberList) do
    if v.id == id then
      return v
    end
  end
  return nil
end
function CorpsMemberSystem.GetPositionNameByUid(id)
  local info = CorpsMemberSystem.FindMemberByID(id)
  local positionId = 410008
  if info then
    if info.position == 1 then
      positionId = 410005
    elseif info.position == 2 then
      positionId = 410006
    elseif info.position == 3 then
      positionId = 410007
    end
  end
  return LocUtil.GetLocalizeResStr(positionId)
end
function CorpsMemberSystem.ResetData()
  log(bWriteLog and "CorpsMemberSystem.ResetData")
  CorpsMemberSystem.isInit = false
  DataMgr.corpsInfo.corpsMemberList = {}
  CorpsMemberSystem.lastGetCorpsMemberOnlineInfoReq = 0
  CorpsMemberSystem.GetCorpsMemberOnlineInfoRspTime = 0
  CorpsMemberSystem.MemberOnlineInfo = {}
end
function CorpsMemberSystem.SendApplyJoinCorps(corps_id)
  log(bWriteLog and "CorpsMemberSystem.SendApplyJoinCorps corps_id " .. tostring(corps_id))
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  local CorpsHander = require("client.network.Protocol.CorpsHandler")
  CorpsHander.send_apply_join_corps_req(corps_id)
end
function CorpsMemberSystem.apply_join_corps_rsp(res, corps_id, can_join_time, auto_join)
  local CorpsMgr = require("client.slua.logic.corps.corps_mgr")
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  log(bWriteLog and "CorpsMemberSystem.apply_join_corps_rsp res " .. res)
  log(bWriteLog and string.format("CorpsMemberSystem.apply_join_corps_rsp(res[%s], corps_id[%s], can_join_time[%s], auto_join[%s])", tostring(res), tostring(corps_id), tostring(can_join_time), tostring(auto_join)))
  if res == NetErrorCode_NONE then
    if auto_join then
      CorpsMgr.InitID(corps_id)
      local logic_corps_tab_mgr = require("client.slua.logic.corps.logic_corps_tab_mgr")
      logic_corps_tab_mgr.OpenCorpsUIWithForceReq()
      local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
      logic_chat_main.CloseChatWin()
      ShowNotice(410031)
    else
      ShowNotice(410032)
      local CorpsSuggestionSystem = require("client.slua.logic.corps.logic_corps_suggestion")
      CorpsSuggestionSystem.UpdateTempApplyIDList(corps_id)
    end
    local _RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
    _RoleInfoMainSystem.ChacheOwnHasApplyInfo(RoleInfoSystem.PersonalBasicInfo.role_id, true)
    local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
    LobbySocialSystem.CacheOwnHasApply(corps_id)
    EventSystem:postEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_LOBBY_SOCIAL_CORPS_SUMMARY)
    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_JOINED, auto_join)
  else
    local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
    RoleInfoMainSystem.ChacheOwnHasApplyInfo(RoleInfoSystem.PersonalBasicInfo.role_id, false)
    if res == 411039 then
      local msg = CorpsMemberSystem.GetRemainTimeStr(res, can_join_time)
      ShowNotice(msg)
    elseif res == 411038 then
      CorpsMgr.ShowCorpsLimitError()
    else
      if res == 411023 then
        local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
        LobbySocialSystem.CacheOwnHasApply(corps_id)
      end
      ShowNotice(res)
    end
  end
end
function CorpsMemberSystem.GetRemainTimeStr(errorCode, endTime)
  local TimeUtil = require("client.common.time_util")
  local remainTime = endTime - TimeUtil.GetServerTimeInSec()
  return LocUtil.LocalizeResFormat(tostring(errorCode), TimeUtil.FormatCountDownTime_DH_or_HM(remainTime, true))
end
function CorpsMemberSystem.IsSelfCommander()
  return CorpsMemberSystem.IsCommander(tonumber(DataMgr.roleData.uid))
end
function CorpsMemberSystem.IsCommander(uid)
  return uid == DataMgr.corpsInfo.commanderId
end
function CorpsMemberSystem.IsSelfCommanderOrSecCommanderOrAgentLeader()
  return CorpsMemberSystem.IsCommanderOrSecCommanderOrAgentLeader(tonumber(DataMgr.roleData.uid))
end
function CorpsMemberSystem.IsCommanderOrSecCommanderOrAgentLeader(uid)
  local isAgentLeader = uid == (DataMgr.corpsInfo.agent_leader and DataMgr.corpsInfo.agent_leader.uid or 0)
  return uid == DataMgr.corpsInfo.commanderId or DataMgr.corpsInfo.secCommanderList[uid] ~= nil or isAgentLeader
end
function CorpsMemberSystem.SendExitCorpsReq()
  if CorpsMemberSystem.IsSelfCommander() then
    if #DataMgr.corpsInfo.corpsMemberList > 1 then
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.Show(1, LocUtil.GetLocalizeResStr("101001"), LocUtil.GetLocalizeResStr("410012"))
    else
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.Show(2, LocUtil.GetLocalizeResStr("101001"), LocUtil.GetLocalizeResStr("410013"), CorpsMemberSystem.DoSendExitCorpsReq)
    end
  else
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, LocUtil.GetLocalizeResStr("101001"), LocUtil.GetLocalizeResStr("410014"), CorpsMemberSystem.DoSendExitCorpsReq)
  end
end
function CorpsMemberSystem.DoSendExitCorpsReq()
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  log(bWriteLog and "CorpsMemberSystem.DoSendExitCorpsReq")
  local CorpsHander = require("client.network.Protocol.CorpsHandler")
  CorpsHander.send_exit_corps_req()
end
function CorpsMemberSystem.exit_corps_rsp(msg)
  local CorpsMgr = require("client.slua.logic.corps.corps_mgr")
  log(bWriteLog and "CorpsMemberSystem.exit_corps_rsp msg " .. msg)
  if msg == NetErrorCode_NONE then
    CorpsMgr.InitID(0)
    CorpsMemberSystem.ResetData()
    EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_CHAT_CORPS_QUIT)
    local CorpsSuggestionSystem = require("client.slua.logic.corps.logic_corps_suggestion")
    CorpsSuggestionSystem.InitInvitedCorpsArray({})
    local logic_corps_tab_mgr = require("client.slua.logic.corps.logic_corps_tab_mgr")
    logic_corps_tab_mgr.OpenCorpsUIWithForceReq()
    local logic_corps_fight = require("client.slua.logic.corps.logic_corps_fight")
    logic_corps_fight.SetCorpfightInfo(nil)
    logic_corps_fight.UpdateRedDotPoint()
    ShowNotice(410039)
  else
    ShowNotice(msg)
  end
end
function CorpsMemberSystem.SendKickMember(memberUID)
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  local CorpsHander = require("client.network.Protocol.CorpsHandler")
  CorpsHander.send_corps_kick_member(memberUID)
end
function CorpsMemberSystem.corps_kick_member_rsp(msg, corps)
  local CorpsMgr = require("client.slua.logic.corps.corps_mgr")
  if msg == NetErrorCode_NONE then
    CorpsMgr.InitData(corps)
  elseif msg ~= nil then
    ShowNotice(msg)
  end
end
function CorpsMemberSystem.SendInviteReq(fri_uid, approval_status)
  log(bWriteLog and "CorpsMemberSystem.SendInviteReq fri_uid " .. fri_uid)
  log(bWriteLog and "CorpsMemberSystem.SendInviteReq approval_status " .. approval_status)
  log(bWriteLog and "CorpsMemberSystem.SendInviteReq DataMgr.corpsInfo.id " .. DataMgr.corpsInfo.id)
  if approval_status ~= 0 and not CorpsMemberSystem.IsSelfCommanderOrSecCommanderOrAgentLeader() then
    approval_status = 0
  end
  local CorpsHander = require("client.network.Protocol.CorpsHandler")
  CorpsHander.send_corps_invite_req(DataMgr.corpsInfo.id, tonumber(fri_uid), approval_status)
end
function CorpsMemberSystem.corps_invite_rsp(res, corps_id, fri_uid, approval_status, left_cnt)
  log(bWriteLog and string.format("CorpsMemberSystem.corps_invite_rsp %s, %s, %s %s", tostring(res), tostring(corps_id), tostring(fri_uid), tostring(left_cnt)))
  if res == NetErrorCode_NONE then
    if approval_status == 0 then
      CorpsMemberSystem.invitedRemainNum = left_cnt or 0
      ShowNotice(410011)
    elseif approval_status == 1 then
      ShowNotice(410011)
    elseif approval_status == 2 then
      ShowNotice(410036)
    end
    local CorpsApplyListUILogic = require("client.slua.logic.corps.logic_corps_apply_list")
    CorpsApplyListUILogic.RemoveFromApplyList(fri_uid)
    local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
    RoleInfoMainSystem.SetInviteCorpsResult()
    local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
    LobbySocialSystem.CacheInviteOther(fri_uid)
    EventSystem:postEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_LOBBY_SOCIAL_CORPS_SUMMARY)
    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_RECRUIT_RES, fri_uid)
  else
    ShowNotice(res)
  end
end
local SendGetDailyInvitedListDelegate
function CorpsMemberSystem.SendGetDailyInvitedListReq(del)
  SendGetDailyInvitedListDelegate = del
  local CorpsHander = require("client.network.Protocol.CorpsHandler")
  CorpsHander.send_corps_get_daily_invited_list_req()
end
function CorpsMemberSystem.corps_get_daily_invited_list_rsp(res, invited_list, left_cnt, applyList)
  CorpsMemberSystem.InvitedList = {}
  CorpsMemberSystem.applyList = {}
  if res == NetErrorCode_NONE then
    if invited_list then
      for i, v in ipairs(invited_list) do
        table.insert(CorpsMemberSystem.InvitedList, v)
      end
    end
    if applyList then
      for i, v in ipairs(applyList) do
        table.insert(CorpsMemberSystem.applyList, v)
      end
    end
    log(bWriteLog and "CorpsMemberSystem.corps_get_daily_invited_list_rsp left_cnt " .. tostring(left_cnt))
    CorpsMemberSystem.invitedRemainNum = left_cnt or 0
  elseif res ~= nil then
    ShowNotice(res)
  end
  if SendGetDailyInvitedListDelegate ~= nil then
    SendGetDailyInvitedListDelegate()
    SendGetDailyInvitedListDelegate = nil
  end
end
function CorpsMemberSystem.corps_accept_invite_req(corps_id, accept)
  corps_id = tonumber(corps_id)
  if not corps_id then
    log_error("CorpsMemberSystem.corps_accept_invite_req no corps_id")
    return
  end
  log(bWriteLog and "CorpsMemberSystem.corps_accept_invite_req corps_id " .. corps_id)
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  local CorpsHander = require("client.network.Protocol.CorpsHandler")
  CorpsHander.send_corps_accept_invite_req(corps_id, accept)
end
function CorpsMemberSystem.corps_accept_invite_rsp(res, corps_id, accept, open_join_time)
  if res == nil then
    return
  end
  log(bWriteLog and "CorpsMemberSystem.corps_accept_invite_rsp res " .. tostring(res))
  log(bWriteLog and "CorpsMemberSystem.corps_accept_invite_rsp corps_id " .. tostring(corps_id))
  log(bWriteLog and "CorpsMemberSystem.corps_accept_invite_rsp accept " .. tostring(accept))
  corps_id = corps_id or 0
  if res == NetErrorCode_NONE then
    if accept == CorpsMemberSystem.accept_yes then
      ShowNotice(410031)
      EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_JOINED)
      local logic_corps_tab_mgr = require("client.slua.logic.corps.logic_corps_tab_mgr")
      logic_corps_tab_mgr.OpenCorpsUIWithForceReq()
    elseif accept == CorpsMemberSystem.accept_no then
      ShowNotice(410036)
      local CorpsSuggestionSystem = require("client.slua.logic.corps.logic_corps_suggestion")
      CorpsSuggestionSystem.RemoveInvitedCorpsByID(corps_id)
      EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_NO_JOIN, {
        res = res,
        corps_id = corps_id,
              })
    end
  elseif res == 411039 then
    local msg = CorpsMemberSystem.GetRemainTimeStr(res, open_join_time or 0)
    ShowNotice(msg)
  else
    ShowNotice(res)
    local CorpsSuggestionSystem = require("client.slua.logic.corps.logic_corps_suggestion")
    CorpsSuggestionSystem.RemoveInvitedCorpsByID(corps_id)
    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_NO_JOIN, {
      res = res,
      corps_id = corps_id,
          })
  end
end
function CorpsMemberSystem.SendAppoint(target_uid, class_type)
  log(bWriteLog and "CorpsMemberSystem.SendAppoint class_type " .. class_type)
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  local CorpsHander = require("client.network.Protocol.CorpsHandler")
  CorpsHander.send_corps_appoint(target_uid, class_type)
end
function CorpsMemberSystem.corps_appoint_rsp(res, target_uid, class_type)
  if res == nil then
    return
  end
  log(bWriteLog and "CorpsMemberSystem.corps_appoint_rsp res " .. res)
  if res == NetErrorCode_NONE then
    CorpsMemberSystem.SetMemberAppoint(target_uid, class_type)
    ShowNotice(410001)
  else
    ShowNotice(res)
  end
end
function CorpsMemberSystem.SetMemberAppoint(target_uid, class_type)
  log(bWriteLog and "CorpsMemberSystem.SetMemberAppoint class_type " .. tostring(class_type))
  local oldEnable = CorpsMemberSystem.IsSelfCommanderOrSecCommanderOrAgentLeader()
  if class_type == MemberPosition.Commander then
    local commander = CorpsMemberSystem.FindMemberByID(DataMgr.corpsInfo.commanderId)
    if commander ~= nil then
      commander.position = MemberPosition.Member
    else
      log_error("can't find commander")
    end
  end
  local member = CorpsMemberSystem.FindMemberByID(target_uid)
  if member == nil then
    return
  end
  member.position = class_type
  CorpsMemberSystem.UpdateMemberPosition()
  local newEnable = CorpsMemberSystem.IsSelfCommanderOrSecCommanderOrAgentLeader()
  if newEnable ~= oldEnable then
    local CorpsApplyListUILogic = require("client.slua.logic.corps.logic_corps_apply_list")
    if not newEnable then
      CorpsApplyListUILogic.InitApplyList(nil)
    else
      CorpsApplyListUILogic.SendGetCorpsApplyListReq(false)
    end
  end
  if member.position > 2 then
    local CorpsApplyListUILogic = require("client.slua.logic.corps.logic_corps_apply_list")
    CorpsApplyListUILogic.CloseUI()
  end
  EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_APPOINT, target_uid)
end
function CorpsMemberSystem.notify_corps_target_appoint_info(corps_id, op_uid, class_type)
  log(bWriteLog and "CorpsMemberSystem.notify_corps_target_appoint_info")
  CorpsMemberSystem.SetMemberAppoint(tonumber(DataMgr.roleData.uid), class_type)
end
function CorpsMemberSystem.get_corps_member_online_info_req()
  log(bWriteLog and "CorpsMemberSystem.get_corps_member_online_info_req last request time " .. tostring(CorpsMemberSystem.GetCorpsMemberOnlineInfoRspTime))
  local TimeUtil = require("client.common.time_util")
  if TimeUtil.GetServerTimeInSec() - CorpsMemberSystem.lastGetCorpsMemberOnlineInfoReq >= CorpsMemberSystem.member_online_info_interval then
    local CorpsHandler = require("client.network.Protocol.CorpsHandler")
    CorpsHandler.send_get_corps_member_online_info_req(CorpsMemberSystem.GetCorpsMemberOnlineInfoRspTime)
    CorpsMemberSystem.lastGetCorpsMemberOnlineInfoReq = TimeUtil.GetServerTimeInSec()
    return true
  end
  return false
end
function CorpsMemberSystem.on_get_corps_member_online_info_rsp(ret, lastTime, cache)
  log(bWriteLog and "CorpsMemberSystem.on_get_corps_member_online_info_rsp ret " .. tostring(ret) .. ",lastTime:" .. tostring(lastTime))
  if ret ~= 0 then
    if ret == 411008 then
      CorpsMemberSystem.MemberOnlineInfo = {}
    end
    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_MEMBER_NO_UPDATE)
    return
  end
  CorpsMemberSystem.lastGetCorpsMemberOnlineInfoReq = lastTime
  CorpsMemberSystem.GetCorpsMemberOnlineInfoRspTime = lastTime
  CorpsMemberSystem.OnStatusChanged(cache)
end
return CorpsMemberSystem