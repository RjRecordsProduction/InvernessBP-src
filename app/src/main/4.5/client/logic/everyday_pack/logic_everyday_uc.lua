local EveryDayUcSystem = {}
EveryDayUcSystem.activityId = -1
EveryDayUcSystem.shopPageId = 41
EveryDayUcSystem.propId = 0
EveryDayUcSystem.isHasAct = false
EveryDayUcSystem.isFaceSlap = false
EveryDayUcSystem.isSpecial = false
local LocalizeResTimeType = {faceType = 0, redpointType = 1}
EveryDayUcSystem.activityData = nil
EveryDayUcSystem.exchangeData = nil
EveryDayUcSystem.everyBuyData = nil
EveryDayUcSystem.giftPackData = nil
function EveryDayUcSystem.ResetData()
  EveryDayUcSystem.activityData = nil
  EveryDayUcSystem.exchangeData = nil
  EveryDayUcSystem.everyBuyData = nil
  EveryDayUcSystem.giftPackData = nil
  EveryDayUcSystem.propId = 0
  EveryDayUcSystem.isFaceSlap = false
  EventSystem:unregistEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYBACK_EXCHANGE_REFRESH, EveryDayUcSystem.IntExchangeData)
  EventSystem:unregistEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_DATA, EveryDayUcSystem.GetStoreDataAndSendReq)
  EventSystem:unregistEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_CHEST_INFO, EveryDayUcSystem.GetGiftPackData)
  EventSystem:unregistEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_BUY_INFO_CHANGE, EveryDayUcSystem.GetBuyTimesData)
end
function EveryDayUcSystem.SetIsSpecial(bIsSpecial)
  EveryDayUcSystem.isSpecial = bIsSpecial
end
function EveryDayUcSystem.GetEveryDayData()
  EveryDayUcSystem.activityId = EveryDayUcSystem.GetActivityId()
  if EveryDayUcSystem.activityId ~= -1 and EveryDayUcSystem.IsActivityTime() then
    local LuckybackHandler = require("client.network.Protocol.LuckybackHandler")
    LuckybackHandler.send_get_exchange_activity_info_req(EveryDayUcSystem.activityId)
    EventSystem:registEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYBACK_EXCHANGE_REFRESH, EveryDayUcSystem.IntExchangeData)
  end
end
function EveryDayUcSystem.ShowEveryDayUC()
  if not EveryDayUcSystem.IsActivityTime() then
    return
  end
  EveryDayUcSystem.activityId = EveryDayUcSystem.GetActivityId()
  if EveryDayUcSystem.activityId == -1 then
    log(bWriteLog and " EveryDayUcSystem.ShowEveryDayUC, activityId Error >>> " .. EveryDayUcSystem.activityId)
    return
  end
  EveryDayUcSystem.isFaceSlap = false
  local LuckybackHandler = require("client.network.Protocol.LuckybackHandler")
  LuckybackHandler.send_get_exchange_activity_info_req(EveryDayUcSystem.activityId)
  local StoreHandler = require("client.network.Protocol.StoreHandler")
  StoreHandler.send_get_market_info_req(EveryDayUcSystem.shopPageId, 0)
  StoreHandler.send_get_market_buy_info_req_v3()
  EventSystem:registEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYBACK_EXCHANGE_REFRESH, EveryDayUcSystem.IntExchangeData)
  EventSystem:registEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_DATA, EveryDayUcSystem.GetStoreDataAndSendReq)
  EventSystem:registEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_CHEST_INFO, EveryDayUcSystem.GetGiftPackData)
  EventSystem:registEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_BUY_INFO_CHANGE, EveryDayUcSystem.GetBuyTimesData)
  EveryDayUcSystem.IntActivityData()
  EveryDayUcSystem.SaveRedPointTime()
end
function EveryDayUcSystem.GetActivityId()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  return ActivityNewSystem.CheckActivityIsOpenByType(ActivityType.LUCKYBACK_EXCHANGE, 1)
end
function EveryDayUcSystem.GetTextureCfg()
  if not EveryDayUcSystem.activityData then
    EveryDayUcSystem.IntActivityData()
    return
  end
  local tActData = EveryDayUcSystem.activityData
  local sBgUrl = tActData.ImgUrl
  local sCharacterUrl = tActData.EntryImageUrl
  return sBgUrl, sCharacterUrl
