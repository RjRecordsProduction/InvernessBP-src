local Logic_SocialLobbyConst = {}
Logic_SocialLobbyConst.DEFAULT_SKIN_ITEM_ID = 6680101
Logic_SocialLobbyConst.DEFAULT_MONUMENT_ITEM_ID = 6680702
Logic_SocialLobbyConst.HIGH_LEVEL_MONUMENT_ITEM_ID = 6680701
Logic_SocialLobbyConst.DEFAULT_BG_WALL_ITEM_ID = 6680200
Logic_SocialLobbyConst.DEFAULT_SCENE_NAME = "Lobby_Social_CH_Mesh"
Logic_SocialLobbyConst.DEFAULT_BG_WALL_ACTOR_TAG = "StaticMeshActor"
Logic_SocialLobbyConst.SOCIAL_LOBBY_EDITOR_CAMERA_ID = 10156
Logic_SocialLobbyConst.SOCIAL_LOBBY_SHOW_CAMERA_ID = 10151
Logic_SocialLobbyConst.SOCIAL_LOBBY_TOP_VIEW_CAMERA_ID = 10157
Logic_SocialLobbyConst.SOCIAL_LOBBY_SKIN_SLOT_INDEX_START = 1001
Logic_SocialLobbyConst.SOCIAL_LOBBY_SLOT_SELECT_OUTLINE_COLOR = FLinearColor(1, 0.527, 0.0185, 1)
Logic_SocialLobbyConst.SOCIAL_LOBBY_SLOT_SELECT_OUTLINE_WIDTH = 1.5
Logic_SocialLobbyConst.WEAPON_LIST_TOUCH_SLIDE_DIS = 5
Logic_SocialLobbyConst.SOCIAL_LOBBY_DATA_INDEX = 2
Logic_SocialLobbyConst.SOCIAL_PET_SLOT_SHOW_MAX_COUNT = 1
Logic_SocialLobbyConst.SOCIAL_BG_WALL_SLOT_SHOW_MAX_COUNT = 1
Logic_SocialLobbyConst.SOCIAL_AVATAR_SHOW_SLOT_SHOW_MAX_COUNT = 3
Logic_SocialLobbyConst.COLLECT_MILESTONE_DETAIL_FORM_SOCIAL_LOBBY = "formSocialLobby"
Logic_SocialLobbyConst.COLLECTION_MOD_PAK_NAME = "map_planch"
Logic_SocialLobbyConst.Enum_DataReqSource = {SocialLobby = 1, CollectionHall = 2}
local Enum_SocialLobbySlotType = {
  Achievement = 0,
  AvatarShow = 1,
  Vehicle = 2,
  Weapon = 3,
  Pet = 4,
  BGWall = 100
}
Logic_SocialLobbyConst.local Enum_SLActorType = {
  AvatarShowSlot3DUI = Enum_SocialLobbySlotType.AvatarShow,
  VehicleSlot3DUI = Enum_SocialLobbySlotType.Vehicle,
  WeaponSlot3DUI = Enum_SocialLobbySlotType.Weapon,
  PetSlot3DUI = Enum_SocialLobbySlotType.Pet,
  BGPanel3DUI = Enum_SocialLobbySlotType.BGWall,
  CombatInfo3DUI = 1000,
  Souvenirs3DUI = 1001,
  VersionAlbum3DUI = 1002,
  CollectSysInfo3DUI = 1003,
  CollectHallEnter = 1004,
  CollectSysMileage = 1005,
  DisplayMonumentModel = 1006
}
Logic_SocialLobbyConst.Logic_SocialLobbyConst.Enum_LevelUnlockSlotCfgKey = {
  [Enum_SocialLobbySlotType.Achievement] = "AchievementMedalFreeSlotCount",
  [Enum_SocialLobbySlotType.AvatarShow] = "MixHallFreeAvatarSlotCount",
  [Enum_SocialLobbySlotType.Vehicle] = "MixHallFreeVehicleSlotCount",
  [Enum_SocialLobbySlotType.Weapon] = "MixHallFreeWeaponSlotCount",
  [Enum_SocialLobbySlotType.Pet] = "MixHallFreePetSlotCount"
}
Logic_SocialLobbyConst.Enum_SkinUnlockSlotCfgKey = {
  [Enum_SocialLobbySlotType.AvatarShow] = "MixHallExtraAvatarSlotCount",
  [Enum_SocialLobbySlotType.Vehicle] = "MixHallExtraVehicleSlotCount",
  [Enum_SocialLobbySlotType.Weapon] = "MixHallExtraWeaponSlotCount",
  [Enum_SocialLobbySlotType.Pet] = "MixHallExtraPetSlotCount"
}
Logic_SocialLobbyConst.Enum_AchievementSlotEditSubTab = {Achievement = 1, Alias = 2}
Logic_SocialLobbyConst.Enum_WeaponListPage = {Page_1 = 1, Page_2 = 2}
return Logic_SocialLobbyConst