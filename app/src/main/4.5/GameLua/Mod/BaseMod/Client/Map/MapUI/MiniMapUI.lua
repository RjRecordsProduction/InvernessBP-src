local MiniMapUI = {}
local slua_isValid = slua.isValid
local ESlateVisibility = UEnums.ESlateVisibility
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local MapDynamicScaleConfig = {
  [1] = {
    LowerLimit = 0,
    UpperLimit = 805.555481,
    ScaleFactor = 1.0,
    ScaleFactor2 = 0.4
  },
  [2] = {
    LowerLimit = 805.555481,
    UpperLimit = 1916.66626,
    ScaleFactor = 0.875,
    ScaleFactor2 = 0.3
  },
  [3] = {
    LowerLimit = 1916.66626,
    UpperLimit = 2611.111084,
    ScaleFactor = 0.75,
    ScaleFactor2 = 0.25
  },
  [4] = {
    LowerLimit = 2611.111084,
    UpperLimit = 99999.0,
    ScaleFactor = 0.5,
    ScaleFactor2 = 0.2
  }
}
function MiniMapUI:SetTickAdjustMappostion(bAdjust)
  self.CurrentMapUI.BTickAdjustMapPostion = bAdjust
end
function MiniMapUI:SetNotChangeScale(bNotChangeScale)
  self.  self:ReadDynamicScaleTable()
end
function MiniMapUI:SetMiniMapPostion(PointLocationInLevel)
  if not PointLocationInLevel then
    return
  end
  local CPS = self.CurrentMapUI.MapAndCircleCanvas.Slot
  if CPS then
    local USTExtraMapFunctionLibrary = import("/Script/ShadowTrackerExtra.STExtraMapFunctionLibrary")
    local LevelLandScapeCenter = self.CurrentMapUI.LevelLandScapeCenterC
    local LevelToMapScale = self.CurrentMapUI:GetLevelToMapScale()
    local NewTranslation = USTExtraMapFunctionLibrary.MapCenterToPointVector2D(PointLocationInLevel, LevelLandScapeCenter, LevelToMapScale)
    self.CurrentMapUI.MapAdjustOffsetC = USTExtraMapFunctionLibrary.AdjustMapPosition(CPS, NewTranslation, self.CurrentMapUI.MapWindowExtentC * 0.5, self.CurrentMapUI.MapImageExtentC)
  end
end
function MiniMapUI:SetTargetPosition(InTargetPosition)
  self.CurrentMapUI:SetTargetPosition(InTargetPosition)
end
function MiniMapUI:SetMiniMapState(bEnableCircleMiniMap, bEnableCenteredAtTargetPoint)
  if self.CurrentMapUI then
    self.CurrentMapUI:SetMiniMapState(bEnableCircleMiniMap, bEnableCenteredAtTargetPoint)
  end
end
function MiniMapUI:ConvertWorldPosition2MapPosition(WorldPosition)
  local USTExtraMapFunctionLibrary = import("/Script/ShadowTrackerExtra.STExtraMapFunctionLibrary")
  local LevelLandScapeCenter = self.CurrentMapUI.LevelLandScapeCenterC
  local LevelToMapScale = self.CurrentMapUI:GetLevelToMapScale()
  local MapPosition = USTExtraMapFunctionLibrary.MapCenterToPointVector2D(WorldPosition, LevelLandScapeCenter, LevelToMapScale)
  return MapPosition
end
function MiniMapUI:ReadDynamicScaleTable()
  print(bWriteLog and " MiniMapUI:ReadDynamicScaleTable bNotChangeScale:" .. tostring(self.bNotChangeScale))
  local LowerLimitTb = {}
  local ScaleFactorTb = {}
  local bNotChangeScale = self.bNotChangeScale
  for i, v in ipairs(MapDynamicScaleConfig) do
    LowerLimitTb[i] = v.LowerLimit
    if bNotChangeScale then
      ScaleFactorTb[i] = 1
    else
      ScaleFactorTb[i] = v.ScaleFactor
    end
  end
  self.CurrentMapUI.SpeedLowerLimitListC = LowerLimitTb
  self.CurrentMapUI.DynamicScaleFactorListC = ScaleFactorTb
