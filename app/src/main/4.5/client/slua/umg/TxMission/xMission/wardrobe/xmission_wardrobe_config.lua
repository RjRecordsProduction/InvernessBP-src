local xMission_macro = require("client.slua.umg.TxMission.xMission.xmission_macro")
local All = xMission_macro.ENUM_WardrobePage.ENUM_WardrobePage_All
local Weapon = xMission_macro.ENUM_WardrobePage.ENUM_WardrobePage_Weapon
local Part = xMission_macro.ENUM_WardrobePage.ENUM_WardrobePage_Part
local Bullet = xMission_macro.ENUM_WardrobePage.ENUM_WardrobePage_Bullet
local Armor = xMission_macro.ENUM_WardrobePage.ENUM_WardrobePage_Armor
local Tool = xMission_macro.ENUM_WardrobePage.ENUM_WardrobePage_Tool
local xMission_Wardrobe_Config = {
  PageTab_Config = {
    {
      pageId = All,
      pageIconNormal = "/Game/Mod/TPlan/XMission/Textures/XMission_Wardrobe_Atlas/Frames/XMission_Wardrobe_ICON1_png.XMission_Wardrobe_ICON1_png",
      pageIconSelect = "/Game/Mod/TPlan/XMission/Textures/XMission_Wardrobe_Atlas/Frames/XMission_Wardrobe_ICON1_1_png.XMission_Wardrobe_ICON1_1_png",
      moduleName = "client.slua.umg.TxMission.xMission.wardrobe.xmission_page_tab",
      bpPath = "/Game/Mod/TPlan/XMission/UMG/Wardrobe/Wardrobe_PageTab_UIBP.Wardrobe_PageTab_UIBP",
      onPageClick = {
        onClickBP = "/Game/Mod/TPlan/XMission/UMG/Wardrobe/Wardrobe_Clothes_UIBP.Wardrobe_Clothes_UIBP",
        onClickModuleName = "client.slua.umg.TxMission.xMission.wardrobe.xmission_subtab_all",
        onClickAttachPoint = "Common_PlaceHolder"
      },
      defaultSelected = true,
      uiStat_name = "xMission\228\187\147\229\186\147-\229\133\168\233\131\168"
    },
    {
      pageId = Weapon,
      pageIconNormal = "/Game/Mod/TPlan/XMission/Textures/XMission_Wardrobe_Atlas/Frames/XMission_Wardrobe_ICON2_png.XMission_Wardrobe_ICON2_png",
      pageIconSelect = "/Game/Mod/TPlan/XMission/Textures/XMission_Wardrobe_Atlas/Frames/XMission_Wardrobe_ICON2_1_png.XMission_Wardrobe_ICON2_1_png",
      moduleName = "client.slua.umg.TxMission.xMission.wardrobe.xmission_page_tab",
      bpPath = "/Game/Mod/TPlan/XMission/UMG/Wardrobe/Wardrobe_PageTab_UIBP.Wardrobe_PageTab_UIBP",
      onPageClick = {
        onClickBP = "/Game/Mod/TPlan/XMission/UMG/Wardrobe/Wardrobe_Clothes_UIBP.Wardrobe_Clothes_UIBP",
        onClickModuleName = "client.slua.umg.TxMission.xMission.wardrobe.xmission_subtab_base",
        onClickAttachPoint = "Common_PlaceHolder"
      },
      uiStat_name = "xMission\228\187\147\229\186\147-\230\158\170\230\162\176"
    },
    {
      pageId = Armor,
      pageIconNormal = "/Game/Mod/TPlan/XMission/Textures/XMission_Wardrobe_Atlas/Frames/XMission_Wardrobe_ICON3_png.XMission_Wardrobe_ICON3_png",
      pageIconSelect = "/Game/Mod/TPlan/XMission/Textures/XMission_Wardrobe_Atlas/Frames/XMission_Wardrobe_ICON3_1_png.XMission_Wardrobe_ICON3_1_png",
      moduleName = "client.slua.umg.TxMission.xMission.wardrobe.xmission_page_tab",
      bpPath = "/Game/Mod/TPlan/XMission/UMG/Wardrobe/Wardrobe_PageTab_UIBP.Wardrobe_PageTab_UIBP",
      onPageClick = {
        onClickBP = "/Game/Mod/TPlan/XMission/UMG/Wardrobe/Wardrobe_Clothes_UIBP.Wardrobe_Clothes_UIBP",
        onClickModuleName = "client.slua.umg.TxMission.xMission.wardrobe.xmission_subtab_base",
        onClickAttachPoint = "Common_PlaceHolder"
      },
      uiStat_name = "xMission\228\187\147\229\186\147-\233\152\178\229\133\183"
    },
    {
      pageId = Part,
      pageIconNormal = "/Game/Mod/TPlan/XMission/Textures/XMission_Wardrobe_Atlas/Frames/XMission_Wardrobe_ICON4_png.XMission_Wardrobe_ICON4_png",
      pageIconSelect = "/Game/Mod/TPlan/XMission/Textures/XMission_Wardrobe_Atlas/Frames/XMission_Wardrobe_ICON4_1_png.XMission_Wardrobe_ICON4_1_png",
      moduleName = "client.slua.umg.TxMission.xMission.wardrobe.xmission_page_tab",
      bpPath = "/Game/Mod/TPlan/XMission/UMG/Wardrobe/Wardrobe_PageTab_UIBP.Wardrobe_PageTab_UIBP",
      onPageClick = {
        onClickBP = "/Game/Mod/TPlan/XMission/UMG/Wardrobe/Wardrobe_Clothes_UIBP.Wardrobe_Clothes_UIBP",
        onClickModuleName = "client.slua.umg.TxMission.xMission.wardrobe.xmission_subtab_base",
        onClickAttachPoint = "Common_PlaceHolder"
      },
      uiStat_name = "xMission\228\187\147\229\186\147-\233\133\141\228\187\182"
    },
    {
      pageId = Bullet,
      pageIconNormal = "/Game/Mod/TPlan/XMission/Textures/XMission_Wardrobe_Atlas/Frames/XMission_Wardrobe_ICON5_png.XMission_Wardrobe_ICON5_png",
      pageIconSelect = "/Game/Mod/TPlan/XMission/Textures/XMission_Wardrobe_Atlas/Frames/XMission_Wardrobe_ICON5_1_png.XMission_Wardrobe_ICON5_1_png",
      moduleName = "client.slua.umg.TxMission.xMission.wardrobe.xmission_page_tab",
      bpPath = "/Game/Mod/TPlan/XMission/UMG/Wardrobe/Wardrobe_PageTab_UIBP.Wardrobe_PageTab_UIBP",
      onPageClick = {
        onClickBP = "/Game/Mod/TPlan/XMission/UMG/Wardrobe/Wardrobe_Clothes_UIBP.Wardrobe_Clothes_UIBP",
        onClickModuleName = "client.slua.umg.TxMission.xMission.wardrobe.xmission_subtab_base",
        onClickAttachPoint = "Common_PlaceHolder"
      },
      uiStat_name = "xMission\228\187\147\229\186\147-\229\173\144\229\188\185"
    },
    {
      pageId = Tool,
      pageIconNormal = "/Game/Mod/TPlan/XMission/Textures/XMission_Wardrobe_Atlas/Frames/XMission_Wardrobe_ICON6_png.XMission_Wardrobe_ICON6_png",
      pageIconSelect = "/Game/Mod/TPlan/XMission/Textures/XMission_Wardrobe_Atlas/Frames/XMission_Wardrobe_ICON6_1_png.XMission_Wardrobe_ICON6_1_png",
      moduleName = "client.slua.umg.TxMission.xMission.wardrobe.xmission_page_tab",
      bpPath = "/Game/Mod/TPlan/XMission/UMG/Wardrobe/Wardrobe_PageTab_UIBP.Wardrobe_PageTab_UIBP",
      onPageClick = {
        onClickBP = "/Game/Mod/TPlan/XMission/UMG/Wardrobe/Wardrobe_Clothes_UIBP.Wardrobe_Clothes_UIBP",
        onClickModuleName = "client.slua.umg.TxMission.xMission.wardrobe.xmission_subtab_base",
        onClickAttachPoint = "Common_PlaceHolder"
      },
      uiStat_name = "xMission\228\187\147\229\186\147-\233\129\147\229\133\183"
    }
  }
}
return xMission_Wardrobe_Config