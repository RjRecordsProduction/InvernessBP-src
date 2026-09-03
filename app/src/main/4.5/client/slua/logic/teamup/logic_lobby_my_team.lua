local timer_tick = require("common.time_ticker")
local surperList = require("common.super_list")
local logic_lobby_my_team = {
  inviteInterval = 10,
  teamMember = {},
  playerList = {},
  timedownList = {},
  requestCancelRecruitTime = 0
}
local player_info = {
  info = {},
  inviteElapse = 0
}
local timerHandle
function logic_lobby_my_team.Init()
end
function logic_lobby_my_team.RegisterEvent()
  EventSystem:registEvent(EVENTTYPE_TEAMUP, EVENTID_CONSCRIBE_UPDATE_TEAM, logic_lobby_my_team.OnTeamInfoSys)
end
function logic_lobby_my_team.UnRegisterEvent()
  EventSystem:unregistEvent(EVENTTYPE_TEAMUP, EVENTID_CONSCRIBE_UPDATE_TEAM, logic_lobby_my_team.OnTeamInfoSys)
end
function logic_lobby_my_team.OnModePostSwitch(preState, nextState)
  if nextState == GameStatus.Lobby then
    logic_lobby_my_team.Init()
    logic_lobby_my_team.RegisterEvent()
  elseif not GameStatus.IsInLobbyOrMainCity() then
    logic_lobby_my_team.ClearData()
    logic_lobby_my_team.UnRegisterEvent()
  end
end
function logic_lobby_my_team.ClearData()
  if timerHandle then
    timer_tick.RemoveTimer(timerHandle)
    timerHandle = nil
  end
  logic_lobby_my_team.timedownList = {}
  logic_lobby_my_team.playerList = {}
  logic_lobby_my_team.teamMember = {}
end
function logic_lobby_my_team.GetTeamMember()
  return logic_lobby_my_team.teamMember
end
function logic_lobby_my_team.GetPlayerList()
  return logic_lobby_my_team.playerList
end
function logic_lobby_my_team.OnTeamInfoSys()
  logic_lobby_my_team.teamMember = {}
  local teamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local teamInfo = teamUpNewSystem.teamInfo
  if teamInfo and teamInfo.publish_conscribe and teamInfo.members and next(teamInfo.members) then
    local zone_id = teamInfo.zone_id
    for k, v in pairs(teamInfo.members) do
      local info = {
        isLeader = teamInfo.leader == k,
        uid = tonumber(k),
        picUrl = v.pic_url,
        cur_avatar_box_id = v.avatar_box_id or 0,
        name = v.name,
        maxSegment = logic_lobby_my_team.GetMaxSegmentLevelCurZone(v.segment_info, zone_id),
        online = v.svr and true or false,
        level = v.level,
        top10_rate = v.top10_rate,
        kd = v.kd,
        nation = v.nation,
        mic_level = v.mic_level,
        mic_lang = v.mic_lang,
        new_label_id = v.new_label_id,
        new_label_value = v.new_label_value,
        recent_upvote = v.recent_upvote,
        evaluation_base64bin = v.evaluation_base64bin,
        registertime = v.registertime,
        rejoin_start_time = v.back_time,
        dynamic_life_time = v.dynamic_life_time
      }
      if v.metro_team_info then
        info.prestige_level = v.metro_team_info.prestige_level or 1
      else
        info.prestige_level = v.prestige_level or 1
      end
      if info.uid == teamUpNewSystem.GetSelfUID() then
        info.cur_avatar_box_id = DataMgr.roleData.cur_avatar_box_id
      end
      if info.uid == teamUpNewSystem.GetSelfUID() then
        info.nation = DataMgr.roleData.nation
      end
      if info.isLeader then
        table.insert(logic_lobby_my_team.teamMember, 1, info)
      else
        table.insert(logic_lobby_my_team.teamMember, info)
      end
      logic_lobby_my_team.InsertTeammateSex(info)
      logic_lobby_my_team.RefreshIdlePlayerByMenber(k)
    end
    EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_CONSCRIBE_UPDATE_TEAM_UI)
  end
