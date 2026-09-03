local BTTools = require("GameLua.Mod.Library.GamePlay.AI.LuaNode.BTTools")
local LuaBTTaskBase = {}
function LuaBTTaskBase:ctor()
  self.TaskNodeName = "LuaBTTaskBase"
end
function LuaBTTaskBase:ReceiveExecute(ActorOwner)
end
local class = require("class")
local CLuaNodeBase = require("GameLua.Mod.Library.GamePlay.AI.LuaNode.LuaBTNodeBase")
local CLuaBTTaskBase = class(CLuaNodeBase, nil, LuaBTTaskBase)
return CLuaBTTaskBase