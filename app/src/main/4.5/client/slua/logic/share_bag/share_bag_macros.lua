local ENUM_ShareItemType = {
  AvatarItem = 1,
  Pet = 2,
  Weapon = 3
}
local ENUM_ShareType = {
  Subscribe = 1,
  Collection = 2,
  Pet = 3,
  Weapon = 4
}
local ShareItemType2ShareTypeMap = {
  [ENUM_ShareItemType.AvatarItem] = {
    ENUM_ShareType.Subscribe,
    ENUM_ShareType.Collection
  },
  [ENUM_ShareItemType.Pet] = {
    ENUM_ShareType.Pet
  },
  [ENUM_ShareItemType.Weapon] = {
    ENUM_ShareType.Weapon
  }
}
local ShareType2ShareItemTypeMap = {
  [ENUM_ShareType.Subscribe] = ENUM_ShareItemType.AvatarItem,
  [ENUM_ShareType.Collection] = ENUM_ShareItemType.AvatarItem,
  [ENUM_ShareType.Pet] = ENUM_ShareItemType.Pet,
  [ENUM_ShareType.Weapon] = ENUM_ShareItemType.Weapon
}
local share_bag_macros = {
  ENUM_ShareItemType = ENUM_ShareItemType,
  ENUM_ShareType = ENUM_ShareType,
  ShareItemType2ShareTypeMap = ShareItemType2ShareTypeMap,
  ShareType2ShareItemTypeMap = ShareType2ShareItemTypeMap,
  ShareTypeCount = 4,
  MAX_ITEM_COUNT_PER_SHARE_TYPE = 10,
  ShareTabConfig = {
    {
      tabType = ENUM_ShareItemType.AvatarItem,
      activePath = "/Game/UMG/Texture_200/Atlas/Lobby_Store/Frames/Common_Tab_Fushi_7_xuangzhong_png.Common_Tab_Fushi_7_xuangzhong_png",
      inactivePath = "/Game/UMG/Texture_200/Atlas/Lobby_Store/Frames/Common_Tab_Fushi_7_png.Common_Tab_Fushi_7_png"
    },
    {
      tabType = ENUM_ShareItemType.Pet,
      activePath = "/Game/UMG/Texture_200/Atlas/Lobby_Store/Frames/Common_Tab_Pet_xuangzhong_png.Common_Tab_Pet_xuangzhong_png",
      inactivePath = "/Game/UMG/Texture_200/Atlas/Lobby_Store/Frames/Common_Tab_Pet_png.Common_Tab_Pet_png"
    },
    {
      tabType = ENUM_ShareItemType.Weapon,
      activePath = "/Game/UMG/Texture_200/Atlas/Lobby_Store/Frames/Common_Tab_Pistol_xuangzhong2_png.Common_Tab_Pistol_xuangzhong2_png",
      inactivePath = "/Game/UMG/Texture_200/Atlas/Lobby_Store/Frames/Common_Tab_Pistol_png.Common_Tab_Pistol_png"
    }
  },
  PET_SHARE_PRIVILEGE_ITEM_ID = 619100001,
  WEAPON_SHARE_PRIVILEGE_ITEM_ID = 619110001
}
return share_bag_macros