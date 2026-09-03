local CanvasAction_VehicleUIChanged = {
  sActionName = "CanvasAction_VehicleUIChanged"
}
function CanvasAction_VehicleUIChanged:BindEvent()
  if not self.Config.Show and not self.Config.Hide then
    return
  end
  self:AddCommonEvent(EVENTYPE_INGAME_VEHICLE_CONTROL_PANEL, EVENTID_VEHICLE_UIVISIBILITY_CHANGED, self.OnSwitchUIOperation, self)
  local UGCUIControllerSubsystem = SubsystemMgr:Get("UGCUIControllerSubsystem")
  if UGCUIControllerSubsystem and UGCUIControllerSubsystem.GetVehicleExitOperationFlag then
    local VehicleExitOperationFlag = UGCUIControllerSubsystem:GetVehicleExitOperationFlag()
    if VehicleExitOperationFlag ~= nil then
      local VehicleControlUIFlag = require("GameLua.Mod.BaseMod.Client.Config.VehicleControlUIFlag")
      self:OnSwitchUIOperation(nil, nil, VehicleControlUIFlag.VehicleExitOperation, VehicleExitOperationFlag)
    end
  end
end
function CanvasAction_VehicleUIChanged:UnbindEvent()
  self:RemoveCommonEvent(EVENTYPE_INGAME_VEHICLE_CONTROL_PANEL, EVENTID_VEHICLE_UIVISIBILITY_CHANGED)
end
function CanvasAction_VehicleUIChanged:OnSwitchUIOperation(_1, _2, VehicleOperation, OperationValue)
  if not slua.isValid(CGameState) then
    return
  end
  local UGameplayStatics = import("GameplayStatics")
  local uPlayerController = UGameplayStatics.GetPlayerController(CGameState, 0)
  if slua.isValid(uPlayerController) then
    if self.Config.Show then
      self.bIsShow = self:HasValue(self.Config.Show, VehicleOperation, OperationValue)
    elseif self.Config.Hide then
      self.bIsShow = not self:HasValue(self.Config.Hide, VehicleOperation, OperationValue)
    end
  end
  self:UpdateCanvasShow()
end
function CanvasAction_VehicleUIChanged:HasValue(ConfigFlags, FlagName, FlagValue)
  if ConfigFlags[FlagName] == FlagValue then
    return true
  end
  return false
end
local class = require("class")
local CanvasActionBase = require("GameLua.Mod.BaseMod.Common.UICanvas.Action.CanvasActionBase")
local CCanvasAction_VehicleUIChanged = class(CanvasActionBase, nil, CanvasAction_VehicleUIChanged)
return CCanvasAction_VehicleUIChanged