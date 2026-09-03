local super_list = require("common.super_list")
local LogicFriend = {
  IsReqOnlineAndGroupInfo = false,
  GetAllFriendStamp = 0,
  GetAllFriendCD = 120,
  Intimacy_CanShowToBuild = 70,
  Friend_Intimacy_Threshold = 100,
  Friend_Intimacy_MaxCount = 30,
  Friend_Max_Num = 300,
  OpenFrom = 0,
  OpenFromUID = 0,
  JumpToUID = 0,
  JumpToType = 1,
  CurTab = 0,
  ReserveBack2Lobby = {},
  ignoreFriendTime = false,
  InviteBySMS = ShareSource.SMS,
  InviteByLine = ShareSource.Line,
  InviteByMore = ShareSource.More,
  InviteByWhatsapp = ShareSource.Whatsapp,
  InviteByFacebook = ShareSource.Facebook,
  InviteByMessenger = ShareSource.Messenger,
  teamState = 0,
  rejectInviteFreeFriendTime = 0,
  bShouldShowFriendBanned = false,
  FriendTopList = {},
  del_friend_timer = nil,
  loginchannel_icon_path = {
    [ShareSource.Facebook] = "/Game/UMG/Texture_200/Atlas/LoginUI/Frames/Login_FB_png.Login_FB_png",
    [ShareSource.Twitter] = "/Game/UMG/Texture_200/Atlas/LoginUI/Frames/Login_TW_png.Login_TW_png",
    [ShareSource.GooglePlay] = "/Game/UMG/Texture_200/Atlas/LoginUI/Frames/Login_GG_png.Login_GG_png",
    [ShareSource.Discord] = "/Game/UMG/Texture_200/Atlas/LoginUI/Frames/Login_discord_png.Login_discord_png",
    [ShareSource.Messenger] = "/Game/UMG/Texture/Atlas/MessageBoxTipsUI/Frames/CHAT_btn_FBmessage_png.CHAT_btn_FBmessage_png"
  },
  ImageInviteTintColor = FSlateColor(FLinearColor(0, 0, 0, 0.698039))
}
local TimeUtil = require("client.common.time_util")
local local IntimacyUtils = require("client.slua.logic.friend.Intimacy.IntimacyUtils")
LogicFriend.TabType = {
  Platform = 0,
  Inner = 1,
  RecentTeammate = 2,
  Intimacy = 3,
  Search = 5,
  RecentLike = 7,
  Apply = 8,
  NewbieFriendsRecommend = 9,
  ReturnFriendsRecommend = 10,
  RoleInfoCard = 11,
  ChatWorldSocialCard = 12,
  ChatTopic1SocialCard = 13,
  ChatTopic2SocialCard = 14,
  ChatCorpsSocialCard = 15,
  QRCode = 16,
  PlanPHPlayerList = 17,
  PlanPHHomeDetailLobby = 18,
  PlanPHHomeDetailIngame = 19,
  PlanPHHomePigeonVisitor = 20,
  WOWResult = 21,
  MainCityInfoCard = 22,
  ReturnFriendsChatChannel = 24
}
LogicFriend.OpenFromType = {Lobby = 0, PersonSpaceRelationShip = 1}
LogicFriend.RelationChangeType = {RelationType = 1, CustomName = 2}
LogicFriend.RelationApplyOp = {Agree = 1, Refuse = 2}
local friendDataMap = {}
local innerList = super_list.Create()
local platformList = super_list.Create()
local recommendedDataList = {}
local recentTeammateMap = {}
local strangerRecallMap = {}
local intimacyList = {}
function LogicFriend.Init()
  EventSystem:registEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_PRE_SWITCH, LogicFriend.OnGameStateChange)
  EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_FRIEND, LogicFriend.OnJumpUrl)
  EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_ADD_FRIEND, LogicFriend.OnJumpUrl)
  EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_QUICKTEAM_MAIN, LogicFriend.OnJumpUrl)
  EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_FRIEND_APPLYLIST, LogicFriend.OnJumpUrl)
  EventSystem:registEvent(EVENTTYPE_APPLICATION_ACTIVE_STATE, EVENTID_APPLICATION_REACTIVATED, LogicFriend.OnApplicationReactivated)
  EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_INTIMACY_LEVEL_UP_SLAP, LogicFriend.OnIntimacyLevelUpSlap)
end
function LogicFriend.OnLogin()
  LogicFriend.ReqFriendData()
end
function LogicFriend.ResetData()
  friendDataMap = {}
  recentTeammateMap = {}
  innerList:ClearData()
  platformList:ClearData()
  recommendedDataList = {}
  strangerRecallMap = {}
  intimacyList = {}
  LogicFriend.IsReqOnlineAndGroupInfo = false
  LogicFriend.OpenFrom = 0
  LogicFriend.OpenFromUID = 0
  LogicFriend.JumpToUID = 0
  LogicFriend.GetAllFriendStamp = 0
  LogicFriend.ReserveBack2Lobby = {}
  LogicFriend.rejectInviteFreeFriendTime = 0
  LogicFriend.bShouldShowFriendBanned = false
  LogicFriend.IntimacyLevelUpData = {}
  LogicFriend._path = nil
end
function LogicFriend.OnJumpUrl(eventType, eventID, vars)
  if eventID == BP_ENUM_MODULE_FRIEND then
    local LogicTeamUpSideBar = require("client.slua.logic.lobby.logic_teamup_side_bar")
    local tab = tonumber(vars and vars.tab)
    LogicTeamUpSideBar.ShowTeamUpSideBar(LogicTeamUpSideBar.ENUM_OPEN_FROM.LOBBY, tab)
  elseif eventID == BP_ENUM_MODULE_ADD_FRIEND then
    UIManager.ShowUI(UIManager.UI_Config.friend_new_search)
  elseif eventID == BP_ENUM_MODULE_FRIEND_APPLYLIST then
    local FriendApplyHandler = require("client.network.Protocol.FriendApplyHandler")
    FriendApplyHandler.send_get_addfriend_reqlist_req()
    UIManager.ShowUI(UIManager.UI_Config.friend_applylist)
  elseif eventID == BP_ENUM_MODULE_QUICKTEAM_MAIN then
    local squad_id = vars and vars.squadID
    UIManager.ShowUI(UIManager.UI_Config.TeamQuick_Main_UIBP, squad_id)
  end
end
function LogicFriend.ReqFriendData()
  log(bWriteLog and "LogicFriend.ReqFriendData")
  local FriendHandler = require("client.network.Protocol.FriendHandler")
  local FriendBlacklistHandler = require("client.network.Protocol.FriendBlacklistHandler")
  local FriendApplyHandler = require("client.network.Protocol.FriendApplyHandler")
  local FlashTeamHandler = require("client.network.Protocol.FlashTeamHandler")
  LogicFriend.IsReqOnlineAndGroupInfo = true
  LogicFriend.get_all_friendlist_req(true)
  FriendBlacklistHandler.send_get_black_list_req()
  FriendBlacklistHandler.send_get_match_black_list_req()
  FriendApplyHandler.send_get_addfriend_reqlist_req()
  LogicFriend.get_intimacy_relation_req(true)
  FriendHandler.send_get_friend_status_detail_req()
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  logic_flash_match_team:ReqPreFetchApplyCnt()
  logic_flash_match_team:ReqInviteData()
  local logic_poke = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_poke)
  logic_poke:send_daily_poke_list_req(true)
  logic_poke:send_no_fri_poke_list_req(true)
end
function LogicFriend.OnGameStateChange(eventType, eventID, vars)
  log(bWriteLog and "LogicFriend.OnGameStateChange " .. vars.current .. "  " .. vars.pre)
  if vars.pre == GameStatus.Fighting and vars.current == GameStatus.Lobby then
    LogicFriend.IsReqOnlineAndGroupInfo = true
    LogicFriend.get_all_friendlist_req(true)
    local logic_poke = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_poke)
    logic_poke:send_daily_poke_list_req(true)
    logic_poke:send_no_fri_poke_list_req(true)
  elseif vars.current == GameStatus.Login then
    LogicFriend.ResetData()
  end
end
local screenInput, timer
function LogicFriend.OnApplicationReactivated()
  if GameStatus.IsInLobbyOrMainCity() then
    local logic_friend_spk_fb = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_spk_fb)
    if not logic_friend_spk_fb:NeedShowRefresh() then
      LogicFriend.get_all_friendlist_req()
    end
    local logic_poke = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_poke)
    logic_poke:send_daily_poke_list_req()
    logic_poke:send_no_fri_poke_list_req()
  end
end
local SortFunc = function(a, b)
  if a == nil or b == nil or a.online == nil or b.online == nil then
    return false
  end
  local PlayerStatusUtil = require("client.slua.logic.player_status.PlayerStatusUtil")
  if a.online == b.online then
    if a.teamState == nil or b.teamState == nil then
      return false
    end
    local teamStateA = a.teamState
    local teamStateB = b.teamState
    if PlayerStatusUtil.IsFree(a) then
      teamStateA = -1
    end
    if PlayerStatusUtil.IsFree(b) then
      teamStateB = -1
    end
    if teamStateA == teamStateB then
      if a.intimacy == nil or b.intimacy == nil then
        return false
      end
      return a.intimacy > b.intimacy
    else
      return teamStateA < teamStateB
    end
  else
    return a.online > b.online
  end
end
local SortIDFunc = function(uidA, uidB)
  if not friendDataMap[uidA] then
    return false
  end
  if not friendDataMap[uidB] then
    return false
  end
  local a = friendDataMap[uidA]
  local b = friendDataMap[uidB]
  if a.online == nil or b.online == nil then
    return false
  end
  local PlayerStatusUtil = require("client.slua.logic.player_status.PlayerStatusUtil")
  if a.online == b.online then
    if a.teamState == nil or b.teamState == nil then
      return false
    end
    local teamStateA = a.teamState
    local teamStateB = b.teamState
    if PlayerStatusUtil.IsFree(a) then
      teamStateA = -1
    end
    if PlayerStatusUtil.IsFree(b) then
      teamStateB = -1
    end
    if teamStateA == teamStateB then
      if a.intimacy == nil or b.intimacy == nil then
        return false
      end
      if a.intimacy == b.intimacy then
        if a.level == nil or b.level == nil then
          return false
        end
        if a.level == b.level then
          return a.lastOnlineTime > b.lastOnlineTime
        else
          return a.level > b.level
        end
      else
        return a.intimacy > b.intimacy
      end
    else
      return teamStateA < teamStateB
    end
  else
    return a.online > b.online
  end
end
local SortByIntimacy = function(uidA, uidB)
  if not friendDataMap[uidA] then
    return false
  end
  if not friendDataMap[uidB] then
    return false
  end
  local a = friendDataMap[uidA]
  local b = friendDataMap[uidB]
  if a.intimacy == nil or b.intimacy == nil then
    return false
  end
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profileA = logic_profile:GetLocalProfile(uidA)
  local profileB = logic_profile:GetLocalProfile(uidA)
  if not profileA or not profileB then
    return false
  end
  if a.intimacy == b.intimacy then
    return profileA.lastOnlineTime > profileB.lastOnlineTime
  else
    return a.intimacy > b.intimacy
  end
end
local SortByIntimacy2 = function(data1, data2)
  return data1.intimacy > data2.intimacy
end
local SortRecentFunc = function(a, b)
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  local statusA = PlayerStatusMgr:GetStatusData(a.uid)
  local statusB = PlayerStatusMgr:GetStatusData(b.uid)
  if not statusA or not statusB then
    return false
  end
  local onlineA = statusA.online or 0
  local onlineB = statusB.online or 0
  if onlineA == onlineB then
    if a.endtime == nil or b.endtime == nil then
      return false
    end
    if a.endtime == b.endtime then
      local PlayerStatusUtil = require("client.slua.logic.player_status.PlayerStatusUtil")
      local teamStateA = a.teamState
      local teamStateB = b.teamState
      if teamStateA == nil or teamStateB == nil then
        return false
      end
      if PlayerStatusUtil.IsFree(a) then
        teamStateA = -1
      end
      if PlayerStatusUtil.IsFree(b) then
        teamStateB = -1
      end
      if teamStateA == teamStateB then
        if a.isRecaller == b.isRecaller then
          if a.intimacy == nil or b.intimacy == nil then
            return false
          end
          if a.intimacy == b.intimacy then
            if a.level == nil or b.level == nil then
              return false
            end
            if a.level == b.level then
              return a.lastOnlineTime > b.lastOnlineTime
            else
              return a.level > b.level
            end
          else
            return a.intimacy > b.intimacy
          end
        else
          return a.isRecaller > b.isRecaller
        end
      else
        return teamStateA < teamStateB
      end
    else
      return a.endtime > b.endtime
    end
  else
    return onlineA > onlineB
  end
