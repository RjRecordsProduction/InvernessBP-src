local StoreUtils = require("client.slua.logic.store.utils.store_utils_config")
local needCheckMoneyType = {
  [StoreConst.Page_New_ID_Cloth] = {reserveJump = false},
  [StoreConst.Page_New_ID_Weapon] = {reserveJump = true},
  [StoreConst.Page_New_ID_Other] = {reserveJump = true}
}
local getMaxPriceByCurrency = function(data, currency)
  local value = 0
  local prices = data.lowestPriceList or {}
  for i, v in pairs(prices) do
    if v.currency == currency and value < v.discountPrice then
      value = v.discountPrice
    end
  end
  return value
end
local getMaxPriceByTreasure = function(data)
  local value, weight = 0, 0
  local prices = data.lowestPriceList or {}
  for i, v in pairs(prices) do
    if v.currency == StoreConst.label_price_type_uc then
      if value < v.discountPrice then
        value = v.discountPrice
        weight = 0
      end
    elseif v.currency == StoreConst.label_price_type_diamond then
      if value < v.discountPrice * 0.1 then
        value = v.discountPrice * 0.1
        weight = 1
      end
    elseif v.currency == StoreConst.label_price_type_chip and value < v.discountPrice * 0.6 then
      value = v.discountPrice * 0.6
      weight = 2
    end
  end
  return value, weight
end
local getMaxPriceOfCrystal = function(data, crystalID)
  local value, weight = 0, 0
  local prices = data.lowestPriceList or {}
  for i, v in pairs(prices) do
    if v.currency == StoreConst.label_price_type_uc then
      if value < v.discountPrice then
        value = v.discountPrice
        weight = 0
      end
    elseif v.currency == crystalID and value < v.discountPrice * 35 then
      value = v.discountPrice * 35
      weight = 1
    end
  end
  return value, weight
end
local getMaxPriceOfCloth = function(data)
  local value, weight = 0, 0
  local prices = data.lowestPriceList or {}
  for i, v in pairs(prices) do
    if v.currency == StoreConst.label_price_type_uc then
      if value < v.discountPrice * 10 then
        value = v.discountPrice * 10
        weight = 0
      end
    elseif v.currency == StoreConst.label_price_type_diamond and value < v.discountPrice then
      value = v.discountPrice
      weight = 1
    end
  end
  return value, weight
end
local sort_have = function(a, b, sortFunc, ...)
  local haveWithOutLimit_A = a.have and a.purchaseLimitNum == 0
  local haveWithOutLimit_B = b.have and b.purchaseLimitNum == 0
  if haveWithOutLimit_A == haveWithOutLimit_B then
    local bSoldOut_A = a.isSoldOut and a.purchaseLimitNum > 0 and a.hasPurchaseNum == a.purchaseLimitNum
    local bSoldOut_B = b.isSoldOut and b.purchaseLimitNum > 0 and b.hasPurchaseNum == b.purchaseLimitNum
    if bSoldOut_A == bSoldOut_B then
      return sortFunc(a, b, ...)
    else
      return bSoldOut_B
    end
  else
    return haveWithOutLimit_B
  end
end
local priceSortForCloth = function(a, b, isUp)
  local valueA, weightA = getMaxPriceOfCloth(a)
  local valueB, weightB = getMaxPriceOfCloth(b)
  if valueA == valueB then
    if weightA == weightB then
      return a.shopId > b.shopId
    else
      return weightA < weightB
    end
  elseif isUp then
    return valueA < valueB
  else
    return valueA > valueB
  end
end
local priceSortForCrystal = function(a, b, isUp, crystalID)
  local valueA, weightA = getMaxPriceOfCrystal(a, crystalID)
  local valueB, weightB = getMaxPriceOfCrystal(b, crystalID)
  if weightA == weightB then
    if valueA == valueB then
      return a.shopId > b.shopId
    elseif isUp then
      return valueA < valueB
    else
      return valueA > valueB
    end
  elseif isUp then
    return weightA < weightB
  else
    return weightA > weightB
  end
end
local priceSortForCurrency = function(a, b, isUp, currency)
  local valueA = getMaxPriceByCurrency(a, currency)
  local valueB = getMaxPriceByCurrency(b, currency)
  if valueA == valueB then
    return a.shopId > b.shopId
  elseif isUp then
    return valueA < valueB
  else
    return valueA > valueB
  end
