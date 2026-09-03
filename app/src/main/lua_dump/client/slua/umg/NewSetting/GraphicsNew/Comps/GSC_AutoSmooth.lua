local GSC_AutoSmooth = {}
local GraphicSettingDB = require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
function GSC_AutoSmooth:ctor()
end
function GSC_AutoSmooth:OnInitialize()
  self.UIRoot.TextBlock_Title:SetText(LocUtil.GetLocalizeResStr(24021412))
  self:SetWidgetVisible(self.UIRoot.Button_Help, true, true)
end
function GSC_AutoSmooth:RegistEvents()
  local itemRoot = self.UIRoot
  self:AddControlEventByControl(itemRoot.Button_Switch, "OnClicked", self.OnClickAutoAdapt, self)
  self:AddControlEventByControl(itemRoot.Button_Help, "OnClicked", self.OnClickButton_Help, self)
end
function GSC_AutoSmooth:OnAfterAllComponentsInitialized()
  self:Subscribe(GraphicSettingDB.DeviceAutoAdaptEx, function(old, value)
    self:UpdateUI(value)
  end)
end
function GSC_AutoSmooth:UpdateUI(bOpen)
  self.UIRoot.Setting_Switch:SetSwitcherEnable2(bOpen, true)
end
function GSC_AutoSmooth:OnClickAutoAdapt()
  self:PlayAudio(sound_config.click_v1)
  GraphicSettingDB:UpdateUIDataOneMinus(GraphicSettingDB.DeviceAutoAdaptEx)
  self:GetParentUI():SetDirty(true)
end
function GSC_AutoSmooth:OnClickButton_Help()
  self:PlayAudio(sound_config.click_v1)
  UIManager.ShowUI(UIManager.UI_Config.common_questionmark_style_three, LocUtil.GetLocalizeResStr(24021413), self.UIRoot.Button_Help)
end
local class = require("class")
local GSC_Base = require("client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_Base")
return class(GSC_Base, nil, GSC_AutoSmooth)