local logic_profile = {}
function logic_profile:DefineAndResetData()
  self.sendSequenceNum = 0
  self.dicFriend = {}
  self.dicStranger = {}
  self.dicSendMap = {}
end
function logic_profile:ctor(_, ModuleConfig)
  self._config = ModuleConfig
end
function logic_profile:OnLogOut()
  logic_profile.__super.OnLogOut(self)
  self:DefineAndResetData()
end
function logic_profile:OnPreSwitchGameStatus(preState, nextState)
  if nextState ~= GameStatus.Fighting or LobbySystem.CheckOpen(1002013) then
    return
  end
  if GameStatus.IsInMainCity() then
    return
  end
  self.dicStranger = {}
  self.dicSendMap = {}
end
function logic_profile:send_batch_get_bin_profile_req(listUid, callback, needRefresh, isFriend, isGetRankData, refreshOnlineStatus, moduleId, infoTag)
  isGetRankData = isGetRankData or 0
  moduleId = moduleId or 0
  local logic_profile_utils = require("client.slua.logic.user.profile.logic_profile_utils")
  infoTag = logic_profile_utils.Binary2Decimal(infoTag or 0)
  local profileListValid = {}
  local uidListInvalid = {}
  if type(listUid) ~= "table" then
    log(bWriteLog and "logic_profile:send_batch_get_bin_profile_req invalid listUid")
    return 0
  end
  if #listUid < 1 then
    log(bWriteLog and "logic_profile:send_batch_get_bin_profile_req empty listUid")
    return 0
  end
  for _, v in pairs(listUid) do
    local isTimeValid, isTagValid = false, false
    local localProfile
    v = tonumber(v)
    if v and 0 < v then
      localProfile = self:GetLocalProfile(v, isFriend)
      if not needRefresh then
        isTimeValid = true
      elseif isGetRankData ~= 1 and 1 < #listUid then
        isTimeValid = logic_profile_utils.JudgeItemValidByTime(localProfile)
      end
      isTagValid = logic_profile_utils.JudgeItemValidByTag(localProfile, infoTag)
    end
    if isTimeValid and isTagValid then
      table.insert(profileListValid, localProfile)
    else
      table.insert(uidListInvalid, v)
    end
  end
  local maxSingleReqCount = logic_profile_utils.GetReqCountByTag(infoTag, isGetRankData)
  local uidListInvalidCount = #uidListInvalid
  if uidListInvalidCount <= 0 and not refreshOnlineStatus then
    if callback then
      local utility = require("common.utility")
      xpcall(callback, utility.ErrorMessageHandler, profileListValid)
    end
    xpcall(function()
      EventSystem:postEvent(EVENTTYPE_PROFILE, EVENTID_PROFILE_MSG, profileListValid)
    end, function()
      log_error("OriginalGetProfileList event handle error")
    end)
    return 0
  end
  local sendCount = 0
  self.sendSequenceNum = self.sendSequenceNum + 1
  local listSendUid = {}
  local index = 1
  local ProfileHander = require("client.network.Protocol.ProfileHander")
  for k, v in ipairs(uidListInvalid) do
    table.insert(listSendUid, v)
    if maxSingleReqCount < index or k == uidListInvalidCount then
      ProfileHander.send_batch_get_bin_profile_req(self.sendSequenceNum, slua.LuaArchiverEncode(LuaStateWrapper, listSendUid), isGetRankData, index, moduleId, infoTag)
      listSendUid = {}
      index = 1
      sendCount = sendCount + 1
    end
    index = index + 1
  end
  if refreshOnlineStatus then
    local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
    PlayerStatusMgr:GetOrReqStatusData(ENUM_BATCH_GET_GROUP_AND_ONLINE.ProfileMgr, listUid)
  end
  self.dicSendMap[self.sendSequenceNum] = {
    sendSeq = self.sendSequenceNum,
    profileListValid = profileListValid,
    uidListInvalid = uidListInvalid,
    isFriend = isFriend,
    callback = callback,
    sendCount = sendCount,
    sendOnlineStatus = refreshOnlineStatus and 1 or 0,
      }
  return self.sendSequenceNum
end
function logic_profile:GetLocalProfile(uid, forceFriend)
  uid = tonumber(uid)
  local result = self.dicFriend[uid]
  if result and result.isInit or forceFriend then
    return result
  end
  result = self.dicStranger[uid]
  if result and result.isInit then
    return result
  end
  return nil
end
function logic_profile:ClearCache(uid)
  log(bWriteLog and "logic_profile:ClearCache uid = " .. uid)
  uid = tonumber(uid)
  self.dicFriend[uid] = nil
  self.dicStranger[uid] = nil
end
function logic_profile:ClearSendCallbackRegister(sendSeq)
  self.dicSendMap[sendSeq] = nil
end
function logic_profile:ClearStrangerCache()
  self.dicStranger = {}
