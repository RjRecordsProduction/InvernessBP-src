local ChanllengeConfig = {
  LocationId2Key = {
    [1] = "OutSide",
    [2] = "FirstFloor",
    [3] = "SecondFloor",
    [4] = "ThirdFloor",
    [5] = "Rooftop"
  },
  OutSide = {
    [1] = {
      BornTeamid = 3,
      BornPos = {
        FVector(40232.0, 37915.0, 144.021851)
      },
      IsProne = true
    },
    [2] = {
      BornTeamid = 2,
      BornPos = {
        FVector(40506.0, 30993.0, 143.00032)
      },
      IsProne = true
    },
    [3] = {
      BornTeamid = 5,
      BornPos = {
        FVector(39284.0, 31888.0, 157.0)
      },
      IsProne = false
    },
    [4] = {
      BornTeamid = 20,
      BornPos = {
        FVector(40521.0, 31760.0, 144.047318)
      },
      IsProne = true
    },
    [5] = {
      BornTeamid = 21,
      BornPos = {
        FVector(40968.0, 30359.0, 553.563171)
      },
      IsProne = false
    },
    [6] = {
      BornTeamid = 14,
      BornPos = {
        FVector(40686.0, 31853.0, 142.047318)
      },
      IsProne = true
    },
    [7] = {
      BornTeamid = 15,
      BornPos = {
        FVector(41249.0, 37212.0, 559.021912)
      },
      IsProne = false
    }
  },
  FirstFloor = {
    [1] = {
      BornTeamid = 6,
      BornPos = {
        FVector(38658.0, 34884.0, 214.538498),
        FVector(38667.0, 34149.0, 176.538513),
        IsProne = false
      }
    },
    [2] = {
      BornTeamid = 7,
      BornPos = {
        FVector(38726.0, 32721.0, 178.538498),
        FVector(38687.0, 33398.0, 180.05217),
        IsProne = true
      }
    }
  },
  SecondFloor = {
    [1] = {
      BornTeamid = 8,
      BornPos = {
        FVector(38709.0, 34887.0, 557.569458),
        FVector(38702.0, 34205.0, 557.569458)
      },
      IsProne = true
    },
    [2] = {
      BornTeamid = 10,
      BornPos = {
        FVector(38688.0, 32547.0, 594.569458),
        FVector(38627.0, 33414.0, 560.570618)
      },
      IsProne = false
    }
  },
  ThirdFloor = {
    [1] = {
      BornTeamid = 9,
      BornPos = {
        FVector(38701.0, 34886.0, 937.455811),
        FVector(38672.0, 34129.0, 937.455811)
      },
      IsProne = true
    },
    [2] = {
      BornTeamid = 11,
      BornPos = {
        FVector(38706.0, 32588.0, 973.455811),
        FVector(38650.0, 33401.0, 934.455811)
      },
      IsProne = false
    }
  },
  Rooftop = {
    [1] = {
      BornTeamid = 12,
      BornPos = {
        FVector(39294.0, 34159.0, 1317.0448),
        FVector(38150.0, 34168.0, 1317.044434)
      },
      IsProne = true
    },
    [2] = {
      BornTeamid = 13,
      BornPos = {
        FVector(39294.0, 33411.0, 1356.0448),
        FVector(38118.0, 33422.0, 1356.044556)
      },
      IsProne = false
    },
    [3] = {
      BornTeamid = 25,
      BornPos = {
        FVector(39107.0, 35436.0, 1321.044556),
        FVector(38100.0, 34520.0, 1321.044434)
      },
      IsProne = true
    },
    [4] = {
      BornTeamid = 19,
      BornPos = {
        FVector(39349.0, 35458.0, 1315.044678),
        FVector(38825.0, 32117.0, 1315.044556)
      },
      IsProne = true
    }
  },
  StepSoundChallengeCfg = {
    Level2Key = {
      [1] = "Easy",
      [2] = "Intermediate",
      [3] = "Hard",
      [4] = "Endless"
    },
    Easy = {
      TraningAIAction_Move = {
        [0] = 75,
        [3] = 25
      },
      BattleTime = 150,
      BattleReward = {10, 0},
      AIBornPos = {
        [1] = {
          Pos = {2},
          TraningAIAction_Count = 1
        },
        [2] = {
          Pos = {3},
          TraningAIAction_Count = 1
        },
        [3] = {
          Pos = {2, 4},
          TraningAIAction_Count = 1
        },
        [4] = {
          Pos = {3, 5},
          TraningAIAction_Count = 1
        },
        [5] = {
          Pos = {1, 4},
          TraningAIAction_Count = 1
        },
        [6] = {
          Pos = {5},
          TraningAIAction_Count = 1
        },
        [7] = {
          Pos = {2, 3},
          TraningAIAction_Count = 1
        },
        [8] = {
          Pos = {
            1,
            2,
            3,
            4,
            5
          },
          TraningAIAction_Count = 1
        }
      }
    },
    Intermediate = {
      TraningAIAction_Move = {
        [2] = 30,
        [3] = 20,
        [0] = 50
      },
      BattleTime = 120,
      BattleReward = {10, 0},
      AIBornPos = {
        [1] = {
          Pos = {
            1,
            2,
            3
          },
          TraningAIAction_Count = 2
        },
        [2] = {
          Pos = {
            2,
            3,
            4
          },
          TraningAIAction_Count = 2
        },
        [3] = {
          Pos = {1, 5},
          TraningAIAction_Count = 2
        },
        [4] = {
          Pos = {2, 4},
          TraningAIAction_Count = 2
        },
        [5] = {
          Pos = {3, 5},
          TraningAIAction_Count = 2
        },
        [6] = {
          Pos = {
            2,
            3,
            4
          },
          TraningAIAction_Count = 2
        }
      }
    },
    Hard = {
      TraningAIAction_Move = {
        [0] = 40,
        [2] = 20,
        [3] = 20
      },
      BattleTime = 90,
      BattleReward = {10, 0},
      AIBornPos = {
        [1] = {
          Pos = {
            1,
            3,
            4
          },
          TraningAIAction_Count = 3
        },
        [2] = {
          Pos = {
            2,
            4,
            5
          },
          TraningAIAction_Count = 3
        },
        [3] = {
          Pos = {
            2,
            3,
            5
          },
          TraningAIAction_Count = 3
        },
        [4] = {
          Pos = {
            2,
            3,
            4
          },
          TraningAIAction_Count = 3
        },
        [5] = {
          Pos = {
            2,
            3,
            5
          },
          TraningAIAction_Count = 3
        },
        [6] = {
          Pos = {
            3,
            4,
            5
          },
          TraningAIAction_Count = 3
        }
      }
    },
    Endless = {
      TraningAIAction_Move = {
        [0] = 40,
        [2] = 20,
        [3] = 20
      },
      BattleTime = 25,
      BattleReward = {10, 10},
      AIBornPos = {
        [1] = {
          Pos = {2, 3},
          TraningAIAction_Count = 2
        },
        [2] = {
          Pos = {4, 5},
          TraningAIAction_Count = 2
        },
        [3] = {
          Pos = {1, 2},
          TraningAIAction_Count = 2
        },
        [4] = {
          Pos = {3, 5},
          TraningAIAction_Count = 2
        },
        [5] = {
          Pos = {2, 4},
          TraningAIAction_Count = 2
        },
        [6] = {
          Pos = {
            1,
            2,
            3
          },
          TraningAIAction_Count = 2
        },
        [7] = {
          Pos = {
            3,
            4,
            5
          },
          TraningAIAction_Count = 2
        },
        [8] = {
          Pos = {2, 5},
          TraningAIAction_Count = 2
        }
      }
    }
  },
  GunSoundChallengeCfg = {
    Level2Key = {
      [1] = "Easy",
      [2] = "Intermediate",
      [3] = "Hard",
      [4] = "Endless"
    },
    Easy = {
      TraningAIWeapon = {
        [1] = 40,
        [2] = 40,
        [3] = 20
      },
      TraningAIAction_FireGun = {
        [0] = 30
      },
      TraningAIShootingInterval = 2,
      TraningAIShootingCD = 4,
      BattleTime = 120,
      BattleReward = {10, 0},
      FailReward = {0, 0},
      AIBornPos = {
        [1] = {
          GetRandomAIPos = {
            [4001] = 25
          },
          RealFireAICount = 1
        },
        [2] = {
          GetRandomAIPos = {
            [4002] = 25
          },
          RealFireAICount = 1
        },
        [3] = {
          GetRandomAIPos = {
            [4003] = 25
          },
          RealFireAICount = 1
        },
        [4] = {
          GetRandomAIPos = {
            [4004] = 25
          },
          RealFireAICount = 1
        },
        [5] = {
          GetRandomAIPos = {
            [4005] = 25,
            [4006] = 25
          },
          RealFireAICount = 1
        },
        [6] = {
          GetRandomAIPos = {
            [4007] = 25,
            [4009] = 25
          },
          RealFireAICount = 1
        },
        [7] = {
          GetRandomAIPos = {
            [1201] = 25,
            [3011] = 25,
            [3015] = 25
          },
          RealFireAICount = 1
        },
        [8] = {
          GetRandomAIPos = {
            [1001] = 25,
            [1101] = 25,
            [1102] = 25,
            [3008] = 25,
            [3025] = 25
          },
          RealFireAICount = 1
        },
        [9] = {
          GetRandomAIPos = {
            [1201] = 25,
            [3011] = 25,
            [3015] = 25
          },
          RealFireAICount = 1
        },
        [10] = {
          GetRandomAIPos = {
            [3016] = 25,
            [4003] = 25,
            [4001] = 25
          },
          RealFireAICount = 1
        },
        [11] = {
          GetRandomAIPos = {
            [3003] = 25,
            [3020] = 25,
            [4002] = 25
          },
          RealFireAICount = 1
        },
        [12] = {
          GetRandomAIPos = {
            [3006] = 25,
            [4004] = 25,
            [4401] = 25
          },
          RealFireAICount = 1
        },
        [13] = {
          GetRandomAIPos = {
            [3011] = 25,
            [3019] = 25,
            [1401] = 25
          },
          RealFireAICount = 1
        },
        [14] = {
          GetRandomAIPos = {
            [3004] = 25,
            [1601] = 25,
            [1102] = 25
          },
          RealFireAICount = 1
        },
        [15] = {
          GetRandomAIPos = {
            [1401] = 25,
            [3026] = 25
          },
          RealFireAICount = 1
        },
        [16] = {
          GetRandomAIPos = {
            [3008] = 25,
            [1002] = 25,
            [1001] = 25
          },
          RealFireAICount = 1
        },
        [17] = {
          GetRandomAIPos = {
            [1303] = 25,
            [3024] = 25
          },
          RealFireAICount = 1
        },
        [18] = {
          GetRandomAIPos = {
            [3016] = 25,
            [3001] = 25,
            [4003] = 25
          },
          RealFireAICount = 1
        },
        [19] = {
          GetRandomAIPos = {
            [3012] = 25,
            [3007] = 25,
            [3017] = 25,
            [3009] = 25
          },
          RealFireAICount = 1
        },
        [20] = {
          GetRandomAIPos = {
            [3024] = 25,
            [1701] = 25,
            [3016] = 25
          },
          RealFireAICount = 1
        },
        [21] = {
          GetRandomAIPos = {
            [4001] = 25,
            [4004] = 25,
            [4401] = 25
          },
          RealFireAICount = 1
        }
      }
    },
    Intermediate = {
      TraningAIWeapon = {
        [1] = 60,
        [2] = 20,
        [4] = 20
      },
      TraningAIAction_FireGun = {
        [0] = 50,
        [1] = 35,
        [2] = 15
      },
      TraningAIShootingInterval = 2,
      TraningAIShootingCD = 6,
      BattleTime = 120,
      BattleReward = {10, 0},
      FailReward = {0, 0},
      AIBornPos = {
        [1] = {
          GetRandomAIPos = {
            [1105] = 25,
            [1106] = 25
          },
          RealFireAICount = 1
        },
        [2] = {
          GetRandomAIPos = {
            [1112] = 25,
            [1114] = 25
          },
          RealFireAICount = 1
        },
        [3] = {
          GetRandomAIPos = {
            [4007] = 25,
            [4009] = 25
          },
          RealFireAICount = 1
        },
        [4] = {
          GetRandomAIPos = {
            [3021] = 25,
            [1504] = 25
          },
          RealFireAICount = 1
        },
        [5] = {
          GetRandomAIPos = {
            [4402] = 25,
            [1206] = 25
          },
          RealFireAICount = 1
        },
        [6] = {
          GetRandomAIPos = {
            [1113] = 25,
            [1503] = 25
          },
          RealFireAICount = 1
        },
        [7] = {
          GetRandomAIPos = {
            [1205] = 25,
            [1202] = 25
          },
          RealFireAICount = 1
        },
        [8] = {
          GetRandomAIPos = {
            [1006] = 25,
            [1004] = 25
          },
          RealFireAICount = 1
        },
        [9] = {
          GetRandomAIPos = {
            [1119] = 25,
            [1112] = 25
          },
          RealFireAICount = 1
        },
        [10] = {
          GetRandomAIPos = {
            [1302] = 25
          },
          RealFireAICount = 1
        },
        [11] = {
          GetRandomAIPos = {
            [4404] = 25,
            [1603] = 25
          },
          RealFireAICount = 1
        },
        [12] = {
          GetRandomAIPos = {
            [1116] = 25,
            [1113] = 25
          },
          RealFireAICount = 1
        },
        [13] = {
          GetRandomAIPos = {
            [4100] = 25,
            [1606] = 25
          },
          RealFireAICount = 1
        },
        [14] = {
          GetRandomAIPos = {
            [1006] = 25,
            [4407] = 25
          },
          RealFireAICount = 1
        },
        [15] = {
          GetRandomAIPos = {
            [1113] = 25,
            [1503] = 25
          },
          RealFireAICount = 1
        },
        [16] = {
          GetRandomAIPos = {
            [1607] = 25,
            [4101] = 25
          },
          RealFireAICount = 1
        },
        [17] = {
          GetRandomAIPos = {
            [3026] = 25,
            [4406] = 25
          },
          RealFireAICount = 1
        },
        [18] = {
          GetRandomAIPos = {
            [4100] = 25,
            [1607] = 25
          },
          RealFireAICount = 1
        }
      }
    },
    Hard = {
      TraningAIWeapon = {
        [1] = 70,
        [4] = 30
      },
      TraningAIAction_FireGun = {
        [0] = 50,
        [1] = 25,
        [2] = 25
      },
      TraningAIShootingInterval = 2,
      TraningAIShootingCD = 8,
      BattleTime = 120,
      BattleReward = {10, 0},
      FailReward = {0, 0},
      AIBornPos = {
        [1] = {
          GetRandomAIPos = {
            [1117] = 50,
            [1115] = 50
          },
          RealFireAICount = 1
        },
        [2] = {
          GetRandomAIPos = {
            [1118] = 50,
            [1506] = 50
          },
          RealFireAICount = 1
        },
        [3] = {
          GetRandomAIPos = {
            [1122] = 25,
            [1123] = 25
          },
          RealFireAICount = 1
        },
        [4] = {
          GetRandomAIPos = {
            [1209] = 25,
            [1204] = 25
          },
          RealFireAICount = 1
        },
        [5] = {
          GetRandomAIPos = {
            [1118] = 25,
            [1506] = 25
          },
          RealFireAICount = 1
        },
        [6] = {
          GetRandomAIPos = {
            [1005] = 25,
            [1007] = 25
          },
          RealFireAICount = 1
        },
        [7] = {
          GetRandomAIPos = {
            [1121] = 25,
            [4700] = 25
          },
          RealFireAICount = 1
        },
        [8] = {
          GetRandomAIPos = {
            [1306] = 25,
            [4101] = 25
          },
          RealFireAICount = 1
        },
        [9] = {
          GetRandomAIPos = {
            [1605] = 25,
            [4600] = 25
          },
          RealFireAICount = 1
        },
        [10] = {
          GetRandomAIPos = {
            [1402] = 25,
            [1403] = 25
          },
          RealFireAICount = 1
        },
        [11] = {
          GetRandomAIPos = {
            [1207] = 25,
            [1211] = 25
          },
          RealFireAICount = 1
        },
        [12] = {
          GetRandomAIPos = {
            [1008] = 25,
            [1009] = 25
          },
          RealFireAICount = 1
        },
        [13] = {
          GetRandomAIPos = {
            [1703] = 25,
            [1307] = 25
          },
          RealFireAICount = 1
        },
        [14] = {
          GetRandomAIPos = {
            [1116] = 25,
            [1120] = 25,
            [1114] = 25
          },
          RealFireAICount = 1
        },
        [15] = {
          GetRandomAIPos = {
            [1207] = 25,
            [1211] = 25,
            [1210] = 25
          },
          RealFireAICount = 1
        }
      }
    },
    Endless = {
      TraningAIWeapon = {
        [1] = 100
      },
      TraningAIAction_FireGun = {
        [0] = 20,
        [1] = 20,
        [2] = 60
      },
      TraningAIShootingInterval = 2,
      TraningAIShootingCD = 6,
      BattleTime = 20,
      BattleReward = {10, 10},
      FailReward = {0, 0},
      AIBornPos = {
        [1] = {
          GetRandomAIPos = {
            [4005] = 25,
            [4006] = 25
          },
          RealFireAICount = 1
        },
        [2] = {
          GetRandomAIPos = {
            [3024] = 25,
            [1701] = 25,
            [3016] = 25
          },
          RealFireAICount = 1
        },
        [3] = {
          GetRandomAIPos = {
            [3021] = 25,
            [1504] = 25
          },
          RealFireAICount = 1
        },
        [4] = {
          GetRandomAIPos = {
            [1121] = 25,
            [4700] = 25
          },
          RealFireAICount = 1
        },
        [5] = {
          GetRandomAIPos = {
            [4001] = 25,
            [4004] = 25,
            [4401] = 25
          },
          RealFireAICount = 1
        },
        [6] = {
          GetRandomAIPos = {
            [3016] = 25,
            [3001] = 25,
            [4003] = 25
          },
          RealFireAICount = 1
        },
        [7] = {
          GetRandomAIPos = {
            [4404] = 25,
            [1603] = 25
          },
          RealFireAICount = 1
        },
        [8] = {
          GetRandomAIPos = {
            [1402] = 25,
            [1403] = 25
          },
          RealFireAICount = 1
        },
        [9] = {
          GetRandomAIPos = {
            [3008] = 25,
            [1002] = 25,
            [1001] = 25
          },
          RealFireAICount = 1
        },
        [10] = {
          GetRandomAIPos = {
            [3011] = 25,
            [3019] = 25,
            [1401] = 25
          },
          RealFireAICount = 1
        },
        [11] = {
          GetRandomAIPos = {
            [4100] = 25,
            [1606] = 25
          },
          RealFireAICount = 1
        },
        [12] = {
          GetRandomAIPos = {
            [1207] = 25,
            [1703] = 25,
            [1307] = 25
          },
          RealFireAICount = 1
        },
        [13] = {
          GetRandomAIPos = {
            [1008] = 25,
            [1009] = 25
          },
          RealFireAICount = 1
        },
        [14] = {
          GetRandomAIPos = {
            [1207] = 25,
            [1211] = 25,
            [1210] = 25
          },
          RealFireAICount = 1
        },
        [15] = {
          GetRandomAIPos = {
            [4100] = 25,
            [1606] = 25
          },
          RealFireAICount = 1
        },
        [16] = {
          GetRandomAIPos = {
            [1119] = 25,
            [1112] = 25
          },
          RealFireAICount = 1
        }
      }
    }
  },
  ChanllengeAIBornPoint = {
    [4001] = {
      Pos = FVector(36333.503906, 33764.5, 150.0),
      Rotation = FRotator(0.0, 100.000427, 0.0)
    },
    [4002] = {
      Pos = FVector(36333.503906, 31340.5, 150.0),
      Rotation = FRotator(0.0, 100.000427, 0.0)
    },
    [4003] = {
      Pos = FVector(36617.503906, 35786.5, 150.0),
      Rotation = FRotator(0.0, 100.000427, 0.0)
    },
    [4004] = {
      Pos = FVector(34917.503906, 33379.5, 40.956299),
      Rotation = FRotator(0.0, 100.000427, 0.0)
    },
    [4005] = {
      Pos = FVector(35202.503906, 37860.5, 150.0),
      Rotation = FRotator(0.0, 100.000427, 0.0)
    },
    [4006] = {
      Pos = FVector(35202.503906, 30120.5, 23.763535),
      Rotation = FRotator(0.0, 100.000427, 0.0)
    },
    [4007] = {
      Pos = FVector(32949.503906, 34279.5, 34.101608),
      Rotation = FRotator(0.0, 100.000427, 0.0)
    },
    [4009] = {
      Pos = FVector(32950.503906, 31944.5, 39.101608),
      Rotation = FRotator(0.0, 100.000458, 0.0)
    },
    [1201] = {
      Pos = FVector(38457.503906, 30094.5, 610.0),
      Rotation = FRotator(0.0, 100.000427, 0.0)
    },
    [3011] = {
      Pos = FVector(39738.503906, 30100.5, 534.913635),
      Rotation = FRotator(0.0, 100.000427, 0.0)
    },
    [3015] = {
      Pos = FVector(37096.285156, 30090.648438, 541.0),
      Rotation = FRotator(0.0, 10.00001, 0.0)
    },
    [1001] = {
      Pos = FVector(41597.0, 33466.0, 703.0),
      Rotation = FRotator(0.0, 179.999893, 0.0)
    },
    [1101] = {
      Pos = FVector(41567.203125, 32244.957031, 390.897339),
      Rotation = FRotator(0.0, 0.0, 0.0)
    },
    [1102] = {
      Pos = FVector(43099.0, 34169.0, 646.0),
      Rotation = FRotator(0.0, 0.0, 0.0)
    },
    [3008] = {
      Pos = FVector(42600.671875, 32930.308594, 723.0),
      Rotation = FRotator(0.0, -144.999969, 0.0)
    },
    [3025] = {
      Pos = FVector(43547.671875, 33641.308594, 651.0),
      Rotation = FRotator(0.0, -144.999969, 0.0)
    },
    [3015] = {
      Pos = FVector(37096.285156, 30230.648438, 541.0),
      Rotation = FRotator(0.0, 10.00001, 0.0)
    },
    [3016] = {
      Pos = FVector(36919.285156, 36049.648438, 138.0),
      Rotation = FRotator(0.0, 10.00001, 0.0)
    },
    [3003] = {
      Pos = FVector(36191.503906, 30427.5, 150.0),
      Rotation = FRotator(0.0, 100.000427, 0.0)
    },
    [3020] = {
      Pos = FVector(36885.503906, 29747.5, 416.913635),
      Rotation = FRotator(0.0, 100.000427, 0.0)
    },
    [3006] = {
      Pos = FVector(35398.503906, 35749.5, 150.0),
      Rotation = FRotator(0.0, 100.000427, 0.0)
    },
    [4401] = {
      Pos = FVector(34783.0, 33717.0, 40.908203),
      Rotation = FRotator(0.0, 0.0, 0.0)
    },
    [3019] = {
      Pos = FVector(41039.503906, 29747.5, 416.913635),
      Rotation = FRotator(0.0, 100.000427, 0.0)
    },
    [1401] = {
      Pos = FVector(41310.0, 31284.0, 130.897308),
      Rotation = FRotator(0.0, 154.999985, 0.0)
    },
    [3004] = {
      Pos = FVector(41967.503906, 34641.5, 710.0),
      Rotation = FRotator(0.0, 100.000427, 0.0)
    },
    [1601] = {
      Pos = FVector(42574.671875, 34549.308594, 723.0),
      Rotation = FRotator(0.0, -144.999969, 0.0)
    },
    [3026] = {
      Pos = FVector(42438.0, 29205.0, 704.13916),
      Rotation = FRotator(0.0, 179.999893, 0.0)
    },
    [1002] = {
      Pos = FVector(43105.0, 33163.0, 642.0),
      Rotation = FRotator(0.0, 179.999893, 0.0)
    },
    [1303] = {
      Pos = FVector(39123.0, 37481.0, 557.823059),
      Rotation = FRotator(0.0, -84.999817, 0.0)
    },
    [3024] = {
      Pos = FVector(38237.0, 37492.0, 552.897339),
      Rotation = FRotator(0.0, 179.999893, 0.0)
    },
    [3001] = {
      Pos = FVector(36392.503906, 36297.5, 163.0),
      Rotation = FRotator(0.0, 100.000427, 0.0)
    },
    [3012] = {
      Pos = FVector(41219.0, 37679.0, 473.13916),
      Rotation = FRotator(0.0, 179.999893, 0.0)
    },
    [3007] = {
      Pos = FVector(40013.0, 37468.0, 570.0),
      Rotation = FRotator(0.0, 179.999893, 0.0)
    },
    [3017] = {
      Pos = FVector(41236.285156, 36121.648438, 148.0),
      Rotation = FRotator(0.0, 10.00001, 0.0)
    },
    [3009] = {
      Pos = FVector(41597.0, 36223.0, 132.897339),
      Rotation = FRotator(0.0, 179.999893, 0.0)
    },
    [1701] = {
      Pos = FVector(36796.503906, 37747.789063, 459.099915),
      Rotation = FRotator(0.0, -75.0, 0.0)
    },
    [1105] = {
      Pos = FVector(33308.0, 31494.0, 51.7034),
      Rotation = FRotator(0.0, 0.0, 0.0)
    },
    [1106] = {
      Pos = FVector(34409.0, 32695.0, 36.909149),
      Rotation = FRotator(0.0, 0.0, 0.0)
    },
    [1112] = {
      Pos = FVector(31520.671875, 38840.097656, 430.922913),
      Rotation = FRotator(0.0, 0.0, 0.0)
    },
    [1114] = {
      Pos = FVector(32547.0, 38689.0, 443.70343),
      Rotation = FRotator(0.0, 0.0, 0.0)
    },
    [3021] = {
      Pos = FVector(33134.0, 26089.0, 412.188049),
      Rotation = FRotator(0.0, 179.999893, 0.0)
    },
    [1504] = {
      Pos = FVector(33266.0, 28522.0, 46.590454),
      Rotation = FRotator(0.0, 10.000067, 0.0)
    },
    [4402] = {
      Pos = FVector(37562.972656, 25364.689453, 59.0),
      Rotation = FRotator(0.0, -84.999786, 0.0)
    },
    [1206] = {
      Pos = FVector(39641.0, 25156.0, 130.521271),
      Rotation = FRotator(0.0, 95.000267, 0.0)
    },
    [1113] = {
      Pos = FVector(30817.0, 31884.0, 145.70343),
      Rotation = FRotator(0.0, 0.0, 0.0)
    },
    [1503] = {
      Pos = FVector(31458.0, 29030.0, 50.096527),
      Rotation = FRotator(0.0, 55.000011, 0.0)
    },
    [1202] = {
      Pos = FVector(39880.503906, 26327.5, 245.0),
      Rotation = FRotator(0.0, 95.000381, 0.0)
    },
    [1205] = {
      Pos = FVector(41814.0, 24741.0, 394.521271),
      Rotation = FRotator(0.0, 95.000267, 0.0)
    },
    [1006] = {
      Pos = FVector(45533.0, 35810.0, 663.0),
      Rotation = FRotator(0.0, 179.999893, 0.0)
    },
    [1004] = {
      Pos = FVector(45385.003906, 33597.003906, 661.0),
      Rotation = FRotator(0.0, 179.999893, 0.0)
    },
    [1119] = {
      Pos = FVector(30699.0, 38432.0, 115.291534),
      Rotation = FRotator(0.0, 0.0, 0.0)
    },
    [1302] = {
      Pos = FVector(37903.0, 41091.0, 719.823059),
      Rotation = FRotator(0.0, -84.999817, 0.0)
    },
    [4404] = {
      Pos = FVector(41233.652344, 40436.28125, 658.0),
      Rotation = FRotator(0.0, -144.999939, 0.0)
    },
    [1603] = {
      Pos = FVector(41909.671875, 40764.308594, 942.0),
      Rotation = FRotator(0.0, -144.999939, 0.0)
    },
    [1116] = {
      Pos = FVector(32252.0, 33859.0, 34.398758),
      Rotation = FRotator(0.0, 0.0, 0.0)
    },
    [4100] = {
      Pos = FVector(41641.921875, 40998.113281, 2565.172363),
      Rotation = FRotator(0.0, -164.999695, 0.0)
    },
    [1606] = {
      Pos = FVector(41815.921875, 41163.113281, 3181.172363),
      Rotation = FRotator(0.0, -164.999695, 0.0)
    },
    [4407] = {
      Pos = FVector(46138.0, 37042.0, 655.0),
      Rotation = FRotator(0.0, 179.999893, 0.0)
    },
    [1607] = {
      Pos = FVector(40319.921875, 41164.113281, 3181.172363),
      Rotation = FRotator(0.0, -164.999649, 0.0)
    },
    [4101] = {
      Pos = FVector(39879.921875, 42306.113281, 1836.172363),
      Rotation = FRotator(0.0, -164.999649, 0.0)
    },
    [4406] = {
      Pos = FVector(45239.003906, 29729.996094, 661.0),
      Rotation = FRotator(0.0, 179.999893, 0.0)
    },
    [1117] = {
      Pos = FVector(29373.0, 36396.0, 25.839127),
      Rotation = FRotator(0.0, 0.0, 0.0)
    },
    [1115] = {
      Pos = FVector(29221.0, 39493.0, 24.346802),
      Rotation = FRotator(0.0, 0.0, 0.0)
    },
    [1118] = {
      Pos = FVector(28025.0, 32214.0, 83.45459),
      Rotation = FRotator(0.0, 0.0, 0.0)
    },
    [1506] = {
      Pos = FVector(28744.0, 29517.0, 201.102661),
      Rotation = FRotator(0.0, 55.000008, 0.0)
    },
    [1122] = {
      Pos = FVector(24722.0, 39872.0, 75.857056),
      Rotation = FRotator(0.0, 0.0, 0.0)
    },
    [1123] = {
      Pos = FVector(24723.0, 36079.0, 75.857056),
      Rotation = FRotator(0.0, 0.0, 0.0)
    },
    [1209] = {
      Pos = FVector(41876.0, 22970.0, 330.669861),
      Rotation = FRotator(0.0, 95.000275, 0.0)
    },
    [1204] = {
      Pos = FVector(40495.0, 22630.0, 145.669861),
      Rotation = FRotator(0.0, 95.000298, 0.0)
    },
    [1005] = {
      Pos = FVector(48732.0, 33965.0, 1219.0),
      Rotation = FRotator(0.0, 179.999893, 0.0)
    },
    [1007] = {
      Pos = FVector(49073.0, 34035.0, 1769.244507),
      Rotation = FRotator(0.0, 179.999893, 0.0)
    },
    [1121] = {
      Pos = FVector(24346.0, 38162.0, 619.857056),
      Rotation = FRotator(0.0, 0.0, 0.0)
    },
    [4700] = {
      Pos = FVector(24758.0, 33504.0, 546.817078),
      Rotation = FRotator(0.0, 0.0, 0.0)
    },
    [1306] = {
      Pos = FVector(36237.0, 42699.0, 1187.341797),
      Rotation = FRotator(0.0, -84.999817, 0.0)
    },
    [1605] = {
      Pos = FVector(47550.0, 41837.0, 1129.411987),
      Rotation = FRotator(0.0, -165.000031, 0.0)
    },
    [4600] = {
      Pos = FVector(48355.0, 43947.0, 1123.433716),
      Rotation = FRotator(0.0, -165.000031, 0.0)
    },
    [1402] = {
      Pos = FVector(48084.0, 30793.0, 674.091919),
      Rotation = FRotator(0.0, 99.999985, 0.0)
    },
    [1403] = {
      Pos = FVector(49660.390625, 28334.755859, 670.016296),
      Rotation = FRotator(0.0, 99.99987, 0.0)
    },
    [1207] = {
      Pos = FVector(40496.0, 18894.0, 288.710571),
      Rotation = FRotator(0.0, 95.000298, 0.0)
    },
    [1211] = {
      Pos = FVector(41322.0, 18358.0, 569.710571),
      Rotation = FRotator(0.0, 95.000275, 0.0)
    },
    [1008] = {
      Pos = FVector(49337.0, 36773.0, 1661.244507),
      Rotation = FRotator(0.0, 179.999893, 0.0)
    },
    [1009] = {
      Pos = FVector(49106.0, 37996.0, 1797.244507),
      Rotation = FRotator(0.0, 179.999893, 0.0)
    },
    [1703] = {
      Pos = FVector(34507.0, 47411.0, 2793.290771),
      Rotation = FRotator(0.0, -74.999939, 0.0)
    },
    [1307] = {
      Pos = FVector(35603.0, 50383.0, 2824.716797),
      Rotation = FRotator(0.0, -84.999817, 0.0)
    },
    [1120] = {
      Pos = FVector(31365.0, 35206.0, 39.908302),
      Rotation = FRotator(0.0, 0.0, 0.0)
    },
    [1210] = {
      Pos = FVector(40218.0, 16532.0, 1522.710571),
      Rotation = FRotator(0.0, 95.000275, 0.0)
    }
  }
}
return ChanllengeConfig