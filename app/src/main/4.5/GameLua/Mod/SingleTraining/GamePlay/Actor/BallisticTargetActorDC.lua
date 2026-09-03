local BallisticTargetActorDC = {}
function BallisticTargetActorDC:ctor()
end
function BallisticTargetActorDC:IsValidDamage(DamageAmount, DmanageEvent, EventInstigator, DamageCauser)
  return false
end
local class = require("class")
local CActorBase = require("GameLua.Mod.BaseMod.GamePlay.Component.DamageableComponent")
local CBallisticTargetActorDCClass = class(CActorBase, nil, BallisticTargetActorDC)
return CBallisticTargetActorDCClass