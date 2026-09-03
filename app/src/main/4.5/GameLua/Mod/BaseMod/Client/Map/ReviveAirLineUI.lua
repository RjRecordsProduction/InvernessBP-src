local ReviveAirLineUI = {}
function ReviveAirLineUI:ctor()
  self.TickRat = 0.05
end
function ReviveAirLineUI:RegistEvents()
  print(bWriteLog and "ReviveAirLineUI:RegistEvents")
  ReviveAirLineUI.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_DEATH_MATCH_UI_SETTING, self.UpdateRouteWhenIsMiniMap, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_GAMEPLAY_SYNC_PLAYERSTATE, self.UpdateRouteWhenIsMiniMap, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_ENTIRE_MAP_SHOW_RESIZE_MINIMAP, self.UpdateRouteWhenIsMiniMap, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_MAP_AIRLINE_ROUTE_UPDATE, self.UpdateRouteByEvent, self)
end
function ReviveAirLineUI:BindMapUIBase(MapUI, IsMiniMap)
  if MapUI then
    print(bWriteLog and "ReviveAirLineUI:BindMapUIBase, self.IsMiniMap = " .. tostring(IsMiniMap))
    self.MapUIBase = MapUI.CurrentMapUI
    self.    self.    self:InitAirlineWithMapType(IsMiniMap)
    self.AirIconVisible = false
    self.AirlineVisible = true
    self:BindLuaObjEvent(MapUI, "OnEntireMapOpen", self.OnEnterMap, self)
    self:BindLuaObjEvent(MapUI, "OnChangeMapSize", self.UpdateRouteBothMap, self)
    self:BindLuaObjEvent(MapUI, "ForceRefreshAirLine", self.ForceRefreshAirLine, self)
    self:BindLuaObjEvent(MapUI, "UpdateReviveAirline", self.UpdateReviveAirline, self)
  else
    print(bWriteLog and "ReviveAirLineUI:BindMapUIBase, MapUI = nil")
  end
end
function ReviveAirLineUI:UpdateReviveAirline(bIsUpdate)
  if bIsUpdate then
    self:UpdateRoute()
  else
    self:StopTick()
    self:Collapsed()
  end
end
function ReviveAirLineUI:InitAirlineWithMapType(IsMiniMap)
  print(bWriteLog and "ReviveAirLineUI:InitAirlineWithMapType")
  self.AirLineScale = 1
  self.FixedAirlineScale = true
  if IsMiniMap then
    self.FixedAirlineScale = true
    self.UIRoot.Image_Start.Slot:SetSize(FVector2D(6, 6))
    self.UIRoot.Image_End.Slot:SetSize(FVector2D(8, 8))
    if self.RepositionItemOnMapDel then
      if self.MapUIBase then
        self.MapUIBase.OnRepositionItemOnMap:Remove(self.RepositionItemOnMapDel)
      end
      self.RepositionItemOnMapDel = nil
    end
    self.RepositionItemOnMapDel = self.MapUIBase.OnRepositionItemOnMap:Add(function()
      self:UpdateRouteWhenIsMiniMap()
    end)
  else
    self.UIRoot.Image_Start.Slot:SetSize(FVector2D(12, 12))
    self.UIRoot.Image_End.Slot:SetSize(FVector2D(16, 16))
    local CurGameModeID = Client.GetGameModeID(GameFrontendHUD)
    local ModeTableData = CDataTable.GetTableData("BTMode", CurGameModeID)
    if ModeTableData then
      self.AirLineScale = ModeTableData.AirlineCoefficient / 100.0
      self.FixedAirlineScale = self.AirLineScale > 0.999
    end
  end
end
function ReviveAirLineUI:OnUnRegistEvents()
  print(bWriteLog and "ReviveAirLineUI:OnUnRegistEvents")
  if self.RepositionItemOnMapDel then
    if self.MapUIBase then
      self.MapUIBase.OnRepositionItemOnMap:Remove(self.RepositionItemOnMapDel)
    end
    self.RepositionItemOnMapDel = nil
  end
end
function ReviveAirLineUI:UpdateRouteWhenIsMiniMap()
  if self:IsNeedTick() and self.IsMiniMap and self.AirlineVisible then
    print(bWriteLog and "ReviveAirLineUI:UpdateRouteWhenIsMiniMap")
    self.MapUI:CalculateRouteInfo()
    self:UpdateRoute()
  end
