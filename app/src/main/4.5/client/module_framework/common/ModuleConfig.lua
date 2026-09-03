require("client.common.game_status")
require("client.common.SlateUI_ID")
local ModuleMacro = require("client.module_framework.ModuleMacro")
local ModuleConfig = {
  SettingModule = {
    KeyName = "SettingModule",
    ModuleName = "client.slua.logic.setting.SettingModule",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  CustomLayoutModule = {
    KeyName = "CustomLayoutModule",
    ModuleName = "client.slua.logic.setting.CustomLayoutModule",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  PlayerStatusMgr = {
    KeyName = "PlayerStatusMgr",
    ModuleName = "client.slua.logic.player_status.PlayerStatusMgr",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_friend_apply_battle = {
    KeyName = "logic_friend_apply_battle",
    ModuleName = "client.slua.logic.friend.logic_friend_apply_battle",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_friend_gift = {
    KeyName = "logic_friend_gift",
    ModuleName = "client.slua.logic.friend.logic_friend_gift",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_friend_apply = {
    KeyName = "logic_friend_apply",
    ModuleName = "client.slua.logic.friend.logic_friend_apply",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_friend_search = {
    KeyName = "logic_friend_search",
    ModuleName = "client.slua.logic.friend.logic_friend_search",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_friend_blacklist = {
    KeyName = "logic_friend_blacklist",
    ModuleName = "client.slua.logic.friend.logic_friend_blacklist",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_match_blacklist = {
    KeyName = "logic_match_blacklist",
    ModuleName = "client.slua.logic.friend.logic_match_blacklist",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  puffer_odpak_downloader = {
    KeyName = "puffer_odpak_downloader",
    ModuleName = "client.slua.logic.download.puffer.odpak.puffer_odpak_downloader"
  },
  puffer_odpak_manager = {
    KeyName = "puffer_odpak_manager",
    ModuleName = "client.slua.logic.download.puffer.odpak.puffer_odpak_manager",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  puffer_map_downloader = {
    KeyName = "puffer_map_downloader",
    ModuleName = "client.slua.logic.download.puffer.map.puffer_map_downloader"
  },
  puffer_map_manager = {
    KeyName = "puffer_map_manager",
    ModuleName = "client.slua.logic.download.puffer.map.puffer_map_manager",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  puffer_res_downloader = {
    KeyName = "puffer_res_downloader",
    ModuleName = "client.slua.logic.download.puffer.res.puffer_res_downloader"
  },
  puffer_res_manager = {
    KeyName = "puffer_res_manager",
    ModuleName = "client.slua.logic.download.puffer.res.puffer_res_manager",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  puffer_shader_downloader = {
    KeyName = "puffer_shader_downloader",
    ModuleName = "client.slua.logic.download.puffer.shader.puffer_shader_downloader"
  },
  puffer_shader_manager = {
    KeyName = "puffer_shader_manager",
    ModuleName = "client.slua.logic.download.puffer.shader.puffer_shader_manager",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  puffer_prefetch_downloader = {
    KeyName = "puffer_prefetch_downloader",
    ModuleName = "client.slua.logic.download.puffer.prefetch.puffer_prefetch_downloader"
  },
  puffer_prefetch_manager = {
    KeyName = "puffer_prefetch_manager",
    ModuleName = "client.slua.logic.download.puffer.prefetch.puffer_prefetch_manager",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  puffer_ugcpak_downloader = {
    KeyName = "puffer_ugcpak_downloader",
    ModuleName = "client.slua.logic.download.puffer.ugcpak.puffer_ugcpak_downloader"
  },
  puffer_ugcpak_manager = {
    KeyName = "puffer_ugcpak_manager",
    ModuleName = "client.slua.logic.download.puffer.ugcpak.puffer_ugcpak_manager",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  UIComponentModule = {
    KeyName = "UIComponentModule",
    ModuleName = "client.slua.component.UIComponentModule.UIComponentModule",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  UIPreload = {
    KeyName = "UIPreload",
    ModuleName = "client.slua_ui_framework.preload.UIPreload",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  PreloadAssetManager = {
    KeyName = "PreloadAssetManager",
    ModuleName = "client.slua_ui_framework.preload.PreloadAssetManager",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  avatar_pool = {
    KeyName = "avatar_pool",
    ModuleName = "client.slua_ui_framework.pool.avatar_pool",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  chat_pool = {
    KeyName = "chat_pool",
    ModuleName = "client.slua_ui_framework.pool.chat_pool",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  downloadui_pool = {
    KeyName = "downloadui_pool",
    ModuleName = "client.slua_ui_framework.pool.downloadui_pool",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  rank_integral_pool = {
    KeyName = "rank_integral_pool",
    ModuleName = "client.slua_ui_framework.pool.rank_integral_pool",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  other_pool = {
    KeyName = "other_pool",
    ModuleName = "client.slua_ui_framework.pool.other_pool",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  item_pool = {
    KeyName = "item_pool",
    ModuleName = "client.slua_ui_framework.pool.item_pool",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  reddot_pool = {
    KeyName = "reddot_pool",
    ModuleName = "client.slua_ui_framework.pool.reddot_pool",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  ui_pool = {
    KeyName = "ui_pool",
    ModuleName = "client.slua_ui_framework.pool.ui_pool",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  pool_controller = {
    KeyName = "pool_controller",
    ModuleName = "client.slua_ui_framework.pool.pool_controller",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  puffer_queue = {
    KeyName = "puffer_queue",
    ModuleName = "client.slua.logic.download.puffer.puffer_queue",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  Logic_BattleDownloadMgr = {
    KeyName = "Logic_BattleDownloadMgr",
    ModuleName = "client.slua.logic.download.puffer.Logic_BattleDownloadMgr",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  smart_download_monitor = {
    KeyName = "logic_smart_download_monitor",
    ModuleName = "client.slua.logic.download.report.smart_download_monitor",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  logic_multiple_area = {
    KeyName = "logic_multiple_area",
    ModuleName = "client.slua.logic.multiple_area.logic_multiple_area"
  },
  share_module = {
    KeyName = "share_module",
    ModuleName = "client.logic.share.share_module"
  },
  logic_chat_voice = {
    KeyName = "logic_chat_voice",
    ModuleName = "client.slua.logic.chat_voice.logic_chat_voice",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_antsvoice_interface = {
    KeyName = "logic_antsvoice_interface",
    ModuleName = "client.slua.logic.chat_voice.logic_antsvoice_interface",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  QRcodeRestrictManager = {
    KeyName = "QRcodeRestrictManager",
    ModuleName = "client.slua.logic.QRCodeLogin.QRcodeRestrictManager",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  image_download_mgr = {
    KeyName = "image_download_mgr",
    ModuleName = "client.slua.logic.image_download.image_download_mgr",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  http_manager = {
    KeyName = "http_manager",
    ModuleName = "client.slua.logic.http.http_manager"
  },
  ChatRedpacketManager = {
    KeyName = "ChatRedpacketManager",
    ModuleName = "client.slua.logic.crp.ChatRedpacketManager"
  },
  LogicPHomeStore = {
    KeyName = "LogicPHomeStore",
    ModuleName = "client.slua.logic.homestore.LogicPHomeStore",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  LogicPHomeStoreActivity = {
    KeyName = "LogicPHomeStoreActivity",
    ModuleName = "client.slua.logic.homestore.LogicPHomeStoreActivity",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_depot_items_time = {
    KeyName = "logic_depot_items_time",
    ModuleName = "client.slua.logic.homestore.logic_depot_items_time",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  LogicHomeParty = {
    KeyName = "LogicHomeParty",
    ModuleName = "client.slua.logic.homeparty.LogicHomeParty",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  LogicLudo = {
    KeyName = "LogicLudo",
    ModuleName = "client.slua.logic.ludo.LogicLudo",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  LogicSmartAssistant = {
    KeyName = "LogicSmartAssistant",
    ModuleName = "client.slua.logic.sa.LogicSmartAssistant"
  },
  LogicShowBrand = {
    KeyName = "LogicShowBrand",
    ModuleName = "client.slua.logic.showbrand.LogicShowBrand"
  },
  logic_enter_lobby_scheduler = {
    KeyName = "logic_enter_lobby_scheduler",
    ModuleName = "client.slua.logic.lobby.logic_enter_lobby_scheduler",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  SceneSwitchLatenQueueSystem = {
    KeyName = "SceneSwitchLatenQueueSystem",
    ModuleName = "client.slua.logic.lobby.SceneSwitchLatenQueueSystem",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_planz_switches = {
    KeyName = "logic_planz_switches",
    ModuleName = "client.slua.logic.PlanZ.logic_planz_switches",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  serverlist_downloader = {
    KeyName = "serverlist_downloader",
    ModuleName = "client.slua.logic.serverlist.serverlist_downloader",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  BLUEHOLES_serverlist_downloader = {
    KeyName = "BLUEHOLES_serverlist_downloader",
    ModuleName = "blacklist.serverlist.BLUEHOLES_serverlist_downloader",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  skill_selection_system = {
    KeyName = "skill_selection_system",
    ModuleName = "client.slua.logic.skill_selection_system.skill_selection_system",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  skill_task_system = {
    KeyName = "skill_task_system",
    ModuleName = "client.slua.logic.skill_selection_system.skill_task_system",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  LobbyAssetPreloader = {
    KeyName = "LobbyAssetPreloader",
    ModuleName = "client.slua.logic.lobby.LobbyAssetPreloader",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_segment_title = {
    KeyName = "logic_segment_title",
    ModuleName = "client.slua.logic.segment.logic_segment_title"
  },
  logic_recommend_friend = {
    KeyName = "logic_recommend_friend",
    ModuleName = "client.slua.logic.recommend.logic_recommend_friend"
  },
  logic_return_recommend_friend = {
    KeyName = "logic_return_recommend_friend",
    ModuleName = "client.slua.logic.recommend.logic_return_recommend_friend",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_recommend_labels = {
    KeyName = "logic_recommend_labels",
    ModuleName = "client.slua.logic.recommend.logic_recommend_labels"
  },
  newbie_download_module = {
    KeyName = "newbie_download_module",
    ModuleName = "client.logic.newbie.newbie_download_module"
  },
  texture_cache_mgr = {
    KeyName = "texture_cache_mgr",
    ModuleName = "client.slua.logic.texture.texture_cache_mgr"
  },
  logic_gamelet_interface = {
    KeyName = "logic_gamelet_interface",
    ModuleName = "client.slua.logic.gamelet.logic_gamelet_interface",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  GameletResMonitor = {
    KeyName = "GameletResMonitor",
    ModuleName = "client.slua.logic.gamelet.GameletResMonitor",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_cost_collector = {
    KeyName = "logic_cost_collector",
    ModuleName = "client.slua.logic.cost_collector.logic_cost_collector",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  UIAdaptation = {
    KeyName = "UIAdaptation",
    ModuleName = "client.slua.logic.UIAdaptation.UIAdaptation",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  LogicNewbieAssist = {
    KeyName = "LogicNewbieAssist",
    ModuleName = "client.slua.logic.activity.newbie.LogicNewbieAssist",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_pet = {
    KeyName = "logic_pet",
    ModuleName = "client.slua.logic.pet.logic_pet",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_outfit_combination = {
    KeyName = "logic_outfit_combination",
    ModuleName = "client.slua.logic.wardrobe.logic_outfit_combination"
  },
  logic_suit_dye = {
    KeyName = "logic_suit_dye",
    ModuleName = "client.slua.logic.suit_dye.logic_suit_dye",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_weapon_pendant = {
    KeyName = "logic_weapon_pendant",
    ModuleName = "client.slua.logic.weapon_pendant.logic_weapon_pendant",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  LogicVehicleDIY = {
    KeyName = "LogicVehicleDIY",
    ModuleName = "client.logic.vehicle.LogicVehicleDIY",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  NicknameColorManager = {
    KeyName = "NicknameColorManager",
    ModuleName = "client.slua.logic.nickname_color.NicknameColorManager",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_battle_profile = {
    KeyName = "logic_battle_profile",
    ModuleName = "client.slua.logic.battle_profile.logic_battle_profile"
  },
  logic_tdm_rating_protect = {
    KeyName = "logic_tdm_rating_protect",
    ModuleName = "client.slua.logic.teamup.logic_tdm_rating_protect",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_qr_code = {
    KeyName = "logic_qr_code",
    ModuleName = "client.slua.logic.common.qr_code.logic_qr_code"
  },
  logic_ping_delay_report = {
    KeyName = "logic_ping_delay_report",
    ModuleName = "client.slua.logic.match.logic_ping_delay_report",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  LogicUserBattleDataManager = {
    KeyName = "LogicUserBattleDataManager",
    ModuleName = "client.slua.logic.common.LogicUserBattleDataManager",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  NewFaceSlapSystem = {
    KeyName = "NewFaceSlapSystem",
    ModuleName = "client.slua.logic.FaceSlap.NewFaceSlapSystem",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_loginlobby_timestamp = {
    KeyName = "logic_loginlobby_timestamp",
    ModuleName = "blacklist.slua.logic.lobby.logic_loginlobby_timestamp",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  AdjustSystem = {
    KeyName = "AdjustSystem",
    ModuleName = "client.slua.logic.adjust.AdjustSystem"
  },
  PushSystem = {
    KeyName = "PushSystem",
    ModuleName = "client.slua.logic.push.PushSystem"
  },
  LocalPushSystem = {
    KeyName = "LocalPushSystem",
    ModuleName = "client.slua.logic.push.LocalPushSystem",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  rare_item_get_module = {
    KeyName = "rare_item_get_module",
    ModuleName = "client.slua.logic.common.CommonItemGet.rare_item_get_module"
  },
  live_video_module = {
    KeyName = "live_video_module",
    ModuleName = "client.slua.logic.live_video.live_video_module"
  },
  ui_navigation_manager = {
    KeyName = "ui_navigation_manager",
    ModuleName = "client.common.uibase.ui_navigation_manager",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  pandora_common_protocol = {
    KeyName = "pandora_common_protocol",
    ModuleName = "client.slua.logic.Pandora.pandora_common_protocol",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  HostedProtoBridge = {
    KeyName = "HostedProtoBridge",
    ModuleName = "client.slua.logic.HostedProtoBridge.HostedProtoBridge",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  HostedCommonProtocol = {
    KeyName = "HostedCommonProtocol",
    ModuleName = "client.slua.logic.HostedProtoBridge.ImplProtocol.HostedCommonProtocol",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  HostedFriendProtocol = {
    KeyName = "HostedFriendProtocol",
    ModuleName = "client.slua.logic.HostedProtoBridge.ImplProtocol.HostedFriendProtocol",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  CoupleAvatarSystem = {
    KeyName = "CoupleAvatarSystem",
    ModuleName = "client.slua.logic.lobby.Left.CoupleAvatarSystem",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  AvatarDataCenter = {
    KeyName = "AvatarDataCenter",
    ModuleName = "client.logic.avatar.AvatarDataCenter",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_no_auth_util = {
    KeyName = "logic_no_auth_util",
    ModuleName = "client.logic.login.logic_no_auth_util"
  },
  logic_home_detail = {
    KeyName = "logic_home_detail",
    ModuleName = "client.slua.logic.home.Detail.logic_home_detail"
  },
  logic_home_housekeeper = {
    KeyName = "logic_home_housekeeper",
    ModuleName = "client.slua.logic.home.housekeeper.logic_home_housekeeper",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_housekeeper_dialog_lobby = {
    KeyName = "logic_housekeeper_dialog_lobby",
    ModuleName = "client.slua.logic.home.housekeeper.logic_housekeeper_dialog_lobby",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_housekeeper_dialog_battle = {
    KeyName = "logic_housekeeper_dialog_battle",
    ModuleName = "client.slua.logic.home.housekeeper.logic_housekeeper_dialog_battle",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_housekeeper_AI = {
    KeyName = "logic_housekeeper_AI",
    ModuleName = "client.slua.logic.home.housekeeper.AIChat.logic_housekeeper_AI",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_AIChat_Adult = {
    KeyName = "logic_AIChat_Adult",
    ModuleName = "client.slua.logic.home.housekeeper.AIChat.logic_AIChat_Adult",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_AIChat_Count = {
    KeyName = "logic_AIChat_Count",
    ModuleName = "client.slua.logic.home.housekeeper.AIChat.logic_AIChat_Count",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_AIChat_Trans = {
    KeyName = "logic_AIChat_Trans",
    ModuleName = "client.slua.logic.home.housekeeper.AIChat.logic_AIChat_Trans",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_AIChat_UI = {
    KeyName = "logic_AIChat_UI",
    ModuleName = "client.slua.logic.home.housekeeper.AIChat.logic_AIChat_UI",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_home_housekeeper_faceslap = {
    KeyName = "logic_home_housekeeper_faceslap",
    ModuleName = "client.slua.logic.home.housekeeper.logic_home_housekeeper_faceslap",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_home_message_board = {
    KeyName = "logic_home_message_board",
    ModuleName = "client.slua.logic.home.message_board.logic_home_message_board"
  },
  logic_home_photowall = {
    KeyName = "logic_home_photowall",
    ModuleName = "client.slua.logic.home.logic_home_photowall",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_home_profile = {
    KeyName = "logic_home_profile",
    ModuleName = "client.slua.logic.home.Profile.logic_home_profile",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_home_edit_home = {
    KeyName = "logic_home_edit_home",
    ModuleName = "client.slua.logic.home.EditHome.logic_home_edit_home",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_home_edit_plan = {
    KeyName = "logic_home_edit_plan",
    ModuleName = "client.slua.logic.home.EditPlan.logic_home_edit_plan",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  logic_home_music = {
    KeyName = "logic_home_music",
    ModuleName = "client.slua.logic.home.HomeConsole.logic_home_music",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  PlanPHEditChatEntranceLogic = {
    KeyName = "PlanPHEditChatEntranceLogic",
    ModuleName = "client.slua.logic.lobby_chat.manor.PlanPHEditChatEntranceLogic"
  },
  PlanPHVisitChatEntranceLogic = {
    KeyName = "PlanPHVisitChatEntranceLogic",
    ModuleName = "client.slua.logic.lobby_chat.manor.PlanPHVisitChatEntranceLogic"
  },
  Logic_PlanCHVisitChatEntranceModule = {
    KeyName = "Logic_PlanCHVisitChatEntranceModule",
    ModuleName = "client.slua.logic.lobby_chat.hall.Logic_PlanCHVisitChatEntranceModule"
  },
  IslandChatEntranceLogic = {
    KeyName = "IslandChatEntranceLogic",
    ModuleName = "GameLua.Mod.SocialIsland.Client.Chat.IslandChatEntranceLogic"
  },
  logic_home_loading = {
    KeyName = "logic_home_loading",
    ModuleName = "client.slua.logic.home.loading.logic_home_loading",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  LogicCollectionHallLoading = {
    ModuleName = "client.slua.logic.CollectionHall.LogicCollectionHallLoading",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  LogicCollectionDetail = {
    ModuleName = "client.slua.logic.CollectionHall.LogicCollectionDetail"
  },
  LogicCollectionHallInvite = {
    ModuleName = "client.slua.logic.CollectionHall.LogicCollectionHallInvite"
  },
  standalone_map_enter_util = {
    KeyName = "standalone_map_enter_util",
    ModuleName = "client.slua.logic.home.standalone_map_enter_util",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_home_style = {
    KeyName = "logic_home_style",
    ModuleName = "client.slua.logic.home.style.logic_home_style"
  },
  logic_home_table_config = {
    KeyName = "logic_home_table_config",
    ModuleName = "client.slua.logic.home.Config.logic_home_table_config"
  },
  logic_home_album = {
    KeyName = "logic_home_album",
    ModuleName = "client.slua.logic.home.logic_home_album"
  },
  logic_home_golden_tree = {
    KeyName = "logic_home_golden_tree",
    ModuleName = "client.slua.logic.home.GoldenTree.logic_home_golden_tree",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_lobby_home_entry_item = {
    KeyName = "logic_lobby_home_entry_item",
    ModuleName = "client.slua.logic.home.Lobby.logic_lobby_home_entry_item",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_home_newbieguide = {
    KeyName = "logic_home_newbieguide",
    ModuleName = "client.slua.logic.home.NewbieGuide.logic_home_newbieguide",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_home_guidebook = {
    KeyName = "logic_home_guidebook",
    ModuleName = "client.slua.logic.home.HomeConsole.logic_home_guidebook",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_home_capture = {
    KeyName = "logic_home_capture",
    ModuleName = "client.slua.logic.home.Capture.logic_home_capture"
  },
  logic_home_party_redpacket = {
    KeyName = "logic_home_party_redpacket",
    ModuleName = "client.slua.logic.home.PartyRedpacket.logic_home_party_redpacket"
  },
  logic_home_exchange_dealer = {
    KeyName = "logic_home_exchange_dealer",
    ModuleName = "client.slua.logic.home.ExchangeDealer.logic_home_exchange_dealer"
  },
  logic_home_party_personalise = {
    KeyName = "logic_home_party_personalise",
    ModuleName = "client.slua.logic.home.PartyRedpacket.logic_home_party_personalise"
  },
  LogicHalloween = {
    KeyName = "LogicHalloween",
    ModuleName = "client.slua.logic.home.Activity.Halloween.LogicHalloween",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  LogicSnowParty = {
    KeyName = "LogicSnowParty",
    ModuleName = "client.slua.logic.home.Activity.SnowParty.LogicSnowParty",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  LogicSnowMan = {
    KeyName = "LogicSnowMan",
    ModuleName = "client.slua.logic.home.Activity.SnowParty.LogicSnowMan",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_home_activity = {
    KeyName = "logic_home_activity",
    ModuleName = "client.slua.logic.home.Activity.logic_home_activity",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  store_supply_manager = {
    KeyName = "store_supply_manager",
    ModuleName = "client.slua.logic.store.store_supply_manager"
  },
  supply_repeated_manager = {
    KeyName = "supply_repeated_manager",
    ModuleName = "client.slua.logic.store.supply_repeated_manager"
  },
  supply_optional_data = {
    KeyName = "supply_optional_data",
    ModuleName = "client.slua.umg.NewStoreV280.NewStoreMove.supply.Mechanism.Optional.supply_optional_data"
  },
  Logic_BanSelectModeModule = {
    KeyName = "Logic_BanSelectModeModule",
    ModuleName = "client.slua.logic.common.Logic_BanSelectModeModule"
  },
  logic_promotion_mode = {
    KeyName = "logic_promotion_mode",
    ModuleName = "client.logic.season.promotion.logic_promotion_mode"
  },
  store_collect_data = {
    KeyName = "store_collect_data",
    ModuleName = "client.slua.logic.store.store_collect_data",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_home_jump = {
    KeyName = "logic_home_jump",
    ModuleName = "client.slua.logic.home.jump.logic_home_jump",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  pet_show_module = {
    KeyName = "pet_show_module",
    ModuleName = "client.slua.logic.pet.pet_show_module",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  LogicKillCounter = {
    KeyName = "LogicKillCounter",
    ModuleName = "client.logic.kill_features.LogicKillCounter",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  LogicKillCucolorisRecolor = {
    KeyName = "LogicKillCucolorisRecolor",
    ModuleName = "client.logic.kill_features.LogicKillCucolorisRecolor",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_home_party_historicalrecord = {
    KeyName = "logic_home_party_historicalrecord",
    ModuleName = "client.slua.logic.home.PartyRedpacket.logic_home_party_historicalrecord"
  },
  PubgmMusicGuideCtrl = {
    KeyName = "PubgmMusicGuideCtrl",
    ModuleName = "client.slua.umg.pubgm_music.PubgmMusicGuideCtrl"
  },
  logic_corps_fight_new = {
    KeyName = "logic_corps_fight_new",
    ModuleName = "client.slua.logic.corps.logic_corps_fight_new",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  logic_corps_teamfight = {
    KeyName = "logic_corps_teamfight",
    ModuleName = "client.slua.logic.corps.logic_corps_teamfight",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  LogicHDmpveUpload = {
    KeyName = "LogicHDmpveUpload",
    ModuleName = "client.slua.logic.HDmpveUpload.LogicHDmpveUpload",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_home_level_extra_reward = {
    KeyName = "logic_home_level_extra_reward",
    ModuleName = "client.slua.logic.home.level.logic_home_level_extra_reward",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_home_smart_upgrade = {
    KeyName = "logic_home_smart_upgrade",
    ModuleName = "client.slua.logic.home.level.logic_home_smart_upgrade",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_home_joint = {
    KeyName = "logic_home_joint",
    ModuleName = "client.slua.logic.home.joint.logic_home_joint",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_home_anniversary_activity = {
    KeyName = "logic_home_anniversary_activity",
    ModuleName = "client.slua.logic.home.Activity.Anniversary.logic_home_anniversary_activity",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_home_car_parking = {
    KeyName = "logic_home_car_parking",
    ModuleName = "client.slua.logic.home.CarParking.logic_home_car_parking",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_home_car_parking_invite = {
    KeyName = "logic_home_car_parking_invite",
    ModuleName = "client.slua.logic.home.CarParking.logic_home_car_parking_invite",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_home_car_parking_auto_park = {
    KeyName = "logic_home_car_parking_auto_park",
    ModuleName = "client.slua.logic.home.CarParking.logic_home_car_parking_auto_park",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_home_car_parking_slap = {
    KeyName = "logic_home_car_parking_slap",
    ModuleName = "client.slua.logic.home.CarParking.logic_home_car_parking_slap",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_home_car_parking_guide = {
    KeyName = "logic_home_car_parking_guide",
    ModuleName = "client.slua.logic.home.CarParking.logic_home_car_parking_guide",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_home_car_parking_rank = {
    KeyName = "logic_home_car_parking_rank",
    ModuleName = "client.slua.logic.home.CarParking.logic_home_car_parking_rank",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_home_car_parking_gift = {
    KeyName = "logic_home_car_parking_gift",
    ModuleName = "client.slua.logic.home.CarParking.logic_home_car_parking_gift",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_home_parking_coin_alert = {
    KeyName = "logic_home_parking_coin_alert",
    ModuleName = "client.slua.logic.home.CarParking.logic_home_parking_coin_alert",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_home_car_parking_store = {
    KeyName = "logic_home_car_parking_store",
    ModuleName = "client.slua.logic.home.CarParking.logic_home_car_parking_store",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_home_pass = {
    KeyName = "logic_home_pass",
    ModuleName = "client.slua.logic.home.CraftmanPass.logic_home_pass",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_home_theme = {
    KeyName = "logic_home_theme",
    ModuleName = "client.slua.logic.home.Activity.NewTheme.logic_home_theme",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_home_installment = {
    KeyName = "logic_home_installment",
    ModuleName = "client.slua.logic.home.Installment.logic_home_installment",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_friend_list = {
    KeyName = "logic_friend_list",
    ModuleName = "client.slua.logic.friend.logic_friend_list",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_friend = {
    KeyName = "logic_friend",
    ModuleName = "client.slua.logic.friend.refactor.logic_friend",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_friend_list_ui = {
    KeyName = "logic_friend_list_ui",
    ModuleName = "client.slua.logic.friend.refactor.logic_friend_list_ui",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_friendlistitem_custom = {
    KeyName = "logic_friendlistitem_custom",
    ModuleName = "client.slua.logic.friend.logic_friendlistitem_custom",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_friend_spk_fb = {
    KeyName = "logic_friend_spk_fb",
    ModuleName = "client.slua.logic.friend.logic_friend_spk_fb",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_friend_group = {
    KeyName = "logic_friend_group",
    ModuleName = "client.slua.logic.friend.logic_friend_group",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_friend_group_tools = {
    KeyName = "logic_friend_group_tools",
    ModuleName = "client.slua.logic.friend.logic_friend_group_tools",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_friend_memory_record = {
    KeyName = "logic_friend_memory_record",
    ModuleName = "client.slua.logic.friend.logic_friend_memory_record",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_community_shield_tool = {
    KeyName = "logic_community_shield_tool",
    ModuleName = "client.slua.logic.community.logic_community_shield_tool",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_cloud_game = {
    KeyName = "logic_cloud_game",
    ModuleName = "client.slua.logic.cloud_game.logic_cloud_game",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  logic_pipeline_helper = {
    KeyName = "logic_pipeline_helper",
    ModuleName = "client.slua.logic.pipelinehelper.logic_pipeline_helper"
  },
  LogicSmartHousekeeper = {
    KeyName = "LogicSmartHousekeeper",
    ModuleName = "client.slua.logic.sa.LogicSmartHousekeeper",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  logic_home_audit_state = {
    KeyName = "logic_home_audit_state",
    ModuleName = "client.slua.logic.home.Audit.logic_home_audit_state",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  logic_AllDetail = {
    KeyName = "logic_AllDetail",
    ModuleName = "client.slua.logic.home.logic_AllDetail"
  },
  pet_pawn_pool = {
    KeyName = "pet_pawn_pool",
    ModuleName = "client.slua.logic.pet.pet_pawn_pool",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  AvatarGIFImageBPPool = {
    KeyName = "AvatarGIFImageBPPool",
    ModuleName = "client.slua.component.avatar.AvatarGIFImageBPPool",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  logic_share_bag_team_util = {
    KeyName = "logic_share_bag_team_util",
    ModuleName = "client.slua.logic.share_bag.logic_share_bag_team_util",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  LogicInheritSystem = {
    KeyName = "LogicInheritSystem",
    ModuleName = "client.slua.logic.Inherit.LogicInheritSystem",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  LogicInheritWardrobe = {
    KeyName = "LogicInheritWardrobe",
    ModuleName = "client.slua.logic.Inherit.LogicInheritWardrobe",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_card_collection = {
    KeyName = "logic_card_collection",
    ModuleName = "client.slua.logic.card_collection.logic_card_collection"
  },
  logic_notification_system = {
    KeyName = "logic_notification_system",
    ModuleName = "client.slua.logic.notification_system.logic_notification_system"
  },
  logic_ugc_codeprefab = {
    KeyName = "logic_ugc_codeprefab",
    ModuleName = "client.slua.logic.ugc.logic_ugc_codeprefab",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_ugc_appreciation_group = {
    KeyName = "logic_ugc_appreciation_group",
    ModuleName = "client.slua.logic.ugc.logic_ugc_appreciation_group",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_ugc_prefab_mall = {
    KeyName = "logic_ugc_prefab_mall",
    ModuleName = "client.slua.logic.ugc.PrefabMall.logic_ugc_prefab_mall",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_resbucket = {
    KeyName = "logic_resbucket",
    ModuleName = "client.slua.logic.ugc.ResBucket.logic_resbucket",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_common_task = {
    KeyName = "logic_common_task",
    ModuleName = "client.logic.common_task.logic_common_task"
  },
  mem_opt = {
    KeyName = "mem_opt",
    ModuleName = "client.common.mem_opt",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  multi_state_manager = {
    KeyName = "multi_state_manager",
    ModuleName = "client.slua.logic.golden_suit.multi_state_manager"
  },
  ScrapGoldManger = {
    KeyName = "ScrapGoldManger",
    ModuleName = "client.slua.logic.lobby_activity.scrap_gold.ScrapGoldManger"
  },
  LogicBackpackClothUIUtil = {
    KeyName = "LogicBackpackClothUIUtil",
    ModuleName = "client.slua.logic.backpack.LogicBackpackClothUIUtil"
  },
  logic_main_city_join = {
    KeyName = "logic_main_city_join",
    ModuleName = "GameLua.Mod.MainCity.Client.logic.logic_main_city_join"
  },
  logic_main_city_album = {
    KeyName = "logic_main_city_album",
    ModuleName = "client.slua.logic.main_city.logic_main_city_album"
  },
  logic_main_city_latent_queue = {
    KeyName = "logic_main_city_latent_queue",
    ModuleName = "GameLua.Mod.MainCity.Client.logic.logic_main_city_latent_queue"
  },
  logic_main_city_interact = {
    KeyName = "logic_main_city_interact",
    ModuleName = "GameLua.Mod.MainCity.Client.logic.logic_main_city_interact"
  },
  passive_resource_downloader = {
    KeyName = "passive_resource_downloader",
    ModuleName = "client.slua.logic.download.passive_resource.passive_resource_downloader",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  Logic_temu = {
    KeyName = "Logic_temu",
    ModuleName = "client.slua.logic.specialoffer.Temu.Logic_temu"
  },
  ItemUpgradeModule = {
    KeyName = "ItemUpgradeModule",
    ModuleName = "client.logic.ItemUpgrade.ItemUpgradeModule",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  headshot_module = {
    KeyName = "headshot_module",
    ModuleName = "client.slua.logic.headshot.headshot_module",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_weaponstrength_result = {
    KeyName = "logic_weaponstrength_result",
    ModuleName = "client.slua.logic.weapon_strength.logic_weaponstrength_result",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_market_weekend = {
    KeyName = "logic_market_weekend",
    ModuleName = "client.slua.logic.activity.logic_market_weekend"
  },
  logic_ugc_prefab_mall_search = {
    KeyName = "logic_ugc_prefab_mall_search",
    ModuleName = "client.slua.logic.ugc.PrefabMall.logic_ugc_prefab_mall_search"
  },
  logic_wedding_vehicles = {
    KeyName = "logic_wedding_vehicles",
    ModuleName = "client.slua.logic.home.Wedding.logic_wedding_vehicles"
  },
  logic_wedding_home_tips = {
    KeyName = "logic_wedding_home_tips",
    ModuleName = "client.slua.logic.home.Wedding.logic_wedding_home_tips"
  },
  logic_wedding_dance = {
    KeyName = "logic_wedding_dance",
    ModuleName = "client.slua.logic.home.Wedding.logic_wedding_dance"
  },
  PatrollerModule = {
    KeyName = "PatrollerModule",
    ModuleName = "client.slua.logic.patroller.PatrollerModule"
  },
  AWSHelper = {
    KeyName = "AWSHelper",
    ModuleName = "client.logic.aws.AWSHelper"
  },
  logic_ds_monitor = {
    KeyName = "logic_ds_monitor",
    ModuleName = "client.logic.data.logic_ds_monitor",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  logic_ugc_propshop = {
    KeyName = "logic_ugc_propshop",
    ModuleName = "client.slua.logic.ugc.logic_ugc_propshop"
  },
  logic_post_switch_popup = {
    KeyName = "logic_post_switch_popup",
    ModuleName = "client.slua.logic.post_switch_popup.logic_post_switch_popup",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  ClickEffectModule = {
    KeyName = "ClickEffectModule",
    ModuleName = "client.slua.logic.ClickEffect.ClickEffectModule",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  logic_battle_data_transmission = {
    KeyName = "logic_battle_data_transmission",
    ModuleName = "client.slua.logic.data_transmission.logic_battle_data_transmission",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_home_wow_display = {
    KeyName = "logic_home_wow_display",
    ModuleName = "client.slua.logic.home.logic_home_wow_display",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_time_cost_report = {
    KeyName = "logic_time_cost_report",
    ModuleName = "client.slua.logic.performance.logic_time_cost_report",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  logic_home_promotion_activity = {
    KeyName = "logic_home_promotion_activity",
    ModuleName = "client.slua.logic.homestore.logic_home_promotion_activity",
    ModuleLevel = ModuleMacro.ModuleLevel.SceneLevel
  },
  logic_promotion = {
    KeyName = "logic_promotion",
    ModuleName = "client.slua.logic.promotion.logic_promotion",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  NoticesModule = {
    KeyName = "NoticesModule",
    ModuleName = "client.logic.Notice.NoticesModule",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  SkelMeshLODManager = {
    KeyName = "SkelMeshLODManager",
    ModuleName = "client.slua.logic.lobby.SkelMeshLODManager",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  logic_flash_match_team = {
    KeyName = "logic_flash_match_team",
    ModuleName = "client.slua.logic.friend.logic_flash_match_team",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_flash_match_team_online = {
    KeyName = "logic_flash_match_team_online",
    ModuleName = "client.slua.logic.friend.logic_flash_match_team_online",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_flash_team_season = {
    KeyName = "logic_flash_team_season",
    ModuleName = "client.slua.logic.friend.flash_team.logic_flash_team_season",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_lobby_user_research = {
    KeyName = "logic_lobby_user_research",
    ModuleName = "client.slua.logic.lobby.logic_lobby_user_research",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_flash_team_utils = {
    KeyName = "logic_flash_team_utils",
    ModuleName = "client.slua.logic.friend.flash_team.logic_flash_team_utils",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  }
}
local StatusStartConfig = {
  [GameStatus.Login] = "client.module_framework.status.LoginStartupModule",
  [GameStatus.Lobby] = "client.module_framework.status.LobbyStartupModule",
  [GameStatus.Fighting] = "client.module_framework.status.FightingStartupModule"
}
function ModuleConfig.GetGameStatusStartConfig()
  return StatusStartConfig
end
return ModuleConfig