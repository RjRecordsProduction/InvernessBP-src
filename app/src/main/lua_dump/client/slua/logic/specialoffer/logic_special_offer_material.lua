local logic_special_offer_material = {}
local playerprefs = require("client.logic.LogicPlayerPrefs.playerprefs")
function logic_special_offer_material:DefineAndResetData()
  self.rawData = nil
  self.tMaterialData = nil
  self.bIsCanBuy = true
  self.tDirectInfo = nil
  self.searchTimer = nil
  self.buyData = playerprefs.LoadFileToTable_N(playerprefs.ePlayerPrefsType.eSpecialOfferMaterial) or {}
  log_tree("logic_special_offer_material self.buyData", self.buyData)
  if next(self.buyData) then
    self:CheckReUpdate()
  end
end
function logic_special_offer_material:RegistEvents()
  log(bWriteLog and "[SY]logic_special_offer_material:RegistEvents.")
  self:AddCommonEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_DATA, self.OnPageInfo, self)
  self:AddCommonEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_BUY_INFO_CHANGE, self.OnRefreshGiftsData, self)
  self:AddCommonEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_BUY, self.OnRefreshSubscribe, self)
  self:AddCommonEvent(EVENTTYPE_NEXTDAY, EVENTID_NEXTDAY_ZERO, self.NextDayReqActData, self)
  self:AddCommonEvent(EVENTTYPE_RECHARGE, EVENTID_RECHARGE_PURCHASE_GET_INFO, self.OnRefreshDircetPriceInfo, self)
  self:AddCommonEvent(EVENTTYPE_CENTAURI_NOTIFY, EVENTID_CENTAURI_GET_GOODS_PRODUCT_INFO_NOTIFY, self.OnLoadPriceDataCallback, self)
end
function logic_special_offer_material:HandMaterialGiftsData()
  self:GetMaterialGiftContent()
  local materialData = self:GetGiftsData()
  if not materialData then
    return
  end
  local tResult = {}
  for _, v in pairs(materialData) do
    if not tResult[v.nGroupId] then
      tResult[v.nGroupId] = {}
    end
    table.insert(tResult[v.nGroupId], v)
  end
  for _, v in pairs(tResult) do
    table.sort(v, function(a, b)
      return a.nGroupPosition < b.nGroupPosition
    end)
  end
  self:SetGiftsData(tResult)
  EventSystem:postEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_SPECIAL_OFFER_REFRESH_PAGE)
  return tResult
end
function logic_special_offer_material:GetGiftsData()
  if not self.tMaterialData and self.rawData then
    self:RawDataHanle()
  end
  return self.tMaterialData
end
function logic_special_offer_material:SetGiftsData(data)
  self.tMaterialData = data
end
function logic_special_offer_material:CheckGiftData()
  return self.rawData and next(self.rawData)
end
function logic_special_offer_material:GetMaterialGiftContent()
  local tGrigtCfg = {}
  local materialData = self:GetGiftsData()
  for _, data in pairs(materialData) do
    local sPath = self:GetMaterialConfigPath()
    local tGiftCotent = CDataTable.GetTableData(sPath, data.goodsId)
    if not tGiftCotent then
      self:SetGiftsData(nil)
      return
    end
    local nGroupId = tGiftCotent.GroupId
    local nGroupPosition = tGiftCotent.GroupPosition
    local nConditionType = tGiftCotent.PurchaseConditionType
    local nConditionParameters = tGiftCotent.PurchaseConditionParameters
    local tGiftGroup = CDataTable.GetTableData("MaterialGiftGroup", nGroupId)
    local sGroupName = tGiftGroup.GroupName
    local sGroupBg = tGiftGroup.GroupBg
    table.insert(tGrigtCfg, {
      nGroupId = nGroupId,
      nGroupPosition = nGroupPosition,
      sGroupName = sGroupName,
      sGroupBg = sGroupBg,
      nConditionType = nConditionType,
      nConditionParameters = nConditionParameters,
          })
  end
  for i, v in pairs(tGrigtCfg) do
    local tData = materialData[i]
    tData.nGroupId = v.nGroupId
    tData.nGroupPosition = v.nGroupPosition
    tData.sGroupName = v.sGroupName
    tData.sGroupBg = v.sGroupBg
    tData.nConditionType = v.nConditionType
    tData.nConditionParameters = v.nConditionParameters
  end
  log_tree("GetMaterialGiftContent: ", materialData)
