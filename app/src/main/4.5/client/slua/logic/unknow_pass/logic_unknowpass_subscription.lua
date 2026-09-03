local UnknowPassPrimeSystem = {
  upass_prime_buy = {},
  upass_prime_privilege_cfg = {},
  upass_prime_info = {},
  continuous_awards_cfg = {},
  normalPrimeInfo = {},
  SuperPrimeInfo = {},
  gift_data = {},
  Enum_Prime_Type = {Normal = 1, Super = 2},
  Enum_Prime_Period = {
    Month = 1,
    Season = 2,
    Year = 3
  }
}
function UnknowPassPrimeSystem.HandlePrimeInfo(upass_prime_buy, upass_prime_privilege_cfg, continuous_awards_cfg, upass_prime_info, gift_data)
  log_tree("UnknowPassPrimeSystem.HandlePrimeInfo1 upass_prime_buy", upass_prime_buy)
  log_tree("UnknowPassPrimeSystem.HandlePrimeInfo2 upass_prime_privilege_cfg", upass_prime_privilege_cfg)
  log_tree("UnknowPassPrimeSystem.HandlePrimeInfo3 continuous_awards_cfg", continuous_awards_cfg)
  log_tree("UnknowPassPrimeSystem.HandlePrimeInfo4 upass_prime_info", upass_prime_info)
  log_tree("UnknowPassPrimeSystem.HandlePrimeInfo5 gift_data", gift_data)
  UnknowPassPrimeSystem.  UnknowPassPrimeSystem.normalPrimeInfo.BuyInfo = upass_prime_buy[1]
  UnknowPassPrimeSystem.SuperPrimeInfo.BuyInfo = upass_prime_buy[2]
  UnknowPassPrimeSystem.normalPrimeInfo.Continuous_Award = continuous_awards_cfg[1]
  UnknowPassPrimeSystem.SuperPrimeInfo.Continuous_Award = continuous_awards_cfg[2]
  UnknowPassPrimeSystem.normalPrimeInfo.UserData = upass_prime_info[1] or {}
  UnknowPassPrimeSystem.SuperPrimeInfo.UserData = upass_prime_info[2] or {}
  UnknowPassPrimeSystem.normalPrimeInfo.BuyInfo.month_prime_microprice = 4990000
  UnknowPassPrimeSystem.normalPrimeInfo.BuyInfo.season_prime_microprice = 14490000
  UnknowPassPrimeSystem.normalPrimeInfo.BuyInfo.year_prime_microprice = 55990000
  UnknowPassPrimeSystem.SuperPrimeInfo.BuyInfo.month_prime_microprice = 12490000
  UnknowPassPrimeSystem.SuperPrimeInfo.BuyInfo.season_prime_microprice = 35990000
  UnknowPassPrimeSystem.SuperPrimeInfo.BuyInfo.year_prime_microprice = 139990000
  UnknowPassPrimeSystem.  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_SUBSCRIPTION_INFO)
end
function UnknowPassPrimeSystem.LoadPrice()
  local productStr = UnknowPassPrimeSystem.MakeProductIdStr()
  local logic_payment_api = require("client.logic.pay.logic_payment_api")
  logic_payment_api:load_Centauri_intro_price(productStr, true)
end
function UnknowPassPrimeSystem.MakeProductIdStr()
  if not (UnknowPassPrimeSystem.normalPrimeInfo and UnknowPassPrimeSystem.SuperPrimeInfo and UnknowPassPrimeSystem.normalPrimeInfo.BuyInfo) or not UnknowPassPrimeSystem.SuperPrimeInfo.BuyInfo then
    return ""
  end
  local productStr = string.format("%s,%s,%s,%s,%s,%s", UnknowPassPrimeSystem.normalPrimeInfo.BuyInfo.month_prime_product_id, UnknowPassPrimeSystem.normalPrimeInfo.BuyInfo.season_prime_product_id, UnknowPassPrimeSystem.normalPrimeInfo.BuyInfo.year_prime_product_id, UnknowPassPrimeSystem.SuperPrimeInfo.BuyInfo.month_prime_product_id, UnknowPassPrimeSystem.SuperPrimeInfo.BuyInfo.season_prime_product_id, UnknowPassPrimeSystem.SuperPrimeInfo.BuyInfo.year_prime_product_id)
  return productStr
