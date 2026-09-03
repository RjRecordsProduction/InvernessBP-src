local GSC_HDR_Item = {}
local GraphicSettingDB = require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
local GraphicConst = require("client.slua.umg.NewSetting.GraphicsNew.GraphicConst")
local ERenderQuality = import("ERenderQuality")
local GraphicHelperUtil = require("client.slua.umg.NewSetting.GraphicsNew.GraphicHelperUtil")
local RENDER_QUALITY = {
  HD = ERenderQuality.HIGHDEFINITION,
  HD_PLUS = ERenderQuality.HIGHDEFINITIONPLUS,
  ULTRA_HD = ERenderQuality.ULTRAHIGHDEFINITION
}
local LOC_IDS = {
  LOBBY_HDR = 200000457,
  BATTLE_HDR = 200000458,
  OFF = 200000440,
  HDR_HD = 119600013,
  HDR_ULTRA = 119600014
}
function GSC_HDR_Item:ctor()
  self.curSelectedQuality = nil
  self.curSelectedQuality_Fight = nil
end
function GSC_HDR_Item:OnInitialize()
  local Root = self.UIRoot
  self.switcherGroup = {
    Root.WidgetSwitcher_0,
    Root.WidgetSwitcher_1,
    Root.WidgetSwitcher_2
  }
  self.switcherGroup_Fight = {
    Root.WidgetSwitcher_3,
    Root.WidgetSwitcher_4,
    Root.WidgetSwitcher_5
  }
  local STExtraGameInstance = import("STExtraGameInstance")
  local gameInstance = STExtraGameInstance.GetInstance()
  local bSupportSwitchRenderLevelRuntime = gameInstance:IsSupportSwitchRenderLevelRuntime()
  local textMapping = {
    TextBlock_Title = LOC_IDS.LOBBY_HDR,
    UTRichTextBlock_0 = LOC_IDS.BATTLE_HDR,
    TextBlock_106 = LOC_IDS.OFF,
    TextBlock_113 = LOC_IDS.OFF,
    TextBlock_0 = LOC_IDS.OFF,
    TextBlock_1 = LOC_IDS.OFF,
    TextBlock_114 = LOC_IDS.HDR_HD,
    TextBlock_115 = LOC_IDS.HDR_HD,
    TextBlock_2 = LOC_IDS.HDR_HD,
    TextBlock_3 = LOC_IDS.HDR_HD,
    TextBlock_134 = LOC_IDS.HDR_ULTRA,
    TextBlock_116 = LOC_IDS.HDR_ULTRA,
    TextBlock_4 = LOC_IDS.HDR_ULTRA,
    TextBlock_5 = LOC_IDS.HDR_ULTRA
  }
  for widgetName, locId in pairs(textMapping) do
    if Root[widgetName] then
      Root[widgetName]:SetText(LocUtil.GetLocalizeResStr(locId))
    end
  end
  self:WidgetSelfHit(self.UIRoot.VerticalBox_16)
  if not bSupportSwitchRenderLevelRuntime then
    self:WidgetCollapse(self.UIRoot.VerticalBox_16)
    self.UIRoot.UTRichTextBlock_0:SetText(LocUtil.GetLocalizeResStr(200000459))
  end
end
function GSC_HDR_Item:RegistEvents()
  self:AddOnClickedEventByControl(self.UIRoot.Button_Close, function()
    self:OnClickHDRButton(RENDER_QUALITY.HD, 1, false)
  end, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_1x, function()
    self:OnClickHDRButton(RENDER_QUALITY.HD_PLUS, 2, false)
  end, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_2x, function()
    self:OnClickHDRButton(RENDER_QUALITY.ULTRA_HD, 3, false)
  end, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Quality, function()
    self:OnClickQuestionButton(false)
  end, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_1, function()
    self:OnClickHDRButton(RENDER_QUALITY.HD, 1, true)
  end, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_2, function()
    self:OnClickHDRButton(RENDER_QUALITY.HD_PLUS, 2, true)
  end, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_3, function()
    self:OnClickHDRButton(RENDER_QUALITY.ULTRA_HD, 3, true)
  end, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_0, function()
    self:OnClickQuestionButton(true)
  end, self)
