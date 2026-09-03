local logic_lobby_mid_banner = {
  firstLineBannerList = {
    [BP_ENUM_MODULE_LUCKY_UNBACK] = 1,
    [BP_ENUM_MODULE_LUCKY_DOUBLE] = 1,
    [BP_ENUM_MODULE_LUCKY_BACK] = 1,
    [BP_ENUM_MODULE_THEFIRSTCHARGE_SEASON] = 1,
    [BP_ENUM_MODULE_PDD] = 1,
    [BP_ENUM_MODULE_LUCKY_BACK_VEHICLE] = 1,
    [BP_ENUM_MODULE_BLACK_FRIDAY] = 1,
    [BP_ENUM_MODULE_BLACK_FRIDAY_MAIN] = 1,
    [BP_ENUM_MODULE_DISCOUNT_FEVER] = 1,
    [BP_ENUM_MODULE_BLACK_FRIDAY_VOTE] = 1,
    [BP_ENUM_MODULE_XSUIT_SPIN] = 1,
    [BP_ENUM_MODULE_EVERYDAY_PACK] = 1,
    [BP_ENUM_MODULE_TAROTCARD_DARWCARD] = 1,
    [BP_ENUM_MODULE_RECHARGE_GAS_STATION] = 1,
    [BP_ENUM_MODULE_PRIME] = 1,
    [BP_ENUM_MODULE_HOLA_MONSTER] = 1,
    [BP_ENUM_MODULE_CUSTOM_PACK] = 1,
    [BP_ENUM_MODULE_FINANCIAL_P] = 1,
    [BP_ENUM_MODULE_LADDER_DRAW] = 1,
    [BP_ENUM_MODULE_EVERYDAY_PACK_V2] = 1,
    [BP_ENUM_MODULE_GODZILLA_BAN] = 1,
    [BP_ENUM_MODULE_APLAN_EXPLORE] = 1,
    [BP_ENUM_MODULE_LUCKY_MULTI] = 1
  }
}
local C_NEW_TIME_LIMIT = 604800
local Allow_Max_Activity = 4
local Allow_Cfg_Max_Activity = 4
local ENUM_BANNER_TYPE = {
  Sidebar = 0,
  Lobby = 201,
  bothShow = 202,
  OnlyShowSupply = 301,
  PHome = 600,
  MainCity = 700,
  WOW_Hall = 800
}
local WOW_Hall_Banner_ID_SpecialList = {
  [20150] = {
    module = "LogicUGCWOWQuestionnaire",
    method = "GetIconNeedShow"
  }
}
local IsWOWHallBannerAllowed = function(actInfoID)
  log(bWriteLog and string.format("IsWOWHallBannerAllowed - actInfoID: %s", tostring(actInfoID)))
  if not actInfoID then
    return false
  end
  local cfg = WOW_Hall_Banner_ID_SpecialList[actInfoID]
  if cfg then
    local success, result = pcall(function()
      local moduleInstance = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig[cfg.module])
      if moduleInstance and moduleInstance[cfg.method] then
        return moduleInstance[cfg.method](moduleInstance)
      end
      return true
    end)
    if success then
      log(bWriteLog and string.format("IsWOWHallBannerAllowed - actInfoID: %s, result: %s", tostring(actInfoID), tostring(result)))
      return result
    end
  end
  log(bWriteLog and "IsWOWHallBannerAllowed defeat return true")
  return true
