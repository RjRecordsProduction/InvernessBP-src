local GSC_Brightness = {}
local GraphicSettingDB = require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
local NMinBrightness = 0.8
local NStep = 0.01
local NRate = 0.7
function GSC_Brightness:ctor()
  self._bUpdatingUI = false
end
function GSC_Brightness:OnInitialize()
  local itemRoot = self.UIRoot
  itemRoot.TextBlock_Title:SetText(LocUtil.GetLocalizeResStr(24021405))
end
function GSC_Brightness:RegistEvents()
  local itemRoot = self.UIRoot
  self:AddControlEventByControl(itemRoot.Button_screen_add, "OnClicked", self.OnScreenAdd, self)
  self:AddControlEventByControl(itemRoot.Button_screen_minus, "OnClicked", self.OnScreenMinus, self)
  self:AddControlEventByControl(itemRoot.Slider_screen, "OnValueChanged", self.OnLightnessSliderValueChange, self)
end
function GSC_Brightness:OnAfterAllComponentsInitialized()
  self:Subscribe(GraphicSettingDB.ScreenLightness, function(old, value)
    self:UpdateUI(value)
  end)
end
function GSC_Brightness:OnScreenAdd()
  self:PlayAudio(sound_config.click_v1)
  local ScreenLightness = GraphicSettingDB:GetUIData(GraphicSettingDB.ScreenLightness)
  ScreenLightness = math.min(NRate + NMinBrightness, ScreenLightness + NStep)
  self:OnLightnessValueChange(ScreenLightness)
end
function GSC_Brightness:OnScreenMinus()
  self:PlayAudio(sound_config.click_v1)
  local ScreenLightness = GraphicSettingDB:GetUIData(GraphicSettingDB.ScreenLightness)
  ScreenLightness = math.max(NMinBrightness, ScreenLightness - NStep)
  self:OnLightnessValueChange(ScreenLightness)
end
function GSC_Brightness:OnLightnessSliderValueChange(value)
  if self._bUpdatingUI then
    return
  end
  local ScreenLightness = value * NRate + NMinBrightness
  self:OnLightnessValueChange(ScreenLightness)
end
function GSC_Brightness:OnLightnessValueChange(lightness)
  GraphicSettingDB:UpdateUIData(GraphicSettingDB.ScreenLightness, lightness, false)
  local userSettings = slua_GameFrontendHUD:GetUserSettings()
  userSettings.ScreenLightness = lightness
  local gameInstance = slua_GameFrontendHUD:GetGameInstance()
  gameInstance:ExecuteCMD("r.Mobile.Brightness", tostring(lightness))
end
function GSC_Brightness:OnGraphicsReset()
  local ScreenLightness = GraphicSettingDB:GetUIData(GraphicSettingDB.ScreenLightness)
  self:OnLightnessValueChange(ScreenLightness)
end
function GSC_Brightness:UpdateUI(lightness)
  local lightPercent = math.floor(lightness * 100 + 0.5)
  local light = (lightness - NMinBrightness) / NRate
  local itemRoot = self.UIRoot
  itemRoot.Veihclescreen:SetText(LocUtil.LocalizeResFormat(20082, lightPercent))
  self._bUpdatingUI = true
  itemRoot.Slider_screen:SetValue(light)
  self._bUpdatingUI = false
  itemRoot.ProgressBar_screen:SetPercent(light)
end
local class = require("class")
local GSC_Base = require("client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_Base")
return class(GSC_Base, nil, GSC_Brightness)