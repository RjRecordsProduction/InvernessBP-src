local StoreUtils = require("client.slua.logic.store.utils.store_utils_config")
function StoreUtils.ConvertToShopInfo(ItemData, TabId, SubId)
  if not ItemData then
    log_error("StoreUtils.ConvertToShopInfo(ItemData is nil!)")
    return
  end
  local ShopInfo = {
    valid_hours1 = 0,
    valid_hours2 = 0,
    valid_hours3 = 0,
    valid2_hours1 = 0,
    valid2_hours2 = 0,
    valid2_hours3 = 0,
    money1_type = 0,
    money1_price = 0,
    money1_price2 = 0,
    money1_price3 = 0,
    money2_type = 0,
    money2_price = 0,
    money2_price2 = 0,
    money2_price3 = 0,
    item_id = 0,
    id = 0,
    name = "",
    gift_open = false,
    off_rate = 0,
    title_hot = false,
    title_new = false,
    item_count = 1,
    shop_rank = 0,
    timelimit_off_rate = 0,
    timelimit_discount_begin_time = 0,
    daily_buy_limit = 0,
    week_buy_limit = 0,
    permanet_buy_limit = 0,
    item_type = 0,
    item_sub_type = 0,
    tab_id = 0,
    sub_id = 0,
    is_vip_item = 0,
    isZeroUC = 0,
    timelimit_discount_end_time = 0,
    timelimit_discount_price1 = 0,
    timelimit_discount_price2 = 0,
    permanet_discount_begin_time = 0,
    permanet_discount_price1 = 0,
    permanet_discount_price2 = 0,
    voucher = {},
    sale_begin_time = 0,
    sale_end_time = 0,
    show_limit_time = 0,
    page = 0,
    icon_name = "",
    item_tips = "",
    category = 0,
    valid_time = 1
  }
  local PriceList = ItemData[StoreConst.label_item_index_price_list]
  if PriceList and next(PriceList) then
    local validHourIdx1, validHourIdx2 = 1, 1
    local firstType = PriceList[1][StoreConst.label_price_index_price_type]
    local priceKey = ""
    for i, v in ipairs(PriceList) do
      if v[StoreConst.label_price_index_price_type] == firstType then
        ShopInfo["valid_hours" .. validHourIdx1] = v[StoreConst.label_price_index_valid_hours]
        if validHourIdx1 == 1 then
          ShopInfo.money1_type = v[StoreConst.label_price_index_price_type]
          priceKey = "money1_price"
        else
          priceKey = "money1_price" .. validHourIdx1
        end
        validHourIdx1 = validHourIdx1 + 1
      else
        ShopInfo["valid2_hours" .. validHourIdx2] = v[StoreConst.label_price_index_valid_hours]
        if validHourIdx2 == 1 then
          ShopInfo.money2_type = v[StoreConst.label_price_index_price_type]
          priceKey = "money2_price"
        else
          priceKey = "money2_price" .. validHourIdx2
        end
        validHourIdx2 = validHourIdx2 + 1
      end
      if v[StoreConst.label_price_index_one_discount_price] and 0 < v[StoreConst.label_price_index_one_discount_price] then
        ShopInfo[priceKey] = v[StoreConst.label_price_index_one_discount_price]
      else
        ShopInfo[priceKey] = v[StoreConst.label_price_index_one_original_price]
      end
    end
  end
  ShopInfo.item_id = ItemData[StoreConst.label_item_index_id]
  ShopInfo.item_type = 0
  ShopInfo.item_sub_type = 0
  local itemConfig = CDataTable.GetTableData("Item", ShopInfo.item_id or 0)
  if itemConfig then
    ShopInfo.item_type = itemConfig.ItemType or 0
    ShopInfo.item_sub_type = itemConfig.ItemSubType or 0
  end
  ShopInfo.id = ItemData[StoreConst.label_item_index_market_id]
  if ItemData[StoreConst.label_item_index_can_gift] and StoreUtils.CanSendGift() then
    ShopInfo.bCanBeGift = true
  end
  ShopInfo.off_rate = ItemData[StoreConst.label_item_index_up_value]
  if ItemData[StoreConst.label_item_index_hot_or_new] == 1 then
    ShopInfo.title_hot = true
  elseif ItemData[StoreConst.label_item_index_hot_or_new] == 2 then
    ShopInfo.title_new = true
  end
  ShopInfo.item_count = ItemData[StoreConst.label_item_index_count] or 0
  local LimitInfo = ItemData[StoreConst.label_item_index_buy_limit]
  if LimitInfo then
    ShopInfo.daily_buy_limit = LimitInfo[StoreConst.label_buy_limit_type_daily] or 0
    ShopInfo.week_buy_limit = LimitInfo[StoreConst.label_buy_limit_type_week] or 0
    ShopInfo.permanet_buy_limit = LimitInfo[StoreConst.label_buy_limit_type_permanent] or 0
  end
  ShopInfo.tab_id = TabId
  ShopInfo.sub_id = SubId
  ShopInfo.is_vip_item = ItemData[StoreConst.label_item_index_vip] or 0
  ShopInfo.isZeroUC = ItemData[StoreConst.label_item_index_zero_uc_mark] == 1
  ShopInfo.isPreferencesGift = ItemData[StoreConst.label_item_index_preferences_gift] == 1
  ShopInfo.timelimit_off_rate = 0
  ShopInfo.timelimit_discount_begin_time = 0
  ShopInfo.timelimit_discount_end_time = 0
  ShopInfo.timelimit_discount_price1 = 0
  ShopInfo.timelimit_discount_price2 = 0
  ShopInfo.permanet_discount_begin_time = 0
  ShopInfo.permanet_discount_price1 = 0
  ShopInfo.permanet_discount_price2 = 0
  ShopInfo.voucher = {}
  ShopInfo.sale_begin_time = 0
  ShopInfo.sale_end_time = 0
  ShopInfo.show_limit_time = 0
  ShopInfo.name = ""
  ShopInfo.shop_rank = 0
  ShopInfo.page = 0
  ShopInfo.icon_name = ""
  ShopInfo.item_tips = ""
  ShopInfo.category = 0
  ShopInfo.valid_time = 1
  return ShopInfo
end