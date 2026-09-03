local main_city_config = {
  C_GameSubMode = 26000,
  enterMainCityKeepTime = 120,
  EnumGetMainCityInfoType = {
    LobbyToMainCity = 1,
    MainCityToMainCity = 2,
    Blacklist = 3,
    EnterTeamMainCity = 4
  },
  EnumFireType = {
    Fist = 1,
    Wand = 2,
    Interactive = 3,
    InteractiveInterrupt = 4,
    SayHiRobot = 5,
    PartyPopper = 6,
    Multipose = 7
  },
  FireTypePriority = nil,
  ESceneType = {
    Lobby = 1,
    MainCity = 2,
    Fighting = 3,
    Others = 4
  },
  EMainUISystemType = {
    ActivityCenter = 1,
    SpecialDiscount = 2,
    RP = 3,
    Supply = 4,
    JKSupply = 5,
    Store = 6,
    JKStore = 7,
    CrazyWeekendAct = 8
  },
  EMainUIActBubbleType = {
    Return = 1,
    Recruit = 2,
    RedEnvelope = 3,
    KJEntrance = 4,
    WeddingRedEnvelope = 5
  },
  MainCityMapKey = "map_maincity"
}
local E = main_city_config.EnumFireType
main_city_config.FireTypePriority = {
  [E.Fist] = 1,
  [E.Wand] = 100,
  [E.Interactive] = 80,
  [E.InteractiveInterrupt] = 110,
  [E.SayHiRobot] = 30,
  [E.PartyPopper] = 101,
  [E.Multipose] = 105
}
return main_city_config