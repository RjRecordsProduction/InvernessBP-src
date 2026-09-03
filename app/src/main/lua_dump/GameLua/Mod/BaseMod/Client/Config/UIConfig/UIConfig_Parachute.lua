local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local EUIConfigPoolType = require("client.slua.config.ClientMacros.EUIConfigPoolType")
local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local UIConfig_Parachute = {
  AutoParachuteUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.AutoParachute.AutoParachuteUI",
    path = "/Game/Mod/EvoBase/BluePrints/UIBP/AutomaticParachuting/Parachuting_UIBP.Parachuting_UIBP",
    uiStat = {
      name = "AutoParachuteUI"
    },
    zOrder = 0,
    closeOnHide = true,
    loadFromPool = EUIConfigPoolType.None,
    isMainUI = false
  },
  BattlePass02 = {
    moduleName = "GameLua.Mod.BaseMod.Client.BattlePassCoatingMes02ItemUI.BattlePassCoatingMes02ItemUI",
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
  ParachuteOpenUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.InGameUI.ParachuteOpenUI",
    path = "/Game/UMG/UI_BP/Setting/Setting_Skill_Skydiver_UIBP.Setting_Skill_Skydiver_UIBP",
    uiStat = {
      name = "ParachuteOpenUI"
    },
    closeOnHide = false,
    isMainUI = false,
    asy = true
  },
  PlaneShowAliasEnterBroadcastUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.PlaneShow.PlaneShowAliasEnterBroadcastUI",
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
    moduleName = "GameLua.Mod.BaseMod.Client.PlaneShow.PlaneShowBestViewUI",
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
    moduleName = "GameLua.Mod.BaseMod.Client.PlaneShow.PlaneShowCloseUI",
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
    moduleName = "GameLua.Mod.BaseMod.Client.PlaneShow.PlaneShowSkinTipsUI",
    path = "/Game/BluePrints/UI/PlaneShow/PlaneShow_Tips.PlaneShow_Tips",
    isMainUI = false,
    asy = true,
    loadFromPool = EUIConfigPoolType.None,
    uiStat = {
      name = "PlaneShowSkinTipsUI"
    },
    containerName = UIContainers.Top
  }
}
return UIConfig_Parachute