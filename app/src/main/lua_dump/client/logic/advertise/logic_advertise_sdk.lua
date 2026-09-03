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
  AdvertiseStatus = 0
}
function logic_advertise_sdk.OnLogin()
  local AdmobEnable = HDmpveRemote.HDmpveRemoteConfigGetString("AdmobEnable", "nil")
  if AdmobEnable == "true" or AdmobEnable == "false" then
    Client.SaveToSharedPreferences("AdmobEnable", AdmobEnable)
  end
  logic_advertise_sdk:Init()
end
function logic_advertise_sdk:Init()
  log(bWriteLog and "logic_advertise_sdk:Init")
  if self:CanAdvertiseShow() == false then
    log(bWriteLog and "logic_advertise_sdk:Init return by disable advertise")
    return
  end
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  IMSDKHelperInstance:InitAdvertiseSDK_iOS()
  IMSDKHelperInstance:InitAdvertiseSDK()
  self:RegistEvents()
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
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  IMSDKHelperInstance:SetAdvertiseUserID(UserId)
end
function logic_advertise_sdk:SetCustomData(CustomData)
  log(bWriteLog and "logic_advertise_sdk:SetCustomData: " .. tostring(CustomData))
  if self:CanAdvertiseShow() == false then
    log(bWriteLog and "logic_advertise_sdk:SetCustomData return by disable advertise")
    return
  end
  local IMSDKHelper = import("IMSDKHelper")
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
  if logic_advertise_sdk.AdvertiseStatus == logic_advertise_sdk.MacroAdvertiseStatus.loading or logic_advertise_sdk.AdvertiseStatus == logic_advertise_sdk.MacroAdvertiseStatus.loadSucc then
    log(bWriteLog and "logic_advertise_sdk:LoadAdvertise return by loading or loaded")
    return
  end
  self:SetAdvertiseStatus(logic_advertise_sdk.MacroAdvertiseStatus.loading)
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  IMSDKHelperInstance:SetMSDKConfig({
    IMSDK_ADPIEX_AD_TYPE = logic_advertise_sdk.AdPiexADType.Reward
  }, false)
  IMSDKHelperInstance:LoadAdvertise(tempAdvertiseUnit)
end
function logic_advertise_sdk:PlayAdvertise()
  log(bWriteLog and "logic_advertise_sdk:PlayAdvertise")
  if self:CanAdvertiseShow() == false then
    log(bWriteLog and "logic_advertise_sdk:PlayAdvertise return by disable advertise")
    return
  end
  self:SetAdvertiseStatus(logic_advertise_sdk.MacroAdvertiseStatus.showing)
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
  local SDKMacros = require("client.slua.config.ClientMacros.SDKMacros")
  local IMSDKAdvStatus = SDKMacros.IMSDKAdvStatus
  local IMSDKErrorCode = SDKMacros.IMSDKErrorCode
  if result.imsdkRetCode == IMSDKErrorCode.SUCCESS and result.thirdRetCode == IMSDKAdvStatus.DID_CLOSE then
    self:SetAdvertiseStatus(logic_advertise_sdk.MacroAdvertiseStatus.close)
    self:SetAdvertiseLoadedState(false)
    self:LoadAdvertise()
  end
end
function logic_advertise_sdk:CanAdvertiseShow()
  local enableAdavertise = false
  local memorySizeInG = Client.GetMemorySize()
  local devicePlatformName = Client.GetDevicePlatformName()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  enableAdavertise = true
  return enableAdavertise
end
function logic_advertise_sdk:LoadAdWithoutPrize()
  log(bWriteLog and "logic_advertise_sdk:LoadAdWithoutPrize.  ")
  if not self:CanAdvertiseShow() then
    log(bWriteLog and "logic_advertise_sdk:LoadAdWithoutPrize.  can not show")
    return
  end
  local advertiseUnitId = logic_advertise_sdk.AdUnitId
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
    self:LoadAdvertise(logic_advertise_sdk.AdPriseUnitId)
  end
  IMSDKHelperInstance.OnLoadAdvertiseResult:Clear()
  IMSDKHelperInstance.OnLoadAdvertiseResult:Add(function(ret, extra)
    log(bWriteLog and "logic_advertise_sdk.OnLoadAdvertiseResult: " .. ret)
    local result = json.decode(ret)
    if result.imsdkRetCode == IMSDKErrorCode.SUCCESS then
      local useTime = TimeUtil.GetMiliseconds() - loadTime
      log(bWriteLog and "logic_advertise_sdk:LoadAdWithoutPrize. useTime: " .. tostring(useTime))
      self.nLoadAbTime = 0
      self:PlayAdvertise()
    elseif self.nLoadAbTime <= 3 then
      self:LoadAdWithoutPrize()
    else
      self.nLoadAbTime = 0
      log(bWriteLog and "logic_advertise_sdk:LoadAdWithoutPrize. load fail")
      LoadOtherAb()
    end
  end)
  IMSDKHelperInstance.OnShowAdvertiseResult:Clear()
  IMSDKHelperInstance.OnShowAdvertiseResult:Add(function(ret, extra)
    log(bWriteLog and "logic_advertise_sdk. LoadAdWithoutPrize OnShowAdvertiseResult: " .. ret)
    LoadOtherAb()
  end)
  local BusinessHelper = import("BusinessHelper")
  local openid = BusinessHelper.GetOpenId()
  self:SetUserId(openid)
  local AD_macro = require("client.slua.logic.advertisement.AD_macro")
  self:SetAdvertiseUnitId(advertiseUnitId)
  IMSDKHelperInstance:SetMSDKConfig({
    IMSDK_ADPIEX_AD_TYPE = logic_advertise_sdk.AdPiexADType.Interstitial
  }, false)
  IMSDKHelperInstance:LoadAdvertise(advertiseUnitId)
end
return logic_advertise_sdk