end
function UnknowPassPrimeSystem.GetCentauriIntroInfo(evenType, eventID, resultTable)
  if resultTable == nil then
    log(bWriteLog and "GetCentauriIntroInfo\232\175\187\229\143\150\230\149\176\230\141\174\229\164\177\232\180\165")
    logic_connection_waiting:Hide(1)
    return
  end
  log_tree("zino GetCentauriIntroInfo resultTable", resultTable)
  for k, product in pairs(resultTable) do
    if product.productId ~= nil and product.price ~= nil then
      if product.productId == UnknowPassPrimeSystem.normalPrimeInfo.BuyInfo.month_prime_product_id then
        log(bWriteLog and "product.Normalprice " .. product.price .. product.microprice)
        UnknowPassPrimeSystem.normalPrimeInfo.BuyInfo.month_prime_price = product.price
        UnknowPassPrimeSystem.normalPrimeInfo.BuyInfo.month_prime_microprice = product.microprice
        UnknowPassPrimeSystem.Set_First_Month_Discount_Price(UnknowPassPrimeSystem.Enum_Prime_Type.Normal, UnknowPassPrimeSystem.Enum_Prime_Period.Month, product.intro_price, product.currency)
      elseif product.productId == UnknowPassPrimeSystem.normalPrimeInfo.BuyInfo.season_prime_product_id then
        log(bWriteLog and "product.Normalprice " .. product.price .. product.microprice)
        UnknowPassPrimeSystem.normalPrimeInfo.BuyInfo.season_prime_price = product.price
        UnknowPassPrimeSystem.normalPrimeInfo.BuyInfo.season_prime_microprice = product.microprice
        UnknowPassPrimeSystem.Set_First_Month_Discount_Price(UnknowPassPrimeSystem.Enum_Prime_Type.Normal, UnknowPassPrimeSystem.Enum_Prime_Period.Season, product.intro_price, product.currency)
      elseif product.productId == UnknowPassPrimeSystem.normalPrimeInfo.BuyInfo.year_prime_product_id then
        log(bWriteLog and "product.Normalprice " .. product.price .. product.microprice)
        UnknowPassPrimeSystem.normalPrimeInfo.BuyInfo.year_prime_price = product.price
        UnknowPassPrimeSystem.normalPrimeInfo.BuyInfo.year_prime_microprice = product.microprice
        UnknowPassPrimeSystem.Set_First_Month_Discount_Price(UnknowPassPrimeSystem.Enum_Prime_Type.Normal, UnknowPassPrimeSystem.Enum_Prime_Period.Year, product.intro_price, product.currency)
      elseif product.productId == UnknowPassPrimeSystem.SuperPrimeInfo.BuyInfo.month_prime_product_id then
        log(bWriteLog and "product.Superprice " .. product.price .. product.microprice)
        UnknowPassPrimeSystem.SuperPrimeInfo.BuyInfo.month_prime_price = product.price
        UnknowPassPrimeSystem.SuperPrimeInfo.BuyInfo.month_prime_microprice = product.microprice
        UnknowPassPrimeSystem.Set_First_Month_Discount_Price(UnknowPassPrimeSystem.Enum_Prime_Type.Super, UnknowPassPrimeSystem.Enum_Prime_Period.Month, product.intro_price, product.currency)
      elseif product.productId == UnknowPassPrimeSystem.SuperPrimeInfo.BuyInfo.season_prime_product_id then
        log(bWriteLog and "product.Superprice " .. product.price .. product.microprice)
        UnknowPassPrimeSystem.SuperPrimeInfo.BuyInfo.season_prime_price = product.price
        UnknowPassPrimeSystem.SuperPrimeInfo.BuyInfo.season_prime_microprice = product.microprice
        UnknowPassPrimeSystem.Set_First_Month_Discount_Price(UnknowPassPrimeSystem.Enum_Prime_Type.Super, UnknowPassPrimeSystem.Enum_Prime_Period.Season, product.intro_price, product.currency)
      elseif product.productId == UnknowPassPrimeSystem.SuperPrimeInfo.BuyInfo.year_prime_product_id then
        log(bWriteLog and "product.Superprice " .. product.price .. product.microprice)
        UnknowPassPrimeSystem.SuperPrimeInfo.BuyInfo.year_prime_price = product.price
        UnknowPassPrimeSystem.SuperPrimeInfo.BuyInfo.year_prime_microprice = product.microprice
        UnknowPassPrimeSystem.Set_First_Month_Discount_Price(UnknowPassPrimeSystem.Enum_Prime_Type.Super, UnknowPassPrimeSystem.Enum_Prime_Period.Year, product.intro_price, product.currency)
      end
    else
      log(bWriteLog and "GetCentauriGoodsInfo \230\139\137\229\143\150\230\149\176\230\141\174\229\164\177\232\180\165")
      logic_connection_waiting:Hide(1)
    end
  end
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_SUBSCRIPTION_PRICEINFO)
  logic_connection_waiting:Hide(1)
