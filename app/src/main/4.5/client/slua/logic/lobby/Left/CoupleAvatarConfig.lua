local ESceneType = {
  WarRank = 1,
  Upass = 2,
  Rank = 3,
  Preview = 4,
  Corps = 5,
  Social = 6,
  FromTPlanRank = 7,
  Sink = 8,
  PopularPKLeft = 11,
  PopularPKRight = 12,
  RoleInfo = 13,
  TeamPKLeft = 14,
  TeamPKRight = 15,
  ItemPreview = 16,
  HousekeeperCoemote = 17,
  PeakGameRank = 18,
  Multiplayer = 19,
  Lobby_Partner = 20,
  Lobby_Partner_Award = 21,
  Corps_Avatar_Capture = 22
}
local CoupleAvatarConfig = {
  ESceneType = ESceneType,
  ShowPosition = {
    [ESceneType.WarRank] = {
      X = -803.477417,
      Y = 1043.836182,
      Z = -5623
    },
    [ESceneType.Upass] = {
      X = -45.300003,
      Y = -383.5,
      Z = -14347.0
    },
    [ESceneType.Rank] = {
      X = -850,
      Y = 1043.836182,
      Z = -5623
    },
    [ESceneType.Preview] = {
      X = 25,
      Y = -383,
      Z = -14348.75
    },
    [ESceneType.Corps] = {
      X = -886,
      Y = 1043.836182,
      Z = -5623
    },
    [ESceneType.Social] = {
      X = -215.962997,
      Y = -56.193787,
      Z = 5279.437012
    },
    [ESceneType.FromTPlanRank] = {
      X = -340,
      Y = -873,
      Z = 90
    },
    [ESceneType.Sink] = {
      X = -100,
      Y = 0,
      Z = 89.5
    },
    [ESceneType.PopularPKLeft] = {
      X = -822.576355,
      Y = 1049.922485,
      Z = -5623.0
    },
    [ESceneType.PopularPKRight] = {
      X = -642.576355,
      Y = 1049.922485,
      Z = -5623.0
    },
    [ESceneType.RoleInfo] = {
      X = -850,
      Y = 1043.836182,
      Z = -5623
    },
    [ESceneType.TeamPKLeft] = {
      X = -822.576355,
      Y = 1049.922485,
      Z = -5623.0
    },
    [ESceneType.TeamPKRight] = {
      X = -642.576355,
      Y = 1049.922485,
      Z = -5623.0
    },
    [ESceneType.ItemPreview] = {
      X = -5360,
      Y = 27323,
      Z = -19273
    },
    [ESceneType.HousekeeperCoemote] = {
      X = -300,
      Y = 175,
      Z = 1800
    },
    [ESceneType.PeakGameRank] = {
      X = 19778.294922,
      Y = 0,
      Z = 89.5
    },
    [ESceneType.Lobby_Partner] = {
      X = -12900.8125,
      Y = -250,
      Z = 89.625557
    },
    [ESceneType.Lobby_Partner_Award] = {
      X = -12963.416016,
      Y = -250,
      Z = 89.625557
    },
    [ESceneType.Corps_Avatar_Capture] = {
      X = 900,
      Y = 0,
      Z = 89.5
    }
  },
  RotationConfig = {
    [ESceneType.FromTPlanRank] = {
      X = 0,
      Y = 0,
      Z = -50
    },
    [ESceneType.HousekeeperCoemote] = {
      X = 0,
      Y = 0,
      Z = -90
    }
  },
  PosType = {Left = 0, Right = 1},
  GenderType = {Male = 1, Female = 2},
  DefaultSwitcher = {
    isShowWeapon = true,
    isShowHelmet = true,
    isShowBg = true,
    isShowHighCloteEffect = false
  },
  AvatarType = {Self = 1, Friend = 2}
}
return CoupleAvatarConfig