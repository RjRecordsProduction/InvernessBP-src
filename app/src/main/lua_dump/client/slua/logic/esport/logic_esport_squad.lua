local ESportSquadSystem = {
  jumpFrom = nil,
  bSignNoJumpTip = false,
  bJumpToRecruit = false
}
local myTeamData
local myTeamProfileList = {}
local OffMsgInfo = {}
local CurrentOffmsg
local nProfileLastUpdateTime = 0
local hasSentInviteReqList = {}
local applyList
local hasSentJoinReqList = {}
local C_ProfileUpdateInterval = 120
local JumpFromType = {
  EGameEntry = BP_ENUM_MODULE_EGAME_ENTRY,
  AllStarMain = BP_ENUM_MODULE_ESPORT_AllSTAR
}
ESportSquadSystem.
function ESportSquadSystem.OpenTeamUI()
  local teamData = ESportSquadSystem.GetTeamData()
  if teamData then
    UIManager.ShowUI(UIManager.UI_Config.esport_team_bookmark)
  else
    UIManager.ShowUI(UIManager.UI_Config.esport_team_create)
  end
end
function ESportSquadSystem.OpenTeamMainPanel()
  UIManager.ShowUI(UIManager.UI_Config.esport_team_bookmark)
end
function ESportSquadSystem.CloseTeamMainPanel()
  UIManager.CloseUI(UIManager.UI_Config.esport_team_bookmark)
end
function ESportSquadSystem.GetTeamData()
  return myTeamData
end
function ESportSquadSystem.GetMembers()
  if myTeamData then
    return myTeamData.members
  end
  return {}
end
function ESportSquadSystem.GetMemberNum()
  if myTeamData then
    local TableUtil = require("common.table_util")
    return TableUtil.CountTable(myTeamData.members)
  end
  return 0
end
function ESportSquadSystem.GetMemberInfo(uid)
  if not uid or not myTeamData then
    return nil
  end
  uid = tonumber(uid)
  return myTeamData.members[uid]
end
function ESportSquadSystem.IsTeamLeader(uid)
  if not uid or not myTeamData then
    return false
  end
  uid = tonumber(uid)
  return uid == myTeamData.leader.uid
end
function ESportSquadSystem.GetTeamID()
  if myTeamData then
    return myTeamData.team_id
  end
  return 0
end
function ESportSquadSystem.GetAllStarAreaID()
  if myTeamData then
    return myTeamData.area_id
  end
  return 0
end
function ESportSquadSystem.GetTeamFillState()
  if myTeamData and myTeamData.fill then
    return myTeamData.fill
  end
  return false
end
function ESportSquadSystem.GetMyTeamPlayerProfile(uid)
  if not uid then
    return
  end
  uid = tonumber(uid)
  for _, v in pairs(myTeamProfileList) do
    if v.uid == uid then
      return v
    end
  end
  return nil
end
function ESportSquadSystem.GetMyTeamProfileList()
  return myTeamProfileList
end
function ESportSquadSystem.GetTeamProfileListWithoutSelf()
  local profileList = {}
  for _, v in pairs(myTeamProfileList) do
    if v.uid ~= tonumber(DataMgr.roleData.uid) and v.uid ~= 0 then
      table.insert(profileList, v)
      if v.timeSinceGameBeginStamp ~= nil then
        local TimeUtil = require("client.common.time_util")
        v.timeSinceGameBegin = TimeUtil.OSTime() - v.timeSinceGameBeginStamp
      end
    end
  end
  return profileList
end
function ESportSquadSystem.ConstructSelfData()
  local UnknowPassUtil = require("client.slua.logic.unknow_pass.logic_unknowpass_util")
  local data = {}
  data.uid = tonumber(DataMgr.roleData.uid)
  data.nickName = DataMgr.roleData.nickName
  data.level = DataMgr.roleData.level
  local rank = CDataTable.GetTableData("MilitaryRankLevel", data.level)
  if rank then
    data.militaryRank = rank.MilitaryRankName
  else
    data.militaryRank = 0
  end
  data.picUrl = DataMgr.roleData.headIconUrl
  data.vipLevel = 0
  data.platName = ""
  data.sex = DataMgr.roleData.gender
  data.lastOnlineTime = 0
  data.lastOnlineTimeStr = ""
  data.lastLoginTime = 0
  data.exp = DataMgr.roleData.roleExp
  DataMgr.fillMaxSegmentInfo()
  data.segment_info_solo = DataMgr.maxSegmentSolo.SegmentLevel
  data.segment_info_duo = DataMgr.maxSegmentDuo.SegmentLevel
  data.segment_info_squad = DataMgr.maxSegmentSquad.SegmentLevel
  data.cur_avatar_box_id = DataMgr.roleData.cur_avatar_box_id
  data.AllSegment_Info = DataMgr.roleData.allzoneSegment
  data.upass_is_buy, data.upass_is_show, data.upass_keep, data.upass_cur_value = UnknowPassUtil.ParseUpassInfo(DataMgr.roleData.upass)
  data.aliasId = DataMgr.roleData.alias.id
  data.aliasTitle = DataMgr.roleData.alias.title
  data.aliasNation = DataMgr.roleData.alias.nation
  return data
end
function ESportSquadSystem.ConstructOtherData(profile)
  local TimeUtil = require("client.common.time_util")
  local UnknowPassUtil = require("client.slua.logic.unknow_pass.logic_unknowpass_util")
  local data = {}
  data.uid = tonumber(profile.uid)
  data.nickName = profile.nickName
  data.level = profile.level
  local rank = CDataTable.GetTableData("MilitaryRankLevel", profile.level)
  if rank then
    data.militaryRank = rank.MilitaryRankName
  else
    data.militaryRank = 0
  end
  data.picUrl = profile.picUrl
  data.vipLevel = profile.vipLevel
  data.ladder = profile.ladder
  data.platName = profile.platName
  data.sex = profile.sex
  data.lastOnlineTime = profile.lastOnlineTime
  data.lastOnlineTimeStr = TimeUtil.GetLastOnlineTimeStr(profile.lastOnlineTime)
  data.lastLoginTime = profile.lastLoginTime
  data.exp = profile.exp
  data.segment_info_solo, data.segment_info_duo, data.segment_info_squad = FuncUtil.GetMaxSegement(profile.segment_info)
  data.cur_avatar_box_id = profile.cur_avatar_box_id
  data.upass_is_buy, data.upass_is_show, data.upass_keep, data.upass_cur_value = UnknowPassUtil.ParseUpassInfo(profile.upass)
  data.aliasId = profile.alias.id
  data.aliasTitle = profile.alias.title
  data.aliasNation = profile.alias.nation
  return data
