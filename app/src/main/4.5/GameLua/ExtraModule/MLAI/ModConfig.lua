local ModConfig = {
  Import = {},
  Export = {Name = "MLAI", AutoExportAllConfig = true}
}
ModConfig.Export.Inject = {
  IsUGCMode = true,
  Mod = {
    "BaseMod",
    "BRCard",
    "TDM",
    "PlanBT"
  },
  Map = {
    "Baltic",
    "Livik",
    "Desert",
    "Borderland",
    "Neon"
  }
}
return ModConfig