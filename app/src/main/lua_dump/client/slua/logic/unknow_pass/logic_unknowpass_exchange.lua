local UnknowPassExchangeSystem = {
  ExchangeItemList = {},
  ExchangeReturnItemList = {},
  ExchangeItemListMap = {},
  SpecialMap = {},
  maxExchangeItem = {},
  PrivilegeInfo = {},
  upass_active_shop_info = {},
  NewExchangeItemList = {},
  IsBuyingItem = false,
  exchange_hair_chest_id = nil,
  upass_exchange_face_chest_id = nil,
  curActiveShopCfgSeason = nil,
  curNewExchangeItemListSeason = nil,
  ActiveShopConfig = nil,
  bEncoreBoxJumpReturn = false,
  SpecialType = {
    SPECIAL = 0,
    EXCHANGE = 1,
    SUBWAY = 2
  }
}
function UnknowPassExchangeSystem.OpenExchangeUI()
  if UnknowPassSystem.Season >= 59 then
    UIManager.ShowUI(UIManager.UI_Config.UnknowPass_Exchange_New_BP)
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.unknowpass_exchange)
end
function UnknowPassExchangeSystem.CloseExchangeUI()
  UIManager.CloseUI(UIManager.UI_Config.unknowpass_exchange)
  UIManager.CloseUI(UIManager.UI_Config.UnknowPass_Exchange_New_BP)
end
function UnknowPassExchangeSystem.SetUpassActiveShopInfo(tUpassActiveShopInfo)
  UnknowPassExchangeSystem.upass_active_shop_info = tUpassActiveShopInfo
end
function UnknowPassExchangeSystem.on_upass_active_shop_exchange_rp_receipt_rsp(info)
  ShowNotice(6500)
  UnknowPassExchangeSystem.upass_active_shop_info.current_rp_score_receipt_count = info.current_rp_score_receipt_count
  UnknowPassExchangeSystem.upass_active_shop_info.exchange_info.season_rp_score_receipt_count = info.season_rp_score_receipt_count
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_UPDATE_RPACTIVE_SCORE)
end
function UnknowPassExchangeSystem.on_upass_active_shop_buy_rsp(info)
  UnknowPassExchangeSystem.upass_active_shop_info.current_rp_score_receipt_count = info.current_rp_score_receipt_count
  UnknowPassExchangeSystem.upass_active_shop_info.exchange_info = info.exchange_info
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_AVTIVESHOP_EXCHANGE_ITEM)
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_UPDATE_RPACTIVE_SCORE)
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_RPRewardGet(info.item_list)
end
function UnknowPassExchangeSystem.GetActiveShopItemHadExchangeCount(uniq_id)
  local buy_list = UnknowPassExchangeSystem.upass_active_shop_info.exchange_info.buy_list
  if buy_list then
    return buy_list[uniq_id] or 0
  end
  return 0
end
function UnknowPassExchangeSystem.SetEncoreBoxJumpReturn(bIsJumpReturn)
  UnknowPassExchangeSystem.bEncoreBoxJumpReturn = bIsJumpReturn
end
function UnknowPassExchangeSystem.GetEncoreBoxJumpReturn()
  return UnknowPassExchangeSystem.bEncoreBoxJumpReturn
end
function UnknowPassExchangeSystem.IsUnlockExchange(rp_level)
  if rp_level and rp_level == 101 then
    return UnknowPassSystem.IsBuyElite, 18140160
  elseif rp_level and rp_level == 103 then
    return UnknowPassSystem.IsBuyElite and UnknowPassSystem.PassType == 2, 18140159
  end
  return true
end
function UnknowPassExchangeSystem.GetItemHadExchangeCount(uniq_id)
  local buy_list = UnknowPassExchangeSystem.upass_active_shop_info.exchange_info.buy_list
  if buy_list then
    return buy_list[uniq_id] or 0
  end
  return 0
