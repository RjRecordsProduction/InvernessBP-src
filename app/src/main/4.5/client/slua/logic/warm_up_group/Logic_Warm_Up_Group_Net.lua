local WarmUpGroupHandler = require("client.network.Protocol.WarmUpGroupHandler")
local TimeUtil = require("client.common.time_util")
local Logic_Warm_Up_Group = {
  nMemberCount = nil,
  nLastGetActDataReqTime = nil,
  nLastFriendTopNumProfileReqTime = nil,
  nLastFriendProfileReqTime = nil,
  nLastMyTeamProfileReqTime = nil,
  nLastInvitorProfileReqTime = nil,
  tLastRequestTimes = nil
}
function Logic_Warm_Up_Group:TryGetAllData(bForceUpdate)
  log(bWriteLog and "Logic_Warm_Up_Group:TryGetAllData Start")
  if not self:CheckIsModuleOpen() then
    return
  end
  if not bForceUpdate and self:CheckDataValid() then
    return
  end
  self:TryGetCfg():Then(function()
    if not self:IsActivityInTime() then
      log(bWriteLog and "Logic_Warm_Up_Group:TryGetAllData IsActivityInTime false")
      return
    end
    self:SendGetActData(true)
  end)
end
function Logic_Warm_Up_Group:InviteFriend(uid)
  log(bWriteLog and "Logic_Warm_Up_Group:InviteFriend, receiver_uid = " .. tostring(uid))
  local other = self:GetInviteOther()
  if not other then
    log_error("Logic_Warm_Up_Group:InviteFriend other = nil")
    return
  end
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  local receiver = tonumber(uid)
  local channel = chat_macro.Channel.channelPrivate
  local tabContent = {}
  tabContent.msgType = chat_macro.WarmUpGroupInvite
  tabContent.  tabContent.text = LocUtil.GetLocalizeResStr(527031)
  self:SendInviteChat(receiver, channel, tabContent)
end
function Logic_Warm_Up_Group:SendInviteChat(receiver, channel, tabContent)
  local chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  local msgId = chat_main.CacheMsg(tabContent)
  ChatHandler.send_chat_req(receiver, channel, msgId, tabContent)
end
function Logic_Warm_Up_Group:SendGetReward(nMemberCount)
  self.  return WarmUpGroupHandler.send_pre_team_act_get_reward(nMemberCount)
end
function Logic_Warm_Up_Group:ResponseGetReward(tData)
  if not tData then
    log_error("Logic_Warm_Up_Group:ResponseGetReward tData = nil")
    return
  end
  local tActData = self:GetActivityData()
  if not tActData then
    log_error("Logic_Warm_Up_Group:ResponseGetReward tActData = nil")
    return
  end
  if not tActData.rewards_status then
    tActData.rewards_status = {}
  end
  if self.nMemberCount then
    tActData.rewards_status[self.nMemberCount] = true
  end
  local tReward = {
    {
      res_id = tData.item_id,
      count = tData.item_num,
      valid_hours = tData.valid_hours
    }
  }
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(tReward)
end
function Logic_Warm_Up_Group:SendGetFriendTeam(tTeamIds)
  local table_util = require("common.table_util")
  if table_util.CountTable(tTeamIds) <= 0 then
    log(bWriteLog and "Logic_Warm_Up_Group:SendGetFriendTeam empty")
    return self:GetPromise()
  end
  self.tLastRequestTimes = self.tLastRequestTimes or {}
  local currentTime = TimeUtil.GetServerTimeInSec()
  for i = #self.tLastRequestTimes, 1, -1 do
    if currentTime - self.tLastRequestTimes[i] >= 2 then
      table.remove(self.tLastRequestTimes, i)
    end
  end
  if #self.tLastRequestTimes < 2 then
    table.insert(self.tLastRequestTimes, currentTime)
    log(bWriteLog and "Logic_Warm_Up_Group:SendGetFriendTeam send")
    return WarmUpGroupHandler.send_pre_team_act_get_friend_teams(tTeamIds)
  end
  log(bWriteLog and "Logic_Warm_Up_Group:SendGetFriendTeam block")
  return self:GetPromise()
