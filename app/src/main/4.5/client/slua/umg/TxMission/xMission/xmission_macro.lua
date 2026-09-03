local xmission_macro = {
  DismantleChestID = 3001069,
  DismantleChestAccTicket = 3001070,
  AffixChangeItemID = 3001130,
  AffixEnhanceItemID = 1000074,
  REPAIR_THRESHOLD = 20,
  TLobbySceneID = 10099,
  TeamCompetitionMapID = 701,
  ENUM_WardrobePage = {
    ENUM_WardrobePage_All = 0,
    ENUM_WardrobePage_Weapon = 1,
    ENUM_WardrobePage_Part = 2,
    ENUM_WardrobePage_Bullet = 3,
    ENUM_WardrobePage_Armor = 4,
    ENUM_WardrobePage_Tool = 5
  },
  Enum_Type = {
    EnumType_Main_Weapon = 1,
    EnumType_Pistol = 2,
    EnumType_Knife = 3,
    EnumType_Helmet = 4,
    EnumType_Armor = 5,
    EnumType_Part = 6,
    EnumType_Bag = 7,
    EnumType_Other = 8,
    EnumType_Chest = 13,
    EnumType_RedPacket = 19,
    EnumType_Souvenirs = 888
  },
  Enum_Sub_Type = {
    EnumType_Sub_Rifle = 1001,
    EnumType_Sub_Submachine = 1002,
    EnumType_Sub_Pistol = 2001,
    EnumType_Sub_Knife = 3001,
    EnumType_Sub_Pan = 3002,
    EnumType_Sub_Stick = 3003,
    EnumType_Sub_Heirloom = 3881,
    EnumType_Sub_Helmet = 4001,
    EnumType_Sub_Armor = 5001,
    EnumType_Sub_Grip = 6001,
    EnumType_Sub_Sight = 6002,
    EnumType_Sub_Magnification = 6003,
    EnumType_Sub_Bag = 7001,
    EnumType_Sub_Bullet = 8001,
    EnumType_Sub_Drug = 8002,
    EnumType_Sub_Souvenirs_Drop = 8003,
    EnumType_Sub_ThrowObject = 8004,
    EnumType_Sub_PasswordLetter = 8005,
    EnumType_Sub_ResearchChest = 8010,
    EnumType_Sub_Identification = 8011,
    EnumType_Sub_UseItem = 8099,
    EnumType_Sub_Option_Chest = 13002
  },
  Enum_Slot = {
    EnumSlot_Main_Weapon_1 = 1,
    EnumSlot_Main_Weapon_2 = 2,
    EnumSlot_Pistol = 3,
    EnumSlot_Knife = 4,
    EnumSlot_Helmet = 5,
    EnumSlot_Armor = 6,
    EnumSlot_Bag = 7
  },
  Enum_Dst_Desc = {
    EnumDst_Depot = "depot",
    EnumDst_Bag = "bag",
    EnumDst_Slot = "slot",
    EnumDst_PartSlot = "part_slot",
    EnumDst_SafeBag = "safe_bag"
  },
  ENUM_TIPS_TYPE = {
    ENUM_TIPS_TYPE_OTHER = 1,
    ENUM_TIPS_TYPE_WEAPON = 2,
    ENUM_TIPS_TYPE_ARMOR = 3,
    ENUM_TIPS_TYPE_BAG = 4
  },
  ENUM_TIPS_OPEN_TYPE = {FROM_WARDROBE = 1, FROM_PREPARE = 2},
  ENUM_WARDROBE_SORT_TYPE = {
    SORT_BY_DEFAULT = 1,
    SORT_BY_PREPARE_CONFIG = 2,
    SORT_BY_CAN_INTO_BAG = 3,
    SORT_BY_PREPARE_SLOT_ID = 4,
    SORT_BY_WEAPON_SLOT_INDEX = 5
  },
  ENUM_MODE_TYPE = {
    BASE = 1,
    ADVANCED = 2,
    UNDERCOVER = 3,
    ASSAULT = 4,
    VS_STANDARD = 5,
    VS_FREE = 6
  },
  ENUM_OPERATION_STATE_TYPE = {
    EnumType_Empty = 1,
    EnumType_Busy = 2,
    EnumType_Available = 3,
    EnumType_Nothing = 4
  },
  ENUM_SELECT_UI_TYPE = {
    EnumType_PutIn = 1,
    EnumType_PutOff = 2,
    EnumType_Sell = 3,
    EnumType_OpenChest = 4
  },
  ENUM_TLOBBY_ENTRY_CLICK_TYPE = {
    EnumType_Souvenirs = 1,
    EnumType_RP = 2,
    EnumType_Task = 3,
    EnumType_Activity = 4,
    EnumType_Treasure = 5
  },
  ENUM_PRESET_GUIDE_STEP_TYPE = {
    EnumType_Click_Entry = 1,
    EnumType_Click_Edit = 2,
    EnumType_Drag_Item = 3,
    EnumType_Save_Plan = 4,
    EnumType_Set_Default = 5,
    EnumType_Supply_Plan = 6
  },
  ENUM_OPERATION_TAB_TYPE = {
    EnumType_Dismantling = 1,
    EnumType_Enhance = 2,
    EnumType_MakeAffixs = 3
  },
  ENUM_MAKE_AFFIX_TYPE = {EnumType_BUILD = 1, EnumType_REFINE = 2},
  ENUM_AFFIX_OPERATION_TYPE = {
    EnumType_Sell = 1,
    EnumType_Decompose = 2,
    EnumType_MaxLevel = 3
  },
  ENum_BuySourceType = {
    BlackMarket = 1,
    BlackMarketMystical = 2,
    BattleBlackMarket = 3,
    BlackMarketPack = 4
  }
}
return xmission_macro