local Setting_GraphicsNew_UIBP = {}
local GraphicSettingDB = require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
local GraphicConst = require("client.slua.umg.NewSetting.GraphicsNew.GraphicConst")
local ERenderQuality = import("ERenderQuality")
function Setting_GraphicsNew_UIBP:ctor()
  self.items = {}
  self.components = {}
  self.isChildLoaded = false
  self.wrapCustom = nil
  self.wrapEnergy = nil
end
function Setting_GraphicsNew_UIBP:SubscribeNotFirstCallBack(settingKey, callback)
  self:AddDataListenerNotFirstCallBack(GraphicSettingDB:GetSuperData(), settingKey, callback)
end
function Setting_GraphicsNew_UIBP:Subscribe(settingKey, callback)
  self:AddDataListener(GraphicSettingDB:GetSuperData(), settingKey, callback)
end
function Setting_GraphicsNew_UIBP:OnInitialize()
  self:SetWidgetVisible(self.UIRoot.Setting_ScreenTips_UIBP, false)
  self:SetWidgetVisible(self.UIRoot.Btn_Modifyconfirm, false)
  GraphicSettingDB:LoadUserSetting()
  self:SubscribeNotFirstCallBack(GraphicSettingDB.CustomTab, function(old, value)
    self:OnCustomTabChange(value)
  end)
  self:SubscribeNotFirstCallBack(GraphicSettingDB.GraphicFavor, function(old, value)
    self:OnFavorChange(value)
  end)
  self:initDynamicUI()
  self.isChildLoaded = true
  local favor = GraphicSettingDB:GetUIData(GraphicSettingDB.GraphicFavor)
  if favor == GraphicConst.FavorDef.Custom then
    local CustomTab = GraphicSettingDB:GetUIData(GraphicSettingDB.CustomTab)
    self:OnCustomTabChange(CustomTab)
  else
    self:OnFavorChange(favor)
  end
end
function Setting_GraphicsNew_UIBP:initDynamicUI()
  local root = self.UIRoot.VerticalBox_Layer
  local lineIndex = 0
  local loadItem = function(name, parent)
    local itemCfg = GraphicConst.ItemConfig[name]
    assert_format(itemCfg, "Setting_GraphicsNew_UIBP:loadItem itemCfg is nil, name = %s", name)
    local script = itemCfg.Script
    local comp
    if script then
      comp = self:CreateChildWindowWithLuaAndBpPath(parent, nil, script, itemCfg.Path, name)
      self.components[name] = comp
      self.items[name] = comp.UIRoot
      self:SetWidgetVisible(comp.UIRoot, true)
      if itemCfg.Path == GraphicConst.SDoublePath then
        comp.UIRoot.Button_Switch:SetIsEnabled(true)
        self:SetWidgetVisible(comp.UIRoot.Setting_Switch.Canvas_Panel_UnClickable, false)
      end
    else
      comp = self:CreateChildWindowWithBpPath(parent, nil, itemCfg.Path)
      self.items[name] = comp.UIRoot
      self:SetWidgetVisible(comp.UIRoot, true)
    end
    if itemCfg.type == "Line" and comp.UIRoot.PlayDelayEnterAnim then
      comp.itemIndex = lineIndex
      lineIndex = lineIndex + 1
      comp.UIRoot:PlayDelayEnterAnim()
    end
  end
  local LayerWrap = "/Game/UMG/UI_BP/NewSetting/PictureItemBps/Layer_Item.Layer_Item"
  local AdvancedEnergyWrap = "/Game/UMG/UI_BP/NewSetting/PictureItemBps/AdvancedSetting_Item.AdvancedSetting_Item"
  loadItem("Favor_Item", root)
  loadItem("HDR_Item", root)
  loadItem("FPSFT", root)
  loadItem("CustomTab", root)
  do
    local parent = self:CreateChildWindowWithBpPath(root, nil, LayerWrap)
    self:SetWidgetVisible(parent.UIRoot.Mask, false)
    self.wrapCustom = parent.UIRoot
    local parentNode = parent.UIRoot.VerticalParent
    loadItem("Quality", parentNode)
    loadItem("QualityCompare", parentNode)
    loadItem("FPS", parentNode)
    loadItem("FPSFT2", parentNode)
    loadItem("Reflection", parentNode)
  end
  loadItem("Line2", root)
  do
    local parent = self:CreateChildWindowWithLuaAndBpPath(root, nil, "client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_AdvancedWrap", AdvancedEnergyWrap)
    self.wrapEnergy = parent.UIRoot
    local parentNode = parent.UIRoot.VerticalBox_Item
    loadItem("MSAA", parentNode)
    loadItem("EnergySaving", parentNode)
    loadItem("Shadow", parentNode)
    loadItem("AutoSmooth", parentNode)
    loadItem("VivoTurbo", parentNode)
  end
  loadItem("Line", root)
  loadItem("EnhanceLobby", root)
  loadItem("Line3", root)
  loadItem("Style", root)
  loadItem("Line4", root)
  loadItem("TitleParam", root)
  loadItem("Brightness", root)
  loadItem("SpecialScreen", root)
  loadItem("Line5", root)
  loadItem("ColorBlind", root)
  for k, v in pairs(self.components) do
    if v.OnAfterAllComponentsInitialized then
      v:OnAfterAllComponentsInitialized()
    end
  end
