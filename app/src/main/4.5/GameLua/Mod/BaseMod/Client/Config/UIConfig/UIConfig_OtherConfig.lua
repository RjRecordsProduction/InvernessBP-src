local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local EUIConfigPoolType = require("client.slua.config.ClientMacros.EUIConfigPoolType")
local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local UIConfig_OtherConfig = {
  BornIsLandAirdrop_ActivityTips_UIBP = {
    moduleName = "GameLua.Mod.Library.Client.SurpriseAirDrop.BornIsLandAirdropActivityTips",
    path = "/Game/Mod/VersionRes/390/SurpriseAirdrop/BluePrints/UI/BornIsLandAirdrop_ActivityTips_UIBP.BornIsLandAirdrop_ActivityTips_UIBP",
    isMainUI = false,
    asy = true,
    loadFromPool = EUIConfigPoolType.None,
    uiStat = {
      name = "BornIsLandAirdrop_ActivityTips_UIBP"
    }
  },
  BroomControlUI = {
    moduleName = "GameLua.Mod.Library.GamePlay.Vehicle.Broom.BroomControlUI",
    path = "/Game/Library/Res/Vehicles/Broom/Blueprints/UI/Broom_ControlUI.Broom_ControlUI",
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    uiStat = {
      name = "\233\173\148\230\179\149\230\137\171\229\184\154"
    },
    AndroidBackType = EAndroidBackType.Ban
  },
  CamelControlUI = {
    moduleName = "GameLua.Mod.Library.GamePlay.Vehicle.Camel.CamelControlUI",
    path = "/Game/Library/Res/Vehicles/Camel/Blueprints/UI/Camel_ControlUI.Camel_ControlUI",
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    uiStat = {
      name = "CamelControlUI"
    },
    AndroidBackType = EAndroidBackType.Ban
  },
  HeavyWeaponMechaVehicleControlUI = {
    moduleName = "GameLua.Mod.HeavyWeapon.Client.UI.MechaVehicleControlUI",
    path = "/Game/Library/Res/Vehicles/Mecha/BluePrints/UI/MechaVehicleControlUI.MechaVehicleControlUI",
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    uiStat = {
      name = "HeavyWeaponMechaVehicleControlUI"
    },
    AndroidBackType = EAndroidBackType.Ban
  },
  Ice98KChargingUI = {
    moduleName = "GameLua.Mod.Library.GamePlay.Weapon.Ice98K.Ice98KChargingUI",
    path = "/Game/Library/Res/Weapons/Kar98kIce/BluePrint/UI/BPChargingCrossHair.BPChargingCrossHair",
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    uiStat = {
      name = "Ice98KChargingUI"
    },
    AndroidBackType = EAndroidBackType.Ban
  },
  IronSightTestPanel = {
    moduleName = "GameLua.Dev.IngameGM.IngameGMItems.IngameGMIronTestPanel",
    path = "/Game/Mod/MemLeakTest/BluePrints/Core/IronSightsCheckMain_UIBP.IronSightsCheckMain_UIBP",
    fullScreen = true,
    uiStat = {
      name = "GM IngameGMIronTestPanel"
    },
    containerName = UIContainers.Top,
    isSingleton = true
  },
  OnIceRoadInfo = {
    moduleName = "GameLua.Mod.Library.Client.UI.SpecialMove.OnIceRoadInfo",
    path = "/Game/Library/Res/Skills/IceRoad/Arts_PlayerBluePrints/UI/OnIceRoadInfo_UIBP.OnIceRoadInfo_UIBP",
    isMainUI = false,
    isWindowsOBHide = true,
    zOrder = 1,
    asy = true,
    uiStat = {
      name = "OnIceRoadInfo"
    }
  },
  GiantSyringeLeftUI = {
    moduleName = "GameLua.Mod.Library.Client.UI.GiantSyringe.GiantSyringeLeftUI",
    path = "/Game/Library/Res/Actors/GiantSyringe/BluePrints/GiantSyringeSkillAttackBtn.GiantSyringeSkillAttackBtn",
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    AndroidBackType = EAndroidBackType.Ban
  },
  GiantSyringeRightUI = {
    moduleName = "GameLua.Mod.Library.Client.UI.GiantSyringe.GiantSyringeRightUI",
    path = "/Game/Library/Res/Actors/GiantSyringe/BluePrints/GiantSyringeSkillAttackBtn.GiantSyringeSkillAttackBtn",
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    AndroidBackType = EAndroidBackType.Ban
  },
  SyringerSwitchPanel = {
    moduleName = "GameLua.Mod.Library.Client.UI.GiantSyringe.SyringerSwitchPanel",
    path = "/Game/Library/Res/Actors/GiantSyringe/BluePrints/GiantSyringeSwitchPanel.GiantSyringeSwitchPanel",
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    AndroidBackType = EAndroidBackType.Ban
  },
  MTCrosshairUI = {
    moduleName = "GameLua.Mod.PlanTF.Client.UI.VehicleControl.TFCrosshairUI",
    path = "/Game/Library/Res/Vehicles/TFMecha/BluePrints/UI/TFMecha_Crosshair_02_UIBP.TFMecha_Crosshair_02_UIBP",
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    uiStat = {
      name = "MTCrosshairUI"
    },
    AndroidBackType = EAndroidBackType.Ban
  },
  MTVehicleCrosshairUI = {
    moduleName = "GameLua.Mod.PlanTF.Client.UI.VehicleControl.MTVehicleCrosshairUI",
    path = "/Game/Library/Res/Vehicles/TFMecha/BluePrints/UI/TFMecha_Crosshair_UIBP.TFMecha_Crosshair_UIBP",
    isMainUI = false,
    containerName = UIContainers.Bottom,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    uiStat = {
      name = "MTVehicleCrosshairUI"
    },
    AndroidBackType = EAndroidBackType.Ban
  },
  Multi_InteractiveUI = {
    moduleName = "GameLua.Mod.PlanPH.Client.UI.PlanPH_Multi_InteractiveUI",
    path = "/Game/Mod/PlanPH/BluePrints/UI/Interact/PlanPH_Multi_Interactive_UIBP.PlanPH_Multi_Interactive_UIBP",
    isSingleton = true,
    uiStat = {
      name = "Multi_InteractiveUI"
    }
  },
  NewbieGuideTip = {
    moduleName = "GameLua.Mod.NewbieGame.Client.NewbieGuideTip",
    path = "/Game/Mod/NewbieGame/BluePrints/Tips/Lobby_Mid_MiniTv_Tips_Novice_Open.Lobby_Mid_MiniTv_Tips_Novice_Open",
    uiStat = {
      name = "NewbieGuideTip"
    },
    zOrder = 1,
    closeOnHide = false,
    isMainUI = false
  },
  OPCrosshairUI = {
    moduleName = "GameLua.Mod.PlanTF.Client.UI.VehicleControl.TFCrosshairUIOP",
    path = "/Game/Library/Res/Vehicles/TFMecha/BluePrints/UI/Optimus/Optimus_Crosshair_UIBP.Optimus_Crosshair_UIBP",
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    uiStat = {
      name = "OPCrosshairUI"
    },
    AndroidBackType = EAndroidBackType.Ban
  },
  SingleReviveCountUI = {
    moduleName = "GameLua.Mod.Library.Revive1800.GamePlay.UI.SingleReviveCountUI",
    path = "/Game/Mod/EvoBase/BluePrints/UI/ReviveTowerUI/SingleReviePanel_UIBP.SingleReviePanel_UIBP",
    uiStat = {
      name = "SingleReviveCountUI"
    },
    isSingleton = true,
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    zOrder = 0
  },
  SurpriseAirdrop_Critical_Hit_Tips = {
    moduleName = "GameLua.Mod.Library.Client.SurpriseAirDrop.SurpriseAirdropTip",
    path = "/Game/Mod/VersionRes/390/SurpriseAirdrop/BluePrints/UI/Tips/SurpriseAirdrop_Critical_Hit_Tips_UIBP.SurpriseAirdrop_Critical_Hit_Tips_UIBP",
    isMainUI = false,
    asy = true,
    loadFromPool = EUIConfigPoolType.None,
    uiStat = {
      name = "SurpriseAirdrop_Critical_Hit_Tips"
    },
    containerName = UIContainers.Top
  },
  TFVehicleControlUI = {
    moduleName = "GameLua.Mod.PlanTF.Client.UI.VehicleControl.TFVehicleControlUI",
    path = "/Game/Library/Res/Vehicles/TFMecha/BluePrints/UI/TFVehicleControlUI.TFVehicleControlUI",
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    uiStat = {
      name = "TFVehicleControlUI"
    },
    AndroidBackType = EAndroidBackType.Ban
  },
  TFVehicleHealthUI = {
    moduleName = "GameLua.Mod.PlanTF.Client.UI.VehicleControl.TFVehicleHealthUI",
    path = "/Game/Library/Res/Vehicles/TFMecha/BluePrints/UI/Optimus/Optimus_Health_Bar_UIBP.Optimus_Health_Bar_UIBP",
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    uiStat = {
      name = "TFVehicleHealthUI"
    },
    AndroidBackType = EAndroidBackType.Ban
  },
  VehicleControlUITrack = {
    moduleName = "GameLua.Mod.TPlan.Client.InGameUI.VehicleControl.ControlUI.VehicleControlUITrack",
    path = "/Game/BluePrints/ControlInput/IngameUI/Vehicle/ControlUI/VehicleControlUITrack.VehicleControlUITrack",
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    uiStat = {
      name = "VehicleControlUITrack"
    },
    AndroidBackType = EAndroidBackType.Ban
  },
  VehicleControlUIUCAV = {
    moduleName = "GameLua.Mod.Library.Client.UI.VehicleControl.ControlUI.VehicleControlUIUCAV",
    path = "/Game/Library/Res/Weapons/UCAV/BluePrints/UI/AttackUI/AttackUI_UIBP.AttackUI_UIBP",
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    uiStat = {
      name = "VehicleControlUIUCAV"
    },
    AndroidBackType = EAndroidBackType.Ban
  },
  VehicleTheatreUI = {
    moduleName = "GameLua.ExtraModule.Baby.Client.UI.VehicleTheatreUI",
    path = "/Game/Mod/Baby/BluePrints/Baby_Clock_UIBP.Baby_Clock_UIBP",
    isSingleton = true,
    uiStat = {
      name = "VehicleTheatreUI"
    },
    isMainUI = false,
    loadFromPool = EUIConfigPoolType.None,
    containerName = UIContainers.Top
  },
  ModWeaponLabelUI = {
    moduleName = "GameLua.Mod.Library.GamePlay.Weapon.UI.ModWeaponLabelUI",
    path = "/Game/Mod/EvoBase/BluePrints/UI/Weapon/ModWeaponLabel.ModWeaponLabel",
    fullScreen = false,
    uiStat = {
      name = "ModWeaponLabelUI"
    },
    containerName = UIContainers.Default,
    isSingleton = false,
    asy = true
  },
  SurprisePickUpItem = {
    moduleName = "GameLua.Mod.Library.Client.SurpriseAirDrop.SurprisePickUpItem",
    path = "/Game/Mod/VersionRes/390/SurpriseAirdrop/BluePrints/UI/Item/SurpriseAirdrop_Pickup_Information_Item_UIBP.SurpriseAirdrop_Pickup_Information_Item_UIBP",
    uiStat = {
      name = "SurprisePickUpItem"
    },
    isSingleton = false,
    isMainUI = false,
    closeOnHide = false,
    zOrder = 1
  },
  TeammateReviveStateIcon = {
    moduleName = "GameLua.Mod.Library.Revive1800.GamePlay.UI.TeammateReviveStateIcon",
    path = "/Game/Mod/EvoBase/BluePrints/UI/ReviveTowerUI/ReviveTeam_SignalTower_Item.ReviveTeam_SignalTower_Item",
    uiStat = {
      name = "TeammateReviveStateIcon"
    },
    containerName = UIContainers.Default,
    isSingleton = false,
    AndroidBackType = EAndroidBackType.Ban
  },
  MusicUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.MusicUI",
    path = "/Game/Mod/EvoBase/BluePrints/UI/MusicUI_UIBP.MusicUI_UIBP",
    uiStat = {name = "MusicUI"},
    closeOnHide = true,
    isSingleton = true,
    isMainUI = false,
    asy = true
  },
  SpecialMoveEnergyUI = {
    moduleName = "GameLua.Mod.Library.Client.UI.SpecialMove.SpecialMoveEnergyUI",
    path = "/Game/Library/Res/Hero/HeroSP/Blueprints/UI/SpecialMoveEnergyUI_UIBP.SpecialMoveEnergyUI_UIBP",
    uiStat = {
      name = "SpecialMoveEnergyUI"
    },
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    closeOnHide = false
  }
}
return UIConfig_OtherConfig