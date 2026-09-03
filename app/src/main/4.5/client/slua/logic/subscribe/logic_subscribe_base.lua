local SubscribeSystemBase = {}
local SubscribeEnumConfig = require("client.slua.logic.subscribe.logic_subscribe_enum_config")
function SubscribeSystemBase:DefineAndResetData()
  self._ActivityData = {}
  self._CouponData = {}
  self._Centauri_table_data = {}
  self._Centauri_act_table_data = {}
  self._NormalInfo = {
    _is_Open = false,
    _SubscribeID = "",
    _IsCouldGetFirstAward = false,
    _Is_Could_Take_Award = false,
    _show_price = "",
    _first_month_price = "",
    _tablePrice = "",
    _award_UC_Num = 0,
    _left_time = 0,
    _Centauri_end_time = 0,
    _Centauri_start_time = 0,
    _start_time = 0,
    _InfoList = {
      InfoID = {Describe = "", num = 0}
    },
    _EveryDayGetTimes = 0
  }
  self._SuperInfo = {
    _is_Open = false,
    _SubscribeID = "",
    _IsCouldGetFirstAward = false,
    _show_price = "",
    _first_month_price = "",
    _first_motnth_tableprice = "",
    _tablePrice = "",
    _left_time = 0,
    _Centauri_end_time = 0,
    _Centauri_start_time = 0,
    _start_time = 0,
    _award_UC_Num = 0,
    _Is_Could_Take_Award = false,
    _uniq_id = 0,
    _is_first_time_buy = false,
    _redpoint = false,
    _InfoList = {
      InfoID = {Describe = "", num = 0}
    },
    _DropAwardList = {},
    _EveryDayGetTimes = 0
  }
end
function SubscribeSystemBase:OnInitialize()
  SubscribeSystemBase.__super.OnInitialize(self)
  self._is_Subscribe_Open = false
  self._Is_Succeed_Get_Prime_Data = false
  self._IsFromBuy = false
  self._CurSubStatus = 0
  self._IsHigh_low_take = 9999
  self._isOpenActivity = false
  self._upgrade_260_guide_flag = false
  self._renew_end_time = 0
  self._prime_refund_ban_time = nil
end
function SubscribeSystemBase:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_LOGIN, EVENTID_LOGIN_SUCCESS, self.SetPrimeOpen, self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_PRIME, self.ShowSubscribe, self)
  self:AddCommonEvent(EVENTTYPE_CENTAURI_NOTIFY, EVENTID_CENTAURI_SUBSCRIBE_NOTIFY, self.ReceiveBuyCallbackInfo, self)
  self:AddCommonEvent(EVENTTYPE_CENTAURI_NOTIFY, EVENTID_CENTAURI_GET_GOODS_PRODUCT_INFO_NOTIFY, self.LoadPriceFromCached, self)
  self:AddCommonEvent(EVENTTYPE_CENTAURI_NOTIFY, EVENTID_CENTAURI_GET_INTRO_PRICE_INFO_NOTIFY, self.LoadIntroPriceFromCached, self)
end
function SubscribeSystemBase:OnLogOut()
  log(bWriteLog and "NewSubscribeSystem log  out ")
  self._Is_Succeed_Get_Prime_Data = false
  self._IsFromBuy = false
end
function SubscribeSystemBase:GetNormalInfo()
  return self._NormalInfo
end
function SubscribeSystemBase:GetSuperInfo()
  return self._SuperInfo
end
function SubscribeSystemBase:PostReq()
  log(bWriteLog and "zino isopen subscribe.. " .. tostring(self._is_Subscribe_Open))
  if not self._is_Subscribe_Open then
    return
  end
  local SubscribeHandler = require("client.network.Protocol.SubscribeHandler")
  SubscribeHandler.send_query_prime_info()
end
function SubscribeSystemBase:JumpToCarnivalUI()
  local CallBack = function()
    local jump_utils = require("client.logic.store.jump_utils")
    jump_utils.OpenJumpModule(BP_ENUM_MODULE_SUBSCRIBE_CARNIVAL)
  end
  local logic_region_block = require("client.logic.logic_region_block.logic_region_block")
  if logic_region_block.IsCrossRegionPlayer() then
    logic_region_block.ShowCrossRegionRechargeNotify(CallBack)
  else
    CallBack()
  end
end
function SubscribeSystemBase:SetPrimeOpen()
  self._is_Subscribe_Open = self:CheckMenuOpen()
  if self._is_Subscribe_Open then
    self:PostReq()
  end
end
function SubscribeSystemBase:GetIsPrimeOpen()
  return self._is_Subscribe_Open
end
function SubscribeSystemBase:GetNewestSubStatus()
  if self._NormalInfo._left_time == 0 and not self._SuperInfo._left_time == 0 then
    return SubscribeEnumConfig.ENUM_SubStatus.NONE
  end
  local TimeUtil = require("client.common.time_util")
  if self._NormalInfo._left_time then
    if TimeUtil.GetServerTimeInSec() < self._NormalInfo._left_time then
      self._NormalInfo._is_Open = true
    else
      self._NormalInfo._is_Open = false
    end
  end
  if self._SuperInfo._left_time then
    if TimeUtil.GetServerTimeInSec() < self._SuperInfo._left_time then
      self._SuperInfo._is_Open = true
    else
      self._SuperInfo._is_Open = false
    end
  end
  local bNormalIsOpen = self._NormalInfo._is_Open
  local bSuperIsOpen = self._SuperInfo._is_Open
  if not bNormalIsOpen and not bSuperIsOpen then
    self._CurSubStatus = SubscribeEnumConfig.ENUM_SubStatus.NONE
  elseif bNormalIsOpen and not bSuperIsOpen then
    self._CurSubStatus = SubscribeEnumConfig.ENUM_SubStatus.NormalStatus
  elseif not bNormalIsOpen and bSuperIsOpen then
    self._CurSubStatus = SubscribeEnumConfig.ENUM_SubStatus.SuperStatus
  elseif bNormalIsOpen and bSuperIsOpen then
    self._CurSubStatus = SubscribeEnumConfig.ENUM_SubStatus.BothStatus
  end
  local subscri_redpoint_data = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_subscribe_reddot_data)
  subscri_redpoint_data:UpdateRewardRedDot()
  log(bWriteLog and "zino newest CurSubStatus " .. tostring(self._CurSubStatus) .. " CurrentTime " .. tostring(TimeUtil.GetServerTimeInSec()))
  return self._CurSubStatus
end
function SubscribeSystemBase:GetSubStatus()
  log(bWriteLog and "zino CurSubStatus " .. tostring(self._CurSubStatus))
  return self._CurSubStatus
end
function SubscribeSystemBase:Get_Left_Time(type)
  if type == SubscribeEnumConfig.ENUM_SubId.Normal and self._NormalInfo._left_time then
    return tonumber(self._NormalInfo._left_time)
  end
  if type == SubscribeEnumConfig.ENUM_SubId.Super and self._SuperInfo._left_time then
    return tonumber(self._SuperInfo._left_time)
  end
  return 0
