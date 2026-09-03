local EPawnState = import("EPawnState")
local KismetInputLibrary = import("KismetInputLibrary")
local SlateBlueprintLibrary = import("SlateBlueprintLibrary")
local WidgetBlueprintLibrary = import("WidgetBlueprintLibrary")
local UUIDataProcessingFunctionLibrary = import("UIDataProcessingFunctionLibrary")
local VehicleSeatUtil = require("GameLua.Mod.BaseMod.Client.InGameUI.VehicleControl.Seat.VehicleSeatUtil")
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local TriggerMoveSelectThreshold = 12
local OperationModeEnum = {
  None = 0,
  ClickOperation = 1,
  MoveOperation = 2
}
local BaseSeatGeneralUI = {}
function BaseSeatGeneralUI:ctor()
  self.CurrentSeatPopupUIConfig = nil
  self.ShowSeatPopupUITimer = nil
  self.Image_SeatBGs = {}
  self.Image_SeatTags = {}
  self.bTouchStart = false
  self.OperationMode = OperationModeEnum.None
  self.SeatIndex2RealIndexMap = {}
  self.RealIndex2SeatIndexMap = {}
  self.CurrentRealSeatIndex = -1
  self.TouchStartNormalizedPosition = FVector2D(0, 0)
  self.NormalizedTempPosition = FVector2D(0, 0)
  self.DirectionTable = {
    [1] = {
      Right = 2,
      Down = 3,
      RightDown = 4
    },
    [2] = {
      Left = 1,
      Down = 4,
      LeftDown = 3
    },
    [3] = {
      Up = 1,
      Down = 5,
      Right = 4,
      RightUp = 2,
      RightDown = 6
    },
    [4] = {
      Up = 2,
      Down = 6,
      Left = 3,
      LeftUp = 1,
      LeftDown = 5
    },
    [5] = {
      Up = 3,
      Down = 7,
      Right = 6,
      RightUp = 4,
      RightDown = 8
    },
    [6] = {
      Up = 4,
      Down = 8,
      Left = 5,
      LeftUp = 3,
      LeftDown = 7
    },
    [7] = {
      Up = 5,
      Right = 8,
      RightUp = 6
    },
    [8] = {
      Up = 6,
      Left = 7,
      LeftUp = 5
    }
  }
end
function BaseSeatGeneralUI:OnInitialize()
  local table_insert = table.insert
  for i = 0, 7 do
    table_insert(self.Image_SeatBGs, self.UIRoot["Image_SeatBG_" .. i])
    table_insert(self.Image_SeatTags, self.UIRoot["Image_SeatTag_" .. i])
  end
end
function BaseSeatGeneralUI:RegistEvents()
  self.UIRoot.Button_ChangeSeat:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
  self:AddControlEventByControl(self.UIRoot.Button_ChangeSeat, "OnPressed", self.OnPressed_Button_ChangeSeat, self)
  self:AddControlEventByControl(self.UIRoot.Button_ChangeSeat, "OnReleased", self.OnReleased_Button_ChangeSeat, self)
  self:AddControlEventByControl(self.UIRoot, "OnTouchStart", self.OnTouchStart, self)
  self:AddControlEventByControl(self.UIRoot, "OnTouchMove", self.OnTouchMove, self)
  self:AddControlEventByControl(self.UIRoot, "OnTouchEnd", self.OnTouchEnd, self)
  GameplayData.AddSelfPlayerControllerEvent(self, "ClientOnEnterVehicle", function()
    self:VehicleUpdateSeatUI()
    local VehicleUserComponent = self:GetVehicleUserComponent()
    if not (slua.isValid(VehicleUserComponent) and slua.isValid(VehicleUserComponent.Vehicle)) or not slua.isValid(VehicleUserComponent.Vehicle.VehicleSeats) then
      return
    end
    local Vehicle = VehicleUserComponent.Vehicle
    local VehicleSeats = Vehicle.VehicleSeats
    self:AddControlEventByControl(VehicleSeats, "OnUpdateSeatGUI", self.VehicleUpdateSeatUI, self)
  end)
