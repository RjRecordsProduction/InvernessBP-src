local SubscribeCarnivalSystem = {
  clickEntranceMap = nil,
  hasOpenActivityUI = nil,
  xlsNameCfgList = {
    ActData = "Subscribe_carnival",
    Reward = "daily_reward",
    FirstGive = "subscribe_gift",
    AllGift = "combine_discount",
    BothPriDesc = "Carnival_benefits",
    RecommendPriority = "combine_priority"
  },
  Enum_T_Subscribe = {
    SysPrimePlus = 201,
    SysPrime = 101,
    RpPrimePlus = 2,
    RpPrime = 1
  },
  primeIconList = {
    [101] = "/Game/UMG/Texture/Atlas/Lobby_Store_Int/Frames/Subscription_image_RP_png.Subscription_image_RP_png",
    [201] = "/Game/UMG/Texture/Atlas/Lobby_Store_Int/Frames/Subscription_image_RP_png.Subscription_image_RP_png",
    [1] = "/Game/UMG/Texture/Atlas/Lobby_Store_Int/Frames/Subscription_image_02_png.Subscription_image_02_png",
    [2] = "/Game/UMG/Texture/Atlas/Lobby_Store_Int/Frames/Subscription_image_02_png.Subscription_image_02_png"
  },
  iconRPGray = "/Game/UMG/Texture/Atlas/Lobby_Store_Int/Frames/Subscription_image_RP_2_png.Subscription_image_RP_2_png",
  iconLobbyGray = "/Game/UMG/Texture/Atlas/Lobby_Store_Int/Frames/Subscription_image_Ordinary_1_png.Subscription_image_Ordinary_1_png",
  imageBgNormal = "/Game/UMG/Texture/Lobby_NoAtlas/Store_Int/Store_3/Subscription_image_Pop_02.Subscription_image_Pop_02",
  imageBgGray = "/Game/UMG/Texture/Lobby_NoAtlas/Store_Int/Store_3/Subscription_image_Pop_01.Subscription_image_Pop_01",
  colorContinuous = FSlateColor(FLinearColor(0.913099, 0.913099, 0.913099, 1)),
  colorMouth = FSlateColor(FLinearColor(1, 0.799103, 0.3564, 1)),
  E_Prime_Goods_Type = {
    System_prime = 1,
    RP_Prime = 2,
    Both_Prime = 3
  },
  E_Show_Type = {Lobby_Subscribe = 1, Subscribe_Carnival = 2},
  E_Subscribe_Status = {
    None = 1,
    OnlyPrime = 2,
    Others = 3
  },
  actDataCfg = nil,
  dayAwardCfg = nil,
  primeGiftCfg = nil,
  firstPrimeAwardCfg = nil,
  privilegeDescCfg = nil,
  bothPriDescList = nil,
  priorityCfg = nil,
  userData = nil,
  getDayAwardList = nil,
  purchaseInfoList = nil,
  productIDList = nil,
  productPriceList = nil,
  combineDiscountBuy = nil,
  subscribeGiftStatus = nil,
  maxDiscountBuyNum = 1,
  extraDiscount = 0,
  bpDiscount = 0,
  isOpen = false,
  isBothPrime = false,
  lastClickBuyTime = 0,
  privilegeTypeRPExchange = 3001,
  privilegeTypeBPExchange = 3002,
  redDotTimer = nil,
  tipTimer = nil
}
local CONFLICT_TYPE_LIST = {
  [SubscribeCarnivalSystem.Enum_T_Subscribe.SysPrimePlus] = SubscribeCarnivalSystem.Enum_T_Subscribe.SysPrime,
  [SubscribeCarnivalSystem.Enum_T_Subscribe.SysPrime] = SubscribeCarnivalSystem.Enum_T_Subscribe.SysPrimePlus,
  [SubscribeCarnivalSystem.Enum_T_Subscribe.RpPrimePlus] = SubscribeCarnivalSystem.Enum_T_Subscribe.RpPrime,
  [SubscribeCarnivalSystem.Enum_T_Subscribe.RpPrime] = SubscribeCarnivalSystem.Enum_T_Subscribe.RpPrimePlus
}
local OutputPrimeLog = function()
  local UnknowPassPrimeSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_subscription")
  if UnknowPassPrimeSystem.normalPrimeInfo and UnknowPassPrimeSystem.normalPrimeInfo.UserData then
    local UserData = UnknowPassPrimeSystem.normalPrimeInfo.UserData
    log(bWriteLog and "SubscribeCarnivalSystem.getunknow normalPrimeInfo startTime == " .. tostring(UserData.begin_time) .. "endTime = " .. tostring(UserData.end_time))
  end
  if UnknowPassPrimeSystem.SuperPrimeInfo and UnknowPassPrimeSystem.SuperPrimeInfo.UserData then
    local UserData = UnknowPassPrimeSystem.SuperPrimeInfo.UserData
    log(bWriteLog and "SubscribeCarnivalSystem.getunknow SuperPrimeInfo startTime == " .. tostring(UserData.begin_time) .. "endTime = " .. tostring(UserData.end_time))
  end
  local logic_subscribe_handler = require("client.slua.logic.subscribe.logic_subscribe_handler")
  local subscribeModuleObj = logic_subscribe_handler.GetSubscribeModuleObj()
  local _NormalInfo = subscribeModuleObj:GetNormalInfo()
  local _SuperInfo = subscribeModuleObj:GetSuperInfo()
  if _NormalInfo and _NormalInfo._left_time then
    log(bWriteLog and "SubscribeSystemBase._NormalInfo _left_time = " .. tostring(_NormalInfo._left_time))
  end
  if _SuperInfo and _SuperInfo._left_time then
    log(bWriteLog and "SubscribeSystemBase._SuperInfo _left_time = " .. tostring(_SuperInfo._left_time))
  end
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  log(bWriteLog and "currentTime == " .. tostring(curTime))
end
function SubscribeCarnivalSystem.JumpToMainUI()
  if not SubscribeCarnivalSystem.IsActivityOpen() then
    ShowNotice(4002)
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.ui_subscribe_carnival_main)
end
function SubscribeCarnivalSystem.IsBothPrime()
  if not SubscribeCarnivalSystem.isBothPrime then
    return false
  else
    local logic_subscribe_handler = require("client.slua.logic.subscribe.logic_subscribe_handler")
    local subscribeModuleObj = logic_subscribe_handler.GetSubscribeModuleObj()
    local curSysStatus = subscribeModuleObj:GetNewestSubStatus()
    local UnknowPassPrimeSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_subscription")
    local hasRpSubScribed = UnknowPassPrimeSystem.CheckAlreadySubScribed(1) or UnknowPassPrimeSystem.CheckAlreadySubScribed(2)
    local SubscribeEnumConfig = require("client.slua.logic.subscribe.logic_subscribe_enum_config")
    if curSysStatus >= SubscribeEnumConfig.ENUM_SubStatus.NormalStatus and hasRpSubScribed then
      return true
    else
      OutputPrimeLog()
    end
  end
  return false
