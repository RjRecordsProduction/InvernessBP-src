local BugglyReportConfig = {
  CharacterMoveableException = {
    ReportIndex = 1,
    ReportType = UEnums.EBugglyReportModeType.BRMode,
    ReportFreqType = UEnums.EBugglyReportFreqType.GameOnce,
    ReportHitCount = 5,
    ReportInfo = {
      "PlayerInfo",
      "SkillInfo",
      "BuffInfo",
      "PlayerAttrInfo"
    }
  },
  CharacterMoveSlowException = {
    ReportIndex = 2,
    ReportType = UEnums.EBugglyReportModeType.AllMode,
    ReportFreqType = UEnums.EBugglyReportFreqType.GameOnce,
    ReportProbability = 1,
    ReportHitCount = 4,
    ReportInfo = {
      "PlayerInfo",
      "SkillInfo",
      "BuffInfo",
      "PlayerAttrInfo"
    }
  },
  AvatarExceptionReport = {
    ReportIndex = 3,
    ReportType = UEnums.EBugglyReportModeType.BRAndTPlanMode,
    ReportFreqType = UEnums.EBugglyReportFreqType.GameOnce,
    ReportProbability = 10,
    ReportHitCount = 1,
    ReportInfo = {"PlayerInfo"}
  },
  AttrModifierException = {
    ReportIndex = 5,
    ReportType = UEnums.EBugglyReportModeType.AllMode,
    ReportFreqType = UEnums.EBugglyReportFreqType.GameOnce,
    ReportHitCount = 1,
    ReportInfo = {
      "PlayerInfo",
      "SkillInfo",
      "BuffInfo",
      "PlayerAttrInfo"
    }
  },
  MoveSpeedException = {
    ReportIndex = 6,
    ReportType = UEnums.EBugglyReportModeType.AllMode,
    ReportFreqType = UEnums.EBugglyReportFreqType.GameOnce,
    ReportHitCount = 1,
    ReportInfo = {
      "PlayerInfo",
      "SkillInfo",
      "BuffInfo",
      "PlayerAttrInfo"
    }
  },
  TeammateDisappearException = {
    ReportIndex = 7,
    ReportType = UEnums.EBugglyReportModeType.AllMode,
    ReportFreqType = UEnums.EBugglyReportFreqType.GameOnce,
    ReportProbability = 1,
    ReportHitCount = 1,
    ReportInfo = {"PlayerInfo"}
  },
  WalkSpeedCurveScaleException = {
    ReportIndex = 8,
    ReportType = UEnums.EBugglyReportModeType.AllMode,
    ReportFreqType = UEnums.EBugglyReportFreqType.GameOnce,
    ReportHitCount = 1,
    ReportInfo = {
      "PlayerInfo",
      "SkillInfo",
      "BuffInfo",
      "PlayerAttrInfo"
    }
  },
  AvatarExceptionReport_AllSlotCheck = {
    ReportIndex = 9,
    ReportType = UEnums.EBugglyReportModeType.BRAndTPlanMode,
    ReportFreqType = UEnums.EBugglyReportFreqType.GameOnce,
    ReportProbability = 100,
    ReportHitCount = 1,
    ReportInfo = {
      "PlayerInfo",
      "CharacterMeshInfo",
      "OtherCharacterMeshInfo"
    }
  },
  BackpackPanelError = {
    ReportIndex = 10,
    ReportType = UEnums.EBugglyReportModeType.AllMode,
    ReportFreqType = UEnums.EBugglyReportFreqType.LoadingOnce,
    ReportProbability = 1,
    ReportHitCount = 1,
    ReportInfo = {"PlayerInfo"}
  },
  BattleResultChildWindowException = {
    ReportIndex = 11,
    ReportType = UEnums.EBugglyReportModeType.AllMode,
    ReportFreqType = UEnums.EBugglyReportFreqType.GameOnce,
    ReportProbability = 1,
    ReportHitCount = 1,
    ReportInfo = {"PlayerInfo"}
  },
  InteractItemError = {
    ReportIndex = 12,
    ReportType = UEnums.EBugglyReportModeType.BRMode,
    ReportFreqType = UEnums.EBugglyReportFreqType.LoadingOnce,
    ReportProbability = 1,
    ReportHitCount = 1,
    ReportInfo = {"PlayerInfo"}
  },
  ClientNetContinuousSaturate = {
    ReportIndex = 13,
    ReportType = UEnums.EBugglyReportModeType.AllMode,
    ReportFreqType = UEnums.EBugglyReportFreqType.Always,
    ReportProbability = 1000,
    ReportHitCount = 1,
    ReportInfo = {"PlayerInfo"}
  },
  ClientGameModeStateError = {
    ReportIndex = 14,
    ReportType = UEnums.EBugglyReportModeType.BRAndTPlanMode,
    ReportFreqType = UEnums.EBugglyReportFreqType.GameOnce,
    ReportProbability = 10,
    ReportHitCount = 1,
    ReportInfo = {"PlayerInfo"}
  },
  AudioNumberTooMuch = {
    ReportType = UEnums.EBugglyReportModeType.AllMode,
    ReportFreqType = UEnums.EBugglyReportFreqType.GameOnce,
    ReportProbability = 1000,
    ReportHitCount = 1,
    ReportInfo = {"PlayerInfo"}
  },
  AudioNotEnoughMemoryToAlloc = {
    ReportType = UEnums.EBugglyReportModeType.AllMode,
    ReportFreqType = UEnums.EBugglyReportFreqType.GameOnce,
    ReportProbability = 1000,
    ReportHitCount = 1,
    ReportInfo = {"PlayerInfo"}
  },
  SettingCustomDifferences = {
    ReportIndex = 15,
    ReportType = UEnums.EBugglyReportModeType.BRAndTPlanMode,
    ReportFreqType = UEnums.EBugglyReportFreqType.GameOnce,
    ReportProbability = 10,
    ReportHitCount = 1,
    ReportInfo = {
      "SettingCustomDifferences"
    }
  },
  AroundPlayerInfo = {
    ReportIndex = 17,
    ReportType = UEnums.EBugglyReportModeType.BRMode,
    ReportFreqType = UEnums.EBugglyReportFreqType.GameOnce,
    ReportProbability = 10000,
    ReportHitCount = 1,
    ReportInfo = {"PlayerInfo"}
  },
  ForbiddenMoveException = {
    ReportIndex = 18,
    ReportType = UEnums.EBugglyReportModeType.BRMode,
    ReportFreqType = UEnums.EBugglyReportFreqType.GameOnce,
    ReportProbability = 1,
    ReportHitCount = 12,
    ReportInfo = {
      "PlayerInfo",
      "SkillInfo",
      "BuffInfo",
      "PlayerAttrInfo"
    }
  },
  CharacterScaleException = {
    ReportIndex = 19,
    ReportType = UEnums.EBugglyReportModeType.BRMode,
    ReportFreqType = UEnums.EBugglyReportFreqType.GameOnce,
    ReportProbability = 1,
    ReportHitCount = 1,
    ReportInfo = {"PlayerInfo"}
  },
  PlayerCannotLeaveVehicle = {
    ReportIndex = 21,
    ReportType = UEnums.EBugglyReportModeType.BRMode,
    ReportFreqType = UEnums.EBugglyReportFreqType.Always,
    ReportProbability = 1000,
    ReportHitCount = 1,
    ReportInfo = {"PlayerInfo"}
  },
  TPlanAffixAttrInfo = {
    ReportIndex = 22,
    ReportType = UEnums.EBugglyReportModeType.TPlanMode,
    ReportFreqType = UEnums.EBugglyReportFreqType.GameOnce,
    ReportProbability = 1,
    ReportHitCount = 1,
    ReportInfo = {
      "PlayerInfo",
      "PlayerAttrInfo"
    }
  },
  MoveSkipTickException = {
    ReportIndex = 23,
    ReportType = UEnums.EBugglyReportModeType.BRMode,
    ReportFreqType = UEnums.EBugglyReportFreqType.GameOnce,
    ReportProbability = 10000,
    ReportHitCount = 1,
    ReportInfo = {
      "PlayerInfo",
      "SkillInfo",
      "BuffInfo",
      "PlayerAttrInfo"
    }
  },
  ShootWeaponPositionException = {
    ReportIndex = 24,
    ReportType = UEnums.EBugglyReportModeType.BRMode,
    ReportFreqType = UEnums.EBugglyReportFreqType.GameOnce,
    ReportProbability = 1,
    ReportHitCount = 1,
    ReportInfo = {"PlayerInfo"}
  },
  TDMPlayerNumOverflowException = {
    ReportIndex = 25,
    ReportType = UEnums.EBugglyReportModeType.TDMMode,
    ReportFreqType = UEnums.EBugglyReportFreqType.Always,
    ReportProbability = 1,
    ReportHitCount = 1,
    ReportInfo = {"PlayerInfo"}
  },
  WeaponAvatarDataError = {
    ReportIndex = 26,
    ReportType = UEnums.EBugglyReportModeType.AllMode,
    ReportFreqType = UEnums.EBugglyReportFreqType.LoadingOnce,
    ReportProbability = 1,
    ReportHitCount = 1,
    ReportInfo = {"PlayerInfo"}
  },
  AttachVehicleException = {
    ReportIndex = 27,
    ReportType = UEnums.EBugglyReportModeType.BRMode,
    ReportFreqType = UEnums.EBugglyReportFreqType.GameOnce,
    ReportProbability = 1,
    ReportHitCount = 1,
    ReportInfo = {"PlayerInfo"}
  },
  FightingStateStateMachineError = {
    ReportIndex = 28,
    ReportType = UEnums.EBugglyReportModeType.AllMode,
    ReportFreqType = UEnums.EBugglyReportFreqType.LoadingOnce,
    ReportProbability = 1,
    ReportHitCount = 1,
    ReportInfo = {"PlayerInfo"}
  },
  AliveNumInfoError = {
    ReportIndex = 29,
    ReportType = UEnums.EBugglyReportModeType.AllMode,
    ReportFreqType = UEnums.EBugglyReportFreqType.LoadingOnce,
    ReportProbability = 5000,
    ReportHitCount = 1,
    ReportInfo = {"PlayerInfo"}
  },
  BornIslandTeamShowUI = {
    ReportIndex = 30,
    ReportType = UEnums.EBugglyReportModeType.AllMode,
    ReportFreqType = UEnums.EBugglyReportFreqType.LoadingOnce,
    ReportProbability = 1,
    ReportHitCount = 1,
    ReportInfo = {"PlayerInfo"}
  },
  ["BuildSystemComponent:BugLoc"] = {
    ReportIndex = 31,
    ReportType = UEnums.EBugglyReportModeType.AllMode,
    ReportFreqType = UEnums.EBugglyReportFreqType.GameOnce,
    ReportProbability = 1,
    ReportHitCount = 1,
    ReportInfo = {"PlayerInfo"}
  },
  SkillServerTriggerException = {
    ReportIndex = 32,
    ReportType = UEnums.EBugglyReportModeType.BRMode,
    ReportFreqType = UEnums.EBugglyReportFreqType.GameOnce,
    ReportProbability = 100,
    ReportHitCount = 1,
    ReportInfo = {
      "PlayerInfo",
      "SkillInfo",
      "SkillNetInfo"
    }
  },
  CharacterAttachedOnVehicleException = {
    ReportIndex = 33,
    ReportType = UEnums.EBugglyReportModeType.BRMode,
    ReportFreqType = UEnums.EBugglyReportFreqType.GameOnce,
    ReportProbability = 100,
    ReportHitCount = 1,
    ReportInfo = {"PlayerInfo"}
  }
}
if Client and Client.IsDevelopment() then
  BugglyReportConfig.AvatarExceptionReport.ReportProbability = 1
  BugglyReportConfig.AvatarExceptionReport.ReportFreqType = UEnums.EBugglyReportFreqType.Always
  BugglyReportConfig.AvatarExceptionReport_AllSlotCheck.ReportProbability = 1
  BugglyReportConfig.AvatarExceptionReport_AllSlotCheck.ReportFreqType = UEnums.EBugglyReportFreqType.Always
end
return BugglyReportConfig