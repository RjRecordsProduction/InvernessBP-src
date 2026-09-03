local Logic_DataMgrConst = require("client.logic.data.Logic_DataMgrConst")
local struct_RoleAttri = Logic_DataMgrConst.Enum_Attribute
local StringUtil = require("common.string_util")
struct_SegmentType = {
  segment_type_solo = "solo",
  segment_type_double = "duo",
  segment_type_team = "squad",
  segment_type_fppsolo = "fppsolo",
  segment_type_fppdouble = "fppduo",
  segment_type_fppteam = "fppsquad"
}
enum_SegmentType = {
  solo = 1,
  double = 2,
  team = 3,
  fpp_solo = 4,
  fpp_double = 5,
  fpp_team = 6
}
local enum_ModeType = {
  solo = 1,
  duo = 2,
  squad = 3,
  fppsolo = 4,
  fppduo = 5,
  fppsquad = 6
}
local SubType2PutOnField = {
  [ENUM_ITEM_SUBTYPE.WakeFlame] = "run_trail",
  [ENUM_ITEM_SUBTYPE.Footprints] = "foot_print",
  [ENUM_ITEM_SUBTYPE.ClickEffect] = "click_effect"
}
local canShowSManager
DataMgr_PlayerType = {
  Normal = 1,
  WoW = 2,
  Theme = 3,
  Metro = 4
}
DataMgr = {
  roleData = {
    openID = 0,
    uid = "",
    level = 0,
    nation = "",
    roleExp = 0,
    nickName = "",
    gender = 0,
    headIconUrl = "",
    signature = "",
    segment = {},
    bgbg_vip = 0,
    cur_avatar_box_id = 0,
    allzoneSegment = {},
    eugdpr = {},
    history_max_segment_level = 0,
    credit = 0,
    enableWatch = 1,
    watch_privacy = 1,
    upvote = 0,
    charisma = 0,
    rankData = {},
    upass = {},
    alias = {},
    corps_alias_data = {},
    carteamId = 0,
    nameFrameData = {},
    role_setting = {},
    voice_feedback = {},
    segment_rating = {},
    ios_acc_del_ts = 0,
    aos_acc_del_ts = 0,
    fcm_switch_data = {},
    fcm_switch_cfg = {},
    image_quality_open_flag = true,
    item_upgrade_switch_info = {},
    weapon_audio_volume_info = {}
  },
  gold = 0,
  ticket = 0,
  fp_token = 0,
  gen_ticket = 0,
  gold_chip = 0,
  smelt = 0,
  anchor = 0,
  anchor_origin = 0,
  item_store = {},
  modify_name_time = 0,
  last_modify_nation_time = 0,
  last_modify_nation_item_time = 0,
  registertime = 0,
  avatarData = {
    headid = 0,
    hairid = 0,
    beardid = 0,
    beardcolorid = 0,
    gamegender = 0,
    avatar_list = {_isLeaf = true},
    activate_avatar_list = {_isLeaf = true},
    attr_info = {_isLeaf = true}
  },
  defaultParachuteResID = 0,
  defaultParachuteInsID = 0,
  parachute = "",
  defaultPlaneSkinResID = 1801101,
  defaultPlaneSkinInsID = 0,
  defaultWingmanSkinResID = 181101000,
  defaultWingmanSkinInsID = 0,
  head_show = 0,
  equipmentSkinInsIDTable = {
    [504] = 0,
    [505] = 0,
    [506] = 0
  },
  BagSkinTableIndex = 504,
  HelmetSkinTableIndex = 505,
  defaultVehicleSkinResIDTable = {
    [901] = 1901001,
    [902] = 1902001,
    [903] = 1903001,
    [904] = 1904001,
    [905] = 1905001,
    [906] = 1906001,
    [907] = 1907001,
    [908] = 1908001,
    [909] = 1909001,
    [910] = 1910001,
    [911] = 1911001,
    [912] = 1912001,
    [913] = 1913001,
    [914] = 1914001,
    [915] = 1915001,
    [916] = 1916001,
    [917] = 1917001,
    [918] = 1918001,
    [919] = 1919001,
    [920] = 1920001,
    [930] = 1930001,
    [953] = 1953001,
    [960] = 1960001,
    [961] = 1961001,
    [963] = 1963001,
    [966] = 1966001,
    [967] = 1967001
  },
  defaultVehicleSkinInsIDTable = {
    [1901001] = 0,
    [1902001] = 0,
    [1903001] = 0,
    [1904001] = 0,
    [1905001] = 0,
    [1906001] = 0,
    [1907001] = 0,
    [1908001] = 0,
    [1909001] = 0,
    [1910001] = 0,
    [1911001] = 0,
    [1912001] = 0,
    [1913001] = 0,
    [1914001] = 0,
    [1915001] = 0,
    [1916001] = 0,
    [1917001] = 0,
    [1918001] = 0,
    [1966001] = 0
  },
  vehicleSkinInsIDTable = {},
  SignInInfo = {
    login_reward = {},
    last_login_reward_remind = 0
  },
  fresher_type = 0,
  taskData = {
    daily_update_time = 0,
    list = {}
  },
  activeness = {
    daily_update_time = 0,
    value = 0,
    list = {},
    week_update_time = 0,
    week_value = 0,
    week_list = {},
    WeekActIndexMark = 100
  },
  levelTask = {
    list = {}
  },
  ban = {},
  WeekSignUpInfo = {
    Resign_times = 0,
    AwardState = {},
    UCAwardState = {},
    weeklyUc = 0,
    is_black_friday = 0,
    page_link = ""
  },
  activity = {
    isInit = false,
    hashList = {},
    activityMap = {},
    activityListMap = {},
    activityIdMap = {},
    data = {}
  },
  bulletin = {
    hashList = {},
    data = {}
  },
  ShareAwardInfo = {
    daily_share_time = 0,
    share_times = 0,
    AwardState = {}
  },
  activityGroupList = {},
  doubleCard = {
    expCardRatePlus = 0,
    expCardExpireTime = 0,
    goldCardRatePlus = 0,
    goldCardExpireTime = 0
  },
  lbs_warzone_info = {
    warzone_id = -1,
    warzone_id_update_time = 0,
    use_title = {},
    title_map = {},
    title_update_time_map = {},
    rank_times_map = {}
  },
  corpsInfo = {
    create_time = 0,
    energyType = 0,
    last_season_active_type = nil,
    setup_active_type_time = nil,
    isInit = false,
    commanderId = 0,
    secCommanderList = {},
    eliteList = {},
    memberList = {},
    selfMember = {},
    id = 0,
    exp = 0,
    level = 0,
    weekRank = 1,
    announcement = "",
    notice = "",
    change_notice_uid = 0,
    change_notice_time = 0,
    name = "",
    icon = 0,
    icon_text = "",
    icon_text_colour = 0,
    city = "",
    memberNum = 0,
    leader = 0,
    day_active = 0,
    week_active = 0,
    season_active = 0,
    day_exp = 0,
    week_exp = 0,
    chest_star = 0,
    fund = 0,
    isAcceptApply = true,
    isNeedApproval = true,
    joinLevel = 0,
    joinSegment = 0,
    corps_labels_info = {},
    agent_leader = {},
    corpsMemberList = {}
  },
  corpsTaskData = {
    list = {}
  },
  corpsActiveness = {
    value = 0,
    star = 0,
    list = {}
  },
  maxSegmentSolo = {zoneid = 0, SegmentLevel = 0},
  maxSegmentDuo = {zoneid = 0, SegmentLevel = 0},
  maxSegmentSquad = {zoneid = 0, SegmentLevel = 0},
  maxSegmentSoloFpp = {zoneid = 0, SegmentLevel = 0},
  maxSegmentDuoFpp = {zoneid = 0, SegmentLevel = 0},
  maxSegmentSquadFpp = {zoneid = 0, SegmentLevel = 0},
  maxSegment = {
    zoneid = 0,
    SegmentLevel = 0,
    segmentType = enum_SegmentType.solo
  },
  IsEightDaySlpaed = false,
  CurUpdateZoneSegementZoneId = 0,
  jp_age = nil,
  minor_cert_status = nil,
  MotionSlotMax = 0,
  MotionSlotList = {},
  RejoinTaskData = {
    is_open = false,
    is_back_user = false,
    rejoin_start_time = 0,
    last_login_time = 0,
    total_login_day = 1,
    task_special = {},
    task_regular = {},
    taskActiveness = {
      value = 0,
      list = {}
    },
    activeness = 0,
    last_refresh_time = 0,
    rejoin_num = 0,
    chest_award_list = {},
    convert = false
  },
  Last_ZoneId = 0,
  Last_Combat_ShootType = 0,
  Last_CombatModelType = 0,
  team_up_has_weak_guide = false,
  newbieGuide = {},
  NEWBIE_GUIDE_MODULE_ID_WARZONE = 1,
  NEWBIE_GUIDE_MODULE_ID_CHAT = 2,
  NEWBIE_GUIDE_MODULE_ID_WARDROBE = 3,
  NEWBIE_GUIDE_MODULE_ID_TITLE = 4,
  NEWBIE_GUIDE_MODULE_ID_PASS = 5,
  NEWBIE_GUIDE_MODULE_WEEK_SIGN = 6,
  NEWBIE_GUIDE_MODULE_ID_SHAOJI = 8,
  NEWBIE_GUIDE_MODULE_ID_MATCH_LANG = 9,
  NEWBIE_GUIDE_MODULE_ID_BIGHAND = 10,
  NEWBIE_GUIDE_MODULE_ID_SINGLETRAIN = 11,
  NEWBIE_GUIDE_MODULE_ID_BLACK_FRIDAY = 21,
  NEWBIE_GUIDE_MODULE_ID_ITEM_UPGRADE = 22,
  NEWBIE_GUIDE_MODULE_ID_NEW_STORE = 23,
  NEWBIE_GUIDE_MODULE_ID_ACTIVITY_SHOP = 24,
  NEWBIE_GUIDE_MODULE_ID_RESIDENT_EVIL = 25,
  NEWBIE_GUIDE_MODULE_ID_LUCKYUNBACK = 26,
  NEWBIE_GUIDE_MODULE_ID_INDIA_CHAMPIONSHIP = 28,
  NEWBIE_GUIDE_MODULE_ID_DISCOUNT_FEVER = 29,
  NEWBIE_GUIDE_MODULE_ID_INTIMACY_RELATION = 30,
  NEWBIE_GUIDE_MODULE_ID_PSPACE_GIFT = 31,
  NEWBIE_GUIDE_MODULE_ID_LOBBY_REARRANGE = 33,
  NEWBIE_GUIDE_MODULE_ID_TASK = 34,
  NEWBIE_GUIDE_MODULE_ID_MODELSELECT = 35,
  NEWBIE_GUIDE_MODULE_ID_VEHICIE_MAIN = 37,
  NEWBIE_GUIDE_MODULE_ID_SOCIAL_LOBBY = 38,
  NEWBIE_GUIDE_MODULE_ID_SOCIAL_ISLAND = 60,
  NEWBIE_GUIDE_MODULE_ID_CORPS = 61,
  NEWBIE_GUIDE_MODULE_ID_SOCIALLAND_LUCKMATE = 62,
  NEWBIE_GUIDE_MODULE_ID_DIY = 70,
  NEWBIE_GUIDE_MODULE_ID_BIG_EVENT = 71,
  NEWBIE_GUIDE_MODULE_ID_XMISSION_TALENT = 72,
  NEWBIE_GUIDE_MODULE_ID_XMISSION_STORE = 73,
  NEWBIE_GUIDE_MODULE_ID_XMISSION_CULTIVATE = 74,
  NEWBIE_GUIDE_MODULE_ID_BATTLE_REPORT = 75,
  NEWBIE_GUIDE_MODULE_ID_NEW_FRIENDSTATUS = 76,
  NEWBIE_GUIDE_MODULE_ID_WORLD_CUP_MY_TEAM = 77,
  NEWBIE_GUIDE_MODULE_ID_MODE_SELECTION = 78,
  NEWBIE_GUIDE_MODULE_ID_BAG_EXTEND = 79,
  NEWBIE_GUIDE_MODULE_ID_XMISSION_CAMMANDPOST_LEVELEXTEND = 80,
  NEWBIE_GUIDE_MODULE_ID_HOME_GUIDEBOOK_REDDOT = 81,
  NEWBIE_GUIDE_MODULE_ID_BAN = 105,
  NEWBIE_GUIDE_MODULE_ID_LIBYA = 118,
  NEWBIE_GUIDE_MODULE_ID_RP_BRANCH = 120,
  NEWBIE_GUIDE_MODULE_ID_MUSIC_PLAYER = 121,
  NEWBIE_GUIDE_MODULE_ID_CORPS_LEREPLACEEV = 122,
  NEWBIE_GUIDE_MODULE_ID_RIGHT_MODE = 123,
  NEWBIE_GUIDE_MODULE_ID_CHAT_FIRE = 124,
  NEWBIE_GUIDE_MODULE_ID_MATCH_ENTRY_GUIDE = 125,
  NEWBIE_GUIDE_MODULE_ID_DEATH_RECOMMEND_GUIDE = 126,
  NEWBIE_GUIDE_MODULE_ID_NEWBIE_MODE_REDDOT = 127,
  NEWBIE_GUIDE_HOME_CRYSTAL_TAB_EMOTION = 128,
  NEWBIE_GUIDE_VERSIONALBUM_CARD_TAB = 129,
  NEWBIE_GUIDE_MODULE_ID_MAINCITY = 130,
  NEWBIE_GUIDE_MODULE_ID_CORPS_NEWVERSION = 131,
  NEWBIE_GUIDE_MODULE_ID_CRAZYWEEKEND_LOTTERYDRAW = 132,
  NEWBIE_GUIDE_MODULE_ID_RECOMMENDED_CONFIG = 133,
  NEWBIE_GUIDE_MODULE_ID_HISTORY_NEWBIE = 134,
  NEWBIE_GUIDE_ACE_IMPRINT = 135,
  NEWBIE_GUIDE_MODULE_HEIRLOOM = 136,
  NEWBIE_GUIDE_MODULE_HOME_PROMOTION_ACTIVITY = 137,
  NEWBIE_GUIDE_MODULE_LOBBY_430_NEW = 138,
  NEWBIE_GUIDE_MODULE_WARDROBE_XSUIT = 139,
  NEWBIE_GUIDE_MODULE_ID_ROLE_INFO = 141,
  carteam_coin_count = 0,
  sub_mode = 0,
  FirstSecondLanguage = {},
  MatchLanguage = {},
  season_id = 1,
  character_ids = {},
  RegionData = {
    region = "",
    setTime = 0,
    setCount = 0,
    setRegionList = {}
  },
  NewerTotalGameCnt = 0,
  NewerHaveShowEightDay = false,
  VGameAppID = "",
  last_30days_recharge_amount = 0,
  last_recharge_amount = 0,
  friends_most_recharge_amount = 0,
  last_pay_time = 0,
  save_sum = 0
}
local local SinkPerspectiveType = {sink_segment_type_tpp = "tpp", sink_segment_type_fpp = "fpp"}
local E_SinkModeDataType = {SinkDataTPP = 1, SinkDataFPP = 2}
function DataMgr.OnLogin()
  local roleData = LobbySystem.roleData
  DataMgr.InitMotionInfo(roleData.motion_info, roleData.motion_limit)
  DataMgr.InitVehicleInfo(roleData.vst_in_battle, roleData.vst_skin)
end
function DataMgr.ResetData()
  if not DataMgrInit then
    return
  end
  local CorpsMgr = require("client.slua.logic.corps.corps_mgr")
  log(bWriteLog and "IDataMgr.ResetData!!!!")
  DataMgr.ResetLevelTaskData()
  DataMgr.ResetBulletin()
  CorpsMgr.ResetData()
  DataMgr.avatarData.avatar_list = {}
  DataMgr.avatarData.activate_avatar_list = {}
  DataMgr.tournament_id = nil
  DataMgr.ResetRegion()
