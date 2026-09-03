local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
local PufferConst = require("client.slua.logic.download.puffer_const")
local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
local XMissionUIConfig = require("client.slua.logic.TxMission.logic_xmission_uiconfig")
local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
local LogicTxMissionMain = {
  MONEY_ID_GOLD_FASTENER = 1301,
  TPLAN_TICKET_ID = 1310,
  bHasGetBaseInfo = false,
  metro_cur_profit = 0,
  metro_max_profit = 0,
  profit_awards = {},
  prestige = 0,
  prestige_level = 1,
  moneys = {},
  totalTalentPoint = 0,
  has_auto_show_warpre = false,
  levelUpData = nil,
  waitJoinTeamUID = nil,
  C_Single2NpcLS = 64,
  C_Team2NpcLS = 65,
  C_Npc2SingleLS = 66,
  C_Npc2TeamLS = 67,
  C_MaxPrestigeLevel = nil,
  entry_actor = nil,
  entry_ui = nil,
  bCurBattleGuideIsShow = false,
  bIsReconnect = false,
  bNewMailTips = false,
  BackupShadowQuality = 1,
  BattleResultReason = false,
  banWindowShowTimer = nil,
  banWindowShow = false,
  command_post_reddot_num = 0,
  bCheckCommandPostLevelExtendGuide = false,
  bEnterXMissionReq = false,
  timerResetIsInXMission = nil,
  bEnterXMissionFromScroll = nil,
  cur_select_index = 0,
  oldPrestigeLevel = 1
}
local _isInXMission = false
local E_ChangeTeamType = {L2X = 1, X2L = 2}
local XMission_Wardrobe_JumpType = {QuickJump = "QuickJump"}
LogicTxMissionMain.LogicTxMissionMain.local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
local xMissionEnterKey = PlayerPrefsSystem.ePlayerPrefsType.eXMissionEnter
function LogicTxMissionMain.SetEnterXMissionFrom(from)
  log(bWriteLog and string.format("LogicTxMissionMain.SetEnterXMissionFrom. from=%s", tostring(from)))
  local isFromScroll = from == ENUM_XMISSION_FROM.Scroll
  LogicTxMissionMain.bEnterXMissionFromScroll = isFromScroll
  local table = PlayerPrefsSystem.LoadFileToTable_N(xMissionEnterKey) or {}
  table.  PlayerPrefsSystem.SaveTableToFile_N(table, xMissionEnterKey)
end
function LogicTxMissionMain.IsEnterXMissionFromScroll()
  log(bWriteLog and "LogicTxMissionMain.IsEnterXMissionFromScroll. bEnterXMissionFromScroll" .. tostring(LogicTxMissionMain.bEnterXMissionFromScroll))
  if LogicTxMissionMain.bEnterXMissionFromScroll ~= nil then
    return LogicTxMissionMain.bEnterXMissionFromScroll
  end
  local table = PlayerPrefsSystem.LoadFileToTable_N(xMissionEnterKey) or {}
  log(bWriteLog and "LogicTxMissionMain.IsEnterXMissionFromScroll. from" .. tostring(table.from))
  local isFromScroll = table.from == ENUM_XMISSION_FROM.Scroll
  LogicTxMissionMain.bEnterXMissionFromScroll = isFromScroll
  return isFromScroll
end
function LogicTxMissionMain.OnPostSwitchGameStatus(_, _, status)
  log(bWriteLog and "[muidarzhang] LogicTxMissionMain.OnPostSwitchGameStatus")
  local pre = status.pre
  local next = status.current
  local ScriptHelperEngine = import("ScriptHelperEngine")
  if ScriptHelperEngine.IsLowMemoryDevice() then
    local gc_util = require("common.gc_util")
    gc_util.FullGC()
  end
  if next == GameStatus.Login then
    log(bWriteLog and "[muidarzhang] LogicTxMissionMain.OnPostSwitchGameStatus, status = login.")
    log(bWriteLog and "LogicTxMissionMain.OnPostSwitchGameStatus 1 set _isInXMission false")
    _isInXMission = false
    LogicTxMissionMain.levelUpData = nil
    LogicTxMissionMain.DestroyData()
  elseif next == GameStatus.Fighting and not GameStatus.IsInMainCity() then
    log(bWriteLog and "[muidarzhang] LogicTxMissionMain.OnPostSwitchGameStatus, status = fighting.")
    LogicTxMissionMain.DestroyData()
  elseif next == GameStatus.Lobby then
    log(bWriteLog and "[muidarzhang] LogicTxMissionMain.OnPostSwitchGameStatus, status = lobby.")
    local time_ticker = require("common.time_ticker")
    time_ticker.AddTimerOnce(1.5, function()
      LogicTxMissionMain.ShowOrHidePanel()
    end)
    local LogicTxMissionDownload = require("client.slua.logic.TxMission.logic_xmission_download")
    if LogicTxMissionMain.bIsReconnect then
      LogicTxMissionMain.Reconnect()
    elseif LogicTxMissionMain.IsInXMission() and GameStatus.IsPostSwitchEnterLobbyOrMainCityFromFighting(pre, next) then
      log(bWriteLog and "[teddysjwu] LogicTxMissionMain.OnPostSwitchGameStatus, IsInXMission. OpenTPlan")
      time_ticker.AddTimerOnce(0.1, function()
        GlobalData.StopLobbyBGM()
        LogicTxMissionDownload.OpenTPlan("fight")
      end)
    else
      log(bWriteLog and "LogicTxMissionMain.OnPostSwitchGameStatus 2 set _isInXMission false")
      _isInXMission = false
    end
    local MatchSystem = require("client.slua.logic.match.logic_match")
    MatchSystem.QueryPlayerState()
  end
  LogicTxMissionMain.banWindowShow = false
end
function LogicTxMissionMain.CheckIsTPlanMode(mode)
  if not mode or mode == "" then
    return false
  end
  local mapModeInfo = CDataTable.GetTableData("TxMissionMapMode", mode)
  if mapModeInfo then
    return true
  end
  local SubModeCfg = CDataTable.GetTableData("BTMode", tonumber(mode))
  local StringUtil = require("common.string_util")
  if SubModeCfg and StringUtil.StrFind(SubModeCfg.ModType, "TPlan") then
    return true
  end
  return false
end
function LogicTxMissionMain.OnLogin(bReLogin)
  log(bWriteLog and "[muidarzhang] LogicTxMissionMain.OnLogin(bReLogin)")
  if bReLogin then
    LogicTxMissionMain.ReconnectXMission()
  end
end
function LogicTxMissionMain.InitOnlyOne()
  EventSystem:registEvent(EVENTTYPE_TEAMUP, EVENTID_TEAM_PLATFORM_QUIT_TEAM_SUC_AND_APPLY, LogicTxMissionMain.OnQuitTeamAndNext)
  EventSystem:registEvent(EVENTTYPE_CAMERA, EVENTID_CAMERA_SWITCHED, LogicTxMissionMain.OnCameraSwitched)
  EventSystem:registEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_POST_SWITCH, LogicTxMissionMain.OnPostSwitchGameStatus)
end
function LogicTxMissionMain.CheckAndDestroyEnterParticleEmitter()
  local time_ticker = require("common.time_ticker")
  local open = LobbySystem.CheckOpen(BP_ENUM_LOBBY_MENU_TXMISSION)
  local needShowHallTheme = LogicTxMissionMain.CheckHallThemeNeedShowEntry()
  local ScriptHelperEngine = import("ScriptHelperEngine")
  if ScriptHelperEngine.IsLowMemoryDevice() then
    local gc_util = require("common.gc_util")
    gc_util.FullGC()
  end
  local cfg = CDataTable.GetTableData("TxMissionExtra", "metro_level_limit")
  local levelLimit = false
  if cfg and cfg.value and tonumber(cfg.value) > 0 and DataMgr.roleData.level < tonumber(cfg.value) then
    levelLimit = true
  end
  if not (open and not Client.IsWindowOB() and needShowHallTheme) or levelLimit then
    time_ticker.AddTimerOnce(0.1, LobbySceneManager.DestroyXmissionEnterEmitter)
    time_ticker.AddTimerOnce(2.1, LobbySceneManager.DestroyXmissionEnterEmitter)
  end
end
function LogicTxMissionMain.IsBlackMarketSystemOpen(showTips)
  return LogicTxMissionMain.IsSubSystemOpen("market_open_lv", showTips)
end
function LogicTxMissionMain.IsMissionSystemOpen(showTips)
  return LogicTxMissionMain.IsSubSystemOpen("mission_open_lv", showTips)
end
function LogicTxMissionMain.IsPrestigeAwardSystemOpen(showTips)
  return LogicTxMissionMain.IsSubSystemOpen("level_reward_open_lv", showTips)
end
function LogicTxMissionMain.IsTalentSystemOpen(showTips)
  return LogicTxMissionMain.IsSubSystemOpen("mastery_open_lv", showTips)
end
function LogicTxMissionMain.IsCultivateSystemOpen(showTips)
  return LogicTxMissionMain.IsSubSystemOpen("cultivate_open_lv", showTips)
end
function LogicTxMissionMain.IsConsoleGuideOpen(showTips)
  return LogicTxMissionMain.IsSubSystemOpen("console_guide_open_lv", showTips)
end
function LogicTxMissionMain.IsRPGuideOpen(showTips)
  return LogicTxMissionMain.IsSubSystemOpen("rp_guide_open_lv", showTips)
end
function LogicTxMissionMain.IsSouvenirsGuideOpen(showTips)
  return LogicTxMissionMain.IsSubSystemOpen("souvenirs_guide_open_lv", showTips)
