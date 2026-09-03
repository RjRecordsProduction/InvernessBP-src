local MallSystem = {
  ItemCache = nil,
  GetShopItemInfoByIdReqCallback = nil,
  Version = 0,
  TableItem = {
    id = 0,
    name = "",
    category = "",
    page = "",
    send_client = 1,
    sort = 0,
    icon = "",
    money_type = 1001,
    money_price = 0,
    money_price2 = 0,
    money_price3 = 0,
    item_id = 0,
    item_time_limit = 0,
    item_time_limit2 = 0,
    item_time_limit3 = 0,
    sale_begin_time = 0,
    sale_end_time = 0,
    personal_buy_limit = 0,
    global_buy_limit = 0,
    is_hot = 0,
    timelimit_discount_begin_time = 0,
    timelimit_discount_end_time = 0,
    timelimit_discount_count_limit = 0,
    timelimit_discount_price = 0,
    timelimit_discount_price2 = 0,
    timelimit_discount_price3 = 0,
    timelimit_discount_show_discount = 0,
    give_type = "item",
    is_expire = 0,
    can_present = 0,
    item_extra_id = 0,
    is_new = 0
  },
  CheckMoneyBtnType = {
    NIL = nil,
    Cancel = 0,
    OK = 1,
    Pay = 2
  },
  OnSellItemListDic = {},
  TabInfos = {},
  BuyItemIdRecord = {},
  monthCardInfo = {
    cfg = {
      configPrice = "",
      productPriceDesc = "",
      awardOnOffUC = 0,
      awardItemId = 1101,
      awardDailyNum = 1,
      awardTotalNum = 30,
      totalTimes = 30,
      CentauriProductId = 0,
      CentauriPrice = "",
      CentauriCountry = "",
      CentauriCurrency = "",
      CentauriPayItem = 1
    },
    data = {
      buyFlag = false,
      getTodayEnabled = false,
      getAwradTimes = 0,
      lackOfTimes = 0
    }
  },
  rewardPkgInfo = {
    configPrice = "",
    productPriceDesc = "",
    actEndTime = 0,
    CentauriProductId = 0,
    CentauriPrice = "",
    CentauriCountry = "",
    CentauriCurrency = "",
    CentauriPayItem = 1,
    rewardItems = {},
    discount = 1,
    item_id = 0
  },
  recommendBannerInfo = {},
  recommendPosterInfo = {},
  recommendBoxInfo = {
    icon_name = FuncUtil.GetDomainByID(3366055) .. "/event/pics/recommend/recommend2.png",
    shop_id = 10624,
    box_info = {}
  },
  recommendItemsInfo = {
    new_market_id = {
      310071,
      310072,
      710010
    },
    hot_market_id = {
      710001,
      310069,
      310070
    },
    market_list = {},
    itemId2ShopId = {}
  },
  recommendBoxMainInfo = {},
  recommendMarketVersion = 0,
  Buy_Source = 2
}
local StringUtil = require("common.string_util")
G_SHOP_TAB_LIMIT_TIME = 13
local lastVersion
local reqNum = 0
local cacheItemInfo = {}
local localText = function(id)
  return LocUtil.GetLocalizeResStr(id)
end
function MallSystem.Enter()
  log(bWriteLog and "MallSystem enter")
  lastVersion = 0
  MallSystem.GetBuyInfoReq()
  MallSystem.Get2rdVerPageListReq()
  MallSystem.GetShopIdListReq()
end
function MallSystem.Release()
  log(bWriteLog and "MallSystem Release")
  MallSystem.ResetItemCache()
end
function MallSystem.GetItemCountInBag(item_id)
  if MallSystem.ItemCache == nil then
    MallSystem.ItemCache = {}
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local arrayHallDepotItemInfo = wardrobe_data:GetArrayHallDepotItemInfo()
    for k, v in pairs(arrayHallDepotItemInfo) do
      if v.expireTS == 0 then
        local num = MallSystem.ItemCache[v.resID]
        if num then
          num = num + v.count
        else
          num = v.count
        end
        MallSystem.ItemCache[v.resID] = num
      end
    end
  end
  local count = MallSystem.ItemCache[item_id]
  if count then
    return count
  end
  return 0
