local StoreUtils = require("client.slua.logic.store.utils.store_utils_config")
local exchangeSortNumMap = {
  [1] = -10,
  [9] = -9
}
local recommendSubTab = {
  [StoreConst.subtype_new_recommend_rec] = true,
  [StoreConst.subtype_new_recommend_ucb] = true,
  [StoreConst.subtype_new_recommend_dol] = true
}
function StoreUtils.GetSortNumByExchange(data)
  if exchangeSortNumMap[data.itemType] ~= nil then
    return exchangeSortNumMap[data.itemType]
  end
  return data.itemSubType
end
function StoreUtils.SortNewTreasurePage(list, tabId)
  if not list then
    return
  end
  for _, data in pairs(list) do
    if data.isSubDailyGift then
      local logic_subscribe_handler = require("client.slua.logic.subscribe.logic_subscribe_handler")
      local subscribeModuleObj = logic_subscribe_handler.GetSubscribeModuleObj()
      if subscribeModuleObj:IsBuyPrime() and not subscribeModuleObj:Get_Discount_Is_Could_Buy() then
        data.isSoldOut = true
      end
    end
  end
  local sortFunc = function(a, b)
    if a.isSoldOut == b.isSoldOut then
      if a.isPreferencesGift == b.isPreferencesGift then
        local isLess_A = StoreUtils.IsLessThanThreeDays(a)
        local isLess_B = StoreUtils.IsLessThanThreeDays(b)
        if isLess_A == isLess_B then
          if isLess_A then
            if a.leftTime == b.leftTime then
              return StoreUtils.BySort(a, b)
            else
              return a.leftTime < b.leftTime
            end
          end
          return StoreUtils.BySort(a, b)
        else
          return isLess_A
        end
      else
        return a.isPreferencesGift
      end
    else
      return b.isSoldOut
    end
  end
  local sort_have = function(a, b)
    local haveWithOutLimit_A = a.have and a.purchaseLimitNum == 0
    local haveWithOutLimit_B = b.have and b.purchaseLimitNum == 0
    if haveWithOutLimit_A == haveWithOutLimit_B then
      local bSoldOut_A = a.isSoldOut and a.purchaseLimitNum > 0 and a.hasPurchaseNum == a.purchaseLimitNum
      local bSoldOut_B = b.isSoldOut and b.purchaseLimitNum > 0 and b.hasPurchaseNum == b.purchaseLimitNum
      if bSoldOut_A == bSoldOut_B then
        return sortFunc(a, b)
      else
        return bSoldOut_B
      end
    else
      return haveWithOutLimit_B
    end
  end
  if tabId and tabId == StoreConst.Page_New_ID_Treasure then
    table.sort(list, sort_have)
  elseif tabId and StoreUtils.IsKrJpTreasure(tabId) then
    table.sort(list, sort_have)
  else
    table.sort(list, sortFunc)
  end
end
function StoreUtils.IsLessThanThreeDays(data)
  if data == nil or data.leftTime == nil or type(data.leftTime) ~= "number" or data.leftTime == 0 then
    return false
  end
  return data.leftTime < 259200
end
function StoreUtils.BySort(a, b)
  if a.sort == b.sort then
    return a.shopId > b.shopId
  else
    return a.sort > b.sort
  end
end
function StoreUtils.SortPrimePage(list)
  if not list then
    return
  end
  local version_util = require("client.common.version_util")
  local sort_ver = function(a, b)
    local a_ver = a.putVersion or ""
    local b_ver = b.putVersion or ""
    if a_ver ~= "" and b_ver ~= "" then
      if a_ver == b_ver then
        return a.shopId > b.shopId
      end
      return version_util.HigherVersion(a_ver, b_ver)
    else
      if a_ver ~= "" then
        return true
      end
      if b_ver ~= "" then
        return false
      end
      return a.shopId > b.shopId
    end
  end
  local sort_time = function(a, b)
    local a_t = a.startTime or 0
    local b_t = b.startTime or 0
    if a_t ~= 0 and b_t ~= 0 then
      if a_t == b_t then
        return sort_ver(a, b)
      end
      return a_t > b_t
    else
      if a_t ~= 0 then
        return true
      end
      if b_t ~= 0 then
        return false
      end
      return sort_ver(a, b)
    end
  end
  local sort_s = function(a, b)
    if a.have == b.have then
      if a.sort == b.sort then
        return sort_time(a, b)
      end
      return a.sort > b.sort
    else
      return b.have
    end
  end
  table.sort(list, sort_s)
end
function StoreUtils.GetTreasureSubTab()
  if GlobalData.IsJapanOrKorea() then
    return StoreConst.label_subtype_treasure
  else
    return StoreConst.subtype_new_treasure_com
  end
end
function StoreUtils.GetDirectBuyTab()
  if GlobalData.IsJapanOrKorea() then
    return StoreConst.Page_ID_Item
  else
    return StoreConst.Page_New_ID_Treasure
  end
end
function StoreUtils.IsSpecialMaterialPack(tabID)
  if tabID == StoreConst.Page_Special_Material_Pack then
    return true
  end
  return false
end
function StoreUtils.IsDirectBuyTab(tabID)
  if tabID == StoreConst.Page_ID_Item then
    return true
  end
  if tabID == StoreConst.Page_New_ID_Treasure then
    return true
  end
  return false
end
function StoreUtils.IsUCSpecialPackageTab(tabId, subTabID)
  if tabId == StoreConst.Page_New_ID_Recommend and subTabID == StoreConst.subtype_new_recommend_ucb then
    return true
  end
  return false
end
function StoreUtils.IsSubscribeLimitTab(tabId, subTabID)
  if tabId == StoreConst.Page_New_ID_Recommend and (subTabID == StoreConst.subtype_new_recommend_lim or subTabID == StoreConst.subtype_new_recommend_lim_In) then
    return true
  end
  return false
end
function StoreUtils.IsPrimeTab(tabID, subTabID)
  if tabID == StoreConst.Page_ID_Collect then
    return true
  end
  if tabID == StoreConst.Page_New_ID_Exchange and subTabID == StoreConst.subtype_new_exchange_bps then
    return true
  end
  return false
end
function StoreUtils.IsCollectTab(tabID, subTabID)
  if GlobalData.IsJapanOrKorea() then
    if tabID == StoreConst.Page_ID_Collect then
      return true
    end
  elseif tabID == StoreConst.Page_New_ID_Recommend and subTabID == StoreConst.subtype_new_recommend_col then
    return true
  end
  return false
end
function StoreUtils.IsVoiceCard(ItemId)
  local itemCfg = CDataTable.GetTableData("Item", ItemId)
  if not itemCfg then
    return false
  end
  return itemCfg.ItemType == ENUM_ITEM_TYPE.Voice_Pack and itemCfg.ItemSubType == 1901
end
function StoreUtils.CheckHaveSubTab(nTab, nSubTab)
  local storeList = StoreConst.store_data.store_list
  local nSubTabList = StoreConst.label_market_index_sub_list
  local TableUtil = require("common.table_util")
  return TableUtil.GetTableValue(storeList, nTab, nSubTabList, nSubTab)
end
function StoreUtils.CheckRecommendTab(tabID, subTabID)
  if not (tabID and subTabID) or tabID <= 0 or subTabID <= 0 then
    return false
  end
  if tabID ~= StoreConst.Page_New_ID_Recommend then
    return false
  end
  if recommendSubTab[subTabID] then
    return true
  end
  return false
end