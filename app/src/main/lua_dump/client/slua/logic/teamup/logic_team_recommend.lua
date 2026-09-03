local logic_team_recommend = {
  CorpsCallback = nil,
  server_recommend_time = 0,
  server_ban_time = 0,
  server_day_cnt = 0,
  server_week_cnt = 0,
  checkTimerID = nil,
  checkTimerInterval = 2,
  lastCheckTime = nil,
  checkCD = 0
}
local common_config = require("client.slua.common.common_config")
local timer_tick = require("common.time_ticker")
local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
local MatchSystem = require("client.slua.logic.match.logic_match")
function logic_team_recommend:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_CORPS, EVENTID_CORPS_MEMBER_ONLINE_INFO, self.OnRefreshCorpsOnline, self)
  self:AddCommonEvent(EVENTTYPE_CORPS, EVENTID_CORPS_MEMBER_NO_UPDATE, self.OnRefreshCorpsOnline, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_LOBBY_FADE_IN_ANIM_FINISH, self.StartDetectingFree, self)
  self:AddCommonEvent(EVENTTYPE_NEXTDAY, EVENTID_NEXTDAY_ZERO, self.OnNextDayZeroCome, self)
end
function logic_team_recommend:OnPostSwitchGameStatus(preState, nextState)
  log(bWriteLog and "logic_team_recommend:OnPostSwitchGameStatus nextState:" .. tostring(nextState))
  if not GameStatus.IsInLobbyOrMainCity() then
    self:RemoveCheckTimer()
  end
end
function logic_team_recommend:OnLogOut()
  log(bWriteLog and "logic_team_recommend:OnLogOut")
  self:RemoveCheckTimer()
end
function logic_team_recommend:on_notify_recommend_team_info(last_recommend_team_time, day_cnt, week_cnt, last_recommend_nil_time)
  log(bWriteLog and "logic_team_recommend:on_notify_recommend_team_info " .. tostring(last_recommend_team_time))
  log(bWriteLog and "logic_team_recommend:on_notify_recommend_team_info " .. tostring(day_cnt))
  log(bWriteLog and "logic_team_recommend:on_notify_recommend_team_info " .. tostring(week_cnt))
  log(bWriteLog and "logic_team_recommend:on_notify_recommend_team_info " .. tostring(last_recommend_nil_time))
  self.server_recommend_time = last_recommend_team_time or 0
  self.server_day_cnt = day_cnt or 0
  self.server_week_cnt = week_cnt or 0
  self.server_ban_time = last_recommend_nil_time or 0
end
function logic_team_recommend:GetFreeUidAndSendReq()
  log(bWriteLog and "logic_team_recommend:GetFreeUidAndSendReq")
  local CorpsMemberSystem = require("client.slua.logic.corps.logic_corps_member")
  CorpsMemberSystem.get_corps_member_online_info_req()
  local GetFreeCorps = function()
    local friendList = self:GetRecommendFriendUidList()
    local corpsList = self:GetRecommendCorpsUidList(CorpsMemberSystem.MemberOnlineInfo)
    self:get_recommend_team_req(friendList, corpsList)
  end
  self.CorpsCallback = GetFreeCorps
end
function logic_team_recommend:get_recommend_team_req(friendList, corpsList)
  log_tree("logic_team_recommend:get_recommend_team_req ", friendList)
  log_tree("logic_team_recommend:get_recommend_team_req ", corpsList)
  local TeamupHandler = require("client.network.Protocol.TeamupHandler")
  TeamupHandler.send_get_recommend_team_req(friendList, corpsList)
end
function logic_team_recommend:get_recommend_team_rsp(team_uid, from, labels)
  log(bWriteLog and "logic_team_recommend:get_recommend_team_rsp " .. team_uid .. " " .. from)
  log_tree("logic_team_recommend:get_recommend_team_rsp ", labels)
  if IsWoWEditor then
    return
  end
  if GameStatus.IsInFightingNotSocialNotMainCityNotHome() then
    return
  end
  local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
  self:ClearTeamRecommendTimer()
  local count = 0
  local timeout = 10
  self.showTeamRecommendTimer = self:AddTimerLoop(0, function()
    count = count + 1
    if count >= timeout then
      log(bWriteLog and "logic_team_recommend:get_recommend_team_rsp timeout")
      self:ClearTeamRecommendTimer()
      return
    end
    if GameStatus.IsInFightingNotSocialNotMainCityNotHome() then
      log(bWriteLog and "logic_team_recommend:get_recommend_team_rsp GameStatus.IsInFightingNotSocialNotMainCityNotHome()")
      self:ClearTeamRecommendTimer()
      return
    end
    if Lobby_Main_City_Enter.bEnterMainCityLoading then
      log(bWriteLog and "logic_team_recommend:get_recommend_team_rsp bEnterMainCityLoading")
      return
    end
    self:ClearTeamRecommendTimer()
    UIManager.ShowUI(UIManager.UI_Config.team_recommend, team_uid, from, labels)
  end, TIMER_INFINITE, 1)
