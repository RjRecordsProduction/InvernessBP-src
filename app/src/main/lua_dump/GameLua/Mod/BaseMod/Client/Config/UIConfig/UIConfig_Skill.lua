local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local EUIConfigPoolType = require("client.slua.config.ClientMacros.EUIConfigPoolType")
local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local UIConfig_Skill = {
  BasicSkillsMenuBP = {
    moduleName = "GameLua.Mod.BaseMod.Client.Skill.BasicSkillsMenuBP_Main",
    path = "/Game/BluePrints/ControlInput/IngameUI/BasicSkillsMenu_BP.BasicSkillsMenu_BP",
    isMainUI = false,
    isWindowsOBHide = true,
    zOrder = 0,
    uiStat = {
      name = "BasicSkillsMenuBP"
    }
  },
  DefaultQTEUI = {
    moduleName = "GameLua.Mod.Library.Client.UI.DefaultQTEUI",
    path = "/Game/BluePrints/ControlInput/IngameCDBarUI/DefaultQTEUI_BP.DefaultQTEUI_BP",
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    AndroidBackType = EAndroidBackType.Ban
  },
  SkillCancelButton = {
    moduleName = "GameLua.Mod.BaseMod.Client.SkillPanel.SkillCancelButton",
    path = "/Game/BluePrints/ControlInput/SkillUI/SkillCancelButton_BP.SkillCancelButton_BP",
    uiStat = {
      name = "SkillCancelButton"
    },
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    isWindowsOBHide = true,
    isSingleton = true,
    zOrder = 30,
    autoCreate = true,
    mountPanel = {
      mountOuterName = "ShootingUIPanel",
      mountName = "SkillLayer"
    }
  },
  SkillDynahexButton = {
    moduleName = "GameLua.Mod.BaseMod.Client.SkillPanel.SkillDynahexButton",
    path = "/Game/BluePrints/ControlInput/SkillUI/SkillDynahexButton_BP.SkillDynahexButton_BP",
    uiStat = {
      name = "SkillDynahexButton"
    },
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    isWindowsOBHide = true,
    isSingleton = true,
    zOrder = 30,
    mountPanel = {
      mountOuterName = "ShootingUIPanel",
      mountName = "SkillLayer"
    }
  },
  SkillHangGliderButtonSlot = {
    moduleName = "GameLua.Mod.BaseMod.Client.SkillPanel.SkillHangGliderButtonSlot",
    path = "/Game/BluePrints/ControlInput/SkillUI/SkillHangGliderButtonSlot_BP.SkillHangGliderButtonSlot_BP",
    uiStat = {
      name = "SkillHangGliderButtonSlot"
    },
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    isWindowsOBHide = true,
    isSingleton = true,
    zOrder = 30,
    autoCreate = true,
    mountPanel = {
      mountOuterName = "ShootingUIPanel",
      mountName = "SkillLayer"
    }
  },
  SkillModButtonSlot = {
    moduleName = "GameLua.Mod.BaseMod.Client.SkillPanel.SkillModButtonSlot",
    path = "/Game/BluePrints/ControlInput/SkillUI/SkillModButtonSlot_BP.SkillModButtonSlot_BP",
    uiStat = {
      name = "SkillModButtonSlot"
    },
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    isWindowsOBHide = true,
    isSingleton = true,
    zOrder = 30,
    autoCreate = true,
    mountPanel = {
      mountOuterName = "ShootingUIPanel",
      mountName = "SkillLayer"
    }
  },
  SkillShieldButtonSlot = {
    moduleName = "GameLua.Mod.BaseMod.Client.SkillPanel.SkillShieldButtonSlot",
    path = "/Game/BluePrints/ControlInput/SkillUI/SkillShieldButtonSlot_BP.SkillShieldButtonSlot_BP",
    uiStat = {
      name = "SkillShieldButtonSlot"
    },
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    isWindowsOBHide = true,
    isSingleton = true,
    zOrder = 30,
    autoCreate = true,
    mountPanel = {
      mountOuterName = "ShootingUIPanel",
      mountName = "SkillLayer"
    }
  },
  SkillShootingWeaponMeleeButtonSlot = {
    moduleName = "GameLua.Mod.BaseMod.Client.SkillPanel.SkillShootingWeaponMeleeButtonSlot",
    path = "/Game/BluePrints/ControlInput/SkillUI/SkillShootingWeaponMeleeButtonSlot_BP.SkillShootingWeaponMeleeButtonSlot_BP",
    uiStat = {
      name = "SkillShootingWeaponMeleeButtonSlot"
    },
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    isWindowsOBHide = true,
    isSingleton = true,
    zOrder = 30,
    autoCreate = true,
    mountPanel = {
      mountOuterName = "ShootingUIPanel",
      mountName = "SkillLayer"
    }
  },
  SkillBuildMVPButtonSlot = {
    moduleName = "GameLua.Mod.BaseMod.Client.SkillPanel.SkillBuildMVPButtonSlot",
    path = "/Game/BluePrints/ControlInput/SkillUI/SkillBuildMVPButtonSlot_BP.SkillBuildMVPButtonSlot_BP",
    uiStat = {
      name = "SkillBuildMVPButtonSlot"
    },
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    isWindowsOBHide = true,
    isSingleton = true,
    zOrder = 30,
    autoCreate = true,
    mountPanel = {
      mountOuterName = "ShootingUIPanel",
      mountName = "SkillLayer"
    }
  }
}
return UIConfig_Skill