end
local SortRelationFunc = function(a, b)
  if a.relation == nil or b.relation == nil then
    return false
  end
  return a.relation < b.relation
end
local SortIntimacyFunc = function(a, b)
  if a.stateSortPriority == b.stateSortPriority then
    if a.relationSortPriority == nil or b.relationSortPriority == nil then
      return false
    end
    if a.relationSortPriority == b.relationSortPriority then
      if a.intimacy == nil or b.intimacy == nil then
        return false
      end
      return a.intimacy > b.intimacy
    else
      return a.relationSortPriority > b.relationSortPriority
    end
  else
    return a.stateSortPriority > b.stateSortPriority
  end
end
local SortSearchFunc = function(a, b)
  if a.sortValue ~= b.sortValue then
    return a.sortValue > b.sortValue
  end
  return a.uid < b.uid
end
function LogicFriend.SortInnerList()
  log(bWriteLog and "LogicFriend.SortInnerList")
  local logic_friend_blacklist = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_blacklist)
  local blackMap = logic_friend_blacklist:GetBlackMap()
  for i = #innerList, 1, -1 do
    if blackMap[innerList[i]] then
      innerList:RemoveItem(i)
    end
  end
  innerList:Sort(SortIDFunc)
end
function LogicFriend.AddFriendData(uid)
  local data = friendDataMap[uid] or {}
  data.  data.intimacy = 0
  data.create_time = TimeUtil.GetServerTimeInSec()
  friendDataMap[uid] = data
  local list = {uid}
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetFriendProfiles(Enum_PROFILE_REPORT_CFG.FRIEND_ADD, list)
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  PlayerStatusMgr:GetOrReqStatusData(ENUM_BATCH_GET_GROUP_AND_ONLINE.AddFriend, list, function(infos)
    for k, v in pairs(infos) do
      EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_ADD_DELETE_FRIEND, k, true)
    end
  end)
end
function LogicFriend.AddInnerFriend(uid)
  uid = tonumber(uid)
  local logic_friend_blacklist = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_blacklist)
  logic_friend_blacklist:RemoveBlacklist(uid)
  local logic_friend_apply = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_apply)
  logic_friend_apply:DelApplyList(uid)
  local logic_friend_search = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_search)
  local bChanged = logic_friend_search:RemoveSearchList(uid)
  local logic_wedding_friend_search = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_wedding_friend_search)
  logic_wedding_friend_search:RemoveSearchList(uid)
  if bChanged then
    EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_SEARCHLIST_CHANGE)
  end
  EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_APPLYLIST_CHANGE)
  if LogicFriend.IsInnerFriend(uid) then
    return
  end
  innerList:AppendItem(uid)
  LogicFriend.AddFriendData(uid)
end
function LogicFriend.AddSource(uid, source)
  if uid and source then
    local data = friendDataMap[uid]
    if data then
      data.      data.add_from = source
      friendDataMap[uid] = data
    end
  end
end
function LogicFriend.AddIntimacy(uid, state, param, intimacy, awardlevel, createtime, norefresh, ignoreHas)
  local data = {}
  data.  data.  data.  if intimacy then
    data.    data.    data.    if friendDataMap[uid] then
      friendDataMap[uid].      friendDataMap[uid].      friendDataMap[uid].    end
  else
    data.intimacy = LogicFriend.GetInnerFriendIntimacy(uid)
  end
  if state == 3 then
    local InnerFriendIntimacy = LogicFriend.GetInnerFriendIntimacy(uid)
    if InnerFriendIntimacy and InnerFriendIntimacy >= LogicFriend.Friend_Intimacy_Threshold then
      state = 0
      param = InnerFriendIntimacy
    end
  end
  if state == 2 and param then
    local IntimacyConst = require("client.slua.logic.friend.Intimacy.IntimacyConst")
    local maxType = IntimacyConst.EIntimacyType.Max
    if param > maxType then
      log(bWriteLog and string.format("LogicFriend.AddIntimacy relationType not exit: %d, max type=%d", param, maxType))
      return
    end
  end
  local has = false
  if not ignoreHas then
    for i = 1, #intimacyList do
      if intimacyList[i].uid == uid then
        intimacyList[i] = data
        has = true
        break
      end
    end
  end
  if not has then
    table.insert(intimacyList, data)
  end
  if not norefresh then
    EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_INTIMACY_CHANGE)
  end
end
function LogicFriend.ChangeList(uid, awardlevel)
  for i = 1, #intimacyList do
    if intimacyList[i].uid == uid then
      intimacyList[i].      break
    end
  end
end
function LogicFriend.DeleteInnerFriend(friUid, bSkipPostEvent)
  local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
  log(bWriteLog and "LogicFriend.DeleteFriend" .. tostring(friUid))
  local isPlatFriend = false
  for i = #platformList, 1, -1 do
    if platformList[i] == friUid then
      isPlatFriend = true
      break
    end
  end
  if not isPlatFriend then
    friendDataMap[friUid] = nil
  elseif friendDataMap[friUid] then
    friendDataMap[friUid].intimacy = 0
    friendDataMap[friUid].remark = nil
    local data = {}
    data.uid = friUid
    data.intimacy = 0
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    logic_profile:ModifyFriendSubData(data)
  end
  for i = #innerList, 1, -1 do
    if innerList[i] == friUid then
      innerList:RemoveItem(i)
      break
    end
  end
  if PersonSpaceSystem.IntimacyPartnerData and PersonSpaceSystem.IntimacyPartnerData.partner_uid == friUid then
    PersonSpaceSystem.IntimacyPartnerData = {partner_uid = 0}
  end
  LogicFriend.DeleteIntimacyData(friUid)
  if not bSkipPostEvent then
    EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_ADD_DELETE_FRIEND, friUid, false)
  end
  local logic_share_bag_team_util = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_share_bag_team_util)
  logic_share_bag_team_util:UpdateAvailableShareBagCount()
  EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_SHARE_INFO_CHANGED)
end
function LogicFriend.DeleteIntimacyData(friUid)
  for i = #intimacyList, 1, -1 do
    if intimacyList[i].uid == friUid then
      local intimacy = LogicFriend.GetInnerFriendIntimacy(intimacyList[i].uid)
      if intimacy >= LogicFriend.Friend_Intimacy_Threshold then
        local data = intimacyList[i]
        data.state = 0
        data.param = intimacy
        intimacyList[i] = data
      else
        table.remove(intimacyList, 1)
      end
      EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_INTIMACY_CHANGE)
      break
    end
  end
  local logic_chat_channel_friend = require("client.slua.logic.lobby_chat.logic_chat_channel_friend")
  logic_chat_channel_friend.DeleteFriendBgID(tostring(friUid))
end
function LogicFriend.GetFriendData(uid)
  return friendDataMap[uid]
end
function LogicFriend.GetAllFriendData()
  return friendDataMap
end
function LogicFriend.GetRemark(uid)
  uid = tonumber(uid)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(uid)
  local name = ""
  if profile then
    name = profile.nickName
  end
  local NicknameColorManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NicknameColorManager)
  name = NicknameColorManager:ChangeTextColorByUID(name, uid)
  local friend = friendDataMap[uid]
  if friend and friend.remark and friend.remark ~= "" then
    name = LocUtil.LocalizeResFormat(34627, name, friend.remark)
  end
  return name
end
function LogicFriend.GetNamePure(uid)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(uid)
  local name = ""
  if profile then
    name = profile.nickName
  end
  return name
end
function LogicFriend.GetRemarkNamePure(uid)
  if type(uid) == "string" then
    uid = tonumber(uid)
  end
  local friend = friendDataMap[uid]
  local remark = ""
  if friend and friend.remark and friend.remark ~= "" then
    remark = friend.remark
  end
  return remark
end
function LogicFriend.GetFriendDataByNickName(nickName)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  for i, v in pairs(friendDataMap) do
    local profile = logic_profile:GetLocalProfile(v.uid)
    if profile and profile.nickName == nickName then
      return friendDataMap[i]
    end
  end
  return nil
end
function LogicFriend.GetPLatformList(bSort)
  local logic_friend_blacklist = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_blacklist)
  local blackMap = logic_friend_blacklist:GetBlackMap()
  for i = #innerList, 1, -1 do
    if blackMap[platformList[i]] then
      platformList:RemoveItem(i)
    end
  end
  if bSort then
    platformList:Sort(SortIDFunc)
  end
  return platformList
end
function LogicFriend.GetInnerList(bSort)
  if bSort then
    innerList:Sort(SortIDFunc)
  end
  return innerList
end
function LogicFriend.GetInnerListSortByIntimacy()
  innerList:Sort(SortByIntimacy)
  return innerList
end
function LogicFriend.GetIntimacyData(uid)
  for i, v in pairs(intimacyList) do
    if v.uid == uid then
      return v
    end
  end
  return nil
end
function LogicFriend.GetIntimacyList(bSort)
  if not bSort then
    return intimacyList
  end
  local statePriorityMap = {
    [0] = 1,
    [1] = 3,
    [2] = 2,
    [4] = 4
  }
  local relationPriorityMap = {
    [1] = 2,
    [2] = 4,
    [4] = 3
  }
  for i = 1, #intimacyList do
    intimacyList[i].stateSortPriority = statePriorityMap[intimacyList[i].state] or 0
    intimacyList[i].relation = intimacyList[i].state == 4 and intimacyList[i].param or 0
    intimacyList[i].relationSortPriority = relationPriorityMap[intimacyList[i].relation] or 1
    local friend = LogicFriend.GetFriendData(intimacyList[i].uid)
    if friend then
      intimacyList[i].intimacy = friend.intimacy
    end
  end
  table.sort(intimacyList, SortIntimacyFunc)
  return intimacyList
end
function LogicFriend.GetIntimacyHasBuildList()
  local list = {}
  for i = 1, #intimacyList do
    if intimacyList[i].state == 4 then
      table.insert(list, intimacyList[i])
    end
  end
  table.sort(list, SortByIntimacy2)
  return list
end
function LogicFriend.GetIntimacyHasBuildSortV2()
  local list = {}
  for i = 1, #intimacyList do
    if intimacyList[i].state == 4 then
      table.insert(list, intimacyList[i])
    end
  end
  table.sort(list, function(a, b)
    local isAPriority = a.param == 2 or a.param == 6
    local isBPriority = b.param == 2 or b.param == 6
    if isAPriority ~= isBPriority then
      return isAPriority
    end
    return a.intimacy > b.intimacy
  end)
  return list
end
function LogicFriend.GetIntimacyCanBePartnerList()
  local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
  local list = {}
  for i = 1, #intimacyList do
    if intimacyList[i].state == 4 and intimacyList[i].intimacy >= PersonSpaceSystem.PartnerIntimacyLimit then
      table.insert(list, intimacyList[i])
    end
  end
  table.sort(list, SortByIntimacy2)
  return list
end
function LogicFriend.GetIntimacyCanBuildList()
  local list = {}
  for i = #innerList, 1, -1 do
    if LogicFriend.GetInnerFriendIntimacy(innerList[i]) >= LogicFriend.Intimacy_CanShowToBuild then
      local data = LogicFriend.GetIntimacyData(innerList[i])
      if not data or data.state == 0 or data.state == 1 then
        table.insert(list, innerList[i])
      end
    end
  end
  table.sort(list, SortByIntimacy)
  return list
end
function LogicFriend.GetLimitedIntimacyCanBuildList(maxNum)
  local list = {}
  local resultList = {}
  maxNum = maxNum or 3
  local curNum = 0
  local playerPrefs = require("client.logic.LogicPlayerPrefs.playerprefs")
  local viewedAvaliableIntimacy = playerPrefs.LoadFileToTable_N(playerPrefs.ePlayerPrefsType.IntemateRelationAvaliable)
  for i = #innerList, 1, -1 do
    if LogicFriend.GetInnerFriendIntimacy(innerList[i]) >= LogicFriend.Friend_Intimacy_Threshold then
      local data = LogicFriend.GetIntimacyData(innerList[i])
      if (not data or data.state == 0 or data.state == 2) and (not viewedAvaliableIntimacy or not viewedAvaliableIntimacy[innerList[i]]) then
        table.insert(list, innerList[i])
      end
    end
  end
  table.sort(list, SortByIntimacy)
  for i = 1, maxNum do
    table.insert(resultList, list[i])
  end
  return resultList
