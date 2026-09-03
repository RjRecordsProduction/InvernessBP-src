local StoreUtils = require("client.slua.logic.store.utils.store_utils_config")
function StoreUtils.IsPossessed(ItemId, ColorId, PatternId)
  local cfg = CDataTable.GetTableData("Item", ItemId)
  if cfg ~= nil then
    local IsWithCount = StoreUtils.IsWithCount(cfg.ItemType, cfg.ItemSubType)
    if not IsWithCount then
      ColorId = ColorId or 0
      PatternId = PatternId or 0
      return StoreUtils.HasItem(ItemId, ColorId, PatternId)
    end
    if cfg.ItemType == ENUM_ITEM_TYPE.Medicine then
      local ItemUpGradeHandler = require("client.network.Protocol.ItemUpGradeHandler")
      return ItemUpGradeHandler.HasItem(ItemId)
    end
    if cfg.ItemType == ENUM_ITEM_TYPE.VehicleAccessory then
      local LogicVehicleAccessory = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicVehicleAccessory)
      return LogicVehicleAccessory:CheckHasGetAccessoryItem(ItemId)
    end
    if cfg.ItemSubType == ENUM_ITEM_SUBTYPE.Automatic_Decomposition then
      local ItemUpgradeMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.ItemUpgradeModule)
      if StoreUtils.HasItem(ItemId) then
        return true
      end
      return ItemUpgradeMgr:CheckSpecialMaterialIsHave(ItemId)
    end
    return false
  else
    return false
  end
end
function StoreUtils.GetDiscountTimePeriodStr(startTime, endTime)
  local TimeUtil = require("client.common.time_util")
  return TimeUtil.FormatTime_timeFrame(startTime, endTime, false, false, TimeUtil.FormatTime_MD)
end
function StoreUtils.GetIconShowInLeftByPriority(isVIP, discount, itemData)
  isVIP = 0 < isVIP
  local isDiscount = discount ~= 0
  local isHot = StoreUtils.CanShowHotIcon(itemData)
  local logic_subscribe_handler = require("client.slua.logic.subscribe.logic_subscribe_handler")
  local subscribeModuleObj = logic_subscribe_handler.GetSubscribeModuleObj()
  if isVIP == true and subscribeModuleObj:GetIsPrimeOpen() == true then
    return true, false, false
  elseif isDiscount == true then
    return false, true, false
  elseif isHot == true then
    return false, false, true
  else
    return false, false, false
  end
end
function StoreUtils.GetIconByCurrencyType(type)
  if type == StoreConst.label_price_type_diamond then
    return "/Game/Arts/UI/TableIcons/ItemIcon/Currency/Task_icon_currency2_64.Task_icon_currency2_64"
  elseif type == StoreConst.label_price_type_bp then
    return "/Game/Arts/UI/TableIcons/ItemIcon/Currency/Task_icon_BP_64.Task_icon_BP_64"
  elseif type == StoreConst.label_price_type_fp then
    return "/Game/Arts/UI/TableIcons/ItemIcon/Currency/Task_icon_zupailing_64.Task_icon_zupailing_64"
  elseif type == StoreConst.label_price_type_battle then
    return "/Game/Arts/UI/TableIcons/ItemIcon/Currency/icon_Battlefield_64.icon_Battlefield_64"
  elseif type == StoreConst.label_price_type_chip then
    return "/Game/Arts/UI/TableIcons/ItemIcon/Currency/ClothingCoin_Int_64.ClothingCoin_Int_64"
  elseif type == StoreConst.label_price_type_gold_chip then
    return "/Game/Arts/UI/TableIcons/ItemIcon/Currency/ClothingCoin_Gold_64.ClothingCoin_Gold_64"
  else
    return "/Game/Arts/UI/TableIcons/ItemIcon/Currency/Task_icon_coupons_64.Task_icon_coupons_64"
  end