end
function SubscribeSystemBase:GetPrimeRefundBanTime()
  local TimeUtil = require("client.common.time_util")
  local nCurrentTime = TimeUtil.GetServerTimeInSec()
  if not self._prime_refund_ban_time or nCurrentTime >= self._prime_refund_ban_time then
    return nil
  end
  local banTime = self._prime_refund_ban_time - nCurrentTime
  local banDays = math.ceil(banTime / 86400)
  return banDays
end
function SubscribeSystemBase:Get_Is_Valid(type)
  local TimeUtil = require("client.common.time_util")
  return TimeUtil.GetServerTimeInSec() < self:Get_Left_Time(type)
end
function SubscribeSystemBase:Set_SubProduct_ID(type, productId)
  if type == SubscribeEnumConfig.ENUM_SubId.Normal then
    self._NormalInfo._SubscribeID = productId
  elseif type == SubscribeEnumConfig.ENUM_SubId.Super then
    self._SuperInfo._SubscribeID = productId
  end
end
function SubscribeSystemBase:Get_SubProduct_ID(type)
  local ENUM_SubId = SubscribeEnumConfig.ENUM_SubId
  if type == ENUM_SubId.Normal then
    return self._NormalInfo._SubscribeID
  elseif type == ENUM_SubId.Super then
    return self._SuperInfo._SubscribeID
  elseif type == ENUM_SubId.Super_ThreeMonth or type == ENUM_SubId.Super_TwelveMonth or type == ENUM_SubId.Super_Special_Type then
    local tActData = self._ActivityData
    if tActData and tActData[type] and tActData[type].productid then
      return tActData.productid
    else
      return ""
    end
  end
end
function SubscribeSystemBase:Set_Price(type, price)
  if not type or not price then
    return
  end
  if type == SubscribeEnumConfig.ENUM_SubId.Normal then
    self._NormalInfo._show_  elseif type == SubscribeEnumConfig.ENUM_SubId.Super then
    self._SuperInfo._show_  end
end
function SubscribeSystemBase:Get_Price(type)
  if not type then
    return
  end
  if type == SubscribeEnumConfig.ENUM_SubId.Normal then
    if self._NormalInfo._show_price == "" then
      log(bWriteLog and "get_price " .. self._NormalInfo._tablePrice)
      return LocUtil.LocalizeResFormat(6378, self._NormalInfo._tablePrice)
    end
    return LocUtil.LocalizeResFormat(6378, self._NormalInfo._show_price)
  elseif type == SubscribeEnumConfig.ENUM_SubId.Super then
    if self._SuperInfo._show_price == "" then
      return LocUtil.LocalizeResFormat(6378, self._SuperInfo._tablePrice)
    end
    return LocUtil.LocalizeResFormat(6378, self._SuperInfo._show_price)
  end
end
function SubscribeSystemBase:Get_Price_NoMonth(type)
  if not type then
    return
  end
  if type == SubscribeEnumConfig.ENUM_SubId.Normal then
    if self._NormalInfo._show_price == "" then
      log(bWriteLog and "Get_Price_Num " .. self._NormalInfo._tablePrice)
      return self._NormalInfo._tablePrice
    end
    return self._NormalInfo._show_price
  elseif type == SubscribeEnumConfig.ENUM_SubId.Super then
    if self._SuperInfo._show_price == "" then
      return self._SuperInfo._tablePrice
    end
    return self._SuperInfo._show_price
  end
end
function SubscribeSystemBase:Get_Super_Price_NoMonth()
  if self._SuperInfo._show_price == "" then
    return self._SuperInfo._tablePrice
  end
  return self._SuperInfo._show_price
end
function SubscribeSystemBase:IsSetFirstBuyPrice(prime_type)
  local primeInfo
  if prime_type == SubscribeEnumConfig.ENUM_SubId.Normal then
    primeInfo = self._NormalInfo
  elseif prime_type == SubscribeEnumConfig.ENUM_SubId.Super then
    primeInfo = self._SuperInfo
  end
  return primeInfo and primeInfo._is_first_time_buy
end
function SubscribeSystemBase:Set_First_Month_Price(price)
  self._SuperInfo._first_month_price = ""
  if self:IsSetFirstBuyPrice(SubscribeEnumConfig.ENUM_SubId.Super) and self._SuperInfo._first_motnth_tableprice and self._SuperInfo._first_motnth_tableprice ~= "" then
    if price and price ~= "" then
      self._SuperInfo._first_month_    else
      self._SuperInfo._first_month_price = self._SuperInfo._first_motnth_tableprice
    end
  end
end
function SubscribeSystemBase:Set_General_First_Month_Price(price)
  self._NormalInfo._first_month_price = ""
  if self:IsSetFirstBuyPrice(SubscribeEnumConfig.ENUM_SubId.Normal) and self._NormalInfo._first_motnth_tableprice and self._NormalInfo._first_motnth_tableprice ~= "" then
    if price and price ~= "" then
      self._NormalInfo._first_month_    else
      self._NormalInfo._first_month_price = self._NormalInfo._first_motnth_tableprice
    end
  end
end
function SubscribeSystemBase:Get_First_Month_Price()
  return self._SuperInfo._first_month_price
end
function SubscribeSystemBase:Get_General_First_Month_Price()
  return self._NormalInfo._first_month_price
end
function SubscribeSystemBase:IsShowFirstMonthPrice()
  return true
end
function SubscribeSystemBase:Get_EveryDay_GetTimes(type)
  if type == SubscribeEnumConfig.ENUM_SubId.Normal and self._NormalInfo._is_Open then
    return self._NormalInfo._EveryDayGetTimes
  elseif type == SubscribeEnumConfig.ENUM_SubId.Super and self._SuperInfo._is_Open then
    return self._SuperInfo._EveryDayGetTimes
  end
  return 0
end
function SubscribeSystemBase:Get_Supply_Status()
  if not self._is_Subscribe_Open or not self._SuperInfo._is_Open then
    return false
  end
  if self._SuperInfo._InfoList[SubscribeEnumConfig.ENUM_SubInfoID.DISCOUNT_BOX] == nil then
    return false
  end
  local iscouldbuy = self._SuperInfo._InfoList[SubscribeEnumConfig.ENUM_SubInfoID.DISCOUNT_BOX].iscouldbuy
  if iscouldbuy == true then
    log(bWriteLog and "iscouldbuy" .. tostring(iscouldbuy))
    return iscouldbuy
  end
end
function SubscribeSystemBase:Get_Supply_Discount_Num()
  local num = self._SuperInfo._InfoList[SubscribeEnumConfig.ENUM_SubInfoID.DISCOUNT_BOX].num
  if num then
    return num
  end
