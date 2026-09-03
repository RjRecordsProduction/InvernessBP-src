local GSC_Style = {}
local GraphicSettingDB = require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
local ERenderStyle = import("ERenderStyle")
local StyleArrayOn = {
  Default = "artstyleclassical_on",
  CLASSIC = "artstyleclassical_on",
  COLOURFUL = "artstylecolorful_on",
  REALISTIC = "artstylerealistic_on",
  SOFT = "artstylesoft_on",
  MOVIE = "Grid_film_on"
}
function GSC_Style:ctor()
  self.curSelectTab = 1
  self.curSelectStyle = nil
end
function GSC_Style:OnInitialize()
  self.UIRoot.TextBlock_Title:SetText(LocUtil.GetLocalizeResStr(24021401))
  self.UIRoot.TextBlock_0:SetText(LocUtil.GetLocalizeResStr(200000453))
  local STExtraGameInstance = import("STExtraGameInstance")
  local gameInstance = STExtraGameInstance.GetInstance()
  local bSupportSwitchRenderLevelRuntime = gameInstance:IsSupportSwitchRenderLevelRuntime()
  if bSupportSwitchRenderLevelRuntime then
    self:WidgetSelfHit(self.UIRoot.HorizontalBox_0)
  else
    self:WidgetCollapse(self.UIRoot.HorizontalBox_0)
  end
  self:SetWidgetVisible(self.UIRoot.Button_Help, false, true)
  self.Common_Tab_Horizontal_LevelThree_Text_UIBP = self:InitHorizontalLevelThreeTextTab(self.UIRoot.Common_Tab_Horizontal_LevelThree_Text_UIBP, {bDarkMode = true})
end
function GSC_Style:RegistEvents()
  local itemRoot = self.UIRoot
  self:AddControlEventByControl(itemRoot.Btn_artStyle_classical, "OnClicked", self.OnClickStyle, self, ERenderStyle.CLASSIC)
  self:AddControlEventByControl(itemRoot.btn_artStyle_colorful, "OnClicked", self.OnClickStyle, self, ERenderStyle.COLOURFUL)
  self:AddControlEventByControl(itemRoot.Btn_artStyle_realistic, "OnClicked", self.OnClickStyle, self, ERenderStyle.REALISTIC)
  self:AddControlEventByControl(itemRoot.Btn_artstyle_soft, "OnClicked", self.OnClickStyle, self, ERenderStyle.SOFT)
  self:AddControlEventByControl(itemRoot.btn_artstyle_film, "OnClicked", self.OnClickStyle, self, ERenderStyle.MOVIE)
  self:AddControlEventByControl(itemRoot.Button_Help, "OnClicked", self.OnClickButton_Help, self)
  self:AddOnCheckStateChangedEventByControl(self.UIRoot.CheckBox_0, self.OnCheckStateChanged, self)
  self.Common_Tab_Horizontal_LevelThree_Text_UIBP:AddOnSelectedCallback(self.OnClickedLevelOneTab, self)
end
function GSC_Style:OnPostInitialize()
end
function GSC_Style:OnAfterAllComponentsInitialized()
  local userSettings = slua_GameFrontendHUD:GetUserSettings()
  local bStyleSeparate = GraphicSettingDB:GetUIData(GraphicSettingDB.bStyleSeparate)
  local SelectedStyle = userSettings.BattleRenderStyle
  if bStyleSeparate and self.curSelectTab == 2 then
    SelectedStyle = userSettings.LobbyRenderStyle
  end
  self.curSelectStyle = SelectedStyle
  local Tab_Cfg = {
    LocUtil.GetLocalizeResStr(637),
    LocUtil.GetLocalizeResStr(8108)
  }
  self.curSelectTab = 1
  self.Common_Tab_Horizontal_LevelThree_Text_UIBP:SetTabs(Tab_Cfg, self.curSelectTab)
  self:UpdateUI()
end
function GSC_Style:OnGraphicsReset()
  printf("GSC_Style:OnGraphicsReset")
  local userSettings = slua_GameFrontendHUD:GetUserSettings()
  self.curSelectStyle = userSettings.BattleRenderStyle
  local Tab_Cfg = {
    LocUtil.GetLocalizeResStr(637),
    LocUtil.GetLocalizeResStr(8108)
  }
  self.curSelectTab = 1
  self.Common_Tab_Horizontal_LevelThree_Text_UIBP:SetTabs(Tab_Cfg, self.curSelectTab)
  self:UpdateUI()
