local ExtraPlayerLiveState = import("ExtraPlayerLiveState")
local VoiceRecommendationConfig = {
  ReplayVoice = {
    [1] = {
      [33002] = false,
      [33001] = true
    },
    [2] = {
      [30069] = true
    },
    [3] = {
      [30034] = false
    },
    [4] = {
      [30051] = false
    },
    [5] = {
      [33010] = false
    }
  },
  VoiceConfig = {
    [1] = {
      Condition = {
        MainCondition = {
          LuaPath = "GameLua.Mod.Library.Client.VoiceRecommendation.Conditions.VoiceRecommendHasStateCondition",
          Params = {
            State = {
              ExtraPlayerLiveState.InDying
            },
            CDTime = 30,
            bRegistEvent = true
          }
        },
        AndCondition = {
          [1] = {
            LuaPath = "GameLua.Mod.Library.Client.VoiceRecommendation.Conditions.VoiceRecommendHasPropertyCondition",
            Params = {
              PropertyName = "IsBeingRescued",
              DataType = "Character",
              TargetValue = false,
              CompareType = UEnums.CompareType.Equal
            }
          },
          [2] = {
            LuaPath = "GameLua.Mod.Library.Client.VoiceRecommendation.Conditions.VoiceRecommendSearchTeammateCondition",
            Params = {
              DistanceSquared = 400000000,
              CompareType = UEnums.CompareType.LessEqual,
              TargetNum = 1
            }
          }
        },
        OrCondition = nil
      },
      Voice = {
        [1] = 33002,
        [2] = 33001
      },
      Priority = 1,
      Type = 1
    },
    [2] = {
      Condition = {
        MainCondition = {
          LuaPath = "GameLua.Mod.Library.Client.VoiceRecommendation.Conditions.VoiceRecommendHasStateCondition",
          Params = {
            State = {
              ExtraPlayerLiveState.InVehicle,
              ExtraPlayerLiveState.InDefault
            },
            CDTime = 30,
            bRegistEvent = true
          }
        },
        AndCondition = {
          [1] = {
            LuaPath = "GameLua.Mod.Library.Client.VoiceRecommendation.Conditions.VoiceRecommendSearchTeammateCondition",
            Params = {
              DistanceSquared = 225000000,
              CompareType = UEnums.CompareType.LessEqual,
              TargetNum = 1,
              PreSearchFunc = "NoVehiclePreSearchFunction",
              SearchFunc = "NoVehicleSearchFunction"
            }
          }
        },
        OrCondition = nil
      },
      Voice = {
        [1] = 30069
      },
      Priority = 2,
      Type = 2
    },
    [3] = {
      Condition = {
        MainCondition = nil,
        AndCondition = {
          [1] = {
            LuaPath = "GameLua.Mod.Library.Client.VoiceRecommendation.Conditions.VoiceRecommendCircleCondition",
            Params = {
              BeginCountDownTime = 20,
              IncludeBlurCircleRun = true,
              ComputeType = "Ratio",
              CompareType = UEnums.CompareType.Greater,
              TagetValue = 2,
              TargetTeammateNum = 1
            }
          }
        },
        OrCondition = nil
      },
      Voice = {
        [1] = 30034
      },
      Priority = 3,
      Type = 3
    },
    [4] = {
      Condition = {
        MainCondition = nil,
        AndCondition = {
          [1] = {
            LuaPath = "GameLua.Mod.Library.Client.VoiceRecommendation.Conditions.VoiceRecommendHasStateCondition",
            Params = {
              State = {
                ExtraPlayerLiveState.InVehicle,
                ExtraPlayerLiveState.InDefault
              },
              bRegistEvent = false
            }
          },
          [2] = {
            LuaPath = "GameLua.Mod.Library.Client.VoiceRecommendation.Conditions.VoiceRecommendHasPropertyCondition",
            Params = {
              PropertyName = "Health",
              DataType = "Character",
              TargetValue = 30,
              CompareType = UEnums.CompareType.LessEqual
            }
          },
          [3] = {
            LuaPath = "GameLua.Mod.Library.Client.VoiceRecommendation.Conditions.VoiceRecommendHasItemCondition",
            Params = {
              [1] = {
                ItemIDList = nil,
                SubType = {
                  [1] = 601
                },
                ExcludeIDList = {
                  [1] = 601004,
                  [2] = 601009
                },
                TargetNum = 0,
                CompareType = UEnums.CompareType.LessEqual
              }
            }
          }
        },
        OrCondition = nil
      },
      Voice = {
        [1] = 30051
      },
      Priority = 4,
      Type = 4
    },
    [5] = {
      Condition = {
        MainCondition = {
          LuaPath = "GameLua.Mod.Library.Client.VoiceRecommendation.Conditions.VoiceRecommendTeammateHasPropertyCondition",
          Params = {
            PropertyName = "bCounterattacking",
            DataType = "Character",
            TargetValue = true,
            CompareType = UEnums.CompareType.Equal
          }
        },
        AndCondition = {
          [1] = {
            LuaPath = "GameLua.Mod.Library.Client.VoiceRecommendation.Conditions.VoiceRecommendSearchTeammateCondition",
            Params = {
              DistanceSquared = 100000000,
              CompareType = UEnums.CompareType.LessEqual,
              TargetNum = 1
            }
          }
        }
      },
      Voice = {
        [1] = 33010
      },
      Priority = 5,
      Type = 5
    }
  }
}
return VoiceRecommendationConfig