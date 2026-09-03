local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
local data_config_marco = require("client.logic.data.data_config_marco")
local ConstCareer = require("client.slua.logic.career.const_career")
local Logic_WardrobeGun = require("client.slua.logic.wardrobe.logic_wardrobe_gun")
local CareerSystem = {
  bGraySwitch = false,
  bBannerSwitch = false,
  svrData = {},
  svrChangeData = {},
  svrModuleData = {},
  svrModuleSeasonData = {},
  bPublicShow = false,
  svrOthersData = {},
  svrOthersModuleData = {},
  svrOthersSeasonModuleData = {},
  clientModuleData = {},
  clientSeasonModuleData = {},
  clientOthersModuleData = {},
  clientOthersSeasonModuleData = {},
  jumpCacheUID = nil,
  httpRequestTimer = nil
}
local E_CareerModule = ConstCareer.E_CareerModule
local E_WeaponType = ConstCareer.E_WeaponType
local E_ModeType = ConstCareer.E_ModeType
local E_VehicleType = ConstCareer.E_VehicleType
local E_EditBaseTabType = ConstCareer.E_EditBaseTabType
local E_PersonalizeType = ConstCareer.E_PersonalizeType
local C_CareerMaxLevel
local nDefaultWeaponId = 101004
local nDefaultMapModeId = 10001
local nDefaultVehicleId = 1903001
local C_ServerConfigs = {
  Module = data_config_marco.career_module_table,
  Mode = data_config_marco.career_mode_table,
  Weapon = data_config_marco.career_weapon_table,
  Vehicle = data_config_marco.career_vehicle_table,
  BannerTask = data_config_marco.career_banner_task_table
}
CareerSystem.local _bIsCanClearData = true
local _nShowUserId, _tOpenedModuleId
local _tModuleAllType = {}
local _tModulePageCache = {}
local _tModuleSeasonPageCache = {}
local _tModuleCurShowType, _tAllCheckStatus, _nMainSelectModuleIndex, _tAllModuleData, _tGotTipCallbackHandle
function CareerSystem.IsOpen(isShowTip)
  if isShowTip == nil then
    isShowTip = false
  end
  return LobbySystem.CheckLobbyMenuOpen(BP_ENUM_SWITCH_CAREER, isShowTip) and CareerSystem.bGraySwitch
end
function CareerSystem.BannerIsOpen()
  return CareerSystem.bGraySwitch
end
function CareerSystem.OnModePreSwitch(preState, nextState)
  local logic_careerRedPoint = require("client.slua.logic.career.logic_careerRedPoint")
  if nextState.current == GameStatus.Fighting then
    if GameStatus.IsInMainCity() then
    else
      CareerSystem.svrChangeData = nil
      logic_careerRedPoint.Init()
    end
  elseif nextState.current == GameStatus.Login then
    CareerSystem.svrChangeData = nil
    logic_careerRedPoint.Init()
    CareerSystem.svrData = {}
    CareerSystem.svrModuleData = {}
    CareerSystem.svrModuleSeasonData = {}
  elseif nextState.preState == GameStatus.Fighting then
    _bIsCanClearData = true
    CareerSystem.ClearData()
    logic_careerRedPoint.DestroyData()
  end
end
function CareerSystem.IsModuleOpen(module)
  local config = CareerSystem.GetConfig(C_ServerConfigs.Module)
  if not config then
    return false
  end
  if not config[module] then
    return false
  end
  return config[module].is_open == 1
end
function CareerSystem.GetConfig(tableName)
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  return BasicDataServerTable:GetCacheData(tableName)
end
function CareerSystem.ShowEntry(uid)
  if not CareerSystem.IsOpen() or not uid then
    return false
  end
  uid = tonumber(uid)
  local nLevel = 1
  local nProValue = 0
  if not uid or uid == tonumber(DataMgr.roleData.uid) then
    if CareerSystem.svrData and next(CareerSystem.svrData) then
      nLevel = CareerSystem.svrData.level or 1
      nProValue = CareerSystem.svrData.pro or 0
    else
      nLevel, nProValue = CareerSystem.GetLocalCacheCareerLevel()
      CareerSystem.ReqCareerAllData()
    end
  else
    CareerSystem.ReqCareerOthersData(uid)
  end
  return true
end
function CareerSystem.InitModuleLevelConfig()
  CareerSystem.cModuleLevelConfig = {}
  local CareerModuleLevelConfig = CDataTable.GetTable("CareerModuleLevelConfig")
  for _, v in pairs(CareerModuleLevelConfig) do
    if not CareerSystem.cModuleLevelConfig[v.ModuleID] then
      CareerSystem.cModuleLevelConfig[v.ModuleID] = {}
    end
    table.insert(CareerSystem.cModuleLevelConfig[v.ModuleID], v)
  end
  for _, v in pairs(CareerSystem.cModuleLevelConfig) do
    table.sort(v, function(a, b)
      return a.Level < b.Level
    end)
  end
end
function CareerSystem.GetModuleLevelConfig(module)
  if not CareerSystem.cModuleLevelConfig then
    CareerSystem.InitModuleLevelConfig()
  end
  return CareerSystem.cModuleLevelConfig[module]
end
function CareerSystem.IsMaxLevel(level)
  if not C_CareerMaxLevel then
    local LevelConfig = CDataTable.GetTable("CareerLevelConfig")
    for _, v in pairs(LevelConfig) do
      if v.LevelUpNeed == 0 then
        C_CareerMaxLevel = v.Level
        break
      end
    end
  end
  return level >= (C_CareerMaxLevel or 99)
end
function CareerSystem.ReqCareerIsOpen()
  local CareerHandler = require("client.network.Protocol.CareerHandler")
  CareerHandler.send_career_is_open_req()
