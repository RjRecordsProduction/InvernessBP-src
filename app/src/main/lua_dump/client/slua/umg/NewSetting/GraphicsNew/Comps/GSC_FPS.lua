local GSC_FPS = {}
local GraphicSettingDB = require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
local GraphicConst = require("client.slua.umg.NewSetting.GraphicsNew.GraphicConst")
local FPStoLevel = {
  [15] = 1,
  [20] = 2,
  [25] = 3,
  [30] = 4,
  [40] = 5,
  [60] = 6,
  [90] = 7,
  [120] = 8
}
local CachedIsEnableOfLevel = {}
local FPSButtons = {
  [2] = "Btn_fpslv2",
  [3] = "Btn_fpslv3",
  [4] = "Btn_fpslv4",
  [5] = "Btn_fpslv5",
  [6] = "Btn_fpslv6",
  [7] = "Btn_fpslv7",
  [8] = "Btn_fpslv8"
}
local FPSNodes = {
  [2] = "NodeFps20",
  [3] = "NodeFps25",
  [4] = "NodeFps30",
  [5] = "NodeFps40",
  [6] = "NodeFps60",
  [7] = "NodeFps90",
  [8] = "NodeFps120"
}
local minOfTwo = function(a, b)
  return a < b and a or b
end
local maxOfTwo = function(a, b)
  if a == nil or b == nil then
    return a or b
  end
  return b < a and a or b
end
function GSC_FPS:ctor()
end
function GSC_FPS:OnInitialize()
  local itemRoot = self.UIRoot
  itemRoot.TextBlock_FPS1:SetText(LocUtil.GetLocalizeResStr(119600025))
  itemRoot.TextBlock_FPS2:SetText(LocUtil.GetLocalizeResStr(119600016))
  itemRoot.TextBlock_FPS3:SetText(LocUtil.GetLocalizeResStr(119600017))
  itemRoot.TextBlock_FPS4:SetText(LocUtil.GetLocalizeResStr(119600018))
  itemRoot.TextBlock_FPS5:SetText(LocUtil.GetLocalizeResStr(119600019))
  itemRoot.TextBlock_FPS6:SetText(LocUtil.GetLocalizeResStr(119600020))
  itemRoot.TextBlock_FPS7:SetText(LocUtil.GetLocalizeResStr(119600021))
  itemRoot.TextBlock_FPS8:SetText(LocUtil.GetLocalizeResStr(119600040))
  itemRoot.TextBlock_FPS11:SetText(LocUtil.GetLocalizeResStr(119600025))
  itemRoot.TextBlock_FPS21:SetText(LocUtil.GetLocalizeResStr(119600016))
  itemRoot.TextBlock_FPS31:SetText(LocUtil.GetLocalizeResStr(119600017))
  itemRoot.TextBlock_FPS41:SetText(LocUtil.GetLocalizeResStr(119600018))
  itemRoot.TextBlock_FPS51:SetText(LocUtil.GetLocalizeResStr(119600019))
  itemRoot.TextBlock_FPS61:SetText(LocUtil.GetLocalizeResStr(119600020))
  itemRoot.TextBlock_FPS71:SetText(LocUtil.GetLocalizeResStr(119600021))
  itemRoot.TextBlock_FPS81:SetText(LocUtil.GetLocalizeResStr(119600040))
  self:WidgetCollapse(itemRoot.NodeFps15)
end
function GSC_FPS:RegistEvents()
  local itemRoot = self.UIRoot
  for i = 1, 8 do
    self:AddControlEventByControl(itemRoot["Btn_fpslv" .. i], "OnClicked", self.ClickFPS, self, i)
  end
  self:AddCommonEvent(EVENTTYPE_SETTING, EVENTID_SETTING_FPS_LIMIT_CONFIRM, self.OnFPSPopConfirm, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Quality, self.OnClickButton_Quality, self)