end
function LogicTxMissionMain.IsWarPresetGuideOpen(showTips)
  return LogicTxMissionMain.IsSubSystemOpen("war_preset_guide_open_lv", showTips)
end
function LogicTxMissionMain.IsBagExtendGuideOpen(showTips)
  return LogicTxMissionMain.IsSubSystemOpen("bag_extend_guide_open_lv", showTips)
end
function LogicTxMissionMain.IsAffixOpen(showTips)
  return LogicTxMissionMain.IsSubSystemOpen("affix_open_lv", showTips)
end
function LogicTxMissionMain.IsRnakOpen(showTips)
  return LogicTxMissionMain.IsSubSystemOpen("rank_open_lv", showTips)
end
function LogicTxMissionMain.IsRepairGuideOpen(showTips)
  return LogicTxMissionMain.IsSubSystemOpen("repair_guide_open_lv", showTips)
end
function LogicTxMissionMain.IsInsuranceGuideOpen(showTips)
  return LogicTxMissionMain.IsSubSystemOpen("insurance_open_lv", showTips)
end
function LogicTxMissionMain.IsSubSystemOpen(systemKey, showTips)
  local cfg = CDataTable.GetTableData("TxMissionExtra", systemKey)
  if not cfg then
    return false
  end
  local prestige_level = tonumber(LogicTxMissionMain.prestige_level) or 0
  local value = tonumber(cfg.value)
  if showTips and prestige_level < value then
    ShowNotice(LocUtil.LocalizeResFormat(35181, value))
  end
  return prestige_level >= value
end
function LogicTxMissionMain.IsInXMission(checkIsOpen)
  if IsWoWEditor then
    return false
  end
  if checkIsOpen == nil then
    checkIsOpen = false
  end
  if checkIsOpen then
    local logic_xmission_entrance = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_entrance)
    if not logic_xmission_entrance:IsTxMissionOpen() then
      return false
    end
  end
  if _isInXMission then
    log(bWriteLog and "[muidarzhang] LogicTxMissionMain.IsInXMission1, true. ")
    return true
  end
  log(bWriteLog and "[muidarzhang] LogicTxMissionMain.IsInXMission2  metro_team_flag", TeamUpNewSystem.teamInfo and TeamUpNewSystem.teamInfo.metro_team_flag)
  if TeamUpNewSystem.teamInfo and TeamUpNewSystem.teamInfo.metro_team_flag and TeamUpNewSystem.GetTeamNum() > 1 then
    log(bWriteLog and "[muidarzhang] LogicTxMissionMain.IsInXMission2, true. ")
    return true
  end
  return false
end
local C_XmissionUIList = {
  {
    uiconfig = UIManager.UI_Config.xmission_download
  },
  {
    uiconfig = UIManager.UI_Config.xmission_team_main
  },
  {
    uiconfig = UIManager.UI_Config.xmission_wardrobe
  },
  {
    uiconfig = UIManager.UI_Config.xMission_Mode_Select
  },
  {
    uiconfig = UIManager.UI_Config.xMission_Mode_Select_Detail
  },
  {
    uiconfig = UIManager.UI_Config.xmission_task_main
  },
  {
    uiconfig = UIManager.UI_Config.xmission_task_brief
  },
  {
    uiconfig = UIManager.UI_Config.xmission_rank_ui
  },
  {
    uiconfig = UIManager.UI_Config.xmission_gift_packet
  },
  {
    uiconfig = UIManager.UI_Config.black_market_buy
  },
  {
    uiconfig = UIManager.UI_Config.black_market_sell
  },
  {
    uiconfig = UIManager.UI_Config.black_market_page
  },
  {
    uiconfig = UIManager.UI_Config.black_market_detail_component
  },
  {
    uiconfig = UIManager.UI_Config.xmission_npc_conversation
  },
  {
    uiconfig = UIManager.UI_Config.xmission_npc_dialog
  },
  {
    uiconfig = UIManager.UI_Config.xmission_voice_over_dialog
  },
  {
    uiconfig = UIManager.UI_Config.xmission_levelup
  },
  {
    uiconfig = UIManager.UI_Config.xmission_talent
  },
  {
    uiconfig = UIManager.UI_Config.xmission_part_store
  },
  {
    uiconfig = UIManager.UI_Config.xmission_season_main
  },
  {
    uiconfig = UIManager.UI_Config.xmission_season_detail
  },
  {
    uiconfig = UIManager.UI_Config.Xmission_Affix_UIBP
  }
}
function LogicTxMissionMain.IsInPureXMissionLobby()
  if not LogicTxMissionMain.IsInXMission() then
    return false
  end
  for _, v in pairs(C_XmissionUIList) do
    if UIManager.IsUIShow(v.uiconfig) then
      return false
    end
  end
  return true
end
function LogicTxMissionMain.GetZoneList()
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  local list = ZoneSystem.chooseZoneList
  local t = {}
  for i, v in ipairs(list) do
    local ZoneConfig = CDataTable.GetTableData("ZoneConfig", v.zone_id)
    if ZoneConfig then
      table.insert(t, ZoneConfig)
    end
  end
  return t
end
function LogicTxMissionMain.ReconnectXMission()
  if IsWoWEditor then
    return
  end
  if _isInXMission then
    local LogicTxMissionDownload = require("client.slua.logic.TxMission.logic_xmission_download")
    LogicTxMissionDownload.OpenTPlan("reconnect")
  end
end
function LogicTxMissionMain.EnterXMissionByInvite(teaminfo)
  log(bWriteLog and "[edward][logic_xmission_main] LogicTxMissionMain.EnterXMissionByInvite")
  if IsWoWEditor then
    return
  end
  if not GameStatus.IsInLobbyOrMainCity() then
    return
  end
  if not teaminfo then
    return
  end
  if not teaminfo.metro_team_flag then
    log(bWriteLog and "[edward][logic_xmission_main] LogicTxMissionMain.EnterXMissionByInvite, metro_team_flag = false")
    return
  end
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:IsRestrictBatlleAll() then
    TeamUpNewSystem.team_quit_request(TeamUpNewSystem.teamInfo.id, TeamUpNewSystem.E_QUIT_TYPE.QuitXMission)
    return
  end
  local LogicTxMissionDownload = require("client.slua.logic.TxMission.logic_xmission_download")
  if not LogicTxMissionDownload.CheckDevice() then
    log(bWriteLog and "[edward][logic_xmission_main] LogicTxMissionMain.EnterXMissionByInvite, CheckDevice is false")
    return
  end
  if not LogicTxMissionDownload.CheckResHasDownloaded() then
    log(bWriteLog and "[edward][logic_xmission_main] LogicTxMissionMain.EnterXMissionByInvite, CheckResHasDownloaded is false")
    TeamUpNewSystem.team_quit_request(TeamUpNewSystem.teamInfo.id, TeamUpNewSystem.E_QUIT_TYPE.QuitXMission)
    return
  end
  if _isInXMission then
    log(bWriteLog and "[edward][logic_xmission_main] LogicTxMissionMain.EnterXMissionByInvite, is in XMission")
    local XMissionTeamUpSystem = require("client.slua.logic.TxMission.logic_xmission_team")
    if TeamUpNewSystem.teamInfo and TeamUpNewSystem.teamInfo.members then
      for k, v in pairs(TeamUpNewSystem.teamInfo.members) do
        if tonumber(k) ~= TeamUpNewSystem.GetSelfUID() then
          XMissionTeamUpSystem.CreateAvatarInfo(k, v)
          if v.metro_team_info then
            XMissionTeamUpSystem.SetTeamInfo(k, v.metro_team_info, v.metro_scence_status)
          end
        end
      end
    end
    EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_JOIN)
    return
  end
  LogicTxMissionMain.CancelTeamPlatformRecruit()
  UIManager.CloseUI(UIManager.UI_Config.Team_Invite_Tip_UIBP)
  TeamUpNewSystem.RemoveAllInvite()
  if teaminfo.reconnect and tonumber(teaminfo.reconnect) == 1 then
    LogicTxMissionMain.SendEnterXMissionReq("reconnect")
  else
    LogicTxMissionMain.SendEnterXMissionReq("invite")
  end
end
function LogicTxMissionMain.EnterXMissionSuccess()
  log(bWriteLog and "LogicTxMissionMain.EnterXMissionSuccess")
  _isInXMission = true
  local TxMissionHandler = require("client.network.Protocol.TxMissionHandler")
  TxMissionHandler.send_report_enter_metro_scence()