end
function SubscribeSystemBase:Set_UPASS_Is_Take(is_take)
  if self._SuperInfo._InfoList[SubscribeEnumConfig.ENUM_SubInfoID.EXTRA_RP_SCORE] then
    self._SuperInfo._InfoList[SubscribeEnumConfig.ENUM_SubInfoID.EXTRA_RP_SCORE].iscouldbuy = is_take
  end
end
function SubscribeSystemBase:GetIsInContinuousTime()
  if not self._SuperInfo._renew_end_time or self._SuperInfo._renew_end_time == 0 then
    return false
  end
  local TimeUtil = require("client.common.time_util")
  return TimeUtil.GetServerTimeInSec() < self._SuperInfo._renew_end_time
end
function SubscribeSystemBase:Set_Discount_Item_Info(item_id, money_type, sale_price, ori_price, sale, item_num, uniq_id)
  local tItemData = self._SuperInfo._InfoList[SubscribeEnumConfig.ENUM_SubInfoID.DISCOUNT_ITEM]
  if tItemData then
    tItemData.    tItemData.    tItemData.    tItemData.    tItemData.    tItemData.    self._SuperInfo._  end
end
function SubscribeSystemBase:Get_Discount_ITemID()
  if self._SuperInfo._InfoList[SubscribeEnumConfig.ENUM_SubInfoID.DISCOUNT_ITEM].item_id then
    return self._SuperInfo._InfoList[SubscribeEnumConfig.ENUM_SubInfoID.DISCOUNT_ITEM].item_id
  end
end
function SubscribeSystemBase:Get_uniq_id()
  if self._SuperInfo._uniq_id then
    log(bWriteLog and "NewSubscribeSystem.uniq_id  " .. tostring(self._SuperInfo._uniq_id))
    return self._SuperInfo._uniq_id
  end
end
function SubscribeSystemBase:GetIsPurchasedSub()
  local bIsUnlockNormal = self:IsBuyPrime(true)
  local bIsUnlockSuper = self:IsBuyPrime()
  return bIsUnlockNormal or bIsUnlockSuper
end
function SubscribeSystemBase:HasDailyReward()
  local nNormalSubGetTimes = self:Get_EveryDay_GetTimes(SubscribeEnumConfig.ENUM_SubId.Normal)
  local nSuperSubGetTimes = self:Get_EveryDay_GetTimes(SubscribeEnumConfig.ENUM_SubId.Super)
  if 0 < nNormalSubGetTimes or 0 < nSuperSubGetTimes then
    return true
  end
  return false
end
function SubscribeSystemBase:HasWeekReward()
  return false
end
function SubscribeSystemBase:IsGetSubscribeData()
  if self._Is_Succeed_Get_Prime_Data then
    return true
  end
  self:PostReq()
  log(bWriteLog and "SubscribeSystemBase:IsGetSubscribeData >>> self._Is_Succeed_Get_Prime_Data = false")
  return false
end
function SubscribeSystemBase:GetSubscribeUIConfigName()
  if not self._Is_Succeed_Get_Prime_Data then
    log(bWriteLog and "NewSubscribeSystem._Is_Succeed_Get_Prime_Data " .. tostring(self._Is_Succeed_Get_Prime_Data))
    self._IsFromBuy = true
    self:PostReq()
    return
  end
  if self:GetNewestSubStatus() == SubscribeEnumConfig.ENUM_SubStatus.NONE then
    return "Subscribe_HomePage_New_UIBP"
  end
end
function SubscribeSystemBase:ShowSubscribe()
  if not self._Is_Succeed_Get_Prime_Data then
    log(bWriteLog and "NewSubscribeSystem._Is_Succeed_Get_Prime_Data " .. tostring(self._Is_Succeed_Get_Prime_Data))
    self._IsFromBuy = true
    self:PostReq()
    return
  end
  local special_offer_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.special_offer_module)
  special_offer_module:OpenPrime()
  local subscri_redpoint_data = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_subscribe_reddot_data)
  subscri_redpoint_data:UpdateRewardRedDot()
end
function SubscribeSystemBase:HasEveryDayGetSubId(nId)
  local ENUM_SubInfoID = SubscribeEnumConfig.ENUM_SubInfoID
  return nId == ENUM_SubInfoID.EVERYDAY_GET_UC or nId == ENUM_SubInfoID.EVERYDAY_GET_AG or nId == ENUM_SubInfoID.EXTRA_RP_SCORE
end
function SubscribeSystemBase:HasRightsSubId(nId)
  local ENUM_SubInfoID = SubscribeEnumConfig.ENUM_SubInfoID
  return nId == ENUM_SubInfoID.SHOP_BUY or nId == ENUM_SubInfoID.DISCOUNT_ITEM or nId == ENUM_SubInfoID.DISCOUNT_BOX or nId == ENUM_SubInfoID.SHARE_BAG
end
function SubscribeSystemBase:on_query_prime_info(prime_success, cfg, prime, discountbuy, tCoupons, activity_table, prime_notice_flag, prime_refund_ban_time)
  if not prime_success or prime_success ~= 0 then
    return
  end
  self._CurSubStatus = SubscribeEnumConfig.ENUM_SubStatus.NONE
  self._Is_Succeed_Get_Prime_Data = true
  self._  if cfg and next(cfg) then
    log_tree("on_query_prime_infocfg", cfg.buy)
    if cfg.priv then
      self:Cached_Describe_Info(cfg.priv)
    end
    if cfg.buy then
      self:Cached_FirstBuy_RewardInfo(cfg.buy)
    end
  end
  if discountbuy then
    log_tree("discountbuy", discountbuy)
    self:Cached_Discount_Item_Data(discountbuy)
  end
  if tCoupons and next(tCoupons) and self.SetJKCouponData then
    self:SetJKCouponData(tCoupons)
  end
  self:SetOpenSubscribeSlap(prime_notice_flag)
  EventSystem:postEvent(EVENTTYPE_SUBSCRIBE, EVENTID_ON_FACESLAP_SUBSCRIBE_READY)
  if prime then
    log_tree("prime", prime)
    self:Handle_Prime_Status(prime)
  else
    log(bWriteLog and "NewSubscribeSystem._SuperInfo._is_first_time_buy = true")
    self._SuperInfo._is_first_time_buy = true
    self._NormalInfo._is_first_time_buy = true
    local subscri_redpoint_data = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_subscribe_reddot_data)
    subscri_redpoint_data:SetFirstOpenRedData(true)
  end
  self:SetOpenSubscribeActivity(activity_table)
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if not prime and PublishRegionMacros.IsJapanOrKorea() then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local MonthCardData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eKoreaMonthCardTipTime)
    local TimeUtil = require("client.common.time_util")
    local curTime = TimeUtil.GetServerTimeInSec()
    if MonthCardData == nil or MonthCardData.lastTime == nil or not TimeUtil.IsSameDay(curTime, MonthCardData.lastTime) then
      local saveData = {lastTime = curTime}
      PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eKoreaMonthCardTipTime)
      local jump_utils = require("client.logic.store.jump_utils")
      jump_utils.OpenJumpModule(EVENTID_SUBSCRIBE_ICON_TIP)
    end
  end
