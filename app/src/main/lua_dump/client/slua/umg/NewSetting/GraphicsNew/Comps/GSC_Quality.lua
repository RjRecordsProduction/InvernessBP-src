local GSC_Quality = {}
local GraphicSettingDB = require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
local GraphicConst = require("client.slua.umg.NewSetting.GraphicsNew.GraphicConst")
local UIUtil = require("client.common.ui_util")
local ERenderQuality = import("ERenderQuality")
local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local IsDevelopment = USTExtraBlueprintFunctionLibrary.IsDevelopment()
local widgetName2ResId = {
  TextBlock_Quality1 = 119600024,
  TextBlock_Quality2 = 119600010,
  TextBlock_Quality3 = 119600011,
  TextBlock_Quality4 = 119600012,
  TextBlock_Quality5 = 119600013,
  TextBlock_Quality6 = 119600014,
  TextBlock_Quality7 = 119600015,
  TextBlock_Quality11 = 119600024,
  TextBlock_Quality21 = 119600010,
  TextBlock_Quality31 = 119600011,
  TextBlock_Quality41 = 119600012,
  TextBlock_Quality51 = 119600013,
  TextBlock_Quality61 = 119600014,
  TextBlock_Quality71 = 119600015
}
local QualityArrayOn = {
  SMOOTH = "status_lowquality_on",
  BALANCE = "status_middlequality_on",
  HIGHDEFINITION = "status_hightquality_on",
  HIGHDEFINITIONPLUS = "status_highquality+_on",
  ULTRAHIGHDEFINITION = "status_superhighquality_on",
  VERYSMOOTH = "status_SuperSmooth_on"
}
local QualityArrayOff = {
  SMOOTH = "status_lowquality_off",
  BALANCE = "status_middlequality_off",
  HIGHDEFINITION = "status_highquality_off",
  HIGHDEFINITIONPLUS = "status_highquality+_off",
  ULTRAHIGHDEFINITION = "status_superhighquality_off",
  VERYSMOOTH = "status_SuperSmooth_off"
}
function GSC_Quality:ctor()
end
function GSC_Quality:OnInitialize()
  local itemRoot = self.UIRoot
  for name, resId in pairs(widgetName2ResId) do
    itemRoot[name]:SetText(LocUtil.GetLocalizeResStr(resId))
  end
  self:SetWidgetVisible(itemRoot.status_ExtremelyON, false)
  self:SetWidgetVisible(itemRoot.status_ExtremelyOff, true)
end
function GSC_Quality:RegistEvents()
  local itemRoot = self.UIRoot
  self:AddControlEventByControl(itemRoot.Btn_LowQuality, "OnClicked", self.OnSmooth, self)
  self:AddControlEventByControl(itemRoot.Btn_MiddleQuality, "OnClicked", self.OnBalanced, self)
  self:AddControlEventByControl(itemRoot.Btn_HighQuality, "OnClicked", self.OnHD, self)
  self:AddControlEventByControl(itemRoot.Btn_hightQualityHD, "OnClicked", self.OnHDR, self)
  self:AddControlEventByControl(itemRoot.Btn_superhighquality, "OnClicked", self.OnUltraHDR, self)
  self:AddControlEventByControl(itemRoot.Button_Extremely, "OnClicked", self.OnUHD, self)
  self:AddControlEventByControl(itemRoot.Btn_supersmooth, "OnClicked", self.OnVerySmooth, self)
  self:AddControlEventByControl(itemRoot.Button_ImageContrast, "OnClicked", self.OnClickSuperHighContrast, self)
  self:AddControlEventByControl(itemRoot.Button_Quality, "OnClicked", self.OnClickHelp, self)
