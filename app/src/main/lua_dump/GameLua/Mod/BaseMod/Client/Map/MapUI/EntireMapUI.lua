local EntireMapUI = {}
local slua_isValid = slua.isValid
local ESlateVisibility = UEnums.ESlateVisibility
local StringUtil = require("common.string_util")
local audio_util = require("client.common.audio_util")
local KismetMathLibrary = import("/Script/Engine.KismetMathLibrary")
local GameBackendHUD = import("/Script/Client.GameBackendHUD")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local GlobalUIFunctionLibrary = require("client.slua.umg.ui_utility.global_ui_function_library")
local STExtraMapFunctionLibrary = import("/Script/ShadowTrackerExtra.STExtraMapFunctionLibrary")
local MapMarkCD = 10
local LastTeamMarkTime
local MapMarkAudioPath = "/Game/WwiseEvent/UI/UI_440/Play_UI_MiniMap_Mark.Play_UI_MiniMap_Mark"
function EntireMapUI:ctor()
  print(bWriteLog and "EntireMapUI:ctor")
  EntireMapUI.__super.ctor(self)
  self.bAutoLock = true
end
function EntireMapUI:OnDestroy()
  if slua.isValid(self.CurrentMapData_BP) then
    self.CurrentMapData_BP:OnDestroy()
  end
  self:SaveHightLightTimes()
  self:SaveReshowRouteSetting()
  self:ClearWidgets()
  self.HoldWidget = nil
  self.HoldEntireMapWidget = nil
  self.STExtraPlayerController = nil
  self:UnRegistBPEvents()
  self:Dispose()
end
function EntireMapUI:HandleClickClearMultiMark()
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return
  end
  if uPlayerController:IsFriendOrEnemySpectator() == false then
    uPlayerController:SetPlayerMapMultiMark(FVector(0, 0, 0), false, self.MultiMarkMaxNum, true)
    local uPlayerState = uPlayerController:GetCurPlayerState()
    if not slua.isValid(uPlayerState) then
      return
    end
    uPlayerState:SetPlayerMapMultiMark(FVector(0, 0, 0), false, self.MultiMarkMaxNum, true)
    EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_REPOSITION_SELF_MULTI_MARK)
  end
end
function EntireMapUI:ConvertWorldPosition2MapPosition(WorldPosition)
  local MapPosition = self.CurrentMapUI:Calculate3dTo2dPosition(WorldPosition)
  return MapPosition
end
function EntireMapUI:SetReshowAirplaneRouteBtnVisibility(bIsShow)
  print(bWriteLog and "EntireMapUI:SetReshowAirplaneRouteBtnVisibility - bIsShow", tostring(bIsShow))
  if not slua.isValid(self.CurrentMapUI.CanvasPanel_ShowAirPlaneRoute) or not self.HoldWidget then
    return
  end
  if bIsShow then
    self.CurrentMapUI.CanvasPanel_ShowAirPlaneRoute:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
    if self.bHasClickReshowRoute then
      self.HoldWidget.CanvasPanel_ReshowRouteEffect:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      return
    end
    local bIsOpen = true
    local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
    if SettingSubsystem then
      bIsOpen = SettingSubsystem:GetUserSettings_Bool("ReshowAirlineRouteBtnChecked")
    end
    if bIsOpen then
      self.HoldWidget.CheckBox_ReshowRoute:SetCheckedState(1)
      self:ReShowAirplaneRoute(true)
      self.HoldWidget.CanvasPanel_ReshowRouteEffect:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    else
      self.HoldWidget.CheckBox_ReshowRoute:SetCheckedState(0)
    end
    self:OnAirlineRouteShow()
    local MapIconSubsystem = SubsystemMgr:Get("MapIconSubsystem")
    if MapIconSubsystem and not MapIconSubsystem.bBaltic then
      EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_SHOW_AIRPLANE_ROUTE, false)
      self.CurrentMapUI.CanvasPanel_ShowAirPlaneRoute:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    end
  else
    self.CurrentMapUI.CanvasPanel_ShowAirPlaneRoute:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    local PlayerState = GameplayData.GetPlayerState()
    if slua.isValid(PlayerState) and PlayerState.RPC_ServerAddGeneralCount then
      PlayerState:RPC_ServerAddGeneralCount(11529, 1, true)
    end
  end
  self.bShowAirplaneRoute = bIsShow
end
function EntireMapUI:OnAirlineRouteShow()
  print(bWriteLog and "EntireMapUI:OnAirlineRouteShow")
  EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_SHOW_AIRPLANE_ROUTE, true)
  local bShowMapLegend = false
  local MapLegendUI = UIManager.GetUI(UIManager.UI_Config_InGame.EntireMapLegend)
  if MapLegendUI and not MapLegendUI.bIsHide then
    bShowMapLegend = true
  end
  if bShowMapLegend then
    local AirPlaneRouteCanvas = self.HoldEntireMapWidget.CanvasPanel_ReshowRoute
    if AirPlaneRouteCanvas and AirPlaneRouteCanvas.Slot then
      AirPlaneRouteCanvas.Slot:SetPosition(FVector2D(180, -69.5))
    else
      print(bWriteLog and "EntireMapUI:OnAirlineRouteShow - AirPlaneRouteCanvas or AirPlaneRouteCanvas.Slot is nil")
    end
  end
end
function EntireMapUI:OnClickReShowRouteBtn()
  self.bHasClickReshowRoute = true
end
function EntireMapUI:SaveReshowRouteSetting()
  if not self.bHasClickReshowRoute then
    return
  end
  local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
  if not SettingSubsystem or not self.HoldWidget then
    return
  end
  local SettingValue = SettingSubsystem:GetUserSettings_Bool("ReshowAirlineRouteBtnChecked")
  local bIsReshowBtnChecked = self.HoldWidget.CheckBox_ReshowRoute:GetCheckedState() == 1
  if SettingValue == nil or SettingValue ~= bIsReshowBtnChecked then
    print(bWriteLog and "EntireMapUI:SaveReshowRouteSetting : " .. tostring(bIsReshowBtnChecked))
    SettingSubsystem:SetUserSettings_Bool("ReshowAirlineRouteBtnChecked", bIsReshowBtnChecked)
  end
  self.bHasClickReshowRoute = false
