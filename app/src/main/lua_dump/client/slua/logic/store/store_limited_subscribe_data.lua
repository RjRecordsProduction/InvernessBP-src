local store_limited_subscribe_data = {}
local currentCount = 0
local maxCount = 50
function store_limited_subscribe_data:DefineAndResetData()
  self:ClearlimitedSubscribeData()
end
function store_limited_subscribe_data:OnLogOut()
  self.limitedSubscribeData = nil
  self.isOnLimitedSubscribePage = nil
  self.offerData = nil
  self.reddotList = nil
  self.RefreshSubscribePage = nil
  self.OfferShareShopIdList = nil
  self.bClearMallRedDot = false
  self.bClearSpecialOfferRedDot = false
  self.manuallyUnsubscribeList = nil
end
function store_limited_subscribe_data:ClearlimitedSubscribeData()
  self.limitedSubscribeData = {}
  self.isOnLimitedSubscribePage = false
  self.offerData = {}
  self.reddotList = {}
  self.RefreshSubscribePage = nil
  self.OfferShareShopIdList = nil
  self.bClearMallRedDot = false
  self.bClearSpecialOfferRedDot = false
  self.manuallyUnsubscribeList = nil
end
function store_limited_subscribe_data:ReceivedOfferData(datas)
  self:CreateTable(self.offerData)
  if datas and next(datas) then
    for k, v in pairs(datas) do
      self.offerData[k] = v
    end
  end
  self:CheckBubbleShow(false)
end
function store_limited_subscribe_data:ReqGiftData()
  local logic_special_offer_material = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_special_offer_material)
  local logic_special_offer_condition = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_special_offer_condition)
  if not logic_special_offer_material:CheckGiftData() or not logic_special_offer_condition:CheckGiftData() then
    logic_special_offer_material:GetMaterialGiftsDataReq()
    return false
  end
  return true
end
function store_limited_subscribe_data:ReceivedLimitedSubscribeData(datas, count)
  if not self.limitedSubscribeData or not next(self.limitedSubscribeData) then
    self.limitedSubscribeData = datas
    currentCount = count
    self:InitReddotList()
  end
end
function store_limited_subscribe_data:ReceivedTempLimitedSubscribeData(temp, data)
  self:CreateTable(self.limitedSubscribeData)
  if temp and data then
    self.limitedSubscribeData[temp] = data
  elseif temp and not data then
    self.limitedSubscribeData[temp] = self.offerData and self.offerData[temp] or nil
  end
  if temp and self.reddotList and self.reddotList[temp] and self:IsShopSoldOut(temp) then
    local TimeUtil = require("client.common.time_util")
    local serverTime = TimeUtil.GetServerTimeInSec()
    self.reddotList[temp] = {
      reddot = UEnums.SubscribeState.notsubscribe,
      time = serverTime
    }
    self:WriteNeedRedPointTabData()
  end
end
function store_limited_subscribe_data:MatchLimitedSubscribeData(shopId)
  if shopId and self.limitedSubscribeData and self.limitedSubscribeData[shopId] then
    return self.limitedSubscribeData[shopId]
  end
  local offer2Shop = self:JudgementOfferShareShopIdList(shopId)
  if offer2Shop ~= nil then
    return self.limitedSubscribeData[offer2Shop]
  end
  return nil
end
function store_limited_subscribe_data:SetLimitedSubscribeState(shopId, opType)
  self:CreateTable(self.limitedSubscribeData)
  if opType == 0 then
    self.limitedSubscribeData[shopId] = nil
    currentCount = currentCount - 1
    if self.reddotList and self.reddotList[shopId] then
      self.reddotList[shopId] = nil
      self:WriteNeedRedPointTabData()
      local store_reddot_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_reddot_manager)
      store_reddot_manager:RemoveLimitedShowRedDot(shopId)
    end
    ShowNotice(64348, true)
  else
    self:ReceivedTempLimitedSubscribeData(shopId)
    currentCount = currentCount + 1
    self:AddOrSubShopFromReddotList(shopId, true)
    ShowNotice(64349, true)
  end
  EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_SUBSCRIBE, shopId, opType == 1)
  self:CheckReddotShowStatus()
  EventSystem:postEvent(EVENTTYPE_STORE, EVENTID_STORE_SUBSCRIBE)
