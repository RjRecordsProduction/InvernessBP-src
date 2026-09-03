local LogicESportCenter = {
  Subscribes = {},
  hasPopUpTip_IdList = {},
  hasEnQueueNoShow_IdList = {},
  isGMOpen = false,
  timer = nil
}
local C_PopupDelayTime = 10
local C_MaxPopCount = 3
local domainStr = FuncUtil.GetDomainByID(3366036) or ""
local E_CompeteType = {AllStar = 1}
LogicESportCenter.local E_OnLiveState = {
  OnLive = 1,
  PlayBack = 2,
  Expired = 3
}
LogicESportCenter.
function LogicESportCenter.InitTest()
  LogicESportCenter.Subscribes = {
    [1001] = {
      expired_time = 1717171200,
      details = {
        start_time = 1685548800,
        end_time = 1717171200,
        title = "PMGC ID 1001",
        url = domainStr .. "/act/a20180727live/live.html?language=zh&netType=1",
        title_id = 1
      },
      state = 0
    },
    [1002] = {
      expired_time = 1717171200,
      details = {
        start_time = 1685548800,
        end_time = 1717171200,
        title = "PMGC ID 1002",
        url = domainStr .. "/act/a20180727live/live.html?language=zh&netType=1",
        title_id = 2
      },
      state = 0
    }
  }
  log(bWriteLog and "[YY]InitTest==" .. tostring(111111111))
  LogicESportCenter.ShowESportCenterTip()
end
function LogicESportCenter.ShowESportCenter(evenType, eventID, params)
  local DeviceOSInfo = require("client.logic.data.data_device_os")
  local netType = 0
  if Client.HasActiveWifi() then
    netType = 1
  end
  local memorySizeLimit = 3
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS then
    memorySizeLimit = 2
  end
  local switch = LobbySystem.CheckOpen(80017)
  log(bWriteLog and "LogicESportCenter.ShowESportCenter switch = " .. tostring(switch))
  if switch == false or memorySizeLimit > DeviceOSInfo.InfoList.Memory then
    local baseURL = LogicESportCenter.GetUrl()
    local ticket = Client.GetWebViewTicket(NetInterface)
    local url = string.format("%slanguage=%s&netType=%d&sTicket=%s", baseURL, Client.GetCurrentLanguage(), netType, ticket)
    if params and params.view then
      url = url .. params.view
    end
    log(bWriteLog and "[YY]ShowESportCenter=11=" .. tostring(url))
    local WebviewSDK = require("client.slua.logic.url.logic_webview_sdk")
    WebviewSDK:OpenURL(url, true)
  else
    log(bWriteLog and "Client.CacheH5WebView EsportsCenter")
    Client.GMH5Enable(true)
    local moduleName = ""
    local BusinessHelper = import("BusinessHelper")
    if BusinessHelper.GetIMSDKEnv() == 1 then
      moduleName = "EsportsCenter"
    else
      moduleName = "EsportsCenterDev"
    end
    Client.CacheH5WebView(moduleName)
    log(bWriteLog and "[YY]ShowESportCenter=22=" .. tostring(moduleName))
    UIManager.ShowUI(UIManager.UI_Config.esport_center, params)
  end
end
function LogicESportCenter.SetESportSubscribes(subscribes)
  LogicESportCenter.Subscribes = subscribes
end
function LogicESportCenter.UpdateESportSubscribes(esports_id, expired_time, details)
  if not LogicESportCenter.Subscribes then
    LogicESportCenter.Subscribes = {}
  end
  if not LogicESportCenter.Subscribes[esports_id] then
    LogicESportCenter.Subscribes[esports_id] = {}
  end
  LogicESportCenter.Subscribes[esports_id].  LogicESportCenter.Subscribes[esports_id].  if not expired_time then
    LogicESportCenter.Subscribes[esports_id] = nil
  end
end
function LogicESportCenter.FilterESportSubscribes()
  local esport_Ids = {}
  local TimeUtil = require("client.common.time_util")
  local nNow = TimeUtil.GetServerTimeInSec()
  log(bWriteLog and "[YY]FilterESportSubscribes==" .. tostring(nNow))
  for i, v in pairs(LogicESportCenter.Subscribes) do
    if nNow and v.expired_time and nNow < v.expired_time and (not v.state or v.state == 0) and LogicESportCenter.CanPopUI(i) and LogicESportCenter.HasNotPopInLobby(i) then
      table.insert(esport_Ids, i)
    end
  end
  table.sort(esport_Ids, function(a, b)
    return b < a
  end)
  return esport_Ids
end
function LogicESportCenter.CanPopUI(esport_id)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eEsportsCenterSubscribe)
  if not cfg or not next(cfg) then
    return true
  end
  local data = cfg[esport_id]
  if not data then
    return true
  end
  if data and data.popCount and data.popCount < C_MaxPopCount then
    return true
  end
  local TimeUtil = require("client.common.time_util")
  local nNow = TimeUtil.GetServerTimeInSec()
  if data and data.firstPopTime and nNow >= data.firstPopTime + 86400 then
    return true
  end
  return false