end
function GSC_Quality:OnAfterAllComponentsInitialized()
  self:SubscribeNotFirstCallBack(GraphicSettingDB.bOpenSprHghQltyComparison, function(old, value)
    printf("GSC_Quality:OnAfterAllComponentsInitialized bOpenSprHghQltyComparison: %s", value)
    self:ShowOrHideSprHighComparison(value)
  end)
  self:SubscribeNotFirstCallBack(GraphicSettingDB.TurboEnable, function(old, value)
    printf("GSC_Quality:OnAfterAllComponentsInitialized TurboEnable: %s", value)
  end)
  self:SubscribeNotFirstCallBack(GraphicSettingDB.nEnhancedLobbyQuality, function(old, value)
    printf("GSC_Quality:OnAfterAllComponentsInitialized nEnhancedLobbyQuality: %s", value)
    local CustomTab = GraphicSettingDB:GetUIData(GraphicSettingDB.CustomTab)
    if value == 1 and CustomTab == GraphicConst.CustomTabDef.Lobby or CustomTab == GraphicConst.CustomTabDef.Global then
      self:SetFPSAndQualityEnable(true)
    else
      self:SetFPSAndQualityEnable(false)
    end
  end)
  self:InitSelectedQuality()
  self:UpdateUI()
end
function GSC_Quality:SetFPSAndQualityEnable(TurboEnable)
  self:SetWidgetVisible(self.UIRoot.Image_Mask, TurboEnable)
end
function GSC_Quality:OnCustomTabChange(customTab)
  printf("GSC_Quality:OnCustomTabChange customTab: %s", customTab)
  self:InitSelectedQuality()
  self:UpdateUI()
end
function GSC_Quality:ShowOrHideSprHighComparison(bShow)
  printf("GSC_Quality:ShowOrHideSprHighComparison value: %s", bShow)
  local SelectedQuality = GraphicSettingDB:GetUIData(GraphicSettingDB.SelectedQuality)
  if SelectedQuality == nil then
    printf("GSC_Quality:ShowOrHideSprHighComparison SelectedQuality is nil")
    return
  end
  if SelectedQuality < ERenderQuality.ULTRAHIGHDEFINITION or SelectedQuality == ERenderQuality.VERYSMOOTH then
    bShow = false
  end
  local parent = self:GetParentUI()
  if bShow then
    parent.items.QualityCompare:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.WidgetSwitcher_UP:SetActiveWidgetIndex(1)
  else
    parent.items.QualityCompare:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.WidgetSwitcher_UP:SetActiveWidgetIndex(0)
  end
end
function GSC_Quality:UpdateVerySmoothQuality()
  local gameInstance = import("STExtraGameInstance").GetInstance()
  local show = false
  local CustomTab = GraphicSettingDB:GetUIData(GraphicSettingDB.CustomTab)
  if (CustomTab == GraphicConst.CustomTabDef.Battle or CustomTab == GraphicConst.CustomTabDef.Global) and Game:IsSupportVerySmooth() then
    show = true
  end
  self:SetWidgetVisible(self.UIRoot.GridPanel_SperSmooth, show)
end
function GSC_Quality:OnClickSuperHighContrast()
  self:PlayAudio(sound_config.click_v1)
  GraphicSettingDB:UpdateUIDataOneMinus(GraphicSettingDB.bOpenSprHghQltyComparison)
end
function GSC_Quality:OnVerySmooth()
  printf("GSC_Quality:OnVerySmooth")
  if not self:CanChangeQualityAndFPSPreCheck() then
    return
  end
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  local title = LocUtil.GetLocalizeResStr(101001)
  local content = LocUtil.GetLocalizeResStr(612401040)
  CommonMsgBoxMgr.Show(2, title, content, function()
    self:OnClickQuality(ERenderQuality.VERYSMOOTH)
  end)
end
function GSC_Quality:OnSmooth()
  if not self:CanChangeQualityAndFPSPreCheck() then
    return
  end
  self:OnClickQuality(ERenderQuality.SMOOTH)
end
function GSC_Quality:OnBalanced()
  if not self:CanChangeQualityAndFPSPreCheck() then
    return
  end
  self:OnClickQuality(ERenderQuality.BALANCE)
end
function GSC_Quality:OnHD()
  if not self:CanChangeQualityAndFPSPreCheck() then
    return
  end
  self:OnClickQuality(ERenderQuality.HIGHDEFINITION)
