local LogicChatRoomMember = {}
function LogicChatRoomMember:DefineAndResetData()
  self.open_voice_apply = nil
end
function LogicChatRoomMember:IsOnMic(uid)
  log(bWriteLog and "LogicChatRoomMember:IsOnMic uid:" .. tostring(uid))
  local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
  local myChannel = logic_chat_channel_chat_room.GetMyChannel()
  if not myChannel then
    log(bWriteLog and "LogicChatRoomMember:IsOnMic I am not in room")
    return false
  end
  local member = myChannel.members[uid]
  if not member then
    log(bWriteLog and "LogicChatRoomMember:IsOnMic uid not in room")
    return false
  end
  log_tree(bWriteLog and "LogicChatRoomMember:IsOnMic member:", member)
  local LogicChatRoomMacro = require("client.slua.logic.lobby_chat.chatroom.LogicChatRoomMacro")
  return member.chat_status == LogicChatRoomMacro.ChannelStatus.OnMic
end
function LogicChatRoomMember:IsApplyingMic(uid)
  log(bWriteLog and "LogicChatRoomMember:IsApplyingMic uid:" .. tostring(uid))
  if not self.open_voice_apply then
    log(bWriteLog and "LogicChatRoomMember:IsApplyingMic no open_voice_apply")
    return false
  end
  if self.open_voice_apply[uid] then
    return true
  else
    return false
  end
end
function LogicChatRoomMember:GetAudienceList()
  local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
  local myChannel = logic_chat_channel_chat_room.GetMyChannel()
  if not myChannel then
    log(bWriteLog and "LogicChatRoomMember:GetAudienceList I am not in room")
    return {}
  end
  local audienceList = {}
  local members = myChannel.members
  for uid, info in pairs(members) do
    if type(info) == "table" then
      info.      table.insert(audienceList, info)
    end
  end
  local sortFunc = function(a, b)
    local isRoomOwnerA = logic_chat_channel_chat_room.IsRoomOwner(a.uid)
    local isRoomOwnerB = logic_chat_channel_chat_room.IsRoomOwner(b.uid)
    if isRoomOwnerA ~= isRoomOwnerB then
      return isRoomOwnerA
    end
    local isMeA = tonumber(a.uid) == tonumber(DataMgr.roleData.uid)
    local isMeB = tonumber(b.uid) == tonumber(DataMgr.roleData.uid)
    if isMeA ~= isMeB then
      return isMeA
    end
    local isApplyingA = self:IsApplyingMic(a.uid)
    local isApplyingB = self:IsApplyingMic(b.uid)
    if isApplyingA ~= isApplyingB then
      return isApplyingA
    elseif isApplyingA then
      local status_ts_a = a.status_ts or 0
      local status_ts_b = b.status_ts or 0
      return status_ts_a < status_ts_b
    end
    local onMicA = self:IsOnMic(a.uid)
    local onMicB = self:IsOnMic(b.uid)
    if onMicA ~= onMicB then
      return onMicA
    end
    local status_ts_a = a.status_ts or 0
    local status_ts_b = b.status_ts or 0
    return status_ts_a < status_ts_b
  end
  table.sort(audienceList, sortFunc)
  return audienceList
end
function LogicChatRoomMember:GetOnMicMembers()
  local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
  local myChannel = logic_chat_channel_chat_room.GetMyChannel()
  if not myChannel then
    log(bWriteLog and "LogicChatRoomMember:GetOnMicMembers I am not in room")
    return {}
  end
  local LogicChatRoomMacro = require("client.slua.logic.lobby_chat.chatroom.LogicChatRoomMacro")
  local onMicList = {}
  local members = myChannel.members
  for uid, info in pairs(members) do
    if type(info) == "table" and info.chat_status == LogicChatRoomMacro.ChannelStatus.OnMic then
      info.      table.insert(onMicList, info)
    end
  end
  table.sort(onMicList, function(a, b)
    local isRoomOwnerA = logic_chat_channel_chat_room.IsRoomOwner(a.uid)
    local isRoomOwnerB = logic_chat_channel_chat_room.IsRoomOwner(b.uid)
    if isRoomOwnerA ~= isRoomOwnerB then
      return isRoomOwnerA
    end
    local status_ts_a = a.status_ts or 0
    local status_ts_b = b.status_ts or 0
    return status_ts_a < status_ts_b
  end)
  return onMicList
