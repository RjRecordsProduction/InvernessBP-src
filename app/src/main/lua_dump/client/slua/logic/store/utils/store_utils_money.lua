local StoreUtils = require("client.slua.logic.store.utils.store_utils_config")
local localText = function(id)
  return LocUtil.GetLocalizeResStr(id)
end
function StoreUtils.GetMoneyInfo()
  local info = {}
  info.nGold = DataMgr.gold or 0
  info.nUC = DataMgr.ticket or 0
  info.nZhupai = DataMgr.fp_token or 0
  info.nSilver = DataMgr.diamond or 0
  info.nGoldChip = DataMgr.gold_chip or 0
  info.nBattle = DataMgr.battle_coin or 0
  info.nDiamond = DataMgr.eternal_diamond or 0
  info.nAllStarCoin = LobbySystem.roleData.allstar_score
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() then
    info.bShowZhupai = true
    info.bShowBattle = true
  else
    info.bShowZhupai = false
    info.bShowBattle = false
  end
  return info
end
function StoreUtils.GetFirstPriceNumMax(data)
  if data == nil then
    return 0
  end
  local firstType = -1
  local firstMax = 0
  for k, v in pairs(data) do
    if firstType == -1 then
      firstType = v[6]
      firstMax = v[1]
    elseif firstType == v[6] then
      if firstMax < v[1] then
        firstMax = v[1]
      end
    else
      return firstMax
    end
  end
  return firstMax
end
function StoreUtils.GetFirstPriceNumMax2(data)
  if data == nil then
    return 0
  end
  local maxPrice = 0
  for k, v in pairs(data) do
    for kk, vv in pairs(v) do
      if maxPrice < vv.Price then
        maxPrice = vv.Price
      end
    end
  end
  return maxPrice
end
function StoreUtils.GetPriceNumMax(data, selectType)
  if data == nil then
    return 0
  end
  selectType = selectType or -1
  local selectMax = 0
  for k, v in pairs(data) do
    if selectType == -1 then
      selectType = v[6]
      selectMax = v[1]
    elseif selectType == v[6] and selectMax < v[1] then
      selectMax = v[1]
    end
  end
  return selectMax
end
local setPriceInfo = function(priceInfo, original, discount, priceType, icon)
  priceInfo.currency = priceType
  priceInfo.discountPrice = discount
  priceInfo.originalPrice = original
  priceInfo.currencyIcon = icon
  priceInfo.highestPrice = priceInfo.originalPrice
  if priceInfo.discountPrice == 0 then
    priceInfo.discountPrice = priceInfo.originalPrice
  end
end
local resetPriceInfo = function(priceInfo, original, discount, priceType)
  if priceInfo.currency ~= priceType then
    return
  end
  if priceInfo.discountPrice == 0 then
    setPriceInfo(priceInfo, original, discount, priceType, priceInfo.currencyIcon)
  elseif 0 < discount then
    if discount < priceInfo.discountPrice then
      priceInfo.discountPrice = discount
      priceInfo.originalPrice = original
    end
  elseif 0 < original then
    if original < priceInfo.discountPrice then
      priceInfo.discountPrice = original
      priceInfo.originalPrice = original
    elseif original > priceInfo.highestPrice then
      priceInfo.highestPrice = original
    end
  end
end
function StoreUtils.ParsePriceInfo(priceInfo, value, vipFlag)
  local original = value[StoreConst.label_price_index_one_original_price] or 0
  local discount = value[StoreConst.label_price_index_one_discount_price] or 0
  local priceType = value[StoreConst.label_price_index_price_type]
  local isValid, isAG = StoreUtils.IsValidPrice(vipFlag or 0, priceType)
  if isValid then
    if priceInfo.currency == -1 then
      setPriceInfo(priceInfo, original, discount, priceType, "")
    else
      resetPriceInfo(priceInfo, original, discount, priceType)
    end
  end
  return isValid, isAG
