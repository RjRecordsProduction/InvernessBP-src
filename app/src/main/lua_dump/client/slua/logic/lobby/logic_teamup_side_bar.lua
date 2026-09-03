local SuperList = require("common.super_list")
local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
local IntimacyConst = require("client.slua.logic.friend.Intimacy.IntimacyConst")
local friend_list_macros = require("client.slua.logic.friend.refactor.friend_list_macros")
local PlayerStatusUtil = require("client.slua.logic.player_status.PlayerStatusUtil")
local logic_teamup_side_bar = {
  ENUM_OPEN_FROM = friend_list_macros.ENUM_OPEN_FROM,
  ENUM_TAB = friend_list_macros.ENUM_TAB,
  EnableRecommend = false,
  SetDataToFriends = false,
  FetchRecentCD = 10,
  FetchRecentTime = 0,
  recallerIdList = {},
  tag = 1
}
local Recent = SuperList.Create()
local Crews = SuperList.Create()
local Corps = SuperList.Create()
local Nears = SuperList.Create()
local E_CREW = 2
local E_CORPS = 3
local E_RECENT = 1
local E_FRIENDS = 0
local E_NEAR = 4
local Recommend = {}
local ProtocolWaitMap
function logic_teamup_side_bar.FetchFriends()
end
function logic_teamup_side_bar.FetchRecent(callBack)
  local IDs = LogicFriend.GetRecentTeammateIDList()
  if next(IDs) then
    local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
    PlayerStatusMgr:GetOrReqStatusData(ENUM_BATCH_GET_GROUP_AND_ONLINE.RecentTeammate, IDs, function()
      EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_UPDATE_RECENT_STATUS)
      EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_RECENT_STATE_UPDATE)
    end)
  else
    Recent:SetData(IDs)
    if callBack then
      callBack()
    end
  end
end
function logic_teamup_side_bar.OnRecentReqResponse()
  Recent:SetData(LogicFriend.GetRecentTeammateList(true))
end
function logic_teamup_side_bar.FetchCrew()
  local ESportSquadSystem = require("client.slua.logic.esport.logic_esport_squad")
  local CrewMembers = ESportSquadSystem.GetTeamProfileListWithoutSelf()
  for _, v in pairs(CrewMembers) do
    v.upass_keep_buy = v.upass_keep
    if LogicFriend.IsMyFriend(v.uid) then
      local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
      local status = PlayerStatusMgr:GetStatusData(v.uid)
      v.enable_watch = status.enable_watch
    end
  end
  Crews:SetData(CrewMembers)
end
local CopyCorpsBaseInfo = function(player)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(player.id) or {}
  local _video_inspect = false
  if player.online_info and player.online_info.is_video_inspect then
    _video_inspect = player.online_info.is_video_inspect
  end
  local member = {
    uid = player.id,
    enable_watch = 0,
    week_active = player.week_active,
    is  }
  if LogicFriend.IsMyFriend(member.uid) then
    member.enable_watch = profile.enableWatch or 0
  end
  return member
end
function logic_teamup_side_bar.FetchCorps(data, callBack, isReq)
  local IDs = {}
  local Members = {}
  for _, player in pairs(data) do
    if player.id ~= tonumber(DataMgr.roleData.uid) then
      table.insert(Members, CopyCorpsBaseInfo(player))
      table.insert(IDs, player.id)
    end
  end
  Corps:SetData(Members)
  if isReq then
    if next(IDs) then
      local CorpsMemberSystem = require("client.slua.logic.corps.logic_corps_member")
      CorpsMemberSystem.get_corps_member_online_info_req()
    else
      Corps:SetData(IDs)
      if callBack then
        callBack()
      end
    end
  end
end
function logic_teamup_side_bar.AssembleCorps(data)
  local Members = {}
  for _, player in pairs(data) do
    if not DataMgr.IsMe(player.id) then
      local member = {}
      member.uid = player.id
      member.week_active = player.week_active
      logic_teamup_side_bar.UpdateCorpsMemberStatus(player.id, member)
      table.insert(Members, member)
    end
  end
  Corps:SetData(Members)
