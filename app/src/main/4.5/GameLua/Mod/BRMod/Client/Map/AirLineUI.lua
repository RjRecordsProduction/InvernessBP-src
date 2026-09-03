local AirLineUI = {
  MarkLocationJumpInfo = {
    Default = {ConstantC = 100000, ConstantD = 113760.0},
    Baltic = {ConstantC = 120000, ConstantD = 113760.0},
    Savage = {ConstantC = 100000, ConstantD = 56880.0},
    Borderland = {ConstantC = 42500, ConstantD = 19908.0},
    Karakin = {ConstantC = 60000, ConstantD = 28440.0},
    DihorOtok = {ConstantC = 120000, ConstantD = 68256.0},
    Livik = {ConstantC = 71600, ConstantD = 28440.0},
    Desert = {ConstantC = 120000, ConstantD = 113760.0},
    Neon = {ConstantC = 120000, ConstantD = 113760.0}
  }
}
local STExtraMapFunctionLibrary = import("STExtraMapFunctionLibrary")
local UGameplayStatics = import("GameplayStatics")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
function AirLineUI:ctor()
  printf("AirLineUI:ctor")
  self.TickRat = 0.03
  self.FixedAirlineScale = true
end
function AirLineUI:OnInitialize()
  printf("AirLineUI:OnInitialize")
end
function AirLineUI:OnPostInitialize()
  printf("AirLineUI:OnPostInitialize")
  AirLineUI.__super.OnPostInitialize(self)
end
function AirLineUI:RegistEvents()
  print(bWriteLog and "AirLineUI:RegistEvents")
  AirLineUI.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_SHOW_AIR_PLANE, self.ShowAirIcon, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_HIDE_AIR_PLANE, self.HideAirIcon, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_DEATH_MATCH_UI_SETTING, self.UpdateRouteWhenIsMiniMap, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_GAMEPLAY_SYNC_PLAYERSTATE, self.UpdateRouteWhenIsMiniMap, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_ENTIRE_MAP_SHOW_RESIZE_MINIMAP, self.UpdateRouteWhenIsMiniMap, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_MAP_AIRLINE_ROUTE_UPDATE, self.UpdateRouteByEvent, self)
end
function AirLineUI:OnUnRegistEvents()
  print(bWriteLog and "AirLineUI:OnUnRegistEvents")
  if self.RepositionItemOnMapDel then
    if self.MapUIBase then
      self.MapUIBase.OnRepositionItemOnMap:Remove(self.RepositionItemOnMapDel)
    end
    self.RepositionItemOnMapDel = nil
  end
end
function AirLineUI:Close()
  printf("AirLineUI:Close  " .. tostring(self.IsMiniMap))
  if self.TickWidgetTimer then
    self:RemoveGameTimer(self.TickWidgetTimer)
    self.TickWidgetTimer = nil
  end
  AirLineUI.__super.Close(self)
end
function AirLineUI:BindMapUIBase(MapUI, IsMiniMap)
  if MapUI then
    self.MapUIBase = MapUI.CurrentMapUI
    self.    self.    local RealTimeInfo = slua.IndexReference(self.MapUIBase, "MapRealTimeInfoC")
    self.PlaneRouteData = slua.IndexReference(RealTimeInfo, "PlaneRouteData")
    self:InitAirlineVisibility()
    self:InitAirlineWithMapType(IsMiniMap)
    self.AirIconVisible = true
    self.AirlineVisible = true
    self:BindLuaObjEvent(MapUI, "OnEntireMapOpen", self.OnEnterMap, self)
    self:BindLuaObjEvent(MapUI, "OnChangeMapSize", self.UpdateRouteBothMap, self)
    self:BindLuaObjEvent(MapUI, "ForceHideAirIcon", self.ForceHideAirIcon, self)
    self:BindLuaObjEvent(MapUI, "ForceRefreshAirLine", self.ForceRefreshAirLine, self)
    self:BindLuaObjEvent(MapUI, "ReShowAirplaneRoute", self.ReShowAirplaneRoute, self)
    self:BindLuaObjEvent(MapUI, "AfterInitMapStandard", self.InitAirlineVisibility, self)
    self:BindLuaObjEvent(MapUI, "UpdateAirplaneRouteShow", self.UpdateAirplaneRoute, self)
    print(bWriteLog and "AirLineUI BindMapUIBase Success")
  end
