local logic_community = {
  EGameStateType = {
    GAMESTATE_UNKNOWN = 0,
    GAMESTATE_LOBBY_FREE = 1,
    GAMESTATE_ROOM_FREE = 2,
    GAMESTATE_GAMING = 3
  },
  EVersionEnv = {
    Test = 0,
    CE = 1,
    Release = 2
  },
  EClubStateValue = {
    CHAT_STATE_OFFLINE = 0,
    CHAT_STATE_ONLINE = 1,
    CHAT_STATE_WATCH_LIVE = 2
  },
  lastPostState = 0,
  systemId = 16,
  _bInit = false,
  ClubMemberCache = {},
  ClubMemberStatusCache = {},
  SubscribeInfo = nil,
  GameScene = {
    LobbyEntry = "LobbyEntry",
    FriendSideBar = "FriendSideBar",
    CorpsFeed = "CorpsFeed",
    ChatMoreClub = "ChatMoreClub",
    ChatClubHome = "ChatClubHome",
    ChatClubHome1 = "ChatClubHome1",
    FromPersonalPopup = "FromPersonalPopup",
    FromPersonalSpace = "FromPersonalSpace",
    BackFromPersonalSpace = "BackFromPersonalSpace",
    ForcePopup = "ForcePopup",
    LobbyBanner = "LobbyBanner",
    ActivityCenter = "ActivityCenter",
    AliasJump = "AliasJump",
    GotItemShare = "GotItemShare",
    WardrobeItemShare = "WardrobeItemShare",
    PopularityRecent = "PopularityRecent",
    ClubOwnerMessage = "ClubOwnerMessage",
    ClubRecentMessage = "ClubRecentMessage",
    IntimacyRecuit = "IntimacyRecuit",
    VersionTopic = "VersionTopic",
    InGamePhoto = "InGamePhoto",
    SmartAssistant = "SmartAssistant",
    UGCAuthorCertification = "UGCAuthorCertification",
    UGCAuthorHomepage = "UGCAuthorHomepage",
    UGCGuestHomepage = "UGCGuestHomepage",
    UGCMapDetail = "UGCMapDetail",
    UGCAuthorLevel = "UGCAuthorLevel",
    UGCCommunityMainPange = "UGCCommunityMainPange",
    UGCMapUpload = "UGCMapUpload",
    UGCMapPalyFull = "UGCMapPalyFull",
    UGCMapCollectionShare = "UGCMapCollectionShare",
    CollectionShare = "CollectionShare",
    CardExchange = "CardExchange"
  },
  PublishFeedType = {
    WardrobeItem = 1,
    GotItem = 2,
    H5Creative = 3,
    InGamePhoto = 4,
    CollectionShare = 9,
    CardExchange = 1001
  },
  ClubToGameCfg = {},
  versionUpdateInfo = nil,
  isStayInH5 = false
}
return logic_community