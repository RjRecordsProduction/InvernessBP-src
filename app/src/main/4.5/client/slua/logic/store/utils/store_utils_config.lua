local StoreUtils = {
  NewFlagAvailableTime = 604800,
  DiscountType_NONE = 0,
  DiscountType_DISCOUNT_ACTIVITY = 1,
  DiscountType_VIP = 2,
  CheckMoneyBtnType = {
    NIL = nil,
    Cancel = 0,
    OK = 1,
    Pay = 2
  },
  TitleType = {DropDown = 1, Tab = 2},
  ItemSortType = {
    Default = 1,
    Quality = 2,
    Price_Up = 3,
    Price_Down = 4,
    Priority_AG = 5,
    Priority_UC = 6
  },
  priceTypeList = {
    StoreConst.label_price_type_bp,
    StoreConst.label_price_type_chip,
    StoreConst.label_price_type_uc,
    StoreConst.label_price_type_fp,
    StoreConst.label_price_type_battle,
    StoreConst.label_price_type_exchage,
    StoreConst.label_price_type_gold_chip
  }
}
StoreUtils.NotNeedToCheckSubTab = {
  [StoreConst.subtype_new_weapon_com] = true,
  [StoreConst.subtype_new_recommend_lim] = true,
  [StoreConst.subtype_new_recommend_lim_In] = true
}
StoreUtils.TabToPageConfigV280 = {
  [StoreConst.Page_New_ID_Recommend] = {
    subTab = {
      [StoreConst.subtype_new_recommend_rec] = "StoreRecommendPage",
      [StoreConst.subtype_new_recommend_dol] = "StoreDirectPurchasePage",
      [StoreConst.subtype_new_recommend_ucb] = "StoreUCGiftPage",
      [StoreConst.subtype_new_recommend_col] = "StoreCollectPage",
      [StoreConst.subtype_new_recommend_lim] = "StoreLimitedSubscribePage",
      [StoreConst.subtype_new_recommend_lim_In] = "StoreLimitedSubscribePage"
    },
    default = "StoreGeneralPage"
  },
  [StoreConst.Page_New_ID_Weapon] = {
    default = "StoreEquipmentPage"
  },
  [StoreConst.Page_New_ID_Car] = {
    default = "StoreEquipmentPage"
  },
  [StoreConst.Page_ID_Collect] = {
    default = "StoreCollectPage"
  },
  [StoreConst.Page_ID_Exchange] = {
    default = "StoreGeneralPage"
  },
  [StoreConst.Page_ID_Item] = {
    subTab = {
      [StoreConst.label_subtype_recommend] = "StoreRecommendPage"
    },
    default = "StoreGeneralPage"
  },
  [StoreConst.Page_ID_Season] = {
    default = "StoreGeneralPage"
  },
  [StoreConst.Page_New_ID_Cloth] = {
    default = "StoreGeneralPage"
  },
  [StoreConst.Page_New_ID_Other] = {
    subTab = {
      [StoreConst.subtype_new_other_pre] = "StorePetPage"
    },
    default = "StoreGeneralPage"
  }
}
StoreUtils.TitleDropDownTypeConfig = {
  Common = {
    {
      text = 4670,
      sortType = StoreUtils.ItemSortType.Default
    },
    {
      text = 37256,
      sortType = StoreUtils.ItemSortType.Quality
    },
    {
      text = 37257,
      sortType = StoreUtils.ItemSortType.Price_Up
    },
    {
      text = 37258,
      sortType = StoreUtils.ItemSortType.Price_Down
    }
  },
  Cloth = {
    {
      text = 4670,
      sortType = StoreUtils.ItemSortType.Default
    },
    {
      text = 37256,
      sortType = StoreUtils.ItemSortType.Quality
    },
    {
      text = 37257,
      sortType = StoreUtils.ItemSortType.Price_Up
    },
    {
      text = 37258,
      sortType = StoreUtils.ItemSortType.Price_Down
    },
    {
      text = 37264,
      sortType = StoreUtils.ItemSortType.Priority_AG
    }
  },
  Car = {
    {
      text = 4670,
      sortType = StoreUtils.ItemSortType.Default
    },
    {
      text = 37256,
      sortType = StoreUtils.ItemSortType.Quality
    },
    {
      text = 37263,
      sortType = StoreUtils.ItemSortType.Priority_UC
    },
    {
      text = 37264,
      sortType = StoreUtils.ItemSortType.Priority_AG
    }
  },
  Weapon = {
    {
      text = 4670,
      sortType = StoreUtils.ItemSortType.Default
    },
    {
      text = 37256,
      sortType = StoreUtils.ItemSortType.Quality
    },
    {
      text = 37263,
      sortType = StoreUtils.ItemSortType.Priority_UC
    },
    {
      text = 37264,
      sortType = StoreUtils.ItemSortType.Priority_AG
    }
  }
}
StoreUtils.TitleTabConfig = {
  [StoreConst.subtype_new_exchange_cry] = {
    titleType = StoreUtils.TitleType.DropDown,
    textList = StoreUtils.TitleDropDownTypeConfig.Common
  },
  [StoreConst.subtype_new_exchange_fra] = {
    titleType = StoreUtils.TitleType.DropDown,
    textList = StoreUtils.TitleDropDownTypeConfig.Common
  },
  [StoreConst.subtype_new_exchange_bps] = {
    titleType = StoreUtils.TitleType.DropDown,
    textList = StoreUtils.TitleDropDownTypeConfig.Common
  },
  [StoreConst.subtype_new_exchange_bpf] = {
    titleType = StoreUtils.TitleType.DropDown,
    textList = StoreUtils.TitleDropDownTypeConfig.Common
  },
  [StoreConst.subtype_new_exchange_as] = {
    titleType = StoreUtils.TitleType.DropDown,
    textList = StoreUtils.TitleDropDownTypeConfig.Common
  },
  [StoreConst.subtype_new_cloth_sui] = {
    titleType = StoreUtils.TitleType.DropDown,
    textList = StoreUtils.TitleDropDownTypeConfig.Cloth
  },
  [StoreConst.subtype_new_cloth_com] = {
    titleType = StoreUtils.TitleType.DropDown,
    textList = StoreUtils.TitleDropDownTypeConfig.Cloth
  },
  [StoreConst.subtype_new_cloth_hea] = {
    titleType = StoreUtils.TitleType.DropDown,
    textList = StoreUtils.TitleDropDownTypeConfig.Cloth
  },
  [StoreConst.subtype_new_cloth_gla] = {
    titleType = StoreUtils.TitleType.DropDown,
    textList = StoreUtils.TitleDropDownTypeConfig.Cloth
  },
  [StoreConst.subtype_new_cloth_fac] = {
    titleType = StoreUtils.TitleType.DropDown,
    textList = StoreUtils.TitleDropDownTypeConfig.Cloth
  },
  [StoreConst.subtype_new_cloth_jac] = {
    titleType = StoreUtils.TitleType.DropDown,
    textList = StoreUtils.TitleDropDownTypeConfig.Cloth
  },
  [StoreConst.subtype_new_cloth_und] = {
    titleType = StoreUtils.TitleType.DropDown,
    textList = StoreUtils.TitleDropDownTypeConfig.Cloth
  },
  [StoreConst.subtype_new_cloth_sho] = {
    titleType = StoreUtils.TitleType.DropDown,
    textList = StoreUtils.TitleDropDownTypeConfig.Cloth
  },
  [StoreConst.subtype_new_cloth_hel] = {
    titleType = StoreUtils.TitleType.DropDown,
    textList = StoreUtils.TitleDropDownTypeConfig.Cloth
  },
  [StoreConst.subtype_new_cloth_bac] = {
    titleType = StoreUtils.TitleType.DropDown,
    textList = StoreUtils.TitleDropDownTypeConfig.Cloth
  },
  [StoreConst.subtype_new_cloth_pen] = {
    titleType = StoreUtils.TitleType.DropDown,
    textList = StoreUtils.TitleDropDownTypeConfig.Cloth
  },
  [StoreConst.subtype_new_weapon_com] = {
    titleType = StoreUtils.TitleType.DropDown,
    textList = StoreUtils.TitleDropDownTypeConfig.Weapon
  },
  [StoreConst.subtype_new_car_com] = {
    titleType = StoreUtils.TitleType.DropDown,
    textList = StoreUtils.TitleDropDownTypeConfig.Car
  },
  [StoreConst.subtype_new_treasure_com] = {
    titleType = StoreUtils.TitleType.DropDown,
    textList = StoreUtils.TitleDropDownTypeConfig.Common
  },
  [StoreConst.subtype_new_treasure_mat] = {
    titleType = StoreUtils.TitleType.DropDown,
    textList = StoreUtils.TitleDropDownTypeConfig.Common
  },
  [StoreConst.subtype_new_treasure_gif] = {
    titleType = StoreUtils.TitleType.DropDown,
    textList = StoreUtils.TitleDropDownTypeConfig.Common
  },
  [StoreConst.subtype_new_treasure_use] = {
    titleType = StoreUtils.TitleType.DropDown,
    textList = StoreUtils.TitleDropDownTypeConfig.Common
  },
  [StoreConst.subtype_new_treasure_fir] = {
    titleType = StoreUtils.TitleType.DropDown,
    textList = StoreUtils.TitleDropDownTypeConfig.Common
  },
  [StoreConst.subtype_new_treasure_fra] = {
    titleType = StoreUtils.TitleType.DropDown,
    textList = StoreUtils.TitleDropDownTypeConfig.Common
  },
  [StoreConst.subtype_new_other_act] = {
    titleType = StoreUtils.TitleType.DropDown,
    textList = StoreUtils.TitleDropDownTypeConfig.Common
  },
  [StoreConst.subtype_new_other_pai] = {
    titleType = StoreUtils.TitleType.DropDown,
    textList = StoreUtils.TitleDropDownTypeConfig.Common
  },
  [StoreConst.subtype_new_other_par] = {
    titleType = StoreUtils.TitleType.DropDown,
    textList = StoreUtils.TitleDropDownTypeConfig.Common
  },
  [StoreConst.subtype_new_other_gli] = {
    titleType = StoreUtils.TitleType.DropDown,
    textList = StoreUtils.TitleDropDownTypeConfig.Common
  },
  [StoreConst.subtype_new_other_theme] = {
    titleType = StoreUtils.TitleType.DropDown,
    textList = StoreUtils.TitleDropDownTypeConfig.Common
  }
}
local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
StoreUtils.OutfitTypeMapping = {
  [wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_suit] = StoreConst.subtype_new_cloth_sui,
  [wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_head] = StoreConst.subtype_new_cloth_hea,
  [wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_glasses] = StoreConst.subtype_new_cloth_gla,
  [wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_face] = StoreConst.subtype_new_cloth_fac,
  [wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_clothes] = StoreConst.subtype_new_cloth_jac,
  [wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_trousers] = StoreConst.subtype_new_cloth_und,
  [wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_shoes] = StoreConst.subtype_new_cloth_sho,
  [wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_helmet] = StoreConst.subtype_new_cloth_hel,
  [wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_bag] = StoreConst.subtype_new_cloth_bac,
  [wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_bag_pendant] = StoreConst.subtype_new_cloth_pen
}
StoreUtils.WeaponTypeAll = 0
StoreUtils.TabIDToWeaponTypeMap = {
  [StoreConst.subtype_new_weapon_cus] = 1,
  [StoreConst.subtype_new_weapon_sin] = 2,
  [StoreConst.subtype_new_weapon_bur] = 3,
  [StoreConst.subtype_new_weapon_cha] = 4,
  [StoreConst.subtype_new_weapon_sho] = 5,
  [StoreConst.subtype_new_weapon_lig] = 6,
  [StoreConst.subtype_new_weapon_pis] = 7,
  [StoreConst.subtype_new_weapon_mel] = 8,
  [StoreConst.subtype_new_weapon_oth] = 9
}
return StoreUtils