end
function Logic_Warm_Up_Group:ResponseGetFriendTeam(tData)
  for _, tTeamInfo in pairs(tData or {}) do
    local nTeamID = tTeamInfo.team_id
    if nTeamID then
      self.friendsTeamInfos[nTeamID] = tTeamInfo
    end
  end
end
function Logic_Warm_Up_Group:SendCreateTeam()
  return WarmUpGroupHandler.send_pre_team_act_create_team()
end
function Logic_Warm_Up_Group:ResponseCreateTeam(data)
  self:SetMyGroupData(data)
end
function Logic_Warm_Up_Group:SendJoinTeam(nID)
  if not nID then
    log_error("Logic_Warm_Up_Group nID = nil")
    return self:GetPromise()
  end
  return WarmUpGroupHandler.send_pre_team_act_join_team(nID)
end
function Logic_Warm_Up_Group:ResponseJoinTeam(tData)
  self:SetMyGroupData(tData)
end
function Logic_Warm_Up_Group:SendInviteToJoinTeam(nID)
  return WarmUpGroupHandler.send_pre_team_act_invite_join(nID)
end
function Logic_Warm_Up_Group:ResponseInviteToJoinTeam(tData)
  local tActData = self:GetActivityData()
  if not tActData then
    log_error("Logic_Warm_Up_Group:ResponseInviteToJoinTeam tActData = nil")
    return
  end
  if not tData.uid then
    log_error("Logic_Warm_Up_Group:ResponseInviteToJoinTeam uid = nil")
    return
  end
  if not tActData.invited_list then
    tActData.invited_list = {}
  end
  tActData.invited_list[tData.uid] = true
  self:InviteFriend(tData.uid)
end
function Logic_Warm_Up_Group:SendGetActData(bGetDataSilent)
  local nowTime = TimeUtil.GetServerTimeInSec()
  if not self.nLastGetActDataReqTime or nowTime - self.nLastGetActDataReqTime > 5 then
    self.nLastGetActDataReqTime = nowTime
    log(bWriteLog and "Logic_Warm_Up_Group:SendGetActData")
    return WarmUpGroupHandler.send_pre_team_act_query_team_info(bGetDataSilent)
  end
  return self:GetPromise()
end
function Logic_Warm_Up_Group:ResponseGetActData(data)
  if not data then
    log_error("Logic_Warm_Up_Group:ResponseGetActData data = nil")
    return
  end
  self.actData = data
  log(bWriteLog and "Logic_Warm_Up_Group:ResponseGetActData Success")
end
function Logic_Warm_Up_Group:SendGetInvitorProfile()
  local nowTime = TimeUtil.GetServerTimeInSec()
  if not self.nLastInvitorProfileReqTime or nowTime - self.nLastInvitorProfileReqTime >= 30 then
    self.nLastInvitorProfileReqTime = nowTime
    local tList = {}
    local tInvitorList = self:GetBeInvitedData()
    for i, j in pairs(tInvitorList) do
      table.insert(tList, j.uid)
    end
    if 0 < #tList then
      log_tree("Logic_Warm_Up_Group SendGetInvitorProfile List = ", tList)
      return self:SendGetProfile(tList)
    end
  end
  return self:GetPromise()
end
function Logic_Warm_Up_Group:SendGetFriendProfile()
  local nowTime = TimeUtil.GetServerTimeInSec()
  if not self.nLastFriendProfileReqTime or nowTime - self.nLastFriendProfileReqTime >= 30 then
    self.nLastFriendProfileReqTime = nowTime
    local tList = {}
    local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
    local tFriendList = LogicFriend.GetFriendList(true) or {}
    for i, j in ipairs(tFriendList) do
      table.insert(tList, j.uid)
    end
    if 0 < #tList then
      log_tree("Logic_Warm_Up_Group SendGetFrienProfile List = ", tList)
      return self:SendGetProfile(tList)
    end
  end
  return self:GetPromise()
