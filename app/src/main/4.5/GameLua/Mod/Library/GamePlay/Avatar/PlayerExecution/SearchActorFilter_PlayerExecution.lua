local SearchActorFilter_PlayerExecution = {}
local EPawnState = import("EPawnState")
function SearchActorFilter_PlayerExecution:LuaIsValidFilterActor(InActor, InOwner, bPrintLog)
  if not slua.isValid(InOwner) then
    return false
  end
  if not slua.isValid(InActor) then
    return false
  end
  if InActor == InOwner then
    return false
  end
  if InOwner.IsRescueingOther then
    return false
  end
  if InActor.bHidden then
    return false
  end
  if InActor.IsBeingRescued then
    return false
  end
  if not InOwner.HasState then
    return false
  end
  if not InOwner:HasState(EPawnState.Stand) then
    return false
  end
  if InOwner:HasState(EPawnState.CarryBack) or InOwner:HasState(EPawnState.BeCarriedBack) or InOwner:HasState(EPawnState.Save) or InOwner:HasState(EPawnState.CarryBox) or InOwner:HasState(EPawnState.CoopVault) or InOwner:HasState(EPawnState.CoopVaultPrepare) or InOwner:HasState(EPawnState.Swim) or InOwner:HasState(EPawnState.Build) or InOwner:HasState(EPawnState.ControlWeapon) or InOwner:HasState(EPawnState.DriveVehicle) or InOwner:HasState(EPawnState.InVehicle) or InOwner:HasState(EPawnState.LeanOutVehicle) or InOwner:HasState(EPawnState.ControlUnmannedVehicle) or InOwner:HasState(EPawnState.RemoteControlVehicle) or InOwner:HasState(EPawnState.DriveMovePlatForm) then
    return false
  end
  if not InActor.HasState then
    return false
  end
  if InActor:HasState(EPawnState.InVehicle) or InActor:HasState(EPawnState.BeCarriedBack) then
    return false
  end
  if not InOwner.IsExecutingOther or InOwner:IsExecutingOther() then
    return false
  end
  if not InOwner.IsNearDeath or InOwner:IsNearDeath() then
    return false
  end
  if not InOwner.IsSameTeam or InOwner:IsSameTeam(InActor) then
    return false
  end
  if not InActor.GetActorEnableCollision or not InActor:GetActorEnableCollision() then
    return false
  end
  if not InActor.IsNearDeath or not InActor:IsNearDeath() then
    return false
  end
  if not InActor.IsBeingExecuted or InActor:IsBeingExecuted() then
    return false
  end
  if not InOwner.GetRescueOtherComponent then
    return false
  end
  local RescueComp = InOwner:GetRescueOtherComponent()
  if not RescueComp then
    return false
  end
  return RescueComp:CheckOtherGeometryOnly(InActor, InOwner, true, bPrintLog)
end
local object = require("object")
local class = require("class")
return class(object, nil, SearchActorFilter_PlayerExecution)