end
function MiniMapUI:ReadDynamicScaleTableInRacing()
  print(bWriteLog and " MiniMapUI:ReadDynamicScaleTableInRacing bNotChangeScale:" .. tostring(self.bNotChangeScale))
  local LowerLimitTb = {}
  local ScaleFactorTb = {}
  local bNotChangeScale = self.bNotChangeScale
  for i, v in ipairs(MapDynamicScaleConfig) do
    LowerLimitTb[i] = v.LowerLimit
    if bNotChangeScale then
      ScaleFactorTb[i] = 1
    else
      ScaleFactorTb[i] = v.ScaleFactor2
    end
  end
  self.CurrentMapUI.SpeedLowerLimitListC = LowerLimitTb
  self.CurrentMapUI.DynamicScaleFactorListC = ScaleFactorTb
end
function MiniMapUI:OnRacingDataChange(IsRacing)
  if IsRacing then
    self:ReadDynamicScaleTableInRacing()
  else
    self:ReadDynamicScaleTable()
  end
end
function MiniMapUI:InitMapStandardPoint()
  MiniMapUI.__super.InitMapStandardPoint(self)
  self:SelfInitMapStandardPoint()
  self:HandleMapResize()
end
function MiniMapUI:InitMapTextureCallBack()
  self:InitMapStandardPoint()
  self:OnMapResize()
  EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_MAP_IMMEDIATE_REFRESH, self.bIsMiniMap, self.CurTag)
end
function MiniMapUI:HandleChangeMapTexture(MapTexturePath, NewMapScale, MapStandTag)
  if MapTexturePath == "" then
    local DefaultMapScale = self:GetDefaultScale()
    self.StandardScale = DefaultMapScale
  else
    self.StandardScale = NewMapScale
  end
  MiniMapUI.__super.HandleChangeMapTexture(self, MapTexturePath, NewMapScale, MapStandTag)
end
function MiniMapUI:ShowHideMarkMarkTagCanvas(Tag, NewVis)
  local TagMarkRootMap = self.CurrentMapUI.CustomTagMarkRootMap
  if Tag < TagMarkRootMap:Num() then
    local MarkRoot = TagMarkRootMap:Get(Tag)
    if slua_isValid(MarkRoot) then
      if NewVis then
        MarkRoot:SetWidgetVisibility(ESlateVisibility.HitTestInvisible)
      else
        MarkRoot:SetWidgetVisibility(ESlateVisibility.Collapsed)
      end
    end
  end
end
function MiniMapUI:OnDestroy()
  print(bWriteLog and "MiniMapUI:OnDestroy")
  if slua.isValid(self.CurrentMapData_BP) then
    self.CurrentMapData_BP:OnDestroy()
  end
  self:ClearWidgets()
  self.HoldWidget = nil
  self.HoldMiniWidget = nil
  self.STExtraPlayerController = nil
  self:UnRegistBPEvents()
  self:Dispose()
end
function MiniMapUI:HandleConstruct(Widget, MapDataBase)
  self.CurrentMapUI = CGame:NewObjectFromPath("/Script/ShadowTrackerExtra.MiniMapUI", self)
  self.bIsMiniMap = true
  self.HoldMini  self:SetWidget()
  MiniMapUI.__super.HandleConstruct(self, Widget, MapDataBase)
  self:AddControlEvent(self.CurrentMapUI, "OnSetupUIMarkRoot", self.SetupMarkRoot, self)
  self:AddControlEvent(self.CurrentMapUI, "OnMapResizeC", self.OnMapResize, self)
  self:AddControlEvent(self.CurrentMapUI, "OnHandleTeammateOutOfRangeC", self.TeammateOutOfRange, self)
