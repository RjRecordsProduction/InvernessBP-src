local Config = {
  KeyItemId = 3000335,
  PickupCommonTipsId = 12104,
  TargetHasOpenedTipsId = 12111,
  MapMarkId = 77,
  ScreenMarkId = 1013,
  TLog = {
    Game = {OpenCount = 451}
  },
  GenerateKey = {Radius = 100000, CullRadius = 20000},
  BPClass = {
    SecretArmory = "/Game/Library/Res/Actors/BackRoom/BP_SM_Building_BackRoom_01.BP_SM_Building_BackRoom_01",
    SecretArmoryKeyWrapper = "/Game/Library/Res/Actors/BackRoom/BluePrints/Actor/SecretArmoryKeyWrapper.SecretArmoryKeyWrapper"
  },
  CullMode = {
    1010,
    1011,
    1012,
    1070,
    1071,
    1072,
    1094,
    1095,
    1096,
    60011,
    60012,
    60015,
    60016,
    1034,
    1035,
    1036,
    1040,
    1041,
    1042,
    90001,
    90002,
    90003,
    91001,
    1022,
    1023,
    1024,
    1025,
    1026,
    1027,
    1028,
    1029,
    1030,
    1031,
    1032,
    1033,
    1037,
    1038,
    1039
  },
  GenerateItems = {
    [1] = {
      Location = {
        X = -726.999756,
        Y = 85.016624,
        Z = 272.934509
      },
      Rotation = {
        Pitch = 6.28E-4,
        Yaw = 90,
        Roll = 90.0
      },
      ItemWeights = {
        [102003] = 3960,
        [102001] = 1980,
        [102002] = 3960,
        [102105] = 100
      }
    },
    [2] = {
      Location = {
        X = -729.999573,
        Y = 27.01561,
        Z = 264.933655
      },
      Rotation = {
        Pitch = 0.0,
        Yaw = 0.0,
        Roll = 0.0
      },
      ItemBinding = {
        TargetSpotId = 1,
        Mapping = {
          [102003] = {ItemId = 301001, Count = 90},
          [102001] = {ItemId = 301001, Count = 90},
          [102002] = {ItemId = 305001, Count = 90},
          [102105] = {ItemId = 301002, Count = 200}
        }
      }
    },
    [3] = {
      Location = {
        X = -726.999756,
        Y = 208.016678,
        Z = 270.932892
      },
      Rotation = {
        Pitch = 6.35E-4,
        Yaw = 90.0,
        Roll = 90.0
      },
      ItemWeights = {
        [101001] = 3960,
        [101102] = 1980,
        [101008] = 3960,
        [101005] = 100
      }
    },
    [4] = {
      Location = {
        X = -729.999573,
        Y = 157.01561,
        Z = 264.933655
      },
      Rotation = {
        Pitch = 0.0,
        Yaw = 0.0,
        Roll = 0.0
      },
      ItemBinding = {
        TargetSpotId = 3,
        Mapping = {
          [101001] = {ItemId = 302001, Count = 60},
          [101102] = {ItemId = 302001, Count = 60},
          [101008] = {ItemId = 302001, Count = 60},
          [101005] = {ItemId = 302001, Count = 60}
        }
      }
    },
    [5] = {
      Location = {
        X = -726.999756,
        Y = 64.017426,
        Z = 200.931427
      },
      Rotation = {
        Pitch = 6.35E-4,
        Yaw = 89.999985,
        Roll = 90.0
      },
      ItemWeights = {
        [101003] = 1980,
        [101004] = 3960,
        [101006] = 3960,
        [101100] = 100
      }
    },
    [6] = {
      Location = {
        X = -729.999573,
        Y = 14.01561,
        Z = 195.933655
      },
      Rotation = {
        Pitch = 0.0,
        Yaw = 0.0,
        Roll = 0.0
      },
      ItemBinding = {
        TargetSpotId = 5,
        Mapping = {
          [101003] = {ItemId = 303001, Count = 60},
          [101004] = {ItemId = 303001, Count = 60},
          [101006] = {ItemId = 303001, Count = 60},
          [101100] = {ItemId = 303001, Count = 60}
        }
      }
    },
    [9] = {
      Location = {
        X = -409.63269,
        Y = 465.212555,
        Z = 323.995605
      },
      Rotation = {
        Pitch = 0.0,
        Yaw = 0.0,
        Roll = 90.0
      },
      ItemWeights = {
        [103004] = 792,
        [103100] = 792,
        [103006] = 528,
        [103009] = 528,
        [103002] = 1320,
        [103001] = 660,
        [103011] = 660,
        [103102] = 4620,
        [103007] = 50,
        [103003] = 25,
        [103012] = 25
      }
    },
    [10] = {
      Location = {
        X = -361.999573,
        Y = 464.015625,
        Z = 246.933655
      },
      Rotation = {
        Pitch = 90.0,
        Yaw = 0.0,
        Roll = 90.000008
      },
      ItemBinding = {
        TargetSpotId = 9,
        Mapping = {
          [103004] = {ItemId = 302001, Count = 30},
          [103100] = {ItemId = 303001, Count = 30},
          [103006] = {ItemId = 303001, Count = 30},
          [103009] = {ItemId = 302001, Count = 30},
          [103002] = {ItemId = 302001, Count = 30},
          [103001] = {ItemId = 302001, Count = 30},
          [103011] = {ItemId = 302001, Count = 30},
          [103102] = {ItemId = 302001, Count = 30},
          [103007] = {ItemId = 302001, Count = 60},
          [103003] = {ItemId = 306001, Count = 20},
          [103012] = {ItemId = 306002, Count = 10}
        }
      }
    },
    [7] = {
      Location = {
        X = -726.999756,
        Y = 183.017426,
        Z = 200.932571
      },
      Rotation = {
        Pitch = 6.35E-4,
        Yaw = 89.999985,
        Roll = 90.0
      },
      ItemWeights = {
        [104003] = 1584,
        [104004] = 2376,
        [105001] = 2970,
        [105002] = 2970,
        [105010] = 100
      },
      RotationOverride = {
        [105010] = {
          Pitch = 0,
          Yaw = 90,
          Roll = 0
        }
      }
    },
    [8] = {
      Location = {
        X = -729.999573,
        Y = 137.01561,
        Z = 195.933655
      },
      Rotation = {
        Pitch = 0.0,
        Yaw = 0.0,
        Roll = 0.0
      },
      ItemBinding = {
        TargetSpotId = 7,
        Mapping = {
          [104003] = {ItemId = 304001, Count = 20},
          [104004] = {ItemId = 304001, Count = 20},
          [105001] = {ItemId = 303001, Count = 100},
          [105002] = {ItemId = 302001, Count = 100},
          [105010] = {ItemId = 302001, Count = 100}
        }
      }
    },
    [11] = {
      Location = {
        X = -409.63269,
        Y = 465.212555,
        Z = 278.995605
      },
      Rotation = {
        Pitch = 0.0,
        Yaw = 0.0,
        Roll = 90.0
      },
      ItemWeights = {
        [102105] = 1650,
        [101005] = 1650,
        [101100] = 1650,
        [105010] = 1650,
        [103007] = 1700,
        [103003] = 850,
        [103012] = 850
      },
      RotationOverride = {
        [105010] = {
          Pitch = 0,
          Yaw = 0,
          Roll = 0
        }
      }
    },
    [12] = {
      Location = {
        X = -406.999573,
        Y = 464.015625,
        Z = 246.933655
      },
      Rotation = {
        Pitch = 90.0,
        Yaw = 0.0,
        Roll = 90.000008
      },
      ItemBinding = {
        TargetSpotId = 11,
        Mapping = {
          [102105] = {ItemId = 301002, Count = 200},
          [101005] = {ItemId = 302001, Count = 60},
          [101100] = {ItemId = 303001, Count = 60},
          [105010] = {ItemId = 302001, Count = 100},
          [103007] = {ItemId = 302001, Count = 60},
          [103003] = {ItemId = 306001, Count = 20},
          [103012] = {ItemId = 306002, Count = 10}
        }
      }
    },
    [13] = {
      Location = {
        X = -750.999573,
        Y = 342.015625,
        Z = 334.933655
      },
      Rotation = {
        Pitch = 0.0,
        Yaw = -89.999985,
        Roll = 0.0
      },
      ItemWeights = {
        [502003] = 10000
      }
    },
    [14] = {
      Location = {
        X = -750.999573,
        Y = 430.015625,
        Z = 334.933655
      },
      Rotation = {
        Pitch = 0.0,
        Yaw = -90.0,
        Roll = 0.0
      },
      ItemWeights = {
        [502002] = 8000,
        [502003] = 2000
      },
      RotationOverride = {
        [502002] = {
          Pitch = 0.0,
          Yaw = -143.999851,
          Roll = 0
        },
        [502003] = {
          Pitch = 0.0,
          Yaw = -90.0,
          Roll = 0.0
        }
      }
    },
    [15] = {
      Location = {
        X = -764.999573,
        Y = 428.015625,
        Z = 286.933655
      },
      Rotation = {
        Pitch = 0.0,
        Yaw = 89.999969,
        Roll = -89.999969
      },
      ItemWeights = {
        [503002] = 6800,
        [503003] = 3200
      },
      RotationOverride = {
        [503002] = {
          Pitch = -230.399399,
          Yaw = 90,
          Roll = -90
        },
        [503003] = {
          Pitch = -107.999725,
          Yaw = 90,
          Roll = -89.999969
        }
      }
    },
    [16] = {
      Location = {
        X = -764.999573,
        Y = 346.015625,
        Z = 243.933655
      },
      Rotation = {
        Pitch = 0.0,
        Yaw = -90.0,
        Roll = 90.0
      },
      ItemWeights = {
        [403045] = 3000,
        [503003] = 7000
      },
      RotationOverride = {
        [503003] = {
          Pitch = -107.999725,
          Yaw = 90,
          Roll = -89.999969
        }
      }
    },
    [17] = {
      Location = {
        X = -764.999573,
        Y = 428.015625,
        Z = 194.933655
      },
      Rotation = {
        Pitch = 0.0,
        Yaw = 89.999969,
        Roll = -89.999969
      },
      ItemWeights = {
        [501002] = 7000,
        [501003] = 3000
      },
      RotationOverride = {
        [501002] = {
          Pitch = -323.999115,
          Yaw = 90,
          Roll = -90
        },
        [501003] = {
          Pitch = -75.599785,
          Yaw = 90,
          Roll = -89.999969
        }
      }
    },
    [18] = {
      Location = {
        X = -722.729309,
        Y = 226.73259,
        Z = 143.148788
      },
      Rotation = {
        Pitch = 0.0,
        Yaw = 89.999985,
        Roll = 0.0
      },
      ItemWeights = {
        [201006] = 1000,
        [201002] = 2000,
        [201011] = 1000,
        [201009] = 2000,
        [201053] = 1000,
        [201007] = 1000,
        [201003] = 2000
      }
    },
    [19] = {
      Location = {
        X = -722.729309,
        Y = 145.73259,
        Z = 143.148788
      },
      Rotation = {
        Pitch = 0.0,
        Yaw = 89.999985,
        Roll = 0.0
      },
      ItemWeights = {
        [204004] = 1250,
        [204006] = 1875,
        [204011] = 1250,
        [204013] = 1875,
        [204007] = 1250,
        [204009] = 1875,
        [204051] = 625
      }
    },
    [20] = {
      Location = {
        X = -722.729309,
        Y = 64.73259,
        Z = 143.148788
      },
      Rotation = {
        Pitch = 0.0,
        Yaw = 89.999985,
        Roll = 0.0
      },
      ItemWeights = {
        [204004] = 1250,
        [204006] = 1875,
        [204011] = 1250,
        [204013] = 1875,
        [204007] = 1250,
        [204009] = 1875,
        [204051] = 625
      }
    },
    [21] = {
      Location = {
        X = -343.63269,
        Y = 445.212433,
        Z = 199.995697
      },
      Rotation = {
        Pitch = 90.0,
        Yaw = 90,
        Roll = 90.0
      },
      ItemWeights = {
        [202002] = 2500,
        [202001] = 2500,
        [202004] = 1250,
        [202005] = 1250,
        [202006] = 1250,
        [202007] = 1250
      },
      RotationOverride = {
        [202001] = {
          Pitch = 0.0,
          Yaw = 0,
          Roll = 0.0
        },
        [202004] = {
          Pitch = 0.0,
          Yaw = 0,
          Roll = 0.0
        },
        [202005] = {
          Pitch = 0.0,
          Yaw = 0,
          Roll = 0.0
        },
        [202006] = {
          Pitch = 0.0,
          Yaw = 0,
          Roll = 0.0
        },
        [202007] = {
          Pitch = 0.0,
          Yaw = 0,
          Roll = 0.0
        }
      }
    },
    [22] = {
      Location = {
        X = -399.63269,
        Y = 445.212433,
        Z = 199.995697
      },
      Rotation = {
        Pitch = 90.0,
        Yaw = 90,
        Roll = 90.000198
      },
      ItemWeights = {
        [202002] = 2500,
        [202001] = 2500,
        [202004] = 1250,
        [202005] = 1250,
        [202006] = 1250,
        [202007] = 1250
      },
      RotationOverride = {
        [202001] = {
          Pitch = 0.0,
          Yaw = 0,
          Roll = 0.0
        },
        [202004] = {
          Pitch = 0.0,
          Yaw = 0,
          Roll = 0.0
        },
        [202005] = {
          Pitch = 0.0,
          Yaw = 0,
          Roll = 0.0
        },
        [202006] = {
          Pitch = 0.0,
          Yaw = 0,
          Roll = 0.0
        },
        [202007] = {
          Pitch = 0.0,
          Yaw = 0,
          Roll = 0.0
        }
      }
    },
    [23] = {
      Location = {
        X = -115.63269,
        Y = 448.212219,
        Z = 216.457993
      },
      Rotation = {
        Pitch = 0.0,
        Yaw = -90.0,
        Roll = 1.98E-4
      },
      ItemWeights = {
        [203001] = 2500,
        [203003] = 2500,
        [203014] = 2500,
        [203004] = 2500
      }
    },
    [24] = {
      Location = {
        X = -191.63269,
        Y = 444.212524,
        Z = 216.995697
      },
      Rotation = {
        Pitch = 0.0,
        Yaw = -90.0,
        Roll = 1.98E-4
      },
      ItemWeights = {
        [203015] = 5000,
        [203005] = 5000
      },
      RotationOverride = {
        [203005] = {
          Pitch = 0.0,
          Yaw = 0.0,
          Roll = 1.98E-4
        }
      }
    },
    [25] = {
      Location = {
        X = -152.729309,
        Y = 442.732483,
        Z = 179.148788
      },
      Rotation = {
        Pitch = 0.0,
        Yaw = 0.0,
        Roll = 0.0
      },
      ItemWeights = {
        [205002] = 5000,
        [204014] = 2500,
        [205003] = 2500
      }
    },
    [26] = {
      Location = {
        X = -287.628174,
        Y = 206.999985,
        Z = 178.996719
      },
      Rotation = {
        Pitch = 0.0,
        Yaw = 0.0,
        Roll = 0.0
      },
      ItemWeights = {
        [601001] = 5000,
        [601003] = 5000
      }
    },
    [27] = {
      Location = {
        X = -256.628174,
        Y = 207.999985,
        Z = 177.996719
      },
      Rotation = {
        Pitch = 0.0,
        Yaw = 0.0,
        Roll = 0.0
      },
      ItemWeights = {
        [601001] = 5000,
        [601003] = 5000
      }
    },
    [28] = {
      Location = {
        X = -259.628174,
        Y = 229.999985,
        Z = 177.996719
      },
      Rotation = {
        Pitch = 0.0,
        Yaw = 0.0,
        Roll = 0.0
      },
      ItemWeights = {
        [601001] = 5000,
        [601003] = 5000
      }
    },
    [29] = {
      Location = {
        X = -274.628174,
        Y = 226.999985,
        Z = 179.996719
      },
      Rotation = {
        Pitch = 0.0,
        Yaw = 0.0,
        Roll = 0.0
      },
      ItemWeights = {
        [601002] = 10000
      }
    },
    [30] = {
      Location = {
        X = -556.154053,
        Y = -29.140593,
        Z = 149.996719
      },
      Rotation = {
        Pitch = 0.0,
        Yaw = 44.999992,
        Roll = 0.0
      },
      ItemWeights = {
        [601004] = 2500,
        [601005] = 7500
      }
    },
    [31] = {
      Location = {
        X = -500.292297,
        Y = -27.019268,
        Z = 148.996719
      },
      Rotation = {
        Pitch = 0.0,
        Yaw = 44.999992,
        Roll = 0.0
      },
      ItemWeights = {
        [601004] = 2500,
        [601005] = 7500
      }
    },
    [32] = {
      Location = {
        X = -349.394257,
        Y = 168.363953,
        Z = 175.996719
      },
      Rotation = {
        Pitch = 0.0,
        Yaw = 0,
        Roll = 0.0
      },
      ItemWeights = {
        [601004] = 7500,
        [601005] = 2500
      }
    },
    [33] = {
      Location = {
        X = -275.063202,
        Y = 167.949738,
        Z = 175.996719
      },
      Rotation = {
        Pitch = 0.0,
        Yaw = 135.0,
        Roll = 0.0
      },
      ItemWeights = {
        [601006] = 1
      }
    },
    [34] = {
      Location = {
        X = -444.628174,
        Y = 241.999985,
        Z = 178.996719
      },
      Rotation = {
        Pitch = 0.0,
        Yaw = 0.0,
        Roll = 0.0
      },
      ItemWeights = {
        [602004] = 1
      }
    },
    [35] = {
      Location = {
        X = -438.628174,
        Y = 227.999985,
        Z = 178.996719
      },
      Rotation = {
        Pitch = 0.0,
        Yaw = 0.0,
        Roll = 0.0
      },
      ItemWeights = {
        [602004] = 1
      }
    },
    [36] = {
      Location = {
        X = -473.628174,
        Y = 234.999985,
        Z = 181.996719
      },
      Rotation = {
        Pitch = 0.0,
        Yaw = 0.0,
        Roll = 0.0
      },
      ItemWeights = {
        [602003] = 1
      }
    },
    [37] = {
      Location = {
        X = -484.628174,
        Y = 227.999985,
        Z = 181.996719
      },
      Rotation = {
        Pitch = 0.0,
        Yaw = 0.0,
        Roll = 0.0
      },
      ItemWeights = {
        [602003] = 1
      }
    },
    [38] = {
      Location = {
        X = -415.628174,
        Y = 222.999985,
        Z = 181.996719
      },
      Rotation = {
        Pitch = 0.0,
        Yaw = 0.0,
        Roll = 0.0
      },
      ItemWeights = {
        [602002] = 1
      }
    },
    [39] = {
      Location = {
        X = -425.628174,
        Y = 212.999985,
        Z = 181.996719
      },
      Rotation = {
        Pitch = 0.0,
        Yaw = 0.0,
        Roll = 0.0
      },
      ItemWeights = {
        [602002] = 1
      }
    },
    [40] = {
      Location = {
        X = -332.71405,
        Y = -100.418739,
        Z = 219.431213
      },
      Rotation = {
        Pitch = 0.0,
        Yaw = 0.0,
        Roll = -89.999985
      },
      ItemWeights = {
        [604007] = 8000,
        [602069] = 2000
      }
    },
    [41] = {
      Location = {
        X = -332.71405,
        Y = -100.418747,
        Z = 86.431213
      },
      Rotation = {
        Pitch = 0.0,
        Yaw = 90.0,
        Roll = 0.0
      },
      ItemWeights = {
        [603001] = 10000
      }
    }
  }
}
return Config