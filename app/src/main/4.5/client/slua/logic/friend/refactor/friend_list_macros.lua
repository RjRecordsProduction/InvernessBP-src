local friend_list_macros = {}
friend_list_macros.ENUM_STATE = {
  FRIENDS = "Friends",
  FRIENDS_DELETE = "FriendsDelete",
  FRIENDS_TOP = "FriendsTop"
}
friend_list_macros.ENUM_TAB = {
  ENUM_FRIEND_TAG = 1,
  ENUM_RECENT_TAG = 2,
  ENUM_CORPS_TAG = 3,
  ENUM_LBS_NEAR = 4,
  ENUM_WOW_TAG = 5,
  ENUM_TEAM_TAG = 6
}
friend_list_macros.ENUM_OPEN_FROM = {
  LOBBY = 0,
  ISLAND = 1,
  TPLAN = 2,
  ISMOREPLAYERNUM = 3,
  TPLANISMOREPLAYERNUM = 4,
  PLANPH = 5,
  CREATIVEWOW = 6,
  WOWMod = 7,
  UGCPlayHallInvite = 8,
  UGCPubMod = 9,
  WOWTogether = 10,
  SINGLE_TRAINING = 11,
  PLANCH = 12,
  WOWNewHall = 13
}
friend_list_macros.LocMap = {
  [0] = 102124,
  [1] = 7890,
  [2] = 4132,
  [3] = 7889
}
friend_list_macros.C_ModeMap = {
  [1] = "solo",
  [2] = "duo",
  [3] = "squad",
  [4] = "fppsolo",
  [5] = "fppduo",
  [6] = "fppsquad"
}
friend_list_macros.C_Colors = {
  GRAY = FSlateColor(FLinearColor(0, 0, 0, 0.7)),
  BLUE = FSlateColor(FLinearColor(0.012893, 0.013702, 0.473532, 1)),
  YELLOW = FSlateColor(FLinearColor(0.693872, 0.14996, 0.0, 1)),
  GREEN = FSlateColor(FLinearColor(0.030713, 0.423268, 0.201556, 1)),
  RED = FSlateColor(FLinearColor(0.58, 0, 0.02, 1)),
  ANNIVERSARY = FSlateColor(FLinearColor(0.89, 0.742, 0.082, 1)),
  ONLINE = FLinearColor(1, 1, 1, 1),
  OFFLINE = FLinearColor(1, 1, 1, 0.5),
  STATE_GREEN = FSlateColor(FLinearColor(0.051269, 0.838799, 0.686686, 1)),
  STATE_BLUE = FSlateColor(FLinearColor(0.191202, 0.428691, 1, 1)),
  STATE_ORANGE = FSlateColor(FLinearColor(0.693872, 0.14996, 0.0, 1)),
  STATE_WHITE = FSlateColor(FLinearColor(1, 1, 1, 0.7)),
  STATE_RED = FSlateColor(FLinearColor(0.58, 0, 0, 1))
}
friend_list_macros.C_MaincityOpePic = {
  "/Game/UMG/Texture_200/Atlas/LobbyUI/Frames/Common_Icon_Friends_012_png.Common_Icon_Friends_012_png",
  "/Game/UMG/Texture_200/Atlas/LobbyUI/Frames/Common_Icon_Friends_011_png.Common_Icon_Friends_011_png"
}
friend_list_macros.C_IslandOpePic = {
  "/Game/UMG/Texture_200/Atlas/LobbyUI/Frames/Common_Icon_Friends_015_png.Common_Icon_Friends_015_png",
  "/Game/UMG/Texture_200/Atlas/LobbyUI/Frames/Common_Icon_Friends_014_png.Common_Icon_Friends_014_png",
  "/Game/UMG/Texture_200/Atlas/LobbyUI/Frames/Common_Icon_Friends_021_png.Common_Icon_Friends_021_png",
  "/Game/UMG/Texture_200/Atlas/LobbyUI/Frames/Common_Icon_Friends_022_png.Common_Icon_Friends_022_png"
}
friend_list_macros.C_ReserveOpePic = {
  "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Btn_Lv2_Huise_png.Common_Btn_Lv2_Huise_png",
  "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Btn_Lv2_Bukedian_png.Common_Btn_Lv2_Bukedian_png",
  ""
}
friend_list_macros.C_WowOpePic = {
  "/Game/UMG/Texture_200/Atlas/LobbyUI/Frames/Lobby_Icon_WonderfulWorld_png.Lobby_Icon_WonderfulWorld_png",
  "/Game/UMG/Texture_200/Atlas/LobbyUI/Frames/Lobby_Icon_WonderfulWorld_1_png.Lobby_Icon_WonderfulWorld_1_png",
  "/Game/UMG/Texture_200/Atlas/LobbyUI/Frames/Lobby_Icon_WonderfulWorld_2_png.Lobby_Icon_WonderfulWorld_2_png",
  "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Follow_png.Common_Icon_Follow_png"
}
friend_list_macros.C_OfflineOpePic = {
  "/Game/UMG/Texture_200/Atlas/LobbyUI/Frames/lobby_image_implement_05_png_png.lobby_image_implement_05_png_png",
  "/Game/UMG/Texture_200/Atlas/LobbyUI/Frames/lobby_image_implement_04_png.lobby_image_implement_04_png"
}
friend_list_macros.C_HomeOpePic = {
  "/Game/UMG/Texture_200/Atlas/LobbyUI/Frames/Common_Icon_Friends_017_png.Common_Icon_Friends_017_png",
  "/Game/UMG/Texture_200/Atlas/LobbyUI/Frames/Common_Icon_Friends_016_png.Common_Icon_Friends_016_png"
}
friend_list_macros.C_CollectionHallOpePic = {
  "/Game/UMG/Texture_200/Atlas/LobbyUI/Frames/Common_Icon_Friends_020_png.Common_Icon_Friends_020_png",
  "/Game/UMG/Texture_200/Atlas/LobbyUI/Frames/Common_Icon_Friends_019_png.Common_Icon_Friends_019_png"
}
friend_list_macros.C_SingleTrainingOpePic = {
  "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Range_png.Common_Icon_Range_png"
}
friend_list_macros.C_FriendTabPic = {
  Friend = {
    Selected = "/Game/UMG/Texture_200/Atlas/LobbyUI/Frames/Common_Tab_Friend_Xuanzhong_png.Common_Tab_Friend_Xuanzhong_png",
    UnSelect = "/Game/UMG/Texture_200/Atlas/LobbyUI/Frames/Common_Tab_Friend_png.Common_Tab_Friend_png"
  },
  Recent = {
    Selected = "/Game/UMG/Texture_200/Atlas/LobbyUI/Frames/Common_Tab_Daojishi_Xuanzhong_png.Common_Tab_Daojishi_Xuanzhong_png",
    UnSelect = "/Game/UMG/Texture_200/Atlas/LobbyUI/Frames/Common_Tab_Daojishi_png.Common_Tab_Daojishi_png"
  },
  Corps = {
    Selected = "/Game/UMG/Texture_200/Atlas/LobbyUI/Frames/Common_Tab_Crops_Xuanzhong_png.Common_Tab_Crops_Xuanzhong_png",
    UnSelect = "/Game/UMG/Texture_200/Atlas/LobbyUI/Frames/Common_Tab_Crops_png.Common_Tab_Crops_png"
  },
  Near = {
    Selected = "/Game/UMG/Texture_200/Atlas/LobbyUI/Frames/Common_Tab_Local_xuangzhong_png.Common_Tab_Local_xuangzhong_png",
    UnSelect = "/Game/UMG/Texture_200/Atlas/LobbyUI/Frames/Common_Tab_Local_png.Common_Tab_Local_png"
  },
  Wow = {
    Selected = "/Game/UMG/Texture_200/Atlas/LobbyUI/Frames/Common_Tab_WowFriend_Selected_png.Common_Tab_WowFriend_Selected_png",
    UnSelect = "/Game/UMG/Texture_200/Atlas/LobbyUI/Frames/Common_Tab_WowFriend_png.Common_Tab_WowFriend_png"
  },
  Team = {
    Selected = "/Game/UMG/Texture_200/Atlas/LobbyUI/Frames/Common_Tab_TeamQuick01_png.Common_Tab_TeamQuick01_png",
    UnSelect = "/Game/UMG/Texture_200/Atlas/LobbyUI/Frames/Common_Icon_TeamQuick_png.Common_Icon_TeamQuick_png"
  }
}
friend_list_macros.Friend_MaxBatchDelCount = 50
friend_list_macros.Friend_MaxBatchTopCount = 100
return friend_list_macros