CentauriManager = CentauriManager or {
  productInfoJson = "",
  productInfoParsed = nil,
  getMPResultCode = "",
  present_level = "",
  localCurrencyArray = {
    "THB",
    "BRL",
    "RUB",
    "TRY",
    "VND",
    "INR",
    "GBP",
    "PHP",
    "MXN",
    "EUR",
    "CAD",
    "MYR",
    "USD",
    "HKD",
    "AUD",
    "JPY",
    "KRW",
    "TWD"
  },
  CachedProductInfoList = {},
  CachedProductInfoExpireTime = 300,
  CachedMPTimeStampLoaded = 0,
  CachedMPExpireTime = 300,
  CachedIntroPriceList = {},
  CachedIntroPriceListExpireTime = 300,
  hasRegisterBackLogin = false,
  RejectRecharge_PlayGameTime = 20,
  RechargeProductIdForLastTime = "",
  RechargeErrorMessages = nil,
  IsRechargedForThisRuntime = false,
  LocalOrderCountDownTimerIdx = -1,
  IsProcessLocalOrder = false,
  LocalOrderInfo = {RechargeKey = "", Timestamp = 0},
  LocalOrderKey_Timestamp = "Recharge_OrderTime",
  LocalOrderKey_RechargeKey = "Recharge_OrderRechargeKey",
  LocalOrderExpireTime = 600,
  RequestNotifyClientChargeTimer = nil,
  Recharge_CurrentRechargeKey = "",
  IsInCentauriPaying = false,
  HitAppFrontGroundAfterPay = false,
  HitIOSPsd2Error = false,
  CachedUserTickectNumBeforeBuy = 0,
  GetPriceByProductIdTimerStarted = false,
  GetPriceByProductIds = {},
  country = nil
}
local StringUtil = require("common.string_util")
local E_PayChannel = {GP = 1, H5 = 2}
CentauriManager.local Enum_Rule = {Unpaid = 1, Accumulated = 2}
local E_CentauriCallbackType = {
  CB_None = 0,
  CB_Init = 1,
  CB_Pay = 2
}
CentauriManager.
function CentauriManager.Initialize()
  Client.CentauriSDKInit()
  if CentauriManager.hasRegisterBackLogin == false then
    CentauriManager.hasRegisterBackLogin = true
    EventSystem:registEvent(EVENTTYPE_LOGIN, EVENTID_BACKLOGIN, CentauriManager.OnBackLogin)
    EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_TICKET_CHANGE, CentauriManager.OnTicketUpdated)
    log(bWriteLog and "CentauriManager registEvent.")
  end
end
function CentauriManager.OnLogin()
  local roleData = LobbySystem.roleData
  if NetUtil.needInitCentauriWhenLogin == true then
    NetUtil.needInitCentauriWhenLogin = false
    local logic_payment_api = require("client.logic.pay.logic_payment_api")
    if roleData.pay_zoneid ~= nil then
      logic_payment_api:set_Centauri_zoneid(roleData.pay_zoneid, roleData.pay_zoneid)
    else
      logic_payment_api:set_Centauri_zoneid("1", "1")
    end
    local cr = Client.GetPublishRegion()
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    if cr == PublishRegionMacros.BLUEHOLE then
      logic_payment_api:set_Centauri_idc("singapore_pubgld")
    end
    CentauriManager.Initialize()
    local bEnableIOSThirdPay = HDmpveRemote.HDmpveRemoteConfigGetBool("EnableIOSThirdPay", false)
    if bEnableIOSThirdPay then
      local IMSDKHelper = import("IMSDKHelper")
      local IMSDKHelperInstance = IMSDKHelper.GetInstance()
      local bGuest = IMSDKHelperInstance:IsEqualCurLoginPlatform(ShareSource.Guest)
      local isGlobal = cr == PublishRegionMacros.GLOBAL
      CentauriManager.country = nil
      log(bWriteLog and "[SY]CentauriManager.OnLogin.bGuest:" .. tostring(bGuest) .. " country:" .. tostring(CentauriManager.country))
      if isGlobal and not bGuest then
        local rechargeTable = FuncUtil.GetRechargeLevelTable()
        if rechargeTable ~= nil then
          for _, v in pairs(rechargeTable) do
            log(bWriteLog and "[SY]CentauriManager.OnLogin.GetCountry key:" .. tostring(v.rechargeKey))
            local time_ticker = require("common.time_ticker")
            time_ticker.AddTimerOnce(20, function()
              log(bWriteLog and "[SY]CentauriManager.OnLogin.SendProduct")
              logic_payment_api:load_Centauri_product_info(v.rechargeKey)
            end)
            break
          end
        end
      end
    end
    local StoreKit = import("StoreKit")
    local RegionCallbackDelegate = slua.createDelegate(function(region)
      logic_payment_api.StoreCountryCode = region
    end)
    StoreKit.GetCountryCode(RegionCallbackDelegate)
  end
  if roleData.rc_time ~= nil then
    CentauriManager.RejectRecharge_PlayGameTime = roleData.rc_time
  end
  CentauriManager.IsRechargedForThisRuntime = false
end
function CentauriManager.OnBackLogin()
  log(bWriteLog and "CentauriManager OnBackLogin.")
  CentauriManager.CachedProductInfoList = {}
  CentauriManager.CachedIntroPriceList = {}
  CentauriManager.getMPResultCode = ""
  CentauriManager.present_level = ""
end
function CentauriManager.OnInitialize(_)
  log(bWriteLog and "CentauriManager received OnInitialize")
  local CentauriHandler = require("client.network.Protocol.CentauriHandler")
  CentauriHandler.send_imobile_notify_client_charge(0)