end
function DataMgr.InitRoleData(roleDataTb)
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  log(bWriteLog and "InitRoleData openID:" .. tostring(roleDataTb.openID) .. " uid:" .. tostring(roleDataTb.uid))
  log(bWriteLog and "InitRoleData nickName:" .. tostring(roleDataTb.nickName) .. " level:" .. tostring(roleDataTb.level) .. " roleExp:" .. tostring(roleDataTb.roleExp) .. " gender:" .. tostring(roleDataTb.gender))
  log(bWriteLog and "InitRoleData gold:" .. tostring(roleDataTb.gold))
  if roleDataTb.ticket ~= nil then
    log(bWriteLog and "InitRoleData ticket:" .. roleDataTb.ticket)
  end
  log(bWriteLog and "InitRoleData modify_name_time:" .. tostring(roleDataTb.modify_name_time))
  log(bWriteLog and "InitRoleData last_modify_nation_time:" .. tostring(roleDataTb.last_modify_nation_time))
  log(bWriteLog and "InitRoleData last_modify_nation_item_time:" .. tostring(roleDataTb.last_modify_nation_item_time))
  log(bWriteLog and "InitRoleData registertime:" .. tostring(roleDataTb.registertime))
  log(bWriteLog and "InitRoleData signature:" .. roleDataTb.signature)
  log_tree("InitRoleData avatar:", roleDataTb.avatar)
  log_tree("InitRoleData avatar_feature_list:", roleDataTb.avatar_feature_list)
  log_tree("InitRoleData activate_avatar_list:", roleDataTb.activate_avatar_list)
  log(bWriteLog and "InitRoleData parachute:" .. roleDataTb.parachute)
  log(bWriteLog and "InitRoleData planeSkin:" .. tostring(roleDataTb.planeSkinInsID))
  log(bWriteLog and "InitRoleData wingmanSkin:" .. tostring(roleDataTb.wingmanSkinInsID))
  log(bWriteLog and "InitRoleData bagSkin:" .. tostring(roleDataTb.bagSkinInsID))
  log(bWriteLog and "InitRoleData helmetSkin:" .. tostring(roleDataTb.helmetSkinInsID))
  log(bWriteLog and "InitRoleData headShow:" .. roleDataTb.head_show)
  log_tree("InitRoleData vehicleSkinInsIDTable:", roleDataTb.vehicleSkinInsIDTable)
  log(bWriteLog and "InitRoleData last_login_reward_remind:" .. roleDataTb.last_login_reward_remind)
  log(bWriteLog and "InitRoleData fresher_type:" .. roleDataTb.fresher_type)
  log(bWriteLog and "InitRoleData anchor:" .. roleDataTb.anchor)
  log(bWriteLog and "InitRoleData anchor_origin:" .. tostring(roleDataTb.anchor_origin))
  log(bWriteLog and "InitRoleData bgbg_vip:" .. tostring(roleDataTb.bgbg_vip))
  log(bWriteLog and "InitRoleData xy_red_point:" .. tostring(roleDataTb.xy_red_point))
  log(bWriteLog and "InitRoleData corps_money:" .. tostring(roleDataTb.corps_money))
  log(bWriteLog and "InitRoleData pve_exp:" .. tostring(roleDataTb.pve_exp) .. ",pve_level:" .. tostring(roleDataTb.pve_level))
  log(bWriteLog and "InitRoleData signature:" .. tostring(roleDataTb.signature))
  log(bWriteLog and "InitRoleData big_event_newbie_guide:" .. tostring(roleDataTb.big_event_newbie_guide))
  log(bWriteLog and "InitRoleData old_last_login_time:" .. tostring(roleDataTb.old_last_login_time))
  log_tree("InitRoleData car_plate_info", roleDataTb.car_plate_info)
  log_tree("[ljw] roleDataTb.mil_info", roleDataTb.mil_info)
  log_tree("InitRoleData.convience_mode_settings = ", roleDataTb.convience_mode_settings)
  DataMgr.ResetData()
  local LobbyWaterMarkSystem = require("client.slua.logic.lobby_watermark.logic_lobby_watermark")
  LobbyWaterMarkSystem.SetOpenID(roleDataTb.openID)
  local roleData = DataMgr.roleData
  roleData.openID = roleDataTb.openID
  roleData.uid = roleDataTb.uid
  roleData.nickName = roleDataTb.nickName
  roleData.nation = roleDataTb.nation
  roleData.level = roleDataTb.level
  roleData.roleExp = roleDataTb.roleExp
  roleData.gender = roleDataTb.avatar.gamegender
  roleData.signature = roleDataTb.signature
  roleData.eugdpr = roleDataTb.eugdpr
  roleData.newbie_points = roleDataTb.newbie_points or 0
  roleData.convience_mode_settings = roleDataTb.convience_mode_settings
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  growthprojectMgrB.InitPlayerMarkLabel(roleDataTb.growup_mark_labels)
  roleData.headIconUrl = roleDataTb.headIconUrl
  log(bWriteLog and "DataMgr.InitRoleData, headIconUrl = " .. roleDataTb.headIconUrl)
  if string.find(roleData.headIconUrl, "twimg") ~= nil then
    roleData.headIconUrl = string.gsub(roleData.headIconUrl, "_normal", "_bigger")
    log(bWriteLog and "DataMgr.InitRoleData, twitter headIconUrl = " .. roleData.headIconUrl)
  end
  local RoleInfoAvatarFrameSystem = require("client.slua.logic.roleInfo.logic_RoleInfoAvatarFrame")
  RoleInfoAvatarFrameSystem.UpdateCurAvatarBoxID(roleDataTb.cur_avatar_box_id)
  roleData.bgbg_vip = GetSafeNumber(roleDataTb.bgbg_vip)
  roleData.xy_red_point = roleDataTb.xy_red_point
  roleData.credit = roleDataTb.credit
  roleData.pve_exp = roleDataTb.pve_exp
  roleData.pve_level = roleDataTb.pve_level
  roleData.enableWatch = roleDataTb.enableWatch
  roleData.watch_privacy = roleDataTb.watch_privacy
  roleData.enable_watch_remind = roleDataTb.enable_watch_remind
  roleData.receive_nonfriend_team_request = roleDataTb.receive_nonfriend_team_request
  roleData.isEmulator = Client.IsEmulator()
  roleData.alias = roleDataTb.alias
  log_tree("InitRoleData CkeckAliasInfo alias", roleDataTb.alias)
  roleData.corps_alias_data = roleDataTb.corps_alias_data
  roleData.carteamId = roleDataTb.carteam_id or 0
  roleData.character_ids = roleDataTb.character_ids
  roleData.season_switch_display = roleDataTb.season_switch_display
  roleData.idip_area_id = roleDataTb.idip_area_id
  roleData.big_event_newbie_guide = roleDataTb.big_event_newbie_guide
  roleData.game_flag = roleDataTb.game_flag
  roleData.old_last_login_time = roleDataTb.old_last_login_time
  roleData.mil_info = roleDataTb.mil_info
  roleData.fcm_switch_data = roleDataTb.fcm_switch_data
  roleData.fcm_switch_cfg = roleDataTb.fcm_switch_cfg
  roleData.ios_acc_del_ts = roleDataTb.ios_acc_del_ts or 0
  roleData.aos_acc_del_ts = roleDataTb.aos_acc_del_ts or 0
  roleData.performance_switch = roleDataTb.performance_switch or 1
  roleData.item_upgrade_switch_info = roleDataTb.item_upgrade_switch_info
  roleData.weapon_audio_volume_info = roleDataTb.weapon_audio_volume_info
  roleData.gun_upgrade_parts_switch = roleDataTb.gun_upgrade_parts_switch
  roleData.kol_leaderboard = roleDataTb.kol_leaderboard, Client.SetPlayerBaseInfo(GameFrontendHUD, roleDataTb.openID, roleDataTb.uid, roleDataTb.nickName, roleDataTb.headIconUrl)
  local LuckAirDropSystem = require("client.slua.logic.luck_airdrop.logic_luck_air_drop")
  if roleDataTb.luck_airdrop ~= nil then
    LuckAirDropSystem.CachedLuckAirData(roleDataTb.luck_airdrop)
  else
    LuckAirDropSystem.ClearData()
  end
  roleData.arena_season_id = roleDataTb.arena_season_id
  roleData.arena_rating_and_segment = roleDataTb.arena_rating_and_segment
  roleData.sink_segment = roleDataTb.sink_segment
  roleData.sink_segment_rating = roleDataTb.sink_segment_rating
  roleData.allzoneSegment = roleDataTb.segment
  roleData.allzoneSegmentTitle = roleDataTb.segmentTitleData
  roleData.segment_protect_shield_info = roleDataTb.segment_protect_shield_info
  log_tree("InitRoleData segment_info:", roleDataTb.segment)
  SegmentZoneCount = roleData.allzoneSegment and #roleData.allzoneSegment or 0
  if 0 < SegmentZoneCount then
    for k, v in pairs(roleData.allzoneSegment) do
      DataMgr.SetCurSegment(k)
      break
    end
  end
  DataMgr.UpdateTaskChange(false, roleDataTb.task)
  if roleDataTb.levelTask ~= nil then
    DataMgr.UpdateLevelTaskChange(false, roleDataTb.levelTask)
  else
    log(bWriteLog and "xzx9 DataMgr.InitRoleData failed")
  end
  DataMgr.gold = roleDataTb.gold or 0
  DataMgr.ticket = roleDataTb.ticket or 0
  DataMgr.diamond = roleDataTb.diamond or 0
  DataMgr.fp_token = roleDataTb.fp_token or 0
  DataMgr.gen_ticket = roleDataTb.gen_ticket
  DataMgr.corps_money = roleDataTb.corps_money or 0
  DataMgr.gold_chip = roleDataTb.gold_chip or 0
  DataMgr.battle_coin = roleDataTb.battle_coin or 0
  DataMgr.eternal_diamond = roleDataTb.eternal_diamond or 0
  DataMgr.wow_creation_score = roleDataTb.wow_creation_score or 0
  DataMgr.smelt = roleDataTb.smelt or 0
  DataMgr.item_store = roleDataTb.item_store or {}
  DataMgr.ugc_advanced_crystal = roleDataTb.ugc_advanced_crystal or 0
  DataMgr.wow_uc_gen_balance = roleDataTb.wow_uc_gen_balance or 0
  DataMgr.anchor = roleDataTb.anchor
  DataMgr.anchor_origin = roleDataTb.anchor_origin
  LogicNewbie.newbieType = roleDataTb.fresher_type
  DataMgr.modify_name_time = GetSafeNumber(roleDataTb.modify_name_time)
  DataMgr.last_modify_nation_time = GetSafeNumber(roleDataTb.last_modify_nation_time)
  DataMgr.last_modify_nation_item_time = GetSafeNumber(roleDataTb.last_modify_nation_item_time)
  DataMgr.registertime = GetSafeNumber(roleDataTb.registertime)
  DataMgr.most_play_map = GetSafeNumber(roleDataTb.most_play_map)
  DataMgr.reg_ver = roleDataTb.reg_ver
  DataMgr.save_sum = roleDataTb.save_sum or 0
  if roleDataTb.Recharge == nil then
    DataMgr.Recharge = 1
  else
    DataMgr.Recharge = roleDataTb.Recharge
  end
  DataMgr.is_user_recharged = roleDataTb.is_user_recharged
  if roleDataTb.total_season_recharge == nil then
    DataMgr.SeasonRecharge = 0
  else
    DataMgr.SeasonRecharge = roleDataTb.total_season_recharge
  end
  DataMgr.krjp_del_account_left_time = GetSafeNumber(roleDataTb.krjp_del_account_left_time)
  log(bWriteLog and "InitRoleData Recharge:" .. tostring(roleDataTb.Recharge) .. "DataMgr Recharge:" .. tostring(DataMgr.Recharge))
  AvatarData.SetHeadID(roleDataTb.avatar.headid)
  AvatarData.SetGameGender(roleDataTb.avatar.gamegender)
  AvatarData.SetHairID(roleDataTb.avatar.hairid)
  AvatarData.SetBeardID(roleDataTb.avatar.beardid or 0)
  AvatarData.SetBeardColorID(roleDataTb.avatar.beardcolor or 0)
  DataMgr.avatarData.attr_info = roleDataTb.avatar.attr_info or {}
  log_tree("InitRoleData avatarData.attr_info", DataMgr.avatarData.attr_info)
  local avatar_list = {}
  if roleDataTb.avatar_feature_list ~= nil then
    for k, v in pairs(roleDataTb.avatar_feature_list) do
      avatar_list[k] = v
    end
  end
  DataMgr.avatarData.  if roleDataTb.activate_avatar_list ~= nil then
    local activate_avatar_list = {}
    for k, v in pairs(roleDataTb.activate_avatar_list) do
      activate_avatar_list[k] = v
    end
    DataMgr.avatarData.  end
  if roleDataTb.can_show_rp_bubble then
    DataMgr.can_show_rp_bubble = roleDataTb.can_show_rp_bubble
  end
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  fashionbag_data:UpdateAllFashionBagRolewears(roleDataTb.rolewear_array)
  fashionbag_data:UpdateAllFashionBagStates(roleDataTb.rolewear_state)
  fashionbag_data:UpdateAllFashionBagExtraInfos(roleDataTb.all_knapsack_ext_info)
  fashionbag_data:SetFashionBagUseIndex(roleDataTb.use_rolewear)
  DataMgr.pspace_rolewear_index = roleDataTb.pspace_rolewear_index
  log_tree("DataMgr rolewear_array", roleDataTb.rolewear_array)
  local TableUtil = require("common.table_util")
  local tRoleData = TableUtil.CopyTable(fashionbag_data:GetRolewearByIndex(roleDataTb.use_rolewear))
  AvatarData.SetRoleWear(tRoleData)
  AvatarData.SetCommonSubtypeWearData(roleDataTb.common_subtype_wear_data)
  DataMgr.SetLastEquipForeverSkin(roleDataTb.last_equip_forever_skins)
  local sysCfg = CDataTable.GetTableData("SystemConfig", "DefaultParachute")
  DataMgr.defaultParachuteResID = 0
  if sysCfg ~= nil then
    DataMgr.defaultParachuteResID = tonumber(sysCfg.ConfigValue)
  end
  fashionbag_data:SetParachute(roleDataTb.parachute)
  fashionbag_data:SetPlanSkin(roleDataTb.planeSkinInsID)
  fashionbag_data:SetWingmanSkin(roleDataTb.wingmanSkinInsID)
  DataMgr.gliding = roleDataTb.gliding
  if DataMgr.gliding == 0 or DataMgr.gliding == nil then
    DataMgr.gliding = roleDataTb.aircraft_put_id or 0
  end
  DataMgr.foot_special_effect_id = roleDataTb.foot_special_effect_id
  DataMgr.common_depot_puton = roleDataTb.common_depot_puton
  DataMgr.minitv_dressid = tonumber(roleDataTb.minitv_dressid)
  DataMgr.win_statue = roleDataTb.win_statue
  DataMgr.car_plate_info = roleDataTb.car_plate_info
  DataMgr.ratingShieldCardID = roleDataTb.wearRatingShield
  DataMgr.seasonRatingShieldCardID = roleDataTb.wearSeasonRatingShield
  DataMgr.seasonAddScoreCardInfo = roleDataTb.seasonAddScoreCardInfo
  DataMgr.seasonPakeGameRatingShieldCardID = roleDataTb.seasonPakeGameRatingShield
  DataMgr.seasonPakeGameAddScoreCardInfo = roleDataTb.seasonPakeGameAddScoreCardInfo
  DataMgr.ratingShieldExpireTime = roleDataTb.ratingShieldExpireTime
  DataMgr.equipmentSkinInsIDTable[504] = roleDataTb.bagSkinInsID ~= 0 and roleDataTb.bagSkinInsID or 0
  DataMgr.equipmentSkinInsIDTable[505] = roleDataTb.helmetSkinInsID ~= 0 and roleDataTb.helmetSkinInsID or 0
  DataMgr.equipmentSkinInsIDTable[506] = roleDataTb.armorSkinInsID ~= 0 and roleDataTb.armorSkinInsID or 0
  log(bWriteLog and "roleDataTb.head_show" .. roleDataTb.head_show)
  DataMgr.head_show = roleDataTb.head_show or 0
  DataMgr.bag_level = roleDataTb.bag_level or 1
  DataMgr.helmet_level = roleDataTb.helmet_level or 1
  fashionbag_data:SetHeadShow(DataMgr.head_show)
  for k, v in pairs(roleDataTb.bag_pendants) do
    fashionbag_data:SetBagPendants(k, v)
  end
  DataMgr.InitVehicleSkinData(roleDataTb.vehicleSkinInsIDTable)
  local logic_display_setting = require("client.slua.logic.wardrobe.logic_display_setting")
  logic_display_setting.UpdateDepotShowSettings(roleDataTb.depot_show_info)
  local logic_teamup_action = require("client.slua.logic.teamup.logic_teamup_action")
  logic_teamup_action.OnInitTeamUpAction(roleDataTb.teamup_action_type)
  local logic_mvp_action = require("client.slua.logic.teamup.logic_mvp_action")
  if not roleDataTb.mvp_action_type then
    log(bWriteLog and string.format("[lesterzy] DataMgr.InitRoleData roleDataTb.mvp_action_type is Missing"))
  else
    logic_mvp_action:OnInitMVPAction(roleDataTb.mvp_action_type)
  end
  DataMgr.InitWeaponData(roleDataTb.weapon_id, roleDataTb.weapon_skin_resID, roleDataTb.weapon_skin_insID)
  DataMgr.InitWeaponDIYData(roleDataTb.weapon_isUsingRecommend, roleDataTb.weapon_planID)
  DataMgr.InitExtraWeaponList(roleDataTb.extra_weapon_list)
  local display_setting = require("client.slua.logic.wardrobe.logic_display_setting")
  display_setting.RefreshGun()
  DataMgr.SignInInfo.login_reward = roleDataTb.login_reward
  DataMgr.SignInInfo.last_login_reward_remind = roleDataTb.last_login_reward_remind
  DataMgr.InitWeekSignUpList(roleDataTb.week_signup)
  if roleDataTb.share_award ~= nil then
    DataMgr.ShareAwardInfo.daily_share_time = roleDataTb.share_award.daily_share_time
    DataMgr.ShareAwardInfo.share_times = roleDataTb.share_award.share_times
    for k, v in pairs(roleDataTb.share_award.list) do
      DataMgr.ShareAwardInfo.AwardState[k] = v.status
    end
    local ShareAwardMgr = require("client.logic.share_award.logic_share_award")
    ShareAwardMgr.OnShareAwardInfoUpdate()
  else
    log_error("roleDataTb.share_award == nil")
  end
  local DoubleCardSystem = require("client.logic.double_card.logic_double_card")
  DoubleCardSystem.InitData(roleDataTb.double_card)
  DataMgr.InitRoomCardInfo(roleDataTb.room_cards)
  DataMgr.IsEightDaySlpaed = false
  DataMgr.InitJPAgeInfo(roleDataTb.jp_age)
  DataMgr.minor_cert_status = roleDataTb.minor_cert_status
  log(bWriteLog and "DataMgr.InitRoleData minor_cert_status:" .. tostring(DataMgr.minor_cert_status))
  DataMgrInit = true
  DataMgr.carteam_coin_count = roleDataTb.carteam_coin_count or 0
  DataMgr.season_id = roleDataTb.season_id or 1
  log(bWriteLog and "******* season_id init as " .. DataMgr.season_id)
  EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_SEASON_CHANGE)
  DataMgr.isSeasonStarOpen = roleDataTb.isSeasonStarOpen
  DataMgr.isHsegmentTitleOpen = roleDataTb.isHsegmentTitleOpen
  DataMgr.sink_season_id = roleDataTb.sink_season_id or 1
  log(bWriteLog and "******* sink season_id init as " .. DataMgr.sink_season_id)
  roleData.nameFrameData = roleDataTb.brand
  DataMgr.echo_port = roleDataTb.echo_port
  DataMgr.xy_userid = roleDataTb.xy_userid
  roleData.back_user_data = roleDataTb.back_user_data
  roleData.all_segment_protect_times = roleDataTb.all_segment_protect_times
  roleData.is_back_user = roleDataTb.is_back_user
  roleData.has_send_back_friend_list = false
  DataMgr.is_new_player = roleDataTb.is_new_player
  DataMgr.is_come_back_player = roleDataTb.is_come_back_player
  DataMgr.ace_imprint_show_id = roleDataTb.ace_imprint_show_id
  DataMgr.ace_imprint_base_id = roleDataTb.ace_imprint_base_id
  DataMgr.ace_imprint_show_cnt = roleDataTb.ace_imprint_show_cnt
  DataMgr.activity_teams = roleDataTb.activity_teams
  EventSystem:postEvent(EVENTTYPE_LOGIN_ROLEDATA, EVENTID_LOGIN_ROLEDATA_SYNC, roleDataTb)
  DataMgr.cheat_flag = roleDataTb.cheat_flag
  DataMgr.minitv_onekey_flag = roleDataTb.minitv_onekey_flag
  roleData.can_watch_google_ad = roleDataTb.can_watch_google_ad
  local ArenaRedDotSystem = require("client.slua.logic.arena.logic_AW_red_dot")
  ArenaRedDotSystem.OnBasePveLvNotify(roleData.pve_level)
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  ZoneSystem.InitChooseZone(roleDataTb.zone_id, roleDataTb.next_select_zone_time)
  local logic_wardrobe_card = require("client.slua.logic.wardrobe.logic_wardrobe_card")
  logic_wardrobe_card:InitArenaTimesCard(roleDataTb.rating_card)
  local TeamPlatformSystem = require("client.slua.logic.teamup.logic_team_platform")
  TeamPlatformSystem.InitGraySwitch(roleDataTb.team_consribe_switch, roleDataTb.team_consribe_voice_switch, roleDataTb.team_consribe_tplan_switch)
  roleData.voice_feedback = roleDataTb.voice_feedback
  log(bWriteLog and "god test roleDataTb.voice_feedback", roleDataTb.voice_feedback)
  DataMgr.isSoundMonitorOpen = roleDataTb.sound_monitor
  DataMgr.VGameAppID = roleDataTb.VGameAppID or ""
  local moment_cfg = require("client.slua.logic.moment.moment_cfg")
  moment_cfg.SetMomentInfo(roleDataTb.moment_info)
  roleData.no_login_label_info = roleDataTb.no_login_label_info
  if roleData.back_user_data then
    local logic_longline_task = require("client.slua.logic.player_return.logic_longline_task")
    logic_longline_task.HandleLevelRewardData()
  end
  local logic_chat_channel_world = require("client.slua.logic.lobby_chat.logic_chat_channel_world")
  logic_chat_channel_world.SetArabicCfgData(roleDataTb.arabic_chat_cfg)
  roleData.mode_views_api_version = roleDataTb.mode_views_api_version
  roleData.match_success_animation = roleDataTb.match_success_animation
  roleData.novice_guidance_flag = roleDataTb.novice_guidance_flag
  roleData.friend_nickname_skin = roleDataTb.friend_nickname_skin
  log(bWriteLog and "DataMgr.InitRoleData DataMgr.roleData.friend_nickname_skin = " .. tostring(roleData.friend_nickname_skin))
  roleData.chat_bubble = roleDataTb.chat_bubble
  log(bWriteLog and "DataMgr.InitRoleData DataMgr.roleData.chat_bubble = " .. tostring(roleData.chat_bubble))
  DataMgr.is_open_ugc = roleDataTb.is_open_ugc
  DataMgr.ugc_hot_theme = roleDataTb.ugc_hot_theme
  log(bWriteLog and "InitRoleData is_open_ugc:" .. tostring(roleDataTb.is_open_ugc))
  log(bWriteLog and "InitRoleData ugc_hot_theme:" .. tostring(roleDataTb.ugc_hot_theme))
  DataMgr.club_report_svrid = roleDataTb.club_report_svrid
  log(bWriteLog and "InitRoleData club_report_svrid:" .. tostring(roleDataTb.club_report_svrid))
  DataMgr.last_30days_recharge_amount = roleDataTb.last_30days_recharge_amount
  DataMgr.last_recharge_amount = roleDataTb.last_recharge_amount
  DataMgr.friends_most_recharge_amount = roleDataTb.friends_most_recharge_amount
  DataMgr.last_pay_time = roleDataTb.last_pay_time
  roleData.dragon_ball_unlock_state = roleDataTb.dragon_ball_unlock_state
  roleData.manor_switch = roleDataTb.manor_switch
  DataMgr.last_ugc_recharge_amount = roleDataTb.last_wow_recharge_amount
  DataMgr.last_ugc_pay_time = roleDataTb.last_wow_recharge_time
  log(bWriteLog and "DataMgr.InitRoleData last_ugc_recharge_amount = " .. tostring(DataMgr.last_ugc_recharge_amount))
  log(bWriteLog and "DataMgr.InitRoleData last_ugc_pay_time = " .. tostring(DataMgr.last_ugc_pay_time))
  roleData.social_card_share_limit = roleDataTb.social_card_share_limit
  DataMgr.ugc_author_info = roleDataTb.ugc_author_info
  log_tree(bWriteLog and "InitRoleData ugc_author_info:", roleDataTb.ugc_author_info)
  local LogicUGCAuthor = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthor)
  local state = LogicUGCAuthor:CheckBecomeCreatorState(DataMgr.roleData.uid)
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  if not state or state ~= Config_UGC.Enum_Become_Creator_Type.AnswerExemptReview then
    EventSystem:postEvent(EVENTTYPE_LOGIN_ROLEDATA, EVENTID_DATAMGR_BECOME_CREATOR)
  end
  roleData.metro_souvenirs = roleDataTb.metro_souvenirs
  log_tree(bWriteLog and "InitRoleData metro_souvenirs:", roleDataTb.metro_souvenirs)
  roleData.brief_collect_data = roleDataTb.brief_collect_data or {}
  roleData.brief_collect_hall_data = roleDataTb.brief_collect_hall_data or {}
  roleData.casual_segment_id = roleDataTb.casual_segment_id
  roleData.casual_segment_score = roleDataTb.casual_segment_score
  roleData.casual_task_award_flag = roleDataTb.casual_task_award_flag
  roleData.casual_segment_award_flag = roleDataTb.casual_segment_award_flag
  log(bWriteLog and "DataMgr.InitRoleData casual_segment_id = " .. tostring(roleData.casual_segment_id) .. ", casual_task_award_flag = " .. tostring(roleData.casual_task_award_flag) .. ", casual_segment_award_flag = " .. tostring(roleData.casual_segment_award_flag))
  roleData.peakgame_can_take_reward = roleDataTb.peakgame_can_take_reward
  roleData.peakgame_start_time = roleDataTb.peakgame_start_time
  roleData.last_season_max_segment = roleDataTb.last_season_max_segment
  log(bWriteLog and "DataMgr.InitRoleData peakgame_can_take_reward = " .. tostring(roleData.peakgame_can_take_reward) .. " peakgame_start_time = " .. tostring(roleData.peakgame_start_time) .. " last_season_max_segment = " .. tostring(roleData.last_season_max_segment))
  roleData.segment_show_type = roleDataTb.segment_show_type
  log(bWriteLog and "DataMgr.InitRoleData segment_show_type = " .. tostring(roleData.segment_show_type))
  roleData.peakgame_rating_info = roleDataTb.peakgame_rating_info
  roleData.peakgame_history_max_segment = roleDataTb.peakgame_history_max_segment
  log(bWriteLog and "DataMgr.InitRoleData peakgame_history_max_segment = " .. tostring(roleData.peakgame_history_max_segment))
  roleData.peakgame_start_time_list = roleDataTb.peakgame_start_time_list
  log_tree(bWriteLog and "DataMgr.InitRoleData peakgame_start_time_list = ", roleDataTb.peakgame_start_time_list)
  roleData.bride_npc_data = roleDataTb.bride_npc_data
  roleData.open_llm_chat_v2 = roleDataTb.open_llm_chat_v2
  roleData.open_llm_pilot = roleDataTb.open_llm_pilot
  local AceImprintHandler = require("client.network.Protocol.AceImprintHandler")
  AceImprintHandler.send_get_ace_imprint_detail_req(DataMgr.roleData.uid)
  roleData.newbie_match_guide_flag = roleDataTb.newbie_match_guide_flag