end
function LogicTxMissionMain.QuitXMission(withoutConfirm, customExitFunc, TeamWithoutConfirm)
  if LobbySystem.isInMatch then
    ShowNotice(110017)
    return
  end
  local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
  local bIsInHomeMod = PlanPH_GamePlay_Tools and PlanPH_GamePlay_Tools.IsPHomeMode()
  if bIsInHomeMod then
    log(bWriteLog and "LogicTxMissionMain.QuitXMission bIsInHomeMod")
    return
  end
  local LogicTxMissionDownload = require("client.slua.logic.TxMission.logic_xmission_download")
  local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
  local showFunc = "ShowTPlan"
  if LogicTxMissionDownload.GetTPlanMapDownloadState(LogicTxMissionDownload.BASE_MAP_KEY) ~= PufferConst.ENUM_DownloadState.Done then
    showFunc = "Show"
  else
    LogicTxMissionMain.MountXMissionPak()
  end
  local title = LocUtil.GetLocalizeResStr(101001)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  if TeamUpNewSystem.GetTeamNum() > 1 then
    if TeamUpNewSystem.IsTeamLeader() then
      local callback = function()
        LogicTxMissionMain.CancelTeamPlatformRecruit()
        LogicTxMissionMain.ChangeTeamType(E_ChangeTeamType.X2L)
      end
      if TeamWithoutConfirm then
        callback()
      else
        do
          local content = LocUtil.GetLocalizeResStr(35195)
          CommonMsgBoxMgr[showFunc](2, title, content, function()
            callback()
          end)
        end
      end
    elseif TeamWithoutConfirm then
      TeamUpNewSystem.team_quit_request(TeamUpNewSystem.teamInfo.id, TeamUpNewSystem.E_QUIT_TYPE.QuitXMission)
    else
      local content = LocUtil.GetLocalizeResStr(35196)
      CommonMsgBoxMgr[showFunc](2, title, content, function()
        TeamUpNewSystem.team_quit_request(TeamUpNewSystem.teamInfo.id, TeamUpNewSystem.E_QUIT_TYPE.QuitXMission)
      end)
    end
  else
    local exitXMission = customExitFunc or function()
      LogicTxMissionMain.CancelTeamPlatformRecruit()
      LogicTxMissionMain.SendExitXMissionReq()
    end
    if withoutConfirm then
      exitXMission()
    else
      local content = LocUtil.GetLocalizeResStr(35195)
      CommonMsgBoxMgr[showFunc](2, title, content, exitXMission)
    end
  end
end
function LogicTxMissionMain.QuitXMissionByJoinTeam(uid)
  LogicTxMissionMain.waitJoinTeamUID = uid
  LogicTxMissionMain.QuitXMission(true)
end
function LogicTxMissionMain.QuitXMissionLocal()
  log(bWriteLog and "LogicTxMissionMain.QuitXMissionLocal")
  _isInXMission = false
end
function LogicTxMissionMain.QuitXMissionSuccess()
  log(bWriteLog and "LogicTxMissionMain.QuitXMissionSuccess")
  _isInXMission = false
  local TxMissionHandler = require("client.network.Protocol.TxMissionHandler")
  TxMissionHandler.send_report_exit_metro_scence()
end
function LogicTxMissionMain.ChangeTeamType(op)
  local time_ticker = require("common.time_ticker")
  LogicTxMissionMain.banWindowShow = true
  if not LogicTxMissionMain.banWindowShowTimer then
    LogicTxMissionMain.banWindowShowTimer = time_ticker.AddTimerOnce(3, function()
      LogicTxMissionMain.banWindowShow = false
      time_ticker.RemoveTimer(LogicTxMissionMain.banWindowShowTimer)
      LogicTxMissionMain.banWindowShowTimer = nil
    end)
  end
  local TxMissionHandler = require("client.network.Protocol.TxMissionHandler")
  TxMissionHandler.send_metro_trans_team_type_req(op)
end
function LogicTxMissionMain.OnQuitTeamAndNext(eventType, eventID, reason)
  if not reason then
    return
  end
  if reason == TeamUpNewSystem.E_QUIT_TYPE.EnterXMission then
    local LogicTxMissionDownload = require("client.slua.logic.TxMission.logic_xmission_download")
    LogicTxMissionDownload.OpenTPlan("quit")
  elseif reason == TeamUpNewSystem.E_QUIT_TYPE.QuitXMission then
    LogicTxMissionMain.SendExitXMissionReq()
  end
end
function LogicTxMissionMain.OnCameraSwitched(_, _, newCameraID)
  local ui_util = require("client.common.ui_util")
  local deviceLevel = ui_util.GetGameInstance():GetDeviceLevel()
  if 0 < deviceLevel then
    return
  end
  if not UIManager.IsUIShow(UIManager.UI_Config.loading) then
    return
  end
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  if newCameraID ~= Lobby_camera_manager_module.Enum_CameraID.Lobby_Default then
    return
  end
  if not LogicTxMissionMain.quitTLobbyLoadingTimer then
    return
  end
  local LoadingSystem = require("client.slua.logic.loading.logic_loading")
  local timer_tick = require("common.time_ticker")
  LoadingSystem.RefreshLoadPercent(1)
  timer_tick.RemoveTimer(LogicTxMissionMain.quitTLobbyLoadingTimer)
  LogicTxMissionMain.quitTLobbyLoadingTimer = nil
end
function LogicTxMissionMain.InitData(depot_capacity, metro)
  log_tree(bWriteLog and "[kkjhuang] LogicTxMissionMain.InitData depot_capacity", depot_capacity)
  log_tree(bWriteLog and "[kkjhuang] LogicTxMissionMain.InitData metro", metro)
  local ScriptHelperEngine = import("ScriptHelperEngine")
  if ScriptHelperEngine.IsLowMemoryDevice() then
    local gc_util = require("common.gc_util")
    gc_util.FullGC()
  end
  if metro then
    if metro.profit then
      LogicTxMissionMain.metro_cur_profit = metro.profit.cur_value or 0
      LogicTxMissionMain.profit_awards = metro.profit.awards or {}
      LogicTxMissionMain.metro_max_profit = metro.profit.max_value or 0
    else
      LogicTxMissionMain.metro_cur_profit = 0
      LogicTxMissionMain.profit_awards = {}
      LogicTxMissionMain.metro_max_profit = 0
    end
    LogicTxMissionMain.prestige = metro.prestige or 0
    LogicTxMissionMain.prestige_level = metro.prestige_level or 1
    LogicTxMissionMain.moneys = metro.moneys or {}
    if metro.mastery and metro.mastery.total_point then
      LogicTxMissionMain.totalTalentPoint = metro.mastery.total_point
    end
    local LogicTxMissionWarPre = require("client.slua.logic.TxMission.warpre.logic_xmission_warpre")
    LogicTxMissionWarPre.InitData(depot_capacity, metro)
    local XMissionNpcSystem = require("client.slua.logic.TxMission.logic_xmission_npc")
    if metro.npc then
      XMissionNpcSystem.InitData(metro.npc.npcs, metro.npc.effects, metro.npc.daily_send_gift_cnt)
    else
      XMissionNpcSystem.InitData()
    end
    local LogicTxMissionSeason = require("client.slua.logic.TxMission.season.logic_xmission_season")
    LogicTxMissionSeason.InitData(metro.season)
    local logic_xmission_souvenirs = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_souvenirs)
    logic_xmission_souvenirs:InitAchievementData(metro.achievement, metro.first_enter_season_index)
    if metro.bag_ext_capacity_info then
      local logic_xmission_bag_extend = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_bag_extend)
      logic_xmission_bag_extend:InitMetroData(metro.bag_ext_capacity_info)
    end
    LogicTxMissionMain.bHasGetBaseInfo = true
  end
end
function LogicTxMissionMain.DestroyData()
  LogicTxMissionMain.metro_cur_profit = 0
  LogicTxMissionMain.metro_max_profit = 0
  LogicTxMissionMain.profit_awards = {}
  LogicTxMissionMain.prestige = 0
  LogicTxMissionMain.prestige_level = 1
  LogicTxMissionMain.moneys = {}
  LogicTxMissionMain.has_auto_show_warpre = false
  LogicTxMissionMain.entry_ui = nil
  LogicTxMissionMain.entry_actor = nil
  LogicTxMissionMain.bHasGetBaseInfo = false
  LogicTxMissionMain.waitJoinTeamUID = nil
  local LogicTxMissionMatch = require("client.slua.logic.TxMission.match.logic_xmission_match")
  LogicTxMissionMatch.DestroyData()
  local LogicTxMissionWarPre = require("client.slua.logic.TxMission.warpre.logic_xmission_warpre")
  LogicTxMissionWarPre.DestroyData()
  local LogicTxMissionSeason = require("client.slua.logic.TxMission.season.logic_xmission_season")
  LogicTxMissionSeason.DestroyData()
  LogicTxMissionMain.BattleResultReason = false
  local ScriptHelperEngine = import("ScriptHelperEngine")
  if ScriptHelperEngine.IsLowMemoryDevice() then
    local gc_util = require("common.gc_util")
    gc_util.FullGC()
  end
end
function LogicTxMissionMain.GetMoney(ID)
  ID = ID or LogicTxMissionMain.MONEY_ID_GOLD_FASTENER
  if LogicTxMissionMain.moneys and LogicTxMissionMain.moneys[LogicTxMissionMain.MONEY_ID_GOLD_FASTENER] and tonumber(LogicTxMissionMain.moneys[LogicTxMissionMain.MONEY_ID_GOLD_FASTENER]) > 0 then
    return tonumber(LogicTxMissionMain.moneys[LogicTxMissionMain.MONEY_ID_GOLD_FASTENER]) or 0
  end
  return 0
end
function LogicTxMissionMain.GetTicket()
  local logic_xmission_warpre = require("client.slua.logic.TxMission.warpre.logic_xmission_warpre")
  local curNum = logic_xmission_warpre.GetItemNumByItemId(LogicTxMissionMain.TPLAN_TICKET_ID, true)
  return curNum
end
function LogicTxMissionMain.CanAffordCost(cost_id, cost_num)
  cost_num = cost_num or 0
  local hasMoney = LogicTxMissionMain.GetMoney(cost_id)
  hasMoney = hasMoney or 0
  if cost_num > hasMoney then
    ShowNotice(LocUtil.LocalizeResFormat(11343))
    return false
  else
    return true
  end
