local table_util = require("common.table_util")
local Logic_Temu_Team = {
  selfGroupID = nil,
  teamDetail = {},
  member_progress = {},
  _animation_state = nil,
  Guide = nil
}
local lastTimeSpan = 10
local maxMember = 4
function Logic_Temu_Team.ResetData()
  Logic_Temu_Team.selfGroupID = nil
  Logic_Temu_Team.teamDetail = {}
  Logic_Temu_Team.member_progress = {}
  Logic_Temu_Team._animation_state = {}
  Logic_Temu_Team.Guide = nil
end
local GetModule = function()
  return ModuleManager.GetModule(ModuleManager.CommonModuleConfig.Logic_temu)
end
function Logic_Temu_Team:IsNeedShowGetKick()
  local Logic_Temu = GetModule()
  local stageInfo = Logic_Temu:GetStageInfo()
end
function Logic_Temu_Team.IsCurStageNeedAnim(stageID)
  local teamID = Logic_Temu_Team.GetSelfTeamID()
  local data = Logic_Temu_Team.TryGetStageAnimationState()
  if not data.stage[teamID] then
    data.stage[teamID] = {}
  end
  return not data.stage[teamID][stageID]
end
function Logic_Temu_Team.IsHaveTeam()
  local groupID = Logic_Temu_Team.GetSelfTeamID()
  return groupID ~= nil
end
function Logic_Temu_Team.IsTeamCanKick(uid)
  if not Logic_Temu_Team.IsHaveTeam() then
    return
  end
  local selfTeamInfo = Logic_Temu_Team.GetSelfTeamInfo()
  if not selfTeamInfo then
    return false
  end
  if selfTeamInfo.leader_uid ~= tonumber(DataMgr.roleData.uid) then
    return false
  end
  for i, data in pairs(selfTeamInfo.member) do
    if data.memberData and data.memberData.uid == uid then
      return data.memberData.can_be_kicked
    end
  end
  return false
end
function Logic_Temu_Team.IsTeamCanInvite()
  local teamInfo = Logic_Temu_Team.GetSelfTeamInfo()
  if not teamInfo then
    return
  end
  return teamInfo.total_num < maxMember
end
function Logic_Temu_Team.IsCanSendTeamInfo(id)
  local teamDetail = Logic_Temu_Team.GetTeamDetail(id)
  if not teamDetail then
    return true
  end
  local time_util = require("client.common.time_util")
  local curTime = time_util.GetServerTimeInSec()
  local lastTime = teamDetail.lastSendTime or 0
  return curTime > lastTime + lastTimeSpan
end
function Logic_Temu_Team.IsLeader(group_id, uid)
  group_id = group_id or Logic_Temu_Team.GetSelfTeamID()
  uid = uid or tonumber(DataMgr.roleData.uid)
  local teamInfo = Logic_Temu_Team.GetTeamInfo(group_id)
  if not teamInfo then
    return false, false
  end
  return teamInfo.leader_uid == uid, teamInfo.leader_uid == tonumber(DataMgr.roleData.uid)
end
function Logic_Temu_Team.IsSelfLeader()
  local teamInfo = Logic_Temu_Team.GetSelfTeamInfo()
  if not teamInfo then
    return false
  end
  return teamInfo.leader_uid == tonumber(DataMgr.roleData.uid)
end
function Logic_Temu_Team.IsCurSeasonNeedShowGuide()
  local Guide = Logic_Temu_Team.GetCurSeasonGuideState()
  if not Guide then
    return true
  end
  local isHaveTeam = Logic_Temu_Team.IsHaveTeam()
  if isHaveTeam or Guide.isHaveTeam then
    return false
  end
  local time_util = require("client.common.time_util")
  local curTime = time_util.GetServerTimeInSec()
  if not time_util.IsSameDay(Guide.lastShowTime, curTime) then
    return true
  end
  return false
