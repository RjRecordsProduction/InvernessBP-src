local logic_payment_config = require("client.logic.pay.logic_payment_config")
local logic_payment_api = logic_payment_api or {DEFAULT_JP_PAYMENT_AGE_LIMIT = 20, StoreCountryCode = nil}
function logic_payment_api:get_payment_sdk()
  local PaymentSDK = import("CentauriManager")
  return PaymentSDK.GetInstance()
end
function logic_payment_api:is_pay_test_env()
  return logic_payment_config:IsPayTestEnv()
end
function logic_payment_api:get_midasbuy_domain_id(release_id, test_id)
  if self:is_pay_test_env() then
    return test_id
  end
  return release_id
end
function logic_payment_api:CentauriSDKInit()
  local sdk = self:get_payment_sdk()
  sdk:SetPayEnvironment(logic_payment_config:GetPayEnvironment())
  sdk:SetInIDC(logic_payment_config:GetInIDC())
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  local strPlatform = Client.GetDevicePlatformName()
  if strPlatform == DevicePlatformNameMacros.Android then
    local svr_info = logic_payment_config:GetPaymentSvrInfo()
    log_tree(bWriteLog and "logic_payment_api:CentauriSDKInit svr_info = ", svr_info)
    sdk:SetIDCInfo(json.encode(svr_info))
  end
  sdk:Initialize(0, false)
  self.CurrentSDKWOWMode = false
end
logic_payment_api.SDK_READY_DELAY_MS = 500
logic_payment_api.SDKReadyAtMs = 0
local _now_ms = function()
  local TimeUtil = require("client.common.time_util")
  return TimeUtil.GetMiliseconds() or 0
end
function logic_payment_api:EnsureCentauriWOWMode(is_wow)
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  local strPlatform = Client.GetDevicePlatformName()
  if strPlatform ~= DevicePlatformNameMacros.Android then
    return false
  end
  local targetMode = is_wow == true
  if self.CurrentSDKWOWMode == targetMode then
    return false
  end
  log(bWriteLog and string.format("logic_payment_api:EnsureCentauriWOWMode switch SDK wow mode from %s to %s", tostring(self.CurrentSDKWOWMode), tostring(targetMode)))
  self:get_payment_sdk():Initialize(0, targetMode)
  self.CurrentSDKWOWMode = targetMode
  self.SDKReadyAtMs = _now_ms() + self.SDK_READY_DELAY_MS
  return true
end
function logic_payment_api:RunWhenCentauriReady(fn)
  if type(fn) ~= "function" then
    return
  end
  local waitMs = (self.SDKReadyAtMs or 0) - _now_ms()
  if waitMs <= 0 then
    fn()
    return
  end
  log(bWriteLog and string.format("logic_payment_api:RunWhenCentauriReady delay %dms for BillingClient reconnect", waitMs))
  local TimeTicker = require("common.time_ticker")
  TimeTicker.AddTimerOnce(waitMs / 1000.0, function()
    local ok, err = pcall(fn)
    if not ok then
      log(bWriteLog and "logic_payment_api:RunWhenCentauriReady fn error: " .. tostring(err))
    end
  end)
end
function logic_payment_api:set_Centauri_idc(idc)
  self:get_payment_sdk():SetInIDC(idc)
end
function logic_payment_api:set_Centauri_zoneid(zoneid, goods_zoneid)
  self:get_payment_sdk():SetZoneID(zoneid, goods_zoneid)
end
function logic_payment_api:get_Centauri_pf()
  return self:get_payment_sdk():getPF()
end
function logic_payment_api:get_Centauri_pay_channel()
  return self:get_payment_sdk():GetPayChannel()
end
logic_payment_api.ECentauriMultiPayChannelSwitch = {kCentauriPayChannelMain = 0, kCentauriPayChannelH5 = 1}
function logic_payment_api:SwitchPayChannel(switchChannel)
  log(bWriteLog and "logic_payment_api:SwitchPayChannel switchChannel = " .. tostring(switchChannel))
  self:get_payment_sdk():SwitchPayChannel(switchChannel)
