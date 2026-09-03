local PetConfig = {
  WORKSHOP_BIG_PET_POSITION = {
    -10000,
    -404,
    -14433.0
  }
}
PetConfig.AttachSocketName = {
  DEFAULT = "DEFAULT",
  PARACHUTE = "Parachute_Socket"
}
PetConfig.HighPerformanceSystem = {
  "pet_main",
  "ItemPreview_UIBP",
  "NewStoreSystem",
  "GiveStoreSystem",
  "NewSupplySystemJK"
}
PetConfig.FullScreenUIList = {
  "ActivityCenter_Main_UIBP",
  "egame_center",
  "Assembly_Main_UIBP",
  "Lobby_SeasonUI_Homepage_New01_Sidebar_UIBP",
  "mode_selection_main",
  "Mail_UIBP"
}
PetConfig.EDeviceBasicLOD = {HIGH_DEVICE = 0, LOW_DEVICE = 1}
PetConfig.TwoPassPets = {
  [ENUM_LOBBYPET_TYPE.TYPE_PORO] = true,
  [ENUM_LOBBYPET_TYPE.TYPE_LITTLECAT] = true,
  [ENUM_LOBBYPET_TYPE.TYPE_LITTLEDOG] = true,
  [ENUM_LOBBYPET_TYPE.TYPE_WOLF] = true,
  [ENUM_LOBBYPET_TYPE.TYPE_GIANT_PANDA] = true
}
PetConfig.EPetState = {
  IDLE = 1,
  WALK = 2,
  RUN = 3,
  SWIM = 4,
  PARACHUTE = 5
}
PetConfig.BaseAttachBiasList = {
  Default = {
    position = {
      x = 0,
      y = -60,
      z = 1
    },
    rotation = {
      x = 0,
      y = 0,
      z = -90
    }
  },
  [ENUM_LOBBYPET_TYPE.TYPE_MINI_TV] = {
    position = {
      x = 50,
      y = 0,
      z = 0
    },
    rotation = {
      x = 0,
      y = 0,
      z = 0
    }
  },
  [ENUM_LOBBYPET_TYPE.TYPE_DOG] = {
    position = {
      x = 50,
      y = 0,
      z = -91
    },
    rotation = {
      x = 0,
      y = 0,
      z = 90
    }
  },
  [ENUM_LOBBYPET_TYPE.TYPE_LITTLECAT] = {
    position = {
      x = 0,
      y = -70,
      z = 1
    },
    rotation = {
      x = 0,
      y = 0,
      z = -90
    }
  },
  [ENUM_LOBBYPET_TYPE.TYPE_LITTLEDOG] = {
    position = {
      x = 0,
      y = -70,
      z = 1
    },
    rotation = {
      x = 0,
      y = 0,
      z = -90
    }
  },
  [ENUM_LOBBYPET_TYPE.TYPE_SCARECROW] = {
    position = {
      x = 0,
      y = -70,
      z = 1
    },
    rotation = {
      x = 0,
      y = 0,
      z = -90
    }
  },
  [ENUM_LOBBYPET_TYPE.TYPE_WOLF] = {
    position = {
      x = 0,
      y = -70,
      z = 1
    },
    rotation = {
      x = 0,
      y = 0,
      z = -90
    }
  },
  [ENUM_LOBBYPET_TYPE.TYPE_LION] = {
    position = {
      x = -20,
      y = -70,
      z = 1
    },
    rotation = {
      x = 0,
      y = 0,
      z = -90
    }
  },
  [ENUM_LOBBYPET_TYPE.TYPE_GHIDORAH] = {
    position = {
      x = 0,
      y = -50,
      z = 1
    },
    rotation = {
      x = 0,
      y = 0,
      z = -90
    }
  }
}
local ConstAvatarDislay = require("client.slua.traits.DetailComponent.AvatarDisplay.ConstAvatarDislay")
PetConfig.SceneShowPosOffset = {
  [ConstAvatarDislay.ESceneType.SmallRP300] = {
    x = 0,
    y = 20,
    z = 40
  },
  [ConstAvatarDislay.ESceneType.PeakGameRank] = {
    x = -10,
    y = 10,
    z = 0
  }
}
PetConfig.AttachBiasListForTheme = {
  ["202408061_3"] = {
    Default = {
      position = {
        x = -40,
        y = -60,
        z = 1
      },
      rotation = {
        x = 0,
        y = 0,
        z = -90
      }
    },
    [ENUM_LOBBYPET_TYPE.TYPE_MINI_TV] = {
      position = {
        x = 50,
        y = 0,
        z = 0
      },
      rotation = {
        x = 0,
        y = 0,
        z = 0
      }
    },
    [ENUM_LOBBYPET_TYPE.TYPE_DOG] = {
      position = {
        x = 50,
        y = 0,
        z = -91
      },
      rotation = {
        x = 0,
        y = 0,
        z = 90
      }
    },
    [ENUM_LOBBYPET_TYPE.TYPE_LITTLECAT] = {
      position = {
        x = -40,
        y = -70,
        z = 1
      },
      rotation = {
        x = 0,
        y = 0,
        z = -90
      }
    },
    [ENUM_LOBBYPET_TYPE.TYPE_LITTLEDOG] = {
      position = {
        x = -40,
        y = -70,
        z = 1
      },
      rotation = {
        x = 0,
        y = 0,
        z = -90
      }
    },
    [ENUM_LOBBYPET_TYPE.TYPE_SCARECROW] = {
      position = {
        x = -40,
        y = -70,
        z = 1
      },
      rotation = {
        x = 0,
        y = 0,
        z = -90
      }
    },
    [ENUM_LOBBYPET_TYPE.TYPE_WOLF] = {
      position = {
        x = -40,
        y = -70,
        z = 1
      },
      rotation = {
        x = 0,
        y = 0,
        z = -90
      }
    },
    [ENUM_LOBBYPET_TYPE.TYPE_LION] = {
      position = {
        x = -60,
        y = -70,
        z = 1
      },
      rotation = {
        x = 0,
        y = 0,
        z = -90
      }
    }
  }
}
PetConfig.ParachuteBiasList = {}
PetConfig.SwimBiasList = {
  Default = 80,
  [ENUM_LOBBYPET_TYPE.TYPE_WOLF] = 95,
  [ENUM_LOBBYPET_TYPE.TYPE_KARIN] = 40
}
PetConfig.LeftAvatarPetPositionDefault = {
  x = -50,
  y = 75,
  z = 1
}
PetConfig.RightAvatarPetPositionDefault = {
  x = -40,
  y = -40,
  z = 1
}
PetConfig.LeftAvatarPetPositionForRankDefault = {
  x = -50,
  y = 52,
  z = 1
}
PetConfig.RightAvatarPetPositionForRankDefault = {
  x = -40,
  y = -40,
  z = 1
}
PetConfig.ColorConfig = {
  [1] = {
    HighDeviceMaterials = {
      [0] = "/Game/Res/IG2500/Arts_Player/Pet/Pet_int_054/Mat/M_Pet_Cloth_int_054_Outter_1.M_Pet_Cloth_int_054_Outter_1",
      [1] = "/Game/Res/IG2500/Arts_Player/Pet/Pet_int_054/Mat/M_Pet_Cloth_int_054_1.M_Pet_Cloth_int_054_1",
      [2] = "/Game/Res/IG2500/Arts_Player/Pet/Pet_int_054/Mat/M_Pet_Cloth_int_054_Off_Logo.M_Pet_Cloth_int_054_Off_Logo",
      [3] = "/Game/Res/IG2500/Arts_Player/Pet/Pet_int_054/Mat/M_Pet_Cloth_int_054_Inside_1.M_Pet_Cloth_int_054_Inside_1"
    },
    LowDeviceMaterial = "/Game/Res/IG2500/Arts_Player/Pet/Pet_int_054/Mat/M_Pet_Cloth_int_054_1_Low.M_Pet_Cloth_int_054_1_Low"
  },
  [2] = {
    HighDeviceMaterials = {
      [0] = "/Game/Res/IG2500/Arts_Player/Pet/Pet_int_054/Mat/M_Pet_Cloth_int_054_Outter_1.M_Pet_Cloth_int_054_Outter_1",
      [1] = "/Game/Res/IG2500/Arts_Player/Pet/Pet_int_054/Mat/M_Pet_Cloth_int_054_2.M_Pet_Cloth_int_054_2",
      [2] = "/Game/Res/IG2500/Arts_Player/Pet/Pet_int_054/Mat/M_Pet_Cloth_int_054_On_Logo.M_Pet_Cloth_int_054_On_Logo",
      [3] = "/Game/Res/IG2500/Arts_Player/Pet/Pet_int_054/Mat/M_Pet_Cloth_int_054_Inside_1.M_Pet_Cloth_int_054_Inside_1"
    },
    LowDeviceMaterial = "/Game/Res/IG2500/Arts_Player/Pet/Pet_int_054/Mat/M_Pet_Cloth_int_054_2_Low.M_Pet_Cloth_int_054_2_Low"
  },
  [3] = {
    HighDeviceMaterials = {
      [0] = "/Game/Res/IG2500/Arts_Player/Pet/Pet_int_054/Mat/M_Pet_Cloth_int_054_Outter_1.M_Pet_Cloth_int_054_Outter_1",
      [1] = "/Game/Res/IG2500/Arts_Player/Pet/Pet_int_054/Mat/M_Pet_Cloth_int_054_3.M_Pet_Cloth_int_054_3",
      [2] = "/Game/Res/IG2500/Arts_Player/Pet/Pet_int_054/Mat/M_Pet_Cloth_int_054_On_Logo.M_Pet_Cloth_int_054_On_Logo",
      [3] = "/Game/Res/IG2500/Arts_Player/Pet/Pet_int_054/Mat/M_Pet_Cloth_int_054_Inside_1.M_Pet_Cloth_int_054_Inside_1"
    },
    LowDeviceMaterial = "/Game/Res/IG2500/Arts_Player/Pet/Pet_int_054/Mat/M_Pet_Cloth_int_054_3_Low.M_Pet_Cloth_int_054_3_Low"
  },
  [4] = {
    HighDeviceMaterials = {
      [0] = "/Game/Res/IG2500/Arts_Player/Pet/Pet_int_054/Mat/M_Pet_Cloth_int_054_Outter_4.M_Pet_Cloth_int_054_Outter_4",
      [1] = "/Game/Res/IG2500/Arts_Player/Pet/Pet_int_054/Mat/M_Pet_Cloth_int_054_4.M_Pet_Cloth_int_054_4",
      [2] = "/Game/Res/IG2500/Arts_Player/Pet/Pet_int_054/Mat/M_Pet_Cloth_int_054_Off_Logo.M_Pet_Cloth_int_054_Off_Logo",
      [3] = "/Game/Res/IG2500/Arts_Player/Pet/Pet_int_054/Mat/M_Pet_Cloth_int_054_Inside_4.M_Pet_Cloth_int_054_Inside_4"
    },
    LowDeviceMaterial = "/Game/Res/IG2500/Arts_Player/Pet/Pet_int_054/Mat/M_Pet_Cloth_int_054_4_Low.M_Pet_Cloth_int_054_4_Low"
  },
  [5] = {
    HighDeviceMaterials = {
      [0] = "/Game/Res/IG2500/Arts_Player/Pet/Pet_int_054/Mat/M_Pet_Cloth_int_054_Outter_4.M_Pet_Cloth_int_054_Outter_4",
      [1] = "/Game/Res/IG2500/Arts_Player/Pet/Pet_int_054/Mat/M_Pet_Cloth_int_054_4.M_Pet_Cloth_int_054_4",
      [2] = "/Game/Res/IG2500/Arts_Player/Pet/Pet_int_054/Mat/M_Pet_Cloth_int_054_On_Logo_2.M_Pet_Cloth_int_054_On_Logo_2",
      [3] = "/Game/Res/IG2500/Arts_Player/Pet/Pet_int_054/Mat/M_Pet_Cloth_int_054_Inside_4.M_Pet_Cloth_int_054_Inside_4"
    },
    LowDeviceMaterial = "/Game/Res/IG2500/Arts_Player/Pet/Pet_int_054/Mat/M_Pet_Cloth_int_054_5_Low.M_Pet_Cloth_int_054_5_Low"
  },
  [6] = {
    HighDeviceMaterials = {
      [0] = "/Game/Res/IG2500/Arts_Player/Pet/Pet_int_054/Mat/M_Pet_Cloth_int_054_Outter_4.M_Pet_Cloth_int_054_Outter_4",
      [1] = "/Game/Res/IG2500/Arts_Player/Pet/Pet_int_054/Mat/M_Pet_Cloth_int_054_6.M_Pet_Cloth_int_054_6",
      [2] = "/Game/Res/IG2500/Arts_Player/Pet/Pet_int_054/Mat/M_Pet_Cloth_int_054_On_Logo_2.M_Pet_Cloth_int_054_On_Logo_2",
      [3] = "/Game/Res/IG2500/Arts_Player/Pet/Pet_int_054/Mat/M_Pet_Cloth_int_054_Inside_4.M_Pet_Cloth_int_054_Inside_4"
    },
    LowDeviceMaterial = "/Game/Res/IG2500/Arts_Player/Pet/Pet_int_054/Mat/M_Pet_Cloth_int_054_6_Low.M_Pet_Cloth_int_054_6_Low"
  },
  [7] = {
    HighDeviceMaterials = {
      [0] = "/Game/Res/IG2500/Arts_Player/Pet/Pet_int_054/Mat/M_Pet_Cloth_int_054_Outter_7.M_Pet_Cloth_int_054_Outter_7",
      [1] = "/Game/Res/IG2500/Arts_Player/Pet/Pet_int_054/Mat/M_Pet_Cloth_int_054_7.M_Pet_Cloth_int_054_7",
      [2] = "/Game/Res/IG2500/Arts_Player/Pet/Pet_int_054/Mat/M_Pet_Cloth_int_054_Off_Logo.M_Pet_Cloth_int_054_Off_Logo",
      [3] = "/Game/Res/IG2500/Arts_Player/Pet/Pet_int_054/Mat/M_Pet_Cloth_int_054_Inside_7.M_Pet_Cloth_int_054_Inside_7"
    },
    LowDeviceMaterial = "/Game/Res/IG2500/Arts_Player/Pet/Pet_int_054/Mat/M_Pet_Cloth_int_054_7_Low.M_Pet_Cloth_int_054_7_Low"
  },
  [8] = {
    HighDeviceMaterials = {
      [0] = "/Game/Res/IG2500/Arts_Player/Pet/Pet_int_054/Mat/M_Pet_Cloth_int_054_Outter_8.M_Pet_Cloth_int_054_Outter_8",
      [1] = "/Game/Res/IG2500/Arts_Player/Pet/Pet_int_054/Mat/M_Pet_Cloth_int_054_8.M_Pet_Cloth_int_054_8",
      [2] = "/Game/Res/IG2500/Arts_Player/Pet/Pet_int_054/Mat/M_Pet_Cloth_int_054_On_Logo.M_Pet_Cloth_int_054_On_Logo",
      [3] = "/Game/Res/IG2500/Arts_Player/Pet/Pet_int_054/Mat/M_Pet_Cloth_int_054_Inside_8.M_Pet_Cloth_int_054_Inside_8"
    },
    LowDeviceMaterial = "/Game/Res/IG2500/Arts_Player/Pet/Pet_int_054/Mat/M_Pet_Cloth_int_054_8_Low.M_Pet_Cloth_int_054_8_Low"
  },
  [9] = {
    HighDeviceMaterials = {
      [0] = "/Game/Res/IG2500/Arts_Player/Pet/Pet_int_054/Mat/M_Pet_Cloth_int_054_Outter_9.M_Pet_Cloth_int_054_Outter_9",
      [1] = "/Game/Res/IG2500/Arts_Player/Pet/Pet_int_054/Mat/M_Pet_Cloth_int_054_9.M_Pet_Cloth_int_054_9",
      [2] = "/Game/Res/IG2500/Arts_Player/Pet/Pet_int_054/Mat/M_Pet_Cloth_int_054_On_Logo.M_Pet_Cloth_int_054_On_Logo",
      [3] = "/Game/Res/IG2500/Arts_Player/Pet/Pet_int_054/Mat/M_Pet_Cloth_int_054_Inside_9.M_Pet_Cloth_int_054_Inside_9"
    },
    LowDeviceMaterial = "/Game/Res/IG2500/Arts_Player/Pet/Pet_int_054/Mat/M_Pet_Cloth_int_054_9_Low.M_Pet_Cloth_int_054_9_Low"
  }
}
PetConfig.EnabledFeaturePets = {
  [ENUM_LOBBYPET_TYPE.TYPE_BLOCKBEARDROP] = true
}
PetConfig.CarryPets = {MAX_CARRY_COUNT_NORMAL = 4, MAX_CARRY_COUNT_WITH_EXPAND_SLOT = 6}
return PetConfig