local store_supply_manager = {}
function store_supply_manager:OnLogin(bReLogin)
  if bReLogin then
    self:InitializationOfMandatoryData(bReLogin)
  end
end
function store_supply_manager:OnLogOut()
  self:ResetData()
end
function store_supply_manager:GetBackToSupplyDrawStats()
  return StoreConst.Back_Supply_Draw_Status
end
function store_supply_manager:SetBackToSupplyDrawStats(Value)
  StoreConst.Back_Supply_Draw_Status = Value
end
function store_supply_manager:OnPostSwitchGameStatus(preState, nextState)
  if nextState == GameStatus.Lobby then
    self:InitializationOfMandatoryData()
  end
end
function store_supply_manager:InitializationOfMandatoryData(bReLogin)
  local store_limit_buy_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_limit_buy_manager)
  store_limit_buy_manager:ReqLimitBuyInfo()
  local store_collect_data = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_collect_data)
  store_collect_data:ReceivedCollectionData(LobbySystem.roleData.market_collect_data)
  local supply_ban_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.supply_ban_manager)
  supply_ban_manager:RequestServerTableConfig()
  store_collect_data:ReadNeedRedPointTabData()
  self.bGetTabList = false
  self.bRefreshSupplyBannerList = true
end
function store_supply_manager:ReqTabListData(isBriefInfo)
  StoreConst.req_status.shop_received = false
  StoreConst.req_status.market_received = false
  self.bGetTabList = false
  self.bRefreshSupplyBannerList = true
  local StoreHandler = require("client.network.Protocol.StoreHandler")
  if isBriefInfo then
    self:ReqOptimizeSupplyInfo()
  else
    StoreHandler.send_get_shop_flowlight_req()
    StoreHandler.send_get_shop_tab_list_req()
  end
  StoreHandler.send_get_market_tab_list_req()
  local store_supply_switcher = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_supply_switcher)
  local GiveStore = store_supply_switcher:GetGiveStore()
  if GiveStore then
    self:GetTabData(StoreConst.store_tab, StoreConst.Page_New_ID_Give)
  end
end
function store_supply_manager:ResetData(onlyResetStoreData)
  StoreConst.store_data = {}
  StoreConst.supply_data = {}
  StoreConst.give_data = {}
  local supply_ban_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.supply_ban_manager)
  supply_ban_manager:ClearBanData()
  local treasure_chest_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.treasure_chest_manager)
  treasure_chest_manager:ClearChestInfo()
  local supply_credit_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.supply_credit_manager)
  supply_credit_manager:ClearCreditData()
  StoreConst.directPurchaseSrc = StoreConst.direct_purchase_source_buy
  self.hasSupplySubTab = nil
  StoreConst.haveShowedStoreEmotion = {}
  local LogicSupplyUcAgLimit = require("client.slua.logic.supply.logic_supply_uc_ag_limit")
  LogicSupplyUcAgLimit.ClearAGLimitData()
  local StoreRecommendData = require("client.slua.logic.store.store_recommend_data")
  StoreRecommendData.ClearRecommendData()
  local StoreSubscriptData = require("client.slua.logic.store.store_subscript_data")
  StoreSubscriptData.ClearSubscriptData()
  local moneyComponentSystem = require("client.slua.logic.store.logic_money_component")
  moneyComponentSystem.ClearStoreCurrencyData()
end
function store_supply_manager:ProcessVersion(tab, version)
  log(bWriteLog and string.format("store_supply_manager:ProcessVersion tab = %s, version = %s", tab, version))
  log(bWriteLog and string.format("store_supply_manager:ProcessVersion StoreConst.store_version = %s", StoreConst.store_version))
  local ResetDataWithVersion = function(tabType, _version, needReqData)
    log(bWriteLog and string.format("store_supply_manager:ProcessVersion ResetDataWithVersion tabType = %s, _version = %s, needReqData = %s", tabType, _version, needReqData))
    if tabType == StoreConst.store_tab then
      StoreConst.store      StoreConst.store_data = {}
    elseif tabType == StoreConst.supply_tab then
      StoreConst.supply      StoreConst.supply_data = {}
    end
    local JumpUtils = require("client.logic.store.jump_utils")
    JumpUtils.TryResetJumpMap()
    local treasure_chest_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.treasure_chest_manager)
    treasure_chest_manager:ClearChestInfo()
    local store_supply_switcher = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_supply_switcher)
    if needReqData and GameStatus.IsInLobbyOrMainCity() and store_supply_switcher:IsInStoreSupplySystem() then
      self:ReqTabListData()
    end
  end
  if tab == StoreConst.store_tab and StoreConst.store_version ~= version then
    ResetDataWithVersion(StoreConst.store_tab, version, StoreConst.store_version ~= 0)
  elseif tab == StoreConst.supply_tab and StoreConst.supply_version ~= version then
    ResetDataWithVersion(StoreConst.supply_tab, version, StoreConst.supply_version ~= 0)
  end
end
function store_supply_manager:SyncVersionCheck(version, show_market_red)
  log_tree("store_supply_manager:SyncVersionCheck, version = ", version)
  log_tree("store_supply_manager:SyncVersionCheck, show_market_red = ", show_market_red)
  local store_reddot_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_reddot_manager)
  store_reddot_manager:OnRecRedDotRsp(show_market_red)
  StoreConst.store_version = version[1] or 0
  StoreConst.supply_version = version[2] or 0
  StoreConst.store_data = {}
  StoreConst.supply_data = {}
  StoreConst.give_data = {}
  self.optimizeSupplyInfo = nil
  local TimeUtil = require("client.common.time_util")
  self.resetStoreSupplyTime = TimeUtil.GetServerTimeInSec()
  local supply_ban_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.supply_ban_manager)
  supply_ban_manager:ClearBanData()
  local treasure_chest_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.treasure_chest_manager)
  treasure_chest_manager:ClearChestInfo()
  self.hasSupplySubTab = nil
  local JumpUtils = require("client.logic.store.jump_utils")
  JumpUtils.TryResetJumpMap()
  local StoreRecommendData = require("client.slua.logic.store.store_recommend_data")
  StoreRecommendData.ClearRecommendData()
  local StoreSubscriptData = require("client.slua.logic.store.store_subscript_data")
  StoreSubscriptData.ClearSubscriptData()
  if GameStatus.IsInLobbyOrMainCity() then
    EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_REQ_RECOMMEND_DATA)
    log(bWriteLog and "store_supply_manager:SyncVersionCheck RequestJumpMapInfo")
    JumpUtils.RequestJumpMapInfo(true)
    self:ReqTabListData()
    local store_limit_buy_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_limit_buy_manager)
    store_limit_buy_manager:ReqLimitBuyInfo()
    local async = require("client.common.async")
    async.Run(function(co)
      async.AwaitEvent(co, nil, EVENTTYPE_MALL, EVENTID_MALL_GET_ALL_SIMPLE_INFO)
      EventSystem:postEvent(EVENTTYPE_SUPPLY, EVENTID_SUPPLY_REFRESH_TAB_REDDOT)
    end)
    local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
    if LogicTxMissionMain.IsInXMission(true) then
      do
        local LogicXMissionBlackMarket = require("client.slua.logic.TxMission.logic_xmission_black_market")
        LogicXMissionBlackMarket.tabInfo = {}
        LogicXMissionBlackMarket.tabList = {}
        LogicXMissionBlackMarket.subTabList = {}
        LogicXMissionBlackMarket.requestChest = {}
        LogicXMissionBlackMarket.chestInfo = {}
        LogicXMissionBlackMarket.GetTabList()
      end
    end
  end
  local LuckyBackGuideCtrl = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LuckyBackGuideCtrl)
  if LuckyBackGuideCtrl:GetLuckyBackGuide() then
    LuckyBackGuideCtrl:CanShowNextTip()
  end