end
function LogicChatRoomMember:GetMemberState(uid)
  log(bWriteLog and "LogicChatRoomMember:GetMemberState uid:" .. tostring(uid))
  local LogicChatRoomMacro = require("client.slua.logic.lobby_chat.chatroom.LogicChatRoomMacro")
  local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
  if logic_chat_channel_chat_room.IsMyRoomSelfCreate() then
    if self:IsOnMic(uid) then
      return LogicChatRoomMacro.ChannelStatus.OnMic
    elseif self:IsApplyingMic(uid) then
      return LogicChatRoomMacro.ChannelStatus.ApplyingMic
    else
      return LogicChatRoomMacro.ChannelStatus.Watch
    end
  elseif self:IsOnMic(uid) then
    return LogicChatRoomMacro.ChannelStatus.OnMic
  else
    return LogicChatRoomMacro.ChannelStatus.Watch
  end
end
function LogicChatRoomMember:UpdateOpenVoiceApply(applyData)
  log_tree(bWriteLog and "LogicChatRoomMember:UpdateOpenVoiceApply applyData:", applyData)
  local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
  if not logic_chat_channel_chat_room.IsMyRoomSelfCreate() then
    log(bWriteLog and "LogicChatRoomMember:UpdateOpenVoiceApply no master")
    return
  end
  self.open_voice_apply = applyData
end
function LogicChatRoomMember:InsertOpenVoiceApply(apply_uid, apply_ts)
  log(bWriteLog and "LogicChatRoomMember:InsertOpenVoiceApply")
  local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
  if not logic_chat_channel_chat_room.IsMyRoomSelfCreate() then
    log(bWriteLog and "LogicChatRoomMember:InsertOpenVoiceApply no master")
    return
  end
  if not self.open_voice_apply then
    self.open_voice_apply = {}
  end
  self.open_voice_apply[apply_uid] = apply_ts
  EventSystem:postEvent(EVENTTYPE_CHAT_ROOM, EVENTID_CHAT_ROOM_CHANGE_MIC_STATUS, apply_uid)
end
function LogicChatRoomMember:RemoveOpenVoiceApply(apply_uid, post_event)
  log(bWriteLog and "LogicChatRoomMember:RemoveOpenVoiceApply")
  local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
  if not logic_chat_channel_chat_room.IsMyRoomSelfCreate() then
    log(bWriteLog and "LogicChatRoomMember:RemoveOpenVoiceApply no master")
    return
  end
  if not self.open_voice_apply or not self.open_voice_apply[apply_uid] then
    log(bWriteLog and "LogicChatRoomMember:RemoveOpenVoiceApply no data")
    return
  end
  self.open_voice_apply[apply_uid] = nil
  if post_event then
    EventSystem:postEvent(EVENTTYPE_CHAT_ROOM, EVENTID_CHAT_ROOM_CHANGE_MIC_STATUS, apply_uid)
  end
end
function LogicChatRoomMember:IsMicSeatFull()
  local onMicList = self:GetOnMicMembers()
  local LogicChatRoomMacro = require("client.slua.logic.lobby_chat.chatroom.LogicChatRoomMacro")
  return #onMicList >= LogicChatRoomMacro.MaxOnMicMembers
