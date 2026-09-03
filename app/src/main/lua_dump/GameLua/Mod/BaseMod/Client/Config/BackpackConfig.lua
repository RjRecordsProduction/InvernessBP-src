local EWeaponAttachmentSocketType = import("EWeaponAttachmentSocketType")
local EBattleItemAdditionalDataType = import("EBattleItemAdditionalDataType")
local BackpackConfig = {
  DefaultShowArmorSlot = {},
  ArmorSlotPosition = {
    [UEnums.EBackpackClothArmorType.NightVision] = 3,
    [UEnums.EBackpackClothArmorType.SkillProp] = 4,
    [UEnums.EBackpackClothArmorType.SurfBoard] = 3,
    [UEnums.EBackpackClothArmorType.SnowBoard] = 4,
    [UEnums.EBackpackClothArmorType.Lighter] = 3,
    [UEnums.EBackpackClothArmorType.SkillEquipItem] = 3,
    [UEnums.EBackpackClothArmorType.FriendlyBehavior] = 3
  },
  ArmorSlotDesc = {
    [504002] = {LocalizeID = 21252},
    [4181003] = {LocalizeID = 508168},
    [4181002] = {
      LocalizeID = 508167,
      Params = {
        3,
        1,
        15
      }
    }
  },
  tExtraWidgetDragDropPriority = {VehicleBackpack = 1, TacticalBag = 2},
  SpecialItemID = {
    [604095] = "Fireworks",
    [604096] = "Fireworks",
    [604097] = "Fireworks",
    [604098] = "Fireworks",
    [3000326] = "ReviveCard",
    [602097] = "ReviveCard",
    [604129] = "Fireworks",
    [108018] = "DaggerOfTimeAdv"
  },
  SpecialItemType = {},
  ItemsNotToShowTips = {
    [602999] = true,
    [3001061] = true,
    [3001062] = true,
    [3001063] = true,
    [602041] = true,
    [504003] = true,
    [3000324] = true,
    [602093] = true,
    [501017] = true,
    [1403411] = true,
    [602096] = true,
    [507002] = true,
    [602204] = true,
    [602208] = true,
    [602213] = true,
    [604207] = true
  },
  ItemUIConfig = {
    Default = {
      UIPath = "/Game/BluePrints/ControlInput/MainBackPackUI/Item/BackPackItem_BP.BackPackItem_BP_C",
      ModulePath = "Client.Backpack.BackPackItemUI"
    },
    Fireworks = "BackpackItemFireworks",
    ReviveCard = "BackpackItemReviveCard",
    DaggerOfTimeAdv = "BackpackItemDaggerOfTimeAdv"
  },
  tBackPackDragOrigin = {
    nFromList = 0,
    nFromWeapon1 = 1,
    nFromWeapon2 = 2,
    nFromArmor = 3,
    nFromCloth = 4,
    nFromMelee = 5,
    nFromPistol = 6,
    nFromOccupation = 7,
    nFromVehicle = 8,
    nFromBackpackWeaponDetail = 9,
    nFromPickupWeaponDetail = 10,
    nFromArmorAttachment = 11
  },
  Socket2Index = {
    [EWeaponAttachmentSocketType.GunPoint] = 1,
    [EWeaponAttachmentSocketType.Grip] = 2,
    [EWeaponAttachmentSocketType.Magazine] = 3,
    [EWeaponAttachmentSocketType.Gunstock] = 4,
    [EWeaponAttachmentSocketType.OpticalSight] = 5,
    [EWeaponAttachmentSocketType.MasterGun] = -1,
    [EWeaponAttachmentSocketType.Ammo] = -1,
    [EWeaponAttachmentSocketType.Pendant] = -1,
    [EWeaponAttachmentSocketType.AngledOpticalSight] = 6,
    [EWeaponAttachmentSocketType.ACCore] = 8,
    [EWeaponAttachmentSocketType.Bezel] = 1,
    [EWeaponAttachmentSocketType.GunLock] = 8,
    [EWeaponAttachmentSocketType.TacticalAttach] = 8
  },
  SlotNameList = {
    [EWeaponAttachmentSocketType.GunPoint] = 100010,
    [EWeaponAttachmentSocketType.Grip] = 100011,
    [EWeaponAttachmentSocketType.Magazine] = 100012,
    [EWeaponAttachmentSocketType.Gunstock] = 100013,
    [EWeaponAttachmentSocketType.OpticalSight] = 100014,
    [EWeaponAttachmentSocketType.AngledOpticalSight] = 100100,
    [EWeaponAttachmentSocketType.ACCore] = 29808,
    [EWeaponAttachmentSocketType.Bezel] = 48412,
    [EWeaponAttachmentSocketType.GunLock] = 48412,
    [EWeaponAttachmentSocketType.TacticalAttach] = 48412
  },
  SlotChatText = {
    [EWeaponAttachmentSocketType.GunPoint] = 17,
    [EWeaponAttachmentSocketType.Grip] = 18,
    [EWeaponAttachmentSocketType.Magazine] = 19,
    [EWeaponAttachmentSocketType.Gunstock] = 20,
    [EWeaponAttachmentSocketType.OpticalSight] = 21,
    [EWeaponAttachmentSocketType.AngledOpticalSight] = 22,
    [EWeaponAttachmentSocketType.Bezel] = 39,
    [EWeaponAttachmentSocketType.GunLock] = 40,
    [EWeaponAttachmentSocketType.TacticalAttach] = 41
  },
  tArmorEquipItemIndex2ArmorType = {
    [1] = UEnums.EBackpackClothArmorType.Helmet,
    [2] = UEnums.EBackpackClothArmorType.ArmoredVest,
    [3] = UEnums.EBackpackClothArmorType.Package
  },
  ArmorSlotDesc = {
    [504002] = {LocalizeID = 21252},
    [4181003] = {LocalizeID = 508168},
    [4181002] = {
      LocalizeID = 508167,
      Params = {
        3,
        1,
        15
      }
    }
  },
  tBackPackDragOrigin = {
    nFromList = 0,
    nFromWeapon1 = 1,
    nFromWeapon2 = 2,
    nFromArmor = 3,
    nFromCloth = 4,
    nFromMelee = 5,
    nFromPistol = 6,
    nFromOccupation = 7,
    nFromVehicle = 8,
    nFromBackpackWeaponDetail = 9,
    nFromPickupWeaponDetail = 10,
    nFromArmorAttachment = 11
  },
  BackPackBaseZOrder = 3,
  CanNotDropItemID = {
    3000301,
    371111,
    602999,
    1000,
    1001,
    3000314,
    602030,
    602040,
    3001061,
    3001062,
    3001063,
    602041,
    504003,
    602107,
    602108,
    602109,
    602110,
    602046,
    602047,
    602048,
    602049,
    602056,
    602042
  },
  tHideWeaponFeatureMods = {
    CreativeBase = true,
    SlayTheBot = true,
    Sink2 = true,
    WarGame = true,
    TDM = true,
    BRTDM = true,
    TPlan = true
  },
  tTacticalAttachTipsInfo = {
    [EWeaponAttachmentSocketType.Bezel] = {
      nSlotItemID = 207001,
      nDescTextID = 47432,
      nVolumeTextID = 48412
    },
    [EWeaponAttachmentSocketType.GunLock] = {
      nSlotItemID = 208001,
      nDescTextID = 49195,
      nVolumeTextID = 48412
    },
    [EWeaponAttachmentSocketType.TacticalAttach] = {
      nSlotItemID = 209001,
      nDescTextID = 63073,
      nVolumeTextID = 48412
    }
  },
  ItemNewbieGuideMap = {
    [604100] = 150063,
    [604123] = 604123
  },
  ReviveCardRedAreaID = {0},
  DropSlideInfo = {
    Length = 220,
    Theta = 90,
    StayTime = 3.5,
    FirstIgnoreLen = 20
  },
  AllExcludedItemTypeConfig = {
    [6] = 606
  },
  AllExcludedItemIDConfig = {
    604102,
    604103,
    6041003
  },
  SelfCanPickUpItemTipID = {
    [1702833] = 33020003
  },
  LuaCheckBackpackNeedToShowItemType = {
    [4] = true
  },
  LuaCheckBackpackNeedToShowItemSubType = {
    [4181] = true
  },
  AllSpecialItemID = {}
}
BackpackConfig.UseItemButtonZOrder = BackpackConfig.BackPackBaseZOrder + 1
BackpackConfig.DropItemZOrder = BackpackConfig.UseItemButtonZOrder + 1
return BackpackConfig