end
function AirLineUI:InitAirlineVisibility()
  if self.MapUIBase and self.MapUI.CurTag then
    local tags = self.MapUI.CurTag
    if tags == "" then
      self.bIsCanShow = true
    else
      self.bIsCanShow = false
    end
  end
  if self.bLastCanShow == nil or self.bIsCanShow == nil or self.bLastCanShow ~= self.bIsCanShow then
    self:ReFreshVisible()
    self.bLastCanShow = self.bIsCanShow
  end
end
function AirLineUI:InitAirlineWithMapType(IsMiniMap)
  self.AirLineScale = 1
  self.FixedAirlineScale = true
  if IsMiniMap then
    self.FixedAirlineScale = true
    self.UIRoot.Image_Start.Slot:SetSize(FVector2D(6, 6))
    self.UIRoot.Image_End.Slot:SetSize(FVector2D(8, 8))
    self.RepositionItemOnMapDel = self.MapUIBase.OnRepositionItemOnMap:Add(function()
      self:UpdateRouteWhenIsMiniMap()
    end)
  else
    self.UIRoot.Image_Start.Slot:SetSize(FVector2D(24, 24))
    self.UIRoot.Image_End.Slot:SetSize(FVector2D(20, 20))
    local CurGameModeID = Client.GetGameModeID(GameFrontendHUD)
    local ModeTableData = CDataTable.GetTableData("BTMode", CurGameModeID)
    if ModeTableData then
      self.AirLineScale = ModeTableData.AirlineCoefficient / 100.0
      self.FixedAirlineScale = self.AirLineScale > 0.999
    end
  end
end
function AirLineUI:InitUI(ParentUI)
  if ParentUI and ParentUI.UIRoot.CommonFunctionAddPanel then
    self.bInitSuccess = true
    self:ReFreshVisible()
    print(bWriteLog and "AirLineUI:InitUI SUCCESS" .. tostring(self.IsMiniMap))
    ParentUI:AttachChildWindow("CommonFunctionAddPanel", self)
    self.UIRoot.Slot:SetAnchors(FAnchors(0, 0, 1, 1))
    self.UIRoot.Slot:SetOffsets(FMargin(0, 0, 0, 0))
    self.UIRoot.Slot:SetZOrder(2)
    self.AirlineVisible = self.UIRoot.CanvasPanel_Airline:GetVisibility() == UEnums.ESlateVisibility.SelfHitTestInvisible
    self.AirIconVisible = self.UIRoot.Image_AirIcon:GetVisibility() == UEnums.ESlateVisibility.SelfHitTestInvisible
    if not self.TickWidgetTimer and self:IsNeedTick() then
      self.TickWidgetTimer = self:AddGameTimer(self.TickRat, true, function()
        self:TickWidget()
      end)
    end
    self:CheckShowIconAfterInit()
    self:UpdateMarkParachuteVisable()
  else
    self.bInitSuccess = false
    self:SetVisible(self.UIRoot, false)
    print(bWriteLog and "AirLineUI:InitUI FALSE" .. tostring(self.IsMiniMap))
  end
end
function AirLineUI:UpdateAirplaneRoute(bIsShow)
  if not bIsShow then
    self:SetArilineGroupVisibility(false)
  else
    self:UpdateRoute()
    self:SetArilineGroupVisibility(true)
  end
end
function AirLineUI:UpdateRouteWhenIsMiniMap()
  if self:IsNeedTick() and self.IsMiniMap and self.AirlineVisible then
    self.MapUIBase:ReCalMapInfoC()
    self:UpdateRoute()
  end