end
function logic_special_offer_material:GetGiftsRefrshTime(limitType)
  local Gifts_Const = require("client.slua.logic.specialoffer.special_offer_gifts_const")
  local TimeUtil = require("client.common.time_util")
  local Enum_LimitType = Gifts_Const.Enum_LimitType
  if limitType == Enum_LimitType.Daily or limitType == Enum_LimitType.backUserDaily or limitType == Enum_LimitType.privilegeDaily or limitType == Enum_LimitType.rpPlusDaily then
    return TimeUtil.GetTodayStartTimestamp() + 86400
  elseif limitType == Enum_LimitType.Week or limitType == Enum_LimitType.backUserWeek or limitType == Enum_LimitType.privilegeWeek or limitType == Enum_LimitType.rpPlusWeek then
    local nWeekDay = TimeUtil.GetServerWeekDay()
    if nWeekDay == 0 then
      nWeekDay = 7
    end
    local nDayCount = 7 - nWeekDay
    local nTimestamp = TimeUtil.GetTodayStartTimestamp() + 86400 + nDayCount * 86400
    return nTimestamp
  end
  log_error(bWriteLog and "logic_special_offer_material:GetGiftsRefrshTime is error " .. tostring(limitType))
  return 0
end
function logic_special_offer_material:OnPageInfo(_, _, data)
  if data.tab_id ~= StoreConst.Page_Special_Material_Pack then
    return
  end
  self.rawData = data
  local queue_task_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.queue_task_module)
  local task = {
    module = self,
    funcName = "RawDataHanle",
    param = self,
    debugInfo = "logic_special_offer_material",
    protect = true
  }
  queue_task_module:Enqueue(queue_task_module.TaskEnum.Lobby, task)
end
function logic_special_offer_material:RawDataHanle()
  if not self.rawData or not next(self.rawData) then
    return
  end
  local tGiftsData = self:FilterMaterialData(self.rawData.data[3])
  if not tGiftsData or not next(tGiftsData) then
    return
  end
  local tGiftsInfo = {}
  for key, value in pairs(tGiftsData) do
    local data = {}
    data.itemId = value[StoreConst.label_item_index_id]
    local price_list = value[StoreConst.label_item_index_price_list][1]
    data.goodsId = value[StoreConst.label_item_index_market_id] or 0
    if not price_list or not next(price_list) then
      log(bWriteLog and "goods price_list is nil " .. data.goodsId)
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
    table.insert(tGiftsInfo, data)
  end
  self:SetGiftsData(tGiftsInfo)
  self:HandMaterialGiftsData()
  self:OnRefreshLimitBuyInfo()
  self:CheckReUpdate()
  self:GetPriceInfoReq()
  local cfg = require("client.slua.logic.specialoffer.special_offer_cfg")
  EventSystem:postEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_SPECIAL_RED_CHANGE, cfg.MaterialsGift)
end
function logic_special_offer_material:FilterMaterialData(data)
  local sPath = self:GetMaterialConfigPath()
  local _tGiftData = {}
  for goodsId, value in pairs(data) do
    local tGiftCotent = CDataTable.GetTableData(sPath, goodsId)
    if tGiftCotent then
      table.insert(_tGiftData, value)
    end
  end
  return _tGiftData
end
function logic_special_offer_material:GetMaterialConfigPath()
  local sPath = "MaterialGiftContent"
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local bIsJapanOrKorea = PublishRegionMacros.IsJapanOrKorea()
  local bIsBLUEHOLE = PublishRegionMacros.IsBLUEHOLE()
  if bIsJapanOrKorea then
    sPath = "MaterialGiftContentKJ"
  elseif bIsBLUEHOLE then
    sPath = "MaterialGiftContentIN"
  end
  return sPath