end
function ESportSquadSystem.ConstructFriendData(uid)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(uid)
  local UnknowPassUtil = require("client.slua.logic.unknow_pass.logic_unknowpass_util")
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  local status = PlayerStatusMgr:GetStatusData(uid)
  if profile and status then
    local data = {}
    data.    data.gid = tostring(uid)
    data.nickName = profile.nickName
    data.level = profile.level
    local rank = CDataTable.GetTableData("MilitaryRankLevel", profile.level)
    if rank ~= nil then
      data.militaryRank = rank.MilitaryRankName
    end
    data.friendType = 0
    data.roleNation = profile.nation
    data.picUrl = profile.picUrl
    data.vipLevel = 0
    data.platName = ""
    data.sex = profile.sex
    data.lastOnlineTime = profile.lastOnlineTime
    data.lastOnlineTimeStr = ""
    data.lastLoginTime = profile.lastLoginTime
    data.exp = profile.exp
    data.segment_info_solo, data.segment_info_duo, data.segment_info_squad = FuncUtil.GetMaxSegement(profile.segment_info)
    data.cur_avatar_box_id = profile.cur_avatar_box_id
    data.AllSegment_Info = profile.segment_info
    data.upass_is_buy, data.upass_is_show, data.upass_keep, data.upass_cur_value = UnknowPassUtil.ParseUpassInfo(profile.upass)
    data.aliasId = profile.alias.id
    data.aliasTitle = profile.alias.title
    data.aliasNation = profile.alias.nation
    data.online = status.online
    data.teamState = status.teamState
    data.currentTeamAmount = status.currentTeamAmount
    data.maxTeamAmount = status.maxTeamAmount
    data.is_low_corps = profile.is_low_corps
    data.new_group_buy_visible_packages = profile.new_group_buy_visible_packages
    return data
  end
  return nil
end
function ESportSquadSystem.HasSentInviteReq(uid)
  for _, v in pairs(hasSentInviteReqList) do
    if v == uid then
      return true
    end
  end
  return false
end
function ESportSquadSystem.GetApplyList()
  return applyList
end
function ESportSquadSystem.TeamProfileSortFunc(a, b)
  local selfUID = tonumber(DataMgr.roleData.uid)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  if a.uid == selfUID then
    return true
  end
  if b.uid == selfUID then
    return false
  end
  if a.online == nil or b.online == nil then
    return false
  end
  if a.online == b.online then
    if a.teamState == nil or b.teamState == nil then
      return false
    end
    local PlayerStatusUtil = require("client.slua.logic.player_status.PlayerStatusUtil")
    local teamStateA = a.teamState
    local teamStateB = b.teamState
    if PlayerStatusUtil.IsFree(a) then
      teamStateA = -1
    end
    if PlayerStatusUtil.IsFree(b) then
      teamStateB = -1
    end
    if teamStateA == teamStateB then
      if a.level == nil or b.level == nil then
        return false
      end
      if a.level == b.level then
        return a.lastOnlineTime > b.lastOnlineTime
      else
        return a.level > b.level
      end
    else
      return teamStateA < teamStateB
    end
  else
    return a.online > b.online
  end
end
function ESportSquadSystem.HasSentJoinReq(team_id)
  for _, v in pairs(hasSentJoinReqList) do
    if v == team_id then
      return true
    end
  end
  return false
end
function ESportSquadSystem.IsAppyCardTeam(applied_members)
  local data = applied_members or {}
  if not data or not next(data) then
    return false
  end
  local uid = tonumber(DataMgr.roleData.uid)
  for _, v in pairs(data) do
    if v == uid then
      return true
    end
  end
  return false
end
local ClearData = function()
  myTeamData = nil
  myTeamProfileList = {}
  OffMsgInfo = {}
  CurrentOffmsg = nil
  nProfileLastUpdateTime = 0
  hasSentInviteReqList = {}
  applyList = nil
  hasSentJoinReqList = {}
  local esport_reddot_data = require("client.slua.logic.esport.esport_reddot_data")
  esport_reddot_data.UpdateApplyCount(0)
end
function ESportSquadSystem.OnModePostSwitch(preState, nextState)
  if nextState == GameStatus.Login then
    ClearData()
  end