end
function AirLineUI:UpdateRouteBothMap()
  self:ForceRefreshAirLine(nil, nil, true)
  self:ForceRefreshAirLine(nil, nil, false)
end
function AirLineUI:UpdateRouteByEvent()
  if not Game:IsValid(self.MapUIBase) then
    return
  end
  self.MapUIBase:ReCalMapInfoC()
  if self.MapUIBase.bIsShowAirPlaneRouteAfteHide then
    self:ReShowAirplaneRoute()
  else
    self:UpdateRoute()
  end
end
function AirLineUI:UpdateRoute()
  local PlaneRouteData = self.PlaneRouteData
  local MapRadio = self.MapUIBase.MapScalingRadio
  if self.AirlineVisible then
    if not self.IsMiniMap then
      print(bWriteLog and "AirLineUI:UpdateRoute  PlaneRouteData.RouteLengthInMap : " .. tostring(PlaneRouteData.RouteLengthInMap) .. " ; " .. tostring(MapRadio))
    end
    local AirlineRouteCanvas = self.UIRoot.CanvasPanel_Airline
    if self.MapUIBase.bIsShowAirPlaneRouteAfteHide then
      AirlineRouteCanvas:SetRenderTranslation(slua.IndexReference(PlaneRouteData, "LastValidCanJumpLocInMap"))
      AirlineRouteCanvas:SetRenderAngle(PlaneRouteData.LastValidRouteWidgetRotateAngle)
      self.UIRoot.Image_JumpMark:SetRenderAngle(PlaneRouteData.LastValidRouteWidgetRotateAngle)
      self.UIRoot.Image_JumpMark_Glow:SetRenderAngle(PlaneRouteData.LastValidRouteWidgetRotateAngle)
    else
      AirlineRouteCanvas:SetRenderTranslation(slua.IndexReference(PlaneRouteData, "CanJumpLocInMap"))
      AirlineRouteCanvas:SetRenderAngle(PlaneRouteData.RouteWidgetRotateAngle)
      self.UIRoot.Image_JumpMark:SetRenderAngle(PlaneRouteData.RouteWidgetRotateAngle)
      self.UIRoot.Image_JumpMark_Glow:SetRenderAngle(PlaneRouteData.RouteWidgetRotateAngle)
    end
    local NewSizeY = AirlineRouteCanvas.Slot:GetSize().Y
    local NewSizeX = 0
    if self.MapUIBase.bIsShowAirPlaneRouteAfteHide then
      NewSizeX = PlaneRouteData.LastValidRouteLengthInMap
    else
      NewSizeX = PlaneRouteData.RouteLengthInMap
    end
    if not self.FixedAirlineScale then
      NewSizeX = NewSizeX / MapRadio
    end
    AirlineRouteCanvas.Slot:SetSize(FVector2D(NewSizeX, NewSizeY))
  end
end
function AirLineUI:TickWidget()
  self:CommonTick()
  if not self.IsMiniMap then
    self:EntrieMapTick()
  end
end
function AirLineUI:IsNeedTick()
  if self.MapUI.bIsShow then
    return true
  else
    return false
  end