end
function logic_profile:GetLastOnlineTime(uid)
  local profile = self:GetLocalProfile(uid)
  if not profile then
    return nil
  elseif profile.lastOnlineTime and not profile.hiding_time then
    return profile.lastOnlineTime
  elseif profile.hiding_time and not profile.lastOnlineTime then
    return profile.hiding_time
  elseif profile.lastOnlineTime < profile.hiding_time then
    return profile.lastOnlineTime
  elseif profile.lastOnlineTime >= profile.hiding_time then
    return profile.hiding_time
  else
    return nil
  end
end
function logic_profile:IsPlayerDelete(profile)
  if not profile or not type(profile) == "table" then
    return false
  end
  return profile.is_del
end
function logic_profile:GetRoleSexByUid(uid, needBasicSex)
  local profile = self:GetLocalProfile(uid)
  if not profile then
    return 0
  end
  if needBasicSex then
    return profile.sex
  elseif profile.social_card and profile.social_card.new_sex then
    return profile.social_card.new_sex
  else
    return 0
  end
end
function logic_profile:GetPlayerNation(uid)
  local profile = self:GetLocalProfile(uid)
  if tonumber(uid) == tonumber(DataMgr.roleData.uid) then
    profile = DataMgr.roleData
  end
  if not profile then
    return ""
  end
  return profile.nation
end
function logic_profile:GetNickName(uid)
  local profile = self:GetLocalProfile(uid)
  return profile and profile.nickName or nil
end
function logic_profile:GetFriendNickName(uid)
  uid = tonumber(uid)
  if not self.dicFriend[uid] then
    return nil
  end
  return self.dicFriend[uid].nickName
end
function logic_profile:GetFriendNickNameInGame(uid)
  uid = tonumber(uid)
  local profile = self.dicFriend[uid]
  if not profile then
    return nil
  end
  local logic_profile_utils = require("client.slua.logic.user.profile.logic_profile_utils")
  local bIsShowGRName = logic_profile_utils.GetIsShowGRName()
  if profile.isPlatFriend and (profile.gameRemarkName == "" or not bIsShowGRName) then
    return profile.gameName
  else
    return profile.nickName
  end
end
function logic_profile:IsPlayerBanned(uid)
  local profile = self:GetLocalProfile(uid)
  if not profile then
    return false
  end
  local login_banned_ts = profile.login_banned_ts
  if not login_banned_ts then
    return false
  end
  local TimeUtil = require("client.common.time_util")
  return login_banned_ts[2] > TimeUtil.GetServerTimeInSec()
end
function logic_profile:IsPlayerBannedBeforeTime(uid, timeStamp)
  if not self:IsPlayerBanned(uid) then
    return false
  end
  local profile = self:GetLocalProfile(uid)
  return timeStamp < profile.login_banned_ts[2]
end
function logic_profile:IsPlayerBannedOver30day(uid)
  if not self:IsPlayerBanned(uid) then
    return false
  end
  local profile = self:GetLocalProfile(uid)
  local login_banned_ts = profile.login_banned_ts
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  local banDurationDay = LobbySystem.roleData.clear_client_banned_interval or 0
  local banDurationSec = banDurationDay * 24 * 3600
  local banStartTime = tonumber(login_banned_ts[1]) or 0
  local banEndTime = tonumber(login_banned_ts[2]) or 0
  local playerBanDuration = banEndTime - banStartTime
  if curTime > banStartTime and curTime < banEndTime then
    return banDurationSec <= playerBanDuration
  end
  return false
end
function logic_profile:IsPlayerChatBanned(uid)
  local profile = self:GetLocalProfile(uid)
  if not profile then
    return false
  end
  if not profile.chat_banned_ts then
    return false
  end
  local TimeUtil = require("client.common.time_util")
  return profile.chat_banned_ts > TimeUtil.GetServerTimeInSec()
end
function logic_profile:SetFriendSubData()
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local innerList = LogicFriend.GetInnerList(false)
  local platformList = LogicFriend.GetPLatformList(false)
  local logic_profile_utils = require("client.slua.logic.user.profile.logic_profile_utils")
  for _, v in pairs(innerList) do
    self.dicFriend[v] = logic_profile_utils.FormatInnerFriendProfile(self.dicFriend[v], LogicFriend.GetFriendData(v), v)
  end
  for _, v in pairs(platformList) do
    self.dicFriend[v] = logic_profile_utils.FormatPlatFriendProfile(self.dicFriend[v], LogicFriend.GetFriendData(v), v)
  end
end
function logic_profile:ModifyFriendSubData(friendData, isPlatForm)
  local logic_profile_utils = require("client.slua.logic.user.profile.logic_profile_utils")
  self.dicFriend[friendData.uid] = logic_profile_utils.FormatFriendProfile(self.dicFriend[friendData.uid], friendData, isPlatForm)
end
function logic_profile:ModifyFriendReserveSwitch(uid, privacy_value)
  if not uid or not privacy_value then
    return
  end
  uid = tonumber(uid)
  if not self.dicFriend[uid] then
    return
  end
  self.dicFriend[uid].friend_appointment_privacy = privacy_value
  log(bWriteLog and string.format("logic_profile:ModifyFriendReserveSwitch uid: %s, privacy_value: %s", uid, privacy_value))
