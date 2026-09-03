require("client.slua.config.tlog.TLogEventDefine")
local Config_UGC_Center = {MissionAwardMaxNum = 4}
local _TabID = {
  CreatorsGrow = 1,
  School = 2,
  DataCenter = 3,
  Wallet = 4,
  IncentivePlan = 5,
  Home = 6,
  BenchmarkAuthor = 7,
  OfficialStory = 8,
  Video = 201,
  Challenge = 202,
  Overview = 301,
  Mod = 302,
  Fans = 303,
  ActiveMotivation = 401,
  CrystalIncentive = 402,
  RewardIncentives = 403,
  ContractIncentives = 404,
  Activity = 405,
  Level = 501,
  Mission = 502,
  Store = 503
}
Config_UGC_Center.Config_UGC_Centerlocal gem_report_utils = require("client.logic.store.gem_report_utils")
local tlogicpetnetutil = require("client.slua.logic.pet.traits.TLogicPetNetUtil")
local _LevelTab = {
  ID = _TabID.Level,
  NameID = 8940002,
  Module = "UGC_Center_Level",
  GemReport = gem_report_utils.SubEventName_UGC_Center_Level,
  Tlog = TLogEventDefine.UGC_Center_Level
}
local _HomeTab = {
  ID = _TabID.Home,
  NameID = 68617,
  Module = "UGC_Center_Home",
  GemReport = gem_report_utils.SubEventName_UGC_Center_Home,
  Tlog = TLogEventDefine.UGC_Center_Home,
  Open = function()
    if LobbySystem.CheckOpen(92068) then
      return true
    else
      return false
    end
  end
}
local _SchoolTab = {
  ID = _TabID.School,
  NameID = 8940003,
  Open = function()
    if IsWoWEditor then
      return false
    end
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    if PublishRegionMacros.IsBLUEHOLE() or not LobbySystem.CheckOpen(95015) then
      return false
    else
      return true
    end
  end
}
local _VideoTab = {
  ID = _TabID.Video,
  NameID = 8940004,
  Module = "UGC_Center_Gamelet_Container_UIBP",
  GemReport = gem_report_utils.SubEventName_UGC_Center_Video,
  Tlog = TLogEventDefine.UGC_Center_Video,
  Open = function()
    local strRegion = Client.GetPublishRegion()
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    if strRegion == PublishRegionMacros.BLUEHOLE or strRegion == PublishRegionMacros.JAPAN or strRegion == PublishRegionMacros.KOREA then
      return false
    end
    local gamelet_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_gamelet_interface)
    return gamelet_interface:IsInterfaceReady("3177")
  end,
  CreateExtreHandle = function(SourceExtra)
    return "3177"
  end
}
local _ChallengeTab = {
  ID = _TabID.Challenge,
  NameID = 8971015,
  Module = "UGC_Center_Challenge",
  GemReport = gem_report_utils.SubEventName_UGC_Center_Challenge,
  Tlog = TLogEventDefine.UGC_Center_Challenge
}
local _MissionTab = {
  ID = _TabID.Mission,
  NameID = 8940006,
  Module = "UGC_Center_Mission",
  GemReport = gem_report_utils.SubEventName_UGC_Center_Mission,
  Tlog = TLogEventDefine.UGC_Center_Mission,
  Open = function()
    return LobbySystem.CheckOpen(95013)
  end
}
local _StoreTab = {
  ID = _TabID.Store,
  NameID = 7095,
  Module = "UGC_Center_Store",
  GemReport = gem_report_utils.SubEventName_UGC_Center_Store,
  Tlog = TLogEventDefine.UGC_Center_Store
}
local _ActivityTab = {
  ID = _TabID.Activity,
  NameID = 8940008,
  Module = "UGC_Center_Gamelet_Container_UIBP",
  GemReport = gem_report_utils.SubEventName_UGC_Center_Activity,
  Tlog = TLogEventDefine.UGC_Center_Activity,
  Open = function()
    local strRegion = Client.GetPublishRegion()
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    if strRegion == PublishRegionMacros.BLUEHOLE or strRegion == PublishRegionMacros.JAPAN or strRegion == PublishRegionMacros.KOREA then
      return false
    end
    local gamelet_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_gamelet_interface)
    return gamelet_interface:IsInterfaceReady("3176")
  end,
  CreateExtreHandle = function(SourceExtra)
    return "3176"
  end
}
local _DataCenter = {
  ID = _TabID.DataCenter,
  NameID = 8973101,
  Module = "UGC_Center_Data",
  GemReport = gem_report_utils.SubEventName_UGC_Center_Data,
  Tlog = TLogEventDefine.UGC_Center_Data,
  Open = function()
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    if PublishRegionMacros.IsBLUEHOLE() or not LobbySystem.CheckOpen(95031) then
      return false
    else
      return true
    end
  end
}
local _WalletTab = {
  ID = _TabID.Wallet,
  NameID = 68709,
  Module = "UGC_Center_Wallet",
  GemReport = gem_report_utils.SubEventName_UGC_Center_Wallet,
  Tlog = TLogEventDefine.UGC_Center_Wallet,
  Open = function()
    if IsWoWEditor then
      return false
    end
    if LobbySystem.CheckOpen(92068) then
      return true
    else
      return false
    end
  end
}
local _CreationIncentivesTab = {
  ID = _TabID.IncentivePlan,
  NameID = 68710,
  Open = function()
    if LobbySystem.CheckOpen(92069) then
      return true
    else
      return false
    end
  end
}
local _ActiveMotivationTab = {
  ID = _TabID.ActiveMotivation,
  NameID = 68671,
  Module = "UGC_Center_ActiveMotivation",
  GemReport = gem_report_utils.SubEventName_UGC_Center_ActiveMotivation,
  Tlog = TLogEventDefine.UGC_Center_ActiveMotivation,
  Open = function()
    if LobbySystem.CheckOpen(92069) and LobbySystem.CheckOpen(92070) then
      return true
    else
      return false
    end
  end
}
local _CreatorsGrow = {
  ID = _TabID.CreatorsGrow,
  NameID = 79592,
  GemReport = gem_report_utils.SubEventName_UGC_Center_Grow,
  Tlog = TLogEventDefine.UGC_Center_Level
}
local _BenchmarkAuthor = {
  ID = _TabID.BenchmarkAuthor,
  Module = "UGC_Center_Gamelet_Container_UIBP",
  NameID = 79593,
  GemReport = gem_report_utils.SubEventName_UGC_Center_BenchmarkAuthor,
  Tlog = TLogEventDefine.UGC_Center_BenchmarkAuthor,
  Open = function()
    local strRegion = Client.GetPublishRegion()
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    if strRegion == PublishRegionMacros.BLUEHOLE or strRegion == PublishRegionMacros.JAPAN or strRegion == PublishRegionMacros.KOREA then
      return false
    end
    local gamelet_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_gamelet_interface)
    return gamelet_interface:IsInterfaceReady("3175")
  end,
  CreateExtreHandle = function(SourceExtra)
    return "3175"
  end
}
local _OfficialStory = {
  ID = _TabID.OfficialStory,
  Module = "UGC_Center_Gamelet_Container_UIBP",
  NameID = 79594,
  GemReport = gem_report_utils.SubEventName_UGC_Center_OfficialStory,
  Tlog = TLogEventDefine.UGC_Center_OfficialStory,
  Open = function()
    local strRegion = Client.GetPublishRegion()
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    if strRegion == PublishRegionMacros.BLUEHOLE or strRegion == PublishRegionMacros.JAPAN or strRegion == PublishRegionMacros.KOREA then
      return false
    end
    local gamelet_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_gamelet_interface)
    return gamelet_interface:IsInterfaceReady("3178")
  end,
  CreateExtreHandle = function(SourceExtra)
    return "3178"
  end
}
local _Tabs = {
  _HomeTab,
  _WalletTab,
  _CreationIncentivesTab,
  _StoreTab,
  _CreatorsGrow,
  _SchoolTab,
  _DataCenter,
  _BenchmarkAuthor,
  _OfficialStory
}
Config_UGC_Center.Config_UGC_Centerlocal _TeachingRoadTabsID = {NoviceTeaching = 1, ChallengeLevel = 2}
local _NoviceTeachingTab = {
  ID = _TeachingRoadTabsID.NoviceTeaching,
  NameID = 8971016,
  Module = "UGC_Center_Challenge_Page",
  Tlog = TLogEventDefine.UGC_Center_NoviceTeaching
}
local _ChallengeLevelTab = {
  ID = _TeachingRoadTabsID.ChallengeLevel,
  NameID = 8940005,
  Module = "UGC_Center_Challenge_Page",
  Tlog = TLogEventDefine.UGC_Center_ChallengeLevel
}
local _TeachingRoadTabs = {_NoviceTeachingTab, _ChallengeLevelTab}
Config_UGC_Center.Config_UGC_Center_TeachingRoad = _TeachingRoadTabs
local _TeachingRoadNewTabsID = {
  BeginnerTeaching = 1,
  TrainEliteSoldier = 2,
  ChallengeLevel = 3
}
Config_UGC_Center.Config_UGC_Centerlocal _BeginnerTeachingTab = {
  ID = _TeachingRoadNewTabsID.BeginnerTeaching,
  NameID = 18710233,
  Module = "UGC_Center_Challenge_Page",
  Tlog = TLogEventDefine.UGC_Center_BeginnerTeaching
}
local _ChallengeLevel2Tab = {
  ID = _TeachingRoadNewTabsID.ChallengeLevel,
  NameID = 8940005,
  Module = "UGC_Center_Challenge_Page",
  Tlog = TLogEventDefine.UGC_Center_ChallengeLevel
}
local _TrainEliteSoldierTab = {
  ID = _TeachingRoadNewTabsID.TrainEliteSoldier,
  NameID = 2026032194,
  Module = "UGC_Center_Challenge_Page",
  Tlog = TLogEventDefine.UGC_Center_TrainEliteSoldier
}
local _TeachingRoadNewTabs = {
  _BeginnerTeachingTab,
  _TrainEliteSoldierTab,
  _ChallengeLevel2Tab
}
Config_UGC_Center.Config_UGC_Center_TeachingRoadNew = _TeachingRoadNewTabs
local _TutorialVersion = {Old = 1, New = 2}
Config_UGC_Center.Config_UGC_Centerlocal _DataOverview = {
  ID = 301,
  NameID = 8973102,
  Tlog = TLogEventDefine.UGC_Center_Data_Overview_Stay,
  Module = "UGCCenterData_Overview"
}
local _ModData = {
  ID = 302,
  NameID = 8973103,
  Tlog = TLogEventDefine.UGC_Center_Data_Mod_Stay,
  Module = "UGCCenterData_Mod"
}
local _FansData = {
  ID = 303,
  NameID = 8973109,
  Tlog = TLogEventDefine.UGC_Center_Data_Overview_Fans,
  Module = "UGCCenterData_Fans"
}
local _OverviewWorkInfo = {
  Played = 1,
  Hot = 2,
  Collect = 3,
  FollowTotal = 4,
  FollowAdd = 5
}
Config_UGC_Center.Configlocal _ModWorkInfo = {
  Played = 1,
  Hot = 2,
  Collect = 3,
  Share = 4,
  FansCnt = 5,
  PlayerCnt = 6,
  PlayerSourceDistribution = 7,
  PlayingTimeDistribution = 8,
  TrackingPoint = 9,
  Subsistence = 10,
  CrystalIncome = 11
}
Config_UGC_Center.Configlocal _ModFansInfo = {
  Follow_total = 1,
  Follow_add = 2,
  Follow_new = 3,
  Follow_cancel = 4
}
Config_UGC_Center.Config_OverviewFansInfo = _ModFansInfo
local author_line_chart_type = {
  play_cnt = "play_cnt",
  play_time = "play_time",
  collect = "collect",
  follow_total = "follow_total",
  follow_add_total = "follow_add_total",
  follow_new_total = "follow_new_total",
  follow_cancel_total = "follow_cancel_total",
  share = "share",
  fan_cnt = "fan_cnt",
  player_cnt = "player_cnt",
  crystal_income = "crystal_income"
}
Config_UGC_Center.Config_DataCenter_OverviewType = author_line_chart_type
local author_circle_chart_type = {
  player_source = "player_source",
  play_time = "play_time",
  fans_source = "fans_source"
}
Config_UGC_Center.tracking_point_chart_type = {
  TrackingPoint = "TrackingPoint",
  Subsistence = "player_day1_retention_rate"
}
Config_UGC_Center.Author_Circle_Chart_Type = author_circle_chart_type
local _SortType = {PubTime = 1, PlayCnt = 2}
local _PlayerSourceOrder = {
  sort_type = {
    "wow_cnt",
    "room_cnt",
    "profilepage_cnt",
    "search_cnt",
    "other_cnt"
  },
  sort_lockey = {
    wow_cnt = 8973062,
    room_cnt = 8973063,
    profilepage_cnt = 8973064,
    search_cnt = 8973065,
    other_cnt = 8973066
  }
}
Config_UGC_Center.PlayerSourceOrder = _PlayerSourceOrder
local _PlayTimeOrder = {
  sort_type = {
    "one",
    "one_five",
    "five_ten",
    "ten_fifteen",
    "fifteen"
  },
  sort_lockey = {
    one = 8973067,
    one_five = 8973068,
    five_ten = 8973069,
    ten_fifteen = 8973070,
    fifteen = 8973071
  }
}
Config_UGC_Center.PlayTimeOrder = _PlayTimeOrder
local _FansSourceOrder = {
  sort_type = {
    "detail_cnt",
    "profilepage_cnt",
    "search_cnt",
    "other_cnt"
  },
  sort_lockey = {
    detail_cnt = 8973075,
    profilepage_cnt = 8973076,
    search_cnt = 8973077,
    other_cnt = 8973078
  }
}
Config_UGC_Center.FansSourceOrder = _FansSourceOrder
local _AuthorDataCenterSortConfig = {
  [_SortType.PubTime] = {nNameID = 8973120},
  [_SortType.PlayCnt] = {nNameID = 8973121}
}
Config_UGC_Center.Clocal _CrystalIncentiveTab = {
  ID = _TabID.CrystalIncentive,
  NameID = 1050236,
  Module = "UGC_Center_CrystalIncentive",
  GemReport = gem_report_utils.SubEventName_UGC_Center_CrystalIncentives,
  Tlog = TLogEventDefine.UGC_Center_CrystalIncentives,
  Open = function()
    if not LobbySystem.CheckOpen(92073) then
      return false
    end
    return true
  end
}
local _RewardIncentivesTab = {
  ID = _TabID.RewardIncentives,
  NameID = 68683,
  Module = "UGC_Center_RewardIncentives",
  GemReport = gem_report_utils.SubEventName_UGC_UGC_Center_RewardIncentives,
  Tlog = TLogEventDefine.UGC_Center_RewardIncentives,
  Open = function()
    if LobbySystem.CheckOpen(92069) and LobbySystem.CheckOpen(92072) then
      return true
    else
      return false
    end
  end
}
local _ContractIncentivesTab = {
  ID = _TabID.ContractIncentives,
  NameID = 68684,
  Module = "UGC_Center_CreationIncentives",
  GemReport = gem_report_utils.SubEventName_UGC_Center_CreationIncentives,
  Tlog = TLogEventDefine.UGC_Center_CreationIncentives,
  Open = function()
    return false
  end
}
local _SecondTabs = {
  [_TabID.School] = {_VideoTab, _ChallengeTab},
  [_TabID.DataCenter] = {
    _DataOverview,
    _ModData,
    _FansData
  },
  [_TabID.IncentivePlan] = {
    _ActiveMotivationTab,
    _RewardIncentivesTab,
    _CrystalIncentiveTab
  },
  [_TabID.CreatorsGrow] = {_LevelTab, _MissionTab}
}
Config_UGC_Center.Config_UGC_Centerlocal _MissionTabID = {
  NewbieMission = 1,
  DailyMission = 2,
  GrowMission = 3
}
Config_UGC_Center.Config_UGC_Centerlocal _DailyMissionTabID = {WeekMission = 1, SeasonMission = 2}
Config_UGC_Center.Config_UGC_Centerlocal _GrowMissionTabID = {CreativeMission = 1, AchievementMission = 2}
local _NewbieMissionTab = {
  ID = _MissionTabID.NewbieMission,
  NameID = 8600083,
  Module = "UGC_Center_Mission_Page",
  GemReport = gem_report_utils.SubEventName_UGC_Center_Mission_Newbie,
  Tlog = TLogEventDefine.UGC_Center_Mission_Newbie
}
local _DailyMissionTab = {
  ID = _MissionTabID.DailyMission,
  NameID = 8600084,
  Module = "UGC_Center_Mission_DailyPage",
  GemReport = gem_report_utils.SubEventName_UGC_Center_Mission_Daily,
  Tlog = TLogEventDefine.UGC_Center_Mission_Daily
}
local _GrowMissionTab = {
  ID = _MissionTabID.GrowMission,
  NameID = 8600085,
  Module = "UGC_Center_Mission_Page",
  GemReport = gem_report_utils.SubEventName_UGC_Center_Mission_Grow,
  Tlog = TLogEventDefine.UGC_Center_Mission_Grow
}
local _MissionTabs1 = {_NewbieMissionTab}
Config_UGC_Center.Config_UGC_Centerlocal _MissionTabs2 = {_DailyMissionTab, _GrowMissionTab}
Config_UGC_Center.Config_UGC_Centerlocal _WeekMissionTab = {
  ID = _DailyMissionTabID.WeekMission,
  NameID = 8600086,
  GemReport = gem_report_utils.SubEventName_UGC_Center_Mission_Week,
  Tlog = TLogEventDefine.UGC_Center_Mission_Newbie
}
local _SeasonMissionTab = {
  ID = _DailyMissionTabID.SeasonMission,
  NameID = 8600087,
  GemReport = gem_report_utils.SubEventName_UGC_Center_Mission_Season,
  Tlog = TLogEventDefine.UGC_Center_Mission_Season
}
local _CreativeMissionTab = {
  ID = _GrowMissionTabID.CreativeMission,
  NameID = 8600088,
  GemReport = gem_report_utils.SubEventName_UGC_Center_Mission_Creative,
  Tlog = TLogEventDefine.UGC_Center_Mission_Creative
}
local _AchievementMissionTab = {
  ID = _GrowMissionTabID.AchievementMission,
  NameID = 8600094,
  GemReport = gem_report_utils.SubEventName_UGC_Center_Mission_Achievement,
  Tlog = TLogEventDefine.UGC_Center_Mission_Achievement
}
local _MissionSecondTabs = {
  [_MissionTabID.DailyMission] = {_WeekMissionTab},
  [_MissionTabID.GrowMission] = {_CreativeMissionTab, _AchievementMissionTab}
}
local ItemDataType = {
  Title = 2,
  Content = 1,
  Spacer = 3
}
Config_UGC_Center.Config_UGC_Center.Config_UGC_Centerlocal _WalletTabsID = {RevenueStatistics = 1, IncomeDetails = 2}
local _RevenueStatisticsTab = {
  ID = _WalletTabsID.RevenueStatistics,
  NameID = 68669
}
local _IncomeDetailsTab = {
  ID = _WalletTabsID.IncomeDetails,
  NameID = 68670
}
local _WalletTabs = {_RevenueStatisticsTab, _IncomeDetailsTab}
Config_UGC_Center.Config_UGC_Center_Wallet = _WalletTabs
local _IncentiveTabID = {
  ActiveMotivation = 1,
  InternalPurchaseIncentive = 2,
  RewardIncentives = 3,
  ContractIncentives = 4
}
Config_UGC_Center.Config_UGC_Centerlocal _CreationIncentivesTabs = {
  _ActiveMotivationTab,
  _CrystalIncentiveTab,
  _RewardIncentivesTab,
  _ContractIncentivesTab
}
Config_UGC_Center.Config_UGC_Centerlocal _IncentivePlanTabsID = {ParticipationProcess = 1, MonthlyTasks = 2}
local _ParticipationProcessTab = {
  ID = _IncentivePlanTabsID.ParticipationProcess,
  NameID = 68702
}
local _MonthlyTasksTab = {
  ID = _IncentivePlanTabsID.MonthlyTasks,
  NameID = 68703
}
local _IncentivePlanTabs = {_ParticipationProcessTab, _MonthlyTasksTab}
Config_UGC_Center.Config_UGC_Center_IncentivePlan = _IncentivePlanTabs
local _WalletCfg = {
  ActiveMotivation = 1,
  CreativeCompetition = 2,
  signing_plan = 3
}
Config_UGC_Center.Config_UGC_Center_Wallet_Cfg = _WalletCfg
local _UGCTutorialSource = {
  club = 1,
  center = 2,
  teach = 3
}
Config_UGC_Center.Config_UGC_Center_TutorialSource = _UGCTutorialSource
return Config_UGC_Center