local logic_special_offer_condition = {}
function logic_special_offer_condition:DefineAndResetData()
  self.rawData = nil
  self.tConditionData = nil
  self.tDirectInfo = {}
  self.tGroupIdToDropIdList = {}
  self.tLoginDays = nil
  self.tSkipLoginNeedUC = nil
  self.tSkipLoginIdList = {}
  self.bIsDircetPriceRsp = false
end
function logic_special_offer_condition:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_DATA, self.OnPageInfo, self)
  self:AddCommonEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_BUY_INFO_CHANGE, self.OnRefreshGiftsData, self)
  self:AddCommonEvent(EVENTTYPE_RECHARGE, EVENTID_RECHARGE_PURCHASE_GET_INFO, self.OnRefreshDircetPriceInfo, self)
  self:AddCommonEvent(EVENTTYPE_CENTAURI_NOTIFY, EVENTID_CENTAURI_GET_GOODS_PRODUCT_INFO_NOTIFY, self.OnLoadPriceDataCallback, self)
end
function logic_special_offer_condition:HandConditionGiftsData()
  self:GetConditionGiftContent()
  local conditionData = self:GetGiftsData()
  if not conditionData then
    return
  end
  local tResult = {}
  local tDropKeyList = {}
  local tSkipLoginNeedUC = {}
  for _, v in pairs(conditionData) do
    if not tResult[v.nGroupId] then
      tResult[v.nGroupId] = {}
    end
    table.insert(tResult[v.nGroupId], v)
    if not tDropKeyList[v.nGroupId] then
      tDropKeyList[v.nGroupId] = {}
    end
    table.insert(tDropKeyList[v.nGroupId], v.itemId)
    if not tSkipLoginNeedUC[v.nGroupId] and v.SkipLoginDailyNeedUC and v.SkipLoginDailyNeedUC > 0 then
      tSkipLoginNeedUC[v.nGroupId] = v.SkipLoginDailyNeedUC
    end
  end
  for _, v in pairs(tResult) do
    table.sort(v, function(a, b)
      return a.nGroupPosition < b.nGroupPosition
    end)
  end
  if not next(tResult) then
    return
  end
  self.tGroupIdToDropIdList = tDropKeyList
  self:SetGiftsData(tResult)
  self.  self:OnRefreshLimitBuyInfo()
  local cfg = require("client.slua.logic.specialoffer.special_offer_cfg")
  EventSystem:postEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_SPECIAL_RED_CHANGE, cfg.ConditionsGift)
  EventSystem:postEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_SPECIAL_OFFER_REFRESH_PAGE)
  self:NotifyFITLobbyEntrance(tResult)
end
function logic_special_offer_condition:GetConditionGiftContent()
  local tGiftCfg = {}
  local tGiftData = self:GetGiftsData()
  for index, data in pairs(tGiftData) do
    local item_data = {}
    local sPath = self:GetConditionConfigPath()
    local tGiftCotent = CDataTable.GetTableData(sPath, data.goodsId)
    if not tGiftCotent then
      log_error("tGiftCotent is nil " .. tostring(data.goodsId))
      self:SetGiftsData(nil)
      return
    end
    item_data.nConditionType = tGiftCotent.ConditionType
    item_data.nConditionParam = tGiftCotent.ConditionParam
    item_data.nGroupId = tGiftCotent.GroupId
    item_data.nGroupPosition = tGiftCotent.GroupPosition
    item_data.nPreGoodsId = tGiftCotent.PreGoodsId or 0
    item_data.sGiftBoxIcon = tGiftCotent.GiftBoxIcon
    item_data.sGiftBg = tGiftCotent.GiftBg
    local bgResId = tGiftCotent.BgResId
    if bgResId and bgResId ~= 0 then
      local bgCfg = CDataTable.GetTableData("ConditionBgCfg", bgResId)
      if bgCfg then
        item_data.itemBg = bgCfg.ItemBg
        item_data.ActivityBgL = bgCfg.ActivityBgL
        item_data.ActivityBgR = bgCfg.ActivityBgR
        item_data.itemSelectBg = bgCfg.ItemSelectBg
      end
    end
    item_data.nShowTime = tGiftCotent.ShowCountDown or 0
    item_data.SkipLoginDailyNeedUC = tGiftCotent.SkipLoginDailyNeedUC
    item_data.isSpecialItem = tGiftCotent.isSpecialItem or 0
    tGiftCfg[index] = item_data
  end
  for i, v in pairs(tGiftCfg) do
    local tData = tGiftData[i]
    tData.nConditionType = v.nConditionType
    tData.nConditionParam = v.nConditionParam
    tData.nGroupId = v.nGroupId
    tData.nGroupPosition = v.nGroupPosition
    tData.nPreGoodsId = v.nPreGoodsId
    tData.sGiftBoxIcon = v.sGiftBoxIcon
    tData.sGiftBg = v.sGiftBg
    tData.itemBg = v.itemBg
    tData.itemSelectBg = v.itemSelectBg
    tData.ActivityBgL = v.ActivityBgL
    tData.ActivityBgR = v.ActivityBgR
    tData.nShowTime = v.nShowTime or 0
    tData.SkipLoginDailyNeedUC = v.SkipLoginDailyNeedUC
    tData.isSpecialItem = v.isSpecialItem == 1 or false
  end
  return tGiftData