end
function UnknowPassPrimeSystem.GetCentauriIntroInfoFromCache(evenType, eventID, resultCode)
  log(bWriteLog and "UnknowPassPrimeSystem.GetCentauriIntroInfoFromCache " .. tostring(resultCode))
  if resultCode then
    local productid_str = UnknowPassPrimeSystem.MakeProductIdStr()
    local isProductInfoCached, cachedProductInfoList = CentauriManager.LoadCachedCentauriIntroPrice(productid_str)
    if isProductInfoCached then
      log_tree("zino cachedProductInfoList", cachedProductInfoList)
      UnknowPassPrimeSystem.GetCentauriIntroInfo(evenType, eventID, cachedProductInfoList)
    else
      log(bWriteLog and "no reason to go here if go here find alex")
    end
  end
  logic_connection_waiting:Hide(1)
end
function UnknowPassPrimeSystem.Set_First_Month_Discount_Price(prime_type, price_type, intro_price, currency)
  log(bWriteLog and "v_wllwu UnknowPassPrimeSystem.Set_First_Month_Discount_Price\239\188\154" .. "prime_type" .. tostring(prime_type) .. "price_type" .. tostring(price_type) .. "intro_price" .. tostring(intro_price) .. "currency" .. tostring(currency))
  if not (prime_type and price_type) or not currency then
    return
  end
  if prime_type == UnknowPassPrimeSystem.Enum_Prime_Type.Normal then
    if price_type == UnknowPassPrimeSystem.Enum_Prime_Period.Month then
      UnknowPassPrimeSystem.normalPrimeInfo.BuyInfo.month_discount_CentauriPrice = intro_price
    elseif price_type == UnknowPassPrimeSystem.Enum_Prime_Period.Season then
      UnknowPassPrimeSystem.normalPrimeInfo.BuyInfo.season_discount_CentauriPrice = intro_price
    elseif price_type == UnknowPassPrimeSystem.Enum_Prime_Period.Year then
      UnknowPassPrimeSystem.normalPrimeInfo.BuyInfo.year_discount_CentauriPrice = intro_price
    end
  end
  if prime_type == UnknowPassPrimeSystem.Enum_Prime_Type.Super then
    if price_type == UnknowPassPrimeSystem.Enum_Prime_Period.Month then
      UnknowPassPrimeSystem.SuperPrimeInfo.BuyInfo.month_discount_CentauriPrice = intro_price
    elseif price_type == UnknowPassPrimeSystem.Enum_Prime_Period.Season then
      UnknowPassPrimeSystem.SuperPrimeInfo.BuyInfo.season_discount_CentauriPrice = intro_price
    elseif price_type == UnknowPassPrimeSystem.Enum_Prime_Period.Year then
      UnknowPassPrimeSystem.SuperPrimeInfo.BuyInfo.year_discount_CentauriPrice = intro_price
    end
  end
end
function UnknowPassPrimeSystem.ShowSubScriptionUI()
end
function UnknowPassPrimeSystem.CentauriBuy(product_id)
  if not product_id then
    log_error("CentauriBuy no subid")
    return
  end
  local subscribeStoreInfo = CentauriManager.LoadCachedSubscribeStoreInfo(product_id)
  local instance = require("client.logic.pay.logic_payment_api")
  log(bWriteLog and "UnknowPassPrimeSystem.CentauriBuy " .. tostring(product_id))
  if product_id == UnknowPassPrimeSystem.normalPrimeInfo.BuyInfo.month_prime_product_id then
    instance:Subscribe(product_id, 31, "US", "USD", "PUBGMRP", "PUBGMRP", true, subscribeStoreInfo.basePlanId, subscribeStoreInfo.gwOfferId)
  elseif product_id == UnknowPassPrimeSystem.normalPrimeInfo.BuyInfo.season_prime_product_id then
    instance:Subscribe(product_id, 93, "US", "USD", "PUBGMRP", "PUBGMRP", true, subscribeStoreInfo.basePlanId, subscribeStoreInfo.gwOfferId)
  elseif product_id == UnknowPassPrimeSystem.normalPrimeInfo.BuyInfo.year_prime_product_id then
    instance:Subscribe(product_id, 372, "US", "USD", "PUBGMRP", "PUBGMRP", true, subscribeStoreInfo.basePlanId, subscribeStoreInfo.gwOfferId)
  elseif product_id == UnknowPassPrimeSystem.SuperPrimeInfo.BuyInfo.month_prime_product_id then
    instance:Subscribe(product_id, 31, "US", "USD", "PUBGMRPP", "PUBGMRPP", true, subscribeStoreInfo.basePlanId, subscribeStoreInfo.gwOfferId)
  elseif product_id == UnknowPassPrimeSystem.SuperPrimeInfo.BuyInfo.season_prime_product_id then
    instance:Subscribe(product_id, 93, "US", "USD", "PUBGMRPP", "PUBGMRPP", true, subscribeStoreInfo.basePlanId, subscribeStoreInfo.gwOfferId)
  elseif product_id == UnknowPassPrimeSystem.SuperPrimeInfo.BuyInfo.year_prime_product_id then
    instance:Subscribe(product_id, 372, "US", "USD", "PUBGMRPP", "PUBGMRPP", true, subscribeStoreInfo.basePlanId, subscribeStoreInfo.gwOfferId)
  end
