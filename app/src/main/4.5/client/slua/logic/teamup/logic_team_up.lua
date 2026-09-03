local TeamUpNewSystem = {
  teamInfo = {
    members = {}
  },
  nInviter = 0,
  nInviterTeamID = 0,
  nInviterRoomID = 0,
  nApplierID = 0,
  nApplierTeamID = 0,
  inviteApplyQueue = {},
  bInviteApplyShowing = false,
  nInviteApplyShowType = 0,
  nInviteApplyShowTime = 0,
  autoRefuseInviterMap = {},
  autoRefuseApplierMap = {},
  autoRefuseSoloMap = {},
  bIsAddMember = true,
  changeMemberInfo = {},
  changeWearInfo = {},
  headShowChangeInfo = {},
  changeWearPair = {},
  changeAvatarInfo = {},
  bHasEnterFighting = false,
  bIsFightingBackLobby = false,
  nCurTeamEmulatorType = -1,
  nWXPlatformInviteType = 0,
  nMsgIdGuid = 0,
  msgContentCacheMap = {},
  oneMoreGameTeamInfo = nil,
  oneMoreGameReplyList = {},
  nShowVehicleUID = 0,
  teamPriorIntimacyInfo = {},
  nVihicleVideoPlayingUser = nil,
  nShowTeamGroup = 1,
  nLastShowTeamGroup = nil
}
local E_InviteFromType = {
  Normal = 0,
  TeamTask = 1,
  TeamRecruit = 2,
  CorpsRecruitWithTeamTask = 3,
  TeamRecruitWithTeamTask = 4,
  Appointment = 5,
  TeamConscribe = 6,
  TPlan = 7,
  TPlanTeamConscribe = 8,
  MagicWish = 9,
  AllStar = 10,
  BeatIt = 11,
  PanJam = 12,
  TapJoy = 13,
  CommunityLive = 14,
  NearsFriend = 15,
  InviteFreeFriend = 16,
  FriendReserveList = 17,
  ChannelSocialIslandChat = 18,
  ChannelWorld = 19,
  ChannelTeamRecruit = 20,
  ChannelPrivate = 21,
  ChannelLBS = 22,
  ChannelCorps = 23,
  ChannelClub = 24,
  ChannelTopic = 25,
  FriendBar = 26,
  RecentBar = 27,
  CorpsBar = 28,
  SocialIslandArena = 29,
  SocialIslandDuel = 30,
  SocialIslandPlayerInteract = 31,
  FightPlayerInteract = 32,
  MailMessageCenter = 33,
  FriendCare = 34,
  Sponsor = 35,
  Tournament = 36,
  FireBaseInvite = 37,
  SwtichModeFriendBar = 38,
  SwtichModeRecentBar = 39,
  SwtichModeCorpsBar = 40,
  SwtichModeAppointment = 41,
  SwtichModeNearsFriend = 42,
  SwtichModeFriendReserveList = 43,
  SwtichModeTPlan = 44,
  RecommendTeamFriend = 45,
  RecommendTeamCorps = 46,
  RecommendTeamStranger = 47,
  RecommendTeamFriendCorps = 48,
  ChannelSameAge = 49,
  TeamConscribeNew = 50,
  TPlanTeamConscribeNew = 51,
  RecommendTeamBackUser = 52,
  ChannelChatRoom = 53,
  WorldCup_LuckyStar = 54,
  ReturnFriendInteract = 55,
  WorldCup_LuckyStar_Stranger = 56,
  LuckyStar = 57,
  LuckyStar_Stranger = 58,
  CreativeWoW = 59,
  RecommendTeamSocialEdge = 60,
  RecommendTeamLuckyStar = 61,
  SoloPK = 62,
  WOWTeam = 63,
  MainCityInfoCard = 64,
  RecommendReturnPlayer = 65,
  WOWTogether = 66,
  MainCityInteract = 67,
  NewbieChatChannelNewbie = 68,
  NewbieChatChannelMentor = 69,
  FlashTeam = 70,
  WoWEditorPro = 72
}
TeamUpNewSystem.local E_InviteTipType = {
  Invite = 0,
  Join = 1,
  RoomInvite = 2,
  AsiaRoomInvite = 3
}
TeamUpNewSystem.local C_AUTO_REFUSE_TIME_OUT = 300
local C_APPLY_INVITE_SHOW_TIME = 5
local C_APPLY_INVITE_CLOSE_TIME = 15
TeamUpNewSystem.local E_QUIT_TYPE = {
  TeamPlatform = 1,
  EnterXMission = 2,
  QuitXMission = 3
}
TeamUpNewSystem.local E_UI_TYPE = {
  TeamPlatformMain = 1,
  XMissionTeamPlatformMain = 2,
  LobbyMyTeamUI = 3,
  MentorUI = 4,
  LobbyMyXMissionTeamUI = 5,
  WoWTeamPlatformMain = 6,
  WOWLobbyMyTeamUI = 7,
  PeakTeamPlatformMain = 8,
  PeakLobbyMyTeamUI = 9,
  WowHallUI = 10,
  WowRoomUI = 11
}
local SCENETYPE = {MainCity = "MainCity"}
TeamUpNewSystem.local MatchSystem = require("client.slua.logic.match.logic_match")
function TeamUpNewSystem.OnModePostSwitch(preState, nextState)
  if nextState == GameStatus.Lobby then
    TeamUpNewSystem.Enter()
    if TeamUpNewSystem.IsInOneMoreGameTeam() then
      TeamUpNewSystem.ShowOneMoreGameInviteUI()
    end
  elseif nextState == GameStatus.Fighting and not GameStatus.IsInMainCity() then
    TeamUpNewSystem.ReleaseOneMoreGameInfo()
    TeamUpNewSystem.bHasEnterFighting = true
    local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
    LobbyAvatarManager.ResetAllHideAvatar()
  end
  local logic_teamup_action = require("client.slua.logic.teamup.logic_teamup_action")
  logic_teamup_action.ClearActionData()
end
function TeamUpNewSystem.CreateTeamUI()
  if IsWoWEditor then
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.team_main)
  local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
  logic_chat_voice:ShowAntsVoiceUI()
end
function TeamUpNewSystem.ShowTeamUI()
  local ui = UIManager.GetUI(UIManager.UI_Config.team_main)
  if ui then
    ui:SelfHitTestInvisible()
  end
  local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
  logic_chat_voice:ShowAntsVoiceUI()
end
function TeamUpNewSystem.HideTeamUI()
  local ui = UIManager.GetUI(UIManager.UI_Config.team_main)
  if ui then
    ui:Collapsed()
  end
  local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
  logic_chat_voice:HideAntsVoiceUI()
end
function TeamUpNewSystem.GetSelfUID()
  return tonumber(DataMgr.roleData.uid) or 0
end
function TeamUpNewSystem.GetTeamNum()
  local logic_xmission_room_team = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_room_team)
  if not logic_xmission_room_team:IsSelfInXmissionRoom() then
    return TeamUpNewSystem.RealGetTeamNum()
  else
    return logic_xmission_room_team:GetTeamNum()
  end
end
function TeamUpNewSystem.RealGetTeamNum()
  if TeamUpNewSystem.teamInfo then
    return TeamUpNewSystem.teamInfo.player_count or 1
  else
    return 1
  end
end
function TeamUpNewSystem.GetTeamAntsVoiceURL()
  if TeamUpNewSystem.teamInfo then
    local TableUtil = require("common.table_util")
    return TableUtil.GetTableValue(TeamUpNewSystem.teamInfo, "AntsVoice_url")
  else
    return ""
  end
end
function TeamUpNewSystem.GetTeamZoneID()
  if TeamUpNewSystem.teamInfo then
    return TeamUpNewSystem.teamInfo.zone_id or 1
  else
    return 1
  end
end
function TeamUpNewSystem.GetTeamID()
  if TeamUpNewSystem.teamInfo then
    return TeamUpNewSystem.teamInfo.id
  else
    return nil
  end
end
function TeamUpNewSystem.GetTeamLeader()
  if TeamUpNewSystem.teamInfo then
    return TeamUpNewSystem.teamInfo.leader
  end
end
local C_DefaultMaxTeamNum = 4
function TeamUpNewSystem.GetDefaultMaxTeamNum()
  return C_DefaultMaxTeamNum
end
function TeamUpNewSystem.GetMaxTeamNum()
  if not LobbySystem.CheckOpen(BP_ENUM_SWITCH_8PLAYERS_TEAM_UP) then
    return C_DefaultMaxTeamNum
  end
  local LogicUGCMulti = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMulti)
  if LogicUGCMulti.bIsBundleMatch then
    return LogicUGCMulti:GetMaxTeamSize()
  else
    local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
    local currModeMaxTeamNum = logic_mode_selection:GetModeMaxTeamNum()
    return currModeMaxTeamNum > C_DefaultMaxTeamNum and currModeMaxTeamNum or C_DefaultMaxTeamNum
  end
end
function TeamUpNewSystem.IsInLargeTeam()
  if not LobbySystem.CheckOpen(BP_ENUM_SWITCH_8PLAYERS_TEAM_UP) then
    return false
  end
  return TeamUpNewSystem.GetTeamNum() > TeamUpNewSystem.GetDefaultMaxTeamNum()
end
function TeamUpNewSystem.ShowExtraTeamUI()
  if not LobbySystem.CheckOpen(BP_ENUM_SWITCH_8PLAYERS_TEAM_UP) then
    return
  end
  local bShow = false
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local LogicUGCMulti = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMulti)
  if logic_mode_selection:IsSelect8PlayersMode() and not LogicUGCMulti.bIsBundleMatch then
    bShow = true
  elseif TeamUpNewSystem.GetTeamNum() > 4 then
    bShow = true
  end
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_LOBBY_SHOW_OR_HIDE_PANEL, bShow, "CanvasPanel_TeamExtra", UIManager.UI_Config.team_extra_main)
end
function TeamUpNewSystem.GetShowTeamGroup()
  if not LobbySystem.CheckOpen(BP_ENUM_SWITCH_8PLAYERS_TEAM_UP) then
    return 1
  end
  return TeamUpNewSystem.nShowTeamGroup
end
function TeamUpNewSystem.SwitchTeamGroup(group)
  if not LobbySystem.CheckOpen(BP_ENUM_SWITCH_8PLAYERS_TEAM_UP) then
    return
  end
  if group then
    TeamUpNewSystem.nShowTeamGroup = group
  else
    TeamUpNewSystem.nShowTeamGroup = TeamUpNewSystem.nShowTeamGroup == 1 and 2 or 1
  end
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  TeamAvatarManager.SwitchTeamGroup(TeamUpNewSystem.nShowTeamGroup)
  EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_SWITCH_SHOW_GROUP)
end
function TeamUpNewSystem.ForceSwitchTeamGroup(group)
  if not LobbySystem.CheckOpen(BP_ENUM_SWITCH_8PLAYERS_TEAM_UP) then
    return C_DefaultMaxTeamNum
  end
  if not group or group == TeamUpNewSystem.nShowTeamGroup then
    return
  end
  TeamUpNewSystem.nLastShowTeamGroup = TeamUpNewSystem.nShowTeamGroup
  TeamUpNewSystem.SwitchTeamGroup(group)
end
function TeamUpNewSystem.RevertTeamGroup()
  if not LobbySystem.CheckOpen(BP_ENUM_SWITCH_8PLAYERS_TEAM_UP) then
    return C_DefaultMaxTeamNum
  end
  if TeamUpNewSystem.nLastShowTeamGroup and TeamUpNewSystem.nLastShowTeamGroup ~= TeamUpNewSystem.nShowTeamGroup then
    TeamUpNewSystem.SwitchTeamGroup(TeamUpNewSystem.nLastShowTeamGroup)
  end
  TeamUpNewSystem.nLastShowTeamGroup = nil
end
function TeamUpNewSystem.FixTeamGroup()
  if not LobbySystem.CheckOpen(BP_ENUM_SWITCH_8PLAYERS_TEAM_UP) then
    return
  end
  if TeamUpNewSystem.nShowTeamGroup == 1 and not TeamUpNewSystem.nLastShowTeamGroup then
    return
  end
  if TeamUpNewSystem.GetTeamNum() <= C_DefaultMaxTeamNum then
    TeamUpNewSystem.nShowTeamGroup = 1
    if TeamUpNewSystem.nLastShowTeamGroup then
      TeamUpNewSystem.nLastShowTeamGroup = nil
      return
    end
    local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
    TeamAvatarManager.SwitchTeamGroup(TeamUpNewSystem.nShowTeamGroup)
    EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_SWITCH_SHOW_GROUP)
  end
end
function TeamUpNewSystem.InShowGroup(index)
  if not LobbySystem.CheckOpen(BP_ENUM_SWITCH_8PLAYERS_TEAM_UP) then
    return true
  end
  local beginIndex = (TeamUpNewSystem.nShowTeamGroup - 1) * C_DefaultMaxTeamNum
  local endIndex = TeamUpNewSystem.nShowTeamGroup * C_DefaultMaxTeamNum
  return index > beginIndex and index <= endIndex
end
function TeamUpNewSystem.GetTeamType()
  if TeamUpNewSystem.teamInfo then
    return TeamUpNewSystem.teamInfo.team_type or 0
  else
    return 0
  end
end
function TeamUpNewSystem.IsTeamLeader(uid)
  uid = tonumber(uid) or TeamUpNewSystem.GetSelfUID()
  if TeamUpNewSystem.teamInfo and TeamUpNewSystem.teamInfo.leader and uid and uid ~= TeamUpNewSystem.teamInfo.leader then
    return false
  end
  return true
end
function TeamUpNewSystem.GetTeamReadyInfo()
  log(bWriteLog and "TeamUpNewSystem.GetTeamReadyInfo")
  local readyCount = 0
  local totalCount = TeamUpNewSystem.GetTeamNum()
  if TeamUpNewSystem.teamInfo and TeamUpNewSystem.teamInfo.members then
    local leaderUID = TeamUpNewSystem.teamInfo.leader
    for uid, memberInfo in pairs(TeamUpNewSystem.teamInfo.members) do
      if uid == leaderUID or memberInfo.status == 1 then
        readyCount = readyCount + 1
      end
    end
  end
  log(bWriteLog and "TeamUpNewSystem.GetTeamReadyInfo readyCount = " .. tostring(readyCount) .. " totalCount = " .. tostring(totalCount))
  return readyCount, totalCount
end
function TeamUpNewSystem.GetMemberInfo(uid)
  if not uid then
    return nil
  end
  local logic_xmission_room_team = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_room_team)
  if logic_xmission_room_team:IsSelfInXmissionRoom() then
    return logic_xmission_room_team:GetRowMemberInfo(uid)
  end
  if TeamUpNewSystem.teamInfo and TeamUpNewSystem.teamInfo.members then
    return TeamUpNewSystem.teamInfo.members[tonumber(uid)]
  else
    return nil
  end
end
function TeamUpNewSystem.GetMemberRelationInfo(uid)
  log(bWriteLog and "[ZH] GetMemberRelationInfo")
  if not uid then
    return nil
  end
  if not (TeamUpNewSystem.teamInfo and TeamUpNewSystem.teamInfo.intimacy_info) or not next(TeamUpNewSystem.teamInfo.intimacy_info) then
    log(bWriteLog and "[ZH] TeamUpNewSystem.teamInfo or TeamUpNewSystem.teamInfo.intimacy_info is nil")
    local logic_new_friend = require("client.slua.logic.friend.logic_new_friend")
    local intimacyData = logic_new_friend.GetIntimacyData(uid)
    local relation = logic_new_friend.GetRelation(uid)
    if intimacyData and relation then
      return {
        relation = relation,
        intimacy = intimacyData.intimacy
      }
    end
    return nil
  end
  log_tree("[ZH]TeamUpNewSystem.intimacy_info", TeamUpNewSystem.teamInfo.intimacy_info)
  return TeamUpNewSystem.teamInfo.intimacy_info[tonumber(uid)]
end
function TeamUpNewSystem.GetMemberName(uid)
  uid = tonumber(uid)
  local info = TeamUpNewSystem.GetMemberInfo(uid)
  if info then
    return info.name
  else
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local friendData = logic_profile:GetLocalProfile(uid)
    if friendData then
      return friendData.nickName
    else
      return ""
    end
  end
end
function TeamUpNewSystem.GetMyStatus()
  if TeamUpNewSystem.teamInfo then
    local uid = TeamUpNewSystem.GetSelfUID()
    local myInfo = TeamUpNewSystem.GetMemberInfo(uid)
    if myInfo then
      return myInfo.status
    end
  end
  return 1
end
function TeamUpNewSystem.IsEverybodyReady()
  if not TeamUpNewSystem.teamInfo then
    return true
  end
  if TeamUpNewSystem.teamInfo.player_count and TeamUpNewSystem.teamInfo.player_count == 1 then
    return true
  end
  local leaderUID = TeamUpNewSystem.teamInfo.leader
  for k, v in pairs(TeamUpNewSystem.teamInfo.members) do
    if v.status ~= 1 and k ~= leaderUID then
      return false
    end
  end
  return true
end
function TeamUpNewSystem.IsAnyoneInGuiding()
  if not TeamUpNewSystem.teamInfo then
    log(bWriteLog and "TeamUpNewSystem.IsAnyoneInGuiding, return false")
    return false
  end
  if TeamUpNewSystem.teamInfo.player_count and TeamUpNewSystem.teamInfo.player_count == 1 then
    log(bWriteLog and "TeamUpNewSystem.IsAnyoneInGuiding, return false")
    return false
  end
  local leaderUID = TeamUpNewSystem.teamInfo.leader
  local LogicXMissionBeginnerGuide = require("client.slua.logic.TxMission.logic_xmission_beginner_guide")
  for k, v in pairs(TeamUpNewSystem.teamInfo.members) do
    if k ~= leaderUID and v.metro_team_info and v.metro_team_info.guide_progress < LogicXMissionBeginnerGuide.state_Equiped then
      log(bWriteLog and "TeamUpNewSystem.IsAnyoneInGuiding, return true")
      return true
    end
  end
  log(bWriteLog and "TeamUpNewSystem.IsAnyoneInGuiding, return false")
  return false
end
function TeamUpNewSystem.GetMemberClanName(uid)
  local memberInfo = TeamUpNewSystem.GetMemberInfo(tonumber(uid))
  if memberInfo then
    return memberInfo.carteam_name or ""
  else
    return ""
  end
end
function TeamUpNewSystem.IsOpenVoice(uid)
  local memberInfo = TeamUpNewSystem.GetMemberInfo(tonumber(uid))
  if memberInfo and memberInfo.voice then
    return memberInfo.voice.voice_open
  end
  return false
end
function TeamUpNewSystem.IsOpenSpeaker(uid)
  local memberInfo = TeamUpNewSystem.GetMemberInfo(tonumber(uid))
  if memberInfo and memberInfo.voice then
    return memberInfo.voice.trumpet_open
  end
  return false
end
function TeamUpNewSystem.GetPlayerRelation(uid)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  if LogicFriend.IsMyFriend(uid) then
    return "friend"
  end
  local strUid = tostring(uid)
  local CorpsMemberSystem = require("client.slua.logic.corps.logic_corps_member")
  if CorpsMemberSystem.isInit and DataMgr.corpsInfo.corpsMemberList then
    for _, player in pairs(DataMgr.corpsInfo.corpsMemberList) do
      if strUid == tostring(player.id) then
        return "corps"
      end
    end
  end
  if LogicFriend.GetRecentTeammateData(uid) then
    return "recent"
  end
  local logic_lbs_friend = require("client.slua.logic.lbs.logic_lbs_friend")
  local bNearFriend = logic_lbs_friend:IsNearsFriend(uid)
  if bNearFriend then
    return "lbsnearly"
  end
  return "other"
end
function TeamUpNewSystem.ShowInviteTip()
  if not UIManager.IsUIShow(UIManager.UI_Config.Return_Team_Guidance_UIBP) then
    UIManager.CloseUI(UIManager.UI_Config.Return_Team_Guidance_UIBP)
  end
  log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.ShowInviteTip")
  if GameStatus.IsInFightingNotSocialNotMainCityNotHome() then
    return
  end
  log_tree("[chub]TeamUpNewSystem.ShowInviteTip, TeamUpNewSystem.inviteApplyQueue = ", TeamUpNewSystem.inviteApplyQueue)
  if not TeamUpNewSystem.inviteApplyQueue or not TeamUpNewSystem.inviteApplyQueue[1] then
    TeamUpNewSystem.inviteApplyQueue = {}
    return
  end
  if not TeamUpNewSystem.IsInviteUIShow() then
    TeamUpNewSystem.RemoveSameInviteInfo()
    local inviteInfo = TeamUpNewSystem.inviteApplyQueue[1]
    if TeamUpNewSystem.IsRecommendType(inviteInfo) then
      UIManager.ShowUI(UIManager.UI_Config.Recommend_Team_Invite_Tip_UIBP, inviteInfo)
    elseif inviteInfo.from == E_InviteFromType.RecommendTeamBackUser and TeamUpNewSystem.CanShowAssemblyInviteTip() then
      UIManager.ShowUI(UIManager.UI_Config.Assembly_Team_Invite_Tip_UIBP, inviteInfo)
    elseif inviteInfo.from == E_InviteFromType.WOWTeam then
      log(bWriteLog and "TeamUpNewSystem.ShowInviteTip Show WOW_Team_Invite_Tip_UIBP")
      local ugcModID = inviteInfo.ugcModID
      local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
      LogicUGC:BatchGetModInfo({ugcModID}, LogicUGC.C_ModListTypes.team_invite_tip, function(MetaList, ListType, Param, bUseCache, FilterOfflineModList)
        local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
        if not UGCMacros.CheckMetaType(ListType, UGCMacros.ENUM_MODE_TYPE.team_invite_tip) then
          return
        end
        local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
        local cachedInfo = LogicUGC:GetModByWithoutPubCache(ugcModID)
        if cachedInfo then
          UIManager.ShowUI(UIManager.UI_Config.WOW_Team_Invite_Tip_UIBP, inviteInfo)
        else
          log(bWriteLog and "TeamUpNewSystem.ShowInviteTip Show WOW_Team_Invite_Tip_UIBP not has meta mod_id = " .. tostring(ugcModID))
        end
      end)
    else
      log(bWriteLog and "TeamUpNewSystem.ShowInviteTip Show Team_Invite_Tip_UIBP")
      UIManager.ShowUI(UIManager.UI_Config.Team_Invite_Tip_UIBP, inviteInfo)
    end
  end
end
function TeamUpNewSystem.RemoveCurInviteInfo()
  local _top = TeamUpNewSystem.inviteApplyQueue and TeamUpNewSystem.inviteApplyQueue[1]
  printf("TeamUpNewSystem.RemoveCurInviteInfo - top.inviter=%s top.teamId=%s queueLenBefore=%s", _top and _top.playerId or "nil", _top and _top.inviterTeamID or "nil", TeamUpNewSystem.inviteApplyQueue and #TeamUpNewSystem.inviteApplyQueue or 0)
  table.remove(TeamUpNewSystem.inviteApplyQueue, 1)
end
function TeamUpNewSystem.RemoveSameInviteInfo()
  local _len = TeamUpNewSystem.inviteApplyQueue and #TeamUpNewSystem.inviteApplyQueue
  if not _len or _len < 2 then
    return
  end
  local _top = TeamUpNewSystem.inviteApplyQueue[1]
  local _dedupCount = 0
  for i = _len, 2, -1 do
    local _cur = TeamUpNewSystem.inviteApplyQueue[i]
    if _cur and _cur.playerId == _top.playerId and _cur.inviterTeamID == _top.inviterTeamID and _cur.type == _top.type and _cur.from == _top.from then
      table.remove(TeamUpNewSystem.inviteApplyQueue, i)
      _dedupCount = _dedupCount + 1
    end
  end
  if 0 < _dedupCount then
    printf("TeamUpNewSystem.RemoveSameInviteInfo DEDUP-tail count=%s top.inviter=%s top.teamId=%s", _dedupCount, _top.playerId, _top.inviterTeamID)
  end
end
function TeamUpNewSystem.CanShowAssemblyInviteTip()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local bIsDifferentDate = PlayerPrefsSystem.CheckAndSaveCurrentDate_N(PlayerPrefsSystem.ePlayerPrefsType.eBackUserInviteTipsCheckTime, true)
  return bIsDifferentDate
end
function TeamUpNewSystem.ShowNextInviteTip()
  log(bWriteLog and "[chub]TeamUpNewSystem.ShowNextInviteTip()")
  TeamUpNewSystem.ShowInviteTip()
end
function TeamUpNewSystem.IsInviteUIShow()
  return UIManager.IsUIShow(UIManager.UI_Config.Team_Invite_Tip_UIBP) or UIManager.IsUIShow(UIManager.UI_Config.Recommend_Team_Invite_Tip_UIBP) or UIManager.IsUIShow(UIManager.UI_Config.Assembly_Team_Invite_Tip_UIBP) or UIManager.IsUIShow(UIManager.UI_Config.WOW_Team_Invite_Tip_UIBP)
end
function TeamUpNewSystem.IsInviteUIReadyToShow()
  if TeamUpNewSystem.inviteApplyQueue and next(TeamUpNewSystem.inviteApplyQueue) then
    return true
  end
  return false
end
function TeamUpNewSystem.IsRecommendType(info)
  if not info then
    return false
  end
  return info.from == E_InviteFromType.RecommendTeamFriend or info.from == E_InviteFromType.RecommendTeamCorps or info.from == E_InviteFromType.RecommendTeamStranger or info.from == E_InviteFromType.RecommendTeamFriendCorps or info.from == E_InviteFromType.RecommendTeamSocialEdge or info.from == E_InviteFromType.RecommendTeamLuckyStar or info.from == E_InviteFromType.RecommendReturnPlayer
end
function TeamUpNewSystem.CanInviteFriend(uid, NoTips)
  if TeamUpNewSystem.IsInOneMoreGameTeam() then
    if not NoTips then
      ShowNotice(8003)
    end
    return false
  end
  if not MatchSystem.CanInviteInBan() then
    log(bWriteLog and "TeamUpNewSystem.CanInviteFriend not MatchSystem.CanInviteInBan()")
    return false
  end
  if not uid then
    return true
  end
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  local status = PlayerStatusMgr:GetStatusData(uid)
  if status then
    local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
    if LogicTxMissionMain.IsInXMission() then
      if status.socialland_type and status.socialland_type == 1 then
        if not NoTips then
          ShowNotice(411028)
        end
        log(bWriteLog and "TeamUpNewSystem.CanInviteFriend status.socialland_type == 1")
        return false
      elseif status.cwow_type and status.cwow_type == 1 then
        if not NoTips then
          ShowNotice(411028)
        end
        log(bWriteLog and "TeamUpNewSystem.CanInviteFriend status.cwow_type == 1")
        return false
      end
    elseif status.tplan_type and status.tplan_type == 1 then
      if not NoTips then
        ShowNotice(411028)
      end
      log(bWriteLog and "TeamUpNewSystem.CanInviteFriend status.tplan_type == 1")
      return false
    elseif status.socialland_type and status.socialland_type == 1 then
      local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
      if logic_mode_selection:IsSelect8PlayersMode() then
        if not NoTips then
          ShowNotice(411028)
        end
        log(bWriteLog and "TeamUpNewSystem.CanInviteFriend status.socialland_type == 1")
        return false
      end
    elseif status.cwow_type and status.cwow_type == 1 then
      local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
      if logic_mode_selection:IsSelect8PlayersMode() then
        if not NoTips then
          ShowNotice(411028)
        end
        log(bWriteLog and "TeamUpNewSystem.CanInviteFriend status.cwow_type == 1")
        return false
      end
    end
  end
  local LogicUGCMulti = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMulti)
  if LogicUGCMulti.bIsBundleMatch then
    log(bWriteLog and string.format("TeamUpNewSystem.CanInviteFriend TeamUpNewSystem.GetTeamNum == %s, LogicUGCMulti:GetMaxTeamSize == %s", tostring(TeamUpNewSystem.GetTeamNum()), tostring(LogicUGCMulti:GetMaxTeamSize())))
    return TeamUpNewSystem.GetTeamNum() < LogicUGCMulti:GetMaxTeamSize()
  end
  return true