end
function SubscribeSystemBase:on_notify_prime_ban_time(refund_ban_time)
  log(bWriteLog and "SubscribeSystemBase:on_notify_prime_ban_time refund_ban_time = " .. tostring(refund_ban_time))
  self._prime_  EventSystem:postEvent(EVENTTYPE_SUBSCRIBE, EVENTID_SUBSCRIBE_UPDATE_REFUND_BAN_TIME)
end
function SubscribeSystemBase:Cached_Discount_Item_Data(data)
  if not data then
    return
  end
  if data.item_id and data.sale_price and data.ori_price and data.money_type and data.item_num and data.sale and data.uniq_id then
    self:Set_Discount_Item_Info(data.item_id, data.money_type, data.sale_price, data.ori_price, data.sale, data.item_num, data.uniq_id)
  end
end
local _GetPrivilegeInfoBySetverData = function(info)
  local TempOneInfo = {
    nItemId = info.privilege_item,
    Describe = info.privilege_type_des,
    Name = info.privilege_des,
    num = info.privilege_num,
    privilege_value = info.privilege_value,
    privilege_icon = info.privilege_icon,
    privilege_des_type = info.privilege_des_type,
    privilege_describe = info.privilege_describe
  }
  return TempOneInfo
end
function SubscribeSystemBase:Cached_Describe_Info(priv_info)
  if not priv_info then
    return
  end
  if priv_info[SubscribeEnumConfig.ENUM_SubId.Normal] and next(priv_info[SubscribeEnumConfig.ENUM_SubId.Normal]) then
    for k, v in pairs(priv_info[SubscribeEnumConfig.ENUM_SubId.Normal]) do
      self._NormalInfo._InfoList[tonumber(k)] = _GetPrivilegeInfoBySetverData(v)
    end
  end
  if priv_info[SubscribeEnumConfig.ENUM_SubId.Super] and next(priv_info[SubscribeEnumConfig.ENUM_SubId.Super]) then
    for k, v in pairs(priv_info[SubscribeEnumConfig.ENUM_SubId.Super]) do
      self._SuperInfo._InfoList[tonumber(k)] = _GetPrivilegeInfoBySetverData(v)
    end
  end
end
function SubscribeSystemBase:GetIsCouponItem(nItemId)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local tItemCfg = CDataTable.GetTableData("Item", nItemId)
  if tItemCfg and tItemCfg.itemType == 16 and (tItemCfg.itemSubType == ENUM_ITEM_SUBTYPE.Coupon or tItemCfg.itemSubType == ENUM_ITEM_SUBTYPE.SpecialCoupon) then
    return true
  end
  return false
end
function SubscribeSystemBase:Cached_FirstBuy_RewardInfo(buy_info)
  if not buy_info then
    return
  end
  local nEnumSubNor = SubscribeEnumConfig.ENUM_SubId.Normal
  self._CouponData = {}
  if buy_info[nEnumSubNor] then
    local normal_buy_info = buy_info[nEnumSubNor]
    if normal_buy_info.productid then
      self:Set_SubProduct_ID(nEnumSubNor, normal_buy_info.productid)
    end
    if normal_buy_info.prime_price then
      self._NormalInfo._tablePrice = normal_buy_info.prime_price
    end
    if normal_buy_info.drop and next(normal_buy_info.drop) then
      if not self._CouponData[nEnumSubNor] then
        self._CouponData[nEnumSubNor] = {}
      end
      for _, v in pairs(normal_buy_info.drop) do
        if tonumber(v.item_id) == 1006 then
          self._NormalInfo._award_UC_Num = v.item_num
        elseif self:GetIsCouponItem(v.item_id) then
          table.insert(self._CouponData[nEnumSubNor], {
            resid = v.item_id,
            count = v.item_num
          })
        end
      end
    end
    self._NormalInfo._first_motnth_tableprice = normal_buy_info.first_time_price or ""
    self._NormalInfo.value_times = normal_buy_info.value_times
    self._NormalInfo.total_value = normal_buy_info.total_value
  end
  local nEnumSubSup = SubscribeEnumConfig.ENUM_SubId.Super
  if buy_info[nEnumSubSup] then
    local super_buy_info = buy_info[nEnumSubSup]
    if super_buy_info.productid then
      self:Set_SubProduct_ID(nEnumSubSup, super_buy_info.productid)
    end
    if super_buy_info.prime_price then
      self._SuperInfo._tablePrice = super_buy_info.prime_price
    end
    self._SuperInfo._first_motnth_tableprice = super_buy_info.first_time_price or ""
    if super_buy_info.drop and next(super_buy_info.drop) then
      if not self._CouponData[nEnumSubSup] then
        self._CouponData[nEnumSubSup] = {}
      end
      self._SuperInfo._DropAwardList = {}
      for _, v in pairs(super_buy_info.drop) do
        if tonumber(v.item_id) ~= 1006 then
          local tempdrop = {}
          tempdrop.itemid = v.item_id
          tempdrop.itemnum = v.item_num
          table.insert(self._SuperInfo._DropAwardList, tempdrop)
          if self:GetIsCouponItem(v.item_id) then
            table.insert(self._CouponData[nEnumSubSup], {
              resid = v.item_id,
              count = v.item_num
            })
          end
        else
          self._SuperInfo._award_UC_Num = v.item_num
        end
      end
    end
    self._SuperInfo.value_times = super_buy_info.value_times
    self._SuperInfo.total_value = super_buy_info.total_value
    self._SuperInfo.coupons_value = super_buy_info.coupons_value
  end
end
function SubscribeSystemBase:on_notify_prime_change(data, dailyinfo, redpoint)
  if dailyinfo then
    log_tree("dailyinfo", dailyinfo)
    self:Cached_Discount_Item_Data(dailyinfo)
  end
  if redpoint then
    self._SuperInfo._redpoint = true
  end
  if data then
    log_tree("on_notify_prime_change data", data)
    self:Handle_Prime_Status(data)
    local subscri_redpoint_data = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_subscribe_reddot_data)
    subscri_redpoint_data:UpdateRewardRedDot()
  end
