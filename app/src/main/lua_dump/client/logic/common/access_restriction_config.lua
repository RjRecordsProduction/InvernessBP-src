local access_restriction_config = {
  EPlayerType = {
    Normal_Player = 1000,
    Doubtful_Player = 1001,
    Normal_Tourist = 2000,
    High_Kill_Tourist = 2001,
    Doubtful_Tourist = 2002,
    Low_Priority_Player = 4000
  },
  EAccessType = {
    BattleResult = 1,
    SegmentLimit = 2,
    SelectZone = 3,
    SelectMatchCount = 4,
    TeamInvite = 5,
    Mentor = 6,
    TeamPlatform = 7,
    GameAgain = 8,
    TeamRecruit = 9,
    TeamCode = 10,
    Matching = 11,
    FriendWatch = 12,
    SocialIsland = 13,
    WorldChat = 14,
    Wireless = 15,
    LocalRank = 16,
    NoLocalRank = 17,
    WarRank = 18,
    SpaceGift = 19,
    ClubChat = 20
  }
}
return access_restriction_config