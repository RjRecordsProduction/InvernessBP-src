local MapUIBase = {
  LuaEventContainer = {
    "NeedInnerCircle",
    "OnEntireMapOpen",
    "OnChangeMapSize",
    "ForceHideAirIcon",
    "OnRefreshMapIcon",
    "OnSyncCircleInfo",
    "RedrawHighDropArea",
    "RedrawAirAttackArea",
    "ForceRefreshAirLine",
    "UpdateReviveAirline",
    "ReShowAirplaneRoute",
    "AfterInitMapStandard",
    "OnPlayerLeaveVehicle",
    "OnCloseCustomBlueWidget",
    "UpdateAirplaneRouteShow",
    "RedrawCustomAirAttackArea",
    "OnReceivedCustomBlueCircle",
    "UpdateSecondAirplaneRouteShow"
  }
}
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
local slua_isValid = slua.isValid
local EGameModeType = import("EGameModeType")
local GameplayStatics = import("/Script/Engine.GameplayStatics")
local KismetSystemLibrary = import("/Script/Engine.KismetSystemLibrary")
local GameBackendHUD = import("/Script/Client.GameBackendHUD")
local STExtraDelegateMgr = import("/Script/ShadowTrackerExtra.STExtraDelegateMgr")
local STExtraBlueprintFunctionLibrary = import("/Script/ShadowTrackerExtra.STExtraBlueprintFunctionLibrary")
local MapUIUtils = require("GameLua.Mod.BaseMod.Client.Map.MapUI.MapUIUtil")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
function MapUIBase:ctor()
  print(bWriteLog and "MapUIBase:ctor")
  MapUIBase.__super.ctor(self)
  self.TeamMarkIndexMap = {}
  self.DefaultMapPath = nil
  self.MapWidgets = {}
end
function MapUIBase:OnDestroy()
  print(bWriteLog and "MapUIBAse:OnDestroy")
  self:ClearWidgets()
  if slua.isValid(self.CurrentMapData_BP) then
    self.CurrentMapData_BP:OnDestroy()
  end
  self.STExtraPlayerController = nil
  self.DefaultMapPath = nil
  self:UnRegistBPEvents()
  self:Dispose()
end
function MapUIBase:ClearWidgets()
  print(bWriteLog and "MapUIBAse:ClearWidgets")
  self.MapWidgetLua = nil
  self.HasBinRegist = nil
  self.DefaultMapPath = nil
  for _, Widget in ipairs(self.MapWidgets) do
    if Widget and self[Widget] then
      self[Widget]:Close()
      self[Widget] = nil
    end
  end
end
function MapUIBase:SetData(param)
  if not param then
    return
  end
  self.DefaultMapPath = param.DefaultMapPath
end
function MapUIBase:RegisterDelegate()
  GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerEnterFlying", self.HandleOnPlayerEnterFlying, self)
  self:RegistDelegateInLua()
