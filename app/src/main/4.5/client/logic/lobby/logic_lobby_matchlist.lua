local UILobbyMatchList = {}
UILobbyMatchList.MatchListIsOpen = false
function UILobbyMatchList.EnterEntry()
  UIManager.ShowUI(UIManager.UI_Config.egame_entry)
end
function UILobbyMatchList.EnterIndia()
  local TournamentsManager = require("client.slua.logic.tournament.TournamentsManager")
  local gem_report_utils = require("client.logic.store.gem_report_utils")
  local logic_tournament_main = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_tournament_main)
  logic_tournament_main:ShowMainUI()
  local TimeUtil = require("client.common.time_util")
  local serverTime = math.min(TimeUtil.GetServerTimeInSec(), 2147483647)
  local nowData = math.floor(serverTime / 86400)
  local lastData = DataMgr.GetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_INDIA_CHAMPIONSHIP, Newbie_Guide_India_Championship_Tournament_New)
  if nil == lastData or lastData ~= nowData then
    if nowData == math.huge or nowData == -math.huge then
      nowData = 0
    end
    DataMgr.SetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_INDIA_CHAMPIONSHIP, Newbie_Guide_India_Championship_Tournament_New, nowData)
  end
  TournamentsManager.tournamentHas = false
  gem_report_utils.ReportBtnClickEvent(gem_report_utils.SubEventName_LobbyTournament)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.LobbyTournament)
  local esport_reddot_data = require("client.slua.logic.esport.esport_reddot_data")
  esport_reddot_data.UpdateBonusCount(0)
end
function UILobbyMatchList.EnterBroadcast()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local ActivityHandler = require("client.network.Protocol.ActivityHandler")
  if ActivityNewSystem.IsContainsH5LeagueGameActivity() then
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    if PublishRegionMacros.IsJapanOrKorea() then
      ActivityHandler.send_deal_activity_req(ActivityFixedID.H5LeagueGame_JK, 1, 0)
    else
      ActivityHandler.send_deal_activity_req(ActivityFixedID.H5LeagueGame, 1, 0)
    end
  end
  if not LobbySystem.CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_BROADCAST) then
    return
  end
  if LobbySystem.isInMatch then
    ShowNotice(110017)
    return
  end
  local LogicESportCenter = require("client.slua.logic.esport.logic_esport_center")
  LogicESportCenter.ShowESportCenter()
  GlobalData.StopLobbyBGM()
  EventSystem:postEvent(EVENTTYPE_WEB, EVENTID_WEB_DEACTIVATED)
  local center_reddot_data = require("client.slua.logic.esport.center_reddot_data")
  center_reddot_data.UpdateCenterCount(0)
end
function UILobbyMatchList.EnterChampionship()
  local ChampionshipSponsorSystem = require("client.slua.logic.championship.logic_championship_sponsor")
  UIManager.ShowUI(UIManager.UI_Config.Championship_Sponsor_Mgr_UIBP, ChampionshipSponsorSystem.EnterFrom)