end
function EveryDayUcSystem.SaveRedPointTime()
  local actJson = EveryDayUcSystem.LoadRedPointTable()
  actJson = actJson or {}
  local TimeUtil = require("client.common.time_util")
  local currStamp = TimeUtil.GetServerTimeInSec()
  local cuurTime = math.floor(currStamp / 86400)
  actJson.lastTime = cuurTime
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(actJson, PlayerPrefsSystem.ePlayerPrefsType.eEveryDayPackUC)
end
function EveryDayUcSystem.ShowMainUI()
  if EveryDayUcSystem.IsHaveData() then
    log(bWriteLog and "[PXY]EveryDayUcSystem.ShowMainUI.isBanner")
    UIManager.ShowUI(UIManager.UI_Config.everyday_uc_activity)
  end
end
function EveryDayUcSystem.IsActivityTime()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  return ActivityNewSystem.IsActivityOpenByBanner(BP_ENUM_MODULE_EVERYDAY_PACK_UC)
end
function EveryDayUcSystem.IsHaveData()
  if EveryDayUcSystem.activityData and EveryDayUcSystem.exchangeData and #EveryDayUcSystem.exchangeData > 0 and EveryDayUcSystem.everyBuyData and EveryDayUcSystem.giftPackData then
    EveryDayUcSystem.GetPropNumData()
    return true
  end
  return false
end
function EveryDayUcSystem.IntExchangeData()
  local LuckybackActivityNewSystem = require("client.slua.logic.lobby_activity.logic_luckyback_activity")
  if LuckybackActivityNewSystem.exchangeItemList and #LuckybackActivityNewSystem.exchangeItemList > 0 then
    EveryDayUcSystem.exchangeData = LuckybackActivityNewSystem.exchangeItemList
    if EveryDayUcSystem.propId == 0 then
      for i = 1, #EveryDayUcSystem.exchangeData do
        local data = EveryDayUcSystem.exchangeData[i]
        EveryDayUcSystem.propId = data.needItemId
        if EveryDayUcSystem.propId ~= 0 then
          break
        end
      end
    end
    EveryDayUcSystem.IsRedPoint()
  end
end
function EveryDayUcSystem.IntActivityData()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local actId = EveryDayUcSystem.activityId
  local activityDataTable = ActivityNewSystem.GetActivityByID(actId)
  if activityDataTable then
    EveryDayUcSystem.activityData = activityDataTable
  end
end
function EveryDayUcSystem.GetStoreDataAndSendReq(eventType, eventID, param)
  local shopKey = StoreConst.label_market_index_market_list
  local info = param and param.data and param.data[shopKey]
  if param == nil or info and 0 < #info then
    log(bWriteLog and " EveryDayUcSystem.GetStoreData()" .. "param  or data is nil")
    return
  end
  local tAllData = {}
  for k, v in pairs(info) do
    local data = {}
    data.shopId = k
    data.itemId = v[StoreConst.label_item_index_id]
    data.itemNum = v[StoreConst.label_item_index_count]
    data.itemSort = v[StoreConst.label_item_index_rank]
    data.isDonwcount = v[StoreConst.label_item_index_show_time_limit]
    data.isNew = v[StoreConst.label_item_index_show_new]
    data.tabId = param.tab_id
    data.version = v[StoreConst.label_item_index_version]
    data.subId = v[StoreConst.label_item_index_page_id]
    local priceList = v[StoreConst.label_item_index_price_list]
    if priceList and 0 < #priceList then
      if priceList[1][StoreConst.label_price_index_price_type] then
        data.priceType = priceList[1][StoreConst.label_price_index_price_type]
      end
      if priceList[1][StoreConst.label_price_index_daily_discount_limit] then
        data.discountLimit = priceList[1][StoreConst.label_price_index_daily_discount_limit]
      end
      if priceList[1][StoreConst.label_price_index_daily_discount_price] then
        data.disCountPrice = priceList[1][StoreConst.label_price_index_daily_discount_price]
      end
      if priceList[1][StoreConst.label_price_index_one_original_price] then
        data.price = priceList[1][StoreConst.label_price_index_one_original_price]
      end
      if priceList[1][StoreConst.label_price_index_valid_hours] then
        data.validHours = priceList[1][StoreConst.label_price_index_valid_hours]
      end
    end
    if data.itemNum == 1 then
      tAllData[1] = data
    else
      tAllData[2] = data
    end
  end
  if tAllData and 2 <= #tAllData then
    EveryDayUcSystem.everyBuyData = tAllData
    local StoreHandler = require("client.network.Protocol.StoreHandler")
    StoreHandler.send_get_market_chest_info_req(tAllData[1].shopId)
  end