end
function logic_special_offer_condition:GetGiftsData()
  if not self.tConditionData and self.rawData then
    self:RawDataHanle()
  end
  return self.tConditionData
end
function logic_special_offer_condition:SetGiftsData(data)
  self.tConditionData = data
end
function logic_special_offer_condition:CheckGiftData()
  return self.rawData and next(self.rawData)
end
function logic_special_offer_condition:GetCountDown()
  local time = 0
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  local conditionData = self:GetGiftsData()
  for i, v in pairs(conditionData) do
    local preData
    if v[1] and logic_special_offer_condition:GetIsBuyPreGoods(v[1].nPreGoodsId) then
      preData = v[1]
    end
    local startTime = preData and preData.startTime or 0
    local endTime = preData and preData.endTime or 0
    if preData and 0 < preData.nShowTime and now >= startTime and now < endTime and (time == 0 or time > endTime) then
      time = endTime
    end
  end
  return time
end
function logic_special_offer_condition:IsInExpirationDate()
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  local conditionData = self:GetGiftsData()
  for _, v in pairs(conditionData) do
    local preData = {}
    if v[1] and self:GetIsBuyPreGoods(v[1].nPreGoodsId) then
      preData = v[1]
    end
    local startTime = preData and preData.startTime or 0
    local endTime = preData and preData.endTime or 0
    if now >= startTime and now < endTime then
      return true
    end
  end
  return false
end
function logic_special_offer_condition:GetImmediateGetDropIdListAfterBuy(tItemData, loginDay)
  local tDropIdList = {}
  local conditionData = self:GetGiftsData()
  if not conditionData then
    return tDropIdList
  end
  local groupId = tItemData.nGroupId
  local goodsId = tItemData.goodsId
  table.insert(tDropIdList, tItemData.itemId)
  for _, giftDatas in pairs(conditionData) do
    if giftDatas[1].nGroupId == groupId then
      local nLoginDays = self:GetLoginDays(groupId)
      for _, giftData in pairs(giftDatas) do
        local bFreeGiftData = giftData.limitNum ~= 0 and 0 < giftData.zero_uc
        local bFitLoginDays = nLoginDays >= giftData.nConditionParam or self:IsSkipLoginByGroupId(groupId)
        local bPreGoods = giftData.nPreGoodsId == goodsId
        if bFitLoginDays and bFreeGiftData and bPreGoods then
          table.insert(tDropIdList, giftData.itemId)
        end
      end
    end
  end
  return tDropIdList
end
function logic_special_offer_condition:GetGroupDropIdList()
  return self.tGroupIdToDropIdList
end
function logic_special_offer_condition:OnPageInfo(_, _, data)
  if data.tab_id ~= StoreConst.Page_Special_Material_Pack then
    return
  end
  self.rawData = data
  local queue_task_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.queue_task_module)
  local task = {
    module = self,
    funcName = "RawDataHanle",
    param = self,
    debugInfo = "logic_special_offer_condition",
    protect = true
  }
  queue_task_module:Enqueue(queue_task_module.TaskEnum.Lobby, task)
