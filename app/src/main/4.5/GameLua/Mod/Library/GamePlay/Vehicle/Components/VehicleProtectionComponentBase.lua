local VehicleProtectionComponentBase = {
  LuaEventContainer = {
    "OnPhysicsHit"
  }
}
function VehicleProtectionComponentBase:ctor()
  self.OnPhysicsHitDelegate = "OnPhysicsHit"
end
function VehicleProtectionComponentBase:OnPhysicsHitExt(InOtherActor, InOtherComponent, InHit)
  if not slua.isValid(self.Object) then
    return
  end
  self:LuaBroadcast(self.OnPhysicsHitDelegate, InOtherActor, InOtherComponent, InHit)
end
local class = require("class")
local CActorComponentBase = require("GameLua.Mod.BaseMod.Common.Core.ActorComponentBase")
return class(CActorComponentBase, nil, VehicleProtectionComponentBase)