end
function Setting_GraphicsNew_UIBP:RegistEvents()
  self:AddOnClickedEventByControl(self.UIRoot.Btn_Modifyconfirm, self.OnClickBtn_Modifyconfirm, self)
  self:AddOnClickedEventByControl(self.UIRoot.btn_default, self.OnClickbtn_default, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_HideScreenTips, self.OnClickButton_HideScreenTips, self)
end
function Setting_GraphicsNew_UIBP:OnPostInitialize()
  self:UpdateUI()
end
function Setting_GraphicsNew_UIBP:OnClose()
  GraphicSettingDB:Clear()
  if self.bIsUIRectOffsetChanged == true then
    self.bIsUIRectOffsetChanged = nil
    EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_UIRECT_OFFSET_CHANGED)
  end
  self.items = nil
  self.components = nil
end
function Setting_GraphicsNew_UIBP:OnClickButton_HideScreenTips()
  self:PlayAudio(sound_config.click_v1)
  self:SetWidgetVisible(self.UIRoot.Setting_ScreenTips_UIBP, false)
  self:SetWidgetVisible(self.UIRoot.Button_HideScreenTips, false)
end
function Setting_GraphicsNew_UIBP:OnClickbtn_default()
  self:PlayAudio(sound_config.click_v1)
  local title = LocUtil.GetLocalizeResStr("101001")
  local content = LocUtil.GetLocalizeResStr("8009")
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, title, content, function()
    slua_GameFrontendHUD:BeginModifyUserSettings()
    GraphicSettingDB:ResetToDefault()
    for _, component in pairs(self.components) do
      if component.OnGraphicsReset then
        component:OnGraphicsReset()
      end
    end
    self:SetDirty(false)
    slua_GameFrontendHUD:FinishModifyUserSettings()
    EventRefreshArtQualityLabel()
  end)