end
function store_supply_manager:GetTabList(tab_type)
  log(bWriteLog and string.format("store_supply_manager:GetTabList tab_type = %s", tab_type))
  if tab_type == StoreConst.supply_tab then
    if StoreConst.supply_data.supply_list ~= nil then
      log(bWriteLog and "have data and return immediately.")
      local data = {}
      data.tab_type = StoreConst.supply_tab
      data.data = StoreConst.supply_data.supply_list
      EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_SUPPLY_LIST, data)
    else
      local StoreHandler = require("client.network.Protocol.StoreHandler")
      StoreHandler.send_get_shop_flowlight_req()
      StoreHandler.send_get_shop_tab_list_req()
    end
  elseif StoreConst.store_data.store_list ~= nil then
    log(bWriteLog and "have data and return immediately.")
    local data = {}
    data.tab_type = StoreConst.store_tab
    data.data = StoreConst.store_data.store_list
    EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_LIST, data)
  else
    local StoreHandler = require("client.network.Protocol.StoreHandler")
    StoreHandler.send_get_market_tab_list_req()
  end
end
function store_supply_manager:ResponseSupplyTabList(supply_version, supply_list, lucky_strategy_table, frame_style_conf)
  log(bWriteLog and string.format("store_supply_manager:ResponseSupplyTabList supply_version = %s", supply_version))
  log_tree("supply_list", supply_list)
  self:ProcessVersion(StoreConst.supply_tab, supply_version, lucky_strategy_table)
  StoreConst.supply_data.supply_list = supply_list or {}
  StoreConst.supply_data.lucky_strategy_table = lucky_strategy_table or {}
  StoreConst.supply_data.frame_style_conf = frame_style_conf or {}
  local data = {}
  data.tab_type = StoreConst.supply_tab
  data.data = StoreConst.supply_data.supply_list
  EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_SUPPLY_LIST, data)
  EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_CRATE_COLLECT_NOTIFY)
  if StoreConst.req_status.shop_received == false then
    StoreConst.req_status.shop_received = true
    self:RefreshReddot()
  end
end
function store_supply_manager:ResponseStoreTabList(store_version, store_list)
  log(bWriteLog and string.format("store_supply_manager:ResponseStoreTabList store_version = %s", store_version))
  log_tree("xcc store_supply_manager:ResponseStoreTabList store_list", store_list)
  self:ProcessVersion(StoreConst.store_tab, store_version)
  StoreConst.store_data.  local data = {}
  data.tab_type = StoreConst.store_tab
  data.data = StoreConst.store_data.store_list
  self:CheckRemovePrimeTab()
  local store_reddot_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_reddot_manager)
  store_reddot_manager:ConstructStoreRedDot()
  EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_LIST, data)
  if StoreConst.req_status.market_received == false then
    StoreConst.req_status.market_received = true
    self:RefreshReddot()
  end
end
function store_supply_manager:GetStoreAndSupplyTabList()
  log(bWriteLog and "store_supply_manager:GetStoreAndSupplyTabList self.bGetTabList = " .. tostring(self.bGetTabList))
  if self.bGetTabList then
    self:RefreshSupplyBannerList()
    return
  end
  self.bGetTabList = true
  self:ReqTabListData(true)
  self:RefreshSupplyBannerList()
end
function store_supply_manager:RefreshSupplyBannerListTag()
  self.bRefreshSupplyBannerList = true
  self:RefreshSupplyBannerList()
end
function store_supply_manager:RefreshSupplyBannerList()
  log(bWriteLog and "store_supply_manager:RefreshSupplyBannerList self.bRefreshSupplyBannerList = " .. tostring(self.bRefreshSupplyBannerList))
  if not self.bRefreshSupplyBannerList then
    return
  end
  self.bRefreshSupplyBannerList = false
  local store_reddot_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_reddot_manager)
  store_reddot_manager:OnInitSupplyBanner()
  local data = {}
  data.tab_type = StoreConst.supply_tab
  data.data = StoreConst.supply_data.supply_list
  EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_SUPPLY_LIST, data)
  if StoreConst.req_status.shop_received == false then
    StoreConst.req_status.shop_received = true
    self:RefreshReddot()
  end
end
function store_supply_manager:CheckRemovePrimeTab()
  local logic_subscribe_handler = require("client.slua.logic.subscribe.logic_subscribe_handler")
  local subscribeModuleObj = logic_subscribe_handler.GetSubscribeModuleObj()
  local isPrimeOpen = subscribeModuleObj:GetIsPrimeOpen()
  if isPrimeOpen then
    log(bWriteLog and string.format("store_supply_manager:CheckRemovePrimeTab isPrimeOpen is true."))
    return
  end
  for k, v in pairs(StoreConst.store_data.store_list) do
    if v[StoreConst.label_market_index_id] == StoreConst.Page_ID_Prime then
      StoreConst.store_data.store_list[k] = nil
      break
    elseif v[StoreConst.label_market_index_id] == StoreConst.Page_New_ID_Exchange then
      if v[StoreConst.label_market_index_sub_list] then
        v[StoreConst.label_market_index_sub_list][StoreConst.subtype_new_exchange_bps] = nil
      end
      break
    end
  end
end
function store_supply_manager:RemoveTabDataByTab(tabId, subTabId)
  if StoreConst.store_data == nil or StoreConst.store_data.store_list == nil then
    return
  end
  local tabData = StoreConst.store_data.store_list
  for i, v in pairs(tabData) do
    if tabId == i then
      if v[StoreConst.label_market_index_sub_list] then
        v[StoreConst.label_market_index_sub_list][subTabId] = nil
      end
      break
    end
  end
  local data = {}
  data.tab_type = StoreConst.store_tab
  data.data = StoreConst.store_data.store_list
  EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_LIST, data)
end
function store_supply_manager:GetSupplyTabList()
  if StoreConst.supply_data then
    return StoreConst.supply_data.supply_list or {}
  end
  return {}
end
function store_supply_manager:GetStoreTabList()
  if StoreConst.store_data then
    return StoreConst.store_data.store_list or {}
  end
  return {}
end
function store_supply_manager:ReqOptimizeSupplyInfo()
  if self.optimizeSupplyInfo then
    log(bWriteLog and string.format("store_supply_manager:ReqOptimizeSupplyInfo Data already exists."))
    return
  end
  local StoreHandler = require("client.network.Protocol.StoreHandler")
  StoreHandler.send_get_shop_flowlight_req()
