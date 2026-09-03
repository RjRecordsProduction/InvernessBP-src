local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local EUIConfigPoolType = require("client.slua.config.ClientMacros.EUIConfigPoolType")
local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local UIConfig_Interactive = {
  DanceCameraButtonUI = {
    moduleName = "GameLua.Mod.Library.Client.UI.RobotDance.DanceCameraButtonUI",
    path = "/Game/Library/Res/Actors/RobotDance/BluePrints/UI/BP_DanceCameraButton.BP_DanceCameraButton",
    uiStat = {
      name = "DanceCameraButtonUI"
    },
    isMainUI = false,
    asy = true,
    zOrder = 1
  },
  ElevatorBoxUI = {
    moduleName = "GameLua.Mod.Library.Client.Elevator.ElevatorMainUI",
    path = "/Game/Mod/EvoBase/Blueprints/UI/Elevator/Elevator_UIBP.Elevator_UIBP",
    uiStat = {
      name = "ElevatorBoxUI"
    },
    zOrder = 0,
    asy = true
  },
  ElevatorFloorUI = {
    moduleName = "GameLua.Mod.Library.Client.Elevator.ElevatorRequestUI",
    path = "/Game/Mod/EvoBase/Blueprints/UI/Elevator/Elevator_Request_UIBP.Elevator_Request_UIBP",
    uiStat = {
      name = "ElevatorFloorUI"
    },
    zOrder = 0,
    asy = true
  },
  InteractiveUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.InteractiveUI",
    path = "/Game/Mod/EvoBase/BluePrints/UI/Interactive_UIBP.Interactive_UIBP",
    isSingleton = true,
    uiStat = {
      name = "InteractiveUI"
    },
    isMainUI = false,
    loadFromPool = EUIConfigPoolType.None,
    containerName = UIContainers.Bottom
  },
  LifterControlPanel = {
    moduleName = "GameLua.Mod.BaseMod.GamePlay.Actor.Lifter.LifterControlPanel",
    path = "/Game/Mod/EvoBase/Arts_PlayerBluePrints/Lifter/LifterControlPanel.LifterControlPanel",
    uiStat = {
      name = "LifterControlPanel"
    },
    zOrder = 0,
    isWindowsOBHide = true,
    mountPanel = {
      mountOuterName = "MainControlBaseUI",
      mountName = "CanvasPanel_42"
    },
    closeOnHide = false,
    isMainUI = false
  },
  MedievalCraneHandleInteractiveUI = {
    moduleName = "GameLua.Mod.Library.Client.UI.MedievalCrane.MedievalCraneHandleInteractiveUI",
    path = "/Game/Mod/EvoBase/BluePrints/UI/Interactive_UIBP.Interactive_UIBP",
    isSingleton = true,
    uiStat = {
      name = "MedievalCraneHandleInteractiveUI"
    },
    isMainUI = false,
    loadFromPool = EUIConfigPoolType.None,
    mountPanel = {
      mountOuterName = "MainControlBaseUI",
      mountName = "CanvasPanel_42"
    }
  },
  MedievalCraneInteractiveUI = {
    moduleName = "GameLua.Mod.Library.Client.UI.MedievalCrane.MedievalCraneInteractiveUI",
    path = "/Game/Mod/EvoBase/BluePrints/UI/InteractUI/MedievalCrane/BP_MedievalCraneInteractiveUI.BP_MedievalCraneInteractiveUI",
    isSingleton = true,
    uiStat = {
      name = "MedievalCraneInteractiveUI"
    },
    zOrder = 0,
    closeOnHide = false,
    isMainUI = false,
    asy = true,
    mountPanel = {
      mountOuterName = "MainControlBaseUI",
      mountName = "CanvasPanel_42"
    }
  },
  OptionalGarageUI = {
    moduleName = "GameLua.Mod.BaseMod.Client.OptionalGarage.OptionalGarageUI",
    path = "/Game/Library/Res/Actors/OptionalGarage/BluePrints/OptionalGarage_Vehicle_UIBP.OptionalGarage_Vehicle_UIBP",
    isMainUI = true,
    isAndroidBack = true,
    isWindowsOBHide = false,
    zOrder = 60,
    isSingleton = true,
    uiStat = {
      name = "OptionalGarageUI"
    },
    asy = true,
    containerName = UIContainers.Top
  }
}
return UIConfig_Interactive