end
function MiniMapUI:RegistEvents()
  MiniMapUI.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_ENTIRE_MAP_SHOW_STATE, self.HandleEntireShowEvt, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_DELETE_SELF_MAP_MAKER, self.HandleDeleteMaker, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_HIDE_ALL_UI, self.HandleHideAllUI, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_DEATH_MATCH_UI_SETTING, self.HandleReceiveDeathMatchUISetting, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_GAMEPLAY_SYNC_PLAYERSTATE, self.HandleGamePlaySyncPlayerState, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_ENTIRE_MAP_SHOW_RESIZE_MINIMAP, self.TryRefreshMiniMap, self)
end
function MiniMapUI:HandleOnPlayerEnterFlying()
  self.MapWindowHalfExtent = self.CurrentMapUI.MapWindowExtentC / 2
  self:RedrawAllMapMark()
end
function MiniMapUI:RegisterDelegate()
  MiniMapUI.__super.RegisterDelegate(self)
  self:SelfRegisterDelegates()
end
function MiniMapUI:HandleReceiveInitWidget()
  MiniMapUI.__super.HandleReceiveInitWidget(self)
  self:SelfHandleReceivedWidget()
end
function MiniMapUI:HandleInitPlayerState()
  MiniMapUI.__super.HandleInitPlayerState(self)
  self:SelfHandleInitPlayerState()
end
function MiniMapUI:HandleResetUIStateAfterRespawn()
  self:HandleInitPlayerState()
end
function MiniMapUI:Reconnect_ResetUIByPlayerControllerState()
  MiniMapUI.__super.Reconnect_ResetUIByPlayerControllerState(self)
  self:MiniMapAdjustLimtChange()
end
function MiniMapUI:OnCharacterStateChange(OwnerCharacter, LiveState)
  print(bWriteLog and "MiniMapUI:OnCharacterStateChange")
  MiniMapUI.__super.OnCharacterStateChange(self, OwnerCharacter, LiveState)
  self:SelfOnCharacterStateChange(OwnerCharacter, LiveState)
end
function MiniMapUI:OnSpectatorChanged()
  MiniMapUI.__super.OnSpectatorChanged(self)
  self:SelfOnSpectatorChange()
end
function MiniMapUI:SetupMarkRoot()
  local CurrentMapUI = self.CurrentMapUI
  local HoldMiniWidget = self.HoldMiniWidget
  CurrentMapUI.m_pMarkRoot = HoldMiniWidget.CanvasPanel_MarkSystem
  local EPropertyClass = UEnums.EPropertyClass
  local CanvasPanelSlot = import("CanvasPanel")
  CurrentMapUI.CustomTagMarkRootMap:Add(HoldMiniWidget.CanvasPanel_MarkRoot1)
  CurrentMapUI.CustomTagMarkRootMap:Add(HoldMiniWidget.CanvasPanel_MarkRoot2)
  CurrentMapUI.DynamaicCustomPanelMap:Add("DynamicMark", HoldMiniWidget.DynamicMarkPanel)
end
function MiniMapUI:SelfRegisterDelegates()
  GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerEnterFighting", self.MiniMapAdjustLimtChange, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnRepTeammateChange", self.HandleOnTeamMateChange, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnRepPlayerState", self.HandleInitPlayerState, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnReconnectResetUIByPlayerControllerStateDelegate", self.Reconnect_ResetUIByPlayerControllerState, self)
end
function MiniMapUI:OnMapResize()
  self:HandleMapResize()
end
function MiniMapUI:TeammateOutOfRange(Widget, bIsInRange, RotDegree)
  self:HandleTeammateOutOfRange(Widget, bIsInRange, RotDegree)
end
function MiniMapUI:HandleEntireShowEvt(_, _, bShow)
  if bShow and slua_isValid(self.HoldWidget) then
    self.HoldWidget:SetWidgetVisibility(ESlateVisibility.Collapsed)
    self.bIsShow = false
  else
    self:HideEnterMap()
  end
end
function MiniMapUI:HandleDeleteMaker()
  self.CurrentMapUI.bNeedDrawSelfGuideLineC = false
