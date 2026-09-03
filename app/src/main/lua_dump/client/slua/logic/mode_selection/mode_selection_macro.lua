local mode_selection_macro = {
  C_New_Icon_Path = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Image_NEW_png.Common_Image_NEW_png",
  C_Beta_Icon_Path = "/Game/UMG/Texture/Atlas/Common_Atlas/Frames/T_icon_BETA_png.T_icon_BETA_png",
  C_Multi_BigBg_Path = {
    Classic = "/Game/UMG/Texture/Lobby_NoAtlas/Lobby_Match_SelectMap/ModeSelection_New/MapEntrance/Big/Lobby_match_MapEntrance_Suijijingdian.Lobby_match_MapEntrance_Suijijingdian",
    Arena = "/Game/UMG/Texture/Lobby_NoAtlas/Lobby_Match_SelectMap/ModeSelection_New/MapEntrance/Big/Lobby_match_MapEntrance_Suijituanjing.Lobby_match_MapEntrance_Suijituanjing"
  },
  C_Multi_SmallBg_Path = {
    Classic = "/Game/UMG/Texture/Lobby_NoAtlas/Lobby_Match_SelectMap/ModeSelection_New/MapEntrance/Small/Lobby_match_MapEntrance_Suijijingdian.Lobby_match_MapEntrance_Suijijingdian",
    Arena = "/Game/UMG/Texture/Lobby_NoAtlas/Lobby_Match_SelectMap/ModeSelection_New/MapEntrance/Small/Lobby_match_MapEntrance_Suijituanjing.Lobby_match_MapEntrance_Suijituanjing"
  },
  C_SelectMapMinNum = {Classic = 1, Arena = 1},
  C_SelectPerspective_Icon_Path = {
    Not = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Btn_Lv2_Huise_png.Common_Btn_Lv2_Huise_png",
    Selected = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Btn_Lv2_Lanse_png.Common_Btn_Lv2_Lanse_png"
  },
  C_Multi_Arena_BigBg_Sp_Path = "/Game/UMG/Texture/Lobby_NoAtlas/Lobby_Match_SelectMap/ModeSelection_New/MapEntrance/Big/Lobby_match_MapEntrance_059.Lobby_match_MapEntrance_059",
  C_Multi_Arena_SmallBg_Sp_Path = "/Game/UMG/Texture/Lobby_NoAtlas/Lobby_Match_SelectMap/ModeSelection_New/MapEntrance/Small/Lobby_match_MapEntrance_S059.Lobby_match_MapEntrance_S059",
  C_Multi_Arena_Sp_View_List = {12107, 12105},
  C_Xmission_ViewID = 20000,
  C_XmissionNewTips_MaxCount = 2,
  E_UITYPE = {
    TEXT = 1,
    SINGLEIMAGE = 2,
    DOUBLEIMAGE = 3,
    TRIPLEIMAGE = 4,
    VIDEO = 5,
    H5 = 6,
    GAMEGUIDE = 7
  }
}
local Enum_TabID = {
  RankClassic = 100,
  RankClassicMode = 110,
  RankPeakGameMode = 120,
  MatchAlpha = 200,
  MatchClassic = 210,
  MatchArena = 220,
  Other = 230,
  MatchNewbie = 240,
  MatchTxMission = 260,
  MatchAsymmetricMode = 270,
  UGC = 900
}
mode_selection_macro.local Enum_Menu_Type = {
  View = 1,
  MultiLevel = 2,
  Single = 3
}
mode_selection_macro.local Enum_Newbie_Guide_Step_Key = {STEP_THEME_RANK = 1}
mode_selection_macro.local TeamNumIcon_Path_Config = {
  [1] = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Person_1_png.Common_Icon_Person_1_png",
  [2] = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Person_2_png.Common_Icon_Person_2_png",
  [4] = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Person_4_png.Common_Icon_Person_4_png",
  [8] = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Person_8_png.Common_Icon_Person_8_png"
}
mode_selection_macro.local Enum_Group_Type = {
  Theme = "theme",
  Group = "group",
  Multi = "multi"
}
mode_selection_macro.local Enum_Lock_State = {
  Not = 1,
  Level = 2,
  Time = 3,
  Person = 4,
  TeamNum = 5
}
mode_selection_macro.mode_selection_macro.jumpUrlViewId = nil
local jumpMenuConfig = {
  [100] = "100",
  [210] = "210|200",
  [220] = "220|200",
  [230] = "230|200"
}
mode_selection_macro.mode_selection_macro.scrollViewId = nil
mode_selection_macro.newbieViewType = {
  Invalid = 0,
  Video_Training = 1,
  Level_Training_Standalone = 2,
  Level_Training = 3
}
mode_selection_macro.newbieAwardStatus = {
  CAN_NOT_GET = 0,
  CAN_GET = 1,
  HAVE_GOT = 2
}
mode_selection_macro.curHomeRedDot = nil
mode_selection_macro.curHomePKRedDot = nil
mode_selection_macro.curHomeDetailRedDot = nil
return mode_selection_macro