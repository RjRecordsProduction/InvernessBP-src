local TeleportConfig = {
  [440001] = {
    LoadingEffect = {
      Type = "UI",
      Param = "TeleportParkourTrialDungeonScreenEffectUI"
    },
    TestLocation = {
      LineTraceEnabled = false,
      MaxHorizontalOffsetRate = 3,
      MaxHeightOffsetRate = 3,
      OffsetValue = 100
    }
  },
  [440002] = {
    LoadingEffect = {
      Type = "UI",
      Param = "TeleportParkourTrialDungeonScreenEffectUI"
    },
    TestLocation = {MaxHeightOffsetRate = 3, LineTraceEnabled = false}
  },
  [440003] = {
    LoadingEffect = {Type = "UI", Param = ""},
    TestLocation = {MaxHeightOffsetRate = 3, LineTraceEnabled = false}
  },
  [440004] = {
    LoadingEffect = {
      Type = "UI",
      Param = "TeleportToNTScreenEffectUI",
      Timeout = 5
    },
    FilterLevelKey = "Baltic_GodTrial_PreheatSpaceP_DSForceLoad"
  },
  [440005] = {
    LoadingEffect = {
      Type = "UI",
      Param = "TeleportToNTScreenEffectUI",
      Timeout = 5
    },
    FilterLevelKey = "Baltic_GodTrial_PreheatSpaceY_DSForceLoad"
  },
  [440006] = {
    LoadingEffect = {
      Type = "UI",
      Param = "TeleportToNTScreenEffectUI",
      Timeout = 5
    },
    FilterLevelKey = "Baltic_GodTrial_PreheatSpaceMB_DSForceLoad"
  },
  [440007] = {
    LoadingEffect = {
      Type = "UI",
      Param = "TeleportToNTScreenEffectUI",
      Timeout = 5
    },
    FilterLevelKey = "Baltic_GodTrial_PreheatSpaceFarm_DSForceLoad"
  },
  [440008] = {
    NotShowLoading = true,
    HideAllUI = false,
    TestLocation = {
      LineTraceEnabled = false,
      MaxHorizontalOffsetRate = 3,
      MaxHeightOffsetRate = 3,
      OffsetValue = 100
    }
  },
  [440009] = {
    LoadingEffect = {
      Type = "UI",
      Param = "TeleportToNTScreenEffectUI",
      Timeout = 5
    },
    FilterLevelKey = "Baltic_GodTrial_PreheatSpaceG_DSForceLoad"
  },
  [440010] = {
    LoadingEffect = {
      Type = "UI",
      Param = "TeleportToNTScreenEffectUI",
      Timeout = 1.8
    }
  }
}
return TeleportConfig