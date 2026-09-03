local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
local macroTabString = wardrobe_macro.ENUM_WardrobeSubTabString
local Avatar = wardrobe_macro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Avatar
local Weapon = wardrobe_macro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Weapon
local Vehicle = wardrobe_macro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Vehicle
local Parachute = wardrobe_macro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Parachute
local Tool = wardrobe_macro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Tool
local Appearance = wardrobe_macro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Appearance
local Wardrobe_Config = {
  PageTab_Config = {
    {
      pageId = Avatar,
      activePath = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Shizhuang_xuangzhong_png.Common_Tab_Shizhuang_xuangzhong_png",
      inactivePath = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_shizhuang_png.Common_Tab_shizhuang_png",
      bpPath = "/Game/UMG/UI_BP/Wardrobe/Wardrobe_PageTab_UIBP.Wardrobe_PageTab_UIBP",
      defaultSelected = true
    },
    {
      pageId = Weapon,
      activePath = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Pistol_xuanzhong_png.Common_Tab_Pistol_xuanzhong_png",
      inactivePath = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Pistol_png.Common_Tab_Pistol_png",
      bpPath = "/Game/UMG/UI_BP/Wardrobe/Wardrobe_PageTab_UIBP.Wardrobe_PageTab_UIBP",
      onPageClick = {
        onClickBP = "/Game/UMG/UI_BP/Wardrobe/VerticalBox_Wardrobe_Gun_UIBP.VerticalBox_Wardrobe_Gun_UIBP",
        onClickModuleName = "client.slua.umg.Wardrobe.subtab_gun",
        onClickAttachPoint = "Common_PlaceHolder"
      },
      uiStat_name = "\228\187\147\229\186\147-\230\158\170\230\162\176"
    },
    {
      pageId = Vehicle,
      activePath = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Zaiju_xuanzhong_png.Common_Tab_Zaiju_xuanzhong_png",
      inactivePath = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Zaiju_png.Common_Tab_Zaiju_png",
      bpPath = "/Game/UMG/UI_BP/Wardrobe/Wardrobe_PageTab_UIBP.Wardrobe_PageTab_UIBP",
      onPageClick = {
        onClickBP = "/Game/UMG/UI_BP/Wardrobe/VerticalBox_Wardrobe_Gun_UIBP.VerticalBox_Wardrobe_Gun_UIBP",
        onClickModuleName = "client.slua.umg.Wardrobe.subtab_vehicles",
        onClickAttachPoint = "Common_PlaceHolder"
      },
      uiStat_name = "\228\187\147\229\186\147-\232\189\189\229\133\183"
    },
    {
      pageId = Parachute,
      activePath = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Zhanbei_xuangzhong1_png.Common_Tab_Zhanbei_xuangzhong1_png",
      inactivePath = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Zhanbei1_png.Common_Tab_Zhanbei1_png",
      bpPath = "/Game/UMG/UI_BP/Wardrobe/Wardrobe_PageTab_UIBP.Wardrobe_PageTab_UIBP"
    },
    {
      pageId = Tool,
      activePath = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Daoju_Xuanzhong_png.Common_Tab_Daoju_Xuanzhong_png",
      inactivePath = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Daoju_png.Common_Tab_Daoju_png",
      bpPath = "/Game/UMG/UI_BP/Wardrobe/Wardrobe_PageTab_UIBP.Wardrobe_PageTab_UIBP"
    },
    {
      pageId = Appearance,
      activePath = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Gender_xuangzhong_png.Common_Tab_Gender_xuangzhong_png",
      inactivePath = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Gender_png.Common_Tab_Gender_png",
      bpPath = "/Game/UMG/UI_BP/Wardrobe/Wardrobe_PageTab_UIBP.Wardrobe_PageTab_UIBP"
    }
  },
  SubTab_Config = {}
}
Wardrobe_Config.SubTab_Config[Avatar] = {
  subTabBP = "/Game/UMG/UI_BP/Wardrobe/WardrobeSubTab_UIBP.WardrobeSubTab_UIBP",
  subTabModuleName = "client.slua.umg.Wardrobe.sub_tab",
  hideTagFilter = false,
  subTabOnClick = {
    onClickBP = "/Game/UMG/UI_BP/Wardrobe/HorizontalBox_Wardrobe_Clothes_UIBP.HorizontalBox_Wardrobe_Clothes_UIBP",
    onClickModuleName = "client.slua.umg.Wardrobe.subtab_avatar",
    onClickAttachPoint = "Common_PlaceHolder"
  },
  subTabs = {
    {
      subTabID = macroTabString.ENUM_WardrobeSubTabString_suit,
      ItemSubTypeIDs = {403},
      subTabIconNormal = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Fushi_7_png.Common_Tab_Fushi_7_png",
      subTabIconSelect = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Fushi_7_xuangzhong_png.Common_Tab_Fushi_7_xuangzhong_png",
      onClickBP = "/Game/UMG/UI_BP/Wardrobe/HorizontalBox_Wardrobe_Suit_UIBP_2.HorizontalBox_Wardrobe_Suit_UIBP_2",
      onClickModuleName = "client.slua.umg.Wardrobe.subtab_suit",
      defaultSelected = true,
      defaultSelectedInEditMode = true,
      bRefreshIconOnEditMode = true
    },
    {
      subTabID = macroTabString.ENUM_WardrobeSubTabString_helmet,
      ItemSubTypeIDs = {502, 505},
      subTabIconNormal = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Toukui_png.Common_Tab_Toukui_png",
      subTabIconSelect = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Toukui_xuangzhong_png.Common_Tab_Toukui_xuangzhong_png",
      onClickBP = "/Game/UMG/UI_BP/Wardrobe/HorizontalBox_Wardrobe_Helmet_UIBP.HorizontalBox_Wardrobe_Helmet_UIBP",
      onClickModuleName = "client.slua.umg.Wardrobe.subtab_helmet",
      bRefreshIconOnEditMode = true
    },
    {
      subTabID = macroTabString.ENUM_WardrobeSubTabString_head,
      ItemSubTypeIDs = {
        ENUM_ITEM_SUBTYPE.Head_Slot_400,
        ENUM_ITEM_SUBTYPE.Hat_Slot,
        ENUM_ITEM_SUBTYPE.Hair_Slot
      },
      subTabIconNormal = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Zhuangbeitubiao_2_png.Common_Tab_Zhuangbeitubiao_2_png",
      subTabIconSelect = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Zhuangbeitubiao_2_xuangzhong_png.Common_Tab_Zhuangbeitubiao_2_xuangzhong_png",
      bRefreshIconOnEditMode = true
    },
    {
      subTabID = macroTabString.ENUM_WardrobeSubTabString_glasses,
      ItemSubTypeIDs = {
        ENUM_ITEM_SUBTYPE.Eye_Slot
      },
      subTabIconNormal = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Zhuangbeitubiao_13_png.Common_Tab_Zhuangbeitubiao_13_png",
      subTabIconSelect = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Zhuangbeitubiao_13_xuangzhong_png.Common_Tab_Zhuangbeitubiao_13_xuangzhong_png",
      bRefreshIconOnEditMode = true
    },
    {
      subTabID = macroTabString.ENUM_WardrobeSubTabString_face,
      ItemSubTypeIDs = {
        ENUM_ITEM_SUBTYPE.Mask_Slot
      },
      subTabIconNormal = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Zhuangbeitubiao_3_png.Common_Tab_Zhuangbeitubiao_3_png",
      subTabIconSelect = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Zhuangbeitubiao_3_xuangzhong_png.Common_Tab_Zhuangbeitubiao_3_xuangzhong_png",
      bRefreshIconOnEditMode = true
    },
    {
      subTabID = macroTabString.ENUM_WardrobeSubTabString_clothes,
      ItemSubTypeIDs = {
        ENUM_ITEM_SUBTYPE.Package_Slot
      },
      subTabIconNormal = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Zhuangbeitubiao_4_png.Common_Tab_Zhuangbeitubiao_4_png",
      subTabIconSelect = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Zhuangbeitubiao_4_xuangzhong_png.Common_Tab_Zhuangbeitubiao_4_xuangzhong_png",
      bRefreshIconOnEditMode = true
    },
    {
      subTabID = macroTabString.ENUM_WardrobeSubTabString_bag,
      ItemSubTypeIDs = {
        ENUM_ITEM_SUBTYPE.Upgrade_Backpack,
        ENUM_ITEM_SUBTYPE.Backpack
      },
      subTabIconNormal = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Beibao_png.Common_Tab_Beibao_png",
      subTabIconSelect = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Beibao_xuangzhong_png.Common_Tab_Beibao_xuangzhong_png",
      onClickBP = "/Game/UMG/UI_BP/Wardrobe/HorizontalBox_Wardrobe_Bag_UIBP.HorizontalBox_Wardrobe_Bag_UIBP",
      onClickModuleName = "client.slua.umg.Wardrobe.subtab_bag",
      bRefreshIconOnEditMode = true
    },
    {
      subTabID = macroTabString.ENUM_WardrobeSubTabString_trousers,
      ItemSubTypeIDs = {
        ENUM_ITEM_SUBTYPE.Pants_Slot
      },
      subTabIconNormal = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Zhuangbeitubiao_5_png.Common_Tab_Zhuangbeitubiao_5_png",
      subTabIconSelect = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Zhuangbeitubiao_5_xuangzhong_png.Common_Tab_Zhuangbeitubiao_5_xuangzhong_png",
      bRefreshIconOnEditMode = true
    },
    {
      subTabID = macroTabString.ENUM_WardrobeSubTabString_shoes,
      ItemSubTypeIDs = {
        ENUM_ITEM_SUBTYPE.Shoes_Slot
      },
      subTabIconNormal = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Zhuangbeitubiao_6_png.Common_Tab_Zhuangbeitubiao_6_png",
      subTabIconSelect = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Zhuangbeitubiao_6_xuangzhong_png.Common_Tab_Zhuangbeitubiao_6_xuangzhong_png",
      bRefreshIconOnEditMode = true
    },
    {
      subTabID = macroTabString.ENUM_WardrobeSubTabString_gloves,
      ItemSubTypeIDs = {
        ENUM_ITEM_SUBTYPE.Gloves
      },
      subTabIconNormal = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Zhuangbeitubiao_14_png.Common_Tab_Zhuangbeitubiao_14_png",
      subTabIconSelect = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Zhuangbeitubiao_14_xuangzhong_png.Common_Tab_Zhuangbeitubiao_14_xuangzhong_png",
      onClickModuleName = "client.slua.umg.Wardrobe.subtab_gloves",
      bRefreshIconOnEditMode = true
    }
  }
}
Wardrobe_Config.SubTab_Config[Weapon] = {
  subTabs = {}
}
Wardrobe_Config.SubTab_Config[Parachute] = {
  subTabBP = "/Game/UMG/UI_BP/Wardrobe/WardrobeSubTab_UIBP.WardrobeSubTab_UIBP",
  subTabModuleName = "client.slua.umg.Wardrobe.sub_tab",
  hideTagFilter = false,
  subTabOnClick = {
    onClickBP = "/Game/UMG/UI_BP/Wardrobe/HorizontalBox_Wardrobe_Props_UIBP.HorizontalBox_Wardrobe_Props_UIBP",
    onClickAttachPoint = "Common_PlaceHolder"
  },
  subTabs = {
    {
      subTabID = macroTabString.ENUM_WardrobeSubTabString_emoj,
      subTabIconNormal = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Biaoqing_png.Common_Tab_Biaoqing_png",
      subTabIconSelect = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Biaoqing_xuangzhong_png.Common_Tab_Biaoqing_xuangzhong_png",
      onClickModuleName = "client.slua.umg.Wardrobe.subtab_action",
      defaultSelected = true,
      onClickBP = "/Game/UMG/UI_BP/Wardrobe/Expression_UIBP.Expression_UIBP"
    },
    {
      subTabID = macroTabString.ENUM_WardrobeSubTabString_MiniTVSuit,
      subTabIconNormal = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_MiniTV_png.Common_Tab_MiniTV_png",
      subTabIconSelect = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_MiniTV_xuangzhong_png.Common_Tab_MiniTV_xuangzhong_png",
      onClickModuleName = "client.slua.umg.Wardrobe.subtab_minitv",
      onClickBP = "/Game/UMG/UI_BP/Wardrobe/HorizontalBox_Wardrobe_MiniTV_UIBP.HorizontalBox_Wardrobe_MiniTV_UIBP",
      hideTagFilter = true
    },
    {
      subTabID = macroTabString.Enum_WardrobeSubTabString_ShowBrand,
      subTabIconNormal = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_ShowBrand_png.Common_Tab_ShowBrand_png",
      subTabIconSelect = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_ShowBrand_xuangzhong_png.Common_Tab_ShowBrand_xuangzhong_png",
      onClickModuleName = "client.slua.umg.Wardrobe.subtab_showbrand",
      onClickBP = "/Game/UMG/UI_BP/Wardrobe/Wardrobe_Placard_UIBP.Wardrobe_Placard_UIBP",
      hideTagFilter = true
    },
    {
      subTabID = macroTabString.ENUM_WardrobeSubTabString_parachute,
      subTabIconNormal = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Zhuangbeitubiao_11_png.Common_Tab_Zhuangbeitubiao_11_png",
      subTabIconSelect = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Zhuangbeitubiao_11_xuangzhong_png.Common_Tab_Zhuangbeitubiao_11_xuangzhong_png",
      onClickModuleName = "client.slua.umg.Wardrobe.subtab_parachute",
      refreshIcon = false,
      defaultSelectedInEditMode = true
    },
    {
      subTabID = macroTabString.ENUM_WardrobeSubTabString_effect,
      subTabIconNormal = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Fly_png.Common_Tab_Fly_png",
      subTabIconSelect = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Fly_xuangzhong_png.Common_Tab_Fly_xuangzhong_png",
      onClickModuleName = "client.slua.umg.Wardrobe.subtab_gliding",
      refreshIcon = false
    },
    {
      subTabID = macroTabString.ENUM_WardrobeSubTabString_quicksign,
      subTabIconNormal = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Voicemark_png.Common_Tab_Voicemark_png",
      subTabIconSelect = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Voicemark_xuangzhong_png.Common_Tab_Voicemark_xuangzhong_png",
      onClickModuleName = "client.slua.umg.Wardrobe.subtab_quicksign",
      onClickBP = "/Game/UMG/UI_BP/Wardrobe/Wardrobe_QuickSign_BP.Wardrobe_QuickSign_BP",
      onClickAttachPoint = "CanvasPanel_0",
      hideTagFilter = true
    },
    {
      subTabID = macroTabString.ENUM_WardrobeSubTabString_quickmessage,
      subTabIconNormal = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Voice_png.Common_Tab_Voice_png",
      subTabIconSelect = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Voice_xuangzhong_png.Common_Tab_Voice_xuangzhong_png",
      onClickModuleName = "client.slua.umg.Wardrobe.subtab_quickmsg",
      onClickBP = "/Game/UMG/UI_BP/Setting/Setting_QuickMessage_BP.Setting_QuickMessage_BP",
      onClickAttachPoint = "CanvasPanel_0",
      hideTagFilter = true
    },
    {
      subTabID = macroTabString.ENUM_WardrobeSubTabString_plane,
      subTabIconNormal = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Zhuangbeitubiao_12_png.Common_Tab_Zhuangbeitubiao_12_png",
      subTabIconSelect = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Zhuangbeitubiao_12_xuangzhong_png.Common_Tab_Zhuangbeitubiao_12_xuangzhong_png",
      onClickModuleName = "client.slua.umg.Wardrobe.subtab_plane",
      onClickBP = "/Game/UMG/UI_BP/Wardrobe/HorizontalBox_Wardrobe_Plane_UIBP.HorizontalBox_Wardrobe_Plane_UIBP",
      refreshIcon = false
    },
    {
      subTabID = macroTabString.Enum_WardrobeSubTabString_SpecialVehicle,
      subTabIconNormal = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_UgcCrop_png.Common_Tab_UgcCrop_png",
      subTabIconSelect = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_UgcCrop_xuangzhong_png.Common_Tab_UgcCrop_xuangzhong_png",
      onClickModuleName = "client.slua.umg.Wardrobe.subtab_special_vehicle",
      onClickBP = "/Game/UMG/UI_BP/Wardrobe/HorizontalBox_Wardrobe_WOW_UIBP.HorizontalBox_Wardrobe_WOW_UIBP",
      refreshIcon = false
    },
    {
      subTabID = macroTabString.ENUM_WardrobeSubTabString_throw_object,
      subTabIconNormal = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Lei_png.Common_Tab_Lei_png",
      subTabIconSelect = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Lei_xuangzhong_png.Common_Tab_Lei_xuangzhong_png",
      onClickModuleName = "client.slua.umg.Wardrobe.subtab_throw_object",
      onClickBP = "/Game/UMG/UI_BP/Wardrobe/HorizontalBox_Wardrobe_ThrowOBJ_UIBP.HorizontalBox_Wardrobe_ThrowOBJ_UIBP"
    },
    {
      subTabID = macroTabString.ENUM_WardrobeSubTabString_hallTheme,
      subTabIconNormal = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Zhuangbeitubiao_8_png.Common_Tab_Zhuangbeitubiao_8_png",
      subTabIconSelect = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Zhuangbeitubiao_8_xuangzhong_png.Common_Tab_Zhuangbeitubiao_8_xuangzhong_png",
      onClickModuleName = "client.slua.umg.Wardrobe.subtab_hallTheme"
    },
    {
      subTabID = macroTabString.ENUM_WardrobeSubTabString_FootEffect,
      subTabIconNormal = "/Game/Arts/UI/TableIcons/ItemIcon/Tailing/Icon_Tailing_RPA18_01Hui_128.Icon_Tailing_RPA18_01Hui_128",
      subTabIconSelect = "/Game/Arts/UI/TableIcons/ItemIcon/Tailing/Icon_Tailing_RPA18_01_128.Icon_Tailing_RPA18_01_128",
      onClickModuleName = "client.slua.umg.Wardrobe.subtab_foot_effect",
      hideTagFilter = true
    },
    {
      subTabID = macroTabString.Enum_WardrobeSubTabString_CabinShow,
      subTabIconNormal = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_CabinDisplay_png.Common_Tab_CabinDisplay_png",
      subTabIconSelect = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_CabinDisplay_XuanZhong_png.Common_Tab_CabinDisplay_XuanZhong_png",
      onClickModuleName = "client.slua.umg.Wardrobe.subtab_cabinShow"
    },
    {
      subTabID = macroTabString.ENUM_WardrobeSubTabString_character_MVP_MOTION,
      subTabIconNormal = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_MVP_png.Common_Tab_MVP_png",
      subTabIconSelect = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_MVP_xuangzhong_png.Common_Tab_MVP_xuangzhong_png",
      onClickBP = "/Game/UMG/UI_BP/Wardrobe/HorizontalBox_Wardrobe_MVPAction_UIBP.HorizontalBox_Wardrobe_MVPAction_UIBP",
      onClickModuleName = "client.slua.umg.Wardrobe.subtab_actionMVP",
      hideTagFilter = true
    },
    {
      subTabID = macroTabString.Enum_WardrobeSubTabString_Toy,
      subTabIconNormal = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_FunProp_png.Common_Tab_FunProp_png",
      subTabIconSelect = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_FunProp_xuangzhong_png.Common_Tab_FunProp_xuangzhong_png",
      onClickModuleName = "client.slua.umg.Wardrobe.subtab_toy",
      hideTagFilter = true
    },
    {
      subTabID = macroTabString.ENUM_WardrobeSubTabString_interactive_action,
      subTabIconNormal = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Celebrate_png.Common_Tab_Celebrate_png",
      subTabIconSelect = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Celebrate_xuangzhong_png.Common_Tab_Celebrate_xuangzhong_png",
      onClickModuleName = "client.slua.umg.Wardrobe.subtab_interactive_action",
      onClickBP = "/Game/UMG/UI_BP/Wardrobe/Plating_UIBP.Plating_UIBP",
      hideTagFilter = true
    },
    {
      subTabID = macroTabString.ENUM_WardrobeSubTabString_emoji_bubble,
      subTabIconNormal = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Qipao_png.Common_Tab_Qipao_png",
      subTabIconSelect = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Qipao_xuangzhong_png.Common_Tab_Qipao_xuangzhong_png",
      onClickModuleName = "client.slua.umg.Wardrobe.subtab_emoji_bubble",
      onClickBP = "/Game/UMG/UI_BP/Wardrobe/Expression_UIBP.Expression_UIBP",
      hideTagFilter = true
    },
    {
      subTabID = macroTabString.ENUM_WardrobeSubTabString_holography,
      subTabIconNormal = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Quanxi_png.Common_Tab_Quanxi_png",
      subTabIconSelect = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Quanxi_xuangzhong_png.Common_Tab_Quanxi_xuangzhong_png",
      onClickModuleName = "client.slua.umg.Wardrobe.subtab_holography",
      onClickBP = "/Game/UMG/UI_BP/Wardrobe/Plating_UIBP.Plating_UIBP",
      hideTagFilter = true
    },
    {
      subTabID = macroTabString.ENUM_WardrobeSubTabString_plating,
      subTabIconNormal = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Pentu_png.Common_Tab_Pentu_png",
      subTabIconSelect = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Pentu_xuangzhong_png.Common_Tab_Pentu_xuangzhong_png",
      onClickModuleName = "client.slua.umg.Wardrobe.subtab_plating",
      onClickBP = "/Game/UMG/UI_BP/Wardrobe/Plating_UIBP.Plating_UIBP",
      hideTagFilter = true
    }
  }
}
Wardrobe_Config.SubTab_Config[Tool] = {
  subTabBP = "/Game/UMG/UI_BP/Wardrobe/WardrobeSubTab_UIBP.WardrobeSubTab_UIBP",
  subTabModuleName = "client.slua.umg.Wardrobe.sub_tab",
  hideTagFilter = true,
  subTabOnClick = {
    onClickBP = "/Game/UMG/UI_BP/Wardrobe/HorizontalBox_Wardrobe_Props_UIBP.HorizontalBox_Wardrobe_Props_UIBP",
    onClickAttachPoint = "Common_PlaceHolder"
  },
  subTabs = {
    {
      subTabID = macroTabString.ENUM_WardrobeSubTabString_items,
      subTabIconNormal = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Xiangzitubiao_png.Common_Tab_Xiangzitubiao_png",
      subTabIconSelect = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Xiangzitubiao_xuangzhong_png.Common_Tab_Xiangzitubiao_xuangzhong_png",
      onClickModuleName = "client.slua.umg.Wardrobe.subtab_props_all",
      defaultSelected = true,
      defaultSelectedInEditMode = true
    },
    {
      subTabID = macroTabString.ENUM_WardrobeSubTabString_voucher,
      subTabIconNormal = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Sale_png.Common_Tab_Sale_png",
      subTabIconSelect = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Sale_xuangzhong_png.Common_Tab_Sale_xuangzhong_png",
      onClickModuleName = "client.slua.umg.Wardrobe.subtab_tickets",
      shieldedRegion = ""
    },
    {
      subTabID = macroTabString.Enum_WardrobeSubTabString_Materials,
      subTabIconNormal = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Machine_png.Common_Tab_Machine_png",
      subTabIconSelect = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Machine_xuanzhong_png.Common_Tab_Machine_xuanzhong_png",
      onClickModuleName = "client.slua.umg.Wardrobe.subtab_props",
      shieldedRegion = ""
    },
    {
      subTabID = macroTabString.Enum_WardrobeSubTabString_SpaceGift,
      subTabIconNormal = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_GiftPopularity_png.Common_Tab_GiftPopularity_png",
      subTabIconSelect = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_GiftPopularity_xuanzhong_png.Common_Tab_GiftPopularity_xuanzhong_png",
      onClickModuleName = "client.slua.umg.Wardrobe.subtab_props",
      shieldedRegion = ""
    },
    {
      subTabID = macroTabString.Enum_WardrobeSubTabString_Packages,
      subTabIconNormal = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Pack_png.Common_Tab_Pack_png",
      subTabIconSelect = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Pack_Xuangzhong_png.Common_Tab_Pack_Xuangzhong_png",
      onClickModuleName = "client.slua.umg.Wardrobe.subtab_props",
      shieldedRegion = ""
    }
  }
}
Wardrobe_Config.SubTab_Config[Vehicle] = {
  subTabs = {}
}
Wardrobe_Config.SubTab_Config[Appearance] = {
  subTabBP = "/Game/UMG/UI_BP/Wardrobe/WardrobeSubTab_UIBP.WardrobeSubTab_UIBP",
  subTabModuleName = "client.slua.umg.Wardrobe.sub_tab",
  hideTagFilter = false,
  subTabOnClick = {
    onClickBP = "/Game/UMG/UI_BP/Wardrobe/HorizontalBox_Wardrobe_Clothes_UIBP.HorizontalBox_Wardrobe_Clothes_UIBP",
    onClickModuleName = "client.slua.umg.Wardrobe.subtab_avatar",
    onClickAttachPoint = "Common_PlaceHolder"
  },
  subTabs = {
    {
      subTabID = macroTabString.Enum_WardrobeSubTabString_Head,
      ItemSubTypeIDs = {400},
      subTabIconNormal = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Head_png.Common_Tab_Head_png",
      subTabIconSelect = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Head_xuangzhong_png.Common_Tab_Head_xuangzhong_png",
      onClickBP = "/Game/UMG/UI_BP/Wardrobe/HorizontalBox_Wardrobe_Gender_UIBP.HorizontalBox_Wardrobe_Gender_UIBP",
      onClickModuleName = "client.slua.umg.Wardrobe.subtab_appearance",
      defaultSelected = true,
      defaultSelectedInEditMode = true
    },
    {
      subTabID = macroTabString.Enum_WardrobeSubTabString_Hair,
      ItemSubTypeIDs = {406},
      subTabIconNormal = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Hair_png.Common_Tab_Hair_png",
      subTabIconSelect = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Hair_xuangzhong_png.Common_Tab_Hair_xuangzhong_png",
      onClickBP = "/Game/UMG/UI_BP/Wardrobe/HorizontalBox_Wardrobe_Gender_UIBP.HorizontalBox_Wardrobe_Gender_UIBP",
      onClickModuleName = "client.slua.umg.Wardrobe.subtab_appearance"
    },
    {
      subTabID = macroTabString.Enum_WardrobeSubTabString_Beard,
      ItemSubTypeIDs = {408},
      subTabIconNormal = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Beard_png.Common_Tab_Beard_png",
      subTabIconSelect = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Beard_xuangzhong_png.Common_Tab_Beard_xuangzhong_png",
      onClickBP = "/Game/UMG/UI_BP/Wardrobe/HorizontalBox_Wardrobe_Gender_UIBP.HorizontalBox_Wardrobe_Gender_UIBP",
      onClickModuleName = "client.slua.umg.Wardrobe.subtab_appearance"
    },
    {
      subTabID = macroTabString.Enum_WardrobeSubTabString_UnderWear,
      ItemSubTypeIDs = {428, 429},
      subTabIconNormal = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Underwear_png.Common_Tab_Underwear_png",
      subTabIconSelect = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Common_Tab_Underwear_xuangzhong_png.Common_Tab_Underwear_xuangzhong_png",
      onClickBP = "/Game/UMG/UI_BP/Wardrobe/HorizontalBox_Wardrobe_Gender_UIBP.HorizontalBox_Wardrobe_Gender_UIBP",
      onClickModuleName = "client.slua.umg.Wardrobe.subtab_appearance"
    }
  }
}
Wardrobe_Config.Tab_Structure = {
  [Weapon] = {},
  [Vehicle] = {}
}
Wardrobe_Config.PageID_To_SubTabDataList = {}
Wardrobe_Config.InitSubTabConfig = false
function Wardrobe_Config:GetTabPageConfig(pageID)
  for _, v in ipairs(Wardrobe_Config.PageTab_Config) do
    if v.pageId == pageID then
      return v
    end
  end
  return {}
