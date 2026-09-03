local SubscribeSystemGlobal = {}
function SubscribeSystemGlobal:DefineAndResetData()
  SubscribeSystemGlobal.__super.DefineAndResetData(self)
  self._Discount_Coupons_Data = {}
end
function SubscribeSystemGlobal:OnInitialize()
  SubscribeSystemGlobal.__super.OnInitialize(self)
  self._Super_Discount_Status = false
end
function SubscribeSystemGlobal:Set_Discount_Is_Take(istake)
  self._Super_Discount_Status = istake
end
function SubscribeSystemGlobal:CachedNormalDiscountStatus(prime_priv, SubId)
  local SubscribeEnumConfig = require("client.slua.logic.subscribe.logic_subscribe_enum_config")
  if SubId == SubscribeEnumConfig.ENUM_SubId.Super then
    if not prime_priv[SubscribeEnumConfig.ENUM_SubInfoID.DISCOUNT_ITEM] then
      return
    end
    self._Super_Discount_Status = prime_priv[SubscribeEnumConfig.ENUM_SubInfoID.DISCOUNT_ITEM].status or false
    return
  end
end
function SubscribeSystemGlobal:Get_Discount_Is_Could_Buy()
  log(bWriteLog and "self._Super_Discount_Status " .. tostring(self._Super_Discount_Status))
  return self._Super_Discount_Status
end
function SubscribeSystemGlobal:send_take_daily_uc_priv()
  local SubscribeHandler = require("client.network.Protocol.SubscribeHandler")
  SubscribeHandler.send_take_daily_uc_priv()
end
function SubscribeSystemGlobal:Get_Discount_Item_Info()
  local SubscribeEnumConfig = require("client.slua.logic.subscribe.logic_subscribe_enum_config")
  return self._SuperInfo._InfoList[SubscribeEnumConfig.ENUM_SubInfoID.DISCOUNT_ITEM]
end
function SubscribeSystemGlobal:send_buy_discount_sale_item(uniq_id)
  local SubscribeHandler = require("client.network.Protocol.SubscribeHandler")
  SubscribeHandler.send_buy_discount_sale_item(uniq_id)
end
function SubscribeSystemGlobal:HandleRegionData(SubId, prime_priv)
  local SubscribeEnumConfig = require("client.slua.logic.subscribe.logic_subscribe_enum_config")
  local CouponsData = prime_priv[SubscribeEnumConfig.ENUM_SubInfoID.DISCOUNT_COUPONS]
  if CouponsData then
    self._Discount_Coupons_Data[SubId] = CouponsData
    if CouponsData.status == true then
      self:CachedCouponsDataStatus(true)
    end
  end
end
function SubscribeSystemGlobal:CachedCouponsDataStatus(status)
  if self._Discount_Coupons_Data then
    self._Discount_Coupons_Data.  end
end
function SubscribeSystemGlobal:GetDiscountCouponsData()
  return self._Discount_Coupons_Data
end
function SubscribeSystemGlobal:LoadActivityDataPrice(SubId)
  log(bWriteLog and "LoadActivityDataPrice " .. tostring(SubId))
  local price = ""
  local productid = self:Get_SubProduct_ID(SubId)
  if not productid then
    log_error("No_This_ProductID")
    return nil
  end
  local SubscribeEnumConfig = require("client.slua.logic.subscribe.logic_subscribe_enum_config")
  local ENUM_SubId = SubscribeEnumConfig.ENUM_SubId
  if SubId == ENUM_SubId.Super then
    return self:Get_Price(ENUM_SubId.Super)
  end
  if self._Centauri_act_table_data and next(self._Centauri_act_table_data) then
    log_tree("SubscribeSystemGlobal._Centauri_table_data", self._Centauri_table_data)
    for i, product in pairs(self._Centauri_act_table_data) do
      if product.productId ~= nil and product.price ~= nil and productid == product.productId then
        price = product.price
        return price
      end
    end
  end
  if not self._ActivityData[SubId] or not self._ActivityData[SubId].prime_price then
    log_error("self._ActivityData")
    return nil
  end
  price = self._ActivityData[SubId].prime_price
  return price
