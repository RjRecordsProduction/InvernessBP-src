local UGC_Inventory = {}
UGC_Inventory.DataNameList = {
  Dress_HomePageConfig = "Dress_HomePageConfig",
  Dress_UpInRoomNotice = "Dress_UpInRoomNotice",
  Dress_MatchRoom = "Dress_MatchRoom",
  Dress_PlayerComment = "Dress_PlayerComment",
  Cascade_Kill = "Cascade_Kill",
  Cascade_Revive = "Cascade_Revive"
}
local config_InventoryList = {
  keyName = "InventoryList",
  isSingleton = false,
  isMainUI = false
}
UGC_Inventory.InventoryList = {
  [1] = {
    TabID = 303,
    NormalIcon = "/Game/UMG/Texture_200/Atlas/CreativeMode/Frames/Common_Tab_SpecialEffects_png.Common_Tab_SpecialEffects_png",
    SelectIcon = "/Game/UMG/Texture_200/Atlas/CreativeMode/Frames/Common_Tab_SpecialEffects_Select_png.Common_Tab_SpecialEffects_Select_png",
    [1] = {
      SubTabID = 30301,
      NormalIcon = "/Game/UMG/Texture_200/Atlas/CreativeMode/Frames/Common_Tab_KillSpecialEffects_png.Common_Tab_KillSpecialEffects_png",
      SelectIcon = "/Game/UMG/Texture_200/Atlas/CreativeMode/Frames/Common_Tab_KillSpecialEffects_Select_png.Common_Tab_KillSpecialEffects_Select_png",
      moduleName = "client.slua.umg.ugc.lobby.UGCInventory.UGC_KillEffect_UIBP",
      path = "/Game/UMG/UI_BP/UGC/Store/UGC_KillEffect_UIBP.UGC_KillEffect_UIBP",
      DataName = UGC_Inventory.DataNameList.Cascade_Kill,
      config = config_InventoryList
    },
    [2] = {
      SubTabID = 30302,
      NormalIcon = "/Game/UMG/Texture_200/Atlas/CreativeMode/Frames/Common_Tab_ResurrectionCountdown_png.Common_Tab_ResurrectionCountdown_png",
      SelectIcon = "/Game/UMG/Texture_200/Atlas/CreativeMode/Frames/Common_Tab_ResurrectionCountdown_Select_png.Common_Tab_ResurrectionCountdown_Select_png",
      moduleName = "client.slua.umg.ugc.lobby.UGCInventory.UGC_ReviveEffect_UIBP",
      path = "/Game/UMG/UI_BP/UGC/Store/UGC_KillEffect_UIBP.UGC_KillEffect_UIBP",
      DataName = UGC_Inventory.DataNameList.Cascade_Revive,
      config = config_InventoryList
    }
  },
  [2] = {
    TabID = 301,
    NormalIcon = "/Game/UMG/Texture_200/Atlas/CreativeMode/Frames/Common_Tab_DressUp_png.Common_Tab_DressUp_png",
    SelectIcon = "/Game/UMG/Texture_200/Atlas/CreativeMode/Frames/Common_Tab_DressUp_Select_png.Common_Tab_DressUp_Select_png",
    [1] = {
      SubTabID = 30101,
      NormalIcon = "/Game/UMG/Texture_200/Atlas/CreativeMode/Frames/Common_Tab_HomePageDressUp_png.Common_Tab_HomePageDressUp_png",
      SelectIcon = "/Game/UMG/Texture_200/Atlas/CreativeMode/Frames/Common_Tab_HomePageDressUp_Select_png.Common_Tab_HomePageDressUp_Select_png",
      moduleName = "client.slua.umg.ugc.lobby.UGCInventory.UGC_InformationCard_UIBP",
      path = "/Game/UMG/UI_BP/UGC/Store/UGC_InformationCard_UIBP.UGC_InformationCard_UIBP",
      DataName = UGC_Inventory.DataNameList.Dress_HomePageConfig,
      config = config_InventoryList
    },
    [2] = {
      SubTabID = 30102,
      NormalIcon = "/Game/UMG/Texture_200/Atlas/CreativeMode/Frames/Common_Tab_EnterTips_png.Common_Tab_EnterTips_png",
      SelectIcon = "/Game/UMG/Texture_200/Atlas/CreativeMode/Frames/Common_Tab_EnterTips_Select_png.Common_Tab_EnterTips_Select_png",
      moduleName = "client.slua.umg.ugc.lobby.UGCInventory.UGC_UpInRoomNotice_UIBP",
      path = "/Game/UMG/UI_BP/UGC/Store/UGC_InformationCard_UIBP.UGC_InformationCard_UIBP",
      DataName = UGC_Inventory.DataNameList.Dress_UpInRoomNotice,
      config = config_InventoryList
    }
  }
}
UGC_Inventory.UpInRoomTypeUIList = {
  LobbyMain = 1,
  TeamPlay = 2,
  RoomTeam = 3
}
return UGC_Inventory