end
function DataMgr.SaveLocalIntimateApplyRed(ApplyList)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local ApplayJson = ApplyList or {}
  PlayerPrefsSystem.SaveTableToFile_N(ApplayJson, PlayerPrefsSystem.ePlayerPrefsType.InitmateRelationShipsApplyRedDot)
end
function DataMgr.SaveLocalPopulDIspalyData(DataList)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local DisPalyJson = DataList or {}
  PlayerPrefsSystem.SaveTableToFile_N(DisPalyJson, PlayerPrefsSystem.ePlayerPrefsType.newPopupwindowdisplay)
end
function DataMgr.LoadLocalPopulDIspalyData()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local DataInfo = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.newPopupwindowdisplay)
  return DataInfo
end
function DataMgr.LoadlIntimateApplyRedData()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local DataInfo = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.InitmateRelationShipsApplyRedDot)
  return DataInfo
end
function DataMgr.GetPreVersion(version)
  local result = StringUtil.Split(version, ".")
  if result and 3 <= #result then
    local str = string.format("%s.%s.0", result[1], result[2])
    return str
  end
  return nil
end
function DataMgr.GetVideoPlayPath(path)
  local list = StringUtil.Split(path, ".")
  for _, v in pairs(list) do
    if string.find(v, "PUBGM") then
      local list2 = StringUtil.Split(v, "/")
      if list2 and list2[#list2] then
        return "./MoviesPakDir/" .. list2[#list2] .. ".mp4"
      end
    end
  end
  return ""
end
function DataMgr.GetVideoDownloadPath(path)
  if not path or path == "" then
    return ""
  end
  local VideoLibrary = require("client.slua.logic.video.lobby_video_function_library")
  if VideoLibrary.IsStreamPath(path) then
    return path
  else
    if string.find(path, "/Movies/") then
      return ""
    end
    local list = StringUtil.Split(path, "/")
    local fileName = StringUtil.Split(list[#list], ".")[1]
    return "/Game/MoviesPak/" .. fileName
  end
end
function DataMgr.SetCurSegment(zoneId)
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
    zoneId = 3
  end
  log(bWriteLog and "DataMgr.SetCurSegment, zoneId = " .. zoneId)
  local allSegment = DataMgr.roleData.allzoneSegment or {}
  if next(allSegment) and allSegment[zoneId] ~= nil then
    DataMgr.roleData.segment = {
      solo = DataMgr.roleData.allzoneSegment[zoneId][enum_SegmentType.solo],
      double = DataMgr.roleData.allzoneSegment[zoneId][enum_SegmentType.double],
      team = DataMgr.roleData.allzoneSegment[zoneId][enum_SegmentType.team],
      fpp_solo = DataMgr.roleData.allzoneSegment[zoneId][enum_SegmentType.fpp_solo],
      fpp_double = DataMgr.roleData.allzoneSegment[zoneId][enum_SegmentType.fpp_double],
      fpp_team = DataMgr.roleData.allzoneSegment[zoneId][enum_SegmentType.fpp_team]
    }
  end
  DataMgr.SaveLocalCurSegment(DataMgr.roleData.segment)
  log_tree("DataMgr.roleData.segment:", DataMgr.roleData.segment)
end
function DataMgr.GetCurMaxSegmentByZoneId(zoneId, allzoneSegment)
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
    zoneId = 3
  end
  log(bWriteLog and "DataMgr.SetCurSegment, zoneId = " .. zoneId)
  local allSegment = allzoneSegment or {}
  local maxSegment = 101
  local maxMode = 1
  if next(allSegment) and allSegment[zoneId] ~= nil then
    local segmentTabs = {
      [1] = allzoneSegment[zoneId][enum_SegmentType.team] or 101,
      [2] = allzoneSegment[zoneId][enum_SegmentType.double] or 101,
      [3] = allzoneSegment[zoneId][enum_SegmentType.solo] or 101,
      [4] = allzoneSegment[zoneId][enum_SegmentType.fpp_team] or 101,
      [5] = allzoneSegment[zoneId][enum_SegmentType.fpp_double] or 101,
      [6] = allzoneSegment[zoneId][enum_SegmentType.fpp_solo] or 101
    }
    maxSegment = math.max(segmentTabs[1], segmentTabs[2], segmentTabs[3], segmentTabs[4], segmentTabs[5], segmentTabs[6])
    for key, value in pairs(segmentTabs) do
      if maxSegment == value then
        maxMode = key
        break
      end
    end
  end
  local indexToMode = {
    [1] = "team",
    [2] = "double",
    [3] = "single",
    [4] = "fppteam",
    [5] = "fppdouble",
    [6] = "fppsingle"
  }
  return maxSegment, indexToMode[maxMode]
end
function DataMgr.SetCollectHallData(tCollectHallData)
  DataMgr.roleData.brief_collect_hall_data = tCollectHallData
end
function DataMgr.GetCollectHallData()
  return DataMgr.roleData.brief_collect_hall_data or {}
end
function DataMgr.GetCollectSysData()
  return DataMgr.roleData.brief_collect_data or {}
end
function DataMgr.SaveLocalCurSegment(segmentTable)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local roleJson = segmentTable or {}
  PlayerPrefsSystem.SaveTableToFile_N(roleJson, PlayerPrefsSystem.ePlayerPrefsType.eSegment)
end
function DataMgr.GetLocalSegmentInfo()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local roleJson = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eSegment) or {}
  return roleJson
end
function DataMgr.GetSegmentByZoneId(zoneId)
  log(bWriteLog and "DataMgr.GetSegmentByZoneId, zoneId = " .. zoneId)
  if #DataMgr.roleData.allzoneSegment > 0 and DataMgr.roleData.allzoneSegment[zoneId] ~= nil then
    segment = {
      solo = DataMgr.roleData.allzoneSegment[zoneId][enum_SegmentType.solo],
      double = DataMgr.roleData.allzoneSegment[zoneId][enum_SegmentType.double],
      team = DataMgr.roleData.allzoneSegment[zoneId][enum_SegmentType.team],
      fpp_solo = DataMgr.roleData.allzoneSegment[zoneId][enum_SegmentType.fpp_solo],
      fpp_double = DataMgr.roleData.allzoneSegment[zoneId][enum_SegmentType.fpp_double],
      fpp_team = DataMgr.roleData.allzoneSegment[zoneId][enum_SegmentType.fpp_team]
    }
    return segment
  end
  return nil
end
function DataMgr.InitVehicleSkinData(data)
  if data ~= nil then
    DataMgr.vehicleSkinInsIDTable = {}
    for k, v in pairs(data) do
      if v ~= 0 then
        DataMgr.vehicleSkinInsIDTable[k] = v
      end
    end
  end
end
function DataMgr.InitBanData(banData)
  DataMgr.ban = banData
  EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_SYNC_PLAYER_BAN, banData)
end
function DataMgr.GetBanInfo(ban_id)
  if not DataMgr.ban then
    return nil
  end
  if type(DataMgr.ban) ~= "table" then
    return nil
  end
  return DataMgr.ban[ban_id]
end
function DataMgr.UpdateMyRoleProfileData(data, myRankData, myPassData, myAliasData, corps_alias_info)
  DataMgr.roleData.nickName = data.nickName
  if data.level > DataMgr.roleData.level then
    DataMgr.roleData.level = data.level
  end
  if data.pve_level > DataMgr.roleData.pve_level then
    DataMgr.roleData.pve_level = data.pve_level
  end
  if data.pve_exp > DataMgr.roleData.pve_exp then
    DataMgr.roleData.pve_exp = data.pve_exp
  end
  log(bWriteLog and "DataMgr.UpdateMyRoleProfileData, roleDataLevel = " .. DataMgr.roleData.level .. ",pve_level:" .. DataMgr.roleData.pve_level .. ",pve_exp:" .. tostring(DataMgr.roleData.pve_exp))
  DataMgr.roleData.headIconUrl = data.picUrl
  log(bWriteLog and "DataMgr.UpdateMyRoleProfileData, headIconUrl = " .. DataMgr.roleData.headIconUrl)
  if string.find(DataMgr.roleData.headIconUrl, "twimg") ~= nil then
    DataMgr.roleData.headIconUrl = string.gsub(DataMgr.roleData.headIconUrl, "_normal", "_bigger")
    log(bWriteLog and "DataMgr.UpdateMyRoleProfileData, twitter headIconUrl = " .. DataMgr.roleData.headIconUrl)
  end
  DataMgr.roleData.upvote = data.upvote
  DataMgr.roleData.charisma = data.charisma
  local RoleInfoAvatarFrameSystem = require("client.slua.logic.roleInfo.logic_RoleInfoAvatarFrame")
  RoleInfoAvatarFrameSystem.UpdateCurAvatarBoxID(data.cur_avatar_box_id)
  local fixWord = FuncUtil.GetKeywordByID(3377006) .. "_vip"
  DataMgr.roleData.bgbg_vip = GetSafeNumber(data[fixWord])
  DataMgr.roleData.allzoneSegment = DataMgr.roleData.allzoneSegment or {}
  for k, v in pairs(data.segment_info) do
    DataMgr.roleData.allzoneSegment[k] = v
  end
  log_tree("UpdateMyRoleProfileData segment_info", data.segment_info)
  SegmentZoneCount = DataMgr.roleData.allzoneSegment and #DataMgr.roleData.allzoneSegment or 0
  if SegmentZoneCount > 0 then
    for k, v in pairs(DataMgr.roleData.allzoneSegment) do
      DataMgr.SetCurSegment(k)
      break
    end
  end
  if myRankData then
    DataMgr.roleData.rankdata = myRankData
    log_tree("roleData.rankdata", DataMgr.roleData.rankdata)
    local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
    MatchModeMgrSystem.rankData = {}
  else
    log(bWriteLog and "UpdateMyRoleProfileData rankdata is empty")
  end
  if myPassData then
    DataMgr.roleData.upass = myPassData
  else
    log(bWriteLog and "UpdateMyRoleProfileData myPassData is empty")
  end
  if myAliasData then
    local redpoint = DataMgr.roleData.alias.red_point
    DataMgr.roleData.alias = myAliasData
    DataMgr.roleData.alias.red_point = redpoint
    DataMgr.roleData.alias.title = FuncUtil.Gen_title(myAliasData.id, myAliasData.rank, myAliasData.ext_info, myAliasData.rank_id)
  else
    log(bWriteLog and "UpdateMyRoleProfileData myAliasData is empty")
  end
  if corps_alias_info and DataMgr.roleData.corps_alias_data then
    DataMgr.roleData.corps_alias_data.cur_corps_alias_id = corps_alias_info.cur_corps_alias_id
  end
  if data.pround_info then
    log_tree("UpdateMyRoleProfileData pround_info", data.pround_info)
    DataMgr.roleData.pround_info = data.pround_info or {}
  else
    log(bWriteLog and "UpdateMyRoleProfileData pround_info is empty")
  end
  if data.psmatch_info then
    log_tree("UpdateMyRoleProfileData psmatch_info", data.psmatch_info)
    DataMgr.roleData.psmatch_info = data.psmatch_info
  else
    log(bWriteLog and "UpdateMyRoleProfileData psmatch_info is empty")
  end
  log(bWriteLog and "DataMgr.UpdateMyRoleProfileData, auth_type = " .. tostring(data.auth_type) .. ", auth_end_time = " .. tostring(data.auth_end_time))
  DataMgr.roleData.auth_type = data.auth_type
  DataMgr.roleData.auth_end_time = data.auth_end_time
  DataMgr.roleData.total_devote = data.total_devote or 0
  DataMgr.roleData.battleinfo_show_options = data.battleinfo_show_options
  DataMgr.roleData.ip_region = data.ip_region
  EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_SEASON_CHANGE)
end
function DataMgr.GetAvatarRemainTime(avatar_id)
  local remainTime = -1
  if DataMgr.avatarData.avatar_list[avatar_id] ~= nil then
    if DataMgr.avatarData.avatar_list[avatar_id] == 0 then
      remainTime = 0
    else
      local TimeUtil = require("client.common.time_util")
      remainTime = DataMgr.avatarData.avatar_list[avatar_id] - TimeUtil.GetServerTimeInSec()
      log(bWriteLog and "GetAvatarRemainTime " .. tostring(avatar_id) .. ":" .. tostring(remainTime))
      if remainTime == 0 then
        remainTime = 1
      end
    end
  end
  return remainTime
end
function DataMgr.HasAvatarById(itemId)
  local avatarId
  for k, v in pairs(CDataTable.GetTable("AvatarInit")) do
    if v.BodyID == itemId then
      avatarId = v.ID
    end
  end
  if not avatarId then
    return false
  end
  local result = false
  if avatarId ~= nil then
    avatarId = tonumber(avatarId)
    if DataMgr.avatarData.avatar_list[avatarId] ~= nil and DataMgr.avatarData.avatar_list[avatarId] == 0 then
      result = true
    end
  end
  log(bWriteLog and "DataMgr.HasAvatarById, avatarId = " .. tostring(avatarId) .. ", result = " .. tostring(result))
  return result
end
function DataMgr.UpdateRoleWearData(putOnId, putDownId)
  if putDownId ~= 0 then
    AvatarData.RemoveRoleWearDataByValue(putDownId)
  end
  local isFind = false
  local tRoleData = AvatarData.GetRoleWear()
  if putOnId ~= 0 then
    for _, v in pairs(tRoleData) do
      if v == putOnId then
        isFind = true
        v = putOnId
        break
      end
    end
  end
  if isFind == false and putOnId ~= 0 then
    AvatarData.AddRoleWearData(putOnId)
  end
  DataMgr.UpdateItemNewFlag(putOnId, putDownId)
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  fashionbag_data:SaveRolewearToFashionBag(fashionbag_data:GetFashionBagUseIndex())
end
function DataMgr.GetLastEquipForeverSkin(ItemType, ItemSubType)
  if not DataMgr.last_equip_forever_skins then
    return nil
  end
  if not ItemType or not DataMgr.last_equip_forever_skins[ItemType] then
    return nil
  end
  if not ItemSubType or not DataMgr.last_equip_forever_skins[ItemType][ItemSubType] then
    return nil
  end
  return DataMgr.last_equip_forever_skins[ItemType][ItemSubType]
end
function DataMgr.SetLastEquipForeverSkin(last_equip_forever_skins)
  DataMgr.end
function DataMgr.UpdateLastEquipForeverSkin(ItemType, ItemSubType, skin)
  if not (ItemType and ItemSubType) or not skin then
    return
  end
  if not DataMgr.last_equip_forever_skins then
    DataMgr.last_equip_forever_skins = {}
  end
  if not DataMgr.last_equip_forever_skins[ItemType] then
    DataMgr.last_equip_forever_skins[ItemType] = {}
  end
  if not DataMgr.last_equip_forever_skins[ItemType][ItemSubType] then
    DataMgr.last_equip_forever_skins[ItemType][ItemSubType] = skin
  end
end
function DataMgr.UpdateItemNewFlag(putOnId, putDownId)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  wardrobe_data:ChangeHallDepotItemNewStatus(putOnId)
  wardrobe_data:ChangeHallDepotItemNewStatus(putDownId)
end
function DataMgr.UpdateEffect(putOnId)
  DataMgr.UpdateItemNewFlag(putOnId, DataMgr.gliding)
  DataMgr.gliding = putOnId
end
function DataMgr.UpdateFootEffect(putOnId)
  DataMgr.UpdateItemNewFlag(putOnId, DataMgr.foot_special_effect_id)
  DataMgr.foot_special_effect_id = putOnId
end
function DataMgr.GetCommonPutOnDataBy(subType)
  local data = DataMgr.common_depot_puton or {}
  local putOnField = SubType2PutOnField[subType]
  if putOnField then
    return data[putOnField]
  end
  return nil
end
function DataMgr.UpdateCommonPutOnDataBy(subType, instanceId)
  if not DataMgr.common_depot_puton then
    DataMgr.common_depot_puton = {}
  end
  local data = DataMgr.common_depot_puton
  local putOnField = SubType2PutOnField[subType]
  if putOnField then
    data[putOnField] = instanceId
  end
end
function DataMgr.UpdateMiniTvDress(putOnId)
  DataMgr.minitv_dressid = putOnId
  EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_MINITV_DRESS_UPDATE)