end
function MapUIBase:RegistDelegateInLua()
  print(bWriteLog and " MapUIBase:RegistDelegateInLua")
  if not self.HasBinRegist then
    self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_SYNC_CIRCILE_INFO, self.OnSyncCircleInfo, self)
    self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_ON_UPDATE_AIRDROP_PATH_DATA, self.UpdateAirDropLine, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_MAP_SHOW_OR_HIDE_WHITE_CIRCLE, self.SetIsDrawWhiteCircle, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_MAP_SHOW_OR_HIDE_WHITE_CIRCLE_GUID_LINE, self.SetIsDrawWhiteCircleGuideLine, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_MAP_REVIVE_AIRLINE_INFO, self.OnReceivedReviveAirlineInfo, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_MAP_SECONDE_AIRLINE_INFO, self.OnReceivedSecondAirlineInfo, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_MAP_ON_CREATE_CUSTOM_BLUE_CIRCLE, self.OnReceivedCustomBlueCircle, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_MAP_ON_CLOSE_CUSTOM_BLUE_CIRCLE, self.CloseCustomBlueWidget, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_REFRESHMAPICON_TRANSLATION, self.HandleRefreshMapIcon, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_REFRESH_MAP_MARK, self.RefreshAllMarks, self)
    self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_RECEIVED_AIR_ATTACK, self.OnReceivedAirAttack, self)
    self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_MAP_SHOW_OR_HIDE_COMMONAIRLINE, self.CreateCommonAirlineWidget, self)
    self:AddCommonEvent(EVENTTYPE_MAP, EVENTID_HIGH_DROP, self.CheckHighDropArea, self)
    if self.bIsMiniMap then
      self:AddCommonEvent(EVENTTYPE_INGAME_UI, EVENTID_INGAME_ON_SET_CUSTOMIZE_UIINFO, self.SetCustomSetting, self)
    end
    self.HasBinRegist = true
  end
  GameplayData.AddSelfPlayerControllerEvent(self, "ClientOnLeaveVehicle", self.OnPlayerLeaveVehicle, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnSpectatorChange", self.OnSpectatorChanged, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnPlayerQuitSpectatingForClient", self.RefreshAllIcon, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnReconnectResetUIByPlayerControllerStateDelegate", self.OnReconnect, self)
  GameplayData.AddGameStateEvent(self, "OnAirAttack", self.HandleAirAttackBroadcast, self)
end
function MapUIBase:OnReceivedReviveAirlineInfo(_, _, param)
  self.ReviveAirlineInfo = nil
  if param ~= nil then
    self.ReviveAirlineInfo = {}
    self.ReviveAirlineInfo.PlaneStartLoc = FVector(param.start_x, param.start_y, 0)
    self.ReviveAirlineInfo.PlaneEndLoc = FVector(param.end_x, param.end_y, 0)
    self.ReviveAirlineInfo.Plane = nil
    print(bWriteLog and "MapUIBase:OnReceivedReviveAirlineInfo, param.Plane = " .. tostring(param.plane))
    print(bWriteLog and "MapUIBase:OnReceivedReviveAirlineInfo, ReviveAirlineInfo.Plane = " .. tostring(self.ReviveAirlineInfo.Plane))
  else
    print(bWriteLog and "MapUIBase:OnReceivedReviveAirlineInfo, param = nil")
  end
  self:UpdateReviveAirline()
end
function MapUIBase:OnReceivedSecondAirlineInfo(_, _, OneFlightInfo)
  self.SecondAirlineInfo = nil
  if OneFlightInfo ~= nil then
    self.SecondAirlineInfo = {}
    self.SecondAirlineInfo.PlaneStartLoc = OneFlightInfo.AirplaneCanJumpLoc:clone()
    self.SecondAirlineInfo.PlaneEndLoc = OneFlightInfo.AirplaneForceJumpLoc:clone()
    self.SecondAirlineInfo.Plane = OneFlightInfo.Plane
    if self.CurrentMapUI then
      self.CurrentMapUI:ReCalMapInfoC()
    end
    if self.bInitNeedInfoBackShow then
      self:UpdateSecondAirplaneRoute(FVector(0, 0, 0), FVector(0, 0, 0), true, false)
    end
    print(bWriteLog and "MapUIBase:OnReceivedSecondAirlineInfo, OneFlightInfo.Plane = " .. tostring(OneFlightInfo.plane))
  else
    print(bWriteLog and "MapUIBase:OnReceivedSecondAirlineInfo, OneFlightInfo = nil")
  end
end
function MapUIBase:OnReceivedAirAttack(_, _, AttackMsg, Wave, AirAttackActor, AirAttackArea)
  if AirAttackActor == nil or AirAttackActor.AirAttack == nil then
    print(bWriteLog and "MapUIBase:OnReceivedAirAttack Error.")
    return
  end
  local Area = FVector(0, 0, 0)
  if AirAttackArea then
    Area = AirAttackArea
  elseif AirAttackActor.AirAttack.AirAttackArea then
    Area = AirAttackActor.AirAttack.AirAttackArea
  end
  local bIsCustomAirAttack = CGameState ~= AirAttackActor
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  if not UKismetSystemLibrary.IsDedicatedServer(self) then
    print(bWriteLog and "MapUIBase:OnReceivedAirAttack bIsCustomAirAttack[" .. tostring(bIsCustomAirAttack) .. "] AttackMsg:" .. tostring(AttackMsg) .. ", Wave:" .. tostring(Wave) .. ", Area:" .. tostring(Area.X) .. "," .. tostring(Area.Y) .. "," .. tostring(Area.Z))
    local EAirAttackInfo = import("EAirAttackInfo")
    if AttackMsg == EAirAttackInfo.Attacking or AttackMsg == EAirAttackInfo.AttackWarningTips then
      if bIsCustomAirAttack then
        self:LuaBroadcast("RedrawCustomAirAttackArea", Area)
      else
        self.LastestAirAttack        self:LuaBroadcast("RedrawAirAttackArea", Area)
      end
      if AttackMsg == EAirAttackInfo.AttackWarningTips and self.bIsMiniMap then
        print(bWriteLog and "MapUIBase:OnReceivedAirAttack AttackWarningTips")
        local bIsCanShowTips = self:IsMapCanSeeAirAttack(Area)
        if bIsCanShowTips then
          IngameTipsTools.BattleGeneralTip(self.AirAttackTipsID or 10022)
        end
      end
    elseif AttackMsg == EAirAttackInfo.AttackOver then
      if bIsCustomAirAttack then
        self:LuaBroadcast("RedrawCustomAirAttackArea", nil)
      elseif self.LastestAirAttackWave == Wave or Wave == -1 then
        print(bWriteLog and "MapUIBase:OnReceivedAirAttack AirAttarAreaWidget false")
        self:LuaBroadcast("RedrawAirAttackArea", nil)
      end
    end
    self.LastAirAttack = Area
  end
end
function MapUIBase:IsMapCanSeeAirAttack(Area)
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(uPlayerCharacter) then
    return false
  end
  if not slua.isValid(self.CurrentMapUI) then
    return false
  end
  local LevelLandScapeCenterC = slua.IndexReference(self.CurrentMapUI, "LevelLandScapeCenterC")
  local LevelToMapScale = self.CurrentMapUI:GetLevelToMapScale()
  local STExtraMapFunctionLibrary = import("/Script/ShadowTrackerExtra.STExtraMapFunctionLibrary")
  local NewTranslation = STExtraMapFunctionLibrary.MapCenterToPointVector2D(Area, LevelLandScapeCenterC, LevelToMapScale)
  NewTranslation = NewTranslation + slua.IndexReference(self.CurrentMapUI, "MapAdjustOffsetC")
  local AirAttackRadius = Area.Z * LevelToMapScale + 68
  local OffsetX = math.abs(NewTranslation.X) - AirAttackRadius
  local OffsetY = math.abs(NewTranslation.Y) - AirAttackRadius
  if 0 < OffsetX or 0 < OffsetY then
    return false
  end
  return true
end
function MapUIBase:GetAirAttackArea()
  return self.LastAirAttack
end
function MapUIBase:ReceivedHighDrop(X, Y, Radius)
  local Area = FVector(X, Y, Radius)
  self:LuaBroadcast("RedrawHighDropArea", Area)
end
function MapUIBase:CheckHighDropArea()
  local uGameState = slua_GameFrontendHUD:GetGameState()
  if not (uGameState and slua.isValid(uGameState) and uGameState.BP_HighDropCircleComp) or not uGameState.BP_HighDropCircleComp.GetHighDorpRadius then
    return
  end
  local HighDropRadius = uGameState.BP_HighDropCircleComp:GetHighDorpRadius()
  if HighDropRadius and 0 < HighDropRadius then
    local HighDropX = uGameState.BP_HighDropCircleComp:GetHighDorpX()
    local HighDropY = uGameState.BP_HighDropCircleComp:GetHighDorpY()
    self:ReceivedHighDrop(HighDropX, HighDropY, HighDropRadius)
  end
end
function MapUIBase:OnCreateMapWidget(Widget, WidgetUIConfig)
  if not Widget or not WidgetUIConfig then
    print(bWriteLog and "MapUIBase:OnCreateMapWidget - Error")
    return
  end
  self[Widget] = UIManager.ShowUI(UIManager.UI_Config_InGame[WidgetUIConfig])
  local NewWidget = self[Widget]
  if NewWidget then
    if NewWidget.BindMapUIBase then
      NewWidget.BindMapUIBase(NewWidget, self, self.bIsMiniMap)
    end
    if NewWidget.InitUI then
      NewWidget.InitUI(NewWidget, self.MapWidgetLua)
    end
    self.MapWidgets[#self.MapWidgets + 1] = Widget
  end
end
function MapUIBase:CanCreateMapWidget(MapWidgetConfig)
  if MapWidgetConfig.bMiniMap == false and self.bIsMiniMap == true then
    return false
  elseif MapWidgetConfig.bEntireMap == false and self.bIsMiniMap == false then
    return false
  end
  return true
end
function MapUIBase:InitMapWidget()
  local MapWidgetConfig = GamePlayTools.GetCurrentConfig("MapWidgetConfig")
  if not MapWidgetConfig then
    print(bWriteLog and "MapUIBase:InitMapWidget - MapWidgetConfig or MapWidgetConfig.Widgets is nil")
    return
  end
  for Widget, WidgetConfig in pairs(MapWidgetConfig) do
    local CloseEvents = WidgetConfig.CloseEvents
    local CreateEvents = WidgetConfig.MapUIEvents
    local WidgetUIConfig = WidgetConfig.UIConfig or Widget
    if not self[Widget] and UIManager.UI_Config_InGame[WidgetUIConfig] and self:CanCreateMapWidget(WidgetConfig) then
      if CreateEvents then
        for _, Event in ipairs(CreateEvents) do
          if type(Event) == "string" then
            self:BindLuaObjEvent(self, Event, function(...)
              if not self[Widget] then
                self:OnCreateMapWidget(Widget, WidgetUIConfig)
                self:LuaBroadcast(Event, ...)
                self:AddGameTimer(0, false, function()
                  self:UnBindLuaObjEvent(self, Event)
                end)
              end
            end)
          end
        end
      else
        self:OnCreateMapWidget(Widget, WidgetUIConfig)
      end
      if CloseEvents then
        for _, Event in ipairs(CloseEvents) do
          if type(Event) == "string" then
            self:BindLuaObjEvent(self, Event, function(...)
              if self[Widget] then
                self[Widget]:Close()
                self[Widget] = nil
              end
            end)
          end
        end
      end
    end
  end
end
function MapUIBase:BindMapWidget(MapWidget)
  print(bWriteLog and "MapUIBase:BindMapWidget" .. tostring(MapWidget))
  self.MapWidgetLua = MapWidget
  self:InitMapWidget()
  self:UpdateAirplaneRoute(FVector(0, 0, 0), FVector(0, 0, 0), true, false)
  self:UpdateSecondAirplaneRoute(FVector(0, 0, 0), FVector(0, 0, 0), true, false)
  self:UpdateReviveAirline()
  self.AirAttackTipsID = 10022
  self:CheckIsNeedCreateInnerCircle()
  self:CheckHighDropArea()
end
function MapUIBase:OnReconnect(ReconnectInfo)
  print(bWriteLog and "MapUIBase:OnReconnect")
  self:UpdateAirplaneRoute(FVector(0, 0, 0), FVector(0, 0, 0), true, false)
  self:UpdateSecondAirplaneRoute(FVector(0, 0, 0), FVector(0, 0, 0), true, false)
  self:UpdateReviveAirline()
  if slua.isValid(ReconnectInfo) and slua.isValid(ReconnectInfo.AirAttackStatus) and slua.isValid(ReconnectInfo.AirAttackWave) then
    self:OnReceivedAirAttack(nil, nil, ReconnectInfo.AirAttackStatus, ReconnectInfo.AirAttackWave, ReconnectInfo.AirAttackArea)
  end
  if self.CurrentMapData_BP then
    self.CurrentMapData_BP:RefreshTeammateIcon(-1)
  end
  self:CheckNeedCarTips()
  self:Reconnect_ResetUIByPlayerControllerState()
end
function MapUIBase:UpdateAirplaneRoute(StartLoc, EndLoc, IsDraw, bCheckPostion)
  print(bWriteLog and "MapUIBase:UpdateAirplaneRoute StartLoc:" .. StartLoc:ToString() .. " EndLoc:" .. EndLoc:ToString())
  if not MapUIUtils.CheckIsShowAirLine(StartLoc, EndLoc, IsDraw, bCheckPostion) and not self.CurrentMapUI.bIsShowAirPlaneRouteAfteHide then
    print(bWriteLog and "MapUIBase:UpdateAirplaneRoute CheckIsShowAirLine False  " .. tostring(self.bIsMiniMap))
    self:LuaBroadcast("UpdateAirplaneRouteShow", false)
  else
    if not self.CurrentMapUI then
      print(bWriteLog and "MapUIBase:UpdateAirplaneRoute CurrentMapUI Is Nil  " .. tostring(self.bIsMiniMap))
      return
    end
    self.CurrentMapUI:ReCalMapInfoC()
    local MapRealTimeInfoC = self.CurrentMapUI.MapRealTimeInfoC
    if not MapRealTimeInfoC or slua.IndexReference(MapRealTimeInfoC, "PlaneRouteData").RouteLengthInMap <= 0 then
      print(bWriteLog and "MapUIBase:UpdateAirplaneRoute MapRealTimeInfoC Is Nil  " .. tostring(self.CurrentMapUI.MapRealTimeInfoC == nil) .. tostring(self.bIsMiniMap))
      return
    end
    self:LuaBroadcast("UpdateAirplaneRouteShow", true)
  end
end
function MapUIBase:UpdateReviveAirline()
  local HasChance = false
  local playerController = GameplayStatics.GetPlayerController(CGameState, 0)
  if Game:IsValid(playerController) then
    local PlayerState = playerController.PlayerState
    if PlayerState and slua.isValid(PlayerState) and PlayerState.HasAnyReviveChance then
      HasChance = PlayerState:HasAnyReviveChance()
    end
  end
  self:CalculateRouteInfo()
  print(bWriteLog and "MapUIBase:UpdateReviveAirline, HasChance = " .. tostring(HasChance) .. ", ReviveAirlineInfo = " .. tostring(self.ReviveAirlineInfo))
  if self.ReviveAirlineInfo ~= nil or HasChance then
    if not self.CurrentMapUI then
      print(bWriteLog and "MapUIBase:UpdateReviveAirline, self.CurrentMapUI = nil")
      return
    end
    self:LuaBroadcast("UpdateReviveAirline", true)
    if self.ReviveAirlineInfo ~= nil then
      self:LuaBroadcast("ForceHideAirIcon")
    end
  else
    self:LuaBroadcast("UpdateReviveAirline", false)
  end
end
function MapUIBase:CreateCommonAirlineWidget(__, __, ShowOrHide, Plane, startPos, stopPos)
  print(bWriteLog and "MapUIBase:CreateCommonAirlineWidget, self.bIsMiniMap = " .. tostring(self.bIsMiniMap))
  if ShowOrHide then
    self.CommonAirLineUIWidget = UIManager.ShowUI(UIManager.UI_Config_InGame.CommonAirLineUI)
  end
  if self.CommonAirLineUIWidget and ShowOrHide then
    self.CommonAirLineUIWidget:BindMapUIBase(self, self.bIsMiniMap, ShowOrHide, Plane, startPos, stopPos)
    self.CommonAirLineUIWidget:InitUI(self.MapWidgetLua)
  elseif self.CommonAirLineUIWidget and not ShowOrHide then
    self.CommonAirLineUIWidget:HideAirLine()
  end
end
function MapUIBase:CalculateRouteInfo()
  if self.ReviveAirlineInfo ~= nil then
    local LevelLandScapeCenter = self.CurrentMapUI.LevelLandScapeCenterC
    local LevelToMapScale = self.CurrentMapUI:GetLevelToMapScale()
    self.ReviveRouteInfo = {}
    local USTExtraMapFunctionLibrary = import("/Script/ShadowTrackerExtra.STExtraMapFunctionLibrary")
    self:CalculatePlaneInfo()
    self.ReviveRouteInfo.CanJumpLocInMap = USTExtraMapFunctionLibrary.MapCenterToPointVector2D(self.ReviveAirlineInfo.PlaneStartLoc, LevelLandScapeCenter, LevelToMapScale)
    self.ReviveRouteInfo.ForceJumpLocInMap = USTExtraMapFunctionLibrary.MapCenterToPointVector2D(self.ReviveAirlineInfo.PlaneEndLoc, LevelLandScapeCenter, LevelToMapScale)
    self.ReviveRouteInfo.RouteLengthInMap = FVector2D.Distance(self.ReviveRouteInfo.CanJumpLocInMap, self.ReviveRouteInfo.ForceJumpLocInMap)
    self.ReviveRouteInfo.RouteWidgetRotateAngle = math.atan(self.ReviveRouteInfo.ForceJumpLocInMap.Y - self.ReviveRouteInfo.CanJumpLocInMap.Y, self.ReviveRouteInfo.ForceJumpLocInMap.X - self.ReviveRouteInfo.CanJumpLocInMap.X) * 180 / math.pi
    self.ReviveRouteInfo.PlaneRotation = self.ReviveRouteInfo.RouteWidgetRotateAngle + 90
  else
    self.ReviveRouteInfo = nil
  end
end
function MapUIBase:CalculatePlaneInfo()
  if self.ReviveAirlineInfo ~= nil and self.ReviveRouteInfo then
    local USTExtraMapFunctionLibrary = import("/Script/ShadowTrackerExtra.STExtraMapFunctionLibrary")
    local PlanePosition = FVector(0, 0, 0)
    local Plane = self.ReviveAirlineInfo.Plane
    if Plane and slua.isValid(Plane) then
      PlanePosition = Plane:K2_GetActorLocation()
      local LevelLandScapeCenter = self.CurrentMapUI.LevelLandScapeCenterC
      local LevelToMapScale = self.CurrentMapUI:GetLevelToMapScale()
      self.ReviveRouteInfo.PlaneLocInMap = USTExtraMapFunctionLibrary.MapCenterToPointVector2D(PlanePosition, LevelLandScapeCenter, LevelToMapScale)
      local PassedDist = FVector.DistXY(PlanePosition, self.ReviveAirlineInfo.PlaneStartLoc)
      local TotalDist = FVector.DistXY(self.ReviveAirlineInfo.PlaneStartLoc, self.ReviveAirlineInfo.PlaneEndLoc)
      self.ReviveRouteInfo.PlaneFlyingProcess = PassedDist / TotalDist
    else
      self.ReviveAirlineInfo.Plane = nil
      self.ReviveRouteInfo.PlaneFlyingProcess = 1
    end
  end
end
function MapUIBase:ReShowAirplaneRoute(IsShow)
  print(bWriteLog and "MapUIBase:ReShowAirplaneRoute:" .. tostring(IsShow))
  self.CurrentMapUI.bIsShowAirPlaneRouteAfteHide = IsShow
  self:LuaBroadcast("ReShowAirplaneRoute", IsShow)
end
function MapUIBase:ForceRefreshAirline()
  self.CurrentMapUI:ReCalMapInfoC()
  self:LuaBroadcast("ForceRefreshAirLine", self.bIsMiniMap)
end
function MapUIBase:UpdateSecondAirplaneRoute(StartLoc, EndLoc, IsDraw, bCheckPostion)
  if not MapUIUtils.CheckIsShowAirLine(StartLoc, EndLoc, IsDraw, bCheckPostion) then
    print(bWriteLog and "MapUIBase:UpdateSecondAirplaneRoute CheckIsShowAirLine False  " .. tostring(self.bIsMiniMap))
    if not self.CurrentMapUI.bIsShowAirPlaneRouteAfteHide then
      self:LuaBroadcast("UpdateSecondAirplaneRouteShow", false)
    end
  else
    if not self.CurrentMapUI then
      print(bWriteLog and "MapUIBase:UpdateSecondAirplaneRoute CurrentMapUI Is Nil  " .. tostring(self.bIsMiniMap))
      return
    end
    if self.CurrentMapUI then
      self.CurrentMapUI:ReCalMapInfoC()
    end
    self.bInitNeedInfoBackShow = true
    local MapRealTimeInfoC = self.CurrentMapUI.MapRealTimeInfoC
    if not MapRealTimeInfoC or slua.IndexReference(MapRealTimeInfoC, "PlaneRouteData2").RouteLengthInMap <= 0 then
      print(bWriteLog and "MapUIBase:UpdateSecondAirplaneRoute SecondAirlineInfo Is Nil  " .. tostring(self.bIsMiniMap))
      return
    end
    self.bInitNeedInfoBackShow = false
    self:LuaBroadcast("UpdateSecondAirplaneRouteShow", true)
  end
end
function MapUIBase:HandleAirAttackBroadcast(AttackMsg, Wave, Order, Area)
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  if not UKismetSystemLibrary.IsDedicatedServer(self) then
    if Order ~= nil then
      print(bWriteLog and "HandleAirAttackBroadcast AttackMsg:" .. tostring(AttackMsg) .. ", Wave:" .. tostring(Wave) .. ", bExecOnce:" .. tostring(Order.bExecOnce) .. ", Area:" .. tostring(Area.X) .. "," .. tostring(Area.Y) .. "," .. tostring(Area.Z))
    end
    local EAirAttackInfo = import("EAirAttackInfo")
    if AttackMsg == EAirAttackInfo.Attacking or AttackMsg == EAirAttackInfo.AttackWarningTips then
      if Order ~= nil and Order.bExecOnce then
        self:LuaBroadcast("RedrawCustomAirAttackArea", Area)
      else
        self.LastestAirAttack        self:LuaBroadcast("RedrawAirAttackArea", Area)
      end
    elseif AttackMsg == EAirAttackInfo.AttackOver then
      if Wave == -1 or Order ~= nil and Order.bExecOnce then
        self:LuaBroadcast("RedrawCustomAirAttackArea", nil)
      end
      if (Wave == -1 or Order == nil or not Order.bExecOnce) and (self.LastestAirAttackWave == Wave or Wave == -1) then
        self:LuaBroadcast("RedrawAirAttackArea", nil)
      end
    end
  end
end
function MapUIBase:SetReshowAirplaneRouteBtnVisibility(bIsShow)
  print(bWriteLog and "MapUIBase:SetReshowAirplaneRouteBtnVisibility - bIsShow", tostring(bIsShow))
  local CanvasPanel_ShowAirPlaneRoute = self.CurrentMapUI.CanvasPanel_ShowAirPlaneRoute
  if slua_isValid(CanvasPanel_ShowAirPlaneRoute) then
    if bIsShow then
      local MapIconSubsystem = SubsystemMgr:Get("MapIconSubsystem")
      if MapIconSubsystem and not MapIconSubsystem.bBaltic then
        CanvasPanel_ShowAirPlaneRoute:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      else
        CanvasPanel_ShowAirPlaneRoute:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      end
    else
      CanvasPanel_ShowAirPlaneRoute:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
end
function MapUIBase:HandleHideAirPlaneRoute()
  local PlayerState = GameplayData.GetPlayerState()
  if PlayerState and slua_isValid(PlayerState) and PlayerState.LastValidAirplaneCanJumpLoc:Equals(FVector(0, 0, 0), 1.0E-4) and PlayerState.LastValidAirplaneForceJumpLoc:Equals(FVector(0, 0, 0), 1.0E-4) then
    self:SetReshowAirplaneRouteBtnVisibility(false)
  else
    self:SetReshowAirplaneRouteBtnVisibility(true)
  end
  if not self.CurrentMapUI.bIsShowAirPlaneRouteAfteHide then
    self:UpdateAirplaneRoute(FVector(0, 0, 0), FVector(0, 0, 0), false, true)
  end
end
function MapUIBase:HandleShowAirPlaneRoute()
  local PlayerState = GameplayData.GetPlayerState()
  if PlayerState and slua_isValid(PlayerState) and PlayerState.GetCanJumpLoc then
    local CanJumpLoc = PlayerState:GetCanJumpLoc()
    local ForceJumpLoc = PlayerState:GetForceJumpLoc()
    self:UpdateAirplaneRoute(CanJumpLoc, ForceJumpLoc, true, true)
    if CanJumpLoc:Equals(ForceJumpLoc, 1.0E-4) then
      if not PlayerState.LastValidAirplaneCanJumpLoc:Equals(FVector(0, 0, 0), 1.0E-4) or not PlayerState.LastValidAirplaneForceJumpLoc:Equals(FVector(0, 0, 0), 1.0E-4) then
        self:SetReshowAirplaneRouteBtnVisibility(true)
        if not self.CurrentMapUI.bIsShowAirPlaneRouteAfteHide then
          self:UpdateAirplaneRoute(FVector(0, 0, 0), FVector(0, 0, 0), false, true)
        end
      end
    else
      self:SetReshowAirplaneRouteBtnVisibility(false)
    end
  end
end
function MapUIBase:HandlechangeMapTextureWithTags(_, _, MapTexturePath, MapScale, MapStandTag)
  self:ChangeMapTextureAndTags(MapTexturePath, MapScale, MapStandTag, true)
end
function MapUIBase:HandlechangeMapTextureWithoutTags(_, _, MapTexturePath, MapScale, MapStandTag)
  self:ChangeMapTextureAndTags(MapTexturePath, MapScale, MapStandTag, false)
end
function MapUIBase:GetOwningPlayer()
  if slua.isValid(self.HoldWidget) then
    local PlayerController = self.HoldWidget:GetOwningPlayer()
    if slua.isValid(PlayerController) then
      return PlayerController
    end
  end
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    return PlayerController
  end
  print(bWriteLog and "MapUIBase:GetOwningPlayer PlayerController is nil")
  return nil
end
function MapUIBase:RepositionMapMark(InIndex, Offset, Size)
  if not self.bIsInfectMode and not self.bIsVehicleWarMode then
    self.CurrentMapUI:RedrawAllMapMarkC(self.MapCurSize)
  end
end
function MapUIBase:OnPlayerLeaveVehicle()
  self:LuaBroadcast("OnPlayerLeaveVehicle")
end
function MapUIBase:CheckNeedCarTips()
  if self.CurrentMapUI.MapRealTimeInfoC and self.CurrentMapUI.MapRealTimeInfoC.bCanPlayerSeeLastVehicle then
    self:LuaBroadcast("OnPlayerLeaveVehicle")
  end
end
function MapUIBase:OnSyncCircleInfo(_, __, CircleInfo)
  local uGameState = GameplayData.GetGameState()
  if uGameState and slua.isValid(uGameState) and uGameState:GetCurCircleWave() > -1 or uGameState.BlueCircle and not slua.IndexReference(uGameState, "BlueCircle"):IsZero() then
    self:LuaBroadcast("OnSyncCircleInfo", CircleInfo)
    self:RemoveCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_SYNC_CIRCILE_INFO)
  end
end
function MapUIBase:CloseCustomBlueWidget()
  print(bWriteLog and "MapUIBase:CloseCustomBlueWidget")
  self:LuaBroadcast("OnCloseCustomBlueWidget")
end
function MapUIBase:OnReceivedCustomBlueCircle(_, __, CircleInfo, bExcludeBlueWidget)
  print(bWriteLog and "MapUIBase:OnReceivedCustomBlueCircle")
  if not (not self.CustomBlueWidget and bExcludeBlueWidget) or not self.BlueWidget then
    self:LuaBroadcast("OnReceivedCustomBlueCircle", CircleInfo)
  end
end
function MapUIBase:UpdateAirDropLine()
end
function MapUIBase:CheckIsNeedCreateInnerCircle()
  local CurGameModeID = Client.GetGameModeID(GameFrontendHUD)
  local bIsNeedInnerCircle = false
  for k, v in pairs(self.CurrentMapUI.InnerCircleGameModeIDC) do
    if v == tostring(CurGameModeID) then
      bIsNeedInnerCircle = true
      break
    end
  end
  if not bIsNeedInnerCircle then
    return
  end
  self:LuaBroadcast("NeedInnerCircle")
end
function MapUIBase:AfterInitMapStandard()
  print(bWriteLog and "MapUIBase:AfterInitMapStandard")
  self:LuaBroadcast("AfterInitMapStandard")
end
function MapUIBase:HandleRefreshMapIcon(_, __, bMiniMap)
  print(bWriteLog and "MapUIBase:HandleRefreshMapIcon", bMiniMap)
  if not self.CurrentMapUI then
    return
  end
  if bMiniMap and self.bIsMiniMap then
    self.CurrentMapUI.bMapDynamicScaleDirty = true
  elseif not bMiniMap and not self.bIsMiniMap then
    self.CurrentMapUI.bMapDynamicScaleDirty = true
  end
  self:LuaBroadcast("OnRefreshMapIcon")
end
function MapUIBase:RefreshAllMarks()
  if not self.CurrentMapUI then
    return
  end
  if self.bIsMiniMap then
    self.CurrentMapUI.bMapDynamicScaleDirty = true
  end
  self.CurrentMapUI:OnUpdateUIMarks()
end
function MapUIBase:SetIsDrawWhiteCircle(_, __, bIsDraw)
  if self.CurrentMapUI then
    self.CurrentMapUI.bNeedDrawWhiteCircleC = bIsDraw
  end
end
function MapUIBase:SetIsDrawWhiteCircleGuideLine(_, __, bIsDraw)
  if self.CurrentMapUI then
    self.CurrentMapUI.bNeedDrawCircleGuideLineC = bIsDraw
  end
end
function MapUIBase:OnEntireMapOpen(bIsOpen)
  print(bWriteLog and "MapUIBase:OnEntireMapOpen -", tostring(bIsOpen))
  self:LuaBroadcast("OnEntireMapOpen", bIsOpen)
end
function MapUIBase:OnLuaInitTeammateState(teammate)
  print(bWriteLog and "MapUIBase:OnLuaInitTeammateState ")
  if not slua.isValid(teammate) then
    return
  end
  self:AddControlEvent(teammate, "OnMapTagsChangedDelegate", self.HandleChangeTeammateTags, self)
end
function MapUIBase:HandleChangeTeammateTags(TeammateState)
  local CurPlayerState = MapUIUtils.GetLocalPlayerState()
  if not (slua_isValid(TeammateState) and slua.isValid(CurPlayerState)) or not slua.isValid(self.CurrentMapData_BP) then
    return
  end
  print(bWriteLog and "MapUIBase:HandleChangeTeammateTags ", TeammateState, CurPlayerState)
  if TeammateState == CurPlayerState then
    self.CurrentMapData_BP:RefreshTeammateIcon(-1)
  else
    local PlayerState = GameplayData.GetPlayerState()
    if slua_isValid(PlayerState) then
      local teammateIndex = PlayerState:GetTeamMateIndex(TeammateState)
      self.CurrentMapData_BP:RefreshTeammateIcon(teammateIndex)
    end
  end
end
function MapUIBase:HandleChangeMapTexture(MapTexturePath, MapScale, MapStandTag)
  local MapManagerSubsystem = SubsystemMgr:Get("MapManagerSubsystem")
  if not MapManagerSubsystem then
    return
  end
  self.StandParam = MapManagerSubsystem:GetTagParam(MapStandTag)
  if self.StandParam == nil then
    return
  end
  self.ChangedMapPath = MapTexturePath
  self.CurTag = MapStandTag
  local StandParamPath = self.StandParam.ChangedMapPath
  if StandParamPath and StandParamPath ~= "" then
    self.ChangedMapPath = StandParamPath
  end
  self:InitMapTextureByPath(self.ChangedMapPath)
  local NavigatorPanel = UIManager.GetUI(UIManager.UI_Config_InGame.NavigatorPanel)
  if NavigatorPanel then
    NavigatorPanel:ReSetPara(self.StandParam.BoundExtent, self.StandParam.Loc)
  end
  print(bWriteLog and "MapUIBase:HandleChangeMapTexture MapTexturePath = ", self.ChangedMapPath, " MapStandTag : ", MapStandTag)
end
function MapUIBase:InitMapStandardPoint()
  if self.StandParam == nil then
    local MapManagerSubsystem = SubsystemMgr:Get("MapManagerSubsystem")
    if not MapManagerSubsystem then
      return
    end
    self.StandParam = MapManagerSubsystem:GetTagParam(self.CurTag or "")
    if self.StandParam == nil then
      return
    end
  end
  self.LevelLandScapeExtent = self.StandParam.BoundExtent
  self.CurrentMapUI.LevelLandScapeCenterC = self.StandParam.Loc
  self.CurrentMapUI.LevelLandScapeCenterC.Z = 0
  self:HandleShowAirPlaneRoute()
  self.CurrentMapUI.bMapDynamicScaleDirty = true
end
function MapUIBase:ChangeMapTextureAndTags(MapTexturePath, MapScale, MapStandTag, bIsChangeTags)
  print(bWriteLog and "MapUIBase:ChangeMapTextureandTags " .. tostring(bIsChangeTags))
  if MapTexturePath == "" and MapScale == 0 and MapStandTag == "" and self.CurMapInfo then
    if self.CurMapInfo.MapStandTag == "" then
      print(bWriteLog and "MapUIBase:ChangeMapTextureandTags Return Case MapStandTag Empty")
      return
    end
    self:HandleChangeMapTexture(self.CurMapInfo.MapTexturePath, self.CurMapInfo.MapScale, self.CurMapInfo.MapStandTag)
  else
    self:HandleChangeMapTexture(MapTexturePath, MapScale, MapStandTag)
    if not self.CurMapInfo then
      self.CurMapInfo = {}
    end
    self.CurMapInfo.    self.CurMapInfo.    self.CurMapInfo.  end
  self.CurrentMapUI:ReCalMapInfoC()
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return
  end
  local uPlayerState = uPlayerController.PlayerState
  if not slua.isValid(uPlayerState) then
    return
  end
  if bIsChangeTags then
    if uPlayerState.SetCurMapTags then
      uPlayerState:SetCurMapTags(self.CurTag)
    end
  elseif uPlayerState.ShowingMapTags and slua.isValid(self.CurrentMapData_BP) then
    uPlayerState.ShowingMapTags = self.CurTag
    self.CurrentMapData_BP:RefreshTeammateIcon(-1)
  end
  self:AfterInitMapStandard()
  self:HandleMultiMarks(MapStandTag)
end
function MapUIBase:HandleMultiMarks(MapStandTag)
  local CurAreaID = 0
  if MapStandTag == "" then
    CurAreaID = 0
  else
    CurAreaID = tonumber(MapStandTag)
  end
  local MultiMarkItems = self.CurrentMapData_BP.MultiMarkItems
  for Index, MultiMarks in pairs(MultiMarkItems) do
    if Index ~= self.CurrentMapUI.LocalPlayerIndexC then
      local AreaID = MapUIUtils.GetTeamMateAreaID(Index)
      local NewVisibility = UEnums.ESlateVisibility.Collapsed
      if AreaID == CurAreaID then
        NewVisibility = UEnums.ESlateVisibility.SelfHitTestInvisible
      end
      for _, MultiMark in pairs(MultiMarks) do
        MultiMark:SetWidgetVisibility(NewVisibility)
      end
    end
  end
end
function MapUIBase:OnChangeMapSize(bIsMiniMap)
  if bIsMiniMap ~= self.bIsMiniMap then
    return
  end
  self.CurrentMapUI:ReCalMapInfoC()
  self:LuaBroadcast("OnChangeMapSize")
  if bIsMiniMap then
    print(bWriteLog and "MapUIBase:OnChangeMapSize")
    EventSystem:postEvent(EVENTTYPE_INGAME_MAP, EVENTID_ON_MINIMAP_RESIZE)
  end
end
function MapUIBase:RefreshAllIcon()
  if self.CurrentMapData_BP then
    self.CurrentMapData_BP:RefreshTeammateIcon(-1)
  end
  self:HandleInitPlayerState()
end
function MapUIBase:SetCustomSetting()
  local CustomType = require("client.logic.setting.CustomType")
  local CustomLayoutModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.CustomLayoutModule)
  local LayoutDetail = CustomLayoutModule:GetLayoutDetailByType(CustomType._12_Map)
  if LayoutDetail then
    local Opacity = LayoutDetail.Opacity
    self.CurrentMapUI.WhiteCircleColorC.A = Opacity
    self.CurrentMapUI.GuideLineColor.A = Opacity
    self.Last  end