end
function TeamUpNewSystem.IsInTeam()
  if TeamUpNewSystem.teamInfo and TeamUpNewSystem.teamInfo.player_count then
    return TeamUpNewSystem.teamInfo.player_count > 1
  else
    return false
  end
end
function TeamUpNewSystem.SendInMainCity(is_3d)
  if TeamUpNewSystem.IsInTeam() then
    local TeamupHandler = require("client.network.Protocol.TeamupHandler")
    TeamupHandler.send_main_city_change_3d_req(is_3d)
  end
end
function TeamUpNewSystem.CanInvite()
  log_tree(bWriteLog and "TeamUpNewSystem.CanInvite teamInfo:", TeamUpNewSystem.teamInfo)
  log(bWriteLog and "TeamUpNewSystem.CanInvite maxTeamNum:" .. tostring(TeamUpNewSystem.GetMaxTeamNum()))
  if TeamUpNewSystem.teamInfo and TeamUpNewSystem.teamInfo.player_count then
    return TeamUpNewSystem.teamInfo.player_count < TeamUpNewSystem.GetMaxTeamNum()
  else
    return false
  end
end
function TeamUpNewSystem.CanTeamUp(bShowTips)
  if GameStatus.IsInFightingNotSocialNotMainCityNotHome() then
    return false
  end
  if TeamUpNewSystem.GetTeamNum() >= TeamUpNewSystem.GetMaxTeamNum() then
    return false
  end
  if TeamUpNewSystem.IsInOneMoreGameTeam() then
    if bShowTips == false then
    else
      ShowNotice(8003)
    end
    return false
  end
  if not MatchSystem.CanInviteInBan() then
    return false
  end
  if MatchSystem.nMatchStatus == ENUM_MatchStatus.Matching then
    return false
  end
  return true
end
function TeamUpNewSystem.IsMemberInSocialLand()
  if TeamUpNewSystem.teamInfo and TeamUpNewSystem.teamInfo.members then
    for i, memberInfo in pairs(TeamUpNewSystem.teamInfo.members) do
      if memberInfo.socialland_type and memberInfo.socialland_type == 1 then
        return true
      end
    end
  end
  return false
end
function TeamUpNewSystem.KeepJoinApply()
  if #TeamUpNewSystem.inviteApplyQueue > 0 and #TeamUpNewSystem.inviteApplyQueue > 0 then
    local inviteApplyData
    for i = #TeamUpNewSystem.inviteApplyQueue, 1, -1 do
      inviteApplyData = TeamUpNewSystem.inviteApplyQueue[i]
      if inviteApplyData then
        if inviteApplyData.type == E_InviteTipType.Invite then
          TeamUpNewSystem.team_invite_reply("autoRefuseOnTeamChange", tonumber(inviteApplyData.playerId), tonumber(inviteApplyData.inviterTeamID))
          table.remove(TeamUpNewSystem.inviteApplyQueue, i)
        elseif inviteApplyData.type == E_InviteTipType.RoomInvite or inviteApplyData.type == E_InviteTipType.AsiaRoomInvite then
          TeamUpNewSystem.room_invite_reply("autoRefuseOnTeamChange", tonumber(inviteApplyData.inviterRoomID), tonumber(inviteApplyData.playerId))
          table.remove(TeamUpNewSystem.inviteApplyQueue, i)
        end
      end
    end
  end
end
function TeamUpNewSystem.RemoveAllInvite()
  if #TeamUpNewSystem.inviteApplyQueue > 0 then
    for i = 1, #TeamUpNewSystem.inviteApplyQueue do
      local inviteApplyData = TeamUpNewSystem.inviteApplyQueue[i]
      if inviteApplyData.type == E_InviteTipType.Invite then
        TeamUpNewSystem.team_invite_reply("autoRefuseOnTeamChange", tonumber(inviteApplyData.playerId), tonumber(inviteApplyData.inviterTeamID))
      elseif inviteApplyData.type == E_InviteTipType.Join then
        TeamUpNewSystem.team_apply_reply("autoRefuseOnTeamChange", tonumber(inviteApplyData.playerId), tonumber(inviteApplyData.applierTeamID), inviteApplyData.src, inviteApplyData.from, inviteApplyData.signatur or "", inviteApplyData.playerName)
      elseif inviteApplyData.type == E_InviteTipType.RoomInvite or inviteApplyData.type == E_InviteTipType.AsiaRoomInvite then
        TeamUpNewSystem.room_invite_reply("autoRefuseOnTeamChange", tonumber(inviteApplyData.inviterRoomID), tonumber(inviteApplyData.playerId))
      end
    end
  end
  TeamUpNewSystem.inviteApplyQueue = {}
end
function TeamUpNewSystem.RemoveAllRoomInvite()
  log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.RemoveAllRoomInvite")
  if #TeamUpNewSystem.inviteApplyQueue > 0 then
    local inviteApplyData
    for k = #TeamUpNewSystem.inviteApplyQueue, 1, -1 do
      inviteApplyData = TeamUpNewSystem.inviteApplyQueue[k]
      if inviteApplyData and (inviteApplyData.type == E_InviteTipType.RoomInvite or inviteApplyData.type == E_InviteTipType.AsiaRoomInvite) and TeamUpNewSystem.inviter and TeamUpNewSystem.inviter == inviteApplyData.playerId then
        TeamUpNewSystem.room_invite_reply("autoRefuseOnTeamChange", tonumber(inviteApplyData.inviterRoomID), tonumber(inviteApplyData.playerId))
        table.remove(TeamUpNewSystem.inviteApplyQueue, k)
      end
    end
  end
end
function TeamUpNewSystem.RemoveInvite(index)
  for i, v in ipairs(TeamUpNewSystem.inviteApplyQueue) do
    if i == index and v then
      table.remove(TeamUpNewSystem.inviteApplyQueue, i)
      break
    end
  end
end
function TeamUpNewSystem.UpdateTeamMemberWear(uid, wear_ext, wear_ext_res)
  local memberInfo = TeamUpNewSystem.GetMemberInfo(tonumber(uid))
  if not memberInfo then
    return
  end
  if memberInfo.wear_ext then
    memberInfo.wear_ext = wear_ext_res
  else
    log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.UpdateTeamMemberWear memberInfo.wear_ext == nil")
  end
  if memberInfo.ware then
    memberInfo.ware = wear_ext
  else
    log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.UpdateTeamMemberWear memberInfo.ware == nil")
  end
end
function TeamUpNewSystem.on_stranger_staus_rsp(infos)
  local curUID = 0
  local strangerStatus = {}
  if infos then
    for k, v in pairs(infos) do
      curUID = k
      strangerStatus = v
      break
    end
  end
  if 0 < curUID then
    local myInfo = TeamUpNewSystem.GetMemberInfo(curUID)
    if not myInfo then
      EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_STRANGER_STAUS_RSP, strangerStatus, curUID)
    end
  end
end
function TeamUpNewSystem.IsInOneMoreGameTeam()
  local bIsInGame = false
  local team_omb_info = TeamUpNewSystem.GetOneMoreGameInfo()
  if team_omb_info then
    local member_status = team_omb_info.member_status
    local selfUid = TeamUpNewSystem.GetSelfUID()
    local isOneMoreGameTeamLeader = team_omb_info.team_leader == selfUid
    if member_status and next(member_status) then
      for k, v in pairs(member_status) do
        if isOneMoreGameTeamLeader and tonumber(k) == selfUid then
        elseif v.status == 0 then
          bIsInGame = true
          break
        end
      end
    end
    local TimeUtil = require("client.common.time_util")
    local serverTime = TimeUtil.GetServerTimeInSec()
    local team_unlock_time = team_omb_info.team_unlock_time
    if bIsInGame and team_unlock_time and 0 < team_unlock_time and serverTime > team_unlock_time then
      bIsInGame = false
    end
  end
  return bIsInGame
end
function TeamUpNewSystem.ReleaseOneMoreGameInfo()
  TeamUpNewSystem.ClearOneMoreGameInfo()
  UIManager.CloseUI(UIManager.UI_Config.one_more_team_tip)
end
function TeamUpNewSystem.ClearOneMoreGameInfo()
  TeamUpNewSystem.oneMoreGameTeamInfo = nil
  if TeamUpNewSystem.teamInfo then
    TeamUpNewSystem.teamInfo.team_omb_info = nil
  end
end
function TeamUpNewSystem.GetOneMoreGameInfo()
  local team_omb_info
  if TeamUpNewSystem.oneMoreGameTeamInfo then
    team_omb_info = TeamUpNewSystem.oneMoreGameTeamInfo
  elseif TeamUpNewSystem.teamInfo then
    team_omb_info = TeamUpNewSystem.teamInfo.team_omb_info
  end
  return team_omb_info
end
function TeamUpNewSystem.Enter()
  log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.Enter")
  TeamUpNewSystem.teamInfo = {}
  TeamUpNewSystem.teamInfo.members = {}
  TeamUpNewSystem.team_info_request()
  local TeamPlatformSystem = require("client.slua.logic.teamup.logic_team_platform")
  TeamPlatformSystem.GetTeamPlatformInfo()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local teamVehicleShowUID = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eTeamVehicleShowUID)
  if teamVehicleShowUID then
    TeamUpNewSystem.nShowVehicleUID = tonumber(teamVehicleShowUID) or 0
  end
end
function TeamUpNewSystem.ReconnectFetchTeamUpInfo()
  TeamUpNewSystem.changeMemberInfo = {}
  TeamUpNewSystem.ReleaseOneMoreGameInfo()
  TeamUpNewSystem.team_info_request()
  local TeamPlatformSystem = require("client.slua.logic.teamup.logic_team_platform")
  TeamPlatformSystem.GetTeamPlatformInfo()
end
function TeamUpNewSystem.CheckInviteList()
  log(bWriteLog and "TeamUpNewSystem.CheckInviteList")
  if not GameStatus.IsInLobbyOrMainCity() then
    log_warning(bWriteLog and "TeamUpNewSystem.CheckInviteList - not inLobbyOrMainCity")
    return
  end
  if TeamUpNewSystem.inviteApplyQueue and #TeamUpNewSystem.inviteApplyQueue > 0 then
    TeamUpNewSystem.ShowInviteTip()
  end
end
function TeamUpNewSystem.UpdateVoiceInfo(uid, voiceInfo)
  local memberInfo = TeamUpNewSystem.GetMemberInfo(uid)
  if not memberInfo then
    log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.UpdateVoiceInfo memberinfo is none")
    return
  end
  TeamUpNewSystem.teamInfo.members[uid].voice = voiceInfo
end
function TeamUpNewSystem.UpdateClanName(uid, clanName)
  local memberinfo = TeamUpNewSystem.GetMemberInfo(uid)
  if not memberinfo then
    log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.UpdateCarteamName memberinfo is none")
    return
  end
  TeamUpNewSystem.teamInfo.members[uid].carteam_name = clanName
end
function TeamUpNewSystem.UpdateCrops(uid, corps_name, corps_icon, cur_corps_alias_id, corps_position)
  local memberinfo = TeamUpNewSystem.GetMemberInfo(uid)
  if not memberinfo then
    log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.UpdateCarteamName memberinfo is none")
    return
  end
  TeamUpNewSystem.teamInfo.members[uid].  TeamUpNewSystem.teamInfo.members[uid].  TeamUpNewSystem.teamInfo.members[uid].  TeamUpNewSystem.teamInfo.members[uid].end
function TeamUpNewSystem.UpdateCredit(uid, credit)
  local memberinfo = TeamUpNewSystem.GetMemberInfo(uid)
  if not memberinfo then
    log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.UpdateCarteamName memberinfo is none")
    return
  end
  TeamUpNewSystem.teamInfo.members[uid].end
function TeamUpNewSystem.UpdateVehicle(param)
  log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.UpdateVehicle")
  if param and param.uid then
    local uid = param.uid
    if TeamUpNewSystem.teamInfo and TeamUpNewSystem.teamInfo.members then
      for k, v in pairs(TeamUpNewSystem.teamInfo.members) do
        if k == uid then
          if param.vst_info then
            v.vst_info.skin_id = param.vst_info.skin_id
            v.vst_info.vst_type = param.vst_info.vst_type
            v.vst_info.skin_style_list = param.vst_info.skin_style_list
            v.vst_info.show_tire_feature = param.vst_info.show_tire_feature
            v.vst_info.car_install_acc = param.vst_info.car_install_acc
            v.vst_info.chassis_light = param.vst_info.chassis_light
            v.vst_info.car_applique_list = param.vst_info.car_applique_list
            v.vst_info.brake_caliper = param.vst_info.brake_caliper
            v.vst_info.wheel_hub = param.vst_info.wheel_hub
            v.vst_info.sunroof = param.vst_info.sunroof
          end
          break
        end
      end
    end
    if tonumber(uid) == TeamUpNewSystem.nShowVehicleUID and param.vst_info.skin_id == 0 and param.vst_info.vst_type == 0 then
      local selfUID = TeamUpNewSystem.GetSelfUID()
      TeamUpNewSystem.nShowVehicleUID = selfUID
      local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
      PlayerPrefsSystem.SaveTableToFile_N(tostring(selfUID), PlayerPrefsSystem.ePlayerPrefsType.eTeamVehicleShowUID)
    end
  end
  TeamUpNewSystem.ShowVehicleAvatar()
end
function TeamUpNewSystem.UpdateBackground(param)
  log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.UpdateBackground")
  if param and param.uid then
    local uid = param.uid
    if TeamUpNewSystem.teamInfo and TeamUpNewSystem.teamInfo.members then
      for k, v in pairs(TeamUpNewSystem.teamInfo.members) do
        if k == uid then
          if param.background then
            v.background = param.background
          end
          break
        end
      end
    end
  end
  local LobbyThemeManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyThemeManager)
  LobbyThemeManager:ShowTheme(true)
end
function TeamUpNewSystem.CheckInviteAutoRefuse(inviter)
  return TeamUpNewSystem.CheckAutoRefuse(TeamUpNewSystem.autoRefuseInviterMap, inviter, C_AUTO_REFUSE_TIME_OUT)
end
function TeamUpNewSystem.CheckApplyAutoRefuse(applier)
  return TeamUpNewSystem.CheckAutoRefuse(TeamUpNewSystem.autoRefuseApplierMap, applier, C_AUTO_REFUSE_TIME_OUT)
end
function TeamUpNewSystem.CheckSoloAutoRefuse(applier)
  return TeamUpNewSystem.CheckAutoRefuse(TeamUpNewSystem.autoRefuseSoloMap, applier, C_AUTO_REFUSE_TIME_OUT)
end
function TeamUpNewSystem.CheckAutoRefuse(map, id, timeout)
  if not (map and id) or not timeout then
    return false
  end
  local autoRefuseTime = map[id]
  if not autoRefuseTime then
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local timeDiff = TimeUtil.GetServerTimeInSec() - autoRefuseTime
  log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.CheckAutoRefuseid = " .. id .. ", timeDiff = " .. timeDiff)
  return timeout > timeDiff
end
function TeamUpNewSystem.GetOldGameType(newTeamType)
  if newTeamType and 200 < newTeamType then
    return 2
  else
    return 1
  end
end
function TeamUpNewSystem.CacheMsg(tabContent)
  TeamUpNewSystem.nMsgIdGuid = TeamUpNewSystem.nMsgIdGuid + 1
  TeamUpNewSystem.msgContentCacheMap[TeamUpNewSystem.nMsgIdGuid] = tabContent
  return TeamUpNewSystem.nMsgIdGuid
end
function TeamUpNewSystem.CheckInviteApplyOnTeamChange(teaminfo)
  if TeamUpNewSystem.teamInfo and TeamUpNewSystem.teamInfo.id and TeamUpNewSystem.teamInfo.id ~= teaminfo.id then
    local queueLength = #TeamUpNewSystem.inviteApplyQueue
    log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.CheckInviteApplyOnTeamChange queueLength = " .. queueLength)
    TeamUpNewSystem.RemoveAllInvite()
    UIManager.CloseUI(UIManager.UI_Config.Team_Invite_Tip_UIBP)
  end
end
function TeamUpNewSystem.ReLinkLine(tParam)
  log_tree("[DeanJYT] TeamUpNewSystem.ReLinkLine tParam", tParam)
  if not tParam then
    log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.ReLinkLine tParam none")
    TeamUpNewSystem.team_info_request()
    return
  end
  local pUid = tParam.uid
  local _info = TeamUpNewSystem.GetMemberInfo(pUid)
  if not _info then
    log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.ReLinkLine _info none uid:" .. tostring(pUid))
    return
  end
  local isOnlineLastTime = _info.svr ~= nil
  local isOnlineNow = tParam.svr ~= nil
  if not isOnlineLastTime and isOnlineNow then
    TeamUpNewSystem.lastMemberLoginTime = true
    if GameStatus.IsInLobbyOrMainCity() then
      log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.ReLinkLine perOnline" .. pUid)
      local stringName = TeamUpNewSystem.GetMemberName(pUid)
      local tipString = DataMgr.GetMsgByID(110020)
      local finalString = string.format(tostring(tipString), tostring(stringName))
      ShowNotice(finalString)
    end
  end
  _info.svr = tParam.svr
  _info.game_start = tParam.game_start or 0
  _info.socialland_type = tParam.socialland_type or 0
  _info.sub_mode = tParam.sub_mode or 0
  _info.cwow_type = tParam.cwow_type or 0
  EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC, ENUM_TeamInfoSyncType.Online)
  EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_CONSCRIBE_UPDATE_TEAM)
end
function TeamUpNewSystem.CheckSameInvite(inviter, inviterType)
  for i, v in ipairs(TeamUpNewSystem.inviteApplyQueue) do
    if tonumber(v.playerId) == tonumber(inviter) and v.type == inviterType then
      printf("TeamUpNewSystem.CheckSameInvite - HIT inviter=%s type=%s queueIdx=%s existTeamId=%s", inviter, inviterType, i, v.inviterTeamID)
      return i
    end
  end
  return 0
end
function TeamUpNewSystem.OtherJoinTeam(teamid, param)
  log(bWriteLog and "TeamUpNewSystem.OtherJoinTeam")
  if not param then
    log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.OtherJoinTeam tParam none")
    TeamUpNewSystem.team_info_request()
    return
  end
  local uid = param.uid
  if not uid then
    log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.OtherJoinTeam uid none")
    TeamUpNewSystem.team_info_request()
    return
  end
  if not TeamUpNewSystem.teamInfo or not TeamUpNewSystem.teamInfo.members then
    log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.OtherJoinTeam TeamUpNewSystem.teamInfo none")
    TeamUpNewSystem.team_info_request()
    return
  end
  local teamNum = TeamUpNewSystem.GetTeamNum()
  if 1 < teamNum and teamid ~= TeamUpNewSystem.teamInfo.id then
    log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.OtherJoinTeam teamid is not same")
    TeamUpNewSystem.team_info_request()
    return
  end
  if teamNum == 1 then
    local selfUID = TeamUpNewSystem.GetSelfUID()
    local selfInfo = TeamUpNewSystem.GetMemberInfo(selfUID)
    if selfInfo and not selfInfo.join_time then
      selfInfo.join_time = 0
    end
    TeamUpNewSystem.teamInfo.leader = selfUID
  end
  local TableUtil = require("common.table_util")
  local newTeamInfo = TableUtil.CopyTable(TeamUpNewSystem.teamInfo)
  newTeamInfo.members[tonumber(uid)] = param
  newTeamInfo.player_count = TableUtil.CountTable(newTeamInfo.members)
  TeamUpNewSystem.on_team_info_sync(teamid, newTeamInfo, true, false)
  log(bWriteLog and "TeamUpNewSystem.OtherJoinTeam, self.PlayVehicleVideo(param). ")
  TeamUpNewSystem.PlayVehicleVideo(param)
  local ActorVoiceSystem = require("client.slua.logic.actor_voice.logic_actor_voice")
  ActorVoiceSystem.CheckAndShowTeamActorVoiceUI(param, false)
  if param.join_from == E_InviteFromType.WOWTeam or param.join_from == E_InviteFromType.WOWTogether then
    log(bWriteLog and "TeamUpNewSystem OtherJoinTeam ")
    local UGC_Inventory = require("client.slua.logic.ugc.ugc_Inventory")
    local bTeamPlatform_MyTeam_UIBP = UIManager.IsUIShow(UIManager.UI_Config.TeamPlatform_MyTeam_UIBP)
    if bTeamPlatform_MyTeam_UIBP then
      EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_ROOM_ENTRY_UPDATE_TIPS, uid, UGC_Inventory.UpInRoomTypeUIList.TeamPlay)
    else
      EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_ROOM_ENTRY_UPDATE_TIPS, uid, UGC_Inventory.UpInRoomTypeUIList.LobbyMain)
    end
  end
end
function TeamUpNewSystem.QuitTeam()
  local logic_chat_voice_doctor = require("client.slua.logic.chat_voice.logic_chat_voice_doctor")
  logic_chat_voice_doctor:AddJoinTeamRoomStep(620)
  local TeamPlatformSystem = require("client.slua.logic.teamup.logic_team_platform")
  TeamPlatformSystem.ClearRecruitInfo()
  local logic_share_bag_team_util = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_share_bag_team_util)
  logic_share_bag_team_util:OnQuitTeam()
  TeamUpNewSystem.nShowVehicleUID = 0
  TeamUpNewSystem.afterteamID = 0
  if not TeamUpNewSystem.teamInfo then
    log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.QuitTeam TeamUpNewSystem.teamInfo none")
    logic_chat_voice_doctor:AddJoinTeamRoomStep(621)
    TeamUpNewSystem.team_info_request()
    return
  end
  local uid = TeamUpNewSystem.GetSelfUID()
  local info = TeamUpNewSystem.GetMemberInfo(uid)
  if not info then
    log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.QuitTeam team info have no self")
    logic_chat_voice_doctor:AddJoinTeamRoomStep(622)
    TeamUpNewSystem.team_info_request()
    return
  end
  if TeamUpNewSystem.GetTeamNum() == 1 then
    log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.QuitTeam team info is already alone")
    logic_chat_voice_doctor:AddJoinTeamRoomStep(623)
    return
  end
  local TableUtil = require("common.table_util")
  local newTeamInfo = TableUtil.CopyTable(TeamUpNewSystem.teamInfo)
  newTeamInfo.members = {}
  newTeamInfo.members[uid] = info
  newTeamInfo.player_count = nil
  newTeamInfo.create_time = nil
  newTeamInfo.AntsVoice_url = nil
  newTeamInfo.leader = nil
  newTeamInfo.zone_id = nil
  newTeamInfo.is_participate_competition = nil
  newTeamInfo.team_omb_info = nil
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eModeSelectionMainUI) or {}
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local _, viewId = logic_mode_selection:GetCurSelectInfo()
  local bAutoFill = false
  if viewId and logic_mode_selection.GetMenuListByViewID then
    local menuIdList = logic_mode_selection:GetMenuListByViewID(viewId)
    local menuId = menuIdList and menuIdList[1]
    if menuId and cfg.menuFilter and cfg.menuFilter[menuId] then
      bAutoFill = cfg.menuFilter[menuId].bAutoFill or false
    end
  end
  newTeamInfo.fill = bAutoFill and 1 or 0
  TeamUpNewSystem.on_team_info_sync(0, newTeamInfo, true, true)
  local LogicTeamUpLimit = require("client.slua.logic.teamup.logic_team_up_limit")
  LogicTeamUpLimit.ClearCurTeamLimitStatusAndRange()
  EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_LIMIT_RANGE_CHANGE)
  TeamUpNewSystem.SetTeamCode(nil)
  EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMCODE_SYNC)
  local ActorVoiceSystem = require("client.slua.logic.actor_voice.logic_actor_voice")
  ActorVoiceSystem.RemovePlayerTeamVoice(nil)
  logic_share_bag_team_util:UpdateTeamAvatar(DataMgr.roleData.uid, {})
  logic_share_bag_team_util:ClearLastSelectShareItemsInfo()
  local ShareSuit = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ShareSuit)
  ShareSuit:OnExitMember(nil, nil, uid)
end
function TeamUpNewSystem.OtherQuitTeam(uid)
  if not TeamUpNewSystem.teamInfo then
    log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.OtherQuitTeam TeamUpNewSystem.teamInfo none")
    TeamUpNewSystem.team_info_request()
    return
  end
  if not uid then
    log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.OtherQuitTeam uid is none")
    TeamUpNewSystem.team_info_request()
    return
  end
  uid = tonumber(uid)
  local logic_share_bag_team_util = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_share_bag_team_util)
  logic_share_bag_team_util:ClearLastSelectShareItemsInfo(uid)
  logic_share_bag_team_util:OnOtherQuitTeam(uid)
  if not (TeamUpNewSystem.teamInfo and TeamUpNewSystem.teamInfo.members) or not TeamUpNewSystem.teamInfo.members[uid] then
    log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.OtherQuitTeam team have no member of uid = " .. uid)
    TeamUpNewSystem.team_info_request()
    return
  end
  local TableUtil = require("common.table_util")
  local newTeamInfo = TableUtil.CopyTable(TeamUpNewSystem.teamInfo)
  newTeamInfo.members[uid] = nil
  newTeamInfo.player_count = TableUtil.CountTable(newTeamInfo.members)
  if newTeamInfo.player_count == 1 then
    TeamUpNewSystem.nShowVehicleUID = 0
    if not TeamUpNewSystem.IsInOneMoreGameTeam() then
      newTeamInfo.team_omb_info = nil
    end
    TeamUpNewSystem.on_team_info_sync(newTeamInfo.id or 0, newTeamInfo, true, true)
    EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_DESTROY_TEAM)
    TeamUpNewSystem.SetTeamCode(nil)
    EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMCODE_SYNC)
  else
    if TeamUpNewSystem.nShowVehicleUID == uid then
      TeamUpNewSystem.nShowVehicleUID = 0
    end
    TeamUpNewSystem.on_team_info_sync(newTeamInfo.id, newTeamInfo, true, true)
  end
  local ActorVoiceSystem = require("client.slua.logic.actor_voice.logic_actor_voice")
  ActorVoiceSystem.RemovePlayerTeamVoice(uid)
end
function TeamUpNewSystem.team_info_request()
  log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.team_info_request")
  local TeamupHandler = require("client.network.Protocol.TeamupHandler")
  TeamupHandler.send_team_info_request()