end
function StoreUtils.GetIconShowInRightByPriority(specialIcon, new)
  local hasSpecialIcon = specialIcon ~= ""
  new = new or false
  hasSpecialIcon = hasSpecialIcon or false
  if hasSpecialIcon then
    return true, false
  end
  if new then
    return false, true
  end
  return false, false
end
function StoreUtils.CanShowNewIcon(data)
  local isNew = data[StoreConst.label_item_index_show_new] or 0
  local marketId = data[StoreConst.label_item_index_market_id] or 0
  local startTime = data[StoreConst.label_item_index_start_time] or 0
  local playerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local newItemClickRecord = playerPrefsSystem.LoadFileToTable_N(playerPrefsSystem.ePlayerPrefsType.eStoreNewItemClickRecord)
  local haveClicked = false
  if newItemClickRecord ~= nil and newItemClickRecord[tostring(marketId)] ~= nil then
    haveClicked = true
  end
  local TimeUtil = require("client.common.time_util")
  if isNew == 1 and haveClicked == false and startTime ~= 0 and TimeUtil.GetServerTimeInSec() < startTime + StoreUtils.NewFlagAvailableTime then
    return true
  end
  return false
end
function StoreUtils.RecordHaveShowedNewItem(shopId)
  local needSave = true
  local playerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local newItemClickRecord = playerPrefsSystem.LoadFileToTable_N(playerPrefsSystem.ePlayerPrefsType.eStoreNewItemClickRecord)
  local key = tostring(shopId)
  if newItemClickRecord == nil then
    newItemClickRecord = {}
    newItemClickRecord[key] = 1
  elseif newItemClickRecord[key] == nil then
    newItemClickRecord[key] = 1
  else
    needSave = false
  end
  if needSave then
    playerPrefsSystem.SaveTableToFile_N(newItemClickRecord, playerPrefsSystem.ePlayerPrefsType.eStoreNewItemClickRecord)
  end
end
function StoreUtils.CheckIsNew(data)
  local isNew = data[StoreConst.label_item_index_show_new] or 0
  local marketId = data[StoreConst.label_item_index_market_id] or 0
  local startTime = data[StoreConst.label_item_index_start_time] or 0
  local TimeUtil = require("client.common.time_util")
  local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
  if isNew == 1 and store_supply_manager:CheckHasRecordNewTag(marketId) == false and startTime ~= 0 and TimeUtil.GetServerTimeInSec() - startTime < StoreUtils.NewFlagAvailableTime then
    return true
  end
  return false
end
function StoreUtils.CheckNeedShowSaleEndTime(data)
  local showSaleEndTimeHour = data[StoreConst.label_item_index_cout_down_time] or 0
  local saleEndTime = data[StoreConst.label_item_index_time_limit] or 0
  if data[StoreConst.label_item_index_show_time_limit] == 1 then
    local TimeUtil = require("client.common.time_util")
    if showSaleEndTimeHour == 0 or FuncUtil.GetServerTimeInSec() >= saleEndTime - showSaleEndTimeHour * 3600 and saleEndTime > TimeUtil.GetServerTimeInSec() then
      return true
    else
      return false
    end
  else
    return false
  end
end
function StoreUtils.GetMonthDayStr(time)
  local TimeUtil = require("client.common.time_util")
  return TimeUtil.FormatTime_MD(time)
