local WeaponDefine = require("GameLua.GameCore.Module.Weapon.WeaponDefine")
local Config = {
  Default = {
    [WeaponDefine.ConfigKey.ItemHandle] = {
      WeaponClass = "/Game/Arts_PlayerBluePrints/Weapon/MainWeapon/Rifle/AKM/BP_Rifle_AKM.BP_Rifle_AKM",
      WrapperClass = "/Game/Arts_PlayerBluePrints/Weapon/MainWeapon/Rifle/AKM/BP_Rifle_AKM_Wrapper.BP_Rifle_AKM_Wrapper",
      SkeletonMesh = "/Game/Arts_Player/Weapon/MainWeapon/Rifle/AKM/Mesh/SK_WEP_AK47.SK_WEP_AK47",
      StaticMeshLod = "/Game/Arts_Player/Weapon/MainWeapon/Rifle/AKM/Mesh/ST_WEP_AK47_Lod.ST_WEP_AK47_Lod",
      MeshMat = "",
      SkeletonMeshLod = "",
      StaticMesh = "",
      AnimationBP = "/Game/Arts_Player/Weapon/MainWeapon/Rifle/AN94/BluePrint/SK_WEP_AN94_AnimBP.SK_WEP_AN94_AnimBP_C"
    },
    [WeaponDefine.ConfigKey.Fov] = {
      [0] = 70.0,
      [203001] = 55.0,
      [203002] = 55.0,
      [203003] = 44.444443,
      [203004] = 20.0,
      [203005] = 11.034483,
      [203014] = 26.666666,
      [203015] = 13.333333,
      [203018] = 62.0,
      [203201] = 44.444443,
      [203202] = 44.444443,
      [203051] = 55.0,
      [203052] = 55.0,
      [203053] = 44.444443,
      [203054] = 20.0,
      [203055] = 11.034483,
      [203056] = 26.666666,
      [203057] = 13.333333
    },
    [WeaponDefine.ConfigKey.Attachment] = {
      [WeaponDefine.AttachmentType.Constant] = {291001},
      [WeaponDefine.AttachmentType.Muzzle] = {201009, 201010},
      [WeaponDefine.AttachmentType.Upper] = {203001, 203002},
      [WeaponDefine.AttachmentType.Stock] = {205002},
      [WeaponDefine.AttachmentType.Magazine] = {204011},
      [WeaponDefine.AttachmentType.Lower] = {202001},
      [WeaponDefine.AttachmentType.UpperSide] = {203018}
    },
    [WeaponDefine.ConfigKey.Attribute] = {}
  },
  [101888] = {
    [WeaponDefine.ConfigKey.ItemHandle] = {},
    [WeaponDefine.ConfigKey.Fov] = {},
    [WeaponDefine.ConfigKey.Attachment] = {
      [WeaponDefine.AttachmentType.Constant] = {291001},
      [WeaponDefine.AttachmentType.Muzzle] = {201009, 201010},
      [WeaponDefine.AttachmentType.Upper] = {203001, 203002},
      [WeaponDefine.AttachmentType.Stock] = {205002},
      [WeaponDefine.AttachmentType.Magazine] = {204011},
      [WeaponDefine.AttachmentType.Lower] = {202001},
      [WeaponDefine.AttachmentType.UpperSide] = {203018}
    },
    [WeaponDefine.ConfigKey.Attribute] = {
      [WeaponDefine.Attribute.AutoShootInter] = 3.5,
      [WeaponDefine.Attribute.BaseImpactDamage] = 40,
      [WeaponDefine.Attribute.BulletRange] = 100000,
      [WeaponDefine.Attribute.RangeModifier] = 0.94,
      [WeaponDefine.Attribute.ReferenceDistance] = 19000
    }
  },
  [107008] = {
    [WeaponDefine.ConfigKey.AttackIcon] = "/Game/Mod/EvoBase/Atlas/EvoBase/Frames/Collimation_Icon_BowArrow_png.Collimation_Icon_BowArrow_png"
  },
  [107009] = {
    [WeaponDefine.ConfigKey.AttackIcon] = "/Game/Mod/EvoBase/Atlas/EvoBase/Frames/Collimation_Icon_BowArrow_png.Collimation_Icon_BowArrow_png"
  },
  [108008] = {
    [WeaponDefine.ConfigKey.AttackIcon] = "/Game/Library/Res/Weapons/Katana/Arts/UI/Atlas/Frames/ZD_Icon_Katana_png.ZD_Icon_Katana_png"
  },
  [108009] = {
    [WeaponDefine.ConfigKey.AttackIcon] = "/Game/Library/Res/Actors/BladeBall/Arts/UI/Atlas/Frames/ZD_Icon_Defense_png.ZD_Icon_Defense_png"
  },
  [106203] = {
    [WeaponDefine.ConfigKey.ItemHandle] = {
      WeaponClass = "/Game/Library/Res/Vehicles/Mecha/Arts_PlayerBlueprints/Weapon/MagneticGun/BP_MagneticGun.BP_MagneticGun",
      WrapperClass = "/Game/Library/Res/Vehicles/Mecha/Arts_PlayerBlueprints/Weapon/MagneticGun/BP_MagneticGun_Wrapper.BP_MagneticGun_Wrapper",
      SkeletonMesh = "/Game/Library/Res/Vehicles/Mecha/Arts_Player/Mesh/MagneticGun/Sceneltem_int_971_skin.Sceneltem_int_971_skin",
      SkeletonMeshLod = "/Game/Library/Res/Vehicles/Mecha/Arts_Player/Mesh/MagneticGun/Sceneltem_int_971_skin.Sceneltem_int_971_skin",
      AnimationBP = "/Game/Library/Res/Vehicles/Mecha/Arts_Player/Mesh/MagneticGun/Sceneltem_int_971_ABP.Sceneltem_int_971_ABP_C",
      IsPistol = true
    }
  },
  [106107] = {
    [WeaponDefine.ConfigKey.ItemHandle] = {
      WeaponClass = "/Game/Mod/EvoBase/Arts_PlayerBluePrints/Weapon/ReviveFlaregun/BP_Pistol_ReviveFlaregun.BP_Pistol_ReviveFlaregun",
      WrapperClass = "/Game/Mod/EvoBase/Arts_PlayerBluePrints/Weapon/ReviveFlaregun/BP_Pistol_ReviveFlaregun_Wrapper.BP_Pistol_ReviveFlaregun_Wrapper",
      SkeletonMesh = "/Game/Mod/EvoBase/Arts_Player/Sceneltem_int_970/Mesh/Sceneltem_int_970.Sceneltem_int_970",
      StaticMeshLod = "/Game/Mod/EvoBase/Arts_Player/Sceneltem_int_970/Mesh/Sceneltem_int_970_LOD.Sceneltem_int_970_LOD",
      AnimationBP = "/Game/Arts_Player/Weapon/MainWeapon/Pistol/FlareGun/BluePrint/SK_WEP_FlareGun_AnimBP.SK_WEP_FlareGun_AnimBP_C",
      IsPistol = true
    }
  },
  [108194] = {
    [WeaponDefine.ConfigKey.AttackIcon] = "/Game/Library/Res/Weapons/Pillow/Arts/Atlas/Frames/ZD_Icon_Pillow_png.ZD_Icon_Pillow_png"
  },
  [1081205] = {
    [WeaponDefine.ConfigKey.AttackIcon] = "/Game/Arts/UI/Atlas/BattleUI/General_Ver2/Frames/ZD_Icon_Karambit_png.ZD_Icon_Karambit_png"
  },
  [1081206] = {
    [WeaponDefine.ConfigKey.AttackIcon] = "/Game/Arts/UI/Atlas/BattleUI/General_Ver2/Frames/ZD_Icon_Karambit_png.ZD_Icon_Karambit_png"
  },
  [108200] = {
    [WeaponDefine.ConfigKey.AttackIcon] = "/Game/Library/Res/Weapons/Pillow/Arts/Atlas/Frames/ZD_Icon_Pillow_png.ZD_Icon_Pillow_png"
  }
}
return Config