end
function CentauriManager.OnPayNeedLogin()
  log(bWriteLog and "CentauriManager received OnPayNeedLogin")
  local msgTitle = LocUtil.GetLocalizeResStr("4085")
  local msgContent = LocUtil.GetLocalizeResStr("7692")
  local clickOKCallback = function()
    log(bWriteLog and "CentauriManager.OnPayNeedLogin logOut")
    local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
    login_module:sendLogout()
  end
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, msgTitle, msgContent, clickOKCallback)
end
function CentauriManager.OnPay(payCallBack)
  log(bWriteLog and "CentauriManager received OnPay,resultCode:" .. payCallBack.resultCode .. ",appExtends:" .. payCallBack.appExtends)
  log_tree("CentauriManager received OnPay,resultCode payCallBack:", payCallBack)
  local paytype = "0"
  if string.find(payCallBack.appExtends, "recharge") ~= nil then
    paytype = "1"
  elseif string.find(payCallBack.appExtends, "goods") ~= nil then
    if string.find(payCallBack.appExtends, "goodspresent") ~= nil then
      paytype = "5"
    else
      paytype = "2"
    end
  elseif string.find(payCallBack.appExtends, "subscribe") ~= nil then
    paytype = "3"
  elseif string.find(payCallBack.appExtends, "h5pay") ~= nil then
    paytype = "4"
  else
    log(bWriteLog and "CentauriManager received unknown OnPay appExtends.")
  end
  local StringUtil = require("common.string_util")
  local resultInnerCode_0 = "-1"
  local resultInnerCode_1 = "-1"
  local resultInnerCode_2 = "-1"
  local resultInnerCodeSplit = StringUtil.Split(payCallBack.resultInnerCode, "-")
  if 3 <= #resultInnerCodeSplit then
    resultInnerCode_0 = resultInnerCodeSplit[1]
    resultInnerCode_1 = resultInnerCodeSplit[2]
    resultInnerCode_2 = resultInnerCodeSplit[3]
    log(bWriteLog and string.format("payCallBack.resultInnerCode split succ to 3 0: %s 1: %s 2: %s", tostring(resultInnerCode_0), tostring(resultInnerCode_1), tostring(resultInnerCode_2)))
  end
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  local AOSSHOPMacros = require("client.slua.config.ClientMacros.AOSSHOPMacros")
  local devicetype = DevicePlatformNameMacros.Android
  if Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS then
    devicetype = "iOS"
  end
  if paytype == "4" then
  elseif payCallBack.resultCode == "0" then
    if paytype == "1" then
      CentauriManager.ticketNumBeforeUpdate = DataMgr.ticket
      CentauriManager.StartRequestNotifyClientRechargeTimer()
      local CentauriHandler = require("client.network.Protocol.CentauriHandler")
      CentauriHandler.send_imobile_notify_client_charge(0)
      log(bWriteLog and "EVENTID_MESSAGE_PUSH_TRIGGER_RECORD_DATA FIRST_CHARGE")
      EventSystem:postEvent(EVENTTYPE_MESSAGE_PUSH_TRIGGER, EVENTID_MESSAGE_PUSH_TRIGGER_RECORD_DATA, ENUM_TRIGGER_COND.FIRST_CHARGE)
      if CentauriManager.IsRechargedForThisRuntime == false then
        CentauriManager.IsRechargedForThisRuntime = true
      end
      if DataMgr.SeasonRecharge == nil or DataMgr.SeasonRecharge == 0 then
        DataMgr.SeasonRecharge = 1
      end
      local SettingAccount = require("client.logic.setting.logic_setting_account")
      SettingAccount.ShowNotSafe(BP_ENUM_SWITCH_ACCOUNT_SAFE_CENTAURI)
    end
    CentauriManager.ReportPurchaseSuccEventToAdjust(payCallBack.payProductId)
    if paytype ~= "5" then
      ShowNotice(7687)
    end
  elseif payCallBack.resultCode == "3" then
    CentauriManager.ShowPayTip(LocUtil.GetLocalizeResStr(7688))
  elseif payCallBack.resultCode == "2" then
    CentauriManager.ShowPayTip(LocUtil.GetLocalizeResStr(7689))
  elseif Client.GetDevicePlatformName() == DevicePlatformNameMacros.Android and Client.GetAOSSHOP() == AOSSHOPMacros.Samsung then
    ShowNotice(7690)
  elseif payCallBack.resultCode == "1" or Client.GetDevicePlatformName() == DevicePlatformNameMacros.Android and payCallBack.resultCode == "100" and payCallBack.resultInnerCode == "-2001" then
    CentauriManager.StartCancelRechargeGuildFlow(paytype)
  elseif payCallBack.resultCode == "4" then
    CentauriManager.ShowPayTip(LocUtil.GetLocalizeResStr(7694))
  elseif payCallBack.resultCode == "-1" and payCallBack.resultInnerCode == "-5" then
    local rc_type = "save"
    if string.find(payCallBack.appExtends, "goods") ~= nil then
      rc_type = "bg"
    elseif string.find(payCallBack.appExtends, "subscribe") ~= nil then
      rc_type = "unimonth"
    end
    local CentauriHandler = require("client.network.Protocol.CentauriHandler")
    CentauriHandler.send_report_reject_charge(rc_type)
    local strTips = LocUtil.GetLocalizeResStr(6321)
    CentauriManager.ShowPayTip(string.format(strTips, CentauriManager.RejectRecharge_PlayGameTime))
  elseif payCallBack.resultCode == "-1" and resultInnerCode_0 == "1138" then
    log(bWriteLog and string.format("payCallBack.resultCode=-1 resultInnerCode_0=1138 Error Tips : %s 1: %s 2: %s", tostring(resultInnerCode_0), tostring(resultInnerCode_1), tostring(resultInnerCode_2)))
    local realResultInnerCode = ""
    if resultInnerCode_1 == "1" or Client.GetDevicePlatformName() == DevicePlatformNameMacros.Android and resultInnerCode_1 == "30051" then
      realResultInnerCode = resultInnerCode_2
    elseif Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS and resultInnerCode_2 == "30051" then
      realResultInnerCode = resultInnerCode_1
    end
    if 0 < string.len(realResultInnerCode) then
      local TipsKey = tonumber(realResultInnerCode) + 100000000
      local InnerCodeNum = tonumber(realResultInnerCode)
      if 10000 <= InnerCodeNum and InnerCodeNum <= 13999 then
        local tInnerCodeNumList = {
          12161,
          12201,
          12202,
          12203,
          12219,
          12255
        }
        local bKeepDefault = false
        for _, v in ipairs(tInnerCodeNumList) do
          if v == InnerCodeNum then
            bKeepDefault = true
            break
          end
        end
        if not bKeepDefault then
          if Client.GetAOSSHOP() == AOSSHOPMacros.HMS then
            TipsKey = 64358
          else
            TipsKey = 100010000
          end
        end
      else
        if 14000 <= InnerCodeNum and InnerCodeNum <= 14999 then
          TipsKey = 100014000
        else
        end
      end
      CentauriManager.ShowPayWarningTip(LocUtil.GetLocalizeResStr(TipsKey), CentauriManager.JumpToHelp)
    else
      CentauriManager.ShowCommonPayErrorTip(nil)
    end
  elseif Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS and payCallBack.resultCode == "-1" and (payCallBack.resultInnerCode == "1138" or payCallBack.resultInnerCode == "1139" or payCallBack.resultInnerCode == "1140" or payCallBack.resultInnerCode == "1141") then
    CentauriManager.ShowCommonPayErrorTip(nil)
  elseif Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS and payCallBack.resultCode == "-1" then
    CentauriManager.ShowCommonPayErrorTip(nil)
  elseif Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS and payCallBack.resultCode == "100" and payCallBack.resultInnerCode == "-1233" then
    CentauriManager.ShowPayTip(LocUtil.GetLocalizeResStr(7695))
  elseif Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS and payCallBack.resultCode == "100" and payCallBack.resultInnerCode == "-1234" then
    CentauriManager.ShowPayTip(LocUtil.GetLocalizeResStr(7696))
  elseif Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS and payCallBack.resultCode == "100" and payCallBack.resultInnerCode == "2037" then
    CentauriManager.ShowCommonPayErrorTip(nil)
  elseif Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS and payCallBack.resultCode == "100" and payCallBack.resultInnerCode == "-128" then
    CentauriManager.ShowCommonPayErrorTip(nil)
  elseif CentauriManager.IsEUPsd2Enable() and paytype == "1" and payCallBack.resultCode == "100" and payCallBack.resultInnerCode == "0" then
    CentauriManager.UpdateAndCheckPayCallback(CentauriManager.E_CentauriCallbackType.CB_Pay, payCallBack.resultCode, payCallBack.resultInnerCode)
  elseif Client.GetDevicePlatformName() == DevicePlatformNameMacros.Android and payCallBack.resultCode == "-1" and (payCallBack.resultInnerCode == "1138" or payCallBack.resultInnerCode == "5017") then
    if payCallBack.resultMsg ~= nil and 0 < string.len(payCallBack.resultMsg) and not CentauriManager.HasIllegalChar(payCallBack.resultMsg) then
      CentauriManager.ShowPayTip(payCallBack.resultMsg)
    else
      CentauriManager.ShowCommonPayErrorTip(nil)
    end
  elseif Client.GetDevicePlatformName() == DevicePlatformNameMacros.Android and payCallBack.resultCode == "100" and payCallBack.resultInnerCode == "-2002" then
    CentauriManager.ShowPayTip(LocUtil.GetLocalizeResStr(7697))
  elseif Client.GetDevicePlatformName() == DevicePlatformNameMacros.Android and payCallBack.resultCode == "100" and payCallBack.resultInnerCode == "-2003" then
    CentauriManager.ShowPayTip(LocUtil.GetLocalizeResStr(7698))
  elseif Client.GetDevicePlatformName() == DevicePlatformNameMacros.Android and payCallBack.resultCode == "100" and payCallBack.resultInnerCode == "-2004" then
    CentauriManager.ShowPayTip(LocUtil.GetLocalizeResStr(7699))
  elseif Client.GetDevicePlatformName() == DevicePlatformNameMacros.Android and payCallBack.resultCode == "100" and payCallBack.resultInnerCode == "-2005" then
    CentauriManager.ShowPayTip(LocUtil.GetLocalizeResStr(7700))
  elseif Client.GetDevicePlatformName() == DevicePlatformNameMacros.Android and payCallBack.resultCode == "100" and payCallBack.resultInnerCode == "-2008" then
    CentauriManager.ShowPayTip(LocUtil.GetLocalizeResStr(7701))
  elseif Client.GetDevicePlatformName() == DevicePlatformNameMacros.Android and payCallBack.resultCode == "100" and payCallBack.resultInnerCode == "-2011" then
    CentauriManager.ShowPayTip(LocUtil.GetLocalizeResStr(7702))
  elseif Client.GetDevicePlatformName() == DevicePlatformNameMacros.Android and payCallBack.resultCode == "100" and payCallBack.resultInnerCode == "-2012" then
    CentauriManager.ShowPayTip(LocUtil.GetLocalizeResStr(7703))
  elseif Client.GetDevicePlatformName() == DevicePlatformNameMacros.Android and payCallBack.resultCode == "100" and payCallBack.resultInnerCode == "-2013" then
    CentauriManager.ShowPayTip(LocUtil.GetLocalizeResStr(7704))
  elseif Client.GetDevicePlatformName() == DevicePlatformNameMacros.Android and payCallBack.resultCode == "-1" and payCallBack.resultInnerCode == "60051" then
    CentauriManager.ShowPayTip(LocUtil.GetLocalizeResStr(7704))
  elseif Client.GetDevicePlatformName() == DevicePlatformNameMacros.Android and payCallBack.resultCode == "100" and (payCallBack.resultInnerCode == "-2014" or payCallBack.resultInnerCode == "-2020") then
    if Client.GetAOSSHOP() == AOSSHOPMacros.Google or Client.GetAOSSHOP() == AOSSHOPMacros.ThirdPartyPayment then
      CentauriManager.ShowPayTip(LocUtil.GetLocalizeResStr(44727))
    else
      CentauriManager.ShowPayTip(LocUtil.GetLocalizeResStr(7705))
    end
  elseif Client.GetDevicePlatformName() == DevicePlatformNameMacros.Android and payCallBack.resultCode == "100" and payCallBack.resultInnerCode == "-2016" then
    CentauriManager.ShowPayTip(LocUtil.GetLocalizeResStr(64216))
  elseif Client.GetDevicePlatformName() == DevicePlatformNameMacros.Android and payCallBack.resultCode == "100" and payCallBack.resultInnerCode == "-2019" then
    CentauriManager.ShowPayTip(LocUtil.GetLocalizeResStr(64217))
  elseif Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS and payCallBack.resultCode == "100" and CentauriManager.IsErrorCodeInStoreErrorMsg(payCallBack.resultMsg, "-7003") then
    CentauriManager.StartCancelRechargeGuildFlow(paytype)
  else
    CentauriManager.ShowCommonPayErrorTip(nil)
  end
  CentauriManager.IsInCentauriPaying = false
  local store_direct_purchase_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.store_direct_purchase_manager)
  if paytype == "1" then
    EventSystem:postEvent(EVENTTYPE_CENTAURI_NOTIFY, EVENTID_CENTAURI_PAY_NOTIFY, payCallBack.resultCode, payCallBack.payChannel)
  elseif paytype == "2" then
    store_direct_purchase_manager:DirectPurchaseCentauriRsp(payCallBack.resultCode, payCallBack.resultInnerCode)
    EventSystem:postEvent(EVENTTYPE_CENTAURI_NOTIFY, EVENTID_CENTAURI_BUY_GOODS_NOTIFY, payCallBack.resultCode, payCallBack.resultInnerCode)
  elseif paytype == "3" then
    EventSystem:postEvent(EVENTTYPE_CENTAURI_NOTIFY, EVENTID_CENTAURI_SUBSCRIBE_NOTIFY, payCallBack.resultCode, payCallBack.payChannel)
  elseif paytype == "5" then
    store_direct_purchase_manager:DirectPurchaseCentauriRsp(payCallBack.resultCode, payCallBack.resultInnerCode)
    EventSystem:postEvent(EVENTTYPE_CENTAURI_NOTIFY, EVENTID_CENTAURI_BUY_GOODS_NOTIFY, payCallBack.resultCode, payCallBack.resultInnerCode)
  end
  local payresult = "2"
  if payCallBack.resultCode == "0" then
    payresult = "0"
    log(bWriteLog and "send_daily_direct_buy_success" .. "\230\151\165\229\191\151\231\148\159\230\149\136")
  elseif payCallBack.resultCode == "1" or Client.GetDevicePlatformName() == DevicePlatformNameMacros.Android and payCallBack.resultCode == "100" and payCallBack.resultInnerCode == "-2001" then
    payresult = "1"
  end
  local payEvent = {
    openid = DataMgr.roleData.openID,
    pay_type = paytype,
    pay_result = payresult,
    pay_channel = payCallBack.payChannel,
    device_type = devicetype,
    resultCode = payCallBack.resultCode,
    resultInnerCode = payCallBack.resultInnerCode,
    resultMsg = ""
  }
  Client.GEMReportEvent(GameFrontendHUD, "pay", payEvent)
end
function CentauriManager.IsErrorCodeInStoreErrorMsg(storeMsg, code)
  local hasFound = false
  local errorCodeStr = "Code=" .. code
  for s in string.gmatch(storeMsg, "Code=%-%d+") do
    if errorCodeStr == s then
      hasFound = true
      break
    end
  end
  if hasFound == false then
    for s in string.gmatch(storeMsg, "Code=%d+") do
      if errorCodeStr == s then
        hasFound = true
        break
      end
    end
  end
  log(bWriteLog and "CentauriManager.IsErrorCodeInStoreErrorMsg: " .. tostring(hasFound))
  return hasFound
end
function CentauriManager.ShowPayTip(msgContent, clickOkCallback)
  if msgContent ~= nil then
    local obj_ui = UIManager.GetUI(UIManager.UI_Config.Common_RechargeMsgBox_UIBP)
    if obj_ui then
      UIManager.CloseUI(UIManager.UI_Config.Common_RechargeMsgBox_UIBP)
    end
    if clickOkCallback ~= nil then
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.Show(1, LocUtil.GetLocalizeResStr(101001), msgContent, clickOkCallback)
    else
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.Show(1, LocUtil.GetLocalizeResStr(101001), msgContent)
    end
  end
