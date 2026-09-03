local TableUtil = require("common.table_util")
local BaseCanvasVisibleConfig = require("GameLua.Mod.BaseMod.Client.Config.CanvasVisibleConfig")
local CanvasVisibleConfig = TableUtil.CopyTable(BaseCanvasVisibleConfig)
CanvasVisibleConfig.BallisticTargetUI = {
  PhotoGrapherState = {Hide = true}
}
return CanvasVisibleConfig