end
function Setting_GraphicsNew_UIBP:OnClickBtn_Modifyconfirm()
  self:PlayAudio(sound_config.click_v1)
  printf("Setting_GraphicsNew_UIBP:OnClickBtn_Modifyconfirm")
  slua_GameFrontendHUD:BeginModifyUserSettings()
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  local gameInstance = slua_GameFrontendHUD:GetGameInstance()
  local GraphicHelperUtil = require("client.slua.umg.NewSetting.GraphicsNew.GraphicHelperUtil")
  local logic_setting_graphics = require("client.slua.logic.setting.logic_setting_graphics")
  local GraphicFavor = GraphicSettingDB:GetUIData(GraphicSettingDB.GraphicFavor)
  if GraphicFavor == nil or GraphicFavor == 0 then
    printf("Setting_GraphicsNew_UIBP:OnClickBtn_Modifyconfirm GraphicFavor is nil or 0")
    GraphicFavor = GraphicConst.FavorDef.Balance
  end
  local favorSetting = GraphicHelperUtil.GetFavorDefaultSettings(GraphicFavor)
  local lastBattleRenderQuality = SettingConfig.BattleRenderQuality
  local lastLobbyRenderQuality = SettingConfig.LobbyRenderQuality
  local lastBVerySmooth = SettingConfig.bVerySmooth
  local bShouldShowVerySmoothTips = false
  local StyleComp = self.components.Style
  if GraphicFavor ~= GraphicConst.FavorDef.Custom then
    if nil == favorSetting then
      LogExceptionAndReport("Setting_GraphicsNew_UIBP:OnClickBtn_Modifyconfirm favorSetting is nil, GraphicFavor = " .. GraphicFavor, 6)
      return
    end
    favorSetting.RealSceneRenderStyle = StyleComp:GetRealSceneStyle()
  end
  if GraphicFavor == GraphicConst.FavorDef.Custom then
    local changes = GraphicSettingDB.changes
    log_tree("Setting_GraphicsNew_UIBP:OnClickBtn_Modifyconfirm changes:", changes)
    if lastLobbyRenderQuality == ERenderQuality.VERYSMOOTH and changes.LobbyRenderQuality ~= nil and changes.LobbyRenderQuality ~= lastLobbyRenderQuality then
      printf("Setting_GraphicsNew_UIBP:OnClickBtn_Modifyconfirm changes.LobbyRenderQuality ~= lastLobbyRenderQuality")
      bShouldShowVerySmoothTips = true
    end
    if lastBattleRenderQuality == ERenderQuality.VERYSMOOTH and changes.BattleRenderQuality ~= nil and changes.BattleRenderQuality ~= lastBattleRenderQuality then
      printf("Setting_GraphicsNew_UIBP:OnClickBtn_Modifyconfirm changes.BattleRenderQuality ~= lastBattleRenderQuality")
      bShouldShowVerySmoothTips = true
    end
    if changes.LobbyRenderQuality == ERenderQuality.VERYSMOOTH then
      printf("Setting_GraphicsNew_UIBP:OnClickBtn_Modifyconfirm changes.LobbyRenderQuality == ERenderQuality.VERYSMOOTH")
      bShouldShowVerySmoothTips = true
    end
    if changes.BattleRenderQuality == ERenderQuality.VERYSMOOTH then
      printf("Setting_GraphicsNew_UIBP:OnClickBtn_Modifyconfirm changes.BattleRenderQuality == ERenderQuality.VERYSMOOTH")
      bShouldShowVerySmoothTips = true
    end
    if nil ~= changes.RenderMSAASetting or nil ~= changes.RenderMSAAValue or nil ~= changes.BattleRenderQuality or nil ~= changes.LobbyRenderQuality or nil ~= changes.ManorRenderQuality or nil ~= changes.MainCityRenderQuality or nil ~= changes.LobbyRenderStyle or nil ~= changes.BattleRenderStyle then
      local SelectedQuality = GraphicSettingDB:GetUIData(GraphicSettingDB.SelectedQuality)
      local SelectedStyle = StyleComp:GetRealSceneStyle()
      local RenderMSAASetting = GraphicSettingDB:GetUIData(GraphicSettingDB.RenderMSAASetting)
      local RenderMSAAValue = GraphicSettingDB:GetUIData(GraphicSettingDB.RenderMSAAValue)
      local CustomTab = GraphicSettingDB:GetUIData(GraphicSettingDB.CustomTab)
      local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
      local IsPHomeMode = PlanPH_GamePlay_Tools.IsPHomeMode()
      local IsMainCityMode = GameStatus.IsInMainCity()
      local bActualApply = 0
      if GameStatus.IsIn2DLobby() then
        printf("Setting_GraphicsNew_UIBP:OnClickBtn_Modifyconfirm GameStatus.IsIn2DLobby()")
        if CustomTab == GraphicConst.CustomTabDef.Lobby or CustomTab == GraphicConst.CustomTabDef.Global then
          bActualApply = 1
        end
      elseif GameStatus.IsInMainCity() then
        printf("Setting_GraphicsNew_UIBP:OnClickBtn_Modifyconfirm GameStatus.IsInMainCity()")
        if CustomTab == GraphicConst.CustomTabDef.MainCity or CustomTab == GraphicConst.CustomTabDef.Global then
          bActualApply = 2
        end
      elseif GameStatus.IsInFightingStatus() then
        printf("Setting_GraphicsNew_UIBP:OnClickBtn_Modifyconfirm GameStatus.IsInFightingStatus()")
        if (CustomTab == GraphicConst.CustomTabDef.Battle or CustomTab == GraphicConst.CustomTabDef.Global) and not IsPHomeMode then
          bActualApply = 3
        elseif (CustomTab == GraphicConst.CustomTabDef.Home or CustomTab == GraphicConst.CustomTabDef.Global) and IsPHomeMode then
          bActualApply = 4
        elseif (CustomTab == GraphicConst.CustomTabDef.MainCity or CustomTab == GraphicConst.CustomTabDef.Global) and IsMainCityMode then
          bActualApply = 5
        end
      end
      printf("Setting_GraphicsNew_UIBP:OnClickBtn_Modifyconfirm CustomTab = %s, bActualApply = %s", CustomTab, bActualApply)
      if 0 < bActualApply then
        logic_setting_graphics.SetQuality(gameInstance, SelectedQuality, SelectedStyle, RenderMSAASetting, RenderMSAAValue)
      else
        local RenderSettingsApplying = logic_setting_graphics.GetRenderSettingsApplying()
        local RenderStyle = RenderSettingsApplying.RenderStyleSetting
        local RenderQuality = RenderSettingsApplying.RenderQualitySetting
        logic_setting_graphics.SetQuality(gameInstance, RenderQuality, RenderStyle, RenderMSAASetting, RenderMSAAValue)
      end
    end
    GraphicSettingDB:SaveChanges()
    if nil ~= changes.SelectedFPS or nil ~= changes.FPSFineTuneSwitch or nil ~= changes.FPSFineTuneNum or nil ~= changes.BattleFPS or nil ~= changes.LobbyFPS or nil ~= changes.MainCityFPS then
      local FPSComp = self.components.FPS
      local RealSceneFPSLevel = FPSComp:GetRealSceneFPSLevel()
      logic_setting_graphics.SetFPS(gameInstance, RealSceneFPSLevel)
    end
  else
    if GraphicFavor == GraphicConst.FavorDef.BestQuality then
      local gsc_hdr = self.components.HDR_Item
      local SelectedHDRQuality = gsc_hdr.curSelectedQuality
      local SelectedHDRQualityFight = gsc_hdr.curSelectedQuality_Fight
      favorSetting.LobbyRenderQuality = SelectedHDRQuality
      favorSetting.BattleRenderQuality = SelectedHDRQualityFight
      favorSetting.ManorRenderQuality = SelectedHDRQualityFight
    elseif GraphicFavor == GraphicConst.FavorDef.Balance then
    elseif GraphicFavor == GraphicConst.FavorDef.FrameRate then
      favorSetting.FPSFineTuneSwitch = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneSwitch)
      favorSetting.FPSFineTuneNum = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneNum)
      favorSetting.FPSAutoInterpolation = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSAutoInterpolation)
      local ERenderQuality = import("ERenderQuality")
      local bVerySmoothOpen = GraphicSettingDB:GetUIData(GraphicSettingDB.bVerySmooth)
      if bVerySmoothOpen then
        favorSetting.BattleRenderQuality = ERenderQuality.VERYSMOOTH
        favorSetting.BattleFPS = GraphicHelperUtil.GetMaxFPSForQuality(ERenderQuality.VERYSMOOTH)
      else
        favorSetting.BattleRenderQuality = ERenderQuality.SMOOTH
        favorSetting.BattleFPS = GraphicHelperUtil.GetMaxFPSForQuality(ERenderQuality.SMOOTH)
      end
      if lastBVerySmooth ~= bVerySmoothOpen then
        printf("Setting_GraphicsNew_UIBP:OnClickBtn_Modifyconfirm lastBVerySmooth ~= bVerySmoothOpen")
        bShouldShowVerySmoothTips = true
      end
    end
    local uiBattleStyle = GraphicSettingDB:GetUIData(GraphicSettingDB.BattleRenderStyle)
    local uiLobbyStyle = GraphicSettingDB:GetUIData(GraphicSettingDB.LobbyRenderStyle)
    if uiBattleStyle then
      favorSetting.BattleRenderStyle = uiBattleStyle
    end
    if uiLobbyStyle then
      favorSetting.LobbyRenderStyle = uiLobbyStyle
    end
    printf("Setting_GraphicsNew_UIBP:OnClickBtn_Modifyconfirm uiBattleStyle = %s, uiLobbyStyle = %s", uiBattleStyle, uiLobbyStyle)
    logic_setting_graphics.ApplyFavorSettings(favorSetting, GraphicFavor)
    local changes = GraphicSettingDB.changes
    for key, value in pairs(changes) do
      if favorSetting[key] ~= nil then
        changes[key] = nil
      end
    end
    if changes[GraphicSettingDB.UIRectOffset] ~= nil then
      self.bIsUIRectOffsetChanged = true
    end
    GraphicSettingDB:SaveChanges()
  end
  if SettingConfig.TurboEnable then
    local logic_setting_graphics = require("client.slua.logic.setting.logic_setting_graphics")
    local UIUtil = require("client.common.ui_util")
    local gameInstance = UIUtil.GetGameInstance()
    logic_setting_graphics.SetFPS(gameInstance, 6)
  end
  for _, component in pairs(self.components) do
    if component.OnApplyModify then
      component:OnApplyModify()
    end
  end
  local uSTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local bFrameInterpolation = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue("t.EnableFrameInterpolation")
  local BattleFPS = GraphicSettingDB:GetUIData(GraphicSettingDB.BattleFPS)
  if 0 < bFrameInterpolation then
    local interpolationState = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSAutoInterpolation) == 2 and BattleFPS == 8
    self:SetFPSAutoInterpolation(interpolationState)
  end
  local IsVulkanEnable = GraphicSettingDB:GetUIData(GraphicSettingDB.IsVulkanEnable)
  Client.SetUserVulkanSetting(IsVulkanEnable)
  local gem_report_utils = require("client.logic.store.gem_report_utils")
  gem_report_utils.ReportLobbyClickEvent(gem_report_utils.SubEventName_Vulkan_Status, IsVulkanEnable and 1 or 0)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.Vulkan_Status, 0, tostring(IsVulkanEnable and 1 or 0))
  self:ReportTLogQualityAndFPS()
  self:ShowCorrectConfirmNotice(bShouldShowVerySmoothTips)
  self.UIRoot:SendSettingReport()
  EventRefreshArtQualityLabel()
  if logic_setting_graphics.NeedTempShutOffMSAA() then
    logic_setting_graphics.DoTempShutOffMSAA()
  end
  self:ApplyScaleFactor()
  if GameStatus.IsInFightingStatus() or GameStatus.IsInMainCity() then
    local PlayerController = slua_GameFrontendHUD:GetPlayerController()
    if slua.isValid(PlayerController) and PlayerController.GetPlayerCharacterSafety then
      local PlayerCharacter = PlayerController:GetPlayerCharacterSafety()
      if slua.isValid(PlayerCharacter) then
        local UnderWaterEffectComp = PlayerCharacter:getUnderWaterEffectComponent()
        if slua.isValid(UnderWaterEffectComp) then
          UnderWaterEffectComp:OnToggleUnderWaterPPV(false)
        end
      end
    end
  end
  if GameStatus.IsIn2DLobby() then
    local nEnhancedLobbyQuality = GraphicSettingDB:GetUIData(GraphicSettingDB.nEnhancedLobbyQuality)
    local APILevel = tostring(Client.GetCurrentRHILevel(GameFrontendHUD))
    if nEnhancedLobbyQuality == 1 and not Client.IsEmulator() and not string.find(APILevel, "ES2") then
      printf("Setting_GraphicsNew_UIBP:OnClickBtn_Modifyconfirm nEnhancedLobbyQuality true")
      local DeviceFPSHDR = gameInstance:GetDeviceFPSHDR()
      local DeviceFPSHigh = gameInstance:GetDeviceFPSHigh()
      local DeviceFPSLow = gameInstance:GetDeviceFPSLow()
      local GradeLevel = Client.GetTCDeviceLevel()
      local ERenderQuality = import("ERenderQuality")
      local ERenderStyle = import("ERenderStyle")
      local LobbyQuality = GraphicSettingDB:GetUIData(GraphicSettingDB.LobbyRenderQuality)
      local bDefaultOpenHDR = 1 < DeviceFPSHDR
      if DeviceFPSHigh < 1 then
        if gameInstance:GetInitMobileContentScaleFactor() < 0.8 then
          gameInstance:SetMobileContentScaleFactorAOS(0.8)
        else
          gameInstance:SetMobileContentScaleFactorAOS(1.1)
        end
      end
      if 1 < DeviceFPSHigh then
        if gameInstance:GetCurrentMaxFPS() > 30 then
          gameInstance:ExecuteCMD("t.MaxFPS", 30)
        end
        if LobbyQuality < ERenderQuality.HIGHDEFINITION and not bDefaultOpenHDR then
          local renderQuality = gameInstance:GetRenderQualityLastSet()
          renderQuality.RenderQualitySetting = ERenderQuality.HIGHDEFINITION
          gameInstance:SetRenderQuality(renderQuality)
        end
        gameInstance:ExecuteCMD("r.EnableLowFPSRender", 0)
        if 61 < DeviceFPSLow or 8 <= GradeLevel then
          gameInstance:ExecuteCMD("r.EnableSSSM", 1)
          gameInstance:ExecuteCMD("r.SSSMMipMaxCascadeNum", 3)
          gameInstance:SetSSSMBoundsScale(1.0)
          gameInstance:SetSSSMBoundsZOffset(0)
          gameInstance:SetDisableSSShadowSoft(false)
        elseif DeviceFPSHDR <= 30 then
          gameInstance:SetMobileContentScaleFactorAOS(1.2)
        end
      end
      if bDefaultOpenHDR and LobbyQuality < ERenderQuality.HIGHDEFINITIONPLUS then
        local renderQuality = gameInstance:GetRenderQualityLastSet()
        renderQuality.RenderQualitySetting = ERenderQuality.HIGHDEFINITIONPLUS
        gameInstance:SetRenderQuality(renderQuality)
        gameInstance:ExecuteCMD("r.BloomKarisAverage", 1)
        gameInstance:ExecuteCMD("r.BloomThreshold", 0.01)
        gameInstance:ExecuteCMD("r.BloomMoreShiningIntensityScale", 5)
      end
      if 31 < DeviceFPSHDR then
        gameInstance:SetMobileContentScaleFactorAOS(1.5)
        if 61 < DeviceFPSLow then
          gameInstance:SetMobileContentScaleFactorIOS(3.0)
        end
      end
      if 41 < DeviceFPSHDR then
      end
    else
      printf("Setting_GraphicsNew_UIBP:OnClickBtn_Modifyconfirm nEnhancedLobbyQuality false")
      gameInstance:ExecuteCMD("r.EnableSSSM", 0)
      gameInstance:ExecuteCMD("r.EnableLowFPSRender", 1)
      gameInstance:SetToInitMobileContentScaleFactor()
      gameInstance:ExecuteCMD("r.BloomThreshold", -1)
      gameInstance:ExecuteCMD("r.BloomKarisAverage", 0)
      gameInstance:ExecuteCMD("r.BloomMoreShiningIntensityScale", -1)
      local renderQuality = gameInstance:GetRenderQualityLastSet()
      local LobbyQuality = GraphicSettingDB:GetUIData(GraphicSettingDB.LobbyRenderQuality)
      if LobbyQuality ~= renderQuality.RenderQualitySetting then
        renderQuality.RenderQualitySetting = LobbyQuality
        gameInstance:SetRenderQuality(renderQuality)
      end
      local LobbyFPS = GraphicSettingDB:GetUIData(GraphicSettingDB.LobbyFPS)
      logic_setting_graphics.SetFPS(gameInstance, LobbyFPS)
    end
  elseif GameStatus.IsCollectionHallMode() then
    local FPS = GraphicHelperUtil.GetCurrentSceneFPS()
    local RenderQuality = GraphicHelperUtil.GetCurrentSceneRenderQuality()
    local RenderSettingsApplying = logic_setting_graphics.GetRenderSettingsApplying()
    local RenderMSAA = RenderSettingsApplying and RenderSettingsApplying.RenderMSAASetting or false
    local RenderMSAAValue = RenderSettingsApplying and RenderSettingsApplying.RenderMSAAValue or 0
    local settingConfig = logic_setting_graphics.GetSettingConfig()
    local RenderStyle = settingConfig and settingConfig.BattleRenderStyle or 0
    local enableShadow = gameInstance:GetUserSetingShadowQuality()
    local iRendQuality, iFps, bEnableShadow = GraphicHelperUtil.GetCollectRendQualityAndFPS()
    if iRendQuality ~= -1 then
      RenderQuality = iRendQuality
    end
    if iFps ~= -1 then
      FPS = iFps
    end
    if bEnableShadow ~= nil then
      enableShadow = bEnableShadow
    end
    logic_setting_graphics.SetQuality(gameInstance, RenderQuality, RenderStyle, RenderMSAA, RenderMSAAValue)
    logic_setting_graphics.SetFPS(gameInstance, FPS)
    gameInstance:SetUserSetingShadowQuality(enableShadow)
  end
  self:SetDirty(false)
  logic_setting_graphics.PostQualityToApm()
  slua_GameFrontendHUD:FinishModifyUserSettings()