end
function GSC_FPS:OnAfterAllComponentsInitialized()
  self:SubscribeNotFirstCallBack(GraphicSettingDB.SelectedQuality, function(old, value)
    local SelectedFPSLevel = GraphicSettingDB:GetUIData(GraphicSettingDB.SelectedFPS)
    self:InitSelectedFPS(SelectedFPSLevel)
    self:UpdateUI()
  end)
  self:SubscribeNotFirstCallBack(GraphicSettingDB.nEnhancedLobbyQuality, function(old, value)
    local CustomTab = GraphicSettingDB:GetUIData(GraphicSettingDB.CustomTab)
    if value == 1 and (CustomTab == GraphicConst.CustomTabDef.Lobby or CustomTab == GraphicConst.CustomTabDef.Global) then
      self:SetFPSAndQualityEnable(true)
    else
      self:SetFPSAndQualityEnable(false)
    end
  end)
end
function GSC_FPS:OnCustomTabChange(customTab)
  printf("GSC_FPS:OnCustomTabChange customTab: %s", customTab)
  self:InitSelectedFPS()
  self:UpdateUI()
end
function GSC_FPS:InitRealSupportFPS()
  local SelectedQuality = GraphicSettingDB:GetUIData(GraphicSettingDB.SelectedQuality)
  local FPS, ExpandFPS
  local gameInstance = slua_GameFrontendHUD:GetGameInstance()
  if gameInstance:IsSupportSwitchRenderLevelRuntime() then
    FPS = gameInstance:GetDeviceMaxFPSByDeviceLevel(SelectedQuality)
    ExpandFPS = gameInstance:GetExpandDeviceMaxFPSByDeviceLevel(SelectedQuality)
  else
    local renderQuality = gameInstance:GetRenderQualityApplying().RenderQualitySetting
    FPS = gameInstance:GetDeviceMaxFPSByDeviceLevel(renderQuality)
    ExpandFPS = gameInstance:GetExpandDeviceMaxFPSByDeviceLevel(renderQuality)
  end
  local maxLevel = FPStoLevel[FPS] or 8
  local expandMaxLevel
  if ExpandFPS == 0 then
    expandMaxLevel = 0
  else
    expandMaxLevel = FPStoLevel[ExpandFPS]
  end
  printf("GSC_FPS:InitRealSupportFPS SelectedQuality:%s, FPS:%s, ExpandFPS:%s, maxLevel:%s, expandMaxLevel:%s", SelectedQuality, FPS, ExpandFPS, maxLevel, expandMaxLevel)
  local RealSupportFPS = {}
  for i = 1, 8 do
    if maxLevel >= i then
      RealSupportFPS[i] = {true}
    else
      local result = {false, false}
      if expandMaxLevel >= i then
        result[2] = true
      end
      RealSupportFPS[i] = result
    end
  end
  GraphicSettingDB:UpdateUIData(GraphicSettingDB.RealSupportFPS, RealSupportFPS, false)
  local itemRoot = self.UIRoot
  for level, node in pairs(FPSNodes) do
    local bSupport, bExpandSupport = RealSupportFPS[level][1], RealSupportFPS[level][2]
    if not bSupport and not bExpandSupport then
      itemRoot[node]:SetIsEnabled(false)
    else
      itemRoot[node]:SetIsEnabled(true)
    end
  end
  return RealSupportFPS
end
function GSC_FPS:OnClickButton_Quality()
  printf("GSC_FPS:OnClickButton_Quality")
  self:PlayAudio(sound_config.click_v1)
  local SelectedFPSLevel = GraphicSettingDB:GetUIData(GraphicSettingDB.SelectedFPS)
  local RealSupportFPS = GraphicSettingDB:GetUIData(GraphicSettingDB.RealSupportFPS)
  if nil == RealSupportFPS then
    log_warning("GSC_FPS:OnClickButton_Quality RealSupportFPS is nil, init it")
    RealSupportFPS = self:InitRealSupportFPS()
  end
  local bSupport, bExpandSupport = RealSupportFPS[SelectedFPSLevel][1], RealSupportFPS[SelectedFPSLevel][2]
  printf("GSC_FPS:OnClickButton_Quality SelectedFPSLevel:%s bSupport:%s bExpandSupport:%s", SelectedFPSLevel, bSupport, bExpandSupport)
  local tipText = ""
  if bSupport then
    if SelectedFPSLevel == GraphicConst.FPSLevelDef.FPS120 then
      tipText = LocUtil.GetLocalizeResStr(87564)
    elseif SelectedFPSLevel == GraphicConst.FPSLevelDef.FPS90 then
      tipText = LocUtil.GetLocalizeResStr(87563)
    else
      tipText = LocUtil.GetLocalizeResStr(87565)
    end
  else
    tipText = LocUtil.GetLocalizeResStr(87891)
  end
  UIManager.ShowUI(UIManager.UI_Config.common_questionmark_style_three, tipText, self.UIRoot.Button_Quality)
