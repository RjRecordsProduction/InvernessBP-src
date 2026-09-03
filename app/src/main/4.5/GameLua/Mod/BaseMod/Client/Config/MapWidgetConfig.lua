local Config = {
  AirLineWidget = {UIConfig = "AirLineUI"},
  ReviveAirLineWidget = {
    UIConfig = "ReviveAirLineUI"
  },
  AirAttarAreaWidget = {
    UIConfig = "AirAttackAreaUI",
    MapUIEvents = {
      "RedrawAirAttackArea"
    }
  },
  HighDropWidget = {
    UIConfig = "HighDropAreaUI",
    MapUIEvents = {
      "RedrawHighDropArea"
    }
  },
  BlueWidget = {
    UIConfig = "BlueCircleUI",
    MapUIEvents = {
      "OnSyncCircleInfo",
      "OnRefreshMapIcon"
    }
  },
  CarTipsWidget = {
    UIConfig = "CarTipsUI",
    MapUIEvents = {
      "OnPlayerLeaveVehicle"
    }
  },
  CustomBlueWidget = {
    UIConfig = "CustomBlueCircleUI",
    MapUIEvents = {
      "OnReceivedCustomBlueCircle"
    },
    CloseEvents = {
      "OnCloseCustomBlueWidget"
    }
  },
  InnerCircleWidget = {
    UIConfig = "InnerCircleUI",
    MapUIEvents = {
      "NeedInnerCircle"
    }
  },
  CustomAirAttackAreaWidget = {
    UIConfig = "CustomAirAttackAreaUI",
    MapUIEvents = {
      "RedrawCustomAirAttackArea"
    }
  }
}
return Config