end
function Logic_Temu_Team.IsTeamHaveMemberCanGift(stageID)
  local teamData = Logic_Temu_Team.GetSelfTeamInfo()
  if not teamData then
    return false
  end
  stageID = stageID or Logic_Temu_Team.GetCurStageID()
  for i, data in pairs(teamData.member) do
    if data.memberData and data.memberData.uid ~= tonumber(DataMgr.roleData.uid) and not data.memberData.stage_info[stageID].gifted then
      return true
    end
  end
  return false
end
function Logic_Temu_Team.GetSelfTeamID()
  return Logic_Temu_Team.selfGroupID
end
function Logic_Temu_Team.GetSelfTeamInfo()
  if not Logic_Temu_Team.IsHaveTeam() then
    return
  end
  local selfTeamId = Logic_Temu_Team.GetSelfTeamID()
  return Logic_Temu_Team.GetTeamInfo(selfTeamId), selfTeamId
end
function Logic_Temu_Team.GetTeamInfo(id)
  local detail = Logic_Temu_Team.GetTeamDetail(id)
  return detail and detail.data
end
function Logic_Temu_Team.GetTeamDetail(id)
  return Logic_Temu_Team.teamDetail[id]
end
function Logic_Temu_Team.GetCurStageID()
  local id = 1
  local info = Logic_Temu_Team.GetSelfTeamInfo()
  local Logic_Temu = GetModule()
  if info then
    id = info.stage or 1
  else
    local data = Logic_Temu:GetAllStageData()
    if not data then
      return 1
    end
    id = 1
    for i, v in pairs(data) do
      if v.pkg_status == 2 then
        id = id + 1
      end
    end
  end
  return math.min(id, Logic_Temu:GetMaxStage())
end
function Logic_Temu_Team.GetCurSubStageID()
  local id = 1
  local info = Logic_Temu_Team.GetSelfTeamInfo()
  if info then
    id = info.sub_stage
  end
  return id
end
function Logic_Temu_Team.UpdateSelfTeamID(id)
  Logic_Temu_Team.selfGroupID = id
  Logic_Temu_Team.UpdateGuideIsHaveTeam()
end
function Logic_Temu_Team.UpdateGuideIsHaveTeam()
  if Logic_Temu_Team.IsHaveTeam() then
    local guide = Logic_Temu_Team.GetCurSeasonGuideState()
    if guide and not guide.isHaveTeam then
      guide.isHaveTeam = true
      local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
      PlayerPrefsSystem.SaveTableToFile_N(guide, PlayerPrefsSystem.ePlayerPrefsType.TemuGuide)
    end
  end
end
function Logic_Temu_Team.GetMemberTaskProgress(uid, stage)
  return table_util.GetTableValue(Logic_Temu_Team.member_progress, stage, tonumber(uid)) or 0
end
function Logic_Temu_Team.GetPackageExpireTime()
  local teamInfo = Logic_Temu_Team.GetSelfTeamInfo()
  if not teamInfo then
    return 0
  end
  return teamInfo.pkg_expired
end
function Logic_Temu_Team.GetFreeLeaveTime()
  local teamInfo = Logic_Temu_Team.GetSelfTeamInfo()
  if not teamInfo then
    return 0
  end
  return teamInfo.recruiting_expired
end
function Logic_Temu_Team.GetTeamInfoTotalNum(teamID)
  teamID = teamID or Logic_Temu_Team.GetSelfTeamID()
  local teamInfo = Logic_Temu_Team.GetTeamInfo(teamID)
  if not teamInfo then
    return 1
  end
  return teamInfo.total_num
end
function Logic_Temu_Team.GetStartTaskMemberNum(teamID)
  teamID = teamID or Logic_Temu_Team.GetSelfTeamID()
  local teamInfo = Logic_Temu_Team.GetTeamInfo(teamID)
  if not teamInfo then
    return 1
  end
  return teamInfo.start_task_member