end
function logic_teamup_side_bar.UpdateCorpsMembersStatus(IDList)
  if not IDList then
    return
  end
  local IDs = {}
  for _, ID in pairs(IDList) do
    IDs[ID] = true
  end
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  for _, member in pairs(Corps) do
    local status = PlayerStatusMgr:GetStatusData(member.uid)
    if status and IDs[member.uid] then
      member.online = status.online or 0
      member.game_id = status.game_id or 0
      member.land_id = status.land_id or 0
      member.teamState = status.teamState or 0
      member.maxTeamAmount = status.maxTeamAmount or 4
      member.socialland_type = status.socialland_type or 0
      member.currentTeamAmount = status.currentTeamAmount or 1
      member.timeSinceGameBegin = status.timeSinceGameBegin
      member.tplan_type = status.tplan_type or 0
      member.cwow_type = status.cwow_type or 0
      if LogicFriend.IsMyFriend(member.uid) then
        member.enable_watch = status.enableWatch or 0
      else
        member.enable_watch = 0
      end
    end
  end
end
function logic_teamup_side_bar.OnProfileResponse(profileList)
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENT_PROFILE_RESPONSE, profileList)
end
function logic_teamup_side_bar.OnRankProfileResponse(profileList)
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENT_RANKPROFILE_RESPONSE, profileList)
end
function logic_teamup_side_bar.GetFriends(bIsOnlyInner)
  local logic_friend = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local logic_friend_blacklist = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_blacklist)
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  local IntimacyAwardSystem = require("client.slua.logic.person_space.logic_intimacy_award")
  local blackMap = logic_friend_blacklist:GetBlackMap()
  local firendData = logic_friend:GetFriendData()
  local insertSetMap = {}
  local array = {}
  local insertFunc = function(uid)
    if insertSetMap[uid] then
      return
    end
    local profile = logic_profile:GetLocalProfile(uid)
    if not profile then
      return
    end
    if blackMap[uid] then
      return
    end
    local v = LogicFriend.GetFriendData(uid)
    if not v then
      return
    end
    v.from = 0
    local status = PlayerStatusMgr:GetStatusData(uid)
    if status then
      v.online = status.online
      v.teamState = status.teamState
    else
      v.online = 0
      v.teamState = 0
    end
    v.lastOnlineTime = profile.lastOnlineTime
    v.level = profile.level
    if LogicFriend.GetRelation(v.uid) == IntimacyConst.EIntimacyType.Lover and IntimacyAwardSystem.CheckCanRankTopInFriends(v.intimacy) then
      v.bTopLover = true
    end
    v.nickName = profile.nickName
    table.insert(array, v)
    insertSetMap[uid] = true
  end
  if not firendData or not next(firendData) then
    log(bWriteLog and "logic_teamup_side_bar.GetFriends no data")
    return {}
  end
  if not bIsOnlyInner then
    for k, v in pairs(firendData.plat_list) do
      insertFunc(k)
    end
  end
  for k, v in pairs(firendData.inner_list) do
    insertFunc(k)
  end
  local sortFunc = logic_teamup_side_bar.FriendsSortFunc
  if logic_teamup_side_bar.EnableRecommend then
    sortFunc = logic_teamup_side_bar.SortFriendsWithRecommend
    for _, v in pairs(Recommend) do
      table.insert(array, v)
    end
  end
  table.sort(array, sortFunc)
  return array
end
function logic_teamup_side_bar.SetTag(tag)
  log(bWriteLog and "[v_mxiliu] logic_teamup_side_bar.SetTag tag = " .. tag)
  logic_teamup_side_bar.end
function logic_teamup_side_bar.TagIsRecently()
  log(bWriteLog and "[v_mxiliu] logic_teamup_side_bar.TagIsRecently start")
  if logic_teamup_side_bar.tag and logic_teamup_side_bar.tag == logic_teamup_side_bar.ENUM_RECENT_TAG then
    log(bWriteLog and "[v_mxiliu] logic_teamup_side_bar.TagIsRecently can report")
    return true
  end
  return false