end
function logic_special_offer_condition:RawDataHanle()
  if not self.rawData or not next(self.rawData) then
    return
  end
  local tGiftsData = self:FilterConditionData(self.rawData.data[3])
  if not tGiftsData or not next(tGiftsData) then
    return
  end
  local tGiftsInfo = {}
  for _, value in pairs(tGiftsData) do
    local item_data = {}
    item_data.itemId = value[StoreConst.label_item_index_id]
    item_data.tabId = self.rawData.tab_id
    local price_list = value[StoreConst.label_item_index_price_list][1]
    item_data.goodsId = value[StoreConst.label_item_index_market_id] or 0
    if not price_list or not next(price_list) then
      log(bWriteLog and "goods price_list is nil " .. item_data.goodsId)
      return
    end
    item_data.originPrice = price_list[StoreConst.label_price_index_one_original_price]
    item_data.discountPrice = price_list[StoreConst.label_price_index_one_discount_price] or 0
    item_data.valid_hours = price_list[StoreConst.label_price_index_valid_hours] or 0
    item_data.discount = value[StoreConst.label_item_index_discount] or 0
    item_data.marketId = value[StoreConst.label_item_index_market_id] or 0
    item_data.itemNum = value[StoreConst.label_item_index_count] or 1
    item_data.priceType = price_list[StoreConst.label_price_index_price_type]
    item_data.limitType = next(value[StoreConst.label_item_index_buy_limit])
    item_data.startTime = value[StoreConst.label_item_index_start_time]
    item_data.endTime = value[StoreConst.label_item_index_time_limit]
    item_data.zero_uc = value[StoreConst.label_item_index_zero_uc_mark]
    item_data.limitNum = 1
    table.insert(tGiftsInfo, item_data)
  end
  self:SetGiftsData(tGiftsInfo)
  self:HandConditionGiftsData()
  self:GetPriceInfoReq()
  self:OnGetLoginDaysReq()
end
function logic_special_offer_condition:FilterConditionData(data)
  local sPath = self:GetConditionConfigPath()
  local _tGiftData = {}
  for goodsId, value in pairs(data) do
    local tGiftCotent = CDataTable.GetTableData(sPath, goodsId)
    if tGiftCotent then
      table.insert(_tGiftData, value)
    end
  end
  return _tGiftData
end
function logic_special_offer_condition:GetConditionConfigPath()
  local sPath = "ConditionGiftContent"
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local bIsJapanOrKorea = PublishRegionMacros.IsJapanOrKorea()
  local bIsBLUEHOLE = PublishRegionMacros.IsBLUEHOLE()
  if bIsJapanOrKorea then
    sPath = "ConditionGiftContentKJ"
  elseif bIsBLUEHOLE then
    sPath = "ConditionGiftContentIN"
  end
  return sPath
end
function logic_special_offer_condition:OnRefreshLimitBuyInfo()
  local limit_info = StoreConst.buy_info
  local giftsData = self:GetGiftsData()
  if not limit_info or not giftsData then
    return
  end
  for _, value in pairs(giftsData) do
    for _, data in pairs(value) do
      if limit_info[data.goodsId] then
        data.limitNum = 0
      end
    end
  end
end
function logic_special_offer_condition:GetIsBuyPreGoods(preGoodsId)
  if not preGoodsId or preGoodsId == 0 then
    return true
  end
  local limit_info = StoreConst.buy_info
  for key, _ in pairs(limit_info) do
    if key == preGoodsId then
      return true
    end
  end
  return false
end
function logic_special_offer_condition:OnRefreshGiftsData()
  if not self:GetGiftsData() then
    return
  end
  local cfg = require("client.slua.logic.specialoffer.special_offer_cfg")
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_CONDITION_DATA_REFRESH)
  EventSystem:postEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_SPECIAL_RED_CHANGE, cfg.ConditionsGift)
  local HasBuyAll = self:IsInExpirationDate()
  if HasBuyAll then
    EventSystem:postEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_SPECIAL_OFFER_REFRESH_PAGE)
  end
