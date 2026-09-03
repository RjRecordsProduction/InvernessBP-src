local gamelet_define = {
  GameletAppConfig = {
    AppIds = {
      CustomerService = {
        GLOBAL = "989",
        CE = "2441",
        TW = "989",
        FIT = "989"
      },
      WOW_BBS = {
        GLOBAL = "3156",
        VNG = "3156",
        TW = "3156",
        FIT = "989"
      },
      SafetyCenter = {
        GLOBAL = "3160",
        VNG = "3160",
        TW = "3160",
        FIT = "3160"
      },
      Wiki = {
        GLOBAL = "3158",
        VNG = "3158",
        TW = "3158",
        FIT = "3158"
      },
      WOW_Center_Video = {
        CE = "3177",
        VNG = "3177",
        TW = "3177",
        FIT = "3177",
        FITCE = "3177",
        GLOBAL = "3177"
      },
      WOW_Center_Activity = {
        CE = "3176",
        VNG = "3176",
        TW = "3176",
        FIT = "3176",
        FITCE = "3176",
        GLOBAL = "3176"
      },
      creatorBase = {
        GLOBAL = "3190",
        FIT = "3190",
        VNG = "3190",
        TW = "3190"
      },
      GameletAct = {
        GLOBAL = "3152",
        VNG = "3152",
        TW = "3152",
        FIT = "3152"
      },
      WOW_Center_BenchmarkAuthor = {
        CE = "3175",
        VNG = "3175",
        TW = "3175",
        FIT = "3175",
        FITCE = "3175",
        GLOBAL = "3175"
      },
      WOW_Center_OfficialStory = {
        CE = "3178",
        VNG = "3178",
        TW = "3178",
        FIT = "3178",
        FITCE = "3178",
        GLOBAL = "3178"
      },
      panameraCenter = {
        GLOBAL = "3262",
        VNG = "3262",
        TW = "3262",
        FIT = "3262"
      },
      NationalEsports_Official = {
        GLOBAL = "3313",
        VNG = "3313",
        TW = "3313",
        FIT = "3313"
      },
      NationalEsports_Entertainment = {
        GLOBAL = "3338",
        VNG = "3338",
        TW = "3338",
        FIT = "3338"
      }
    }
  },
  GameletApp = {
    CustomerService = "CustomerService",
    WOW_BBS = "WOW_BBS",
    SafetyCenter = "SafetyCenter",
    Wiki = "Wiki",
    GameletAct = "GameletAct",
    WOW_Center_Video = "WOW_Center_Video",
    WOW_Center_Activity = "WOW_Center_Activity",
    creatorBase = "creatorBase",
    WOW_Center_BenchmarkAuthor = "officialLore",
    WOW_Center_OfficialStory = "creatorEvent",
    panameraCenter = "panameraCenter",
    NationalEsports_Official = "NationalEsports_Official",
    NationalEsports_Entertainment = "NationalEsports_Entertainment"
  },
  Enum_IMSDKEnv = {Test = 0, Release = 1},
  Enum_GameletEnv = {
    Test = 0,
    Product = 1,
    Tyf_Test = 2,
    Tyf_Product = 3
  },
  DisableReason = {
    None = 0,
    LowMem = 1,
    RegionForbidden = 2,
    RemoteSwitchClosed = 3
  }
}
return gamelet_define