end
function SubscribeSystemBase:Handle_Prime_Status(data)
  if data then
    self:SetPrimeStatus(data)
    if data.uniq_id then
      log(bWriteLog and "data.uniq_id " .. tostring(data.uniq_id))
      self._SuperInfo._uniq_id = data.uniq_id
    end
    self:HandleNormalStatusData(data[SubscribeEnumConfig.ENUM_SubId.Normal], SubscribeEnumConfig.ENUM_SubId.Normal, self._NormalInfo)
    self:HandleSuperStatusData(data[SubscribeEnumConfig.ENUM_SubId.Super], SubscribeEnumConfig.ENUM_SubId.Super, self._SuperInfo)
    local subscri_redpoint_data = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_subscribe_reddot_data)
    subscri_redpoint_data:UpdateRewardRedDot()
  end
  if self._IsFromBuy then
    log(bWriteLog and "_isfrombuy == true")
    self:ShowSubscribe()
    self._IsFromBuy = false
  end
  EventSystem:postEvent(EVENTTYPE_SUBSCRIBE, EVENTID_SUBSCRIBE_GET_STATUS_DATA)
  EventSystem:postEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_SPECIAL_OFFER_REFRESH_PAGE)
end
function SubscribeSystemBase:HandleNormalStatusData(data, subId, info)
  if not data or not next(data) then
    info._is_first_time_buy = true
    return
  end
  info._start_time = data.begin_time or 0
  info._Centauri_end_time = data.Centauri_end_time or 0
  info._Centauri_start_time = data.Centauri_begin_time or 0
  if data.priv then
    local everydayGetUC = data.priv[SubscribeEnumConfig.ENUM_SubInfoID.EVERYDAY_GET_UC]
    if everydayGetUC and everydayGetUC.times then
      info._EveryDayGetTimes = everydayGetUC.times
      log(bWriteLog and "NewSubscribeSystem._NormalInfo._EveryDayGetTimes" .. info._EveryDayGetTimes)
    end
    if GlobalData.IsJapanOrKorea() then
      local extraRPScore = data.priv[SubscribeEnumConfig.ENUM_SubInfoID.EXTRA_RP_SCORE]
      if extraRPScore then
        info._EveryDayGetTimes = extraRPScore.times
      end
    end
    if self.CachedNormalDiscountStatus then
      self:CachedNormalDiscountStatus(data.priv, SubscribeEnumConfig.ENUM_SubId.Normal)
    end
    self:HandleRegionData(subId, data.priv)
  end
  if data.first_reward then
    info._Is_Could_Take_Award = data.first_reward
  end
end
function SubscribeSystemBase:HandleSuperStatusData(data, subId, info)
  if not data or not next(data) then
    log(bWriteLog and "NewSubscribeSystem._SuperInfo._is_first_time_buy = true")
    info._is_first_time_buy = true
    return
  end
  info._start_time = data.begin_time or 0
  info._Centauri_end_time = data.Centauri_end_time or 0
  info._Centauri_start_time = data.Centauri_begin_time or 0
  local ENUM_SubInfoID = SubscribeEnumConfig.ENUM_SubInfoID
  local ENUM_SubId = SubscribeEnumConfig.ENUM_SubId
  if data.priv then
    log_tree("Super_Data.priv", data.priv)
    if data.priv[ENUM_SubInfoID.EVERYDAY_GET_UC] and data.priv[ENUM_SubInfoID.EVERYDAY_GET_UC].times then
      info._EveryDayGetTimes = data.priv[ENUM_SubInfoID.EVERYDAY_GET_UC].times
      log(bWriteLog and "NewSubscribeSystem._SuperInfo._EveryDayGetTimes" .. info._EveryDayGetTimes)
    end
    if not next(info._InfoList) then
      return
    end
    if data.priv[ENUM_SubInfoID.DISCOUNT_BOX] ~= nil and info._InfoList[ENUM_SubInfoID.DISCOUNT_BOX] then
      log(bWriteLog and "Super_Data.priv[NewSubscribeSystem.ENUM_SubInfoID.DISCOUNT_BOX] " .. tostring(data.priv[ENUM_SubInfoID.DISCOUNT_BOX]))
      info._InfoList[ENUM_SubInfoID.DISCOUNT_BOX].iscouldbuy = data.priv[ENUM_SubInfoID.DISCOUNT_BOX]
    end
    if data.priv[ENUM_SubInfoID.EXTRA_RP_SCORE] ~= nil then
      self:Set_UPASS_Is_Take(data.priv[ENUM_SubInfoID.EXTRA_RP_SCORE])
    end
    if data.priv[ENUM_SubInfoID.DISCOUNT_ITEM] and data.priv[ENUM_SubInfoID.DISCOUNT_ITEM]._uniq_id then
      info._uniq_id = data.priv[ENUM_SubInfoID.DISCOUNT_ITEM].uniq_id
    end
    if self.CachedNormalDiscountStatus then
      self:CachedNormalDiscountStatus(data.priv, ENUM_SubId.Super)
    end
    self:HandleRegionData(subId, data.priv)
  end
  if data.first_reward then
    info._Is_Could_Take_Award = data.first_reward
  end
  if data.renew_end_time and 0 < data.renew_end_time then
    log(bWriteLog and "Super_Data.renew_end_time " .. tostring(data.renew_end_time))
    info._renew_end_time = data.renew_end_time
  else
    info._renew_end_time = 0
  end
end
function SubscribeSystemBase:SetPrimeStatus(data)
  if data then
    local Normal_Data = data[SubscribeEnumConfig.ENUM_SubId.Normal]
    local Super_Data = data[SubscribeEnumConfig.ENUM_SubId.Super]
    self:HandleUpdateStatus(Normal_Data, self._NormalInfo)
    self:HandleUpdateStatus(Super_Data, self._SuperInfo)
    local bIsNormalOpen = self._NormalInfo._is_Open
    local bIsSuperOpen = self._SuperInfo._is_Open
    if not bIsNormalOpen and not bIsSuperOpen then
      self._CurSubStatus = SubscribeEnumConfig.ENUM_SubStatus.NONE
    elseif bIsNormalOpen and not bIsSuperOpen then
      self._CurSubStatus = SubscribeEnumConfig.ENUM_SubStatus.NormalStatus
    elseif not bIsNormalOpen and bIsSuperOpen then
      self._CurSubStatus = SubscribeEnumConfig.ENUM_SubStatus.SuperStatus
    elseif bIsNormalOpen and bIsSuperOpen then
      self._CurSubStatus = SubscribeEnumConfig.ENUM_SubStatus.BothStatus
    end
    local subscri_redpoint_data = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_subscribe_reddot_data)
    subscri_redpoint_data:SetFirstOpenRedData(self:GetSubStatus() == SubscribeEnumConfig.ENUM_SubStatus.NONE)
  end
end
function SubscribeSystemBase:HandleUpdateStatus(data, info)
  if not data or not next(data) then
    return
  end
  if data.end_time then
    local TimeUtil = require("client.common.time_util")
    if TimeUtil.GetServerTimeInSec() < data.end_time then
      info._left_time = data.end_time
      info._is_Open = true
    else
      info._is_Open = false
    end
  end