end
function MallSystem.HasItemInBag(item_id)
  return MallSystem.GetItemCountInBag(item_id) > 0
end
function MallSystem.ResetItemCache()
  MallSystem.ItemCache = nil
end
function MallSystem.IsMoneyEnough(money_type, money_price)
  if money_type == 1000 then
    if money_price > DataMgr.gold then
      return false
    end
    return true
  elseif money_type == 1001 then
    if money_price > DataMgr.diamond then
      return false
    end
    return true
  elseif money_type == 1006 then
    if money_price > DataMgr.ticket then
      return false
    end
    return true
  else
    local count = MallSystem.GetItemCountInBag(money_type)
    if money_price > count then
      return false
    end
    return true
  end
end
function MallSystem.GetMoneyName(money_type)
  local money_name = ""
  local itm_cfg = CDataTable.GetTableData("Item", money_type)
  if itm_cfg then
    return itm_cfg.ItemName
  end
  return money_name
end
function MallSystem.CheckIfOpen(id)
  return LobbySystem.CheckOpen(id)
end
function MallSystem.CheckMoneyIsEnough(money_type, money_price, callback)
  local money_name = MallSystem.GetMoneyName(money_type)
  if money_type == 1000 then
    if money_price > DataMgr.gold then
      local str = string.format("%s\228\184\141\232\182\179", money_name)
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.Show(1, localText(101001), str, function()
        callback(false, 1)
      end)
    else
      callback(true)
    end
  elseif money_type == 1001 then
    local ticket_name = MallSystem.GetMoneyName(1006)
    if money_price > DataMgr.diamond then
      if MallSystem.CheckIfOpen(50004) then
        local now_ticket = DataMgr.ticket
        local need_diamond = money_price - DataMgr.diamond
        if now_ticket >= need_diamond then
          local str = string.format(localText(501051), money_name, need_diamond, ticket_name)
          local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
          CommonMsgBoxMgr.Show(2, localText(101001), str, function()
            callback(true, 1)
          end, function()
            callback(true, 0)
          end)
          return
        end
        local CommonPayBoxMgr = require("client.slua.logic.common.Payclass.logic_common_pay_box")
        CommonPayBoxMgr.ShowUcRechargeMsg(need_diamond)
      else
        local str = string.format("%s\228\184\141\232\182\179", money_name)
        local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
        CommonMsgBoxMgr.Show(1, localText(101001), str, function()
          callback(false, 1)
        end)
      end
    else
      callback(true)
    end
  elseif money_type == 1006 then
    if money_price > DataMgr.ticket then
      local CommonPayBoxMgr = require("client.slua.logic.common.Payclass.logic_common_pay_box")
      CommonPayBoxMgr.ShowUcRechargeMsg(money_price)
    else
      callback(true)
    end
  else
    local count = MallSystem.GetItemCountInBag(money_type)
    if money_price > count then
      local str = string.format("%s\228\184\141\232\182\179", money_name)
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.Show(1, localText(101001), str, function()
        callback(false, 1)
      end)
    end
    callback(true)
  end
end
function MallSystem.GetProductForeverPrice(productTbl)
  local ForeverPrice = 0
  local DiscountPrice = 0
  if productTbl.is_expire == 1 then
    local itemTimeLimit = {
      productTbl.item_time_limit,
      productTbl.item_time_limit2,
      productTbl.item_time_limit3
    }
    local itemMoneyPrice = {
      productTbl.money_price,
      productTbl.money_price2,
      productTbl.money_price3
    }
    local itemDiscountPrice = {
      productTbl.timelimit_discount_price,
      productTbl.timelimit_discount_price2,
      productTbl.timelimit_discount_price3
    }
    local foreverIdx = 1
    for i = 1, #itemTimeLimit do
      if itemTimeLimit[i] == -1 then
        foreverIdx = i
        break
      end
    end
    ForeverPrice = itemMoneyPrice[foreverIdx]
    DiscountPrice = itemDiscountPrice[foreverIdx]
  else
    ForeverPrice = productTbl.money_price
    DiscountPrice = productTbl.timelimit_discount_price
  end
  local isDiscount = MallSystem.IsDiscount(productTbl)
  if isDiscount then
    return DiscountPrice, ForeverPrice
  end
  return ForeverPrice, ForeverPrice
