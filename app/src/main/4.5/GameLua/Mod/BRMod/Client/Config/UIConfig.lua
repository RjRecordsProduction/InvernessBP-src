local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local EUIConfigPoolType = require("client.slua.config.ClientMacros.EUIConfigPoolType")
local ModulePathList = {
  "GameLua.Mod.BRMod.Client.Config.UIConfig.UIConfig_BattleResult"
}
local ModuleCache = {}
local ClearModuleCache = function()
  ModuleCache = {}
  for _, modulePath in ipairs(ModulePathList) do
    package.loaded[modulePath] = nil
  end
end
local LoadModule = function(modulePath)
  if ModuleCache[modulePath] then
    return ModuleCache[modulePath]
  end
  local success, moduleConfig = pcall(require, modulePath)
  if not success then
    print(string.format("BRModUIConfig: Failed to load module %s, error: %s", modulePath, tostring(moduleConfig)))
    return {}
  end
  ModuleCache[modulePath] = moduleConfig
  return moduleConfig
end
local MergeSubModulesInto = function(target, bReleaseAfterMerge)
  for _, modulePath in ipairs(ModulePathList) do
    local moduleConfig = LoadModule(modulePath)
    for key, value in pairs(moduleConfig) do
      if target[key] then
        print(string.format("BRModUIConfig: Warning - Duplicate key '%s' found in module %s", key, modulePath))
      end
      target[key] = value
    end
  end
  if bReleaseAfterMerge then
    ClearModuleCache()
  end