end
function CareerSystem.OnCareerIsOpenRsp(switch)
  log(bWriteLog and "[edward] CareerSystem.OnCareerIsOpenRsp switch = " .. tostring(switch))
  CareerSystem.bGraySwitch = switch
  if CareerSystem.IsOpen() then
    EventSystem:postEvent(EVENTTYPE_CAREER, EVENTID_CAREER_SHOW_ENTRY)
    local logic_careerRedPoint = require("client.slua.logic.career.logic_careerRedPoint")
    logic_careerRedPoint.Init()
    local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
    for _, v in pairs(C_ServerConfigs) do
      BasicDataServerTable:GetOrReqData(v)
    end
    CareerSystem.ReqCareerAllData()
  end
end
function CareerSystem.OnCareerIsBannerOpenRsp(bIsOpen)
  CareerSystem.bBannerSwitch = bIsOpen
end
function CareerSystem.ReqCareerAllData()
  local CareerHandler = require("client.network.Protocol.CareerHandler")
  CareerHandler.send_career_all_data_req()
  CareerHandler.send_career_banner_get_data_req()
end
function CareerSystem.OnCareerAllDataRsp(data)
  log(bWriteLog and "[edward] CareerSystem.OnCareerAllDataRsp")
  CareerSystem.svrData = data
  if data then
    CareerSystem.bPublicShow = data.show_public == 1
    local level = CareerSystem.svrData.level or 1
    local levelConfig = CDataTable.GetTableData("CareerLevelConfig", level)
    EventSystem:postEvent(EVENTTYPE_CAREER, EVENTID_CAREER_GET_DATA, tonumber(DataMgr.roleData.uid), level, CareerSystem.svrData.pro, levelConfig.LevelIcon)
    local logic_careerRedPoint = require("client.slua.logic.career.logic_careerRedPoint")
    logic_careerRedPoint.InitMedalsRedData(data.red_dot)
  end
end
local _UpdateNewModuleData = function(src, dst, nModuleId, nMappingId)
  local bIsNewMedals = false
  if not src or not dst then
    return bIsNewMedals
  end
  if src.medal ~= dst.medal_new and dst.medal_new ~= 0 then
    local nMedalsLevel = dst.medal_new
    local logic_careerRedPoint = require("client.slua.logic.career.logic_careerRedPoint")
    logic_careerRedPoint.UpdateMedalsNewItemRedPoint(nModuleId, nMappingId, nMedalsLevel)
    local Logic_CareerEdit = require("client.slua.logic.career.logic_careerEdit")
    Logic_CareerEdit:UpdateMedalsItemDataCache(nModuleId, nMappingId, nMedalsLevel)
    local nItemId = Logic_CareerEdit:GetMedalsItemId(nModuleId, nMappingId, nMedalsLevel)
    if nItemId then
      CareerSystem.ShowGotTip(E_EditBaseTabType.Medals, nModuleId, nItemId)
    end
    bIsNewMedals = true
  end
  src.medal = dst.medal_new
  src.pro = dst.pro_new
  src.pro_season = dst.pro_season_new
  return bIsNewMedals
end
local _InitSvrData = function(sModuleKey, nMappingId)
  local tSvrData = CareerSystem.svrData
  if not tSvrData[sModuleKey] then
    tSvrData[sModuleKey] = {}
  end
  if not tSvrData[sModuleKey][nMappingId] then
    tSvrData[sModuleKey][nMappingId] = {}
  end
end
local _CleanModuleCacheData = function(nModuleId)
  if CareerSystem.IsSelfCareer() then
    if _tAllModuleData then
      _tAllModuleData[nModuleId] = nil
    end
    _tModulePageCache[nModuleId] = nil
    _tModuleSeasonPageCache[nModuleId] = nil
  end
end
function CareerSystem.OnCareerChangeNtf(update_data)
  CareerSystem.svrChangeData = update_data
  if update_data then
    if CareerSystem.svrData then
      local tSvrData = CareerSystem.svrData
      tSvrData.level = update_data.level_new
      tSvrData.pro = update_data.pro_new
      tSvrData.pro_season = update_data.pro_season_new
      CareerSystem.UpdateModuleSvrData(update_data.mode, "mode", E_CareerModule.Mode)
      CareerSystem.UpdateModuleSvrData(update_data.weapon, "weapon", E_CareerModule.Weapon)
      CareerSystem.UpdateModuleSvrData(update_data.vehicle, "vehicle", E_CareerModule.Vehicle)
    end
    EventSystem:postEvent(EVENTTYPE_CAREER, EVENTID_CAREER_DATA_CHANGE)
    EventSystem:postEvent(EVENTTYPE_CAREER, EVENTID_CAREER_RED_DOT_DATA)
  end
end
function CareerSystem.UpdateModuleSvrData(tUpdateData, sKey, nModuleId)
  if tUpdateData then
    local Logic_CareerEdit = require("client.slua.logic.career.logic_careerEdit")
    local nBaseTab = E_EditBaseTabType.Medals
    local bIsNewMedals = false
    local tSvrData = CareerSystem.svrData
    for id, v in pairs(tUpdateData) do
      _InitSvrData(sKey, id)
      local bIsNew = _UpdateNewModuleData(tSvrData[sKey][id], v, nModuleId, id)
      bIsNewMedals = bIsNewMedals or bIsNew
    end
    _CleanModuleCacheData(nModuleId)
    if bIsNewMedals then
      Logic_CareerEdit:UpdateMedalsListCache(nBaseTab, nModuleId)
    end
  end
end
function CareerSystem.ReqCareerOthersData(uid)
  local CareerHandler = require("client.network.Protocol.CareerHandler")
  CareerHandler.send_career_others_data_req(uid)
end
function CareerSystem.OnCareerOthersDataRsp(uid, data)
  if not CareerSystem.svrOthersData then
    CareerSystem.svrOthersData = {}
  end
  local TableUtil = require("common.table_util")
  if TableUtil.CountTable(CareerSystem.svrOthersData) > 10 then
    CareerSystem.svrOthersData = {}
  end
  CareerSystem.svrOthersData[uid] = data
  CareerSystem.bPublicShow = data.show_public == 1
  local level = data.level or 1
  local levelConfig = CDataTable.GetTableData("CareerLevelConfig", level)
  EventSystem:postEvent(EVENTTYPE_CAREER, EVENTID_CAREER_GET_DATA, uid, level, data.pro, levelConfig.LevelIcon)
