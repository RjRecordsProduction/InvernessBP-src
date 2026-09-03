local PufferConst = require("client.slua.logic.download.puffer_const")
local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local EUIConfigPoolType = require("client.slua.config.ClientMacros.EUIConfigPoolType")
local LobbyQueuePopUIKeyDefine = require("client.slua.config.LobbyQueuePopUIKeyDefine")
local ESlateVisibility = UEnums and UEnums.ESlateVisibility or {}
local Visible = ESlateVisibility.Visible
local Collapsed = ESlateVisibility.Collapsed
require("client.slua.config.ClientMacros.bp_macros")
require("client.common.game_status")
require("client.slua.config.ClientMacros.EFixedZOrder")
require("client.slua.config.ClientMacros.UIContainers")
require("client.common.SlateUI_ID")
local souvenirs_ui_configs = {
  Collect_Available_Rewards = {
    keyName = "Collect_Available_Rewards",
    moduleName = "GameLua.Mod.Lobby.Base.Collect.umg.Tips.Collect_Available_Rewards",
    path = "/Game/UMG/UI_BP/Universal_Popup/Common_Popup_UIBP.Common_Popup_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\231\143\141\232\151\143-\229\143\175\231\148\168\229\165\150\229\138\177\229\188\185\231\170\151"
    }
  },
  Collect_Award_Preview_AddPetItem_Item = {
    keyName = "Collect_Award_Preview_AddPetItem_Item",
    isMainUI = false,
    isSingleton = false,
    moduleName = "GameLua.Mod.Lobby.Base.Collect.umg.AwardPreview.Collect_Award_Preview_AddPetItem_Item",
    path = "/Game/Mod/Lobby/Split/Collect/Item/Collect_Award_Preview_AddPetItem_Item.Collect_Award_Preview_AddPetItem_Item",
    uiStat = {
      name = "\230\148\182\232\151\143-\230\148\182\232\151\143\228\185\139\232\183\175\233\162\132\232\167\136-\229\174\160\231\137\169\230\167\189\228\189\141\231\137\185\230\157\131"
    }
  },
  Collect_Award_Preview_GiftDetails_Item = {
    keyName = "Collect_Award_Preview_GiftDetails_Item",
    isMainUI = false,
    moduleName = "GameLua.Mod.Lobby.Base.Collect.umg.AwardPreview.Collect_Award_Preview_GiftDetails_Item",
    path = "/Game/Mod/Lobby/Split/Collect/Item/Collect_Award_Preview_GiftDetails_Item.Collect_Award_Preview_GiftDetails_Item",
    uiStat = {
      name = "\230\148\182\232\151\143-\229\165\150\229\138\177\233\162\132\232\167\136-\231\164\188\229\140\133"
    }
  },
  Collect_Award_Preview_Gun_Item = {
    keyName = "Collect_Award_Preview_Gun_Item",
    moduleName = "GameLua.Mod.Lobby.Base.Collect.umg.AwardPreview.Collect_Award_Preview_Gun_Item",
    path = "/Game/Mod/Lobby/Split/Collect/Item/Collect_Award_Preview_Gun_Item.Collect_Award_Preview_Gun_Item",
    uiStat = {
      name = "\231\143\141\232\151\143\233\162\132\232\167\136-\229\135\187\230\157\128\229\137\170\229\189\177"
    }
  },
  Collect_Award_Preview_InheritancePrivileges_Item = {
    keyName = "Collect_Award_Preview_InheritancePrivileges_Item",
    isMainUI = false,
    moduleName = "GameLua.Mod.Lobby.Base.Collect.umg.AwardPreview.Collect_Award_Preview_InheritancePrivileges_Item",
    path = "/Game/Mod/Lobby/Split/Collect/Item/Collect_Award_Preview_InheritancePrivileges_Item.Collect_Award_Preview_InheritancePrivileges_Item",
    uiStat = {
      name = "\228\188\160\230\137\191\231\137\185\230\157\131\229\165\150\229\138\177\233\162\132\232\167\136\231\149\140\233\157\162"
    }
  },
  Collect_Award_Preview_Material_Item = {
    keyName = "Collect_Award_Preview_Material_Item",
    moduleName = "GameLua.Mod.Lobby.Base.Collect.umg.AwardPreview.Collect_Award_Preview_Material_Item",
    path = "/Game/Mod/Lobby/Split/Collect/Item/Collect_Award_Preview_Material_Item.Collect_Award_Preview_Material_Item",
    uiStat = {
      name = "\231\143\141\232\151\143\233\162\132\232\167\136-\230\175\143\229\145\168\230\157\144\230\150\153\231\164\188\229\140\133\231\137\185\230\157\131"
    }
  },
  Collect_Award_Preview_PhotoFrame_Item = {
    keyName = "Collect_Award_Preview_PhotoFrame_Item",
    moduleName = "GameLua.Mod.Lobby.Base.Collect.umg.AwardPreview.Collect_Award_Preview_PhotoFrame_Item",
    path = "/Game/Mod/Lobby/Split/Collect/Item/Collect_Award_Preview_PhotoFrame_Item.Collect_Award_Preview_PhotoFrame_Item",
    uiStat = {
      name = "\231\143\141\232\151\143\233\162\132\232\167\136-\230\148\182\232\151\143\229\174\164\231\155\184\230\161\134"
    }
  },
  Collect_Award_Preview_SharePackage_Item = {
    keyName = "Collect_Award_Preview_SharePackage_Item",
    moduleName = "GameLua.Mod.Lobby.Base.Collect.umg.AwardPreview.Collect_Award_Preview_SharePackage_Item",
    path = "/Game/Mod/Lobby/Split/Collect/Item/Collect_Award_Preview_SharePackage_Item.Collect_Award_Preview_SharePackage_Item",
    uiStat = {
      name = "\231\143\141\232\151\143\233\162\132\232\167\136-\231\137\185\230\157\131"
    }
  },
  Collect_Award_Preview_TeamShow_Item = {
    keyName = "Collect_Award_Preview_TeamShow_Item",
    moduleName = "GameLua.Mod.Lobby.Base.Collect.umg.AwardPreview.Collect_Award_Preview_TeamShow_Item",
    path = "/Game/Mod/Lobby/Split/Collect/Item/Collect_Award_Preview_TeamShow_Item.Collect_Award_Preview_TeamShow_Item",
    uiStat = {
      name = "\231\143\141\232\151\143\233\162\132\232\167\136-\229\144\141\229\173\151\229\143\152\232\137\178"
    }
  },
  Collect_Award_Preview_UIBP = {
    keyName = "Collect_Award_Preview_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Collect.umg.AwardPreview.Collect_Award_Preview_UIBP",
    path = "/Game/Mod/Lobby/Split/Collect/Collect_Award_Preview_UIBP.Collect_Award_Preview_UIBP",
    jumpModuleID = BP_ENUM_MODULE_COLLECT_ROAD_PREVIEW,
    uiStat = {
      name = "\230\148\182\232\151\143-\230\148\182\232\151\143\228\185\139\232\183\175\233\162\132\232\167\136"
    }
  },
  Collect_Award_Preview_Video_Item = {
    keyName = "Collect_Award_Preview_Video_Item",
    isMainUI = false,
    isSingleton = false,
    moduleName = "GameLua.Mod.Lobby.Base.Collect.umg.AwardPreview.Collect_Award_Preview_Video_Item",
    path = "/Game/UMG/UI_BP/NewItemUpgrade/Common_KillCounter_Video_UIBP.Common_KillCounter_Video_UIBP",
    uiStat = {
      name = "\230\148\182\232\151\143-\230\148\182\232\151\143\228\185\139\232\183\175\233\162\132\232\167\136-\229\141\142\228\184\189\232\176\162\229\185\149\232\167\134\233\162\145"
    }
  },
  Collect_Award_Preview_Video_Popup_UIIBP = {
    keyName = "Collect_Award_Preview_Video_Popup_UIIBP",
    moduleName = "GameLua.Mod.Lobby.Base.Collect.umg.AwardPreview.Collect_Award_Preview_Video_Popup_UIIBP",
    path = "/Game/UMG/UI_BP/NewItemUpgrade/Common_KillCounter_Preview_Video_Popup_UIIBP.Common_KillCounter_Preview_Video_Popup_UIIBP",
    uiStat = {
      name = "\230\148\182\232\151\143-\229\135\187\230\157\128\232\174\161\230\149\176\229\153\168\232\167\134\233\162\145"
    }
  },
  Collect_CardBgPreview_UIBP = {
    keyName = "Collect_CardBgPreview_UIBP",
    isMainUI = false,
    moduleName = "GameLua.Mod.Lobby.Split.Collect.umg.Road.Collect_CardBgPreview_UIBP",
    path = "/Game/Mod/Lobby/Split/Collect/CardBg/Collect_CardBgPreview_UIBP.Collect_CardBgPreview_UIBP",
    uiStat = {
      name = "\230\148\182\232\151\143-\230\148\182\232\151\143\228\185\139\232\183\175\233\162\132\232\167\136-\232\131\140\230\153\175\233\162\132\232\167\136"
    }
  },
  Collect_ExhibitionHallShare_UIBP = {
    keyName = "Collect_ExhibitionHallShare_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Collect.umg.Room.Collect_ExhibitionHallShare_UIBP",
    path = "/Game/Mod/Lobby/Split/Collect/Collect_ExhibitionHallShare_UIBP.Collect_ExhibitionHallShare_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\230\148\182\232\151\143-\230\148\182\232\151\143\229\174\164\229\136\134\228\186\171"
    }
  },
  Collect_Guide_UIBP = {
    keyName = "Collect_Guide_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Collect.umg.Road.Collect_Guide_UIBP",
    path = "/Game/Mod/Lobby/Split/Collect/Collect_Guide_UIBP.Collect_Guide_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\230\148\182\232\151\143-\229\188\149\229\175\188"
    }
  },
  Collect_LevelUp_UIBP = {
    keyName = "Collect_LevelUp_UIBP",
    moduleName = "GameLua.Mod.Lobby.Base.Collect.umg.LevelUP.Collect_LevelUp_UIBP",
    path = "/Game/Mod/Lobby/Split/Collect/Collect_LevelUp_UIBP.Collect_LevelUp_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\231\143\141\232\151\143\229\141\135\231\186\167\231\149\140\233\157\162"
    }
  },
  Collect_Level_Medal_Tips_UIBP = {
    keyName = "Collect_Level_Medal_Tips_UIBP",
    moduleName = "GameLua.Mod.Lobby.Base.Collect.umg.Tips.Collect_Level_Medal_Tips_UIBP",
    path = "/Game/Mod/Lobby/Split/Collect/Item/Collect_Level_Medal_Tips_UIBP.Collect_Level_Medal_Tips_UIBP",
    containerName = UIContainers.Top,
    zOrder = EFixedZOrder.CollectMedal,
    asy = true,
    uiStat = {
      name = "\230\148\182\232\151\143\229\139\139\231\171\160\229\188\185\231\170\151"
    }
  },
  Collect_Library_Clothe_Popup_Collection_UIBP = {
    keyName = "Collect_Library_Clothe_Popup_Collection_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Collect.umg.See.Collect_Library_Clothe_Popup_Collection_UIBP",
    path = "/Game/Mod/Lobby/Split/Collect/Popup/Collect_Library_Clothe_Popup_Collection_UIBP.Collect_Library_Clothe_Popup_Collection_UIBP",
    containerName = UIContainers.Top,
    uiStat = {
      name = "\230\148\182\232\151\143-\230\156\141\232\163\133-\231\179\187\229\136\151\229\188\185\231\170\151"
    }
  },
  Collect_Library_Clothe_UIBP = {
    keyName = "Collect_Library_Clothe_UIBP",
    isMainUI = false,
    moduleName = "GameLua.Mod.Lobby.Split.Collect.umg.See.Collect_Library_Clothe_UIBP",
    path = "/Game/Mod/Lobby/Split/Collect/Collect_Library_Clothe_UIBP.Collect_Library_Clothe_UIBP",
    asy = true,
    uiStat = {
      name = "\230\148\182\232\151\143-\232\151\143\229\147\129\229\186\147-\230\156\141\232\163\133"
    }
  },
  Collect_Library_DetailsGoods_UIBP = {
    keyName = "Collect_Library_DetailsGoods_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Collect.umg.See.Collect_Library_DetailsGoods_UIBP",
    path = "/Game/Mod/Lobby/Split/Collect/Collect_Library_DetailsGoods_UIBP.Collect_Library_DetailsGoods_UIBP",
    jumpModuleID = BP_ENUM_MODULE_COLLECT_LIBRARY,
    asy = true,
    uiStat = {
      name = "\230\148\182\232\151\143-\232\151\143\229\147\129\229\186\147-\232\161\163\230\156\141"
    }
  },
  Collect_Library_DetailsGunCar_UIBP = {
    keyName = "Collect_Library_DetailsGunCar_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Collect.umg.See.Collect_Library_DetailsGunCar_UIBP",
    path = "/Game/Mod/Lobby/Split/Collect/Collect_Library_DetailsGunCar_UIBP.Collect_Library_DetailsGunCar_UIBP",
    jumpModuleID = BP_ENUM_MODULE_COLLECT_LIBRARY,
    asy = true,
    uiStat = {
      name = "\230\148\182\232\151\143-\232\151\143\229\147\129\229\186\147-\230\158\170\232\189\166"
    }
  },
  Collect_Library_DetailsPet_UIBP = {
    keyName = "Collect_Library_DetailsPet_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Collect.umg.See.Collect_Library_DetailsPet_UIBP",
    path = "/Game/Mod/Lobby/Split/Collect/Collect_Library_DetailsGoods_UIBP.Collect_Library_DetailsGoods_UIBP",
    jumpModuleID = BP_ENUM_MODULE_COLLECT_LIBRARY,
    uiStat = {
      name = "\230\148\182\232\151\143-\232\151\143\229\147\129\229\186\147-\228\188\153\228\188\180\239\188\136\229\174\160\231\137\169\239\188\137"
    }
  },
  Collect_Library_GoodWeaponCar_UIBP = {
    keyName = "Collect_Library_GoodWeaponCar_UIBP",
    isMainUI = false,
    moduleName = "GameLua.Mod.Lobby.Split.Collect.umg.See.Collect_Library_GoodWeaponCar_UIBP",
    path = "/Game/Mod/Lobby/Split/Collect/Collect_Library_GoodWeaponCar_UIBP.Collect_Library_GoodWeaponCar_UIBP",
    asy = true,
    uiStat = {
      name = "\230\148\182\232\151\143-\232\151\143\229\147\129\229\186\147-\230\158\170\232\189\166"
    }
  },
  Collect_Library_GuestState_UIBP = {
    keyName = "Collect_Library_GuestState_UIBP",
    isMainUI = false,
    moduleName = "GameLua.Mod.Lobby.Split.Collect.umg.See.Collect_Library_GuestState_UIBP",
    path = "/Game/Mod/Lobby/Split/Collect/Collect_Library_GuestState_UIBP.Collect_Library_GuestState_UIBP",
    uiStat = {
      name = "\230\148\182\232\151\143-\232\151\143\229\147\129\229\186\147-\229\174\162\230\128\129"
    }
  },
  Collect_Library_Pet_UIBP = {
    keyName = "Collect_Library_Pet_UIBP",
    isMainUI = false,
    moduleName = "GameLua.Mod.Lobby.Split.Collect.umg.See.Collect_Library_Pet_UIBP",
    path = "/Game/Mod/Lobby/Split/Collect/Collect_Library_Pet_UIBP.Collect_Library_Pet_UIBP",
    asy = true,
    uiStat = {
      name = "\230\148\182\232\151\143-\232\151\143\229\147\129\229\186\147-\228\188\153\228\188\180\239\188\136\229\174\160\231\137\169\239\188\137"
    }
  },
  Collect_Library_Theme_UIBP = {
    keyName = "Collect_Library_Theme_UIBP",
    isMainUI = false,
    moduleName = "GameLua.Mod.Lobby.Split.Collect.umg.See.Collect_Library_Theme_UIBP",
    path = "/Game/Mod/Lobby/Split/Collect/Collect_Library_Theme_UIBP.Collect_Library_Theme_UIBP",
    asy = true,
    uiStat = {
      name = "\230\148\182\232\151\143-\232\151\143\229\147\129\229\186\147-\228\184\187\233\162\152"
    }
  },
  Collect_Library_UIBP = {
    keyName = "Collect_Library_UIBP",
    isMainUI = false,
    moduleName = "GameLua.Mod.Lobby.Split.Collect.umg.See.Collect_Library_UIBP",
    path = "/Game/Mod/Lobby/Split/Collect/Collect_Library_UIBP.Collect_Library_UIBP",
    uiStat = {
      name = "\230\148\182\232\151\143-\232\151\143\229\147\129\229\186\147"
    }
  },
  Collect_Library_Vehicle_UIBP = {
    keyName = "Collect_Library_Vehicle_UIBP",
    isMainUI = false,
    moduleName = "GameLua.Mod.Lobby.Split.Collect.umg.See.Collect_Library_Vehicle_UIBP",
    path = "/Game/Mod/Lobby/Split/Collect/Collect_Library_Vehicle_UIBP.Collect_Library_Vehicle_UIBP",
    asy = true,
    uiStat = {
      name = "\230\148\182\232\151\143-\232\151\143\229\147\129\229\186\147-\232\189\189\229\133\183"
    }
  },
  Collect_Milestone_Detail_UIBP = {
    keyName = "Collect_Milestone_Detail_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Collect.umg.Milestone.Collect_Milestone_Detail_UIBP",
    path = "/Game/Mod/Lobby/Split/Collect/Collect_Milestone_Detail_UIBP.Collect_Milestone_Detail_UIBP",
    jumpModuleID = BP_ENUM_MODULE_COLLECT_MILESTONE_PREVIEW,
    uiStat = {
      name = "\231\143\141\232\151\143-\233\135\140\231\168\139\231\162\145-\233\162\132\232\167\136"
    }
  },
  Collect_Milestone_Detail_Visitor_UIBP = {
    keyName = "Collect_Milestone_Detail_Visitor_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Collect.umg.Milestone.Collect_Milestone_Detail_Visitor_UIBP",
    path = "/Game/Mod/Lobby/Split/Collect/Collect_Milestone_Detail_UIBP.Collect_Milestone_Detail_UIBP",
    jumpModuleID = BP_ENUM_MODULE_COLLECT_MILESTONE_PREVIEW,
    uiStat = {
      name = "\231\143\141\232\151\143-\233\135\140\231\168\139\231\162\145-\233\162\132\232\167\136-\229\174\162\230\128\129"
    }
  },
  Collect_Milestone_Edit_UIBP = {
    keyName = "Collect_Milestone_Edit_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Collect.umg.Milestone.Collect_Milestone_Edit_UIBP",
    path = "/Game/Mod/Lobby/Split/Collect/Collect_Milestone_Edit_UIBP.Collect_Milestone_Edit_UIBP",
    jumpModuleID = BP_ENUM_MODULE_COLLECT_MILESTONE_EDIT,
    uiStat = {
      name = "\231\143\141\232\151\143-\233\135\140\231\168\139\231\162\145-\231\188\150\232\190\145"
    }
  },
  Collect_Milestone_UIBP = {
    keyName = "Collect_Milestone_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Collect.umg.Milestone.Collect_Milestone_UIBP",
    path = "/Game/Mod/Lobby/Split/Collect/Collect_Milestone_UIBP.Collect_Milestone_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\231\143\141\232\151\143-\233\135\140\231\168\139\231\162\145"
    }
  },
  Collect_Milestone_Visitor_UIBP = {
    keyName = "Collect_Milestone_Visitor_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Collect.umg.Milestone.Collect_Milestone_Visitor_UIBP",
    path = "/Game/Mod/Lobby/Split/Collect/Collect_Milestone_UIBP.Collect_Milestone_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\231\143\141\232\151\143-\233\135\140\231\168\139\231\162\145-\229\174\162\230\128\129"
    }
  },
  Collect_Popup_CareerIntergral_UIBP = {
    keyName = "Collect_Popup_CareerIntergral_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Collect.umg.Road.Collect_Popup_CareerIntergral_UIBP",
    path = "/Game/Mod/Lobby/Split/Collect/Popup/Collect_Popup_CareerIntergral_UIBP.Collect_Popup_CareerIntergral_UIBP",
    uiStat = {
      name = "\231\143\141\232\151\143-\231\148\159\230\182\175-\231\167\175\229\136\134\232\142\183\229\143\150\229\188\185\231\170\151"
    }
  },
  Collect_Popup_LikeRecord_UIBP = {
    keyName = "Collect_Popup_LikeRecord_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Collect.umg.Room.Collect_Popup_LikeRecord_UIBP",
    path = "/Game/Mod/Lobby/Split/Collect/Popup/Collect_Popup_LikeRecord_UIBP.Collect_Popup_LikeRecord_UIBP",
    asy = true,
    uiStat = {
      name = "\230\148\182\232\151\143-\231\130\185\232\181\158\232\174\176\229\189\149\228\184\142\231\130\185\232\181\158\230\142\146\232\161\140\230\166\156"
    }
  },
  Collect_Popup_Room_UIBP = {
    keyName = "Collect_Popup_Room_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Collect.umg.Room.Collect_Popup_Room_UIBP",
    path = "/Game/Mod/Lobby/Split/Collect/Popup/Collect_Popup_Room_UIBP.Collect_Popup_Room_UIBP",
    asy = true,
    uiStat = {
      name = "\230\148\182\232\151\143-\230\148\182\232\151\143\229\174\164-\233\128\137\230\139\169\232\180\180\231\186\184"
    }
  },
  Collect_Popup_Score_UIBP = {
    keyName = "Collect_Popup_Score_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Collect.umg.Road.Collect_Popup_Score_UIBP",
    path = "/Game/Mod/Lobby/Split/Collect/Popup/Collect_Popup_Score_UIBP.Collect_Popup_Score_UIBP",
    uiStat = {
      name = "\230\148\182\232\151\143-\230\148\182\232\151\143\228\185\139\232\183\175-\232\175\180\230\152\142"
    }
  },
  Collect_Popup_TimeLimitedRank_GunList_UIBP = {
    keyName = "Collect_Popup_TimeLimitedRank_GunList_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Collect.umg.Rank.Collect_Popup_TimeLimitedRank_GunList_UIBP",
    path = "/Game/Mod/Lobby/Split/Collect/Popup/Collect_Popup_TimeLimitedRank_GunList_UIBP.Collect_Popup_TimeLimitedRank_GunList_UIBP",
    uiStat = {
      name = "\231\143\141\232\151\143-\231\143\141\232\151\143\230\142\146\232\161\140-\231\167\175\229\136\134\232\142\183\229\143\150\229\188\185\231\170\151-\231\137\169\229\147\129\229\136\151\232\161\168"
    }
  },
  Collect_Popup_TimeLimitedRank_UIBP = {
    keyName = "Collect_Popup_TimeLimitedRank_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Collect.umg.Rank.Collect_Popup_TimeLimitedRank_UIBP",
    path = "/Game/Mod/Lobby/Split/Collect/Popup/Collect_Popup_TimeLimitedRank_UIBP.Collect_Popup_TimeLimitedRank_UIBP",
    uiStat = {
      name = "\231\143\141\232\151\143-\231\143\141\232\151\143\230\142\146\232\161\140-\231\167\175\229\136\134\232\142\183\229\143\150\229\188\185\231\170\151"
    }
  },
  Collect_Popup_UIBP = {
    keyName = "Collect_Popup_UIBP",
    moduleName = "GameLua.Mod.Lobby.Base.Collect.umg.Tips.Collect_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Universal_Popup/Common_Popup_UIBP_4.Common_Popup_UIBP_4",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\231\143\141\232\151\143\229\165\150\229\138\177-\229\143\179\228\184\139\232\167\146\229\188\185\231\170\151"
    }
  },
  Collect_Road_UIBP = {
    keyName = "Collect_Road_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Collect.umg.Road.Collect_Road_UIBP",
    path = "/Game/Mod/Lobby/Split/Collect/Collect_Road_UIBP.Collect_Road_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\230\148\182\232\151\143-\230\148\182\232\151\143\228\185\139\232\183\175"
    }
  },
  Collect_Room_DressUp_UIBP = {
    keyName = "Collect_Room_DressUp_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Collect.umg.Room.Collect_Room_DressUp_UIBP",
    path = "/Game/Mod/Lobby/Split/Collect/Collect_Room_DressUp_UIBP.Collect_Room_DressUp_UIBP",
    asy = true,
    uiStat = {
      name = "\230\148\182\232\151\143-\230\148\182\232\151\143\229\174\164-\233\128\137\230\139\169\232\180\180\231\186\184\232\131\140\230\153\175"
    }
  },
  Collect_Room_UIBP = {
    keyName = "Collect_Room_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Collect.umg.Room.Collect_Room_UIBP",
    path = "/Game/Mod/Lobby/Split/Collect/Collect_Room_UIBP.Collect_Room_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\230\148\182\232\151\143-\230\148\182\232\151\143\229\174\164"
    }
  },
  Collect_Season_UIBP = {
    keyName = "Collect_Season_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Collect.umg.Season.Collect_Season_UIBP",
    path = "/Game/Mod/Lobby/Split/Collect/Collect_Season_UIBP.Collect_Season_UIBP",
    jumpModuleID = BP_ENUM_MODULE_COLLECT_SEASON_REVIEW,
    uiStat = {
      name = "\230\148\182\232\151\143\229\155\158\233\161\190\231\149\140\233\157\162"
    }
  },
  Collect_TimeLimitedRanking_UIBP = {
    keyName = "Collect_TimeLimitedRanking_UIBP",
    moduleName = "GameLua.Mod.Lobby.Split.Collect.umg.Rank.Collect_TimeLimitedRanking_UIBP",
    path = "/Game/Mod/Lobby/Split/Collect/Collect_TimeLimitedRanking_UIBP.Collect_TimeLimitedRanking_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\231\143\141\232\151\143-\231\143\141\232\151\143\230\142\146\232\161\140"
    }
  },
  Crate_GuaranteeMechanism_Collect_UIBP = {
    keyName = "Crate_GuaranteeMechanism_Collect_UIBP",
    moduleName = "GameLua.Mod.Lobby.Base.Collect.umg.LevelUP.Crate_GuaranteeMechanism_Collect_UIBP",
    path = "/Game/UMG/UI_BP/Store/Item/Crate_GuaranteeMechanism_Collect_UIBP.Crate_GuaranteeMechanism_Collect_UIBP",
    containerName = UIContainers.Top,
    AndroidBackType = EAndroidBackType.Skip,
    zOrder = EFixedZOrder.GuaranteeMechanism,
    asy = true,
    uiStat = {
      name = "\231\143\141\232\151\143\231\167\175\229\136\134\230\143\144\229\141\135\232\191\155\229\186\166"
    }
  },
  ExpressionPop_New_UIBP = {
    keyName = "ExpressionPop_New_UIBP",
    moduleName = "client.slua.umg.Souvenirs.ExpressionPop_New_UIBP",
    path = "/Game/UMG/UI_BP/Lobby/ExpressionPop_New_UIBP.ExpressionPop_New_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    uiStat = {
      name = "310\229\164\167\229\142\133\232\161\168\230\131\133\229\177\149\231\164\186"
    }
  },
  Guide_Tips_UIBP = {
    keyName = "Guide_Tips_UIBP",
    moduleName = "client.slua.umg.newbie.Guide_Tips_UIBP",
    path = "/Game/UMG/UI_BP/Souvenirs/Guide_Tips_UIBP.Guide_Tips_UIBP",
    isMainUI = false,
    isSingleton = false,
    AndroidBackType = EAndroidBackType.Ban,
    asy = true,
    uiStat = {
      name = "\229\188\149\229\175\188\230\176\148\230\179\161"
    }
  },
  Pet_LobbyControl_Item_01_UIBP = {
    keyName = "Pet_LobbyControl_Item_01_UIBP",
    moduleName = "client.slua.umg.Souvenirs.Pet_LobbyControl_Item_01_UIBP",
    path = "/Game/UMG/UI_BP/Pet/Pet_Item/Pet_LobbyControl_Item_01_UIBP.Pet_LobbyControl_Item_01_UIBP",
    uiStat = {
      name = "\232\161\168\230\131\133\229\177\149\231\164\186Item"
    }
  },
  Souvenirs_Dagger_Share_UIBP = {
    keyName = "Souvenirs_Dagger_Share_UIBP",
    moduleName = "client.slua.umg.Souvenirs.Share_Souviners_Special_Colletion",
    path = "/Game/UMG/UI_BP/Souvenirs/Item/Souvenirs_Dagger_Item_UIBP.Souvenirs_Dagger_Item_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\232\151\143\229\147\129-\230\151\182\228\185\139\229\136\131-\232\175\129\228\185\166\229\136\134\228\186\171"
    }
  },
  Souvenirs_Main_Dagger_UIBP = {
    keyName = "Souvenirs_Main_Dagger_UIBP",
    moduleName = "client.slua.umg.Souvenirs.Souvenirs_Main_Dagger_UIBP",
    path = "/Game/UMG/UI_BP/Souvenirs/Souvenirs_Main_Dagger_UIBP.Souvenirs_Main_Dagger_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    IsMainUI = false,
    AndroidBackType = EAndroidBackType.Skip,
    uiStat = {
      name = "\231\137\185\230\174\138\232\151\143\229\147\129-\228\184\187\231\149\140\233\157\162"
    }
  },
  Souvenirs_Main_Dagger_UIBP_LOD01 = {
    keyName = "Souvenirs_Main_Dagger_UIBP_LOD01",
    moduleName = "client.slua.umg.Souvenirs.Souvenirs_Main_Dagger_UIBP",
    path = "/Game/UMG/UI_BP/Souvenirs/Souvenirs_Main_Dagger_UIBP_LOD1.Souvenirs_Main_Dagger_UIBP_LOD1",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    uiStat = {
      name = "\231\137\185\230\174\138\232\151\143\229\147\129-\228\184\187\231\149\140\233\157\162-\228\189\142\231\171\175\230\156\186"
    }
  },
  Souvenirs_Main_PMGC_UIBP = {
    keyName = "Souvenirs_Main_PMGC_UIBP",
    moduleName = "client.slua.umg.Souvenirs.Souvenirs_Main_PMGC_UIBP",
    path = "/Game/UMG/UI_BP/Souvenirs/Souvenirs_Main_PMGC_UIBP.Souvenirs_Main_PMGC_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    IsMainUI = false,
    AndroidBackType = EAndroidBackType.Skip,
    uiStat = {
      name = "PMGC\232\151\143\229\147\129-\231\149\140\233\157\162"
    }
  },
  Souvenirs_Main_UIBP = {
    keyName = "Souvenirs_Main_UIBP",
    moduleName = "client.slua.umg.Souvenirs.Souvenirs_Main_UIBP",
    path = "/Game/UMG/UI_BP/Souvenirs/Souvenirs_Main_UIBP.Souvenirs_Main_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    asy = true,
    uiStat = {
      name = "\232\151\143\229\147\129-\228\184\187\231\149\140\233\157\162"
    }
  },
  Souvenirs_NewGuide_Tips_UIBP = {
    keyName = "Souvenirs_NewGuide_Tips_UIBP",
    moduleName = "client.slua_ui_framework.base",
    path = "/Game/UMG/UI_BP/Souvenirs/Souvenirs_NewGuide_Tips_UIBP.Souvenirs_NewGuide_Tips_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    isMainUI = false,
    uiStat = {
      name = "\232\151\143\229\147\129-\232\151\143\229\147\129\229\188\149\229\175\188"
    }
  },
  Souvenirs_Popup_Notes_UIBP = {
    keyName = "Souvenirs_Popup_Notes_UIBP",
    moduleName = "client.slua.umg.Souvenirs.Souvenirs_Popup_Notes_UIBP",
    path = "/Game/UMG/UI_BP/Souvenirs/Souvenirs_Popup_Notes_UIBP.Souvenirs_Popup_Notes_UIBP",
    loadFromPool = EUIConfigPoolType.None,
    uiStat = {
      name = "\232\151\143\229\147\129-\230\139\141\232\132\184"
    }
  },
  Souvenirs_Popup_Share_UIBP = {
    keyName = "Souvenirs_Popup_Share_UIBP",
    moduleName = "client.slua.umg.Souvenirs.Souvenirs_Popup_Share_UIBP",
    path = "/Game/UMG/UI_BP/Souvenirs/Souvenirs_Popup_Share_UIBP.Souvenirs_Popup_Share_UIBP",
    uiStat = {
      name = "\232\151\143\229\147\129-\232\151\143\229\147\129\232\181\160\233\128\129"
    }
  },
  Souvenirs_T_Certificate_UIBP = {
    keyName = "Souvenirs_T_Certificate_UIBP",
    moduleName = "client.slua.umg.Souvenirs.Souvenirs_T_Certificate_UIBP",
    path = "/Game/UMG/UI_BP/Souvenirs/Souvenirs_T/Souvenirs_T_Certificate_UIBP_2.Souvenirs_T_Certificate_UIBP_2",
    AndroidBackType = EAndroidBackType.Ban,
    isMainUI = false,
    uiStat = {
      name = "\232\151\143\229\147\129-t-\232\175\129\228\185\166"
    }
  },
  Souvenirs_T_Certificate_UIBP_New = {
    keyName = "Souvenirs_T_Certificate_UIBP_New",
    moduleName = "client.slua.umg.Souvenirs.Souvenirs_T_Certificate_UIBP_New",
    path = "/Game/UMG/UI_BP/Souvenirs/Souvenirs_T/Souvenirs_T_Certificate_UIBP.Souvenirs_T_Certificate_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    isMainUI = false,
    uiStat = {
      name = "\232\151\143\229\147\129-t-\232\175\129\228\185\166"
    }
  },
  Souvenirs_T_Main_UIBP = {
    keyName = "Souvenirs_T_Main_UIBP",
    moduleName = "client.slua.umg.Souvenirs.Souvenirs_T_Main_UIBP",
    path = "/Game/UMG/UI_BP/Souvenirs/Souvenirs_T/Souvenirs_T_Main_UIBP.Souvenirs_T_Main_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    uiStat = {
      name = "\232\151\143\229\147\129-t\228\184\187\231\149\140\233\157\162"
    }
  },
  Souvenirs_T_Tab_UIBP = {
    keyName = "Souvenirs_T_Tab_UIBP",
    moduleName = "client.slua.umg.Souvenirs.Souvenirs_T_Tab_UIBP",
    path = "/Game/UMG/UI_BP/Souvenirs/Souvenirs_T/Souvenirs_T_Tab_UIBP.Souvenirs_T_Tab_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    uiStat = {
      name = "\232\151\143\229\147\129-t\232\151\143\229\147\129\233\128\137\230\139\169"
    }
  },
  Souvenirs_Tab_UIBP = {
    keyName = "Souvenirs_Tab_UIBP",
    moduleName = "client.slua.umg.Souvenirs.Souvenirs_Tab_UIBP",
    path = "/Game/UMG/UI_BP/Souvenirs/Souvenirs_Tab_UIBP.Souvenirs_Tab_UIBP",
    jumpModuleID = BP_ENUM_MODULE_LOBBY_SOUVENIRS,
    uiStat = {
      name = "\232\151\143\229\147\129-\232\151\143\229\147\129\233\128\137\230\139\169"
    }
  },
  Souvenirs_Tips_UIBP = {
    keyName = "Souvenirs_Tips_UIBP",
    containerName = UIContainers.Top,
    moduleName = "client.slua.umg.Souvenirs.Souvenirs_Collection_Tips_Item_UIBP",
    path = "/Game/UMG/UI_BP/Souvenirs/Item/Souvenirs_Main_Item_UIBP.Souvenirs_Main_Item_UIBP",
    uiStat = {
      name = "\232\151\143\229\147\129-\231\137\185\230\174\138\232\151\143\229\147\129-\232\151\143\229\147\129\230\144\156\233\155\134tips"
    }
  },
  Theme_Collection_Popop_UIBP = {
    keyName = "Theme_Collection_Popop_UIBP",
    moduleName = "client.slua.umg.Theme.New.Popup.Theme_Collection_Popop_UIBP",
    path = "/Game/Arts_UI/FromUMG/Theme/Popup/Theme_Collection_Popop_UIBP.Theme_Collection_Popop_UIBP",
    uiStat = {
      name = "\228\184\187\233\162\152\231\179\187\231\187\159-\231\137\136\230\156\172\228\187\139\231\187\141-\232\151\143\229\147\129\229\188\185\231\170\151"
    }
  },
  VehiclePlacement = {
    keyName = "VehiclePlacement",
    moduleName = "client.slua.umg.vehicle.collect.VehiclePlacement",
    path = "/Game/UMG/UI_BP/Vehicle/IllustratedBook/310Vehicle/310Vehic310Vehicle_IllustratedBook_UIBP.310Vehic310Vehicle_IllustratedBook_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\232\183\145\232\189\166\230\148\182\233\155\134\229\155\190\233\137\180-\232\189\166\232\190\134\230\145\134\230\148\190\233\155\134\229\144\136\232\147\157\229\155\190\230\168\161\230\157\191"
    }
  },
  Vehicle_IllustratedBook_UIBP = {
    keyName = "Vehicle_IllustratedBook_UIBP",
    moduleName = "client.slua.umg.vehicle.collect.Vehicle_IllustratedBook_UIBP",
    path = "/Game/UMG/UI_BP/Vehicle/IllustratedBook/Vehicle_IllustratedBook_UIBP.Vehicle_IllustratedBook_UIBP",
    uiStat = {
      name = "\232\183\145\232\189\166\230\148\182\233\155\134\229\155\190\233\137\180"
    }
  },
  collect_inherit_friend_page = {
    keyName = "collect_inherit_friend_page",
    moduleName = "GameLua.Mod.Lobby.Base.Collect.umg.Inherit.Page.collect_inherit_friend_page",
    path = "/Game/Mod/Lobby/Split/Collect/Popup/Collect_Popup_SelectInheritor_UIBP.Collect_Popup_SelectInheritor_UIBP",
    isSingleton = true,
    asy = true,
    containerName = UIContainers.Top,
    uiStat = {
      name = "\228\188\160\230\137\191\231\137\185\230\157\131 \233\128\137\230\139\169\229\165\189\229\143\139\231\149\140\233\157\162"
    }
  },
  collect_inherit_popup_page = {
    keyName = "collect_inherit_popup_page",
    moduleName = "GameLua.Mod.Lobby.Base.Collect.umg.Inherit.Page.collect_inherit_popup_page",
    path = "/Game/Mod/Lobby/Split/Collect/Popup/Collect_Popup_InheritancePrivileges_UIBP.Collect_Popup_InheritancePrivileges_UIBP",
    isSingleton = true,
    asy = true,
    containerName = UIContainers.Top,
    uiStat = {
      name = "\228\188\160\230\137\191\231\137\185\230\157\131 \229\188\185\231\170\151\231\149\140\233\157\162"
    }
  },
  collect_inherit_share_not_using = {
    keyName = "collect_inherit_share_not_using",
    moduleName = "GameLua.Mod.Lobby.Base.Collect.umg.Inherit.Page.collect_inherit_share_not_using",
    path = "/Game/Mod/Lobby/Split/Collect/ShareInterface/Collect_ShareInterface_InheritancePrivileges_Style1_UIBP.Collect_ShareInterface_InheritancePrivileges_Style1_UIBP",
    isSingleton = true,
    asy = true,
    uiStat = {
      name = "\228\188\160\230\137\191\231\137\185\230\157\131 \229\136\134\228\186\171 \228\187\133\229\177\149\231\164\186\232\135\170\229\183\177"
    }
  },
  collect_inherit_share_using = {
    keyName = "collect_inherit_share_using",
    moduleName = "GameLua.Mod.Lobby.Base.Collect.umg.Inherit.Page.collect_inherit_share_using",
    path = "/Game/Mod/Lobby/Split/Collect/ShareInterface/Collect_ShareInterface_InheritancePrivileges_Style2_UIBP.Collect_ShareInterface_InheritancePrivileges_Style2_UIBP",
    isSingleton = true,
    asy = true,
    uiStat = {
      name = "\228\188\160\230\137\191\231\137\185\230\157\131 \229\136\134\228\186\171 \229\177\149\231\164\186\229\143\140\228\186\186"
    }
  },
  collect_inherit_tip = {
    keyName = "collect_inherit_tip",
    moduleName = "GameLua.Mod.Lobby.Base.Collect.umg.Inherit.collect_inherit_tip",
    path = "/Game/Mod/Lobby/Split/Collect/Item/Collect_Library_Tips.Collect_Library_Tips",
    isMainUI = false,
    isSingleton = true,
    uiStat = {
      name = "\228\188\160\230\137\191\231\137\185\230\157\131 \229\133\165\229\143\163 \230\143\144\231\164\186"
    }
  }
}
return souvenirs_ui_configs