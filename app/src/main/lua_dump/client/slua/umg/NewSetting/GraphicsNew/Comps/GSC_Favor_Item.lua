local GSC_Favor_Item = {}
local GraphicSettingDB = require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
local GraphicConst = require("client.slua.umg.NewSetting.GraphicsNew.GraphicConst")
local GraphicHelperUtil = require("client.slua.umg.NewSetting.GraphicsNew.GraphicHelperUtil")
function GSC_Favor_Item:ctor()
end
function GSC_Favor_Item:OnInitialize()
  self.switcherGroup = {
    self.UIRoot.WidgetSwitcher_0,
    self.UIRoot.WidgetSwitcher_1,
    self.UIRoot.WidgetSwitcher_2,
    self.UIRoot.WidgetSwitcher_3
  }
  self.UIRoot.TextBlock_0:SetText(LocUtil.GetLocalizeResStr(200000421))
  self.UIRoot.TextBlock_Quality21:SetText(LocUtil.GetLocalizeResStr(200000423))
  self.UIRoot.TextBlock_Quality2:SetText(LocUtil.GetLocalizeResStr(200000423))
  self.UIRoot.TextBlock_Quality31:SetText(LocUtil.GetLocalizeResStr(200000424))
  self.UIRoot.TextBlock_Quality3:SetText(LocUtil.GetLocalizeResStr(200000424))
  self.UIRoot.TextBlock_Quality41:SetText(LocUtil.GetLocalizeResStr(200000425))
  self.UIRoot.TextBlock_Quality4:SetText(LocUtil.GetLocalizeResStr(200000425))
  self.UIRoot.TextBlock_Quality51:SetText(LocUtil.GetLocalizeResStr(200000426))
  self.UIRoot.TextBlock_Quality5:SetText(LocUtil.GetLocalizeResStr(200000426))
  local STExtraGameInstance = import("STExtraGameInstance")
  local gameInstance = STExtraGameInstance.GetInstance()
  local bSupportSwitchRenderLevelRuntime = gameInstance:IsSupportSwitchRenderLevelRuntime()
  printf("GSC_Favor_Item:OnInitialize bSupportSwitchRenderLevelRuntime = %s", tostring(bSupportSwitchRenderLevelRuntime))
  if bSupportSwitchRenderLevelRuntime then
    self.UIRoot.WidgetSwitcher_4:SetActiveWidgetIndex(0)
    self.UIRoot.TextBlock_1:SetText(LocUtil.GetLocalizeResStr(34920))
    self.UIRoot.TextBlock_7:SetText(LocUtil.GetLocalizeResStr(34921))
    self.UIRoot.TextBlock_4:SetText(LocUtil.GetLocalizeResStr(656032))
  else
    self.UIRoot.WidgetSwitcher_4:SetActiveWidgetIndex(1)
  end
end
function GSC_Favor_Item:RegistEvents()
  self:AddOnClickedEventByControl(self.UIRoot.Btn_hightQualityHD, self.OnClickBtn_Custom, self)
  self:AddOnClickedEventByControl(self.UIRoot.Btn_HighQuality, self.OnClickBtn_FrameRate, self)
  self:AddOnClickedEventByControl(self.UIRoot.Btn_MiddleQuality, self.OnClickBtn_Banlance, self)
  self:AddOnClickedEventByControl(self.UIRoot.Btn_LowQuality, self.OnClickBtn_BestQuality, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Quality, self.OnClickButton_Quality, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Switch, self.OnClickButton_VerySmooth, self)
end
function GSC_Favor_Item:OnAfterAllComponentsInitialized()
  self:Subscribe(GraphicSettingDB.GraphicFavor, function(old, value)
    self:UpdateUI()
    self:OnFavorChange(value)
  end)
  local updateUIKeys = {
    GraphicSettingDB.GFBestQLobby,
    GraphicSettingDB.GFBestQBattle,
    GraphicSettingDB.BattleRenderQuality,
    GraphicSettingDB.LobbyRenderQuality,
    GraphicSettingDB.BattleFPS,
    GraphicSettingDB.LobbyFPS,
    GraphicSettingDB.CustomTab,
    GraphicSettingDB.MainCityRenderQuality,
    GraphicSettingDB.MainCityFPS,
    GraphicSettingDB.bVerySmooth,
    GraphicSettingDB.nEnhancedLobbyQuality
  }
  for _, key in ipairs(updateUIKeys) do
    self:SubscribeNotFirstCallBack(key, function(old, value)
      self:UpdateUI()
    end)
  end
