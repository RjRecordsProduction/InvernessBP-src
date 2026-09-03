local data_config_marco = require("client.logic.data.data_config_marco")
local logic_season_shop_system = {}
local C_CasualSeasonConfig = data_config_marco.casual_season_shop_table
function logic_season_shop_system:OnInitialize()
  self.seasonShopConfig = {}
  self.seasonExchangeParams = {}
  self.seasonExchangeInfo = {}
  self.seasonCasualExchangeInfo = {}
  self.seasonCasualPermanentExchangeInfo = {}
  self.seasonCasualSeasonItemsExchangeInfo = {}
  self.seasonShopShowConfig = {}
  self.seasonCasualConfig = {}
end
function logic_season_shop_system:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_SEASON_AWARD_MAIN, self.OnJumpHandler, self)
end
function logic_season_shop_system:OnJumpHandler(_, _, jumpData)
  log(bWriteLog and "logic_season_award:OnJumpHandler")
  local SeasonVerCfg = CDataTable.GetTableData("SeasonVersion", DataMgr.season_id)
  local version_util = require("client.common.version_util")
  local _clientVersion3 = version_util.GetClientFormat(Client.GetAppVersion())
  if not SeasonVerCfg then
    ShowNotice(9409)
    return
  end
  log(bWriteLog and string.format("logic_season_shop_system:OnJumpHandler curVersion=%s, seasonMinVersion=%s", _clientVersion3, SeasonVerCfg.MinVersion))
  if SeasonVerCfg and version_util.CompareVersionStandard(_clientVersion3, SeasonVerCfg.MinVersion) < 0 then
    ShowNotice(9409)
    return
  end
  local LogicPeakGameUtil = require("client.logic.PeakGame.LogicPeakGameUtil")
  local tab = 2
  if jumpData and jumpData.tab then
    tab = tonumber(jumpData.tab)
    if tab == 3 then
      tab = LogicPeakGameUtil.IsOpen() and 3 or 2
    end
  end
  UIManager.ShowUI(UIManager.UI_Config.SeasonAwardMain_UIBP, tab, jumpData)
end
function logic_season_shop_system:GetSeasonShopConfig()
  return self.seasonShopConfig
end
function logic_season_shop_system:GetSeasonExchangeParams()
  return self.seasonExchangeParams
end
function logic_season_shop_system:GetShopExchangeInfo()
  log(bWriteLog and "logic_season_shop_system:GetShopExchangeInfo")
  log_tree("logic_season_shop_system:GetShopExchangeInfo self.seasonExchangeInfo = ", self.seasonExchangeInfo)
  return self.seasonExchangeInfo
end
function logic_season_shop_system:GetCasualShopExchangeInfo()
  log(bWriteLog and "logic_season_shop_system:GetCasualShopExchangeInfo")
  log_tree("logic_season_shop_system:GetCasualShopExchangeInfo self.seasonCasualExchangeInfo = ", self.seasonCasualExchangeInfo)
  log_tree("logic_season_shop_system:GetCasualShopExchangeInfo self.seasonCasualPermanentExchangeInfo = ", self.seasonCasualPermanentExchangeInfo)
  log_tree("logic_season_shop_system:GetCasualShopExchangeInfo self.seasonCasualSeasonItemsExchangeInfo = ", self.seasonCasualSeasonItemsExchangeInfo)
  return self.seasonCasualExchangeInfo, self.seasonCasualPermanentExchangeInfo, self.seasonCasualSeasonItemsExchangeInfo
end
function logic_season_shop_system:GetMinPrice()
  local minPrice
  for _, v in pairs(self.seasonShopConfig) do
    if minPrice == nil then
      minPrice = v.exchange_need_cnt
    end
    if minPrice > v.exchange_need_cnt then
      minPrice = v.exchange_need_cnt
    end
  end
  log(bWriteLog and "logic_season_shop_system:GetMinPrice() minPrice = " .. tostring(minPrice))
  return minPrice or 1
end
function logic_season_shop_system:GetSeasonCasualShopConfig()
  return self.seasonCasualConfig
end
function logic_season_shop_system:GetJumpUrl(resID)
  if resID == nil then
    log(bWriteLog and "GetJumpUrl resID is nil")
    return nil, true
  end
  if type(resID) ~= "number" then
    log(bWriteLog and "GetJumpUrl resID's type is not number, type(resID) = " .. tostring(type(resID)))
    return nil, true
  end
  log(bWriteLog and "GetJumpUrl resID = " .. tostring(resID))
  if resID ~= 1702156 and resID ~= 4151006 and resID ~= 1125 then
    return nil, true
  end
  log(bWriteLog and "GetJumpUrl DataMgr.season_id = " .. tostring(DataMgr.season_id))
  if DataMgr.season_id <= 23 then
    return nil, true
  end
  if not LobbySystem.CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_SEASON) then
    return nil, false
  end
  local SeasonVerCfg = CDataTable.GetTableData("SeasonVersion", DataMgr.season_id)
  local version_util = require("client.common.version_util")
  local _clientVersion = version_util.GetClientFormat(Client.GetAppVersion())
  if SeasonVerCfg and version_util.CompareVersionStandard(_clientVersion, SeasonVerCfg.MinVersion) < 0 then
    log(bWriteLog and string.format("GetJumpUrl _clientVersion:%s, SeasonVerCfg.MinVersion:%s", _clientVersion, SeasonVerCfg.MinVersion))
    ShowNotice(9409)
    return nil, false
  end
  if resID == 1125 then
    local jumpConfig = CDataTable.GetTableData("JumpExchangeUrlConfig", resID)
    if jumpConfig and jumpConfig.JumpExchangeUrl and jumpConfig.JumpExchangeUrl ~= "" then
      return jumpConfig.JumpExchangeUrl, true
    end
  end
  return "game://?module=1000891&tab=4", true