end
function ReviveAirLineUI:InitUI(ParentUI)
  if ParentUI and ParentUI.UIRoot.CommonFunctionAddPanel then
    if self:CheckIsCanShow() then
      self:SetVisible(self.UIRoot, true)
    else
      self:SetVisible(self.UIRoot, false)
    end
    ParentUI:AttachChildWindow("CommonFunctionAddPanel", self)
    self.UIRoot.Slot:SetAnchors(FAnchors(0, 0, 1, 1))
    self.UIRoot.Slot:SetOffsets(FMargin(0, 0, 0, 0))
    self:SetVisible(self.UIRoot.CanvasPanel_Airline, false)
    self:SetVisible(self.UIRoot.Image_AirIcon, false)
    self:SetVisible(self.UIRoot.Image_JumpMark, false)
    self:SetVisible(self.UIRoot.Image_JumpMark_Glow, false)
    self:SetVisible(self.UIRoot.CanvasPanel_IconAndTip, false)
    print(bWriteLog and "ReviveAirLineUI:InitUI, self.IsMiniMap = " .. tostring(self.IsMiniMap))
  else
    self:SetVisible(self.UIRoot, false)
    print(bWriteLog and "ReviveAirLineUI:InitUI, CommonFunctionAddPanel = nil when self.IsMiniMap = " .. tostring(self.IsMiniMap))
  end
end
function ReviveAirLineUI:IsNeedTick()
  if self.MapUI.bIsShow and self.MapUI.ReviveAirlineInfo then
    return true
  else
    return false
  end
end
function ReviveAirLineUI:TickWidget()
  self:CommonTick()
  if not self.IsMiniMap then
    self:EntrieMapTick()
  end
end
function ReviveAirLineUI:CommonTick()
  self.MapUI:CalculatePlaneInfo()
  self:UpdateRoute()
  local PlaneRouteData = self.MapUI.ReviveRouteInfo
  if PlaneRouteData == nil then
    return
  end
  local UIRoot = self.UIRoot
  if self.AirIconVisible then
    local Plane = self.MapUI.ReviveAirlineInfo.Plane
    if Plane and slua.isValid(Plane) then
      local AirIcon = UIRoot.Image_AirIcon
      AirIcon:SetRenderTranslation(PlaneRouteData.PlaneLocInMap)
      self:SetVisible(UIRoot.Image_AirIcon, true)
    else
      self:SetVisible(UIRoot.Image_AirIcon, false)
    end
  end
  if self.AirlineVisible then
    local AirlineRouteCanvas = self.UIRoot.CanvasPanel_Airline
    self:SetVisible(AirlineRouteCanvas, true)
    AirlineRouteCanvas:SetRenderTranslation(PlaneRouteData.CanJumpLocInMap)
    if UIRoot.Image_LineUV.Slot and slua.isValid(UIRoot.Image_LineUV.Slot) then
      local MapRadio = self.MapUIBase.MapScalingRadio
      local bFixedAirlineScaleC = self.FixedAirlineScale
      local USTExtraMapFunctionLibrary = import("STExtraMapFunctionLibrary")
      USTExtraMapFunctionLibrary.SetLeftRouteLength(UIRoot.Image_LineUV.Slot, UIRoot.Image_PassedRoute.Slot, PlaneRouteData.PlaneFlyingProcess, PlaneRouteData.RouteLengthInMap, MapRadio, bFixedAirlineScaleC)
    else
      print(bWriteLog and "ReviveAirLineUI:CommonTick, Image_LineUV.Slot = " .. tostring(UIRoot.Image_LineUV.Slot))
    end
  end
end
function ReviveAirLineUI:EntrieMapTick()
  local AirlineRouteCanvas = self.UIRoot.CanvasPanel_Airline
  if self.FixedAirlineScale then
    local PlaneRouteData = self.MapUI.ReviveRouteInfo
    if PlaneRouteData then
      local NewSizeX = PlaneRouteData.RouteLengthInMap
      local NewSizeY = AirlineRouteCanvas.Slot:GetSize().Y
      if self.AirlineVisible then
        AirlineRouteCanvas.Slot:SetSize(FVector2D(NewSizeX, NewSizeY))
      end
    end
  else
    if self.AirIconVisible then
      local AirIcon = self.UIRoot.Image_AirIcon
      local NewScale = (self.MapUIBase.MapScalingRadio - 1) * self.AirLineScale + 1
      AirIcon:SetRenderScale(FVector2D(NewScale, NewScale))
    end
    if self.AirlineVisible then
      local RouteNewScale = self.MapUIBase.MapScalingRadio
      AirlineRouteCanvas:SetRenderScale(FVector2D(RouteNewScale, RouteNewScale))
    end
  end
end
function ReviveAirLineUI:UpdateRouteByEvent()
  print(bWriteLog and "ReviveAirLineUI:UpdateRouteByEvent, self.IsMiniMap = " .. tostring(self.IsMiniMap))
  self:UpdateRoute()