end
function TeamUpNewSystem.team_invite_request(uid, from, missionInfo, teamPlatformInfo, autoVoiceRequest)
  log(bWriteLog and "TeamUpNewSystem.team_invite_request uid = " .. uid .. ", from = " .. tostring(from))
  log_tree("missionInfo = ", missionInfo)
  log_tree("teamPlatformInfo = ", teamPlatformInfo)
  log_tree("autoVoiceRequest = ", autoVoiceRequest)
  local isTMode = false
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  if from == TeamUpNewSystem.E_InviteFromType.FireBaseInvite then
    log(bWriteLog and "TeamUpNewSystem.team_invite_request FireBaseInvite")
  elseif logic_mode_selection.hasSelectTxMission then
    log(bWriteLog and "TeamUpNewSystem.team_invite_request hasSelectTxMission")
    from = TeamUpNewSystem.E_InviteFromType.TPlan
    isTMode = true
  end
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  local ugcMatchInfo = LogicUGCMatch:GetUgcMatchModInfo()
  local inviteInfo = {
    playerName = DataMgr.roleData.nickName,
    src = TeamUpNewSystem.GetPlayerRelation(uid),
    from = from or 0,
    missionInfo = missionInfo,
    teamPlatformInfo = teamPlatformInfo,
    showCD = C_APPLY_INVITE_SHOW_TIME,
    closeCD = C_APPLY_INVITE_CLOSE_TIME,
    closeTotalTime = C_APPLY_INVITE_CLOSE_TIME,
    autoVoiceRequest = autoVoiceRequest,
    ugcModID = ugcMatchInfo and ugcMatchInfo.mod_id,
      }
  if GameStatus.IsInMainCity() then
    inviteInfo.sceneType = "MainCity"
    local logic_main_city_achievement_task_report = require("GameLua.Mod.MainCity.Client.logic.logic_main_city_achievement_task_report")
    logic_main_city_achievement_task_report.ReportInviteFriend()
  end
  if from == TeamUpNewSystem.E_InviteFromType.FlashTeam then
    local logic_chat_channel_flash_match_team = require("client.slua.logic.lobby_chat.logic_chat_channel_flash_match_team")
    inviteInfo.squad_id = logic_chat_channel_flash_match_team.GetCurrentTeamId()
  end
  local TeamupHandler = require("client.network.Protocol.TeamupHandler")
  TeamupHandler.send_team_invite_request(uid, inviteInfo)
end
function TeamUpNewSystem.team_invite_reply(ispermit, userid, teamid, src, from_type, isTPlanItem, tournament_id, text_id)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local index = 0
  for k, v in ipairs(LogicFriend.ReserveBack2Lobby) do
    if v.friUid == userid then
      from_type = v.from
      index = k
      break
    end
  end
  if 0 ~= index then
    table.remove(LogicFriend.ReserveBack2Lobby, index)
  end
  local TeamupHandler = require("client.network.Protocol.TeamupHandler")
  if isTPlanItem then
    src = "metro_" .. src
  end
  log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.team_invite_reply ispermit = " .. tostring(ispermit) .. ", userid = " .. tostring(userid) .. ", teamid = " .. tostring(teamid) .. ", src = " .. tostring(src) .. ", from = " .. tostring(from_type))
  TeamupHandler.send_team_invite_reply(ispermit, userid, teamid, src, from_type, nil, tournament_id, text_id)
  if (from_type == E_InviteFromType.WOWTeam or from_type == E_InviteFromType.WOWTogether) and ispermit and tostring(ispermit) == "ok" then
    EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_ROOM_ENTRY_UPDATE_TIPS, userid)
  end
end
function TeamUpNewSystem.team_apply_reply(ispermit, userid, teamid, src, from_type, join_signatur, applyer_name, text_id)
  log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.team_apply_reply ispermit = " .. ispermit .. ", userid = " .. userid)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  for _, v in ipairs(LogicFriend.ReserveBack2Lobby) do
    if v.friUid == userid then
      from_type = 5
      break
    end
  end
  local TeamupHandler = require("client.network.Protocol.TeamupHandler")
  TeamupHandler.send_team_apply_reply(ispermit, userid, teamid, src, from_type, join_signatur, applyer_name, text_id)
end
function TeamUpNewSystem.room_invite_reply(ispermit, room_id, inviter, src, extend_info)
  log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.room_invite_reply ispermit = " .. ispermit .. ", room_id = " .. room_id)
  local TeamupHandler = require("client.network.Protocol.TeamupHandler")
  TeamupHandler.send_room_invite_reply(ispermit, room_id, inviter, src, extend_info)
end
function TeamUpNewSystem.team_apply_request(UID, from, missionInfo)
  if not UID then
    log_warning("[edward][logic_team_up] TeamUpNewSystem.team_apply_request, UID is nil")
    return
  end
  log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.team_apply_request userid = " .. UID .. ", from = " .. tostring(from))
  local applyInfo = {
    src = TeamUpNewSystem.GetPlayerRelation(UID),
    from = from or 0,
      }
  if GameStatus.IsInMainCity() then
    applyInfo.sceneType = "MainCity"
  end
  local TeamupHandler = require("client.network.Protocol.TeamupHandler")
  TeamupHandler.send_team_apply_request(UID, applyInfo)
end
function TeamUpNewSystem.team_quit_request(teamid, reason)
  if not teamid then
    log_warning("[edward][logic_team_up] TeamUpNewSystem.team_quit_request teamid is nil")
    TeamUpNewSystem.on_team_quit_respond(NetErrorCode_NONE)
    return
  end
  log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.team_quit_request teamid = " .. teamid)
  local TeamupHandler = require("client.network.Protocol.TeamupHandler")
  TeamupHandler.send_team_quit_request(teamid, reason)
end
function TeamUpNewSystem.JoinTeamByChat(uid, teamid, src, from_type, isTPlanItem)
  log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.JoinTeamByChat uid = " .. tostring(uid) .. ", teamid = " .. tostring(teamid) .. ", src = " .. tostring(src))
  if IsWoWEditor then
    return
  end
  if TeamUpNewSystem.GetSelfUID() == tonumber(uid) then
    if src ~= ShareSource.Facebook then
      ShowNotice(110045)
    end
    return
  end
  TeamUpNewSystem.team_invite_reply("enlist", tonumber(uid), tonumber(teamid), src, from_type, isTPlanItem)
end
function TeamUpNewSystem.team_kick_request(userid, from)
  log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.team_kick_request userid = " .. userid)
  local TeamupHandler = require("client.network.Protocol.TeamupHandler")
  TeamupHandler.send_team_kick_request(userid, from)
end
function TeamUpNewSystem.recv_stau_request(isNeed)
end
function TeamUpNewSystem.team_change_type_request(matchID, viewIDs)
  local TeamupHandler = require("client.network.Protocol.TeamupHandler")
  TeamupHandler.send_team_change_type_request(matchID, viewIDs)
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  logic_mode_selection:HasSelectMetroTxMission(viewIDs[1])
end
function TeamUpNewSystem.team_change_fill_request(fill)
  log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.team_change_fill_request fill = " .. tostring(fill))
  local TeamupHandler = require("client.network.Protocol.TeamupHandler")
  TeamupHandler.send_team_change_fill_request(fill)
end
function TeamUpNewSystem.team_change_leader_request(new_leader)
  log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.team_change_leader_request new_leader = " .. new_leader)
  if LobbySystem.isInMatch then
    ShowNotice(110017)
    return
  end
  local memberInfo = TeamUpNewSystem.GetMemberInfo(new_leader)
  if memberInfo and not memberInfo.svr then
    ShowNotice(110065)
    return
  end
  local TeamupHandler = require("client.network.Protocol.TeamupHandler")
  TeamupHandler.send_team_change_leader_request(new_leader)
end
function TeamUpNewSystem.stranger_all_status_request(uid)
  local list = {
    [1] = tonumber(uid)
  }
  if next(list) then
    local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
    PlayerStatusMgr:GetOrReqStatusData(ENUM_BATCH_GET_GROUP_AND_ONLINE.TeamUpStranger, list, function(infos)
      TeamUpNewSystem.on_stranger_staus_rsp(infos)
    end)
  end
end
function TeamUpNewSystem.get_teamid_for_plat_request()
  log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.get_teamid_for_plat_request")
  if _G.BP_Platform == BP_ENUM_PLAYFORM_WX and Client.IsInstallWX(NetInterface) == false then
    ShowNotice(110126)
    return
  elseif _G.BP_Platform == BP_ENUM_PLAYFORM_BGBG and Client.IsInstallFaceBook(NetInterface) == false then
    ShowNotice(110125)
    return
  end
  local TeamupHandler = require("client.network.Protocol.TeamupHandler")
  TeamupHandler.send_team_recruit_for_plat_req()
end
function TeamUpNewSystem.ReportVoiceInfo(voiceuid, voiceOpen)
  if GameStatus.GetGameStatus() == GameStatus.Login then
    return
  end
  log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.ReportVoiceInfo:" .. voiceuid .. "isOpen:" .. tostring(voiceOpen))
  local TeamupHandler = require("client.network.Protocol.TeamupHandler")
  local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
  local speakerState = logic_chat_voice:GetSpeakerState()
  TeamupHandler.send_team_report_voice_info(tonumber(voiceuid), voiceOpen, speakerState)
end
function TeamUpNewSystem.ReportSpeakerInfo(voiceuid, speakerOpen)
  if GameStatus.GetGameStatus() == GameStatus.Login then
    return
  end
  log(bWriteLog and "[DeanJYT] TeamUpNewSystem.ReportSpeakerInfo:" .. voiceuid .. "isOpen:" .. tostring(speakerOpen))
  local TeamupHandler = require("client.network.Protocol.TeamupHandler")
  local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
  TeamupHandler.send_team_report_voice_info(tonumber(voiceuid), logic_chat_voice:GetMicState(), speakerOpen)
end
function TeamUpNewSystem.team_player_action(action_id, randSoundId, extraParam)
  log(bWriteLog and "TeamUpNewSystem.team_player_action action_id = " .. tostring(action_id))
  randSoundId = randSoundId or 0
  local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
  if LogicXSuit.IsInviteAction(action_id) then
    if LogicXSuit.CheckHasEquipXSuitByAction(action_id) then
      local XMissionSystem = require("client.slua.logic.TxMission.logic_xmission_main")
      if not XMissionSystem.IsInXMission() then
        LogicXSuit.CheckNeedSendInvite(action_id)
      end
    else
      return
    end
  end
  if LogicXSuit.IsBattleEmotion(action_id) then
    return
  end
  local LogicParticleEmote = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicParticleEmote)
  if LogicParticleEmote:Is2LevelParticleEmote(action_id) then
    action_id = LogicParticleEmote:GetBaseID(action_id)
  end
  local TeamupHandler = require("client.network.Protocol.TeamupHandler")
  local item_cfg = CDataTable.GetTableData("Item", action_id)
  if item_cfg and item_cfg.ItemSubType == 2206 then
    TeamupHandler.send_together_dance_action_req(action_id)
  end
  extraParam = extraParam or {}
  local bStop = extraParam.stopAction
  if not bStop then
    log(bWriteLog and "TeamUpNewSystem.team_player_action play action_id = " .. tostring(action_id))
    local UIUtil = require("client.common.ui_util")
    if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.SyncLobbyEmotion, false) then
      log(bWriteLog and "TeamUpNewSystem.team_player_action send too frequently, ignore")
      return
    end
  else
    log(bWriteLog and "TeamUpNewSystem.team_player_action stop action_id = " .. tostring(action_id))
  end
  log(bWriteLog and "team_player_action action_id = " .. tostring(action_id) .. ",randSoundId=" .. randSoundId)
  log_tree("TeamUpNewSystem.team_player_action extramParam=", extraParam)
  TeamupHandler.send_team_player_action(action_id, randSoundId, nil, extraParam)
end
function TeamUpNewSystem.ErrorNotice(nDefaultTipKey, nTipKey, sUserNick)
  if not sUserNick or sUserNick == "" then
    ShowNotice(nDefaultTipKey)
  else
    ShowNotice(LocUtil.LocalizeResFormat(nTipKey, sUserNick))
  end
end
function TeamUpNewSystem.on_team_invite_respond(state, invitee, verCompareResult, fcmLimit, userNick, text_id)
  log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.on_team_invite_respond state = " .. state .. ", invitee = " .. invitee .. " UserNick = " .. tostring(userNick))
  log(bWriteLog and "[chub]TeamUpNewSystem.on_team_invite_respond userNick = " .. tostring(userNick))
  log(bWriteLog and "[chub]TeamUpNewSystem.on_team_invite_respond text_id = " .. tostring(text_id))
  if state == NetErrorCode_NONE then
    ShowNotice(LocUtil.LocalizeResFormat(110004))
  elseif state == "target_not_online" then
    ShowNotice(110016)
  elseif state == "invitee_offline" then
    ShowNotice(110016)
  elseif state == "invitee_in_metro_scence" then
    ShowNotice(1994019)
  elseif state == "team_is_full" then
    ShowNotice(110007)
  elseif state == "refuse" then
    if text_id then
      local reason = LocUtil.LocalizeResFormat(text_id)
      ShowNotice(LocUtil.LocalizeResFormat(43751, userNick or "", reason))
    else
      TeamUpNewSystem.ErrorNotice(110011, 38826, userNick)
    end
  elseif state == "timeout" then
    TeamUpNewSystem.ErrorNotice(110011, 38828, userNick)
  elseif state == "autoRefuseOnTeamChange" then
    ShowNotice(110056)
  elseif state == "invitee_in_match" then
    ShowNotice(110059)
  elseif state == "inviter_in_game" then
    ShowNotice(9911106)
  elseif state == "invitee_in_game" then
    ShowNotice(9911106)
  elseif state == "team in match" then
    ShowNotice(110060)
  elseif state == "already_in_match" then
    ShowNotice(110061)
    log(bWriteLog and "TeamUpNewSystem.on_team_invite_respond MatchSystem.QueryPlayerState 1")
    MatchSystem.QueryPlayerState()
  elseif state == "not_same_version" then
    TeamUpNewSystem.HandleVersionErrorCode(verCompareResult, true)
  elseif state == "already_has_team" then
    ShowNotice(110044)
  elseif state == "invitee-not-in-team-whitelist" then
    ShowNotice(8889349)
  elseif state == "invitee_already_in_team" then
    ShowNotice(6283)
    if invitee then
      local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
      PlayerStatusMgr:send_batch_get_group_and_online_req(ENUM_BATCH_GET_GROUP_AND_ONLINE.AllFriend, {invitee})
    end
  elseif state == "invitee_cond_limit" then
    ShowNotice(7134)
  elseif state == "param_err" then
    ShowNotice(108109)
  elseif state == "low_priority_match_banned" then
    MatchSystem.ShowBanTip(MatchSystem.GetTeamUpBanTip())
  elseif state == "match_isolation_label_banned" then
    MatchSystem.ShowBanTip(LocUtil.GetLocalizeResStr(29113))
  elseif state == "invitee_match_isolation_label_banned" then
    local title = LocUtil.GetLocalizeResStr(101001)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(1, title, LocUtil.LocalizeResFormat(32634, verCompareResult))
    log(bWriteLog and "TeamUpNewSystem.on_team_invite_respond  invitee_match_isolation_label_banned  name = " .. tostring(verCompareResult))
  elseif state == "guest_state_banned" then
    ShowNotice(22006)
  elseif state == "invitee_guest_state_banned" then
    ShowNotice(22007)
  elseif state == "not_tmap" then
    ShowNotice(LocUtil.LocalizeResFormat(11615))
  elseif state == "metro_mode_not_open" then
    ShowNotice(LocUtil.LocalizeResFormat(100080023))
  elseif state == "not_friend" then
    ShowNotice(29388)
  elseif state == "pre_team_limit" then
    ShowNotice(27192)
  elseif state == "view_not_right" then
    ShowNotice(31199)
  elseif state == "cant-invite-8v8-player" then
    ShowNotice(411028)
  elseif state == "cant-invite-socialland-player" then
    ShowNotice(411028)
  elseif state == "cant-invite-ugc-player" then
    ShowNotice(48410)
  elseif state == "ugc-cant-invite-socialland-player" then
    ShowNotice(48409)
  elseif state == "ugc-cant-invite-unlock-player" then
    ShowNotice(511204)
  elseif state == "ugc-cant-invite-dev-limit" then
    ShowNotice(511205)
  elseif state == "qrcode_login_limit" then
    ShowNotice(LocUtil.LocalizeResFormat(200000128, userNick))
  elseif state == "team_reject_strangers" then
    ShowNotice(773309)
  elseif state == "not_promotion_rating" then
    ShowNotice(85159)
  elseif state == "not_promotion_layer" then
    ShowNotice(85159)
  elseif state == "not_inviter_promotion_multi_mode" then
    ShowNotice(100610010)
  elseif state == "not_inviter_promotion_mode" then
    ShowNotice(100610009)
  elseif state == "not_inviter_promotion_rating" then
    ShowNotice(100610011)
  elseif state == "not_invitee_promotion_rating" then
    ShowNotice(100610012)
  elseif not TeamUpNewSystem.HandleTeamJoinErrorCode(state) then
    TeamUpNewSystem.HandleErrorCode(state, invitee, fcmLimit)
  end
end
function TeamUpNewSystem.HandleErrorCode(errorCode, invitee, fcmLimit)
  if errorCode == "already_in_room" then
    ShowNotice(110117)
  elseif errorCode == "invitee_in_room" then
    ShowNotice(110118)
  elseif errorCode == "inviter_in_room" then
    ShowNotice(110119)
  elseif errorCode == "applicant_in_room" then
    ShowNotice(110120)
  elseif errorCode == "kickOut" then
    ShowNotice(110121)
  elseif errorCode == "kickOut_in_allstar" then
    ShowNotice(12646)
  elseif errorCode == "owed_state_banned" then
    ShowNotice(24226)
  elseif errorCode == "offline_invitee_closed" then
    ShowNotice(33400)
  elseif errorCode == "invitee_frequently" then
    local Logic_Offline_Invite = require("client.slua.logic.teamup.logic_offline_invite")
    Logic_Offline_Invite.bAllCanInvite = false
    ShowNotice(LocUtil.LocalizeResFormat(33115, fcmLimit))
  elseif errorCode == "offline_invitee_user_limit" then
    ShowNotice(LocUtil.LocalizeResFormat(33116, fcmLimit))
    local Logic_Offline_Invite = require("client.slua.logic.teamup.logic_offline_invite")
    Logic_Offline_Invite.RecordInviteForbid(invitee)
  elseif errorCode == "offline_invite_success" then
    ShowNotice(33073)
  elseif errorCode == "db_error" then
    ShowNotice(100500002)
  elseif errorCode == "peakgame_segment_limit" then
    ShowNotice(46129)
  end
end
function TeamUpNewSystem.HandleVersionErrorCode(verCompareResult, bInvite)
  if verCompareResult then
    if verCompareResult == 1 then
      ShowNotice(110150)
    else
      local title = LocUtil.GetLocalizeResStr(5077)
      local tips
      if bInvite then
        tips = LocUtil.GetLocalizeResStr(44902)
      else
        tips = LocUtil.GetLocalizeResStr(44903)
      end
      local okText = LocUtil.GetLocalizeResStr(201003)
      local cancelText = LocUtil.GetLocalizeResStr(110035)
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.Show(2, title, tips, function()
        FuncUtil.JumpToDownloadApp()
      end, nil, okText, cancelText)
    end
  else
    ShowNotice(110116)
  end
end
function TeamUpNewSystem.on_team_invite_notify(inviter, teamId, team_type, inviteInfo, sub_mode_view_ids)
  local _queueLenEntry = TeamUpNewSystem.inviteApplyQueue and #TeamUpNewSystem.inviteApplyQueue or 0
  local _autoRefuseTs = TeamUpNewSystem.autoRefuseInviterMap and TeamUpNewSystem.autoRefuseInviterMap[inviter]
  printf("TeamUpNewSystem.on_team_invite_notify - inviter=%s teamId=%s team_type=%s queueLen=%s autoRefuseTs=%s", inviter, teamId, team_type, _queueLenEntry, _autoRefuseTs)
  local autoRefuse = TeamUpNewSystem.CheckInviteAutoRefuse(inviter)
  if autoRefuse then
    log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.on_team_invite_notify, autoRefuse = true")
    if inviteInfo then
      TeamUpNewSystem.team_invite_reply("refuse", inviter, teamId, inviteInfo.src, inviteInfo.from, nil, nil)
    end
    return
  end
  if TeamUpNewSystem.IsInOneMoreGameTeam() then
    log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.on_team_invite_notify in oneMoreGameTeam")
    return
  end
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local logic_friend_blacklist = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_blacklist)
  local isPullBack = logic_friend_blacklist:IsBlacklist(inviter)
  log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.on_team_invite_notify ispulblack:" .. tostring(isPullBack))
  if isPullBack then
    log_warning(bWriteLog and "TeamUpNewSystem.on_team_invite_notify - REJECT-blacklist")
    return
  end
  local logic_replay = require("client.slua.logic.replay.logic_replay")
  if logic_replay.IsPlayingReplay() then
    log(bWriteLog and "[yw ] TeamUpNewSystem.ShowInviteTip => replay is playing")
    return
  end
  local inviteApplyData
  local isExistIndex = TeamUpNewSystem.CheckSameInvite(inviter, 0)
  inviteApplyData = {
    type = 0,
    playerId = inviter,
    inviterTeamID = teamId,
    playerName = TeamUpNewSystem.GetMemberName(inviter),
    gameType = TeamUpNewSystem.GetOldGameType(team_type),
    showCD = C_APPLY_INVITE_SHOW_TIME,
    closeCD = C_APPLY_INVITE_CLOSE_TIME,
    closeTotalTime = C_APPLY_INVITE_CLOSE_TIME,
    modeID = team_type,
    subViewId = sub_mode_view_ids and sub_mode_view_ids[1]
  }
  if inviteInfo then
    local ChampionshipSponsorSystem = require("client.slua.logic.championship.logic_championship_sponsor")
    ChampionshipSponsorSystem.pub_id = inviteInfo.pug_id or 0
    inviteApplyData.playerName = inviteInfo.playerName
    inviteApplyData.src = inviteInfo.src
    inviteApplyData.from = inviteInfo.from
    inviteApplyData.missionInfo = inviteInfo.missionInfo
    inviteApplyData.recommend_info_type_team_labels = inviteInfo.recommend_info_type_team_labels
    inviteApplyData.ugcModID = inviteInfo.ugcModID
    inviteApplyData.mainCityID = inviteInfo.main_city_info and inviteInfo.main_city_info.room_id
    inviteApplyData.isTMode = inviteInfo.isTMode
    if inviteApplyData.from == E_InviteFromType.Tournament then
      inviteApplyData.tournament_id = inviteInfo.tournament_id
    end
    if inviteInfo.zone_id then
      local logic_multiple_area = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_multiple_area)
      inviteApplyData.zoneName = logic_multiple_area:GetDisplayNameByZoneID(inviteInfo.zone_id)
      if inviteApplyData.zoneName ~= "" then
        local logic_zone_delay = require("client.slua.logic.match.logic_zone_delay")
        inviteApplyData.netDelay = logic_zone_delay.GetZoneDelay(inviteInfo.zone_id, 360, 10000)
      else
        inviteApplyData.netDelay = 360
      end
    end
    if inviteApplyData.from == E_InviteFromType.TPlan or inviteApplyData.from == E_InviteFromType.TPlanTeamConscribeNew then
      inviteApplyData.mapName = LocUtil.GetLocalizeResStr(35194)
      local LogicTxMissionDownload = require("client.slua.logic.TxMission.logic_xmission_download")
      if not LogicTxMissionDownload.CheckResHasDownloaded() then
        TeamUpNewSystem.team_invite_reply("not_tmap", inviter, teamId, inviteInfo.src, inviteInfo.from, 1)
        return
      end
    elseif inviteApplyData.from == E_InviteFromType.AllStar then
      local XMissionSystem = require("client.slua.logic.TxMission.logic_xmission_main")
      if XMissionSystem.IsInXMission() then
        return
      end
      inviteApplyData.mapName = LocUtil.GetLocalizeResStr(12585)
    elseif inviteApplyData.from == E_InviteFromType.TapJoy then
      inviteApplyData.mapName = LocUtil.GetLocalizeResStr(92221)
    elseif inviteApplyData.from == E_InviteFromType.Sponsor then
      inviteApplyData.mapName = LocUtil.GetLocalizeResStr(62485)
    elseif inviteApplyData.from == E_InviteFromType.FlashTeam then
      local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
      local teamInfo = logic_flash_match_team:getOwnFlashTeamInfo()
      if teamInfo and teamInfo.setting and teamInfo.setting.block_team_invite then
        log(bWirteLog and "logic_team_up:flash match team invite is blocked flag is " .. tostring(teamInfo.setting.block_team_invite))
        return
      end
      local squad_id = inviteInfo.squad_id
      if squad_id then
        local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
        local teamInfo = logic_flash_match_team:GetFlashTeamSummaryById(squad_id)
        local name = teamInfo and teamInfo.name or LocUtil.GetLocalizeResStr(88801431)
        inviteApplyData.mapName = LocUtil.LocalizeResFormat(18010390, name)
        inviteApplyData.      else
        inviteApplyData.mapName = LocUtil.LocalizeResFormat(18010390, LocUtil.GetLocalizeResStr(88801427))
      end
    else
      local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
      inviteApplyData.mapName = logic_mode_selection:GetSelectMapName(sub_mode_view_ids)
      if inviteApplyData.ugcModID then
        local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
        LogicUGC:BatchGetModInfo({
          inviteApplyData.ugcModID
        }, LogicUGC.C_ModListTypes.team_invite_tip)
      end
    end
  end
  log_tree("[YY]inviteInfo==", inviteInfo)
  local FriendHandler = require("client.network.Protocol.FriendHandler")
  if FriendHandler.friend_status_data then
    local isFromAllowedSource = inviteApplyData.from == E_InviteFromType.FriendBar or inviteApplyData.from == E_InviteFromType.MainCityInfoCard
    if not GameStatus.IsInFightingNotSocialNotMainCityNotHome() and FriendHandler.friend_status_data.is_agree_invite and isFromAllowedSource then
      ShowNotice(37411)
      TeamUpNewSystem.directlyAgree(inviteApplyData)
      return
    end
  end
  if isExistIndex == 0 then
    table.insert(TeamUpNewSystem.inviteApplyQueue, inviteApplyData)
  else
    TeamUpNewSystem.inviteApplyQueue[isExistIndex] = inviteApplyData
  end
  if GameStatus.IsInFightingNotSocialNotMainCityNotHome() then
    log_warning(bWriteLog and "TeamUpNewSystem.on_team_invite_notify - is in fighting")
    return
  end
  local logic_friend_reserve = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_reserve)
  logic_friend_reserve:AddFriendUidWhenInviteMe(tonumber(inviter))
  logic_friend_reserve:CloseReserveTipsUI()
  TeamUpNewSystem.ShowInviteTip()
end
function TeamUpNewSystem.directlyAgree(applyData)
  TeamUpNewSystem.team_invite_reply(NetErrorCode_NONE, applyData.playerId, applyData.inviterTeamID, applyData.src, applyData.from)
  local LevelUpSystem = require("client.logic.levelup.logic_levelup")
  LevelUpSystem.ClosePveLevelupPanel()
  local pandoraSystem = require("client.slua.logic.Pandora.pandora_system")
  pandoraSystem.HideCurAct()
  local logic_wardrobe_interactive_action = require("client.slua.logic.wardrobe.logic_wardrobe_interactive_action")
  logic_wardrobe_interactive_action.StopInteractiveAction()
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_EMOTION_SELECT_CLOSE)
  EventSystem:postEvent(EVENTTYPE_CHARACTER, EVENTID_CHARACTER_CLOSE_MAIN)
  EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_ACCEPT_INVITE)
  EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAM_PLATFORM_CLOSE_RECRUIT_UI)