end
local ProtocolErroCode = function(reason, param)
  if reason == "already-in-carteam" then
    ShowNotice(117001)
  elseif reason == "not-in-carteam" then
    ShowNotice(117002)
  elseif reason == "carteam-exists" then
    ShowNotice(117003)
  elseif reason == "db-error" then
    ShowNotice(117004)
  elseif reason == "insert-offmsg-failed" then
    ShowNotice(117005)
  elseif reason == "invite-already" then
    ShowNotice(117006)
  elseif reason == "have-member-in-carteam" then
    ShowNotice(117007)
  elseif reason == "carteam-not-exists" then
    ShowNotice(117008)
  elseif reason == "not-carteam-leader" then
    ShowNotice(117009)
  elseif reason == "not-invited" then
    ShowNotice(117010)
  elseif reason == "level-not-enough" then
    local rankConfig = CDataTable.GetTableData("MilitaryRankLevel", param)
    local name = rankConfig and rankConfig.MilitaryRankName or ""
    local tip = LocUtil.LocalizeResFormat(117011, tostring(param), name)
    ShowNotice(tip)
  elseif reason == "carteam-is-full" then
    ShowNotice(117012)
  elseif reason == "create-too-much-today" then
    ShowNotice(117013)
  elseif reason == "name-is-empty" then
    ShowNotice(117039)
  elseif reason == "name-too-short" then
    ShowNotice(117039)
  elseif reason == "name-too-long" then
    ShowNotice(117041)
  elseif reason == "have-dirty-in-name" then
    ShowNotice(117042)
  elseif reason == "announcement-too-long" then
    ShowNotice(117043)
  elseif reason == "have-dirty-in-announcement" then
    ShowNotice(117044)
  elseif reason == "already-join" then
    ShowNotice(117059)
  elseif reason == "daily-req-join-limited" then
    local tip = LocUtil.LocalizeResFormat(117058, tostring(param))
    ShowNotice(tip)
  elseif reason == "time-out" then
    ShowNotice(117060)
  elseif reason == "joined-other-carteam" then
    ShowNotice(117061)
  elseif reason == "already-accept" then
    ShowNotice(117064)
  elseif reason == "client-apply-send-ok" then
    ShowNotice(117057)
  elseif reason == "client_send_ok" then
    if ESportSquadSystem.IsTeamLeader(DataMgr.roleData.uid) then
      ShowNotice(117014)
    else
      ShowNotice(7038)
    end
  elseif reason == "cline_JoinCarTeam" then
    local title = LocUtil.GetLocalizeResStr(101001)
    local tip = LocUtil.LocalizeResFormat(117015, tostring(param))
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(1, title, tip, function()
      ESportSquadSystem.jumpFrom = ESportSquadSystem.JumpFromType.EGameEntry
      GlobalData.JumpUrl("game://?module=" .. BP_ENUM_MODULE_ALLIANCE_MAIN_PANEL)
    end)
  elseif reason == "low_priority_match_banned" then
    local MatchSystem = require("client.slua.logic.match.logic_match")
    MatchSystem.ShowBanTip(MatchSystem.GetTeamUpBanTip())
  elseif reason == "match_isolation_label_banned" then
    local MatchSystem = require("client.slua.logic.match.logic_match")
    MatchSystem.ShowBanTip(LocUtil.GetLocalizeResStr(29113))
  elseif reason == "player-is-guest" then
    ShowNotice(12645)
  elseif reason == "already-in-other-carteam" then
    ShowNotice(12657)
  elseif reason == "carteam-state-dismatch" then
    ShowNotice(33815)
  elseif reason == "no_carteam" then
    ShowNotice(33827)
  else
    ShowNotice(reason)
  end
end
local GetOffmsgInfoByIndex = function(index)
  local locIndex = tonumber(index)
  for _, v in pairs(OffMsgInfo) do
    if locIndex == v.index then
      return v
    end
  end
  return nil
end
local RemoveOffMsgInfoByIndex = function(index)
  local msgInfo = GetOffmsgInfoByIndex(index)
  if msgInfo ~= nil then
    for k, v in pairs(OffMsgInfo) do
      if v.index == tonumber(index) then
        table.remove(OffMsgInfo, k)
      end
    end
  end
end
local OnClickOkCallBack = function()
  local teamid = CurrentOffmsg.msg.team_id
  local fromuid = CurrentOffmsg.msg.from_uid
  local offmsgid = CurrentOffmsg.index
  ESportSquadSystem.SendAcceptJoinReq(teamid, fromuid, offmsgid, true)
  RemoveOffMsgInfoByIndex(offmsgid)
  CurrentOffmsg = {}
end
local OnClickCancelCallBack = function()
  local teamid = CurrentOffmsg.msg.team_id
  local fromuid = CurrentOffmsg.msg.from_uid
  local offmsgid = CurrentOffmsg.index
  ESportSquadSystem.SendAcceptJoinReq(teamid, fromuid, offmsgid, false)
  RemoveOffMsgInfoByIndex(offmsgid)
  CurrentOffmsg = {}
end
local GetPopNickNameBack = function(profile_list)
  local friendName = DataMgr.GetMsgByID(117032)
  if #profile_list ~= 0 then
    friendName = profile_list[1].nickName
  end
  local tipstr = DataMgr.GetMsgByID(117033)
  local contentStr = string.format(tipstr, friendName, CurrentOffmsg.msg and CurrentOffmsg.msg.team_name or "")
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, DataMgr.GetMsgByID(117034), contentStr, OnClickOkCallBack, OnClickCancelCallBack, DataMgr.GetMsgByID(117035), DataMgr.GetMsgByID(117036))
end
local PopQueueMsgInfoTips = function()
  local find = false
  for _, v in pairs(OffMsgInfo) do
    CurrentOffmsg = v
    find = true
    break
  end
  if find == true then
    if CurrentOffmsg.msg.op == 1 then
      local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
      logic_profile_get_wrap.GetNormalProfiles({
        CurrentOffmsg.msg.from_uid
      }, GetPopNickNameBack, Enum_PROFILE_REPORT_CFG.ALLIANCE_QUEUE)
    elseif CurrentOffmsg.msg.op == 2 then
      ProtocolErroCode("cline_JoinCarTeam", CurrentOffmsg.msg.team_name)
      ESportSquadSystem.SendAllOffMsgReq(1)
    end
  end
end
local ConstructTeamStateData = function(data)
  data.friendType = 0
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  data.roleNation = logic_profile:GetPlayerNation(data.uid)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  data.isMyFriend = LogicFriend.IsMyFriend(data.uid)
  data.socialland_type = 0
  data.tplan_type = 0
  data.cwow_type = 0
  local memberInfo = ESportSquadSystem.GetMemberInfo(data.uid)
  if memberInfo then
    data.online = memberInfo.online_state
    data.teamState = memberInfo.team_state
    data.currentTeamAmount = memberInfo.team_amount or 1
    data.maxTeamAmount = memberInfo.team_max
    data.openId = memberInfo.openid
    if memberInfo.online_info then
      data.socialland_type = memberInfo.online_info.socialland_type
      data.game_id = memberInfo.online_info.game_id
      data.land_id = memberInfo.online_info.land_id
      data.tplan_type = memberInfo.online_info.tplan_type
      data.cwow_type = memberInfo.online_info.cwow_type
      if memberInfo.online_info.timeSinceGameBegin then
        data.timeSinceGameBegin = memberInfo.online_info.timeSinceGameBegin
        local TimeUtil = require("client.common.time_util")
        data.timeSinceGameBeginStamp = TimeUtil.GetServerTimeInSec() - data.timeSinceGameBegin
      end
    end
  end
