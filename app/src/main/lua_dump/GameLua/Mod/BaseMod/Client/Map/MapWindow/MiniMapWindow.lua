local MiniMapWindow = {}
local STExtraMapFunctionLibrary = import("/Script/ShadowTrackerExtra.STExtraMapFunctionLibrary")
local STExtraBlueprintFunctionLibrary = import("/Script/ShadowTrackerExtra.STExtraBlueprintFunctionLibrary")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
function MiniMapWindow:ctor()
  printf("MiniMapWindow:ctor")
  self.bEnableCircleMiniMap = false
  self.bEnableCenteredAtTargetPoint = false
  self.AimTargetMarkInstanceID = nil
  self.MortarAimTargetTable = {}
  self.MortarLineUITable = {}
end
function MiniMapWindow:OnInitialize()
  printf("MiniMapWindow:OnInitialize")
end
function MiniMapWindow:OnPostInitialize()
  printf("MiniMapWindow:OnPostInitialize")
  self:OnInitWidget()
  self:AttachToMainControlUI()
  MiniMapWindow.__super.OnPostInitialize(self)
  if self:NeedEnableCircleMiniMap() then
    self:OtherMortarEnterAimState(false, false)
    local DataLayerSubsystem = SubsystemMgr:Get("DataLayerSubsystem")
    if DataLayerSubsystem then
      self:AddDataListener(DataLayerSubsystem:GetSuperData(), "OtherMortarEnterAimState", self.OtherMortarEnterAimState, self)
    end
  end
end
function MiniMapWindow:OtherMortarEnterAimState(_, bOtherMortarEnterAimState)
  if bOtherMortarEnterAimState then
    self:SetMiniMapState(true, true)
  else
    self:SetMiniMapState(false, false)
  end
end
function MiniMapWindow:NeedEnableCircleMiniMap()
  return true
end
function MiniMapWindow:GetAttachToWidgetNode()
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if not MainControlBaseUI then
    print(bWriteLog and "MiniMapWindow:GetAttachToWidgetNode Failed Case MainControlBaseUI")
    return nil
  end
  return MainControlBaseUI.MiniMapBox
end
function MiniMapWindow:AttachToMainControlUI()
  local AttachTo = self:GetAttachToWidgetNode()
  print(bWriteLog and "MiniMapWindow:AttachToMainControlUI self:" .. tostring(self.UIRoot) .. " AttachTo:" .. tostring(AttachTo))
  if slua.isValid(AttachTo) then
    AttachTo:AddChild(self.UIRoot)
    self.UIRoot.Slot:SetAnchors(FAnchors(0.5, 0.5, 0.5, 0.5))
    self.UIRoot.Slot:SetSize(FVector2D(200, 200))
    self.UIRoot.Slot:SetAlignment(FVector2D(0.5, 0.5))
    self.UIRoot:InitWidget(false)
    self.UIRoot.CanvasPanel_Root:SetWidgetVisibility(UEnums.GSlateVisibility.SelfHitTestInvisible)
    self.InitializeFailed = false
  else
    self.InitializeFailed = true
    self.UIRoot.CanvasPanel_Root:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
    print(bWriteLog and "MiniMapWindow:OnPostInitialize Failed Case AttachTo")
  end
  self:InvalidateLayoutCache(3)
end
function MiniMapWindow:CheckInitialize()
  if self.InitializeFailed then
    self:AttachToMainControlUI()
  end
end
function MiniMapWindow:SetMiniMapState(bEnableCircleMiniMap, bEnableCenteredAtTargetPoint)
  self.  self.  self.UIRoot.CurrentMapUIBP:SetMiniMapState(bEnableCircleMiniMap, bEnableCenteredAtTargetPoint)
  if self.bEnableCircleMiniMap then
    self:EnterCircleMiniMap()
  else
    self:LeaveCircleMiniMap()
  end
end
function MiniMapWindow:EnterCircleMiniMap()
  print(bWriteLog and "MiniMapWindow:EnterCircleMiniMap")
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if MainControlBaseUI and MainControlBaseUI.RetainerBox_CircleMiniMap then
    MainControlBaseUI.CanvasPanel_CircleMinimapRoot:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    self:AttachToPanel(MainControlBaseUI.RetainerBox_CircleMiniMap)
  end
