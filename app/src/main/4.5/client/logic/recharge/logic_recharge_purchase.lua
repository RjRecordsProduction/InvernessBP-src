local RechargePurchaseSystem = {
  purchase_type_uc = 2,
  purchase_type_cash = 10,
  purchase_save_string = "RechargePurchaseSave",
  limitedPaks = {},
  nHadItemId = nil
}
RechargePurchaseSystem.dropList = {}
RechargePurchaseSystem.SelectedNumber = 0
RechargePurchaseSystem.SelectedRechargeInfo = {}
RechargePurchaseSystem.RechargeInfoList = {}
RechargePurchaseSystem.RechargeInfoArray = {}
RechargePurchaseSystem.NeedShowRedDot = false
RechargePurchaseSystem.SelectedId = 0
local DirectPurchaseItemList = {}
local RedDotInfoList = {}
function RechargePurchaseSystem.Init()
end
function RechargePurchaseSystem.Destroy()
end
function RechargePurchaseSystem.RefreshActivityInfo(eventType, eventID, changeList)
  if not changeList then
    return
  end
  if changeList.typeList[ActivityType.ACTIVITY_TYPE_KRJP_PURCHASE] == true then
    log_tree("RechargePurchaseSystem.RefreshActivityInfo Purchase Info Changes!")
    local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
    DirectPurchaseItemList = {}
    local activity = ActivityNewSystem.GetActivityListByType(ActivityType.ACTIVITY_TYPE_KRJP_PURCHASE)
    if activity then
      for _, v in ipairs(activity) do
        RechargePurchaseSystem.ConvertActDataToPurchaseInfo(v)
      end
    end
    if #DirectPurchaseItemList ~= 0 then
      RechargePurchaseSystem.GetPurchaseInfoReq(DirectPurchaseItemList)
    else
      RechargePurchaseSystem.SortRechargeInfoList()
    end
    RechargePurchaseSystem.LoadRechargePurchaseInfo()
  end
end
function RechargePurchaseSystem.GetTimePeriod(startTime, endTime)
  local TimeUtil = require("client.common.time_util")
  return TimeUtil.FormatTime_timeFrame(startTime, endTime, false, true)
end
function RechargePurchaseSystem.ClearInfo()
  log(bWriteLog and "RechargePurchaseSystem.ClearInfo")
  RechargePurchaseSystem.dropList = {}
  RechargePurchaseSystem.SelectedNumber = 0
  RechargePurchaseSystem.SelectedRechargeInfo = {}
  RechargePurchaseSystem.RechargeInfoList = {}
  RechargePurchaseSystem.RechargeInfoArray = {}
  RechargePurchaseSystem.NeedShowRedDot = false