end
local GetRPBannerDataForJaguar = function()
  log(bWriteLog and "[SY]GetRPBannerDataForJaguar.")
  local LogicPufferBundle = require("client.slua.logic.download.bundle.logic_puffer_bundle")
  if LogicPufferBundle.IsFitLobbyResDownloaded() then
    return nil
  end
  if not (UnknowPassSystem and UnknowPassSystem.SeasonInfo) or not UnknowPassSystem.SeasonInfo.cfg then
    return nil
  end
  local cfg = UnknowPassSystem.SeasonInfo.cfg
  local beginTime = cfg.begin_timestamp
  local endTime = cfg.end_timestamp
  if not beginTime or not endTime then
    return nil
  end
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  if beginTime > now or endTime < now then
    return nil
  end
  local nSeason = UnknowPassSystem.Season
  local bannerCfg = nSeason and CDataTable.GetTableData("UnknowpassBannerCfg", nSeason)
  if not bannerCfg then
    return nil
  end
  local iconPath = bannerCfg.Icon and bannerCfg.Icon ~= "" and bannerCfg.Icon or ""
  local bDownloaded = logic_lobby_mid_banner.IsRPDownloaded()
  local baseWeight = bannerCfg.BaseWeight or 9999
  local undownloadWeight = bannerCfg.UndownloadWeight or 0
  local weight = bDownloaded and baseWeight or baseWeight + undownloadWeight
  local jumpUrl = "game://?module=" .. BP_ENUM_MODULE_UNKNOW_PASS
  local data = {
    ID = 900000019,
    Priority = 0,
    ActivityName = cfg.season_name or "",
    ActivityDesc = "",
    IconPath = iconPath,
    JumpUrl = jumpUrl,
    StartTime = "",
    EndTime = "",
    StartTimeUTC = beginTime,
    EndTimeUTC = endTime,
    IsNew = false,
    ActivityType = 32,
    IsShowCountDownIcon = false,
    Weight = weight,
    BPPath = "",
    DependItems = "",
    Depends = "",
    ShowSceneID = 0,
    EntryImagePath = "",
    BackupParam1 = "",
    BackupParam2 = "",
    BannerType = ENUM_BANNER_TYPE.bothShow,
    ActId = 0,
    CreatedUtc = 0,
    CreatedProcess = 0,
    isNewbie = 0,
    EndShowDay = 0,
    StartShowDay = 0,
    CornerIconPath = "",
    isRPEntry = true,
    isRPDownloaded = bDownloaded
  }
  return data
end
function logic_lobby_mid_banner.IsRPDownloaded()
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  return PassDataSystem.GetRpResourceDownloadState() == PufferConst.ENUM_DownloadState.Done
end
function logic_lobby_mid_banner.GetRPDownloadList()
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  return PassDataSystem.GetRpResourceDownloadList()
end
function logic_lobby_mid_banner.OnRPDownloadComplete()
  local logic_puffer_bundle = require("client.slua.logic.download.bundle.logic_puffer_bundle")
  if logic_puffer_bundle.IsFitLobbyResDownloaded() then
    return
  end
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_UNKNOWNPASS_DOWNLOAD_COMPLETE)
end
local sortBannerByWeight = function(a, b)
  if a.Weight == b.Weight then
    return a.StartTimeUTC > b.StartTimeUTC
  else
    return a.Weight > b.Weight
  end
end
local sortBannerByTime = function(a, b)
  if a.StartTimeUTC == b.StartTimeUTC then
    return a.Weight > b.Weight
  else
    return a.StartTimeUTC > b.StartTimeUTC
  end
end
function logic_lobby_mid_banner.GetBannerByLine()
  if #LobbySystem.activityBtnDisplayList <= 0 then
    return nil
  end
  local actList = {}
  for i = 1, #LobbySystem.activityBtnDisplayList do
    local actInfo = LobbySystem.activityBtnDisplayList[i]
    table.insert(actList, actInfo)
  end
  table.sort(actList, sortBannerByTime)
  return actList
end
function logic_lobby_mid_banner.GetSidebarBannerList(isSidebar)
  if #LobbySystem.activityBtnDisplayList <= 0 then
    local rpData = GetRPBannerDataForJaguar()
    if rpData then
      return {rpData}
    end
    return {}
  end
  local check = isSidebar and ENUM_BANNER_TYPE.Sidebar or ENUM_BANNER_TYPE.Lobby
  local actSidebarList = {}
  for i, actInfo in ipairs(LobbySystem.activityBtnDisplayList) do
    local bannerType = actInfo.BannerType or ENUM_BANNER_TYPE.Sidebar
    if bannerType == check or bannerType == ENUM_BANNER_TYPE.bothShow or bannerType == ENUM_BANNER_TYPE.Sidebar then
      table.insert(actSidebarList, actInfo)
    end
  end
  local rpData = GetRPBannerDataForJaguar()
  if rpData then
    table.insert(actSidebarList, rpData)
  end
  table.sort(actSidebarList, sortBannerByWeight)
  return actSidebarList