end
function logic_special_offer_material:OnRefreshLimitBuyInfo()
  log_tree(" StoreConst.buy_info:", StoreConst.buy_info)
  local limit_info = StoreConst.buy_info
  local materialData = self:GetGiftsData()
  if not limit_info or not materialData then
    return
  end
  local store_limit_buy_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_limit_buy_manager)
  local Gifts_Const = require("client.slua.logic.specialoffer.special_offer_gifts_const")
  for _, value in pairs(materialData) do
    for _, data in pairs(value) do
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
      if data.limitType == Gifts_Const.Enum_LimitType.Daily then
        data.limitText = LocUtil.GetLocalizeResStr(63038)
      elseif data.limitType == Gifts_Const.Enum_LimitType.Week then
        data.limitText = LocUtil.GetLocalizeResStr(63039)
      elseif data.limitType == Gifts_Const.Enum_LimitType.Forever then
        data.limitText = LocUtil.GetLocalizeResStr(63041)
      end
      local limitType, count, addCount = store_limit_buy_manager:GetBackUserPrivilege(data.goodsId)
      if limitType and limitType == Gifts_Const.Enum_LimitType.backUserDaily then
        if 0 < count then
          data.limitType = Gifts_Const.Enum_LimitType.backUserDaily
        else
          data.limitType = Gifts_Const.Enum_LimitType.Daily
        end
        data.limitNum = data.limitNum + count
        data.limitText = LocUtil.GetLocalizeResStr(78052)
      elseif limitType and limitType == Gifts_Const.Enum_LimitType.backUserWeek then
        if 0 < count then
          data.limitType = Gifts_Const.Enum_LimitType.backUserWeek
        else
          data.limitType = Gifts_Const.Enum_LimitType.Week
        end
        data.limitNum = data.limitNum + count
        data.limitText = LocUtil.GetLocalizeResStr(78053)
      end
      data.backUserAddCount = addCount or 0
      limitType, count, addCount = store_limit_buy_manager:GetCollectPrivilege(data.goodsId)
      if limitType and limitType == Gifts_Const.Enum_LimitType.privilegeDaily then
        if 0 < count then
          data.limitType = Gifts_Const.Enum_LimitType.privilegeDaily
        else
          data.limitType = Gifts_Const.Enum_LimitType.Daily
        end
        data.limitNum = data.limitNum + count
        data.limitText = LocUtil.GetLocalizeResStr(64354)
      elseif limitType and limitType == Gifts_Const.Enum_LimitType.privilegeWeek then
        if 0 < count then
          data.limitType = Gifts_Const.Enum_LimitType.privilegeWeek
        else
          data.limitType = Gifts_Const.Enum_LimitType.Week
        end
        data.limitNum = data.limitNum + count
        data.limitText = LocUtil.GetLocalizeResStr(64355)
      end
      data.collectAddCount = addCount or 0
      limitType, count, addCount = store_limit_buy_manager:GetRPPlusPrivilege(data.goodsId)
      if limitType and limitType == Gifts_Const.Enum_LimitType.rpPlusDaily then
        data.limitType = Gifts_Const.Enum_LimitType.rpPlusDaily
        data.limitNum = data.limitNum + count
        data.limitText = LocUtil.GetLocalizeResStr(64354)
      elseif limitType and limitType == Gifts_Const.Enum_LimitType.rpPlusWeek then
        data.limitType = Gifts_Const.Enum_LimitType.rpPlusWeek
        data.limitNum = data.limitNum + count
        data.limitText = LocUtil.GetLocalizeResStr(64355)
      end
      data.rpPlusAddCount = addCount or 0
    end
  end
end
function logic_special_offer_material:OnRefreshGiftsData()
  if not self:GetGiftsData() then
    return
  end
  local cfg = require("client.slua.logic.specialoffer.special_offer_cfg")
  self:OnRefreshLimitBuyInfo()
  log(bWriteLog and "[SY]logic_special_offer_material:OnRefreshGiftsData.")
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_MATERIAL_DATA_REFRESH)
  EventSystem:postEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_SPECIAL_RED_CHANGE, cfg.MaterialsGift)
end
function logic_special_offer_material:OnRefreshSubscribe(_, __, data)
  if data and data.market_id then
    local StoreLimitedSubscribeData = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_limited_subscribe_data)
    if self:IsSpecialOfferMaterial(data.market_id) and not StoreLimitedSubscribeData:JudgementOfferShareShopIdList(data.market_id) and not StoreLimitedSubscribeData:HasManuallyUnsubscribe(data.market_id) then
      local StoreHandler = require("client.network.Protocol.StoreHandler")
      StoreHandler.send_subscribe_commodity_req(data.market_id, 1)
    end
  end
end
function logic_special_offer_material:NextDayReqActData()
  log(bWriteLog and "[SY]logic_special_offer_material:NextDayReqActData.")
  local StoreHandler = require("client.network.Protocol.StoreHandler")
  StoreHandler.send_get_market_info_req(61, 0)