end
function LogicTxMissionMain.GetWorth()
  local XMissionTeamUpSystem = require("client.slua.logic.TxMission.logic_xmission_team")
  local uid = tostring(DataMgr.roleData.uid)
  local metroWorth = XMissionTeamUpSystem.GetTeamInfoMetroWorthByUid(uid)
  return metroWorth
end
function LogicTxMissionMain.GetCurProfit()
  return LogicTxMissionMain.metro_cur_profit
end
function LogicTxMissionMain.GetMaxProfit()
  return LogicTxMissionMain.metro_max_profit
end
function LogicTxMissionMain.GetPrestigeLevel()
  return LogicTxMissionMain.prestige_level or 0
end
function LogicTxMissionMain.GetProfitAwards()
  return LogicTxMissionMain.profit_awards or {}
end
function LogicTxMissionMain.ShowOrHidePanel(bForceClose)
  local bShow = LobbySystem.CheckOpen(BP_ENUM_LOBBY_MENU_TXMISSION)
  local isInXmission = LogicTxMissionMain.IsInXMission()
  if GameStatus.GetGameStatus() ~= GameStatus.Lobby then
    return
  end
  if Client.IsWindowOB() then
    bForceClose = true
  end
  LogicTxMissionMain.CheckAndDestroyEnterParticleEmitter()
end
function LogicTxMissionMain.CheckReEnterGame()
  if LobbySystem.enterGameTimeOutParams then
    log(bWriteLog and "[edward][logic_xmission_main] LogicTxMissionMain:CheckReEnterGame, time out msg box")
    UnrealNet.HandleNetworkException(table.unpack(LobbySystem.enterGameTimeOutParams))
    return true
  end
  local logic_enter_game = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_enter_game)
  if logic_enter_game.PendingReEnterInfo then
    log(bWriteLog and "[edward][logic_xmission_main] LogicTxMissionMain:CheckReEnterGame, reenter game msg box")
    logic_enter_game:on_re_enter_game(table.unpack(logic_enter_game.PendingReEnterInfo))
    return true
  end
  return false
end
function LogicTxMissionMain.CheckShowLevelUp()
  local levelUpData = LogicTxMissionMain.levelUpData
  if levelUpData then
    LogicTxMissionMain.oldPrestigeLevel = levelUpData.old_prestige_level
    UIManager.ShowUI(UIManager.UI_Config.xmission_levelup, levelUpData.old_prestige_level, levelUpData.new_prestige_level, levelUpData.award_list)
    LogicTxMissionMain.levelUpData = nil
    return true
  end
  LogicTxMissionMain.levelUpData = nil
  return false
end
function LogicTxMissionMain.CheckShowSpecialCollection()
  log(bWriteLog and "LogicTxMissionMain.CheckShowSpecialCollection")
  log_tree(bWriteLog and "LogicTxMissionMain.CheckShowSpecialCollection list=", LogicTxMissionMain.SpecialCollectionList)
  local specialCollectionList = LogicTxMissionMain.SpecialCollectionList
  if specialCollectionList and next(specialCollectionList) then
    UIManager.CloseUI(UIManager.UI_Config.Common_RightBottom_Tip_UIBP)
    local title = LocUtil.LocalizeResFormat(6719)
    local btnText = LocUtil.GetLocalizeResStr(4996)
    for _, itemData in pairs(specialCollectionList) do
      local itemID = itemData.item_id
      local count = itemData.count
      log(bWriteLog and string.format("[hatchertang] LogicTxMissionMain.CheckShowSpecialCollection itemID=%d count=%d", itemID, count))
      local itemInfo = CDataTable.GetTableData("Item", itemID)
      if itemInfo then
        do
          local content = LocUtil.LocalizeResFormat(74105, count, itemInfo.ItemName)
          local UIUtil = require("client.common.ui_util")
          local path = UIUtil.GetItemBigIcon(itemID)
          local callback = function()
            FuncUtil.ItemJump(itemID)
          end
          local jumpInfo = {btnText = btnText, callback = callback}
          UIManager.ShowUI(UIManager.UI_Config.xmission_RightBottom_Tip_UIBP, title, content, path, jumpInfo)
        end
      end
    end
  end
  LogicTxMissionMain.SpecialCollectionList = nil
end
function LogicTxMissionMain.CancelTeamPlatformRecruit()
  local TeamPlatformSystem = require("client.slua.logic.teamup.logic_team_platform")
  if TeamPlatformSystem.IsInRecruit() then
    local logic_lobby_my_team = require("client.slua.logic.teamup.logic_lobby_my_team")
    logic_lobby_my_team.CancelRecruit(true)
  end
end
function LogicTxMissionMain.CancelMentorWaiting()
  local MentorSystem = require("client.slua.logic.mentor.logic_mentor")
  if MentorSystem.waiting_status == MentorSystem.EWaitingStatus.Wait then
    MentorSystem.mentor_unregister_req()
  end
end
function LogicTxMissionMain.SendEnterXMissionReq(from)
  log(bWriteLog and string.format("[muidarzhang] LogicTxMissionMain.SendEnterXMissionReq, from:%s", from))
  if GameStatus.IsInFightingNotSocialNotMainCityNotHome() then
    return
  end
  local ScriptHelperEngine = import("ScriptHelperEngine")
  if ScriptHelperEngine.IsLowMemoryDevice() then
    local gc_util = require("common.gc_util")
    gc_util.FullGC()
  end
  local time_ticker = require("common.time_ticker")
  LogicTxMissionMain.banWindowShow = true
  if not LogicTxMissionMain.banWindowShowTimer then
    LogicTxMissionMain.banWindowShowTimer = time_ticker.AddTimerOnce(3, function()
      LogicTxMissionMain.banWindowShow = false
      time_ticker.RemoveTimer(LogicTxMissionMain.banWindowShowTimer)
      LogicTxMissionMain.banWindowShowTimer = nil
    end)
  end
  LogicTxMissionMain.bEnterXMissionReq = true
  if not LogicTxMissionMain.EnterXMissionReqTimer then
    LogicTxMissionMain.EnterXMissionReqTimer = time_ticker.AddTimerOnce(3, function()
      LogicTxMissionMain.bEnterXMissionReq = false
      time_ticker.RemoveTimer(LogicTxMissionMain.EnterXMissionReqTimer)
      LogicTxMissionMain.EnterXMissionReqTimer = nil
    end)
  end
  local TxMissionHandler = require("client.network.Protocol.TxMissionHandler")
  if from ~= "reconnect" and from ~= "fight" and from ~= "team" and from ~= "invite" then
    LogicTxMissionMain.SetEnterXMissionFrom(from or "nil")
  end
  ClientSendTLogReport(TLogEventDefine.RightScreenEnterTPlan, 0, tostring(LogicTxMissionMain.bEnterXMissionFromScroll))
  LogicTxMissionMain.SendEnterXMissionFrom = from or ""
  local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
  if not PufferMapManager.bHaveInitMapPaks then
    PufferMapManager:InitMapPaks()
  end
  TxMissionHandler.send_enter_metro_scence_req()
  LogicTxMissionMain.SetResetIsInXmissionTimer()
  local LogicXMissionBeginnerGuide = require("client.slua.logic.TxMission.logic_xmission_beginner_guide")
  LogicXMissionBeginnerGuide.GetGuideStateReq()
  if ScriptHelperEngine.IsLowMemoryDevice() then
    local gc_util = require("common.gc_util")
    gc_util.FullGC()
  end
  from = from or "nil"
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.TPlan_Enter_Lobby, 0, tostring(from))
end
function LogicTxMissionMain.SendExitXMissionReq(from)
  local TxMissionHandler = require("client.network.Protocol.TxMissionHandler")
  TxMissionHandler.send_exit_metro_scence_req()
end
function LogicTxMissionMain.CheckCultivateRedPoint()
  log(bWriteLog and "[cw] LogicTxMissionMain.CheckCultivateRedPoint ")
  local TxMissionHandler = require("client.network.Protocol.TxMissionHandler")
  TxMissionHandler.send_metro_collection_get_red_point_req()
  if not LogicTxMissionMain.GetCheckCommandPostGuide() then
    LogicTxMissionMain.CheckComaandPostLevelExtendGuide()
  end
end
function LogicTxMissionMain.IsMaxPrestigeLevel()
  if not LogicTxMissionMain.C_MaxPrestigeLevel then
    local PrestigeConfig = CDataTable.GetTable("PrestigeConfig")
    for k, v in pairs(PrestigeConfig) do
      if v.Exp and v.Exp == 0 then
        LogicTxMissionMain.C_MaxPrestigeLevel = tonumber(v.Level)
        break
      end
    end
    if not LogicTxMissionMain.C_MaxPrestigeLevel then
      LogicTxMissionMain.C_MaxPrestigeLevel = 30
    end
  end
  return LogicTxMissionMain.prestige_level >= LogicTxMissionMain.C_MaxPrestigeLevel
end
function LogicTxMissionMain.SetShadowQuality(value, save)
  local KismetSystemLibrary = import("KismetSystemLibrary")
  local LowDevice = KismetSystemLibrary.GetConsoleVariableIntValue("r.Mobile.LowDevice")
  if LowDevice == 1 then
    if save then
      LogicTxMissionMain.BackupShadowQuality = KismetSystemLibrary.GetConsoleVariableIntValue("r.ShadowQuality")
    end
    local UIUtil = require("client.common.ui_util")
    local gameInstance = UIUtil.GetGameInstance()
    KismetSystemLibrary.ExecuteConsoleCommand(gameInstance, "r.ShadowQuality " .. tostring(value), nil)
  end
