local CircleChooseCfg = {
  BGPath = {
    MedsThrow = "/Game/Arts/UI/Atlas/BattleUI/General_RGBA/Frames/ZD_image_shoulei_bg_png.ZD_image_shoulei_bg_png",
    Normal = "/Game/Arts/UI/Atlas/BattleUI/General_RGBA/Frames/ZD_image_shoulei_bg_png.ZD_image_shoulei_bg_png",
    MedRing = "/Game/Arts/UI/Atlas/BattleUI/RingThrowUI/Frames/ZD_img_NewZhiHui_BG_png.ZD_img_NewZhiHui_BG_png"
  },
  RingListItem = {
    601001,
    601002,
    601003,
    601004,
    601005,
    601006,
    602001,
    602002,
    602003,
    602004
  },
  RelatedSubtype = {
    [602] = true,
    [601] = true,
    [108] = true
  },
  RelatedID = {
    [604123] = true
  },
  ThrowableMedicineIDMap = {
    [601001] = true,
    [601002] = true,
    [601003] = true,
    [601004] = true,
    [601005] = true,
    [601006] = true
  },
  SpecialAnnexID = {},
  SimMeleeID = {
    [604123] = true,
    [602420] = true
  },
  RelatedVehicleType = {},
  GrenadeValidSlotNum = 5,
  MedValidSlotNum = 5,
  RingListCfg = {
    Grenades = {
      [4] = {
        ItemID = -1,
        EmptyImage = "/Game/Arts/UI/Atlas/BattleUI/RingThrowUI/Frames/ZD_img_ZhiHui_Icon011_png.ZD_img_ZhiHui_Icon011_png"
      },
      [3] = {ItemID = 602003},
      [2] = {ItemID = 602004},
      [1] = {ItemID = 602002},
      [0] = {ItemID = 602001}
    },
    Medicines = {
      [4] = {ItemID = 601004},
      [3] = {ItemID = 601001},
      [2] = {ItemID = 601005},
      [1] = {ItemID = 601003},
      [0] = {ItemID = 601006}
    }
  },
  EConsumableSortMode = {
    NormalMode = 1,
    FullHealth = 2,
    LittleBitWound = 3,
    PlentyWound = 4,
    SeriousWound = 5,
    AlmostDie = 6
  },
  SortingModePriorityIDList = {
    [1] = {
      [601004] = 1,
      [601005] = 2,
      [601006] = 3,
      [601096] = 4,
      [601001] = 5,
      [601003] = 6,
      [601002] = 7,
      [601061] = 8,
      [601009] = 1,
      [601010] = 2
    },
    [2] = {
      [601004] = 5,
      [601005] = 6,
      [601006] = 7,
      [601096] = 4,
      [601001] = 1,
      [601003] = 2,
      [601002] = 3,
      [601061] = 6,
      [601009] = 4,
      [601010] = 5
    },
    [3] = {
      [601004] = 5,
      [601005] = 6,
      [601006] = 7,
      [601096] = 4,
      [601001] = 1,
      [601003] = 2,
      [601002] = 3,
      [601061] = 6,
      [601009] = 4,
      [601010] = 5
    },
    [4] = {
      [601004] = 1,
      [601005] = 2,
      [601006] = 3,
      [601096] = 4,
      [601001] = 5,
      [601003] = 6,
      [601002] = 7,
      [601061] = 3,
      [601009] = 1,
      [601010] = 2
    },
    [5] = {
      [601004] = 4,
      [601005] = 2,
      [601006] = 3,
      [601096] = 1,
      [601001] = 5,
      [601003] = 6,
      [601002] = 7,
      [601061] = 2,
      [601009] = 3,
      [601010] = 1
    },
    [6] = {
      [601004] = 4,
      [601005] = 3,
      [601006] = 2,
      [601096] = 1,
      [601001] = 5,
      [601003] = 6,
      [601002] = 7,
      [601061] = 1,
      [601009] = 3,
      [601010] = 2
    }
  },
  CommonGrenadePriorityDic = {
    [602001] = 21,
    [602002] = 22,
    [602003] = 23,
    [602004] = 24,
    [602045] = 25,
    [602036] = 26,
    [602069] = 27
  },
  MeleeWeaponPriority = 40
}
return CircleChooseCfg