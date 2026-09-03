local EntireMapWindow = {}
local ESlateVisibility = UEnums.ESlateVisibility
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local GlobalUIFunctionLibrary = require("client.slua.umg.ui_utility.global_ui_function_library")
local MapTabIconColor = {
  Select = FLinearColor(0.015996, 0.0185, 0.020289, 1.0),
  UnSelect = FLinearColor(0.283149, 0.533277, 0.571125, 1.0)
}
function EntireMapWindow:ctor(selfType)
  self.TLogHelperCache = {}
end
function EntireMapWindow:OnInitialize()
  local UIUtil = require("client.common.ui_util")
  UIUtil.SetAdaptation(self.UIRoot.AdapationCanvasPanel)
  log(bWriteLog and "EntireMapWindow:OnInitialize")
  self.UIRoot:InitWidget(true)
  self:OnInitWidget()
  self.RefreshMapByGM = false
  self.HasShowedTarget = {}
end
function EntireMapWindow:RegistEvents()
  EntireMapWindow.__super.RegistEvents(self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_SelfMark, self.HandleClickSelfMark, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_SelfLock, self.HandleLockBtnClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_AutoLock, self.HandleAutoLockBtnClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_DelMarkIcon, self.HandleClickDeleteMark, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_MultiMark, self.HandleClickMultiMark, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_SingleMark, self.HandleClickMultiMark, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_ClearMultiMark, self.HandleClickClearMultiMark, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_RevertMultiMark, self.HandleClickRevertMultiMark, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_HideMap, self.HandleClickHide, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_ZoomOut, self.HandleBtnZoomOut, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_ZoomIn, self.HandleBtnZoomIn, self)
  self:AddOnCheckStateChangedEventByControl(self.UIRoot.CheckBox_ReshowRoute, self.HandleBtnReshowAirPlaneRoute, self)
  self:AddControlEventByControl(self.UIRoot.Slider_MapZoom, "OnValueChanged", self.HandleSliderValueChanged, self)
  self:AddOnPressedEventByControl(self.UIRoot.Button_0, self.HandleBtn0Pressed, self)
  self:AddOnReleasedEventByControl(self.UIRoot.Button_0, self.HandleBtn0Realeased, self)
  self:AddControlEventByControl(self.UIRoot.MapCircleAndLineBlackboard, "MoveMap", self.HandleMoveMap, self)
  self:AddControlEventByControl(self.UIRoot.MapCircleAndLineBlackboard, "SetMarker", self.HandleSetMarker, self)
  self:AddControlEventByControl(self.UIRoot.MapCircleAndLineBlackboard, "ScaleMap", self.HandleScaleMap, self)
  self:AddControlEventByControl(self.UIRoot.MapCircleAndLineBlackboard, "OnClickEntireMap", self.HandleClickEntireMap, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_SHOW_MAP_AIRPLANE_ROUTE, self.OnHideReshowBtn, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_HIDE_MAP, self.HandleClickHide, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_SET_MAP_GUIDE_TARGET, self.OnSetGuideTarget, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_BEGIN_MAP_GUIDE, self.OnBeginMapGuide, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_CLICK_MULTI_MARK, self.OnClickMultiMark, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_INIT_MULTI_MARK_BUTTON, self.OnInitMultiMarkButton, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_CHANGE_ENTIRE_MAP_SIZE, self.OnChangeEntireMapSize, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_ENTIRE_MAP_MULTI_GUIDELINE, self.OnMapMultiGuideLine, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_ENTIRE_MAP_TOUCH, self.OnEntireMapBlackboardTouch, self)
  self:BindMiniMapPointerExceptionHandler()
  self:AddOnClickedEventByControl(self.UIRoot.Button_GameGuideTab, function()
    local TlogConfig = require("GameLua.Mod.BaseMod.Client.Config.TlogConfig")
    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
    local uPlayerState = GameplayData.GetPlayerState()
    if slua.isValid(uPlayerState) and TlogConfig then
      uPlayerState:RPC_ServerAddGeneralCount(TlogConfig.NewbieGuideImageTxt3, 1, false)
      uPlayerState:RPC_ServerAddGeneralCount(11532, 1, false)
    end
    self:SelectGameGuide(true)
    EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_ENTIRE_MAP_TOUCH)
  end, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_MapTab, self.SelectGameGuide, self, false)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_PHOTOGRAPHER_STATE, self.OnPhotoGrapherStateChange, self)
  local PhotoGrapherSubSystem = SubsystemMgr:Get("PhotoGrapherSubSystem")
  if PhotoGrapherSubSystem then
    self:OnPhotoGrapherStateChange(nil, nil, PhotoGrapherSubSystem.bIsPhotoGrapherMode)
  end
  EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_ADD_TO_FORCE_HIDE_UI_ARRAY, self.UIRoot.CanvasPanel_Root)
