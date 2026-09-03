local SingleTrainingConfig = {
  AITeamIdRange = {
    AIModelTarget = 100000001,
    FootStepChanllenge = 100000100,
    GunTraining = 100000201,
    SoundTraining = 100000202,
    AIRoundTraining = 100000203
  },
  AITrainingMode = {
    FootStepSound = 0,
    GunSound = 1,
    AIRoundTraining = 2,
    ThrowBombTraining = 3,
    ShootTraining = 4
  },
  FloorMaterialCfg = {
    [1] = "/Game/Mod/SingleTraining/Arts_Scenes/Materials/Ground/MI_shooting_hearing_ground_1_Grass.MI_shooting_hearing_ground_1_Grass",
    [2] = "/Game/Mod/SingleTraining/Arts_Scenes/Materials/Ground/MI_shooting_hearing_ground_2_Snow.MI_shooting_hearing_ground_2_Snow",
    [3] = "/Game/Mod/SingleTraining/Arts_Scenes/Materials/Ground/MI_shooting_hearing_ground_3_Stone.MI_shooting_hearing_ground_3_Stone",
    [4] = "/Game/Mod/SingleTraining/Arts_Scenes/Materials/Ground/MI_shooting_hearing_ground_4_Metal.MI_shooting_hearing_ground_4_Metal",
    [5] = "/Game/Mod/SingleTraining/Arts_Scenes/Materials/Ground/MI_shooting_hearing_ground_5_Sand.MI_shooting_hearing_ground_5_Sand",
    [6] = "/Game/Mod/SingleTraining/Arts_Scenes/Materials/Ground/MI_shooting_hearing_ground_6_Wood.MI_shooting_hearing_ground_6_Wood",
    [7] = "/Game/Mod/SingleTraining/Arts_Scenes/Materials/Ground/MI_shooting_hearing_ground_7_clay.MI_shooting_hearing_ground_7_clay"
  },
  BallisticTargetMark = "/Game/Mod/SingleTraining/BluePrints/UI/SingleTrain_Target_Item_BP.SingleTrain_Target_Item_BP_C",
  FrameMaterialPath = "/Game/Mod/SingleTraining/Arts/AQ_Icon_xuanzhong_Player_Mat1.AQ_Icon_xuanzhong_Player_Mat1",
  FrameDistanceSizeCurve = "/Game/Arts/UI/NoAtlas/AQ_Icon_xuanzhong_Curve.AQ_Icon_xuanzhong_Curve",
  SoundTrainingGroupId = 1,
  SimulateTrainingGroupId = 2,
  GunChanllengeGroupId = 3,
  ShootingEntriesId = 4,
  ThrowBombEntriesId = 5,
  TargetMarkHideTime = 2,
  TargetUIHideTime = 3,
  TargetActorBodyOrigin = FVector(0, 0, -6),
  TargetActorBodyBoxExtent = FVector(26, 0, 30),
  TargetActorHeadOrigin = FVector(0, 0, 30),
  TargetActorHeadBoxExtent = FVector(9, 0, 9),
  TargetUIWidth = 64,
  TargetUIHeight = 90,
  FakerPlayerWeaponCfg = {
    [1] = {
      101001,
      101002,
      101003,
      101004
    },
    [2] = {
      102001,
      102002,
      102003,
      102004
    },
    [3] = {
      104001,
      104002,
      104003,
      104004
    },
    [4] = {
      103001,
      103002,
      103003,
      103004
    }
  },
  ScatterGunIDs = {
    104001,
    104002,
    104003,
    104004,
    104101,
    104102,
    106006
  },
  TeleportCfg = {
    [1] = {
      Pos = FVector(36142.003906, 33791.125, 163.547729),
      Rotation = FRotator(0.0, 0.0, 0.0)
    },
    [2] = {
      Pos = FVector(38357.859375, 20202.84375, -389.002045),
      Rotation = FRotator(0.0, -179.624069, 0.0)
    },
    [3] = {
      Pos = FVector(38089.0, 33101.0, 1364.0),
      Rotation = FRotator(0.0, -179.0, 0.0)
    },
    [4] = {
      Pos = FVector(45282.859375, 20611.84375, 644.90332),
      Rotation = FRotator(0.0, 90.3759, 0.0)
    },
    [5] = {
      Pos = FVector(47041.859375, 20611.84375, 644.90332),
      Rotation = FRotator(0.0, 90.3759, 0.0)
    }
  },
  GunSoundTrainingCfg = {
    DirectionId2Key = {
      [1] = "East",
      [2] = "West",
      [3] = "South",
      [4] = "North",
      [5] = "Southeast",
      [6] = "Southwest",
      [7] = "Northeast",
      [8] = "Northwest"
    },
    East = {
      [1] = {
        FVector(41481.410156, 34543.296875, 747.147705),
        FVector(41630.519531, 33720.9375, 747.147705),
        FVector(41616.507813, 32976.265625, 747.147705),
        FVector(42945.25, 34403.515625, 714.289185),
        FVector(42999.320313, 33156.703125, 712.642761)
      },
      [2] = {
        FVector(43946.5625, 34681.515625, 648.207153),
        FVector(43948.425781, 33758.09375, 679.454346),
        FVector(43766.808594, 32642.640625, 697.582581),
        FVector(44866.058594, 32583.296875, 702.018738),
        FVector(45156.207031, 34736.078125, 702.018738)
      },
      [3] = {
        FVector(48217.324219, 33468.40625, 1197.087036),
        FVector(48848.800781, 33964.609375, 1255.193726),
        FVector(47331.535156, 35085.921875, 870.469299)
      },
      [4] = {
        FVector(49521.394531, 32815.3125, 1217.097778),
        FVector(49941.421875, 35556.546875, 1215.98999)
      }
    },
    West = {
      [1] = {
        FVector(36197.527344, 33422.515625, 208.047211),
        FVector(36325.609375, 33793.5625, 208.047211),
        FVector(35579.445313, 33459.59375, 170.045303),
        FVector(35234.011719, 33841.90625, 123.89019),
        FVector(34257.722656, 33633.21875, 78.481796)
      },
      [2] = {
        FVector(33540.398438, 33454.875, 77.252182),
        FVector(33408.273438, 34162.640625, 77.252182),
        FVector(32026.994141, 33326.09375, 86.866432),
        FVector(32689.771484, 34144.734375, 97.007896),
        FVector(32210.810547, 34161.109375, 83.312263)
      },
      [3] = {
        FVector(30988.140625, 34228.109375, 74.617767),
        FVector(30838.453125, 33527.578125, 92.93689),
        FVector(29981.492188, 33750.578125, 83.09642),
        FVector(29134.490234, 34201.171875, 77.252449),
        FVector(27745.429688, 34328.328125, 84.093987)
      },
      [4] = {
        FVector(26283.269531, 34271.921875, 79.198868),
        FVector(25809.621094, 34485.3125, 68.128395),
        FVector(24718.105469, 34477.0, 72.735168),
        FVector(24413.423828, 33840.71875, 633.149841),
        FVector(24441.210938, 34459.203125, 633.149841)
      }
    },
    South = {
      [1] = {
        FVector(38582.507813, 37319.65625, 604.118408),
        FVector(39567.09375, 37204.953125, 604.118408),
        FVector(38542.019531, 39074.015625, 198.835419),
        FVector(39574.222656, 39063.078125, 242.502075),
        FVector(39080.875, 39821.109375, 378.492706)
      },
      [2] = {
        FVector(38267.710938, 41307.5, 723.940308),
        FVector(39005.882813, 41312.0, 656.284485),
        FVector(39654.707031, 41224.0625, 684.306091),
        FVector(38544.214844, 42330.3125, 747.407166),
        FVector(39582.160156, 42160.703125, 707.302307)
      },
      [3] = {
        FVector(38268.175781, 43221.578125, 852.314636),
        FVector(39070.0, 42898.75, 734.278381),
        FVector(39596.214844, 42618.859375, 717.520203),
        FVector(38377.285156, 43338.375, 833.12146),
        FVector(39453.855469, 43713.484375, 743.464111)
      },
      [4] = {
        FVector(38522.707031, 45873.953125, 1374.492432),
        FVector(37732.5, 45723.75, 1365.421021)
      }
    },
    North = {
      [1] = {
        FVector(39645.191406, 30345.125, 586.620239),
        FVector(38402.484375, 30289.890625, 586.6203),
        FVector(39895.285156, 28470.390625, 236.196228),
        FVector(39088.523438, 28373.65625, 192.974915),
        FVector(38151.566406, 27815.703125, 185.91922)
      },
      [2] = {
        FVector(39556.492188, 26614.4375, 218.218414),
        FVector(38799.164063, 26719.53125, 163.460114),
        FVector(37919.296875, 26780.59375, 140.553741),
        FVector(39746.996094, 25217.234375, 185.758224),
        FVector(38462.425781, 25167.390625, 78.847008)
      },
      [3] = {
        FVector(39710.804688, 24508.609375, 152.940613),
        FVector(39014.808594, 24528.015625, 82.001511),
        FVector(38042.753906, 24848.0, 71.628487),
        FVector(39686.339844, 23441.8125, 172.093246),
        FVector(38237.796875, 23673.671875, 4.44442)
      },
      [4] = {
        FVector(40284.855469, 19916.640625, 86.92495),
        FVector(39845.847656, 19181.578125, 111.278152),
        FVector(40468.792969, 16838.765625, 1539.114746)
      }
    },
    Northeast = {
      [1] = {
        FVector(40878.375, 30421.28125, 580.797485),
        FVector(40795.949219, 28863.359375, 257.547791),
        FVector(41501.9375, 28093.75, 441.543152)
      },
      [2] = {
        FVector(42475.359375, 27888.671875, 662.219604),
        FVector(43217.078125, 27256.96875, 698.069458),
        FVector(42992.09375, 26753.8125, 969.082092)
      },
      [3] = {
        FVector(45614.320313, 24478.359375, 702.15033),
        FVector(45157.449219, 23856.84375, 702.15033),
        FVector(45258.414063, 22819.03125, 702.151367)
      },
      [4] = {
        FVector(47632.179688, 21894.84375, 702.151367),
        FVector(48614.230469, 21439.5625, 706.058105),
        FVector(47687.671875, 20249.09375, 719.525452)
      }
    },
    Southeast = {
      [1] = {
        FVector(41137.589844, 37152.109375, 588.960144),
        FVector(42740.128906, 38456.703125, 693.556519),
        FVector(42957.632813, 38854.59375, 695.137634)
      },
      [2] = {
        FVector(44949.222656, 39015.078125, 691.169495),
        FVector(45072.296875, 40115.34375, 697.461121),
        FVector(45658.945313, 38605.765625, 703.512146)
      },
      [3] = {
        FVector(47582.515625, 41383.015625, 1113.26355),
        FVector(48557.207031, 40720.1875, 1090.358276),
        FVector(47269.75, 42203.8125, 1157.013916)
      },
      [4] = {
        FVector(49228.675781, 42959.09375, 1235.667236),
        FVector(49354.933594, 41661.53125, 1138.447266),
        FVector(47888.824219, 44840.34375, 1165.453857)
      }
    },
    Northwest = {
      [1] = {
        FVector(37066.597656, 30365.546875, 580.785339),
        FVector(36144.082031, 30840.3125, 208.047211),
        FVector(34683.875, 30488.96875, 75.813881)
      },
      [2] = {
        FVector(35344.953125, 28460.46875, 83.207367),
        FVector(34251.089844, 29527.65625, 81.502632),
        FVector(32883.980469, 28185.546875, 83.207367)
      },
      [3] = {
        FVector(31041.853516, 27432.375, 83.051338),
        FVector(29564.199219, 25790.40625, 86.52066),
        FVector(28602.863281, 26263.25, 130.367554)
      },
      [4] = {
        FVector(27593.900391, 24411.765625, 98.653465),
        FVector(26417.353516, 24828.5625, 83.268898),
        FVector(25347.935547, 25396.203125, 83.752853)
      }
    },
    Southwest = {
      [1] = {
        FVector(36831.414063, 37271.640625, 589.016907),
        FVector(36804.058594, 39062.640625, 194.265381),
        FVector(35190.046875, 38602.96875, 166.26857)
      },
      [2] = {
        FVector(33405.074219, 40531.125, 695.95105),
        FVector(32223.318359, 39269.875, 510.755554),
        FVector(33476.328125, 40549.15625, 702.753357)
      },
      [3] = {
        FVector(34087.136719, 44700.75, 1592.917114),
        FVector(30928.701172, 42771.75, 208.901566),
        FVector(29142.330078, 42761.1875, 113.362556)
      },
      [4] = {
        FVector(28066.144531, 43959.078125, 181.794052),
        FVector(28908.339844, 44866.390625, 392.903503),
        FVector(30683.794922, 45083.25, 906.355591)
      }
    }
  },
  StepSoundTrainingCfg = {
    LocationId2Key = {
      [1] = "OutSide",
      [2] = "FirstFloor",
      [3] = "SecondFloor",
      [4] = "ThirdFloor",
      [5] = "Rooftop"
    },
    OutSide = {
      SingleCirculation = {
        [1] = {
          BornTeamid = 3,
          BornPos = {
            FVector(40232.0, 37915.0, 144.021851),
            FVector(40390.0, 36016.0, 138.047302)
          },
          IsProne = true
        },
        [2] = {
          BornTeamid = 2,
          BornPos = {
            FVector(40506.0, 30993.0, 143.00032),
            FVector(40522.0, 31896.0, 143.562317)
          },
          IsProne = true
        },
        [3] = {
          BornTeamid = 5,
          BornPos = {
            FVector(39284.0, 31888.0, 157.0),
            FVector(37823.0, 35438.0, 140.047318)
          },
          IsProne = false
        }
      },
      RepeatOnBothSides = {
        [1] = {
          BornTeamid = 20,
          BornPos = {
            FVector(40521.0, 31760.0, 144.047318),
            FVector(37618.0, 35827.0, 141.047318)
          },
          IsProne = true
        },
        [2] = {
          BornTeamid = 21,
          BornPos = {
            FVector(40968.0, 30359.0, 553.563171),
            FVector(36947.0, 30359.0, 513.551147)
          },
          IsProne = false
        }
      },
      AlternateLeftRight = {
        [1] = {
          BornTeamid = 14,
          BornPos = {
            FVector(40686.0, 31853.0, 142.047318),
            FVector(36381.0, 35594.0, 142.047318)
          },
          IsProne = true
        },
        [2] = {
          BornTeamid = 15,
          BornPos = {
            FVector(41249.0, 37212.0, 559.021912),
            FVector(36829.0, 30303.0, 501.047302)
          },
          IsProne = false
        }
      }
    },
    FirstFloor = {
      SingleCirculation = {
        [1] = {
          BornTeamid = 6,
          BornPos = {
            FVector(38794.0, 34750.0, 214.538498),
            FVector(38257.0, 34133.0, 214.538498)
          },
          IsProne = false
        },
        [2] = {
          BornTeamid = 7,
          BornPos = {
            FVector(38726.0, 32721.0, 178.538498),
            FVector(38687.0, 33398.0, 180.05217)
          },
          IsProne = true
        }
      },
      RepeatOnBothSides = {
        [1] = {
          BornTeamid = 22,
          BornPos = {
            FVector(38257.0, 34642.0, 214.538498),
            FVector(38327.0, 33014.0, 214.538498)
          },
          IsProne = true
        }
      },
      AlternateLeftRight = {
        [1] = {
          BornTeamid = 16,
          BornPos = {
            FVector(38700.0, 34943.0, 214.538513),
            FVector(38694.0, 32692.0, 214.538498)
          },
          IsProne = true
        }
      }
    },
    SecondFloor = {
      SingleCirculation = {
        [1] = {
          BornTeamid = 8,
          BornPos = {
            FVector(38257.0, 34511.0, 558.538513),
            FVector(38702.0, 34205.0, 557.569458)
          },
          IsProne = true
        },
        [2] = {
          BornTeamid = 10,
          BornPos = {
            FVector(38794.0, 32863.0, 594.569458),
            FVector(39816.0, 32615.0, 594.570557)
          },
          IsProne = false
        }
      },
      RepeatOnBothSides = {
        [1] = {
          BornTeamid = 23,
          BornPos = {
            FVector(38257.0, 34642.0, 594.569458),
            FVector(38327.0, 33014.0, 594.569458)
          },
          IsProne = true
        }
      },
      AlternateLeftRight = {
        [1] = {
          BornTeamid = 17,
          BornPos = {
            FVector(38700.0, 34943.0, 594.569458),
            FVector(38694.0, 32692.0, 594.569458)
          },
          IsProne = true
        }
      }
    },
    ThirdFloor = {
      SingleCirculation = {
        [1] = {
          BornTeamid = 9,
          BornPos = {
            FVector(38794.0, 34750.0, 973.455811),
            FVector(39836.0, 34975.0, 973.455933)
          },
          IsProne = true
        },
        [2] = {
          BornTeamid = 11,
          BornPos = {
            FVector(38794.0, 32863.0, 973.455811),
            FVector(39816.0, 33401.0, 973.455933)
          },
          IsProne = false
        }
      },
      RepeatOnBothSides = {
        [1] = {
          BornTeamid = 24,
          BornPos = {
            FVector(38257.0, 34642.0, 973.455811),
            FVector(38327.0, 33014.0, 973.455811)
          },
          IsProne = true
        }
      },
      AlternateLeftRight = {
        [1] = {
          BornTeamid = 18,
          BornPos = {
            FVector(38700.0, 34943.0, 973.455811),
            FVector(38694.0, 32692.0, 973.455811)
          },
          IsProne = true
        }
      }
    },
    Rooftop = {
      SingleCirculation = {
        [1] = {
          BornTeamid = 12,
          BornPos = {
            FVector(39294.0, 34159.0, 1356.0448),
            FVector(38832.0, 34935.0, 1356.044434)
          },
          IsProne = true
        },
        [2] = {
          BornTeamid = 13,
          BornPos = {
            FVector(39294.0, 33411.0, 1356.0448),
            FVector(38823.0, 32615.0, 1356.044556)
          },
          IsProne = false
        }
      },
      RepeatOnBothSides = {
        [1] = {
          BornTeamid = 25,
          BornPos = {
            FVector(39115.0, 33857.0, 1356.0448),
            FVector(38095.0, 33001.0, 1356.044556)
          },
          IsProne = true
        }
      },
      AlternateLeftRight = {
        [1] = {
          BornTeamid = 19,
          BornPos = {
            FVector(39349.0, 35458.0, 1315.044678),
            FVector(38825.0, 32117.0, 1315.044556)
          },
          IsProne = true
        }
      }
    }
  },
  ModelTagetSpawnPoint = {
    [5] = {
      Pos = FVector(37419.308594, 32115.492188, 220.0),
      Rotation = FRotator(0.0, 180.0, 0.0),
      bHideInSpecialTrain = true
    },
    [6] = {
      Pos = FVector(37419.308594, 32368.205078, 220.0),
      Rotation = FRotator(0.0, 180.0, 0.0),
      bHideInSpecialTrain = true
    },
    [7] = {
      Pos = FVector(37418.917969, 32614.4375, 220.0),
      Rotation = FRotator(0.0, 180.0, 0.0),
      bHideInSpecialTrain = true
    },
    [8] = {
      Pos = FVector(37418.917969, 32867.15625, 220.0),
      Rotation = FRotator(0.0, 180.0, 0.0),
      bHideInSpecialTrain = true
    }
  },
  ModelTagetEquipment = {
    [1] = {HelmetID = 0, ArmorID = 0},
    [2] = {HelmetID = 502004, ArmorID = 503001},
    [3] = {HelmetID = 502002, ArmorID = 503002},
    [4] = {HelmetID = 502003, ArmorID = 503003},
    [5] = {HelmetID = 0, ArmorID = 0},
    [6] = {HelmetID = 502004, ArmorID = 503001},
    [7] = {HelmetID = 502002, ArmorID = 503002},
    [8] = {HelmetID = 502003, ArmorID = 503003}
  },
  ModelTagetAudioConfig = {
    Body = "/Game/Mod/SingleTraining/WwiseEvent/Play_BulletHit_Modle_Impact_Flesh.Play_BulletHit_Modle_Impact_Flesh",
    Armor = "/Game/Mod/SingleTraining/WwiseEvent/Play_BulletHit_Model_Imapct_Armor.Play_BulletHit_Model_Imapct_Armor"
  },
  TrainingBornItemList = {
    604087,
    604088,
    604089,
    604090,
    604091,
    604092,
    604093,
    604094
  },
  TrainingBornItemSubTypeList = {606}
}
return SingleTrainingConfig