end
function AirLineUI:CommonTick()
  if not slua.isValid(self.MapUIBase) then
    return
  end
  self.MapUIBase:ReCalMapInfoC()
  local PlaneRouteData = self.PlaneRouteData
  local UIRoot = self.UIRoot
  if self.AirIconVisible then
    local PlaneLoc = slua.IndexReference(PlaneRouteData, "PlaneLocInMap")
    if slua.IndexReference(PlaneRouteData, "CanJumpLocInMap"):IsZero() and slua.IndexReference(PlaneRouteData, "ForceJumpLocInMap"):IsZero() and PlaneLoc:IsZero() then
      self:SetAirIconVisibility(false)
    end
    local AirIcon = UIRoot.Image_AirIcon
    AirIcon:SetRenderTranslation(PlaneLoc)
  end
  if not self.MapUIBase.bIsShowAirPlaneRouteAfteHide and self.AirlineVisible then
    local AirlineRouteCanvas = self.UIRoot.CanvasPanel_Airline
    local MapRadio = self.MapUIBase.MapScalingRadio
    local bFixedAirlineScaleC = self.FixedAirlineScale
    AirlineRouteCanvas:SetRenderTranslation(slua.IndexReference(PlaneRouteData, "CanJumpLocInMap"))
    STExtraMapFunctionLibrary.SetLeftRouteLength(UIRoot.Image_LineUV.Slot, UIRoot.Image_PassedRoute.Slot, PlaneRouteData.PlaneFlyingProcess, PlaneRouteData.RouteLengthInMap, MapRadio, bFixedAirlineScaleC)
  elseif self.MapUIBase.bIsShowAirPlaneRouteAfteHide and self.AirlineVisible then
    local AirlineRouteCanvas = self.UIRoot.CanvasPanel_Airline
    local MapRadio = self.MapUIBase.MapScalingRadio
    local bFixedAirlineScaleC = self.FixedAirlineScale
    AirlineRouteCanvas:SetRenderTranslation(slua.IndexReference(PlaneRouteData, "LastValidCanJumpLocInMap"))
    STExtraMapFunctionLibrary.SetLeftRouteLength(UIRoot.Image_LineUV.Slot, UIRoot.Image_PassedRoute.Slot, 1, PlaneRouteData.LastValidRouteLengthInMap, MapRadio, bFixedAirlineScaleC)
  end
  if self.MarkParachuteVisable and self.AimCenterPointLength then
    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
    local uPlayerController = GameplayData.GetPlayerController()
    if not slua.isValid(uPlayerController) then
      return
    end
    local PS = uPlayerController:GetCurPlayerState()
    if not slua.isValid(PS) then
      PS = uPlayerController.PlayerState
    end
    local AirPlaneInAimPath = true
    if slua.isValid(PS.Plane) then
      local Start = PS:GetAirplaneStartLoc()
      local AirPlanePos = PS.Plane:K2_GetActorLocation()
      AirPlaneInAimPath = false
      if self:getPointInStartandEnd(Start, self.MarkEnd, AirPlanePos) or self:getPointInStartandEnd(Start, self.MarkStart, AirPlanePos) then
        AirPlaneInAimPath = true
      end
    end
    if AirPlaneInAimPath then
      local LevelLandScapeCenterC = slua.IndexReference(self.MapUIBase, "LevelLandScapeCenterC")
      local LevelToMapScale = self.MapUIBase:GetLevelToMapScale()
      local STExtraMapFunctionLibrary = import("STExtraMapFunctionLibrary")
      local NewTranslation = STExtraMapFunctionLibrary.MapCenterToPointVector2D(self.AimCenterPoint, LevelLandScapeCenterC, LevelToMapScale)
      self.UIRoot.Image_JumpMark:SetRenderTranslation(NewTranslation)
      self.UIRoot.Image_JumpMark.Slot:SetSize(FVector2D(self.AimCenterPointLength * LevelToMapScale, 20))
      self.UIRoot.Image_JumpMark_Glow:SetRenderTranslation(NewTranslation)
      self.UIRoot.Image_JumpMark_Glow.Slot:SetSize(FVector2D(self.AimCenterPointLength * LevelToMapScale, 22))
      self.UIRoot.CanvasPanel_IconAndTip:SetRenderTranslation(NewTranslation)
    else
      self:SetVisible(self.UIRoot.Image_JumpMark, false)
      self:SetVisible(self.UIRoot.Image_JumpMark_Glow, false)
      self:SetVisible(self.UIRoot.CanvasPanel_IconAndTip, false)
    end
  end
end
function AirLineUI:CheckShowIconAfterInit()
  print(bWriteLog and "AirLineUI:CheckShowIconAfterInit")
  self.MapUIBase:ReCalMapInfoC()
  local PlaneRouteData = self.PlaneRouteData
  if PlaneRouteData and (PlaneRouteData.PlaneFlyingProcess > 0 or slua.IndexReference(PlaneRouteData, "PlaneLocInMap") ~= FVector2D(0, 0)) then
    self:ShowAirIcon()
  end