end
function LogicTxMissionMain.OnEnterXMissionRsp(metro_scene_data, rate_up_data)
  log(bWriteLog and "LogicTxMissionMain.OnEnterXMissionRsp")
  log_tree("LogicTxMissionMain.OnEnterXMissionRsp metro_scene_data:", metro_scene_data)
  log_format("LogicTxMissionMain:OnEnterXMissionRsp enter, from:%s, isDownloadShow:%s, isRecommendDeleteShow:%s, isXmissionMainShow:%s", tostring(LogicTxMissionMain.SendEnterXMissionFrom), tostring(UIManager.IsUIShow(UIManager.UI_Config.Download_Main_UIBP)), tostring(UIManager.IsUIShow(UIManager.UI_Config.notify_recommend_delete)), tostring(UIManager.IsUIShow(UIManager.UI_Config.xmission_main)))
  LobbySystem.roleData.is_in_metro = true
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  logic_mode_selection:HasSelectMetroTxMission(20000)
  local ScriptHelperEngine = import("ScriptHelperEngine")
  if ScriptHelperEngine.IsLowMemoryDevice() then
    local gc_util = require("common.gc_util")
    gc_util.FullGC()
  end
  LogicTxMissionMain.bEnterXMissionReq = false
  if not LogicTxMissionMain.MountXMissionPak() then
    LogicTxMissionMain.QuitXMission(true)
    return
  end
  if GameStatus.IsInMainCityConnectDs() then
    local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
    local bConnectDS = Lobby_Main_City_Enter.bConnectDS
    log(bWriteLog and "LogicTxMissionMain.OnEnterXMissionRsp bConnectDS = " .. tostring(bConnectDS))
    if bConnectDS then
      Lobby_Main_City_Enter.LeaveMainCity(true, false, false)
    end
  end
  local AkGameplayStatics = import("AkGameplayStatics")
  AkGameplayStatics.RefreshModDirectories()
  local LogicTxMissionMatch = require("client.slua.logic.TxMission.match.logic_xmission_match")
  LogicTxMissionMatch.InitData(metro_scene_data)
  log(bWriteLog and "LogicTxMissionMain.OnEnterXMissionRsp set _isInXMission true")
  _isInXMission = true
  if UIManager.IsUIShow(UIManager.UI_Config.xmission_main) then
    log(bWriteLog and "[edward][logic_xmission_main] LogicTxMissionMain.OnEnterXMissionRsp, is already in xmission main ui")
    if UIManager.IsUIShow(UIManager.UI_Config.setting_main) then
      log(bWriteLog and "[logic_xmission_main] LogicTxMissionMain.OnEnterXMissionRsp, is in setting main ui")
      return
    end
    if UIManager.IsUIShow(UIManager.UI_Config.Xmission_Room_UIBP) then
      log(bWriteLog and "[logic_xmission_main] LogicTxMissionMain.OnEnterXMissionRsp, is in Xmission_Room_UIBP")
      return
    end
    if LogicTxMissionMain.SendEnterXMissionFrom == "reconnect" then
      if UIManager.IsUIShow(UIManager.UI_Config.ActivityCenter_Main_UIBP) then
        log(bWriteLog and "[logic_xmission_main] LogicTxMissionMain.ActivityCenter_Main_UIBP, is in Xmission_Room_UIBP")
        return
      end
      local ui_navigation_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ui_navigation_manager)
      if ui_navigation_manager:IsHavePandoraUI() then
        log(bWriteLog and "[logic_xmission_main] LogicTxMissionMain.IsHavePandoraUI, and is in Xmission_Room_UIBP")
        return
      end
    end
    UIManager.AndroidBackToLobby()
    return
  end
  local ui_jump_manager = require("client.common.uibase.ui_jump_manager")
  ui_jump_manager.Clear()
  if UIManager.IsUIShow(UIManager.UI_Config.ui_season_switch_mgr) then
    UIManager.CloseUI(UIManager.UI_Config.ui_season_switch_mgr)
  end
  local Logic_SocialLobbyEditMgrModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SocialLobbyEditMgrModule)
  Logic_SocialLobbyEditMgrModule:ResetEditDataAndExistEdit()
  if UIManager.IsUIShow(UIManager.UI_Config.NewbieGuide_UIBP) then
    UIManager.CloseUI(UIManager.UI_Config.NewbieGuide_UIBP)
  end
  if UIManager.IsUIShow(UIManager.UI_Config.Download_Main_UIBP) then
    log_format("LogicTxMissionMain:OnEnterXMissionRsp close Download_Main_UIBP, from:%s", tostring(LogicTxMissionMain.SendEnterXMissionFrom))
    UIManager.CloseUI(UIManager.UI_Config.Download_Main_UIBP)
  end
  if UIManager.IsUIShow(UIManager.UI_Config.notify_recommend_delete) then
    log_format("LogicTxMissionMain:OnEnterXMissionRsp close notify_recommend_delete, from:%s", tostring(LogicTxMissionMain.SendEnterXMissionFrom))
    UIManager.CloseUI(UIManager.UI_Config.notify_recommend_delete)
  end
  LogicTxMissionMain.CancelTeamPlatformRecruit()
  TeamUpNewSystem.RemoveAllInvite()
  UIManager.CloseUI(UIManager.UI_Config.Team_Invite_Tip_UIBP)
  local logic_achievement_float_tip = require("client.slua.logic.achievement.logic_achievement_float_tip")
  logic_achievement_float_tip.BlockPopTip()
  LogicTxMissionMain.CheckShowSpecialCollection()
  local logic_chat_channel_chat_room = require("client.slua.logic.lobby_chat.chatroom.logic_chat_channel_chat_room")
  xpcall(function()
    logic_chat_channel_chat_room.QuitVoiceRoom()
  end, require("common.utility").ErrorMessageHandler)
  local logic_chat_recruit_msg = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_recruit_msg)
  logic_chat_recruit_msg:ClearMsgList()
  if ScriptHelperEngine.IsLowMemoryDevice() then
    local gc_util = require("common.gc_util")
    gc_util.FullGC()
  end
  log(bWriteLog and "LogicTxMissionMain.OnEnterXMissionRsp. SendEnterXMissionFrom = " .. tostring(LogicTxMissionMain.SendEnterXMissionFrom))
  local LoadingSystem = require("client.slua.logic.loading.logic_loading")
  if LoadingSystem.IsShowing() or LogicTxMissionMain.bEnterXMissionFromScroll ~= true or LogicTxMissionMain.SendEnterXMissionFrom == "fight" then
    LoadingSystem.ShowLoading(true)
  else
    UIManager.ShowUI(UIManager.UI_Config.ModeSelection_Opening_Train_UIBP, true)
  end
  local Lobby_Main_Control = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
  Lobby_Main_Control.OnEnterXmissionEnd()
  local time_ticker = require("common.time_ticker")
  if not LogicTxMissionMain.enterTimer then
    LogicTxMissionMain.enterTimer = time_ticker.AddTimer(0, function()
      if ScriptHelperEngine.IsLowMemoryDevice() then
        local gc_util = require("common.gc_util")
        gc_util.FullGC()
      end
      local xmission_download = UIManager.GetUI(UIManager.UI_Config.xmission_download)
      if xmission_download then
        xmission_download.waitForEnter = true
      end
      UIManager.ForceBackToLobby()
      local ui_show_manager = require("client.common.uibase.ui_show_manager")
      ui_show_manager.HideCurLobby()
      LogicTxMissionMain.EnterXMissionLoading(metro_scene_data)
      LoadingSystem.RefreshLoadPercent(0.1)
      coroutine.yield(0.5)
      local playerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
      local enterRecord = playerPrefsSystem.LoadFileToTable_N(playerPrefsSystem.ePlayerPrefsType.eXMissionEnter) or {}
      if not enterRecord.enter then
        enterRecord.enter = true
        playerPrefsSystem.SaveTableToFile_N(enterRecord, playerPrefsSystem.ePlayerPrefsType.eXMissionEnter)
      end
      local logic_share_replay = require("client.slua.logic.replay.logic_share_replay")
      logic_share_replay.RecoverXmissionUI()
      LogicTxMissionMain.enterTimer = nil
    end)
  end
  LogicTxMissionMain.  LogicTxMissionMain.SetShadowQuality(0, true)
end
function LogicTxMissionMain.MountXMissionPak(mapKey)
  if _G.IsEditor then
    return true
  end
  local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
  local LogicTxMissionDownload = require("client.slua.logic.TxMission.logic_xmission_download")
  local mapKeys = {
    LogicTxMissionDownload.BASE_MAP_KEY,
    LogicTxMissionDownload.MAP_KEY
  }
  if mapKey then
    local contain = false
    for _, v in ipairs(mapKeys) do
      if v == mapKey then
        contain = true
        break
      end
    end
    if not contain then
      table.insert(mapKeys, mapKey)
    end
  end
  for _, v in ipairs(mapKeys) do
    if not PufferMapManager:MountMapPak(v) then
      return false
    end
  end
  return true