end
function CentauriManager.ShowPayWarningTip(msgContent, clickOkCallback)
  if msgContent ~= nil then
    local obj_ui = UIManager.GetUI(UIManager.UI_Config.Common_RechargeMsgBox_UIBP)
    if obj_ui then
      UIManager.CloseUI(UIManager.UI_Config.Common_RechargeMsgBox_UIBP)
    end
    if clickOkCallback ~= nil then
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.Show(3, LocUtil.GetLocalizeResStr(101001), msgContent, clickOkCallback, nil, LocUtil.GetLocalizeResStr(4539))
    else
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.Show(3, LocUtil.GetLocalizeResStr(101001), msgContent)
    end
  end
end
function CentauriManager.ShowCommonPayErrorTip(resultMsg)
  local canShowDetailErrorMsg = false
  if resultMsg ~= nil and string.len(resultMsg) > 0 and not CentauriManager.HasIllegalChar(resultMsg) then
    canShowDetailErrorMsg = true
  end
  if canShowDetailErrorMsg then
    CentauriManager.ShowPayTip(string.format(LocUtil.GetLocalizeResStr(7691), resultMsg))
  else
    CentauriManager.ShowPayTip(LocUtil.GetLocalizeResStr(7690))
  end
end
function CentauriManager.PreLoadRechargeErrorMessages()
  local rechargeMessages = CDataTable.GetTable("RechargeErrorMessageConfig")
  CentauriManager.RechargeErrorMessages = {}
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() then
    return
  end
  for i, v in pairs(rechargeMessages) do
    if string.lower(v.osplatform) == string.lower(Client.GetDevicePlatformName()) then
      local vTemp = {
        messageId = v.messageId,
        osplatform = v.osplatform,
        rechargeStatus = v.rechargeStatus,
        passStatus = v.passStatus,
        payType = v.payType,
        rechargeKey = v.rechargeKey,
        translationKey = v.translationKey,
        impreciseMatchCounter = 0
      }
      table.insert(CentauriManager.RechargeErrorMessages, vTemp)
    end
  end
end
function CentauriManager.GetRechargeErrorMessages()
  if CentauriManager.RechargeErrorMessages == nil then
    CentauriManager.PreLoadRechargeErrorMessages()
  end
  return CentauriManager.RechargeErrorMessages
end
function CentauriManager.StartCancelRechargeGuildFlow(paytype)
  local rechargeMessage
  local rechargeInCurrentSeason = DataMgr.SeasonRecharge > 0
  local hasRecharged = DataMgr.Recharge == 0 or CentauriManager.IsRechargedForThisRuntime == true
  for i, v in pairs(CentauriManager.GetRechargeErrorMessages()) do
    while (string.lower(v.payType) ~= "recharge" or paytype == "1") and (string.lower(v.payType) ~= "goods" or paytype == "2") and (string.lower(v.payType) ~= "subscribe" or paytype == "3") do
      if v.rechargeStatus ~= "skip" then
        if not ((v.rechargeStatus ~= "unpaid" or not hasRecharged) and (v.rechargeStatus ~= "paid" or hasRecharged) and (v.rechargeStatus ~= "unpaidinseason" or hasRecharged and not rechargeInCurrentSeason) and (v.rechargeStatus ~= "paidinseason" or hasRecharged and rechargeInCurrentSeason)) then
          break
        end
        v.impreciseMatchCounter = v.impreciseMatchCounter + 1
      end
      if v.passStatus ~= "skip" then
        if not (v.passStatus ~= "paidpass" or UnknowPassSystem.IsBuyElite) or v.passStatus == "unpaidpass" and UnknowPassSystem.IsBuyElite then
          break
        end
        v.impreciseMatchCounter = v.impreciseMatchCounter + 1
      end
      if v.rechargeKey ~= "all" then
        if v.rechargeKey ~= tostring(CentauriManager.RechargeProductIdForLastTime) then
          break
        end
        v.impreciseMatchCounter = v.impreciseMatchCounter + 1
      end
      if rechargeMessage == nil then
        rechargeMessage = v
        break
      end
      if v.rechargKey ~= rechargeMessage.rechargKey then
        if v.rechargKey == tostring(CentauriManager.RechargeProductIdForLastTime) then
          rechargeMessage = v
          break
        end
        if rechargeMessage.rechargKey ~= tostring(CentauriManager.RechargeProductIdForLastTime) then
          goto lbl_137
        end
        do break end
        ::lbl_137::
        if rechargeMessage.rechargKey ~= tostring(CentauriManager.RechargeProductIdForLastTime) and v.rechargKey ~= tostring(CentauriManager.RechargeProductIdForLastTime) and v.impreciseMatchCounter > rechargeMessage.impreciseMatchCounter then
          rechargeMessage = v
        end
        break
      end
      if v.rechargKey == rechargeMessage.rechargKey and v.impreciseMatchCounter > rechargeMessage.impreciseMatchCounter then
        rechargeMessage = v
      end
      break
    end
  end
  local OnOkClickedCallback
  if paytype == "1" then
    OnOkClickedCallback = CentauriManager.ProgressLocalOrder
  end
  if rechargeMessage ~= nil then
    log(bWriteLog and "[CentauriManager.ProcessCancelPay] cat localization id:" .. rechargeMessage.translationKey)
    CentauriManager.ShowPayTip(LocUtil.GetLocalizeResStr(rechargeMessage.translationKey), OnOkClickedCallback)
  else
    CentauriManager.ShowPayTip(LocUtil.GetLocalizeResStr(7693), OnOkClickedCallback)
  end
end
function CentauriManager.CreateLocalOrder()
  log(bWriteLog and "[CentauriManager.CreateLocalOrder] called")
  if CentauriManager.Recharge_CurrentRechargeKey ~= nil and CentauriManager.Recharge_CurrentRechargeKey ~= "" then
    local TimeUtil = require("client.common.time_util")
    CentauriManager.LocalOrderInfo.Timestamp = TimeUtil.GetServerTimeInSec()
    CentauriManager.LocalOrderInfo.RechargeKey = CentauriManager.Recharge_CurrentRechargeKey
    CentauriManager.Recharge_CurrentRechargeKey = ""
    local PlayerPrefs = require("client.logic.LogicPlayerPrefs.playerprefs")
    local personalRecords = PlayerPrefs.LoadFileToTable_N(PlayerPrefs.ePlayerPrefsType.ePersonalRecord)
    if personalRecords == nil then
      personalRecords = {}
    end
    personalRecords[CentauriManager.LocalOrderKey_Timestamp] = CentauriManager.LocalOrderInfo.Timestamp
    personalRecords[CentauriManager.LocalOrderKey_RechargeKey] = CentauriManager.LocalOrderInfo.RechargeKey
    PlayerPrefs.SaveTableToFile_N(personalRecords, PlayerPrefs.ePlayerPrefsType.ePersonalRecord)
  end
end
function CentauriManager.CompleteLocalOrder()
  log(bWriteLog and "[CentauriManager.CompleteLocalOrder] called")
  CentauriManager.LocalOrderInfo.Timestamp = 0
  CentauriManager.LocalOrderInfo.RechargeKey = ""
  local PlayerPrefs = require("client.logic.LogicPlayerPrefs.playerprefs")
  local personalRecords = PlayerPrefs.LoadFileToTable_N(PlayerPrefs.ePlayerPrefsType.ePersonalRecord)
  if personalRecords ~= nil and (personalRecords[CentauriManager.LocalOrderKey_Timestamp] ~= nil or personalRecords[CentauriManager.LocalOrderKey_RechargeKey] ~= nil) then
    personalRecords[CentauriManager.LocalOrderKey_Timestamp] = CentauriManager.LocalOrderInfo.Timestamp
    personalRecords[CentauriManager.LocalOrderKey_RechargeKey] = CentauriManager.LocalOrderInfo.RechargeKey
    PlayerPrefs.SaveTableToFile_N(personalRecords, PlayerPrefs.ePlayerPrefsType.ePersonalRecord)
  end
end
function CentauriManager.LoadLocalOrder()
  log(bWriteLog and "[CentauriManager.LoadLocalOrder] called")
  local PlayerPrefs = require("client.logic.LogicPlayerPrefs.playerprefs")
  local personalRecords = PlayerPrefs.LoadFileToTable_N(PlayerPrefs.ePlayerPrefsType.ePersonalRecord)
  if personalRecords ~= nil and personalRecords[CentauriManager.LocalOrderKey_Timestamp] ~= nil and personalRecords[CentauriManager.LocalOrderKey_RechargeKey] ~= nil then
    CentauriManager.LocalOrderInfo.Timestamp = personalRecords[CentauriManager.LocalOrderKey_Timestamp]
    CentauriManager.LocalOrderInfo.RechargeKey = personalRecords[CentauriManager.LocalOrderKey_RechargeKey]
  end
  if CentauriManager.IsLocalOrderExpire() then
    CentauriManager.CompleteLocalOrder()
  end
end
function CentauriManager.IsLocalOrderExpire()
  local TimeUtil = require("client.common.time_util")
  local deta = CentauriManager.LocalOrderInfo.Timestamp + CentauriManager.LocalOrderExpireTime - TimeUtil.GetServerTimeInSec()
  return deta <= 0
end
function CentauriManager.JumpToHelp()
  log(bWriteLog and string.format("CentauriManager.JumpToHelp for 1138"))
  local LogicCustomerService = require("client.slua.logic.CustomerService.LogicCustomerService")
  LogicCustomerService.Open(LogicCustomerService.E_EntranceType.Recharge)
end
function CentauriManager.ProgressLocalOrder()
  if not CentauriManager.IsProcessLocalOrder then
    if CentauriManager.LocalOrderInfo.RechargeKey ~= "" and not CentauriManager.IsLocalOrderExpire() then
      CentauriManager.AskPlayerToProcessLocalOrder()
    else
      CentauriManager.CreateLocalOrder()
    end
  end
  CentauriManager.StopLocalOrderCountDownTimer()
  CentauriManager.StartLocalOrderCountDownTimer()
