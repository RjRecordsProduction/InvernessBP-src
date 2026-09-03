local Lobby_Mid_Squad_Tips_UIBP = {}
local FlashTeamHandler = require("client.network.Protocol.FlashTeamHandler")
local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
local TimeUtil = require("client.common.time_util")
local flash_team_data_handler = require("client.slua.logic.friend.flash_team.flash_team_data_handler")
local RecommendType = {
  Default = 0,
  DelayRecommend = 1,
  ModeSwitch = 2,
  WeeklyLogin = 3,
  DailyLogin = 4
}
local JumpType = {Default = 1, ToTeamLobby = 2}
local ShowType = {
  condition1 = 1,
  condition2 = 2,
  condition3 = 3,
  condition4 = 4,
  condition5 = 5,
  condition6 = 6,
  condition7 = 7,
  condition8 = 8,
  condition9 = 9,
  condition10 = 10,
  condition}
local UIShowType = {Default = 0, ShowIcon = 1}
local SHOW_TIP_THROTTLE_INTERVAL = 3600
require("client.slua.config.event.event_define")
function Lobby_Mid_Squad_Tips_UIBP:ctor()
end
function Lobby_Mid_Squad_Tips_UIBP:OnInitialize()
end
function Lobby_Mid_Squad_Tips_UIBP:RegistEvents()
  self:AddOnClickedEventByControl(self.UIRoot.Button_HotZone, self.OnClickButton_HotZone, self)
  self:AddCommonEvent(EVENTTYPE_FLASH_TEAM, EVENTID_FLASH_TEAM_RECOM_RSP, self.onGetRecommendFlashTeamRsp, self)
  self:AddCommonEvent(EVENTTYPE_LOGIN, EVENTID_LOGIN_SUCCESS, self.OnLoginLobby, self)
  self:AddCommonEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_POST_SWITCH, self.OnReturnLobby, self)
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_MATCH_MODE_SELECT_CHANGE, self.onModeSelectChange, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_NEW_TEAM_MATCH_MODE, self.onModeSelectChange, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_CONSCRIBE_UPDATE_TEAM, self.OnTeamUpChg, self)
  self:AddCommonEvent(EVENTTYPE_FLASH_TEAM, EVENTID_FLASH_TEAM_DATA_CHG, self.onAllMyTeamsChg, self)
  self:AddCommonEvent(EVENTTYPE_FLASH_TEAM, EVENTID_OPEN_FLASH_TEAM_LIST, self.onOpenFlashTeamList, self)
  self:AddCommonEvent(EVENTTYPE_FLASH_TEAM, ENTRY_SPECIFIC_REMIND_TIPS, self.onShowSpecificTips, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, GM_FLASH_TEAM_RECOMMEND_TIPS, self.GMShow, self)
end
function Lobby_Mid_Squad_Tips_UIBP:OnPostInitialize()
  self.UIRoot.TextBlock_1:SetText("")
  self.UIRoot.TextBlock_0:SetText("")
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  logic_flash_match_team:reqMyTeamData()
  local SeasonHandler = require("client.network.Protocol.SeasonHandler")
  SeasonHandler.send_get_season_config_req()
  self.isFirstOpen = true
  self:UpdateUI()
end
function Lobby_Mid_Squad_Tips_UIBP:OnClose()
  self:HideTip()
  if self.delayShowTip then
    self:RemoveTimer(self.delayShowTip)
    self.delayShowTip = nil
  end
  if self.delayModeSwitchTip then
    self:RemoveTimer(self.delayModeSwitchTip)
    self.delayModeSwitchTip = nil
  end
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  logic_flash_match_team:SetCurRecomTeam()
end
function Lobby_Mid_Squad_Tips_UIBP:OnClickButton_HotZone()
  self:PlayAudio(sound_config.click_v1)
  self:MarkClose()
  log_format(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:OnClickButton_HotZone click recommend curLogType:%s", self.curLogType)
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.FlashSquad_Guide_Log, self.curLogType, 1)
  if self.jumpType == JumpType.ToTeamLobby then
    UIManager.ShowUI(UIManager.UI_Config.TeamQuick_Lobby_Main)
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.QuickTeamLobbyHall, 1)
    return
  end
  local FLMacros = require("client.slua.logic.friend.refactor.friend_list_macros")
  UIManager.ShowUI(UIManager.UI_Config.Lobby_InviteFriend_BP, FLMacros.ENUM_OPEN_FROM.LOBBY, FLMacros.ENUM_TAB.ENUM_TEAM_TAG)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.QuickTeamList, 1)
