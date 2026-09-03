local ModConfig = {
  Import = {},
  Export = {
    Name = "SkillCore",
    AutoExportAllConfig = true,
    Inject = {
      IsThemeBRMode = true,
      Mod = {
        "CreativeBase",
        "TPlan",
        "TPlanPVE"
      }
    }
  }
}
return ModConfig