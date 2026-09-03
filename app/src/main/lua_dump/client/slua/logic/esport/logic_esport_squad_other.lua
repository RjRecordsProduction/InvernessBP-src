local ESportSquadOther = {
  playerTeamDataDic = {},
  otherTeamProfileList = {}
}
function ESportSquadOther.ClearData()
  ESportSquadOther.playerTeamDataDic = {}
  ESportSquadOther.otherTeamProfileList = {}
end
function ESportSquadOther.OnModePostSwitch(preState, nextState)
  if nextState == GameStatus.Login or nextState == GameStatus.Fighting and not GameStatus.IsInMainCity() then
    ESportSquadOther.ClearData()
  end
end
function ESportSquadOther.SetTeamData(teamData)
  if not teamData or not teamData.team_id then
    return
  end
  ESportSquadOther.playerTeamDataDic[teamData.team_id] = teamData
  local TimeUtil = require("client.common.time_util")
  ESportSquadOther.playerTeamDataDic[teamData.team_id].saveTime = TimeUtil.GetServerTimeInSec()
  local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
  LobbySocialSystem.RefreshCarTeamUI(teamData.team_id)
end
function ESportSquadOther.GetTeamData(team_id)
  return ESportSquadOther.playerTeamDataDic[team_id]
end
function ESportSquadOther.GetTeamProfileList()
  return ESportSquadOther.otherTeamProfileList
end
function ESportSquadOther.IsTeamLeader(team_id, uid)
  local teamData = ESportSquadOther.GetTeamData(team_id)
  if not teamData then
    return false
  end
  return uid == teamData.leader.uid
end
function ESportSquadOther.ConstructTeamStateData(data)
  data.friendType = 0
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  data.roleNation = logic_profile:GetPlayerNation(data.uid)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  data.isMyFriend = LogicFriend.IsMyFriend(data.uid)
  local memberInfo = ESportSquadOther.GetMemberInfo(data.uid)
  if memberInfo then
    data.online = memberInfo.online_state
    data.teamState = memberInfo.team_state
    data.currentTeamAmount = memberInfo.team_amount or 1
    data.maxTeamAmount = memberInfo.team_max
    data.openId = memberInfo.openid
    if memberInfo.online_info and memberInfo.online_info.timeSinceGameBegin then
      data.timeSinceGameBegin = memberInfo.online_info.timeSinceGameBegin
      local TimeUtil = require("client.common.time_util")
      data.timeSinceGameBeginStamp = TimeUtil.GetServerTimeInSec() - data.timeSinceGameBegin
    end
  end
end
function ESportSquadOther.GetMemberInfo(uid)
  for _, v in pairs(ESportSquadOther.playerTeamDataDic) do
    for k, member in pairs(v.members) do
      if k == uid then
        return member
      end
    end
  end
  return nil
end
function ESportSquadOther.QueryOthersCarteamReq(query_uid, query_carteam_id)
  local ESportAllStarSystem = require("client.slua.logic.esport.logic_esport_allstar")
  if not ESportAllStarSystem.IsCarTeamOpen() then
    return
  end
  if query_uid == nil or query_uid == 0 then
    return
  end
  if query_carteam_id == nil then
    return
  end
  if query_carteam_id == 0 then
    ESportSquadOther.OnQueryOthersCarteamRsp(false, 505001, {})
    return
  end
  if ESportSquadOther.playerTeamDataDic[query_carteam_id] then
    local TimeUtil = require("client.common.time_util")
    if TimeUtil.GetServerTimeInSec() - ESportSquadOther.playerTeamDataDic[query_carteam_id].saveTime > 300 then
      local AllianceHandler = require("client.network.Protocol.AllianceHandler")
      AllianceHandler.send_query_others_carteam_req(query_uid, query_carteam_id)
    else
      ESportSquadOther.OnQueryOthersCarteamRsp(true, 0, ESportSquadOther.playerTeamDataDic[query_carteam_id])
    end
  else
    local AllianceHandler = require("client.network.Protocol.AllianceHandler")
    AllianceHandler.send_query_others_carteam_req(query_uid, query_carteam_id)
  end
end
function ESportSquadOther.OnQueryOthersCarteamRsp(ok, reason, carteam)
  if ok then
    if carteam and carteam.team_id then
      ESportSquadOther.SetTeamData(carteam)
      local uidList = {}
      for k, _ in pairs(carteam.members) do
        table.insert(uidList, k)
      end
      local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
      logic_profile_get_wrap.GetNormalProfiles(uidList, ESportSquadOther.OnProfileOtherRsp, Enum_PROFILE_REPORT_CFG.ALLIANCE_OTHER, 0, false)
      EventSystem:postEvent(EVENTTYPE_ALLSTAR, EVENTID_ALLSTAR_TEAM_QUERY_OTHER_TEAM_RSP, carteam.team_id)
    end
  elseif reason ~= 505001 then
    ShowNotice(reason)
  end
end
function ESportSquadOther.OnProfileOtherRsp(role_basic_info_list)
  ESportSquadOther.otherTeamProfileList = {}
  local ESportSquadSystem = require("client.slua.logic.esport.logic_esport_squad")
  for _, v in pairs(role_basic_info_list) do
    local data
    local uid = tonumber(v.uid)
    if uid == tonumber(DataMgr.roleData.uid) then
      data = ESportSquadSystem.ConstructSelfData()
    else
      data = ESportSquadSystem.ConstructOtherData(v)
    end
    ESportSquadOther.ConstructTeamStateData(data)
    table.insert(ESportSquadOther.otherTeamProfileList, data)
  end
  table.sort(ESportSquadOther.otherTeamProfileList, ESportSquadSystem.TeamProfileSortFunc)
  EventSystem:postEvent(EVENTTYPE_ALLSTAR, EVENTID_ALLSTAR_TEAM_PROFILE_OTHER_RES)
end
return ESportSquadOther