end
function EntireMapUI:SetReshowRouteEffectVisibility()
  if not self.HoldEntireMapWidget then
    return
  end
  if not self.HightLightReshowAirLineTimes then
    local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
    if SettingSubsystem then
      self.HightLightReshowAirLineTimes = SettingSubsystem:GetUserSettings_Int("HightLightReshowAirLineTimes")
    end
  end
  if self.HightLightReshowAirLineTimes > 3 then
    self.HoldEntireMapWidget.CanvasPanel_ReshowRouteEffect:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    return
  end
  if self.HoldEntireMapWidget.CanvasPanel_ReshowRoute:GetVisibility() ~= UEnums.GSlateVisibility.SelfHitTestInvisible then
    self.HoldEntireMapWidget.CanvasPanel_ReshowRouteEffect:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    return
  end
  self.HoldEntireMapWidget.CanvasPanel_ReshowRouteEffect:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
  self.HightLightReshowAirLineTimes = self.HightLightReshowAirLineTimes + 1
end
function EntireMapUI:SaveHightLightTimes()
  if not self.HightLightReshowAirLineTimes then
    return
  end
  local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
  if SettingSubsystem then
    SettingSubsystem:SetUserSettings_Int("HightLightReshowAirLineTimes", self.HightLightReshowAirLineTimes)
  end
end
function EntireMapUI:InitMapStandardPoint()
  EntireMapUI.__super.InitMapStandardPoint(self)
  self:SelfInitMapStandardPoint()
end
function EntireMapUI:HandleConstruct(Widget, MapDataBase)
  self.CurrentMapUI = CGame:NewObjectFromPath("/Script/ShadowTrackerExtra.EntireMapUI", self)
  self.CurrentMapUI.InnerCircleGameModeID = self.InnerCircleGameModeID
  self.bIsMiniMap = false
  self.HoldEntireMap  self:SetWidget()
  EntireMapUI.__super.HandleConstruct(self, Widget, MapDataBase)
  if slua_isValid(self.CurrentMapUI) then
    self:AddControlEvent(self.CurrentMapUI, "OnSetupUIMarkRoot", self.OnSetupUIMarkRoot, self)
    self:AddControlEvent(self.CurrentMapUI, "OnUpdateMarkerDistanceC", self.UpdateMarkerDistance, self)
  end
end
function EntireMapUI:HandleReceiveInitWidget()
  EntireMapUI.__super.HandleReceiveInitWidget(self)
  self:SelfHandleReceivedWidget()
end
function EntireMapUI:RegistEvents()
  EntireMapUI.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_HIDE_ALL_UI, self.HandleHideAllUI, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_DEATH_MATCH_UI_SETTING, self.HandleReceiveDeathMatchUISetting, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_GAMEPLAY_SYNC_PLAYERSTATE, self.HandleGamePlaySyncPlayerState, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_MODIFY_MULTITOCH_SCALE_RADIO, self.HandleModifyMultitouchScaleRadio, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_MAP_HANDLE_RESIZE, self.HandleMapResize, self)
end
function EntireMapUI:RegisterDelegate()
  EntireMapUI.__super.RegisterDelegate(self)
  self:SelfRegisterDelegate()
end
function EntireMapUI:HandleInitPlayerState()
  EntireMapUI.__super.HandleInitPlayerState(self)
  self:SelfHandleInitPlayerState()
end
function EntireMapUI:OnSetupUIMarkRoot()
  local CurrentMapUI = self.CurrentMapUI
  local HoldEntireMapWidget = self.HoldEntireMapWidget
  CurrentMapUI.m_pMarkRoot = HoldEntireMapWidget.PlayerAddPanel
  CurrentMapUI.CustomTagMarkRootMap:Add(HoldEntireMapWidget.CanvasPanel_MarkRoot1)
  CurrentMapUI.CustomTagMarkRootMap:Add(HoldEntireMapWidget.CanvasPanel_MarkRoot2)
  CurrentMapUI.DynamaicCustomPanelMap:Add("DynamicMark", HoldEntireMapWidget.DynamicMarkPanel)
end
function EntireMapUI:OnCharacterStateChange(OwnerCharacter, LiveState)
  print(bWriteLog and "EntireMapUI:OnCharacterStateChange")
  EntireMapUI.__super.OnCharacterStateChange(self, OwnerCharacter, LiveState)
  self:SelfOnCharacterStateChange(OwnerCharacter, LiveState)
end
function EntireMapUI:OnSpectatorChanged()
  EntireMapUI.__super.OnSpectatorChanged(self)
  self:HandleInitPlayerState()
  local ExtraPlayerLiveState = import("ExtraPlayerLiveState")
  self:OnCharacterStateChange(nil, ExtraPlayerLiveState.InDefault)
end
function EntireMapUI:UpdateMarkerDistance()
  self:ShowMarkerDistance()
end
function EntireMapUI:HandleOnPlayerEnterFlying()
  self:RepositionAllMapMark(0)
end
function EntireMapUI:InitMapTextureCallBack()
  self:InitMapStandardPoint()
  EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_MAP_IMMEDIATE_REFRESH, self.bIsMiniMap, self.CurTag)
  self:AddTimer(0, function()
    EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_MAP_AIRLINE_ROUTE_UPDATE)
    EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_MAP_HANDLE_RESIZE)
    EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_AFTER_CHANGE_MAP_TEXTURE)
  end)
end
function EntireMapUI:ShowHideMarkMarkTagCanvas(Tag, bIsVisible)
  local CustomTagMarkRootMap = self.CurrentMapUI.CustomTagMarkRootMap
  if Tag < CustomTagMarkRootMap:Num() and slua_isValid(CustomTagMarkRootMap:Get(Tag)) then
    local Canvas = CustomTagMarkRootMap:Get(Tag)
    if bIsVisible then
      Canvas:SetWidgetVisibility(ESlateVisibility.Collapsed)
    else
      Canvas:SetWidgetVisibility(ESlateVisibility.HitTestInvisible)
    end
  end
end
function EntireMapUI:HandleResetUIStateAfterRespawn()
  self:HandleInitPlayerState()
end
function EntireMapUI:HandleLockBtnClick()
  GlobalUIFunctionLibrary:PlaySoundClickButton()
  local PlayerInfoArray = self.CurrentMapData_BP:GetPlayerInfoBPArray()
  local Index = self.CurrentMapUI.LocalPlayerIndexC
  if not PlayerInfoArray or PlayerInfoArray:Num() <= 0 or Index < 0 or Index >= PlayerInfoArray:Num() then
    print(bWriteLog and string.format("EntireMapUI:HandleLockBtnClick - Index out of range: Index=%d, ArrayNum=%d", Index, PlayerInfoArray:Num()))
    return
  end
  local PlayerInfo = PlayerInfoArray:Get(Index)
  local GameFunctionLibrary = import("/Game/BluePrints/Core/BP_GameFunctionLibrary.BP_GameFunctionLibrary_C")
  if GameFunctionLibrary.IsPlayerCanSeeWidget(PlayerInfo) then
    self:MovePointOnMapToCenter(PlayerInfo.RenderTransform.Translation)
  end