end
function logic_teamup_side_bar.GetRecent()
  return Recent
end
function logic_teamup_side_bar.GetCrew()
  return Crews
end
function logic_teamup_side_bar.GetCorps()
  return Corps
end
function logic_teamup_side_bar.GetNears()
  return Nears
end
function logic_teamup_side_bar.IsInRoom()
  return UIManager.IsUIShow(UIManager.UI_Config.room_list) or RoomSystem.IsShowWaiting()
end
function logic_teamup_side_bar.ShowLobbyFriendEntrance()
end
function logic_teamup_side_bar.CloseLobbyFriendEntrance()
end
function logic_teamup_side_bar.ShowTeamUpSideBar(from, tab, modInfo)
  UIManager.ShowUI(UIManager.UI_Config.Lobby_InviteFriend_BP, from, tab, nil, modInfo)
end
function logic_teamup_side_bar.CloseTeamUpSideBar()
  UIManager.CloseUI(UIManager.UI_Config.Lobby_InviteFriend_BP)
end
function logic_teamup_side_bar.ShowWOWFriend(modInfo)
  local logic_ugc_mode = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_mode)
  local LogicTeamUpSideBar = require("client.slua.logic.lobby.logic_teamup_side_bar")
  local Data = LogicTeamUpSideBar.GetFriends() or {}
  local AllData = logic_ugc_mode:GetWOWFriendList(modInfo.mod_id, Data)
  local OnlineIndex = logic_ugc_mode:GetOnlinFriendIndex(AllData)
  local LogicTeamUpSideBar = require("client.slua.logic.lobby.logic_teamup_side_bar")
  local FLMacros = require("client.slua.logic.friend.refactor.friend_list_macros")
  if not AllData or #AllData <= 0 then
    LogicTeamUpSideBar.ShowTeamUpSideBar(FLMacros.ENUM_OPEN_FROM.WOWMod, FLMacros.ENUM_TAB.ENUM_FRIEND_TAG)
  elseif OnlineIndex == 0 then
    LogicTeamUpSideBar.ShowTeamUpSideBar(FLMacros.ENUM_OPEN_FROM.WOWMod, FLMacros.ENUM_TAB.ENUM_FRIEND_TAG, modInfo)
  else
    LogicTeamUpSideBar.ShowTeamUpSideBar(FLMacros.ENUM_OPEN_FROM.WOWMod, FLMacros.ENUM_TAB.ENUM_WOW_TAG, modInfo)
  end
end
function logic_teamup_side_bar.FriendsSortFunc(a, b)
  if a.bTopLover and not b.bTopLover then
    return true
  end
  if not a.bTopLover and b.bTopLover then
    return false
  end
  if a.isTop and not b.isTop then
    return true
  end
  if not a.isTop and b.isTop then
    return false
  end
  if a.isTop and b.isTop then
    return a.SetTopTimeStamp < b.SetTopTimeStamp
  end
  if a.online == nil or b.online == nil then
    return false
  end
  local isRecallerA = logic_teamup_side_bar.recallerIdList and logic_teamup_side_bar.recallerIdList[a.uid] ~= nil and 1 or 0
  local isRecallerB = logic_teamup_side_bar.recallerIdList and logic_teamup_side_bar.recallerIdList[b.uid] ~= nil and 1 or 0
  if a.online == 0 and b.online == 0 then
    if a.lastOnlineTime == nil then
      return false
    end
    if b.lastOnlineTime == nil then
      return true
    end
    if isRecallerA == isRecallerB then
      if a.lastOnlineTime == b.lastOnlineTime then
        if a.teamState == nil or b.teamState == nil then
          return false
        end
        if a.intimacy == nil or b.intimacy == nil then
          return false
        end
        if a.intimacy == b.intimacy then
          return a.level > b.level
        else
          return a.intimacy > b.intimacy
        end
      else
        return a.lastOnlineTime > b.lastOnlineTime
      end
    else
      return isRecallerA > isRecallerB
    end
  end
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
      if isRecallerA == isRecallerB then
        if a.intimacy == nil or b.intimacy == nil then
          return false
        end
        if a.intimacy == b.intimacy then
          if a.level == nil or b.level == nil then
            return false
          end
          if a.level == b.level then
            if a.lastOnlineTime == nil then
              return false
            end
            if a.lastOnlineTime == nil then
              return true
            end
            return a.lastOnlineTime > b.lastOnlineTime
          else
            return a.level > b.level
          end
        else
          return a.intimacy > b.intimacy
        end
      else
        return isRecallerA > isRecallerB
      end
    else
      return teamStateA < teamStateB
    end
  else
    return a.online > b.online
  end