end
function logic_payment_api:load_Centauri_product_info(product_list, is_subscrible, is_wow)
  local product_map_to_load_price = {}
  local string_util = require("common.string_util")
  product_list = self:attach_special_product_for_query_price(product_list, is_subscrible)
  local product_list_arr = string_util.Split(product_list, ",")
  for _, product_id in pairs(product_list_arr) do
    product_map_to_load_price[product_id] = self:get_product_type(is_subscrible)
  end
  log_tree("logic_payment_api:load_Centauri_product_info product_map_to_load_price = ", product_map_to_load_price)
  self:EnsureCentauriWOWMode(is_wow)
  self:RunWhenCentauriReady(function()
    self:get_payment_sdk():GetProductInfo(product_map_to_load_price, is_wow == true)
  end)
end
function logic_payment_api:load_Centauri_intro_price(product_list, is_subscrible, is_wow)
  local product_map_to_load_price = {}
  local string_util = require("common.string_util")
  product_list = self:attach_special_product_for_query_price(product_list, is_subscrible)
  local product_list_arr = string_util.Split(product_list, ",")
  for _, product_id in pairs(product_list_arr) do
    product_map_to_load_price[product_id] = self:get_product_type(is_subscrible)
  end
  log_tree("logic_payment_api:load_Centauri_intro_price product_map_to_load_price = ", product_map_to_load_price)
  self:EnsureCentauriWOWMode(is_wow)
  self:RunWhenCentauriReady(function()
    self:get_payment_sdk():GetIntroPrice(product_map_to_load_price, is_wow == true)
  end)
end
function logic_payment_api:load_Centauri_mp(country, moneytary_uint, is_wow)
  log(bWriteLog and "logic_payment_api:load_Centauri_mp is_wow = " .. tostring(is_wow))
  local mpCache = CentauriManager.GetMPCache(is_wow)
  if mpCache ~= nil and mpCache.isRequesting == true then
    log(bWriteLog and "logic_payment_api:load_Centauri_mp skip duplicated request, is_wow = " .. tostring(is_wow))
    return
  end
  local app_extends = ""
  local drm_info = ""
  if self:is_mpinfo_in_diff_area() then
    local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
    local strPlatform = Client.GetDevicePlatformName()
    if strPlatform == DevicePlatformNameMacros.IOS then
      app_extends = "drm_info=version%3D3.0"
    elseif strPlatform == DevicePlatformNameMacros.Android then
      drm_info = "version=3.0"
    end
  end
  CentauriManager.LastMPRequestIsWOW = is_wow == true
  if mpCache ~= nil then
    mpCache.isRequesting = true
  end
  self:EnsureCentauriWOWMode(is_wow)
  self:get_payment_sdk():GetMPInfo(country, moneytary_uint, app_extends, drm_info, is_wow == true)
end
function logic_payment_api:Goods(product_id, pay_item, price, country, currency, is_wow)
  local appExtends = self:get_common_pay_app_extends("goods")
  local channelExtras = string.format("payItem=%s*%s*%d", product_id, price, pay_item)
  local payItem = string.format("%s*%s*%d", product_id, price, pay_item)
  local logic_cloud_game = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cloud_game)
  channelExtras = logic_cloud_game:ActtachPaymentChannelExtra(channelExtras)
  local payChannel, payUrl = self:GetOptionPayParams("shop", product_id, is_wow)
  self:get_payment_sdk():Goods(product_id, payItem, price, country, currency, channelExtras, appExtends, payChannel, payUrl, is_wow == true)
end
function logic_payment_api:GoodsPresent(product_id, pay_item, price, country, currency, metaData, is_wow)
  local appExtends = self:get_common_pay_app_extends("goodspresent")
  local channelExtras = string.format("payItem=%s*%s*%d", product_id, price, pay_item)
  local payItem = string.format("%s*%s*%d", product_id, price, pay_item)
  local logic_cloud_game = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cloud_game)
  channelExtras = logic_cloud_game:ActtachPaymentChannelExtra(channelExtras)
  local payChannel, payUrl = self:GetOptionPayParams("shop", product_id, is_wow)
  self:get_payment_sdk():GoodsPresent(product_id, payItem, price, country, currency, metaData, channelExtras, appExtends, payChannel, payUrl, is_wow == true)
end
function logic_payment_api:Pay(product_id, pay_item, country, currency, is_wow)
  local appExtends = self:get_common_pay_app_extends("recharge")
  local channelExtras = string.format("payItem=%d", pay_item)
  local logic_cloud_game = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cloud_game)
  channelExtras = logic_cloud_game:ActtachPaymentChannelExtra(channelExtras)
  local payChannel, payUrl = self:GetOptionPayParams("buy", product_id, is_wow)
  log(bWriteLog and "logic_payment_api:Pay product_id = " .. tostring(product_id) .. " pay_item = " .. tostring(pay_item) .. " is_wow = " .. tostring(is_wow))
  self:get_payment_sdk():Pay(product_id, tostring(pay_item), country, currency, channelExtras, appExtends, payChannel, payUrl, is_wow == true)
