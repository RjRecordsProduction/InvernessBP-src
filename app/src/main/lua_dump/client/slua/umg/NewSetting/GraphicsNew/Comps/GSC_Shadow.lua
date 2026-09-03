local GSC_Shadow = {}
local GraphicSettingDB = require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
local ERenderQuality = import("ERenderQuality")
function GSC_Shadow:ctor()
end
function GSC_Shadow:OnInitialize()
  self.UIRoot.TextBlock_Title:SetText(LocUtil.GetLocalizeResStr(24021408))
  self:SetWidgetVisible(self.UIRoot.Button_Help, true, true)
end
function GSC_Shadow:RegistEvents()
  self:AddControlEventByControl(self.UIRoot.Button_Switch, "OnClicked", self.OnClickShadow, self)
  self:AddControlEventByControl(self.UIRoot.Button_Help, "OnClicked", self.OnClickButton_Help, self)
end
function GSC_Shadow:OnAfterAllComponentsInitialized()
  self:Subscribe(GraphicSettingDB.SelectedShadow, function(old, value)
    self:UpdateUI(value)
  end)
end
function GSC_Shadow:OnApplyModify()
  local SelectedShadow = GraphicSettingDB:GetUIData(GraphicSettingDB.SelectedShadow)
  self:UpdateUI(SelectedShadow)
end
function GSC_Shadow:OnClickShadow()
  self:PlayAudio(sound_config.click_v1)
  GraphicSettingDB:UpdateUIDataOneMinus(GraphicSettingDB.SelectedShadow)
  self:GetParentUI():SetDirty(true)
end
function GSC_Shadow:UpdateUI(value)
  local GraphicHelperUtil = require("client.slua.umg.NewSetting.GraphicsNew.GraphicHelperUtil")
  if not GraphicHelperUtil.ShouldShowShadowBtn() then
    printf("GSC_Shadow:UpdateUI not show shadow btn")
    self:Collapsed()
    return
  end
  self:SelfHitTestInvisible()
  self.UIRoot.Setting_Switch:SetSwitcherEnable2(value, true)
end
function GSC_Shadow:OnClickButton_Help()
  self:PlayAudio(sound_config.click_v1)
  UIManager.ShowUI(UIManager.UI_Config.common_questionmark_style_three, LocUtil.GetLocalizeResStr(24021409), self.UIRoot.Button_Help)
end
local class = require("class")
local GSC_Base = require("client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_Base")
return class(GSC_Base, nil, GSC_Shadow)