end
function SubscribeSystemGlobal:GetRangeActivityPrice()
  local maxprice = ""
  local lowestprice = ""
  local copytable = {}
  if not self._ActivityData then
    log_error("no SubscribeSystemGlobal_ActivityData")
    return nil
  end
  for i, v in pairs(self._ActivityData) do
    v.SubId = i
    if v.SubId == 201 then
      v.price_order = 0
    end
    table.insert(copytable, v)
  end
  if not copytable or not next(copytable) then
    log_error("copy error")
    return nil
  end
  table.sort(copytable, function(a, b)
    if a.price_order == nil or b.price_order == nil then
      return false
    end
    return a.price_order < b.price_order
  end)
  maxprice = self:LoadActivityDataPrice(copytable[#copytable].SubId)
  if not self:GetIsInContinuousTime() then
    if self:Get_First_Month_Price() == "" then
      lowestprice = self:Get_Super_Price_NoMonth()
    else
      local SubscribeEnumConfig = require("client.slua.logic.subscribe.logic_subscribe_enum_config")
      local ENUM_SubId = SubscribeEnumConfig.ENUM_SubId
      lowestprice = self:Get_First_Month_Price(ENUM_SubId.Super)
    end
  else
    lowestprice = self:LoadActivityDataPrice(copytable[1].SubId)
  end
  return lowestprice .. " - " .. maxprice
end
function SubscribeSystemGlobal:LoadPrice()
  log(bWriteLog and "NewSubscribeSystem load price ")
  local SubscribeEnumConfig = require("client.slua.logic.subscribe.logic_subscribe_enum_config")
  local ENUM_SubId = SubscribeEnumConfig.ENUM_SubId
  if self:Get_SubProduct_ID(ENUM_SubId.Normal) ~= "" and self:Get_SubProduct_ID(ENUM_SubId.Super) ~= "" then
    local productid_str = self:MakeProductIdStr()
    log(bWriteLog and "SubscribeSystemGlobalproductid_str " .. tostring(productid_str))
    local isProductInfoCached, cachedProductInfoList = CentauriManager.LoadCachedCentauriIntroPrice(productid_str)
    if isProductInfoCached then
      log_tree("zino cachedProductInfoList", cachedProductInfoList)
      self:GetCentauriIntroInfo(EVENTTYPE_CENTAURI_NOTIFY, EVENTID_CENTAURI_GET_INTRO_PRICE_INFO_NOTIFY, cachedProductInfoList)
    else
      local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
      if PublishRegionMacros.IsCEVersion() then
        logic_connection_waiting:Show(1)
      end
      local funcCall1 = function()
        logic_connection_waiting:Hide(1)
      end
      local time_ticker = require("common.time_ticker")
      time_ticker.AddTimerOnce(20, funcCall1)
      log(bWriteLog and "LoadCentauriProductIntroInfo " .. productid_str)
      local logic_payment_api = require("client.logic.pay.logic_payment_api")
      logic_payment_api:load_Centauri_intro_price(productid_str, true)
    end
    local product_activity_str = self:MakeActivityProductIdStr()
    if product_activity_str and product_activity_str ~= "" then
      local isProductInfoCached2, cachedProductInfoList2 = CentauriManager.LoadCachedCentauriProductInfo(product_activity_str)
      if isProductInfoCached2 then
        log_tree("zino cachedProductInfoList2", cachedProductInfoList2)
        self:GetCentauriGoodsInfo(EVENTTYPE_CENTAURI_NOTIFY, EVENTID_CENTAURI_GET_SUBSCRIBE_PRODUCT_INFO_NOTIFY, cachedProductInfoList)
        local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
        if PublishRegionMacros.IsCEVersion() then
          logic_connection_waiting:Show(1)
        end
        local funcCall1 = function()
          logic_connection_waiting:Hide(1)
        end
        local time_ticker = require("common.time_ticker")
        time_ticker.AddTimerOnce(20, funcCall1)
        log(bWriteLog and "LoadCentauriProductIntroInfo2 " .. product_activity_str)
        local logic_payment_api = require("client.logic.pay.logic_payment_api")
        logic_payment_api:load_Centauri_product_info(product_activity_str, true)
      end
    end
  end
end
function SubscribeSystemGlobal:IsShowFirstMonthPrice()
  local SubscribeCarnivalSystem = require("client.slua.logic.subscribe.logic_subscribe_carnival_activity")
  local SubscribeEnumConfig = require("client.slua.logic.subscribe.logic_subscribe_enum_config")
  local ENUM_SubId = SubscribeEnumConfig.ENUM_SubId
  if SubscribeCarnivalSystem.IsActivityOpen() and not self:IsSubscribeContinous(ENUM_SubId.Super) then
    return true
  end
  return false
end
function SubscribeSystemGlobal:IsSetFirstBuyPrice(prime_type)
  local SubscribeEnumConfig = require("client.slua.logic.subscribe.logic_subscribe_enum_config")
  local ENUM_SubId = SubscribeEnumConfig.ENUM_SubId
  if prime_type == ENUM_SubId.Super then
    return self:IsShowFirstMonthPrice()
  end
  return false
end
local class = require("class")
local CSubscribeSystemBase = require("client.slua.logic.subscribe.logic_subscribe_base")
local CSubscribeSystemGlobal = class(CSubscribeSystemBase, nil, SubscribeSystemGlobal)
return CSubscribeSystemGlobal