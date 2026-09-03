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
local corps_ui_configs = {
  Chat_FriendInfo_CorpTag_UIBP = {
    keyName = "Chat_FriendInfo_CorpTag_UIBP",
    moduleName = "client.slua.umg.lobby_chat.item.MemberListSubItem.Chat_FriendInfo_CorpTag_UIBP",
    path = "/Game/UMG/UI_BP/LobbyChat/Item/Chat_MemberListSubItem/Chat_FriendInfo_CorpTag_UIBP.Chat_FriendInfo_CorpTag_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\232\129\138\229\164\169-\229\165\189\229\143\139\228\191\161\230\129\175-\229\134\155\229\155\162\230\160\135\231\173\190"
    },
    loadFromPool = EUIConfigPoolType.chat_pool
  },
  Common_Popup_Corps_LeReplaceEv = {
    keyName = "Common_Popup_Corps_LeReplaceEv",
    moduleName = "client.slua.umg.corps.Common_Popup_Corps_LeReplaceEv",
    path = "/Game/UMG/UI_BP/Common/Popup/Theme/Common_Popup_Theme_Explain_UIBP.Common_Popup_Theme_Explain_UIBP",
    containerName = UIContainers.Top,
    asy = true,
    uiStat = {
      name = "\229\134\155\229\155\162\232\191\155\229\140\150\229\134\155\229\155\162\230\155\191\230\141\162\228\184\186\228\188\145\233\151\178\229\134\155\229\155\162\229\188\149\229\175\188"
    }
  },
  CorpsAnnouncement = {
    keyName = "CorpsAnnouncement",
    moduleName = "client.slua.umg.corps.corps_announcement",
    path = "/Game/UMG/UI_BP/Corps/Corps_Announcement_UIBP.Corps_Announcement_UIBP",
    uiStat = {
      name = "\229\134\155\229\155\162-\229\133\172\229\145\138\230\160\143"
    },
    isSingleton = false
  },
  Corps_Homepagenew_Star = {
    keyName = "Corps_Homepagenew_Star",
    moduleName = "client.slua.umg.corps.Corps_Homepagenew_Star",
    path = "/Game/UMG/UI_BP/Corps/Corps_Homepagenew_Star.Corps_Homepagenew_Star",
    uiStat = {
      name = "\229\134\155\229\155\162\228\184\187\233\161\181-\229\134\155\229\155\162\230\152\142\230\152\159"
    },
    isSingleton = false
  },
  Corps_Homepagenew_Chat_Item_UIBP = {
    keyName = "Corps_Homepagenew_Chat_Item_UIBP",
    moduleName = "client.slua.umg.corps.item.corps_homepage_chat",
    path = "/Game/UMG/UI_BP/Corps/item/Corps_Homepagenew_Chat_Item_UIBP.Corps_Homepagenew_Chat_Item_UIBP",
    uiStat = {
      name = "\229\134\155\229\155\162\228\184\187\233\161\181-\229\134\155\229\155\162\232\129\138\229\164\169"
    },
    isSingleton = false
  },
  CorpsAnnouncementPopup = {
    keyName = "CorpsAnnouncementPopup",
    moduleName = "client.slua.umg.corps.corps_announcement_popup",
    path = "/Game/UMG/UI_BP/Corps/Corps_Declaration_Popup_UIBP.Corps_Declaration_Popup_UIBP",
    uiStat = {
      name = "\229\134\155\229\155\162-\228\191\174\230\148\185\229\133\172\229\145\138\229\188\185\231\170\151"
    }
  },
  CorpsHomepage3 = {
    keyName = "CorpsHomepage3",
    moduleName = "client.slua.umg.corps.corps_homepage_new2_3",
    path = "/Game/UMG/UI_BP/Corps/Corps_Homepagenew_02_03_UIBP.Corps_Homepagenew_02_03_UIBP",
    uiStat = {
      name = "\229\134\155\229\155\162-\228\184\187\233\161\181-\228\184\187\233\161\1813"
    },
    isSingleton = false
  },
  CorpsHomepageNewUI2 = {
    keyName = "CorpsHomepageNewUI2",
    moduleName = "client.slua.umg.corps.corps_homepage_new2",
    path = "/Game/UMG/UI_BP/Corps/Corps_Homepagenew_02_UIBP.Corps_Homepagenew_02_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\134\155\229\155\162-\228\184\187\233\161\181"
    }
  },
  CorpsInvitation_New_UIBP_2 = {
    keyName = "CorpsInvitation_New_UIBP_2",
    moduleName = "client.slua.umg.corps.item.CorpsInvitation_New_UIBP_2",
    path = "/Game/UMG/UI_BP/Corps/CorpsInvitation_New_UIBP_2.CorpsInvitation_New_UIBP_2",
    uiStat = {
      name = "\229\134\155\229\155\162\229\144\141\231\137\135-\229\136\134\228\186\171"
    }
  },
  CorpsInvitation_Share_UIBP = {
    keyName = "CorpsInvitation_Share_UIBP",
    moduleName = "client.slua.umg.corps.item.CorpsInvitation_Share_UIBP",
    path = "/Game/UMG/UI_BP/Corps/CorpsInvitation_Share_UIBP.CorpsInvitation_Share_UIBP",
    uiStat = {
      name = "\229\134\155\229\155\162-\228\184\187\233\161\181-\229\136\134\228\186\171"
    },
    isSingleton = false
  },
  CorpsTabMgr = {
    keyName = "CorpsTabMgr",
    moduleName = "client.slua.umg.corps.corps_tab_mgr",
    path = "/Game/UMG/UI_BP/Corps/Corps_TabUIBP.Corps_TabUIBP",
    jumpModuleID = BP_ENUM_MODULE_CORPS,
    asy = true,
    uiStat = {
      name = "\229\134\155\229\155\162-\233\161\181\231\173\190\231\174\161\231\144\134"
    }
  },
  Corps_Activity_Filter_Menu_UIBP = {
    keyName = "Corps_Activity_Filter_Menu_UIBP",
    moduleName = "client.slua.umg.corps.corps_gift_change.Corps_Activity_Filter_Menu_UIBP",
    path = "/Game/UMG/UI_BP/Corps/item/Corps_Activity_Filter_Menu_UIBP.Corps_Activity_Filter_Menu_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\229\134\155\229\155\162-\228\184\139\230\139\137\230\161\134"
    }
  },
  Corps_Appointment_pop_UIBP = {
    keyName = "Corps_Appointment_pop_UIBP",
    moduleName = "client.slua.umg.corps.Corps_Appointment_pop_UIBP",
    path = "/Game/UMG/UI_BP/Corps/item/Corps_Appointment_pop_UIBP_2.Corps_Appointment_pop_UIBP_2",
    uiStat = {
      name = "\229\134\155\229\155\162\230\136\144\229\145\152\228\187\187\229\145\189"
    }
  },
  Corps_AutoInvite_UIBP = {
    keyName = "Corps_AutoInvite_UIBP",
    moduleName = "client.slua.umg.corps.Corps_AutoInvite_UIBP",
    path = "/Game/UMG/UI_BP/Corps/item/corps_R_POPUIBP_2.corps_R_POPUIBP_2",
    uiStat = {
      name = "\229\134\155\229\155\162\230\142\168\232\141\144\230\136\144\229\145\152"
    }
  },
  Corps_Brilliance_Popup_UIBP = {
    keyName = "Corps_Brilliance_Popup_UIBP",
    moduleName = "client.slua.umg.corps.Corps_Brilliance_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Corps/Corps_Brilliance_Popup_UIBP.Corps_Brilliance_Popup_UIBP",
    uiStat = {
      name = "\229\134\155\229\155\162\231\166\143\229\136\169\228\184\187\233\161\181\233\157\162"
    }
  },
  Corps_Energy_Mission_Has_Type = {
    keyName = "Corps_Energy_Mission_Has_Type",
    moduleName = "client.slua.umg.corps.corps_energy_mission_has_type",
    path = "/Game/UMG/UI_BP/Corps/Corps_TypeTask_UIBP.Corps_TypeTask_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\134\155\229\155\162-\231\155\174\230\160\135"
    }
  },
  Corps_Energy_Mission_No_Type = {
    keyName = "Corps_Energy_Mission_No_Type",
    moduleName = "client.slua.umg.corps.corps_energy_mission_no_type",
    path = "/Game/UMG/UI_BP/Corps/Corps_TypeSet_UIBP.Corps_TypeSet_UIBP",
    uiStat = {
      name = "\229\134\155\229\155\162-\231\155\174\230\160\135\228\187\187\229\138\161-\230\156\170\232\174\190\229\174\154\231\155\174\230\160\135"
    }
  },
  Corps_Energy_Type_Set = {
    keyName = "Corps_Energy_Type_Set",
    moduleName = "client.slua.umg.corps.corps_energy_type_set",
    path = "/Game/UMG/UI_BP/Corps/Corps_ManageType_Item_UIBP.Corps_ManageType_Item_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\229\134\155\229\155\162\231\174\161\231\144\134-\232\131\189\233\135\143\231\177\187\229\158\139\232\174\190\231\189\174"
    }
  },
  Corps_Get_Popup_UIBP = {
    keyName = "Corps_Get_Popup_UIBP",
    moduleName = "client.slua.umg.corps.corps_welfare.Corps_Get_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Corps/Corps_Get_Popup_UIBP.Corps_Get_Popup_UIBP",
    uiStat = {
      name = "\229\134\155\229\155\162\231\166\143\229\136\169\228\184\187\233\161\181\233\157\162"
    }
  },
  Corps_Homepagenew_Notice_Popup_Item_UIBP = {
    keyName = "Corps_Homepagenew_Notice_Popup_Item_UIBP",
    moduleName = "client.slua.umg.corps.item.Corps_Homepagenew_Notice_Popup_Item_UIBP",
    path = "/Game/UMG/UI_BP/Corps/item/Corps_Homepagenew_Notice_Popup_Item_UIBP.Corps_Homepagenew_Notice_Popup_Item_UIBP",
    uiStat = {
      name = "\229\134\155\229\155\162-\228\184\187\233\161\181-\229\177\149\231\164\186\229\133\172\229\145\138"
    }
  },
  Corps_Homepagenew_Pop_UIBP = {
    keyName = "Corps_Homepagenew_Pop_UIBP",
    moduleName = "client.slua.umg.corps.item.Corps_Homepagenew_Pop_UIBP",
    path = "/Game/UMG/UI_BP/Corps/item/Corps_Homepagenew_SetStar_Popup_Item_UIBP.Corps_Homepagenew_SetStar_Popup_Item_UIBP",
    uiStat = {
      name = "\229\134\155\229\155\162\228\184\187\233\161\181\233\157\162-\229\134\155\229\155\162\230\152\142\230\152\159\232\174\190\231\189\174\229\188\185\231\170\151"
    }
  },
  Corps_Homepagenew_TopPopupTips_Item_UIBP = {
    keyName = "Corps_Homepagenew_TopPopupTips_Item_UIBP",
    moduleName = "client.slua.umg.corps.item.Corps_Homepagenew_TopPopupTips_Item_UIBP",
    path = "/Game/UMG/UI_BP/Corps/item/Corps_Homepagenew_TopPopupTips_Item_UIBP.Corps_Homepagenew_TopPopupTips_Item_UIBP",
    uiStat = {
      name = "\229\134\155\229\155\162-\232\129\138\229\164\169-\230\155\191\230\141\162\231\189\174\233\161\182\230\182\136\230\129\175\229\188\185\231\170\151"
    }
  },
  Corps_LegionIcon_UIBP = {
    keyName = "Corps_LegionIcon_UIBP",
    moduleName = "client.slua.umg.corps.Corps_LegionIcon_UIBP",
    path = "/Game/UMG/UI_BP/Corps/Corps_LegionIcon_UIBP_2.Corps_LegionIcon_UIBP_2",
    isSingleton = false,
    uiStat = {
      name = "\229\134\155\229\155\162\229\134\155\229\155\162\229\155\190\230\160\135"
    }
  },
  Corps_Manage_UIBP = {
    keyName = "Corps_Manage_UIBP",
    moduleName = "client.slua.umg.corps.Corps_Manage_UIBP",
    path = "/Game/UMG/UI_BP/Corps/item/Corps_Manage_UIBP.Corps_Manage_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\229\134\155\229\155\162\229\174\161\230\137\185\233\128\137\233\161\185"
    }
  },
  Corps_Nation = {
    keyName = "Corps_Nation",
    moduleName = "client.slua.umg.corps.corps_nation_select",
    path = "/Game/UMG/UI_BP/Corps/Corps_Countryarea_UIBP.Corps_Countryarea_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\229\134\155\229\155\162\231\174\161\231\144\134-\230\151\151\229\184\156"
    }
  },
  Corps_RankAward_UIBP = {
    keyName = "Corps_RankAward_UIBP",
    moduleName = "client.slua.umg.corps.Corps_RankAward_UIBP",
    path = "/Game/UMG/UI_BP/Corps/item/Corps_WeeklyRanking_Item_UIBP.Corps_WeeklyRanking_Item_UIBP",
    uiStat = {
      name = "\229\134\155\229\155\162\232\181\155\229\173\163\229\165\150\229\138\177"
    }
  },
  Corps_Rank_Reward = {
    keyName = "Corps_Rank_Reward",
    moduleName = "client.slua.umg.corps.corps_rank_reward",
    path = "/Game/UMG/UI_BP/Corps/Corps_Rewards_Popup_UIBP.Corps_Rewards_Popup_UIBP",
    uiStat = {
      name = "\229\134\155\229\155\162-\230\142\146\232\161\140\230\166\156\229\165\150\229\138\177"
    }
  },
  Corps_Report_Popup_UIBP = {
    keyName = "Corps_Report_Popup_UIBP",
    moduleName = "client.slua.umg.corps.Corps_Report_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Corps/Corps_Report_Popup_UIBP.Corps_Report_Popup_UIBP",
    uiStat = {
      name = "\229\134\155\229\155\162\228\184\190\230\138\165\233\161\181\233\157\162"
    }
  },
  Corps_Setting = {
    keyName = "Corps_Setting",
    moduleName = "client.slua.umg.corps.corps_setting",
    path = "/Game/UMG/UI_BP/Corps/Corps_ManageBlock_UIBP.Corps_ManageBlock_UIBP",
    uiStat = {
      name = "\229\134\155\229\155\162\231\174\161\231\144\134"
    }
  },
  Corps_Shop_UIBP = {
    keyName = "Corps_Shop_UIBP",
    moduleName = "client.slua.umg.corps.Corps_Shop_UIBP",
    path = "/Game/UMG/UI_BP/Corps/Corps_Shop_UIBP_2.Corps_Shop_UIBP_2",
    isMainUI = false,
    uiStat = {
      name = "\229\134\155\229\155\162-\229\149\134\229\159\142"
    }
  },
  Corps_Star_pop_UIBP = {
    keyName = "Corps_Star_pop_UIBP",
    moduleName = "client.slua.umg.corps.item.Corps_Star_pop_UIBP",
    path = "/Game/UMG/UI_BP/Corps/item/Corps_Homepagenew_SetStarName_Popup_Item_UIBP.Corps_Homepagenew_SetStarName_Popup_Item_UIBP",
    uiStat = {
      name = "\228\191\161\230\129\175\233\161\181\233\157\162-\229\134\155\229\155\162\230\152\142\230\152\159\232\174\190\231\189\174\229\188\185\231\170\151"
    }
  },
  Corps_Type_Task_Popup = {
    keyName = "Corps_Type_Task_Popup",
    moduleName = "client.slua.umg.corps.corps_type_task_popup",
    path = "/Game/UMG/UI_BP/Corps/Corps_TypeTask_RewardPopup_UIBP.Corps_TypeTask_RewardPopup_UIBP",
    uiStat = {
      name = "\229\134\155\229\155\162-\231\155\174\230\160\135-\229\165\150\229\138\177\232\175\166\230\131\133"
    }
  },
  CropsTraining_Rank_UIBP = {
    keyName = "CropsTraining_Rank_UIBP",
    moduleName = "client.slua.umg.corps.corps_training.CropsTraining_Rank_UIBP",
    path = "/Game/UMG/UI_BP/Corps/CropsTraining_Rank_UIBP.CropsTraining_Rank_UIBP",
    uiStat = {
      name = "\229\134\155\229\155\162-\228\187\138\230\151\165\231\137\185\232\174\173-\230\142\146\232\161\140\230\166\156"
    }
  },
  CropsTraining_UIBP = {
    keyName = "CropsTraining_UIBP",
    moduleName = "client.slua.umg.corps.corps_training.CropsTraining_UIBP",
    path = "/Game/UMG/UI_BP/Corps/CropsTraining_UIBP.CropsTraining_UIBP",
    jumpModuleID = BP_ENUM_MODULE_CORPS_TRAINING,
    uiStat = {
      name = "\229\134\155\229\155\162-\228\187\138\230\151\165\231\137\185\232\174\173"
    }
  },
  NewCorpsSlap = {
    keyName = "NewCorpsSlap",
    moduleName = "client.slua.umg.corps.new_corps_slap",
    path = "/Game/UMG/UI_BP/Corps/Corps_SlapType_UIBP.Corps_SlapType_UIBP",
    asy = true,
    uiStat = {
      name = "\229\134\155\229\155\162-\230\139\141\232\132\184\229\155\190"
    }
  },
  RecruitList_Item02_UIBP = {
    keyName = "RecruitList_Item02_UIBP",
    moduleName = "client.slua_ui_framework.base",
    path = "/Game/UMG/UI_BP/Corps/item/RecruitList_Item02_UIBP.RecruitList_Item02_UIBP",
    isSingleton = false,
    isMainUI = false
  },
  RecruitList_Item_UIBP = {
    keyName = "RecruitList_Item_UIBP",
    moduleName = "client.slua_ui_framework.base",
    path = "/Game/UMG/UI_BP/Corps/item/RecruitList_Item_UIBP.RecruitList_Item_UIBP",
    isSingleton = false,
    isMainUI = false
  },
  corps_applylist = {
    keyName = "corps_applylist",
    moduleName = "client.slua.umg.corps.corps_applylist",
    path = "/Game/UMG/UI_BP/Corps/item/Corps_pop_Applist_UIBP.Corps_pop_Applist_UIBP",
    uiStat = {
      name = "\229\134\155\229\155\162-\229\134\155\229\155\162\231\148\179\232\175\183"
    }
  },
  corps_create = {
    keyName = "corps_create",
    moduleName = "client.slua.umg.corps.corps_create",
    path = "/Game/UMG/UI_BP/Corps/Corps_createItem_UIBP.Corps_CreateItem_UIBP",
    uiStat = {
      name = "\229\134\155\229\155\162-\229\134\155\229\155\162\229\136\155\229\187\186"
    },
    isMainUI = false
  },
  corps_energy_type_popup = {
    keyName = "corps_energy_type_popup",
    moduleName = "client.slua.umg.corps.corps_energy_type_popup",
    path = "/Game/UMG/UI_BP/Corps/Corps_Create_Type_UIBP.Corps_Create_Type_UIBP",
    uiStat = {
      name = "\229\134\155\229\155\162\229\136\155\229\187\186-\229\177\158\230\128\167\229\188\185\231\170\151"
    }
  },
  corps_fight_main = {
    keyName = "corps_fight_main",
    moduleName = "client.slua.umg.corps.corps_fight.corps_fight_main",
    path = "/Game/UMG/UI_BP/Corps/Corps_Confrontation/Corps_Confrontation_occupied_UIBP.Corps_Confrontation_occupied_UIBP",
    uiStat = {
      name = "\229\134\155\229\155\162\229\175\185\230\138\151\230\136\152\228\184\187\231\149\140\233\157\162"
    }
  },
  corps_fight_member_rank = {
    keyName = "corps_fight_member_rank",
    moduleName = "client.slua.umg.corps.corps_fight.corps_fight_member_rank",
    path = "/Game/UMG/UI_BP/Corps/Corps_Confrontation/Confrontation_Rank_UIBP.Confrontation_Rank_UIBP",
    uiStat = {
      name = "\229\134\155\229\155\162\229\175\185\230\138\151\230\136\152\230\136\144\229\145\152\232\180\161\231\140\174\230\142\146\232\161\140\231\149\140\233\157\162"
    }
  },
  corps_fight_overview = {
    keyName = "corps_fight_overview",
    moduleName = "client.slua.umg.corps.corps_fight.corps_fight_overview",
    path = "/Game/UMG/UI_BP/Corps/Corps_Confrontation/Confrontation_flag_UIBP.Confrontation_flag_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\134\155\229\155\162\229\175\185\230\138\151\230\136\152\230\128\187\232\167\136\231\149\140\233\157\162"
    }
  },
  corps_fight_rank_reward = {
    keyName = "corps_fight_rank_reward",
    moduleName = "client.slua.umg.corps.corps_fight.corps_fight_rank_reward",
    path = "/Game/UMG/UI_BP/Corps/Corps_Confrontation/Confrontation_End_Rank_Reward_UIBP.Confrontation_End_Rank_Reward_UIBP",
    uiStat = {
      name = "\229\134\155\229\155\162\229\175\185\230\138\151\230\136\152\230\142\146\229\144\141\230\156\128\231\187\136\229\165\150\229\138\177\233\162\134\229\165\150\231\149\140\233\157\162"
    }
  },
  corps_fight_register = {
    keyName = "corps_fight_register",
    moduleName = "client.slua.umg.corps.corps_fight.corps_fight_register",
    path = "/Game/UMG/UI_BP/Corps/Corps_Confrontation/Corps_Confrontation_UIBP.Corps_Confrontation_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\134\155\229\155\162-\229\175\185\230\138\151\230\136\152\230\138\165\229\144\141\231\149\140\233\157\162"
    }
  },
  corps_fight_result = {
    keyName = "corps_fight_result",
    moduleName = "client.slua.umg.corps.corps_fight.corps_fight_result",
    path = "/Game/UMG/UI_BP/Corps/Corps_Confrontation/Confrontation_End_Rank_UIBP.Confrontation_End_Rank_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\134\155\229\155\162\229\175\185\230\138\151\230\136\152\230\128\187\231\187\147\231\174\151\231\149\140\233\157\162"
    }
  },
  corps_fight_result_today = {
    keyName = "corps_fight_result_today",
    moduleName = "client.slua.umg.corps.corps_fight.corps_fight_result_today",
    path = "/Game/UMG/UI_BP/Corps/Corps_Confrontation/Confrontation_End_Rank_Popups_UIBP.Confrontation_End_Rank_Popups_UIBP",
    uiStat = {
      name = "\229\134\155\229\155\162\229\175\185\230\138\151\230\136\152\228\187\138\230\151\165\231\187\147\231\174\151\231\149\140\233\157\162"
    }
  },
  corps_fight_reward = {
    keyName = "corps_fight_reward",
    moduleName = "client.slua.umg.corps.corps_fight.corps_fight_reward",
    path = "/Game/UMG/UI_BP/Corps/Corps_Confrontation/Confrontation_Rank_Reward_UIBP.Confrontation_Rank_Reward_UIBP",
    uiStat = {
      name = "\229\134\155\229\155\162\229\175\185\230\138\151\230\136\152\231\187\136\230\158\129\229\165\150\229\138\177\231\149\140\233\157\162"
    }
  },
  corps_fight_right_tip = {
    keyName = "corps_fight_right_tip",
    moduleName = "client.slua.umg.corps.corps_fight.corps_fight_right_tip",
    path = "/Game/UMG/UI_BP/Corps/Corps_Confrontation/Corps_Confrontation_Tips_right_UIBP.Corps_Confrontation_Tips_right_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\229\134\155\229\155\162\229\175\185\230\138\151\230\136\152\229\143\179\228\184\139\232\167\146\230\143\144\233\134\146\231\149\140\233\157\162"
    }
  },
  corps_fight_share = {
    keyName = "corps_fight_share",
    moduleName = "client.slua.umg.corps.corps_fight.corps_fight_share",
    path = "/Game/UMG/UI_BP/Corps/Corps_Confrontation/Confrontation_Share_UIBP.Confrontation_Share_UIBP",
    uiStat = {
      name = "\229\136\134\228\186\171-\229\134\155\229\155\162\229\175\185\230\138\151\230\136\152"
    }
  },
  corps_fight_start = {
    keyName = "corps_fight_start",
    moduleName = "client.slua.umg.corps.corps_fight.corps_fight_start",
    path = "/Game/UMG/UI_BP/Corps/Corps_Confrontation/Confrontation_ongoing_star_UIBP.Confrontation_ongoing_star_UIBP",
    uiStat = {
      name = "\229\134\155\229\155\162\229\175\185\230\138\151\230\136\152\230\136\144\229\145\152\228\187\138\230\151\165\229\188\128\229\167\139\229\138\168\230\149\136\231\149\140\233\157\162"
    }
  },
  corps_fight_tip = {
    keyName = "corps_fight_tip",
    moduleName = "client.slua.umg.corps.corps_fight.corps_fight_tip",
    path = "/Game/UMG/UI_BP/Lobby/Corps_Confrontation_Lobby_Tips_UIBP.Corps_Confrontation_Lobby_Tips_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\134\155\229\155\162\229\175\185\230\138\151\230\143\144\231\164\186\233\161\181\233\157\162"
    }
  },
  corps_fight_today = {
    keyName = "corps_fight_today",
    moduleName = "client.slua.umg.corps.corps_fight.corps_fight_today",
    path = "/Game/UMG/UI_BP/Corps/Corps_Confrontation/Confrontation_ongoing_UIBP.Confrontation_ongoing_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\134\155\229\155\162\229\175\185\230\138\151\230\136\152\228\187\138\230\151\165\229\175\185\230\136\152\231\149\140\233\157\162"
    }
  },
  corps_item_menu = {
    keyName = "corps_item_menu",
    moduleName = "client.slua.umg.corps.corps_item_menu",
    path = "/Game/UMG/UI_BP/Corps/Corps_Infoitem_menu.Corps_Infoitem_menu",
    uiStat = {
      name = "\229\134\155\229\155\162-\230\136\144\229\145\152\232\143\156\229\141\149"
    }
  },
  corps_member_info = {
    keyName = "corps_member_info",
    moduleName = "client.slua.umg.corps.corps_member_info",
    path = "/Game/UMG/UI_BP/Corps/Corps_Infoitem_UIBP.Corps_Infoitem_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\134\155\229\155\162-\228\191\161\230\129\175"
    }
  },
  corps_rank_new = {
    keyName = "corps_rank_new",
    moduleName = "client.slua.umg.corps.corps_rank_new",
    path = "/Game/UMG/UI_BP/Corps/Corps_Rank_UIBP.Corps_Rank_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\134\155\229\155\162-\230\142\146\232\161\140"
    }
  },
  corps_recruit = {
    keyName = "corps_recruit",
    moduleName = "client.slua.umg.corps.corps_recruit",
    path = "/Game/UMG/UI_BP/Corps/LobbyTeam_UIBP.LobbyTeam_UIBP",
    uiStat = {
      name = "\229\134\155\229\155\162-\230\139\155\229\139\159"
    }
  },
  corps_suggestion = {
    keyName = "corps_suggestion",
    moduleName = "client.slua.umg.corps.corps_suggestion",
    path = "/Game/UMG/UI_BP/Corps/Corps_Suggestion_UIBP.Corps_Suggestion_UIBP",
    uiStat = {
      name = "\229\134\155\229\155\162-\229\134\155\229\155\162\230\142\168\232\141\144"
    },
    isMainUI = false
  },
  corps_welfare_main = {
    keyName = "corps_welfare_main",
    moduleName = "client.slua.umg.corps.corps_welfare.corps_welfare_main",
    path = "/Game/UMG/UI_BP/Corps/Corps_Welfare_UIBP_2.Corps_Welfare_UIBP_2",
    isMainUI = false,
    uiStat = {
      name = "\229\134\155\229\155\162-\231\166\143\229\136\169"
    }
  },
  corps_welfare_receive = {
    keyName = "corps_welfare_receive",
    moduleName = "client.slua.umg.corps.corps_welfare.corps_welfare_receive",
    path = "/Game/UMG/UI_BP/Corps/item/Crops_Receivingrecords_UIBP_2.Crops_Receivingrecords_UIBP_2",
    uiStat = {
      name = "\229\134\155\229\155\162\231\166\143\229\136\169\233\162\134\229\143\150\232\174\176\229\189\149\233\161\181\233\157\162"
    }
  },
  corps_welfare_redEnvelop = {
    keyName = "corps_welfare_redEnvelop",
    moduleName = "client.slua.umg.corps.corps_welfare.corps_welfare_redEnvelop",
    path = "/Game/UMG/UI_BP/Corps/item/Corps_RedEnvelopes_Item_UIBP_2.Corps_RedEnvelopes_Item_UIBP_2",
    uiStat = {
      name = "\229\134\155\229\155\162-\230\180\190\229\143\145\231\166\143\229\136\169\231\149\140\233\157\162"
    }
  },
  roleinfo_corpsAlias = {
    keyName = "roleinfo_corpsAlias",
    moduleName = "client.slua.umg.roleInfo.Roleinfo_CorpsAlias",
    path = "/Game/UMG/UI_BP/Corps/Corps_ChooseCorpsAlias_UIBP.Corps_ChooseCorpsAlias_UIBP",
    asy = true,
    uiStat = {
      name = "\228\184\170\228\186\186\231\169\186\233\151\180-\233\128\137\230\139\169\229\134\155\229\155\162\231\167\176\229\143\183"
    }
  }
}
return corps_ui_configs