end
function CentauriManager.AskPlayerToProcessLocalOrder(isCallFromTipClicked)
  local OnOkClicked = function()
    CentauriManager.IsProcessLocalOrder = true
    CentauriManager.RechargeProductIdForLastTime = CentauriManager.LocalOrderInfo.RechargeKey
    EventSystem:postEvent(EVENTTYPE_SHOPLIMIT, EVENTID_SHOPLIMIT_REQUEST_DOPAY, CentauriManager.LocalOrderInfo.RechargeKey)
    CentauriManager.CompleteLocalOrder()
    CentauriManager.CreateLocalOrder()
  end
  local OnCloseClicked = function()
    CentauriManager.CompleteLocalOrder()
    CentauriManager.CreateLocalOrder()
  end
  local msgContent = LocUtil.GetLocalizeResStr("8011")
  local msgTitle = LocUtil.GetLocalizeResStr("101001")
  if isCallFromTipClicked ~= nil and isCallFromTipClicked == true then
    local buyNum = ""
    local money = ""
    local symbol = ""
    local RechargeSystem = require("client.logic.recharge.logic_recharge")
    local recharge_data = RechargeSystem.recharge_DataList_Array or {}
    for i, v in ipairs(recharge_data) do
      if v.rechargeKey == CentauriManager.LocalOrderInfo.RechargeKey then
        buyNum = v.buyNum
        money = v.money
        symbol = v.monetarySymbol
        break
      end
    end
    local symbol_money = symbol .. tostring(money)
    for k, p in pairs(CentauriManager.CachedProductInfoList) do
      if p.productId == CentauriManager.LocalOrderInfo.RechargeKey then
        symbol_money = p.price
        break
      end
    end
    local nBuyNum = tonumber(buyNum)
    local gen_ticket_index = -1
    local index = 0
    if RechargeSystem.recharge_PayNumList_Array ~= nil then
      for k, v in pairs(RechargeSystem.recharge_PayNumList_Array) do
        index = index + 1
        if v == nBuyNum then
          gen_ticket_        end
      end
    end
    local gen_ticket_number = 0
    index = 0
    if 0 <= gen_ticket_index and RechargeSystem.recharge_PayPresentList_Array ~= nil then
      for k, v in pairs(RechargeSystem.recharge_PayPresentList_Array) do
        index = index + 1
        if index == gen_ticket_index then
          gen_ticket_number = v
        end
      end
    end
    local total_buy_number = tonumber(buyNum or 0) + gen_ticket_number
    msgContent = LocUtil.LocalizeResFormat("7946", symbol_money, tostring(total_buy_number))
  end
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, msgTitle, msgContent, OnOkClicked, OnCloseClicked, nil, nil, {switchTextType = true})
end
function CentauriManager.OnRechargeUIShow()
  CentauriManager.LoadLocalOrder()
  CentauriManager.StopLocalOrderCountDownTimer()
  CentauriManager.StartLocalOrderCountDownTimer()
end
function CentauriManager.StartLocalOrderCountDownTimer()
  local time_ticker = require("common.time_ticker")
  CentauriManager.LocalOrderCountDownTimerIdx = time_ticker.AddTimerLoop(0, CentauriManager.TickUpdateLocalOrderRemainTime, TIMER_INFINITE, 1)
end
function CentauriManager.StopLocalOrderCountDownTimer()
  if CentauriManager.LocalOrderCountDownTimerIdx then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(CentauriManager.LocalOrderCountDownTimerIdx)
    CentauriManager.LocalOrderCountDownTimerIdx = nil
  end
end
function CentauriManager.TickUpdateLocalOrderRemainTime()
  local TimeUtil = require("client.common.time_util")
  local expireDetaTime = CentauriManager.LocalOrderInfo.Timestamp + CentauriManager.LocalOrderExpireTime - TimeUtil.GetServerTimeInSec()
  local strCountDownTime = "00:00"
  if 0 < expireDetaTime then
    local _, hours, mins, seconds = TimeUtil.FormatCountDownTime_HMS(expireDetaTime)
    strCountDownTime = mins .. ":" .. seconds
  end
  EventSystem:postEvent(EVENTTYPE_SHOPLIMIT, EVENTID_SHOPLIMIT_CANCEL_RECHARGE_TIME_LIMIT_UPDATED, strCountDownTime)
  local RechargeSystem = require("client.logic.recharge.logic_recharge")
  local isShow = RechargeSystem.isRechargeUIShowing()
  if not isShow or expireDetaTime <= 0 then
    CentauriManager.StopLocalOrderCountDownTimer()
    return
  end
end
function CentauriManager.OnGetMP(getMPCallBack)
  log(bWriteLog and "CentauriManager received OnGetMP: " .. getMPCallBack.mpInfoJson)
  CentauriManager.getMPResultCode = "-2"
  CentauriManager.present_level = ""
  if getMPCallBack.mpInfoJson == nil then
    log(bWriteLog and "CentauriManager.OnGetMP failed 1")
    EventSystem:postEvent(EVENTTYPE_CENTAURI_NOTIFY, EVENTID_CENTAURI_GETMPINFO_NOTIFY, CentauriManager.getMPResultCode)
    return
  end
  local mpInfo = json.decode(getMPCallBack.mpInfoJson)
  mpInfo = mpInfo.msg
  if mpInfo == nil then
    log(bWriteLog and "CentauriManager.OnGetMP failed 2")
    EventSystem:postEvent(EVENTTYPE_CENTAURI_NOTIFY, EVENTID_CENTAURI_GETMPINFO_NOTIFY, CentauriManager.getMPResultCode)
    return
  end
  if mpInfo.ret ~= nil and mpInfo.ret == 0 then
    local logic_payment_api = require("client.logic.pay.logic_payment_api")
    if logic_payment_api:is_mpinfo_in_diff_area() and mpInfo.mp_info and mpInfo.mp_info.buycurrency and mpInfo.mp_info.buycurrency.uptopresent and mpInfo.mp_info.buycurrency.uptopresent.rule_item then
      local rule_items = mpInfo.mp_info.buycurrency.uptopresent.rule_item
      local rule_items_len = #rule_items
      local allow_channel = logic_payment_api:get_paychannel_by_aosshop()
      local rule_item, normal_rule_item
      for i = 1, rule_items_len do
        local tmp_rule_item = rule_items[i]
        if tmp_rule_item and tmp_rule_item.allow_channel and allow_channel == tmp_rule_item.allow_channel then
          rule_item = tmp_rule_item
        end
        if tmp_rule_item and tmp_rule_item.allow_channel and "*" == tmp_rule_item.allow_channel then
          normal_rule_item = tmp_rule_item
        end
      end
      if rule_item == nil then
        log(bWriteLog and "CentauriManager.OnGetMP info NOT found in channel. Use Normarl channel data instead")
        rule_item = normal_rule_item
      end
      if rule_item and rule_item.present_item then
        local present_level = {}
        local rule_item_len = #rule_item.present_item
        for j = 1, rule_item_len do
          local present_item = rule_item.present_item[j]
          if present_item and present_item.send_num and present_item.num then
            local num = tonumber(present_item.num)
            local send_num = tonumber(present_item.send_num)
            if 0 < send_num and 0 < num then
              table.insert(present_level, num)
              table.insert(present_level, send_num)
            end
          end
        end
        local present_level_string = table.concat(present_level, ",")
        mpInfo.present_level = string.format("[%s]", present_level_string)
      end
    end
    if mpInfo.present_level ~= nil then
      log(bWriteLog and string.format("CentauriManager.OnGetMP present_level: %s", mpInfo.present_level))
      CentauriManager.getMPResultCode = tostring(mpInfo.ret)
      CentauriManager.present_level = mpInfo.present_level
      local TimeUtil = require("client.common.time_util")
      CentauriManager.CachedMPTimeStampLoaded = TimeUtil.OSTime()
    end
  end
  if CentauriManager.getMPResultCode == "0" then
    log(bWriteLog and "CentauriManager.OnGetMP success.")
  else
    log(bWriteLog and "CentauriManager.OnGetMP failed 3")
  end
  EventSystem:postEvent(EVENTTYPE_CENTAURI_NOTIFY, EVENTID_CENTAURI_GETMPINFO_NOTIFY, CentauriManager.getMPResultCode)
end
function CentauriManager.OnGetProductInfo(getProductInfoCallBack)
  log(bWriteLog and "CentauriManager received OnGetProductInfo" .. getProductInfoCallBack.productInfoJson)
  CentauriManager.productInfoJson = getProductInfoCallBack.productInfoJson
  local AOSSHOPMacros = require("client.slua.config.ClientMacros.AOSSHOPMacros")
  CentauriManager.productInfoParsed = json.decode(CentauriManager.productInfoJson)
  if CentauriManager.productInfoParsed ~= nil and CentauriManager.productInfoParsed.ret ~= nil and (CentauriManager.productInfoParsed.ret == "0" or CentauriManager.productInfoParsed.ret == 0) and CentauriManager.productInfoParsed.productInfo ~= nil and 0 < #CentauriManager.productInfoParsed.productInfo then
    local aosShop = Client.GetAOSSHOP()
    local country
    for i, v in pairs(CentauriManager.productInfoParsed.productInfo) do
      if aosShop == AOSSHOPMacros.Amazon then
        v.currency = ""
      end
      if v.productId ~= nil and v.currency ~= nil and v.price ~= nil then
        local bExistInCachedList = false
        for k, p in pairs(CentauriManager.CachedProductInfoList) do
          if p.productId == v.productId then
            bExistInCachedList = true
            p.currency = v.currency
            p.price = v.price
            p.microprice = v.microprice
            local TimeUtil = require("client.common.time_util")
            p.timeStampLoaded = TimeUtil.OSTime()
          end
        end
        if bExistInCachedList == false then
          local TimeUtil = require("client.common.time_util")
          local temp_ProductInfo = {
            productId = v.productId,
            currency = v.currency,
            price = v.price,
            microprice = v.microprice,
            timeStampLoaded = TimeUtil.OSTime()
          }
          table.insert(CentauriManager.CachedProductInfoList, temp_ProductInfo)
        end
      end
      if v.country ~= nil and v.country ~= CentauriManager.country then
        country = v.country
      end
    end
    if country ~= nil and country ~= CentauriManager.country then
      local RegionHandler = require("client.network.Protocol.RegionHandler")
      RegionHandler.send_set_shop_region_req(country)
    end
    if CentauriManager.productInfoParsed.productInfo[1].productId ~= nil then
      local productType = CentauriManager.GetProductType(CentauriManager.productInfoParsed.productInfo[1].productId)
      if productType == 1 then
        EventSystem:postEvent(EVENTTYPE_CENTAURI_NOTIFY, EVENTID_CENTAURI_GET_RECHARGE_PRODUCT_INFO_NOTIFY, CentauriManager.productInfoParsed.productInfo)
        return
      elseif productType == 2 then
        EventSystem:postEvent(EVENTTYPE_CENTAURI_NOTIFY, EVENTID_CENTAURI_GET_GOODS_PRODUCT_INFO_NOTIFY, CentauriManager.productInfoParsed.productInfo)
        return
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_CENTAURI_NOTIFY, EVENTID_CENTAURI_GET_RECHARGE_PRODUCT_INFO_NOTIFY, nil)
  EventSystem:postEvent(EVENTTYPE_CENTAURI_NOTIFY, EVENTID_CENTAURI_GET_GOODS_PRODUCT_INFO_NOTIFY, nil)