end
function UnknowPassExchangeSystem.OpenExchangeBuyScoreUI()
  local UnknowPassPrimeSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_subscription")
  local bIsShowVouchers = UnknowPassSystem.hasCoupon or UnknowPassSystem.hasVoucher or UnknowPassPrimeSystem.CheckSubScriptionOpen()
  local CoinMacro = require("client.slua.config.ClientMacros.CoinMacro")
  local tExchangeData = {
    itemId = UnknowPassSystem.SCORE_ITEM_ID,
    itemNum = 100,
    validTime = 0,
    timeLimits = 99,
    hasExchangeCount = 0,
    needItemId = CoinMacro.Uc,
    needItemNum = 100
  }
  local tExtra = {
    sTitle = LocUtil.GetLocalizeResStr(6177),
    sExchangeBtnText = LocUtil.GetLocalizeResStr(6177),
    bIsMaskInput = true,
    nAddSubBtnChangeCount = 100,
    nCommonItemShowNum = 0,
    nShowAddCount = 10,
    bIsHideAddMaxBtn = true,
    bIsHideUpperLimitText = true,
    bIsShowVouchers = bIsShowVouchers,
    bIsShowItemNum = true,
    fExchangeCallback = function(tExchangeData, nCount, _, tCouponData)
      local sBuyStr = LocUtil.GetLocalizeResStr("301185")
      local itemName = LocUtil.GetLocalizeResStr("4577")
      local nBuyScore = nCount * tExchangeData.itemNum
      itemName = GlobalData.GetLocalizeStringWithNum(4577, 0, nBuyScore)
      local sTip = LocUtil.LocalizeResFormat(44542, tCouponData.nCurPrice, itemName)
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      local msgData = {
        styleType = CommonMsgBoxMgr.SHOW_TYPE_TWO,
        title = sBuyStr,
        msg = sTip,
        clickOkCallback = function()
          UnknowPassExchangeSystem.ConfirmBuyScore(nBuyScore, tCouponData.nCouponId, tCouponData.tVouchers)
        end
      }
      CommonMsgBoxMgr.ShowUSPolicyTip(msgData)
    end
  }
  UIManager.ShowUI(UIManager.UI_Config.Common_RPExchangePopup_UIBP, tExchangeData, tExtra)
end
function UnknowPassExchangeSystem.CloseExchangeBuyScoreUI()
  UIManager.CloseUI(UIManager.UI_Config.Common_RPExchangePopup_UIBP)
end
function UnknowPassExchangeSystem.SetExchangeVisible(value)
  local UnknowPassTreasureBoxSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_treasurebox")
  if not UnknowPassTreasureBoxSystem.TreasureBoxUIShowing then
    local UIPanel = UIManager.GetUI(UIManager.UI_Config.unknowpass_exchange)
    if nil ~= UIPanel then
      UIPanel:ChangeIsOnlyShow(value)
    end
  end
end
function UnknowPassExchangeSystem.SetExchangeOpenOrClose(value)
  local UIPanel = UIManager.GetUI(UIManager.UI_Config.unknowpass_exchange)
  if UIPanel then
    if value then
      UIPanel:SelfHitTestInvisible()
    else
      UIPanel:Collapsed()
    end
  end
end
function UnknowPassExchangeSystem.SetHasSubScribed()
  local UnknowPassPrimeSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_subscription")
  return UnknowPassPrimeSystem.CheckAlreadySubScribed(1) or UnknowPassPrimeSystem.CheckAlreadySubScribed(2)
end
function UnknowPassExchangeSystem.IsSetSpecialData(item_data)
  if UnknowPassExchangeSystem.ExchangeItemList[UnknowPassExchangeSystem.SpecialMap[item_data.item_id]].label == item_data.label then
    return true
  end
  if UnknowPassExchangeSystem.SpeciaLabelList[item_data.label] then
    return true
  end
  return false
end
function UnknowPassExchangeSystem.GetSpecailOldItemData(item_data)
  for index, value_item in pairs(UnknowPassExchangeSystem.ExchangeItemList) do
    if value_item.item_id == item_data.item_id and value_item.label == item_data.label then
      return value_item
    end
  end
  return nil
