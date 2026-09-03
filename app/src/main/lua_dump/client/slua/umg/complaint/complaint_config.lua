local SecurityCommonUtils = require("GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils")
local IsString = SecurityCommonUtils.IsString
local LogIf = SecurityCommonUtils.LogIf
local ComplaintConfig = {
  EComplaintModule = {
    DeathMatch = "DeathMatch",
    Infection = "Infection",
    Vehicle = "Vehicle",
    Lobby = "Lobby",
    Classic = "Classic",
    Wonderful = "Wonderful",
    DeathReplay = "DeathReplay",
    SocialIsland = "SocialIsland",
    XMissionMetro = "XMissionMetro",
    Chat = "Chat",
    Moment = "Moment",
    UGC = "UGC",
    UGCCopy = "UGCCopy",
    UGCRank = "UGCRank",
    UGCPlayer = "UGCPlayer",
    UGCPrefab = "UGCPrefab",
    UGCAICopilot = "UGCAICopilot",
    Home = "Home",
    HomeCopy = "HomeCopy",
    HomeMessage = "HomeMessage",
    HomePlayer = "HomePlayer",
    Voice = "Voice",
    UGCRecommendVideo = "UGCRecommendVideo",
    UGCCollections = "UGCCollections",
    IntimateRelation = "intimateRelation",
    MainCityPlayer = "MainCityPlayer",
    Escape = "Escape",
    TeamQuick = "TeamQuick"
  },
  ETeamMode = {
    Solo = 1,
    Double = 2,
    Four = 4,
    Eight = 8
  },
  EComplaintReasonType = {
    NOSELECT = 0,
    DIRTYWORD = 2,
    CHEATED = 4,
    USEBUG = 8,
    HurtTeammate = 16,
    OTHER = 32,
    TEAMUP = 64,
    IllegalDealing = 128,
    NEGATIVE = 256,
    DIRTYTEXT = 512
  },
  EComplaintSubReasonType = {
    AutoAim = 1,
    SpeedHack = 2,
    WallHack = 3,
    WallNoClip = 4,
    AbnormalBullet = 5,
    HighJump = 6,
    VehicleFly = 7,
    AbnormalSound = 8,
    NoRecoil = 9,
    OtherCheat = 10,
    ExitTeamBeforeBoarding = 11,
    ExitMatchDuringFighting = 12,
    Inactivity = 13,
    TextViolation = 14,
    VoiceViolation = 15
  },
  EComplaintFrom = {
    Default = "Default",
    Lobby = "Lobby",
    History = "History",
    SocialIsland = "SocialIsland",
    Chat = "Chat",
    Moment = "Moment",
    DeathMatchHistory = "DeathMatchHistory",
    Wonderful = "Wonderful",
    DeathReplay = "DeathReplay",
    XMissionMetro = "XMissionMetro",
    UGC = "UGC",
    UGCRank = "UGCRank",
    UGCVideo = "UGCVideo",
    HomeMessage = "HomeMessage",
    UGCCollections = "UGCCollections",
    IntimateRelation = "IntimateRelation",
    Escape = "Escape",
    TeamQuick = "TeamQuick"
  },
  EComplaintSceneTLogType = {
    InBattle = 1,
    Corpus = 4,
    MomentPost = 8,
    MomentComment = 9,
    ChatText = 10,
    ChatPortrait = 11,
    ChatNickname = 12,
    WonderfulReplay = 13,
    SecurityZone = 14,
    BattleResult = 15,
    BattleHistory = 16,
    DeathReplay = 17,
    SpectateAfterDeath = 18,
    LobbyRoleInfo = 19,
    SocialIsland = 20,
    InBattleQuickReport = 21,
    SpectateAsFriend = 22,
    HawkEyePatrol = 23,
    UGC = 24,
    UGCRank = 25,
    HomePigeon = 26,
    HomeMessageBoard = 27,
    HomeMessageWelcomeText = 28,
    UGCVideo = 29,
    UGCCollectionList = 30,
    UGCSearchWords = 31,
    IntimateRelation = 32,
    ButlerAigcAll = 33,
    ButlerAigcSingle = 34,
    AICopilotReport = 35,
    BlackIndustryReport = 36,
    UGCPrefabReport = 37,
    PopularityPK = 38,
    UGCAnimPrefabReport = 39,
    UGCModPrefabReport = 40,
    UGCCodePrefabReport = 41,
    UGCSoundReport = 42,
    UGCImageReport = 43,
    UGCCustomUIReport = 44,
    SmartAssistantV2AIChat = 45,
    TeamQuick = 46
  },
  EComplaintAIType = {
    BehaviorTree = 1,
    MachineLearning = 2,
    LobbySmartAssistantAIType = 3,
    CentaurAIType = 5
  },
  EComplaintBotType = {
    Playmate = 0,
    Delivery = 1,
    TeammateTakeOver = 2,
    Mercenary = 3,
    LobbySmartAssistantBotType = 4,
    CentaurBotType = 5
  },
  EReportEnvironmentType = {
    Unknown = 1,
    InBattle = 2,
    BattleResult = 3,
    BattleHistory = 4,
    DeathReplay = 5,
    SpectateAfterDeath = 6,
    SpectateAsFriend = 7,
    Lobby = 8,
    WonderfulReplay = 9,
    Chat = 10
  },
  AutoCloseEventList = {
    BattleResult = {
      EventType = EVENTTYPE_STATE,
      EventID = EVENTID_GAMESTATE_ON_BATTLE_RESULT
    },
    DeathReplayPlaybackEnded = {
      EventType = EVENTTYPE_INGAME_REPLAY,
      EventID = EVENTID_DEATH_REPLAY_PLAYBACK_ENDED
    },
    SocialIslandDuelResult = {
      EventType = EVENTTYPE_SOCIAL_ISLAND,
      EventID = EVENTID_SOCIAL_ISLAND_SHOW_REQ_RESULT_PANEL
    },
    SocialIslandArenaResult = {
      EventType = EVENTTYPE_SOCIAL_ISLAND,
      EventID = EVENTID_SOCIAL_ISLAND_BATTLE_RESULT_CHANGE
    },
    LobbyLoadingBegin = {
      EventType = EVENTTYPE_LOBBY,
      EventID = EVENTID_LOADING_BEGIN
    }
  },
  AutoClosePlayerDropDownListEventMap = {
    OnShowReportExplainUI = {
      EventType = EVENTTYPE_REPORT_PLAYER,
      EventID = EVENTID_ON_SHOW_REPORT_PLAYER_EXPLAIN_UI
    },
    OnShowReasonExplainUI = {
      EventType = EVENTTYPE_REPORT_PLAYER,
      EventID = EVENTID_ON_SHOW_REPORT_PLAYER_REASON_EXPLAIN_UI
    }
  },
  EReportSceneType = {
    Others = 0,
    InIsland = 1,
    InBattle = 2,
    InPlane = 3,
    InMainCity = 4
  }
}
local EComplaintSubReasonType = ComplaintConfig.EComplaintSubReasonType
local EComplaintReasonType = ComplaintConfig.EComplaintReasonType
local EReasonType = {
  Default = "Default",
  Chat = "Chat",
  Moment = "Moment",
  XMissionMetro = "Metro",
  UGC = "UGC",
  UGC_Error = "UGC_Error",
  UGCRank = "UGCRank",
  UGCPic = "UGCPic",
  UGCText = "UGCText",
  UGCMap = "UGCMap",
  UGCVideo = "UGCVideo",
  UGCPrefabText = "UGCPrefabText",
  UGCPrefabContent = "UGCPrefabContent",
  UGCAIHelperContent = "UGCAIHelperContent",
  UGCAIHelperLowQuality = "UGCAIHelperLowQuality",
  UGCAnimText = "UGCAnimText",
  UGCAnimContent = "UGCAnimContent",
  UGCCodeText = "UGCCodeText",
  UGCCodeContent = "UGCCodeContent",
  UGCModGenText = "UGCModGenText",
  UGCModGenContent = "UGCModGenContent",
  HomePic = "HOMEPIC",
  HomeText = "HOMETEXT",
  HomeMap = "HOMEMAP",
  UGCCollectionName = "UGCCollectionName",
  UGCCollectionContent = "UGCCollectionContent",
  UGCSearchReport = "UGCSearchReport",
  BlackIndustry = "BlackIndustry",
  HOMEBLACK = "HOMEBLACK",
  PopularityPK = "PopularityPK",
  UGCModGenText = "UGCModGenText",
  UGCModGenContent = "UGCModGenContent",
  UGCSoundText = "UGCSoundText",
  UGCSoundContent = "UGCSoundContent",
  UGCImageText = "UGCImageText",
  UGCImageContent = "UGCImageContent",
  UGCCustomUIText = "UGCCustomUIText",
  UGCCustomUIContent = "UGCCustomUIContent",
  UGCMapLobby = "UGCMapLobby",
  TeamQuick = "TeamQuick"
}
ComplaintConfig.local ComplaintReasonHelpStrCfg = {
  [EComplaintReasonType.TEAMUP] = 47122
}
ComplaintConfig.local EComplaintModule = ComplaintConfig.EComplaintModule
local EComplaintUI = {}
EComplaintUI[EComplaintModule.DeathMatch] = {
  sUIName = "ui_complaint_deathmatch",
  sReasonType = EReasonType.Default,
  nNumSelectedReasonMax = 3
}
EComplaintUI[EComplaintModule.Infection] = {
  sUIName = "ui_complaint_infection",
  sReasonType = EReasonType.Default,
  nNumSelectedReasonMax = 3
}
EComplaintUI[EComplaintModule.Vehicle] = {
  sUIName = "ui_complaint_vehicle",
  sReasonType = EReasonType.Default,
  nNumSelectedReasonMax = 3
}
EComplaintUI[EComplaintModule.Lobby] = {
  sUIName = "ui_complaint_lobby",
  sReasonType = EReasonType.Default,
  nNumSelectedReasonMax = 3
}
EComplaintUI[EComplaintModule.Classic] = {
  sUIName = "ui_complaint_classic",
  sReasonType = EReasonType.Default,
  nNumSelectedReasonMax = 3
}
EComplaintUI[EComplaintModule.Wonderful] = {
  sUIName = "ui_complaint_wonderful",
  sReasonType = EReasonType.Default,
  nNumSelectedReasonMax = 3
}
EComplaintUI[EComplaintModule.DeathReplay] = {
  sUIName = "ui_complaint_deathreplay",
  sReasonType = EReasonType.Default,
  nNumSelectedReasonMax = 3
}
EComplaintUI[EComplaintModule.SocialIsland] = {
  sUIName = "ui_complaint_socialisland",
  sReasonType = EReasonType.Default,
  nNumSelectedReasonMax = 3
}
EComplaintUI[EComplaintModule.XMissionMetro] = {
  sUIName = "ui_complaint_xmissionmetro",
  sReasonType = EReasonType.XMissionMetro,
  nNumSelectedReasonMax = 3
}
EComplaintUI[EComplaintModule.Chat] = {
  sUIName = "ui_complaint_chat",
  sReasonType = EReasonType.Chat,
  nNumSelectedReasonMax = 1
}
EComplaintUI[EComplaintModule.UGCRecommendVideo] = {
  sUIName = "ui_complaint_ugc_recommend_video",
  sReasonType = EReasonType.UGCVideo,
  nNumSelectedReasonMax = 3
}
EComplaintUI[EComplaintModule.Moment] = {
  sUIName = "ui_complaint_moment",
  sReasonType = EReasonType.Moment,
  nNumSelectedReasonMax = 1
}
EComplaintUI[EComplaintModule.IntimateRelation] = {
  sUIName = "ui_complaint_intimateRelation",
  sReasonType = EReasonType.Chat,
  nNumSelectedReasonMax = 1
}
EComplaintUI[EComplaintModule.UGC] = {
  sUIName = "UGCReportWorkCopy",
  sReasonType = EReasonType.UGCPic,
  nNumSelectedReasonMax = 3
}
EComplaintUI[EComplaintModule.UGCCopy] = {
  sUIName = "ugc_mod_report",
  sReasonType = EReasonType.UGCPic,
  nNumSelectedReasonMax = 3
}
EComplaintUI[EComplaintModule.UGCPlayer] = {
  sUIName = "ui_complaint_ugc",
  sReasonType = EReasonType.Default,
  nNumSelectedReasonMax = 3
}
EComplaintUI[EComplaintModule.UGCRank] = {
  sUIName = "ui_complaint_ugc_rank",
  sReasonType = EReasonType.UGCRank,
  nNumSelectedReasonMax = 3
}
EComplaintUI[EComplaintModule.Home] = {
  sUIName = "home_report",
  sReasonType = EReasonType.HomePic,
  nNumSelectedReasonMax = 3
}
EComplaintUI[EComplaintModule.HomeCopy] = {
  sUIName = "home_mod_report",
  sReasonType = EReasonType.HomePic,
  nNumSelectedReasonMax = 3
}
EComplaintUI[EComplaintModule.HomeMessage] = {
  sUIName = "home_message_report",
  sReasonType = EReasonType.Chat,
  nNumSelectedReasonMax = 1
}
EComplaintUI[EComplaintModule.HomePlayer] = {
  sUIName = "ui_complaint_home",
  sReasonType = EReasonType.Default,
  nNumSelectedReasonMax = 3
}
EComplaintUI[EComplaintModule.Voice] = {
  sUIName = "ui_complaint_voice",
  sReasonType = EReasonType.Voice,
  nNumSelectedReasonMax = 1
}
EComplaintUI[EComplaintModule.UGCCollections] = {
  sUIName = "ugc_collections_report",
  sReasonType = EReasonType.UGCCollectionName,
  nNumSelectedReasonMax = 3
}
EComplaintUI[EComplaintModule.MainCityPlayer] = {
  sUIName = "ui_complaint_main_city",
  sReasonType = EReasonType.Default,
  nNumSelectedReasonMax = 3
}
EComplaintUI[EComplaintModule.Escape] = {
  sUIName = "ui_complaint_escape",
  sReasonType = EReasonType.Default,
  nNumSelectedReasonMax = 3
}
EComplaintUI[EComplaintModule.UGCPrefab] = {
  sUIName = "ugc_prefab_bug",
  sReasonType = EReasonType.UGCPrefabText,
  nNumSelectedReasonMax = 3
}
EComplaintUI[EComplaintModule.UGCAICopilot] = {
  sUIName = "UGC_AiCopilot_Report",
  sReasonType = EReasonType.UGCAIHelperContent,
  nNumSelectedReasonMax = 3
}
EComplaintUI[EComplaintModule.TeamQuick] = {
  sUIName = "ui_complaint_team_quick",
  sReasonType = EReasonType.TeamQuick,
  nNumSelectedReasonMax = 1
}
ComplaintConfig.local ParseReasonIgnoreEGameModeType = function(sIgnoreEGameModeType)
  local tSet = {}
  if LogIf(not IsString(sIgnoreEGameModeType), "invalid sIgnoreEGameModeType") then
    return tSet
  end
  local StringUtil = require("common.string_util")
  for _, sItem in pairs(StringUtil.Split(sIgnoreEGameModeType, ";")) do
    nItem = tonumber(sItem)
    if nItem then
      tSet[nItem] = true
    end
  end
  return tSet