end
function logic_lobby_mid_banner:GetMCSideBannerList()
  if #LobbySystem.activityBtnDisplayList <= 0 then
    return {}
  end
  local sidebarList = logic_lobby_mid_banner.GetSidebarBannerList(true)
  local actList = {}
  for i, actInfo in ipairs(sidebarList) do
    if actInfo.ID ~= 243032105 and actInfo.ID ~= 243032111 then
      table.insert(actList, actInfo)
    end
  end
  for i, actInfo in ipairs(LobbySystem.activityBtnDisplayList) do
    if actInfo.ID ~= 243032105 and actInfo.ID ~= 243032111 then
      local bannerType = actInfo.BannerType or ENUM_BANNER_TYPE.Sidebar
      if bannerType == ENUM_BANNER_TYPE.MainCity then
        table.insert(actList, actInfo)
      end
    end
  end
  table.sort(actList, function(a, b)
    if a.bannerType == b.bannerType then
      if a.Weight == b.Weight then
        return a.StartTimeUTC > b.StartTimeUTC
      else
        return a.Weight > b.Weight
      end
    else
      return a.bannerType > b.bannerType
    end
  end)
  log_tree(bWriteLog and "logic_lobby_mid_banner.GetMCSideBannerList actList", actList)
  return actList
end
function logic_lobby_mid_banner.GetMCLobbyBannerList()
  if #LobbySystem.activityBtnDisplayList <= 0 then
    return {}
  end
  local lobbyList = logic_lobby_mid_banner.GetLobbyBannerList()
  local actList = {}
  for i, actInfo in ipairs(lobbyList) do
    if actInfo.ID ~= 243032105 and actInfo.ID ~= 243032111 then
      table.insert(actList, actInfo)
    end
  end
  for i, actInfo in ipairs(LobbySystem.activityBtnDisplayList) do
    if actInfo.ID ~= 243032105 and actInfo.ID ~= 243032111 then
      local bannerType = actInfo.BannerType or ENUM_BANNER_TYPE.Sidebar
      if bannerType == ENUM_BANNER_TYPE.MainCity then
        table.insert(actList, actInfo)
      end
    end
  end
  table.sort(actList, function(a, b)
    if a.bannerType == b.bannerType then
      if a.StartTimeUTC == b.StartTimeUTC then
        return a.Weight > b.Weight
      else
        return a.StartTimeUTC > b.StartTimeUTC
      end
    else
      return a.bannerType > b.bannerType
    end
  end)
  log_tree(bWriteLog and "logic_lobby_mid_banner.GetMCLobbyBannerList actList", actList)
  return actList
end
function logic_lobby_mid_banner.GetPHomeBannerList()
  if #LobbySystem.activityBtnDisplayList <= 0 then
    return {}
  end
  local actList = {}
  for i, actInfo in ipairs(LobbySystem.activityBtnDisplayList) do
    local bannerType = actInfo.BannerType or ENUM_BANNER_TYPE.Sidebar
    if bannerType == ENUM_BANNER_TYPE.PHome then
      table.insert(actList, actInfo)
    end
  end
  table.sort(actList, sortBannerByWeight)
  log_tree(bWriteLog and "logic_lobby_mid_banner.GetPHomeBannerList actList", actList)
  return actList
end
function logic_lobby_mid_banner.GetLobbyBannerList()
  if #LobbySystem.activityBtnDisplayList <= 0 then
    local rpData = GetRPBannerDataForJaguar()
    if rpData then
      return {rpData}
    end
    return {}
  end
  table.sort(LobbySystem.activityBtnDisplayList, sortBannerByWeight)
  local actLobbyList = {}
  local actResidentList = {}
  local actLimitList = {}
  for i, actInfo in pairs(LobbySystem.activityBtnDisplayList) do
    local bannerType = actInfo.BannerType or ENUM_BANNER_TYPE.Sidebar
    if bannerType == ENUM_BANNER_TYPE.bothShow then
      table.insert(actResidentList, actInfo)
    elseif bannerType == ENUM_BANNER_TYPE.Lobby then
      table.insert(actLimitList, actInfo)
    end
  end
  log(bWriteLog and "Remove Sidebar from Lobby")
  local curLobbyActCount = 0
  local outAllowMaxNum = false
  if #actResidentList + #actLimitList > Allow_Max_Activity then
    outAllowMaxNum = true
  end
  local addActToActList = function(actList)
    for k, actInfo in pairs(actList) do
      if not outAllowMaxNum and curLobbyActCount < Allow_Max_Activity then
        table.insert(actLobbyList, actInfo)
        curLobbyActCount = curLobbyActCount + 1
      elseif outAllowMaxNum and curLobbyActCount < Allow_Cfg_Max_Activity then
        table.insert(actLobbyList, actInfo)
        curLobbyActCount = curLobbyActCount + 1
      end
    end
  end
  addActToActList(actResidentList)
  addActToActList(actLimitList)
  local rpData = GetRPBannerDataForJaguar()
  if rpData then
    table.insert(actLobbyList, rpData)
  end
  table.sort(actLobbyList, sortBannerByTime)
  return actLobbyList
