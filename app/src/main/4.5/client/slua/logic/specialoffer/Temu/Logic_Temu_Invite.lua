local Logic_Temu_Invite = {
  inviteList = nil,
  remindList = nil,
  groupInviteData = {
    inviteList = {},
    recommendList = {},
    lastSendTime = 0
  },
  lastFriendProfileReqTime = 0
}
local lastTimeSpan = 10
local GetModule = function()
  return ModuleManager.GetModule(ModuleManager.CommonModuleConfig.Logic_temu)
end
function Logic_Temu_Invite.ResetData()
  Logic_Temu_Invite.inviteList = nil
  Logic_Temu_Invite.remindList = nil
  Logic_Temu_Invite.groupInviteData.inviteList = {}
  Logic_Temu_Invite.groupInviteData.recommendList = {}
  Logic_Temu_Invite.groupInviteData.lastSendTime = 0
end
function Logic_Temu_Invite.Init()
  Logic_Temu_Invite.GetAlreadyInviteList()
end
function Logic_Temu_Invite.OnInviteNotify(uidList)
  for i, uid in pairs(uidList) do
    Logic_Temu_Invite.InviteListAdd(uid)
  end
end
function Logic_Temu_Invite.SendGetGroupInviteMap(stageId)
  log(bWriteLog and "[SY]Logic_Temu_Invite.SendGetGroupInviteMap." .. tostring(stageId))
  local Logic_Temu = GetModule()
  if not Logic_Temu then
    log(bWriteLog and "[SY]Logic_Temu_Invite.SendGetGroupInviteMap.No Module")
    return
  end
  if Logic_Temu:IsHaveTeam() then
    log(bWriteLog and "[SY]Logic_Temu_Invite.SendGetGroupInviteMap. isHaveTeam")
    return
  end
  stageId = stageId or Logic_Temu:GetCurStageID()
  local TEMUHandler = require("client.network.Protocol.TEMUHandler")
  TEMUHandler.send_get_temu_group_friend_invite_list_req(stageId)
end
function Logic_Temu_Invite.OnSendGetGroupInviteMap(inviteSeverData, stage_id)
  local time_util = require("client.common.time_util")
  local curTime = time_util.GetServerTimeInSec()
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local uidProfileList = {}
  local inviteList = {}
  for _, data in pairs(inviteSeverData) do
    local tempData = {
      uid = data.src_uid or data.leader_uid,
      group_id = data.group_id,
      leader_uid = data.leader_uid,
      stage = data.stage,
      total_num = data.total_num,
      invite_time = data.invite_time,
      is_corp = data.is_corp,
      auto_invite = data.auto_invite
    }
    table.insert(inviteList, tempData)
    local profile = logic_profile:GetLocalProfile(tempData.uid)
    if not profile then
      table.insert(uidProfileList, tempData.uid)
    end
  end
  table.sort(inviteList, function(a, b)
    return a.invite_time > b.invite_time
  end)
  if 0 < #uidProfileList then
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles(uidProfileList, Logic_Temu_Invite.UpdateHeadItem, Enum_PROFILE_REPORT_CFG.TEMU_TEAM)
  end
  Logic_Temu_Invite.groupInviteData.lastSendTime = curTime
  Logic_Temu_Invite.groupInviteData.inviteList[stage_id] = inviteList
  EventSystem:postEvent(EVENTTYPE_TEMU, EVENTID_TEMU_UPDATE_TEAM_INVITE_LIST)
end
function Logic_Temu_Invite.SendGetRecommendInviteMap(stageId)
  log(bWriteLog and "[SY]Logic_Temu_Invite.SendGetRecommendInviteMap." .. tostring(stageId))
  local Logic_Temu = GetModule()
  if not Logic_Temu then
    log(bWriteLog and "[SY]Logic_Temu_Invite.SendGetGroupInviteMap.No Module")
    return
  end
  if Logic_Temu:IsHaveTeam() then
    log(bWriteLog and "[SY]Logic_Temu_Invite.SendGetGroupInviteMap. isHaveTeam")
    return
  end
  stageId = stageId or Logic_Temu:GetCurStageID()
  local TEMUHandler = require("client.network.Protocol.TEMUHandler")
  TEMUHandler.send_get_temu_recommend_list_from_pool_req(stageId)
