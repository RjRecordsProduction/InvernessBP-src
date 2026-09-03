local ModConfig = {
  Export = {
    Name = "PlanBT",
    AutoExportAllConfig = true,
    LuaFeature = {}
  }
}
ModConfig.Export.Inject = {
  Mod = {
    "PlanBTShooting"
  }
}
return ModConfig