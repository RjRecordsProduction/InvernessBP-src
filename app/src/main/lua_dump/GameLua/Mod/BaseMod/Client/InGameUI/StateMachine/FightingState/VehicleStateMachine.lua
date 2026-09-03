local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
local UILayoutConfig = require("GameLua.Mod.BaseMod.Client.MainControlUI.UILayoutConfig")
local EJoystickOperatingMode = import("EJoystickOperatingMode")
local StateNameConfig = {
  "DriverState",
  "PassengerState"
}
local VehicleStateMachine = {}
function VehicleStateMachine:ctor()
  self.StateName = "VehicleStateMachine"
  self.CurrentVehicleDriverLayout = UILayoutConfig.LayoutNameConfig.VehicleDriverLayout
  self.CurrentState = false
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  for _, Key in pairs(StateNameConfig) do
    local StatePath = GamePlayTools.GetModPath(true, string.format("Client.InGameUI.StateMachine.VehicleState.%s", Key), true)
    local StateMudule = require(StatePath)
    if StateMudule then
      self.StateInstanceConfig[Key] = StateMudule()
    end
  end
end
function VehicleStateMachine:ChangeSubState(NewStateName)
  if self.CurrentState then
    self.CurrentState:Exit()
  end
  if NewStateName then
    self.CurrentState = self.StateInstanceConfig[NewStateName]
    self.CurrentState:Enter()
  else
    self.CurrentState = false
  end
end
function VehicleStateMachine:Enter()
  VehicleStateMachine.__super.Enter(self)
  self.CurrentSeatType = nil
  self:AddUIMessageEvent("UIMsgChangeSeatCompleted", self.OnEnterVehicleOrChangeSeatCompleted, self)
  self:OnEnterVehicleOrChangeSeatCompleted()
  self:AddCommonEvent(EVENTTYPE_PLAYEREVENT_VEHICLE, EVENTID_VEHICLE_SHOW_CONTROL_PANEL, self.OnShowControlPanel, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_VEHICLE_DEFORMATION_REENTER_VEHICLE, self.ReEnterVehicle, self)
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    PlayerController.IsPlayerUnableToDoAutoSprintOperation = true
    PlayerController.CharacterTouchMove = true
  end
  local OperateSubsystem = SubsystemMgr:Get("OperateSubsystem")
  if OperateSubsystem then
    OperateSubsystem:HideAutoSprintUI()
  end
  local VehicleControlUISubSystem = SubsystemMgr:Get("VehicleControlUISubSystem")
  if VehicleControlUISubSystem then
    local VehicleUserComponent = PlayerController:GetVehicleUserComp()
    if Game:IsValid(VehicleUserComponent) and VehicleUserComponent:HasAnyControlPanelHiddenFlag() then
      print(bWriteLog and "VehicleStateMachine:Enter, VehicleUserComponent:HasAnyControlPanelHiddenFlag()")
      VehicleControlUISubSystem:HideVehicleControlLayer()
      local PlayerController = GameplayData.GetPlayerController()
      if Game:isValid(PlayerController) then
        PlayerController:ShowTouchInterface(false)
      end
    else
      print(bWriteLog and "VehicleStateMachine:Enter, ShowVehicleControlLayer")
      VehicleControlUISubSystem:ShowVehicleControlLayer()
    end
  end
  InGameUITools.SetJoystickSprintState(false)
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(PlayerCharacter) then
    PlayerCharacter:OnVehicleStateChange()
  end
end
function VehicleStateMachine:Exit()
  VehicleStateMachine.__super.Exit(self)
  self:ChangeSubState(nil)
  local VehicleControlUISubSystem = SubsystemMgr:Get("VehicleControlUISubSystem")
  if VehicleControlUISubSystem then
    VehicleControlUISubSystem:OnExitVehicle()
    VehicleControlUISubSystem:HideVehicleControlLayer()
  end
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    PlayerController:SetJoystickOperatingMode(EJoystickOperatingMode.JSEightDirection, 0)
    PlayerController:ShowTouchInterface(true)
    PlayerController.CharacterTouchMove = true
    PlayerController.IsPlayerUnableToDoAutoSprintOperation = false
  end
  InGameUITools.SetJoystickSprintState(false)
  local PlayerCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(PlayerCharacter) then
    PlayerCharacter:OnVehicleStateChange()
  end