end
function logic_lobby_my_team.InsertTeammateSex(teammate_info)
  if not teammate_info or not teammate_info.uid then
    return
  end
  local target_member
  for _, member_data in ipairs(logic_lobby_my_team.GetTeamMember()) do
    if tostring(member_data.uid) == tostring(teammate_info.uid) then
      target_member = member_data
    end
  end
  if not target_member then
    return
  end
  if tostring(teammate_info.uid) == tostring(DataMgr.roleData.uid) then
    local SocialCardSystem = require("client.slua.logic.lobby.Left.logic_social_card")
    if SocialCardSystem and SocialCardSystem.MySocialCard then
      target_member.social_sex = SocialCardSystem.MySocialCard.new_sex
      EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_CONSCRIBE_UPDATE_TEAM_UI)
    end
    return
  end
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(teammate_info.uid)
  if not profile then
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles({
      teammate_info.uid
    }, function(profile_list)
      for _, one_profile in pairs(profile_list) do
        if tostring(one_profile.uid) == tostring(teammate_info.uid) and one_profile.social_card then
          target_member.social_sex = one_profile.social_card.new_sex
        end
      end
      EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_CONSCRIBE_UPDATE_TEAM_UI)
    end, Enum_PROFILE_REPORT_CFG.TEAMUP_MEMBER_DETAIL)
    return
  elseif profile.social_card then
    target_member.social_sex = profile.social_card.new_sex
    EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_CONSCRIBE_UPDATE_TEAM_UI)
  end
end
function logic_lobby_my_team.GetMaxSegmentLevelCurZone(segment_info, zone_id)
  log_tree(bWriteLog and "[v_wllwu] logic_lobby_my_team.GetMaxSegmentLevelCurZone " .. tostring(zone_id), segment_info)
  local maxSegLevel = 101
  if not zone_id then
    log(bWriteLog and "[v_wllwu] logic_lobby_my_team.GetMaxSegmentLevelCurZone error no zone_id ")
    return maxSegLevel
  end
  if not segment_info or not segment_info[zone_id] then
    log(bWriteLog and "[v_wllwu] logic_lobby_my_team.GetMaxSegmentLevelCurZone error no segment_info ")
    return maxSegLevel
  end
  local curSegmentInfo = segment_info[zone_id] or {}
  for _, segment in pairs(curSegmentInfo) do
    if segment > maxSegLevel then
      maxSegLevel = segment
    end
  end
  log(bWriteLog and "[v_wllwu] logic_lobby_my_team.GetMaxSegmentLevelCurZone" .. tostring(maxSegLevel))
  return maxSegLevel
end
function logic_lobby_my_team.RefreshIdlePlayerByMenber(uid)
  for k, v in pairs(logic_lobby_my_team.playerList) do
    if v.uid == uid then
      logic_lobby_my_team.RefreshOnePlayer(uid)
      break
    end
  end
end
function logic_lobby_my_team.GetTeamMemberCount()
  local count = 0
  local teamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local teamInfo = teamUpNewSystem.teamInfo
  if teamInfo and teamInfo.members then
    local TableUtil = require("common.table_util")
    count = TableUtil.CountTable(teamInfo.members)
  end
  return count
end
function logic_lobby_my_team.InvitePlayerToNormalTeam(uid, option, from)
  if not option then
    log_warning("[edward][logic_lobby_my_team] logic_lobby_my_team.InvitePlayerToNormalTeam, option is nil")
    return
  end
  local TeamPlatform_Macro = require("client.slua.logic.teamup.teamplatform_macro")
  local teamPlatformInviteInfo = {
    zoneID = option.nZoneID,
    modeID = option.nModeID,
    openMic = option.nSelectMicType ~= TeamPlatform_Macro.Enum_MicVoiceOptionType.None,
    perspective = option.nPerspective,
    language = DataMgr.MatchLanguage[1]
  }
  local logic_team_up = require("client.slua.logic.teamup.logic_team_up")
  logic_team_up.team_invite_request(uid, from, nil, teamPlatformInviteInfo)
  logic_lobby_my_team.AddToTimerTick(uid)
