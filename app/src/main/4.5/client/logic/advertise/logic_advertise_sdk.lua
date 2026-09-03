local logic_advertise_sdk = {
  AdvertiseUnitId = nil,
  AdPriseUnitId = nil,
  AdUnitId = nil,
  isAdvertiseLoaded = false,
  isAdvertiseVaild = true,
  MacroAdvertiseStatus = {
    idle = 0,
    loading = 1,
    loadSucc = 2,
    loadFail = 3,
    showing = 4,
    close = 5,
    invalid = 6
  },
  AdPiexADType = {Reward = "1", Interstitial = "2"},
  AdMobCallbackType = {
    DidOpen = 1,
    StartPlay = 2,
    CompletePlay = 3,
    GetReward = 4,
    DidClose = 5,
    LeaveApp = 6
  },
  AdPieXCallbackType = {
    Click = 1,
    Show = 2,
    GetReward = 3,
    DidClose = 4,
    FailedToShow = 5,
    VideoFinishUnknown = 6,
    VideoFinishCompleted = 7,
    VideoFinishError = 8,
    VideoFinishSkipped = 9
  },
  AdvertiseTypeEnum = {
    None = "0",
    AdMob = "1",
    AdPieX = "2"
  },
  AdvertiseStatus = 0,
  bInited = false,
  AdvertiseRewardType = {PropShop = 20},
  LastPlayLoadKind = nil,
  LastPlayLoadUnitId = nil,
  bPlayingAdNoCloseCallback = false,
  bLoadingAdWithoutPrize = false,
  ReactivatedEventIndex = nil
}
function logic_advertise_sdk.OnLogin()
  logic_advertise_sdk:Init()
end
function logic_advertise_sdk:Init()
  log(bWriteLog and "logic_advertise_sdk:Init")
  if self:CanAdvertiseShow() == false then
    log(bWriteLog and "logic_advertise_sdk:Init return by disable advertise")
    return
  end
  if logic_advertise_sdk.bInited then
    log(bWriteLog and "logic_advertise_sdk:Init return by already inited")
    return
  end
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  IMSDKHelperInstance:InitAdvertiseSDK_iOS()
  IMSDKHelperInstance:InitAdvertiseSDK()
  self:RegistEvents()
  logic_advertise_sdk.bInited = true
  self.hasAdWithoutPrize = false
end
function logic_advertise_sdk:RegistEvents()
  log(bWriteLog and "logic_advertise_sdk:RegistEvents")
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  IMSDKHelperInstance.OnLoadAdvertiseResult:Clear()
  IMSDKHelperInstance.OnLoadAdvertiseResult:Add(function(ret, extra)
    log(bWriteLog and "logic_advertise_sdk.OnLoadAdvertiseResult: " .. ret)
    self:OnLoadAdvertiseResult(json.decode(ret))
  end)
  IMSDKHelperInstance.OnShowAdvertiseResult:Clear()
  IMSDKHelperInstance.OnShowAdvertiseResult:Add(function(ret, extra)
    log(bWriteLog and "logic_advertise_sdk.OnShowAdvertiseResult: " .. ret)
    self:OnShowAdvertiseResult(json.decode(ret))
  end)
end
function logic_advertise_sdk:SetUserId(UserId)
  log(bWriteLog and "logic_advertise_sdk:SetUserId: " .. tostring(UserId))
  if self:CanAdvertiseShow() == false then
    log(bWriteLog and "logic_advertise_sdk:SetUserId return by disable advertise")
    return
  end
  logic_advertise_sdk.Last  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  IMSDKHelperInstance:SetAdvertiseUserID(UserId)
end
function logic_advertise_sdk:SetCustomData(CustomData)
  log(bWriteLog and "logic_advertise_sdk:SetCustomData: " .. tostring(CustomData))
  if self:CanAdvertiseShow() == false then
    log(bWriteLog and "logic_advertise_sdk:SetCustomData return by disable advertise")
    return
  end
  logic_advertise_sdk.Last  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  IMSDKHelperInstance:SetAdvertiseCustomData(CustomData)
end
function logic_advertise_sdk:SetAdvertiseUnitId(AdvertiseUnitId)
  log(bWriteLog and "logic_advertise_sdk:SetAdvertiseUnitId: " .. tostring(AdvertiseUnitId))
  logic_advertise_sdk.  local gameInstance = slua.getGameInstance()
  gameInstance:ExecuteCMD("adv.AdvertiseUnitId", AdvertiseUnitId)
