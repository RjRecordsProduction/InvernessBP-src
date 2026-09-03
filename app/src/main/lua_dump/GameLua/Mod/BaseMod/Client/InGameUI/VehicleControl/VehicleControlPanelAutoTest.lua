local WidgetBlueprintLibrary = import("WidgetBlueprintLibrary")
local ESTExtraVehicleUserState = import("ESTExtraVehicleUserState")
local VehicleControlPanelIMP = require("GameLua.Mod.BaseMod.Client.InGameUI.VehicleControl.VehicleControlPanelIMP")
function VehicleControlPanelIMP:IsPlayerOutOfVehicle()
  print(bWriteLog and "VehicleControlPanelIMP:IsPlayerOutOfVehicle")
  local VehicleUserComponent = self:GetVehicleUserComponent()
  if not VehicleUserComponent then
    print(bWriteLog and "VehicleControlPanelIMP:IsPlayerOutOfVehicle VehicleUserComponent nil")
    return true
  end
  return VehicleUserComponent.VehicleUserState == ESTExtraVehicleUserState.EVUS_OutOfVehicle
end
function VehicleControlPanelIMP:UIMsg_LeaveVehicle()
  print(bWriteLog and "VehicleControlPanelIMP:UIMsg_LeaveVehicle")
  if self:IsPlayerOutOfVehicle() then
    print(bWriteLog and "VehicleControlPanelIMP:UIMsg_LeaveVehicle PlayerOutOfVehicle")
    return
  end
  self:Msg_LeaveVehicle()
end
function VehicleControlPanelIMP:UIMsg_DriveLeftPress()
  print(bWriteLog and "VehicleControlPanelIMP:UIMsg_DriveLeftPress")
  if self:IsPlayerOutOfVehicle() then
    print(bWriteLog and "VehicleControlPanelIMP:UIMsg_DriveLeftPress PlayerOutOfVehicle")
    return
  end
  self:Msg_DriveLeftPress()
end
function VehicleControlPanelIMP:UIMsg_DriveLeftRelease()
  print(bWriteLog and "VehicleControlPanelIMP:UIMsg_DriveLeftRelease")
  if self:IsPlayerOutOfVehicle() then
    print(bWriteLog and "VehicleControlPanelIMP:UIMsg_DriveLeftRelease PlayerOutOfVehicle")
    return
  end
  self:Msg_DriveLeftRelease()
end
function VehicleControlPanelIMP:UIMsg_DriveRightPress()
  print(bWriteLog and "VehicleControlPanelIMP:UIMsg_DriveRightPress")
  if self:IsPlayerOutOfVehicle() then
    print(bWriteLog and "VehicleControlPanelIMP:UIMsg_DriveRightPress PlayerOutOfVehicle")
    return
  end
  self:Msg_DriveRightPress()
end
function VehicleControlPanelIMP:UIMsg_DriveRightRelease()
  print(bWriteLog and "VehicleControlPanelIMP:UIMsg_DriveRightRelease")
  if self:IsPlayerOutOfVehicle() then
    print(bWriteLog and "VehicleControlPanelIMP:UIMsg_DriveRightRelease PlayerOutOfVehicle")
    return
  end
  self:Msg_DriveRightRelease()
end
function VehicleControlPanelIMP:UIMsg_BleDriveForwardPress()
  print(bWriteLog and "VehicleControlPanelIMP:UIMsg_BleDriveForwardPress")
  self:BleDriveUpPress()
end
function VehicleControlPanelIMP:UIMsg_BleDriveForwardRelease()
  print(bWriteLog and "VehicleControlPanelIMP:UIMsg_BleDriveForwardRelease")
  self:BleDriveUpRelease()
end
function VehicleControlPanelIMP:UIMsg_BleBrakeOrBackForwardPress()
  print(bWriteLog and "VehicleControlPanelIMP:UIMsg_BleBrakeOrBackForwardPress")
  self:BleDriveDownPress()
end
function VehicleControlPanelIMP:UIMsg_BleBrakeOrBackForwardRelease()
  print(bWriteLog and "VehicleControlPanelIMP:UIMsg_BleBrakeOrBackForwardRelease")
  self:BleDriveDownRelease()
