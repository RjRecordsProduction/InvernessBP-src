local ModuleMacro = require("client.module_framework.ModuleMacro")
local ModuleConfig = {
  Libya_module = {
    KeyName = "Libya_module",
    ModuleName = "client.logic.countryarea.Libya_module"
  },
  logic_marketing_agreement = {
    KeyName = "logic_marketing_agreement",
    ModuleName = "client.logic.countryarea.logic_marketing_agreement",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  ban_login_module = {
    KeyName = "ban_login_module",
    ModuleName = "client.slua.logic.login.ban_login_module",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  version_up_module = {
    KeyName = "version_up_module",
    ModuleName = "client.logic.update_login.version_up_module",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  login_module = {
    KeyName = "login_module",
    ModuleName = "client.slua.logic.login.login_module",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  logic_login_event = {
    KeyName = "logic_login_event",
    ModuleName = "client.logic.login.logic_login_event",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  device_module = {
    KeyName = "device_module",
    ModuleName = "client.slua.logic.login.device_module",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  Logic_LobbyModule = {
    KeyName = "Logic_LobbyModule",
    ModuleName = "client.logic.login.Logic_LobbyModule",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  Logic_SocialLobbyModule = {
    KeyName = "Logic_SocialLobbyModule",
    ModuleName = "client.slua.logic.lobby.Left.Logic_SocialLobbyModule"
  },
  Logic_SocialLobbyEditMgrModule = {
    KeyName = "Logic_SocialLobbyEditMgrModule",
    ModuleName = "client.slua.logic.lobby.Left.Logic_SocialLobbyEditMgrModule"
  },
  golden_suit_module = {
    KeyName = "golden_suit_module",
    ModuleName = "client.slua.logic.golden_suit.golden_suit_module"
  },
  logic_Intimacy_Pose_dress_replace = {
    KeyName = "logic_Intimacy_Pose_dress_replace",
    ModuleName = "client.slua.logic.lobby.Left.logic_Intimacy_Pose_dress_replace"
  },
  full_preview_module = {
    KeyName = "full_preview_module",
    ModuleName = "GameLua.Mod.Lobby.Base.Common.full_preview_module",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  feature_module = {
    KeyName = "feature_module",
    ModuleName = "GameLua.Mod.Lobby.Base.Common.feature_module",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  collect_module = {
    KeyName = "collect_module",
    ModuleName = "GameLua.Mod.Lobby.Base.Collect.logic.collect_module",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  collect_clothe_module = {
    KeyName = "collect_clothe_module",
    ModuleName = "GameLua.Mod.Lobby.Base.Collect.logic.collect_clothe_module",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  collect_gun_module = {
    KeyName = "collect_gun_module",
    ModuleName = "GameLua.Mod.Lobby.Base.Collect.logic.collect_gun_module",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  collect_vehicle_module = {
    KeyName = "collect_vehicle_module",
    ModuleName = "GameLua.Mod.Lobby.Base.Collect.logic.collect_vehicle_module",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  collect_reddot_module = {
    KeyName = "collect_reddot_module",
    ModuleName = "GameLua.Mod.Lobby.Base.Collect.logic.collect_reddot_module",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  collect_up_level = {
    KeyName = "collect_up_level",
    ModuleName = "GameLua.Mod.Lobby.Base.Collect.logic.collect_up_level"
  },
  collect_rank_season_module = {
    KeyName = "collect_rank_season_module",
    ModuleName = "GameLua.Mod.Lobby.Split.Collect.logic.rank.collect_rank_season_module"
  },
  collect_rank_entry_module = {
    KeyName = "collect_rank_entry_module",
    ModuleName = "GameLua.Mod.Lobby.Base.Collect.logic.rank.collect_rank_entry_module"
  },
  collect_rank_total_module = {
    KeyName = "collect_rank_total_module",
    ModuleName = "GameLua.Mod.Lobby.Split.Collect.logic.rank.collect_rank_total_module"
  },
  collect_career_module = {
    KeyName = "collect_career_module",
    ModuleName = "GameLua.Mod.Lobby.Base.Collect.logic.collect_career_module"
  },
  collect_season_module = {
    KeyName = "collect_season_module",
    ModuleName = "GameLua.Mod.Lobby.Base.Collect.logic.collect_season_module"
  },
  collect_bgm_module = {
    KeyName = "collect_bgm_module",
    ModuleName = "GameLua.Mod.Lobby.Split.Collect.logic.collect_bgm_module",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  collect_available_module = {
    KeyName = "collect_available_module",
    ModuleName = "GameLua.Mod.Lobby.Base.Collect.logic.collect_available_module",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  collect_encryption_module = {
    KeyName = "collect_encryption_module",
    ModuleName = "GameLua.Mod.Lobby.Base.Collect.logic.collect_encryption_module"
  },
  collect_pet_module = {
    KeyName = "collect_pet_module",
    ModuleName = "GameLua.Mod.Lobby.Base.Collect.logic.collect_pet_module",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  collect_limit_module = {
    KeyName = "collect_limit_module",
    ModuleName = "GameLua.Mod.Lobby.Base.Collect.logic.collect_limit_module"
  },
  collect_introduction_module = {
    KeyName = "collect_introduction_module",
    ModuleName = "GameLua.Mod.Lobby.Base.Collect.logic.collect_introduction_module"
  },
  collect_pavilions_module = {
    KeyName = "collect_pavilions_module",
    ModuleName = "GameLua.Mod.Lobby.Base.Collect.logic.collect_pavilions_module",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  collect_tlog_module = {
    KeyName = "collect_tlog_module",
    ModuleName = "GameLua.Mod.Lobby.Split.Collect.logic.collect_tlog_module",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  collect_room_module = {
    KeyName = "collect_room_module",
    ModuleName = "GameLua.Mod.Lobby.Base.Collect.logic.collect_room_module",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  collect_privacy_module = {
    KeyName = "collect_privacy_module",
    ModuleName = "GameLua.Mod.Lobby.Base.Collect.logic.collect_privacy_module",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  collect_theme_module = {
    KeyName = "collect_theme_module",
    ModuleName = "GameLua.Mod.Lobby.Base.Collect.logic.collect_theme_module",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  collect_library_module = {
    KeyName = "collect_library_module",
    ModuleName = "GameLua.Mod.Lobby.Base.Collect.logic.collect_library_module",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  collect_badge_module = {
    KeyName = "collect_badge_module",
    ModuleName = "GameLua.Mod.Lobby.Base.Collect.logic.collect_badge_module",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  collect_award_module = {
    KeyName = "collect_award_module",
    ModuleName = "GameLua.Mod.Lobby.Split.Collect.logic.collect_award_module",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  collect_guide_module = {
    KeyName = "collect_guide_module",
    ModuleName = "GameLua.Mod.Lobby.Base.Collect.logic.collect_guide_module",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  CollectLikeRankModule = {
    KeyName = "CollectLikeRankModule",
    ModuleName = "GameLua.Mod.Lobby.Split.Collect.logic.rank.CollectLikeRankModule"
  },
  queue_task_module = {
    KeyName = "queue_task_module",
    ModuleName = "client.slua.logic.event_task.queue_task_module",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  reddot_node_collect_manager = {
    KeyName = "reddot_node_collect_manager",
    ModuleName = "GameLua.Mod.Lobby.Base.Collect.umg.ReddotManager.reddot_node_collect_manager",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  collect_inherit_data = {
    KeyName = "collect_inherit_data",
    ModuleName = "GameLua.Mod.Lobby.Base.Collect.umg.Inherit.collect_inherit_data"
  },
  logic_chat_entrance = {
    KeyName = "logic_chat_entrance",
    ModuleName = "client.slua.logic.lobby_chat.logic_chat_entrance"
  },
  logic_mode_selection = {
    KeyName = "logic_mode_selection",
    ModuleName = "client.slua.logic.mode_selection.logic_mode_selection",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_mode_peak = {
    KeyName = "logic_mode_peak",
    ModuleName = "client.slua.logic.mode_selection.logic_mode_peak"
  },
  logic_mode_asymmertric = {
    KeyName = "logic_mode_asymmertric",
    ModuleName = "client.slua.logic.mode_selection.logic_mode_asymmertric",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_enter_game = {
    KeyName = "logic_enter_game",
    ModuleName = "client.slua.logic.mode_selection.logic_enter_game",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  logic_enter_guide = {
    KeyName = "logic_enter_guide",
    ModuleName = "client.slua.logic.growth_project.logic_enter_guide",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_mode_map_download = {
    KeyName = "logic_mode_map_download",
    ModuleName = "client.slua.logic.mode_selection.logic_mode_map_download"
  },
  logic_mode_uilogic = {
    KeyName = "logic_mode_uilogic",
    ModuleName = "client.slua.logic.mode_selection.logic_mode_uilogic"
  },
  logic_recruit_filter_new = {
    KeyName = "logic_recruit_filter_new",
    ModuleName = "client.slua.logic.lobby_chat.recruit.logic_recruit_filter_new"
  },
  logic_recruit_new = {
    KeyName = "logic_recruit_new",
    ModuleName = "client.slua.logic.lobby_chat.recruit.logic_recruit_new"
  },
  logic_team_platform_new = {
    KeyName = "logic_team_platform_new",
    ModuleName = "client.slua.logic.teamup.logic_team_platform_new"
  },
  logic_reputation_system = {
    KeyName = "logic_reputation_system",
    ModuleName = "client.slua.logic.ReputationSystem.logic_reputation_system"
  },
  TipsManager = {
    KeyName = "TipsManager",
    ModuleName = "client.slua.logic.tip.TipsManager"
  },
  level_unlock_manager = {
    KeyName = "level_unlock_manager",
    ModuleName = "client.logic.level_unlock.level_unlock_manager",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  level_unlock_award_manager = {
    KeyName = "level_unlock_award_manager",
    ModuleName = "client.logic.level_unlock.level_unlock_award_manager",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_season_guide_manager = {
    KeyName = "logic_season_guide_manager",
    ModuleName = "client.logic.level_unlock.logic_season_guide_manager"
  },
  logic_level_unlock_report = {
    KeyName = "logic_level_unlock_report",
    ModuleName = "client.logic.level_unlock.logic_level_unlock_report"
  },
  logic_level_unlock_exp = {
    KeyName = "logic_level_unlock_exp",
    ModuleName = "client.logic.level_unlock.logic_level_unlock_exp"
  },
  logic_lobby_guide_manager = {
    KeyName = "logic_lobby_guide_manager",
    ModuleName = "client.logic.level_unlock.manager.logic_lobby_guide_manager"
  },
  logic_tournament_main = {
    KeyName = "logic_tournament_main",
    ModuleName = "client.slua.logic.tournament.logic_tournament_main"
  },
  logic_season_shop_system = {
    KeyName = "logic_season_shop_system",
    ModuleName = "client.logic.season.season_shop.logic_season_shop_system"
  },
  DragonChangeForm = {
    KeyName = "DragonChangeForm",
    ModuleName = "client.slua.logic.avatar.anim_notify_handler.DragonChangeForm"
  },
  LobbyThemeManager = {
    KeyName = "LobbyThemeManager",
    ModuleName = "client.logic.lobby.LobbyThemeManager"
  },
  AvatarCheckerModule = {
    KeyName = "AvatarCheckerModule",
    ModuleName = "blacklist.slua.logic.lobby_gm.AvatarCheckerModule"
  },
  LobbyThemeInteractiveManager = {
    KeyName = "LobbyThemeInteractiveManager",
    ModuleName = "client.logic.lobby.LobbyThemeInteractiveManager"
  },
  LobbyThemeParallaxManager = {
    KeyName = "LobbyThemeParallaxManager",
    ModuleName = "client.logic.lobby.LobbyThemeParallaxManager"
  },
  SubhallSystem = {
    KeyName = "SubhallSystem",
    ModuleName = "client.logic.lobby.subhall.SubhallSystem"
  },
  ThemeVehicleManager = {
    KeyName = "ThemeVehicleManager",
    ModuleName = "client.logic.lobby.ThemeVehicleManager"
  },
  GarageThemeSystem = {
    KeyName = "GarageThemeSystem",
    ModuleName = "client.logic.lobby.GarageThemeSystem"
  },
  logic_card_share_rank_data = {
    KeyName = "logic_card_share_rank_data",
    ModuleName = "client.slua.logic.lobby.Left.logic_card_share_rank_data"
  },
  logic_return_activity = {
    KeyName = "logic_return_activity",
    ModuleName = "client.slua.logic.return_activity.logic_return_activity"
  },
  logic_return_activity_level_reward = {
    KeyName = "logic_return_activity_level_reward",
    ModuleName = "client.slua.logic.return_activity.logic_return_activity_level_reward"
  },
  logic_return_activity_guide = {
    KeyName = "logic_return_activity_guide",
    ModuleName = "client.slua.logic.return_activity.logic_return_activity_guide"
  },
  logic_return_activity_first_battle = {
    KeyName = "logic_return_activity_first_battle",
    ModuleName = "client.slua.logic.return_activity.logic_return_activity_first_battle"
  },
  logic_login_background = {
    KeyName = "logic_login_background",
    ModuleName = "client.logic.login.logic_login_background"
  },
  logic_unknownpass_action = {
    KeyName = "logic_unknownpass_action",
    ModuleName = "client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_action"
  },
  Lobby_camera_manager_module = {
    KeyName = "Lobby_camera_manager_module",
    ModuleName = "client.slua.logic.lobby_camera.Lobby_camera_manager_module",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  logic_season_award = {
    KeyName = "logic_season_award",
    ModuleName = "client.logic.season.logic_season_award"
  },
  long_txt_manager = {
    KeyName = "long_txt_manager",
    ModuleName = "client.slua.logic.long_txt.long_txt_manager"
  },
  pet_manager = {
    KeyName = "pet_manager",
    ModuleName = "client.slua.logic.pet.pet_manager"
  },
  logic_avatar_capture_system = {
    KeyName = "logic_avatar_capture_system",
    ModuleName = "client.logic.share.logic_avatar_capture_system"
  },
  Corps_Avatar_Capture_SYSTEM = {
    KeyName = "Corps_Avatar_Capture_SYSTEM",
    ModuleName = "client.slua.logic.corps.Corps_Avatar_Capture_SYSTEM"
  },
  logic_store_enter_feature = {
    KeyName = "logic_store_enter_feature",
    ModuleName = "client.slua.logic.store.logic_store_enter_feature"
  },
  StoreDetailManager = {
    KeyName = "StoreDetailManager",
    ModuleName = "client.slua.logic.store.StoreDetailManager"
  },
  store_detail_data_select_chest = {
    KeyName = "store_detail_data_select_chest",
    ModuleName = "client.slua.logic.store.detail_data.store_detail_data_select_chest"
  },
  store_default_wear_manager = {
    KeyName = "store_default_wear_manager",
    ModuleName = "client.slua.logic.store.store_default_wear_manager"
  },
  view_component_manager = {
    KeyName = "view_component_manager",
    ModuleName = "client.slua.logic.store.view_component_manager"
  },
  logic_setting_recommended = {
    KeyName = "logic_setting_recommended",
    ModuleName = "client.logic.setting.logic_setting_recommended"
  },
  LogicAddScordCard = {
    KeyName = "LogicAddScordCard",
    ModuleName = "client.logic.double_card.logic_add_scord_card"
  },
  logic_team_recommend = {
    KeyName = "logic_team_recommend",
    ModuleName = "client.slua.logic.teamup.logic_team_recommend",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_return_team_recommend = {
    KeyName = "logic_return_team_recommend",
    ModuleName = "client.slua.logic.return_activity.logic_return_team_recommend",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_team_maincity = {
    KeyName = "logic_team_maincity",
    ModuleName = "client.slua.logic.teamup.logic_team_maincity",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_newbie_team_recommend = {
    KeyName = "logic_newbie_team_recommend",
    ModuleName = "client.slua.logic.newbie.logic_newbie_team_recommend",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_tournament_auth_check = {
    KeyName = "logic_tournament_auth_check",
    ModuleName = "client.slua.logic.tournament.logic_tournament_auth_check"
  },
  logic_worldcup_activity = {
    KeyName = "logic_worldcup_activity",
    ModuleName = "client.slua.logic.lobby_activity.world_cup.logic_worldcup_activity"
  },
  logic_xmission_entrance = {
    KeyName = "logic_xmission_entrance",
    ModuleName = "client.slua.logic.TxMission.logic_xmission_entrance"
  },
  logic_xmission_entry_tips = {
    KeyName = "logic_xmission_entry_tips",
    ModuleName = "client.slua.logic.TxMission.logic_xmission_entry_tips"
  },
  logic_xmission_insurance = {
    KeyName = "logic_xmission_insurance",
    ModuleName = "client.slua.logic.TxMission.insurance.logic_xmission_insurance"
  },
  logic_xmission_heirloom_equip = {
    KeyName = "logic_xmission_heirloom_equip",
    ModuleName = "client.slua.logic.TxMission.logic_xmission_heirloom_equip"
  },
  logic_xmission_map = {
    KeyName = "logic_xmission_map",
    ModuleName = "client.slua.logic.TxMission.match.logic_xmission_map"
  },
  logic_moment_bubble_tips = {
    KeyName = "logic_moment_bubble_tips",
    ModuleName = "client.slua.logic.moment.logic_moment_bubble_tips"
  },
  logic_moment_at = {
    KeyName = "logic_moment_at",
    ModuleName = "client.slua.logic.moment.logic_moment_at"
  },
  logic_friend_reserve = {
    KeyName = "logic_friend_reserve",
    ModuleName = "client.slua.logic.friend.logic_friend_reserve"
  },
  module_newbie_friends_gathering = {
    KeyName = "module_newbie_friends_gathering",
    ModuleName = "client.slua.logic.activity.newbie.module_newbie_friends_gathering",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_module_mix_lucky = {
    KeyName = "logic_module_mix_lucky",
    ModuleName = "client.slua.logic.lobby_activity.logic_module_mix_lucky"
  },
  url_parser = {
    KeyName = "url_parser",
    ModuleName = "client.slua.logic.url.url_parser"
  },
  BlackFridayMainModule = {
    KeyName = "BlackFridayMainModule",
    ModuleName = "GameLua.Mod.Lobby.Base.BlackFriday.Logic.BlackFridayMainModule"
  },
  BlackFridayGroupBuyModule = {
    KeyName = "BlackFridayGroupBuyModule",
    ModuleName = "GameLua.Mod.Lobby.Base.BlackFriday.Logic.BlackFridayGroupBuyModule"
  },
  BlackFridayPassModule = {
    KeyName = "BlackFridayPassModule",
    ModuleName = "GameLua.Mod.Lobby.Base.BlackFriday.Logic.BlackFridayPassModule"
  },
  BlackFridayUpgradeModule = {
    KeyName = "BlackFridayUpgradeModule",
    ModuleName = "GameLua.Mod.Lobby.Base.BlackFriday.Logic.BlackFridayUpgradeModule"
  },
  BlackFridayVowModule = {
    KeyName = "BlackFridayVowModule",
    ModuleName = "GameLua.Mod.Lobby.Base.BlackFriday.Logic.BlackFridayVowModule"
  },
  BlackFridayRankModule = {
    KeyName = "BlackFridayRankModule",
    ModuleName = "GameLua.Mod.Lobby.Base.BlackFriday.Logic.BlackFridayRankModule"
  },
  BlackFridayGunModule = {
    KeyName = "BlackFridayGunModule",
    ModuleName = "GameLua.Mod.Lobby.Base.BlackFriday.Logic.BlackFridayGunModule"
  },
  BlackFridayRedDotModule = {
    KeyName = "BlackFridayRedDotModule",
    ModuleName = "GameLua.Mod.Lobby.Base.BlackFriday.Logic.BlackFridayRedDotModule"
  },
  BlackFridayWeekSignModule = {
    KeyName = "BlackFridayWeekSignModule",
    ModuleName = "GameLua.Mod.Lobby.Base.BlackFriday.Logic.BlackFridayWeekSignModule"
  },
  BlackFridayEntranceModule = {
    KeyName = "BlackFridayEntranceModule",
    ModuleName = "GameLua.Mod.Lobby.Base.BlackFriday.Logic.BlackFridayEntranceModule"
  },
  BlackFridayRPGroupModule = {
    KeyName = "BlackFridayRPGroupModule",
    ModuleName = "GameLua.Mod.Lobby.Base.BlackFriday.Logic.BlackFridayRPGroupModule"
  },
  Logic_BFSubscribeModule = {
    KeyName = "Logic_BFSubscribeModule",
    ModuleName = "GameLua.Mod.Lobby.Base.BlackFriday.Logic.Logic_BFSubscribeModule"
  },
  Activity = {
    KeyName = "Activity",
    ModuleName = "client.slua.logic.activity.logic_act_module"
  },
  ActivityCenterTabModule = {
    KeyName = "ActivityCenterTabModule",
    ModuleName = "client.slua.logic.activity.ActivityCenterTabModule"
  },
  webModule = {
    KeyName = "webModule",
    ModuleName = "client.logic.url.webModule",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  web2clientModule = {
    KeyName = "web2clientModule",
    ModuleName = "client.logic.url.web2clientModule"
  },
  upgradeVehicle = {
    KeyName = "upgradeVehicle",
    ModuleName = "client.logic.vehicle.upgradeVehicle"
  },
  special_offer_module = {
    KeyName = "special_offer_module",
    ModuleName = "client.slua.logic.specialoffer.special_offer_module"
  },
  banner_module = {
    KeyName = "banner_module",
    ModuleName = "client.slua.logic.lobby.Mid.banner_module"
  },
  logic_special_offer_material = {
    KeyName = "logic_special_offer_material",
    ModuleName = "client.slua.logic.specialoffer.logic_special_offer_material",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_special_offer_condition = {
    KeyName = "logic_special_offer_condition",
    ModuleName = "client.slua.logic.specialoffer.logic_special_offer_condition",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  Discount_Direct_Logic = {
    KeyName = "Discount_Direct_Logic",
    ModuleName = "client.slua.umg.DiscountDirect.Discount_Direct_Logic",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  Logic_SmallRP = {
    KeyName = "Logic_SmallRP",
    ModuleName = "client.slua.logic.specialoffer.SmallRP.Logic_SmallRP"
  },
  Logic_SmallRPRedMgr = {
    KeyName = "Logic_SmallRPRedMgr",
    ModuleName = "client.slua.logic.specialoffer.SmallRP.Logic_SmallRPRedMgr"
  },
  Logic_RPPassPreOrder = {
    KeyName = "Logic_RPPassPreOrder",
    ModuleName = "client.slua.logic.unknow_pass.RPPassPreOrder.Logic_RPPassPreOrder"
  },
  Logic_RP_EncoreBox = {
    KeyName = "Logic_RP_EncoreBox",
    ModuleName = "client.slua.logic.unknow_pass.RPEncoreBox.Logic_RP_EncoreBox"
  },
  logic_pandora_red = {
    KeyName = "logic_pandora_red",
    ModuleName = "client.slua.logic.specialoffer.Pandora.logic_pandora_red"
  },
  logic_weapon_enter_anim = {
    KeyName = "logic_weapon_enter_anim",
    ModuleName = "client.slua.logic.avatar.module.logic_weapon_enter_anim"
  },
  logic_team_up_gap_unreasonable = {
    KeyName = "logic_team_up_gap_unreasonable",
    ModuleName = "client.slua.logic.teamup.logic_team_up_gap_unreasonable"
  },
  logic_role_info_module = {
    KeyName = "logic_role_info_module",
    ModuleName = "client.slua.logic.lobby_activity.logic_role_info_module"
  },
  logic_roleInfo_honor_title_select = {
    KeyName = "logic_roleInfo_honor_title_select",
    ModuleName = "client.slua.logic.roleInfo.logic_roleInfo_honor_title_select"
  },
  logic_roleInfo_weaponstrength_title_select = {
    KeyName = "logic_roleInfo_weaponstrength_title_select",
    ModuleName = "client.slua.logic.roleInfo.logic_roleInfo_weaponstrength_title_select"
  },
  logic_luckystar = {
    KeyName = "logic_luckystar",
    ModuleName = "client.slua.logic.lucky_star.logic_luckystar"
  },
  audio_manager = {
    KeyName = "audio_manager",
    ModuleName = "client.common.audio.audio_manager"
  },
  audio_system = {
    KeyName = "audio_system",
    ModuleName = "client.common.audio.audio_system",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_roleInfo_TeamUpFrame = {
    KeyName = "logic_roleInfo_TeamUpFrame",
    ModuleName = "client.slua.logic.roleInfo.logic_roleInfo_TeamUpFrame"
  },
  logic_roleinfo_carte_frame = {
    KeyName = "logic_roleinfo_carte_frame",
    ModuleName = "client.slua.logic.roleInfo.logic_roleinfo_carte_frame"
  },
  logic_roleInfo_nicknameframe = {
    KeyName = "logic_roleInfo_nicknameframe",
    ModuleName = "client.slua.logic.roleInfo.logic_roleInfo_nicknameframe"
  },
  logic_roleInfo_chatframe = {
    KeyName = "logic_roleInfo_chatframe",
    ModuleName = "client.slua.logic.roleInfo.logic_roleInfo_chatframe"
  },
  logic_roleInfo_background = {
    KeyName = "logic_roleInfo_background",
    ModuleName = "client.slua.logic.roleInfo.logic_roleInfo_background"
  },
  logic_roleInfo_opening = {
    KeyName = "logic_roleInfo_opening",
    ModuleName = "client.slua.logic.roleInfo.logic_roleInfo_opening"
  },
  logic_chat_tips_manager = {
    KeyName = "logic_chat_tips_manager",
    ModuleName = "client.slua.logic.lobby_chat.chat_tips.logic_chat_tips_manager"
  },
  logic_team_add_score_card = {
    KeyName = "logic_team_add_score_card",
    ModuleName = "client.logic.double_card.logic_team_add_score_card"
  },
  logic_friend_interact_record = {
    KeyName = "logic_friend_interact_record",
    ModuleName = "client.slua.logic.friend.logic_friend_interact_record"
  },
  logic_challenge_add_score_card = {
    KeyName = "logic_challenge_add_score_card",
    ModuleName = "client.logic.double_card.logic_challenge_add_score_card"
  },
  logic_season_segment_target = {
    KeyName = "logic_season_segment_target",
    ModuleName = "client.logic.season.logic_season_segment_target"
  },
  logic_couple_avatar_action = {
    KeyName = "logic_couple_avatar_action",
    ModuleName = "client.slua.logic.lobby.Left.logic_couple_avatar_action"
  },
  logic_season_lookback = {
    KeyName = "logic_season_lookback",
    ModuleName = "client.logic.season.lookback.logic_season_lookback"
  },
  logic_pre_loss = {
    KeyName = "logic_pre_loss",
    ModuleName = "client.logic.pre_loss.logic_pre_loss",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  LogicUGC = {
    KeyName = "LogicUGC",
    ModuleName = "client.slua.logic.ugc.logic_ugc",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_ugc_ai_cover_image = {
    KeyName = "logic_ugc_ai_cover_image",
    ModuleName = "client.slua.logic.ugc.logic_ugc_ai_cover_image"
  },
  logic_ugc_popup_queue = {
    KeyName = "logic_ugc_popup_queue",
    ModuleName = "client.slua.logic.ugc.logic_ugc_popup_queue",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_ugc_popupcheck = {
    KeyName = "logic_ugc_popupcheck",
    ModuleName = "client.slua.logic.ugc.logic_ugc_popupcheck"
  },
  logic_ugc_mail = {
    KeyName = "logic_ugc_mail",
    ModuleName = "client.slua.logic.ugc.mail.logic_ugc_mail"
  },
  logic_mail_frozen_tips = {
    KeyName = "logic_mail_frozen_tips",
    ModuleName = "client.slua.logic.mail.logic_mail_frozen_tips",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_ugc_season = {
    KeyName = "logic_ugc_season",
    ModuleName = "client.slua.logic.ugc.logic_ugc_season"
  },
  logic_ugc_mod_play_history = {
    KeyName = "logic_ugc_mod_play_history",
    ModuleName = "client.slua.logic.ugc.logic_ugc_mod_play_history"
  },
  logic_ugc_playlevel = {
    KeyName = "logic_ugc_playlevel",
    ModuleName = "client.slua.logic.ugc.logic_ugc_playlevel"
  },
  logic_ugc_mixed_banner = {
    KeyName = "logic_ugc_mixed_banner",
    ModuleName = "client.slua.logic.ugc.logic_ugc_mixed_banner"
  },
  logic_ugc_follow_author = {
    KeyName = "logic_ugc_follow_author",
    ModuleName = "client.slua.logic.ugc.logic_ugc_follow_author"
  },
  logic_ugc_authorhome = {
    KeyName = "logic_ugc_authorhome",
    ModuleName = "client.slua.logic.ugc.AuthorHome.logic_ugc_authorhome"
  },
  logic_ugc_loading = {
    KeyName = "logic_ugc_loading",
    ModuleName = "client.slua.logic.ugc.logic_ugc_loading",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  LogicUGCSocial = {
    KeyName = "LogicUGCSocial",
    ModuleName = "client.slua.logic.ugc.logic_ugc_social"
  },
  LogicUGCRank = {
    KeyName = "LogicUGCRank",
    ModuleName = "client.slua.logic.ugc.logic_ugc_rank"
  },
  LogicUGCRoom = {
    KeyName = "LogicUGCRoom",
    ModuleName = "client.slua.logic.ugc.logic_ugc_room"
  },
  LogicUGCMatch = {
    KeyName = "LogicUGCMatch",
    ModuleName = "client.slua.logic.ugc.logic_ugc_match",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  LogicUGCResManager = {
    KeyName = "LogicUGCResManager",
    ModuleName = "client.slua.logic.ugc.logic_ugc_res_manager"
  },
  LogicUGCModRank = {
    KeyName = "LogicUGCModRank",
    ModuleName = "client.slua.logic.ugc.logic_ugc_mod_rank"
  },
  LogicUGCCommunityManager = {
    KeyName = "LogicUGCCommunityManager",
    ModuleName = "client.slua.logic.ugc.logic_ugc_community",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  LogicUGCTrans = {
    KeyName = "LogicUGCTrans",
    ModuleName = "client.slua.logic.ugc.logic_ugc_trans"
  },
  LogicUGCExposure = {
    KeyName = "LogicUGCExposure",
    ModuleName = "client.slua.logic.ugc.logic_ugc_exposure"
  },
  LogicUGCCollectionList = {
    KeyName = "LogicUGCCollectionList",
    ModuleName = "client.slua.logic.ugc.logic_ugc_collectionlist"
  },
  LogicUGCAuthor = {
    KeyName = "LogicUGCAuthor",
    ModuleName = "client.slua.logic.ugc.logic_ugc_author"
  },
  LogicUGCCRUD = {
    KeyName = "LogicUGCCRUD",
    ModuleName = "client.slua.logic.ugc.logic_ugc_crud"
  },
  LogicUGCMulti = {
    KeyName = "LogicUGCMulti",
    ModuleName = "client.slua.logic.ugc.logic_ugc_multi",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  LogicUGCTemplate = {
    KeyName = "LogicUGCTemplate",
    ModuleName = "client.slua.logic.ugc.logic_ugc_template"
  },
  LogicUGCRandom = {
    KeyName = "LogicUGCRandom",
    ModuleName = "client.slua.logic.ugc.logic_ugc_random"
  },
  LogicUGCAuthorGuest = {
    KeyName = "LogicUGCAuthorGuest",
    ModuleName = "client.slua.logic.ugc.logic_ugc_author_guest"
  },
  LogicUgcFilterTag = {
    KeyName = "LogicUgcFilterTag",
    ModuleName = "client.slua.logic.ugc.logic_ugc_filter_tag"
  },
  LogicUGCSeasonAward = {
    KeyName = "LogicUGCSeasonAward",
    ModuleName = "client.slua.logic.ugc.logic_ugc_season_award"
  },
  logic_ugc_mode = {
    KeyName = "logic_ugc_mode",
    ModuleName = "client.slua.logic.ugc.logic_ugc_mode"
  },
  logic_ugc_random_recommend = {
    KeyName = "logic_ugc_random_recommend",
    ModuleName = "client.slua.logic.ugc.logic_ugc_random_recommend",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_ugc_tag = {
    KeyName = "logic_ugc_tag",
    ModuleName = "client.slua.logic.ugc.Logic_UGC_Tag"
  },
  logic_ugc_player_vote_tag = {
    KeyName = "logic_ugc_player_vote_tag",
    ModuleName = "client.slua.logic.ugc.logic_ugc_player_vote_tag"
  },
  logic_ugc_my_comment = {
    KeyName = "logic_ugc_my_comment",
    ModuleName = "client.slua.logic.ugc.comment.logic_ugc_my_comment"
  },
  logic_ugc_comment_switch = {
    KeyName = "logic_ugc_comment_switch",
    ModuleName = "client.slua.logic.ugc.comment.logic_ugc_comment_switch"
  },
  logic_ugc_comment_evaluate = {
    KeyName = "logic_ugc_comment_evaluate",
    ModuleName = "client.slua.logic.ugc.comment.logic_ugc_comment_evaluate"
  },
  Logic_UGC_TLog = {
    KeyName = "Logic_UGC_TLog",
    ModuleName = "client.slua.logic.ugc.logic_ugc_tlog"
  },
  logic_ugc_recommend_video = {
    KeyName = "logic_ugc_recommend_video",
    ModuleName = "client.slua.logic.ugc.logic_ugc_recommend_video"
  },
  logic_ugc_creativewow = {
    KeyName = "logic_ugc_creativewow",
    ModuleName = "client.slua.logic.ugc.logic_ugc_creativewow"
  },
  logic_creative_wow_friend = {
    KeyName = "logic_creative_wow_friend",
    ModuleName = "client.slua.logic.creative_wow.logic_creative_wow_friend",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_ugc_hot_theme = {
    KeyName = "logic_ugc_hot_theme",
    ModuleName = "client.slua.logic.ugc.hot_theme.logic_ugc_hot_theme"
  },
  logic_ugc_wowpage = {
    KeyName = "logic_ugc_wowpage",
    ModuleName = "client.slua.logic.ugc.logic_ugc_wowpage"
  },
  logic_ugc_hot_page = {
    KeyName = "logic_ugc_hot_page",
    ModuleName = "client.slua.logic.ugc.logic_ugc_hot_page"
  },
  logic_ugc_center = {
    KeyName = "logic_ugc_center",
    ModuleName = "client.slua.logic.ugc.center.logic_ugc_center",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_ugc_datacenter = {
    KeyName = "logic_ugc_datacenter",
    ModuleName = "client.slua.logic.ugc.center.logic_ugc_datacenter"
  },
  logic_ugc_personalization = {
    KeyName = "logic_ugc_personalization",
    ModuleName = "client.slua.logic.ugc.logic_ugc_personalization"
  },
  logic_ugc_task = {
    KeyName = "logic_ugc_task",
    ModuleName = "client.slua.logic.ugc.task.logic_ugc_task"
  },
  logic_ugc_uobject = {
    KeyName = "logic_ugc_uobject",
    ModuleName = "client.slua.logic.ugc.logic_ugc_uobject",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  logic_ugc_newbie_guide = {
    KeyName = "logic_ugc_newbie_guide",
    ModuleName = "client.slua.logic.ugc.newbie.logic_ugc_newbie_guide",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_ugc_share = {
    KeyName = "logic_ugc_share",
    ModuleName = "client.slua.logic.ugc.share.logic_ugc_share"
  },
  logic_ugc_copilot = {
    KeyName = "logic_ugc_copilot",
    ModuleName = "client.slua.logic.ugc.copilot.logic_ugc_copilot",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  LogicUGCAssetHub = {
    KeyName = "LogicUGCAssetHub",
    ModuleName = "client.slua.logic.ugc.AssetHub.logic_ugc_AssetHub",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_ugc_mod_sharing_challenge = {
    KeyName = "logic_ugc_mod_sharing_challenge",
    ModuleName = "client.slua.logic.ugc.logic_ugc_mod_sharing_challenge",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  LogicUGCWOWQuestionnaire = {
    KeyName = "LogicUGCWOWQuestionnaire",
    ModuleName = "client.slua.logic.ugc.logic_ugc_wow_questionnaire",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_newbie_mode_selection = {
    KeyName = "logic_newbie_mode_selection",
    ModuleName = "client.slua.logic.mode_selection.logic_newbie_mode_selection",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_affix_pictorial_book = {
    KeyName = "logic_affix_pictorial_book",
    ModuleName = "client.slua.logic.TxMission.warpre.logic_affix_pictorial_book"
  },
  logic_chat_filter_language = {
    KeyName = "logic_chat_filter_language",
    ModuleName = "client.slua.logic.lobby_chat.recruit.logic_chat_filter_language"
  },
  logic_team_platform_data = {
    KeyName = "logic_team_platform_data",
    ModuleName = "client.slua.logic.teamup.logic_team_platform_data"
  },
  logic_module_social_person_space = {
    KeyName = "logic_module_social_person_space",
    ModuleName = "client.slua.logic.lobby.Left.logic_module_social_person_space"
  },
  logic_chat_recruit_msg = {
    KeyName = "logic_chat_recruit_msg",
    ModuleName = "client.slua.logic.lobby_chat.recruit.logic_chat_recruit_msg"
  },
  affix_redpoint_data = {
    KeyName = "affix_redpoint_data",
    ModuleName = "client.slua.logic.TxMission.warpre.affix_redpoint_data"
  },
  logic_user_ctrl = {
    KeyName = "logic_user_ctrl",
    ModuleName = "client.slua.logic.user.logic_user_ctrl"
  },
  logic_rating_card_buff_mgr = {
    KeyName = "logic_rating_card_buff_mgr",
    ModuleName = "client.logic.double_card.logic_rating_card_buff_mgr"
  },
  logic_social_card_bg = {
    KeyName = "logic_social_card_bg",
    ModuleName = "client.slua.logic.lobby.Left.logic_social_card_bg"
  },
  logicRightPopupModule = {
    KeyName = "logicRightPopupModule",
    ModuleName = "client.slua.logic.lobby.logicRightPopupModule"
  },
  logic_exchange_gift = {
    KeyName = "logic_exchange_gift",
    ModuleName = "client.slua.logic.gift.logic_exchange_gift"
  },
  logic_popular_gift_pk = {
    KeyName = "logic_popular_gift_pk",
    ModuleName = "client.slua.logic.person_space.logic_popular_gift_pk",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_popular_pk_result = {
    KeyName = "logic_popular_pk_result",
    ModuleName = "client.slua.logic.person_space.logic_popular_pk_result"
  },
  logic_popular_pk_reddot = {
    KeyName = "logic_popular_pk_reddot",
    ModuleName = "client.slua.logic.person_space.logic_popular_pk_reddot"
  },
  logic_popular_pk_push = {
    KeyName = "logic_popular_pk_push",
    ModuleName = "client.slua.logic.person_space.logic_popular_pk_push"
  },
  logic_popular_pk_treasurebox = {
    KeyName = "logic_popular_pk_treasurebox",
    ModuleName = "client.slua.logic.person_space.logic_popular_pk_treasurebox"
  },
  logic_popular_pk_fun_awards = {
    KeyName = "logic_popular_pk_fun_awards",
    ModuleName = "client.slua.logic.person_space.logic_popular_pk_fun_awards"
  },
  logic_popular_tsl_pk = {
    KeyName = "logic_popular_tsl_pk",
    ModuleName = "client.slua.logic.person_space.logic_popular_tsl_pk"
  },
  logic_gift_download = {
    KeyName = "logic_gift_download",
    ModuleName = "client.slua.logic.gift.logic_gift_download"
  },
  logic_reddot_limitation = {
    KeyName = "logic_reddot_limitation",
    ModuleName = "client.slua.logic.reddot.logic_reddot_limitation",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_xmission_operation = {
    KeyName = "logic_xmission_operation",
    ModuleName = "client.slua.logic.TxMission.research.logic_xmission_operation",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_xmission_operation_make_affix = {
    KeyName = "logic_xmission_operation_make_affix",
    ModuleName = "client.slua.logic.TxMission.research.logic_xmission_operation_make_affix",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_setzone_control = {
    KeyName = "logic_setzone_control",
    ModuleName = "client.slua.logic.match.logic_setzone_control",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_assembly_activity_jk = {
    KeyName = "logic_assembly_activity_jk",
    ModuleName = "client.slua.logic.come_back.jk.logic_assembly_activity_jk"
  },
  logic_chat_channel_manager = {
    KeyName = "logic_chat_channel_manager",
    ModuleName = "client.slua.logic.lobby_chat.logic_chat_channel_manager",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_xmission_wardrobe_setting = {
    KeyName = "logic_xmission_wardrobe_setting",
    ModuleName = "client.slua.logic.TxMission.warpre.logic_xmission_wardrobe_setting"
  },
  LogicSmartAssistantCfg = {
    KeyName = "LogicSmartAssistantCfg",
    ModuleName = "client.slua.logic.sa.LogicSmartAssistantCfg"
  },
  LogicSmartAssistantToolCard = {
    KeyName = "LogicSmartAssistantToolCard",
    ModuleName = "client.slua.logic.sa.toolcard.LogicSmartAssistantToolCard"
  },
  LogicToolCardFriendApply = {
    KeyName = "LogicToolCardFriendApply",
    ModuleName = "client.slua.logic.sa.toolcard.LogicToolCardFriendApply"
  },
  LogicToolCardTokenExpired = {
    KeyName = "LogicToolCardTokenExpired",
    ModuleName = "client.slua.logic.sa.toolcard.LogicToolCardTokenExpired"
  },
  LogicToolCardNewbieLevel = {
    KeyName = "LogicToolCardNewbieLevel",
    ModuleName = "client.slua.logic.sa.toolcard.LogicToolCardNewbieLevel"
  },
  LogicToolCardMoments = {
    KeyName = "LogicToolCardMoments",
    ModuleName = "client.slua.logic.sa.toolcard.LogicToolCardMoments"
  },
  LogicToolCardSeasonSegment = {
    KeyName = "LogicToolCardSeasonSegment",
    ModuleName = "client.slua.logic.sa.toolcard.LogicToolCardSeasonSegment"
  },
  LogicToolCardSpaceGift = {
    KeyName = "LogicToolCardSpaceGift",
    ModuleName = "client.slua.logic.sa.toolcard.LogicToolCardSpaceGift"
  },
  LogicToolCardCommunity = {
    KeyName = "LogicToolCardCommunity",
    ModuleName = "client.slua.logic.sa.toolcard.LogicToolCardCommunity"
  },
  LogicToolCardReturnFirstBattle = {
    KeyName = "LogicToolCardReturnFirstBattle",
    ModuleName = "client.slua.logic.sa.toolcard.LogicToolCardReturnFirstBattle"
  },
  LogicToolCardCustomerService = {
    KeyName = "LogicToolCardCustomerService",
    ModuleName = "client.slua.logic.sa.toolcard.LogicToolCardCustomerService"
  },
  LogicToolCardDelayFreeGift = {
    KeyName = "LogicToolCardDelayFreeGift",
    ModuleName = "client.slua.logic.sa.toolcard.LogicToolCardDelayFreeGift"
  },
  LogicToolCardParkingCoinExpiry = {
    KeyName = "LogicToolCardParkingCoinExpiry",
    ModuleName = "client.slua.logic.sa.toolcard.LogicToolCardParkingCoinExpiry"
  },
  LogicMultiItemModule = {
    KeyName = "LogicMultiItemModule",
    ModuleName = "client.slua.logic.wardrobe.LogicMultiItemModule"
  },
  LogicParticleEmote = {
    KeyName = "LogicParticleEmote",
    ModuleName = "client.slua.logic.wardrobe.LogicParticleEmote"
  },
  UniqueEmoteManager = {
    KeyName = "UniqueEmoteManager",
    ModuleName = "client.logic.avatar.UniqueEmoteManager"
  },
  LobbyEmoteManager = {
    KeyName = "LobbyEmoteManager",
    ModuleName = "client.logic.avatar.LobbyEmoteManager"
  },
  VehicleCollectSystem = {
    KeyName = "VehicleCollectSystem",
    ModuleName = "client.logic.vehicle.VehicleCollectSystem"
  },
  SportCarSystem = {
    KeyName = "SportCarSystem",
    ModuleName = "client.logic.vehicle.SportCarSystem"
  },
  GlideSystem = {
    KeyName = "GlideSystem",
    ModuleName = "client.logic.glide.GlideSystem"
  },
  store_limited_subscribe_data = {
    KeyName = "store_limited_subscribe_data",
    ModuleName = "client.slua.logic.store.store_limited_subscribe_data"
  },
  logic_upass_award = {
    KeyName = "logic_upass_award",
    ModuleName = "client.slua.logic.upass.core.logic_upass_award"
  },
  supply_ban_manager = {
    KeyName = "supply_ban_manager",
    ModuleName = "client.slua.logic.supply.supply_ban_manager"
  },
  LuckyBackGuideCtrl = {
    KeyName = "LuckyBackGuideCtrl",
    ModuleName = "client.slua.umg.lobby_activity.LuckySpin.TraitClassStyle.Supply.LuckyBackGuide.LuckyBackGuideCtrl"
  },
  supply_activity_manager = {
    KeyName = "supply_activity_manager",
    ModuleName = "client.slua.logic.supply.supply_activity_manager"
  },
  supply_credit_manager = {
    KeyName = "supply_credit_manager",
    ModuleName = "client.slua.logic.supply.supply_credit_manager"
  },
  supply_luckybag_manager = {
    KeyName = "supply_luckybag_manager",
    ModuleName = "client.slua.logic.supply.supply_luckybag_manager"
  },
  store_limit_buy_manager = {
    KeyName = "store_limit_buy_manager",
    ModuleName = "client.slua.logic.store.store_limit_buy_manager"
  },
  store_reddot_manager = {
    KeyName = "store_reddot_manager",
    ModuleName = "client.slua.logic.store.store_reddot_manager"
  },
  treasure_chest_manager = {
    KeyName = "treasure_chest_manager",
    ModuleName = "client.slua.logic.store.treasure_chest_manager"
  },
  store_direct_purchase_manager = {
    KeyName = "store_direct_purchase_manager",
    ModuleName = "client.slua.logic.store.store_direct_purchase_manager"
  },
  supply_collect_chest_manager = {
    KeyName = "supply_collect_chest_manager",
    ModuleName = "client.slua.logic.supply.supply_collect_chest_manager"
  },
  supply_optional_chest_manager = {
    KeyName = "supply_optional_chest_manager",
    ModuleName = "client.slua.logic.supply.supply_optional_chest_manager"
  },
  logic_subscribe_global = {
    KeyName = "logic_subscribe_global",
    ModuleName = "client.slua.logic.subscribe.logic_subscribe_global",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_subscribe_korea = {
    KeyName = "logic_subscribe_korea",
    ModuleName = "client.slua.logic.subscribe.logic_subscribe_korea",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_subscribe_reddot_data = {
    KeyName = "logic_subscribe_reddot_data",
    ModuleName = "client.slua.logic.subscribe.red_data.logic_subscribe_reddot_data",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  store_supply_switcher = {
    KeyName = "store_supply_switcher",
    ModuleName = "client.slua.logic.new_store.store_supply_switcher",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_xmission_info = {
    KeyName = "logic_xmission_info",
    ModuleName = "client.slua.logic.TxMission.logic_xmission_info"
  },
  logic_xmission_npc_plot = {
    KeyName = "logic_xmission_npc_plot",
    ModuleName = "client.slua.logic.TxMission.plot.logic_xmission_npc_plot"
  },
  logic_xmission_guide = {
    KeyName = "logic_xmission_guide",
    ModuleName = "client.slua.logic.TxMission.guide.logic_xmission_guide"
  },
  logic_xmission_souvenirs = {
    KeyName = "logic_xmission_souvenirs",
    ModuleName = "client.slua.logic.TxMission.souvenirs.logic_xmission_souvenirs"
  },
  logic_xmission_friend_souvenirs = {
    KeyName = "logic_xmission_friend_souvenirs",
    ModuleName = "client.slua.logic.TxMission.souvenirs.logic_xmission_friend_souvenirs"
  },
  logic_xmission_bag_extend = {
    KeyName = "logic_xmission_bag_extend",
    ModuleName = "client.slua.logic.TxMission.logic_xmission_bag_extend"
  },
  logic_xmission_history_record = {
    KeyName = "logic_xmission_history_record",
    ModuleName = "client.slua.logic.TxMission.logic_xmission_history_record"
  },
  Logic_ItemGetModule = {
    KeyName = "Logic_ItemGetModule",
    ModuleName = "client.slua.logic.common.CommonItemGet.Logic_ItemGetModule"
  },
  logic_profile = {
    KeyName = "logic_profile",
    ModuleName = "client.slua.logic.user.profile.logic_profile",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_online_status = {
    KeyName = "logic_online_status",
    ModuleName = "client.slua.logic.user.profile.logic_online_status",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_super_airdrop = {
    KeyName = "logic_super_airdrop",
    ModuleName = "client.slua.logic.lobby_activity.super_airdrop.logic_super_airdrop"
  },
  logic_airdrop_entry = {
    KeyName = "logic_airdrop_entry",
    ModuleName = "client.slua.logic.lobby_activity.super_airdrop.logic_airdrop_entry"
  },
  logic_airdrop_collection = {
    KeyName = "logic_airdrop_collection",
    ModuleName = "client.slua.logic.lobby_activity.super_airdrop.logic_airdrop_collection"
  },
  LogicPeakGame = {
    KeyName = "LogicPeakGame",
    ModuleName = "client.logic.PeakGame.LogicPeakGame"
  },
  LogicPeakGameReward = {
    KeyName = "LogicPeakGameReward",
    ModuleName = "client.logic.PeakGame.LogicPeakGameReward"
  },
  LogicPeakGameHomepage = {
    KeyName = "LogicPeakGameHomepage",
    ModuleName = "client.logic.PeakGame.LogicPeakGameHomepage"
  },
  LogicPeakGameHall = {
    KeyName = "LogicPeakGameHall",
    ModuleName = "client.logic.PeakGame.LogicPeakGameHall"
  },
  LogicPeakHallResultReward = {
    KeyName = "LogicPeakHallResultReward",
    ModuleName = "client.logic.PeakGame.LogicPeakHallResultReward"
  },
  LogicPeakGameRank = {
    KeyName = "LogicPeakGameRank",
    ModuleName = "client.logic.PeakGame.LogicPeakGameRank"
  },
  LogicPeakGameSegmentType = {
    KeyName = "LogicPeakGameSegmentType",
    ModuleName = "client.logic.PeakGame.LogicPeakGameSegmentType"
  },
  LogicPeakGamePopup = {
    KeyName = "LogicPeakGamePopup",
    ModuleName = "client.logic.PeakGame.LogicPeakGamePopup",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  peakgame_reddot_util = {
    KeyName = "peakgame_reddot_util",
    ModuleName = "client.logic.season.red_point.peakgame_reddot_util"
  },
  logic_peakgame_rank = {
    KeyName = "logic_peakgame_rank",
    ModuleName = "client.logic.PeakGame.logic_peakgame_rank"
  },
  logic_peakgame_ace = {
    KeyName = "logic_peakgame_ace",
    ModuleName = "client.logic.season.ace.logic_peakgame_ace"
  },
  logic_peakgame_WonderfulPlayBack_Reddot = {
    KeyName = "logic_peakgame_WonderfulPlayBack_Reddot",
    ModuleName = "client.logic.PeakGame.logic_peakgame_WonderfulPlayBack_Reddot",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  logic_combat = {
    KeyName = "logic_combat",
    ModuleName = "client.logic.combat.logic_combat"
  },
  logic_rank_combat = {
    KeyName = "logic_rank_combat",
    ModuleName = "client.logic.combat.logic_rank_combat"
  },
  logic_peakgame_combat = {
    KeyName = "logic_peakgame_combat",
    ModuleName = "client.logic.combat.logic_peakgame_combat"
  },
  logic_match_combat = {
    KeyName = "logic_match_combat",
    ModuleName = "client.logic.combat.logic_match_combat"
  },
  logic_history_combat = {
    KeyName = "logic_history_combat",
    ModuleName = "client.logic.combat.history.logic_history_combat"
  },
  logic_best_partner = {
    KeyName = "logic_best_partner",
    ModuleName = "client.slua.logic.activity.logic_best_partner"
  },
  logic_room_circle = {
    KeyName = "logic_room_circle",
    ModuleName = "client.slua.logic.room.logic_room_circle"
  },
  logic_room_match_voice = {
    KeyName = "logic_room_match_voice",
    ModuleName = "client.slua.logic.room.logic_room_match_voice"
  },
  vehicle_collect_manager = {
    KeyName = "vehicle_collect_manager",
    ModuleName = "client.slua.logic.vehicle.vehicle_collect_manager"
  },
  KeyDesignPointSystem = {
    KeyName = "KeyDesignPointSystem",
    ModuleName = "client.slua.logic.key_design_point.KeyDesignPointSystem"
  },
  logic_lbs_select_region = {
    KeyName = "logic_lbs_select_region",
    ModuleName = "client.slua.logic.lbs.logic_lbs_select_region"
  },
  logic_lbs_warzone = {
    KeyName = "logic_lbs_warzone",
    ModuleName = "client.slua.logic.lbs.logic_lbs_warzone"
  },
  logic_worldcup_teamup_rank_activity = {
    KeyName = "logic_worldcup_teamup_rank_activity",
    ModuleName = "client.slua.logic.lobby_activity.world_cup.logic_worldcup_teamup_rank_activity"
  },
  logic_crazy_weekend_teamUp_activity = {
    KeyName = "logic_crazy_weekend_teamUp_activity",
    ModuleName = "client.slua.logic.lobby_activity.crazy_weekend.logic_crazy_weekend_teamUp_activity"
  },
  logic_crazy_weekend_luckydraw = {
    KeyName = "logic_crazy_weekend_luckydraw",
    ModuleName = "client.slua.logic.lobby_activity.crazy_weekend.logic_crazy_weekend_luckydraw"
  },
  logic_popular_team_pk = {
    KeyName = "logic_popular_team_pk",
    ModuleName = "client.slua.logic.popular_team_pk.logic_popular_team_pk"
  },
  logic_popular_team_pk_tab = {
    KeyName = "logic_popular_team_pk_tab",
    ModuleName = "client.slua.logic.popular_team_pk.logic_popular_team_pk_tab"
  },
  logic_popular_team_pk_invitefriend = {
    KeyName = "logic_popular_team_pk_invitefriend",
    ModuleName = "client.slua.logic.popular_team_pk.logic_popular_team_pk_invitefriend"
  },
  logic_light_board = {
    KeyName = "logic_light_board",
    ModuleName = "client.slua.logic.light_board.logic_light_board"
  },
  logic_popular_store = {
    KeyName = "logic_popular_store",
    ModuleName = "client.slua.logic.person_space.logic_popular_store"
  },
  logic_popular_streak = {
    KeyName = "logic_popular_streak",
    ModuleName = "client.slua.logic.person_space.logic_popular_streak"
  },
  logic_popular_home_pk = {
    KeyName = "logic_popular_home_pk",
    ModuleName = "client.slua.logic.popular_home_pk.logic_popular_home_pk"
  },
  logic_popular_home_pk_tab = {
    KeyName = "logic_popular_home_pk_tab",
    ModuleName = "client.slua.logic.popular_home_pk.logic_popular_home_pk_tab"
  },
  logic_popular_home_pk_task = {
    KeyName = "logic_popular_home_pk_task",
    ModuleName = "client.slua.logic.popular_home_pk.logic_popular_home_pk_task"
  },
  logic_popular_home_style_pk = {
    KeyName = "logic_popular_home_style_pk",
    ModuleName = "client.slua.logic.popular_home_pk.logic_popular_home_style_pk"
  },
  logic_leisure_season = {
    KeyName = "logic_leisure_season",
    ModuleName = "client.slua.logic.leisure.logic_leisure_season"
  },
  logic_promotion_homepage = {
    KeyName = "logic_promotion_homepage",
    ModuleName = "client.logic.season.promotion.logic_promotion_homepage",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  logic_social_bottom_tips = {
    KeyName = "logic_social_bottom_tips",
    ModuleName = "client.slua.logic.lobby.Left.logic_social_bottom_tips"
  },
  logic_social_popularity_tips = {
    KeyName = "logic_social_popularity_tips",
    ModuleName = "client.slua.logic.lobby.Left.logic_social_popularity_tips"
  },
  logic_memory_warning = {
    KeyName = "logic_memory_warning",
    ModuleName = "client.slua.logic.memory_warning.logic_memory_warning",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_report_replay = {
    KeyName = "logic_report_replay",
    ModuleName = "client.slua.logic.replay.logic_report_replay",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_guide_flow_config = {
    KeyName = "logic_guide_flow_config",
    ModuleName = "client.slua.logic.GuideFlow.logic_guide_flow_config"
  },
  logic_space_gift_discount_packet = {
    KeyName = "logic_space_gift_discount_packet",
    ModuleName = "client.slua.logic.person_space.logic_space_gift_discount_packet"
  },
  logic_popularity_tab_manager = {
    KeyName = "logic_popularity_tab_manager",
    ModuleName = "client.slua.logic.person_space.logic_popularity_tab_manager"
  },
  logic_setting_special_notify_switch = {
    KeyName = "logic_setting_special_notify_switch",
    ModuleName = "client.logic.setting.logic_setting_special_notify_switch"
  },
  supply_payment_report = {
    KeyName = "supply_payment_report",
    ModuleName = "client.slua.logic.supply.supply_payment.supply_payment_report"
  },
  supply_payment_manager = {
    KeyName = "supply_payment_manager",
    ModuleName = "client.slua.logic.supply.supply_payment.supply_payment_manager"
  },
  supply_payment_coupon = {
    KeyName = "supply_payment_coupon",
    ModuleName = "client.slua.logic.supply.supply_payment.supply_payment_coupon"
  },
  supply_payment_cache = {
    KeyName = "supply_payment_cache",
    ModuleName = "client.slua.logic.supply.supply_payment.supply_payment_cache"
  },
  payment_base = {
    KeyName = "payment_base",
    ModuleName = "client.slua.logic.supply.supply_payment.playment_type.payment_base"
  },
  payment_uc = {
    KeyName = "payment_uc",
    ModuleName = "client.slua.logic.supply.supply_payment.playment_type.payment_uc"
  },
  payment_token = {
    KeyName = "payment_token",
    ModuleName = "client.slua.logic.supply.supply_payment.playment_type.payment_token"
  },
  payment_other = {
    KeyName = "payment_other",
    ModuleName = "client.slua.logic.supply.supply_payment.playment_type.payment_other"
  },
  payment_free = {
    KeyName = "payment_free",
    ModuleName = "client.slua.logic.supply.supply_payment.playment_type.payment_free"
  },
  payment_exchange = {
    KeyName = "payment_exchange",
    ModuleName = "client.slua.logic.supply.supply_payment.playment_type.payment_exchange"
  },
  payment_advertisement = {
    KeyName = "payment_advertisement",
    ModuleName = "client.slua.logic.supply.supply_payment.playment_type.payment_advertisement"
  },
  payment_bp = {
    KeyName = "payment_bp",
    ModuleName = "client.slua.logic.supply.supply_payment.playment_type.payment_bp"
  },
  payment_ag = {
    KeyName = "payment_ag",
    ModuleName = "client.slua.logic.supply.supply_payment.playment_type.payment_ag"
  },
  payment_act_coin = {
    KeyName = "payment_act_coin",
    ModuleName = "client.slua.logic.supply.supply_payment.playment_type.payment_act_coin"
  },
  store_jump_manager = {
    KeyName = "store_jump_manager",
    ModuleName = "client.slua.logic.store.store_jump_manager"
  },
  store_commodity_manager = {
    KeyName = "store_commodity_manager",
    ModuleName = "client.slua.logic.store.store_commodity_manager"
  },
  store_firework_manager = {
    KeyName = "store_firework_manager",
    ModuleName = "client.slua.logic.store.store_firework_manager"
  },
  logic_ugc_comment = {
    KeyName = "logic_ugc_comment",
    ModuleName = "client.slua.logic.ugc.comment.logic_ugc_comment"
  },
  logic_ugc_comment_detail = {
    KeyName = "logic_ugc_comment_detail",
    ModuleName = "client.slua.logic.ugc.comment.logic_ugc_comment_detail"
  },
  logic_ugc_featured_comment_summary = {
    KeyName = "logic_ugc_featured_comment_summary",
    ModuleName = "client.slua.logic.ugc.comment.logic_ugc_featured_comment_summary"
  },
  logic_ugc_common_comment_summary = {
    KeyName = "logic_ugc_common_comment_summary",
    ModuleName = "client.slua.logic.ugc.comment.logic_ugc_common_comment_summary"
  },
  logic_ugc_work_detail_featured_comment = {
    KeyName = "logic_ugc_work_detail_featured_comment",
    ModuleName = "client.slua.logic.ugc.comment.logic_ugc_work_detail_featured_comment"
  },
  logic_ugc_hall_recommend_comment = {
    KeyName = "logic_ugc_hall_recommend_comment",
    ModuleName = "client.slua.logic.ugc.comment.logic_ugc_hall_recommend_comment"
  },
  logic_lobby_google_task = {
    KeyName = "logic_lobby_google_task",
    ModuleName = "client.slua.logic.task.logic_lobby_google_task"
  },
  logic_red_envelope = {
    KeyName = "logic_red_envelope",
    ModuleName = "client.slua.logic.red_envelope.logic_red_envelope",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_wedding_red_envelope = {
    KeyName = "logic_wedding_red_envelope",
    ModuleName = "client.slua.logic.red_envelope.logic_wedding_red_envelope",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  WeaponDiffColorModule = {
    KeyName = "WeaponDiffColorModule",
    ModuleName = "client.logic.ItemUpgrade.WeaponDiffColorModule",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_long_time_match = {
    KeyName = "logic_long_time_match",
    ModuleName = "client.slua.logic.match.logic_long_time_match"
  },
  logic_multi_select_match = {
    KeyName = "logic_multi_select_match",
    ModuleName = "client.slua.logic.match.logic_multi_select_match"
  },
  logic_solo_pk = {
    KeyName = "logic_solo_pk",
    ModuleName = "client.slua.logic.teamup.logic_solo_pk"
  },
  logic_lobby_system_extension = {
    KeyName = "logic_lobby_system_extension",
    ModuleName = "client.slua.logic.lobby.logic_lobby_system_extension"
  },
  logic_coupon_gold_suit = {
    KeyName = "logic_coupon_gold_suit",
    ModuleName = "client.slua.logic.coupon.logic_coupon_gold_suit"
  },
  logic_xmission_war_preset = {
    KeyName = "logic_xmission_war_preset",
    ModuleName = "client.slua.logic.TxMission.warpre.logic_xmission_war_preset"
  },
  logic_advertisement_BlueHole = {
    KeyName = "logic_advertisement_BlueHole",
    ModuleName = "client.slua.logic.advertisement.logic_advertisement_BlueHole"
  },
  logic_co_creation_base = {
    KeyName = "logic_co_creation_base",
    ModuleName = "client.slua.logic.co_creation_base.logic_co_creation_base"
  },
  SpecialOfferBubbleModule = {
    KeyName = "SpecialOfferBubbleModule",
    ModuleName = "client.slua.logic.lobby_bubble.SpecialOfferBubbleModule"
  },
  ActivityBubbleModule = {
    KeyName = "ActivityBubbleModule",
    ModuleName = "client.slua.logic.lobby_bubble.ActivityBubbleModule"
  },
  LobbyBubbleManager = {
    KeyName = "LobbyBubbleManager",
    ModuleName = "client.slua.logic.lobby_bubble.LobbyBubbleManager"
  },
  logic_lobby_toy = {
    KeyName = "logic_lobby_toy",
    ModuleName = "client.slua.logic.lobby_toy.logic_lobby_toy"
  },
  logic_lobby_paint = {
    KeyName = "logic_lobby_paint",
    ModuleName = "client.slua.logic.lobby_toy.logic_lobby_paint"
  },
  ShareSuit = {
    KeyName = "ShareSuit",
    ModuleName = "client.slua.logic.share_suit.ShareSuit"
  },
  logic_rank_ice = {
    KeyName = "logic_rank_ice",
    ModuleName = "client.slua.logic.activity.rank.logic_rank_ice"
  },
  logic_rank_collection = {
    KeyName = "logic_rank_collection",
    ModuleName = "client.slua.logic.activity.rank.logic_rank_collection"
  },
  logic_home_entry = {
    KeyName = "logic_home_entry",
    ModuleName = "client.slua.logic.home.logic_home_entry"
  },
  LogicCollectionHallEntry = {
    KeyName = "LogicCollectionHallEntry",
    ModuleName = "client.slua.logic.CollectionHall.LogicCollectionHallEntry",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  LogicCollectionHallLevelReward = {
    KeyName = "LogicCollectionHallLevelReward",
    ModuleName = "GameLua.Mod.PlanCH.Client.SubSystem.Logic.LogicCollectionHallLevelReward"
  },
  LogicCollectionHallClaimReward = {
    KeyName = "LogicCollectionHallClaimReward",
    ModuleName = "GameLua.Mod.PlanCH.Client.SubSystem.Logic.LogicCollectionHallClaimReward"
  },
  LogicCollectionHallEnterBroadcast = {
    KeyName = "LogicCollectionHallEnterBroadcast",
    ModuleName = "GameLua.Mod.PlanCH.Client.SubSystem.Logic.LogicCollectionHallEnterBroadcast"
  },
  LogicCollectionHallFriendVisit = {
    ModuleName = "GameLua.Mod.PlanCH.Client.SubSystem.Logic.LogicCollectionHallFriendVisit",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  LogicCollectionHallInvite = {
    ModuleName = "GameLua.Mod.PlanCH.Client.SubSystem.Logic.LogicCollectionHallInvite",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_home_delay_event = {
    KeyName = "logic_home_delay_event",
    ModuleName = "client.slua.logic.home.logic_home_delay_event"
  },
  logic_home_rank = {
    KeyName = "logic_home_rank",
    ModuleName = "client.slua.logic.home.Rank.logic_home_rank"
  },
  logic_home_list_view = {
    KeyName = "logic_home_list_view",
    ModuleName = "client.slua.logic.home.logic_home_list_view",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_home_door_plate = {
    KeyName = "logic_home_door_plate",
    ModuleName = "client.slua.logic.home.RoleInfo.logic_home_door_plate"
  },
  logic_home_switch = {
    KeyName = "logic_home_switch",
    ModuleName = "client.slua.logic.home.logic_home_switch"
  },
  logic_home_safety_notice = {
    KeyName = "logic_home_safety_notice",
    ModuleName = "client.slua.logic.home.safety.logic_home_safety_notice"
  },
  logic_chat_manor_topic = {
    KeyName = "logic_chat_manor_topic",
    ModuleName = "client.slua.logic.lobby_chat.manor.logic_chat_manor_topic",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_manor_draw_reward = {
    KeyName = "logic_manor_draw_reward",
    ModuleName = "client.slua.logic.home.DrawReward.logic_manor_draw_reward"
  },
  logic_home_status = {
    KeyName = "logic_home_status",
    ModuleName = "client.slua.logic.home.RoleInfo.logic_home_status"
  },
  logic_revise_home_name = {
    KeyName = "logic_revise_home_name",
    ModuleName = "client.slua.logic.home.Detail.logic_revise_home_name"
  },
  logic_home_collection_task = {
    KeyName = "logic_home_collection_task",
    ModuleName = "client.slua.logic.home.Collection.logic_home_collection_task"
  },
  logic_home_report = {
    KeyName = "logic_home_report",
    ModuleName = "client.slua.logic.home.logic_home_report"
  },
  logic_home_visit_count = {
    KeyName = "logic_home_visit_count",
    ModuleName = "client.slua.logic.home.logic_home_visit_count"
  },
  logic_home_collection_rank = {
    KeyName = "logic_home_collection_rank",
    ModuleName = "client.slua.logic.home.Collection.logic_home_collection_rank"
  },
  NewCharacterSystem = {
    KeyName = "NewCharacterSystem",
    ModuleName = "GameLua.Mod.Lobby.Base.NewCharacter.logic.NewCharacterSystem",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  NewCharacterNetSystem = {
    KeyName = "NewCharacterNetSystem",
    ModuleName = "GameLua.Mod.Lobby.Base.NewCharacter.logic.NewCharacterNetSystem",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  NewCharacterAvatarSystem = {
    KeyName = "NewCharacterAvatarSystem",
    ModuleName = "GameLua.Mod.Lobby.Base.NewCharacter.logic.NewCharacterAvatarSystem",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  CharacterBuySystem = {
    KeyName = "CharacterBuySystem",
    ModuleName = "GameLua.Mod.Lobby.Split.NewCharacter.logic.CharacterBuySystem"
  },
  logic_share_bag_guide = {
    KeyName = "logic_share_bag_guide",
    ModuleName = "client.slua.logic.share_bag.logic_share_bag_guide"
  },
  logic_team_zone_ping = {
    KeyName = "logic_team_zone_ping",
    ModuleName = "client.slua.logic.teamup.logic_team_zone_ping"
  },
  logic_activity_recharge_mgr = {
    KeyName = "logic_activity_recharge_mgr",
    ModuleName = "client.slua.logic.activity.logic_activity_recharge_mgr"
  },
  logic_wardrobe_tag_mgr = {
    KeyName = "logic_wardrobe_tag_mgr",
    ModuleName = "client.slua.logic.wardrobe.logic_wardrobe_tag_mgr"
  },
  logic_xmission_box_activity_detail = {
    KeyName = "logic_xmission_box_activity_detail",
    ModuleName = "client.slua.logic.TxMission.research.logic_xmission_box_activity_detail"
  },
  logic_suit_multi_shape = {
    KeyName = "logic_suit_multi_shape",
    ModuleName = "client.slua.logic.suit_multi_shape.logic_suit_multi_shape"
  },
  tlog_commercial_player_behavior = {
    KeyName = "tlog_commercial_player_behavior",
    ModuleName = "client.slua.config.tlog.tlog_commercial_player_behavior"
  },
  logic_lobby_souvenirs = {
    KeyName = "logic_lobby_souvenirs",
    ModuleName = "client.slua.logic.souvenirs.logic_lobby_souvenirs",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  LogicFPSAutoAdjust = {
    KeyName = "LogicFPSAutoAdjust",
    ModuleName = "client.slua.umg.NewSetting.GraphicsNew.LogicFPSAutoAdjust",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  logic_theme_system = {
    KeyName = "logic_theme_system",
    ModuleName = "client.slua.logic.theme_system.logic_theme_system"
  },
  theme_system_reddot = {
    KeyName = "theme_system_reddot",
    ModuleName = "client.slua.logic.theme_system.theme_system_reddot"
  },
  logic_theme_task = {
    KeyName = "logic_theme_task",
    ModuleName = "client.slua.logic.theme_system.logic_theme_task"
  },
  logic_singlebind = {
    KeyName = "logic_singlebind",
    ModuleName = "client.slua.logic.single_bind.logic_singlebind",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_lobby_birthday = {
    KeyName = "logic_lobby_birthday",
    ModuleName = "client.slua.logic.birthday.logic_lobby_birthday",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  LogicChatRoomTopic = {
    KeyName = "LogicChatRoomTopic",
    ModuleName = "client.slua.logic.lobby_chat.chatroom.LogicChatRoomTopic"
  },
  LogicJoinMicrophone = {
    KeyName = "LogicJoinMicrophone",
    ModuleName = "client.slua.logic.lobby_chat.chatroom.LogicJoinMicrophone"
  },
  LogicChatRoomMember = {
    KeyName = "LogicChatRoomMember",
    ModuleName = "client.slua.logic.lobby_chat.chatroom.LogicChatRoomMember"
  },
  LogicChatRoomGuide = {
    KeyName = "LogicChatRoomGuide",
    ModuleName = "client.slua.logic.lobby_chat.chatroom.LogicChatRoomGuide"
  },
  LogicChatRoomBG = {
    KeyName = "LogicChatRoomBG",
    ModuleName = "client.slua.logic.lobby_chat.chatroom.LogicChatRoomBG"
  },
  Logic_BonusPass = {
    KeyName = "Logic_BonusPass",
    ModuleName = "client.slua.logic.unknow_pass.BonusPass.Logic_BonusPass",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  Logic_Bonus_ReadFrontCfg = {
    KeyName = "Logic_Bonus_ReadFrontCfg",
    ModuleName = "client.slua.logic.unknow_pass.BonusPass.Logic_Bonus_ReadFrontCfg",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_bonuspass_level_slap = {
    KeyName = "logic_bonuspass_level_slap",
    ModuleName = "client.slua.logic.unknow_pass.logic_bonuspass_level_slap"
  },
  Logic_BonusPass_Buy = {
    KeyName = "Logic_BonusPass_Buy",
    ModuleName = "client.slua.logic.unknow_pass.BonusPass.Logic_BonusPass_Buy"
  },
  logic_share_bag_privilege_util = {
    KeyName = "logic_share_bag_privilege_util",
    ModuleName = "client.slua.logic.share_bag.logic_share_bag_privilege_util",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_unknowpass_full_level_slap = {
    KeyName = "logic_unknowpass_full_level_slap",
    ModuleName = "client.slua.logic.unknow_pass.logic_unknowpass_full_level_slap",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  LogicLastKillEffecs = {
    KeyName = "LogicLastKillEffecs",
    ModuleName = "client.logic.kill_features.LogicLastKillEffecs",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  LogicEliminationKingEffect = {
    KeyName = "LogicEliminationKingEffect",
    ModuleName = "client.logic.kill_features.LogicEliminationKingEffect",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_tarotcard_exchange_sendgift = {
    KeyName = "logic_tarotcard_exchange_sendgift",
    ModuleName = "client.slua.logic.tarot_card.logic_tarotcard_exchange_sendgift",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_corps_member_recruitment = {
    KeyName = "logic_corps_member_recruitment",
    ModuleName = "client.slua.logic.corps.logic_corps_member_recruitment"
  },
  logic_version_album = {
    KeyName = "logic_version_album",
    ModuleName = "client.slua.logic.version_album.logic_version_album"
  },
  logic_account_protect_setting = {
    KeyName = "logic_account_protect_setting",
    ModuleName = "client.slua.logic.setting.logic_account_protect_setting",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_account_sensitive_aciton = {
    KeyName = "logic_account_sensitive_aciton",
    ModuleName = "client.slua.logic.setting.logic_account_sensitive_aciton"
  },
  AccountAnchorModule = {
    KeyName = "AccountAnchorModule",
    ModuleName = "client.slua.logic.Account.AccountAnchorModule",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_vng_personal_info = {
    KeyName = "logic_vng_personal_info",
    ModuleName = "client.logic.login.logic_vng_personal_info"
  },
  FashionBagEditUtils = {
    KeyName = "FashionBagEditUtils",
    ModuleName = "client.slua.logic.wardrobe.fashionbag.FashionBagEditUtils"
  },
  logic_xmission_room = {
    KeyName = "logic_xmission_room",
    ModuleName = "client.slua.logic.TxMission.room.logic_xmission_room"
  },
  logic_xmission_room_team = {
    KeyName = "logic_xmission_room_team",
    ModuleName = "client.slua.logic.TxMission.room.logic_xmission_room_team",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  LobbyIdleUnlock = {
    KeyName = "LobbyIdleUnlock",
    ModuleName = "client.slua.logic.wardrobe.LobbyIdleUnlock",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_ugc_SendFriends = {
    KeyName = "logic_ugc_SendFriends",
    ModuleName = "client.slua.logic.ugc.logic_ugc_SendFriends"
  },
  red_point_manager = {
    KeyName = "red_point_manager",
    ModuleName = "client.slua.logic.wardrobe.redPoint.red_point_manager"
  },
  wardrobe_red_point = {
    KeyName = "wardrobe_red_point",
    ModuleName = "client.slua.logic.wardrobe.wardrobe_red_point"
  },
  LogicVehicleAccessory = {
    KeyName = "LogicVehicleAccessory",
    ModuleName = "client.logic.vehicle.LogicVehicleAccessory"
  },
  VehicleFeature = {
    KeyName = "VehicleFeature",
    ModuleName = "client.logic.vehicle.VehicleFeature"
  },
  LogicVehicleExtendedFeature = {
    KeyName = "LogicVehicleExtendedFeature",
    ModuleName = "client.logic.vehicle.LogicVehicleExtendedFeature"
  },
  logic_lobby_home_main = {
    KeyName = "logic_lobby_home_main",
    ModuleName = "client.slua.logic.home.Lobby.logic_lobby_home_main",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_ugc_search = {
    KeyName = "logic_ugc_search",
    ModuleName = "client.slua.logic.ugc.logic_ugc_search"
  },
  LobbyModeManager = {
    KeyName = "LobbyModeManager",
    ModuleName = "client.logic.lobby.LobbyModeManager"
  },
  logic_xmission_mail_notify = {
    KeyName = "logic_xmission_mail_notify",
    ModuleName = "client.slua.logic.TxMission.logic_xmission_mail_notify"
  },
  logic_poke = {
    KeyName = "logic_poke",
    ModuleName = "client.slua.logic.friend.logic_poke"
  },
  logic_interaction = {
    KeyName = "logic_interaction",
    ModuleName = "client.slua.logic.friend.logic_interaction",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_ce = {
    KeyName = "logic_ce",
    ModuleName = "client.slua.logic.ce.logic_ce",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_person_relation = {
    KeyName = "logic_person_relation",
    ModuleName = "client.logic.personspace.logic_person_relation"
  },
  logic_person_multiple = {
    KeyName = "logic_person_multiple",
    ModuleName = "client.logic.personspace.logic_person_multiple"
  },
  logic_xmission_return_teammate_equip = {
    KeyName = "logic_xmission_return_teammate_equip",
    ModuleName = "client.slua.logic.TxMission.logic_xmission_return_teammate_equip",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  LogicVehicleDecalExchange = {
    KeyName = "LogicVehicleDecalExchange",
    ModuleName = "client.slua.logic.vehicle.LogicVehicleDecalExchange"
  },
  logic_friend_intimacy = {
    KeyName = "logic_friend_intimacy",
    ModuleName = "client.slua.logic.friend.logic_friend_intimacy"
  },
  logic_home_liveTogether_crystal = {
    KeyName = "logic_home_liveTogether_crystal",
    ModuleName = "client.slua.logic.home.RoleInfo.logic_home_liveTogether_crystal"
  },
  kol_data_in = {
    KeyName = "kol_data_in",
    ModuleName = "client.slua.umg.Kol_IN.kol_data_in",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  lobby_scene_module = {
    KeyName = "lobby_scene_module",
    ModuleName = "client.slua.logic.manager.lobby_scene_module"
  },
  MixItemModule = {
    KeyName = "MixItemModule",
    ModuleName = "client.slua.logic.MixItem.Module.MixItemModule"
  },
  MixItemRedDotModule = {
    KeyName = "MixItemRedDotModule",
    ModuleName = "client.slua.logic.MixItem.Module.MixItemRedDotModule"
  },
  MixItemPlannerChatModule = {
    KeyName = "MixItemPlannerChatModule",
    ModuleName = "client.slua.logic.MixItem.Module.MixItemPlannerChatModule"
  },
  EasterEggModule = {
    KeyName = "EasterEggModule",
    ModuleName = "client.slua.logic.MixItem.EasterEgg.EasterEggModule"
  },
  MillionUCModule = {
    KeyName = "MillionUCModule",
    ModuleName = "client.slua.logic.MixItem.EasterEgg.MillionUCModule",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_xmission_team_competition = {
    KeyName = "logic_xmission_team_competition",
    ModuleName = "client.slua.logic.TxMission.logic_xmission_team_competition"
  },
  logic_xmission_talent_guide = {
    KeyName = "logic_xmission_talent_guide",
    ModuleName = "client.slua.logic.TxMission.logic_xmission_talent_guide"
  },
  Logic_LukcyOptionalTurntable = {
    KeyName = "Logic_LukcyOptionalTurntable",
    ModuleName = "client.slua.logic.lobby_activity.LukcyOptionalTurntable.Logic_LukcyOptionalTurntable"
  },
  ResearchRedDot = {
    KeyName = "ResearchRedDot",
    ModuleName = "client.slua.logic.research.ResearchRedDot"
  },
  logic_pet_privilege_guide = {
    KeyName = "logic_pet_privilege_guide",
    ModuleName = "client.slua.logic.pet.logic_pet_privilege_guide"
  },
  logic_shield = {
    KeyName = "logic_shield",
    ModuleName = "client.slua.logic.community.logic_shield"
  },
  logic_backuser_tips_mutex = {
    KeyName = "logic_backuser_tips_mutex",
    ModuleName = "client.slua.logic.tip.logic_backuser_tips_mutex"
  },
  logic_ugc_match_tab = {
    KeyName = "logic_ugc_match_tab",
    ModuleName = "client.slua.logic.ugc.match_tab.logic_ugc_match_tab"
  },
  logic_lobby_actor_voice = {
    KeyName = "logic_lobby_actor_voice",
    ModuleName = "client.slua.logic.lobby.Main.logic_lobby_actor_voice"
  },
  logic_ugc_hot_author = {
    KeyName = "logic_ugc_hot_author",
    ModuleName = "client.slua.logic.ugc.hot_author.logic_ugc_hot_author"
  },
  logic_whole_explore = {
    KeyName = "logic_whole_explore",
    ModuleName = "client.slua.logic.explore.logic_whole_explore"
  },
  Logic_Friendly = {
    KeyName = "Logic_Friendly",
    ModuleName = "client.logic.friendly.Logic_Friendly"
  },
  logic_lobby_performance = {
    KeyName = "logic_lobby_performance",
    ModuleName = "GameLua.Mod.MainCity.Client.logic.Performance.logic_lobby_performance",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_social_lobby_performance = {
    KeyName = "logic_social_lobby_performance",
    ModuleName = "GameLua.Mod.MainCity.Client.logic.Performance.logic_social_lobby_performance",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_maincity_performance = {
    KeyName = "logic_maincity_performance",
    ModuleName = "GameLua.Mod.MainCity.Client.logic.Performance.logic_maincity_performance",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_main_city_screen_scan = {
    KeyName = "logic_main_city_screen_scan",
    ModuleName = "GameLua.Mod.MainCity.Client.logic.logic_main_city_screen_scan"
  },
  logic_main_city_newbie_guide_manager = {
    KeyName = "logic_main_city_newbie_guide_manager",
    ModuleName = "GameLua.Mod.MainCity.Client.logic.NewbieGuide.logic_main_city_newbie_guide_manager",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_main_city_newbie_guide_entry = {
    KeyName = "logic_main_city_newbie_guide_entry",
    ModuleName = "GameLua.Mod.MainCity.Client.logic.NewbieGuide.logic_main_city_newbie_guide_entry"
  },
  logic_main_city_newbie_guide_sequence = {
    KeyName = "logic_main_city_newbie_guide_sequence",
    ModuleName = "GameLua.Mod.MainCity.Client.logic.NewbieGuide.logic_main_city_newbie_guide_sequence"
  },
  logic_main_city_newbie_guide_popup = {
    KeyName = "logic_main_city_newbie_guide_popup",
    ModuleName = "GameLua.Mod.MainCity.Client.logic.NewbieGuide.logic_main_city_newbie_guide_popup"
  },
  logic_main_city_newbie_guide_explore = {
    KeyName = "logic_main_city_newbie_guide_explore",
    ModuleName = "GameLua.Mod.MainCity.Client.logic.NewbieGuide.logic_main_city_newbie_guide_explore"
  },
  logic_main_city_newbie_guide_setting = {
    KeyName = "logic_main_city_newbie_guide_setting",
    ModuleName = "GameLua.Mod.MainCity.Client.logic.NewbieGuide.logic_main_city_newbie_guide_setting"
  },
  logic_main_city_scroll = {
    KeyName = "logic_main_city_scroll",
    ModuleName = "GameLua.Mod.MainCity.Client.logic.Screen.logic_main_city_scroll"
  },
  logic_main_city_commercialization = {
    KeyName = "logic_main_city_commercialization",
    ModuleName = "GameLua.Mod.MainCity.Client.logic.Commercialization.logic_main_city_commercialization"
  },
  logic_main_city_player = {
    KeyName = "logic_main_city_player",
    ModuleName = "GameLua.Mod.MainCity.Client.logic.Player.logic_main_city_player"
  },
  logic_main_city_enter = {
    KeyName = "logic_main_city_enter",
    ModuleName = "GameLua.Mod.MainCity.Client.logic.Process.Enter.logic_main_city_enter",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_main_city_switch = {
    KeyName = "logic_main_city_switch",
    ModuleName = "GameLua.Mod.MainCity.Client.logic.Process.Transfer.logic_main_city_switch"
  },
  logic_main_city_follow = {
    KeyName = "logic_main_city_follow",
    ModuleName = "GameLua.Mod.MainCity.Client.logic.Process.Follow.logic_main_city_follow"
  },
  logic_main_city_connect_state = {
    KeyName = "logic_main_city_connect_state",
    ModuleName = "GameLua.Mod.MainCity.Client.logic.Process.Connect.logic_main_city_connect_state",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_main_city_reconnect = {
    KeyName = "logic_main_city_reconnect",
    ModuleName = "GameLua.Mod.MainCity.Client.logic.Process.Reconnect.logic_main_city_reconnect",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_main_city_heart = {
    KeyName = "logic_main_city_heart",
    ModuleName = "GameLua.Mod.MainCity.Client.logic.Process.Heart.logic_main_city_heart",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_main_city_bubble = {
    KeyName = "logic_main_city_bubble",
    ModuleName = "GameLua.Mod.MainCity.Client.logic.Bubble.logic_main_city_bubble"
  },
  logic_main_city_immersion = {
    KeyName = "logic_main_city_immersion",
    ModuleName = "GameLua.Mod.MainCity.Client.logic.logic_main_city_immersion"
  },
  logic_main_city_explore = {
    KeyName = "logic_main_city_explore",
    ModuleName = "GameLua.Mod.MainCity.Client.logic.logic_main_city_explore"
  },
  logic_main_city_privacy = {
    KeyName = "logic_main_city_privacy",
    ModuleName = "GameLua.Mod.MainCity.Client.logic.logic_main_city_privacy"
  },
  logic_main_city_voice = {
    KeyName = "logic_main_city_voice",
    ModuleName = "GameLua.Mod.MainCity.Client.logic.Chat.logic_main_city_voice"
  },
  logic_main_city_chat = {
    KeyName = "logic_main_city_chat",
    ModuleName = "GameLua.Mod.MainCity.Client.logic.Chat.logic_main_city_chat"
  },
  logic_main_city_long_term_bubble = {
    KeyName = "logic_main_city_long_term_bubble",
    ModuleName = "GameLua.Mod.MainCity.Client.logic.Chat.logic_main_city_long_term_bubble"
  },
  logic_main_city_status = {
    KeyName = "logic_main_city_status",
    ModuleName = "GameLua.Mod.MainCity.Client.logic.logic_main_city_status"
  },
  logic_maincity_minilobby_team_tips = {
    KeyName = "logic_maincity_minilobby_team_tips",
    ModuleName = "GameLua.Mod.MainCity.Client.logic.MiniLobby.logic_maincity_minilobby_team_tips"
  },
  logic_custom_presentation = {
    KeyName = "logic_custom_presentation",
    ModuleName = "client.slua.logic.person_space.logic_custom_presentation"
  },
  logic_main_city_music = {
    KeyName = "logic_main_city_music",
    ModuleName = "GameLua.Mod.MainCity.Client.logic.logic_main_city_music"
  },
  logic_main_city_camera_manager = {
    KeyName = "logic_main_city_camera_manager",
    ModuleName = "GameLua.Mod.MainCity.Client.logic.Camera.logic_main_city_camera_manager"
  },
  logic_main_city_action_tLog = {
    KeyName = "logic_main_city_action_tLog",
    ModuleName = "GameLua.Mod.MainCity.Client.logic.logic_main_city_action_tLog"
  },
  logic_main_city_download = {
    KeyName = "logic_main_city_download",
    ModuleName = "GameLua.Mod.MainCity.Client.logic.Download.logic_maincity_download",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_main_city_reddot = {
    KeyName = "logic_main_city_reddot",
    ModuleName = "GameLua.Mod.MainCity.Client.logic.logic_main_city_reddot"
  },
  logic_main_city_game_record = {
    KeyName = "logic_main_city_game_record",
    ModuleName = "GameLua.Mod.MainCity.Client.logic.GameRecord.logic_main_city_game_record"
  },
  logic_main_city_newbie_guide_fold = {
    KeyName = "logic_main_city_newbie_guide_fold",
    ModuleName = "GameLua.Mod.MainCity.Client.logic.NewbieGuide.logic_main_city_newbie_guide_fold"
  },
  logic_main_city_penguin_interact = {
    KeyName = "logic_main_city_penguin_interact",
    ModuleName = "GameLua.Mod.MainCity.Client.logic.Penguin.logic_main_city_penguin_interact"
  },
  logic_ugc_inventory = {
    KeyName = "logic_ugc_inventory",
    ModuleName = "client.slua.logic.ugc.logic_ugc_inventory"
  },
  logic_ugc_wallet = {
    KeyName = "logic_ugc_wallet",
    ModuleName = "client.slua.logic.ugc.center.logic_ugc_wallet"
  },
  UGCNewTLogReport = {
    KeyName = "UGCNewTLogReport",
    ModuleName = "client.slua.logic.ugc.UGCNewTLogReport"
  },
  logic_ugc_season_template = {
    KeyName = "logic_ugc_season_template",
    ModuleName = "client.slua.logic.ugc.SeasonTemplate.logic_ugc_season_template"
  },
  logic_ugc_theme_play_activity_template = {
    KeyName = "logic_ugc_theme_play_activity_template",
    ModuleName = "client.slua.logic.ugc.ThemePlayActivityTemplate.logic_ugc_theme_play_activity_template"
  },
  UGCPlayHallRoom = {
    KeyName = "UGCPlayHallRoom",
    ModuleName = "client.slua.logic.ugc.UGCPlayHallRoom"
  },
  logic_ugc_featured_comment = {
    KeyName = "logic_ugc_featured_comment",
    ModuleName = "client.slua.logic.ugc.comment.logic_ugc_featured_comment"
  },
  logic_ugc_active_motivation = {
    KeyName = "logic_ugc_active_motivation",
    ModuleName = "client.slua.logic.ugc.center.logic_ugc_active_motivation"
  },
  logic_wardrobe_wow_vehicle = {
    KeyName = "logic_wardrobe_wow_vehicle",
    ModuleName = "client.slua.logic.wardrobe.logic_wardrobe_wow_vehicle"
  },
  music_manager = {
    KeyName = "music_manager",
    ModuleName = "client.slua.logic.pubgm_music.music_manager"
  },
  LuckyAirDropModule = {
    KeyName = "LuckyAirDropModule",
    ModuleName = "client.slua.logic.luck_airdrop.LuckyAirDropModule"
  },
  logic_package_send_control = {
    KeyName = "logic_package_send_control",
    ModuleName = "client.slua.logic.wardrobe.logic_package_send_control"
  },
  logic_ai_take_over = {
    KeyName = "logic_ai_take_over",
    ModuleName = "client.slua.logic.teamup.logic_ai_take_over"
  },
  LobbyModelPossess = {
    KeyName = "LobbyModelPossess",
    ModuleName = "client.slua.logic.avatar.module.LobbyModelPossess"
  },
  logic_ugc_WOWPass = {
    KeyName = "logic_ugc_WOWPass",
    ModuleName = "client.slua.logic.ugc.logic_ugc_WOWPass"
  },
  logic_ugc_reward_incentives = {
    KeyName = "logic_ugc_reward_incentives",
    ModuleName = "client.slua.logic.ugc.center.logic_ugc_reward_incentives"
  },
  LogicVehicleResDependencyUtil = {
    KeyName = "LogicVehicleResDependencyUtil",
    ModuleName = "client.logic.vehicle.LogicVehicleResDependencyUtil"
  },
  logic_xmission_buff = {
    KeyName = "logic_xmission_buff",
    ModuleName = "client.slua.logic.TxMission.logic_xmission_buff"
  },
  logic_ugc_new_map = {
    KeyName = "logic_ugc_new_map",
    ModuleName = "client.slua.logic.ugc.logic_ugc_new_map"
  },
  logic_weapon_strength_rank = {
    KeyName = "logic_weapon_strength_rank",
    ModuleName = "client.slua.logic.weapon_strength.logic_weapon_strength_rank"
  },
  logic_weapon_strength = {
    KeyName = "logic_weapon_strength",
    ModuleName = "client.slua.logic.weapon_strength.logic_weapon_strength"
  },
  logic_weapon_strength_weekly_award = {
    KeyName = "logic_weapon_strength_weekly_award",
    ModuleName = "client.slua.logic.weapon_strength.logic_weapon_strength_weekly_award"
  },
  logic_newbie_task_segment_activity = {
    KeyName = "logic_newbie_task_segment_activity",
    ModuleName = "client.slua.logic.activity.newbie.logic_newbie_task_segment_activity"
  },
  logic_newbie_new_abtest = {
    KeyName = "logic_newbie_new_abtest",
    ModuleName = "client.logic.newbie.logic_newbie_new_abtest"
  },
  logic_player_return_login = {
    KeyName = "logic_player_return_login",
    ModuleName = "client.slua.logic.player_return.logic_player_return_login"
  },
  logic_hyperlink_common_jump = {
    KeyName = "logic_hyperlink_common_jump",
    ModuleName = "client.slua.logic.Hyperlink.logic_hyperlink_common_jump"
  },
  logic_comeback_task = {
    KeyName = "logic_comeback_task",
    ModuleName = "client.slua.logic.task.Task_Integration.logic_comeback_task"
  },
  logic_apple_gamecenter_achievement = {
    KeyName = "logic_apple_gamecenter_achievement",
    ModuleName = "client.slua.logic.achievement.logic_apple_gamecenter_achievement",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  logic_gamelet_interface_update_nonage = {
    KeyName = "logic_gamelet_interface_update_nonage",
    ModuleName = "client.slua.logic.gamelet.logic_gamelet_interface_update_nonage"
  },
  logic_main_city_newbie_activity_guide = {
    KeyName = "logic_main_city_newbie_activity_guide",
    ModuleName = "GameLua.Mod.MainCity.Client.logic.NewbieGuide.logic_main_city_newbie_activity_guide"
  },
  logic_main_city_newbie_guide_first_match = {
    KeyName = "logic_main_city_newbie_guide_first_match",
    ModuleName = "GameLua.Mod.MainCity.Client.logic.NewbieGuide.logic_main_city_newbie_guide_first_match"
  },
  logic_ugc_ForumBubble = {
    KeyName = "logic_ugc_ForumBubble",
    ModuleName = "client.slua.logic.ugc.logic_ugc_ForumBubble"
  },
  logic_return_rb_guide_popup = {
    KeyName = "logic_return_rb_guide_popup",
    ModuleName = "client.slua.logic.return_activity.logic_return_rb_guide_popup"
  },
  logic_mentor_new = {
    KeyName = "logic_mentor_new",
    ModuleName = "client.slua.logic.mentor.logic_mentor_new"
  },
  logic_wedding = {
    KeyName = "logic_wedding",
    ModuleName = "client.slua.logic.home.Wedding.logic_wedding"
  },
  logic_wedding_activity = {
    KeyName = "logic_wedding_activity",
    ModuleName = "client.slua.logic.home.Wedding.logic_wedding_activity"
  },
  logic_wedding_friend_search = {
    KeyName = "logic_wedding_friend_search",
    ModuleName = "client.slua.logic.home.Wedding.logic_wedding_friend_search"
  },
  logic_season_year_rank_task = {
    KeyName = "logic_season_year_rank_task",
    ModuleName = "client.logic.season_year.logic_season_year_rank_task"
  },
  logic_national_esports = {
    KeyName = "logic_national_esports",
    ModuleName = "client.slua.logic.esport.logic_national_esports"
  },
  logic_season_year_trial_mission = {
    KeyName = "logic_season_year_trial_mission",
    ModuleName = "client.logic.season_year.logic_season_year_trial_mission"
  },
  fission_data = {
    KeyName = "fission_data",
    ModuleName = "client.slua.umg.NewUserFission.Data.fission_data"
  },
  logic_season_year_badge = {
    KeyName = "logic_season_year_badge",
    ModuleName = "client.logic.season_year.logic_season_year_badge"
  },
  logic_ugc_mine = {
    KeyName = "logic_ugc_mine",
    ModuleName = "client.slua.logic.ugc.logic_ugc_mine"
  },
  logic_ugc_album_theme = {
    KeyName = "logic_ugc_album_theme",
    ModuleName = "client.slua.logic.ugc.AlbumTheme.logic_ugc_album_theme",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_card_collection_season = {
    KeyName = "logic_card_collection_season",
    ModuleName = "client.slua.logic.card_collection_season.logic_card_collection_season"
  },
  card_collection_reddot_data = {
    KeyName = "card_collection_reddot_data",
    ModuleName = "client.slua.logic.card_collection_season.card_collection_reddot_data"
  },
  mail_notify_popup = {
    KeyName = "mail_notify_popup",
    ModuleName = "client.slua.logic.mail.mail_notify_popup"
  },
  logic_mini_tv_team_util = {
    KeyName = "logic_mini_tv_team_util",
    ModuleName = "client.slua.logic.mini_tv.logic_mini_tv_team_util"
  },
  logic_mini_tv_util = {
    KeyName = "logic_mini_tv_util",
    ModuleName = "client.slua.logic.mini_tv.logic_mini_tv_util",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  DelayNoticesModule = {
    KeyName = "DelayNoticesModule",
    ModuleName = "client.logic.Notice.DelayNoticesModule"
  },
  logic_newbie_guide_force_rank = {
    KeyName = "logic_newbie_guide_force_rank",
    ModuleName = "client.slua.logic.newbie_guide.logic_newbie_guide_force_rank"
  },
  logic_ugc_crystal_incentive = {
    KeyName = "logic_ugc_crystal_incentive",
    ModuleName = "client.slua.logic.ugc.center.logic_ugc_crystal_incentive",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_brcard_collection = {
    KeyName = "logic_brcard_collection",
    ModuleName = "client.slua.logic.BRCard.logic_brcard_collection"
  },
  logic_brcard_ladder = {
    KeyName = "logic_brcard_ladder",
    ModuleName = "client.slua.logic.BRCard.logic_brcard_ladder"
  },
  logic_brcard_free_hero = {
    KeyName = "logic_brcard_free_hero",
    ModuleName = "client.slua.logic.BRCard.logic_brcard_free_hero"
  },
  logic_group_buying = {
    KeyName = "logic_group_buying",
    ModuleName = "client.slua.logic.new_group_buy.logic_group_buying",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_group_buying_invite = {
    KeyName = "logic_group_buying_invite",
    ModuleName = "client.slua.logic.new_group_buy.logic_group_buying_invite",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_assembly_system = {
    KeyName = "logic_assembly_system",
    ModuleName = "client.slua.logic.come_back.logic_assembly_system"
  },
  logic_psSkill_sprint = {
    KeyName = "logic_psSkill_sprint",
    ModuleName = "client.slua.logic.psSkill_sprint.logic_psSkill_sprint",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  Logic_UGC_Mine = {
    KeyName = "Logic_UGC_Mine",
    ModuleName = "client.slua.logic.ugc.Mine.logic_ugc_mine"
  },
  logic_ugc_intention = {
    KeyName = "logic_ugc_intention",
    ModuleName = "client.slua.logic.ugc.logic_ugc_intention"
  },
  UGCDetailBulletComments = {
    KeyName = "UGCDetailBulletComments",
    ModuleName = "client.slua.umg.ugc.lobby.detail.UGCDetailBulletComments"
  },
  SmartAssistantActivityModule = {
    KeyName = "SmartAssistantActivityModule",
    ModuleName = "client.slua.logic.activity.SmartAssistant.SmartAssistantActivityModule",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_rank_reddot = {
    KeyName = "logic_rank_reddot",
    ModuleName = "client.slua.logic.rank.logic_rank_reddot"
  },
  logic_google_play_achievement = {
    KeyName = "logic_google_play_achievement",
    ModuleName = "client.slua.logic.achievement.logic_google_play_achievement",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel
  },
  logic_card_collect_wardrobe_show = {
    KeyName = "logic_card_collect_wardrobe_show",
    ModuleName = "client.slua.logic.wardrobe.logic_card_collect_wardrobe_show"
  },
  logic_newbie_opt_system = {
    KeyName = "logic_newbie_opt_system",
    ModuleName = "client.slua.logic.activity.newbie_opt.logic_newbie_opt_system"
  },
  logic_whatsApp_subscription = {
    KeyName = "logic_whatsApp_subscription",
    ModuleName = "client.logic.countryarea.logic_whatsApp_subscription",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_roleInfo_HonourCertificate = {
    KeyName = "logic_roleInfo_HonourCertificate",
    ModuleName = "client.slua.logic.roleInfo.logic_roleInfo_HonourCertificate"
  },
  logic_season_switch_slap = {
    KeyName = "logic_season_switch_slap",
    ModuleName = "client.slua.umg.season.logic_season_switch_slap",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_teamquick_res = {
    KeyName = "logic_teamquick_res",
    ModuleName = "client.slua.logic.TeamQuick.logic_teamquick_res"
  },
  logic_teamquick_join = {
    KeyName = "logic_teamquick_join",
    ModuleName = "client.slua.logic.TeamQuick.logic_teamquick_join",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  LogicToolCardSvipPersonalCustomerService = {
    KeyName = "LogicToolCardSvipPersonalCustomerService",
    ModuleName = "client.slua.logic.sa.toolcard.LogicToolCardSvipPersonalCustomerService"
  },
  UGC_Hall_Bullet_Comments = {
    KeyName = "UGC_Hall_Bullet_Comments",
    ModuleName = "client.slua.umg.ugc.Hall.UGC_Hall_Bullet_Comments"
  },
  logic_ugc_hall = {
    KeyName = "logic_ugc_hall",
    ModuleName = "client.slua.logic.ugc.logic_ugc_hall"
  },
  logic_lobby_main_page_jump = {
    KeyName = "logic_lobby_main_page_jump",
    ModuleName = "client.slua.logic.lobby.Main.logic_lobby_main_page_jump"
  },
  logic_legend_weapon = {
    KeyName = "logic_legend_weapon",
    ModuleName = "client.slua.logic.wardrobe.logic_legend_weapon"
  },
  logic_ugc_hall_mod = {
    KeyName = "logic_ugc_hall_mod",
    ModuleName = "client.slua.logic.ugc.Hall.logic_ugc_hall_mod"
  },
  logic_ugc_new_process = {
    KeyName = "logic_ugc_new_process",
    ModuleName = "client.slua.logic.ugc.newbie.NewProcess.logic_ugc_new_process",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  LogicFusionModule = {
    KeyName = "LogicFusionModule",
    ModuleName = "client.slua.logic.wardrobe.LogicFusionModule"
  },
  logic_teamquick_guide = {
    KeyName = "logic_teamquick_guide",
    ModuleName = "client.slua.logic.TeamQuick.logic_teamquick_guide"
  },
  logic_teamquick_entry = {
    KeyName = "logic_teamquick_entry",
    ModuleName = "client.slua.logic.TeamQuick.logic_teamquick_entry",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel
  },
  logic_lobby_common_download = {
    KeyName = "logic_lobby_common_download",
    ModuleName = "client.slua.logic.lobby.Download.logic_lobby_common_download"
  }
}
return ModuleConfig