end
function LogicFriend.UpdateAvaliableIntimacyTb()
  local playerPrefs = require("client.logic.LogicPlayerPrefs.playerprefs")
  local viewedList = {}
  for i = #innerList, 1, -1 do
    if LogicFriend.GetInnerFriendIntimacy(innerList[i]) >= LogicFriend.Friend_Intimacy_Threshold then
      local data = LogicFriend.GetIntimacyData(innerList[i])
      if not data or data.state == 0 or data.state == 2 then
        viewedList[innerList[i]] = 1
      end
    end
  end
  playerPrefs.SaveTableToFile_N(viewedList, playerPrefs.ePlayerPrefsType.IntemateRelationAvaliable)
end
function LogicFriend.GetRelationRichText(relation)
  local IntimacyUtils = require("client.slua.logic.friend.Intimacy.IntimacyUtils")
  return IntimacyUtils.GetRelationRichText(relation)
end
function LogicFriend.GetRelationText(relation)
  local IntimacyUtils = require("client.slua.logic.friend.Intimacy.IntimacyUtils")
  return IntimacyUtils.GetRelationText(relation)
end
function LogicFriend.GetRelationCnt(relation)
  local cnt = 0
  for i = 1, #intimacyList do
    if intimacyList[i].state == 4 and relation == intimacyList[i].relation then
      cnt = cnt + 1
    end
  end
  return cnt
end
function LogicFriend.GetAllFriendList(bNeedOnline, nCnt, teamState)
  local list = {}
  local PlayerStatusEnum = require("client.slua.logic.player_status.PlayerStatusEnum")
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  for i, v in pairs(friendDataMap) do
    local profile = logic_profile:GetLocalProfile(i)
    if profile then
      local flag = true
      if bNeedOnline and v.online ~= 1 then
        log(bWriteLog and string.format("LogicFriend.GetAllFriendList not online, uid = %s", tostring(profile._uid)))
        flag = false
      end
      if teamState and v.teamState ~= teamState then
        log(bWriteLog and string.format("LogicFriend.GetAllFriendList v.teamState ~= %s, uid = %s", tostring(teamState), tostring(profile.uid)))
        flag = false
      end
      if teamState == PlayerStatusEnum.Enum_TeamState.Free and v.bHaveRecommendToTeam then
        log(bWriteLog and string.format("LogicFriend.GetAllFriendList bHaveRecommendToTeam == true, uid = ", tostring(profile.uid)))
        flag = false
      end
      if flag then
        table.insert(list, i)
      end
    end
    if nCnt and nCnt <= #list then
      break
    end
  end
  return list
end
function LogicFriend.SortNearList(uList)
  table.sort(uList, SortFunc)
  return uList
end
function LogicFriend.IsAtLeastOneOnlineAndFree()
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  local PlayerStatusUtil = require("client.slua.logic.player_status.PlayerStatusUtil")
  for _, uid in pairs(innerList) do
    local status = PlayerStatusMgr:GetStatusData(uid)
    if status and status.online == 1 and PlayerStatusUtil.IsIdleOrFree(status) or PlayerStatusUtil.IsMainCityIdle() then
      return true
    end
  end
  for _, uid in pairs(platformList) do
    local status = PlayerStatusMgr:GetStatusData(uid)
    if status and status.online == 1 and PlayerStatusUtil.IsIdleOrFree(status) or PlayerStatusUtil.IsMainCityIdle() then
      return true
    end
  end
  return false
end
function LogicFriend.GetFriendList(bSort)
  log(bWriteLog and "LogicFriend.SortFriendList")
  local list = {}
  local logic_friend_blacklist = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_blacklist)
  local blackMap = logic_friend_blacklist:GetBlackMap()
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  for i, v in pairs(friendDataMap) do
    if not blackMap[v.uid] then
      local data = v
      local status = PlayerStatusMgr:GetStatusData(v.uid)
      if status then
        data.online = status.online
        data.teamState = status.teamState
      else
        data.online = 0
        data.teamState = 0
      end
      table.insert(list, data)
    end
  end
  if bSort then
    table.sort(list, SortFunc)
  end
  return list
end
function LogicFriend.GetChangeRelationApplyList()
  local list = {}
  local logic_friend_blacklist = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_blacklist)
  local blackMap = logic_friend_blacklist:GetBlackMap()
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  for i, v in pairs(friendDataMap) do
    if not blackMap[v.uid] then
      local changeData = v.change_data and v.change_data[1]
      if changeData and changeData.state == 2 then
        table.insert(list, {
          uid = v.uid,
          relation = changeData.param,
                  })
      end
    end
  end
  log_tree(bWriteLog and "LogicFriend.GetChangeRelationApplyList", list)
  return list
end
function LogicFriend.GetChangeCustomNameApplyList()
  local list = {}
  local logic_friend_blacklist = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_blacklist)
  local blackMap = logic_friend_blacklist:GetBlackMap()
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  for i, v in pairs(friendDataMap) do
    if not blackMap[v.uid] then
      local changeData = v.change_data and v.change_data[2]
      if changeData and changeData.state == 2 then
        table.insert(list, {
          uid = v.uid,
          relation = changeData.param,
                  })
      end
    end
  end
  return list
end
function LogicFriend.GetRecentTeammateList()
  local list = {}
  local logic_friend_interact_record = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_interact_record)
  local interactMap = logic_friend_interact_record:GetRecentDataMap()
  for _uid, data in pairs(interactMap) do
    if tonumber(_uid) ~= tonumber(DataMgr.roleData.uid) then
      table.insert(list, {uid = _uid, interactData = data})
    end
  end
  for _, v in pairs(list) do
    local isFriend = LogicFriend.IsPlatFriend(v.uid)
    if isFriend == false then
      v.platName = ""
      v.remarks_name = ""
    end
  end
  return list
end
function LogicFriend.GetRecentTeammateIDList()
  local logic_friend_interact_record = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_interact_record)
  local interactMap = logic_friend_interact_record:GetRecentDataMap()
  local IDs = {}
  for uid, v in pairs(interactMap) do
    if tonumber(uid) ~= tonumber(DataMgr.roleData.uid) then
      table.insert(IDs, uid)
    end
  end
  return IDs
end
function LogicFriend.GetRecentTeammateData(uid)
  local logic_friend_interact_record = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_interact_record)
  local interactMap = logic_friend_interact_record:GetRecentDataMap()
  if interactMap[uid] then
    return interactMap[uid]
  end
  return nil
end
function LogicFriend.GetStrangerRecallList()
  local list = {}
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  for uid, info in pairs(strangerRecallMap) do
    if not LogicFriend.IsMyFriend(uid) then
      info.      info.intimacy = 0
      info.lastOnlineTime = logic_profile:GetLastOnlineTime(uid)
      table.insert(list, info)
    end
  end
  return list
end
function LogicFriend.GetFromIDByTab(type)
  local fromID = BP_ENUM_ADD_FRIEND_FROM_FRIEND_SEARCH
  if type == LogicFriend.TabType.RecentTeammate then
    fromID = BP_ENUM_ADD_FRIEND_FROM_FRIEND_RECENTTEAMMATE
  elseif type == LogicFriend.TabType.Search then
    local logic_friend_search = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_search)
    if logic_friend_search:IsFromRecommand() then
      fromID = BP_ENUM_ADD_FRIEND_FROM_RECOMMAND
    else
      fromID = BP_ENUM_ADD_FRIEND_FROM_FRIEND_SEARCH
    end
  elseif type == LogicFriend.TabType.Intimacy then
    fromID = BP_ENUM_ADD_FRIEND_FROM_FRIEND_RECRUITMENT
  elseif type == LogicFriend.TabType.ReturnFriendsRecommend then
    fromID = BP_ENUM_ADD_FRIEND_FROM_RETURN_RECOMMENDED
  elseif type == LogicFriend.TabType.NewbieFriendsRecommend then
    fromID = BP_ENUM_ADD_FRIEND_FROM_NEWBIE_FRIENDS_RECOMMENDED
  elseif type == LogicFriend.TabType.RoleInfoCard then
    fromID = BP_ENUM_ADD_FRIEND_FROM_ROLEINFO_CARD
  elseif type == LogicFriend.TabType.ChatWorldSocialCard then
    fromID = BP_ENUM_ADD_FRIEND_FROM_Chat_World_CARD
  elseif type == LogicFriend.TabType.ChatTopic1SocialCard then
    fromID = BP_ENUM_ADD_FRIEND_FROM_Chat_Topic1_CARD
  elseif type == LogicFriend.TabType.ChatTopic2SocialCard then
    fromID = BP_ENUM_ADD_FRIEND_FROM_Chat_Topic2_CARD
  elseif type == LogicFriend.TabType.ChatCorpsSocialCard then
    fromID = BP_ENUM_ADD_FRIEND_FROM_Chat_Corps_CARD
  elseif type == LogicFriend.TabType.QRCode then
    fromID = BP_ENUM_QR_CODE
  elseif type == LogicFriend.TabType.PlanPHHomePigeonVisitor then
    fromID = BP_ENUM_ADD_FRIEND_FROM_MANOR_PIGEON_VISITOR
  elseif type == LogicFriend.TabType.PlanPHHomeDetailLobby then
    fromID = BP_ENUM_ADD_FRIEND_FROM_HOME_DETAIL_LOBBY
  elseif type == LogicFriend.TabType.PlanPHHomeDetailIngame then
    fromID = BP_ENUM_ADD_FRIEND_FROM_HOME_DETAIL_INGAME
  elseif type == LogicFriend.TabType.PlanPHPlayerList then
    fromID = BP_ENUM_ADD_FRIEND_FROM_HOME_PLAYER_LIST
  elseif type == LogicFriend.TabType.MainCityInfoCard then
    fromID = BP_ENUM_ADD_FRIEND_MAINCITY_INFO_CARD
  elseif type == LogicFriend.TabType.ReturnFriendsChatChannel then
    fromID = BP_ENUM_ADD_FRIEND_FROM_RETURN_CHANNEL
  end
  return fromID
end
function LogicFriend.GetReserveState(uid)
  local data = LogicFriend.GetFriendData(uid)
  if not data then
    return 0
  end
  local logic_friend_reserve = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_reserve)
  if not logic_friend_reserve:IsCanReserve(uid) then
    return 0
  end
  local isReserved = logic_friend_reserve:IsReserveSuccess(uid)
  if isReserved then
    return 3
  end
  if not logic_friend_reserve:CheckCanReserve(uid) then
    return 2
  end
  return 1
end
function LogicFriend.GetAllApplyCnt()
  local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
  local cnt = 0
  local logic_friend_apply = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_apply)
  cnt = cnt + logic_friend_apply:GetApplyCnt()
  for i = #intimacyList, 1, -1 do
    if intimacyList[i].state == 2 then
      cnt = cnt + 1
    end
  end
  if PersonSpaceSystem.IntimacyPartnerData and PersonSpaceSystem.IntimacyPartnerData.wait_confirm_list then
    for i, v in pairs(PersonSpaceSystem.IntimacyPartnerData.wait_confirm_list) do
      cnt = cnt + 1
    end
  end
  local changeRelationList = LogicFriend.GetChangeRelationApplyList()
  if changeRelationList and next(changeRelationList) then
    for _, changeData in pairs(changeRelationList) do
      cnt = cnt + 1
    end
  end
  local changeRelationList = LogicFriend.GetChangeCustomNameApplyList()
  if changeRelationList and next(changeRelationList) then
    for _, changeData in pairs(changeRelationList) do
      cnt = cnt + 1
    end
  end
  local logic_home_joint = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_joint)
  local inviteList = logic_home_joint:GetJointApplications()
  cnt = cnt + #inviteList
  inviteList = logic_home_joint:GetTerminateApplications()
  cnt = cnt + #inviteList
  return cnt