end
function SubscribeCarnivalSystem.ReqActivityData()
  local tab_name_list = SubscribeCarnivalSystem.GetCfgNameList()
  local SubscribeCarnivalHandler = require("client.network.Protocol.SubscribeCarnivalHandler")
  SubscribeCarnivalHandler.send_carnival_query_req(nil, tab_name_list)
end
function SubscribeCarnivalSystem.GetCfgNameList()
  local req_list = {}
  if not SubscribeCarnivalSystem.actDataCfg then
    table.insert(req_list, SubscribeCarnivalSystem.xlsNameCfgList.ActData)
  end
  if not SubscribeCarnivalSystem.bothPriDescList then
    table.insert(req_list, SubscribeCarnivalSystem.xlsNameCfgList.BothPriDesc)
  end
  if not SubscribeCarnivalSystem.primeGiftCfg then
    table.insert(req_list, SubscribeCarnivalSystem.xlsNameCfgList.AllGift)
  end
  if not SubscribeCarnivalSystem.firstPrimeAwardCfg then
    table.insert(req_list, SubscribeCarnivalSystem.xlsNameCfgList.FirstGive)
  end
  if not SubscribeCarnivalSystem.priorityCfg then
    table.insert(req_list, SubscribeCarnivalSystem.xlsNameCfgList.RecommendPriority)
  end
  table.insert(req_list, SubscribeCarnivalSystem.xlsNameCfgList.Reward)
  if #req_list <= 0 then
    return nil
  end
  return req_list
end
function SubscribeCarnivalSystem.OnActivityCfgRsp(is_open, is_prime, user_data, cfg)
  log(bWriteLog and "[v_wllwu] SubscribeCarnivalSystem is_open ====" .. tostring(is_open))
  log(bWriteLog and "[v_wllwu] SubscribeCarnivalSystem is_prime ====" .. tostring(is_prime))
  if user_data then
    log_tree("[v_wllwu] SubscribeCarnivalSystem carnival_data ====", user_data)
  end
  if cfg then
    log_tree("[v_wllwu] SubscribeCarnivalSystem cfg ====", cfg)
  end
  SubscribeCarnivalSystem.isOpen = is_open
  if not is_open then
    return
  end
  SubscribeCarnivalSystem.isBothPrime = is_prime
  if user_data then
    if user_data.daily_reward then
      SubscribeCarnivalSystem.getDayAwardList = user_data.daily_reward
    end
    if user_data.subscribe_gift then
      SubscribeCarnivalSystem.subscribeGiftStatus = user_data.subscribe_gift
    end
    if user_data.combine_discount then
      SubscribeCarnivalSystem.combineDiscountBuy = user_data.combine_discount
    end
  end
  if cfg then
    SubscribeCarnivalSystem.HandleCfgData(cfg)
  end
  SubscribeCarnivalSystem.HandleRedDot()
  EventSystem:postEvent(EVENTTYPE_ACTIVITY_SUBSCRIBE_CARNIVAL, EVENTID_SUBSCRIBE_CARNIVAL_REFRESH_ACTIVITYDATA)
end
function SubscribeCarnivalSystem.HandleRedDot()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  if not ActivityNewSystem.IsActivityOpenByBanner(BP_ENUM_MODULE_SUBSCRIBE_CARNIVAL) then
    return
  end
  local show_reddot = false
  if SubscribeCarnivalSystem.getDayAwardList then
    for _, status in pairs(SubscribeCarnivalSystem.getDayAwardList) do
      if status and status == 1 then
        show_reddot = true
        break
      end
    end
  end
  LobbySystem.LobbyRedPointUpdate(BP_ENUM_MODULE_SUBSCRIBE_CARNIVAL, show_reddot)