end
function VehicleStateMachine:ReEnterVehicle()
  self.CurrentSeatType = nil
  local VehicleControlUISubSystem = SubsystemMgr:Get("VehicleControlUISubSystem")
  if VehicleControlUISubSystem then
    VehicleControlUISubSystem:OnExitVehicle()
  end
  self:OnEnterVehicleOrChangeSeatCompleted()
end
function VehicleStateMachine:OnEnterVehicleOrChangeSeatCompleted()
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) or not PlayerController.BP_VehicleUser then
    print(bWriteLog and "VehicleControlPanel:OnEnterVehicleOrChangeSeatCompleted cont find PC or BP_VehicleUser")
    return
  end
  local ESTExtraVehicleSeatType = import("ESTExtraVehicleSeatType")
  local SeatType = PlayerController.BP_VehicleUser.SeatType
  if SeatType == ESTExtraVehicleSeatType.ESeatType_VirtualDriverSeat then
    return
  end
  if self.CurrentSeatType ~= SeatType then
    self.Current    if SeatType == ESTExtraVehicleSeatType.ESeatType_DriversSeat then
      self:ChangeSubState("DriverState")
    else
      self:ChangeSubState("PassengerState")
    end
  end
  self:DoVehicleWeaponGUI()
  InGameUITools.SetJoystickSprintState(false)
end
function VehicleStateMachine:DoVehicleWeaponGUI()
  local VehicleControlUISubSystem = SubsystemMgr:Get("VehicleControlUISubSystem")
  if VehicleControlUISubSystem then
    VehicleControlUISubSystem:DoVehicleWeaponGUI()
  end
end
function VehicleStateMachine:OnShowControlPanel(_, _, InVehicle, InShow)
  print(bWriteLog and "VehicleControlUISubSystem:OnShowControlPanel", InShow, InVehicle)
  if not Game:IsValid(InVehicle) then
    return
  end
  local PlayerController = GameplayData.GetPlayerController()
  if not Game:IsValid(PlayerController) then
    print(bWriteLog and "VehicleControlUISubSystem:OnShowControlPanel, PlayerController nil")
    return nil
  end
  local VehicleUserComponent = PlayerController:GetVehicleUserComp()
  if not Game:IsValid(VehicleUserComponent) then
    print(bWriteLog and "VehicleControlUISubSystem:OnShowControlPanel, VehicleUserComponent nil")
    return nil
  end
  if InVehicle ~= VehicleUserComponent.Vehicle then
    print(bWriteLog and "VehicleControlUISubSystem:OnShowControlPanel, InVehicle not equal VehicleUserComponent.Vehicle", InVehicle, VehicleUserComponent.Vehicle)
    return
  end
  local VehicleControlUISubSystem = SubsystemMgr:Get("VehicleControlUISubSystem")
  if VehicleControlUISubSystem then
    if InShow then
      self:ReEnterVehicle()
      VehicleControlUISubSystem:ShowVehicleControlLayer()
    else
      VehicleControlUISubSystem:OnExitVehicle()
      VehicleControlUISubSystem:HideVehicleControlLayer()
      local PlayerController = GameplayData.GetPlayerController()
      if Game:isValid(PlayerController) then
        PlayerController:ShowTouchInterface(false)
      end
    end
  end
  InGameUITools.SetJoystickSprintState(false)
end
local class = require("class")
local CDelegateContainer = require("GameLua.Mod.BaseMod.Client.InGameUI.StateMachine.StateMachine")
return class(CDelegateContainer, nil, VehicleStateMachine)