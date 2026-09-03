local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local EUIConfigPoolType = require("client.slua.config.ClientMacros.EUIConfigPoolType")
local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local UIConfig_PlayerInfo = {
  HelmetArmor = {
    moduleName = "GameLua.Mod.BaseMod.Client.PlayerInfoPanel.HelmetArmor.HelmetArmorMain",
    path = "/Game/BluePrints/ControlInput/IngameUI/PlayerInfoPanel/HelmetArmor/HelmetArmor_UIBP.HelmetArmor_UIBP",
    fullScreen = false,
    uiStat = {
      name = "HelmetArmor"
    },
    containerName = UIContainers.Default,
    isSingleton = true,
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    zOrder = -10
  },
  IngameHPUIBase = {
    moduleName = "GameLua.Mod.BaseMod.Client.HPBar.IngameHPUIBase",
    path = "/Game/Mod/EvoBase/BluePrints/UI/IngameMonsterHP_UIBP.IngameMonsterHP_UIBP",
    containerName = UIContainers.Bottom,
    uiStat = {
      name = "IngameHPUIBase"
    },
    isMainUI = false
  },
  PlayerInfoCard = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.PlayerInfoCard",
    path = "/Game/BluePrints/ControlInput/ResultsshareUI/IngamePlayerInfo_UIBP.IngamePlayerInfo_UIBP",
    isMainUI = false,
    zOrder = 10,
    isWindowsOBHide = true,
    asy = true,
    uiStat = {
      name = "PlayerInfoCard"
    }
  },
  PlayerInfoPanelMain = {
    moduleName = "GameLua.Mod.BaseMod.Client.PlayerInfoPanel.PlayerInfoPanelMain",
    path = "/Game/BluePrints/ControlInput/PlayerInfoPanelMain.PlayerInfoPanelMain",
    fullScreen = false,
    uiStat = {
      name = "PlayerInfoPanelMain"
    },
    containerName = UIContainers.Default,
    isSingleton = true,
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    zOrder = 0,
    asy = false,
    autoCreate = true
  },
  ReviveCountDownUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.ReviveTower.ReviveCountDownUI",
    path = "/Game/Mod/EvoBase/BluePrints/UI/Revive_Countdown_UIBP.Revive_Countdown_UIBP",
    uiStat = {
      name = "ReviveCountDownUI"
    },
    closeOnHide = true,
    loadFromPool = EUIConfigPoolType.None,
    isMainUI = false,
    asy = true
  },
  ReviveTowerTipsUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.ReviveTower.ReviveTowerTipsUI",
    path = "/Game/Mod/EvoBase/BluePrints/UI/ReviveTowerUI/ReviveAirplaneTips.ReviveAirplaneTips",
    isSingleton = true,
    uiStat = {
      name = "ReviveTowerTipsUI"
    },
    asy = true,
    isMainUI = false,
    containerName = UIContainers.Top
  },
  SurviveInfoPanel = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.SurviveInfoPanel",
    path = "/Game/BluePrints/ControlInput/SurviveInfoPanel.SurviveInfoPanel",
    uiStat = {
      name = "SurviveInfoPanel"
    },
    containerName = UIContainers.Default,
    zOrder = 0,
    asy = true,
    autoCreate = true,
    isMainUI = false
  },
  WatchGameInGamePlayerInfo = {
    moduleName = "GameLua.Mod.BaseMod.Client.WatchGame.WatchGameInGamePlayerInfo",
    path = "/Game/BluePrints/ControlInput/ResultsshareUI/IngamePlayerInfo_UIBP.IngamePlayerInfo_UIBP",
    isMainUI = false,
    isWindowsOBHide = true,
    zOrder = 10,
    showVisibility = UEnums.ESlateVisibility.Collapsed,
    asy = true,
    uiStat = {
      name = "WatchGameInGamePlayerInfo"
    }
  },
  WatchGamePlayerInfo = {
    moduleName = "GameLua.Mod.BaseMod.Client.WatchGame.WatchGamePlayerInfo",
    path = "/Game/BluePrints/ControlInput/ResultsshareUI/Item/WatchGame_PlayerInfo_UIBP.WatchGame_PlayerInfo_UIBP",
    isMainUI = false,
    isWindowsOBHide = true,
    zOrder = 0,
    asy = true,
    uiStat = {
      name = "WatchGamePlayerInfo"
    }
  },
  BackpackItemReviveCard = {
    moduleName = "GameLua.Mod.BaseMod.Client.Backpack.BackPackReviveCardItemUI",
    path = "/Game/BluePrints/ControlInput/MainBackPackUI/Item/BackPackItem_BP.BackPackItem_BP",
    uiStat = {
      name = "BackPackReviveCardItemUI"
    },
    isMainUI = false,
    containerName = UIContainers.Default,
    AndroidBackType = EAndroidBackType.Ban,
    closeOnHide = false,
    isSingleton = false,
    zOrder = 0
  },
  KingEliminationStateIcon = {
    moduleName = "GameLua.Mod.BaseMod.Client.KillInfoTips.KingEliminationStateIcon",
    path = "/Game/BluePrints/ControlInput/IngameUI/TipsItem/KingElimination_State_Item_UIBP.KingElimination_State_Item_UIBP",
    isMainUI = false,
    isSingleton = false,
    zOrder = 0,
    closeOnHide = false,
    AndroidBackType = EAndroidBackType.Ban,
    showVisibility = UEnums.ESlateVisibility.Collapsed
  },
  PlayerInfoPanelStateIcon_BuffDisplayIcon = {
    moduleName = "GameLua.Mod.BaseMod.Client.PlayerInfoPanel.StateIcons.PlayerInfoPanelStateIcon_BuffDisplayIcon",
    path = "/Game/BluePrints/ControlInput/PlayerInfoPanelStateIcons/BuffDisplayIcon.BuffDisplayIcon",
    fullScreen = false,
    uiStat = {
      name = "PlayerInfoPanelStateIcon_BuffDisplayIcon"
    },
    containerName = UIContainers.Default,
    isSingleton = false,
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    zOrder = 0,
    asy = false,
    autoCreate = false
  },
  PlayerInfoPanelStateIcon_Freezing = {
    moduleName = "GameLua.Mod.BaseMod.Client.PlayerInfoPanel.StateIcons.PlayerInfoPanelStateIcon_Freezing",
    path = "/Game/BluePrints/ControlInput/PlayerInfoPanelStateIcons/FreezingStateIcon.FreezingStateIcon",
    fullScreen = false,
    uiStat = {
      name = "PlayerInfoPanelStateIcon_Freezing"
    },
    containerName = UIContainers.Default,
    isSingleton = false,
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    zOrder = 0,
    asy = false
  },
  PlayerInfoPanelStateIcon_Help = {
    moduleName = "GameLua.Mod.BaseMod.Client.PlayerInfoPanel.StateIcons.PlayerInfoPanelStateIcon_Help",
    path = "/Game/BluePrints/ControlInput/PlayerInfoPanelStateIcons/HelpStateIcon.HelpStateIcon",
    fullScreen = false,
    uiStat = {
      name = "PlayerInfoPanelStateIcon_Help"
    },
    containerName = UIContainers.Default,
    isSingleton = false,
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    zOrder = 0,
    asy = false,
    autoCreate = false
  },
  PlayerInfoPanelStateIcon_Power = {
    moduleName = "GameLua.Mod.BaseMod.Client.PlayerInfoPanel.StateIcons.PlayerInfoPanelStateIcon_Power",
    path = "/Game/BluePrints/ControlInput/PlayerInfoPanelStateIcons/PowerStateIcon.PowerStateIcon",
    fullScreen = false,
    uiStat = {
      name = "PlayerInfoPanelStateIcon_Power"
    },
    containerName = UIContainers.Default,
    isSingleton = false,
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    zOrder = 0,
    asy = false,
    autoCreate = false
  },
  PlayerInfoPanelStateIcon_Skill = {
    moduleName = "GameLua.Mod.BaseMod.Client.PlayerInfoPanel.StateIcons.PlayerInfoPanelStateIcon_Skill",
    path = "/Game/BluePrints/ControlInput/PlayerInfoPanelStateIcons/SkillStateIcon.SkillStateIcon",
    fullScreen = false,
    uiStat = {
      name = "PlayerInfoPanelStateIcon_Skill"
    },
    containerName = UIContainers.Default,
    isSingleton = false,
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    zOrder = 0,
    asy = false,
    autoCreate = false
  }
}
return UIConfig_PlayerInfo