end
function SubscribeCarnivalSystem.HandleCfgData(info)
  if info[SubscribeCarnivalSystem.xlsNameCfgList.ActData] then
    SubscribeCarnivalSystem.actDataCfg = info[SubscribeCarnivalSystem.xlsNameCfgList.ActData]
  end
  if info[SubscribeCarnivalSystem.xlsNameCfgList.BothPriDesc] then
    local list = info[SubscribeCarnivalSystem.xlsNameCfgList.BothPriDesc]
    SubscribeCarnivalSystem.bothPriDescList = list
    for k, v in pairs(list) do
      if k == SubscribeCarnivalSystem.privilegeTypeRPExchange then
        SubscribeCarnivalSystem.extraDiscount = v.privilege_num
      elseif k == SubscribeCarnivalSystem.privilegeTypeBPExchange then
        SubscribeCarnivalSystem.bpDiscount = v.privilege_num
      end
    end
  end
  if info[SubscribeCarnivalSystem.xlsNameCfgList.AllGift] then
    local list = info[SubscribeCarnivalSystem.xlsNameCfgList.AllGift]
    if not SubscribeCarnivalSystem.primeGiftCfg then
      SubscribeCarnivalSystem.primeGiftCfg = {}
    end
    SubscribeCarnivalSystem.productIDList = {}
    for k, v in pairs(list) do
      local prime_info = {
        combine_id = k,
        combine_1 = v.combine_1,
        purchase_time1 = v.purchase_time1,
        combine_2 = v.combine_2,
        purchase_time2 = v.purchase_time2,
        prime_type_id = v.prime_type_id,
        prime_old_type_id = v.prime_old_type_id,
        old_price = v.old_price,
        sale_price = v.sale_price,
        sale = v.sale,
        sale_tag = v.sale_tag,
        good_type = SubscribeCarnivalSystem.E_Prime_Goods_Type.Both_Prime
      }
      table.insert(SubscribeCarnivalSystem.primeGiftCfg, prime_info)
      if v.prime_type_id then
        table.insert(SubscribeCarnivalSystem.productIDList, v.prime_type_id)
      end
      if v.prime_old_type_id then
        table.insert(SubscribeCarnivalSystem.productIDList, v.prime_old_type_id)
      end
    end
  end
  if info[SubscribeCarnivalSystem.xlsNameCfgList.Reward] then
    SubscribeCarnivalSystem.dayAwardCfg = info[SubscribeCarnivalSystem.xlsNameCfgList.Reward] or {}
  end
  if info[SubscribeCarnivalSystem.xlsNameCfgList.FirstGive] then
    SubscribeCarnivalSystem.firstPrimeAwardCfg = info[SubscribeCarnivalSystem.xlsNameCfgList.FirstGive] or {}
  end
  if info[SubscribeCarnivalSystem.xlsNameCfgList.RecommendPriority] then
    SubscribeCarnivalSystem.priorityCfg = info[SubscribeCarnivalSystem.xlsNameCfgList.RecommendPriority]
  end
end
function SubscribeCarnivalSystem.GetPrivilegeCfg()
  if not SubscribeCarnivalSystem.privilegeDescCfg then
    local cfg = CDataTable.GetTable("SubscibeDescription")
    SubscribeCarnivalSystem.SetPrivilegeList(cfg)
  end
  return SubscribeCarnivalSystem.privilegeDescCfg
end
local GetPrivilegeList = function(info)
  local list = {}
  if info then
    local index = 1
    local str_name = "privilege_description_"
    local icon_name = "privilege_icon_"
    while info[str_name .. index] and info[icon_name .. index] ~= "" do
      local desc_info = {
        desc_key = info[str_name .. index],
        icon_url = info[icon_name .. index]
      }
      table.insert(list, desc_info)
      index = index + 1
    end
  end
  return list
end
function SubscribeCarnivalSystem.SetPrivilegeList(info)
  if not info then
    return
  end
  if not SubscribeCarnivalSystem.privilegeDescCfg then
    SubscribeCarnivalSystem.privilegeDescCfg = {}
  end
  for k, v in pairs(info) do
    SubscribeCarnivalSystem.privilegeDescCfg[v.prime_type] = {
      key_name_id = v.name,
      privilege_list = GetPrivilegeList(v)
    }
  end
end
function SubscribeCarnivalSystem.ReqGetDayAward(day_num)
  local SubscribeCarnivalHandler = require("client.network.Protocol.SubscribeCarnivalHandler")
  SubscribeCarnivalHandler.send_take_daily_reward(day_num)
end
function SubscribeCarnivalSystem.OnGetAwardRsp(err_code, day_num)
  if err_code == 1 then
    if not SubscribeCarnivalSystem.getDayAwardList then
      SubscribeCarnivalSystem.getDayAwardList = {}
    end
    SubscribeCarnivalSystem.getDayAwardList[day_num] = 2
    SubscribeCarnivalSystem.HandleRedDot()
    EventSystem:postEvent(EVENTTYPE_ACTIVITY_SUBSCRIBE_CARNIVAL, EVENTID_SUBSCRIBE_CARNIVAL_GET_DAY_AWARD, day_num)
  else
    ShowNotice(err_code)
  end
end
function SubscribeCarnivalSystem.SortGiftList(list)
  if not (SubscribeCarnivalSystem.combineDiscountBuy and list) or #list <= 1 then
    return list
  end
  table.sort(list, function(a, b)
    local buy_num1 = SubscribeCarnivalSystem.combineDiscountBuy[a.combine_id] or 0
    local buy_num2 = SubscribeCarnivalSystem.combineDiscountBuy[b.combine_id] or 0
    if buy_num1 == buy_num2 then
      return a.combine_id < b.combine_id
    else
      return buy_num1 < buy_num2
    end
  end)
  return list
end
function SubscribeCarnivalSystem.GetDiscountListByType(type)
  local show_list = SubscribeCarnivalSystem.GetSiftList()
  if not type then
    return show_list
  end
  if show_list and next(show_list) then
    local list = {}
    for k, v in pairs(show_list) do
      if v then
        local prime_type1 = v.combine_1
        local prime_type2 = v.combine_2
        local confilict_type = CONFLICT_TYPE_LIST[type] or -999
        if prime_type1 == type and prime_type2 ~= confilict_type or prime_type2 == type and prime_type1 ~= confilict_type then
          table.insert(list, v)
        end
      end
    end
    return SubscribeCarnivalSystem.SortGiftList(list)
  end
  return nil
