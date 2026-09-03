local HandleItemHandleEvent = {}
function HandleItemHandleEvent:ctor(selfType)
end
function HandleItemHandleEvent:HandleInitWeaponHandle(EventType, EventID, WeaponHandle)
  print(bWriteLog and "HandleItemHandleEvent:HandleInitWeaponHandle", self.bIsClient, WeaponHandle)
  local WeaponSystem = require("GameLua.GameCore.Module.Weapon.WeaponSystem")
  WeaponSystem:InitScirptWeaponHandle(WeaponHandle)
end
local class = require("class")
local CEventBase = require("GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEvents.HandleEventBase")
local CHandleItemHadnleEvent = class(CEventBase, nil, HandleItemHandleEvent)
return CHandleItemHadnleEvent