end
function logic_lobby_my_team.AddToTimerTick(uid)
  for _, info in pairs(logic_lobby_my_team.playerList) do
    if info.uid == uid then
      info.inviteElapse = logic_lobby_my_team.inviteInterval
      if not timerHandle then
        timerHandle = timer_tick.AddTimerLoop(1, function()
          if #logic_lobby_my_team.timedownList > 0 then
            for k = #logic_lobby_my_team.timedownList, 1, -1 do
              local info = logic_lobby_my_team.timedownList[k]
              if 0 < info.inviteElapse then
                info.inviteElapse = info.inviteElapse - 1
                for k, player in pairs(logic_lobby_my_team.playerList) do
                  if player.uid == info.uid then
                    logic_lobby_my_team.playerList[k] = info
                    EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_CONSCRIBE_UPDATE_PLAYER_LIST_UI)
                    break
                  end
                end
              else
                table.remove(logic_lobby_my_team.timedownList, k)
              end
            end
          elseif timerHandle then
            timer_tick.RemoveTimer(timerHandle)
            timerHandle = nil
          end
        end, TIMER_INFINITE, 1)
      end
      local exist = false
      for _, v in pairs(logic_lobby_my_team.timedownList) do
        if v.uid == uid then
          exist = true
          break
        end
      end
      if not exist then
        table.insert(logic_lobby_my_team.timedownList, info)
      end
      break
    end
  end
end
function logic_lobby_my_team.CheckAndOpenMyTeamUI()
  local TeamPlatformSystem = require("client.slua.logic.teamup.logic_team_platform")
  local logic_team_up = require("client.slua.logic.teamup.logic_team_up")
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission() then
    if not TeamPlatformSystem.CheckShowLobbyMyXMissionTeamUI() then
      logic_team_up.team_info_request()
      TeamPlatformSystem.ShowLobbyMyXMissionTeamUI()
    end
  elseif not TeamPlatformSystem.CheckShowLobbyMyTeamUI() then
    logic_team_up.team_info_request()
    TeamPlatformSystem.ShowLobbyMyTeamUI()
  end
end
function logic_lobby_my_team.CheckAndOpenWOWMyTeamUI()
  local TeamPlatformSystem = require("client.slua.logic.teamup.logic_team_platform")
  local logic_team_up = require("client.slua.logic.teamup.logic_team_up")
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission() then
    if not TeamPlatformSystem.CheckShowLobbyMyXMissionTeamUI() then
      logic_team_up.team_info_request()
      TeamPlatformSystem.ShowLobbyMyXMissionTeamUI()
    end
  elseif not TeamPlatformSystem.CheckShowWOWLobbyMyTeamUI() then
    logic_team_up.team_info_request()
    TeamPlatformSystem.ShowWOWLobbyMyTeamUI()
  end
end
function logic_lobby_my_team.CheckAndOpenPeakMyTeamUI()
  local TeamPlatformSystem = require("client.slua.logic.teamup.logic_team_platform")
  local logic_team_up = require("client.slua.logic.teamup.logic_team_up")
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission() then
    if not TeamPlatformSystem.CheckShowLobbyMyXMissionTeamUI() then
      logic_team_up.team_info_request()
      TeamPlatformSystem.ShowLobbyMyXMissionTeamUI()
    end
  elseif not TeamPlatformSystem.CheckShowPeakLobbyMyTeamUI() then
    logic_team_up.team_info_request()
    TeamPlatformSystem.ShowPeakLobbyMyTeamUI()
  end
end
function logic_lobby_my_team.on_search_idle_player_res(res, player_list, replaced_uids, cnt)
  log(bWriteLog and "logic_lobby_my_team.on_search_idle_player_res, cnt = " .. tostring(cnt))
  log_tree(bWriteLog and "logic_lobby_my_team.on_search_idle_player_res, player_list = ", player_list)
  log_tree(bWriteLog and "logic_lobby_my_team.on_search_idle_player_res, replaced_uids = ", replaced_uids)
  if res == 0 then
    if player_list == nil or not next(player_list) then
      logic_lobby_my_team.playerList = {}
    else
      local TeamPlatformSystem = require("client.slua.logic.teamup.logic_team_platform")
      if cnt == TeamPlatformSystem.CONST_SEARCHIDLE_MINCOUNT then
        logic_lobby_my_team.ReplacePlayer(player_list, replaced_uids)
      else
        logic_lobby_my_team.AddPlayers(player_list)
        log_tree("halendeng test player_list", player_list)
      end
    end
    EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAM_UPDATE_IDLE_PLAYERS)
    EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_CONSCRIBE_UPDATE_PLAYER_LIST_UI)
  else
    log(bWriteLog and "logic_lobby_my_team.on_search_idle_player_res, res = " .. tostring(res))
    ShowNotice(res)
  end
