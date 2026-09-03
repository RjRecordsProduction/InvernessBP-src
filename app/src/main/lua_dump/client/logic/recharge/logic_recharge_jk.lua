local logic_recharge_jk = {
  IsRegisEvent = false,
  bFromAct = false,
  isShowing = false,
  bHasInit = false,
  productId_buynum_array = {},
  productId_str = "",
  isConfigRecharge = false,
  zoneId = 1,
  country = "US",
  monetaryUint = "USD",
  bIsHideFirstCharge = false,
  bIsFirstChargeShowing = false,
  tDataList = {},
  tPayNumList = {},
  tPayPresentList = {},
  tMoneyList = {},
  tMoneyKeyList = {},
  isLoadingMP = false,
  isLoadingProductInfo = false,
  isLoadMiadsMP = false,
  timer_hidetip = nil,
  limited_special_list = {}
}
local StringUtil = require("common.string_util")
local recharge_macro = require("client.logic.recharge.recharge_macro")
function logic_recharge_jk.RegisterRechargeEvent()
  EventSystem:registEvent(EVENTTYPE_CENTAURI_NOTIFY, EVENTID_CENTAURI_PAY_NOTIFY, logic_recharge_jk.CentauriPayBackEventHandler)
  EventSystem:registEvent(EVENTTYPE_CENTAURI_NOTIFY, EVENTID_CENTAURI_GETMPINFO_NOTIFY, logic_recharge_jk.CentauriMPEventHandler)
  EventSystem:registEvent(EVENTTYPE_CENTAURI_NOTIFY, EVENTID_CENTAURI_GET_RECHARGE_PRODUCT_INFO_NOTIFY, logic_recharge_jk.CentauriProductEventHandler)
end
function logic_recharge_jk.UnRegisterRechargeEvent()
  EventSystem:unregistEvent(EVENTTYPE_CENTAURI_NOTIFY, EVENTID_CENTAURI_PAY_NOTIFY, logic_recharge_jk.CentauriPayBackEventHandler)
  EventSystem:unregistEvent(EVENTTYPE_CENTAURI_NOTIFY, EVENTID_CENTAURI_GETMPINFO_NOTIFY, logic_recharge_jk.CentauriMPEventHandler)
  EventSystem:unregistEvent(EVENTTYPE_CENTAURI_NOTIFY, EVENTID_CENTAURI_GET_RECHARGE_PRODUCT_INFO_NOTIFY, logic_recharge_jk.CentauriProductEventHandler)
end
function logic_recharge_jk.EnterRechargeUI(fromAct)
  local gem_report_utils = require("client.logic.store.gem_report_utils")
  logic_recharge_jk.bFromAct = fromAct
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  gem_report_utils.ReportBtnClickEvent(gem_report_utils.SubEventName_ShowRecharge, login_module.sIpRegion, Client.GetCurrentLanguage())
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  local E_UcEntryType = require("client.logic.recharge.logic_recharge")
  if E_UcEntryType.EnterFrom == E_UcEntryType.E_UcEntryType.FromUC then
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.ShowRechargeUC)
  elseif E_UcEntryType.EnterFrom == E_UcEntryType.E_UcEntryType.FromLobbyUC then
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.ShowRechargeLobbyUC)
  end
  E_UcEntryType.EnterFrom = -1
  if IsWoWEditor then
    return
  end
  if not LobbySystem.CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_ENCHARGE) then
    return
  end
  local special_offer_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.special_offer_module)
  special_offer_module:OpenRecharge()
end
function logic_recharge_jk.InitializeTableData()
  if not GlobalData.IsJapanOrKorea() then
    return
  end
  if logic_recharge_jk.bHasInit then
    return
  end
  logic_recharge_jk.bHasInit = true
  local tableData = FuncUtil.GetRechargeLevelTable()
  local dataList = {}
  for _, v in pairs(tableData) do
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
      table.insert(dataList, itemInfo)
      logic_recharge_jk.productId_buynum_array[v.rechargeKey] = v.buyNum
      if logic_recharge_jk.productId_str == "" then
        logic_recharge_jk.productId_str = v.rechargeKey
      else
        logic_recharge_jk.productId_str = logic_recharge_jk.productId_str .. "," .. v.rechargeKey
      end
      if logic_recharge_jk.isConfigRecharge == false then
        logic_recharge_jk.isConfigRecharge = true
        logic_recharge_jk.zoneId = v.zoneId
        logic_recharge_jk.country = v.country
        logic_recharge_jk.monetaryUint = v.monetaryUint
      end
    end
  end
  table.sort(dataList, function(a, b)
    return a.rechargeId < b.rechargeId
  end)
  logic_recharge_jk.tDataList = dataList
