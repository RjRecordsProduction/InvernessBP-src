local UnknowPassBuyActSystem = {
  MAX_GROUP_NUM = 20,
  localGroupList = nil,
  recommendList = {},
  inviteList = nil,
  inviterList = {},
  friendInviterList = {},
  myGroupInfo = nil,
  allGroupInfoList = {},
  detailInfoList = {},
  lastGetProfileTime = 0,
  hasNewInvite = false,
  hasNewReward = false,
  joinGroupID = 0,
  openDetailId = 0,
  localInviteGroupList = nil,
  isNewJoin = false,
  from = 0,
  C_InviteMinCnt = 5,
  C_InviteMinPercentage = 0.25,
  C_InviteEffectLoopCnt = 10,
  RPRecommendList = {},
  bIsReqRecommendData = true
}
function UnknowPassBuyActSystem.OnLogin(bReLogin)
  if not bReLogin then
    EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, UnknowPassBuyActSystem.OnActivityDataChange)
    EventSystem:registEvent(EVENTTYPE_CHAT, EVENTID_CHAT_OPEN_FRIEND, UnknowPassBuyActSystem.HideInviteReddot)
    UnknowPassBuyActSystem.myGroupInfo = nil
    UnknowPassBuyActSystem.allGroupInfoList = {}
    UnknowPassBuyActSystem.detailInfoList = {}
    UnknowPassBuyActSystem.inviteList = nil
    UnknowPassBuyActSystem.inviterList = {}
    UnknowPassBuyActSystem.friendInviterList = {}
    UnknowPassBuyActSystem.hasNewInvite = false
    UnknowPassBuyActSystem.hasNewReward = false
    UnknowPassBuyActSystem.RPRecommendList = {}
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local info = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUnknowPassBuyActInviteReddot)
    if info then
      UnknowPassBuyActSystem.hasNewInvite = info.hasNewInvite
    end
  end
end
function UnknowPassBuyActSystem.OpenBuyActUI()
  if UnknowPassBuyActSystem.GetNeedShowEntrance() == false then
    ShowNotice(4002)
    return
  end
  local ui_jump_manager = require("client.common.uibase.ui_jump_manager")
  ui_jump_manager.OpenJumpModule(BP_ENUM_MODULE_BUY_UPASS_ACT, {})
end
function UnknowPassBuyActSystem.OnActivityDataChange()
  UnknowPassBuyActSystem.GetNeedShowReddot()
end
function UnknowPassBuyActSystem.GetNeedShowReddot(skipUpdate)
  local bRedDot = false
  local IsBuyElite = UnknowPassSystem.IsInCurSession and UnknowPassSystem.IsBuyElite
  UnknowPassBuyActSystem.hasNewReward = false
  local awardList = {}
  if IsBuyElite then
    local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
    local activityData = ActivityNewSystem.GetActivityByType(ActivityType.ACTIVITY_TYPE_RP_GROUPBUY)
    if activityData then
      for k, v in pairs(activityData.List) do
        if v.Status == 1 then
          local groupID = UnknowPassBuyActSystem.GetPlayerGroupID(DataMgr.roleData.uid)
          if groupID and groupID ~= 0 then
            UnknowPassBuyActSystem.hasNewReward = true
            break
          end
        end
      end
    end
    activityData = ActivityNewSystem.GetActivityByType(ActivityType.BUY_UPASS_ACTIVITY)
    if activityData then
      for k, v in pairs(activityData.List) do
        if v.Status == 1 then
          UnknowPassBuyActSystem.hasNewReward = true
          break
        end
      end
    end
  end
  log(bWriteLog and "UnknowPassBuyActSystem.GetNeedShowReddot hasNewReward = " .. tostring(UnknowPassBuyActSystem.hasNewReward) .. " || hasNewInvite = " .. tostring(UnknowPassBuyActSystem.hasNewInvite))
  bRedDot = UnknowPassBuyActSystem.hasNewReward
  if not skipUpdate then
    LobbySystem.LobbyRedPointUpdate(BP_ENUM_MODULE_BUY_UPASS_ACT, bRedDot)
  end
  return bRedDot, awardList
end
function UnknowPassBuyActSystem.IsHaveAwards()
  return UnknowPassBuyActSystem.hasNewReward
