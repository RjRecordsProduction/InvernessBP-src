local MCActionConfig = {
  MaxInteractAllowDistance_UI = 300,
  MaxInteractAllowDistance = 250,
  MinInteractAllowDistance = 150,
  TriggerActionEmoteId = {
    AddFriend = 2205085,
    CheckProfile = 2205086,
    InviteTeam = 2205087,
    SendGift = 2205088,
    Thank = 2205089,
    Encourage = 2205090,
    Hello = 2205097
  },
  ForbidFollowEmoteList = {
    [2205085] = true,
    [2205086] = true,
    [2205087] = true,
    [2205088] = true,
    [2205089] = true,
    [2205090] = true,
    [2205091] = true,
    [2205092] = true,
    [2205093] = true,
    [2205094] = true,
    [2205097] = true,
    [2205098] = true,
    [2205080] = true,
    [2205081] = true,
    [2205099] = true,
    [2205082] = true,
    [2205083] = true,
    [2205084] = true
  },
  SkillIds = {
    CheckSystemSkillId = 1038908,
    PrincessHugHold = 1038909,
    PrincessHugRelease = 1038910,
    ClosedCarryHold = 1038911,
    ClosedCarryRelease = 1038912,
    FollowWalkLead = 1038913,
    FollowWalkFollow = 1038914,
    PlayEmoteSkill = 1014700,
    HighfiveCaster = 1038923,
    HighfiveTarget = 1038924,
    FistbumpCaster = 1038925,
    FistbumpTarget = 1038926,
    GreetCaster = 1038927,
    GreetTarget = 1038928,
    PenguinClean = 1038929,
    GuessingGame = 1038930
  },
  DualSkillMapping = {
    [1038923] = 1038924,
    [1038925] = 1038926,
    [1038927] = 1038928
  },
  PRINCESS_HUG_CD = 5,
  CLOSED_CARRY_CD = 5,
  MainRingSlots = {
    [1] = {
      bDualSkill = true,
      SkillId = 1038927,
      IconPath = "/Game/Mod/MainCity/Arts/UI/Atlas/Frames/MainCity_Icon_Interactive_Greeting_png.MainCity_Icon_Interactive_Greeting_png"
    },
    [2] = {
      bSimple = true,
      EmoteId = 2205090,
      IconPath = "/Game/Arts/UI/TableIcons/Emote/Icon_Victoryinhand_128.Icon_Victoryinhand_128"
    },
    [3] = {
      bSimple = true,
      EmoteId = 2205089,
      IconPath = "/Game/Mod/MainCity/Arts/UI/Atlas/Frames/ZD_icon_Thank_png.ZD_icon_Thank_png"
    },
    [4] = {
      bDualSkill = true,
      SkillId = 1038925,
      IconPath = "/Game/Arts/UI/TableIcons/Emote/Icon_Emote_110Sociallsland1_128.Icon_Emote_110Sociallsland1_128"
    },
    [5] = {
      bDualSkill = true,
      SkillId = 1038923,
      IconPath = "/Game/Mod/MainCity/Arts/UI/Atlas/Frames/ZD_Icon_Clap_png.ZD_Icon_Clap_png"
    }
  },
  SubRingSlots = {
    [1] = {
      SkillId = 1038909,
      IconPath = "/Game/Mod/MainCity/Arts/UI/Atlas/Frames/ZD_icon_Princess_png.ZD_icon_Princess_png"
    },
    [2] = {
      SkillId = 1038911,
      IconPath = "/Game/Mod/MainCity/Arts/UI/Atlas/Frames/ZD_icon_Back_png.ZD_icon_Back_png"
    },
    [3] = {
      SkillId = 1038913,
      IconPath = "/Game/Mod/MainCity/Arts/UI/Atlas/Frames/ZD_Icon_HandInHand_png.ZD_Icon_HandInHand_png"
    }
  },
  ActionToCharmTypeKey = {
    Emote = "Emote",
    Interactive = "Interactive",
    Skill = "Skill"
  },
  SkillSubState = {
    PrincessHug = 1,
    ClosedCarry = 2,
    FollowWalk = 3
  },
  CarryBackState = {
    ActiveHold = 1,
    ActiveRelease = 2,
    PassiveHold = 3,
    PassiveRelease = 4
  },
  HandleFollowType = {Active = 1, Passive = 2},
  AutoRefuseInteractionCount = 3,
  DSInviteTimeout = 6,
  EInteracteActionType = {
    Emote = 1,
    Interactive = 2,
    Skill = 3
  },
  DualSkillDistance = 105,
  DualSkillDistanceGreet = 165,
  DualSkillDistanceHighfive = 108,
  DualSkillDistanceZDiff = 5,
  ContinusAction = {
    [1] = {
      Caster = {10001, 10002},
      Target = {10003}
    },
    [2] = {
      Caster = {10004},
      Target = {10005}
    },
    [3] = {
      Caster = {10006, 10008},
      Target = {10008}
    },
    [1038925] = {1001, 1002},
    [1038926] = {1001, 1002},
    [1038923] = {1003, 1004},
    [1038924] = {1003, 1004}
  },
  ContinusSubActionCfg = {
    [1001] = {
      Icon = "/Game/Mod/MainCity/Arts/UI/Atlas/Frames/MainCity_Icon_Interactive_Mora_png.MainCity_Icon_Interactive_Mora_png"
    },
    [1002] = {
      Icon = "/Game/Mod/MainCity/Arts/UI/Atlas/Frames/MainCity_Icon_Interactive_FistBump_png.MainCity_Icon_Interactive_FistBump_png",
      EventName = "OnEx5",
      CasterSkillId = 1038925,
      TargetSkillId = 1038926
    },
    [1003] = {
      Icon = "/Game/Mod/MainCity/Arts/UI/Atlas/Frames/MainCity_Icon_Interactive_DanceBattle_png.MainCity_Icon_Interactive_DanceBattle_png",
      EventName = "OnEx5",
      CasterSkillId = 1038923,
      TargetSkillId = 1038924
    },
    [1004] = {
      Icon = "/Game/Mod/MainCity/Arts/UI/Atlas/Frames/MainCity_Icon_Interactive_HighFiveStickTogether_png.MainCity_Icon_Interactive_HighFiveStickTogether_png",
      EventName = "OnEx6",
      CasterSkillId = 1038923,
      TargetSkillId = 1038924
    },
    [10001] = {
      Icon = "/Game/Mod/MainCity/Arts/UI/Atlas/Frames/MainCity_Icon_Interactive_PrincessHugDance_png.MainCity_Icon_Interactive_PrincessHugDance_png",
      SkillId = 1038922
    },
    [10002] = {
      Icon = "/Game/Mod/MainCity/Arts/UI/Atlas/Frames/MainCity_Icon_Interactive_LetYourLoveFly_png.MainCity_Icon_Interactive_LetYourLoveFly_png",
      SkillId = 1038921
    },
    [10003] = {
      Icon = "/Game/Mod/MainCity/Arts/UI/Atlas/Frames/MainCity_Icon_Interactive_PrincessHugStickers_png.MainCity_Icon_Interactive_PrincessHugStickers_png",
      SkillId = 1038920
    },
    [10004] = {
      Icon = "/Game/Mod/MainCity/Arts/UI/Atlas/Frames/MainCity_Icon_Interactive_SpinInPlace_png.MainCity_Icon_Interactive_SpinInPlace_png",
      SkillId = 1038916
    },
    [10005] = {
      Icon = "/Game/Mod/MainCity/Arts/UI/Atlas/Frames/MainCity_Icon_Interactive_HorseRiding_png.MainCity_Icon_Interactive_HorseRiding_png",
      SkillId = 1038917
    },
    [10006] = {
      Icon = "/Game/Mod/MainCity/Arts/UI/Atlas/Frames/MainCity_Icon_Interactive_Swing_png.MainCity_Icon_Interactive_Swing_png",
      SkillId = 1038919
    },
    [10007] = {
      Icon = "/Game/Mod/MainCity/Arts/UI/Atlas/Frames/MainCity_Icon_Interactive_Swing_png.MainCity_Icon_Interactive_Swing_png",
      SkillId = 1038918
    },
    [10008] = {
      Icon = "/Game/Mod/MainCity/Arts/UI/Atlas/Frames/MainCity_Icon_Interactive_Mora_png.MainCity_Icon_Interactive_Mora_png",
      SkillId = 1038930
    }
  },
  ContinousActionSkillList = {
    [1038917] = true,
    [1038918] = true,
    [1038919] = true,
    [1038920] = true,
    [1038921] = true,
    [1038922] = true
  },
  MultiPlayerPoseDefaultSkillId = 1038931,
  MultiposeInviteRadius = 1500,
  MultiPlayerPoseCfg = {
    [1038931] = {
      Name = "QSGY",
      MaxParticipants = 4,
      InitiatorSkillID = 1038931,
      ParticipantSkillID = 1038932,
      Icon = "/Game/Mod/MainCity/Arts/UI/Atlas/Frames/MainCity_Icon_JoinMultiAct_Mote03_png.MainCity_Icon_JoinMultiAct_Mote03_png",
      Locations = {
        [1] = "(X=0.000000,Y=0.000000,Z=0.000000)",
        [2] = "(X=0.000000,Y=-71.678665,Z=0.000000)",
        [3] = "(X=0.000000,Y=-134.679016,Z=0.000000)",
        [4] = "(X=-0.000015,Y=-196.851349,Z=0.000000)"
      }
    },
    [1038933] = {
      Name = "KQY",
      MaxParticipants = 5,
      InitiatorSkillID = 1038933,
      ParticipantSkillID = 1038934,
      Icon = "/Game/Mod/MainCity/Arts/UI/Atlas/Frames/MainCity_Icon_JoinMultiAct_Mote05_png.MainCity_Icon_JoinMultiAct_Mote05_png",
      Locations = {
        [1] = "(X=0.000000,Y=0.000000,Z=0.000000)",
        [2] = "(X=72.234589,Y=-0.000031,Z=0.000000)",
        [3] = "(X=137.788651,Y=0.000275,Z=0.000000)",
        [4] = "(X=208.927353,Y=0.000793,Z=0.000000)",
        [5] = "(X=274.208282,Y=0.000854,Z=0.000000)"
      }
    },
    [1038935] = {
      Name = "WXFX",
      MaxParticipants = 5,
      InitiatorSkillID = 1038935,
      ParticipantSkillID = 1038936,
      Icon = "/Game/Mod/MainCity/Arts/UI/Atlas/Frames/MainCity_Icon_JoinMultiAct_Mote01_png.MainCity_Icon_JoinMultiAct_Mote01_png",
      Locations = {
        [1] = "(X=0.000000,Y=0.000000,Z=0.000000)",
        [2] = "(X=-80.940483,Y=-14.852921,Z=0.000000)",
        [3] = "(X=82.510002,Y=-23.324036,Z=0.000000)",
        [4] = "(X=-48.572010,Y=-92.802841,Z=0.000000)",
        [5] = "(X=42.731033,Y=-93.171524,Z=0.000000)"
      }
    },
    [1038937] = {
      Name = "JTBX",
      MaxParticipants = 6,
      InitiatorSkillID = 1038937,
      ParticipantSkillID = 1038938,
      Icon = "/Game/Mod/MainCity/Arts/UI/Atlas/Frames/MainCity_Icon_JoinMultiAct_Mote02_png.MainCity_Icon_JoinMultiAct_Mote02_png",
      Locations = {
        [1] = "(X=0.000000,Y=0.000000,Z=0.000000)",
        [2] = "(X=-62.145084,Y=-69.646156,Z=-0.000122)",
        [3] = "(X=66.810432,Y=-48.653461,Z=0.000061)",
        [4] = "(X=-98.378906,Y=-136.237762,Z=0.000000)",
        [5] = "(X=127.404274,Y=-116.837135,Z=0.000000)",
        [6] = "(X=2.595680,Y=-108.522423,Z=0.000000)"
      }
    },
    [1038939] = {
      Name = "DPZC",
      MaxParticipants = 5,
      InitiatorSkillID = 1038939,
      ParticipantSkillID = 1038940,
      Icon = "/Game/Mod/MainCity/Arts/UI/Atlas/Frames/MainCity_Icon_JoinMultiAct_Mote08_png.MainCity_Icon_JoinMultiAct_Mote08_png",
      Locations = {
        [1] = "(X=0.000000,Y=0.000000,Z=0.000000)",
        [2] = "(X=-105.795044,Y=36.250504,Z=0.000000)",
        [3] = "(X=68.556183,Y=34.725784,Z=0.000000)",
        [4] = "(X=-49.173470,Y=-61.700150,Z=0.000000)",
        [5] = "(X=40.019707,Y=-55.952942,Z=-1.003067)"
      }
    }
  },
  C_MultiPlayerPoseSkillIdList = {
    1038931,
    1038933,
    1038935,
    1038937,
    1038939
  }
}
return MCActionConfig