local Discount_Direct_Logic = {}
function Discount_Direct_Logic:DefineAndResetData()
  self.tMaterialData = nil
  self.tDirectInfo = {}
  self.needHLItem = 0
  self.buyCount = 1
end
function Discount_Direct_Logic:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_DATA, self.OnRefreshData, self)
  self:AddCommonEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_BUY_INFO_CHANGE, self.OnRefreshLimitData, self)
  self:AddCommonEvent(EVENTTYPE_RECHARGE, EVENTID_RECHARGE_PURCHASE_GET_INFO, self.OnRefreshDircetPriceInfo, self)
  self:AddCommonEvent(EVENTTYPE_CENTAURI_NOTIFY, EVENTID_CENTAURI_GET_GOODS_PRODUCT_INFO_NOTIFY, self.OnLoadPriceDataCallback, self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_TICKET_CHANGE, self.OnRefreshUC, self)
end
function Discount_Direct_Logic:GetDiscountDirectDataReq()
  if self.tMaterialData then
    return
  end
  local StoreHandler = require("client.network.Protocol.StoreHandler")
  StoreHandler.send_get_market_info_req(StoreConst.Page_New_ID_DiscountDirect, 0)
end
function Discount_Direct_Logic:OnRefreshData(_, _, data)
  if data.tab_id ~= StoreConst.Page_New_ID_DiscountDirect then
    return
  end
  local tGiftsData = data.data[3]
  log_tree("hhy Discount_Direct_Logic:OnRefreshData tGiftsData= ", tGiftsData)
  if not tGiftsData or not next(tGiftsData) then
    return
  end
  local tGiftsInfo = {}
  local index = 0
  for key, value in pairs(tGiftsData) do
    local data = {}
    data.itemId = value[StoreConst.label_item_index_id]
    data.itemZGId = value[StoreConst.label_item_index_bluehole_discount_id]
    local discountDirectCfg = CDataTable.GetTableData("BHDiscountDirectConfig", data.itemZGId)
    if not discountDirectCfg then
      return nil
    end
    data.UCMax = discountDirectCfg.UCMax
    data.discountRate = discountDirectCfg.discountRate
    data.startTime = discountDirectCfg.startTime
    data.endTime = discountDirectCfg.endTime
    data.UCCount = discountDirectCfg.UCCount
    local price_list = value[StoreConst.label_item_index_price_list][1]
    data.goodsId = value[StoreConst.label_item_index_market_id] or 0
    if not price_list or not next(price_list) then
      return
    end
    data.originPrice = price_list[StoreConst.label_price_index_one_original_price]
    data.discountPrice = price_list[StoreConst.label_price_index_one_discount_price] or 0
    data.valid_hours = price_list[StoreConst.label_price_index_valid_hours] or 0
    data.discount = value[StoreConst.label_item_index_discount] or 0
    data.marketId = value[StoreConst.label_item_index_market_id] or 0
    data.itemNum = value[StoreConst.label_item_index_count] or 1
    data.priceType = price_list[StoreConst.label_price_index_price_type]
    data.limitType = next(value[StoreConst.label_item_index_buy_limit])
    data.limitNum = 1
    index = index + 1
    tGiftsInfo[index] = data
  end
  table.sort(tGiftsInfo, function(a, b)
    return a.UCMax < b.UCMax
  end)
  log_tree("hhy Discount_Direct_Logic:OnRefreshData over sort tGiftsInfo= ", tGiftsInfo)
  self.tMaterialData = tGiftsInfo
  self:OnRefreshLimitBuyInfo()
  self:GetNeedHLItem()
  self:GetPriceInfoReq()
  EventSystem:postEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_SPECIAL_DISCOUNT_DIRECT_PACKAGE)
  EventSystem:postEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_SPECIAL_OFFER_REFRESH_PAGE)
end
function Discount_Direct_Logic:GetNeedHLItem()
  self.needHLItem = 0
  if not self.tMaterialData then
    return
  end
  log(bWriteLog and "hhy Discount_Direct_Logic:GetNeedHLItem")
  for _, v in pairs(self.tMaterialData) do
    if type(v) ~= "table" then
      return
    end
    if DataMgr.ticket < v.UCMax and 0 < v.limitNum then
      self.needHLItem = v.itemId
      break
    end
  end
end
function Discount_Direct_Logic:GetPriceInfoReq()
  local Gifts_Const = require("client.slua.logic.specialoffer.special_offer_gifts_const")
  local Enum_PriceType = Gifts_Const.Enum_PriceType
  local req_id_list = {}
  if not self.tMaterialData then
    return
  end
  log(bWriteLog and "hhy Discount_Direct_Logic:GetPriceInfoReq")
  for _, value in pairs(self.tMaterialData) do
    if value.priceType == Enum_PriceType.Dollar then
      table.insert(req_id_list, value.originPrice)
    end
  end
  local RechargePurchaseSystem = require("client.logic.recharge.logic_recharge_purchase")
  RechargePurchaseSystem.GetPurchaseInfoReq(req_id_list)