end
local priceSortForTreasure = function(a, b, isUp)
  local valueA, weightA = getMaxPriceByTreasure(a)
  local valueB, weightB = getMaxPriceByTreasure(b)
  if valueA == valueB then
    if weightA == weightB then
      return a.shopId > b.shopId
    elseif isUp then
      return weightA > weightB
    else
      return weightA < weightB
    end
  elseif isUp then
    return valueA < valueB
  else
    return valueA > valueB
  end
end
local checkPayType = function(prices, pType)
  local len = #prices
  for i = len, 1, -1 do
    if prices[i] then
      local priType = prices[i][StoreConst.label_price_index_price_type]
      if priType and priType == pType then
        return true
      end
    end
  end
  return false
end
local hasPaymentTypeByExchange = function(prices, pType, isCull)
  local isHas = false
  if checkPayType(prices, pType) then
    isHas = true
  else
    return isHas
  end
  if not isCull then
    return isHas
  end
  local len = #prices
  for i = len, 1, -1 do
    if prices[i] then
      local priType = prices[i][StoreConst.label_price_index_price_type]
      if priType ~= pType then
        table.remove(prices, i)
      end
    end
  end
  return isHas
end
local cullPaymentType = function(prices, currencyGroup)
  local has = false
  local tempTable = {}
  for i, v in ipairs(currencyGroup) do
    tempTable[v] = true
  end
  local len = #prices
  for i = len, 1, -1 do
    if prices[i] then
      local priType = prices[i][StoreConst.label_price_index_price_type]
      if tempTable[priType] ~= true then
        table.remove(prices, i)
      else
        has = true
      end
    end
  end
  return has
end
function StoreUtils.GetPageConfigByTabId(tabId, subTabId, isSupply)
  local store_supply_switcher = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_supply_switcher)
  local page = store_supply_switcher:GetUseNewStoreFlag() and "StoreGeneralPage"
  local tabToPageConfig = StoreUtils.GetTabToPageConfig()
  local tabCfg = tabToPageConfig[tabId]
  if tabCfg then
    if tabCfg.subTab and tabCfg.subTab[subTabId] then
      page = tabCfg.subTab[subTabId]
    elseif tabCfg.default then
      page = tabCfg.default
    end
  elseif isSupply then
    page = store_supply_switcher:GetUseNewStoreFlag() and "SupplyGeneralPage"
  end
  log(bWriteLog and string.format("StoreUtils.GetPageConfigByTabId return page = %s", page))
  return UIManager.UI_Config[page]
end
function StoreUtils.GetTabToPageConfig()
  local store_supply_switcher = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_supply_switcher)
  return store_supply_switcher:GetUseNewStoreFlag() and StoreUtils.TabToPageConfigV280
end
function StoreUtils.IsKrJpTreasure(tabId)
  if not GlobalData.IsJapanOrKorea() then
    return false
  end
  if tabId == StoreConst.Page_ID_Item then
    return true
  else
    return false
  end
end
local cullNotThisTabForExchange = function(curSubTab, prices, checkSubTab, isVIP)
  isVIP = isVIP or 0
  if StoreConst.subtype_new_exchange_cry == curSubTab then
    return curSubTab == checkSubTab
  elseif StoreConst.subtype_new_exchange_fra == curSubTab then
    return hasPaymentTypeByExchange(prices, StoreConst.label_price_type_chip, true)
  elseif StoreConst.subtype_new_exchange_bps == curSubTab then
    if hasPaymentTypeByExchange(prices, StoreConst.label_price_type_bp, true) then
      return 0 < isVIP
    end
  elseif StoreConst.subtype_new_exchange_bpf == curSubTab then
    if hasPaymentTypeByExchange(prices, StoreConst.label_price_type_bp, true) then
      return isVIP == 0
    end
  elseif StoreConst.subtype_new_exchange_as == curSubTab then
    return curSubTab == checkSubTab
  end
  return false
end
local cullNotThisTabForTreasure = function(curSubTab, prices)
  if checkPayType(prices, StoreConst.label_price_type_bp) then
    return false
  else
    return true
  end
