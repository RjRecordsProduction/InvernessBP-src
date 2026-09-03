local flash_team_data_handler = {}
local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
function flash_team_data_handler:IsPlayerInSquad(squadId, uid)
  local squadIdNum = tonumber(squadId)
  local uidNum = tonumber(uid)
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  local membersBrief = logic_flash_match_team:GetFlashTeamMembersById(squadIdNum)
  if not membersBrief or not membersBrief.list then
    return false
  end
  if membersBrief.list[uidNum] then
    return true
  end
  return false
end
function flash_team_data_handler:ShowJoinLimit(confirmCb, cancelCb, notShowConfirm)
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  local ownTeamInfo = logic_flash_match_team:getOwnFlashTeamInfo()
  local MAX_SQUAD_COUNT = logic_flash_match_team:GetConstConfValue("max_squad_per_player") or 20
  if ownTeamInfo and MAX_SQUAD_COUNT <= ownTeamInfo.squad_count then
    local leastTeam = logic_flash_match_team:GetLeastFlashSquad()
    if not leastTeam then
      ShowNotice(817100)
      return true
    end
    if notShowConfirm then
      ShowNotice(817041, leastTeam.name)
    else
      local LocTitle = LocUtil.GetLocalizeResStr(817093)
      local LocMsg = LocUtil.LocalizeResFormat(817041, leastTeam.name)
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.Show(2, LocTitle, LocMsg, function()
        local FlashTeamHandler = require("client.network.Protocol.FlashTeamHandler")
        FlashTeamHandler.send_quit_flash_squad_req({
          leastTeam.squad_id
        }, false)
        if confirmCb then
          confirmCb()
        end
      end, function()
        if cancelCb then
          cancelCb()
        end
      end, nil, nil, {
        showUIKey = "com_msg_small_box_slua"
      })
    end
    return true
  end
  return false
end
function flash_team_data_handler:AddInviteFriends(data)
  if not self.inviteFriendsMap then
    self.inviteFriendsMap = {}
  end
  local uidKey = tostring(data.uid)
  self.inviteFriendsMap[uidKey] = data
  local TableUtil = require("common.table_util")
  EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_INVITE_FRIENDS_CHANGE, TableUtil.CountTable(self.inviteFriendsMap))
end
function flash_team_data_handler:RemoveInviteFriends(data)
  if not self.inviteFriendsMap then
    return
  end
  local uidKey = tostring(data.uid)
  self.inviteFriendsMap[uidKey] = nil
  local TableUtil = require("common.table_util")
  EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_INVITE_FRIENDS_CHANGE, TableUtil.CountTable(self.inviteFriendsMap))
end
function flash_team_data_handler:HasInviteFriends(uid)
  if not self.inviteFriendsMap then
    return false
  end
  local uidKey = tostring(uid)
  return self.inviteFriendsMap[uidKey] ~= nil
end
function flash_team_data_handler:ClearInviteFriends()
  self.inviteFriendsMap = {}
  EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_INVITE_FRIENDS_CHANGE, 0)
end
function flash_team_data_handler:GetInviteFriends()
  if not self.inviteFriendsMap then
    return {}
  end
  local inviteFriends = {}
  for uid, info in pairs(self.inviteFriendsMap) do
    table.insert(inviteFriends, info)
  end
  return inviteFriends
end
function flash_team_data_handler:SaveInviteJoinSuccessUid(squadId, uid)
  local squadIdNum = tonumber(squadId)
  local uidNum = tonumber(uid)
  if not (squadIdNum and not (squadIdNum <= 0) and uidNum) or uidNum <= 0 then
    return
  end
  if self:IsPlayerInSquad(squadIdNum, uidNum) then
    return
  end
  self.inviteJoinSuccessUidMap = self.inviteJoinSuccessUidMap or {}
  local squadInviteUidMap = self.inviteJoinSuccessUidMap[squadIdNum]
  if not squadInviteUidMap then
    squadInviteUidMap = {}
    self.inviteJoinSuccessUidMap[squadIdNum] = squadInviteUidMap
  end
  squadInviteUidMap[tostring(uidNum)] = true