end
function MiniMapUI:HandleHideAllUI()
  local PlayerController = GameplayData.GetPlayerController()
  if slua_isValid(PlayerController) then
    PlayerController.bMoveInMiniMap = false
  end
  self:RedrawAllMapMark()
end
function MiniMapUI:HandleReceiveDeathMatchUISetting()
  print(bWriteLog and "MiniMapUI:HandleReceiveDeathMatchUISetting")
  self.CurrentMapData_BP:SwitchAllAliveDeadIcon(false)
  self:HandleReceiveInitWidget()
  self:HandleInitPlayerState()
  self:RedrawAllMapMark()
end
function MiniMapUI:HandleGamePlaySyncPlayerState()
  self:HandleReceiveInitWidget()
  self:HandleInitPlayerState()
  self:RedrawAllMapMark()
end
function MiniMapUI:TryRefreshMiniMap()
  self:HandleMapResize()
  self:RedrawAllMapMark()
  if slua_isValid(self.CurrentMapUI) then
    self.CurrentMapUI.MapScalingRadio = 0.9
  end
end
function MiniMapUI:MiniMapAdjustLimtChange()
  local PlayerController = GameplayData.GetPlayerController()
  if slua_isValid(PlayerController) then
    if PlayerController:IsInFight() then
      self.MapWindowHalfExtent = 0.0
    elseif not PlayerController:IsInInitial() then
      self.MapWindowHalfExtent = self.CurrentMapUI.MapWindowExtentC / 2.0
    end
  end
end
function MiniMapUI:HandleOnTeamMateChange()
  self:ResetLocalPlayerIndex(false)
  if not self.bIsInfectMode then
    self:HideAllMark()
    self:RedrawAllMapMark()
    self:RefreshLocalPlayer()
  end
end
function MiniMapUI:SelfOnCharacterStateChange()
  local PlayerState = GameplayData.GetPlayerState()
  if slua_isValid(PlayerState) and PlayerState.GetTeamMatePlayerStateList then
    self.CurPlayerID = PlayerState.PlayerId
    local TeamMatePlayerState = PlayerState:GetTeamMatePlayerStateList({}, false)
    for Index, TeamMateState in pairs(TeamMatePlayerState) do
      if slua_isValid(TeamMateState) then
        self.CurrentMapData_BP:SwitchAliveDeadIcon(Index, TeamMateState.LiveState)
        self.CurrentMapData_BP:UpdateVeteranStatus(Index, TeamMateState:GetMentorPlayerType(), TeamMateState:GetVeteranPlayerLevel())
      end
    end
  end
end
function MiniMapUI:SelfOnSpectatorChange()
  local EPlayerLiveState = import("ExtraPlayerLiveState")
  self:OnCharacterStateChange(nil, EPlayerLiveState.InDefault)
  self:RefreshLocalPlayer()
end
function MiniMapUI:HideEnterMap()
  if slua_isValid(self.HoldWidget) then
    self.bIsShow = true
    self.HoldWidget:SetWidgetVisibility(ESlateVisibility.SelfHitTestInvisible)
    local PlayerController = GameplayData.GetPlayerController()
    if slua_isValid(PlayerController) then
      PlayerController.bMoveInMiniMap = false
    end
    self:RedrawAllMapMark()
  end
end
function MiniMapUI:RefreshLocalPlayer()
  self.TeamPlayerWithoutLocalPlayer:Clear()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local PlayerState = PlayerController:GetCurPlayerState()
  if slua_isValid(PlayerState) then
    self.CurrentMapData_BP:SetSpectatorInfoAndColor(PlayerState)
    for _, TeamMateState in pairs(self.TeamMatePlayerStateList) do
      if slua_isValid(TeamMateState) and TeamMateState.PlayerId ~= PlayerState.PlayerId then
        self.TeamPlayerWithoutLocalPlayer:Add(TeamMateState)
      end
    end
  end