end
function store_supply_manager:RspOptimizeSupplyInfo(supply_new_tag, supply_infos)
  self.supplyNewTag = supply_new_tag
  self.optimizeSupplyInfo = supply_infos or {}
  local store_reddot_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_reddot_manager)
  store_reddot_manager:ConstructSupplyRedDot()
end
function store_supply_manager:IsSupplyNewTag()
  return self.supplyNewTag
end
function store_supply_manager:GetOptimizeSupplyInfo()
  return self.optimizeSupplyInfo or {}
end
function store_supply_manager:GetTabData(tab_type, tab_id, is_ams_chest, give_tab)
  log(bWriteLog and string.format("store_supply_manager:GetTabData tab_type = %s, tab_id = %s, is_ams_chest = %s, give_tab = %s", tab_type, tab_id, is_ams_chest, give_tab))
  if tab_type == StoreConst.supply_tab then
    if StoreConst.supply_data[tab_id] ~= nil then
      log(bWriteLog and "have data and return immediately.")
      local data = {}
      data.tab_type = StoreConst.supply_tab
      data.      data.data = StoreConst.supply_data[tab_id]
      EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_SUPPLY_DATA, data)
    else
      local StoreHandler = require("client.network.Protocol.StoreHandler")
      StoreHandler.send_get_shop_info_req(tab_id, 0, is_ams_chest)
    end
  elseif give_tab == true and tab_id ~= StoreConst.Page_New_ID_Give then
    log(bWriteLog and "have data and return immediately.11111")
    local data = {}
    data.tab_type = StoreConst.give_tab
    data.    data.data = StoreConst.give_data[tab_id]
    EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_DATA, data)
  elseif StoreConst.store_data[tab_id] ~= nil then
    log(bWriteLog and "have data and return immediately.22222")
    local data = {}
    data.    data.    data.data = StoreConst.store_data[tab_id]
    self:FilterExpiredItemForVoiceExchange(tab_id, data.data)
    EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_DATA, data)
  else
    local StoreHandler = require("client.network.Protocol.StoreHandler")
    StoreHandler.send_get_market_info_req(tab_id, 0)
  end
end
function store_supply_manager:ResponseSupplyData(supply_version, info, shop_wish_info)
  log(bWriteLog and string.format("store_supply_manager:ResponseSupplyData supply_version = %s", supply_version))
  self:ProcessVersion(StoreConst.supply_tab, supply_version)
  if not info or next(info) == nil or info[StoreConst.label_shop_index_id_box] == nil then
    log(bWriteLog and "get_market_info_rsp, Can't believe it!")
    return
  end
  local tab_id = info[StoreConst.label_shop_index_id_box]
  StoreConst.supply_data[tab_id] = info
  local data = {}
  data.tab_type = StoreConst.supply_tab
  data.  data.data = info
  data.data.wish_info = shop_wish_info or {}
  EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_SUPPLY_DATA, data)
end
function store_supply_manager:ResponseStoreData(store_version, info, back_user_buy_info, material_limit_info, rpPlusLimitInfo)
  log(bWriteLog and string.format("store_supply_manager:ResponseStoreData store_version = %s", store_version))
  self:ProcessVersion(StoreConst.store_tab, store_version)
  if not info or next(info) == nil or info[StoreConst.label_market_index_id] == nil then
    log(bWriteLog and "get_market_info_rsp, Can't believe it!")
    return
  end
  local tab_id = info[StoreConst.label_market_index_id]
  log(bWriteLog and string.format("store_supply_manager:ResponseStoreData tab_id = %d", tab_id))
  StoreConst.store_data[tab_id] = info
  local store_limit_buy_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_limit_buy_manager)
  if tab_id == StoreConst.Page_New_ID_Recommend then
    store_limit_buy_manager:CheckRequireSpecialLimitInfo()
  end
  self:FilterExpiredItemForVoiceExchange(tab_id, info)
  local data = {}
  data.tab_type = StoreConst.store_tab
  data.  data.data = info
  local StoreSubscriptData = require("client.slua.logic.store.store_subscript_data")
  StoreSubscriptData.SetSubscriptData(info)
  store_limit_buy_manager:SetOtherLimitInfo(back_user_buy_info, material_limit_info, rpPlusLimitInfo)
  EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_DATA, data)
end
function store_supply_manager:SetGiveTabList(tabId, subTabId, tabList)
  if not (StoreConst.store_data and StoreConst.store_data.store_list) or StoreConst.store_data.store_list[tabId] == nil then
    log(bWriteLog and "FilterTabListForGiveSystem, no info with subTabId = " .. tostring(subTabId) .. "  tabId = " .. tostring(tabId))
    return
  end
  local TableUtil = require("common.table_util")
  if tabList[tabId] == nil then
    tabList[tabId] = TableUtil.CopyTable(StoreConst.store_data.store_list[tabId])
    tabList[tabId][StoreConst.label_market_index_sub_list] = {}
  end
  if StoreConst.store_data.store_list[tabId][StoreConst.label_market_index_sub_list][subTabId] ~= nil and tabList[tabId][StoreConst.label_market_index_sub_list][subTabId] == nil then
    tabList[tabId][StoreConst.label_market_index_sub_list][subTabId] = TableUtil.CopyTable(StoreConst.store_data.store_list[tabId][StoreConst.label_market_index_sub_list][subTabId])
  end
end
function store_supply_manager:SetGiveTabData(tabId, subTabId, tabData, k, v)
  if tabData[tabId] == nil then
    if StoreConst.store_data[tabId] ~= nil then
      local TableUtil = require("common.table_util")
      tabData[tabId] = TableUtil.CopyTable(StoreConst.store_data[tabId])
      tabData[tabId][StoreConst.label_market_index_market_list] = {}
    else
      tabData[tabId] = {}
      tabData[tabId][StoreConst.label_market_index_id] = tabId
      tabData[tabId][StoreConst.label_market_index_sub_id] = subTabId
      tabData[tabId][StoreConst.label_market_index_market_list] = {}
      tabData[tabId][StoreConst.label_market_index_banner_list] = {}
    end
  end
  tabData[tabId][StoreConst.label_market_index_market_list][k] = v
end
function store_supply_manager:FilterTabListForGiveSystem(param)
  local StoreUtils = require("client.slua.logic.store.utils.store_utils")
  if StoreConst.give_data.give_list ~= nil then
    log(bWriteLog and "FilterTabListForGiveSystem, have data and return immediately.")
    local data = {}
    data.tab_type = StoreConst.give_tab
    data.data = StoreConst.give_data.give_list
    return data
  else
    local tabList = {}
    local tabData = {}
    for k, v in pairs(param.data[StoreConst.label_market_index_market_list]) do
      local subTabId = v[StoreConst.label_item_index_page_id]
      if subTabId ~= nil and subTabId ~= StoreConst.subtype_new_recommend_rec then
        local tabId = math.modf(subTabId / 100)
        if subTabId == 4001 then
          v[StoreConst.label_item_index_page_id] = StoreUtils.GetTreasureSubTab()
          subTabId = StoreUtils.GetTreasureSubTab()
          tabId = StoreUtils.GetDirectBuyTab()
          log(bWriteLog and "FilterTabListForGiveSystem, subTabId = 4001" .. "  shopID = " .. tostring(k))
        end
        self:SetGiveTabList(tabId, subTabId, tabList)
        self:SetGiveTabData(tabId, subTabId, tabData, k, v)
      end
    end
    StoreConst.give_data = tabData
    StoreConst.give_data.give_list = tabList
    local data = {}
    data.tab_type = StoreConst.give_tab
    data.data = StoreConst.give_data.give_list
    return data
  end