end
function logic_teamup_side_bar.CorpsSortFunc(a, b)
  local CorpsMemberSystem = require("client.slua.logic.corps.logic_corps_member")
  local statusA = CorpsMemberSystem.GetOnlineStatus(a.uid)
  local statusB = CorpsMemberSystem.GetOnlineStatus(b.uid)
  local isRecallerA = logic_teamup_side_bar.recallerIdList and logic_teamup_side_bar.recallerIdList[a.uid] ~= nil and 1 or 0
  local isRecallerB = logic_teamup_side_bar.recallerIdList and logic_teamup_side_bar.recallerIdList[b.uid] ~= nil and 1 or 0
  if statusA.online == statusB.online then
    local teamStateA = statusA.teamState
    local teamStateB = statusB.teamState
    if teamStateA == nil or teamStateB == nil then
      return false
    end
    if PlayerStatusUtil.IsFree(statusA) then
      teamStateA = -1
    end
    if PlayerStatusUtil.IsFree(statusB) then
      teamStateB = -1
    end
    if teamStateA == teamStateB then
      if isRecallerA == isRecallerB then
        if a.week_active == nil or b.week_active == nil then
          return false
        end
        if a.week_active == b.week_active then
          return tonumber(a.uid) > tonumber(b.uid)
        end
        return a.week_active > b.week_active
      else
        return isRecallerA > isRecallerB
      end
    else
      return teamStateA < teamStateB
    end
  else
    return statusA.online > statusB.online
  end
end
function logic_teamup_side_bar.ClearData()
  Crews:ClearData()
  Corps:ClearData()
  Recent:ClearData()
  local LBSFriendMgr = require("client.slua.logic.lbs.logic_lbs_friend")
  LBSFriendMgr:ClearCache()
end
local Insert = function(ID)
  log(bWriteLog and "[LogicTeamUpSideBar] Insert " .. tostring(ID))
  if ProtocolWaitMap then
    ProtocolWaitMap[ID] = true
  end
end
local Remove = function(ID)
  log(bWriteLog and "[LogicTeamUpSideBar] Remove " .. tostring(ID))
  if ProtocolWaitMap then
    ProtocolWaitMap[ID] = nil
    if not next(ProtocolWaitMap) then
      logic_teamup_side_bar.GenerateRecommend()
      ProtocolWaitMap = nil
    end
  end
end
local InitWait = function()
  ProtocolWaitMap = {}
end
function logic_teamup_side_bar.Recommend(isFromSideBar)
  log(bWriteLog and "[LogicTeamUpSideBar] Recommend")
  InitWait()
  Insert(E_CORPS)
  Insert(E_RECENT)
  if isFromSideBar then
    logic_teamup_side_bar.SetDataToFriends = true
  else
    logic_teamup_side_bar.SetDataToFriends = false
  end
  EventSystem:registEvent(EVENTTYPE_FRIEND, EVENTID_UPDATE_RECENT_STATUS, logic_teamup_side_bar.OnReceiveRecent)
  EventSystem:registEvent(EVENTTYPE_CORPS, EVENTID_CORPS_GET_MEMBERLIST, logic_teamup_side_bar.OnReceiveCorps)
  logic_teamup_side_bar.FetchCrew()
  logic_teamup_side_bar.FetchRecent(logic_teamup_side_bar.OnReceiveRecent)
  local CorpsMemberSystem = require("client.slua.logic.corps.logic_corps_member")
  CorpsMemberSystem.GetCorpsMemberList()