end
function Logic_Temu_Team.GetCurSeasonGuideState()
  local Logic_Temu = GetModule()
  if not Logic_Temu then
    return
  end
  local seasonID = Logic_Temu:GetCurSeasonID()
  if not seasonID or seasonID == 0 then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  if not Logic_Temu_Team.Guide then
    local info = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.TemuGuide)
    if not info or info.seasonID ~= seasonID then
      local isHaveTeam = Logic_Temu_Team.IsHaveTeam()
      Logic_Temu_Team.Guide = {
        seasonID = seasonID,
        isHaveTeam = isHaveTeam,
        lastShowTime = 0
      }
      PlayerPrefsSystem.SaveTableToFile_N(Logic_Temu_Team.Guide, PlayerPrefsSystem.ePlayerPrefsType.TemuGuide)
    else
      Logic_Temu_Team.Guide = info
    end
  end
  return Logic_Temu_Team.Guide
end
function Logic_Temu_Team.TryGetStageAnimationState()
  local Logic_Temu = GetModule()
  if not Logic_Temu then
    log(bWriteLog and "[SY]Logic_Temu_Team.TryGetStageAnimationState.No Module")
    return
  end
  local data
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  if not Logic_Temu_Team._animation_state then
    data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.TemuStageAnim)
  else
    data = Logic_Temu_Team._animation_state
  end
  local seasonID = Logic_Temu:GetCurSeasonID()
  if data and data.seasonID == seasonID then
    Logic_Temu_Team._animation_state = data
  else
    Logic_Temu_Team._animation_state = {
      seasonID = seasonID,
      stage = {}
    }
    PlayerPrefsSystem.SaveTableToFile_N(Logic_Temu_Team._animation_state, PlayerPrefsSystem.ePlayerPrefsType.TemuStageAnim)
  end
  return Logic_Temu_Team._animation_state
end
function Logic_Temu_Team.SetAlreadyPlayStageAnimation(stageID)
  local data = Logic_Temu_Team.TryGetStageAnimationState()
  local teamID = Logic_Temu_Team.GetSelfTeamID()
  if not data.stage[teamID] then
    data.stage[teamID] = {}
  end
  data.stage[teamID][stageID] = true
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(Logic_Temu_Team._animation_state, PlayerPrefsSystem.ePlayerPrefsType.TemuStageAnim)
end
function Logic_Temu_Team.Login_SetTeamID(id)
  log(bWriteLog and "[SY]Logic_Temu_Team.Login_SetTeamID." .. tostring(id))
  Logic_Temu_Team.UpdateSelfTeamID(id)
end
function Logic_Temu_Team.SendCreateTeam(stageID)
  if Logic_Temu_Team.IsHaveTeam() then
    return
  end
  local TEMUHandler = require("client.network.Protocol.TEMUHandler")
  TEMUHandler.send_create_temu_group_req(stageID)
end
function Logic_Temu_Team.SendDismissTeam()
  if not Logic_Temu_Team.IsHaveTeam() then
    ShowNotice()
    return
  end
  local TEMUHandler = require("client.network.Protocol.TEMUHandler")
  TEMUHandler.send_dismiss_temu_group_req()
end
function Logic_Temu_Team.SendJoinTeam(id)
  if Logic_Temu_Team.IsHaveTeam() then
    ShowNotice(527032)
    return
  end
  local TEMUHandler = require("client.network.Protocol.TEMUHandler")
  TEMUHandler.send_join_temu_group_req(id)
end
function Logic_Temu_Team.SendLeaveTeam()
  if not Logic_Temu_Team.IsHaveTeam() then
    return
  end
  local TEMUHandler = require("client.network.Protocol.TEMUHandler")
  TEMUHandler.send_leave_temu_group_req()
end
function Logic_Temu_Team.SendKickMember(uid)
  local TEMUHandler = require("client.network.Protocol.TEMUHandler")
  TEMUHandler.send_temu_group_kick_member_req(uid)
end
function Logic_Temu_Team.SendGetSelfTeamInfo(isForceGet)
  if not Logic_Temu_Team.IsHaveTeam() then
    return
  end
  Logic_Temu_Team.SendGetTeamInfo(nil, isForceGet)
