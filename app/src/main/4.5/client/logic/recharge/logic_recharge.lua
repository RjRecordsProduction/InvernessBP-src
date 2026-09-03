local RechargeSystem = {
  IsRegisEvent = false,
  buy_PosForSave = "",
  isInit = false,
  isLoadMiadsMP = false,
  isLoadingMP = false,
  isLoadingProductInfo = false,
  isConfigRecharge = false,
  isHideFirstCharge = false,
  isFirstChargeShowing = false,
  zoneId = 1,
  country = "US",
  monetaryUint = "USD",
  monetarySymbol = "UC$",
  productId_BuyNum_Array = {},
  recharge_DataList_Array = {},
  strProductId = "",
  recharge_PayNumList_Array = {},
  recharge_PayPresentList_Array = {},
  recharge_MoneyKeyList = {},
  recharge_MoneyList = {},
  timer_getinfo = nil,
  timer_hidetip = nil,
  isUIShowing = false,
  EnterFrom = -1,
  E_UcEntryType = {
    FromUC = 1,
    FromLobbyUC = 2,
    FromHomeStoreUC = 3,
    FromUGC = 4
  },
  Enum_ShowTag = {
    None = 0,
    SuperValue = 1,
    Hot = 2,
    FirstCharge = 3,
    FriendsPre = 4,
    LastCharge = 5,
    Comeback = 6
  },
  bIsShowH5Pay = false
}
local _nGMShowTagType = RechargeSystem.Enum_ShowTag.None
local _UCIconShow = {
  [1] = {
    path = "/Game/UMG/Texture/Currency/Icon_UC_01_int.Icon_UC_01_int",
    min = 0,
    max = 60
  },
  [2] = {
    path = "/Game/UMG/Texture/Currency/Icon_UC_02_int.Icon_UC_02_int",
    min = 60,
    max = 180
  },
  [3] = {
    path = "/Game/UMG/Texture/Currency/Icon_UC_03_int.Icon_UC_03_int",
    min = 180,
    max = 300
  },
  [4] = {
    path = "/Game/UMG/Texture/Currency/Icon_UC_04_int.Icon_UC_04_int",
    min = 300,
    max = 600
  },
  [5] = {
    path = "/Game/UMG/Texture/Currency/Icon_UC_05_int.Icon_UC_05_int",
    min = 600,
    max = 1500
  },
  [6] = {
    path = "/Game/UMG/Texture/Currency/Icon_UC_06_int.Icon_UC_06_int",
    min = 1500,
    max = 3000
  },
  [7] = {
    path = "/Game/UMG/Texture/Currency/Icon_UC_07_int.Icon_UC_07_int",
    min = 3000,
    max = 6000
  },
  [8] = {
    path = "/Game/UMG/Texture/Currency/Icon_UC_08_int.Icon_UC_08_int",
    min = 6000,
    max = 99999999
  }
}
function RechargeSystem.Enter()
end
function RechargeSystem.Release()
end
function RechargeSystem.OpenRechargeUI(fromAct, bIsOpenH5)
  if Client.IsMatchVersion and Client.IsMatchVersion() then
    local title = LocUtil.GetLocalizeResStr(101001)
    local text = LocUtil.GetLocalizeResStr(120001)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(1, title, text)
    return
  end
  local gem_report_utils = require("client.logic.store.gem_report_utils")
  local audio_util = require("client.common.audio_util")
  audio_util.PlayAudio(sound_config.new_UC)
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() then
    local RechargeSystemJK = require("client.logic.recharge.logic_recharge_jk")
    RechargeSystemJK.EnterRechargeUI(fromAct)
  else
    RechargeSystem.EnterRechargeUI(bIsOpenH5)
  end
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  gem_report_utils.ReportBtnClickEvent(gem_report_utils.SubEventName_ShowRecharge, login_module.sIpRegion, Client.GetCurrentLanguage())
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.ShowRecharge)
end
function RechargeSystem.CanShowRecharge()
  if IsWoWEditor then
    return false
  end
  local logic_multiple_area = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_multiple_area)
  if not logic_multiple_area:IsPaymentSupport() then
    log(bWriteLog and "RechargeSystem.EnterRechargeUI payment not support for current area")
    logic_multiple_area:ShowPaymentNotSupportNotice()
    return false
  end
  if not LobbySystem.CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_ENCHARGE) then
    log(bWriteLog and " RechargeSystem.EnterRechargeUI BP_ENUM_LOBBY_MENU_ENCHARGE LobbyMenu not Open")
    return false
  end
  return true