end
function logic_advertise_sdk:SetPrizeUnitId(AdvertiseUnitId)
  log(bWriteLog and "logic_advertise_sdk:SetPrizeUnitId: " .. tostring(AdvertiseUnitId))
  logic_advertise_sdk.AdPriseUnitId = AdvertiseUnitId
end
function logic_advertise_sdk:SetUnitId(AdUnitId)
  log(bWriteLog and "logic_advertise_sdk:SetUnitId. AdUnitId: " .. tostring(AdUnitId))
  logic_advertise_sdk.end
function logic_advertise_sdk:LoadAdvertise(AdvertiseUnitId)
  log(bWriteLog and "logic_advertise_sdk:LoadAdvertise: " .. tostring(AdvertiseUnitId))
  if self:CanAdvertiseShow() == false then
    log(bWriteLog and "logic_advertise_sdk:LoadAdvertise return by disable advertise")
    return
  end
  if not AdvertiseUnitId or "" == AdvertiseUnitId then
    AdvertiseUnitId = logic_advertise_sdk.AdPriseUnitId
  end
  local tempAdvertiseUnit = AdvertiseUnitId
  if tempAdvertiseUnit == nil or tempAdvertiseUnit == "" then
    tempAdvertiseUnit = logic_advertise_sdk.AdvertiseUnitId
  end
  if tempAdvertiseUnit == nil or tempAdvertiseUnit == "" then
    log(bWriteLog and "[ERROR] logic_advertise_sdk:LoadAdvertise return by advertise unit is nil")
    return
  end
  self:SetAdvertiseUnitId(tempAdvertiseUnit)
  logic_advertise_sdk.LastPlayLoadKind = "Prize"
  logic_advertise_sdk.LastPlayLoadUnitId = tempAdvertiseUnit
  if logic_advertise_sdk.AdvertiseStatus == logic_advertise_sdk.MacroAdvertiseStatus.loading or logic_advertise_sdk.AdvertiseStatus == logic_advertise_sdk.MacroAdvertiseStatus.loadSucc then
    log(bWriteLog and "logic_advertise_sdk:LoadAdvertise return by loading or loaded")
    return
  end
  self:SetAdvertiseStatus(logic_advertise_sdk.MacroAdvertiseStatus.loading)
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  if self:IsAdPieX() then
    IMSDKHelperInstance:SetMSDKConfig({
      IMSDK_ADPIEX_AD_TYPE = logic_advertise_sdk.AdPiexADType.Reward
    }, false)
    local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
    local devicePlatformName = Client.GetDevicePlatformName()
    if devicePlatformName == DevicePlatformNameMacros.IOS then
      if logic_advertise_sdk.LastUserId ~= nil then
        self:SetUserId(logic_advertise_sdk.LastUserId)
      end
      if logic_advertise_sdk.LastCustomData ~= nil then
        self:SetCustomData(logic_advertise_sdk.LastCustomData)
      end
      local TimeTicker = require("common.time_ticker")
      local delayedUnitId = tempAdvertiseUnit
      TimeTicker.AddTimerOnce(0.5, function()
        log(bWriteLog and "logic_advertise_sdk:LoadAdvertise delayed call IMSDKHelperInstance:LoadAdvertise: " .. tostring(delayedUnitId))
        IMSDKHelperInstance:LoadAdvertise(delayedUnitId)
      end)
    else
      IMSDKHelperInstance:LoadAdvertise(tempAdvertiseUnit)
    end
  else
    IMSDKHelperInstance:LoadAdvertise(tempAdvertiseUnit)
  end
end
function logic_advertise_sdk:PlayAdvertise()
  log(bWriteLog and "logic_advertise_sdk:PlayAdvertise")
  if self:CanAdvertiseShow() == false then
    log(bWriteLog and "logic_advertise_sdk:PlayAdvertise return by disable advertise")
    return
  end
  self:SetAdvertiseStatus(logic_advertise_sdk.MacroAdvertiseStatus.showing)
  logic_advertise_sdk.bPlayingAdNoCloseCallback = true
  self:RegisterReactivatedListener()
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  IMSDKHelperInstance:PlayAdvertise()
end
function logic_advertise_sdk:SetAdvertiseLoadedState(value)
  logic_advertise_sdk.isAdvertiseLoaded = value
  local gameInstance = slua.getGameInstance()
  gameInstance:ExecuteCMD("adv.IsAdvertiseLoaded", tostring(value))
end
function logic_advertise_sdk:SetAdvertiseStatus(value)
  log(bWriteLog and "logic_advertise_sdk:SetAdvertiseStatus:" .. tostring(value))
  logic_advertise_sdk.AdvertiseStatus = value