end
function BaseSeatGeneralUI:OnTouchStart(InGeometry, MouseEvent)
  print(bWriteLog and "BaseSeatGeneralUI:OnTouchStart")
  self.bTouchStart = true
  self.StartScreenSpacePosition = KismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
  self.OperationMode = OperationModeEnum.None
  self:OnPressed_Button_ChangeSeat()
  local Handled = WidgetBlueprintLibrary.Handled()
  local Capture = WidgetBlueprintLibrary.CaptureMouse(Handled, self.UIRoot)
  return Capture
end
function BaseSeatGeneralUI:OnTouchMove(InGeometry, MouseEvent)
  if not self.bTouchStart then
    return
  end
  print(bWriteLog and "BaseSeatGeneralUI:OnTouchMove")
  if self.OperationMode ~= OperationModeEnum.None then
    return
  end
  local MoveScreenSpacePosition = KismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
  local Offset = MoveScreenSpacePosition - self.StartScreenSpacePosition
  local Dis = math.sqrt(Offset.X * Offset.X + Offset.Y * Offset.Y)
  print(bWriteLog and "BaseSeatGeneralUI:OnTouchMove Dis", Dis)
  if Dis > TriggerMoveSelectThreshold then
    self.OperationMode = OperationModeEnum.MoveOperation
    if self.ShowSeatPopupUITimer then
      self:RemoveGameTimer(self.ShowSeatPopupUITimer)
      self.ShowSeatPopupUITimer = nil
    end
  end
end
function BaseSeatGeneralUI:OnTouchEnd(InGeometry, MouseEvent)
  if not self.bTouchStart then
    return
  end
  self.bTouchStart = false
  print(bWriteLog and "BaseSeatGeneralUI:OnTouchEnd")
  if self.OperationMode == OperationModeEnum.MoveOperation then
    self:TryChangeSeat(InGeometry, MouseEvent)
  end
  self:OnReleased_Button_ChangeSeat()
  self.OperationMode = OperationModeEnum.None
  local Handled = WidgetBlueprintLibrary.Handled()
  local Capture = WidgetBlueprintLibrary.ReleaseMouseCapture(Handled)
  return Capture
end
function BaseSeatGeneralUI:TryChangeSeat(InGeometry, MouseEvent)
  local SeatIndex = self.RealIndex2SeatIndexMap[self.CurrentRealSeatIndex]
  if not SeatIndex then
    return
  end
  local EndScreenSpacePosition = KismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
  local Offset = EndScreenSpacePosition - self.StartScreenSpacePosition
  local DirectionName = "None"
  if math.abs(Offset.X) > math.abs(Offset.Y) then
    DirectionName = Offset.X > 0 and "Right" or "Left"
    if math.abs(Offset.Y) > math.tan(math.pi / 10.2) * math.abs(Offset.X) then
      if Offset.Y > 0 then
        DirectionName = DirectionName .. "Down"
      else
        DirectionName = DirectionName .. "Up"
      end
    end
  else
    DirectionName = Offset.Y > 0 and "Down" or "Up"
    if math.abs(Offset.X) > math.tan(math.pi / 10.2) * math.abs(Offset.Y) then
      if Offset.X > 0 then
        DirectionName = "Right" .. DirectionName
      else
        DirectionName = "Left" .. DirectionName
      end
    end
  end
  local NewIndex = self.DirectionTable[SeatIndex][DirectionName]
  if not NewIndex then
    return
  end
  local RealIndex = self.SeatIndex2RealIndexMap[NewIndex]
  print(bWriteLog and string.format("BaseSeatPopupUI:ChangeSeat, RealIndex:%s", tostring(RealIndex)))
  if RealIndex == nil then
    return
  end
  local VehicleUserComponent = self:GetVehicleUserComponent()
  if not VehicleUserComponent then
    print(bWriteLog and "BaseSeatGeneralUI:TryChangeSeat VehicleUserComponent nil")
    return
  end
  VehicleUserComponent:TryChangeToVehicleSeat(RealIndex)
