local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local EUIConfigPoolType = require("client.slua.config.ClientMacros.EUIConfigPoolType")
local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local UIConfig_Map = {
  AirLineGuidWidget = {
    moduleName = "GameLua.Mod.BaseMod.Client.Map.AirLineGuidWidget",
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
  AreaPlayerNumMiniPanel = {
    moduleName = "GameLua.Mod.Library.Client.UI.AreaPlayerNumMiniUI",
    path = "/Game/Mod/EvoBase/BluePrints/UI/MapItem/AreaPlayerNumMiNi_UIBP.AreaPlayerNumMiNi_UIBP",
    isSingleton = true,
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "AreaPlayerNumMiniPanel"
    },
    zOrder = 0
  },
  AreaPlayerNumPanel = {
    moduleName = "GameLua.Mod.Library.Client.UI.AreaPlayerNumUI",
    path = "/Game/Mod/EvoBase/BluePrints/UI/MapItem/AreaPlayerNum_UIBP.AreaPlayerNum_UIBP",
    isSingleton = true,
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "AreaPlayerNumPanel"
    },
    zOrder = 0
  },
  EntireMapChangeBtn = {
    moduleName = "GameLua.Mod.BaseMod.Client.Map.MapWindow.ChangeMapBtnUI",
    path = "/Game/BluePrints/UI/Map/EntireMap_ChangeMapBtn_UIBP.EntireMap_ChangeMapBtn_UIBP",
    zOrder = 10,
    uiStat = {
      name = "EntireMapChangeBtn"
    },
    isMainUI = false,
    closeOnHide = true,
    loadFromPool = EUIConfigPoolType.None,
    asy = true
  },
  EntireMapLegend = {
    moduleName = "GameLua.Mod.BaseMod.Client.Map.MapLegend.MapLegendBase",
    path = "/Game/Mod/EvoBase/BluePrints/UI/MapItem/EntireMapLegend_UIBP.EntireMapLegend_UIBP",
    containerName = UIContainers.Default,
    zOrder = 10,
    uiStat = {
      name = "EntireMapLegend"
    },
    isMainUI = false
  },
  EntireMapTaskUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.Map.MapWindow.EntireMapTaskUI",
    path = "/Game/BluePrints/UI/Map/EntireMapUI_Task_UIBP.EntireMapUI_Task_UIBP",
    uiStat = {
      name = "EntireMapTaskUI"
    },
    isMainUI = false,
    closeOnHide = false,
    bPermanentDuringThisBattle = true,
    zOrder = 1,
    autoCreate = true
  },
  EntireMapWindow = {
    moduleName = "GameLua.Mod.BaseMod.Client.Map.MapWindow.EntireMapWindow",
    path = "/Game/BluePrints/UI/Map/EntireMapUIWidget.EntireMapUIWidget",
    uiStat = {
      name = "EntireMapWindow"
    },
    closeOnHide = false,
    bPermanentDuringThisBattle = true,
    AndroidBackType = EAndroidBackType.Skip,
    zOrder = 100
  },
  GameGuideUIMain = {
    moduleName = "GameLua.Mod.BaseMod.Client.Map.GameGuideUI.GameGuideUIMain",
    path = "/Game/BluePrints/Game/BluePrints/UI/GamePlayGuide_UIBP.GamePlayGuide_UIBP",
    uiStat = {
      name = "GameGuideUIMain"
    },
    isMainUI = false,
    closeOnHide = true,
    bPermanentDuringThisBattle = true,
    zOrder = 40,
    isSingleton = true,
    asy = true
  },
  MapSoundVisualization = {
    moduleName = "GameLua.Mod.BaseMod.Client.SoundVisualization.MapSoundVisualization",
    path = "/Game/Mod/EvoBase/BluePrints/UI/SoundVisualization/SoundVisualization_Map_Mark_UIBP.SoundVisualization_Map_Mark_UIBP",
    uiStat = {
      name = "MapSoundVisualization"
    },
    closeOnHide = false,
    AndroidBackType = EAndroidBackType.Ban,
    isMainUI = false,
    zOrder = 0
  },
  MiniMapWindow = {
    moduleName = "GameLua.Mod.BaseMod.Client.Map.MapWindow.MiniMapWindow",
    path = "/Game/BluePrints/UI/Map/MiniMapUIWidget.MiniMapUIWidget",
    uiStat = {
      name = "MiniMapWindow"
    },
    isMainUI = false,
    closeOnHide = false,
    bPermanentDuringThisBattle = true,
    zOrder = 0
  },
  AirAttackAreaUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.Map.AirAttackAreaUI",
    path = "/Game/BluePrints/UI/Map/AirAttackAreaUIWidget.AirAttackAreaUIWidget",
    uiStat = {
      name = "AirAttackAreaUI"
    },
    isSingleton = false,
    zOrder = 1,
    isMainUI = false,
    asy = true
  },
  AirDropUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.Map.AirDropUI",
    path = "/Game/BluePrints/UI/Map/Item/Bounty_Airline_UIBP.Bounty_Airline_UIBP",
    uiStat = {name = "AirDropUI"},
    isSingleton = false,
    isMainUI = false,
    zOrder = 1
  },
  AirLineUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.Map.AirLineUI",
    path = "/Game/BluePrints/UI/Map/AirLineWidget.AirLineWidget",
    uiStat = {name = "AirLineUI"},
    isSingleton = false,
    zOrder = 1,
    isMainUI = false
  },
  BlueCircleUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.Map.BlueCircleUI",
    path = "/Game/BluePrints/UI/Map/BlueCircleWidget.BlueCircleWidget",
    uiStat = {
      name = "BlueCircleUI"
    },
    isSingleton = false,
    zOrder = 1,
    isMainUI = false,
    asy = true
  },
  CarTipsUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.Map.CarTipsUI",
    path = "/Game/BluePrints/UI/Map/CarTipsUIWidget.CarTipsUIWidget",
    uiStat = {name = "CarTipsUI"},
    isSingleton = false,
    zOrder = 1,
    isMainUI = false
  },
  CommonAirLineUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.Map.CommonAirLineUI",
    path = "/Game/BluePrints/UI/Map/CommonAirLineWidget.CommonAirLineWidget",
    uiStat = {
      name = "CommonAirLineUI"
    },
    isSingleton = false,
    zOrder = 1,
    isMainUI = false
  },
  CustomAirAttackAreaUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.Map.AirAttackAreaUI",
    path = "/Game/BluePrints/UI/Map/AirAttackAreaUIWidget.AirAttackAreaUIWidget",
    uiStat = {
      name = "CustomAirAttackAreaUI"
    },
    isSingleton = false,
    zOrder = 1,
    isMainUI = false,
    asy = true
  },
  CustomBlueCircleUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.Map.CustomBlueCircle",
    path = "/Game/BluePrints/UI/Map/BlueCircleWidget.BlueCircleWidget",
    uiStat = {
      name = "CustomBlueCircleUI"
    },
    isSingleton = false,
    zOrder = 1,
    isMainUI = false,
    asy = true
  },
  EntireMapTaskMenuBtn = {
    moduleName = "GameLua.Mod.BaseMod.Client.Map.EntireMapLeftPanel.EntireMapTaskMenuBtn",
    path = "/Game/BluePrints/UI/Map/LeftPanelItem/TaskMenuButton.TaskMenuButton",
    uiStat = {
      name = "EntireMapTaskMenuBtn"
    },
    isMainUI = false,
    closeOnHide = false,
    bPermanentDuringThisBattle = true,
    zOrder = 1,
    isSingleton = false,
    asy = true
  },
  EntireMapTaskItemContainerTrucksUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.Map.EntireMapLeftPanel.EntireMapLeftSubItemUI.EntireMapTaskItemContainerTrucksUI",
    path = "/Game/BluePrints/UI/Map/Item/EntireMapUI_TaskItem_ContainerTrucks_UIBP.EntireMapUI_TaskItem_ContainerTrucks_UIBP",
    uiStat = {
      name = "EntireMapTaskItemContainerTrucksUI"
    },
    isMainUI = false,
    closeOnHide = false,
    zOrder = 1,
    isSingleton = false
  },
  EntireMapTaskItemDetailsUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.Map.EntireMapLeftPanel.EntireMapLeftSubItemUI.EntireMapTaskItemDetailsUI",
    path = "/Game/BluePrints/UI/Map/Item/EntireMapUI_TaskItem_Details_UIBP.EntireMapUI_TaskItem_Details_UIBP",
    uiStat = {
      name = "EntireMapTaskItemDetailsUI"
    },
    isMainUI = false,
    closeOnHide = false,
    zOrder = 1,
    isSingleton = false
  },
  EntireMapTaskItemTipsUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.Map.EntireMapLeftPanel.EntireMapLeftSubItemUI.EntireMapTaskItemTipsUI",
    path = "/Game/BluePrints/UI/Map/Item/EntireMapUI_TaskItem_Tips_UIBP.EntireMapUI_TaskItem_Tips_UIBP",
    uiStat = {
      name = "EntireMapTaskItemTipsUI"
    },
    isMainUI = false,
    closeOnHide = false,
    zOrder = 1,
    isSingleton = false
  },
  EntireMapTaskItemTitleUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.Map.EntireMapLeftPanel.EntireMapLeftSubItemUI.EntireMapTaskItemTitleUI",
    path = "/Game/BluePrints/UI/Map/Item/EntireMapUI_TaskItem_Title_UIBP.EntireMapUI_TaskItem_Title_UIBP",
    uiStat = {
      name = "EntireMapTaskItemTitleUI"
    },
    isMainUI = false,
    closeOnHide = false,
    zOrder = 1,
    isSingleton = false
  },
  EntireMapVersionTaskItemDetailsUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.Map.EntireMapLeftPanel.EntireMapLeftSubItemUI.EntireMapVersionTaskItemDetailsUI",
    path = "/Game/Mod/EvoBase/BluePrints/UI/VersionTask/Item/EntireMapUI_Version_TaskItem_Details_UIBP.EntireMapUI_Version_TaskItem_Details_UIBP",
    uiStat = {
      name = "EntireMapVersionTaskItemDetailsUI"
    },
    isMainUI = false,
    closeOnHide = false,
    zOrder = 1,
    isSingleton = false
  },
  HighDropAreaUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.Map.HighDropAreaUI",
    path = "/Game/BluePrints/UI/Map/HighDropUIWidget.HighDropUIWidget",
    uiStat = {
      name = "HighDropAreaUI"
    },
    isSingleton = false,
    zOrder = 1,
    isMainUI = false,
    asy = true
  },
  InnerCircleUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.Map.InnerCircleUI",
    path = "/Game/BluePrints/UI/Map/InnerCircleWidget.InnerCircleWidget",
    uiStat = {
      name = "InnerCircleUI"
    },
    isSingleton = false,
    isMainUI = false,
    zOrder = 1
  },
  EntireMapPlayerIcon = {
    moduleName = "GameLua.Mod.BaseMod.Client.Map.MapMark.MapItem.MapPlayerIcon",
    path = "/Game/BluePrints/UI/Map/Item/EntireMapPlayerIconItem.EntireMapPlayerIconItem",
    uiStat = {
      name = "EntireMapPlayerIcon"
    },
    isSingleton = false,
    isMainUI = false,
    showVisibility = UEnums.ESlateVisibility.Collapsed
  },
  EntireMapPlayerMark = {
    moduleName = "GameLua.Mod.BaseMod.Client.Map.MapMark.MapItem.MapPlayerMark",
    path = "/Game/BluePrints/UI/Map/Item/EntireMapPlayerMarkItem.EntireMapPlayerMarkItem",
    uiStat = {
      name = "EntireMapPlayerMark"
    },
    isSingleton = false,
    isMainUI = false
  },
  MiniMapPlayerIcon = {
    moduleName = "GameLua.Mod.BaseMod.Client.Map.MapMark.MapItem.MapPlayerIcon",
    path = "/Game/BluePrints/UI/Map/Item/MiniMapPlayerIconItem.MiniMapPlayerIconItem",
    uiStat = {
      name = "MiniMapPlayerIcon"
    },
    isSingleton = false,
    isMainUI = false,
    showVisibility = UEnums.ESlateVisibility.Collapsed
  },
  MiniMapPlayerMark = {
    moduleName = "GameLua.Mod.BaseMod.Client.Map.MapMark.MapItem.MapPlayerMark",
    path = "/Game/BluePrints/UI/Map/Item/MiniMapPlayerMarkItem.MiniMapPlayerMarkItem",
    uiStat = {
      name = "MiniMapPlayerMark"
    },
    isSingleton = false,
    isMainUI = false
  },
  MapPlayerMultiMark = {
    moduleName = "GameLua.Mod.BaseMod.Client.Map.MapMark.MapItem.MapMultiMarkItem",
    path = "/Game/BluePrints/UI/Map/Item/MapMultiMarkItem.MapMultiMarkItem",
    uiStat = {
      name = "MapPlayerMultiMark"
    },
    isSingleton = false,
    isMainUI = false
  },
  EntireMapUAVIcon = {
    moduleName = "GameLua.Mod.BaseMod.Client.Map.MapMark.MapItem.MapUAVIcon",
    path = "/Game/Mod/EvoBase/BluePrints/UI/MapItem/EntireMapUAVIconItem.EntireMapUAVIconItem",
    uiStat = {
      name = "EntireMapUAVIcon"
    },
    isSingleton = false,
    isMainUI = false
  },
  MiniMapUAVIcon = {
    moduleName = "GameLua.Mod.BaseMod.Client.Map.MapMark.MapItem.MapUAVIcon",
    path = "/Game/Mod/EvoBase/BluePrints/UI/MapItem/MiniMapUAVIconItem.MiniMapUAVIconItem",
    uiStat = {
      name = "MiniMapUAVIcon"
    },
    isSingleton = false,
    isMainUI = false
  },
  MortarLineUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.Map.MortarLineUI",
    path = "/Game/BluePrints/UI/Map/MortarLineWidget.MortarLineWidget",
    uiStat = {
      name = "MortarLineUI"
    },
    isSingleton = false,
    zOrder = 1,
    asy = true,
    isMainUI = false
  },
  SecondAirLineUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.Map.SecondAirLineUI",
    path = "/Game/BluePrints/UI/Map/AirLineWidget.AirLineWidget",
    uiStat = {name = "Line2"},
    isSingleton = false,
    zOrder = 1,
    isMainUI = false
  },
  SecondAirLineUIOB = {
    moduleName = "GameLua.Mod.BaseMod.Client.Map.SecondAirLineUIOB",
    path = "/Game/BluePrints/UI/Map/AirLineWidgetOB.AirLineWidgetOB",
    uiStat = {name = "obLine2"},
    isSingleton = false,
    zOrder = 1,
    isMainUI = false
  },
  ReviveAirLineUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.Map.ReviveAirLineUI",
    path = "/Game/BluePrints/UI/Map/AirLineWidget.AirLineWidget",
    uiStat = {
      name = "ReviveAirLineUI"
    },
    isSingleton = false,
    zOrder = 1,
    isMainUI = false
  },
  ReviveAirLineUIOB = {
    moduleName = "GameLua.Mod.BaseMod.Client.Map.ReviveAirLineUIOB",
    path = "/Game/BluePrints/UI/Map/AirLineWidget.AirLineWidget",
    uiStat = {
      name = "ReviveAirLineUIOB"
    },
    isSingleton = false,
    zOrder = 1,
    isMainUI = false
  },
  ThemeTaskItemDetailsUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.Map.EntireMapLeftPanel.EntireMapLeftSubItemUI.ThemeTaskItemDetailsUI",
    path = "/Game/Mod/EvoBase/BluePrints/UI/ThemeTask/Item/Theme_TaskItem_Details_UIBP.Theme_TaskItem_Details_UIBP",
    uiStat = {
      name = "ThemeTaskItemDetailsUI"
    },
    isMainUI = false,
    closeOnHide = false,
    zOrder = 1,
    isSingleton = false
  },
  ThemeTaskButtonItemUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.Map.EntireMapLeftPanel.EntireMapLeftSubItemUI.ThemeTaskButtonItemUI",
    path = "/Game/Mod/EvoBase/BluePrints/UI/ThemeTask/Item/Theme_Task_Button_Item_UIBP.Theme_Task_Button_Item_UIBP",
    uiStat = {
      name = "ThemeTaskButtonItemUI"
    },
    isMainUI = false,
    closeOnHide = false,
    zOrder = 1,
    isSingleton = false
  }
}
return UIConfig_Map