end
function flash_team_data_handler:HasInvitedJoinFlashSquad(squadId, uid)
  local squadIdNum = tonumber(squadId)
  local uidNum = tonumber(uid)
  if not (squadIdNum and not (squadIdNum <= 0) and uidNum) or uidNum <= 0 then
    return false
  end
  if self:IsPlayerInSquad(squadIdNum, uidNum) then
    return false
  end
  if not self.inviteJoinSuccessUidMap then
    return false
  end
  local squadInviteUidMap = self.inviteJoinSuccessUidMap[squadIdNum]
  if not squadInviteUidMap then
    return false
  end
  return squadInviteUidMap[tostring(uidNum)] == true
end
function flash_team_data_handler:SortInviteFriendList(squadId, friendList)
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  local teamInfo = logic_flash_match_team:GetFlashTeamSummaryById(squadId)
  if not teamInfo then
    return
  end
  local leaderUid = teamInfo.leader_uid
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  table.sort(friendList, function(a, b)
    local inTeamA = a.isInTeam and 1 or 0
    local inTeamB = b.isInTeam and 1 or 0
    if inTeamA ~= inTeamB then
      return inTeamA < inTeamB
    end
    local invitedA = a.isInvited and 1 or 0
    local invitedB = b.isInvited and 1 or 0
    if invitedA ~= invitedB then
      return invitedA < invitedB
    end
    if leaderUid then
      local isLeaderA = tonumber(a.uid) == leaderUid
      local isLeaderB = tonumber(b.uid) == leaderUid
      if isLeaderA ~= isLeaderB then
        return isLeaderA
      end
    end
    local onlineA = logic_flash_match_team:JudgeMemberIsOnline(squadId, a.uid)
    local onlineB = logic_flash_match_team:JudgeMemberIsOnline(squadId, b.uid)
    if onlineA ~= onlineB then
      return onlineA == true
    end
    local tacitA = logic_flash_match_team:GetRapportContributionById(squadId, tonumber(a.uid)) or 0
    local tacitB = logic_flash_match_team:GetRapportContributionById(squadId, tonumber(b.uid)) or 0
    if tacitA ~= tacitB then
      return tacitA > tacitB
    end
    return false
  end)
end
flash_team_data_handler.triggerRemindKey = PlayerPrefsSystem.ePlayerPrefsType.FlashTeamModeSelectTip
function flash_team_data_handler:CheckTriggerModeSelectTip(gameSelectTab)
  if self.NoConditionRemind then
    return true
  end
  if not gameSelectTab then
    return false
  end
  if gameSelectTab ~= mode_selection_macro.Enum_TabID.MatchArena and gameSelectTab ~= mode_selection_macro.Enum_TabID.RankArena and gameSelectTab ~= mode_selection_macro.Enum_TabID.MatchTxMission and gameSelectTab ~= mode_selection_macro.Enum_TabID.UGC then
    log_format("flash_team_data_handler:CheckTriggerModeSelectTip Not specific Tabs gameSelectTab:%s", gameSelectTab)
    return false
  end
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  if logic_flash_match_team:IsGuidMuted() then
    log_format("flash_team_data_handler:CheckTriggerModeSelectTip Setting IsGuidMuted")
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local TWO_WEEKS_DAYS = 14
  local canTrigger = PlayerPrefsSystem.CheckAndSaveCurrentDate_DynamicPath(flash_team_data_handler.triggerRemindKey, tostring(gameSelectTab), true, TWO_WEEKS_DAYS)
  if not canTrigger then
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local FIVE_DAYS_SECONDS = 432000
  local haveEnoughTeam = function(MainId)
    local gameModeIds = logic_flash_match_team:GetModesByID(MainId)
    local modeMap = {}
    for _, mode in ipairs(gameModeIds) do
      modeMap[mode] = true
    end
    local myTeams = logic_flash_match_team:getMyTeams()
    local count = 0
    local currentTime = TimeUtil.GetServerTimeInSec()
    for _, team in ipairs(myTeams) do
      if team.prefer_modes and next(team.prefer_modes) then
        for _, mode in ipairs(team.prefer_modes) do
          if modeMap[mode] and currentTime - team.rapport.chg_time < FIVE_DAYS_SECONDS then
            count = count + 1
            break
          end
        end
      end
    end
    log_format("flash_team_data_handler:CheckTriggerModeSelectTip HaveEnoughTeam() MainId:%s haveEnoughTeam:%s", MainId, count)
    return 3 < count
  end
  local logic_teamquick_join = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_teamquick_join)
  local teamMainID = logic_teamquick_join:GetPreferModesOver60Percent(0.4) or self.setMainMode
  if not teamMainID then
    log(bWriteLog and "flash_team_data_handler:CheckTriggerModeSelectTip \229\189\147\229\137\141\230\178\161\230\156\137\229\129\143\229\165\189\230\168\161\229\188\143 \230\178\161\230\156\137\230\142\168\232\141\144")
    return false
  end
  log_format(bWriteLog and "flash_team_data_handler:CheckTriggerModeSelectTip teamMainMode:%s", teamMainID)
  if gameSelectTab == mode_selection_macro.Enum_TabID.MatchArena and teamMainID and teamMainID == UEnums.FlashTeamGameMode.Team_Competition then
    if haveEnoughTeam(teamMainID) then
      return false
    end
    return true
  end
  if gameSelectTab == mode_selection_macro.Enum_TabID.RankArena and teamMainID and teamMainID == UEnums.FlashTeamGameMode.Team_Competition then
    if haveEnoughTeam(teamMainID) then
      return false
    end
    return true
  end
  if gameSelectTab == mode_selection_macro.Enum_TabID.MatchTxMission and teamMainID and teamMainID == UEnums.FlashTeamGameMode.Metro_Royale then
    if haveEnoughTeam(teamMainID) then
      return false
    end
    return true
  end
  if gameSelectTab == mode_selection_macro.Enum_TabID.UGC and teamMainID and teamMainID == UEnums.FlashTeamGameMode.WoW_Creative then
    if haveEnoughTeam(teamMainID) then
      return false
    end
    return true
  end
  log_format(bWriteLog and "flash_team_data_handler:CheckTriggerModeSelectTip not matched! gameSelectTab:%s teamMainID:%s", gameSelectTab, teamMainID)
  return false