end
function TeamUpNewSystem.on_team_info_sync(teamid, teaminfo, isIncrement, isMemberQuit)
  log(bWriteLog and "TeamUpNewSystem.on_team_info_sync isMemberQuit = " .. tostring(isMemberQuit))
  local logic_chat_voice_doctor = require("client.slua.logic.chat_voice.logic_chat_voice_doctor")
  logic_chat_voice_doctor:AddJoinTeamRoomStep(630)
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.on_team_info_sync, teamid = " .. tostring(teamid))
  log_tree("on_team_info_sync==teamInfo", teaminfo)
  if not teaminfo.player_count then
    teaminfo.player_count = 1
  end
  local logic_profile_security = require("client.slua.logic.profile.logic_profile_security")
  logic_profile_security.ProcTeamInfo(teaminfo)
  if teaminfo.player_count >= 2 then
    log(bWriteLog and "TeamUpNewSystem.on_team_info_sync open tick")
    local main_city_performance_config = require("GameLua.Mod.MainCity.Client.logic.Performance.main_city_performance_config")
    local logic_lobby_performance = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lobby_performance)
    logic_lobby_performance:SetLobbyModelTick(main_city_performance_config.SwitchDataType.TeamUp, true)
    local time_ticker = require("common.time_ticker")
    time_ticker.AddTimer(10, function()
      local logic_lobby_performance = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lobby_performance)
      if logic_lobby_performance then
        logic_lobby_performance:SetLobbyModelTick(main_city_performance_config.SwitchDataType.TeamUp, false)
      end
      logic_lobby_performance:SetLobbyModelTick(main_city_performance_config.SwitchDataType.TeamUp, false)
    end)
  end
  local isMainCity = GameStatus.IsInLobbyOrMainCity()
  local SingleTrainTool = require("GameLua.Mod.SingleTraining.GamePlay.Data.SingleTrainTool")
  local isInSingleTraining = SingleTrainTool.IsSelfInTraining()
  local preTeamPlayerCount = TeamUpNewSystem.teamInfo and TeamUpNewSystem.teamInfo.player_count or 0
  if isMainCity and preTeamPlayerCount <= 1 and teaminfo.player_count > 1 then
    local TeamupHandler = require("client.network.Protocol.TeamupHandler")
    TeamupHandler.send_main_city_change_3d_req(GameStatus.IsInMainCity())
  end
  if TeamUpNewSystem.bHasEnterFighting then
    local newbieGuideManager = require("client.logic.newbie_manager.newbie_guide_manager")
    local needUpdateRole = newbieGuideManager.NeedUpdateRole()
    local UnknowPassTunnelSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknowpass_tunnel")
    if not needUpdateRole and not UnknowPassTunnelSystem.isShowRP and not isMainCity then
      log(bWriteLog and "TeamUpNewSystem.on_team_info_sync, received team_info_sync, force switch camera")
      local UIUtil = require("client.common.ui_util")
      UIUtil.ShowLobbyUI(true)
      TeamUpNewSystem.bHasEnterFighting = false
    else
      log(bWriteLog and "team info sync switch camera is not allowed when update role")
    end
  end
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  local isInGame = GameStatus.IsInFightingStatus()
  log(bWriteLog and "TeamUpNewSystem.on_team_info_sync, received team_info_sync, team(player_count) = " .. tostring(teaminfo.player_count))
  if isInGame then
    log(bWriteLog and "TeamUpNewSystem.on_team_info_sync, received team_info_sync, fighting player change")
    if not MatchModeMgrSystem.IsSocialIslandMode(true) and not isMainCity and not isInSingleTraining then
      logic_chat_voice_doctor:AddJoinTeamRoomStep(633)
      return
    end
  end
  local selfUID = TeamUpNewSystem.GetSelfUID()
  if teamid == 0 then
    teaminfo.player_count = 1
    teaminfo.id = 0
  else
    teaminfo.id = teamid
  end
  if teaminfo.player_count == 1 then
    teaminfo.leader = selfUID
  end
  if not isInGame or isMainCity then
    local BasicDataAvatarWearInfo = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataAvatarWearInfo)
    for AvatarUID, v in pairs(teaminfo.members) do
      BasicDataAvatarWearInfo:UpdateRoleSexByUid(AvatarUID, v.avatar and v.avatar.gamegender)
      if tonumber(AvatarUID) ~= selfUID then
        TeamAvatarManager.CreateAvatarDepotShowSetting(tostring(AvatarUID), v.depot_show_info)
      end
    end
    if teaminfo.player_count == 1 then
      local selfZoneID = teaminfo.self_zone_id
      log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.on_team_info_sync, teaminfo.self_zone_id = " .. tostring(selfZoneID))
      local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
      if ZoneSystem.nChooseZoneID ~= 0 and selfZoneID and 0 < selfZoneID and selfZoneID ~= ZoneSystem.nChooseZoneID then
        ZoneSystem.ShowReturnZoneTip(selfZoneID)
      end
      if ZoneSystem.nChooseZoneID == 0 and selfZoneID and 0 < selfZoneID and selfZoneID ~= ZoneSystem.nChooseZoneID then
        ZoneSystem.setZoneId(selfZoneID)
      end
    end
    TeamUpNewSystem.CheckInviteApplyOnTeamChange(teaminfo)
    local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
    LogicXSuit.RefreshTeamInfo(teaminfo)
    local logic_teamup_action = require("client.slua.logic.teamup.logic_teamup_action")
    logic_teamup_action.ProcessTeammateInfo(teaminfo)
    TeamUpNewSystem.CompareMember(teaminfo)
    if not GameStatus.IsInMainCity() and teaminfo.main_city_info ~= nil then
      local logic_main_city_join = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_main_city_join)
      logic_main_city_join:OnTeamInfoSync(29, teaminfo.main_city_info)
    end
  end
  local isEnterTeam = false
  if teaminfo.player_count > 1 and TeamUpNewSystem.teamInfo.player_count == 1 then
    isEnterTeam = true
    local logic_share_bag_team_util = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_share_bag_team_util)
    logic_share_bag_team_util:ClearAllGrantShareBagMember()
    local logic_share_bag_privilege_util = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_share_bag_privilege_util)
    if logic_share_bag_privilege_util:IsAnyShardBagValid() then
      logic_share_bag_privilege_util:ReqSharedBagPermissionInfo()
    end
    EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CREATE_TEAM)
  end
  log(bWriteLog and "111logic_mode_selection_for_umg isEnterTeam = " .. tostring(isEnterTeam))
  local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
  if Lobby_Main_City_Enter.bInMainCity and teaminfo.player_count > 1 and TeamUpNewSystem.teamInfo.player_count ~= nil and teaminfo.player_count > TeamUpNewSystem.teamInfo.player_count then
    local logic_maincity_minilobby_team_tips = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_maincity_minilobby_team_tips)
    logic_maincity_minilobby_team_tips:AddJoinTeamTips(TeamUpNewSystem.teamInfo.members, teaminfo.members)
  end
  local isPlayerCountChange = false
  if teaminfo.player_count ~= TeamUpNewSystem.teamInfo.player_count then
    isPlayerCountChange = true
  end
  if TeamUpNewSystem.teamInfo.player_count and TeamUpNewSystem.teamInfo.player_count < teaminfo.player_count then
    local AssemblyActivitySystem = require("client.slua.logic.come_back.logic_assembly_activity")
    if AssemblyActivitySystem.HasReqAssemblyInfo then
      AssemblyActivitySystem.EnterTeamTips(TeamUpNewSystem.teamInfo.members, teaminfo.members)
    else
      AssemblyActivitySystem.isNeedShowTips = true
      AssemblyActivitySystem.tipsTeamInfo = {
        oldCount = TeamUpNewSystem.teamInfo.members,
        newCount = teaminfo.members
      }
      AssemblyActivitySystem.ReqAssemblyInfo()
    end
    local logic_team_zone_ping = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_team_zone_ping)
    logic_team_zone_ping:ReportSelfPing(true)
  end
  TeamUpNewSystem.teamInfo = teaminfo
  local logic_mode_selection_for_umg = require("client.slua.logic.mode_selection.logic_mode_selection_for_umg")
  local viewID = teaminfo.sub_mode_view_ids and teaminfo.sub_mode_view_ids[1] or 0
  if TeamUpNewSystem.teamInfo.player_count and 1 < TeamUpNewSystem.teamInfo.player_count then
    logic_mode_selection_for_umg.UpdateTxMissionChoiceBeforeJoinTeam(viewID)
  else
    logic_mode_selection_for_umg.UpdateTxMissionChoiceAfterQuitTeam(viewID)
  end
  log(bWriteLog and "111logic_mode_selection_for_umg player_count =   " .. tostring(TeamUpNewSystem.teamInfo.player_count))
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  for k, v in pairs(teaminfo.members) do
    if v.alias and v.alias.id and v.alias.id ~= 0 then
      v.aliasid = v.alias.id
      v.aliastitle = FuncUtil.Gen_title(v.alias.id, v.alias.rank or 0, v.alias.ext_info or {}, v.alias.rank_id)
      v.aliasnation = v.alias.nation or ""
      v.aliasRankId = v.alias.rank_id
      local cachedProfile = logic_profile:GetLocalProfile(k)
      if cachedProfile and cachedProfile.alias then
        cachedProfile.alias.id = v.aliasid
        cachedProfile.alias.title = v.aliastitle
        cachedProfile.alias.nation = v.aliasnation
        cachedProfile.alias.rank_id = v.aliasRankId
      end
    end
  end
  for k, v in pairs(teaminfo.members) do
    if k ~= selfUID then
      local NicknameColorManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NicknameColorManager)
      if v.privilege_data and v.privilege_data.use_color then
        NicknameColorManager:SetUserData(k, v.privilege_data.use_color)
      end
    end
  end
  if not isIncrement then
    logic_chat_voice_doctor:AddJoinTeamRoomStep(631)
    EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC, ENUM_TeamInfoSyncType.All, isPlayerCountChange)
  else
    logic_chat_voice_doctor:AddJoinTeamRoomStep(632)
    EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC, ENUM_TeamInfoSyncType.Compatible)
  end
  EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_CONSCRIBE_UPDATE_TEAM)
  if not isInGame or isMainCity then
    if teamid == 0 then
      HallThemeUtils.ProcLeaveTeam()
    else
      HallThemeUtils.ProcEnterTeam(teaminfo)
    end
    local TeamUpActionUIDList = {}
    for _, v in pairs(TeamUpNewSystem.changeMemberInfo) do
      if tonumber(v.gid) ~= TeamUpNewSystem.GetSelfUID() then
        table.insert(TeamUpActionUIDList, v.gid)
      end
    end
    TeamUpNewSystem.ChangeMember()
    local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
    LogicXSuit.SyncXSuitScheme(teaminfo)
    if isPlayerCountChange then
      EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_JOIN_TEAM)
    end
    log(bWriteLog and "[WL]TeamUpNewSystem.on_team_info_sync, not isInGame")
    local ESportAllStarSystem = require("client.slua.logic.esport.logic_esport_allstar")
    if teaminfo.is_participate_competition then
      ESportAllStarSystem.ShowEnterGameTeamUI()
    end
    if not teaminfo.tournament_id or teaminfo.tournament_id == 0 then
      if UIManager.IsUIShow(UIManager.UI_Config.tournament_teamup) then
        UIManager.CloseUI(UIManager.UI_Config.tournament_teamup)
      end
      local TournamentsManager = require("client.slua.logic.tournament.TournamentsManager")
      TournamentsManager.ClearTournamentTeamInfo()
    else
      local TournamentsManager = require("client.slua.logic.tournament.TournamentsManager")
      TournamentsManager.SetTournamentTeamInfo(teaminfo.tournament_id, teamid)
    end
    TeamUpNewSystem.InitTeamEmulatorType()
    TeamUpNewSystem.ProcessEmulatorTips()
    TeamUpNewSystem.RefreshWeapon()
    local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
    local logic_share_bag_team_util = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_share_bag_team_util)
    for k, v in pairs(teaminfo.members) do
      local sharePetData = logic_share_bag_team_util:GetUsingSharePetInfoByUID(k)
      if sharePetData then
        local petData = logic_pet:FormatPetDataByServerInfo(k, sharePetData)
        TeamAvatarManager.CreatePet(k, petData)
      else
        local pet_info
        if tostring(k) == tostring(DataMgr.roleData.uid) then
          pet_info = logic_pet:GetPetDataByInsID(logic_pet:GetEquipedPetInsID())
        else
          pet_info = v.pet_info
        end
        if pet_info ~= nil and pet_info.id ~= 0 then
          local petLevel = logic_pet:GetPetLevelByExp(pet_info.id, pet_info.exp)
          local PetData = logic_pet:FormatPetDataByServerInfo(k, pet_info)
          TeamAvatarManager.CreatePet(k, PetData)
          if v.name ~= nil then
            TeamAvatarManager.SetPetName(k, v.name)
          end
        end
      end
    end
    if isEnterTeam and teaminfo.player_count > 1 and DataMgr.foot_special_effect_id ~= nil and DataMgr.foot_special_effect_id ~= 0 then
      local WardrobeDataManager = require("client.slua.logic.wardrobe.wardrobe_data")
      local itemData = WardrobeDataManager:GetValidHallDepotItemDataByInsID(DataMgr.foot_special_effect_id)
      if itemData and itemData.resID then
        TeamAvatarManager.PutonEquipment(DataMgr.roleData.uid, itemData.resID)
      end
    end
    if isEnterTeam and teaminfo.player_count > 1 then
      if not TeamUpNewSystem.IsTeamLeader() then
        local tSelfData = teaminfo.members and teaminfo.members[selfUID]
        if tSelfData then
          log(bWriteLog and "TeamUpNewSystem.on_team_info_sync, self.PlayVehicleVideo(tSelfData). ")
          TeamUpNewSystem.PlayVehicleVideo(tSelfData)
        end
        table.insert(TeamUpActionUIDList, 1, selfUID)
      else
        log(bWriteLog and "TeamUpNewSystem.on_team_info_sync I am Leader")
      end
      local ActorVoiceSystem = require("client.slua.logic.actor_voice.logic_actor_voice")
      local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
      for uid, member in pairs(teaminfo.members) do
        ActorVoiceSystem.CheckAndShowTeamActorVoiceUI(member, uid == teaminfo.leader)
        if member.voice_download_ids then
          log_tree("TeamUpNewSystem.on_team_info_sync member.voice_download_ids:", member.voice_download_ids)
          for k, v in pairs(member.voice_download_ids) do
            PufferManager.DownloadAssociateBankByActorID(k)
          end
        end
      end
      local LobbyLightLogic = require("client.slua.logic.manager.LobbySceneSubLogic.LobbyLightLogic")
      LobbyLightLogic.SwitchTeamLight()
    end
    local logic_chat_extra = require("client.slua.logic.lobby_chat.logic_chat_extra")
    logic_chat_extra.RecordVoiceMicTLog()
    local logic_share_bag_team_util = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_share_bag_team_util)
    logic_share_bag_team_util:SetShareBagInfo(isIncrement, isMemberQuit, teamid, TeamUpNewSystem.teamInfo.members)
    local logic_teamup_action = require("client.slua.logic.teamup.logic_teamup_action")
    for _, uid in pairs(TeamUpActionUIDList) do
      logic_teamup_action.PlayTeamupAction(uid)
    end
  end
  if teaminfo.team_omb_info and teaminfo.team_omb_info.member_status and (not TeamUpNewSystem.oneMoreGameTeamInfo or not TeamUpNewSystem.oneMoreGameTeamInfo.member_status) then
    if UIManager.GetUI(UIManager.UI_Config.one_more_team_tip) then
      EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_INVITE_GAME_RSP, selfUID, 2)
    else
      EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_INVITE_GAME)
    end
  end
  local LeaderTeamInfo = teaminfo.members[teaminfo.leader or 0]
  if LeaderTeamInfo and LeaderTeamInfo.ugc_mod_bundle then
    local LogicUGCMulti = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMulti)
    LogicUGCMulti:OnGetUGCModBundleRsp(LeaderTeamInfo.ugc_mod_bundle)
  end
  if not isMemberQuit then
    local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
    LogicUGCMatch:GetTeamMode(teaminfo.team_type)
  end
  local logic_suit_multi_shape = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_suit_multi_shape)
  logic_suit_multi_shape:GetBindClothInfoIfNeed()
end
function TeamUpNewSystem.UpdateOnePet(uid)
  local logic_share_bag_team_util = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_share_bag_team_util)
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local teamInfo = TeamUpNewSystem.teamInfo
  log(bWriteLog and "  TeamUpNewSystem.UpdateOnePet. uid: " .. tostring(uid))
  local k = tonumber(uid)
  local v = teamInfo.members[k]
  local sharePetData = logic_share_bag_team_util:GetUsingSharePetInfoByUID(k)
  if not v then
    return
  end
  if sharePetData then
    local petData = logic_pet:FormatPetDataByServerInfo(k, sharePetData)
    TeamAvatarManager.CreatePet(k, petData)
  else
    local pet_info
    if tostring(k) == tostring(DataMgr.roleData.uid) then
      pet_info = logic_pet:GetPetDataByInsID(logic_pet:GetEquipedPetInsID())
    else
      pet_info = v.pet_info
    end
    if pet_info ~= nil and pet_info.id ~= 0 then
      local PetData = logic_pet:FormatPetDataByServerInfo(k, pet_info)
      TeamAvatarManager.CreatePet(k, PetData)
      if v.name ~= nil then
        TeamAvatarManager.SetPetName(k, v.name)
      end
    end
  end
end
function TeamUpNewSystem.on_team_quit_respond(state, zone_id, reason)
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  local logic_chat_voice_doctor = require("client.slua.logic.chat_voice.logic_chat_voice_doctor")
  logic_chat_voice_doctor:AddJoinTeamRoomStep(610)
  logic_chat_voice_doctor:CheckLobbyQuitRoomFlow()
  log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.on_team_quit_respond state = " .. state .. ", zone_id = " .. tostring(zone_id))
  if state == NetErrorCode_NONE then
    TeamUpNewSystem.on_team_quit_for_reason(reason)
    local ESportAllStarSystem = require("client.slua.logic.esport.logic_esport_allstar")
    ESportAllStarSystem.OnQuitTeamRsp()
    TeamUpNewSystem.QuitTeam()
    TeamUpNewSystem.FixTeamGroup()
    HallThemeUtils.ProcLeaveTeam()
    EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_BE_KICKED_OUT, reason)
    local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
    if zone_id and 0 < zone_id and zone_id ~= ZoneSystem.nChooseZoneID then
      if reason ~= 11 then
        ZoneSystem.ShowReturnZoneTip(zone_id)
      end
      ZoneSystem.on_select_zone_res(NetErrorCode_NONE, zone_id)
    end
    if 0 < ZoneSystem.nChooseZoneID then
      local UDPPingCollector = slua_GameFrontendHUD.UDPPingCollector
      local isChoosingZoneAccess = UDPPingCollector:IsChooingZoneAccess()
      if not isChoosingZoneAccess then
        ZoneSystem.on_select_zone_req(ZoneSystem.nChooseZoneID)
      end
    end
    TeamUpNewSystem.ReleaseOneMoreGameInfo()
  else
    logic_chat_voice_doctor:AddJoinTeamRoomStep(611)
  end
end
function TeamUpNewSystem.on_team_quit_for_reason(reason)
  EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAM_PLATFORM_QUIT_TEAM_SUC_AND_APPLY, reason)
end
function TeamUpNewSystem.on_team_apply_respond(state, verCompareResult, userNick, text_id)
  log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.on_team_apply_respond state = " .. state .. "  userNick = " .. tostring(userNick))
  log(bWriteLog and "[chub]TeamUpNewSystem.on_team_invite_respond userNick = " .. tostring(userNick))
  log(bWriteLog and "[chub]TeamUpNewSystem.on_team_invite_respond text_id = " .. tostring(text_id))
  if state == NetErrorCode_NONE then
  elseif state == "refuse" then
    if text_id then
      local reason = LocUtil.LocalizeResFormat(text_id)
      ShowNotice(LocUtil.LocalizeResFormat(43751, userNick or "", reason))
    else
      TeamUpNewSystem.ErrorNotice(110013, 38827, userNick)
    end
  elseif state == "timeout" then
    TeamUpNewSystem.ErrorNotice(110013, 38829, userNick)
  elseif state == "autoRefuseOnTeamChange" then
    ShowNotice(110057)
  elseif state == "team in match" then
    ShowNotice(110060)
  elseif state == "already_in_match" then
    ShowNotice(110061)
    log(bWriteLog and "TeamUpNewSystem.on_team_invite_respond MatchSystem.QueryPlayerState 2")
    MatchSystem.QueryPlayerState()
  elseif state == "send_apply_success" then
    ShowNotice(110012)
  elseif state == "not_same_version" then
    TeamUpNewSystem.HandleVersionErrorCode(verCompareResult)
  elseif state == "team_is_full" then
    ShowNotice(110007)
  elseif state == "leader_changed" then
    ShowNotice(6432)
  elseif state == "low_priority_match_banned" then
    MatchSystem.ShowBanTip(MatchSystem.GetTeamUpBanTip())
  elseif state == "match_isolation_label_banned" then
    MatchSystem.ShowBanTip(LocUtil.GetLocalizeResStr(29113))
  elseif state == "guest_state_banned" then
    ShowNotice(22021)
  elseif state == "metro_mode_not_open" then
    ShowNotice(740016)
  elseif state == "pre_team_limit" then
    ShowNotice(27192)
  elseif state == "not_friend" then
    ShowNotice(29388)
  elseif state == "cant-join-8v8-team" then
    ShowNotice(11893)
  elseif state == "cant-join-socialland-team" then
    ShowNotice(11893)
  elseif state == "cant-join-ugc-team" then
    ShowNotice(48410)
  elseif state == "cant-join-ugc-team-level-limit" then
    ShowNotice(511200)
  elseif state == "cant-join-ugc-team-dev-limit" then
    ShowNotice(511203)
  elseif state == "team_reject_strangers" then
    ShowNotice(773309)
  elseif state == "not_apply_promotion_rating" then
    ShowNotice(100610015)
  elseif state == "not_apply_promotion_multi_mode" then
    ShowNotice(100610014)
  elseif state == "not_apply_promotion_mode" then
    ShowNotice(100610013)
  elseif state == "not_apply_player_promotion_rating" then
    ShowNotice(100610016)
  elseif state == "not_in_team" then
    ShowNotice(817224)
  elseif state == "already_in_game" then
    ShowNotice(9911106)
  elseif not TeamUpNewSystem.HandleTeamJoinErrorCode(state) then
    TeamUpNewSystem.HandleErrorCode(state)
  end
end
function TeamUpNewSystem.HandleTeamJoinErrorCode(state)
  if state == "device_type_limit" then
    local EmulatorSystem = require("client.logic.login.logic_emulator")
    if EmulatorSystem.IsX86Phone() then
      ShowNotice(520025)
    else
      ShowNotice(7126)
    end
  elseif state == "tournament_limit_min_level" then
    ShowNotice(7127)
  elseif state == "tournament_limit_min_seg_level" then
    ShowNotice(7128)
  elseif state == "tournament_limit_max_seg_level" then
    ShowNotice(7129)
  elseif state == "tournament_id_not_exist" then
    ShowNotice(7130)
  elseif state == "tournament_id_rule_mode_err" then
    ShowNotice(7131)
  elseif state == "tournament_not_in_time" then
    ShowNotice(7132)
  elseif state == "tournament_unvisible_region" then
    ShowNotice(7133)
  elseif state == "not_carteam_teammate" then
    ShowNotice(12651)
  elseif state == "segment_level_not_enough" then
    ShowNotice(7128)
  elseif state == "invitee_in_manor" or state == "target_in_manor" then
    ShowNotice(655422)
  elseif state == "inviter_in_manor" or state == "oneself_in_manor" then
    ShowNotice(655423)
  elseif state == "invitee_in_collect_hall" or state == "target_in_collect_hall" then
    ShowNotice(100051049)
  elseif state == "inviter_in_collect_hall" or state == "oneself_in_collect_hall" then
    ShowNotice(100051050)
  elseif state == "peakgame_segment_limit" then
    ShowNotice(46129)
  else
    return false
  end
  return true
end
function TeamUpNewSystem.on_team_join_rsp(res, teamid, teamInfo, verCompareResult)
  log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.on_team_join_rsp, res = " .. tostring(res) .. ", teamid = " .. tostring(teamid) .. ", teamInfo = " .. tostring(teamInfo))
  if res == NetErrorCode_NONE then
    ShowNotice(110042)
  elseif res == "team_is_full" then
    ShowNotice(110007)
  elseif res == "target_not_online" then
    ShowNotice(110009)
  elseif res == "already_in_team" then
    ShowNotice(39090)
  elseif res == "already_has_team" then
    ShowNotice(39090)
  elseif res == "team-in-match" then
    ShowNotice(110059)
  elseif res == "team_not_exist" then
    ShowNotice(520037)
  elseif res == "not_same_version" then
    TeamUpNewSystem.HandleVersionErrorCode(verCompareResult)
  elseif res == "inviter_in_match" then
    ShowNotice(110059)
  elseif res == "invitee_in_match" then
    ShowNotice(39091)
  elseif res == "inviter_in_game" then
    ShowNotice(9911106)
  elseif res == "team_not_found" then
    ShowNotice(4361)
  elseif res == "already_in_match" then
    ShowNotice(39091)
  elseif res == "already_in_game" then
    ShowNotice(39091)
  elseif res == "segment_limit" then
    ShowNotice(7788)
  elseif res == "low_priority_match_banned" then
    MatchSystem.ShowBanTip(MatchSystem.GetTeamUpBanTip())
  elseif res == "match_isolation_label_banned" then
    MatchSystem.ShowBanTip(LocUtil.GetLocalizeResStr(29113))
  elseif res == "voice_team_no_invite" then
    ShowNotice(10573)
  elseif res == "not_exist_conscribe" then
    ShowNotice(100220010)
  elseif res == "guest_state_banned" then
    ShowNotice(22006)
  elseif res == "compete_already_in_battle" then
    log(bWriteLog and "TeamUpNewSystem.on_team_invite_respond MatchSystem.QueryPlayerState 3")
    MatchSystem.QueryPlayerState()
  elseif res == "join_team_in_cool_down_time" then
    ShowNotice(29776)
  elseif res == "pre_team_limit" then
    ShowNotice(27192)
  elseif res == "tournament_id_not_invalid" then
    ShowNotice(501076)
  elseif res == "tournament_auth_check_failed" then
    ShowNotice(505047)
  elseif res == "same_main_city_limit" then
    ShowNotice(77922)
  elseif res == "join_team_promotion_invalid" then
    if not verCompareResult or not verCompareResult.error_code then
      ShowNotice(85160)
    else
      local uid = verCompareResult.member_uid or 0
      local nickName = uid
      local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
      local profile = logic_profile:GetLocalProfile(uid)
      if profile then
        nickName = profile.nickName
      end
      ShowNotice(LocUtil.LocalizeResFormat(verCompareResult.error_code, nickName))
    end
  elseif res == "applyer_in_metro_scence" then
    ShowNotice(6656432)
  elseif type(res) == "number" then
    if res == 505046 then
      local TournamentsManager = require("client.slua.logic.tournament.TournamentsManager")
      log_tree("TournamentsManager.inviteApplyData", TournamentsManager.inviteApplyData)
      local tournament_id = TournamentsManager.inviteApplyData and TournamentsManager.inviteApplyData.tournament_id or 0
      TournamentsManager.ShowSafetyCheckUI(tournament_id)
    else
      ShowNotice(res)
    end
  elseif not TeamUpNewSystem.HandleTeamJoinErrorCode(res) then
    TeamUpNewSystem.HandleErrorCode(res)
  end
  if res ~= NetErrorCode_NONE then
    if TeamUpNewSystem.oneMoreGameTeamInfo then
      TeamUpNewSystem.one_more_battle_reply_rsp()
    end
    EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_JOINT_TEAM_FAIL, teamid)
  end