end
function MapUIBase:ReSetLineColor()
  if not self.bIsMiniMap then
    return
  end
  if not self.LastOpacity then
    return
  end
  self.CurrentMapUI.WhiteCircleColorC.A = self.LastOpacity
  self.CurrentMapUI.GuideLineColor.A = self.LastOpacity
end
function MapUIBase:InitPlayerState(bSwitchDeadState)
  print(bWriteLog and "MapUIBase:InitPlayerState")
  if STExtraBlueprintFunctionLibrary.IsUsingMapPlayerItem(self) then
    self.CurrentMapData_BP:InitPlayerItemInMap(true)
    local PlayerState = GameplayData.GetPlayerState()
    if slua_isValid(PlayerState) then
      local TeammateCount = PlayerState:GetTeammateCount()
      for Index = 0, TeammateCount - 1 do
        self.CurrentMapData_BP:AddOnePlayerMark(Index, 0)
      end
    end
    self:ResetLocalPlayerIndex(false)
    local MapSys = require("GameLua.Mod.BaseMod.Client.Map.IngameMapSys")
    self.CurrentMapUI.GuideLineColor = MapSys:GetPlayerColorByIndexC(self.CurrentMapUI.LocalPlayerIndexC)
    self:ReSetLineColor()
  else
    local GameState = GameplayStatics.GetGameState(self.Object)
    local PlayerController = GameplayData.GetPlayerController()
    local PlayerState = slua_isValid(PlayerController) and PlayerController.PlayerState
    if not slua_isValid(GameState) or not slua_isValid(PlayerState) then
      return
    end
    if not self.bIsVehicleWarMode then
      if GameState.PlayerNumPerTeam == 1 then
        self.CurrentMapUI.LocalPlayerIndexC = 0
        self.CurrentMapData_BP:AddOnePlayer(0, 0)
        self.CurrentMapData_BP:SetSingleStype(0, true)
      elseif slua_isValid(PlayerState) and PlayerState.GetPlayerIndexInTeam then
        self.CurrentMapUI.LocalPlayerIndexC = PlayerState:GetPlayerIndexInTeam()
        self.TeamMatePlayerStateList = PlayerState:GetTeamMatePlayerStateList({}, false)
        local LocalPlayerID = PlayerState.PlayerId
        local PlayerController = GameplayData.GetPlayerController()
        if slua.isValid(PlayerController) then
          local CurPlayerState = PlayerController:GetCurPlayerState()
          if slua.isValid(CurPlayerState) then
            LocalPlayerID = CurPlayerState.PlayerId
          end
        end
        for Index, TeamMatePlayerState in pairs(self.TeamMatePlayerStateList) do
          self.CurrentMapData_BP:AddOnePlayer(Index, self.CurrentMapUI.LocalPlayerIndexC)
          if slua_isValid(TeamMatePlayerState) then
            if TeamMatePlayerState.PlayerId == LocalPlayerID then
              self.CurrentMapData_BP:SetSelfStype(Index, true)
            else
              self.TeamPlayerWithoutLocalPlayer:Add(TeamMatePlayerState)
              self.CurrentMapData_BP:SetSelfStype(Index, false)
            end
            self:OnLuaInitTeammateState(TeamMatePlayerState)
            if bSwitchDeadState then
              self.CurrentMapData_BP:SwitchAliveDeadIcon(Index, TeamMatePlayerState.LiveState)
            end
          end
        end
        if 1 < self.TeamMatePlayerStateList:Num() then
          local PlayerInfoBPArray = self.CurrentMapData_BP:GetPlayerInfoBPArray()
          for Index = self.TeamMatePlayerStateList:Num(), PlayerInfoBPArray:Num() - 1 do
            self.CurrentMapData_BP:SwitchVisiblity(Index, false)
          end
        end
      end
    end
    local DelegateMgr = STExtraDelegateMgr.STExtraDelegateMgrInstance(self)
    if slua_isValid(DelegateMgr) then
      self:AddControlEvent(DelegateMgr, "OnCharacterStateChangeDelegate", self.HandleOnCharacterStateChangeDelegate, self)
    end
    local ExtraPlayerLiveState = import("ExtraPlayerLiveState")
    self:OnCharacterStateChange(nil, ExtraPlayerLiveState.InDefault)
  end
