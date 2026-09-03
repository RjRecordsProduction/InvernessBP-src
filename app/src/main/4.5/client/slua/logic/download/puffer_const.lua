local PufferConst = {
  MB = 1048576,
  KB = 1024,
  ActivityAudioItemID = 1899999,
  PREFETCH_BUNDLE_ID = 100000,
  UGC_BUNDLE_ID = 100011,
  BIND_PHONE_MAIL_REWARD_ID = 99999,
  PAKS_RELATIVE_DIR = "Paks/",
  ODPAKS_RELATIVE_DIR = "ODPaks/",
  UGCPAKS_RELATIVE_DIR = "ODPaks/",
  RES_FILE_PREFIX = "res_",
  PACK_SET_PREFIX = "pak_",
  MAP_PACK_SET_PREFIX = "pak_map_",
  MIX_PACK_SET_PREFIX = "pak_mix_",
  BASE_PREFIX = "base_",
  MAP_PREFIX = "map_",
  LOBBY_MAPKEY = "pak_map_lobby",
  PUFFERPATCH = "res_pufferpatch",
  UGC_BASIC_MAPKEY = "map_creativebasic",
  UGC_EDIT_MAPKEY = "map_creativeedit",
  UGC_MAP_PREFIX1 = "map_creative",
  UGC_MAP_PREFIX2 = "map_ugc_",
  RES_VULKAN_SHADER = "res_vulkanshader",
  FIT_SHADER_KEY = "fit_shader",
  FIT_ES2SHADER = "map_es2shadercsm",
  FIT_ES3SHADER = "map_es3shadercsm",
  FIT_ES_SHADER_PREFIX = "shadercsm",
  FIT_LOBBY_DOWNLOAD = "res_corelobydownload",
  FIT_COMMERCIAL_CORE_DEP = "res_corecommtialcoredep",
  FIT_LOBBY_RES_KEY = "pak_mix_lobby_res",
  PREFETCH = "prefetch",
  CE_LOCK_PAKNAME = "ODPaks/0000000000000000000011111111111111111111.pak",
  LOCK_PAKNAME = "ODPaks/0000000000000000000000000000000000000000.pak",
  EODPackID = {
    Audio = 30001,
    RankUpVideo = 70002,
    BuJiKaiXiang = 70003,
    Pet = 80030,
    Notice = 80400,
    DIY = 80040,
    GoldenSuit = 80050,
    XSuit = 80649,
    XSuit_Scene = 80702,
    RP = 80060,
    SocialLobby = 80070,
    HandBook = 80090,
    ModeSelect = 80900,
    Language_zh = 80124,
    Language_zhHK = 80125,
    Language_zhTW = 80126,
    PopularityGift = 70004,
    MainIcon = 80501,
    OtherIcon = 80502,
    HLOD = 80700,
    Theme = 80711,
    WOW_20W = 200000,
    Kol_Rank = 80713,
    UserCurEquipment = 99997,
    UserWardrobe = 99998,
    PREFETCH_ODPACKID = 999999,
    UnMatchPackID = -999
  }
}
PufferConst.Enum_AutoDownloadSet = {
  OnlyWifi = 1,
  Only4G = 2,
  WifiAnd4G = 3
}
PufferConst.Enum_StateIcon = {Ani = 1, RoundIcon = 2}
PufferConst.Enum_BundleID = {
  Prefetch = 100000,
  Recommend = 100001,
  SystemAndActivity = 100002,
  MapTPlan = 100006,
  HighQuality = 100007,
  AppearanceLatest = 100008,
  AppearanceRecent = 100009,
  AppearanceClassic = 100010,
  AppearanceNostalgia = 100013,
  WoW = 100011,
  WOWResAward = 100012,
  Recall = 100022,
  Mentor = 100023,
  FIT = 100024,
  MyAppearance = 100101
}
PufferConst.DynamicAppearanceID = {
  LatestAppearance = "LatestAppearance",
  RecentThreeVersion = "RecentThreeVersion"
}
PufferConst.RecommendBundleIDs = {
  PufferConst.Enum_BundleID.Recommend,
  PufferConst.Enum_BundleID.Recall,
  PufferConst.Enum_BundleID.Mentor,
  PufferConst.Enum_BundleID.FIT
}
PufferConst.Enum_RecommendType = {
  None = 0,
  New = 1,
  Recall = 2,
  Mentor = 3,
  FIT = 4
}
PufferConst.ENUM_DownloadType = {
  ODPAK = 1,
  ODPACK = 2,
  MAP = 3,
  RES = 4,
  SHADER = 5,
  PREFETCH = 6,
  UGCPAK = 7,
  UGCPACK = 8
}
PufferConst.ENUM_DownloadState = {
  Not = 0,
  Download = 1,
  Pause = 2,
  Done = 3,
  Error = 4,
  Wait = 5,
  Update = 6
}
PufferConst.DownloadStatePriority = {
  [PufferConst.ENUM_DownloadState.Not] = 1,
  [PufferConst.ENUM_DownloadState.Download] = 6,
  [PufferConst.ENUM_DownloadState.Pause] = 4,
  [PufferConst.ENUM_DownloadState.Done] = 0,
  [PufferConst.ENUM_DownloadState.Error] = 3,
  [PufferConst.ENUM_DownloadState.Wait] = 5,
  [PufferConst.ENUM_DownloadState.Update] = 2
}
PufferConst.ENUM_ReportMapEventType = {
  Progress = 0,
  Start = 1,
  Time = 2,
  Done = 3,
  Error = 4,
  Pause = 5,
  Continue = 6,
  AutoPause = 7
}
PufferConst.ENUM_ReportMapNetworkStatus = {
  Wifi = 1,
  ["4g"] = 2
}
PufferConst.ENUM_ReportMapDownloadMethod = {Auto = 1, Manual = 2}
PufferConst.ENUM_ReserveState = {
  Not = 0,
  Reserved = 1,
  CanDownload = 2
}
return PufferConst