end
function logic_teamup_side_bar.OnReceiveRecent()
  log(bWriteLog and "[LogicTeamUpSideBar] OnReceiveRecent")
  EventSystem:unregistEvent(EVENTTYPE_FRIEND, EVENTID_UPDATE_RECENT_STATUS, logic_teamup_side_bar.OnReceiveRecent)
  logic_teamup_side_bar.OnRecentReqResponse()
  Remove(E_RECENT)
end
function logic_teamup_side_bar.OnReceiveCorps(_, _, data)
  log(bWriteLog and "[LogicTeamUpSideBar] OnReceiveCorps")
  EventSystem:unregistEvent(EVENTTYPE_CORPS, EVENTID_CORPS_GET_MEMBERLIST, logic_teamup_side_bar.OnReceiveCorps)
  logic_teamup_side_bar.AssembleCorps(data)
  Remove(E_CORPS)
end
local OnlineAndNotFriend = function(t, map, players, from)
  local logic_friend_blacklist = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_blacklist)
  for _, v in pairs(players) do
    if v.online and v.online == 1 and v.uid and not LogicFriend.IsMyFriend(v.uid) and not logic_friend_blacklist:IsBlacklist(v.uid) and not map[v.uid] then
      log(bWriteLog and string.format("[LogicTeamUpSideBar] OnlineAndNotFriend find one UID : %s  From : %s", tostring(v.uid), tostring(from)))
      v.      map[v.uid] = true
      table.insert(t, v)
    end
  end
end
local RecentWithinOneWeek = function(t, map, players, from)
  local logic_friend_blacklist = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_blacklist)
  for _, v in pairs(players) do
    if v.online and v.online == 1 and v.uid and not LogicFriend.IsMyFriend(v.uid) and not logic_friend_blacklist:IsBlacklist(v.uid) and not map[v.uid] then
      local TimeUtil = require("client.common.time_util")
      if v.endtime and TimeUtil.GetServerTimeInSec() - v.endtime <= 604800 then
        log(bWriteLog and string.format("[LogicTeamUpSideBar] RecentWithinOneWeek find one UID : %s  From : %s", tostring(v.uid), tostring(v.from)))
        v.        map[v.uid] = true
        table.insert(t, v)
      end
    end
  end
end
local Head = function(n, t)
  local inner = {}
  table.sort(t, logic_teamup_side_bar.SortFriendsWithRecommend)
  for _, player in pairs(t) do
    if n <= #inner then
      break
    end
    table.insert(inner, player)
    log(bWriteLog and string.format("[LogicTeamUpSideBar] Head UID : %s  From : %s", tostring(player.uid), tostring(player.from)))
  end
  return inner
end
local merge = function(t1, t2)
  for _, v in pairs(t2) do
    table.insert(t1, v)
  end
  return t1
end
function logic_teamup_side_bar.GenerateRecommend()
  log(bWriteLog and "[LogicTeamUpSideBar] GenerateRecommend")
  local map = {}
  local list = {}
  RecentWithinOneWeek(list, map, Recent, E_RECENT)
  OnlineAndNotFriend(list, map, Crews, E_CREW)
  OnlineAndNotFriend(list, map, Corps, E_CORPS)
  Recommend = Head(4, list)
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  for _, v in pairs(Recommend) do
    local status = PlayerStatusMgr:GetStatusData(v.uid)
    if status then
      v.online = status.online
      v.teamState = status.teamState
    end
  end
  EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_PROFILE_CHANGE)