end
function EntireMapWindow:OnPhotoGrapherStateChange(_, __, bState)
  if bState then
    BatttleWindowMgr.HideUI("EntireMapWindow")
  end
end
function EntireMapWindow:OnSetGuideTarget(_, _, TargetNameID)
  local TableUtil = require("common.table_util")
  if TableUtil.Find(self.HasShowedTarget, TargetNameID) == -1 then
    local GameGuideUIMain = UIManager.GetUI(UIManager.UI_Config_InGame.GameGuideUIMain)
    if not GameGuideUIMain then
      self.      EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_HIGH_LIGHT_MAP_GUIDE_BUTTON)
      table.insert(self.HasShowedTarget, TargetNameID)
    end
  end
end
function EntireMapWindow:OnBeginMapGuide()
  self.BeginGuide = true
  local GameGuideUIMain = UIManager.GetUI(UIManager.UI_Config_InGame.GameGuideUIMain)
  if not GameGuideUIMain then
    EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_CHANGE_MAP_BUTTON_SHOW, true)
  else
    GameGuideUIMain:OnSetGuideTarget(_, _, self.TargetNameID)
    self.TargetNameID = nil
  end
end
function EntireMapWindow:CreateGameGuideUI()
  local GameGuideUIUtil = require("GameLua.Mod.BaseMod.Client.Map.GameGuideUI.GameGuideUIUtil")
  local UIConfig = GameGuideUIUtil.GetGameGuideUIMainConfig()
  local GameGuideUIMain = UIManager.GetUI(UIConfig)
  if not GameGuideUIMain then
    if not self.BeginGuide then
      self.TargetNameID = nil
    end
    GameGuideUIMain = UIManager.ShowUI(UIConfig, self.TargetNameID)
    self.TargetNameID = nil
  else
    GameGuideUIMain:SelfHitTestInvisible()
  end
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_CHANGE_MAP_BUTTON_SHOW, false)
end
function EntireMapWindow:CloseGameGuideUI()
  local GameGuideUIUtil = require("GameLua.Mod.BaseMod.Client.Map.GameGuideUI.GameGuideUIUtil")
  local UIConfig = GameGuideUIUtil.GetGameGuideUIMainConfig()
  local GameGuideUIMain = UIManager.GetUI(UIConfig)
  if GameGuideUIMain then
    local ScriptHelperClient = import("/Script/Client.ScriptHelperClient")
    if ScriptHelperClient.GetMemorySize() > 2.9 then
      GameGuideUIMain:Collapsed()
    else
      UIManager.CloseUI(UIConfig)
    end
  end
end
function EntireMapWindow:SelectGameGuide(bSelect)
  local UIRoot = self.UIRoot
  if not UIRoot then
    return
  end
  if bSelect then
    UIRoot.WidgetSwitcher_MapTab:SetActiveWidgetIndex(1)
    UIRoot.WidgetSwitcher_GuideTab:SetActiveWidgetIndex(0)
    UIRoot.CanvasPanel_ScaleButton:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
    UIRoot.CanvasPanel_AutoLock:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
    UIRoot.Button_SelfLock:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
    UIRoot.Image_RedDot:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    if not self.EntireMapGuideRedDot then
      local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
      SettingModule:SetOptionValue("EntireMapGuideRedDot", true)
    end
    self:CreateGameGuideUI()
  else
    UIRoot.WidgetSwitcher_MapTab:SetActiveWidgetIndex(0)
    UIRoot.WidgetSwitcher_GuideTab:SetActiveWidgetIndex(1)
    UIRoot.CanvasPanel_ScaleButton:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    UIRoot.CanvasPanel_AutoLock:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    UIRoot.Button_SelfLock:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    self:CloseGameGuideUI()
  end
  if bSelect then
    local PlayerState = GameplayData.GetPlayerState()
    if slua.isValid(PlayerState) then
      PlayerState:RPC_ServerAddGeneralCount(11523, 1, false)
    end
  end