end
function EntireMapUI:HandleAutoLockBtnClick()
  print(bWriteLog and "EntireMapUI:HandleAutoLockBtnClick")
  local bOperateSuccess = self:AutoLockScaleMap()
  if not bOperateSuccess then
    self.HoldEntireMapWidget.WidgetSwitcher_AutoLock:SetActiveWidgetIndex(1)
    self.bAutoLock = false
    return
  end
  self.bAutoLock = true
  if self.AutoLockMoveMapTimer then
    print(bWriteLog and "EntireMapUI:HandleAutoLockBtnClick - Already set self.AutoLockMoveMapTimer")
    return
  end
  self.AutoLockMoveMapTimer = self:AddGameTimer(0.01, false, function()
    self.AutoLockMoveMapTimer = nil
    local bOperateSuccess = self:AutoLockMoveMap()
    if not bOperateSuccess then
      self.HoldEntireMapWidget.WidgetSwitcher_AutoLock:SetActiveWidgetIndex(1)
      self.bAutoLock = false
      return
    end
    self.bAutoLock = true
    GlobalUIFunctionLibrary:PlaySoundClickButton()
  end)
end
function EntireMapUI:AutoLockScaleMap()
  print(bWriteLog and "EntireMapUI:AutoLockScaleMap")
  local PlayersTranslation = {}
  local PlayerInfoArray = self.CurrentMapData_BP:GetPlayerInfoBPArray()
  for _, PlayerInfo in pairs(PlayerInfoArray) do
    PlayersTranslation[#PlayersTranslation + 1] = PlayerInfo.RenderTransform.Translation
  end
  local CenterCoord, SideLength = self:CalcAABB(PlayersTranslation)
  if CenterCoord == nil or SideLength == nil then
    print(bWriteLog and "EntireMapUI:AutoLockScaleMap - Failed to auto lock")
    self:ScaleToDefaultMap()
    return false
  end
  local Slot = self.HoldEntireMapWidget.MapCircleAndLineBlackboard.Slot
  local MapSize = Slot:GetSize()
  SideLength = SideLength * (1 + MapSize.X / self.MapInitSize.X / 20)
  self.bSelfCenterZoom = false
  local ScaleRadio = 1 / (SideLength / MapSize.X)
  ScaleRadio = self:ClampMapScaleValue(ScaleRadio)
  self.CurrentMapUI.MapScalingRadio = ScaleRadio
  local SliderValue = self:CalSliderValue(ScaleRadio)
  self.HoldEntireMapWidget.Slider_MapZoom:SetValue(SliderValue)
  local EntireMap = UIManager.GetUI(UIManager.UI_Config_InGame.EntireMapWindow)
  if EntireMap then
    EntireMap.FocusCenter = false
  end
  self.CurrentMapUI.bIsSliderValueChange = true
  return true
end
function EntireMapUI:AutoLockMoveMap()
  print(bWriteLog and "EntireMapUI:AutoLockMoveMap")
  local PlayersTranslation = {}
  local PlayerInfoArray = self.CurrentMapData_BP:GetPlayerInfoBPArray()
  for _, PlayerInfo in pairs(PlayerInfoArray) do
    PlayersTranslation[#PlayersTranslation + 1] = PlayerInfo.RenderTransform.Translation
  end
  local CenterCoord, SideLength = self:CalcAABB(PlayersTranslation)
  if CenterCoord == nil or SideLength == nil then
    print(bWriteLog and "EntireMapUI:AutoLockMoveMap - Failed to auto lock")
    self:ScaleToDefaultMap()
    return false
  end
  self:MovePointOnMapToCenter(CenterCoord)
  self.bSelfCenterZoom = true
  local EntireMap = UIManager.GetUI(UIManager.UI_Config_InGame.EntireMapWindow)
  if EntireMap then
    EntireMap.FocusCenter = true
  end
  return true
end
function EntireMapUI:ScaleToDefaultMap()
  local ScaleRadio = 0
  self.bSelfCenterZoom = true
  ScaleRadio = self:ClampMapScaleValue(ScaleRadio)
  self.CurrentMapUI.MapScalingRadio = ScaleRadio
  self.CurrentMapUI.bIsSliderValueChange = true
  local SliderValue = self:CalSliderValue(ScaleRadio)
  self.HoldEntireMapWidget.Slider_MapZoom:SetValue(SliderValue)
end
function EntireMapUI:CalcAABB(PlayersTranslation)
  local RealTimeInfo = slua.IndexReference(self.CurrentMapUI, "MapRealTimeInfoC")
  local BlueCircleCoord, BlueCircleRadius
  if RealTimeInfo then
    BlueCircleCoord = RealTimeInfo.BlueCircleCoord
    BlueCircleRadius = RealTimeInfo.BlueCircleRadius
  end
  if RealTimeInfo == nil or BlueCircleRadius == nil or BlueCircleRadius == 0 then
    print(bWriteLog and "EntireMapUI:CalcAABB - One player click auto lock button in ready state")
    return nil, nil
  end
  local XMax = math.mininteger
  local YMax = math.mininteger
  local XMin = math.maxinteger
  local YMin = math.maxinteger
  for _, Translation in ipairs(PlayersTranslation) do
    XMax = math.max(Translation.X, XMax)
    YMax = math.max(Translation.Y, YMax)
    XMin = math.min(Translation.X, XMin)
    YMin = math.min(Translation.Y, YMin)
  end
  local BlueCircleCoordX = BlueCircleCoord.X
  local BlueCircleCoordY = BlueCircleCoord.Y
  XMax = math.max(BlueCircleCoordX + BlueCircleRadius, XMax)
  YMax = math.max(BlueCircleCoordY + BlueCircleRadius, YMax)
  XMin = math.min(BlueCircleCoordX - BlueCircleRadius, XMin)
  YMin = math.min(BlueCircleCoordY - BlueCircleRadius, YMin)
  local Slot = self.HoldEntireMapWidget.MapCircleAndLineBlackboard.Slot
  local MapSize = Slot:GetSize()
  local MapSizeHalfLength = MapSize.X / 2
  XMax = FuncUtil.Clamp(XMax, -MapSizeHalfLength, MapSizeHalfLength)
  YMax = FuncUtil.Clamp(YMax, -MapSizeHalfLength, MapSizeHalfLength)
  XMin = FuncUtil.Clamp(XMin, -MapSizeHalfLength, MapSizeHalfLength)
  YMin = FuncUtil.Clamp(YMin, -MapSizeHalfLength, MapSizeHalfLength)
  local MaxCoord = FVector2D(XMax, YMax)
  local MinCoord = FVector2D(XMin, YMin)
  local XSideLength = XMax - XMin
  local YSideLength = YMax - YMin
  local SideLength = math.max(XSideLength, YSideLength)
  local CenterCoord = FVector2D((XMax + XMin) / 2, (YMax + YMin) / 2)
  print(bWriteLog and string.format("EntireMapUI:CalcAABB - CenterCoord (%s, %s), SideLength %s", tostring(CenterCoord.X), tostring(CenterCoord.Y), tostring(SideLength)))
  return CenterCoord, SideLength
end
function EntireMapUI:HandleClickDeleteMark()
  GlobalUIFunctionLibrary:PlaySoundClickButton()
  local PlayerController = GameplayData.GetPlayerController()
  if slua_isValid(PlayerController) and not PlayerController:IsFriendOrEnemySpectator() then
    local Location = FVector(0, 0, -1)
    PlayerController:SetPlayerMark(Location)
    local PlayerState = GameplayData.GetPlayerState()
    if slua_isValid(PlayerState) and PlayerState.FadeTeammatesMapMark then
      PlayerState.MapMark = Location
      PlayerState:FadeTeammatesMapMark()
    end
    EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_DELETE_SELF_MAP_MAKER)
    if not PlayerController:IsSpectator() then
      self:RepositionSelfMarker()
    end
    PlayerController.OnShowHideSelfMarkDelegate:BroadCast()
  end
end
function EntireMapUI:HandleClickMultiMark()
  local audio_util = require("client.common.audio_util")
  audio_util.PlayAudioAsyncAtLocation("/Game/WwiseEvent/UI/Play_UI_Click.Play_UI_Click", FVector(0, 0, 0), FRotator(0, 0, 0))
  EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_CLICK_MULTI_MARK, self.bIsDrawMultiGuideLine)
  if not self.bIsDrawMultiGuideLine then
    local EntireMapUIWidget = UIManager.GetUI(UIManager.UI_Config_InGame.EntireMapWindow)
    if EntireMapUIWidget then
      EntireMapUIWidget.bPrepareForSingleMarkTLog = true
    end
  end
  self.bIsDrawMultiGuideLine = not self.bIsDrawMultiGuideLine
