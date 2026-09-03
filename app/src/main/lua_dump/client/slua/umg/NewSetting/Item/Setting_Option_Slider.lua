local Setting_Option_Slider = {}
local FuncLib = require("client.logic.NewSetting.Stack.FuncLib")
function Setting_Option_Slider:OnInitialize()
  Setting_Option_Slider.__super.OnInitialize(self)
  if not self.Data.SetFunc then
    self.Data.SetFunc = FuncLib.SetValue
  end
  if not self.Data.GetFunc then
    self.Data.GetFunc = FuncLib.GetValue
  end
  if self.UIRoot.Setting_Option_Base then
    if type(self.Data.Text) == "number" then
      self.UIRoot.Setting_Option_Base.Text:SetText(LocUtil.GetLocalizeResStr(self.Data.Text))
    elseif type(self.Data.Text) == "string" then
      self.UIRoot.Setting_Option_Base.Text:SetText(self.Data.Text)
    end
    self:SetupHelpButton(self.UIRoot.Setting_Option_Base.Button_Help)
  end
  self.Min = self.Data.Min or 0
  self.Max = self.Data.Max or 100
  self.IsPercent = self.Data.IsPercent ~= false
  if self.Max <= self.Min then
    self.Max = self.Min + 1
    print(bWriteLog and "Setting_Option_Slider:OnInitialize - Max smaller than Min, Key=" .. self.Data.Key)
  end
  self.UIRoot.Slider:SetStepSize(1 / (self.Max - self.Min))
  self:OnRefreshOption()
end
function Setting_Option_Slider:OnRefreshOption()
  if self.Data.GetFunc then
    local InitValue = self.Data.GetFunc(self.Data.Key)
    if type(InitValue) == "number" then
      self.CurrentValue = math.max(self.Min, math.min(self.Max, InitValue))
    else
      self.CurrentValue = self.Min
      print(bWriteLog and "Setting_Option_Slider:OnInitialize - GetFunc returned non-number, Key=" .. self.Data.Key)
    end
  else
    self.CurrentValue = self.Min
  end
  self.LastAppliedValue = self.CurrentValue
  self:UpdateSliderDisplay()
end
function Setting_Option_Slider:RegistEvents()
  Setting_Option_Slider.__super.RegistEvents(self)
  self:AddControlEventByControl(self.UIRoot.Button_Minus, "OnClicked", self.OnClickMinus, self)
  self:AddControlEventByControl(self.UIRoot.Button_Plus, "OnClicked", self.OnClickPlus, self)
  self:AddControlEventByControl(self.UIRoot.Slider, "OnValueChanged", self.OnSliderValueChanged, self)
  self:AddControlEventByControl(self.UIRoot.Slider, "OnMouseCaptureEnd", self.OnSliderMouseCaptureEnd, self)
end
function Setting_Option_Slider:UpdateSliderDisplay()
  local SliderValue = (self.CurrentValue - self.Min) / (self.Max - self.Min)
  self.UIRoot.Slider:SetValue(SliderValue)
  self:UpdateValueText()
end
function Setting_Option_Slider:UpdateValueText()
  if self.IsPercent then
    self.UIRoot.TextBlock_Value:SetText(tostring(self.CurrentValue) .. "%")
  else
    self.UIRoot.TextBlock_Value:SetText(tostring(self.CurrentValue))
  end
end
function Setting_Option_Slider:OnSliderValueChanged(SliderValue)
  local RawValue = SliderValue * (self.Max - self.Min) + self.Min
  local NewValue = math.floor(RawValue + 0.5)
  if NewValue ~= self.CurrentValue then
    self.CurrentValue = NewValue
    self:UpdateValueText()
  end
end
function Setting_Option_Slider:OnSliderMouseCaptureEnd()
  if self.CurrentValue ~= self.LastAppliedValue then
    self:ApplyValue()
    self.LastAppliedValue = self.CurrentValue
  end
end
function Setting_Option_Slider:OnClickMinus()
  if self.CurrentValue > self.Min then
    self:PlayAudio(sound_config.click_v1)
    self.CurrentValue = self.CurrentValue - 1
    self:UpdateSliderDisplay()
    self:ApplyValue()
    self.LastAppliedValue = self.CurrentValue
  end
end
function Setting_Option_Slider:OnClickPlus()
  if self.CurrentValue < self.Max then
    self:PlayAudio(sound_config.click_v1)
    self.CurrentValue = self.CurrentValue + 1
    self:UpdateSliderDisplay()
    self:ApplyValue()
    self.LastAppliedValue = self.CurrentValue
  end
end
function Setting_Option_Slider:ApplyValue()
  if self.Data.SetFunc then
    self.Data.SetFunc(self.Data.Key, self.CurrentValue)
  end
end
local class = require("class")
local Setting_Item_Base = require("client.slua.umg.NewSetting.Item.Setting_Item_Base")
return class(Setting_Item_Base, nil, Setting_Option_Slider)