end
function logic_teamup_side_bar.GetFriendArray()
  log(bWriteLog and "[LogicFriend] Get friend array")
  local array = {}
  local logic_friend_blacklist = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_blacklist)
  local blackMap = logic_friend_blacklist:GetBlackMap()
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  local IntimacyAwardSystem = require("client.slua.logic.person_space.logic_intimacy_award")
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  for _, v in pairs(LogicFriend.GetAllFriendData()) do
    local profile = logic_profile:GetLocalProfile(v.uid)
    if profile and not blackMap[v.uid] then
      local data = v
      data.from = 0
      local status = PlayerStatusMgr:GetStatusData(v.uid)
      if status then
        v.online = status.online
        v.teamState = status.teamState
      else
        v.online = 0
        v.teamState = 0
      end
      v.lastOnlineTime = profile.lastOnlineTime
      v.level = profile.level
      if LogicFriend.GetRelation(v.uid) == IntimacyConst.EIntimacyType.Lover and IntimacyAwardSystem.CheckCanRankTopInFriends(v.intimacy) then
        v.bTopLover = true
      end
      v.nickName = profile.nickName
      table.insert(array, v)
    end
  end
  return array
end
function logic_teamup_side_bar.SortFriendsWithRecommend(a, b)
  if a.online == nil then
    return false
  end
  if b.online == nil then
    return true
  end
  if a.online ~= b.online then
    return a.online > b.online
  end
  if a.teamState == nil then
    return false
  end
  if b.teamState == nil then
    return true
  end
  local teamStateA = a.teamState
  local teamStateB = b.teamState
  if PlayerStatusUtil.IsFree(a) then
    teamStateA = -1
  end
  if PlayerStatusUtil.IsFree(b) then
    teamStateB = -1
  end
  if teamStateA ~= teamStateB then
    return teamStateA < teamStateB
  end
  if a.from == nil then
    return false
  end
  if b.from == nil then
    return true
  end
  if a.from ~= b.from then
    return a.from < b.from
  end
  if a.online == 0 and b.online == 0 and a.lastOnlineTime and b.lastOnlineTime then
    return a.lastOnlineTime > b.lastOnlineTime
  end
  if a.from == E_FRIENDS then
    if a.intimacy == nil then
      return false
    end
    if b.intimacy == nil then
      return true
    end
    if a.intimacy ~= b.intimacy then
      return a.intimacy > b.intimacy
    end
    if a.level == nil then
      return false
    end
    if b.level == nil then
      return true
    end
    if a.level ~= b.level then
      return a.level > b.level
    end
    if a.lastOnlineTime == nil then
      return false
    end
    if b.lastOnlineTime == nil then
      return true
    end
    return a.lastOnlineTime > b.lastOnlineTime
  elseif a.from == E_RECENT then
    if a.endtime == nil then
      return false
    end
    if b.endtime == nil then
      return true
    end
    if a.endtime ~= b.endtime then
      return a.endtime > b.endtime
    end
    if a.intimacy == nil then
      return false
    end
    if b.intimacy == nil then
      return true
    end
    if a.intimacy ~= b.intimacy then
      return a.intimacy < b.intimacy
    end
    if a.level == nil then
      return false
    end
    if b.level == nil then
      return true
    end
    if a.level ~= b.level then
      return a.level > b.level
    end
    if a.lastOnlineTime == nil then
      return false
    end
    if b.lastOnlineTime == nil then
      return true
    end
    return a.lastOnlineTime > b.lastOnlineTime
  elseif a.from == E_CREW then
    if a.level == nil then
      return false
    end
    if b.level == nil then
      return true
    end
    if a.level ~= b.level then
      return a.level > b.level
    end
    if a.lastOnlineTime == nil then
      return false
    end
    if b.lastOnlineTime == nil then
      return true
    end
    return a.lastOnlineTime > b.lastOnlineTime
  elseif a.from == E_CORPS then
    if a.week_active == nil then
      return false
    end
    if b.week_active == nil then
      return true
    end
    if a.week_active ~= b.week_active then
      return a.week_active > b.week_active
    end
    return tonumber(a.uid) > tonumber(b.uid)
  end
end
function logic_teamup_side_bar.HasRecommend()
  if Recommend and next(Recommend) then
    return true
  else
    return false
  end
