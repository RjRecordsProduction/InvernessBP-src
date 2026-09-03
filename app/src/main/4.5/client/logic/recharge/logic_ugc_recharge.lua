local Logic_UGC_Recharge = {
  E_WOWEntryType = {
    Personal = 1,
    WOWPass = 2,
    Center = 3,
    PropShopInGame = 4,
    PropShopLobby = 5,
    Withdrawal = 6,
    Exchange = 7,
    WOWLobby = 8,
    WOWLobbyOld = 9,
    WOWInventory = 10,
    BoxJump = 11
  }
}
function Logic_UGC_Recharge:ctor()
  self.isInit = false
  self.recharge_DataList_Array = {}
  self.productId_BuyNum_Array = {}
  self.strProductId = ""
  self.isConfigRecharge = false
  self.zoneId = 1
  self.country = "US"
  self.monetaryUint = "USD"
  self.monetarySymbol = "UC$"
  self.recharge_MoneyKeyList = {}
  self.recharge_MoneyList = {}
  self.recharge_PayNumList_Array = {}
  self.recharge_PayPresentList_Array = {}
  self.timer_hidetip = nil
  self.isLoadingProductInfo = false
  self.isLoadingMP = false
  self.buy_PosForSave = ""
  self.EnterFrom = nil
end
local _UCIconShow = {
  [1] = {
    path = "/Game/UMG/Texture/Currency/WoWPass_Icon_Item_UC01.WoWPass_Icon_Item_UC01",
    min = 0,
    max = 60
  },
  [2] = {
    path = "/Game/UMG/Texture/Currency/WoWPass_Icon_Item_UC02.WoWPass_Icon_Item_UC02",
    min = 60,
    max = 180
  },
  [3] = {
    path = "/Game/UMG/Texture/Currency/WoWPass_Icon_Item_UC03.WoWPass_Icon_Item_UC03",
    min = 180,
    max = 300
  },
  [4] = {
    path = "/Game/UMG/Texture/Currency/WoWPass_Icon_Item_UC04.WoWPass_Icon_Item_UC04",
    min = 300,
    max = 600
  },
  [5] = {
    path = "/Game/UMG/Texture/Currency/WoWPass_Icon_Item_UC05.WoWPass_Icon_Item_UC05",
    min = 600,
    max = 1500
  },
  [6] = {
    path = "/Game/UMG/Texture/Currency/WoWPass_Icon_Item_UC06.WoWPass_Icon_Item_UC06",
    min = 1500,
    max = 3000
  },
  [7] = {
    path = "/Game/UMG/Texture/Currency/WoWPass_Icon_Item_UC07.WoWPass_Icon_Item_UC07",
    min = 3000,
    max = 6000
  },
  [8] = {
    path = "/Game/UMG/Texture/Currency/WoWPass_Icon_Item_UC08.WoWPass_Icon_Item_UC08",
    min = 6000,
    max = 99999999
  }
}
function Logic_UGC_Recharge:OnInitialize()
end
function Logic_UGC_Recharge:OnLogOut()
end
function Logic_UGC_Recharge:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_CENTAURI_NOTIFY, EVENTID_CENTAURI_PAY_NOTIFY, self.CentauriPayBackEventHandler, self)
  self:AddCommonEvent(EVENTTYPE_CENTAURI_NOTIFY, EVENTID_CENTAURI_GET_UGC_RECHARGE_PRODUCT_INFO_NOTIFY, self.CentauriProductEventHandler, self)
  self:AddCommonEvent(EVENTTYPE_CENTAURI_NOTIFY, EVENTID_CENTAURI_GETMPINFO_NOTIFY, self.CentauriMPEventHandler, self)
end
function Logic_UGC_Recharge:OnPostSwitchGameStatus(preState, nextState)
  if nextState == GameStatus.Login then
    self:ResetData()
  end
end
function Logic_UGC_Recharge:OpenRechargeUI(fromAct, bIsOpenH5)
  local audio_util = require("client.common.audio_util")
  audio_util.PlayAudio(sound_config.new_UC)
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() then
    local Logic_UGC_JK_Recharge = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_jk_recharge)
    Logic_UGC_JK_Recharge:EnterRechargeUI(fromAct)
  else
    self:EnterRechargeUI(bIsOpenH5)
  end
