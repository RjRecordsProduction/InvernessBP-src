local logic_chat_stranger = {
  strangerChatList = {}
}
local strangerList = {}
function logic_chat_stranger.GetStrangerList()
  return strangerList
end
function logic_chat_stranger.OpenChatWinByStranger(uid)
  local friendSystem = require("client.slua.logic.friend.logic_new_friend")
  if friendSystem.IsMyFriend(uid) then
    local logic_chat_channel_friend = require("client.slua.logic.lobby_chat.logic_chat_channel_friend")
    logic_chat_channel_friend.CurrentGid = tostring(uid)
  else
    logic_chat_stranger.AddStranger(uid, true)
  end
end
function logic_chat_stranger.AddStranger(uid, select)
  log(bWriteLog and "god test AddStranger " .. tostring(uid))
  if not strangerList[tonumber(uid)] then
    strangerList[tonumber(uid)] = {uid = uid}
    local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
    local _myselfOnIsland = MatchModeMgrSystem.IsSocialIslandMode()
    local _tag = _myselfOnIsland and Enum_PROFILE_REPORT_CFG.SOCIAL_ISLAND_PERSONAL_CHAT or Enum_PROFILE_REPORT_CFG.CHAT_REQ
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles({uid}, function(profileList)
      logic_chat_stranger.SetStrangerInfo(profileList, uid, select)
    end, _tag)
  elseif select then
    local logic_chat_channel_friend = require("client.slua.logic.lobby_chat.logic_chat_channel_friend")
    logic_chat_channel_friend.CurrentGid = tostring(uid)
  end
end
function logic_chat_stranger.SetStrangerInfo(profileList, uid, select)
  local modeSystem = require("client.slua.logic.match.logic_mode_mgr")
  if modeSystem.IsSocialIslandMode() then
    logic_chat_stranger.SetStrangerProfile(profileList)
    if select then
      local logic_chat_channel_friend = require("client.slua.logic.lobby_chat.logic_chat_channel_friend")
      logic_chat_channel_friend.CurrentGid = tostring(uid)
      EventSystem:postEvent(EVENTTYPE_CHAT, EVENTID_CHAT_ADD_STRANGER)
    end
  end
end
function logic_chat_stranger.IsStranger(uid)
  if strangerList[tonumber(uid)] then
    return true
  else
    return false
  end
end
function logic_chat_stranger.SetStrangerProfile(profileList)
  local newStranger
  for _, profile in pairs(profileList) do
    strangerList[tonumber(profile.uid)] = profile
    newStranger = profile
    break
  end
  local logic_chat_channel_friend = require("client.slua.logic.lobby_chat.logic_chat_channel_friend")
  logic_chat_channel_friend.SetStrangerToFriend(newStranger)
  log(bWriteLog and "god test SetStrangerProfile")
end
function logic_chat_stranger.ReqStrangerStatus(IDList)
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  log_tree("god test ReqStrangerStatus", IDList)
  if next(IDList) then
    PlayerStatusMgr:GetOrReqStatusData(ENUM_BATCH_GET_GROUP_AND_ONLINE.ChatStranger, IDList, logic_chat_stranger.on_stranger_status_rs)
  end
end
function logic_chat_stranger.AddNewChat(chatMsg)
  local refMsg = logic_chat_stranger.CheckAndCreateChatMsg(chatMsg.uid)
  local logic_chat_channel_friend = require("client.slua.logic.lobby_chat.logic_chat_channel_friend")
  logic_chat_channel_friend.SetMsgTime(refMsg, chatMsg)
  logic_chat_channel_friend.SetMsgNewMessageCount(refMsg)
  logic_chat_channel_friend.AddNewMsgItem(refMsg, chatMsg)
  if not logic_chat_stranger.IsStranger(chatMsg.uid) then
    logic_chat_stranger.AddStranger(chatMsg.uid)
  end
  return refMsg
end
function logic_chat_stranger.CheckAndCreateChatMsg(uid)
  uid = tostring(uid)
  local super_list = require("common.super_list")
  local refMsg = logic_chat_stranger.strangerChatList[uid]
  if nil == refMsg then
    refMsg = {}
    refMsg.gid = uid
    refMsg.newMessageCount = 0
    refMsg.lastMsgSendTime = 0
    refMsg.recordLastMsgSendTime = 0
    refMsg.send_time = 0
    refMsg.messageList = super_list.Create()
    logic_chat_stranger.strangerChatList[uid] = refMsg
  end
  return refMsg
end
function logic_chat_stranger.RefreshStrangerUnreadList(uid, message_count)
  if logic_chat_stranger.strangerChatList[uid] then
    logic_chat_stranger.strangerChatList[uid].newMessageCount = message_count
  end
end
function logic_chat_stranger.GetTotalUnread()
  local unreadCount = 0
  for k, v in pairs(logic_chat_stranger.strangerChatList) do
    unreadCount = unreadCount + v.newMessageCount
  end
  return unreadCount
end
function logic_chat_stranger.on_stranger_status_rsp(cacheData)
  local logic_chat_channel_friend = require("client.slua.logic.lobby_chat.logic_chat_channel_friend")
  log_tree("god test chat_stranger ", cacheData)
  if cacheData ~= nil then
    for k, v in pairs(cacheData) do
      if strangerList[k] then
        strangerList[k].teamState = v.teamStateNew or 0
        strangerList[k].teamId = v.teamId
        strangerList[k].currentTeamAmount = v.currentTeamAmount
        strangerList[k].maxTeamAmount = v.maxTeamAmount
        strangerList[k].timeSinceGameBegin = v.timeSinceGameBegin
        strangerList[k].online = v.online
        strangerList[k].socialland_type = v.socialland_type
        strangerList[k].tplan_type = v.tplan_type
        strangerList[k].cwow_type = v.cwow_type
        logic_chat_channel_friend.UpdateStrangerStauts(k)
      end
    end
  end
end
function logic_chat_stranger.DeleteStranger(uid)
  if strangerList[tonumber(uid)] then
    strangerList[tonumber(uid)] = nil
  end
end
function logic_chat_stranger.ClearData()
  logic_chat_stranger.strangerChatList = {}
  strangerList = {}
end
return logic_chat_stranger