end
function StoreUtils.SetCurrencyIcon(currency)
  if currency == StoreConst.label_price_type_bp then
    return StoreUtils.GetPriceIconByItemId(1000), true
  elseif currency == StoreConst.label_price_type_chip then
    return StoreUtils.GetPriceIconByItemId(1001), true
  elseif currency == StoreConst.label_price_type_uc then
    return StoreUtils.GetPriceIconByItemId(1006), false
  elseif currency == StoreConst.label_price_type_battle then
    return StoreUtils.GetPriceIconByItemId(1103), true
  elseif currency == StoreConst.label_price_type_iap then
    return SInAppPurchase, true
  elseif currency == StoreConst.label_price_type_diamond then
    return StoreUtils.GetPriceIconByItemId(1109), false
  elseif currency == StoreConst.label_price_type_allstar then
    return StoreUtils.GetPriceIconByCurrency(currency), true
  elseif currency == StoreConst.label_price_type_fp then
    return StoreUtils.GetPriceIconByItemId(1101), true
  elseif currency == StoreConst.label_price_type_gold_chip then
    return StoreUtils.GetPriceIconByItemId(1104), true
  else
    return StoreUtils.GetPriceIconByItemId(currency), true
  end
end
function StoreUtils.GetShowPrice(vipFlag, priceList, currency)
  local priceInfo = {
    currency = currency or -1,
    currencyIcon = "",
    discountPrice = 0,
    originalPrice = 0,
    highestPrice = 0,
    isAGMark = false,
    isSpecialColorBuyBtn = false
  }
  for key, value in pairs(priceList) do
    local isValid, isAG = StoreUtils.ParsePriceInfo(priceInfo, value, vipFlag)
    if not isValid then
      priceInfo.isAGMark = priceInfo.isAGMark or isAG
    end
  end
  priceInfo.currencyIcon, priceInfo.isSpecialColorBuyBtn = StoreUtils.SetCurrencyIcon(priceInfo.currency)
  return priceInfo or {}
end
function StoreUtils.GetPriceIconByItemId(itemId)
  local result = ""
  if itemId ~= nil then
    local cfg = CDataTable.GetTableData("Item", itemId)
    if cfg ~= nil then
      result = cfg.ItemSmallIcon2
      if result == "" then
        result = cfg.ItemSmallIcon
      end
    end
  end
  return result
end
function StoreUtils.GetPriceIconByCurrency(currency)
  local result = ""
  if currency == StoreConst.label_price_type_bp then
    result = "/Game/UMG/Texture/Atlas/Common_Atlas/Frames/LOBBY_icon_jinbi_64x64_png.LOBBY_icon_jinbi_64x64_png"
  elseif currency == StoreConst.label_price_type_chip then
    result = "/Game/UMG/Texture/Atlas/Common_Atlas/Frames/Shop_icon_silverypiece_png.Shop_icon_silverypiece_png"
  elseif currency == StoreConst.label_price_type_uc then
    result = "/Game/UMG/Texture/Atlas/Common_Atlas/Frames/Task_icon_coupons_64_png.Task_icon_coupons_64_png"
  elseif currency == StoreConst.label_price_type_battle then
    result = "/Game/Arts/UI/TableIcons/ItemIcon/Currency/Championship_Coin_128.Championship_Coin_128"
  elseif currency == StoreConst.label_price_type_diamond then
    result = "/Game/UMG/Texture/Atlas/Common_Atlas/Frames/Lobby_Image_Money_png.Lobby_Image_Money_png"
  elseif currency == StoreConst.label_price_type_allstar then
    result = "/Game/Arts/UI/TableIcons/ItemIcon/Currency/Currency_Small/Currency_ESport_64.Currency_ESport_64"
  elseif currency == StoreConst.label_price_type_fp then
    result = "/Game/UMG/Texture/Atlas/GeneralLobbyUI/Frames/TASK_icon_zupailing_png.TASK_icon_zupailing_png"
  elseif currency == StoreConst.label_price_type_gold_chip then
    result = "/Game/Arts/UI/TableIcons/ItemIcon/Currency/ClothingCoin_Gold_64.ClothingCoin_Gold_64"
  elseif currency == StoreConst.label_price_type_gold_suit then
    local logic_xsuit_activity = ModuleManager.GetModule(ModuleManager.JumpModuleConfig.logic_xsuit_activity)
    local itemCfg = CDataTable.GetTableData("Item", logic_xsuit_activity:GetDrawCurrencyID())
    if itemCfg then
      result = itemCfg.ItemSmallIcon
    end
  elseif currency == StoreConst.label_price_type_active_coin then
    local ShopSystem = require("client.logic.shop.logic_shop")
    result = ShopSystem.jkActivePrice.couponIcon
  else
    local UIUtil = require("client.common.ui_util")
    return UIUtil.GetItemSmallIcon2(currency)
  end
  return result