end
function TeamUpNewSystem.on_join_anchor_team_res(err, ver_ret)
  log(bWriteLog and "[TeamUpNewSystem] on_join_anchor_team_res err = " .. tostring(err) .. ", ver_ret = " .. tostring(ver_ret))
  if err == "guest_state_banned" then
    ShowNotice(22006)
  elseif err == "owed_state_banned" then
    ShowNotice(24226)
  elseif err == "already_has_team" then
    ShowNotice(110044)
  elseif err == "already_in_match" then
    ShowNotice(4360)
  elseif err == "already_in_game" then
    ShowNotice(4400)
  elseif err == "already_in_room" then
    ShowNotice(110117)
  elseif err == "low_priority_match_banned" then
    MatchSystem.ShowBanTip(MatchSystem.GetTeamUpBanTip())
  elseif err == "match_isolation_label_banned" then
    MatchSystem.ShowBanTip(LocUtil.GetLocalizeResStr(29113))
  elseif err == "anchor_match_isolation_label_banned" then
    MatchSystem.ShowBanTip(LocUtil.GetLocalizeResStr(29112))
  elseif err == "anchor_team_limit" then
    ShowNotice(25237)
  elseif err == "not_same_version" then
    TeamUpNewSystem.HandleVersionErrorCode(ver_ret)
  elseif err == "team_is_full" then
    ShowNotice(110007)
  elseif err == "applyer in socialland" then
    ShowNotice(25236)
  elseif err == "pre_team_limit" then
    ShowNotice(27192)
  else
    TeamUpNewSystem.HandleErrorCode(err)
  end
end
function TeamUpNewSystem.on_team_kick_respond(res, targetUID)
  log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.on_team_kick_respond res = " .. res .. ", targetUID = " .. targetUID)
  if res == NetErrorCode_NONE then
    TeamUpNewSystem.team_info_request()
  else
    ShowNotice(301165)
  end
end
function TeamUpNewSystem.on_team_apply_notify(applierID, applierName, teamid, applyInfo)
  log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.on_team_apply_notify applierID = " .. applierID .. ", applierName = " .. applierName)
  local autoRefuse = TeamUpNewSystem.CheckApplyAutoRefuse(applierID)
  if autoRefuse then
    log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.on_team_apply_notify autoRefuse = true")
    if applyInfo then
      TeamUpNewSystem.team_apply_reply("refuse", applierID, teamid, applyInfo.src, applyInfo.from, applyInfo.signatur, applierName)
    end
    return
  end
  local isExistIndex = TeamUpNewSystem.CheckSameInvite(applierID, 1)
  local inviteApplyData = {
    type = 1,
    playerId = applierID,
    playerName = applierName,
    applierTeamID = teamid,
    showCD = C_APPLY_INVITE_SHOW_TIME,
    closeCD = C_APPLY_INVITE_CLOSE_TIME,
    closeTotalTime = C_APPLY_INVITE_CLOSE_TIME
  }
  if applyInfo then
    local TableUtil = require("common.table_util")
    TableUtil.OverrideTable(inviteApplyData, applyInfo)
  end
  if isExistIndex == 0 then
    table.insert(TeamUpNewSystem.inviteApplyQueue, inviteApplyData)
  else
    TeamUpNewSystem.inviteApplyQueue[isExistIndex] = inviteApplyData
  end
  if GameStatus.IsInFightingNotSocialNotMainCityNotHome() then
    return
  end
  TeamUpNewSystem.ShowInviteTip()
end
function TeamUpNewSystem.on_team_info_change_notify(teamid, operate_type, param, param1, param2)
  log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.on_team_info_change_notify teamid = " .. tostring(teamid) .. ", operate_type = " .. tostring(operate_type) .. ", param = " .. tostring(param) .. ", param1 = " .. tostring(param1) .. ", param2 = " .. tostring(param2))
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local selfUID = TeamUpNewSystem.GetSelfUID()
  if operate_type == 1 then
    if TeamUpNewSystem.GetTeamNum() == 1 then
      EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CREATE_TEAM)
    end
    TeamUpNewSystem.OtherJoinTeam(teamid, param)
    EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_ADD_OTHER_PLAYER, teamid, param)
    EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CHANGE_SHOW_VEHICLE)
    local logic_team_match_state = require("client.slua.logic.teamup.logic_team_match_state")
    logic_team_match_state:RequestCheckTeamMatchState()
  elseif operate_type == 2 then
    if param then
      if selfUID == tonumber(param) then
        if param2 and param2 == 6 then
          TeamUpNewSystem.HandleErrorCode("kickOut_in_allstar")
        elseif param2 and param2 == 11 then
          log(bWriteLog and "TeamUpNewSystem.on_team_info_change_notify param2 = 11, skip tips")
        else
          TeamUpNewSystem.HandleErrorCode("kickOut")
        end
        TeamUpNewSystem.QuitTeam()
        TeamUpNewSystem.FixTeamGroup()
        EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_BE_KICKED_OUT)
      else
        EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_EXIT_OTHER_PLAYER, param)
        TeamUpNewSystem.OtherQuitTeam(param)
        TeamUpNewSystem.FixTeamGroup()
        EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_EXIT_OTHER_PLAYER)
      end
    else
      TeamUpNewSystem.team_info_request()
    end
    EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CHANGE_SHOW_VEHICLE)
    local pandoraSystem = require("client.slua.logic.Pandora.pandora_system")
    pandoraSystem.HideCurAct()
  elseif operate_type == 3 then
    log(bWriteLog and "on_team_info_change_notify param1 = " .. tostring(param1))
    local curPlayerCount = param1 or TeamUpNewSystem.GetTeamNum()
    if param then
      if selfUID == tonumber(param) and 1 < curPlayerCount then
        if GameStatus.IsInLobbyOrMainCity() then
          ShowNotice(LocUtil.LocalizeResFormat(110046))
        end
      elseif selfUID ~= tonumber(param) then
        TeamUpNewSystem.KeepJoinApply()
        if #TeamUpNewSystem.inviteApplyQueue == 0 then
          UIManager.CloseUI(UIManager.UI_Config.Team_Invite_Tip_UIBP)
        end
      end
    end
    if TeamUpNewSystem.teamInfo then
      TeamUpNewSystem.teamInfo.leader = param
    end
    EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC, ENUM_TeamInfoSyncType.Ready)
    EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC, ENUM_TeamInfoSyncType.Base)
    EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CHANGE_LEADER_NOTIFY)
    EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_CONSCRIBE_UPDATE_TEAM)
    HallThemeUtils.ProcEnterTeam()
  elseif operate_type == 4 then
    TeamUpNewSystem.team_info_request()
  elseif operate_type == 5 then
    log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.on_team_info_change_notify new teamtype = " .. tostring(param))
    if TeamUpNewSystem.teamInfo then
      TeamUpNewSystem.teamInfo.game_type = 1
      TeamUpNewSystem.teamInfo.team_type = tonumber(param)
      TeamUpNewSystem.teamInfo.sub_mode_view_ids = param1
    end
    local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
    local bPreUgcMatchInfo = LogicUGCMatch:HasUGCMatchInfo()
    log(bWriteLog and "TeamUpNewSystem.on_team_info_change_notify bPreUgcMatchInfo = " .. tostring(bPreUgcMatchInfo))
    local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
    if TeamUpNewSystem.teamInfo and TeamUpNewSystem.teamInfo.team_type and LogicUGCMatch:IsUGCSingleMatchMode(TeamUpNewSystem.teamInfo.team_type) then
      LogicUGCMatch:CleanEditMatchInfo(TeamUpNewSystem.IsTeamLeader())
      LogicUGCMatch:SetIsCreativeWoW(false)
      if TeamUpNewSystem.teamInfo.id then
        if TeamUpNewSystem.afterteamID then
          local PlayerIndex = 0
          for k, members in pairs(TeamUpNewSystem.teamInfo.members) do
            PlayerIndex = PlayerIndex + 1
          end
          if TeamUpNewSystem.afterteamID ~= TeamUpNewSystem.teamInfo.id and TeamUpNewSystem.teamInfo.id ~= 0 and 1 < PlayerIndex then
            TeamUpNewSystem.afterteamID = TeamUpNewSystem.teamInfo.id
            log(bWriteLog and "on_team_info_change_notify self.afterteamID = " .. TeamUpNewSystem.afterteamID .. "self.teamInfo.id = " .. TeamUpNewSystem.teamInfo.id)
            EventSystem:postEvent(EVENTTYPE_ROOM, EVENTID_ROOM_ENTRY_UPDATE_TIPS, DataMgr.roleData.uid)
          end
        else
          log(bWriteLog and "on_team_info_change_notify self.teamInfo.id = " .. TeamUpNewSystem.teamInfo.id)
          TeamUpNewSystem.afterteamID = TeamUpNewSystem.teamInfo.id
        end
      end
    else
      LogicUGCMatch:ClearData()
    end
    EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC, ENUM_TeamInfoSyncType.MatchMode)
    EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_NEW_TEAM_MATCH_MODE, bPreUgcMatchInfo)
    if 1 < TeamUpNewSystem.GetTeamNum() then
      local logic_team_match_state = require("client.slua.logic.teamup.logic_team_match_state")
      logic_team_match_state:RequestCheckTeamMatchState()
      local LanguageHandler = require("client.network.Protocol.LanguageHandler")
      LanguageHandler.send_query_match_langs_req()
    end
  elseif operate_type == 6 then
    local memberInfo = TeamUpNewSystem.GetMemberInfo(param.uid)
    if memberInfo then
      memberInfo.status = param.status
      EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC, ENUM_TeamInfoSyncType.Ready, param.status, param.uid)
    else
      log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.on_team_info_change_notify, uid = " .. tostring(param.uid) .. " is not in team!")
    end
  elseif operate_type == 7 then
    TeamUpNewSystem.ReLinkLine(param)
    if param.status then
      local memberInfo = TeamUpNewSystem.GetMemberInfo(param.uid)
      if memberInfo then
        memberInfo.status = param.status
        EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC, ENUM_TeamInfoSyncType.Ready, param.status, param.uid)
      end
    end
  elseif operate_type == 8 then
    if TeamUpNewSystem.teamInfo then
      TeamUpNewSystem.teamInfo.fill = param
    end
    local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
    MatchModeMgrSystem.bAutoMatch = param == 1
    if TeamUpNewSystem.teamInfo.player_count and 1 < TeamUpNewSystem.teamInfo.player_count then
      local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
      logic_mode_selection:HasSelectMetroTxMission(0)
    end
    EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC, ENUM_TeamInfoSyncType.MatchMode)
  elseif operate_type == 9 then
    TeamUpNewSystem.HandleVersionErrorCode()
  elseif operate_type == 10 then
    if param then
      TeamUpNewSystem.UpdateVoiceInfo(param.uid, param.voice)
      EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC, ENUM_TeamInfoSyncType.Voice, param.uid)
    end
  elseif operate_type == 11 then
    if param then
      TeamUpNewSystem.UpdateClanName(param.uid, param.carteam_name)
      EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC, ENUM_TeamInfoSyncType.Crops)
    end
  elseif operate_type == 12 then
    if param then
      TeamUpNewSystem.UpdateCrops(param.uid, param.corps_name, param.corps_icon, param.cur_corps_alias_id, param.corps_position)
      EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC, ENUM_TeamInfoSyncType.Crops)
    end
  elseif operate_type == 13 then
    if param then
      TeamUpNewSystem.UpdateCredit(param.uid, param.credit)
      EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC, ENUM_TeamInfoSyncType.Credit)
    end
  elseif operate_type == 15 then
    local memberInfo = TeamUpNewSystem.GetMemberInfo(param.uid)
    if memberInfo then
      memberInfo.weapon_wear_info = param.weapon_wear_info
      TeamUpNewSystem.OnMemberWeaponChange(param.uid)
    end
  elseif operate_type == 16 then
    TeamUpNewSystem.QuitTeam()
    TeamUpNewSystem.FixTeamGroup()
    EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_BE_KICKED_OUT)
  elseif operate_type == 17 then
    TeamUpNewSystem.UpdateVehicle(param)
    EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CHANGE_SHOW_VEHICLE)
  elseif operate_type == 18 then
    TeamUpNewSystem.UpdateBackground(param)
  elseif operate_type == 19 then
    local memberInfo = TeamUpNewSystem.GetMemberInfo(param.uid)
    if memberInfo then
      memberInfo.brand_id = param.brand_id
    end
    EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC, ENUM_TeamInfoSyncType.NameFrame)
  elseif operate_type == 20 then
    TeamUpNewSystem.ChangeBagPendant(param)
  elseif operate_type == 21 then
    if param then
      local memberInfo = TeamUpNewSystem.GetMemberInfo(param.uid)
      if memberInfo then
        memberInfo.level = param.level
        EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC, ENUM_TeamInfoSyncType.Base)
      end
    end
  elseif operate_type == 22 then
    if param then
      local memberInfo = TeamUpNewSystem.GetMemberInfo(param.uid)
      if memberInfo then
        memberInfo.ace_imprint_show_id = param.ace_imprint_show_id
        memberInfo.ace_imprint_base_id = param.ace_imprint_base_id
        memberInfo.peakgame_ace_count = param.peakgame_ace_count
        memberInfo.peakgame_ace_id = param.peakgame_ace_id
        memberInfo.ace_show_type = param.ace_show_type
        EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC, ENUM_TeamInfoSyncType.AceImprint)
      end
    end
  elseif operate_type == 23 then
  elseif operate_type == 24 then
    if param ~= nil and param1 ~= nil and type(param1) == "table" and LobbySystem.CheckOpen(BP_ENUM_TEAM_UP_LIMIT_SWITCH) then
      log(bWriteLog and "TeamUpNewSystem.on_team_info_change_notify Team segment limit status notify")
      local LogicTeamUpLimit = require("client.slua.logic.teamup.logic_team_up_limit")
      LogicTeamUpLimit.SetCurTeamLimitStatusAndRange(param, param1)
      EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_LIMIT_RANGE_CHANGE)
    end
  elseif operate_type == 25 then
    if param then
      EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_NOTIFY_QUICK_MSG, param)
    end
  elseif operate_type == 26 then
    if param then
      local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
      LogicUGCMatch:ClearData()
      LogicUGCMatch:SetModID(param)
    end
  elseif operate_type == 27 then
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    log_tree("TeamUpNewSystem.on_team_info_change_notify param:", param)
    if param and type(param.voice_download_ids) == "table" then
      local voice_download_ids = param.voice_download_ids
      if next(voice_download_ids) then
        for k, v in pairs(voice_download_ids) do
          PufferManager.DownloadAssociateBankByActorID(k)
        end
      end
    end
  elseif operate_type == 29 or operate_type == 30 then
    local logic_main_city_join = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_main_city_join)
    logic_main_city_join:OnTeamInfoSync(operate_type, param)
    local memberInfo = TeamUpNewSystem.GetMemberInfo(param1)
    if memberInfo then
      memberInfo.main_city_info = param
      EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC, ENUM_TeamInfoSyncType.MainCity)
    end
  elseif operate_type == 100 then
    local memberInfo = TeamUpNewSystem.GetMemberInfo(param1)
    if memberInfo then
      memberInfo.upvote = param
      memberInfo.recent_upvote = param2
      EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC, ENUM_TeamInfoSyncType.Like)
    end
  elseif operate_type == 101 then
  elseif operate_type == 102 then
    local memberInfo = TeamUpNewSystem.GetMemberInfo(param1)
    if memberInfo then
      memberInfo.aliasid = param.id
      memberInfo.aliastitle = FuncUtil.Gen_title(param.id, param.rank, param.ext_info, param.rank_id)
      memberInfo.aliasnation = param.nation
      memberInfo.aliasRankId = param.rank_id
      local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
      local cachedProfile = logic_profile:GetLocalProfile(memberInfo.uid)
      if cachedProfile and cachedProfile.alias then
        cachedProfile.alias.id = memberInfo.aliasid
        cachedProfile.alias.title = memberInfo.aliastitle
        cachedProfile.alias.nation = memberInfo.aliasnation
        cachedProfile.alias.rank_id = memberInfo.aliasRankId
      end
      EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC, ENUM_TeamInfoSyncType.Alias)
    end
  elseif operate_type == 103 then
    if 1 < TeamUpNewSystem.GetTeamNum() then
      local shouldSkip = false
      if TeamUpNewSystem.lastMemberLoginTime and param and param.map_info then
        local onlyHas77 = true
        for k, _ in pairs(param.map_info) do
          if k ~= 77 then
            onlyHas77 = false
            break
          end
        end
        if onlyHas77 then
          shouldSkip = true
        end
      end
      if shouldSkip then
        log(bWriteLog and "[logic_team_up] operate_type 103 skipped, teammate login with only map 77")
        TeamUpNewSystem.lastMemberLoginTime = nil
      else
        TeamUpNewSystem.lastMemberLoginTime = nil
        local logic_team_match_state = require("client.slua.logic.teamup.logic_team_match_state")
        logic_team_match_state:RequestCheckTeamMatchState()
      end
    end
  elseif operate_type == 104 then
    log(bWriteLog and "HeadShowChangeParam is :")
    for i, v in pairs(param) do
      TeamUpNewSystem.headShowChangeInfo.uid = i
      TeamUpNewSystem.headShowChangeInfo.param = v
    end
    EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CHANGE_HEADSHOW)
  elseif operate_type == 105 then
    log(bWriteLog and "PlayerAvatarDepotShowSettingChanged In Team")
    TeamAvatarManager.UpdateAvatarDepotShowSetting(tostring(param.uid), param.depot_show_info)
    EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CHANGE_SHOW_VEHICLE)
  elseif operate_type == 106 then
    local logic_lobby_my_team = require("client.slua.logic.teamup.logic_lobby_my_team")
    logic_lobby_my_team.notify_leader_voice(param, param1)
  elseif operate_type == 107 then
    if param and selfUID == tonumber(param) then
    else
      ShowNotice(LocUtil.LocalizeResFormat(100080022))
    end
  elseif operate_type == 117 then
    local XMissionTeamUpSystem = require("client.slua.logic.TxMission.logic_xmission_team")
    local uid = param and param.uid or 0
    local military_level = param and param.metro_team_info and param.metro_team_info.military_level or 1
    XMissionTeamUpSystem.MilitaryNotify(uid, military_level)
  elseif operate_type == 109 then
    TeamUpNewSystem.teamInfo.intimacy_info = param
    EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC, ENUM_TeamInfoSyncType.intimacyIcon)
    EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_MEMBER_RELATION_CHANGE, ENUM_TeamInfoSyncType.intimacyIcon)
    print(bWriteLog and "TeamUpNewSystem:OnShowRelationAnim type = " .. tostring(ENUM_TeamInfoSyncType.intimacyIcon))
    log_tree("[ZH] param", param)
    if 1 < TeamUpNewSystem.GetTeamNum() then
      local logic_team_match_state = require("client.slua.logic.teamup.logic_team_match_state")
      logic_team_match_state:RequestCheckTeamMatchState()
    end
  elseif operate_type == 118 and param then
    if TeamUpNewSystem.teamInfo then
      local LeaderTeamInfo = TeamUpNewSystem.teamInfo.members[TeamUpNewSystem.teamInfo.leader or 0]
      if LeaderTeamInfo and LeaderTeamInfo.ugc_mod_bundle then
        LeaderTeamInfo.ugc_mod_bundle = param
      end
    end
    local LogicUGCMulti = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMulti)
    LogicUGCMulti:OnGetUGCModBundleRsp(param)
  elseif operate_type == 119 and param then
    if 1 < TeamUpNewSystem.GetTeamNum() then
      local logic_team_match_state = require("client.slua.logic.teamup.logic_team_match_state")
      logic_team_match_state:RequestCheckTeamMatchState()
    end
  elseif operate_type == 120 then
    local logic_team_zone_ping = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_team_zone_ping)
    logic_team_zone_ping:UpdateTeamZonePing(param)
  elseif operate_type == 130 then
    if param then
      local logic_weapon_pendant = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_weapon_pendant)
      logic_weapon_pendant:UpdatePendantData(param.uid, param.weapon_pendants)
    else
      log(bWriteLog and "not param!")
    end
  elseif operate_type == 131 then
    if param then
      TeamUpNewSystem.UpdateGarageCarInfo(param.uid, param.car_page_info)
      local ThemeVehicleManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ThemeVehicleManager)
      ThemeVehicleManager:ShowThemeVehicle()
    end
  elseif operate_type == 132 then
    if param then
      if param.privilege_data and param.privilege_data.use_color then
        local NicknameColorManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NicknameColorManager)
        NicknameColorManager:SetUserData(param.uid, param.privilege_data.use_color)
      end
    else
      log(bWriteLog and "TeamUpNewSystem.on_team_info_change_notify 132, not param")
    end
  elseif operate_type == 133 then
    log_tree("TeamUpNewSystem.on_team_info_change_notify: 133 param", param)
    if param and type(param) == "table" then
      local memberInfo = TeamUpNewSystem.GetMemberInfo(param.uid)
      if memberInfo then
        memberInfo.brief_collect_data = param.brief_collect_data or {}
        EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_UPDATE_COLLECT_SCORE)
      end
    end
  elseif operate_type == 134 then
    log_tree("TeamUpNewSystem.on_team_info_change_notify: 134 param", param)
    if param then
      local memberInfo = TeamUpNewSystem.GetMemberInfo(param.uid)
      if memberInfo then
        memberInfo.set_milestone_data = param.set_milestone_data or {}
      end
    end
  elseif operate_type == 135 and param then
    if type(param) == "table" and param.uid and param.uid ~= tonumber(DataMgr.roleData.uid) then
      if param.flag == 1 then
        local Avatar = TeamAvatarManager.GetAvatarByUid(param.uid)
        if Avatar ~= nil and Avatar:GetModel() ~= nil then
          local Model = Avatar:GetModel()
          local ECharacterEffectTriggerCondition = import("ECharacterEffectTriggerCondition")
          EventSystem:postEvent(EVENTTYPE_CHARACTER_EFFECT, EVENTID_CHARACTER_EFFECT_APPLY, Model, ECharacterEffectTriggerCondition.LobbyDisplay_LowHealth)
          local time_ticker = require("common.time_ticker")
          time_ticker.AddTimerOnce(3, function()
            if Model then
              EventSystem:postEvent(EVENTTYPE_CHARACTER_EFFECT, EVENTID_CHARACTER_EFFECT_APPLY, Model, ECharacterEffectTriggerCondition.LobbyDisplay_HighHealth)
            end
          end)
        end
      elseif param.flag == 2 and TeamAvatarManager.CheckHasEquipped(param.uid, param.resid) then
        local featuresItem = CDataTable.GetTableData("FeaturesItems", param.resid)
        if featuresItem and featuresItem.Features and featuresItem.Features ~= "" then
          local StringUtil = require("common.string_util")
          local features = StringUtil.Split(featuresItem.Features, ";")
          for _, featureID in ipairs(features) do
            local cfg = CDataTable.GetTableData("FeaturesConfig", tonumber(featureID) or 0)
            if cfg and cfg.FeatureType == 49 and cfg.ExpressionID and 0 < cfg.ExpressionID then
              log(bWriteLog and string.format("TeamUpNewSystem.on_team_info_change_notify: 135 flag=2 PlayAction uid=%s resid=%s ExpressionID=%s", tostring(param.uid), tostring(param.resid), tostring(cfg.ExpressionID)))
              TeamAvatarManager.PlayAction(tostring(param.uid), cfg.ExpressionID)
              break
            end
          end
        end
      end
    end
  elseif operate_type == 136 then
    printf("TeamUpNewSystem.on_team_info_change_notify: 136 param:%s, param1:%s", param, param1)
  elseif operate_type == 999 then
    local logic_team_up_test = require("client.slua.logic.teamup.logic_team_up_test")
    local newTeamInfo = logic_team_up_test.GetTeamInfo()
    TeamUpNewSystem.on_team_info_sync(teamid, newTeamInfo, true, false)
    TeamUpNewSystem.PlayVehicleVideo(param)
    local ActorVoiceSystem = require("client.slua.logic.actor_voice.logic_actor_voice")
    ActorVoiceSystem.CheckAndShowTeamActorVoiceUI(param, false)
  elseif operate_type == 122 then
    local XMissionSystem = require("client.slua.logic.TxMission.logic_xmission_main")
    if XMissionSystem.IsInXMission() then
      log_tree("TeamUpNewSystem.on_team_info_change_notify: 122 param", param)
      if param then
        UIManager.ShowUI(UIManager.UI_Config.Xmission_Readiness_Popup_UIBP, param)
      end
    end
  elseif operate_type == 123 then
    local XMissionSystem = require("client.slua.logic.TxMission.logic_xmission_main")
    if XMissionSystem.IsInXMission() then
      log_tree("TeamUpNewSystem.on_team_info_change_notify: 123 param", param)
      if param then
        EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_XMISSION_WORTH_READINESS_SYCN, param)
      end
    end
  elseif operate_type == 137 then
  elseif operate_type == 138 and param then
    log(bWriteLog and string.format("TeamUpNewSystem.on_team_info_change_notify: 138 param uid=%s resid=%s", tostring(param and param.uid), tostring(param and param.resid)))
    if type(param) == "table" and param.uid and param.uid ~= tonumber(DataMgr.roleData.uid) then
      local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
      local Avatar = TeamAvatarManager.GetAvatarByUid(param.uid)
      if Avatar ~= nil and Avatar:GetModel() ~= nil then
        local Model = Avatar:GetModel()
        local LobbyAvatar = require("client.logic.avatar.LobbyAvatar")
        Model:PreviewMoveEffect(param.resid, LobbyAvatar.Const.AdditionEffectEmote)
      end
    end
  elseif operate_type == 139 and param then
    log(bWriteLog and string.format("TeamUpNewSystem.on_team_info_change_notify: 139 param uid=%s resid=%s", tostring(param and param.uid), tostring(param and param.resid)))
    if type(param) == "table" and param.uid and param.uid ~= tonumber(DataMgr.roleData.uid) then
      local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
      local Avatar = TeamAvatarManager.GetAvatarByUid(param.uid)
      if Avatar ~= nil and Avatar:GetModel() ~= nil then
        local Model = Avatar:GetModel()
        local LobbyAvatar = require("client.logic.avatar.LobbyAvatar")
        Model:PreviewFootStepEffect(param.resid, LobbyAvatar.Const.AdditionEffectEmote)
      end
    end
  end
  local LobbyEffect = require("client.logic.login.logic_LobbyEffect")
  LobbyEffect.UpdateEffectUI()