end
function Setting_GraphicsNew_UIBP:SaveQualityAndFPS()
  printf("Setting_GraphicsNew_UIBP:SaveQualityAndFPS")
  if not slua.isValid(self.UIRoot) then
    printf("Setting_GraphicsNew_UIBP:SaveQualityAndFPS self.UIRoot is nil")
    return
  end
  slua_GameFrontendHUD:BeginModifyUserSettings()
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  local lastLobbyRenderQuality = SettingConfig.LobbyRenderQuality
  local lastBattleRenderQuality = SettingConfig.BattleRenderQuality
  local lastBVerySmooth = SettingConfig.bVerySmooth
  local changes = GraphicSettingDB.changes
  local bVerySmoothOpen = GraphicSettingDB:GetUIData(GraphicSettingDB.bVerySmooth)
  local bShouldShowVerySmoothTips = false
  if lastLobbyRenderQuality == ERenderQuality.VERYSMOOTH and changes.LobbyRenderQuality ~= nil and changes.LobbyRenderQuality ~= lastLobbyRenderQuality then
    printf("Setting_GraphicsNew_UIBP:SaveQualityAndFPS changes.LobbyRenderQuality ~= lastLobbyRenderQuality")
    bShouldShowVerySmoothTips = true
  end
  if lastBattleRenderQuality == ERenderQuality.VERYSMOOTH and changes.BattleRenderQuality ~= nil and changes.BattleRenderQuality ~= lastBattleRenderQuality then
    printf("Setting_GraphicsNew_UIBP:SaveQualityAndFPS changes.BattleRenderQuality ~= lastBattleRenderQuality")
    bShouldShowVerySmoothTips = true
  end
  if changes.LobbyRenderQuality == ERenderQuality.VERYSMOOTH then
    printf("Setting_GraphicsNew_UIBP:SaveQualityAndFPS changes.LobbyRenderQuality == ERenderQuality.VERYSMOOTH")
    bShouldShowVerySmoothTips = true
  end
  if changes.BattleRenderQuality == ERenderQuality.VERYSMOOTH then
    printf("Setting_GraphicsNew_UIBP:SaveQualityAndFPS changes.BattleRenderQuality == ERenderQuality.VERYSMOOTH")
    bShouldShowVerySmoothTips = true
  end
  if lastBVerySmooth ~= bVerySmoothOpen then
    printf("Setting_GraphicsNew_UIBP:SaveQualityAndFPS changes.bVerySmooth ~= lastBVerySmooth")
    bShouldShowVerySmoothTips = true
  end
  GraphicSettingDB:SaveChanges()
  local logic_setting_graphics = require("client.slua.logic.setting.logic_setting_graphics")
  local gameInstance = slua_GameFrontendHUD:GetGameInstance()
  local SelectedQuality = GraphicSettingDB:GetUIData(GraphicSettingDB.SelectedQuality)
  local SelectedStyle = self.components.Style:GetRealSceneStyle()
  local CustomTab = GraphicSettingDB:GetUIData(GraphicSettingDB.CustomTab)
  local RenderMSAASetting = GraphicSettingDB:GetUIData(GraphicSettingDB.RenderMSAASetting)
  local RenderMSAAValue = GraphicSettingDB:GetUIData(GraphicSettingDB.RenderMSAAValue)
  local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
  local IsPHomeMode = PlanPH_GamePlay_Tools.IsPHomeMode()
  local IsMainCityMode = GameStatus.IsInMainCity()
  local bActualApply = 0
  if GameStatus.IsIn2DLobby() then
    printf("Setting_GraphicsNew_UIBP:SaveQualityAndFPS GameStatus.IsIn2DLobby()")
    if CustomTab == GraphicConst.CustomTabDef.Lobby or CustomTab == GraphicConst.CustomTabDef.Global then
      bActualApply = 1
    end
  elseif GameStatus.IsInMainCity() then
    printf("Setting_GraphicsNew_UIBP:SaveQualityAndFPS GameStatus.IsInMainCity()")
    if CustomTab == GraphicConst.CustomTabDef.MainCity or CustomTab == GraphicConst.CustomTabDef.Global then
      bActualApply = 2
    end
  elseif GameStatus.IsInFightingStatus() then
    printf("Setting_GraphicsNew_UIBP:SaveQualityAndFPS GameStatus.IsInFightingStatus()")
    if (CustomTab == GraphicConst.CustomTabDef.Battle or CustomTab == GraphicConst.CustomTabDef.Global) and not IsPHomeMode then
      bActualApply = 3
    elseif (CustomTab == GraphicConst.CustomTabDef.Home or CustomTab == GraphicConst.CustomTabDef.Global) and IsPHomeMode then
      bActualApply = 4
    elseif (CustomTab == GraphicConst.CustomTabDef.MainCity or CustomTab == GraphicConst.CustomTabDef.Global) and IsMainCityMode then
      bActualApply = 5
    end
  end
  printf("Setting_GraphicsNew_UIBP:SaveQualityAndFPS bActualApply = %s", bActualApply)
  if 0 < bActualApply then
    logic_setting_graphics.SetQuality(gameInstance, SelectedQuality, SelectedStyle, RenderMSAASetting, RenderMSAAValue)
  else
    local RenderSettingsApplying = logic_setting_graphics.GetRenderSettingsApplying()
    local RenderStyle = RenderSettingsApplying.RenderStyleSetting
    local RenderQuality = RenderSettingsApplying.RenderQualitySetting
    logic_setting_graphics.SetQuality(gameInstance, RenderQuality, RenderStyle, RenderMSAASetting, RenderMSAAValue)
  end
  local FPSComp = self.components.FPS
  local RealSceneFPSLevel = FPSComp:GetRealSceneFPSLevel()
  logic_setting_graphics.SetFPS(gameInstance, RealSceneFPSLevel)
  local uSTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local bFrameInterpolation = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue("t.EnableFrameInterpolation")
  local BattleFPS = GraphicSettingDB:GetUIData(GraphicSettingDB.BattleFPS)
  if 0 < bFrameInterpolation then
    local interpolationState = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSAutoInterpolation) == 2 and BattleFPS == 8
    self:SetFPSAutoInterpolation(interpolationState)
  end
  if bShouldShowVerySmoothTips then
    ShowNotice(612401037)
  end
  slua_GameFrontendHUD:FinishModifyUserSettings()
  EventRefreshArtQualityLabel()