end
function StoreUtils.GetLowestPriceByCurrency(vipFlag, price)
  local allCurrency = {}
  local allCurrencyLength = 1
  local validPriceList = {}
  local validPriceListLength = 1
  for key, value in pairs(price) do
    if StoreUtils.IsValidPrice(vipFlag, value[StoreConst.label_price_index_price_type]) then
      local temp = {}
      temp.currency = value[StoreConst.label_price_index_price_type]
      temp.duration = value[StoreConst.label_price_index_valid_hours] or 0
      temp.original = value[StoreConst.label_price_index_one_original_price] or 0
      temp.discount = value[StoreConst.label_price_index_one_discount_price] or 0
      validPriceList[validPriceListLength] = temp
      validPriceListLength = validPriceListLength + 1
      local exist = false
      for kk, vv in pairs(allCurrency) do
        if vv == temp.currency then
          exist = true
          break
        end
      end
      if exist == false then
        allCurrency[allCurrencyLength] = temp.currency
        allCurrencyLength = allCurrencyLength + 1
      end
    end
  end
  for k, v in pairs(StoreUtils.priceTypeList) do
    local exist = false
    for kk, vv in pairs(allCurrency) do
      if v == vv then
        exist = true
        break
      end
    end
    if exist == false then
      allCurrency[allCurrencyLength] = v
      allCurrencyLength = allCurrencyLength + 1
    end
  end
  local result = {}
  local resultLength = 1
  for i, v in ipairs(allCurrency) do
    local lowest = {}
    lowest.currency = v
    lowest.discountPrice = 0
    lowest.originalPrice = 0
    for ii, vv in ipairs(validPriceList) do
      if vv.currency == lowest.currency then
        if lowest.discountPrice == 0 then
          lowest.discountPrice = vv.original
          lowest.originalPrice = vv.original
          if 0 < vv.discount then
            lowest.discountPrice = vv.discount
          end
        elseif 0 < vv.discount then
          if vv.discount < lowest.discountPrice then
            lowest.discountPrice = vv.discount
            lowest.originalPrice = vv.original
          end
        elseif vv.original < lowest.discountPrice then
          lowest.discountPrice = vv.original
          lowest.originalPrice = vv.original
        end
      end
    end
    result[resultLength] = lowest
    resultLength = resultLength + 1
  end
  return result
end
function StoreUtils.CalculateLowestByCurrency(price)
  local currency = {}
  for i, v in ipairs(price) do
    if #currency == 0 or currency[#currency] ~= v.currency then
      table.insert(currency, v.currency)
    end
  end
  local priceTypeList = {
    StoreConst.label_price_type_bp,
    StoreConst.label_price_type_chip,
    StoreConst.label_price_type_uc,
    StoreConst.label_price_type_fp,
    StoreConst.label_price_type_exchage,
    StoreConst.label_price_type_gold_chip
  }
  for i, v in ipairs(priceTypeList) do
    local isExist = false
    for ii, vv in ipairs(currency) do
      if v == vv then
        isExist = true
        break
      end
    end
    if not isExist then
      table.insert(currency, v)
    end
  end
  local result = {}
  for i, v in ipairs(currency) do
    local lowest = {}
    lowest.currency = v
    lowest.price = 0
    lowest.original = 0
    for ii, vv in ipairs(price) do
      if vv.currency == lowest.currency then
        if lowest.price == 0 then
          lowest.price = vv.original
          lowest.original = vv.original
          if 0 < vv.discount then
            lowest.price = vv.discount
          end
        elseif 0 < vv.discount then
          if vv.discount < lowest.price then
            lowest.price = vv.discount
            lowest.original = vv.original
          end
        elseif vv.original < lowest.price then
          lowest.price = vv.original
          lowest.original = vv.original
        end
      end
    end
    table.insert(result, lowest)
  end
  return result
end
function StoreUtils.HideVisibleDialog()
  if UIManager.IsUIShow(UIManager.UI_Config.select_price_popup) then
    UIManager.CloseUI(UIManager.UI_Config.select_price_popup)
  end
  if UIManager.GetUI(UIManager.UI_Config.rate_panel_ui) then
    UIManager.CloseUI(UIManager.UI_Config.rate_panel_ui)
  end
  if UIManager.IsUIShow(UIManager.UI_Config.GivingGifts_Popup_UIBP) then
    UIManager.CloseUI(UIManager.UI_Config.GivingGifts_Popup_UIBP)
  end
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.HideAllPanel()
end
function StoreUtils.ShowSelectPayPopup(ticketPrice, tokenPrice, isTen, CrateCouponBranch, isAG, supplyOneDiscData)
  UIManager.ShowUI(UIManager.UI_Config.select_price_popup, ticketPrice, tokenPrice, isTen, CrateCouponBranch, isAG, supplyOneDiscData)