end
function logic_special_offer_condition:OnRefreshDircetPriceInfo(_, _, list)
  local giftsData = self:GetGiftsData()
  if not giftsData then
    return
  end
  log(bWriteLog and "logic_special_offer_condition:OnRefreshDircetPriceInfo  ")
  self.bIsDircetPriceRsp = true
  for _, value in pairs(giftsData) do
    for _, data in pairs(value) do
      if list[data.originPrice] then
        local price_data = list[data.originPrice]
        self.tDirectInfo[data.goodsId] = price_data
        local price = CentauriManager.GetPriceByProductId(price_data.productid, price_data.curency_unit, price_data.price, true)
        data.originPrice = price
        data.productid = price_data.productid
        data.curency_unit = price_data.curency_unit
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_CONDITION_PRICE_REFRESH)
end
function logic_special_offer_condition:CheckDircetPriceRsp()
  if self.bIsDircetPriceRsp then
    return
  end
  self:GetPriceInfoReq()
end
function logic_special_offer_condition:CheckMidasPriceData()
  local giftsData = self:GetGiftsData()
  if not giftsData then
    return
  end
  local sAllProductId = ""
  for _, value in pairs(giftsData) do
    for _, data in pairs(value) do
      if data.productid then
        if sAllProductId ~= "" then
          sAllProductId = sAllProductId .. ","
        end
        sAllProductId = sAllProductId .. data.productid
      end
    end
  end
  CentauriManager.LoadCachedCentauriProductInfo(sAllProductId)
end
function logic_special_offer_condition:OnLoadPriceDataCallback(_, _, resultCode)
  local giftsData = self:GetGiftsData()
  if not giftsData or not resultCode then
    log(bWriteLog and " logic_special_offer_condition:OnLoadPriceDataCallback return >>>> ")
    return
  end
  for _, value in pairs(giftsData) do
    for _, data in pairs(value) do
      local oldPrice = data.originPrice
      local price = CentauriManager.GetPriceByProductId(data.productid, data.curency_unit, oldPrice)
      data.originPrice = price
      log(bWriteLog and " OnLoadPriceDataCallback Update Price  >>>>> " .. tostring(oldPrice) .. " >>>> " .. tostring(price))
    end
  end
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_CONDITION_PRICE_REFRESH)
end
function logic_special_offer_condition:GetDirectInfo(goodsId)
  return self.tDirectInfo[goodsId]
end
function logic_special_offer_condition:OpenBuyPopup(itemData, titleId, descStr)
  local logic_coupon = require("client.slua.logic.coupon.logic_coupon")
  UIManager.ShowUI(UIManager.UI_Config.SpecialOffer_Material_Popup_UIBP, itemData, self.tDirectInfo[itemData.goodsId], titleId, descStr, logic_coupon._Enum_Scene._SpecialOfferCondition)
end
function logic_special_offer_condition:SortGiftsData()
  local giftsData = self:GetGiftsData()
  if not giftsData then
    return
  end
  local _HasBuyPreGood = function(v)
    local item_data = v
    if not item_data or not next(item_data) then
      return false
    end
    for _, v in pairs(item_data) do
      if v.nPreGoodsId == 0 and v.limitNum == 0 then
        return true
      end
    end
    return false
  end
  local _HasGetAll = function(v)
    local item_data = v
    if not item_data or not next(item_data) then
      return false
    end
    for _, v in pairs(item_data) do
      if v.limitNum > 0 then
        return false
      end
    end
    return true
  end
  local _GetGroupId = function(v)
    local item_data = v
    if not item_data or not next(item_data) then
      return 0
    end
    for _, v in pairs(item_data) do
      if 0 < v.nGroupId then
        return v.nGroupId
      end
    end
    return 0
  end
  table.sort(giftsData, function(a, b)
    local hasPreBuy_A = _HasBuyPreGood(a)
    local hasPreBuy_B = _HasBuyPreGood(b)
    local hasBuyAll_A = _HasGetAll(a)
    local hasBuyAll_B = _HasGetAll(b)
    local hasBuyPreAndNotFinish_A = hasPreBuy_A and hasBuyAll_A
    local hasBuyPreAndNotFinish_B = hasPreBuy_B and hasBuyAll_B
    if hasBuyPreAndNotFinish_A == hasBuyPreAndNotFinish_B then
      if hasPreBuy_A == hasPreBuy_B then
        local groupId_A = _GetGroupId(a)
        local groupId_B = _GetGroupId(b)
        if 0 < groupId_A and 0 < groupId_B then
          return groupId_A > groupId_B
        end
      else
        return hasPreBuy_A
      end
    else
      return not hasBuyPreAndNotFinish_A
    end
  end)
  for _, v in pairs(giftsData) do
    table.sort(v, function(a, b)
      if a.limitNum > b.limitNum then
        return true
      elseif a.limitNum == b.limitNum then
        return a.nGroupPosition < b.nGroupPosition
      end
      return false
    end)
  end