end
function CentauriManager.OnGetIntroPrice(getIntroPriceCallBack)
  log(bWriteLog and "CentauriManager received OnGetIntroPrice" .. getIntroPriceCallBack.introPriceJson)
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  local devicetype = 1
  if Client.GetDevicePlatformName() == DevicePlatformNameMacros.IOS then
    devicetype = 0
  end
  local introPriceJson = getIntroPriceCallBack.introPriceJson
  local introPriceJsonParsed = json.decode(introPriceJson)
  if introPriceJsonParsed == nil then
    log(bWriteLog and "CentauriManager.OnGetIntroPrice failed1")
    EventSystem:postEvent(EVENTTYPE_CENTAURI_NOTIFY, EVENTID_CENTAURI_GET_INTRO_PRICE_INFO_NOTIFY, false)
    return
  end
  if introPriceJsonParsed.ret == nil or introPriceJsonParsed.ret ~= "0" and introPriceJsonParsed.ret ~= 0 then
    log(bWriteLog and "CentauriManager.OnGetIntroPrice failed2")
    EventSystem:postEvent(EVENTTYPE_CENTAURI_NOTIFY, EVENTID_CENTAURI_GET_INTRO_PRICE_INFO_NOTIFY, false)
    return
  end
  local gwallet_eligibility_info = introPriceJsonParsed.gwallet_eligibility_info
  if not gwallet_eligibility_info and introPriceJsonParsed.encrypt_ret_msg then
    gwallet_eligibility_info = introPriceJsonParsed.encrypt_ret_msg.gwallet_eligibility_info
  end
  local ios_eligibility_info = introPriceJsonParsed.eligibility_info
  if not ios_eligibility_info and introPriceJsonParsed.encrypt_ret_msg then
    ios_eligibility_info = introPriceJsonParsed.encrypt_ret_msg.eligibility_info
  end
  local mainEligibilityInfo = gwallet_eligibility_info
  local priceInfo = introPriceJsonParsed.gwallet_productInfo
  if devicetype == 0 then
    mainEligibilityInfo = ios_eligibility_info
    priceInfo = introPriceJsonParsed.productInfo
  end
  if mainEligibilityInfo ~= nil and 0 < #mainEligibilityInfo then
    for i, v in pairs(mainEligibilityInfo) do
      if v.productid ~= nil and (v.num ~= nil or v.intro_num ~= nil) then
        local bFoundInCache = false
        local cachedIntroPrice
        for k, p in pairs(CentauriManager.CachedIntroPriceList) do
          if v.productid == p.productId then
            bFoundInCache = true
            cachedIntroPrice = p
          end
        end
        if not bFoundInCache then
          cachedIntroPrice = {
            productId = v.productid,
            microprice = 0,
            currency = "",
            price = "",
            intro_price = "",
            intro_gwallet_num = 0,
            intro_ios_num = 0,
            timeStampLoaded = 0,
            isValid = false,
            isBillingV5 = false,
            basePlanId = "p1m",
            offerId = ""
          }
          table.insert(CentauriManager.CachedIntroPriceList, cachedIntroPrice)
        end
        cachedIntroPrice.isValid = false
        local TimeUtil = require("client.common.time_util")
        cachedIntroPrice.timeStampLoaded = TimeUtil.OSTime()
        local bFoundInMainEligibility = false
        if ios_eligibility_info then
          for k, p in pairs(ios_eligibility_info) do
            if p.productid == cachedIntroPrice.productId and p.num ~= nil then
              cachedIntroPrice.intro_ios_num = p.num
              if devicetype == 0 then
                bFoundInMainEligibility = true
              end
            end
          end
        end
        if gwallet_eligibility_info ~= nil then
          for k, p in pairs(gwallet_eligibility_info) do
            if p.productid == cachedIntroPrice.productId and p.intro_num ~= nil then
              cachedIntroPrice.intro_gwallet_num = p.intro_num
              if devicetype == 1 then
                bFoundInMainEligibility = true
              end
            end
          end
        end
        if not bFoundInMainEligibility then
          log(bWriteLog and "CentauriManager.OnGetIntroPrice failed3 in main eligibility_info" .. cachedIntroPrice.productId)
          EventSystem:postEvent(EVENTTYPE_CENTAURI_NOTIFY, EVENTID_CENTAURI_GET_INTRO_PRICE_INFO_NOTIFY, false)
          return
        end
        bFoundInMainEligibility = false
        if priceInfo ~= nil then
          for k, p in pairs(priceInfo) do
            bFoundInMainEligibility = CentauriManager.ModifyCachedIntroPrice(cachedIntroPrice, p, bFoundInMainEligibility)
          end
        end
        if not bFoundInMainEligibility then
          log(bWriteLog and "CentauriManager.OnGetIntroPrice failed4")
          EventSystem:postEvent(EVENTTYPE_CENTAURI_NOTIFY, EVENTID_CENTAURI_GET_INTRO_PRICE_INFO_NOTIFY, false)
          return
        end
        cachedIntroPrice.isValid = true
      end
    end
  else
    log(bWriteLog and "CentauriManager.OnGetIntroPrice failed5 eligibility_info is null or empty.")
    EventSystem:postEvent(EVENTTYPE_CENTAURI_NOTIFY, EVENTID_CENTAURI_GET_INTRO_PRICE_INFO_NOTIFY, false)
    return
  end
  EventSystem:postEvent(EVENTTYPE_CENTAURI_NOTIFY, EVENTID_CENTAURI_GET_INTRO_PRICE_INFO_NOTIFY, true)
end
function CentauriManager.ModifyCachedIntroPrice(cachedIntroPrice, p, InFoundInMainEligibility)
  local foundInMainEligibility = InFoundInMainEligibility
  if p.productId == cachedIntroPrice.productId then
    if p.subscriptionOfferDetails ~= nil then
      log(bWriteLog and "CentauriManager.ModifyCachedIntroPrice set price with billing v5")
      cachedIntroPrice.isBillingV5 = true
      local priceDataAfterFilter = CentauriManager.GetSubscriptionOffer(p.productId, p.subscriptionOfferDetails)
      cachedIntroPrice.basePlanId = priceDataAfterFilter.basePlanId
      if priceDataAfterFilter.offerId ~= nil then
        cachedIntroPrice.offerId = priceDataAfterFilter.offerId
      end
      local pricingPhase = priceDataAfterFilter.pricingPhases[1]
      local originalPricingPhase
      if pricingPhase.recurrenceMode and pricingPhase.recurrenceMode ~= 1 then
        for k, v in pairs(priceDataAfterFilter.pricingPhases) do
          if v.recurrenceMode and v.recurrenceMode == 1 then
            originalPricingPhase = v
            break
          end
        end
      end
      if pricingPhase.priceCurrencyCode ~= nil and pricingPhase.formattedPrice ~= nil then
        cachedIntroPrice.currency = pricingPhase.priceCurrencyCode
        cachedIntroPrice.price = pricingPhase.formattedPrice
        cachedIntroPrice.microprice = pricingPhase.priceAmountMicros
        if originalPricingPhase ~= nil then
          cachedIntroPrice.price = originalPricingPhase.formattedPrice
          cachedIntroPrice.intro_price = pricingPhase.formattedPrice
        end
        foundInMainEligibility = true
      end
    elseif p.currency ~= nil and p.price ~= nil then
      cachedIntroPrice.currency = p.currency
      cachedIntroPrice.price = p.price
      cachedIntroPrice.microprice = p.microprice
      if p.introPrice ~= nil then
        cachedIntroPrice.intro_price = p.introPrice
      end
      foundInMainEligibility = true
    end
  end
  return foundInMainEligibility
end
function CentauriManager.GetSubscriptionOffer(product, subscriptionOfferDetails)
  local result = subscriptionOfferDetails[1]
  local appRegion = Client.GetPublishRegion()
  local offeridConfig = CDataTable.GetTable("SubscribePlan")
  local found = false
  for k, v in pairs(subscriptionOfferDetails) do
    for ck, cv in pairs(offeridConfig) do
      if product == cv.productId and appRegion == cv.region and v.basePlanId == cv.basePlanId and v.offerId == cv.offerId then
        result = v
        found = true
        break
      end
    end
    if found then
      break
    end
  end
  if 1 < #subscriptionOfferDetails and Client.IsDevelopment() and found == false then
    local crashtable = {}
    local a = crashtable.basePlanNumIsLargerThan1() + 1
  end
  return result
end
function CentauriManager.OnApplicationEnterForeground()
  local platformName = Client.GetDevicePlatformName()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if platformName == DevicePlatformNameMacros.Android then
    local RechargeSystem = require("client.logic.recharge.logic_recharge")
    local isShow = RechargeSystem.isRechargeUIShowing()
    if GameStatus.IsInLobbyOrMainCity() and isShow == false then
      log(bWriteLog and "CentauriManager try to reprovide.")
      CentauriManager.Reprovide()
    end
  end
  if CentauriManager.IsEUPsd2Enable() then
    if CentauriManager.IsInCentauriPaying == true or CentauriManager.HitIOSPsd2Error == true then
      CentauriManager.HitAppFrontGroundAfterPay = true
    end
    CentauriManager.TryStartIOSPsd2RechargeTimer()
  end
end
function CentauriManager.Reprovide()
  local logic_payment_api = require("client.logic.pay.logic_payment_api")
  local payChannel = logic_payment_api:get_Centauri_pay_channel()
  if payChannel == "os_offical" then
    logic_payment_api:Centauri_reprovide()
  end
end
function CentauriManager.OnReprovide(_)
  local CentauriHandler = require("client.network.Protocol.CentauriHandler")
  CentauriHandler.send_imobile_notify_client_charge(0)
end
function CentauriManager.GetProductType(productId)
  local rechargeTable
  rechargeTable = FuncUtil.GetRechargeLevelTable()
  if rechargeTable ~= nil then
    for i, v in pairs(rechargeTable) do
      if v.rechargeKey == productId then
        return 1
      end
    end
  end
  return 2
end
function CentauriManager.ShouldShowLocalCurrency(currency)
  local AOSSHOPMacros = require("client.slua.config.ClientMacros.AOSSHOPMacros")
  if Client.GetAOSSHOP() == AOSSHOPMacros.Amazon then
    return true
  end
  if currency == nil then
    return false
  end
  for k, v in pairs(CentauriManager.localCurrencyArray) do
    if v == currency then
      return true
    end
  end
  return false
