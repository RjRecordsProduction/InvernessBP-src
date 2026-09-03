local AskForSystem = {
  Cadge_Data = {},
  AskForPackID = 0,
  AskForDirectPurchaseInfo = {},
  AskForProductInfo = {},
  CancelAskForLimit = false,
  nRPCardTLogType = 0
}
function AskForSystem.CachedCadgeData(Cadge_Data)
  if Cadge_Data then
    AskForSystem.  end
end
function AskForSystem.UpdateCachedCadgeDataStatus(nSerialNum, nStatus)
  if AskForSystem.Cadge_Data then
    for _, v in pairs(AskForSystem.Cadge_Data.history or {}) do
      if v.serial_num == nSerialNum then
        v.status = nStatus
        break
      end
    end
  end
end
function AskForSystem.GetCadgeData()
  return AskForSystem.Cadge_Data
end
function AskForSystem.GetRPCardTLogType()
  return AskForSystem.nRPCardTLogType
end
function AskForSystem.AskForRPCard(nItemId, nRPCardTLogType)
  if not nItemId then
    return
  end
  if AskForSystem.GetCurrentAskForInfo(nItemId) == nil then
    ShowNotice(7083)
    return
  end
  local Logic_ItemGiveAndAskConst = require("client.slua.logic.ItemGiveAndAsk.Logic_ItemGiveAndAskConst")
  local nGiveType = Logic_ItemGiveAndAskConst.Enum_GiveGiftType.RPCard
  local Logic_FriendGiftPopupShow = require("client.slua.logic.ItemGiveAndAsk.Logic_FriendGiftPopupShow")
  Logic_FriendGiftPopupShow.ShowOnlyFriendAskGift(nGiveType, nItemId)
  AskForSystem.end
function AskForSystem.SetAskForPackID(packID)
  AskForSystem.AskForPackID = packID
end
function AskForSystem.UpdateDirectPurchaseInfo()
  local MallSystem = require("client.logic.mall.logic_mall")
  local info = MallSystem.GetRewardPkgInfo()
  if info.item_id == AskForSystem.AskForPackID then
    info.productPriceDesc = info.configPrice
    AskForSystem.AskForDirectPurchaseInfo = DeepCopy(info)
    EventSystem:postEvent(EVENTTYPE_AskFor, EVENTID_ASKFOR_DIRECT_PURCHASE_INFO)
  else
    local time_ticker = require("common.time_ticker")
    time_ticker.AddTimerOnce(0, function()
      MallSystem.GetDirectPurchaseInfoReq(AskForSystem.AskForPackID)
    end)
  end
end
function AskForSystem.GetDirectPurchaseInfo()
  return AskForSystem.AskForDirectPurchaseInfo
end
function AskForSystem.OnGetDirectPurchaseInfo(eventType, eventID)
  local MallSystem = require("client.logic.mall.logic_mall")
  local info = MallSystem.GetRewardPkgInfo()
  if info.item_id == AskForSystem.AskForPackID then
    info.productPriceDesc = info.configPrice
    AskForSystem.AskForDirectPurchaseInfo = DeepCopy(info)
    EventSystem:postEvent(EVENTTYPE_AskFor, EVENTID_ASKFOR_DIRECT_PURCHASE_INFO)
  end
end
function AskForSystem.UpdateCentauriProductInfo()
  local directPurchaseInfo = AskForSystem.AskForDirectPurchaseInfo
  if not directPurchaseInfo then
    log_warning("[MHT]AskForSystem.UpdateCentauriProductInfo() directPurchaseInfo is nil!")
    return
  end
  local isProductInfoCached, cachedProductInfoList = CentauriManager.LoadCachedCentauriProductInfo(directPurchaseInfo.CentauriProductId)
  if isProductInfoCached == true then
    EventSystem:postEvent(EVENTTYPE_CENTAURI_NOTIFY, EVENTID_CENTAURI_GET_GOODS_PRODUCT_INFO_NOTIFY, cachedProductInfoList)
  else
    log(bWriteLog and "directPurchaseInfo.CentauriProductId" .. directPurchaseInfo.CentauriProductId)
    local time_ticker = require("common.time_ticker")
    time_ticker.AddTimerOnce(0, function()
      local logic_payment_api = require("client.logic.pay.logic_payment_api")
      logic_payment_api:load_Centauri_product_info(directPurchaseInfo.CentauriProductId)
    end)
  end
end
function AskForSystem.GetCentauriProductInfo()
  return AskForSystem.AskForProductInfo
end
function AskForSystem.OnGetCentauriProductInfo(eventType, eventID, resultTable)
  log(bWriteLog and "AskForSystem.OnGetCentauriProductInfo")
  log_tree("AskForSystem.OnGetCentauriProductInfo(eventType, eventID, resultTable)", resultTable)
  if resultTable == nil then
    log(bWriteLog and "\230\139\137\229\143\150\230\149\176\230\141\174\229\164\177\232\180\165")
    return
  end
  local product = resultTable[1]
  if not product then
    log_warning("product is nil!")
    return
  end
  if product.productId ~= nil and product.price ~= nil and product.productId == AskForSystem.AskForDirectPurchaseInfo.CentauriProductId then
    AskForSystem.AskForProductInfo = product
    EventSystem:postEvent(EVENTTYPE_AskFor, EVENTID_ASKFOR_CENTAURI_PRODUCT_INFO)
  end
end
function AskForSystem.GetCurrentAskForInfo(nItemId)
  local uCfg = CDataTable.GetTableDataByFilter("AskforCfg", "ItemID", nItemId)
  return uCfg
