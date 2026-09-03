local GameReportConfig = {}
GameReportConfig.BugglyConfigs = {
  CharacterMoveableException = {
    ReportName = "CharacterMoveableException",
    ReportIndex = 1,
    Conditions = {
      ModeType = UEnums.EBugglyReportModeType.BRMode,
      FreqType = UEnums.EBugglyReportFreqType.GameOnce,
      HitCount = 5
    },
    ReportInfo = {
      "PlayerInfo",
      "SkillInfo",
      "BuffInfo",
      "PlayerAttrInfo"
    }
  },
  CharacterMoveSlowException = {
    ReportName = "CharacterMoveSlowException",
    ReportIndex = 2,
    Conditions = {
      ModeType = UEnums.EBugglyReportModeType.AllMode,
      FreqType = UEnums.EBugglyReportFreqType.GameOnce,
      Probability = 1,
      HitCount = 4
    },
    ReportInfo = {
      "PlayerInfo",
      "SkillInfo",
      "BuffInfo",
      "PlayerAttrInfo"
    }
  },
  AvatarExceptionReport = {
    ReportName = "AvatarExceptionReport",
    ReportIndex = 3,
    Conditions = {
      ModeType = UEnums.EBugglyReportModeType.BRAndTPlanMode,
      FreqType = UEnums.EBugglyReportFreqType.GameOnce,
      Probability = 10,
      HitCount = 1
    },
    ReportInfo = {"PlayerInfo"}
  },
  TeammateDisappearException = {
    ReportName = "TeammateDisappearException",
    ReportIndex = 7,
    Conditions = {
      ModeType = UEnums.EBugglyReportModeType.BRAndTPlanMode,
      FreqType = UEnums.EBugglyReportFreqType.GameOnce,
      Probability = 1,
      HitCount = 1
    },
    ReportInfo = {"PlayerInfo"}
  },
  WalkSpeedCurveScaleException = {
    ReportName = "WalkSpeedCurveScaleException",
    ReportIndex = 8,
    Conditions = {
      ModeType = UEnums.EBugglyReportModeType.AllMode,
      FreqType = UEnums.EBugglyReportFreqType.GameOnce,
      HitCount = 1
    },
    ReportInfo = {
      "PlayerInfo",
      "SkillInfo",
      "BuffInfo",
      "PlayerAttrInfo"
    }
  },
  AvatarExceptionReport_AllSlotCheck = {
    ReportName = "AvatarExceptionReport_AllSlotCheck",
    ReportIndex = 9,
    Conditions = {
      ModeType = UEnums.EBugglyReportModeType.BRAndTPlanMode,
      FreqType = UEnums.EBugglyReportFreqType.GameOnce,
      Probability = 100,
      HitCount = 1
    },
    ReportInfo = {
      "PlayerInfo",
      "CharacterMeshInfo",
      "OtherCharacterMeshInfo"
    }
  },
  BackpackPanelError = {
    ReportName = "BackpackPanelError",
    ReportIndex = 10,
    Conditions = {
      ModeType = UEnums.EBugglyReportModeType.AllMode,
      FreqType = UEnums.EBugglyReportFreqType.LoadingOnce,
      Probability = 1,
      HitCount = 1
    },
    ReportInfo = {"PlayerInfo"}
  },
  ClientNetContinuousSaturate = {
    ReportName = "ClientNetContinuousSaturate",
    ReportIndex = 13,
    Conditions = {
      ModeType = UEnums.EBugglyReportModeType.AllMode,
      FreqType = UEnums.EBugglyReportFreqType.Always,
      Probability = 1000,
      HitCount = 1
    },
    ReportInfo = {"PlayerInfo"}
  },
  ClientGameModeStateError = {
    ReportName = "ClientGameModeStateError",
    ReportIndex = 14,
    Conditions = {
      ModeType = UEnums.EBugglyReportModeType.BRAndTPlanMode,
      FreqType = UEnums.EBugglyReportFreqType.GameOnce,
      Probability = 10,
      HitCount = 1
    },
    ReportInfo = {"PlayerInfo"}
  },
  AudioNumberTooMuch = {
    ReportName = "AudioNumberTooMuch",
    Conditions = {
      ModeType = UEnums.EBugglyReportModeType.AllMode,
      FreqType = UEnums.EBugglyReportFreqType.GameOnce,
      Probability = 1,
      HitCount = 1
    },
    ReportInfo = {"PlayerInfo"}
  },
  AudioNotEnoughMemoryToAlloc = {
    ReportName = "AudioNotEnoughMemoryToAlloc",
    Conditions = {
      ModeType = UEnums.EBugglyReportModeType.AllMode,
      FreqType = UEnums.EBugglyReportFreqType.GameOnce,
      Probability = 1,
      HitCount = 1
    },
    ReportInfo = {"PlayerInfo"}
  },
  ForbiddenMoveException = {
    ReportName = "ForbiddenMoveException",
    ReportIndex = 18,
    Conditions = {
      ModeType = UEnums.EBugglyReportModeType.BRAndTPlanMode,
      FreqType = UEnums.EBugglyReportFreqType.GameOnce,
      Probability = 1,
      HitCount = 1
    },
    ReportInfo = {"PlayerInfo"}
  },
  CharacterScaleException = {
    ReportName = "CharacterScaleException",
    ReportIndex = 19,
    Conditions = {
      ModeType = UEnums.EBugglyReportModeType.BRMode,
      FreqType = UEnums.EBugglyReportFreqType.GameOnce,
      Probability = 1,
      HitCount = 1
    },
    ReportInfo = {"PlayerInfo"}
  },
  PlayerCannotLeaveVehicle = {
    ReportName = "PlayerCannotLeaveVehicle",
    ReportIndex = 21,
    Conditions = {
      ModeType = UEnums.EBugglyReportModeType.BRMode,
      FreqType = UEnums.EBugglyReportFreqType.Always,
      Probability = 1000,
      HitCount = 1
    },
    ReportInfo = {"PlayerInfo"}
  },
  TPlanAffixAttrInfo = {
    ReportName = "TPlanAffixAttrInfo",
    ReportIndex = 22,
    Conditions = {
      ModeType = UEnums.EBugglyReportModeType.TPlanMode,
      FreqType = UEnums.EBugglyReportFreqType.GameOnce,
      Probability = 1,
      HitCount = 1
    },
    ReportInfo = {
      "PlayerInfo",
      "PlayerAttrInfo"
    }
  },
  FightingStateStateMachineError = {
    ReportName = "FightingStateStateMachineError",
    ReportIndex = 28,
    Conditions = {
      ModeType = UEnums.EBugglyReportModeType.AllMode,
      FreqType = UEnums.EBugglyReportFreqType.LoadingOnce,
      Probability = 1,
      HitCount = 1
    },
    ReportInfo = {"PlayerInfo"}
  },
  AliveNumInfoError = {
    ReportName = "AliveNumInfoError",
    ReportIndex = 29,
    Conditions = {
      ModeType = UEnums.EBugglyReportModeType.AllMode,
      FreqType = UEnums.EBugglyReportFreqType.LoadingOnce,
      Probability = 5000,
      HitCount = 1
    },
    ReportInfo = {"PlayerInfo"}
  },
  SkillServerTriggerException = {
    ReportName = "SkillServerTriggerException",
    ReportIndex = 32,
    Conditions = {
      ModeType = UEnums.EBugglyReportModeType.BRMode,
      FreqType = UEnums.EBugglyReportFreqType.GameOnce,
      Probability = 100,
      HitCount = 1
    },
    ReportInfo = {
      "PlayerInfo",
      "SkillInfo",
      "SkillNetInfo"
    }
  }
}
GameReportConfig.ReplayConfigs = {
  [1] = {
    Type = UEnums.EReplayReportRPCType.UInt8ArrayUnReliable,
    ReportInterval = 0.5,
    bOnlyReportLatest = true,
    HandleFunc = "OnReportUIState"
  },
  [2] = {
    Type = UEnums.EReplayReportRPCType.UInt8ArrayReliable,
    ReportInterval = 0,
    bOnlyReportLatest = false,
    HandleFunc = "OnReceiveBattleResult"
  },
  [3] = {
    Type = UEnums.EReplayReportRPCType.UInt8ArrayUnReliable,
    ReportInterval = 0,
    bOnlyReportLatest = false,
    HandleFunc = "OnUpdateBattleResultPeriod"
  },
  [4] = {
    Type = UEnums.EReplayReportRPCType.IntArrayUnReliable,
    ReportInterval = 1,
    bOnlyReportLatest = true,
    HandleFunc = "OnReportAvatarNetData"
  },
  [7] = {
    Type = UEnums.EReplayReportRPCType.FloatArrayUnReliable,
    ReportInterval = 1,
    bOnlyReportLatest = false,
    HandleFunc = "OnReportParachuteAvgSpeed"
  }
}
if Client and Client.IsDevelopment() then
  GameReportConfig.BugglyConfigs.AvatarExceptionReport.Conditions.Probability = 1
  GameReportConfig.BugglyConfigs.AvatarExceptionReport.Conditions.FreqType = UEnums.EBugglyReportFreqType.Always
  GameReportConfig.BugglyConfigs.AvatarExceptionReport_AllSlotCheck.Conditions.Probability = 1
  GameReportConfig.BugglyConfigs.AvatarExceptionReport_AllSlotCheck.Conditions.FreqType = UEnums.EBugglyReportFreqType.Always
end
function GameReportConfig.GetBugglyConfig(ReportName)
  return GameReportConfig.BugglyConfigs[ReportName]
end
function GameReportConfig.GetReplayConfig(ID)
  return GameReportConfig.ReplayConfigs[ID]
end
function GameReportConfig.GetAllBugglyConfigNames()
  local Names = {}
  for Name, _ in pairs(GameReportConfig.BugglyConfigs) do
    table.insert(Names, Name)
  end
  return Names
end
function GameReportConfig.GetAllReplayConfigIDs()
  local IDs = {}
  for ID, _ in pairs(GameReportConfig.ReplayConfigs) do
    table.insert(IDs, ID)
  end
  return IDs
end
return GameReportConfig