end
function EntireMapUI:HandleClickRevertMultiMark()
  GlobalUIFunctionLibrary:PlaySoundClickButton()
  local PlayerController = GameplayData.GetPlayerController()
  if slua_isValid(PlayerController) and not PlayerController:IsFriendOrEnemySpectator() then
    local Location = FVector(0, 0, 0)
    PlayerController:SetPlayerMapMultiMark(Location, false, self.MultiMarkMaxNum, false)
    local PlayerState = GameplayData.GetPlayerState()
    if slua_isValid(PlayerState) then
      PlayerState:SetPlayerMapMultiMark(Location, false, self.MultiMarkMaxNum, false)
    end
    EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_REPOSITION_SELF_MULTI_MARK)
  end
end
function EntireMapUI:HandleBtnZoomIn()
  local CurrentMapUI = self.CurrentMapUI
  if CurrentMapUI.MapScalingRadio < self.MaxScaleValue + 1.0 then
    local MapScalingRadio = self:ClampMapScaleValue(CurrentMapUI.MapScalingRadio + 1.0)
    CurrentMapUI.    self.HoldEntireMapWidget.Slider_MapZoom:SetValue(self:CalSliderValue(MapScalingRadio))
    self.MapCurSize = self.MapInitSize * CurrentMapUI.MapScalingRadio
    self:ChangeMapSize(self.MapCurSize, true, false)
    local MinAlign, MaxAlign = self:GetMapMaxAligByMapSize(self.MapCurSize)
    self:ClampAlig(MaxAlign, MinAlign)
    CurrentMapUI.CorrectLevelToMapScaleC = CurrentMapUI.MapScalingRadio * CurrentMapUI.LevelToMapScaleC
    self:RepositionMarkerAndPin()
    CurrentMapUI.bMapDynamicScaleDirty = true
    self:DispatchMapResizeEvent()
  end
end
function EntireMapUI:HandleBtnZoomOut()
  local CurrentMapUI = self.CurrentMapUI
  if CurrentMapUI.MapScalingRadio > 1.0 then
    CurrentMapUI.MapScalingRadio = self:ClampMapScaleValue(CurrentMapUI.MapScalingRadio - 1.0)
    self.HoldEntireMapWidget.Slider_MapZoom:SetValue(self:CalSliderValue(CurrentMapUI.MapScalingRadio))
    self:ResizeAndRedrawMap()
  end
end
function EntireMapUI:HandleSliderValueChange(SelfCenter)
  local CurrentMapUI = self.CurrentMapUI
  local MapScale = math.abs(CurrentMapUI.CorrectLevelToMapScaleC / CurrentMapUI.LevelToMapScaleC - CurrentMapUI.MapScalingRadio)
  if 0.03 < MapScale then
    self.MapCurSize = self.MapInitSize * CurrentMapUI.MapScalingRadio
    self:ChangeMapSize(self.MapCurSize, true, false)
    local MinAlign, MaxAlign = self:GetMapMaxAligByMapSize(self.MapCurSize)
    self:ClampAlig(MaxAlign, MinAlign)
    CurrentMapUI.CorrectLevelToMapScaleC = CurrentMapUI.MapScalingRadio * CurrentMapUI.LevelToMapScaleC
    self:RepositionMarkerAndPin()
    if SelfCenter then
      self:TryActiveSelfCenterZoom()
    else
      self.bSelfCenterZoom = false
    end
    CurrentMapUI.bMapDynamicScaleDirty = true
    self:DispatchMapResizeEvent()
  end
end
function EntireMapUI:HandlePlayerControllerRespawned(PlayerController)
end
function EntireMapUI:HandleOnTeamMateChange()
  self:HandleInitPlayerState()
  self:ResetLocalPlayerIndex(false)
  if not self.bIsInfectMode then
    local Abs = math.abs
    self.CurrentMapData_BP:HideAllMapMark()
    local LocalPlayerMarkerAlign = self.LocalPlayerMarkerAlig
    if Abs(LocalPlayerMarkerAlign.X) > 1.0E-4 or 1.0E-4 < Abs(LocalPlayerMarkerAlign.Y) then
      self:MakeMarker(LocalPlayerMarkerAlign)
    end
    self:RepositionMarkerAndPin()
  end
end
function EntireMapUI:HandleHideAllUI()
  if slua_isValid(self.HoldEntireMapWidget) then
    BatttleWindowMgr.HideUI("EntireMapWindow")
  end
end
function EntireMapUI:HandleReceiveDeathMatchUISetting()
  print(bWriteLog and "EntireMapUI:HandleReceiveDeathMatchUISetting")
  self.CurrentMapData_BP:SwitchAllAliveDeadIcon()
  self:HandleReceiveInitWidget()
  self:HandleInitPlayerState()
  self:HideAllMark()
  self:RepositionAllMapMark(0)
