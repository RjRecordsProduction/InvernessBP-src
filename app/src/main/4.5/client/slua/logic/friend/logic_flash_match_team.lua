local logic_flash_match_team = {}
local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
local FlashTeamHandler = require("client.network.Protocol.FlashTeamHandler")
local template_feature = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.TemplateFeature")
function logic_flash_match_team:DefineAndResetData()
  self.ownTeamInfo = {}
  self.recomSquads = {}
  self.flashTeamSummary = {}
  self.flashTeamMembersSummary = {}
  self.flashTeamDetail = {}
  self.myFlashTeamApplyList = {}
  self.myFlashTeamInviteList = {}
  self.rapportChangeData = nil
  self.rapportClaimedInfo = {}
end
function logic_flash_match_team:OnInitialize()
end
function logic_flash_match_team:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_ON_BATTLE_RESULT, self.OnResultDataHandler, self)
end
function logic_flash_match_team:OnLogin(bReLogin)
end
function logic_flash_match_team:OnLogOut()
  self:RemoveAllTimer()
  self.reserveJoinPopTimer = nil
  self.reserveDesktopNotifyTimer = nil
end
function logic_flash_match_team:OnPreSwitchGameStatus(pre, next)
end
function logic_flash_match_team:OnPostSwitchGameStatus(pre, next)
  if pre ~= GameStatus.Lobby and next == GameStatus.Lobby then
    FlashTeamHandler.send_get_flash_squad_data_req()
  end
end
function logic_flash_match_team:setOwnFlashTeamInfo(info)
  self.ownTeamInfo = info
  for k, v in pairs(self.ownTeamInfo.squads) do
    self.ownTeamInfo.squads[k] = self:FilterPreTeam(v)
  end
  self:SetReserJoinPopTimer()
  EventSystem:postEvent(EVENTTYPE_FLASH_TEAM, EVENTID_TOTAL_FLASH_TEAM_CHG)
end
function logic_flash_match_team:getOwnFlashTeamInfo()
  return self.ownTeamInfo
end
function logic_flash_match_team:IsGuidMuted()
  if not self.ownTeamInfo or not self.ownTeamInfo.setting then
    return false
  end
  return self.ownTeamInfo.setting.is_guide_closed or false
end
function logic_flash_match_team:IsMyTeam(squadId)
  if not self.ownTeamInfo or not self.ownTeamInfo.squads then
    return false
  end
  for uid, squadInfo in pairs(self.ownTeamInfo.squads) do
    if squadId == uid then
      return true
    end
  end
end
function logic_flash_match_team:isTeamPinUp(id)
  if not self.ownTeamInfo or not self.ownTeamInfo.squads then
    return false
  end
  for squadId, squadInfo in pairs(self.ownTeamInfo.squads) do
    if squadId == id and squadInfo.is_pinned then
      return squadInfo.pin_time
    end
  end
  return false
end
function logic_flash_match_team:GetAllPinTeamIds()
  local teamIds = {}
  if not self.ownTeamInfo or not self.ownTeamInfo.squads then
    return teamIds
  end
  for squadId, squadInfo in pairs(self.ownTeamInfo.squads) do
    if squadInfo.is_pinned then
      table.insert(teamIds, squadId)
    end
  end
  return teamIds
end
function logic_flash_match_team:saveRecomSquad(squads)
  self.recomSquads = squads
  EventSystem:postEvent(EVENTTYPE_FLASH_TEAM, EVENTID_FLASH_TEAM_RECOM_RSP)
end
function logic_flash_match_team:getRecomSquad()
  return self.recomSquads
end
function logic_flash_match_team:getRecomSquadById(id)
  for _, squad in ipairs(self.recomSquads) do
    if squad.squad_id == id then
      return squad
    end
  end
end
function logic_flash_match_team:getRecomSquadByFilter(filterIds)
  if not filterIds or #filterIds == 0 then
    return self.recomSquads
  end
  log_tree(bWriteLog and "logic_flash_match_team:getRecomSquadByFilter ", filterIds)
  local filterMap = {}
  for _, id in ipairs(filterIds) do
    filterMap[id] = true
  end
  local filterSquads = {}
  for _, team in ipairs(self.recomSquads) do
    if team and team.prefer_modes and next(team.prefer_modes) then
      for _, modeId in ipairs(team.prefer_modes) do
        if filterMap[modeId] then
          table.insert(filterSquads, team)
          break
        end
      end
    end
  end
  if #filterSquads == 0 then
    log_format(bWriteLog and "logic_flash_match_team:getRecomSquadByFilter \230\142\168\232\141\144\231\187\147\230\158\156\230\178\161\230\156\137\231\172\166\229\144\136\230\157\161\228\187\182\231\154\132\229\176\143\233\152\159")
  end
  return filterSquads
end
function logic_flash_match_team:FilterPreTeam(TeamSummary)
  TeamSummary.pre_teams = TeamSummary.pre_teams or {}
  local selfUID = tonumber(DataMgr.roleData.uid)
  local filteedPreTeam = {}
  local filterMembers = function(membersIn)
    local newMembers = {}
    for k, v in ipairs(membersIn) do
      if v == selfUID or TeamSummary.members[v] and not TeamSummary.members[v].is_hiding then
        table.insert(newMembers, v)
      end
    end
    return newMembers
  end
  for k, v in pairs(TeamSummary.pre_teams) do
    if v.leader_uid == selfUID then
      filteedPreTeam[k] = v
    elseif TeamSummary.members[v.leader_uid] and TeamSummary.members[v.leader_uid].is_hiding then
    else
      v.member_uids = filterMembers(v.member_uids)
      filteedPreTeam[k] = v
    end
  end
  TeamSummary.pre_teams = filteedPreTeam
  return TeamSummary
end
function logic_flash_match_team:addToSaveFlashTeam(teams)
  local logic_flash_team_season = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_team_season)
  local curSeasonId = logic_flash_team_season:GetCurSeasonId()
  for uid, team in pairs(teams) do
    local seasonId = team.rapport and team.rapport.season_id
    log_format("logic_flash_match_team:addToSaveFlashTeam Reset SeasonID  seasonId:%s curSeasonId:%s", seasonId, curSeasonId)
    if seasonId and curSeasonId > seasonId then
      team.rapport.level = 0
    end
    self.flashTeamSummary[uid] = self:FilterPreTeam(team)
  end
end
function logic_flash_match_team:GetAllFlashTeamSummary()
  return self.flashTeamSummary
end
function logic_flash_match_team:GetFlashTeamSummaryById(id)
  if not self.flashTeamSummary then
    return nil
  end
  return self.flashTeamSummary[id]
end
function logic_flash_match_team:UpdateFlashTeamDetail(id, detail)
  log_tree(bWriteLog and string.format("logic_flash_match_team:UpdateFlashTeamDetail id=%s, detail", id), detail)
  if id then
    self.flashTeamDetail[id] = detail
    EventSystem:postEvent(EVENTTYPE_FLASH_TEAM, EVENTID_FLASH_TEAM_DETAIL_UPDATE, id)
  end
end
function logic_flash_match_team:GetFlashTeamDetailById(id)
  return id and self.flashTeamDetail[id]
end
function logic_flash_match_team:getFlashTeamByGMode(GMode)
  local targetMode = tonumber(GMode)
  if not targetMode then
    return nil, nil
  end
  local myTeams = self:getMyTeams()
  for _, team in ipairs(myTeams) do
    if team.pre_teams and next(team.pre_teams) then
      for _, preTeam in pairs(team.pre_teams) do
        local mainMode = self:GetModeByGMode(preTeam.game_mode)
        if (preTeam.game_mode == targetMode or mainMode == targetMode) and preTeam.max_member > preTeam.member_count then
          return team, preTeam
        end
      end
    end
  end
  return nil, nil
end
function logic_flash_match_team:GetFlashTeamMembersById(id)
  if not self.flashTeamMembersSummary then
    return nil
  end
  return self.flashTeamMembersSummary[id]
end
function logic_flash_match_team:addToSaveFlashMemberTeam(members_briefs)
  if members_briefs then
    for uid, brief in pairs(members_briefs) do
      self.flashTeamMembersSummary[uid] = brief
      EventSystem:postEvent(EVENTTYPE_FLASH_TEAM, EVENTID_FLASH_TEAM_SINGLE_CHG, uid)
    end
  end
end
function logic_flash_match_team:GetRapportContributionById(squadId, playerId)
  local team = self:GetFlashTeamSummaryById(squadId)
  if not team or not team.rapport_contributions then
    return 0
  end
  return team.rapport_contributions[playerId] or 0
end
function logic_flash_match_team:getMyTeams()
  if not self.ownTeamInfo or not self.ownTeamInfo.squads then
    return {}
  end
  local teams = {}
  for id, teamInfo in pairs(self.ownTeamInfo.squads) do
    local teamInfo = self:GetFlashTeamSummaryById(id)
    if teamInfo then
      table.insert(teams, teamInfo)
    end
  end
  return teams
end
function logic_flash_match_team:GetMyTeamIds()
  local teamIds = {}
  if not self.ownTeamInfo or not self.ownTeamInfo.squads then
    return teamIds
  end
  for id, _ in pairs(self.ownTeamInfo.squads) do
    table.insert(teamIds, id)
  end
  return teamIds
end
function logic_flash_match_team:AddMyTeam(team)
  if not (team and self.ownTeamInfo) or not self.ownTeamInfo.squads then
    return
  end
  if not self.ownTeamInfo.squads[team.squad_id] then
    self.ownTeamInfo.squad_count = self.ownTeamInfo.squad_count + 1
  end
  self.flashTeamSummary = self.flashTeamSummary or {}
  self.flashTeamSummary[team.squad_id] = self:FilterPreTeam(team)
  self.ownTeamInfo.squads[team.squad_id] = self.flashTeamSummary[team.squad_id]
  self:SetReserJoinPopTimer()