end
function LogicTxMissionMain.EnterXMissionLoading(metro_scene_data)
  local XMissionTeamUpSystem = require("client.slua.logic.TxMission.logic_xmission_team")
  XMissionTeamUpSystem.CreateSelfTeamInfo(metro_scene_data)
  XMissionTeamUpSystem.CreateSelfAvatarInfo()
  log(bWriteLog and "[muidarzhang] LogicTxMissionMain.EnterXMissionLoading:CreateSelfAvatarInfo")
  local ScriptHelperEngine = import("ScriptHelperEngine")
  if ScriptHelperEngine.IsLowMemoryDevice() then
    local gc_util = require("common.gc_util")
    gc_util.FullGC()
  end
  if TeamUpNewSystem.teamInfo and TeamUpNewSystem.teamInfo.members then
    for k, v in pairs(TeamUpNewSystem.teamInfo.members) do
      if tonumber(k) ~= TeamUpNewSystem.GetSelfUID() then
        XMissionTeamUpSystem.CreateAvatarInfo(k, v)
        if v.metro_team_info then
          XMissionTeamUpSystem.SetTeamInfo(k, v.metro_team_info, v.metro_scence_status)
        end
      end
    end
  end
  if UIManager.IsUIShow(UIManager.UI_Config.xmission_main) then
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.xmission_main)
  local time_ticker = require("common.time_ticker")
  time_ticker.AddTimerOnce(1, function()
    local logic_xmission_insurance = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_insurance)
    logic_xmission_insurance:ShowRemainDialog()
  end)
end
function LogicTxMissionMain.OnChangeTeamTypeRsp(team_id, opt)
  if team_id == 0 then
    local LogicTxMissionDownload = require("client.slua.logic.TxMission.logic_xmission_download")
    LogicTxMissionDownload.OpenTPlan("team")
    return
  end
  if team_id ~= TeamUpNewSystem.teamInfo.id then
    log_warning("[edward][LogicTxMissionMain] XMissionSystem.OnChangeTeamTypeRsp, teamID is not match, team_id = " .. team_id .. ", opt = " .. opt)
    return
  end
  if opt == E_ChangeTeamType.L2X then
    log(bWriteLog and "[edward][LogicTxMissionMain] XMissionSystem.OnChangeTeamTypeRsp change type 1 success!!!")
    EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_CHANGE_TEAM_TYPE)
  elseif opt == E_ChangeTeamType.X2L then
    log(bWriteLog and "[edward][LogicTxMissionMain] XMissionSystem.OnChangeTeamTypeRsp change type 2 success!!!")
  end
end
function LogicTxMissionMain.OnQuitXMissionLoading(exit_reason)
  local Lobby_Main_Control = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
  if LogicTxMissionMain.IsInXMission() and UIManager.IsUIShow(UIManager.UI_Config.xmission_main) then
    local isExitFromScroll = LogicTxMissionMain.IsEnterXMissionFromScroll()
    log(bWriteLog and "LogicTxMissionMain.OnQuitXMission. isExitFromScroll" .. tostring(isExitFromScroll))
    if isExitFromScroll then
      if Lobby_Main_Control.ReturnFromTLobbyToPage == nil then
        Lobby_Main_Control.ReturnFromTLobbyToPage = ENUM_LobbyPageType.Mid
      end
      local isShowLoading = UIManager.IsUIShow(UIManager.UI_Config.ModeSelection_Opening_Train_UIBP)
      log(bWriteLog and "LogicTxMissionMain.OnQuitXMission. IsUIShowLoading = " .. tostring(isShowLoading))
      log(bWriteLog and "LogicTxMissionMain.OnQuitXMission.  waitForLoadingCallback = " .. tostring(LogicTxMissionMain.waitForLoadingCallback))
      if LogicTxMissionMain.waitForLoadingCallback then
        return true
      end
      if not isShowLoading then
        LogicTxMissionMain.waitForLoadingCallback = true
        UIManager.ShowUI(UIManager.UI_Config.ModeSelection_Opening_Train_UIBP, false)
        local time_ticker = require("common.time_ticker")
        time_ticker.AddTimerOnce(2, function()
          LogicTxMissionMain.waitForLoadingCallback = false
          LogicTxMissionMain.OnQuitXMissionToLobby(exit_reason)
        end)
        return true
      end
    end
  end
  return false
end
function LogicTxMissionMain.OnQuitXMission(exit_reason)
  log(bWriteLog and string.format("LogicTxMissionMain.OnQuitXMission. exit_reason=%s", tostring(exit_reason)))
  LobbySystem.roleData.is_in_metro = false
  if not UIManager.GetUI(UIManager.UI_Config.xmission_main) then
    log_error("LogicTxMissionMain.OnQuitXMission return because main UI not found")
    return
  end
  if LogicTxMissionMain.OnQuitXMissionLoading(exit_reason) then
    return
  end
  LogicTxMissionMain.OnQuitXMissionToLobby(exit_reason)
end
function LogicTxMissionMain.OnQuitXMissionToLobby(exit_reason)
  exit_reason = exit_reason or ""
  EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_ON_QUIT_PLAN_TNOTIFY)
  log(bWriteLog and "[muidarzhang] LogicTxMissionMain.OnQuitXMission")
  _isInXMission = false
  if TeamUpNewSystem.teamInfo then
    TeamUpNewSystem.teamInfo.metro_team_flag = false
  end
  local XMissionTeamUpSystem = require("client.slua.logic.TxMission.logic_xmission_team")
  XMissionTeamUpSystem.ClearData()
  local XMissionAvatarMgr = require("client.slua.logic.TxMission.logic_xmission_avatar_mgr")
  XMissionAvatarMgr.DestroyAllAvatar()
  local XMissionConversationSystem = require("client.slua.logic.TxMission.logic_xmission_conversation")
  XMissionConversationSystem.ClearConversationQueue()
  local TalentDataMgr = require("client.slua.logic.TxMission.talent.logic_xmission_talent_data")
  TalentDataMgr:ClearData()
  local xmission_main = UIManager.GetUI(UIManager.UI_Config.xmission_main)
  if xmission_main then
    local ui_util = require("client.common.ui_util")
    local deviceLevel = ui_util.GetGameInstance():GetDeviceLevel()
    local LoadingSystem = require("client.slua.logic.loading.logic_loading")
    if deviceLevel == 0 then
      FuncUtil.ShowLoadingToLobby()
      local timer_tick = require("common.time_ticker")
      if not LogicTxMissionMain.quitTLobbyLoadingTimer then
        LogicTxMissionMain.quitTLobbyLoadingTimer = timer_tick.AddTimerOnce(20, function()
          LoadingSystem.RefreshLoadPercent(1)
          timer_tick.RemoveTimer(LogicTxMissionMain.quitTLobbyLoadingTimer)
          LogicTxMissionMain.quitTLobbyLoadingTimer = nil
        end)
      end
    else
      LoadingSystem.RefreshLoadPercent(1)
    end
  end
  UIManager.CloseUI(UIManager.UI_Config.xmission_main)
  UIManager.CloseUI(UIManager.UI_Config.xmission_beginner_guide)
  UIManager.CloseUI(UIManager.UI_Config.Xmission_Guide_Skip_UIBP)
  UIManager.AndroidBackToLobby()
  local NewFaceSlapSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NewFaceSlapSystem)
  local main_city_process_util = require("GameLua.Mod.MainCity.Client.logic.Process.main_city_process_util")
  if not main_city_process_util.CheckIsPendingAutoEnterMainCity() then
    NewFaceSlapSystem:RemoveWaitingMainCity()
  end
  log(bWriteLog and string.format("[kkjhuang] LogicTxMissionMain.OnQuitXMission, exit_reason:%s", exit_reason))
  if exit_reason and exit_reason ~= "season_switch" then
    log(bWriteLog and "LogicTxMissionMain.OnQuitXMission in lobby")
    NewFaceSlapSystem:RevertSlap()
    NewFaceSlapSystem:StartFaceSlap2DLobby()
  end
  local logic_achievement_float_tip = require("client.slua.logic.achievement.logic_achievement_float_tip")
  logic_achievement_float_tip.UnblockPopTip()
  if LogicTxMissionMain.waitJoinTeamUID then
    TeamUpNewSystem.team_apply_request(LogicTxMissionMain.waitJoinTeamUID, TeamUpNewSystem.E_InviteFromType.TPlan)
  end
  LogicTxMissionMain.waitJoinTeamUID = nil
  LogicTxMissionMain.SetShadowQuality(LogicTxMissionMain.BackupShadowQuality, false)
  local logic_chat_recruit_msg = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_chat_recruit_msg)
  logic_chat_recruit_msg:ClearMsgList()
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  if level_unlock_manager:NeedShowLevelup() then
    if NewFaceSlapSystem:IsInSlap() then
      local async = require("client.common.async")
      async.Run(function(co)
        async.AwaitEvent(co, 20, EVENTTYPE_LOBBY, EVENTID_ON_FACESLAP_END)
        log(bWriteLog and "[kkjhuang] LogicTxMissionMain.OnQuitXMission async.Run")
        level_unlock_manager:OpenLevelupPanel()
      end)
    else
      level_unlock_manager:OpenLevelupPanel()
    end
  end
  if LogicTxMissionMain.SendEnterXMissionFrom ~= "reconnect" then
    LogicTxMissionMain.SetEnterXMissionFrom(nil)
  end
end
function LogicTxMissionMain.on_metro_info_rsp(depot_capacity, metro)
  LogicTxMissionMain.InitData(depot_capacity, metro)
  EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_T_METRO_INFO_RSP)
end
function LogicTxMissionMain.on_metro_profit_ntfy(old_cur_value, old_max_value, cur_profit_value, max_profit_value)
  LogicTxMissionMain.metro_cur_profit = cur_profit_value or 0
  LogicTxMissionMain.metro_max_profit = max_profit_value or 0
  EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_T_METRO_WORTH_NOTIFY)