end
function logic_payment_api:Subscribe(product_id, pay_item, country, currency, service_code, service_name, auto_pay, basePlanId, gw_offerid)
  local appExtends = self:get_common_pay_app_extends("subscribe")
  local channelExtras = string.format("payItem=%d", pay_item)
  local logic_cloud_game = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cloud_game)
  channelExtras = logic_cloud_game:ActtachPaymentChannelExtra(channelExtras)
  self:get_payment_sdk():Subscribe(product_id, tostring(pay_item), country, currency, service_code, service_name, auto_pay, basePlanId, gw_offerid, channelExtras, appExtends)
end
function logic_payment_api:ModifySubscribe(old_product, new_product, pay_item, country, currency, service_code, service_name, auto_pay, basePlanId, gw_offerid)
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  local strPlatform = Client.GetDevicePlatformName()
  if strPlatform == DevicePlatformNameMacros.IOS then
    self:Subscribe(new_product, pay_item, country, currency, service_code, service_name, auto_pay, basePlanId, gw_offerid)
  elseif strPlatform == DevicePlatformNameMacros.Android then
    local appExtends = self:get_common_pay_app_extends("subscribe")
    local channelExtras = string.format("OldSku=%s&SubcribeProrationMode=4", old_product)
    local logic_cloud_game = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cloud_game)
    channelExtras = logic_cloud_game:ActtachPaymentChannelExtra(channelExtras)
    self:get_payment_sdk():ModifySubscribe(new_product, country, currency, service_code, service_name, auto_pay, basePlanId, gw_offerid, channelExtras, appExtends)
  end
end
function logic_payment_api:H5Pay(country, is_wow)
  if not CentauriManager.H5PayEnable() then
    return
  end
  local AccountAnchorModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.AccountAnchorModule)
  if not AccountAnchorModule:CanRecharge() then
    ShowNotice(77737)
    return
  end
  local appExtends = self:get_common_pay_app_extends("h5pay")
  local roleNameAfterUrlEncode = Client.UrlEncode(DataMgr.roleData.nickName or "")
  local channelExtras = string.format("charac_id=%s&charac_name=%s", tostring(DataMgr.roleData.uid), roleNameAfterUrlEncode)
  local packageInstallChannel = Client.GetNativePackageTag()
  if packageInstallChannel ~= nil and 0 < #packageInstallChannel then
    channelExtras = string.format("%s&from=%s&sc=%s", channelExtras, packageInstallChannel, packageInstallChannel)
  end
  self:get_payment_sdk():H5Pay(country, channelExtras, appExtends, is_wow == true)
end
function logic_payment_api:GetOptionPayParams(pageid, product_id, is_wow)
  if not self:is_embed_h5_pay_allowed() then
    return "", ""
  end
  local payChannel = "os_web_channel"
  local form = "gamebr.events"
  local encodeparam = Client.GetWebViewTicket(NetInterface)
  local openid = DataMgr.roleData.openID
  local roleid = tostring(DataMgr.roleData.uid)
  local roleNameEncoded = DataMgr.roleData.nickName or ""
  local launchUrlScheme = Client.GetConfigString(Client.ProjectDir() .. "Config/DefaultEngine.ini", "/Script/AndroidRuntimeSettings.AndroidRuntimeSettings", "LaunchUrlScheme")
  local redirecturl = "schema:" .. launchUrlScheme .. "://"
  local zoneid = self:get_payment_sdk().zoneID
  local region = self:getRegionByCounteryCode(logic_payment_api.StoreCountryCode or "")
  local h5Offerid = self:get_payment_sdk().offerID_H5
  local offerid = self:get_payment_sdk().offerID
  if is_wow == true then
    h5Offerid = self:get_payment_sdk().offerID_WOWH5
    offerid = self:get_payment_sdk().offerID_WOW
  end
  local price_iap = self:get_product_price_by_product_id(product_id, is_wow)
  local paymentUrl, parameterTb
  local directToPayPage = false
  if directToPayPage then
    local from = "sdk_buy.topup"
    paymentUrl = FuncUtil.GetDomainByID(self:get_midasbuy_domain_id(3366245, 3366250))
    parameterTb = {
      shopcode = "pubgminapp",
      region = region,
      gameid = "pubgm",
      zoneid = zoneid,
      charac_name = roleNameEncoded,
      ticket = encodeparam,
      redirecturl = redirecturl,
      from = form,
      openid = openid,
      uid = roleid
    }
  else
    local from = "gamebr.events"
    paymentUrl = FuncUtil.GetDomainByID(self:get_midasbuy_domain_id(3366244, 3366249))
    parameterTb = {
      from = form,
      charac_name = roleNameEncoded,
      region = region,
      charac_id = roleid,
      redirecturl = redirecturl,
      appid = h5Offerid,
      shopcode = "pubgminapp",
      zoneid = zoneid,
      openid = openid,
      encodeparam = encodeparam,
      pageid = pageid,
      game_product_id = product_id,
      game_appid = offerid,
      game_product_price = price_iap
    }
  end
  local paramList = {}
  for key, value in pairs(parameterTb) do
    table.insert(paramList, string.format("%s=%s", key, Client.UrlEncode(tostring(value))))
  end
  local queryString = table.concat(paramList, "&")
  paymentUrl = paymentUrl .. "?" .. queryString
  return payChannel, paymentUrl
