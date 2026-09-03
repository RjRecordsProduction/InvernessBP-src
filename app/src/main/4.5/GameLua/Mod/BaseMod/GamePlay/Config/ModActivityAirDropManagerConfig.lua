local ModActivityAirDropManagerConfig = {
  EffectMap = {
    Baltic = false,
    Livik = false,
    DihorOtok = false,
    Savage = false,
    Desert = false,
    Neon = false,
    Karakin = false,
    Borderland = false
  },
  EffectMainMap = {
    Baltic_Main = false,
    FourMaps_Main = false,
    PUBG_Desert = false,
    PUBG_Savage_Main = false,
    PUBG_4Anniversary_ResultAvatar = false,
    PUBG_Summerland_Mian = false,
    Sink_Main = false,
    DihorOtok_Main = false,
    PUBG_Borderland_Main = false,
    PUBG_Neon_Main = false
  },
  DisableModeID = {
    [1070] = true,
    [1071] = true,
    [1072] = true,
    [1094] = true,
    [1095] = true,
    [1096] = true,
    [20007] = true,
    [20008] = true,
    [20009] = true,
    [880047] = true,
    [880050] = true,
    [64943] = true,
    [64946] = true,
    [64949] = true,
    [64952] = true,
    [64955] = true,
    [64958] = true
  },
  ModActivityAirDropInfo = {
    Baltic = {
      AcitvityStartTime = "2024-07-25 02:00:00",
      AcitvityStopTime = "2025-08-18 00:00:00",
      ModifyAirDropIndexes = {1, 2},
      RandomDroppingRangeMin = -0.8,
      RandomDroppingRangeMax = -0.3,
      ExtraAirDropRandLowerLimit = 100000.0,
      ExtraAirDropRandUpperLimit = 250000.0,
      bShowAirLineAndMark = true,
      ExtraAirDropRandParamsArray = {
        [1] = {TotalDropCount = 2, TermWeight = 100}
      }
    },
    Livik = {
      AcitvityStartTime = "2024-07-25 02:00:00",
      AcitvityStopTime = "2025-08-18 00:00:00",
      ModifyAirDropIndexes = {0},
      RandomDroppingRangeMin = -0.8,
      RandomDroppingRangeMax = -0.3,
      ExtraAirDropRandLowerLimit = 50000.0,
      ExtraAirDropRandUpperLimit = 10000.0,
      bShowAirLineAndMark = true,
      ExtraAirDropRandParamsArray = {
        [1] = {TotalDropCount = 2, TermWeight = 100}
      }
    },
    Savage = {
      AcitvityStartTime = "2024-07-25 02:00:00",
      AcitvityStopTime = "2025-08-18 00:00:00",
      ModifyAirDropIndexes = {0},
      RandomDroppingRangeMin = -0.8,
      RandomDroppingRangeMax = -0.3,
      ExtraAirDropRandLowerLimit = 70000.0,
      ExtraAirDropRandUpperLimit = 120000.0,
      bShowAirLineAndMark = true,
      ExtraAirDropRandParamsArray = {
        [1] = {TotalDropCount = 2, TermWeight = 100}
      }
    },
    DihorOtok = {
      AcitvityStartTime = "2024-07-25 02:00:00",
      AcitvityStopTime = "2025-08-18 00:00:00",
      ModifyAirDropIndexes = {1},
      RandomDroppingRangeMin = -0.8,
      RandomDroppingRangeMax = -0.3,
      ExtraAirDropRandLowerLimit = 100000.0,
      ExtraAirDropRandUpperLimit = 250000.0,
      bShowAirLineAndMark = true,
      ExtraAirDropRandParamsArray = {
        [1] = {TotalDropCount = 2, TermWeight = 100}
      }
    },
    Desert = {
      AcitvityStartTime = "2024-07-25 02:00:00",
      AcitvityStopTime = "2025-08-18 00:00:00",
      ModifyAirDropIndexes = {1},
      RandomDroppingRangeMin = -0.8,
      RandomDroppingRangeMax = -0.3,
      ExtraAirDropRandLowerLimit = 100000.0,
      ExtraAirDropRandUpperLimit = 250000.0,
      bShowAirLineAndMark = true,
      ExtraAirDropRandParamsArray = {
        [1] = {TotalDropCount = 2, TermWeight = 100}
      }
    },
    Neon = {
      AcitvityStartTime = "2024-07-25 02:00:00",
      AcitvityStopTime = "2025-08-18 00:00:00",
      ModifyAirDropIndexes = {1},
      RandomDroppingRangeMin = -0.8,
      RandomDroppingRangeMax = -0.3,
      ExtraAirDropRandLowerLimit = 100000.0,
      ExtraAirDropRandUpperLimit = 250000.0,
      bShowAirLineAndMark = true,
      ExtraAirDropRandParamsArray = {
        [1] = {TotalDropCount = 2, TermWeight = 100}
      }
    },
    Karakin = {
      AcitvityStartTime = "2024-07-25 02:00:00",
      AcitvityStopTime = "2025-08-18 00:00:00",
      ModifyAirDropIndexes = {0},
      RandomDroppingRangeMin = -0.8,
      RandomDroppingRangeMax = -0.3,
      ExtraAirDropRandLowerLimit = 30000.0,
      ExtraAirDropRandUpperLimit = 50000.0,
      bShowAirLineAndMark = true,
      ExtraAirDropRandParamsArray = {
        [1] = {TotalDropCount = 2, TermWeight = 100}
      }
    },
    Borderland = {
      AcitvityStartTime = "2024-07-25 02:00:00",
      AcitvityStopTime = "2025-08-18 00:00:00",
      ModifyAirDropIndexes = {0},
      RandomDroppingRangeMin = -0.8,
      RandomDroppingRangeMax = -0.3,
      ExtraAirDropRandLowerLimit = 30000.0,
      ExtraAirDropRandUpperLimit = 50000.0,
      bShowAirLineAndMark = true,
      ExtraAirDropRandParamsArray = {
        [1] = {TotalDropCount = 2, TermWeight = 100}
      }
    }
  }
}
return ModActivityAirDropManagerConfig