end
function EntireMapUI:HandleGamePlaySyncPlayerState()
  self:HideAllMark()
  self:HandleReceiveInitWidget()
  self:HandleInitPlayerState()
  self:RepositionAllMapMark(0)
end
function EntireMapUI:HandleModifyMultitouchScaleRadio(_, _, Radio)
  self.HoldEntireMapWidget.MapCircleAndLineBlackboard.MultiTouchScaleRatio = Radio
end
function EntireMapUI:HandleMapResize()
  self:OnChangeMapSize(false)
end
function EntireMapUI:SelfInitMapStandardPoint()
  local CurrentMapUI = self.CurrentMapUI
  CurrentMapUI.LevelToMapScaleC = self.MapInitSize.X / self.LevelLandScapeExtent
  CurrentMapUI.MapWindowExtentC = self.MapCurSize.X
  CurrentMapUI.MapImageExtentC = CurrentMapUI.MapWindowExtentC
  CurrentMapUI.CorrectLevelToMapScaleC = CurrentMapUI.MapScalingRadio * CurrentMapUI.LevelToMapScaleC
  local MapSys = require("GameLua.Mod.BaseMod.Client.Map.IngameMapSys")
  CurrentMapUI.GuideLineColor = MapSys:GetPlayerColorByIndexC(CurrentMapUI.LocalPlayerIndexC)
end
function EntireMapUI:SelfHandleInitPlayerState()
  self:InitPlayers()
  self:InitPlayerState(false)
  self:SetTeamMateNameInMap()
end
function EntireMapUI:SelfHandleReceivedWidget()
  self:SetAdaptation()
  self:InitMapTexture()
  self:InitMapStandardPoint()
  self:HideFakeEdge()
  self.CurrentMapData_BP:HandleReceiveInitWidget(self.HoldEntireMapWidget.PlayerAddPanel)
  self:InitMultiMarkButton()
end
function EntireMapUI:SelfRegisterDelegate()
  GameplayData.AddSelfPlayerControllerEvent(self, "PlayerControllerRespawnedDelegate", self.HandlePlayerControllerRespawned, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnRepTeammateChange", self.HandleOnTeamMateChange, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnRepPlayerState", self.HandleInitPlayerState, self)
end
function EntireMapUI:SelfOnCharacterStateChange(OwnerCharacter, LiveState)
  local PlayerState = GameplayData.GetPlayerState()
  if slua_isValid(PlayerState) and PlayerState.GetTeamMatePlayerStateList then
    local TeamMatePlayerState = PlayerState:GetTeamMatePlayerStateList({}, false)
    for Index, TeamMateState in pairs(TeamMatePlayerState) do
      if slua_isValid(TeamMateState) then
        self.CurrentMapData_BP:UpdateVeteranStatus(Index, TeamMateState:GetMentorPlayerType(), TeamMateState:GetVeteranPlayerLevel())
        self.CurrentMapData_BP:SwitchAliveDeadIcon(Index, TeamMateState.LiveState)
      else
        print("Invalid Index:", Index)
      end
    end
  end
end
function EntireMapUI:HandleClickSelfMark()
  GlobalUIFunctionLibrary:PlaySoundClickButton()
  local PlayerController = GameplayData.GetPlayerController()
  if slua_isValid(PlayerController) and not PlayerController:IsFriendOrEnemySpectator() then
    local PlayerInfoArray = self.CurrentMapData_BP:GetPlayerInfoBPArray()
    local Position = self.MapCurSize / 2.0
    local PlayerIndex = self.CurrentMapUI.LocalPlayerIndexC
    if PlayerIndex < 0 or PlayerIndex >= PlayerInfoArray:Num() then
      return
    end
    local PlayerIconItem = PlayerInfoArray:Get(self.CurrentMapUI.LocalPlayerIndexC)
    Position = PlayerIconItem.RenderTransform.Translation + Position
    local AligX, AligY = self:GetObjectAligInCurMapSize(Position)
    local Alignment = FVector2D(AligX, AligY)
    self:MakeMarker(Alignment)
  end
end
function EntireMapUI:InitPlayers()
  self.CurrentMapData_BP:ResetPlayerInfoBPArray()
  self.TeamPlayerWithoutLocalPlayer:Clear()
end
function EntireMapUI:SetWidget()
  local CurrentMapUI = self.CurrentMapUI
  local HoldEntireMapWidget = self.HoldEntireMapWidget
  CurrentMapUI.CanvasPanel_ShowAirPlaneRoute = HoldEntireMapWidget.CanvasPanel_ReshowRoute
  HoldEntireMapWidget.MapCircleAndLineBlackboard.MapUI = CurrentMapUI
  HoldEntireMapWidget.MapCircleAndLineBlackboard.MapUIBaseBP = self
  CurrentMapUI.PlayerAddPanel = HoldEntireMapWidget.PlayerAddPanel
  CurrentMapUI.ExtraAddBottomPanel = HoldEntireMapWidget.ExtraAddBottomPanel
  CurrentMapUI.ExtraAddTopPanel = HoldEntireMapWidget.ExtraAddTopPanel
  self.MapImage = HoldEntireMapWidget.EntireMapImage
end
function EntireMapUI:SetAdaptation()
  if self.bHasSetAdaptation then
    return
  end
  self.bHasSetAdaptation = true
  local margin = Client.GetUIRectOffset()
  local result = StringUtil.Split(margin, ",")
  self.AdaptationBottomOffset = tonumber(result[4])
  if slua_isValid(self.HoldEntireMapWidget.SimpleModeHideCanvas.Slot) then
    local UIUtil = require("client.common.ui_util")
    local Size = UIUtil.GetViewportSize() / UIUtil.GetViewportScale()
    self.MapTopLeftOnScreen = (Size - FVector2D(self.MapWindowExtentC, self.MapWindowExtentC)) / 2.0
    self.MapCenterOnScreen = Size / 2.0
    self.CurMapSize = math.min(Size.Y - self.AdaptationBottomOffset, 638)
    self.MapInitSize.X = self.CurMapSize
    self.MapInitSize.Y = self.CurMapSize
    self:ChangeMapSize(self.MapInitSize, true, true)
    self.HoldEntireMapWidget.EditableTextBox_Location:SetWidgetVisibility(ESlateVisibility.Hidden)
  end