end
function DataMgr.UpdateStatueSkin(putOnId)
  DataMgr.win_statue = putOnId
end
function DataMgr.UpdateEquipmentSkin(itemSubType, putOnId)
  local skinInsID = DataMgr.equipmentSkinInsIDTable[itemSubType]
  if skinInsID ~= nil then
    DataMgr.UpdateItemNewFlag(putOnId, skinInsID)
    DataMgr.equipmentSkinInsIDTable[itemSubType] = putOnId
  end
end
function DataMgr.UpdateVehicleSkin(itemSubType, putOnId)
  log(bWriteLog and "DataMgr.UpdateVehicleSkin:itemSubType" .. tostring(itemSubType) .. "DataMgr.vst_skin" .. tostring(putOnId))
  DataMgr.vst_skin = putOnId
  local skinInsID = DataMgr.vehicleSkinInsIDTable[itemSubType]
  if skinInsID ~= nil then
    DataMgr.UpdateItemNewFlag(putOnId, skinInsID)
    DataMgr.vehicleSkinInsIDTable[itemSubType] = putOnId
    local tabSurveillance = require("client.slua.logic.wardrobe.tab_surveillance")
    tabSurveillance.VehicleChange()
  end
end
function DataMgr.HasEquipVehicleSkin(insID)
  if not insID or insID == 0 then
    return false
  end
  for _, _Insid in pairs(DataMgr.vehicleSkinInsIDTable) do
    if insID == _Insid then
      return true
    end
  end
  return false
end
function DataMgr.GetMaxRankLevel()
  DataMgr.fillMaxSegmentInfo()
  maxRankLevel = math.max(DataMgr.maxSegmentSolo.SegmentLevel, DataMgr.maxSegmentDuo.SegmentLevel, DataMgr.maxSegmentSquad.SegmentLevel, DataMgr.maxSegmentSoloFpp.SegmentLevel, DataMgr.maxSegmentDuoFpp.SegmentLevel, DataMgr.maxSegmentSquadFpp.SegmentLevel)
  return maxRankLevel
end
function DataMgr.IsValidTime(time)
  if not time or time == 0 then
    return true
  end
  local TimeUtil = require("client.common.time_util")
  return time >= TimeUtil.GetServerTimeInSec()
end
function DataMgr.GetItemValidHour(expireTS)
  if expireTS <= 0 then
    return 0
  end
  local timeUtil = require("client.common.time_util")
  local curtime = timeUtil.GetServerTimeInSec()
  if expireTS <= curtime then
    return 0
  end
  local validHour = math.modf((expireTS - curtime) / 3600)
  if validHour < 1 then
    validHour = 1
  end
  return validHour
end
function DataMgr.GetExpireTSAddValue(src, dst)
  local tSrc = src.expireTS or 0
  local tDst = dst.expire_ts or 0
  if tSrc < tDst then
    return tDst - tSrc
  end
  return 0
end
function DataMgr.ShowExpireTSChangeTips(map)
  local pandoraLogic = require("client.slua.logic.Pandora.pandora_logic")
  local curActId = pandoraLogic.GetCurActId()
  if curActId == BP_ENUM_MODULE_PANDORA_ICE_SNOW_GIFT then
    return
  end
  local wardrobeLogic = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  for resId, changeValue in pairs(map) do
    if 0 < changeValue then
      local cfg = CDataTable.GetTableData("Item", resId)
      if cfg then
        local timeStr = wardrobeLogic:GetTimeStr(changeValue)
        ShowNotice(LocUtil.LocalizeResFormat(6831, cfg.ItemName, timeStr))
      end
    end
  end
end
function DataMgr.ShowExpireTSMaxTips(map)
  for resId, maxValue in pairs(map) do
    if maxValue ~= nil then
      local cfg = CDataTable.GetTableData("Item", resId)
      if cfg then
        ShowNotice(LocUtil.LocalizeResFormat(6859, cfg.ItemName))
      end
    end
  end
end
function DataMgr.UpdateSignInData(period, day)
  log(bWriteLog and "DataMgr UpdateSignInData")
  if DataMgr.SignInInfo.login_reward[period] == nil then
    DataMgr.SignInInfo.login_reward[period] = {}
  end
  if DataMgr.SignInInfo.login_reward[period][day] == nil then
    DataMgr.SignInInfo.login_reward[period][day] = true
  end