end
function MapUIBase:HandleConstruct(Widget, MapDataBase)
  self.Hold  self.CurrentMapData_BP = MapDataBase
  self.CurrentHoldMapUI = self.CurrentMapUI
  self.CurrentMapData_BP:HandleConstruct(self)
  self.CurrentMapUI:InitMap(self.CurrentMapData_BP.CurrentMapData, self.HoldWidget)
  self:RegistEvents()
  self:AddControlEvent(self.CurrentMapUI, "OnUpdateMark", self.HandleUpdateMark, self)
  self:AddControlEvent(self.CurrentMapUI, "OnUpdateMultiMark", self.HandleUpdateMultiMark, self)
end
function MapUIBase:HandleReceiveInitWidget()
  local GameState = GameplayData.GetGameState()
  self.STExtraPlayerController = GameplayData.GetPlayerController()
  if slua_isValid(self.STExtraPlayerController) and slua_isValid(GameState) then
    self.STEGameStateBase = GameState
    self:RegisterDelegate()
    self:SetAntiAlias()
    self:HandleShowAirPlaneRoute()
  end
end
function MapUIBase:SetAntiAlias()
  local GameInstance = GameplayStatics.GetGameInstance(self)
  local DeviceLevel = GameInstance:GetDeviceLevel()
  if DeviceLevel <= 0 then
    self.CurrentMapUI.IsAntiAliasC = false
  elseif DeviceLevel == 1 or DeviceLevel == 2 then
    self.CurrentMapUI.IsAntiAliasC = true
  end
