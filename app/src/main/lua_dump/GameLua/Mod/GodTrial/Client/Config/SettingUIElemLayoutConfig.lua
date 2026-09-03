local CustomType = require("client.logic.setting.CustomType")
local ModCustomType = require("GameLua.Mod.GodTrial.Client.Config.CustomType")
local CustomSaveFlag = require("client.logic.setting.CustomSaveFlag")
local CustomDisplayFlag = require("client.logic.setting.CustomDisplayFlag")
local SettingUIElemLayoutConfig = {
  IndexerRefPath = "/Game/Mod/GodTrial/BluePrints/UI/DynamicCustom/DynamicCustomIndexer.DynamicCustomIndexer",
  SlotRegistry = {
    [ModCustomType._1001_ArenaTrials] = {
      SaveFlag = CustomSaveFlag.Classic,
      ShowFlag = CustomDisplayFlag.Classic
    }
  }
}
return SettingUIElemLayoutConfig