end
function Logic_Temu_Invite.OnSendGetRecommendInviteMap(inviteSeverData, stage_id)
  local time_util = require("client.common.time_util")
  local curTime = time_util.GetServerTimeInSec()
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local uidProfileList = {}
  local list = {}
  for _, data in pairs(inviteSeverData) do
    local tempData = {
      uid = data.src_uid or data.leader_uid,
      group_id = data.group_id,
      leader_uid = data.leader_uid,
      stage = data.stage,
      total_num = data.total_num,
      invite_time = data.invite_time,
      is_corp = data.is_corp,
      auto_invite = data.auto_invite
    }
    table.insert(list, tempData)
    local profile = logic_profile:GetLocalProfile(tempData.uid)
    if not profile then
      table.insert(uidProfileList, tempData.uid)
    end
  end
  table.sort(list, function(a, b)
    return a.total_num > b.total_num
  end)
  if 0 < #uidProfileList then
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles(uidProfileList, Logic_Temu_Invite.UpdateHeadItem, Enum_PROFILE_REPORT_CFG.TEMU_TEAM)
  end
  Logic_Temu_Invite.groupInviteData.lastSendTime = curTime
  Logic_Temu_Invite.groupInviteData.recommendList[stage_id] = list
  EventSystem:postEvent(EVENTTYPE_TEMU, EVENTID_TEMU_UPDATE_TEAM_INVITE_LIST)
end
function Logic_Temu_Invite.InviteCrop()
  local cropId = DataMgr.corpsInfo.id
  log(bWriteLog and "Logic_Temu_Invite:InviteCrop, receiver_uid = " .. tostring(cropId))
  if not cropId or cropId == 0 then
    log(bWriteLog and "[SY]Logic_Temu_Invite:InviteCrop.No crop")
    return
  end
  if not Logic_Temu_Invite.IsFriendCanInvite(cropId) then
    log(bWriteLog and "[SY]Logic_Temu_Invite:InviteCrop, already invite")
    return
  end
  local Logic_Temu = GetModule()
  if not Logic_Temu then
    log(bWriteLog and "[SY]Logic_Temu_Invite.InviteCrop.No Module")
    return
  end
  local teamInfo, teamID = Logic_Temu:GetSelfTeamInfo()
  if not teamID or not teamInfo then
    return
  end
  local isHaveData, other = Logic_Temu_Invite.TryGetInviteOther()
  if not isHaveData then
    return
  end
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  local receiver = tonumber(cropId)
  local channel = chat_macro.Channel.channelCorps
  local tabContent = {}
  tabContent.msgType = chat_macro.temuInvite
  tabContent.  tabContent.text = LocUtil.GetLocalizeResStr(527031)
  Logic_Temu_Invite.SendInviteChat(receiver, channel, tabContent)
end
function Logic_Temu_Invite.InviteFriend(uid)
  log(bWriteLog and "Logic_Temu_Invite:InviteFriend, receiver_uid = " .. tostring(uid))
  if not Logic_Temu_Invite.IsFriendCanInvite(uid) then
    log(bWriteLog and "[SY]Logic_Temu_Invite:InviteFriend, already invite")
    return
  end
  local Logic_Temu = GetModule()
  if not Logic_Temu then
    log(bWriteLog and "[SY]Logic_Temu_Invite.InviteFriend.No Module")
    return
  end
  local teamInfo, teamID = Logic_Temu:GetSelfTeamInfo()
  if not teamID or not teamInfo then
    return
  end
  local isHaveData, other = Logic_Temu_Invite.TryGetInviteOther()
  if not isHaveData then
    return
  end
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  local receiver = tonumber(uid)
  local channel = chat_macro.Channel.channelPrivate
  local tabContent = {}
  tabContent.msgType = chat_macro.temuInvite
  tabContent.  tabContent.text = LocUtil.GetLocalizeResStr(527031)
  Logic_Temu_Invite.SendInviteChat(receiver, channel, tabContent)