end
function RechargeSystem.EnterRechargeUI(bIsOpenH5)
  if not RechargeSystem.CanShowRecharge() then
    return
  end
  RechargeSystem.ip_region_check_req()
  local special_offer_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.special_offer_module)
  special_offer_module:OpenRecharge()
  if bIsOpenH5 and RechargeSystem.bIsShowH5Pay and CentauriManager.H5PayEnable() then
    local logic_payment_api = require("client.logic.pay.logic_payment_api")
    logic_payment_api:H5Pay("")
  end
end
function RechargeSystem.IsBlueHoleOfficialAVersion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local strRegion = Client.GetPublishRegion()
  local SubsideFeatureLevelMacros = require("client.slua.config.ClientMacros.SubsideFeatureLevelMacros")
  if strRegion == PublishRegionMacros.BLUEHOLE and Client.GetSubsideFeatureLevel() == SubsideFeatureLevelMacros.OfficialA then
    log(bWriteLog and "[muidarzhang] RechargeSystem.IsIndiaOfficialAVersion, true. ")
    return true
  else
    log(bWriteLog and "[muidarzhang] RechargeSystem.IsIndiaOfficialAVersion, false. ")
    return false
  end
end
function RechargeSystem.ip_region_check_req()
  log(bWriteLog and "[chub][ip_region_check_req]")
  local GlobalNetHandler = require("client.network.Protocol.GlobalNetHandler")
  GlobalNetHandler.send_ip_region_check_req()
end
function RechargeSystem.ip_region_check_res(err_code, err_msg)
  log(bWriteLog and "[chub][ip_region_check_res]: error_code = " .. tonumber(err_code) .. " err_msg = " .. tostring(err_msg))
  if err_code and err_code ~= 0 then
    log_warning("[chub][EVENTID_RECHARGE_CLOSE_BUTTON_MORE]")
    EventSystem:postEvent(EVENTTYPE_RECHARGE, EVENTID_RECHARGE_CLOSE_BUTTON_MORE)
  end
end
function RechargeSystem.OnJumpPurchaseUrl(eventType, eventID, vars)
  local special_offer_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.special_offer_module)
  special_offer_module:OpenPurchase()
end
function RechargeSystem.OnModePostSwitch(preState, nextState)
  local RechargePurchaseSystem = require("client.logic.recharge.logic_recharge_purchase")
  if nextState == GameStatus.Lobby then
    if RechargeSystem.isLoadMiadsMP == false then
      RechargeSystem.isLoadMiadsMP = true
    end
    if not RechargeSystem.IsRegisEvent then
      RechargeSystem.IsRegisEvent = true
      RechargeSystem.RegisterRechargeEvent()
    end
  else
    if nextState == GameStatus.Login then
      RechargePurchaseSystem.ClearInfo()
      RechargeSystem.ResetData()
    end
    if not GameStatus.IsInMainCity() then
      RechargeSystem.ClearAllTimer()
    end
  end
end
function RechargeSystem.InitializeTableData()
  if RechargeSystem.isInit == false then
    RechargeSystem.isInit = true
    local tabledata
    tabledata = FuncUtil.GetRechargeLevelTable()
    tabledata = CentauriManager.ProcessSpecialDisplaySetting(tabledata)
    local temp_Recharge_DataList = {}
    for i, v in pairs(tabledata) do
      if v.visible > 0 then
        local uObj_giveCountCfg = CDataTable.GetTableData("RechargeBounds", v.rechargeKey)
        local nGiveCount = uObj_giveCountCfg and uObj_giveCountCfg.GiveCount or 0
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
          country = v.country,
          giveCount = nGiveCount
        }
        table.insert(temp_Recharge_DataList, itemInfo)
        RechargeSystem.productId_BuyNum_Array[v.rechargeKey] = v.buyNum
        if RechargeSystem.strProductId == "" then
          RechargeSystem.strProductId = v.rechargeKey
        else
          RechargeSystem.strProductId = RechargeSystem.strProductId .. "," .. v.rechargeKey
        end
        if RechargeSystem.isConfigRecharge == false then
          RechargeSystem.isConfigRecharge = true
          RechargeSystem.zoneId = v.zoneId
          RechargeSystem.country = v.country
          RechargeSystem.monetaryUint = v.monetaryUint
          RechargeSystem.monetarySymbol = v.monetarySymbol
        end
      end
    end
    if temp_Recharge_DataList and 0 < #temp_Recharge_DataList then
      table.sort(temp_Recharge_DataList, function(a, b)
        return a.buyNum < b.buyNum
      end)
    end
    RechargeSystem.recharge_DataList_Array = temp_Recharge_DataList
  end