end
function EntireMapWindow:CheckShowGameGuideButton()
  self.UIRoot.CanvasPanel_GuideTab:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.CanvasPanel_MapTab:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  local GameGuideUIUtil = require("GameLua.Mod.BaseMod.Client.Map.GameGuideUI.GameGuideUIUtil")
  local GameGuideConfig = GameGuideUIUtil.GetGameGuideConfig()
  if not GameGuideConfig then
    return false
  end
  self.UIRoot.CanvasPanel_GuideTab:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self.UIRoot.CanvasPanel_MapTab:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  return true
end
function EntireMapWindow:CheckShowJumpToMapModDetailUI()
  if not self:CheckShowGameGuideButton() then
    return
  end
  local uGameState = slua_GameFrontendHUD:GetGameState()
  if slua.isValid(uGameState) then
    if CGameState.IsCreativeMode and CGameState:IsCreativeMode() then
      return
    end
    local CurGameState = uGameState:GetGameModeState()
    if CurGameState ~= "ReadyState" then
      print(bWriteLog and "EntireMapWindow:CheckShowJumpToMapModDetailUI is not ReadyState")
      return
    end
  end
  local ClientGameMain = require("GameLua.GameCore.Main.ClientGameMain")
  if not ClientGameMain then
    return
  end
  local NewbieGuideConfig = ClientGameMain.GetCurrentConfig("NewbieGuideConfig")
  if type(NewbieGuideConfig) == "string" then
    NewbieGuideConfig = require(NewbieGuideConfig)
  end
  local ShouldShowEnterGameFaceGuide = false
  if NewbieGuideConfig then
    for _, GuideItem in pairs(NewbieGuideConfig) do
      if GuideItem and GuideItem.Actions then
        for _, Action in pairs(GuideItem.Actions) do
          if Action and Action.Params and (Action.Params.ConfigName == "EnterGameFaceGuide" or Action.Params.UIConfigName == "EnterGameFaceGuide") then
            ShouldShowEnterGameFaceGuide = true
            break
          end
        end
      end
      if ShouldShowEnterGameFaceGuide then
        break
      end
    end
  end
  local JumpToMapModDetailUI = UIManager.GetUI(UIManager.UI_Config_InGame.JumpToMapModDetailUI)
  if not ShouldShowEnterGameFaceGuide and not JumpToMapModDetailUI then
    UIManager.ShowUI(UIManager.UI_Config_InGame.JumpToMapModDetailUI)
  elseif UIManager.UI_Config_InGame and UIManager.UI_Config_InGame.JumpToMapModDetailUI and JumpToMapModDetailUI then
    UIManager.CloseUI(UIManager.UI_Config_InGame.JumpToMapModDetailUI)
  end
end
function EntireMapWindow:PlayBlueCircleAnim()
  if not slua.isValid(self.UIRoot.CurrentMapUIBP) then
    return
  end
  if not self.UIRoot.CurrentMapUIBP.BlueWidget then
    self.UIRoot.CurrentMapUIBP:OnSyncCircleInfo()
  end
  local BlueCircle = self.UIRoot.CurrentMapUIBP.BlueWidget
  if not BlueCircle then
    print(bWriteLog and "EntireMapWindow:PlayBlueCircleAnim Error")
    return
  end
  BlueCircle:PlayUserWidgetAnimation(BlueCircle.UIRoot.Anim_RingFX, 0, 0, 0, 1)
end
function EntireMapWindow:StopBlueCircleAnim()
  if not slua.isValid(self.UIRoot.CurrentMapUIBP) then
    return
  end
  local BlueCircle = self.UIRoot.CurrentMapUIBP.BlueWidget
  if not BlueCircle then
    return
  end
  BlueCircle.UIRoot:StopAnimation(BlueCircle.UIRoot.Anim_RingFX)
end
function EntireMapWindow:BindMiniMapPointerExceptionHandler()
  print(bWriteLog and "EntireMapWindow:BindMiniMapPointerExceptionHandler")
  local utility = require("common.utility")
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if uPlayerController and slua.isValid(uPlayerController) then
    local uMapUIMarkManager = uPlayerController:GetComponentByClass(import("/Script/ShadowTrackerExtra.MapUIMarkManager"))
    if slua.isValid(uMapUIMarkManager) then
      self:AddControlEventByControl(uMapUIMarkManager, "OnMiniMapPointerException", function()
        print(bWriteLog and "[Lua] OnMiniMapPointerException")
        local MiniMap = UIManager.GetUI(UIManager.UI_Config_InGame.MiniMapWindow)
        if MiniMap then
          local Widget = MiniMap.UIRoot
          if slua.isValid(Widget) and slua.isValid(Widget.CurrentMapUIBP) and slua.isValid(Widget.CurrentMapUIBP.CurrentMapUI) then
            uMapUIMarkManager.m_pMiniMap = Widget.CurrentMapUIBP.CurrentMapUI
            print(bWriteLog and "MiniMapUIWidget[Lua]: Reassign m_pMiniMap success")
          else
            print(bWriteLog and "MiniMapUIWidget[Lua]: Reassign m_pMiniMap fail")
          end
        end
      end)
    end
  end