end
function logic_flash_match_team:getMyTeamsMember()
  local list = self:getMyTeams()
  local membersList = {}
  for _, team in pairs(list) do
    local summary = self.flashTeamSummary[team.squad_id]
    if summary then
      local members = self:GetFlashTeamMembersById(summary.squad_id)
      table.insert(membersList, members)
    end
  end
  return membersList
end
function logic_flash_match_team:getMaxIntimacyInSquad(id)
  local summary = self:GetFlashTeamSummaryById(id)
  if not summary or not summary.member_uids then
    return 0
  end
  local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
  local myUid = tonumber(DataMgr.roleData.uid) or 0
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local maxIntimacy = 0
  for _, uid in pairs(summary.member_uids) do
    if tonumber(uid) ~= myUid then
      local intimacy = LogicFriend.GetInnerFriendIntimacy(uid) or 0
      if maxIntimacy < intimacy then
        maxIntimacy = intimacy
      end
    end
  end
  return maxIntimacy
end
function logic_flash_match_team:isPlayerInPreTeam(id)
  local summary = self:GetFlashTeamSummaryById(id)
  if not summary or not summary.pre_teams then
    return false
  end
  local myUid = tonumber(DataMgr.roleData.uid) or 0
  for _, preTeam in pairs(summary.pre_teams) do
    if preTeam.member_uids then
      for _, uid in pairs(preTeam.member_uids) do
        if tonumber(uid) == myUid then
          return true
        end
      end
    end
  end
  return false
end
function logic_flash_match_team:hasPreTeamMatchingCurMode(id)
  local summary = self:GetFlashTeamSummaryById(id)
  if not summary or not summary.pre_teams then
    return false
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local gameMode = logic_mode_selection:GetCurSelectInfo()
  if not gameMode then
    return false
  end
  for _, preTeam in pairs(summary.pre_teams) do
    if preTeam.game_mode == gameMode then
      return true
    end
  end
  return false
end
function logic_flash_match_team:getMinVacancyInPreTeams(id)
  local summary = self:GetFlashTeamSummaryById(id)
  if not summary or not summary.pre_teams then
    return 9999
  end
  local minVacancy = 9999
  for _, preTeam in pairs(summary.pre_teams) do
    if not preTeam.is_full then
      local vacancy = (preTeam.max_member or 0) - (preTeam.member_count or 0)
      if minVacancy > vacancy then
        minVacancy = vacancy
      end
    end
  end
  return minVacancy
end
function logic_flash_match_team:getOnlineCount(id)
  local membersBrief = self:GetFlashTeamMembersById(id)
  if not membersBrief or not membersBrief.list then
    return 0
  end
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  local count = 0
  for uid, _ in pairs(membersBrief.list) do
    if DataMgr.IsSelf(uid) then
    elseif self:JudgeMemberIsOnline(id, uid) then
      count = count + 1
    end
  end
  return count
end
function logic_flash_match_team:getOnlineTeamCount()
  local myTeams = self:getMyTeams()
  local count = 0
  for _, team in ipairs(myTeams) do
    local onlineCount = self:getOnlineCount(team.squad_id)
    if 0 < onlineCount then
      count = count + 1
    end
  end
  return count
end
function logic_flash_match_team:SaveRapportClaimed(squad_id, claimInfo)
  log_tree(bWriteLog and string.format("logic_flash_match_team:SaveRapportClaimed squad_id:%s, claimInfo", squad_id), claimInfo)
  self.rapportClaimedInfo[squad_id] = claimInfo or {}
  EventSystem:postEvent(EVENTTYPE_FLASH_TEAM, EVENTID_FLASH_TEAM_CLAIM_INFO_CHG, squad_id, claimInfo)
end
function logic_flash_match_team:GetRapportClaimed(squadId)
  return self.rapportClaimedInfo[squadId]
end
function logic_flash_match_team:HasUnclaimedTacitReward(squadId)
  local claimInfo = self:GetRapportClaimed(squadId)
  if not claimInfo then
    return false
  end
  local logic_teamquick_res = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_teamquick_res)
  local teamInfo = logic_teamquick_res:GetSquadData(squadId)
  if not teamInfo or not teamInfo.rapport then
    teamInfo = self:GetFlashTeamSummaryById(squadId)
  end
  if not teamInfo or not teamInfo.rapport then
    return false
  end
  local rapport = teamInfo.rapport
  local totalScore = rapport.total
  local curLevel = rapport.level
  log_format(bWriteLog and "logic_flash_match_team:HasUnclaimedTacitReward squadId=%s curScore=%s curLevel=%s", squadId, totalScore, curLevel)
  log_tree(bWriteLog and "logic_flash_match_team:HasUnclaimedTacitReward claimInfo=", claimInfo)
  local tacitLevelConf = self:GetTeamTacitLeveConf()
  for level, levelInfo in ipairs(tacitLevelConf) do
    if curLevel <= level or totalScore < levelInfo.MaxScore then
      break
    end
    if not claimInfo[level] then
      log_format(bWriteLog and "logic_flash_match_team:HasUnclaimedTacitReward squadId=%s curScore=%s has unclaimed tacit reward level=%s", squadId, totalScore, level)
      return true
    end
  end
  return false
end
function logic_flash_match_team:GetTeamVacancyCount(squadId)
  local max_member_per_squad = self:GetConstConfValue("max_member_per_squad") or 20
  local teamInfo = squadId and self:GetFlashTeamSummaryById(squadId)
  if not teamInfo then
    return max_member_per_squad - 1
  end
  local curCount = teamInfo and teamInfo.member_count or 1
  local vacancy = max_member_per_squad - curCount
  return 0 < vacancy and vacancy or 0
end
function logic_flash_match_team:JudgeMemberIsOnline(squadId, uid)
  if DataMgr.IsSelf(uid) then
    return false
  end
  local teamInfo = self:GetFlashTeamSummaryById(squadId)
  if not teamInfo then
    return false
  end
  local status = teamInfo.members and teamInfo.members[uid]
  return status and not status.is_hiding and status.online == true
end
function logic_flash_match_team:CheckRepetitiveApply(squadId)
  if not self.CheckRepetitiveApplyMap then
    self.CheckRepetitiveApplyMap = {}
  end
  if self.CheckRepetitiveApplyMap[squadId] then
    return true
  end
  self.CheckRepetitiveApplyMap[squadId] = true
  return false
end
function logic_flash_match_team:GetTeamTacitLeveConf()
  local Conf = CDataTable.GetTable("TeamTacitLevel")
  return Conf
end
function logic_flash_match_team:GetTeamTacitLevelItem(level)
  local Data = CDataTable.GetTableData("TeamTacitLevel", level)
  return Data
end
function logic_flash_match_team:GetTeamTacitRewardConf()
  local Conf = CDataTable.GetTable("TeamTacitReward")
  return Conf
end
function logic_flash_match_team:GetSeasonTeamTacitReward(seaonId, lv)
  local Conf = self:GetTeamTacitRewardConf()
  local list = {}
  for id, item in pairs(Conf) do
    if item and item.SeasonID == seaonId then
      table.insert(list, item)
      if item.Cond1Param == lv then
        return item
      end
    end
  end
  return list
end
function logic_flash_match_team:getTacitLvByValue(value)
  if not value then
    return 0
  end
  local conf = self:GetTeamTacitLeveConf()
  if not conf then
    return 0
  end
  for _, item in pairs(conf) do
    if item and item.MinScore and item.MaxScore and value >= item.MinScore and value <= item.MaxScore then
      return item.Level or 0
    end
  end
  return 0
end
function logic_flash_match_team:getTacitConfByLv(value)
  if not value then
    return nil
  end
  local conf = self:GetTeamTacitLeveConf()
  if not conf then
    return nil
  end
  for _, item in pairs(conf) do
    if item and item.Level == value then
      return item
    end
  end
  return nil
end
function logic_flash_match_team:getTeamQuickBGSkinConf()
  local Conf = CDataTable.GetTable("TeamQuickBGSkin")
  return Conf
end
function logic_flash_match_team:getTeamQuickBGSkinItem(itemId)
  local Data = CDataTable.GetTableData("TeamQuickBGSkin", tonumber(itemId))
  return Data
end
function logic_flash_match_team:getTacitRewardByLv(value, seasonId)
  if not value then
    return nil
  end
  local conf = self:GetTeamTacitRewardConf()
  if not conf then
    return nil
  end
  for _, item in pairs(conf) do
    if item and item.Cond1Param == value and (not seasonId or item.SeasonID == seasonId) then
      return item
    end
  end
  return nil
end
function logic_flash_match_team:GetConstConfValue(key)
  local Item = CDataTable.GetTable("FlashSquadConstConf")[key]
  if not Item then
    return nil
  end
  return Item.value
end
function logic_flash_match_team:GetModeList()
  local list = CDataTable.GetTable("FlashSquadFriendMode")
  return list
end
function logic_flash_match_team:GetModeItemByModeId(modeId)
  local list = self:GetModeList()
  return list[modeId]