end
function SubscribeCarnivalSystem.GetSiftList()
  local siftList = {}
  if SubscribeCarnivalSystem.primeGiftCfg and next(SubscribeCarnivalSystem.primeGiftCfg) then
    for k, v in pairs(SubscribeCarnivalSystem.primeGiftCfg) do
      if v.prime_type_id or v.prime_old_type_id then
        if v.prime_type_id then
          table.insert(siftList, v)
        elseif SubscribeCarnivalSystem.IsShowDiscountPrice(v.combine_id) then
          table.insert(siftList, v)
        end
      end
    end
  end
  return siftList
end
function SubscribeCarnivalSystem.IsShowDiscountPrice(combine_id)
  if combine_id and SubscribeCarnivalSystem.combineDiscountBuy then
    local buy_num = SubscribeCarnivalSystem.combineDiscountBuy[combine_id]
    if buy_num == nil or buy_num < SubscribeCarnivalSystem.maxDiscountBuyNum then
      return true
    end
  end
  return false
end
function SubscribeCarnivalSystem.SetReqPurchaseInfoList()
  if SubscribeCarnivalSystem.productIDList and next(SubscribeCarnivalSystem.productIDList) then
    local req_id_list = {}
    local save_list = {}
    for k, v in pairs(SubscribeCarnivalSystem.productIDList) do
      local product_id = v
      if (not SubscribeCarnivalSystem.purchaseInfoList or not SubscribeCarnivalSystem.purchaseInfoList[product_id]) and not save_list[product_id] then
        save_list[product_id] = true
        table.insert(req_id_list, product_id)
      end
    end
    if 1 <= #req_id_list then
      local RechargePurchaseSystem = require("client.logic.recharge.logic_recharge_purchase")
      RechargePurchaseSystem.GetPurchaseInfoReq(req_id_list)
    end
  end
end
function SubscribeCarnivalSystem.SavePurchaseInfo(list, dontLoadPrice)
  if not list or not SubscribeCarnivalSystem.productIDList then
    return
  end
  if not SubscribeCarnivalSystem.purchaseInfoList then
    SubscribeCarnivalSystem.purchaseInfoList = {}
  end
  for k, v in pairs(list) do
    for _, j in pairs(SubscribeCarnivalSystem.productIDList) do
      if k == j then
        local purchase_info = {}
        purchase_info.CentauriProductId = v.productid
        purchase_info.CentauriCountry = v.country
        purchase_info.CentauriCurrency = v.curency_unit
        purchase_info.CentauriPrice = v.CentauriPrice
        purchase_info.CentauriPayItem = v.payItem
        SubscribeCarnivalSystem.purchaseInfoList[k] = purchase_info
      end
    end
  end
  if not dontLoadPrice then
    SubscribeCarnivalSystem.LoadPrice()
  end
end
function SubscribeCarnivalSystem.GetRecommendGiftID()
  local subscribe_type = -1
  local logic_subscribe_handler = require("client.slua.logic.subscribe.logic_subscribe_handler")
  local subscribeModuleObj = logic_subscribe_handler.GetSubscribeModuleObj()
  local curSysStatus = subscribeModuleObj:GetSubStatus()
  local UnknowPassPrimeSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_subscription")
  local hasRpSubScribed = UnknowPassPrimeSystem.CheckAlreadySubScribed(1) or UnknowPassPrimeSystem.CheckAlreadySubScribed(2)
  local SubscribeEnumConfig = require("client.slua.logic.subscribe.logic_subscribe_enum_config")
  local ENUM_SubStatus = SubscribeEnumConfig.ENUM_SubStatus
  if curSysStatus < ENUM_SubStatus.NormalStatus and not hasRpSubScribed then
    subscribe_type = SubscribeCarnivalSystem.E_Subscribe_Status.None
  elseif curSysStatus == ENUM_SubStatus.NormalStatus and not hasRpSubScribed then
    subscribe_type = SubscribeCarnivalSystem.E_Subscribe_Status.OnlyPrime
  else
    subscribe_type = SubscribeCarnivalSystem.E_Subscribe_Status.Others
  end
  if SubscribeCarnivalSystem.priorityCfg then
    return SubscribeCarnivalSystem.priorityCfg[subscribe_type]
  end
  return nil
end
function SubscribeCarnivalSystem.GetPriviligeNamgeByType(p_type)
  local cfg = SubscribeCarnivalSystem.GetPrivilegeCfg()
  if p_type and cfg and cfg[p_type] then
    return LocUtil.GetLocalizeResStr(cfg[p_type].key_name_id)
  end
  return ""