end
function EntireMapWindow:OnPostInitialize()
  printf("EntireMapWindow:OnPostInitialize")
  EntireMapWindow.__super.OnPostInitialize(self)
  self:BindUIBase()
  self:SetGuideRedDotCollapsed()
  self:CheckShowJumpToMapModDetailUI()
  self.UIRoot.WidgetSwitcher_AutoLock:SetActiveWidgetIndex(1)
  self:CheckDisableInvalidationBoxes()
end
function EntireMapWindow:SetGuideRedDotCollapsed()
  local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
  self.EntireMapGuideRedDot = SettingModule:GetOptionValue("EntireMapGuideRedDot")
  if self.EntireMapGuideRedDot then
    self.UIRoot.Image_RedDot:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
  end
end
function EntireMapWindow:OnInitWidget()
  local MapManagerSubsystem = SubsystemMgr:Get("MapManagerSubsystem")
  if not MapManagerSubsystem then
    print(bWriteLog and "EntireMapWindow:OnInitWidget Failed Case Not MapManagerSubsystem")
    return
  end
  local MapUIPath = MapManagerSubsystem:GetMapUIPath(false)
  self.UIRoot.CurrentMapUIBP = CGame:NewObjectFromPath(MapUIPath, self.UIRoot)
  if not slua.isValid(self.UIRoot.CurrentMapUIBP) then
    print(bWriteLog and "EntireMapWindow:OnInitWidget Failed Case CurrentMapUIBP Is Not Valid")
    return
  end
  local MapDataPath = MapManagerSubsystem:GetMapDataPath(false)
  local MapData = CGame:NewObjectFromPath(MapDataPath, self.UIRoot)
  self.UIRoot.CurrentMapUIBP:HandleConstruct(self.UIRoot, MapData)
  self.UIRoot.CurrentMapUIBP:HandleReceiveInitWidget()
  self.UIRoot.MapUIBase = self.UIRoot.CurrentMapUIBP.CurrentMapUI
  self:AddControlEventByControl(self.UIRoot.CurrentMapUIBP.CurrentMapUI, "OnSliderValueChanged", self.OnSliderValueChanged, self)
end
function EntireMapWindow:OnUnRegistEvents()
  EntireMapWindow.__super.OnUnRegistEvents(self)
  self.delegateContainer = nil
end
function EntireMapWindow:OnShow()
  EntireMapWindow.__super.OnShow(self)
  local CurrentMapUIBP = self:GetEntireMapUIBP()
  if CurrentMapUIBP then
    CurrentMapUIBP:ShowEntiremap()
    CurrentMapUIBP.bIsShow = true
  end
  self:NotifyMapUIBaseEntireMapOpened(true)
  EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_ENTIRE_MAP_SHOW_STATE, true)
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if MainControlBaseUI then
    MainControlBaseUI.FakeOceanImage:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
  end
  if self:CheckShowGameGuideButton() then
    self:SelectGameGuide(false)
  end
  self.TLogHelperCache = {}
end
function EntireMapWindow:OnClose()
  print(bWriteLog and "EntireMapWindow:OnClose")
  EventSystem:postEvent(EVENTTYPE_INGAME_UI, EVENTID_REMOVE_FROM_FORCE_HIDE_UI_ARRAY, self.UIRoot.CanvasPanel_Root)
  EntireMapWindow.__super.OnClose(self)
  self:SelectGameGuide(false)
  if self.UIRoot.CurrentMapUIBP then
    self.UIRoot.CurrentMapUIBP:OnDestroy()
    self.UIRoot.CurrentMapUIBP = nil
  end
  local GameGuideUIUtil = require("GameLua.Mod.BaseMod.Client.Map.GameGuideUI.GameGuideUIUtil")
  UIManager.CloseUI(GameGuideUIUtil.GetGameGuideUIMainConfig())