end
function logic_payment_api:getRegionByCounteryCode(countryCode)
  local ISO_3166_MAPPING = {
    usa = "us",
    can = "ca",
    mex = "mx",
    gbr = "gb",
    fra = "fr",
    deu = "de",
    ita = "it",
    esp = "es",
    nld = "nl",
    bel = "be",
    che = "ch",
    aut = "at",
    pol = "pl",
    swe = "se",
    nor = "no",
    dnk = "dk",
    fin = "fi",
    prt = "pt",
    grc = "gr",
    cze = "cz",
    hun = "hu",
    rou = "ro",
    rus = "ru",
    tur = "tr",
    chn = "cn",
    hkg = "hk",
    jpn = "jp",
    kor = "kr",
    ind = "in",
    idn = "id",
    tha = "th",
    vnm = "vn",
    mys = "my",
    sgp = "sg",
    phl = "ph",
    pak = "pk",
    bgd = "bd",
    npl = "np",
    mmr = "mm",
    lao = "la",
    khm = "kh",
    bra = "br",
    arg = "ar",
    chl = "cl",
    col = "co",
    per = "pe",
    ven = "ve",
    ecu = "ec",
    bol = "bo",
    pry = "py",
    ury = "uy",
    aus = "au",
    nzl = "nz",
    zaf = "za",
    egy = "eg",
    nga = "ng",
    ken = "ke",
    mar = "ma",
    eth = "et",
    tza = "tz",
    gha = "gh",
    dza = "dz",
    moz = "mz",
    ago = "ao",
    cod = "cd",
    cmr = "cm",
    civ = "ci",
    sen = "sn",
    zmb = "zm",
    zwe = "zw",
    uga = "ug",
    rwa = "rw",
    bfa = "bf",
    mli = "ml",
    ner = "ne",
    tcd = "td",
    sdn = "sd"
  }
  local lowerCode = string.lower(countryCode or "")
  return ISO_3166_MAPPING[lowerCode]
end
function logic_payment_api:Centauri_reprovide()
  self:get_payment_sdk():Reprovide()
end
function logic_payment_api:get_product_type(is_subscrible)
  if is_subscrible then
    return "subs"
  else
    return "inapp"
  end
end
function logic_payment_api:attach_special_product_for_query_price(product_ids, is_subscrible)
  local AOSSHOPMacros = require("client.slua.config.ClientMacros.AOSSHOPMacros")
  if product_ids ~= nil and 0 < #product_ids and Client.GetAOSSHOP() == AOSSHOPMacros.HMS then
    if is_subscrible then
      product_ids = product_ids .. ",Type-Subscribe"
    else
      product_ids = product_ids .. ",Type-Consumable"
    end
  end
  return product_ids
end
function logic_payment_api:is_mpinfo_in_diff_area()
  local is_enable_mpinfo_diff_area = false
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() ~= true then
    return is_enable_mpinfo_diff_area
  end
  is_enable_mpinfo_diff_area = LobbySystem.CheckOpen(BP_ENUM_PAYMENT_LOAD_MPINFO_V3_SWITCH_ID)
  return is_enable_mpinfo_diff_area