end
function UnknowPassBuyActSystem.HideInviteReddot()
  log(bWriteLog and "UnknowPassBuyActSystem.HideInviteReddot")
  if UnknowPassBuyActSystem.hasNewInvite then
    UnknowPassBuyActSystem.hasNewInvite = false
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    PlayerPrefsSystem.SaveTableToFile_N({hasNewInvite = false}, PlayerPrefsSystem.ePlayerPrefsType.eUnknowPassBuyActInviteReddot)
    local UpassHandle = require("client.network.Protocol.UpassHandle")
    UpassHandle.send_remove_invite_red_point_req()
    UnknowPassBuyActSystem.GetNeedShowReddot()
    EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_BUYUPASS_REDDOT)
  end
end
function UnknowPassBuyActSystem.GetNeedShowEntrance()
  local TimeUtil = require("client.common.time_util")
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local info = ActivityNewSystem.GetActivityByType(ActivityType.ACTIVITY_TYPE_RP_GROUPBUY)
  if info then
    local endTime = TimeUtil.TimeStringToUnixstamp(info.BackupParam2)
    if endTime >= TimeUtil.GetServerTimeInSec() then
      return true
    else
      local groupID = UnknowPassBuyActSystem.GetPlayerGroupID(DataMgr.roleData.uid)
      if groupID and groupID ~= 0 then
        return true
      else
        log(bWriteLog and "UnknowPassBuyActSystem.GetNeedShowEntrance Not Join ,endTime = " .. tostring(info.BackupParam2))
        return false
      end
    end
  else
    log(bWriteLog and "UnknowPassBuyActSystem.GetNeedShowEntrance Act Not Open")
  end
  return false
end
function UnknowPassBuyActSystem.OpenBuyActUIFromInviteURL(groupID)
  log(bWriteLog and "UnknowPassBuyActSystem.OpenBuyActUIFromInviteURL groupID = " .. groupID)
  if UnknowPassBuyActSystem.GetNeedShowEntrance() == false then
    ShowNotice(4002)
    return
  end
  local localGroupList = UnknowPassBuyActSystem.GetGroupIDInLocal()
  table.insert(localGroupList, groupID)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N({
    season = UnknowPassSystem.Season,
    groupList = localGroupList
  }, PlayerPrefsSystem.ePlayerPrefsType.eUnknowPassBuyActGroupID)
  local ui_jump_manager = require("client.common.uibase.ui_jump_manager")
  ui_jump_manager.OpenJumpModule(BP_ENUM_MODULE_BUY_UPASS_ACT, {groupID = groupID})
end
function UnknowPassBuyActSystem.GetPlayerGroupID(uid)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(uid)
  if profile then
    return profile.rp_groupbuy_leader_uid
  elseif uid == DataMgr.roleData.uid then
    local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
    local info = ActivityNewSystem.GetActivityByType(ActivityType.ACTIVITY_TYPE_RP_GROUPBUY)
    if info and info.other and info.other.id ~= 0 then
      return info.other.id
    end
  else
    log(bWriteLog and "UnknowPassBuyActSystem.GetPlayerGroupID profile is not exist, id = " .. tostring(uid))
  end
  return 0
end
function UnknowPassBuyActSystem.GetGroupIDInLocal()
  if UnknowPassBuyActSystem.localGroupList then
    return UnknowPassBuyActSystem.localGroupList
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local info = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUnknowPassBuyActGroupID)
  if info and info.season == UnknowPassSystem.Season and info.groupList then
    UnknowPassBuyActSystem.localGroupList = info.groupList
  else
    UnknowPassBuyActSystem.localGroupList = {}
  end
  return UnknowPassBuyActSystem.localGroupList
end
function UnknowPassBuyActSystem.GetInviterList()
  return UnknowPassBuyActSystem.inviterList
end
function UnknowPassBuyActSystem.GetInviteList()
  if UnknowPassBuyActSystem.inviteList then
    return UnknowPassBuyActSystem.inviteList
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local info = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUnknowPassBuyActInviteList)
  log_tree("UnknowPassBuyActSystem.GetInviteList ", info)
  if info and info.season == UnknowPassSystem.Season and info.inviteList then
    UnknowPassBuyActSystem.inviteList = {}
    for i, j in pairs(info.inviteList) do
      UnknowPassBuyActSystem.inviteList[tonumber(i)] = j
    end
  else
    UnknowPassBuyActSystem.inviteList = {}
  end
  return UnknowPassBuyActSystem.inviteList
end
function UnknowPassBuyActSystem.InviteListAdd(uid)
  local inviteList = UnknowPassBuyActSystem.GetInviteList()
  inviteList[uid] = true
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N({
    season = UnknowPassSystem.Season,
      }, PlayerPrefsSystem.ePlayerPrefsType.eUnknowPassBuyActInviteList)