end
function VehicleControlPanelIMP:UIMsg_VehicleLiftUpPress()
  print(bWriteLog and "VehicleControlPanelIMP:UIMsg_VehicleLiftUpPress")
  if self:IsPlayerOutOfVehicle() then
    print(bWriteLog and "VehicleControlPanelIMP:UIMsg_VehicleLiftUpPress PlayerOutOfVehicle")
    return
  end
  self:Msg_VehicleLiftUpPress()
end
function VehicleControlPanelIMP:UIMsg_VehicleLiftUpRelease()
  print(bWriteLog and "VehicleControlPanelIMP:UIMsg_VehicleLiftUpRelease")
  if self:IsPlayerOutOfVehicle() then
    print(bWriteLog and "VehicleControlPanelIMP:UIMsg_VehicleLiftUpRelease PlayerOutOfVehicle")
    return
  end
  self:Msg_VehicleLiftUpRelease()
end
function VehicleControlPanelIMP:UIMsg_VehiclePushDownPress()
  print(bWriteLog and "VehicleControlPanelIMP:UIMsg_VehiclePushDownPress")
  if self:IsPlayerOutOfVehicle() then
    print(bWriteLog and "VehicleControlPanelIMP:UIMsg_VehiclePushDownPress PlayerOutOfVehicle")
    return
  end
  self:Msg_VehiclePushDownPress()
end
function VehicleControlPanelIMP:UIMsg_VehiclePushDownRelease()
  print(bWriteLog and "VehicleControlPanelIMP:UIMsg_VehiclePushDownRelease")
  if self:IsPlayerOutOfVehicle() then
    print(bWriteLog and "VehicleControlPanelIMP:UIMsg_VehiclePushDownRelease PlayerOutOfVehicle")
    return
  end
  self:Msg_VehiclePushDownRelease()
end
function VehicleControlPanelIMP:UIMsg_VehicleChangeSeat()
  print(bWriteLog and "VehicleControlPanelIMP:UIMsg_VehicleChangeSeat")
  if self:IsPlayerOutOfVehicle() then
    print(bWriteLog and "VehicleControlPanelIMP:UIMsg_VehicleChangeSeat PlayerOutOfVehicle")
    return
  end
  self:Msg_VehicleChangeSeat()
end
function VehicleControlPanelIMP:UIMsg_VehicleSpeedUpPress()
  print(bWriteLog and "VehicleControlPanelIMP:UIMsg_VehicleSpeedUpPress")
  if self:IsPlayerOutOfVehicle() then
    print(bWriteLog and "VehicleControlPanelIMP:UIMsg_VehicleSpeedUpPress PlayerOutOfVehicle")
    return
  end
  self:Msg_VehicleSpeedUpPress()
end
function VehicleControlPanelIMP:UIMsg_VehicleSpeedUpRelease()
  print(bWriteLog and "VehicleControlPanelIMP:UIMsg_VehicleSpeedUpRelease")
  if self:IsPlayerOutOfVehicle() then
    print(bWriteLog and "VehicleControlPanelIMP:UIMsg_VehicleSpeedUpRelease PlayerOutOfVehicle")
    return
  end
  self:Msg_VehicleSpeedUpRelease()
end
function VehicleControlPanelIMP:UIMsg_VehicleSpeakerPress()
  print(bWriteLog and "VehicleControlPanelIMP:UIMsg_VehicleSpeakerPress")
  if self:IsPlayerOutOfVehicle() then
    print(bWriteLog and "VehicleControlPanelIMP:UIMsg_VehicleSpeakerPress PlayerOutOfVehicle")
    return
  end
  self:SpeakerPress()
end
function VehicleControlPanelIMP:UIMsg_VehicleSpeakerRelease()
  print(bWriteLog and "VehicleControlPanelIMP:UIMsg_VehicleSpeakerRelease")
  if self:IsPlayerOutOfVehicle() then
    print(bWriteLog and "VehicleControlPanelIMP:UIMsg_VehicleSpeakerRelease PlayerOutOfVehicle")
    return
  end
  self:SpeakerRelease()
end
function VehicleControlPanelIMP:UIMsg_VehicleLeanOutOrIn()
  print(bWriteLog and "VehicleControlPanelIMP:UIMsg_VehicleLeanOutOrIn")
  if self:IsPlayerOutOfVehicle() then
    print(bWriteLog and "VehicleControlPanelIMP:UIMsg_VehicleLeanOutOrIn PlayerOutOfVehicle")
    return
  end
  self:Msg_VehicleLeanOutOrIn()