end
function MapUIBase:HandleInitPlayerState()
  GameplayData.AddSelfPlayerControllerEvent(self, "OnMapMarkChangeDelegate", self.HandleTeamMapMark, self)
end
function MapUIBase:RegistEvents()
  self.CurrentMapData_BP:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_REFRESHUI_AFTERRESPAWN, self.HandleResetUIStateAfterRespawn, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_RECEIVED_TRANNING_FILED_ID, self.InitMapStandardPoint, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_HIDE_MAP_AIRPLANE_ROUTE, self.HandleHideAirPlaneRoute, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_SHOW_MAP_AIRPLANE_ROUTE, self.HandleShowAirPlaneRoute, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_MAKE_MAKER, self.HandleMakeMark, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_CHANGE_MAP_TEXTURE, self.HandlechangeMapTextureWithTags, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_CHANGE_MAP_TEXTURE_WITHOUT_TAGS, self.HandlechangeMapTextureWithoutTags, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_REPOSITION_SELF_MULTI_MARK, self.HandleRepositionSelfMultiMark, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_SHOW_MARKCANVAS_WITHTAG, self.ShowHideMarkMarkTagCanvas, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTTYPE_CHANGE_LEVEL_STREAM, self.InitMapStandardPoint, self)
end
function MapUIBase:HandleMakeMark(_, _, PositionX, PositionY, bIsSpectator)
  local CurrentMapUI = self.CurrentMapUI
  CurrentMapUI.SelfMarkerAligmentC.X = PositionX
  CurrentMapUI.SelfMarkerAligmentC.Y = PositionY
  CurrentMapUI.bNeedDrawSelfGuideLineC = not bIsSpectator
  local MapSys = require("GameLua.Mod.BaseMod.Client.Map.IngameMapSys")
  CurrentMapUI.GuideLineColor = MapSys:GetPlayerColorByIndexC(CurrentMapUI.LocalPlayerIndexC)
  self:ReSetLineColor()