end
function logic_flash_match_team:InitPreferModeMap()
  local list = CDataTable.GetTable("FlashSquadFriendMode")
  self.preferModeMap = {}
  self.GameModeMap = {}
  for preferMode, modeItem in pairs(list) do
    local mainModeIdStr = modeItem.MainModeId
    if mainModeIdStr and type(mainModeIdStr) == "string" then
      local modeIds = {}
      for modeIdStr in string.gmatch(mainModeIdStr, "([^;]+)") do
        local modeId = tonumber(modeIdStr)
        if modeId then
          modeIds[#modeIds + 1] = modeId
          self.GameModeMap[modeId] = tonumber(preferMode)
        end
      end
      self.preferModeMap[tonumber(preferMode)] = modeIds
    end
  end
end
function logic_flash_match_team:GetModeByGMode(gameMode)
  if not self.GameModeMap then
    self:InitPreferModeMap()
  end
  return self.GameModeMap[tonumber(gameMode)]
end
function logic_flash_match_team:GetModesByID(teamMainID)
  local modeItem = self:GetModeItemByModeId(teamMainID)
  if not modeItem then
    return {}
  end
  local modeIds = {}
  local mainModeIdStr = modeItem.MainModeId
  for modeIdStr in string.gmatch(mainModeIdStr, "([^;]+)") do
    local modeId = tonumber(modeIdStr)
    if modeId then
      modeIds[#modeIds + 1] = modeId
    end
  end
  return modeIds
end
function logic_flash_match_team:SetRQTTeamIdx(idx)
  self.RQTTeamIdx = idx
end
function logic_flash_match_team:GetRQTTeamIdx()
  return self.RQTTeamIdx
end
function logic_flash_match_team:SetJumpTeamMainHighlight(state)
  self.JumpTeamMainHighligh = state
end
function logic_flash_match_team:GetJumpTeamMainHighlight()
  return self.JumpTeamMainHighligh
end
function logic_flash_match_team:SetCurRecomTeam(squadId, teamId)
  self.curRecomTeamId = squadId
  self.curPreTeamId = teamId
end
function logic_flash_match_team:GetCurRecomTeam()
  return self.curRecomTeamId, self.curPreTeamId
end
function logic_flash_match_team:getSquadNearRapportUpgrade(threshold)
  threshold = threshold or 20
  local teams = self:getMyTeams()
  if not teams or #teams == 0 then
    return nil
  end
  local bestSquad
  local bestRemaining = threshold + 1
  for _, teamInfo in ipairs(teams) do
    local curLevel = teamInfo.rapport and teamInfo.rapport.level or 0
    local curScore = teamInfo.rapport and teamInfo.rapport.total or 0
    if 0 < curScore then
      local curLevelConf = self:getTacitConfByLv(curLevel)
      if curLevelConf and curLevelConf.MaxScore then
        local remaining = curLevelConf.MaxScore + 1 - curScore
        if 0 < remaining and threshold >= remaining and bestRemaining > remaining then
          bestRemaining = remaining
          bestSquad = teamInfo
        end
      end
    end
  end
  return bestSquad
end
function logic_flash_match_team:getRecommendType2Squad()
  local teams = self:GetSortedMyTeams()
  if not teams or #teams == 0 then
    return nil, nil
  end
  for _, teamInfo in ipairs(teams) do
    if 0 < (teamInfo.pre_team_count or 0) and teamInfo.pre_teams then
      for teamId, preTeam in pairs(teamInfo.pre_teams) do
        if not preTeam.is_full then
          return teamInfo.squad_id, teamId
        end
      end
    end
  end
  for _, teamInfo in ipairs(teams) do
    local onlineCount = self:getOnlineCount(teamInfo.squad_id)
    if 0 < onlineCount then
      return teamInfo.squad_id, nil
    end
  end
end
function logic_flash_match_team:getRecommendType3Squad(gameMode)
  if not gameMode then
    return
  end
  local teams = self:GetSortedMyTeams()
  if not teams or #teams == 0 then
    return
  end
  for _, teamInfo in ipairs(teams) do
    if 0 < (teamInfo.pre_team_count or 0) and teamInfo.pre_teams then
      for teamId, preTeam in pairs(teamInfo.pre_teams) do
        if preTeam.game_mode == gameMode and not preTeam.is_full then
          return teamInfo.squad_id, teamId, teamInfo.name
        end
      end
    end
  end
  local logic_mode_utils = require("client.slua.logic.mode_selection.logic_mode_utils")
  local modeName = logic_mode_utils.GetModeNameByModeID(gameMode) or ""
  for _, teamInfo in ipairs(teams) do
    if teamInfo.prefer_modes then
      for _, modeId in pairs(teamInfo.prefer_modes) do
        if gameMode == modeId then
          return teamInfo.squad_id, nil, teamInfo.name
        end
      end
    end
  end
  return nil, nil, nil
end
function logic_flash_match_team:getRecommendType3FromRecomSquads(gameMode)
  if not gameMode then
    return nil, nil
  end
  local recommendSquads = self:getRecomSquad()
  if not recommendSquads or #recommendSquads == 0 then
    return nil, nil
  end
  for _, squad in ipairs(recommendSquads) do
    if 0 < (squad.pre_team_count or 0) then
      return squad.squad_id, squad.name
    end
  end
  for _, squad in ipairs(recommendSquads) do
    if squad.prefer_modes then
      for _, modeId in pairs(squad.prefer_modes) do
        if gameMode == modeId then
          return squad.squad_id, squad.name
        end
      end
    end
    if squad.social_tags and next(squad.social_tags) then
      return squad.squad_id, squad.name
    end
  end
  return nil, nil
end
function logic_flash_match_team:getRecommendType4FromRecomSquads(MainId)
  if not MainId then
    return nil, nil
  end
  local recommendSquads = self:getRecomSquad()
  if not recommendSquads or #recommendSquads == 0 then
    return nil, nil
  end
  local recommendModeIds = self:GetModesByID(MainId)
  local filterRecmdSquads = self:getRecomSquadByFilter(recommendModeIds)
  if not next(filterRecmdSquads) then
    return nil, nil
  end
  table.sort(filterRecmdSquads, function(a, b)
    if a.pre_team_count ~= b.pre_team_count then
      return a.pre_team_count > b.pre_team_count
    end
    return a.display_score > b.display_score
  end)
  local squad = filterRecmdSquads[1]
  return squad.squad_id, squad.name
end
function logic_flash_match_team:checkRecommendType6Condition()
  local MAX_SQUAD_COUNT = self:GetConstConfValue("max_squad_per_player") or 20
  local ownInfo = self:getOwnFlashTeamInfo()
  if not (ownInfo and ownInfo.squads) or not next(ownInfo.squads) then
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  local SEVEN_DAYS = 604800
  local squadCount = ownInfo.squad_count or 0
  local latestJoinTime = 0
  for _, joinInfo in pairs(ownInfo.squads) do
    local jt = joinInfo.join_time or 0
    if latestJoinTime < jt then
      latestJoinTime = jt
    end
  end
  if MAX_SQUAD_COUNT > squadCount and 0 < latestJoinTime and SEVEN_DAYS < now - latestJoinTime then
    return true
  end
  if MAX_SQUAD_COUNT <= squadCount then
    local teams = self:getMyTeams()
    if teams and 0 < #teams then
      local allStale = true
      for _, teamInfo in ipairs(teams) do
        local chgTime = teamInfo.rapport and teamInfo.rapport.chg_time or 0
        if 0 < chgTime and SEVEN_DAYS >= now - chgTime then
          allStale = false
          break
        end
      end
      if allStale then
        return true
      end
    end
  end
  return false
end
function logic_flash_match_team:getFirstRecomSquad()
  local recommendSquads = self:getRecomSquad()
  if not recommendSquads or #recommendSquads == 0 then
    return nil, nil
  end
  local first = recommendSquads[1]
  return first
end
local WeeklyRemindInviteTeam = PlayerPrefsSystem.ePlayerPrefsType.WeeklyRemindInviteTeam
function logic_flash_match_team:CheckdailyRemindInviteTeam(onlyCheck)
  local TimeUtil = require("client.common.time_util")
  local remainDays = 1
  local isRemind = PlayerPrefsSystem.CheckAndSaveCurrentDate_N(WeeklyRemindInviteTeam, onlyCheck, remainDays)
  return isRemind
end
function logic_flash_match_team:CleardailyRemindInviteTeam()
  PlayerPrefsSystem.SaveTableToFile_N({}, WeeklyRemindInviteTeam)
end
function logic_flash_match_team:SaveLastOpenTime(time)
  local TimeUtil = require("client.common.time_util")
  self.lastPollingTime = time or TimeUtil.GetServerTimeInSec()
end
function logic_flash_match_team:GetLastOpenTime()
  return self.lastPollingTime or 0
end
function logic_flash_match_team:reqMyTeamData()
  FlashTeamHandler.send_batch_get_flash_squad_summary_req()
  FlashTeamHandler.send_get_flash_squad_data_req()
end
function logic_flash_match_team:AddOperateSquadId(id)
  self.operateTeamSet = self.operateTeamSet or {}
  self.operateTeamSet[id] = true
end
function logic_flash_match_team:RemoveOperateSquadId(uid)
  if self.operateTeamSet then
    self.operateTeamSet[uid] = nil
  end
end
function logic_flash_match_team:GetSquadStateById(id)
  return self.operateTeamSet and self.operateTeamSet[id] or false
end
function logic_flash_match_team:GetSquadIdState()
  local playerList = {}
  for id, _ in pairs(self.operateTeamSet or {}) do
    table.insert(playerList, id)
  end
  return playerList
end
function logic_flash_match_team:ClearOperateSquadId()
  self.operateTeamSet = {}
end
function logic_flash_match_team:UpdatePinnedSquads(pinnedSquadIds)
  if not self.ownTeamInfo or not self.ownTeamInfo.squads then
    log(bWriteLog and "logic_flash_match_team:UpdatePinnedSquads - ownTeamInfo or squads is nil")
    return
  end
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  local pinnedSet = {}
  for _, squadId in ipairs(pinnedSquadIds or {}) do
    pinnedSet[squadId] = true
  end
  local logic_chat_channel_flash_match_team = require("client.slua.logic.lobby_chat.logic_chat_channel_flash_match_team")
  for squadId, squadInfo in pairs(self.ownTeamInfo.squads) do
    if pinnedSet[squadId] then
      if not squadInfo.is_pinned then
        squadInfo.is_pinned = true
        squadInfo.pin_time = now
      end
      logic_chat_channel_flash_match_team.SetTeamPinned(squadId)
    else
      squadInfo.is_pinned = false
      squadInfo.pin_time = 0
      logic_chat_channel_flash_match_team.RemoveTeamPinned(squadId)
    end
  end
  EventSystem:postEvent(EVENTTYPE_FLASH_TEAM, EVENTID_FLASH_TEAM_DATA_CHG)
end
local TeamRecommendTipsPopTimeDaily = PlayerPrefsSystem.ePlayerPrefsType.TeamRecommendTipsPopTimeDaily
function logic_flash_match_team:SavePopTimes(time)
  self.popTimes = time
  PlayerPrefsSystem.CheckAndSaveCurInt_N(TeamRecommendTipsPopTimeDaily, self.popTimes, false)
end
function logic_flash_match_team:GetPopTimes()
  if not self.popTimes then
    self.popTimes = PlayerPrefsSystem.CheckAndSaveCurInt_N(TeamRecommendTipsPopTimeDaily, nil, true)
  end
  return self.popTimes or 0
end
function logic_flash_match_team:ClearPopTimes()
  self.popTimes = 0
  PlayerPrefsSystem.CheckAndSaveCurInt_N(TeamRecommendTipsPopTimeDaily, {})
end
function logic_flash_match_team:SaveLastClosePopTime(time)
  self.lastPopTime = time
end
function logic_flash_match_team:GetLastClosePopTime()
  return self.lastPopTime or 0
end
local TeamRecommendTipsDaily = PlayerPrefsSystem.ePlayerPrefsType.TeamRecommendTipsDaily
function logic_flash_match_team:CheckDailyTipsIsRemind(onlyCheck)
  local isRemind = PlayerPrefsSystem.CheckAndSaveCurrentDate_N(TeamRecommendTipsDaily, onlyCheck)
  return isRemind
end
function logic_flash_match_team:ClearDailyTipsIsRemind()
  PlayerPrefsSystem.SaveTableToFile_N({}, TeamRecommendTipsDaily)
end
function logic_flash_match_team:CheckPlayerNotUsing(onlyCheck)
  local fileType = PlayerPrefsSystem.ePlayerPrefsType.TeamRecommendTipsClosed
  local notUsing = PlayerPrefsSystem.CheckAndSaveCurrentDate_N(fileType, onlyCheck, 1)
  return notUsing
end
function logic_flash_match_team:InitTeamTips(parentUILua, instantShow, GameMode)
  log(bWriteLog and "logic_flash_match_team:InitTeamTips")
  self:StopPopTeamTimer()
  if self:IsGuidMuted() then
    log(bWriteLog and "logic_flash_match_team:InitTeamTips IsGuidMuted")
    return
  end
  if not parentUILua or not parentUILua.UIRoot then
    log_format(bWriteLog and "logic_flash_match_team:InitTeamTips parentUILua or UIRoot is nil")
    return
  end
  local tipsWidget = parentUILua.UIRoot.SizeBox_RecommendedTeamTips
  local bIsDynamic = tipsWidget ~= nil
  if not bIsDynamic then
    tipsWidget = parentUILua.UIRoot.TeamPlatform_RecommendedTeam_Tips
  end
  if not tipsWidget then
    log_format(bWriteLog and "logic_flash_match_team:InitTeamTips tipsWidget is nil")
    return
  end
  if not self:CheckDailyTipsIsRemind(true) then
    log(bWriteLog and "logic_flash_match_team:InitTeamTips CheckDailyTipsIsRemind false")
    return
  end
  if instantShow then
    local TimeUtil = require("client.common.time_util")
    self:SaveLastClosePopTime(TimeUtil.GetServerTimeInSec())
  end
  local tipsLua = self:showTipsWidget(parentUILua, tipsWidget, GameMode, bIsDynamic)
  tipsLua:SetCloseCb(function()
    parentUILua:SetWidgetVisible(tipsWidget, false)
    local TimeUtil = require("client.common.time_util")
    self:SaveLastClosePopTime(TimeUtil.GetServerTimeInSec())
    if self.closeTipsCb then
      self:RemoveTimer(self.closeTipsCb)
      self.closeTipsCb = nil
    end
  end)
  parentUILua:SetWidgetVisible(tipsWidget, false)
  self:StartPopTeamTimer(tipsWidget, tipsLua, parentUILua)
end
function logic_flash_match_team:showTipsWidget(parentUILua, tipsWidget, GameMode, bIsDynamic)
  local tipsLua
  if bIsDynamic then
    local teamup_ui_configs = require("client.slua.config.ui_configs.teamup_ui_configs")
    local cfg = teamup_ui_configs.TeamPlatform_RecommendedTeam_Tips
    tipsLua = parentUILua:CreateChildWindowWithLuaAndBpPath(tipsWidget, cfg, cfg.moduleName, cfg.path, GameMode)
  else
    local UIComponentModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.UIComponentModule)
    if UIComponentModule then
      tipsLua = UIComponentModule:InitWithParentComponent(parentUILua, UIComponentModule.Config.TeamPlatform_RecommendedTeam_Tips, tipsWidget, GameMode)
    else
      log(bWriteLog and "logic_flash_match_team.showTipsWidget UIComponentModule is nil")
    end
  end
  return tipsLua
end
function logic_flash_match_team:StartPopTeamTimer(tipsWidget, tipsLua, parentUILua)
  local popInterval = self:GetConstConfValue("team_popup_trigger_interval") or 45
  local MaxPopCount = self:GetConstConfValue("team_popup_daily_limit") or 5
  local delayCloseTime = self:GetConstConfValue("team_popup_auto_close_time") or 20
  log_format(bWriteLog and "logic_flash_match_team:StartPopTeamTimer popInterval: %d, MaxPopCount: %d, delayCloseTime: %d", popInterval, MaxPopCount, delayCloseTime)
  self:StopPopTeamTimer()
  self.  self.  self.  if not (self.tipsWidget and self.tipsLua) or not self.parentUILua then
    log_format(bWriteLog and "logic_flash_match_team:StartPopTeamTimer tipsWidget or tipsLua or parentUILua is nil")
    return
  end
  local popTimes = self:GetPopTimes()
  log_format(bWriteLog and "logic_flash_match_team:StartPopTeamTimer popTimes: %d", popTimes, MaxPopCount)
  if MaxPopCount <= popTimes then
    return
  end
  local UIUtil = require("client.common.ui_util")
  self.loopPopTimer = self:AddTimerLoop(popInterval, function()
    if not self:CheckDailyTipsIsRemind(true) then
      log_format(bWriteLog and "logic_flash_match_team:StartPopTeamTimer CheckDailyTipsIsRemind false")
      self:StopPopTeamTimer()
      return
    end
    local popTimes = self:GetPopTimes()
    if popTimes >= MaxPopCount then
      log_format(bWriteLog and "logic_flash_match_team:StartPopTeamTimer Over MaxPopCount!")
      self:StopPopTeamTimer()
      return
    end
    if not (slua.isValid(self.tipsWidget) and self.parentUILua) or not slua.isValid(self.parentUILua.UIRoot) then
      log_format(bWriteLog and "logic_flash_match_team:StartPopTeamTimer TipsWidget or parentUILua is invalid")
      self:StopPopTeamTimer()
      return
    end
    local TimeUtil = require("client.common.time_util")
    if UIUtil.IsWidgetVisible(self.tipsWidget) then
      if self.showTipsTime then
        local nextCloseTime = self.showTipsTime + delayCloseTime - TimeUtil.GetServerTimeInSec()
      end
      return
    end
    self.showTipsTime = TimeUtil.GetServerTimeInSec()
    local pastTime = self.showTipsTime - self:GetLastClosePopTime()
    local RemainingTime = popInterval - pastTime
    if 0 < RemainingTime then
      return
    end
    self.tipsLua:SetWindowInfo()
    self:SavePopTimes(popTimes + 1)
    self.closeTipsCb = self:AddTimerOnce(delayCloseTime, function()
      if not self.parentUILua then
        return
      end
      self.parentUILua:SetWidgetVisible(self.tipsWidget, false)
      self:SaveLastClosePopTime(TimeUtil.GetServerTimeInSec())
      self.closeTipsCb = nil
    end)
  end, 0, 1)
end
function logic_flash_match_team:StopPopTeamTimer()
  if self.loopPopTimer then
    self:RemoveTimer(self.loopPopTimer)
    self.loopPopTimer = nil
  end
  if self.closeTipsCb then
    self:RemoveTimer(self.closeTipsCb)
    self.closeTipsCb = nil
  end
  if self.parentUILua and slua.isValid(self.parentUILua) and self.tipsWidget and slua.isValid(self.tipsWidget) then
    self.parentUILua:SetWidgetVisible(self.tipsWidget, false)
  end
  self.tipsWidget = nil
  self.tipsLua = nil
  self.parentUILua = nil
end
function logic_flash_match_team:GetRQTList()
  local result = {}
  local logic_teamquick_join = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_teamquick_join)
  local topModID = {}
  local preferModes = logic_teamquick_join:GetPreferModes()
  for i = 1, math.min(2, #preferModes) do
    table.insert(topModID, preferModes[i].mapped_mode_id)
  end
  for _, modID in pairs(topModID) do
    local data = self:GetRQT_Mode(modID)
    if data then
      table.insert(result, data)
    end
  end
  local intimacy_data = self:GetRQT_Intimacy()
  if intimacy_data then
    table.insert(result, intimacy_data)
  end
  return result
end
function logic_flash_match_team:GetRQT_Mode(modeID)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local friend_list = LogicFriend.GetFriendList(false)
  if not friend_list or #friend_list < 1 then
    log(bWriteLog and "logic_flash_match_team.GetRQT_Mode friend_list is not enough")
    return nil
  end
  local members = {}
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(DataMgr.roleData.uid)
  if profile then
    table.insert(members, profile)
  else
    log(bWriteLog and "logic_flash_match_team.GetRQT_Mode self profile is nil, uid = " .. tostring(DataMgr.roleData.uid))
  end
  local logic_teamquick_join = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_teamquick_join)
  local top3FriendsUID = logic_teamquick_join:GetTop3FriendsUIDByModeID(modeID)
  for _, uid in ipairs(top3FriendsUID) do
    local profile = logic_profile:GetLocalProfile(uid)
    if profile then
      table.insert(members, profile)
    end
  end
  local modeName = self:GetRQTModeName(modeID)
  local result = {
    title = LocUtil.LocalizeResFormat(85453, DataMgr.roleData.nickName, modeName),
    desc = LocUtil.LocalizeResFormat(85455, modeName),
    members = members,
    icon = "",
    tags = self:GetRQTTags(members, modeID),
    modeId = modeID
  }
  return result