end
function GSC_FPS:ClickFPS(FPSLevel)
  self:PlayAudio(sound_config.click_v1)
  local SelectedFPSLevel = GraphicSettingDB:GetUIData(GraphicSettingDB.SelectedFPS)
  if SelectedFPSLevel == FPSLevel then
    printf("GSC_FPS:ClickFPS SelectedFPSLevel == FPSLevel, ignore")
    return
  end
  if not self:CanChangeQualityAndFPSPreCheck() then
    return
  end
  printf("GSC_FPS:ClickFPS FPSLevel: %s", FPSLevel)
  self:DoClickFPS(FPSLevel)
end
function GSC_FPS:OnFPSPopConfirm(_, _, FPSIndex)
  if not FPSIndex then
    return
  end
  self:DoClickFPS(FPSIndex)
end
function GSC_FPS:DoClickFPS(FPSLevel)
  local CustomTab = GraphicSettingDB:GetUIData(GraphicSettingDB.CustomTab)
  local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
  if CustomTab == GraphicConst.CustomTabDef.Home and PlanPH_GamePlay_Tools.IsPHomeMode() and FPSLevel > GraphicConst.FPSLevelDef.FPS60 then
    ShowNotice(655445)
    return
  end
  local RealSupportFPS = GraphicSettingDB:GetUIData(GraphicSettingDB.RealSupportFPS)
  if nil == RealSupportFPS then
    log_warning("GSC_FPS:DoClickFPS RealSupportFPS is nil, init it")
    RealSupportFPS = self:InitRealSupportFPS()
  end
  local support = RealSupportFPS[FPSLevel]
  local bSupport, bExpandSupport = support[1], support[2]
  if not bSupport and not bExpandSupport then
    printf("GSC_FPS:DoClickFPS FPSLevel:%s not support and not expand support. bSupport:%s, bExpandSupport:%s", FPSLevel, bSupport, bExpandSupport)
    ShowNotice(116013)
    return
  end
  local ok = function()
    if slua.isValid(self.UIRoot) then
      GraphicSettingDB:UpdateSelectedFPS(FPSLevel)
      self:UpdateUI()
      self:GetParentUI():SaveQualityAndFPS()
      self:GetParentUI():SetDirty(true)
    end
  end
  if bSupport then
    local SelectedQuality = GraphicSettingDB:GetUIData(GraphicSettingDB.SelectedQuality)
    if FPSLevel == GraphicConst.FPSLevelDef.FPS120 then
      local ERenderQuality = import("ERenderQuality")
      if SelectedQuality == ERenderQuality.VERYSMOOTH then
        if GraphicSettingDB:GetUIData(GraphicSettingDB.bEnergySaveManuelChangeFlag1) then
          printf("GSC_FPS:DoClickFPS hit flag1 change to heat warning")
          self:ChangeQualityAndFPSConfirm(ok)
        else
          printf("GSC_FPS:DoClickFPS keep 120fps warning")
          self:Change120FPSConfirm(ok)
        end
      elseif SelectedQuality == ERenderQuality.SMOOTH then
        if GraphicSettingDB:GetUIData(GraphicSettingDB.bEnergySaveManuelChangeFlag2) then
          printf("GSC_FPS:DoClickFPS hit flag2 change to heat warning")
          self:ChangeQualityAndFPSConfirm(ok)
        else
          printf("GSC_FPS:DoClickFPS keep 120fps warning")
          self:Change120FPSConfirm(ok)
        end
      end
    else
      local ERenderQuality = import("ERenderQuality")
      if (SelectedQuality == ERenderQuality.HIGHDEFINITIONPLUS or SelectedQuality == ERenderQuality.ULTRAHIGHDEFINITION or SelectedQuality == ERenderQuality.HIGHDEFINITION) and FPSLevel == GraphicConst.FPSLevelDef.FPS60 or FPSLevel >= GraphicConst.FPSLevelDef.FPS90 then
        self:ChangeQualityAndFPSConfirm(ok)
      else
        GraphicSettingDB:UpdateSelectedFPS(FPSLevel)
        self:UpdateUI()
        self:GetParentUI():SetDirty(true)
      end
    end
  else
    self:ClickExpandFPSConfirm(ok)
  end