end
function StoreUtils.ShowGuaranteeAwardInfo(item_id, title)
  log(bWriteLog and "StoreOtherUtils.ShowGuaranteeAwardInfo, item_id = " .. tostring(item_id) .. ", title = " .. tostring(title))
  UIManager.ShowUI(UIManager.UI_Config.supply_guarantee_awardInfo, item_id, title)
end
function StoreUtils.GetCreditConfigByTime()
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local myRegion = FuncUtil.GetAccountRegionForBP()
  local result
  local TimeUtil = require("client.common.time_util")
  local currentTime = TimeUtil.GetServerTimeInSec()
  local jpCfg = BasicDataServerTable:GetCacheData(StoreConst.custom_crate_ban_table_kr_names.custom_chest_cfg_jpkr) or {}
  local CustomCrateHandler = require("client.network.Protocol.CustomCrateHandler")
  local supply_credit_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.supply_credit_manager)
  if next(jpCfg) then
    for i, v in pairs(jpCfg) do
      local startTime = v.begin_time_ts
      local endTime = v.end_time_ts
      if currentTime >= startTime and currentTime < endTime then
        local regions = v.area_set or {}
        for reg, _ in pairs(regions) do
          if reg == myRegion then
            result = v
            result.List = supply_credit_manager:SetProgressData(result)
            CustomCrateHandler.currentStage = i
            return result
          end
        end
      end
    end
  end
  return result
end
function StoreUtils.GetSupplyPageTagQueue(bDrop, bFree, bDiscount, bHasAct)
  if bDrop then
    bDrop = true
    bFree = false
    bDiscount = false
    bHasAct = false
  elseif bFree then
    bDrop = false
    bFree = true
    bDiscount = false
    bHasAct = false
  elseif bDiscount then
    bDrop = false
    bFree = false
    bDiscount = true
    bHasAct = false
  elseif bHasAct then
    bDrop = false
    bFree = false
    bDiscount = false
    bHasAct = true
  end
  return bDrop, bFree, bDiscount, bHasAct
end
function StoreUtils.ShowSupplyRateNotGlobal()
  local strRegion = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local WebviewSDK = require("client.slua.logic.url.logic_webview_sdk")
  if strRegion == PublishRegionMacros.JAPAN then
    WebviewSDK:OpenURL(FuncUtil.GetDomainByID(3366039) .. "/wanderer.html")
  elseif strRegion == PublishRegionMacros.KOREA then
    WebviewSDK:OpenURL(FuncUtil.GetDomainByID(3366072) .. "/battlegroundsmobile/3")
  else
    WebviewSDK:OpenURL(FuncUtil.GetDomainByID(3366039) .. "/wanderer_EN.html")
  end
end
function StoreUtils.PlayCardVoice(soundParam, index, widget)
  local ActorVoiceSystem = require("client.slua.logic.actor_voice.logic_actor_voice")
  ActorVoiceSystem.StopSound()
  local StringUtil = require("common.string_util")
  local soundList = StringUtil.Split(soundParam, "|")
  local sound = tonumber(soundList[index])
  ActorVoiceSystem.PlaySound(sound, widget)