end
function logic_special_offer_material:IsSpecialOfferMaterial(shopId)
  local materialData = self:GetGiftsData()
  if not materialData or not next(materialData) then
    return false
  end
  for _, group in pairs(materialData) do
    for __, info in pairs(group) do
      if info and info.marketId and info.marketId == shopId then
        return true
      end
    end
  end
  return false
end
function logic_special_offer_material:IsCanBuyGifts()
  local materialData = self:GetGiftsData()
  if not materialData then
    return false
  end
  for _, v in pairs(materialData) do
    if type(v) ~= "table" then
      return
    end
    for _, vv in pairs(v) do
      if vv.limitNum == 1 then
        return true
      end
    end
  end
  return false
end
function logic_special_offer_material:OnRefreshDircetPriceInfo(_, _, list)
  local materialData = self:GetGiftsData()
  if not materialData then
    return
  end
  for _, value in pairs(materialData) do
    for _, data in pairs(value) do
      if type(data) ~= "table" then
        return
      end
      if list[data.originPrice] then
        local price_data = list[data.originPrice]
        self.tDirectInfo = price_data
        local price = CentauriManager.GetPriceByProductId(price_data.productid, price_data.curency_unit, price_data.price, true)
        data.originPrice = price
        data.productid = price_data.productid
        data.curency_unit = price_data.curency_unit
      end
    end
  end
end
function logic_special_offer_material:CheckPriceData()
  local materialData = self:GetGiftsData()
  if not materialData then
    return
  end
  local sAllProductId = ""
  for _, value in pairs(materialData) do
    for _, data in pairs(value) do
      if data.productid then
        if sAllProductId ~= "" then
          sAllProductId = sAllProductId .. ","
        end
        sAllProductId = sAllProductId .. data.productid
      end
    end
  end
  local bIsGotMidas = CentauriManager.LoadCachedCentauriProductInfo(sAllProductId)
  if not bIsGotMidas then
    self:OnLoadPriceDataCallback()
  end
end
function logic_special_offer_material:OnLoadPriceDataCallback(_, _, resultCode)
  local materialData = self:GetGiftsData()
  if not materialData or not resultCode then
    log(bWriteLog and " logic_special_offer_material:OnLoadPriceDataCallback return >>>> ")
    return
  end
  log_tree(" logic_special_offer_material:OnLoadPriceDataCallback get Midas data :", resultCode)
  for _, value in pairs(materialData) do
    for _, data in pairs(value) do
      local oldPrice = data.originPrice
      local price = CentauriManager.GetPriceByProductId(data.productid, data.curency_unit, oldPrice)
      data.originPrice = price
      log(bWriteLog and " logic_special_offer_material:OnLoadPriceDataCallback Update Price  >>>>> " .. oldPrice .. " >>>> " .. price)
    end
  end
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_MATERIAL_DATA_REFRESH)
end
function logic_special_offer_material:OpenBuyPopup(itemData)
  local logic_coupon = require("client.slua.logic.coupon.logic_coupon")
  UIManager.ShowUI(UIManager.UI_Config.SpecialOffer_Material_Popup_UIBP, itemData, self.tDirectInfo, nil, nil, logic_coupon._Enum_Scene._SpecialOfferCondition)
end
function logic_special_offer_material:GetMaterialGiftsDataReq()
  if self:GetGiftsData() then
    return
  end
  local StoreHandler = require("client.network.Protocol.StoreHandler")
  StoreHandler.send_get_market_info_req(StoreConst.Page_Special_Material_Pack, 0)
end
function logic_special_offer_material:GetPriceInfoReq()
  local Gifts_Const = require("client.slua.logic.specialoffer.special_offer_gifts_const")
  local Enum_PriceType = Gifts_Const.Enum_PriceType
  local req_id_list = {}
  local materialData = self:GetGiftsData()
  if not materialData then
    return
  end
  for _, value in pairs(materialData) do
    for _, data in pairs(value) do
      if data.priceType == Enum_PriceType.Dollar then
        table.insert(req_id_list, data.originPrice)
      end
    end
  end
  local RechargePurchaseSystem = require("client.logic.recharge.logic_recharge_purchase")
  RechargePurchaseSystem.GetPurchaseInfoReq(req_id_list)
end
local BuyType = {
  Normal = 0,
  Bought = 1,
  ReUpdate = 2
}
function logic_special_offer_material:OnBuyOne(groupId, index)
  local key = string.format("%d_%d", groupId, index)
  self.buyData[key] = BuyType.Bought
  playerprefs.SaveTableToFile_N(self.buyData, playerprefs.ePlayerPrefsType.eSpecialOfferMaterial)
  self:CheckReUpdate()