end
function logic_payment_api:get_paychannel_by_aosshop()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  local strPlatform = Client.GetDevicePlatformName()
  local allow_channel = "*"
  if strPlatform == DevicePlatformNameMacros.IOS then
    allow_channel = "iap"
  elseif strPlatform == DevicePlatformNameMacros.Android then
    local AOSSHOPMacros = require("client.slua.config.ClientMacros.AOSSHOPMacros")
    local aosShop = Client.GetAOSSHOP()
    if aosShop == AOSSHOPMacros.Google then
      allow_channel = "gwallet"
    end
  end
  return allow_channel
end
function logic_payment_api:is_embed_h5_pay_allowed()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if not PublishRegionMacros.IsGlobalVersion() then
    return false
  end
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  local strPlatform = Client.GetDevicePlatformName()
  if strPlatform ~= DevicePlatformNameMacros.IOS then
    return false
  end
  if GlobalData and GlobalData.IsIOSCheck and GlobalData.IsIOSCheck() then
    return false
  end
  local bEnableIOSThirdPay = HDmpveRemote.HDmpveRemoteConfigGetString("EmbedH5PayCountryCodes", "usa")
  if bEnableIOSThirdPay and bEnableIOSThirdPay ~= "" then
    local bFound = false
    local StringUtil = require("common.string_util")
    local countryCodeList = StringUtil.Split(bEnableIOSThirdPay, ",")
    for _, countryCode in ipairs(countryCodeList) do
      if countryCode == string.lower(logic_payment_api.StoreCountryCode) then
        bFound = true
        break
      end
    end
    if not bFound then
      return false
    end
  end
  local bEnableEmbedH5Pay = HDmpveRemote.HDmpveRemoteConfigGetBool("EnableEmbedH5Pay", false)
  return bEnableEmbedH5Pay
end
function logic_payment_api:get_common_pay_app_extends(pay_type)
  local appExtends = string.format("pay_type=%s", pay_type)
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if Client.GetPublishRegion() == PublishRegionMacros.JAPAN then
    local jpage = DataMgr.jp_age or logic_payment_api.DEFAULT_JP_PAYMENT_AGE_LIMIT
    appExtends = string.format("pay_type=%s&midas_time_zone=9&midas_user_age=%s&midas_user_zone=JP", pay_type, tostring(jpage))
  end
  local UELanguageUtilityMethods = import("UELanguageUtilityMethods")
  local DeviceOSInfo = require("client.logic.data.data_device_os")
  local TimeUtil = require("client.common.time_util")
  appExtends = appExtends .. string.format("&emulator=%s&language=%s&vpn=%s&time_zone=%s", DataMgr.IsEmulator() and 1 or 0, UELanguageUtilityMethods.GetCurrentLanguageName(), DeviceOSInfo.GetIsPlayerUsingVPN() and 1 or 0, "UTC" .. math.floor(TimeUtil.GetTimeZone()))
  local IMSDKQRCodeSystem = require("client.logic.login.logic_imsdk_qrcode")
  if IMSDKQRCodeSystem:IsQRCodeLogined() then
    appExtends = appExtends .. "&user_login_type=qrcode"
  end
  return appExtends
end
function logic_payment_api:get_product_price_by_product_id(product_id, is_wow)
  if not product_id or product_id == "" then
    return ""
  end
  local symbol = ""
  local money = ""
  local recharge_data
  if is_wow then
    local Logic_UGC_Recharge = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_recharge)
    recharge_data = Logic_UGC_Recharge:GetRecharge_DataList_Array()
  else
    local RechargeSystem = require("client.logic.recharge.logic_recharge")
    recharge_data = RechargeSystem.recharge_DataList_Array or {}
  end
  for i, v in ipairs(recharge_data) do
    if v.rechargeKey == product_id then
      money = v.money
      symbol = v.monetarySymbol
      break
    end
  end
  local symbol_money = symbol .. tostring(money)
  log_tree("logic_payment_api.get_product_price_by_product_id CentauriManager.CachedProductInfoList = ", CentauriManager.CachedProductInfoList)
  for k, p in pairs(CentauriManager.CachedProductInfoList) do
    if p.productId == product_id then
      symbol_money = tostring(p.price)
      break
    end
  end
  return symbol_money
end
return logic_payment_api