end
function TeamUpNewSystem.on_team_change_wear(memberUid, isPushOn, mResId, mAvatarPos, wearInfo, gold_dress_set_info, gold_dress_set_info_all)
  TeamUpNewSystem.changeWearInfo = {
    uid = memberUid,
    pos = isPushOn,
    resId = mResId,
    avatarPos = mAvatarPos,
    wearInfo = wearInfo or {}
  }
  local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
  if LogicXSuit.IsXSuit(mResId) then
    local period = LogicXSuit.GetPeriodByItemId(mResId)
    if period then
      local branch = LogicXSuit.GetBranchByItemId(mResId) or 0
      local newItemID = mResId
      if gold_dress_set_info and gold_dress_set_info.set_info and gold_dress_set_info.set_info[period] and gold_dress_set_info.set_info[period][branch] then
        newItemID = LogicXSuit.GetSwitchItemByItemAndSwitchLevel(newItemID, gold_dress_set_info.set_info[period][branch])
      end
      if gold_dress_set_info_all and gold_dress_set_info_all.set_info and gold_dress_set_info_all.set_info[period] and gold_dress_set_info_all.set_info[period][branch] then
        local state = gold_dress_set_info_all.set_info[period][branch].bicolor_state
        if state then
          newItemID = LogicXSuit.ChangeItemIDByState(newItemID, state)
        end
      end
      TeamUpNewSystem.changeWearInfo.resId = newItemID
    end
  end
  if wearInfo and wearInfo[1] then
    if LogicXSuit.IsXSuit(wearInfo[1]) then
      local period = LogicXSuit.GetPeriodByItemId(wearInfo[1])
      if period then
        local newItemID = wearInfo[1]
        local branch = LogicXSuit.GetBranchByItemId(newItemID) or 0
        local source = wearInfo[ENUM_AVATAR_DATA_TYPE.Source] or 0
        if gold_dress_set_info and gold_dress_set_info.set_info and gold_dress_set_info.set_info[period] and gold_dress_set_info.set_info[period][branch] and source ~= EWardrobeDataSource.InheritWardrobe then
          newItemID = LogicXSuit.GetSwitchItemByItemAndSwitchLevel(newItemID, gold_dress_set_info.set_info[period][branch])
        end
        if gold_dress_set_info_all and gold_dress_set_info_all.set_info and gold_dress_set_info_all.set_info[period] and gold_dress_set_info_all.set_info[period][branch] then
          local state = gold_dress_set_info_all.set_info[period][branch].bicolor_state
          if state then
            newItemID = LogicXSuit.ChangeItemIDByState(newItemID, state)
          end
        end
        wearInfo[1] = newItemID
        TeamUpNewSystem.changeWearInfo.resId = newItemID
      end
    end
    local EAvatarShapeType = import("ECharacterAvatarShapeType")
    local logic_suit_multi_shape = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_suit_multi_shape)
    if logic_suit_multi_shape:CanCurrentSuitChangeHead(wearInfo[1]) then
      logic_suit_multi_shape:SetSuitShapeInfo(memberUid, wearInfo[1], EAvatarShapeType.ECharacterAvatarShapeType_SuitChangeHead, wearInfo[6])
    end
  end
  local memberInfo = TeamUpNewSystem.GetMemberInfo(tonumber(memberUid))
  if not memberInfo then
    return
  end
  if not memberInfo.wear_ext then
    log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.on_team_change_wear memberInfo.wear_ext == nil")
    return
  end
  local hasWear = memberInfo.wear_ext[mAvatarPos]
  if hasWear then
    if isPushOn == 1 then
      local tLastWearData = memberInfo.wear_ext[mAvatarPos]
      local tTempData = {
        uid = memberUid,
        pos = 0,
        resId = tLastWearData[ENUM_AVATAR_DATA_TYPE.ItemID],
        avatarPos = mAvatarPos,
        wearInfo = tLastWearData
      }
      EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CHANGE_WEAR, tTempData)
      TeamUpNewSystem.teamInfo.members[tonumber(memberUid)].wear_ext[mAvatarPos] = wearInfo
    else
      for k, v in pairs(memberInfo.wear_ext) do
        if k == mAvatarPos then
          if TeamUpNewSystem.changeWearInfo and TeamUpNewSystem.changeWearInfo.resId and TeamUpNewSystem.changeWearInfo.resId <= 0 then
            TeamUpNewSystem.changeWearInfo.resId = v[1]
          end
          TeamUpNewSystem.teamInfo.members[tonumber(memberUid)].wear_ext[k] = nil
        end
      end
    end
  elseif isPushOn == 1 then
    TeamUpNewSystem.teamInfo.members[tonumber(memberUid)].wear_ext[mAvatarPos] = wearInfo
  end
  EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CHANGE_WEAR, TeamUpNewSystem.changeWearInfo)
  LogicXSuit.RefreshTeamInfo(TeamUpNewSystem.teamInfo)
  LogicXSuit.SyncXSuitScheme(TeamUpNewSystem.teamInfo, gold_dress_set_info_all)
end
function TeamUpNewSystem.on_change_type_rsp(res)
  log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.on_change_type_rsp faild" .. res)
  if res ~= NetErrorCode_NONE then
    if res == "cant-change-to-8v8" then
      ShowNotice(27577)
    elseif res == "ugc_member_level_limit" then
      ShowNotice(48643)
    elseif res == "ugc_member_dev_limi" then
      ShowNotice(48458)
    end
  end
end
function TeamUpNewSystem.on_change_leader_rsp(res)
  log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.on_change_leader_rsp" .. res)
  if res == "member-offline" then
    ShowNotice(110065)
  end
end
function TeamUpNewSystem.on_team_update_wear(op_uid, wear_res, wear_ext_res, knapsack_ext_info, gold_dress_set_info, gold_dress_set_info_all)
  TeamUpNewSystem.changeWearPair = {
    uid = op_uid,
    ware = wear_res,
    wear_ext = wear_ext_res
  }
  local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
  if wear_res and wear_res[3] then
    local newItemID = wear_res[3]
    if LogicXSuit.IsXSuit(newItemID) then
      local period = LogicXSuit.GetPeriodByItemId(newItemID)
      if period then
        local branch = LogicXSuit.GetBranchByItemId(newItemID) or 0
        if gold_dress_set_info and gold_dress_set_info.set_info and gold_dress_set_info.set_info[period] and gold_dress_set_info.set_info[period][branch] then
          newItemID = LogicXSuit.GetSwitchItemByItemAndSwitchLevel(newItemID, gold_dress_set_info.set_info[period][branch])
        end
        if gold_dress_set_info_all and gold_dress_set_info_all.set_info and gold_dress_set_info_all.set_info[period] and gold_dress_set_info_all.set_info[period][branch] then
          local state = gold_dress_set_info_all.set_info[period][branch].bicolor_state
          if state then
            newItemID = LogicXSuit.ChangeItemIDByState(newItemID, state)
          end
        end
      end
    end
    wear_res[3] = newItemID
    TeamUpNewSystem.changeWearPair.ware[3] = newItemID
  end
  if wear_ext_res and wear_ext_res[3] and wear_ext_res[3][1] then
    if LogicXSuit.IsXSuit(wear_ext_res[3][1]) then
      local newItemID = wear_ext_res[3][1]
      local period = LogicXSuit.GetPeriodByItemId(newItemID)
      if period then
        local branch = LogicXSuit.GetBranchByItemId(newItemID) or 0
        local Source = wear_ext_res[3][ENUM_AVATAR_DATA_TYPE.Source] or 0
        if gold_dress_set_info and gold_dress_set_info.set_info and gold_dress_set_info.set_info[period] and gold_dress_set_info.set_info[period][branch] and Source ~= EWardrobeDataSource.InheritWardrobe then
          newItemID = LogicXSuit.GetSwitchItemByItemAndSwitchLevel(wear_ext_res[3][1], gold_dress_set_info.set_info[period][branch])
        end
        if gold_dress_set_info_all and gold_dress_set_info_all.set_info and gold_dress_set_info_all.set_info[period] and gold_dress_set_info_all.set_info[period][branch] then
          local state = gold_dress_set_info_all.set_info[period][branch].bicolor_state
          if state then
            newItemID = LogicXSuit.ChangeItemIDByState(newItemID, state)
          end
        end
      end
      TeamUpNewSystem.changeWearPair.wear_ext[3][1] = newItemID
    end
    local EAvatarShapeType = import("ECharacterAvatarShapeType")
    local logic_suit_multi_shape = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_suit_multi_shape)
    if logic_suit_multi_shape:CanCurrentSuitChangeHead(wear_ext_res[3][1]) then
      logic_suit_multi_shape:SetSuitShapeInfo(op_uid, wear_ext_res[3][1], EAvatarShapeType.ECharacterAvatarShapeType_SuitChangeHead, wear_ext_res[3][6])
    end
  end
  if knapsack_ext_info then
    local uid = tonumber(op_uid)
    if TeamUpNewSystem.teamInfo and TeamUpNewSystem.teamInfo.members then
      for k, v in pairs(TeamUpNewSystem.teamInfo.members) do
        if tonumber(k) == uid then
          if knapsack_ext_info.weapon_wear_info then
            v.weapon_wear_info.weapon_id = knapsack_ext_info.weapon_wear_info.weapon_id
            v.weapon_wear_info.skin_id = knapsack_ext_info.weapon_wear_info.skin_id
            if knapsack_ext_info.weapon_wear_info.ext_info then
              v.weapon_wear_info.ext_info = knapsack_ext_info.weapon_wear_info.ext_info
            end
          else
            v.weapon_wear_info.weapon_id = 0
            v.weapon_wear_info.skin_id = 0
          end
          TeamUpNewSystem.OnMemberWeaponChange(uid)
          v.vst_info.skin_id = knapsack_ext_info.vst_skin.skin_id
          v.vst_info.vst_type = knapsack_ext_info.vst_skin.vst_type
          v.vst_info.skin_style_list = knapsack_ext_info.vst_skin.skin_style_list
          v.background = knapsack_ext_info.background
          v.bag_pendants = knapsack_ext_info.bag_pendants
          TeamUpNewSystem.headShowChangeInfo.          TeamUpNewSystem.headShowChangeInfo.param = knapsack_ext_info.skin_info
          EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CHANGE_HEADSHOW)
          v.skin_info = knapsack_ext_info.skin_info
          break
        end
      end
    end
  end
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  HallThemeUtils.ProcTeamUpdateWear(op_uid)
  EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CHANGE_WEAR_PAIR)
  LogicXSuit.RefreshTeamInfo(TeamUpNewSystem.teamInfo)
  LogicXSuit.SyncXSuitScheme(TeamUpNewSystem.teamInfo, gold_dress_set_info_all)
end
function TeamUpNewSystem.on_plat_get_teamid_rsp(res, team_id, battle_id)
  local ShareMgr = require("client.logic.share.share_logic")
  log(bWriteLog and "on_plat_get_teamid_rsp " .. team_id .. "  " .. battle_id)
  if res == NetErrorCode_NONE then
    if _G.BP_Platform == BP_ENUM_PLAYFORM_WX then
      ShareMgr.InviteJoinTeamWX(team_id, battle_id)
    elseif _G.BP_Platform == BP_ENUM_PLAYFORM_BGBG then
      ShareMgr.InviteJoinTeamBgBg(team_id)
    end
  elseif res == "team_is_full" then
    ShowNotice(110007)
  elseif res == "already_in_match" then
    ShowNotice(110061)
  elseif res == "already_in_game" then
    ShowNotice(9911106)
  elseif res == "guest_state_banned" then
    ShowNotice(22006)
  elseif res == "not_friend" then
    ShowNotice(29388)
  elseif res == "low_priority_match_banned" or res == "match_isolation_label_banned" then
    MatchSystem.ShowBanTip(MatchSystem.GetTeamUpBanTip())
  else
    TeamUpNewSystem.HandleErrorCode(res)
  end
end
function TeamUpNewSystem.on_room_invite_notify(inviter, room_id, mode, zone_id, compete_type, stage_id, room_type, map_id, mod_id)
  log(bWriteLog and "on_room_invite_notify inviter = " .. inviter)
  log(bWriteLog and "on_room_invite_notify room_id = " .. room_id)
  log(bWriteLog and "on_room_invite_notify mode = " .. tostring(mode))
  log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.on_room_invite_notify, zone_id = " .. tostring(zone_id))
  local XMissionSystem = require("client.slua.logic.TxMission.logic_xmission_main")
  if XMissionSystem.IsInXMission() and room_type ~= "tmode" then
    return
  end
  if mod_id then
    local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
    LogicUGC:BatchGetModInfo({mod_id}, LogicUGC.C_ModListTypes.team_invite_tip, nil, {bForce = true})
  end
  local autoRefuse = TeamUpNewSystem.CheckInviteAutoRefuse(inviter)
  if autoRefuse then
    log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.on_room_invite_notify autoRefuse = true")
    local LogicESportCenter = require("client.slua.logic.esport.logic_esport_center")
    if compete_type and compete_type == LogicESportCenter.E_CompeteType.AllStar then
      local AllStarHandler = require("client.network.Protocol.AllStarHandler")
      AllStarHandler.send_compete_room_invite_reply("refuse", room_id, stage_id, inviter, compete_type)
    else
      TeamUpNewSystem.room_invite_reply("refuse", room_id, inviter, "")
    end
    return
  end
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local logic_friend_blacklist = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_blacklist)
  local isPullBack = logic_friend_blacklist:IsBlacklist(inviter)
  log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.on_room_invite_notify ispulblack:" .. tostring(isPullBack))
  if isPullBack then
    return
  end
  local isAsinaRoom = false
  if room_type and room_type == "asian_games" then
    isAsinaRoom = true
  end
  local isExistIndex = TeamUpNewSystem.CheckSameInvite(inviter, isAsinaRoom and E_InviteTipType.AsiaRoomInvite or E_InviteTipType.RoomInvite)
  local inviteApplyData = {
    type = isAsinaRoom and E_InviteTipType.AsiaRoomInvite or E_InviteTipType.RoomInvite,
    playerId = inviter,
    inviterRoomID = room_id,
    playerName = TeamUpNewSystem.GetMemberName(inviter),
    gameType = TeamUpNewSystem.GetOldGameType(999),
    showCD = C_APPLY_INVITE_SHOW_TIME,
    closeCD = C_APPLY_INVITE_CLOSE_TIME,
    closeTotalTime = C_APPLY_INVITE_CLOSE_TIME,
    mapName = isAsinaRoom and LocUtil.GetLocalizeResStr(29743) or "",
    map_id = map_id,
      }
  if zone_id then
    local logic_multiple_area = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_multiple_area)
    inviteApplyData.zoneName = logic_multiple_area:GetDisplayNameByZoneID(zone_id)
  end
  if compete_type then
    inviteApplyData.competeType = compete_type
  end
  if stage_id then
    inviteApplyData.stageID = stage_id
  end
  if isExistIndex == 0 then
    table.insert(TeamUpNewSystem.inviteApplyQueue, inviteApplyData)
  else
    TeamUpNewSystem.inviteApplyQueue[isExistIndex] = inviteApplyData
  end
  if GameStatus.IsInFightingNotSocialNotMainCityNotHome() then
    return
  end
  TeamUpNewSystem.ShowInviteTip()
  log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.on_room_invite_notify inviteApplyData.gameType = " .. inviteApplyData.gameType)
end
function TeamUpNewSystem.on_team_match_zone_notify(match_zone)
  if not match_zone then
    log(bWriteLog and "TeamUpNewSystem.on_team_match_zone_notify, match_zone is nil")
    return
  end
  log(bWriteLog and "TeamUpNewSystem.on_team_match_zone_notify, match_zone = " .. tostring(match_zone))
  if not TeamUpNewSystem.teamInfo then
    log_error(bWriteLog and "TeamUpNewSystem.on_team_match_zone_notify, teaminfo is nil")
    return
  end
  TeamUpNewSystem.teamInfo.zone_id = match_zone
  if GameStatus.IsInMainCity() and TeamUpNewSystem.GetTeamNum() > 1 then
    ShowNotice(656093)
  end
  local leaderInfo = TeamUpNewSystem.GetMemberInfo(TeamUpNewSystem.teamInfo.leader)
  if not leaderInfo then
    log_error(bWriteLog and "TeamUpNewSystem.on_team_match_zone_notify, leaderInfo is nil")
    return
  end
  leaderInfo.self_zone_id = match_zone
end
function TeamUpNewSystem.RefreshWeapon()
  local selfUID = TeamUpNewSystem.GetSelfUID()
  local teamNum = TeamUpNewSystem.GetTeamNum()
  if 1 < teamNum and TeamUpNewSystem.teamInfo.members then
    local weapon_wear_info = {}
    for k, v in pairs(TeamUpNewSystem.teamInfo.members) do
      local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
      if tonumber(k) ~= selfUID then
        if v.weapon_wear_info then
          weapon_wear_info.weaponId = v.weapon_wear_info.weapon_id
          weapon_wear_info.skinId = v.weapon_wear_info.skin_id
          weapon_wear_info.usingDiyRecommend = v.weapon_wear_info.is_using_recommend
          weapon_wear_info.diyPlanId = v.weapon_wear_info.cur_use_plan
        else
          weapon_wear_info.weaponId = 0
          weapon_wear_info.skinId = 0
          weapon_wear_info.usingDiyRecommend = false
          weapon_wear_info.diyPlanId = 0
        end
        if not weapon_wear_info.weaponId or tonumber(weapon_wear_info.weaponId) == 0 then
          LobbyAvatarManager.UnEquipWeapon(k)
        else
          LobbyAvatarManager.EquipWeapon(k, weapon_wear_info, nil, true)
        end
        local ext_weapon_list = v.weapon_wear_info.ext_info
        if ext_weapon_list and next(ext_weapon_list) then
          for _, extra_weapon in pairs(ext_weapon_list) do
            if not extra_weapon.weapon_id or tonumber(extra_weapon.weapon_id) == 0 then
              LobbyAvatarManager.UnEquipExtraWeapon(k)
            else
              weapon_wear_info.weaponId = extra_weapon.weapon_id
              weapon_wear_info.skinId = extra_weapon.skin_id
              weapon_wear_info.usingDiyRecommend = extra_weapon.is_using_recommend
              weapon_wear_info.diyPlanId = extra_weapon.cur_use_plan
              LobbyAvatarManager.EquipWeapon(k, weapon_wear_info, nil, false)
            end
          end
        end
      end
    end
  end
end
local NeedReCreatPalyer = function(op_uid, newAvatar)
  local result = false
  local _info = TeamUpNewSystem.GetMemberInfo(op_uid)
  if _info ~= nil and _info.avatar.headid ~= newAvatar.headid then
    return true
  end
  return result
end
local NeedChangePalyerSex = function(op_uid, newAvatar)
  local result = false
  local _info = TeamUpNewSystem.GetMemberInfo(op_uid)
  if _info ~= nil and _info.avatar.gamegender ~= newAvatar.gamegender then
    return true
  end
end
local UpdateMemberModel = function(newTeamInfo)
  if newTeamInfo.player_count == 1 then
    return
  end
  local selfUID = TeamUpNewSystem.GetSelfUID()
  local needUpdate = false
  for k, v in pairs(newTeamInfo.members) do
    local _newGid = k
    if k ~= selfUID then
      local info = TeamUpNewSystem.GetMemberInfo(tonumber(k))
      local notSameSex = false
      local notSameHeadid = false
      if info ~= nil then
        notSameSex = NeedReCreatPalyer(_newGid, info.avatar)
        notSameHeadid = NeedReCreatPalyer(_newGid, info.avatar)
      end
      if info == nil or notSameSex == true or notSameHeadid == true then
        needUpdate = true
        break
      end
    end
  end
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  if needUpdate == true then
    local oldTeamInfo = TeamUpNewSystem.teamInfo
    for k1, v1 in pairs(oldTeamInfo.members) do
      local _oldGid = k1
      if k1 ~= selfUID then
        local _sex = 1
        if v1.gender ~= nil then
          _sex = v1.gender
        end
        local wareArray = {}
        if v1.wear_ext ~= nil then
          for wk, wv in pairs(v1.wear_ext) do
            table.insert(wareArray, AvatarData.ConvertToAvatarCustom(wv))
          end
        else
          log(bWriteLog and "UpdateMemberModle v1.wear_ext = nil")
        end
        local playerData = {
          gid = _oldGid,
          sex = _sex,
          BP_ARRAY_AvatarList = wareArray,
          avatar = v1.avatar,
          bagSkinInsId = v1.skin_info.bag_skin,
          headShow = v1.skin_info.head_show
        }
        LobbyAvatarManager.SpawnPlayer(playerData, false, true)
      end
    end
    for k2, v2 in pairs(newTeamInfo.members) do
      local _newGid1 = k2
      if k2 ~= selfUID then
        local _sex = 1
        if v2.gender ~= nil then
          _sex = v2.gender
        end
        local wareArray = {}
        if v2.wear_ext ~= nil then
          for wk1, wv1 in pairs(v2.wear_ext) do
            table.insert(wareArray, AvatarData.ConvertToAvatarCustom(wv1))
          end
        else
          log(bWriteLog and "UpdateMemberModle v2.wear_ext = nil")
        end
        local head_show = 0
        if v2.skin_info ~= nil and (v2.skin_info.head_show == 0 or v2.skin_info.head_show == v2.skin_info.helmet_skin) and v2.wear ~= nil then
          local head = v2.wear[1]
          if head ~= nil then
            log_tree("head", head)
            for i, v in pairs(wareArray) do
              if v.ItemID == head[1] then
                v.ItemID = 0
              end
            end
          end
          head_show = DataMgr.GetEquipmentItemIDByResID(v2.skin_info.helmet_level, v2.skin_info.head_show)
        end
        local playerData = {
          gid = _newGid1,
          sex = _sex,
          BP_ARRAY_AvatarList = wareArray,
          avatar = v2.avatar,
          bagSkinInsId = DataMgr.GetEquipmentItemIDByResID(v2.skin_info.bag_level, v2.skin_info.bag_skin),
          headShow = head_show
        }
        LobbyAvatarManager.SpawnPlayer(playerData, true)
      end
    end
  end
end
function TeamUpNewSystem.CompareMember(newTeamInfo)
  if not newTeamInfo then
    log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.CompareMember newTeamInfo none")
    return
  end
  local oldTeamInfo = TeamUpNewSystem.teamInfo
  if not oldTeamInfo.player_count then
    local selfUID = TeamUpNewSystem.GetSelfUID()
    log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.CompareMember selfUID" .. selfUID)
    TeamUpNewSystem.bIsAddMember = true
    for k, v in pairs(newTeamInfo.members) do
      if not v.wear_ext then
        log(bWriteLog and "TeamUpNewSystem.CompareMemBer v.wear_ext = nil 1")
      end
      if k ~= selfUID then
        local wear_ext = v.wear_ext or {}
        if wear_ext[3] and wear_ext[3][1] then
          local newItemID = wear_ext[3][1]
          local source = wear_ext[3][ENUM_AVATAR_DATA_TYPE.Source]
          local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
          local period = LogicXSuit.GetPeriodByItemId(newItemID)
          if period then
            local branch = LogicXSuit.GetBranchByItemId(newItemID) or 0
            if v.gold_dress_set_info and v.gold_dress_set_info.set_info and v.gold_dress_set_info.set_info[period] and v.gold_dress_set_info.set_info[period][branch] and source ~= EWardrobeDataSource.InheritWardrobe then
              newItemID = LogicXSuit.GetSwitchItemByItemAndSwitchLevel(newItemID, v.gold_dress_set_info.set_info[period][branch])
            end
            if v.gold_dress_set_info_all and v.gold_dress_set_info_all.set_info and v.gold_dress_set_info_all.set_info[period] and v.gold_dress_set_info_all.set_info[period][branch] then
              local state = v.gold_dress_set_info_all.set_info[period][branch].bicolor_state
              if state then
                newItemID = LogicXSuit.ChangeItemIDByState(newItemID, state)
              end
            end
          end
          wear_ext[3][1] = newItemID
        end
        local _newStructData = {
          gid = k,
          name = v.name,
          status = v.status,
          svr = v.svr,
          wear = wear_ext,
          gender = v.gender,
          avatar = v.avatar,
          skin_info = v.skin_info or {},
          bag_pendants = v.bag_pendants or {},
          depot_show_info = v.depot_show_info or {},
          weapon_wear_info = v.weapon_wear_info or {}
        }
        table.insert(TeamUpNewSystem.changeMemberInfo, _newStructData)
      end
    end
    return
  end
  TeamUpNewSystem.changeMemberInfo = {}
  if newTeamInfo.player_count == oldTeamInfo.player_count then
    TeamUpNewSystem.bIsAddMember = false
    UpdateMemberModel(newTeamInfo)
    TeamUpNewSystem.UpdateTeamMemberAvatar(newTeamInfo, true)
    return
  end
  if newTeamInfo.player_count > oldTeamInfo.player_count then
    TeamUpNewSystem.bIsAddMember = true
    for k, v in pairs(newTeamInfo.members) do
      if v.wear_ext == nil then
        log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.CompareMember v.wear_ext = nil 2")
      end
      local _newGid = k
      local _isFind = false
      for i, vv in pairs(oldTeamInfo.members) do
        local _oldGid = i
        if k == _oldGid then
          _isFind = true
          break
        end
      end
      if _isFind == false then
        local _newStructData = {
          gid = _newGid,
          name = v.name,
          status = v.status,
          svr = v.svr,
          wear = v.wear_ext or {},
          gender = v.gender,
          avatar = v.avatar,
          skin_info = v.skin_info or {},
          bag_pendants = v.bag_pendants or {},
          depot_show_info = v.depot_show_info or {},
          weapon_wear_info = v.weapon_wear_info or {}
        }
        table.insert(TeamUpNewSystem.changeMemberInfo, _newStructData)
      end
    end
  elseif newTeamInfo.player_count < oldTeamInfo.player_count then
    TeamUpNewSystem.bIsAddMember = false
    for k, v in pairs(oldTeamInfo.members) do
      if v.wear_ext == nil then
        log(bWriteLog and "TeamUpNewSystem.CompareMemBer v.wear_ext = nil 2")
      end
      local _newGid = k
      local _isFind = false
      for i, _ in pairs(newTeamInfo.members) do
        local _oldGid = i
        if _newGid == _oldGid then
          _isFind = true
          break
        end
      end
      if _isFind == false then
        local _newStructData = {
          gid = _newGid,
          name = v.name,
          status = v.status,
          svr = v.svr,
          wear = v.wear_ext or {},
          gender = v.gender,
          avatar = v.avatar,
          skin_info = v.skin_info or {},
          bag_pendants = v.bag_pendants or {},
          depot_show_info = v.depot_show_info or {}
        }
        table.insert(TeamUpNewSystem.changeMemberInfo, _newStructData)
      end
    end
  end
  TeamUpNewSystem.UpdateTeamMemberAvatar(newTeamInfo, nil, oldTeamInfo)
end
function TeamUpNewSystem.ChangeMember()
  local memberInfo = TeamUpNewSystem.changeMemberInfo
  if #TeamUpNewSystem.changeMemberInfo == 0 then
    return
  end
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  for k, v in pairs(memberInfo) do
    if tonumber(v.gid) ~= TeamUpNewSystem.GetSelfUID() then
      local _sex = 1
      if v.gender then
        _sex = v.gender
      end
      local wearArray = {}
      if Client.IsDevelopment() then
        log_tree("[DIYColor] TeamUpNewSystem.ChangeMember info: ", {
          uid = v.gid,
          wear_ext = v.wear
        })
      end
      if v.wear then
        for _, itemInfo in pairs(v.wear) do
          if itemInfo[1] and itemInfo[5] then
            local logic_suit_dye = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_suit_dye)
            logic_suit_dye:SetPlanData(v.gid, itemInfo[1], itemInfo[5])
          end
        end
        local equipmentIDList = {}
        local itemIDMap = {}
        for kk, vv in pairs(v.wear) do
          if vv[1] then
            table.insert(equipmentIDList, vv[1])
            itemIDMap[vv[1]] = vv
          else
            log_error(bWriteLog and "TeamUpNewSystem.ChangeMember wear vv[1] is nil")
          end
        end
        equipmentIDList = LobbyAvatarManager.SortEquipmentIDList(equipmentIDList)
        for kk, vv in ipairs(equipmentIDList) do
          table.insert(wearArray, AvatarData.ConvertToAvatarCustom(itemIDMap[vv.itemID]))
        end
      end
      if v.bag_pendants then
        for kk, vv in pairs(v.bag_pendants) do
          table.insert(wearArray, AvatarData.CreateAvatarCustom(kk))
        end
      end
      local head_show = 0
      if v.skin_info and (v.skin_info.head_show == 0 or v.skin_info.head_show == v.skin_info.helmet_skin) and v.depot_show_info.helmet ~= false then
        local head = v.wear[1]
        if head then
          for ii, vv in pairs(wearArray) do
            if vv.ItemID == head[1] then
              vv.ItemID = 0
            end
          end
        end
        head_show = DataMgr.GetEquipmentItemIDByResID(v.skin_info.helmet_level, v.skin_info.head_show)
      end
      local playerData = {
        gid = v.gid,
        sex = _sex,
        BP_ARRAY_AvatarList = wearArray,
        avatar = v.avatar,
        bagSkinInsId = DataMgr.GetEquipmentItemIDByResID(v.skin_info.bag_level, v.skin_info.bag_skin),
        headShow = head_show
      }
      local bHasWear
      if not LogicTxMissionMain.IsInXMission() then
        bHasWear = v.wear ~= nil and next(v.wear) ~= nil
      end
      log(bWriteLog and "TeamUpNewSystem.ChangeMember playerData.gid:" .. tostring(playerData.gid) .. "---TeamUpNewSystem.IsAddMember" .. tostring(TeamUpNewSystem.bIsAddMember))
      LobbyAvatarManager.SpawnPlayer(playerData, TeamUpNewSystem.bIsAddMember, nil, bHasWear)
    end
  end
  TeamUpNewSystem.changeMemberInfo = {}