end
function GSC_Quality:OnHDR()
  if not self:CanChangeQualityAndFPSPreCheck() then
    return
  end
  self:OnClickQuality(ERenderQuality.HIGHDEFINITIONPLUS)
end
function GSC_Quality:OnUltraHDR()
  if not self:CanChangeQualityAndFPSPreCheck() then
    return
  end
  local logic_setting_graphics = require("client.slua.logic.setting.logic_setting_graphics")
  logic_setting_graphics.SetUltraHighRedPoint()
  self:OnClickQuality(ERenderQuality.ULTRAHIGHDEFINITION)
end
function GSC_Quality:OnClickHelp()
  self:PlayAudio(sound_config.click_v1)
  local UIUtil = require("client.common.ui_util")
  local gameInstance = UIUtil.GetGameInstance()
  local noticeText = ""
  if gameInstance:IsSupportSwitchRenderLevelRuntime() then
    noticeText = LocUtil.GetLocalizeResStr(87893)
  else
    noticeText = LocUtil.GetLocalizeResStr(87895)
  end
  UIManager.ShowUI(UIManager.UI_Config.common_questionmark_style_three, noticeText, self.UIRoot.Button_Quality)
end
function GSC_Quality:OnUHD()
  self:PlayAudio(sound_config.click_v1)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(1, LocUtil.GetLocalizeResStr(101001), LocUtil.GetLocalizeResStr(116009))
end
function GSC_Quality:OnClickQuality(quality)
  self:PlayAudio(sound_config.click_v1)
  local gameInstance = import("STExtraGameInstance").GetInstance()
  print("GSC_Quality:OnClickQuality quality: ", quality, gameInstance:GetDeviceMaxSupportLevel())
  local GraphicHelperUtil = require("client.slua.umg.NewSetting.GraphicsNew.GraphicHelperUtil")
  if quality == ERenderQuality.VERYSMOOTH then
    printf("[GSC_Quality] OnClickQuality Can change quality to very smooth")
    if GraphicHelperUtil.CanChangeArtQuality(quality) then
      printf("[GSC_Quality] Quality change")
      GraphicSettingDB:UpdateSelectedQuality(quality)
      self:UpdateUI()
      self:GetParentUI():SetDirty(true)
    end
  elseif quality <= gameInstance:GetDeviceMaxSupportLevel() then
    printf("[GSC_Quality] OnClickQuality Can change quality")
    if GraphicHelperUtil.CanChangeArtQuality(quality) then
      printf("[GSC_Quality] Quality change")
      local FPSLevel = GraphicSettingDB:GetUIData(GraphicSettingDB.SelectedFPS)
      local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
      local IsPHomeMode = PlanPH_GamePlay_Tools.IsPHomeMode()
      if IsPHomeMode then
        local CustomTab = GraphicSettingDB:GetUIData(GraphicSettingDB.CustomTab)
        if CustomTab == GraphicConst.CustomTabDef.Home then
          local PlanPH_ArtQuality = require("GameLua.Mod.PlanPH.Client.ArtQuality.PlanPH_ArtQuality")
          local fps = PlanPH_ArtQuality.curFPSCache
          FPSLevel = GraphicHelperUtil.FPSNum2Level(fps)
          printf("GSC_Quality:OnClickQuality Home FPSLevel: %s", FPSLevel)
        end
      end
      printf("[GSC_Quality] SelectedFPS: %s", FPSLevel)
      local ERenderQuality = import("ERenderQuality")
      if (quality == ERenderQuality.HIGHDEFINITIONPLUS or quality == ERenderQuality.ULTRAHIGHDEFINITION or quality == ERenderQuality.HIGHDEFINITION) and FPSLevel == GraphicConst.FPSLevelDef.FPS60 or FPSLevel >= GraphicConst.FPSLevelDef.FPS90 then
        self:ChangeQualityAndFPSConfirm(function()
          if slua.isValid(self.UIRoot) then
            GraphicSettingDB:UpdateSelectedQuality(quality)
            self:UpdateUI()
            self:GetParentUI():SaveQualityAndFPS()
            self:GetParentUI():SetDirty(true)
          end
        end)
      else
        GraphicSettingDB:UpdateSelectedQuality(quality)
        self:UpdateUI()
        self:GetParentUI():SetDirty(true)
      end
    end
  else
    printf("[[GSC_Quality] OnClickQuality Can't change quality")
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(1, LocUtil.GetLocalizeResStr(101001), LocUtil.GetLocalizeResStr(116006))
  end