end
function BaseSeatGeneralUI:StartPreviewSeat(InGeometry, MouseEvent)
  if not self.CurrentSeatAbsolutePosition then
    return
  end
  local ScreenSpacePosition = KismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
  self.NormalizedTempPosition.X = self.CurrentSeatAbsolutePosition.X + (ScreenSpacePosition.X - self.CurrentSeatAbsolutePosition.X)
  self.NormalizedTempPosition.Y = self.CurrentSeatAbsolutePosition.Y + (ScreenSpacePosition.Y - self.CurrentSeatAbsolutePosition.Y)
  for RealIndex, Index in pairs(self.RealIndex2SeatIndexMap) do
    local ImageBG = self.Image_SeatBGs[Index]
    if ImageBG and SlateBlueprintLibrary.IsUnderLocation(ImageBG:GetCachedGeometry(), self.NormalizedTempPosition) then
      ImageBG:SetColorAndOpacity(FLinearColor(0.0, 1.0, 0.0, 1.0))
      self.CurrentSeatAbsolutePosition = SlateBlueprintLibrary.GetAbsolutePosition(ImageBG:GetCachedGeometry())
      break
    end
  end
end
function BaseSeatGeneralUI:OnShow()
  self:VehicleUpdateSeatUI()
  local VehicleUserComponent = self:GetVehicleUserComponent()
  if not (slua.isValid(VehicleUserComponent) and slua.isValid(VehicleUserComponent.Vehicle)) or not slua.isValid(VehicleUserComponent.Vehicle.VehicleSeats) then
    return
  end
  local Vehicle = VehicleUserComponent.Vehicle
  local VehicleSeats = Vehicle.VehicleSeats
  self:AddControlEventByControl(VehicleSeats, "OnUpdateSeatGUI", self.VehicleUpdateSeatUI, self)
end
function BaseSeatGeneralUI:OnHide()
  self:CloseSeatPopupUI()
  local VehicleUserComponent = self:GetVehicleUserComponent()
  if not (slua.isValid(VehicleUserComponent) and slua.isValid(VehicleUserComponent.Vehicle)) or not slua.isValid(VehicleUserComponent.Vehicle.VehicleSeats) then
    return
  end
  local Vehicle = VehicleUserComponent.Vehicle
  local VehicleSeats = Vehicle.VehicleSeats
  self:RemoveControlEventByControl(VehicleSeats, "OnUpdateSeatGUI")
end
function BaseSeatGeneralUI:GetVehicleUserComponent()
  local VehicleControlUISubSystem = SubsystemMgr:Get("VehicleControlUISubSystem")
  if VehicleControlUISubSystem then
    return VehicleControlUISubSystem:GetVehicleUserComponent()
  end
end
function BaseSeatGeneralUI:CloseSeatPopupUI()
  if self.CurrentSeatPopupUIConfig then
    local CurrentSeatPopupUI = UIManager.GetUI(self.CurrentSeatPopupUIConfig)
    if CurrentSeatPopupUI and CurrentSeatPopupUI:IsShow() then
      UIManager.CloseUI(self.CurrentSeatPopupUIConfig)
    end
  end
end
function BaseSeatGeneralUI:OnClose()
  print(bWriteLog and "BaseSeatGeneralUI:OnClose")
end
function BaseSeatGeneralUI:VehicleUpdateSeatUI()
  self:UpdateGUISeats()
  local VehicleUserComponent = self:GetVehicleUserComponent()
  if not VehicleUserComponent then
    return
  end
  local Vehicle = VehicleUserComponent.Vehicle
  if not slua.isValid(Vehicle) then
    return
  end
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  if not PlayerController.bIsPressingFireBtn then
    return
  end
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) then
    return
  end
  if PlayerCharacter:HasState(EPawnState.LeanOutVehicle) then
    return
  end
  VehicleUserComponent:TryLeanOutOrIn(true, false)