end
function StoreUtils.get_money_type_and_price(id, is_first_money, shopInfo, time_valid_index)
  local node = shopInfo
  local money_type = node.money1_type
  local money_price = node.money1_price
  if is_first_money == 1 then
    money_type = node.money1_type
    if not time_valid_index or time_valid_index == 1 then
      money_price = node.money1_price
    elseif time_valid_index == 2 then
      money_price = node.money1_price2
    elseif time_valid_index == 3 then
      money_price = node.money1_price3
    end
  else
    money_type = node.money2_type
    if not time_valid_index or time_valid_index == 1 then
      money_price = node.money2_price
    elseif time_valid_index == 2 then
      money_price = node.money2_price2
    elseif time_valid_index == 3 then
      money_price = node.money2_price3
    end
  end
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  if node.permanet_discount_begin_time ~= 0 and node.permanet_discount_begin_time ~= "" then
    local start_tm = node.permanet_discount_begin_time
    if now >= start_tm then
      if is_first_money ~= 1 then
        money_price = node.permanet_discount_price2
      else
        money_price = node.permanet_discount_price1
      end
    end
  end
  if node.timelimit_discount_begin_time ~= "" and node.timelimit_discount_begin_time ~= 0 and node.timelimit_discount_end_time ~= "" and node.timelimit_discount_end_time ~= 0 then
    local start_tm = node.timelimit_discount_begin_time
    local end_tm = node.timelimit_discount_end_time
    if now >= start_tm and now <= end_tm then
      if is_first_money ~= 1 then
        money_price = node.timelimit_discount_price2
      else
        money_price = node.timelimit_discount_price1
      end
    end
  end
  return money_type, money_price
end
function StoreUtils.MoneyTypeToFiveMoneyType(moneyType)
  if moneyType == 0 then
    return 1000
  elseif moneyType == 1 then
    return 1001
  elseif moneyType == 2 then
    return 1006
  end
  return moneyType
end
function StoreUtils.CanShowDiamond()
  if LobbySystem.CheckOpen(BP_ENUM_LOBBY_MENU_DIAMONDE) then
    return true
  else
    return false
  end
end
function StoreUtils.GetCongratulationDiamondState()
  local playerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local probabilityCheckBoxRecord = playerPrefsSystem.LoadFileToTable_N(playerPrefsSystem.ePlayerPrefsType.eCrateCustomShowProbability)
  local checked = true
  if probabilityCheckBoxRecord ~= nil and probabilityCheckBoxRecord.diamondChecked ~= nil then
    checked = probabilityCheckBoxRecord.diamondChecked or false
  end
  return checked
end
function StoreUtils.SaveCongratulationDiamondState(checked)
  local playerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local probabilityCheckBoxRecord = playerPrefsSystem.LoadFileToTable_N(playerPrefsSystem.ePlayerPrefsType.eCrateCustomShowProbability)
  if probabilityCheckBoxRecord == nil then
    probabilityCheckBoxRecord = {}
    probabilityCheckBoxRecord.diamondChecked = checked
  else
    probabilityCheckBoxRecord.diamondChecked = checked
  end
  playerPrefsSystem.SaveTableToFile_N(probabilityCheckBoxRecord, playerPrefsSystem.ePlayerPrefsType.eCrateCustomShowProbability)
end
function StoreUtils.GetMoneyName(money_type)
  local money_name = ""
  local itm_cfg = CDataTable.GetTableData("Item", money_type)
  if itm_cfg then
    return itm_cfg.ItemName
  end
  return money_name