end
function MallSystem.IsDiscount(itm_svr)
  local TimeUtil = require("client.common.time_util")
  local now_time = TimeUtil.GetServerTimeInSec()
  if itm_svr.timelimit_discount_price <= 0 then
    return false
  end
  local max_time = false
  if itm_svr.timelimit_discount_end_time == 0 then
    max_time = true
  end
  if now_time >= itm_svr.timelimit_discount_begin_time and (max_time or now_time <= itm_svr.timelimit_discount_end_time) then
    return true
  else
    return false
  end
end
function MallSystem.MoneyTypeToFiveMoneyType(moneyType)
  if moneyType == 0 then
    return 1000
  elseif moneyType == 1 then
    return 1001
  elseif moneyType == 2 then
    return 1006
  end
  return moneyType
end
function MallSystem.FiveMoneyTypeToMoneyType(moneyType)
  if moneyType == 1000 then
    return 0
  elseif moneyType == 1001 then
    return 1
  elseif moneyType == 1006 then
    return 2
  end
  return moneyType
end
function MallSystem.GetMonthCardInfo()
  return MallSystem.monthCardInfo
end
function MallSystem.GetRewardPkgInfo()
  return MallSystem.rewardPkgInfo
end
function MallSystem.IsTabOpen(tab)
  if MallSystem.TabInfos then
    local info = MallSystem.TabInfos[tab]
    if info and info.isOpen and info.isOpen == 1 then
      return true
    end
  end
  return false
end
function MallSystem.IsMysteryTab(firTab, secTab)
  if firTab == G_SHOP_TAB_LIMIT_TIME and (secTab == 1 or secTab == 2) then
    return true
  end
  return false
end
function MallSystem.IsInBuyRecord(itemId, colorID, patternID)
  colorID = colorID or 0
  patternID = patternID or 0
  if not (MallSystem.BuyItemIdRecord and MallSystem.BuyItemIdRecord[itemId]) or MallSystem.BuyItemIdRecord[itemId].colorID ~= colorID or MallSystem.BuyItemIdRecord[itemId].patternID ~= patternID then
    return false
  end
  return true
end
function MallSystem.ClearBuyRecord()
  MallSystem.BuyItemIdRecord = {}
end
function MallSystem.GetBuyInfoReq()
  log(bWriteLog and "get_imobile_market_buy_info_req")
  local MallHandler = require("client.network.Protocol.MallHandler")
  MallHandler.send_get_imobile_market_buy_info_req()
end
function MallSystem.GetBuyInfoRsp(list, isAll)
  log(bWriteLog and "get_market_buy_info_rsp :" .. isAll)
  if isAll == 1 then
    EventSystem:postEvent(EVENTTYPE_MALL, EVENTID_MALL_BUY_INFO_UPDATE, list)
  else
    EventSystem:postEvent(EVENTTYPE_MALL, EVENTID_MALL_BUY_INFO_CHANGE, list)
  end
end
function MallSystem.GetPageDetailReq(page)
end
function MallSystem.HandleReqNum()
  reqNum = reqNum + 1
end
function MallSystem.BatchBuyReq(list, curVersion, voucher)
  log(bWriteLog and "imobile_market_batch_buy_req :" .. tostring(curVersion))
  reqNum = reqNum + 1
  local MallHandler = require("client.network.Protocol.MallHandler")
  local bVersion = curVersion == nil and lastVersion or curVersion
  MallHandler.send_imobile_market_batch_buy_req(list, bVersion, voucher)
end
function MallSystem.BatchBuyRsp(res, itemList)
  log(bWriteLog and "imobile_market_batch_buy_rsp :" .. res)
  reqNum = reqNum - 1
  if res == NetErrorCode_NONE then
    MallSystem.ResetItemCache()
    for i, v in ipairs(itemList) do
      local itemData = {
        res_id = v.id,
        count = v.count,
        valid_hours = v.time_limit,
        expire_ts = 0,
        color_id = v.color,
        pattern_id = v.pattern
      }
      table.insert(cacheItemInfo, itemData)
      MallSystem.BuyItemIdRecord[v.id] = {
        id = v.id,
        colorID = v.color or 0,
        patternID = v.pattern or 0
      }
    end
    if reqNum == 0 then
      local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
      Logic_CommonItemGet.ShowPanel_DefaultStyle(cacheItemInfo)
      cacheItemInfo = {}
    end
    EventSystem:postEvent(EVENTTYPE_MALL, EVENTID_MALL_BUY_RESULT, {true, itemList})
  else
    EventSystem:postEvent(EVENTTYPE_MALL, EVENTID_MALL_BUY_RESULT, {false})
    if res == 9910225 then
      local CommonPayBoxMgr = require("client.slua.logic.common.Payclass.logic_common_pay_box")
      CommonPayBoxMgr.ShowUcRechargeMsg()
    else
      ShowNotice(res)
    end
  end
