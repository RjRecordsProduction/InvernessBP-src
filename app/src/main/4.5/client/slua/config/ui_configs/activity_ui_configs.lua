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
local activity_ui_configs = {
  Activity_SingleBind_UIBP = {
    keyName = "Activity_SingleBind_UIBP",
    moduleName = "client.slua.umg.activity.Activity_SingleBind_UIBP",
    path = "/Game/Mod/Lobby/Split/NewActivity/UMG/UI_BP/Activity_SingleBind/Activity_SingleBind_UIBP.Activity_SingleBind_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\230\180\187\229\138\168\228\184\173\229\191\131-\229\141\149\231\187\145"
    }
  },
  activity_ad_week = {
    keyName = "activity_ad_week",
    moduleName = "client.slua.umg.activity.activity_ad_week",
    path = "/Game/Mod/Lobby/Split/NewActivity/Activty_RoutineTasks_UIBP.Activty_RoutineTasks_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\230\180\187\229\138\168\228\184\173\229\191\131-\229\185\191\229\145\138\229\145\168"
    }
  },
  activity_rebate_slap = {
    keyName = "activity_rebate_slap",
    moduleName = "client.slua.umg.activity.rebate.Activity_Rebate_Slap_UIBP",
    path = "/Game/UMG/UI_BP/DailyActivity/Activity_Rebate_Slap_UIBP.Activity_Rebate_Slap_UIBP",
    loadFromPool = EUIConfigPoolType.None,
    uiStat = {
      name = "\232\191\148\229\136\169\230\180\187\229\138\168-\230\139\141\232\132\184\229\155\190"
    }
  },
  Activity_Newbie_EightDays = {
    keyName = "Activity_Newbie_EightDays",
    moduleName = "client.slua.umg.DailyActivity.NoviceTask.Activity_Newbie_EightDays",
    path = "/Game/Mod/Lobby/Split/NewbieActivity/UIBP/NovicEightDays/Activity_Novice_8Days_UIBP.Activity_Novice_8Days_UIBP",
    uiStat = {
      name = "\230\150\176\230\137\139\230\180\187\229\138\168-\230\150\176\229\133\181\229\133\171\229\164\169\230\180\187\229\138\168"
    },
    isMainUI = false
  },
  Activity_Newbie_Award = {
    keyName = "Activity_Newbie_Award",
    moduleName = "client.slua.umg.DailyActivity.NoviceTask.Activity_Newbie_Award",
    path = "/Game/Mod/Lobby/Split/NewbieActivity/UIBP/NoviceTask/Activity_Novice_Reward_UIBP.Activity_Novice_Reward_UIBP",
    uiStat = {
      name = "\230\150\176\230\137\139\230\180\187\229\138\168-\229\134\178\230\174\181\229\165\150\229\138\177"
    },
    isMainUI = false
  },
  Activity_Newbie_Gift = {
    keyName = "Activity_Newbie_Gift",
    moduleName = "client.slua.umg.DailyActivity.NoviceTask.Activity_Newbie_Gift",
    path = "/Game/Mod/Lobby/Split/NewbieActivity/UIBP/NewbieSpin/Activity_Novice_UIBP.Activity_Novice_UIBP",
    uiStat = {
      name = "\230\150\176\230\137\139\230\180\187\229\138\168-\230\150\176\230\137\139\231\164\188\229\140\133"
    }
  },
  Activity_Newbie_Spin = {
    keyName = "Activity_Newbie_Spin",
    moduleName = "client.slua.umg.growth_project.new_player_spin_main_uibp",
    path = "/Game/Mod/Lobby/Split/NewbieActivity/UIBP/NewbieSpin/LuckySpin_Gun_Hilarity4_UIBP.LuckySpin_Gun_Hilarity4_UIBP",
    uiStat = {
      name = "\230\150\176\230\137\139\230\180\187\229\138\168-\230\150\176\230\137\139\232\189\172\231\155\152"
    },
    isMainUI = false
  },
  Activity_Newbie_Training = {
    keyName = "Activity_Newbie_Training",
    moduleName = "client.slua.umg.DailyActivity.NoviceTask.Activity_Newbie_Training",
    path = "/Game/Mod/Lobby/Split/NewbieActivity/UIBP/NewbieTraining/NewbieTraining_UIBP.NewbieTraining_UIBP",
    uiStat = {
      name = "\230\150\176\230\137\139\230\180\187\229\138\168-\230\150\176\229\133\181\232\174\173\231\187\131"
    },
    isMainUI = false
  },
  Activity_Newbie_FriendsGathering = {
    keyName = "Activity_Newbie_FriendsGathering",
    moduleName = "client.slua.umg.DailyActivity.NoviceTask.Activity_Newbie_FriendsGathering",
    path = "/Game/Mod/Lobby/Split/NewbieActivity/UIBP/NewbieFriendsGathering/Newbie_FriendsGathering_UIBP.Newbie_FriendsGathering_UIBP",
    uiStat = {
      name = "\230\150\176\230\137\139\230\180\187\229\138\168-\229\165\189\229\143\139\233\155\134\231\187\147"
    },
    isMainUI = false
  },
  Activity_Newbie_Achievement = {
    keyName = "Activity_Newbie_Achievement",
    moduleName = "client.slua.umg.DailyActivity.NoviceTask.Activity_Newbie_Achievement",
    path = "/Game/Mod/Lobby/Split/NewbieActivity/UIBP/NewbieAchievement/Newbie_Achievement_UIBP.Newbie_Achievement_UIBP",
    uiStat = {
      name = "\230\150\176\230\137\139\230\180\187\229\138\168-\230\150\176\229\133\181\230\136\144\229\176\177"
    },
    isMainUI = false
  },
  Activity_Newbie_LevelSprint = {
    keyName = "Activity_Newbie_LevelSprint",
    moduleName = "client.slua.umg.DailyActivity.NoviceTask.Activity_Newbie_LevelSprint",
    path = "/Game/Mod/Lobby/Split/NewbieActivity/UIBP/LevelSprint/Newbie_LevelSprint_UIBP.Newbie_LevelSprint_UIBP",
    uiStat = {
      name = "\230\150\176\230\137\139\230\180\187\229\138\168-\231\173\137\231\186\167\229\134\178\229\136\186"
    },
    isMainUI = false
  },
  Activity_Newbie_Main = {
    keyName = "Activity_Newbie_Main",
    moduleName = "client.slua.umg.DailyActivity.NoviceTask.Activity_Newbie_Main",
    path = "/Game/Mod/Lobby/Split/NewbieActivity/UIBP/NewbieTab_Main_UIBP.NewbieTab_Main_UIBP",
    uiStat = {
      name = "\230\150\176\230\137\139\230\180\187\229\138\168-\228\184\187\231\149\140\233\157\162"
    },
    jumpModuleID = BP_ENUM_MODULE_NEWIBIE_ACTIVITY_MAIN
  },
  Activity_Newbie_Banner = {
    keyName = "Activity_Newbie_Banner",
    moduleName = "client.slua.umg.DailyActivity.NoviceTask.Activity_Newbie_Banner",
    path = "/Game/Mod/Lobby/Base/Newbie/Newbie_Banner.Newbie_Banner",
    uiStat = {
      name = "\230\150\176\230\137\139\230\180\187\229\138\168-banner"
    },
    isMainUI = false
  },
  activity_bind_facebook = {
    keyName = "activity_bind_facebook",
    moduleName = "client.slua.umg.activity.bind_facebook.activity_bind_facebook",
    jumpModuleID = BP_ENUM_MODULE_BIND_FACEBOOK,
    path = "/Game/UMG/UI_BP/Lobby_Activity/Activity_BindFacebookUIBP.Activity_BindFacebookUIBP",
    uiStat = {
      name = "\231\187\145\229\174\154\230\156\137\231\164\188-\228\184\187\231\149\140\233\157\162"
    }
  },
  activity_bind_discord = {
    keyName = "activity_bind_discord",
    moduleName = "client.slua.umg.activity.bind_discord.activity_bind_discord",
    path = "/Game/UMG/UI_BP/Lobby_Activity/Activity_BindGift_UIBP.Activity_BindGift_UIBP",
    uiStat = {
      name = "\231\187\145\229\174\154\230\156\137\231\164\188-discord\231\187\145\229\174\154\230\180\187\229\138\168\228\184\187\231\149\140\233\157\162"
    }
  },
  everydaypack_activity = {
    keyName = "everydaypack_activity",
    moduleName = "client.slua.umg.SpecialOffer.EverydayPack.everydaypack_activity",
    path = "/Game/Arts_UI/FromUMG/SpecialOffer/EverydayPack/UIBP/EveryDayPack_Main_BP.EveryDayPack_Main_BP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\230\175\143\230\151\165\231\164\188\229\140\133"
    }
  },
  EveryDayPack_Empty_Click = {
    keyName = "EveryDayPack_Empty_Click",
    moduleName = "client.slua.umg.SpecialOffer.EverydayPack.everydaypack_activity_empty_click",
    path = "/Game/Arts_UI/FromUMG/SpecialOffer/EverydayPack/UIBP/EveryDayPack_Empty_Click_UIBP.EveryDayPack_Empty_Click_UIBP",
    asy = false,
    containerName = UIContainers.Top,
    isSingleton = false,
    uiStat = {
      name = "\230\175\143\230\151\165\231\164\188\229\140\133\229\133\168\229\177\143\231\130\185\229\135\187"
    }
  },
  everydaypack_activity_v2 = {
    keyName = "everydaypack_activity_v2",
    moduleName = "client.slua.umg.SpecialOffer.EverydayPack.everydaypack_activity_v2",
    path = "/Game/Arts_UI/FromUMG/SpecialOffer/DailyFortunePack/UIBP/EveryDayPack_NewMain_UIBP.EveryDayPack_NewMain_UIBP",
    asy = true,
    isMainUI = false,
    uiStat = {
      name = "\230\175\143\230\151\165\231\164\188\229\140\133\232\161\141\231\148\159"
    }
  },
  week_sign = {
    keyName = "week_sign",
    moduleName = "client.slua.umg.activity.week_sign",
    path = "/Game/Mod/Lobby/Split/NewActivity/UMG/UI_BP/Avtivity_WeekSign/Activity_WeekSign_Main_UIBP.Activity_WeekSign_Main_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\230\180\187\229\138\168\228\184\173\229\191\131-\229\145\168\231\173\190\229\136\176"
    }
  },
  SortitionPutbackTemplate_Main = {
    keyName = "SortitionPutbackTemplate_Main",
    moduleName = "client.slua.umg.activity.SortitionPutbackTemplate_Main",
    path = "/Game/Arts_UI/FromUMG/LotteryTemplate/SortitionPutbackTemplate/SortitionPutbackTemplate_Main_UIBP.SortitionPutbackTemplate_Main_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\230\180\187\229\138\168\228\184\173\229\191\131-\230\138\189\231\173\190\232\189\172\231\155\152"
    }
  },
  SortitionPutbackTemplate_Sharere = {
    keyName = "SortitionPutbackTemplate_Sharere",
    moduleName = "client.slua.umg.activity.SortitionPutbackTemplate_Sharere",
    path = "/Game/Arts_UI/FromUMG/LotteryTemplate/SortitionPutbackTemplate/SortitionPutbackTemplate_Sharere_UIBP.SortitionPutbackTemplate_Sharere_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\230\180\187\229\138\168\228\184\173\229\191\131-\230\138\189\231\173\190\232\189\172\231\155\152\229\136\134\228\186\171"
    }
  },
  ui_day_first_win = {
    keyName = "ui_day_first_win",
    moduleName = "client.slua.umg.activity.day_first_win.ui_day_first_win",
    path = "/Game/Mod/Lobby/Split/NewActivity/Activty_DailyWin_UIBP.Activty_DailyWin_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\230\175\143\230\151\165\233\166\150\232\131\156\231\149\140\233\157\162"
    }
  },
  new_player_spin_main_uibp = {
    keyName = "new_player_spin_main_uibp",
    moduleName = "client.slua.umg.growth_project.new_player_spin_main_uibp",
    path = "/Game/Mod/Lobby/Split/NewbieActivity/UIBP/NewbieSpin/LuckySpin_Gun_Hilarity4_UIBP.LuckySpin_Gun_Hilarity4_UIBP",
    uiStat = {
      name = "\229\162\158\233\149\191\228\184\147\233\161\185-\230\150\176\230\137\139\232\189\172\231\155\152-\232\131\140\230\153\175"
    },
    isMainUI = false
  },
  new_player_spin_twelve_item_uibp = {
    keyName = "new_player_spin_twelve_item_uibp",
    moduleName = "client.slua.umg.growth_project.new_player_spin_twelve_item_uibp",
    path = "/Game/Mod/Lobby/Split/NewbieActivity/UIBP/NewbieSpin/LuckySpin_Gun_Hilarity2_UIBP.LuckySpin_Gun_Hilarity2_UIBP",
    isSingleton = false,
    uiStat = {
      name = "\229\162\158\233\149\191\228\184\147\233\161\185-\230\150\176\230\137\139\232\189\172\231\155\152-12\231\137\169\229\147\129"
    }
  },
  AdvertisingWheel_Main = {
    keyName = "AdvertisingWheel_Main",
    moduleName = "client.slua.umg.activity.advertisingwheel.AdvertisingWheel_Main",
    path = "/Game/Arts_UI/FromUMG/LotteryTemplate/LndianLottery/AdvertisingWheel_Main_UIBP.AdvertisingWheel_Main_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\185\191\229\145\138\232\189\172\231\155\152\230\138\189\229\165\150-\232\147\157\230\180\158"
    }
  },
  AdvertisingWheel_Unback = {
    keyName = "AdvertisingWheel_Unback",
    moduleName = "client.slua.umg.activity.advertisingwheel.AdvertisingWheel_Unback",
    path = "/Game/Arts_UI/FromUMG/LotteryTemplate/LukcyunbackTemplate/LuckyunbackTemplate_MainBG.LuckyunbackTemplate_MainBG",
    isMainUI = false,
    uiStat = {
      name = "\229\185\191\229\145\138\232\189\172\231\155\152\230\138\189\229\165\150-3500\231\137\136\233\128\154\231\148\168\229\188\130\230\173\165\229\174\185\229\153\168-\228\184\141\230\148\190\229\155\158-\232\147\157\230\180\158"
    }
  },
  LongTermSign_UIBP = {
    keyName = "LongTermSign_UIBP",
    moduleName = "client.slua.umg.activity.LongTermSign.LongTermSign_UIBP",
    path = "/Game/Mod/Lobby/Split/NewActivity/LongTermSign_UIBP.LongTermSign_UIBP",
    uiStat = {
      name = "\233\149\191\231\173\190\229\136\176\230\180\187\229\138\168"
    },
    isMainUI = false
  },
  Sink_Activity_UIBP = {
    keyName = "Sink_Activity_UIBP",
    moduleName = "client.slua.umg.activity.sink_activity.Sink_Activity_UIBP",
    path = "/Game/Mod/Lobby/Split/NewActivity/UMG/UI_BP/Sink/Sink_Activity_UIBP.Sink_Activity_UIBP",
    uiStat = {
      name = "\228\184\139\230\178\137\228\187\187\229\138\161\231\149\140\233\157\162"
    }
  },
  ActivityCenter_Main_UIBP = {
    keyName = "ActivityCenter_Main_UIBP",
    moduleName = "client.slua.umg.activity.ActivityCenter.ActivityCenter_Main_UIBP",
    jumpModuleID = BP_ENUM_MODULE_ACTIVITY,
    path = "/Game/Mod/Lobby/Split/NewActivity/Activty_UIBP_450.Activty_UIBP_450",
    enableCDNCompress = true,
    uiStat = {
      name = "\230\180\187\229\138\168\228\184\173\229\191\131"
    }
  },
  Activity_Exchange_UIBP = {
    keyName = "Activity_Exchange_UIBP",
    moduleName = "client.slua.umg.activity.new_activity_center.Activity_Exchange_UIBP",
    path = "/Game/Mod/Lobby/Split/NewActivity/Activty_Exchange_UIBP.Activty_Exchange_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\230\180\187\229\138\168\228\184\173\229\191\131-\232\175\190\231\168\139\232\161\168\231\177\187\229\173\144\230\180\187\229\138\168"
    }
  },
  Activity_Schedule_UIBP = {
    keyName = "Activity_Schedule_UIBP",
    moduleName = "client.slua.umg.activity.new_activity_center.Activity_Schedule_UIBP",
    path = "/Game/Mod/Lobby/Split/NewActivity/Activty_Schedule_UIBP.Activty_Schedule_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\230\180\187\229\138\168\228\184\173\229\191\131-\231\167\175\229\136\134\232\191\155\229\186\166"
    }
  },
  Activity_Image_UIBP = {
    keyName = "Activity_Image_UIBP",
    moduleName = "client.slua.umg.activity.new_activity_center.Activity_Image_UIBP",
    path = "/Game/Mod/Lobby/Split/NewActivity/Activty_Page3_UIBP.Activty_Page3_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\230\180\187\229\138\168\228\184\173\229\191\131-\229\164\167\229\155\190\230\180\187\229\138\168"
    }
  },
  Activity_Notice_UIBP = {
    keyName = "Activity_Notice_UIBP",
    moduleName = "client.slua.umg.activity.new_activity_center.Activity_Notice_UIBP",
    path = "/Game/Mod/Lobby/Split/NewActivity/Activty_Page2_UIBP.Activty_Page2_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\230\180\187\229\138\168\228\184\173\229\191\131-\231\186\175\230\150\135\229\173\151\229\133\172\229\145\138"
    }
  },
  Activty_Page2_UIBP_New = {
    keyName = "Activty_Page2_UIBP_New",
    moduleName = "client.slua.umg.activity.new_activity_center.Activty_Page2_UIBP_New",
    path = "/Game/Mod/Lobby/Split/NewActivity/Activty_Page2_UIBP_New.Activty_Page2_UIBP_New",
    isMainUI = false,
    uiStat = {
      name = "\230\180\187\229\138\168\228\184\173\229\191\131-\229\155\190\230\150\135\230\183\183\229\144\136\229\133\172\229\145\138"
    }
  },
  Activity_Text_UIBP = {
    keyName = "Activity_Text_UIBP",
    moduleName = "client.slua.umg.activity.new_activity_center.Activity_Text_UIBP",
    path = "/Game/Mod/Lobby/Split/NewActivity/Activty_Page4_UIBP.Activty_Page4_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\230\180\187\229\138\168\228\184\173\229\191\131-\231\186\175\230\150\135\229\173\151\230\180\187\229\138\168"
    }
  },
  Activity_EntrySet_UIBP = {
    keyName = "Activity_EntrySet_UIBP",
    moduleName = "client.slua.umg.activity.new_activity_center.Activity_EntrySet_UIBP",
    path = "/Game/Mod/Lobby/Split/NewActivity/Activty_EntrySet_UIBP.Activty_EntrySet_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\230\180\187\229\138\168\228\184\173\229\191\131-banner\229\155\190\230\180\187\229\138\168"
    }
  },
  PassworRedEnvelope_UIBP = {
    keyName = "PassworRedEnvelope_UIBP",
    moduleName = "client.slua.umg.activity.new_activity_center.PassworRedEnvelope_UIBP",
    path = "/Game/Mod/Lobby/Split/NewActivity/PassworRedEnvelope_UIBP.PassworRedEnvelope_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\230\180\187\229\138\168\228\184\173\229\191\131-\229\143\163\228\187\164\231\186\162\229\140\133"
    }
  },
  new_activity_exchange = {
    keyName = "new_activity_exchange",
    moduleName = "client.slua.umg.activity.new_activity_center.new_activity_exchange",
    path = "/Game/UMG/UI_BP/Common/Comon_ExchangeProps_UIBP_slua.Comon_ExchangeProps_UIBP_slua",
    asy = true,
    uiStat = {
      name = "\230\180\187\229\138\168\228\184\173\229\191\131-\229\133\145\230\141\162\231\149\140\233\157\162"
    }
  },
  Activity_Area_UIBP = {
    keyName = "Activity_Area_UIBP",
    moduleName = "client.slua.umg.activity.Area.Activity_Area_UIBP",
    path = "/Game/Mod/Lobby/Split/NewActivity/Area_Activity_UIBP.Area_Activity_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\230\180\187\229\138\168\228\184\173\229\191\131-\229\140\186\229\159\159\229\140\150\230\180\187\229\138\168"
    }
  },
  Activity_Gradually_UIBP = {
    keyName = "Activity_Gradually_UIBP",
    moduleName = "client.slua.umg.activity.new_activity_center.Activity_Gradually_UIBP",
    path = "/Game/Mod/Lobby/Split/NewActivity/Gradually_Activity_UIBP.Gradually_Activity_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\230\180\187\229\138\168\228\184\173\229\191\131-\229\141\176\229\186\166\231\137\136\233\152\182\230\174\181\230\128\167\232\167\163\233\148\129\229\158\139\230\168\161\230\157\191\230\180\187\229\138\168"
    }
  },
  Activity_JumpEntry_UIBP = {
    keyName = "Activity_JumpEntry_UIBP",
    moduleName = "client.slua.umg.activity.new_activity_center.Activity_JumpEntry_UIBP",
    path = "/Game/Mod/Lobby/Split/NewActivity/Activity_JumpEntry_UIBP.Activity_JumpEntry_UIBP",
    isMainUI = false,
    asy = true,
    uiStat = {
      name = "\230\180\187\229\138\168\228\184\173\229\191\131-\232\183\179\232\189\172\229\133\165\229\143\163\230\140\137\233\146\174"
    }
  },
  ReturnActivity_Return_Item = {
    keyName = "ReturnActivity_Return_Item",
    moduleName = "client.slua.umg.return_activity.item.ReturnActivity_Return_Item",
    path = "/Game/UMG/UI_BP/ReturnActivity/Items/ReturnActivity_Return_Item.ReturnActivity_Return_Item",
    isSingleton = false,
    uiStat = {
      name = "200\229\155\158\230\181\129\230\180\187\229\138\168-\231\167\175\229\136\134\229\165\150\229\138\177item"
    }
  },
  ReturnActivity_Newest_Item = {
    keyName = "ReturnActivity_Newest_Item",
    moduleName = "client.slua_ui_framework.base",
    path = "/Game/UMG/UI_BP/ReturnActivity/Items/ReturnActivity_Newest_Item.ReturnActivity_Newest_Item",
    isSingleton = false,
    isMainUI = false
  },
  ReturnActivity_GamePrivileges_UIBP = {
    keyName = "ReturnActivity_GamePrivileges_UIBP",
    moduleName = "client.slua.umg.return_activity.ReturnActivity_GamePrivileges_UIBP",
    path = "/Game/UMG/UI_BP/ReturnActivity/ReturnActivity_GamePrivileges_UIBP.ReturnActivity_GamePrivileges_UIBP",
    uiStat = {
      name = "200\229\155\158\230\181\129\230\180\187\229\138\168-\229\175\185\229\177\128\231\137\185\230\157\131\229\188\185\231\170\151\231\149\140\233\157\162"
    }
  },
  ReturnActivity_GamePrivileges02_UIBP = {
    keyName = "ReturnActivity_GamePrivileges02_UIBP",
    moduleName = "client.slua.umg.return_activity.ReturnActivity_GamePrivileges02_UIBP",
    path = "/Game/UMG/UI_BP/ReturnActivity/ReturnActivity_GamePrivileges02_UIBP.ReturnActivity_GamePrivileges02_UIBP",
    uiStat = {
      name = "230\229\155\158\230\181\129\230\180\187\229\138\168-\229\175\185\229\177\128\231\137\185\230\157\131\229\177\149\231\164\186\229\188\185\231\170\151\231\149\140\233\157\162"
    }
  },
  ReturnActivity_Anniversary_Tips_UIBP = {
    keyName = "ReturnActivity_Anniversary_Tips_UIBP",
    moduleName = "client.slua.umg.return_activity.ReturnActivity_Anniversary_Tips_UIBP",
    path = "/Game/UMG/UI_BP/ReturnActivity/ReturnActivity_Anniversary_Tips_UIBP.ReturnActivity_Anniversary_Tips_UIBP",
    uiStat = {
      name = "310\229\155\158\230\181\129\230\180\187\229\138\168-\230\175\143\230\151\165\228\187\187\229\138\161\231\149\140\233\157\162"
    }
  },
  ReturnActivity_7days_UIBP = {
    keyName = "ReturnActivity_7days_UIBP",
    moduleName = "client.slua.umg.return_activity.ReturnActivity_7days_UIBP",
    path = "/Game/UMG/UI_BP/ReturnActivity/ReturnActivity_7days_UIBP.ReturnActivity_7days_UIBP",
    uiStat = {
      name = "200\229\155\158\230\181\129\231\142\169\229\174\182-\229\155\158\229\189\146\231\173\190\229\136\176"
    },
    AndroidBackType = EAndroidBackType.Ban,
    isMainUI = false
  },
  ReturnActivity_7days02_UIBP = {
    keyName = "ReturnActivity_7days02_UIBP",
    moduleName = "client.slua.umg.return_activity.ReturnActivity_7days_UIBP",
    path = "/Game/UMG/UI_BP/ReturnActivity/ReturnActivity_7days02_UIBP.ReturnActivity_7days02_UIBP",
    uiStat = {
      name = "200\229\155\158\230\181\129\231\142\169\229\174\182-\229\155\158\229\189\146\231\173\190\229\136\176\230\139\141\232\132\184"
    }
  },
  ReturnActivity_Newest_UIBP = {
    keyName = "ReturnActivity_Newest_UIBP",
    moduleName = "client.slua.umg.return_activity.ReturnActivity_Newest_UIBP",
    path = "/Game/UMG/UI_BP/ReturnActivity/ReturnActivity_Newest_UIBP.ReturnActivity_Newest_UIBP",
    uiStat = {
      name = "200\229\155\158\230\181\129\231\142\169\229\174\182-\231\178\190\229\189\169\228\184\138\230\150\176\230\150\176\229\188\185\231\170\151"
    }
  },
  ReturnActivity_Video_UIBP = {
    keyName = "ReturnActivity_Video_UIBP",
    moduleName = "client.slua.umg.return_activity.ReturnActivity_Video_UIBP",
    path = "/Game/UMG/UI_BP/ReturnActivity/ReturnActivity_Video_UIBP.ReturnActivity_Video_UIBP",
    loadFromPool = EUIConfigPoolType.None,
    uiStat = {
      name = "200\229\155\158\230\181\129\231\142\169\229\174\182-\228\184\137\229\185\149\229\138\168\231\148\187\229\188\185\231\170\151"
    }
  },
  ReturnActivity_Package_UIBP = {
    keyName = "ReturnActivity_Package_UIBP",
    moduleName = "client.slua.umg.return_activity.ReturnActivity_Package_UIBP",
    path = "/Game/UMG/UI_BP/ReturnActivity/ReturnActivity_Package_UIBP.ReturnActivity_Package_UIBP",
    uiStat = {
      name = "230\229\155\158\230\181\129\228\184\187\230\139\141\232\132\184"
    }
  },
  ReturnActivity_FristBattle_Popup_UIBP = {
    keyName = "ReturnActivity_FristBattle_Popup_UIBP",
    moduleName = "client.slua.umg.return_activity.ReturnActivity_FristBattle_Popup_UIBP",
    path = "/Game/UMG/UI_BP/ReturnActivity/ReturnActivity_FristBattle_Popup_UIBP.ReturnActivity_FristBattle_Popup_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    uiStat = {
      name = "\229\155\158\230\181\129\233\166\150\229\177\128\229\188\149\229\175\188\230\139\141\232\132\184"
    }
  },
  ReturnActivity_Tips_UIBP = {
    keyName = "ReturnActivity_Tips_UIBP",
    moduleName = "client.slua.umg.return_activity.ReturnActivity_Tips_UIBP",
    path = "/Game/UMG/UI_BP/ReturnActivity/ReturnActivity_Tips_UIBP.ReturnActivity_Tips_UIBP",
    uiStat = {
      name = "230\229\155\158\230\181\129tips"
    },
    AndroidBackType = EAndroidBackType.Ban
  },
  ReturnActivity_Tips_Child_UIBP = {
    keyName = "ReturnActivity_Tips_Child_UIBP",
    moduleName = "client.slua.umg.return_activity.ReturnActivity_Tips_UIBP",
    path = "/Game/UMG/UI_BP/ReturnActivity/ReturnActivity_Tips_UIBP.ReturnActivity_Tips_UIBP",
    isMainUI = false,
    uiStat = {
      name = "230\229\155\158\230\181\129tips"
    },
    AndroidBackType = EAndroidBackType.Ban
  },
  ReturnActivity_Video_Item = {
    keyName = "ReturnActivity_Video_Item",
    moduleName = "client.slua_ui_framework.base",
    path = "/Game/UMG/UI_BP/ReturnActivity/Items/ReturnActivity_Video_Item01.ReturnActivity_Video_Item01",
    isSingleton = false,
    isMainUI = false
  },
  ReturnActivity_Main_UIBP = {
    keyName = "ReturnActivity_Main_UIBP",
    moduleName = "client.slua.umg.ReturnActivity.ReturnActivity_Main_UIBP",
    path = "/Game/UMG/UI_BP/ReturnActivity/ReturnActivity_Main_UIBP.ReturnActivity_Main_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    uiStat = {
      name = "\229\155\158\230\181\129\228\184\187\231\149\140\233\157\162"
    }
  },
  ReturnActivity_GamePrivileges_01_UIBP = {
    keyName = "ReturnActivity_GamePrivileges_01_UIBP",
    moduleName = "client.slua.umg.ReturnActivity.ReturnActivity_GamePrivileges_01_UIBP",
    path = "/Game/UMG/UI_BP/ReturnActivity/ReturnActivity_GamePrivileges_01_UIBP.ReturnActivity_GamePrivileges_01_UIBP",
    uiStat = {
      name = "\229\155\158\230\181\129\231\137\185\230\157\131\231\149\140\233\157\162"
    },
    isMainUI = false
  },
  ReturnActivity_Newest03_UIBP = {
    keyName = "ReturnActivity_Newest03_UIBP",
    moduleName = "client.slua.umg.ReturnActivity.ReturnActivity_Newest03_UIBP",
    path = "/Game/UMG/UI_BP/ReturnActivity/ReturnActivity_Newest03_UIBP.ReturnActivity_Newest03_UIBP",
    uiStat = {
      name = "\230\150\176\229\155\158\230\181\129\228\184\138\230\150\176\231\149\140\233\157\162"
    },
    isMainUI = false
  },
  ReturnActivity_SpeciallyPreferential_UIBP = {
    keyName = "ReturnActivity_SpeciallyPreferential_UIBP",
    moduleName = "client.slua.umg.ReturnActivity.ReturnActivity_SpeciallyPreferential_UIBP",
    path = "/Game/UMG/UI_BP/ReturnActivity/ReturnActivity_SpeciallyPreferential_UIBP.ReturnActivity_SpeciallyPreferential_UIBP",
    uiStat = {
      name = "\229\155\158\230\181\129\231\137\185\230\131\160\231\149\140\233\157\162"
    },
    isMainUI = false
  },
  ReturnActivity_SpeciallyPreferential_UIBP_01 = {
    keyName = "ReturnActivity_SpeciallyPreferential_UIBP_01",
    moduleName = "client.slua.umg.ReturnActivity.ReturnActivity_SpeciallyPreferential_UIBP_01",
    path = "/Game/UMG/UI_BP/ReturnActivity/ReturnActivity_SpeciallyPreferential_UIBP_01.ReturnActivity_SpeciallyPreferential_UIBP_01",
    uiStat = {
      name = "\229\155\158\230\181\129\231\137\185\230\131\160\231\149\140\233\157\162"
    },
    isMainUI = false
  },
  ReturnActivity_Questionnaire_UIBP = {
    keyName = "ReturnActivity_Questionnaire_UIBP",
    moduleName = "client.slua.umg.ReturnActivity.ReturnActivity_Questionnaire_UIBP",
    path = "/Game/UMG/UI_BP/ReturnActivity/ReturnActivity_Questionnaire_UIBP.ReturnActivity_Questionnaire_UIBP",
    uiStat = {
      name = "\229\155\158\230\181\129\233\151\174\229\141\183\232\176\131\230\159\165"
    },
    isMainUI = false
  },
  Home_NewTheme_Popup_UIBP = {
    keyName = "Home_NewTheme_Popup_UIBP",
    moduleName = "client.slua.umg.Home.AnniversaryActivity.Home_NewTheme_Popup_UIBP",
    path = "/Game/UMG/UI_BP/Home/AnniversaryActivity/Home_NewTheme_Popup_UIBP.Home_NewTheme_Popup_UIBP",
    uiStat = {
      name = "\229\164\167\229\142\133-\229\174\182\229\155\173\230\150\176\228\184\187\233\162\152-\230\139\141\232\132\184\231\149\140\233\157\162"
    }
  },
  Home_NewThemeMain_UIBP = {
    keyName = "Home_NewThemeMain_UIBP",
    moduleName = "client.slua.umg.Home.AnniversaryActivity.Home_NewThemeMain_UIBP",
    path = "/Game/UMG/UI_BP/Home/AnniversaryActivity/Home_NewThemeMain_UIBP.Home_NewThemeMain_UIBP",
    jumpModuleID = BP_ENUM_MODULE_HOME_NEW_THEME,
    uiStat = {
      name = "\229\164\167\229\142\133-\229\174\182\229\155\173\230\150\176\228\184\187\233\162\152-\228\184\187\231\149\140\233\157\162"
    }
  },
  Home_NewTheme_Collect_UIBP = {
    keyName = "Home_NewTheme_Collect_UIBP",
    moduleName = "client.slua.umg.Home.AnniversaryActivity.Home_NewTheme_Collect_UIBP",
    path = "/Game/UMG/UI_BP/Home/AnniversaryActivity/Home_NewTheme_Collect_UIBP.Home_NewTheme_Collect_UIBP",
    AndroidBackType = EAndroidBackType.Skip,
    uiStat = {
      name = "\229\164\167\229\142\133-\229\174\182\229\155\173\230\150\176\228\184\187\233\162\152-\229\165\150\229\138\177\231\149\140\233\157\162"
    }
  },
  Elegant_Ancient_Capital_UIBP = {
    keyName = "Elegant_Ancient_Capital_UIBP",
    moduleName = "client.slua.umg.Home.Elegant_Ancient_Capital.Elegant_Ancient_Capital_UIBP",
    path = "/Game/Mod/Lobby/Split/NewActivity/UMG/UI_BP/Home/Activity/Elegant_Ancient_Capital_UIBP.Elegant_Ancient_Capital_UIBP",
    isMainUI = false,
    AndroidBackType = EAndroidBackType.Skip,
    uiStat = {
      name = "\229\174\182\229\155\173\229\149\134\229\159\142\230\180\187\229\138\168\231\149\140\233\157\162"
    }
  },
  Elegant_Ancient_Capital_UIBP_New = {
    keyName = "Elegant_Ancient_Capital_UIBP_New",
    moduleName = "client.slua.umg.Home.Elegant_Ancient_Capital.Elegant_Ancient_Capital_UIBP",
    path = "/Game/Mod/Lobby/Split/NewActivity/UMG/UI_BP/Home/Activity/Elegant_Ancient_Capital_UIBP.Elegant_Ancient_Capital_UIBP",
    jumpModuleID = BP_EMUM_MODULE_HOME_PROMOTION_ACTIVITY,
    uiStat = {
      name = "\229\174\182\229\155\173\229\149\134\229\159\142\230\180\187\229\138\168\231\149\140\233\157\162-\230\150\176"
    }
  },
  HomeActivity_Style_A_UIBP = {
    keyName = "HomeActivity_Style_A_UIBP",
    moduleName = "client.slua.umg.Home.Elegant_Ancient_Capital.HomeActivity_Style_UIBP",
    path = "/Game/Mod/Lobby/Split/NewActivity/UMG/UI_BP/Home/Activity/HomeActivity_Style_A_UIBP.HomeActivity_Style_A_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\174\182\229\155\173\229\149\134\229\159\142\230\180\187\229\138\168\228\184\128\230\156\159\229\174\164\229\134\133\231\149\140\233\157\162"
    }
  },
  HomeActivity_Style_B_UIBP = {
    keyName = "HomeActivity_Style_B_UIBP",
    moduleName = "client.slua.umg.Home.Elegant_Ancient_Capital.HomeActivity_Style_UIBP",
    path = "/Game/Mod/Lobby/Split/NewActivity/UMG/UI_BP/Home/Activity/HomeActivity_Style_B_UIBP.HomeActivity_Style_B_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\174\182\229\155\173\229\149\134\229\159\142\230\180\187\229\138\168\228\186\140\230\156\159\229\174\164\229\134\133\231\149\140\233\157\162"
    }
  },
  HomeActivity_Style_C_UIBP = {
    keyName = "HomeActivity_Style_C_UIBP",
    moduleName = "client.slua.umg.Home.Elegant_Ancient_Capital.HomeActivity_Style_UIBP",
    path = "/Game/Mod/Lobby/Split/NewActivity/UMG/UI_BP/Home/Activity/HomeActivity_Style_C_UIBP.HomeActivity_Style_C_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\174\182\229\155\173\229\149\134\229\159\142\230\180\187\229\138\168\228\184\128\230\156\159\229\174\164\229\164\150\231\149\140\233\157\162"
    }
  },
  HomeActivity_Style_D_UIBP = {
    keyName = "HomeActivity_Style_D_UIBP",
    moduleName = "client.slua.umg.Home.Elegant_Ancient_Capital.HomeActivity_Style_UIBP",
    path = "/Game/Mod/Lobby/Split/NewActivity/UMG/UI_BP/Home/Activity/HomeActivity_Style_D_UIBP.HomeActivity_Style_D_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\174\182\229\155\173\229\149\134\229\159\142\230\180\187\229\138\168\228\186\140\230\156\159\229\174\164\229\164\150\231\149\140\233\157\162"
    }
  },
  ScrapGold_Popup_ActivityDescription_UIBP = {
    keyName = "ScrapGold_Popup_ActivityDescription_UIBP",
    moduleName = "client.slua.umg.SpecialOffer.Popup.ScrapGold_Popup_ActivityDescription_UIBP",
    path = "/Game/Arts_UI/FromUMG/SpecialOffer/ScrapGold/UIBP/ScrapGold_Popup_ActivityDescription_UIBP.ScrapGold_Popup_ActivityDescription_UIBP",
    uiStat = {
      name = "\231\165\158\231\167\152\229\183\165\229\157\138\230\138\152\230\137\163\230\143\143\232\191\176"
    }
  },
  ReturnActivity_WelcomeBack_UIBP = {
    keyName = "ReturnActivity_WelcomeBack_UIBP",
    moduleName = "client.slua.umg.ReturnActivity.ReturnActivity_WelcomeBack_UIBP",
    path = "/Game/UMG/UI_BP/ReturnActivity/ReturnActivity_WelcomeBack_UIBP.ReturnActivity_WelcomeBack_UIBP",
    uiStat = {
      name = " \229\155\158\230\181\129-\230\172\162\232\191\142\230\139\141\232\132\184\231\149\140\233\157\162"
    }
  },
  ReturnActivity_Slap_Main_UIBP = {
    keyName = "ReturnActivity_Slap_Main_UIBP",
    moduleName = "client.slua.umg.ReturnActivity.ReturnActivity_Slap_Main_UIBP",
    path = "/Game/UMG/UI_BP/ReturnActivity/ReturnActivity_Slap_Main_UIBP.ReturnActivity_Slap_Main_UIBP",
    uiStat = {
      name = "\229\155\158\230\181\129-\230\139\141\232\132\184\228\184\178\232\129\148\229\174\185\229\153\168"
    }
  },
  ReturnActivity_Achievement_UIBP = {
    keyName = "ReturnActivity_Achievement_UIBP",
    moduleName = "client.slua.umg.ReturnActivity.ReturnActivity_Achievement_UIBP",
    path = "/Game/UMG/UI_BP/ReturnActivity/ReturnActivity_Achievement_UIBP.ReturnActivity_Achievement_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    uiStat = {
      name = "\229\155\158\230\181\129-\230\139\141\232\132\184-\230\136\144\229\176\177\233\169\177\229\138\168\229\158\139"
    }
  },
  ReturnActivity_ContentDriven_UIBP = {
    keyName = "ReturnActivity_ContentDriven_UIBP",
    moduleName = "client.slua.umg.ReturnActivity.ReturnActivity_ContentDriven_UIBP",
    path = "/Game/UMG/UI_BP/ReturnActivity/ReturnActivity_ContentDriven_UIBP.ReturnActivity_ContentDriven_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    uiStat = {
      name = "\229\155\158\230\181\129-\230\139\141\232\132\184-\229\134\133\229\174\185\233\169\177\229\138\168\229\158\139"
    }
  },
  ReturnActivity_Version_Update_UIBP = {
    keyName = "ReturnActivity_Version_Update_UIBP",
    moduleName = "client.slua.umg.ReturnActivity.ReturnActivity_Version_Update_UIBP",
    path = "/Game/UMG/UI_BP/ReturnActivity/ReturnActivity_Version_Update_UIBP.ReturnActivity_Version_Update_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    uiStat = {
      name = "\229\155\158\230\181\129-\230\139\141\232\132\184-\231\137\136\230\155\180\230\143\144\233\134\146"
    }
  },
  ReturnActivity_Guide_Collection_UIBP = {
    keyName = "ReturnActivity_Guide_Collection_UIBP",
    moduleName = "client.slua.umg.ReturnActivity.ReturnActivity_Guide_Collection_UIBP",
    path = "/Game/UMG/UI_BP/ReturnActivity/ReturnActivity_Guide_Collection_UIBP.ReturnActivity_Guide_Collection_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    uiStat = {
      name = "\229\155\158\230\181\129\229\188\149\229\175\188\233\155\134\229\144\136\233\161\181"
    }
  },
  ReturnActivity_TastingType_UIBP = {
    keyName = "ReturnActivity_TastingType_UIBP",
    moduleName = "client.slua.umg.ReturnActivity.ReturnActivity_TastingType_UIBP",
    path = "/Game/UMG/UI_BP/ReturnActivity/ReturnActivity_TastingType_UIBP.ReturnActivity_TastingType_UIBP",
    handleJumpEvent = ENUM_HANDLE_JUMP_EVENT.CLOSE_AND_RESHOW,
    uiStat = {
      name = "\229\155\158\230\181\129-\230\139\141\232\132\184-\229\176\157\233\178\156\229\158\139"
    }
  },
  ReturnActivity_First_UIBP = {
    keyName = "ReturnActivity_First_UIBP",
    moduleName = "client.slua.umg.return_activity.slap.ReturnActivity_First_UIBP",
    path = "/Game/UMG/UI_BP/ReturnActivity/ReturnActivity_First_UIBP.ReturnActivity_First_UIBP",
    containerName = UIContainers.Default,
    uiStat = {
      name = "\229\155\158\230\181\129\233\166\150\229\177\128\229\165\150\229\138\177\230\139\141\232\132\184"
    }
  },
  Warm_Up_Group_Linkage_UIBP = {
    moduleName = "client.slua.umg.warm_up_group_linkage.Warm_Up_Group_Linkage_UIBP",
    path = "/Game/Arts_UI/FromUMG/Activity/WarmUpGroupLinkage/Warm_Up_Group_Linkage_UIBP.Warm_Up_Group_Linkage_UIBP",
    asy = true,
    isMainUI = true,
    isSingleton = true,
    uiStat = {
      name = "\233\172\188\230\150\176\229\168\152\233\162\132\231\131\173\233\155\134\229\144\136\233\161\181"
    }
  },
  VersionAlbum_Main_My = {
    keyName = "VersionAlbum_Main_My",
    moduleName = "client.slua.umg.version_album.VersionAlbum_Main_My",
    path = "/Game/UMG/UI_BP/EventPhoto/VersionAlbum_Main_UIBP.VersionAlbum_Main_UIBP",
    jumpModuleID = BP_ENUM_MODULE_MY_VERSION_ALBUM,
    uiStat = {
      name = "\231\137\136\230\156\172\231\155\184\229\134\140-\228\184\187\231\149\140\233\157\162-\232\135\170\229\183\177\231\154\132"
    }
  },
  VersionAlbum_Main_Other = {
    keyName = "VersionAlbum_Main_Other",
    moduleName = "client.slua.umg.version_album.VersionAlbum_Main_Other",
    path = "/Game/UMG/UI_BP/EventPhoto/VersionAlbum_Main_UIBP.VersionAlbum_Main_UIBP",
    uiStat = {
      name = "\231\137\136\230\156\172\231\155\184\229\134\140-\228\184\187\231\149\140\233\157\162-\228\187\150\228\186\186\231\154\132"
    }
  },
  VersionAlbum_Detail_UIBP = {
    keyName = "VersionAlbum_Detail_UIBP",
    moduleName = "client.slua.umg.version_album.VersionAlbum_Detail_UIBP",
    path = "/Game/UMG/UI_BP/EventPhoto/VersionAlbum_Detail_UIBP.VersionAlbum_Detail_UIBP",
    uiStat = {
      name = "\231\137\136\230\156\172\231\155\184\229\134\140-\232\175\166\230\131\133"
    }
  },
  VersionAlbum_Guide_UIBP = {
    keyName = "VersionAlbum_Guide_UIBP",
    moduleName = "client.slua.umg.version_album.VersionAlbum_Guide_UIBP",
    path = "/Game/UMG/UI_BP/EventPhoto/VersionAlbum_Guide_UIBP.VersionAlbum_Guide_UIBP",
    uiStat = {
      name = "\231\137\136\230\156\172\231\155\184\229\134\140-\229\188\149\229\175\188"
    }
  },
  VersionAlbum_Add_Photo_UIBP = {
    keyName = "VersionAlbum_Add_Photo_UIBP",
    moduleName = "client.slua.umg.version_album.VersionAlbum_Add_Photo_UIBP",
    path = "/Game/UMG/UI_BP/EventPhoto/VersionAlbum_Add_Photo_UIBP.VersionAlbum_Add_Photo_UIBP",
    uiStat = {
      name = "\231\137\136\230\156\172\231\155\184\229\134\140-\230\183\187\229\138\160\231\133\167\231\137\135"
    }
  },
  VersionAlbum_NotUnlocked_UIBP = {
    keyName = "VersionAlbum_NotUnlocked_UIBP",
    moduleName = "client.slua.umg.EventPhoto.VersionAlbum_NotUnlocked_UIBP",
    path = "/Game/UMG/UI_BP/EventPhoto/VersionAlbum_NotUnlocked_UIBP.VersionAlbum_NotUnlocked_UIBP",
    uiStat = {
      name = "\229\141\161\231\137\140\232\175\166\230\131\133-\230\156\170\232\167\163\233\148\129"
    }
  },
  VersionAlbum_ContainerTrucks_Popup = {
    keyName = "VersionAlbum_ContainerTrucks_Popup",
    moduleName = "client.slua.umg.EventPhoto.Popup.VersionAlbum_ContainerTrucks_Popup",
    path = "/Game/UMG/UI_BP/EventPhoto/Popup/VersionAlbum_ContainerTrucks_Popup.VersionAlbum_ContainerTrucks_Popup",
    uiStat = {
      name = "\229\141\161\231\137\140\232\175\166\230\131\133-\229\183\178\232\167\163\233\148\129"
    }
  },
  VersionAlbum_Preview_UIBP = {
    keyName = "VersionAlbum_Preview_UIBP",
    moduleName = "client.slua.umg.EventPhoto.VersionAlbum_Preview_UIBP",
    path = "/Game/UMG/UI_BP/EventPhoto/VersionAlbum_Preview_UIBP.VersionAlbum_Preview_UIBP",
    uiStat = {
      name = "\229\141\161\231\137\140\233\152\133\232\167\136-\229\177\149\231\164\186\230\149\136\230\158\156"
    }
  },
  VersionAlbum_Preview_CardList_UIBP = {
    keyName = "VersionAlbum_Preview_CardList_UIBP",
    moduleName = "client.slua.umg.EventPhoto.Popup.VersionAlbum_Preview_CardList_UIBP",
    path = "/Game/UMG/UI_BP/EventPhoto/Popup/VersionAlbum_Preview_CardList_UIBP.VersionAlbum_Preview_CardList_UIBP",
    closeOnSwitch = false,
    uiStat = {
      name = "Loading\231\149\140\233\157\162-\229\177\149\231\164\186\233\152\159\228\188\141\229\134\133\231\154\132\229\141\161\231\137\140"
    }
  },
  Warm_Up_Group_UIBP = {
    keyName = "Warm_Up_Group_UIBP",
    moduleName = "client.slua.umg.warm_up_group.Warm_Up_Group_UIBP",
    path = "/Game/Arts_UI/FromUMG/Activity/WarmUpGroup/UIBP/Warm_Up_Group_UIBP.Warm_Up_Group_UIBP",
    asy = true,
    isMainUI = true,
    isSingleton = true,
    uiStat = {
      name = "\233\162\132\231\131\173\231\187\132\229\155\162"
    }
  },
  Warm_Up_Group_TeamInvitePopup_UIBP = {
    keyName = "Warm_Up_Group_TeamInvitePopup_UIBP",
    moduleName = "client.slua.umg.warm_up_group.Popup.Warm_Up_Group_TeamInvitePopup_UIBP",
    path = "/Game/Arts_UI/FromUMG/Activity/WarmUpGroup/UIBP/Warm_Up_Group_TeamInvitePopup_UIBP.Warm_Up_Group_TeamInvitePopup_UIBP",
    asy = true,
    isMainUI = true,
    isSingleton = true,
    uiStat = {
      name = "\233\162\132\231\131\173\231\187\132\229\155\162\233\130\128\232\175\183\231\149\140\233\157\162"
    }
  },
  Warm_Up_Group_Join_UIBP = {
    keyName = "Warm_Up_Group_Join_UIBP",
    moduleName = "client.slua.umg.warm_up_group.Popup.Warm_Up_Group_Join_UIBP",
    path = "/Game/Arts_UI/FromUMG/Activity/WarmUpGroup/UIBP/Warm_Up_Group_Join_UIBP.Warm_Up_Group_Join_UIBP",
    asy = true,
    isMainUI = true,
    isSingleton = true,
    uiStat = {
      name = "\233\162\132\231\131\173\231\187\132\229\155\162\232\162\171\233\130\128\232\175\183\231\149\140\233\157\162"
    }
  },
  ReturnActivity_Player_Tag_Item = {
    keyName = "ReturnActivity_Player_Tag_Item",
    moduleName = "client.slua.umg.ReturnActivity.Items.ReturnActivity_Player_Tag_Item",
    path = "/Game/UMG/UI_BP/ReturnActivity/Items/ReturnActivity_Player_Tag_Item.ReturnActivity_Player_Tag_Item",
    AndroidBackType = EAndroidBackType.Skip,
    isMainUI = false,
    isSingleton = false
  },
  ReturnActivity_Reward_Homepage_UIBP = {
    keyName = "ReturnActivity_Reward_Homepage_UIBP",
    moduleName = "client.slua.umg.ReturnActivity.ReturnActivity_Reward_Homepage_UIBP",
    path = "/Game/UMG/UI_BP/ReturnActivity/ReturnActivity_Reward_Homepage_UIBP.ReturnActivity_Reward_Homepage_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\155\158\230\181\129\230\180\187\229\138\168-\229\165\150\229\138\177\228\184\187\233\161\181"
    }
  },
  ReturnAtivity_Popup_MultipleChoose_UIBP = {
    keyName = "ReturnAtivity_Popup_MultipleChoose_UIBP",
    moduleName = "client.slua.umg.ReturnActivity.Popup.ReturnAtivity_Popup_MultipleChoose_UIBP",
    path = "/Game/UMG/UI_BP/ReturnActivity/Popup/ReturnAtivity_Popup_MultipleChoose_UIBP.ReturnAtivity_Popup_MultipleChoose_UIBP",
    uiStat = {
      name = "\229\155\158\230\181\129\230\180\187\229\138\168-\229\165\150\229\138\177\233\128\137\230\139\169\229\188\185\231\170\151"
    }
  },
  ReturnActivity_Reward_Middle_Item_UIBP = {
    keyName = "ReturnActivity_Reward_Middle_Item_UIBP",
    moduleName = "client.slua.umg.ReturnActivity.Items.ReturnActivity_Reward_Middle_Item_UIBP",
    path = "/Game/UMG/UI_BP/ReturnActivity/Items/ReturnActivity_Reward_Middle_Item_UIBP.ReturnActivity_Reward_Middle_Item_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\229\155\158\230\181\129\230\180\187\229\138\168-\229\165\150\229\138\177\228\184\187\233\161\181-\228\184\173\233\151\180\230\140\130\232\189\189"
    }
  },
  ReturnActivity_Reward_Middle_Single_Item_UIBP = {
    keyName = "ReturnActivity_Reward_Middle_Single_Item_UIBP",
    moduleName = "client.slua.umg.ReturnActivity.Items.ReturnActivity_Reward_Middle_Single_Item_UIBP",
    isMainUI = false,
    path = "/Game/UMG/UI_BP/ReturnActivity/Items/ReturnActivity_Reward_Middle_Single_Item_UIBP.ReturnActivity_Reward_Middle_Single_Item_UIBP",
    uiStat = {
      name = "\229\155\158\230\181\129\230\180\187\229\138\168-\229\165\150\229\138\177\228\184\187\233\161\181-\228\184\173\233\151\180\230\140\130\232\189\189-\229\141\149\231\171\139\231\187\152"
    }
  },
  Matchmaking_Enter_UIBP = {
    keyName = "Matchmaking_Enter_UIBP",
    moduleName = "client.slua.umg.lobby_activity.Matchmaking.Matchmaking_Enter_UIBP",
    path = "/Game/UMG/UI_BP/Lobby_Activity/Matchmaking/Matchmaking_Enter_UIBP.Matchmaking_Enter_UIBP",
    isMainUI = false,
    isSingleton = false,
    uiStat = {
      name = "\231\187\147\231\188\152\230\180\187\229\138\168-\229\133\165\229\143\163"
    }
  },
  Matchmaking_RightTab_UIBP = {
    keyName = "Matchmaking_RightTab_UIBP",
    moduleName = "client.slua.umg.lobby_activity.Matchmaking.Matchmaking_RightTab_UIBP",
    path = "/Game/UMG/UI_BP/Lobby_Activity/Matchmaking/Matchmaking_RightTab_UIBP.Matchmaking_RightTab_UIBP",
    jumpModuleID = BP_ENUM_MODULE_WEDDING_ACTIVITY,
    uiStat = {
      name = "\231\187\147\231\188\152\230\180\187\229\138\168-\228\184\187\231\149\140\233\157\162"
    }
  },
  Matchmaking_MarriageProcess_UIBP = {
    keyName = "Matchmaking_MarriageProcess_UIBP",
    moduleName = "client.slua.umg.lobby_activity.Matchmaking.Matchmaking_MarriageProcess_UIBP",
    path = "/Game/UMG/UI_BP/Lobby_Activity/Matchmaking/Matchmaking_MarriageProcess_UIBP.Matchmaking_MarriageProcess_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\231\187\147\231\188\152\230\180\187\229\138\168-\231\187\147\231\188\152\230\181\129\231\168\139\228\187\139\231\187\141\229\173\144\231\149\140\233\157\162"
    }
  },
  Matchmaking_Ceremony_UIBP = {
    keyName = "Matchmaking_Ceremony_UIBP",
    moduleName = "client.slua.umg.Lobby_Activity.Matchmaking.Matchmaking_Ceremony_UIBP",
    path = "/Game/UMG/UI_BP/Lobby_Activity/Matchmaking/Matchmaking_Ceremony_UIBP.Matchmaking_Ceremony_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\231\187\147\231\188\152\230\180\187\229\138\168-\231\187\147\231\188\152\228\187\170\229\188\143\228\187\139\231\187\141\229\173\144\231\149\140\233\157\162"
    }
  },
  Matchmaking_GetMarried_UIBP = {
    keyName = "Matchmaking_GetMarried_UIBP",
    moduleName = "client.slua.umg.lobby_activity.Matchmaking.Matchmaking_GetMarried_UIBP",
    path = "/Game/UMG/UI_BP/Lobby_Activity/Matchmaking/Matchmaking_GetMarried_UIBP.Matchmaking_GetMarried_UIBP",
    isMainUI = false,
    uiStat = {
      name = "\231\187\147\231\188\152\230\180\187\229\138\168-\230\136\145\232\166\129\231\187\147\231\188\152\229\173\144\231\149\140\233\157\162"
    }
  },
  Matchmaking_Pop_Publish_UIBP = {
    keyName = "Matchmaking_Pop_Publish_UIBP",
    moduleName = "client.slua.umg.Lobby_Activity.Matchmaking.Popup.Matchmaking_Pop_Publish_UIBP",
    path = "/Game/UMG/UI_BP/Lobby_Activity/Matchmaking/Popup/Matchmaking_Pop_Publish_UIBP.Matchmaking_Pop_Publish_UIBP",
    uiStat = {
      name = "\231\187\147\231\188\152\230\180\187\229\138\168-\229\143\145\229\184\131\229\188\185\231\170\151"
    }
  },
  fission_tab_page = {
    keyName = "fission_tab_page",
    moduleName = "client.slua.umg.NewUserFission.UIBP.fission_tab_page",
    path = "/Game/Arts_UI/FromUMG/InviteNewUser/UIBP/Fission_Main_Panel.Fission_Main_Panel",
    jumpModuleID = BP_ENUM_MODULE_FISSION_ACTIVITY,
    uiStat = {
      name = "\230\150\176\231\148\168\230\136\183\232\163\130\229\143\152\230\180\187\229\138\168-\228\184\187\231\149\140\233\157\162"
    }
  },
  fission_inviter_page = {
    keyName = "fission_inviter_page",
    moduleName = "client.slua.umg.NewUserFission.UIBP.fission_inviter_page",
    path = "/Game/Arts_UI/FromUMG/InviteNewUser/UIBP/Fission_Inviter_Page.Fission_Inviter_Page",
    AndroidBackType = EAndroidBackType.Skip,
    uiStat = {
      name = "\230\150\176\231\148\168\230\136\183\232\163\130\229\143\152\230\180\187\229\138\168-\233\130\128\232\175\183\232\128\133\231\149\140\233\157\162"
    }
  },
  fission_invitee_page = {
    keyName = "fission_invitee_page",
    moduleName = "client.slua.umg.NewUserFission.UIBP.fission_invitee_page",
    path = "/Game/Arts_UI/FromUMG/InviteNewUser/UIBP/Fission_Invitee_Page.Fission_Invitee_Page",
    AndroidBackType = EAndroidBackType.Skip,
    uiStat = {
      name = "\230\150\176\231\148\168\230\136\183\232\163\130\229\143\152\230\180\187\229\138\168-\232\162\171\233\130\128\232\175\183\232\128\133\231\149\140\233\157\162"
    }
  },
  fission_shop_page = {
    keyName = "fission_shop_page",
    moduleName = "client.slua.umg.NewUserFission.UIBP.fission_shop_page",
    path = "/Game/Arts_UI/FromUMG/InviteNewUser/UIBP/Fission_Shop_Pgae.Fission_Shop_Pgae",
    AndroidBackType = EAndroidBackType.Skip,
    uiStat = {
      name = "\230\150\176\231\148\168\230\136\183\232\163\130\229\143\152\230\180\187\229\138\168-\231\167\175\229\136\134\229\149\134\229\159\142\231\149\140\233\157\162"
    }
  },
  fission_history_popup = {
    keyName = "fission_history_popup",
    moduleName = "client.slua.umg.NewUserFission.UIBP.Popup.fission_history_popup",
    path = "/Game/Arts_UI/FromUMG/InviteNewUser/UIBP/Fission_History_Popup.Fission_History_Popup",
    uiStat = {
      name = "\230\150\176\231\148\168\230\136\183\232\163\130\229\143\152\230\180\187\229\138\168-\233\130\128\232\175\183\232\174\176\229\189\149\229\188\185\231\170\151"
    }
  },
  fission_share = {
    keyName = "fission_share",
    moduleName = "client.slua.umg.NewUserFission.UIBP.fission_share",
    path = "/Game/Arts_UI/FromUMG/InviteNewUser/UIBP/Fission_Share_UIBP.Fission_Share_UIBP",
    uiStat = {
      name = "\230\150\176\231\148\168\230\136\183\232\163\130\229\143\152\230\180\187\229\138\168-\229\136\134\228\186\171\231\149\140\233\157\162"
    }
  }
}
return activity_ui_configs