end
function logic_recharge_jk.OnCentauriFirstPay()
  local StatManager = import("StatManager")
  StatManager.GetInstance():ReportEventWithNoParam(16, true)
end
function logic_recharge_jk.OnCentauriPay(sPayChannel)
  sPayChannel = sPayChannel or ""
  local recharge_macro = require("client.logic.recharge.recharge_macro")
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  local sTLogStr = recharge_macro.TLogRechargeType .. "," .. sPayChannel
  log(bWriteLog and " logic_recharge_jk.OnCentauriPay Pay Uc Success >>>> " .. sTLogStr)
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.RechargeSuccess, 0, sTLogStr, true)
  local StatManager = import("StatManager")
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local PublishRegion = Client.GetPublishRegion()
  if PublishRegion ~= PublishRegionMacros.BLUEHOLE and PublishRegion ~= PublishRegionMacros.KOREA and PublishRegion ~= PublishRegionMacros.JAPAN then
    StatManager.GetInstance():ReportEventWithNoParam(15, true)
  end
  StatManager.GetInstance():ReportEventWithNoParam(19, true)
end
function logic_recharge_jk.CentauriPayBackEventHandler(_, _, resultCode, sPayChannel)
  logic_connection_waiting:Hide(1)
  logic_recharge_jk.RemoveTimer(logic_recharge_jk.timer_hidetip)
  if resultCode == "0" or resultCode == 0 then
    if UIManager.IsUIShow(UIManager.UI_Config.ui_recharge_jk) then
      logic_recharge_jk.GetMPInfo()
    end
    logic_recharge_jk.OnCentauriPay(sPayChannel)
    if DataMgr.Recharge == 1 then
      logic_recharge_jk.OnCentauriFirstPay()
    end
    if logic_recharge_jk.bFromAct then
      local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
      tlog_report_utils.ReportTLogEvent(TLogEventDefine.ActJumpRechargeSuccess)
    end
  end
  EventSystem:postEvent(EVENTTYPE_RECHARGE, EVENTID_RECHARGE_GETDATA_SUCCESSED)
end
function logic_recharge_jk.CentauriMPEventHandler(_, _, CentauriRechargeCode)
  local temp_Recharge_PayPresentList = {}
  local temp_Recharge_PayNumList = {}
  if CentauriManager.getMPResultCode == "0" or CentauriManager.getMPResultCode == 0 then
    if string.len(CentauriManager.present_level) <= 2 then
      return
    end
    local tempStr = string.sub(CentauriManager.present_level, 2, string.len(CentauriManager.present_level) - 1)
    log(bWriteLog and CentauriManager.present_level .. "  self cast CentauriManager.present_level to  :  " .. tempStr)
    local args = StringUtil.Split(tempStr, ",")
    for i, v in ipairs(args) do
      local mod = math.fmod(i, 2)
      if mod == 0 then
        table.insert(temp_Recharge_PayPresentList, tonumber(v))
      else
        table.insert(temp_Recharge_PayNumList, tonumber(v))
      end
    end
    logic_recharge_jk.tPayNumList = temp_Recharge_PayNumList
    logic_recharge_jk.tPayPresentList = temp_Recharge_PayPresentList
    EventSystem:postEvent(EVENTTYPE_RECHARGE, EVENTID_RECHARGE_UPDATE_MP_INFO)
  end
  if UIManager.IsUIShow(UIManager.UI_Config.ui_recharge_jk) then
    logic_recharge_jk.isLoadingMP = false
    if logic_recharge_jk.isLoadingProductInfo == false then
      EventSystem:postEvent(EVENTTYPE_RECHARGE, EVENTID_RECHARGE_GETDATA_SUCCESSED)
      logic_recharge_jk.RemoveTimer(logic_recharge_jk.timer_hidetip)
    end
  end
