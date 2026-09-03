local GSC_MSAA = {}
local GraphicSettingDB = require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
function GSC_MSAA:ctor()
end
function GSC_MSAA:OnInitialize()
end
function GSC_MSAA:RegistEvents()
  local itemRoot = self.UIRoot
  self:AddControlEventByControl(itemRoot.Button_Close, "OnClicked", self.OnButtonClose, self)
  self:AddControlEventByControl(itemRoot.Button_2x, "OnClicked", self.OnButton2x, self)
  self:AddControlEventByControl(itemRoot.Button_4x, "OnClicked", self.OnButton4x, self)
  self:AddControlEventByControl(itemRoot.Button_Help, "OnClicked", self.OnClickButton_Help, self)
end
function GSC_MSAA:OnAfterAllComponentsInitialized()
  local SettingUtil = require("client.slua.logic.setting.setting_util")
  local bSupport = SettingUtil.GetGameInstance():IsSupportMSAA()
  if not bSupport then
    printf("GSC_MSAA:OnAfterAllComponentsInitialized not bSupport")
    self:Collapsed()
    return
  end
  self:Subscribe(GraphicSettingDB.RenderMSAAValue, function(old, value)
    self:UpdateUI(value)
  end)
end
function GSC_MSAA:UpdateUI(msaaVal)
  local itemRoot = self.UIRoot
  if msaaVal == 0 then
    itemRoot.GridPanel_50:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    itemRoot.GridPanel_67:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    itemRoot.GridPanel_79:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  elseif msaaVal == 2 then
    itemRoot.GridPanel_50:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    itemRoot.GridPanel_67:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    itemRoot.GridPanel_79:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  elseif msaaVal == 4 then
    itemRoot.GridPanel_50:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    itemRoot.GridPanel_67:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    itemRoot.GridPanel_79:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
  itemRoot.TextBlock_Title:SetText(LocUtil.GetLocalizeResStr(24021406))
  self:SetWidgetVisible(itemRoot.Button_Help, true, true)
end
function GSC_MSAA:OnButtonClose()
  log(bWriteLog and "GSC_MSAA:OnButtonClose")
  self:PlayAudio(sound_config.click_v1)
  GraphicSettingDB:UpdateUIData(GraphicSettingDB.RenderMSAAValue, 0)
  GraphicSettingDB:UpdateUIData(GraphicSettingDB.RenderMSAASetting, false)
  self:GetParentUI():SetDirty(true)
end
function GSC_MSAA:OnButton2x()
  log(bWriteLog and "GSC_MSAA:OnButton2x")
  self:PlayAudio(sound_config.click_v1)
  GraphicSettingDB:UpdateUIData(GraphicSettingDB.RenderMSAAValue, 2)
  GraphicSettingDB:UpdateUIData(GraphicSettingDB.RenderMSAASetting, true)
  GraphicSettingDB:UpdateUIData(GraphicSettingDB.SelectedWaterReflection, false)
  self:GetParentUI():SetDirty(true)
end
function GSC_MSAA:OnButton4x()
  log(bWriteLog and "GSC_MSAA:OnButton4x")
  self:PlayAudio(sound_config.click_v1)
  GraphicSettingDB:UpdateUIData(GraphicSettingDB.RenderMSAAValue, 4)
  GraphicSettingDB:UpdateUIData(GraphicSettingDB.RenderMSAASetting, true)
  GraphicSettingDB:UpdateUIData(GraphicSettingDB.SelectedWaterReflection, false)
  self:GetParentUI():SetDirty(true)
end
function GSC_MSAA:OnClickButton_Help()
  self:PlayAudio(sound_config.click_v1)
  UIManager.ShowUI(UIManager.UI_Config.common_questionmark_style_three, LocUtil.GetLocalizeResStr(180027), self.UIRoot.Button_Help)
end
local class = require("class")
local GSC_Base = require("client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_Base")
return class(GSC_Base, nil, GSC_MSAA)