end
local AddTeamMember = function(uid, member)
  if not uid or not myTeamData then
    return
  end
  uid = tonumber(uid)
  myTeamData.members[uid] = member
  local members = ESportSquadSystem.GetMembers()
  local uidList = {}
  for k, _ in pairs(members) do
    table.insert(uidList, k)
  end
  ESportSquadSystem.SquadProfileReq(uidList, Enum_PROFILE_REPORT_CFG.ALLIANCE_REQ)
end
local UpdateTeamLeader = function(uid)
  log(bWriteLog and "ESportSquadSystem.UpdateTeamLeader" .. tostring(uid))
  for _, v in pairs(myTeamProfileList) do
    if v.uid == uid then
      myTeamData.leader.name = v.nickName
      myTeamData.leader.      log(bWriteLog and "Update Leader success!!!!")
      if uid == tonumber(DataMgr.roleData.uid) then
        ShowNotice(301281)
        break
      end
      do
        local esport_reddot_data = require("client.slua.logic.esport.esport_reddot_data")
        esport_reddot_data.SendRemoveApplyTlog()
        esport_reddot_data.UpdateApplyCount(0)
      end
      break
    end
  end
end
local KickoutTeamMember = function(uid)
  if not uid or not myTeamData then
    return
  end
  uid = tonumber(uid)
  for k, _ in pairs(myTeamData.members) do
    if k == uid then
      myTeamData.members[k] = nil
      log(bWriteLog and "KickoutTeamMember success!!!!")
      break
    end
  end
  for i, v in pairs(myTeamProfileList) do
    if v.uid == uid then
      table.remove(myTeamProfileList, i)
      break
    end
  end
end
local UpdateTeamMember = function(uid, member)
  if not uid or not myTeamData then
    return
  end
  uid = tonumber(uid)
  for k, _ in pairs(myTeamData.members) do
    if k == uid then
      myTeamData.members[k] = member
      log(bWriteLog and "UpdateTeamMember success!!!!")
      break
    end
  end
  local memberProfile = ESportSquadSystem.GetMyTeamPlayerProfile(uid)
  if memberProfile then
    memberProfile.online = member.online_state
    memberProfile.teamState = member.team_state
    memberProfile.currentTeamAmount = member.team_amount
    memberProfile.maxTeamAmount = member.team_max
    if member.online_info ~= nil and member.online_info.timeSinceGameBegin ~= nil then
      memberProfile.timeSinceGameBegin = member.online_info.timeSinceGameBegin
      local TimeUtil = require("client.common.time_util")
      memberProfile.timeSinceGameBeginStamp = TimeUtil.GetServerTimeInSec() - memberProfile.timeSinceGameBegin
    end
    if member.online_info then
      memberProfile.socialland_type = member.online_info.socialland_type
      memberProfile.game_id = member.online_info.game_id
      memberProfile.land_id = member.online_info.land_id
      memberProfile.tplan_type = member.online_info.tplan_type
      memberProfile.cwow_type = member.online_info.cwow_type
    end
    table.sort(myTeamProfileList, ESportSquadSystem.TeamProfileSortFunc)
  end
end
local ConstructMyTeamData = function(carteam)
  DataMgr.roleData.carteamId = carteam.team_id
  myTeamData = carteam
  local LogicEsportSquadOther = require("client.slua.logic.esport.logic_esport_squad_other")
  LogicEsportSquadOther.SetTeamData(carteam)
  local members = ESportSquadSystem.GetMembers()
  local uidList = {}
  for k, _ in pairs(members) do
    table.insert(uidList, k)
  end
  ESportSquadSystem.SquadProfileReq(uidList, Enum_PROFILE_REPORT_CFG.ALLIANCE_REQ)
end
local AddHasSentInviteReqItem = function(uid)
  for _, v in pairs(hasSentInviteReqList) do
    if v == uid then
      return
    end
  end
  table.insert(hasSentInviteReqList, uid)
end
local AddHasSentJoinReqItem = function(team_id)
  for _, v in pairs(hasSentJoinReqList) do
    if v == team_id then
      return
    end
  end
  table.insert(hasSentJoinReqList, team_id)
end
local CanHaveTeam = function()
  local openLvStr = DataMgr.GetSystemConfig("MinCarTeamLevel")
  local openLv = openLvStr == nil and 0 or tonumber(openLvStr)
  if openLv > DataMgr.roleData.level then
    ProtocolErroCode("level-not-enough", openLv)
    return false
  end
  return true
end
function ESportSquadSystem.SendQueryCarteamReq()
  local ESportAllStarSystem = require("client.slua.logic.esport.logic_esport_allstar")
  if not ESportAllStarSystem.IsCarTeamOpen() then
    return
  end
  local AllianceHandler = require("client.network.Protocol.AllianceHandler")
  AllianceHandler.send_query_carteam_req()
end
function ESportSquadSystem.SendGetApplyListReq()
  local AllianceHandler = require("client.network.Protocol.AllianceHandler")
  AllianceHandler.send_get_carteam_apply_list_req()
end
function ESportSquadSystem.SendCreateTeamReq(name, icon, announcement, is_fill)
  log(bWriteLog and "ESportSquadSystem.SendCreateTeamReq")
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  local AllianceHandler = require("client.network.Protocol.AllianceHandler")
  AllianceHandler.send_create_carteam_req(name, icon, announcement, is_fill)
end
function ESportSquadSystem.SendChangeTeamInfo(changeType, value)
  if not ESportSquadSystem.IsTeamLeader(DataMgr.roleData.uid) then
    ShowNotice(301280)
    return
  end
  log(bWriteLog and "change_carteam_req" .. tostring(changeType) .. tostring(value))
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  local AllianceHandler = require("client.network.Protocol.AllianceHandler")
  AllianceHandler.send_change_carteam_req(changeType, value)