end
function logic_flash_match_team:GetRandomFriends(count)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local friend_list = LogicFriend.GetFriendList(false)
  if not friend_list or #friend_list < 1 then
    return {}
  end
  return friend_list
end
function logic_flash_match_team:GetRQT_Intimacy()
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local intimacy_list = LogicFriend.GetIntimacyList(true) or {}
  local friend_uids = {}
  if not intimacy_list or #intimacy_list < 1 then
    log(bWriteLog and "logic_lobby_my_team.GetRQT_Intimacy intimacy_list is not enough")
    local friends = LogicFriend.GetFriendList(false)
    for _, v in pairs(friends) do
      table.insert(friend_uids, tonumber(v.uid))
    end
    if #friend_uids < 1 then
      log(bWriteLog and "logic_lobby_my_team.GetRQT_Intimacy uids is not enough")
      return nil
    end
  end
  local sorted_list = {}
  for i = 1, #intimacy_list do
    table.insert(sorted_list, intimacy_list[i])
  end
  table.sort(sorted_list, function(a, b)
    return a.intimacy > b.intimacy
  end)
  for _, uid in ipairs(friend_uids) do
    table.insert(sorted_list, {uid = uid, intimacy = 0})
  end
  local members = {}
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(DataMgr.roleData.uid)
  if profile then
    table.insert(members, profile)
  end
  for i = 1, math.min(3, #sorted_list) do
    local profile = logic_profile:GetLocalProfile(sorted_list[i].uid)
    if profile then
      table.insert(members, profile)
    else
      log(bWriteLog and "logic_lobby_my_team.GetRQT_Intimacy profile is nil, uid = " .. tostring(sorted_list[i].uid))
    end
  end
  local logic_teamquick_join = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_teamquick_join)
  local preferModes = logic_teamquick_join:GetPreferModes()
  local modeID = preferModes[1] and preferModes[1].mapped_mode_id or 101
  local modeName = self:GetRQTModeName(modeID)
  local result = {
    title = LocUtil.LocalizeResFormat(85454, DataMgr.roleData.nickName),
    desc = LocUtil.GetLocalizeResStr(85457),
    members = members,
    icon = "",
    tags = self:GetRQTTags(members, -1),
    modeId = modeID
  }
  return result