end
function GSC_FPS:Change120FPSConfirm(okCallback, cancelCallback)
  local contentMsg = LocUtil.GetLocalizeResStr(200000258)
  local titleMsg = LocUtil.GetLocalizeResStr(200000252)
  local okMsg = LocUtil.GetLocalizeResStr(7001)
  local cancelMsg = LocUtil.GetLocalizeResStr(7002)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, titleMsg, contentMsg, function()
    log(bWriteLog and "[SettingGraphics] Click Confirm")
    if okCallback then
      okCallback()
    end
  end, function()
    log(bWriteLog and "[SettingGraphics] Click Cancel")
    if cancelCallback then
      cancelCallback()
    end
  end, okMsg, cancelMsg)
end
function GSC_FPS:ClickExpandFPSConfirm(okCallback, cancelCallback)
  local contentMsg = LocUtil.GetLocalizeResStr(180009)
  local titleMsg = LocUtil.GetLocalizeResStr(301137)
  local okMsg = LocUtil.GetLocalizeResStr(180010)
  local cancelMsg = LocUtil.GetLocalizeResStr(7002)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, titleMsg, contentMsg, function()
    if okCallback then
      okCallback()
    end
  end, function()
    if cancelCallback then
      cancelCallback()
    end
  end, okMsg, cancelMsg)