end
function ESportSquadSystem.SendInviteCarTeamReq(inviteID)
  log(bWriteLog and "ESportSquadSystem.SendInviteCarTeamReq")
  local UIUtil = require("client.common.ui_util")
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.InviteJoinCarTeam) then
    return
  end
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  local AllianceHandler = require("client.network.Protocol.AllianceHandler")
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(inviteID)
  log_tree("SendInviteCarTeamReq profile:", profile)
  if profile and profile.allstar_zone_id then
    AllianceHandler.send_invite_join_carteam_req(tonumber(inviteID), profile.allstar_zone_id)
  else
    AllianceHandler.send_invite_join_carteam_req(tonumber(inviteID))
  end
end
function ESportSquadSystem.SendAcceptJoinReq(team_id, from_uid, offmsg_id, is_accept)
  log(bWriteLog and "SendAcceptJoinReq team_id:" .. tostring(team_id) .. "from_uid:" .. tostring(from_uid) .. "offmsg_id:" .. tostring(offmsg_id) .. "is_accept:" .. tostring(is_accept))
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  local AllianceHandler = require("client.network.Protocol.AllianceHandler")
  AllianceHandler.send_accept_join_carteam_req(tonumber(team_id), tonumber(from_uid), tonumber(offmsg_id), is_accept)
end
function ESportSquadSystem.SendApproveReq(uid, isPass)
  log(bWriteLog and "SendApproveReq" .. tostring(uid))
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  local AllianceHandler = require("client.network.Protocol.AllianceHandler")
  AllianceHandler.send_approve_join_carteam_req(tonumber(uid), isPass)
end
function ESportSquadSystem.SendAllOffMsgReq(type)
  local ESportAllStarSystem = require("client.slua.logic.esport.logic_esport_allstar")
  if not ESportAllStarSystem.IsCarTeamOpen() then
    return
  end
  log(bWriteLog and "SendAllOffMsgReq" .. type)
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  ChatHandler.send_get_all_offmsg_req(type)
end
function ESportSquadSystem.SendAppointmentReq(uid)
  log(bWriteLog and "transfer_carteam_leader_req" .. tostring(uid))
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  local AllianceHandler = require("client.network.Protocol.AllianceHandler")
  AllianceHandler.send_transfer_carteam_leader_req(tonumber(uid))
end
function ESportSquadSystem.SendExitTeamReq(reason)
  log(bWriteLog and "ESportSquadSystem.SendExitTeamReq")
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  local AllianceHandler = require("client.network.Protocol.AllianceHandler")
  AllianceHandler.send_exit_carteam_req(reason)
end
function ESportSquadSystem.KickoutTeamReq(uid)
  log(bWriteLog and "KickoutTeamReq" .. tostring(uid))
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  local AllianceHandler = require("client.network.Protocol.AllianceHandler")
  AllianceHandler.send_kickout_carteam_req(tonumber(uid))
end
function ESportSquadSystem.SendPreCreateTeamCheck()
  log(bWriteLog and "pre_create_carteam_req")
  if not CanHaveTeam() then
    return
  end
  local AllianceHandler = require("client.network.Protocol.AllianceHandler")
  AllianceHandler.send_pre_create_carteam_req()
end
function ESportSquadSystem.FastJoinTeamReq()
  if not CanHaveTeam() then
    return
  end
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  local ESportAllStarSystem = require("client.slua.logic.esport.logic_esport_allstar")
  local area_id = ESportAllStarSystem.GetFastJoinAreaID()
  local AllianceHandler = require("client.network.Protocol.AllianceHandler")
  if 0 < area_id then
    AllianceHandler.send_carteam_fill_req(area_id)
  else
    ShowNotice(505056)
    log(bWriteLog and "[YY]send_carteam_fill_req===area_id=" .. tostring(area_id))
  end
end
function ESportSquadSystem.JoinTeamReq(carteam_id)
  if not CanHaveTeam() then
    return
  end
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  local AllianceHandler = require("client.network.Protocol.AllianceHandler")
  AllianceHandler.send_join_carteam_req(carteam_id)
end
function ESportSquadSystem.ImmJoinTeamReq(carteam_id)
  if not CanHaveTeam() then
    return
  end
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  local AllianceHandler = require("client.network.Protocol.AllianceHandler")
  AllianceHandler.send_imm_join_carteam_req(carteam_id)
end
function ESportSquadSystem.SendTeamSuggestionListReq()
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local friendIDList = LogicFriend.GetAllFriendList()
  local carteam_id_list = {}
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  for _, v in pairs(friendIDList) do
    local profile = logic_profile:GetLocalProfile(v)
    if profile and profile.carteam_id and profile.carteam_id > 0 then
      table.insert(carteam_id_list, profile.carteam_id)
    end
  end
  local AllianceHandler = require("client.network.Protocol.AllianceHandler")
  AllianceHandler.send_carteam_suggestion_list_req(carteam_id_list)
end
function ESportSquadSystem.SendTeamSearchListReq(teamName)
  if teamName == "" or not teamName then
    ShowNotice(16169)
    return
  end
  local AllianceHandler = require("client.network.Protocol.AllianceHandler")
  AllianceHandler.send_find_carteam_by_name_req(teamName)
end
function ESportSquadSystem.SendSetTeamFlagReq(id)
  log(bWriteLog and "ESportSquadSystem.SendSetTeamFlagReq id " .. id)
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  local AllianceHandler = require("client.network.Protocol.AllianceHandler")
  AllianceHandler.send_set_car_team_flag_req(id)
end
function ESportSquadSystem.SendSetTeamNationFlagReq(id)
  log(bWriteLog and "ESportSquadSystem.SendSetTeamNationFlagReq id " .. id)
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckSocialRestrict() then
    return
  end
  local AllianceHandler = require("client.network.Protocol.AllianceHandler")
  AllianceHandler.send_set_car_team_nation_flag_req(id)
