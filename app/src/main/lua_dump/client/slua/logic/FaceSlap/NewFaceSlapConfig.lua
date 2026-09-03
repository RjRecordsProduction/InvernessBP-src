local NewFaceSlapConfig = {}
local _InitSlapList = function()
  local KeyPlayVideoSystem = require("client.slua.logic.lobby_activity.logic_keyplayvideo")
  local logic_player_return_slap = require("client.slua.logic.player_return.logic_player_return_slap")
  local pandora_slap_system = require("client.slua.logic.Pandora.pandora_slap_system")
  local bulletinManager = require("client.slua.umg.activity.bulletin_board.bulletin_manager")
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local SignInSystem = require("client.slua.logic.activity.logic_sign_in")
  local everyDayUCSystem = require("client.logic.everyday_pack.logic_everyday_uc")
  local EveryDayPackSystem = require("client.logic.everyday_pack.logic_everydaypack")
  local AntiaddctionSystem = require("client.logic.antiaddction.logic_antiaddction")
  local ActivityRebate = require("client.logic.activity.logic_activity_rebate")
  local SeasonSystem = require("client.logic.season.logic_season")
  local EightDaySystem = require("client.slua.logic.activity.newbie.logic_newbie_eight_day")
  local LiveVideoSystem = require("client.slua.logic.live_video.logic_live_video")
  local NoticesUtil = require("client.logic.Notice.NoticesUtil")
  local logic_security = require("client.slua.logic.security.logic_security")
  local logic_prechurn_loginreward = require("client.slua.logic.activity.logic_prechurn_loginreward")
  local subscribeSlapSystem = require("client.slua.umg.subscribe.Subscribe_Slap_System")
  local logic_fairgame_popup = require("client.slua.logic.fairgame.logic_fairgame_popup")
  local RoleInfoAliasSystem = require("client.slua.logic.roleInfo.logic_roleinfo_title")
  local MatchSystem = require("client.slua.logic.match.logic_match")
  local QuickQuestionSystem = require("client.slua.logic.activity.logic_quick_question")
  local logic_version_update_slap = require("client.slua.logic.version_update_slap.logic_version_update_slap")
  local logic_enhanced_lobby_quality_slap = require("client.slua.logic.setting.logic_enhanced_lobby_quality_slap")
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local main_city_process_util = require("GameLua.Mod.MainCity.Client.logic.Process.main_city_process_util")
  local GraphicHelperUtil = require("client.slua.umg.NewSetting.GraphicsNew.GraphicHelperUtil")
  local LogicPufferBundle = require("client.slua.logic.download.bundle.logic_puffer_bundle")
  local logic_newbie_reward_eight_day = require("client.slua.logic.activity.newbie.logic_newbie_reward_eight_day")
  local logic_reputation_system = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_reputation_system)
  local logic_lobby_souvenirs = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lobby_souvenirs)
  local logic_lobby_birthday = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lobby_birthday)
  local logic_account_protect_setting = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_account_protect_setting)
  local LogicUGCAuthor = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthor)
  local logic_return_activity = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_activity)
  NewFaceSlapConfig = {
    [BP_ENUM_MODULE_VERSION_UPDATE_SLAP] = logic_version_update_slap.CheckCanSlap,
    [BP_ENUM_MODULE_ACCOUNT_RISK_SLAP] = logic_account_protect_setting.IsCanShowRiskSlap,
    [BP_ENUM_MODULE_BIRTHDAY_SLAP] = logic_lobby_birthday.CanShowSlapFace,
    [BP_ENUM_MODULE_KEY_PLAY_VIDEO] = KeyPlayVideoSystem.NeedPlay,
    [BP_ENUM_MODULE_DOWNLOAD_VOICE_BANK] = PufferDownloader.ShouldSlapDownloadVoice,
    [BP_ENUM_MODULE_SEASON_KING] = SeasonSystem.ShouldKing,
    [BP_ENUM_MODULE_RETURN_REWARD_SLAP] = logic_player_return_slap.CanShowNewReturnAward,
    [BP_ENUM_MODULE_RETURN_RECHARGE_REBATE_SLAP] = logic_return_activity.CheckShowReturnGiftUI,
    [BP_ENUM_MODULE_RETURN_GUIDE_SLAP] = logic_return_activity.CheckShowReturnGuide,
    [BP_ENUM_MODULE_RETURN_NEW] = logic_player_return_slap.CanShowNewReturnUI,
    [BP_ENUM_MODULE_RETURN_BANNER_SLAP] = logic_player_return_slap.CanShowNewBannerUI,
    [BP_ENUM_MODULE_RETURN_FB_SLAP] = logic_player_return_slap.CanShowFBUI,
    [BP_ENUM_MODULE_RETURN_SIGN_SLAP] = logic_player_return_slap.CanShowSignRewardUI,
    [BP_ENUM_MODULE_RETURN_FB_GUIDE_SLAP] = logic_player_return_slap.CanShowFBGuideUI,
    [BP_ENUM_MODULE_RETURN_MODE_SELECT_SLAP] = logic_player_return_slap.CanShowModeSelectUI,
    [BP_ENUM_SWITCH_NEW_SETTING_GRAPHICS] = GraphicHelperUtil.CanShowNewSettingPopup,
    [BP_ENUM_MODULE_UGC_BECOME_AUTHOR] = LogicUGCAuthor.CheckShowBecomeAuthorSlap,
    [BP_EMUM_MODULE_MAIN_CITY_DOWNLOAD_THEME] = main_city_process_util.CanShowMainCityDownloadTheme,
    [BP_EMUM_MODULE_FIT_VERSION_RECOMMEND_POPUP] = LogicPufferBundle.CanShowFitRecommendPopup,
    [BP_ENUM_MODULE_ANTIADDCTION] = AntiaddctionSystem.ShouldSlap,
    [BP_ENUM_MODULE_FAIRGAME_AGREEMENT] = logic_fairgame_popup.ShouldShowFairGameAgreement,
    [BP_ENUM_MODULE_FAIRGAME_REPORT] = logic_security.ShouldShowReportSucceedFace,
    [BP_ENUM_MODULE_SEASON_SWITCH] = function()
      local logic_season_switch_slap = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_switch_slap)
      return logic_season_switch_slap:CheckShouldSlapOnEnterLobby()
    end,
    [BP_EMUM_MODULE_BILLBOARD_SLAP] = bulletinManager.ShouldSlap,
    [BP_ENUM_MODULE_EIGHT_DAY] = EightDaySystem.ShouldSlap,
    [BP_ENUM_MODULE_PRECHURN_LOGINREWARD] = logic_prechurn_loginreward.ShouldSlap,
    [BP_ENUM_MODULE_ACTIVITY_SIGN_IN] = SignInSystem.ShouldSlapSignIn,
    [BP_ENUM_MODULE_ACTIVITY_REBATE] = ActivityRebate.ShouldSlap,
    [BP_ENUM_MODULE_EVERYDAY_PACK_UC] = everyDayUCSystem.ShouldSlap,
    [BP_ENUM_MODULE_SUBSCRIBE_SLAP] = subscribeSlapSystem.ShouldSlap,
    [BP_ENUM_MODULE_SEASON_REMIND] = SeasonSystem.ShouldRemind,
    [BP_ENUM_MODULE_ESPORT_LIVE_VIDEO] = LiveVideoSystem.ShouldSlap,
    [BP_ENUM_MODULE_NOTICE] = NoticesUtil.HasGlobalNotices,
    [BP_ENUM_MODULE_TXMISSION_NOTICE] = NoticesUtil.HasTxMissionNotices,
    [BP_ENUM_MODULE_PANDORA] = pandora_slap_system.ShouldSlap,
    [BP_ENUM_MODULE_ACTIVITY_SLAP] = ActivityNewSystem.CanShowActivityCenterFace,
    [BP_ENUM_MODULE_ZONE_NOTICE] = DataMgr.ShouldSlapZoneNotice,
    [BP_ENUM_MODULE_FAIRGAME_NOTICE] = logic_fairgame_popup.ShouldShowFairGameNotice,
    [BP_ENUM_MODULE_GET_ALIAS_POPUP] = RoleInfoAliasSystem.ShouldSlap,
    [BP_ENUM_MODULE_MATCH_BAN_TIP] = MatchSystem.ShouldSlapBanTip,
    [BP_ENUM_MODULE_QUICK_QUEATION] = QuickQuestionSystem.IsFaceShow,
    [BP_ENUM_MODULE_CREDIT_NOTICE] = logic_reputation_system.ShouldShowReputationNotice,
    [BP_ENUM_MODULE_LOBBY_SOUVENIRS_SLAP] = logic_lobby_souvenirs.IsCanShowSouvenirsSlap,
    [BP_ENUM_MODULE_INTIMACY_LEVEL_UP_SLAP] = LogicFriend.IsShowIntimacyLevelUpSlap,
    [BP_ENUM_MODULE_430_NEWBIE_GUIDE] = LogicNewbie.IsCanShow430LobbyGuide,
    [BP_ENUM_MODULE_HOSTED_GAMELET_FACE_SLAP] = NoticesUtil.HasGameletNotices,
    [BP_ENUM_MODULE_ENHANCED_LOBBY_QUALITY] = logic_enhanced_lobby_quality_slap.ShouldShowEnhancedLobbyQualitySlap,
    [BP_ENUM_MODULE_NEWBIE_REWARD_EIGHT_DAY] = logic_newbie_reward_eight_day.IsShowNewbieRewardEightDaySlap,
    [BP_ENUM_MODULE_CRAZY_WEEKEND_GUILD] = function()
      local logic_crazy_weekend_teamUp_activity = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_crazy_weekend_teamUp_activity)
      return logic_crazy_weekend_teamUp_activity:CheckCanOpenGuildUI()
    end,
    [BP_ENUM_MODULE_WHATSAPP_SUBSCRIPTION_SLAP] = function()
      local logic_whatsApp_subscription = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_whatsApp_subscription)
      return logic_whatsApp_subscription:CheckCanShowSlap()
    end
  }
end
_InitSlapList()
return NewFaceSlapConfig