end
function CareerSystem.IsPublicShow()
  return CareerSystem.bPublicShow
end
function CareerSystem.IsGetedData()
  local bIsGeted = false
  if next(CareerSystem.svrData) then
    bIsGeted = true
  end
  return bIsGeted
end
function CareerSystem.ReqCareerIsPublic()
  local CareerHandler = require("client.network.Protocol.CareerHandler")
  CareerHandler.send_career_is_show_public_req()
end
function CareerSystem.OnCareerIsPublicRsp(show_public)
  CareerSystem.bPublicShow = show_public
  EventSystem:postEvent(EVENTTYPE_CAREER, EVENTID_CAREER_SET_PUBLIC)
end
function CareerSystem.ReqCareerSetPublic()
  CareerSystem.bPublicShow = not CareerSystem.bPublicShow
  local CareerHandler = require("client.network.Protocol.CareerHandler")
  CareerHandler.send_career_set_show_public_req(CareerSystem.bPublicShow and 1 or 0)
end
function CareerSystem.OnCareerSetPublicRsp(show_public)
  CareerSystem.bPublicShow = show_public
  EventSystem:postEvent(EVENTTYPE_CAREER, EVENTID_CAREER_SET_PUBLIC)
end
local C_HttpRequestHeaders = {
  ["Ocp-Apim-Subscription-Key"] = ""
}
local _GetTranslator = function()
  local UIUtil = require("client.common.ui_util")
  local _GameFrontendHUD = UIUtil.GetGameInstance():GetAssociatedFrontendHUD()
  if _GameFrontendHUD then
    return _GameFrontendHUD:GetTranslator()
  end
  return nil
end
local _GetHttpRequestHeaders = function()
  if C_HttpRequestHeaders["Ocp-Apim-Subscription-Key"] == "" then
    local translator = _GetTranslator()
    if translator then
      C_HttpRequestHeaders["Ocp-Apim-Subscription-Key"] = translator.SubscriptionKey
    end
  end
  return C_HttpRequestHeaders
end
local _HttpRequest = function(url, isLock)
  local translator = _GetTranslator()
  if translator then
    translator.OnGetAccessTokenDelegate:Bind(CareerSystem.OnModuleInfoRsp)
    translator:GetAccessToken(true, url, "GET", _GetHttpRequestHeaders(), "")
    if isLock then
      logic_connection_waiting:Show(0)
    end
    local timer_ticker = require("common.time_ticker")
    if CareerSystem.httpRequestTimer then
      timer_ticker.RemoveTimer(CareerSystem.httpRequestTimer)
      CareerSystem.httpRequestTimer = nil
    end
    CareerSystem.httpRequestTimer = timer_ticker.AddTimerOnce(5, function()
      if CareerSystem.httpRequestTimer then
        timer_ticker.RemoveTimer(CareerSystem.httpRequestTimer)
        CareerSystem.httpRequestTimer = nil
      end
      ShowNotice(24839)
      EventSystem:postEvent(EVENTTYPE_CAREER, EVENTID_CAREER_GET_MODULE_DATA_TIME_OUT)
      if isLock then
        logic_connection_waiting:Hide(0)
      end
    end)
  end
end
local C_GetCareerInfoUrlPrefix = ""
local C_GetCareerInfoUrlToken = "cgrPTxw71pa4DVEvAWot"
local C_Module2HttpModuleMap = {
  [E_CareerModule.Weapon] = "gunCareer",
  [E_CareerModule.Mode] = "modeCareer",
  [E_CareerModule.Vehicle] = "vehicleCareer"
}
local C_HttpModule2ModuleMap = {
  [E_CareerModule.Weapon] = 101,
  [E_CareerModule.Mode] = 201,
  [E_CareerModule.Vehicle] = 301
}
local C_HttpModuleIDKeyMap = {
  [E_CareerModule.Weapon] = "gunId",
  [E_CareerModule.Mode] = "careerModeId",
  [E_CareerModule.Vehicle] = "vehicleId"
}
local _GetBaseUrl = function()
  if C_GetCareerInfoUrlPrefix and C_GetCareerInfoUrlPrefix ~= "" then
    return C_GetCareerInfoUrlPrefix
  end
  local BusinessHelper = import("BusinessHelper")
  local strRegion = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local urlKey = FuncUtil.GetKeywordByID(3377009) or ""
  if BusinessHelper.GetIMSDKEnv() == 1 and globalConfig.IsDirectConnect() then
    if strRegion == PublishRegionMacros.CE or strRegion == PublishRegionMacros.FITCE then
      C_GetCareerInfoUrlPrefix = FuncUtil.GetDomainByID(3366077) .. "/" .. urlKey .. "CareerTyf/"
    elseif strRegion == PublishRegionMacros.BLUEHOLE then
      C_GetCareerInfoUrlPrefix = FuncUtil.GetDomainByID(3366078) .. ":443/" .. urlKey .. "Career/"
    else
      C_GetCareerInfoUrlPrefix = FuncUtil.GetDomainByID(3366079) .. ":443/" .. urlKey .. "Career/"
    end
  elseif strRegion == PublishRegionMacros.BLUEHOLE then
    C_GetCareerInfoUrlPrefix = FuncUtil.GetDomainByID(3366080) .. "/" .. urlKey .. "Career/"
  else
    C_GetCareerInfoUrlPrefix = FuncUtil.GetDomainByID(3366077) .. "/" .. urlKey .. "Career/"
  end
  return C_GetCareerInfoUrlPrefix
end
local _GetSign = function(url)
  local sign = Client.MD5HashAnsiString(url)
  sign = string.upper(sign)
  return sign
end
function CareerSystem.ClearDelegateAndTimer()
  local Translator = _GetTranslator()
  if Translator then
    Translator.OnGetAccessTokenDelegate:Clear()
  end
  if CareerSystem.httpRequestTimer then
    local timer_ticker = require("common.time_ticker")
    timer_ticker.RemoveTimer(CareerSystem.httpRequestTimer)
    CareerSystem.httpRequestTimer = nil
  end