end
function EntireMapWindow:OnHide()
  EntireMapWindow.__super.OnHide(self)
  EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_ENTIRE_MAP_SHOW_STATE, false)
  local CurrentMapUIBP = self:GetEntireMapUIBP()
  if CurrentMapUIBP then
    CurrentMapUIBP.bIsShow = false
    if CurrentMapUIBP.SaveReshowRouteSetting then
      CurrentMapUIBP:SaveReshowRouteSetting()
    end
  end
  self:NotifyMapUIBaseEntireMapOpened(false)
  self:SwitchShowMode(false)
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if MainControlBaseUI and MainControlBaseUI.FakeOceanImage then
    MainControlBaseUI.FakeOceanImage:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
  end
  self:SelectGameGuide(false)
end
function EntireMapWindow:GetEntireMapUIBP()
  if self.UIRoot then
    if not slua.isValid(self.UIRoot.CurrentMapUIBP) then
      self:OnInitWidget()
    end
    return self.UIRoot.CurrentMapUIBP
  end
end
function EntireMapWindow:GetEntireMapUI()
  local EntireMapUIBP = self:GetEntireMapUIBP()
  if EntireMapUIBP then
    return EntireMapUIBP.CurrentMapUI
  end
end
function EntireMapWindow:HandleClickSelfMark()
  local uPlayerState = GameplayData.GetPlayerState()
  if slua.isValid(uPlayerState) then
    uPlayerState:RPC_ServerAddGeneralCount(11503, 1, false)
  end
  local CurrentMapUIBP = self:GetEntireMapUIBP()
  if CurrentMapUIBP then
    CurrentMapUIBP:HandleClickSelfMark()
  end
  self:TLogOnceHelper(11535)
end
function EntireMapWindow:HandleLockBtnClick()
  local uPlayerState = GameplayData.GetPlayerState()
  if slua.isValid(uPlayerState) then
    uPlayerState:RPC_ServerAddGeneralCount(11504, 1, false)
  end
  self:TLogOnceHelper(11542)
  local CurrentMapUIBP = self:GetEntireMapUIBP()
  if CurrentMapUIBP then
    CurrentMapUIBP:HandleLockBtnClick()
  end
  if IsEditor and self.RefreshMapByGM then
    EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_CHANGE_MAP_TEXTURE, "", 1, "")
  end
end
function EntireMapWindow:HandleAutoLockBtnClick()
  local uPlayerState = GameplayData.GetPlayerState()
  if slua.isValid(uPlayerState) then
    uPlayerState:RPC_ServerAddGeneralCount(11545, 1, false)
  end
  local Switcher = self.UIRoot.WidgetSwitcher_AutoLock
  if not Switcher then
    return
  end
  local ActiveIndex = Switcher:GetActiveWidgetIndex()
  if ActiveIndex == 1 then
    GlobalUIFunctionLibrary:PlaySoundClickButton()
    Switcher:SetActiveWidgetIndex(0)
    return
  end
  Switcher:SetActiveWidgetIndex(1)
  local CurrentMapUIBP = self:GetEntireMapUIBP()
  if CurrentMapUIBP then
    CurrentMapUIBP:HandleAutoLockBtnClick()
  end
end
function EntireMapWindow:HandleClickDeleteMark()
  local CurrentMapUIBP = self:GetEntireMapUIBP()
  if CurrentMapUIBP then
    CurrentMapUIBP:HandleClickDeleteMark()
  end
  self:TLogOnceHelper(11536)
  EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_MARK_PARACHUTE_REFRESH)
end
function EntireMapWindow:HandleClickMultiMark()
  local CurrentMapUIBP = self:GetEntireMapUIBP()
  if CurrentMapUIBP then
    CurrentMapUIBP:HandleClickMultiMark()
  end
end
function EntireMapWindow:HandleClickClearMultiMark()
  self:PlayAudio(sound_config.click)
  local CurrentMapUIBP = self:GetEntireMapUIBP()
  if CurrentMapUIBP then
    CurrentMapUIBP:HandleClickClearMultiMark()
  end
end
function EntireMapWindow:HandleClickRevertMultiMark()
  local CurrentMapUIBP = self:GetEntireMapUIBP()
  if CurrentMapUIBP then
    CurrentMapUIBP:HandleClickRevertMultiMark()
  end
