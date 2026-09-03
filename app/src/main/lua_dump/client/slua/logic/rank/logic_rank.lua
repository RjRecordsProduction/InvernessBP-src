local RankSystem = {}
RankSystem.RankDataMgr = require("client.slua.logic.rank.rank_data_mgr")
RankSystem.RankNetHandler = require("client.slua.logic.rank.rank_net_handler")
local RankConfig = require("client.slua.logic.rank.rank_config")
local RankSelectEnum = RankConfig.RankSelectEnum
local RankDataMgr = RankSystem.RankDataMgr
local RegionEnum = RankConfig.RegionEnum
local PeriodEnum = RankConfig.PeriodEnum
local MemberEnum = RankConfig.MemberEnum
function RankSystem.OnModePostSwitch(preState, nextState)
  if nextState == GameStatus.Lobby then
    RankDataMgr.SetRankSelectType(RankSelectEnum.sum)
    RankDataMgr.SetRankRegionType(RegionEnum.all)
    RankDataMgr.SetRankSelectMemberType(MemberEnum.team)
    RankDataMgr.SetPlanPHType(RankConfig.PlanPHEnum.prosperity)
    RankDataMgr.SetWoWAuthorType(RankConfig.WoWAuthorEnum.level)
  end
end
function RankSystem.OnJumpUrl(eventType, eventID, vars)
  local rankTo = ""
  local region = RegionEnum.all
  local period = PeriodEnum.total
  local planPHType = RankConfig.PlanPHEnum.prosperity
  local WoWAuthorType = RankConfig.WoWAuthorEnum.level
  if vars and vars.to then
    rankTo = tostring(vars.to)
  end
  if vars and vars.region then
    region = vars.region
  end
  if vars and vars.period then
    period = vars.period
  end
  if vars and vars.planPHType then
    planPHType = vars.planPHType
  end
  if vars and vars.WoWAuthorType then
    WoWAuthorType = vars.WoWAuthorType
  end
  if region == RegionEnum.friend then
    RankDataMgr.SetRankRegionType(RegionEnum.friend)
  else
    RankDataMgr.SetRankRegionType(RegionEnum.all)
  end
  if period == PeriodEnum.week then
    RankDataMgr.SetRankPeriodType(PeriodEnum.week)
  else
    RankDataMgr.SetRankPeriodType(PeriodEnum.total)
  end
  RankDataMgr.SetPlanPHType(planPHType)
  RankDataMgr.SetWoWAuthorType(WoWAuthorType)
  if rankTo == RankSelectEnum.career then
    RankSystem.EventEnterRank(RankSelectEnum.career)
  elseif rankTo == RankSelectEnum.arena then
    RankSystem.EventEnterRank(RankSelectEnum.arena)
  elseif rankTo == RankSelectEnum.popularity then
    RankSystem.EventEnterRank(RankSelectEnum.popularity)
  elseif rankTo == RankSelectEnum.pround then
    RankSystem.EventEnterRank(RankSelectEnum.pround)
  elseif rankTo == RankSelectEnum.planPH then
    RankSystem.EventEnterRank(RankSelectEnum.planPH)
  elseif rankTo == RankSelectEnum.wow then
    RankSystem.EventEnterRank(RankSelectEnum.wow)
  elseif rankTo == RankSelectEnum.peak then
    RankSystem.EventEnterRank(RankSelectEnum.peak)
  else
    RankSystem.EventEnterRank(rankTo)
  end
end
function RankSystem.EventEnterRank(type)
  if not LobbySystem.CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_RANK) then
    return
  end
  local LogicPeakGameUtil = require("client.logic.PeakGame.LogicPeakGameUtil")
  local isPeakOpen = LogicPeakGameUtil.IsInRankOpenTime()
  if not type or type == RankSelectEnum.peak then
    type = isPeakOpen and RankSelectEnum.peak or RankSelectEnum.sum
  end
  UIManager.ShowUI(UIManager.UI_Config.ui_rank, type)
end
function RankSystem.InitRankData()
  local rank_ctrl = require("client.slua.logic.rank.rank_ctrl")
  local rank_data = require("client.slua.logic.rank.rank_data")
  rank_data.InitData()
  rank_ctrl.InitMyRankInfo()
end
function RankSystem.BeforeOpening()
  local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
  LobbySocialSystem.get_achievement_summary_req(DataMgr.roleData.uid)
  LobbySystem.CloseOtherMenu()
  local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
  logic_chat_voice:HideAntsVoiceUI()
  local LogicPeakGame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGame)
  LogicPeakGame:ReqPeakGameInfo(false)
