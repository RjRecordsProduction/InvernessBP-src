local TeamPlatForm_Macro = {
  Enum_PlatformType = {
    None = 0,
    Normal = 1,
    TPlan = 2,
    WoW = 3,
    Peak = 4,
    WoWHall = 5
  },
  Enum_FilterLanguage_Scene = {TeamPlatForm = 1, Chat = 2},
  Enum_FilterType = {
    Filter = 1,
    Publish = 2,
    Change = 3
  },
  Enum_MicVoiceOptionType = {
    None = 0,
    Mic = 1,
    Voice = 2
  },
  Enum_ButtonEntranceState = {
    FindTeam = 1,
    InRecruit = 2,
    SendRecruit = 3
  },
  Enum_PublishRecruitMsgFromType = {
    LobbyEntrance = 1,
    Chat = 2,
    TeamPlatForm = 3,
    TPlanLobbyEntrance = 4,
    TPlanChat = 5,
    TPlanTeamPlatForm = 6,
    WoWTeamPlatForm = 7,
    WoWChat = 8,
    CorpsHomepage = 9
  },
  Enum_RecruitSyncReason = {
    Publish = 1,
    Modify = 2,
    Timeout = 3,
    Cancel = 4,
    JoinTeam = 5,
    QuitTeam = 6,
    TeamDismiss = 7,
    GameStart = 8,
    ChangeLeader = 9
  },
  ChannelTab = {
    Classic = 1,
    WoW = 2,
    Peak = 3
  },
  WoWMapType = {mod = 1, collection = 2}
}
return TeamPlatForm_Macro