end
function store_supply_manager:RefreshReddot()
  log(bWriteLog and "[YY]store_supply_manager:RefreshReddot===\229\149\134\229\159\142\229\136\151\232\161\168====" .. tostring(StoreConst.req_status.market_received))
  log(bWriteLog and "[YY]store_supply_manager:RefreshReddot===\232\161\165\231\187\153\229\136\151\232\161\168====" .. tostring(StoreConst.req_status.shop_received))
  if StoreConst.req_status.market_received and StoreConst.req_status.shop_received then
    EventSystem:postEvent(EVENTTYPE_MALL, EVENTID_MALL_GET_ALL_SIMPLE_INFO)
  end
end
function store_supply_manager:ResponseDynamicPrice(change_list)
  if change_list == nil or next(change_list) == nil then
    log_error("change_list data error of market_dynamic_price_change_notify .")
    return
  end
  log_tree("[cw] StoreSystem.ResponseDynamicPrice change_list:", change_list)
  local tab_id = 0
  local shop_id = 0
  local new_market_info = {}
  for i, v in pairs(change_list) do
    tab_id = v.page_id or 0
    shop_id = v.market_id or 0
    new_market_info = v.new_market_info or {}
    self:MergeDynamicPrice(tab_id, shop_id, new_market_info)
  end
  EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_PRICE_UPDATE)
end
function store_supply_manager:MergeDynamicPrice(tab_id, shop_id, new_market_info)
  local marKey = StoreConst.label_market_index_market_list
  local priKey = StoreConst.label_item_index_price_list
  local dynKey = StoreConst.label_price_index_dynamic_adjust_price
  local newPriceList = {}
  if new_market_info then
    newPriceList = new_market_info[priKey] or {}
  end
  local itemData = {}
  if StoreConst.store_data and StoreConst.store_data[tab_id] ~= nil then
    itemData = StoreConst.store_data[tab_id][marKey] or {}
  end
  for shopId, v in pairs(itemData) do
    if shop_id and shopId == shop_id and v[priKey] then
      for idx, priInfo in pairs(v[priKey]) do
        if newPriceList[idx] and newPriceList[idx][dynKey] then
          priInfo[dynKey] = newPriceList[idx][dynKey]
        end
      end
    end
  end
end
function store_supply_manager:CanBuyDailyFreeGiftBox()
  local itemData = {}
  if StoreConst.store_data and StoreConst.store_data[StoreConst.Page_New_ID_Recommend] then
    itemData = StoreConst.store_data[StoreConst.Page_New_ID_Recommend][StoreConst.label_market_index_market_list] or {}
  else
    local store_limit_buy_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_limit_buy_manager)
    store_limit_buy_manager:ReqLimitBuyInfo()
    local StoreRecommendData = require("client.slua.logic.store.store_recommend_data")
    StoreRecommendData.GetRecommendParentTabData()
  end
  local result, limitTimes, curTimes = nil, 0, 0
  for shopID, data in pairs(itemData) do
    if data[StoreConst.label_item_index_zero_uc_mark] == 1 then
      local limitData = data[StoreConst.label_item_index_buy_limit] or {}
      limitTimes = limitData[StoreConst.label_buy_limit_type_daily] or 0
      result = shopID
      break
    end
  end
  local StoreUtils = require("client.slua.logic.store.utils.store_utils")
  local buyInfo = StoreUtils.GetBuyInfo(result)
  if result and buyInfo then
    curTimes = buyInfo.daily_buy_cnt or 0
  end
  return limitTimes > curTimes
end
function store_supply_manager:GetDelayFreeGiftItemID()
  local itemData = {}
  if StoreConst.store_data and StoreConst.store_data[StoreConst.Page_New_ID_Recommend] then
    itemData = StoreConst.store_data[StoreConst.Page_New_ID_Recommend][StoreConst.label_market_index_market_list] or {}
  end
  for _, data in pairs(itemData) do
    if data[StoreConst.label_item_index_zero_uc_mark] == 1 then
      return data[StoreConst.label_item_index_id] or 0
    end
  end
  return 0
end
function store_supply_manager:GetSupplyFrameStylePath(style)
  local path = ""
  if StoreConst.supply_data and StoreConst.supply_data.frame_style_conf then
    path = StoreConst.supply_data.frame_style_conf[style] or ""
  end
  local base_color = {
    [0] = FLinearColor(1, 1, 1, 1),
    [1] = FLinearColor(0.023, 0.013, 0.019, 1),
    [2] = FLinearColor(0.018, 0.023, 0.035, 1),
    [3] = FLinearColor(0.027, 0.046, 0.046, 1),
    [4] = FLinearColor(0.043, 0.022, 0.04, 1)
  }
  return path, base_color[style]
end
function store_supply_manager:update_shop_price_rsp_v3(shop_id, price_list)
  local supplyList = StoreConst.supply_data
  if supplyList == nil then
    return
  end
  if supplyList[shop_id] then
    supplyList[shop_id][StoreConst.label_shop_index_price_list] = price_list
  end
end
function store_supply_manager:SetSupplyHasSubMark(mark)
  self.hasSupplySubTab = mark
end
function store_supply_manager:GetSupplyHasSubMark()
  return self.hasSupplySubTab
end
function store_supply_manager:FilterExpiredItemForVoiceExchange(tabId, info)
  if tabId ~= StoreConst.Page_ID_Exchange then
    return
  end
  local subTabId = StoreConst.label_subtype_voice_chip
  local itemList = info and info[StoreConst.label_market_index_market_list]
  if not itemList then
    return
  end
  self.bHideVoiceExchangeSubTab = true
  local StoreUtils = require("client.slua.logic.store.utils.store_utils")
  local expiredKey = {}
  for itemID, item in pairs(itemList) do
    if item[StoreConst.label_item_index_page_id] == subTabId then
      local endTime = item[StoreConst.label_item_index_time_limit] or 0
      if endTime ~= 0 and 0 >= StoreUtils.GetLeftTime(endTime) then
        table.insert(expiredKey, itemID)
      else
        self.bHideVoiceExchangeSubTab = false
      end
    end
  end
  if self.bHideVoiceExchangeSubTab then
    local store_reddot_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_reddot_manager)
    store_reddot_manager:RemoveStoreRed(tabId, subTabId)
  end
  EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_SUPPLY_SWITCH_SUB_TAB_SHOW, StoreConst.Page_ID_Exchange, StoreConst.label_subtype_voice_chip, not self.bHideVoiceExchangeSubTab)
end
function store_supply_manager:NeedHideVoiceSubTab()
  return self.bHideVoiceExchangeSubTab