end
function LogicTxMissionMain.OnTakeWorthAward(err, profit_num, awards_list)
  if err == 0 then
    if awards_list and next(awards_list) then
      local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
      Logic_CommonItemGet.ShowPanel_DefaultStyle(awards_list)
    end
    if profit_num then
      if not LogicTxMissionMain.profit_awards then
        LogicTxMissionMain.profit_awards = {}
      end
      LogicTxMissionMain.profit_awards[profit_num] = 1
    end
    EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_TAKE_WORTH_AWARD)
  end
end
function LogicTxMissionMain.ReceiveAllSettlementGift(err_code, awards, award_list)
  if err_code == 0 then
    if award_list and next(award_list) then
      local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
      Logic_CommonItemGet.ShowPanel_DefaultStyle(award_list)
    end
    if awards and next(awards) then
      LogicTxMissionMain.profit_    end
    EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_TAKE_WORTH_AWARD)
  end
end
function LogicTxMissionMain.on_metro_money_ntfy(item_id, after, item_num)
  LogicTxMissionMain.moneys = LogicTxMissionMain.moneys or {}
  LogicTxMissionMain.moneys[item_id] = after
  EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_T_METRO_MONEY_NOTIFY)
end
function LogicTxMissionMain.OnPrestigeChangeNotify(prestige, prestige_level)
  LogicTxMissionMain.  LogicTxMissionMain.prestige_level = prestige_level or 1
  EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_PRESITGE_NOTIFY)
end
function LogicTxMissionMain.OnPrestigeLevelChangeNotify(old_prestige_level, new_prestige_level, award_list)
  if UIManager.IsUIShow(UIManager.UI_Config.loading) then
    if LogicTxMissionMain.levelUpData then
      LogicTxMissionMain.levelUpData.      for i, v in ipairs(award_list) do
        table.insert(LogicTxMissionMain.levelUpData.award_list, v)
      end
    else
      LogicTxMissionMain.levelUpData = {
        old_prestige_level = old_prestige_level,
        new_prestige_level = new_prestige_level,
              }
    end
  else
    if not GameStatus.IsInLobbyOrMainCity() then
      return
    end
    if not LogicTxMissionMain.IsInXMission() then
      return
    end
    LogicTxMissionMain.oldPrestigeLevel = old_prestige_level
    UIManager.ShowUI(UIManager.UI_Config.xmission_levelup, old_prestige_level, new_prestige_level, award_list)
  end
end
function LogicTxMissionMain.on_metro_collection_get_red_point_rsp(show_point)
  log(bWriteLog and "[cw] LogicTxMissionMain.on_metro_collection_get_red_point_rsp(" .. tostring(show_point) .. ") ")
  EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_STORY_ENTRY_RED_POINT_CHANGE, show_point)
end
function LogicTxMissionMain.AdjustWeightAccuracy(weight)
  weight = weight or 0
  weight = weight + FLOAT_NUMBER_TRAIL
  weight = math.modf(weight * 1000)
  weight = weight / 1000
  return weight
end
function LogicTxMissionMain.HideLobbyUI()
  UIManager.CloseUI(UIManager.UI_Config.xmission_wardrobe)
  UIManager.CloseUI(UIManager.UI_Config.Xmission_Store_NewQuickConfigPopup_UIBP)
  UIManager.CloseUI(UIManager.UI_Config.black_market_buy)
  UIManager.CloseUI(UIManager.UI_Config.xmission_season_main)
  UIManager.CloseUI(UIManager.UI_Config.Xmission_Operation_Main_UIBP)
  UIManager.CloseUI(UIManager.UI_Config.Xmission_Souvenirs_UIBP)
  UIManager.CloseUI(UIManager.UI_Config.Xmission_Souvenirs_Detail_UIBP)
  UIManager.CloseUI(UIManager.UI_Config.Xmission_Souvenirs_Friend_UIBP)
  UIManager.CloseUI(UIManager.UI_Config.Xmission_Souvenirs_Friend_Detail_UIBP)
  UIManager.CloseUI(UIManager.UI_Config.Prepare_Bage_Programme_Popup_UIBP)
  EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_CLOSE_MEMBER_DETAIL)
  EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_QUIT_LOBBY)
end
function LogicTxMissionMain:JumpOutLobby()
  UIManager.CloseUI(UIManager.UI_Config.xmission_wardrobe)
  UIManager.CloseUI(UIManager.UI_Config.Xmission_Store_NewQuickConfigPopup_UIBP)
  UIManager.CloseUI(UIManager.UI_Config.black_market_buy)
  UIManager.CloseUI(UIManager.UI_Config.xmission_season_main)
  UIManager.CloseUI(UIManager.UI_Config.Xmission_Operation_Main_UIBP)
  UIManager.CloseUI(UIManager.UI_Config.Xmission_Souvenirs_UIBP)
  UIManager.CloseUI(UIManager.UI_Config.Xmission_Souvenirs_Detail_UIBP)
  UIManager.CloseUI(UIManager.UI_Config.Xmission_Souvenirs_Friend_UIBP)
  UIManager.CloseUI(UIManager.UI_Config.Xmission_Souvenirs_Friend_Detail_UIBP)
  UIManager.CloseUI(UIManager.UI_Config.Prepare_Bage_Programme_Popup_UIBP)
  EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_CLOSE_MEMBER_DETAIL)
  EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_JUMP_OUT_LOBBY)
end
function LogicTxMissionMain.ShowWardrobeMain(from)
  UIManager.ShowUI(UIManager.UI_Config.xmission_wardrobe, {from = from})
end
function LogicTxMissionMain.JumpTxMission()
  local logic_xmission_entrance = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_entrance)
  logic_xmission_entrance:OpenTxMissionByClick()
end
function LogicTxMissionMain.OnTalentDataChangeNotify(data)
  if data and data.new_total_point and data.new_total_point > 0 then
    LogicTxMissionMain.totalTalentPoint = data.new_total_point
  end
end
local ENTRY_TRANSFORM_FOR_THEMES = {
  [202408001] = {
    DEFAULT = "UI_3D_Transform",
    LONG = "UI_3D_Transform_Long"
  },
  [202408014] = {
    DEFAULT = "UI_3D_Rich",
    LONG = "UI_3D_Rich_Long"
  },
  [202408022] = {
    DEFAULT = "UI_3D_Chrismas",
    LONG = "UI_3D_Chrismas_Long"
  }
}
function LogicTxMissionMain.Create3dUIDisplayActor(path)
  local world = slua_GameFrontendHUD:GetWorld()
  local tClass = import(path)
  local showActor = world:SpawnActor(tClass, nil, nil, nil)
  LogicTxMissionMain.Update3DUITransform(showActor, path)
  return showActor
end
function LogicTxMissionMain.CheckHallThemeNeedShowEntry()
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  local themeID = HallThemeUtils.GetCurShowThemeItemId()
  if ENTRY_TRANSFORM_FOR_THEMES[themeID] then
    return true
  else
    return false
  end
end
function LogicTxMissionMain.Update3DUITransform(showActor, path)
  if showActor == nil or not slua.isValid(showActor) then
    return
  end
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  local adapt = Lobby_camera_manager_module:GetCurrentCameraRatio()
  local defalutTransform = showActor.UI_3D_Transform
  local longTransform = showActor.UI_3D_Transform_Long
  showActor:K2_SetActorTransform(adapt == 0 and defalutTransform or longTransform, false, nil, false)
end
function LogicTxMissionMain.Destroy3dUIDisplayActor(actor)
  if actor and slua.isValid(actor) then
    actor:K2_DestroyActor()
  end
end
function LogicTxMissionMain.Show3dUIDisplayActor(actor, uiConfig)
  if not actor then
    return nil
  end
  local userWidget = actor.Widget:GetUserWidgetObject()
  local UIClass = require(uiConfig.moduleName)
  local ui = UIClass()
  ui:InitWithWidget(userWidget)
  ui:OnShow()
  if uiConfig.uiStatName then
    local BusinessHelper = import("BusinessHelper")
    BusinessHelper.StopUIStat(uiConfig.uiStatName, true)
  end
  return ui
end
function LogicTxMissionMain.SetCurBattleGuide(isShow)
  LogicTxMissionMain.bCurBattleGuideIsShow = isShow
end
function LogicTxMissionMain.HideBattleGuide()
  if LogicTxMissionMain.bCurBattleGuideIsShow then
    EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_HIDE_BATTLEGUIDE)
  end
end
function LogicTxMissionMain.HadXmissionActivity()
  local DisplayScene = ActivityDisplayScene.TxMission
  local ActivityCenterModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ActivityCenterModule)
  ActivityCenterModule:BuildDisplaySceneData(DisplayScene)
  local proxy = ActivityCenterModule:GetDataProxy(DisplayScene)
  local hasAny = proxy and proxy:HasAnyData() or false
  log(bWriteLog and "LogicTxMissionMain.HadXmissionActivity. " .. tostring(hasAny))
  return hasAny
end
function LogicTxMissionMain.HadXmissionActivityRedDot()
  local DisplayScene = ActivityDisplayScene.TxMission
  local ActivityRedDot = require("client.slua.logic.activity.RedPoint.ActivityRedDot")
  local SystemName = ActivityRedDot.DisplayScene2SystemName(DisplayScene)
  local TxMissionRedDot = ActivityRedDot.GetRedDotData(SystemName)
  return TxMissionRedDot and TxMissionRedDot.newCount > 0
