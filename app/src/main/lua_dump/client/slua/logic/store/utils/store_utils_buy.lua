local StoreUtils = require("client.slua.logic.store.utils.store_utils_config")
local _tMoneyTypeToItemId = {
  [StoreConst.label_price_type_bp] = 1000,
  [StoreConst.label_price_type_chip] = 1001,
  [StoreConst.label_price_type_uc] = 1006,
  [StoreConst.label_price_type_battle] = 1103,
  [StoreConst.label_price_type_diamond] = 1109,
  [StoreConst.label_price_type_fp] = 1101,
  [StoreConst.label_price_type_gold_chip] = 1104
}
local _tItemIdToMoneyType = {
  [1000] = StoreConst.label_price_type_bp,
  [1001] = StoreConst.label_price_type_chip,
  [1006] = StoreConst.label_price_type_uc,
  [1103] = StoreConst.label_price_type_battle,
  [1109] = StoreConst.label_price_type_diamond,
  [1101] = StoreConst.label_price_type_fp,
  [1104] = StoreConst.label_price_type_gold_chip
}
function StoreUtils.MoneyTypeToItemId(nMoneyType)
  if nMoneyType == StoreConst.label_price_type_gold_suit then
    local logic_xsuit_activity = ModuleManager.GetModule(ModuleManager.JumpModuleConfig.logic_xsuit_activity)
    return logic_xsuit_activity:GetDrawCurrencyID()
  end
  return _tMoneyTypeToItemId[nMoneyType]
end
function StoreUtils.ItemIdToMoneyType(nItemId)
  return _tItemIdToMoneyType[nItemId]
end
function StoreUtils.PurchaseItem(ShopInfo, selectedMoneyType, extraData)
  local BuyInfo = StoreUtils.GetBuyInfo(ShopInfo.id)
  local cfg = CDataTable.GetTableData("Item", ShopInfo.item_id)
  if not cfg then
    log(bWriteLog and "StoreOtherUtils.PurchaseItem cfg nil itemid = " .. tostring(ShopInfo.item_id))
    return
  end
  local curDiscountLimit = StoreConst.buy_info[ShopInfo.id] and StoreConst.buy_info[ShopInfo.id].daily_buy_cnt or 0
  local canBuyWithCount = ShopInfo.discountLimit and ShopInfo.disCountPrice and ShopInfo.discountDisplay and curDiscountLimit >= ShopInfo.discountLimit or not ShopInfo.discountLimit
  if StoreUtils.IsWithCount(cfg.ItemType, cfg.ItemSubType) and canBuyWithCount then
    local store_buy_utils = require("client.slua.umg.NewStoreV280.NewStoreMove.buy.store_buy_utils")
    local tBuyData = store_buy_utils.GetBuyUIInfo(ShopInfo, BuyInfo)
    StoreUtils.ShowBuyPanel(ShopInfo, tBuyData)
  elseif cfg.ItemSubType == ENUM_ITEM_SUBTYPE.SuitBox then
  else
    UIManager.ShowUI(UIManager.UI_Config.Store_Buy_Slua_BP, ShopInfo, BuyInfo, selectedMoneyType, extraData)
  end
end
function StoreUtils.IsSoldOut(shopId, DayLimit, WeekLimit, PermanentLimit)
  local itemBuyInfo = StoreUtils.GetBuyInfo(shopId)
  local store_limit_buy_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_limit_buy_manager)
  local _, backuserCanBuyCnt = store_limit_buy_manager:GetBackUserPrivilege(shopId)
  if backuserCanBuyCnt <= 0 then
    _, backuserCanBuyCnt = store_limit_buy_manager:GetCollectPrivilege(shopId)
  end
  local _, rpPlusCanBuyCnt = store_limit_buy_manager:GetRPPlusPrivilege(shopId)
  backuserCanBuyCnt = backuserCanBuyCnt + rpPlusCanBuyCnt
  if 0 < backuserCanBuyCnt then
    return false
  end
  if DayLimit and 0 < DayLimit and DayLimit <= itemBuyInfo.daily_buy_cnt then
    return true
  end
  if WeekLimit and 0 < WeekLimit and WeekLimit <= itemBuyInfo.week_buy_cnt then
    return true
  end
  if PermanentLimit and 0 < PermanentLimit and PermanentLimit <= itemBuyInfo.permanet_buy_cnt then
    return true
  end
  return false