end
function CareerSystem.ReqModuleInfo(module, modeType, uid, isSeason, isLock)
  module = C_Module2HttpModuleMap[module]
  if not module then
    log_error(bWriteLog and "[edward] CareerSystem.ReqModuleInfo, module is error, please check!!!")
    return
  end
  local ticket = Client.GetWebViewTicket(NetInterface)
  local baseUrl = _GetBaseUrl() .. module .. "?"
  local paramStr = ""
  if modeType then
    paramStr = paramStr .. "mode=" .. modeType .. "&pageNo=1&pageSize=99"
  else
    paramStr = paramStr .. "pageNo=1&pageSize=99"
  end
  local TimeUtil = require("client.common.time_util")
  paramStr = paramStr .. "&sMOMITimestamp=" .. TimeUtil.GetServerTimeInSec() .. "&sid=" .. (isSeason and DataMgr.season_id or -1) .. (ticket and ticket ~= "" and "&ticket=" .. ticket or "") .. "&uid=" .. (uid or DataMgr.roleData.uid) .. "&version=" .. Client.GetAppVersion()
  local getTokenUrl = paramStr .. "&sMOMIToken=" .. C_GetCareerInfoUrlToken
  local sign = _GetSign(getTokenUrl)
  local reqUrl = baseUrl .. paramStr .. "&sMOMISign=" .. sign
  log(bWriteLog and "[edward] CareerSystem.ReqModuleInfo reqUrl = " .. reqUrl)
  _HttpRequest(reqUrl, isLock)
end
local GetHttpDataError = function()
  ShowNotice(24839)
  EventSystem:postEvent(EVENTTYPE_CAREER, EVENTID_CAREER_GET_MODULE_DATA_ERROR)
end
local ConstructClientHttpData = function(src, module, svrData)
  src = src or {}
  if not src[module] then
    src[module] = {}
  end
  local idKey = C_HttpModuleIDKeyMap[module]
  for _, v in ipairs(svrData) do
    local id = v[idKey]
    if id then
      src[module][id] = v
    end
  end
  return src
end
local ConstructClientOtherHttpData = function(src, module, uid, svrData)
  src = src or {}
  if not src[module] then
    src[module] = {}
  end
  local TableUtil = require("common.table_util")
  if TableUtil.CountTable(src[module]) > 10 then
    src[module] = {}
  end
  if not src[module][uid] then
    src[module][uid] = {}
  end
  local idKey = C_HttpModuleIDKeyMap[module]
  for _, v in ipairs(svrData) do
    local id = v[idKey]
    if id then
      src[module][uid][id] = v
    end
  end
  return src
end
function CareerSystem.OnModuleInfoRsp(isSuccess, httpData)
  CareerSystem.ClearDelegateAndTimer()
  if not isSuccess or httpData == "" then
    log(bWriteLog and "[edward] CareerSystem.OnModuleInfoRsp, is no success")
    GetHttpDataError()
    return
  end
  local data = string.gsub(httpData, "Bearer ", "")
  data = json.decode(data)
  if not data then
    log(bWriteLog and "[edward] CareerSystem.OnModuleInfoRsp, data parse fail")
    GetHttpDataError()
    return
  end
  if data.state ~= "SUCCESS" then
    if data.state == "FAILURE" then
      log(bWriteLog and "[edward] CareerSystem.OnModuleInfoRsp, failure reason = " .. data.error)
    end
    GetHttpDataError()
    return
  end
  local tCareerData = data.data
  local module
  for k, v in pairs(C_HttpModule2ModuleMap) do
    if v == tCareerData.module then
      module = k
      break
    end
  end
  if not module then
    log(bWriteLog and "[edward] CareerSystem.OnModuleInfoRsp, can not find module")
    GetHttpDataError()
    return
  end
  local uid = tonumber(tCareerData.uid)
  local bIsSeason = false
  if uid == tonumber(DataMgr.roleData.uid) then
    if tCareerData.sid == -1 then
      if not CareerSystem.svrModuleData then
        CareerSystem.svrModuleData = {}
      end
      CareerSystem.svrModuleData[module] = tCareerData.list
      CareerSystem.clientModuleData = ConstructClientHttpData(CareerSystem.clientModuleData, module, tCareerData.list)
    else
      bIsSeason = true
      if not CareerSystem.svrModuleSeasonData then
        CareerSystem.svrModuleSeasonData = {}
      end
      CareerSystem.svrModuleSeasonData[module] = tCareerData.list
      CareerSystem.clientSeasonModuleData = ConstructClientHttpData(CareerSystem.clientSeasonModuleData, module, tCareerData.list)
    end
  else
    local TableUtil = require("common.table_util")
    if tCareerData.sid == -1 then
      if not CareerSystem.svrOthersModuleData then
        CareerSystem.svrOthersModuleData = {}
      end
      if not CareerSystem.svrOthersModuleData[module] then
        CareerSystem.svrOthersModuleData[module] = {}
      end
      if TableUtil.CountTable(CareerSystem.svrOthersModuleData[module]) > 10 then
        CareerSystem.svrOthersModuleData[module] = {}
      end
      CareerSystem.svrOthersModuleData[module][uid] = tCareerData.list
      CareerSystem.clientOthersModuleData = ConstructClientOtherHttpData(CareerSystem.clientOthersModuleData, module, uid, tCareerData.list)
    else
      if not CareerSystem.svrOthersSeasonModuleData then
        CareerSystem.svrOthersSeasonModuleData = {}
      end
      if not CareerSystem.svrOthersSeasonModuleData[module] then
        CareerSystem.svrOthersSeasonModuleData[module] = {}
      end
      if 10 < TableUtil.CountTable(CareerSystem.svrOthersSeasonModuleData[module]) then
        CareerSystem.svrOthersModuleData[module] = {}
      end
      CareerSystem.svrOthersSeasonModuleData[module][uid] = tCareerData.list
      CareerSystem.clientOthersSeasonModuleData = ConstructClientOtherHttpData(CareerSystem.clientOthersSeasonModuleData, module, uid, tCareerData.list)
      bIsSeason = true
    end
  end
  EventSystem:postEvent(EVENTTYPE_CAREER, EVENTID_CAREER_GET_MODULE_DATA, tonumber(tCareerData.uid), module, bIsSeason)