end
function StoreUtils.CheckSubTabSame(tabId, curSubTab, checkSubTab, prices, isVIP, sourceType, jump)
  if StoreConst.Page_New_ID_Exchange == tabId then
    return cullNotThisTabForExchange(curSubTab, prices, checkSubTab, isVIP)
  end
  if StoreUtils.IsKrJpTreasure(tabId) then
    return true
  end
  if checkSubTab == 0 or checkSubTab == curSubTab or StoreUtils.NotNeedToCheckSubTab[curSubTab] then
  else
    return false
  end
  if StoreConst.Page_New_ID_Treasure == tabId then
    return cullNotThisTabForTreasure(curSubTab, prices)
  end
  return StoreUtils.CheckTypeMoneyType(tabId, curSubTab, prices, sourceType, jump)
end
function StoreUtils.CheckTypeMoneyType(curTabID, curSubTabID, prices, sourceType, jump)
  if GlobalData.IsJapanOrKorea() then
    return true
  end
  local config = needCheckMoneyType[curTabID]
  if not config then
    return true
  end
  local moneySystem = require("client.slua.logic.store.logic_money_component")
  local currencyGroup = moneySystem.GetStoreCurrencyGroup(curTabID, curSubTabID)
  if currencyGroup then
    if cullPaymentType(prices, currencyGroup) then
      return true
    elseif config.reserveJump and (sourceType ~= ENUM_ItemSourceType.None or jump) then
      return true
    elseif curSubTabID == StoreConst.subtype_new_recommend_lim or curSubTabID == StoreConst.subtype_new_recommend_lim_In then
      return true
    end
  end
  return false
end
function StoreUtils.CheckSubTabByJK(curSubTab, checkSubTab)
  if not GlobalData.IsJapanOrKorea() then
    return false
  end
  if curSubTab == StoreConst.label_subtype_voice_chip and checkSubTab ~= 0 and checkSubTab ~= curSubTab then
    return true
  end
  if curSubTab == StoreConst.label_subtype_sliver_chip and checkSubTab == StoreConst.label_subtype_voice_chip then
    return true
  end
  return false
end
function StoreUtils.GetQualityProbability(rateList)
  local list = {}
  if not rateList then
    return list
  end
  for index, rate in pairs(rateList) do
    local nRate = tonumber(rate)
    if nRate and 0 < nRate then
      list[index] = LocUtil.LocalizeResFormat(10283, nRate)
    else
      list[index] = rate
    end
  end
  return list
end
function StoreUtils.GetCurrencyByExchangeTab(currency, isGive, tabId, subTabId)
  currency = currency or -1
  if isGive then
    currency = StoreConst.label_price_type_uc
  elseif tabId == StoreConst.Page_ID_Exchange then
    if subTabId and subTabId == StoreConst.label_subtype_voice_chip then
      currency = StoreConst.label_price_itemID_voice_chip
    elseif subTabId and subTabId == StoreConst.label_subtype_allstar_chip then
      currency = StoreConst.label_price_type_allstar
    else
      currency = StoreConst.label_price_type_chip
    end
  end
  return currency
end
function StoreUtils.DiscountSpecialByPrime(tabId, subTabId, priceInfo, vipFlag)
  local isPrimeTab = StoreUtils.IsPrimeTab(tabId, subTabId)
  if not isPrimeTab or priceInfo.discountPrice ~= priceInfo.originalPrice then
    return
  end
  if vipFlag and (vipFlag == StoreConst.vip_type_mode_primeplus or vipFlag == StoreConst.vip_type_mode_prime) then
    local SubscribeCarnivalSystem = require("client.slua.logic.subscribe.logic_subscribe_carnival_activity")
    if SubscribeCarnivalSystem.IsActivityOpen() and SubscribeCarnivalSystem.IsBothPrime() then
      local discount_rate = SubscribeCarnivalSystem.GetBPExchangeDiscount()
      if discount_rate and 0 < discount_rate then
        priceInfo.discountPrice = math.floor(priceInfo.originalPrice * (1 - discount_rate))
      end
    end
  end
end
function StoreUtils.GivePriceSpecialByAG(item, isGive, currency)
  if isGive and currency == StoreConst.label_price_type_diamond then
    item.priceIcon = StoreUtils.GetPriceIconByCurrency(StoreConst.label_price_type_uc)
    item.discountPrice = math.ceil(item.discountPrice / 10)
    item.originalPrice = math.ceil(item.originalPrice / 10)
    item.highestPrice = math.ceil(item.highestPrice / 10)
    item.finalPrice = math.ceil(item.finalPrice / 10)
  end