end
function logic_profile:proc_batch_get_bin_profile_rsp(sendSeq, profileList, hasRankData)
  local sendInfoItem = self.dicSendMap[sendSeq]
  if not sendInfoItem then
    return
  end
  sendInfoItem.sendCount = sendInfoItem.sendCount - 1
  local logic_multiple_area = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_multiple_area)
  local isRussia = logic_multiple_area:IsConnectToRussiaArea()
  local logic_profile_utils = require("client.slua.logic.user.profile.logic_profile_utils")
  local NicknameColorManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NicknameColorManager)
  local logic_online_status = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_online_status)
  local profile_config = require("client.slua.logic.user.profile.profile_config")
  for k, v in pairs(profileList) do
    local data = logic_profile_utils.CreateProfile(k, v)
    if isRussia and data.history_max_segment_level and next(data.history_max_segment_level) then
      for i = 1, #data.history_max_segment_level do
        if i ~= 2 then
          data.history_max_segment_level[i] = 101
        end
      end
    end
    if tostring(data.uid) == tostring(DataMgr.roleData.uid) then
      DataMgr.UpdateMyRoleProfileData(data, v.rankdata, v.upass, v.alias)
      local logic_popular_gift_pk = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_gift_pk)
      logic_popular_gift_pk:proc_view_pk_switch(v.psmatch_view_pk_switch)
    end
    local oldProfile = self:GetLocalProfile(k, true)
    local bIsAddToFriendDic = (v.isFriend or oldProfile) and tostring(data.uid) ~= tostring(DataMgr.roleData.uid)
    if not bIsAddToFriendDic then
      oldProfile = self:GetLocalProfile(k)
    end
    oldProfile = logic_online_status:GetItemByUid(k) or oldProfile
    if oldProfile then
      for kk, vv in pairs(profile_config.Online2ProfileKey) do
        data[kk] = oldProfile[kk] or vv.default
      end
      data = logic_profile_utils.MergeProfile(data, oldProfile)
    end
    if bIsAddToFriendDic then
      data.isPlatFriend = oldProfile.isPlatFriend or false
      if data.isPlatFriend and data.gameName then
        if data.remarks_name and data.remarks_name ~= "" then
          data.nickName = data.gameName .. "(" .. data.remarks_name .. ")"
        elseif data.platName and data.platName ~= "" then
          data.nickName = data.gameName .. "(" .. data.platName .. ")"
        end
      end
      self.dicFriend[k] = data
    else
      self.dicStranger[k] = data
    end
    logic_online_status:ClearItemByUid(k)
    if hasRankData == 1 then
      data.rankdata = v.rankdata
    end
    table.insert(sendInfoItem.profileListValid, data)
    if k ~= tonumber(DataMgr.roleData.uid) or NicknameColorManager:CanTrustProfileColor() then
      local msg_use_color = v.collect_data and v.collect_data.msg_use_color
      NicknameColorManager:SetUserData(k, msg_use_color)
    end
  end
  if self:CheckIsReceiveAllAndDoCallBack(sendSeq, sendInfoItem) then
    EventSystem:postEvent(EVENTTYPE_PROFILE, EVENTID_PROFILE_LIST_UPDATE)
  end
end
function logic_profile:proc_batch_get_group_and_online_rsp(sendSeq)
  local sendInfoItem = self.dicSendMap[sendSeq]
  if not sendInfoItem then
    return
  end
  self:CheckIsReceiveAllAndDoCallBack(sendSeq, sendInfoItem)
end
function logic_profile:CheckIsReceiveAllAndDoCallBack(sendSeq, sendInfoItem)
  if not sendSeq or not sendInfoItem then
    return false
  end
  if sendInfoItem.sendCount > 0 or 0 < sendInfoItem.sendOnlineStatus then
    log(bWriteLog and string.format("logic_profile:CheckIsReceiveAllAndDoCallBack %s invalid count: %s %s", sendSeq, sendInfoItem.sendCount, sendInfoItem.sendOnlineStatus))
    return false
  end
  local profileListValid = {}
  for _, v in ipairs(sendInfoItem.profileListValid) do
    if v.isInit then
      table.insert(profileListValid, v)
    end
  end
  if sendInfoItem.callback then
    local TimeUtil = require("client.common.time_util")
    local procStartTime = TimeUtil.GetMiliseconds()
    local utility = require("common.utility")
    xpcall(sendInfoItem.callback, utility.ErrorMessageHandler, profileListValid)
    if not Client.IsShipping() then
      local processTime = TimeUtil.GetMiliseconds() - procStartTime
      if 100 < processTime then
        log(bWriteLog and string.format("[TimeTracer][logic_profile]batch_get_bin_profile_rsp callback proccess module[%s] takes %s ms", sendInfoItem.moduleId, processTime))
      end
    end
  end
  xpcall(function()
    EventSystem:postEvent(EVENTTYPE_PROFILE, EVENTID_PROFILE_MSG, profileListValid)
  end, function()
    log_error("OnBatchGetProfileRsp event handle error")
  end)
  self.dicSendMap[sendSeq] = nil
  return true
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
return class(CModuleBase, nil, logic_profile)