end
function logic_flash_match_team:GetRQTTags(membersProfile, modeID)
  local tags = {}
  if modeID and modeID < 0 then
    table.insert(tags, LocUtil.GetLocalizeResStr(44361))
  else
    table.insert(tags, self:GetRQTModeName(modeID))
  end
  local allMembersSocialTagsCount = {}
  for _, profile in pairs(membersProfile) do
    local hasSocialCardLabel = profile.integration_labels
    if hasSocialCardLabel then
      local label = profile.integration_labels
      for labelId, v in pairs(label) do
        local cfg = CDataTable.GetTableData("LableConfigAll", labelId)
        local bIsFlashTeamLabel = cfg and cfg.From == 2
        if bIsFlashTeamLabel then
          if allMembersSocialTagsCount[labelId] then
            allMembersSocialTagsCount[labelId] = allMembersSocialTagsCount[labelId] + 1
          else
            allMembersSocialTagsCount[labelId] = 1
          end
        end
      end
    end
  end
  local allMembersSocialTags = {}
  for label, count in pairs(allMembersSocialTagsCount) do
    table.insert(allMembersSocialTags, {label = label, count = count})
  end
  table.sort(allMembersSocialTags, function(a, b)
    return a.count > b.count
  end)
  for i = 1, math.min(3, #allMembersSocialTags) do
    if #tags < 4 then
      local cfg = CDataTable.GetTableData("LableConfigAll", allMembersSocialTags[i].label)
      if cfg then
        table.insert(tags, LocUtil.GetLocalizeResStr(cfg.LabelText))
      end
    end
  end
  return tags
end
function logic_flash_match_team:GetRQTModeName(modeID)
  local FlashSquadFriendMode = CDataTable.GetTableData("FlashSquadFriendMode", modeID)
  return FlashSquadFriendMode and LocUtil.GetLocalizeResStr(FlashSquadFriendMode.LocalizationId) or ""
end
function logic_flash_match_team:IsTeamToCreate(squad_id)
  return squad_id == 0
end
function logic_flash_match_team:ReqPreFetchApplyCnt()
  log(bWriteLog and "logic_flash_match_team:ReqPreFetchApplyCnt")
  FlashTeamHandler.send_get_flash_squad_apply_count_req()
end
function logic_flash_match_team:ReqApplyData()
  log(bWriteLog and "logic_flash_match_team:ReqApplyData")
  local lastReqTime = self.lastReqApplyDataTime or 0
  local TimeUtil = require("client.common.time_util")
  local curTime = math.floor(TimeUtil.GetServerTimeInSecWithFraction() * 1000)
  if curTime - lastReqTime < 2100 then
    log(bWriteLog and "logic_flash_match_team:ReqApplyData too frequent")
    return
  else
    self.lastReqApplyDataTime = curTime
  end
  FlashTeamHandler.send_get_all_flash_squad_apply_list_req()
  self.myFlashTeamApplyList = {}
  self._applyKeySet = {}
  self.requestedProfile = {}
end
function logic_flash_match_team:OnGetFlashSquadApplyList(applications)
  log(bWriteLog and "logic_flash_match_team:OnGetFlashSquadApplyList")
  if not applications then
    log(bWriteLog and "logic_flash_match_team:OnGetFlashSquadApplyList applications is nil")
    return
  end
  for _, squad_applications in pairs(applications) do
    local squad_id = squad_applications.squad_id
    if not squad_id then
      log(bWriteLog and "logic_flash_match_team:OnGetFlashSquadApplyList squad_id is nil")
    else
      local apply_list = squad_applications.applies or {}
      for _, application in pairs(apply_list) do
        application.        if application.apply_id then
          local key = squad_id .. "_" .. application.apply_id
          if not self._applyKeySet[key] then
            self._applyKeySet[key] = true
            table.insert(self.myFlashTeamApplyList, application)
          end
        end
      end
    end
  end
  log_tree(bWriteLog and "logic_flash_match_team:OnGetFlashSquadApplyList self.myFlashTeamApplyList:", self.myFlashTeamApplyList)
  if not self.RefreshTimerProfile then
    self.RefreshTimerProfile = self:AddTimerOnce(0.5, function()
      self:CheckApplicantProfiles(true)
      self.RefreshTimerProfile = nil
    end)
  end
end
function logic_flash_match_team:CheckApplicantProfiles(bRequestProfile)
  log(bWriteLog and "logic_flash_match_team:CheckApplicantProfiles")
  self:SetPreFetchApplyCnt(0)
  local rawList = self.myFlashTeamApplyList
  local noProfileUidList = {}
  local filteredList = {}
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  for _, application in pairs(rawList) do
    local profile = logic_profile:GetLocalProfile(application.applicant_uid)
    if not profile and not self.requestedProfile[application.applicant_uid] then
      table.insert(noProfileUidList, application.applicant_uid)
      self.requestedProfile[application.applicant_uid] = true
    elseif profile and profile.is_del then
      filteredList[application.applicant_uid] = true
      local FlashTeamHandler = require("client.network.Protocol.FlashTeamHandler")
      FlashTeamHandler.send_handle_flash_squad_apply_req(application.squad_id, application.apply_id, 2)
    end
  end
  if bRequestProfile and next(noProfileUidList) then
    log(bWriteLog and "logic_flash_match_team:CheckApplicantProfiles request profile")
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles(noProfileUidList, function(list)
      self:CheckApplicantProfiles(false)
    end, Enum_PROFILE_REPORT_CFG.FLASH_MATCH_TEAM)
  else
    log(bWriteLog and "logic_flash_match_team:CheckApplicantProfiles missing profile:" .. tostring(#noProfileUidList))
    local tempList = {}
    for _, application in pairs(self.myFlashTeamApplyList) do
      if not filteredList[application.applicant_uid] then
        table.insert(tempList, application)
      end
    end
    self.myFlashTeamApplyList = tempList
    EventSystem:postEvent(EVENTTYPE_FLASH_TEAM, EVENTID_FLASH_TEAM_APPLY_LIST_CHANGE)
  end
end
function logic_flash_match_team:ReqInviteData()
  log(bWriteLog and "logic_flash_match_team:ReqInviteData")
  FlashTeamHandler.send_get_flash_squad_invite_list_req()
end
function logic_flash_match_team:OnGetFlashSquadInviteList(invites)
  self.myFlashTeamInviteList = invites
  local missingSummaryIds = {}
  local missingSet = {}
  for _, invite in pairs(invites) do
    local squad_id = invite.squad_id
    if squad_id and not self:GetFlashTeamSummaryById(squad_id) and not missingSet[squad_id] then
      missingSet[squad_id] = true
      table.insert(missingSummaryIds, squad_id)
    end
  end
  if 0 < #missingSummaryIds then
    self.inviteMissingSummaryIds = missingSummaryIds
    log(bWriteLog and "logic_flash_match_team:OnGetFlashSquadInviteList fetch missing summaries count:" .. #missingSummaryIds)
    FlashTeamHandler.send_batch_get_flash_squad_summary_req(missingSummaryIds)
  end
  EventSystem:postEvent(EVENTTYPE_FLASH_TEAM, EVENTID_FLASH_TEAM_APPLY_LIST_CHANGE)
end
function logic_flash_match_team:CheckInvitorProfiles(bRequestProfile)
  log(bWriteLog and "logic_flash_match_team:CheckInvitorProfiles")
  local rawList = self.myFlashTeamInviteList
  local noProfileUidList = {}
  local hasProfileList = {}
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  for _, invite in pairs(rawList) do
    local profile = logic_profile:GetLocalProfile(invite.inviter_uid)
    if not profile then
      table.insert(noProfileUidList, invite.inviter_uid)
    elseif not profile.is_del then
      table.insert(hasProfileList, invite)
    else
      log(bWriteLog and "logic_flash_match_team:CheckInvitorProfiles delete invite due to profile.is_del")
      FlashTeamHandler.send_delete_flash_squad_invite_req(invite.inviter_uid, invite.squad_id)
    end
  end
  if bRequestProfile and next(noProfileUidList) then
    log(bWriteLog and "logic_flash_match_team:CheckInvitorProfiles request profile")
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles(noProfileUidList, function(list)
      self:CheckInvitorProfiles(false)
    end, Enum_PROFILE_REPORT_CFG.FLASH_MATCH_TEAM)
  else
    self.myFlashTeamInviteList = hasProfileList
    EventSystem:postEvent(EVENTTYPE_FLASH_TEAM, EVENTID_FLASH_TEAM_APPLY_LIST_CHANGE)
  end
end
function logic_flash_match_team:OnFlashSquadApplyNotify(application_info)
  table.insert(self.myFlashTeamApplyList, application_info)
  EventSystem:postEvent(EVENTTYPE_FLASH_TEAM, EVENTID_FLASH_TEAM_APPLY_LIST_CHANGE)
  self:ReqApplyData()
end
function logic_flash_match_team:OnFlashSquadInviteNotify(inviteInfo)
  if not inviteInfo then
    log(bWriteLog and "logic_flash_match_team:OnFlashSquadInviteNotify inviteInfo is nil")
    return
  end
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  local selfStatus = PlayerStatusMgr:GetStatusData(tonumber(DataMgr.roleData.uid))
  local PlayerStatusUtil = require("client.slua.logic.player_status.PlayerStatusUtil")
  if selfStatus and PlayerStatusUtil.IsBusy(selfStatus) then
    log(bWriteLog and "logic_flash_match_team:OnFlashSquadInviteNotify ignored, self is busy(do not disturb)")
    return
  end
  local inviter_uid = inviteInfo.inviter_uid
  local squad_id = inviteInfo.squad_id
  local timestamp = inviteInfo.timestamp
  for _, invite in pairs(self.myFlashTeamInviteList) do
    if invite.inviter_uid == inviter_uid and invite.squad_id == squad_id then
      invite.timestamp = math.max(invite.timestamp, timestamp)
      return
    end
  end
  table.insert(self.myFlashTeamInviteList, {
    inviter_uid = inviter_uid,
    squad_id = squad_id,
      })
  if not self:GetFlashTeamSummaryById(squad_id) then
    FlashTeamHandler.send_batch_get_flash_squad_summary_req({squad_id})
  end
end
function logic_flash_match_team:OnHandleFlashSquadApply(ret, squad_id, apply_id)
  log(bWriteLog and "logic_flash_match_team:OnHandleFlashSquadApply ret:" .. tostring(ret) .. ", apply_id:" .. tostring(apply_id))
  if ret ~= 0 then
    local ret2notice = {
      [441003] = 525110,
      [441020] = 817101,
      [441033] = 817100,
      [441030] = 200051,
      [441031] = 200051,
      [441032] = 200051
    }
    ShowNotice(ret2notice[ret] or ret)
    if ret == 441030 or ret == 441032 or ret == 441031 then
    else
      return
    end
  end
  if squad_id == -1 or apply_id == -1 then
    self.myFlashTeamApplyList = {}
    self._applyKeySet = {}
  else
    for index, application in pairs(self.myFlashTeamApplyList) do
      if application.squad_id == squad_id and application.apply_id == apply_id then
        table.remove(self.myFlashTeamApplyList, index)
        break
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_FLASH_TEAM, EVENTID_FLASH_TEAM_APPLY_LIST_CHANGE)
end
function logic_flash_match_team:OnDeleteFlashSquadInvite(ret, inviter_id, squad_id)
  log(bWriteLog and "logic_flash_match_team:OnDeleteFlashSquadInvite ret:" .. tostring(ret) .. ", inviter_id:" .. tostring(inviter_id) .. ", squad_id:" .. tostring(squad_id))
  if ret ~= 0 then
    ShowNotice(ret)
    return
  end
  if inviter_id == -1 then
    self.myFlashTeamInviteList = {}
    EventSystem:postEvent(EVENTTYPE_FLASH_TEAM, EVENTID_FLASH_TEAM_APPLY_LIST_CHANGE)
    return
  end
  for index, invite in pairs(self.myFlashTeamInviteList) do
    if invite.inviter_uid == inviter_id and invite.squad_id == squad_id then
      table.remove(self.myFlashTeamInviteList, index)
    end
  end
  EventSystem:postEvent(EVENTTYPE_FLASH_TEAM, EVENTID_FLASH_TEAM_APPLY_LIST_CHANGE)
end
function logic_flash_match_team:OnJoinFlashSquad(squad_id, squad_summary, apply_id)
  log(bWriteLog and "logic_flash_match_team:OnJoinFlashSquad squad_id:" .. tostring(squad_id) .. ", apply_id:" .. tostring(apply_id))
  local removeCnt = 0
  local newList = {}
  for index, application in pairs(self.myFlashTeamInviteList) do
    if application.squad_id == squad_id then
    else
      table.insert(newList, application)
    end
  end
  self.myFlashTeamInviteList = newList
  if apply_id and 0 < apply_id then
    ShowNotice(817046)
  else
    ShowNotice(817045)
    if not squad_summary then
      printf("[ERROR] logic_flash_match_team:OnJoinFlashSquad squad_summary is nil on direct join, squad_id:%s", tostring(squad_id))
    else
      self:AddMyTeam(squad_summary)
      EventSystem:postEvent(EVENTTYPE_FLASH_TEAM, EVENTID_FLASH_TEAM_DATA_CHG)
    end
  end
  EventSystem:postEvent(EVENTTYPE_FLASH_TEAM, EVENTID_FLASH_TEAM_APPLY_LIST_CHANGE)
end
function logic_flash_match_team:GetFlashTeamApplyList()
  local list = {}
  for _, application in pairs(self.myFlashTeamApplyList) do
    table.insert(list, application)
  end
  return list
end
function logic_flash_match_team:SetFlashTeamApplyList(list)
  self.myFlashTeamApplyList = list
end
function logic_flash_match_team:GetFlashTeamApplyCnt()
  local TableUtil = require("common.table_util")
  if self.myFlashTeamApplyList and next(self.myFlashTeamApplyList) then
    return TableUtil.CountTable(self.myFlashTeamApplyList)
  else
    return self.PreFetchApplyCnt or 0
  end
end
function logic_flash_match_team:SetPreFetchApplyCnt(cnt)
  log(bWriteLog and "logic_flash_match_team:SetPreFetchApplyCnt cnt:" .. tostring(cnt))
  self.PreFetchApplyCnt = cnt
  EventSystem:postEvent(EVENTTYPE_FLASH_TEAM, EVENTID_FLASH_TEAM_APPLY_LIST_CHANGE)
end
function logic_flash_match_team:GetFlashTeamInviteList()
  local list = {}
  local TableUtil = require("common.table_util")
  for _, application in pairs(self.myFlashTeamInviteList) do
    local squad_id = application.squad_id
    local bHasSummary = self:GetFlashTeamSummaryById(squad_id)
    if bHasSummary then
      table.insert(list, application)
    elseif TableUtil.Contains(self.inviteMissingSummaryIds, squad_id) then
      log(bWriteLog and "logic_flash_match_team:GetFlashTeamInviteList missing summary for squad_id:" .. tostring(squad_id))
    else
      table.insert(list, application)
    end
  end
  return list
end
function logic_flash_match_team:SetFlashTeamInviteList(list)
  self.myFlashTeamInviteList = list
end
function logic_flash_match_team:GetFlashTeamInviteCnt()
  local TableUtil = require("common.table_util")
  return TableUtil.CountTable(self.myFlashTeamInviteList)
end
function logic_flash_match_team:ClearMyFlashTeamApplyList(squad_id)
  log(bWriteLog and "logic_flash_match_team:ClearMyFlashTeamApplyList squad_id:" .. tostring(squad_id))
  if squad_id then
    local newList = {}
    for key, application in pairs(self.myFlashTeamApplyList) do
      if application.squad_id == squad_id then
      else
        table.insert(newList, application)
      end
    end
    self.myFlashTeamApplyList = newList
  else
    self.myFlashTeamApplyList = {}
    self._applyKeySet = {}
  end
  EventSystem:postEvent(EVENTTYPE_FLASH_TEAM, EVENTID_FLASH_TEAM_APPLY_LIST_CHANGE)
end
function logic_flash_match_team:ClearMyFlashTeamInviteList(squad_id, send_delete_req)
  log(bWriteLog and "logic_flash_match_team:ClearMyFlashTeamInviteList squad_id:" .. tostring(squad_id))
  if squad_id then
    local newList = {}
    local FlashTeamHandler = require("client.network.Protocol.FlashTeamHandler")
    for _, invite in pairs(self.myFlashTeamInviteList) do
      if invite.squad_id ~= squad_id then
        table.insert(newList, invite)
      elseif send_delete_req then
        FlashTeamHandler.send_delete_flash_squad_invite_req(invite.inviter_uid, invite.squad_id)
      end
    end
    self.myFlashTeamInviteList = newList
  else
    self.myFlashTeamInviteList = {}
  end
  EventSystem:postEvent(EVENTTYPE_FLASH_TEAM, EVENTID_FLASH_TEAM_APPLY_LIST_CHANGE)
end
function logic_flash_match_team:OpenApplicationPopup(tab, subTab)
  local selectTab = tab or 1
  local selectSubTab = subTab
  local bIsLeader = self:IsAnyLeader()
  if bIsLeader then
    if not selectSubTab then
      local bHasApply = self.myFlashTeamApplyList and next(self.myFlashTeamApplyList)
      local bHasInvite = self.myFlashTeamInviteList and next(self.myFlashTeamInviteList)
      if bHasApply then
        selectSubTab = 1
      elseif bHasInvite then
        selectSubTab = 2
      end
    end
    UIManager.ShowUI(UIManager.UI_Config.TeamQuick_TeamApplicationLeader_Popup, selectTab, selectSubTab)
  else
    UIManager.ShowUI(UIManager.UI_Config.TeamQuick_TeamApplication_Popup, selectTab)
  end
end
function logic_flash_match_team:IsAnyLeader()
  if not self.ownTeamInfo or not self.ownTeamInfo.squads then
    return true
  end
  for id, teamInfo in pairs(self.ownTeamInfo.squads) do
    if teamInfo.role and teamInfo.role == 1 then
      return true
    end
  end
  return false
end
function logic_flash_match_team:AgreeAllApplyNew()
  log(bWriteLog and "logic_flash_match_team:AgreeAllApplyNew")
  local FlashTeamHandler = require("client.network.Protocol.FlashTeamHandler")
  FlashTeamHandler.send_handle_flash_squad_apply_req(-1, -1, 3)
end
function logic_flash_match_team:IgnoreAllApplyNew()
  log(bWriteLog and "logic_flash_match_team:IgnoreAllApplyNew")
  local FlashTeamHandler = require("client.network.Protocol.FlashTeamHandler")
  FlashTeamHandler.send_handle_flash_squad_apply_req(-1, -1, 4)
end
function logic_flash_match_team:AgreeAllApply()
  log(bWriteLog and "logic_flash_match_team:AgreeAllApply")
  for _, application in pairs(self.myFlashTeamApplyList) do
    FlashTeamHandler.send_handle_flash_squad_apply_req(application.squad_id, application.apply_id, 1)
  end
end
function logic_flash_match_team:IgnoreAllApply()
  log(bWriteLog and "logic_flash_match_team:IgnoreAllApply")
  for _, application in pairs(self.myFlashTeamApplyList) do
    FlashTeamHandler.send_handle_flash_squad_apply_req(application.squad_id, application.apply_id, 2)
  end
end
function logic_flash_match_team:AgreeAllInvite()
  log(bWriteLog and "logic_flash_match_team:AgreeAllInvite")
  for _, application in pairs(self.myFlashTeamInviteList) do
    FlashTeamHandler.send_join_flash_squad_req(application.squad_id, 4)
  end
end
function logic_flash_match_team:IgnoreAllInvite()
  log(bWriteLog and "logic_flash_match_team:IgnoreAllInvite")
  FlashTeamHandler.send_delete_flash_squad_invite_req(-1, -1, true)
end
function logic_flash_match_team:GetLeastFlashSquad()
  log(bWriteLog and "logic_flash_match_team:QuitLeastFlashSquad")
  local myTeams = self:getMyTeams()
  local leastSquad
  local myContributeScore = 99999999
  for key, teamInfo in pairs(myTeams) do
    local myTeamScore = self:GetRapportContributionById(teamInfo.squad_id, tonumber(DataMgr.roleData.uid)) or 0
    if myContributeScore > myTeamScore then
      myContributeScore = myTeamScore
      leastSquad = teamInfo
    end
  end
  if leastSquad then
    log(bWriteLog and "logic_flash_match_team:QuitLeastFlashSquad leastSquadID:" .. tostring(leastSquad.squad_id) .. ", myContributeScore:" .. tostring(myContributeScore))
  end
  return leastSquad
end
function logic_flash_match_team:OnResultDataHandler(_, __, resultData)
  if not resultData or not resultData.flash_squad_rapport_changes then
    log(bWriteLog and "logic_flash_match_team:OnResultDataHandler resultData is nil or missing flash_squad_rapport_changes")
    return
  end
  log_tree(bWriteLog and "logic_flash_match_team:OnResultDataHandler flash_squad_rapport_changes", resultData.flash_squad_rapport_changes)
  self.rapportChangeData = {}
  self.rapportChangeData.flash_squad_rapport_changes = resultData.flash_squad_rapport_changes
  for i, change in ipairs(self.rapportChangeData.flash_squad_rapport_changes) do
    local teamInfo = self:GetFlashTeamSummaryById(change.squad_id)
    log_tree(bWriteLog and "logic_flash_match_team:OnResultDataHandler teamInfo", teamInfo)
    if teamInfo then
      local rapport = teamInfo.rapport and teamInfo.rapport.total or 0
      local level = teamInfo.rapport and teamInfo.rapport.level or 0
      local rapportLevelBefore = level
      local rapportLevelAfter = self:getTacitLvByValue(rapport + change.delta)
      if rapportLevelBefore < rapportLevelAfter then
        self.rapportChangeData.is_level_up = true
        break
      else
        self.rapportChangeData.is_level_up = false
      end
    end
  end
end
function logic_flash_match_team:GetRapportChangeData()
  return self.rapportChangeData
end
function logic_flash_match_team:ClearRapportChangeData()
  log(bWriteLog and "logic_flash_match_team:ClearRapportChangeData")
  self.rapportChangeData = nil
end
function logic_flash_match_team:GetModeMapName(subGameMode, notShowPerson, isShowDetailMap)
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local logic_recruit_filter_new = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_recruit_filter_new)
  local logic_mode_utils = require("client.slua.logic.mode_selection.logic_mode_utils")
  if not subGameMode then
    _, subGameMode = logic_mode_selection:GetCurSelectInfo()
  end
  local tabId
  local tabList = logic_mode_selection:GetMenuListByViewID(subGameMode)
  if tabList and 0 < #tabList then
    tabId = tabList[1]
  else
    tabId = logic_mode_utils.GetDefaultTabId()
    log_error(bWriteLog and "[v_wllwu]  Chat_Recruit_Panel_New:UpdateModeName tabId is nil, and viewId = " .. tostring(subGameMode))
  end
  local modeName = logic_recruit_filter_new:GetFilterTabName(tabId)
  if not notShowPerson then
    local curSelectModeInfo = logic_mode_selection:GetFilterInfo()
    local viewInfo = logic_mode_selection:GetSubviewInfoBySubviewID(subGameMode)
    if viewInfo then
      local personNameId = curSelectModeInfo.perspective or 10053
      modeName = string.format("%s(%s)", modeName, LocUtil.GetLocalizeResStr(personNameId))
    end
  end
  local mapInfo = logic_mode_selection:GetSubviewInfoBySubviewID(subGameMode)
  local mapName
  if mapInfo then
    mapName = isShowDetailMap and LocUtil.LocalizeResFormat(mapInfo.aux_name) or LocUtil.LocalizeResFormat(mapInfo.title)
  end
  return modeName, mapName
end
function logic_flash_match_team:ShowFlashTeamHelp(defaultType)
  log_format(bWriteLog and "logic_flash_match_team:ShowFlashTeamHelp defaultType=%s", defaultType)
  local flash_match_team_const = require("client.slua.logic.friend.flash_match_team_const")
  defaultType = defaultType or flash_match_team_const.FlashTeamHelpType.BaseRule
  local E_StyleType = require("client.slua.umg.common.questionmark.questionmark_style_cfg").E_StyleType
  local helpConfig = {
    [flash_match_team_const.FlashTeamHelpType.BaseRule] = {
      tab = LocUtil.GetLocalizeResStr(817200),
      title = LocUtil.GetLocalizeResStr(817200),
      textInfo = {
        {
          type = E_StyleType.TEXT,
          content1 = LocUtil.GetLocalizeStrConcatenation(817179)
        }
      }
    },
    [flash_match_team_const.FlashTeamHelpType.TeamLobby] = {
      tab = LocUtil.GetLocalizeResStr(817044),
      title = LocUtil.GetLocalizeResStr(817044),
      textInfo = {
        {
          type = E_StyleType.TEXT,
          content1 = LocUtil.GetLocalizeStrConcatenation(817196)
        }
      }
    },
    [flash_match_team_const.FlashTeamHelpType.RapportLevel] = {
      tab = LocUtil.GetLocalizeResStr(817177),
      title = LocUtil.GetLocalizeResStr(817177),
      textInfo = {
        {
          type = E_StyleType.TEXT,
          content1 = LocUtil.GetLocalizeStrConcatenation(817178)
        }
      }
    },
    [flash_match_team_const.FlashTeamHelpType.CreateTeam] = {
      tab = LocUtil.GetLocalizeResStr(817043),
      title = LocUtil.GetLocalizeResStr(817043),
      textInfo = {
        {
          type = E_StyleType.TEXT,
          content1 = LocUtil.GetLocalizeStrConcatenation(817195)
        }
      }
    },
    [flash_match_team_const.FlashTeamHelpType.PrivacySetting] = {
      tab = LocUtil.GetLocalizeResStr(817026),
      title = LocUtil.GetLocalizeResStr(817026),
      textInfo = {
        {
          type = E_StyleType.TEXT,
          content1 = LocUtil.GetLocalizeStrConcatenation(817180)
        }
      }
    }
  }
  UIManager.ShowUI(UIManager.UI_Config.common_questionmark_style_two, helpConfig, nil, defaultType)
end
function logic_flash_match_team:proc_flash_squad_create_arrange_rsp(squad_id, arrange_id, mode_name_id, arrange_time)
  log(bWriteLog and string.format("logic_flash_match_team:proc_flash_squad_create_arrange_rsp squad_id:%s, arrange_id:%s, mode_name_id:%s, arrange_time:%s)", squad_id, arrange_id, mode_name_id, arrange_time))
  if not (squad_id and arrange_id and mode_name_id) or not arrange_time then
    log(bWriteLog and "logic_flash_match_team:proc_flash_squad_create_arrange_rsp param is nil")
    return
  end
  if not self.ownTeamInfo.squads or not self.ownTeamInfo.squads[squad_id] then
    log(bWriteLog and "logic_flash_match_team:proc_flash_squad_create_arrange_rsp teamInfo is nil")
    return
  end
  self.ownTeamInfo.squads[squad_id].arranges = self.ownTeamInfo.squads[squad_id].arranges or {}
  self.ownTeamInfo.squads[squad_id].arranges[arrange_id] = {
    mode_name_id = mode_name_id,
    arrange_time = arrange_time,
    creator_uid = tonumber(DataMgr.roleData.uid),
    likes = {
      0,
      0,
      0
    }
  }
  local teamSum = self:GetFlashTeamMembersById(squad_id)
  if teamSum then
    teamSum.arranges = teamSum.arranges or {}
    teamSum.arranges[arrange_id] = self.ownTeamInfo.squads[squad_id].arranges[arrange_id]
  end
  self:SetReserJoinPopTimer()
  EventSystem:postEvent(EVENTTYPE_FLASH_TEAM, EVENTID_FLASH_TEAM_RESERVE_CHG, teamSum)
end
function logic_flash_match_team:proc_flash_squad_like_arrange_rsp(squad_id, arrange_id, like_total)
  if not self.ownTeamInfo.squads or not self.ownTeamInfo.squads[squad_id] then
    log(bWriteLog and "logic_flash_match_team:proc_flash_squad_create_arrange_rsp teamInfo is nil")
    return
  end
  local teamInfo = self.ownTeamInfo.squads[squad_id]
  if teamInfo and teamInfo.arranges and teamInfo.arranges[arrange_id] then
    teamInfo.arranges[arrange_id].likes = like_total
  end
  local teamSum = self:GetFlashTeamMembersById(squad_id)
  if teamSum and teamSum.arranges and teamSum.arranges[arrange_id] then
    teamSum.arranges[arrange_id].likes = like_total
  end
  EventSystem:postEvent(EVENTTYPE_FLASH_TEAM, EVENTID_FLASH_TEAM_RESERVE_LIKE, arrange_id)
end
function logic_flash_match_team:SetReserJoinPopTimer()
  log(bWriteLog and "logic_flash_match_team:SetReserJoinPopTimer")
  if self.reserveJoinPopTimer then
    self:RemoveTimer(self.reserveJoinPopTimer)
    self.reserveJoinPopTimer = nil
  end
  if self.reserveDesktopNotifyTimer then
    self:RemoveTimer(self.reserveDesktopNotifyTimer)
    self.reserveDesktopNotifyTimer = nil
  end
  if not self.ownTeamInfo or not self.ownTeamInfo.squads then
    return
  end
  local reserveId = -1
  local reserveInfo
  local teamid = -1
  local time_util = require("client.common.time_util")
  local serverTime = time_util.GetServerTimeInSec()
  for key, squad in pairs(self.ownTeamInfo.squads) do
    local teamInfo = self:GetFlashTeamSummaryById(key)
    if teamInfo and teamInfo.arranges then
      for akey, arrange in pairs(teamInfo.arranges) do
        if not reserveInfo then
          reserveId = akey
          reserveInfo = arrange
          teamid = key
        elseif reserveInfo.arrange_time < arrange.arrange_time and serverTime < arrange.arrange_time then
          reserveId = akey
          reserveInfo = arrange
          teamid = key
        end
      end
    end
  end
  if 0 <= reserveId then
    local timeUntilReserve = reserveInfo.arrange_time - serverTime
    if timeUntilReserve <= 0 and -1 < timeUntilReserve then
      self:ShowReserveJoinPop(teamid, reserveId, reserveInfo)
      return
    elseif timeUntilReserve <= 0 then
      return
    end
    local notifyAdvanceTime = 300
    if timeUntilReserve > notifyAdvanceTime then
      self.reserveDesktopNotifyTimer = self:AddTimer(timeUntilReserve - notifyAdvanceTime, function()
        self.reserveDesktopNotifyTimer = nil
        self:ShowReserveDesktopNotify(teamid, reserveId, reserveInfo)
      end)
    end
    log(string.format("logic_flash_match_team:SetReserJoinPopTimer teamid:%s reserveId:%s timeUntilReserve:%s", teamid, reserveId, timeUntilReserve))
    self.reserveJoinPopTimer = self:AddTimer(timeUntilReserve, function()
      self.reserveJoinPopTimer = nil
      self:ShowReserveJoinPop(teamid, reserveId, reserveInfo)
    end)
  end
  EventSystem:postEvent(EVENTTYPE_FLASH_TEAM, EVENTID_FLASH_TEAM_RESERVE_REFRESH)
end
function logic_flash_match_team:ShowReserveDesktopNotify(teamid, reserveId, reserveInfo)
  log_format(bWriteLog and "logic_flash_match_team:ShowReserveDesktopNotify teamid:%s, reserveId:%s", teamid, reserveId)
  local teamSummary = self:GetFlashTeamSummaryById(teamid)
  if not teamSummary then
    log(bWriteLog and "logic_flash_match_team:ShowReserveDesktopNotify teamSummary is nil")
    return
  end
  local modeName = LocUtil.GetLocalizeResStr(reserveInfo.mode_name_id or 0)
  local notifyMsg = LocUtil.LocalizeResFormat(817250, modeName)
  local jumpUrl = string.format("game://?module=100030?deeplink=igamesdk%%3A%%2F%%2Fmeemo%%2Fnotify%%3F%%26type%%3D0%%26game_scene%%3DFlashTeamReserve%%26squad_id%%3D%s%%26reserve_id%%3D%s%%26msg%%3D%s", tostring(teamid), tostring(reserveId), notifyMsg)
  log_format(bWriteLog and "logic_flash_match_team:ShowReserveDesktopNotify jumpUrl:%s", jumpUrl)
  GlobalData.JumpUrl(jumpUrl)
end
function logic_flash_match_team:ShowReserveJoinPop(teamid, reserveId, reserveInfo)
  log(bWriteLog and "logic_flash_match_team:ShowReserveJoinPop teamid:%s, reserveId:%s", teamid, reserveId)
  if not GameStatus.IsInLobbyOrMainCity() then
    log(bWriteLog and "logic_flash_match_team:ShowReserveJoinPop not in lobby or main city")
    return
  end
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission() then
    log(bWriteLog and "logic_flash_match_team:ShowReserveJoinPop in xmisssion")
    return
  end
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eFlashTeamReserveMute) or {}
  if saveData and saveData.noReserveTime and serverTime < saveData.noReserveTime then
    log(bWriteLog and "logic_flash_match_team:ShowReserveJoinPop noReserveTime is greater than serverTime")
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.TeamQuick_Reserve_Tips_UIBP, teamid, reserveId, reserveInfo)
end
function logic_flash_match_team:proc_flash_squad_bond_notify(TeamData)
  if self.DelayOpenTeamPop then
    self:RemoveTimer(self.DelayOpenTeamPop)
    self.DelayOpenTeamPop = nil
  end
  self.DelayOpenTeamPop = self:AddTimerOnce(2, function()
    local ui_show_queue_config = require("client.common.uibase.ui_show_queue_config")
    local queueConfig = ui_show_queue_config.GetParamTable(10150)
    UIManager.ShowUI(UIManager.UI_Config.TeamQuick_Invite_Tips_UIBP, TeamData, queueConfig)
  end)