end
function UnknowPassPrimeSystem.SwitchBuy(product_id, preProduct_id)
  if not product_id then
    log_error("CentauriBuy no subid")
    return
  end
  local subscribeStoreInfo = CentauriManager.LoadCachedSubscribeStoreInfo(product_id)
  local instance = require("client.logic.pay.logic_payment_api")
  log(bWriteLog and "UnknowPassPrimeSystem.CentauriBuy " .. tostring(product_id))
  if product_id == UnknowPassPrimeSystem.normalPrimeInfo.BuyInfo.month_prime_product_id then
    instance:ModifySubscribe(preProduct_id, product_id, 31, "US", "USD", "PUBGMRP", "PUBGMRP", true, subscribeStoreInfo.basePlanId, subscribeStoreInfo.gwOfferId)
  elseif product_id == UnknowPassPrimeSystem.normalPrimeInfo.BuyInfo.season_prime_product_id then
    instance:ModifySubscribe(preProduct_id, product_id, 93, "US", "USD", "PUBGMRP", "PUBGMRP", true, subscribeStoreInfo.basePlanId, subscribeStoreInfo.gwOfferId)
  elseif product_id == UnknowPassPrimeSystem.normalPrimeInfo.BuyInfo.year_prime_product_id then
    instance:ModifySubscribe(preProduct_id, product_id, 372, "US", "USD", "PUBGMRP", "PUBGMRP", true, subscribeStoreInfo.basePlanId, subscribeStoreInfo.gwOfferId)
  elseif product_id == UnknowPassPrimeSystem.SuperPrimeInfo.BuyInfo.month_prime_product_id then
    instance:ModifySubscribe(preProduct_id, product_id, 31, "US", "USD", "PUBGMRPP", "PUBGMRPP", true, subscribeStoreInfo.basePlanId, subscribeStoreInfo.gwOfferId)
  elseif product_id == UnknowPassPrimeSystem.SuperPrimeInfo.BuyInfo.season_prime_product_id then
    instance:ModifySubscribe(preProduct_id, product_id, 93, "US", "USD", "PUBGMRPP", "PUBGMRPP", true, subscribeStoreInfo.basePlanId, subscribeStoreInfo.gwOfferId)
  elseif product_id == UnknowPassPrimeSystem.SuperPrimeInfo.BuyInfo.year_prime_product_id then
    instance:ModifySubscribe(preProduct_id, product_id, 372, "US", "USD", "PUBGMRPP", "PUBGMRPP", true, subscribeStoreInfo.basePlanId, subscribeStoreInfo.gwOfferId)
  end
end
function UnknowPassPrimeSystem.CheckAlreadySubScribed(type)
  local UserData
  if type == 1 then
    UserData = UnknowPassPrimeSystem.normalPrimeInfo.UserData
  else
    UserData = UnknowPassPrimeSystem.SuperPrimeInfo.UserData
  end
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  local startTime = 0
  local endTime = 0
  if UserData and next(UserData) ~= nil then
    startTime = UserData.begin_time
    endTime = UserData.end_time
  else
    return false
  end
  if curTime <= endTime and curTime >= startTime then
    return true
  else
    return false
  end
end
function UnknowPassPrimeSystem.GetIsSubscribedContinue(type)
  if not UnknowPassPrimeSystem.CheckAlreadySubScribed(type) then
    return false
  end
  local UserData
  if type == UnknowPassPrimeSystem.Enum_Prime_Type.Normal then
    UserData = UnknowPassPrimeSystem.normalPrimeInfo.UserData
  elseif type == UnknowPassPrimeSystem.Enum_Prime_Type.Super then
    UserData = UnknowPassPrimeSystem.SuperPrimeInfo.UserData
  end
  log(bWriteLog and "GetIsSubscribedContinue UserDataType = " .. tostring(type))
  if not (UserData and UserData.productid) or UserData.productid == "" then
    log(bWriteLog and "UnknowPassPrimeSystem.GetIsSubscribedContinue productid = nil")
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  log(bWriteLog and "GetIsSubscribedContinue curTime = " .. tostring(curTime))
  local startTime = 0
  local endTime = 0
  if UserData and next(UserData) ~= nil then
    startTime = UserData.Centauri_begin_time or 0
    endTime = UserData.Centauri_end_time or 0
    log(bWriteLog and "UnknowPassPrimeSystem.GetIsSubscribedContinue\239\188\154" .. " startCentauriTime = " .. tostring(startTime) .. " endCentauriTime = " .. tostring(endTime))
    if curTime < endTime and curTime >= startTime then
      log(bWriteLog and "UnknowPassPrimeSystem.GetIsSubscribedContinue true")
      return true
    end
  end
  return false