end
function LogicESportCenter.ClearExpiredSubscribeData()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eEsportsCenterSubscribe)
  cfg = cfg or {}
  if cfg and next(cfg) then
    local TimeUtil = require("client.common.time_util")
    local nNow = TimeUtil.GetServerTimeInSec()
    for i, data in pairs(cfg) do
      if data and (type(data) == "number" or type(data) == "table" and data.firstPopTime and nNow >= data.firstPopTime + 86400) then
        cfg[i] = nil
      end
    end
  end
  PlayerPrefsSystem.SaveTableToFile_N(cfg, PlayerPrefsSystem.ePlayerPrefsType.eEsportsCenterSubscribe)
end
function LogicESportCenter.SaveSubsribeData(esport_id)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eEsportsCenterSubscribe)
  cfg = cfg or {}
  local data = cfg[esport_id]
  local TimeUtil = require("client.common.time_util")
  local nNow = TimeUtil.GetServerTimeInSec()
  if not data then
    data = {firstPopTime = nNow, popCount = 1}
  else
    if not data.firstPopTime or not data.popCount then
      data = {firstPopTime = nNow, popCount = 1}
    end
    data.popCount = data.popCount + 1
    if nNow >= data.firstPopTime + 86400 then
      data = {firstPopTime = nNow, popCount = 1}
    end
  end
  cfg[esport_id] = data
  PlayerPrefsSystem.SaveTableToFile_N(cfg, PlayerPrefsSystem.ePlayerPrefsType.eEsportsCenterSubscribe)
  log_tree("SubsribeData", cfg)
end
function LogicESportCenter.HasNotPopInLobby(esport_id)
  if LogicESportCenter.hasPopUpTip_IdList and LogicESportCenter.hasPopUpTip_IdList[esport_id] then
    return false
  end
  return true
end
function LogicESportCenter.SaveHasPopIdData(esportId)
  if not LogicESportCenter.hasPopUpTip_IdList then
    LogicESportCenter.hasPopUpTip_IdList = {}
  end
  LogicESportCenter.hasPopUpTip_IdList[esportId] = true
end
function LogicESportCenter.HasEnQueueNoShow(esport_id)
  if not esport_id then
    return
  end
  if LogicESportCenter.hasEnQueueNoShow_IdList and LogicESportCenter.hasEnQueueNoShow_IdList[esport_id] then
    return true
  end
  return false
end
function LogicESportCenter.EnQueueNoShowData(esport_id)
  if not LogicESportCenter.hasEnQueueNoShow_IdList then
    LogicESportCenter.hasEnQueueNoShow_IdList = {}
  end
  LogicESportCenter.hasEnQueueNoShow_IdList[esport_id] = true
end
function LogicESportCenter.ClearAllTimer()
  local time_ticker = require("common.time_ticker")
  if LogicESportCenter.timer then
    time_ticker.RemoveTimer(LogicESportCenter.timer)
    LogicESportCenter.timer = nil
  end
end
function LogicESportCenter.ShowESportCenterTip()
  if IsWoWEditor then
    return
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() or PublishRegionMacros.IsBLUEHOLE() then
    return
  end
  if not LogicESportCenter.Subscribes or not next(LogicESportCenter.Subscribes) then
    return
  end
  log(bWriteLog and "[YY]InitTest==" .. tostring(22222222))
  local esports_id = LogicESportCenter.FilterESportSubscribes()
  if #esports_id == 0 then
    return
  end
  log(bWriteLog and "[YY]InitTest==" .. tostring(3333333333))
  LogicESportCenter.ClearAllTimer()
  local TimeUtil = require("client.common.time_util")
  local TableUtil = require("common.table_util")
  local time_ticker = require("common.time_ticker")
  local subscribes = LogicESportCenter.Subscribes
  LogicESportCenter.timer = time_ticker.AddTimerLoop(C_PopupDelayTime, function()
    local showIDList = {}
    for _, v in ipairs(esports_id) do
      if subscribes[v] then
        local details = ""
        if Client and not Client.IsShipping() and LogicESportCenter.isGMOpen then
          details = subscribes[v].details
        else
          details = json.decode(subscribes[v].details)
        end
        local expired_time = subscribes[v].expired_time
        local nNow = TimeUtil.GetServerTimeInSec()
        if details and details.start_time and details.end_time and nNow >= tonumber(details.start_time) and expired_time > nNow then
          log(bWriteLog and "[YY]InitTest==" .. tostring(444444444))
          if not GameStatus.IsInLobbyOrMainCity() then
            return
          end
          local state = E_OnLiveState.OnLive
          if nNow > tonumber(details.end_time) and expired_time > nNow then
            state = E_OnLiveState.PlayBack
          end
          log_tree("ShowESportCenterTip====details===", details)
          log(bWriteLog and "[YY]ShowESportCenterTip====esport_id==" .. tostring(v))
          log(bWriteLog and "[YY]ShowESportCenterTip====expire_time==" .. tostring(expired_time))
          log(bWriteLog and "[YY]ShowESportCenterTip====nNow===" .. tostring(nNow))
          log(bWriteLog and "[YY]ShowESportCenterTip====state===" .. tostring(state))
          if not LogicESportCenter.HasEnQueueNoShow(v) then
            LogicESportCenter.EnQueueNoShowData(v)
            UIManager.ShowUI(UIManager.UI_Config.esport_center_tip, v, details, state)
          end
          table.insert(showIDList, v)
        end
      end
    end
    log_tree("InitTest==showIDList==", showIDList)
    for i, v in ipairs(showIDList) do
      TableUtil.Remove(esports_id, v)
    end
    log_tree("InitTest==esports_id==", esports_id)
    if not esports_id or #esports_id == 0 then
      LogicESportCenter.ClearAllTimer()
    end
  end, TIMER_INFINITE, 20)
