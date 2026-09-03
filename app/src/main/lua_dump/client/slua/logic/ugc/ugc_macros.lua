local UGCMacros = {
  ENUM_AUTHOR_STATE = {
    None = 0,
    Verified = 1,
    Verifying = 2
  },
  ENUM_MODE_TYPE = {
    Pub = "bin_pub_mod_list",
    History = "bin_history_play_list",
    Collect = "bin_collections",
    Recommend = "bin_recommend",
    GuestMod = "bin_other_online_mod_list",
    OtherHistory = "bin_other_history_play_list",
    OtherCollect = "bin_other_collections",
    Room = "bin_ugc_room_info",
    UgcMatch = "bin_ugc_match",
    FirstMod = "bin_first_mod",
    Share = "bin_ugc_mod_share",
    UgcChatRoom = "bin_ugc_chat_room",
    Download = "bin_download_list",
    Random = "bin_random_reg",
    Follow = "bin_follow_list",
    Comment = "bin_ugc_comment",
    MomentSummaryComment = "bin_moment_summary_comment",
    MomentDetailComment = "bin_moment_detail_comment",
    HotTheme = "bin_hot_theme",
    ResultRecommend = "bin_result_recommend",
    MixedBanner = "bin_mixed_banner",
    Collections = "bin_pub_mod_collections",
    Season = "bin_season_mod",
    SearchWorks = "bin_combined_search",
    Link = "bin_ugc_link",
    WonderSeason = "bin_season_filter",
    Brand_Map = "bin_brand_map",
    SeasonAchievement = "bin_season_records",
    RankTypeDefault = "bin_personal_rec",
    RecommendSetting = "bin_recommend_setting",
    RecommendSearchWork = "bin_recommend_setting_search",
    TeamConscribe = "bin_team_conscribe",
    creation_center_data = "bin_creation_center_data",
    hot_theme_ext = "bin_hot_theme_ext",
    Match_tab = "bin_match_tab",
    hot_top_author = "bin_top_author",
    ModeSelectionCustom = "bin_swipe_mod",
    team_invite_tip = "bin_team_invite_tip",
    pub_mod_wallet = "bin_pub_mod_wallet",
    play_hall = "bin_play_hall",
    events_template = "bin_events_template",
    new_mod_incubation = "bin_new_mod_incubation",
    new_mod_validation = "bin_new_mod_validation",
    Incentive_Rank = "bin_IPR_rank",
    FirendStatus = "bin_friend_status",
    PlayHallFilter = "bin_play_hall_filter",
    AppreciationGroup = "bin_review_panel",
    Solo = "bin_solo",
    template_mod = "bin_template_mod",
    MineStatus = "bin_mine_status",
    crystal_income = "bin_crystal_income",
    bin_manor_show_mod = "bin_manor_show_mod",
    PlayHistory = "bin_play_history",
    wow_newbie_guide = "bin_wow_newbie_guide",
    wow_play_activity = "bin_wow_play_activity"
  },
  ENUM_MOD_STATE = {
    EMSR_EDIT = 101,
    EMSR_VERIFY = 201,
    EMSR_ONLINE = 401,
    EMSR_OFFLINE = 501,
    EMSR_VERIFY_HUMAN = 601,
    EMSR_NEED_MODIFY = 602,
    EMSR_FORBID = 603,
    EMSR_TEMPLATE = 801
  },
  ENUM_SKIP_CLEAR = {bin_ugc_match = true, bin_mixed_banner = true},
  ENUM_RE_REQ = {
    bin_pub_mod_list = true,
    bin_ugc_room_info = true,
    bin_ugc_match = true,
    bin_ugc_mod_share = true
  },
  ENUM_UGC_TEMPLATE_ID = {NEWBIE_ISLAND = 10},
  ENU_UGC_TLOG_REACH_TYPE = {
    CLICK = 1,
    SELECT = 2,
    COLLECT = 3,
    START_GAME = 4,
    RESULT_COLLECT = 5,
    SHOW_MOD = 6,
    SHOW_BANNER_THEMA = 7,
    Download = 8
  },
  TLOL_REACH_CD = 2,
  TLOG_COLLECTION_REACH_CD = 300,
  ENU_UGC_TLOG_COLLECTIONS_TYPE = {SHOW = 2, CLICK = 1},
  ENU_UGC_TAG_ERROR_TYPE = {
    MUSTSET = 1,
    SINGE_LIMIT = 2,
    ALL_LIMIT = 3
  },
  EDIT_SUB_MODE = 600074,
  UGC_WOW_SUB_MODE = 600091,
  UGC_SUB_GAME_MODE_ID_LIST = {
    600092,
    600093,
    600094
  },
  ENU_UGC_TLOG_StayTime_TYPE = {
    UGCWow = 1,
    UGCCenterData_Overview = 2,
    UGCCenterData_Mod = 3,
    UGCCenterData_Fans = 4
  },
  Enum_FansFollowSource = {
    DetailAndResult = 1,
    PersonData = 2,
    WOWSearch = 3,
    Other = 4
  },
  Enum_UGC_CommentClick_Type = {
    Commentlike = 1,
    CommentDislike = 2,
    CommentWindow = 3,
    CommentVoteItem = 4,
    CommentSort = 5
  },
  Enum_UGC_CommercialClick_Type = {
    Mission = 1,
    Room = 2,
    Club = 3,
    CreationSquare = 4,
    CWOW = 5,
    Setting = 6,
    UGCWarehouse = 18,
    Personal = 7,
    Share = 8,
    UGCCenter = 9,
    UGCCenter_Store = 10,
    Pass = 11,
    UGCCenter_Purse = 12,
    UGCCenter_Level = 13,
    Personal_PlayData = 14,
    Personal_Follow = 15,
    Personal_LevelTips = 16,
    CreatorForum = 17,
    CuratorTeam = 18
  },
  Enum_UGC_AuthorHomeClick_Type = {
    MainPage = 1,
    ModPange = 2,
    HonorPage = 3,
    EditSignature = 4,
    ThumbsUp = 5,
    CreaterLevelRank = 6,
    ChangeSkin = 7,
    EditTag = 8,
    HonorAll = 9,
    HonorCreate = 10,
    HonorSeason = 11,
    EditModWall = 12,
    EditHonorWall = 13
  },
  ENUM_EventElementID = {Skibidi_Toilet = 1},
  ENUM_DownloaderType = {
    ModCopy = 1,
    MyWork = 2,
    Template = 3,
    ModList = 4
  },
  GAME_NEED_MIN_STORAGE = 100,
  ENUM_Mail_Report = {Show = 1, Click = 2},
  ENUM_MinePanel_Report = {Show = 1, Click = 2},
  ENUM_UgcCetter_Linechart_Tab_Report = {TrackingPoint = 1, Subsistence = 2},
  ENUM_UGC_ThemePlay_FaceSlap_UIShow = {
    Close = 1,
    JumpActive = 2,
    Play = 3
  }
}
local CheckMetaType = function(Src, Dst)
  if not Src then
    return false
  end
  if not Dst then
    return true
  end
  return Src == Dst
end
UGCMacros.return UGCMacros