end
function RechargePurchaseSystem.ConvertActDataToPurchaseInfo(actData)
  log_tree("RechargePurchaseSystem.ConvertActDataToPurchaseInfo", actData)
  local info = actData.Condition
  local recommendItem = {}
  local tmpcond = StrSplit(info, ",")
  local TimeUtil = require("client.common.time_util")
  if actData.EndTime <= TimeUtil.GetServerTimeInSec() then
    log_error("RechargePurchaseSystem.ConvertActDataToPurchaseInfo timeout!!! activityid : " .. actData.ID)
    if RechargePurchaseSystem.RechargeInfoList[actData.ID] ~= nil then
      RechargePurchaseSystem.RechargeInfoList[actData.ID] = nil
      return
    end
    if RechargePurchaseSystem.limitedPaks[actData.ID] then
      RechargePurchaseSystem.limitedPaks[actData.ID] = nil
      return
    end
  end
  recommendItem.packId = tonumber(tmpcond[1])
  recommendItem.purchaseType = tonumber(tmpcond[2])
  if recommendItem.purchaseType ~= RechargePurchaseSystem.purchase_type_uc and recommendItem.purchaseType ~= RechargePurchaseSystem.purchase_type_cash then
    log_error("RechargePurchaseSystem.ConvertActDataToPurchaseInfo type Error!! activityid :" .. actData.ID .. "|| type : " .. recommendItem.purchaseType)
    return
  end
  if recommendItem.purchaseType == RechargePurchaseSystem.purchase_type_uc then
    local chestItemId = recommendItem.packId
    recommendItem.itemId = chestItemId
    if chestItemId ~= 0 then
      local cfg = CDataTable.GetTableData("Item", chestItemId)
      if cfg then
        recommendItem.name = cfg.ItemName
      else
        recommendItem.name = ""
      end
    end
  elseif recommendItem.purchaseType == RechargePurchaseSystem.purchase_type_cash then
    table.insert(DirectPurchaseItemList, recommendItem.packId)
  end
  recommendItem.iconPath = actData.ImgUrl or ""
  recommendItem.rateUrl = actData.ImgLink or ""
  recommendItem.num = tonumber(tmpcond[3])
  if actData.other and next(actData.other) ~= nil then
    recommendItem.leftnum = recommendItem.num - actData.other.times
  else
    recommendItem.leftnum = recommendItem.num
  end
  recommendItem.price = tonumber(tmpcond[4])
  recommendItem.startTime = actData.StartTime
  recommendItem.endTime = actData.EndTime
  recommendItem.activityId = actData.ID
  recommendItem.alreadyhad = tonumber(tmpcond[8])
  if 0 < recommendItem.alreadyhad then
    local onGetChestRsp = function(_, data)
      RechargePurchaseSystem.nHadItemId = data[1].DropItemID
    end
    local BasicDataChestTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataChestTable)
    BasicDataChestTable:GetOrReqData(recommendItem.packId, onGetChestRsp)
  end
  if actData.LabelType == 1 then
    recommendItem.tag = 2
  elseif actData.LabelType == 5 then
    recommendItem.tag = 1
  else
    recommendItem.tag = 0
  end
  if RechargePurchaseSystem.RechargeInfoList == nil then
    RechargePurchaseSystem.RechargeInfoList = {}
  end
  local limitedPak = tonumber(tmpcond[7])
  if limitedPak == 1 then
    RechargePurchaseSystem.limitedPaks[actData.ID] = recommendItem
  else
    RechargePurchaseSystem.RechargeInfoList[actData.ID] = recommendItem
  end
end
function RechargePurchaseSystem.LoadRechargePurchaseInfo()
  if next(RedDotInfoList) == nil then
    local saveString = RechargePurchaseSystem.purchase_save_string .. "_" .. DataMgr.roleData.uid
    RedDotInfoList = {}
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local data = PlayerPrefsSystem.LoadFileToTable_DynamicPath(PlayerPrefsSystem.ePlayerPrefsType.purchaseSaveString, saveString)
    if data ~= nil then
      RedDotInfoList = data
    end
  end
  log_tree("RechargePurchaseSystem.LoadRechargePurchaseInfo", RedDotInfoList)
  RechargePurchaseSystem.CheckNeedShowRedDot()
end
function RechargePurchaseSystem.SaveRechargePurchaseInfo()
  local saveString = RechargePurchaseSystem.purchase_save_string .. "_" .. DataMgr.roleData.uid
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_DynamicPath(RedDotInfoList, PlayerPrefsSystem.ePlayerPrefsType.purchaseSaveString, saveString)
  log(bWriteLog and "RechargePurchaseSystem.SaveRechargePurchaseInfo")
end
function RechargePurchaseSystem.CheckNeedShowRedDot()
  log(bWriteLog and "RechargePurchaseSystem.CheckNeedShowRedDot")
  local RechargeSystemJK = require("client.logic.recharge.logic_recharge_jk")
  RechargePurchaseSystem.NeedShowRedDot = false
  if RechargeSystemJK.IsCanShowPurchaseTab() then
    for key, info in pairs(RechargePurchaseSystem.RechargeInfoList) do
      if RedDotInfoList[tostring(info.activityId)] == nil and RedDotInfoList[tonumber(info.activityId)] == nil then
        log(bWriteLog and "RechargePurchaseSystem.CheckNeedShowRedDot not show id = " .. tostring(info.activityId))
        RechargePurchaseSystem.NeedShowRedDot = true
        EventSystem:postEvent(EVENTTYPE_RECHARGE, EVENTID_RECHARGE_PURCHASE_REDDOT_CHANGE)
        return
      end
    end
  end