end
function logic_recharge_jk.CentauriProductEventHandler(_, _, resultTable)
  local success = false
  if resultTable ~= nil then
    local temp_Recharge_MoneyKeyList = {}
    local temp_Recharge_MoneyList = {}
    for k, product in pairs(resultTable) do
      if product ~= nil then
        success = true
        if product.productId ~= nil and product.price ~= nil then
          local productNum = logic_recharge_jk.productId_buynum_array[tostring(product.productId)]
          if productNum ~= nil then
            table.insert(temp_Recharge_MoneyKeyList, productNum)
            table.insert(temp_Recharge_MoneyList, tostring(product.price))
          end
        end
      end
    end
    logic_recharge_jk.tMoneyKeyList = temp_Recharge_MoneyKeyList
    logic_recharge_jk.tMoneyList = temp_Recharge_MoneyList
    if success == true then
      EventSystem:postEvent(EVENTTYPE_RECHARGE, EVENTID_RECHARGE_UPDATE_PRODUCT_INFO)
      logic_recharge_jk.RemoveTimer(logic_recharge_jk.timer_hidetip)
    end
  end
  if UIManager.IsUIShow(UIManager.UI_Config.ui_recharge_jk) then
    logic_recharge_jk.isLoadingProductInfo = false
    if logic_recharge_jk.isLoadingMP == false then
      EventSystem:postEvent(EVENTTYPE_RECHARGE, EVENTID_RECHARGE_GETDATA_SUCCESSED)
    end
  end
end
function logic_recharge_jk.OnModePostSwitch(preState, nextState)
  if nextState == GameStatus.Lobby then
    if logic_recharge_jk.isLoadMiadsMP == false then
      logic_recharge_jk.isLoadMiadsMP = true
    end
    if not logic_recharge_jk.IsRegisEvent then
      logic_recharge_jk.IsRegisEvent = true
      logic_recharge_jk.RegisterRechargeEvent()
    end
  else
    if nextState == GameStatus.Login then
      logic_recharge_jk.ResetData()
    end
    if not GameStatus.IsInMainCity() then
      logic_recharge_jk.ClearAllTimer()
    end
  end
end
function logic_recharge_jk.ClearAllTimer()
  logic_recharge_jk.RemoveTimer(logic_recharge_jk.timer_hidetip)
  logic_recharge_jk.RemoveTimer(logic_recharge_jk.timer_getinfo)
end
function logic_recharge_jk.SetIsHideFirstCharge(bIsHide)
  logic_recharge_jk.bIsHideFirstCharge = bIsHide
end
function logic_recharge_jk.GetIsHideFirstCharge()
  return logic_recharge_jk.bIsHideFirstCharge
end
function logic_recharge_jk.GetFirstChargeShowingState()
  return logic_recharge_jk.bIsFirstChargeShowing
end
function logic_recharge_jk.UpdateFirstChargeShowingState(bIsShowing)
  logic_recharge_jk.bIsFirstChargeShowing = bIsShowing
end
function logic_recharge_jk.ResetData()
  logic_recharge_jk.bIsHideFirstCharge = false
  logic_recharge_jk.bIsFirstChargeShowing = false
  logic_recharge_jk.UnRegisterRechargeEvent()
end
function logic_recharge_jk.GetMPInfo()
  local time_ticker = require("common.time_ticker")
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if not DevicePlatformNameMacros.IsPC() then
    logic_connection_waiting:Show(1)
    logic_recharge_jk.RemoveTimer(logic_recharge_jk.timer_hidetip)
    logic_recharge_jk.timer_hidetip = time_ticker.AddTimerOnce(5, function()
      logic_connection_waiting:Hide(1)
    end)
  end
  logic_recharge_jk.RemoveTimer(logic_recharge_jk.timer_getinfo)
  logic_recharge_jk.timer_getinfo = time_ticker.AddTimerOnce(0.1, function()
    logic_recharge_jk.InitializeTableData()
    logic_recharge_jk.isLoadingMP = true
    local logic_payment_api = require("client.logic.pay.logic_payment_api")
    logic_payment_api:load_Centauri_mp(logic_recharge_jk.country, logic_recharge_jk.monetaryUint)
  end)
end
function logic_recharge_jk.RemoveTimer(timer)
  if timer then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(timer)
    timer = nil
  end
end
function logic_recharge_jk.AskForJPLaw()
  UIManager.ShowUI(UIManager.UI_Config.Subscribed_Policy_Popup_JK_UIBP)