end
function LogicFriend.GetAllApplyCntWithProfileCheck()
  local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
  local cnt = 0
  local logic_friend_apply = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_apply)
  local applyList = logic_friend_apply:GetApplyList()
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  for i, v in pairs(applyList) do
    local profile = logic_profile:GetLocalProfile(v.uid)
    if profile and not profile.is_del then
      cnt = cnt + 1
    end
  end
  local logic_home_joint = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_joint)
  local fAddCnt = function(list)
    for i, v in pairs(list) do
      local profile = logic_profile:GetLocalProfile(v.fromId)
      if profile and not profile.is_del then
        cnt = cnt + 1
      end
    end
  end
  local listApply = logic_home_joint:GetJointApplications()
  local listTerminate = logic_home_joint:GetTerminateApplications()
  fAddCnt(listApply)
  fAddCnt(listTerminate)
  for i = #intimacyList, 1, -1 do
    if intimacyList[i].state == 2 then
      cnt = cnt + 1
    end
  end
  if PersonSpaceSystem.IntimacyPartnerData and PersonSpaceSystem.IntimacyPartnerData.wait_confirm_list then
    for i, v in pairs(PersonSpaceSystem.IntimacyPartnerData.wait_confirm_list) do
      cnt = cnt + 1
    end
  end
  local changeRelationList = LogicFriend.GetChangeRelationApplyList()
  if changeRelationList and next(changeRelationList) then
    for _, changeData in pairs(changeRelationList) do
      cnt = cnt + 1
    end
  end
  local changeRelationList2 = LogicFriend.GetChangeCustomNameApplyList()
  if changeRelationList2 and next(changeRelationList2) then
    for _, changeData in pairs(changeRelationList2) do
      cnt = cnt + 1
    end
  end
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  local flashTeamApplyCnt = logic_flash_match_team:GetFlashTeamApplyCnt()
  local flashTeamInviteList = logic_flash_match_team:GetFlashTeamInviteList()
  log("LogicFriend.GetAllApplyCntWithProfileCheck flashTeam notification cnt = " .. tostring(flashTeamApplyCnt) .. " + " .. tostring(#flashTeamInviteList))
  cnt = cnt + flashTeamApplyCnt + #flashTeamInviteList
  return cnt
end
function LogicFriend.GetApplyIntimacyList()
  local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
  local CurrentInitmacyList = {}
  for i = #intimacyList, 1, -1 do
    if intimacyList[i].state == 2 then
      local uid = intimacyList[i].uid
      table.insert(CurrentInitmacyList, uid)
    end
  end
  if PersonSpaceSystem.IntimacyPartnerData and PersonSpaceSystem.IntimacyPartnerData.wait_confirm_list then
    for i, v in pairs(PersonSpaceSystem.IntimacyPartnerData.wait_confirm_list) do
      table.insert(CurrentInitmacyList, i)
    end
  end
  local changeRelationList = LogicFriend.GetChangeRelationApplyList()
  if changeRelationList and next(changeRelationList) then
    for _, changeData in pairs(changeRelationList) do
      table.insert(CurrentInitmacyList, changeData.uid)
    end
  end
  local changeRelationList = LogicFriend.GetChangeCustomNameApplyList()
  if changeRelationList and next(changeRelationList) then
    for _, changeData in pairs(changeRelationList) do
      table.insert(CurrentInitmacyList, changeData.uid)
    end
  end
  return CurrentInitmacyList
end
function LogicFriend.GetIntimacyApplyCnt()
  local cnt = 0
  for i = #intimacyList, 1, -1 do
    if intimacyList[i].state == 2 then
      cnt = cnt + 1
    end
  end
  return cnt
end
function LogicFriend.GetInnerFriendIntimacy(friUid)
  local intimacy = 0
  local friend = friendDataMap[tonumber(friUid)]
  if friend then
    intimacy = friend.intimacy
  end
  return intimacy
end
function LogicFriend.GetEmptyIntimacyRelations()
  local relations = {}
  for relation = 1, 5 do
    if not LogicFriend.IsIntimacyRelationFull(relation) then
      table.insert(relations, relation)
    end
  end
  return relations
end
function LogicFriend.GetRelation(uid)
  for i = 1, #intimacyList do
    if intimacyList[i].uid == uid and intimacyList[i].state == 4 then
      return tonumber(intimacyList[i].param) or 0
    end
  end
  return 0
end
function LogicFriend.GetIntimacyRankUIDList()
  local rankUIDList = {}
  for _, v in pairs(friendDataMap) do
    if v.rank_uid then
      table.insert(rankUIDList, v.rank_uid)
    end
  end
  return rankUIDList
end
function LogicFriend.GetFriendUIDAndIntimacyByRankUID(rankUID)
  for _, v in pairs(friendDataMap) do
    if tonumber(v.rank_uid) == tonumber(rankUID) then
      return v.uid, v.intimacy
    end
  end
  log_warning(bWriteLog and "LogicFriend.GetFriendUIDByRankUID not find uid, rankUID = " .. tostring(rankUID))
  return nil, nil
end
function LogicFriend.SetRemark(uid, remark)
  if friendDataMap[uid] then
    friendDataMap[uid].    EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_UPDATE_REMARK, uid)
  end
end
function LogicFriend.HaveRelationWaitConfirm()
  for i = 1, #intimacyList do
    if intimacyList[i].state == 2 then
      return true
    end
  end
  return false
end
function LogicFriend.IsIntimacyRelationFull(relation)
  local config = CDataTable.GetTableData("FriendIntimacyConfig", relation)
  if not config then
    return false
  end
  local count = 0
  for _, info in ipairs(#intimacyList) do
    if info.state == 4 then
      count = count + 1
    end
  end
  return count >= config.IntimacyRelationMaxCount
end
local bShowIntimayLevelUpSlap = false
function LogicFriend.IsShowIntimacyLevelUpSlap()
  return bShowIntimayLevelUpSlap
end
function LogicFriend.OnIntimacyLevelUpSlap()
  if bShowIntimayLevelUpSlap then
    LogicFriend.GetNextUpgradeDataAndShow(true)
    bShowIntimayLevelUpSlap = false
  end
end
function LogicFriend.ClearIntimacyUpgradeData(fri_uid)
  if LogicFriend.IntimacyLevelUpData and LogicFriend.IntimacyLevelUpData[fri_uid] then
    LogicFriend.IntimacyLevelUpData[fri_uid] = nil
  end
end
function LogicFriend.SetIntimacyLevelUpData(fri_uid, lv, list)
  local list = {
    targetUID = fri_uid,
    level = lv,
    itemList = list
  }
  if not LogicFriend.IntimacyLevelUpData then
    LogicFriend.IntimacyLevelUpData = {}
  end
  LogicFriend.IntimacyLevelUpData[fri_uid] = list
end
function LogicFriend.GetNextUpgradeDataAndShow(bShowPop)
  if LogicFriend.IntimacyLevelUpData and next(LogicFriend.IntimacyLevelUpData) then
    local _, data = next(LogicFriend.IntimacyLevelUpData)
    if bShowPop then
      UIManager.ShowUI(UIManager.UI_Config.Intimacy_Popup_Upgrade_UIBP, data)
      LogicFriend.ClearIntimacyUpgradeData(data.targetUID)
    end
    return data
  end
  return nil
end
function LogicFriend.IsMyFriend(uid)
  uid = tonumber(uid)
  if friendDataMap[uid] then
    return true
  end
  return false
end
function LogicFriend.IsFriendReserveSwitchOpen(uid)
  uid = tonumber(uid)
  if not friendDataMap[uid] then
    log(bWriteLog and "LogicFriend.IsFriendReserveSwitchOpen not friend")
    return false
  end
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local FriendData = logic_profile:GetLocalProfile(uid)
  if FriendData and FriendData.friend_appointment_privacy and FriendData.friend_appointment_privacy == 0 then
    log(bWriteLog and "LogicFriend.IsFriendReserveSwitchOpen not friend_appointment_privacy open")
    return false
  end
  return true
end
function LogicFriend.IsPlatFriend(uid)
  local isPlat = false
  for i = #platformList, 1, -1 do
    if platformList[i] == uid then
      isPlat = true
      break
    end
  end
  return isPlat
end
function LogicFriend.IsInnerFriend(uid)
  local isInner = false
  for i = #innerList, 1, -1 do
    if innerList[i] == uid then
      isInner = true
      break
    end
  end
  return isInner
end
function LogicFriend.IsInIntimacyList(uid)
  local isIn = false
  for i = #intimacyList, 1, -1 do
    if intimacyList[i].uid == uid then
      isIn = true
      break
    end
  end
  return isIn
end
function LogicFriend.get_all_friendlist_req(bForce)
  if not bForce and TimeUtil.GetServerTimeInSec() - LogicFriend.GetAllFriendStamp < LogicFriend.GetAllFriendCD then
    log(bWriteLog and "LogicFriend.get_all_friendlist_req CD")
    return
  end
  local FriendHandler = require("client.network.Protocol.FriendHandler")
  FriendHandler.send_get_all_friendlist_req()
end
function LogicFriend.UpdateIntimacyRankUID(uid, rankUID)
  log(bWriteLog and "LogicFriend.UpdateIntimacyRankUID uid = " .. tostring(uid) .. ", rankUID = " .. tostring(rankUID))
  if friendDataMap[uid] and rankUID then
    friendDataMap[uid].rank_uid = rankUID
  end
end
function LogicFriend.send_report_friend_info_req(code, err_str)
  log(bWriteLog and "LogicFriend.send_report_friend_info_req code is " .. tostring(code))
end
function LogicFriend.proc_report_friend_info_rsp(res, type, code, err_str)
  log(bWriteLog and "LogicFriend.proc_report_friend_info_rsp code is " .. tostring(code))
end
function LogicFriend.on_get_all_friendlist_rsp(res, friendlist, _, _)
  log(bWriteLog and "LogicFriend.on_get_all_friendlist_rsp")
  local utility = require("common.utility")
  xpcall(function()
    platformList:ClearData()
    innerList:ClearData()
  end, utility.ErrorMessageHandler)
  local topList = friendlist.top_list or {}
  local logic_friend_gift = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_gift)
  local curTime = TimeUtil.GetServerTimeInSec()
  if next(friendlist) ~= nil then
    local list = {}
    local idx = 1
    for k, v in pairs(friendlist.plat_list) do
      k = tonumber(k)
      if 0 < k then
        local friendInfo = friendDataMap[k] or {}
        friendDataMap[k] = friendInfo
        friendInfo.uid = k
        friendInfo.lastInviteTime = v.lastInviteTime
        friendInfo.intimacy = 0
        friendInfo.remarks_name = v.remarks_name
        friendInfo.remark = v.remark
        if v.add_from then
          friendInfo.add_from = v.add_from
        end
        if v.presented and tonumber(v.presented) == 0 then
          logic_friend_gift:SetLastPresentTime(k, 0)
        else
          logic_friend_gift:SetLastPresentTime(k, curTime)
        end
        friendInfo.isTop = false
        friendInfo.SetTopTimeStamp = 0
        if topList[friendInfo.uid] then
          friendInfo.isTop = true
          friendInfo.SetTopTimeStamp = topList[friendInfo.uid]
        end
        list[idx] = k
        idx = idx + 1
      end
    end
    platformList:SetData(list)
    list = {}
    idx = 1
    for k, v in pairs(friendlist.inner_list) do
      k = tonumber(k)
      if 0 < k then
        local friendInfo = friendDataMap[k] or {}
        friendDataMap[k] = friendInfo
        friendInfo.uid = k
        friendInfo.intimacy = v.intimacy
        friendInfo.create_time = v.create_time
        friendInfo.remark = v.remark
        friendInfo.rank_uid = v.rank_uid
        friendInfo.change_data = v.change_data
        friendInfo.custom_name = v.custom_name
        if v.add_from then
          friendInfo.add_from = v.add_from
        end
        if v.presented ~= nil and tonumber(v.presented) == 0 then
          logic_friend_gift:SetLastPresentTime(k, 0)
        else
          logic_friend_gift:SetLastPresentTime(k, curTime)
        end
        friendInfo.isTop = false
        friendInfo.SetTopTimeStamp = 0
        if topList[friendInfo.uid] then
          friendInfo.isTop = true
          friendInfo.SetTopTimeStamp = topList[friendInfo.uid]
        end
        list[idx] = k
        idx = idx + 1
      end
    end
    innerList:SetData(list)
    local uidList = FuncUtil.UnionList(innerList, platformList)
    if next(uidList) then
      local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
      logic_profile_get_wrap.GetFriendProfiles(Enum_PROFILE_REPORT_CFG.FRIEND_LIST, uidList, LogicFriend.on_batch_get_all_profile_rsp, false, false, nil, false)
      if LogicFriend.IsReqOnlineAndGroupInfo then
        local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
        PlayerStatusMgr:send_batch_get_group_and_online_req(ENUM_BATCH_GET_GROUP_AND_ONLINE.AllFriend, uidList)
        LogicFriend.IsReqOnlineAndGroupInfo = false
      end
    else
      local HostedFriendProtocol = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.HostedFriendProtocol)
      HostedFriendProtocol:OnFriendDataReady()
    end
    if innerList and DataMgr.roleData.back_user_data and not DataMgr.roleData.back_user_data.have_task_list and not DataMgr.roleData.has_send_back_friend_list then
      DataMgr.roleData.has_send_back_friend_list = true
      local TableUtil = require("common.table_util")
      local uids = {}
      for i = 1, 10 do
        if innerList and innerList[i] then
          table.insert(uids, innerList[i])
        end
        if platformList and platformList[i] and not TableUtil.IsInTable(innerList, platformList[i]) then
          table.insert(uids, platformList[i])
        end
      end
      table.sort(uids, SortIDFunc)
      uids = TableUtil.slice(uids, 1, 10, 1)
      local PlayerReturnHandler = require("client.network.Protocol.PlayerReturnHandler")
      PlayerReturnHandler.send_backuser_start_req(uids)
    end
  end
  LogicFriend.GetAllFriendStamp = TimeUtil.GetServerTimeInSec()
  EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_INTIMACY_CHANGE)
  local logic_friend_interact_record = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_interact_record)
  logic_friend_interact_record:AddInnerFriendData(innerList)