end
function Setting_GraphicsNew_UIBP:UpdateUI()
  log(bWriteLog and "Setting_GraphicsNew_UIBP:UpdateUI")
end
function Setting_GraphicsNew_UIBP:OnShowScreenTips(btn)
  self:SetWidgetVisible(self.UIRoot.Button_HideScreenTips, true, true)
  local widget = self.UIRoot.Setting_ScreenTips_UIBP
  local Geometry = btn:GetCachedGeometry()
  local SlateBlueprintLibrary = import("SlateBlueprintLibrary")
  local BtnAbsolutePosition = SlateBlueprintLibrary.GetAbsolutePosition(Geometry)
  local size = SlateBlueprintLibrary.GetAbsoluteSize(Geometry)
  BtnAbsolutePosition.X = BtnAbsolutePosition.X + size.X
  local LocalBtnPosition = SlateBlueprintLibrary.AbsoluteToLocal(self.UIRoot.CanvasPanel_Tip:GetCachedGeometry(), BtnAbsolutePosition)
  widget.Slot:SetPosition(LocalBtnPosition)
  self:SetWidgetVisible(widget, true)
  self:SetWidgetVisible(self.UIRoot.Button_HideScreenTips, true, true)
end
function Setting_GraphicsNew_UIBP:OnFavorChange(favor)
  printf("Setting_GraphicsNew_UIBP:OnFavorChange favor = %s", favor)
  if not self.isChildLoaded then
    return
  end
  if favor ~= GraphicConst.FavorDef.Custom then
    self:SetWidgetVisible(self.wrapCustom, false)
    self:SetWidgetVisible(self.wrapEnergy, false)
    self:SetWidgetVisible(self.items.Line2, false)
  end