end
function RechargePurchaseSystem.RefreshRedDotInfo()
  log(bWriteLog and "RechargePurchaseSystem.RefreshRedDotInfo NeedShowRedDot : " .. tostring(RechargePurchaseSystem.NeedShowRedDot))
  RechargePurchaseSystem.CheckNeedShowRedDot()
  if RechargePurchaseSystem.NeedShowRedDot == false then
    return
  end
  RechargePurchaseSystem.NeedShowRedDot = false
  for key, info in pairs(RechargePurchaseSystem.RechargeInfoList) do
    if RedDotInfoList == nil then
      RedDotInfoList = {}
    end
    RedDotInfoList[tostring(info.activityId)] = 1
  end
  RechargePurchaseSystem.SaveRechargePurchaseInfo()
  EventSystem:postEvent(EVENTTYPE_RECHARGE, EVENTID_RECHARGE_PURCHASE_REDDOT_CHANGE)
end
function RechargePurchaseSystem.SortRechargeInfoList()
  RechargePurchaseSystem.RechargeInfoArray = {}
  for k, v in pairs(RechargePurchaseSystem.RechargeInfoList) do
    local purchaseInfo = v.purchaseInfo
    if v.purchaseType == 10 and (purchaseInfo == nil or type(purchaseInfo) == "table" and not next(purchaseInfo)) then
      log(bWriteLog and "RechargePurchaseSystem.SortRechargeInfoList purchaseInfo is null ,id = " .. v.activityId)
    else
      table.insert(RechargePurchaseSystem.RechargeInfoArray, v)
    end
  end
  log_tree("RechargePurchaseSystem.SortRechargeInfoList before :", RechargePurchaseSystem.RechargeInfoArray)
  table.sort(RechargePurchaseSystem.RechargeInfoArray, function(a, b)
    if a.activityId == b.activityId then
      return false
    end
    local a_tagScore = a.tag
    local b_tagScore = b.tag
    if a_tagScore == 0 then
      a_tagScore = 3
    end
    if b_tagScore == 0 then
      b_tagScore = 3
    end
    if a_tagScore ~= b_tagScore then
      return a_tagScore < b_tagScore
    end
    local a_soldout = a.leftnum == 0
    local b_soldout = b.leftnum == 0
    if a_soldout ~= b_soldout then
      return not a_soldout
    end
    if a.endTime ~= b.endTime then
      return a.endTime < b.endTime
    end
    return a.startTime > b.startTime
  end)
  log_tree("RechargePurchaseSystem.SortRechargeInfoList :", RechargePurchaseSystem.RechargeInfoArray)
  if RechargePurchaseSystem.SelectedId ~= 0 then
    for i, info in pairs(RechargePurchaseSystem.RechargeInfoList) do
      if info.activityId == RechargePurchaseSystem.SelectedId then
        RechargePurchaseSystem.SelectedRechargeInfo = info
        break
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_RECHARGE, EVENTID_RECHARGE_PURCHASE_INFO_CHANGE)
end
function RechargePurchaseSystem.GetBuyPreCheckReq(acitivityId)
  log(bWriteLog and "RechargePurchaseSystem.GetBuyPrecheckReq acitivityId : " .. acitivityId)
  logic_connection_waiting:Show(1)
  local funcHide = function()
    logic_connection_waiting:Hide(1)
  end
  local time_ticker = require("common.time_ticker")
  time_ticker.AddTimerOnce(3, funcHide)
  local RechargePurchaseHandler = require("client.network.Protocol.RechargePurchaseHandler")
  RechargePurchaseHandler.send_direct_buy_pre_check(acitivityId)