end
function CareerSystem.RequestWeaponDiySkin()
  if not Logic_WardrobeGun:HasGunSkinList() then
    Logic_WardrobeGun:GetGunSkinListReq()
  end
  local Logic_Career_Weapon = require("client.slua.logic.career.logic_career_weapon")
  local tTempData = Logic_Career_Weapon.GetWeaponShowList()
  if not tTempData then
    return
  end
  local WeaponDiyNetHandler = require("client.network.Protocol.WeaponDiyHandler")
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local logic_wardrobe_new = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local logic_wardrobe_gun = require("client.slua.logic.wardrobe.logic_wardrobe_gun")
  local weapon_diy_rec_scheme = require("client.slua.logic.weapon_diy.weapon_diy_rec_scheme")
  local tAllWeaponId = {}
  for k, _ in pairs(tTempData) do
    local nSkinInsID = logic_wardrobe_gun:GetSkinIdByWeaponID(k)
    local tItemData = wardrobe_data:GetValidHallDepotItemDataByInsID(nSkinInsID)
    local nSkinItemId = tItemData and tItemData.resID or 0
    if tItemData and nSkinItemId ~= 0 and logic_wardrobe_new:IsCanUse(nSkinItemId) and weapon_diy_rec_scheme[nSkinItemId] then
      table.insert(tAllWeaponId, tItemData.resID)
    end
  end
  if 0 < #tAllWeaponId then
    WeaponDiyNetHandler.send_batch_get_weapon_diy_summary_data_req(tAllWeaponId)
  end
end
function CareerSystem.GetShowModule()
  if not _tOpenedModuleId then
    local tAllModule = {}
    for _, v in pairs(E_CareerModule) do
      if CareerSystem.IsModuleOpen(v) then
        table.insert(tAllModule, v)
      end
    end
    local tModuleCfg = CDataTable.GetTable("CareerModuleConfig")
    local tModuleData = {}
    for _, v in pairs(tModuleCfg) do
      tModuleData[v.ModuleID] = v
    end
    table.sort(tAllModule, function(a, b)
      return tModuleData[a].Sort < tModuleData[b].Sort
    end)
    local tConfig = CareerSystem.GetConfig(C_ServerConfigs.Module)
    if tConfig then
      _tOpenedModuleId = tAllModule
    end
    return tAllModule
  end
  return _tOpenedModuleId
end
function CareerSystem.SetIsCanClearData(bIsCan)
  _bIsCanClearData = bIsCan
  if not bIsCan then
    CareerSystem.CacheCurrentUid()
  end
end
function CareerSystem.GetModuleData(nModuleId)
  local tAllData
  if CareerSystem.IsSelfCareer() then
    if CareerSystem.svrData then
      if nModuleId == E_CareerModule.Weapon then
        tAllData = CareerSystem.svrData.weapon
      elseif nModuleId == E_CareerModule.Vehicle then
        tAllData = CareerSystem.svrData.vehicle
      elseif nModuleId == E_CareerModule.Mode then
        local Logic_Career_Mode = require("client.slua.logic.career.logic_career_mode")
        tAllData = Logic_Career_Mode.RemoveOtherTypeData(CareerSystem.svrData.mode)
      end
    end
  elseif CareerSystem.svrOthersData and CareerSystem.svrOthersData[_nShowUserId] then
    local tTempData = CareerSystem.svrOthersData[_nShowUserId]
    if nModuleId == E_CareerModule.Weapon then
      tAllData = tTempData.weapon
    elseif nModuleId == E_CareerModule.Vehicle then
      tAllData = tTempData.vehicle
    elseif nModuleId == E_CareerModule.Mode then
      local Logic_Career_Mode = require("client.slua.logic.career.logic_career_mode")
      tAllData = Logic_Career_Mode.RemoveOtherTypeData(tTempData.mode)
    end
  end
  return tAllData or {}
end
function CareerSystem.GetModuleItemProData(nModuleId, nItemId, bIsSeason)
  local tAllItemData = CareerSystem.GetModuleData(nModuleId)
  if tAllItemData[nItemId] then
    if bIsSeason then
      return tAllItemData[nItemId].pro_season
    else
      return tAllItemData[nItemId].pro
    end
  end
end
function CareerSystem.GetModuleItemMedal(nModuleId, nItemId)
  local tAllItemData = CareerSystem.GetModuleData(nModuleId)
  if tAllItemData[nItemId] then
    return tAllItemData[nItemId].medal
  end
  return 0
end
function CareerSystem.SetShowUserId(nUserId)
  _nShowUserId = nUserId
end
function CareerSystem.GetShowUserId()
  return _nShowUserId or tonumber(DataMgr.roleData.uid)
end
function CareerSystem.GetCareerLevel()
  local nLevel = 0
  if CareerSystem.IsSelfCareer() then
    if CareerSystem.svrData then
      nLevel = CareerSystem.svrData.level or 1
    end
  elseif CareerSystem.svrOthersData and CareerSystem.svrOthersData[_nShowUserId] then
    local tData = CareerSystem.svrOthersData[_nShowUserId]
    nLevel = tData.level or 1
  end
  return nLevel
end
function CareerSystem.GetCareerTotalPro()
  local nValue = 0
  if CareerSystem.IsSelfCareer() then
    if CareerSystem.svrData then
      nValue = CareerSystem.svrData.pro or 0
    end
  elseif CareerSystem.svrOthersData and CareerSystem.svrOthersData[_nShowUserId] then
    local tData = CareerSystem.svrOthersData[_nShowUserId]
    nValue = tData.pro or 0
  end
  return nValue
end
function CareerSystem.GetMyCareerTotalPro()
  local nValue = 0
  if CareerSystem.svrData then
    nValue = CareerSystem.svrData.pro or 0
  end
  return nValue