end
function Discount_Direct_Logic:OnRefreshDircetPriceInfo(_, _, list)
  if not self.tMaterialData then
    return
  end
  log_tree("hhy Discount_Direct_Logic:OnRefreshDircetPriceInfo list = ", list)
  for _, data in pairs(self.tMaterialData) do
    if type(data) ~= "table" then
      return
    end
    if list[data.originPrice] then
      local price_data = list[data.originPrice]
      self.tDirectInfo[data.goodsId] = price_data
      local price = CentauriManager.GetPriceByProductId(price_data.productid, price_data.curency_unit, price_data.price, true)
      data.originPrice = price
      data.productid = price_data.productid
      data.curency_unit = price_data.curency_unit
    end
  end
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_MATERIAL_DATA_REFRESH)
end
function Discount_Direct_Logic:CheckPriceData()
  if not self.tMaterialData then
    return
  end
  local sAllProductId = ""
  for _, data in pairs(self.tMaterialData) do
    if data.productid then
      if sAllProductId ~= "" then
        sAllProductId = sAllProductId .. ","
      end
      sAllProductId = sAllProductId .. data.productid
    end
  end
  local bIsGotMidas = CentauriManager.LoadCachedCentauriProductInfo(sAllProductId)
  if not bIsGotMidas then
    self:OnLoadPriceDataCallback()
  end
end
function Discount_Direct_Logic:OnLoadPriceDataCallback(_, _, resultCode)
  if not self.tMaterialData or not resultCode then
    log(bWriteLog and "hhy Discount_Direct_Logic:OnLoadPriceDataCallback return >>>> ")
    return
  end
  log_tree("hhy Discount_Direct_Logic:OnLoadPriceDataCallback get Midas data :", resultCode)
  for _, data in pairs(self.tMaterialData) do
    local oldPrice = data.originPrice
    local price = CentauriManager.GetPriceByProductId(data.productid, data.curency_unit, oldPrice)
    data.originPrice = price
    log(bWriteLog and "hhy Discount_Direct_Logic:OnLoadPriceDataCallback Update Price  >>>>> " .. oldPrice .. " >>>> " .. price)
  end
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_MATERIAL_DATA_REFRESH)
end
function Discount_Direct_Logic:OnRefreshLimitData()
  if not self.tMaterialData then
    return
  end
  self:OnRefreshLimitBuyInfo()
  self:GetNeedHLItem()
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_MATERIAL_DATA_REFRESH)
end
function Discount_Direct_Logic:OnRefreshLimitBuyInfo()
  log_tree("hhy Discount_Direct_Logic:OnRefreshLimitBuyInfo StoreConst.buy_info = ", StoreConst.buy_info)
  local limit_info = StoreConst.buy_info
  if not limit_info or not self.tMaterialData then
    return
  end
  for _, data in pairs(self.tMaterialData) do
    if type(data) ~= "table" then
      return
    end
    data.limitNum = 1
    for index, _ in pairs(limit_info) do
      if data.goodsId == index then
        data.limitNum = 0
        break
      end
    end
  end
end
function Discount_Direct_Logic:OnBuyEvent(itemData)
  log_tree("hhy Discount_Direct_Logic:OnBuyEvent itemData = ", itemData)
  log_tree("hhy Discount_Direct_Logic:OnBuyEvent self.tDirectInfo = ", self.tDirectInfo)
  self:HandleGiftBuyEvent(itemData, self.tDirectInfo[itemData.goodsId], {
    count = self.buyCount
  })