end
function logic_advertise_sdk:IsAdvertiseLoaded()
  return logic_advertise_sdk.isAdvertiseLoaded
end
function logic_advertise_sdk:IsAdvertiseLoadSucc()
  return logic_advertise_sdk.MacroAdvertiseStatus.loadSucc == logic_advertise_sdk.AdvertiseStatus
end
function logic_advertise_sdk:IsAdvertiseVaild()
  return logic_advertise_sdk.isAdvertiseVaild
end
function logic_advertise_sdk:OnLoadAdvertiseResult(result)
  local SDKMacros = require("client.slua.config.ClientMacros.SDKMacros")
  local IMSDKErrorCode = SDKMacros.IMSDKErrorCode
  if result.imsdkRetCode == IMSDKErrorCode.SUCCESS then
    self:SetAdvertiseLoadedState(true)
    self:SetAdvertiseStatus(logic_advertise_sdk.MacroAdvertiseStatus.loadSucc)
  elseif result.imsdkRetCode == IMSDKErrorCode.NEED_INSTALL_APP then
    self:SetAdvertiseLoadedState(false)
    self:SetAdvertiseStatus(logic_advertise_sdk.MacroAdvertiseStatus.invalid)
    logic_advertise_sdk.isAdvertiseVaild = false
  else
    self:SetAdvertiseLoadedState(false)
    self:SetAdvertiseStatus(logic_advertise_sdk.MacroAdvertiseStatus.loadFail)
  end
end
function logic_advertise_sdk:OnShowAdvertiseResult(result)
  print(bWriteLog and "logic_advertise_sdk:OnShowAdvertiseResult ")
  local SDKMacros = require("client.slua.config.ClientMacros.SDKMacros")
  local IMSDKErrorCode = SDKMacros.IMSDKErrorCode
  if result.imsdkRetCode == IMSDKErrorCode.SUCCESS and self:IsAdClosedCallback(result.thirdRetCode) then
    logic_advertise_sdk.bPlayingAdNoCloseCallback = false
    self:UnregisterReactivatedListener()
    self:SetAdvertiseStatus(logic_advertise_sdk.MacroAdvertiseStatus.close)
    self:SetAdvertiseLoadedState(false)
    self:LoadAdvertise()
  end
  if CGameState and slua.isValid(CGameState) and CGameState.IsCreativeMode and CGameState:IsCreativeMode() then
    print(bWriteLog and "logic_advertise_sdk:OnShowAdvertiseResult Post ADFinish ")
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_PROP_AD_FINISH)
  end
end
function logic_advertise_sdk:GetAdvertiseType()
  if logic_advertise_sdk.AdvertiseType ~= nil then
    return logic_advertise_sdk.AdvertiseType
  end
  local iniPath = Client.ProjectDir() .. "Config/DefaultEngine.ini"
  local section = "/Script/Client.AdvertiseSettings"
  local key = "AdvertiseType"
  local advertiseType = Client.GetConfigString(iniPath, section, key) or ""
  log(bWriteLog and "logic_advertise_sdk:GetAdvertiseType - " .. tostring(advertiseType))
  logic_advertise_sdk.AdvertiseType = advertiseType
  return advertiseType
end
function logic_advertise_sdk:IsAdMob()
  return self:GetAdvertiseType() == logic_advertise_sdk.AdvertiseTypeEnum.AdMob
end
function logic_advertise_sdk:IsAdPieX()
  return self:GetAdvertiseType() == logic_advertise_sdk.AdvertiseTypeEnum.AdPieX
end
function logic_advertise_sdk:IsAdClosedCallback(thirdRetCode)
  if self:IsAdPieX() then
    return thirdRetCode == logic_advertise_sdk.AdPieXCallbackType.DidClose
  else
    return thirdRetCode == logic_advertise_sdk.AdMobCallbackType.DidClose
  end
end
function logic_advertise_sdk:IsAdRewardedCallback(thirdRetCode)
  if self:IsAdPieX() then
    return thirdRetCode == logic_advertise_sdk.AdPieXCallbackType.GetReward
  else
    return thirdRetCode == logic_advertise_sdk.AdMobCallbackType.GetReward
  end
end
function logic_advertise_sdk:IsAdvertiseTypeSet()
  local t = self:GetAdvertiseType()
  return t ~= nil and t ~= "" and t ~= logic_advertise_sdk.AdvertiseTypeEnum.None
