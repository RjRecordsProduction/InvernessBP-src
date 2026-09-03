local NGConditionWithIgnoreMod = {}
function NGConditionWithIgnoreMod:ctor(selfType, Params)
  self.ignoreMod = Params.ignoreMod
end
function NGConditionWithIgnoreMod:CheckConditionOK(...)
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local ModType, _ = GameMainConfig.GetModType()
  local check1 = ModType ~= self.ignoreMod
  print(bWriteLog and "NGConditionWithIgnoreMod:CheckConditionOK", check1)
  return check1
end
local class = require("class")
local CObject = require("GameLua.GameCore.Module.NewbieGuide.Conditions.NewbieGuideConditionBase")
local CNGConditionWithIgnoreMod = class(CObject, nil, NGConditionWithIgnoreMod)
return CNGConditionWithIgnoreMod