end
function EntireMapWindow:HandleClickHide()
  BatttleWindowMgr.HideUI("EntireMapWindow")
  local STExtraGameInstance = import("/Script/ShadowTrackerExtra.STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  GameInstance:ExecuteCMD("Slate.EnableUIDynamicBatch", 1)
end
function EntireMapWindow:HandleBtn0Pressed()
  local uPlayerController = self.UIRoot:GetOwningPlayer()
  if slua.isValid(uPlayerController) and uPlayerController.CharacterTouchMove ~= nil then
    uPlayerController.CharacterTouchMove = false
  else
    log(bWriteLog and "HandleBtn0Pressed error")
  end
end
function EntireMapWindow:HandleBtn0Realeased()
  local uPlayerController = self.UIRoot:GetOwningPlayer()
  if slua.isValid(uPlayerController) and uPlayerController.CharacterTouchMove ~= nil then
    uPlayerController.CharacterTouchMove = true
  else
    log(bWriteLog and "HandleBtn0Pressed error")
  end
end
function EntireMapWindow:HandleBtnZoomOut()
  local EntireMapUI = self:GetEntireMapUI()
  if not EntireMapUI then
    return
  end
  local CurrentScale = EntireMapUI.MapScalingRadio
  if CurrentScale <= 1 then
    return
  end
  CurrentScale = CurrentScale - 1
  CurrentScale = math.max(CurrentScale, 1)
  EntireMapUI.MapScalingRadio = CurrentScale
  local CurrentMapUIBP = self:GetEntireMapUIBP()
  if CurrentMapUIBP then
    local SliderValue = CurrentMapUIBP:CalSliderValue(EntireMapUI.MapScalingRadio)
    self.UIRoot.Slider_MapZoom:SetValue(SliderValue)
    CurrentMapUIBP:ResizeAndRedrawMap()
  end
  self:TLogOnceHelper(11538)
  EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_ENTIRE_MAP_TOUCH, true)
end
function EntireMapWindow:HandleBtnZoomIn()
  local CurrentMapUIBP = self:GetEntireMapUIBP()
  if CurrentMapUIBP then
    CurrentMapUIBP:HandleBtnZoomIn()
  end
  self:TLogOnceHelper(11538)
  EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_ENTIRE_MAP_TOUCH, true)
end
function EntireMapWindow:CreatePremiumResourceUIItem(UIConfig, Position, Radius)
end
function EntireMapWindow:ConvertWorldPosition2MapPosition(WorldPosition)
  return self.UIRoot.CurrentMapUIBP:ConvertWorldPosition2MapPosition(WorldPosition)
end
function EntireMapWindow:HandleSliderValueChanged(nValue)
  local EntireMapUI = self:GetEntireMapUI()
  local CurrentMapUIBP = self:GetEntireMapUIBP()
  if EntireMapUI and CurrentMapUIBP then
    local Rate = nValue * CurrentMapUIBP.MaxScaleValue + 1
    EntireMapUI.MapScalingRadio = CurrentMapUIBP:ClampMapScaleValue(Rate)
    self.FocusCenter = true
    EntireMapUI.bIsSliderValueChange = true
  end
  self:TLogOnceHelper(11539)
  EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_ENTIRE_MAP_TOUCH, true)
end
function EntireMapWindow:HandleMoveMap(uVector)
  local CurrentMapUIBP = self:GetEntireMapUIBP()
  if CurrentMapUIBP then
    CurrentMapUIBP:HandleMapMove(uVector)
  end
  self:TLogOnceHelper(11541)
  EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_ENTIRE_MAP_TOUCH, true)
end
function EntireMapWindow:HandleSetMarker(uVector)
  log(bWriteLog and "EntireMapWindow:HandleSetMarker")
  local CurrentMapUIBP = self:GetEntireMapUIBP()
  if CurrentMapUIBP then
    local Aligx, Aligy = CurrentMapUIBP:GetObjectAligInCurMapSize(uVector)
    CurrentMapUIBP:MakeMarker(FVector2D(Aligx, Aligy))
  end
  self:TLogOnceHelper(11534)
  if self.bPrepareForSingleMarkTLog then
    self.bPrepareForSingleMarkTLog = nil
    self:TLogOnceHelper(11533)
  end
  EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_ENTIRE_MAP_TOUCH, true)
end
function EntireMapWindow:HandleScaleMap(nScaleValue)
  local EntireMapUI = self:GetEntireMapUI()
  local CurrentMapUIBP = self:GetEntireMapUIBP()
  if EntireMapUI and CurrentMapUIBP then
    local Rate = nScaleValue + EntireMapUI.MapScalingRadio
    EntireMapUI.MapScalingRadio = CurrentMapUIBP:ClampMapScaleValue(Rate)
    local SliderValue = CurrentMapUIBP:CalSliderValue(EntireMapUI.MapScalingRadio)
    self.UIRoot.Slider_MapZoom:SetValue(SliderValue)
    self.FocusCenter = false
    EntireMapUI.bIsSliderValueChange = true
  end
  self:TLogOnceHelper(11540)
  EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_ENTIRE_MAP_TOUCH, true)
