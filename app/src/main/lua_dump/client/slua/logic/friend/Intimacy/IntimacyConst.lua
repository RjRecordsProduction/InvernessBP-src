local IntimacyConst = {
  EStateType = {
    None = 0,
    Has_Send = 1,
    Wait_Confirm = 2,
    Has_Delete = 3,
    Has_Build = 4
  },
  EIntimacyType = {
    None = 0,
    Bromance = 1,
    Lover = 2,
    Buddy = 3,
    BFF = 4,
    Family = 5,
    Bonding = 6,
    Max = 6
  },
  EShowMode = {
    Apply = 1,
    Accept = 2,
    ChangeApply = 3,
    ChangeAccept = 4,
    Display = 5
  },
  C_IntimacyMaxCount = {
    [1] = 6,
    [2] = 1,
    [3] = 6,
    [4] = 6,
    [5] = 6,
    [6] = 1
  },
  C_IntimacyTypeIcon = {
    [1] = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/PersonSpace_icon_GayFriend_png.PersonSpace_icon_GayFriend_png",
    [2] = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/PersonSpace_icon_lover_png.PersonSpace_icon_lover_png",
    [3] = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/PersonSpace_icon_Partner_png.PersonSpace_icon_Partner_png",
    [4] = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/PersonSpace_icon_BestFriend_png.PersonSpace_icon_BestFriend_png",
    [5] = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/PersonSpace_Icon_Family_png.PersonSpace_Icon_Family_png",
    [6] = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/PersonSpace_icon_FatefulConnection_png.PersonSpace_icon_FatefulConnection_png"
  },
  C_IntimacyTypeSmallIcon = {
    [1] = "/Game/UMG/Texture_200/Lobby_NoAtlas/LobbyPlayerInfoUI/PersonSpace_Icon_GayFriend_32.PersonSpace_Icon_GayFriend_32",
    [2] = "/Game/UMG/Texture_200/Lobby_NoAtlas/LobbyPlayerInfoUI/PersonSpace_Icon_lover_32.PersonSpace_Icon_lover_32",
    [3] = "/Game/UMG/Texture_200/Lobby_NoAtlas/LobbyPlayerInfoUI/PersonSpace_Icon_Partner_32.PersonSpace_Icon_Partner_32",
    [4] = "/Game/UMG/Texture_200/Lobby_NoAtlas/LobbyPlayerInfoUI/PersonSpace_Icon_BestFriend_32.PersonSpace_Icon_BestFriend_32",
    [5] = "/Game/UMG/Texture_200/Lobby_NoAtlas/LobbyPlayerInfoUI/PersonSpace_Icon_Family_32.PersonSpace_Icon_Family_32",
    [6] = "/Game/UMG/Texture_200/Lobby_NoAtlas/LobbyPlayerInfoUI/PersonSpace_Icon_FatefulConnection_32.PersonSpace_Icon_FatefulConnection_32"
  },
  C_IntimacyRelationText = {
    [1] = 33146,
    [2] = 33145,
    [3] = 33147,
    [4] = 33148,
    [5] = 73243,
    [6] = 8075861
  },
  C_IntimacyRelationRichText = {
    [1] = 35055,
    [2] = 35057,
    [3] = 35056,
    [4] = 35054,
    [5] = 73282,
    [6] = 82951
  },
  C_IntimacyRelationTextColor = {
    [1] = FLinearColor(0.059511, 0.502887, 1, 1),
    [2] = FLinearColor(0.83077, 0.238398, 0.337164, 1),
    [3] = FLinearColor(0.863157, 0.450786, 0.021219, 1),
    [4] = FLinearColor(0.610496, 0.076185, 0.514918, 1),
    [5] = FLinearColor(0.894118, 0.262745, 0.145098, 1),
    [6] = FLinearColor(0.83077, 0.238398, 0.337164, 1)
  },
  C_InviteBeText = {
    [1] = 18881,
    [2] = 18883,
    [3] = 18882,
    [4] = 18880,
    [5] = 73287,
    [6] = 8075892
  },
  C_MaleIconPath = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Boy_png.Common_Icon_Boy_png",
  C_FemaleIconPath = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Girl_png.Common_Icon_Girl_png",
  C_LongPressFingerprintTotalDuration = 3000,
  C_NewbieGuideKey = {INTIMACY_HEART_FIRST_SHOW = 1, INTIMACY_BOOK_FIRST_SHOW = 2},
  C_SoulmateTipsShowSeconds = 10,
  C_SoulmateTipsInterval = 12
}
return IntimacyConst