end
function UnknowPassBuyActSystem.InviteListAddAll()
  local inviteList = UnknowPassBuyActSystem.GetInviteList()
  if DataMgr.corpsInfo.id ~= 0 then
    inviteList[DataMgr.corpsInfo.id] = true
  end
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local friendList = LogicFriend.GetFriendList(true)
  for k, v in pairs(friendList) do
    inviteList[v.uid] = true
  end
  local RPRecommendList = UnknowPassBuyActSystem.RPRecommendList
  for i, uid in ipairs(RPRecommendList) do
    inviteList[uid] = true
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N({
    season = UnknowPassSystem.Season,
      }, PlayerPrefsSystem.ePlayerPrefsType.eUnknowPassBuyActInviteList)
end
function UnknowPassBuyActSystem.ConvertServerData(data, uid_list)
  local myGroupID = UnknowPassBuyActSystem.GetPlayerGroupID(DataMgr.roleData.uid)
  log(bWriteLog and "UnknowPassBuyActSystem.ConvertServerData myGroupID = " .. tostring(myGroupID))
  log_tree("UnknowPassBuyActSystem.ConvertServerData data = ", data)
  log_tree("UnknowPassBuyActSystem.ConvertServerData uid_list = ", uid_list)
  for i, j in pairs(data) do
    if i == tonumber(myGroupID) then
      if j.leader_uid == nil or tonumber(j.leader_uid) == 0 then
        UnknowPassBuyActSystem.InitMyGroupData()
      end
      UnknowPassBuyActSystem.myGroupInfo = UnknowPassBuyActSystem.myGroupInfo or {}
      UnknowPassBuyActSystem.myGroupInfo.groupID = i
      UnknowPassBuyActSystem.myGroupInfo.leaderUid = j.leader_uid or 0
      UnknowPassBuyActSystem.myGroupInfo.count = j.total_num or 0
      UnknowPassBuyActSystem.myGroupInfo.totalLevel = j.total_level or 0
      if i ~= 0 then
        UnknowPassBuyActSystem.HideInviteReddot()
      end
    elseif j.leader_uid == nil then
      UnknowPassBuyActSystem.allGroupInfoList[i] = nil
    else
      local info = {}
      info.leaderUid = j.leader_uid
      info.count = j.total_num
      info.totalLevel = j.total_level
      UnknowPassBuyActSystem.allGroupInfoList[i] = info
    end
  end
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_GROUP_BUY_REFRESH)
end
function UnknowPassBuyActSystem.InitMyGroupData()
  UnknowPassBuyActSystem.myGroupInfo = {}
  UnknowPassBuyActSystem.myGroupInfo.groupID = 0
  UnknowPassBuyActSystem.myGroupInfo.leaderUid = 0
  UnknowPassBuyActSystem.myGroupInfo.leaderName = ""
  UnknowPassBuyActSystem.myGroupInfo.leaderIcon = ""
  UnknowPassBuyActSystem.myGroupInfo.count = 0
  UnknowPassBuyActSystem.myGroupInfo.totalLevel = 0
  UnknowPassBuyActSystem.myGroupInfo.avatar_box_id = 0
end
function UnknowPassBuyActSystem.GetMyGroupData()
  if UnknowPassBuyActSystem.myGroupInfo == nil then
    UnknowPassBuyActSystem.InitMyGroupData()
  end
  return UnknowPassBuyActSystem.myGroupInfo
end
function UnknowPassBuyActSystem.SetProfileGroupID(groupID)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(DataMgr.roleData.uid)
  if profile then
    profile.rp_groupbuy_leader_uid = groupID
  end
end
function UnknowPassBuyActSystem.RefreshInviterList()
  UnknowPassBuyActSystem.inviterList = {}
  local needDetailList = {}
  for i, j in pairs(UnknowPassBuyActSystem.friendInviterList) do
    UnknowPassBuyActSystem.inviterList[j] = true
    if UnknowPassBuyActSystem.allGroupInfoList[j] == nil then
      table.insert(needDetailList, j)
    end
  end
  log_tree("UnknowPassBuyActSystem.RefreshInviterList friendInviterList", UnknowPassBuyActSystem.friendInviterList)
  if next(needDetailList) then
    log_tree("UnknowPassBuyActSystem.RefreshInviterList needDetailList", needDetailList)
    local UpassHandle = require("client.network.Protocol.UpassHandle")
    UpassHandle.send_get_rp_groupbuy_simple_info_req(needDetailList)
  else
    EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_GROUP_BUY_REFRESH)
  end
  if #UnknowPassBuyActSystem.inviterList > 0 then
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetFriendProfiles(Enum_PROFILE_REPORT_CFG.RPACT_FRIEND, UnknowPassBuyActSystem.inviterList)
  end