end
function Lobby_Mid_Squad_Tips_UIBP:onGetRecommendFlashTeamRsp()
  log_format(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:onGetRecommendFlashTeamRsp Server recommend Squads! recommendType:%s", self.recommendType)
  if not self:CheckCanShow() then
    self.recommendType = RecommendType.Default
    return
  end
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  local smart_guide_join_match_threshold = logic_flash_match_team:GetConstConfValue("smart_guide_join_match_threshold") or 95
  if self.GMTrigger1 then
    log("Lobby_Mid_Squad_Tips_UIBP:onGetRecommendFlashTeamRsp GMTrigger \230\151\160\230\157\161\228\187\182\229\188\185\229\135\186\239\188\140\230\142\168\232\141\144\229\136\134\232\174\190\231\189\174\228\184\1860")
    self.GMTrigger1 = false
    smart_guide_join_match_threshold = 0
  end
  local recommendSquads = logic_flash_match_team:getRecomSquad()
  if self.recommendType == RecommendType.DelayRecommend then
    if not recommendSquads or #recommendSquads == 0 then
      log(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:onGetRecommendFlashTeamRsp Server recommend Squads! recommendType:%s", self.recommendType)
      return
    end
    local bestSquad
    local bestScore = 0
    for _, squad in ipairs(recommendSquads) do
      local score = squad.display_score or 0
      if smart_guide_join_match_threshold <= score and bestScore < score then
        bestSquad = squad
      end
    end
    if bestSquad then
      self:RefreshShow(ShowType.condition4, nil, nil, bestSquad)
    else
      self:RefreshShow(ShowType.condition5)
    end
    self:ShowTip()
  elseif self.recommendType == RecommendType.ModeSwitch then
    if not self.curSelectMode then
      log(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:onGetRecommendFlashTeamRsp  no current selected mode")
      return
    end
    local squadId, squadName = logic_flash_match_team:getRecommendType3FromRecomSquads(self.curSelectMode)
    if not squadId then
      log(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:onGetRecommendFlashTeamRsp  \230\178\161\230\156\137\231\172\166\229\144\136\230\157\161\228\187\182\231\154\132\233\151\170\233\133\141\229\176\143\233\152\159\239\188\140\228\184\141\232\167\166\229\143\145")
      return
    end
    self:RefreshShow(ShowType.condition8, squadId)
    self:ShowTip()
  elseif self.recommendType == RecommendType.WeeklyLogin then
    if not self.weeklyDominantMainId then
      log(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:onGetRecommendFlashTeamRsp WeeklyLogin \230\178\161\230\156\137\229\129\143\231\136\177\231\142\169\230\179\149")
      return
    end
    local squadId, squadName = logic_flash_match_team:getRecommendType4FromRecomSquads(self.weeklyDominantMainId)
    if not squadId then
      log(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:onGetRecommendFlashTeamRsp WeeklyLogin \230\178\161\230\156\137\229\129\143\231\136\177\231\155\174\230\160\135\231\142\169\230\179\149\231\154\132\230\142\168\232\141\144\229\176\143\233\152\159\239\188\140\228\184\141\232\167\166\229\143\145")
      return
    end
    self:RefreshShow(ShowType.condition9, squadId)
    self:ShowTip()
  elseif self.recommendType == RecommendType.DailyLogin then
    local squadInfo = logic_flash_match_team:getFirstRecomSquad()
    if not squadInfo then
      log(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:onGetRecommendFlashTeamRsp DailyLogin \230\178\161\230\156\137\230\142\168\232\141\144\229\176\143\233\152\159")
      return
    end
    self:RefreshShow(ShowType.condition11, nil, nil, squadInfo)
    self:ShowTip()
  end
  self.recommendType = RecommendType.Default
end
function Lobby_Mid_Squad_Tips_UIBP:OnLoginLobby(bIsRelogin)
  log(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:OnLoginLobby")
  self.userClosed = nil
  if not self:CheckCanShow() then
    return
  end
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local isWeeklyFirst = PlayerPrefsSystem.CheckAndSaveCurrentDate_N(PlayerPrefsSystem.ePlayerPrefsType.eFlashTeamWeeklyLogin, false, 7)
  if isWeeklyFirst and self:GetRecommendType4() then
    return
  end
  local isDailyFirst = PlayerPrefsSystem.CheckAndSaveCurrentDate_N(PlayerPrefsSystem.ePlayerPrefsType.eFlashTeamDailyLogin, false, 1)
  if isDailyFirst then
    local isReqRecommend = true
    local ownInfo = logic_flash_match_team:getOwnFlashTeamInfo()
    local hasSquad = ownInfo and ownInfo.squads and next(ownInfo.squads)
    if not hasSquad and self:GetRecommendType5() then
      return
    end
    self:ReqSeverRecommend(10, nil, RecommendType.DailyLogin)
  end
end
function Lobby_Mid_Squad_Tips_UIBP:OnReturnLobby()
  log(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:OnReturnLobby")
  self:RefreshNewSeasonTips()
  self.userClosed = nil
  if self:CheckCanShow() then
    local isFound = self:GetRecommendType1()
    if isFound then
      self:ShowTip()
    end
  end
  if self.delayShowTip then
    self:RemoveTimer(self.delayShowTip)
    self.delayShowTip = nil
  end
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  local smart_guide_lobby_coldstart_time = logic_flash_match_team:GetConstConfValue("smart_guide_lobby_coldstart_time") or 45
  self.delayShowTip = self:AddTimer(smart_guide_lobby_coldstart_time, function()
    self.delayShowTip = nil
    if not self:CheckCanShow() then
      log(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:OnReturnLobby delayShowTip has been jumped")
      return
    end
    if self:GetRecommendType2() then
      self:ShowTip()
    else
      self:ReqSeverRecommend(10, self.defaultRecommendMode, RecommendType.DelayRecommend)
    end
  end)
end
function Lobby_Mid_Squad_Tips_UIBP:onModeSelectChange()
  self.userClosed = nil
  self.lastShowTipTime = nil
  if not self:CheckCanShow() then
    return
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  self.curSelectMode = logic_mode_selection:GetCurSelectInfo()
  log_format(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:onModeSelectChange curMatchMode:%s", self.curSelectMode)
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  local teamMainID = logic_flash_match_team:GetModeByGMode(self.curSelectMode)
  if not self.curSelectMode or self.curSelectMode ~= UEnums.GameMode.Rank_Competition and teamMainID ~= UEnums.FlashTeamGameMode.Team_Competition and teamMainID ~= UEnums.FlashTeamGameMode.WoW_Creative then
    log(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:onModeSelectChange not target mode, curMatchMode:%s", self.curSelectMode)
    return
  end
  if self.delayModeSwitchTip then
    self:RemoveTimer(self.delayModeSwitchTip)
    self.delayModeSwitchTip = nil
  end
  local MODE_SWITCH_DELAY = 15
  self.delayModeSwitchTip = self:AddTimer(MODE_SWITCH_DELAY, function()
    self.delayModeSwitchTip = nil
    if not self:CheckCanShow() then
      log(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:onModeSelectChange delay skipped, can not show")
      return
    end
    if self:GetRecommendType3(self.curSelectMode) then
      self:ShowTip()
    end
  end)
end
function Lobby_Mid_Squad_Tips_UIBP:onAllMyTeamsChg()
  self:UpdateRemindTips()
  if not self:CheckCanShow() then
    log(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:onAllMyTeamsChg Cannot show, other tips is showing")
    return
  end
  if not self.isFirstOpen then
    log(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:onAllMyTeamsChg not first open")
    return
  end
  local isFound = self:GetRecommendType1()
  if isFound then
    self:ShowTip()
  end
  self.isFirstOpen = nil
end
function Lobby_Mid_Squad_Tips_UIBP:onOpenFlashTeamList()
  self:MarkClose()
end
function Lobby_Mid_Squad_Tips_UIBP:onShowSpecificTips(_, _, content)
  if self.recommendIsShowing then
    log(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:onShowSpecificTips Cannot show, other tips is showing")
    return
  end
  local logic_teamquick_guide = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_teamquick_guide)
  local hasShowLobbyGuide = logic_teamquick_guide:CheckHasShowLobbyGuide()
  if not hasShowLobbyGuide then
    log(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:onShowSpecificTips HasShowLobbyGuide = false")
    return
  end
  log(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:onShowSpecificTips")
  self:RefreshUIType()
  self.UIRoot.TextBlock_1:SetText(content)
  self:ShowTip()
end
function Lobby_Mid_Squad_Tips_UIBP:GMShow(_, _, type)
  self:HideTip()
  self.userClosed = nil
  self.GMTrigger = true
  self.GMTrigger1 = true
  if type == 4 or type == 5 then
    self:ReqSeverRecommend(10, nil, RecommendType.DelayRecommend)
  elseif type == 8 then
    local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
    self.curSelectMode = logic_mode_selection:GetCurSelectInfo()
    log_format(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:GMShow curMatchMode:%s", self.curSelectMode)
    self:ReqSeverRecommend(10, self.curSelectMode, RecommendType.ModeSwitch)
  elseif type == 9 then
    local logic_teamquick_join = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_teamquick_join)
    self.weeklyDominantMainId = logic_teamquick_join:GetPreferModesOver60Percent()
    log_format(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:GMShow preferMode:%s", self.weeklyDominantMainId)
    self:ReqSeverRecommend(10, nil, RecommendType.WeeklyLogin)
  elseif type == 11 then
    self:ReqSeverRecommend(10, nil, RecommendType.DailyLogin)
  elseif type == 1 then
    local isFound = self:GetRecommendType1()
    if isFound then
      self:ShowTip()
    end
  elseif type == 30 then
    self:RefreshNewSeasonTips()
  else
    local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
    local myTeams = logic_flash_match_team:GetSortedMyTeams()
    local squadId = myTeams and myTeams[1] and myTeams[1].squad_id
    local pre_teams = myTeams and myTeams[1] and myTeams[1].pre_teams
    local idx = pre_teams and next(pre_teams)
    local preTeamId = idx and pre_teams[idx].team_id
    local rcmdInfo = logic_flash_match_team:getFirstRecomSquad()
    if not squadId and not rcmdInfo then
      log(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:GMShow() no squadId and rcmdInfo")
      return
    end
    self:RefreshShow(type, squadId, preTeamId, rcmdInfo)
    self:ShowTip()
  end
end
function Lobby_Mid_Squad_Tips_UIBP:OnTeamUpChg()
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  if self.delayRefreshCb then
    log(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:OnTeamUpChg requesting delayRefreshCb")
    return
  end
  log(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:OnTeamUpChg")
  self.delayRefreshCb = self:AddTimerOnce(2, function()
    self.delayRefreshCb = nil
    logic_flash_match_team:reqMyTeamData()
    self.markRefresh = true
  end)
end
function Lobby_Mid_Squad_Tips_UIBP:UpdateRemindTips()
  log(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:UpdateRemindTips")
  if not self.markRefresh then
    return
  end
  self.markRefresh = false
  if self.recommendIsShowing then
    log(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:UpdateRemindTips RecommendIsShowing = true")
    return false
  end
  if flash_team_data_handler:IsOverPreTeamDailyRemindLimit() then
    log(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:UpdateRemindTips Over limit")
    return
  end
  local mySquadInfo, myPreTeamInfo = flash_team_data_handler:FindMyPreTeam()
  if not mySquadInfo then
    log(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:UpdateRemindTips No mySquadInfo")
    return
  end
  self:RefreshUIType()
  self.UIRoot.TextBlock_1:SetText(LocUtil.LocalizeResFormat(818256))
  self:ShowTip(true)
  flash_team_data_handler:IncreaseDailyRemindCount()
end
function Lobby_Mid_Squad_Tips_UIBP:UpdateUI()
  log(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:UpdateUI")
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  self.myTeams = logic_flash_match_team:GetSortedMyTeams()
  self:HideTip()
  self:OnLoginLobby()
  self:OnReturnLobby()
end
function Lobby_Mid_Squad_Tips_UIBP:CheckCanShow()
  if self.GMTrigger then
    self.GMTrigger = false
    return true
  end
  if self.userClosed then
    log(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:CheckCanShow userClosed = true")
    return false
  end
  if self.recommendIsShowing then
    log(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:CheckCanShow recommendIsShowing = true")
    return false
  end
  local logic_teamquick_guide = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_teamquick_guide)
  local hasShowLobbyGuide = logic_teamquick_guide:CheckHasShowLobbyGuide()
  if not hasShowLobbyGuide then
    log(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:CheckCanShow hasShowLobbyGuide = false")
    return false
  end
  local nowSec = TimeUtil.GetServerTimeInSec()
  if self.lastShowTipTime and nowSec - self.lastShowTipTime < SHOW_TIP_THROTTLE_INTERVAL then
    log_format(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:ShowTip skipped by hourly throttle, lastShowTipTime:%s nowSec:%s", self.lastShowTipTime, nowSec)
    return false
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.IsInTeam() then
    log(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:CheckCanShow player is in a team")
    return false
  end
  return true
end
function Lobby_Mid_Squad_Tips_UIBP:ShowTip(isNotMarkTime)
  if not isNotMarkTime then
    self.lastShowTipTime = TimeUtil.GetServerTimeInSec() or 0
  end
  self:HideTip()
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  local smart_guide_auto_close_time = logic_flash_match_team:GetConstConfValue("smart_guide_auto_close_time") or 20
  self:SetWidgetVisible(self.UIRoot.SocialIsland_Tips, true)
  self.recommendIsShowing = true
  log_format(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:ShowTip show tips! curLogType:%s", self.curLogType)
  self.delayCloseCb = self:AddTimer(smart_guide_auto_close_time, function()
    log_format(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:ShowTip delayCloseCb curLogType:%s", self.curLogType)
    self.delayCloseCb = nil
    self:HideTip()
    local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
    logic_flash_match_team:SetCurRecomTeam()
    self.jumpType = JumpType.Default
  end)
end
function Lobby_Mid_Squad_Tips_UIBP:MarkClose()
  if not self.UIRoot.SocialIsland_Tips:isVisible() then
    return
  end
  self.userClosed = true
  self:HideTip()
end
function Lobby_Mid_Squad_Tips_UIBP:HideTip()
  log(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:HideTip")
  if self.delayCloseCb then
    self:RemoveTimer(self.delayCloseCb)
    self.delayCloseCb = nil
  end
  self:SetWidgetVisible(self.UIRoot.SocialIsland_Tips, false)
  self.recommendIsShowing = false
end
function Lobby_Mid_Squad_Tips_UIBP:GetRecommendType1()
  log(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:GetRecommendType1 trigger recommendation when returning to lobby")
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  local squad = logic_flash_match_team:getSquadNearRapportUpgrade(20)
  if not squad then
    log(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:GetRecommendType1 \231\142\169\229\174\182\229\176\154\230\156\170\231\187\132\233\152\159\239\188\140\228\184\148\229\183\178\229\138\160\229\133\165\229\176\143\233\152\159\229\173\152\229\156\168\232\183\157\231\166\187\233\187\152\229\165\145\229\128\188\229\141\135\231\186\167\228\187\133\229\137\169\226\137\16420\231\154\132\229\176\143\233\152\159")
    return false
  end
  self:RefreshShow(ShowType.condition1, squad.squad_id)
  return true
end
function Lobby_Mid_Squad_Tips_UIBP:GetRecommendType2()
  log(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:GetRecommendType2 \229\129\156\231\149\153\229\164\167\229\142\133\228\184\128\230\174\181\230\151\182\233\151\180\229\144\142\232\167\166\229\143\145\232\142\183\229\143\150\230\142\168\232\141\144")
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  local squadId, preTeamId = logic_flash_match_team:getRecommendType2Squad()
  if not squadId then
    log(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:GetRecommendType2 \229\189\147\229\137\141\230\151\160\230\142\168\232\141\144\229\176\143\233\152\159")
    return false
  end
  if preTeamId then
    self:RefreshShow(ShowType.condition2, squadId, preTeamId)
  else
    self:RefreshShow(ShowType.condition3, squadId, preTeamId)
  end
  return true
end
function Lobby_Mid_Squad_Tips_UIBP:GetRecommendType3(gameMode)
  log(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:GetRecommendType3 \229\136\135\230\141\162\230\168\161\229\188\143\229\144\142\232\167\166\229\143\145\232\142\183\229\143\150\230\142\168\232\141\144")
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  local logic_mode_utils = require("client.slua.logic.mode_selection.logic_mode_utils")
  local modeName = logic_mode_utils.GetModeNameByModeID(gameMode) or ""
  local squadId, preTeamId, squadName = logic_flash_match_team:getRecommendType3Squad(gameMode)
  if squadId then
    if preTeamId then
      self:RefreshShow(ShowType.condition6, squadId, preTeamId)
    else
      self:RefreshShow(ShowType.condition7, squadId)
    end
    return true
  end
  self:ReqSeverRecommend(10, gameMode, RecommendType.ModeSwitch)
  return false
end
function Lobby_Mid_Squad_Tips_UIBP:GetRecommendType4()
  log(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:GetRecommendType4")
  local logic_teamquick_join = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_teamquick_join)
  local preferMode = logic_teamquick_join:GetPreferModesOver60Percent()
  if preferMode then
    self.weeklyDominantMainId = preferMode
    self:ReqSeverRecommend(10, nil, RecommendType.WeeklyLogin)
    return true
  end
  return false
end
function Lobby_Mid_Squad_Tips_UIBP:GetRecommendType5()
  log(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:GetRecommendType5")
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  local RQTList = logic_flash_match_team:GetRQTList()
  if RQTList then
    for idx, info in ipairs(RQTList) do
      if idx == 1 then
        self:RefreshShow(ShowType.condition10)
        self:ShowTip()
        return true
      end
    end
  end
end
function Lobby_Mid_Squad_Tips_UIBP:GetRecommendType6()
  log(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:GetRecommendType6")
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  if logic_flash_match_team:checkRecommendType6Condition() then
    return true
  end
end
function Lobby_Mid_Squad_Tips_UIBP:ReqSeverRecommend(count, matchMode, rcmdType)
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  local cooldown = 3
  local nowSec = os.time()
  if self.lastReqRecommendTime and cooldown > nowSec - self.lastReqRecommendTime then
    log_format(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:ReqSeverRecommend skipped by cooldown, recommendType:%s", self.recommendType)
    return
  end
  self.lastReqRecommendTime = nowSec
  self.recommendType = rcmdType or RecommendType.DelayRecommend
  local modeIds = {}
  if matchMode then
    modeIds[#modeIds + 1] = matchMode
  end
  FlashTeamHandler.send_get_flash_squad_recommend_req(count or 10, {game_mode_ids = modeIds})
end
function Lobby_Mid_Squad_Tips_UIBP:RefreshShow(type, squadId, preTeamId, rcmdSquad)
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  if squadId then
    if preTeamId then
      log_format(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:RefreshShow recommended squad:%s pre-team:%s", squadId, preTeamId)
    else
      log_format(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:RefreshShow recommended squad:%s", squadId)
    end
    logic_flash_match_team:SetCurRecomTeam(squadId, preTeamId)
  elseif rcmdSquad then
    log_format(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:RefreshShow \230\156\141\229\138\161\229\153\168\230\142\168\232\141\144\229\176\143\233\152\159:%s", rcmdSquad.squad_id)
    logic_flash_match_team:SetCurRecomTeam(rcmdSquad.squad_id)
  else
    logic_flash_match_team:SetCurRecomTeam()
  end
  self:RefreshUIType()
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.FlashSquad_Guide_Log, type, 0)
  self.curLogType = type
  log_format(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:RefreshShow \232\174\190\231\189\174\230\142\168\232\141\144\231\177\187\229\158\139 type:%s", type)
  if ShowType.condition1 == type then
    self.UIRoot.TextBlock_1:SetText(LocUtil.LocalizeResFormat(817119))
  elseif ShowType.condition2 == type then
    local teamInfo = logic_flash_match_team:GetFlashTeamSummaryById(squadId)
    local preTeam = teamInfo and teamInfo.pre_teams and teamInfo.pre_teams[preTeamId]
    if preTeam then
      local membersBrief = logic_flash_match_team:GetFlashTeamMembersById(squadId)
      local teamName = teamInfo and teamInfo.name or ""
      local logic_mode_utils = require("client.slua.logic.mode_selection.logic_mode_utils")
      local modeName = logic_flash_match_team:GetModeMapName()
      self.UIRoot.TextBlock_1:SetText(LocUtil.LocalizeResFormat(817120, teamName, modeName))
    else
      log(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:RefreshShow preTeam is nil")
    end
  elseif ShowType.condition3 == type then
    local teamInfo = logic_flash_match_team:GetFlashTeamSummaryById(squadId)
    local teamName = teamInfo and teamInfo.name or ""
    self.UIRoot.TextBlock_1:SetText(LocUtil.LocalizeResFormat(817121, teamName))
  elseif ShowType.condition4 == type then
    local scoreTxt = LocUtil.LocalizeResFormat(10283, rcmdSquad and rcmdSquad.display_score or 0)
    self.UIRoot.TextBlock_1:SetText(LocUtil.LocalizeResFormat(817122, scoreTxt))
  elseif ShowType.condition5 == type then
    self.UIRoot.TextBlock_1:SetText(LocUtil.LocalizeResFormat(817123))
    logic_flash_match_team:SetJumpTeamMainHighlight(true)
  elseif ShowType.condition6 == type then
    local teamInfo = logic_flash_match_team:GetFlashTeamSummaryById(squadId)
    local preTeam = teamInfo and teamInfo.pre_teams and teamInfo.pre_teams[preTeamId]
    if preTeam then
      local membersBrief = logic_flash_match_team:GetFlashTeamMembersById(squadId)
      local teamName = teamInfo and teamInfo.name or ""
      local modeName = logic_flash_match_team:GetModeMapName()
      self.UIRoot.TextBlock_1:SetText(LocUtil.LocalizeResFormat(817120, teamName, modeName))
      return true
    else
      log(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:RefreshShow preTeam is nil")
    end
  elseif ShowType.condition7 == type then
    local teamInfo = logic_flash_match_team:GetFlashTeamSummaryById(squadId)
    local teamName = teamInfo and teamInfo.name or ""
    local modeName = logic_flash_match_team:GetModeMapName()
    self.UIRoot.TextBlock_1:SetText(LocUtil.LocalizeResFormat(817128, teamName, modeName))
  elseif ShowType.condition8 == type then
    local modeName = logic_flash_match_team:GetModeMapName()
    self.UIRoot.TextBlock_1:SetText(LocUtil.LocalizeResFormat(817124, modeName))
  elseif ShowType.condition9 == type then
    local logic_mode_utils = require("client.slua.logic.mode_selection.logic_mode_utils")
    local modeName = logic_flash_match_team:GetModeMapName()
    self.UIRoot.TextBlock_1:SetText(LocUtil.LocalizeResFormat(817124, modeName))
  elseif ShowType.condition10 == type then
    local RQTList = logic_flash_match_team:GetRQTList()
    local score = 0
    if RQTList then
      for idx, info in ipairs(RQTList) do
        if idx == 1 then
          score = 90
          logic_flash_match_team:SetRQTTeamIdx(idx)
          break
        end
      end
    end
    self.UIRoot.TextBlock_1:SetText(LocUtil.LocalizeResFormat(817125, score))
    logic_flash_match_team:SetCurRecomTeam()
  elseif ShowType.condition11 == type then
    local scoreTxt = LocUtil.LocalizeResFormat(10283, rcmdSquad and rcmdSquad.display_score or 0)
    self.UIRoot.TextBlock_1:SetText(LocUtil.LocalizeResFormat(817122, scoreTxt))
  end
  log_format(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:RefreshShow \232\174\190\231\189\174\230\152\190\231\164\186\230\150\135\230\156\172 type:%s", self.UIRoot.TextBlock_1:GetText())
end
function Lobby_Mid_Squad_Tips_UIBP:RefreshUIType(typeId)
  self:SetWidgetVisible(self.UIRoot.TextBlock_1, true)
  self:SetWidgetVisible(self.UIRoot.TextBlock_0, false)
  if typeId == UIShowType.ShowIcon then
    self:SetWidgetVisible(self.UIRoot.Panel_Award, true)
  else
    self:SetWidgetVisible(self.UIRoot.Panel_Award, false)
  end
end
function Lobby_Mid_Squad_Tips_UIBP:RefreshNewSeasonTips()
  local logic_teamquick_guide = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_teamquick_guide)
  local hasShowLobbyGuide = logic_teamquick_guide:CheckHasShowLobbyGuide()
  if not hasShowLobbyGuide then
    log(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:RefreshNewSeasonTips hasShowLobbyGuide = false")
    return false
  end
  local logic_flash_team_season = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_team_season)
  logic_flash_team_season:CheckAndExecuteReminder(logic_flash_team_season.ReminderType.Lobby_Tips_Remind, function()
    log(bWriteLog and "Lobby_Mid_Squad_Tips_UIBP:RefreshNewSeasonTips show new season tips")
    self:RefreshUIType(UIShowType.ShowIcon)
    self.UIRoot.TextBlock_1:SetText(LocUtil.LocalizeResFormat(817230))
    self:ShowTip(true)
    return true
  end)
end
function Lobby_Mid_Squad_Tips_UIBP:SetDefaultRecommendMode(gameMode)
  self.defaultRecommendMode = gameMode
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, Lobby_Mid_Squad_Tips_UIBP)