end
function EveryDayUcSystem.GetEveryBuyData()
  return EveryDayUcSystem.everyBuyData
end
function EveryDayUcSystem.GetBuyTimesData(eventType, eventID, param)
  local tEveryBuyData = EveryDayUcSystem.everyBuyData
  if not tEveryBuyData or #tEveryBuyData <= 0 then
    return
  end
  tEveryBuyData[1].buyTimes = 0
  if not StoreConst.buy_info then
    return
  end
  for k, _ in pairs(StoreConst.buy_info) do
    if k == tEveryBuyData[1].shopId then
      local count = StoreConst.buy_info[k].daily_buy_cnt
      tEveryBuyData[1].buyTimes = count
    end
  end
end
function EveryDayUcSystem.GetGiftPackData(event_type, event_id, param)
  if not param then
    log(bWriteLog and "EveryDayUcSystem.GetStoreData()" .. "param is nil")
    return
  end
  local dataInfo = param.info
  table.sort(dataInfo, function(a, b)
    return a[StoreConst.label_drop_index_item_sort] < b[StoreConst.label_drop_index_item_sort]
  end)
  local dataList = {}
  for index = 1, 3 do
    local data = {}
    if dataInfo and dataInfo[index] then
      data.itemId = dataInfo[index][StoreConst.label_drop_index_item_id]
      if index == 1 then
        data.itemCnt = 1
      else
        data.itemCnt = dataInfo[index][StoreConst.label_drop_index_item_num]
      end
      data.chance = dataInfo[index][StoreConst.label_drop_index_chance]
      data.limitTime = dataInfo[index][StoreConst.label_drop_index_item_time]
      data.dropType = dataInfo[index][StoreConst.label_drop_index_type]
      data.sort = dataInfo[index][StoreConst.label_drop_index_item_sort]
    end
    if data then
      table.insert(dataList, data)
    end
  end
  if dataList and 0 < #dataList then
    EveryDayUcSystem.giftPackData = dataList
  end
  EveryDayUcSystem.ShowMainUI()
end
function EveryDayUcSystem.IsRedPoint()
  local red = EveryDayUcSystem.HasRedPoint()
  LobbySystem.LobbyRedPointUpdate(BP_ENUM_MODULE_EVERYDAY_PACK_UC, red)
end
function EveryDayUcSystem.HasRedPoint()
  if EveryDayUcSystem.IsActivityTime() and not EveryDayUcSystem.IsToday(LocalizeResTimeType.redpointType) and not EveryDayUcSystem.IsHasAllExcahnge() then
    return true
  end
  return false
end
function EveryDayUcSystem.IsHasAllExcahnge()
  if not EveryDayUcSystem.exchangeData then
    return true
  end
  if #EveryDayUcSystem.exchangeData < 0 then
    return true
  end
  local len = #EveryDayUcSystem.exchangeData
  for index = 1, len do
    local data = EveryDayUcSystem.exchangeData[index]
    if data.hasExchangeCount < data.timeLimits then
      return false
    end
  end
  return true
end
function EveryDayUcSystem.LoadRedPointTable()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local actJson = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eEveryDayPackUC)
  return actJson
end
function EveryDayUcSystem.IsToday(type)
  local actJson = EveryDayUcSystem.LoadRedPointTable()
  local lastTime = 0
  if LocalizeResTimeType.faceType == type then
    if not actJson then
      lastTime = 0
    elseif not actJson.faceTime then
      lastTime = 0
    else
      lastTime = actJson.faceTime
    end
  elseif LocalizeResTimeType.redpointType == type then
    if not actJson then
      lastTime = 0
    elseif not actJson.lastTime then
      lastTime = 0
    else
      lastTime = actJson.lastTime
    end
  end
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  local cuurTime = math.floor(now / 86400)
  if lastTime < cuurTime or lastTime == 0 then
    return false
  end
  return true
end
function EveryDayUcSystem.GetPropNumData()
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local propNum = wardrobe_data:GetHallDepotItemCountByResID(EveryDayUcSystem.propId)
  return propNum
end
function EveryDayUcSystem.ShouldSlap()
  if EveryDayUcSystem.activityId == -1 or not EveryDayUcSystem.exchangeData then
    log(bWriteLog and "EveryDayUcSystem.ShouldSlap no activityData")
    return false
  end
  if not EveryDayUcSystem.IsActivityTime() then
    return false
  end
  if EveryDayUcSystem.IsToday(LocalizeResTimeType.faceType) then
    return false
  end
  EveryDayUcSystem.isFaceSlap = true
  return true
end
return EveryDayUcSystem