end
function DataMgr.OnRoleAttrChangeNotify(attriType, attriValue, attriTab, isClickReward)
  log(bWriteLog and "OnRoleAttrChangeNotify attriType:" .. attriType)
  local Logic_AttributeUpdateCfg = require("client.logic.data.Logic_AttributeUpdateCfg")
  local fHandleFun = Logic_AttributeUpdateCfg.GetAttributeHandlerFun(attriType)
  if fHandleFun and type(fHandleFun) == "function" then
    log(bWriteLog and "DataMgr.OnRoleAttrChangeNotify attriType >>> " .. tostring(attriType))
    fHandleFun(attriValue, attriTab, isClickReward)
    return
  end
  if attriType == struct_RoleAttri.attr_type_gold then
    DataMgr.gold = attriValue
    EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_GOLD_CHANGE, attriValue)
  elseif attriType == struct_RoleAttri.attr_type_ticket then
    local RecommendHandler = require("client.slua.logic.download.recommend.logic_recommend_handler")
    RecommendHandler.OnUCChange(DataMgr.ticket, attriValue)
    DataMgr.ticket = attriValue
    DataMgr.gen_ticket = attriTab.gen_ticket
    EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_TICKET_CHANGE, attriValue, attriTab)
  elseif attriType == struct_RoleAttri.attr_type_fp_token then
    DataMgr.fp_token = attriValue
    EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_FP_TOKEN_CHANGE, attriValue)
  elseif attriType == struct_RoleAttri.attr_type_diamond then
    DataMgr.diamond = attriValue
    EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_DIAMOND_CHANGE, attriValue)
  elseif attriType == struct_RoleAttri.attr_type_eternal_diamond then
    DataMgr.eternal_diamond = attriValue
    EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_ETERNAL_DIAMOND_CHANGE, attriValue)
  elseif attriType == struct_RoleAttri.attr_type_gold_chip then
    DataMgr.gold_chip = attriValue
    EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_GOLD_CHIP_CHANGE, attriValue)
  elseif attriType == struct_RoleAttri.attr_type_nation then
    DataMgr.roleData.nation = attriValue
  elseif attriType == struct_RoleAttri.attr_type_exp then
    local logic_level_unlock_exp = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_level_unlock_exp)
    logic_level_unlock_exp:RecordOldExp(DataMgr.roleData.roleExp)
    DataMgr.roleData.roleExp = attriValue
    EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_ROLE_EXP_CHANGE, attriValue, isClickReward)
  elseif attriType == struct_RoleAttri.attr_type_level then
    local LevelUpSystem = require("client.logic.levelup.logic_levelup")
    LevelUpSystem.OldLevel = DataMgr.roleData.level
    local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
    level_unlock_manager:RecordLevel(DataMgr.roleData.level)
    log(bWriteLog and "old level: " .. tostring(DataMgr.roleData.level))
    DataMgr.UpdateLevel(attriValue)
    log(bWriteLog and "new level: " .. tostring(attriValue))
    if DataMgr.roleData.level == 10 then
      local logic_cloud_game = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cloud_game)
      log(bWriteLog and "[zzww] DataMgr:UpdateLevelTaskChange SendMessageToCloudGame LevelUpToCertainLevel")
      logic_cloud_game:SendMessageToCloudGame(logic_cloud_game.ProtocolName.LevelUpToCertainLevel, "Attmptlevel_10")
    end
    EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_ROLE_LEVEL_CHANGE, attriValue, isClickReward)
  elseif attriType == struct_RoleAttri.attr_type_signature then
    DataMgr.roleData.signature = attriValue
    EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_SIGNINFO_REFRESH)
  elseif attriType == struct_RoleAttri.attr_type_segment then
    log(bWriteLog and "Player Rank Change")
    log_tree(bWriteLog and "attr_type_segment attriTab", attriTab)
    DataMgr.UpdateZoneSegementById(attriTab.zone_id, attriTab.segment_type, attriTab.segment_value)
    local SettingAccount = require("client.logic.setting.logic_setting_account")
    SettingAccount.SegmentUpgrade(attriTab and attriTab.segment_value)
    local LogicTeamUpLimit = require("client.slua.logic.teamup.logic_team_up_limit")
    LogicTeamUpLimit.send_get_single_squad_pre_team_limit_req()
    EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ROLE_RANK_CHANGE, attriValue)
  elseif attriType == struct_RoleAttri.attr_type_rating_info_silent then
    log(bWriteLog and "attr_type_rating_info_silent")
    DataMgr.UpdateZoneSegementById(attriTab.zone_id, attriTab.segment_type, attriTab.segment_value)
    local rankdata = DataMgr.roleData.rankdata and DataMgr.roleData.rankdata[attriTab.zone_id]
    log_tree(bWriteLog and "attriTab", attriTab)
    if rankdata and rankdata[attriTab.segment_type] then
      local data = rankdata[attriTab.segment_type]
      data.rank_rating = attriTab.new_rating
      data.win_rating = attriTab.new_win_rating
      data.kill_rating = attriTab.new_kill_rating
    end
    if DataMgr.roleData.segment_rating and DataMgr.roleData.segment_rating[attriTab.zone_id] then
      local segmentIndex = enum_ModeType[attriTab.segment_type]
      segmentIndex = segmentIndex or 1
      log(bWriteLog and "[ZH] segmentIndex: " .. tostring(segmentIndex))
      DataMgr.roleData.segment_rating[attriTab.zone_id][segmentIndex] = DataMgr.roleData.segment_rating[attriTab.zone_id][segmentIndex] or 0
      DataMgr.roleData.segment_rating[attriTab.zone_id][segmentIndex] = attriTab.new_rating
      log(bWriteLog and "[ZH]  attriTab.new_rating: " .. tostring(attriTab.new_rating))
    end
  elseif attriType == struct_RoleAttri.attr_type_promo_segment then
    log_tree("attr_type_promo_segment attriTab", attriTab)
    DataMgr.UpdateZoneSegementById(attriTab.zone_id, attriTab.segment_type, attriTab.segment_value)
    local rankdata = DataMgr.roleData.rankdata and DataMgr.roleData.rankdata[attriTab.zone_id]
    if rankdata and rankdata[attriTab.segment_type] then
      local data = rankdata[attriTab.segment_type]
      data.rank_rating = attriTab.new_rating
      data.win_rating = attriTab.new_win_rating
      data.kill_rating = attriTab.new_kill_rating
    end
    local segmentIndex = enum_ModeType[attriTab.segment_type]
    log(bWriteLog and "attr_type_promo_segment segmentIndex: " .. tostring(segmentIndex))
    if DataMgr.roleData.segment_rating and DataMgr.roleData.segment_rating[attriTab.zone_id] and segmentIndex then
      DataMgr.roleData.segment_rating[attriTab.zone_id][segmentIndex] = DataMgr.roleData.segment_rating[attriTab.zone_id][segmentIndex] or 0
      DataMgr.roleData.segment_rating[attriTab.zone_id][segmentIndex] = attriTab.new_rating
    end
    local promotion_match_util = require("client.logic.season.promotion_match.promotion_match_util")
    promotion_match_util.UpdatePromotionRatingData(attriTab.zone_id, segmentIndex, attriTab.promo_rank_rating)
  elseif attriType == struct_RoleAttri.attr_type_promotion_data then
    log_tree(bWriteLog and "attr_type_promotion_data attriTab", attriTab)
    local promotion_data = attriTab
    local promotion_match_util = require("client.logic.season.promotion_match.promotion_match_util")
    promotion_match_util.UpdatePromotionData(promotion_data)
    EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_PROMOTION_DATA_CHANGE)
  elseif attriType == struct_RoleAttri.attr_type_promo_rating then
    log_tree(bWriteLog and "attr_type_promo_rating attriTab", attriTab)
    local segmentIndex = enum_ModeType[attriTab.segment_type]
    local promotion_match_util = require("client.logic.season.promotion_match.promotion_match_util")
    promotion_match_util.UpdatePromotionRatingData(attriTab.zone_id, segmentIndex, attriTab.promo_rank_rating)
  elseif attriType == struct_RoleAttri.attr_type_corpsmoney then
    DataMgr.corps_money = attriValue
    EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_CORPS_MONEY_CHANGE, attriValue)
  elseif attriType == struct_RoleAttri.attr_type_credit then
    log(bWriteLog and "struct_RoleAttri.attr_type_credit = " .. tostring(struct_RoleAttri.attr_type_credit))
    DataMgr.roleData.credit = attriValue
    EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ROLE_CREDIT, attriValue)
  elseif attriType == struct_RoleAttri.attr_type_season_id then
    local bSeasonChange = DataMgr.season_id ~= attriValue
    DataMgr.season_id = attriValue or 1
    if attriTab then
      DataMgr.roleData.allzoneSegment = attriTab
    end
    if isClickReward then
      DataMgr.roleData.segment_rating = isClickReward
    end
    if bSeasonChange then
      local promotion_match_util = require("client.logic.season.promotion_match.promotion_match_util")
      promotion_match_util.ClearPromotionRatingData()
    end
    EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_SEASON_CHANGE, true)
    log(bWriteLog and "******* season_id OnRoleAttrChangeNotify as " .. DataMgr.season_id)
  elseif attriType == struct_RoleAttri.attr_type_pve_exp then
    DataMgr.roleData.pve_exp = attriValue
    log(bWriteLog and "******* attr_type_pve_exp OnRoleAttrChangeNotify: " .. tostring(attriValue))
    EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_PVE_EXP_CHANGE, attriValue)
  elseif attriType == struct_RoleAttri.attr_type_pve_level then
    local LevelUpSystem = require("client.logic.levelup.logic_levelup")
    LevelUpSystem.PveOldLevel = DataMgr.roleData.pve_level
    local weapon_lv_up = {}
    weapon_lv_up.pre_level = DataMgr.roleData.pve_level
    weapon_lv_up.aft_level = attriValue
    local ArenaWeaponSystem = require("client.slua.logic.arena.logic_arena_weapon")
    ArenaWeaponSystem.save_weapon_level_up = weapon_lv_up
    local showWeapon = false
    for k, v in pairs(CDataTable.GetTable("ArenaPrepareWeapon")) do
      if v.UnlockType == "pve_level" and weapon_lv_up.pre_level < v.UnlockNum and weapon_lv_up.aft_level >= v.UnlockNum then
        showWeapon = true
        break
      end
    end
    if showWeapon then
      UIManager.ShowUI(UIManager.UI_Config.arena_weapon_levelup)
    end
    DataMgr.roleData.pve_level = attriValue
    log(bWriteLog and "******* attr_type_pve_level OnRoleAttrChangeNotify old:" .. tostring(LevelUpSystem.PveOldLevel) .. ",new:" .. tostring(attriValue))
    EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_PVE_LEVEL_CHANGE, attriValue)
    local ArenaRedDotSystem = require("client.slua.logic.arena.logic_AW_red_dot")
    ArenaRedDotSystem.OnPveLvNotify(attriValue)
  elseif attriType == struct_RoleAttri.attr_type_first_reasch_high_segment then
    local SeasonSystem = require("client.logic.season.logic_season")
    SeasonSystem.ReportAdjustEvent(attriValue)
    if attriValue and attriValue.new_segment and attriValue.new_segment == 701 then
      return
    end
    SeasonSystem.OnRankSlapInfo(attriValue)
    log(bWriteLog and "DataMgr.OnRoleAttrChangeNotify attr_type_first_reasch_high_segment GetNormalProfiles")
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles({
      DataMgr.roleData.uid
    }, function()
      EventSystem:postEvent(EVENTTYPE_PROFILE, EVENTID_DATAMGR_UPDATE_HIGH_SEGMENT)
    end, Enum_PROFILE_REPORT_CFG.UPDATE_HIGH_SEGMENT, nil, true)
  elseif attriType == struct_RoleAttri.attr_type_arena_rating_info then
    local arena_rating_and_segment = DataMgr.roleData.arena_rating_and_segment
    if not arena_rating_and_segment then
      return
    end
    local data = arena_rating_and_segment[attriValue.zone_id]
    if data and data.vs_team then
      data.vs_team.segment_id = attriValue.new_segment_id
      data.vs_team.rank_rating = attriValue.new_rating
      local ArenaSystem = require("client.slua.logic.arena.logic_arena")
      ArenaSystem.UpdateSegment(attriValue.new_rating)
      EventSystem:postEvent(EVENTTYPE_ARENA, EVENTID_ARENA_GET_SEASON_RECORD_ARENA_RSP, attriValue.new_segment_id)
    end
  elseif attriType == struct_RoleAttri.attr_type_ace_imprint then
    log(bWriteLog and "attr_type_ace_imprint old:" .. tostring(DataMgr.ace_imprint_show_id) .. ",new:" .. tostring(attriValue))
    log_tree(bWriteLog and "OnRoleAttrChangeNotify attriTab = ", attriTab)
    DataMgr.ace_imprint_show_id = attriValue
    DataMgr.ace_imprint_base_id = attriTab and attriTab.ace_imprint_base_id or 0
    DataMgr.ace_imprint_show_cnt = attriTab and attriTab.ace_imprint_show_cnt or 0
    LobbySystem.roleData.peakgame_ace_count = attriTab and attriTab.peakgame_ace_count
    LobbySystem.roleData.peakgame_ace_id = attriTab and attriTab.peakgame_ace_id
    LobbySystem.roleData.ace_show_type = attriTab and attriTab.ace_show_type
    local AceImprintLogic = require("client.logic.season.AceImprintLogic")
    AceImprintLogic.HasGetNew = true
    log(bWriteLog and "OnRoleAttrChangeNotify: req player ace_imprint_data")
    local AceImprintHandler = require("client.network.Protocol.AceImprintHandler")
    AceImprintHandler.send_get_ace_imprint_detail_req(DataMgr.roleData.uid)
    EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_ACE_IMPRINT_UPDATE)
  elseif attriType == struct_RoleAttri.attr_type_allstar_score then
    LobbySystem.roleData.allstar_score = attriValue
    EventSystem:postEvent(EVENTTYPE_ALLSTAR, EVENTID_ALLSTAR_UPDATE_SCORE)
  elseif attriType == struct_RoleAttri.attr_type_chanllenge_info then
    local SeasonSystem = require("client.logic.season.logic_season")
    SeasonSystem.OnChanllengeInfoChange(attriValue)
  elseif attriType == struct_RoleAttri.attr_type_sink_segment then
    log_tree("******* Player Sink Rank Change:", attriTab)
    if DataMgr.roleData.sink_segment and DataMgr.roleData.sink_segment_rating and attriTab.zone_id then
      local sink_segment = DataMgr.roleData.sink_segment[attriTab.zone_id]
      local sink_segment_rating = DataMgr.roleData.sink_segment_rating[attriTab.zone_id]
      if attriTab.segment_type == SinkPerspectiveType.sink_segment_type_tpp then
        if sink_segment and sink_segment[E_SinkModeDataType.SinkDataTPP] and attriTab.segment_value then
          sink_segment[E_SinkModeDataType.SinkDataTPP] = attriTab.segment_value
        end
        if sink_segment_rating and sink_segment_rating[E_SinkModeDataType.SinkDataTPP] and attriTab.new_rating then
          sink_segment_rating[E_SinkModeDataType.SinkDataTPP] = attriTab.new_rating
        end
      elseif attriTab.segment_type == SinkPerspectiveType.sink_segment_type_fpp then
        if sink_segment and sink_segment[E_SinkModeDataType.SinkDataFPP] and attriTab.segment_value then
          sink_segment[E_SinkModeDataType.SinkDataFPP] = attriTab.segment_value
        end
        if sink_segment_rating and sink_segment_rating[E_SinkModeDataType.SinkDataFPP] and attriTab.new_rating then
          sink_segment_rating[E_SinkModeDataType.SinkDataFPP] = attriTab.new_rating
        end
      end
    end
  elseif attriType == struct_RoleAttri.attr_type_player_name then
    if attriValue then
      DataMgr.UpdateNickName(attriValue)
      EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_ROLENAME)
    end
  elseif attriType == struct_RoleAttri.attr_pround_info then
    log(bWriteLog and "DataMgr.OnRoleAttrChangeNotify attr_pround_info Change attriValue = " .. tostring(attriValue))
    local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
    if attriValue and RoleInfoPopularitySystem.IsProundHornMsgLevel(tonumber(attriValue)) then
      EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_ROLEINFO_UPDATE_PROUND_LEVEL, attriValue)
      local logic_chat_main = require("client.slua.logic.lobby_chat.logic_chat_main")
      logic_chat_main.SendProundHornMsg(attriValue)
    end
  elseif attriType == struct_RoleAttri.attr_type_wow_creation_score then
    DataMgr.wow_creation_score = attriValue
    EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_UGC_CREATIVE_SCORE_CHANGE, attriValue)
  elseif attriType == struct_RoleAttri.attr_type_segment_show then
    log(bWriteLog and "DataMgr.OnRoleAttrChangeNotify attr_type_segment_show Change attriValue = " .. tostring(attriValue))
    if attriValue then
      DataMgr.roleData.segment_show_type = attriValue
      local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
      local profile = logic_profile:GetLocalProfile(DataMgr.roleData.uid)
      if profile then
        profile.segment_show_type = attriValue
      end
    end
  elseif attriType == struct_RoleAttri.attr_type_peakgame_info then
    log(bWriteLog and "DataMgr.OnRoleAttrChangeNotify attr_type_peakgame_info Change attriValue = " .. tostring(attriValue))
    log_tree("DataMgr.OnRoleAttrChangeNotify attr_type_peakgame_info Change attriTab = ", attriTab)
    if attriTab and next(attriTab) then
      DataMgr.roleData.peakgame_can_take_reward = attriTab.peakgame_can_take_reward
      DataMgr.roleData.peakgame_start_time = attriTab.peakgame_start_time
      DataMgr.roleData.last_season_max_segment = attriTab.last_season_max_segment
      EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_PEAKGAME_INFO_CHANGE_NOTIFY)
    end
  elseif attriType == struct_RoleAttri.attr_type_smelt then
    local num = attriValue - DataMgr.smelt
    DataMgr.smelt = attriValue
    local EasterEggModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.EasterEggModule)
    EasterEggModule:AddWealthGap(num)
    EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_SMELT_CHANGE, attriValue, attriTab)
  elseif attriType == struct_RoleAttri.attr_type_creator_care_change then
    log(bWriteLog and "DataMgr.OnRoleAttrChangeNotify attr_type_creator_care_change Change attriValue = " .. tostring(attriValue))
    if attriValue then
      EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_CREATOR_CARE_CHANGE, attriValue)
    end
  elseif attriType == struct_RoleAttri.attr_type_custom_presentation then
    if attriValue then
      local logic_custom_presentation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_custom_presentation)
      local custom_presentation = attriValue.custom_presentation or attriValue
      logic_custom_presentation:SetData(custom_presentation)
      LobbySystem.roleData.      EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_CUSTOM_PRESENTATION_CHANGE)
    end
  elseif attriType == struct_RoleAttri.attr_ugc_advanced_crystal then
    if attriValue then
      log(bWriteLog and "DataMgr.OnRoleAttrChangeNotify attr_ugc_advanced_crystal Change attriValue = " .. tostring(attriValue))
      DataMgr.ugc_advanced_crystal = attriValue
      EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_UGC_ADVANCED_CRYSTAL_UPDATE, attriValue)
      log_tree("DataMgr.OnRoleAttrChangeNotify attr_ugc_advanced_crystal Change attriTab = ", attriTab)
      DataMgr.wow_uc_gen_balance = attriTab and attriTab.wow_uc_gen_balance or 0
    end
  elseif attriType == struct_RoleAttri.attr_type_promo_challenge and attriValue then
    log_tree(bWriteLog and "attr_type_promo_challenge_data attriTab", attriTab)
    local promo_challenge_data = attriTab
    local promotion_match_util = require("client.logic.season.promotion_match.promotion_match_util")
    promotion_match_util.UpdatePromoChallengeData(promo_challenge_data)
    EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_PROMOTION_DATA_CHANGE)
  end
