local BTTools = require("GameLua.Mod.Library.GamePlay.AI.LuaNode.BTTools")
local LuaBTDecoratorBase = {}
function LuaBTDecoratorBase:ctor()
  self.TaskNodeName = "LuaBTDecoratorBase"
end
function LuaBTDecoratorBase:PerformConditionCheck(AIController)
  return true
end
local class = require("class")
local CLuaNodeBase = require("GameLua.Mod.Library.GamePlay.AI.LuaNode.LuaBTNodeBase")
local CLuaBTDecoratorBase = class(CLuaNodeBase, nil, LuaBTDecoratorBase)
return CLuaBTDecoratorBase