end
function logic_recharge_jk.GetSubscribeSubTabData()
  if logic_recharge_jk.subscribeSubTabList then
    return logic_recharge_jk.subscribeSubTabList
  end
  logic_recharge_jk.subscribeSubTabList = {}
  for k, _ in pairs(recharge_macro.SubscribeSubTabDataConfig) do
    local tCfg = recharge_macro.SubscribeSubTabDataConfig[k]
    local tab_info = {
      sub_tab_id = k,
      text = LocUtil.GetLocalizeResStr(tCfg.NameId)
    }
    table.insert(logic_recharge_jk.subscribeSubTabList, tab_info)
  end
  table.sort(logic_recharge_jk.subscribeSubTabList, function(a, b)
    return a.sub_tab_id < b.sub_tab_id
  end)
  return logic_recharge_jk.subscribeSubTabList
end
function logic_recharge_jk.IsSubTabExist(tabData)
  if not tabData then
    return
  end
  if tabData.HaveSubTab then
    return true
  end
  if tabData.HaveSubTabFunc and tabData.HaveSubTabFunc() then
    return true
  end
  return false
end
function logic_recharge_jk.IsCanShowPurchaseTab()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  local AOSSHOPMacros = require("client.slua.config.ClientMacros.AOSSHOPMacros")
  if Client.GetAOSSHOP() == AOSSHOPMacros.Samsung and Client.GetDevicePlatformName() == DevicePlatformNameMacros.Android then
    return false
  end
  if GlobalData.IsJapanOrKorea() then
    local region = FuncUtil.GetAccountRegionForBP()
    local AccountRegionForBPMacros = require("client.slua.config.ClientMacros.AccountRegionForBPMacros")
    if region ~= AccountRegionForBPMacros.JP then
    end
    return true
  end
  return false
end
function logic_recharge_jk.IsCanShowLimitJk()
  if not GlobalData.IsJapanOrKorea() then
    return false
  end
  local RechargePurchaseSystem = require("client.logic.recharge.logic_recharge_purchase")
  if not next(RechargePurchaseSystem.limitedPaks) then
    return false
  end
  return true
end
function logic_recharge_jk.CloseRechargeJKUI()
  UIManager.CloseUI(UIManager.UI_Config.SpecialOffer_Main_UIBP)
end
function logic_recharge_jk.GetAwardListBySpecialId(special_Id)
  if not logic_recharge_jk.limited_special_list or not next(logic_recharge_jk.limited_special_list) then
    return
  end
  local data = logic_recharge_jk.limited_special_list[special_Id]
  if not data then
    return
  end
  local item_list = {}
  local crateItemID = CDataTable.GetTableData("ShopItem", data.shop_id).ItemID
  local item1 = {
    res_id = crateItemID,
    count = 1,
    valid_hours = 0
  }
  table.insert(item_list, item1)
  local item2 = {
    res_id = data.special_item_id,
    count = data.special_item_num,
    valid_hours = 0
  }
  table.insert(item_list, item2)
  return item_list
end
function logic_recharge_jk.GetChestData(itemList)
  local item_list = {}
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  if itemList and 0 < #itemList then
    for _, v in pairs(itemList) do
      local nItemId = v and v.res_id or 0
      local tItemCfg = CDataTable.GetTableData("Item", nItemId)
      if tItemCfg and tItemCfg.ItemType == ENUM_ITEM_TYPE.Starter_Pack then
        table.insert(item_list, v)
        break
      end
    end
  end
  return item_list
end
function logic_recharge_jk.GetTimeStrFromLimited_Special_Chest()
  if not logic_recharge_jk.limited_special_list or not next(logic_recharge_jk.limited_special_list) then
    return
  end
  local config
  for _, v in pairs(logic_recharge_jk.limited_special_list) do
    if v then
      config = v
      break
    end
  end
  if not config then
    return
  end
  local TimeUtil = require("client.common.time_util")
  local startTimeStr = TimeUtil.FormatTime_YMD(config and config.begin_time, true)
  local endTimeStr = TimeUtil.FormatTime_YMD(config and config.end_time, true)
  local timeStr = LocUtil.LocalizeResFormat(7545, startTimeStr, endTimeStr)
  return timeStr
end
return logic_recharge_jk