end
function VehicleControlPanelIMP:UIMsg_VehicleUpdateSpped()
  print(bWriteLog and "VehicleControlPanelIMP:UIMsg_VehicleUpdateSpped")
  local VehicleUserComponent = self:GetVehicleUserComponent()
  if not VehicleUserComponent then
    print(bWriteLog and "VehicleControlPanelIMP:UIMsg_VehicleUpdateSpped nil")
    return
  end
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_VEHICLE_CONTROL_UI_UPDATE_GUI_SPEED, VehicleUserComponent.RawSpeed, 0, 0)
end
function VehicleControlPanelIMP:BleDriveUpPress()
  print(bWriteLog and "VehicleControlPanelIMP:BleDriveUpPress")
  self:OnPressed_DriveUp()
end
function VehicleControlPanelIMP:BleDriveUpRelease()
  print(bWriteLog and "VehicleControlPanelIMP:BleDriveUpRelease")
  self:OnReleased_DriveUp()
end
function VehicleControlPanelIMP:BleDriveDownPress()
  print(bWriteLog and "VehicleControlPanelIMP:BleDriveDownPress")
  self:OnPressed_DriveDown()
end
function VehicleControlPanelIMP:BleDriveDownRelease()
  print(bWriteLog and "VehicleControlPanelIMP:BleDriveDownRelease")
  self:OnReleased_DriveDown()
end
function VehicleControlPanelIMP:Msg_VehicleLiftUpPress()
  print(bWriteLog and "VehicleControlPanelIMP:Msg_VehicleLiftUpPress")
  local VehicleUserComponent = self:GetVehicleUserComponent()
  if not VehicleUserComponent then
    return
  end
  VehicleUserComponent:SetAirControlF(-1.0)
end
function VehicleControlPanelIMP:Msg_VehiclePushDownPress()
  print(bWriteLog and "VehicleControlPanelIMP:Msg_VehiclePushDownPress")
  local VehicleUserComponent = self:GetVehicleUserComponent()
  if not VehicleUserComponent then
    print(bWriteLog and "VehicleControlPanelIMP:Msg_VehiclePushDownPress nil")
    return
  end
  VehicleUserComponent:SetAirControlB(1.0)
end
function VehicleControlPanelIMP:Msg_LeaveVehicle()
  print(bWriteLog and "VehicleControlPanelIMP:Msg_LeaveVehicle")
  if self.UIRoot.PanelVehicleCommonGUI2:GetVisibility() == UEnums.ESlateVisibility.SelfHitTestInvisible then
    local VehicleUserComponent = self:GetVehicleUserComponent()
    if not VehicleUserComponent then
      print(bWriteLog and "VehicleControlPanelIMP:Msg_LeaveVehicle VehicleUserComponent nil")
      return
    end
    VehicleUserComponent:ExitVehicle()
    return WidgetBlueprintLibrary.Handled()
  end
end
function VehicleControlPanelIMP:Msg_DriveLeftPress()
  print(bWriteLog and "VehicleControlPanelIMP:Msg_DriveLeftPress")
  local VehicleUserComponent = self:GetVehicleUserComponent()
  if not VehicleUserComponent then
    print(bWriteLog and "VehicleControlPanelIMP:Msg_DriveLeftPress nil")
    return
  end
  VehicleUserComponent:MoveVehicleRight(-1.0)
end
function VehicleControlPanelIMP:Msg_DriveRightPress()
  print(bWriteLog and "VehicleControlPanelIMP:Msg_DriveRightPress")
  local VehicleUserComponent = self:GetVehicleUserComponent()
  if not VehicleUserComponent then
    print(bWriteLog and "VehicleControlPanelIMP:Msg_DriveRightPress nil")
    return
  end
  VehicleUserComponent:MoveVehicleRight(1.0)
end
function VehicleControlPanelIMP:Msg_VehicleChangeSeat()
  print(bWriteLog and "VehicleControlPanelIMP:Msg_VehicleChangeSeat")
  local VehicleUserComponent = self:GetVehicleUserComponent()
  if not VehicleUserComponent then
    print(bWriteLog and "VehicleControlPanelIMP:Msg_VehicleChangeSeat nil")
    return
  end
  VehicleUserComponent:TryChangeVehicleSeat()