end
function UnknowPassPrimeSystem.CheckIsBuyPrimeGift(type)
  local UserData
  if type == UnknowPassPrimeSystem.Enum_Prime_Type.Normal then
    UserData = UnknowPassPrimeSystem.normalPrimeInfo.UserData
  elseif type == UnknowPassPrimeSystem.Enum_Prime_Type.Super then
    UserData = UnknowPassPrimeSystem.SuperPrimeInfo.UserData
  end
  if UserData and next(UserData) ~= nil then
    if not UserData.productid or UserData.productid == "" then
      log(bWriteLog and "UnknowPassPrimeSystem UserData.productid = null")
      return true
    end
    local startCentauriTime = UserData.Centauri_begin_time or 0
    local endCentauriTime = UserData.Centauri_end_time or 0
    local startTime = UserData.begin_time or 0
    local endTime = UserData.end_time or 0
    local TimeUtil = require("client.common.time_util")
    local curTime = TimeUtil.GetServerTimeInSec()
    log(bWriteLog and "CheckIsBuyPrimeGift curTime = " .. tostring(curTime) .. " endTime = " .. tostring(endTime) .. " startTime = " .. tostring(startTime) .. " endCentauriTime = " .. tostring(endCentauriTime) .. " startCentauriTime = " .. tostring(startCentauriTime))
    local intervalTime = 1728000
    local intervalTime_2 = 432000
    if endTime > curTime and startTime <= curTime and (intervalTime < endTime - endCentauriTime or intervalTime_2 < startCentauriTime - startTime) then
      return true
    end
  end
  return false
end
function UnknowPassPrimeSystem.CheckLastPlatformMatch(type)
  local UserData
  if type == 1 then
    UserData = UnknowPassPrimeSystem.normalPrimeInfo.UserData
  else
    UserData = UnknowPassPrimeSystem.SuperPrimeInfo.UserData
  end
  if UserData and next(UserData) ~= nil then
    log_tree("UnknowPassPrimeSystem.CheckLastPlatformMatch", UserData)
    local strPlatform = Client.GetDevicePlatformName()
    local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
    if strPlatform == DevicePlatformNameMacros.IOS and UserData.pay_channel == "gwallet" then
      return false
    end
    if strPlatform == DevicePlatformNameMacros.Android and UserData.pay_channel == SInAppPurchase then
      return false
    end
  end
  return true
end
function UnknowPassPrimeSystem.CheckMonthReddot()
  if UnknowPassPrimeSystem.CheckAlreadySubScribed(1) and UnknowPassPrimeSystem.normalPrimeInfo.BuyInfo then
    for i, v in ipairs(UnknowPassPrimeSystem.normalPrimeInfo.BuyInfo.privilege_list) do
      local AwardData = UnknowPassPrimeSystem.normalPrimeInfo.UserData
      if AwardData and next(AwardData) ~= nil and AwardData.month_awards[v] == 0 then
        return true
      end
    end
  end
  if UnknowPassPrimeSystem.CheckAlreadySubScribed(2) and UnknowPassPrimeSystem.SuperPrimeInfo.BuyInfo then
    for i, v in ipairs(UnknowPassPrimeSystem.SuperPrimeInfo.BuyInfo.privilege_list) do
      local AwardData = UnknowPassPrimeSystem.SuperPrimeInfo.UserData
      if AwardData and next(AwardData) ~= nil and AwardData.month_awards[v] == 0 then
        return true
      end
    end
  end
  return false
end
function UnknowPassPrimeSystem.CheckContinuousReddot()
  if UnknowPassPrimeSystem.normalPrimeInfo.Continuous_Award then
    for k, v in pairs(UnknowPassPrimeSystem.normalPrimeInfo.Continuous_Award) do
      local AwardData = UnknowPassPrimeSystem.normalPrimeInfo.UserData
      if AwardData and next(AwardData) ~= nil and AwardData.continuous_awards[k] == 0 then
        return true
      end
    end
  end
  if UnknowPassPrimeSystem.SuperPrimeInfo.Continuous_Award then
    for k, v in pairs(UnknowPassPrimeSystem.SuperPrimeInfo.Continuous_Award) do
      local AwardData = UnknowPassPrimeSystem.SuperPrimeInfo.UserData
      if AwardData and next(AwardData) ~= nil and AwardData.continuous_awards[k] == 0 then
        return true
      end
    end
  end
  return false