end
function logic_teamup_side_bar.GetFriendsWithRecommend()
  log(bWriteLog and "logic_teamup_side_bar.GetFriendsWithRecommend")
  local list = merge(logic_teamup_side_bar.GetFriendArray(), Recommend)
  table.sort(list, logic_teamup_side_bar.SortFriendsWithRecommend)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local requests = {}
  for _, v in pairs(Recommend) do
    if not logic_profile:GetLocalProfile(v.uid) then
      log(bWriteLog and "[LogicTeamUpSideBar] GetFriendsWithRecommend player has no profile " .. tostring(v.uid))
      table.insert(requests, v.uid)
    end
  end
  if next(requests) then
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles(requests, logic_teamup_side_bar.OnProfileResponse, Enum_PROFILE_REPORT_CFG.FRIEND_LIST)
  end
  return list
end
function logic_teamup_side_bar.GetRecommendNum()
  if Recommend then
    return #Recommend
  else
    return 0
  end
end
function logic_teamup_side_bar.IsRecommendPlayer(UID)
  if Recommend then
    for _, player in pairs(Recommend) do
      if player.uid == UID then
        log(bWriteLog and "[LogicTeamUpSideBar] IsRecommendPlayer " .. tostring(UID))
        return true
      end
    end
  end
end
function logic_teamup_side_bar.OnRecommendStatusChange(UID, UpdateFunc)
  log(bWriteLog and "[LogicTeamUpSideBar] OnRecommendStatusChange " .. tostring(UID))
  for index, player in pairs(Recommend) do
    if player.uid and tonumber(player.uid) == tonumber(UID) then
      Recommend[index] = UpdateFunc(UID, player)
      break
    end
  end
end
function logic_teamup_side_bar.UpdateCorpsMemberStatus(UID, player)
  log(bWriteLog and "[LogicTeamUpSideBar] UpdateCorpsMemberStatus " .. tostring(UID))
  local CorpsMemberSystem = require("client.slua.logic.corps.logic_corps_member")
  local status = CorpsMemberSystem.GetOnlineStatus(UID)
  if status then
    for i, v in pairs(status) do
      player[i] = v
    end
  end
  return player
end
function logic_teamup_side_bar.UpdateCrewMemberStatus(UID, player)
  log(bWriteLog and "[LogicTeamUpSideBar] UpdateCrewMemberStatus " .. tostring(UID))
  for _, v in pairs(Crews) do
    if v.uid == UID then
      return v
    end
  end
  return player
end
function logic_teamup_side_bar.IsPlayerCorrespondsGivenRelation(filter, UID)
  local CorpsMemberSystem = require("client.slua.logic.corps.logic_corps_member")
  if string.find(filter, E_FRIENDS) and LogicFriend.IsMyFriend(UID) then
    log(bWriteLog and "[CertainPlayersInMyTeam] is friend " .. tostring(UID))
    return true
  end
  if string.find(filter, E_RECENT) and LogicFriend.GetRecentTeammateData(UID) then
    log(bWriteLog and "[CertainPlayersInMyTeam] is recent " .. tostring(UID))
    return true
  end
  if string.find(filter, E_CREW) then
    local ESportSquadSystem = require("client.slua.logic.esport.logic_esport_squad")
    local CrewMembers = ESportSquadSystem.GetTeamProfileListWithoutSelf()
    for _, player in pairs(CrewMembers) do
      if tonumber(UID) == tonumber(player.gid) then
        log(bWriteLog and "[CertainPlayersInMyTeam] is crew " .. tostring(UID))
        return true
      end
    end
  end
  if string.find(filter, E_CORPS) and CorpsMemberSystem.isInit and DataMgr.corpsInfo.corpsMemberList then
    for _, player in pairs(DataMgr.corpsInfo.corpsMemberList) do
      if tonumber(UID) == tonumber(player.id) then
        log(bWriteLog and "[CertainPlayersInMyTeam] is corps " .. tostring(UID))
        return true
      end
    end
  end
  return false
end
return logic_teamup_side_bar