end
function VehicleControlPanelIMP:Msg_VehicleSpeedUpPress()
  print(bWriteLog and "VehicleControlPanelIMP:Msg_VehicleSpeedUpPress")
  local VehicleUserComponent = self:GetVehicleUserComponent()
  if not VehicleUserComponent then
    print(bWriteLog and "VehicleControlPanelIMP:Msg_VehicleSpeedUpPress VehicleUserComponent nil")
    return
  end
  if not slua.isValid(VehicleUserComponent.Vehicle) or not VehicleUserComponent.Vehicle.bCanBoostSpeed then
    print(bWriteLog and "VehicleControlPanelIMP:Msg_VehicleSpeedUpPress Vehicle nil or bCanBoostSpeed false")
    return
  end
  local VehicleControlUISpeed = UIManager.GetUI(UIManager.UI_Config_InGame.VehicleControlUISpeed)
  if VehicleControlUISpeed then
    VehicleControlUISpeed:OnPressed_Button_SpeedUp()
  end
end
function VehicleControlPanelIMP:Msg_VehicleSpeedUpRelease()
  print(bWriteLog and "VehicleControlPanelIMP:Msg_VehicleSpeedUpRelease")
  local VehicleUserComponent = self:GetVehicleUserComponent()
  if not VehicleUserComponent then
    print(bWriteLog and "VehicleControlPanelIMP:Msg_VehicleSpeedUpRelease VehicleUserComponent nil")
    return
  end
  if not slua.isValid(VehicleUserComponent.Vehicle) or not VehicleUserComponent.Vehicle.bCanBoostSpeed then
    print(bWriteLog and "VehicleControlPanelIMP:Msg_VehicleSpeedUpRelease Vehicle nil or bCanBoostSpeed false")
    return
  end
  local VehicleControlUISpeed = UIManager.GetUI(UIManager.UI_Config_InGame.VehicleControlUISpeed)
  if VehicleControlUISpeed then
    VehicleControlUISpeed:OnReleased_Button_SpeedUp()
  end
end
function VehicleControlPanelIMP:Msg_VehicleLeanOutOrIn()
  print(bWriteLog and "VehicleControlPanelIMP:Msg_VehicleLeanOutOrIn")
  local VehicleUserComponent = self:GetVehicleUserComponent()
  if not VehicleUserComponent then
    print(bWriteLog and "VehicleControlPanelIMP:Msg_VehicleLeanOutOrIn nil")
    return
  end
  VehicleUserComponent:TryLeanOutOrIn(false, false)
end
function VehicleControlPanelIMP:Msg_VehicleLiftUpRelease()
  print(bWriteLog and "VehicleControlPanelIMP:Msg_VehicleLiftUpRelease")
  local VehicleUserComponent = self:GetVehicleUserComponent()
  if not VehicleUserComponent then
    print(bWriteLog and "VehicleControlPanelIMP:Msg_VehicleLiftUpRelease nil")
    return
  end
  VehicleUserComponent:SetAirControlF(0.0)
end
function VehicleControlPanelIMP:Msg_VehiclePushDownRelease()
  print(bWriteLog and "VehicleControlPanelIMP:Msg_VehiclePushDownRelease")
  local VehicleUserComponent = self:GetVehicleUserComponent()
  if not VehicleUserComponent then
    print(bWriteLog and "VehicleControlPanelIMP:Msg_VehiclePushDownRelease nil")
    return
  end
  VehicleUserComponent:SetAirControlB(1.0)
end
function VehicleControlPanelIMP:Msg_DriveLeftRelease()
  print(bWriteLog and "VehicleControlPanelIMP:Msg_DriveLeftRelease")
  local VehicleUserComponent = self:GetVehicleUserComponent()
  if not VehicleUserComponent then
    print(bWriteLog and "VehicleControlPanelIMP:Msg_DriveLeftRelease nil")
    return
  end
  VehicleUserComponent:MoveVehicleRight(0.0)
end
function VehicleControlPanelIMP:Msg_DriveRightRelease()
  print(bWriteLog and "VehicleControlPanelIMP:Msg_DriveRightRelease")
  local VehicleUserComponent = self:GetVehicleUserComponent()
  if not VehicleUserComponent then
    print(bWriteLog and "VehicleControlPanelIMP:Msg_DriveRightRelease nil")
    return
  end
  VehicleUserComponent:MoveVehicleRight(0.0)
end