end
function UnknowPassPrimeSystem.GetCanGetMonthAwardList()
  local res = {}
  if UnknowPassPrimeSystem.CheckAlreadySubScribed(1) and UnknowPassPrimeSystem.normalPrimeInfo.BuyInfo then
    for i, v in ipairs(UnknowPassPrimeSystem.normalPrimeInfo.BuyInfo.privilege_list) do
      local AwardData = UnknowPassPrimeSystem.normalPrimeInfo.UserData
      if AwardData and next(AwardData) ~= nil and AwardData.month_awards[v] == 0 then
        local info = UnknowPassPrimeSystem.upass_prime_privilege_cfg[v]
        local ItemQuality = CDataTable.GetTableData("Item", tonumber(info.param1)).ItemQuality
        table.insert(res, {
          itemId = tonumber(info.param1),
          itemCount = tonumber(info.param2),
                  })
      end
    end
  end
  if UnknowPassPrimeSystem.CheckAlreadySubScribed(2) and UnknowPassPrimeSystem.SuperPrimeInfo.BuyInfo then
    for i, v in ipairs(UnknowPassPrimeSystem.SuperPrimeInfo.BuyInfo.privilege_list) do
      local AwardData = UnknowPassPrimeSystem.SuperPrimeInfo.UserData
      if AwardData and next(AwardData) ~= nil then
        local info = UnknowPassPrimeSystem.upass_prime_privilege_cfg[v]
        if info.privilege_type == 1 and AwardData.month_awards[v] == 0 or info.privilege_type == 3 and AwardData.first_awards[v] == 0 then
          local ItemQuality = CDataTable.GetTableData("Item", tonumber(info.param1)).ItemQuality
          table.insert(res, {
            itemId = tonumber(info.param1),
            itemCount = tonumber(info.param2),
                      })
        end
      end
    end
  end
  return res
end
function UnknowPassPrimeSystem.GetCanGetContinuousAwardList()
  local res = {}
  local UIUtil = require("client.common.ui_util")
  if UnknowPassPrimeSystem.normalPrimeInfo.Continuous_Award then
    for k, v in pairs(UnknowPassPrimeSystem.normalPrimeInfo.Continuous_Award) do
      local AwardData = UnknowPassPrimeSystem.normalPrimeInfo.UserData
      if AwardData and next(AwardData) ~= nil and AwardData.continuous_awards[k] == 0 then
        local iconPath = UIUtil.GetItemSmallIcon(tonumber(v.resid))
        local ItemQuality = CDataTable.GetTableData("Item", tonumber(v.resid)).ItemQuality
        table.insert(res, {
          itemId = tonumber(v.resid),
          itemCount = tonumber(v.count),
                  })
      end
    end
  end
  if UnknowPassPrimeSystem.SuperPrimeInfo.Continuous_Award then
    for k, v in pairs(UnknowPassPrimeSystem.SuperPrimeInfo.Continuous_Award) do
      local AwardData = UnknowPassPrimeSystem.SuperPrimeInfo.UserData
      if AwardData and next(AwardData) ~= nil and AwardData.continuous_awards[k] == 0 then
        local iconPath = UIUtil.GetItemSmallIcon(tonumber(v.resid))
        local ItemQuality = CDataTable.GetTableData("Item", tonumber(v.resid)).ItemQuality
        table.insert(res, {
          itemId = tonumber(v.resid),
          itemCount = tonumber(v.count),
                  })
      end
    end
  end
  return res
end
function UnknowPassPrimeSystem.GetSubSubscribedType(product_id)
  if product_id == UnknowPassPrimeSystem.normalPrimeInfo.BuyInfo.month_prime_product_id then
    return 1
  elseif product_id == UnknowPassPrimeSystem.normalPrimeInfo.BuyInfo.season_prime_product_id then
    return 2
  elseif product_id == UnknowPassPrimeSystem.normalPrimeInfo.BuyInfo.year_prime_product_id then
    return 3
  elseif product_id == UnknowPassPrimeSystem.SuperPrimeInfo.BuyInfo.month_prime_product_id then
    return 1
  elseif product_id == UnknowPassPrimeSystem.SuperPrimeInfo.BuyInfo.season_prime_product_id then
    return 2
  elseif product_id == UnknowPassPrimeSystem.SuperPrimeInfo.BuyInfo.year_prime_product_id then
    return 3
  end
