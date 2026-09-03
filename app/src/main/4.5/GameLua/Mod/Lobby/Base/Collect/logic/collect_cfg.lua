local Wardrobe_Config = require("client.slua.umg.Wardrobe.wardrobe_config")
local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
local sortIds = wardrobe_macro.ENUM_WardrobePageTypeId
local macroTabString = wardrobe_macro.ENUM_WardrobeSubTabString
local ItemMacros = require("client.slua.config.ClientMacros.ItemMacros")
local QUALITY_GOLDEN = ItemMacros.QUALITY_GOLDEN
local QUALITY_RED = ItemMacros.QUALITY_RED
local QUALITY_PINK = ItemMacros.QUALITY_PINK
local QUALITY_PURPLE = ItemMacros.QUALITY_PURPLE
local collect_cfg = {
  voteId = 406,
  SeasonMaxText = "MAX",
  Sys2Index = {
    Level = 1,
    Season = 2,
    Clothes = 3,
    Guns = 4,
    Vehicle = 5,
    Pet = 6
  },
  quality2Word = {
    [QUALITY_GOLDEN] = 77432,
    [QUALITY_RED] = 77433,
    [QUALITY_PINK] = 77434,
    [QUALITY_PURPLE] = 77435
  },
  privacy = {
    DoubleShowCollectLevel = 1,
    DoubleStrangerCDetail = 2,
    DoubleFriendCDetail = 3
  },
  DetailTabIndex = {
    Gun = 1,
    Theme = 2,
    Clothes = 3,
    Car = 4,
    Pet = 5
  },
  Index2AwardName = {
    "total_award_status",
    "season_award_status",
    "cloth_award_status",
    "weapon_award_status",
    "vehicle_award_status",
    "pet_award_status"
  },
  DetailTab2ScoreName = {
    "weapon_score",
    "",
    "cloth_score",
    "vehicle_score"
  },
  Index2SysId = {4, 6},
  tab2Sort = {
    [macroTabString.ENUM_WardrobeSubTabString_bag_pendant] = sortIds.ENUM_WardrobePageType_Avatar
  },
  page2Image = {},
  subTab2Image = {},
  upFrames = {
    [61830001] = "/Game/UMG/Texture_200/Lobby_NoAtlas/RoleInfo/Collect/Room/Collect_PhotoFrame_Bg01.Collect_PhotoFrame_Bg01",
    [61830002] = "/Game/UMG/Texture_200/Lobby_NoAtlas/RoleInfo/Collect/Room/Collect_PhotoFrame_Bg03.Collect_PhotoFrame_Bg03",
    [61830003] = "/Game/UMG/Texture_200/Lobby_NoAtlas/RoleInfo/Collect/Room/Collect_PhotoFrame_Bg05.Collect_PhotoFrame_Bg05"
  },
  downFrames = {
    [61830001] = "/Game/UMG/Texture_200/Lobby_NoAtlas/RoleInfo/Collect/Room/Collect_PhotoFrame_Bg02.Collect_PhotoFrame_Bg02",
    [61830002] = "/Game/UMG/Texture_200/Lobby_NoAtlas/RoleInfo/Collect/Room/Collect_PhotoFrame_Bg04.Collect_PhotoFrame_Bg04",
    [61830003] = "/Game/UMG/Texture_200/Lobby_NoAtlas/RoleInfo/Collect/Room/Collect_PhotoFrame_Bg06.Collect_PhotoFrame_Bg06"
  },
  dataInOther = -1,
  collect_special_page = {
    [macroTabString.ENUM_WardrobeSubTabString_bag_pendant] = {
      subTabID = macroTabString.ENUM_WardrobeSubTabString_bag_pendant,
      ItemSubTypeIDs = {417},
      pageIconNormal = "/Game/Mod/Lobby/Base/Wardrobe/Atlas/WardrobeUI_New/Frames/Common_Tab_Ornament_png.Common_Tab_Ornament_png",
      pageIconSelect = "/Game/Mod/Lobby/Base/Wardrobe/Atlas/WardrobeUI_New/Frames/Common_Tab_Ornament_xuangzhong_png.Common_Tab_Ornament_xuangzhong_png"
    }
  },
  DynamicBadgeItemLuaPath = "GameLua.Mod.Lobby.Split.Collect.umg.Room.Item.Collect_Room_Dynamic_Badge_Item",
  E_Milestone_Tab = {
    outfits = 1,
    firearms = 2,
    Vehicle = 3,
    career = 4,
    pet = 5
  },
  C_Milestone_Tab_Text_List = {
    82002,
    82003,
    82029,
    82045,
    82070
  },
  E_Milestone_Guide_Mark = {
    C_Guide_Edit = 1,
    C_Guide_View = 2,
    C_Guide_Action = 3
  },
  E_Milestone_Server_Type = {
    firearms = 1,
    outfits = 2,
    Vehicle = 3,
    career = 4,
    pet = 5
  },
  E_Milestone_Edit_Slot_Type = {acquired = "acquired", slot = "slot"},
  E_Milestone_Action_Edit_Slot_Type = {
    milestoneAction = "milestoneAction",
    milestoneActionSlot = "milestoneActionSlot"
  },
  C_Image_Format_Gray = "/Game/Mod/Lobby/Split/CollectBadge/Level/Collect_Level_Big0%d_Gray_Bg.Collect_Level_Big0%d_Gray_Bg",
  C_Image_Format_Light = "/Game/Mod/Lobby/Split/CollectBadge/Level/Collect_Level_Big0%d_Bg.Collect_Level_Big0%d_Bg",
  C_Path_Format_Silver_Gray = "/Game/Mod/Lobby/Split/CollectBadge/Level/Collect_Level_Big03_No%d_Gray.Collect_Level_Big03_No%d_Gray",
  C_Path_Format_Silver_Light = "/Game/Mod/Lobby/Split/CollectBadge/Level/Collect_Level_Big03_No%d.Collect_Level_Big03_No%d",
  C_Path_Format_Gold_Gray = "/Game/Mod/Lobby/Split/CollectBadge/Level/Collect_Level_Big06_No%d_Gray.Collect_Level_Big06_No%d_Gray",
  C_Path_Format_Gold_Light = "/Game/Mod/Lobby/Split/CollectBadge/Level/Collect_Level_Big06_No%d.Collect_Level_Big06_No%d",
  C_Helmet_Icon_Gray = "/Game/Mod/Lobby/Split/CollectBadge/Leve8/T_UI_Collect_Leve8_Gray_10.T_UI_Collect_Leve8_Gray_10",
  C_Helmet_Icon_Light = "/Game/Mod/Lobby/Split/CollectBadge/Leve8/T_UI_Collect_Leve8_10.T_UI_Collect_Leve8_10",
  E_CollectBadge_AnimaType = {
    None = 0,
    Fadein = 1,
    Upgrade = 2
  },
  E_AwardGet_Type = {
    [true] = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Btn_Huangse_png.Common_Btn_Huangse_png",
    [false] = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Btn_Bukedian_png.Common_Btn_Bukedian_png"
  },
  sDefMilestoneBGPath = "/Game/UMG/Texture_200/Lobby_NoAtlas/RoleInfo/Collect/Room/DressUp/MilestoneBG/Collect_Room_DressUp_MilestoneBg01.Collect_Room_DressUp_MilestoneBg01",
  tBGID2Config = {
    [61820001] = {
      index = 0,
      bpPath = "/Game/Mod/Lobby/Split/Collect/CardBg/Collect_CardBg_Elementary_UIBP.Collect_CardBg_Elementary_UIBP",
      milestoneBGPath = "/Game/UMG/Texture_200/Lobby_NoAtlas/RoleInfo/Collect/Room/DressUp/MilestoneBG/Collect_Room_DressUp_MilestoneBg02.Collect_Room_DressUp_MilestoneBg02"
    },
    [61820002] = {
      index = 1,
      bpPath = "/Game/Mod/Lobby/Split/Collect/CardBg/Collect_CardBg_MiddleRank_UIBP.Collect_CardBg_MiddleRank_UIBP",
      milestoneBGPath = "/Game/UMG/Texture_200/Lobby_NoAtlas/RoleInfo/Collect/Room/DressUp/MilestoneBG/Collect_Room_DressUp_MilestoneBg03.Collect_Room_DressUp_MilestoneBg03"
    },
    [61820003] = {
      index = 2,
      bpPath = "/Game/Mod/Lobby/Split/Collect/CardBg/Collect_CardBg_Senior_UIBP.Collect_CardBg_Senior_UIBP",
      milestoneBGPath = "/Game/UMG/Texture_200/Lobby_NoAtlas/RoleInfo/Collect/Room/DressUp/MilestoneBG/Collect_Room_DressUp_MilestoneBg04.Collect_Room_DressUp_MilestoneBg04"
    }
  },
  DefaultCardBG = "/Game/Mod/Lobby/Split/Collect/CardBg/Collect_CardBg_Empty_UIBP.Collect_CardBg_Empty_UIBP"
}
local tab2Sort = collect_cfg.tab2Sort
for k, oneSort in pairs(Wardrobe_Config.SubTab_Config) do
  for _, v in ipairs(oneSort.subTabs) do
    tab2Sort[v.subTabID] = k
  end