end
function MiniMapWindow:LeaveCircleMiniMap()
  print(bWriteLog and "MiniMapWindow:LeaveCircleMiniMap")
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  local AttachTo = self:GetAttachToWidgetNode()
  print(bWriteLog and "MiniMapWindow:LeaveCircleMiniMap self:" .. tostring(self.UIRoot) .. " AttachTo:" .. tostring(AttachTo))
  if MainControlBaseUI and slua.isValid(AttachTo) then
    MainControlBaseUI.CanvasPanel_CircleMinimapRoot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self:AttachToPanel(AttachTo)
    self:SetAnchors(0.5, 0.5, 0.5, 0.5)
    self:SetAlignment(0.5, 0.5)
    self:SetPosition(0, 0)
    self:SetSize(200, 200)
  end
  if self.AimTargetMarkInstanceID then
    InGameMarkTools.HideMapMark(self.AimTargetMarkInstanceID)
    self.AimTargetMarkInstanceID = nil
  end
  for MarkInstanceID, _ in pairs(self.MortarAimTargetTable) do
    InGameMarkTools.HideMapMark(MarkInstanceID)
  end
  self.MortarAimTargetTable = {}
  for _, MortarLineUI in pairs(self.MortarLineUITable) do
    MortarLineUI:Close()
  end
  self.MortarLineUITable = {}
end
function MiniMapWindow:SetTargetPosition(InTargetPosition, AimTargetLoc)
  self.UIRoot.CurrentMapUIBP:SetTargetPosition(InTargetPosition)
  local Dis = "0m"
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(PlayerCharacter) then
    local PlayerCharacterLocation = PlayerCharacter:K2_GetActorLocation()
    local Diff = PlayerCharacterLocation - InTargetPosition
    Dis = math.floor(math.sqrt(Diff.X * Diff.X + Diff.Y * Diff.Y) / 100) .. "m"
  end
  if not self.bEnableCircleMiniMap then
    local MortarPackUpUI = UIManager.GetUI(UIManager.UI_Config_InGame.MortarPackUpUI)
    if MortarPackUpUI then
      MortarPackUpUI:UpdateDis(Dis)
    end
    return
  end
  if not self.AimTargetMarkInstanceID then
    self.AimTargetMarkInstanceID = InGameMarkTools.ClientAddMapMark(3000005, AimTargetLoc, 0, nil, 1)
  end
  local Target2AimDiff = InTargetPosition - AimTargetLoc
  local Target2AimDiffDis = math.floor(math.sqrt(Target2AimDiff.X * Target2AimDiff.X + Target2AimDiff.Y * Target2AimDiff.Y) / 100)
  InGameMarkTools.UpdateMapMarkLocation(self.AimTargetMarkInstanceID, AimTargetLoc)
  InGameMarkTools.UpdateMapMarkCustomFloat(self.AimTargetMarkInstanceID, Target2AimDiffDis)
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local MainControlBaseUI = InGameUITools.GetMainControlBaseUI()
  if MainControlBaseUI and MainControlBaseUI.TextBlock_Dis then
    MainControlBaseUI.TextBlock_Dis:SetText(Dis)
  end
end
function MiniMapWindow:OnMortarLaunch(StartPosition, EndPosition, ShootID)
  if not self.bEnableCircleMiniMap then
    return
  end
  print(bWriteLog and string.format("MiniMapWindow:OnMortarLaunch: %d", ShootID))
  local MapStartPosition = self:ConvertWorldPosition2MapPosition(StartPosition)
  local MapEndPosition = self:ConvertWorldPosition2MapPosition(EndPosition)
  local MortarLineUI = self:CreateChildWindow("PlayerAddPanel", UIManager.UI_Config.MortarLineUI, MapStartPosition, MapEndPosition)
  self.MortarLineUITable[ShootID] = MortarLineUI
