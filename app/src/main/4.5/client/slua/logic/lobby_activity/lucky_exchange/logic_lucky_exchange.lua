local logic_lucky_exchange = {
  ActivityID = nil,
  ActivityList = {},
  ExchangeItemList = {},
  ExchangeCurrencyCount = {},
  CurItemIDList = {},
  tExchangeNewRedList = {}
}
function logic_lucky_exchange.OpenExchange(Key, ActivityID, extraData)
  log(bWriteLog and "logic_lucky_exchange.OpenExchange" .. tostring(ActivityID))
  logic_lucky_exchange.ActivityList[ActivityID] = true
  logic_lucky_exchange.  logic_lucky_exchange.UpdateExchangeCurrencyCount(ActivityID)
  logic_lucky_exchange._ShowExchangeUIByKey(Key, ActivityID, extraData)
end
function logic_lucky_exchange.SendInfoReq(ActivityID)
  logic_lucky_exchange.ActivityList[ActivityID] = true
  logic_lucky_exchange.send_get_exchange_activity_info_req(ActivityID)
end
function logic_lucky_exchange.CloseExchangeUIByKey(Key)
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKYBACK_EXCHANGE_CLOSED)
  local lucky_exchange_config = require("client.slua.logic.lobby_activity.lucky_exchange.lucky_exchange_config")
  local ModuleName = lucky_exchange_config.UIConfig[Key]
  if ModuleName then
    UIManager.CloseUI(UIManager.UI_Config[ModuleName])
  end
end
function logic_lucky_exchange.SetCurSelectItemID(ActivityID, ItemID)
  logic_lucky_exchange.CurItemIDList[ActivityID] = ItemID
end
function logic_lucky_exchange.GetCurSelectItemID(ActivityID)
  return logic_lucky_exchange.CurItemIDList[ActivityID]
end
function logic_lucky_exchange.GetExchangeDataList(ActivityID)
  return logic_lucky_exchange.ExchangeItemList[ActivityID]
end
function logic_lucky_exchange.GetExchangeCurrentyID(ActivityID)
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local data = ActivityNewSystem.GetServerDataByID(ActivityID)
  if data and data.cfg.award and data.cfg.award[1] then
    local tmpcond = StrSplit(data.cfg.award[1].cond, ",")
    if tmpcond[1] then
      local itemId = tonumber(tmpcond[1])
      return itemId
    end
  end
  return 0
end
function logic_lucky_exchange.IsInActicityList(ActivityID)
  return logic_lucky_exchange.ActivityList[ActivityID]
end
function logic_lucky_exchange.send_get_exchange_activity_info_req(ActivityID)
  local LuckybackHandler = require("client.network.Protocol.LuckybackHandler")
  LuckybackHandler.send_get_exchange_activity_info_req(tonumber(ActivityID))
end
local formatItem = function(itemId, count, validTime)
  return string.format("%s_%s_%s", itemId, count, validTime)
end
function logic_lucky_exchange.on_get_exchange_activity_info_rsp(exchange_table, mydata, activity_id, discount_cfg, sheet_shield_cfg)
  log_tree("exchange_table", exchange_table)
  log_tree("mydata", mydata)
  local ItemList = {}
  local tNewRedList = {}
  local hasExchanges = mydata and mydata.new_limit_exchange_info or {}
  local tRedPointClearFlag = mydata and mydata.red_point_del_flag or {}
  local region = FuncUtil.GetAccountRegionForBP()
  for i, v in pairs(exchange_table) do
    local isInExchange = true
    if sheet_shield_cfg and sheet_shield_cfg[v.exchange_sheet_id] then
      local shieldData = sheet_shield_cfg[v.exchange_sheet_id]
      if shieldData[0] and shieldData[0][region] then
        isInExchange = false
      end
      if shieldData[v.pos_id] and shieldData[v.pos_id][region] then
        isInExchange = false
      end
    end
    if isInExchange then
      local sExchangeDataKey = formatItem(v.award_item_id, v.award_item_num, v.award_item_valid_time)
      local exchangeItem = {
        itemId = v.award_item_id,
        itemNum = v.award_item_num,
        needItemId = v.need_item_id,
        needItemNum = v.need_item_num,
        timeLimits = v.exchange_times_limit,
        iconCDNPath = v.award_picture_cdn,
        pos = v.pos_id,
        discount = v.discount,
        validTime = v.award_item_valid_time or 0,
        startTime = v.start_time or 0,
        isNew = v.is_new or false,
        hasExchangeCount = hasExchanges[sExchangeDataKey] or 0,
        exchange_sheet_id = v.exchange_sheet_id or 1,
        original_price = v.original_price,
        pre_item_list = v.pre_item_list,
        post_item_list = v.post_item_list,
        pre_local_text = v.pre_local_text,
        post_local_text = v.post_local_text
      }
      if tRedPointClearFlag and tRedPointClearFlag[sExchangeDataKey] then
        tNewRedList[sExchangeDataKey] = true
      end
      table.insert(ItemList, exchangeItem)
    end
  end
  table.sort(ItemList, function(a, b)
    return a.pos < b.pos
  end)
  logic_lucky_exchange.ExchangeItemList[activity_id] = ItemList
  logic_lucky_exchange.tExchangeNewRedList[activity_id] = tNewRedList
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKY_EXCHANGE_REFRESH, activity_id)
end
function logic_lucky_exchange:GetExchangeNewRedData(activity_id)
  return logic_lucky_exchange.tExchangeNewRedList[activity_id]