end
function MapUIBase:HandleUpdateMark(Index, FLoc, bIsShow, Opacity)
  self.CurrentMapData_BP:UpdateMark(Index, FLoc, bIsShow, Opacity)
  if slua_isValid(self.HoldWidget) then
    self.HoldWidget:InvalidateLayoutAndVolatility()
  end
end
function MapUIBase:HandleUpdateMultiMark(Index, MultiMarkLocs, bIsShow, Opacity)
  self.CurrentMapData_BP:UpdateMultiMark(Index, MultiMarkLocs, bIsShow, Opacity)
  if Index == self.CurrentMapUI.LocalPlayerIndexC then
    return
  end
  local CurAreaID = MapUIUtils.GetCurAreaID()
  local MultiMarkItems = self.CurrentMapData_BP.MultiMarkItems
  if self.TeamMarkIndexMap[Index] and self.TeamMarkIndexMap[Index] ~= CurAreaID and MultiMarkItems and MultiMarkItems[Index] then
    for _, Widget in pairs(MultiMarkItems[Index]) do
      Widget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
  if slua_isValid(self.HoldWidget) then
    self.HoldWidget:InvalidateLayoutAndVolatility()
  end
end
function MapUIBase:HandleRepositionSelfMultiMark()
  local PlayerState = GameplayData.GetPlayerState()
  if slua_isValid(PlayerState) then
    local TeamMateList = PlayerState:GetTeamMatePlayerStateList({}, false)
    if TeamMateList:Num() > 0 then
      self.CurrentMapUI:RepositionMapMultiMarkC(self.CurrentMapUI.LocalPlayerIndexC, self.MapCurSize)
    else
      self.CurrentMapUI:RepositionMapMultiMarkC(-1, self.MapCurSize)
    end
  end