end
function MiniMapUI:HandleMapResize()
  if slua_isValid(self.MapTexture) then
    local MapSizeX = math.floor(self.MapTexture:Blueprint_GetSizeX())
    MapSizeX = MapSizeX * (self.StandardScale * self.CurrentMapUI.MapScalingRadio)
    self.CurrentMapUI.MapImageExtentC = MapSizeX
    self.MapCurSize = FVector2D(MapSizeX, MapSizeX)
    self.CurrentMapUI.LevelToMapScaleC = MapSizeX / self.LevelLandScapeExtent
    self.GuideLineMaxLength = MapSizeX * math.sqrt(2.0)
    if self.CurrentMapUI.MapAndCircleCanvas then
      local MapAndCircleCanvas = self.CurrentMapUI.MapAndCircleCanvas.Slot
      if slua_isValid(MapAndCircleCanvas) then
        MapAndCircleCanvas:SetSize(self.MapCurSize)
      end
    end
    self:OnChangeMapSize(true)
    self.CurrentMapUI.bMapDynamicScaleDirty = true
  end
end
function MiniMapUI:HandleTeammateOutOfRange(Widget, bIsInRange, RotDegree)
  if slua_isValid(Widget) then
    if Widget.SwitchInOutRange then
      Widget:SwitchInOutRange(bIsInRange, RotDegree, true)
    else
      local SwitchInOutRangeFunction = Widget["SwitchIn/OutRange"]
      if SwitchInOutRangeFunction then
        SwitchInOutRangeFunction(Widget, bIsInRange, RotDegree, true)
      end
    end
  end
end
function MiniMapUI:SelfHandleReceivedWidget()
  self:InitMapTexture()
  self.StandardScale = self:GetDefaultScale()
  self.CurrentMapUI.MapScalingRadio = 1
  self:InitMapStandardPoint()
  self:ReadDynamicScaleTable()
  self.CurrentMapData_BP:HandleReceiveInitWidget(self.HoldMiniWidget.PlayerAddPanel)
end
function MiniMapUI:SetWidget()
  self.CurrentMapUI.ExtraAddBottomPanel = self.HoldMiniWidget.ExtraAddBottomPanel
  self.CurrentMapUI.ExtraAddTopPanel = self.HoldMiniWidget.CanvasPanel_MarkSystem
  self.CurrentMapUI.PlayerAddPanel = self.HoldMiniWidget.PlayerAddPanel
  self.MapImage = self.HoldMiniWidget.MiniMap
  self.CurrentMapUI.MapAndCircleCanvas = self.HoldMiniWidget.MapandCircleCanvas
end
function MiniMapUI:HandleRepPlayerState()
end
function MiniMapUI:SelfHandleInitPlayerState()
  self:InitPlayerState(true)
end
function MiniMapUI:SelfInitMapStandardPoint()
  local MapSys = require("GameLua.Mod.BaseMod.Client.Map.IngameMapSys")
  self.CurrentMapUI.GuideLineColor = MapSys:GetPlayerColorByIndexC(self.CurrentMapUI.LocalPlayerIndexC)
  self:ReSetLineColor()
end
function MiniMapUI:GetDefaultScale()
  if self.UseOutMinimapscale then
    return self.OutMiniMapScale / 100.0
  else
    local GameState = GameplayData.GetGameState()
    if slua_isValid(GameState) then
      local ModeCfg = CDataTable.GetTableData("BTMode", GameState.GameModeID)
      if ModeCfg then
        local MapID = ModeCfg.MapID
        local MapCfg = CDataTable.GetTableData("Map", MapID)
        if MapCfg then
          local MiniMapScale = MapCfg.Minimapscale / 100
          return MiniMapScale
        end
      end
    end
    return 1.0
  end
end
local class = require("class")
local CMapUIBase = require("GameLua.Mod.BaseMod.Client.Map.MapUI.MapUIBase")
local CMiniMapUI = class(CMapUIBase, nil, MiniMapUI)
return CMiniMapUI