end
function MallSystem.GetDirectBuyInfoReq()
  log(bWriteLog and "imobile_get_direct_buy_info")
  local MallHandler = require("client.network.Protocol.MallHandler")
  MallHandler.send_imobile_get_direct_buy_info()
end
function MallSystem.GetDirectBuyInfoRsp(res, list)
  log(bWriteLog and "imobile_get_direct_buy_info_rsp" .. res)
  if res ~= NetErrorCode_NONE then
    ShowNotice(res)
    return
  end
  EventSystem:postEvent(EVENTTYPE_MALL, EVENTID_MALL_DIRECT_BUY_INFO, list)
end
function MallSystem.DirectBuyContentReq(id)
  log(bWriteLog and "imobile_market_direct_buy_content_req")
  local MallHandler = require("client.network.Protocol.MallHandler")
  MallHandler.send_imobile_market_direct_buy_content_req(id)
end
function MallSystem.DirectBuyContentRsp(res, content, id)
  if res ~= NetErrorCode_NONE then
    ShowNotice(res)
    return
  end
  EventSystem:postEvent(EVENTTYPE_MALL, EVENTID_MALL_GET_DROP_LIST, {id, content})
end
function MallSystem.DirectBuyResultNotify(res, id, limit_num)
  local StarterPackSystem = require("client.logic.starter_pack.logic_starter_pack")
  if res ~= NetErrorCode_NONE then
    ShowNotice(res)
    return
  end
  StarterPackSystem.DirectBuyResultNotify(res, id, limit_num)
end
function MallSystem.GetMonthCardInfoReq()
  log(bWriteLog and "MallSystem.GetMonthCardInfoReq")
  local MallHandler = require("client.network.Protocol.MallHandler")
  MallHandler.send_get_month_card_info()
end
function MallSystem.GetMonthCardInfoRsp(res, svrCardinfo)
  if res ~= NetErrorCode_NONE then
    ShowNotice(res)
    return
  end
  if svrCardinfo == nil or svrCardinfo.cfg == nil then
    return
  end
  local cardInfoCfg = MallSystem.monthCardInfo.cfg
  local cardInfoData = MallSystem.monthCardInfo.data
  MallSystem.ParseMonthCardParam(svrCardinfo.cfg.parm2, cardInfoCfg)
  local itemContent = svrCardinfo.cfg.item_content
  if itemContent and 1 < #itemContent then
    local dropCfg = itemContent[1]
    cardInfoCfg.awardItemId = dropCfg.DropItemID
    cardInfoCfg.awardDailyNum = dropCfg.DropItemNum
    cardInfoCfg.awardTotalNum = cardInfoCfg.totalDay * dropCfg.DropItemNum
  end
  cardInfoCfg.CentauriProductId = svrCardinfo.cfg.productid
  cardInfoCfg.CentauriCurrency = svrCardinfo.cfg.curency_unit
  cardInfoCfg.CentauriCountry = svrCardinfo.cfg.country
  cardInfoCfg.CentauriPayItem = svrCardinfo.cfg.payItem
  cardInfoCfg.CentauriPrice = svrCardinfo.cfg.CentauriPrice
  if not svrCardinfo.data then
    cardInfoData.buyFlag = false
  else
    if svrCardinfo.can_buy then
      cardInfoData.buyFlag = false
    else
      cardInfoData.buyFlag = true
    end
    cardInfoData.lackOfTimes = svrCardinfo.data.times
    cardInfoData.getAwradTimes = cardInfoCfg.totalTimes - svrCardinfo.data.times
    cardInfoData.getTodayEnabled = svrCardinfo.data.flag
  end
  cardInfoCfg.configPrice = svrCardinfo.cfg.price
  cardInfoCfg.productPriceDesc = CentauriManager.GetPriceByProductId(cardInfoCfg.CentauriProductId, cardInfoCfg.CentauriCurrency, "", true)
  EventSystem:postEvent(EVENTTYPE_MALL, EVENTID_MALL_MONTH_CARD_INFO)
