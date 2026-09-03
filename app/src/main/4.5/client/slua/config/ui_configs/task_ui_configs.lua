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
local task_ui_configs = {
  newbie_task = {
    keyName = "newbie_task",
    moduleName = "client.slua.umg.task.Lobby_NewbieTask_Main_UIBP",
    path = "/Game/UMG/UI_BP/Task/Lobby_NewbieTask_Main_UIBP.Lobby_NewbieTask_Main_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\228\187\187\229\138\161-\230\150\176\229\133\181\232\174\173\231\187\131"
    }
  },
  TaskGrowbut_UIBP = {
    keyName = "TaskGrowbut_UIBP",
    moduleName = "client.slua.umg.task.Taskitem.TaskGrowbut_UIBP",
    path = "/Game/UMG/UI_BP/Task/Taskitem/TaskGrowbut_UIBP.TaskGrowbut_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\228\187\187\229\138\161-\230\136\144\233\149\191\228\187\187\229\138\161Item"
    }
  },
  newbie_task_daily_brief = {
    keyName = "newbie_task_daily_brief",
    moduleName = "client.slua.umg.task.Taskitem.Lobby_NewbieTask_Daily_Brief_UIBP",
    path = "/Game/UMG/UI_BP/Task/Taskitem/Lobby_NewbieTask_Daily_Brief_UIBP.Lobby_NewbieTask_Daily_Brief_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\228\187\187\229\138\161-\230\150\176\229\133\181\232\174\173\231\187\131\231\174\128\232\166\129\229\177\149\231\164\186"
    }
  },
  newbie_task_last_day = {
    keyName = "newbie_task_last_day",
    moduleName = "client.slua.umg.task.Taskitem.Lobby_NewbieTask_LastDay_UIBP",
    path = "/Game/UMG/UI_BP/Task/Taskitem/Lobby_NewbieTask_LastDay_UIBP.Lobby_NewbieTask_LastDay_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\228\187\187\229\138\161-\230\150\176\229\133\181\232\174\173\231\187\131\231\172\172\228\184\131\229\164\169\232\175\166\231\187\134\229\177\149\231\164\186"
    }
  },
  new_player_spin_task_item_uibp = {
    keyName = "new_player_spin_task_item_uibp",
    moduleName = "client.slua.umg.growth_project.new_player_spin_task_item_uibp",
    path = "/Game/Mod/Lobby/Split/NewbieActivity/UIBP/NewbieSpin/LuckySpin_Gun_Hilarity3_UIBP.LuckySpin_Gun_Hilarity3_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\229\162\158\233\149\191\228\184\147\233\161\185-\230\150\176\230\137\139\232\189\172\231\155\152-\228\187\187\229\138\161\229\136\151\232\161\168"
    }
  },
  mentor_task_item = {
    keyName = "mentor_task_item",
    moduleName = "client.slua.umg.mentor.item.mentor_task_item",
    path = "/Game/UMG/UI_BP/PartnerReadiness/Item/PartnerReadiness_Task_UIBP.PartnerReadiness_Task_UIBP",
    isSingleton = false
  },
  mentor_task_tips = {
    keyName = "mentor_task_tips",
    moduleName = "client.slua.umg.mentor.mentor_task_tips",
    path = "/Game/UMG/UI_BP/PartnerReadiness/PartnerReadiness_DailyTask_UIBP.PartnerReadiness_DailyTask_UIBP",
    AndroidBackType = EAndroidBackType.Ban,
    uiStat = {
      name = "\232\128\129\229\184\166\230\150\176-\229\164\167\229\142\133\228\187\187\229\138\161\230\143\144\231\164\186"
    }
  },
  Flap_Newbie_EightDays = {
    keyName = "Flap_Newbie_EightDays",
    moduleName = "client.slua.umg.DailyActivity.NoviceTask.Flap_Newbie_EightDays",
    path = "/Game/Mod/Lobby/Split/NewbieActivity/UIBP/NoviceTask/Activity_EightDaysUIBP.Activity_EightDaysUIBP",
    uiStat = {
      name = "\230\150\176\230\137\139\230\180\187\229\138\168-\230\150\176\229\133\181\229\133\171\229\164\169\230\139\141\232\132\184"
    }
  },
  EightDays_SelectAwardUI = {
    keyName = "EightDays_SelectAwardUI",
    moduleName = "client.slua.umg.DailyActivity.NoviceTask.EightDays_SelectAwardUI",
    path = "/Game/Mod/Lobby/Split/NewbieActivity/UIBP/NoviceTask/Activity_Novice_Popup_UIBP.Activity_Novice_Popup_UIBP",
    uiStat = {
      name = "\230\150\176\230\137\139\230\180\187\229\138\168-\230\150\176\229\133\181\229\133\171\229\164\169-\233\128\137\230\139\169\229\165\150\229\138\177"
    }
  },
  NewbieTraining_New_UIBP = {
    keyName = "NewbieTraining_New_UIBP",
    moduleName = "client.slua.umg.DailyActivity.NoviceTask.NewbieTraining_New_UIBP",
    path = "/Game/Mod/Lobby/Split/NewbieActivity/UIBP/NewbieTraining/NewbieTraining_New_UIBP.NewbieTraining_New_UIBP",
    uiStat = {
      name = "\230\150\176\230\137\139\230\180\187\229\138\168-\230\150\176\229\133\181\232\174\173\231\187\131-\230\150\176\231\149\140\233\157\162"
    },
    isMainUI = false
  },
  Newbie_Reward_Homepage_UIBP = {
    keyName = "Newbie_Reward_Homepage_UIBP",
    moduleName = "client.slua.umg.DailyActivity.NoviceTask.Newbie_Reward_Homepage_UIBP",
    path = "/Game/Mod/Lobby/Split/NewbieActivity/UIBP/NewbieReward/Newbie_Reward_Homepage_UIBP.Newbie_Reward_Homepage_UIBP",
    uiStat = {
      name = "\230\150\176\230\137\139\230\180\187\229\138\168-\230\150\176\229\133\181\229\165\150\229\138\177-\230\150\176\231\149\140\233\157\162"
    },
    isMainUI = false
  },
  Newbie_Reward_MoreMission_UIBP = {
    keyName = "Newbie_Reward_MoreMission_UIBP",
    moduleName = "client.slua.umg.DailyActivity.NoviceTask.Newbie_Reward_MoreMission_UIBP",
    path = "/Game/Mod/Lobby/Split/NewbieActivity/UIBP/NewbieReward/Newbie_Reward_MoreMission_UIBP.Newbie_Reward_MoreMission_UIBP",
    uiStat = {
      name = "\230\150\176\230\137\139\230\180\187\229\138\168-\230\150\176\229\133\181\229\165\150\229\138\177-\230\150\176\228\187\187\229\138\161\229\188\185\231\170\151\231\149\140\233\157\162"
    },
    isMainUI = false,
    containerName = UIContainers.Top
  },
  Newbie_Reward_Middle_Item_UIBP = {
    keyName = "Newbie_Reward_Middle_Item_UIBP",
    moduleName = "client.slua.umg.DailyActivity.NoviceTask.Newbie_Reward_Middle_Item_UIBP",
    path = "/Game/Mod/Lobby/Split/NewbieActivity/UIBP/NewbieReward/Item/Newbie_Reward_Middle_Item_UIBP.Newbie_Reward_Middle_Item_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\230\150\176\229\133\181\230\180\187\229\138\168-\230\150\176\229\133\181\229\165\150\229\138\177\228\184\187\233\161\181-\228\184\173\233\151\180\230\140\130\232\189\189"
    }
  },
  Newbie_Reward_Home_OptionsReward_UIBP = {
    keyName = "Newbie_Reward_Home_OptionsReward_UIBP",
    moduleName = "client.slua.umg.DailyActivity.NoviceTask.Newbie_Reward_Home_OptionsReward_UIBP",
    path = "/Game/Mod/Lobby/Split/NewbieActivity/UIBP/NewbieOptionsReward/Newbie_OptionsReward_UIBP.Newbie_OptionsReward_UIBP",
    uiStat = {
      name = "\230\150\176\229\133\181\230\180\187\229\138\168-\230\150\176\229\133\181\229\165\150\229\138\177-\228\184\137\233\128\137\228\184\128\231\149\140\233\157\162"
    }
  },
  NewbiePrivileges_Activity_HomePage_UIBP = {
    keyName = "NewbiePrivileges_Activity_HomePage_UIBP",
    moduleName = "client.slua.umg.DailyActivity.NoviceTask.NewbiePrivileges_Activity_HomePage_UIBP",
    path = "/Game/Mod/Lobby/Split/NewbieActivity/UIBP/NewbiePrivileges/NewbiePrivileges_Activity_HomePage_UIBP.NewbiePrivileges_Activity_HomePage_UIBP",
    uiStat = {
      name = "\230\150\176\230\137\139\230\180\187\229\138\168-\230\150\176\229\133\181\231\137\185\230\157\131-\230\150\176\231\149\140\233\157\162"
    },
    isMainUI = false
  },
  NewbiePrivileges_Activity_HomePage_Tips_UIBP = {
    keyName = "NewbiePrivileges_Activity_HomePage_Tips_UIBP",
    moduleName = "client.slua.umg.DailyActivity.NoviceTask.NewbiePrivileges_Activity_HomePage_Tips_UIBP",
    path = "/Game/Mod/Lobby/Split/NewbieActivity/UIBP/NewbiePrivileges/Item/NewbiePrivileges_Activity_HomePage_Tips_UIBP.NewbiePrivileges_Activity_HomePage_Tips_UIBP",
    uiStat = {
      name = "\230\150\176\230\137\139\230\180\187\229\138\168-\230\150\176\229\133\181\231\137\185\230\157\131-\230\143\144\231\164\186\231\149\140\233\157\162"
    }
  },
  Newbie_Reward_Level_Sprint_UIBP = {
    keyName = "Newbie_Reward_Level_Sprint_UIBP",
    moduleName = "client.slua.umg.DailyActivity.NoviceTask.Newbie_Reward_Level_Sprint_UIBP",
    path = "/Game/Mod/Lobby/Split/NewbieActivity/UIBP/NewbieReward/Newbie_Reward_LevelSprint_UIBP.Newbie_Reward_LevelSprint_UIBP",
    uiStat = {
      name = "\230\150\176\230\137\139\230\180\187\229\138\168-\229\134\178\230\174\181-\230\150\176\229\133\181\229\164\141\231\148\168\229\142\159\231\173\137\231\186\167\229\134\178\229\136\186\231\149\140\233\157\162"
    },
    isMainUI = false
  },
  Newbie_Reward_Eight_Days_UIBP = {
    keyName = "Newbie_Reward_Eight_Days_UIBP",
    moduleName = "client.slua.umg.DailyActivity.NoviceTask.Newbie_Reward_Eight_Days_UIBP",
    path = "/Game/Mod/Lobby/Split/NewbieActivity/UIBP/NoviceTask/Activity_Novice_8Days_UIBP.Activity_Novice_8Days_UIBP",
    uiStat = {
      name = "\230\150\176\230\137\139\230\180\187\229\138\168-\230\150\176\229\133\181\229\133\171\229\164\169\230\180\187\229\138\168-\230\150\176\229\133\181\229\164\141\231\148\168\229\142\159\229\133\171\229\164\169\230\180\187\229\138\168\231\149\140\233\157\162"
    },
    isMainUI = false
  },
  Flap_Newbie_Reward_Eight_Days = {
    keyName = "Flap_Newbie_Reward_Eight_Days",
    moduleName = "client.slua.umg.DailyActivity.NoviceTask.Flap_Newbie_Reward_Eight_Days",
    path = "/Game/Mod/Lobby/Split/NewbieActivity/UIBP/NoviceTask/Activity_EightDaysUIBP.Activity_EightDaysUIBP",
    uiStat = {
      name = "\230\150\176\230\137\139\230\180\187\229\138\168-\230\150\176\229\133\181\229\133\171\229\164\169\230\139\141\232\132\184-\230\150\176\229\133\181\229\164\141\231\148\168"
    }
  },
  Newbie_Reward_Eight_Days_OptionsReward_UIBP = {
    keyName = "Newbie_Reward_Eight_Days_OptionsReward_UIBP",
    moduleName = "client.slua.umg.DailyActivity.NoviceTask.Newbie_Reward_Eight_Days_OptionsReward_UIBP",
    path = "/Game/Mod/Lobby/Split/NewbieActivity/UIBP/NewbieOptionsReward/Newbie_OptionsReward_UIBP.Newbie_OptionsReward_UIBP",
    uiStat = {
      name = "\230\150\176\229\133\181\230\180\187\229\138\168-\230\150\176\229\133\181\229\133\171\229\164\169\229\165\150\229\138\177-\228\184\137\233\128\137\228\184\128\231\149\140\233\157\162"
    }
  },
  Financial_TemplateTask_UIBP = {
    keyName = "Financial_TemplateTask_UIBP",
    moduleName = "client.slua.umg.SpecialOffer.Financial.Financial_TemplateTask_UIBP",
    path = "/Game/Arts_UI/FromUMG/SpecialOffer/Financial/Financial_Task_UIBP.Financial_Task_UIBP",
    uiStat = {
      name = "\231\144\134\232\180\162\232\174\161\229\136\146-\228\187\187\229\138\161\229\136\151\232\161\168"
    }
  },
  SmallPayment_Task_UIBP = {
    keyName = "SmallPayment_Task_UIBP",
    moduleName = "client.slua.umg.SmallPayment.SmallPayment_Task_UIBP",
    path = "/Game/Arts_UI/FromUMG/SpecialOffer/SmallPayment/SmallPayment_Task_UIBP.SmallPayment_Task_UIBP",
    uiStat = {
      name = "\229\176\143\233\162\157\228\187\152\232\180\185-\228\187\187\229\138\161\229\136\151\232\161\168"
    }
  },
  Activity_RoutineTasks1_UIBP = {
    keyName = "Activity_RoutineTasks1_UIBP",
    moduleName = "client.slua.umg.activity.new_activity_center.Activity_RoutineTasks1_UIBP",
    path = "/Game/Mod/Lobby/Split/NewActivity/Activty_RoutineTasks_UIBP.Activty_RoutineTasks_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\230\180\187\229\138\168\228\184\173\229\191\131-\229\173\144\230\180\187\229\138\168"
    }
  },
  Activity_RoutineTasks2_UIBP = {
    keyName = "Activity_RoutineTasks2_UIBP",
    moduleName = "client.slua.umg.activity.new_activity_center.Activity_RoutineTasks2_UIBP",
    path = "/Game/Mod/Lobby/Split/NewActivity/Activty_RoutineTasks_UIBP_2.Activty_RoutineTasks_UIBP_2",
    isMainUI = false,
    uiStat = {
      name = "\230\180\187\229\138\168\228\184\173\229\191\131-\232\191\155\229\186\166\230\157\161\231\177\187\229\173\144\230\180\187\229\138\168"
    }
  },
  Activity_RoutineTasks3_UIBP = {
    keyName = "Activity_RoutineTasks3_UIBP",
    moduleName = "client.slua.umg.activity.new_activity_center.Activity_RoutineTasks3_UIBP",
    path = "/Game/Mod/Lobby/Split/NewActivity/Activty_RoutineTasks_UIBP_3.Activty_RoutineTasks_UIBP_3",
    isMainUI = false,
    uiStat = {
      name = "\230\180\187\229\138\168\228\184\173\229\191\131-\233\129\147\229\133\183\230\148\182\233\155\134\231\177\187\229\173\144\230\180\187\229\138\168"
    }
  },
  ReturnActivity_Task_Popup_UIBP = {
    keyName = "ReturnActivity_Task_Popup_UIBP",
    moduleName = "client.slua.umg.return_activity.ReturnActivity_Task_Popup_UIBP",
    path = "/Game/UMG/UI_BP/ReturnActivity/ReturnActivity_Task_Popup_UIBP.ReturnActivity_Task_Popup_UIBP",
    uiStat = {
      name = "230\229\155\158\230\181\129\228\187\187\229\138\161\230\139\141\232\132\184"
    }
  },
  Return_Packs_Popup_UIBP = {
    keyName = "Return_Packs_Popup_UIBP",
    moduleName = "client.slua.umg.return_activity.Return_Packs_Popup_UIBP",
    path = "/Game/UMG/UI_BP/ReturnActivity/ReturnActivity_Task_Popup_UIBP.ReturnActivity_Task_Popup_UIBP",
    uiStat = {
      name = "\229\155\158\230\181\129\230\172\162\232\191\142\231\164\188\229\140\133"
    }
  },
  Theme_Task_UIBP = {
    keyName = "Theme_Task_UIBP",
    moduleName = "client.slua.umg.Theme.New.Theme_Task_UIBP",
    path = "/Game/Arts_UI/FromUMG/Theme/Theme_Task_UIBP.Theme_Task_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\228\184\187\233\162\152\231\179\187\231\187\159-\231\137\136\230\156\172\228\187\187\229\138\161"
    }
  },
  Theme_Achievement_Summary_Task_Item = {
    keyName = "Theme_Achievement_Summary_Task_Item",
    moduleName = "client.slua_ui_framework.base",
    path = "/Game/Arts_UI/FromUMG/Theme/Item/Theme_Achievement_Summary_Task_Item.Theme_Achievement_Summary_Task_Item",
    isMainUI = false,
    isSingleton = false
  },
  INTIMACY_DOUBLE_UIBP = {
    keyName = "INTIMACY_DOUBLE_UIBP",
    moduleName = "client.slua.umg.popular_gift_pk.Intimacy_Double_UIBP",
    path = "/Game/Mod/Lobby/Split/NewActivity/Activty_RoutineTasks_UIBP_5.Activty_RoutineTasks_UIBP_5",
    isMainUI = false,
    uiStat = {
      name = "\228\186\178\229\175\134\229\186\166\229\143\140\229\128\141\230\180\187\229\138\168"
    }
  },
  PeakGame_Task_Popup_UIBP = {
    keyName = "PeakGame_Task_Popup_UIBP",
    moduleName = "client.slua.umg.PeakGame.Popup.PeakGame_Task_Popup_UIBP",
    path = "/Game/Mod/Lobby/Split/NewSeason/PeakGame/Popup/PeakGame_Task_Popup_UIBP.PeakGame_Task_Popup_UIBP",
    uiStat = {
      name = "\229\183\133\229\179\176\232\181\155-\228\187\187\229\138\161\231\149\140\233\157\162"
    },
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE,
    asy = true
  },
  NewbieTraining_Popup_UIBP = {
    keyName = "NewbieTraining_Popup_UIBP",
    moduleName = "client.slua.umg.DailyActivity.NoviceTask.NewbieTraining_Popup_UIBP",
    path = "/Game/Mod/Lobby/Split/NewbieActivity/UIBP/NewbieTraining/NewbieTraining_Popup_UIBP.NewbieTraining_Popup_UIBP",
    uiStat = {
      name = "\230\150\176\230\137\139\230\180\187\229\138\168-\230\174\181\228\189\141\230\180\187\229\138\168\229\188\185\231\170\151"
    }
  },
  Newbie_Friends_Recommend = {
    keyName = "Newbie_Friends_Recommend",
    moduleName = "client.slua.umg.DailyActivity.NoviceTask.Newbie_FriendsRecommend_New",
    path = "/Game/UMG/UI_BP/ReturnActivity/ReturnActivity_RecommendFriend_UIBP.ReturnActivity_RecommendFriend_UIBP",
    containerName = UIContainers.Default,
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    uiStat = {
      name = "\230\150\176\230\137\139\229\165\189\229\143\139\230\142\168\232\141\144\229\188\185\231\170\151"
    }
  },
  NewRecruit_SevenDayTask_UIBP = {
    keyName = "NewRecruit_SevenDayTask_UIBP",
    moduleName = "client.slua.umg.NewRecruit.SevenDayTask.NewRecruit_SevenDayTask_UIBP",
    path = "/Game/Mod/Lobby/Split/NewbieActivity/UIBP/NewRecruit/SevenDayTask/NewRecruit_SevenDayTask_UIBP.NewRecruit_SevenDayTask_UIBP",
    uiStat = {
      name = "\230\150\176\229\133\181-\228\184\131\230\151\165\228\187\187\229\138\161\231\149\140\233\157\162"
    },
    isMainUI = false
  },
  NewRecruit_NewbieTask_UIBP = {
    keyName = "NewRecruit_NewbieTask_UIBP",
    moduleName = "client.slua.umg.NewRecruit.NewbieTask.NewRecruit_NewbieTask_UIBP",
    path = "/Game/Mod/Lobby/Split/NewbieActivity/UIBP/NewRecruit/NewbieTask/NewRecruit_NewbieTask_UIBP.NewRecruit_NewbieTask_UIBP",
    uiStat = {
      name = "\230\150\176\229\133\181-\230\150\176\228\186\186\228\187\187\229\138\161\231\149\140\233\157\162"
    },
    isMainUI = false
  },
  NewRecruit_DailyWish_UIBP = {
    keyName = "NewRecruit_DailyWish_UIBP",
    moduleName = "client.slua.umg.NewRecruit.DailyWish.NewRecruit_DailyWish_UIBP",
    path = "/Game/Mod/Lobby/Split/NewbieActivity/UIBP/NewRecruit/DailyWish/NewRecruit_DailyWish_UIBP.NewRecruit_DailyWish_UIBP",
    uiStat = {
      name = "\230\150\176\229\133\181-\230\175\143\230\151\165\232\174\184\230\132\191\230\177\160"
    },
    isMainUI = false
  },
  NewRecruit_Welfare_UIBP = {
    keyName = "NewRecruit_Welfare_UIBP",
    moduleName = "client.slua.umg.NewRecruit.Welfare.NewRecruit_Welfare_UIBP",
    path = "/Game/Mod/Lobby/Split/NewbieActivity/UIBP/NewRecruit/Welfare/NewRecruit_Welfare_UIBP.NewRecruit_Welfare_UIBP",
    uiStat = {
      name = "\230\150\176\229\133\181-\230\150\176\228\186\186\231\166\143\229\136\169"
    },
    isMainUI = false
  },
  NewRecruit_NewcomerTutorial_UIBP = {
    keyName = "NewRecruit_NewcomerTutorial_UIBP",
    moduleName = "client.slua.umg.NewRecruit.NewcomerTutorial.NewRecruit_NewcomerTutorial_UIBP",
    path = "/Game/Mod/Lobby/Split/NewbieActivity/UIBP/NewRecruit/NewcomerTutorial/NewRecruit_NewcomerTutorial_UIBP.NewRecruit_NewcomerTutorial_UIBP",
    uiStat = {
      name = "\230\150\176\229\133\181-\230\150\176\228\186\186\230\149\153\229\173\166"
    },
    isMainUI = false
  },
  NewRecruit_SevenDayTask_AwardsItem = {
    keyName = "NewRecruit_SevenDayTask_AwardsItem",
    moduleName = "client.slua.umg.NewRecruit.SevenDayTask.Item.NewRecruit_SevenDayTask_AwardsItem",
    path = "/Game/Mod/Lobby/Split/NewbieActivity/UIBP/NewRecruit/SevenDayTask/Item/NewRecruit_SevenDayTask_AwardsItem.NewRecruit_SevenDayTask_AwardsItem",
    isMainUI = false,
    isSingleton = false
  }
}
return task_ui_configs