end
function Logic_Temu_Team.SendGetTeamInfo(id, isForceGet)
  id = id or Logic_Temu_Team.GetSelfTeamID()
  if not id then
    log(bWriteLog and "[SY]Logic_Temu_Team.SendGetTeamInfo. .. NoTeam")
    return
  end
  if not isForceGet and not Logic_Temu_Team.IsCanSendTeamInfo(id) then
    log(bWriteLog and "[SY]Logic_Temu_Team.SendGetTeamInfo. .. ISCD")
    return
  end
  log(bWriteLog and "[SY]Logic_Temu_Team.SendGetTeamInfo." .. tostring(id))
  local TEMUHandler = require("client.network.Protocol.TEMUHandler")
  TEMUHandler.send_get_temu_group_info_req(id)
end
function Logic_Temu_Team.SendRemind(uid)
  local TEMUHandler = require("client.network.Protocol.TEMUHandler")
  TEMUHandler.send_remind_teammate_purchase_package_req({uid})
end
function Logic_Temu_Team.OnRemindTeamMate()
  Logic_Temu_Team.SendGetSelfTeamInfo(true)
end
function Logic_Temu_Team.OnCreateTeam(id)
  Logic_Temu_Team.UpdateSelfTeamID(id)
  Logic_Temu_Team.SendGetSelfTeamInfo(true)
end
function Logic_Temu_Team.OnJoinTeam(id)
  Logic_Temu_Team.UpdateSelfTeamID(id)
  Logic_Temu_Team.SendGetSelfTeamInfo(true)
end
function Logic_Temu_Team.OnDismissTeam(id)
  Logic_Temu_Team.ClearTeamData(id)
end
function Logic_Temu_Team.OnLeaveTeam(id)
  Logic_Temu_Team.ClearTeamData(id)
end
function Logic_Temu_Team.OnKickMember(uid)
  Logic_Temu_Team.DeleteMember(uid)
  Logic_Temu_Team.SendGetSelfTeamInfo(true)
  local Logic_Temu = GetModule()
  Logic_Temu:SendGetStageInfo()
  EventSystem:postEvent(EVENTTYPE_TEMU, EVENTID_TEMU_KICK_MEMBER)
end
function Logic_Temu_Team.OnGetTeamInfo(info)
  Logic_Temu_Team.UpdateTeamDetail(info.group_id, info)
  if info.group_id == Logic_Temu_Team.selfGroupID then
    EventSystem:postEvent(EVENTTYPE_TEMU, EVENTID_TEMU_UPDATE_SELF_TEAM_INFO)
  end
  EventSystem:postEvent(EVENTTYPE_TEMU, EVENTID_TEMU_UPDATE_TEAM_INFO)
end
function Logic_Temu_Team.OnSendGetStageTaskProgress(memberProgress, stage)
  if not Logic_Temu_Team.IsHaveTeam() then
    return
  end
  for uid, progress in pairs(memberProgress) do
    if not Logic_Temu_Team.member_progress[stage] then
      Logic_Temu_Team.member_progress[stage] = {}
    end
    Logic_Temu_Team.member_progress[stage][tonumber(uid)] = progress
  end
end
function Logic_Temu_Team.DeleteMember(uid)
  local teamInfo = Logic_Temu_Team.GetSelfTeamInfo()
  if teamInfo then
    for i, member in pairs(teamInfo.member) do
      if member.memberData and member.memberData.uid == uid then
        member.memberData = nil
        break
      end
    end
  end
end
function Logic_Temu_Team.ClearTeamData(groupId)
  log(bWriteLog and "[SY]Logic_Temu_Team.ClearTeamData.")
  local groupID = groupId or Logic_Temu_Team.GetSelfTeamID()
  if not groupID then
    return
  end
  Logic_Temu_Team.teamDetail[groupID] = nil
  Logic_Temu_Team.member_progress = {}
  if groupID == Logic_Temu_Team.selfGroupID then
    Logic_Temu_Team.selfGroupID = nil
  end
