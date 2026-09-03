local Special_Offer_Gifts_Const = {
  Enum_LimitType = {
    Daily = 1,
    Week = 2,
    Forever = 3,
    backUserDaily = 4,
    backUserWeek = 5,
    privilegeDaily = 6,
    privilegeWeek = 7,
    rpPlusDaily = 8,
    rpPlusWeek = 9
  },
  Enum_PriceType = {
    Uc = 2,
    Dollar = 5,
    AG = 6,
    FpToken = 102
  },
  T_PriceTypeCurrencyId = {
    [2] = 1006,
    [6] = 1109,
    [102] = 1101
  },
  Enum_ConditionType = {
    RoleLevel = 1,
    RankLevel = 2,
    LoginDays = 3,
    CollectSeasonLevel = 4
  },
  Enum_MaterialGiftIndex = {
    UpgradeGun = 1,
    HolyDress = 2,
    MythStamp = 3,
    Paint = 4,
    ModifiedCars = 5,
    Pet = 6
  },
  Enum_MaterialGiftLocalKey = {
    [1] = 63047,
    [2] = 63048,
    [3] = 63049,
    [4] = 87995,
    [5] = 87996,
    [6] = 87997
  },
  Enum_UnReachConditionType = {NotBuyPreGood = 1, NotReachLoginDays = 2},
  Enum_Condition_GiftGroup = {FirstCharge = 4},
  Enum_Default_Bg = {
    [1] = "/Game/UMG/Texture_200/Lobby_NoAtlas/SpecialOffer/SpecialOffer_Image_Bg_L_02.SpecialOffer_Image_Bg_L_02",
    [2] = "/Game/UMG/Texture_200/Lobby_NoAtlas/SpecialOffer/SpecialOffer_Image_Bg_R_02.SpecialOffer_Image_Bg_R_02"
  }
}
return Special_Offer_Gifts_Const