end
function GSC_FPS:UpdateUI()
  if false == self:IsCustomFavor() then
    printf("GSC_FPS:UpdateUI. ignore by not custom favor")
    self:Collapsed()
    return
  end
  local CustomTab = GraphicSettingDB:GetUIData(GraphicSettingDB.CustomTab)
  if CustomTab == GraphicConst.CustomTabDef.Home then
    printf("GSC_FPS:UpdateUI. ignore by Energy or Home tab")
    self:Collapsed()
    return
  end
  self:SelfHitTestInvisible()
  self:InitRealSupportFPS()
  local SelectedFPSLevel = GraphicSettingDB:GetUIData(GraphicSettingDB.SelectedFPS)
  printf("GSC_FPS:UpdateUI SelectedFPSLevel:%s", SelectedFPSLevel)
  self:UpdateFpsBetaIconVisible()
  self:UpdateSelectedFPSState(SelectedFPSLevel)
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uGameState = GameplayData.GetGameState()
  local CustomTab = GraphicSettingDB:GetUIData(GraphicSettingDB.CustomTab)
  if CustomTab == GraphicConst.CustomTabDef.Battle then
    if Game:IsValid(uGameState) then
      print(bWriteLog and string.format("GSC_FPS:UpdateUI RoomType[%s]", uGameState.RoomType))
      if uGameState.RoomType == "match" then
        print(bWriteLog and string.format("GSC_FPS:UpdateUI MaxFPSInMatch[%d]", uGameState.MaxFPSInMatch))
        if uGameState.MaxFPSInMatch and uGameState.MaxFPSInMatch > 0 then
          for FPS, Level in pairs(FPStoLevel) do
            local NodeFpsName = string.format("NodeFps%d", FPS)
            local NodeFpsWidget = self.UIRoot[NodeFpsName]
            local BtnName = string.format("Btn_fpslv%d", Level)
            local BtnWidget = self.UIRoot[BtnName]
            CachedIsEnableOfLevel[Level] = NodeFpsWidget:GetIsEnabled()
            if NodeFpsWidget and BtnWidget and FPS > uGameState.MaxFPSInMatch then
              NodeFpsWidget:SetIsEnabled(false)
              BtnWidget:SetIsEnabled(false)
              print(bWriteLog and string.format("GSC_FPS:UpdateUI, %s,%s Collapsed, Level[%d] FPS[%d] > MaxFPSInMatch[%d]", NodeFpsName, BtnName, Level, FPS, uGameState.MaxFPSInMatch))
            end
          end
        end
      end
    end
  elseif Game:IsValid(uGameState) and uGameState.RoomType == "match" then
    print(bWriteLog and string.format("GSC_FPS:UpdateUI restore widget's IsEnable to cached data"))
    for FPS, Level in pairs(FPStoLevel) do
      local NodeFpsName = string.format("NodeFps%d", FPS)
      local NodeFpsWidget = self.UIRoot[NodeFpsName]
      local BtnName = string.format("Btn_fpslv%d", Level)
      local BtnWidget = self.UIRoot[BtnName]
      local bIsEnable = CachedIsEnableOfLevel[Level]
      if bIsEnable ~= nil then
        NodeFpsWidget:SetIsEnabled(bIsEnable)
        BtnWidget:SetIsEnabled(bIsEnable)
      end
      print(bWriteLog and string.format("GSC_FPS:UpdateUI, %s,%s restore IsEnable Level[%d] FPS[%d] bIsEnable[%s]", NodeFpsName, BtnName, Level, FPS, bIsEnable))
    end
  end
  local nEnhancedLobbyQuality = GraphicSettingDB:GetUIData(GraphicSettingDB.nEnhancedLobbyQuality)
  local CustomTab = GraphicSettingDB:GetUIData(GraphicSettingDB.CustomTab)
  if nEnhancedLobbyQuality == 1 and (CustomTab == GraphicConst.CustomTabDef.Lobby or CustomTab == GraphicConst.CustomTabDef.Global) then
    self:SetFPSAndQualityEnable(true)
  else
    self:SetFPSAndQualityEnable(false)
  end
end
function GSC_FPS:SetFPSAndQualityEnable(bEnable)
  self:SetWidgetVisible(self.UIRoot.Image_Mask, bEnable)
end
function GSC_FPS:UpdateFpsBetaIconVisible()
  local SelectedQuality = GraphicSettingDB:GetUIData(GraphicSettingDB.SelectedQuality)
  local ERenderQuality = import("ERenderQuality")
  local bShowBeta90 = false
  if SelectedQuality > ERenderQuality.SMOOTH then
    printf("GSC_FPS:UpdateFpsBetaIconVisible show beta 90 by selected quality")
    bShowBeta90 = true
  end
  local RealSupportFPS = GraphicSettingDB:GetUIData(GraphicSettingDB.RealSupportFPS)
  if RealSupportFPS[GraphicConst.FPSLevelDef.FPS90] and RealSupportFPS[GraphicConst.FPSLevelDef.FPS90][2] then
    printf("GSC_FPS:UpdateFpsBetaIconVisible show beta 90 by expand support")
    bShowBeta90 = true
  end
  self:SetWidgetVisible(self.UIRoot.Reddot_Anchor_Item16, bShowBeta90)
  local bShowBeta120 = false
  if RealSupportFPS[GraphicConst.FPSLevelDef.FPS120] and RealSupportFPS[GraphicConst.FPSLevelDef.FPS120][2] then
    printf("GSC_FPS:UpdateFpsBetaIconVisible show beta 120 by expand support")
    bShowBeta120 = true
  end
  self:SetWidgetVisible(self.UIRoot.Reddot_Anchor_Item16_C_0, bShowBeta120)