end
function AirLineUI:EntrieMapTick()
  local AirlineRouteCanvas = self.UIRoot.CanvasPanel_Airline
  local AirIcon = self.UIRoot.Image_AirIcon
  if self.FixedAirlineScale then
    local NewSizeY = AirlineRouteCanvas.Slot:GetSize().Y
    local NewSizeX = 0
    local PlaneRouteData = self.PlaneRouteData
    if self.MapUIBase.bIsShowAirPlaneRouteAfteHide then
      NewSizeX = PlaneRouteData.LastValidRouteLengthInMap
    else
      NewSizeX = PlaneRouteData.RouteLengthInMap
    end
    if self.AirlineVisible then
      AirlineRouteCanvas.Slot:SetSize(FVector2D(NewSizeX, NewSizeY))
    end
  else
    if self.AirLineScale and self.AirIconVisible then
      local NewScale = (self.MapUIBase.MapScalingRadio - 1) * self.AirLineScale + 1
      AirIcon:SetRenderScale(FVector2D(NewScale, NewScale))
    end
    if self.AirlineVisible then
      local RouteNewScale = self.MapUIBase.MapScalingRadio
      local CircleScale = RouteNewScale < 2 and 1 / RouteNewScale or 0.5
      AirlineRouteCanvas:SetRenderScale(FVector2D(RouteNewScale, RouteNewScale))
      self.UIRoot.Image_End:SetRenderScale(FVector2D(CircleScale, CircleScale))
      self.UIRoot.Image_Start:SetRenderScale(FVector2D(CircleScale, CircleScale))
    end
  end
end
function AirLineUI:ShowAirIcon()
  if not slua.isValid(self.MapUIBase) or not slua.isValid(self.PlaneRouteData) then
    return
  end
  local PlaneRouteData = self.PlaneRouteData
  if slua.IndexReference(PlaneRouteData, "CanJumpLocInMap"):IsZero() and slua.IndexReference(PlaneRouteData, "ForceJumpLocInMap"):IsZero() or self.bIsForceHideAirIcon then
    self:SetAirIconVisibility(false)
  else
    self:SetAirIconVisibility(true)
  end
end
function AirLineUI:HideAirIcon()
  self:SetAirIconVisibility(false)
end
function AirLineUI:ForceHideAirIcon()
  self.bIsForceHideAirIcon = true
  self:SetAirIconVisibility(false)
end
function AirLineUI:SetAirIconVisibility(IsShow)
  self.AirIconVisible = IsShow
  self:SetVisible(self.UIRoot.Image_AirIcon, IsShow)
  if not IsShow and not self.AirlineVisible and self.TickWidgetTimer then
    self:RemoveGameTimer(self.TickWidgetTimer)
    self.TickWidgetTimer = nil
  end
  if IsShow then
    self.UIRoot.Image_AirIcon:SetRenderAngle(self.PlaneRouteData.PlaneRotation)
  end
end
function AirLineUI:SetArilineGroupVisibility(IsShow)
  self.AirlineVisible = IsShow
  self:SetVisible(self.UIRoot.CanvasPanel_Airline, IsShow)
  print(bWriteLog and "AirLineUI:SetArilineGroupVisibility:" .. tostring(IsShow))
  if IsShow and not self.MapUIBase.bIsShowAirPlaneRouteAfteHide and not self.TickWidgetTimer and self:IsNeedTick() then
    print(bWriteLog and "AirLineUI:SetArilineGroupVisibility ADD TIMER")
    self.TickWidgetTimer = self:AddGameTimer(self.TickRat, true, function()
      self:TickWidget()
    end)
  end
end
function AirLineUI:GetArilineGroupVisibility()
  if self.UIRoot.CanvasPanel_Airline:GetVisibility() == UEnums.ESlateVisibility.SelfHitTestInvisible then
    return true
  else
    return false
  end