end
function LogicChatRoomMember:GetRecentMember()
  local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
  local myChannel = logic_chat_channel_chat_room.GetMyChannel()
  if not myChannel then
    log(bWriteLog and "LogicChatRoomMember:GetRecentMember I am not in room")
    return 0
  end
  local memberList = {}
  local members = myChannel.members
  for uid, info in pairs(members) do
    if type(info) == "table" then
      info.      table.insert(memberList, info)
    end
  end
  table.sort(memberList, function(a, b)
    local status_ts_a = a.status_ts or 0
    local status_ts_b = b.status_ts or 0
    return status_ts_a < status_ts_b
  end)
  return memberList[#memberList].uid
end
function LogicChatRoomMember:GetSendGiftList()
  local onMicList = self:GetOnMicMembers()
  if #onMicList == 0 then
    log(bWriteLog and "LogicChatRoomMember:GetSendGiftList no onMicList")
    return {}
  end
  local giftList = {}
  for _, data in ipairs(onMicList) do
    if tonumber(DataMgr.roleData.uid) ~= tonumber(data.uid) then
      table.insert(giftList, data)
    end
  end
  return giftList
end
function LogicChatRoomMember:IsFreeVoiceMode()
  local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
  local myChannel = logic_chat_channel_chat_room.GetMyChannel()
  if not myChannel then
    log(bWriteLog and "LogicChatRoomMember:IsFreeVoiceMode I am not in room")
    return false
  end
  local LogicChatRoomMacro = require("client.slua.logic.lobby_chat.chatroom.LogicChatRoomMacro")
  return myChannel.channel_info.voice_mode == LogicChatRoomMacro.VoiceMode.Free
end
function LogicChatRoomMember:IsRoomOwnerAndOnMic()
  local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
  if not logic_chat_channel_chat_room.IsMyRoomSelfCreate() then
    log(bWriteLog and "LogicChatRoomMember:IsRoomOwnerAndOnMic not owner")
    return false
  end
  if not self:IsOnMic(tonumber(DataMgr.roleData.uid)) then
    log(bWriteLog and "LogicChatRoomMember:IsRoomOwnerAndOnMic off mic")
    return false
  end
  log(bWriteLog and "LogicChatRoomMember:IsRoomOwnerAndOnMic owner, on mic")
  return true
end
function LogicChatRoomMember:CleanData()
  self.open_voice_apply = nil
end
function LogicChatRoomMember:send_channel_kick_out_req(kick_uid)
  local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
  if not logic_chat_channel_chat_room.IsMyRoomSelfCreate() then
    log(bWriteLog and "LogicChatRoomMember:send_channel_kick_out_req not master")
    return
  end
  local channel_id = tonumber(logic_chat_channel_chat_room.GetMyChatRoomId())
  local ChatRoomHandler = require("client.network.Protocol.ChatRoomHandler")
  ChatRoomHandler.send_channel_kick_out_req(channel_id, kick_uid)
end
function LogicChatRoomMember:on_channel_kick_out_rsp(channel_id, kick_uid)
  local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
  if not logic_chat_channel_chat_room.IsCurrentRoom(channel_id) then
    return
  end
  local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
  logic_chat_channel_chat_room.MemberExit(kick_uid)
  ShowNotice(68034)
end
function LogicChatRoomMember:send_channel_force_close_voice_req(close_uid)
  local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
  if not logic_chat_channel_chat_room.IsMyRoomSelfCreate() then
    log(bWriteLog and "LogicChatRoomMember:send_channel_force_close_voice_req not master")
    return
  end
  local channel_id = tonumber(logic_chat_channel_chat_room.GetMyChatRoomId())
  local ChatRoomHandler = require("client.network.Protocol.ChatRoomHandler")
  ChatRoomHandler.send_channel_force_close_voice_req(channel_id, close_uid)
end
function LogicChatRoomMember:on_channel_force_close_voice_rsp(channel_id, close_uid)
  local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
  if not logic_chat_channel_chat_room.IsCurrentRoom(channel_id) then
    return
  end
  local LogicChatRoomMacro = require("client.slua.logic.lobby_chat.chatroom.LogicChatRoomMacro")
  logic_chat_channel_chat_room.UpdateMemberStatus(close_uid, LogicChatRoomMacro.ChannelStatus.Watch)
  ShowNotice(68041)
end
function LogicChatRoomMember:send_channel_invite_open_voice_req(invitee_uid)
  local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
  if not logic_chat_channel_chat_room.IsMyRoomSelfCreate() then
    log(bWriteLog and "LogicChatRoomMember:send_channel_invite_open_voice_req not master")
    return
  end
  if self:IsMicSeatFull() then
    log(bWriteLog and "LogicChatRoomMember:send_channel_invite_open_voice_req seat full")
    ShowNotice(15115)
    return
  end
  local channel_id = tonumber(logic_chat_channel_chat_room.GetMyChatRoomId())
  local ChatRoomHandler = require("client.network.Protocol.ChatRoomHandler")
  ChatRoomHandler.send_channel_invite_open_voice_req(channel_id, invitee_uid)
end
function LogicChatRoomMember:on_channel_invite_open_voice_rsp(channel_id, invitee_uid)
  local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
  if not logic_chat_channel_chat_room.IsCurrentRoom(channel_id) then
    return
  end
  ShowNotice(301265)
end
function LogicChatRoomMember:send_channel_invite_open_voice_reply_req(reply_op)
  local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
  local channel_id = tonumber(logic_chat_channel_chat_room.GetMyChatRoomId())
  local ChatRoomHandler = require("client.network.Protocol.ChatRoomHandler")
  ChatRoomHandler.send_channel_invite_open_voice_reply_req(channel_id, reply_op)
end
function LogicChatRoomMember:on_channel_invite_open_voice_reply_rsp(channel_id, reply_op)
  local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
  if not logic_chat_channel_chat_room.IsCurrentRoom(channel_id) then
    return
  end
  local LogicChatRoomMacro = require("client.slua.logic.lobby_chat.chatroom.LogicChatRoomMacro")
  if reply_op == LogicChatRoomMacro.ReplyOp.Agree then
    logic_chat_channel_chat_room.UpdateMemberStatus(tonumber(DataMgr.roleData.uid), LogicChatRoomMacro.ChannelStatus.OnMic)
    self:OpenRoomMicrophone()
  end
end
function LogicChatRoomMember:send_channel_apply_open_voice_req()
  if self:IsOnMic(tonumber(DataMgr.roleData.uid)) then
    log(bWriteLog and "LogicChatRoomMember:send_channel_apply_open_voice_req on mic")
    return
  end
  if self:IsMicSeatFull() then
    log(bWriteLog and "LogicChatRoomMember:send_channel_apply_open_voice_req seat full")
    ShowNotice(15115)
    return
  end
  local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
  local channel_id = tonumber(logic_chat_channel_chat_room.GetMyChatRoomId())
  local ChatRoomHandler = require("client.network.Protocol.ChatRoomHandler")
  ChatRoomHandler.send_channel_apply_open_voice_req(channel_id)
end
function LogicChatRoomMember:on_channel_apply_open_voice_rsp(channel_id)
  local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
  if not logic_chat_channel_chat_room.IsCurrentRoom(channel_id) then
    return
  end
  if not self:IsFreeVoiceMode() then
    ShowNotice(68044)
  end
end
function LogicChatRoomMember:send_channel_deal_open_voice_apply_req(apply_uid, reply_op)
  local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
  if not logic_chat_channel_chat_room.IsMyRoomSelfCreate() then
    log(bWriteLog and "LogicChatRoomMember:send_channel_deal_open_voice_apply_req not master")
    return
  end
  local channel_id = tonumber(logic_chat_channel_chat_room.GetMyChatRoomId())
  local ChatRoomHandler = require("client.network.Protocol.ChatRoomHandler")
  ChatRoomHandler.send_channel_deal_open_voice_apply_req(channel_id, apply_uid, reply_op)
end
function LogicChatRoomMember:on_channel_deal_open_voice_apply_rsp(err_code, channel_id, apply_uid, reply_op)
  if err_code ~= 0 then
    self:RemoveOpenVoiceApply(apply_uid, true)
    return
  end
  local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
  if not logic_chat_channel_chat_room.IsCurrentRoom(channel_id) then
    return
  end
  local LogicChatRoomMacro = require("client.slua.logic.lobby_chat.chatroom.LogicChatRoomMacro")
  if reply_op == LogicChatRoomMacro.ReplyOp.Agree then
    self:RemoveOpenVoiceApply(apply_uid, false)
    logic_chat_channel_chat_room.UpdateMemberStatus(apply_uid, LogicChatRoomMacro.ChannelStatus.OnMic)
  else
    self:RemoveOpenVoiceApply(apply_uid, true)
  end
end
function LogicChatRoomMember:send_channel_close_voice_req()
  local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
  if logic_chat_channel_chat_room.IsMyRoomSelfCreate() then
    log(bWriteLog and "LogicChatRoomMember:send_channel_close_voice_req master")
    ShowNotice(68107)
    return
  end
  local onMic = self:IsOnMic(tonumber(DataMgr.roleData.uid))
  if not onMic then
    log(bWriteLog and "LogicChatRoomMember:send_channel_close_voice_req not onMic")
    return
  end
  local channel_id = tonumber(logic_chat_channel_chat_room.GetMyChatRoomId())
  local ChatRoomHandler = require("client.network.Protocol.ChatRoomHandler")
  ChatRoomHandler.send_channel_close_voice_req(channel_id)
end
function LogicChatRoomMember:on_channel_close_voice_rsp(channel_id)
  local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
  if not logic_chat_channel_chat_room.IsCurrentRoom(channel_id) then
    return
  end
  local LogicChatRoomMacro = require("client.slua.logic.lobby_chat.chatroom.LogicChatRoomMacro")
  logic_chat_channel_chat_room.UpdateMemberStatus(tonumber(DataMgr.roleData.uid), LogicChatRoomMacro.ChannelStatus.Watch)
  local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
  logic_chat_voice:ChangeRoomMicrophoneState(false, logic_chat_channel_chat_room.GetVoiceRoomID())
  ShowNotice(68041)
end
function LogicChatRoomMember:send_channel_get_open_voice_apply_req()
  local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
  local channel_id = tonumber(logic_chat_channel_chat_room.GetMyChatRoomId())
  local ChatRoomHandler = require("client.network.Protocol.ChatRoomHandler")
  ChatRoomHandler.send_channel_get_open_voice_apply_req(channel_id)
end
function LogicChatRoomMember:on_channel_get_open_voice_apply_rsp(channel_id, apply_info)
  local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
  if not logic_chat_channel_chat_room.IsCurrentRoom(channel_id) then
    return
  end
  self:UpdateOpenVoiceApply(apply_info)
  EventSystem:postEvent(EVENTTYPE_CHAT_ROOM, EVENTID_CHAT_ROOM_GET_OPEN_VOICE_APPLY)
end
function LogicChatRoomMember:on_channel_inner_op_notify(channel_id, op, params)
  local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
  if not logic_chat_channel_chat_room.IsCurrentRoom(channel_id) then
    return
  end
  local LogicChatRoomMacro = require("client.slua.logic.lobby_chat.chatroom.LogicChatRoomMacro")
  if op == LogicChatRoomMacro.ChannelOp.channel_op_kick_out then
    self:op_kick_out()
  elseif op == LogicChatRoomMacro.ChannelOp.channel_op_force_close_voice then
    self:op_force_close_voice()
  elseif op == LogicChatRoomMacro.ChannelOp.channel_op_invite_open_voice then
    self:op_invite_open_voice(params)
  elseif op == LogicChatRoomMacro.ChannelOp.channel_op_apply_open_voice then
    self:op_apply_open_voice(params)
  elseif op == LogicChatRoomMacro.ChannelOp.channel_op_deal_open_voice_apply then
    self:op_deal_open_voice_apply(params)
  elseif op == LogicChatRoomMacro.ChannelOp.channel_op_reply_invite_open_voice then
    self:op_reply_invite_open_voice(params)
  elseif op == LogicChatRoomMacro.ChannelOp.channel_op_set_question then
    self:op_set_question(params)
  elseif op == LogicChatRoomMacro.ChannelOp.channel_op_set_bg then
    self:op_set_bg(params)
  end
end
function LogicChatRoomMember:op_kick_out()
  ShowNotice(68035)
end
function LogicChatRoomMember:op_force_close_voice()
  local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
  local LogicChatRoomMacro = require("client.slua.logic.lobby_chat.chatroom.LogicChatRoomMacro")
  logic_chat_channel_chat_room.UpdateMemberStatus(tonumber(DataMgr.roleData.uid), LogicChatRoomMacro.ChannelStatus.Watch)
  local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
  logic_chat_voice:ChangeRoomMicrophoneState(false, logic_chat_channel_chat_room.GetVoiceRoomID())
  ShowNotice(68042)
end
function LogicChatRoomMember:op_invite_open_voice(params)
  local LogicJoinMicrophone = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicJoinMicrophone)
  local LogicChatRoomMacro = require("client.slua.logic.lobby_chat.chatroom.LogicChatRoomMacro")
  LogicJoinMicrophone:PushOpenMic(LogicChatRoomMacro.OpenMicType.Invite, params.inviter_uid)