end
function BaseSeatGeneralUI:UpdateGUISeats()
  self.CurrentRealSeatIndex = VehicleSeatUtil.UpdateGUISeats(self:GetVehicleUserComponent(), self.Image_SeatBGs, false, self.Image_SeatTags, self.SeatIndex2RealIndexMap)
  for Index, RealIndex in pairs(self.SeatIndex2RealIndexMap) do
    self.RealIndex2SeatIndexMap[RealIndex] = Index
  end
end
function BaseSeatGeneralUI:OnPressed_Button_ChangeSeat()
  print(bWriteLog and "BaseSeatGeneralUI:OnPressed_Button_ChangeSeat")
  local VehicleUserComponent = self:GetVehicleUserComponent()
  if not VehicleUserComponent then
    print(bWriteLog and "BaseSeatGeneralUI:OnPressed_Button_ChangeSeat VehicleUserComponent nil")
    return
  end
  if not slua.isValid(VehicleUserComponent.Vehicle) then
    print(bWriteLog and "BaseSeatGeneralUI:OnPressed_Button_ChangeSeat Vehicle nil")
    return
  end
  if self.ShowSeatPopupUITimer then
    self:RemoveGameTimer(self.ShowSeatPopupUITimer)
    self.ShowSeatPopupUITimer = nil
  end
  self.ShowSeatPopupUITimer = self:AddGameTimer(0.5, false, function()
    self.OperationMode = OperationModeEnum.ClickOperation
    self.ShowSeatPopupUITimer = nil
    local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
    if SettingConfig and SettingConfig.CarPreciseChangeSeat and self:CanShowChangeSeatAccurate() then
      self:ShowSeatPopupUI()
    end
  end)
end
function BaseSeatGeneralUI:OnReleased_Button_ChangeSeat()
  print(bWriteLog and "BaseSeatGeneralUI:OnReleased_Button_ChangeSeat")
  if self.ShowSeatPopupUITimer then
    self:RemoveGameTimer(self.ShowSeatPopupUITimer)
    self.ShowSeatPopupUITimer = nil
    local VehicleUserComponent = self:GetVehicleUserComponent()
    if VehicleUserComponent then
      VehicleUserComponent:CacheLastUseWeaponSlot()
      VehicleUserComponent:TryChangeVehicleSeat()
    end
  end
end
function BaseSeatGeneralUI:CanShowChangeSeatAccurate()
  print(bWriteLog and "BaseSeatGeneralUI:CanShowChangeSeatAccurate")
  local VehicleUserComponent = self:GetVehicleUserComponent()
  if not slua.isValid(VehicleUserComponent) then
    print(bWriteLog and "BaseSeatGeneralUI:CanShowChangeSeatAccurate VehicleUserComponent nil")
    return false
  end
  local Vehicle = VehicleUserComponent.Vehicle
  if not slua.isValid(Vehicle) then
    print(bWriteLog and "BaseSeatGeneralUI:CanShowChangeSeatAccurate Vehicle nil")
    return false
  end
  local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
  if not slua.isValid(SettingConfig) then
    return false
  end
  if SettingConfig.ChangeSeatAccurately or Vehicle.bCanChangeSeatAccurately then
    return true
  end
  return Vehicle:IsArmedVehicle()
end
function BaseSeatGeneralUI:ShowSeatPopupUI()
  self:Collapsed()
  local VehicleControlPanel = InGameUITools.GetVehicleControlPanelLuaClass()
  if VehicleControlPanel then
    VehicleControlPanel:CreateChildWindow("CanvasPanel_0", self.CurrentSeatPopupUIConfig, self._config)
  end
end
function BaseSeatGeneralUI:GetVehicleUserComponent()
  local VehicleControlUISubSystem = SubsystemMgr:Get("VehicleControlUISubSystem")
  if VehicleControlUISubSystem then
    return VehicleControlUISubSystem:GetVehicleUserComponent()
  end
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
return class(UIBase, nil, BaseSeatGeneralUI)