end
function Logic_Temu_Invite.TaskRemind(uid)
  if not Logic_Temu_Invite.IsUserCanRemindTask(uid) then
    log(bWriteLog and "[SY]Logic_Temu_Invite:TaskRemind, already")
    return
  end
  local Logic_Temu = GetModule()
  if not Logic_Temu then
    log(bWriteLog and "[SY]Logic_Temu_Invite.TaskRemind.No Module")
    return
  end
  local teamInfo, teamID = Logic_Temu:GetSelfTeamInfo()
  if not teamID or not teamInfo then
    log(bWriteLog and "[SY]Logic_Temu_Invite.TaskRemind.NoTeamInfo")
    return
  end
  local isHaveData, other = Logic_Temu_Invite.TryGetRemindOther()
  if not isHaveData then
    return
  end
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  local receiver = tonumber(uid)
  local channel = chat_macro.Channel.channelPrivate
  local tabContent = {}
  tabContent.msgType = chat_macro.temuTaskRemind
  tabContent.  tabContent.text = LocUtil.GetLocalizeResStr(527138)
  Logic_Temu_Invite.SendInviteChat(receiver, channel, tabContent)
end
function Logic_Temu_Invite.SendInviteChat(receiver, channel, tabContent)
  local chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  local msgId = chat_main.CacheMsg(tabContent)
  ChatHandler.send_chat_req(receiver, channel, msgId, tabContent)
end
function Logic_Temu_Invite.SendInviteFriendList(uid_list)
  local Logic_Temu = GetModule()
  if not Logic_Temu then
    log(bWriteLog and "[SY]Logic_Temu_Invite.SendInviteFriendList.No Module")
    return
  end
  local selfTeam = Logic_Temu:GetSelfTeamInfo()
  if not selfTeam then
    log(bWriteLog and "[SY]Logic_Temu_Invite.SendInviteFriend.GetTeamInfo")
    return
  end
  if uid_list and 0 < #uid_list then
    for i = #uid_list, 1, -1 do
      local uid = uid_list[i]
      if not Logic_Temu_Invite.IsFriendCanInvite(uid) then
        log(bWriteLog and "[SY]Logic_Temu_Invite.SendInviteFriend.IsAlready InviteFirend" .. tostring(uid))
        table.remove(uid_list, i)
      end
    end
  end
  if not uid_list or #uid_list == 0 then
    log(bWriteLog and "[SY]Logic_Temu_Invite.NoFriendCanInvite")
    return
  end
  local isHaveData, other = Logic_Temu_Invite.TryGetInviteOther(true)
  if not isHaveData then
    return
  end
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  local channel = chat_macro.Channel.channelPrivate
  local msgType = chat_macro.temuInvite
  local tabContent = {}
  tabContent.  tabContent.  tabContent.text = LocUtil.GetLocalizeResStr(527031)
  local TEMUHandler = require("client.network.Protocol.TEMUHandler")
  TEMUHandler.send_invite_all_temu_group_friend_list_req(uid_list, channel, 0, tabContent)
  Logic_Temu_Invite.InviteListAddAll(uid_list)
  EventSystem:postEvent(EVENTTYPE_TEMU, EVENTID_TEMU_INVITE_FRIEND_UPDATE)
end
function Logic_Temu_Invite.TryGetInviteOther(isInviteAll)
  local Logic_Temu = GetModule()
  if not Logic_Temu then
    log(bWriteLog and "[SY]Logic_Temu_Invite.TryGetInviteOther.No Module")
    return false
  end
  local seasonID = Logic_Temu:GetCurSeasonID()
  if not seasonID or seasonID == 0 then
    log(bWriteLog and "[SY]Logic_Temu_Invite.TryGetInviteOther.NoSeasonID")
    return false
  end
  local teamInfo = Logic_Temu:GetSelfTeamInfo()
  if not teamInfo then
    log(bWriteLog and "[SY]Logic_Temu_Invite.TryGetInviteOther.NoTeamInfo")
    return false
  end
  local time_util = require("client.common.time_util")
  local data = {
    invite_all = isInviteAll and 1 or 0,
    activity_id = seasonID,
    group_id = teamInfo.group_id,
    leader_uid = teamInfo.leader_uid,
    total_num = teamInfo.total_num,
    stage = teamInfo.stage,
    invite_time = time_util.GetServerTimeInSec()
  }
  return true, data