end
function MapUIBase:HideAllMark()
  if slua_isValid(self.CurrentMapData_BP) then
    self.CurrentMapData_BP:HideAllMapMark()
  end
end
function MapUIBase:CacheMode()
  self.bIsInfectMode = MapUIUtils.IsInfectMode()
  self.bIsVehicleWarMode = MapUIUtils.IsVehicleWarMode()
end
function MapUIBase:ShowHideMarkMarkTagCanvas()
end
function MapUIBase:OnCharacterStateChange(OwnerCharacter, LiveState)
end
function MapUIBase:SetBlueImageColorBlindness(ImageArray)
  local BackendHudObject = GameBackendHUD.GetInstance()
  local GameInstance = GameplayStatics.GetGameInstance(self)
  local GameFrontendHUD = BackendHudObject:GetGameFrontendHUDByGameInstance(GameInstance)
  if slua_isValid(GameFrontendHUD) then
    for Idx, Image in pairs(ImageArray) do
      if slua_isValid(Image) then
        GameFrontendHUD:AddImage(Image, FLinearColor(1, 1, 1, 1), 1)
      end
    end
  end
end
function MapUIBase:PlayerPawnActiveEvent(PlayerKey, PlayerCharacter)
  self:HandleInitPlayerState()
end
function MapUIBase:InitMapTexture()
  if not slua_isValid(self.MapTexture) then
    local GameFunctionLibrary = import("/Game/BluePrints/Core/BP_GameFunctionLibrary.BP_GameFunctionLibrary_C")
    local DefaultMapPath = self.DefaultMapPath or GameFunctionLibrary.GetMinimapPathbyModeID(self.Object)
    if DefaultMapPath ~= "" then
      self:InitMapTextureByPath(DefaultMapPath)
      self:CacheMode()
    else
      print(bWriteLog and "MapUIBase:InitMapTexture - DefaultMapPath is nil")
      self:AddTimerOnce(0.2, function()
        self:InitMapTexture()
      end)
    end
  end