end
function UILobbyMatchList.EnterBonusH5()
  local TimeUtil = require("client.common.time_util")
  local AdvertiseSystem = require("client.logic.advertise.logic_advertise")
  local gem_report_utils = require("client.logic.store.gem_report_utils")
  local url = FuncUtil.GetDomainByID(3366036) .. "/act/a20190624guess/index.shtml?sTicket={itop_ticket}&game_area={game_area}&region={country}&nickname={nickname}&version={version}"
  local webModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.webModule)
  url = webModule:AddParameterByPersonalInfo(url)
  local TournamentsManager = require("client.slua.logic.tournament.TournamentsManager")
  url = url .. "&time_zone=" .. tostring(TimeUtil.GetTimeZone())
  url = url .. "&typeswitch=" .. tostring(TournamentsManager.bonusCfg.typeswitch)
  url = url .. "&otherswitch=" .. tostring(TournamentsManager.bonusCfg.otherswitch)
  url = url .. "&quiz_newer=" .. tostring(TournamentsManager.bonusCfg.quiz_newer)
  url = url .. "&weekly_reward=" .. tostring(TournamentsManager.bonusCfg.weekly_reward)
  url = url .. "&adtimes=" .. tostring(TournamentsManager.bonusCfg.addTimes)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local lastt = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.bonusAdTimeStamp) or 0
  url = url .. "&lastadstamp=" .. tostring(lastt)
  url = url .. "&lastadstamp=" .. tostring(lastt)
  local is_ad_open = "1"
  if TournamentsManager.bonusCfg.is_ad and TournamentsManager.bonusCfg.is_ad ~= "" then
    is_ad_open = TournamentsManager.bonusCfg.is_ad
  end
  url = url .. "&ad_reward=" .. is_ad_open
  if TournamentsManager.addrId then
    url = url .. "&address_id=" .. tostring(TournamentsManager.addrId)
  end
  url = url .. "&area_id=" .. tostring(DataMgr.roleData.idip_area_id or 1)
  url = url .. "&optionswitch=" .. tostring(TournamentsManager.bonusCfg.optionswitch)
  log(bWriteLog and "[COLE]UILobbyMatchList.EnterBonusH5 url=" .. url)
  local StringUtil = require("common.string_util")
  local isFloatWeb = false
  if TournamentsManager.bonusCfg.typeconfig then
    local res = StringUtil.Split(TournamentsManager.bonusCfg.typeconfig, ",")
    if tonumber(res[1]) == 1 then
      isFloatWeb = true
    end
  end
  if isFloatWeb then
    local UIUtil = require("client.common.ui_util")
    if UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.InGameWebview) == true then
      UIManager.ShowUI(UIManager.UI_Config.ingame_process_webview, url)
      ClientSendTLogReport(TLogEventDefine.InGameProcessWebView, 0, gem_report_utils.EventName_LobbyEvent)
    end
  else
    GlobalData.JumpUrl(url)
  end
  GlobalData.LoadAdvertiseByType(AdvertiseSystem.eType.web)
  TournamentsManager.bonusCfg.redPointBonus = false
  local logic_lobby_reddot = require("client.slua.logic.lobby.logic_lobby_reddot")
  logic_lobby_reddot.ProcModuleReddot(BP_ENUM_MODULE_BOUNUS, false)
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_UPDATE_MATCH_REDPOINT)
  gem_report_utils.ReportBtnClickEvent(gem_report_utils.SubEventName_LobbyBonus)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.LobbyBonus)
end
function UILobbyMatchList.SetDoubleRatingData()
  local lobbyMain = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  if lobbyMain then
    local ui_doublecard = lobbyMain:GetChildUI(UIManager.UI_Config.lobby_doublecard_entrance)
    if ui_doublecard then
      ui_doublecard:SetDoubleRatingData()
    end
  end
end
function UILobbyMatchList.EnterQualifying()
  local QuilifyHandler = require("client.network.Protocol.QuilifyHandler")
  QuilifyHandler.send_get_tournament_unions_req()
end
function UILobbyMatchList.EnterSeason()
  local gem_report_utils = require("client.logic.store.gem_report_utils")
  if not LobbySystem.CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_SEASON) then
    return
  end
  local SeasonVerCfg = CDataTable.GetTableData("SeasonVersion", DataMgr.season_id)
  local version_util = require("client.common.version_util")
  local ClientVersion = version_util.GetClientFormat(Client.GetAppVersion())
  if SeasonVerCfg and version_util.CompareVersionStandard(ClientVersion, SeasonVerCfg.MinVersion) < 0 then
    ShowNotice(9409)
    return
  end
  ClientVersion = Client.GetAppVersion()
  local season_year_util = require("client.logic.season_year.util.season_year_util")
  local seasonYearOpen = season_year_util.CheckFunctionIsOpen()
  if not seasonYearOpen and SeasonVerCfg and 0 > version_util.CompareVersionFull(ClientVersion, SeasonVerCfg.MaxVersion) and 0 <= version_util.CompareVersionFull(ClientVersion, SeasonVerCfg.MinVersion) then
    UIManager.ShowUI(UIManager.UI_Config.ui_season_anim_mgr)
    gem_report_utils.ReportBtnClickEvent(gem_report_utils.SubEventName_LobbySeason)
  else
    local SeasonSystem = require("client.logic.season.logic_season")
    SeasonSystem.ShowSeasonHomepage()
  end
end
function UILobbyMatchList.EnterBigEvent(sMapPath)
end
return UILobbyMatchList