end
function GSC_Favor_Item:OnClose()
  printf("GSC_Favor_Item:OnClose")
end
function GSC_Favor_Item:OnFavorChange(favor)
  self:GetParentUI():OnFavorChange(favor)
  if favor == GraphicConst.FavorDef.Custom then
    local CustomTab = GraphicSettingDB:GetUIData(GraphicSettingDB.CustomTab)
    self:GetParentUI():OnCustomTabChange(CustomTab)
  end
end
function GSC_Favor_Item:OnClickButton_Quality()
  self:PlayAudio(sound_config.click_v1)
  UIManager.ShowUI(UIManager.UI_Config.common_questionmark_style_three, LocUtil.GetLocalizeResStr(200000422), self.UIRoot.Button_Quality)
end
function GSC_Favor_Item:OnClickBtn_BestQuality()
  self:PlayAudio(sound_config.click_v1)
  local GFBestQBattle = GraphicSettingDB:GetUIData(GraphicSettingDB.GFBestQBattle)
  if GraphicHelperUtil.CanCombatStateSwitchQuality(GFBestQBattle) then
    self:onClickFavor(1)
  end
end
function GSC_Favor_Item:OnClickBtn_Banlance()
  self:PlayAudio(sound_config.click_v1)
  if GraphicHelperUtil.CanCombatStateSwitchQuality(nil) then
    self:onClickFavor(2)
  end
end
function GSC_Favor_Item:OnClickBtn_FrameRate()
  self:PlayAudio(sound_config.click_v1)
  if GraphicHelperUtil.CanCombatStateSwitchQuality(nil) then
    self:onClickFavor(3)
  end
end
function GSC_Favor_Item:OnClickBtn_Custom()
  self:PlayAudio(sound_config.click_v1)
  self:CustomFavorConfirm(function()
    self:onClickFavor(4)
  end)
end
function GSC_Favor_Item:onClickFavor(favor)
  GraphicSettingDB:UpdateUIData(GraphicSettingDB.GraphicFavor, favor)
  self:GetParentUI():SetDirty(true)
end
function GSC_Favor_Item:OnClickButton_VerySmooth()
  self:PlayAudio(sound_config.click_v1)
  local bVerySmoothSelect = GraphicSettingDB:GetUIData(GraphicSettingDB.bVerySmooth)
  printf("GSC_Favor_Item:OnClickButton_VerySmooth bVerySmoothSelect %s", bVerySmoothSelect)
  if not bVerySmoothSelect then
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    local title = LocUtil.GetLocalizeResStr(101001)
    local content = LocUtil.GetLocalizeResStr(612401040)
    CommonMsgBoxMgr.Show(2, title, content, function()
      GraphicSettingDB:UpdateUIDataOneMinus(GraphicSettingDB.bVerySmooth)
      self:GetParentUI():SetDirty(true)
    end)
  else
    GraphicSettingDB:UpdateUIDataOneMinus(GraphicSettingDB.bVerySmooth)
    self:GetParentUI():SetDirty(true)
  end
end
function GSC_Favor_Item:CustomFavorConfirm(okCallback)
  local titleMsg = LocUtil.GetLocalizeResStr(5077)
  local contentMsg = LocUtil.GetLocalizeResStr(200000432)
  local okMsg = LocUtil.GetLocalizeResStr(200000426)
  local cancelMsg = LocUtil.GetLocalizeResStr(7002)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, titleMsg, contentMsg, function()
    okCallback()
  end, nil, okMsg, cancelMsg)
end
function GSC_Favor_Item:UpdateFavorHighlight(favor)
  printf("GSC_Favor_Item:switchFavorite favor = %s", favor)
  for i, v in ipairs(self.switcherGroup) do
    if i == favor then
      self.switcherGroup[i]:SetActiveWidgetIndex(1)
    else
      self.switcherGroup[i]:SetActiveWidgetIndex(0)
    end
  end