end
function MiniMapWindow:OnMortarBulletImpact(ImpactPoint, ShootID)
  if not self.bEnableCircleMiniMap then
    return
  end
  print(bWriteLog and string.format("MiniMapWindow:OnMortarBulletImpact: %d", ShootID))
  local MortarLineUI = self.MortarLineUITable[ShootID]
  if MortarLineUI then
    MortarLineUI:Close()
    self.MortarLineUITable[ShootID] = nil
  end
  local MarkInstanceID = InGameMarkTools.ClientAddMapMark(3000006, ImpactPoint, 0, nil, 1)
  self.MortarAimTargetTable[MarkInstanceID] = true
end
function MiniMapWindow:ConvertWorldPosition2MapPosition(WorldPosition)
  return self.UIRoot.CurrentMapUIBP:ConvertWorldPosition2MapPosition(WorldPosition)
end
function MiniMapWindow:OnInitWidget()
  local MapManagerSubsystem = SubsystemMgr:Get("MapManagerSubsystem")
  if not MapManagerSubsystem then
    print(bWriteLog and "MiniMapWindow:OnInitWidget Failed Case Not MapManagerSubsystem")
    return
  end
  local MapUIPath = MapManagerSubsystem:GetMapUIPath(true)
  self.UIRoot.CurrentMapUIBP = CGame:NewObjectFromPath(MapUIPath, self.UIRoot)
  if not slua.isValid(self.UIRoot.CurrentMapUIBP) then
    print(bWriteLog and "MiniMapWindow:OnInitWidget Failed Case CurrentMapUIBP Is Not Valid")
    return
  end
  local MapDataPath = MapManagerSubsystem:GetMapDataPath(true)
  local MapData = CGame:NewObjectFromPath(MapDataPath, self.UIRoot)
  self.UIRoot.CurrentMapUIBP:HandleConstruct(self.UIRoot, MapData)
  self.UIRoot.CurrentMapUIBP:HandleReceiveInitWidget()
  self.UIRoot.MapUIBase = self.UIRoot.CurrentMapUIBP.CurrentMapUI
  local world = slua_GameFrontendHUD:GetWorld()
  self.UIRoot.MapUIMarkComponent = STExtraBlueprintFunctionLibrary.GetMapUIMarkComponent(world)
  if slua.isValid(self.UIRoot.MapUIMarkComponent) then
    self:AddControlEventByControl(self.UIRoot.MapUIMarkComponent, "OnMiniMapPointerException", self.OnMiniMapPointerException, self)
  end
  self:BindUIBase()
  local CurretnGameSate = slua_GameFrontendHUD:GetGameState()
  if slua.isValid(CurretnGameSate) and CurretnGameSate.GetLevelDataInfo then
    local LevelData = CurretnGameSate:GetLevelDataInfo()
    if LevelData then
      self:ChangeMiniMap(nil, nil, LevelData)
    end
  end
  self.UIRoot.IsMiniMapUIReady = true
end
function MiniMapWindow:OnMiniMapPointerException()
  if slua.isValid(self.UIRoot.CurrentMapUIBP) and slua.isValid(self.UIRoot.CurrentMapUIBP.CurrentMapUI) and slua.isValid(self.UIRoot.MapUIMarkComponent) then
    self.UIRoot.MapUIMarkComponent.m_pMiniMap = self.UIRoot.CurrentMapUIBP.CurrentMapUI
  else
    print(bWriteLog and "MiniMapWindow:OnMiniMapPointerException Failed")
  end
end
function MiniMapWindow:RegistEvents()
  MiniMapWindow.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_RADIATION_CIRCLE, EVENTID_RADIATION_CIRCLE_MINIMAPINFO_CHANGE, self.ChangeMiniMap, self)
  self:AddCommonEvent(EVENTTYPE_SOCIAL_ISLAND, EVENTID_ISLAND_SELF_RACING_STATUS_CHANGE, self.OnRacingStatusChange, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_MAP, EVENTID_ENTIRE_MAP_SHOW_STATE, self.OpenOrHideEntireMap, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "OnReconnectResetUIByPlayerControllerStateDelegate", self.OnReconnected_Handle, self)