end
function ComplaintConfig.GetReasonConfig(sReasonType)
  local list = {}
  local ComplaintReason = CDataTable.GetTable("ComplaintReason")
  if not ComplaintReason then
    log_error(" ComplaintConfig.GetReasonConfig : ComplaintReason is nil!")
    return list
  end
  for _, info in pairs(ComplaintReason) do
    local bIsReasonEnabled = info.Model == sReasonType
    if sReasonType == EReasonType.XMissionMetro and info.Model == EReasonType.Default then
      bIsReasonEnabled = true
    end
    if bIsReasonEnabled then
      table.insert(list, {
        reaName = info.Name or "",
        hasSubType = info.HasSub == 1,
        reaDes = info.Des or "",
        codeType = info.Code or 0,
        subList = info.SubModel or "",
        bForceIgnoreTeammate = info.ForceIgnoreTeammate == 1,
        bForceIgnoreEnemy = info.ForceIgnoreEnemy == 1,
        tSetIgnoreTeammateEGameModeType = ParseReasonIgnoreEGameModeType(info.IgnoreTeammateEGameModeType),
        tSetIgnoreEnemyEGameModeType = ParseReasonIgnoreEGameModeType(info.IgnoreEnemyEGameModeType)
      })
    end
  end
  return list
end
function ComplaintConfig.GetSubReasonIdsByPrimaryCode(primarySeasonCode)
  local subResonIds = {}
  local primarySeasonInfo
  local ComplaintReason = CDataTable.GetTable("ComplaintReason")
  for _, info in pairs(ComplaintReason) do
    if info.Code == primarySeasonCode then
      primarySeasonInfo = info
      break
    end
  end
  if primarySeasonInfo == nil then
    return subResonIds
  end
  if ComplaintConfig.ComplaintReason2SubReasonSetMap[primarySeasonInfo.SubModel] == nil then
    local subReasons = CDataTable.GetTable("ComplaintSubReason")
    if not subReasons then
      log_error(" ComplaintConfig.GetSubReasonConfig : ComplaintSubReason is nil!")
      return subResonIds
    end
    for _, info in pairs(subReasons) do
      if info.SubModel == primarySeasonInfo.SubModel then
        subResonIds[info.ID] = true
      end
    end
    ComplaintConfig.ComplaintReason2SubReasonSetMap[primarySeasonInfo.SubModel] = subResonIds
  end
  return ComplaintConfig.ComplaintReason2SubReasonSetMap[primarySeasonInfo.SubModel]