end
function SubscribeCarnivalSystem.SetItemInfo(widget, item_data, dont_show_reward)
  if not item_data then
    return
  end
  if item_data.purchase_time1 and item_data.purchase_time2 and item_data.purchase_time1 == item_data.purchase_time2 then
    local month = math.ceil(item_data.purchase_time1 / 31)
    widget.TextBlock_mouth:SetText(LocUtil.LocalizeResFormat(10405, month))
  end
  local prime_type1 = item_data.combine_1
  local prime_type2 = item_data.combine_2
  local product_id = item_data.prime_old_type_id
  local table_discount_price = item_data.sale_price
  local table_original_price = item_data.old_price
  local original_product_id = item_data.prime_type_id
  local util = require("client.slua_ui_framework.util")
  local name_1 = SubscribeCarnivalSystem.GetPriviligeNamgeByType(prime_type1)
  util.SetTexture(widget.Image_icon1, SubscribeCarnivalSystem.primeIconList[prime_type1] or "")
  widget.UTRichTextBlock_1:SetText(name_1)
  local name_2 = SubscribeCarnivalSystem.GetPriviligeNamgeByType(prime_type2)
  util.SetTexture(widget.Image_icon2, SubscribeCarnivalSystem.primeIconList[prime_type2] or "")
  widget.UTRichTextBlock_2:SetText(name_2)
  local price = SubscribeCarnivalSystem.GetProductPriceById(original_product_id)
  if item_data.sale and item_data.sale > 0 and SubscribeCarnivalSystem.IsShowDiscountPrice(item_data.combine_id) then
    if price then
      widget.TextBlock_oldprice:SetText(price)
    else
      widget.TextBlock_oldprice:SetText(table_original_price or "")
    end
    local dist_price = SubscribeCarnivalSystem.GetProductPriceById(product_id)
    if dist_price then
      widget.TextBlock_price:SetText(dist_price)
    else
      widget.TextBlock_price:SetText(table_discount_price or "")
    end
    widget.TextBlock_discount:SetText(LocUtil.LocalizeResFormat(12496, item_data.sale))
    widget.CanvasPanel_oldprice:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    widget.CanvasPanel_discount:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    if price then
      widget.TextBlock_price:SetText(price)
    else
      widget.TextBlock_price:SetText(table_original_price or "")
    end
    widget.CanvasPanel_oldprice:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    widget.CanvasPanel_discount:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  widget.Image_add:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  widget.Image_icon2:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  widget.UTRichTextBlock_2:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  if not dont_show_reward then
    widget.TextBlock_0:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    util.SetTexture(widget.Image_bg, SubscribeCarnivalSystem.imageBgNormal)
    widget.TextBlock_price:SetColorAndOpacity(SubscribeCarnivalSystem.colorMouth)
    SubscribeCarnivalSystem.ShowFirstAward(widget, prime_type1, prime_type2)
  end
end
function SubscribeCarnivalSystem.ShowFirstAward(widget, prime_type1, prime_type2)
  widget.CanvasPanel_award:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  widget.CanvasPanel_reward1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  widget.CanvasPanel_reward2:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if not SubscribeCarnivalSystem.firstPrimeAwardCfg then
    return
  end
  if SubscribeCarnivalSystem.subscribeGiftStatus then
    local item_id1 = 0
    local item_num1 = 0
    if not SubscribeCarnivalSystem.subscribeGiftStatus[prime_type1] or SubscribeCarnivalSystem.subscribeGiftStatus[prime_type1] <= 0 then
      local item_info = SubscribeCarnivalSystem.firstPrimeAwardCfg[prime_type1]
      if item_info then
        local item_cfg = CDataTable.GetTableData("Item", item_info.item_id)
        if item_cfg then
          item_id1 = item_info.item_id
          item_num1 = item_info.item_num
          local util = require("client.slua_ui_framework.util")
          util.SetTexture(widget.Image_award, item_cfg.ItemSmallIcon, {sync = false})
          widget.TextBlock_num:SetText("x" .. tostring(item_info.item_num))
          local UIUtil = require("client.common.ui_util")
          local bigQuality = UIUtil.GetBgQualityPath(item_cfg.ItemQuality or 0)
          if bigQuality ~= "" then
            widget.Image_Quality1:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            util.SetTexture(widget.Image_Quality1, bigQuality)
          else
            widget.Image_Quality1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
          end
          widget.CanvasPanel_award:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
          widget.CanvasPanel_reward1:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        end
      end
    end
    if prime_type2 and (not SubscribeCarnivalSystem.subscribeGiftStatus[prime_type2] or SubscribeCarnivalSystem.subscribeGiftStatus[prime_type2] <= 0) then
      local item_info = SubscribeCarnivalSystem.firstPrimeAwardCfg[prime_type2]
      if item_info then
        if item_info.item_id == item_id1 then
          item_num1 = item_num1 + item_info.item_num
          widget.TextBlock_num:SetText("x" .. tostring(item_num1))
        else
          local item_cfg = CDataTable.GetTableData("Item", item_info.item_id)
          if item_cfg then
            local util = require("client.slua_ui_framework.util")
            util.SetTexture(widget.Image_award2, item_cfg.ItemSmallIcon)
            widget.TextBlock_num2:SetText("x" .. tostring(item_info.item_num))
            local UIUtil = require("client.common.ui_util")
            local bigQuality = UIUtil.GetBgQualityPath(item_cfg.ItemQuality or 0)
            if bigQuality ~= "" then
              widget.Image_Quality2:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
              util.SetTexture(widget.Image_Quality2, bigQuality, {sync = false})
            else
              widget.Image_Quality2:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
            end
            widget.CanvasPanel_award:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            widget.CanvasPanel_reward2:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
          end
        end
      end
    end
  end
end
function SubscribeCarnivalSystem.JumpToRpPrime()
  GlobalData.JumpUrl("game://?module=" .. BP_ENUM_MODULE_PRIME_UNKNOW_PASS)
end
function SubscribeCarnivalSystem.JumpToSysPrime()
  GlobalData.JumpUrl("game://?module=" .. BP_ENUM_MODULE_PRIME)
end
function SubscribeCarnivalSystem.JumpToMall()
  local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
  store_supply_manager:ShowStorePrime()
end
function SubscribeCarnivalSystem.JumpToRPExchange()
  local jumpInfo = {}
  jumpInfo.Tab1 = 2
  local UnknowPassTunnelSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknowpass_tunnel")
  UnknowPassTunnelSystem.ShowRP(jumpInfo)
end
function SubscribeCarnivalSystem.CloseMainUI()
  local ui_subscribe_carnival_main = UIManager.GetUI(UIManager.UI_Config.ui_subscribe_carnival_main)
  if ui_subscribe_carnival_main and ui_subscribe_carnival_main:IsShow() then
    UIManager.CloseUI(UIManager.UI_Config.ui_subscribe_carnival_main)
  end