end
function ESportSquadSystem.SquadProfileReq(uidList, systemType)
  if systemType == Enum_PROFILE_REPORT_CFG.ALLIANCE_REQ then
    local needRefresh = false
    local TimeUtil = require("client.common.time_util")
    local now = TimeUtil.GetServerTimeInSec()
    local timeDiff = now - nProfileLastUpdateTime
    if timeDiff > C_ProfileUpdateInterval then
      nProfileLastUpdateTime = now
      needRefresh = true
    end
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles(uidList, ESportSquadSystem.OnSquadProfileListRsp, systemType, 0, needRefresh)
  elseif systemType == Enum_PROFILE_REPORT_CFG.ALLIANCE_SUGGESTION_LIST then
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles(uidList, ESportSquadSystem.OnSuggestionProfileListRsp, systemType, 0, false)
  end
end
function ESportSquadSystem.OnQueryCarTeamRsp(ok, reason, carteam)
  local ESportAllStarSystem = require("client.slua.logic.esport.logic_esport_allstar")
  if not ESportAllStarSystem.IsCarTeamOpen() then
    return
  end
  log_tree("ESportSquadSystem.OnQueryCarTeamRsp", carteam)
  if not ok then
    ProtocolErroCode(reason)
    return
  end
  if carteam then
    ConstructMyTeamData(carteam)
    if ESportSquadSystem.IsTeamLeader(DataMgr.roleData.uid) then
      ESportSquadSystem.SendGetApplyListReq()
    end
  end
  EventSystem:postEvent(EVENTTYPE_ALLSTAR, EVENTID_ALLSTAR_QUERY_TEAM_RES)
