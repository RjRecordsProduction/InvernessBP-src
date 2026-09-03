local EState = {
  Idle = 0,
  Interacting = 1,
  Deactivated = 2,
  BTBoss = 3,
  MLBoss = 4,
  WaitingHired = 5,
  Hired = 6
}
local CentaurConfig = {
  MoveAbility = {},
  TLogConfig = {
    TotalGame_BeenHired = 703,
    TotalGame_TeamRank = 704,
    TotalGame_BossDamageDealt = 715,
    TotalGame_Assists = 719,
    Player_TeamHire = 2148
  },
  DeathConfig = {
    DissolveDuration = 2,
    DeathAnimDuration = 4,
    KneelParticlePath = "/Game/Library/Res/AI/Centaur/Arts_Effect/Par/P_Zombie_Int_170_Die_L2.P_Zombie_Int_170_Die_L2",
    KneelParticlePath2 = "/Game/Library/Res/AI/Centaur/Arts_Effect/Par/P_Zombie_Int_170_Born_L2.P_Zombie_Int_170_Born_L2"
  },
  MercenaryCentaurRadius = 80
}
CentaurConfig.BossVoice = {
  VoiceCD = 30.0,
  IdleVoiceCD = 50.0,
  MaxPlayDistance = 16000,
  RegionSuffix = {
    [0] = "cn",
    [1] = "en",
    [8] = "tr",
    [9] = "ru",
    [15] = "cn",
    [19] = "ar"
  },
  StartVoices = {
    "prologue",
    {265, 267}
  },
  IdleVoices = {
    "ramblings",
    {
      296,
      297,
      298,
      299,
      300
    }
  },
  SkillVoices = {
    [4400003] = {
      "archery",
      {
        270,
        271,
        272
      }
    },
    [4402001] = {
      "trampling",
      {
        273,
        274,
        275
      }
    },
    [4402003] = {
      "charging",
      {
        276,
        277,
        278
      }
    },
    [4400004] = {
      "explosive_arrow",
      {
        279,
        280,
        281
      }
    },
    [4402004] = {
      "trampling",
      {
        273,
        274,
        275
      }
    },
    [4402006] = {
      "charging",
      {
        276,
        277,
        278
      }
    }
  },
  HealthVoices = {
    "low_health",
    {
      282,
      283,
      284,
      285
    }
  },
  KillVoices = {
    "kill_player",
    {
      286,
      287,
      288,
      289,
      290
    }
  },
  DefeatedVoices = {
    "boss_defeated",
    {
      291,
      292,
      293,
      294,
      295
    }
  }
}
return CentaurConfig