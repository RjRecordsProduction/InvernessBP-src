local logic_teamquick_join = {}
local RECOMMEND_COUNT = 40
function logic_teamquick_join:ctor()
  self.listFilterFriend = false
  self.listFilterNoApply = false
  self.QuickTeamUpList = {}
  if not self.prefer_modes then
    local FlashTeamHandler = require("client.network.Protocol.FlashTeamHandler")
    FlashTeamHandler.send_get_prefer_modes_for_flash_squad_req()
  end
end
function logic_teamquick_join:OnLogin(bReLogin)
  local FlashTeamHandler = require("client.network.Protocol.FlashTeamHandler")
  FlashTeamHandler.send_get_prefer_modes_for_flash_squad_req()
end
function logic_teamquick_join:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_QUICKTEAM_LOBBY, self.OnUrl)
end
function logic_teamquick_join:OnUrl()
  UIManager.ShowUI(UIManager.UI_Config.TeamQuick_Lobby_Main)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.QuickTeamLobbyHall, 5)
end
function logic_teamquick_join:RequireQuickTeamUpList(bForceRefresh)
  if bForceRefresh then
    local FlashTeamHandler = require("client.network.Protocol.FlashTeamHandler")
    FlashTeamHandler.send_get_flash_squad_recommend_req(RECOMMEND_COUNT)
    return
  end
  if not next(self.QuickTeamUpList) then
    local FlashTeamHandler = require("client.network.Protocol.FlashTeamHandler")
    FlashTeamHandler.send_get_flash_squad_recommend_req(RECOMMEND_COUNT)
  end
end
function logic_teamquick_join:SetAvatarTeamID(squadId)
  self.AvatarSquadId = squadId
end
function logic_teamquick_join:GetAvatarTeamID()
  return self.AvatarSquadId
end
function logic_teamquick_join:SetRecommendCount(count)
  RECOMMEND_COUNT = count
end
function logic_teamquick_join:GetQuickTeamUpList()
  return self.QuickTeamUpList
end
function logic_teamquick_join:SetListFilterFriend(value)
  self.listFilterFriend = value
end
function logic_teamquick_join:GetListFilterFriend()
  return self.listFilterFriend
end
function logic_teamquick_join:GetPreferModesOver60Percent(threshold)
  local prefer_modes = self.prefer_modes
  if not prefer_modes or #prefer_modes == 0 then
    log(bWriteLog and "logic_teamquick_join:GetPreferModesOver60Percent Server no prefer_modes!")
    return false
  end
  local max_mode_count = 0
  local total_count = 0
  local max_mode = 0
  for _, mode in ipairs(prefer_modes) do
    total_count = total_count + mode.count
    if max_mode_count < mode.count then
      max_mode_count = mode.count
      max_mode = mode.mapped_mode_id
    end
  end
  if total_count <= 0 or max_mode_count <= 0 then
    return nil
  end
  threshold = threshold or 0.6
  if threshold < max_mode_count / total_count then
    return max_mode
  end
  return nil
end
function logic_teamquick_join:GetPreferModes()
  return self.prefer_modes or {}
end
function logic_teamquick_join:GetTop3FriendsUIDByModeID(modeID)
  local getAllCountByModData = function(data)
    local totalCount = 0
    for k, v in pairs(data) do
      totalCount = totalCount + v
    end
    return totalCount
  end
  local result = {}
  local tempFriends = {}
  local uidSet = {}
  local FlashSquadFriendMode = CDataTable.GetTableData("FlashSquadFriendMode", modeID)
  if not FlashSquadFriendMode then
    log_error("logic_teamquick_join:GetTop3FriendsUIDByModeID TeamQuickFriendMod is nil, modeID = " .. tostring(modeID))
    return result
  end
  for k, v in pairs(self.teamates_list or {}) do
    local uid = tonumber(k)
    if uid and not uidSet[uid] then
      local totalCount = 0
      for kk, vv in pairs(v) do
        if string.find(FlashSquadFriendMode.MainModeId, kk) then
          totalCount = totalCount + getAllCountByModData(vv)
        end
      end
      if 0 < totalCount then
        uidSet[uid] = true
        table.insert(tempFriends, {uid = uid, count = totalCount})
      end
    end
  end
  table.sort(tempFriends, function(a, b)
    return a.count > b.count
  end)
  for i = 1, math.min(3, #tempFriends) do
    table.insert(result, tempFriends[i].uid)
  end
  return result
end
function logic_teamquick_join:JudgeIsMyFriendInTeam(teamId)
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  local flashTeamMembersBrief = logic_flash_match_team:GetFlashTeamMembersById(teamId)
  local flashTeamSummary = logic_flash_match_team:GetFlashTeamSummaryById(teamId)
  if (not flashTeamSummary or not flashTeamSummary.member_uids) and (not flashTeamMembersBrief or not flashTeamMembersBrief.list) then
    log(bWriteLog and "logic_teamquick_join:JudgeIsMyFriendInTeam flashTeamSummary is nil, teamId = " .. tostring(teamId))
    return false
  end
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  if flashTeamSummary and flashTeamSummary.member_uids then
    for _, uid in ipairs(flashTeamSummary.member_uids) do
      if LogicFriend.IsMyFriend(uid) then
        return true
      end
    end
  end
  if flashTeamMembersBrief and flashTeamMembersBrief.list then
    for k, v in pairs(flashTeamMembersBrief.list) do
      if LogicFriend.IsMyFriend(k) then
        return true
      end
    end
  end
  return false
end
function logic_teamquick_join:SetListFilterNoApply(value)
  self.listFilterNoApply = value
end
function logic_teamquick_join:GetListFilterNoApply()
  return self.listFilterNoApply
end
function logic_teamquick_join:proc_get_flash_squad_recommend_rsp(ret, squad_list)
  if ret ~= 0 then
    ShowNotice(ret)
    return
  end
  if not next(squad_list) then
    return
  end
  log_tree(bWriteLog and "logic_teamquick_join:proc_get_flash_squad_recommend_rsp squad_list:", squad_list)
  self.QuickTeamUpList = {}
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  for k, v in pairs(squad_list) do
    if not logic_flash_match_team:IsMyTeam(v.squad_id) then
      table.insert(self.QuickTeamUpList, v)
    end
  end
  local squad_ids = {}
  if squad_list then
    for _, squad in ipairs(squad_list) do
      if squad.squad_id then
        table.insert(squad_ids, squad.squad_id)
      end
    end
  end
  if 0 < #squad_ids then
    local FlashTeamHandler = require("client.network.Protocol.FlashTeamHandler")
    FlashTeamHandler.send_batch_get_flash_squad_members_brief_req(squad_ids)
  end
end
function logic_teamquick_join:proc_get_prefer_modes_for_flash_squad_rsp(data)
  log_tree(bWriteLog and "logic_teamquick_join:proc_get_prefer_modes_for_flash_squad_rsp data:", data)
  self.prefer_modes = data.prefer_modes or {}
  table.sort(self.prefer_modes, function(a, b)
    return a.count > b.count
  end)
  self.teamates_list = data.teamates_list or {}
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
return class(CModuleBase, nil, logic_teamquick_join)