end
function SubscribeSystemBase:On_take_daily_uc_priv(ret, number, super_times, normal_times)
  if not ret then
    return
  end
  if ret == 0 then
    log(bWriteLog and "ret " .. ret)
    if super_times then
      log(bWriteLog and "super_times " .. super_times)
      self._SuperInfo._EveryDayGetTimes = super_times
    end
    if normal_times then
      log(bWriteLog and "normal_times " .. normal_times)
      self._NormalInfo._EveryDayGetTimes = normal_times
    end
    if number then
      local arrayItemData = {}
      table.insert(arrayItemData, {res_id = 1006, count = number})
      local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
      Logic_CommonItemGet.ShowPanel_DefaultStyle(arrayItemData)
      EventSystem:postEvent(EVENTTYPE_SUBSCRIBE, EVENTID_SUBSCRIBE_GET_UC_DATA, number)
    end
    return
  elseif ret == 103 then
    ShowNotice(6503)
  elseif ret == 104 then
    ShowNotice(LocUtil.GetLocalizeResStr(6494))
  end
end
function SubscribeSystemBase:On_buy_discount_sale_item_rsp(ret, item_id, item_num)
  if not ret then
    return
  end
  log(bWriteLog and "ret " .. ret)
  if ret == 0 then
    if item_id then
      log(bWriteLog and "On_buy_discount_sale_itemid " .. item_id)
    end
    if item_num then
      self._SuperInfo._InfoList[SubscribeEnumConfig.ENUM_SubInfoID.DISCOUNT_ITEM].      log(bWriteLog and "On_buy_discount_sale_item num " .. item_num)
    end
    if item_num and item_id then
      local arrayItemData = {}
      table.insert(arrayItemData, {res_id = item_id, count = item_num})
      local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
      Logic_CommonItemGet.ShowPanel_DefaultStyle(arrayItemData)
      local _ = self.Set_Discount_Is_Take and type(self.Set_Discount_Is_Take) == "function" and self:Set_Discount_Is_Take(false)
    end
    EventSystem:postEvent(EVENTTYPE_SUBSCRIBE, EVENTID_SUBSCRIBE_DAILYSHOP_DATA)
    EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_BUY_INFO_CHANGE)
    EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_SUBSCRIBE_BUY)
  elseif ret == 103 then
    ShowNotice(4793)
  elseif ret == 104 then
    ShowNotice(6494)
    self:BPNotEnough()
  end
end
function SubscribeSystemBase:BPNotEnough()
  local StoreUtils = require("client.slua.logic.store.utils.store_utils")
  local str = string.format(LocUtil.LocalizeResFormat(501052, StoreUtils.GetMoneyName(1006)))
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, LocUtil.GetLocalizeResStr(101001), str, function()
    local RechargeSystem = require("client.logic.recharge.logic_recharge")
    RechargeSystem.OpenRechargeUI()
  end)
end
function SubscribeSystemBase:ReceiveBuyCallbackInfo(evenType, eventID, resultCode, sPayChannel)
  logic_connection_waiting:Hide(1)
  if resultCode == nil then
    log(bWriteLog and "\230\139\137\229\143\150\230\149\176\230\141\174\229\164\177\232\180\165")
    return
  end
  log_tree("zino prime buy_callback resultCode", resultCode)
  if tonumber(resultCode) == 0 then
    log(bWriteLog and "imobile_notify_client_charge")
    sPayChannel = sPayChannel or ""
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    local sTLogStr = "3," .. sPayChannel
    log(bWriteLog and " SubscribeSystemBase:ReceiveBuyCallbackInfo SubscribeSuccess >>>> " .. sTLogStr)
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.SubscribeSuccess, 0, sTLogStr, true)
    local CentauriHandler = require("client.network.Protocol.CentauriHandler")
    CentauriHandler.send_imobile_notify_client_charge(0)
    EventSystem:postEvent(EVENTTYPE_SUBSCRIBE, EVENTID_SUBSCRIBE_Buy_Succeed)
  end
end
function SubscribeSystemBase:GetCentauriGoodsInfo(evenType, eventID, resultTable)
  if resultTable == nil then
    log(bWriteLog and "GetCentauriPriceInfo\230\139\137\229\143\150\230\149\176\230\141\174\229\164\177\232\180\165")
    logic_connection_waiting:Hide(1)
    return
  end
  if not resultTable or not next(resultTable) then
    log_error("no Centauri GetCentauriGoodsInfo")
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
  log(bWriteLog and "SYR_GetCentauriGoodsInfo " .. str)
  if str ~= self:MakeActivityProductIdStr() then
    log_error("no Centauri SYR_GetCentauriGoodsInfo")
    return
  end
  log_tree("zino GetCentauriGoodsInfo resultTable", resultTable)
  self._Centauri_act_table_data = resultTable
  EventSystem:postEvent(EVENTTYPE_SUBSCRIBE, EVENTID_SUBSCRIBE_GET_CENTAURIGOODS_PRICE)
  logic_connection_waiting:Hide(1)
end
function SubscribeSystemBase:GetCentauriIntroInfo(evenType, eventID, resultTable)
  if resultTable == nil then
    log(bWriteLog and "GetCentauriIntroInfo\232\175\187\229\143\150\230\149\176\230\141\174\229\164\177\232\180\165")
    logic_connection_waiting:Hide(1)
    return
  end
  log_tree("zino GetCentauriIntroInfo resultTable", resultTable)
  for k, product in pairs(resultTable) do
    if product.productId ~= nil and product.price ~= nil then
      if product.productId == self:Get_SubProduct_ID(SubscribeEnumConfig.ENUM_SubId.Normal) then
        log(bWriteLog and "product.Normalprice " .. product.price)
        self:Set_Price(SubscribeEnumConfig.ENUM_SubId.Normal, product.price)
      elseif product.productId == self:Get_SubProduct_ID(SubscribeEnumConfig.ENUM_SubId.Super) then
        log(bWriteLog and "product.Superprice " .. product.price)
        self:Set_Price(SubscribeEnumConfig.ENUM_SubId.Super, product.price)
      end
    else
      log(bWriteLog and "GetCentauriGoodsInfo \230\139\137\229\143\150\230\149\176\230\141\174\229\164\177\232\180\165")
      logic_connection_waiting:Hide(1)
    end
    if product.productId and product.intro_price and product.intro_price ~= "" and product.intro_gwallet_num and product.intro_ios_num then
      if product.productId == self:Get_SubProduct_ID(SubscribeEnumConfig.ENUM_SubId.Super) then
        self:Set_First_Month_Price(product.intro_price)
      end
      if product.productId == self:Get_SubProduct_ID(SubscribeEnumConfig.ENUM_SubId.Normal) then
        self:Set_General_First_Month_Price(product.intro_price)
      end
    else
      log(bWriteLog and "GetCentauriIntroInfo \230\139\137\229\143\150\230\149\176\230\141\174\229\164\177\232\180\165")
    end
  end
  EventSystem:postEvent(EVENTTYPE_SUBSCRIBE, EVENTID_SUBSCRIBE_GET_CENTAURIGOODS_PRICE)
  logic_connection_waiting:Hide(1)
