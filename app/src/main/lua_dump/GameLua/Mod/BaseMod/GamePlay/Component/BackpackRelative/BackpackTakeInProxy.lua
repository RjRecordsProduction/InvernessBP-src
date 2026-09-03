local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local UBackpackUtils = import("BackpackUtils")
local BackpackTakeInProxy = {}
function BackpackTakeInProxy:ctor(selfType)
  BackpackTakeInProxy.__super.ctor(self, selfType)
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
local CBackpackTakeInProxy = class(CDelegateContainer, nil, BackpackTakeInProxy)
return CBackpackTakeInProxy