end
function UnknowPassExchangeSystem.SetSpecialItemListLabel(label)
  if not UnknowPassExchangeSystem.SpeciaLabelList then
    UnknowPassExchangeSystem.SpeciaLabelList = {}
  end
  UnknowPassExchangeSystem.SpeciaLabelList[label] = true
end
function UnknowPassExchangeSystem.SetSpecialItemData(new_data, limit, table_data, table_k)
  new_data.exchangeId_2 = table_k
  new_data.disc_cost_item_num_2 = table_data.disc_cost_item_num == 0 and table_data.cost_item_num or table_data.disc_cost_item_num
  new_data.cost_item_num_2 = table_data.cost_item_num
  new_data.pass_level_limit_2 = table_data.pass_level_limit
  new_data.cost_item_id_2 = table_data.cost_item_id
  if limit and 0 < limit.buy_count then
    new_data.buy_count_2 = limit.buy_count
  else
    new_data.buy_count_2 = 0
  end
  local item = new_data
  item.ori_disc_num_2 = item.disc_cost_item_num_2 or table_data.cost_item_num
  local hasSubscribed = UnknowPassExchangeSystem.SetHasSubScribed()
  if hasSubscribed and table_data.cost_item_id == 1099 then
    local UnknowPassPrimeSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_subscription")
    local discount_rate = UnknowPassPrimeSystem.GetDiscountRate()
    item.disc_cost_item_num_2 = math.floor(item.disc_cost_item_num_2 * discount_rate)
  end
  local cfg = CDataTable.GetTableData("Item", table_data.cost_item_id)
  new_data.strCostItemIcon_2 = cfg.ItemSmallIcon2
  new_data.IsEnoughCostItem_2 = UnknowPassExchangeSystem.CheckIsEnoughCostItem(new_data.cost_item_id_2, new_data.disc_cost_item_num_2)