end
function SubscribeSystemBase:LoadIntroPriceFromCached(evenType, eventID, resultCode)
  log(bWriteLog and "LoadIntroPriceFromCached" .. tostring(resultCode))
  if resultCode and self:Get_SubProduct_ID(SubscribeEnumConfig.ENUM_SubId.Normal) ~= "" and self:Get_SubProduct_ID(SubscribeEnumConfig.ENUM_SubId.Super) ~= "" then
    local productid_str = self:MakeProductIdStr()
    local isProductInfoCached, cachedProductInfoList = CentauriManager.LoadCachedCentauriIntroPrice(productid_str)
    if isProductInfoCached then
      log_tree("zino cachedProductInfoList", cachedProductInfoList)
      self:GetCentauriIntroInfo(evenType, eventID, cachedProductInfoList)
    else
      log(bWriteLog and "no reason to go here if go here find alex")
    end
  end
  logic_connection_waiting:Hide(1)
end
function SubscribeSystemBase:LoadPriceFromCached(evenType, eventID, resultCode)
  log(bWriteLog and "LoadPriceFromCached" .. tostring(resultCode))
  if resultCode then
    local product_activity_str = self:MakeActivityProductIdStr()
    if product_activity_str and product_activity_str ~= "" then
      local isProductInfoCached, cachedProductInfoList = CentauriManager.LoadCachedCentauriProductInfo(product_activity_str)
      if isProductInfoCached then
        log_tree("zino cachedProductInfoList222", cachedProductInfoList)
        self:GetCentauriGoodsInfo(evenType, eventID, cachedProductInfoList)
      else
        log(bWriteLog and "no reason to go here if go here find alex")
      end
    end
  end
  logic_connection_waiting:Hide(1)
end
function SubscribeSystemBase:On_take_first_award_rsp(ret, res)
  if ret and ret == 0 then
    log_tree("On_notify_take_first_award", ret)
    log_tree("res ", res)
    local AwardList = {}
    for k, v in pairs(res) do
      local award = {}
      award.count = v
      award.res_id = tonumber(k)
      table.insert(AwardList, award)
    end
    log_tree("zino AwardList", AwardList)
    local str = LocUtil.GetLocalizeResStr("6374")
    local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
    local tExtendData = {sTitle = str}
    Logic_CommonItemGet.ShowPanel_DefaultStyle(AwardList, false, true, tExtendData)
    if self._IsHigh_low_take == SubscribeEnumConfig.ENUM_KoreaSubInfoID.Get_Award then
      self._SuperInfo._Is_Could_Take_Award = false
    else
      self._NormalInfo._Is_Could_Take_Award = false
    end
    EventSystem:postEvent(EVENTTYPE_SUBSCRIBE, EVENTID_SUBSCRIBE_GET_AWARD)
  else
    log(bWriteLog and "ret " .. tostring(ret))
  end
end
function SubscribeSystemBase:CheckMenuOpen()
  local isopen = false
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local bIsJK = PublishRegionMacros.IsJapanOrKorea()
  local AOSSHOPMacros = require("client.slua.config.ClientMacros.AOSSHOPMacros")
  local nAOSSHOP = Client.GetAOSSHOP()
  if nAOSSHOP == AOSSHOPMacros.Samsung and bIsJK or nAOSSHOP == AOSSHOPMacros.Amazon or nAOSSHOP == AOSSHOPMacros.HMS and not self:HMSIsOpenSubscribe() then
    return false
  end
  local logic_cloud_game = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cloud_game)
  if logic_cloud_game:IsCloudVersion() then
    log(bWriteLog and "SubscribeSystemBase:CheckMenuOpen is IsCloudVersion ")
    return false
  end
  isopen = LobbySystem.CheckOpen(BP_ENUM_LOBBY_MENU_SUBSCRIBE_SYSTEM)
  local logic_multiple_area = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_multiple_area)
  local isPaymentSupportCurrentArea = logic_multiple_area:IsPaymentSupport()
  log(bWriteLog and "SubscribeSystemBase.CheckMenuOpen subscript system switch: " .. tostring(isopen) .. " area payment support: " .. tostring(isPaymentSupportCurrentArea))
  isopen = isopen and isPaymentSupportCurrentArea
  local strRegion = Client.GetPublishRegion()
  if strRegion then
    if strRegion == PublishRegionMacros.VNG then
      isopen = LobbySystem.CheckOpen(80004)
    end
    if strRegion == PublishRegionMacros.TW then
      isopen = LobbySystem.CheckOpen(80005)
    end
  end
  log(bWriteLog and "NewSubscribeSystem._is_Subscribe_Open " .. tostring(isopen))
  return isopen
end
function SubscribeSystemBase:CentauriBuy(SubId)
  if not SubId then
    log_error("CentauriBuy no subid")
    return
  end
  local logic_payment_api = require("client.logic.pay.logic_payment_api")
  local sProductId = self:Get_SubProduct_ID(SubId)
  if not sProductId or sProductId == "" then
    return
  end
  local nDay = 1
  local sMonetaryUint = "USD"
  local subscribeStoreInfo = CentauriManager.LoadCachedSubscribeStoreInfo(sProductId)
  if SubId <= SubscribeEnumConfig.ENUM_SubId.Super then
    nDay = 30
    self:SenBuyTLog(sProductId, nDay, sMonetaryUint)
    logic_payment_api:Subscribe(sProductId, nDay, "US", sMonetaryUint, "PUBGPrimeP", "PUBGPrimeP", true, subscribeStoreInfo.bansePlanId, subscribeStoreInfo.gwOfferId)
  else
    local subdata = self._ActivityData[SubId]
    if subdata then
      nDay = subdata.time
    end
    logic_payment_api:Subscribe(sProductId, nDay, "US", sMonetaryUint, "PUBGPrimeP", "PUBGPrimeP", false, subscribeStoreInfo.bansePlanId, subscribeStoreInfo.gwOfferId)
  end
end
function SubscribeSystemBase:SenBuyTLog(sProductId, nDay, sMonetaryUint)
  local TimeUtil = require("client.common.time_util")
  local sTLogStr = TimeUtil.GetServerTimeInSec() .. "," .. sProductId .. "," .. nDay .. "," .. sMonetaryUint
  log(bWriteLog and " SubscribeSystemBase:SenBuyTLog >>>> " .. sTLogStr)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.SendPaySubscribe, 0, sTLogStr, true)
end
function SubscribeSystemBase:GetSubscribeCouponData()
  return self._CouponData
end
function SubscribeSystemBase:IsOpenSubscribeActivity()
  log(bWriteLog and "IsOpenSubscribeActivity " .. tostring(self._isOpenActivity))
  return self._isOpenActivity
end
function SubscribeSystemBase:IsOpenSubscribeSlap()
  return self._isOpenSlap