end
function LogicFriend.FilterFriendData()
  log(bWriteLog and "LogicFriend.FilterFriendData")
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  for i, _ in pairs(friendDataMap) do
    if not logic_profile:GetLocalProfile(i) then
      log(bWriteLog and "LogicFriend.FilterFriendData nil profile uid: " .. tostring(i))
      friendDataMap[i] = nil
      for index = #platformList, 1, -1 do
        if platformList[index] == i then
          platformList:RemoveItem(index)
          break
        end
      end
      for index = #innerList, 1, -1 do
        if innerList[index] == i then
          innerList:RemoveItem(index)
          break
        end
      end
      for index = #intimacyList, 1, -1 do
        if intimacyList[index].uid == i then
          table.remove(intimacyList, index)
          break
        end
      end
    end
  end
  logic_profile:SetFriendSubData()
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_FRIENDINFO_UPDATE)
  EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_PROFILE_CHANGE)
  EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_INTIMACY_CHANGE)
  EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_BANSTATUS_CHANGE)
  if not LogicFriend.IsReqOnlineAndGroupInfo then
    EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_PROFILE_ONLINE_GROUP_GET)
  end
end
function LogicFriend.on_notify_topn_plat_friend_chg_info(list)
  log(bWriteLog and "LogicFriend.on_notify_topn_plat_friend_chg_info")
  if list == nil then
    return
  end
  local logic_friend_gift = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_gift)
  for k, v in pairs(list) do
    if 0 < k then
      local friendInfo = friendDataMap[k] or {}
      friendInfo.uid = k
      friendInfo.lastInviteTime = v.lastInviteTime
      friendInfo.remarks_name = v.remarks_name
      if friendInfo.intimacy == nil then
        friendInfo.intimacy = 0
      end
      if v.presented ~= nil and tonumber(v.presented) == 0 then
        logic_friend_gift:SetLastPresentTime(k, 0)
      else
        logic_friend_gift:SetLastPresentTime(k, TimeUtil.GetServerTimeInSec())
      end
      friendDataMap[k] = friendInfo
      local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
      logic_profile:ModifyFriendSubData(friendInfo, true)
      if not LogicFriend.IsPlatFriend(k) then
        platformList:AppendItem(k)
      end
    end
  end
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetFriendProfiles(Enum_PROFILE_REPORT_CFG.FRIEND_TOPN_PLAT, list, LogicFriend.on_batch_get_all_profile_rsp)
end
function LogicFriend.on_batch_get_all_profile_rsp(profileList)
  local lastLogoutTime = tonumber(LobbySystem.roleData.last_logout_time) or 0
  log(bWriteLog and "[DeanJYT] LogicFriend.on_batch_get_all_profile_rsp lastLogoutTime: " .. tostring(lastLogoutTime))
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  for _, v in pairs(profileList) do
    if friendDataMap[v.uid] then
      friendDataMap[v.uid].uid = v.uid
      friendDataMap[v.uid].lastOnlineTime = v.lastOnlineTime
      if logic_profile:IsPlayerBannedOver30day(v.uid) then
        local TableUtil = require("common.table_util")
        local banStartTime = TableUtil.GetTableValue(v, "login_banned_ts", 1) or 0
        if lastLogoutTime < banStartTime then
          LogicFriend.bShouldShowFriendBanned = true
        end
      end
    end
  end
  local HostedFriendProtocol = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.HostedFriendProtocol)
  HostedFriendProtocol:OnFriendDataReady()
  LogicFriend.FilterFriendData()
  local AssemblyActivitySystem = require("client.slua.logic.come_back.logic_assembly_activity")
  AssemblyActivitySystem.SyncAssemblyFriendToServer(LogicFriend.GetInnerListSortByIntimacy(), platformList)
end
function LogicFriend.ShowIntimacyErrCode(res, relation, limit)
  log(bWriteLog and "LogicFriend.ShowIntimacyErrCode:" .. tostring(res) .. " relation:" .. tostring(relation))
  if res == 100100011 then
    local str = LocUtil.LocalizeResFormat(77901, limit)
    ShowNotice(str)
  elseif res == 100100002 then
    local str = LocUtil.GetLocalizeResStr(9136)
    ShowNotice(str)
  elseif res == 100100005 then
    local str = LocUtil.GetLocalizeResStr(8075918)
    ShowNotice(str)
  elseif res == "del-cd" then
    local str = LocUtil.GetLocalizeResStr(200045)
    ShowNotice(str)
  elseif res == "full" then
    local str = LocUtil.GetLocalizeResStr(200046)
    ShowNotice(str)
  elseif res == "invalid-param" then
    local str = LocUtil.GetLocalizeResStr(200047)
    ShowNotice(str)
  elseif res == "low-intimacy" then
    local str = LocUtil.GetLocalizeResStr(200048)
    ShowNotice(str)
  elseif res == "op-low-intimacy" then
    local str = LocUtil.GetLocalizeResStr(200048)
    ShowNotice(str)
  elseif res == "already-build" then
    local str = LocUtil.GetLocalizeResStr(200056)
    ShowNotice(str)
  elseif res == "wait-confirm" then
    local str = LocUtil.GetLocalizeResStr(200049)
    ShowNotice(str)
  elseif res == "op-del-cd" then
    local str = LocUtil.GetLocalizeResStr(200045)
    ShowNotice(str)
  elseif res == "op-already-build" then
    local str = LocUtil.GetLocalizeResStr(200056)
    ShowNotice(str)
  elseif res == "op-already-send" then
    local str = LocUtil.GetLocalizeResStr(200049)
    ShowNotice(str)
  elseif res == "state-error" or res == "relation-error" or res == "op-state-error" or res == "op-relation-error" then
    local str = LocUtil.GetLocalizeResStr(200053)
    ShowNotice(str)
  elseif res == "not-exist" then
    local msg = LocUtil.GetLocalizeResStr(200051)
    ShowNotice(msg)
  elseif res == "cur-relation-full" then
    local relationName = IntimacyUtils.GetRelationText(relation)
    local msg = LocUtil.LocalizeResFormat(8041, relationName)
    ShowNotice(msg)
  elseif res == "all-relation-full" then
    local str = LocUtil.LocalizeResFormat(8043)
    ShowNotice(str)
  else
    local relationName = IntimacyUtils.GetRelationText(relation)
    log(bWriteLog and "proc_build_intimacy_relation_rsp res ok " .. tostring(relationName))
    if relationName ~= "" then
      local str = LocUtil.LocalizeResFormat(200038, relationName)
      ShowNotice(str)
    end
  end
end
function LogicFriend.get_intimacy_relation_req(IsNeedRedpoint)
  log(bWriteLog and "LogicFriend.get_intimacy_relation_req")
  local FriendHandler = require("client.network.Protocol.FriendHandler")
  FriendHandler.send_get_intimacy_relation_req(IsNeedRedpoint or false)
end
function LogicFriend.on_get_intimacy_relation_rsp(list)
  log_tree("on_get_intimacy_relation_rsp", list)
  intimacyList = {}
  for k, v in pairs(list) do
    LogicFriend.AddIntimacy(tonumber(k), v.state, v.param, v.intimacy, v.award_level, v.create_time, true, true)
  end
  EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_INTIMACY_CHANGE)
  LogicFriend.GetIntimacyList(true)
  local logic_interaction = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_interaction)
  logic_interaction:on_fire_listAddMsg()
end
function LogicFriend.build_intimacy_relation_req(friUid, relation, vow_id)
  printf("LogicFriend.build_intimacy_relation_req friUid:%s, relation:%s, vow_id:%s", friUid, relation, vow_id)
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  local FriendHandler = require("client.network.Protocol.FriendHandler")
  FriendHandler.send_build_intimacy_relation_req(friUid, relation, vow_id)
end
function LogicFriend.proc_build_intimacy_relation_rsp(friUid, relation)
  log(bWriteLog and "LogicFriend.proc_build_intimacy_relation_rsp")
  local relationName = IntimacyUtils.GetRelationText(relation)
  log(bWriteLog and "proc_build_intimacy_relation_rsp res ok " .. tostring(relationName))
  if relationName ~= "" then
    local str = LocUtil.LocalizeResFormat(200034, relationName)
    ShowNotice(str)
  end
  local bFound = false
  for i = 1, #intimacyList do
    if intimacyList[i].uid == friUid then
      local data = intimacyList[i]
      data.state = 1
      data.param = relation
      intimacyList[i] = data
      EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_INTIMACY_CHANGE)
      bFound = true
      break
    end
  end
  if not bFound then
    LogicFriend.AddIntimacy(friUid, 1, relation)
  end
end
function LogicFriend.delete_intimacy_relation_req(friUid)
  log(bWriteLog and "LogicFriend.delete_intimacy_relation_req friUid: " .. tostring(friUid))
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  local FriendHandler = require("client.network.Protocol.FriendHandler")
  FriendHandler.send_delete_intimacy_relation_req(tonumber(friUid))
end
function LogicFriend.on_delete_intimacy_relation_rsp(res, friUid, relation)
  log(bWriteLog and "LogicFriend.on_delete_intimacy_relation_rsp res: " .. tostring(res) .. " friUid: " .. tostring(friUid))
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  if res == NetErrorCode_NONE then
    LogicFriend.DeleteIntimacyData(friUid)
    local msg = LocUtil.GetLocalizeResStr(200035)
    local relationName = IntimacyUtils.GetRelationText(relation)
    local profile = logic_profile:GetLocalProfile(friUid)
    if profile then
      local str = string.format(msg, profile.nickName, relationName)
      ShowNotice(str)
    end
    local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
    if friUid == PersonSpaceSystem.IntimacyPartnerData.partner_uid then
      local IntimacyAwardSystem = require("client.slua.logic.person_space.logic_intimacy_award")
      IntimacyAwardSystem.get_intimacy_reward_info_req(true)
      PersonSpaceSystem.IntimacyPartnerData = {partner_uid = 0}
      IntimacyAwardSystem.has_intimacy_reward = false
    end
  elseif res == "not-build" then
    local msg = LocUtil.GetLocalizeResStr(200055)
    ShowNotice(msg)
    LogicFriend.DeleteIntimacyData(friUid)
  end
end
function LogicFriend.cancel_build_intimacy_relation_req(friUid)
  log(bWriteLog and "LogicFriend.cancel_build_intimacy_relation_req uid: " .. tostring(friUid))
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  local FriendHandler = require("client.network.Protocol.FriendHandler")
  FriendHandler.send_cancel_build_intimacy_relation_req(friUid)
end
function LogicFriend.on_cancel_build_intimacy_relation_rsp(res, friUid)
  log(bWriteLog and "LogicFriend.on_cancel_build_intimacy_relation_rsp res: " .. tostring(res) .. " friUid: " .. tostring(friUid))
  for i = #intimacyList, 1, -1 do
    if intimacyList[i].uid == friUid then
      local data = intimacyList[i]
      data.state = 0
      intimacyList[i] = data
      break
    end
  end
  EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_INTIMACY_CHANGE)
end
function LogicFriend.on_cancel_build_intimacy_relation_notify(friUid, canBuild)
  log(bWriteLog and "LogicFriend.on_cancel_build_intimacy_relation_notify friUid: " .. tostring(friUid) .. " canBuild: " .. tostring(canBuild))
  if canBuild then
    for i = #intimacyList, 1, -1 do
      if intimacyList[i].uid == friUid then
        local data = {}
        data.state = 0
        data.param = LogicFriend.GetInnerFriendIntimacy(friUid)
        intimacyList[i] = data
        break
      end
    end
  else
    for i = #intimacyList, 1, -1 do
      if intimacyList[i].uid == friUid then
        table.remove(intimacyList, i)
        break
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_INTIMACY_CHANGE)
end
function LogicFriend.reply_intimacy_relation_req(friUid, relation, op, vow_id)
  printf("LogicFriend.reply_intimacy_relation_req friUid:%s, relation:%s, op:%s, vow_id:%s", friUid, relation, op, vow_id)
  vow_id = vow_id or 0
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  local FriendHandler = require("client.network.Protocol.FriendHandler")
  return FriendHandler.send_reply_intimacy_relation_req(friUid, relation, op, nil, vow_id)