end
function RankSystem.ReportHandle()
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.RankEntrance)
  local gem_report_utils = require("client.logic.store.gem_report_utils")
  gem_report_utils.ReportBtnClickEvent(gem_report_utils.SubEventName_RankEntrance)
end
function RankSystem.IsUPassOpened()
  local isUPassOpened = LobbySystem.CheckOpen(BP_ENUM_LOBBY_MENU_UNKNOW_PASS)
  return isUPassOpened
end
function RankSystem.GetTabStyle(clickStyle)
  local select = clickStyle or RankDataMgr.GetRankSelectType()
  local temp
  if select == RankSelectEnum.tpp then
    temp = {isTpp = true}
  elseif select == RankSelectEnum.fpp then
    temp = {isFpp = true}
  elseif RankDataMgr.IsTpp() then
    temp = {isTpp = true, isSub = true}
  elseif RankDataMgr.IsFpp() then
    temp = {isFpp = true, isSub = true}
  elseif select == RankSelectEnum.like then
    temp = {isLike = true}
  elseif select == RankSelectEnum.upass then
    temp = {isUPass = true}
  elseif select == RankSelectEnum.pve then
    temp = {isPve = true}
  elseif select == RankSelectEnum.charisma then
    temp = {isCharisma = true}
  elseif select == RankSelectEnum.arena then
    temp = {isArena = true}
  elseif select == RankSelectEnum.achievement then
    temp = {isAchievement = true}
  elseif select == RankSelectEnum.career then
    temp = {isCareer = true}
  elseif select == RankSelectEnum.gift then
    temp = {isGift = true}
  elseif RankDataMgr.IsGift() then
    temp = {isGift = true, isSub = true}
  elseif RankDataMgr.IsIntimacy() then
    temp = {isIntimacy = true}
  elseif select == RankSelectEnum.planPH then
    temp = {isPlanPH = true}
  elseif select == RankSelectEnum.wow_author then
    temp = {isWoW = true, isSub = true}
  elseif select == RankSelectEnum.wow_author_level then
    temp = {isWoW = true, isSub = true}
  elseif select == RankSelectEnum.wow then
    temp = {isWoW = true}
  elseif select == RankSelectEnum.peakgame then
    temp = {isPeakgame = true}
  elseif select == RankSelectEnum.weapon_usage_score then
    temp = {isWeaponUsageScore = true}
  end
  return temp
end
function RankSystem.IsShowPeopleSelection()
  local r = false
  local select = RankDataMgr.GetRankSelectType()
  if select == RankSelectEnum.sum then
    r = true
  elseif select == RankSelectEnum.win then
    r = true
  elseif select == RankSelectEnum.beat then
    r = true
  elseif select == RankSelectEnum.fpp_sum then
    r = true
  elseif select == RankSelectEnum.fpp_win then
    r = true
  elseif select == RankSelectEnum.fpp_beat then
    r = true
  elseif select == RankSelectEnum.peakgame_win then
    r = true
  end
  return r
end
function RankSystem.IsShowPlanPHTypeSelection()
  local r = false
  local select = RankDataMgr.GetRankSelectType()
  if select == RankSelectEnum.planPH then
    r = true
  end
  return r
end
function RankSystem.IsShowWeekSelection()
  local r = false
  local select = RankDataMgr.GetRankSelectType()
  if select == RankSelectEnum.like then
    r = true
  elseif select == RankSelectEnum.popularity then
    r = true
  elseif select == RankSelectEnum.pround then
    r = true
  elseif select == RankSelectEnum.guardian then
    r = true
  elseif select == RankSelectEnum.lover then
    r = true
  elseif select == RankSelectEnum.bestie then
    r = true
  elseif select == RankSelectEnum.homie then
    r = true
  elseif select == RankSelectEnum.bestFriend then
    r = true
  elseif select == RankSelectEnum.family then
    r = true
  elseif select == RankSelectEnum.wow_author then
    local SubSelect = RankDataMgr.GetWoWAuthorType()
    if SubSelect == RankConfig.WoWAuthorEnum.popularity then
      r = true
    end
  elseif select == RankSelectEnum.peakgame_win then
    r = true
  end
  return r
end
function RankSystem.IsShowRangeSelection()
  local r = true
  local select = RankDataMgr.GetRankSelectType()
  if select == RankSelectEnum.lover then
    r = false
  elseif select == RankSelectEnum.bestie then
    r = false
  elseif select == RankSelectEnum.homie then
    r = false
  elseif select == RankSelectEnum.bestFriend then
    r = false
  elseif select == RankSelectEnum.family then
    r = false
  elseif select == RankSelectEnum.wow_author then
    r = false
  elseif select == RankSelectEnum.peakgame_win then
    r = false
  elseif select == RankSelectEnum.weapon_usage_score then
    r = false
  end
  return r