end
function SubscribeSystemBase:SetOpenSubscribeActivity(activity_table)
  if activity_table and next(activity_table) then
    self._isOpenActivity = true
    log_tree("subscribe_activity_table", activity_table)
    self._ActivityData = activity_table
    if self:GetSubStatus() < SubscribeEnumConfig.ENUM_SubStatus.SuperStatus or not self:GetIsInContinuousTime() then
      local tTempData = {
        describe = LocUtil.LocalizeResFormat(7650),
        prime_price = self:Get_Price(SubscribeEnumConfig.ENUM_SubId.Super)
      }
      self._ActivityData[SubscribeEnumConfig.ENUM_SubId.Super] = tTempData
    else
      self._ActivityData[SubscribeEnumConfig.ENUM_SubId.Super] = nil
    end
  else
    self._isOpenActivity = false
    log(bWriteLog and "no_subscribe_activity_data")
  end
end
function SubscribeSystemBase:SetOpenSubscribeSlap(prime_notice_flag)
  self._isOpenSlap = prime_notice_flag ~= nil
end
function SubscribeSystemBase:MakeProductIdStr()
  local productid_str = string.format("%s,%s", self:Get_SubProduct_ID(SubscribeEnumConfig.ENUM_SubId.Normal), self:Get_SubProduct_ID(SubscribeEnumConfig.ENUM_SubId.Super))
  return productid_str
end
function SubscribeSystemBase:MakeActivityProductIdStr()
  local ENUM_SubId = SubscribeEnumConfig.ENUM_SubId
  local productid_str = ""
  if self:Get_SubProduct_ID(ENUM_SubId.Super_ThreeMonth) and self:Get_SubProduct_ID(ENUM_SubId.Super_ThreeMonth) ~= "" then
    productid_str = productid_str .. self:Get_SubProduct_ID(ENUM_SubId.Super_ThreeMonth)
  end
  self:HandleProductID(ENUM_SubId.Super_TwelveMonth, productid_str)
  self:HandleProductID(ENUM_SubId.Super_Special_Type, productid_str)
  log(bWriteLog and "SubscribeSystemBase.MakeActivityProductIdStr " .. tostring(productid_str))
  return productid_str
end
function SubscribeSystemBase:HandleProductID(subId, productid_str)
  local subProductID = self:Get_SubProduct_ID(subId)
  if subProductID and subProductID ~= "" then
    if productid_str == "" then
      productid_str = subProductID
    else
      productid_str = productid_str .. "," .. subProductID
    end
  end
  return productid_str
end
function SubscribeSystemBase:IsSubscribeContinous(type)
  local Centauri_end_time = 0
  if type == SubscribeEnumConfig.ENUM_SubId.Super then
    Centauri_end_time = self._SuperInfo._renew_end_time or 0
    log(bWriteLog and "SuperInfo_renew_end_time " .. tostring(Centauri_end_time))
  elseif type == SubscribeEnumConfig.ENUM_SubId.Normal then
    Centauri_end_time = self._NormalInfo._Centauri_end_time or 0
  end
  local TimeUtil = require("client.common.time_util")
  local cur_time = TimeUtil.GetServerTimeInSec()
  log(bWriteLog and "SubscribeSystemBase.IsSubscribeContinous type = " .. tostring(type) .. "_Centauri_end_time = " .. tostring(Centauri_end_time) .. "curTime = " .. tostring(cur_time))
  return Centauri_end_time > cur_time
end
function SubscribeSystemBase:GetIsBuyPrimeGift(type)
  local UserData
  if type == SubscribeEnumConfig.ENUM_SubId.Normal then
    UserData = self._NormalInfo
  elseif type == SubscribeEnumConfig.ENUM_SubId.Super then
    UserData = self._SuperInfo
  end
  if not UserData then
    log(bWriteLog and "SubscribeSystemBase.GetIsBuyPrimeGift UserData is nil")
    return false
  end
  local startCentauriTime = UserData._Centauri_start_time or 0
  local endCentauriTime = UserData._Centauri_end_time or 0
  if type == SubscribeEnumConfig.ENUM_SubId.Super then
    endCentauriTime = UserData._renew_end_time or 0
  end
  local startTime = UserData._start_time or 0
  local endTime = UserData._left_time or 0
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  log(bWriteLog and "SubscribeSystemBase.GetIsBuyPrimeGift curTime = " .. tostring(curTime) .. " startTime = " .. tostring(startTime) .. " endTime = " .. tostring(endTime) .. " type = " .. tostring(type) .. " endCentauriTime = " .. tostring(endCentauriTime) .. " startCentauriTime = " .. tostring(startCentauriTime))
  local intervalTime = 1728000
  local intervalTime_2 = 432000
  if 0 < startTime and 0 < endTime and endTime > curTime and (intervalTime < endTime - endCentauriTime or intervalTime_2 < startCentauriTime - startTime) then
    return true
  end
  return false
end
function SubscribeSystemBase:OpenCommonAgreementPopUI(sub_id, bStoreJump)
  local data = {sub_type = sub_id}
  UIManager.ShowUI(UIManager.UI_Config.ui_subscribe_confirm_buy, SubscribeEnumConfig.ENUM_PrimeAgreementShowType.Common, data, bStoreJump)
end
function SubscribeSystemBase:IsBuyPrime(isNormal)
  local ENUM_SubStatus = SubscribeEnumConfig.ENUM_SubStatus
  local curStatus = self:GetSubStatus()
  if curStatus == ENUM_SubStatus.NONE then
    return false
  end
  if curStatus == ENUM_SubStatus.BothStatus then
    return true
  end
  if isNormal then
    return curStatus == ENUM_SubStatus.NormalStatus
  end
  return curStatus == ENUM_SubStatus.SuperStatus
end
function SubscribeSystemBase:HMSIsOpenSubscribe()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  local AOSSHOPMacros = require("client.slua.config.ClientMacros.AOSSHOPMacros")
  local nAOSSHOP = Client.GetAOSSHOP()
  if Client.GetDevicePlatformName() == DevicePlatformNameMacros.Android and nAOSSHOP == AOSSHOPMacros.HMS then
    return LobbySystem.CheckOpen(BP_ENUM_LOBBY_MENU_SUBSCRIBE_SYSTEM_HMS)
  end
  return false
end
function SubscribeSystemBase:ShowReceiveReward(tAllReward, tAllItemValid)
  local tAllData = {}
  for k, v in pairs(tAllReward) do
    table.insert(tAllData, {
      res_id = k,
      count = v,
      valid_hours = tAllItemValid[k] and tAllItemValid[k].valid_hours or 0
    })
  end
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(tAllData)
  local special_offer_cfg = require("client.slua.logic.specialoffer.special_offer_cfg")
  EventSystem:postEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_SPECIAL_RED_CHANGE, special_offer_cfg.subscribe)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CSubscribeSystemBase = class(CModuleBase, nil, SubscribeSystemBase)
return CSubscribeSystemBase