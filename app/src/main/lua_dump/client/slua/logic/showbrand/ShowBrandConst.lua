local ShowBrandConst = {GeneralEmoteId = 12220336, EditEmoteId = 12220338}
ShowBrandConst.ShowType = {
  GameNum = 1,
  ChickenNum = 2,
  TopTenNum = 3,
  KillNum = 4,
  DefeatOrSurvive = 5,
  ChickenRate = 6,
  TopTenRate = 7,
  HitRate = 8,
  CritRate = 9,
  CritNum = 10,
  AvgDamage = 11,
  TotalDamage = 12,
  TreasureLevel = 13,
  HighestLevel = 14,
  CurrentLevel = 15,
  CurrentCycleMark = 16,
  PeakGameLevel = 27,
  PlayterPartner = 28,
  BanLevel = 29,
  BanTotalCount = 30,
  BanRealCount = 31.0
}
ShowBrandConst.IconName = {
  [ShowBrandConst.ShowType.TreasureLevel] = 77527,
  [ShowBrandConst.ShowType.HighestLevel] = 199608,
  [ShowBrandConst.ShowType.CurrentLevel] = nil,
  [ShowBrandConst.ShowType.CurrentCycleMark] = 42634,
  [ShowBrandConst.ShowType.PeakGameLevel] = 46063,
  [ShowBrandConst.ShowType.BanLevel] = 180003
}
ShowBrandConst.PatrollerDataType = {
  [ShowBrandConst.ShowType.BanLevel] = true,
  [ShowBrandConst.ShowType.BanTotalCount] = true,
  [ShowBrandConst.ShowType.BanRealCount] = true
}
return ShowBrandConst