end
function GSC_Quality:InitSelectedQuality()
  local userSettings = slua_GameFrontendHUD:GetUserSettings()
  local SelectedQuality
  local CustomTab = GraphicSettingDB:GetUIData(GraphicSettingDB.CustomTab)
  if CustomTab == GraphicConst.CustomTabDef.Battle or CustomTab == GraphicConst.CustomTabDef.Global then
    SelectedQuality = userSettings.BattleRenderQuality
  elseif CustomTab == GraphicConst.CustomTabDef.Lobby then
    SelectedQuality = userSettings.LobbyRenderQuality
  elseif CustomTab == GraphicConst.CustomTabDef.Home then
    SelectedQuality = userSettings.ManorRenderQuality
  else
    if CustomTab == GraphicConst.CustomTabDef.MainCity then
      SelectedQuality = userSettings.MainCityRenderQuality
    else
    end
  end
  if SelectedQuality then
    printf("GSC_Quality:InitSelectedQuality CustomTab: %s SelectedQuality: %s", CustomTab, SelectedQuality)
    GraphicSettingDB:UpdateUIData(GraphicSettingDB.SelectedQuality, SelectedQuality, false)
  end
end
function GSC_Quality:UpdateQulaityForCloudGame()
  if Client.GetYYXDeviceModel() == 0 then
    return
  end
  self:SetWidgetVisible(self.UIRoot.GridPanel_HDR, false)
  self:SetWidgetVisible(self.UIRoot.GridPanel_SperHigh, false)
  self:SetWidgetVisible(self.UIRoot.GridPanel_Extremely, false)
end
function GSC_Quality:UpdateQualityBtnVisible_LowDeviceOnly()
  local gameInstance = slua_GameFrontendHUD:GetGameInstance()
  local bSupportSwitchRenderLevelRuntime = gameInstance:IsSupportSwitchRenderLevelRuntime()
  if bSupportSwitchRenderLevelRuntime then
    return
  end
  local deviceMaxSupportLevel = gameInstance:GetDeviceMaxSupportLevel()
  printf("GSC_Quality:UpdateQualityBtnVisible_LowDeviceOnly deviceMaxSupportLevel: %s", deviceMaxSupportLevel)
  local itemRoot = self.UIRoot
  self:SetWidgetVisible(itemRoot.GridPanel_SperSmooth, true)
  self:SetWidgetVisible(itemRoot.GridPanel_Smooth, deviceMaxSupportLevel >= ERenderQuality.SMOOTH)
  self:SetWidgetVisible(itemRoot.GridPanel_Blance, deviceMaxSupportLevel >= ERenderQuality.BALANCE)
  self:SetWidgetVisible(itemRoot.GridPanel_High, deviceMaxSupportLevel >= ERenderQuality.HIGHDEFINITION)
  self:SetWidgetVisible(itemRoot.GridPanel_HDR, deviceMaxSupportLevel >= ERenderQuality.HIGHDEFINITIONPLUS)
  self:SetWidgetVisible(itemRoot.GridPanel_SperHigh, deviceMaxSupportLevel >= ERenderQuality.ULTRAHIGHDEFINITION)
  self:SetWidgetVisible(itemRoot.GridPanel_Extremely, false)