end
function DataMgr.UpdateZoneSegementById(zoneId, attrType, segmentValue)
  log(bWriteLog and "UpdateZoneSegementById, zoneId = " .. zoneId .. ", attrType = " .. attrType .. ", segmentValue = " .. segmentValue)
  DataMgr.UpdateZoneSegementZoneId = zoneId
  if not DataMgr.roleData.allzoneSegment then
    DataMgr.roleData.allzoneSegment = {}
  end
  if not DataMgr.roleData.allzoneSegment[zoneId] then
    DataMgr.roleData.allzoneSegment[zoneId] = {}
  end
  if attrType == struct_SegmentType.segment_type_solo then
    DataMgr.roleData.allzoneSegment[zoneId][enum_SegmentType.solo] = segmentValue
  elseif attrType == struct_SegmentType.segment_type_double then
    DataMgr.roleData.allzoneSegment[zoneId][enum_SegmentType.double] = segmentValue
  elseif attrType == struct_SegmentType.segment_type_team then
    DataMgr.roleData.allzoneSegment[zoneId][enum_SegmentType.team] = segmentValue
  elseif attrType == struct_SegmentType.segment_type_fppsolo then
    DataMgr.roleData.allzoneSegment[zoneId][enum_SegmentType.fpp_solo] = segmentValue
  elseif attrType == struct_SegmentType.segment_type_fppdouble then
    DataMgr.roleData.allzoneSegment[zoneId][enum_SegmentType.fpp_double] = segmentValue
  elseif attrType == struct_SegmentType.segment_type_fppteam then
    DataMgr.roleData.allzoneSegment[zoneId][enum_SegmentType.fpp_team] = segmentValue
  end
end
function DataMgr.ShowMessageBoxByID(msgID)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  local content = LocUtil.GetLocalizeResStr(msgID)
  if content == "" then
    log(bWriteLog and "[v_wllwu] DataMgr.ShowMessageBoxByID return, msgID is:" .. tostring(msgID))
    return
  end
  CommonMsgBoxMgr.Show(1, LocUtil.GetLocalizeResStr(101001), content)
end
function DataMgr.GetItemStoreByItemId(nItemId)
  return DataMgr.item_store[nItemId] or 0
end
function DataMgr.SetItemStoreData(nItemId, nCount)
  DataMgr.item_store[nItemId] = nCount
end
function DataMgr.GetMsgByID(msgID)
  local msgConfig = LocUtil.GetLocalizeResStr(msgID)
  return msgConfig
end
function DataMgr.GetMultiLineMsgByID(msgID)
  local str = DataMgr.GetMsgByID(msgID)
  return str == nil and "" or string.gsub(str, "\\n", "\n")
end
function DataMgr.GetMsgByIDForBattleText(msgID)
  return DataMgr.GetMsgByID(msgID)
end
function DataMgr.GetFormatMsgByIDForBattleText(msgID, ...)
  local msgConfig = LocUtil.TryGetLocalizeResStr(msgID)
  if msgConfig == "" then
    return ""
  end
  local content = msgConfig
  for index = 1, select("#", ...) do
    content = string.StrReplace(content, "{" .. tostring(index - 1) .. "}", tostring(select(index, ...)))
  end
  return content
end
function DataMgr.GetFormatMsgByIDForBattleTextWithSAP(msgID, ...)
  return LocUtil.LocalizeResFormat(msgID, ...)
end
function DataMgr.GetVoiceDescByID(msgID)
  local msgConfig = CDataTable.GetTableData("VoiceText", msgID)
  if msgConfig == nil then
    return DataMgr.GetFormatMsgByIDForBattleText(msgID)
  end
  return msgConfig.VoiceTextValue
end
function DataMgr.GetPlayerFramePath(rankIntegral)
  local name = "Default"
  local rankIntegralCfg = FuncUtil.GetRankTableData(rankIntegral)
  if rankIntegralCfg then
    name = tostring(rankIntegralCfg.FrameID)
  end
  return string.format("/Game/Arts/UI/Item_Icon/AvatarFrames/Style1/AvatarFrame_%s.AvatarFrame_%s", name, name)
end
function DataMgr.GetSystemConfig(configName)
  local msgConfig = CDataTable.GetTableData("SystemConfig", configName)
  if msgConfig then
    return msgConfig.ConfigValue
  end
  return nil
end
function DataMgr.GetFPPOpenLevel()
  local msgConfig = CDataTable.GetTableData("SystemConfig", "FPPOpenLevel")
  if msgConfig then
    return msgConfig.ConfigValue
  end
  return nil
end
function DataMgr.GetDestinyModeOpenLevel()
  local msgConfig = CDataTable.GetTableData("SystemConfig", "DestinyModeOpenLevel")
  if msgConfig then
    return msgConfig.ConfigValue
  end
  return nil
end
function DataMgr.IsEmulator()
  log(bWriteLog and "InitRoleData isEmulator:" .. tostring(DataMgr.roleData.isEmulator))
  local result = false
  if DataMgr.roleData ~= nil and DataMgr.roleData.isEmulator ~= nil then
    result = DataMgr.roleData.isEmulator
  end
  return result
end
function DataMgr.IsBLE()
  return 0
end
function DataMgr.UpdateOfficerTrainingTaskList(data)
  log(bWriteLog and "DataMgr.UpdateOfficerTrainingTaskList, data = " .. tostring(data))
  for _, act in pairs(data) do
    for index, subTask in pairs(act.award) do
      DataMgr.OfficerTrainingData.taskList[subTask.idx] = {
        progress = subTask.num,
        sort = index
      }
    end
  end
end
function DataMgr.ChangeOfficerTrainingTaskData(lastIndex, newIndex, index)
  log(bWriteLog and "DataMgr.ChangeOfficerTrainingTaskData, index = " .. tostring(index))
  DataMgr.OfficerTrainingData.taskList[lastIndex] = nil
  DataMgr.OfficerTrainingData.taskList[newIndex] = {progress = 0, sort = index}
end
function DataMgr.UpdateTaskChange(isAll, task)
  log(bWriteLog and "DataMgr.UpdateTaskChange:" .. tostring(isAll))
  if task == nil then
    log_error("task can't be nil")
    return
  end
  if task.week_list then
    local WeekTaskSystem = require("client.slua.logic.task.logic_week_task")
    WeekTaskSystem.UpdateWeekTaskData(task.week_list, isAll)
  end
end
function DataMgr.UpdateCorpsAcitveNum(res, member_info)
  if res == nil then
    log_error("res can't be nil")
    return
  end
  if res ~= NetErrorCode_NONE then
    ShowNotice(res)
    return
  end
  DataMgr.corpsActiveness.value = member_info.member.week_active
  DataMgr.corpsActiveness.star = member_info.corp.chest_star
  DataMgr.corpsInfo.season_active = member_info.corp.season_active
  DataMgr.corpsInfo.week_active = member_info.corp.week_active
  DataMgr.corpsInfo.day_active = member_info.corp.day_active
  DataMgr.corpsInfo.day_exp = member_info.corp.day_exp
  DataMgr.corpsInfo.week_exp = member_info.corp.week_exp
  DataMgr.corpsInfo.exp = member_info.corp.exp
  DataMgr.corpsInfo.level = member_info.corp.level
  DataMgr.corpsInfo.selfMember.day_active = member_info.member.day_active
  DataMgr.corpsInfo.selfMember.week_active = member_info.member.week_active
  DataMgr.corpsInfo.selfMember.season_active = member_info.member.season_active
  EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_CORPS_ACTIVENESS_CHANGE)
end
function DataMgr.ResetLevelTaskData()
  DataMgr.levelTask = {
    list = {}
  }
end
function DataMgr.UpdateLevelTaskChange(isAll, levelTask)
  log(bWriteLog and "UpdateLevelTaskChange:" .. tostring(isAll))
  if levelTask == nil then
    return
  end
  if isAll == true then
    DataMgr.  else
    for level, taskInfo in pairs(levelTask.list) do
      DataMgr.levelTask.list[level] = taskInfo
    end
  end
  local LevelTaskRedPointData = require("client.slua.logic.task.level_task_reddot_data")
  LevelTaskRedPointData.UpdateRedDot()
  EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_LEVLE_TASK_CHANGE)
end
function DataMgr.TestProgress(taskId)
end
function DataMgr.InitWeekSignUpList(week_signup)
  if week_signup ~= nil then
    for i = 1, #week_signup.list do
      local wsStatus = week_signup.list[i]
      if wsStatus ~= nil then
        DataMgr.WeekSignUpInfo.AwardState[i] = wsStatus.status
        DataMgr.WeekSignUpInfo.UCAwardState[i] = wsStatus.uc_sign_status
      end
    end
    log(bWriteLog and "  :week_signup.uc_chg" .. tostring(week_signup.uc_chg))
    DataMgr.WeekSignUpInfo.weeklyUc = week_signup.uc_chg or 0
    DataMgr.WeekSignUpInfo.Resign_times = week_signup.resign_times
    DataMgr.WeekSignUpInfo.is_black_friday = week_signup.is_black_friday
    DataMgr.WeekSignUpInfo.page_link = week_signup.page_link
    local WeekSignManager = require("client.slua.logic.week_sign.logic_weeksign")
    WeekSignManager.SignInfoChange()
  else
    log_error("week_signup == nil")
  end
end
function DataMgr.UpdateWeekSignUpInfo(day, state)
  DataMgr.WeekSignUpInfo.AwardState[day] = state
  log(bWriteLog and "  : UpdateWeekSignUpInfo set AwardState " .. tostring(day) .. tostring(state))
end
function DataMgr.ResetWeekSignUpInfo()
  DataMgr.WeekSignUpInfo.Resign_times = 0
  DataMgr.WeekSignUpInfo.AwardState[1] = 1
  local itemCount = #DataMgr.WeekSignUpInfo.AwardState
  for i = 2, itemCount do
    DataMgr.WeekSignUpInfo.AwardState[i] = 0
  end
end
function DataMgr.UpdateShareAwardState(id, state)
  DataMgr.ShareAwardInfo.AwardState[id] = state
  local ShareAwardMgr = require("client.logic.share_award.logic_share_award")
  ShareAwardMgr.OnShareAwardInfoUpdate()
end
function DataMgr.UpdateShareChange(share_times)
  local TimeUtil = require("client.common.time_util")
  DataMgr.ShareAwardInfo.daily_share_time = TimeUtil.GetServerTimeInSec()
  DataMgr.ShareAwardInfo.  local ShareAwardMgr = require("client.logic.share_award.logic_share_award")
  ShareAwardMgr.OnShareAwardInfoUpdate()
end
function DataMgr.ResetBulletin()
  DataMgr.bulletin = {
    hashList = {},
    data = {}
  }
end
function DataMgr.UpdateCorpsTaskChange()
  local CorpsHandler = require("client.network.Protocol.CorpsHandler")
  CorpsHandler.send_get_corps_training_req()
  CorpsHandler.send_get_corps_task_req()
  local logic_corps_tab_mgr = require("client.slua.logic.corps.logic_corps_tab_mgr")
  logic_corps_tab_mgr.UpdateRedPoint()
  EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_TRAINING_STATUS)
end
function DataMgr.HasInstallPlatApp()
  local result = true
  if _G.BP_Platform == BP_ENUM_PLAYFORM_WX then
    if Client.IsInstallFaceBook(NetInterface) == false then
      result = false
    end
  elseif _G.BP_Platform == BP_ENUM_PLAYFORM_BGBG and Client.IsInstallWX(NetInterface) == false then
    result = false
  end
  return result
end
function DataMgr.GetMultiLineMsgByID(msgID)
  local str = DataMgr.GetMsgByID(msgID)
  return str == nil and "" or string.gsub(str, "\\n", "\n")
end
function DataMgr.resetMaxSegmentInfo()
  DataMgr.maxSegmentSolo.zoneid = 0
  DataMgr.maxSegmentSolo.SegmentLevel = 0
  DataMgr.maxSegmentDuo.zoneid = 0
  DataMgr.maxSegmentDuo.SegmentLevel = 0
  DataMgr.maxSegmentSquad.zoneid = 0
  DataMgr.maxSegmentSquad.SegmentLevel = 0
  DataMgr.maxSegmentSoloFpp.zoneid = 0
  DataMgr.maxSegmentSoloFpp.SegmentLevel = 0
  DataMgr.maxSegmentDuoFpp.zoneid = 0
  DataMgr.maxSegmentDuoFpp.SegmentLevel = 0
  DataMgr.maxSegmentSquadFpp.zoneid = 0
  DataMgr.maxSegmentSquadFpp.SegmentLevel = 0
  DataMgr.maxSegment.zoneid = 0
  DataMgr.maxSegment.segmentType = 0
  DataMgr.maxSegment.SegmentLevel = enum_SegmentType.solo
end
function DataMgr.GetMaxSegmentInfo(allzoneSegment)
  log_tree("allzoneSegment", allzoneSegment)
  local maxSegment = {
    zoneid = 0,
    segmentType = 0,
    SegmentLevel = enum_SegmentType.solo
  }
  if not allzoneSegment then
    log(bWriteLog and "DataMgr.GetMaxSegmentInfo not allzoneSegment")
    return maxSegment
  end
  for k, v in pairs(allzoneSegment) do
    for segmentType = enum_SegmentType.solo, enum_SegmentType.fpp_team do
      if maxSegment.SegmentLevel < (v[segmentType] or 0) then
        maxSegment.zoneid = k
        maxSegment.        maxSegment.SegmentLevel = v[segmentType]
      end
    end
  end
  return maxSegment
end
function DataMgr.fillMaxSegmentInfo()
  DataMgr.resetMaxSegmentInfo()
  local allzoneSegment = DataMgr.roleData.allzoneSegment
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if not allzoneSegment then
    return
  end
  if Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
    allzoneSegment = {
      [3] = allzoneSegment[3]
    }
  else
    local logic_multiple_area = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_multiple_area)
    if logic_multiple_area:IsConnectToRussiaArea() then
      allzoneSegment = {
        [2] = allzoneSegment[2]
      }
    end
  end
  for k, v in pairs(allzoneSegment) do
    if DataMgr.maxSegmentSolo.SegmentLevel < DataMgr.roleData.allzoneSegment[k][enum_SegmentType.solo] then
      DataMgr.maxSegmentSolo.zoneid = k
      DataMgr.maxSegmentSolo.SegmentLevel = DataMgr.roleData.allzoneSegment[k][enum_SegmentType.solo]
    end
    if DataMgr.maxSegmentDuo.SegmentLevel < DataMgr.roleData.allzoneSegment[k][enum_SegmentType.double] then
      DataMgr.maxSegmentDuo.zoneid = k
      DataMgr.maxSegmentDuo.SegmentLevel = DataMgr.roleData.allzoneSegment[k][enum_SegmentType.double]
    end
    if DataMgr.maxSegmentSquad.SegmentLevel < DataMgr.roleData.allzoneSegment[k][enum_SegmentType.team] then
      DataMgr.maxSegmentSquad.zoneid = k
      DataMgr.maxSegmentSquad.SegmentLevel = DataMgr.roleData.allzoneSegment[k][enum_SegmentType.team]
    end
    if DataMgr.maxSegmentSoloFpp.SegmentLevel < DataMgr.roleData.allzoneSegment[k][enum_SegmentType.fpp_solo] then
      DataMgr.maxSegmentSoloFpp.zoneid = k
      DataMgr.maxSegmentSoloFpp.SegmentLevel = DataMgr.roleData.allzoneSegment[k][enum_SegmentType.fpp_solo]
    end
    if DataMgr.maxSegmentDuoFpp.SegmentLevel < DataMgr.roleData.allzoneSegment[k][enum_SegmentType.fpp_double] then
      DataMgr.maxSegmentDuoFpp.zoneid = k
      DataMgr.maxSegmentDuoFpp.SegmentLevel = DataMgr.roleData.allzoneSegment[k][enum_SegmentType.fpp_double]
    end
    if DataMgr.maxSegmentSquadFpp.SegmentLevel < DataMgr.roleData.allzoneSegment[k][enum_SegmentType.fpp_team] then
      DataMgr.maxSegmentSquadFpp.zoneid = k
      DataMgr.maxSegmentSquadFpp.SegmentLevel = DataMgr.roleData.allzoneSegment[k][enum_SegmentType.fpp_team]
    end
    for segmentType = enum_SegmentType.solo, enum_SegmentType.fpp_team do
      if DataMgr.maxSegment.SegmentLevel < DataMgr.roleData.allzoneSegment[k][segmentType] then
        DataMgr.maxSegment.zoneid = k
        DataMgr.maxSegment.        DataMgr.maxSegment.SegmentLevel = DataMgr.roleData.allzoneSegment[k][segmentType]
      end
    end
  end
end
function DataMgr.InitRoomCardInfo(room_card_info_all)
  local CreateRoomConfig = require("client.slua.logic.room.config_create_room")
  if not CreateRoomConfig or not CreateRoomConfig.C_RoomCardInfo then
    log_error("DataMgr.InitRoomCardInfo can not load config_create_room")
    return
  end
  for k, v in pairs(CreateRoomConfig.C_RoomCardInfo) do
    DataMgr.UpdateRoomCardInfoForType(room_card_info_all[k], k, v)
  end