end
function logic_season_shop_system:ReSortSeasonShopConfig()
  if not next(self.seasonShopShowConfig) then
    log(bWriteLog and "logic_season_shop_system:ReSortSeasonShopConfig no shop config")
    return
  end
  local sortFunc = function(a, b)
    if a.sortFlag ~= b.sortFlag then
      return a.sortFlag < b.sortFlag
    elseif a.serial_no ~= b.serial_no then
      return a.serial_no > b.serial_no
    else
      return false
    end
  end
  local currSeason = DataMgr.season_id
  log(bWriteLog and "logic_season_shop_system:ReSortSeasonShopConfig currSeason = " .. tostring(currSeason))
  for seasonType, datas in pairs(self.seasonShopShowConfig) do
    self.seasonShopShowConfig[seasonType].Current = {}
    self.seasonShopShowConfig[seasonType].Past = {}
    if next(self.seasonShopShowConfig[seasonType].All) then
      for _, value in pairs(self.seasonShopShowConfig[seasonType].All) do
        if currSeason <= tonumber(value.season_id) then
          table.insert(self.seasonShopShowConfig[seasonType].Current, value)
        else
          table.insert(self.seasonShopShowConfig[seasonType].Past, value)
        end
      end
      table.sort(self.seasonShopShowConfig[seasonType].Current, sortFunc)
      table.sort(self.seasonShopShowConfig[seasonType].Past, sortFunc)
      table.sort(self.seasonShopShowConfig[seasonType].All, sortFunc)
    end
  end
end
function logic_season_shop_system:OnGetSeasonShopConfig(season_coin_exchange_shop_conf, season_exchange_params_conf)
  log(bWriteLog and "logic_season_shop_system:OnGetSeasonShopConfig")
  self.seasonShopConfig = season_coin_exchange_shop_conf or {}
  self.seasonExchangeParams = season_exchange_params_conf
end
function logic_season_shop_system:OnGetCasualSeasonShopConfig(season_coin_exchange_shop_conf)
  log(bWriteLog and "logic_season_shop_system:OnGetCasualSeasonShopConfig")
  self.seasonCasualConfig = season_coin_exchange_shop_conf or {}
end
function logic_season_shop_system:ReqCasualSeasonShopConfig()
  log(bWriteLog and "logic_season_shop_system:ReqCasualSeasonShopConfig")
  local logic_leisure_season = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_leisure_season)
  if not logic_leisure_season:IsLeisureSeasonOpen() then
    log(bWriteLog and "logic_season_shop_system:ReqCasualSeasonShopConfig not open")
    return
  end
  local on_req = function(table_name, table_data)
    log(bWriteLog and "logic_season_shop_system:ReqCasualSeasonShopConfig callback")
    if table_name ~= C_CasualSeasonConfig or not table_data then
      return
    end
    log_tree("logic_season_shop_system:ReqCasualSeasonShopConfig casual_season_shop_table", table_data)
    self:OnGetCasualSeasonShopConfig(table_data)
    local logic_season_const = require("client.logic.season.logic_season_const")
    EventSystem:postEvent(EVENTTYPE_SEASON_CONFIG, EVENTID_GET_SHOP_CONFIG, logic_season_const.ESeasonType.Casual)
  end
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  BasicDataServerTable:GetOrReqData(C_CasualSeasonConfig, on_req)
end
function logic_season_shop_system:OnGetShopExchangeInfo(coin_exchange_info)
  log(bWriteLog and "logic_season_shop_system:OnGetShopExchangeInfo")
  self.seasonExchangeInfo = coin_exchange_info or {}
  EventSystem:postEvent(EVENTTYPE_SEASON_CONFIG, EVENTID_EXCHANGE_NUM_CHANGE)
end
function logic_season_shop_system:OnGetCasualShopExchangeInfo(coin_exchange_info, permanent_items, season_items)
  log(bWriteLog and "logic_season_shop_system:OnGetCasualShopExchangeInfo")
  self.seasonCasualExchangeInfo = coin_exchange_info or {}
  self.seasonCasualPermanentExchangeInfo = permanent_items or {}
  self.seasonCasualSeasonItemsExchangeInfo = season_items or {}
  EventSystem:postEvent(EVENTTYPE_SEASON_CONFIG, EVENTID_EXCHANGE_NUM_CHANGE)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, logic_season_shop_system)
return CModuleTemplate