end
function UnknowPassPrimeSystem.GetSubscribeDiscountPrice(prime_type, price_type)
  if prime_type and price_type then
    local buyInfo
    if prime_type == UnknowPassPrimeSystem.Enum_Prime_Type.Normal then
      buyInfo = UnknowPassPrimeSystem.normalPrimeInfo.BuyInfo
    elseif prime_type == UnknowPassPrimeSystem.Enum_Prime_Type.Super then
      buyInfo = UnknowPassPrimeSystem.SuperPrimeInfo.BuyInfo
    end
    if UnknowPassPrimeSystem.GetIsSubscribedContinue(prime_type) then
      return
    end
    if buyInfo then
      local discount_price_cfg = ""
      local discount_Centauri_price = ""
      if price_type == UnknowPassPrimeSystem.Enum_Prime_Period.Month then
        discount_price_cfg = buyInfo.month_discount_price
        discount_Centauri_price = buyInfo.month_discount_CentauriPrice
      elseif price_type == UnknowPassPrimeSystem.Enum_Prime_Period.Season then
        discount_price_cfg = buyInfo.season_discount_price
        discount_Centauri_price = buyInfo.season_discount_CentauriPrice
      elseif price_type == UnknowPassPrimeSystem.Enum_Prime_Period.Year then
        discount_price_cfg = buyInfo.year_discount_price
        discount_Centauri_price = buyInfo.year_discount_CentauriPrice
      end
      local SubscribeCarnivalSystem = require("client.slua.logic.subscribe.logic_subscribe_carnival_activity")
      if SubscribeCarnivalSystem.IsActivityOpen() and discount_price_cfg and discount_price_cfg ~= "" then
        return discount_Centauri_price or ""
      end
    end
  end
  return ""
end
function UnknowPassPrimeSystem.GetSubscribePrice(prime_type, price_type)
  if prime_type and price_type then
    local buyInfo
    if prime_type == UnknowPassPrimeSystem.Enum_Prime_Type.Normal then
      buyInfo = UnknowPassPrimeSystem.normalPrimeInfo.BuyInfo
    elseif prime_type == UnknowPassPrimeSystem.Enum_Prime_Type.Super then
      buyInfo = UnknowPassPrimeSystem.SuperPrimeInfo.BuyInfo
    end
    if buyInfo then
      if price_type == UnknowPassPrimeSystem.Enum_Prime_Period.Month then
        return buyInfo.month_prime_price
      elseif price_type == UnknowPassPrimeSystem.Enum_Prime_Period.Season then
        return buyInfo.season_prime_price
      elseif price_type == UnknowPassPrimeSystem.Enum_Prime_Period.Year then
        return buyInfo.year_prime_price
      end
    end
  end
  return ""
end
function UnknowPassPrimeSystem.GetSubscribeShowPrice(prime_type, price_type)
  local discount_price = UnknowPassPrimeSystem.GetSubscribeDiscountPrice(prime_type, price_type)
  if discount_price and discount_price ~= "" then
    return discount_price
  end
  return UnknowPassPrimeSystem.GetSubscribePrice(prime_type, price_type) or ""
end
function UnknowPassPrimeSystem.JumpCarnival()
  local SubscribeCarnivalSystem = require("client.slua.logic.subscribe.logic_subscribe_carnival_activity")
  SubscribeCarnivalSystem.JumpToMainUI()
end
function UnknowPassPrimeSystem.upass_prime_query_rsp(upass_prime_buy, upass_prime_privilege_cfg, continuous_awards_cfg, upass_prime_info, gift_data)
  UnknowPassPrimeSystem.HandlePrimeInfo(upass_prime_buy, upass_prime_privilege_cfg, continuous_awards_cfg, upass_prime_info, gift_data)
end
function UnknowPassPrimeSystem.upass_prime_take_continuous_award_rsp(err_code, award)
  if err_code ~= 0 then
  elseif award then
    local arrayItemList = {}
    for k, v in pairs(award) do
      table.insert(arrayItemList, {res_id = k, count = v})
    end
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_RPRewardGet(arrayItemList)
  end
end
function UnknowPassPrimeSystem.upass_prime_take_month_award_rsp(err_code, award)
  if err_code ~= 0 then
  elseif award then
    local arrayItemList = {}
    for k, v in pairs(award) do
      table.insert(arrayItemList, {res_id = k, count = v})
    end
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_RPRewardGet(arrayItemList)
  end
end
function UnknowPassPrimeSystem.upass_prime_take_first_award_rsp(err_code, award)
  if err_code ~= 0 then
  elseif award then
    local arrayItemList = {}
    for k, v in pairs(award) do
      table.insert(arrayItemList, {res_id = k, count = v})
    end
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_RPRewardGet(arrayItemList)
  end
end
function UnknowPassPrimeSystem.upass_prime_info_change_notify(prime_data)
  log_tree("UnknowPassSystem.upass_prime_info_change_notify ", prime_data)
  local UnknowPassPrimeSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_subscription")
  if prime_data and prime_data.type == 1 then
    UnknowPassPrimeSystem.normalPrimeInfo = UnknowPassPrimeSystem.normalPrimeInfo or {}
    UnknowPassPrimeSystem.normalPrimeInfo.UserData = prime_data
  elseif prime_data and prime_data.type == 2 then
    UnknowPassPrimeSystem.SuperPrimeInfo = UnknowPassPrimeSystem.SuperPrimeInfo or {}
    UnknowPassPrimeSystem.SuperPrimeInfo.UserData = prime_data
  end
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_SUBSCRIPTION_INFO)
  local passReddotMainSystem = require("client.slua.logic.unknow_pass.NewRPPreview.unknowpass_reddot_main")
  passReddotMainSystem.UpdateReddot()