end
function AirLineUI:SetVisible(UI, IsVisible)
  if IsVisible then
    UI:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    UI:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function AirLineUI:ReFreshVisible()
  if self:CheckIsCanShow() and self.bInitSuccess ~= false then
    self:SetVisible(self.UIRoot, true)
  else
    self:SetVisible(self.UIRoot, false)
  end
end
function AirLineUI:CheckIsCanShow()
  return self.bIsCanShow or self.bIsCanShow == nil
end
function AirLineUI:ReShowAirplaneRoute()
  print(bWriteLog and "AirLineUI:ReShowAirplaneRoute")
  local UIUtil = require("client.common.ui_util")
  local uGameState = UGameplayStatics.GetGameState(UIUtil.GetGameInstance())
  if not slua.isValid(uGameState) then
    print(bWriteLog and "AirLineUI:ReShowAirplaneRoute False Case GAMESTATE Is Nil")
    self:SetArilineGroupVisibility(false)
    return
  end
  if not self.MapUIBase.bIsShowAirPlaneRouteAfteHide then
    self:SetArilineGroupVisibility(false)
    return
  end
  local PlaneRouteData = self.PlaneRouteData
  print(bWriteLog and "AirLineUI:ReShowAirplaneRoute PlaneRouteData.LastValidRouteLengthInMap : " .. tostring(PlaneRouteData.LastValidRouteLengthInMap))
  if PlaneRouteData.LastValidRouteLengthInMap > 0 then
    self.AirlineVisible = true
    self:UpdateRoute()
    self:UpdateRouteBothMap()
    local MapRadio = self.MapUIBase.MapScalingRadio
    local bFixedAirlineScaleC = self.FixedAirlineScale
    STExtraMapFunctionLibrary.SetLeftRouteLength(self.UIRoot.Image_LineUV.Slot, self.UIRoot.Image_PassedRoute.Slot, 1, PlaneRouteData.LastValidRouteLengthInMap, MapRadio, bFixedAirlineScaleC)
    self:SetArilineGroupVisibility(true)
    self:ReFreshVisible()
    self:SetAirIconVisibility(false)
  end
end
function AirLineUI:ForceRefreshAirLine(IsRefreshMiniMap)
  if IsRefreshMiniMap ~= self.IsMiniMap then
    if not self:IsNeedTick() then
      return
    end
    self:CommonTick()
    if not self.IsMiniMap then
      self:EntrieMapTick()
    end
  end
end
function AirLineUI:OnEnterMap(isEntireMap)
  print(bWriteLog and "AirLineUI:OnEnterMap \239\188\154 " .. tostring(isEntireMap) .. "  : " .. tostring(self.IsMiniMap))
  if isEntireMap ~= self.IsMiniMap then
    self.MapUIBase:ReCalMapInfoC()
    self:TickWidget()
    if not self.TickWidgetTimer and self.AirIconVisible then
      self.TickWidgetTimer = self:AddGameTimer(self.TickRat, true, function()
        self:TickWidget()
      end)
    end
  elseif self.TickWidgetTimer then
    self:RemoveGameTimer(self.TickWidgetTimer)
    self.TickWidgetTimer = nil
  end