end
function CareerSystem.UpdateModuleData(nModuleId)
  if not _tAllModuleData then
    _tAllModuleData = {}
  end
  local nTotalPro = 0
  local nSeasonTotalPro = 0
  local nItemId, nItemPro
  local tMedalCount = {
    0,
    0,
    0
  }
  local tAllData = CareerSystem.GetModuleData(nModuleId)
  for nId, v in pairs(tAllData) do
    nTotalPro = nTotalPro + v.pro or 0
    nSeasonTotalPro = nSeasonTotalPro + v.pro_season or 0
    if v.medal ~= 0 and tMedalCount[v.medal] then
      tMedalCount[v.medal] = tMedalCount[v.medal] + 1
    end
    if not nItemPro or nItemPro < v.pro then
      nItemId = nId
      nItemPro = v.pro
    end
  end
  if not nItemId then
    if nModuleId == E_CareerModule.Weapon then
      nItemId = nDefaultWeaponId
    elseif nModuleId == E_CareerModule.Mode then
      nItemId = nDefaultMapModeId
    elseif nModuleId == E_CareerModule.Vehicle then
      nItemId = nDefaultVehicleId
    else
      nItemId = 0
    end
    nItemPro = tAllData[nItemId] and tAllData[nItemId].pro or 0
  end
  if not nItemId or nItemId == 0 then
    log_error(bWriteLog and " CareerSystem.UpdateModuleData not ItemId")
    return
  end
  _tAllModuleData[nModuleId] = {
    nTotalPro = nTotalPro,
    nSeasonTotalPro = nSeasonTotalPro,
    nShowItemId = nItemId,
    nShowItemPro = nItemPro,
      }
end
function CareerSystem.GetModuleSummaryData(nModuleId)
  if not _tAllModuleData or not _tAllModuleData[nModuleId] then
    CareerSystem.UpdateModuleData(nModuleId)
  end
  return _tAllModuleData[nModuleId] or {}
end
function CareerSystem.IsFirst()
  local nPlayerUId = _nShowUserId or tonumber(DataMgr.roleData.uid)
  local tLocalCacheData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.CareerLocalCache) or {}
  if tLocalCacheData.tLevelCache and tLocalCacheData.tLevelCache[nPlayerUId] then
    return false
  end
  return true
end
function CareerSystem.IsNewSeason()
  local tLocalCacheData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.CareerLocalCache) or {}
  if tLocalCacheData and tLocalCacheData.nSeason == DataMgr.season_id then
    return false
  end
  return true
end
function CareerSystem.SaveCareerOpenedSeason()
  if CareerSystem.IsSelfCareer() and CareerSystem.GetIsExistSeasonData() then
    local tLocalCacheData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.CareerLocalCache) or {}
    tLocalCacheData.nSeason = DataMgr.season_id
    PlayerPrefsSystem.SaveTableToFile_N(tLocalCacheData, PlayerPrefsSystem.ePlayerPrefsType.CareerLocalCache)
  end
end
function CareerSystem.SaveCareerLevelData()
  if CareerSystem.IsSelfCareer() then
    local tLocalCacheData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.CareerLocalCache) or {}
    local nPlayerUid = CareerSystem.GetShowUserId()
    if not tLocalCacheData.tLevelCache then
      tLocalCacheData.tLevelCache = {}
    end
    local tLevelCache = tLocalCacheData.tLevelCache
    if not tLocalCacheData.isInCareerMain then
      tLocalCacheData.isInCareerMain = true
    end
    if not tLevelCache[nPlayerUid] then
      tLevelCache[nPlayerUid] = {
        nLevel = CareerSystem.svrData.level or 1,
        nPro = CareerSystem.svrData.pro or 0
      }
    else
      tLevelCache[nPlayerUid].nLevel = CareerSystem.svrData.level or 1
      tLevelCache[nPlayerUid].nPro = CareerSystem.svrData.pro or 0
    end
    PlayerPrefsSystem.SaveTableToFile_N(tLocalCacheData, PlayerPrefsSystem.ePlayerPrefsType.CareerLocalCache)
  end
end
function CareerSystem.GetLocalCacheCareerLevel()
  local nLevel = 1
  local nProValue = 0
  if CareerSystem.IsSelfCareer() then
    local tLocalCacheData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.CareerLocalCache) or {}
    local nPlayerUid = CareerSystem.GetShowUserId()
    local tLevelCache = tLocalCacheData.tLevelCache
    if tLevelCache and tLevelCache[nPlayerUid] then
      nLevel = tLevelCache[nPlayerUid].nLevel
      nProValue = tLevelCache[nPlayerUid].nPro
    else
      CareerSystem.SaveCareerLevelData()
    end
  end
  return nLevel, nProValue
end
function CareerSystem.ClearData()
  if not _bIsCanClearData then
    return
  end
  CareerSystem.ClearDelegateAndTimer()
  _nMainSelectModuleIndex = nil
  _tAllModuleData = nil
  _tAllCheckStatus = nil
  _tModuleCurShowType = nil
end
function CareerSystem.IsSelfCareer()
  if not _nShowUserId then
    return true
  end
  return _nShowUserId == tonumber(DataMgr.roleData.uid)
end
function CareerSystem.GetModuleAllType(nModuleId)
  if not _tModuleAllType[nModuleId] then
    local tShowType = {}
    local tAllType = {}
    if nModuleId == E_CareerModule.Weapon then
      tAllType = E_WeaponType
    elseif nModuleId == E_CareerModule.Vehicle then
      tAllType = E_VehicleType
    elseif nModuleId == E_CareerModule.Mode then
      tAllType = E_ModeType
    end
    for _, v in pairs(tAllType) do
      table.insert(tShowType, v)
    end
    table.sort(tShowType, function(a, b)
      return a < b
    end)
    _tModuleAllType[nModuleId] = tShowType
  end
  return _tModuleAllType[nModuleId]