end
function logic_team_recommend:ClearTeamRecommendTimer()
  log(bWriteLog and "logic_team_recommend:ClearTeamRecommendTimer")
  if self.showTeamRecommendTimer then
    self:RemoveTimer(self.showTeamRecommendTimer)
    self.showTeamRecommendTimer = nil
  end
end
function logic_team_recommend:CanTeamRecommend()
  if not GameStatus.IsInLobbyOrMainCity() then
    log(bWriteLog and "logic_team_recommend:CanTeamRecommend not lobby")
    return false
  end
  if common_config:IsBlockingPopupTip() then
    log(bWriteLog and "logic_team_recommend:CanTeamRecommend UI responsiveness testing")
    return false
  end
  local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
  if Lobby_Main_City_Enter.bEnterMainCityLoading then
    log(bWriteLog and "logic_team_recommend:CanTeamRecommend bEnterMainCityLoading")
    return
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  if logic_mode_selection:IsSingleMode() then
    log(bWriteLog and "logic_team_recommend:CanTeamRecommend IsSingleMode")
    self.lastCheckTime = FuncUtil.GetServerTimeInSec()
    return false
  end
  if TeamUpNewSystem.IsInTeam() then
    log(bWriteLog and "logic_team_recommend:CanTeamRecommend InTeam")
    self.lastCheckTime = FuncUtil.GetServerTimeInSec()
    return false
  end
  if MatchSystem.nMatchStatus == ENUM_MatchStatus.Matching then
    log(bWriteLog and "logic_team_recommend:CanTeamRecommend Matching")
    self.lastCheckTime = FuncUtil.GetServerTimeInSec()
    return false
  end
  local CanTeamUp = TeamUpNewSystem.CanTeamUp(false)
  if not CanTeamUp then
    log(bWriteLog and "logic_team_recommend:CanTeamRecommend Cannot TeamUp")
    self.lastCheckTime = FuncUtil.GetServerTimeInSec()
    return false
  end
  if FuncUtil.GetServerTimeInSec() < self.server_recommend_time or FuncUtil.GetServerTimeInSec() < self.server_ban_time or self.server_week_cnt <= 0 or 0 >= self.server_day_cnt then
    log(bWriteLog and "logic_team_recommend:CanTeamRecommend serverLimit")
    self.lastCheckTime = FuncUtil.GetServerTimeInSec()
    return false
  end
  local Social_Person_Space_UIBP = UIManager.GetUI(UIManager.UI_Config.Social_Person_Space_UIBP)
  local Lobby_Main_Control = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
  if Lobby_Main_Control.curPage == ENUM_LobbyPageType.Right or Lobby_Main_Control.curPage == ENUM_LobbyPageType.Left or Social_Person_Space_UIBP and Social_Person_Space_UIBP:IsShow() then
    log(bWriteLog and "logic_team_recommend:CanTeamRecommend Lobby showing")
    self.lastCheckTime = FuncUtil.GetServerTimeInSec()
    return false
  end
  local FriendHandler = require("client.network.Protocol.FriendHandler")
  if FriendHandler.friend_status_data then
    local selfStatusID = FriendHandler.friend_status_data.sub_status_id or 0
    local cfg = CDataTable.GetTableData("FriendStatusCfg", selfStatusID)
    if cfg and (cfg.type == 7 or cfg.type == 6) then
      log(bWriteLog and "logic_team_recommend:CanTeamRecommend selfStatusID")
      self.lastCheckTime = FuncUtil.GetServerTimeInSec()
      return false
    end
  end
  if FuncUtil.GetServerTimeInSec() - self.lastCheckTime < self.checkCD then
    log(bWriteLog and "logic_team_recommend:CanTeamRecommend checkCD")
    return false
  end
  log(bWriteLog and "logic_team_recommend:CanTeamRecommend OK")
  self.lastCheckTime = FuncUtil.GetServerTimeInSec()
  return true
end
function logic_team_recommend:StartDetectingFree()
  log(bWriteLog and "logic_team_recommend:StartDetectingFree ")
  if not GameStatus.IsInLobbyOrMainCity() then
    log(bWriteLog and "logic_team_recommend:StartDetectingFree not lobby")
    return
  end
  self:RemoveCheckTimer()
  self.lastCheckTime = FuncUtil.GetServerTimeInSec()
  self.checkCD = CDataTable.GetTableData("RecommendedSystemCfg", "recommend_team_cd").Value
  self.checkTimerID = timer_tick.AddTimerLoop(self.checkCD, function()
    if self:CanTeamRecommend() then
      self:GetFreeUidAndSendReq()
    end
  end, TIMER_INFINITE, self.checkTimerInterval)
