local GSC_AdvancedWrap = {}
local GraphicSettingDB = require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
function GSC_AdvancedWrap:ctor()
  self.bExpand = false
end
function GSC_AdvancedWrap:OnInitialize()
  local itemRoot = self.UIRoot
  itemRoot.TextBlock_Title:SetText(LocUtil.GetLocalizeResStr(86764))
  local GraphicHelperUtil = require("client.slua.umg.NewSetting.GraphicsNew.GraphicHelperUtil")
  if GraphicHelperUtil.IsSupportVivoTurbo() then
    self:SetWidgetVisible(itemRoot.Tab_Item05, true)
  else
    self:SetWidgetVisible(itemRoot.Tab_Item05, false)
  end
  if GraphicHelperUtil.ShouldShowShadowBtn() then
    self:SetWidgetVisible(itemRoot.Tab_Item03, true)
  else
    self:SetWidgetVisible(itemRoot.Tab_Item03, false)
  end
  self:SetWidgetVisible(self.UIRoot.VerticalBox_Item, self.bExpand)
  self:SetWidgetVisible(self.UIRoot.WrapBox_Tab, not self.bExpand)
  self.UIRoot.WidgetSwitcher_Unfold:SetActiveWidgetIndex(self.bExpand and 1 or 0)
end
function GSC_AdvancedWrap:RegistEvents()
  local itemRoot = self.UIRoot
  self:AddOnClickedEventByControl(self.UIRoot.Button_Unfold, self.OnButtonUnfoldClicked, self)
  local ConvertBoolToText = function(b)
    return b and LocUtil.GetLocalizeResStr(6401) or LocUtil.GetLocalizeResStr(6402)
  end
  self:Subscribe(GraphicSettingDB.RenderMSAAValue, function(old, value)
    printf("GSC_AdvancedWrap:RegistEvents RenderMSAAValue value = %s", value)
    local map = {
      [0] = LocUtil.GetLocalizeResStr(6402),
      [2] = "2x",
      [4] = "4x"
    }
    local s = map[value]
    self.UIRoot.Tab_Item01.TextBlock_0:SetText(LocUtil.LocalizeResFormat(86759, s))
  end)
  self:Subscribe(GraphicSettingDB.SelectedEnergySaving, function(old, value)
    value = ConvertBoolToText(value)
    self.UIRoot.Tab_Item02.TextBlock_0:SetText(LocUtil.LocalizeResFormat(86760, value))
  end)
  self:Subscribe(GraphicSettingDB.SelectedShadow, function(old, value)
    value = ConvertBoolToText(value)
    self.UIRoot.Tab_Item03.TextBlock_0:SetText(LocUtil.LocalizeResFormat(86761, value))
  end)
  self:Subscribe(GraphicSettingDB.DeviceAutoAdaptEx, function(old, value)
    value = ConvertBoolToText(value)
    self.UIRoot.Tab_Item04.TextBlock_0:SetText(LocUtil.LocalizeResFormat(86762, value))
  end)
  self:Subscribe(GraphicSettingDB.TurboEnable, function(old, value)
    value = ConvertBoolToText(value)
    self.UIRoot.Tab_Item05.TextBlock_0:SetText(LocUtil.LocalizeResFormat(86763, value))
  end)
end
function GSC_AdvancedWrap:OnButtonUnfoldClicked()
  self:PlayAudio(sound_config.popup_v1)
  printf("GSC_AdvancedWrap:OnButtonUnfoldClicked")
  self.bExpand = not self.bExpand
  self:SetWidgetVisible(self.UIRoot.VerticalBox_Item, self.bExpand)
  self:SetWidgetVisible(self.UIRoot.WrapBox_Tab, not self.bExpand)
  self.UIRoot.WidgetSwitcher_Unfold:SetActiveWidgetIndex(self.bExpand and 1 or 0)
end
local class = require("class")
local GSC_Base = require("client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_Base")
return class(GSC_Base, nil, GSC_AdvancedWrap)