end
function store_limited_subscribe_data:IsAllowSubscribe()
  if currentCount >= maxCount then
    return false
  end
  return true
end
function store_limited_subscribe_data:AddOrSubShopFromReddotList(shopId, addOrSub)
  self:CreateTable(self.reddotList)
  shopId = self:JudgementOfferShareShopIdList(shopId) or shopId
  if addOrSub then
    self.reddotList[shopId] = {
      reddot = UEnums.SubscribeState.nextsubscribe,
      time = 0
    }
    self:SetLimitedSubscribeReddot()
  elseif not addOrSub and self.reddotList[shopId] then
    local TimeUtil = require("client.common.time_util")
    local serverTime = TimeUtil.GetServerTimeInSec()
    self.reddotList[shopId] = {
      reddot = UEnums.SubscribeState.notsubscribe,
      time = serverTime
    }
    local store_reddot_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_reddot_manager)
    store_reddot_manager:RemoveLimitedShowRedDot(shopId)
  end
  self:WriteNeedRedPointTabData()
end
function store_limited_subscribe_data:ManuallyUnsubscribeInit()
  self.manuallyUnsubscribeList = {}
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eManuallyUnsubscribeAuto)
  if data ~= nil then
    self.manuallyUnsubscribeList = data
  end
end
function store_limited_subscribe_data:HasManuallyUnsubscribe(shopId)
  if not self.manuallyUnsubscribeList then
    self:ManuallyUnsubscribeInit()
  end
  if self.manuallyUnsubscribeList[shopId] ~= nil then
    return self.manuallyUnsubscribeList[shopId]
  end
  return false
end
function store_limited_subscribe_data:SetManuallyUnsubscribe(shopId)
  if not self.manuallyUnsubscribeList then
    self:ManuallyUnsubscribeInit()
  end
  self.manuallyUnsubscribeList[shopId] = true
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(self.manuallyUnsubscribeList, PlayerPrefsSystem.ePlayerPrefsType.eManuallyUnsubscribeAuto)
end
function store_limited_subscribe_data:InitReddotList()
  self:CreateTable(self.reddotList)
  local reddots = self:ReadNeedRedPointTabData()
  if reddots and next(reddots) then
    local TimeUtil = require("client.common.time_util")
    local serverTime = TimeUtil.GetServerTimeInSec()
    for k, v in pairs(reddots) do
      if v.reddot == UEnums.SubscribeState.notsubscribe then
        if not TimeUtil.IsSameDay(v.time, serverTime) and serverTime > v.time then
          v.reddot = UEnums.SubscribeState.subscribe
        end
      elseif v.reddot == UEnums.SubscribeState.nextsubscribe then
        v.reddot = UEnums.SubscribeState.subscribe
        v.time = serverTime
      end
      self.reddotList[k] = v
    end
    self:CheckReddotShowStatus()
  else
    if self.limitedSubscribeData and next(self.limitedSubscribeData) then
      for k, v in pairs(self.limitedSubscribeData) do
        local limitData = v[StoreConst.label_item_index_buy_limit]
        local StoreUtils = require("client.slua.logic.store.utils.store_utils")
        local limitInfo = StoreUtils.GetBuyLimitData(limitData, k)
        if limitInfo and not limitInfo.isSoldOut and limitInfo.hasPurchaseNum < limitInfo.purchaseLimitNum then
          self.reddotList[k] = {
            reddot = UEnums.SubscribeState.subscribe,
            time = 0
          }
        end
      end
    end
    self:WriteNeedRedPointTabData()
  end
  self:SetLimitedSubscribeReddot()
  self:CheckBubbleShow(true)
