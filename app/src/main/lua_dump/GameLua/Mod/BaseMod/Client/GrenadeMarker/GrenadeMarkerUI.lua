local GrenadeMarkerUI = {
  MarkerItemUIPath = "/Game/Mod/EvoBase/BluePrints/UIBP/GrenadeTips/GrenadeMarkerItem_UIBP.GrenadeMarkerItem_UIBP_C",
  MaxShowDistance = 10000
}
local UGameplayStatics = import("GameplayStatics")
local WidgetLayoutLibrary = import("WidgetLayoutLibrary")
local EStateType = import("EStateType")
function GrenadeMarkerUI:ctor()
  print(bWriteLog and "GrenadeMarkerUI:ctor")
  self.GrenadeIDUIMap = {}
end
function GrenadeMarkerUI:OnInitialize()
  print(bWriteLog and "GrenadeMarkerUI:OnInitialize")
  GrenadeMarkerUI.__super.OnInitialize(self)
  self.GrenadeIDUIMap = {}
  self:InitMarkerPool()
  local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
  local ShootingUIPanel = InGameUITools.GetShootingUIPanel()
  if slua.isValid(ShootingUIPanel) and slua.isValid(ShootingUIPanel.CanvasPanel_CustomWeaponUI) then
    print(bWriteLog and "GrenadeMarkerUI:OnInitialize AddChildToCanvas")
    ShootingUIPanel.CanvasPanel_CustomWeaponUI:AddChildToCanvas(self.UIRoot)
    self:SetAnchors(0.5, 0.5, 0.5, 0.5)
    self:SetPosition(0, 0)
    local SelfUISlot = WidgetLayoutLibrary.SlotAsCanvasSlot(self.UIRoot)
    SelfUISlot:SetSize(FVector2D(0, 0))
  end
end
function GrenadeMarkerUI:InitMarkerPool()
  print(bWriteLog and "GrenadeMarkerUI:InitMarkerPool")
  local ItemPoolClass = import("UIDuplicatedItemPool")
  if ItemPoolClass then
    self.MarkerPool = ItemPoolClass(self.UIRoot)
    if self.MarkerPool then
      self.MarkerPool.bActiveItemListHold = true
      self.MarkerPool:InitItemPool(self.MarkerItemUIPath, 8, true)
      print(bWriteLog and "GrenadeMarkerUI:InitMarkerPool Success")
    end
  end
end
function GrenadeMarkerUI:OnPlayerReconnect()
  print(bWriteLog and "GrenadeMarkerUI:OnPlayerReconnect")
  self:ClearAllMarkItems()
end
function GrenadeMarkerUI:OnPlayerStateChanged(InState)
  print(bWriteLog and "GrenadeMarkerUI:OnPlayerStateChanged InState:", InState)
  if InState == EStateType.State_Dead then
    self:ClearAllMarkItems()
  end
end
function GrenadeMarkerUI:ClearAllMarkItems()
  print(bWriteLog and "GrenadeMarkerUI:ClearAllMarkItems")
  if self.GrenadeIDUIMap ~= nil then
    for k, MarkerItem in pairs(self.GrenadeIDUIMap) do
      if MarkerItem and slua.isValid(MarkerItem) then
        MarkerItem:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        self.MarkerPool:FreeOneItem(MarkerItem)
      end
    end
  end
  self.GrenadeIDUIMap = {}
end
function GrenadeMarkerUI:RegistEvents()
  print(bWriteLog and "GrenadeMarkerUI:RegistEvents")
  GrenadeMarkerUI.__super.RegistEvents(self)
  if Client.IsWindowOB() then
    return
  end
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_ON_GRENADE_MARKER_STATE_CHANGED, self.HandleGrenadeMarkerStateChanged, self)
  self:AddCommonEvent(EVENTTYPE_APPLICATION_ACTIVE_STATE, EVENTID_APPLICATION_REACTIVATED_EX, self.OnApplicationReactived, self)
  local PlayerController = UGameplayStatics.GetPlayerController(self.UIRoot, 0)
  if PlayerController and slua.isValid(PlayerController) then
    self:AddControlEventByControl(PlayerController, "OnReconnectResetUIByPlayerControllerStateDelegate", self.OnPlayerReconnect, self)
    self:AddControlEventByControl(PlayerController, "OnPlayerControllerStateChangedDelegate", self.OnPlayerStateChanged, self)
  end