end
function logic_special_offer_material:Key2Data(key)
  local materialData = self:GetGiftsData()
  if not materialData then
    return
  end
  local StringUtil = require("common.string_util")
  local tb = StringUtil.Split(key, "_")
  local group, index = tonumber(tb[1]), tonumber(tb[2])
  return materialData[group][index]
end
function logic_special_offer_material:CheckReUpdate()
  local smallestTime = math.huge
  for k, v in pairs(self.buyData) do
    if v == BuyType.Bought then
      local oneData = self:Key2Data(k)
      local limitNum = oneData and oneData.limitNum
      if limitNum then
        if 0 < limitNum then
          self:ShowReUpdate(k)
        elseif limitNum <= 0 then
          local endTime = self:GetGiftsRefrshTime(oneData.limitType)
          if smallestTime > endTime then
            smallestTime = endTime
          end
        end
      end
    end
  end
  log_warning(bWriteLog and "  : smallestTime: " .. tostring(smallestTime))
  if smallestTime ~= math.huge then
    local TimeUtil = require("client.common.time_util")
    local now = TimeUtil.GetServerTimeInSec()
    self:StartSearchBuyTime(smallestTime + 1 - now)
  end
end
function logic_special_offer_material:ShowReUpdate(key)
  self.buyData[key] = BuyType.ReUpdate
  playerprefs.SaveTableToFile_N(self.buyData, playerprefs.ePlayerPrefsType.eSpecialOfferMaterial)
  local special_offer_cfg = require("client.slua.logic.specialoffer.special_offer_cfg")
  EventSystem:postEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_SPECIAL_RED_CHANGE, special_offer_cfg.MaterialsGift)
end
function logic_special_offer_material:StartSearchBuyTime(delay)
  if self.searchTimer then
    self:RemoveTimer(self.searchTimer)
    self.searchTimer = nil
  end
  if delay < 0 then
    log(bWriteLog and "GiftType is forever, not redot")
    return
  end
  log_warning(bWriteLog and "  : delay: " .. tostring(delay))
  self.searchTimer = self:AddTimerOnce(delay, function()
    self:TimeEnd()
    self:RemoveTimer(self.searchTimer)
    self.searchTimer = nil
  end)
end
function logic_special_offer_material:TimeEnd()
  for k, v in pairs(self.buyData) do
    if v == BuyType.Bought then
      local oneData = self:Key2Data(k)
      if oneData and oneData.limitNum and oneData.limitNum ~= 0 then
        self:ShowReUpdate(k)
        break
      end
    end
  end
end
function logic_special_offer_material:HasReUpdate()
  local materialData = self:GetGiftsData()
  if not materialData then
    return false
  end
  for _, group in ipairs(materialData) do
    for index, v in ipairs(group) do
      local key = string.format("%d_%d", v.nGroupId, index)
      if self.buyData[key] == BuyType.ReUpdate then
        return true
      end
    end
  end
  return false
end
function logic_special_offer_material:RemoveReUpdate()
  local hasRemoved
  for k, v in pairs(self.buyData) do
    if v == BuyType.ReUpdate then
      self.buyData[k] = nil
      hasRemoved = true
    end
  end
  if hasRemoved then
    log_tree("RemoveReUpdate self.buyData", self.buyData)
    playerprefs.SaveTableToFile_N(self.buyData, playerprefs.ePlayerPrefsType.eSpecialOfferMaterial)
  end
end
function logic_special_offer_material:HandleGiftBuyEvent(tData, tDirectInfo, tExtraInfo, currentCouponId)
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
  if currentCouponId and 0 < currentCouponId then
    data[StoreConst.label_buy_param_voucher] = currentCouponId
  end
  if item_data.priceType == Enum_PriceType.Dollar then
    if not tDirectInfo then
      return
    end
    local directInfo = tDirectInfo
    local purchaseInfo = {}
    purchaseInfo.CentauriProductId = directInfo.productid
    purchaseInfo.CentauriCountry = directInfo.country
    purchaseInfo.CentauriCurrency = directInfo.curency_unit
    purchaseInfo.CentauriPrice = (tonumber(directInfo.CentauriPrice) or 0) / 10
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
    if 0 < item_data.discountPrice then
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
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CTemplate = class(CModuleBase, nil, logic_special_offer_material)
return CTemplate