end
function Setting_GraphicsNew_UIBP:OnCustomTabChange(customTab)
  printf("Setting_GraphicsNew_UIBP:OnCustomTabChange value = %s", customTab)
  if self.isChildLoaded then
    self:SetWidgetVisible(self.wrapEnergy, true)
    self:SetWidgetVisible(self.items.Line2, true)
    self:SetWidgetVisible(self.wrapCustom, true)
    self.components.Quality:OnCustomTabChange(customTab)
    self.components.FPS:OnCustomTabChange(customTab)
  else
  end
end
function Setting_GraphicsNew_UIBP:SetDirty(bDirty)
  if not slua.isValid(self.UIRoot) then
    printf("Setting_GraphicsNew_UIBP:SetDirty self.UIRoot is nil")
    return
  end
  local gameInstance = slua_GameFrontendHUD:GetGameInstance()
  local bIsSupportSwitchRenderLevelRuntime = gameInstance:IsSupportSwitchRenderLevelRuntime()
  if bIsSupportSwitchRenderLevelRuntime then
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(0)
    if bDirty then
      self:WidgetVisible(self.UIRoot.Btn_Modifyconfirm)
    else
      self:SetWidgetVisible(self.UIRoot.Btn_Modifyconfirm, false, true)
    end
  elseif bDirty then
    self:WidgetVisible(self.UIRoot.Btn_Modifyconfirm)
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(0)
  else
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(1)
  end