end
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
  AirLineGuidWidget = {
    moduleName = "GameLua.Mod.BRMod.Client.Map.AirLineGuidWidget",
    path = "/Game/BluePrints/UI/Map/Guide/AirLineWidget_Tip_UIBP.AirLineWidget_Tip_UIBP",
    isMainUI = false,
    isSingleton = true,
    zOrder = 0,
    asy = true,
    closeOnHide = false,
    uiStat = {
      name = "TreatmentDeviceRightUI"
    },
    AndroidBackType = EAndroidBackType.Ban
  },
  AirLineUI = {
    moduleName = "GameLua.Mod.BRMod.Client.Map.AirLineUI",
    path = "/Game/BluePrints/UI/Map/AirLineWidget.AirLineWidget",
    uiStat = {name = "AirLineUI"},
    isSingleton = false,
    zOrder = 1,
    isMainUI = false
  },
  SecondAirLineUI = {
    moduleName = "GameLua.Mod.BRMod.Client.Map.SecondAirLineUI",
    path = "/Game/BluePrints/UI/Map/AirLineWidget.AirLineWidget",
    uiStat = {name = "Line2"},
    isSingleton = false,
    zOrder = 1,
    isMainUI = false
  },
  SecondAirLineUIOB = {
    moduleName = "GameLua.Mod.BRMod.Client.Map.SecondAirLineUIOB",
    path = "/Game/BluePrints/UI/Map/AirLineWidgetOB.AirLineWidgetOB",
    uiStat = {name = "obLine2"},
    isSingleton = false,
    zOrder = 1,
    isMainUI = false
  },
  BlueCircleUI = {
    moduleName = "GameLua.Mod.BRMod.Client.Map.BlueCircleUI",
    path = "/Game/BluePrints/UI/Map/BlueCircleWidget.BlueCircleWidget",
    uiStat = {
      name = "BlueCircleUI"
    },
    isSingleton = false,
    zOrder = 1,
    isMainUI = false,
    asy = true
  },
  CustomBlueCircleUI = {
    moduleName = "GameLua.Mod.BRMod.Client.Map.CustomBlueCircle",
    path = "/Game/BluePrints/UI/Map/BlueCircleWidget.BlueCircleWidget",
    uiStat = {
      name = "CustomBlueCircleUI"
    },
    isSingleton = false,
    zOrder = 1,
    isMainUI = false,
    asy = true
  },
  InnerCircleUI = {
    moduleName = "GameLua.Mod.BRMod.Client.Map.InnerCircleUI",
    path = "/Game/BluePrints/UI/Map/InnerCircleWidget.InnerCircleWidget",
    uiStat = {
      name = "InnerCircleUI"
    },
    isSingleton = false,
    isMainUI = false,
    zOrder = 1
  },
  AirAttackAreaUI = {
    moduleName = "GameLua.Mod.BRMod.Client.Map.AirAttackAreaUI",
    path = "/Game/BluePrints/UI/Map/AirAttackAreaUIWidget.AirAttackAreaUIWidget",
    uiStat = {
      name = "AirAttackAreaUI"
    },
    isSingleton = false,
    zOrder = 1,
    isMainUI = false,
    asy = true
  },
  CustomAirAttackAreaUI = {
    moduleName = "GameLua.Mod.BRMod.Client.Map.CustomAirAttackAreaUI",
    path = "/Game/BluePrints/UI/Map/AirAttackAreaUIWidget.AirAttackAreaUIWidget",
    uiStat = {
      name = "CustomAirAttackAreaUI"
    },
    isSingleton = false,
    zOrder = 1,
    isMainUI = false,
    asy = true
  },
  AirDropUI = {
    moduleName = "GameLua.Mod.BRMod.Client.Map.AirDropUI",
    path = "/Game/BluePrints/UI/Map/Item/Bounty_Airline_UIBP.Bounty_Airline_UIBP",
    uiStat = {name = "AirDropUI"},
    isSingleton = false,
    isMainUI = false,
    zOrder = 1
  },
  GameOverCountDown_UIBP = {
    moduleName = "GameLua.Mod.BRMod.Client.BattleResult.GameOverTips.BattleResultCountDown_UICtrl",
    path = "/Game/Mod/EvoBase/BluePrints/UI/BattleResult/GameOverCountDown/GameOverCountDown_UIBP.GameOverCountDown_UIBP",
    uiStat = {
      name = "GameOverCountDown_UIBP"
    },
    containerName = UIContainers.Top,
    closeOnHide = false,
    AndroidBackType = EAndroidBackType.Ban,
    asy = true,
    zOrder = EFixedZOrder.Click_Animation
  },
  AutoParachuteUI = {
    moduleName = "GameLua.Mod.BRMod.Client.AutoParachute.AutoParachuteUI",
    path = "/Game/Mod/EvoBase/BluePrints/UIBP/AutomaticParachuting/Parachuting_UIBP.Parachuting_UIBP",
    uiStat = {
      name = "AutoParachuteUI"
    },
    zOrder = 0,
    closeOnHide = true,
    loadFromPool = EUIConfigPoolType.None,
    isMainUI = false
  },
  ParachuteOpenUI = {
    moduleName = "GameLua.Mod.BRMod.Client.InGameUI.ParachuteOpenUI",
    path = "/Game/UMG/UI_BP/Setting/Setting_Skill_Skydiver_UIBP.Setting_Skill_Skydiver_UIBP",
    uiStat = {
      name = "ParachuteOpenUI"
    },
    closeOnHide = false,
    isMainUI = false,
    asy = true
  },
  BattlePass02 = {
    moduleName = "GameLua.Mod.BRMod.Client.BattlePassCoatingMes02ItemUI.BattlePassCoatingMes02ItemUI",
    path = "/Game/BluePrints/ControlInput/BattlePass/BattlePass_CoatingMes02_Item.BattlePass_CoatingMes02_Item",
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Ban,
    isWindowsOBHide = true,
    closeOnHide = false,
    zOrder = -9,
    loadFromPool = EUIConfigPoolType.None,
    asy = true,
    showVisibility = UEnums.ESlateVisibility.Collapsed,
    uiStat = {
      name = "BattlePass02"
    }
  },
  PlaneShowAliasEnterBroadcastUI = {
    moduleName = "GameLua.Mod.BRMod.Client.PlaneShow.PlaneShowAliasEnterBroadcastUI",
    path = "/Game/BluePrints/UI/PlaneShow/PlaneShow_AliasEnterBroadcast.PlaneShow_AliasEnterBroadcast",
    isMainUI = false,
    asy = true,
    loadFromPool = EUIConfigPoolType.None,
    uiStat = {
      name = "PlaneShowAliasEnterBroadcastUI"
    },
    containerName = UIContainers.Top
  },
  PlaneShowBestViewSwitch = {
    moduleName = "GameLua.Mod.BRMod.Client.PlaneShow.PlaneShowBestViewUI",
    path = "/Game/Mod/EvoBase/BluePrints/UI/PlaneViewSwitch_UIBP.PlaneViewSwitch_UIBP",
    uiStat = {
      name = "PlaneShowBestViewSwitch"
    },
    asy = true,
    loadFromPool = EUIConfigPoolType.None,
    zOrder = 99,
    isMainUI = false
  },
  PlaneShowCloseViewSwitch = {
    moduleName = "GameLua.Mod.BRMod.Client.PlaneShow.PlaneShowCloseUI",
    path = "/Game/Mod/EvoBase/BluePrints/UI/PlaneViewSwitch_Close_UIBP.PlaneViewSwitch_Close_UIBP",
    uiStat = {
      name = "PlaneShowCloseViewSwitch"
    },
    closeOnHide = false,
    asy = true,
    loadFromPool = EUIConfigPoolType.None,
    containerName = UIContainers.Top,
    isMainUI = false
  },
  PlaneShowSkinTipsUI = {
    moduleName = "GameLua.Mod.BRMod.Client.PlaneShow.PlaneShowSkinTipsUI",
    path = "/Game/BluePrints/UI/PlaneShow/PlaneShow_Tips.PlaneShow_Tips",
    isMainUI = false,
    asy = true,
    loadFromPool = EUIConfigPoolType.None,
    uiStat = {
      name = "PlaneShowSkinTipsUI"
    },
    containerName = UIContainers.Top
  },
  AirplaneShowUI = {
    moduleName = "GameLua.Mod.BRMod.Client.PlaneShow.PlaneTeamNameUI",
    path = "/Game/Mod/EvoBase/BluePrints/UI/ID_Emergesr_UIBP.ID_Emergesr_UIBP",
    isMainUI = false,
    asy = true,
    loadFromPool = EUIConfigPoolType.None,
    uiStat = {
      name = "BornIslandTeamShowUI"
    },
    containerName = UIContainers.Top
  },
  AirplaneShowFinalNameUI = {
    moduleName = "GameLua.Mod.BRMod.Client.PlaneShow.PlaneTeamNameUI",
    path = "/Game/Mod/EvoBase/BluePrints/UI/ID_NameInfo_UIBP.ID_NameInfo_UIBP",
    isMainUI = false,
    asy = true,
    loadFromPool = EUIConfigPoolType.None,
    uiStat = {
      name = "BornIslandTeamShowUI"
    },
    containerName = UIContainers.Top
  },
  BornIslandTeamToPlaneUI = {
    moduleName = "GameLua.Mod.BRMod.Client.BornIslandTeamShow.BornIslandTeamShowToPaneUI",
    path = "/Game/Mod/EvoBase/BluePrints/UI/BornIslandTeamShow/AircraftTransition_6th_UIBP.AircraftTransition_6th_UIBP",
    isMainUI = false,
    asy = true,
    loadFromPool = EUIConfigPoolType.None,
    uiStat = {
      name = "BornIslandTeamToPlaneUI"
    },
    containerName = UIContainers.Top
  },
  ReviveCountDownUI = {
    moduleName = "GameLua.Mod.BRMod.Client.ReviveTower.ReviveCountDownUI",
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
    moduleName = "GameLua.Mod.BRMod.Client.ReviveTower.ReviveTowerTipsUI",
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
    moduleName = "GameLua.Mod.BRMod.Client.InGameUI.SurviveInfoPanel",
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
  VoiceEmojiBubble = {
    moduleName = "GameLua.Mod.BRMod.Client.VoiceEmojiBubble.VoiceEmojiBubbleUI",
    path = "/Game/Mod/BRMod/BluePrints/UI/Ingame_VoiceEmojiBubble_UIBP.Ingame_VoiceEmojiBubble_UIBP",
    fullScreen = false,
    uiStat = {
      name = "VoiceEmojiBubble"
    },
    containerName = UIContainers.Default,
    isSingleton = false,
    loadFromPool = EUIConfigPoolType.None
  },
  Exit_Execute_UIBP = {
    moduleName = "GameLua.Mod.BRMod.Client.InGameUI.Exit_Execute_UIBP",
    path = "/Game/Mod/BRMod/BluePrints/UI/Exit_Execute_UIBP.Exit_Execute_UIBP",
    containerName = UIContainers.Default,
    zOrder = 1,
    isMainUI = false,
    closeOnHide = true,
    isWindowsOBHide = true,
    loadFromPool = EUIConfigPoolType.None,
    uiStat = {
      name = "Exit_Execute_UIBP"
    }
  },
  InMatchVideoPlayerUI = {
    moduleName = "GameLua.Mod.BRMod.Client.InGameUI.InMatchVideoPlayerUI",
    path = "/Game/Mod/BRMod/BluePrints/UI/NT_Memory_UIBP.NT_Memory_UIBP",
    isSingleton = true,
    uiStat = {
      name = "InMatchVideoPlayerUI"
    },
    isMainUI = false,
    loadFromPool = EUIConfigPoolType.None,
    containerName = UIContainers.Top
  },
  SmartAssistantMainUIBP = require("GameLua.Mod.Library.Client.Config.UIConfig").UIConfig.SmartAssistantMainUIBP,
  SmartAssistantGuideUIBP = require("GameLua.Mod.Library.Client.Config.UIConfig").UIConfig.SmartAssistantGuideUIBP
}
MergeSubModulesInto(UIConfig, true)
return UIConfig