end
function Logic_Warm_Up_Group:SendGetMyTeamProfile()
  local nowTime = TimeUtil.GetServerTimeInSec()
  if not self.nLastMyTeamProfileReqTime or nowTime - self.nLastMyTeamProfileReqTime >= 2 then
    self.nLastMyTeamProfileReqTime = nowTime
    local tList = {}
    local tMemberList = self:GetMemberData()
    for i, j in ipairs(tMemberList) do
      table.insert(tList, j.uid)
    end
    if 0 < #tList then
      log_tree("Logic_Warm_Up_Group SendGetFrienProfile List = ", tList)
      return self:SendGetProfile(tList)
    end
  end
  return self:GetPromise()
end
function Logic_Warm_Up_Group:SendGetTopNumRandomOnlineFriendProfile()
  local nowTime = TimeUtil.GetServerTimeInSec()
  if not self.nLastFriendTopNumProfileReqTime or nowTime - self.nLastFriendTopNumProfileReqTime >= 2 then
    local fGetRandomElements = function(list, count)
      count = count or 10
      local result = {}
      local n = #list
      if count >= n then
        for i, v in ipairs(list) do
          table.insert(result, v)
        end
        return result
      end
      for i = 1, count do
        local randomIndex = math.random(i, n)
        list[i], list[randomIndex] = list[randomIndex], list[i]
        table.insert(result, list[i])
      end
      return result
    end
    local tList = {}
    local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
    local friendList = LogicFriend.GetFriendList(true)
    for i, j in ipairs(friendList) do
      if not self.bOnlineLimit or j.online and j.online ~= 0 then
        table.insert(tList, j.uid)
      end
    end
    log(bWriteLog and "Logic_Warm_Up_Group:SendGetTopNumRandomOnlineFriendProfile online Count" .. tostring(#tList))
    tList = fGetRandomElements(tList, self.nSendGetTopNumRandomOnlineFriendProfileCount)
    if 0 < #tList then
      self.nLastFriendTopNumProfileReqTime = nowTime
      log_tree("MyTreeLog Logic_Warm_Up_Group SendGetFrienProfile List = ", tList)
      return self:SendGetProfile(tList)
    end
  end
  return self:GetPromise()
end
function Logic_Warm_Up_Group:SendGetProfile(tList)
  local Promise = require("common.Promise")
  local tNewPromise = Promise.new()
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetFriendProfiles(Enum_PROFILE_REPORT_CFG.WARM_UP_TEAM, tList, function()
    tNewPromise:Resolve(tList)
  end, true)
  return tNewPromise
end
function Logic_Warm_Up_Group:SendGetRecordData()
  local nCurrentTime = TimeUtil.GetServerTimeInSec()
  local tOpenInvitorRecordUIBPCacheData = self:GetJoinUICacheData()
  if tOpenInvitorRecordUIBPCacheData then
    local nlastOpenRecordUITime = tOpenInvitorRecordUIBPCacheData.nlastOpenRecordUITime
    if nlastOpenRecordUITime and nCurrentTime - nlastOpenRecordUITime <= 5 then
      log(bWriteLog and "Logic_Warm_Up_Group SendGetRecordData \231\188\147\229\173\152\230\137\147\229\188\128\231\149\140\233\157\162")
      return self:GetPromise(tOpenInvitorRecordUIBPCacheData)
    end
  end
  if self.tSendGetBeInvitedRecordDataPromise then
    return self:GetPromise(nil)
  end
  if self.tSendGetRandomFriendDataPromise then
    return self:GetPromise(nil)
  end
  local fCancelPromise = function()
    local tSendGetBeInvitedRecordDataPromise = self.tSendGetBeInvitedRecordDataPromise
    if tSendGetBeInvitedRecordDataPromise then
      self.tSendGetBeInvitedRecordDataPromise = nil
      tSendGetBeInvitedRecordDataPromise:Cancel()
      log(bWriteLog and "Logic_Warm_Up_Group SendGetRecordData tSendGetBeInvitedRecordDataPromise Cancel")
    end
    local tSendGetRandomFriendDataPromise = self.tSendGetRandomFriendDataPromise
    if tSendGetRandomFriendDataPromise then
      self.tSendGetRandomFriendDataPromise = nil
      tSendGetRandomFriendDataPromise:Cancel()
      log(bWriteLog and "Logic_Warm_Up_Group SendGetRecordData tSendGetRandomFriendDataPromise Cancel")
    end
  end
  local tStartPromise = self:GetPromise()
  local Promise = require("common.Promise")
  log(bWriteLog and "Logic_Warm_Up_Group SendGetRecordData Start")
  local tGetDataPromise = self:_SendGetBeInvitedRecordData():Then(function(tRecommendList)
    self.tSendGetBeInvitedRecordDataPromise = nil
    if tRecommendList and 0 < #tRecommendList then
      return {
        tRecommendList = tRecommendList or {},
        nlastOpenRecordUITime = TimeUtil.GetServerTimeInSec(),
        bShowBeInvitedListRecord = true
      }
    end
    return self:_SendGetRandomFriendData():Then(function(tRecommendList)
      self.tSendGetRandomFriendDataPromise = nil
      return {
        tRecommendList = tRecommendList or {},
        nlastOpenRecordUITime = TimeUtil.GetServerTimeInSec(),
        bShowBeInvitedListRecord = false
      }
    end)
  end):Then(function(tOpenInvitorRecordUIBPCacheData)
    self:SetJoinUICacheData(tOpenInvitorRecordUIBPCacheData)
    return tOpenInvitorRecordUIBPCacheData
  end)
  return tStartPromise.any({
    Promise.Helper.LobbyDelay(10):Then(function()
      log(bWriteLog and "Logic_Warm_Up_Group SendGetRecordData \232\175\183\230\177\13010s\232\190\190\229\136\176")
      return {}
    end),
    tGetDataPromise
  }):Then(function(tOpenInvitorRecordUIBPCacheData)
    log(bWriteLog and "Logic_Warm_Up_Group SendGetRecordData End")
    fCancelPromise()
    return tOpenInvitorRecordUIBPCacheData
  end):Catch(function(err)
    fCancelPromise()
    log_error("Logic_Warm_Up_Group SendGetRecordData err = " .. tostring(err))
    return {}
  end)
end
function Logic_Warm_Up_Group:_SendGetBeInvitedRecordData()
  log(bWriteLog and "Logic_Warm_Up_Group SendGetBeInvitedRecordData Start")
  self.tSendGetBeInvitedRecordDataPromise = self:SendGetActData()
  log(bWriteLog and "Logic_Warm_Up_Group SendGetRecordData tSendGetBeInvitedRecordDataPromise Create")
  return self.tSendGetBeInvitedRecordDataPromise:Then(function()
    local tBeInvitedList = self:GetBeInvitedData() or {}
    log(bWriteLog and "Logic_Warm_Up_Group SendGetBeInvitedRecordData \232\142\183\229\143\150\232\162\171\233\130\128\232\175\183\229\136\151\232\161\168\230\149\176\230\141\174")
    log_tree("MyTreeLog Logic_Warm_Up_Group SendGetBeInvitedRecordData tBeInvitedList", tBeInvitedList)
    local tMapTeamID = {}
    for _, tData in pairs(tBeInvitedList) do
      if tData.team_id and not tData.is_gm then
        tMapTeamID[tData.team_id] = true
      end
    end
    local nMyGroupID = self:GetMyGroupID()
    if nMyGroupID then
      tMapTeamID[nMyGroupID] = nil
    end
    log_tree("MyTreeLog Logic_Warm_Up_Group SendGetBeInvitedRecordData teamID", tMapTeamID)
    return self:SendGetFriendTeam(tMapTeamID):Then(function()
      return {tMapTeamID, tBeInvitedList}
    end)
  end):Then(function(tResult)
    local tMapTeamID = tResult and tResult[1] or {}
    local tBeInvitedList = tResult and tResult[2] or {}
    log(bWriteLog and "Logic_Warm_Up_Group SendGetBeInvitedRecordData \232\142\183\229\143\150\233\152\159\228\188\141\230\149\176\230\141\174")
    local tData = self:GetTeamInfo(tMapTeamID)
    log(bWriteLog and "Logic_Warm_Up_Group SendGetBeInvitedRecordData HandleBeInvitedData \232\191\135\230\187\164\230\149\176\230\141\174\229\137\141" .. tostring(#tData))
    local tRecommendList = self:HandleBeInvitedData(tData, tBeInvitedList)
    return tRecommendList
  end):Then(function(tRecommendList)
    log(bWriteLog and "Logic_Warm_Up_Group SendGetBeInvitedRecordData End")
    return tRecommendList
  end)
end
function Logic_Warm_Up_Group:_SendGetRandomFriendData()
  log(bWriteLog and "Logic_Warm_Up_Group SendGetRandomFriendData Start \233\154\143\230\156\186\232\142\183\229\143\150" .. tostring(self.nSendGetTopNumRandomOnlineFriendProfileCount) .. "\228\184\170\229\165\189\229\143\139Profile")
  self.tSendGetRandomFriendDataPromise = self:SendGetTopNumRandomOnlineFriendProfile()
  return self.tSendGetRandomFriendDataPromise:Then(function(tList)
    tList = tList or {}
    log_tree("MyTreeLog Logic_Warm_Up_Group SendGetRandomFriendData profileList", tList)
    local tMapTeamID = {}
    local tMapTeamID2FriendUid = {}
    if tList then
      for _, nUid in pairs(tList) do
        local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
        local tProfile = logic_profile:GetLocalProfile(nUid)
        if tProfile then
          local nTeamID = tProfile.pre_team_id
          if nTeamID and nTeamID ~= 0 then
            tMapTeamID[nTeamID] = true
            tMapTeamID2FriendUid[nTeamID] = nUid
          end
        end
      end
    end
    local nMyGroupID = self:GetMyGroupID()
    if nMyGroupID then
      tMapTeamID[nMyGroupID] = nil
    end
    log(bWriteLog and "Logic_Warm_Up_Group SendGetRandomFriendData \232\142\183\229\143\150\233\154\143\230\156\186\229\165\189\229\143\139\233\152\159\228\188\141\230\149\176\230\141\174")
    log_tree("MyTreeLog Logic_Warm_Up_Group SendGetRandomFriendData teamID", tMapTeamID)
    return self:SendGetFriendTeam(tMapTeamID):Then(function()
      return {tMapTeamID, tMapTeamID2FriendUid}
    end)
  end):Then(function(tResult)
    local tMapTeamID = tResult and tResult[1] or {}
    local tMapTeamID2FriendUid = tResult and tResult[2] or {}
    local tData = self:GetTeamInfo(tMapTeamID)
    log_tree("MyTreeLog Logic_Warm_Up_Group SendGetRandomFriendData tData", tData)
    log(bWriteLog and "Logic_Warm_Up_Group SendGetRandomFriendData HandleRecommendData \232\191\135\230\187\164\230\149\176\230\141\174\229\137\141" .. tostring(#tData))
    local tRecommendList = self:HandleRecommendData(tData, tMapTeamID2FriendUid)
    return tRecommendList
  end):Then(function(tRecommendList)
    log(bWriteLog and "Logic_Warm_Up_Group SendGetRandomFriendData End")
    return tRecommendList
  end)
end
function Logic_Warm_Up_Group:GetPromise(...)
  local Promise = require("common.Promise")
  local tNewPromise = Promise.new()
  tNewPromise:Resolve(...)
  return tNewPromise
end
local Trait = require("common.trait")
local CLogic_Warm_Up_Group = Trait(Trait.TraitPrototype, nil, Logic_Warm_Up_Group)
return CLogic_Warm_Up_Group