end
function logic_lucky_exchange.UpdateExchangeNewRedList(activity_id, tNewRedData)
  local logic_scrapgold_draw = require("client.slua.logic.lobby_activity.logic_scrapgold_draw")
  local activityID = activity_id or logic_scrapgold_draw.exchange_act_id
  if not logic_lucky_exchange.tExchangeNewRedList[activityID] then
    logic_lucky_exchange.tExchangeNewRedList[activityID] = {}
  end
  local redData = logic_lucky_exchange.tExchangeNewRedList[activityID]
  local newRedList = tNewRedData.red_point_del_flag
  for key, v in pairs(newRedList) do
    redData[key] = v
  end
end
local _FormatData = function(data)
  local arrayItemList = {}
  for i, v in pairs(data) do
    local arrayItem = {
      res_id = v.resid,
      expire_ts = v.expire_ts or 0,
      valid_hours = v.valid_hours or 0,
      count = v.count
    }
    table.insert(arrayItemList, arrayItem)
  end
  return arrayItemList
end
function logic_lucky_exchange.on_do_exchange_by_activity_id_rsp(myData, award_info, activity_id)
  if not activity_id then
    return
  end
  log(bWriteLog and "on_do_exchange_by_activity_id_rsp activity_id" .. tostring(activity_id))
  local arrayItemList = _FormatData(award_info)
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(arrayItemList)
  local hasExchanges = myData and myData.new_limit_exchange_info or {}
  local ExchangeItemList = logic_lucky_exchange.ExchangeItemList[activity_id]
  for i, v in pairs(ExchangeItemList) do
    v.hasExchangeCount = hasExchanges[formatItem(v.itemId, v.itemNum, v.validTime)] or 0
  end
  if UIManager.IsUIShow(UIManager.UI_Config.Common_Exchange_Confirm_UIBP) then
    UIManager.CloseUI(UIManager.UI_Config.Common_Exchange_Confirm_UIBP)
  end
  logic_lucky_exchange.UpdateExchangeCurrencyCount(activity_id)
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKY_EXCHANGE_REFRESH, activity_id)
  local LuckybackActivitySystem = require("client.slua.logic.lobby_activity.logic_luckyback_activity")
  LuckybackActivitySystem.UpdateDebrisCount()
  local TarotCardDrawCardSystem = require("client.slua.logic.tarot_card.logic_tarotcard_drawcard")
  TarotCardDrawCardSystem.UpdateDebrisCount()
end
function logic_lucky_exchange._ShowExchangeUIByKey(Key, ActivityID, extraData)
  local lucky_exchange_config = require("client.slua.logic.lobby_activity.lucky_exchange.lucky_exchange_config")
  local Config = lucky_exchange_config.UIConfig[Key]
  log(bWriteLog and "[jinqiang] Config.Key == " .. tostring(Key))
  if Config then
    UIManager.ShowUI(UIManager.UI_Config[Config], ActivityID, extraData)
  end
end
function logic_lucky_exchange.UpdateExchangeCurrencyCount(ActivityID)
  local ExchangeCurrentyID = logic_lucky_exchange.GetExchangeCurrentyID(ActivityID)
  if not ExchangeCurrentyID then
    return
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemData = wardrobe_data:GetHallDepotItemDataByResIDAndValidExpireTime(ExchangeCurrentyID)
  if itemData then
    logic_lucky_exchange.ExchangeCurrencyCount[ActivityID] = itemData.count or 0
  else
    logic_lucky_exchange.ExchangeCurrencyCount[ActivityID] = 0
  end
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_LUCKY_EXCHANGE_COUNT_CHANGE)
end
function logic_lucky_exchange.GetExchangeCurrentyCount(ActivityID)
  local ExchangeCurrentyID = logic_lucky_exchange.GetExchangeCurrentyID(ActivityID)
  if not ExchangeCurrentyID then
    return 0
  end
  local ExchangeCurrentyCount = logic_lucky_exchange.ExchangeCurrencyCount[ActivityID] or 0
  return ExchangeCurrentyCount
end
return logic_lucky_exchange