end
function CentauriManager.GetPriceByProductId(productId, currency, oldPrice, needReload)
  log(bWriteLog and "CentauriManager.GetPriceByProductId productId:" .. tostring(productId))
  local result, productInfos = CentauriManager.LoadCachedCentauriProductInfo(productId)
  if not (result and productInfos) or #productInfos <= 0 then
    if needReload then
      if CentauriManager.GetPriceByProductIdTimerStarted then
        local hasExist = false
        for _, v in ipairs(CentauriManager.GetPriceByProductIds) do
          if v == CentauriManager.GetPriceByProductIds then
            hasExist = true
            break
          end
        end
        if not hasExist then
          table.insert(CentauriManager.GetPriceByProductIds, productId)
        end
      else
        local funcCall = function()
          local logic_payment_api = require("client.logic.pay.logic_payment_api")
          logic_payment_api:load_Centauri_product_info(table.concat(CentauriManager.GetPriceByProductIds, ","))
          CentauriManager.GetPriceByProductIdTimerStarted = false
          CentauriManager.GetPriceByProductIds = {}
        end
        local time_ticker = require("common.time_ticker")
        time_ticker.AddTimerOnce(0.2, funcCall)
        table.insert(CentauriManager.GetPriceByProductIds, productId)
        CentauriManager.GetPriceByProductIdTimerStarted = true
      end
    end
  else
    local info = productInfos[1]
    log(bWriteLog and "CentauriManager.GetPriceByProductId price:" .. tostring(info.price))
    return info.price or oldPrice, info.currency or currency
  end
  log(bWriteLog and "CentauriManager.GetPriceByProductId oldPrice:" .. tostring(oldPrice))
  return oldPrice, currency
end
function CentauriManager.LoadCachedCentauriProductInfo(productList)
  if productList == nil then
    log(bWriteLog and "CentauriManager.LoadCachedCentauriProductInfo failed1")
    return false, nil
  end
  local productarr = StringUtil.Split(productList, ",")
  if productarr == nil then
    log(bWriteLog and "CentauriManager.LoadCachedCentauriProductInfo failed2")
    return false, nil
  end
  local notExpiredCount = 0
  local cachedProductInfoList = {}
  local TimeUtil = require("client.common.time_util")
  local curTimestamp = TimeUtil.OSTime()
  for i, v in pairs(productarr) do
    for k, productInfo in pairs(CentauriManager.CachedProductInfoList) do
      if v == productInfo.productId and curTimestamp < productInfo.timeStampLoaded + CentauriManager.CachedProductInfoExpireTime then
        notExpiredCount = notExpiredCount + 1
        local cachedProductInfo = {
          productId = productInfo.productId,
          currency = productInfo.currency,
          price = productInfo.price,
          microprice = productInfo.microprice,
          isBillingV5 = productInfo.isBillingV5,
          basePlanId = productInfo.basePlanId,
          offerId = productInfo.offerId
        }
        table.insert(cachedProductInfoList, cachedProductInfo)
      end
    end
  end
  if notExpiredCount == #productarr then
    log(bWriteLog and "CentauriManager.LoadCachedCentauriProductInfo success.")
    return true, cachedProductInfoList
  end
  log(bWriteLog and "CentauriManager.LoadCachedCentauriProductInfo failed3")
  return false, nil
end
function CentauriManager.LoadCachedCentauriIntroPrice(productList)
  log_tree("CentauriManager.LoadCachedCentauriIntroPrice ", productList)
  if productList == nil then
    log(bWriteLog and "CentauriManager.LoadCachedCentauriIntroPrice failed1")
    return false, nil
  end
  local productarr = StringUtil.Split(productList, ",")
  if productarr == nil then
    log(bWriteLog and "CentauriManager.LoadCachedCentauriIntroPrice failed2")
    return false, nil
  end
  local notExpiredCount = 0
  local cachedProductInfoList = {}
  local TimeUtil = require("client.common.time_util")
  local curTimestamp = TimeUtil.OSTime()
  for i, v in pairs(productarr) do
    for k, productInfo in pairs(CentauriManager.CachedIntroPriceList) do
      if v == productInfo.productId and productInfo.isValid == true and curTimestamp < productInfo.timeStampLoaded + CentauriManager.CachedIntroPriceListExpireTime then
        notExpiredCount = notExpiredCount + 1
        local cachedProductInfo = {
          productId = productInfo.productId,
          currency = productInfo.currency,
          price = productInfo.price,
          microprice = productInfo.microprice,
          intro_price = productInfo.intro_price,
          intro_ios_num = productInfo.intro_ios_num,
          intro_gwallet_num = productInfo.intro_gwallet_num,
          isBillingV5 = productInfo.isBillingV5,
          basePlanId = productInfo.basePlanId,
          offerId = productInfo.offerId
        }
        table.insert(cachedProductInfoList, cachedProductInfo)
      end
    end
  end
  if notExpiredCount == #productarr then
    log(bWriteLog and "CentauriManager.LoadCachedCentauriIntroPrice success.")
    return true, cachedProductInfoList
  end
  log(bWriteLog and "CentauriManager.LoadCachedCentauriIntroPrice failed3")
  return false, nil
end
function CentauriManager.LoadCachedSubscribeStoreInfo(productId)
  local subscribeStoreInfo = {
    isBillingV5 = false,
    basePlanId = "p1m",
    gwOfferId = ""
  }
  if productId == nil or productId == "" then
    log(bWriteLog and "CentauriManager.LoadCachedSubscribeStoreInfo product id is empty")
    return subscribeStoreInfo
  end
  for k, productInfo in pairs(CentauriManager.CachedIntroPriceList) do
    if productId == productInfo.productId then
      subscribeStoreInfo.isBillingV5 = productInfo.isBillingV5
      subscribeStoreInfo.basePlanId = productInfo.basePlanId
      subscribeStoreInfo.gwOfferId = productInfo.offerId
      break
    end
  end
  local AOSSHOPMacros = require("client.slua.config.ClientMacros.AOSSHOPMacros")
  if Client.GetAOSSHOP() ~= AOSSHOPMacros.ThirdPartyPayment and Client.GetAOSSHOP() ~= AOSSHOPMacros.Google then
    subscribeStoreInfo.isBillingV5 = false
    subscribeStoreInfo.basePlanId = ""
    subscribeStoreInfo.gwOfferId = ""
  end
  return subscribeStoreInfo
end
function CentauriManager.IsMPExpire()
  if string.len(CentauriManager.getMPResultCode) == 0 or CentauriManager.getMPResultCode ~= "0" then
    return true
  end
  if string.len(CentauriManager.present_level) == 0 then
    return true
  end
  local TimeUtil = require("client.common.time_util")
  if TimeUtil.OSTime() < CentauriManager.CachedMPTimeStampLoaded + CentauriManager.CachedMPExpireTime then
    return false
  end
  return true
end
function CentauriManager.H5PayEnable()
  local AOSSHOPMacros = require("client.slua.config.ClientMacros.AOSSHOPMacros")
  local logic_cloud_game = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cloud_game)
  if logic_cloud_game:GetCloudGameType() == logic_cloud_game.CLOUD_GAME_TYPE.PIONEER_CLOUD then
    if logic_cloud_game:GetClientType() == logic_cloud_game.CLIENT_TYPE.MICRO_CLIENT then
      return false
    elseif logic_cloud_game:GetClientType() == logic_cloud_game.CLIENT_TYPE.WEB then
      return true
    end
  end
  if Client.GetAOSSHOP() == AOSSHOPMacros.ThirdPartyPayment then
    return true
  end
  if Client.GetAOSSHOP() == AOSSHOPMacros.HMS then
    return HDmpveRemote.HDmpveRemoteConfigGetBool("EnableH5PayInHMS", false)
  end
  return false
end
function CentauriManager.ShouldDirectlyShowH5Pay()
  if CentauriManager.H5PayEnable() then
    local logic_cloud_game = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cloud_game)
    if logic_cloud_game:GetCloudGameType() == logic_cloud_game.CLOUD_GAME_TYPE.PIONEER_CLOUD then
      if logic_cloud_game:GetClientType() == logic_cloud_game.CLIENT_TYPE.MICRO_CLIENT then
        return false
      elseif logic_cloud_game:GetClientType() == logic_cloud_game.CLIENT_TYPE.WEB then
        return true
      end
    end
    if CentauriManager.GetCurrentPayChannel() ~= CentauriManager.E_PayChannel.GP then
      return true
    end
  end
  return false
end
function CentauriManager.SwitchPayChannel(channel)
  if CentauriManager.CurrentPayChannel ~= channel and channel ~= nil then
    CentauriManager.CurrentPayChannel = channel
    local lastPayChannelKey = "LastPayChannel"
    local PlayerPrefs = require("client.logic.LogicPlayerPrefs.playerprefs")
    local personalRecords = PlayerPrefs.LoadFileToTable_N(PlayerPrefs.ePlayerPrefsType.ePersonalRecord)
    if personalRecords == nil then
      personalRecords = {}
    end
    personalRecords[lastPayChannelKey] = CentauriManager.CurrentPayChannel
    PlayerPrefs.SaveTableToFile_N(personalRecords, PlayerPrefs.ePlayerPrefsType.ePersonalRecord)
  end
end
function CentauriManager.GetCurrentPayChannel()
  if CentauriManager.CurrentPayChannel ~= nil then
    return CentauriManager.CurrentPayChannel
  end
  local lastPayChannelKey = "LastPayChannel"
  local PlayerPrefs = require("client.logic.LogicPlayerPrefs.playerprefs")
  local personalRecords = PlayerPrefs.LoadFileToTable_N(PlayerPrefs.ePlayerPrefsType.ePersonalRecord)
  if personalRecords ~= nil and personalRecords[lastPayChannelKey] ~= nil then
    CentauriManager.CurrentPayChannel = personalRecords[lastPayChannelKey]
  end
  if CentauriManager.CurrentPayChannel == nil then
    CentauriManager.CurrentPayChannel = CentauriManager.E_PayChannel.H5
    if personalRecords == nil then
      personalRecords = {}
    end
    personalRecords[lastPayChannelKey] = CentauriManager.CurrentPayChannel
    PlayerPrefs.SaveTableToFile_N(personalRecords, PlayerPrefs.ePlayerPrefsType.ePersonalRecord)
  end
  return CentauriManager.CurrentPayChannel
end
local FormatNumberThousands = function(num)
  local formatted = tostring(num or 0)
  local k
  while true do
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
    if k == 0 then
      break
    end
  end
  return formatted
end
function CentauriManager.TransformPrice(priceDesc, discount)
  local priceTemp = priceDesc
  local priceNumDesc = string.gsub(priceTemp, "[,]?%s?", "")
  local priceNum = string.match(priceNumDesc, "(%d+[.]?%d*)") or 0
  local price = tonumber(priceNum)
  discount = tonumber(discount) or 1
  if nil ~= price and 0 ~= discount then
    local defaultNum = string.format("%.2f", tonumber(priceNum) / discount)
    local formatNum = FormatNumberThousands(defaultNum)
    formatNum = string.gsub(priceNumDesc, priceNum, formatNum)
    return formatNum
  end
  return priceDesc
end
function CentauriManager.on_report_reject_charge(reportResult)
  log(bWriteLog and "on_report_reject_charge: " .. reportResult)