end
function LogicFriend.on_reply_intimacy_relation_rsp(res, friUid, relation, op, limit)
  log(bWriteLog and "LogicFriend.on_reply_intimacy_relation_rsp res:" .. tostring(res) .. " friUid:" .. tostring(friUid) .. " relation:" .. tostring(relation) .. " op:" .. tostring(op))
  if res == NetErrorCode_NONE then
    if op == 1 then
      for i = #intimacyList, 1, -1 do
        if intimacyList[i].uid == friUid then
          local data = intimacyList[i]
          data.state = 4
          data.param = relation
          intimacyList[i] = data
          EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_INTIMACY_CHANGE)
          break
        end
      end
      local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
      local profile = logic_profile:GetLocalProfile(friUid)
      local relationName = IntimacyUtils.GetRelationText(relation)
      if profile then
        local msg = LocUtil.GetLocalizeResStr(200037)
        local str = string.format(msg, profile.nickName, relationName)
        ShowNotice(str)
      end
      local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
      local msgText = ""
      local IntimacyConst = require("client.slua.logic.friend.Intimacy.IntimacyConst")
      if relation == IntimacyConst.EIntimacyType.Bonding then
        msgText = LocUtil.GetLocalizeResStr(8075911)
      else
        msgText = LocUtil.LocalizeResFormat(73286, relationName)
      end
      logic_chat_main.AddAlterInteractiveMsg(friUid, msgText)
    else
      LogicFriend.DeleteIntimacyData(friUid)
    end
  else
    if op == 0 then
      LogicFriend.DeleteIntimacyData(friUid)
    end
    LogicFriend.ShowIntimacyErrCode(res, relation, limit)
  end
  if res ~= 100100011 then
    EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_INTIMACYAPPLY_CHANGE)
  end
end
function LogicFriend.on_notify_intimacy_relation_chg(friUid, state, param, rank_uid)
  log(bWriteLog and "LogicFriend.on_notify_intimacy_relation_chg friUid:" .. tostring(friUid) .. " state:" .. tostring(state))
  if param then
    log(bWriteLog and "LogicFriend.on_notify_intimacy_relation_chg param: " .. tostring(param))
  end
  if state ~= 3 then
    LogicFriend.AddIntimacy(friUid, state, param)
  else
    LogicFriend.DeleteIntimacyData(friUid)
  end
  LogicFriend.UpdateIntimacyRankUID(friUid, rank_uid)
  if state == 2 then
    EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_INTIMACYAPPLY_CHANGE)
  end
end
function LogicFriend.notify_friend_intimacy_chg(friUid, chg, newIntimacy, extraInfo)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  if friendDataMap[friUid] then
    friendDataMap[friUid].intimacy = newIntimacy
    local data = {}
    data.uid = friUid
    data.intimacy = newIntimacy
    logic_profile:ModifyFriendSubData(data)
  end
  if newIntimacy >= LogicFriend.Friend_Intimacy_Threshold and LogicFriend.IsInIntimacyList(friUid) == false then
    LogicFriend.AddIntimacy(friUid, 0, newIntimacy)
  end
  local profile = logic_profile:GetLocalProfile(friUid)
  if profile then
    if extraInfo and extraInfo.times_intimacy then
      log(bWriteLog and "LogicFriend.notify_friend_intimacy_chg extraInfo.times_intimacy = " .. tostring(extraInfo.times_intimacy))
    elseif extraInfo and extraInfo.intimacy_double_act then
      log(bWriteLog and "LogicFriend.notify_friend_intimacy_chg double tips")
      local str = LocUtil.LocalizeResFormat(69302, profile.nickName, tostring(chg))
      ShowNotice(str)
    else
      local str = LocUtil.LocalizeResFormat(6470, profile.nickName, tostring(chg))
      ShowNotice(str)
    end
  end
  EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_INTIMACY_UPDATE, friUid, newIntimacy)
end
function LogicFriend.on_take_intimacy_award_rsp(award_level, target_uid, item_list)
  LogicFriend.ChangeList(target_uid, award_level)
  log(bWriteLog and "[PXY]on_take_intimacy_award_rsp")
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  for key, value in pairs(item_list) do
    local arrayItemData = {}
    table.insert(arrayItemData, {
      res_id = key,
      count = value,
      valid_hours = 0
    })
    Logic_CommonItemGet.ShowPanel_DefaultStyle(arrayItemData)
  end
  EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_TAKE_INTIMACY_REWARD)
end
function LogicFriend.send_change_intimacy_relation_req(fri_uid, change_type, param, vow_id)
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  local TimeUtil = require("client.common.time_util")
  local currentTime = TimeUtil.GetServerTimeInSec()
  local friendData = LogicFriend.GetFriendData(fri_uid)
  if not friendData then
    log(bWriteLog and "LogicFriend.send_change_intimacy_relation_req not friend Data")
    return
  end
  local TableUtil = require("common.table_util")
  local changeData = TableUtil.GetTableValue(friendData, "change_data", LogicFriend.RelationChangeType.RelationType)
  if changeData then
    local friendReqTime = changeData.create_ts or 0
    if TimeUtil.WithinInNDay(friendReqTime, 60) and change_type == LogicFriend.RelationChangeType.RelationType then
      local deltaDays = math.floor((TimeUtil.GetServerTimeInSec() - friendReqTime) / 86400)
      local leftDays = 60 - deltaDays
      ShowNotice(LocUtil.LocalizeResFormat(73271, leftDays))
      return
    end
  end
  local FriendHandler = require("client.network.Protocol.FriendHandler")
  FriendHandler.send_change_intimacy_relation_req(fri_uid, change_type, param, vow_id)
end
function LogicFriend.proc_change_intimacy_relation_rsp(fri_uid, change_type, param)
  log(bWriteLog and "LogicFriend.proc_change_intimacy_relation_rsp")
  local friendInfo = friendDataMap[fri_uid]
  if not friendInfo then
    log(bWriteLog and "LogicFriend.proc_change_intimacy_relation_rsp 2")
    return
  end
  local time_util = require("client.common.time_util")
  local tNow = time_util.GetServerTimeInSec()
  if not friendInfo.change_data then
    friendInfo.change_data = {}
  end
  friendInfo.change_data[change_type] = {
    apply_ts = tNow,
    update_ts = tNow,
    state = 1,
    param = param,
    apply_uid = fri_uid
  }
  EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_INTIMACY_CHANGE)
end
function LogicFriend.get_change_intimacy_relation_tip(res_code)
  log(bWriteLog and "[dongkaizha] intimacy relation errcode 2 tip: " .. tostring(res_code))
  local res_code2tip = {
    [100100006] = 200051,
    [100100012] = 200055,
    [100100013] = 77154,
    [100100014] = 200046,
    [100100015] = 73271,
    [100100016] = 77155,
    [100100017] = 45744,
    [100100018] = 20220914,
    [100100005] = 8075918
  }
  if res_code2tip and res_code2tip[res_code] then
    return res_code2tip[res_code]
  else
    return res_code
  end
end
function LogicFriend.send_reply_change_intimacy_relation_req(fri_uid, op, change_type, param, vow_id)
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  local FriendHandler = require("client.network.Protocol.FriendHandler")
  return FriendHandler.send_reply_change_intimacy_relation_req(fri_uid, op, change_type, param, vow_id)
end
function LogicFriend.on_reply_change_intimacy_relation_rsp(fri_uid, op, change_type, param)
  log(bWriteLog and string.format("LogicFriend.on_reply_change_intimacy_relation_rsp uid = %s , change_type = %d, param = %s", tostring(fri_uid), change_type, tostring(param)))
  local TimeUtil = require("client.common.time_util")
  local currentTime = TimeUtil.GetServerTimeInSec()
  local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
  if op == LogicFriend.RelationApplyOp.Agree then
    local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
    local ui_util = require("client.common.ui_util")
    local msg
    local bChangeRelationOrName = type(param) == "number"
    if bChangeRelationOrName then
      msg = LocUtil.LocalizeResFormat(73286, ui_util.GetIntimacyRelationName(param))
    else
      msg = LocUtil.LocalizeResFormat(73286, param)
    end
    logic_chat_main.AddAlterInteractiveMsg(fri_uid, msg)
    if friendDataMap[fri_uid] then
      friendDataMap[fri_uid].change_data[change_type].update_ts = currentTime
      friendDataMap[fri_uid].change_data[change_type].state = 4
      friendDataMap[fri_uid].change_data[change_type].      if change_type == LogicFriend.RelationChangeType.CustomName then
        friendDataMap[fri_uid].custom_name = param
      end
      for i = 1, #intimacyList do
        if intimacyList[i].uid == fri_uid then
          local data = intimacyList[i]
          data.state = 4
          if change_type == LogicFriend.RelationChangeType.RelationType then
            data.          elseif change_type == LogicFriend.RelationChangeType.CustomName then
            data.custom_name = param
          end
          intimacyList[i] = data
          break
        end
      end
    end
    local logic_chat_channel_friend = require("client.slua.logic.lobby_chat.logic_chat_channel_friend")
    logic_chat_channel_friend.DeleteFriendBgID(tostring(fri_uid))
  elseif op == LogicFriend.RelationApplyOp.Refuse and friendDataMap[fri_uid] then
    friendDataMap[fri_uid].change_data[change_type].update_ts = currentTime
    friendDataMap[fri_uid].change_data[change_type].state = 0
  end
  EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_INTIMACY_CHANGE)
  EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_APPLYLIST_CHANGE)
end
function LogicFriend.send_cancel_change_intimacy_relation_req(fri_uid, change_type, param)
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  local FriendHandler = require("client.network.Protocol.FriendHandler")
  FriendHandler.send_cancel_change_intimacy_relation_req(fri_uid, change_type, param)
end
function LogicFriend.on_cancel_change_intimacy_relation_rsp(fri_uid, change_type, param)
  log(bWriteLog and string.format("LogicFriend.on_cancel_change_intimacy_relation_rsp uid = %s , change_type = %d, param = %s", tostring(fri_uid), change_type, tostring(param)))
  local TimeUtil = require("client.common.time_util")
  local currentTime = TimeUtil.GetServerTimeInSec()
  if friendDataMap[fri_uid] then
    friendDataMap[fri_uid].change_data[change_type].update_ts = currentTime
    friendDataMap[fri_uid].change_data[change_type].state = 0
  end
  EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_INTIMACY_CHANGE)
end
function LogicFriend.on_notify_change_intimacy_relation_update(fri_uid, change_type, change_data)
  log(bWriteLog and "LogicFriend.on_notify_change_intimacy_relation_update fri_uid = " .. tostring(fri_uid) .. " change_type = " .. tostring(change_type))
  log_tree(bWriteLog and "LogicFriend.on_notify_change_intimacy_relation_update change_data", change_data)
  local friendData = LogicFriend.GetFriendData(fri_uid)
  if not friendData then
    log(bWriteLog and "LogicFriend.on_notify_change_intimacy_relation_update failed to get data with fri_uid" .. tostring(fri_uid))
  end
  if change_type == LogicFriend.RelationChangeType.RelationType and change_data and friendData.change_data and friendData.change_data[change_type] then
    local TableUtil = require("common.table_util")
    local currentState = TableUtil.GetTableValue(friendData, "change_data", change_type, "state")
    if currentState then
      local curIntimacy, curId = nil, 0
      for i = 1, #intimacyList do
        if intimacyList[i].uid == fri_uid then
          curId, curIntimacy = i, intimacyList[i]
          break
        end
      end
      if curIntimacy and curIntimacy.param ~= friendData.change_data[change_type].param and currentState == 4 then
        curIntimacy.state = friendData.change_data[change_type].state
        curIntimacy.param = friendData.change_data[change_type].param
        intimacyList[curId] = curIntimacy
      end
    end
  elseif change_type == LogicFriend.RelationChangeType.CustomName and change_data and change_data.state and change_data.state == 4 then
    for i = 1, #intimacyList do
      if intimacyList[i].uid == fri_uid then
        local new_name = change_data.param
        intimacyList[i].custom_name = new_name
        friendData.custom_name = new_name
        break
      end
    end
  end
  if not friendData.change_data then
    friendData.change_data = {}
  end
  friendData.change_data[change_type] = change_data
  EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_INTIMACY_CHANGE)
  EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_INTIMACYAPPLY_CHANGE)