end
function UnknowPassExchangeSystem.SetExchangeItemData(dataTable, exchange_limit, privilege_info)
  UnknowPassExchangeSystem.ExchangeItemList = {}
  UnknowPassExchangeSystem.ExchangeReturnItemList = {}
  UnknowPassExchangeSystem.SpeciaLabelList = {}
  UnknowPassExchangeSystem.PrivilegeInfo = privilege_info
  UnknowPassExchangeSystem.SpecialMap = UnknowPassExchangeSystem.GetSpecialExchangeItemList(UnknowPassExchangeSystem.SpecialType.EXCHANGE)
  local hasSubscribed = UnknowPassExchangeSystem.SetHasSubScribed()
  for k, v in pairs(dataTable) do
    local UnknowPassPrimeSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_subscription")
    if v.need_prime == 0 or UnknowPassPrimeSystem.CheckSubScriptionOpen() then
      local limit = exchange_limit[k]
      if UnknowPassExchangeSystem.SpecialMap and UnknowPassExchangeSystem.SpecialMap[v.item_id] ~= 0 and UnknowPassExchangeSystem.ExchangeItemList[UnknowPassExchangeSystem.SpecialMap[v.item_id]] and UnknowPassExchangeSystem.IsSetSpecialData(v) then
        local nowSpecailItem = UnknowPassExchangeSystem.ExchangeItemList[UnknowPassExchangeSystem.SpecialMap[v.item_id]]
        if nowSpecailItem.label == v.label then
          log(bWriteLog and "[bgp] v.label----------" .. tostring(v.label))
          UnknowPassExchangeSystem.SetSpecialItemData(nowSpecailItem, limit, v, k)
        elseif UnknowPassExchangeSystem.SpeciaLabelList[v.label] then
          local oldData = UnknowPassExchangeSystem.GetSpecailOldItemData(v)
          if oldData then
            log(bWriteLog and "[bgp] v.label=============" .. tostring(v.label))
            UnknowPassExchangeSystem.SetSpecialItemData(oldData, limit, v, k)
          end
        end
      else
        local item = {
          exchangeId = k,
          limit = v.limit,
          single_limit = v.single_limit,
          item_num = v.item_num,
          season_index = v.season_index,
          sort = v.sort,
          pass_level_limit = v.pass_level_limit,
          item_id = v.item_id,
          item_expire_time = v.item_expire_time,
          item_show_type = v.item_show_type,
          need_buy = v.need_buy,
          need_prime = v.need_prime,
          label = v.label or 0,
          cost_item_id = v.cost_item_id,
          cost_item_num = v.cost_item_num,
          disc_cost_item_num = v.disc_cost_item_num,
          cost_item_id_2 = v.cost_item_id_2 or 0,
          cost_item_num_2 = v.cost_item_num_2 or 0,
          disc_cost_item_num_2 = v.disc_cost_item_num_2 or 0,
          exchangeId_2 = 0,
          pass_level_limit_2 = 0,
          buy_count_2 = 0,
          ori_disc_num = 0,
          ori_disc_num_2 = 0,
          is_special = v.is_special,
          if_show_has = v.if_show_has,
          recommend_flag = v.recommend_flag
        }
        if limit and 0 < limit.buy_count then
          item.buy_count = limit.buy_count
        else
          item.buy_count = 0
        end
        if item.disc_cost_item_num == 0 then
          item.disc_cost_item_num = item.cost_item_num
        end
        local cfg = CDataTable.GetTableData("Item", v.cost_item_id)
        item.strCostItemIcon = cfg.ItemSmallIcon2
        item.IsEnoughCostItem = UnknowPassExchangeSystem.CheckIsEnoughCostItem(v.cost_item_id, item.disc_cost_item_num)
        item.ori_disc_num = item.disc_cost_item_num or v.cost_item_num
        if hasSubscribed and item.cost_item_id == 1099 then
          local discount_rate = UnknowPassPrimeSystem.GetDiscountRate()
          item.disc_cost_item_num = math.floor(item.disc_cost_item_num * discount_rate)
        end
        if v.cost_item_id_2 and v.cost_item_id_2 ~= 0 then
          local cfg2 = CDataTable.GetTableData("Item", v.cost_item_id_2)
          item.strCostItemIcon_2 = cfg2.ItemSmallIcon2
          item.IsEnoughCostItem_2 = UnknowPassExchangeSystem.CheckIsEnoughCostItem(v.cost_item_id_2, item.disc_cost_item_num_2)
          item.ori_disc_num_2 = item.disc_cost_item_num_2 or v.cost_item_num_2
          if hasSubscribed and item.cost_item_id_2 == 1099 then
            local discount_rate = UnknowPassPrimeSystem.GetDiscountRate()
            item.disc_cost_item_num_2 = math.floor(item.disc_cost_item_num_2 * discount_rate)
          end
        else
          item.strCostItemIcon_2 = ""
          item.IsEnoughCostItem_2 = false
        end
        if v.page == 1 then
          item.begin_time = v.begin_time
          item.end_time = v.end_time
          table.insert(UnknowPassExchangeSystem.ExchangeItemList, item)
        elseif v.page == 2 then
          item.begin_time = v.begin_time
          item.end_time = v.end_time
          local isLock = UnknowPassExchangeSystem.IsLock(item)
          if isLock then
            local weekIndex = UnknowPassExchangeSystem.IsWeekIndex(item.begin_time)
          end
          table.insert(UnknowPassExchangeSystem.ExchangeReturnItemList, item)
        end
        if UnknowPassExchangeSystem.SpecialMap[v.item_id] then
          UnknowPassExchangeSystem.SpecialMap[v.item_id] = #UnknowPassExchangeSystem.ExchangeItemList
          UnknowPassExchangeSystem.SetSpecialItemListLabel(v.label)
        end
      end
    end
  end
  table.sort(UnknowPassExchangeSystem.ExchangeItemList, function(a, b)
    return a.sort < b.sort
  end)
  table.sort(UnknowPassExchangeSystem.ExchangeReturnItemList, function(a, b)
    return a.sort < b.sort
  end)
  local itemMap = {}
  for k, v in pairs(UnknowPassExchangeSystem.ExchangeItemList) do
    local label = v.label
    if not itemMap[label] then
      itemMap[label] = {}
    end
    table.insert(itemMap[label], v)
  end
  UnknowPassExchangeSystem.ExchangeItemListMap = itemMap