end
function LogicChatRoomMember:op_apply_open_voice(params)
  local LogicJoinMicrophone = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicJoinMicrophone)
  local LogicChatRoomMacro = require("client.slua.logic.lobby_chat.chatroom.LogicChatRoomMacro")
  LogicJoinMicrophone:PushOpenMic(LogicChatRoomMacro.OpenMicType.Apply, params.invitee_uid)
  self:InsertOpenVoiceApply(params.invitee_uid, params.apply_ts)
end
function LogicChatRoomMember:op_deal_open_voice_apply(params)
  local LogicChatRoomMacro = require("client.slua.logic.lobby_chat.chatroom.LogicChatRoomMacro")
  if params.reply_op == LogicChatRoomMacro.ReplyOp.Agree then
    local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
    logic_chat_channel_chat_room.UpdateMemberStatus(tonumber(DataMgr.roleData.uid), LogicChatRoomMacro.ChannelStatus.OnMic)
    self:OpenRoomMicrophone()
    if self:IsFreeVoiceMode() then
      ShowNotice(68047)
    end
  end
end
function LogicChatRoomMember:op_reply_invite_open_voice(params)
  local LogicChatRoomMacro = require("client.slua.logic.lobby_chat.chatroom.LogicChatRoomMacro")
  if params.reply_op == LogicChatRoomMacro.ReplyOp.Agree then
    local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
    logic_chat_channel_chat_room.UpdateMemberStatus(params.target_uid, LogicChatRoomMacro.ChannelStatus.OnMic)
  end