end
function StoreUtils.GetLeftTime(endTime)
  if endTime ~= 0 then
    local TimeUtil = require("client.common.time_util")
    return endTime - TimeUtil.GetServerTimeInSec()
  else
    return 0
  end
end
function StoreUtils.GetCanGiftMark(itemData, tabId)
  if StoreUtils.CanSendGift() == false or tabId == StoreConst.Page_New_ID_Exchange then
    return 0
  else
    return itemData[StoreConst.label_item_index_can_gift] or 0
  end
end
function StoreUtils.GetTodayText(showDiscount, discount, isPreferencesGift)
  if showDiscount and discount ~= 0 then
    if isPreferencesGift then
      return LocUtil.LocalizeResFormat(33275, discount)
    else
      return nil
    end
  elseif isPreferencesGift then
    return LocUtil.LocalizeResFormat(33275, 0)
  else
    return nil
  end
end
function StoreUtils.GetDiscountText(showDiscount, discount)
  if showDiscount and discount ~= 0 then
    return "-" .. tostring(discount) .. "%"
  else
    return ""
  end
end
function StoreUtils.GetBuyLimitData(limitData, shopId)
  local result = {
    purchaseLimitType = 0,
    purchaseLimitNum = 0,
    hasPurchaseNum = 0,
    isSoldOut = false
  }
  if not limitData then
    return result
  end
  local limitType, limitNum = next(limitData)
  if limitType == nil then
    return result
  end
  result.purchaseLimitType = limitType
  result.purchaseLimitNum = limitNum
  local buyInfo = StoreUtils.GetBuyInfo(shopId)
  if StoreConst.label_buy_limit_type_daily == limitType then
    result.hasPurchaseNum = buyInfo.daily_buy_cnt
  elseif StoreConst.label_buy_limit_type_week == limitType then
    result.hasPurchaseNum = buyInfo.week_buy_cnt
  elseif StoreConst.label_buy_limit_type_permanent == limitType then
    result.hasPurchaseNum = buyInfo.permanet_buy_cnt
  end
  result.isSoldOut = StoreUtils.IsSoldOut(shopId, limitData[StoreConst.label_buy_limit_type_daily], limitData[StoreConst.label_buy_limit_type_week], limitData[StoreConst.label_buy_limit_type_permanent])
  return result
end
function StoreUtils.CanShowByItem(tabId, subTabId, preShopId, preShopInfo, isVIP)
  local canShow, preItemId = true
  if StoreUtils.IsUCSpecialPackageTab(tabId, subTabId) then
    canShow, preItemId = StoreUtils.CheckFrontItem(preShopId, preShopInfo)
  elseif StoreUtils.IsDirectBuyTab(tabId) then
    canShow, preItemId = StoreUtils.CheckFrontItem(preShopId, preShopInfo)
  end
  if StoreUtils.IsPrimeTab(tabId, subTabId) and isVIP == StoreConst.vip_type_mode_both_prime then
    local SubscribeCarnivalSystem = require("client.slua.logic.subscribe.logic_subscribe_carnival_activity")
    if SubscribeCarnivalSystem.IsActivityOpen() then
      canShow = true
    else
      canShow = false
    end
  end
  return canShow, preItemId
end
function StoreUtils.CheckFrontItem(preShopId, preShopInfo)
  if preShopId == nil or preShopId == 0 then
    return true, nil
  end
  if not preShopInfo then
    return false, nil
  end
  local limitData = preShopInfo[StoreConst.label_item_index_buy_limit] or {}
  if StoreUtils.IsSoldOut(preShopId, limitData[StoreConst.label_buy_limit_type_daily], limitData[StoreConst.label_buy_limit_type_week], limitData[StoreConst.label_buy_limit_type_permanent]) then
    return true, preShopInfo[StoreConst.label_item_index_id]
  else
    return false, preShopInfo[StoreConst.label_item_index_id]
  end
end
function StoreUtils.GetValidFlag(ValidTimes, ExTime)
  if ValidTimes and ValidTimes ~= 0 then
    return true, ValidTimes
  elseif ExTime ~= "" then
    return true, 0
  end
  return false, 0
end
function StoreUtils.GetNeedShowTitleConfig(subTabId)
  return StoreUtils.TitleTabConfig[subTabId] or {}
