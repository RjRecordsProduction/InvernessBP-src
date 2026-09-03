local SubscribeEnumConfig = {
  ENUM_RewardShowType = {
    UC = 1,
    RP = 2,
    Coupon = 3
  },
  ENUM_SubStatus = {
    NONE = 0,
    NormalStatus = 1,
    SuperStatus = 2,
    BothStatus = 3
  },
  ENUM_SubId = {
    Normal = 101,
    Super = 201,
    Super_ThreeMonth = 301,
    Super_TwelveMonth = 302,
    Super_Special_Type = 303
  },
  ENUM_SubInfoID = {
    EVERYDAY_GET_UC = 1001,
    SHOP_BUY = 1002,
    EXTRA_RP_SCORE = 1004,
    DISCOUNT_ITEM = 1005,
    DISCOUNT_BOX = 1006,
    EVERYDAY_GET_AG = 1010,
    DISCOUNT_COUPONS = 2007,
    SHARE_BAG = 2008,
    Get_Award = 9999
  },
  ENUM_KoreaSubInfoID = {
    EVERYDAY_GET_UC = 1001,
    SHOP_BUY = 1002,
    EXTRA_RP_SCORE = 1004,
    DISCOUNT_BOX = 1006,
    DISCOUNT_ITEM = 1007,
    Pig = 1008,
    EXTRA_BOX_DEBRIS = 1009,
    DISCOUNT_COUPONS = 2007,
    SHARE_BAG = 2008,
    Get_General_Award = 9998,
    Get_Award = 9999
  },
  ENUM_PrimeAgreementShowType = {
    Common = 1,
    WeekPrime = 2,
    BlackFridayPrime = 3
  },
  Enum_ReceiveShowType = {Every = 1, Week = 2},
  Enum_PrivilegeDescShowType = {
    None = 0,
    RightBottom = 1,
    Middle = 2,
    BottomMiddle = 3
  }
}
return SubscribeEnumConfig