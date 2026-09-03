local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local EUIConfigPoolType = require("client.slua.config.ClientMacros.EUIConfigPoolType")
local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local UIConfig_Props = {
  GrenadeChooseWidgetNew = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.NewCircleChooseUI.CircleChooseGrenadeNew",
    path = "/Game/BluePrints/ControlInput/CircleChooseWidget/RingThrowButUI_UIBP.RingThrowButUI_UIBP",
    uiStat = {
      name = "GrenadeChooseWidgetNew"
    },
    containerName = UIContainers.Default,
    closeOnHide = false,
    isSingleton = true,
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Skip
  },
  GrenadeMarkerItemUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.GrenadeMarker.GrenadeMarkerItemUI",
    path = "/Game/Mod/EvoBase/BluePrints/UIBP/GrenadeTips/GrenadeMarkerItem_UIBP.GrenadeMarkerItem_UIBP",
    uiStat = {
      name = "GrenadeMarkerItemUI"
    },
    isWindowsOBHide = false,
    closeOnHide = false,
    isMainUI = false
  },
  GrenadeMarkerUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.GrenadeMarker.GrenadeMarkerUI",
    path = "/Game/Mod/EvoBase/BluePrints/UIBP/GrenadeTips/GrenadeMarkerList_UIBP.GrenadeMarkerList_UIBP",
    uiStat = {
      name = "GrenadeMarkerUI"
    },
    isWindowsOBHide = false,
    closeOnHide = false,
    isMainUI = false
  },
  ThrowTimeInfoPanel = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.ThrowTimeInfoPanel",
    path = "/Game/BluePrints/ControlInput/ThrowTimeInfoPanel.ThrowTimeInfoPanel",
    uiStat = {
      name = "ThrowTimeInfoPanel"
    },
    containerName = UIContainers.Bottom,
    asy = true,
    isMainUI = false
  },
  CircleChooseAnnex = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.NewCircleChooseUI.CircleChooseAnnex",
    path = "/Game/BluePrints/ControlInput/CircleChooseWidget/RingThrow_Annex.RingThrow_Annex",
    uiStat = {
      name = "CircleChooseAnnex"
    },
    containerName = UIContainers.Default,
    isSingleton = false,
    asy = true
  },
  CircleGrenadeItem = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.NewCircleChooseUI.CirCleGrenadeItemTEST",
    path = "/Game/BluePrints/ControlInput/CircleChooseWidget/WheelWidget_UIBP.WheelWidget_UIBP",
    uiStat = {
      name = "CircleGrenadeItem"
    },
    containerName = UIContainers.Default,
    isSingleton = false,
    closeOnHide = false
  },
  GrenadeListBox = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.NewCircleChooseUI.GrenadesListPanel",
    path = "/Game/BluePrints/ControlInput/CircleChooseWidget/GrenadesItemBox_UIBP.GrenadesItemBox_UIBP",
    uiStat = {
      name = "GrenadeListBox"
    },
    containerName = UIContainers.Default,
    isSingleton = false
  },
  GrenadeListItem = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.NewCircleChooseUI.GrenadeListItemBP",
    path = "/Game/BluePrints/ControlInput/CircleChooseWidget/GrenadeListItem_UIBP.GrenadeListItem_UIBP",
    uiStat = {
      name = "GrenadeListItem"
    },
    containerName = UIContainers.Default,
    isSingleton = false
  },
  ThemePropItemBP = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.NewCircleChooseUI.ThemePropItemBP",
    path = "/Game/BluePrints/ControlInput/CircleChooseWidget/ThemeProp_UIBP.ThemeProp_UIBP",
    uiStat = {
      name = "ThemePropItemBP"
    },
    containerName = UIContainers.Default,
    isSingleton = false,
    asy = true
  }
}
return UIConfig_Props