end
function GSC_Favor_Item:UpdateUI()
  local favor = GraphicSettingDB:GetUIData(GraphicSettingDB.GraphicFavor)
  local STExtraGameInstance = import("STExtraGameInstance")
  local gameInstance = STExtraGameInstance.GetInstance()
  local bSupportSwitchRenderLevelRuntime = gameInstance:IsSupportSwitchRenderLevelRuntime()
  printf("GSC_Favor_Item:UpdateUI favor = %s, bSupportSwitchRenderLevelRuntime = %s", favor, bSupportSwitchRenderLevelRuntime)
  local Root = self.UIRoot
  self:UpdateFavorHighlight(favor)
  if favor == GraphicConst.FavorDef.BestQuality then
    Root.NoticeForDevice:SetText(LocUtil.GetLocalizeResStr(200000427))
  elseif favor == GraphicConst.FavorDef.Balance then
    Root.NoticeForDevice:SetText(LocUtil.GetLocalizeResStr(200000428))
  elseif favor == GraphicConst.FavorDef.FrameRate then
    Root.NoticeForDevice:SetText(LocUtil.GetLocalizeResStr(200000429))
  elseif favor == GraphicConst.FavorDef.Custom then
    Root.NoticeForDevice:SetText(LocUtil.GetLocalizeResStr(200000430))
  end
  local GraphicHelperUtil = require("client.slua.umg.NewSetting.GraphicsNew.GraphicHelperUtil")
  local favorSetting = GraphicHelperUtil.GetFavorDefaultSettings(favor)
  if favor == GraphicConst.FavorDef.Balance or favor == GraphicConst.FavorDef.FrameRate then
    if bSupportSwitchRenderLevelRuntime then
      Root.TextBlock_2:SetText(GraphicHelperUtil.GetQualityTextWithPrefix(favorSetting.BattleRenderQuality))
      Root.TextBlock_8:SetText(GraphicHelperUtil.GetQualityTextWithPrefix(favorSetting.LobbyRenderQuality))
      Root.TextBlock_5:SetText(GraphicHelperUtil.GetQualityTextWithPrefix(favorSetting.MainCityRenderQuality))
      Root.TextBlock_3:SetText(GraphicHelperUtil.GetFPSText(favorSetting.BattleFPS))
      Root.TextBlock_9:SetText(GraphicHelperUtil.GetFPSText(favorSetting.LobbyFPS))
      Root.TextBlock_6:SetText(GraphicHelperUtil.GetFPSText(favorSetting.MainCityFPS))
    else
      Root.TextBlock_12:SetText(GraphicHelperUtil.GetQualityTextWithPrefix(favorSetting.BattleRenderQuality))
      Root.TextBlock_13:SetText(GraphicHelperUtil.GetFPSText(favorSetting.BattleFPS))
    end
  elseif favor == GraphicConst.FavorDef.BestQuality then
    if bSupportSwitchRenderLevelRuntime then
      local SelectedHDRQuality = GraphicSettingDB:GetUIData(GraphicSettingDB.GFBestQLobby)
      local SelectedHDRQualityFight = GraphicSettingDB:GetUIData(GraphicSettingDB.GFBestQBattle)
      if SelectedHDRQuality then
        Root.TextBlock_8:SetText(GraphicHelperUtil.GetQualityTextWithPrefix(SelectedHDRQuality))
        local fpsLevel = GraphicHelperUtil.GetLobbyMaxFPSLevel(favor, SelectedHDRQuality)
        printf("GSC_Favor_Item:UpdateUI fpsLevel = %s", fpsLevel)
        Root.TextBlock_9:SetText(GraphicHelperUtil.GetFPSText(fpsLevel))
      else
        Root.TextBlock_8:SetText(GraphicHelperUtil.GetQualityTextWithPrefix(favorSetting.LobbyRenderQuality))
        Root.TextBlock_9:SetText(GraphicHelperUtil.GetFPSText(favorSetting.LobbyFPS))
      end
      if SelectedHDRQualityFight then
        Root.TextBlock_2:SetText(GraphicHelperUtil.GetQualityTextWithPrefix(SelectedHDRQualityFight))
        local fpsLevel = GraphicHelperUtil.GetMaxFPSForQuality(SelectedHDRQualityFight)
        printf("GSC_Favor_Item:UpdateUI battle fpsLevel = %s", fpsLevel)
        Root.TextBlock_3:SetText(GraphicHelperUtil.GetFPSText(fpsLevel))
      else
        Root.TextBlock_2:SetText(GraphicHelperUtil.GetQualityTextWithPrefix(favorSetting.BattleRenderQuality))
        Root.TextBlock_3:SetText(GraphicHelperUtil.GetFPSText(favorSetting.BattleFPS))
      end
      Root.TextBlock_5:SetText(GraphicHelperUtil.GetQualityTextWithPrefix(favorSetting.MainCityRenderQuality))
      Root.TextBlock_6:SetText(GraphicHelperUtil.GetFPSText(favorSetting.MainCityFPS))
    else
      local SelectedHDRQualityFight = GraphicSettingDB:GetUIData(GraphicSettingDB.GFBestQBattle)
      if SelectedHDRQualityFight then
        local fpsLevel = GraphicHelperUtil.GetLobbyMaxFPSLevel(favor, SelectedHDRQualityFight)
        printf("GSC_Favor_Item:UpdateUI fpsLevel = %s", fpsLevel)
        Root.TextBlock_12:SetText(GraphicHelperUtil.GetQualityTextWithPrefix(SelectedHDRQualityFight))
        Root.TextBlock_13:SetText(GraphicHelperUtil.GetFPSText(fpsLevel))
      else
        Root.TextBlock_12:SetText(GraphicHelperUtil.GetQualityTextWithPrefix(favorSetting.BattleRenderQuality))
        Root.TextBlock_13:SetText(GraphicHelperUtil.GetFPSText(favorSetting.BattleFPS))
      end
    end
  else
    local BattleQuality = GraphicSettingDB:GetUIData(GraphicSettingDB.BattleRenderQuality)
    local LobbyQuality = GraphicSettingDB:GetUIData(GraphicSettingDB.LobbyRenderQuality)
    local BattleFPS = GraphicSettingDB:GetUIData(GraphicSettingDB.BattleFPS)
    local LobbyFPS = GraphicSettingDB:GetUIData(GraphicSettingDB.LobbyFPS)
    local MainCityQuality = GraphicSettingDB:GetUIData(GraphicSettingDB.MainCityRenderQuality)
    local MainCityFPS = GraphicSettingDB:GetUIData(GraphicSettingDB.MainCityFPS)
    if bSupportSwitchRenderLevelRuntime then
      Root.TextBlock_2:SetText(GraphicHelperUtil.GetQualityTextWithPrefix(BattleQuality))
      Root.TextBlock_8:SetText(GraphicHelperUtil.GetQualityTextWithPrefix(LobbyQuality))
      Root.TextBlock_5:SetText(GraphicHelperUtil.GetQualityTextWithPrefix(MainCityQuality))
      Root.TextBlock_3:SetText(GraphicHelperUtil.GetFPSText(BattleFPS))
      Root.TextBlock_9:SetText(GraphicHelperUtil.GetFPSText(LobbyFPS))
      Root.TextBlock_6:SetText(GraphicHelperUtil.GetFPSText(MainCityFPS))
    else
      Root.TextBlock_12:SetText(GraphicHelperUtil.GetQualityTextWithPrefix(BattleQuality))
      Root.TextBlock_13:SetText(GraphicHelperUtil.GetFPSText(BattleFPS))
    end
  end
  if favor == GraphicConst.FavorDef.FrameRate then
    if Game:IsSupportVerySmooth() then
      printf("VerySmooth: IsSupportVerySmooth true")
      self.UIRoot.VerySmoothInFavor:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
      self.UIRoot.Setting_Switch:SetSwitcherEnable(true)
      self.UIRoot.Setting_Switch:SetSwitcherEnable2(GraphicSettingDB:GetUIData(GraphicSettingDB.bVerySmooth))
      self.UIRoot.TextBlock_10:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      self.UIRoot.TextBlock_Title:SetText(LocUtil.GetLocalizeResStr(119600024))
    end
  else
    printf("VerySmooth: IsSupportVerySmooth false")
    self.UIRoot.VerySmoothInFavor:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  local nEnhancedLobbyQuality = GraphicSettingDB:GetUIData(GraphicSettingDB.nEnhancedLobbyQuality)
  self:UpdateUI_EnhancedLobbyQuality(nEnhancedLobbyQuality == 1)
end
function GSC_Favor_Item:UpdateUI_EnhancedLobbyQuality(bEnhanced)
  local WidgetSwitcher_5 = self.UIRoot.WidgetSwitcher_5
  if not WidgetSwitcher_5 then
    return
  end
  if bEnhanced then
    self.UIRoot.TextBlock_11:SetText(LocUtil.GetLocalizeResStr(180025))
    WidgetSwitcher_5:SetActiveWidgetIndex(1)
  else
    WidgetSwitcher_5:SetActiveWidgetIndex(0)
  end
end
local class = require("class")
local GSC_Base = require("client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_Base")
return class(GSC_Base, nil, GSC_Favor_Item)