end
function logic_lobby_my_team.AddPlayers(player_list)
  local list = {}
  for _, player in pairs(player_list) do
    local exist = false
    for k, info in pairs(logic_lobby_my_team.playerList) do
      if player.id == info.uid then
        local temp = logic_lobby_my_team.SetPlayerInfo(player)
        temp.inviteElapse = info.inviteElapse
        table.insert(list, temp)
        exist = true
        break
      end
    end
    if not exist then
      local temp = logic_lobby_my_team.SetPlayerInfo(player)
      table.insert(list, temp)
    end
  end
  logic_lobby_my_team.timedownList = {}
  logic_lobby_my_team.playerList = {}
  for _, info in pairs(list) do
    table.insert(logic_lobby_my_team.playerList, info)
    if info.inviteElapse then
      table.insert(logic_lobby_my_team.timedownList, info)
    end
  end
  EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_CONSCRIBE_UPDATE_PLAYER_LIST_UI)
end
function logic_lobby_my_team.ReplacePlayer(player_list, replaced_uids)
  local uid = replaced_uids[1] or 0
  local player = player_list[1]
  local inTeam = false
  if not player then
    return
  end
  for _, v in pairs(logic_lobby_my_team.teamMember) do
    if player.id == v.uid then
      inTeam = true
      break
    end
  end
  local replaykey = 0
  for k, info in pairs(logic_lobby_my_team.playerList) do
    if inTeam then
      if player.id == info.uid then
        table.remove(logic_lobby_my_team.playerList, k)
        EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_CONSCRIBE_UPDATE_PLAYER_LIST_UI)
        break
      end
    else
      if player.id == info.uid then
        replaykey = 0
        break
      end
      if uid == info.uid then
        replaykey = k
      end
    end
  end
  if 0 < replaykey then
    local temp = logic_lobby_my_team.SetPlayerInfo(player)
    logic_lobby_my_team.playerList[replaykey] = temp
    EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_CONSCRIBE_UPDATE_PLAYER_LIST_UI)
  end
end
function logic_lobby_my_team.SetPlayerInfo(player)
  local info = {
    uid = tonumber(player.id),
    picUrl = player.pic_url,
    cur_avatar_box_id = player.avatar_box_id or 0,
    name = player.name,
    maxSegment = player.max_segment_level,
    mic_level = player.mic_level,
    mic_lang = player.mic_lang,
    level = player.level or 1,
    top10_rate = player.top10_rate,
    kd = player.kd,
    nation = player.nation,
    label = player.label,
    play_style = player.play_style,
    new_label_id = player.new_label_id,
    new_label_value = player.new_label_value,
    prestige_level = player.prestige_level,
    recent_upvote = player.recent_upvote,
    evaluation_base64bin = player.evaluation_base64bin,
    social_sex = player.gender
  }
  return info
end
function logic_lobby_my_team.RefreshAllPlayer()
  local ConscribeHandler = require("client.network.Protocol.ConscribeHandler")
  local idlist = {}
  for k, info in pairs(logic_lobby_my_team.playerList) do
    table.insert(idlist, info.uid)
  end
  local TeamPlatformSystem = require("client.slua.logic.teamup.logic_team_platform")
  ConscribeHandler.send_search_idle_player_req(TeamPlatformSystem.CONST_SEARCHIDLE_MAXCOUNT, idlist)
end
function logic_lobby_my_team.RefreshOnePlayer(uid)
  local TeamPlatformSystem = require("client.slua.logic.teamup.logic_team_platform")
  local ConscribeHandler = require("client.network.Protocol.ConscribeHandler")
  ConscribeHandler.send_search_idle_player_req(TeamPlatformSystem.CONST_SEARCHIDLE_MINCOUNT, {uid})
end
function logic_lobby_my_team.CancelRecruit(need_no_rsp)
  if not need_no_rsp then
    logic_lobby_my_team.UpdateCancelRecruitTime()
  else
    logic_lobby_my_team.ResetCancelRecruitTime()
  end
  local ConscribeHandler = require("client.network.Protocol.ConscribeHandler")
  ConscribeHandler.send_cancel_team_conscribe_req(need_no_rsp)