end
function MapUIBase:InitMapTextureByPath(MapTexturePath)
  if MapTexturePath ~= "" then
    self._Pending    local MapTextureSoftObjPath = KismetSystemLibrary.MakeSoftObjectPath(MapTexturePath)
    STExtraBlueprintFunctionLibrary.GetAssetByAssetReferenceAsync(MapTextureSoftObjPath, slua.createDelegate(function(Obj)
      if self._PendingMapTexturePath ~= MapTexturePath then
        print(bWriteLog and string.format("MapUIBase:InitMapTextureByPath - stale callback dropped: got %s, expect %s", tostring(MapTexturePath), tostring(self._PendingMapTexturePath)))
        return
      end
      if not slua_isValid(Obj) then
        print(bWriteLog and string.format("MapUIBase:InitMapTextureByPath - %s Not Found!!", tostring(MapTexturePath)))
      end
      print(bWriteLog and string.format("MapUIBase:InitMapTextureByPath - Init Map Texutre with %s", tostring(MapTexturePath)))
      self:InitMapTextureAsyncCallBack(Obj)
    end))
  end
end
function MapUIBase:InitMapTextureAsyncCallBack(Obj)
  if slua_isValid(Obj) then
    self.MapImage:SetBrushFromTexture(Obj, false)
    self.MapTexture = Obj
    self:InitMapTextureCallBack()
  end
end
function MapUIBase:InitMapTextureCallBack()
end
function MapUIBase:ResetLocalPlayerIndex(bCheckSepctator)
  local TargetPlayerID
  local CurPlayerState = GameplayData.GetPlayerState()
  if CurPlayerState and slua_isValid(CurPlayerState) then
    local PlayerController = GameplayData.GetPlayerController()
    if slua_isValid(PlayerController) and bCheckSepctator and PlayerController:IsFriendOrEnemySpectator() then
      TargetPlayerID = self:GetCurPlayerId()
    else
      TargetPlayerID = CurPlayerState.PlayerId
    end
    self.TeamMatePlayerStateList = CurPlayerState:GetTeamMatePlayerStateList({}, false)
    for Index, PlayerState in pairs(self.TeamMatePlayerStateList) do
      if slua_isValid(PlayerState) and PlayerState.PlayerId == TargetPlayerID then
        self.CurrentMapUI.LocalPlayerIndexC = Index
      end
    end
  end
end
function MapUIBase:RedrawAllMapMark()
  if not self.bIsInfectMode then
    self.CurrentMapUI:RedrawAllMapMarkC(self.MapCurSize)
  end
end
function MapUIBase:HandleTeamMapMark(Index)
  local CurAreaID = MapUIUtils.GetCurAreaID()
  local AreaID = MapUIUtils.GetTeamMateAreaID(Index)
  if not self.TeamMarkIndexMap[Index] then
    self.TeamMarkIndexMap[Index] = AreaID
  else
    self.TeamMarkIndexMap[Index] = AreaID
  end
  self.CurrentMapUI:RedrawAllMapMarkC(self.MapCurSize)
end
function MapUIBase:HandleOnCharacterStateChangeDelegate(State, OwnerCharacter)
  print(bWriteLog and "MapUIBase:HandleOnCharacterStateChangeDelegate")
  if not slua.isValid(OwnerCharacter) then
    print(bWriteLog and "MapUIBase:HandleOnCharacterStateChangeDelegate OwnerCharacter is nil")
  end
  self:OnCharacterStateChange(OwnerCharacter, State)
end
function MapUIBase:HandleOnPlayerEnterFlying()
  self:HideAllMark()
  self:HandleInitPlayerState()
end
function MapUIBase:HandleResetUIStateAfterRespawn()
end
function MapUIBase:OnSpectatorChanged()
  self:RefreshAllIcon()
end
function MapUIBase:Reconnect_ResetUIByPlayerControllerState()
  self:RedrawAllMapMark()
end
function MapUIBase:UnRegistBPEvents()
  if self._controlEvents then
    for control, controlEvents in pairs(self._controlEvents) do
      if controlEvents then
        for eventName, funcDelegate in pairs(controlEvents) do
          if funcDelegate then
            if type(control) == "table" or slua_isValid(control) then
              local eventDelegate = control[eventName]
              if slua_isValid(eventDelegate) then
                if eventDelegate.Remove then
                  eventDelegate:Remove(funcDelegate)
                else
                  eventDelegate:Clear()
                end
                controlEvents[eventName] = nil
              end
            end
            slua.removeDelegate(funcDelegate)
          end
        end
      end
    end
  end
  self._controlEvents = nil
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
local CMapUIBase = class(CDelegateContainer, nil, MapUIBase)
return CMapUIBase