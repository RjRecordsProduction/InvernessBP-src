local Config = {
  EBoardcastType = {
    OnlyForAlive = 1,
    OnlyForWatch = 2,
    ForAll = 3
  },
  ELikeEventType = {
    TeamEvent = 1,
    PersonalEvent = 2,
    InteractEvent = 3,
    ReplyEvent = 4
  },
  KillNum3 = 1,
  KillBack = 2,
  Rescue = 3,
  SendItem = 4,
  Start = 5,
  Win = 6,
  Reply = 7,
  ContinueKill = 8,
  FlareGun = 9,
  EnterCircle = 10,
  TopTen = 11,
  QuickResponse = 12,
  ShowOff = 13,
  TacticalMark = 14,
  GetInVehicle = 15,
  HoldOn = 16,
  Teamwork = 17,
  RescueForAlive = 18,
  [1] = {
    Name = "\229\135\187\230\157\128\230\149\176\233\135\143\232\190\190\229\136\1763",
    ConditionID = 1,
    TipMessageID = 24428,
    TipMessageStyle = 0,
    TeamChatMessageID = 3,
    BoardcastType = 1,
    LikeEventType = 2,
    bExcludeSelf = false,
    bSelfCanSend = false,
    bSendBack = false,
    ThanksChatMessageID = 4,
    WidgetSwitcherIndex = 0,
    ExtraInfo = "3 KILLS",
    TriggerEvent = {
      [1] = {
        EventType = EVENTTYPE_PLAYEREVENT_CHARACTER,
        EVENTID = EVENTTYPE_PLAYEREVENT_KILL_PAWN,
        FuncName = "HandleKillPawn"
      }
    },
    bForbitChat = true,
    Priority = 1
  },
  [2] = {
    Name = "\229\135\187\230\157\128\228\188\164\229\174\179\232\191\135\233\152\159\229\143\139\231\154\132\228\186\186",
    ConditionID = 2,
    TipMessageID = 24429,
    TipMessageStyle = 0,
    TeamChatMessageID = 3,
    BoardcastType = 3,
    LikeEventType = 3,
    bExcludeSelf = true,
    bSelfCanSend = false,
    bSendBack = true,
    ThanksChatMessageID = 4,
    WidgetSwitcherIndex = 0,
    TriggerEvent = {},
    bForbitChat = true,
    Priority = 1
  },
  [3] = {
    Name = "\230\149\145\230\143\180\233\152\159\229\143\139\230\136\144\229\138\159",
    ConditionID = 3,
    TipMessageID = 18052,
    TipMessageStyle = 1,
    TeamChatMessageID = 3,
    BoardcastType = 3,
    LikeEventType = 3,
    bExcludeSelf = false,
    bSelfCanSend = false,
    bSendBack = true,
    ThanksChatMessageID = 4,
    WidgetSwitcherIndex = 0,
    TriggerEvent = {
      [1] = {
        EventType = EVENTTYPE_INGAME_NORMAL,
        EVENTID = EVENTID_PAWN_RESCUE,
        FuncName = "HandlePlayerRescue"
      }
    },
    bForbitChat = true,
    Priority = 1
  },
  [4] = {
    Name = "\230\139\190\229\143\150\233\152\159\229\143\139\228\184\162\229\188\131\231\154\132\233\129\147\229\133\183",
    ConditionID = 4,
    TipMessageID = 18054,
    TipMessageStyle = 2,
    TeamChatMessageID = 3,
    BoardcastType = 3,
    LikeEventType = 3,
    bExcludeSelf = false,
    bSelfCanSend = false,
    bSendBack = true,
    bBroadcastProgress = true,
    ThanksChatMessageID = 4,
    WidgetSwitcherIndex = 0,
    TriggerEvent = {
      [1] = {
        EventType = EVENTTYPE_INGAME_NORMAL,
        EVENTID = EVENTID_PAWN_PICK_UP_ITEM,
        FuncName = "HandlePawnPickupItem"
      }
    },
    bForbitChat = true,
    Priority = 1
  },
  [5] = {
    Name = "\229\188\128\229\156\186\230\151\182\233\152\159\228\188\141\230\187\161\229\145\152\239\188\140\229\143\175\228\187\165\228\186\146\231\155\184\230\137\147\230\176\148",
    ConditionID = 5,
    TipMessageID = 18376,
    TipMessageStyle = 0,
    TeamChatMessageID = 5,
    BoardcastType = 3,
    LikeEventType = 1,
    bExcludeSelf = false,
    bSelfCanSend = true,
    bSendBack = false,
    bBroadcastProgress = true,
    bAlwaysShow = true,
    ThanksChatMessageID = nil,
    WidgetSwitcherIndex = 3,
    TriggerEvent = {},
    Priority = 1
  },
  [6] = {
    Name = "\232\131\156\229\136\169\229\144\142\229\186\134\231\165\157",
    ConditionID = 6,
    TipMessageID = 18377,
    TipMessageStyle = 0,
    TeamChatMessageID = 6,
    BoardcastType = 3,
    LikeEventType = 1,
    bExcludeSelf = false,
    bSelfCanSend = true,
    bSendBack = false,
    bBroadcastProgress = true,
    ThanksChatMessageID = nil,
    bAlwaysShow = true,
    WidgetSwitcherIndex = 4,
    TriggerEvent = {},
    Priority = 1
  },
  [7] = {
    Name = "\230\148\182\229\136\176",
    ConditionID = 7,
    TipMessageID = nil,
    TipMessageStyle = 0,
    TeamChatMessageID = 8,
    BoardcastType = 3,
    LikeEventType = 4,
    bExcludeSelf = false,
    bSelfCanSend = true,
    bSendBack = false,
    ThanksChatMessageID = nil,
    WidgetSwitcherIndex = 5,
    TriggerEvent = {},
    Priority = 3
  },
  [8] = {
    Name = "\232\191\158\231\187\173\229\135\187\230\157\128",
    ConditionID = 8,
    TipMessageID = 756071,
    TeamChatMessageID = 3,
    BoardcastType = 2,
    LikeEventType = 2,
    bExcludeSelf = false,
    bSelfCanSend = false,
    bSendBack = true,
    ThanksChatMessageID = 4,
    WidgetSwitcherIndex = 0,
    TriggerEvent = {},
    bForbitChat = true,
    Priority = 1
  },
  [9] = {
    Name = "\229\143\145\229\176\132\228\191\161\229\143\183\230\158\170",
    ConditionID = 9,
    TipMessageID = 33997,
    TeamChatMessageID = 3,
    BoardcastType = 2,
    LikeEventType = 2,
    bExcludeSelf = false,
    bSelfCanSend = false,
    bSendBack = true,
    ThanksChatMessageID = 4,
    WidgetSwitcherIndex = 0,
    TriggerEvent = {
      [1] = {
        EventType = EVENTTYPE_INGAME_NORMAL,
        EVENTID = EVENTID_CALL_AIR_DROP_SUCCESS,
        FuncName = "HandlePlayerCallAirDrop"
      }
    },
    Priority = 1
  },
  [10] = {
    Name = "\230\136\144\229\138\159\232\191\155\229\156\136",
    ConditionID = 10,
    TipMessageID = 33995,
    TeamChatMessageID = 3,
    BoardcastType = 2,
    LikeEventType = 2,
    bExcludeSelf = false,
    bSelfCanSend = false,
    bSendBack = true,
    ThanksChatMessageID = 4,
    WidgetSwitcherIndex = 0,
    TriggerEvent = {},
    Priority = 1
  },
  [11] = {
    Name = "\232\191\155\229\133\165\229\137\141\229\141\129",
    ConditionID = 11,
    TipMessageID = 33993,
    TeamChatMessageID = 5,
    BoardcastType = 2,
    LikeEventType = 1,
    bExcludeSelf = false,
    bSelfCanSend = true,
    bSendBack = false,
    ThanksChatMessageID = nil,
    WidgetSwitcherIndex = 0,
    TriggerEvent = {},
    Priority = 1
  },
  [12] = {
    Name = "\229\191\171\233\128\159\229\155\158\229\186\148",
    ConditionID = 12,
    TipMessageID = nil,
    TipMessageStyle = 0,
    TeamChatMessageID = 8,
    BoardcastType = 3,
    LikeEventType = 4,
    bExcludeSelf = false,
    bSelfCanSend = true,
    bSendBack = false,
    ThanksChatMessageID = nil,
    WidgetSwitcherIndex = 6,
    TriggerEvent = {},
    Priority = 2
  },
  [13] = {
    Name = "\229\177\149\231\164\186\233\163\142\233\135\135",
    ConditionID = 13,
    TipMessageID = nil,
    TipMessageStyle = 0,
    TeamChatMessageID = 3,
    BoardcastType = 3,
    LikeEventType = 4,
    bExcludeSelf = true,
    bSelfCanSend = false,
    bSendBack = false,
    ThanksChatMessageID = nil,
    WidgetSwitcherIndex = 0,
    TriggerEvent = {},
    Priority = 2,
    bSendTo = true,
    bUseStack = true
  },
  [14] = {
    Name = "\230\136\152\230\156\175\230\160\135\231\130\185",
    ConditionID = 14,
    TipMessageID = nil,
    TipMessageStyle = 0,
    TeamChatMessageID = 8,
    BoardcastType = 1,
    LikeEventType = 4,
    bExcludeSelf = false,
    bSelfCanSend = true,
    bSendBack = false,
    ThanksChatMessageID = nil,
    WidgetSwitcherIndex = 7,
    ConfigKeys = {
      "C_NeedAttachment",
      "C_NeedAmmo",
      "C_NeedMedicine",
      "C_NeedSlot",
      "C_MarkPos",
      "C_Attention"
    },
    TriggerEvent = {},
    Priority = 3
  },
  [15] = {
    Name = "\228\184\138\232\189\166",
    ConditionID = 15,
    TipMessageID = nil,
    TipMessageStyle = 0,
    TeamChatMessageID = 9,
    BoardcastType = 1,
    LikeEventType = 4,
    bExcludeSelf = false,
    bSelfCanSend = true,
    bSendBack = false,
    ThanksChatMessageID = nil,
    WidgetSwitcherIndex = 8,
    TriggerEvent = {
      [1] = {
        EventType = EVENTTYPE_PLAYEREVENT_VEHICLE,
        EVENTID = EVENTID_VEHICLE_PLAYER_CHANGED,
        FuncName = "HandleVehiclePlayerChanged"
      }
    },
    Priority = 2
  },
  [16] = {
    Name = "\231\168\179\228\189\143",
    ConditionID = 16,
    TipMessageID = nil,
    TipMessageStyle = 0,
    TeamChatMessageID = 10,
    BoardcastType = 1,
    LikeEventType = 1,
    bExcludeSelf = false,
    bSelfCanSend = true,
    bSendBack = false,
    ThanksChatMessageID = nil,
    WidgetSwitcherIndex = 9,
    TriggerEvent = {
      [1] = {
        EventType = EVENTTYPE_INGAME_NORMAL,
        EVENTID = EVENTID_PAWN_DIED,
        FuncName = "HandleTeammatePawnDied"
      }
    },
    Priority = 2
  },
  [17] = {
    Name = "\233\133\141\229\144\136",
    ConditionID = 17,
    TipMessageID = nil,
    TipMessageStyle = 0,
    TeamChatMessageID = 11,
    BoardcastType = 1,
    LikeEventType = 3,
    bExcludeSelf = true,
    bSelfCanSend = false,
    bSendBack = true,
    ThanksChatMessageID = 4,
    WidgetSwitcherIndex = 10,
    TriggerEvent = {
      [1] = {
        EventType = EVENTTYPE_INGAME_NORMAL,
        EVENTID = EVENTID_PAWN_DIED_ASSIST,
        FuncName = "HandlePawnDiedAssist"
      }
    },
    Priority = 2
  },
  [18] = {
    Name = "RescueForAlive",
    ConditionID = 18,
    TipMessageID = nil,
    TipMessageStyle = 2,
    TeamChatMessageID = 3,
    BoardcastType = 3,
    LikeEventType = 3,
    bExcludeSelf = false,
    bSelfCanSend = false,
    bSendBack = true,
    bBroadcastProgress = true,
    ThanksChatMessageID = 4,
    WidgetSwitcherIndex = 0,
    TriggerEvent = {},
    bForbitChat = true,
    Priority = 1
  },
  ShowOffConfig = {
    [1] = {47001},
    [2] = {47002},
    [3] = {47003},
    [101] = {47004},
    [102] = {47005},
    [103] = {47006},
    [104] = {47007},
    [105] = {47008}
  },
  ShowOffTime = 30,
  MultiLikeType = {
    [1] = {TextID = 817408}
  },
  SoleLikeType = {
    [18] = {TextID = 817409},
    [4] = {TextID = 817410}
  }
}
return Config