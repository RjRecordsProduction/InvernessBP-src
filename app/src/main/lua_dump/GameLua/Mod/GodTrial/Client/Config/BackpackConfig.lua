local BackpackConfig = {}
local TableUtil = require("common.table_util")
TableUtil.OverrideTable(BackpackConfig, require("GameLua.Mod.BaseMod.Client.Config.BackpackConfig"))
BackpackConfig.ItemNewbieGuideMap[44060803] = 44060803
BackpackConfig.ItemNewbieGuideMap[44060804] = 44060804
BackpackConfig.SpecialItemID[44060801] = "ThemeSkillItemUI"
BackpackConfig.SpecialItemID[44060802] = "ThemeSkillItemUI"
BackpackConfig.SpecialItemID[44060803] = "ThemeSkillItemUI"
BackpackConfig.ItemUIConfig.ThemeSkillItemUI = {
  UIPath = "/Game/BluePrints/ControlInput/MainBackPackUI/Item/BackPackItem_BP.BackPackItem_BP_C",
  ModulePath = "Client.Backpack.BackPackThemeSkillItemUI"
}
return BackpackConfig