end
function CentauriManager.HasIllegalChar(inputstr)
  local lenInByte = #inputstr
  local i = 1
  local chinese1 = tonumber("E4B880", 16)
  local chinese2 = tonumber("E9BEBF", 16)
  local chineseSymbol = {
    "EFBC81",
    "EFBFA5",
    "E280A6",
    "E280A6",
    "EFBC88",
    "EFBC89",
    "E28094",
    "EFBD9B",
    "EFBD9D",
    "EFBC9A",
    "E2809C",
    "E2809D",
    "E3808A",
    "E3808B",
    "EFBC9F",
    "E38090",
    "E38091",
    "E38081",
    "EFBC9B",
    "E28098",
    "EFBC8C",
    "E38082",
    "E38081",
    "E28099"
  }
  local janpan1 = tonumber("E38180", 16)
  local janpan2 = tonumber("E3829F", 16)
  local janpan3 = tonumber("E382A0", 16)
  local janpan4 = tonumber("E383BF", 16)
  local janpan5 = tonumber("E38080", 16)
  local janpan6 = tonumber("E380BF", 16)
  local fullWidthNum1 = tonumber("EFBC90", 16)
  local fullWidthNum2 = tonumber("EFBC99", 16)
  local fullWidthClatin1 = tonumber("EFBCA1", 16)
  local fullWidthClatin2 = tonumber("EFBCBA", 16)
  local fullWidthSlatin1 = tonumber("EFBD81", 16)
  local fullWidthSlatin2 = tonumber("EFBD9A", 16)
  local halfWidthKata1 = tonumber("EFBDA6", 16)
  local halfWidthKata2 = tonumber("EFBE9D", 16)
  local korean1 = tonumber("EAB080", 16)
  local korean2 = tonumber("ED9EAF", 16)
  local russia1 = tonumber("D080", 16)
  local russia2 = tonumber("D3Bf", 16)
  local russia3 = tonumber("D480", 16)
  local russia4 = tonumber("D4AF", 16)
  local tai1 = tonumber("E0B880", 16)
  local tai2 = tonumber("E0B9BF", 16)
  local EU_specail1 = tonumber("C2A1", 16)
  local EU_specail2 = tonumber("CAAf", 16)
  local Vietnamese1 = tonumber("E1B880", 16)
  local Vietnamese2 = tonumber("E1BBBF", 16)
  local Vietnamese3 = tonumber("CC80", 16)
  local Vietnamese4 = tonumber("CDBA", 16)
  local hindi1 = tonumber("E0A480", 16)
  local hindi2 = tonumber("E0A5BF", 16)
  local arabic1 = tonumber("D880", 16)
  local arabic2 = tonumber("DBBF", 16)
  while lenInByte >= i do
    local a = string.byte(inputstr, i)
    local byteCount = 1
    if 0 <= a and a < 192 then
      byteCount = 1
    elseif 192 <= a and a < 224 then
      byteCount = 2
      local b = string.byte(inputstr, i + 1)
      local str = string.format("%X", a) .. string.format("%X", b)
      local value = tonumber(str, 16)
      local isok = false
      if russia1 <= value and russia2 >= value or russia3 <= value and russia4 >= value then
        isok = true
      elseif EU_specail1 <= value and EU_specail2 >= value then
        isok = true
      elseif Vietnamese3 <= value and Vietnamese4 >= value then
        isok = true
      elseif arabic1 <= value and arabic2 >= value then
        isok = true
      end
      if not isok then
        return true
      end
    elseif 224 <= a and a < 240 then
      byteCount = 3
      local b = string.byte(inputstr, i + 1)
      local c = string.byte(inputstr, i + 2)
      local str = string.format("%X", a) .. string.format("%X", b) .. string.format("%X", c)
      local value = tonumber(str, 16)
      local isok = false
      if chinese1 <= value and chinese2 >= value then
        isok = true
      elseif janpan1 <= value and janpan2 >= value then
        isok = true
      elseif janpan3 <= value and janpan4 >= value then
        isok = true
      elseif janpan5 <= value and janpan6 >= value then
        isok = true
      elseif fullWidthNum1 <= value and fullWidthNum2 >= value then
        isok = true
      elseif fullWidthClatin1 <= value and fullWidthClatin2 >= value then
        isok = true
      elseif fullWidthSlatin1 <= value and fullWidthSlatin2 >= value then
        isok = true
      elseif halfWidthKata1 <= value and halfWidthKata2 >= value then
        isok = true
      elseif tai1 <= value and tai2 >= value then
        isok = true
      elseif Vietnamese1 <= value and Vietnamese2 >= value then
        isok = true
      elseif korean1 <= value and korean2 >= value then
        isok = true
      elseif hindi1 <= value and hindi2 >= value then
        isok = true
      end
      if not isok then
        for i, v in ipairs(chineseSymbol) do
          if value == tonumber(v, 16) then
            isok = true
            break
          end
        end
      end
      if not isok then
        return true
      end
    elseif 240 <= a and a < 248 then
      byteCount = 4
      return true
    elseif 248 <= a and a < 252 then
      byteCount = 5
      return true
    elseif 252 <= a then
      byteCount = 6
      return true
    end
    i = i + byteCount
  end
  return false
end
function CentauriManager.ProcessSpecialDisplaySetting(rechargeDataList)
  log(bWriteLog and "CentauriManager.ProcessSpecialDisplayDisplayList called")
  local nCumulativeValue = DataMgr.last_30days_recharge_amount
  log(bWriteLog and " CentauriManager.ProcessSpecialDisplaySetting nCumulativeValue >>> " .. tostring(nCumulativeValue))
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local tLocalCache = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eRechargeRecord) or {}
  local nLastChangeTime = tLocalCache.nLastChangeTime or 0
  local TimeUtil = require("client.common.time_util")
  local nCurTime = TimeUtil.GetServerTimeInSec()
  local bIFreeRep = 1296000 < nCurTime - nLastChangeTime
  local sLastRechargeKey = tLocalCache.sLastRechargeKey or ""
  log(bWriteLog and " nCurTime: " .. nCurTime .. " >>> nLastChangeTime: " .. nLastChangeTime .. " DiffTime >>> " .. nCurTime - nLastChangeTime)
  log(bWriteLog and " bIFreeRep >>>>" .. tostring(bIFreeRep) .. " and sLastRechargeKey >>>> " .. sLastRechargeKey)
  local sCountry = DataMgr.RegionData and DataMgr.RegionData.region or "DEFAULT"
  log(bWriteLog and " ProcessSpecialDisplaySetting sCountry >>> " .. sCountry)
  local AOSSHOPMacros = require("client.slua.config.ClientMacros.AOSSHOPMacros")
  local sAOSSHOP = Client.GetAOSSHOP()
  local bIsCanCumulativeReplace = true
  if sAOSSHOP == AOSSHOPMacros.Samsung or sAOSSHOP == AOSSHOPMacros.Amazon or sAOSSHOP == AOSSHOPMacros.HMS or sAOSSHOP == AOSSHOPMacros.ThirdPartyPayment then
    bIsCanCumulativeReplace = false
  end
  log(bWriteLog and " ProcessSpecialDisplaySetting bIsCanCumulativeReplace >>>>" .. tostring(bIsCanCumulativeReplace) .. " sAOSSHOP >>> " .. sAOSSHOP)
  local returnRechargeData = CentauriManager.GetCountryRechargeList(rechargeDataList, sCountry, bIsCanCumulativeReplace)
  local isUnpaidForThisVersion = CentauriManager.GetAndTryUpdateUnpaidFlagForCurrenVersion()
  log(bWriteLog and "CentauriManager.ProcessSpecialDisplayDisplayList isUnpaidForThisVersion = " .. tostring(isUnpaidForThisVersion))
  local tOriginalList = {}
  local tRepList = {}
  local sDevPlatform = Client.GetDevicePlatformName()
  for _, v in pairs(returnRechargeData) do
    local tReplaceCfg = CDataTable.GetTableByFilter("RechargeSpecialDisplay", "rechargeKey", v.rechargeKey, "osplatform", sDevPlatform, "region", sCountry)
    local nCurCompNum = 0
    for _, tTempCfg in pairs(tReplaceCfg) do
      local bIsReplace = false
      if tTempCfg.rule == Enum_Rule.Unpaid and isUnpaidForThisVersion then
        bIsReplace = true
      elseif bIsCanCumulativeReplace and tTempCfg.rule == Enum_Rule.Accumulated and nCumulativeValue >= tonumber(tTempCfg.repCondition) and nCurCompNum < tonumber(tTempCfg.repCondition) and (bIFreeRep or tTempCfg.replaceRechargeKey == sLastRechargeKey) and tTempCfg.rechargeVisible ~= tTempCfg.replaceRechargeVisible then
        nCurCompNum = tonumber(tTempCfg.repCondition)
        bIsReplace = true
        if bIFreeRep then
          tLocalCache.nLastChangeTime = nCurTime
          tLocalCache.sLastRechargeKey = tTempCfg.replaceRechargeKey
        end
      end
      if bIsReplace then
        tRepList[tTempCfg.replaceRechargeKey] = tTempCfg.replaceRechargeVisible
        if not tOriginalList[v.rechargeKey] then
          tOriginalList[v.rechargeKey] = {
            rechargeVisible = tTempCfg.rechargeVisible,
            sShowListKey = tTempCfg.replaceRechargeKey
          }
        else
          local sDeleteKey = tOriginalList[v.rechargeKey].sShowListKey
          tRepList[sDeleteKey] = nil
          tOriginalList[v.rechargeKey].rechargeVisible = tTempCfg.rechargeVisible
          tOriginalList[v.rechargeKey].sShowListKey = tTempCfg.replaceRechargeKey
        end
      end
    end
  end
  PlayerPrefsSystem.SaveTableToFile_N(tLocalCache, PlayerPrefsSystem.ePlayerPrefsType.eRechargeRecord)
  for _, v in pairs(returnRechargeData) do
    if tOriginalList[v.rechargeKey] then
      v.visible = tOriginalList[v.rechargeKey].rechargeVisible
      log(bWriteLog and " ProcessSpecialDisplaySetting Change 1 >>>> " .. v.rechargeKey .. " IsShow >>>" .. tostring(v.visible))
    end
    if tRepList[v.rechargeKey] then
      v.visible = tRepList[v.rechargeKey]
      log(bWriteLog and " ProcessSpecialDisplaySetting Change 2 >>>> " .. v.rechargeKey .. " IsShow >>>" .. tostring(v.visible))
    end
  end
  return returnRechargeData
end
function CentauriManager.GetCountryRechargeList(rechargeDataList, sCountry, bIsCanCumulativeReplace)
  if not rechargeDataList then
    return {}
  end
  local returnRechargeData = {}
  local tDefaultData = {}
  for _, v in pairs(rechargeDataList) do
    if v.effectiveCountry then
      if v.effectiveCountry == sCountry then
        local rechargeItem = CentauriManager.CopyRechargeItem(v)
        table.insert(returnRechargeData, rechargeItem)
      elseif v.effectiveCountry == "DEFAULT" then
        local rechargeItem = CentauriManager.CopyRechargeItem(v)
        table.insert(tDefaultData, rechargeItem)
      end
    else
      local rechargeItem = CentauriManager.CopyRechargeItem(v)
      table.insert(tDefaultData, rechargeItem)
    end
  end
  log_tree(" CentauriManager.GetCountryRechargeList returnRechargeData :", returnRechargeData)
  log_tree(" CentauriManager.GetCountryRechargeList tDefaultData:", tDefaultData)
  if not next(returnRechargeData) or not bIsCanCumulativeReplace then
    returnRechargeData = tDefaultData
    log(bWriteLog and " CentauriManager.GetCountryRechargeList Get Default >>> " .. tostring(bIsCanCumulativeReplace))
  end
  return returnRechargeData