end
function MallSystem.ParseMonthCardParam(param, cfg)
  strs = StringUtil.Split(param, ",")
  if strs and #strs >= 5 then
    cfg.awardOnOffUC = tonumber(strs[1])
    cfg.totalDay = tonumber(strs[5])
  end
  return 0
end
function MallSystem.GetMonthCardDailyAwardReq()
  log(bWriteLog and "take_month_card_daily_award")
  local MallHandler = require("client.network.Protocol.MallHandler")
  MallHandler.send_take_month_card_daily_award()
end
function MallSystem.GetMonthCardDailyAwardRsp(res, svrCardData)
  if res ~= NetErrorCode_NONE then
    ShowNotice(res)
    return
  end
  if not svrCardData then
    return
  end
  local cardInfoCfg = MallSystem.monthCardInfo.cfg
  local cardInfoData = MallSystem.monthCardInfo.data
  cardInfoData.buyFlag = true
  cardInfoData.lackOfTimes = svrCardData.times
  cardInfoData.getAwradTimes = cardInfoCfg.totalTimes - svrCardData.times
  cardInfoData.getTodayEnabled = svrCardData.flag or false
  EventSystem:postEvent(EVENTTYPE_MALL, EVENTID_MALL_MONTH_CARD_INFO)
end
function MallSystem.NotifyMonthCardInfo(res, svrCardData)
  log(bWriteLog and "MallSystem.NotifyMonthCardInfo----------------------")
  MallSystem.GetMonthCardDailyAwardRsp(res, svrCardData)
end
function MallSystem.GetDirectPurchaseInfoReq(itemId)
  log(bWriteLog and "query_direct_buy_info:" .. tostring(itemId))
  local MallHandler = require("client.network.Protocol.MallHandler")
  MallHandler.send_query_direct_buy_info(itemId)
end
function MallSystem.GetDirectPurchaseInfoListRsp(res, info)
  if res ~= NetErrorCode_NONE then
    ShowNotice(res)
    return
  end
  log(bWriteLog and "MallSystem.GetDirectPurchaseInfoListRsp")
  for k, v in pairs(info) do
    local rewardPkgInfo = {}
    rewardPkgInfo.CentauriProductId = v.productid
    rewardPkgInfo.CentauriCountry = v.country
    rewardPkgInfo.CentauriCurrency = v.curency_unit
    rewardPkgInfo.CentauriPrice = v.CentauriPrice
    rewardPkgInfo.CentauriPayItem = v.payItem
    rewardPkgInfo.discount = v.discount
    rewardPkgInfo.item_id = v.item_id
    rewardPkgInfo.rewardItems = {}
    if v.parm2 and v.parm2 ~= "" then
      local returnUC = MallSystem.ParseDirectPurchaseParam(v.parm2)
      if 0 < returnUC then
        rewardPkgInfo.rewardItems[1] = {itemId = 1006, itemNum = returnUC}
      end
    end
    for index, item in ipairs(v.item_content) do
      rewardPkgInfo.rewardItems[#rewardPkgInfo.rewardItems + 1] = {
        itemId = item.DropItemID,
        itemNum = item.DropItemNum
      }
    end
    rewardPkgInfo.configPrice = v.price
    rewardPkgInfo.productPriceDesc = CentauriManager.GetPriceByProductId(rewardPkgInfo.CentauriProductId, rewardPkgInfo.CentauriCurrency, "", true)
  end
  EventSystem:postEvent(EVENTTYPE_MALL, EVENTID_MALL_REWARD_PKG_INFO)