end
function Logic_Temu_Invite.TryGetRemindOther()
  local Logic_Temu = GetModule()
  if not Logic_Temu then
    log(bWriteLog and "[SY]Logic_Temu_Invite.TryGetInviteOther.No Module")
    return false
  end
  local seasonID = Logic_Temu:GetCurSeasonID()
  if not seasonID or seasonID == 0 then
    log(bWriteLog and "[SY]Logic_Temu_Invite.TryGetInviteOther.NoSeasonID")
    return false
  end
  local teamInfo = Logic_Temu:GetSelfTeamInfo()
  if not teamInfo then
    log(bWriteLog and "[SY]Logic_Temu_Invite.TryGetInviteOther.NoTeamInfo")
    return false
  end
  local time_util = require("client.common.time_util")
  local data = {
    invite_all = 0,
    activity_id = seasonID,
    group_id = teamInfo.group_id,
    leader_uid = teamInfo.leader_uid,
    total_num = teamInfo.total_num,
    stage = teamInfo.stage,
    invite_time = time_util.GetServerTimeInSec()
  }
  return true, data
end
function Logic_Temu_Invite._UpdateInviteHead()
  EventSystem:postEvent(EVENTTYPE_TEMU, EVENTID_TEMU_UPDATE_INVITE_HEAD_INFO)
end
function Logic_Temu_Invite._IsCanSendGetGroupInviteMapMsg()
  local time_util = require("client.common.time_util")
  local curTime = time_util.GetServerTimeInSec()
  local lastTime = Logic_Temu_Invite.groupInviteData.lastSendTime or 0
  return curTime > lastTime + lastTimeSpan
end
function Logic_Temu_Invite.IsFriendCanInvite(uid)
  local dataMap = Logic_Temu_Invite.GetInviteList()
  if dataMap == nil then
    return true
  end
  return not dataMap[uid]
end
function Logic_Temu_Invite.IsUserCanRemindTask(uid)
  local dataMap = Logic_Temu_Invite.GetRemindList()
  if dataMap == nil then
    return true
  end
  return not dataMap[uid]
end
function Logic_Temu_Invite.GetInviteList()
  if Logic_Temu_Invite.inviteList then
    return Logic_Temu_Invite.inviteList
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local info = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.TemuInviteList)
  local Logic_Temu = GetModule()
  local seasonID = Logic_Temu:GetCurSeasonID()
  local groupID = Logic_Temu:GetSelfTeamID()
  log_tree("[SY]Logic_Temu_Invite.GetInviteList ", info)
  if info and seasonID ~= 0 and groupID ~= 0 and info.seasonID == seasonID and info.groupID == groupID and info.inviteList then
    Logic_Temu_Invite.inviteList = {}
    for i, j in pairs(info.inviteList) do
      Logic_Temu_Invite.inviteList[tonumber(i)] = j
    end
  else
    Logic_Temu_Invite.inviteList = {}
  end
  return Logic_Temu_Invite.inviteList
end
function Logic_Temu_Invite.GetRemindList()
  if Logic_Temu_Invite.remindList then
    return Logic_Temu_Invite.remindList
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local info = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.TemuRemindList)
  local Logic_Temu = GetModule()
  local seasonID = Logic_Temu:GetCurSeasonID()
  local groupID = Logic_Temu:GetSelfTeamID()
  log_tree("[SY]Logic_Temu_Invite.GetRemindList ", info)
  if info and seasonID ~= 0 and groupID ~= 0 and info.seasonID == seasonID and info.groupID == groupID and info.remindList then
    Logic_Temu_Invite.remindList = {}
    for i, j in pairs(info.remindList) do
      Logic_Temu_Invite.remindList[tonumber(i)] = j
    end
  else
    Logic_Temu_Invite.remindList = {}
  end
  return Logic_Temu_Invite.remindList
end
function Logic_Temu_Invite.GetGroupInviteList(stage_id)
  local Logic_Temu = GetModule()
  stage_id = stage_id or Logic_Temu:GetCurStageID()
  return Logic_Temu_Invite.groupInviteData.inviteList[stage_id]
end
function Logic_Temu_Invite.GetRecommendInviteList(stage_id)
  local Logic_Temu = GetModule()
  stage_id = stage_id or Logic_Temu:GetCurStageID()
  return Logic_Temu_Invite.groupInviteData.recommendList[stage_id]
