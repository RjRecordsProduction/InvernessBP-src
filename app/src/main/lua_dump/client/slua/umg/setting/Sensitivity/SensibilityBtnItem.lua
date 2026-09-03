local SensibilityBtnItem = {}
local local LogicGlobalSensitivity = require("client.logic.setting.logic_setting_global_sensitivity")
local SettingStyleLibrary = require("client.slua.umg.NewSetting.SettingStyleLibrary")
local FloatToPercent = function(Value)
  return math.floor(Value * 100 + 0.5)
end
local IsFireCamOrGyroKey = function(SettingKey)
  if not SettingKey or type(SettingKey) ~= "string" then
    return false
  end
  return string.find(SettingKey, "FireCam") ~= nil or string.find(SettingKey, "Gyro") ~= nil
end
function SensibilityBtnItem:OnRefresh(_, _)
  local UIRoot = self.UIRoot
  local SettingKey = self.data
  self.curValue = self:FetchData() or -1
  self.max = LogicGlobalSensitivity.GetMaxValue(SettingKey)
  self.min = LogicGlobalSensitivity.GetMinValue(SettingKey)
  self._IntNum = FloatToPercent(self.curValue)
  UIRoot.ValueText:SetText(LocUtil.LocalizeResFormat(10283, self._IntNum))
  UIRoot.NameText:SetText(LocUtil.GetLocalizeResStr(LogicGlobalSensitivity.GetResID(SettingKey) or 0))
  UIRoot.CommonSlider:SetValue(self.curValue / self.max)
  UIRoot.CommonSlider:SetStepSize(0.01)
  if UIRoot.SubText then
    UIRoot.SubText:SetText("")
  end
  if UIRoot.NumDelta_Item then
    self:SetWidgetVisible(UIRoot.NumDelta_Item, false)
  end
  if UIRoot.Border_BG then
    if IsFireCamOrGyroKey(SettingKey) then
      UIRoot.Border_BG:SetBrushColor(SettingStyleLibrary.ExpandedBGColor)
    else
      UIRoot.Border_BG:SetBrushColor(SettingStyleLibrary.GeneralBGColor)
    end
  end
end
function SensibilityBtnItem:FetchData()
  local SettingKey = self.data
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  return SettingConfig[SettingKey]
end
function SensibilityBtnItem:RegistEvents()
  self:AddControlEventByControl(self.UIRoot.Button_Minus, "OnClicked", self.OnDecreaseBtn, self)
  self:AddControlEventByControl(self.UIRoot.Button_Plus, "OnClicked", self.OnIncreaseBtn, self)
  self:AddControlEventByControl(self.UIRoot.CommonSlider, "OnValueChanged", self.OnSlideValueChanged, self)
end
function SensibilityBtnItem:OnDecreaseBtn()
  self:SetNum(self.curValue - 0.01)
end
function SensibilityBtnItem:OnIncreaseBtn()
  self:SetNum(self.curValue + 0.01)
end
function SensibilityBtnItem:OnSlideValueChanged(SliderValue)
  local res = self.max * SliderValue
  res = FuncUtil.Clamp(res, self.min, self.max)
  self:SetNum(res)
end
function SensibilityBtnItem:OnSaved()
end
function SensibilityBtnItem:SetNum(value)
  value = FuncUtil.Clamp(value, self.min, self.max)
  self.curValue = value
  self._IntNum = FloatToPercent(value)
  self.UIRoot.ValueText:SetText(LocUtil.LocalizeResFormat(10283, self._IntNum))
  self.UIRoot.CommonSlider:SetValue(value / self.max)
  local Setting_SensibilityChild_UIBP = self:GetLoopScrollBoxParentUI()
  Setting_SensibilityChild_UIBP:OnValueChanged(self.data, value)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.component.scroll_box_child_base")
local CCollect_RLevel_Item_UIBP = class(ui_base, nil, SensibilityBtnItem)
return CCollect_RLevel_Item_UIBP