end
function EntireMapWindow:HandleClickEntireMap(nScaleValue)
  EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_ENTIRE_MAP_TOUCH, true)
end
function EntireMapWindow:OnEntireMapBlackboardTouch(_, _, Condition)
  if not Condition then
    return
  end
  local UIRoot = self.UIRoot
  if UIRoot and UIRoot.WidgetSwitcher_AutoLock then
    UIRoot.WidgetSwitcher_AutoLock:SetActiveWidgetIndex(0)
    local CurrentMapUIBP = self:GetEntireMapUIBP()
    if CurrentMapUIBP then
      CurrentMapUIBP.bAutoLock = false
    end
  end
end
function EntireMapWindow:OnSliderValueChanged()
  if self.FocusCenter == nil then
    self.FocusCenter = true
  end
  local CurrentMapUIBP = self:GetEntireMapUIBP()
  if CurrentMapUIBP then
    CurrentMapUIBP:HandleSliderValueChange(self.FocusCenter)
  end
end
function EntireMapWindow:HandleBtnReshowAirPlaneRoute(isCheck)
  local PlayerState = GameplayData.GetPlayerState()
  if slua.isValid(PlayerState) then
    PlayerState:RPC_ServerAddGeneralCount(11528, 1, false)
  end
  local CurrentMapUIBP = self:GetEntireMapUIBP()
  if CurrentMapUIBP then
    if isCheck then
      CurrentMapUIBP:ReShowAirplaneRoute(true)
    else
      CurrentMapUIBP:ReShowAirplaneRoute(false)
    end
    CurrentMapUIBP:OnClickReShowRouteBtn()
  end
  local MiniMap = UIManager.GetUI(UIManager.UI_Config_InGame.MiniMapWindow)
  if MiniMap and MiniMap.UIRoot and MiniMap.UIRoot.CurrentMapUIBP then
    MiniMap.UIRoot.CurrentMapUIBP:ReShowAirplaneRoute(isCheck)
  end
  self.UIRoot.CanvasPanel_ReshowRouteEffect:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function EntireMapWindow:ShowMapLegend()
  local MapLegendUI = UIManager.ShowUI(UIManager.UI_Config_InGame.EntireMapLegend)
  if MapLegendUI then
    local uAttachPanel = self.UIRoot:GetWidgetFromName("VerticalBox_Right")
    uAttachPanel:AddChild(MapLegendUI.UIRoot)
  end
end
function EntireMapWindow:NotifyMapUIBaseEntireMapOpened(bIsOpen)
  local CurrentMapUIBP = self:GetEntireMapUIBP()
  if CurrentMapUIBP then
    CurrentMapUIBP:OnEntireMapOpen(bIsOpen)
  end
  local MiniMap = UIManager.GetUI(UIManager.UI_Config_InGame.MiniMapWindow)
  if MiniMap then
    local Widget = MiniMap.UIRoot
    if slua.isValid(Widget) and slua.isValid(Widget.CurrentMapUIBP) then
      Widget.CurrentMapUIBP:OnEntireMapOpen(bIsOpen)
    end
  end
end
function EntireMapWindow:OnHideReshowBtn()
  self.UIRoot.CheckBox_ReshowRoute:SetCheckedState(0)
  local CurrentMapUIBP = self:GetEntireMapUIBP()
  if CurrentMapUIBP then
    CurrentMapUIBP.CurrentMapUI.bIsShowAirPlaneRouteAfteHide = false
  end
end
function EntireMapWindow:SwitchShowMode(bIsSpecialMode)
  local Visibility = UEnums.ESlateVisibility.SelfHitTestInvisible
  if bIsSpecialMode then
    Visibility = UEnums.ESlateVisibility.Collapsed
  end
  local UIRoot = self.UIRoot
  UIRoot.SimpleModeHideCanvas:SetWidgetVisibility(Visibility)
  UIRoot.CanvasPanel_ScaleButton:SetWidgetVisibility(Visibility)