end
function AirLineUI:UpdateMarkParachuteVisable()
  local uPlayerController = GameplayData.GetPlayerController()
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  self.MarkParachuteVisable = false
  if not (slua.isValid(CGameState) and slua.isValid(uPlayerCharacter) and slua.isValid(uPlayerController)) or uPlayerController:IsObserver() or uPlayerController:IsSpectator() or not slua.isValid(uPlayerController.PlayerState) then
    self:SetVisible(self.UIRoot.Image_JumpMark, false)
    self:SetVisible(self.UIRoot.Image_JumpMark_Glow, false)
    self:SetVisible(self.UIRoot.CanvasPanel_IconAndTip, false)
    return false
  end
  local sGameModeState = CGameState:GetGameModeState()
  if not uPlayerController:IsInPlane() and sGameModeState ~= "ReadyState" then
    self:SetVisible(self.UIRoot.Image_JumpMark, false)
    self:SetVisible(self.UIRoot.Image_JumpMark_Glow, false)
    self:SetVisible(self.UIRoot.CanvasPanel_IconAndTip, false)
    return false
  end
  local LightCrossPos = uPlayerController.PlayerState:GetMapMark3DLocation()
  if LightCrossPos.X > -0.1 and LightCrossPos.X < 0.1 and 0.1 > LightCrossPos.Y and -0.1 < LightCrossPos.Y then
    self:SetVisible(self.UIRoot.Image_JumpMark, false)
    self:SetVisible(self.UIRoot.Image_JumpMark_Glow, false)
    self:SetVisible(self.UIRoot.CanvasPanel_IconAndTip, false)
    return false
  end
  local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
  local bAutoParachuteOptionOpen = SettingModule:GetOptionValue("AutoParachute")
  local ParachuteJumpPathMark = SettingModule:GetOptionValue("ParachuteJumpPathMark")
  if not ParachuteJumpPathMark and not uPlayerCharacter.bGuideMarkParacheCanOpen then
    self:SetVisible(self.UIRoot.Image_JumpMark, false)
    self:SetVisible(self.UIRoot.Image_JumpMark_Glow, false)
    self:SetVisible(self.UIRoot.CanvasPanel_IconAndTip, false)
    return false
  end
  self:SetVisible(self.UIRoot.Image_JumpMark, true)
  self:SetVisible(self.UIRoot.Image_JumpMark_Glow, true)
  self:SetVisible(self.UIRoot.CanvasPanel_IconAndTip, true)
  self.MarkParachuteVisable = true
  return true
end
function AirLineUI:MarkParachuteLocation(__, __)
  local uPlayerController = GameplayData.GetPlayerController()
  EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_MAP_IMMEDIATE_GUIDE)
  if not self:UpdateMarkParachuteVisable() then
    return
  end
  if not slua.isValid(uPlayerController) then
    return
  end
  local PS = uPlayerController:GetCurPlayerState()
  if not slua.isValid(PS) then
    PS = uPlayerController.PlayerState
  end
  local Start = PS:GetCanJumpLoc()
  local Stop = PS:GetForceJumpLoc()
  local LightCrossPos = PS:GetMapMark3DLocation()
  local FootPointX, FootPointY = self:getFootPoint(LightCrossPos.X, LightCrossPos.Y, Start.X, Start.Y, Stop.X, Stop.Y)
  self:GetMarkParachuteLocationConfig()
  local CenterPointDistance = math.sqrt(math.abs(self.MarkParachuteLocationConfig.ConstantC * self.MarkParachuteLocationConfig.ConstantC - FVector2D.DistSquared(FVector2D(LightCrossPos.X, LightCrossPos.Y), FVector2D(FootPointX, FootPointY))))
  self.AimCenterPoint = FVector(0, 0, Start.Z)
  self.AimCenterPointLength = self.MarkParachuteLocationConfig.ConstantD
  local AimCenterPointX, AimCenterPointY = self:getPointAtDistanceFromA(FootPointX, FootPointY, Start.X, Start.Y, CenterPointDistance)
  self.AimCenterPoint.X = AimCenterPointX
  self.AimCenterPoint.Y = AimCenterPointY
  self.MarkStart, self.MarkEnd = self:getStartEndPointsFromCenter(FVector(Start.X, Start.Y, Start.Z), FVector(Stop.X, Stop.Y, Stop.Z), self.AimCenterPoint, self.AimCenterPointLength)
  if not self:getPointInStartandEnd(Start, Stop, self.MarkStart) or not self:getPointInStartandEnd(Start, Stop, self.MarkEnd) then
    self:SetVisible(self.UIRoot.Image_JumpMark, false)
    self:SetVisible(self.UIRoot.Image_JumpMark_Glow, false)
    self:SetVisible(self.UIRoot.CanvasPanel_IconAndTip, false)
    self.MarkParachuteVisable = false
  end
  self:CommonTick()
  print(bWriteLog and "Start:" .. Start:ToString() .. "end:" .. Stop:ToString() .. "self.AimCenterPoint:" .. self.AimCenterPoint:ToString())
