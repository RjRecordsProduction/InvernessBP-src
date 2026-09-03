local GSC_EnhanceLobby = {}
local GraphicSettingDB = require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
function GSC_EnhanceLobby:ctor()
end
function GSC_EnhanceLobby:OnInitialize()
  self.UIRoot.TextBlock_Title:SetText(LocUtil.GetLocalizeResStr(180024))
end
function GSC_EnhanceLobby:RegistEvents()
  self:AddControlEventByControl(self.UIRoot.Button_Switch, "OnClicked", self.OnClickButton_Switch, self)
  self:AddControlEventByControl(self.UIRoot.Button_Help, "OnClicked", self.OnClickButton_Help, self)
end
function GSC_EnhanceLobby:OnAfterAllComponentsInitialized()
  self:Subscribe(GraphicSettingDB.nEnhancedLobbyQuality, function(old, value)
    self:UpdateUI(value == 1)
  end)
end
function GSC_EnhanceLobby:OnApplyModify()
  local nEnhancedLobbyQuality = GraphicSettingDB:GetUIData(GraphicSettingDB.nEnhancedLobbyQuality)
  self:UpdateUI(nEnhancedLobbyQuality == 1)
end
function GSC_EnhanceLobby:OnClickButton_Switch()
  self:PlayAudio(sound_config.click_v1)
  local nEnhancedLobbyQuality = GraphicSettingDB:GetUIData(GraphicSettingDB.nEnhancedLobbyQuality)
  GraphicSettingDB:UpdateUIData(GraphicSettingDB.nEnhancedLobbyQuality, 3 - nEnhancedLobbyQuality)
  self:GetParentUI():SetDirty(true)
end
function GSC_EnhanceLobby:OnClickButton_Help()
  self:PlayAudio(sound_config.click_v1)
  UIManager.ShowUI(UIManager.UI_Config.common_questionmark_style_three, LocUtil.GetLocalizeResStr(180026), self.UIRoot.Button_Help)
end
function GSC_EnhanceLobby:UpdateUI(value)
  self:SelfHitTestInvisible()
  printf("GSC_EnhanceLobby:UpdateUI value: %s", value)
  self.UIRoot.Setting_Switch:SetSwitcherEnable2(value)
end
local class = require("class")
local GSC_Base = require("client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_Base")
return class(GSC_Base, nil, GSC_EnhanceLobby)