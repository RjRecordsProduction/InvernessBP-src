local store_limit_buy_manager = {}
local isJK = false
function store_limit_buy_manager:DefineAndResetData()
  self.specialGiftBuyInfo = {}
  self.backUserBuyLimitInfo = {}
  self.materialPackLimitInfo = {}
  self.rpPlusLimitInfo = {}
  isJK = GlobalData.IsJapanOrKorea()
end
function store_limit_buy_manager:ReqLimitBuyInfo()
  local StoreHandler = require("client.network.Protocol.StoreHandler")
  StoreHandler.send_get_market_buy_info_req_v3()
  self:CheckRequireSpecialLimitInfo()
end
function store_limit_buy_manager:ResLimitBuyInfo(list, isAll, backUserBuyLimitInfo, materialPackLimitInfo, rpPlusLimitInfo)
  if isAll == 1 then
    StoreConst.buy_info = list or {}
  else
    for i, v in pairs(list) do
      StoreConst.buy_info[i] = v
    end
  end
  if backUserBuyLimitInfo then
    self:SetBackUserLimitInfo(backUserBuyLimitInfo)
  end
  self.materialPackLimitInfo = materialPackLimitInfo or {}
  self.rpPlusLimitInfo = rpPlusLimitInfo or {}
  EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_BUY_INFO_CHANGE)
end
function store_limit_buy_manager:GetCurDayPurchasedTimes(nShopId)
  local tItemShopData = StoreConst.buy_info[nShopId]
  if not tItemShopData then
    return 0
  end
  return tItemShopData.daily_buy_cnt or 0
end
function store_limit_buy_manager:SetOtherLimitInfo(back_user_buy_info, material_limit_info, rpPlusLimitInfo)
  if back_user_buy_info then
    self:SetBackUserLimitInfo(back_user_buy_info)
  end
  if material_limit_info then
    self.materialPackLimitInfo = material_limit_info
  end
  if rpPlusLimitInfo then
    self.  end
end
function store_limit_buy_manager:SetBackUserLimitInfo(back_user_buy_info)
  local logic_return_activity_utils = require("client.slua.logic.return_activity.logic_return_activity_utils")
  local endTime = logic_return_activity_utils.GetTimeEndTime()
  local TimeUtil = require("client.common.time_util")
  if endTime ~= 0 and endTime > TimeUtil.GetServerTimeInSec() then
    self.backUserBuyLimitInfo = back_user_buy_info
  else
    self.backUserBuyLimitInfo = nil
  end
end
function store_limit_buy_manager:CheckRequireSpecialLimitInfo()
  local shopID = self:GetDelaySpecialGiftShopID()
  if shopID ~= 0 then
    local StoreHandler = require("client.network.Protocol.StoreHandler")
    StoreHandler.send_get_market_gift_limit_info_req(shopID)
  end
end
function store_limit_buy_manager:GetDelaySpecialGiftShopID()
  local itemData = {}
  if StoreConst.store_data and StoreConst.store_data[StoreConst.Page_New_ID_Recommend] then
    itemData = StoreConst.store_data[StoreConst.Page_New_ID_Recommend][StoreConst.label_market_index_market_list] or {}
  end
  for _, data in pairs(itemData) do
    if data[StoreConst.label_item_index_preferences_gift] == 1 then
      return data[StoreConst.label_item_index_market_id] or 0
    end
  end
  return 0
end
function store_limit_buy_manager:ResSpecialGiftLimitInfo(list)
  if not list then
    return
  end
  self.specialGiftBuyInfo = list or {}
  if StoreConst.store_data then
    local StoreSubscriptData = require("client.slua.logic.store.store_subscript_data")
    StoreSubscriptData.SetSubscriptData(StoreConst.store_data[StoreConst.Page_New_ID_Recommend] or {})
  end
  EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_BUY_INFO_CHANGE)