end
function RechargePurchaseSystem.GetBuyPrecheckRsp(res, activityId)
  log(bWriteLog and "RechargePurchaseSystem.GetBuyPrecheckRsp res : " .. res .. ",activityId:" .. tostring(activityId))
  if res ~= NetErrorCode_NONE then
    log_error("RechargePurchaseSystem.GetBuyPrecheckRsp error!")
    logic_connection_waiting:Hide(1)
    return
  end
  logic_connection_waiting:Hide(1)
  if RechargePurchaseSystem.SelectedRechargeInfo == nil or RechargePurchaseSystem.SelectedRechargeInfo.purchaseInfo == nil then
    log_error("RechargePurchaseSystem.GetBuyPrecheckRsp info is null!!")
    ShowNotice(LocUtil.GetLocalizeResStr(301270))
    return
  end
  local info = RechargePurchaseSystem.SelectedRechargeInfo.purchaseInfo
  log_tree("RechargePurchaseSystem.GetBuyPrecheckRsp CentauriGood Info:", info)
  local logic_payment_api = require("client.logic.pay.logic_payment_api")
  logic_payment_api:Goods(info.CentauriProductId, info.CentauriPayItem, info.CentauriPrice, info.CentauriCountry, info.CentauriCurrency)
end
function RechargePurchaseSystem.PurchaseSelectedItem(shopData)
  log_tree("RechargePurchaseSystem.PurchaseItemByMoney itemInfo", RechargePurchaseSystem.SelectedRechargeInfo)
  local info = RechargePurchaseSystem.SelectedRechargeInfo
  if RechargePurchaseSystem.SelectedRechargeInfo == nil or RechargePurchaseSystem.SelectedRechargeInfo.activityId == nil or RechargePurchaseSystem.SelectedRechargeInfo.activityId == 0 then
    log_error("RechargePurchaseSystem.PurchaseSelectedItem info null!!")
    return
  end
  if RechargePurchaseSystem.SelectedRechargeInfo.num ~= 0 and RechargePurchaseSystem.SelectedRechargeInfo.leftnum == 0 then
    ShowNotice(LocUtil.GetLocalizeResStr(4990))
    return
  end
  if RechargePurchaseSystem.SelectedNumber == 0 or RechargePurchaseSystem.SelectedNumber > RechargePurchaseSystem.SelectedRechargeInfo.leftnum then
    ShowNotice(LocUtil.GetLocalizeResStr(301270))
    return
  end
  local TimeUtil = require("client.common.time_util")
  if info.endTime < TimeUtil.GetServerTimeInSec() then
    ShowNotice(LocUtil.GetLocalizeResStr(433013))
  end
  local strBuy = LocUtil.GetLocalizeResStr(301185)
  local itemName = RechargePurchaseSystem.SelectedRechargeInfo.name
  local price = RechargePurchaseSystem.SelectedRechargeInfo.price * RechargePurchaseSystem.SelectedNumber
  local tip = LocUtil.LocalizeResFormat(301372, price, itemName)
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  log_tree(" RechargePurchaseSystem.SelectedRechargeInfo", RechargePurchaseSystem.SelectedRechargeInfo)
  if RechargePurchaseSystem.SelectedRechargeInfo.shopId then
    local StoreUtils = require("client.slua.logic.store.utils.store_utils")
    local shopInfo = StoreUtils.ConvertToShopInfo(shopData[RechargePurchaseSystem.SelectedRechargeInfo.shopId], StoreConst.Page_ID_Item, StoreConst.label_subtype_lucky_bag)
    tip = LocUtil.LocalizeResFormat(7622, itemName)
    local CouponSystem = require("client.slua.logic.coupon.logic_coupon")
    CouponSystem._cur_coupon_scene = CouponSystem._Enum_Scene._RechargePurchase
    local tShowCfg = {
      nCouponPopupType = CouponSystem._Enum_CouponPopupType._Normally,
      sTitle = strBuy,
      sTipContent = tip,
      nMainScene = CouponSystem._Enum_Scene._RechargePurchase,
      nCurPrice = price,
      fConfirmCallback = function(confirmData)
        local buyInfo = StoreUtils.GetBuyInfo(shopInfo.id)
        local store_buy_utils = require("client.slua.umg.NewStoreV280.NewStoreMove.buy.store_buy_utils")
        local buyUIInfo = store_buy_utils.GetBuyUIInfo(shopInfo, buyInfo)
        local data = store_buy_utils.GetBuyWithCountRequestData(buyUIInfo, RechargePurchaseSystem.SelectedNumber, confirmData.nCurCouponId)
        local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
        store_supply_manager:buy_market_by_id_req(data)
        local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
        tlog_report_utils.ReportTLogEvent(TLogEventDefine.Purchase_Lucky_Bag, RechargePurchaseSystem.SelectedRechargeInfo.shopId, RechargePurchaseSystem.SelectedNumber)
      end
    }
    UIManager.ShowUI(UIManager.UI_Config.Coupon_PopupUI_General, tShowCfg)
    return
  end
  if RechargePurchaseSystem.SelectedRechargeInfo.purchaseType == RechargePurchaseSystem.purchase_type_uc then
    if PublishRegionMacros.IsJapanOrKorea() then
      tip = LocUtil.LocalizeResFormat(7622, itemName)
      local CouponSystem = require("client.slua.logic.coupon.logic_coupon")
      CouponSystem._cur_coupon_scene = CouponSystem._Enum_Scene._RechargePurchase
      local tShowCfg = {
        nCouponPopupType = CouponSystem._Enum_CouponPopupType._Normally,
        sTitle = strBuy,
        sTipContent = tip,
        nMainScene = CouponSystem._Enum_Scene._RechargePurchase,
        nCurPrice = price,
        fConfirmCallback = function(confirmData)
          RechargePurchaseSystem.PurchaseItemByUC(confirmData.nCurCouponId)
        end
      }
      UIManager.ShowUI(UIManager.UI_Config.Coupon_PopupUI_General, tShowCfg)
    else
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.Show(2, strBuy, tip, function()
        RechargePurchaseSystem.PurchaseItemByUC()
      end)
    end
  elseif RechargePurchaseSystem.SelectedRechargeInfo.purchaseType == RechargePurchaseSystem.purchase_type_cash then
    local sPriceStr = RechargePurchaseSystem.GetProductPriceByData(info.purchaseInfo, false)
    sPriceStr = sPriceStr ~= "" and sPriceStr or info.purchaseInfo and info.purchaseInfo.configPrice or ""
    tip = LocUtil.LocalizeResFormat(6393, sPriceStr, itemName)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, strBuy, tip, function()
      RechargePurchaseSystem.PurchaseItemByMoney()
    end)
  end