end
function GSC_Style:UpdateUI()
  local itemRoot = self.UIRoot
  if not itemRoot then
    log(bWriteLog and "GSC_Style:UpdateUI not itemRoot")
    return
  end
  local bStyleSeparate = GraphicSettingDB:GetUIData(GraphicSettingDB.bStyleSeparate)
  itemRoot.CheckBox_0:SetIsChecked(bStyleSeparate)
  if bStyleSeparate then
    self:WidgetSelfHit(self.UIRoot.Common_Tab_Horizontal_LevelThree_Text_UIBP)
    self:WidgetSelfHit(itemRoot.CanvasPanel_LevelThree)
  else
    self:WidgetCollapse(self.UIRoot.Common_Tab_Horizontal_LevelThree_Text_UIBP)
    self:WidgetCollapse(itemRoot.CanvasPanel_LevelThree)
  end
  local style = self.curSelectStyle
  printf("GSC_Style:UpdateUI style = %s", style)
  local selectName
  for name, widget in pairs(StyleArrayOn) do
    self:WidgetCollapse(itemRoot[widget])
    if ERenderStyle[name] == style then
      selectName = name
    end
  end
  if selectName then
    self:WidgetSelfHit(itemRoot[StyleArrayOn[selectName]])
  end
end
function GSC_Style:OnClickedLevelOneTab(_, index, bIsFromClick)
  if bIsFromClick then
    self:PlayAudio(sound_config.click_v1)
  end
  self.curSelectTab = index
  local userSettings = slua_GameFrontendHUD:GetUserSettings()
  if index == 1 then
    self.curSelectStyle = userSettings.BattleRenderStyle
  elseif index == 2 then
    self.curSelectStyle = userSettings.LobbyRenderStyle
  end
  printf("GSC_Style:OnClickedLevelOneTab index = %s, SelectedStyle = %s", index, self.curSelectStyle)
  self:UpdateUI()
end
function GSC_Style:OnCheckStateChanged(bCheck)
  printf("GSC_Style:OnCheckStateChanged bCheck = %s", bCheck)
  self:PlayAudio(sound_config.click_v1)
  GraphicSettingDB:UpdateUIData(GraphicSettingDB.bStyleSeparate, bCheck)
  self:UpdateData()
  self:UpdateUI()
  self:GetParentUI():SetDirty(true)
end
function GSC_Style:OnClickStyle(style)
  printf("GSC_Style:OnClickStyle style = %s", style)
  self:PlayAudio(sound_config.click_v1)
  self.curSelectStyle = style
  self:UpdateData()
  self:UpdateUI()
  self:GetParentUI():SetDirty(true)
end
function GSC_Style:UpdateData()
  local bStyleSeparate = GraphicSettingDB:GetUIData(GraphicSettingDB.bStyleSeparate)
  local style = self.curSelectStyle
  if bStyleSeparate then
    if self.curSelectTab == 1 then
      GraphicSettingDB:UpdateUIData(GraphicSettingDB.BattleRenderStyle, style)
    elseif self.curSelectTab == 2 then
      GraphicSettingDB:UpdateUIData(GraphicSettingDB.LobbyRenderStyle, style)
    end
  else
    GraphicSettingDB:UpdateUIData(GraphicSettingDB.BattleRenderStyle, style)
    GraphicSettingDB:UpdateUIData(GraphicSettingDB.LobbyRenderStyle, style)
  end
end
function GSC_Style:GetRealSceneStyle()
  local gameStatus = GameStatus.GetGameStatus()
  printf("GSC_Style:GetRealSceneStyle gameStatus:%s", gameStatus)
  if GameStatus.IsIn2DLobby() then
    return GraphicSettingDB:GetUIData(GraphicSettingDB.LobbyRenderStyle)
  else
    return GraphicSettingDB:GetUIData(GraphicSettingDB.BattleRenderStyle)
  end
end
function GSC_Style:OnClickButton_Help()
  self:PlayAudio(sound_config.click_v1)
  UIManager.ShowUI(UIManager.UI_Config.common_questionmark_style_three, LocUtil.GetLocalizeResStr(24021402), self.UIRoot.Button_Help)
end
local class = require("class")
local GSC_Base = require("client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_Base")
return class(GSC_Base, nil, GSC_Style)