end
local page2Image = collect_cfg.page2Image
for _, cfg in pairs(Wardrobe_Config.PageTab_Config) do
  page2Image[cfg.pageId] = {
    pageIconNormal = cfg.inactivePath,
    pageIconSelect = cfg.activePath
  }
end
local subTab2Image = collect_cfg.subTab2Image
for _, cfg in pairs(Wardrobe_Config.SubTab_Config[sortIds.ENUM_WardrobePageType_Avatar].subTabs) do
  subTab2Image[cfg.subTabID] = {
    pageIconNormal = cfg.subTabIconNormal,
    pageIconSelect = cfg.subTabIconSelect
  }
end
collect_cfg.serverType2MilestoneTab = {
  [collect_cfg.E_Milestone_Server_Type.outfits] = collect_cfg.E_Milestone_Tab.outfits,
  [collect_cfg.E_Milestone_Server_Type.firearms] = collect_cfg.E_Milestone_Tab.firearms,
  [collect_cfg.E_Milestone_Server_Type.Vehicle] = collect_cfg.E_Milestone_Tab.Vehicle,
  [collect_cfg.E_Milestone_Server_Type.career] = collect_cfg.E_Milestone_Tab.career,
  [collect_cfg.E_Milestone_Server_Type.pet] = collect_cfg.E_Milestone_Tab.pet
}
collect_cfg.milestoneTab2ServerType = {
  [collect_cfg.E_Milestone_Tab.outfits] = collect_cfg.E_Milestone_Server_Type.outfits,
  [collect_cfg.E_Milestone_Tab.firearms] = collect_cfg.E_Milestone_Server_Type.firearms,
  [collect_cfg.E_Milestone_Tab.Vehicle] = collect_cfg.E_Milestone_Server_Type.Vehicle,
  [collect_cfg.E_Milestone_Tab.career] = collect_cfg.E_Milestone_Server_Type.career,
  [collect_cfg.E_Milestone_Tab.pet] = collect_cfg.E_Milestone_Server_Type.pet
}
return collect_cfg