end
function ComplaintConfig.GetSubReasonConfig(subReaType)
  local list = {}
  local ComplaintSubReason = CDataTable.GetTable("ComplaintSubReason")
  if not ComplaintSubReason then
    log_error(" ComplaintConfig.GetSubReasonConfig : ComplaintSubReason is nil!")
    return list
  end
  for _, info in pairs(ComplaintSubReason) do
    if info.SubModel == subReaType then
      local temp = {
        subReaName = info.SubName or "",
        subCode = info.SubCode or 0,
        subDescribe = info.SubDescribe or "",
        subModel = info.SubModel or ""
      }
      table.insert(list, temp)
    end
  end
  return list
end
function ComplaintConfig.ConvertTeamModeTypeForTLog(nTeamCharacterCount)
  nTeamCharacterCount = tonumber(nTeamCharacterCount)
  if not nTeamCharacterCount then
    return ComplaintConfig.ETeamMode.Solo
  end
  local nTeamMode = ComplaintConfig.ETeamMode.Eight
  if nTeamCharacterCount <= 1 then
    nTeamMode = ComplaintConfig.ETeamMode.Solo
  elseif nTeamCharacterCount <= 2 then
    nTeamMode = ComplaintConfig.ETeamMode.Double
  elseif nTeamCharacterCount <= 4 then
    nTeamMode = ComplaintConfig.ETeamMode.Four
  end
  return nTeamMode