end
function flash_team_data_handler:ClearTriggerModeSelectTipKey()
  local modeList = {
    mode_selection_macro.Enum_TabID.MatchArena,
    mode_selection_macro.Enum_TabID.RankArena,
    mode_selection_macro.Enum_TabID.MatchTxMission,
    mode_selection_macro.Enum_TabID.UGC
  }
  if not modeList or #modeList == 0 then
    return
  end
  for _, gameMode in ipairs(modeList) do
    PlayerPrefsSystem.SaveTableToFile_DynamicPath({}, flash_team_data_handler.triggerRemindKey, tostring(gameMode))
  end
end
function flash_team_data_handler:GMSetMainMode(mode)
  self.setMainMode = mode
end
function flash_team_data_handler:GMGetMainMode()
  return self.setMainMode
end
function flash_team_data_handler:ClearGMSetMainMode()
  self.setMainMode = nil
end
function flash_team_data_handler:GetDefaultCreateInfo(info)
  if not info then
    log("flash_team_data_handler:GetDefaultCreateInfo info is nil")
    return nil
  end
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  local logic_teamquick_res = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_teamquick_res)
  local ownTeamInfo = logic_flash_match_team:getOwnFlashTeamInfo()
  local count = 0
  if ownTeamInfo and ownTeamInfo.squad_count then
    count = ownTeamInfo.squad_count
  end
  local MAX_SQUAD_COUNT = logic_flash_match_team:GetConstConfValue("max_squad_per_player") or 20
  local defaultName = LocUtil.LocalizeResFormat(817130, DataMgr.roleData.nickName, math.min(count + 1, MAX_SQUAD_COUNT))
  local defaultColor, defaultBG, defaultBroadcast = logic_teamquick_res:GetDefaultStyle()
  local teamSettings = {
    name = info.title or defaultName,
    allow_message = true,
    need_apply = false,
    is_private = false,
    color = defaultColor,
    background = defaultBG,
    broadcast = defaultBroadcast,
    play_date = nil,
    play_time = nil
  }
  local inviteUids = {}
  if info.members then
    for _, v in ipairs(info.members) do
      if v.uid then
        table.insert(inviteUids, v.uid)
      end
    end
  end
  teamSettings.invite_uids = inviteUids
  return teamSettings
