local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local EUIConfigPoolType = require("client.slua.config.ClientMacros.EUIConfigPoolType")
local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local UIConfig_Activity = {
  BornIsland_RedPacket_UIBP = {
    moduleName = "GameLua.Activity.IG2000.Client.UI.BornIsland_RedPacket_UIBP",
    path = "/Game/UMG/UI_BP/Common/BornIsland_RedPacket_UIBP.BornIsland_RedPacket_UIBP",
    containerName = UIContainers.Default,
    zOrder = 1,
    uiStat = {
      name = "BornIsland_RedPacket_UIBP"
    },
    isMainUI = false,
    loadFromPool = EUIConfigPoolType.None
  },
  BikeWithRackValentineUI = {
    moduleName = "GameLua.Mod.Library.Client.BikeWithRack.BikeWithRackValentineUI",
    path = "/Game/Arts/UI/UI_Particle/ValentinesDay_300_Heart_UIBP.ValentinesDay_300_Heart_UIBP",
    uiStat = {
      name = "BikeWithRackValentineUI"
    },
    zOrder = 0,
    asy = true,
    isSingleton = true,
    containerName = UIContainers.Default
  },
  SnowEffectUI = {
    moduleName = "GameLua.Mod.Library.Client.UI.SnowEffectUI",
    path = "/Game/Library/Res/Actors/Festival/BluePrints/IceWorld4_ScreenEffect_ChristmasSnow_UIBP.IceWorld4_ScreenEffect_ChristmasSnow_UIBP",
    isMainUI = false,
    asy = true,
    loadFromPool = EUIConfigPoolType.None,
    uiStat = {
      name = "SnowEffectUI"
    },
    containerName = UIContainers.Top
  },
  WorldCup_RedPacket_UIBP = {
    moduleName = "GameLua.Activity.IG2000.Client.UI.BornIsland_RedPacket_UIBP",
    path = "/Game/Arts_UI/AFD/2300/BornlslandRedpacket/UIBP/WorldCup_Popup_UIBP.WorldCup_Popup_UIBP",
    containerName = UIContainers.Default,
    zOrder = 1,
    uiStat = {
      name = "WorldCup_RedPacket_UIBP"
    },
    isMainUI = false
  },
  NewYearFireworkTipsUI = {
    moduleName = "GameLua.Mod.Library.Client.UI.NewYearFireworkTipsUI",
    path = "/Game/Library/Res/Actors/HappyNewYear/UI/FireworksGala_Tips_UIBP.FireworksGala_Tips_UIBP",
    isSingleton = true,
    uiStat = {
      name = "NewYearFireworkTipsUI"
    },
    asy = true,
    isMainUI = false,
    containerName = UIContainers.Top
  },
  SnowHouseEnterTipsUI = {
    moduleName = "GameLua.Mod.Library.Client.UI.SnowHouseEnterTips",
    path = "/Game/Library/Res/Actors/Festival/BluePrints/Ice_Tips_UIBP.Ice_Tips_UIBP",
    isSingleton = true,
    uiStat = {
      name = "SnowHouseEnterTipsUI"
    },
    isMainUI = false,
    containerName = UIContainers.Top,
    asy = true,
    showVisibility = UEnums.ESlateVisibility.HitTestInvisible,
    zOrder = 10000
  },
  RaceCarStartOrEndUI = {
    moduleName = "GameLua.Mod.Library.Client.UI.RaceCar.RaceCarStartOrEndUI",
    path = "/Game/Library/Res/Actors/RaceCar/BluePrints/RaceCarStartOrEnd_UIBP_Temp.RaceCarStartOrEnd_UIBP_Temp",
    isSingleton = true,
    uiStat = {
      name = "RaceCarStartOrEndUI"
    },
    isMainUI = false,
    loadFromPool = EUIConfigPoolType.None,
    containerName = UIContainers.Bottom
  },
  RaceCarInfoUI = {
    moduleName = "GameLua.Mod.Library.Client.UI.RaceCar.RaceCarInfoUI",
    path = "/Game/Mod/ZNQ8th/BluePrints/UI/Tips/RacingTips.RacingTips",
    isSingleton = true,
    uiStat = {
      name = "RaceCarInfoUI"
    },
    isMainUI = false,
    loadFromPool = EUIConfigPoolType.None,
    containerName = UIContainers.Bottom
  },
  RaceCarCountdownUI = {
    moduleName = "GameLua.Mod.Library.Client.UI.RaceCar.RaceCarCountdownUI",
    path = "/Game/Mod/ZNQ8th/BluePrints/UI/Tips/RacingTips02_UIBP.RacingTips02_UIBP",
    isSingleton = true,
    uiStat = {
      name = "RaceCarCountdownUI"
    },
    isMainUI = false,
    loadFromPool = EUIConfigPoolType.None,
    containerName = UIContainers.Bottom
  },
  RaceCarFinishUI = {
    moduleName = "GameLua.Mod.Library.Client.UI.RaceCar.RaceCarFinishUI",
    path = "/Game/Mod/ZNQ8th/BluePrints/UI/Tips/RacingTips01_UIBP.RacingTips01_UIBP",
    isSingleton = true,
    uiStat = {
      name = "RaceCarFinishUI"
    },
    isMainUI = false,
    loadFromPool = EUIConfigPoolType.None,
    containerName = UIContainers.Bottom
  },
  TeamActivityInteractUI = {
    moduleName = "GameLua.Mod.Library.Client.UI.TeamActivityInteractUI",
    path = "/Game/Mod/EvoBase/BluePrints/UI/InteractUI/TeamActivityInteract_UIBP.TeamActivityInteract_UIBP",
    isSingleton = true,
    uiStat = {
      name = "TeamActivityInteractUI"
    },
    isMainUI = false,
    loadFromPool = EUIConfigPoolType.None
  }
}
return UIConfig_Activity