end
function Logic_Temu_Team.ClearLastSendTime()
  local groupID = Logic_Temu_Team.GetSelfTeamID()
  if not groupID then
    return
  end
  local selfTeamInfo = Logic_Temu_Team.GetTeamDetail(groupID)
  if not selfTeamInfo then
    return
  end
  selfTeamInfo.lastSendTime = 0
end
function Logic_Temu_Team.TryGetTeamInfo(id)
  id = id or Logic_Temu_Team.GetSelfTeamID()
  local isCanGetNewData = Logic_Temu_Team.IsCanSendTeamInfo(id)
  if isCanGetNewData then
    Logic_Temu_Team.SendGetTeamInfo(id)
  end
  return Logic_Temu_Team.GetTeamInfo(id)
end
function Logic_Temu_Team.CheckPackageStateCanKick()
  local teamInfo = Logic_Temu_Team.GetSelfTeamInfo()
  if not teamInfo then
    return false
  end
  local time_util = require("client.common.time_util")
  local curTime = time_util.GetServerTimeInSec()
  local endTime = Logic_Temu_Team.GetPackageExpireTime()
  return curTime >= endTime
end
function Logic_Temu_Team.UpdateTeamDetail(id, info)
  local time_util = require("client.common.time_util")
  if not Logic_Temu_Team.teamDetail[id] then
    Logic_Temu_Team.teamDetail[id] = {}
  end
  local data = {
    group_id = info.group_id,
    total_num = info.total_num,
    start_task_member = info.start_task_member_cnt or 1,
    leader_uid = info.leader_uid,
    stage = info.cur_stage,
    sub_stage = info.sub_stage,
    pkg_expired = info.pkg_expired or 0,
    recruiting_expired = info.recruiting_expired or 0
  }
  local memberList = {}
  for i = 1, maxMember do
    if not memberList[i] then
      memberList[i] = {}
    end
    if info.member[i] then
      local member = info.member[i]
      local memberData = {
        group_id = data.group_id,
        uid = member.uid,
        position = member.position,
        reminded = member.reminded,
        can_be_kicked = member.can_be_kicked,
        stage_info = member.stage_info,
        join_time = member.join_time
      }
      memberList[i].    end
  end
  data.member = memberList
  Logic_Temu_Team.teamDetail[id].  Logic_Temu_Team.teamDetail[id].lastSendTime = time_util.GetServerTimeInSec()
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local uidProfileList = {}
  for i, v in pairs(info.member) do
    local memberData = v
    if memberData and memberData.uid then
      local profile = logic_profile:GetLocalProfile(memberData.uid)
      if not profile then
        table.insert(uidProfileList, memberData.uid)
      end
    end
  end
  if 0 < #uidProfileList then
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles(uidProfileList, Logic_Temu_Team.UpdateHeadItem, Enum_PROFILE_REPORT_CFG.TEMU_TEAM, 0, true)
  end
end
function Logic_Temu_Team.UpdateHeadItem()
  log(bWriteLog and "[SY]Logic_Temu_Team.UpdateHeadItem.")
  EventSystem:postEvent(EVENTTYPE_TEMU, EVENTID_TEMU_UPDATE_HEAD_INFO)
end
function Logic_Temu_Team.IsCurSeasonNeedShowGuide()
  local Guide = Logic_Temu_Team.GetCurSeasonGuideState()
  if not Guide then
    return true
  end
  local isHaveTeam = Logic_Temu_Team.IsHaveTeam()
  if isHaveTeam or Guide.isHaveTeam then
    return false
  end
  local time_util = require("client.common.time_util")
  local curTime = time_util.GetServerTimeInSec()
  if not time_util.IsSameDay(Guide.lastShowTime, curTime) then
    return true
  end
  return false
end
function Logic_Temu_Team.TodayShowGuide()
  local Guide = Logic_Temu_Team.GetCurSeasonGuideState()
  if not Guide then
    return
  end
  local time_util = require("client.common.time_util")
  Guide.lastShowTime = time_util.GetServerTimeInSec()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(Guide, PlayerPrefsSystem.ePlayerPrefsType.TemuGuide)
end
return Logic_Temu_Team