end
function Setting_GraphicsNew_UIBP:ShowOrHideVivoTurboMask(show)
  printf("Setting_GraphicsNew_UIBP:ShowOrHideVivoTurboMask show = %s", show)
  self:SetWidgetVisible(self.wrapCustom.Mask, show, true)
end
function Setting_GraphicsNew_UIBP:ReportTLogQualityAndFPS()
  local settingConfig = slua_GameFrontendHUD:GetUserSettings()
  local reasonStr = json.encode({
    LobbyRenderQuality = settingConfig.LobbyRenderQuality,
    LobbyFPS = settingConfig.LobbyFPS,
    BattleRenderQuality = settingConfig.BattleRenderQuality,
    BattleFPS = settingConfig.BattleFPS
  })
  log_tree("Setting_GraphicsNew_UIBP:ReportTLogQualityAndFPS reasonStr", reasonStr)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.SettingGraphicsQualityAndFPS, 0, reasonStr or "")
end
function Setting_GraphicsNew_UIBP:ShowCorrectConfirmNotice(bShouldShowVerySmoothTips)
  local gameInstance = slua_GameFrontendHUD:GetGameInstance()
  if gameInstance:IsSupportSwitchRenderLevelRuntime() then
    self:ShowCorrectConfirmSpecialNotice(bShouldShowVerySmoothTips)
  else
    local title = LocUtil.GetLocalizeResStr(45131)
    local msg = LocUtil.GetLocalizeResStr(200000496)
    local ok = LocUtil.GetLocalizeResStr(200000498)
    local cancel = LocUtil.GetLocalizeResStr(200000497)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, title, msg, function()
      if IsEditor then
        ShowNotice("===Editor do not need Restart===")
      else
        Client.RestartGame()
      end
    end, function()
      ShowNotice(LocUtil.GetLocalizeResStr(200000499))
    end, ok, cancel)
  end
end
function Setting_GraphicsNew_UIBP:ShowCorrectConfirmSpecialNotice(bShouldShowVerySmoothTips)
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  local ERenderQuality = import("ERenderQuality")
  if SettingConfig.BattleRenderQuality >= ERenderQuality.HIGHDEFINITIONPLUS then
    ShowNotice(24234)
  else
    ShowNotice(116007)
  end
  if bShouldShowVerySmoothTips then
    ShowNotice(612401037)
  end
end
function Setting_GraphicsNew_UIBP:ChangeScaleFactor(ScaleFactor)
  local gameInstance = slua_GameFrontendHUD:GetGameInstance()
  gameInstance:ExecuteCMD("r.MobileContentScaleFactor", ScaleFactor)
