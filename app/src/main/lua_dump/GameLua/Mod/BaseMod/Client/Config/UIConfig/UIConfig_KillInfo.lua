local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local EUIConfigPoolType = require("client.slua.config.ClientMacros.EUIConfigPoolType")
local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local UIConfig_KillInfo = {
  DeathStatUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.DeathStat.DeathStatUI",
    path = "/Game/Mod/EvoBase/BluePrints/UI/DeathStat/DeathStatUI.DeathStatUI",
    uiStat = {
      name = "DeathStatUI"
    },
    closeOnHide = false,
    isMainUI = false,
    isSingleton = true,
    loadFromPool = EUIConfigPoolType.None
  },
  IngameKillIconUIBP = {
    moduleName = "GameLua.Mod.BaseMod.Client.Like.IngameKillIconUIBP",
    path = "/Game/BluePrints/ControlInput/IngameUI/Like/Ingame_KillIcon_UIBP.Ingame_KillIcon_UIBP",
    containerName = UIContainers.Default,
    zOrder = 1,
    uiStat = {
      name = "IngameKillIconUIBP"
    },
    isMainUI = false
  },
  MainKillCounter = {
    moduleName = "GameLua.Mod.BaseMod.Client.KillCounter.MainKillCounter",
    path = "/Game/BluePrints/ControlInput/MainKillCounter.MainKillCounter",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "MainKillCounter"
    },
    zOrder = 0
  },
  MainWeaponKillCounter = {
    moduleName = "GameLua.Mod.BaseMod.Client.KillCounter.MainWeaponKillCounter",
    path = "/Game/BluePrints/ControlInput/MainBackPackUI/Item/MainWeaponKillCounter.MainWeaponKillCounter",
    isMainUI = false,
    isSingleton = false,
    asy = true,
    uiStat = {
      name = "MainWeaponKillCounter"
    },
    zOrder = 0
  },
  KillZoneAndSafeZoneTips = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.GuideTipsUI.KillZoneAndSafeZoneTips",
    path = "/Game/BluePrints/ControlInput/GuideTipsUI/KillZoneAndSafeZoneTips.KillZoneAndSafeZoneTips",
    isMainUI = false,
    zOrder = 0,
    asy = true,
    uiStat = {
      name = "KillZoneAndSafeZoneTips"
    }
  },
  KillZoneCountDownTips = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.GuideTipsUI.KillZoneCountDownTips",
    path = "/Game/BluePrints/ControlInput/GuideTipsUI/KillZoneCountDownTips.KillZoneCountDownTips",
    isMainUI = false,
    zOrder = 0,
    asy = true,
    uiStat = {
      name = "KillZoneCountDownTips"
    }
  },
  KilledTipsPanel = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.KilledTipsPanel",
    path = "/Game/BluePrints/ControlInput/KilledTipsPanel.KilledTipsPanel",
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    isWindowsOBHide = true,
    asy = true,
    uiStat = {
      name = "KilledTipsPanel"
    },
    zOrder = 0
  },
  KingEliminationItemTips = {
    moduleName = "GameLua.Mod.BaseMod.Client.KillInfoTips.KingEliminationItemTips",
    path = "/Game/BluePrints/ControlInput/IngameUI/TipsItem/KingEliminationItem_Tips_UIBP.KingEliminationItem_Tips_UIBP",
    isSingleton = true,
    uiStat = {
      name = "KingEliminationItemTips"
    },
    isMainUI = false,
    containerName = UIContainers.Top,
    asy = true,
    showVisibility = UEnums.ESlateVisibility.Collapsed
  },
  KingEliminationItemTipsForCollect = {
    moduleName = "GameLua.Mod.BaseMod.Client.KillInfoTips.KingEliminationItemTipsForCollect",
    path = "/Game/BluePrints/ControlInput/IngameUI/TipsItem/KingEliminationItem_Effect_CollectLevel100_Tips_UIBP.KingEliminationItem_Effect_CollectLevel100_Tips_UIBP",
    isSingleton = true,
    uiStat = {
      name = "KingEliminationItemTips"
    },
    isMainUI = false,
    containerName = UIContainers.Top,
    asy = true,
    showVisibility = UEnums.ESlateVisibility.Collapsed
  },
  LeftKillInfo = {
    moduleName = "GameLua.Mod.BaseMod.Client.KillInfoTips.LeftKillInfo",
    path = "/Game/BluePrints/ControlInput/IngameUI/TipsItem/LeftKillInfoItem.LeftKillInfoItem",
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    closeOnHide = false,
    asy = true,
    bPermanentDuringThisBattle = true,
    showVisibility = UEnums.ESlateVisibility.SelfHitTestInvisible,
    containerName = UIContainers.Default,
    autoCreate = true,
    uiStat = {
      name = "LeftKillInfo"
    },
    zOrder = 0
  },
  MultiKillTips = {
    moduleName = "GameLua.Mod.BaseMod.Client.BattlePopTipsUI.MultiKillTips",
    path = "/Game/BluePrints/ControlInput/BattlePopTips/BattlePopTips_Distance_Effect.BattlePopTips_Distance_Effect",
    isSingleton = true,
    uiStat = {
      name = "MultiKillTips"
    },
    isMainUI = false,
    containerName = UIContainers.Top,
    asy = true
  },
  NearDeathGiveupUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.NearDeathGiveupUI",
    path = "/Game/BluePrints/ControlInput/IngameUI/NearDeath_GiveUp_UIBP.NearDeath_GiveUp_UIBP",
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    isWindowsOBHide = true,
    zOrder = 20,
    asy = true,
    mountPanel = {
      mountOuterName = "MainControlBaseUI",
      mountName = "CanvasPanel_42"
    },
    uiStat = {
      name = "NearDeathGiveupUI"
    }
  },
  KillCounterTips = {
    moduleName = "GameLua.Mod.BaseMod.Client.KillCounter.KillCounterTips",
    path = "/Game/BluePrints/ControlInput/IngameUI/TipsItem/KillCounter_Tips_Item.KillCounter_Tips_Item",
    isMainUI = false,
    isSingleton = false,
    asy = true,
    uiStat = {
      name = "KillCounterTips"
    },
    zOrder = 0
  },
  KillInfoItem = {
    moduleName = "GameLua.Mod.BaseMod.Client.KillInfoTips.KillInfoItem",
    path = "/Game/BluePrints/ControlInput/IngameUI/TipsItem/KillInfoItem_BP.KillInfoItem_BP",
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    closeOnHide = false,
    showVisibility = UEnums.ESlateVisibility.SelfHitTestInvisible,
    containerName = UIContainers.Default,
    isSingleton = false,
    uiStat = {
      name = "KillInfoItem"
    },
    zOrder = 0,
    asy = true
  }
}
return UIConfig_KillInfo