end
function GSC_Quality:UpdateUI()
  printf("GSC_Quality:UpdateUI")
  if false == self:IsCustomFavor() then
    printf("GSC_Quality:UpdateUI. ignore by not custom favor")
    self:Collapsed()
    return
  end
  self:SelfHitTestInvisible()
  local itemRoot = self.UIRoot
  self:UpdateVerySmoothQuality()
  self:UpdateQulaityForCloudGame()
  self:UpdateQualityBtnVisible_LowDeviceOnly()
  local quality = GraphicSettingDB:GetUIData(GraphicSettingDB.SelectedQuality)
  if quality == ERenderQuality.Default then
    quality = ERenderQuality.SMOOTH
  end
  for k, _ in pairs(QualityArrayOn) do
    self:SetWidgetVisible(itemRoot[QualityArrayOn[k]], ERenderQuality[k] == quality)
    self:SetWidgetVisible(itemRoot[QualityArrayOff[k]], ERenderQuality[k] ~= quality)
  end
  itemRoot.NoticeForDevice:SetText(LocUtil.GetLocalizeResStr(87892))
  local bShowQualityCompare = quality == ERenderQuality.ULTRAHIGHDEFINITION
  self:SetWidgetVisible(itemRoot.GridPanel_ImageContrast, bShowQualityCompare)
  if bShowQualityCompare then
    local bOpenSprHghQltyComparison = GraphicSettingDB:GetUIData(GraphicSettingDB.bOpenSprHghQltyComparison)
    self:ShowOrHideSprHighComparison(bOpenSprHghQltyComparison)
  else
    self:ShowOrHideSprHighComparison(false)
  end
  local nEnhancedLobbyQuality = GraphicSettingDB:GetUIData(GraphicSettingDB.nEnhancedLobbyQuality)
  local CustomTab = GraphicSettingDB:GetUIData(GraphicSettingDB.CustomTab)
  if nEnhancedLobbyQuality == 1 and (CustomTab == GraphicConst.CustomTabDef.Lobby or CustomTab == GraphicConst.CustomTabDef.Global) then
    self:SetFPSAndQualityEnable(true)
  else
    self:SetFPSAndQualityEnable(false)
  end
  self:UpdateDownload()
  self:UpdateGraphicsGuide()
end
function GSC_Quality:UpdateDownload()
  print("GSC_Quality:UpdateDownload", IsEditor, Client.IsWindows(), IsDevelopment)
  if IsEditor or Client.IsWindows() and IsDevelopment then
    return
  end
  local gameInstance = slua_GameFrontendHUD:GetGameInstance()
  if gameInstance and GameStatus.IsInLobbyOrMainCity() then
    local PufferConst = require("client.slua.logic.download.puffer_const")
    local common_download_handler = require("client.slua.common.common_download_handler")
    local itemRoot = self.UIRoot
    local params = {
      showProgress = true,
      pos = FVector2D(6, -6),
      size = 20
    }
    common_download_handler.CreateDownloadUIReturnUIBase(PufferConst.ENUM_DownloadType.RES, {
      "res_maptexmd"
    }, self, itemRoot.Panel_Download_HQ, params)
    local MaxSupportLevel = gameInstance:GetDeviceMaxSupportLevel()
    if MaxSupportLevel == ERenderQuality.ULTRAHIGHDEFINITION then
      common_download_handler.CreateDownloadUIReturnUIBase(PufferConst.ENUM_DownloadType.RES, {
        "res_baltichd"
      }, self, itemRoot.Panel_SuperHigh, params)
    end
  end
end
function GSC_Quality:UpdateGraphicsGuide()
  if not GameStatus.IsInLobbyOrMainCity() then
    return
  end
  local LogicSettingGraphics = require("client.slua.logic.setting.logic_setting_graphics")
  if not LogicSettingGraphics.CanPopNegativePlayGuide() then
    return
  end
  local widget = self.UIRoot.Btn_LowQuality
  self:AddTimerOnce(0, function()
    UIManager.ShowUI(UIManager.UI_Config.GraphicsQuality_Guide_UIBP, widget, function()
      log(bWriteLog and "[v_wllwu] GSC_Quality:UpdateGraphicsGuide click button ")
      local BasicDataTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataTLogReport)
      BasicDataTLogReport:ReportDelay(TLogEventDefine.PreLoss_ChangeGraphicsQuality)
      LogicSettingGraphics.SetNegativePlayGuideFlag(false)
      self:OnClickQuality(ERenderQuality.SMOOTH)
    end)
  end)
end
local class = require("class")
local GSC_Base = require("client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_Base")
return class(GSC_Base, nil, GSC_Quality)