end
function AirLineUI:getPointInStartandEnd(satrtPooint, endPoint, Checkpoint)
  local minX, maxX = math.min(satrtPooint.X, endPoint.X), math.max(satrtPooint.X, endPoint.X)
  local minY, maxY = math.min(satrtPooint.Y, endPoint.Y), math.max(satrtPooint.Y, endPoint.Y)
  return Checkpoint.X >= minX - 1.0E-8 and Checkpoint.X <= maxX + 1.0E-8 and Checkpoint.Y >= minY - 1.0E-8 and Checkpoint.Y <= maxY + 1.0E-8
end
function AirLineUI:getStartEndPointsFromCenter(satrtPooint, endPoint, centerpoint, length)
  local direction = (endPoint - satrtPooint):GetSafeNormal(1.0E-6)
  if direction:Size() == 0 then
    return centerpoint, centerpoint
  end
  local halfD = length / 2
  local point1 = centerpoint + direction * halfD
  local point2 = centerpoint - direction * halfD
  return point1, point2
end
function AirLineUI:getPointAtDistanceFromA(ax, ay, bx, by, C, clamp)
  local dx = bx - ax
  local dy = by - ay
  local d_squared = dx * dx + dy * dy
  if d_squared < 1.0E-10 then
    return ax, ay
  end
  local d = math.sqrt(d_squared)
  local t = C / d
  if clamp then
    t = math.max(0, math.min(1, t))
  end
  local px = ax + dx * t
  local py = ay + dy * t
  return px, py
end
function AirLineUI:getFootPoint(px, py, lx1, ly1, lx2, ly2)
  local A = ly2 - ly1
  local B = lx1 - lx2
  local C = lx2 * ly1 - lx1 * ly2
  if A * A + B * B < 1.0E-13 then
    return lx1, ly1
  end
  if 1.0E-13 > math.abs(A * px + B * py + C) then
    return px, py
  end
  local denominator = A * A + B * B
  local x = (B * B * px - A * B * py - A * C) / denominator
  local y = (-A * B * px + A * A * py - B * C) / denominator
  local minX, maxX = math.min(lx1, lx2), math.max(lx1, lx2)
  local minY, maxY = math.min(ly1, ly2), math.max(ly1, ly2)
  x = FuncUtil.Clamp(x, minX, maxX)
  y = FuncUtil.Clamp(y, minY, maxY)
  return x, y
end
function AirLineUI:GetMarkParachuteLocationConfig()
  if self.MarkParachuteLocationConfig then
    return self.MarkParachuteLocationConfig
  else
    self.MarkParachuteLocationConfig = AirLineUI.MarkLocationJumpInfo.Default
    if slua.isValid(CGameState) and CGameState.GetCurrentModeType then
      local ModeType = CGameState:GetCurrentModeType()
      print(bWriteLog and "AirLineUI:GetMarkParachuteLocationConfig ModeType: " .. tostring(ModeType) or "")
      if ModeType and AirLineUI.MarkLocationJumpInfo[ModeType] then
        self.MarkParachuteLocationConfig = AirLineUI.MarkLocationJumpInfo[ModeType]
      end
    end
    return self.MarkParachuteLocationConfig
  end
end
function AirLineUI:OnClose()
  print(bWriteLog and "AirLineUI:OnClose")
  AirLineUI.__super.OnClose(self)
end
local class = require("class")
local UIBase = require("GameLua.Mod.BaseMod.Client.Map.MapWidget.MapWidgetBase")
local CAirLineUI = class(UIBase, nil, AirLineUI)
return CAirLineUI