end
function CareerSystem.GetModuleSubTypeAllItem(nModuleId, nShowType, bIsSeason)
  if CareerSystem.IsSelfCareer() then
    if bIsSeason then
      return _tModuleSeasonPageCache[nModuleId] and _tModuleSeasonPageCache[nModuleId][nShowType]
    else
      return _tModulePageCache[nModuleId] and _tModulePageCache[nModuleId][nShowType]
    end
  end
end
function CareerSystem.SetModuleSubTypeAllItem(nModuleId, nShowType, tAllItem, bIsSeason)
  if not CareerSystem.IsSelfCareer() then
    return
  end
  if bIsSeason then
    if not _tModuleSeasonPageCache[nModuleId] then
      _tModuleSeasonPageCache[nModuleId] = {}
    end
    _tModuleSeasonPageCache[nModuleId][nShowType] = tAllItem
  else
    if not _tModulePageCache[nModuleId] then
      _tModulePageCache[nModuleId] = {}
    end
    _tModulePageCache[nModuleId][nShowType] = tAllItem
  end
end
function CareerSystem.GetCheckKey(nModuleId, nShowType)
  local sKey = ""
  if nModuleId == E_CareerModule.Mode then
    if nShowType == E_ModeType.Theme then
      sKey = "Check_" .. nModuleId .. nShowType
    else
      sKey = "Check_" .. nModuleId
    end
  else
    sKey = "Check_" .. nModuleId
  end
  return sKey
end
function CareerSystem.GetCheckState(nModuleId, nShowType)
  nShowType = nShowType or CareerSystem.GetModuleCurShowType(nModuleId)
  local sKey = CareerSystem.GetCheckKey(nModuleId, nShowType)
  if not _tAllCheckStatus or not _tAllCheckStatus[sKey] then
    local _, proseason = CareerSystem.GetSelectModuleProNProSeason(nModuleId)
    return proseason ~= 0 and 1 or 0
  end
  return _tAllCheckStatus[sKey]
end
function CareerSystem.SetCheckState(nModuleId, nShowType, nState)
  nShowType = nShowType or CareerSystem.GetModuleCurShowType(nModuleId)
  if not _tAllCheckStatus then
    _tAllCheckStatus = {}
  end
  local sKey = CareerSystem.GetCheckKey(nModuleId, nShowType)
  _tAllCheckStatus[sKey] = nState
end
function CareerSystem.GetIsSeason(nModuleId, nShowType)
  nShowType = nShowType or CareerSystem.GetModuleCurShowType(nModuleId)
  return CareerSystem.GetCheckState(nModuleId, nShowType) == 1
end
function CareerSystem.SetModuleCurShowType(nModuleId, nShowType)
  if not nShowType then
    return
  end
  if not _tModuleCurShowType then
    _tModuleCurShowType = {}
  end
  _tModuleCurShowType[nModuleId] = nShowType
end
function CareerSystem.GetModuleCurShowType(nModuleId)
  if not _tModuleCurShowType or not _tModuleCurShowType[nModuleId] then
    return 0
  end
  return _tModuleCurShowType[nModuleId]
end
function CareerSystem.GetCacheKey(nModuleId, nShowType)
  return "Data_" .. nModuleId .. nShowType .. CareerSystem.GetCheckState(nModuleId, nShowType)
end
function CareerSystem.GetModuleShowData(nModuleId, nShowType)
  if nModuleId == E_CareerModule.Weapon then
    local Logic_Career_Weapon = require("client.slua.logic.career.logic_career_weapon")
    return Logic_Career_Weapon.GetAllWeaponDetailsData(nShowType)
  elseif nModuleId == E_CareerModule.Vehicle then
    local Logic_Career_Vehicle = require("client.slua.logic.career.logicCareerVehicle")
    return Logic_Career_Vehicle.GetVehicleShowData(nShowType)
  elseif nModuleId == E_CareerModule.Mode then
    local Logic_Career_Mode = require("client.slua.logic.career.logic_career_mode")
    return Logic_Career_Mode.GetModeShowData(nShowType)
  end
  return {}
end
function CareerSystem.GetIsExistSeasonData()
  local tAllModule = CareerSystem.GetShowModule()
  if not tAllModule then
    return false
  end
  for _, v in pairs(tAllModule) do
    local _, nSeasonTotalPro = CareerSystem.GetSelectModuleProNProSeason(v)
    if nSeasonTotalPro ~= 0 then
      return true
    end
  end
  return false
end
function CareerSystem.GetSelectModuleProNProSeason(nModuleId)
  local tModuleData = CareerSystem.GetModuleSummaryData(nModuleId)
  local nTotalPro = 0
  local nSeasonTotalPro = 0
  if tModuleData then
    nTotalPro = tModuleData.nTotalPro or 0
    nSeasonTotalPro = tModuleData.nSeasonTotalPro or 0
  end
  return nTotalPro, nSeasonTotalPro
end
function CareerSystem.GetModuleDetailedData(nModuleId, bIsSeason)
  local tDetailedData
  if CareerSystem.IsSelfCareer() then
    if bIsSeason then
      local tTempData = CareerSystem.clientSeasonModuleData
      tDetailedData = tTempData and tTempData[nModuleId]
    else
      local tTempData = CareerSystem.clientModuleData
      tDetailedData = tTempData and tTempData[nModuleId]
    end
  elseif bIsSeason then
    local tTempData = CareerSystem.clientOthersSeasonModuleData
    tTempData = tTempData[nModuleId] or {}
    tDetailedData = tTempData and tTempData[_nShowUserId]
  else
    local tTempData = CareerSystem.clientOthersModuleData
    tTempData = tTempData[nModuleId] or {}
    tDetailedData = tTempData and tTempData[_nShowUserId]
  end
  return tDetailedData
end
function CareerSystem.FormatDecimalNum(nValue, nNum, bIsUp)
  local dataNum = nValue
  nNum = nNum or 1
  local fFun = math.floor
  if bIsUp then
    fFun = math.ceil
  end
  if nNum == 1 then
    dataNum = fFun(dataNum * 10) / 10
  elseif nNum == 2 then
    dataNum = fFun(dataNum * 100) / 100
  end
  local fmt = "%." .. nNum .. "f"
  return string.format(fmt, dataNum)