end
function RechargeSystem.Pay(recharge_info)
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
    log(bWriteLog and "EventRechargeGetJPAge, BP_Recharge_Need_Set_Age=" .. tostring(need_set_age) .. " DataMgr.jp_age=" .. tostring(DataMgr.jp_age))
  end
  RechargeSystem.buy_PosForSave = recharge_info.buyNum
  local TimeUtil = require("client.common.time_util")
  local sTLogStr = TimeUtil.GetServerTimeInSec() .. "," .. recharge_info.rechargeKey .. "," .. recharge_info.buyNum .. "," .. recharge_info.monetaryUint
  log(bWriteLog and " RechargeSystem.Pay SendLog >>>> " .. sTLogStr)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.SendPay, 0, sTLogStr, true)
  local logic_payment_api = require("client.logic.pay.logic_payment_api")
  logic_payment_api:Pay(recharge_info.rechargeKey, tonumber(recharge_info.buyNum), recharge_info.country, recharge_info.monetaryUint)
  EventSystem:postEvent(EVENTTYPE_RECHARGE, EVENTID_RECHARGE_REQ_BUY_ITEM)
end
function RechargeSystem.GetRechargeData()
  RechargeSystem.InitializeTableData()
  return RechargeSystem.recharge_DataList_Array
end
function RechargeSystem.RegisterRechargeEvent()
  EventSystem:registEvent(EVENTTYPE_CENTAURI_NOTIFY, EVENTID_CENTAURI_PAY_NOTIFY, RechargeSystem.CentauriPayBackEventHandler)
  EventSystem:registEvent(EVENTTYPE_CENTAURI_NOTIFY, EVENTID_CENTAURI_GETMPINFO_NOTIFY, RechargeSystem.CentauriMPEventHandler)
  EventSystem:registEvent(EVENTTYPE_CENTAURI_NOTIFY, EVENTID_CENTAURI_GET_RECHARGE_PRODUCT_INFO_NOTIFY, RechargeSystem.CentauriProductEventHandler)
  EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_TICKET_CHANGE, RechargeSystem.OnTicketChange)
end
function RechargeSystem.UnRegisterRechargeEvent()
  EventSystem:unregistEvent(EVENTTYPE_CENTAURI_NOTIFY, EVENTID_CENTAURI_PAY_NOTIFY, RechargeSystem.CentauriPayBackEventHandler)
  EventSystem:unregistEvent(EVENTTYPE_CENTAURI_NOTIFY, EVENTID_CENTAURI_GETMPINFO_NOTIFY, RechargeSystem.CentauriMPEventHandler)
  EventSystem:unregistEvent(EVENTTYPE_CENTAURI_NOTIFY, EVENTID_CENTAURI_GET_RECHARGE_PRODUCT_INFO_NOTIFY, RechargeSystem.CentauriProductEventHandler)
  EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_TICKET_CHANGE, RechargeSystem.OnTicketChange)
end
function RechargeSystem.OnCentauriFirstPay()
  local StatManager = import("StatManager")
  StatManager.GetInstance():ReportEventWithNoParam(16, true)
end
function RechargeSystem.OnCentauriPay(sPayChannel)
  sPayChannel = sPayChannel or ""
  local recharge_macro = require("client.logic.recharge.recharge_macro")
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  local sTLogStr = recharge_macro.TLogRechargeType .. "," .. sPayChannel
  log(bWriteLog and " RechargeSystem.OnCentauriPay Pay Uc Success >>>> " .. sTLogStr)
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.RechargeSuccess, 0, sTLogStr, true)
  local StatManager = import("StatManager")
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local PublishRegion = Client.GetPublishRegion()
  if PublishRegion ~= PublishRegionMacros.BLUEHOLE and PublishRegion ~= PublishRegionMacros.KOREA and PublishRegion ~= PublishRegionMacros.JAPAN then
    StatManager.GetInstance():ReportEventWithNoParam(15, true)
  end
  StatManager.GetInstance():ReportEventWithNoParam(19, true)
end
function RechargeSystem.GetMPInfo()
  local time_ticker = require("common.time_ticker")
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if not DevicePlatformNameMacros.IsPC() then
    logic_connection_waiting:Show(1)
    RechargeSystem.RemoveTimer(RechargeSystem.timer_hidetip)
    RechargeSystem.timer_hidetip = time_ticker.AddTimerOnce(5, function()
      logic_connection_waiting:Hide(1)
    end)
  end
  RechargeSystem.RemoveTimer(RechargeSystem.timer_getinfo)
  RechargeSystem.timer_getinfo = time_ticker.AddTimerOnce(0.1, function()
    RechargeSystem.InitializeTableData()
    RechargeSystem.isLoadingMP = true
    local logic_payment_api = require("client.logic.pay.logic_payment_api")
    logic_payment_api:load_Centauri_mp(RechargeSystem.country, RechargeSystem.monetaryUint)
  end)
