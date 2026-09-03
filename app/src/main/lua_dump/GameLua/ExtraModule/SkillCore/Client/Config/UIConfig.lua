local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local EUIConfigPoolType = require("client.slua.config.ClientMacros.EUIConfigPoolType")
local Config = {
  UIConfig = {
    ODMGearControlUI = {
      moduleName = "GameLua.ExtraModule.SkillCore.Client.ODMGear.ODMGearControlUI",
      path = "/Game/Library/Res/Skills/GasHook/BluePrints/UI/GasHook_ControlUI.GasHook_ControlUI",
      uiStat = {
        name = "ODMGearControlUI"
      },
      zOrder = 0,
      closeOnHide = false,
      isMainUI = false,
      asy = true,
      isSingleton = true,
      mountPanel = {
        mountOuterName = "ShootingUIPanel",
        mountName = "CustomSkillLayer"
      }
    },
    ODMGearWeaponCrossHairUI = {
      moduleName = "GameLua.ExtraModule.SkillCore.Client.ODMGear.ODMGearWeaponCrossHairUI",
      path = "/Game/Library/Res/Skills/GasHook/BluePrints/UI/GasHook_Collimation_Item_UIBP.GasHook_Collimation_Item_UIBP",
      uiStat = {
        name = "ODMGearWeaponCrossHairUI"
      },
      zOrder = 0,
      closeOnHide = false,
      isMainUI = false,
      asy = true,
      isSingleton = true,
      AndroidBackType = EAndroidBackType.Ban
    },
    GhostBalloonControlUI = {
      moduleName = "GameLua.ExtraModule.SkillCore.Client.GhostBalloon.GhostBalloonControlUI",
      path = "/Game/Library/Res/Skills/GhostBalloon/BluePrints/UI/GhostBalloon_ControlUI.GhostBalloon_ControlUI",
      uiStat = {
        name = "GhostBalloonControlUI"
      },
      zOrder = 0,
      closeOnHide = false,
      isMainUI = false,
      asy = true,
      isSingleton = true,
      mountPanel = {
        mountOuterName = "ShootingUIPanel",
        mountName = "CustomSkillLayer"
      }
    },
    GhostShieldControlUI = {
      moduleName = "GameLua.ExtraModule.SkillCore.Client.GhostShield.GhostShieldControlUI",
      path = "/Game/Library/Res/Skills/GhostShield/Blueprint/UI/SkillCore_Shield_Progress_UIBP.SkillCore_Shield_Progress_UIBP",
      uiStat = {
        name = "GhostBalloonControlUI"
      },
      zOrder = 0,
      closeOnHide = false,
      isMainUI = false,
      asy = true,
      isSingleton = true,
      mountPanel = {
        mountOuterName = "ShootingUIPanel",
        mountName = "CustomSkillLayer"
      }
    },
    GhostShieldCancelButtonUI = {
      moduleName = "GameLua.ExtraModule.SkillCore.Client.GhostShield.GhostShieldCancelUI",
      path = "/Game/BluePrints/ControlInput/SkillUI/SkillCancelButton_BP.SkillCancelButton_BP",
      BindCancelSkill = 4000002,
      isMainUI = false,
      isSingleton = true,
      zOrder = 0,
      asy = true,
      closeOnHide = false,
      uiStat = {
        name = "CancelButtonUI"
      },
      mountPanel = {
        mountOuterName = "ShootingUIPanel",
        mountName = "CustomSkillLayer"
      }
    },
    ShieldBallRightUI = {
      moduleName = "GameLua.ExtraModule.SkillCore.Client.GhostShield.GhostShieldReleaseUI",
      path = "/Game/Library/Res/SkillsCommon/UICommon/BluePrints/UI/SkillButton/CommonSkillAttackBtn.CommonSkillAttackBtn",
      isMainUI = false,
      isSingleton = true,
      zOrder = 0,
      asy = true
    },
    ShieldBallLeftUI = {
      moduleName = "GameLua.ExtraModule.SkillCore.Client.GhostShield.GhostShieldReleaseLeftUI",
      path = "/Game/Library/Res/SkillsCommon/UICommon/BluePrints/UI/SkillButton/CommonSkillAttackBtn.CommonSkillAttackBtn",
      isMainUI = false,
      isSingleton = true,
      zOrder = 0,
      asy = true
    },
    FlowerWingControlUI = {
      moduleName = "GameLua.ExtraModule.SkillCore.Client.FlowerWing.FlowerWingControlUI",
      path = "/Game/Library/Res/Skills/FlowerWing/BluePrints/UI/FlowerWing_ControlUI.FlowerWing_ControlUI",
      uiStat = {
        name = "FlowerWingControlUI"
      },
      zOrder = 0,
      closeOnHide = false,
      isMainUI = false,
      asy = true,
      isSingleton = true,
      mountPanel = {
        mountOuterName = "ShootingUIPanel",
        mountName = "CustomSkillLayer"
      }
    },
    FlyingWingControlUI = {
      moduleName = "GameLua.ExtraModule.SkillCore.Client.FlyingWing.FlyingWingControlUI",
      path = "/Game/Library/Res/Skills/FlyingWing/BluePrints/UI/FlyingWing_ControlUI.FlyingWing_ControlUI",
      uiStat = {
        name = "FlyingWingControlUI"
      },
      zOrder = 0,
      closeOnHide = false,
      isMainUI = false,
      asy = true,
      isSingleton = true,
      mountPanel = {
        mountOuterName = "ShootingUIPanel",
        mountName = "CustomSkillLayer"
      }
    },
    VineShackleUI = {
      moduleName = "GameLua.ExtraModule.SkillCore.Client.VineHook.VineShackleUI",
      path = "/Game/Library/Res/Skills/VineHook/BluePrints/UI/VineShackle_UI.VineShackle_UI",
      uiStat = {
        name = "VineShackleUI"
      },
      zOrder = 0,
      closeOnHide = false,
      isMainUI = false,
      asy = true,
      isSingleton = true,
      mountPanel = {
        mountOuterName = "ShootingUIPanel",
        mountName = "CustomSkillLayer"
      }
    },
    VineControlCancelButtonUI = {
      moduleName = "GameLua.ExtraModule.SkillCore.Client.UI.Common.CommonSkillCancelUI",
      path = "/Game/BluePrints/ControlInput/SkillUI/SkillCancelButton_BP.SkillCancelButton_BP",
      BindCancelSkill = 4202006,
      isMainUI = false,
      isSingleton = true,
      zOrder = 0,
      asy = true,
      closeOnHide = false,
      uiStat = {
        name = "CancelButtonUI"
      },
      mountPanel = {
        mountOuterName = "ShootingUIPanel",
        mountName = "CustomSkillLayer"
      }
    },
    VineHookWeaponLeftUI = {
      moduleName = "GameLua.ExtraModule.SkillCore.Client.VineHook.VineAttackLeftUI",
      path = "/Game/Library/Res/Skills/VineHook/BluePrints/UI/VineHookWeaponUI.VineHookWeaponUI",
      isMainUI = false,
      isSingleton = true,
      zOrder = 0,
      asy = true,
      closeOnHide = false,
      uiStat = {
        name = "VineHookWeaponLeftUI"
      }
    },
    VineHookWeaponRightUI = {
      moduleName = "GameLua.ExtraModule.SkillCore.Client.VineHook.VineAttackRightUI",
      path = "/Game/Library/Res/Skills/VineHook/BluePrints/UI/VineHookWeaponUI.VineHookWeaponUI",
      isMainUI = false,
      isSingleton = true,
      zOrder = 0,
      asy = true,
      closeOnHide = false,
      uiStat = {
        name = "VineHookWeaponRightUI"
      }
    },
    VineControlThemePropsCancelWidgetUI = {
      moduleName = "GameLua.ExtraModule.SkillCore.Client.VineHook.VineControlThemePropsCancelUI",
      path = "/Game/BluePrints/ControlInput/CircleChooseWidget/ThemePropsUI_UIBP.ThemePropsUI_UIBP",
      uiStat = {
        name = "VineControlThemePropsCancelWidgetUI"
      },
      containerName = UIContainers.Default,
      closeOnHide = false,
      isSingleton = true,
      isMainUI = false,
      AndroidBackType = EAndroidBackType.Skip,
      mountPanel = {
        mountOuterName = "ShootingUIPanel",
        mountName = "CustomSkillLayer"
      }
    },
    TacticalBoosterControlUI = {
      moduleName = "GameLua.ExtraModule.SkillCore.Client.TacticalBooster.TacticalBoosterControlUI",
      path = "/Game/Library/Res/Skills/TacticalBooster/BluePrints/UI/TacticalBoosterControlUI.TacticalBoosterControlUI",
      isMainUI = false,
      isSingleton = true,
      zOrder = 0,
      asy = true,
      closeOnHide = false,
      uiStat = {
        name = "TacticalBoosterControlUI"
      }
    },
    BattleFlagHPArmorUI = {
      moduleName = "GameLua.ExtraModule.SkillCore.Client.BattleFlag.BattleFlagHPArmorUI",
      path = "/Game/Library/Res/Skills/BattleFlag/BluePrints/UI/BattleFlag_HP_ArmorUI.BattleFlag_HP_ArmorUI",
      uiStat = {
        name = "BattleFlagHPArmorUI"
      },
      zOrder = 0,
      closeOnHide = false,
      isMainUI = false,
      asy = true,
      isSingleton = true
    },
    BattleFlagOBArmorUI = {
      moduleName = "GameLua.ExtraModule.SkillCore.Client.BattleFlag.BattleFlagOBArmorUI",
      path = "/Game/Library/Res/Skills/BattleFlag/BluePrints/UI/BattleFlag_HP_ArmorUI.BattleFlag_HP_ArmorUI",
      uiStat = {
        name = "BattleFlagOBArmorUI"
      },
      zOrder = 0,
      closeOnHide = false,
      isMainUI = false,
      asy = true,
      isSingleton = true
    },
    BattleFlagTeamArmorUI = {
      moduleName = "GameLua.ExtraModule.SkillCore.Client.BattleFlag.BattleFlagTeamArmorUI",
      path = "/Game/Library/Res/Skills/BattleFlag/BluePrints/UI/BattleFlag_Team_ArmorUI.BattleFlag_Team_ArmorUI",
      fullScreen = false,
      uiStat = {
        name = "BattleFlagTeamArmorUI"
      },
      containerName = UIContainers.Default,
      closeOnHide = false,
      isSingleton = false,
      asy = true
    },
    BattleFlagScreenArmorUI = {
      moduleName = "GameLua.ExtraModule.SkillCore.Client.BattleFlag.BattleFlagScreenArmorUI",
      path = "/Game/Library/Res/Skills/BattleFlag/BluePrints/UI/BattleFlag_Screen_ArmorUI.BattleFlag_Screen_ArmorUI",
      uiStat = {
        name = "BattleFlagScreenArmorUI"
      },
      zOrder = 0,
      closeOnHide = false,
      isMainUI = false,
      asy = true,
      isSingleton = true
    },
    BattleFlagEnergyLFireUI = {
      moduleName = "GameLua.ExtraModule.SkillCore.Client.BattleFlag.BattleFlagEnergyLFireUI",
      path = "/Game/Library/Res/Skills/BattleFlag/BluePrints/UI/BattleFlag_EnergyUI.BattleFlag_EnergyUI",
      uiStat = {
        name = "BattleFlagEnergyLFireUI"
      },
      zOrder = 0,
      closeOnHide = false,
      isMainUI = false,
      asy = true,
      isSingleton = true
    },
    BattleFlagEnergyRFireUI = {
      moduleName = "GameLua.ExtraModule.SkillCore.Client.BattleFlag.BattleFlagEnergyRFireUI",
      path = "/Game/Library/Res/Skills/BattleFlag/BluePrints/UI/BattleFlag_EnergyUI.BattleFlag_EnergyUI",
      uiStat = {
        name = "BattleFlagEnergyRFireUI"
      },
      zOrder = 0,
      closeOnHide = false,
      isMainUI = false,
      asy = true,
      isSingleton = true
    },
    FootballOperateUI = {
      moduleName = "GameLua.ExtraModule.SkillCore.Client.Football.FootballOperateUI",
      path = "/Game/Library/Res/Skills/Football/BluePrints/UI/FootballOperateUI_UIBP.FootballOperateUI_UIBP",
      uiStat = {
        name = "IngameTeamItem_New"
      },
      zOrder = 0,
      closeOnHide = false,
      loadFromPool = EUIConfigPoolType.None,
      isMainUI = false,
      asy = true
    }
  },
  OldUIConfig = {
    Default = DefaultInGameWidget,
    ModAdd = {}
  },
  OtherSetting = {}
}
return Config