end
local HasPosInNewWare = function(ware, position)
  log(bWriteLog and "HasPosInNewWare" .. position)
  if ware ~= nil then
    for k, v in pairs(ware) do
      if k == position then
        return v
      end
    end
  end
  return nil
end
function TeamUpNewSystem.UpdateTeamMemberAvatar(newTeamInfo, updateAll, oldTeamInfo)
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  local selfUid = TeamUpNewSystem.GetSelfUID()
  for k, v in pairs(newTeamInfo.members) do
    if tonumber(k) ~= selfUid or updateAll then
      if v.wear_ext == nil then
        log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.UpdateTeamMemberAvatar v.wear_ext = nil")
      end
      local _newGid = k
      local _newWare = v.wear_ext or {}
      if Client.IsDevelopment() then
        log_tree("[DIYColor] TeamUpNewSystem.ChangeMember info: ", {
          uid = k,
          wear_ext = v.wear_ext
        })
      end
      for _, itemInfo in pairs(_newWare) do
        if itemInfo[1] and itemInfo[5] then
          local logic_suit_dye = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_suit_dye)
          logic_suit_dye:SetPlanData(k, itemInfo[1], itemInfo[5])
        end
      end
      local logic_weapon_pendant = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_weapon_pendant)
      logic_weapon_pendant:UpdateAllPendantData(k, v.weapon_pendants)
      local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
      if _newWare[3] and _newWare[3][1] then
        local period = LogicXSuit.GetPeriodByItemId(_newWare[3][1])
        if period then
          local newItemID = _newWare[3][1]
          local branch = LogicXSuit.GetBranchByItemId(newItemID) or 0
          local source = _newWare[3][ENUM_AVATAR_DATA_TYPE.Source] or 0
          if v.gold_dress_set_info and v.gold_dress_set_info.set_info and v.gold_dress_set_info.set_info[period] and v.gold_dress_set_info.set_info[period][branch] and source ~= EWardrobeDataSource.InheritWardrobe then
            newItemID = LogicXSuit.GetSwitchItemByItemAndSwitchLevel(newItemID, v.gold_dress_set_info.set_info[period][branch])
          end
          if v.gold_dress_set_info_all and v.gold_dress_set_info_all.set_info and v.gold_dress_set_info_all.set_info[period] and v.gold_dress_set_info_all.set_info[period][branch] then
            local state = v.gold_dress_set_info_all.set_info[period][branch].bicolor_state
            if state then
              newItemID = LogicXSuit.ChangeItemIDByState(newItemID, state)
            end
          end
          _newWare[3][1] = newItemID
        end
        local EAvatarShapeType = import("ECharacterAvatarShapeType")
        local logic_suit_multi_shape = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_suit_multi_shape)
        if logic_suit_multi_shape:CanCurrentSuitChangeHead(_newWare[3][1]) then
          logic_suit_multi_shape:SetSuitShapeInfo(k, _newWare[3][1], EAvatarShapeType.ECharacterAvatarShapeType_SuitChangeHead, _newWare[3][6])
        end
      end
      local oldMemberInfo = TeamUpNewSystem.GetMemberInfo(_newGid)
      if oldMemberInfo ~= nil then
        local _oldWare = oldMemberInfo.wear_ext or {}
        for k1, v1 in pairs(_oldWare) do
          local wearInfo = HasPosInNewWare(_newWare, k1)
          if wearInfo == nil then
            TeamAvatarManager.ChangeAvatarEquipment(_newGid, AvatarData.CreateAvatarCustom(v1[1]), false)
          end
        end
      end
      local head_show = v.skin_info.head_show
      local bag_skin = v.skin_info.bag_skin
      local helmet_skin = v.skin_info.helmet_skin
      local bag_level = v.skin_info.bag_level
      local helmet_level = v.skin_info.helmet_level
      local ShowHelmet = function()
        return (head_show == helmet_skin or head_show == 0) and v.depot_show_info.helmet ~= false
      end
      if ShowHelmet() then
        table.remove(_newWare, 1)
        head_show = DataMgr.GetEquipmentItemIDByResID(helmet_level, head_show)
      else
        head_show = 0
      end
      bag_skin = DataMgr.GetEquipmentItemIDByResID(bag_level, bag_skin)
      local equipments = {}
      for k2, v2 in pairs(_newWare) do
        local tAvatarCustom = AvatarData.CreateAvatarCustom(v2[1], v2[2], v2[3])
        TeamAvatarManager._CreateEquipmentInfo(equipments, v2[1], tAvatarCustom)
      end
      log(bWriteLog and "=====================bag_skin" .. tostring(bag_skin))
      log(bWriteLog and "=====================bag_skin" .. tostring(head_show))
      TeamAvatarManager._CreateEquipmentInfo(equipments, bag_skin)
      TeamAvatarManager._CreateEquipmentInfo(equipments, head_show)
      local equipmentIDList = {}
      for itemID, _ in pairs(equipments) do
        table.insert(equipmentIDList, itemID)
      end
      local oldEquipmentIDMap = {}
      if oldTeamInfo and oldTeamInfo.members and oldTeamInfo.members[k] and not updateAll then
        local oldWear = oldTeamInfo.members[k].wear_ext or {}
        log(bWriteLog and "TeamUpNewSystem.UpdateTeamMemberAvatar old teamate")
        for key, wearInfo in pairs(oldWear) do
          if wearInfo[1] ~= nil then
            oldEquipmentIDMap[wearInfo[1]] = true
          end
        end
      end
      equipmentIDList = LobbyAvatarManager.SortEquipmentIDList(equipmentIDList)
      local WardrobeLogic = require("client.slua.logic.wardrobe.logic_wardrobe_new")
      local bIsFashionBagEditMode = WardrobeLogic:IsInFashionBagEditMode()
      if DataMgr.roleData.uid ~= tostring(_newGid) or not bIsFashionBagEditMode then
        for i, data in ipairs(equipmentIDList) do
          local info = equipments[data.itemID]
          if oldEquipmentIDMap[info.itemID] then
            log(bWriteLog and "TeamUpNewSystem.UpdateTeamMemberAvatar old item has already wear" .. info.itemID)
          else
            TeamAvatarManager.PutonEquipment(tostring(_newGid), info.itemID, info.tAvatarCustom)
          end
        end
      else
        log(bWriteLog and "TeamUpNewSystem.UpdateTeamMemberAvatar. self avatar is in fashion bag edit mode, do no update now")
      end
    end
  end
end
function TeamUpNewSystem.RecoverTargetEquipment(uid)
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  if not TeamAvatarManager.teamInfo or not TeamUpNewSystem.teamInfo.members then
    return
  end
  for k, v in pairs(TeamUpNewSystem.teamInfo.members) do
    if tonumber(k) == tonumber(uid) then
      if v.wear_ext == nil then
        log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.UpdateTeamMemberAvatar v.wear_ext = nil")
      end
      local _newGid = k
      local _newWare = v.wear_ext or {}
      local head_show = v.skin_info.head_show
      local bag_skin = v.skin_info.bag_skin
      local helmet_skin = v.skin_info.helmet_skin
      local bag_level = v.skin_info.bag_level
      local helmet_level = v.skin_info.helmet_level
      if uid == DataMgr.roleData.uid then
        head_show = 0
        local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
        local nUseWearBagIndex = fashionbag_data:GetFashionBagUseIndex()
        local bagInfo = fashionbag_data:GetKnapsackExtInfoByIndex(nUseWearBagIndex)
        if bagInfo ~= nil and bagInfo.head_show == bagInfo.helmet_skin then
          local WardrobeLogic = require("client.slua.logic.wardrobe.logic_wardrobe_new")
          local originalResId = WardrobeLogic:GetItemResId(bagInfo.helmet_skin)
          head_show = DataMgr.GetEquipmentItemIDByResID(bagInfo.helmet_level, originalResId)
        end
        _newWare = AvatarData.GetAllWearInfoEnumFormat()
      end
      local ShowHelmet = function()
        return (head_show == helmet_skin or head_show == 0) and v.depot_show_info.helmet ~= false
      end
      if ShowHelmet() then
        table.remove(_newWare, 1)
        head_show = DataMgr.GetEquipmentItemIDByResID(helmet_level, helmet_skin)
      else
        head_show = 0
      end
      bag_skin = DataMgr.GetEquipmentItemIDByResID(bag_level, bag_skin)
      local equipments = {}
      for k2, v2 in pairs(_newWare) do
        local tAvatarCustom = AvatarData.CreateAvatarCustom(v2[1], v2[2], v2[3])
        TeamAvatarManager._CreateEquipmentInfo(equipments, v2[1], tAvatarCustom)
      end
      log(bWriteLog and "=====================bag_skin" .. tostring(bag_skin))
      log(bWriteLog and "=====================bag_skin" .. tostring(head_show))
      TeamAvatarManager._CreateEquipmentInfo(equipments, bag_skin)
      TeamAvatarManager._CreateEquipmentInfo(equipments, head_show)
      local equipmentIDList = {}
      for itemID, v in pairs(equipments) do
        table.insert(equipmentIDList, itemID)
      end
      local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
      equipmentIDList = LobbyAvatarManager.SortEquipmentIDList(equipmentIDList)
      for i, data in ipairs(equipmentIDList) do
        local info = equipments[data.itemID]
        log(bWriteLog and "TeamUpNewSystem.RecoverTargetEquipment puton id = " .. tostring(info.itemID))
        TeamAvatarManager.PutonEquipment(tostring(_newGid), info.itemID, info.tAvatarCustom)
      end
    end
  end
end
function TeamUpNewSystem.UpdateMemberHeadShowInfo(headShowChangeInfo)
  if TeamUpNewSystem.teamInfo then
    local uid = headShowChangeInfo.uid
    local param = headShowChangeInfo.param
    if param.head_show then
      TeamUpNewSystem.teamInfo.members[tonumber(uid)].skin_info.head_show = param.head_show
    end
    if param.bag_skin then
      TeamUpNewSystem.teamInfo.members[tonumber(uid)].skin_info.bag_skin = param.bag_skin
    end
    if param.helmet_skin then
      TeamUpNewSystem.teamInfo.members[tonumber(uid)].skin_info.helmet_skin = param.helmet_skin
    end
    if param.bag_level then
      TeamUpNewSystem.teamInfo.members[tonumber(uid)].skin_info.bag_level = param.bag_level
    end
    if param.helmet_level then
      TeamUpNewSystem.teamInfo.members[tonumber(uid)].skin_info.helmet_level = param.helmet_level
    end
  end
end
function TeamUpNewSystem.OnMemberWeaponChange(uid)
  log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.OnMemberWeaponChange uid = " .. tostring(uid))
  local memberInfo = TeamUpNewSystem.GetMemberInfo(uid)
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  if memberInfo and memberInfo.weapon_wear_info then
    if not memberInfo.weapon_wear_info.weapon_id or tonumber(memberInfo.weapon_wear_info.weapon_id) == 0 then
      LobbyAvatarManager.UnEquipWeapon(uid)
    else
      local weapon_wear_info = {}
      if memberInfo.weapon_wear_info then
        weapon_wear_info.weaponId = memberInfo.weapon_wear_info.weapon_id
        weapon_wear_info.skinId = memberInfo.weapon_wear_info.skin_id
        weapon_wear_info.usingDiyRecommend = memberInfo.weapon_wear_info.is_using_recommend
        weapon_wear_info.diyPlanId = memberInfo.weapon_wear_info.cur_use_plan
      else
        weapon_wear_info.weaponId = 0
        weapon_wear_info.skinId = 0
        weapon_wear_info.usingDiyRecommend = false
        weapon_wear_info.diyPlanId = ""
      end
      LobbyAvatarManager.EquipWeapon(uid, weapon_wear_info, nil, true)
      local ext_weapon_list = memberInfo.weapon_wear_info.ext_info
      if ext_weapon_list and next(ext_weapon_list) then
        for _, extra_weapon in pairs(ext_weapon_list) do
          if not extra_weapon.weapon_id or tonumber(extra_weapon.weapon_id) == 0 then
            LobbyAvatarManager.UnEquipExtraWeapon(uid)
          else
            weapon_wear_info.weaponId = extra_weapon.weapon_id
            weapon_wear_info.skinId = extra_weapon.skin_id
            weapon_wear_info.usingDiyRecommend = extra_weapon.is_using_recommend
            weapon_wear_info.diyPlanId = extra_weapon.cur_use_plan
            LobbyAvatarManager.EquipWeapon(uid, weapon_wear_info, nil, false)
          end
        end
      end
    end
  end
end
function TeamUpNewSystem.ChangeBagPendant(param)
  local memberInfo = TeamUpNewSystem.GetMemberInfo(param.uid)
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  if memberInfo then
    if not param.bag_pendants or not next(param.bag_pendants) then
      if memberInfo.bag_pendants then
        for k, v in pairs(memberInfo.bag_pendants) do
          TeamAvatarManager.ChangeAvatarEquipment(param.uid, AvatarData.CreateAvatarCustom(k, 0, 0), false)
        end
        memberInfo.bag_pendants = param.bag_pendants
      end
    else
      memberInfo.bag_pendants = param.bag_pendants
      for k, v in pairs(param.bag_pendants) do
        TeamAvatarManager.ChangeAvatarEquipment(param.uid, AvatarData.CreateAvatarCustom(k, 0, 0), true)
      end
    end
  end
end
function TeamUpNewSystem.on_team_change_avatar(op_uid, newAvatar)
  log(bWriteLog and "on_team_change_avatar" .. op_uid)
  local _info = TeamUpNewSystem.GetMemberInfo(op_uid)
  TeamUpNewSystem.changeAvatarInfo = {
    reCreate = NeedReCreatPalyer(op_uid, newAvatar),
    needChangeSex = NeedChangePalyerSex(op_uid, newAvatar),
    uid = op_uid,
    avatar = newAvatar
  }
  if _info then
    if _info.avatar then
      TeamUpNewSystem.changeAvatarInfo.oldAvatar = _info.avatar
    end
    _info.avatar = newAvatar
    _info.gender = newAvatar.gamegender
    local BasicDataAvatarWearInfo = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataAvatarWearInfo)
    BasicDataAvatarWearInfo:UpdateRoleSexByUid(op_uid, newAvatar.gamegender)
    EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CHANGE_AVATAR)
  end
end
function TeamUpNewSystem.sync_player_action(player_uid, action_id, randSoundId, follow_id, extraParam)
  log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.sync_player_action player_uid = " .. tostring(player_uid) .. ", action_id = " .. tostring(action_id) .. ",randSoundId=" .. tostring(randSoundId) .. "follow_id" .. tostring(follow_id))
  local extraInfo = extraParam and extraParam.extraInfo or nil
  local bStopAction = extraParam and extraParam.stopAction or false
  if bStopAction then
    log(bWriteLog and "TeamUpNewSystem.sync_player_action stop action")
    TeamUpNewSystem.StopPlayerAction(player_uid)
    return
  end
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local sex = logic_profile:GetRoleSexByUid(player_uid, true)
  if GlobalData.IsJapanOrKorea() then
    local itemCfg = CDataTable.GetTableData("Item", action_id)
    if itemCfg and itemCfg.JKBPID and itemCfg.JKBPID > 0 then
      action_id = itemCfg.JKBPID
    end
  end
  local playerDisplayModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.CardCollectionPlayerDisplayModule)
  if playerDisplayModule then
    local logic_card_collection = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_card_collection)
    if action_id == playerDisplayModule:GetActionItemID() then
      local actionVersion = extraInfo
      log(bWriteLog and "TeamUpNewSystem.sync_player_action actionVersion=" .. tostring(actionVersion))
      logic_card_collection:SetTeammateSelectActionVersion(player_uid, actionVersion)
    end
  end
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  if TeamUpNewSystem.GetTeamNum() > 1 and TeamUpNewSystem.IsTeamLeader(player_uid) and TeamUpNewSystem.CheckEmoteCanFollow(action_id) then
    local FollowerUIDS = TeamUpNewSystem.GetEmoteFollowersUID()
    for _, uid in pairs(FollowerUIDS) do
      local EmoteID = TeamUpNewSystem.GetFollowPlayEmoteID(uid, action_id)
      LobbyAvatarManager.PlayEmoteAction(uid, EmoteID, logic_profile:GetRoleSexByUid(uid, true), nil, nil, extraInfo)
    end
  end
  local EmoteID = TeamUpNewSystem.GetFollowPlayEmoteID(player_uid, action_id)
  LobbyAvatarManager.PlayEmoteAction(player_uid, EmoteID, sex, randSoundId, nil, extraInfo or follow_id)
end
function TeamUpNewSystem.StopPlayerAction(playerUid)
  log(bWriteLog and "TeamUpNewSystem.StopPlayerAction player_uid = " .. tostring(playerUid))
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  LobbyAvatarManager.StopEmoteAction(playerUid)
  if TeamUpNewSystem.GetTeamNum() > 1 and TeamUpNewSystem.IsTeamLeader(playerUid) then
    local followerUIDS = TeamUpNewSystem.GetEmoteFollowersUID()
    for _, uid in pairs(followerUIDS) do
      LobbyAvatarManager.StopEmoteAction(uid)
    end
  end
end
function TeamUpNewSystem.GetTeamCode()
  local teamCode = ""
  if TeamUpNewSystem.teamInfo and TeamUpNewSystem.teamInfo.code then
    teamCode = TeamUpNewSystem.teamInfo.code
  end
  return teamCode
end
function TeamUpNewSystem.SetTeamCode(code)
  if TeamUpNewSystem.teamInfo then
    TeamUpNewSystem.teamInfo.  end
end
function TeamUpNewSystem.IsInFaceTeam()
  local teamCode = TeamUpNewSystem.GetTeamCode()
  if teamCode and string.len(teamCode) > 0 then
    return true
  end
  return false
end
function TeamUpNewSystem.team_recruit_req(msgContent, mapArr, paramInfo)
  local gameType = paramInfo.gameType
  local list = {}
  list.text = msgContent
  list.game_model_type = gameType
  list.VoiceType = paramInfo.voiceType
  list.msgType = 1
  list.team_recuit_map_data = mapArr
  list.min_segment = paramInfo.min_segment
  list.same_language = paramInfo.same_language
  list.pos = paramInfo.pos
  list.persiontive = paramInfo.persontiveIndex
  list.taskId = paramInfo.taskId
  list.isRp = paramInfo.isRp
  list.send_to_recruit_channel = paramInfo.channel.send_to_recruit_channel
  list.send_to_corps_channel = paramInfo.channel.send_to_corps_channel
  list.send_to_room_channel = paramInfo.channel.send_to_room_channel
  local msgId = TeamUpNewSystem.CacheMsg(list)
  local TeamupHandler = require("client.network.Protocol.TeamupHandler")
  TeamupHandler.send_team_recruit(list, msgId)
end
function TeamUpNewSystem.team_recruit_rsp(ret, time_left, team_id, msg_id, res_channel)
  local tabContent = TeamUpNewSystem.msgContentCacheMap[msg_id]
  TeamUpNewSystem.msgContentCacheMap[msg_id] = nil
  log(bWriteLog and "TeamUpNewSystem.team_recruit_rsp ret: " .. tostring(ret))
  if ret == NetErrorCode_NONE then
    log(bWriteLog and "TeamUpNewSystem.team_recruit_rsp team_id: " .. tostring(team_id))
    log(bWriteLog and "TeamUpNewSystem.team_recruit_rsp msg_id: " .. tostring(msg_id))
    if not TeamUpNewSystem.teamInfo then
      TeamUpNewSystem.teamInfo = {}
    end
    TeamUpNewSystem.teamInfo.id = team_id
    if not tabContent then
      log(bWriteLog and "team_recruit_rsp:no tabContent")
      return
    end
    local voice_file = ""
    local voice_time = 0
    local chat_ctt = tabContent.text
    if true == tabContent.quickMsg then
      chat_ctt = LocUtil.GetLocalizeResStr(tabContent.text)
    end
    if nil ~= tabContent.voice and "" ~= tabContent.voice then
      voice_time = tabContent.voiceLength
      voice_file = tabContent.voice
    end
    local sender_name = DataMgr.roleData.nickName
    local sender_uid = DataMgr.roleData.uid
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local nation = logic_profile:GetPlayerNation(sender_uid)
    local map_data = tabContent.team_recuit_map_data
    local TimeUtil = require("client.common.time_util")
    local paramInfo = {
      taskId = tabContent.taskId,
      isRp = tabContent.isRp,
      create_time = TimeUtil.GetServerTimeInSec()
    }
    if res_channel then
      if res_channel.send_to_corps_channel then
        local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
        logic_chat_main.Team_recruit(8, sender_name, chat_ctt, sender_uid, true, team_id, nation, map_data, paramInfo)
      end
      if res_channel.send_to_recruit_channel then
        local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
        logic_chat_main.Team_recruit(20, sender_name, chat_ctt, sender_uid, true, team_id, nation, map_data, paramInfo)
      end
      if res_channel.send_to_room_channel then
        local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
        logic_chat_main.Team_recruit(5, sender_name, chat_ctt, sender_uid, true, team_id, nation, map_data, paramInfo)
      end
    end
    if tabContent.taskId and 0 < tabContent.taskId then
      if tabContent.send_to_recruit_channel then
        EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_CHECK_OPEN_GOTO_CHAT, 1)
      elseif tabContent.send_to_corps_channel then
        EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_CHECK_OPEN_GOTO_CHAT, 2)
      end
    end
  elseif ret == "request_frequent" then
    local msgContent = string.format(LocUtil.GetLocalizeResStr(100007), time_left)
    ShowNotice(msgContent)
  elseif ret == "chat_level_limit" then
  elseif ret == "low_priority_match_banned" then
  elseif ret == "match_isolation_label_banned" then
    MatchSystem.ShowBanTip(LocUtil.GetLocalizeResStr(29113))
  elseif ret == "guest_state_banned" then
    ShowNotice(22006)
  end
end
function TeamUpNewSystem.InitTeamEmulatorType()
  if TeamUpNewSystem.nCurTeamEmulatorType < 0 then
    log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.InitTeamEmulatorType")
    TeamUpNewSystem.nCurTeamEmulatorType = 0
    local isEmulator = DataMgr.IsEmulator()
    local mySelfEmulator = isEmulator or DataMgr.IsBLE()
    if mySelfEmulator then
      TeamUpNewSystem.nCurTeamEmulatorType = 1
      if isEmulator then
        local EmulatorSystem = require("client.logic.login.logic_emulator")
        local emulatorName = EmulatorSystem.GetEmulatorName()
        local isBlue = EmulatorSystem.is_blue_simulator(emulatorName)
        if not isBlue then
          TeamUpNewSystem.nCurTeamEmulatorType = 2
        end
      end
    end
  end
end
function TeamUpNewSystem.NeedShowEmulatorTips()
  local lastEmulatorType = TeamUpNewSystem.nCurTeamEmulatorType
  local curEmulatorType = 0
  local EmulatorSystem = require("client.logic.login.logic_emulator")
  if GameStatus.IsInLobbyOrMainCity() and TeamUpNewSystem.GetTeamNum() > 1 and TeamUpNewSystem.teamInfo and TeamUpNewSystem.teamInfo.members then
    for key, value in pairs(TeamUpNewSystem.teamInfo.members) do
      if value.device_type and value.device_type ~= 0 then
        curEmulatorType = 1
        local isEmum = EmulatorSystem.IsEmulator(value.emulator_name)
        if isEmum and value.emulator_name then
          local isBlue = EmulatorSystem.is_blue_simulator(tostring(value.emulator_name))
          if not isBlue then
            curEmulatorType = 2
            break
          end
        end
      end
    end
  end
  log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.NeedShowEmulatorTips curEmulatorType : " .. curEmulatorType .. "|| lastEmulatorType : " .. lastEmulatorType)
  if lastEmulatorType ~= curEmulatorType and lastEmulatorType < curEmulatorType then
    return true
  end
  return false
end
function TeamUpNewSystem.SetTeamEmulatorType()
  TeamUpNewSystem.nCurTeamEmulatorType = 0
  local EmulatorSystem = require("client.logic.login.logic_emulator")
  if TeamUpNewSystem.teamInfo and TeamUpNewSystem.teamInfo.members then
    for key, value in pairs(TeamUpNewSystem.teamInfo.members) do
      if value.device_type and value.device_type ~= 0 then
        TeamUpNewSystem.nCurTeamEmulatorType = 1
        log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.SetTeamEmulatorType" .. tostring(TeamUpNewSystem.nCurTeamEmulatorType))
        local isEmu = EmulatorSystem.IsEmulator(value.emulator_name)
        if isEmu then
          local isBlue = EmulatorSystem.is_blue_simulator(tostring(value.emulator_name))
          if isBlue == false then
            TeamUpNewSystem.nCurTeamEmulatorType = 2
            break
          end
        end
      end
    end
  end
end
function TeamUpNewSystem.IsEmulatorTeam()
  if TeamUpNewSystem.teamInfo and TeamUpNewSystem.teamInfo.members then
    for key, value in pairs(TeamUpNewSystem.teamInfo.members) do
      if value.device_type and value.device_type ~= 0 then
        return true
      end
    end
  end
  return false
end
function TeamUpNewSystem.IsMixEmulatorTeam()
  if TeamUpNewSystem.IsEmulatorTeam() and TeamUpNewSystem.teamInfo and TeamUpNewSystem.teamInfo.members then
    for key, value in pairs(TeamUpNewSystem.teamInfo.members) do
      if value.device_type and value.device_type == 0 then
        return true
      end
    end
  end
  return false
end
function TeamUpNewSystem.ProcessEmulatorTips()
  local needShow = TeamUpNewSystem.NeedShowEmulatorTips()
  TeamUpNewSystem.SetTeamEmulatorType()
  if needShow then
    if TeamUpNewSystem.nCurTeamEmulatorType == 2 then
      DataMgr.ShowMessageBoxByID(110424)
    else
      DataMgr.ShowMessageBoxByID(110138)
    end
  else
    log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.ProcessEmulatorTips " .. tostring(TeamUpNewSystem.bIsFightingBackLobby))
    if TeamUpNewSystem.bIsFightingBackLobby and TeamUpNewSystem.GetTeamNum() > 1 and TeamUpNewSystem.IsMixEmulatorTeam() then
      if TeamUpNewSystem.nCurTeamEmulatorType == 2 then
        DataMgr.ShowMessageBoxByID(110424)
      else
        DataMgr.ShowMessageBoxByID(110138)
      end
    end
  end
  TeamUpNewSystem.bIsFightingBackLobby = false
end
function TeamUpNewSystem.one_more_battle_apply_req(battle_id)
  local TeamupHandler = require("client.network.Protocol.TeamupHandler")
  TeamupHandler.send_one_more_battle_apply_req(battle_id)
end
function TeamUpNewSystem.one_more_battle_apply_rsp()
end
function TeamUpNewSystem.one_more_battle_reply_req(opt, team_id, team_leader)
  local team_omb_info = TeamUpNewSystem.GetOneMoreGameInfo()
  if not team_omb_info then
    log_warning("[edward][logic_team_up] self.one_more_battle_reply_req, oneMoreGameTeamInfo is nil")
    return
  end
  local TeamupHandler = require("client.network.Protocol.TeamupHandler")
  TeamupHandler.send_one_more_battle_reply_req(team_id or team_omb_info.team_id, opt, team_leader or team_omb_info.team_leader)
  if opt == 1 then
    if GameStatus.IsInFightingStatus() then
      EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_INVITE_GAME_RSP, DataMgr.roleData.uid, 1)
    end
  elseif opt == 2 then
    TeamUpNewSystem.ReleaseOneMoreGameInfo()
  end