end
function store_limit_buy_manager:GetSpecialGiftBuyInfo(shopID)
  local BuyInfo = {
    daily_buy_cnt = 0,
    week_buy_cnt = 0,
    permanet_buy_cnt = 0
  }
  if self.specialGiftBuyInfo and self.specialGiftBuyInfo[shopID] then
    BuyInfo.daily_buy_cnt = self.specialGiftBuyInfo[shopID].daily_buy_cnt or 0
    BuyInfo.week_buy_cnt = self.specialGiftBuyInfo[shopID].week_buy_cnt or 0
    BuyInfo.permanet_buy_cnt = self.specialGiftBuyInfo[shopID].permanet_buy_cnt or 0
  end
  return BuyInfo
end
function store_limit_buy_manager:CheckBackUsertBuyCountToday()
  local backUserBuyLimitInfo = {}
  for i, v in pairs(self.backUserBuyLimitInfo or {}) do
    for goodId, limitInfo in pairs(v) do
      local _, count = self:GetBackUserPrivilege(goodId)
      if 0 < count then
        return true
      end
    end
  end
  return false
end
function store_limit_buy_manager:GetBackUserBuyLimitInfoByShopID(shopID)
  if not self.backUserBuyLimitInfo then
    return nil
  end
  if not next(self.backUserBuyLimitInfo) then
    return nil
  end
  local dayInfo = self.backUserBuyLimitInfo.daily_limit_info[shopID]
  local weekInfo = self.backUserBuyLimitInfo.week_limit_info[shopID]
  return dayInfo, weekInfo
end
function store_limit_buy_manager:GetBackUserPrivilegeDesc()
  local GetItemName = function(ItemID)
    if ItemID then
      local SpecialItemDetailCfg = CDataTable.GetTableData("SpecialItemDetail", ItemID)
      if SpecialItemDetailCfg then
        return SpecialItemDetailCfg.Name
      end
      local ItemCfg = CDataTable.GetTableData("Item", ItemID)
      if ItemCfg then
        return ItemCfg.ItemName
      end
    end
    return ""
  end
  local GetItemIdByShopId = function(shopId)
    local logic_special_offer_material = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_special_offer_material)
    local giftsData = logic_special_offer_material:GetGiftsData()
    for i, v in ipairs(giftsData) do
      for i, data in ipairs(v) do
        if data.goodsId == shopId then
          return data.itemId
        end
      end
    end
  end
  local desc = ""
  local backUserBuyLimitInfo = {}
  for i, v in pairs(self.backUserBuyLimitInfo) do
    for goodId, limitInfo in pairs(v) do
      local name = GetItemName(GetItemIdByShopId(goodId))
      if name ~= "" then
        local text = LocUtil.LocalizeResFormat(78063, name, limitInfo.total_valid_cnt, limitInfo.total_buy_cnt)
        desc = desc .. text .. [[
]]
      end
    end
  end
  return desc
end
function store_limit_buy_manager:GetBackUsetBuyLimitInfo()
  if not self.backUserBuyLimitInfo then
    return
  end
  local logic_special_offer_material = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_special_offer_material)
  local giftData = logic_special_offer_material:GetGiftsData()
  local goods = {}
  for i, v in ipairs(giftData) do
    for _, good in ipairs(v) do
      table.insert(goods, good)
    end
  end
  local backUserBuyLimitInfo = {}
  for i, v in pairs(self.backUserBuyLimitInfo) do
    for goodId, limitInfo in pairs(v) do
      backUserBuyLimitInfo[goodId] = limitInfo
    end
  end
  for goodsId, v in pairs(backUserBuyLimitInfo) do
    for i, v in ipairs(goods) do
      if goodsId == v.goodsId then
        return self.backUserBuyLimitInfo
      end
    end
  end
  return nil
end
function store_limit_buy_manager:GetBackUserPrivilege(shopID)
  local Gifts_Const = require("client.slua.logic.specialoffer.special_offer_gifts_const")
  local dayInfo, weekInfo = self:GetBackUserBuyLimitInfoByShopID(shopID)
  if dayInfo and dayInfo.total_buy_cnt then
    if dayInfo.total_buy_cnt >= dayInfo.total_valid_cnt then
      return Gifts_Const.Enum_LimitType.backUserDaily, 0, dayInfo.add_cnt or 0
    end
    local dayCnt = dayInfo.add_cnt - dayInfo.buy_cnt
    return Gifts_Const.Enum_LimitType.backUserDaily, dayCnt, dayInfo.add_cnt
  end
  if weekInfo and weekInfo.total_buy_cnt then
    if weekInfo.total_buy_cnt >= weekInfo.total_valid_cnt then
      return Gifts_Const.Enum_LimitType.backUserWeek, 0, weekInfo.add_cnt or 0
    end
    local weekCnt = weekInfo.add_cnt - weekInfo.buy_cnt
    return Gifts_Const.Enum_LimitType.backUserWeek, weekCnt, weekInfo.add_cnt
  end
  return nil, 0, 0