end
local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
function flash_team_data_handler:JudgeTeamIsHighlyRecommend(rcmdTeam, memberList)
  local friendCount = 0
  for k, v in ipairs(memberList) do
    local friendData = LogicFriend.GetFriendData(v.uid)
    if friendData then
      friendCount = friendCount + 1
    end
  end
  if rcmdTeam.display_score > 95 or rcmdTeam.display_score > 85 and 0 < friendCount then
    return true
  end
  return false
end
function flash_team_data_handler:ApplyJoinPreTeam(teamSummary)
  if teamSummary and teamSummary.pre_teams and next(teamSummary.pre_teams) then
    local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
    for _, pre_team in ipairs(teamSummary.pre_teams) do
      if self.curSelectModesMap and self.curSelectModesMap[pre_team.game_mode] and logic_flash_match_team:IsMyTeam(summary.squad_id) then
        local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
        TeamUpNewSystem.team_apply_request(pre_team.leader_uid, TeamUpNewSystem.E_InviteFromType.FlashTeam)
      end
    end
  end
end
function flash_team_data_handler:FindMyPreTeam()
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  local myTeams = logic_flash_match_team:getMyTeams()
  for _, team in ipairs(myTeams) do
    if team.pre_teams and next(team.pre_teams) then
      for _, pre_team in pairs(team.pre_teams) do
        if self:IsMyPreTeam(pre_team) then
          return team, pre_team
        end
      end
    end
  end
  return nil
end
function flash_team_data_handler:IsMyPreTeam(preTeam)
  if not (preTeam and preTeam.member_uids) or next(preTeam.member_uids) == nil then
    return false
  end
  for _, uid in ipairs(preTeam.member_uids) do
    if DataMgr.IsSelf(uid) then
      return true
    end
  end
  return false
end
function flash_team_data_handler:GetAllPreTeamSquad()
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  local myTeams = logic_flash_match_team:getMyTeams()
  local preTeamSquads = {}
  for _, team in ipairs(myTeams) do
    if team.pre_teams and next(team.pre_teams) then
      for _, pre_team in pairs(team.pre_teams) do
        if self:IsMyPreTeam(pre_team) then
          table.insert(preTeamSquads, team)
        end
      end
    end
  end
  return preTeamSquads
end
function flash_team_data_handler:GetPreDailyRemindCount()
  local t = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.PreTeamTips) or {}
  return tonumber(t.count) or 0
end
function flash_team_data_handler:IsOverPreTeamDailyRemindLimit()
  local MAX_DAILY_SHOW_COUNT = 3
  local count = self:GetPreDailyRemindCount()
  log_format(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:IsOverPreTeamDailyRemindLimit count:%d/%d", count, MAX_DAILY_SHOW_COUNT)
  return MAX_DAILY_SHOW_COUNT <= count
end
function flash_team_data_handler:IncreaseDailyRemindCount()
  local cur = self:GetPreDailyRemindCount()
  PlayerPrefsSystem.SaveTableToFile_N({
    count = cur + 1
  }, PlayerPrefsSystem.ePlayerPrefsType.PreTeamTips)
end
function flash_team_data_handler:ClearPreDailyRemindCount()
  PlayerPrefsSystem.SaveTableToFile_N({count = 0}, PlayerPrefsSystem.ePlayerPrefsType.PreTeamTips)
end
function flash_team_data_handler:GetAgreeStateMap(battleId)
  return self.agreeStateMap and self.agreeStateMap[battleId] or {}
end
function flash_team_data_handler:GetAgreeStateByUid(battleId, uid)
  if not self.agreeStateMap then
    self.agreeStateMap = {}
  end
  if not self.agreeStateMap[battleId] then
    self.agreeStateMap[battleId] = {}
  end
  return self.agreeStateMap[battleId][uid]
end
function flash_team_data_handler:AddPlayerAgreeState(battleId, uid)
  if not self.agreeStateMap then
    self.agreeStateMap = {}
  end
  if not self.agreeStateMap[battleId] then
    self.agreeStateMap[battleId] = {}
  end
  self.agreeStateMap[battleId][uid] = true
end
function flash_team_data_handler:ClearAgreeState(battleId)
  if self.agreeStateMap and self.agreeStateMap[battleId] then
    self.agreeStateMap[battleId] = {}
  end
end
return flash_team_data_handler