end
function Logic_UGC_Recharge:CanShowRecharge()
  if IsWoWEditor then
    return false
  end
  local logic_multiple_area = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_multiple_area)
  if not logic_multiple_area:IsPaymentSupport() then
    log(bWriteLog and "Logic_UGC_Recharge.EnterRechargeUI payment not support for current area")
    logic_multiple_area:ShowPaymentNotSupportNotice()
    return false
  end
  if not LobbySystem.CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_ENCHARGE) then
    log(bWriteLog and " Logic_UGC_Recharge.EnterRechargeUI BP_ENUM_LOBBY_MENU_ENCHARGE LobbyMenu not Open")
    return false
  end
  if not LobbySystem.CheckOpen(BP_ENUM_UGC_RECHARGE) then
    return
  end
  return true
end
function Logic_UGC_Recharge:EnterRechargeUI(bIsOpenH5)
  if not self:CanShowRecharge() then
    return
  end
  local RechargeSystem = require("client.logic.recharge.logic_recharge")
  RechargeSystem.ip_region_check_req()
  local special_offer_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.special_offer_module)
  special_offer_module:OpenUGCRecharge()
  if bIsOpenH5 and RechargeSystem.bIsShowH5Pay and CentauriManager.H5PayEnable() then
    local logic_payment_api = require("client.logic.pay.logic_payment_api")
    logic_payment_api:H5Pay("", true)
  end
end
function Logic_UGC_Recharge:GetRechargeData()
  self:InitializeTableData()
  return self.recharge_DataList_Array
end
function Logic_UGC_Recharge:InitializeTableData()
  if self.isInit == false then
    self.isInit = true
    local tabledata
    tabledata = FuncUtil.GetRechargeLevelTable(true)
    tabledata = CentauriManager.ProcessSpecialDisplaySettingUGC(tabledata)
    local temp_Recharge_DataList = {}
    for i, v in pairs(tabledata) do
      if v.visible > 0 then
        local itemInfo = {
          rechargeId = v.rechargeId,
          zoneId = v.zoneId,
          rechargeKey = v.rechargeKey,
          name = v.name,
          buyNum = v.buyNum,
          money = v.money,
          monetaryUint = v.monetaryUint,
          monetarySymbol = v.monetarySymbol,
          icon = v.iconURL,
          country = v.country
        }
        table.insert(temp_Recharge_DataList, itemInfo)
        self.productId_BuyNum_Array[v.rechargeKey] = v.buyNum
        if self.strProductId == "" then
          self.strProductId = v.rechargeKey
        else
          self.strProductId = self.strProductId .. "," .. v.rechargeKey
        end
        if self.isConfigRecharge == false then
          self.isConfigRecharge = true
          self.zoneId = v.zoneId
          self.country = v.country
          self.monetaryUint = v.monetaryUint
          self.monetarySymbol = v.monetarySymbol
        end
      end
    end
    if temp_Recharge_DataList and 0 < #temp_Recharge_DataList then
      table.sort(temp_Recharge_DataList, function(a, b)
        return a.buyNum < b.buyNum
      end)
    end
    self.recharge_DataList_Array = temp_Recharge_DataList
  end
end
function Logic_UGC_Recharge:CentauriPayBackEventHandler(evenType, eventID, result_code, sPayChannel)
  logic_connection_waiting:Hide(1)
  self:RemoveTimer(self.timer_hidetip)
  if result_code == "0" or result_code == 0 then
    local RechargeSystem = require("client.logic.recharge.logic_recharge")
    if RechargeSystem.isRechargeUIShowing() then
      self:GetMPInfo()
    end
    self:OnCentauriPay(sPayChannel)
  end
  EventSystem:postEvent(EVENTTYPE_RECHARGE, EVENTID_RECHARGE_GETDATA_SUCCESSED)