end
function CareerSystem.GetMedalCount()
  local tAllModuleType = CareerSystem.GetShowModule() or {}
  local nMedal1Count = 0
  local nMedal2Count = 0
  local nMedal3Count = 0
  local nTotalMedalCount = 0
  for _, v in pairs(tAllModuleType) do
    local tData = CareerSystem.GetModuleSummaryData(v)
    local tMedalData = tData and tData.tMedalCount
    local nCount1 = tMedalData and tMedalData[1] or 0
    local nCount2 = tMedalData and tMedalData[2] or 0
    local nCount3 = tMedalData and tMedalData[3] or 0
    nMedal1Count = nMedal1Count + nCount1
    nMedal2Count = nMedal2Count + nCount2
    nMedal3Count = nMedal3Count + nCount3
    nTotalMedalCount = nTotalMedalCount + nCount1 + nCount2 + nCount3
  end
  return nMedal1Count, nMedal2Count, nMedal3Count, nTotalMedalCount
end
function CareerSystem.GetMainShareData()
  local shareBaseData = {}
  local nMedal1Count, nMedal2Count, nMedal3Count, nTotalMedalCount = CareerSystem.GetMedalCount()
  shareBaseData.  shareBaseData.  shareBaseData.  shareBaseData.  local nTotalProValue = CareerSystem.GetCareerTotalPro()
  local nCareerLevel = CareerSystem.GetCareerLevel()
  local nProgressNum = 0
  local nextLevelPro = 0
  local curLevelPro = 0
  if not CareerSystem.IsMaxLevel(nCareerLevel) then
    nextLevelPro = CDataTable.GetTableData("CareerLevelConfig", nCareerLevel + 1).ExpTotal
    curLevelPro = CDataTable.GetTableData("CareerLevelConfig", nCareerLevel).ExpTotal
    nProgressNum = (nTotalProValue - curLevelPro) / (nextLevelPro - curLevelPro)
  else
    nProgressNum = 1
  end
  shareBaseData.  shareBaseData.  shareBaseData.  local tWeaponData = CareerSystem.GetModuleSummaryData(E_CareerModule.Weapon)
  local tModeData = CareerSystem.GetModuleSummaryData(E_CareerModule.Mode)
  local tVehicleData = CareerSystem.GetModuleSummaryData(E_CareerModule.Vehicle)
  shareBaseData.  shareBaseData.  shareBaseData.  return shareBaseData
end
function CareerSystem.GetPlayerWearData()
  local Career_Utils = require("client.slua.logic.career.career_utils")
  if CareerSystem.IsSelfCareer() then
    local tRoleWear = AvatarData.GetRoleWear()
    return Career_Utils:GetEquipData(tRoleWear, AvatarData.GetHeadID(), AvatarData.GetHairID())
  else
    local BasicDataAvatarWearInfo = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataAvatarWearInfo)
    local tRoleInfoData = BasicDataAvatarWearInfo:GetCacheData(_nShowUserId)
    local tData = {}
    for _, v in pairs(tRoleInfoData.wear) do
      if v ~= 0 then
        table.insert(tData, v)
      end
    end
    return tData
  end
end
function CareerSystem.GetPlayerGenderData()
  if CareerSystem.IsSelfCareer() then
    return DataMgr.roleData.gender
  else
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    return logic_profile:GetRoleSexByUid(_nShowUserId)
  end
end
function CareerSystem.GetPlayerNick()
  if CareerSystem.IsSelfCareer() then
    return DataMgr.roleData.nickName
  else
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    return logic_profile:GetFriendNickName(_nShowUserId)
  end
end
function CareerSystem.GetAvatarShowData()
  local Logic_CareerEdit = require("client.slua.logic.career.logic_careerEdit")
  local tShowAvatarData = {
    wear = CareerSystem.GetPlayerWearData(),
    gender = CareerSystem.GetPlayerGenderData(),
    banner = Logic_CareerEdit:GetEquippedEditItem(),
    medal = Logic_CareerEdit:GetAllEquippedMedalsItemId(),
    TextData = {
      Score = CareerSystem.GetCareerTotalPro(),
      UserName = CareerSystem.GetPlayerNick()
    },
    Transform = {
      Location = FVector(-840, 920, -5615),
      Rotation = FVector(0, 90, 0),
      Scale = FVector(0.3, 0.3, 0.3)
    }
  }
  return tShowAvatarData
end
function CareerSystem.CacheCurrentUid()
  CareerSystem.jumpCacheUID = _nShowUserId
end
function CareerSystem.ShowGotTip(nBaseTab, nSubTab, nItemId)
  if not CareerSystem.IsOpen() then
    return
  end
  local sContentTip = ""
  if nBaseTab == E_EditBaseTabType.Medals then
    sContentTip = LocUtil.GetLocalizeResStr(33621)
  elseif nBaseTab == E_EditBaseTabType.Personalize then
    if nSubTab == E_PersonalizeType.Frame then
      sContentTip = LocUtil.GetLocalizeResStr(33622)
    elseif nSubTab == E_PersonalizeType.Posture then
      sContentTip = LocUtil.GetLocalizeResStr(33623)
    elseif nSubTab == E_PersonalizeType.Material then
      sContentTip = LocUtil.GetLocalizeResStr(33624)
    end
  end
  if not _tGotTipCallbackHandle then
    _tGotTipCallbackHandle = {
      checkJump = function()
        local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
        return not RoleInfoMainSystem.IsShow()
      end,
      callback = function()
        local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
        RoleInfoMainSystem.Show(RoleInfoMainSystem.Career, nil, DataMgr.roleData.uid)
      end
    }
  end
  local UIUtil = require("client.common.ui_util")
  local path = UIUtil.GetItemBigIcon(nItemId)
  local RightPopSystem = require("client.slua.logic.lobby_popui.logic_right_popup")
  local ConfigTab = {}
  RightPopSystem.CommonPopup(ConfigTab, nil, sContentTip, path, _tGotTipCallbackHandle, 5)
end
return CareerSystem