end
function store_limited_subscribe_data:CheckReddotShowStatus()
  local bAllNotShow = true
  for k, v in pairs(self.reddotList) do
    if v.reddot ~= UEnums.SubscribeState.notsubscribe then
      bAllNotShow = false
      break
    end
  end
  self.bClearMallRedDot = bAllNotShow
  self.bClearSpecialOfferRedDot = bAllNotShow
end
function store_limited_subscribe_data:CheckBubbleShow(bIsMall)
  log(bWriteLog and string.format("store_limited_subscribe_data:CheckBubbleShow IsMall : %s ", tostring(bIsMall)))
  if self.reddotList and next(self.reddotList) then
    if bIsMall and not self.bClearMallRedDot then
      log(bWriteLog and "store_limited_subscribe_data:CheckBubbleShow Show Mall Bubble!")
      EventSystem:postEvent(EVENTTYPE_MALL, EVENTID_SUBSCRIBE_LOBBY_BUBBLE_UPDATE, true)
      if self:HaveSoldMaterialSpecialOffer() and not self.bClearSpecialOfferRedDot then
        log(bWriteLog and "store_limited_subscribe_data:CheckBubbleShow Show SpecialOffer Bubble!")
        EventSystem:postEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_SUBSCRIBE_LOBBY_BUBBLE_UPDATE, true)
      end
    elseif self:HaveSoldMaterialSpecialOffer() and not self.bClearSpecialOfferRedDot then
      log(bWriteLog and "store_limited_subscribe_data:CheckBubbleShow Show SpecialOffer Bubble!")
      EventSystem:postEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_SUBSCRIBE_LOBBY_BUBBLE_UPDATE, true)
    end
  end
end
function store_limited_subscribe_data:WriteNeedRedPointTabData()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(self.reddotList, PlayerPrefsSystem.ePlayerPrefsType.eLimitedSubscribeData)
end
function store_limited_subscribe_data:ReadNeedRedPointTabData()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local datas = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eLimitedSubscribeData)
  return datas
end
function store_limited_subscribe_data:MatchReddotList(shopId)
  shopId = self:JudgementOfferShareShopIdList(shopId) or shopId
  if shopId and self.reddotList and self.reddotList[shopId] then
    return self.reddotList[shopId].reddot == UEnums.SubscribeState.subscribe
  end
  return false
end
function store_limited_subscribe_data:SetLimitedSubscribeReddot()
  if not self.reddotList then
    return
  end
  local store_reddot_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_reddot_manager)
  store_reddot_manager:SetLimitedShowRedDotNum(self.reddotList)
end
function store_limited_subscribe_data:ClearReddot(isSubscribePage)
  log(bWriteLog and "store_limited_subscribe_data:ClearReddot isSubscribePage : " .. tostring(isSubscribePage))
  local bNeedPostSpecialOffer = false
  local bNeedPostMall = true
  if self.reddotList and next(self.reddotList) then
    for k, v in pairs(self.reddotList) do
      if isSubscribePage then
        self:AddOrSubShopFromReddotList(k, false)
        if self.offerData and self.offerData[k] then
          bNeedPostSpecialOffer = true
        end
      elseif not isSubscribePage then
        if self.offerData and self.offerData[k] then
          self:AddOrSubShopFromReddotList(k, false)
        else
          bNeedPostMall = false
        end
      end
    end
  end
  if isSubscribePage then
    log(bWriteLog and "store_limited_subscribe_data:ClearReddot Clear Mall Subscribe Bubble")
    self.bClearMallRedDot = true
    EventSystem:postEvent(EVENTTYPE_MALL, EVENTID_SUBSCRIBE_LOBBY_BUBBLE_UPDATE, false)
    if bNeedPostSpecialOffer then
      log(bWriteLog and "store_limited_subscribe_data:ClearReddot Clear SpeicalOffer Subscribe Bubble")
      self.bClearSpecialOfferRedDot = true
      EventSystem:postEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_SUBSCRIBE_LOBBY_BUBBLE_UPDATE, false)
    end
  else
    log(bWriteLog and "store_limited_subscribe_data:ClearReddot Clear SpeicalOffer Subscribe Bubble")
    self.bClearSpecialOfferRedDot = true
    EventSystem:postEvent(EVENTTYPE_SPECIAL_OFFER, EVENTID_SUBSCRIBE_LOBBY_BUBBLE_UPDATE, false)
    if bNeedPostMall then
      log(bWriteLog and "store_limited_subscribe_data:ClearReddot Clear Mall Subscribe Bubble")
      self.bClearMallRedDot = true
      EventSystem:postEvent(EVENTTYPE_MALL, EVENTID_SUBSCRIBE_LOBBY_BUBBLE_UPDATE, false)
    end
  end