end
function store_supply_manager:GetCurrentFrame()
  local store_supply_switcher = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_supply_switcher)
  local type = StoreConst.store_tab
  local frame = store_supply_switcher:GetStoreSystem()
  if frame == nil then
    type = StoreConst.supply_tab
    frame = store_supply_switcher:GetSupplySystem()
    if frame == nil then
      type = StoreConst.give_tab
      frame = store_supply_switcher:GetGiveStore()
    end
  end
  log(bWriteLog and string.format("store_supply_manager:GetCurrentFrame() frame = %s, type = %s", frame, type))
  return frame, type
end
function store_supply_manager:buy_shop_by_id_req(params, isTenBuy)
  local StoreHandler = require("client.network.Protocol.StoreHandler")
  log_tree(" StoreSystem.buy_shop_by_id_req params = ", params)
  local supply_activity_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.supply_activity_manager)
  supply_activity_manager:SaveLastActData(params[1], params[15])
  StoreHandler.send_buy_shop_by_id_req(params)
end
function store_supply_manager:buy_shop_by_id_rsp(error_code, shop_id, info, wishInfo)
  log(bWriteLog and "StoreSystem.buy_shop_by_id_rsp, error_code = " .. tostring(error_code))
  log_tree("[ljw]StoreSystem.buy_shop_by_id_rsp, wishInfo", wishInfo)
  if error_code == StoreConst.error_code_success or error_code == StoreConst.error_code_success_new then
    if info and info.draw_flag == 1 then
      log(bWriteLog and "StoreSystem:OneKey Rep")
    else
      log(bWriteLog and "StoreSystem:Common Rep")
      EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_SUPPLY_BUY, shop_id, info, wishInfo)
    end
  else
    EventSystem:postEvent(EVENTTYPE_VIDEO, EVENTID_VIDEO_ENDS)
    ShowNotice(error_code)
    if error_code == StoreConst.error_code_uc_not_enough or error_code == StoreConst.error_code_uc_not_enough_new then
      EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_BUY_ITEM_NO_ENOUGH_UC)
      local CommonPayBoxMgr = require("client.slua.logic.common.Payclass.logic_common_pay_box")
      CommonPayBoxMgr.ShowUcRechargeMsg()
    elseif error_code == StoreConst.error_code_box_sold_out or error_code == StoreConst.error_code_box_sold_out_new then
      EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_BUY_ITEM_SOLD_OUT)
    elseif error_code == StoreConst.error_price_refresh then
      EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_SUPPLY_DISCOUNT_UPDATE)
    end
  end
end
function store_supply_manager:give_gift_from_market_req_v3(params, directPurchaseInfo)
  local store_direct_purchase_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_direct_purchase_manager)
  if directPurchaseInfo then
    store_direct_purchase_manager:SetDirectPurchaseInfo(directPurchaseInfo, StoreConst.direct_purchase_source_gift)
  else
    store_direct_purchase_manager:DirectPurchaseEnd()
  end
  local StoreHandler = require("client.network.Protocol.StoreHandler")
  StoreHandler.send_give_gift_from_market_req_v3(params)
  store_direct_purchase_manager:set_timeout_timer(15)
end
function store_supply_manager:GetCurrVehicleSceneType()
  return CurrVehicleSceneType
end
function store_supply_manager:SetCurrVehicleSceneType(type)
  CurrVehicleSceneType = type or StoreConst.VehicleSceneType.None
end
function store_supply_manager:notice_shop_guarantee_reward(reward_items)
  log(bWriteLog and "StoreSystem.notice_shop_guarantee_reward")
  log_tree("StoreSystem.notice_shop_guarantee_reward, reward_items = ", reward_items)
  EventSystem:postEvent(EVENTTYPE_STORE, EVENTID_STORE_NOTIFY_MIN_GUARANTEE, reward_items)
end
function store_supply_manager:receive_guarantee_reward_req(reward_items, is_pandora_chest)
  log(bWriteLog and "StoreSystem.receive_guarantee_reward_req, Send receive_guarantee_reward_req")
  log_tree("StoreSystem.receive_guarantee_reward_req, reward_items = ", reward_items)
  log(bWriteLog and "[v_wllwu]StoreSystem.receive_guarantee_reward_req is_ams_chest = " .. tostring(is_pandora_chest))
  local StoreHandler = require("client.network.Protocol.StoreHandler")
  StoreHandler.send_receive_guarantee_reward_req(reward_items, is_pandora_chest)
end
function store_supply_manager:receive_guarantee_reward_rsp(err_code, reward_items, boxName)
  log(bWriteLog and "StoreSystem.receive_guarantee_reward_rsp, err_code = " .. tostring(err_code))
  log_tree("StoreSystem.receive_guarantee_reward_rsp, reward_items = ", reward_items)
  log(bWriteLog and "StoreSystem.receive_guarantee_reward_rsp, boxName = " .. tostring(boxName))
  if err_code == 0 then
    UIManager.ShowUI(UIManager.UI_Config.new_supply_get_panel, nil, nil, nil, true)
  elseif err_code == 9911005 then
  end
end
function store_supply_manager:buy_market_by_id_req(params)
  local store_jump_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_jump_manager)
  local buySource = store_jump_manager:GetBuySource()
  if buySource then
    params[StoreConst.label_buy_param_buy_source] = buySource
  end
  local StoreHandler = require("client.network.Protocol.StoreHandler")
  StoreHandler.send_buy_market_by_id_req(params)
end
function store_supply_manager:buy_market_by_id_rsp(error_code, market_id, info)
  log(bWriteLog and "[YY]StoreSystem.buy_market_by_id_rsp, error_code = " .. tostring(error_code))
  log(bWriteLog and "[YY]StoreSystem.buy_market_by_id_rsp, market_id = " .. tostring(market_id))
  log_tree("[YY]StoreSystem.buy_market_by_id_rsp, info = ", info)
  if error_code == StoreConst.error_code_success or error_code == StoreConst.error_code_success_new then
    local tlog_commercial_cost = require("client.slua.config.tlog.tlog_commercial_cost")
    for i = 1, #info do
      local itemId = info[i][StoreConst.label_buy_rsp_item_id]
      tlog_commercial_cost.ReportCost(tlog_commercial_cost.Enum_Scene.Store, itemId)
    end
    self:CheckNeedShowCollect(market_id, info)
    EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_BUY, {market_id = market_id, info = info})
    EventSystem:postEvent(EVENTTYPE_STORE, EVENTID_STORE_SUBSCRIBE_BUY_CALLBACK)
    EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_UPDATE_EXCHANGE_COIN)
  else
    if error_code == StoreConst.error_code_uc_not_enough or error_code == StoreConst.error_code_uc_not_enough_new then
      local CommonPayBoxMgr = require("client.slua.logic.common.Payclass.logic_common_pay_box")
      CommonPayBoxMgr.ShowUcRechargeMsg()
      return
    end
    ShowNotice(error_code)
    if error_code == StoreConst.error_code_exchange_not_enough or error_code == StoreConst.error_code_exchange_not_enough_new then
      return
    end
  end
