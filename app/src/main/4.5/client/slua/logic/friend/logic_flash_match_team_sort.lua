local flash_match_team_const = require("client.slua.logic.friend.flash_match_team_const")
local ESearchMode = flash_match_team_const.ESearchMode
local logic_flash_match_team_sort = {}
function logic_flash_match_team_sort:MatchTeamBySearchKey(teamInfo, searchKeyLower, searchMode)
  if searchKeyLower == "" then
    return true
  end
  local modes = type(searchMode) == "table" and searchMode or {searchMode}
  for _, mode in ipairs(modes) do
    if mode == ESearchMode.Team then
      local teamName = teamInfo.name or ""
      if string.find(string.lower(teamName), searchKeyLower, 1, true) then
        return true
      end
    elseif mode == ESearchMode.Member then
      local membersBrief = self:GetFlashTeamMembersById(teamInfo.squad_id)
      if membersBrief and membersBrief.list then
        for _, memberInfo in pairs(membersBrief.list) do
          local memberName = memberInfo.name or ""
          if string.find(string.lower(memberName), searchKeyLower, 1, true) then
            return true
          end
        end
      end
    end
  end
  return false
end
function logic_flash_match_team_sort:PreTeamSortFunc(teamA, teamB, myUid, gameMode)
  myUid = myUid or DataMgr.roleData.uid
  if not gameMode then
    local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
    gameMode = logic_mode_selection:GetCurSelectInfo()
  end
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local inA = false
  local inB = false
  if teamA.member_uids then
    for _, uid in pairs(teamA.member_uids) do
      if tonumber(uid) == myUid then
        inA = true
        break
      end
    end
  end
  if teamB.member_uids then
    for _, uid in pairs(teamB.member_uids) do
      if tonumber(uid) == myUid then
        inB = true
        break
      end
    end
  end
  if inA ~= inB then
    return inA
  end
  if gameMode then
    local matchA = teamA.game_mode == gameMode
    local matchB = teamB.game_mode == gameMode
    if matchA ~= matchB then
      return matchA
    end
  end
  local vacancyA = (teamA.max_member or 0) - (teamA.member_count or 0)
  local vacancyB = (teamB.max_member or 0) - (teamB.member_count or 0)
  if vacancyA ~= vacancyB then
    return vacancyA < vacancyB
  end
  local maxIntimacyA = 0
  if teamA.member_uids then
    for _, uid in pairs(teamA.member_uids) do
      if tonumber(uid) ~= myUid then
        local intimacy = LogicFriend.GetInnerFriendIntimacy(uid) or 0
        if maxIntimacyA < intimacy then
          maxIntimacyA = intimacy
        end
      end
    end
  end
  local maxIntimacyB = 0
  if teamB.member_uids then
    for _, uid in pairs(teamB.member_uids) do
      if tonumber(uid) ~= myUid then
        local intimacy = LogicFriend.GetInnerFriendIntimacy(uid) or 0
        if maxIntimacyB < intimacy then
          maxIntimacyB = intimacy
        end
      end
    end
  end
  return maxIntimacyA > maxIntimacyB
end
function logic_flash_match_team_sort:DefaultMemberSortFunc(memberA, memberB, leaderUid, squadId)
  if leaderUid then
    local isLeaderA = memberA.uid == leaderUid
    local isLeaderB = memberB.uid == leaderUid
    if isLeaderA ~= isLeaderB then
      return isLeaderA
    end
  end
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  local onlineA = self:JudgeMemberIsOnline(squadId, memberA.uid)
  local onlineB = self:JudgeMemberIsOnline(squadId, memberB.uid)
  onlineA = memberA.uid == tonumber(DataMgr.roleData.uid) and true or onlineA
  onlineB = memberB.uid == tonumber(DataMgr.roleData.uid) and true or onlineB
  if onlineA ~= onlineB then
    return onlineA == true
  end
  local tacitValueA = self:GetRapportContributionById(squadId, memberA.uid)
  local tacitValueB = self:GetRapportContributionById(squadId, memberB.uid)
  if tacitValueA ~= tacitValueB then
    return tacitValueA > tacitValueB
  end
  local joinTimeA = memberA.join_time or 0
  local joinTimeB = memberB.join_time or 0
  return joinTimeA < joinTimeB
end
function logic_flash_match_team_sort:BuildDefaultSortKeys(teams)
  local keys = {}
  for _, teamInfo in ipairs(teams) do
    local id = teamInfo.squad_id
    local pinTime = self:isTeamPinUp(id) or 0
    keys[id] = {
      inPre = self:isPlayerInPreTeam(id),
      isPinned = 0 < pinTime,
      pinTime = pinTime,
      hasPre = 0 < (teamInfo.pre_team_count or 0),
      online = self:getOnlineCount(id)
    }
  end
  return keys
end
function logic_flash_match_team_sort:SortByDefaultKeys(teams, keys, recomSquadId)
  table.sort(teams, function(a, b)
    local ka, kb = keys[a.squad_id], keys[b.squad_id]
    if recomSquadId then
      local isRecomA = recomSquadId == a.squad_id
      local isRecomB = recomSquadId == b.squad_id
      if isRecomA ~= isRecomB then
        return isRecomA
      end
    end
    if ka.isPinned ~= kb.isPinned then
      return ka.isPinned
    end
    if ka.inPre ~= kb.inPre then
      return ka.inPre
    end
    if ka.pinTime ~= kb.pinTime then
      return ka.pinTime > kb.pinTime
    end
    if ka.hasPre ~= kb.hasPre then
      return ka.hasPre
    end
    return ka.online > kb.online
  end)
end
function logic_flash_match_team_sort:GetSortedMyTeams(teams)
  teams = teams or self:getMyTeams() or {}
  local keys = self:BuildDefaultSortKeys(teams)
  self:SortByDefaultKeys(teams, keys, nil)
  return teams
end
function logic_flash_match_team_sort:BuildDefaultSortKeys2(squadIds)
  local selfUid = tonumber(DataMgr.roleData.uid) or 0
  local keys = {}
  for _, id in ipairs(squadIds) do
    local summary = self:GetFlashTeamSummaryById(id)
    local intimacy = self:getMaxIntimacyInSquad(id)
    keys[id] = {
      isPinned = self:isTeamPinUp(id) and true or false,
      rapport = summary and summary.rapport_score or 0,
      contribution = self:GetRapportContributionById(id, selfUid) or 0,
      intimacy = intimacy,
      hasFriend = 0 < intimacy
    }
  end
  return keys
end
function logic_flash_match_team_sort:SortByDefaultKeys2(squadIds, keys)
  table.sort(squadIds, function(a, b)
    local ka, kb = keys[a], keys[b]
    if ka.isPinned ~= kb.isPinned then
      return ka.isPinned
    end
    if ka.rapport ~= kb.rapport then
      return ka.rapport > kb.rapport
    end
    if ka.contribution ~= kb.contribution then
      return ka.contribution > kb.contribution
    end
    if ka.hasFriend ~= kb.hasFriend then
      return ka.hasFriend
    end
    return ka.intimacy > kb.intimacy
  end)
end
return logic_flash_match_team_sort