end
function GSC_FPS:UpdateSelectedFPSState(selectedLevel)
  local LimitedFPSLevel, LimitedExpandFPSLevel = self:GetMaxFPSLevel()
  local MaxFPSLevel = maxOfTwo(LimitedFPSLevel, LimitedExpandFPSLevel)
  local itemRoot = self.UIRoot
  for level, name in pairs(FPSNodes) do
    if level <= MaxFPSLevel then
      self:WidgetSelfHit(itemRoot[name])
      if level == selectedLevel then
        itemRoot["WidgetSwitcher_" .. level]:SetActiveWidgetIndex(0)
      else
        itemRoot["WidgetSwitcher_" .. level]:SetActiveWidgetIndex(1)
      end
    else
      self:WidgetCollapse(itemRoot[name])
    end
  end
end
function GSC_FPS:InitSelectedFPS(SelectedFPSLevel)
  local userSettings = slua_GameFrontendHUD:GetUserSettings()
  local CustomTab = GraphicSettingDB:GetUIData(GraphicSettingDB.CustomTab)
  printf("GSC_FPS:InitSelectedFPS CustomTab:%s", CustomTab)
  if nil == SelectedFPSLevel then
    if CustomTab == GraphicConst.CustomTabDef.Battle then
      SelectedFPSLevel = userSettings.BattleFPS
    elseif CustomTab == GraphicConst.CustomTabDef.Lobby then
      SelectedFPSLevel = userSettings.LobbyFPS
    elseif CustomTab == GraphicConst.CustomTabDef.MainCity then
      SelectedFPSLevel = userSettings.MainCityFPS
    end
  end
  if SelectedFPSLevel then
    local LimitedFPSLevel, LimitedExpandFPSLevel = self:GetMaxFPSLevel()
    local MaxFPSLevel = maxOfTwo(LimitedFPSLevel, LimitedExpandFPSLevel)
    if SelectedFPSLevel > MaxFPSLevel then
      SelectedFPSLevel = MaxFPSLevel
    end
    printf("GSC_FPS:InitSelectedFPS MaxFPSIndex:%s SelectedFPSLevel:%s", MaxFPSLevel, SelectedFPSLevel)
    GraphicSettingDB:UpdateSelectedFPS(SelectedFPSLevel)
  end