end
function logic_special_offer_condition:IsCanBuyGifts(tGiftData)
  local data = tGiftData or self:GetGiftsData()
  if not data then
    return
  end
  for _, v in pairs(data) do
    for _, value in pairs(v) do
      if type(value) ~= "table" then
        return
      end
      local bIsBuyPreGoods = self:GetIsBuyPreGoods(value.nPreGoodsId)
      if bIsBuyPreGoods and value.limitNum > 0 then
        local nLoginDays = self:GetLoginDays(value.nGroupId)
        if nLoginDays >= value.nConditionParam then
          return true
        end
      end
    end
  end
  return
end
function logic_special_offer_condition:IsCanGetAward()
  local data = self:GetGiftsData()
  if not data then
    return
  end
  local _HasBuyPreGood = function(v)
    local item_data = v
    if not item_data or not next(item_data) then
      return false
    end
    for _, v in pairs(item_data) do
      if v.nPreGoodsId == 0 and v.limitNum == 0 then
        return true
      end
    end
    return false
  end
  for _, v in pairs(data) do
    local bBuyFirst = _HasBuyPreGood(v)
    for _, value in pairs(v) do
      if type(value) ~= "table" then
        return
      end
      if bBuyFirst then
        local nLoginDays = self:GetLoginDays(value.nGroupId)
        if value.limitNum > 0 and nLoginDays >= value.nConditionParam and 0 < value.zero_uc then
          return true
        end
      end
    end
  end
end
function logic_special_offer_condition:OnGetLoginDaysReq()
  local ConditionGiftHandler = require("client.network.Protocol.ConditionGiftHandler")
  ConditionGiftHandler.send_get_cond_page_active_days_req()
end
function logic_special_offer_condition:GetPriceInfoReq()
  local Gifts_Const = require("client.slua.logic.specialoffer.special_offer_gifts_const")
  local Enum_PriceType = Gifts_Const.Enum_PriceType
  local req_id_list = {}
  local giftsData = self:GetGiftsData()
  if not giftsData then
    return
  end
  for _, value in pairs(giftsData) do
    for _, data in pairs(value) do
      if data.priceType == Enum_PriceType.Dollar then
        table.insert(req_id_list, data.originPrice)
      end
    end
  end
  local RechargePurchaseSystem = require("client.logic.recharge.logic_recharge_purchase")
  RechargePurchaseSystem.GetPurchaseInfoReq(req_id_list)
end
function logic_special_offer_condition:SetLoginDays(active_days, unlock_tbl)
  if not (active_days and next(active_days)) or not self:GetGiftsData() then
    return
  end
  self.tLoginDays = active_days
  self.tSkipLoginIdList = unlock_tbl or {}
end
function logic_special_offer_condition:IsHidePage()
  local aosShop = Client.GetAOSSHOP()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  local AOSSHOPMacros = require("client.slua.config.ClientMacros.AOSSHOPMacros")
  if Client.GetDevicePlatformName() == DevicePlatformNameMacros.Android and (aosShop == AOSSHOPMacros.Samsung or aosShop == AOSSHOPMacros.Amazon) then
    return true
  end
  return
end
function logic_special_offer_condition:GetLoginDays(nGroupId)
  local tConditionData = self:GetGiftsData()
  local tLoginDays = self.tLoginDays
  local nLoginDays = 1
  if not tConditionData or not tLoginDays then
    return nLoginDays
  end
  for _, v in pairs(tConditionData) do
    if v[1] and nGroupId == v[1].nGroupId then
      local start_time = v[1].startTime
      nLoginDays = tLoginDays[start_time] or 1
      break
    end
  end
  return nLoginDays
end
function logic_special_offer_condition:IsTaskComplete(groupId)
  if not groupId then
    log_error("logic_special_offer_condition:IsTaskComplete tSinglePackageData[1].nGroupId is nil")
    return false
  end
  local bIsSkipLogin = logic_special_offer_condition:IsSkipLoginByGroupId(groupId)
  if bIsSkipLogin then
    return true
  end
  local nLoginDays = self:GetLoginDays(groupId)
  local tConditionData = self:GetGiftsData()
  for _, taskData in pairs(tConditionData) do
    if taskData.nGroupId == groupId and nLoginDays < taskData.nConditionParam then
      return false
    end
  end
  return true
