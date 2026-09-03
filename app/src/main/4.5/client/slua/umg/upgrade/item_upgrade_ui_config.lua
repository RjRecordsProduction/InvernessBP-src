local item_upgrade_ui_config = {
  UITabType = {ItemUpgradeUI = 1, KillFeature = 2},
  ItemUpgradeTabType = {
    All = 0,
    Rifle = ENUM_ITEM_SUBTYPE.Gun_Skin_101,
    SMG = ENUM_ITEM_SUBTYPE.Gun_Skin_102,
    Sniper = ENUM_ITEM_SUBTYPE.Gun_Skin_103,
    ShotGun = ENUM_ITEM_SUBTYPE.Gun_Skin_104,
    MachineGun = ENUM_ITEM_SUBTYPE.Gun_Skin_105,
    Melee = ENUM_ITEM_SUBTYPE.Melee_Weapon,
    Pistol = ENUM_ITEM_SUBTYPE.Gun_Skin_106
  },
  KillFeatureTabType = {
    KillCounter = 1,
    LastKillEffectUI = 2,
    EliminationKing = 3
  }
}
item_upgrade_ui_config.TabListConfig = {
  {
    TabType = item_upgrade_ui_config.UITabType.ItemUpgradeUI,
    SelectIconPath = "/Game/UMG/Texture_200/Atlas/WorkShop/Frames/Common_Tab_Pistol_xuangzhong_png.Common_Tab_Pistol_xuangzhong_png",
    UnSelectIconPath = "/Game/UMG/Texture_200/Atlas/WorkShop/Frames/Common_Tab_Pistol_png.Common_Tab_Pistol_png"
  },
  {
    TabType = item_upgrade_ui_config.UITabType.KillFeature,
    SelectIconPath = "/Game/UMG/Texture_200/Atlas/WorkShop/Frames/Common_Tab_Characteristic_xuangzhong_png.Common_Tab_Characteristic_xuangzhong_png",
    UnSelectIconPath = "/Game/UMG/Texture_200/Atlas/WorkShop/Frames/Common_Tab_Characteristic_png.Common_Tab_Characteristic_png"
  }
}
item_upgrade_ui_config.ItemUpgradeTabListConfig = {
  {
    TabType = item_upgrade_ui_config.ItemUpgradeTabType.All,
    SelectIconPath = "/Game/UMG/Texture_200/Atlas/Lobby_Store/Frames/Common_Tab_Common2_png.Common_Tab_Common2_png",
    UnSelectIconPath = "/Game/UMG/Texture_200/Atlas/Lobby_Store/Frames/Common_Tab_Common2_Select_png.Common_Tab_Common2_Select_png"
  },
  {
    TabType = item_upgrade_ui_config.ItemUpgradeTabType.Rifle,
    SelectIconPath = "/Game/UMG/Texture_200/Atlas/Lobby_Store/Frames/Common_Tab_Qiangxie_0008_png.Common_Tab_Qiangxie_0008_png",
    UnSelectIconPath = "/Game/UMG/Texture_200/Atlas/Lobby_Store/Frames/Common_Tab_Qiangxie_0008_xuangzhong_png.Common_Tab_Qiangxie_0008_xuangzhong_png"
  },
  {
    TabType = item_upgrade_ui_config.ItemUpgradeTabType.SMG,
    SelectIconPath = "/Game/UMG/Texture_200/Atlas/Lobby_Store/Frames/Common_Tab_Qiangxie_0002_png.Common_Tab_Qiangxie_0002_png",
    UnSelectIconPath = "/Game/UMG/Texture_200/Atlas/Lobby_Store/Frames/Common_Tab_Qiangxie_0002_xuangzhong_png.Common_Tab_Qiangxie_0002_xuangzhong_png"
  },
  {
    TabType = item_upgrade_ui_config.ItemUpgradeTabType.Sniper,
    SelectIconPath = "/Game/UMG/Texture_200/Atlas/Lobby_Store/Frames/Common_Tab_Qiangxie_0004_png.Common_Tab_Qiangxie_0004_png",
    UnSelectIconPath = "/Game/UMG/Texture_200/Atlas/Lobby_Store/Frames/Common_Tab_Qiangxie_0004_xuangzhong_png.Common_Tab_Qiangxie_0004_xuangzhong_png"
  },
  {
    TabType = item_upgrade_ui_config.ItemUpgradeTabType.ShotGun,
    SelectIconPath = "/Game/UMG/Texture_200/Atlas/Lobby_Store/Frames/Common_Tab_Qiangxie_0001_png.Common_Tab_Qiangxie_0001_png",
    UnSelectIconPath = "/Game/UMG/Texture_200/Atlas/Lobby_Store/Frames/Common_Tab_Qiangxie_0001_xuangzhong_png.Common_Tab_Qiangxie_0001_xuangzhong_png"
  },
  {
    TabType = item_upgrade_ui_config.ItemUpgradeTabType.MachineGun,
    SelectIconPath = "/Game/UMG/Texture_200/Atlas/Lobby_Store/Frames/Common_Tab_Qiangxie_0007_png.Common_Tab_Qiangxie_0007_png",
    UnSelectIconPath = "/Game/UMG/Texture_200/Atlas/Lobby_Store/Frames/Common_Tab_Qiangxie_0007_xuangzhong_png.Common_Tab_Qiangxie_0007_xuangzhong_png"
  },
  {
    TabType = item_upgrade_ui_config.ItemUpgradeTabType.Melee,
    SelectIconPath = "/Game/UMG/Texture_200/Atlas/Lobby_Store/Frames/Common_Tab_Qiangxie_0005_png.Common_Tab_Qiangxie_0005_png",
    UnSelectIconPath = "/Game/UMG/Texture_200/Atlas/Lobby_Store/Frames/Common_Tab_Qiangxie_0005_xuangzhong_png.Common_Tab_Qiangxie_0005_xuangzhong_png"
  },
  {
    TabType = item_upgrade_ui_config.ItemUpgradeTabType.Pistol,
    SelectIconPath = "/Game/UMG/Texture_200/Atlas/Lobby_Store/Frames/Common_Tab_Pistol_png.Common_Tab_Pistol_png",
    UnSelectIconPath = "/Game/UMG/Texture_200/Atlas/Lobby_Store/Frames/Common_Tab_Pistol_xuangzhong2_png.Common_Tab_Pistol_xuangzhong2_png"
  }
}
item_upgrade_ui_config.KillFeatureTabListConfig = {
  {
    TabType = item_upgrade_ui_config.KillFeatureTabType.KillCounter,
    UIConfigKeyName = "ItemUpgrade_KillCounter_UIBP",
    UnSelectIconPath = "/Game/UMG/Texture_200/Atlas/Lobby_Store/Frames/Common_Tab_Counter_xuangzhong_png.Common_Tab_Counter_xuangzhong_png",
    SelectIconPath = "/Game/UMG/Texture_200/Atlas/Lobby_Store/Frames/Common_Tab_Counter_png.Common_Tab_Counter_png"
  },
  {
    TabType = item_upgrade_ui_config.KillFeatureTabType.LastKillEffectUI,
    UIConfigKeyName = "ItemUpgrade_LastKillEffects_UIBP",
    UnSelectIconPath = "/Game/UMG/Texture_200/Atlas/Lobby_Store/Frames/Common_Tab_Farewell_xuangzhong_png.Common_Tab_Farewell_xuangzhong_png",
    SelectIconPath = "/Game/UMG/Texture_200/Atlas/Lobby_Store/Frames/Common_Tab_Farewell_png.Common_Tab_Farewell_png"
  },
  {
    TabType = item_upgrade_ui_config.KillFeatureTabType.EliminationKing,
    UIConfigKeyName = "ItemUpgrade_EliminationKing_UIBP",
    UnSelectIconPath = "/Game/UMG/Texture_200/Atlas/Lobby_Store/Frames/Common_Tab_KingEliminationTips_xuangzhong_png.Common_Tab_KingEliminationTips_xuangzhong_png",
    SelectIconPath = "/Game/UMG/Texture_200/Atlas/Lobby_Store/Frames/Common_Tab_KingEliminationTips_png.Common_Tab_KingEliminationTips_png"
  }
}
return item_upgrade_ui_config