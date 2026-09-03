local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local EUIConfigPoolType = require("client.slua.config.ClientMacros.EUIConfigPoolType")
local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local UIConfig_TeamPanel = {
  BornIslandTeamShowUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.BornIslandTeamShow.BornIslandTeamShowUI",
    path = "/Game/Mod/EvoBase/BluePrints/UI/BornIslandTeamShow/BornIslandTeamShow_UIBP.BornIslandTeamShow_UIBP",
    isMainUI = false,
    asy = true,
    loadFromPool = EUIConfigPoolType.None,
    uiStat = {
      name = "BornIslandTeamShowUI"
    },
    containerName = UIContainers.Top
  },
  BornIslandTeamShowUILow = {
    moduleName = "GameLua.Mod.BaseMod.Client.BornIslandTeamShow.BornIslandTeamShowUI",
    path = "/Game/Mod/EvoBase/BluePrints/UI/BornIslandTeamShow/BornIslandTeamShow_New_UIBP.BornIslandTeamShow_New_UIBP",
    isMainUI = false,
    asy = true,
    loadFromPool = EUIConfigPoolType.None,
    uiStat = {
      name = "BornIslandTeamShowUILow"
    },
    containerName = UIContainers.Top
  },
  DanceLeaderHeadTips = {
    moduleName = "GameLua.Mod.Library.Client.UI.RobotDance.DanceLeaderPositionUI",
    path = "/Game/Library/Res/Actors/RobotDance/BluePrints/UI/DanceLeaderPositionWidget_BP.DanceLeaderPositionWidget_BP",
    uiStat = {
      name = "DanceLeaderHeadTips"
    },
    zOrder = 0,
    closeOnHide = false,
    isMainUI = false,
    asy = true
  },
  HealTeammateUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.HealTeammateUI",
    path = "/Game/BluePrints/ControlInput/IngameUI/HealTeammate_HealthBar_UIBP.HealTeammate_HealthBar_UIBP",
    isMainUI = false,
    isWindowsOBHide = true,
    closeOnHide = false,
    bPermanentDuringThisBattle = true,
    zOrder = 1,
    asy = true,
    uiStat = {
      name = "HealTeammateUI"
    }
  },
  IngameTeamUIBP = {
    moduleName = "GameLua.Mod.Library.Client.Social.Socialize_TeamInformation_UIBP",
    path = "/Game/BluePrints/ControlInput/IngameUI/Socialize_TeamInformation_UIBP.Socialize_TeamInformation_UIBP",
    containerName = UIContainers.Default,
    zOrder = 1,
    uiStat = {
      name = "IngameTeamUIBP"
    },
    isMainUI = false,
    asy = true
  },
  IngameTeamUpTips = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.TeamUpTip",
    path = "/Game/BluePrints/ControlInput/IngameUI/Captive/TeamUp_Tips_UIBP.TeamUp_Tips_UIBP",
    fullScreen = false,
    uiStat = {
      name = "IngameTeamUpTips"
    },
    containerName = UIContainers.Default,
    isSingleton = true,
    zOrder = 0
  },
  TeamPanel = {
    moduleName = "GameLua.Mod.BaseMod.Client.IngameTeamPanel.IngameTeamPanelMain",
    path = "/Game/BluePrints/ControlInput/IngameUI/Ingame_TeamPanel_New/Ingame_TeamPanel_New_UIBP.Ingame_TeamPanel_New_UIBP",
    fullScreen = false,
    uiStat = {name = "TeamPanel"},
    containerName = UIContainers.Default,
    isSingleton = true,
    isMainUI = false,
    zOrder = 0
  },
  WonderfulTeamPanel = {
    moduleName = "GameLua.Mod.BaseMod.Client.Replay.WonderfulTeamPanel",
    path = "/Game/BluePrints/ControlInput/IngameUI/Ingame_TeamPanel_New/Wonderful_TeamPanel_UIBP.Wonderful_TeamPanel_UIBP",
    fullScreen = false,
    uiStat = {
      name = "WonderfulTeamPanel"
    },
    containerName = UIContainers.Default,
    isSingleton = true,
    isMainUI = false,
    zOrder = 0
  },
  IngameFollowItem_New = {
    moduleName = "GameLua.Mod.BaseMod.Client.IngameTeamPanel.Items.IngameFollowItem_UI_New",
    path = "/Game/BluePrints/ControlInput/IngameUI/Ingame_TeamPanel_New/Items/Ingame_FollowItem_New_UIBP.Ingame_FollowItem_New_UIBP",
    fullScreen = false,
    uiStat = {
      name = "IngameFollowItem_New"
    },
    containerName = UIContainers.Default,
    isSingleton = false
  },
  IngameOnPlanePositionItem_New = {
    moduleName = "GameLua.Mod.BaseMod.Client.IngameTeamPanel.Items.IngamePosItemOnPlane_UI_New",
    path = "/Game/BluePrints/ControlInput/IngameUI/Ingame_TeamPanel_New/Items/Ingame_TeammatePosition_OnPlane_UIBP.Ingame_TeammatePosition_OnPlane_UIBP",
    fullScreen = false,
    uiStat = {
      name = "IngameOnPlanePositionItem_New"
    },
    containerName = UIContainers.None,
    isSingleton = false
  },
  IngamePositionItem = {
    moduleName = "GameLua.Mod.BaseMod.Client.IngameTeamPanel.Items.IngamePositionItem_UI_New",
    path = "/Game/BluePrints/ControlInput/IngameUI/Ingame_TeamPanel_New/Items/Ingame_TeammatePositionItem_New_UIBP.Ingame_TeammatePositionItem_New_UIBP",
    fullScreen = false,
    uiStat = {
      name = "IngamePositionItem"
    },
    containerName = UIContainers.Default,
    isSingleton = false
  },
  IngameTeamItem_New = {
    moduleName = "GameLua.Mod.BaseMod.Client.IngameTeamPanel.Items.IngameTeamItem_UI_New",
    path = "/Game/BluePrints/ControlInput/IngameUI/Ingame_TeamPanel_New/Items/Ingame_TeamItem_New_UIBP.Ingame_TeamItem_New_UIBP",
    fullScreen = false,
    uiStat = {
      name = "IngameTeamItem_New"
    },
    containerName = UIContainers.Default,
    closeOnHide = false,
    isSingleton = false
  },
  Ingame_FollowItem_Aircraft_UIBP = {
    moduleName = "GameLua.Mod.BaseMod.Client.IngameTeamPanel.Items.Ingame_FollowItem_Aircraft_UIBP",
    path = "/Game/BluePrints/ControlInput/IngameUI/Ingame_TeamPanel_New/Items/Ingame_FollowItem_Aircraft_UIBP.Ingame_FollowItem_Aircraft_UIBP",
    fullScreen = false,
    uiStat = {
      name = "Ingame_FollowItem_Aircraft_UIBP"
    },
    containerName = UIContainers.Default,
    isSingleton = false
  },
  OtherPositionItem_BP = {
    moduleName = "GameLua.Mod.BaseMod.Client.IngameTeamPanel.Items.OtherPositionItem_BP",
    path = "/Game/BluePrints/ControlInput/IngameUI/Ingame_TeamPanel/Item/OtherPositionItem_BP.OtherPositionItem_BP",
    fullScreen = false,
    uiStat = {
      name = "OtherPositionItem_BP"
    },
    containerName = UIContainers.Default,
    isSingleton = false
  },
  WonderfulTeammatePosItem = {
    moduleName = "GameLua.Mod.BaseMod.Client.Replay.WonderfulTeammatePosItem",
    path = "/Game/BluePrints/ControlInput/IngameUI/Ingame_TeamPanel_New/Items/Wonderful_TeammatePositionItem_UIBP.Wonderful_TeammatePositionItem_UIBP",
    fullScreen = false,
    uiStat = {
      name = "WonderfulTeammatePosItem"
    },
    containerName = UIContainers.Default,
    closeOnHide = false,
    isSingleton = false
  }
}
return UIConfig_TeamPanel