end
function LogicChatRoomMember:op_set_question(params)
  local LogicChatRoomTopic = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicChatRoomTopic)
  LogicChatRoomTopic:on_notify_channel_question_id_update(params.question_id)
end
function LogicChatRoomMember:op_set_bg(params)
  local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
  logic_chat_channel_chat_room.UpdateChatRoomBG(params.chat_background_id)
end
function LogicChatRoomMember:OpenRoomMicrophone()
  log(bWriteLog and "LogicChatRoomMember:OpenRoomMicrophone")
  local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
  local EUChatRestriction, status = logic_chat_voice:CheckEUChatRestriction()
  if EUChatRestriction then
    log(bWriteLog and "LogicChatRoomMember:OpenRoomMicrophone EUChatRestriction")
    ShowNotice(46880036)
    return
  end
  local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
  local isSpeakerOpen = logic_chat_voice:GetSelfRoomSpeakerState(logic_chat_channel_chat_room.GetVoiceRoomID())
  if not isSpeakerOpen then
    log(bWriteLog and "LogicChatRoomMember:OpenRoomMicrophone not isSpeakerOpen")
    ShowNotice(38760)
    return
  end
  local callback = function()
    log(bWriteLog and "LogicChatRoomMember:OpenRoomMicrophone callback")
    logic_chat_voice:ChangeRoomMicrophoneState(true, logic_chat_channel_chat_room.GetVoiceRoomID())
  end
  logic_chat_voice:RequestPrivacy(callback, 4074)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicChatRoomMember = class(CModuleBase, nil, LogicChatRoomMember)
return CLogicChatRoomMember