end
function store_limited_subscribe_data:IsShopSoldOut(shopId)
  if self.offerData[shopId] then
    return self:IsSoldOut(self.offerData[shopId], shopId)
  end
  if self.limitedSubscribeData[shopId] then
    return self:IsSoldOut(self.limitedSubscribeData[shopId], shopId)
  end
  return false
end
function store_limited_subscribe_data:IsSoldOut(data, shopId)
  local limitData = data[StoreConst.label_item_index_buy_limit]
  local StoreUtils = require("client.slua.logic.store.utils.store_utils")
  local limitInfo = StoreUtils.GetBuyLimitData(limitData, shopId)
  if limitInfo and not limitInfo.isSoldOut and limitInfo.hasPurchaseNum < limitInfo.purchaseLimitNum then
    return false
  end
  return true
end
function store_limited_subscribe_data:HaveSoldMaterialSpecialOffer()
  if self.reddotList and next(self.reddotList) then
    for k, v in pairs(self.reddotList) do
      k = self:JudgementOfferShareShopIdList(k) or k
      if self:MatchReddotList(k) and self.offerData and self.offerData[k] and not self:IsSoldOut(self.offerData[k], k) then
        return true
      end
    end
  end
  return false
end
function store_limited_subscribe_data:HaveMaterialSpecialOffer()
  if self.reddotList and next(self.reddotList) then
    for k, v in pairs(self.reddotList) do
      k = self:JudgementOfferShareShopIdList(k) or k
      if self:MatchReddotList(k) and self.offerData and self.offerData[k] then
        return true
      end
    end
  end
  return false
end
function store_limited_subscribe_data:ShopOfferJudgement(shopId)
  if self.isOnLimitedSubscribePage and self.offerData and self.offerData[shopId] then
    return true
  end
  return false
end
function store_limited_subscribe_data:CreateTable(tab)
  tab = tab or {}
end
function store_limited_subscribe_data:JudgementOfferShareShopIdList(shopId)
  if not self.OfferShareShopIdList then
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    if PublishRegionMacros.IsJapanOrKorea() then
      self.OfferShareShopIdList = CDataTable.GetTable("MaterialGiftContentKJ")
    elseif PublishRegionMacros.IsBLUEHOLE() then
      self.OfferShareShopIdList = CDataTable.GetTable("MaterialGiftContentIN")
    else
      self.OfferShareShopIdList = CDataTable.GetTable("MaterialGiftContent")
    end
  end
  local id = 0
  if self.OfferShareShopIdList and self.OfferShareShopIdList[shopId] then
    id = self.OfferShareShopIdList[shopId].ShareLimitedShopId
  end
  if self.OfferShareShopIdList then
    for k, v in pairs(self.OfferShareShopIdList) do
      if v.ShareLimitedShopId == shopId then
        id = v.GoodsId
        break
      end
    end
  end
  if self.limitedSubscribeData[id] then
    return id
  end
  return nil
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Cstore_limited_subscribe_data = class(CModuleBase, nil, store_limited_subscribe_data)
return Cstore_limited_subscribe_data