end
function logic_lobby_mid_banner.GetShowSupplyBannerList()
  if #LobbySystem.activityBtnDisplayList <= 0 then
    return {}
  end
  local actList = {}
  for i, actInfo in ipairs(LobbySystem.activityBtnDisplayList) do
    local bannerType = actInfo.BannerType or ENUM_BANNER_TYPE.Sidebar
    if bannerType == ENUM_BANNER_TYPE.OnlyShowSupply then
      actList[#actList + 1] = actInfo
    end
  end
  table.sort(actList, sortBannerByTime)
  return actList
end
function logic_lobby_mid_banner.GetWOWHallBannerList()
  log(bWriteLog and "logic_lobby_mid_banner.GetWOWHallBannerList")
  if #LobbySystem.activityBtnDisplayList <= 0 then
    log(bWriteLog and "logic_lobby_mid_banner.GetWOWHallBannerList LobbySystem.activityBtnDisplayList is empty")
    return {}
  end
  local actList = {}
  for i, actInfo in ipairs(LobbySystem.activityBtnDisplayList) do
    local bannerType = actInfo.BannerType or ENUM_BANNER_TYPE.Sidebar
    if bannerType == ENUM_BANNER_TYPE.WOW_Hall and IsWOWHallBannerAllowed(actInfo.ID) then
      actList[#actList + 1] = actInfo
    end
  end
  table.sort(actList, sortBannerByWeight)
  log_tree(bWriteLog and "logic_lobby_mid_banner.GetWOWHallBannerList actList", actList)
  return actList
end
function logic_lobby_mid_banner.CheckNewBannerTime(startTimeUTC)
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  local interval = serverTime - startTimeUTC
  return 0 < interval and interval < C_NEW_TIME_LIMIT
end
function logic_lobby_mid_banner.SaveClickSidebarBanner(bannerList)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eClickSidebarBanner)
  saveData = saveData or {}
  for i, v in ipairs(bannerList) do
    if logic_lobby_mid_banner.CheckNewBannerTime(v.StartTimeUTC) then
      saveData[tostring(v.ID)] = tostring(v.StartTimeUTC)
    end
  end
  PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eClickSidebarBanner)
end
function logic_lobby_mid_banner.CheckSidebarBannerNewRedDot(bannerList)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eClickSidebarBanner)
  saveData = saveData or {}
  for i, v in ipairs(bannerList) do
    if logic_lobby_mid_banner.CheckNewBannerTime(v.StartTimeUTC) and (not saveData[tostring(v.ID)] or saveData[tostring(v.ID)] ~= tostring(v.StartTimeUTC)) then
      return true
    end
  end
  return false