end
function EntireMapWindow:OnClickMultiMark(_, _, bIsDrawMultiGuideLine)
  local HoldEntireMapWidget = self.UIRoot
  if not HoldEntireMapWidget then
    print(bWriteLog and "EntireMapWindow:OnClickMultiMark self.UIRoot is nil")
  end
  if bIsDrawMultiGuideLine then
    HoldEntireMapWidget.WidgetSwitcher_MapMark:SetActiveWidgetIndex(0)
    HoldEntireMapWidget.Button_SelfMark:SetWidgetVisibility(ESlateVisibility.Visible)
    HoldEntireMapWidget.Button_DelMarkIcon:SetWidgetVisibility(ESlateVisibility.Visible)
    HoldEntireMapWidget:StopAnimation(HoldEntireMapWidget.DX_Button_In)
    local Text = LocUtil.GetLocalizeResStr(24382)
  else
    HoldEntireMapWidget.WidgetSwitcher_MapMark:SetActiveWidgetIndex(1)
    HoldEntireMapWidget.Button_SelfMark:SetWidgetVisibility(ESlateVisibility.Collapsed)
    HoldEntireMapWidget.Button_DelMarkIcon:SetWidgetVisibility(ESlateVisibility.Collapsed)
    HoldEntireMapWidget:StopAnimation(HoldEntireMapWidget.DX_Button_Out)
    local Text = LocUtil.GetLocalizeResStr(24383)
  end
end
function EntireMapWindow:OnInitMultiMarkButton(_, _, bIsVisible)
  if bIsVisible then
    self.UIRoot.Button_MultiMark:SetWidgetVisibility(ESlateVisibility.Visible)
  else
    self.UIRoot.Button_MultiMark:SetWidgetVisibility(ESlateVisibility.Collapsed)
  end
end
function EntireMapWindow:OnChangeEntireMapSize(_, _, Size)
  local HoldEntireMapWidget = self.UIRoot
  if not HoldEntireMapWidget then
    print(bWriteLog and "EntireMapWindow:OnChangeEntireMapSize self.UIRoot is nil")
  end
  local Slot = HoldEntireMapWidget.EntireMapImage.Slot
  Slot:SetSize(Size)
  Slot = HoldEntireMapWidget.MapCircleAndLineBlackboard.Slot
  Slot:SetSize(Size)
  Slot = HoldEntireMapWidget.CanvasPanel_MapImageSize.Slot
  Slot:SetSize(Size)
  Slot = HoldEntireMapWidget.CommonFunctionAddPanel.Slot
  Slot:SetSize(Size)
  Slot = HoldEntireMapWidget.CanvasPanel_ClipMaskBox.Slot
  Slot:SetSize(Size)
  Slot = HoldEntireMapWidget.DynamicMarkPanel.Slot
  Slot:SetSize(Size)
end
function EntireMapWindow:OnMapMultiGuideLine(_, _, bInDrawMultiGuideLine)
  local HoldEntireMapWidget = self.UIRoot
  if bInDrawMultiGuideLine then
    HoldEntireMapWidget.Button_SelfMark:SetWidgetVisibility(ESlateVisibility.Visible)
    HoldEntireMapWidget.Button_DelMarkIcon:SetWidgetVisibility(ESlateVisibility.Visible)
    local Text = LocUtil.GetLocalizeResStr(24382)
  else
    HoldEntireMapWidget.Button_SelfMark:SetWidgetVisibility(ESlateVisibility.Collapsed)
    HoldEntireMapWidget.Button_DelMarkIcon:SetWidgetVisibility(ESlateVisibility.Collapsed)
    local Text = LocUtil.GetLocalizeResStr(24383)
  end
end
function EntireMapWindow:TLogOnceHelper(TLogID)
  local PlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(PlayerState) then
    return
  end
  if not self.TLogHelperCache[TLogID] then
    PlayerState:RPC_ServerAddGeneralCount(TLogID, 1, false)
    self.TLogHelperCache[TLogID] = true
  end
end
function EntireMapWindow:CheckDisableInvalidationBoxes()
  if HDmpveRemote.HDmpveRemoteConfigGetBool("DisableInvalidationBox", false) == true then
    log_shipping_client("EntireMapWindow:CheckDisableInvalidationBoxes Disable Invalidation Boxes")
    if self.UIRoot.InvalidationBox_PlayerAddPanel then
      self.UIRoot.InvalidationBox_PlayerAddPanel:SetCanCache(false)
    end
  end
end
local class = require("class")
local ui_base = require("GameLua.Mod.BaseMod.Client.Map.MapWindow.MapUIWidgetBase")
local CEntireMapWindow = class(ui_base, nil, EntireMapWindow)
return CEntireMapWindow