end
function logic_team_recommend:OnRefreshCorpsOnline()
  log(bWriteLog and "logic_team_recommend:OnRefreshCorpsOnline")
  if self.CorpsCallback then
    self.CorpsCallback()
    self.CorpsCallback = nil
  end
end
function logic_team_recommend:CheckValidStatus(profile)
  if not (profile and profile.frd_status_id) or profile.frd_status_id <= 0 then
    return true
  end
  if FuncUtil.GetServerTimeInSec() > profile.frd_status_end_time then
    return true
  end
  local cfg = CDataTable.GetTableData("FriendStatusCfg", profile.frd_status_id)
  if cfg and (cfg.type == 7 or cfg.type == 6) then
    log(bWriteLog and string.format("logic_team_recommend:CheckValidStatus cfg.type == %s, uid = %s", tostring(cfg.type), tostring(profile.uid)))
    return false
  end
  return true
end
function logic_team_recommend:GetRecommendFriendUidList()
  local uidList = {}
  local PlayerStatusEnum = require("client.slua.logic.player_status.PlayerStatusEnum")
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local freeFriendList = LogicFriend.GetAllFriendList(true, nil, PlayerStatusEnum.Enum_TeamState.Free)
  local idleFriendList = LogicFriend.GetAllFriendList(true, nil, PlayerStatusEnum.Enum_TeamState.Idle)
  local mainCityFreeFriendList = LogicFriend.GetInMainCityFreeFriendList()
  local onlineFriendsList = {}
  for i, v in ipairs(freeFriendList) do
    table.insert(onlineFriendsList, v)
  end
  for i, v in ipairs(idleFriendList) do
    table.insert(onlineFriendsList, v)
  end
  for i, v in ipairs(mainCityFreeFriendList) do
    table.insert(onlineFriendsList, v)
  end
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  if 0 < #onlineFriendsList then
    for index, uid in ipairs(onlineFriendsList) do
      local profile = logic_profile:GetLocalProfile(uid)
      if self:CheckValidStatus(profile) and TeamUpNewSystem.CanInviteFriend(uid, true) then
        table.insert(uidList, uid)
      end
    end
  end
  return uidList
end
function logic_team_recommend:GetRecommendCorpsUidList(MemberOnlineInfo)
  local corpsList = {}
  log_tree("logic_team_recommend:GetRecommendCorpsUidList MemberOnlineInfo ", MemberOnlineInfo)
  local PlayerStatusUtil = require("client.slua.logic.player_status.PlayerStatusUtil")
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  for uid, v in pairs(MemberOnlineInfo) do
    local profile = logic_profile:GetLocalProfile(uid)
    log_tree("logic_team_recommend:GetRecommendCorpsUidList MemberOnlineInfo11 ", profile)
    if v.online == 1 and tonumber(uid) ~= tonumber(DataMgr.roleData.uid) and self:CheckValidStatus(profile) and (PlayerStatusUtil.IsIdleOrFree(v) or PlayerStatusUtil.IsMainCityIdle(v)) and (not v.tplan_type or v.tplan_type ~= 1) then
      log(bWriteLog and "logic_team_recommend:GetRecommendCorpsUidList MemberOnlineInfo")
      table.insert(corpsList, uid)
    end
  end
  log(bWriteLog and string.format("logic_team_recommend:GetRecommendCorpsUidList #MemberOnlineInfo == %s, #corpsList == %s", tostring(#MemberOnlineInfo), tostring(#corpsList)))
  return corpsList
end
function logic_team_recommend:GetLabelList(labels)
  local result = {}
  if not labels then
    return result
  end
  local cfg = CDataTable.GetTable("LableConfig")
  for _, value in pairs(labels) do
    local labelConfig = cfg[value]
    if labelConfig and labelConfig.Priority and labelConfig.Priority ~= 0 then
      table.insert(result, labelConfig)
    end
  end
  table.sort(result, function(a, b)
    return a.Priority < b.Priority
  end)
  return result
end
function logic_team_recommend:RemoveCheckTimer()
  log(bWriteLog and "logic_team_recommend:RemoveCheckTimer")
  if self.checkTimerID then
    timer_tick.RemoveTimer(self.checkTimerID)
    self.checkTimerID = nil
    self.lastCheckTime = nil
  end
end
function logic_team_recommend:OnNextDayZeroCome()
  log(bWriteLog and "logic_team_recommend:OnNextDayZeroCome")
  local TeamupHandler = require("client.network.Protocol.TeamupHandler")
  TeamupHandler.send_get_recommend_team_info()
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_team_recommend = class(CModuleBase, nil, logic_team_recommend)
return Clogic_team_recommend