end
function logic_lobby_my_team.UpdateCancelRecruitTime()
  local TimeUtil = require("client.common.time_util")
  logic_lobby_my_team.requestCancelRecruitTime = TimeUtil.GetServerTimeInSec()
  log(bWriteLog and "[v_wllwu] logic_lobby_my_team.UpdateCancelRecruitTime requestCancelRecruitTime =   " .. logic_lobby_my_team.requestCancelRecruitTime)
end
function logic_lobby_my_team.ResetCancelRecruitTime()
  log(bWriteLog and "[v_wllwu] logic_lobby_my_team.ResetCancelRecruitTime")
  logic_lobby_my_team.requestCancelRecruitTime = 0
end
function logic_lobby_my_team.IsCanSearchIdlePlayer()
  if LobbySystem.isInMatch then
    log(bWriteLog and "[v_wllwu] logic_lobby_my_team.IsCanSearchIdlePlayer return 1 ")
    return
  end
  if logic_lobby_my_team.requestCancelRecruitTime <= 0 then
    log(bWriteLog and "[v_wllwu] logic_lobby_my_team.IsCanSearchIdlePlayer return 2 ")
    return true
  end
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  if nowTime - logic_lobby_my_team.requestCancelRecruitTime >= logic_lobby_my_team.inviteInterval then
    logic_lobby_my_team.ResetCancelRecruitTime()
    log(bWriteLog and "[v_wllwu] logic_lobby_my_team.IsCanSearchIdlePlayer over time, nowTime =  " .. tostring(nowTime) .. " requestCancelRecruitTime = " .. tostring(logic_lobby_my_team.requestCancelRecruitTime))
    return true
  end
  log(bWriteLog and "[v_wllwu] logic_lobby_my_team.IsCanSearchIdlePlayer cannot request ")
  return nil
end
function logic_lobby_my_team.notify_leader_voice(inVoice, nicName)
  EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAM_LEADER_IN_VOICE, inVoice, nicName)
end
function logic_lobby_my_team.on_cancel_team_conscribe_res(res, team_id)
  if res == 0 then
    local TeamPlatformSystem = require("client.slua.logic.teamup.logic_team_platform")
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    if TeamUpNewSystem.GetTeamNum() == 1 then
      log(bWriteLog and "[v_wllwu] logic_lobby_my_team.CancelRecruit send RegisterIn")
      TeamPlatformSystem.RegisterIn()
    end
    EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAM_PLATFORM_CANCEL)
  else
    ShowNotice(res)
  end
  logic_lobby_my_team.ResetCancelRecruitTime()
end
function logic_lobby_my_team.IsPlatFormTeamLeader(uid)
  local logic_team_platform = require("client.slua.logic.teamup.logic_team_platform")
  if logic_team_platform.GetRecruitInfo() then
    local leader = logic_team_platform.recruitInfo.conscribe.leader
    if tonumber(leader) == tonumber(uid) then
      return true
    end
  end
  return false
end
function logic_lobby_my_team.GetLabel(label, index)
  local ind, config
  if label then
    ind = label[index]
  end
  if ind then
    config = CDataTable.GetTableData("SocialCardLabel", ind)
  end
  if config then
    return config.Label or ""
  else
    return ""
  end
end
function logic_lobby_my_team.GetPlayerStyle(playerStyle)
  local config
  if playerStyle then
    config = CDataTable.GetTableData("MatchStrategyConfig", playerStyle)
  end
  if config then
    return config.Name
  else
    return ""
  end
end
function logic_lobby_my_team.GetPlayerStyleImagePath(playerStyle)
  local config
  if playerStyle then
    config = CDataTable.GetTableData("MatchStrategyConfig", playerStyle)
  end
  if config then
    return config.IconPath
  else
    return ""
  end
end
function logic_lobby_my_team.GetTextBlockSignText(playerStyle, label)
  if label ~= "" then
    return string.format("%s/%s", playerStyle, label)
  else
    return string.format("%s", playerStyle)
  end
end
function logic_lobby_my_team.GetTextBLockLanguageText(micLevel, data)
  local util = require("client.slua_ui_framework.util")
  if micLevel ~= 0 then
    return util.ConvertCountryIDToDes(data.mic_lang)
  else
    return ""
  end
end
return logic_lobby_my_team