end
function RankSystem.IsShowHelp()
  local r = true
  local select = RankDataMgr.GetRankSelectType()
  if select == RankSelectEnum.upass then
    r = false
  elseif select == RankSelectEnum.pve then
    r = false
  elseif select == RankSelectEnum.arena then
    r = false
  elseif select == RankSelectEnum.achievement then
    r = false
  elseif select == RankSelectEnum.career then
    r = false
  end
  return r
end
function RankSystem.GetHelpContent()
  local content = ""
  local select = RankDataMgr.GetRankSelectType()
  local RankDataMgr = require("client.slua.logic.rank.rank_data_mgr")
  if select == RankSelectEnum.sum or select == RankSelectEnum.fpp_sum then
    content = LocUtil.GetLocalizeStrConcatenation(29852)
  elseif select == RankSelectEnum.win or select == RankSelectEnum.sum.fpp_win then
    content = LocUtil.GetLocalizeStrConcatenation(29853)
  elseif select == RankSelectEnum.beat or select == RankSelectEnum.fpp_beat then
    content = LocUtil.GetLocalizeStrConcatenation(29854)
  elseif select == RankSelectEnum.charisma then
    content = LocUtil.GetLocalizeStrConcatenation(29855)
  elseif select == RankSelectEnum.arena then
    content = LocUtil.GetLocalizeStrConcatenation(29856)
  elseif select == RankSelectEnum.like then
    content = LocUtil.LocalizeFormatConcatenation(29858, 20)
  elseif select == RankSelectEnum.popularity then
    content = LocUtil.LocalizeFormatConcatenation(43249)
  elseif select == RankSelectEnum.pround then
    content = LocUtil.LocalizeFormatConcatenation(43249)
  elseif select == RankSelectEnum.guardian then
    content = LocUtil.LocalizeFormatConcatenation(43249)
  elseif select == RankSelectEnum.lover then
    content = LocUtil.LocalizeFormatConcatenation(77130)
  elseif select == RankSelectEnum.bestie then
    content = LocUtil.LocalizeFormatConcatenation(77130)
  elseif select == RankSelectEnum.homie then
    content = LocUtil.LocalizeFormatConcatenation(77130)
  elseif select == RankSelectEnum.bestFriend then
    content = LocUtil.LocalizeFormatConcatenation(77130)
  elseif select == RankSelectEnum.family then
    content = LocUtil.LocalizeFormatConcatenation(77130)
  elseif select == RankSelectEnum.planPH then
    content = LocUtil.LocalizeFormatConcatenation(655444, 24, 2)
  elseif select == RankSelectEnum.wow or select == RankSelectEnum.wow_author or select == RankSelectEnum.wow_play_level then
    content = LocUtil.LocalizeFormatConcatenation(82245)
  elseif RankDataMgr.IsPeakGameRanking(select) then
    local season_id = DataMgr.season_id
    log(bWriteLog and "RankSystem.GetHelpContent season_id = " .. tostring(season_id))
    if season_id < 41 then
      content = LocUtil.LocalizeFormatConcatenation(68579)
    else
      content = LocUtil.LocalizeFormatConcatenation(68288)
    end
  else
    content = LocUtil.GetLocalizeStrConcatenation(29859)
  end
  if content == nil then
    content = ""
  end
  return content
end
function RankSystem.IsShowWoWAuthorTypeSelection()
  local r = false
  local select = RankDataMgr.GetRankSelectType()
  if select == RankSelectEnum.wow_author then
    r = true
  end
  return r
end
function RankSystem.IsShowWeaponSelection()
  local r = false
  local select = RankDataMgr.GetRankSelectType()
  if select == RankSelectEnum.weapon_usage_score then
    r = true
  end
  return r
end
function RankSystem.IsShowButton_LBS()
  if DataMgr.season_id < 48 then
    return false
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
    return false
  end
  local bShow = false
  local select = RankDataMgr.GetRankSelectType()
  if select == RankSelectEnum.weapon_usage_score then
    bShow = true
  end
  local LbsMgr = require("client.slua.logic.lbs.logic_lbs")
  local bOpen = LobbySystem.CheckOpen(LbsMgr.LABEL_SWITCH_WWARZONE)
  return bShow and bOpen
end
return RankSystem