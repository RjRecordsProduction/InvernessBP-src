local StoreSubscriptData = {}
local StoreUtils = require("client.slua.logic.store.utils.store_utils")
local subscriptInfo = {
  [StoreConst.Page_New_ID_Recommend] = {
    [StoreConst.subtype_new_recommend_ucb] = {},
    [StoreConst.subtype_new_recommend_dol] = {}
  }
}
local rawInfo
local bInit = true
function StoreSubscriptData.GetSubscriptInfo()
  if bInit and rawInfo then
    StoreSubscriptData.SetSubscriptInfo()
  end
  return subscriptInfo
end
function StoreSubscriptData.SetSubscriptInfo()
  if not rawInfo then
    return
  end
  local tabId = rawInfo[StoreConst.label_market_index_id]
  local itemList = rawInfo[StoreConst.label_market_index_market_list]
  local logic_subscribe_handler = require("client.slua.logic.subscribe.logic_subscribe_handler")
  local bIsByPrime, priceData = logic_subscribe_handler.GetIsBuyPrimeAndPrice()
  for shopID, itemData in pairs(itemList) do
    local subTab = itemData[StoreConst.label_item_index_page_id] or 0
    for subTabId, subscript in pairs(subscriptInfo[StoreConst.Page_New_ID_Recommend]) do
      if StoreSubscriptData.CheckSubTabSame(tabId, subTabId, subTab) then
        local limitData = itemData[StoreConst.label_item_index_buy_limit] or {}
        local limitInfo = StoreUtils.GetBuyLimitData(limitData, shopID)
        if limitInfo.isSoldOut ~= true then
          if not subscript[shopID] then
            subscript[shopID] = {}
          end
          if itemData[StoreConst.label_item_index_prime_gift] then
            subscript[shopID].discount = bIsByPrime and priceData.discount or 0
            subscript[shopID].isZeroUC = false
            break
          end
          local isVIP = itemData[StoreConst.label_item_index_vip] or 0
          local discountNum = itemData[StoreConst.label_item_index_discount] or 0
          local showDiscount = isVIP <= 0 and not bIsByPrime and discountNum ~= 0
          subscript[shopID].discount = showDiscount and discountNum or 0
          subscript[shopID].isZeroUC = itemData[StoreConst.label_item_index_zero_uc_mark] == 1
        end
        break
      end
    end
  end
  bInit = false
  EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_SUBSCRIPT_REF)
end
function StoreSubscriptData.CheckSubTabSame(tabId, curSubTab, checkSubTab)
  if checkSubTab ~= 0 and checkSubTab ~= curSubTab then
    return false
  end
  return true
end
function StoreSubscriptData.SetSubscriptData(info)
  local tabId = info[StoreConst.label_market_index_id]
  if tabId ~= StoreConst.Page_New_ID_Recommend then
    return
  end
  local subscriptData = subscriptInfo[tabId]
  if not subscriptData then
    return
  end
  rawInfo = info
  bInit = true
  local queue_task_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.queue_task_module)
  local task = {
    module = StoreSubscriptData,
    funcName = "SetSubscriptInfo",
    param = StoreSubscriptData,
    debugInfo = "StoreSubscriptData",
    protect = true
  }
  queue_task_module:Enqueue(queue_task_module.TaskEnum.Lobby, task)
end
function StoreSubscriptData.GetSubscriptData(tabId, subTabId)
  local isZeroUC = false
  local info = StoreSubscriptData.GetSubscriptInfo()
  if info[tabId] and info[tabId][subTabId] then
    local discount = 0
    for shopID, data in pairs(info[tabId][subTabId]) do
      if data.discount and discount < data.discount then
        discount = data.discount
      end
      if data.isZeroUC then
        isZeroUC = true
      end
    end
    return discount, isZeroUC
  end
  return 0, isZeroUC
end
function StoreSubscriptData.UpdateSubscriptData(shopID, tabId, subTabId, isSoldOut, isTakeDown)
  local info = StoreSubscriptData.GetSubscriptInfo()
  if info and info[tabId] and info[tabId][subTabId] then
    local temp = info[tabId][subTabId][shopID]
    if temp and (isSoldOut or isTakeDown) then
      temp.discount = 0
      temp.isZeroUC = false
    end
  end
  EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_SUBSCRIPT_REF)
end
function StoreSubscriptData.ClearSubscriptData()
  local info = StoreSubscriptData.GetSubscriptInfo()
  for tab, data in pairs(info) do
    for subTab, vv in pairs(data) do
      data[subTab] = {}
    end
  end
end
function StoreSubscriptData.FillBehindItemDiscountNum(tabId, subTabId, shopID, isSoldOut, discount, isZeroUC)
  local info = StoreSubscriptData.GetSubscriptInfo()
  if info and info[tabId] and info[tabId][subTabId] then
    if not info[tabId][subTabId][shopID] then
      info[tabId][subTabId][shopID] = {}
    end
    local temp = info[tabId][subTabId][shopID]
    if isSoldOut ~= true and (temp.discount ~= discount or temp.isZeroUC ~= isZeroUC) then
      temp.discount = discount or 0
      temp.      EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_SUBSCRIPT_REF)
    end
  end
end
return StoreSubscriptData