end
function store_supply_manager:give_gift_from_market_rsp_v3(error_code, askIndex)
  log(bWriteLog and "give_gift_from_market_rsp_v3: error_code = " .. error_code)
  local store_direct_purchase_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_direct_purchase_manager)
  store_direct_purchase_manager:stop_timeout_timer()
  if store_direct_purchase_manager:IsDirectPurchaseCentauriReq() and StoreConst.directPurchaseSrc == StoreConst.direct_purchase_source_gift then
    store_direct_purchase_manager:DirectPurchaseEnd()
  end
  local OnAnimEnd = function()
    local giftPacketSystem = require("client.slua.logic.store.logic_store_gift_packet")
    local sGiftName = giftPacketSystem.GetGiftName()
    local sFriendName = giftPacketSystem.GetFriendDataByKey("nickName") or ""
    local msg = string.format(DataMgr.GetMsgByID(501030), sGiftName, sFriendName)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(1, DataMgr.GetMsgByID(102012), msg, giftPacketSystem.CloseUI, nil, LocUtil.GetLocalizeResStr("110036"), nil, {
      clickCloseCallback = giftPacketSystem.CloseUI
    })
  end
  if error_code == StoreConst.error_code_success or error_code == StoreConst.error_code_success_new then
    EventSystem:postEvent(EVENTTYPE_STORE, EVENTID_PLAY_GIFT_PACKET_ANIM, OnAnimEnd)
    EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYBACK_EXCHANGE_REFRESH)
  elseif error_code == StoreConst.error_golden_suit_activity_unopen_ then
    ShowNotice(10295)
  elseif error_code == StoreConst.error_code_give_account_risk then
    ShowNotice(LocUtil.LocalizeResFormat(27743, askIndex))
  elseif error_code == StoreConst.error_code_have_car then
    ShowNotice(271622)
  elseif error_code == StoreConst.error_different_area_give then
    ShowNotice(43131)
  elseif error_code == StoreConst.error_code_msg_inappropriate then
    local title = LocUtil.GetLocalizeResStr(101001)
    local content = LocUtil.GetLocalizeResStr(44791)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, title, content)
  elseif error_code == StoreConst.gift_err_receiver_already_has_gift_item then
    ShowNotice(12060001)
  else
    ShowNotice(error_code)
  end
end
function store_supply_manager:on_notify_rc_task(rc_task_info, rc_task_cfg)
  if not rc_task_info then
    return
  end
  log_tree(bWriteLog and "[v_wllwu] StoreSystem.on_notify_rc_task ", rc_task_info)
  local level = rc_task_info.rc_task_level
  if level == 4 then
    ShowNotice(27849)
  else
    local total_minutes = 0
    local total_times = 0
    if rc_task_cfg and rc_task_cfg[level] then
      local cfg = rc_task_cfg[level]
      total_minutes = cfg.duration or 0
      total_times = cfg.times or 0
    end
    local cur_minutes = rc_task_info.duration
    local left_minutes = total_minutes - cur_minutes
    if left_minutes < 0 then
      left_minutes = 0
    end
    local tips = LocUtil.LocalizeResFormat(27848, total_minutes, total_times, left_minutes)
    ShowNotice(tips)
  end
end
function store_supply_manager:market_buy_chest_item_notify(res, itemList, tabId, tDecItem)
  if res == NetErrorCode_NONE then
    log(bWriteLog and "market_buy_chest_item_notify success " .. tostring(tabId))
    local rewardList = {}
    local tDecomposeList = {}
    if not tDecItem or not next(tDecItem) then
      itemList = self:MergeRewardList(itemList)
    end
    for nIndex, v in pairs(itemList) do
      local limitTime = v.valid_hours or 0
      if limitTime == 0 then
        local cfg = CDataTable.GetTableData("Item", v.resid)
        if cfg and cfg.ValidTimes ~= 0 then
          limitTime = cfg.ValidTimes
        else
          limitTime = 0
        end
      end
      local decItemId, decItemCount
      if tDecItem and tDecItem[nIndex] and next(tDecItem[nIndex]) then
        decItemCount = 0
        for _, tDecData in ipairs(tDecItem[nIndex]) do
          local nDecCount = 0
          decItemId, nDecCount = next(tDecData.decompose_items)
          decItemCount = decItemCount + nDecCount
        end
        tDecomposeList[nIndex] = {itemid = decItemId, count = decItemCount}
      end
      table.insert(rewardList, {
        res_id = v.resid,
        count = v.count,
        valid_hours = limitTime,
        getTags = v.drop_fun,
        to_res_id = decItemId,
        to_res_cnt = decItemCount,
        ShowUseTime = true
      })
    end
    if 0 < #rewardList then
      if tabId == 50 then
        EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_BUY_ITEM_NOTIFY, rewardList)
      else
        local everyDayUCSystem = require("client.logic.everyday_pack.logic_everyday_uc")
        if everyDayUCSystem.isSpecial then
          EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_EVERYDAYUC, rewardList)
        else
          local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
          Logic_CommonItemGet.ShowPanel_DecomposeStyle(rewardList, tDecomposeList)
        end
      end
    end
  else
    ShowNotice(res)
  end
end
function store_supply_manager:MergeRewardList(list)
  local ret = {}
  for _, v in pairs(list) do
    local key = string.format("%d_%d_%d", v.resid, v.valid_hours or 0, v.drop_fun or 0)
    if ret[key] == nil then
      ret[key] = v
    else
      ret[key].count = ret[key].count + v.count
    end
  end
  local sKey, tItemData = next(ret)
  if tItemData.drop_fun then
    local tTempData = {}
    for _, v in pairs(ret) do
      table.insert(tTempData, v)
    end
    local ItemMacros = require("client.slua.config.ClientMacros.ItemMacros")
    local Enum_GetTagType = ItemMacros.Enum_GetTagType
    table.sort(tTempData, function(a, b)
      if a.drop_fun and b.drop_fun then
        if b.drop_fun == Enum_GetTagType.Luck then
          return false
        elseif a.drop_fun == Enum_GetTagType.Luck then
          return true
        else
          return a.drop_fun > b.drop_fun
        end
      else
        return false
      end
    end)
    ret = tTempData
  end
  return ret
end
function store_supply_manager:add_market_collect_by_item_req(item_id, source_type)
  log(bWriteLog and "StoreSystem.add_market_collect_by_item_req, item_id = " .. tostring(item_id) .. ", source_type = " .. tostring(source_type))
  StoreConst.current_  local multi_state_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.multi_state_manager)
  local originID, state = multi_state_manager:GetOriginClothIDAndState(item_id)
  if originID and state ~= 1 then
    item_id = originID
    log(bWriteLog and "StoreSystem.add_market_collect_by_item_req change state, newItem = " .. tostring(item_id))
  end
  local Logic_DetailUtils = require("client.slua.logic.common.Logic_DetailUtils")
  local itemCfg = CDataTable.GetTableData("Item", item_id)
  local itemList, nUpLevelType = Logic_DetailUtils.GetMultiLevelItems(item_id, itemCfg.ItemType, true)
  local Enum_LevelUpItemType = Logic_DetailUtils.Enum_LevelUpItemType
  if nUpLevelType and nUpLevelType ~= Enum_LevelUpItemType.BackPack and next(itemList) then
    item_id = itemList[1]
  end
  local StoreHandler = require("client.network.Protocol.StoreHandler")
  StoreHandler.send_add_market_collect_by_item_req(item_id, source_type)