end
function StoreUtils.GetQualityNameByNumber(quality)
  local result = ""
  if quality <= 1 then
    result = LocUtil.GetLocalizeResStr(54098)
  elseif quality == 2 then
    result = LocUtil.GetLocalizeResStr(54099)
  elseif quality == 3 then
    result = LocUtil.GetLocalizeResStr(54100)
  elseif quality == 4 then
    result = LocUtil.GetLocalizeResStr(54101)
  elseif quality == 5 then
    result = LocUtil.GetLocalizeResStr(54102)
  elseif quality == 6 then
    result = LocUtil.GetLocalizeResStr(54103)
  elseif quality == 7 then
    result = LocUtil.GetLocalizeResStr(54104)
  elseif 8 <= quality then
    result = LocUtil.GetLocalizeResStr(47065)
  end
  return result
end
function StoreUtils.SetStoreItemInfo(widget, itemData, isTxMission)
  if not itemData then
    return
  end
  local icon, quality
  if itemData.showItem ~= nil then
    icon = itemData.showItem.icon
    quality = itemData.showItem.quality
  else
    icon = itemData.icon
    quality = itemData.quality
  end
  if not icon then
    return
  end
  local util = require("client.slua_ui_framework.util")
  util.SetTexture(widget.Item, icon, {sync = false})
  if isTxMission then
    if quality <= 1 then
      widget.Bg:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      widget.Image_quality:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    else
      widget.Bg:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      widget.Image_quality:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      local xmission_wardrobe_util = require("client.slua.umg.TxMission.xMission.wardrobe.xmission_wardrobe_util")
      xmission_wardrobe_util:SetQuality(nil, widget.Image_quality, quality)
    end
  else
    local UIUtil = require("client.common.ui_util")
    local bigQuality = UIUtil.GetBgQualityPath(quality)
    if bigQuality ~= "" then
      widget.Image_quality:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      util.SetTexture(widget.Image_quality, bigQuality)
      widget.Bg:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    else
      widget.Image_quality:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      widget.Bg:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
  end
  widget.Label:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  widget.Image_25:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if itemData.priceIcon ~= "" then
    widget.WidgetSwitcher_2:SetActiveWidgetIndex(0)
    util.SetTexture(widget.PriceType1, itemData.priceIcon, {sync = false})
    if itemData.originalPrice ~= itemData.finalPrice then
      widget.CanvasPanel_14:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      widget.TextBlock_OriginMoney:SetText(FuncUtil.TransformNumToFormatStr(itemData.originalPrice))
    else
      widget.CanvasPanel_14:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    widget.PriceLabel3:SetText(FuncUtil.TransformNumToFormatStr(itemData.finalPrice))
  else
  end
  if itemData.unlock == false then
    widget.panelLock:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    widget.TextBlock_4:SetText(itemData.unlockTips)
  else
    widget.panelLock:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if itemData.selected == true then
    widget.Common_selected_UIBP:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    widget.Common_selected_UIBP:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if itemData.haveDiscount == true then
    widget.discount:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    widget.TextBlock_1:SetText(itemData.discountText)
  else
    widget.discount:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if 0 < itemData.leftTime then
    widget.leftTimePanel:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    widget.leftTimePanel:SetActiveWidgetIndex(0)
    local result = StoreUtils.ConvertSecondsToTime(itemData.leftTime)
    widget.TimeText:SetText(result)
  else
    widget.leftTimePanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if itemData.specialIcon ~= "" then
    widget.specialIcon:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    util.SetTexture(widget.specialIcon, itemData.specialIcon, {sync = false})
  else
    widget.specialIcon:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if itemData.new == true then
    widget.hotNew:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    widget.Image_5:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    widget.hot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    widget.hotNew:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  widget.Mask:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function StoreUtils.SetCrateItemInfo(widget, itemData)
  local icon, quality
  if itemData.showItem ~= nil then
    icon = itemData.showItem.icon
    quality = itemData.showItem.quality
  else
    icon = itemData.icon
    quality = itemData.quality
  end
  local util = require("client.slua_ui_framework.util")
  util.SetTexture(widget.Item, icon, {sync = false})
  if quality < 1 then
    quality = 1
  end
  if itemData.quality <= 1 then
    widget.Bg:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    widget.Image_quality:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    widget.Bg:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    widget.Image_quality:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    local xmission_wardrobe_util = require("client.slua.umg.TxMission.xMission.wardrobe.xmission_wardrobe_util")
    xmission_wardrobe_util:SetQuality(nil, widget.Image_quality, itemData.quality)
  end
  widget.Label:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if itemData.unlock == false then
    widget.panelLock:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    widget.panelLock:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if itemData.selected == true then
    widget.Common_selected_UIBP:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    widget.Common_selected_UIBP:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if itemData.have == true then
    widget.CanvasPanel_2:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    widget.CanvasPanel_2:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if 1 < itemData.num then
    widget.Count:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    widget.Count:SetText(itemData.num)
  else
    widget.Count:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if itemData.need_checked then
    widget.checked:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    widget.CheckBox_UseStatus:SetCheckedState(itemData.checked and 1 or 0)
  else
    widget.checked:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function StoreUtils.ConvertSecondsToTime(leftTime)
  local hour, min, second
  hour = math.modf(leftTime / 3600)
  leftTime = math.fmod(leftTime, 3600)
  min = math.modf(leftTime / 60)
  second = math.fmod(leftTime, 60)
  local temp = string.format("%.2d:%.2d:%.2d", hour, min, second)
  return temp