end
function UnknowPassExchangeSystem.GetActiveShopItemList()
  if UnknowPassExchangeSystem.curActiveShopCfgSeason and UnknowPassExchangeSystem.curActiveShopCfgSeason == UnknowPassSystem.Season and UnknowPassExchangeSystem.ActiveShopConfig then
    return UnknowPassExchangeSystem.ActiveShopConfig
  end
  local exchange_info = UnknowPassExchangeSystem.upass_active_shop_info
  if not exchange_info then
    return {}
  end
  local ItemList = CDataTable.GetTableByFilter("RPActiveShopConfig", "season_id", UnknowPassSystem.Season)
  local ItemListMap = {}
  for _, v in pairs(ItemList) do
    ItemListMap[#ItemListMap + 1] = {
      uniq_id = v.uniq_id,
      season_id = v.season_id,
      item_id = v.item_id,
      item_num = v.item_num,
      valid_hours = v.valid_hours,
      limits_num = v.limits_num,
      cost_item_id = v.cost_item_id,
      original_price = v.original_price,
      discount_price = v.discount_price,
      need_rp_level = v.need_rp_level,
      item_end_time = v.item_end_time,
      consider_owned = v.consider_owned,
      buy_count = exchange_info.buy_list and exchange_info.buy_list[v.uniq_id] or 0
    }
  end
  UnknowPassExchangeSystem.ActiveShopConfig = ItemListMap
  UnknowPassExchangeSystem.curActiveShopCfgSeason = UnknowPassSystem.Season
  return ItemListMap