end
function EntireMapUI:HideFakeEdge()
  local StandardPoint = STExtraMapFunctionLibrary.GetMapStandardPoint(self)
  if slua_isValid(StandardPoint) then
    local Scale = StandardPoint.FakeEdgeExtent * 2
    Scale = StandardPoint.LevelBoundExtent - Scale
    Scale = StandardPoint.LevelBoundExtent / Scale
    Scale = self:ClampMapScaleValue(Scale)
    self.CurrentMapUI.MapScalingRadio = Scale
    Scale = self:CalSliderValue(Scale)
    self.HoldEntireMapWidget.Slider_MapZoom:SetValue(Scale)
  else
    self.CurrentMapUI.MapScalingRadio = 1
    local Scale = self:CalSliderValue(1.0)
    self.HoldEntireMapWidget.Slider_MapZoom:SetValue(Scale)
  end
  local bCacheCenterZoom = self.bSelfCenterZoom
  self.bSelfCenterZoom = false
  self:ResizeAndRedrawMap()
  self.bSelfCenterZoom = bCacheCenterZoom
  self:ChangeMapPivot(0.5, 0.5)
end
function EntireMapUI:InitMultiMarkButton()
  if self.bIsInfectMode or self.bIsVehicleWarMode or slua_isValid(self.AutoDriveVehicle) then
    EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_INIT_MULTI_MARK_BUTTON, false)
  else
    EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_INIT_MULTI_MARK_BUTTON, true)
  end
end
function EntireMapUI:SetTeamMateNameInMap()
  local PlayerState = GameplayData.GetPlayerState()
  if slua_isValid(PlayerState) then
    local CurrentMapData_BP = self.CurrentMapData_BP
    for Index, TeamMate in pairs(self.TeamMatePlayerStateList) do
      if PlayerState ~= TeamMate and TeamMate then
        CurrentMapData_BP:SetPlayerName(Index, TeamMate.PlayerName)
      else
        CurrentMapData_BP:SetPlayerName(Index, "")
      end
    end
  end
end
function EntireMapUI:HandleTeamMapMark(Index)
  EntireMapUI.__super.HandleTeamMapMark(self, Index)
  local CurTime = os.time()
  if not LastTeamMarkTime or CurTime - LastTeamMarkTime >= MapMarkCD then
    audio_util.PlayAudioAsyncAtLocation(MapMarkAudioPath, FVector(0, 0, 0), FRotator(0, 0, 0))
    LastTeamMarkTime = CurTime
  end
end
function EntireMapUI:RepositionAllMapMark(Param)
  local TeamMates = self:GetTeamMateListFromPlayerState(false)
  if not TeamMates then
    return
  end
  for i = 0, TeamMates:Num() - 1 do
    self:RepositionMapMark(i, self.Offset, self.MapCurSize)
  end
end
function EntireMapUI:MakeMarker(MarkAlignment)
  if not self.bIsInfectMode or self.bIsVehicleWarMode then
    local PlayerController = GameplayData.GetPlayerController()
    if slua_isValid(PlayerController) and not PlayerController:IsFriendOrEnemySpectator() then
      local bIsSpectator = PlayerController:IsSpectator() or PlayerController:IsInPetSpectator()
      local PlayerState = GameplayData.GetPlayerState()
      if slua_isValid(PlayerState) then
        local SuperData = self:GetSuperData()
        if self.bIsDrawMultiGuideLine then
          PlayerState:RPC_ServerAddGeneralCount(11502, 1, false)
          if PlayerState.MapMultiMark:Num() >= self.MultiMarkMaxNum then
            PlayerController:DisplayGameTipWithMsgID(11397)
          else
            local Location = FVector(MarkAlignment.X - 0.5, MarkAlignment.Y - 0.5, 1.0)
            PlayerController:SetPlayerMapMultiMark(Location, true, self.MultiMarkMaxNum, false)
            PlayerState:SetPlayerMapMultiMark(Location, true, self.MultiMarkMaxNum, false)
            EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_REPOSITION_SELF_MULTI_MARK)
            if SuperData then
              SuperData.Mark            end
          end
        else
          self.LocalPlayerMarkerAlig = MarkAlignment - 0.5
          local Location = FVector(self.LocalPlayerMarkerAlig.X, self.LocalPlayerMarkerAlig.Y, 1.0)
          PlayerController:SetPlayerMark(Location)
          PlayerState:RPC_ServerAddGeneralCount(11501, 1, false)
          PlayerState.MapMark = Location
          EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_MAKE_MAKER, self.LocalPlayerMarkerAlig.X, self.LocalPlayerMarkerAlig.Y, bIsSpectator)
          if SuperData then
            SuperData.Mark          end
          if not bIsSpectator then
            self:RepositionSelfMarker()
          end
          PlayerController.OnShowHideSelfMarkDelegate:BroadCast()
          self:ShowMarkerLocationText(self.LocalPlayerMarkerAlig)
          self:ShowMarkerDistance()
        end
      end
    end
  end
end
function EntireMapUI:RepositionSelfMarker()
  local PlayerArray = self.CurrentMapData_BP:GetPlayerBPMarkArray()
  local Index = self.CurrentMapUI.LocalPlayerIndexC
  if 0 <= Index and Index < PlayerArray:Num() then
    local PlayerState = GameplayData.GetPlayerState()
    if slua_isValid(PlayerState) then
      local MapMark = PlayerState.MapMark
      local MapMarkZ = MapMark.Z
      if 0 < MapMarkZ then
        local FLoc = FVector2D(self.LocalPlayerMarkerAlig.X * self.MapCurSize.X, self.LocalPlayerMarkerAlig.Y * self.MapCurSize.Y)
        self.CurrentMapData_BP:UpdateMark(Index, FLoc, true, MapMarkZ)
      else
        local FLoc = FVector2D(0, 0)
        self.CurrentMapData_BP:UpdateMark(Index, FLoc, false, 0.0)
      end
    end
  else
    print(string.format("bp mark length: %d, need index: %d", PlayerArray:Num(), Index))
  end
  self.CurrentMapData_BP:RepositionSelfMarker()
end
function EntireMapUI:ShowMarkerLocationText(InVector)
  local MapSys = require("GameLua.Mod.BaseMod.Client.Map.IngameMapSys")
  if MapSys:GetShowMakerLocation() then
    local Pos = self:MarkPoint2RealLocation(InVector)
    local TextBox = self.HoldEntireMapWidget.EditableTextBox_Location
    TextBox:SetWidgetVisibility(ESlateVisibility.Visible)
    local Text = string.format("%d, %d", Pos.X, Pos.Y)
    TextBox:SetText(Text)
  end
end
function EntireMapUI:MarkPoint2RealLocation(InVector)
  local Pos = FVector2D(self.CurrentMapUI.LevelLandScapeCenterC.X, self.CurrentMapUI.LevelLandScapeCenterC.Y)
  local Pos1 = FVector2D(InVector.X - 0.5, InVector.Y - 0.5)
  Pos1.Y = Pos1.X * self.LevelLandScapeExtent
  Pos1.X = Pos1.Y * self.LevelLandScapeExtent * -1
  Pos = Pos + Pos1
  return Pos