end
function RechargePurchaseSystem.PurchaseItemByMoney()
  local CallBack = function()
    RechargePurchaseSystem.GetBuyPreCheckReq(RechargePurchaseSystem.SelectedRechargeInfo.activityId)
  end
  local logic_region_block = require("client.logic.logic_region_block.logic_region_block")
  if logic_region_block.IsCrossRegionPlayer() then
    logic_region_block.ShowCrossRegionRechargeNotify(CallBack)
  else
    CallBack()
  end
end
function RechargePurchaseSystem.PurchaseItemByShop()
  local paramData = {}
  local shopData = RechargePurchaseSystem.SelectedRechargeInfo
  paramData[StoreConst.label_buy_param_id] = shopData.shopId
  local itemCfg = CDataTable.GetTableData("Item", shopData.itemId)
  paramData[StoreConst.label_buy_param_type] = itemCfg.ItemType
  paramData[StoreConst.label_buy_param_price_type] = 5
  paramData[StoreConst.label_buy_param_tab_id] = shopData.tabId
  paramData[StoreConst.label_buy_param_sub_id] = shopData.subId
  paramData[StoreConst.label_buy_param_ver] = shopData.vresion
  paramData[StoreConst.label_buy_param_valid_hours] = shopData.validHours
  paramData[StoreConst.label_buy_param_count] = shopData.itemNum