end
function StoreUtils.get_color_and_pattern_cost(colorID, patternID)
  local cost = 0
  log(bWriteLog and "get_color_and_pattern_cost  colorID, patternID:  " .. tostring(colorID) .. ",  " .. tostring(patternID))
  if (colorID == nil or colorID == 0) and (patternID == nil or patternID == 0) then
    return cost
  end
  local colorCfg = CDataTable.GetTableData("DiySuitColorConfig", colorID)
  if colorCfg ~= nil then
    cost = cost + colorCfg.Cost
  else
    log(bWriteLog and "colorCfg = nil")
  end
  local patternCfg = CDataTable.GetTableData("DiySuitPatternConfig", patternID)
  if patternCfg ~= nil then
    cost = cost + patternCfg.Cost
  else
    log(bWriteLog and "patternCfg = nil")
  end
  log(bWriteLog and "cost---" .. tostring(cost))
  return cost
end
function StoreUtils.BuyShopItems(shopInfoDict, curVersion, voucher)
  local MallSystem = require("client.logic.mall.logic_mall")
  log_tree("shopInfoDict ", shopInfoDict)
  local tempDict = {}
  local moneyNum = 0
  local money1Num = 0
  local diamondNum = 0
  for i, v in ipairs(shopInfoDict) do
    local shopId = v.id
    local num = v.num
    local itemInfo = v.shopInfo
    if itemInfo ~= nil then
      local priceType, price = StoreUtils.get_money_type_and_price(shopId, 1, itemInfo)
      local colorPatternCost = StoreUtils.get_color_and_pattern_cost(v.colorID, v.patternID)
      if priceType == 2 then
        diamondNum = diamondNum + (price + colorPatternCost) * num
      elseif priceType == 0 then
        moneyNum = moneyNum + (price + colorPatternCost) * num
      elseif priceType == 1 then
        money1Num = money1Num + (price + colorPatternCost) * num
      end
      local info = {
        shopitem_id = itemInfo.id,
        first_money = 1,
        price = (price + colorPatternCost) * num,
        item_id = itemInfo.item_id,
        num = num,
        color = v.colorID,
        pattern = v.patternID,
        source = MallSystem.Buy_Source or 2
      }
      table.insert(tempDict, info)
    end
  end
  if moneyNum > DataMgr.gold then
    ShowNotice(9910227)
    return
  end
  if diamondNum > DataMgr.ticket then
    local CommonPayBoxMgr = require("client.slua.logic.common.Payclass.logic_common_pay_box")
    CommonPayBoxMgr.ShowUcRechargeMsg(diamondNum)
    return
  end
  if money1Num > DataMgr.diamond then
    ShowNotice(4457)
    return
  end
  log_tree("BuyShopItems", tempDict)
  MallSystem.BatchBuyReq(tempDict, curVersion, voucher)