end
function EntireMapUI:ShowMarkerDistance()
  local PlayerState = GameplayData.GetPlayerState()
  if not slua_isValid(PlayerState) then
    return
  end
  local TeamMatePlayerState = PlayerState:GetTeamMatePlayerStateList({}, false)
  if TeamMatePlayerState:Num() > 0 then
    for Index, PlayerState in pairs(TeamMatePlayerState) do
      if slua_isValid(PlayerState) and 0 < PlayerState.MapMark.Z then
        local MarkPoint = FVector2D(PlayerState.MapMark.X, PlayerState.MapMark.Y)
        local MarkArray = self.CurrentMapData_BP:GetPlayerBPMarkArray()
        local Distance = self:CaclMarkDir(MarkPoint)
        if 0 <= Index and Index < MarkArray:Num() then
          local MapPlayer = MarkArray:Get(Index)
          if Distance == 0 then
            local uEPlayerLiveState = import("ExtraPlayerLiveState")
            if PlayerState.LiveState == uEPlayerLiveState.offline then
              MapPlayer:SetMarkDist(0, false)
            else
              MapPlayer:SetMarkDist(Distance, true)
            end
          else
            MapPlayer:SetMarkDist(Distance, true)
          end
        end
      end
    end
  else
    local Distance = self:CaclMarkDir(self.LocalPlayerMarkerAlig)
    local MarkArray = self.CurrentMapData_BP:GetPlayerBPMarkArray()
    local Index = self.CurrentMapUI.LocalPlayerIndexC
    if 0 <= Index and Index < MarkArray:Num() then
      local MapPlayer = MarkArray:Get(Index)
      MapPlayer:SetMarkDist(Distance, true)
    end
  end
end
function EntireMapUI:CaclMarkDir(MarkPoint)
  local PlayerController = GameplayData.GetPlayerController()
  if slua_isValid(PlayerController) then
    local Distance = STExtraMapFunctionLibrary.CalPlayerToMarkerDist(PlayerController, self.LevelLandScapeExtent, MarkPoint, self.CurrentMapUI.LevelLandScapeCenterC) / 100
    Distance = KismetMathLibrary.Round(Distance)
    return Distance
  end
  return 0
end
function EntireMapUI:GetObjectAligInCurMapSize(Pos)
  local Slot = self.HoldEntireMapWidget.MapCircleAndLineBlackboard.Slot
  local Size = Slot:GetSize()
  return Pos.X / Size.X, Pos.Y / Size.Y
end
function EntireMapUI:ShowEntiremap()
  self:SetReshowRouteEffectVisibility()
  self:ResizeAndRedrawMap()
  local bShow, CircleRadius, CenterVector = self.CurrentMapData_BP:CheckNeedZoomToFit()
  if bShow then
    self:HandleAutoLockBtnClick()
    self:AddGameTimer(0.05, false, function()
      self:HandleAutoLockBtnClick()
    end)
  elseif self.HoldEntireMapWidget.CanvasPanel_AutoLock:GetVisibility() == UEnums.ESlateVisibility.SelfHitTestInvisible and self:GetCurAreaID() <= 0 and self.bAutoLock == true then
    self.HoldEntireMapWidget.WidgetSwitcher_AutoLock:SetActiveWidgetIndex(1)
    self:HandleAutoLockBtnClick()
  end
end
function EntireMapUI:SetSettingConfig()
  local SavedSettingConfig = self.SavedSettingConfig
  if slua_isValid(SavedSettingConfig) then
    local BackendHUDObject = GameBackendHUD.GetInstance()
    local GameFrontendHUD = BackendHUDObject:GetFirstGameFrontendHUD()
    self.SavedSettingConfig = GameFrontendHUD:GetUserSettings()
  end
end
function EntireMapUI:ResizeAndRedrawMap()
  local CurrentMapUI = self.CurrentMapUI
  self.MapCurSize = self.MapInitSize * CurrentMapUI.MapScalingRadio
  self:ChangeMapSize(self.MapCurSize, true, false)
  local MinAlign, MaxAlign = self:GetMapMaxAligByMapSize(self.MapCurSize)
  self:ClampAlig(MaxAlign, MinAlign)
  CurrentMapUI.CorrectLevelToMapScaleC = CurrentMapUI.MapScalingRadio * CurrentMapUI.LevelToMapScaleC
  self:RepositionMarkerAndPin()
  self:TryActiveSelfCenterZoom()
  CurrentMapUI.bMapDynamicScaleDirty = true
  self:DispatchMapResizeEvent()
end
function EntireMapUI:GetMapMaxAligByMapSize(MapCurSize)
  local MinAlig = self.MapInitSize.X / (MapCurSize.X * 2)
  local MaxAlig = 1 - MinAlig
  return MinAlig, MaxAlig
end
function EntireMapUI:ChangeMapSize(Size, bCanChangeMapPivot, bIsPostResizeEvent)
  if bCanChangeMapPivot and self.bSelfCenterZoom then
    local ControlledPawn = GameplayData.GetPlayerCharacter()
    if slua_isValid(ControlledPawn) then
      local Location = ControlledPawn:K2_GetActorLocation()
      Location = self:OffsetActorLocation(Location)
      local ScapeCenter = self.CurrentMapUI.LevelLandScapeCenterC - self.LevelLandScapeExtent * 0.5
      Location = Location - ScapeCenter
      Location = Location / self.LevelLandScapeExtent
      self:ChangeMapPivot(Location.X, Location.Y)
    end
  end
  EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_CHANGE_ENTIRE_MAP_SIZE, Size)
  self.CurMapSize = Size.X
  self.CurrentMapUI.MapWindowExtentC = Size.X
  self.CurrentMapUI.MapImageExtentC = Size.X
  if bIsPostResizeEvent then
    self:DispatchMapResizeEvent()
  end
end
function EntireMapUI:OffsetActorLocation(Location)
  return Location
end
function EntireMapUI:ChangeMapPivot(AlignX, AlignY)
  local Align = FVector2D(AlignX, AlignY)
  local HoldEntireMapWidget = self.HoldEntireMapWidget
  local Slot = HoldEntireMapWidget.EntireMapImage.Slot
  Slot:SetAlignment(Align)
  local Slot = HoldEntireMapWidget.CanvasPanel_MapImageSize.Slot
  Slot:SetAlignment(Align)