end
function GSC_FPS:GetMaxFPSLevel()
  local MaxFPSByDeviceLevel, ExpandFPSByDeviceLevel
  local gameInstance = slua_GameFrontendHUD:GetGameInstance()
  if gameInstance:IsSupportSwitchRenderLevelRuntime() then
    local SelectedQuality = GraphicSettingDB:GetUIData(GraphicSettingDB.SelectedQuality)
    MaxFPSByDeviceLevel = gameInstance:GetDeviceMaxFPSByDeviceLevel(SelectedQuality)
    ExpandFPSByDeviceLevel = gameInstance:GetExpandDeviceMaxFPSByDeviceLevel(SelectedQuality)
    printf("GSC_FPS:GetMaxFPSLevel MaxFPSByDeviceLevel:%s ExpandFPSByDeviceLevel:%s, SelectedQuality:%s", MaxFPSByDeviceLevel, ExpandFPSByDeviceLevel, SelectedQuality)
  else
    local renderQuality = gameInstance:GetRenderQualityApplying().RenderQualitySetting
    MaxFPSByDeviceLevel = gameInstance:GetDeviceMaxFPSByDeviceLevel(renderQuality)
    ExpandFPSByDeviceLevel = gameInstance:GetExpandDeviceMaxFPSByDeviceLevel(renderQuality)
    printf("GSC_FPS:GetMaxFPSLevel MaxFPSByDeviceLevel:%s ExpandFPSByDeviceLevel:%s, renderQuality:%s", MaxFPSByDeviceLevel, ExpandFPSByDeviceLevel, renderQuality)
  end
  local LimitedFPS = MaxFPSByDeviceLevel
  local LimitedExpandFPS = ExpandFPSByDeviceLevel
  local CustomTab = GraphicSettingDB:GetUIData(GraphicSettingDB.CustomTab)
  if CustomTab ~= GraphicConst.CustomTabDef.Battle then
    LimitedFPS = minOfTwo(LimitedFPS, 90)
    LimitedExpandFPS = minOfTwo(LimitedExpandFPS, 90)
    printf("GSC_FPS:GetMaxFPSLevel limit to 90 by custom tab. LimitedFPS:%s LimitedExpandFPS:%s", LimitedFPS, LimitedExpandFPS)
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local uSTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local BLUEHOLE120 = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableIntValue("t.BLUEHOLE120")
  if BLUEHOLE120 == 0 and Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
    LimitedFPS = minOfTwo(LimitedFPS, 90)
    LimitedExpandFPS = minOfTwo(LimitedExpandFPS, 90)
    printf("GSC_FPS:GetMaxFPSLevel limit to 90 by bluehole120. LimitedFPS:%s LimitedExpandFPS:%s", LimitedFPS, LimitedExpandFPS)
  end
  local maincity_max_fps
  if CustomTab == GraphicConst.CustomTabDef.MainCity then
    local ERenderQuality = import("ERenderQuality")
    local SelectedQuality = GraphicSettingDB:GetUIData(GraphicSettingDB.SelectedQuality)
    if SelectedQuality == ERenderQuality.SMOOTH then
      maincity_max_fps = 60
    elseif SelectedQuality == ERenderQuality.BALANCE then
      maincity_max_fps = 40
    elseif SelectedQuality == ERenderQuality.HIGHDEFINITION or SelectedQuality == ERenderQuality.HIGHDEFINITIONPLUS or SelectedQuality == ERenderQuality.ULTRAHIGHDEFINITION then
      maincity_max_fps = 30
    else
      maincity_max_fps = 60
    end
    LimitedFPS = minOfTwo(LimitedFPS, maincity_max_fps)
    LimitedExpandFPS = minOfTwo(LimitedExpandFPS, maincity_max_fps)
    printf("GSC_FPS:GetMaxFPSLevel limit to maincity_max_fps. LimitedFPS:%s LimitedExpandFPS:%s, maincity_max_fps:%s", LimitedFPS, LimitedExpandFPS, maincity_max_fps)
  end
  local LimitedFPSLevel = 120 < LimitedFPS and 8 or FPStoLevel[LimitedFPS]
  local LimitedExpandFPSLevel = 120 < LimitedExpandFPS and 8 or FPStoLevel[LimitedExpandFPS]
  if LimitedExpandFPS == 0 then
    LimitedExpandFPSLevel = 0
  end
  printf("GSC_FPS:GetMaxFPSLevel LimitedFPS:%s -> level %s, LimitedExpandFPS:%s -> level %s", LimitedFPS, LimitedFPSLevel, LimitedExpandFPS, LimitedExpandFPSLevel)
  return LimitedFPSLevel, LimitedExpandFPSLevel
end
function GSC_FPS:GetRealSceneFPSLevel()
  local gameStatus = GameStatus.GetGameStatus()
  printf("GSC_FPS:GetRealSceneFPSLevel gameStatus:%s", gameStatus)
  if GameStatus.IsIn2DLobby() then
    printf("GSC_FPS:GetRealSceneFPSLevel debugFPS LobbyFPS")
    return GraphicSettingDB:GetUIData(GraphicSettingDB.LobbyFPS)
  elseif GameStatus.IsInMainCity() then
    printf("GSC_FPS:GetRealSceneFPSLevel debugFPS MainCityFPS")
    return GraphicSettingDB:GetUIData(GraphicSettingDB.MainCityFPS)
  elseif GameStatus.IsInFightingStatus() then
    if GameStatus.IsInMainCity() then
      printf("GSC_FPS:GetRealSceneFPSLevel debugFPS MainCityFPS")
      return GraphicSettingDB:GetUIData(GraphicSettingDB.MainCityFPS)
    else
      printf("GSC_FPS:GetRealSceneFPSLevel debugFPS BattleFPS")
      return GraphicSettingDB:GetUIData(GraphicSettingDB.BattleFPS)
    end
  end
end
local class = require("class")
local GSC_Base = require("client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_Base")
return class(GSC_Base, nil, GSC_FPS)