end
function GrenadeMarkerUI:HandleGrenadeMarkerStateChanged(EventType, EventID, UniqueID, GrenadeID, TargetLocation, bShow, uGrenade, uOwnerCharacter, SpawnTime)
  print(bWriteLog and "GrenadeMarkerUI:HandleGrenadeMarkerStateChanged", UniqueID, GrenadeID, TargetLocation:ToString(), bShow, uGrenade, SpawnTime)
  if bShow then
    self:ShowGrenadeMarker(UniqueID, GrenadeID, TargetLocation, uGrenade, SpawnTime)
  else
    self:HideGrenadeMarker(UniqueID)
  end
end
function GrenadeMarkerUI:OnApplicationReactived()
  print(bWriteLog and "GrenadeMarkerUI:OnApplicationReactived")
  self:ClearAllMarkItems()
end
function GrenadeMarkerUI:ShowGrenadeMarker(UniqueID, GrenadeID, TargetLocation, uGrenade, SpawnTime)
  print(bWriteLog and "GrenadeMarkerUI:ShowGrenadeMarker", UniqueID, GrenadeID, TargetLocation:ToString(), SpawnTime)
  local PlayerController = UGameplayStatics.GetPlayerController(self.UIRoot, 0)
  if PlayerController and slua.isValid(PlayerController) and PlayerController:GetCurPawn() then
    local Direction = PlayerController:GetCurPawnLocation() - TargetLocation
    local length = math.sqrt(Direction.X * Direction.X + Direction.Y * Direction.Y + Direction.Z * Direction.Z)
    if length >= self.MaxShowDistance then
      print(bWriteLog and "GrenadeMarkerUI:ShowGrenadeMarker GrenadeObj is larger than MaxShowDistance")
      return
    end
    if self.GrenadeIDUIMap[UniqueID] == nil then
    end
    if self.GrenadeIDUIMap[UniqueID] == nil and self.UIRoot:GetBrushByGrenadeID(GrenadeID) ~= nil then
      print(bWriteLog and "GrenadeMarkerUI:ShowGrenadeMarker CreateMarker")
      local MarkerObj = self:CreateMarker()
      if MarkerObj then
        self.GrenadeIDUIMap[UniqueID] = MarkerObj
        local GrenadeBrush = self.UIRoot:GetBrushByGrenadeID(GrenadeID)
        MarkerObj:InitData(GrenadeID, GrenadeBrush, TargetLocation, uGrenade, SpawnTime)
      end
    end
  end
end
function GrenadeMarkerUI:HideGrenadeMarker(UniqueID)
  print(bWriteLog and "GrenadeMarkerUI:HideGrenadeMarker")
  local MarkerItem = self.GrenadeIDUIMap[UniqueID]
  if MarkerItem then
    self.MarkerPool:FreeOneItem(MarkerItem)
    MarkerItem:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.GrenadeIDUIMap[UniqueID] = nil
  end
end
function GrenadeMarkerUI:CreateMarker()
  if self.MarkerPool then
    local MarkerItem = self.MarkerPool:GetOneItem()
    if MarkerItem then
      self.UIRoot.MarkerListPanel:AddChild(MarkerItem)
      MarkerItem:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      local MarkerSlot = WidgetLayoutLibrary.SlotAsCanvasSlot(MarkerItem)
      MarkerSlot:SetAnchors(FAnchors(0.5, 0.5, 0.5, 0.5))
      MarkerSlot:SetPosition(FVector2D(0.0, 0.0))
      MarkerSlot:SetSize(FVector2D(0, 0))
      return MarkerItem
    end
  end
  return nil
end
function GrenadeMarkerUI:OnUnRegistEvents()
  print(bWriteLog and "GrenadeMarkerUI:OnUnRegistEvents")
  self.MarkerPool = nil
end
function GrenadeMarkerUI:Close()
  print(bWriteLog and "GrenadeMarkerUI:Close")
  self:ClearAllMarkItems()
  self.MarkerPool = nil
  print(bWriteLog and "GrenadeMarkerUI:Close end")
  GrenadeMarkerUI.__super.Close(self)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CGrenadeMarkerUI = class(ui_base, nil, GrenadeMarkerUI)
return CGrenadeMarkerUI