end
function EntireMapUI:ClampAlig(MaxAlig, MinAlig)
  local HoldEntireMapWidget = self.HoldEntireMapWidget
  local Slot = HoldEntireMapWidget.EntireMapImage.Slot
  local Alignment = Slot:GetAlignment()
  Alignment.X = FuncUtil.Clamp(Alignment.X, MinAlig, MaxAlig)
  Alignment.Y = FuncUtil.Clamp(Alignment.Y, MinAlig, MaxAlig)
  Slot:SetAlignment(Alignment)
  Slot = HoldEntireMapWidget.CanvasPanel_MapImageSize.Slot
  Alignment = Slot:GetAlignment()
  Alignment.X = FuncUtil.Clamp(Alignment.X, MinAlig, MaxAlig)
  Alignment.Y = FuncUtil.Clamp(Alignment.Y, MinAlig, MaxAlig)
  Slot:SetAlignment(Alignment)
end
function EntireMapUI:RepositionMarkerAndPin()
  if self.bIsInfectMode then
    return
  end
  self:RedrawAllMapMark()
  if slua_isValid(self.CurrentMapUI) then
    self.CurrentMapUI.bRepositionMarkerAndPinDirty = true
    self:DispatchRefreshVisualInfoEvent()
  end
end
function EntireMapUI:DispatchRefreshVisualInfoEvent()
  if not self.CurrentMapUI:IsEnableDelayedRefreshVisualInfoEventInTick() then
    EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_REFRESH_VISUALINFO)
  end
end
function EntireMapUI:TryActiveSelfCenterZoom()
  if self.CurrentMapUI.MapScalingRadio == 1 then
    self.bSelfCenterZoom = true
    self.bCanZoonToFitBlueCircle = true
  end
end
function EntireMapUI:DispatchMapResizeEvent()
  if not self.CurrentMapUI:IsEnableDelayedMapResizeEventInTick() then
    self:OnChangeMapSize(false)
  end
end
function EntireMapUI:ZoomToFitBlueCircle(CircleRadius, Center)
  if self.bCanZoonToFitBlueCircle then
    self.bCanZoonToFitBlueCircle = false
    if 0 < CircleRadius then
      local CurrentMapUI = self.CurrentMapUI
      if 0 < CurrentMapUI.LevelToMapScaleC then
        local TargetScale = self.MapInitSize.Y * 0.5 / CircleRadius / CurrentMapUI.LevelToMapScaleC
        CurrentMapUI.MapScalingRadio = self:ClampMapScaleValue(TargetScale)
        TargetScale = self:CalSliderValue(CurrentMapUI.MapScalingRadio)
        self.HoldEntireMapWidget.Slider_MapZoom:SetValue(TargetScale)
        self:ResizeAndRedrawMap()
        CurrentMapUI:ReCalMapInfoC()
        local PointOnMap = Center * CurrentMapUI.MapScalingRadio
        self:MovePointOnMapToCenter(PointOnMap)
      else
        print("Level to map scale is 0")
      end
    else
      print("BlueCircle radius is 0")
    end
  end
end
function EntireMapUI:MovePointOnMapToCenter(PointOnMap)
  local Point = PointOnMap + self.MapCurSize / 2
  local AlignX, AlignY = self:GetObjectAligInCurMapSize(Point)
  local MinAlign, MaxAlign = self:GetMapMaxAligByMapSize(self.MapCurSize)
  AlignX = FuncUtil.Clamp(AlignX, MinAlign, MaxAlign)
  AlignY = FuncUtil.Clamp(AlignY, MinAlign, MaxAlign)
  self:ChangeMapPivot(AlignX, AlignY)
  local MapSize = self.MapInitSize * self.CurrentMapUI.MapScalingRadio
  MinAlign, MaxAlign = self:GetMapMaxAligByMapSize(MapSize)
  self:ClampAlig(MaxAlign, MinAlign)
end
function EntireMapUI:HandleMapMove(uVector)
  local OffsetX = uVector.X
  local OffsetY = uVector.Y
  local EntireMapImageSlot = self.HoldEntireMapWidget.EntireMapImage.Slot
  local SlotSize = EntireMapImageSlot:GetSize()
  local AlignmentSize = EntireMapImageSlot:GetAlignment()
  local MaxAlign = SlotSize.X * 2
  local MinAlign = self.MapInitSize.X / MaxAlign
  MaxAlign = 1 - MinAlign
  local AlignmentX = AlignmentSize.X - OffsetX / SlotSize.X
  local AlignmentY = AlignmentSize.Y - OffsetY / SlotSize.Y
  local AlignmentX = FuncUtil.Clamp(AlignmentX, MinAlign, MaxAlign)
  local AlignmentY = FuncUtil.Clamp(AlignmentY, MinAlign, MaxAlign)
  local AlignmentVector = FVector2D(AlignmentX, AlignmentY)
  EntireMapImageSlot:SetAlignment(AlignmentVector)
  local MapImageSizeSlot = self.HoldEntireMapWidget.CanvasPanel_MapImageSize.Slot
  MapImageSizeSlot:SetAlignment(AlignmentVector)
  self.bSelfCenterZoom = false
end
function EntireMapUI:ClampMapScaleValue(InputMapScale)
  local MapScale = math.floor(InputMapScale * 1000) / 1000.0
  MapScale = FuncUtil.Clamp(MapScale, 1, self.MaxScaleValue + 1.0)
  return MapScale
end
function EntireMapUI:CalSliderValue(CurScale)
  local Scale = CurScale - 1.0
  Scale = Scale * (1.0 / self.MaxScaleValue)
  return Scale
end
function EntireMapUI:ChangeMapTextureAndTags(MapTexturePath, MapScale, MapStandTag, bIsChangeTags)
  EntireMapUI.__super.ChangeMapTextureAndTags(self, MapTexturePath, MapScale, MapStandTag, bIsChangeTags)
  local bBaltic = MapStandTag == ""
  if self.bShowAirplaneRoute and bBaltic then
    EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_SHOW_AIRPLANE_ROUTE, true)
    self.CurrentMapUI.CanvasPanel_ShowAirPlaneRoute:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
    print(bWriteLog and "EntireMapUI:ChangeMapTextureAndTags - CanvasPanel_ShowAirPlaneRoute Show")
  else
    EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_SHOW_AIRPLANE_ROUTE, false)
    self.CurrentMapUI.CanvasPanel_ShowAirPlaneRoute:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    print(bWriteLog and "EntireMapUI:ChangeMapTextureAndTags - CanvasPanel_ShowAirPlaneRoute false")
  end
end
function EntireMapUI:MultiGuideLineEvent(bInDrawMultiGuideLine)
  self.bIsDrawMultiGuideLine = bInDrawMultiGuideLine
  EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_ENTIRE_MAP_MULTI_GUIDELINE, bInDrawMultiGuideLine)
  self.bIsDrawMultiGuideLine = not bInDrawMultiGuideLine
end
local class = require("class")
local CMapUIBase = require("GameLua.Mod.BaseMod.Client.Map.MapUI.MapUIBase")
local CEntireMapUI = class(CMapUIBase, nil, EntireMapUI)
return CEntireMapUI