end
function SubscribeCarnivalSystem.GetCacheInfo()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cacheInfo = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSubscribeCarnival)
  if cacheInfo and cacheInfo.clickEntranceMap then
    SubscribeCarnivalSystem.clickEntranceMap = cacheInfo.clickEntranceMap
  else
    SubscribeCarnivalSystem.clickEntranceMap = {}
  end
  if cacheInfo and cacheInfo.hasOpenActivityUI then
    SubscribeCarnivalSystem.hasOpenActivityUI = true
  else
    SubscribeCarnivalSystem.hasOpenActivityUI = false
  end
end
function SubscribeCarnivalSystem.SaveCacheInfo()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local data = {}
  data.clickEntranceMap = SubscribeCarnivalSystem.clickEntranceMap
  data.hasOpenActivityUI = SubscribeCarnivalSystem.hasOpenActivityUI
  PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.eSubscribeCarnival)
end
function SubscribeCarnivalSystem.GetHasClickBtnEnter(from_type)
  if not SubscribeCarnivalSystem.IsActivityOpen() then
    return true
  end
  if SubscribeCarnivalSystem.clickEntranceMap == nil then
    SubscribeCarnivalSystem.GetCacheInfo()
  end
  return SubscribeCarnivalSystem.clickEntranceMap[tostring(from_type)]
end
function SubscribeCarnivalSystem.SetHasClickBtnEnter(from_type)
  if SubscribeCarnivalSystem.clickEntranceMap and SubscribeCarnivalSystem.clickEntranceMap[tostring(from_type)] then
    return
  end
  if not SubscribeCarnivalSystem.clickEntranceMap then
    SubscribeCarnivalSystem.clickEntranceMap = {}
  end
  SubscribeCarnivalSystem.clickEntranceMap[tostring(from_type)] = true
  SubscribeCarnivalSystem.SaveCacheInfo()
end
function SubscribeCarnivalSystem.GetHasOpenAct()
  if SubscribeCarnivalSystem.hasOpenActivityUI == nil then
    SubscribeCarnivalSystem.GetCacheInfo()
  end
  return SubscribeCarnivalSystem.hasOpenActivityUI
end
function SubscribeCarnivalSystem.SetHasOpenAct()
  if SubscribeCarnivalSystem.hasOpenActivityUI then
    return
  end
  SubscribeCarnivalSystem.hasOpenActivityUI = true
  SubscribeCarnivalSystem.SaveCacheInfo()
end
function SubscribeCarnivalSystem.GetProductPriceById(purchase_id)
  if purchase_id and SubscribeCarnivalSystem.productPriceList and SubscribeCarnivalSystem.purchaseInfoList and SubscribeCarnivalSystem.purchaseInfoList[purchase_id] then
    local product = SubscribeCarnivalSystem.purchaseInfoList[purchase_id]
    if SubscribeCarnivalSystem.productPriceList[product.CentauriProductId] then
      local price = SubscribeCarnivalSystem.productPriceList[product.CentauriProductId]
      return price
    end
  end
  return nil
end
function SubscribeCarnivalSystem.LoadPrice()
  local productStr = SubscribeCarnivalSystem.MakeProductIdStr()
  if productStr and productStr ~= "" then
    local isProductInfoCached, cachedProductInfoList = CentauriManager.LoadCachedCentauriProductInfo(productStr)
    if isProductInfoCached then
      log_tree("SubscribeCarnivalSystem.LoadPrice  cachedProductInfoList2", cachedProductInfoList)
      SubscribeCarnivalSystem.GetCentauriGoodsInfo(nil, nil, cachedProductInfoList)
    else
      log(bWriteLog and "LoadCentauriProductIntroInfo2 " .. productStr)
      local logic_payment_api = require("client.logic.pay.logic_payment_api")
      logic_payment_api:load_Centauri_product_info(productStr)
    end
  end
end
function SubscribeCarnivalSystem.MakeProductIdStr()
  local productStr = ""
  if SubscribeCarnivalSystem.purchaseInfoList and next(SubscribeCarnivalSystem.purchaseInfoList) then
    for k, v in pairs(SubscribeCarnivalSystem.purchaseInfoList) do
      if productStr == "" then
        productStr = v.CentauriProductId
      else
        productStr = productStr .. "," .. v.CentauriProductId
      end
    end
  end
  return productStr
end
function SubscribeCarnivalSystem.GetCentauriGoodsInfo(evenType, eventID, resultTable)
  if resultTable == nil then
    log(bWriteLog and "GetCentauriIntroInfo\232\175\187\229\143\150\230\149\176\230\141\174\229\164\177\232\180\165")
    logic_connection_waiting:Hide(1)
    return
  end
  log_tree("SubscribeCarnivalSystem.GetCentauriIntroInfo resultTable", resultTable)
  if not next(resultTable) then
    log_error("no SubscribeCarnivalSystem GetCentauriGoodsInfo")
    return
  end
  local str = ""
  for i, v in pairs(resultTable) do
    if v.productId then
      if str == "" then
        str = str .. v.productId
      else
        str = str .. "," .. v.productId
      end
    end
  end
  log(bWriteLog and "SubscribeCarnivalSystem SYR_GetCentauriGoodsInfo " .. str)
  if str ~= SubscribeCarnivalSystem.MakeProductIdStr() then
    log_error("no SubscribeCarnivalSystem Centauri SYR_GetCentauriGoodsInfo")
    return
  end
  if not SubscribeCarnivalSystem.productPriceList then
    SubscribeCarnivalSystem.productPriceList = {}
  end
  for k, product in pairs(resultTable) do
    if product.productId ~= nil and product.price ~= nil then
      log(bWriteLog and "product.price " .. product.price)
      SubscribeCarnivalSystem.productPriceList[product.productId] = product.price
    else
      log(bWriteLog and "GetCentauriGoodsInfo \230\139\137\229\143\150\230\149\176\230\141\174\229\164\177\232\180\165")
      logic_connection_waiting:Hide(1)
    end
  end
  EventSystem:postEvent(EVENTTYPE_ACTIVITY_SUBSCRIBE_CARNIVAL, EVENTID_SUBSCRIBE_CARNIVAL_SUBSCRIPTION_PRICEINFO)
  logic_connection_waiting:Hide(1)
