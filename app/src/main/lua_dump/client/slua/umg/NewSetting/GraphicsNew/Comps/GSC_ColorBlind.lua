local GSC_ColorBlind = {}
local GraphicSettingDB = require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
function GSC_ColorBlind:ctor()
end
function GSC_ColorBlind:OnInitialize()
end
function GSC_ColorBlind:RegistEvents()
  local itemRoot = self.UIRoot
  self:AddControlEventByControl(itemRoot.CBSelectNormal, "OnClicked", self.OnClickNormal, self)
  self:AddControlEventByControl(itemRoot.CBSelectRed, "OnClicked", self.OnClickRed, self)
  self:AddControlEventByControl(itemRoot.CBSelectGreen, "OnClicked", self.OnClickGreen, self)
  self:AddControlEventByControl(itemRoot.CBSelectBlue, "OnClicked", self.OnClickBlue, self)
  self:AddControlEventByControl(itemRoot.Button_Help, "OnClicked", self.OnClickButton_Help, self)
end
function GSC_ColorBlind:OnAfterAllComponentsInitialized()
  local itemRoot = self.UIRoot
  itemRoot.TextBlock_Title:SetText(LocUtil.GetLocalizeResStr(24021403))
  self:SetWidgetVisible(self.UIRoot.Button_Help, true, true)
  local SettingGroupMgrClass = import("/Game/UMG/UI_BP/Setting/SettingGroupMgr.SettingGroupMgr_C")
  self.ColorBlindnessTypeMgr = SettingGroupMgrClass()
  self.ColorBlindnessTypeMgr:SetSwitcher(itemRoot.CBSelectSwitcher)
  self.ColorBlindnessTypeMgr:AddItem(0, itemRoot.CBNormalOn, itemRoot.CBNormalOff)
  self.ColorBlindnessTypeMgr:AddItem(1, itemRoot.CBRedOn, itemRoot.CBRedOff)
  self.ColorBlindnessTypeMgr:AddItem(2, itemRoot.CBGreenOn, itemRoot.CBGreenOff)
  self.ColorBlindnessTypeMgr:AddItem(3, itemRoot.CBBlueOn, itemRoot.CBBlueOff)
  self:Subscribe(GraphicSettingDB.ColorBlindnessType, function(old, value)
    self.ColorBlindnessTypeMgr:SelectIndex(value, true)
  end)
end
function GSC_ColorBlind:OnClickNormal()
  self:PlayAudio(sound_config.click_v1)
  local clickSuccess = self.ColorBlindnessTypeMgr:SelectIndex(0, false)
  if clickSuccess then
    GraphicSettingDB:UpdateUIData(GraphicSettingDB.ColorBlindnessType, 0)
    self:GetParentUI():SetDirty(true)
  end
end
function GSC_ColorBlind:OnClickRed()
  self:PlayAudio(sound_config.click_v1)
  local clickSuccess = self.ColorBlindnessTypeMgr:SelectIndex(1, false)
  if clickSuccess then
    GraphicSettingDB:UpdateUIData(GraphicSettingDB.ColorBlindnessType, 1)
    self:GetParentUI():SetDirty(true)
  end
end
function GSC_ColorBlind:OnClickGreen()
  self:PlayAudio(sound_config.click_v1)
  local clickSuccess = self.ColorBlindnessTypeMgr:SelectIndex(2, false)
  if clickSuccess then
    GraphicSettingDB:UpdateUIData(GraphicSettingDB.ColorBlindnessType, 2)
    self:GetParentUI():SetDirty(true)
  end
end
function GSC_ColorBlind:OnClickBlue()
  self:PlayAudio(sound_config.click_v1)
  local clickSuccess = self.ColorBlindnessTypeMgr:SelectIndex(3, false)
  if clickSuccess then
    GraphicSettingDB:UpdateUIData(GraphicSettingDB.ColorBlindnessType, 3)
    self:GetParentUI():SetDirty(true)
  end
end
function GSC_ColorBlind:OnClickButton_Help()
  self:PlayAudio(sound_config.click_v1)
  UIManager.ShowUI(UIManager.UI_Config.common_questionmark_style_three, LocUtil.GetLocalizeResStr(24021404), self.UIRoot.Button_Help)
end
local class = require("class")
local GSC_Base = require("client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_Base")
return class(GSC_Base, nil, GSC_ColorBlind)