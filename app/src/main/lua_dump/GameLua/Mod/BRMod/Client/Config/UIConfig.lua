local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local EUIConfigPoolType = require("client.slua.config.ClientMacros.EUIConfigPoolType")
local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local UIConfig = {
  NewParachutingPanel2UI = {
    moduleName = "GameLua.Mod.BRMod.Client.UMG.Parachute.NewParachutingPanel2UI",
    path = "/Game/BluePrints/ControlInput/NewParachutingPanel2_UIBP.NewParachutingPanel2_UIBP",
    uiStat = {
      name = "NewParachutingPanel2UI"
    },
    containerName = UIContainers.Default,
    showVisibility = UEnums.ESlateVisibility.SelfHitTestInvisible,
    isSingleton = true,
    asy = true,
    isMainUI = false,
    zOrder = 0
  },
  ParachutingControl = {
    moduleName = "GameLua.Mod.BRMod.Client.UMG.Parachute.ParachutingControl",
    path = "/Game/BluePrints/ControlInput/ParachutingControl.ParachutingControl",
    isMainUI = false,
    isWindowsOBHide = true,
    zOrder = 0,
    asy = true,
    mountPanel = {
      mountOuterName = "MainControlPanelTochButton",
      mountName = "ParachutingLayer"
    },
    uiStat = {
      name = "ParachutingControl"
    }
  },
  SignUI = {
    moduleName = "GameLua.Mod.BRMod.Client.UMG.AICommand.AICommandUIBase",
    path = "/Game/Mod/EvoBase/BluePrints/UI/Sign_UIBP.Sign_UIBP",
    uiStat = {name = "SignUI"},
    containerName = UIContainers.Default,
    isSingleton = true,
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    zOrder = 0,
    asy = true
  },
  IngameTeamItem_New = {
    moduleName = "GameLua.Mod.BRMod.Client.IngameTeamPanel.IngameTeamItem_UI_New",
    path = "/Game/BluePrints/ControlInput/IngameUI/Ingame_TeamPanel_New/Items/Ingame_TeamItem_New_UIBP.Ingame_TeamItem_New_UIBP",
    fullScreen = false,
    uiStat = {
      name = "IngameTeamItem_New"
    },
    containerName = UIContainers.Default,
    closeOnHide = false,
    isSingleton = false
  },
  SmartAssistantMainUIBP = require("GameLua.Mod.Library.Client.Config.UIConfig").UIConfig.SmartAssistantMainUIBP,
  SmartAssistantGuideUIBP = require("GameLua.Mod.Library.Client.Config.UIConfig").UIConfig.SmartAssistantGuideUIBP
}
return UIConfig