end
function logic_advertise_sdk:CanAdvertiseShow()
  local defaultEnableAdvertise = true
  if self:IsAdMob() then
    defaultEnableAdvertise = false
  end
  local enableAdvertise = HDmpveRemote.HDmpveRemoteConfigGetBool("EnableAdvertiseShow", defaultEnableAdvertise)
  if not enableAdvertise then
    log(bWriteLog and "logic_advertise_sdk:CanAdvertiseShow : false (disabled by cloud control)")
    return false
  end
  if Client.GetAndroidSOVersion() <= 32 then
    log(bWriteLog and "logic_advertise_sdk:CanAdvertiseShow : false (32-bit CPU not supported)")
    return false
  end
  if self:IsAdPieX() then
    return true
  end
  if self:IsAdMob() then
    local enableAdavertise = false
    local memorySizeInG = Client.GetMemorySize()
    local devicePlatformName = Client.GetDevicePlatformName()
    local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
    if devicePlatformName == DevicePlatformNameMacros.IOS and 4 <= memorySizeInG then
      enableAdavertise = true
    elseif devicePlatformName == DevicePlatformNameMacros.Android and 4 <= memorySizeInG then
      enableAdavertise = true
    end
    return enableAdavertise
  end
  return false
end
function logic_advertise_sdk:LoadAdWithoutPrize(notPlay)
  printf("logic_advertise_sdk:LoadAdWithoutPrize. notPlay:%s", tostring(notPlay))
  if not self:CanAdvertiseShow() then
    log(bWriteLog and "logic_advertise_sdk:LoadAdWithoutPrize.  can not show")
    return
  end
  if self.bLoadingAdWithoutPrize then
    log(bWriteLog and "logic_advertise_sdk:LoadAdWithoutPrize.  loading in progress, skip duplicate call")
    ShowDevNotice("ad is busy")
    return
  end
  if not notPlay and self.hasAdWithoutPrize then
    log(bWriteLog and "logic_advertise_sdk:LoadAdWithoutPrize. without-prize ad already loaded, play directly")
    self:PlayAdvertise()
    return
  end
  local advertiseUnitId = logic_advertise_sdk.AdUnitId
  if not advertiseUnitId then
    log(bWriteLog and "logic_advertise_sdk:LoadAdWithoutPrize.  not advertiseUnitId")
    return
  end
  logic_advertise_sdk.LastPlayLoadKind = "WithoutPrize"
  logic_advertise_sdk.LastPlayLoadUnitId = advertiseUnitId
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  local SDKMacros = require("client.slua.config.ClientMacros.SDKMacros")
  local IMSDKErrorCode = SDKMacros.IMSDKErrorCode
  local TimeUtil = require("client.common.time_util")
  local loadTime = TimeUtil.GetMiliseconds()
  if not self.nLoadAbTime then
    self.nLoadAbTime = 1
  else
    self.nLoadAbTime = self.nLoadAbTime + 1
  end
  log(bWriteLog and "logic_advertise_sdk:LoadAdWithoutPrize. self.nLoadAbTime: " .. tostring(self.nLoadAbTime))
  local LoadOtherAb = function()
    log(bWriteLog and "LoadOtherAb.  ")
    self:RegistEvents()
    local AD_macro = require("client.slua.logic.advertisement.AD_macro")
    self:SetCustomData(AD_macro.ENUM_SCENCE_TYPE.RECHARGE)
    self:LoadAdvertise(logic_advertise_sdk.AdPriseUnitId)
  end
  IMSDKHelperInstance.OnLoadAdvertiseResult:Clear()
  IMSDKHelperInstance.OnLoadAdvertiseResult:Add(function(ret, extra)
    self.bLoadingAdWithoutPrize = false
    log(bWriteLog and "logic_advertise_sdk.OnLoadAdvertiseResult: " .. ret)
    local result = json.decode(ret)
    if result.imsdkRetCode == IMSDKErrorCode.SUCCESS then
      local useTime = TimeUtil.GetMiliseconds() - loadTime
      log(bWriteLog and "logic_advertise_sdk:LoadAdWithoutPrize. useTime: " .. tostring(useTime))
      self.nLoadAbTime = 0
      self.hasAdWithoutPrize = true
      if not notPlay then
        self:PlayAdvertise()
      else
        log(bWriteLog and "logic_advertise_sdk:LoadAdWithoutPrize. loaded only, not play")
      end
    elseif self.nLoadAbTime <= 3 then
      self:LoadAdWithoutPrize(notPlay)
    else
      self.nLoadAbTime = 0
      log(bWriteLog and "logic_advertise_sdk:LoadAdWithoutPrize. load fail")
      LoadOtherAb()
    end
  end)
  IMSDKHelperInstance.OnShowAdvertiseResult:Clear()
  IMSDKHelperInstance.OnShowAdvertiseResult:Add(function(ret, extra)
    log(bWriteLog and "logic_advertise_sdk. LoadAdWithoutPrize OnShowAdvertiseResult: " .. ret)
    local result = json.decode(ret)
    if result and self:IsAdClosedCallback(result.thirdRetCode) then
      logic_advertise_sdk.bPlayingAdNoCloseCallback = false
      self.hasAdWithoutPrize = false
      self:UnregisterReactivatedListener()
      LoadOtherAb()
    end
  end)
  local BusinessHelper = import("BusinessHelper")
  local openid = BusinessHelper.GetOpenId()
  self:SetUserId(openid)
  local AD_macro = require("client.slua.logic.advertisement.AD_macro")
  self:SetAdvertiseUnitId(advertiseUnitId)
  if self:IsAdPieX() then
    IMSDKHelperInstance:SetMSDKConfig({
      IMSDK_ADPIEX_AD_TYPE = logic_advertise_sdk.AdPiexADType.Interstitial
    }, false)
  end
  self.bLoadingAdWithoutPrize = true
  IMSDKHelperInstance:LoadAdvertise(advertiseUnitId)
