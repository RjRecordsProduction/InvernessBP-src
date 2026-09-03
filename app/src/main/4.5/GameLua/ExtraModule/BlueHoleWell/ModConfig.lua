local ModConfig = {
  Export = {
    Name = "BlueHoleWell",
    AutoExportAllConfig = true
  }
}
ModConfig.Export.Inject = {
  BlueHoleVersionOnly = true,
  ModeID = {
    {1001, 1003},
    {1064, 1066},
    {2001, 2003},
    {2064, 2066},
    {64959, 64970},
    600074,
    600080,
    880000
  }
}
return ModConfig