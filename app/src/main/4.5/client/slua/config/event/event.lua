require("client.slua.config.event.event_define")
require("client.slua.config.ClientMacros.bp_macros")
local Event_Config = {
  {
    eventType = EVENTTYPE_DATA_MGR,
    eventID = EVNETID_DATAMGR_ACTIVITY_CHANGE,
    moduleName = "client.logic.recharge.logic_recharge_purchase",
    funcName = "RefreshActivityInfo"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_SOCIAL_IS_LAND,
    moduleName = "client.network.Protocol.SocialIslandHandler",
    funcName = "OnJumpSocialIsLand"
  },
  {
    eventType = EVENTTYPE_LOGIN,
    eventID = EVENTID_BACKLOGIN,
    moduleName = "client.slua.logic.achievement.logic_achievement",
    funcName = "ClearCache"
  },
  {
    eventType = EVENTTYPE_LOGIN,
    eventID = EVENTID_BACKLOGIN,
    moduleName = "client.slua.logic.roleInfo.logic_roleinfo_title",
    funcName = "OnBackLogin"
  },
  {
    eventType = EVENTTYPE_LOGIN,
    eventID = EVENTID_BACKLOGIN,
    moduleName = "client.slua.logic.activity.newbie.logic_newbie_activity",
    funcName = "OnBackLogin"
  },
  {
    eventType = EVENTTYPE_LOGIN,
    eventID = EVENTID_BACKLOGIN,
    moduleName = "client.logic.decompose.logic_decompose",
    funcName = "OnBackLogin"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_SMALL_PAYMENT_EXCHANGE,
    moduleName = "client.slua.logic.SmallPayment.Logic_SmallPayment",
    funcName = "OnJumpByUrl"
  },
  {
    eventType = EVENTTYPE_LOGIN,
    eventID = EVENTID_BACKLOGIN,
    moduleName = "client.network.Protocol.NewbieGuideHandler",
    funcName = "OnLogOut"
  },
  {
    eventType = EVENTTYPE_STATE,
    eventID = EVENTID_ON_MODE_POST_SWITCH,
    moduleName = "client.common.luagc_strategy",
    funcName = "OnPostSceneLoad"
  },
  {
    eventType = EVENTTYPE_ACTION,
    eventID = EVENTID_NEWBIE_GUIDE_LOBBY_LOAD_DONE,
    moduleName = "client.slua.logic.guest_bind.logic_guest_bind_1700",
    funcName = "TryToShowMainPage"
  },
  {
    eventType = EVENTTYPE_STATE,
    eventID = EVENTID_ON_MODE_POST_SWITCH,
    moduleName = "client.slua.logic.guest_bind.logic_guest_bind_1700",
    funcName = "OnModePostSwitch"
  },
  {
    eventType = EVENTTYPE_CENTAURI_NOTIFY,
    eventID = EVENTID_CENTAURI_GET_INTRO_PRICE_INFO_NOTIFY,
    moduleName = "client.slua.logic.unknow_pass.logic_unknowpass_subscription",
    funcName = "GetCentauriIntroInfoFromCache"
  },
  {
    eventType = EVENTTYPE_CENTAURI_NOTIFY,
    eventID = EVENTID_CENTAURI_GET_GOODS_PRODUCT_INFO_NOTIFY,
    moduleName = "client.slua.logic.subscribe.logic_subscribe_carnival_activity",
    funcName = "GetCentauriGoodsInfoFromCache"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_EMUM_MODULE_SOTRE_PRIME,
    moduleName = "client.slua.logic.store.utils.store_utils",
    funcName = "ShowStorePrime"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_ACTIVITY,
    moduleName = "client.slua.logic.activity.logic_activity_mgr",
    funcName = "ShowActivityUI"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_SUPERCORE_ENTRY,
    moduleName = "client.slua.logic.activity.logic_activity_mgr",
    funcName = "OpenSuperCore"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_PREMIUM_HALL_ENTRY,
    moduleName = "client.slua.logic.activity.logic_activity_mgr",
    funcName = "OpenPremiumHallSVIP"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_SEASON,
    moduleName = "client.logic.season.logic_season",
    funcName = "ShowSeason"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_UNKNOW_PASS_LEVEL_SLAP,
    moduleName = "client.slua.logic.upass.levelSlap.logic_upass_level_slap",
    funcName = "ShowLevelSlap"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_PASS_LEVEL_UP_SLAP,
    moduleName = "client.slua.logic.upass.levelSlap.logic_upass_levelup_slap",
    funcName = "ShowSlap"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_PRIME_UNKNOW_PASS,
    moduleName = "client.slua.logic.unknow_pass.logic_unknowpass_subscription",
    funcName = "ShowSubScriptionUI"
  },
  {
    eventType = EVENTTYPE_LOGIN,
    eventID = EVENTID_BACKLOGIN,
    moduleName = "client.slua.logic.come_back.logic_assembly_activity",
    funcName = "Handle_LogOut"
  },
  {
    eventType = EVENTTYPE_LOGIN,
    eventID = EVENTID_BACKLOGIN,
    moduleName = "client.slua.logic.come_back.logic_facebook_friend",
    funcName = "Handle_LogOut"
  },
  {
    eventType = EVENTTYPE_DATA_MGR,
    eventID = EVNETID_DATAMGR_ACTIVITY_CHANGE,
    moduleName = "client.slua.logic.come_back.logic_assembly_activity",
    funcName = "ReqAssemblyRedInfo"
  },
  {
    eventType = EVENTTYPE_TEAMUP,
    eventID = EVENTID_TEAMUP_ACCEPT_INVITE,
    moduleName = "client.slua.logic.mvp_motion.logic_mvp_motion",
    funcName = "Event_Stop_Mvp_Motion"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_EMUM_MODULE_MAIN_CITY_DOWNLOAD_THEME,
    moduleName = "GameLua.Mod.MainCity.Client.logic.Process.main_city_process_util",
    funcName = "ShowMainCityDownloadTheme"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_EMUM_MODULE_FIT_VERSION_RECOMMEND_POPUP,
    moduleName = "client.slua.logic.download.bundle.logic_puffer_bundle",
    funcName = "ShowFitRecommendDownloadPopup"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_SEASON_REMIND,
    moduleName = "client.logic.season.logic_season",
    funcName = "ShowSeasonReminder"
  },
  {
    eventType = EVENTTYPE_STATE,
    eventID = EVENTID_ON_MODE_POST_SWITCH,
    moduleName = "client.logic.season.logic_season",
    funcName = "OnGameStateChange"
  },
  {
    eventType = EVENTTYPE_LOGIN,
    eventID = EVENTID_BACKLOGIN,
    moduleName = "client.slua.logic.person_space.logic_roleinfo_popularity",
    funcName = "Handle_LogOut"
  },
  {
    eventType = EVENTTYPE_LOBBY_SKIN,
    eventID = EVENTID_LOBBY_SKIN_CHANGE,
    moduleName = "client.slua.logic.luck_airdrop.logic_luck_air_drop",
    funcName = "RefreshLuckAirDropLoacation"
  },
  {
    eventType = EVENTTYPE_LOBBY_SKIN,
    eventID = EVENTID_LOBBY_SKIN_CHANGE,
    moduleName = "client.slua.umg.LuckyAirDrop.ui_airdrop_mesh",
    funcName = "ChangeSkin"
  },
  {
    eventType = EVENTTYPE_WARDROBE,
    eventID = EVENTID_WARDROBE_SWITCH_USE_ROLEWEAR,
    moduleName = "client.slua.logic.wardrobe.logic_wardrobe_avatar",
    funcName = "OnSelectFashionBagSucess"
  },
  {
    eventType = EVENTTYPE_DATA_MGR,
    eventID = EVENTID_DATAMGR_HALL_DEPOT_DATA_INIT,
    moduleName = "client.slua.logic.wardrobe.tab_surveillance",
    funcName = "OnHallDepotDataInit"
  },
  {
    eventType = EVENTTYPE_ARENA,
    eventID = EVENTID_ARENA_GET_AWARD_RSP,
    moduleName = "client.slua.logic.match.red_point.match_redpoint_data",
    funcName = "UpdateArena"
  },
  {
    eventType = EVENTTYPE_STATE,
    eventID = EVENTID_ON_MODE_PRE_SWITCH,
    moduleName = "client.slua.logic.wardrobe.tab_surveillance",
    funcName = "OnGameStateChange"
  },
  {
    eventType = EVENTTYPE_LOGIN,
    eventID = EVENTID_BACKLOGIN,
    moduleName = "client.slua.logic.championship.logic_championship_sponsor",
    funcName = "Handle_LogOut"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_QUALIFY,
    moduleName = "client.logic.lobby.logic_lobby_matchlist",
    funcName = "EnterQualifying"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_PLAYER_RETURN_MAIN,
    moduleName = "client.slua.logic.player_return.logic_player_return",
    funcName = "OpenMainUI"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_EGAME_ENTRY,
    moduleName = "client.slua.logic.esport.logic_esport_center",
    funcName = "OpenMain"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_LOBBY_MENU_INDIA_CHAMPIONSHIP_SYSTEM,
    moduleName = "client.logic.lobby.logic_lobby_matchlist",
    funcName = "EnterIndia"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_LOBBY_MENU_SPONSOR_CHAMPIONSHIP,
    moduleName = "client.logic.lobby.logic_lobby_matchlist",
    funcName = "EnterChampionship"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_ACTIVITY_REBATE,
    moduleName = "client.logic.activity.logic_activity_rebate",
    funcName = "PopSlap"
  },
  {
    eventType = EVENTTYPE_LOGIN,
    eventID = EVENTID_BACKLOGIN,
    moduleName = "client.slua.logic.lobby_chat.logic_chat_menu",
    funcName = "Handle_LogOut"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_ACTIVITY_SIGN_IN,
    moduleName = "client.slua.logic.activity.logic_sign_in",
    funcName = "SlapSignIn"
  },
  {
    eventType = EVENTTYPE_LUCKAIR,
    eventID = EVENTID_EVALUATE_RSPDATA,
    moduleName = "client.slua.logic.luck_airdrop.logic_luck_air_drop",
    funcName = "OnReceivedEvaluateRsp"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_WARDROBE,
    moduleName = "client.slua.logic.wardrobe.logic_wardrobe_new",
    funcName = "JumpTo"
  },
  {
    eventType = EVENTTYPE_STATE,
    eventID = EVENTID_ON_MODE_PRE_SWITCH,
    moduleName = "client.slua.logic.wardrobe.logic_wardrobe_new",
    funcName = "OnGameStateChange"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_ESPORT,
    moduleName = "client.logic.lobby.logic_lobby_matchlist",
    funcName = "EnterBroadcast"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_OPEN_FRIEND,
    moduleName = "client.slua.logic.friend.logic_new_friend",
    funcName = "OpenTeamUpSideBar"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_QUICKTEAM,
    moduleName = "client.slua.logic.teamup.logic_quick_team_up",
    funcName = "OnJumpUrl"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_ARENA,
    moduleName = "client.slua.logic.arena.logic_arena",
    funcName = "ShowArenaUI"
  },
  {
    eventType = EVENTTYPE_STORE_DATA,
    eventID = EVENTID_STORE_DATA,
    moduleName = "client.slua.logic.coupon.logic_coupon_shop",
    funcName = "OnSupplyDataUpdate"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_EVERYDAY_PACK,
    moduleName = "client.logic.everyday_pack.logic_everydaypack",
    funcName = "OnJumpUrl"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_EVERYDAY_PACK_V2,
    moduleName = "client.logic.everyday_pack.logic_everydaypack",
    funcName = "OnJumpEverydayPackV2"
  },
  {
    eventType = EVENTTYPE_LOGIN,
    eventID = EVENTID_LOGIN_SUCCESS,
    moduleName = "client.logic.everyday_pack.logic_everydaypack",
    funcName = "OnLoginSuccess"
  },
  {
    eventType = EVENTTYPE_LOGIN,
    eventID = EVENTID_BACKLOGIN,
    moduleName = "client.slua.logic.person_space.logic_roleinfo_arena",
    funcName = "Handle_LogOut"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_EMUM_MODULE_BILLBOARD,
    moduleName = "client.slua.umg.activity.bulletin_board.bulletin_manager",
    funcName = "Entrance"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_EMUM_MODULE_BILLBOARD_SLAP,
    moduleName = "client.slua.umg.activity.bulletin_board.bulletin_manager",
    funcName = "EntranceSlapUI"
  },
  {
    eventType = EVENTTYPE_ARMORY,
    eventID = EVENTID_ARMORY_EQUIP_STAT_CHANGE,
    moduleName = "client.slua.logic.wardrobe.logic_wardrobe_gun",
    funcName = "OnEquipStateChange"
  },
  {
    eventType = EVENTTYPE_LOGIN,
    eventID = EVENTID_BACKLOGIN,
    moduleName = "client.slua.logic.person_space.logic_intimacy_award",
    funcName = "Handle_LogOut"
  },
  {
    eventType = EVENTTYPE_LOGIN,
    eventID = EVENTID_BACKLOGIN,
    moduleName = "client.slua.logic.lobby_chat.logic_chat_gift_notify",
    funcName = "Handle_LogOut"
  },
  {
    eventType = EVENTTYPE_LOGIN,
    eventID = EVENTID_BACKLOGIN,
    moduleName = "client.slua.umg.LuckyAirDrop.ui_airdrop_mesh",
    funcName = "Clear"
  },
  {
    eventType = EVENTTYPE_LOGIN,
    eventID = EVENTID_BACKLOGIN,
    moduleName = "client.slua.logic.corps.corps_mgr",
    funcName = "Handle_LogOut"
  },
  {
    eventType = EVENTTYPE_LOGIN,
    eventID = EVENTID_BACKLOGIN,
    moduleName = "client.slua.logic.corps.logic_corps",
    funcName = "Handle_LogOut"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_EXCHANGE_ACTIVITY,
    moduleName = "client.slua.logic.activity.logic_activity_mgr",
    funcName = "ShowExchangeActivityUI"
  },
  {
    eventType = EVENTTYPE_LOGIN,
    eventID = EVENTID_BACKLOGIN,
    moduleName = "client.slua.logic.prepareScheme.logic_prepare_scheme",
    funcName = "logOut"
  },
  {
    eventType = EVENTTYPE_STORE_DATA,
    eventID = EVENTID_STORE_DATA,
    moduleName = "client.slua.logic.coupon.logic_coupon_shop",
    funcName = "OnRecevedStoreData"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_LOBBY_CORPS_GIFT_CHANGE,
    moduleName = "client.slua.logic.corps_gift_exchange.logic_corp_gift_exchange",
    funcName = "ShowUI"
  },
  {
    eventType = EVENTTYPE_STATE,
    eventID = EVENTID_ON_MODE_PRE_SWITCH,
    moduleName = "client.slua.logic.mentor.logic_mentor",
    funcName = "OnGameStateChange"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_EMUM_MODULE_BILLBOARD_FOR_COMEBACK,
    moduleName = "client.slua.umg.activity.bulletin_board.bulletin_manager",
    funcName = "EntranceForComeback"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_MENTOR,
    moduleName = "client.slua.logic.mentor.logic_mentor",
    funcName = "OpenUI"
  },
  {
    eventType = EVENTTYPE_MATCH,
    eventID = EVENTID_MATCH_UPDATE_PLAYERNUM,
    moduleName = "client.slua.logic.mentor.logic_mentor",
    funcName = "PlayerNumChanged"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_EVERYDAY_PACK_UC,
    moduleName = "client.logic.everyday_pack.logic_everyday_uc",
    funcName = "ShowEveryDayUC"
  },
  {
    eventType = EVENTTYPE_STATE,
    eventID = EVENTID_ON_MODE_PRE_SWITCH,
    moduleName = "GameLua.Mod.SocialIsland.Client.Tips",
    funcName = "OnGameStateChange"
  },
  {
    eventType = EVENTTYPE_SOCIAL_ISLAND,
    eventID = EVENTID_SOCIAL_ISLAND_DS_RECONNECT,
    moduleName = "GameLua.Mod.SocialIsland.Client.Chat.IslandChatNetClient",
    funcName = "OnDSReconnect"
  },
  {
    eventType = EVENTTYPE_SOCIAL_ISLAND,
    eventID = EVENTID_SOCIAL_DS_NET_READY,
    moduleName = "GameLua.Mod.SocialIsland.Client.Chat.IslandChatNetClient",
    funcName = "OnDSNetReady"
  },
  {
    eventType = EVENTTYPE_ACTIVITY,
    eventID = EVNETID_ACTIVITY_REDDOT,
    moduleName = "client.slua.logic.activity.logic_activity_mgr",
    funcName = "UpdateActivityMainUIRedDot"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_OPEN_PHARAOHRISES_EXCHANGE_PANEL,
    moduleName = "client.slua.logic.XSuit.logic_xsuit",
    funcName = "ShowExchangeUI"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_OPEN_GROWPROGET_SIPN_UI,
    moduleName = "client.slua.logic.growth_project.logic_new_player_spin",
    funcName = "OpenSpinUI"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_COMMON_RECEIVE_UIBP,
    moduleName = "client.slua.logic.XSuit.logic_xsuit",
    funcName = "PopCommonTip"
  },
  {
    eventType = EVENTTYPE_STATE,
    eventID = EVENTID_ON_MODE_POST_SWITCH,
    moduleName = "client.slua.logic.gamemaster.logic_accel",
    funcName = "OnPostSceneLoad"
  },
  {
    eventType = EVENTTYPE_LOGIN,
    eventID = EVENTID_BACKLOGIN,
    moduleName = "client.slua.logic.mentor.logic_mentor",
    funcName = "Handle_LogOut"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_WEAPON_DIY_S12K,
    moduleName = "client.slua.logic.weapon_diy.logic_weapon_diy",
    funcName = "JumpToS12K"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_WEAPON_DIY_S12K_COLOR,
    moduleName = "client.slua.logic.weapon_diy.logic_weapon_diy",
    funcName = "JumpToS12KColor"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_WEAPON_DIY_S12K_PATTERN,
    moduleName = "client.slua.logic.weapon_diy.logic_weapon_diy",
    funcName = "JumpToS12KPattern"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_WEAPON_DIY_SCARL,
    moduleName = "client.slua.logic.weapon_diy.logic_weapon_diy",
    funcName = "JumpToSCARL"
  },
  {
    eventType = EVENTTYPE_TEAMUP,
    eventID = EVENTID_TEAMUP_CREATE_TEAM,
    moduleName = "GameLua.Mod.SocialIsland.Client.Member.SocialIsland_Client_Member",
    funcName = "OnCreateTeam"
  },
  {
    eventType = EVENTTYPE_TEAMUP,
    eventID = EVENTID_TEAMUP_BE_KICKED_OUT,
    moduleName = "GameLua.Mod.SocialIsland.Client.Member.SocialIsland_Client_Member",
    funcName = "OnDestroyTeam"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_CORPS_CENTER,
    moduleName = "client.slua.logic.corps.logic_corps_tab_mgr",
    funcName = "JumpUrl"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_CORPS,
    moduleName = "client.slua.logic.corps.logic_corps_tab_mgr",
    funcName = "JumpUrl"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_CORPS_TRAINING,
    moduleName = "client.slua.logic.corps.logic_corps_training",
    funcName = "OpenTrainingUI"
  },
  {
    eventType = EVENTTYPE_STATE,
    eventID = EVENTID_ON_MODE_PRE_SWITCH,
    moduleName = "client.logic.season.AceImprintLogic",
    funcName = "OnGameStateChange"
  },
  {
    eventType = EVENTTYPE_STATE,
    eventID = EVENTID_ON_MODE_POST_SWITCH,
    moduleName = "client.slua.logic.teamup.logic_mic_evaluation",
    funcName = "OnGameStateChange"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_ACHIEVEMENT,
    moduleName = "client.slua.logic.achievement.logic_achievement",
    funcName = "JumpUrl"
  },
  {
    eventType = EVENTTYPE_DATA_MGR,
    eventID = EVENTID_DATAMGR_UPDATE_NEWBIE_STATUS,
    moduleName = "client.slua.logic.corps.logic_corps_tab_mgr",
    funcName = "UpdateRedPoint"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_BAN,
    moduleName = "client.slua.logic.lobby.logic_lobby_system_entrance",
    funcName = "OpenBan"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_REPORT,
    moduleName = "client.slua.logic.lobby.logic_lobby_system_entrance",
    funcName = "OpenReport"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_XUN_YOU,
    moduleName = "client.slua.logic.lobby.logic_lobby_system_entrance",
    funcName = "OpenXunYou"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_LOBBY,
    moduleName = "client.slua.logic.lobby.logic_lobby_system_entrance",
    funcName = "CloseOtherMenu"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_INVITEJOIN,
    moduleName = "client.slua.logic.lobby.logic_lobby_system_entrance",
    funcName = "OnInviteJoin"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_MALL_CHILD,
    moduleName = "client.slua.logic.lobby.logic_lobby_system_entrance",
    funcName = "JumpToStore"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_SETTING,
    moduleName = "client.slua.logic.setting.setting_util",
    funcName = "JumpUrl"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_SETTING_BIND_MAIL,
    moduleName = "client.slua.logic.setting.setting_util",
    funcName = "JumpBindMail"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_SUPPLY,
    moduleName = "client.slua.logic.lobby.logic_lobby_system_entrance",
    funcName = "JumpToCrate"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_ESPORT_AllSTAR,
    moduleName = "client.slua.logic.esport.logic_esport_allstar",
    funcName = "ShowUI"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_ESPORT_SHARE,
    moduleName = "client.slua.logic.esport.logic_esport_allstar",
    funcName = "ShowTeamShareUI"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_ESPORT_WEEKLY_AWARDS,
    moduleName = "client.slua.logic.esport.logic_esport_allstar",
    funcName = "OpenWeeklyAwardsUI"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_BIND_FACEBOOK,
    moduleName = "client.slua.logic.lobby.logic_lobby_system_entrance",
    funcName = "OnJumpBindFB"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_THEFIRSTCHARGE,
    moduleName = "client.slua.logic.lobby.logic_lobby_system_entrance",
    funcName = "OnJumpFirstCharge"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_LOBBY_CORPS,
    moduleName = "client.slua.logic.lobby.logic_lobby_system_entrance",
    funcName = "OnJumpCorps"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_LUCKY_UNBACK,
    moduleName = "client.slua.logic.lobby.logic_lobby_system_entrance",
    funcName = "JumpLuckyPack"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_LUCKY_BACK,
    moduleName = "client.slua.logic.lobby_activity.logic_luckyback_activity",
    funcName = "OpenMainUI"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_COMMON_EXCHANGE,
    moduleName = "client.logic.shop.logic_shop",
    funcName = "OpenCommonExchange"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_LUCKY_EXCHANGE,
    moduleName = "client.slua.logic.lobby_activity.logic_luckyback_activity",
    funcName = "OpenExchangeMainUI"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_LUCKY_BACK_EXCHANGE,
    moduleName = "client.slua.logic.lobby_activity.logic_luckyback_activity",
    funcName = "JumpLuckExchange"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_LUCKY_DOUBLE,
    moduleName = "client.slua.logic.lobby_activity.logic_luckydouble_activity",
    funcName = "OpenMainUI"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_LUCKY_BACK_VEHICLE,
    moduleName = "client.slua.logic.lobby.logic_lobby_system_entrance",
    funcName = "JumpLuckyVehicle"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_LOBBY_MENU_PURCHASE_BANNER,
    moduleName = "client.slua.logic.lobby.logic_lobby_system_entrance",
    funcName = "JumpPurchase"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_EMUM_MODULE_WEGAME,
    moduleName = "client.slua.logic.lobby.logic_lobby_system_entrance",
    funcName = "OnGetWegameUrl"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_RECRUIT,
    moduleName = "client.slua.logic.lobby.logic_lobby_system_entrance",
    funcName = "OnGetRecruitUrl"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_INDIACOMP,
    moduleName = "client.logic.lobby.logic_lobby_matchlist",
    funcName = "EnterIndia"
  },
  {
    eventType = EVENTTYPE_DATA_MGR,
    eventID = EVNETID_DATAMGR_ACTIVITY_CR,
    moduleName = "client.slua.logic.lobby.logic_lobby_system_entrance",
    funcName = "UpdateActivityBtnList"
  },
  {
    eventType = EVENTTYPE_NEXTDAY,
    eventID = EVENTID_NEXTDAY_ZERO,
    moduleName = "client.slua.logic.lobby.logic_lobby_system_entrance",
    funcName = "OnLobbyNextDayHandler"
  },
  {
    eventType = EVENTTYPE_LOGIN,
    eventID = EVENTID_LOGIN_SUCCESS,
    moduleName = "client.network.Protocol.MVPMotionHander",
    funcName = "send_settl_motion_info_req"
  },
  {
    eventType = EVENTTYPE_ACTIVITY,
    eventID = EVNETID_ACTIVITY_BANNER_REDDOT,
    moduleName = "client.slua.logic.lobby.logic_lobby_system_entrance",
    funcName = "OnLobbyRedPointUpdate"
  },
  {
    eventType = EVENTTYPE_ACTIVITY,
    eventID = EVENTID_ACTIVITY_DISCOUNT_TICKET,
    moduleName = "client.slua.umg.lobby.lobby_corner_dot",
    funcName = "RefreshLobbyCornerDot"
  },
  {
    eventType = EVENTTYPE_PROFILE,
    eventID = EVENTID_PROFILE_LIST_UPDATE,
    moduleName = "client.slua.logic.lobby.logic_lobby_system_entrance",
    funcName = "UpdateGoldenSuitPopEvent"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_SEASON_KING,
    moduleName = "client.slua.logic.lobby.logic_lobby_system_entrance",
    funcName = "OnSeasonKing"
  },
  {
    eventType = EVENTTYPE_ITEM_UPGRADE,
    eventID = EVENTID_ITEM_UPGRADE_RED_POINT_DATA_CHANGE,
    moduleName = "client.slua.logic.lobby.logic_lobby_system_entrance",
    funcName = "OnRedPointInfoUpdate"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_BOUNUS,
    moduleName = "client.logic.lobby.logic_lobby_matchlist",
    funcName = "EnterBonusH5"
  },
  {
    eventType = EVENTTYPE_TEAMUP,
    eventID = EVENTID_INTL_SELECT_ZONE_RSP,
    moduleName = "client.slua.logic.lobby.logic_lobby_system_entrance",
    funcName = "OnServerChange"
  },
  {
    eventType = EVENTTYPE_TEAMUP,
    eventID = EVENTID_INTL_MATCH_ZONE_NOTIFY,
    moduleName = "client.slua.logic.lobby.logic_lobby_system_entrance",
    funcName = "OnServerChange"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_ITEM_UPGRADE,
    moduleName = "client.slua.logic.lobby.logic_lobby_system_entrance",
    funcName = "OnJumpItemUpgrade"
  },
  {
    eventType = EVENTTYPE_DATA_MGR,
    eventID = EVENTID_DATAMGR_GOLD_CHANGE,
    moduleName = "client.slua.logic.lobby.logic_lobby_system_entrance",
    funcName = "PlayerDataChange"
  },
  {
    eventType = EVENTTYPE_DATA_MGR,
    eventID = EVENTID_DATAMGR_TICKET_CHANGE,
    moduleName = "client.slua.logic.lobby.logic_lobby_system_entrance",
    funcName = "PlayerDataChange"
  },
  {
    eventType = EVENTTYPE_DATA_MGR,
    eventID = EVENTID_DATAMGR_ETERNAL_DIAMOND_CHANGE,
    moduleName = "client.slua.logic.lobby.logic_lobby_system_entrance",
    funcName = "PlayerDataChange"
  },
  {
    eventType = EVENTTYPE_DATA_MGR,
    eventID = EVENTID_DATAMGR_FP_TOKEN_CHANGE,
    moduleName = "client.slua.logic.lobby.logic_lobby_system_entrance",
    funcName = "PlayerDataChange"
  },
  {
    eventType = EVENTTYPE_DATA_MGR,
    eventID = EVENTID_DATAMGR_ROLE_EXP_CHANGE,
    moduleName = "client.slua.logic.lobby.logic_lobby_system_entrance",
    funcName = "PlayerDataChange"
  },
  {
    eventType = EVENTTYPE_DATA_MGR,
    eventID = EVENTID_DATAMGR_ROLE_LEVEL_CHANGE,
    moduleName = "client.slua.logic.lobby.logic_lobby_system_entrance",
    funcName = "PlayerDataChange"
  },
  {
    eventType = EVENTTYPE_DATA_MGR,
    eventID = EVENTID_DATAMGR_PVE_LEVEL_CHANGE,
    moduleName = "client.slua.logic.lobby.logic_lobby_system_entrance",
    funcName = "PlayerDataChange"
  },
  {
    eventType = EVENTTYPE_DATA_MGR,
    eventID = EVENTID_DATAMGR_PVE_EXP_CHANGE,
    moduleName = "client.slua.logic.lobby.logic_lobby_system_entrance",
    funcName = "PlayerDataChange"
  },
  {
    eventType = EVENTTYPE_DATA_MGR,
    eventID = EVNETID_DATAMGR_ROLE_RANK_CHANGE,
    moduleName = "client.slua.logic.lobby.logic_lobby_system_entrance",
    funcName = "PlayerDataChange"
  },
  {
    eventType = EVENTTYPE_LOBBY,
    eventID = EVENTID_ENTERLOBBY,
    moduleName = "client.slua.logic.lobby.logic_lobby_system_entrance",
    funcName = "lobbyEventHandler"
  },
  {
    eventType = EVENTTYPE_LOBBY,
    eventID = EVENTID_CREATE_LOBBY_AVATAR,
    moduleName = "client.slua.logic.XSuit.logic_xsuit",
    funcName = "UpdateLobbyAvatar"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_CUSTOM_PACK,
    moduleName = "client.slua.logic.custom_pack.logic_custom_pack",
    funcName = "OpenFromURL"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_TEAM_PLATFORM,
    moduleName = "client.slua.logic.teamup.logic_team_platform",
    funcName = "ShowUI"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_VLINK_SDK,
    moduleName = "client.slua.logic.vlink_sdk.logic_vlink_sdk",
    funcName = "EventShowVLink"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_XSUIT_WORKSHOP,
    moduleName = "client.slua.logic.XSuit.logic_xsuit",
    funcName = "ShowUpgradeUIFromURL"
  },
  {
    eventType = EVENTTYPE_STATE,
    eventID = EVENTID_ON_MODE_PRE_SWITCH,
    moduleName = "client.slua.logic.lobby.Left.logic_lobby_social",
    funcName = "OnGameStateChange"
  },
  {
    eventType = EVENTTYPE_STATE,
    eventID = EVENTID_ON_MODE_PRE_SWITCH,
    moduleName = "client.slua.logic.setting.logic_setting_graphics",
    funcName = "OnGameStateChange"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_RP_SUBWAY,
    moduleName = "client.slua.logic.unknow_pass.logic_unknowpass_subway",
    funcName = "OpenMainUIByReq"
  },
  {
    eventType = EVENTTYPE_STATE,
    eventID = EVENTID_ON_MODE_POST_SWITCH,
    moduleName = "client.slua.logic.download.delete.puffer_delete_manager",
    funcName = "OnGameStateChange"
  },
  {
    eventType = EVENTTYPE_STATE,
    eventID = EVENTID_ON_MODE_PRE_SWITCH,
    moduleName = "client.slua.logic.download.recommend.logic_recommend_handler",
    funcName = "OnGameStateChange"
  },
  {
    eventType = EVENTTYPE_STATE,
    eventID = EVENTID_ON_MODE_PRE_SWITCH,
    moduleName = "client.slua.logic.fbi.logic_fbi",
    funcName = "OnGameStateChange"
  },
  {
    eventType = EVENTTYPE_STATE,
    eventID = EVENTID_ON_MODE_PRE_SWITCH,
    moduleName = "client.slua.logic.download.puffer.logic_puffer_downloader",
    funcName = "OnGameStateChange"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_RECHARGE_GAS_STATION,
    moduleName = "client.slua.logic.activity.logic_recharge_gas_station",
    funcName = "OpenActivityUI"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_JUMP_FRIEND_SEND_GIFT,
    moduleName = "client.slua.logic.person_space.logic_roleinfo_popularity",
    funcName = "JumpFriendSendGift"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_TXMISSION_TASK_TO_BLACK_MAR,
    moduleName = "client.slua.logic.TxMission.logic_xmission_black_market",
    funcName = "JumpToBlackMarket"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_TXMISSION_TASK_TO_BATTLE_GUIDE,
    moduleName = "client.slua.logic.TxMission.xmission_task.logic_xmission_task",
    funcName = "JumpToFight"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_TXMISSION_LOBBY_FROM_JUMP,
    moduleName = "client.slua.logic.TxMission.logic_xmission_main",
    funcName = "JumpTxMission"
  },
  {
    eventType = EVENTTYPE_T_XMISSION,
    eventID = EVENTID_XMISSION_WARDROBE_DATA_INIT,
    moduleName = "client.slua.logic.TxMission.warpre.xmission_redpoint_data",
    funcName = "OnXMissionWardrobeDataInit"
  },
  {
    eventType = EVENTTYPE_T_XMISSION,
    eventID = EVENTID_XMISSION_WARDROBE_DATA_CHANGE,
    moduleName = "client.slua.logic.TxMission.warpre.xmission_redpoint_data",
    funcName = "OnItemChange"
  },
  {
    eventType = EVENTTYPE_T_XMISSION,
    eventID = EVENTID_XMISSION_BAG_EXTEND_GUIDE,
    moduleName = "client.slua.logic.TxMission.warpre.xmission_redpoint_data",
    funcName = "OnBagExtendGuideChange"
  },
  {
    eventType = EVENTTYPE_STATE,
    eventID = EVENTID_ON_MODE_PRE_SWITCH,
    moduleName = "client.slua.logic.TxMission.warpre.xmission_redpoint_data",
    funcName = "OnGameStateChange"
  },
  {
    eventType = EVENTTYPE_T_XMISSION,
    eventID = EVENTID_XMISSION_SEASON_CHANGE,
    moduleName = "client.slua.logic.TxMission.warpre.xmission_redpoint_data",
    funcName = "OnSeasonChange"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_XMISSION_ACTIVITY,
    moduleName = "client.slua.logic.TxMission.logic_xmission_main",
    funcName = "JumpToXmissionActivityCenter"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_XMISSION_TASK,
    moduleName = "client.slua.logic.TxMission.xmission_task.logic_xmission_task",
    funcName = "JumpToXMissionTask"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_XMISSION_SELECT_MODE,
    moduleName = "client.slua.logic.TxMission.logic_xmission_main",
    funcName = "JumpToXMissionSelectMode"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_XMISSION_CULTIVATE,
    moduleName = "client.slua.logic.TxMission.logic_xmission_main",
    funcName = "JumpToXMissionCultivate"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_RECHARGE,
    moduleName = "client.logic.recharge.logic_recharge",
    funcName = "OpenRechargeUI"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_RECHARGE_PURCHASE,
    moduleName = "client.logic.recharge.logic_recharge",
    funcName = "OnJumpPurchaseUrl"
  },
  {
    eventType = EVENTTYPE_DATA_MGR,
    eventID = EVENTID_DATAMGR_SEASON_CHANGE,
    moduleName = "client.slua.logic.lobby.Left.logic_lobby_social",
    funcName = "OnUpdateSeason"
  },
  {
    eventType = EVENTTYPE_DATA_MGR,
    eventID = EVENTID_DATAMGR_SEASON_CHANGE,
    moduleName = "client.logic.season.logic_season",
    funcName = "ClearSeasonReminderData"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_EIGHT_DAY,
    moduleName = "client.slua.logic.activity.newbie.logic_newbie_eight_day",
    funcName = "OnJumpUrl"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_TAROTCARD_EVENTCARD,
    moduleName = "client.slua.logic.tarot_card.logic_tarotcard_eventcard",
    funcName = "JumpToEventCardPanel"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_TAROTCARD_DARWCARD,
    moduleName = "client.slua.logic.tarot_card.logic_tarotcard_drawcard",
    funcName = "JumpToEventCardPanel"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_SUBSCRIBE_CARNIVAL,
    moduleName = "client.slua.logic.subscribe.logic_subscribe_carnival_activity",
    funcName = "JumpToMainUI"
  },
  {
    eventType = EVENTTYPE_STATE,
    eventID = EVENTID_ON_MODE_POST_SWITCH,
    moduleName = "client.slua.logic.reddot.reddot_manager",
    funcName = "OnGameStateChange"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_TASK,
    moduleName = "client.slua.logic.task.logic_mgr_task",
    funcName = "JumpTo"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_ESPORT_LIVE_VIDEO,
    moduleName = "client.slua.logic.live_video.logic_live_video",
    funcName = "Slap"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_FAIRGAME_REPORT,
    moduleName = "client.slua.logic.security.logic_security",
    funcName = "ShowReportSucceedFace"
  },
  {
    eventType = EVENTTYPE_LOGIN,
    eventID = EVENTID_BACKLOGIN,
    moduleName = "client.slua.logic.security.logic_security",
    funcName = "OnLogout"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_FAIRGAME_AGREEMENT,
    moduleName = "client.slua.logic.fairgame.logic_fairgame_popup",
    funcName = "ShowFairGameAgreement"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_FAIRGAME_NOTICE,
    moduleName = "client.slua.logic.fairgame.logic_fairgame_popup",
    funcName = "ShowFairGameNotice"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_RP_GIFT,
    moduleName = "client.slua.logic.unknow_pass.logic_unknowpass_gift",
    funcName = "ShowRpGiftMainPageUI"
  },
  {
    eventType = EVENTTYPE_STATE,
    eventID = EVENTID_ON_MODE_PRE_SWITCH,
    moduleName = "client.slua.logic.createRole.logic_createRole",
    funcName = "OnModePreSwitch"
  },
  {
    eventType = EVENTTYPE_STATE,
    eventID = EVENTID_ON_MODE_POST_SWITCH,
    moduleName = "client.slua.logic.createRole.logic_createRole",
    funcName = "OnModePostSwitch"
  },
  {
    eventType = EVENTTYPE_STATE,
    eventID = EVENTID_ON_MODE_POST_SWITCH,
    moduleName = "client.slua.logic.login.logic_login_verify",
    funcName = "OnModePostSwitch"
  },
  {
    eventType = EVENTTYPE_STATE,
    eventID = EVENTID_ON_MODE_POST_SWITCH,
    moduleName = "client.slua.logic.guest_bind.logic_guest_find",
    funcName = "OnModePostSwitch"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_MINI_DOWNLOAD,
    moduleName = "client.slua.logic.mini_tv.logic_mini_tv",
    funcName = "ShowDownloadAct"
  },
  {
    eventType = EVENTTYPE_TASK,
    eventID = EVENTID_NEW_DAY_TASK_SYNC,
    moduleName = "client.slua.logic.task.assembly_reddot_data",
    funcName = "UpdateRedDot"
  },
  {
    eventType = EVENTTYPE_TASK,
    eventID = EVENTID_NEW_DAY_TASK_CHANGE,
    moduleName = "client.slua.logic.task.assembly_reddot_data",
    funcName = "UpdateRedDot"
  },
  {
    eventType = EVENTTYPE_TASK,
    eventID = EVENTID_NEW_DAY_TASK_WEEKLY_ACTIVE,
    moduleName = "client.slua.logic.task.assembly_reddot_data",
    funcName = "UpdateRedDot"
  },
  {
    eventType = EVENTTYPE_ACTIVITY,
    eventID = EVNETID_ACTIVITY_REDDOT,
    moduleName = "client.slua.logic.task.assembly_reddot_data",
    funcName = "UpdateRedDot"
  },
  {
    eventType = EVENTTYPE_ACTIVITY,
    eventID = EVENTID_ASSEMBLY_ACTIVITY_UPDATE,
    moduleName = "client.slua.logic.task.assembly_reddot_data",
    funcName = "UpdateRedDot"
  },
  {
    eventType = EVENTTYPE_ACTIVITY,
    eventID = EVENTID_ASSEMBLY_ACTIVITY_TASK_UPDATE,
    moduleName = "client.slua.logic.task.assembly_reddot_data",
    funcName = "UpdateRedDot"
  },
  {
    eventType = EVENTTYPE_MATCH,
    eventID = EVENTID_MATCH_MAP_DOWNLOAD_DONE,
    moduleName = "client.slua.logic.audio.logic_ak_audio",
    funcName = "OnDownloadFinish"
  },
  {
    eventType = EVENTTYPE_LOGIN,
    eventID = EVENTID_BACKLOGIN,
    moduleName = "client.slua.logic.wardrobe.display_setting_redpoint_data",
    funcName = "OnLogout"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_ALLIANCE_MAIN_PANEL,
    moduleName = "client.slua.logic.esport.logic_esport_squad",
    funcName = "OpenTeamUI"
  },
  {
    eventType = EVENTTYPE_REDDOT,
    eventID = EVENTID_REDDOT_SYSTEM_LOGOUT,
    moduleName = "client.slua.logic.esport.center_reddot_data",
    funcName = "OnLogout"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_PLOT_ACTIVITY,
    moduleName = "client.slua.logic.plot.logic_plot_activity",
    funcName = "OpenPlotActivity"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_LADDER_DRAW,
    moduleName = "client.slua.logic.lobby_activity.logic_ladder_draw",
    funcName = "ShowUI"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_LADDER_DRAW_CAR_STORE,
    moduleName = "client.slua.logic.lobby_activity.logic_ladder_draw",
    funcName = "OpenCarStore"
  },
  {
    eventType = EVENTTYPE_STATE,
    eventID = EVENTID_ON_MODE_POST_SWITCH,
    moduleName = "client.logic.LogicPlayerPrefs.mmkv_playerprefs",
    funcName = "OnGameStateChange"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_MOMENT,
    moduleName = "client.slua.logic.moment.logic_moment",
    funcName = "EnterSelfMomentUIFromMailHyperLink"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_GET_ALIAS_POPUP,
    moduleName = "client.slua.logic.roleInfo.logic_roleinfo_title",
    funcName = "ShowGetAlias"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_MATCH_BAN_TIP,
    moduleName = "client.slua.logic.match.logic_match",
    funcName = "ShowFaceSlapBanTip"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_DOWNLOAD_VOICE_BANK,
    moduleName = "client.slua.logic.download.recommend.logic_recommend_handler",
    funcName = "AskDownloadBankPack"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_ZONE_NOTICE,
    moduleName = "client.logic.data.data_mgr",
    funcName = "CheckTouristDialog"
  },
  {
    eventType = EVENTTYPE_NEXTDAY,
    eventID = EVENTID_NEXTDAY_ZERO,
    moduleName = "client.slua.logic.corps.logic_corps_training",
    funcName = "NextDay"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_QUICK_QUEATION,
    moduleName = "client.slua.logic.activity.logic_quick_question",
    funcName = "OpenQuickQuestionUI"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_OTHER_H5,
    moduleName = "client.slua.logic.activity.logic_quick_question",
    funcName = "OpenOtherH5"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_LOBBY_MENU_ENCHARGE,
    moduleName = "client.logic.recharge.logic_recharge",
    funcName = "EnterRechargeUI"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_WARZONE_RANK,
    moduleName = "client.slua.logic.warzone.logic_warzone_rank",
    funcName = "OpenWarZoneRank"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_RANK,
    moduleName = "client.slua.logic.rank.logic_rank",
    funcName = "OnJumpUrl"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_GODZILLA_BAN,
    moduleName = "client.slua.logic.lobby_activity.logic_godzilla_ban",
    funcName = "ShowMain"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_MATCH_GTV_TOROOM,
    moduleName = "client.slua.logic.room.logic_create_room",
    funcName = "ShowRoomByDeepLink"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_ASSEMBLY_SHARE_JK,
    moduleName = "client.slua.logic.come_back.jk.logic_assembly_activity_jk",
    funcName = "OnReturnToSendBind"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_GOLDENSUIT_SERIES_NEWEST,
    moduleName = "client.slua.logic.coupon.logic_coupon_gold_suit",
    funcName = "JumpToNewestGoldenSuit"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_SHARE_WONDERFUL_REPLAY,
    moduleName = "client.slua.logic.replay.logic_share_replay",
    funcName = "ShowReplayShareUI"
  },
  {
    eventType = EVENTTYPE_STATE,
    eventID = EVENTID_ON_MODE_PRE_SWITCH,
    moduleName = "client.logic.season.logic_season_config",
    funcName = "OnGameStateChange"
  },
  {
    eventType = EVENTTYPE_LOGIN,
    eventID = EVENTID_BACKLOGIN,
    moduleName = "client.logic.roleinfo.logic_roleinfo_history",
    funcName = "OnLogout"
  },
  {
    eventType = EVENTTYPE_STATE,
    eventID = EVENTID_ON_MODE_PRE_SWITCH,
    moduleName = "client.slua.logic.warzone.logic_warzone_rank",
    funcName = "OnGameStateChange"
  },
  {
    eventType = EVENTTYPE_STATE,
    eventID = EVENTID_ON_MODE_PRE_SWITCH,
    moduleName = "client.slua.logic.lbs.logic_lbs",
    funcName = "OnGameStateChange"
  },
  {
    eventType = EVENTTYPE_NETWORK,
    eventID = EVENTID_NET_STATE_CHANGE,
    moduleName = "client.slua.logic.download.network.logic_puffer_netmanager",
    funcName = "NetTypeChange"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_FINANCIAL_P,
    moduleName = "client.slua.logic.Financial.Logic_Financial",
    funcName = "ShowUIHandle"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_APLAN_EXPLORE,
    moduleName = "client.slua.logic.explore.logic_explore",
    funcName = "ShowUIHandle"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_EXPLORE_SUPPLY,
    moduleName = "client.slua.logic.explore.logic_explore",
    funcName = "ShowExploreUIHandle"
  },
  {
    eventType = EVENTTYPE_STATE,
    eventID = EVENTID_ON_MODE_PRE_SWITCH,
    moduleName = "client.module_framework.ModuleManager",
    funcName = "OnPreSwitchGameStatus"
  },
  {
    eventType = EVENTTYPE_STATE,
    eventID = EVENTID_ON_MODE_POST_SWITCH,
    moduleName = "client.module_framework.ModuleManager",
    funcName = "OnPostSwitchGameStatus"
  },
  {
    eventType = EVENTTYPE_LOGIN,
    eventID = EVENTID_BACKLOGIN,
    moduleName = "client.module_framework.ModuleManager",
    funcName = "OnLogOut"
  },
  {
    eventType = EVENTTYPE_LOGIN,
    eventID = EVENTID_BACKLOGIN,
    moduleName = "client.slua.logic.explore.logic_explore",
    funcName = "OnLogOut"
  },
  {
    eventType = EVENTTYPE_LOGIN,
    eventID = EVENTID_BACKLOGIN,
    moduleName = "client.slua.logic.explore.explore_config",
    funcName = "OnLogOut"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_MAIL,
    moduleName = "client.slua.logic.mail.logic_mail",
    funcName = "OnJumpByUrl"
  },
  {
    eventType = EVENTTYPE_LOGIN,
    eventID = EVENTID_BACKLOGIN,
    moduleName = "client.slua.logic.battle_report_video.logic_battle_report_video",
    funcName = "OnLogOut"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_RP_CRT_SCORE,
    moduleName = "client.slua.logic.unknow_pass.logic_unknowpass_crt_score",
    funcName = "OnJumpHandler"
  },
  {
    eventType = EVENTTYPE_STATE,
    eventID = EVENTID_ON_MODE_POST_SWITCH,
    moduleName = "client.slua.logic.activity.logic_activity_mgr",
    funcName = "OnModePostSwitch"
  },
  {
    eventType = EVENTTYPE_SETTING,
    eventID = EVENTID_SET_REGION_OK,
    moduleName = "client.slua.logic.gdpr.logic_compliance",
    funcName = "OnSetRegionOK"
  },
  {
    eventType = EVENTTYPE_STATE,
    eventID = EVENTID_ON_MODE_POST_SWITCH,
    moduleName = "client.slua.logic.gdpr.logic_compliance",
    funcName = "OnModePostSwitch"
  },
  {
    eventType = EVENTTYPE_REDDOT,
    eventID = EVENTID_REDDOT_SYSTEM_LOGOUT,
    moduleName = "client.slua.logic.gdpr.logic_compliance",
    funcName = "OnLogout"
  },
  {
    eventType = EVENTTYPE_STATE,
    eventID = EVENTID_ON_MODE_POST_SWITCH,
    moduleName = "client.slua.logic.download.report.logic_mini_pak_gem",
    funcName = "OnModePostSwitch"
  },
  {
    eventType = EVENTTYPE_STATE,
    eventID = EVENTID_ON_MODE_POST_SWITCH,
    moduleName = "client.slua.logic.teamup.logic_offline_invite",
    funcName = "OnModePostSwitch"
  },
  {
    eventType = EVENTTYPE_STATE,
    eventID = EVENTID_ON_MODE_POST_SWITCH,
    moduleName = "client.slua.logic.download.delete.logic_download_delete",
    funcName = "OnModePostSwitch"
  },
  {
    eventType = EVENTTYPE_STATE,
    eventID = EVENTID_ON_MODE_POST_SWITCH,
    moduleName = "client.slua.logic.manager.LobbySceneSubLogic.LobbyLightLogic",
    funcName = "OnModePostSwitch"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ACTOR_VOICE_INVENTORY,
    moduleName = "client.slua.logic.actor_voice.logic_actor_voice",
    funcName = "JumpItemByID"
  },
  {
    eventType = EVENTTYPE_REDDOT,
    eventID = EVENTID_REDDOT_SYSTEM_LOGOUT,
    moduleName = "client.logic.newbie_manager.newbie_guide_manager",
    funcName = "OnLogout"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_PRECHURN_LOGINREWARD,
    moduleName = "client.slua.logic.activity.logic_prechurn_loginreward",
    funcName = "OnJumpByUrl"
  },
  {
    eventType = EVENTTYPE_MAIL,
    eventID = EVENTID_MAIL_RECV_NEW_ITEM,
    moduleName = "client.slua.logic.teamup.logic_teamup_action",
    funcName = "OnRecvMailItems"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_COMMUNITY_Helpshift,
    moduleName = "client.slua.logic.CustomerService.LogicCustomerService",
    funcName = "OnJumpByUrl"
  },
  {
    eventType = EVENTTYPE_LOGIN,
    eventID = EVENTID_BACKLOGIN,
    moduleName = "client.slua.logic.task.logic_new_day_task",
    funcName = "OnLogout"
  },
  {
    eventType = EVENTTYPE_LOGIN,
    eventID = EVENTID_BACKLOGIN,
    moduleName = "client.logic.roleinfo.roleinfo_red_data",
    funcName = "OnLogout"
  },
  {
    eventType = EVENTTYPE_LOBBY,
    eventID = EVENTID_LOADING_FINISH,
    moduleName = "client.logic.roleinfo.roleinfo_red_data",
    funcName = "OnLoadingFinish"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_PLANPH_HOME_SHARE,
    moduleName = "client.slua.logic.home.Detail.logic_home_detail",
    funcName = "ShowShareUI"
  },
  {
    eventType = EVENTTYPE_STATE,
    eventID = EVENTID_ON_MODE_POST_SWITCH,
    moduleName = "client.slua.common.common_download_handler",
    funcName = "OnGameStateChange"
  },
  {
    eventType = EVENTTYPE_LOGIN,
    eventID = EVENTID_BACKLOGIN,
    moduleName = "client.slua.logic.wardrobe.logic_wardrobe_gun",
    funcName = "OnLogOut"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_CHAT_ROOM,
    moduleName = "client.slua.logic.lobby_chat.logic_chat_main",
    funcName = "OnJumpChatRoomChannel"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_SUBSCRIBE_SLAP,
    moduleName = "client.slua.umg.subscribe.Subscribe_Slap_System",
    funcName = "ShowSlap"
  },
  {
    eventType = EVENTTYPE_STATE,
    eventID = EVENTID_ON_MODE_POST_SWITCH,
    moduleName = "GameLua.Mod.Library.GamePlay.Avatar.Emote.logic_emote",
    funcName = "OnModePostSwitch"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_UGC_BECOME_AUTHOR,
    moduleName = "client.slua.logic.ugc.logic_ugc_author",
    funcName = "ShowBecomeAuthorSlap"
  },
  {
    eventType = EVENTTYPE_STATE,
    eventID = EVENTID_ON_MODE_POST_SWITCH,
    moduleName = "client.slua.logic.stat.logic_data_tunnel",
    funcName = "OnModePostSwitch"
  },
  {
    eventType = EVENTTYPE_LOGIN,
    eventID = EVENTID_BACKLOGIN,
    moduleName = "client.slua.logic.lobby.Left.logic_social_card",
    funcName = "OnLogOut"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_ANTIADDCTION,
    moduleName = "client.logic.antiaddction.logic_antiaddction",
    funcName = "ShowSlap"
  },
  {
    eventType = EVENTTYPE_STATE,
    eventID = EVENTID_ON_MODE_POST_SWITCH,
    moduleName = "client.slua.logic.lobby.MainCity.Lobby_Main_City",
    funcName = "OnModePostSwitch"
  },
  {
    eventType = EVENTTYPE_DOWNLOAD,
    eventID = EVENTID_PUFFER_REFRESH_MAP,
    moduleName = "client.slua.logic.lobby.MainCity.Lobby_Main_City",
    funcName = "OnPufferInited"
  },
  {
    eventType = EVENTTYPE_ROLEINFO,
    eventID = EVENTID_ROLEINFO_AVATAR_DATA_CHANGE,
    moduleName = "client.slua.logic.lobby.MainCity.Lobby_Main_City",
    funcName = "OnAvatarDataChange"
  },
  {
    eventType = EVENTTYPE_DOWNLOAD,
    eventID = EVENTID_PUFFER_DownloadBatchODPaks,
    moduleName = "client.slua.logic.download.puffer.puffer_manager",
    funcName = "ReqDownloadBatchODPaks"
  },
  {
    eventType = EVENTTYPE_LOGIN,
    eventID = EVENTID_BACKLOGIN,
    moduleName = "client.slua.logic.unknow_pass.NewRPPreview.logic_unknowpass_tunnel",
    funcName = "OnLogOut"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_EMUM_MODULE_WEEKEND_TALENT_TEMPORARY,
    moduleName = "client.slua.logic.TxMission.logic_xmission_info",
    funcName = "SaveKolConfig"
  },
  {
    eventType = EVENTTYPE_UGC,
    eventID = EVENTID_UGC_WOW_PASS_RED_DOT_STATE_CHANGE,
    moduleName = "client.slua.logic.ugc.WowPass.wowpass_task_reddot_data",
    funcName = "UpdateRedDot"
  },
  {
    eventType = EVENTTYPE_LOGIN,
    eventID = EVENTID_BACKLOGIN,
    moduleName = "client.common.uibase.ui_show_queue_manager",
    funcName = "OnLogOut"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_VERSION_UPDATE_SLAP,
    moduleName = "client.slua.logic.version_update_slap.logic_version_update_slap",
    funcName = "ShowSlap"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_ACTIVITY_SLAP,
    moduleName = "client.slua.logic.activity.logic_activity_mgr",
    funcName = "ShowActivityUISlap"
  },
  {
    eventType = EVENTTYPE_LOGIN,
    eventID = EVENTID_BACKLOGIN,
    moduleName = "client.slua.logic.video.lobby_video_function_library",
    funcName = "OnLogOut"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_SEASON_SLAP,
    moduleName = "client.logic.season.logic_season",
    funcName = "ShowSeasonSlap"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_PVP_LEVEL_UP_PANEL,
    moduleName = "client.logic.levelup.logic_levelup",
    funcName = "ShowLevelUpPanel"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_SMALL_PAYMENT_TASK_REWARD_POPUP,
    moduleName = "client.slua.logic.SmallPayment.Logic_SmallPayment",
    funcName = "TaskRewardShow"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_CHALLENGE_VALUE_POPUP,
    moduleName = "client.logic.season.logic_season",
    funcName = "ShowChallengeValueTips"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_BATTLE_COLLECT_ITEM_POPUP,
    moduleName = "client.logic.login.logic_lobby",
    funcName = "ShowBattleItemTip"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_APP_RAISE_POPUP,
    moduleName = "client.slua.logic.Appraise.logic_appraise",
    funcName = "TryShowAppRaiseUI"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_CORPS_FIGHT_TASK_POPUP,
    moduleName = "client.slua.logic.corps.logic_corps_fight",
    funcName = "ShowNextTaskTip"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_ACHIEVEMENT_POPUP,
    moduleName = "client.slua.logic.achievement.logic_achievement_float_tip",
    funcName = "ShowAchievementTip"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_BACK_TO_LOBBY_TIPS,
    moduleName = "client.slua.logic.come_back.logic_assembly_activity",
    funcName = "ShowBackToLobbyTips"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_WONDERFUL_REPLAY_SWITCH_TIP,
    moduleName = "client.slua.logic.replay.logic_replay",
    funcName = "ShowWonderfulReplaySwitchTip"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_ALIAS_POPUP,
    moduleName = "client.slua.logic.roleInfo.logic_roleinfo_title",
    funcName = "ShowGetAlias"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_LUCKY_AIR_DROP_PANEL,
    moduleName = "client.slua.logic.luck_airdrop.logic_luck_air_drop",
    funcName = "TryShowPopup"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_RP_LEVEL_UP_PANEL,
    moduleName = "client.slua.logic.unknow_pass.NewRPPreview.logic_unknowpass_tunnel",
    funcName = "TryShowLevelUp"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_ENHANCED_LOBBY_QUALITY,
    moduleName = "client.slua.logic.setting.logic_enhanced_lobby_quality_slap",
    funcName = "ShowEnhancedLobbyQualitySlap"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_EMUM_MODULE_HOME_PROMOTION_ACTIVITY,
    moduleName = "client.slua.logic.activity.logic_activity_mgr",
    funcName = "OpenHomePromotion"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_430_NEWBIE_GUIDE,
    moduleName = "client.logic.newbie.logic_newbie",
    funcName = "Show430LobbyGuide"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_NEWBIE_REWARD_EIGHT_DAY,
    moduleName = "client.slua.logic.activity.newbie.logic_newbie_reward_eight_day",
    funcName = "ShowUI"
  },
  {
    eventType = EVENTTYPE_LOGIN,
    eventID = EVENTID_LOGIN_SUCCESS,
    moduleName = "client.slua.logic.app_store.logic_store_game_interface",
    funcName = "OnLogin"
  },
  {
    eventType = EVENTTYPE_LOGIN,
    eventID = EVENTID_BACKLOGIN,
    moduleName = "client.slua.logic.app_store.logic_store_game_interface",
    funcName = "OnLogout"
  },
  {
    eventType = EVENTTYPE_LOGIN,
    eventID = EVENTID_LOGIN_SUCCESS,
    moduleName = "client.slua.logic.wifi_lock.logic_wifi_lock",
    funcName = "OnLogin"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_KEY_PLAY_VIDEO,
    moduleName = "client.slua.logic.lobby_activity.logic_keyplayvideo",
    funcName = "OnUrlOpenKeyPlayVideo"
  },
  {
    eventType = EVENTTYPE_URL,
    eventID = BP_ENUM_MODULE_KEY_PLAY_VIDEO_NOW,
    moduleName = "client.slua.logic.lobby_activity.logic_keyplayvideo",
    funcName = "OnUrlOpenKeyPlayVideoNow"
  }
}
return Event_Config