end
function ESportSquadSystem.OnGetCarteamApplylistRsp(ok, reason, member_list, invited_source_list)
  log_tree("ESportSquadSystem.OnGetCarteamApplylistRsp ===member_list=====", member_list)
  log(bWriteLog and "OnGetCarteamApplylistRsp==" .. #member_list)
  if not ok then
    ProtocolErroCode(reason)
    return
  end
  applyList = member_list
  local esport_reddot_data = require("client.slua.logic.esport.esport_reddot_data")
  if #member_list == 0 then
    esport_reddot_data.SendRemoveApplyTlog()
  end
  esport_reddot_data.UpdateApplyCount(#member_list)
  EventSystem:postEvent(EVENTTYPE_ALLSTAR, EVENTID_ALLSTAR_TEAM_APPLYLIST_RES)
end
function ESportSquadSystem.OnCreateCarTeamRsp(ok, reason, carteam)
  log_tree("ESportSquadSystem.OnCreateCarTeamRsp carteam ", carteam)
  if not ok then
    ProtocolErroCode(reason, carteam)
    return
  end
  ConstructMyTeamData(carteam)
  EventSystem:postEvent(EVENTTYPE_ALLSTAR, EVENTID_ALLSTAR_ENTER_TEAM_SUCCESS)
end
function ESportSquadSystem.OnChangeCarteamRsp(ok, reason, changeType, unlock_time)
  local TimeUtil = require("client.common.time_util")
  log(bWriteLog and "ESportSquadSystem.OnChangeCarteamRsp:" .. tostring(reason) .. ",changeType:" .. tostring(changeType))
  if not ok then
    if reason == "is_banned" then
      if changeType == 1 then
        local startTimeStr = TimeUtil.FormatTime_YMD(unlock_time)
        ShowNotice(LocUtil.LocalizeResFormat(22204, startTimeStr))
      elseif changeType == 3 then
        local startTimeStr = TimeUtil.FormatTime_YMD(unlock_time)
        ShowNotice(LocUtil.LocalizeResFormat(22205, startTimeStr))
      end
    else
      ProtocolErroCode(reason)
    end
  end
end
function ESportSquadSystem.OnInviteJoinCarteamRsp(ok, reason, to_uid)
  log(bWriteLog and "OnInviteJoinCarteamRsp ok:" .. tostring(ok) .. "reason:" .. tostring(reason) .. "uid:" .. tostring(to_uid))
  if not ok then
    ProtocolErroCode(reason)
    return
  end
  ProtocolErroCode("client_send_ok")
  AddHasSentInviteReqItem(to_uid)
  EventSystem:postEvent(EVENTTYPE_ALLSTAR, EVENTID_ALLSTAR_TEAM_INVITE_RSP)
end
function ESportSquadSystem.OnAcceptJoinCarteamRsp(ok, reason, carteam_id, offmsg_id, carteam)
  local logStr = string.format("OnAcceptJoinCarteamRsp: ok:%s,reason:%s,carteam_id:%s, offmsg_id:%s", tostring(ok), tostring(reason), tostring(carteam_id), tostring(offmsg_id))
  log(bWriteLog and logStr)
  if not ok then
    ProtocolErroCode(reason, carteam_id)
    PopQueueMsgInfoTips()
    return
  end
  if carteam then
    ProtocolErroCode("cline_JoinCarTeam", carteam.name)
    OffMsgInfo = {}
    ESportSquadSystem.SendAllOffMsgReq(1)
    ConstructMyTeamData(carteam)
    EventSystem:postEvent(EVENTTYPE_ALLSTAR, EVENTID_ALLSTAR_ENTER_TEAM_SUCCESS)
  end
  PopQueueMsgInfoTips()
end
function ESportSquadSystem.OnImmJoinCarteamRsp(ok, reason, carteam_id, carteam)
  log(bWriteLog and "[YY]OnImmJoinCarteamRsp===carteam_id=" .. tostring(carteam_id))
  if not ok then
    ProtocolErroCode(reason, carteam)
    return
  end
  ConstructMyTeamData(carteam)
  EventSystem:postEvent(EVENTTYPE_ALLSTAR, EVENTID_ALLSTAR_ENTER_TEAM_SUCCESS)
end
function ESportSquadSystem.OnApproveJoinCarteamRsp(ok, reason, _, op_uid)
  if not ok then
    ProtocolErroCode(reason)
  end
  log(bWriteLog and "OnApproveJoinCarteamRsp ", reason)
  for i, v in pairs(applyList) do
    if v == op_uid then
      table.remove(applyList, i)
      local esport_reddot_data = require("client.slua.logic.esport.esport_reddot_data")
      esport_reddot_data.UpdateApplyCount(#applyList)
      break
    end
  end
  EventSystem:postEvent(EVENTTYPE_ALLSTAR, EVENTID_ALLSTAR_TEAM_APPROVE_JOIN_RSP)
end
function ESportSquadSystem.OnGetAllOffmsgRsp(offmsg_list)
  local ESportAllStarSystem = require("client.slua.logic.esport.logic_esport_allstar")
  if not ESportAllStarSystem.IsCarTeamOpen() then
    return
  end
  if offmsg_list == nil then
    log(bWriteLog and "OnGetAllOffmsgRsp is none")
    return
  end
  if GameStatus.IsInLobbyOrMainCity() then
    log_tree("OnGetAllOffmsgRsp", offmsg_list)
    for _, v in pairs(offmsg_list) do
      local hasMsg = GetOffmsgInfoByIndex(v.index)
      if hasMsg == nil then
        table.insert(OffMsgInfo, v)
      end
    end
    PopQueueMsgInfoTips()
  end
end
function ESportSquadSystem.OnTransferCarteamLeaderRsp(ok, reason, carteam)
  log(bWriteLog and "OnTransferCarteamLeaderRsp" .. tostring(ok) .. tostring(reason))
  if not ok then
    ProtocolErroCode(reason)
    return
  end
  ShowNotice(301279)
end
function ESportSquadSystem.OnExitCarteamRsp(ok, reason, source)
  log(bWriteLog and "ESportSquadSystem.OnExitCarteamRsp" .. tostring(ok))
  log(bWriteLog and "ESportSquadSystem.OnExitCarteamRsp" .. tostring(reason))
  log(bWriteLog and "ESportSquadSystem.OnExitCarteamRsp" .. tostring(source))
  if not ok then
    ProtocolErroCode(reason)
    return
  end
  local ESportAllStarSystem = require("client.slua.logic.esport.logic_esport_allstar")
  ESportAllStarSystem.ClearData()
  DataMgr.roleData.carteamId = 0
  ClearData()
  EventSystem:postEvent(EVENTTYPE_ALLSTAR, EVENTID_ALLSTAR_EXIT_TEAM)
  if source and source == "exit-carteam-fill" then
    ESportSquadSystem.FastJoinTeamReq()
  end
end
function ESportSquadSystem.OnKickoutCarteamRsp(ok, reason, uid)
  log(bWriteLog and "OnKickoutCarteamRsp" .. tostring(ok) .. tostring(reason) .. tostring(uid))
  if not ok then
    ProtocolErroCode(reason)
    return
  end
  KickoutTeamMember(uid)
  ShowNotice(301278)
  EventSystem:postEvent(EVENTTYPE_ALLSTAR, EVENTID_ALLSTAR_UPDATE_TEAM_INFO_NOTIFY)
end
function ESportSquadSystem.OnPreCreateCarteamRsp(ok, reason, min_level)
  log(bWriteLog and "OnPreCreateCarteamRsp")
  if not ok then
    ProtocolErroCode(reason, min_level)
    return
  end
  local title = LocUtil.GetLocalizeResStr(101001)
  local content = LocUtil.GetLocalizeResStr(33823)
  local YesText = LocUtil.GetLocalizeResStr(4110)
  local NoText = LocUtil.GetLocalizeResStr(4115)
  local extraData = {
    urlTips = LocUtil.LocalizeResFormat(33818, 2, 4)
  }
  local CreateTeamClick = function(is_fill)
    ESportSquadSystem.SendCreateTeamReq(DataMgr.roleData.nickName, 0, "", is_fill)
  end
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(4, title, content, function()
    CreateTeamClick(false)
  end, function()
    CreateTeamClick(true)
  end, YesText, NoText, extraData)
end
function ESportSquadSystem.OnJoinCarteamRsp(ok, reason, param)
  if ok then
    ShowNotice(110012)
    AddHasSentJoinReqItem(param)
  elseif type(reason) == "string" then
    ProtocolErroCode(reason, param)
  elseif type(reason) == "number" then
    if reason == 505041 then
      AddHasSentJoinReqItem(param)
    elseif reason == 505001 then
      ShowNotice(110009)
    else
      ShowNotice(reason)
    end
  end
  EventSystem:postEvent(EVENTTYPE_ALLSTAR, EVENTID_ALLSTAR_TEAM_JOIN_TEAM_RSP)
end
function ESportSquadSystem.OnCarteamFillRsp(ok, reason, carteam_id)
  if not ok then
    ProtocolErroCode(reason)
    return
  end
  local AllianceHandler = require("client.network.Protocol.AllianceHandler")
  AllianceHandler.send_imm_join_carteam_req(carteam_id)
end
function ESportSquadSystem.OnTeamSuggestionListRsp(err, suggestion_list)
  log_tree("ESportSquadSystem.OnTeamSuggestionListRsp:", suggestion_list)
  if err ~= 0 then
    ShowNotice(LocUtil.LocalizeResFormat(err))
    return
  end
  EventSystem:postEvent(EVENTTYPE_ALLSTAR, EVENTID_ALLSTAR_TEAM_SUGGESTION_LIST_RSP, suggestion_list)
end
function ESportSquadSystem.OnTeamSearchListRsp(err, carteam_list)
  log_tree("ESportSquadSystem.OnTeamSearchListRsp:", carteam_list)
  if err ~= 0 then
    ShowNotice(LocUtil.LocalizeResFormat(err))
    return
  end
  EventSystem:postEvent(EVENTTYPE_ALLSTAR, EVENTID_ALLSTAR_TEAM_SUGGESTION_LIST_RSP, carteam_list)
end
function ESportSquadSystem.OnSetTeamFlagRsp(retCode, id)
  log(bWriteLog and "OnSetCarTeamFlagRsp " .. retCode .. " id " .. id)
  if retCode ~= 0 then
    ShowNotice(retCode)
    return
  end
  UIManager.CloseUI(UIManager.UI_Config.esport_select_team_flag)
  myTeamData.team_flag = id
  EventSystem:postEvent(EVENTTYPE_ALLSTAR, EVENTID_ALLSTAR_TEAM_SET_TEAM_FLAG_RSP, id)
  local LogicEsportSquadOther = require("client.slua.logic.esport.logic_esport_squad_other")
  LogicEsportSquadOther.SetTeamData(myTeamData)
end
function ESportSquadSystem.OnSetTeamNationFlagRsp(retCode, id)
  log(bWriteLog and "OnSetTeamNationFlagRsp " .. retCode .. " id " .. id)
  if retCode ~= 0 then
    ShowNotice(retCode)
    return
  end
  UIManager.CloseUI(UIManager.UI_Config.country_area_popup)
  myTeamData.nation_flag = id
  EventSystem:postEvent(EVENTTYPE_ALLSTAR, EVENTID_ALLSTAR_TEAM_SET_NATION_FLAG_RSP, id)
end
function ESportSquadSystem.OnSquadProfileListRsp(role_basic_info_list)
  myTeamProfileList = {}
  local list = {}
  for _, v in pairs(role_basic_info_list) do
    local data = {}
    local uid = tonumber(v.uid)
    if uid == tonumber(DataMgr.roleData.uid) then
      data = ESportSquadSystem.ConstructSelfData()
    else
      data = ESportSquadSystem.ConstructOtherData(v)
    end
    ConstructTeamStateData(data)
    table.insert(myTeamProfileList, data)
    table.insert(list, uid)
  end
  table.sort(myTeamProfileList, ESportSquadSystem.TeamProfileSortFunc)
  if next(list) then
    local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
    PlayerStatusMgr:GetOrReqStatusData(ENUM_BATCH_GET_GROUP_AND_ONLINE.ESportSquadSystem, list)
  end
  EventSystem:postEvent(EVENTTYPE_ALLSTAR, EVENTID_ALLSTAR_MY_TEAM_PROFILE_RES)
end
function ESportSquadSystem.OnSuggestionProfileListRsp(role_basic_info_list)
  EventSystem:postEvent(EVENTTYPE_ALLSTAR, EVENTID_ALLSTAR_TEAM_SUGGESTION_PROFILE_RES)
end
function ESportSquadSystem.OnNotifyUpdateCarteamInfo(team_id, changeType, value)
  local ESportAllStarSystem = require("client.slua.logic.esport.logic_esport_allstar")
  if not ESportAllStarSystem.IsCarTeamOpen() then
    return
  end
  log(bWriteLog and "ESportSquadSystem.OnNotifyUpdateCarteamInfo" .. tostring(team_id) .. " " .. tostring(changeType) .. " " .. tostring(value))
  if ESportSquadSystem.GetTeamID() ~= tonumber(team_id) then
    log(bWriteLog and "Not my team")
    return
  end
  if changeType == 1 then
    myTeamData.name = value
  end
  if changeType == 2 then
    myTeamData.icon = value
  end
  if changeType == 3 then
    myTeamData.announcement = value
  end
  if changeType == 4 then
    UpdateTeamLeader(value)
    if ESportSquadSystem.IsTeamLeader(DataMgr.roleData.uid) then
      ESportSquadSystem.SendGetApplyListReq()
    end
  end
  if changeType == 8 then
    myTeamData.area_id = value
    local AllStarHandler = require("client.network.Protocol.AllStarHandler")
    AllStarHandler.send_get_allstar_can_join_game_info_req()
    return
  end
  if changeType == 11 then
    myTeamData.fill = value
  end
  EventSystem:postEvent(EVENTTYPE_ALLSTAR, EVENTID_ALLSTAR_UPDATE_TEAM_INFO_NOTIFY)
end
function ESportSquadSystem.OnNotifyUpdateCarteamMember(team_id, msgType, uid, member)
  local ESportAllStarSystem = require("client.slua.logic.esport.logic_esport_allstar")
  if not ESportAllStarSystem.IsCarTeamOpen() then
    return
  end
  log_tree("ESportSquadSystem.OnNotifyUpdateCarteamMember" .. " " .. tostring(team_id) .. " " .. tostring(msgType) .. " " .. tostring(uid), member)
  if ESportSquadSystem.GetTeamID() ~= tonumber(team_id) then
    log(bWriteLog and "ESportSquadSystem.OnNotifyUpdateCarteamMember Not my team")
    return
  end
  if msgType == 1 then
    AddTeamMember(uid, member)
  end
  if msgType == 2 then
    if uid == tonumber(DataMgr.roleData.uid) then
      ESportAllStarSystem.ClearData()
      DataMgr.roleData.carteamId = 0
      ClearData()
      EventSystem:postEvent(EVENTTYPE_ALLSTAR, EVENTID_ALLSTAR_EXIT_TEAM)
      ShowNotice(LocUtil.LocalizeResFormat(111014))
    else
      KickoutTeamMember(uid)
      EventSystem:postEvent(EVENTTYPE_ALLSTAR, EVENTID_ALLSTAR_UPDATE_TEAM_INFO_NOTIFY)
    end
  end
  if msgType == 3 then
    UpdateTeamMember(uid, member)
    EventSystem:postEvent(EVENTTYPE_ALLSTAR, EVENTID_ALLSTAR_UPDATE_TEAM_INFO_NOTIFY, 3, uid)
  end
end
function ESportSquadSystem.OnNotifyJoinCarteam(ok, reason, carteam)
end
function ESportSquadSystem.OnNotifyReceiveOffmsg(msgtype)
  local ESportAllStarSystem = require("client.slua.logic.esport.logic_esport_allstar")
  if not ESportAllStarSystem.IsCarTeamOpen() then
    return
  end
  log(bWriteLog and "OnNotifyReceiveOffmsg" .. msgtype)
  ESportSquadSystem.SendAllOffMsgReq(msgtype)
end
function ESportSquadSystem.NotifyJoinCarteamRsp()
  local ESportAllStarSystem = require("client.slua.logic.esport.logic_esport_allstar")
  if not ESportAllStarSystem.IsCarTeamOpen() then
    return
  end
  log(bWriteLog and "NotifyJoinCarteamRsp")
  ESportSquadSystem.SendGetApplyListReq()
end
return ESportSquadSystem