end
function Logic_UGC_Recharge:OnCentauriPay(sPayChannel)
  sPayChannel = sPayChannel or ""
  local TimeUtil = require("client.common.time_util")
  local str = string.format("uid=%s&time=%d&payChannel=%s", DataMgr.roleData.uid, TimeUtil.GetServerTimeInSec(), sPayChannel)
  local UGCTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.UGCTLogReport)
  UGCTLogReport:ReportDelay(TLogEventDefine.UGC_WOWCoin_Recharge_CallBack, 0, str)
  local StatManager = import("StatManager")
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local PublishRegion = Client.GetPublishRegion()
  if PublishRegion ~= PublishRegionMacros.BLUEHOLE and PublishRegion ~= PublishRegionMacros.KOREA and PublishRegion ~= PublishRegionMacros.JAPAN then
    StatManager.GetInstance():ReportEventWithNoParam(15, true)
  end
  StatManager.GetInstance():ReportEventWithNoParam(19, true)
end
function Logic_UGC_Recharge:GetMPInfo()
  local time_ticker = require("common.time_ticker")
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if not DevicePlatformNameMacros.IsPC() then
    logic_connection_waiting:Show(1)
    self:RemoveTimer(self.timer_hidetip)
    self.timer_hidetip = time_ticker.AddTimerOnce(5, function()
      logic_connection_waiting:Hide(1)
    end)
  end
  self:RemoveTimer(self.timer_getinfo)
  self.timer_getinfo = time_ticker.AddTimerOnce(0.1, function()
    self:InitializeTableData()
    self.isLoadingMP = true
    local logic_payment_api = require("client.logic.pay.logic_payment_api")
    logic_payment_api:load_Centauri_mp(self.country, self.monetaryUint, true)
  end)
end
function Logic_UGC_Recharge:CentauriProductEventHandler(evenType, eventID, resultTable)
  log_tree(bWriteLog and "Logic_UGC_Recharge:CentauriProductEventHandle resultTable = ", resultTable)
  local success = false
  if resultTable ~= nil then
    local temp_Recharge_MoneyKeyList = {}
    local temp_Recharge_MoneyList = {}
    for k, product in pairs(resultTable) do
      if product ~= nil then
        success = true
        if product.productId ~= nil and product.price ~= nil then
          local productNum = self.productId_BuyNum_Array[tostring(product.productId)]
          if productNum ~= nil then
            table.insert(temp_Recharge_MoneyKeyList, productNum)
            table.insert(temp_Recharge_MoneyList, tostring(product.price))
          end
        end
      end
    end
    self.recharge_MoneyKeyList = temp_Recharge_MoneyKeyList
    self.recharge_MoneyList = temp_Recharge_MoneyList
    log_tree(bWriteLog and "Logic_UGC_Recharge:CentauriProductEventHandler self.recharge_MoneyKeyList = ", self.recharge_MoneyKeyList)
    log_tree(bWriteLog and "Logic_UGC_Recharge:CentauriProductEventHandler self.recharge_MoneyList = ", self.recharge_MoneyList)
    if success then
      EventSystem:postEvent(EVENTTYPE_RECHARGE, EVENTID_RECHARGE_UPDATE_PRODUCT_INFO)
      self:RemoveTimer(self.timer_hidetip)
    end
  end
  local RechargeSystem = require("client.logic.recharge.logic_recharge")
  if RechargeSystem.isRechargeUIShowing() then
    self.isLoadingProductInfo = false
    if self.isLoadingMP == false then
      EventSystem:postEvent(EVENTTYPE_RECHARGE, EVENTID_RECHARGE_GETDATA_SUCCESSED)
    end
  end