end
function StoreUtils.BuyItem(itemInfo, tabID, subTabID, selectedMoneyType)
  local JumpUtils = require("client.logic.store.jump_utils")
  if not itemInfo then
    log_error("[edward][store_utils] StoreOtherUtils.BuyItem, itemInfo = nil")
    return
  end
  local PurchaseCallBack = function()
    local shopInfo = StoreUtils.ConvertToShopInfo(itemInfo, tabID, subTabID)
    StoreUtils.PurchaseItem(shopInfo, selectedMoneyType)
  end
  local itemID = itemInfo[StoreConst.label_item_index_id]
  if StoreUtils.IsExist(itemID) and StoreUtils.CheckCanShowJumpChestByTabId(tabID) then
    local JumpToChestCallBack = function()
      local chestID = JumpUtils.GetJumpToChestItemId(itemID)
      local jump = JumpUtils.FindJumpInfoFirst(chestID, JumpUtils.MODEL_ID_STORE)
      local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
      local frame = store_supply_manager:GetCurrentFrame()
      frame:GotoSpecifiedTabAndItem(jump.Tab1, jump.Tab2, jump.itemId)
    end
    local title = LocUtil.GetLocalizeResStr(101001)
    local content = LocUtil.GetLocalizeResStr(6899)
    local ok = LocUtil.GetLocalizeResStr(6900)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, title, content, JumpToChestCallBack, PurchaseCallBack, ok)
  else
    PurchaseCallBack()
  end
end
function StoreUtils.BuyItemByID(itemID, shopInfo, selectedMoneyType)
  local JumpUtils = require("client.logic.store.jump_utils")
  local PurchaseCallBack = function()
    StoreUtils.PurchaseItem(shopInfo, selectedMoneyType)
  end
  if StoreUtils.IsExist(itemID) then
    local JumpToChestCallBack = function()
      local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
      local frame = store_supply_manager:GetCurrentFrame()
      local jump = JumpUtils.FindJumpInfoFirst(itemID, JumpUtils.MODEL_ID_STORE)
      frame:GotoSpecifiedTabAndItem(jump.Tab1, jump.Tab2, jump.itemId)
    end
    local title = LocUtil.GetLocalizeResStr(101001)
    local content = LocUtil.GetLocalizeResStr(6899)
    local ok = LocUtil.GetLocalizeResStr(6900)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, title, content, JumpToChestCallBack, PurchaseCallBack, ok)
  else
    PurchaseCallBack()
  end
end
function StoreUtils.IsExist(itemId)
  local JumpUtils = require("client.logic.store.jump_utils")
  local chestItemId = JumpUtils.GetJumpToChestItemId(itemId)
  if chestItemId ~= -1 then
    return true
  else
    return false
  end
end
function StoreUtils.IsHideQuality(nItemId, nTab, nSubTab)
  if nTab ~= StoreConst.Page_New_ID_Recommend then
    return false
  end
  if nSubTab ~= StoreConst.subtype_new_recommend_ucb then
    return false
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local uObj_itemCfg = CDataTable.GetTableData("Item", nItemId)
  if StoreUtils.IsTreasuresAndSpecialChests(uObj_itemCfg.ItemType, uObj_itemCfg.ItemSubType) then
    return true
  end
  return false
end
function StoreUtils.CheckShowCoupon(tShopData, tBuyData)
  if not tShopData or not tBuyData then
    return false
  end
  if tShopData.isPreferencesGift then
    log(bWriteLog and string.format("preferences gift cannot use coupons."))
    return false
  end
  if tShopData.isZeroUC then
    log(bWriteLog and string.format("zero uc gift cannot use coupons."))
    return false
  end
  local tPriceList = tBuyData.priceListMap and tBuyData.priceListMap[1]
  if not tPriceList or tPriceList.moneyType ~= 2 then
    return false
  end
  return true
end
function StoreUtils.GetIsSubscribeUnlock(tPriceItem)
  if tPriceItem.isVipItem then
    local logic_subscribe_handler = require("client.slua.logic.subscribe.logic_subscribe_handler")
    local subscribeModuleObj = logic_subscribe_handler.GetSubscribeModuleObj()
    local status = subscribeModuleObj:GetSubStatus()
    local SubscribeEnumConfig = require("client.slua.logic.subscribe.logic_subscribe_enum_config")
    if status == SubscribeEnumConfig.ENUM_SubStatus.NONE then
      return true
    end
  end
  return false