end
local GetMaxArrangeId = function(summary)
  local maxArrangeId = -1
  for key, arrange in pairs(summary.arranges) do
    if key > maxArrangeId then
      maxArrangeId = key
    end
  end
  return maxArrangeId
end
function logic_flash_match_team:HasNewArrange(squadId)
  local teamInfo = self:GetFlashTeamSummaryById(squadId)
  if not teamInfo or not teamInfo.arranges then
    return false
  end
  local maxArrangeId = GetMaxArrangeId(teamInfo)
  if maxArrangeId < 0 then
    return false
  end
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.PreTeamArrangeRead) or {}
  if not saveData[squadId] or maxArrangeId > saveData[squadId] then
    return true
  end
  return false
end
function logic_flash_match_team:MarkArrangeRead(squadId)
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.PreTeamArrangeRead) or {}
  local teamInfo = self:GetFlashTeamSummaryById(squadId)
  if not teamInfo or not teamInfo.arranges then
    return
  end
  local maxArrangeId = GetMaxArrangeId(teamInfo)
  if maxArrangeId < 0 then
    return
  end
  saveData[squadId] = maxArrangeId
  PlayerPrefsSystem.SaveTableToFile_N(PlayerPrefsSystem.ePlayerPrefsType.PreTeamArrangeRead, saveData)
end
local logic_flash_match_team_sort = require("client.slua.logic.friend.logic_flash_match_team_sort")
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local MergePatialTool = require("GameLua.Mod.SocialIsland.GamePlay.MergePatialTool")
MergePatialTool.Mixin(CModuleBase, logic_flash_match_team, logic_flash_match_team_sort)
return class(CModuleBase, nil, logic_flash_match_team)