end
function LogicFriend.on_notify_intimacy_level_up(fri_uid, level, item_list)
  log(bWriteLog and string.format("LogicFriend.on_notify_intimacy_level_up fri_uid = %s level = %s ", tostring(fri_uid), tostring(level)))
  log_tree(bWriteLog and "LogicFriend.on_notify_intimacy_level_up itemList", item_list)
  if not LogicFriend.bSetShowIntimayLevelUpSlap then
    bShowIntimayLevelUpSlap = true
    LogicFriend.bSetShowIntimayLevelUpSlap = true
  end
  LogicFriend.SetIntimacyLevelUpData(fri_uid, level, item_list)
  local LobbyModeManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyModeManager)
  local bInLobbyShowPop = LogicFriend.bSetShowIntimayLevelUpSlap and not bShowIntimayLevelUpSlap or not LogicFriend.bSetShowIntimayLevelUpSlap and not bShowIntimayLevelUpSlap
  if LobbyModeManager:IsNormalLobby() then
    LogicFriend.GetNextUpgradeDataAndShow(true)
  end
end
function LogicFriend.on_notify_team_result_finished()
  log(bWriteLog and "LogicFriend.on_notify_team_result_finished")
end
function LogicFriend.on_get_recent_teammate_rsp(list)
  log(bWriteLog and "LogicFriend.on_get_recent_teammate_rsp")
  recentTeammateMap = {}
  local idlist = {}
  if list then
    for i = 1, #list do
      if list[i].uid > 0 then
        local profile = {
          uid = list[i].uid,
          endtime = list[i].endtime,
          endtimeStr = TimeUtil.GetTimeAgoStr(list[i].endtime),
          rank = list[i].rank,
          total = list[i].total,
          score = tostring(list[i].score),
          kill = list[i].kill,
          mode = list[i].mode,
          battleid = list[i].battleid or 0
        }
        local matchConfig = CDataTable.GetTableData("MatchModeTable", tonumber(list[i].mode))
        if matchConfig then
          profile.modeStr = matchConfig.ModeStr
        else
          profile.modeStr = ""
        end
        if not recentTeammateMap[list[i].uid] then
          table.insert(idlist, list[i].uid)
        end
        recentTeammateMap[list[i].uid] = profile
      end
    end
  end
  if 0 < #idlist then
    log(bWriteLog and "[LogicFriend] request recent data")
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles(idlist, LogicFriend.on_batch_get_profile_rsp, Enum_PROFILE_REPORT_CFG.FRIEND_LIST)
    local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
    PlayerStatusMgr:GetOrReqStatusData(ENUM_BATCH_GET_GROUP_AND_ONLINE.RecentTeammate, idlist, function()
      EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_UPDATE_RECENT_STATUS)
      EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_RECENT_STATE_UPDATE)
    end)
  else
    log(bWriteLog and "[LogicFriend] no recent")
    EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_RECENT_STATE_UPDATE)
  end
end
function LogicFriend.on_batch_get_profile_rsp(profileList)
  log(bWriteLog and "LogicFriend.on_batch_get_recentteammate_profile_rsp")
  EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_INFO_UPDATE, profileList)
end
function LogicFriend.del_inner_friend_req(friUid)
  if not friUid then
    return
  end
  log(bWriteLog and "LogicFriend.del_inner_friend_req: " .. friUid)
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  local FriendHandler = require("client.network.Protocol.FriendHandler")
  FriendHandler.send_del_inner_friend_req(friUid)
end
function LogicFriend.on_del_inner_friend_rsp(res, uid)
  log(bWriteLog and "on_del_inner_friend_rsp:" .. res)
  if res == NetErrorCode_NONE then
    if LogicFriend.IsPlatFriend(uid) then
      ShowNotice(86240)
    end
    LogicFriend.DeleteInnerFriend(uid)
    local logic_interaction = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_interaction)
    logic_interaction:DeleteInteractionInfo(uid)
  end
end
function LogicFriend.on_del_inner_friend_notify(uid)
  log(bWriteLog and "LogicFriend.on_del_inner_friend_notify uid: " .. tostring(uid))
  local logic_interaction = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_interaction)
  logic_interaction:DeleteInteractionInfo(uid)
  LogicFriend.DeleteInnerFriend(uid)
end
function LogicFriend.del_inner_friend_batch_req(list)
  log(bWriteLog and "LogicFriend.del_inner_friend_batch_req")
  if list == nil then
    return
  end
  if #list == 0 then
    return
  end
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  local FriendHandler = require("client.network.Protocol.FriendHandler")
  FriendHandler.send_del_inner_friend_batch_req(list)
end
function LogicFriend.del_inner_friend_batch_rsp(res, friendUidList)
  log(bWriteLog and "LogicFriend.del_inner_friend_batch_rsp:" .. res)
  if res ~= NetErrorCode_NONE then
    return
  end
  local hasPopPlatTips = false
  local time_ticker = require("common.time_ticker")
  if not LogicFriend.del_friend_time then
    LogicFriend.del_friend_timer = time_ticker.AddTimer(0, function()
      for _, uid in ipairs(friendUidList) do
        coroutine.yield(0.01)
        LogicFriend.DeleteInnerFriend(uid, false)
        if LogicFriend.IsPlatFriend(uid) and not hasPopPlatTips then
          hasPopPlatTips = true
          ShowNotice(86240)
        end
      end
      EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_DELETE_BATCH_FRIEND)
      if LogicFriend.del_friend_timer then
        time_ticker.RemoveTimer(LogicFriend.del_friend_timer)
        LogicFriend.del_friend_timer = nil
      end
    end)
  end
end
function LogicFriend.invite_offline_friend_req(channel, token_type)
  log(bWriteLog and "LogicFriend.invite_offline_friend_req channel = " .. tostring(channel))
  local AdjustSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.AdjustSystem)
  LogicFriend.InviteChannnel = channel
  LogicFriend.TokenType = token_type or AdjustSystem.E_TokenType.InviteFriend
  local FriendHandler = require("client.network.Protocol.FriendHandler")
  FriendHandler.send_invite_offline_friend_req()
end
function LogicFriend.on_invite_offline_friend_rsp(res, teamid)
  log(bWriteLog and "LogicFriend.invite_offline_friend_rsp, res = " .. res .. ", teamid = " .. tostring(teamid))
  local AdjustSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.AdjustSystem)
  if res == NetErrorCode_NONE then
    local link = "https://www.pubgmobile.com/act/a20250612fitteam/index.html?region={country}&gameid={gameid}&nickname={nickname}&head_pic={head_pic}&never_adjust=1"
    if not LogicFriend.InviteChannnel then
      LogicFriend.InviteChannnel = LogicFriend.InviteByMessenger
    end
    local src = LogicFriend.InviteChannnel
    local uid = DataMgr.roleData.uid
    local moduleTxt = "&module=1003100"
    local link = link .. moduleTxt .. "&teamid=" .. teamid .. "&src=" .. src .. "&uid=" .. uid
    local webModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.webModule)
    link = webModule:AddParameterByPersonalInfo(link, false, true)
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    if Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
      log(bWriteLog and "LogicFriend.on_invite_offline_friend_rsp BLUEHOLE")
      if LogicFriend.TokenType == AdjustSystem.E_TokenType.InviteFriend then
        link = LogicFriend.ConstructInviteLink(Client.GetCurrentLanguage(), DataMgr.roleData.uid, teamid, LogicFriend.InviteChannnel)
      else
        link = LogicFriend.ConstructMessageInviteLink(Client.GetCurrentLanguage(), DataMgr.roleData.uid, teamid, LogicFriend.InviteChannnel)
      end
    end
    local OnGetUrl = function(shareUrl)
      local title = LocUtil.GetLocalizeResStr("106052")
      local content_noUrl = LocUtil.GetLocalizeResStr("4488")
      local content = content_noUrl .. " " .. shareUrl
      log(bWriteLog and "LogicFriend.OnGetUrl content" .. tostring(content))
      if LogicFriend.InviteChannnel == LogicFriend.InviteByMessenger then
        Client.InviteFBOfflineFriends(NetInterface, title, content_noUrl, shareUrl)
      elseif LogicFriend.InviteChannnel == LogicFriend.InviteBySMS then
        Client.InviteSMSOfflineFriends(NetInterface, content)
      elseif LogicFriend.InviteChannnel == LogicFriend.InviteByWhatsapp then
        Client.InviteWhatsappOfflineFriends(NetInterface, title, content)
      elseif LogicFriend.InviteChannnel == LogicFriend.InviteByMore then
        Client.InviteSystemOfflineFriends(NetInterface, title, content)
      elseif LogicFriend.InviteChannnel == LogicFriend.InviteByLine then
        Client.InviteLineOfflineFriends(NetInterface, title, content)
      end
    end
    local ShareMgr = require("client.logic.share.share_logic")
    ShareMgr.GetShortUrl(link, OnGetUrl)
  elseif res == "team_is_full" then
    ShowNotice(110019)
  elseif res == "already_in_room" then
    ShowNotice(512217)
  end
end
function LogicFriend.ConstructInviteLink(language, uid, teamid, source)
  local AdjustSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.AdjustSystem)
  local adjToken = AdjustSystem:GetRegionToken(AdjustSystem.E_TokenType.InviteFriend)
  return LogicFriend.PrivateConstructInviteLink(language, uid, teamid, source, adjToken)
end
function LogicFriend.ConstructMessageInviteLink(language, uid, teamid, source)
  local AdjustSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.AdjustSystem)
  local adjToken = AdjustSystem:GetRegionToken(AdjustSystem.E_TokenType.MessageInvite)
  return LogicFriend.PrivateConstructInviteLink(language, uid, teamid, source, adjToken)
end
function LogicFriend.PrivateConstructInviteLink(language, uid, teamid, source, adjToken)
  local AdjustSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.AdjustSystem)
  local domain = AdjustSystem:GetShareLinkDomain()
  local cr = AdjustSystem:GetShareLinkCr()
  local logic_deeplink = require("client.slua.logic.deeplink.logic_deeplink")
  local link = domain .. language .. "/event/inviteplay/index.html?module=1003100&uid=" .. uid .. "&teamid=" .. teamid .. "&src=" .. source .. "&adjust_t=" .. adjToken .. "&adjust_deeplink=" .. FuncUtil.GetKeywordByID(3377010) .. logic_deeplink:GetDeeplinkUrlSchemeAppId() .. "%3a%2f%2fmodule%3d1003100%26uid%3d" .. uid .. "%26teamid%3d" .. teamid .. "%26src%3d" .. source .. "&cr=" .. cr
  log(bWriteLog and "LogicFriend.ConstructInviteLink, link = " .. link)
  return link
end
function LogicFriend.HasFriend()
  return next(friendDataMap)
end
function LogicFriend.ShowReserveBack2LobbyNotify()
  if not GameStatus.IsInLobbyOrMainCity() then
    return
  end
  local logic_friend_reserve = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_reserve)
  logic_friend_reserve:OnGetAllAgreeResreveInfo(LogicFriend.ReserveBack2Lobby)
end
function LogicFriend.ShowReserveFriendGameEndNotify(num_uid, from)
  log(bWriteLog and "[v_wllwu] LogicFriend.ShowReserveFriendGameEndNotify, num_uid = " .. tostring(num_uid) .. " from = " .. tostring(from))
  if not GameStatus.IsInLobbyOrMainCity() then
    log(bWriteLog and "[v_wllwu] LogicFriend.ShowReserveFriendGameEndNotify return ")
    return
  end
  local logic_friend_reserve = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_reserve)
  logic_friend_reserve:OnFriendCompleteGame(num_uid, from)
end
function LogicFriend.on_appointment_game_friend_notify(uid, from)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(uid)
  if nil == profile then
    return
  end
  local logic_friend_reserve = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_reserve)
  logic_friend_reserve:OnGetOtherReserveInvite(uid, from)
  if not logic_friend_reserve:IsSingleGameReserveOpen() then
    log(bWriteLog and "[v_wllwu] LogicFriend.on_appointment_game_friend_notify auto refused")
    LogicFriend.appointment_game_friend_answer(uid, 0)
    return
  end
  IngameChat:on_reserve_require_notify(tostring(uid), profile.nickName)
