local ModConfig = {
  Export = {
    Name = "DinosaurCore",
    AutoExportAllConfig = true
  }
}
ModConfig.Export.Inject = {
  IsUGCMode = true,
  ModeID = {
    {880001, 880008},
    880000,
    880019,
    880088
  },
  Mod = {"Dinosaur"}
}
return ModConfig