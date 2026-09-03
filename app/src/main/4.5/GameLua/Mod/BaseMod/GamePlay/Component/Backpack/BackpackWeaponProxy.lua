local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local BackpackWeaponProxy = {}
function BackpackWeaponProxy:ctor(selfType)
  BackpackWeaponProxy.__super.ctor(self, selfType)
  self.CircleChooseCfg = GamePlayTools.GetCurrentConfig("CircleChooseCfg") or {}
end
function BackpackWeaponProxy:LuaInitialize()
  print(bWriteLog and "BackpackWeaponProxy:LuaInitialize()")
  if not self.CircleChooseCfg then
    self.CircleChooseCfg = GamePlayTools.GetCurrentConfig("CircleChooseCfg")
  end
  if not self.CircleChooseCfg then
    return
  end
  if self.CircleChooseCfg.IgnoreThrowableID then
    for _, ID in pairs(self.CircleChooseCfg.IgnoreThrowableID) do
      self.IgnoreTypeSpecificIDList:Add(ID)
    end
  end
end
function BackpackWeaponProxy:LuaDeinitialize()
  print(bWriteLog and "BackpackWeaponProxy:LuaDeinitialize()")
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
local CBackpackWeaponProxy = class(CDelegateContainer, nil, BackpackWeaponProxy)
return CBackpackWeaponProxy