end
function Logic_Temu_Invite.InviteListAdd(uid)
  uid = uid or DataMgr.corpsInfo.id
  log(bWriteLog and "[SY]Logic_Temu_Invite.InviteListAdd." .. uid)
  local inviteList = Logic_Temu_Invite.GetInviteList()
  inviteList[uid] = true
  Logic_Temu_Invite.SaveInviteList(inviteList)
end
function Logic_Temu_Invite.RemindListAdd(uid)
  uid = uid or DataMgr.corpsInfo.id
  log(bWriteLog and "[SY]Logic_Temu_Invite.InviteListAdd." .. uid)
  local list = Logic_Temu_Invite.GetRemindList()
  list[uid] = true
  Logic_Temu_Invite.SaveRemindList(list)
end
function Logic_Temu_Invite.InviteListAddAll(uid_list)
  log_tree("InviteListAddAll", uid_list)
  local inviteList = Logic_Temu_Invite.GetInviteList()
  for i, uid in pairs(uid_list) do
    inviteList[uid] = true
  end
  Logic_Temu_Invite.SaveInviteList(inviteList)
end
function Logic_Temu_Invite.SaveInviteList(inviteList)
  local Logic_Temu = GetModule()
  if not Logic_Temu then
    log(bWriteLog and "[SY]Logic_Temu_Invite.SaveInviteList.No Module")
    return
  end
  local seasonID = Logic_Temu:GetCurSeasonID()
  if not seasonID or seasonID == 0 then
    log(bWriteLog and "[SY]Logic_Temu_Invite.SaveInviteList.No activityID")
    return
  end
  local groupID = Logic_Temu:GetSelfTeamID()
  if not groupID or groupID == 0 then
    log(bWriteLog and "[SY]Logic_Temu_Invite.SaveInviteList.No groupID")
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N({
    seasonID = seasonID,
    groupID = groupID,
      }, PlayerPrefsSystem.ePlayerPrefsType.TemuInviteList)
end
function Logic_Temu_Invite.SaveRemindList(remindList)
  local Logic_Temu = GetModule()
  if not Logic_Temu then
    log(bWriteLog and "[SY]Logic_Temu_Invite.SaveRemindList.No Module")
    return
  end
  local seasonID = Logic_Temu:GetCurSeasonID()
  if not seasonID or seasonID == 0 then
    log(bWriteLog and "[SY]Logic_Temu_Invite.SaveRemindList.No activityID")
    return
  end
  local groupID = Logic_Temu:GetSelfTeamID()
  if not groupID or groupID == 0 then
    log(bWriteLog and "[SY]Logic_Temu_Invite.SaveRemindList.No groupID")
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N({
    seasonID = seasonID,
    groupID = groupID,
      }, PlayerPrefsSystem.ePlayerPrefsType.TemuRemindList)
end
function Logic_Temu_Invite.ClearInviteList()
  Logic_Temu_Invite.inviteList = {}
  EventSystem:postEvent(EVENTTYPE_TEMU, EVENTID_TEMU_INVITE_FRIEND_UPDATE)
end
function Logic_Temu_Invite.ClearRemindList()
  Logic_Temu_Invite.remindList = {}
  EventSystem:postEvent(EVENTTYPE_TEMU, EVENTID_TEMU_UPDATE_TASK_REMIND)
end
function Logic_Temu_Invite.ReqFriendProfile(bShow)
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  if bShow or nowTime - Logic_Temu_Invite.lastFriendProfileReqTime >= 300 then
    Logic_Temu_Invite.lastFriendProfileReqTime = nowTime
    local list = {}
    local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
    local friendList = LogicFriend.GetFriendList(true)
    for i, j in pairs(friendList) do
      table.insert(list, j.uid)
    end
    log_tree("Logic_Temu_Invite:OnShow ReqFriendProfile List = ", list)
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetFriendProfiles(Enum_PROFILE_REPORT_CFG.TEMU_TEAM, list, function()
      EventSystem:postEvent(EVENTTYPE_TEMU, EVENTID_TEMU_INVITE_FRIEND_UPDATE)
    end, true)
  end
end
function Logic_Temu_Invite.ClearGroupInviteData()
  local groupInviteData = Logic_Temu_Invite.groupInviteData
  groupInviteData.inviteList = {}
  groupInviteData.recommendList = {}
  groupInviteData.lastSendTime = 0
end
return Logic_Temu_Invite