end
function logic_special_offer_condition:GetSkipLoginDailyNeedUC(groupId)
  if self.tSkipLoginNeedUC and self.tSkipLoginNeedUC[groupId] then
    return self.tSkipLoginNeedUC[groupId]
  end
  return 0
end
function logic_special_offer_condition:IsSkipLoginByGroupId(groupId)
  if not self.tSkipLoginIdList then
    return false
  end
  for _, id in pairs(self.tSkipLoginIdList) do
    if groupId == id then
      return true
    end
  end
  return false
end
function logic_special_offer_condition:UpdateSkipLoginIdList(group_id)
  log(bWriteLog and "logic_special_offer_condition:UpdateSkipLoginIdList  " .. group_id)
  table.insert(self.tSkipLoginIdList, group_id)
  ShowNotice(43931)
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_CONDITION_LOGIN_LIMIT_REFRESH)
end
function logic_special_offer_condition:ReqLoginDaysInfo()
  if not self.tLoginDays then
    self:OnGetLoginDaysReq()
  end
end
function logic_special_offer_condition:GetCooperationDropInfo(chestID)
  local reta = {}
  local itemCfg = CDataTable.GetTableData("Item", chestID)
  if itemCfg and itemCfg.RateType and itemCfg.RateType == 2 then
    reta = itemCfg
  end
  return reta
end
function logic_special_offer_condition:SetFirstChargeData(data)
  self:OnRefreshLimitBuyInfo()
  self:SortGiftsData()
  local Gifts_Const = require("client.slua.logic.specialoffer.special_offer_gifts_const")
  local GroupId = Gifts_Const.Enum_Condition_GiftGroup.FirstCharge
  local index
  for _, packageData in pairs(self.tConditionData) do
    if packageData[1] and packageData[1].nGroupId == GroupId then
      index = _
    end
  end
  if index then
    self.tConditionData[index] = data
  end
end
function logic_special_offer_condition:GetFirstChargeData()
  if not self.tConditionData then
    return
  end
  self:OnRefreshLimitBuyInfo()
  self:SortGiftsData()
  local Gifts_Const = require("client.slua.logic.specialoffer.special_offer_gifts_const")
  local GroupId = Gifts_Const.Enum_Condition_GiftGroup.FirstCharge
  for _, packageData in pairs(self.tConditionData) do
    if packageData[1] and packageData[1].nGroupId == GroupId then
      return packageData
    end
  end
end
function logic_special_offer_condition:IsCanShowFirstCharge()
  local tAllPackageData = self:GetGiftsData()
  local Gifts_Const = require("client.slua.logic.specialoffer.special_offer_gifts_const")
  local GroupId = Gifts_Const.Enum_Condition_GiftGroup.FirstCharge
  if not tAllPackageData then
    return false
  end
  local flag = false
  for _, PackageData in pairs(tAllPackageData) do
    if PackageData[1] and PackageData[1].nGroupId == GroupId then
      flag = true
    end
  end
  if not flag then
    return false
  end
  local PackageData = self:GetFirstChargeData()
  if not PackageData then
    return false
  end
  for i, v in pairs(PackageData) do
    if v.limitNum == 1 then
      return true
    end
  end
  return false
end
function logic_special_offer_condition:NotifyFITLobbyEntrance(tResult)
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if not PublishRegionMacros.IsFITVersion() then
    log(bWriteLog and "logic_special_offer_condition:NotifyFITLobbyEntrance. Isn't Fit")
    return
  end
  local Gifts_Const = require("client.slua.logic.specialoffer.special_offer_gifts_const")
  if tResult[Gifts_Const.Enum_Condition_GiftGroup.FirstCharge] then
    log(bWriteLog and "logic_special_offer_condition:NotifyFITLobbyEntrance. show the FirstCharge Entrance")
    EventSystem:postEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_SPECIAL_CONDITION_FIRST_CHARGE_DATA_UPDATE)
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CTemplate = class(CModuleBase, nil, logic_special_offer_condition)
return CTemplate