end
function MallSystem.GetDirectPurchaseInfoRsp(res, info)
  local StarterPackSystem = require("client.logic.starter_pack.logic_starter_pack")
  if res ~= NetErrorCode_NONE then
    ShowNotice(res)
    EventSystem:postEvent(EVENTTYPE_MALL, EVENTID_MALL_REWARD_PKG_INFO_ERROR)
    return
  end
  log(bWriteLog and "MallSystem.GetDirectPurchaseInfoRsp")
  local rewardPkgInfo = MallSystem.rewardPkgInfo
  rewardPkgInfo.CentauriProductId = info.productid
  rewardPkgInfo.CentauriCountry = info.country
  rewardPkgInfo.CentauriCurrency = info.curency_unit
  rewardPkgInfo.CentauriPrice = info.CentauriPrice
  rewardPkgInfo.CentauriPayItem = info.payItem
  rewardPkgInfo.discount = info.discount
  rewardPkgInfo.item_id = info.item_id
  rewardPkgInfo.rewardItems = {}
  if info.parm2 and info.parm2 ~= "" then
    local returnUC = MallSystem.ParseDirectPurchaseParam(info.parm2)
    if 0 < returnUC then
      rewardPkgInfo.rewardItems[1] = {itemId = 1006, itemNum = returnUC}
    end
  end
  for index, item in ipairs(info.item_content) do
    rewardPkgInfo.rewardItems[#rewardPkgInfo.rewardItems + 1] = {
      itemId = item.DropItemID,
      itemNum = item.DropItemNum
    }
  end
  rewardPkgInfo.configPrice = info.price
  rewardPkgInfo.productPriceDesc = CentauriManager.GetPriceByProductId(rewardPkgInfo.CentauriProductId, rewardPkgInfo.CentauriCurrency, "", true)
  EventSystem:postEvent(EVENTTYPE_MALL, EVENTID_MALL_REWARD_PKG_INFO)
  StarterPackSystem.GetDirectPurchaseInfoRsp(res, info)
end
function MallSystem.ParseDirectPurchaseParam(param)
  strs = StringUtil.Split(param, ",")
  if strs and #strs >= 1 then
    return tonumber(strs[1])
  end
  return 0
end
function MallSystem.NewItemData(itm_svr)
  local TableUtil = require("common.table_util")
  local itm = TableUtil.CopyTable(MallSystem.TableItem)
  if type(itm_svr) == "table" then
    if itm_svr.item_id then
      local cfg = CDataTable.GetTableData("Item", itm_svr.item_id)
      if cfg then
        itm.name = cfg.ItemName
      end
    end
    for k, v in pairs(itm_svr) do
      itm[k] = v
    end
  end
  return itm
end
function MallSystem.GetShopItemInfoByIdReq(id, callback)
end
function MallSystem.GetShopIdListReq()
end
function MallSystem.GetMallAllItemsSimpleInfo()
end
function MallSystem.Get2rdVerPageListReq()
end
function MallSystem.Get2rdVerPageListRsp(res, page_list, wait_to_refresh_time, wait_to_refresh_time2)
  log(bWriteLog and "imobile_market_get_2rdVer_page_list_rsp: " .. res)
  if res ~= NetErrorCode_NONE then
    ShowNotice(res)
    return
  end
  MallSystem.TabInfos = page_list
  EventSystem:postEvent(EVENTTYPE_MALL, EVENTID_MALL_TAB_RES_UPDATE, {
    page_list,
    wait_to_refresh_time,
    wait_to_refresh_time2
  })
end
local mallSystemUILastFirstTab = 0
local mallSystemUILastSecondTab = 0
function MallSystem.OpenUIWithLastState()
  local params = {
    Tab1 = mallSystemUILastFirstTab,
    Tab2 = mallSystemUILastSecondTab,
    isForceTab2 = true
  }
  local jump_utils = require("client.logic.store.jump_utils")
  jump_utils.OpenJumpModule(BP_ENUM_MODULE_MALL_CHILD, params)
end
function MallSystem.SetMallSystemUIFirstTab(tab)
  mallSystemUILastFirstTab = tab
end
function MallSystem.SetMallSystemUISecondTab(tab)
  mallSystemUILastSecondTab = tab
end
function MallSystem.on_notify_open_chest_present(resid, count)
  log(bWriteLog and "MallSystem.on_notify_open_chest_present resid=" .. resid .. " count=" .. count)
  local fmt = LocUtil.GetLocalizeResStr(6190)
  local str = string.format(fmt, count)
  ShowNotice(str)
end
return MallSystem