end
function UnknowPassPrimeSystem.CheckSubScriptionOpen()
  local HasSubScribed = UnknowPassPrimeSystem.CheckAlreadySubScribed(1) or UnknowPassPrimeSystem.CheckAlreadySubScribed(2)
  local strPlatform = Client.GetDevicePlatformName()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if strPlatform == DevicePlatformNameMacros.IOS and not LobbySystem.CheckOpen(BP_ENUM_PASS_SUBSCRIBE_IOS_ALL) then
    return false
  elseif strPlatform == DevicePlatformNameMacros.Android and not LobbySystem.CheckOpen(BP_ENUM_PASS_SUBSCRIBE_GOOGLE_ALL) then
    return false
  elseif strPlatform == DevicePlatformNameMacros.IOS and not LobbySystem.CheckOpen(BP_ENUM_PASS_SUBSCRIBE_IOS) and not HasSubScribed then
    return false
  elseif strPlatform == DevicePlatformNameMacros.Android and not LobbySystem.CheckOpen(BP_ENUM_PASS_SUBSCRIBE_GOOGLE) and not HasSubScribed then
    return false
  end
  if HasSubScribed then
    return true
  end
  local AOSSHOPMacros = require("client.slua.config.ClientMacros.AOSSHOPMacros")
  local logic_subscribe_handler = require("client.slua.logic.subscribe.logic_subscribe_handler")
  local subscribeModuleObj = logic_subscribe_handler.GetSubscribeModuleObj()
  local nAOSSHOP = Client.GetAOSSHOP()
  if nAOSSHOP == AOSSHOPMacros.Samsung or nAOSSHOP == AOSSHOPMacros.Amazon or nAOSSHOP == AOSSHOPMacros.HMS and not subscribeModuleObj:HMSIsOpenSubscribe() then
    return false
  end
  local logic_multiple_area = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_multiple_area)
  local isRussiaArea = logic_multiple_area:IsConnectToRussiaArea()
  if isRussiaArea then
    return false
  end
  return true
end
function UnknowPassPrimeSystem.CheckSubScriptionOpenOnPlatForm()
  local strPlatform = Client.GetDevicePlatformName()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if strPlatform == DevicePlatformNameMacros.IOS and not LobbySystem.CheckOpen(BP_ENUM_PASS_SUBSCRIBE_IOS) then
    return false
  elseif strPlatform == DevicePlatformNameMacros.Android and not LobbySystem.CheckOpen(BP_ENUM_PASS_SUBSCRIBE_GOOGLE) then
    return false
  end
  local AOSSHOPMacros = require("client.slua.config.ClientMacros.AOSSHOPMacros")
  local logic_subscribe_handler = require("client.slua.logic.subscribe.logic_subscribe_handler")
  local subscribeModuleObj = logic_subscribe_handler.GetSubscribeModuleObj()
  local nAOSSHOP = Client.GetAOSSHOP()
  if nAOSSHOP == AOSSHOPMacros.Samsung or nAOSSHOP == AOSSHOPMacros.Amazon or nAOSSHOP == AOSSHOPMacros.HMS and not subscribeModuleObj:HMSIsOpenSubscribe() then
    return false
  end
  return true
end
function UnknowPassPrimeSystem.GetNeedPrice01ByDiscount(itemInfo)
  local UnknowPassExchangeSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_exchange")
  local hasSubscribed = UnknowPassExchangeSystem.SetHasSubScribed()
  if hasSubscribed and itemInfo.cost_item_id == 1099 then
    local rate = UnknowPassPrimeSystem.GetDiscountRate()
    return itemInfo.ori_disc_num * rate
  end
  return itemInfo.disc_cost_item_num
end
function UnknowPassPrimeSystem.GetNeedPrice02ByDiscount(itemInfo)
  local UnknowPassExchangeSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_exchange")
  local hasSubscribed = UnknowPassExchangeSystem.SetHasSubScribed()
  if hasSubscribed and itemInfo.cost_item_id_2 == 1099 then
    local rate = UnknowPassPrimeSystem.GetDiscountRate()
    return itemInfo.ori_disc_num_2 * rate
  end
  return itemInfo.disc_cost_item_num_2
end
function UnknowPassPrimeSystem.GetDiscountRate()
  local percent_discount = UnknowPassSystem.nDiscount
  local SubscribeCarnivalSystem = require("client.slua.logic.subscribe.logic_subscribe_carnival_activity")
  if SubscribeCarnivalSystem.IsActivityOpen() and SubscribeCarnivalSystem.IsBothPrime() then
    local extra_discount = SubscribeCarnivalSystem.GetRPPrimeDiscount()
    percent_discount = percent_discount - extra_discount
  end
  return percent_discount
end
return UnknowPassPrimeSystem