end
function Setting_GraphicsNew_UIBP:NeedChangeScaleFactor()
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  local IsAndroid = Client.GetDevicePlatformName() == DevicePlatformNameMacros.Android
  local IsBattle = GameStatus.IsInFightingStatus()
  local DeviceLevel = self:GetDeviceLevel()
  local DeviceModel = Client.GetDeviceModel()
  local EnableScaleFactor = false
  local ClientEVOConfig = require("client.logic.client_evo_config.client_evo_config")
  if ClientEVOConfig then
    EnableScaleFactor = ClientEVOConfig.IsMobileSCaleFactorEnable()
  end
  if IsAndroid and IsBattle and DeviceLevel == 6 then
    local NeedScale = self:IsDownClockingDevice(DeviceModel)
    return NeedScale and EnableScaleFactor
  end
  return false
end
function Setting_GraphicsNew_UIBP:IsDownClockingDevice(DeviceModel)
  local DeviceSmoothList = "SM-A047M|SM-A127F|SM-A127M|SM-A135F|SM-A135M|SM-A137F|SM-A145M|SM-A145P|SM-A217F|SM-A217M"
  local DeviceBalanceLow = "SM-A127M|SM-A145M|SM-A145P|SM-A217M|SM-A315G|SM-A705MN|SM-M127F|SM-M325FV"
  local DeviceHdLow = "SM-A047M|SM-A127F|SM-A127M|SM-A135F|SM-A135M|SM-A137F|SM-A145M|SM-A217F"
  local DeviceOtherSmooth = "V2242|V2058|V2057|moto g41|moto g31|moto g23|moto g(20)|M2101K7AG"
  local DeviceOtherBalanceLow = "220333QPG|21061119BI|moto g31|moto g41|KFONWI|21121119SG"
  local SearchTable = {
    DeviceSmoothList,
    DeviceBalanceLow,
    DeviceHdLow,
    DeviceOtherSmooth,
    DeviceOtherBalanceLow
  }
  for i = 1, #SearchTable do
    local Result = string.find(SearchTable[i], DeviceModel)
    if Result ~= nil then
      return true
    end
  end
  return false
end
function Setting_GraphicsNew_UIBP:ApplyScaleFactor()
  local NeedScale = self:NeedChangeScaleFactor()
  local CurrentScale = self:GetScaleFactor()
  if NeedScale and 0.85 < CurrentScale then
    self:ChangeScaleFactor(0.85)
  end
end
function Setting_GraphicsNew_UIBP:GetScaleFactor()
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  local CurrentSCaleFactor = UKismetSystemLibrary.GetConsoleVariableValue("r.MobileContentScaleFactor")
  return tonumber(CurrentSCaleFactor)
end
function Setting_GraphicsNew_UIBP:GetDeviceLevel()
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  local GradeLevel = UKismetSystemLibrary.GetConsoleVariableValue("r.TCQualityGrade")
  return tonumber(GradeLevel)
end
function Setting_GraphicsNew_UIBP:GetWidgetItem(ItemName)
  return self.items[ItemName]
end
function Setting_GraphicsNew_UIBP:SetFPSAutoInterpolation(state)
  log(bWriteLog and "GSC_FPSFT:GetDataFromTGPAFrameInterpolation SetFPSAutoInterpolation: " .. tostring(state))
  local strRegion = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if strRegion ~= PublishRegionMacros.BLUEHOLE then
    local TApmHelper = import("TApmHelper")
    local extraTable = {action = "isSupport"}
    local param = json.encode(extraTable)
    local s_result = TApmHelper.GetDataFromTGPA("FrameInterpolation", param)
    log(bWriteLog and "GSC_FPSFT:GetDataFromTGPAFrameInterpolation isSupport return: " .. s_result)
    local isSupport = false
    if s_result ~= nil then
      local d_result = json.decode(s_result)
      if d_result ~= nil and type(d_result) == "table" and d_result.body ~= nil then
        for k, v in pairs(d_result.body) do
          if tonumber(k) == tonumber(d_result.code) then
            local t = json.decode(v)
            isSupport = t.isSupport == "true"
          end
        end
      end
    end
    if isSupport then
      log(bWriteLog and "GSC_FPSFT: FrameInterpolation Begin")
      local switchState = false
      local g_param = {
        action = "getSwitchState"
      }
      local g_result = TApmHelper.GetDataFromTGPA("FrameInterpolation", json.encode(g_param))
      log(bWriteLog and "GSC_FPSFT: Get FrameInterpolation" .. tostring(g_result))
      local g_decoder = json.decode(g_result)
      if g_decoder.body ~= nil then
        for k, v in pairs(g_decoder.body) do
          if tonumber(k) == tonumber(g_decoder.code) then
            local t = json.decode(v)
            switchState = t.switchState == "true"
          end
        end
      end
      if not switchState and state then
        local s_param = {
          action = "setSwitchState",
          switchState = "true"
        }
        local s_result = TApmHelper.GetDataFromTGPA("FrameInterpolation", json.encode(s_param))
        log(bWriteLog and "GSC_FPSFT: Open FrameInterpolation" .. tostring(s_result))
        local GameInstance = slua_GameFrontendHUD:GetGameInstance()
      elseif switchState and not state then
        local s_param = {
          action = "setSwitchState",
          switchState = "false"
        }
        local s_result = TApmHelper.GetDataFromTGPA("FrameInterpolation", json.encode(s_param))
        log(bWriteLog and "GSC_FPSFT: Close FrameInterpolation" .. tostring(s_result))
        local GameInstance = slua_GameFrontendHUD:GetGameInstance()
      end
    end
    log(bWriteLog and "GSC_FPSFT: FrameInterpolation End")
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CSetting_GraphicsNew_UIBP = class(ui_base, nil, Setting_GraphicsNew_UIBP)
return CSetting_GraphicsNew_UIBP