end
function StoreUtils.SortPageItem(sType, list, tab, subTab)
  if sType == StoreUtils.ItemSortType.Default then
    StoreUtils.SortItemByDefault(list, tab, subTab)
  elseif sType == StoreUtils.ItemSortType.Quality then
    StoreUtils.SortItemByQuality(list, tab)
  elseif sType == StoreUtils.ItemSortType.Price_Up then
    StoreUtils.SortItemByPrice(list, tab, subTab, true)
  elseif sType == StoreUtils.ItemSortType.Price_Down then
    StoreUtils.SortItemByPrice(list, tab, subTab, false)
  elseif sType == StoreUtils.ItemSortType.Priority_AG then
    StoreUtils.SortItemByPriorityAG(list)
  elseif sType == StoreUtils.ItemSortType.Priority_UC then
    StoreUtils.SortItemByPriorityUC(list)
  end
end
function StoreUtils.SortItemByDefault(list, tab, subTab)
  if tab == StoreConst.Page_New_ID_Exchange and subTab == StoreConst.subtype_new_exchange_fra then
    StoreUtils.DefaultSortSilverExchange(list)
  elseif StoreUtils.IsPrimeTab(tab, subTab) then
    StoreUtils.SortPrimePage(list)
  elseif tab == StoreConst.Page_New_ID_Treasure then
    StoreUtils.SortNewTreasurePage(list, tab)
  elseif StoreUtils.IsKrJpTreasure(tab) then
    StoreUtils.SortNewTreasurePage(list, tab)
  else
    StoreUtils.DefaultSortAlgorithm(list)
  end
end
function StoreUtils.SortItemByQuality(list, tabId)
  if list == nil or next(list) == nil then
    return
  end
  local sort = function(a, b)
    if a.quality == b.quality then
      return a.shopId > b.shopId
    else
      return a.quality > b.quality
    end
  end
  if tabId and tabId == StoreConst.Page_New_ID_Treasure then
    table.sort(list, function(a, b)
      return sort_have(a, b, sort)
    end)
  else
    table.sort(list, sort)
  end
end
function StoreUtils.SortItemByPrice(list, tab, subTab, isUp)
  if list == nil or next(list) == nil then
    return
  end
  if tab == StoreConst.Page_New_ID_Cloth then
    table.sort(list, function(a, b)
      return priceSortForCloth(a, b, isUp)
    end)
  elseif tab == StoreConst.Page_New_ID_Exchange then
    if subTab == StoreConst.subtype_new_exchange_cry then
      local moneySystem = require("client.slua.logic.store.logic_money_component")
      local crystalID = moneySystem.GetCrystalsID(tab, subTab)
      table.sort(list, function(a, b)
        return priceSortForCrystal(a, b, isUp, crystalID)
      end)
    elseif subTab == StoreConst.subtype_new_exchange_fra then
      table.sort(list, function(a, b)
        return priceSortForCurrency(a, b, isUp, StoreConst.label_price_type_chip)
      end)
    elseif subTab == StoreConst.subtype_new_exchange_bps then
      table.sort(list, function(a, b)
        return priceSortForCurrency(a, b, isUp, StoreConst.label_price_type_bp)
      end)
    elseif subTab == StoreConst.subtype_new_exchange_bpf then
      table.sort(list, function(a, b)
        return priceSortForCurrency(a, b, isUp, StoreConst.label_price_type_bp)
      end)
    elseif subTab == StoreConst.subtype_new_exchange_as then
      table.sort(list, function(a, b)
        return priceSortForCurrency(a, b, isUp, StoreConst.label_price_type_allstar)
      end)
    end
  elseif tab == StoreConst.Page_New_ID_Treasure then
    table.sort(list, function(a, b)
      return sort_have(a, b, priceSortForTreasure, isUp)
    end)
  elseif tab == StoreConst.Page_New_ID_Other then
    table.sort(list, function(a, b)
      return priceSortForTreasure(a, b, isUp)
    end)
  end
end
function StoreUtils.SortNewOtherPar(a, b)
  local isShowHuoDe_A = StoreUtils.IsHuodeFlag(a)
  local isShowHuoDe_B = StoreUtils.IsHuodeFlag(b)
  if isShowHuoDe_A == isShowHuoDe_B then
    return priceSortForTreasure(a, b, false)
  else
    return isShowHuoDe_A or not isShowHuoDe_B
  end