end
function GSC_HDR_Item:OnAfterAllComponentsInitialized()
  self:SubscribeNotFirstCallBack(GraphicSettingDB.GraphicFavor, function(old, value)
    self:UpdateUI()
  end)
  self:SubscribeNotFirstCallBack(GraphicSettingDB.nEnhancedLobbyQuality, function(old, value)
    self:UpdateUI_EnhancedLobbyQuality(value == 1)
  end)
  self:UpdateUI()
end
function GSC_HDR_Item:OnClickHDRButton(quality, toggleIndex, isFight)
  self:PlayAudio(sound_config.click_v1)
  self:trySetQuality(quality, toggleIndex, isFight)
end
function GSC_HDR_Item:OnClickQuestionButton(isFight)
  self:PlayAudio(sound_config.click_v1)
  local button = isFight and self.UIRoot.Button_0 or self.UIRoot.Button_Quality
  UIManager.ShowUI(UIManager.UI_Config.common_questionmark_style_three, LocUtil.GetLocalizeResStr(200000439), button)
end
function GSC_HDR_Item:switchToggle(toggleIndex, isFight)
  local group = isFight and self.switcherGroup_Fight or self.switcherGroup
  for i, v in ipairs(group) do
    v:SetActiveWidgetIndex(i == toggleIndex and 0 or 1)
  end
end
function GSC_HDR_Item:trySetQuality(quality, toggleIndex, isFight)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  local gameInstance = slua_GameFrontendHUD:GetGameInstance()
  if quality <= gameInstance:GetDeviceMaxSupportLevel() then
    if GraphicHelperUtil.CanChangeArtQuality(quality) then
      local inner = function()
        if isFight then
          self.curSelectedQuality_Fight = quality
        else
          self.curSelectedQuality = quality
        end
        self:UpdateHDRQualityAndFPS(quality, isFight)
        self:switchToggle(toggleIndex, isFight)
        self:GetParentUI():SetDirty(true)
      end
      if isFight and (quality == RENDER_QUALITY.HD_PLUS or quality == RENDER_QUALITY.ULTRA_HD) then
        CommonMsgBoxMgr.Show(2, LocUtil.GetLocalizeResStr(101001), LocUtil.GetLocalizeResStr(200000455), inner)
      else
        inner()
      end
    end
  else
    CommonMsgBoxMgr.Show(1, LocUtil.GetLocalizeResStr(101001), LocUtil.GetLocalizeResStr(116006))
  end
end
function GSC_HDR_Item:UpdateUI()
  local GraphicFavor = GraphicSettingDB:GetUIData(GraphicSettingDB.GraphicFavor)
  if GraphicFavor ~= GraphicConst.FavorDef.BestQuality then
    self:Collapsed()
    return
  end
  local fpsHigh = GraphicHelperUtil.PUBGDeviceFPSHigh()
  if fpsHigh <= 0 then
    printf("GSC_HDR_Item:UpdateUI PUBGDeviceFPSHigh = %s. Collapsed", fpsHigh)
    self:Collapsed()
    return
  end
  local HDRFps = GraphicHelperUtil.PUBGDeviceFPSHDR()
  local UltraHDRFps = GraphicHelperUtil.PUBGDeviceFPSUltralHigh()
  if HDRFps <= 0 and UltraHDRFps <= 0 then
    printf("GSC_HDR_Item:UpdateUI PUBGDeviceFPSHDR = %s, PUBGDeviceFPSUltralHigh = %s. Collapsed", HDRFps, UltraHDRFps)
    self:Collapsed()
    return
  end
  local SelectedHDRQuality = GraphicSettingDB:GetUIData(GraphicSettingDB.GFBestQLobby)
  local SelectedHDRQualityFight = GraphicSettingDB:GetUIData(GraphicSettingDB.GFBestQBattle)
  self.curSelectedQuality = SelectedHDRQuality
  self.curSelectedQuality_Fight = SelectedHDRQualityFight
  self:SelfHitTestInvisible()
  self:UpdateButtonState()
  self:UpdateCurQuality()
  self:UpdateDownload()
  local nEnhancedLobbyQuality = GraphicSettingDB:GetUIData(GraphicSettingDB.nEnhancedLobbyQuality)
  self:UpdateUI_EnhancedLobbyQuality(nEnhancedLobbyQuality == 1)