end
function MiniMapWindow:OnReconnected_Handle()
  print(bWriteLog and "MiniMapWindow:OnReconnected_Handle")
  local CurretnGameSate = slua_GameFrontendHUD:GetGameState()
  if slua.isValid(CurretnGameSate) and CurretnGameSate.GetLevelDataInfo then
    local LevelData = CurretnGameSate:GetLevelDataInfo()
    if LevelData then
      self:ChangeMiniMap(nil, nil, LevelData)
      log_tree("LevelData\239\188\154", LevelData)
    end
  end
end
function MiniMapWindow:OpenOrHideEntireMap(_, __, bIsShow)
  if bIsShow then
    self:Collapsed()
  else
    self:SelfHitTestInvisible()
  end
end
function MiniMapWindow:OnRacingStatusChange(_, __, bRacing)
  print(bWriteLog and string.format(" MiniMapWindow:OnRacingStatusChange bRacing:%s", bRacing))
  if not slua.isValid(self.UIRoot.CurrentMapUIBP) then
    print(bWriteLog and " MiniMapWindow:OnRacingStatusChange invalid self.UIRoot.CurrentMapUIBP")
    return
  end
  self.UIRoot.CurrentMapUIBP:OnRacingDataChange(bRacing)
end
function MiniMapWindow:ChangeMiniMap(__, __, LevelData)
  if not LevelData then
    return
  end
  local levelDataType = type(LevelData)
  if levelDataType ~= "table" then
    print(bWriteLog and "MiniMapUIWidget:ChangeMiniMap table warning" .. levelDataType)
    return
  end
  EventSystem:postEvent(EVENTTYPE_RADIATION_CIRCLE, EVENTID_RADIATION_CIRCLE_DATA_CHANGE)
  if not self.UIRoot.CurrentMapUIBP then
    return
  end
  if LevelData.SmallMapName == "" then
    self.UIRoot.CurrentMapUIBP.UseOutMinimapscale = false
    self.UIRoot.MiniMapCover:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    if LevelData.SmallMapScale then
      self.UIRoot.CurrentMapUIBP.UseOutMinimapscale = true
      self.UIRoot.CurrentMapUIBP.OutMiniMapScale = LevelData.SmallMapScale
    else
      self.UIRoot.CurrentMapUIBP.UseOutMinimapscale = false
    end
  else
    self.UIRoot.CurrentMapUIBP.UseOutMinimapscale = true
    self.UIRoot.CurrentMapUIBP.OutMiniMapScale = LevelData.SmallMapScale
    local KismetSystemLibrary = import("KismetSystemLibrary")
    local ObjectPath = KismetSystemLibrary.MakeSoftObjectPath(LevelData.SmallMapName)
    local loadedDelegate = slua.createDelegate(function(Icon)
      self:RefreshIcon(Icon)
    end)
    STExtraBlueprintFunctionLibrary.GetAssetByAssetReferenceAsync(ObjectPath, loadedDelegate)
    if LevelData.SmallMapOffect then
      self.UIRoot.MiniMapCover:SetRenderTranslation(FVector2D(LevelData.SmallMapOffect.X, LevelData.SmallMapOffect.Y))
    end
    if LevelData.SmallMapZoom then
      self.UIRoot.MiniMapCover:SetRenderScale(FVector2D(LevelData.SmallMapZoom, LevelData.SmallMapZoom))
    end
  end
  self.UIRoot.CurrentMapUIBP:SelfHandleReceivedWidget()
  self.UIRoot.CurrentMapUIBP:HandleMapResize()
end
function MiniMapWindow:RefreshIcon(Icon)
  self.UIRoot.MiniMapCover:SetBrushFromTexture(Icon, false)
  self.UIRoot.MiniMapCover:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
end
function MiniMapWindow:OnClose()
  print(bWriteLog and "MiniMapWindow:OnClose")
  self.UIRoot.CurrentMapUIBP:OnDestroy()
  self.UIRoot.CurrentMapUIBP = nil
  self.UIRoot.IsMiniMapUIReady = false
  MiniMapWindow.__super.OnClose(self)
end
local class = require("class")
local UIBase = require("GameLua.Mod.BaseMod.Client.Map.MapWindow.MapUIWidgetBase")
local CMiniMapWindow = class(UIBase, nil, MiniMapWindow)
return CMiniMapWindow