end
function Logic_UGC_Recharge:CentauriMPEventHandler(evenType, eventID, Centauri_recharge_code)
  local temp_Recharge_PayPresentList = {}
  local temp_Recharge_PayNumList = {}
  local mpCache = CentauriManager.GetMPCache(true)
  if mpCache.resultCode == "0" or mpCache.resultCode == 0 then
    if string.len(mpCache.presentLevel) <= 2 then
      return
    end
    local StringUtil = require("common.string_util")
    local tempStr = string.sub(mpCache.presentLevel, 2, string.len(mpCache.presentLevel) - 1)
    log(bWriteLog and mpCache.presentLevel .. " Logic_UGC_Recharge:CentauriMPEventHandler rechargeUI cast mpCache.presentLevel to  :  " .. tempStr)
    local args = StringUtil.Split(tempStr, ",")
    for i, v in ipairs(args) do
      local mod = math.fmod(i, 2)
      if mod == 0 then
        table.insert(temp_Recharge_PayPresentList, tonumber(v))
      else
        table.insert(temp_Recharge_PayNumList, tonumber(v))
      end
    end
    self.recharge_PayPresentList_Array = temp_Recharge_PayPresentList
    self.recharge_PayNumList_Array = temp_Recharge_PayNumList
    EventSystem:postEvent(EVENTTYPE_RECHARGE, EVENTID_RECHARGE_UPDATE_MP_INFO)
  end
  local RechargeSystem = require("client.logic.recharge.logic_recharge")
  if RechargeSystem.isRechargeUIShowing() then
    self.isLoadingMP = false
    if self.isLoadingProductInfo == false then
      EventSystem:postEvent(EVENTTYPE_RECHARGE, EVENTID_RECHARGE_GETDATA_SUCCESSED)
      self:RemoveTimer(self.timer_hidetip)
    end
  end
end
function Logic_UGC_Recharge:RemoveTimer(timer)
  if timer then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(timer)
    timer = nil
  end
end
function Logic_UGC_Recharge:ResetData()
  log(bWriteLog and "Logic_UGC_Recharge:ResetData")
  self.isInit = false
  self.recharge_DataList_Array = {}
  self.productId_BuyNum_Array = {}
  self.strProductId = ""
  self.isConfigRecharge = false
end
function Logic_UGC_Recharge:Pay(recharge_info)
  local AccountAnchorModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.AccountAnchorModule)
  if not AccountAnchorModule:CanRecharge() then
    ShowNotice(77737)
    return
  end
  local strRegion = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if strRegion == PublishRegionMacros.JAPAN then
    local need_set_age = false
    if DataMgr.jp_age == nil then
      need_set_age = true
      local GdprSystem = require("client.slua.logic.gdpr.logic_gdpr")
      GdprSystem.ShowFirstBuy()
    end
    log(bWriteLog and "Logic_UGC_Recharge:Pay EventRechargeGetJPAge, BP_Recharge_Need_Set_Age=" .. tostring(need_set_age) .. " DataMgr.jp_age=" .. tostring(DataMgr.jp_age))
  end
  self.buy_PosForSave = recharge_info.buyNum
  local TimeUtil = require("client.common.time_util")
  local str = string.format("uid=%s&time=%d&rechargeKey=%s&buyNum=%s&monetaryUint=%s", DataMgr.roleData.uid, TimeUtil.GetServerTimeInSec(), recharge_info.rechargeKey, recharge_info.buyNum, recharge_info.monetaryUint)
  local UGCTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.UGCTLogReport)
  UGCTLogReport:ReportDelay(TLogEventDefine.UGC_WOWCoin_Pay_Btn, 0, str)
  local logic_payment_api = require("client.logic.pay.logic_payment_api")
  logic_payment_api:Pay(recharge_info.rechargeKey, tonumber(recharge_info.buyNum), recharge_info.country, recharge_info.monetaryUint, true)
  EventSystem:postEvent(EVENTTYPE_RECHARGE, EVENTID_RECHARGE_REQ_BUY_ITEM)
end
function Logic_UGC_Recharge:GetGiveCountByBuyWOWCount(nUCCount)
  nUCCount = tonumber(nUCCount)
  local nGiveTicketIndex = -1
  local index = 0
  if self.recharge_PayNumList_Array ~= nil then
    for k, v in pairs(self.recharge_PayNumList_Array) do
      index = index + 1
      if v == nUCCount then
        nGiveTicketIndex = index
      end
    end
  end
  local nGiveTicketCount = 0
  index = 0
  if 0 <= nGiveTicketIndex and self.recharge_PayPresentList_Array ~= nil then
    for k, v in pairs(self.recharge_PayPresentList_Array) do
      index = index + 1
      if index == nGiveTicketIndex then
        nGiveTicketCount = v
      end
    end
  end
  log(bWriteLog and "Logic_UGC_Recharge:GetGiveCountByBuyUCCount, nGiveTicketCount=" .. tostring(nGiveTicketCount))
  return nGiveTicketCount