end
function LogicFriend.appointment_game_friend_req(uid, from, msg_id)
  if nil == uid or "" == uid then
    return
  end
  log(bWriteLog and " LogicFriend.appointment_game_friend_req")
  local logic_friend_reserve = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_reserve)
  logic_friend_reserve:UpdateStateAfterReserve(tonumber(uid), msg_id, from)
  local FriendHandler = require("client.network.Protocol.FriendHandler")
  FriendHandler.send_appointment_game_friend_req(tonumber(uid), from, msg_id)
end
function LogicFriend.on_appointment_game_friend_res(uid, result, from, invite_info)
  local LogicLobbyWatching = require("client.logic.watching.logic_lobby_watching")
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  log(bWriteLog and "LogicFriend.on_appointment_game_friend_res, uid = " .. tostring(uid) .. " result = " .. tostring(result) .. " from = " .. tostring(from))
  local profile = logic_profile:GetLocalProfile(uid)
  if nil == profile then
    return
  end
  local logic_friend_reserve = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_reserve)
  logic_friend_reserve:UpdateFriendReserveState(uid, invite_info, result)
  if result == 0 or result == 1 then
    logic_friend_reserve:OnGetFriendAnswer(uid, result, from)
  elseif result == -2 then
    ShowNotice(44053)
  elseif result == -1 then
    ShowNotice(44054)
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    logic_profile:ModifyFriendReserveSwitch(uid, 0)
  else
    if result == logic_friend_reserve.ErrorCodeConfig.err_friend_appointment_enter_waiting then
      log_tree(bWriteLog and "[v_wllwu] LogicFriend.on_appointment_game_friend_res, invite_info", invite_info)
      if type(invite_info) == "table" and invite_info.msg_id then
        local msgStr = logic_friend_reserve:GetStrByMsgId(invite_info.msg_id)
        logic_friend_reserve:SendChatReserveMsg(uid, msgStr)
      end
      return
    end
    logic_friend_reserve:HandleErrorCode(result)
  end
  EventSystem:postEvent(EVENTTYPE_CHAT, EVENTTYPE_CHAT_RESERVE_RESPONSE)
end
function LogicFriend.appointment_game_friend_answer(uid, bReply)
  log(bWriteLog and "LogicFriend.appointment_game_friend_answer, uid = " .. tostring(uid) .. " result = " .. tostring(bReply))
  if nil == uid or "" == uid then
    return
  end
  if not LogicFriend.IsMyFriend(uid) then
    log(bWriteLog and "[v_wllwu] LogicFriend.appointment_game_friend_answer return")
    return
  end
  uid = tonumber(uid)
  local logic_friend_reserve = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_reserve)
  local reply = 0
  if bReply == 1 or bReply == true then
    reply = 1
    ClientSendBAReport(TLogEventDefine.LobbyReservation, 1)
  else
    ClientSendBAReport(TLogEventDefine.LobbyReservation, 2)
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local from = logic_friend_reserve:GetOtherReserveFrom(uid) or TeamUpNewSystem.E_InviteFromType.Appointment
  logic_friend_reserve:DeleteOtherReserveRecord(uid)
  local FriendHandler = require("client.network.Protocol.FriendHandler")
  FriendHandler.send_appointment_game_friend_answer(uid, reply, from)
  if reply == 1 then
    logic_friend_reserve:SendChatReserveMsg(uid, LocUtil.GetLocalizeResStr(44035))
  else
    logic_friend_reserve:SendChatReserveMsg(uid, LocUtil.GetLocalizeResStr(44036))
  end
end
function LogicFriend.on_notify_appointment_friend_list(fri_list)
  if nil == fri_list or next(fri_list) == nil then
    log(bWriteLog and "LobbyChatSystem.on_reserve_backto_lobby_notify empty list")
    return
  end
  LogicFriend.ReserveBack2Lobby = fri_list
  log_tree(bWriteLog and "[v_wllwu] LogicFriend.on_notify_appointment_friend_list", fri_list)
  local time_ticker = require("common.time_ticker")
  local timer
  timer = time_ticker.AddTimerLoop(0, function()
    if GameStatus.IsInLobbyOrMainCity() then
      LogicFriend.ShowReserveBack2LobbyNotify()
      time_ticker.RemoveTimer(timer)
    end
  end, TIMER_INFINITE, 1)
end
function LogicFriend.on_appointment_friend_game_end(num_uid)
  num_uid = tonumber(num_uid)
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local from = TeamUpNewSystem.E_InviteFromType.Appointment
  local logic_friend_reserve = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_reserve)
  local reserveInfo = logic_friend_reserve:GetReserveInfoByUid(num_uid)
  if reserveInfo and reserveInfo.from then
    from = reserveInfo.from
  end
  LogicFriend.ShowReserveFriendGameEndNotify(num_uid, from)
end
function LogicFriend.ParsePassInfo(UPassInfo)
  local UPassIsBuy = false
  local UPassIsShow = false
  local UPassKeepBuy = 0
  local UpassValue = 0
  local pass_type = 0
  if UPassInfo then
    if UPassInfo.is_buy then
      if UPassInfo.is_buy == 0 then
        UPassIsBuy = false
      else
        UPassIsBuy = true
      end
    else
      UPassIsBuy = false
    end
    if UPassInfo.switch then
      UPassIsShow = UPassInfo.switch.ui or false
    else
      UPassIsShow = false
    end
    UPassKeepBuy = UPassInfo.keep_buy or 0
    UpassValue = UPassInfo.cur_value or 0
    pass_type = UPassInfo.pass_type or 0
  end
  return UPassIsBuy, UPassIsShow, UPassKeepBuy, UpassValue, pass_type
end
function LogicFriend.JoinFriend(uid, from)
  local isMatch = LobbySystem.isInMatch
  if isMatch then
    log(bWriteLog and "EventClickInviteFriendBtn isMatch:")
    ShowNotice(110122)
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if not TeamUpNewSystem.CanInviteFriend() then
    return
  end
  log(bWriteLog and "EventClickJoinBtn GID: " .. uid)
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission() then
    local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
    local status = PlayerStatusMgr:GetStatusData(uid)
    if not status.tplan_type or status.tplan_type == 0 then
      local title = LocUtil.GetLocalizeResStr(101001)
      local content = LocUtil.GetLocalizeResStr(35198)
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.ShowTPlan(2, title, content, function()
        local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
        LogicTxMissionMain.QuitXMissionByJoinTeam(uid)
      end)
      return
    end
    TeamUpNewSystem.team_apply_request(uid, TeamUpNewSystem.E_InviteFromType.TPlan)
  else
    TeamUpNewSystem.team_apply_request(uid, from)
  end
end
function LogicFriend.InviteFriend(uid, from)
  local isInRoomWaiting = RoomSystem.IsShowWaiting()
  uid = tonumber(uid) or 0
  if isInRoomWaiting then
    log(bWriteLog and "LogicFriend.InviteFriend Go Room GID:" .. uid)
    RoomSystem.room_invite_request(uid)
  else
    local isMatch = LobbySystem.isInMatch
    if isMatch then
      log(bWriteLog and "LogicFriend.InviteFriend isMatch: ")
      ShowNotice(110122)
      return
    end
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    if not TeamUpNewSystem.CanInviteFriend(uid) then
      return
    end
    log(bWriteLog and "LogicFriend.InviteFriend GID: " .. uid)
    TeamUpNewSystem.team_invite_request(uid, from)
  end
end
local sendTime = 0
function LogicFriend.GetFriendOnlineCount()
  local totalCount = 0
  local onlineCount = 0
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  local logic_friend_blacklist = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_blacklist)
  local blackMap = logic_friend_blacklist:GetBlackMap()
  local dataMapCount = 0
  for _, v in pairs(friendDataMap) do
    dataMapCount = dataMapCount + 1
    if not blackMap[v.uid] then
      totalCount = totalCount + 1
      local status = PlayerStatusMgr:GetStatusData(v.uid)
      if status and status.online and 0 < status.online then
        onlineCount = onlineCount + 1
      end
    end
  end
  return onlineCount, totalCount, dataMapCount
end
function LogicFriend.ChangeIgnoreFriendTime()
  LogicFriend.ignoreFriendTime = not LogicFriend.ignoreFriendTime
  log(bWriteLog and "[v_wllwu]LogicFriend.ChangeIgnoreFriendTime, result = " .. tostring(LogicFriend.ignoreFriendTime))
end
function LogicFriend.ReserveFriend(UID, from, msg_id)
  if not msg_id then
    local logic_friend_reserve = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_reserve)
    local defaultMsg = logic_friend_reserve:GetDefaultReserveMsg()
    msg_id = defaultMsg and defaultMsg.id
  end
  LogicFriend.appointment_game_friend_req(UID, from, msg_id)
end
function LogicFriend.ShowIntimateRelationComplaint(uid, name, reportRelationName)
  local LogicComplaint = require("client.logic.battle.logic_complaint")
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  local info = {
    chatUID = uid,
    chatName = name,
    chatContent = reportRelationName,
    isVoice = false,
    ChatType = 0,
    CliSourceId = chat_macro.CliSourceId.IntimateRelation
  }
  LogicComplaint.ShowComplaint(LogicComplaint.EComplaintFrom.IntimateRelation, info)
end
function LogicFriend.on_do_friend_top_op_rsp(ret_list)
  for i, v in pairs(friendDataMap) do
    v.isTop = false
    v.SetTopTimeStamp = 0
    if ret_list[i] then
      v.isTop = true
      v.SetTopTimeStamp = ret_list[i]
    end
  end
  EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_TOP_STATUS_CHANGE)
end
function LogicFriend.OpenTeamUpSideBar()
  local LogicTeamUpSideBar = require("client.slua.logic.lobby.logic_teamup_side_bar")
  LogicTeamUpSideBar.ShowTeamUpSideBar(LogicTeamUpSideBar.ENUM_OPEN_FROM.LOBBY)
end
function LogicFriend.GetLoginChannelIcon()
  if LogicFriend._path then
    log(bWriteLog and "LogicFriend:ShowLoginChannel _path " .. tostring(LogicFriend._path))
    return LogicFriend._path, LogicFriend.ImageInviteTintColor
  end
  local path = "/Game/UMG/Texture_200/Atlas/LobbyUI/Frames/Lobby_Icon_Invite_png.Lobby_Icon_Invite_png"
  local tintColor = FSlateColor(FLinearColor(1, 1, 1, 1))
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  local loginChannel = IMSDKHelperInstance:GetCurLoginPlatform()
  log(bWriteLog and "LogicFriend:loginChannel " .. tostring(loginChannel))
  if LogicFriend.loginchannel_icon_path[loginChannel] then
    path = LogicFriend.loginchannel_icon_path[loginChannel]
    tintColor = FSlateColor(FLinearColor(1, 1, 1, 1))
  end
  log(bWriteLog and "LogicFriend:ShowLoginChannel path " .. tostring(path))
  LogicFriend._  LogicFriend.ImageInviteTintColor = tintColor
  return path, tintColor
end
function LogicFriend.GetInMainCityFreeFriendList()
  local PlayerStatusEnum = require("client.slua.logic.player_status.PlayerStatusEnum")
  local PlayerStatusUtil = require("client.slua.logic.player_status.PlayerStatusUtil")
  local list = {}
  local battleFriendList = LogicFriend.GetAllFriendList(true, nil, PlayerStatusEnum.Enum_TeamState.Battle)
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  for i, v in ipairs(battleFriendList) do
    local status = PlayerStatusMgr:GetStatusData(v)
    if status and PlayerStatusUtil.IsMainCityIdle(status) then
      table.insert(list, v)
    end
  end
  log_tree(bWriteLog and "LogicFriend.GetInMainCityFreeFriendList list", list)
  return list
end
function LogicFriend.IsAlreadyBonding(uid)
  local IntimacyConst = require("client.slua.logic.friend.Intimacy.IntimacyConst")
  local logic_friend_intimacy = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_intimacy)
  local ct = logic_friend_intimacy:GetIntimacyCountByRelationAndState(uid, IntimacyConst.EIntimacyType.Bonding, IntimacyConst.EStateType.Has_Build)
  return 0 < ct
end
function LogicFriend.IsAlreadyBondingApplying(uid)
  local IntimacyConst = require("client.slua.logic.friend.Intimacy.IntimacyConst")
  local logic_friend_intimacy = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_intimacy)
  local ct = logic_friend_intimacy:GetIntimacyCountByRelationAndState(uid, IntimacyConst.EIntimacyType.Bonding, IntimacyConst.EStateType.Has_Send)
  return 0 < ct
end
return LogicFriend