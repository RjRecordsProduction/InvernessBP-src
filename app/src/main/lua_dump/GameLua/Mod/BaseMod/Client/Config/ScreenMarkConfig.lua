local FScreenMarkGroupConfig = import("ScreenMarkGroupConfig")
local ScreenMarkUIGroupConfig = {
  GroupMaxNumConfig = {Group1 = 1},
  OtherConfig = {MaxPreloadNum = 5, MaxWidgetNum = 20},
  [1001] = {
    UIPathName = "/Game/Mod/EvoBase/BluePrints/UI/ReviveTowerUI/ReviveTowerScreenMark.ReviveTowerScreenMark_C",
    MaxWidgetNum = 1,
    MaxShowDistance = 6000000,
    bBindOutScreen = true,
    bBindBlocked = true,
    bIsBindingActor = false,
    bNeedPreLoad = true,
    GroupTag = "Group1",
    Priority = 1,
    WorldPositionOffset = FVector(0, 0, 80)
  },
  [1002] = {
    UIPathName = "/Game/Library/Res/Actors/Store/BluePrints/ClassicStoreScreenMarkUI.ClassicStoreScreenMarkUI_C",
    MaxWidgetNum = 1,
    MaxShowDistance = 4000,
    bBindOutScreen = true,
    bBindBlocked = true,
    bIsBindingActor = false,
    bNeedPreLoad = true,
    GroupTag = "Group1",
    Priority = 2,
    bNeedOBShow = false
  },
  [1003] = {
    UIPathName = "/Game/Mod/EvoBase/BluePrints/UIBP/QuickSign/QuickSign_TipHitEnemy_UIBP_New.QuickSign_TipHitEnemy_UIBP_New_C",
    MaxWidgetNum = 4,
    MaxShowDistance = 80000,
    bBindOutScreen = true,
    bBindBlocked = true,
    bNeedPreLoad = true,
    bIsBindingActor = false,
    WorldPositionOffset = FVector(0, 0, 80)
  },
  [1004] = {
    UIPathName = "/Game/BluePrints/ControlInput/IngameUI/Captive/Captive_TeamUp_S_BP.Captive_TeamUp_S_BP_C",
    MaxWidgetNum = 10,
    MaxShowDistance = 6000000,
    bBindOutScreen = true,
    bBindBlocked = true,
    bIsBindingActor = false,
    WorldPositionOffset = FVector(0, 0, 80)
  },
  [1005] = {
    UIPathName = "/Game/Library/Res/Actors/Store/BluePrints/DiscountStoreScreenMarkUI.DiscountStoreScreenMarkUI_C",
    MaxWidgetNum = 4,
    MaxShowDistance = 2000,
    bBindOutScreen = false,
    bBindBlocked = true,
    bIsBindingActor = true,
    bNeedPreLoad = true,
    bNeedOBShow = false
  },
  [1006] = {
    UIPathName = "/Game/Mod/EvoBase/BluePrints/UI/ScreenMark/Item/HpBarUIBP.HpBarUIBP_C",
    MaxWidgetNum = 4,
    MaxShowDistance = 6000000,
    WorldPositionOffset = FVector(0, 0, 200),
    bBindOutScreen = false,
    bBindBlocked = false,
    bNeedPreLoad = true,
    bIsBindingActor = true,
    BindSocketName = "",
    bUseLuaWorldOffset = true
  },
  [1007] = {
    UIPathName = "/Game/Mod/EvoBase/BluePrints/UI/ScreenMark/Item/MonsterSkillWarning_UIBP.MonsterSkillWarning_UIBP_C",
    MaxWidgetNum = 6,
    MaxShowDistance = 6000000,
    bIsBindingActor = true,
    WorldPositionOffset = FVector(0, 0, 30)
  },
  [1009] = {
    UIPathName = "/Game/Library/Res/Actors/Store/BluePrints/FarClassicStoreScreenMarkUI.FarClassicStoreScreenMarkUI_C",
    MaxWidgetNum = 1,
    MaxShowDistance = 6000000,
    bBindOutScreen = true,
    bBindBlocked = true,
    bIsBindingActor = false,
    bNeedPreLoad = true,
    GroupTag = "Group1",
    Priority = 3,
    WorldPositionOffset = FVector(0, 0, 80),
    bNeedOBShow = false
  },
  [1010] = {
    UIPathName = "/Game/BluePrints/ControlInput/IngameUI/ShouleiGrenadePosition_UIBP.ShouleiGrenadePosition_UIBP_C",
    MaxWidgetNum = 30,
    MaxShowDistance = 30000,
    bBindOutScreen = true,
    bBindBlocked = true,
    bNeedPreLoad = true,
    bIsBindingActor = true
  },
  [1011] = {
    UIPathName = "/Game/BluePrints/UI/OBUI/Item/OB_VehicleHP_BP.OB_VehicleHP_BP_C",
    bNeedPreLoad = false,
    bIsBindingActor = true,
    MaxWidgetNum = 10,
    MaxShowDistance = 30000,
    bBindOutScreen = false,
    bBindBlocked = true,
    WorldPositionOffset = FVector(0, 0, 80),
    LimitXY = FVector2D(10, 10),
    LimitZW = FVector2D(10, 10)
  },
  [1012] = {
    UIPathName = "/Game/Library/Res/Actors/Mecha/BluePrints/UI/RepairFactory_ScreenMark_UIBP.RepairFactory_ScreenMark_UIBP_C",
    bIsBindingActor = false,
    MaxWidgetNum = 1,
    bBindBlocked = true,
    MaxShowDistance = 10000,
    bNeedPreLoad = true
  },
  [1013] = {
    UIPathName = "/Game/Library/Res/Actors/BackRoom/SecretArmory_ScreenMark_UIBP.SecretArmory_ScreenMark_UIBP_C",
    MaxWidgetNum = 1,
    MaxShowDistance = 1500,
    bBindOutScreen = false,
    bBindBlocked = true,
    bIsBindingActor = false,
    bNeedPreLoad = true,
    bNeedOBShow = false
  },
  [1014] = {
    UIPathName = "/Game/Library/Res/Vehicles/Horse/BluePrints/UI/RecallHorse_ScreenMark_UIBP.RecallHorse_ScreenMark_UIBP_C",
    MaxWidgetNum = 1,
    MaxShowDistance = 1500,
    bBindOutScreen = false,
    bBindBlocked = true,
    bIsBindingActor = true,
    bNeedPreLoad = true,
    WorldPositionOffset = FVector(0, 0, 180)
  },
  [103501] = {
    UIPathName = "/Game/Mod/IceWorld3/BluePrints/UI/Nutcracker_ScreenMark_UIBP.Nutcracker_ScreenMark_UIBP_C",
    MaxWidgetNum = 1,
    MaxShowDistance = 2000,
    MinShowDistance = 500,
    bBindOutScreen = true,
    bBindBlocked = true,
    bIsBindingActor = true,
    bNeedPreLoad = true
  },
  [1015] = {
    UIPathName = "/Game/Mod/EvoBase/BluePrints/UIBP/Mark/Common_Treasure_Chests_UIBP.Common_Treasure_Chests_UIBP_C",
    MaxWidgetNum = 1,
    MaxShowDistance = 5500,
    MinShowDistance = 500,
    bBindOutScreen = true,
    bBindBlocked = true,
    bIsBindingActor = true,
    bNeedPreLoad = true
  },
  [1016] = {
    UIPathName = "/Game/Mod/VersionRes/370/ThemePreheat/Preheat_UIBP.Preheat_UIBP_C",
    MaxWidgetNum = 1,
    MaxShowDistance = 2000,
    MinShowDistance = 500,
    bBindOutScreen = false,
    bBindBlocked = true,
    bIsBindingActor = false,
    bNeedPreLoad = true
  },
  [1017] = {
    UIPathName = "/Game/Library/Res/Weapons/DaggerOfTime/BluePrints/UI/ScreenMark/DaggerOfTime_ScreenMark_UIBP.DaggerOfTime_ScreenMark_UIBP_C",
    MaxWidgetNum = 1,
    MaxShowDistance = 2000,
    MinShowDistance = 500,
    bBindOutScreen = false,
    bBindBlocked = true,
    bIsBindingActor = false,
    bNeedPreLoad = true
  },
  [999] = {
    UIPathName = "/Game/Mod/EvoBase/Textures/Atlas/ResidentStore/Frames/ResidentStore_Map_Shop_png.ResidentStore_Map_Shop_png",
    MaxWidgetNum = 4,
    MaxShowDistance = 6000000,
    IconSize = FVector2D(55, 55),
    UIOffset = FVector2D(0, -55),
    bBindOutScreen = false,
    bBindBlocked = false,
    bIsBindingActor = false,
    bIsUpdatedByPanel = true,
    bNeedPreLoad = true
  },
  [1018] = {
    UIPathName = "/Game/Mod/Neon/Arts/Atlas/Frames/ZD_Icon_Map_Premium_Store_png.ZD_Icon_Map_Premium_Store_png",
    MaxWidgetNum = 1,
    MaxShowDistance = 2000,
    MinShowDistance = 500,
    bBindOutScreen = false,
    bBindBlocked = true,
    bIsBindingActor = false,
    bNeedPreLoad = true
  },
  [1019] = {
    UIPathName = "/Game/Mod/EvoBase/BluePrints/UI/ScreenMark/Item/CommonLocationScreenMark_UIBP1.CommonLocationScreenMark_UIBP1_C",
    MaxWidgetNum = 1,
    MaxShowDistance = 6000000,
    bBindOutScreen = true,
    bBindBlocked = true,
    bIsBindingActor = false,
    bNeedPreLoad = true,
    bNeedUpdateState = true,
    Priority = 1,
    CommonMarkConfig = {
      Icon = "/Game/Mod/Neon/Arts/Atlas/Frames/ZD_Icon_Map_Premium_Store_png.ZD_Icon_Map_Premium_Store_png",
      bCountDownTime = true,
      bDistance = true
    }
  },
  [1020] = {
    UIPathName = "/Game/Mod/EvoBase/BluePrints/UI/ScreenMark/Item/CommonActorScreenMark_UIBP.CommonActorScreenMark_UIBP_C",
    MaxWidgetNum = 1,
    MaxShowDistance = 6000000,
    bBindOutScreen = true,
    bBindBlocked = true,
    bIsBindingActor = true,
    bNeedPreLoad = true,
    Priority = 1,
    WorldPositionOffset = FVector(0, 0, 280),
    bUseLuaWorldOffset = true,
    bNeedUpdateState = true,
    CommonMarkConfig = {
      Icon = "/Game/Mod/Neon/Arts/Atlas/Frames/ZD_Icon_Map_Premium_Store_png.ZD_Icon_Map_Premium_Store_png",
      bCountDownTime = true,
      bDistance = true
    }
  },
  [1021] = {
    UIPathName = "/Game/Mod/EvoBase/BluePrints/UI/ScreenMark/Item/HpBarUIBP.HpBarUIBP_C",
    MaxWidgetNum = 4,
    MaxShowDistance = 10000,
    MinShowDistance = 300,
    bUseLuaWorldOffset = true,
    WorldPositionOffset = FVector(0, 0, 0),
    bBindOutScreen = false,
    bBindBlocked = false,
    bNeedPreLoad = true,
    bIsBindingActor = true,
    BindSocketName = "RepairMarkSocket"
  },
  [1022] = {
    UIPathName = "/Game/Mod/EvoBase/BluePrints/UI/ScreenMark/Item/HpBarUIBP.HpBarUIBP_C",
    MaxWidgetNum = 4,
    MaxShowDistance = 10000,
    MinShowDistance = 300,
    bUseLuaWorldOffset = true,
    WorldPositionOffset = FVector(0, 0, 0),
    bBindOutScreen = false,
    bBindBlocked = false,
    bNeedPreLoad = true,
    bIsBindingActor = true,
    BindSocketName = "RepairMarkSocket"
  },
  [1024] = {
    UIPathName = "/Game/Mod/VersionRes/390/SurpriseAirdrop/BluePrints/UI/BornIslandAirDrop_Mark_UIBP.BornIslandAirDrop_Mark_UIBP_C",
    MaxWidgetNum = 1,
    MaxShowDistance = 60000,
    MinShowDistance = 300,
    bBindOutScreen = true,
    bBindBlocked = true,
    bIsBindingActor = true,
    bNeedPreLoad = true,
    bNeedUpdateState = true,
    Priority = 1,
    CommonMarkConfig = {bCountDownTime = true}
  },
  [1025] = {
    UIPathName = "/Game/Library/Res/Vehicles/TFMecha/BluePrints/UI/ScreenMark/Optimus_ScreenMark_Exclamation_UIBP.Optimus_ScreenMark_Exclamation_UIBP_C",
    MaxWidgetNum = 1,
    MaxShowDistance = 5000,
    MinShowDistance = 300,
    bUseLuaWorldOffset = true,
    WorldPositionOffset = FVector(0, 0, 0),
    bBindOutScreen = true,
    bBindBlocked = true,
    bNeedPreLoad = true,
    bIsBindingActor = true,
    BindSocketName = "ScreenMark"
  },
  [1026] = {
    UIPathName = "/Game/Mod/EvoBase/BluePrints/UI/ScreenMark/Item/CommonActorScreenMark_UIBP.CommonActorScreenMark_UIBP_C",
    MaxWidgetNum = 1,
    MaxShowDistance = 2000,
    MinShowDistance = 500,
    bBindOutScreen = true,
    bBindBlocked = true,
    bNeedPreLoad = true,
    bIsBindingActor = true,
    Priority = 1,
    WorldPositionOffset = FVector(0, 0, 280),
    CommonMarkConfig = {
      Icon = "/Game/Mod/BlueHoleWell/Arts/UI/Atlas/Frames/ZD_Icon_BlueHoleWell_FireworkLauncher_png.ZD_Icon_BlueHoleWell_FireworkLauncher_png",
      bCountDownTime = false,
      bDistance = true
    }
  },
  [1028] = {
    UIPathName = "/Game/Mod/EvoBase/BluePrints/UI/ScreenMark/Item/CommonLocationScreenMark_UIBP1.CommonLocationScreenMark_UIBP1_C",
    MaxWidgetNum = 1,
    MaxShowDistance = 2000,
    MinShowDistance = 50,
    bBindOutScreen = true,
    bBindBlocked = true,
    bIsBindingActor = false,
    Priority = 1,
    WorldPositionOffset = FVector(0, 0, 200),
    CommonMarkConfig = {
      Icon = "/Game/Library/Res/Actors/Festival/Art/UI/Atlas/Frames/ZD_Tips_ChristmasTree_png.ZD_Tips_ChristmasTree_png",
      bCountDownTime = false,
      bDistance = true
    }
  },
  [1029] = {
    UIPathName = "/Game/Mod/EvoBase/BluePrints/UI/ScreenMark/Item/CommonLocationScreenMark_UIBP1.CommonLocationScreenMark_UIBP1_C",
    MaxWidgetNum = 1,
    MaxShowDistance = 2000,
    MinShowDistance = 50,
    bBindOutScreen = true,
    bBindBlocked = true,
    bIsBindingActor = false,
    Priority = 1,
    WorldPositionOffset = FVector(0, 0, 200),
    CommonMarkConfig = {
      Icon = "/Game/Library/Res/Actors/Festival/Art/UI/Atlas/Frames/ZD_icon_ChristmasSock_Mutually_png.ZD_icon_ChristmasSock_Mutually_png",
      bCountDownTime = false,
      bDistance = false
    }
  },
  [1030] = {
    UIPathName = "/Game/Mod/EvoBase/BluePrints/UIBP/Mark/Picnic_Meteorite_ScreenMark_02_UIBP.Picnic_Meteorite_ScreenMark_02_UIBP_C",
    MaxWidgetNum = 1,
    MaxShowDistance = 6000,
    MinShowDistance = 600,
    bBindOutScreen = true,
    bBindBlocked = true,
    bIsBindingActor = false,
    Priority = 1,
    WorldPositionOffset = FVector(0, 0, 200),
    bNeedPreLoad = true
  },
  [410014] = {
    UIPathName = "/Game/Mod/EvoBase/BluePrints/UI/ScreenMark/Item/CommonActorScreenMark_UIBP.CommonActorScreenMark_UIBP_C",
    MaxWidgetNum = 5,
    MaxShowDistance = 5000,
    MinShowDistance = 200,
    bBindOutScreen = true,
    bBindBlocked = true,
    bIsBindingActor = true,
    bNeedPreLoad = true,
    Priority = 1,
    WorldPositionOffset = FVector(0, 0, 50),
    bUseLuaWorldOffset = true,
    CommonMarkConfig = {
      Icon = "/Game/Library/Res/Actors/Festival/Art/UI/Atlas/Frames/ZD_icon_Punch_Table_png.ZD_icon_Punch_Table_png",
      bDistance = true
    }
  },
  [410050] = {
    UIPathName = "/Game/Mod/Anamika/Icon/UIBP/Map_GhostBride_UIBP_01.Map_GhostBride_UIBP_01",
    MaxWidgetNum = 5,
    MaxShowDistance = 7000,
    MinShowDistance = 3000,
    bBindOutScreen = true,
    bBindBlocked = true,
    bIsBindingActor = true,
    bNeedPreLoad = true,
    Priority = 1,
    WorldPositionOffset = FVector(0, 0, 50),
    bUseLuaWorldOffset = true
  },
  [1031] = {
    UIPathName = "/Game/Library/Res/Vehicles/Scorpion/Blueprints/UI/Scorpion_ArmorBarUI.Scorpion_ArmorBarUI_C",
    MaxWidgetNum = 4,
    MaxShowDistance = 10000,
    MinShowDistance = 300,
    bUseLuaWorldOffset = true,
    WorldPositionOffset = FVector(0, 0, 0),
    bBindOutScreen = false,
    bBindBlocked = false,
    bNeedPreLoad = true,
    bIsBindingActor = true,
    BindSocketName = "HPBarBindSocket"
  },
  [1032] = {
    UIPathName = "/Game/Mod/EvoBase/BluePrints/UI/ScreenMark/Item/CommonLocationScreenMark_UIBP1.CommonLocationScreenMark_UIBP1_C",
    MaxWidgetNum = 1,
    MaxShowDistance = 7000,
    MinShowDistance = 450,
    bBindOutScreen = true,
    bBindBlocked = true,
    bIsBindingActor = false,
    Priority = 1,
    WorldPositionOffset = FVector(0, 0, 0),
    CommonMarkConfig = {
      Icon = "/Game/Library/Res/Actors/ThemePreheat/V430/Arts/UI/Atlas/Frames/ZD_Icon_Crack_png.ZD_Icon_Crack_png",
      bCountDownTime = false,
      bDistance = true
    }
  },
  [1033] = {
    UIPathName = "/Game/Library/Res/Actors/RaceCar/BluePrints/UI/RacingCheckPoint_ScreenMark_UIBP.RacingCheckPoint_ScreenMark_UIBP_C",
    MaxWidgetNum = 1,
    MaxShowDistance = 150000,
    MinShowDistance = 1000,
    bBindOutScreen = true,
    bBindBlocked = true,
    bIsBindingActor = false,
    bNeedUpdateState = true,
    bNeedReplayShow = false,
    Priority = 1,
    UpdateBindingInterval = 1.0,
    bNeedPreLoad = true
  },
  [1034] = {
    UIPathName = "/Game/Library/Res/Actors/RaceCar/BluePrints/UI/RacingStartLine_ScreenMark_UIBP.RacingStartLine_ScreenMark_UIBP_C",
    MaxWidgetNum = 1,
    MaxShowDistance = 15000,
    MinShowDistance = 500,
    bBindOutScreen = true,
    bBindBlocked = true,
    bIsBindingActor = false,
    bNeedUpdateState = true,
    bNeedReplayShow = false,
    Priority = 1,
    UpdateBindingInterval = 1.0,
    bNeedPreLoad = true
  },
  [1035] = {
    UIPathName = "/Game/BluePrints/ControlInput/ResultsshareUI/DeathPlaybackNew_Head_Item.DeathPlaybackNew_Head_Item_C",
    MaxWidgetNum = 1,
    bBindOutScreen = true,
    bBindBlocked = true,
    bIsBindingActor = true,
    bNeedPreLoad = false,
    Priority = 1,
    WorldPositionOffset = FVector(0, 0, 80),
    BindSocketName = "HelmetSocket"
  }
}
return ScreenMarkUIGroupConfig