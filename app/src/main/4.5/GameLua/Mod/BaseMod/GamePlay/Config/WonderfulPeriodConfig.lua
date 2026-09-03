local EWonderfulType = UEnums.EWonderfulType
local WonderfulPeriodConfig = {
  SubTypeRate = 0.8,
  AIRate = 0.3,
  AIMultiKillScoreRate = 0.1,
  nLookBackTime = 15,
  nExtraTime = 5,
  nMaxMultiKillInterval = 30,
  MultiKillConfig = {
    {
      Interval = 30,
      Score = {
        0.5,
        2,
        4
      }
    },
    {
      Interval = 15,
      Score = {
        1,
        3,
        5
      }
    },
    {
      Interval = 4,
      Score = {
        2,
        4.5,
        7.5
      }
    }
  },
  WonderfulType2Text = {
    [EWonderfulType.EWonderfulType_None] = "25614",
    [EWonderfulType.EWonderfulType_MultiKill] = "25614",
    [EWonderfulType.EWonderfulType_MovingVehicleKill] = "25615",
    [EWonderfulType.EWonderfulType_AntiKill] = "25616",
    [EWonderfulType.EWonderfulType_LongDistance] = "25617",
    [EWonderfulType.EWonderfulType_MovingKill] = "25618",
    [EWonderfulType.EWonderfulType_OnVehicleKill] = "29811",
    [EWonderfulType.EWonderfulType_GrenadeKill] = "29812",
    [EWonderfulType.EWonderfulType_HeadshotKill] = "29812",
    [EWonderfulType.EWonderfulType_MeleeWeaponKill] = "29812",
    [EWonderfulType.EWonderfulType_UserSave] = "8700089",
    [EWonderfulType.EWonderfulType_OneShotMultiKill] = "25617",
    [EWonderfulType.EWonderfulType_CrossBowKill] = "25617"
  },
  SubWonderfulType2Text = {
    [EWonderfulType.EWonderfulType_MovingVehicleKill] = "49045",
    [EWonderfulType.EWonderfulType_GrenadeKill] = "49046",
    [EWonderfulType.EWonderfulType_LongDistance] = "49047",
    [EWonderfulType.EWonderfulType_AntiKill] = "49048",
    [EWonderfulType.EWonderfulType_HeadshotKill] = "49049",
    [EWonderfulType.EWonderfulType_OneShotMultiKill] = "49045",
    [EWonderfulType.EWonderfulType_UserSave] = "8700089",
    [EWonderfulType.EWonderfulType_MeleeWeaponKill] = "29812"
  },
  WonderfulLoadingBGConfig = {
    [EWonderfulType.EWonderfulType_MultiKill] = {
      TitlePath = "/Game/Arts/UI/NoAtlas/WonderfulMoment/Titel_Bg05.Titel_Bg05"
    },
    [EWonderfulType.EWonderfulType_MovingVehicleKill] = {
      TitlePath = "/Game/Arts/UI/NoAtlas/WonderfulMoment/Titel_Bg01.Titel_Bg01"
    },
    [EWonderfulType.EWonderfulType_AntiKill] = {
      TitlePath = "/Game/Arts/UI/NoAtlas/WonderfulMoment/Titel_Bg02.Titel_Bg02"
    },
    [EWonderfulType.EWonderfulType_LongDistance] = {
      TitlePath = "/Game/Arts/UI/NoAtlas/WonderfulMoment/Titel_Bg04.Titel_Bg04"
    },
    [EWonderfulType.EWonderfulType_MovingKill] = {
      TitlePath = "/Game/Arts/UI/NoAtlas/WonderfulMoment/Titel_Bg03.Titel_Bg03"
    },
    [EWonderfulType.EWonderfulType_OnVehicleKill] = {
      TitlePath = "/Game/Arts/UI/NoAtlas/WonderfulMoment/Titel_Bg06.Titel_Bg06"
    },
    [EWonderfulType.EWonderfulType_GrenadeKill] = {
      TitlePath = "/Game/Arts/UI/NoAtlas/WonderfulMoment/Titel_Bg07.Titel_Bg07"
    },
    [EWonderfulType.EWonderfulType_HeadshotKill] = {
      TitlePath = "/Game/Arts/UI/NoAtlas/WonderfulMoment/Titel_Bg08.Titel_Bg08"
    },
    [EWonderfulType.EWonderfulType_MeleeWeaponKill] = {
      TitlePath = "/Game/Arts/UI/NoAtlas/WonderfulMoment/Titel_Bg09.Titel_Bg09"
    },
    [EWonderfulType.EWonderfulType_UserSave] = {
      TitlePath = "/Game/Arts/UI/NoAtlas/WonderfulMoment/Titel_Bg09.Titel_Bg09"
    },
    [EWonderfulType.EWonderfulType_OneShotMultiKill] = {
      TitlePath = "/Game/Arts/UI/NoAtlas/WonderfulMoment/Titel_Bg04.Titel_Bg04"
    },
    [EWonderfulType.EWonderfulType_CrossBowKill] = {
      TitlePath = "/Game/Arts/UI/NoAtlas/WonderfulMoment/Titel_Bg04.Titel_Bg04"
    }
  },
  WonderfulCheckerConfig = {
    {
      fChecker = "LongDistanceKillChecker",
      DistScoreTable = {
        {Dist = 10000, nScore = 4},
        {Dist = 20000, nScore = 5},
        {Dist = 35000, nScore = 8}
      }
    },
    {
      fChecker = "HeadshotKillChecker",
      nScore = 3
    },
    {
      fChecker = "GrenadeKillChecker",
      nScore = 4,
      nHighScore = 7,
      nHighScoreTime = 3
    },
    {
      fChecker = "MeleeWeaponKillChecker",
      nScore = 4,
      nHighScore = 7
    },
    {
      fChecker = "OnVehicleKillChecker",
      nDriverScore = 3,
      nPassengerScore = 6,
      nSpeed = 1400
    },
    {
      fChecker = "MovingKillChecker",
      nScore = 2,
      nSpeed = 300,
      nCauseDamage = 30,
      nDistance = 3000
    },
    {
      fChecker = "AntiKillChecker",
      nMaxSelfHealth = 30,
      AntiKillConfig = {
        {
          nSelfHealth = 30,
          nTakeDamage = 30,
          nTotalDamage = 40,
          nScore = 5
        },
        {
          nSelfHealth = 20,
          nTakeDamage = 50,
          nTotalDamage = 60,
          nScore = 6
        },
        {
          nSelfHealth = 15,
          nTakeDamage = 85,
          nTotalDamage = 85,
          nScore = 9
        }
      }
    },
    {
      fChecker = "OneHitMultiKillChecker",
      nShotScore = 7
    },
    {
      fChecker = "CrossBowKillChecker",
      nScore = 5
    }
  },
  TGPAConfig = {
    TriggerKey = 44,
    FirstKill = 1,
    NormalKill = 2,
    MultiKillConfig = {
      {
        3,
        6,
        9,
        12
      },
      {
        4,
        7,
        10,
        13
      },
      {
        5,
        8,
        11,
        14
      }
    }
  }
}
return WonderfulPeriodConfig