end
function store_limit_buy_manager:GetCollectPrivilege(shopID)
  local Gifts_Const = require("client.slua.logic.specialoffer.special_offer_gifts_const")
  local collectDayInfo, collectWeekInfo = self:GetCollectPrivilegeLimitInfoByShopID(shopID)
  if collectDayInfo and collectDayInfo.total_buy_cnt then
    if collectDayInfo.total_buy_cnt >= collectDayInfo.total_add_cnt then
      return Gifts_Const.Enum_LimitType.privilegeDaily, 0, 0
    end
    local dayCnt = collectDayInfo.add_cnt - collectDayInfo.buy_cnt
    return Gifts_Const.Enum_LimitType.privilegeDaily, dayCnt, collectDayInfo.add_cnt
  end
  if collectWeekInfo and collectWeekInfo.total_buy_cnt then
    if collectWeekInfo.total_buy_cnt >= collectWeekInfo.total_add_cnt then
      return Gifts_Const.Enum_LimitType.privilegeWeek, 0, 0
    end
    local weekCnt = collectWeekInfo.add_cnt - collectWeekInfo.buy_cnt
    return Gifts_Const.Enum_LimitType.privilegeWeek, weekCnt, collectWeekInfo.add_cnt
  end
  return nil, 0, 0
end
function store_limit_buy_manager:GetCollectPrivilegeLimitInfoByShopID(shopID)
  if not self.materialPackLimitInfo then
    return nil
  end
  if not next(self.materialPackLimitInfo) then
    return nil
  end
  local dayInfo = self.materialPackLimitInfo.daily_limit_info[shopID]
  local weekInfo = self.materialPackLimitInfo.week_limit_info[shopID]
  return dayInfo, weekInfo
end
function store_limit_buy_manager:GetRPPlusPrivilege(shopID)
  local Gifts_Const = require("client.slua.logic.specialoffer.special_offer_gifts_const")
  local rpPlusDayInfo, rpPlusWeekInfo = self:GetRPPlusPrivilegeLimitInfoByShopID(shopID)
  if rpPlusDayInfo then
    local dayCnt = rpPlusDayInfo.add_cnt - rpPlusDayInfo.buy_cnt
    return Gifts_Const.Enum_LimitType.rpPlusDaily, dayCnt, rpPlusDayInfo.add_cnt
  end
  if rpPlusWeekInfo then
    local weekCnt = rpPlusWeekInfo.add_cnt - rpPlusWeekInfo.buy_cnt
    return Gifts_Const.Enum_LimitType.rpPlusWeek, weekCnt, rpPlusWeekInfo.add_cnt
  end
  return nil, 0, 0
end
function store_limit_buy_manager:GetRPPlusPrivilegeLimitInfoByShopID(shopID)
  if not (not (UnknowPassSystem.Season <= 49) and self.rpPlusLimitInfo) or not next(self.rpPlusLimitInfo) then
    return nil
  end
  local dayInfo = self.rpPlusLimitInfo.daily_limit_info[shopID]
  local weekInfo = self.rpPlusLimitInfo.week_limit_info[shopID]
  return dayInfo, weekInfo
end
function store_limit_buy_manager:GetLocalRPPlusPrivilegeLimitInfoByShopID(shopID)
  local tbName = self:GetTBName("RPPrivilegeLimitCfg")
  local cfg = CDataTable.GetTableData(tbName, shopID)
  if not cfg then
    return 0, 0
  end
  return cfg.DayTimes, cfg.WeekTimes
end
function store_limit_buy_manager:GetTBName(name)
  if not isJK then
    return name
  else
    return name .. "JK"
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, store_limit_buy_manager)
return CModuleTemplate