end
function StoreUtils.BuyShopItems2(shopInfoDict, curVersion, voucher)
  local MallSystem = require("client.logic.mall.logic_mall")
  local tempDict = {}
  local moneyNum = 0
  local money1Num = 0
  local diamondNum = 0
  for i, v in ipairs(shopInfoDict) do
    local shopId = v.id
    local num = v.num
    local itemInfo = v.shopInfo
    if itemInfo ~= nil then
      local priceType, price = StoreUtils.get_money_type_and_price(shopId, v.first_money, itemInfo, v.time_valid_index)
      local colorPatternCost = StoreUtils.get_color_and_pattern_cost(v.colorID, v.patternID)
      if priceType == 2 then
        diamondNum = diamondNum + (price + colorPatternCost) * num
      elseif priceType == 0 then
        moneyNum = moneyNum + (price + colorPatternCost) * num
      elseif priceType == 1 then
        money1Num = money1Num + (price + colorPatternCost) * num
      end
      local info = {
        shopitem_id = itemInfo.id,
        first_money = v.first_money,
        time_valid_index = v.time_valid_index,
        price = (price + colorPatternCost) * num,
        item_id = itemInfo.item_id,
        num = num,
        color = v.colorID,
        pattern = v.patternID,
        source = MallSystem.Buy_Source or 2
      }
      table.insert(tempDict, info)
    end
  end
  if moneyNum > DataMgr.gold then
    ShowNotice(9910227)
    return
  end
  if diamondNum > DataMgr.ticket then
    local CommonPayBoxMgr = require("client.slua.logic.common.Payclass.logic_common_pay_box")
    CommonPayBoxMgr.ShowUcRechargeMsg(diamondNum)
    return
  end
  if money1Num > DataMgr.diamond then
    ShowNotice(4457)
    return
  end
  log_tree("BuyShopItems", tempDict)
  MallSystem.BatchBuyReq(tempDict, curVersion, voucher)
end
function StoreUtils.IsCharacterItemID(itemId)
  if itemId == nil or itemId <= 0 then
    return false
  end
  local CharacterUtils = require("GameLua.Mod.Lobby.Base.NewCharacter.logic.Utils.CharacterUtils")
  local characterID = CharacterUtils:GetCharacterIDByItemID(itemId) or 0
  if 0 < characterID then
    return true
  end
  return false
end
function StoreUtils.IsCanSwitchSex(ItemID)
  local isCanSwitch = true
  if ItemID and 0 < ItemID then
    isCanSwitch = not StoreUtils.IsCharacterItemID(ItemID)
  end
  local NewCharacterNetSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.NewCharacterNetSystem)
  local curRoleIsChar = NewCharacterNetSystem:CurRoleIsCharacter()
  local iRet = isCanSwitch and not curRoleIsChar
  return iRet
end
function StoreUtils.IsOpenCouponUse()
  local AccountRegionForBPMacros = require("client.slua.config.ClientMacros.AccountRegionForBPMacros")
  if GlobalData.IsJapanOrKorea() then
    if FuncUtil.GetAccountRegionForBP() == AccountRegionForBPMacros.JP then
      return LobbySystem.CheckOpen(BP_ENUM_COUPON_JAPAN)
    else
      return LobbySystem.CheckOpen(BP_ENUM_COUPON_KOREA)
    end
  else
    return true
  end
end
function StoreUtils.ShowStorePrime()
  local params = {
    bValid = true,
    Tab1 = StoreConst.Page_ID_Prime,
    Tab2 = 0
  }
  local jump_utils = require("client.logic.store.jump_utils")
  jump_utils.OpenJumpModule(BP_ENUM_MODULE_MALL_CHILD, params)
end