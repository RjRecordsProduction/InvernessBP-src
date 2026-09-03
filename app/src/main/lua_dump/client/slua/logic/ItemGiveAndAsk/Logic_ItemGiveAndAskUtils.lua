local Logic_ItemGiveAndAskUtils = {}
local _bGMIgnoreGiveLimit = false
local _bGMIgnoreAskLimit = false
function Logic_ItemGiveAndAskUtils.SetGMIgnoreGiveLimit(bIsIgnore)
  _bGMIgnoreGiveLimit = bIsIgnore
end
function Logic_ItemGiveAndAskUtils.SetGMIgnoreAskLimit(bIsIgnore)
  _bGMIgnoreAskLimit = bIsIgnore
end
function Logic_ItemGiveAndAskUtils.GetAllFriendData()
  local SortByIntimacy = function(a, b)
    if a.isSameClient == b.isSameClient then
      if a.intimacy == b.intimacy then
        if a.lastOnlineTime == nil or b.lastOnlineTime == nil then
          return false
        end
        return a.lastOnlineTime > b.lastOnlineTime
      else
        return a.intimacy > b.intimacy
      end
    else
      return a.isSameClient
    end
  end
  local tAllFriendList = {}
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local Logic_FriendUtil = require("client.slua.logic.friend.Logic_FriendUtil")
  local tTempList = LogicFriend.GetInnerList()
  for _, v in ipairs(tTempList) do
    local temp = Logic_FriendUtil.MakeFriendInfo(v)
    if temp then
      table.insert(tAllFriendList, temp)
    end
  end
  table.sort(tAllFriendList, SortByIntimacy)
  return tAllFriendList
end
function Logic_ItemGiveAndAskUtils.GetIsCanGive(nGiveType, tFriendData)
  local uObj_giftCondition = CDataTable.GetTableData("SendGiftCondition", nGiveType)
  if not uObj_giftCondition then
    log(bWriteLog and " Logic_ItemGiveAndAskUtils.GetIsCanGive >>> not uObj_giftCondition")
    return false
  end
  if _bGMIgnoreGiveLimit then
    log(bWriteLog and " GM GetIsCanGive _bGMIgnoreGiveLimit  >>> " .. tostring(_bGMIgnoreGiveLimit))
    return true
  end
  local nPlayerIntimacy = tFriendData.intimacy or 0
  if nPlayerIntimacy < uObj_giftCondition.sendMinIntimacy then
    ShowNotice(5000144)
    log(bWriteLog and " Logic_ItemGiveAndAskUtils.GetIsCanGive >>> Intimacy Limit")
    return false
  end
  local nAddFriendTime = tFriendData.create_time or 0
  if not Logic_ItemGiveAndAskUtils.CheckBeFriendTimeOK(nAddFriendTime, uObj_giftCondition.sendMinSeconds) then
    ShowNotice(5000145)
    log(bWriteLog and " Logic_ItemGiveAndAskUtils.GetIsCanGive >>> Friend Time Limit")
    return false
  end
  if DataMgr.roleData.level < uObj_giftCondition.sendMinLevel then
    ShowNotice(5000146)
    log(bWriteLog and " Logic_ItemGiveAndAskUtils.GetIsCanGive >>> Level Limit")
    return false
  end
  return true
end
function Logic_ItemGiveAndAskUtils.GetIsCanAskFor(tAskGiftData, tFriendData)
  local uObj_giftCondition = Logic_ItemGiveAndAskUtils.GetAskForLimitCfg(tAskGiftData)
  if not uObj_giftCondition then
    log(bWriteLog and " Logic_ItemGiveAndAskUtils.GetIsCanAskFor >>> not uObj_giftCondition")
    return false
  end
  if _bGMIgnoreAskLimit then
    log(bWriteLog and " GM GetIsCanAskFor _bGMIgnoreAskLimit  >>> " .. tostring(_bGMIgnoreAskLimit))
    return true
  end
  local nPlayerIntimacy = tFriendData.intimacy or 0
  if nPlayerIntimacy < uObj_giftCondition.FriendIntimacyLimit then
    ShowNotice(5000144)
    log(bWriteLog and " Logic_ItemGiveAndAskUtils.GetIsCanAskFor >>> Intimacy Limit")
    return false
  end
  local nAddFriendTime = tFriendData.create_time or 0
  local nLimitTime = uObj_giftCondition.FriendTimeLimit * 24 * 3600
  if not Logic_ItemGiveAndAskUtils.CheckBeFriendTimeOK(nAddFriendTime, nLimitTime) then
    ShowNotice(5000145)
    log(bWriteLog and " Logic_ItemGiveAndAskUtils.GetIsCanAskFor >>> Friend Time Limit")
    return false
  end
  if DataMgr.roleData.level < uObj_giftCondition.LevelLimit then
    ShowNotice(5000146)
    log(bWriteLog and " Logic_ItemGiveAndAskUtils.GetIsCanAskFor >>> Level Limit")
    return false
  end
  return true
end
function Logic_ItemGiveAndAskUtils.CheckBeFriendTimeOK(nAddFriendTime, nLimitTime)
  if nLimitTime <= 0 then
    log(bWriteLog and "Logic_ItemGiveAndAskUtils.CheckBeFriendTimeOK limitDay <= 0")
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local nNowTime = TimeUtil.GetServerTimeInSec()
  local nBeFriendTime = nNowTime - nAddFriendTime
  log(bWriteLog and "Logic_ItemGiveAndAskUtils.CheckBeFriendTimeOK nLimitTime === " .. tostring(nLimitTime) .. "  beFriendTime = " .. tostring(nBeFriendTime))
  if nBeFriendTime <= 0 then
    log(bWriteLog and "Logic_ItemGiveAndAskUtils.CheckBeFriendTimeOK 2 beFriendTime:" .. nBeFriendTime)
    return false
  end
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local bIgnoreFriendTime = LogicFriend.ignoreFriendTime
  if nLimitTime <= nBeFriendTime or bIgnoreFriendTime then
    log(bWriteLog and "Logic_ItemGiveAndAskUtils.CheckBeFriendTimeOK 3 beFriendTime:" .. nBeFriendTime)
    return true
  end
  log(bWriteLog and "Logic_ItemGiveAndAskUtils.CheckBeFriendTimeOK 4 beFriendTime:" .. nBeFriendTime)
  return false