end
function LogicESportCenter.OpenMain()
  local SeasonVerCfg = CDataTable.GetTableData("SeasonVersion", DataMgr.season_id)
  local ClientVersion = Client.GetAppVersion()
  local version_util = require("client.common.version_util")
  local ChampionshipSponsorSystem = require("client.slua.logic.championship.logic_championship_sponsor")
  ChampionshipSponsorSystem.send_get_pug_system_info_req()
  if version_util.CompareVersionFull(ClientVersion, SeasonVerCfg.MaxVersion) < 0 and 0 <= version_util.CompareVersionFull(ClientVersion, SeasonVerCfg.MinVersion) then
    UIManager.ShowUI(UIManager.UI_Config.allstar_season_anim)
    gem_report_utils.ReportBtnClickEvent(gem_report_utils.SubEventName_LobbyEsport)
  elseif not UIManager.IsUIShow(UIManager.UI_Config.egame_center) then
    UIManager.ShowUI(UIManager.UI_Config.egame_center)
  end
end
function LogicESportCenter.GetUrl()
  local BusinessHelper = import("BusinessHelper")
  local region = FuncUtil.GetAccountRegionForBP()
  local AccountRegionForBPMacros = require("client.slua.config.ClientMacros.AccountRegionForBPMacros")
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() then
    if region == AccountRegionForBPMacros.JP then
      if BusinessHelper.GetIMSDKEnv() == 1 then
        return FuncUtil.GetDomainByID(3366036) .. "/act/a20180727live_jp/index.html?"
      else
        return FuncUtil.GetDomainByID(3366036) .. "/act/a20180727live_jp_dev/index.html?"
      end
    elseif BusinessHelper.GetIMSDKEnv() == 1 then
      return FuncUtil.GetDomainByID(3366036) .. "/act/a20180727live_kr/index.html?"
    else
      return FuncUtil.GetDomainByID(3366036) .. "/act/a20180727live_kr_dev/index.html?"
    end
  elseif BusinessHelper.GetIMSDKEnv() == 1 then
    return FuncUtil.GetDomainByID(3366036) .. "/act/a20180727live/live.html?"
  else
    return FuncUtil.GetDomainByID(3366036) .. "/act/a20180727live_dev/index.html?"
  end
end
function LogicESportCenter.GetShareUrl2()
  local ESportSquadSystem = require("client.slua.logic.esport.logic_esport_squad")
  local data = ESportSquadSystem.GetTeamData()
  local title, content = LogicESportCenter.GetTitleAndContent()
  title = Client.UrlEncode(Client.HtmlEncode(title))
  content = Client.UrlEncode(Client.HtmlEncode(content))
  local domain = ShareMgr.GetShareDomain(true)
  local gameID = FuncUtil.GetGamePublishID()
  local link = "https://" .. domain .. "/teamshare.php?gameid=" .. gameID .. "&title=" .. title .. "&description=" .. content .. "&teamname=" .. (data and data.name or "")
  log(bWriteLog and "yy=====link===" .. link)
  return link
end
function LogicESportCenter.GetTitleAndContent()
  return LocUtil.GetLocalizeResStr(9742), LocUtil.GetLocalizeResStr(4366)
end
function LogicESportCenter.GetShareDesc()
  return LocUtil.GetLocalizeResStr(12637)
end
function LogicESportCenter.OnModePostSwitch(preState, nextState)
  log(bWriteLog and "LogicESportCenter.OnModePostSwitch " .. tostring(nextState))
  if nextState ~= GameStatus.Lobby and not GameStatus.IsInMainCity() then
    if Client then
      Client.CloseWebView()
    end
    LogicESportCenter.hasEnQueueNoShow_IdList = {}
    if nextState == GameStatus.Login then
      LogicESportCenter.ClearAllTimer()
      LogicESportCenter.hasPopUpTip_IdList = {}
      LogicESportCenter.ClearExpiredSubscribeData()
    end
  end
end
return LogicESportCenter