end
function Wardrobe_Config:GetSubTabListByPageId(pageID)
  if Wardrobe_Config.PageID_To_SubTabDataList[pageID] then
    return Wardrobe_Config.PageID_To_SubTabDataList[pageID]
  end
  local subTabList = {}
  for _, v in ipairs(Wardrobe_Config.SubTab_Config[pageID].subTabs) do
    local subTabConfig = self:AssembleSubTabStruct(v, pageID)
    table.insert(subTabList, subTabConfig)
  end
  Wardrobe_Config.PageID_To_SubTabDataList[pageID] = subTabList
  return subTabList
end
function Wardrobe_Config:AssembleSubTabStruct(data, pageID)
  local pageConfig = Wardrobe_Config.SubTab_Config[pageID]
  local subTabConfig = {
    pageId = pageID,
    bpPath = pageConfig.subTabBP,
    subTabId = data.subTabID,
    ItemSubTypeIDs = data.ItemSubTypeIDs,
    moduleName = pageConfig.subTabModuleName,
    tabIconNormal = pageConfig.subTabIconNormal or data.subTabIconNormal,
    tabIconSelect = pageConfig.subTabIconSelect or data.subTabIconSelect,
    refreshIcon = data.refreshIcon ~= false,
    OnClick = {
      bpPath = data.onClickBP or pageConfig.subTabOnClick.onClickBP,
      moduleName = data.onClickModuleName or pageConfig.subTabOnClick.onClickModuleName,
      attachPoint = data.onClickAttachPoint or pageConfig.subTabOnClick.onClickAttachPoint
    },
    defaultSelected = data.defaultSelected,
    defaultSelectedInEditMode = data.defaultSelectedInEditMode,
    shieldedRegion = data.shieldedRegion or "",
    uiStat_name = "\228\187\147\229\186\147-" .. data.subTabID,
    hideTagFilter = data.hideTagFilter or pageConfig.hideTagFilter,
    bRefreshIconOnEditMode = data.bRefreshIconOnEditMode
  }
  return subTabConfig
end
return Wardrobe_Config