end
function RechargePurchaseSystem.PurchaseItemByUC(coupon_id)
  if RechargePurchaseSystem.SelectedNumber <= 0 then
    log(bWriteLog and "RechargePurchaseSystem.PurchaseItemByUC number is 0!")
    return
  end
  log(bWriteLog and "RechargePurchaseSystem.PurchaseItemByUC activityid : " .. RechargePurchaseSystem.SelectedRechargeInfo.activityId .. "|| buyNumber : " .. RechargePurchaseSystem.SelectedNumber)
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:CheckUCRestrict() then
    return
  end
  local RechargePurchaseHandler = require("client.network.Protocol.RechargePurchaseHandler")
  if coupon_id and coupon_id ~= 0 then
    RechargePurchaseHandler.send_unified_purchase(RechargePurchaseSystem.SelectedRechargeInfo.activityId, RechargePurchaseSystem.SelectedNumber, coupon_id)
  else
    RechargePurchaseHandler.send_unified_purchase(RechargePurchaseSystem.SelectedRechargeInfo.activityId, RechargePurchaseSystem.SelectedNumber)
  end
end
function RechargePurchaseSystem.PurchaseItemByUCRsp(res, item_id, item_num, need_show)
  log(bWriteLog and "RechargePurchaseSystem.PurchaseItemByUCRsp need_show = " .. tostring(need_show) .. " ItemId = " .. tostring(item_id) .. " || number = " .. tostring(item_num))
  local DiscountSystem = require("client.slua.logic.Discount_Fever.DiscountSystem")
  if res ~= NetErrorCode_NONE then
    if DiscountSystem.ENUM_DISCOUNT_FEVER_ERR_CODE[res] ~= nil then
      ShowNotice(DiscountSystem.ENUM_DISCOUNT_FEVER_ERR_CODE[res])
    else
      ShowNotice(res)
    end
    log_error("RechargePurchaseSystem.PurchaseItemByUCRsp error! res : " .. res)
    return
  elseif need_show == true and item_id ~= nil and item_num ~= nil then
    log(bWriteLog and "RechargePurchaseSystem.PurchaseItemByUCRsp showItem")
    local itemInfo = {
      {
        res_id = item_id,
        count = item_num,
        valid_hours = 0,
        color_id = 0,
        pattern_id = 0
      }
    }
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    Logic_CommonItemGet.ShowPanel_DefaultStyle(itemInfo)
  end
end
function RechargePurchaseSystem.GetPurchaseInfoReq(reqList)
  log_tree("RechargePurchaseSystem.GetPurchaseInfoReq :", reqList)
  local RechargePurchaseHandler = require("client.network.Protocol.RechargePurchaseHandler")
  RechargePurchaseHandler.send_batch_query_direct_buy_info(reqList)
end
function RechargePurchaseSystem.GetPurchaseInfoRsp(res, list)
  local MallSystem = require("client.logic.mall.logic_mall")
  log(bWriteLog and "RechargePurchaseSystem.GetPurchaseInfoRsp res : " .. res)
  if res ~= NetErrorCode_NONE then
    return
  end
  log_tree("RechargePurchaseSystem.GetPurchaseInfoRsp list : ", list)
  EventSystem:postEvent(EVENTTYPE_RECHARGE, EVENTID_RECHARGE_PURCHASE_GET_INFO, list)
  for k, v in pairs(list) do
    local rechargeInfo
    for i, tInfo in pairs(RechargePurchaseSystem.RechargeInfoList) do
      if k == tInfo.packId then
        rechargeInfo = tInfo
      end
    end
    if rechargeInfo and next(rechargeInfo) then
      local tPurchaseInfo = {}
      tPurchaseInfo.CentauriProductId = v.productid
      tPurchaseInfo.CentauriCountry = v.country
      tPurchaseInfo.CentauriCurrency = v.curency_unit
      tPurchaseInfo.CentauriPrice = v.CentauriPrice
      tPurchaseInfo.CentauriPayItem = v.payItem
      tPurchaseInfo.rewardItems = {}
      if v.parm2 and v.parm2 ~= "" then
        local returnUC = MallSystem.ParseDirectPurchaseParam(v.parm2)
        if 0 < returnUC then
          tPurchaseInfo.rewardItems[1] = {itemId = 1006, itemNum = returnUC}
        end
      end
      for index, item in ipairs(v.item_content) do
        tPurchaseInfo.rewardItems[#tPurchaseInfo.rewardItems + 1] = {
          itemId = item.DropItemID,
          itemNum = item.DropItemNum
        }
      end
      tPurchaseInfo.configPrice = v.price
      tPurchaseInfo.productPriceDesc = CentauriManager.GetPriceByProductId(tPurchaseInfo.CentauriProductId, tPurchaseInfo.CentauriCurrency, "", true)
      rechargeInfo.purchaseInfo = tPurchaseInfo
      rechargeInfo.itemId = v.item_id
      if v.item_id ~= 0 then
        local cfg = CDataTable.GetTableData("Item", v.item_id)
        if cfg then
          rechargeInfo.name = cfg.ItemName
        else
          rechargeInfo.name = ""
        end
      end
    end
  end
  RechargePurchaseSystem.SortRechargeInfoList()