end
function GSC_HDR_Item:UpdateUI_EnhancedLobbyQuality(bEnhanced)
  local WidgetSwitcher_6 = self.UIRoot.WidgetSwitcher_6
  if not WidgetSwitcher_6 then
    return
  end
  if bEnhanced then
    self.UIRoot.TextBlock_11:SetText(LocUtil.GetLocalizeResStr(180025))
    WidgetSwitcher_6:SetActiveWidgetIndex(1)
  else
    WidgetSwitcher_6:SetActiveWidgetIndex(0)
  end
end
function GSC_HDR_Item:UpdateCurQuality()
  local updateToggle = function(quality, isFight)
    local index = quality == RENDER_QUALITY.HD and 1 or quality == RENDER_QUALITY.HD_PLUS and 2 or quality == RENDER_QUALITY.ULTRA_HD and 3 or 1
    self:switchToggle(index, isFight)
  end
  updateToggle(self.curSelectedQuality, false)
  updateToggle(self.curSelectedQuality_Fight, true)
end
function GSC_HDR_Item:UpdateHDRQualityAndFPS(quality, isFight)
  local fpsMapping = {
    [RENDER_QUALITY.HD] = GraphicHelperUtil.PUBGDeviceFPSHigh,
    [RENDER_QUALITY.HD_PLUS] = GraphicHelperUtil.PUBGDeviceFPSHDR,
    [RENDER_QUALITY.ULTRA_HD] = GraphicHelperUtil.PUBGDeviceFPSUltralHigh
  }
  local fpsFunc = fpsMapping[quality]
  if fpsFunc then
    local fpsValue = fpsFunc()
    local fpsKey = isFight and GraphicSettingDB.BattleFPS or GraphicSettingDB.LobbyFPS
    GraphicSettingDB:UpdateUIData(fpsKey, GraphicHelperUtil.FPSNum2Level(fpsValue))
  end
  if isFight then
    GraphicSettingDB:UpdateUIData(GraphicSettingDB.GFBestQBattle, quality)
  else
    GraphicSettingDB:UpdateUIData(GraphicSettingDB.GFBestQLobby, quality)
  end
end
function GSC_HDR_Item:UpdateButtonState()
  local HDRFps = GraphicHelperUtil.PUBGDeviceFPSHDR()
  local UltraHDRFps = GraphicHelperUtil.PUBGDeviceFPSUltralHigh()
  printf("GSC_HDR_Item:UpdateButtonState HDRFps = %s, UltraHDRFps = %s", HDRFps, UltraHDRFps)
  self:SetWidgetVisible(self.UIRoot.GridPanel_4, 0 < HDRFps, false)
  self:SetWidgetVisible(self.UIRoot.GridPanel_7, 0 < UltraHDRFps, false)
  self:SetWidgetVisible(self.UIRoot.GridPanel_52, 0 < HDRFps, false)
  self:SetWidgetVisible(self.UIRoot.GridPanel_66, 0 < UltraHDRFps, false)
end
function GSC_HDR_Item:UpdateDownload()
  if IsEditor then
    return
  end
  local gameInstance = slua_GameFrontendHUD:GetGameInstance()
  if gameInstance and GameStatus.IsInLobbyOrMainCity() then
    local PufferConst = require("client.slua.logic.download.puffer_const")
    local common_download_handler = require("client.slua.common.common_download_handler")
    local itemRoot = self.UIRoot
    local params = {}
    params.showProgress = true
    params.pos = FVector2D(6, -6)
    common_download_handler.CreateDownloadUIReturnUIBase(PufferConst.ENUM_DownloadType.RES, {
      "res_baltichd"
    }, self, itemRoot.Panel_SuperHigh, params)
    local MaxSupportLevel = gameInstance:GetDeviceMaxSupportLevel()
    if MaxSupportLevel == ERenderQuality.ULTRAHIGHDEFINITION then
      local params = {}
      params.showProgress = true
      params.pos = FVector2D(6, -6)
      common_download_handler.CreateDownloadUIReturnUIBase(PufferConst.ENUM_DownloadType.RES, {
        "res_baltichd"
      }, self, itemRoot.CanvasPanel_6, params)
    end
  end
end
local class = require("class")
local GSC_Base = require("client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_Base")
return class(GSC_Base, nil, GSC_HDR_Item)