end
function SubscribeCarnivalSystem.GetCentauriGoodsInfoFromCache(evenType, eventID, resultCode)
  log(bWriteLog and "SubscribeCarnivalSystem.GetCentauriGoodsInfoFromCache " .. tostring(resultCode))
  if resultCode then
    local productid_str = SubscribeCarnivalSystem.MakeProductIdStr()
    local isProductInfoCached, cachedProductInfoList = CentauriManager.LoadCachedCentauriProductInfo(productid_str)
    if isProductInfoCached then
      log_tree("SubscribeCarnivalSystem.GetCentauriIntroInfoFromCache", cachedProductInfoList)
      SubscribeCarnivalSystem.GetCentauriGoodsInfo(evenType, eventID, cachedProductInfoList)
    else
      log(bWriteLog and "no reason to go here if go here find alex")
    end
  end
  logic_connection_waiting:Hide(1)
end
function SubscribeCarnivalSystem.ClickSubscribe(combine_id)
  log(bWriteLog and "SubscribeCarnivalSystem.ClickSubscribe" .. tostring(combine_id))
  if not SubscribeCarnivalSystem.IsActivityOpen() then
    ShowNotice(4002)
    return
  end
  local prime_info = SubscribeCarnivalSystem.primeGiftCfg[combine_id]
  if prime_info == nil then
    log_error("[v_wllwu] SubscribeCarnivalSystem:ClickSubscribe prime_info nil nil nil ")
    return
  end
  local purchase_id = ""
  if SubscribeCarnivalSystem.IsShowDiscountPrice(combine_id) then
    purchase_id = prime_info.prime_old_type_id
  else
    purchase_id = prime_info.prime_type_id
  end
  log(bWriteLog and "[v_wllwu] SubscribeCarnivalSystem.ClickSubscribe purchase_id === " .. tostring(purchase_id))
  if purchase_id ~= "" then
    local TimeUtil = require("client.common.time_util")
    local curTime = TimeUtil.GetServerTimeInSec()
    log(bWriteLog and "[v_wllwu] SubscribeCarnivalSystem.ClickSubscribe curTime = " .. tostring(curTime) .. "lastClickBuyTime = " .. tostring(SubscribeCarnivalSystem.lastClickBuyTime))
    if curTime - SubscribeCarnivalSystem.lastClickBuyTime <= 2 then
      return
    end
    SubscribeCarnivalSystem.lastClickBuyTime = curTime
    local info = SubscribeCarnivalSystem.GetCentauriBuyInfo(purchase_id)
    if info then
      local store_direct_purchase_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_direct_purchase_manager)
      store_direct_purchase_manager:SetDirectPurchaseInfo(info)
      local SubscribeCarnivalHandler = require("client.network.Protocol.SubscribeCarnivalHandler")
      SubscribeCarnivalHandler.send_prime_direct_buy(purchase_id, combine_id)
    end
  end
end
function SubscribeCarnivalSystem.OnSubscribeRsp(str)
  log(bWriteLog and "SubscribeCarnivalSystem.OnSubscribeRsp = " .. tostring(str))
  if str == NetErrorCode_NONE then
    ShowNotice(6493)
  else
    ShowNotice(7690)
  end
end
function SubscribeCarnivalSystem.OnAwardNotify(type)
  log(bWriteLog and "SubscribeCarnivalSystem.OnAwardNotify")
  SubscribeCarnivalSystem.RemoveTipsTimer()
  local time_ticker = require("common.time_ticker")
  SubscribeCarnivalSystem.tipTimer = time_ticker.AddTimerOnce(2.5, function()
    ShowNotice(7240)
  end)
end
function SubscribeCarnivalSystem.RemoveTipsTimer()
  if SubscribeCarnivalSystem.tipTimer then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(SubscribeCarnivalSystem.tipTimer)
  end
end
function SubscribeCarnivalSystem.GetCentauriBuyInfo(purchase_id)
  if not SubscribeCarnivalSystem.purchaseInfoList then
    log_error("[v_wllwu] SubscribeCarnivalSystem:ClickSubscribe purchaseInfoList is nil!")
    return
  end
  if purchase_id == nil then
    log_error("[v_wllwu] SubscribeCarnivalSystem:ClickSubscribe purchase_id is nil!")
    return
  end
  local purchaseInfo = SubscribeCarnivalSystem.purchaseInfoList[purchase_id]
  if purchaseInfo == nil then
    log_error("[v_wllwu] SubscribeCarnivalSystem:ClickSubscribe info is nil!")
    return
  end
  log(bWriteLog and "Client.CentauriGoods" .. "item_id\239\188\154" .. tostring(purchase_id) .. " CentauriProductId: " .. purchaseInfo.CentauriProductId .. " CentauriPayItem: " .. purchaseInfo.CentauriPayItem .. " CentauriPrice: " .. purchaseInfo.CentauriPrice .. " CentauriCountry: " .. purchaseInfo.CentauriCountry .. " CentauriCurrency: " .. purchaseInfo.CentauriCurrency)
  local info = {}
  info.item_id = purchase_id
  info.CentauriProductId = purchaseInfo.CentauriProductId
  info.CentauriPayItem = purchaseInfo.CentauriPayItem
  info.CentauriPrice = purchaseInfo.CentauriPrice
  info.CentauriCountry = purchaseInfo.CentauriCountry
  info.CentauriCurrency = purchaseInfo.CentauriCurrency
  return info