end
function RechargePurchaseSystem.GetSelectedChestInfo()
  if RechargePurchaseSystem.SelectedRechargeInfo == nil then
    log_error("RechargePurchaseSystem.GetSelectedChestInfo info is null")
    return
  end
  local chestId = RechargePurchaseSystem.SelectedRechargeInfo.itemId
  RechargePurchaseSystem.GetChestInfo(chestId)
end
function RechargePurchaseSystem.GetChestInfo(chestId)
  log(bWriteLog and string.format("RechargePurchaseSystem.GetChestInfo, chestId:%s", chestId))
  local onGetChestRsp = function(chest_id, data)
    if chest_id == chestId then
      EventSystem:postEvent(EVENTTYPE_RECHARGE, EVENTID_RECHARGE_GET_CHEST_INFO, data, chest_id)
    end
  end
  local BasicDataChestTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataChestTable)
  BasicDataChestTable:GetOrReqData(chestId, onGetChestRsp)
end
local limitedPakHasRed
function RechargePurchaseSystem.CheckLimitedPakNeedRedDot()
  if limitedPakHasRed ~= nil then
    return limitedPakHasRed
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveCfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUcLimitedPak)
  if not saveCfg then
    limitedPakHasRed = true
  else
    limitedPakHasRed = false
  end
  return limitedPakHasRed
end
function RechargePurchaseSystem.RemoveLimitedPakNeedRedDot()
  limitedPakHasRed = false
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N({red = 1}, PlayerPrefsSystem.ePlayerPrefsType.eUcLimitedPak)
end
local LimitedSpecialChestHasRed
function RechargePurchaseSystem.CheckLimitedSpecialChestNeedRedDot()
  if LimitedSpecialChestHasRed ~= nil then
    return LimitedSpecialChestHasRed
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveCfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eLimitedSpecialChest)
  if not saveCfg then
    LimitedSpecialChestHasRed = true
  else
    LimitedSpecialChestHasRed = false
  end
  return LimitedSpecialChestHasRed
end
function RechargePurchaseSystem.RemoveLimitedSpecialChestNeedRedDot()
  LimitedSpecialChestHasRed = false
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N({red = 1}, PlayerPrefsSystem.ePlayerPrefsType.eLimitedSpecialChest)
end
function RechargePurchaseSystem.OnGetLimitedSpecialChestRsp()
end
function RechargePurchaseSystem.OnBuyLimitedSpecialChestRsp()
end
function RechargePurchaseSystem.GetProductPriceByData(tProductData, bNeedReload)
  if not (tProductData and tProductData.CentauriProductId and tProductData.CentauriCurrency) or not tProductData.CentauriPrice then
    return
  end
  local sPriceStr = CentauriManager.GetPriceByProductId(tProductData.CentauriProductId, tProductData.CentauriCurrency, tProductData.CentauriPrice, bNeedReload)
  return sPriceStr
end
return RechargePurchaseSystem