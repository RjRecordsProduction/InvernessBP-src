local GSC_VivoTurbo = {}
local GraphicSettingDB = require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
local GraphicHelperUtil = require("client.slua.umg.NewSetting.GraphicsNew.GraphicHelperUtil")
function GSC_VivoTurbo:ctor()
end
function GSC_VivoTurbo:OnInitialize()
  local itemRoot = self.UIRoot
  itemRoot.TurboText:SetText(LocUtil.GetLocalizeResStr(6944))
  itemRoot.TurboDescrib:SetText(LocUtil.GetLocalizeResStr(8417))
end
function GSC_VivoTurbo:RegistEvents()
  local itemRoot = self.UIRoot
  self:AddControlEventByControl(itemRoot.TurboOpenButton, "OnClicked", self.OnVivoTurboOpenButtonClicked, self)
  self:AddControlEventByControl(itemRoot.TurboCloseButton, "OnClicked", self.OnVivoTurboCloseButtonClicked, self)
end
function GSC_VivoTurbo:OnAfterAllComponentsInitialized()
  local isShow = GraphicHelperUtil.IsSupportVivoTurbo()
  if isShow then
    self.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.Vivo:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    local vivoRoot = self.UIRoot
    vivoRoot.TurboText:SetText(LocUtil.GetLocalizeResStr(6944))
    vivoRoot.TurboDescrib:SetText(LocUtil.GetLocalizeResStr(8417))
    self:Subscribe(GraphicSettingDB.TurboEnable, function(oldValue, value)
      self:RefreshVivoTurboButton(value)
    end)
  else
    self.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function GSC_VivoTurbo:OnVivoTurboOpenButtonClicked()
  self:PlayAudio(sound_config.click_v1)
  GraphicSettingDB:UpdateUIData(GraphicSettingDB.TurboEnable, true)
  local GraphicHelperUtil = require("client.slua.umg.NewSetting.GraphicsNew.GraphicHelperUtil")
  local Quality = GraphicHelperUtil.GetCurrentSceneRenderQuality()
  GraphicSettingDB:UpdateUIData(GraphicSettingDB.TurboLastQuality, Quality)
  local ERenderQuality = import("ERenderQuality")
  GraphicSettingDB:UpdateSelectedQuality(ERenderQuality.HIGHDEFINITIONPLUS, true)
  self:GetParentUI():SetDirty(true)
end
function GSC_VivoTurbo:OnVivoTurboCloseButtonClicked()
  self:PlayAudio(sound_config.click_v1)
  GraphicSettingDB:UpdateUIData(GraphicSettingDB.TurboEnable, false)
  local TurboLastQuality = GraphicSettingDB:GetUIData(GraphicSettingDB.TurboLastQuality)
  GraphicSettingDB:UpdateSelectedQuality(TurboLastQuality, true)
  self:GetParentUI():SetDirty(true)
end
function GSC_VivoTurbo:RefreshVivoTurboButton(bOpen)
  local itemRoot = self.UIRoot
  self:SetWidgetVisible(itemRoot.TurboOpenButton, not bOpen, true)
  self:SetWidgetVisible(itemRoot.TurboCloseButton, bOpen, true)
  itemRoot.Setting_Switch_Turbo:SetSwitcherEnable2(bOpen, true)
  itemRoot.TextSwitcher:SetActiveWidgetIndex(bOpen and 0 or 1)
  self:GetParentUI():ShowOrHideVivoTurboMask(bOpen)
end
local class = require("class")
local GSC_Base = require("client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_Base")
return class(GSC_Base, nil, GSC_VivoTurbo)