end
function DataMgr.UpdateRoomCardInfoForType(room_card_info, room_card_type, client_name)
  if not room_card_type then
    return
  end
  if not client_name then
    local CreateRoomConfig = require("client.slua.logic.room.config_create_room")
    if not CreateRoomConfig or not CreateRoomConfig.C_RoomCardInfo then
      log_error("DataMgr.InitRoomCardInfo can not load config_create_room")
      return
    end
    client_name = CreateRoomConfig.C_RoomCardInfo[room_card_type]
  end
  if not client_name then
    return
  end
  DataMgr[client_name] = {expire_ts = 0, rest_times = 0}
  if not room_card_info then
    return
  end
  DataMgr[client_name].expire_ts = room_card_info.expire_ts
  DataMgr[client_name].rest_times = room_card_info.rest_times
end
function DataMgr.sync_room_card_info(card_type, room_card_info, item_id)
  local TimeUtil = require("client.common.time_util")
  local dataExpireTs = 0
  if card_type == nil then
    log_error("DataMgr.sync_room_card_info get nil type")
    return
  else
    DataMgr.UpdateRoomCardInfoForType(room_card_info, card_type)
  end
  local msg = ""
  if item_id ~= 0 then
    local itemData = CDataTable.GetTableData("Item", item_id)
    dataExpireTs = DataMgr.room_card_info.expire_ts
    if itemData.ItemSubType == 2103 or itemData.ItemSubType == 2106 or itemData.ItemSubType == 2109 then
      local remainTime = dataExpireTs - TimeUtil.GetServerTimeInSec()
      msg = 0 <= dataExpireTs and LocUtil.LocalizeResFormat("9910124", TimeUtil.FormatCountDownTime_DH_or_HM(remainTime, true)) or LocUtil.GetLocalizeResStr("5012")
    elseif itemData.ItemSubType == 2104 or itemData.ItemSubType == 2107 then
      msg = 0 <= dataExpireTs and LocUtil.LocalizeResFormat("9910125", DataMgr.room_card_info.rest_times) or LocUtil.GetLocalizeResStr("5012")
    elseif itemData.ItemSubType == 2105 or itemData.ItemSubType == 2108 then
      msg = LocUtil.GetLocalizeResStr("5012")
    end
  end
  if msg ~= "" then
    ShowNotice(msg)
  end
end
function DataMgr.sync_room_adv_card_info(room_card_info, item_id)
  local TimeUtil = require("client.common.time_util")
  log_tree("sync_room_card_info_adv card = ", room_card_info)
  log_tree("sync_room_card_info_adv item = ", item_id)
  DataMgr.UpdateRoomCardInfoForType(room_card_info, "advanced")
  local msg = ""
  if item_id ~= 0 then
    local itemData = CDataTable.GetTableData("Item", item_id)
    local dataExpireTs = DataMgr.room_card_info_adv.expire_ts
    if itemData.ItemSubType == 2106 then
      local remainTime = dataExpireTs - TimeUtil.GetServerTimeInSec()
      msg = 0 <= dataExpireTs and LocUtil.LocalizeResFormat("9910124", TimeUtil.FormatCountDownTime_DH_or_HM(remainTime, true)) or LocUtil.GetLocalizeResStr("5012")
    elseif itemData.ItemSubType == 2107 then
      msg = 0 <= dataExpireTs and LocUtil.LocalizeResFormat("9910125", DataMgr.room_card_info_adv.rest_times) or LocUtil.GetLocalizeResStr("5012")
    elseif itemData.ItemSubType == 2108 then
      msg = LocUtil.GetLocalizeResStr("5012")
    end
  end
  if msg ~= "" then
    ShowNotice(msg)
  end
end
function DataMgr.sync_motion_info_req(isWaitting)
  local DataMgrHandler = require("client.network.Protocol.DataMgrHandler")
  DataMgrHandler.send_sync_motion_info_req()
end
function DataMgr.sync_motion_info(motion_info, limit)
  DataMgr.InitMotionInfo(motion_info, limit)
  EventSystem:postEvent(EVENTTYPE_MOTION, EVENTID_MOTION_UPDATE_SLOT_LIST)
end
function DataMgr.InitMotionInfo(motion_info, limit)
  local logic_achievement_float_tip = require("client.slua.logic.achievement.logic_achievement_float_tip")
  log(bWriteLog and "DataMgr.InitMotionInfo limit " .. tostring(limit))
  DataMgr.MotionSlotMax = 0
  DataMgr.MotionSlotList = {}
  if motion_info then
    log(bWriteLog and "DataMgr.is_follow_leader" .. tostring(motion_info.is_follow_leader))
    DataMgr.is_follow_leader = motion_info.is_follow_leader
    DataMgr.show_effect = motion_info.show_effect or false
    DataMgr.motion_effect_level = motion_info.motion_effect_level or {}
    DataMgr.MotionSlotMax = limit or 0
    for i = 1, motion_info.curr_count or 0 do
      table.insert(DataMgr.MotionSlotList, motion_info.motion_slot_list[i] or 0)
    end
    log(bWriteLog and "[ParticleEmote] DataMgr show_effect " .. tostring(DataMgr.show_effect))
    log_tree("[ParticleEmote] DataMgr motion_effect_level", DataMgr.motion_effect_level)
  end
  logic_achievement_float_tip.firstInitialize = true
end
function DataMgr.GetMotionItemDatas()
  local result = {}
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  for i, v in ipairs(DataMgr.MotionSlotList) do
    local itemData = wardrobe_data:GetValidHallDepotItemDataByInsID(v)
    if itemData then
      table.insert(result, itemData)
    end
  end
  return result
end
function DataMgr.InitVehicleInfo(vehicle_info, vst_skin)
  log(bWriteLog and "DataMgr.InitVehicleInfo DataMgr.vst_skin" .. tostring(vst_skin))
  log_tree("DataMgr.InitVehicleInfo DataMgr.VehicleSlotList", vehicle_info)
  DataMgr.VehicleSlotList = vehicle_info or {}
  DataMgr.end
function DataMgr.InitWeaponData(weapon_id, skin_resID, skin_insID)
  log(bWriteLog and "[edward][data_mgr] DataMgr.InitWeaponData, weapon_id = " .. tostring(weapon_id) .. "skin_resID: " .. tostring(skin_resID) .. ", skin_insID = " .. tostring(skin_insID))
  DataMgr.Weapon_ID = weapon_id or 0
  DataMgr.Weapon_Skin_ResID = skin_resID or 0
  DataMgr.Weapon_Skin_InsID = skin_insID or 0
  local logic_wardrobe_gun = require("client.slua.logic.wardrobe.logic_wardrobe_gun")
  logic_wardrobe_gun:SetIsPutOnGun(DataMgr.Weapon_ID ~= 0)
  if DataMgr.Weapon_ID > 0 and DataMgr.Weapon_ID ~= 108005 and logic_wardrobe_gun:IsMeleeWeapon(DataMgr.Weapon_ID) then
    local logic_legend_weapon = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_legend_weapon)
    if logic_legend_weapon and not logic_legend_weapon:IsLegendWeaponItem(DataMgr.Weapon_ID) then
      logic_legend_weapon:SetSceneLobbyOff()
    end
  end
end
function DataMgr.InitWeaponDIYData(isUsingRecommend, planID)
  log(bWriteLog and "[edward][data_mgr] DataMgr.InitWeaponDIYData, isUsingRecommend = " .. tostring(isUsingRecommend) .. ", planID = " .. tostring(planID))
  DataMgr.Weapon_Diy_Using_Recommend = isUsingRecommend or false
  DataMgr.Weapon_Diy_PlanID = planID
end
function DataMgr.InitExtraWeaponList(extra_weapon_list)
  log_tree("[tinghaohu][data_mgr] DataMgr.InitExtraWeaponList, extra_weapon_list = ", extra_weapon_list)
  DataMgr.Extra_Weapon_Info_List = extra_weapon_list or {}
end
function DataMgr.GetCurrentWeaponID()
  if DataMgr.Weapon_ID == 0 then
    return 0
  end
  local weaponID = DataMgr.Weapon_ID
  local isDiy = false
  local isRecommend = false
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemData = wardrobe_data:GetValidHallDepotItemDataByInsID(DataMgr.Weapon_Skin_InsID)
  if not itemData then
    itemData = wardrobe_data:GetAllHallDepotItemDataByResID(tonumber(DataMgr.Weapon_Skin_ResID))
    if (DataMgr.Weapon_Skin_InsID == nil or DataMgr.Weapon_Skin_InsID == 0) and itemData and itemData.insID then
      DataMgr.InitWeaponData(DataMgr.Weapon_ID, DataMgr.Weapon_Skin_ResID, itemData.insID)
    end
  end
  if itemData then
    weaponID = itemData.resID
    if DataMgr.Weapon_Diy_Using_Recommend then
      isDiy = true
      isRecommend = true
    elseif DataMgr.Weapon_Diy_PlanID and DataMgr.Weapon_Diy_PlanID ~= "" then
      local WeaponDiySystem = require("client.slua.logic.weapon_diy.logic_weapon_diy")
      if WeaponDiySystem:IsWeaponDIYPlanIDMatchGivenWeaponSkinID(weaponID, DataMgr.Weapon_Diy_PlanID) then
        if WeaponDiySystem:IsPlanRecommend(DataMgr.Weapon_Diy_PlanID) then
          isRecommend = true
        end
        isDiy = true
      end
    end
  end
  if not LobbySystem.CheckOpen(BP_ENUM_WARDROBE_UI_WEAPON) then
    weaponID = 0
  elseif LobbySystem.IsNeedShowLogError(BP_ENUM_WARDROBE_UI_WEAPON) then
    log_error("error BP_ENUM_WARDROBE_UI_WEAPON is nil")
  end
  weaponID = tonumber(weaponID)
  return weaponID, isDiy, isRecommend
end
function DataMgr.GerExtraWeaponID(weaponId, skinId, isUsingRecommend, curDiyPlan)
  if weaponId == 0 then
    return 0
  end
  local isRecommend = false
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemData = wardrobe_data:GetValidHallDepotItemDataByInsID(skinId)
  itemData = itemData or wardrobe_data:GetHallDepotItemDataByResID(tonumber(skinId))
  if itemData then
    weaponId = itemData.resID
    if isUsingRecommend then
      isRecommend = true
    elseif curDiyPlan and curDiyPlan ~= "" then
      local WeaponDiySystem = require("client.slua.logic.weapon_diy.logic_weapon_diy")
      if WeaponDiySystem:IsWeaponDIYPlanIDMatchGivenWeaponSkinID(weaponId, curDiyPlan) and WeaponDiySystem:IsPlanRecommend(curDiyPlan) then
        isRecommend = true
      end
    end
  end
  if not LobbySystem.CheckOpen(BP_ENUM_WARDROBE_UI_WEAPON) then
    weaponId = 0
  elseif LobbySystem.IsNeedShowLogError(BP_ENUM_WARDROBE_UI_WEAPON) then
    log_error("error BP_ENUM_WARDROBE_UI_WEAPON is nil")
  end
  weaponId = tonumber(weaponId)
  return weaponId, isRecommend
end
function DataMgr.GetHeadShowItemResID(resID)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local insID = DataMgr.equipmentSkinInsIDTable[DataMgr.HelmetSkinTableIndex]
  local itemCfg = wardrobe_data:GetHallDepotItemDataByInsID(insID)
  if itemCfg ~= nil then
    if itemCfg.res_id == resID then
      log(bWriteLog and "Current HeadShow is Helment, resID is " .. resID)
      return resID
    else
      log(bWriteLog and "Current HeadShow is Hat")
      return 0
    end
  else
    return 0
  end
end
function DataMgr.GetEquipmentResID(subType)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemCfg = wardrobe_data:GetHallDepotItemDataByInsID(DataMgr.equipmentSkinInsIDTable[subType])
  if itemCfg then
    log(bWriteLog and "itemCfg.res_id" .. itemCfg.resID)
    return itemCfg.resID
  end
  return 0
end
function DataMgr.GetEquipmentItemIDByResID(level, itemResID)
  print(bWriteLog and "GetEquipmentItemIDByResID")
  print(bWriteLog and "level: ", level)
  print(bWriteLog and "itemResID: ", itemResID)
  local itemMappingCfg = CDataTable.GetTableData("BackpackMapping", itemResID)
  if itemMappingCfg ~= nil then
    if level == 1 then
      return itemMappingCfg.SkinItemIDLv1
    elseif level == 2 then
      return itemMappingCfg.SkinItemIDLv2
    elseif level == 3 then
      return itemMappingCfg.SkinItemIDLv3
    end
  end
  return 0
end
function DataMgr.InitJPAgeInfo(jp_age)
  if jp_age ~= nil then
    log(bWriteLog and "IDataMgr.InitJPAgeInfo jp_age=" .. tostring(jp_age))
    DataMgr.  else
    log(bWriteLog and "IDataMgr.InitJPAgeInfo jp_age=nil")
    DataMgr.jp_age = nil
  end
end
function DataMgr.IsEnableWatch()
  return DataMgr.roleData.enableWatch
end
function DataMgr.SetEnableWatch(enable)
  DataMgr.roleData.enableWatch = enable
end
function DataMgr.SetCanWatchBaseInfoIngame(canWatch)
  DataMgr.roleData.watch_privacy = canWatch
end
function DataMgr.IsCanWatchBaseInfoIngame()
  return DataMgr.roleData.watch_privacy
end
function DataMgr.GetCanWatchInvite()
  return DataMgr.roleData.enable_watch_remind
end
function DataMgr.SetNewbieGuide(module_id, key)
  log(bWriteLog and "DataMgr.SetNewbieGuide module_id:" .. module_id .. "  key:" .. key)
  if DataMgr.newbieGuide[module_id] == nil then
    DataMgr.newbieGuide[module_id] = {}
  end
  DataMgr.newbieGuide[module_id][key] = 1
  local DataMgrHandler = require("client.network.Protocol.DataMgrHandler")
  DataMgrHandler.send_set_newbie_guide_req(module_id, key, 1)
end
function DataMgr.HaveNewbieGuide(module_id, key)
  if DataMgr.newbieGuide[module_id] ~= nil then
    local tempModule = DataMgr.newbieGuide[module_id]
    if tempModule[key] ~= nil and tempModule[key] == 1 then
      return false
    else
      return true
    end
  else
    return true
  end
end
function DataMgr.SetNewbieGuideValue(module_id, key, val)
  log(bWriteLog and "DataMgr.SetNewbieGuide module_id:" .. module_id .. "  key:" .. key .. "   ,val =" .. tostring(val))
  if DataMgr.newbieGuide[module_id] == nil then
    DataMgr.newbieGuide[module_id] = {}
  end
  DataMgr.newbieGuide[module_id][key] = val
  local DataMgrHandler = require("client.network.Protocol.DataMgrHandler")
  DataMgrHandler.send_set_newbie_guide_req(module_id, key, val)
end
function DataMgr.GetNewbieGuideValue(module_id, key)
  if DataMgr.newbieGuide[module_id] ~= nil then
    local tempModule = DataMgr.newbieGuide[module_id]
    if tempModule[key] ~= nil then
      return tempModule[key]
    end
  end
  return nil
end
function DataMgr.on_get_newbie_guide_rsp(err_code, newbie_guide)
  log(bWriteLog and "DataMgr.on_get_newbie_guide_rsp err_code: " .. err_code)
  if err_code == 0 then
    log_tree("newbie_guide", newbie_guide)
    DataMgr.newbieGuide = newbie_guide
    EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_UPDATE_NEWBIE_STATUS)
  end
  LobbySystem.UpdateLobbyNewbieState()
end
function DataMgr.on_set_newbie_guide_rsp(err_code, module_id, key, value)
  log(bWriteLog and "DataMgr.on_set_newbie_guide_rsp err_code: " .. err_code)
  if err_code == 0 then
    log_tree("DataMgr.on_set_newbie_guide_rsp", {
      id = module_id,
      key = key,
          })
    local localValue = DataMgr.GetNewbieGuideValue(module_id, key)
    if localValue ~= value then
      log_error("DataMgr.on_set_newbie_guide_rsp data value is not match. local value:" .. tostring(localValue))
    end
    local tempModule = DataMgr.newbieGuide[module_id]
    if tempModule ~= nil then
      tempModule[key] = value
    else
      tempModule = {}
      tempModule[key] = value
      DataMgr.newbieGuide[module_id] = tempModule
    end
    log_tree("DataMgr.newbieGuide", DataMgr.newbieGuide)
    EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_UPDATE_NEWBIE_STATUS)
  end
end
function DataMgr.sync_match_param(lang, cross_time, cross_max_ping, zoneList, jpkr, match_strategy, krjp_asia)
  log(bWriteLog and "[YY]sync_match_param==jpkr==" .. tostring(jpkr))
  local NetManager = require("client.network.comm.NetManager")
  if NetManager.bIsMuteMsgForReLogin and GameStatus.IsInFightingNotSocialNotMainCityNotHome() then
    return
  end
  log_tree("[DataMgr]jpkr", krjp_asia)
  DataMgr.MatchLanguage = lang
  local LanguageSelectSystem = require("client.logic.language_select.logic__language_select")
  LanguageSelectSystem.OnSyncFirstMatchLanguage()
  if krjp_asia and type(krjp_asia) == "table" then
    DataMgr.JPKRMatchServerOn = krjp_asia.switch_to_asia
  end
  if match_strategy then
    DataMgr.MatchStrategy = match_strategy
  end
  local MatchSystem = require("client.slua.logic.match.logic_match")
  MatchSystem.SetCrossMatchParam(cross_time, cross_max_ping, zoneList, krjp_asia)