end
function Discount_Direct_Logic:HandleGiftBuyEvent(tData, tDirectInfo, tExtraInfo)
  local Gifts_Const = require("client.slua.logic.specialoffer.special_offer_gifts_const")
  local store_buy_utils = require("client.slua.umg.NewStoreV280.NewStoreMove.buy.store_buy_utils")
  local Enum_PriceType = Gifts_Const.Enum_PriceType
  local item_data = tData
  local data = {}
  data[StoreConst.label_buy_param_id] = item_data.goodsId
  data[StoreConst.label_buy_param_price_type] = item_data.priceType
  data[StoreConst.label_buy_param_tab_id] = item_data.tabId
  data[StoreConst.label_buy_param_valid_hours] = item_data.valid_hours
  data[StoreConst.label_buy_param_count] = tExtraInfo and tExtraInfo.count and tExtraInfo.count or item_data.itemNum
  if item_data.priceType == Enum_PriceType.Dollar then
    if not tDirectInfo then
      return
    end
    local directInfo = tDirectInfo
    local purchaseInfo = {}
    purchaseInfo.CentauriProductId = directInfo.productid
    purchaseInfo.CentauriCountry = directInfo.country
    purchaseInfo.CentauriCurrency = directInfo.curency_unit
    purchaseInfo.CentauriPrice = directInfo.CentauriPrice
    purchaseInfo.CentauriPayItem = directInfo.payItem
    purchaseInfo.priceDesc = CentauriManager.GetPriceByProductId(purchaseInfo.CentauriProductId, purchaseInfo.CentauriCurrency, tostring(purchaseInfo.CentauriCurrency) .. tostring(purchaseInfo.CentauriPrice), true)
    local info = {}
    info.item_id = directInfo.item_id
    info.CentauriProductId = purchaseInfo.CentauriProductId
    info.CentauriPayItem = purchaseInfo.CentauriPayItem
    info.CentauriPrice = purchaseInfo.CentauriPrice
    info.CentauriCountry = purchaseInfo.CentauriCountry
    info.CentauriCurrency = purchaseInfo.CentauriCurrency
    local store_direct_purchase_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_direct_purchase_manager)
    store_direct_purchase_manager:SetDirectPurchaseInfo(info)
    local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
    store_supply_manager:buy_market_by_id_req(data)
  elseif item_data.priceType == Enum_PriceType.FpToken then
    local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
    store_supply_manager:buy_market_by_id_req(data)
  else
    local myMoney = store_buy_utils.GetMyMoneyByType(item_data.priceType)
    local price = item_data.originPrice
    if item_data.discountPrice > 0 then
      price = item_data.discountPrice
    end
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
    if myMoney < price then
      if item_data.priceType == Enum_PriceType.Uc then
        local CommonPayBoxMgr = require("client.slua.logic.common.Payclass.logic_common_pay_box")
        CommonPayBoxMgr.ShowUcRechargeMsg(price)
        return
      else
        local needAutoExchange = price - myMoney
        local strBuy = LocUtil.GetLocalizeResStr(301185)
        local tips = LocUtil.GetLocalizeResStr(9488)
        tips = string.gsub(tips, "'", "\"")
        tips = LocUtil.LocalizeResFormatByStr(tips, needAutoExchange, math.ceil(needAutoExchange / 10))
        CommonMsgBoxMgr.Show(2, strBuy, tips, function()
          local nNeedCount = math.ceil(needAutoExchange / 10)
          if nNeedCount > DataMgr.ticket then
            local CommonPayBoxMgr = require("client.slua.logic.common.Payclass.logic_common_pay_box")
            CommonPayBoxMgr.ShowUcRechargeMsg(nNeedCount)
          else
            store_supply_manager:buy_market_by_id_req(data)
            return
          end
        end)
        return
      end
    end
    store_supply_manager:buy_market_by_id_req(data)
  end
end
function Discount_Direct_Logic:OnRefreshUC()
  self:GetNeedHLItem()
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_MATERIAL_DATA_REFRESH)
end
function Discount_Direct_Logic:GetGiftsData()
  if self:HaveGiftsData() then
    return self.tMaterialData
  end
  return self:SetTableData()
end
function Discount_Direct_Logic:HaveGiftsData()
  if not self.tMaterialData or not next(self.tMaterialData) then
    return false
  end
  return true
end
function Discount_Direct_Logic:GetOneGiftData(itemId)
  if not self.tMaterialData then
    return nil
  end
  for _, data in pairs(self.tMaterialData) do
    if type(data) ~= "table" then
      return nil
    end
    if data.itemId == itemId then
      return data
    end
  end
  return nil
end
function Discount_Direct_Logic:SetTableData()
  local discountDirectCfg = CDataTable.GetTable("BHDiscountDirectConfig")
  if not discountDirectCfg then
    return nil
  end
  local discountData = {}
  local index = 0
  local TimeUtil = require("client.common.time_util")
  for _, v in pairs(discountDirectCfg) do
    local bIsInActTime = TimeUtil.UnixTimeStrBetween(v.startTime, v.endTime) == 0
    if bIsInActTime then
      local data = {}
      data.itemId = v.itemID
      data.UCMax = v.UCMax
      data.discountRate = v.discountRate
      data.startTime = v.startTime
      data.endTime = v.endTime
      data.UCCount = v.UCCount
      index = index + 1
      discountData[index] = data
    end
  end
  table.sort(discountData, function(a, b)
    return a.UCMax < b.UCMax
  end)
  log_tree("hhy Discount_Direct_Logic:SetTableData over sort discountData= ", discountData)
  return discountData
end
function Discount_Direct_Logic:IsShow()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if not PublishRegionMacros.IsBLUEHOLE() then
    return false
  end
  local isIn = self:IsInExpirationDate()
  return isIn
end
function Discount_Direct_Logic:IsInExpirationDate()
  local TimeUtil = require("client.common.time_util")
  if self:HaveGiftsData() then
    local data = self.tMaterialData[1]
    local startTime = data.startTime
    local endTime = data.endTime
    if not startTime or not endTime then
      return false
    end
    local bIsInActTime = TimeUtil.UnixTimeStrBetween(startTime, endTime) == 0
    return bIsInActTime
  else
    local discountDirectCfg = CDataTable.GetTable("BHDiscountDirectConfig")
    if not discountDirectCfg then
      return false
    end
    for _, cfg in pairs(discountDirectCfg) do
      local bIsInActTime = TimeUtil.UnixTimeStrBetween(cfg.startTime, cfg.endTime) == 0
      if bIsInActTime then
        return true
      end
    end
  end
  return false
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CTemplate = class(CModuleBase, nil, Discount_Direct_Logic)
return CTemplate