end
function StoreUtils.IsHuodeFlag(data)
  if data == nil or data.finalPrice == nil or type(data.finalPrice) ~= "number" or data.finalPrice > 0 then
    return false
  end
  return data.finalPrice == 0 and data.source ~= "" or false
end
function StoreUtils.SortItemByPriorityAG(list)
  if list == nil or next(list) == nil then
    return
  end
  local sort = function(a, b)
    local agA = getMaxPriceByCurrency(a, StoreConst.label_price_type_diamond)
    local agB = getMaxPriceByCurrency(b, StoreConst.label_price_type_diamond)
    if agA == agB then
      if agA == 0 then
        local ucA = getMaxPriceByCurrency(a, StoreConst.label_price_type_uc)
        local ucB = getMaxPriceByCurrency(b, StoreConst.label_price_type_uc)
        if ucA == ucB then
          return a.shopId > b.shopId
        else
          return ucA > ucB
        end
      end
      return a.shopId > b.shopId
    else
      return agA > agB
    end
  end
  table.sort(list, sort)
end
function StoreUtils.SortItemByPriorityUC(list)
  if list == nil or next(list) == nil then
    return
  end
  local sort = function(a, b)
    local ucA = getMaxPriceByCurrency(a, StoreConst.label_price_type_uc)
    local ucB = getMaxPriceByCurrency(b, StoreConst.label_price_type_uc)
    if ucA == ucB then
      if ucA == 0 then
        local agA = getMaxPriceByCurrency(a, StoreConst.label_price_type_diamond)
        local agB = getMaxPriceByCurrency(b, StoreConst.label_price_type_diamond)
        if agA == agB then
          return a.shopId > b.shopId
        else
          return agA > agB
        end
      end
      return a.shopId > b.shopId
    else
      return ucA > ucB
    end
  end
  table.sort(list, sort)
end
function StoreUtils.DefaultSortSilverExchange(list)
  if list == nil or next(list) == nil then
    return
  end
  local sort = function(a, b)
    if a.have == b.have then
      return StoreUtils.SortExchangePage(a, b)
    else
      return b.have
    end
  end
  table.sort(list, sort)
end
function StoreUtils.SortExchangePage(left, right)
  local IsJapanOrKorea = GlobalData.IsJapanOrKorea()
  if IsJapanOrKorea and left.sort ~= right.sort then
    return left.sort > right.sort
  else
    local leftInfo = {
      itemType = left.type,
      itemSubType = left.subType
    }
    local rightInfo = {
      itemType = right.type,
      itemSubType = right.subType
    }
    local leftSortNum = StoreUtils.GetSortNumByExchange(leftInfo)
    local rightSortNum = StoreUtils.GetSortNumByExchange(rightInfo)
    if leftSortNum < rightSortNum then
      return true
    elseif leftSortNum > rightSortNum then
      return false
    elseif left.quality < right.quality then
      return false
    elseif left.quality > right.quality then
      return true
    else
      return left.shopId < right.shopId
    end
  end
end
function StoreUtils.DefaultSortAlgorithm(list)
  if list == nil or next(list) == nil then
    return
  end
  local sort = function(a, b)
    if a.have == b.have then
      return StoreUtils.SortAlgorithmImpl(a, b)
    else
      return b.have
    end
  end
  table.sort(list, sort)
end
function StoreUtils.SortAlgorithmImpl(a, b)
  if a.sort == b.sort then
    if a.startTime == b.startTime then
      if a.discount == b.discount then
        if a.hot == b.hot then
          if a.quality == b.quality then
            return a.shopId > b.shopId
          else
            return a.quality > b.quality
          end
        else
          return a.hot or not b.hot
        end
      else
        return a.discount > b.discount
      end
    else
      return a.startTime > b.startTime
    end
  else
    return a.sort > b.sort
  end
end
function StoreUtils.SortCollectionInGlobal(list)
  if list == nil or next(list) == nil then
    return
  end
  local sort = function(a, b)
    local isShowHuoDe_A = StoreUtils.IsHuodeFlag(a)
    local isShowHuoDe_B = StoreUtils.IsHuodeFlag(b)
    if isShowHuoDe_A == isShowHuoDe_B then
      if a.quality == b.quality then
        return a.itemId > b.itemId
      else
        return a.quality > b.quality
      end
    else
      return isShowHuoDe_A or not isShowHuoDe_B
    end
  end
  table.sort(list, sort)
end