end
function RechargeSystem.RemoveTimer(timer)
  if timer then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(timer)
    timer = nil
  end
end
function RechargeSystem.CentauriPayBackEventHandler(evenType, eventID, result_code, sPayChannel)
  logic_connection_waiting:Hide(1)
  RechargeSystem.RemoveTimer(RechargeSystem.timer_hidetip)
  if result_code == "0" or result_code == 0 then
    if RechargeSystem.isRechargeUIShowing() then
      RechargeSystem.GetMPInfo()
    end
    RechargeSystem.OnCentauriPay(sPayChannel)
    if DataMgr.Recharge == 1 then
      RechargeSystem.OnCentauriFirstPay()
    end
    log(bWriteLog and "RechargeUI.CentauriPayBackEventHandler .." .. tostring(RechargeSystem.buy_PosForSave))
    if RechargeSystem.buy_PosForSave and RechargeSystem.buy_PosForSave ~= "" then
      GlobalData.SaveRechargePayPos(RechargeSystem.buy_PosForSave)
      RechargeSystem.buy_PosForSave = ""
    end
  end
  EventSystem:postEvent(EVENTTYPE_RECHARGE, EVENTID_RECHARGE_GETDATA_SUCCESSED)
end
function RechargeSystem.CentauriMPEventHandler(evenType, eventID, Centauri_recharge_code)
  local temp_Recharge_PayPresentList = {}
  local temp_Recharge_PayNumList = {}
  local mpCache = CentauriManager.GetMPCache(false)
  if mpCache.resultCode == "0" or mpCache.resultCode == 0 then
    if string.len(mpCache.presentLevel) <= 2 then
      return
    end
    local StringUtil = require("common.string_util")
    local tempStr = string.sub(mpCache.presentLevel, 2, string.len(mpCache.presentLevel) - 1)
    log(bWriteLog and mpCache.presentLevel .. "  rechargeUI cast mpCache.presentLevel to  :  " .. tempStr)
    local args = StringUtil.Split(tempStr, ",")
    for i, v in ipairs(args) do
      local mod = math.fmod(i, 2)
      if mod == 0 then
        table.insert(temp_Recharge_PayPresentList, tonumber(v))
      else
        table.insert(temp_Recharge_PayNumList, tonumber(v))
      end
    end
    RechargeSystem.recharge_PayPresentList_Array = temp_Recharge_PayPresentList
    RechargeSystem.recharge_PayNumList_Array = temp_Recharge_PayNumList
    if GlobalData.IsJapanOrKorea() then
      local RechargeJKSystem = require("client.logic.recharge.logic_recharge_jk")
      RechargeJKSystem.tPayNumList = temp_Recharge_PayNumList
      RechargeJKSystem.tPayPresentList = temp_Recharge_PayPresentList
    end
    EventSystem:postEvent(EVENTTYPE_RECHARGE, EVENTID_RECHARGE_UPDATE_MP_INFO)
  end
  if RechargeSystem.isRechargeUIShowing() then
    RechargeSystem.isLoadingMP = false
    if RechargeSystem.isLoadingProductInfo == false then
      EventSystem:postEvent(EVENTTYPE_RECHARGE, EVENTID_RECHARGE_GETDATA_SUCCESSED)
      RechargeSystem.RemoveTimer(RechargeSystem.timer_hidetip)
    end
  end
end
function RechargeSystem.CentauriProductEventHandler(evenType, eventID, resultTable)
  local success = false
  if resultTable ~= nil then
    local temp_Recharge_MoneyKeyList = {}
    local temp_Recharge_MoneyList = {}
    for k, product in pairs(resultTable) do
      if product ~= nil then
        success = true
        if product.productId ~= nil and product.price ~= nil then
          local productNum = RechargeSystem.productId_BuyNum_Array[tostring(product.productId)]
          if productNum ~= nil then
            table.insert(temp_Recharge_MoneyKeyList, productNum)
            table.insert(temp_Recharge_MoneyList, tostring(product.price))
          end
        end
      end
    end
    RechargeSystem.recharge_MoneyKeyList = temp_Recharge_MoneyKeyList
    RechargeSystem.recharge_MoneyList = temp_Recharge_MoneyList
    if success then
      EventSystem:postEvent(EVENTTYPE_RECHARGE, EVENTID_RECHARGE_UPDATE_PRODUCT_INFO)
      RechargeSystem.RemoveTimer(RechargeSystem.timer_hidetip)
    end
  end
  if RechargeSystem.isRechargeUIShowing() then
    RechargeSystem.isLoadingProductInfo = false
    if RechargeSystem.isLoadingMP == false then
      EventSystem:postEvent(EVENTTYPE_RECHARGE, EVENTID_RECHARGE_GETDATA_SUCCESSED)
    end
  end