end
function UnknowPassExchangeSystem.GetExchangeItemListByCostId(cost_item_id)
  if not UnknowPassExchangeSystem.curNewExchangeItemListSeason or UnknowPassExchangeSystem.curNewExchangeItemListSeason ~= UnknowPassSystem.Season or not UnknowPassExchangeSystem.ActiveShopConfig then
    local index = 0
    local itemList = UnknowPassExchangeSystem.ExchangeItemListMap[index] or {}
    local tRewardList = {}
    for _, v in pairs(itemList) do
      if v.sort ~= 99 and not UnknowPassExchangeSystem.SpecialMap[v.item_id] then
        tRewardList[#tRewardList + 1] = v
      end
    end
    UnknowPassExchangeSystem.NewExchangeItemList = tRewardList
  end
  if not UnknowPassExchangeSystem.NewExchangeItemList then
    return {}
  end
  local curExchangeItemList = {}
  for _, v in pairs(UnknowPassExchangeSystem.NewExchangeItemList) do
    if v.cost_item_id == cost_item_id then
      table.insert(curExchangeItemList, v)
    end
  end
  return curExchangeItemList
end
function UnknowPassExchangeSystem.UpdateExchangeItemInfo()
  local index = 0
  local itemList = UnknowPassExchangeSystem.ExchangeItemListMap[index] or {}
  local tRewardList = {}
  for _, v in pairs(itemList) do
    if v.sort ~= 99 and not UnknowPassExchangeSystem.SpecialMap[v.item_id] then
      tRewardList[#tRewardList + 1] = v
    end
  end
  UnknowPassExchangeSystem.NewExchangeItemList = tRewardList
end
function UnknowPassExchangeSystem.GetBuyCount(exchangeId)
  for i, v in pairs(UnknowPassExchangeSystem.NewExchangeItemList) do
    if exchangeId == v.exchangeId then
      return v.buy_count
    end
  end
  log(bWriteLog and "UnknowPassExchangeSystem.GetBuyCount  " .. tostring(exchangeId))
  return 0
end
function UnknowPassExchangeSystem.GetSpecialExchangeItemList(_sepcialType)
  local res = {}
  local cfg = CDataTable.GetTable("UnknowPassSpecialExchangeItem")
  local SpecialType = UnknowPassExchangeSystem.SpecialType
  for k, v in pairs(cfg) do
    if UnknowPassSystem.Season == v.SeasonId and (v.specailType == SpecialType.SPECIAL or v.specailType == _sepcialType) then
      res[v.itemId] = 0
    end
  end
  return res
end
function UnknowPassExchangeSystem.CheckIsEnoughCostItem(cost_item_id, cost_item_num)
  log(bWriteLog and "UnknowPassExchangeSystem.CheckIsEnoughCostItem" .. cost_item_num .. cost_item_id)
  if cost_item_id == 1000 then
    if cost_item_num > DataMgr.gold then
      return false
    end
  elseif cost_item_id == 1006 then
    if cost_item_num > DataMgr.ticket then
      return false
    end
  elseif cost_item_id == 1099 then
    if cost_item_num > UnknowPassSystem.Score then
      return false
    end
  elseif cost_item_id == 1109 and cost_item_num > DataMgr.eternal_diamond then
    return false
  end
  return true
end
function UnknowPassExchangeSystem.GetLimitString(data, isSec)
  local strLevelLimit = ""
  local isLock = UnknowPassExchangeSystem.IsLock(data)
  if isLock then
    local weekIndex = UnknowPassExchangeSystem.IsWeekIndex(data.begin_time)
    strLevelLimit = LocUtil.LocalizeResFormat(7039, weekIndex)
  elseif isSec then
    strLevelLimit = GlobalData.GetLocalizeStringWithNum(6391, 0, data.pass_level_limit_2)
  else
    strLevelLimit = GlobalData.GetLocalizeStringWithNum(6391, 0, data.pass_level_limit)
  end
  return strLevelLimit
end
function UnknowPassExchangeSystem.IsLock(itemdata)
  if itemdata and itemdata.begin_time and itemdata.end_time then
    local TimeUtil = require("client.common.time_util")
    return TimeUtil.UnixTimeBetween(itemdata.begin_time, itemdata.end_time) == -1
  end
  return false
end
function UnknowPassExchangeSystem.IsWeekIndex(time)
  local cfg = UnknowPassSystem.SeasonInfo.cfg
  time = tonumber(time)
  if not cfg or not time then
    return 1
  else
    return math.floor((time - cfg.begin_timestamp) / 604800) + 1
  end
end
function UnknowPassExchangeSystem.GetItemAndIndex(itemId, isReturn, callBack)
  local ItemList = {}
  if isReturn then
    ItemList = UnknowPassExchangeSystem.ExchangeReturnItemList
  else
    local UnknowPassTunnelSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknowpass_tunnel")
    local jumpInfo = UnknowPassTunnelSystem.jumpInfo
    local label = tonumber(jumpInfo.SubTab) or 0
    ItemList = UnknowPassExchangeSystem.ExchangeItemListMap[label] or {}
  end
  local itemMap = {}
  for i = 1, #ItemList do
    if ItemList[i].item_id == itemId and callBack then
      callBack(i, itemId, nil)
    else
      local onGetChestInfo = function(item_List, chest_id)
        for _, v in pairs(item_List) do
          if v.itemId == itemId and callBack then
            callBack(i, itemId, ItemList[i].item_id)
            log(bWriteLog and "UnknowPassExchangeSystem.GetItemAndIndex " .. i)
            break
          end
        end
      end
      if not itemMap[ItemList[i].item_id] then
        local PassPreviewSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_preview")
        PassPreviewSystem.GetTreasureBoxItemList(ItemList[i].item_id, onGetChestInfo)
      end
    end
    itemMap[ItemList[i].item_id] = 1
  end
end
function UnknowPassExchangeSystem.ConfirmBuyScore(buyNum, couponid, vouchers)
  log(bWriteLog and "UnknowPassExchangeSystem.ConfirmBuyScore, buyNum = " .. tostring(buyNum) .. ", CurrentScore = " .. tostring(UnknowPassSystem.Score))
  log_tree("UnknowPassExchangeSystem.ConfirmBuyScore ", vouchers)
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  PassDataSystem.upass_buy_score_req(buyNum, UnknowPassSystem.Level, UnknowPassSystem.Score, couponid, vouchers)
end
function UnknowPassExchangeSystem.GetNextWillComeItem()
  for k, data in pairs(UnknowPassExchangeSystem.ExchangeReturnItemList) do
    if data.begin_time then
      local TimeUtil = require("client.common.time_util")
      local nowTime = TimeUtil.GetServerTimeInSec()
      if nowTime < data.begin_time then
        return data
      end
    end
  end
  return nil
end
function UnknowPassExchangeSystem.Release()
  UnknowPassExchangeSystem.ExchangeItemList = {}
  UnknowPassExchangeSystem.ExchangeReturnItemList = {}
end
function UnknowPassExchangeSystem.UpdateRedPoint(isHide)
  local TimeUtil = require("client.common.time_util")
  local UnknowPassMacro = require("client.slua.logic.unknow_pass.unknowpass_macro")
  local redId = UnknowPassSystem.Season * 100 + UnknowPassMacro.ENUM_Pass_Sub_Reddot.UnknowPass_ExchangeReturn_Reddot
  local lastViewTime = DataMgr.GetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_PASS, redId)
  local reddot = false
  local nowTime = TimeUtil.GetServerTimeInSec()
  for k, data in pairs(UnknowPassExchangeSystem.ExchangeReturnItemList) do
    if data.begin_time and nowTime > data.begin_time and (not lastViewTime or lastViewTime < data.begin_time) and not reddot then
      reddot = TimeUtil.InDaysFrom(data.begin_time, 7)
    end
  end
  if isHide == true then
    reddot = false
    DataMgr.SetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_PASS, redId, nowTime)
  end
  return reddot