end
function CentauriManager.CopyRechargeItem(RechargeItem)
  local item = {
    rechargeId = RechargeItem.rechargeId,
    zoneId = RechargeItem.zoneId,
    rechargeKey = RechargeItem.rechargeKey,
    name = RechargeItem.name,
    buyNum = RechargeItem.buyNum,
    money = RechargeItem.money,
    monetaryUint = RechargeItem.monetaryUint,
    country = RechargeItem.country,
    monetarySymbol = RechargeItem.monetarySymbol,
    iconURL = RechargeItem.iconURL,
    visible = RechargeItem.visible
  }
  return item
end
function CentauriManager.GetAndTryUpdateUnpaidFlagForCurrenVersion()
  local unpaidForCurrentVersion = true
  local unpaidRecordKey = "LatestUnpaidVersion"
  local PlayerPrefs = require("client.logic.LogicPlayerPrefs.playerprefs")
  local personalRecords = PlayerPrefs.LoadFileToTable_N(PlayerPrefs.ePlayerPrefsType.ePersonalRecord)
  local unpaidVersion
  if personalRecords ~= nil then
    unpaidVersion = personalRecords[unpaidRecordKey]
  end
  if DataMgr.Recharge == 0 or CentauriManager.IsRechargedForThisRuntime == true then
    if unpaidVersion ~= nil and unpaidVersion == Client.GetAppVersion() then
      unpaidForCurrentVersion = true
    else
      unpaidForCurrentVersion = false
    end
  else
    unpaidForCurrentVersion = true
  end
  if unpaidForCurrentVersion == true and (unpaidVersion == nil or unpaidVersion ~= nil and unpaidVersion ~= Client.GetAppVersion()) then
    log(bWriteLog and "[CentauriManager.GetAndTryUpdateUnpaidFlagForCurrenVersion] update version: " .. tostring(Client.GetAppVersion()))
    if personalRecords == nil then
      personalRecords = {}
    end
    personalRecords[unpaidRecordKey] = Client.GetAppVersion()
    PlayerPrefs.SaveTableToFile_N(personalRecords, PlayerPrefs.ePlayerPrefsType.ePersonalRecord)
  end
  return unpaidForCurrentVersion
end
function CentauriManager.UpdateRechargeProductId(productId)
  log(bWriteLog and "[CentauriManager.UpdateRechargeProductId] productId:" .. productId)
  CentauriManager.RechargeProductIdForLastTime = productId
  CentauriManager.IsProcessLocalOrder = false
  if string.len(productId) > 0 then
    CentauriManager.IsInCentauriPaying = true
    CentauriManager.HitAppFrontGroundAfterPay = false
    CentauriManager.HitIOSPsd2Error = false
    CentauriManager.CachedUserTickectNumBeforeBuy = DataMgr.ticket
  end
end
function CentauriManager.StartRequestNotifyClientRechargeTimer()
  log(bWriteLog and "CentauriManager.StartRequestNotifyClientRechargeTimer")
  local time_ticker = require("common.time_ticker")
  if CentauriManager.RequestNotifyClientChargeTimer ~= nil then
    CentauriManager.ClearRequestNotifyClientRechargeTimer()
  end
  CentauriManager.RequestNotifyClientChargeTimer = time_ticker.AddTimerOnce(10, function()
    if GameStatus.IsInLobbyOrMainCity() and CentauriManager.ticketNumBeforeUpdate == DataMgr.ticket then
      log(bWriteLog and "CentauriManager.StartRequestNotifyClientRechargeTimer SendPkg igame_notify_client_charge")
      local CentauriHandler = require("client.network.Protocol.CentauriHandler")
      CentauriHandler.send_imobile_notify_client_charge(0)
    end
    CentauriManager.ClearRequestNotifyClientRechargeTimer()
  end)
end
function CentauriManager.ClearRequestNotifyClientRechargeTimer()
  log(bWriteLog and "CentauriManager.ClearRequestNotifyClientRechargeTimer")
  local time_ticker = require("common.time_ticker")
  if CentauriManager.RequestNotifyClientChargeTimer ~= nil then
    time_ticker.RemoveTimer(CentauriManager.RequestNotifyClientChargeTimer)
    CentauriManager.RequestNotifyClientChargeTimer = nil
  end
end
function CentauriManager.IsEUPsd2Enable()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if Client.GetDevicePlatformName() ~= DevicePlatformNameMacros.IOS then
    log(bWriteLog and "Psd2 disable: platfrom not support")
    return false
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local strRegion = Client.GetPublishRegion()
  if strRegion ~= PublishRegionMacros.GLOBAL and strRegion ~= PublishRegionMacros.FIT then
    log(bWriteLog and "Psd2 disable: region not support")
    return false
  end
  if LobbySystem.CheckOpen(10235) ~= true then
    log(bWriteLog and "Psd2 disable: feature closed")
    return false
  end
  log(bWriteLog and "Psd2 disable: true")
  return true
end
function CentauriManager.UpdateAndCheckPayCallback(callbackType, resultCode, innerCode)
  if callbackType == CentauriManager.E_CentauriCallbackType.CB_Pay and resultCode == "100" and innerCode == "0" then
    CentauriManager.HitiOSPsd2Error = true
    CentauriManager.TryStartIOSPsd2RechargeTimer()
  end
end
function CentauriManager.TryStartIOSPsd2RechargeTimer()
  log(bWriteLog and "[CentauriManager] TryStartIOSPsd2RechargeTimer: " .. tostring(CentauriManager.HitiOSPsd2Error) .. "," .. tostring(CentauriManager.HitAppFrontGroundAfterPay) .. "," .. tostring(CentauriManager.IsInCentauriPaying))
  if CentauriManager.HitiOSPsd2Error == true and CentauriManager.HitAppFrontGroundAfterPay == true then
    CentauriManager.HitIOSPsd2Error = false
    CentauriManager.HitAppFrontGroundAfterPay = false
    logic_connection_waiting:Show(0)
    local time_ticker = require("common.time_ticker")
    CentauriManager.iOSPsd2QueryTicketNumTimer = time_ticker.AddTimerOnce(4, function()
      local CentauriHandler = require("client.network.Protocol.CentauriHandler")
      CentauriHandler.send_imobile_notify_client_charge(0)
      CentauriManager.ClearQueryTicketNumTimer()
    end)
    CentauriManager.iOSPsd2QueryTicketTimeOutTimer = time_ticker.AddTimerOnce(6, function()
      logic_connection_waiting:Hide(0)
      CentauriManager.ShowCommonPayErrorTip("")
      CentauriManager.CachedUserTickectNumBeforeBuy = DataMgr.ticket
      CentauriManager.ClearQueryTicketTimeoutTimer()
    end)
  else
    log(bWriteLog and "[CentauriManager] TryStartIOSPsd2RechargeTimer donothing")
  end
end
function CentauriManager.OnTicketUpdated()
  if CentauriManager.HitIOSPsd2Error == true then
    CentauriManager.HitIOSPsd2Error = false
    CentauriManager.ClearQueryTicketNumTimer()
    CentauriManager.ClearQueryTicketTimeoutTimer()
    if CentauriManager.CachedUserTickectNumBeforeBuy < DataMgr.ticket then
      logic_connection_waiting:Hide(0)
      ShowNotice(7687)
    end
    CentauriManager.CachedUserTickectNumBeforeBuy = DataMgr.ticket
  end
end
function CentauriManager.ClearQueryTicketNumTimer()
  if CentauriManager.iOSPsd2QueryTicketNumTimer ~= nil then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(CentauriManager.iOSPsd2QueryTicketNumTimer)
    CentauriManager.iOSPsd2QueryTicketNumTimer = nil
  end
end
function CentauriManager.ClearQueryTicketTimeoutTimer()
  if CentauriManager.iOSPsd2QueryTicketTimeOutTimer ~= nil then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(CentauriManager.iOSPsd2QueryTicketTimeOutTimer)
    CentauriManager.iOSPsd2QueryTicketTimeOutTimer = nil
  end
end
function CentauriManager.ReportPurchaseSuccEventToAdjust(PayProductId)
  log(bWriteLog and "[CentauriManager] ReportPurchaseSuccEventToAdjust #0")
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local PublishRegion = Client.GetPublishRegion()
  if PublishRegion ~= PublishRegionMacros.BLUEHOLE and PublishRegion ~= PublishRegionMacros.KOREA and PublishRegion ~= PublishRegionMacros.JAPAN and PublishRegion ~= PublishRegionMacros.VNG then
    log(bWriteLog and "[CentauriManager] ReportPurchaseSuccEventToAdjust return by not support region. " .. PublishRegion)
    return
  end
  if PayProductId == "none" or PayProductId == "" then
    log(bWriteLog and "[CentauriManager] ReportPurchaseSuccEventToAdjust return by payProducId is none")
    return
  end
  local isProductInfoCached, cachedProductInfoList = CentauriManager.LoadCachedCentauriProductInfo(PayProductId)
  if not isProductInfoCached then
    log(bWriteLog and "[CentauriManager] ReportPurchaseSuccEventToAdjust return by not cache price")
    return
  end
  if not cachedProductInfoList then
    log(bWriteLog and "[CentauriManager] ReportPurchaseSuccEventToAdjust return by cachedProductInfoList is nil")
    return
  end
  for k, product in pairs(cachedProductInfoList) do
    if product.productId == PayProductId and product.price ~= nil and product.currency ~= nil then
      local reportParams = {
        productId = product.productId
      }
      local extraJson = {
        productId = product.productId
      }
      log(bWriteLog and "[CentauriManager] ReportPurchaseSuccEventToAdjust call statmanager report revenue")
      local StatManager = import("StatManager")
      local price = 0
      if product.microprice ~= nil then
        log(bWriteLog and "[CentauriManager] ReportPurchaseSuccEventToAdjust price from microprice")
        price = tonumber(product.microprice) / 1000000
      else
        log(bWriteLog and "[CentauriManager] ReportPurchaseSuccEventToAdjust price from price")
        local number_str = string.match(product.price, "[%d,%.]+")
        number_str = string.gsub(number_str, ",", "")
        price = tonumber(number_str)
      end
      if price ~= nil and 0 < price then
        log(bWriteLog and string.format("[CentauriManager] ReportPurchaseSuccEventToAdjust call statmanager report revenue: %s, %s", product.currency, tostring(price)))
        StatManager.GetInstance():ReportRevenue(15, product.currency, price, reportParams, json.encode(extraJson))
      end
    end
  end
end
return CentauriManager