local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local EUIConfigPoolType = require("client.slua.config.ClientMacros.EUIConfigPoolType")
local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local UIConfig_GM = {
  BattleGMAnimDebugSubPanel = {
    moduleName = "GameLua.Dev.IngameGM.IngameGMItems.IngameGMAnimDebugSubPanel",
    path = "/Game/BluePrints/ControlInput/IngameUI/IngameGM/Ingame_GMUI_Item/Ingame_GMUI_AnimDebugSubPanel.Ingame_GMUI_AnimDebugSubPanel",
    fullScreen = true,
    uiStat = {
      name = "BattleGMAnimDebugSubPanel"
    },
    containerName = UIContainers.Top,
    isSingleton = true
  },
  BattleGMCommandInputPanel = {
    moduleName = "GameLua.Dev.IngameGM.IngameGMItems.IngameGMCommandInput",
    path = "/Game/BluePrints/ControlInput/IngameUI/IngameGM/Ingame_GMUI_Item/Ingame_GMUI_GMInput.Ingame_GMUI_GMInput",
    fullScreen = true,
    uiStat = {
      name = "BattleGMCommandInputPanel"
    },
    containerName = UIContainers.Top,
    isSingleton = true
  },
  BattleGMInputPanel = {
    moduleName = "GameLua.Dev.IngameGM.IngameGMItems.IngameGMInputPanel",
    path = "/Game/BluePrints/ControlInput/IngameUI/IngameGM/Ingame_GMUI_Item/Ingame_GMUI_InputPanel.Ingame_GMUI_InputPanel",
    fullScreen = true,
    uiStat = {
      name = "BattleGMInputPanel"
    },
    containerName = UIContainers.Top,
    isSingleton = true
  },
  BattleGMInputRecommendPanel = {
    moduleName = "GameLua.Dev.IngameGM.IngameGMItems.IngameGMInputRecommendPanel",
    path = "/Game/BluePrints/ControlInput/IngameUI/IngameGM/Ingame_GMUI_Item/Ingame_GMUI_SelectAndInputPanel.Ingame_GMUI_SelectAndInputPanel",
    fullScreen = true,
    uiStat = {
      name = "BattleGMInputRecommendPanel"
    },
    containerName = UIContainers.Top,
    isSingleton = true
  },
  BattleGMPanel = {
    moduleName = "GameLua.Dev.IngameGM.IngameGMUI",
    path = "/Game/BluePrints/ControlInput/IngameUI/IngameGM/Ingame_GMUI.Ingame_GMUI",
    fullScreen = true,
    containerName = UIContainers.Top,
    uiStat = {
      name = "BattleGMPanel"
    },
    closeOnHide = false,
    AndroidBackType = EAndroidBackType.Skip
  },
  BattleGMSelectAndInputPanel = {
    moduleName = "GameLua.Dev.IngameGM.IngameGMItems.IngameGMSelectAndInputPanel",
    path = "/Game/BluePrints/ControlInput/IngameUI/IngameGM/Ingame_GMUI_Item/Ingame_GMUI_SelectAndInputPanel.Ingame_GMUI_SelectAndInputPanel",
    fullScreen = true,
    uiStat = {
      name = "BattleGMSelectAndInputPanel"
    },
    containerName = UIContainers.Top,
    isSingleton = true
  },
  BattleGMSelectPanel = {
    moduleName = "GameLua.Dev.IngameGM.IngameGMItems.IngameGMSelectPanel",
    path = "/Game/BluePrints/ControlInput/IngameUI/IngameGM/Ingame_GMUI_Item/Ingame_GMUI_SelectPanel.Ingame_GMUI_SelectPanel",
    fullScreen = true,
    uiStat = {
      name = "BattleGMSelectPanel"
    },
    containerName = UIContainers.Top,
    isSingleton = true
  },
  IngameGMMapEditor = {
    moduleName = "GameLua.Dev.IngameGM.IngameGMItems.IngameGMMapEditor",
    path = "/Game/BluePrints/ControlInput/IngameUI/IngameGM/Ingame_GMUI_Item/Ingame_GMUI_MapEditor.Ingame_GMUI_MapEditor",
    fullScreen = true,
    uiStat = {
      name = "IngameGMMapEditor"
    },
    containerName = UIContainers.Top,
    isSingleton = true
  },
  IngameGMPVEMonsterPanel = {
    moduleName = "GameLua.Dev.IngameGM.IngameGMItems.IngameGMPVEMonsterPanel",
    path = "/Game/BluePrints/ControlInput/IngameUI/IngameGM/Ingame_GMUI_Item/Ingame_GMUI_PVESpawnMonsterPanel.Ingame_GMUI_PVESpawnMonsterPanel",
    fullScreen = true,
    uiStat = {
      name = "IngameGMPVEMonsterPanel"
    },
    containerName = UIContainers.Top,
    isSingleton = true
  },
  IngameGMReplayPanel = {
    moduleName = "GameLua.Dev.IngameGM.IngameGMItems.IngameGMRePlayerPanel",
    path = "/Game/BluePrints/ControlInput/IngameUI/IngameGM/Ingame_GMUI_Item/Ingame_GMUI_ReplayPanel.Ingame_GMUI_ReplayPanel",
    fullScreen = true,
    uiStat = {
      name = "IngameGMReplayPanel"
    },
    containerName = UIContainers.Top,
    isSingleton = true,
    zOrder = EFixedZOrder.Click_Animation
  },
  IngameGMActorWatcher = {
    moduleName = "GameLua.Dev.IngameGM.IngameGMItems.IngameGMActorWatcher",
    path = "/Game/BluePrints/ControlInput/IngameUI/IngameGM/Ingame_GMUI_Item/Ingame_GMUI_Watcher.Ingame_GMUI_Watcher",
    fullScreen = true,
    uiStat = {
      name = "IngameGMActorWatcher"
    },
    containerName = UIContainers.Top,
    isSingleton = true,
    zOrder = EFixedZOrder.Click_Animation
  },
  IngameGMSmartBearerPanel = {
    moduleName = "GameLua.Dev.IngameGM.IngameGMItems.IngameGMSmartBearerPanel",
    path = "/Game/BluePrints/ControlInput/IngameUI/IngameGM/Ingame_GMUI_Item/Ingame_GMUI_SmartBearerPanel.Ingame_GMUI_SmartBearerPanel",
    fullScreen = true,
    uiStat = {
      name = "IngameGMSmartBearerPanel"
    },
    containerName = UIContainers.Top,
    isSingleton = true
  },
  IngameGMWeaponEditorPanel = {
    moduleName = "GameLua.Dev.IngameGM.IngameGMItems.IngameGMWeaponEditorPanel",
    path = "/Game/BluePrints/ControlInput/IngameUI/IngameGM/Ingame_GMUI_Item/Ingame_GMUI_WeaponEditor_Panel.Ingame_GMUI_WeaponEditor_Panel",
    fullScreen = true,
    uiStat = {
      name = "GM WeaponEditorPanel"
    },
    containerName = UIContainers.Top,
    isSingleton = true
  },
  IngameGMWonderfulReplayPanel = {
    moduleName = "GameLua.Dev.IngameGM.IngameGMItems.IngameGMWonderfulReplay",
    path = "/Game/BluePrints/ControlInput/IngameUI/IngameGM/Ingame_GMUI_Item/Ingame_GMUI_WonderfulReplayPanel.Ingame_GMUI_WonderfulReplayPanel",
    fullScreen = true,
    uiStat = {
      name = "IngameGMWonderfulReplayPanel"
    },
    containerName = UIContainers.Top,
    isSingleton = true,
    zOrder = EFixedZOrder.Click_Animation
  },
  ActorClickPickerUIBP = {
    moduleName = "client.slua_ui_framework.base",
    path = "/Game/BluePrints/ControlInput/IngameUI/IngameGM/Ingame_GMUI_Item/ActorClickPickerUIBP.ActorClickPickerUIBP",
    fullScreen = true,
    uiStat = {
      name = "ActorClickPickerUIBP"
    },
    containerName = UIContainers.Top,
    isSingleton = true,
    zOrder = EFixedZOrder.Click_Animation
  }
}
return UIConfig_GM