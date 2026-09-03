local home_macros = {
  ENUM_MODE_SELECTION_TAB_TYPE = {
    Friend = 2,
    Recommend = 1,
    Rank = 3,
    History = 4,
    Collect = 5
  },
  ENUM_VISCNT_REQ_TYPE = {
    ModeSelection = 1,
    Rank = 2,
    DoorPlate = 3,
    PlayerCard = 4,
    FriendList = 5,
    TeamInfo = 6,
    Chat = 7
  },
  visCntRefreshCD = 60,
  Enter_SocialIsland_Start = {Default = 100, Store = 101},
  Home_SubMode = {
    Visit = 880047,
    EditPlan_Standalone = 880048,
    EditHome = 880049,
    PerformanceMode = 880050,
    EditPlan = 880051
  },
  ENUM_FOLLOW_REQ_TYPE = {
    FriendList = 1,
    PlayerCard = 2,
    TeamInfo = 3,
    InGame = 4
  },
  ENUM_DETAIL_SCENE_TYPE = {
    Recommend = 1,
    SearchHome = 100,
    FriendTab = 101,
    RecommendTab = 102,
    RankTab = 103,
    HistoryTab = 104,
    CollectTab = 105,
    SocialLobby = 106,
    RoleInfo = 107,
    Rank = 108,
    Share = 109,
    FriendChannel = 110,
    Moment = 111,
    MainLobby = 112
  },
  ENUM_VISIT_SCENE_TYPE = {
    Recommend = 1,
    RoleInfoCard = 101,
    CollectionTask = 102,
    CollectionRank = 103,
    VisitPopup = 104,
    SocialLobby = 105,
    HouseKeeperMsg = 106,
    RoleInfo = 107,
    MainLobby = 108
  },
  ENUM_HOME_TASK_TYPE = {HomeCollection = 0, HomePK = 1},
  ENUM_HOME_ROOM_TYPE = {ordinary = "ordinary", privilege = "privilege"},
  ENUM_HOME_ROOM_ATTRI = {
    Invited = 1,
    FriendsAndInvited = 2,
    All = 3
  },
  ENUM_LOBBY_HOME_MAIN_TAB_TYPE = {
    Banner = 101,
    Recommend = 1,
    Shop = 2,
    Task = 3,
    Loot = 4,
    Spin = 5,
    Competition = 6
  },
  ENUM_LOBBY_HOME_MAIN_BANNER_TYPE = {
    MapleStyle = 1,
    NorthernStyle = 2,
    BayStyle = 3,
    SylvanStyle = 4,
    RomanticStyle = 5,
    AnniversaryActivity = 7
  }
}
return home_macros