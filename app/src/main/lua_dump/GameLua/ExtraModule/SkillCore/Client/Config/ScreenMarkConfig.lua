local ScreenMarkConfig = {
  GroupMaxNumConfig = {GroupPickup = 9},
  [901] = {
    UIPathName = "/Game/Library/Res/UICommon/ScreenMark/HighLevelPickupScreenMark.HighLevelPickupScreenMark_C",
    MaxWidgetNum = 9,
    MaxShowDistance = 20000,
    MinShowDistance = 300,
    bBindOutScreen = true,
    bBindBlocked = true,
    bIsBindingActor = false,
    bNeedUpdateState = true,
    bNeedReplayShow = false,
    GroupTag = "GroupPickup",
    Priority = 1,
    UpdateBindingInterval = 1.0,
    bNeedPreLoad = true
  },
  [902] = {
    UIPathName = "/Game/Library/Res/UICommon/ScreenMark/MiddleLevelPickupScreenMark.MiddleLevelPickupScreenMark_C",
    MaxWidgetNum = 9,
    MaxShowDistance = 20000,
    MinShowDistance = 300,
    bBindOutScreen = true,
    bBindBlocked = true,
    bIsBindingActor = false,
    bNeedUpdateState = true,
    bNeedReplayShow = false,
    GroupTag = "GroupPickup",
    Priority = 2,
    UpdateBindingInterval = 1.0,
    bNeedPreLoad = true
  },
  [400101] = {
    UIPathName = "/Game/Library/Res/Skills/GhostMark/BluePrints/UI/GhostMark_UIBP.GhostMark_UIBP_C",
    MaxWidgetNum = 4,
    MaxShowDistance = 6000000,
    bBindOutScreen = true,
    bBindBlocked = true,
    bIsBindingActor = true,
    WorldPositionOffset = FVector(0, 0, 50),
    bNeedPreLoad = true,
    bNeedOBShow = true
  },
  [400102] = {
    UIPathName = "/Game/Library/Res/Skills/GhostMark/BluePrints/UI/GhostBurning_UIBP.GhostBurning_UIBP_C",
    MaxWidgetNum = 4,
    MaxShowDistance = 6000000,
    bBindOutScreen = true,
    bBindBlocked = true,
    bIsBindingActor = true,
    WorldPositionOffset = FVector(0, 0, 50),
    bNeedPreLoad = true,
    bNeedOBShow = true
  },
  [400103] = {
    UIPathName = "/Game/Library/Res/Skills/GhostMark/BluePrints/UI/GhostAim_UIBP.GhostAim_UIBP_C",
    MaxWidgetNum = 4,
    MaxShowDistance = 6000000,
    bBindOutScreen = true,
    bBindBlocked = true,
    bIsBindingActor = true,
    WorldPositionOffset = FVector(0, 0, 50),
    bNeedPreLoad = true,
    bNeedOBShow = true
  },
  [400104] = {
    UIPathName = "/Game/Library/Res/Skills/NatureBow/Blueprint/UI/MapMark_Pollen_UIBP.MapMark_Pollen_UIBP_C",
    MaxWidgetNum = 4,
    MaxShowDistance = 90000,
    bBindOutScreen = true,
    bBindBlocked = true,
    bIsBindingActor = true,
    WorldPositionOffset = FVector(0, 0, 50),
    bNeedPreLoad = true
  },
  [400105] = {
    UIPathName = "/Game/Library/Res/Skills/NatureBow/Blueprint/UI/MapMark_Pollen_UIBP.MapMark_Pollen_UIBP_C",
    MaxWidgetNum = 4,
    MaxShowDistance = 6000000,
    bBindOutScreen = true,
    bBindBlocked = true,
    bIsBindingActor = true,
    WorldPositionOffset = FVector(0, 0, 50),
    bNeedPreLoad = true,
    bNeedOBShow = true
  },
  [420100] = {
    UIPathName = "/Game/Library/Res/Skills/VineHook/BluePrints/UI/MapMark_Shackle_UIBP.MapMark_Shackle_UIBP_C",
    MaxWidgetNum = 4,
    IconSize = FVector2D(24, 24),
    MaxShowDistance = 3000,
    bBindOutScreen = true,
    bBindBlocked = true,
    bIsBindingActor = true,
    WorldPositionOffset = FVector(0, 0, 130),
    bNeedPreLoad = true
  },
  [420101] = {
    UIPathName = "/Game/Library/Res/Skills/VineHook/BluePrints/UI/MapMark_VineVehicle.MapMark_VineVehicle_C",
    MaxWidgetNum = 4,
    IconSize = FVector2D(24, 24),
    BindSocketName = "HeadSocket",
    bUseLuaWorldSocketName = true,
    MaxShowDistance = 4000,
    bBindOutScreen = true,
    bBindBlocked = true,
    bIsBindingActor = true,
    WorldPositionOffset = FVector(0, 0, 0),
    bNeedPreLoad = true
  },
  [420102] = {
    UIPathName = "/Game/Library/Res/Skills/VineHook/BluePrints/UI/MapMark_ControlVines_UIBP.MapMark_ControlVines_UIBP_C",
    MaxWidgetNum = 1,
    IconSize = FVector2D(24, 24),
    MaxShowDistance = 15000,
    bBindOutScreen = true,
    bBindBlocked = true,
    bIsBindingActor = true,
    WorldPositionOffset = FVector(0, 0, 50),
    bNeedPreLoad = true
  },
  [430101] = {
    UIPathName = "/Game/Library/Res/Skills/GhostMark/BluePrints/UI/GhostAim_UIBP.GhostAim_UIBP_C",
    MaxWidgetNum = 4,
    MaxShowDistance = 6000000,
    bBindOutScreen = true,
    bBindBlocked = true,
    bIsBindingActor = true,
    WorldPositionOffset = FVector(0, 0, 50),
    bNeedPreLoad = true,
    bNeedOBShow = true
  },
  [440101] = {
    UIPathName = "/Game/Mod/EvoBase/BluePrints/UI/ScreenMark/Item/CommonActorScreenMark_UIBP.CommonActorScreenMark_UIBP_C",
    MaxWidgetNum = 1,
    MaxShowDistance = 2000,
    bBindOutScreen = true,
    bBindBlocked = true,
    bIsBindingActor = true,
    bNeedPreLoad = true,
    Priority = 1,
    WorldPositionOffset = FVector(0, 0, 50),
    bUseLuaWorldOffset = true,
    CommonMarkConfig = {
      Icon = "/Game/Mod/GodTrial/Arts/UI/Atlas/Frames/ZD_Icon_SpartaPositioning_png.ZD_Icon_SpartaPositioning_png",
      bCountDownTime = true,
      bDistance = true
    }
  }
}
return ScreenMarkConfig