end
function UnknowPassExchangeSystem.ChangeBackChestLocalCache()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local tCacheInfo = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUnknowPassBackbox) or {}
  if not tCacheInfo.skipstate or tCacheInfo.skipstate == 0 then
    tCacheInfo.skipstate = 1
  else
    tCacheInfo.skipstate = 0
  end
  PlayerPrefsSystem.SaveTableToFile_N(tCacheInfo, PlayerPrefsSystem.ePlayerPrefsType.eUnknowPassBackbox)
end
function UnknowPassExchangeSystem.upass_exchange_list_req()
  local UpassHandle = require("client.network.Protocol.UpassHandle")
  UpassHandle.send_upass_exchange_list_req()
end
function UnknowPassExchangeSystem.upass_exchange_list_rsp(res, tb, exchange_limit, privilege_info)
  log(bWriteLog and "UnknowPassSystem.upass_exchange_list_rsp")
  tb = tb or {}
  UnknowPassExchangeSystem.SetExchangeItemData(tb, exchange_limit, privilege_info)
  UnknowPassExchangeSystem.UpdateExchangeItemInfo()
  EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_EXCHANGE_LIST)
end
function UnknowPassExchangeSystem.upass_exchange_rsp(res, id, reward_list, new_buy_count, chest_items)
  log(bWriteLog and string.format("upass_exchange_rsp id:-------%s, new_buy_count:%s---------", tostring(res), tostring(new_buy_count)))
  if res ~= 0 then
    ShowNotice(res)
  else
    UnknowPassExchangeSystem.upass_exchange_list_req()
    local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
    PassDataSystem.upass_get_req()
    EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_EXCHANGE_SUCCESS, reward_list, new_buy_count, id, chest_items)
  end
end
return UnknowPassExchangeSystem