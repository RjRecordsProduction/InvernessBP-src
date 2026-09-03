local ScreenMarkConfig = {
  [440001] = {
    UIPathName = "/Game/Mod/GodTrial/BluePrints/UI/Mark/FlameChariotScreenMark_UIBP.FlameChariotScreenMark_UIBP_C",
    MaxWidgetNum = 1,
    MaxShowDistance = 20000,
    bBindOutScreen = true,
    bBindBlocked = true,
    bIsBindingActor = true,
    bNeedPreLoad = true,
    Priority = 1,
    bNeedUpdateState = true,
    WorldPositionOffset = FVector(0, 0, 50),
    bUseLuaWorldOffset = true,
    CommonMarkConfig = {
      Icon = "/Game/Mod/EvoBase/Atlas/EvoBase/Frames/ZD_Icon_Horse_png.ZD_Icon_Horse_png",
      bDistance = true
    }
  },
  [440003] = {
    UIPathName = "/Game/Mod/GodTrial/BluePrints/UI/Mark/FramePlatformScreenMark_UIBP.FramePlatformScreenMark_UIBP_C",
    MaxWidgetNum = 4,
    MaxShowDistance = 20000,
    bBindOutScreen = true,
    bBindBlocked = true,
    bIsBindingActor = false,
    bNeedPreLoad = true,
    bNeedUpdateState = true,
    Priority = 1,
    CommonMarkConfig = {bCountDownTime = true, bDistance = true}
  },
  [440004] = {
    UIPathName = "/Game/Mod/EvoBase/BluePrints/UI/ScreenMark/Item/CommonActorScreenMark_UIBP.CommonActorScreenMark_UIBP_C",
    MaxWidgetNum = 1,
    MaxShowDistance = 6000000,
    bBindOutScreen = true,
    bBindBlocked = true,
    bIsBindingActor = false,
    bNeedPreLoad = true,
    bNeedUpdateState = true,
    Priority = 1,
    CommonMarkConfig = {
      Icon = "/Game/Mod/GodTrial/Arts/UI/Atlas/Frames/ZD_Icon_Wings_png.ZD_Icon_Wings_png",
      bDistance = true
    }
  },
  [440005] = {
    UIPathName = "/Game/Mod/EvoBase/BluePrints/UI/ScreenMark/Item/CommonActorScreenMark_UIBP.CommonActorScreenMark_UIBP_C",
    MaxWidgetNum = 1,
    MaxShowDistance = 6000000,
    bBindOutScreen = true,
    bBindBlocked = true,
    bIsBindingActor = true,
    bNeedPreLoad = true,
    bNeedUpdateState = true,
    Priority = 1,
    WorldPositionOffset = FVector(0, 0, 80),
    bUseLuaWorldOffset = true,
    CommonMarkConfig = {
      Icon = "/Game/Mod/GodTrial/Arts/UI/Atlas/Frames/ZD_Icon_LightningPositioning_png.ZD_Icon_LightningPositioning_png",
      bDistance = true
    }
  },
  [440006] = {
    UIPathName = "/Game/Mod/EvoBase/BluePrints/UI/ScreenMark/Item/CommonActorScreenMark_UIBP.CommonActorScreenMark_UIBP_C",
    MaxWidgetNum = 1,
    MaxShowDistance = 5000,
    bBindOutScreen = true,
    bBindBlocked = true,
    bIsBindingActor = false,
    bNeedPreLoad = true,
    bNeedUpdateState = true,
    Priority = 1,
    CommonMarkConfig = {
      Icon = "/Game/Mod/GodTrial/Arts/UI/Atlas/Frames/ZD_Icon_Wings_png.ZD_Icon_Wings_png",
      bDistance = true
    }
  },
  [440007] = {
    UIPathName = "/Game/Mod/EvoBase/BluePrints/UI/ScreenMark/Item/CommonActorScreenMark_UIBP.CommonActorScreenMark_UIBP_C",
    MaxWidgetNum = 1,
    MaxShowDistance = 5000,
    MinShowDistance = 100,
    bBindOutScreen = true,
    bBindBlocked = true,
    bIsBindingActor = false,
    bNeedPreLoad = true,
    bNeedUpdateState = true,
    Priority = 1,
    CommonMarkConfig = {
      Icon = "/Game/Mod/GodTrial/Arts/UI/Atlas/Frames/ZD_Icon_SpartaFlag_png.ZD_Icon_SpartaFlag_png",
      bDistance = true
    }
  },
  [440012] = {
    UIPathName = "/Game/Library/Res/AI/Centaur/BluePrints/UI/CommonActorScreenMark_UIBP_Centaur.CommonActorScreenMark_UIBP_Centaur_C",
    MaxWidgetNum = 1,
    MaxShowDistance = 15000,
    bBindOutScreen = true,
    bBindBlocked = true,
    bIsBindingActor = true,
    bNeedPreLoad = true,
    Priority = 1,
    WorldPositionOffset = FVector(60, 0, 150),
    bUseLuaWorldOffset = true,
    bUseLuaWorldSocketName = true,
    bNeedUpdateState = true,
    bIgnoreSelfPawnBlock = true,
    CommonMarkConfig = {
      Icon = "/Game/Library/Res/AI/Centaur/Arts/UI/Atlas/Frames/ZD_Icon_Map_Centaur_png.ZD_Icon_Map_Centaur_png",
      IconListDiffByTeamIndex = {
        [0] = "/Game/Library/Res/AI/Centaur/Arts/UI/Atlas/Frames/ZD_Image_CentaurtHead01_png.ZD_Image_CentaurtHead01_png",
        [1] = "/Game/Library/Res/AI/Centaur/Arts/UI/Atlas/Frames/ZD_Image_CentaurtHead02_png.ZD_Image_CentaurtHead02_png",
        [2] = "/Game/Library/Res/AI/Centaur/Arts/UI/Atlas/Frames/ZD_Image_CentaurtHead03_png.ZD_Image_CentaurtHead03_png",
        [3] = "/Game/Library/Res/AI/Centaur/Arts/UI/Atlas/Frames/ZD_Image_CentaurtHead04_png.ZD_Image_CentaurtHead04_png"
      },
      bCountDownTime = false,
      bDistance = true
    }
  },
  [440013] = {
    UIPathName = "/Game/Mod/EvoBase/BluePrints/UI/ScreenMark/Item/CommonActorScreenMark_UIBP.CommonActorScreenMark_UIBP_C",
    MaxWidgetNum = 1,
    MaxShowDistance = 10000,
    bBindOutScreen = true,
    bBindBlocked = true,
    bIsBindingActor = true,
    bNeedPreLoad = false,
    Priority = 1,
    WorldPositionOffset = FVector(0, 0, 100),
    bUseLuaWorldOffset = true,
    CommonMarkConfig = {
      Icon = "/Game/Mod/GodTrial/Arts/UI/Atlas/Frames/ZD_Icon_SHTPositioning03_png.ZD_Icon_SHTPositioning03_png",
      bCountDownTime = false,
      bDistance = true
    }
  },
  [440014] = {
    UIPathName = "/Game/Mod/EvoBase/BluePrints/UI/ScreenMark/Item/CommonActorScreenMark_UIBP.CommonActorScreenMark_UIBP_C",
    MaxWidgetNum = 1,
    MaxShowDistance = 10000,
    bBindOutScreen = true,
    bBindBlocked = true,
    bIsBindingActor = false,
    bNeedPreLoad = false,
    Priority = 1,
    WorldPositionOffset = FVector(0, 0, 100),
    bUseLuaWorldOffset = true,
    CommonMarkConfig = {
      Icon = "/Game/Mod/GodTrial/Arts/UI/Atlas/Frames/ZD_Icon_SHT_png.ZD_Icon_SHT_png",
      bCountDownTime = true,
      bDistance = true
    }
  },
  [440015] = {
    UIPathName = "/Game/Mod/EvoBase/BluePrints/UI/ScreenMark/Item/CommonActorScreenMark_UIBP.CommonActorScreenMark_UIBP_C",
    MaxWidgetNum = 1,
    MaxShowDistance = 6000,
    MinShowDistance = 800,
    bBindOutScreen = true,
    bBindBlocked = true,
    bIsBindingActor = true,
    bNeedPreLoad = true,
    Priority = 1,
    WorldPositionOffset = FVector(0, 0, 30),
    bUseLuaWorldOffset = true,
    CommonMarkConfig = {
      Icon = "/Game/Mod/VersionRes/440/Arts/UI/Atlas/Frames/PlanNT_ICON_Interaction_png.PlanNT_ICON_Interaction_png",
      bCountDownTime = false,
      bDistance = true
    }
  },
  [440016] = {
    UIPathName = "/Game/Mod/EvoBase/BluePrints/UI/ScreenMark/Item/CommonActorScreenMark_UIBP.CommonActorScreenMark_UIBP_C",
    MaxWidgetNum = 1,
    MaxShowDistance = 6000,
    MinShowDistance = 800,
    bBindOutScreen = true,
    bBindBlocked = true,
    bIsBindingActor = true,
    bNeedPreLoad = true,
    Priority = 1,
    WorldPositionOffset = FVector(0, 0, 30),
    bUseLuaWorldOffset = true,
    CommonMarkConfig = {
      Icon = "/Game/Mod/VersionRes/440/Arts/UI/Atlas/Frames/PlanNT_ICON_Interaction_png.PlanNT_ICON_Interaction_png",
      bCountDownTime = false,
      bDistance = true
    }
  },
  [440017] = {
    UIPathName = "/Game/Mod/EvoBase/BluePrints/UI/ScreenMark/Item/CommonActorScreenMark_UIBP.CommonActorScreenMark_UIBP_C",
    MaxWidgetNum = 1,
    MaxShowDistance = 50000,
    MinShowDistance = 300,
    bBindOutScreen = true,
    bBindBlocked = true,
    bIsBindingActor = true,
    bNeedPreLoad = true,
    Priority = 1,
    WorldPositionOffset = FVector(0, 0, 30),
    bUseLuaWorldOffset = true,
    CommonMarkConfig = {
      Icon = "/Game/Mod/GodTrial/Arts/UI/Atlas/Frames/ZD_Icon_Castle_png.ZD_Icon_Castle_png",
      bCountDownTime = true,
      bDistance = true
    }
  }
}
return ScreenMarkConfig