end
function RechargeSystem.GetFirstChargeShowingState()
  return RechargeSystem.isFirstChargeShowing
end
function RechargeSystem.UpdateFirstChargeShowingState(showing_state)
  RechargeSystem.isFirstChargeShowing = showing_state
end
function RechargeSystem.isRechargeUIShowing()
  return RechargeSystem.isUIShowing
end
function RechargeSystem.UpdateChargeUIShowingState(showing_state)
  RechargeSystem.isUIShowing = showing_state
end
function RechargeSystem.OnTicketChange()
  CentauriManager.ClearRequestNotifyClientRechargeTimer()
end
function RechargeSystem.ClearAllTimer()
  RechargeSystem.RemoveTimer(RechargeSystem.timer_hidetip)
  RechargeSystem.RemoveTimer(RechargeSystem.timer_getinfo)
end
function RechargeSystem.ResetData()
  RechargeSystem.IsRegisEvent = false
  RechargeSystem.isHideFirstCharge = false
  RechargeSystem.isFirstChargeShowing = false
  RechargeSystem.isUIShowing = false
  RechargeSystem.isInit = false
  RechargeSystem.isConfigRecharge = false
  RechargeSystem.strProductId = ""
  RechargeSystem.productId_BuyNum_Array = {}
  RechargeSystem.recharge_DataList_Array = {}
  RechargeSystem.UnRegisterRechargeEvent()
end
function RechargeSystem.GetGiveCountByBuyUCCount(nUCCount)
  nUCCount = tonumber(nUCCount)
  local nGiveTicketIndex = -1
  local index = 0
  if RechargeSystem.recharge_PayNumList_Array ~= nil then
    for k, v in pairs(RechargeSystem.recharge_PayNumList_Array) do
      index = index + 1
      if v == nUCCount then
        nGiveTicketIndex = index
      end
    end
  end
  local nGiveTicketCount = 0
  index = 0
  if 0 <= nGiveTicketIndex and RechargeSystem.recharge_PayPresentList_Array ~= nil then
    for k, v in pairs(RechargeSystem.recharge_PayPresentList_Array) do
      index = index + 1
      if index == nGiveTicketIndex then
        nGiveTicketCount = v
      end
    end
  end
  return nGiveTicketCount
end
function RechargeSystem.GetUCIconByCount(nUcCount)
  for _, v in pairs(_UCIconShow) do
    if nUcCount > v.min and nUcCount <= v.max then
      return v.path
    end
  end
  return "/Game/Arts/UI/TableIcons/ItemIcon/Currency/Task_icon_dianquan_256.Task_icon_dianquan_256"
end
function RechargeSystem.GetTagShowCfg(bUGC)
  local sRegion = DataMgr.RegionData.region
  if bUGC then
    local tTagShowCfg = CDataTable.GetTableDataByFilter("UGCRechargeShowTag", "Country", sRegion)
    return tTagShowCfg or {}
  end
  local tTagShowCfg = CDataTable.GetTableDataByFilter("RechargeShowTag", "Country", sRegion)
  return tTagShowCfg or {}
end
function RechargeSystem.GetIsCanBuyComebackPack(tPackData)
  local logic_player_return = require("client.slua.logic.player_return.logic_player_return")
  local tBackPlayerPack = logic_player_return.pay_back_info
  local nUcCount = tPackData.buyNum
  local return_activity_macro = require("client.slua.logic.return_activity.return_activity_macro")
  if tBackPlayerPack and tBackPlayerPack[nUcCount] and tBackPlayerPack[nUcCount].status ~= return_activity_macro.Enum_DiscountRewardStatus.Received then
    return true
  end
  return false
end
function RechargeSystem.GMSetShowTagType(nShowTagType)
  _nGMShowTagType = nShowTagType
end
function RechargeSystem.GetGMShowTagType()
  return _nGMShowTagType
end
return RechargeSystem