end
function ReviveAirLineUI:UpdateRoute()
  if self.MapUI == nil or self.MapUI.ReviveAirlineInfo == nil then
    self:StopTick()
    self:SetVisible(self.UIRoot, false)
    print(bWriteLog and "ReviveAirLineUI:UpdateRoute, SetVisible(false)")
    return
  end
  print(bWriteLog and "ReviveAirLineUI:UpdateRoute, self.IsMiniMap = " .. tostring(self.IsMiniMap))
  self:SetVisible(self.UIRoot, true)
  local Callback = function(AirlineRouteCanvas)
    self.MapUI:CalculateRouteInfo()
    local PlaneRouteData = self.MapUI.ReviveRouteInfo
    if self.AirlineVisible then
      self:SetVisible(AirlineRouteCanvas, true)
      AirlineRouteCanvas:SetRenderTranslation(PlaneRouteData.CanJumpLocInMap)
      AirlineRouteCanvas:SetRenderAngle(PlaneRouteData.RouteWidgetRotateAngle)
      local NewSizeX = PlaneRouteData.RouteLengthInMap
      local NewSizeY = AirlineRouteCanvas.Slot:GetSize().Y
      if not self.FixedAirlineScale then
        local MapRadio = self.MapUIBase.MapScalingRadio
        NewSizeX = NewSizeX / MapRadio
      end
      AirlineRouteCanvas.Slot:SetSize(FVector2D(NewSizeX, NewSizeY))
    end
    print(bWriteLog and "ReviveAirLineUI:UpdateRoute,PlaneRotation", self.AirIconVisible, PlaneRouteData.PlaneRotation)
    if self.AirIconVisible then
      self.UIRoot.Image_AirIcon:SetRenderAngle(PlaneRouteData.PlaneRotation)
    end
    self:StartTick()
  end
  local AirlineRouteCanvas = self.UIRoot.CanvasPanel_Airline
  if AirlineRouteCanvas.Slot and AirlineRouteCanvas.Slot.GetSize then
    Callback(AirlineRouteCanvas)
  else
    self:AddTimer(0, function()
      print(bWriteLog and "ReviveAirLineUI:UpdateRoute, next frame in timer")
      Callback(AirlineRouteCanvas)
    end)
  end
end
function ReviveAirLineUI:StartTick()
  if not self.TickWidgetTimer and self:IsNeedTick() then
    print(bWriteLog and "ReviveAirLineUI:StartTick, self.IsMiniMap = " .. tostring(self.IsMiniMap))
    self.TickWidgetTimer = self:AddGameTimer(self.TickRat, true, function()
      self:TickWidget()
    end)
  end
end
function ReviveAirLineUI:StopTick()
  if self.TickWidgetTimer then
    print(bWriteLog and "ReviveAirLineUI:StopTick, self.IsMiniMap = " .. tostring(self.IsMiniMap))
    self:RemoveGameTimer(self.TickWidgetTimer)
    self.TickWidgetTimer = nil
  end
end
function ReviveAirLineUI:ReFreshVisible()
  print(bWriteLog and "ReviveAirLineUI:ReFreshVisible, self.IsMiniMap = " .. tostring(self.IsMiniMap))
  if self:CheckIsCanShow() then
    self:SetVisible(self.UIRoot, true)
  else
    self:SetVisible(self.UIRoot, false)
  end
end
function ReviveAirLineUI:SetVisible(UI, IsVisible)
  if IsVisible then
    UI:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    UI:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function ReviveAirLineUI:CheckIsCanShow()
  local result = false
  if self.MapUI and self.MapUI.ReviveAirlineInfo ~= nil then
    result = true
  end
  return result
end
function ReviveAirLineUI:UpdateRouteBothMap()
  self:ForceRefreshAirLine()
end
function ReviveAirLineUI:ForceRefreshAirLine()
  if not self:IsNeedTick() then
    return
  end
  self.MapUI:CalculateRouteInfo()
  self:TickWidget()
end
function ReviveAirLineUI:OnEnterMap(isEntireMap)
  print(bWriteLog and "ReviveAirLineUI:OnEnterMap, isEntireMap = " .. tostring(isEntireMap) .. ", self.IsMiniMap = " .. tostring(self.IsMiniMap))
  if isEntireMap ~= self.IsMiniMap then
    self.MapUI:CalculateRouteInfo()
    self:TickWidget()
    self:StartTick()
  else
    self:StopTick()
  end
end
function ReviveAirLineUI:Close()
  print(bWriteLog and "ReviveAirLineUI:Close")
  self:StopTick()
  ReviveAirLineUI.__super.Close(self)
end
local class = require("class")
local UIBase = require("GameLua.Mod.BaseMod.Client.Map.MapWidget.MapWidgetBase")
local CReviveAirLineUI = class(UIBase, nil, ReviveAirLineUI)
return CReviveAirLineUI