end
function Logic_UGC_Recharge:GetWOWIconByCount(nUcCount)
  for _, v in pairs(_UCIconShow) do
    if nUcCount > v.min and nUcCount <= v.max then
      return v.path
    end
  end
  return _UCIconShow[1].path
end
function Logic_UGC_Recharge:CheckWOWRecharge(productInfo)
  local is_wow = false
  log_tree(bWriteLog and "Logic_UGC_Recharge:CheckWOWRecharge, productInfo= ", productInfo)
  local recharge_DataList_Array = {}
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() then
    local Logic_UGC_JK_Recharge = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_jk_recharge)
    recharge_DataList_Array = Logic_UGC_JK_Recharge:GetDataList()
  else
    recharge_DataList_Array = self.recharge_DataList_Array
  end
  log_tree(bWriteLog and "Logic_UGC_Recharge:CheckWOWRecharge, recharge_DataList_Array= ", recharge_DataList_Array)
  local checkIsWOW = function(productId)
    if productId == nil then
      return false
    end
    for _, v in pairs(recharge_DataList_Array) do
      if v.rechargeKey == productId then
        return true
      end
    end
    return false
  end
  for _, v in pairs(productInfo) do
    if checkIsWOW(v.productId) then
      is_wow = true
      break
    end
  end
  log(bWriteLog and "Logic_UGC_Recharge:CheckWOWRecharge, is_wow=" .. tostring(is_wow))
  return is_wow
end
function Logic_UGC_Recharge:CheckWOWRechargeByProductId(productId)
  if not productId then
    log(bWriteLog and "Logic_UGC_Recharge:CheckWOWRechargeByProductId, productId is nil")
    return false
  end
  log(bWriteLog and "Logic_UGC_Recharge:CheckWOWRechargeByProductId, productId=" .. tostring(productId))
  local recharge_DataList_Array = {}
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() then
    local Logic_UGC_JK_Recharge = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_jk_recharge)
    recharge_DataList_Array = Logic_UGC_JK_Recharge:GetDataList()
  else
    recharge_DataList_Array = self.recharge_DataList_Array
  end
  log_tree(bWriteLog and "Logic_UGC_Recharge:CheckWOWRechargeByProductId, recharge_DataList_Array= ", recharge_DataList_Array)
  for _, v in pairs(recharge_DataList_Array) do
    if v.rechargeKey == productId then
      return true
    end
  end
  return false
end
function Logic_UGC_Recharge:GetStrProductId()
  return self.strProductId
end
function Logic_UGC_Recharge:GetRecharge_MoneyKeyList()
  return self.recharge_MoneyKeyList
end
function Logic_UGC_Recharge:GetRecharge_MoneyList()
  return self.recharge_MoneyList
end
function Logic_UGC_Recharge:GetRecharge_PayNumList_Array()
  return self.recharge_PayNumList_Array
end
function Logic_UGC_Recharge:GetRecharge_PayPresentList_Array()
  return self.recharge_PayPresentList_Array
end
function Logic_UGC_Recharge:SetLoadingProductInfo(isLoading)
  self.isLoadingProductInfo = isLoading
end
function Logic_UGC_Recharge:SetLoadingMpInfo(isLoading)
  self.isLoadingMP = isLoading
end
function Logic_UGC_Recharge:GetCountry()
  return self.country
end
function Logic_UGC_Recharge:GetMonetaryUint()
  return self.monetaryUint
end
function Logic_UGC_Recharge:GetRecharge_DataList_Array()
  return self.recharge_DataList_Array
end
function Logic_UGC_Recharge:SetEnterFrom(enterFrom)
  self.EnterFrom = enterFrom
end
function Logic_UGC_Recharge:GetEnterFrom()
  return self.EnterFrom
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogic_UGC_Recharge = class(CModuleBase, nil, Logic_UGC_Recharge)
return CLogic_UGC_Recharge