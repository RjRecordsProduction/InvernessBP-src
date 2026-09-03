local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local EUIConfigPoolType = require("client.slua.config.ClientMacros.EUIConfigPoolType")
local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local UIConfig_Shooting = {
  BattleGunHitInfoRealTime = {
    moduleName = "GameLua.Mod.BaseMod.Client.BattleGunHitInfoRealtimeUI",
    path = "/Game/BluePrints/ControlInput/IngameUI/GunHitInfoRealTime_UIBP.GunHitInfoRealTime_UIBP",
    uiStat = {
      name = "BattleGunHitInfoRealTime"
    },
    closeOnHide = false
  },
  ChangeSightUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.MainControlUI.ChangeSightUI",
    path = "/Game/BluePrints/ControlInput/IngameUI/ChangeSight_UIBP.ChangeSight_UIBP",
    isSingleton = true,
    isMainUI = false,
    closeOnHide = false,
    uiStat = {
      name = "HistoricalNewsUIForReplay"
    },
    zOrder = 0,
    showVisibility = UIContainers.ShowVisibilityAction.DontCare
  },
  CoopVaultBtn = {
    moduleName = "GameLua.Mod.BaseMod.Client.ShootingUI.CoopVaultBtn",
    path = "/Game/BluePrints/ControlInput/CoopVault_BP.CoopVault_BP",
    uiState = {
      name = "CoopVaultBtn"
    },
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    isWindowsOBHide = true,
    isSingleton = true,
    zOrder = 0,
    asy = true
  },
  CooperationVaultLeftUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.Vault.CooperationVaultLeftUI",
    path = "/Game/Library/Res/SkillsCommon/UICommon/BluePrints/UI/SkillButton/CommonSkillAttackBtn.CommonSkillAttackBtn",
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    AndroidBackType = EAndroidBackType.Ban
  },
  CooperationVaultRightUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.Vault.CooperationVaultRightUI",
    path = "/Game/Library/Res/SkillsCommon/UICommon/BluePrints/UI/SkillButton/CommonSkillAttackBtn.CommonSkillAttackBtn",
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    AndroidBackType = EAndroidBackType.Ban
  },
  CrouchUIBP = {
    moduleName = "GameLua.Mod.BaseMod.Client.ShootingUI.CrouchUIBP",
    path = "/Game/BluePrints/ControlInput/Crouch_UIBP.Crouch_UIBP",
    uiStat = {name = "CrouchUIBP"},
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    isWindowsOBHide = true,
    isSingleton = true,
    zOrder = 0
  },
  DamageNumMainUI = {
    moduleName = "GameLua.Mod.Library.Client.UI.DamageNumMainUI",
    path = "/Game/Mod/EvoBase/BluePrints/UIBP/DamageNumMainUI.DamageNumMainUI",
    uiStat = {
      name = "DamageNumMainUI"
    },
    closeOnHide = false,
    AndroidBackType = EAndroidBackType.Ban,
    asy = true
  },
  DamageRecordUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.DeathStat.DamageRecordUI",
    path = "/Game/Mod/EvoBase/BluePrints/UI/DeathStat/DamageRecordUI.DamageRecordUI",
    uiStat = {
      name = "DamageRecordUI"
    },
    closeOnHide = false,
    isMainUI = false,
    isSingleton = true,
    loadFromPool = EUIConfigPoolType.None
  },
  FingerScopeZoomUI = {
    moduleName = "GameLua.Mod.BaseMod.GamePlay.Weapon.Attachment.FingerScopeZoomUI",
    path = "/Game/Library/Res/Weapons/FingerScope/UI/April_UIBP.April_UIBP",
    isSingleton = true,
    uiStat = {
      name = "FingerScopeZoomUI"
    },
    isMainUI = false,
    loadFromPool = EUIConfigPoolType.None
  },
  JumpVaultBtn = {
    moduleName = "GameLua.Mod.BaseMod.Client.ShootingUI.JumpVaultBtn",
    path = "/Game/BluePrints/ControlInput/JumpVault_BP.JumpVault_BP",
    uiStat = {
      name = "JumpVaultBtn"
    },
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    isWindowsOBHide = true,
    isSingleton = true,
    zOrder = 0,
    asy = true
  },
  LeanUIBP = {
    moduleName = "GameLua.Mod.BaseMod.Client.ShootingUI.LeanUIBP",
    path = "/Game/BluePrints/ControlInput/LeanButtons_BP.LeanButtons_BP",
    uiStat = {name = "LeanUIBP"},
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    isWindowsOBHide = true,
    isSingleton = true,
    zOrder = 0
  },
  MagneticGunCrossHairUI = {
    moduleName = "GameLua.Mod.Library.Client.UI.MagneticGunCrossHairUI",
    path = "/Game/Library/Res/Vehicles/Mecha/BluePrints/UI/Item/Mecha_Collimation_Item02.Mecha_Collimation_Item02",
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    uiStat = {
      name = "MagneticGunCrossHairUI"
    },
    AndroidBackType = EAndroidBackType.Ban
  },
  MagneticGunInteractUI = {
    moduleName = "GameLua.Mod.Library.Client.UI.MagneticGunInteractUI",
    path = "/Game/BluePrints/ControlInput/IngameCDBarUI/UltraHandSkillUI_BP.UltraHandSkillUI_BP",
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    uiStat = {
      name = "MagneticGunInteractUI"
    },
    AndroidBackType = EAndroidBackType.Ban
  },
  MagneticGunLeftUI = {
    moduleName = "GameLua.Mod.Library.Client.UI.MagneticGunLeftUI",
    path = "/Game/Library/Res/Vehicles/Mecha/BluePrints/UI/MagneticGunUI.MagneticGunUI",
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    uiStat = {
      name = "MagneticGunLeftUI"
    },
    AndroidBackType = EAndroidBackType.Ban
  },
  MagneticGunRightUI = {
    moduleName = "GameLua.Mod.Library.Client.UI.MagneticGunRightUI",
    path = "/Game/Library/Res/Vehicles/Mecha/BluePrints/UI/MagneticGunUI.MagneticGunUI",
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    uiStat = {
      name = "MagneticGunRightUI"
    },
    AndroidBackType = EAndroidBackType.Ban
  },
  MortarAimUI = {
    moduleName = "GameLua.Mod.Library.Client.UI.Mortar.MortarAimUI",
    path = "/Game/BluePrints/ControlInput/MortarUI/MortarAimBtn.MortarAimBtn",
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    uiStat = {
      name = "MortarAimUI"
    },
    AndroidBackType = EAndroidBackType.Ban,
    showVisibility = UEnums.ESlateVisibility.Collapsed
  },
  MortarFireLeftUI = {
    moduleName = "GameLua.Mod.Library.Client.UI.Mortar.MortarFireLeftUI",
    path = "/Game/Library/Res/SkillsCommon/UICommon/BluePrints/UI/SkillButton/CommonSkillAttackBtn.CommonSkillAttackBtn",
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    uiStat = {
      name = "MortarFireLeftUI"
    },
    AndroidBackType = EAndroidBackType.Ban
  },
  MortarFireRightUI = {
    moduleName = "GameLua.Mod.Library.Client.UI.Mortar.MortarFireRightUI",
    path = "/Game/Library/Res/SkillsCommon/UICommon/BluePrints/UI/SkillButton/CommonSkillAttackBtn.CommonSkillAttackBtn",
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    uiStat = {
      name = "MortarFireRightUI"
    },
    AndroidBackType = EAndroidBackType.Ban
  },
  MortarPackUpUI = {
    moduleName = "GameLua.Mod.Library.Client.UI.Mortar.MortarPackUpUI",
    path = "/Game/BluePrints/ControlInput/MortarUI/MortarPackUpUI_BP.MortarPackUpUI_BP",
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    uiStat = {
      name = "MortarPackUpUI"
    },
    AndroidBackType = EAndroidBackType.Ban,
    showVisibility = UEnums.ESlateVisibility.Collapsed
  },
  MultiLayer_PMode_UIBP = {
    moduleName = "GameLua.Mod.BaseMod.Client.ShootingUI.MultiLayerPModePanel",
    path = "/Game/BluePrints/ControlInput/ShootingUIPanel_MultiLayer_PMode.ShootingUIPanel_MultiLayer_PMode",
    uiStat = {
      name = "MultiLayer_PMode_UIBP"
    },
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    isWindowsOBHide = true,
    isSingleton = true,
    zOrder = 0
  },
  PistolMode = {
    moduleName = "GameLua.Mod.BaseMod.Client.MainControlUI.PistolSlotModeBase",
    path = "/Game/BluePrints/ControlInput/PistolMode.PistolMode",
    uiStat = {name = "PistolMode"},
    isMainUI = false,
    isSingleton = true,
    containerName = UIContainers.Default,
    AndroidBackType = EAndroidBackType.Ban,
    closeOnHide = false,
    closeOnSwitch = false
  },
  PistolWeldUI = {
    moduleName = "GameLua.Mod.BaseMod.GamePlay.Weapon.MainWeapon.PistolWeldUI",
    path = "/Game/BluePrints/ControlInput/WeldingGun/WeldingGun_HealthBar_UIBP.WeldingGun_HealthBar_UIBP",
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    AndroidBackType = EAndroidBackType.Ban
  },
  ProneUIBP = {
    moduleName = "GameLua.Mod.BaseMod.Client.ShootingUI.ProneUIBP",
    path = "/Game/BluePrints/ControlInput/Prone_UIBP.Prone_UIBP",
    uiStat = {name = "ProneUIBP"},
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    isWindowsOBHide = true,
    isSingleton = true,
    zOrder = 0
  },
  ScopeZoomUIBP = {
    moduleName = "GameLua.Mod.BaseMod.Client.ShootingUI.ScopeZoomUIBP",
    path = "/Game/BluePrints/ControlInput/ScopeZoom_UIBP.ScopeZoom_UIBP",
    uiStat = {
      name = "ScopeZoomUIBP"
    },
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    isWindowsOBHide = true,
    isSingleton = true,
    zOrder = 0
  },
  ShootAimBtnUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.ShootingUI.ShootAimBtnUI",
    path = "/Game/BluePrints/ControlInput/ShootAimBtn_UIBP.ShootAimBtn_UIBP",
    uiStat = {
      name = "ShootAimBtnUI"
    },
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    isWindowsOBHide = true,
    isSingleton = true,
    zOrder = 0
  },
  ReloadUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.ShootingUI.ReloadUI",
    path = "/Game/BluePrints/ControlInput/BulletReload.BulletReload",
    uiStat = {name = "ReloadUI"},
    showVisibility = UEnums.ESlateVisibility.Collapsed,
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    isWindowsOBHide = true,
    isSingleton = true,
    zOrder = 0
  },
  SwitchThrowUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.ShootingUI.SwitchThrowUI",
    path = "/Game/BluePrints/ControlInput/SwitchThrow.SwitchThrow",
    uiStat = {
      name = "SwitchThrowUI"
    },
    showVisibility = UEnums.ESlateVisibility.Collapsed,
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    isWindowsOBHide = true,
    isSingleton = true,
    zOrder = 0
  },
  ShoulderBtnInfo = {
    moduleName = "GameLua.Mod.BaseMod.Client.Button.ShoulderBtnInfo",
    path = "/Game/BluePrints/ControlInput/IngameUI/ShoulderBtn_UIBP.ShoulderBtn_UIBP",
    isMainUI = false,
    isWindowsOBHide = true,
    zOrder = 0,
    mountPanel = {
      mountOuterName = "ShootingUIPanel",
      mountName = "ShoulderBtnSocket"
    },
    uiStat = {
      name = "ShoulderBtnInfo"
    },
    autoCreate = true
  },
  RedSightUIBP = {
    moduleName = "GameLua.Mod.BaseMod.Client.ShootingUI.RedSightUIBP",
    path = "/Game/BluePrints/ControlInput/IngameUI/RedSight_UIBP.RedSight_UIBP",
    uiStat = {
      name = "RedSightUIBP"
    },
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    isWindowsOBHide = true,
    isSingleton = true,
    zOrder = 0
  },
  SniperDSRBakMagUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.SniperDSRBakMagUI",
    path = "/Game/BluePrints/ControlInput/SniperDSRBakMagUI.SniperDSRBakMagUI",
    isSingleton = false,
    uiStat = {
      name = "SniperDSRBakMagUI"
    },
    zOrder = 0,
    asy = true,
    containerName = UIContainers.Default,
    closeOnHide = false,
    AndroidBackType = EAndroidBackType.Ban
  },
  SwitchWeaponSlot = {
    moduleName = "GameLua.Mod.BaseMod.Client.MainControlUI.SwitchWeaponSlotModeBase",
    path = "/Game/BluePrints/ControlInput/SwitchWeaponSlot_Mode2.SwitchWeaponSlot_Mode2",
    uiStat = {
      name = "SwitchWeaponSlot"
    },
    isMainUI = false,
    containerName = UIContainers.Default,
    AndroidBackType = EAndroidBackType.Ban,
    closeOnHide = false,
    isSingleton = false,
    closeOnSwitch = false
  },
  MSSwitchUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.ShootingUI.MSSwitchUI",
    path = "/Game/BluePrints/ControlInput/MSSwitchPanel.MSSwitchPanel",
    uiStat = {name = "MSSwitchUI"},
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    isWindowsOBHide = true,
    isSingleton = true,
    zOrder = 0
  },
  AttackThrowSwitchBtn = {
    moduleName = "GameLua.Mod.BaseMod.Client.ShootingUI.AttackThrowSwitchBtn",
    path = "/Game/BluePrints/ControlInput/ThrowPlus.ThrowPlus",
    uiStat = {
      name = "AttackThrowSwitchBtn"
    },
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    isWindowsOBHide = true,
    isSingleton = true,
    zOrder = 0
  },
  CancelThrowBtn = {
    moduleName = "GameLua.Mod.BaseMod.Client.ShootingUI.CancelThrowBtn",
    path = "/Game/BluePrints/ControlInput/CancelThrowBtn.CancelThrowBtn",
    uiStat = {
      name = "CancelThrowBtn"
    },
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    isWindowsOBHide = true,
    isSingleton = true,
    zOrder = 0
  },
  ShootingUI_AutoSprintBtn = {
    moduleName = "GameLua.Mod.BaseMod.Client.ShootingUI.ShootingUI_AutoSprintBtn",
    path = "/Game/BluePrints/ControlInput/ShootingUI_AutoSprint.ShootingUI_AutoSprint",
    uiStat = {
      name = "ShootingUI_AutoSprintBtn"
    },
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    isWindowsOBHide = true,
    isSingleton = true,
    zOrder = 0
  },
  BowCrossHairUI = {
    moduleName = "GameLua.Mod.Library.Client.UI.Weapon.BowCrossHairUI",
    path = "/Game/Mod/EvoBase/BluePrints/UI/Collimation/Collimation_BowArrow_UIBP.Collimation_BowArrow_UIBP",
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    uiStat = {
      name = "BowCrossHairUI"
    },
    AndroidBackType = EAndroidBackType.Ban
  },
  KatanaWeaponUI = {
    moduleName = "GameLua.Mod.Library.Client.UI.Weapon.CustomWeaponUIBase",
    path = "/Game/Library/Res/Weapons/Katana/BluePrints/UI/KatanaBlock_UIBP.KatanaBlock_UIBP",
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    uiStat = {
      name = "KatanaWeaponUI"
    },
    AndroidBackType = EAndroidBackType.Ban
  },
  PanzerFaustScopeUI = {
    moduleName = "GameLua.Mod.Library.Client.UI.Weapon.CustomWeaponUIBase",
    path = "/Game/Mod/EvoBase/BluePrints/UI/Weapon/PanzerFaustScope_UIBP.PanzerFaustScope_UIBP",
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    uiStat = {
      name = "PanzerFaustScopeUI"
    },
    AndroidBackType = EAndroidBackType.Ban
  }
}
return UIConfig_Shooting