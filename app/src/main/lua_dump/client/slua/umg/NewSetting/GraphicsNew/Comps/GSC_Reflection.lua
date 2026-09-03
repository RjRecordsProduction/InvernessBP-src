local GSC_Reflection = {}
local GraphicSettingDB = require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
local GraphicConst = require("client.slua.umg.NewSetting.GraphicsNew.GraphicConst")
function GSC_Reflection:ctor()
end
function GSC_Reflection:OnInitialize()
  local itemRoot = self.UIRoot
  itemRoot.TextBlock_Title:SetText(LocUtil.GetLocalizeResStr(34969))
  self:SetWidgetVisible(itemRoot.Button_Help, true, true)
end
function GSC_Reflection:RegistEvents()
  local itemRoot = self.UIRoot
  self:AddControlEventByControl(itemRoot.Button_Switch, "OnClicked", self.OnClickReflection, self)
  self:AddControlEventByControl(itemRoot.Button_Help, "OnClicked", self.OnClickButton_Help, self)
end
function GSC_Reflection:OnAfterAllComponentsInitialized()
  self:SubscribeNotFirstCallBack(GraphicSettingDB.SelectedWaterReflection, function(old, value)
    self:UpdateUI()
  end)
  self:SubscribeNotFirstCallBack(GraphicSettingDB.SelectedQuality, function(old, value)
    self:UpdateUI()
  end)
  self:SubscribeNotFirstCallBack(GraphicSettingDB.CustomTab, function(old, value)
    self:UpdateUI()
  end)
  self:UpdateUI()
end
function GSC_Reflection:UpdateUI()
  local SelectedQuality = GraphicSettingDB:GetUIData(GraphicSettingDB.SelectedQuality)
  local CustomTab = GraphicSettingDB:GetUIData(GraphicSettingDB.CustomTab)
  local ERenderQuality = import("ERenderQuality")
  local bShow = SelectedQuality == ERenderQuality.ULTRAHIGHDEFINITION and CustomTab == GraphicConst.CustomTabDef.Home
  printf("GSC_Reflection:UpdateUI SelectedQuality:%s CustomTab:%s bShow:%s", SelectedQuality, CustomTab, bShow)
  if bShow then
    self:SelfHitTestInvisible()
  else
    self:Collapsed()
    return
  end
  local bOpen = GraphicSettingDB:GetUIData(GraphicSettingDB.SelectedWaterReflection)
  self.UIRoot.Setting_Switch:SetSwitcherEnable2(bOpen, true)
end
function GSC_Reflection:OnClickReflection(noVoice)
  if not noVoice then
    self:PlayAudio(sound_config.click_v1)
  end
  local value = GraphicSettingDB:UpdateUIDataOneMinus(GraphicSettingDB.SelectedWaterReflection)
  if value then
    GraphicSettingDB:UpdateUIData(GraphicSettingDB.RenderMSAAValue, 0)
    GraphicSettingDB:UpdateUIData(GraphicSettingDB.RenderMSAASetting, false)
  end
  self:GetParentUI():SetDirty(true)
end
function GSC_Reflection:OnClickButton_Help()
  self:PlayAudio(sound_config.click_v1)
  UIManager.ShowUI(UIManager.UI_Config.common_questionmark_style_three, LocUtil.GetLocalizeResStr(817282), self.UIRoot.Button_Help)
end
local class = require("class")
local GSC_Base = require("client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_Base")
return class(GSC_Base, nil, GSC_Reflection)