end
function UnknowPassBuyActSystem.OpenDetail(openId, from)
  log(bWriteLog and "UnknowPassBuyActSystem.OpenDetail openID = " .. tostring(openId))
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  if PassDataSystem.ShowRpGroupDownloadTips() then
    return
  end
  UnknowPassBuyActSystem.openDetailId = openId
  UnknowPassBuyActSystem.  local UpassHandle = require("client.network.Protocol.UpassHandle")
  UpassHandle.send_get_rp_groupbuy_info_req(openId)
end
function UnknowPassBuyActSystem.GetNewMessage()
  local nMyGroupID = UnknowPassBuyActSystem.GetPlayerGroupID(DataMgr.roleData.uid)
  if nMyGroupID and 0 < nMyGroupID then
    log(bWriteLog and "UnknowPassBuyActSystem.GetNewMessage  " .. tostring(nMyGroupID))
    return
  end
  UnknowPassBuyActSystem.hasNewInvite = true
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N({hasNewInvite = true}, PlayerPrefsSystem.ePlayerPrefsType.eUnknowPassBuyActInviteReddot)
  UnknowPassBuyActSystem.GetNeedShowReddot()
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_GROUP_BUY_REFRESH)
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_BUYUPASS_REDDOT)
end
function UnknowPassBuyActSystem.CheckShowInviteDot(groupID)
end
function UnknowPassBuyActSystem.CheckHaveInvite()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local buyUpassActivity = ActivityNewSystem.GetActivityByType(ActivityType.ACTIVITY_TYPE_RP_GROUPBUY)
  if buyUpassActivity then
    local unknowpassHandle = require("client.network.Protocol.UpassHandle")
    unknowpassHandle.send_get_invite_red_point_req()
  end
end
function UnknowPassBuyActSystem.SaveRPRecommendList(uid_list)
  UnknowPassBuyActSystem.RPRecommendList = uid_list
  log_tree("SaveRPRecommendListSaveRPRecommendList", UnknowPassBuyActSystem.RPRecommendList)
end
function UnknowPassBuyActSystem.ReceiveFromRedHot()
  local bRet = false
  local IsBuyElite = UnknowPassSystem.IsInCurSession and UnknowPassSystem.IsBuyElite
  if IsBuyElite then
    local ActivityHandler = require("client.network.Protocol.ActivityHandler")
    local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
    local activityData = ActivityNewSystem.GetActivityByType(ActivityType.ACTIVITY_TYPE_RP_GROUPBUY)
    if activityData then
      for k, v in pairs(activityData.List) do
        if v.Status == 1 then
          local groupID = UnknowPassBuyActSystem.GetPlayerGroupID(DataMgr.roleData.uid)
          if groupID and groupID ~= 0 then
            ActivityHandler.send_take_activity_award_req(v.ID, 1)
            bRet = true
            break
          end
        end
      end
    end
    activityData = ActivityNewSystem.GetActivityByType(ActivityType.BUY_UPASS_ACTIVITY)
    if activityData then
      for k, v in pairs(activityData.List) do
        if v.Status == 1 then
          ActivityHandler.send_take_activity_award_req(v.ID, 1)
          bRet = true
          break
        end
      end
    end
  end
  return bRet
end
function UnknowPassBuyActSystem.ConvertBuyNumToShowNum(numTmp)
  local resultNum = numTmp
  if type(numTmp) == "number" then
    local oriStr = "0,000,000"
    local inter = math.modf(numTmp)
    local strNum = tostring(inter)
    local newStr = ""
    local numLen = string.len(strNum)
    local count = 0
    for i = numLen, 1, -1 do
      if count % 3 == 0 and count ~= 0 then
        newStr = string.format("%s,%s", string.sub(strNum, i, i), newStr)
      else
        newStr = string.format("%s%s", string.sub(strNum, i, i), newStr)
      end
      count = count + 1
    end
    local strLen = #newStr
    local oriLen = #oriStr
    if strLen <= oriLen then
      resultNum = string.sub(oriStr, 1, oriLen - strLen) .. newStr
    else
      resultNum = newStr
    end
  end
  return resultNum
end
return UnknowPassBuyActSystem