end
function logic_lobby_mid_banner.ProcOnClickBanner(ID, bannerList, isSidebarBanner)
  local UIUtil = require("client.common.ui_util")
  if UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.LobbyBtn) == false then
    ShowNotice(66372)
    return
  end
  log(bWriteLog and "logic_lobby_mid_banner.ProcOnClickBanner activityId = " .. tostring(ID))
  local TimeUtil = require("client.common.time_util")
  local StarterPackSystem = require("client.logic.starter_pack.logic_starter_pack")
  local gem_report_utils = require("client.logic.store.gem_report_utils")
  local info = {}
  for i, v in pairs(bannerList) do
    if v.ID == ID then
      info = v
      break
    end
  end
  local ret = TimeUtil.UnixTimeBetween(info.StartTimeUTC, info.EndTimeUTC)
  if ret == -1 then
    ShowNotice(LocUtil.GetLocalizeResStr("120106"))
    return
  elseif ret == 1 then
    ShowNotice(LocUtil.GetLocalizeResStr("4002"))
    return
  end
  local activityId = info.ID
  local url = info.JumpUrl
  local StringUtil = require("common.string_util")
  local params = StringUtil.ParseURLParams(url)
  local moduleID = tonumber(params and params.module)
  if url then
    local JumpSourceMacros = require("client.slua.config.ClientMacros.JumpSourceMacros")
    url = StringUtil.AppendUrlParam(url, JumpSourceMacros.URL_KEY, JumpSourceMacros.JumpSource.LobbyBanner)
    local jump_utils = require("client.logic.store.jump_utils")
    if moduleID and jump_utils.FitHideJumpModuleID[moduleID] then
      local LogicPufferBundle = require("client.slua.logic.download.bundle.logic_puffer_bundle")
      if not LogicPufferBundle.IsFitLobbyResDownloaded() then
        LogicPufferBundle.ShowFitLobbyResDownloadPopup()
        log_format("jump_utils.OpenJumpModule blocked by FIT, moduleId=%s", tostring(moduleID))
        return
      end
    end
    if moduleID == BP_ENUM_MODULE_SPECIAL_OFFER and tonumber(params and params.id) == 20 then
      local nBargainSource = isSidebarBanner and 2 or 3
      url = StringUtil.AppendUrlParam(url, "source", tostring(nBargainSource))
    end
    if StringUtil.Starts(url, "http") then
      local webModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.webModule)
      url = webModule:AddParameterByPersonalInfo(url, true)
    end
    GlobalData.JumpUrl(url)
  else
    ShowNotice(79412)
    return
  end
  local reportParam = gem_report_utils.GetReportParam(activityId, url, true)
  gem_report_utils.ReportLobbyClickEvent(gem_report_utils.SubEventName_LobbyBannerJump, reportParam)
  local tLogType = TLogEventDefine.ExposureEntrance
  if isSidebarBanner then
    tLogType = TLogEventDefine.OnClickSidebarBannerItem
  end
  if GameStatus.IsInMainCity() then
    local MainCityUITriggertLog = require("GameLua.Mod.MainCity.Client.Config.MainCityUITriggertLog")
    MainCityUITriggertLog.ReportTLogEvent(MainCityUITriggertLog.UIEnum.banner, reportParam)
  end
  local TLogReasonStrTable = {
    event_name = gem_report_utils.SubEventName_LobbyBannerJump,
    banner_id = info.ID,
    module = gem_report_utils.GetReportModule(url),
    language = Client.GetCurrentLanguage(),
    click = true
  }
  if string.find(url, "activityid=") then
    local realActivityId = string.match(url, "activityid=(%d+)")
    TLogReasonStrTable.activityid = tonumber(realActivityId)
  end
  local TLogReasonStr = json.encode(TLogReasonStrTable)
  ClientSendTLogReport(tLogType, 0, TLogReasonStr)
  log(bWriteLog and "TLog new format, logic_lobby_mid_banner.ProcOnClickBanner, reason : logic_lobby_mid_banner.ProcOnClickBanner, reason : " .. tostring(0) .. " reasonStr : " .. tostring(TLogReasonStr))
  if string.find(url, BP_ENUM_MODULE_BIND_FACEBOOK) ~= nil then
    local logic_bind_facebook = require("client.slua.logic.activity.logic_bind_facebook")
    logic_bind_facebook.ClickActEnterance()
  end
  if string.find(url, BP_ENUM_MODULE_ACTIVITY_HALLOWEEN_VEHICLE) ~= nil then
    local LogicHalloweenVehicle = require("client.logic.activity.logic_halloween_vehicle")
    LobbySystem.LobbyRedPointUpdate(BP_ENUM_MODULE_ACTIVITY_HALLOWEEN_VEHICLE, LogicHalloweenVehicle.IsShowRedPoint())
  end
  if string.find(url, BP_ENUM_MODULE_STARTER_PACK) then
    StarterPackSystem.SetPurchaseUITrigger(StarterPackSystem.PurchaseTriggerUI.CAROUSEL, true)
  end
end
return logic_lobby_mid_banner