end
function LogicTxMissionMain.JumpToXmissionActivityCenter(_, __, vars)
  local scene = vars.DisplayScene or ActivityDisplayScene.TxMission
  if LogicTxMissionMain.HadXmissionActivity(scene) then
    local jump_utils = require("client.logic.store.jump_utils")
    local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
    local actData = ActivityNewSystem.GetActivityByTypeAndLabel(ActivityType.ACTIVITY_TYPE_AREA_GROUP, ActivitySwitchType.Xmission)
    local url = ""
    if actData then
      url = jump_utils.GenerateGameUrl(BP_ENUM_MODULE_ACTIVITY, {
        id = actData.ID,
        DisplayScene = scene
      })
    else
      url = jump_utils.GenerateGameUrl(BP_ENUM_MODULE_ACTIVITY, {DisplayScene = scene})
    end
    GlobalData.JumpUrl(url)
  end
end
function LogicTxMissionMain.JumpToXMissionSelectMode(_, _, jumpInfo)
  if TeamUpNewSystem.GetTeamNum() == 1 or TeamUpNewSystem.IsTeamLeader() then
    UIManager.ShowUI(UIManager.UI_Config.xMission_Mode_Select, jumpInfo)
  else
    ShowNotice(LocUtil.LocalizeResFormat(500062))
  end
end
function LogicTxMissionMain.JumpToXMissionCultivate(_, _, jumpInfo)
  if LogicTxMissionMain.IsCultivateSystemOpen(true) then
    EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_QUIT_LOBBY)
    local XMissionNpcSystem = require("client.slua.logic.TxMission.logic_xmission_npc")
    XMissionNpcSystem.JumpToNpcGift(tonumber(jumpInfo.npcID), true)
  end
end
function LogicTxMissionMain.on_metro_enter_notify()
  log(bWriteLog and "[muidarzhang] LogicTxMissionMain.on_metro_enter_notify")
  log_format("LogicTxMissionMain:on_metro_enter_notify reconnect entry, bEnterXMissionReq:%s, _isInXMission:%s", tostring(LogicTxMissionMain.bEnterXMissionReq), tostring(_isInXMission))
  LogicTxMissionMain.bIsReconnect = true
  LogicTxMissionMain.Reconnect()
end
function LogicTxMissionMain.Reconnect()
  if LogicTxMissionMain.bIsReconnect then
    local LogicTxMissionDownload = require("client.slua.logic.TxMission.logic_xmission_download")
    local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.MAP, {
      LogicTxMissionDownload.MAP_KEY
    })
    log(bWriteLog and string.format("[muidarzhang] LogicTxMissionMain.Reconnect, state:%s", state))
    if IsEditor or state == PufferConst.ENUM_DownloadState.Done then
      LogicTxMissionMain.bEnterXMissionReq = true
      log_format("LogicTxMissionMain:Reconnect mark enter req, mapState:%s", tostring(state))
      LogicTxMissionDownload.OpenTPlan("reconnect")
      LogicTxMissionMain.bIsReconnect = false
    else
      log_format("LogicTxMissionMain:Reconnect map not ready, mapState:%s", tostring(state))
    end
  end
end
function LogicTxMissionMain.IsForbiddenUI(jumpModuleID)
  return jumpModuleID and XMissionUIConfig.ForbiddenUIConfig[jumpModuleID] == true
end
function LogicTxMissionMain.UINeedChangeBG(jumpModuleID)
  return not jumpModuleID or not XMissionUIConfig.UnchangedBGConfig[jumpModuleID]
end
function LogicTxMissionMain.IsShowCommandPostReddot()
  return LogicTxMissionMain.command_post_reddot_num > 0
end
function LogicTxMissionMain.AddCommandPostReddot()
  LogicTxMissionMain.command_post_reddot_num = LogicTxMissionMain.command_post_reddot_num + 1
  log(bWriteLog and "LogicTxMissionMain.CommandPostReddot num :" .. LogicTxMissionMain.command_post_reddot_num)
end
function LogicTxMissionMain.DecCommandPostReddot()
  LogicTxMissionMain.command_post_reddot_num = LogicTxMissionMain.command_post_reddot_num - 1
  if LogicTxMissionMain.command_post_reddot_num <= 0 then
    LogicTxMissionMain.command_post_reddot_num = 0
  end
  log(bWriteLog and "LogicTxMissionMain.CommandPostReddot num :" .. LogicTxMissionMain.command_post_reddot_num)
end
function LogicTxMissionMain.GetCheckCommandPostGuide()
  return LogicTxMissionMain.bCheckCommandPostLevelExtendGuide
end
function LogicTxMissionMain.GetCommandPostGuideValue(key)
  local guideValue = DataMgr.GetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_XMISSION_CAMMANDPOST_LEVELEXTEND, key)
  return guideValue
end
function LogicTxMissionMain.CheckComaandPostLevelExtendGuide()
  local LogicXMissionBeginnerGuide = require("client.slua.logic.TxMission.logic_xmission_beginner_guide")
  local bFinishBeginnerGuide = LogicXMissionBeginnerGuide.HaveFinishedBeginnerGuide()
  local bUnLock = LogicTxMissionMain.IsCultivateSystemOpen(false)
  if not bUnLock or not bFinishBeginnerGuide then
    log(bWriteLog and "LogicTxMissionMain.CommandPostGuide locked")
    return
  end
  local PostLevelExtendGuide_Key = 1
  local guideValue = DataMgr.GetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_XMISSION_CAMMANDPOST_LEVELEXTEND, PostLevelExtendGuide_Key)
  if not guideValue then
    LogicTxMissionMain.SetCommandPostGuideValue(PostLevelExtendGuide_Key, 1)
    guideValue = 1
  end
  log(bWriteLog and "LogicTxMissionMain.CommandPostGuide guideValue: " .. guideValue)
  if guideValue == 1 and not LogicTxMissionMain.bCheckCommandPostLevelExtendGuide then
    EventSystem:postEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_COMMAND_POST_LEVEL_EXTEND_GUIDE, guideValue)
    LogicTxMissionMain.bCheckCommandPostLevelExtendGuide = true
  end
  return 1 < guideValue
end
function LogicTxMissionMain.SetCommandPostGuideValue(key, value)
  log(bWriteLog and "LogicTxMissionMain.CommandPostGuide key: " .. key .. " value: " .. value)
  DataMgr.SetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_XMISSION_CAMMANDPOST_LEVELEXTEND, key, value)
end
function LogicTxMissionMain.SetResetIsInXmissionTimer()
  LogicTxMissionMain.ClearResetIsInXmissionTimer()
  local time_ticker = require("common.time_ticker")
  LogicTxMissionMain.timerResetIsInXMission = time_ticker.AddTimerOnce(7, function()
    local LobbyThemeManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyThemeManager)
    if LobbyThemeManager and not LobbyThemeManager.bInXMission then
      log(bWriteLog and "LogicTxMissionMain.SetResetIsInXmissionTimer set _isInXMission false")
      _isInXMission = false
    end
    LogicTxMissionMain.timerResetIsInXMission = nil
  end)
end
function LogicTxMissionMain.ClearResetIsInXmissionTimer()
  if not LogicTxMissionMain.timerResetIsInXMission then
    return
  end
  local time_ticker = require("common.time_ticker")
  time_ticker.RemoveTimer(LogicTxMissionMain.timerResetIsInXMission)
  LogicTxMissionMain.timerResetIsInXMission = nil
end
function LogicTxMissionMain.HasSettingPickUpGuide()
  local LogicXMissionBeginnerGuide = require("client.slua.logic.TxMission.logic_xmission_beginner_guide")
  local bFinishBeginnerGuide = LogicXMissionBeginnerGuide.HaveFinishedBeginnerGuide()
  if LogicTxMissionMain.prestige_level < 4 then
    return false
  end
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eXmissionPickupSettingGuide) or {}
  if cfg and cfg[DataMgr.roleData.uid] then
    log(bWriteLog and "LogicTxMissionMain.HasSettingPickUpGuide finish guide")
    return false
  end
  log(bWriteLog and "LogicTxMissionMain.HasSettingPickUpGuide show guide")
  return true
end
function LogicTxMissionMain.SetSettingPickUpGuide()
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eXmissionPickupSettingGuide) or {}
  if cfg and cfg[DataMgr.roleData.uid] then
    log(bWriteLog and "LogicTxMissionMain.HasSettingPickUpGuide finish guide")
    return false
  end
  cfg[DataMgr.roleData.uid] = true
  PlayerPrefsSystem.SaveTableToFile_N(cfg, PlayerPrefsSystem.ePlayerPrefsType.eXmissionPickupSettingGuide)
  return true
end
function LogicTxMissionMain.HasSettingTeamDressGuide()
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eXmissionLobbyDressSettingGuide) or {}
  if cfg and cfg[DataMgr.roleData.uid] then
    log(bWriteLog and "LogicTxMissionMain.HasSettingTeamDressGuide finish guide")
    return false
  end
  log(bWriteLog and "LogicTxMissionMain.HasSettingTeamDressGuide show guide")
  return true
end
function LogicTxMissionMain.SetSettingTeamDressGuide()
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eXmissionLobbyDressSettingGuide) or {}
  if cfg and cfg[DataMgr.roleData.uid] then
    log(bWriteLog and "LogicTxMissionMain.SetSettingTeamDressGuide finish guide")
    return false
  end
  cfg[DataMgr.roleData.uid] = true
  PlayerPrefsSystem.SaveTableToFile_N(cfg, PlayerPrefsSystem.ePlayerPrefsType.eXmissionLobbyDressSettingGuide)
  return true
end
function LogicTxMissionMain.GetCurSelectIndex()
  return LogicTxMissionMain.cur_select_index
end
function LogicTxMissionMain.SetCurSelectIndex(index)
  LogicTxMissionMain.cur_select_end
return LogicTxMissionMain