end
local CacheMapBetweenReasonAndSubReasonCode = function()
  if ComplaintConfig.ComplaintReason2SubReasonSetMap then
    return
  end
  local tReasonDataTable = CDataTable.GetTable("ComplaintReason")
  if not tReasonDataTable then
    return
  end
  local tSubReasonDataTable = CDataTable.GetTable("ComplaintSubReason")
  if not tSubReasonDataTable then
    return
  end
  local tReasonArray = {}
  for _, tReasonInfo in pairs(tReasonDataTable) do
    if tReasonInfo then
      local nReasonCode = tonumber(tReasonInfo.Code)
      local sSubReasonModel = tReasonInfo.SubModel
      if nReasonCode and IsString(sSubReasonModel) then
        table.insert(tReasonArray, {nReasonCode = nReasonCode, sSubReasonModel = sSubReasonModel})
      end
    end
  end
  local tSubModel2SubReasonSetMap = {}
  for _, tSubReasonInfo in pairs(tSubReasonDataTable) do
    if tSubReasonInfo then
      local nSubReasonCode = tonumber(tSubReasonInfo.ID)
      local sSubReasonModel = tSubReasonInfo.SubModel
      if nSubReasonCode and IsString(sSubReasonModel) then
        if not tSubModel2SubReasonSetMap[sSubReasonModel] then
          tSubModel2SubReasonSetMap[sSubReasonModel] = {}
        end
        tSubModel2SubReasonSetMap[sSubReasonModel][nSubReasonCode] = true
      end
    end
  end
  local tReason2SubReasonSetMap = {}
  for _, tReasonInfo in pairs(tReasonArray) do
    local tSubReasonSet = tSubModel2SubReasonSetMap[tReasonInfo.sSubReasonModel]
    if tSubReasonSet then
      tReason2SubReasonSetMap[tReasonInfo.nReasonCode] = tSubReasonSet
    end
  end
  local tMapSubReasonCodeToReasonCode = {}
  for nReasonCode, tSubReasonCodeSet in pairs(tReason2SubReasonSetMap) do
    for nSubReasonCode, _ in pairs(tSubReasonCodeSet) do
      tMapSubReasonCodeToReasonCode[nSubReasonCode] = nReasonCode
    end
  end
  ComplaintConfig.Complain  ComplaintConfig.end
CacheMapBetweenReasonAndSubReasonCode()
return ComplaintConfig