end
function AskForSystem.GetItemIdByCadgeId(cadge_id)
  local uAskCfg = CDataTable.GetTableData("AskforCfg", cadge_id)
  if not uAskCfg then
    return -1
  end
  return uAskCfg.ItemID
end
function AskForSystem.GetPriceByCadgeId(cadge_id)
  local uAskCfg = CDataTable.GetTableData("AskforCfg", cadge_id)
  if not uAskCfg then
    return -1
  end
  return uAskCfg.Price
end
function AskForSystem.GetPriceTypeByCadgeId(cadge_id)
  local uAskCfg = CDataTable.GetTableData("AskforCfg", cadge_id)
  if not uAskCfg then
    return -1
  end
  return uAskCfg.PriceType
end
function AskForSystem.CheckBeFriendTimeOK(create_time, limitTime)
  if create_time == nil or create_time <= 0 then
    return true
  end
  if limitTime <= 0 then
    return true
  end
  local TimeUtil = require("client.common.time_util")
  local now_time = TimeUtil.GetServerTimeInSec()
  local beFriendTime = now_time - create_time
  if beFriendTime <= 0 then
    return false
  end
  if limitTime <= beFriendTime then
    return true
  end
  return false
end
function AskForSystem.SortByIntimacyFunc(uidA, uidB)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local a = logic_profile:GetLocalProfile(uidA)
  local b = logic_profile:GetLocalProfile(uidB)
  if a == nil or b == nil then
    return false
  end
  if not FuncUtil.JudgeIsSameClient(uidA) then
    return false
  end
  if not FuncUtil.JudgeIsSameClient(uidB) then
    return true
  end
  local friendA = LogicFriend.GetFriendData(uidA)
  local friendB = LogicFriend.GetFriendData(uidB)
  if friendA.intimacy == friendB.intimacy then
    if a.lastOnlineTime == nil or b.lastOnlineTime == nil then
      return false
    end
    return a.lastOnlineTime > b.lastOnlineTime
  else
    return friendA.intimacy > friendB.intimacy
  end
end
local stop_timeout_timer = function()
  if AskForSystem.timeOutTimer then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(AskForSystem.timeOutTimer)
    AskForSystem.timeOutTimer = nil
  end
  logic_connection_waiting:Hide(0)
end
local set_timeout_timer = function(time)
  logic_connection_waiting:Show(0)
  local time_ticker = require("common.time_ticker")
  if AskForSystem.timeOutTimer then
    time_ticker.RemoveTimer(AskForSystem.timeOutTimer)
  end
  AskForSystem.timeOutTimer = time_ticker.AddTimerOnce(time, function()
    if GameStatus.IsInLobbyOrMainCity() then
      if Client.IsShipping() then
        ShowNotice(9910327)
      else
        local noticeStr = LocUtil.GetLocalizeResStr(9910327)
        ShowNotice(noticeStr)
      end
    end
    if AskForSystem.isDirectPurchaseCentauriReq then
      AskForSystem.DirectPurchaseEnd()
    end
    stop_timeout_timer()
  end)
end
function AskForSystem.DirectPurchaseEnd()
  AskForSystem.isDirectPurchaseCentauriReq = false
  AskForSystem.cache_key = ""
end
function AskForSystem.OnDirectPurchase(eventType, eventID, cache_key, direct_itemid)
  if not AskForSystem.isDirectPurchaseCentauriReq then
    return
  end
  AskForSystem.  local info = AskForSystem.directPurchaseInfo
  if not info then
    return
  end
  if info and info.item_id == direct_itemid then
    stop_timeout_timer()
    log(bWriteLog and "Client.CentauriGoodsPresent" .. " CentauriProductId: " .. info.CentauriProductId .. " CentauriPayItem: " .. info.CentauriPayItem .. " CentauriPrice: " .. info.CentauriPrice .. " CentauriCountry: " .. info.CentauriCountry .. " CentauriCurrency: " .. info.CentauriCurrency .. " cache_key: " .. AskForSystem.cache_key)
    local logic_payment_api = require("client.logic.pay.logic_payment_api")
    logic_payment_api:GoodsPresent(info.CentauriProductId, info.CentauriPayItem, info.CentauriPrice, info.CentauriCountry, info.CentauriCurrency, AskForSystem.cache_key)
  end
end
function AskForSystem.DirectPurchaseCentauriRsp(eventType, eventID, result, inner_code)
  if not AskForSystem.isDirectPurchaseCentauriReq then
    return
  end
  log(bWriteLog and "AskForSystem.DirectPurchaseCentauriRsp, result = " .. tostring(result) .. ", inner_code = " .. tostring(inner_code))
  local StoreHandler = require("client.network.Protocol.StoreHandler")
  StoreHandler.send_direct_buy_result_req(AskForSystem.cache_key, result, inner_code)
  if tostring(result) ~= "0" then
    AskForSystem.DirectPurchaseEnd()
  else
    set_timeout_timer(15)
  end
end
function AskForSystem.SendHandselReq(index, letter_style, msg, directPurchaseInfo)
  if directPurchaseInfo then
    AskForSystem.isDirectPurchaseCentauriReq = true
    AskForSystem.  end
  set_timeout_timer(15)
  local AskForHandler = require("client.network.Protocol.AskForHandler")
  AskForHandler.send_handsel_req(index, letter_style, msg, directPurchaseInfo)
end
function AskForSystem.OnHandselRsp(eventType, eventID, cadgeID)
  if AskForSystem.isDirectPurchaseCentauriReq then
    AskForSystem.DirectPurchaseEnd()
  end
  stop_timeout_timer()
end
return AskForSystem