end
function logic_advertise_sdk:RegisterReactivatedListener()
  if not self:NeedHandleReactivatedForAd() then
    return
  end
  if logic_advertise_sdk.ReactivatedEventIndex ~= nil then
    return
  end
  if EventSystem == nil or EVENTTYPE_APPLICATION_ACTIVE_STATE == nil or EVENTID_APPLICATION_REACTIVATED_EX == nil then
    log(bWriteLog and "logic_advertise_sdk:RegisterReactivatedListener fail by EventSystem nil")
    return
  end
  log(bWriteLog and "logic_advertise_sdk:RegisterReactivatedListener")
  logic_advertise_sdk.ReactivatedEventIndex = EventSystem:registEvent(EVENTTYPE_APPLICATION_ACTIVE_STATE, EVENTID_APPLICATION_REACTIVATED_EX, function()
    logic_advertise_sdk:OnApplicationReactivated()
  end)
end
function logic_advertise_sdk:UnregisterReactivatedListener()
  if logic_advertise_sdk.ReactivatedEventIndex == nil then
    return
  end
  log(bWriteLog and "logic_advertise_sdk:UnregisterReactivatedListener")
  if EventSystem and EventSystem.UnregistEventByID then
    EventSystem:UnregistEventByID(logic_advertise_sdk.ReactivatedEventIndex)
  end
  logic_advertise_sdk.ReactivatedEventIndex = nil
end
function logic_advertise_sdk:NeedHandleReactivatedForAd()
  if not self:IsAdPieX() then
    return false
  end
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  local devicePlatformName = Client.GetDevicePlatformName()
  if devicePlatformName ~= DevicePlatformNameMacros.Android then
    return false
  end
  return true
end
function logic_advertise_sdk:OnApplicationReactivated()
  log(bWriteLog and string.format("logic_advertise_sdk:OnApplicationReactivated bPlayingAdNoCloseCallback=%s LastPlayLoadKind=%s LastPlayLoadUnitId=%s", tostring(logic_advertise_sdk.bPlayingAdNoCloseCallback), tostring(logic_advertise_sdk.LastPlayLoadKind), tostring(logic_advertise_sdk.LastPlayLoadUnitId)))
  if not self:NeedHandleReactivatedForAd() then
    return
  end
  if not logic_advertise_sdk.bPlayingAdNoCloseCallback then
    return
  end
  logic_advertise_sdk.bPlayingAdNoCloseCallback = false
  self:UnregisterReactivatedListener()
  self:SetAdvertiseStatus(logic_advertise_sdk.MacroAdvertiseStatus.close)
  self:SetAdvertiseLoadedState(false)
  self.hasAdWithoutPrize = false
  local kind = logic_advertise_sdk.LastPlayLoadKind
  if kind == "WithoutPrize" then
    log(bWriteLog and "logic_advertise_sdk:OnApplicationReactivated reload by LoadAdWithoutPrize")
    self:LoadAdWithoutPrize()
  elseif kind == "Prize" then
    log(bWriteLog and "logic_advertise_sdk:OnApplicationReactivated reload by LoadAdvertise")
    self:LoadAdvertise(logic_advertise_sdk.LastPlayLoadUnitId)
  else
    log(bWriteLog and "logic_advertise_sdk:OnApplicationReactivated unknown LastPlayLoadKind, skip")
  end
end
return logic_advertise_sdk