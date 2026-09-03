local EActorHiddenMask = import("EActorHiddenMask")
local EAvatarType = {
  Head = 1,
  Hair = 2,
  Clothes = 5,
  Pants = 6,
  Shoes = 7
}
local AvatarExceptionConfig = {
  OtherPlayerCheckDistance = 5000,
  TickCheckInterval = 30,
  PawnCheckScaleSize = 0.1,
  PawnCheckLocationThreshold = 300,
  SlotCheckScaleSize = 0.1,
  SlotCheckLocationThreshold = 600,
  SlotCheckMeshBoundSizeThreshold = 10,
  SelfPawnAvatarMiss = {
    ReportInfo = {
      "PlayerInfo",
      "PlayerStateInfo",
      "CharacterMeshInfo"
    },
    Trigger = {
      [UEnums.EAvatarExceptionTriggerType.Tick] = true,
      [UEnums.EAvatarExceptionTriggerType.AllMeshLoadedEvent] = {
        DelayTime = 2,
        Interval = 2,
        LoopCount = 10
      },
      [UEnums.EAvatarExceptionTriggerType.ClickReportEvent] = {
        DelayTime = 0,
        Interval = 1,
        LoopCount = 2
      }
    },
    AllCheckCount = 10,
    PawnCheck = {
      CheckCount = 5,
      CheckAction = {
        Visible = true,
        Scale = true,
        Location = true
      }
    },
    SlotCheck = {
      [EAvatarType.Head] = {
        CheckCount = 5,
        CheckAction = {
          Visible = true,
          RecentlyRendered = true,
          BoundSize = true,
          Scale = true,
          Location = true
        }
      },
      [EAvatarType.Hair] = {
        CheckCount = 5,
        CheckAction = {Visible = true, RecentlyRendered = true}
      },
      [EAvatarType.Clothes] = {
        CheckCount = 5,
        CheckAction = {
          Visible = true,
          RecentlyRendered = true,
          Scale = true
        }
      },
      [EAvatarType.Pants] = {
        CheckCount = 5,
        CheckAction = {
          Visible = true,
          RecentlyRendered = true,
          Scale = true
        }
      },
      [EAvatarType.Shoes] = {
        CheckCount = 5,
        CheckAction = {
          Visible = true,
          RecentlyRendered = true,
          Scale = true
        }
      }
    },
    IgnoreCheckHiddenMask = {
      EActorHiddenMask.ActorHiddenMask4,
      EActorHiddenMask.ActorHiddenMask5,
      EActorHiddenMask.ActorHiddenMask6
    }
  },
  TeamPawnAvatarMiss = {
    ReportInfo = {
      "PlayerInfo",
      "SpecifiedCharacterMeshInfo"
    },
    Trigger = {
      [UEnums.EAvatarExceptionTriggerType.Tick] = true,
      [UEnums.EAvatarExceptionTriggerType.AllMeshLoadedEvent] = {
        DelayTime = 3,
        Interval = 2,
        LoopCount = 5
      },
      [UEnums.EAvatarExceptionTriggerType.ClickReportEvent] = {
        DelayTime = 0,
        Interval = 1,
        LoopCount = 2
      }
    },
    AllCheckCount = 10,
    PawnCheck = {
      CheckCount = 5,
      CheckAction = {
        Visible = true,
        Scale = true,
        Location = true
      }
    },
    SlotCheck = {
      [EAvatarType.Head] = {
        CheckCount = 5,
        CheckAction = {
          Visible = true,
          RecentlyRendered = true,
          BoundSize = true,
          Scale = true,
          Location = true
        }
      },
      [EAvatarType.Hair] = {
        CheckCount = 5,
        CheckAction = {Visible = true}
      },
      [EAvatarType.Clothes] = {
        CheckCount = 5,
        CheckAction = {
          Visible = true,
          RecentlyRendered = true,
          Scale = true
        }
      },
      [EAvatarType.Pants] = {
        CheckCount = 5,
        CheckAction = {
          Visible = true,
          RecentlyRendered = true,
          Scale = true
        }
      },
      [EAvatarType.Shoes] = {
        CheckCount = 5,
        CheckAction = {
          Visible = true,
          RecentlyRendered = true,
          Scale = true
        }
      }
    }
  },
  OtherPawnAvatarMiss = {
    ReportInfo = {
      "PlayerInfo",
      "SpecifiedCharacterMeshInfo"
    },
    Trigger = {
      [UEnums.EAvatarExceptionTriggerType.AllMeshLoadedEvent] = {
        DelayTime = 3,
        Interval = 2,
        LoopCount = 5
      },
      [UEnums.EAvatarExceptionTriggerType.ClickReportEvent] = {
        DelayTime = 0,
        Interval = 1,
        LoopCount = 2
      }
    },
    AllCheckCount = 10,
    PawnCheck = {
      CheckCount = 5,
      CheckAction = {
        Visible = true,
        Scale = true,
        Location = true
      }
    },
    SlotCheck = {
      [EAvatarType.Head] = {
        CheckCount = 5,
        CheckAction = {
          Visible = true,
          RecentlyRendered = true,
          BoundSize = true,
          Scale = true,
          Location = true
        }
      },
      [EAvatarType.Hair] = {
        CheckCount = 5,
        CheckAction = {Visible = true}
      },
      [EAvatarType.Clothes] = {
        CheckCount = 5,
        CheckAction = {
          Visible = true,
          RecentlyRendered = true,
          Scale = true
        }
      },
      [EAvatarType.Pants] = {
        CheckCount = 5,
        CheckAction = {
          Visible = true,
          RecentlyRendered = true,
          Scale = true
        }
      },
      [EAvatarType.Shoes] = {
        CheckCount = 5,
        CheckAction = {
          Visible = true,
          RecentlyRendered = true,
          Scale = true
        }
      }
    }
  }
}
return AvatarExceptionConfig