end
function StoreUtils.CheckMoneyIsEnough(money_type, money_price, callback)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  local money_name = ""
  if money_type ~= StoreConst.label_price_type_iap then
    money_name = StoreUtils.GetMoneyName(money_type)
  end
  if money_type == 1000 then
    if money_price > DataMgr.gold then
      local str = LocUtil.LocalizeResFormat(7055, money_name)
      CommonMsgBoxMgr.Show(1, localText(101001), str, function()
        callback(false, StoreUtils.CheckMoneyBtnType.OK)
      end)
    else
      callback(true)
    end
  elseif money_type == 1001 then
    local ticket_name = StoreUtils.GetMoneyName(1006)
    if money_price > DataMgr.diamond then
      local now_ticket = DataMgr.ticket
      local need_diamond = money_price - DataMgr.diamond
      if now_ticket >= need_diamond then
        local str = string.format(localText(501051), money_name, need_diamond, ticket_name)
        local msgData = {
          styleType = 2,
          title = localText(101001),
          msg = str,
          clickOkCallback = function()
            callback(true, StoreUtils.CheckMoneyBtnType.OK)
          end,
          clickCancelCallback = function()
            callback(true, StoreUtils.CheckMoneyBtnType.Cancel)
          end
        }
        CommonMsgBoxMgr.ShowUSPolicyTip(msgData)
        return
      end
      local str2 = string.format(localText(501052), money_name)
      local msgData = {
        styleType = 2,
        title = localText(101001),
        msg = str2,
        clickOkCallback = function()
          callback(false, StoreUtils.CheckMoneyBtnType.Pay)
          local RechargeSystem = require("client.logic.recharge.logic_recharge")
          RechargeSystem.OpenRechargeUI()
        end,
        clickCancelCallback = function()
          callback(false, StoreUtils.CheckMoneyBtnType.Cancel)
        end
      }
      CommonMsgBoxMgr.ShowUSPolicyTip(msgData)
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
  elseif money_type == StoreConst.label_price_type_iap then
    callback(true)
  elseif money_type == -1000 then
    callback(true)
  else
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local itemNum = wardrobe_data:GetHallDepotItemCountByResID(money_type)
    if money_price > itemNum then
      local ItemConfig = CDataTable.GetTableData("Item", money_type)
      local str = LocUtil.LocalizeResFormat(501053, ItemConfig.ItemName or "")
      ShowNotice(str)
    else
      callback(true)
    end
  end
end
function StoreUtils.FiveMoneyTypeToMoneyType(moneyType)
  if moneyType == 1000 then
    return 0
  elseif moneyType == 1001 then
    return 1
  elseif moneyType == 1006 then
    return 2
  end
  return moneyType
end
function StoreUtils.CheckMoney(callback, PriceList, CouponDiscountPrice)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  local goldToPurchase = 0
  local diamondToPurchase = 0
  local ticketToPurchase = 0
  local eternalDiamond = 0
  local otherCurrency = 0
  for i, v in pairs(PriceList) do
    if v.Type == 0 then
      goldToPurchase = goldToPurchase + v.Price * v.Num
    end
    if v.Type == 1 then
      diamondToPurchase = diamondToPurchase + v.Price * v.Num
    end
    if v.Type == 2 then
      ticketToPurchase = ticketToPurchase + v.Price * v.Num
    end
    if v.Type == 6 then
      eternalDiamond = eternalDiamond + v.Price * v.Num
    end
    if v.Type ~= 0 and v.Type ~= 1 and v.Type ~= 2 and v.Type ~= 6 then
      local ItemConfig = CDataTable.GetTableData("Item", v.Type)
      if ItemConfig and (ItemConfig.ItemType == 100 or ItemConfig.ItemType == ENUM_ITEM_TYPE.CYCLE_Memory_Item) then
        otherCurrency = otherCurrency + v.Price * v.Num
      end
    end
  end
  if goldToPurchase > DataMgr.gold then
    ShowNotice(502024)
    return false
  end
  if CouponDiscountPrice then
    ticketToPurchase = ticketToPurchase - CouponDiscountPrice
  end
  if ticketToPurchase > DataMgr.ticket then
    local CommonPayBoxMgr = require("client.slua.logic.common.Payclass.logic_common_pay_box")
    CommonPayBoxMgr.ShowUcRechargeMsg(ticketToPurchase)
    return false
  end
  local diamond = DataMgr.eternal_diamond or 0
  if eternalDiamond > diamond then
    local needAutoExchange = eternalDiamond - diamond
    local strBuy = LocUtil.GetLocalizeResStr(301185)
    local tips = LocUtil.GetLocalizeResStr(9488)
    tips = string.gsub(tips, "'", "\"")
    tips = LocUtil.LocalizeResFormatByStr(tips, needAutoExchange, math.ceil(needAutoExchange / 10))
    local msgData = {
      styleType = 2,
      title = strBuy,
      msg = tips,
      clickOkCallback = function()
        local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
        if QRcodeRestrictManager:CheckUCRestrict() then
          return false
        end
        local nNeedCount = math.ceil(needAutoExchange / 10)
        if nNeedCount > DataMgr.ticket then
          local CommonPayBoxMgr = require("client.slua.logic.common.Payclass.logic_common_pay_box")
          CommonPayBoxMgr.ShowUcRechargeMsg(nNeedCount)
        else
          if type(callback) == "function" then
            callback()
          end
          return true
        end
      end
    }
    CommonMsgBoxMgr.ShowUSPolicyTip(msgData)
    return false
  end
  if diamondToPurchase > DataMgr.diamond then
    ShowNotice(4457)
    return false
  end
  if 0 < otherCurrency then
    local itemID = PriceList[1].Type
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local ownCurrencyNum = wardrobe_data:GetHallDepotItemCountByResID(itemID)
    if otherCurrency > ownCurrencyNum then
      local ItemConfig = CDataTable.GetTableData("Item", itemID)
      local str = LocUtil.LocalizeResFormat(501053, ItemConfig.ItemName or "")
      ShowNotice(str)
      EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_SELECT_CRYSTALS, itemID)
      return false
    end
  end
  if type(callback) == "function" then
    callback()
  end
  return true