end
function Logic_ItemGiveAndAskUtils.StoreDataConvertToGiftData(tStoreData, tGiftData, nShowMoneyType, bIsAgChangeToUC)
  tGiftData = tGiftData or {}
  tGiftData.nShopId = tStoreData[StoreConst.label_item_index_market_id]
  tGiftData.nItemId = tStoreData[StoreConst.label_item_index_id]
  local tPriceList = tStoreData[StoreConst.label_item_index_price_list]
  if tPriceList and next(tPriceList) then
    local tAllPriceData = {}
    local nPriceDataIndex = 1
    local nMoneyKey = StoreConst.label_price_index_price_type
    local nOriginalPriceKey = StoreConst.label_price_index_one_original_price
    local nDiscountPriceKey = StoreConst.label_price_index_one_discount_price
    local nValidHoursKey = StoreConst.label_price_index_valid_hours
    local nEveryDayDisCountLimitKey = StoreConst.label_price_index_daily_discount_limit
    local nEveryDayDisPriceKey = StoreConst.label_price_index_daily_discount_price
    local nUCType = StoreConst.label_price_type_uc
    local nAgType = StoreConst.label_price_type_diamond
    for _, v in ipairs(tPriceList) do
      local nMoneyType = v[nMoneyKey]
      if nMoneyType and (not nShowMoneyType or nMoneyType == nShowMoneyType) then
        local nPrice = v[nOriginalPriceKey]
        local nDisPrice = v[nDiscountPriceKey]
        if nDisPrice and 0 < nDisPrice then
          nPrice = nDisPrice
        end
        if bIsAgChangeToUC and nMoneyType == nAgType then
          nMoneyType = nUCType
          nPrice = math.ceil(nPrice / 10)
        end
        local tPriceData = {
          nPrice = nPrice,
          nMoneyType = nMoneyType,
          nValidTime = v[nValidHoursKey]
        }
        if v[nEveryDayDisCountLimitKey] and 0 < v[nEveryDayDisCountLimitKey] then
          tPriceData.nEveryDayDisCountLimit = v[nEveryDayDisCountLimitKey]
          tPriceData.nEveryDayDisPrice = v[nEveryDayDisPriceKey]
        end
        tAllPriceData[nPriceDataIndex] = tPriceData
        if not nShowMoneyType then
          break
        end
        nPriceDataIndex = nPriceDataIndex + 1
      end
    end
    tGiftData.  end
  local tLimitInfo = tStoreData[StoreConst.label_item_index_buy_limit]
  if tLimitInfo then
    tGiftData.nDailyBuyLimit = tLimitInfo[StoreConst.label_buy_limit_type_daily]
    tGiftData.nWeekBuyLimit = tLimitInfo[StoreConst.label_buy_limit_type_week]
    tGiftData.nBuyLimit = tLimitInfo[StoreConst.label_buy_limit_type_permanent]
  end
  Logic_ItemGiveAndAskUtils.UpdateGiftBuyTimes(tGiftData)
  return tGiftData
end
function Logic_ItemGiveAndAskUtils.UpdateGiftBuyTimes(tGiftData)
  if not tGiftData or not tGiftData.nShopId then
    return
  end
  tGiftData.nCanBuyTimes = nil
  local bIsBuyLimit = false
  local nCanBuyTimes = 99999999999
  local StoreUtils = require("client.slua.logic.store.utils.store_utils")
  local tItemBuyInfo = StoreUtils.GetBuyInfo(tGiftData.nShopId)
  if tItemBuyInfo then
    if tGiftData.nDailyBuyLimit then
      nCanBuyTimes = math.min(nCanBuyTimes, tGiftData.nDailyBuyLimit - tItemBuyInfo.daily_buy_cnt)
      bIsBuyLimit = true
    end
    if tGiftData.nWeekBuyLimit then
      nCanBuyTimes = math.min(nCanBuyTimes, tGiftData.nWeekBuyLimit - tItemBuyInfo.week_buy_cnt)
      bIsBuyLimit = true
    end
    if tGiftData.nBuyLimit then
      nCanBuyTimes = math.min(nCanBuyTimes, tGiftData.nBuyLimit - tItemBuyInfo.permanet_buy_cnt)
      bIsBuyLimit = true
    end
  end
  if bIsBuyLimit then
    tGiftData.  end
end
function Logic_ItemGiveAndAskUtils.GetAskForLimitCfg(tAskGiftData)
  local nAskCfgIndex = tAskGiftData.Index
  local uObj_askCondition = CDataTable.GetTableData("AskForLimitCfg", nAskCfgIndex)
  if not uObj_askCondition then
    nAskCfgIndex = 1
    local nMoneyType = tAskGiftData.PriceType
    if nMoneyType == StoreConst.label_price_type_iap then
      nAskCfgIndex = 2
    end
    uObj_askCondition = CDataTable.GetTableData("AskForLimitCfg", nAskCfgIndex)
  end
  return uObj_askCondition
end
return Logic_ItemGiveAndAskUtils