end
function SubscribeCarnivalSystem.OnLogin()
  local tab_name_list = {
    "Subscribe_carnival",
    "daily_reward"
  }
  if not SubscribeCarnivalSystem.bothPriDescList then
    table.insert(tab_name_list, SubscribeCarnivalSystem.xlsNameCfgList.BothPriDesc)
  end
  local SubscribeCarnivalHandler = require("client.network.Protocol.SubscribeCarnivalHandler")
  SubscribeCarnivalHandler.send_carnival_query_req(nil, tab_name_list)
  local time_ticker = require("common.time_ticker")
  SubscribeCarnivalSystem.redDotTimer = time_ticker.AddTimerOnce(3, function()
    SubscribeCarnivalSystem.HandleRedDot()
  end)
end
function SubscribeCarnivalSystem.GetDetailInfo()
  local tab_name_list = {}
  if not SubscribeCarnivalSystem.primeGiftCfg then
    table.insert(tab_name_list, SubscribeCarnivalSystem.xlsNameCfgList.AllGift)
  end
  if not SubscribeCarnivalSystem.firstPrimeAwardCfg then
    table.insert(tab_name_list, SubscribeCarnivalSystem.xlsNameCfgList.FirstGive)
  end
  if 0 < #tab_name_list then
    local SubscribeCarnivalHandler = require("client.network.Protocol.SubscribeCarnivalHandler")
    SubscribeCarnivalHandler.send_carnival_query_req(nil, tab_name_list)
  end
end
function SubscribeCarnivalSystem.CreateDisountItem(parentUI, parentName, click_func)
  local path = "/Game/UMG/UI_BP/NewStore/item/Subscription_DiscountItem_UIBP.Subscription_DiscountItem_UIBP"
  local child = parentUI:CreateChildWindowWithBpPath(parentName, nil, path)
  local discount = SubscribeCarnivalSystem.GetBPExchangeDiscount()
  if discount and 0 < discount then
    discount = math.floor(discount * 100)
    child.UIRoot.TextBlock_0:SetText(LocUtil.LocalizeResFormat(12496, discount))
    child.UIRoot.CanvasPanel_discount:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    child.UIRoot.CanvasPanel_discount:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if SubscribeCarnivalSystem.IsBothPrime() then
    child.UIRoot.UTRichTextBlock_1:SetText(LocUtil.GetLocalizeResStr(12904))
  else
    child.UIRoot.UTRichTextBlock_1:SetText(LocUtil.GetLocalizeResStr(12902))
  end
  if click_func then
    child:AddControlEventByControl(child.UIRoot.Button_0, "OnClicked", function()
      click_func()
    end)
  end
  return child
end
function SubscribeCarnivalSystem.IsActivityOpen()
  if not LobbySystem.CheckOpen(BP_ENUM_SUBSCRIBE_CARNIVAL_ID) then
    return false
  end
  if GlobalData.IsJapanOrKorea() then
    return false
  end
  local strPlatform = Client.GetDevicePlatformName()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if strPlatform == DevicePlatformNameMacros.IOS then
    return false
  end
  if SubscribeCarnivalSystem.actDataCfg and SubscribeCarnivalSystem.actDataCfg.start_time_ts and SubscribeCarnivalSystem.actDataCfg.end_time_ts then
    local start_time = SubscribeCarnivalSystem.actDataCfg.start_time_ts
    local end_time = SubscribeCarnivalSystem.actDataCfg.end_time_ts
    local TimeUtil = require("client.common.time_util")
    local now_time = TimeUtil.GetServerTimeInSec()
    if start_time > now_time or end_time <= now_time then
      return false
    end
  end
  return SubscribeCarnivalSystem.isOpen
end
function SubscribeCarnivalSystem.GetRPPrimeDiscount()
  if SubscribeCarnivalSystem.IsActivityOpen() and SubscribeCarnivalSystem.extraDiscount and SubscribeCarnivalSystem.extraDiscount > 0 then
    return SubscribeCarnivalSystem.extraDiscount * 0.01
  end
  return 0
end
function SubscribeCarnivalSystem.GetBPExchangeDiscount()
  if SubscribeCarnivalSystem.IsActivityOpen() and SubscribeCarnivalSystem.bpDiscount and SubscribeCarnivalSystem.bpDiscount > 0 then
    return SubscribeCarnivalSystem.bpDiscount * 0.01
  end
  return 0
end
function SubscribeCarnivalSystem.ShowCarnivalSlap(from_type)
  if not from_type or not SubscribeCarnivalSystem.CheckIsShowSlap(from_type) then
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.ui_subscribe_carnival_slap, from_type)
  SubscribeCarnivalSystem.SetHasClickBtnEnter(from_type)
end
function SubscribeCarnivalSystem.CheckIsShowSlap(from_type)
  if from_type and SubscribeCarnivalSystem.IsActivityOpen() and not SubscribeCarnivalSystem.GetHasClickBtnEnter(tostring(from_type)) then
    return true
  end
  return false
end
function SubscribeCarnivalSystem.EnterSubscribeDetailUI(is_normal)
  UIManager.ShowUI(UIManager.UI_Config.ui_subscribe_carnival_detail, SubscribeCarnivalSystem.E_Show_Type.Lobby_Subscribe, is_normal)
end
function SubscribeCarnivalSystem.ClearData()
  SubscribeCarnivalSystem.lastClickBuyTime = 0
end
function SubscribeCarnivalSystem.ResetData()
  SubscribeCarnivalSystem.clickEntranceMap = nil
  SubscribeCarnivalSystem.hasOpenActivityUI = nil
  SubscribeCarnivalSystem.isOpen = false
  SubscribeCarnivalSystem.isBothPrime = nil
  SubscribeCarnivalSystem.lastClickBuyTime = 0
  SubscribeCarnivalSystem.RemoveTipsTimer()
  if SubscribeCarnivalSystem.redDotTimer then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(SubscribeCarnivalSystem.redDotTimer)
  end
end
return SubscribeCarnivalSystem