end
function store_supply_manager:add_market_collect_by_item_rsp(err_code, market_collect_data, source_type, item_id, collect_cnt)
  log(bWriteLog and "StoreSystem.add_market_collect_by_item_rsp, err_code = " .. tostring(err_code))
  if err_code == StoreConst.err_market_collect_success then
    local store_collect_data = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_collect_data)
    store_collect_data:ReceivedCollectionData(market_collect_data)
    local collectData = {
      [item_id] = {result = true, count = collect_cnt}
    }
    store_collect_data:UpdateCollectCount(collectData)
    EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_COLLECT)
    ShowNotice(LocUtil.GetLocalizeResStr(source_type == StoreConst.market_collect_source_pspace and 6875 or 6797))
    local StoreUtils = require("client.slua.logic.store.utils.store_utils")
    local source, jump = StoreUtils.GetSourceTypeByJumpInfo(tostring(item_id))
    if source == ENUM_ItemSourceType.None or jump.cant_buy ~= nil then
      self:get_market_collect_jump_info_req()
    end
  else
    local havePopup = false
    if err_code == StoreConst.err_market_collect_limit_by_max_count then
      if GameStatus.IsInLobbyOrMainCity() then
        local title = LocUtil.GetLocalizeResStr(110115)
        local okLabel = LocUtil.GetLocalizeResStr(6874)
        local cancelLabel = LocUtil.GetLocalizeResStr(110035)
        local tips = LocUtil.GetLocalizeResStr(6873)
        local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
        CommonMsgBoxMgr.Show(2, title, tips, function()
          local curUI = self:GetCurrentFrame()
          if curUI and curUI.GotoSpecifiedTabAndItem then
            local param = self:GetJumpCollectTabData()
            curUI:GotoSpecifiedTabAndItem(param.Tab1, param.Tab2, param.itemId)
          else
            if UIManager.GetUI(UIManager.UI_Config.lobby_social_decoration) then
              UIManager.CloseUI(UIManager.UI_Config.lobby_social_decoration)
            end
            GlobalData.JumpUrl("game://?module=1003200&Tab1=37")
          end
        end, nil, okLabel, cancelLabel)
        havePopup = true
      end
    elseif err_code == StoreConst.err_market_collect_item_not_online then
      ShowNotice(7000034)
      havePopup = true
    end
    if havePopup == false then
      ShowNotice(err_code)
    end
  end
end
function store_supply_manager:GetJumpCollectTabData()
  local param = {
    Tab1 = StoreConst.Page_ID_Collect,
    Tab2 = 0,
    itemId = 0,
    bValid = true
  }
  if not GlobalData.IsJapanOrKorea() then
    param.Tab1 = StoreConst.Page_New_ID_Recommend
    param.Tab2 = StoreConst.subtype_new_recommend_col
  end
  return param
end
function store_supply_manager:cancel_market_collect_by_item_req(item_id)
  log(bWriteLog and "StoreSystem.cancel_market_collect_by_item_req, item_id = " .. tostring(item_id))
  local multi_state_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.multi_state_manager)
  local originID, state = multi_state_manager:GetOriginClothIDAndState(item_id)
  if originID and state ~= 1 then
    item_id = originID
    log(bWriteLog and "StoreSystem.add_market_collect_by_item_req change state, newItem = " .. tostring(item_id))
  end
  local StoreHandler = require("client.network.Protocol.StoreHandler")
  StoreHandler.send_cancel_market_collect_by_item_req(item_id)
  local store_collect_data = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_collect_data)
  store_collect_data:RemoveFormNeedRedPointTab(item_id)
end
function store_supply_manager:cancel_market_collect_by_item_rsp(err_code, market_collect_data, item_id)
  log(bWriteLog and string.format("store_supply_manager:cancel_market_collect_by_item_rsp. err_code=%s, market_collect_data=%s, item_id=%s", tostring(err_code), tostring(market_collect_data), tostring(item_id)))
  if err_code == StoreConst.err_market_collect_success then
    local store_collect_data = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_collect_data)
    store_collect_data:ReceivedCollectionData(market_collect_data)
    local collectData = {
      [item_id] = {result = false, count = 0}
    }
    store_collect_data:UpdateCollectCount(collectData)
    EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_COLLECT, item_id)
    ShowNotice(LocUtil.GetLocalizeResStr(6798))
  else
    ShowNotice(err_code)
  end
end
function store_supply_manager:get_market_collect_jump_info_req()
  log(bWriteLog and "StoreSystem.get_market_collect_jump_info_req")
  local StoreHandler = require("client.network.Protocol.StoreHandler")
  StoreHandler.send_get_market_collect_jump_info_req()
end
function store_supply_manager:get_market_collect_jump_info_rsp(market_collect_jump_info)
  log_tree("StoreSystem.get_market_collect_jump_info_rsp, market_collect_jump_info = ", market_collect_jump_info)
  local TimeUtil = require("client.common.time_util")
  local parsed_jump_info = {}
  for k, v in pairs(market_collect_jump_info) do
    if type(v) == "string" then
      parsed_jump_info[k] = v
    elseif type(v) == "table" then
      for _, seg_jump_info in pairs(v) do
        if TimeUtil.UnixTimeBetween(seg_jump_info.begin_time, seg_jump_info.end_time) == 0 then
          parsed_jump_info[k] = seg_jump_info.jump_url
          break
        end
      end
    end
  end
  StoreConst.collection_jump_info = parsed_jump_info
  EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_COLLECT_JUMPINFO)
end
function store_supply_manager:box_energy_receive_award_rsp(res, itemlist, boxName, decompose_list)
  log_tree(bWriteLog and "[YY]box_energy_receive_award_rsp==itemlist==", itemlist)
  log(bWriteLog and "[YY]box_energy_receive_award_rsp==boxName==" .. tostring(boxName))
  log_tree(bWriteLog and "[YY]box_energy_receive_award_rsp===decompose_list=", decompose_list)
  local arrayItemData = {}
  if res == NetErrorCode_NONE then
    BP_Open_Box_DecomposeItemId = 0
    if decompose_list and next(decompose_list) then
      for k, v in pairs(decompose_list) do
        for tid, cnt in pairs(v) do
          log(bWriteLog and "box_energy_receive_award_rsp decompose item id :" .. tostring(tid))
          BP_Open_Box_DecomposeItemId = tid
          break
        end
        break
      end
    end
    local count = 0
    local tDecList = {}
    for k, v in pairs(itemlist) do
      local h = v.valid_hours or 0
      local decomposeInfo = decompose_list and decompose_list[k]
      if decomposeInfo == nil then
        table.insert(arrayItemData, {
          res_id = v.resid or v.res_id,
          count = v.count,
          valid_hours = h
        })
      else
        for tid, cnt in pairs(decomposeInfo) do
          table.insert(arrayItemData, {
            res_id = v.resid or v.res_id,
            count = v.count,
            valid_hours = h,
            to_res_id = tid,
            to_res_          })
          tDecList[k] = {itemid = tid, count = cnt}
          break
        end
      end
      count = count + v.count
    end
    EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_SUPPLY_ACTIVITY_OPEN_EXTRA_BOX, arrayItemData, boxName)
    EventSystem:postEvent(EVENTTYPE_CHEST_MODE, EVENTID_CHEST_MODE_EXTRA_BOX_REWARD, itemlist, tDecList)
  end