end
function DataMgr.carteam_coin_count_notify_chg(value, cur_carteam_coin_count, reason)
  log(bWriteLog and "DataMgr.carteam_coin_count_notify_chg: " .. tostring(value) .. " " .. tostring(cur_carteam_coin_count) .. "  " .. tostring(reason))
  DataMgr.carteam_coin_count = cur_carteam_coin_count
end
function DataMgr.SyncRegionData(data, regionList)
  log_tree("DataMgr.SyncRegionData, regionData = ", data)
  log_tree("DataMgr.SyncRegionData, regionList = ", regionList)
  local regionData = {
    region = data.region,
    setTime = data.set_time,
    setCount = data.set_cnt or 0,
    setCD = data.set_cd,
    setNextCD = data.set_cd_next,
    setRegionList = {}
  }
  for i, v in ipairs(regionList) do
    local info = {
      region = v,
      isCommon = v == regionData.region
    }
    table.insert(regionData.setRegionList, info)
  end
  DataMgr.RegionData = regionData
  local PufferNetManager = require("client.slua.logic.download.network.logic_puffer_netmanager")
  PufferNetManager.SetRegionReserveSpeed()
  Client.SetAccountRegion(DataMgr.RegionData.region or "")
  local NetManager = require("client.network.comm.NetManager")
  if NetManager.bIsMuteMsgForReLogin and GameStatus.IsInFightingNotSocialNotMainCityNotHome() then
    return
  end
  EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SET_REGION_OK)
  local logic_pubgm_music = require("client.slua.logic.pubgm_music.logic_pubgm_music")
  logic_pubgm_music.SetCurRegionCode(data.region)
  local musicManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.music_manager)
  musicManager:IsBlackWithRegionAndPath(nil, nil, true)
  local HostedProtoBridge = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.HostedProtoBridge)
  HostedProtoBridge:SendRegion()
end
function DataMgr.ResetRegion()
  DataMgr.RegionData = {}
end
function DataMgr.CheckIsNeedUSAPolicy()
  local AccountRegionForBPMacros = require("client.slua.config.ClientMacros.AccountRegionForBPMacros")
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  return (PublishRegionMacros.IsGlobalVersion() or Client.GetPublishRegion() == PublishRegionMacros.FITCE) and (FuncUtil.GetAccountRegionForBP() == AccountRegionForBPMacros.US or DataMgr.CheckIsHaveRegionIp(AccountRegionForBPMacros.US))
end
function DataMgr.CheckIsHaveRegionIp(region)
  if DataMgr.RegionData and DataMgr.RegionData.setRegionList then
    for i, v in pairs(DataMgr.RegionData.setRegionList) do
      if v.region == region then
        return true
      end
    end
  end
  return false
end
function DataMgr.GetNameFrame(id)
  return DataMgr.roleData.nameFrameData[id]
end
function DataMgr.UseNameFrame(id)
  if not DataMgr.roleData.nameFrameData[id] then
    log_error("[edward][data_mgr] UseNameFrame error id, id = " .. id)
    return
  end
  DataMgr.roleData.nameFrameData[id].is_used = 1
end
function DataMgr.ResetNameFrame()
  for k, v in pairs(DataMgr.roleData.nameFrameData) do
    DataMgr.roleData.nameFrameData[k].is_used = 0
  end
end
function DataMgr.InitRoleSetting(roleSetting)
  log_tree("DataMgr.InitRoleSetting roleSetting", roleSetting)
  DataMgr.ResetRoleSetting()
  if roleSetting ~= nil then
    for k, v in pairs(roleSetting) do
      DataMgr.SetRoleSetting(k, v)
    end
  else
    log(bWriteLog and "DataMgr.InitRoleSetting roleSetting is nil")
  end
end
function DataMgr.SendSettingReq_Bool(isNeedWaiting, settingKey, settingValue)
  log(bWriteLog and "DataMgr.SendSettingReq")
  DataMgr.SendSettingReq(isNeedWaiting, settingKey, settingValue and 0 or 1)
end
function DataMgr.SendSettingReq(isNeedWaiting, settingKey, settingValue)
  if settingValue ~= 0 and settingValue ~= 1 then
    log(bWriteLog and "DataMgr.SendSettingReq settingValue invalid")
    return
  end
  if isNeedWaiting then
    local DataMgrHandler = require("client.network.Protocol.DataMgrHandler")
    DataMgrHandler.send_set_role_setting_req(settingKey, settingValue)
    log(bWriteLog and "DataMgr.SendSettingReq settingValue isNeedWaiting true")
  else
    local DataMgrHandler = require("client.network.Protocol.DataMgrHandler")
    DataMgrHandler.send_set_role_setting_req(settingKey, settingValue)
    log(bWriteLog and "DataMgr.SendSettingReq settingValue isNeedWaiting false")
  end
end
function DataMgr.ResetRoleSetting()
  DataMgr.roleData.role_setting = {}
end
function DataMgr.SetRoleSetting(settingKey, settingValue)
  log(bWriteLog and "DataMgr.SendSettingReq settingKey " .. tostring(settingKey) .. ", settingValue" .. tostring(settingValue))
  DataMgr.roleData.role_setting[settingKey] = settingValue
  if RoleSettingVar[settingKey] ~= nil then
    DataMgr.roleData[RoleSettingVar[settingKey]] = settingValue == 0
  end
end
function DataMgr.OnRoleSetting(res, settingKey, settingValue)
  log(bWriteLog and "DataMgr.OnRoleSetting res " .. res)
  log(bWriteLog and "DataMgr.OnRoleSetting settingKey " .. tostring(settingKey) .. ", settingValue" .. tostring(settingValue))
  if res == NetErrorCode_NONE then
    DataMgr.SetRoleSetting(settingKey, settingValue)
  end
end
function DataMgr.GetRoleSetting(settingKey)
  log(bWriteLog and "DataMgr.GetRoleSetting settingKey " .. tostring(settingKey))
  log(bWriteLog and "DataMgr.GetRoleSetting value " .. tostring(DataMgr.roleData.role_setting[settingKey]))
  return DataMgr.roleData.role_setting[settingKey] or 0
end
function DataMgr.SendSwitchRoleSetting(settingKey)
  local curValue = DataMgr.GetRoleSetting(settingKey)
  if curValue == 0 then
    DataMgr.SendSettingReq(true, settingKey, 1)
  else
    DataMgr.SendSettingReq(true, settingKey, 0)
  end
end
function DataMgr.IsMoneyEnough(money_type, money_price)
  local MallSystem = require("client.logic.mall.logic_mall")
  if not money_price then
    log(bWriteLog and string.format("DataMgr.IsMoneyEnough money_price is nil."))
    return false
  end
  local itemID
  if money_type == StoreConst.label_price_type_bp then
    if money_price > DataMgr.gold then
      return false
    end
    return true
  elseif money_type == StoreConst.label_price_type_chip then
    if money_price > DataMgr.diamond then
      return false
    end
    return true
  elseif money_type == StoreConst.label_price_type_uc then
    if money_price > DataMgr.ticket then
      return false
    end
    return true
  elseif money_type == StoreConst.label_price_type_fp then
    itemID = 1101
  elseif money_type == StoreConst.label_price_type_gold_chip then
    itemID = 1104
  elseif money_type == StoreConst.label_price_type_battle then
    itemID = 1103
  end
  if itemID then
    local count = MallSystem.GetItemCountInBag(itemID)
    if money_price > count then
      return false
    end
    return true
  end
  return false
end
function DataMgr.ShouldSlapZoneNotice()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local season_id = tonumber(DataMgr.season_id)
  local info = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eLoginDialog)
  if season_id < 16 or info and info.HasShow or DataMgr.registertime and DataMgr.registertime <= 1633839284 then
    return false
  end
  return true
end
function DataMgr.CheckTouristDialog()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local season_id = tonumber(DataMgr.season_id)
  local info = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eLoginDialog)
  log(bWriteLog and "CheckTouristDialog" .. tostring(season_id) .. " regist=" .. tostring(DataMgr.registertime))
  if season_id < 16 or info and info.HasShow or DataMgr.registertime and DataMgr.registertime <= 1633839284 then
  else
    local str = LocUtil.LocalizeResFormat(101001)
    local tip = ""
    if GlobalData.IsPlatformTourist() then
      tip = LocUtil.LocalizeResFormat(22105)
    else
      local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
      local logic_multiple_area = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_multiple_area)
      local server_name = logic_multiple_area:GetDisplayNameByZoneID(ZoneSystem.nChooseZoneID)
      if server_name == "" then
        server_name = LocUtil.GetLocalizeResStr("4089")
      end
      tip = LocUtil.LocalizeResFormat(22004, server_name)
    end
    local ui_show_queue_config = require("client.common.uibase.ui_show_queue_config")
    local ParamTable = ui_show_queue_config.GetParamTable(nil, "IsSlapUI")
    local extraData = {ParamTable = ParamTable}
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(1, str, tip, nil, nil, nil, nil, extraData)
    info = {}
    info.HasShow = true
    PlayerPrefsSystem.SaveTableToFile_N(info, PlayerPrefsSystem.ePlayerPrefsType.eLoginDialog)
  end
end
function DataMgr.GetMoneyByType(money_type)
  local MallSystem = require("client.logic.mall.logic_mall")
  local itemID
  if money_type == StoreConst.label_price_type_bp then
    return DataMgr.gold
  elseif money_type == StoreConst.label_price_type_chip then
    return DataMgr.diamond
  elseif money_type == StoreConst.label_price_type_uc then
    return DataMgr.ticket
  elseif money_type == StoreConst.label_price_type_diamond then
    return DataMgr.eternal_diamond
  elseif money_type == StoreConst.label_price_type_fp then
    return DataMgr.fp_token
  elseif money_type == StoreConst.label_price_type_gold_chip then
    return DataMgr.gold_chip
  elseif money_type == StoreConst.label_price_type_battle then
    return DataMgr.battle_coin
  end
  if itemID then
    local count = MallSystem.GetItemCountInBag(itemID)
    return count
  end
  return 0
end
function DataMgr.IsMe(UID)
  if tonumber(DataMgr.roleData.uid) == UID then
    return true
  else
    return false
  end
end
function DataMgr.GetModeName(sub_mode)
  local logic_mode_utils = require("client.slua.logic.mode_selection.logic_mode_utils")
  return logic_mode_utils.GetModeNameByModeID(sub_mode)
end
function DataMgr.UpdateSinkRankData(sink_rank_data, sink_segment)
  if sink_rank_data then
    DataMgr.roleData.  end
  if sink_segment then
  end
end
function DataMgr.IsRecruit()
  local nRegisterTime = DataMgr.registertime or 0
  if nRegisterTime == 0 then
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local tDateTable = TimeUtil.GetDateByUnixTime(nRegisterTime)
  if next(tDateTable) then
    nRegisterTime = nRegisterTime - tDateTable.hour * 3600 - tDateTable.min * 60 - tDateTable.sec
  end
  local nCurTime = TimeUtil.GetServerTimeInSec()
  if 1209599 < nCurTime - nRegisterTime then
    return false
  end
  return true
end
local _UpdateSelfProfileInfo = function(roleDataStr, profileStr)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(DataMgr.roleData.uid)
  if not profile then
    return
  end
  profileStr = profileStr or roleDataStr
  profile[profileStr] = DataMgr.roleData[roleDataStr]
  log(bWriteLog and "[v_wllwu] _UpdateSelfProfileInfo, roleDataStr is:" .. tostring(roleDataStr) .. ", profileStr is:" .. tostring(profileStr) .. ", data is:" .. tostring(profile[profileStr]))
end
function DataMgr.UpdateLevel(level)
  DataMgr.roleData.  _UpdateSelfProfileInfo("level")
end
function DataMgr.UpdateNickName(nickName)
  DataMgr.roleData.  _UpdateSelfProfileInfo("nickName")
end
function DataMgr.UpdateHeadIconUrl(headIconUrl)
  DataMgr.roleData.  if string.find(DataMgr.roleData.headIconUrl, "twimg") ~= nil then
    DataMgr.roleData.headIconUrl = string.gsub(DataMgr.roleData.headIconUrl, "_normal", "_bigger")
    log(bWriteLog and "DataMgr.UpdateHeadIconUrl = " .. tostring(DataMgr.roleData.headIconUrl))
  end
  _UpdateSelfProfileInfo("headIconUrl", "picUrl")
end
function DataMgr.UpdateAvatarBoxId(avatar_box_id)
  DataMgr.roleData.cur_  _UpdateSelfProfileInfo("cur_avatar_box_id")
end
require("client.logic.gm.RequireBlackList")
function DataMgr.SetSManager(open)
  canShowSManager = open
  log_shipping_client("DataMgr.SetSManager. open: " .. tostring(open))
  EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_GM_STATE_UPDATE)
end
local GetCanShowSuperManager = function()
  return canShowSManager
end
function DataMgr.GetBSManager()
  return GetCanShowSuperManager()
end
function DataMgr.GetWeaponSkinSoundSwitchInfo(groupID)
  local Flag = DataMgr.roleData.item_upgrade_switch_info[groupID]
  return Flag
end
function DataMgr.IsWeaponAvatarFeatureSwitchOn(flag, featureSwitchType, bCheckSelfOnly)
  local AvatarUtil = require("GameLua.Mod.Library.GamePlay.Avatar.AvatarUtil")
  return AvatarUtil.IsWeaponAvatarFeatureSwitchOn(flag, featureSwitchType, bCheckSelfOnly)
end
function DataMgr.IsWeaponSkinFeatureSwitchOn(groupID, featureSwitchType, bCheckSelfOnly)
  local flag = DataMgr.roleData.item_upgrade_switch_info[groupID]
  return DataMgr.IsWeaponAvatarFeatureSwitchOn(flag, featureSwitchType, bCheckSelfOnly)
end
function DataMgr.UpdateWeaponSkinSoundSwitchInfo(instid, flag, groupID)
  DataMgr.roleData.item_upgrade_switch_info[groupID] = flag
  EventSystem:postEvent(EVENTTYPE_ITEM_UPGRADE, EVENTID_ITEM_UPGRADE_AUDIO_SWITCH_INFO_UPDATE, instid, flag, groupID)
end
function DataMgr.SetWeaponSkinSoundSwitchInfo(instid, flag, groupID)
  local CurFlag = DataMgr.roleData.item_upgrade_switch_info[groupID]
  if CurFlag == flag then
    return
  end
  local ItemUpGradeHandler = require("client.network.Protocol.ItemUpGradeHandler")
  ItemUpGradeHandler.send_set_item_upgrade_switch_info_req(instid, flag)
end
function DataMgr.GetWeaponSkinSoundVolumeInfo(groupID, audio_type)
  if not DataMgr.roleData.weapon_audio_volume_info then
    return nil
  end
  if DataMgr.roleData.weapon_audio_volume_info[groupID] and DataMgr.roleData.weapon_audio_volume_info[groupID][audio_type] then
    return DataMgr.roleData.weapon_audio_volume_info[groupID][audio_type]
  end
  return nil
end
function DataMgr.GetWeaponSkinSoundVolumeInfoByGroup(groupID)
  if not DataMgr.roleData.weapon_audio_volume_info then
    print(bWriteLog and "DataMgr.GetWeaponSkinSoundVolumeInfoByGroup - weapon_audio_volume_info is nil")
    return nil
  end
  return DataMgr.roleData.weapon_audio_volume_info[groupID]
end
function DataMgr.UpdateWeaponSkinSoundVolumeInfo(instid, audio_type, volume, groupID)
  if not DataMgr.roleData.weapon_audio_volume_info then
    DataMgr.roleData.weapon_audio_volume_info = {}
  end
  if not DataMgr.roleData.weapon_audio_volume_info[groupID] then
    DataMgr.roleData.weapon_audio_volume_info[groupID] = {}
  end
  DataMgr.roleData.weapon_audio_volume_info[groupID][audio_type] = volume
end
function DataMgr.SetWeaponSkinSoundVolumeInfo(instid, audio_type, volume, groupID)
  local ItemUpGradeHandler = require("client.network.Protocol.ItemUpGradeHandler")
  ItemUpGradeHandler.send_set_weapon_audio_volume_req(instid, audio_type, volume)
end
function DataMgr.UpdateWeaponUpgradePartsSwitch(gun_type, part_type, switch_flag)
  local partsSwitch = DataMgr.roleData.gun_upgrade_parts_switch and DataMgr.roleData.gun_upgrade_parts_switch.parts_shield
  if not partsSwitch then
    return
  end
  if partsSwitch[gun_type] then
    partsSwitch[gun_type][part_type] = switch_flag
  else
    partsSwitch[gun_type] = {}
    partsSwitch[gun_type][part_type] = switch_flag
  end
end
function DataMgr.IsSelf(uid)
  return tostring(uid) == tostring(DataMgr.roleData.uid)
end
function DataMgr.GetPlayerType()
  return DataMgr_PlayerType.Normal
end
return DataMgr