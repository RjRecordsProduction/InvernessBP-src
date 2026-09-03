local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local BackToDriverButton = {}
function BackToDriverButton:OnInitialize()
  self:SetAnchors(0, 0, 1, 1)
  self:SetOffsets(0, 0, 0, 0)
  self.UIRoot.TextBlock_Name:SetText(LocUtil.GetLocalizeResStr(38713))
end
function BackToDriverButton:RegistEvents()
  self:AddOnClickedEventByControl(self.UIRoot.Button_Driver, self.OnClickButton_Driver, self)
  self:AddDataListener(GameplayData.GetSuperData(), "PlayerCharacter", self.OnPlayerCharacterChange, self)
end
function BackToDriverButton:OnPlayerCharacterChange(OldPlayerCharacter, PlayerCharacter)
  if slua.isValid(OldPlayerCharacter) then
    self:RemoveControlEventByControl(OldPlayerCharacter, "OnAttachedToVehicle")
  end
  if slua.isValid(PlayerCharacter) then
    self:AddControlEventByControl(PlayerCharacter, "OnAttachedToVehicle", self.OnAttachedToVehicle_Handle, self)
  end
  self:OnAttachedToVehicle_Handle()
end
function BackToDriverButton:OnAttachedToVehicle_Handle()
  self.UIRoot.CanvasPanel_Root:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) or not PlayerCharacter.GetCurrentVehicle then
    return
  end
  local CurrentVehicle = PlayerCharacter:GetCurrentVehicle()
  if not slua.isValid(CurrentVehicle) or not CurrentVehicle.GetVehicleSeats then
    return
  end
  local VehicleSeatComponent = CurrentVehicle:GetVehicleSeats()
  if not slua.isValid(VehicleSeatComponent) then
    return
  end
  local VehicleSeatType = VehicleSeatComponent:GetCharacterSeatType(PlayerCharacter)
  local ESTExtraVehicleSeatType = import("ESTExtraVehicleSeatType")
  if VehicleSeatType ~= ESTExtraVehicleSeatType.ESeatType_ShootDriver then
    return
  end
  local VehicleShootDriverConfig = require("GameLua.GameCore.Module.Vehicle.Config.VehicleShootDriverConfig")
  if not VehicleShootDriverConfig or not VehicleShootDriverConfig.GetCfg(CurrentVehicle) then
    return
  end
  self.UIRoot.CanvasPanel_Root:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
end
function BackToDriverButton:OnClickButton_Driver()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(PlayerCharacter) or not PlayerCharacter.CurrentVehicle then
    return
  end
  local VehicleUserComponent = PlayerController:GetVehicleUserComp()
  if not slua.isValid(VehicleUserComponent) then
    return
  end
  local Vehicle = PlayerCharacter:GetCurrentVehicle()
  if not slua.isValid(Vehicle) or not slua.isValid(Vehicle.ShootDriverComponent) then
    return
  end
  VehicleUserComponent:TryChangeToVehicleSeat(Vehicle.ShootDriverComponent.OriginalDriverSeatIndex)
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
return class(UIBase, nil, BackToDriverButton)