end
function TeamUpNewSystem.one_more_battle_reply_rsp()
  TeamUpNewSystem.ReleaseOneMoreGameInfo()
end
function TeamUpNewSystem.end_one_more_battle_req()
  local team_omb_info = TeamUpNewSystem.GetOneMoreGameInfo()
  if not team_omb_info then
    log_warning("[edward][logic_team_up] TeamUpNewSystem.end_one_more_battle_req, oneMoreGameTeamInfo is nil")
    return
  end
  local TeamupHandler = require("client.network.Protocol.TeamupHandler")
  TeamupHandler.send_end_one_more_battle_req(team_omb_info.team_id)
end
function TeamUpNewSystem.one_more_battle_info_notify(team_id, msg_type, msg)
  msg = msg or {}
  log(bWriteLog and "[byron][logic_team_up] TeamUpNewSystem.one_more_battle_info_notify, team_id = " .. team_id .. ",msg_type:" .. tostring(msg_type))
  if msg_type == 1 then
    if not TeamUpNewSystem.oneMoreGameTeamInfo and msg.team_omb_info then
      TeamUpNewSystem.oneMoreGameTeamInfo = msg.team_omb_info
      if TeamUpNewSystem.oneMoreGameTeamInfo.team_leader == tonumber(DataMgr.roleData.uid) then
        if not GameStatus.IsInLobbyOrMainCity() then
          EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_INVITE_GAME_LEADER)
        end
      else
        EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_INVITE_GAME, TeamUpNewSystem.oneMoreGameTeamInfo.team_leader)
      end
    end
  elseif msg_type == 5 then
    local team_omb_info = TeamUpNewSystem.GetOneMoreGameInfo()
    if not team_omb_info then
      log_warning("[edward][logic_team_up] TeamUpNewSystem.one_more_battle_info_notify, oneMoreGameTeamInfo is nil")
      return
    end
    if team_omb_info.team_leader == tonumber(DataMgr.roleData.uid) then
      ShowNotice(9897)
    else
      ShowNotice(9186)
    end
    TeamUpNewSystem.ReleaseOneMoreGameInfo()
  else
    TeamUpNewSystem.oneMoreGameTeamInfo = msg.team_omb_info
    if msg_type == 2 then
      local member_status = TeamUpNewSystem.oneMoreGameTeamInfo.member_status
      if member_status[msg.uid] then
        local data = member_status[msg.uid]
        if msg.opt == 2 and TeamUpNewSystem.oneMoreGameTeamInfo.team_leader == tonumber(DataMgr.roleData.uid) and data.status == 2 then
          local tip = LocUtil.LocalizeResFormat(8004, member_status[msg.uid].name)
          ShowNotice(tip)
        elseif msg.opt == 1 then
          local tip1 = LocUtil.LocalizeResFormat(8431, member_status[msg.uid].name)
          ShowNotice(tip1)
        end
      end
      EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_INVITE_GAME_RSP, DataMgr.roleData.uid, 2)
    else
    end
  end
end
function TeamUpNewSystem.ShowOneMoreGameInviteUI()
  log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.ShowOneMoreGameInviteUI")
  local teamNum = 4
  local endTime = 0
  local inviteName = ""
  local isLeader = false
  local team_omb_info
  if TeamUpNewSystem.oneMoreGameTeamInfo then
    team_omb_info = TeamUpNewSystem.oneMoreGameTeamInfo
  elseif TeamUpNewSystem.teamInfo then
    team_omb_info = TeamUpNewSystem.teamInfo.team_omb_info
  end
  if team_omb_info then
    if team_omb_info.team_leader == tonumber(DataMgr.roleData.uid) then
      isLeader = true
    end
    local TableUtil = require("common.table_util")
    teamNum = TableUtil.CountTable(team_omb_info.member_status)
    endTime = team_omb_info.team_unlock_time
    local leadInfo = team_omb_info.member_status[team_omb_info.team_leader]
    if leadInfo then
      inviteName = leadInfo.name
    end
  end
  log(bWriteLog and "[edward][logic_team_up] TeamUpNewSystem.ShowOneMoreGameInviteUI endTime:" .. tostring(endTime) .. ",teamNum:" .. tostring(teamNum) .. ",isLeader:" .. tostring(isLeader))
  local TimeUtil = require("client.common.time_util")
  if 0 < endTime and endTime > TimeUtil.GetServerTimeInSec() then
    UIManager.ShowUI(UIManager.UI_Config.one_more_team_tip, isLeader, teamNum, inviteName, endTime)
  else
    TeamUpNewSystem.ReleaseOneMoreGameInfo()
  end
end
function TeamUpNewSystem.ShowUpvoteTips(uid, name)
  if GameStatus.GetGameStatus() == GameStatus.Lobby then
    local showTip = LocUtil.LocalizeResFormat(4830, name)
    ShowNotice(showTip)
  end
end
function TeamUpNewSystem.GetShowCarList()
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local carList = {}
  if TeamUpNewSystem.teamInfo and TeamUpNewSystem.teamInfo.members then
    for uid, value in pairs(TeamUpNewSystem.teamInfo.members) do
      local avatar = TeamAvatarManager.GetAvatarByUid(uid)
      if avatar and avatar.positionIndex and TeamUpNewSystem.InShowGroup(avatar.positionIndex) and value and value.vst_info.skin_id and value.vst_info.skin_id > 0 then
        local tab = {
          id = uid,
          vst_info = value.vst_info,
          name = value.name
        }
        table.insert(carList, tab)
      end
    end
  end
  return carList
end
function TeamUpNewSystem.ShowVehicleAvatar()
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  HallThemeUtils.ShowThemeVehicle()
end
function TeamUpNewSystem.PlaySportsCarVideo(tMemberData)
  log(bWriteLog and "TeamUpNewSystem.PlayVehicleVideo")
  if IsWoWEditor then
    return false
  end
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission() then
    return false
  end
  local tVST_info = tMemberData.vst_info
  if not tVST_info or not tVST_info.skin_id then
    return false
  end
  local tEffectData = CDataTable.GetTableData("SportsCarTeamBroadcastConfig", tVST_info.skin_id)
  if not tEffectData then
    return false
  else
    log(bWriteLog and string.format("TeamUpNewSystem.PlayVehicleVideo, tVST_info.skin_id:%s", tVST_info.skin_id))
  end
  local time_ticker = require("common.time_ticker")
  time_ticker.AddTimerOnce(0.5, function()
    if not GameStatus.IsInLobbyOrMainCity() then
      log(bWriteLog and "TeamUpNewSystem.PlaySportsCarVideo, IsInLobbyOrMainCity return false")
      return
    end
    local LobbyMainUI = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
    if not LobbyMainUI or not LobbyMainUI:IsShow() then
      log(bWriteLog and "TeamUpNewSystem Mainui Not Show")
      return
    end
    local gm_kill_broadcast = RequireBlackList("blacklist.slua.logic.gm.gm_kill_broadcast")
    if tEffectData.IsLoadChildUIEffect == 1 or gm_kill_broadcast and gm_kill_broadcast.GetGMTestSportsCarFlag() then
      UIManager.UI_Config.TeamUp_Member_SportsCar_UIBP.path = "/Game/UMG/UI_BP/TeamUp/TeamUp_Member_SportsCarMain_UIBP.TeamUp_Member_SportsCarMain_UIBP"
    else
      UIManager.UI_Config.TeamUp_Member_SportsCar_UIBP.path = "/Game/UMG/UI_BP/TeamUp/TeamUp_Member_SportsCar_UIBP.TeamUp_Member_SportsCar_UIBP"
    end
    UIManager.ShowUI(UIManager.UI_Config.TeamUp_Member_SportsCar_UIBP, tEffectData, tMemberData.uid)
  end)
  return true
end
function TeamUpNewSystem.PlayVehicleVideo(tMemberData)
  log(bWriteLog and "TeamUpNewSystem.GetVehiclesVideoInfo")
  local bPlaySportsCarVideo = TeamUpNewSystem.PlaySportsCarVideo(tMemberData)
  local bPlayWingmanVideo = TeamUpNewSystem.PlayWingmanVideo(tMemberData, bPlaySportsCarVideo)
  return bPlaySportsCarVideo or bPlayWingmanVideo
end
function TeamUpNewSystem.PlayWingmanVideo(tMemberData, bPlaySportsCarVideo)
  log(bWriteLog and "TeamUpNewSystem.PlayVehicleVideo")
  if IsWoWEditor then
    return false
  end
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission() then
    return false
  end
  local skin_info = tMemberData.skin_info
  if not skin_info or not skin_info.wingman_skin then
    log(bWriteLog and "TeamUpNewSystem.PlayVehicleVideo wingman_skin invalid")
    return false
  end
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  if not HallThemeUtils.CanShowWingmanTeamVideo(skin_info.wingman_skin) then
    log(bWriteLog and "TeamUpNewSystem.PlayVehicleVideo CanShowWingmanTeamVideo false")
    return false
  end
  local curStatus = GameStatus.GetGameStatus()
  if curStatus ~= GameStatus.Lobby then
    return false
  end
  local LobbyMainUI = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  if not LobbyMainUI or not LobbyMainUI:IsShow() then
    log(bWriteLog and "TeamUpNewSystem Mainui Not Show")
    return false
  end
  UIManager.ShowUI(UIManager.UI_Config.TeamUp_Member_Wingman_UIBP, skin_info.wingman_skin, tMemberData.uid, bPlaySportsCarVideo and 4 or 0.5)
  return true
end
function TeamUpNewSystem.set_receive_nonfriend_team_request(nEnable)
  local TeamupHandler = require("client.network.Protocol.TeamupHandler")
  TeamupHandler.send_set_receive_nonfriend_team_request(nEnable)
end
function TeamUpNewSystem.get_switch_status()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.MentorTeamSwitch) or {}
  if cfg and cfg.open == false then
    return false
  end
  return true
end
function TeamUpNewSystem.SetShowUIType(uiType)
  TeamUpNewSystem.ShowUiType = uiType
end
function TeamUpNewSystem.ShowUI(uiType)
  if IsWoWEditor then
    return
  end
  if UIManager.GetUI(UIManager.UI_Config.TeamPlatform_Tab) then
    EventSystem:postEvent(EVENTTYPE_MENTOR, EVENTID_TEAMPLAT_MAIN, uiType)
  else
    log(bWriteLog and "[v_wllwu] TeamUpNewSystem.ShowUI, SetCanNeedRefreshFilter uiType = " .. tostring(uiType))
    if uiType == TeamUpNewSystem.E_UI_TYPE.TeamPlatformMain or uiType == TeamUpNewSystem.E_UI_TYPE.WoWTeamPlatformMain or uiType == TeamUpNewSystem.E_UI_TYPE.PeakTeamPlatformMain then
      local logic_team_platform_new = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_team_platform_new)
      logic_team_platform_new:SetCanNeedRefreshFilter(true)
    end
    UIManager.ShowUI(UIManager.UI_Config.TeamPlatform_Tab, uiType)
  end
end
function TeamUpNewSystem.CheckUI(uiType)
  return TeamUpNewSystem.ShowUiType == uiType
end
function TeamUpNewSystem.on_notify_teamup_sex_show(bShow)
  log(bWriteLog and "[TeamUpNewSystem] on_notify_teamup_sex_show: " .. tostring(bShow))
  TeamUpNewSystem.bShowTeamupSex = bShow
end
function TeamUpNewSystem.ShouldShowSex()
  return TeamUpNewSystem.bShowTeamupSex
end
function TeamUpNewSystem.IsFollowLeaderEmote(uid)
  if not TeamUpNewSystem.teamInfo or not TeamUpNewSystem.teamInfo.members then
    log(bWriteLog and "TeamUpNewSystem.IsFollowLeaderEmote not TeamUpNewSystem.teamInfo")
    return false
  end
  local Info = TeamUpNewSystem.teamInfo.members[uid]
  if not Info then
    return false
  end
  return Info.is_follow_leader
end
function TeamUpNewSystem.GetEmoteFollowersUID()
  if not LobbySystem.CheckOpen(BP_ENUM_DANCE_FOLLOW_SWITCH) then
    return {}
  end
  if not TeamUpNewSystem.teamInfo or not TeamUpNewSystem.teamInfo.members then
    log(bWriteLog and "TeamUpNewSystem.GetEmoteFollowersUID not TeamUpNewSystem.teamInfo")
    return {}
  end
  local FolloersUID = {}
  for uid, _ in pairs(TeamUpNewSystem.teamInfo.members) do
    if not TeamUpNewSystem.IsTeamLeader(uid) and TeamUpNewSystem.IsFollowLeaderEmote(uid) then
      table.insert(FolloersUID, uid)
    end
  end
  return FolloersUID
end
function TeamUpNewSystem.UpdateEmoteFollowerState(uid, is_follow_leader)
  log(bWriteLog and "TeamUpNewSystem UpdateEmoteFollowerState uid:" .. tostring(uid) .. " is_follow_leader:" .. tostring(is_follow_leader))
  if not TeamUpNewSystem.teamInfo or not TeamUpNewSystem.teamInfo.members then
    log(bWriteLog and "TeamUpNewSystem.UpdateEmoteFollowerState not TeamUpNewSystem.teamInfo")
    return
  end
  local Info = TeamUpNewSystem.teamInfo.members[uid]
  if not Info then
    log(bWriteLog and "TeamUpNewSystem.UpdateEmoteFollowerState not Info" .. tostring(uid))
    return
  end
  Info.end
function TeamUpNewSystem.UpdateEmoteShowEffect(uid, isOpen)
  log(bWriteLog and "TeamUpNewSystem UpdateEmoteShowEffect uid:" .. tostring(uid) .. " isOpen:" .. tostring(isOpen))
  if not TeamUpNewSystem.teamInfo or not TeamUpNewSystem.teamInfo.members then
    log(bWriteLog and "TeamUpNewSystem.UpdateEmoteShowEffect not TeamUpNewSystem.teamInfo")
    return
  end
  local Info = TeamUpNewSystem.teamInfo.members[uid]
  if not Info or not Info.motion_effect_info then
    log(bWriteLog and "TeamUpNewSystem.UpdateEmoteShowEffect not Info" .. tostring(uid))
    return
  end
  Info.motion_effect_info.show_effect = isOpen
end
function TeamUpNewSystem.UpdateEmoteLevel(uid, EmoteID, Level)
  log(bWriteLog and "TeamUpNewSystem UpdateEmoteLevel uid:" .. tostring(uid) .. " EmoteID:" .. tostring(EmoteID) .. "Level" .. tostring(Level))
  if not TeamUpNewSystem.teamInfo or not TeamUpNewSystem.teamInfo.members then
    log(bWriteLog and "TeamUpNewSystem.UpdateEmoteLevel not TeamUpNewSystem.teamInfo")
    return
  end
  local Info = TeamUpNewSystem.teamInfo.members[uid]
  if not Info or not Info.motion_effect_info then
    log(bWriteLog and "TeamUpNewSystem.UpdateEmoteLevel not Info" .. tostring(uid))
    return
  end
  if not Info.motion_effect_info.motion_effect_level then
    Info.motion_effect_info.motion_effect_level = {}
  end
  Info.motion_effect_info.motion_effect_level[EmoteID] = Level
end
function TeamUpNewSystem.GetFollowPlayEmoteID(UID, EmoteID)
  log(bWriteLog and "TeamUpNewSystem.GetFollowPlayEmoteID UID " .. tostring(UID) .. " EmoteID " .. tostring(EmoteID))
  local LogicParticleEmote = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicParticleEmote)
  local EmoteID = LogicParticleEmote:GetBaseID(EmoteID)
  if not LogicParticleEmote:IsParticleEmote(EmoteID) then
    return EmoteID
  end
  local Info = TeamUpNewSystem.GetMemberInfo(UID)
  if not Info or not Info.motion_effect_info then
    return EmoteID
  end
  local motion_effect_info = Info.motion_effect_info
  if not motion_effect_info.motion_effect_level or not motion_effect_info.motion_effect_level[EmoteID] then
    return EmoteID
  end
  if motion_effect_info.show_effect == true and motion_effect_info.motion_effect_level[EmoteID] > 0 then
    local ParticleEmoteID = LogicParticleEmote:GetParticleEmoteID(EmoteID)
    log(bWriteLog and "TeamUpNewSystem.GetFollowPlayEmoteID ParticleEmoteID" .. tostring(ParticleEmoteID))
    return ParticleEmoteID
  end
  return EmoteID
end
function TeamUpNewSystem.CheckEmoteCanFollow(EmoteId)
  local LobbyFollowEmoteCfg = CDataTable.GetTableData("LobbyFollowEmoteCfg", EmoteId)
  if LobbyFollowEmoteCfg and LobbyFollowEmoteCfg.CanPlay == 0 then
    return false
  end
  local logic_emote = require("GameLua.Mod.Library.GamePlay.Avatar.Emote.logic_emote")
  if logic_emote.IsMileStoneEmote(EmoteId) then
    return false
  end
  if logic_emote.IsCustomWeaponShow(EmoteId) then
    return false
  end
  return true
end
function TeamUpNewSystem.GetMemberPetInfo(uid)
  local member = TeamUpNewSystem.GetMemberInfo(uid)
  return member and member.pet_info or {}
end
function TeamUpNewSystem.UpdateMemberPetInfo(uid, pet_info)
  local member = TeamUpNewSystem.GetMemberInfo(uid)
  if not member then
    return
  end
  member.end
function TeamUpNewSystem.GetGarageCarInfo(uid)
  if not uid then
    log(bWriteLog and "TeamUpNewSystem.GetGarageCarInfo not uid " .. tostring(uid))
    return nil
  end
  if not TeamUpNewSystem.teamInfo or not TeamUpNewSystem.teamInfo.members then
    log(bWriteLog and "TeamUpNewSystem.GetGarageCarInfo not teamInfo")
    return nil
  end
  local MemberInfo = TeamUpNewSystem.teamInfo.members[tonumber(uid)]
  if not MemberInfo then
    log(bWriteLog and "TeamUpNewSystem.GetGarageCarInfo not MemberInfo")
    return nil
  end
  return MemberInfo.car_page_info
end
function TeamUpNewSystem.GetGarageRefitList(uid, Position)
  local CarInfo = TeamUpNewSystem.GetGarageCarInfo(uid)
  if not CarInfo or not CarInfo[Position] then
    return
  end
  local RefitList = CarInfo[Position].ext_data and CarInfo[Position].ext_data.car_data
  return RefitList
end
function TeamUpNewSystem.GetGarageVehicleShowTireConfig(uid, Position)
  local CarInfo = TeamUpNewSystem.GetGarageCarInfo(uid)
  if not CarInfo or not CarInfo[Position] then
    return
  end
  local show_tire_feature = CarInfo[Position].ext_data and CarInfo[Position].ext_data.show_tire_feature
  return show_tire_feature
end
function TeamUpNewSystem.GetTeamShowTireConfig(uid)
  if not TeamUpNewSystem.teamInfo then
    return false
  end
  for k, v in pairs(TeamUpNewSystem.teamInfo.members) do
    if tonumber(k) == tonumber(uid) and v and v.vst_info then
      return v.vst_info.show_tire_feature
    end
  end
  return false
end
function TeamUpNewSystem.GetTeamShowVehicleAccessoryList(uid)
  if not uid then
    log(bWriteLog and "TeamUpNewSystem.GetTeamShowVehicleAccessoryList param is nil")
    return nil
  end
  if not TeamUpNewSystem.teamInfo then
    log(bWriteLog and "TeamUpNewSystem.GetTeamShowVehicleAccessoryList teamInfo is nil")
    return nil
  end
  for k, v in pairs(TeamUpNewSystem.teamInfo.members) do
    if tonumber(k) == tonumber(uid) then
      if v and v.vst_info and v.vst_info.car_install_acc then
        log(bWriteLog and "TeamUpNewSystem.GetTeamShowVehicleAccessoryList get")
        return v.vst_info.car_install_acc
      end
      break
    end
  end
  log(bWriteLog and "TeamUpNewSystem.GetTeamShowVehicleAccessoryList nil")
  return nil
end
function TeamUpNewSystem.GetGarageVehicleAccessoryList(uid, Position)
  if not Position or not uid then
    log(bWriteLog and "TeamUpNewSystem.GetGarageVehicleAccessoryList param is nil")
    return nil
  end
  local CarInfo = TeamUpNewSystem.GetGarageCarInfo(uid)
  if not CarInfo or not CarInfo[Position] then
    log(bWriteLog and "TeamUpNewSystem.GetGarageVehicleAccessoryList CarInfo is nil")
    return nil
  end
  local car_install_acc = CarInfo[Position].ext_data and CarInfo[Position].ext_data.car_install_acc
  if not car_install_acc then
    log(bWriteLog and "TeamUpNewSystem.GetGarageVehicleAccessoryList car_install_acc is nil")
    return nil
  end
  log(bWriteLog and "TeamUpNewSystem.GetGarageVehicleAccessoryList Position:" .. tostring(Position) .. " uid:" .. tostring(uid))
  return car_install_acc
end
function TeamUpNewSystem.GetTeamShowVehicleChassisLight(uid)
  if not uid then
    log(bWriteLog and "TeamUpNewSystem.GetTeamShowVehicleChassisLight param is nil")
    return nil
  end
  if not TeamUpNewSystem.teamInfo then
    log(bWriteLog and "TeamUpNewSystem.GetTeamShowVehicleChassisLight teamInfo is nil")
    return nil
  end
  for k, v in pairs(TeamUpNewSystem.teamInfo.members) do
    if tonumber(k) == tonumber(uid) then
      if v and v.vst_info and v.vst_info.chassis_light then
        log(bWriteLog and "TeamUpNewSystem.GetTeamShowVehicleChassisLight get")
        return v.vst_info.chassis_light
      end
      break
    end
  end
  log(bWriteLog and "TeamUpNewSystem.GetTeamShowVehicleChassisLight nil")
  return nil
end
function TeamUpNewSystem.GetGarageVehicleChassisLight(uid, Position)
  if not Position or not uid then
    log(bWriteLog and "TeamUpNewSystem.GetGarageVehicleChassisLight param is nil")
    return nil
  end
  local CarInfo = TeamUpNewSystem.GetGarageCarInfo(uid)
  if not CarInfo or not CarInfo[Position] then
    log(bWriteLog and "TeamUpNewSystem.GetGarageVehicleChassisLight CarInfo is nil")
    return nil
  end
  local chassis_light = CarInfo[Position].ext_data and CarInfo[Position].ext_data.chassis_light
  if not chassis_light then
    log(bWriteLog and "TeamUpNewSystem.GetGarageVehicleChassisLight chassis_light is nil")
    return nil
  end
  log(bWriteLog and "TeamUpNewSystem.GetGarageVehicleChassisLight Position:" .. tostring(Position) .. " uid:" .. tostring(uid) .. " chassis_light:" .. tostring(chassis_light))
  return chassis_light
end
function TeamUpNewSystem.UpdateGarageCarInfo(uid, car_page_info)
  TeamUpNewSystem.teamInfo = TeamUpNewSystem.teamInfo or {}
  TeamUpNewSystem.teamInfo.members = TeamUpNewSystem.teamInfo.members or {}
  TeamUpNewSystem.teamInfo.members[uid] = TeamUpNewSystem.teamInfo.members[uid] or {}
  TeamUpNewSystem.teamInfo.members[uid].end
function TeamUpNewSystem.GetMileStoneData(uid)
  local member = TeamUpNewSystem.GetMemberInfo(uid)
  if not member then
    return
  end
  return member.set_milestone_data
end
function TeamUpNewSystem.SetTempMatchTeamData(uidList)
  local logic_card_collection = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_card_collection)
  logic_card_collection:PreInitCardListData(uidList)
end
function TeamUpNewSystem.GetGarageVehicleMultiSlotData(uid, vehicleId, position)
  local parts = {}
  if not (position and uid) or not vehicleId then
    log(bWriteLog and "TeamUpNewSystem.GetGarageVehicleMultiSlotData param is nil")
    return parts
  end
  local CarInfo = TeamUpNewSystem.GetGarageCarInfo(uid)
  if not CarInfo or not CarInfo[position] then
    log(bWriteLog and "TeamUpNewSystem.GetGarageVehicleMultiSlotData CarInfo is nil")
    return parts
  end
  local extData = CarInfo[position].ext_data
  if not extData then
    log(bWriteLog and "TeamUpNewSystem.GetGarageVehicleChassisLight extData is nil")
    return parts
  end
  local EVehiclePartSlot = import("EVehiclePartSlot")
  local brakeCaliper = extData.brake_caliper
  if brakeCaliper then
    parts[EVehiclePartSlot.BrakeCaliper] = brakeCaliper
  end
  local wheelHub = extData.wheel_hub
  if wheelHub then
    parts[EVehiclePartSlot.WheelHub] = wheelHub
  end
  local canopy = extData.sunroof
  if canopy then
    parts[EVehiclePartSlot.Canopy] = canopy
  end
  local cfg = CDataTable.GetTableData("SportCarDefaultSet", vehicleId)
  if cfg and cfg.SetIDList and cfg.SetIDList ~= "" then
    local StringUtil = require("common.string_util")
    local defaultItems = StringUtil.Split(cfg.SetIDList, "|")
    for i, itemIdStr in ipairs(defaultItems) do
      local slot = i
      local itemId = tonumber(itemIdStr)
      if itemId and 0 < itemId and not parts[slot] then
        parts[slot] = itemId
      end
    end
  end
  return parts
end
function TeamUpNewSystem.GetTeamShowVehicleMultiSlotData(uid, vehicleId)
  local parts = {}
  if not uid or not vehicleId then
    log(bWriteLog and "TeamUpNewSystem.GetTeamShowVehicleMultiSlotData uid is nil")
    return parts
  end
  if not TeamUpNewSystem.teamInfo then
    log(bWriteLog and "TeamUpNewSystem.GetTeamShowVehicleMultiSlotData teamInfo is nil")
    return parts
  end
  local vst_info
  for k, v in pairs(TeamUpNewSystem.teamInfo.members) do
    if tonumber(k) == tonumber(uid) then
      if v and v.vst_info then
        vst_info = v.vst_info
      end
      break
    end
  end
  if not vst_info then
    log(bWriteLog and "TeamUpNewSystem.GetTeamShowVehicleMultiSlotData vst_info is nil")
    return parts
  end
  local EVehiclePartSlot = import("EVehiclePartSlot")
  local brakeCaliper = vst_info.brake_caliper
  if brakeCaliper then
    parts[EVehiclePartSlot.BrakeCaliper] = brakeCaliper
  end
  local wheelHub = vst_info.wheel_hub
  if wheelHub then
    parts[EVehiclePartSlot.WheelHub] = wheelHub
  end
  local canopy = vst_info.sunroof
  if canopy then
    parts[EVehiclePartSlot.Canopy] = canopy
  end
  local cfg = CDataTable.GetTableData("SportCarDefaultSet", vehicleId)
  if cfg and cfg.SetIDList and cfg.SetIDList ~= "" then
    local StringUtil = require("common.string_util")
    local defaultItems = StringUtil.Split(cfg.SetIDList, "|")
    for i, itemIdStr in ipairs(defaultItems) do
      local slot = i
      local itemId = tonumber(itemIdStr)
      if itemId and 0 < itemId and not parts[slot] then
        parts[slot] = itemId
      end
    end
  end
  return parts
end
return TeamUpNewSystem