end
function StoreUtils.ConvertToBuyReqData(tBuyData, nSelectCount, nCouponId)
  local tReqData = {}
  tReqData[StoreConst.label_buy_param_id] = tBuyData.shopId
  tReqData[StoreConst.label_buy_param_price_type] = tBuyData.moneyType
  tReqData[StoreConst.label_buy_param_tab_id] = tBuyData.tab_id
  tReqData[StoreConst.label_buy_param_sub_id] = tBuyData.sub_id
  tReqData[StoreConst.label_buy_param_ver] = StoreConst.store_version
  tReqData[StoreConst.label_buy_param_valid_hours] = 0
  tReqData[StoreConst.label_buy_param_count] = nSelectCount
  if nCouponId and 0 < nCouponId then
    tReqData[StoreConst.label_buy_param_voucher] = nCouponId
  end
  return tReqData
end
function StoreUtils.OnBuyBtnClickHandle(tExchangeData, nSelectCount, _, tCouponData)
  if nSelectCount > tExchangeData.timeLimits then
    if tExchangeData.limitType == 1 then
      ShowNotice(4350)
    elseif tExchangeData.limitType == 2 then
      ShowNotice(4351)
    elseif tExchangeData.limitType == 3 then
      ShowNotice(4352)
    end
    return
  end
  local fCallback = function()
    local tReqData = StoreUtils.ConvertToBuyReqData(tExchangeData, nSelectCount, tCouponData.nCouponId)
    local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
    store_supply_manager:buy_market_by_id_req(tReqData)
  end
  local nCurPrice = tExchangeData.needItemNum
  local PriceList = {
    {
      Type = tExchangeData.moneyType,
      Price = nCurPrice,
      Num = nSelectCount
    }
  }
  if tCouponData.nCouponDisCount and tCouponData.nCouponDisCount > 0 then
    StoreUtils.CheckMoney(fCallback, PriceList, tCouponData.nCouponDisCount)
  else
    StoreUtils.CheckMoney(fCallback, PriceList)
  end
end
function StoreUtils.OnSubscribeBtnClickHandle()
  local store_buy_utils = require("client.slua.umg.NewStoreV280.NewStoreMove.buy.store_buy_utils")
  store_buy_utils.JumpToSubscribe(UIManager.UI_Config.Common_Exchange_Confirm_UIBP)
end
function StoreUtils.ShowBuyPanel(tShopData, tBuyData)
  local nItemId = tShopData.item_id
  local nTabID = tShopData.tab_id
  local nSubTabID = tShopData.sub_id
  local bIsHideQuality = StoreUtils.IsHideQuality(nItemId, nTabID, nSubTabID)
  local tPriceItem = tBuyData.priceListMap and tBuyData.priceListMap[1]
  if not tPriceItem then
    log(bWriteLog and " StoreUtils.PurchaseItem >>> Not Price Data")
    return
  end
  local nPrice = tPriceItem.priceList[1]
  if not nPrice then
    log(bWriteLog and "  StoreUtils.PurchaseItem >>> Not nPrice")
    return
  end
  local bIsShowCoupon = StoreUtils.CheckShowCoupon(tShopData, tBuyData)
  local bIsSubscribe = StoreUtils.GetIsSubscribeUnlock(tPriceItem)
  local nBtnKey = 43327
  local fCallback = StoreUtils.OnBuyBtnClickHandle
  if bIsSubscribe then
    nBtnKey = 13107
    fCallback = StoreUtils.OnSubscribeBtnClickHandle
  end
  local nMoneyType = tPriceItem.moneyType
  local nNeedItemId = StoreUtils.MoneyTypeToItemId(nMoneyType) or nMoneyType
  local tExchangeData = {
    itemId = nItemId,
    itemNum = 0,
    validTime = 0,
    timeLimits = tBuyData.limitCount,
    hasExchangeCount = 0,
    needItemId = nNeedItemId,
    needItemNum = nPrice,
    shopId = tShopData.id,
    tab_id = nTabID,
    sub_id = nSubTabID,
    moneyType = nMoneyType,
    limitType = tBuyData.limitType
  }
  local tExtra = {
    sTitle = LocUtil.GetLocalizeResStr(43327),
    sExchangeBtnText = LocUtil.GetLocalizeResStr(nBtnKey),
    bIsHideCommonItemQuality = bIsHideQuality,
    bIsShowCoupon = bIsShowCoupon,
    bIsHideUpperLimitText = true,
    fExchangeCallback = fCallback,
    nShowAddCount = 10,
    bIsHideAddMaxBtn = true
  }
  UIManager.ShowUI(UIManager.UI_Config.Common_Exchange_Confirm_UIBP, tExchangeData, tExtra)
end