end
function store_supply_manager:LoadNewTagData()
  local str = Client.LoadFileToString("SaveGames/StoreNewTagData_" .. tostring(DataMgr.roleData.uid) .. ".json")
  log(bWriteLog and string.format("StoreSystem.LoadNewTagData str = %s", str))
  if str == "" or str == nil then
    log(bWriteLog and "str is nil or empty string.")
    StoreConst.new_tag_info = {}
    return
  end
  StoreConst.new_tag_info = json.decode(str)
end
function store_supply_manager:SaveNewTagData()
  local str = json.encode(StoreConst.new_tag_info)
  if str == "" then
    return
  end
  StoreConst.last_role_uid = DataMgr.roleData.uid
  Client.SaveStringToFile(str, "SaveGames/StoreNewTagData_" .. tostring(DataMgr.roleData.uid) .. ".json")
end
function store_supply_manager:CheckHasRecordNewTag(marketId)
  if StoreConst.new_tag_info == nil or StoreConst.last_role_uid ~= DataMgr.roleData.uid then
    self:LoadNewTagData()
  end
  return StoreConst.new_tag_info[tostring(marketId)] == 1
end
function store_supply_manager:CheckRecordNewTag(marketId)
  if StoreConst.new_tag_info == nil or StoreConst.last_role_uid ~= DataMgr.roleData.uid then
    self:LoadNewTagData()
  end
  if StoreConst.new_tag_info[tostring(marketId)] == nil then
    StoreConst.new_tag_info[tostring(marketId)] = 1
    self:SaveNewTagData()
    EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_NEW_DATA_CHANGE, marketId)
  end
end
function store_supply_manager:ShowStorePrime()
  local params = {
    bValid = true,
    Tab1 = StoreConst.Page_ID_Prime,
    Tab2 = 0
  }
  local jump_utils = require("client.logic.store.jump_utils")
  jump_utils.OpenJumpModule(BP_ENUM_MODULE_MALL_CHILD, params)
end
function store_supply_manager:JumpToStoreCrateByItemId(itemId, first, from)
  local JumpUtils = require("client.logic.store.jump_utils")
  first = first or JumpUtils.MODEL_ID_STORE
  if not JumpUtils.bGetJumpMap then
    log(bWriteLog and "store_supply_manager:JumpToStoreCrateByItemId RequestJumpMapInfo")
    JumpUtils.RequestJumpMapInfo(false, function()
      self:_JumpToStoreCrateByItemId(itemId, first, from)
    end)
    return
  end
  self:_JumpToStoreCrateByItemId(itemId, first, from)
end
function store_supply_manager:_JumpToStoreCrateByItemId(itemId, first, from)
  local JumpUtils = require("client.logic.store.jump_utils")
  local params = JumpUtils.FindJumpInfoFirst(tonumber(itemId), first)
  if params ~= nil then
    if params.moduleId == JumpUtils.MODEL_ID_STORE then
      local jump_utils = require("client.logic.store.jump_utils")
      jump_utils.OpenJumpModule(BP_ENUM_MODULE_MALL_CHILD, params)
    else
      local jump_utils = require("client.logic.store.jump_utils")
      jump_utils.OpenJumpModule(BP_ENUM_MODULE_SUPPLY, params)
    end
  else
    log(bWriteLog and "StoreSystem.JumpToStoreCrateByItemId, not found itemId = " .. tostring(itemId) .. " in Store/Crate.")
  end
end
function store_supply_manager:JumpToCrateByTabId(tabId)
  if LobbySystem.CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_NEW_SUPPLY) == false then
    return
  end
  local vars = {}
  vars.Tab1 = tonumber(tabId)
  local store_supply_switcher = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_supply_switcher)
  store_supply_switcher:OpenSupply(vars)
end
function store_supply_manager:GetReopenChestTicketCount()
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemData = wardrobe_data:GetHallDepotItemCountByResID(StoreConst.ReopenChestTicketId, true)
  return itemData
end
function store_supply_manager:CheckNeedShowCollect(market_id, info)
  if not info or not next(info) then
    return
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
    log(bWriteLog and "store_supply_manager CheckNeedShowCollect Is BLUEHOLE")
    return
  end
  local VehicleID = info[1][StoreConst.label_buy_rsp_item_id]
  local VehicleCollectSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.VehicleCollectSystem)
  local VehicleType = VehicleCollectSystem:GetVehicleType(VehicleID)
  if VehicleType < 1 then
    log(bWriteLog and "store_supply_manager CheckNeedShowCollect VehicleID" .. tostring(VehicleID))
    return
  end
  local NeedShow = false
  local LogicPlayerPrefs = require("client.logic.LogicPlayerPrefs.LogicPlayerPrefs")
  local PlayerPrefsConfig = require("client.slua.config.PlayerPrefsConfig")
  local SportCarCollect = LogicPlayerPrefs.LoadFileToData_N(PlayerPrefsConfig.eSportCarCollect)
  SportCarCollect = SportCarCollect or {}
  if not SportCarCollect[VehicleType] or SportCarCollect[VehicleType] ~= 1 then
    NeedShow = true
    SportCarCollect[VehicleType] = 1
    LogicPlayerPrefs.SaveDataToFile_N(SportCarCollect, PlayerPrefsConfig.eSportCarCollect)
  end
  if not NeedShow then
    return
  end
  local LadderCarDetailConfig = require("client.slua.logic.lobby_activity.LadderCarDetailConfig")
  local LadderDrawSystem = require("client.slua.logic.lobby_activity.logic_ladder_draw")
  local config = LadderDrawSystem.GetUIConfig()
  local key = "Apollo_WithoutSpecial"
  if LadderCarDetailConfig.IsPorscheNormal(VehicleID) then
    key = "Porsche_WithoutSpecial"
  end
  local n = LadderCarDetailConfig.CheckHowManyCarGotBySeries(LadderCarDetailConfig.Enum_CarTypeName[key])
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local animData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eLadderDrawSpecialTab) or {}
  local limit = LadderDrawSystem.IsINDOrJPKP() and config.KRIDtabSpecialCarShowLimit or config.tabSpecialCarShowLimit
  if n >= limit and not animData[LadderDrawSystem.activityId] then
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.Vehicle_CollectBenefit_UIBP)
  EventSystem:postEvent(EVENTTYPE_LADDER_DRAW, EVENTID_LADDER_COLLECT_REFRESH_MAINUI, false)
end
function store_supply_manager:HasStoreTabData(tab_id)
  return StoreConst and StoreConst.store_data and StoreConst.store_data[tab_id] ~= nil
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, store_supply_manager)
return CModuleTemplate