end
function StoreUtils.GetBuySource()
  local Buy_Source = 2
  local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
  local frame = store_supply_manager:GetCurrentFrame()
  if frame ~= nil and frame.currentTabData ~= nil and frame.currentTabData.tabId == StoreConst.Page_New_ID_Recommend then
    local subTabData = frame.currentSubTabData
    if subTabData and subTabData.subTabId and subTabData.subTabId == StoreConst.subtype_new_recommend_rec then
      Buy_Source = 1
    end
  end
  return Buy_Source
end
function StoreUtils.GetBuyInfo(shopID)
  local BuyInfo = {
    daily_buy_cnt = 0,
    week_buy_cnt = 0,
    permanet_buy_cnt = 0
  }
  local store_limit_buy_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_limit_buy_manager)
  local specialGiftShopID = store_limit_buy_manager:GetDelaySpecialGiftShopID()
  if specialGiftShopID ~= 0 and specialGiftShopID == shopID then
    return store_limit_buy_manager:GetSpecialGiftBuyInfo(shopID)
  end
  if StoreConst.buy_info and StoreConst.buy_info[shopID] then
    BuyInfo.daily_buy_cnt = StoreConst.buy_info[shopID].daily_buy_cnt or 0
    BuyInfo.week_buy_cnt = StoreConst.buy_info[shopID].week_buy_cnt or 0
    BuyInfo.permanet_buy_cnt = StoreConst.buy_info[shopID].permanet_buy_cnt or 0
  end
  return BuyInfo
end
function StoreUtils.NoEnoughUCAndGoCharge()
  local LadderDrawSystem = require("client.slua.logic.lobby_activity.logic_ladder_draw")
  local ladder = LadderDrawSystem.GetLadder()
  local awardPoolPriceCfg = LadderDrawSystem.GetAwardPoolAndPriceConfig()
  local pCfg = awardPoolPriceCfg[ladder] or {}
  local needUC = pCfg.paid_count or 0
  local CommonPayBoxMgr = require("client.slua.logic.common.Payclass.logic_common_pay_box")
  CommonPayBoxMgr.ShowUcRechargeMsg(needUC)
end
function StoreUtils.GetTwoValidPriceForShow(price)
  local currency = {}
  table.insert(currency, StoreConst.label_price_type_bp)
  table.insert(currency, StoreConst.label_price_type_chip)
  table.insert(currency, StoreConst.label_price_type_uc)
  table.insert(currency, StoreConst.label_price_type_fp)
  table.insert(currency, StoreConst.label_price_type_exchage)
  table.insert(currency, StoreConst.label_price_type_gold_chip)
  local result = {}
  for k, v in pairs(currency) do
    if price[v] ~= nil and price[v].price > 0 then
      table.insert(result, price[v])
    end
  end
  while #result < 2 do
    local temp = {}
    temp.currency = -1
    temp.price = 0
    temp.original = 0
    table.insert(result, temp)
  end
  return result
end
function StoreUtils.IsValidPrice(vipFlag, priceType)
  local logic_subscribe_handler = require("client.slua.logic.subscribe.logic_subscribe_handler")
  local subscribeModuleObj = logic_subscribe_handler.GetSubscribeModuleObj()
  if not subscribeModuleObj:GetIsPrimeOpen() and vipFlag == StoreConst.vip_type_mode_primeplus and priceType == StoreConst.label_price_type_bp then
    return false, false
  end
  if priceType == StoreConst.label_price_type_diamond and StoreUtils.CanShowDiamond() == false then
    return false, true
  end
  return true, false
end