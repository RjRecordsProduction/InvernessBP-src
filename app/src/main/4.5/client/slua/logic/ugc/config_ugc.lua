local data_config_marco = require("client.logic.data.data_config_marco")
if IsEditor and Client then
  require("client.slua.config.tlog.TLogEventDefine")
end
local Config_UGC = {
  TestTemplateID = 1,
  MaxSlotNum = 16,
  ReqModInfoMaxNum = 20,
  RecommendFirstReqModNum = 20,
  RankMaxCount = 200,
  RankMinCount = 13,
  RankMaxPage = 10,
  GalleryParamConfig = data_config_marco.gallery_param_config,
  InitSelectTab = 101,
  TopListCol = 4,
  TopPageNum = 6,
  RoomType = "ugc",
  ModRoomType = "ugc_mod_room",
  ChatRoomType = "ugc_chat_room",
  RoomListType = "view_ugc",
  DetailRoomListType = "view_ugc_mod",
  ModType = "CreativeBase",
  IdleState = "idle",
  RefreshListCD = 5,
  TagMaxNum = 3,
  ShowParamMaxNum = 2,
  DefaultCoverMaxNum = 3,
  ModIDMaxLen = 9,
  RoomNameMaxLen = 20,
  RoomPsdMaxLen = 6,
  TimerHUDStrMaxLen = 80,
  RankTopModCount = 8,
  RoomListTabIndex = 3,
  FreezeType = 1,
  CONST_DEFAULT_SUB_TAB_INDEX = 0,
  MaxModCollect = 100,
  MaxModPalyCut = 48,
  MaxModCollectPassOn = 200,
  MaxModPalyCutPassOn = 200,
  SimultaneousOnlineUsers = 10,
  ReqAuthorInfoMaxNum = 20,
  CONST_INERTIA_SCROLL_SPD = 800,
  AUTHOR_INERTIA_SCROLL = 100,
  SimultaneousOnlinePopular = 10,
  SimultaneousOnlineModerate = 1,
  AlbumThemeShowSpecificTime = 7,
  UGCActivationLevel = 3,
  NewbieResKey = "pak_mix_wow_newbie",
  REGION_SELF_TAG_HOT_ID = 209,
  REGION_HOT_RECOMMEND_ID = 208
}
Config_UGC.BatchPullStage = {
  none = 0,
  shouldRequest = 1,
  requested = 2,
  respondedWithData = 3,
  respondedWithoutData = 4
}
Config_UGC.RankDataState = {
  serverNodata = 0,
  clientNoData = 1,
  clientNoNewData = 2,
  clientHasNewData = 3
}
Config_UGC.Enum_Official_Tag = {
  NULL = 0,
  CORP = 1001,
  TEMPLATE = 1002,
  STAR = 1003,
  BANNER = 1004,
  SEASON = 1005,
  GAMEPLAY_LAB = 1006,
  DOBIG = 1007
}
Config_UGC.Source_Open_Detail = {
  UGCMain = 1,
  MineEdit = 2,
  Moment = 3,
  Chat = 4,
  UGCAuthorWork = 5,
  UGCBanner = 6,
  Search = 7,
  Jump = 8,
  Thema = 9,
  InGameResultRecommend = 10,
  UGCBannerAuthor = 11,
  SNS = 12,
  Collections = 13,
  UGCCenterData = 15,
  UGCExposure = 16,
  UGCPersonalCreate = 17,
  AllAuthor = 18,
  SeasonTemplate = 19,
  UGCPersonalAuthorHomePage = 20,
  UGColdBoot = 21,
  UGCSoloPK = 22,
  UGCTemplate = 23,
  HomeWowDevice = 24,
  AppreciationGroup = 25,
  ReturnModeSelect = 26
}
Config_UGC.Detail_Source_To_TLog_Config = {
  [Config_UGC.Source_Open_Detail.UGCMain] = TLogEventDefine.UGC_Mod_Exposure_Main,
  [Config_UGC.Source_Open_Detail.Moment] = TLogEventDefine.UGC_Mod_Exposure_Moment,
  [Config_UGC.Source_Open_Detail.Chat] = TLogEventDefine.UGC_Mod_Exposure_Chat,
  [Config_UGC.Source_Open_Detail.UGCAuthorWork] = TLogEventDefine.UGC_Mod_Exposure_AuthorWork,
  [Config_UGC.Source_Open_Detail.UGCBanner] = TLogEventDefine.UGC_Mod_Exposure_Banner,
  [Config_UGC.Source_Open_Detail.Search] = TLogEventDefine.UGC_Mod_Exposure_Search,
  [Config_UGC.Source_Open_Detail.Jump] = TLogEventDefine.UGC_Mod_Exposure_Jump,
  [Config_UGC.Source_Open_Detail.Thema] = TLogEventDefine.UGC_Mod_Exposure_Banner_ThemaItem_Work,
  [Config_UGC.Source_Open_Detail.InGameResultRecommend] = TLogEventDefine.UGC_Mod_Exposure_Result_Recommend,
  [Config_UGC.Source_Open_Detail.UGCBannerAuthor] = TLogEventDefine.UGC_Mod_Exposure_Banner_AuthorWork,
  [Config_UGC.Source_Open_Detail.AllAuthor] = TLogEventDefine.UGC_AllAuthor_Recommend,
  [Config_UGC.Source_Open_Detail.AppreciationGroup] = TLogEventDefine.UGC_Appreciation_Group
}
Config_UGC.Newbie_Guide_Type_Key = {
  FirstSelectUGCMod = 1,
  SearchCollections = 2,
  DailyTask01 = 3,
  DailyTaskGetAll = 4,
  DailyTaskCloseAfterGetAll = 5,
  DailyTaskEnterPlayData = 6,
  DailyTaskGetReward = 7,
  DailyTaskRewardClaim = 8,
  WeakTeachingRoad = 9,
  StrongTeachingRoad = 10,
  WeakTeachingRoadLvSix_1 = 11,
  WeakTeachingRoadLvSix_2 = 12,
  WeakTeachingRoadNewLvSix_1 = 13,
  WeakTeachingRoadNewLvSix_2 = 14,
  WeakTeachingRoadNewLvSix_3 = 15,
  WeakTeachingRoadNewLvSix_4 = 16,
  WeakTeachingRoadNewLvSix_5 = 17,
  WeakTeachingRoadNewLvSix_6 = 18,
  WeakTeachingRoadNewLvSix_7 = 19,
  EnterGameWoWMode = 1009,
  EnterGameNewbieTheme = 1010,
  EnterGameNewbieThemeTip = 10101,
  EnterGameOpenDetail = 1011,
  EnterGameOpenDetailDownloadRes = 10112,
  EnterGameBeginMatch = 1012,
  HasEnteredUGCMatch = 1013,
  EnterGameWoWModeNewbieEnd = 2000,
  EnterGameWoWModeATestEnd = 2001,
  EnterGameWoWModeBTestHintLobby = 20022,
  EnterGameWoWModeBTestHintModeSelect = 20023,
  EnterGameWoWModeBTestEnd = 2002,
  EnterGameWoWModeCTestHintLobby = 20031,
  EnterGameWoWModeCTestHotMod = 20032,
  EnterGameWoWModeCTestEnd = 2003,
  CustomPhotoEdit = 2004,
  UGCDataCenterNewbieGuide = 2005,
  UGCActiveMotivationRewardGuide1 = 2006,
  UGCActiveMotivationRewardGuide2 = 2007,
  UGCPropShopNewbieGuide = 2008,
  UGCWalletMoneyNewbieGuide = 2009,
  UGCCrystalIncentiveJoinGuide = 2010,
  UGCCrystalIncentiveWithdrawalGuide = 2011,
  UGCCrystalIncentivePayPropGuide = 2012,
  UGCNewFilterTag = 2013,
  EnterWoWNewHall = 2014,
  UGCOpenTitleIntroduction = 2015,
  EnterPlayVideo = 2016,
  EnterOpenRecommendedWorks = 2017,
  EnterOpenIntention = 2018,
  EnterWoWHallNewbieEnd = 3000
}
Config_UGC.Enum_Bundle_Type = {
  Bundle = 1,
  Banner = 2,
  HotTheme = 3,
  Random = 4,
  Collect = 5,
  TourNament = 7,
  ActivityTemplate = 8
}
local _EntryInModeSelection = {
  id = 900,
  name = 70063,
  type = 3,
  menu_level = 1,
  level_limit = 3,
  set_gallery_param_config = 0
}
function Config_UGC.GetEntryData()
  if _EntryInModeSelection.set_gallery_param_config == 0 then
    local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
    _EntryInModeSelection.id = mode_selection_macro.Enum_TabID.UGC
    _EntryInModeSelection.type = mode_selection_macro.Enum_Menu_Type.Single
    local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
    local GalleryParamConfig = BasicDataServerTable:GetCacheData(Config_UGC.GalleryParamConfig)
    if GalleryParamConfig ~= nil and GalleryParamConfig.LevelLimit ~= nil then
      _EntryInModeSelection.level_limit = tonumber(GalleryParamConfig.LevelLimit)
    end
    _EntryInModeSelection.set_gallery_param_config = 1
  end
  return _EntryInModeSelection
end
function Config_UGC.SetEntryData(galleryParamConfig)
  local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
  _EntryInModeSelection.id = mode_selection_macro.Enum_TabID.UGC
  _EntryInModeSelection.type = mode_selection_macro.Enum_Menu_Type.Single
  if galleryParamConfig ~= nil and galleryParamConfig.LevelLimit ~= nil then
    _EntryInModeSelection.level_limit = tonumber(galleryParamConfig.LevelLimit)
  end
  _EntryInModeSelection.set_gallery_param_config = 1
end
function Config_UGC.IsUGCReleased()
  if not DataMgr or not DataMgr.is_open_ugc then
    log(bWriteLog and "Config_UGC.SetUGCSwitchData DataMgr.roleData is nil")
    return false
  end
  return DataMgr.is_open_ugc == 1
end
function Config_UGC.IsUGCUnlock(Level)
  Level = Level or DataMgr.roleData.level
  return Level >= _EntryInModeSelection.level_limit
end
Config_UGC.SearchTabID = {SearchMod = 111, SearchCollections = 112}
local _TabID = {
  Recommend = 101,
  Play = 102,
  History = 103,
  Collect = 104,
  Download = 105,
  Random = 106,
  Follow = 107,
  All = 1,
  PHome = 108,
  HotTheme = 109,
  Friend = 110,
  SearchMod = Config_UGC.SearchTabID.SearchMod,
  SearchCollections = Config_UGC.SearchTabID.SearchCollections,
  Collections = 113,
  Tournament = 114,
  HotRankTheme = 115,
  NewNewMap = 117,
  Mine = 118,
  FineMod = 119,
  ModPlaza = 120,
  More = 121
}
Config_UGC.Config_UGClocal _RandomTab = {
  ID = _TabID.Random,
  nNameID = 8800081,
  sModule = "UGC_Main_Lobby_NewMap_UIBP",
  sRoot = "CanvasPanel_Random",
  nSwitcherIndex = 5
}
local _PlayTab = {
  ID = _TabID.Play,
  nNameID = 70039,
  sCallFunc = "ShowPlay",
  fCheck = function()
    return true
  end
}
local _NewPlayTab = {
  ID = _TabID.Mine,
  nNameID = 70039,
  sModule = "UGC_Main_Mine_UI",
  sRoot = "CanvasPanel_MyPage",
  TLog = TLogEventDefine.UGC_Click_Tab_Mine,
  nSwitcherIndex = 13
}
local _HistoryTab = {
  ID = _TabID.History,
  nNameID = 70056,
  sModule = "OldUGCHistoryPanel",
  sRoot = "CanvasPanel_History",
  nSwitcherIndex = 3,
  nTLogType = TLogEventDefine.UGC_History_Page
}
local _CollectTab = {
  ID = _TabID.Collect,
  nNameID = 70057,
  sModule = "OldUGCCollectPanel",
  sRoot = "CanvasPanel_Collect",
  nSwitcherIndex = 2,
  nTLogType = TLogEventDefine.UGC_Collect_Page
}
local _FriendTab = {
  ID = _TabID.Friend,
  nNameID = 102124,
  sModule = "OldUGCFriendPanel",
  sRoot = "CanvasPanel_Friend",
  nSwitcherIndex = 8,
  nTLogType = TLogEventDefine.UGC_Mod_Friend_Page
}
local _FollowTab = {
  ID = _TabID.Follow,
  nNameID = 78345,
  sModule = "OldUGCFollowPanel",
  sRoot = "CanvasPanel_Follow",
  nSwitcherIndex = 6,
  nTLogType = TLogEventDefine.UGC_Follow_Page
}
local _MineCollectionListTab = {
  ID = _TabID.Collections,
  nNameID = 69264,
  sModule = "OldUGCCollectionListPanel",
  sRoot = "CanvasPanel_CollectionList",
  nSwitcherIndex = 9
}
local _NewUGCSeasonTab = {
  ID = _TabID.Tournament,
  nNameID = 78344,
  sModule = "UGC_Main_Lobby_Tournament_UIBP",
  sRoot = "CanvasPanel_CreativeTourismSeason",
  TLog = TLogEventDefine.UGC_Click_Tab_Tournament,
  nSwitcherIndex = 10
}
local _NewMapTab = {
  ID = _TabID.NewNewMap,
  nNameID = 8800081,
  sModule = "UGC_Main_Lobby_NewMap_TrafficPool_UIBP",
  sRoot = "CanvasPanel_Random",
  TLog = TLogEventDefine.UGC_Click_Tab_New_Map,
  nSwitcherIndex = 5
}
local _NewHotThemeTab = {
  ID = _TabID.HotTheme,
  nNameID = 70038,
  sModule = "New_UGC_Main_Lobby_HotTheme_UIBP",
  sRoot = "CanvasPanel_Hot",
  TLog = TLogEventDefine.UGC_Click_Tab_Hot_theme,
  nSwitcherIndex = 1
}
local _FineModTab = {
  ID = _TabID.FineMod,
  nNameID = 468890112,
  sModule = "UGC_Main_Lobby_FineMod_UIBP",
  sRoot = "CanvasPanel_Random",
  TLog = TLogEventDefine.UGC_Click_Tab_Discovery,
  nSwitcherIndex = 5
}
local _ModPlazaTab = {
  ID = _TabID.ModPlaza,
  nNameID = 69997,
  sModule = "UGC_Hall_CreationPlaza_Item_UIBP",
  sRoot = "CanvasPanel_CreationPlaza",
  TLog = TLogEventDefine.UGC_Hall_FindWork_ModPlazaClick,
  nSwitcherIndex = 14,
  fCheck = function()
    local LogicPufferBundle = require("client.slua.logic.download.bundle.logic_puffer_bundle")
    return LogicPufferBundle.IsFitLobbyResDownloaded()
  end
}
local _PHomeTab = {
  ID = _TabID.PHome,
  nNameID = 64741,
  sModule = "ModeSelection_Home_UIBP",
  sRoot = "CanvasPanel_PHome",
  nSwitcherIndex = 7,
  TLog = TLogEventDefine.UGC_Click_Tab_Home,
  fCheck = function()
    local LogicPufferBundle = require("client.slua.logic.download.bundle.logic_puffer_bundle")
    if not LogicPufferBundle.IsFitLobbyResDownloaded() then
      return false
    end
    local logic_home_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_switch)
    if not LobbySystem.CheckOpen(95006) then
      return false
    end
    return logic_home_switch:CheckHomeSwitchOpen()
  end
}
local _MoreTab = {
  ID = _TabID.More,
  nNameID = 180108,
  nSwitcherIndex = 16,
  TLog = TLogEventDefine.UGC_Click_Tab_More,
  fCheck = function()
    local LogicPufferBundle = require("client.slua.logic.download.bundle.logic_puffer_bundle")
    return not LogicPufferBundle.IsFitLobbyResDownloaded()
  end
}
local _HiddenTabs = {
  _FollowTab,
  _FriendTab,
  _CollectTab,
  _MineCollectionListTab,
  _HistoryTab
}
Config_UGC.Clocal _Fixed_UGC_Tabs_Last_Added = {_PHomeTab, _MoreTab}
local _GetTabData = function(uObj_cfg)
  if uObj_cfg.StartTimeStr and uObj_cfg.StartTimeStr ~= "" and uObj_cfg.EndTimeStr and uObj_cfg.EndTimeStr ~= "" then
    local TimeUtil = require("client.common.time_util")
    local serverTime = TimeUtil.GetServerTimeInSec()
    local startTime = TimeUtil.TimeStringToUnixstamp(uObj_cfg.StartTimeStr)
    local endTime = TimeUtil.TimeStringToUnixstamp(uObj_cfg.EndTimeStr)
    if serverTime < startTime or serverTime >= endTime then
      log(bWriteLog and "Config_UGC._GetTabData, time is not match and ID is: " .. tostring(uObj_cfg.ID) .. " serverTime is: " .. tostring(serverTime))
      return
    end
  end
  local rankTab = {
    ID = uObj_cfg.ID,
    Name = uObj_cfg.Name,
    Sort = uObj_cfg.Sort
  }
  return rankTab
end
function Config_UGC.GetRankTabs()
  local tb1 = Config_UGC.GetCurFixedTabShowConfig() or {}
  local TableUtil = require("common.table_util")
  local tb3 = TableUtil.CopyTable(_Fixed_UGC_Tabs_Last_Added)
  for _, v in ipairs(tb3) do
    if not v.fCheck or v.fCheck() then
      v.Name = v.nNameID
      table.insert(tb1, v)
    end
  end
  table.sort(tb1, function(a, b)
    local sortIndex1 = Config_UGC.GetTabSort(a.ID) or 0
    local sortIndex2 = Config_UGC.GetTabSort(b.ID) or 0
    return sortIndex1 > sortIndex2
  end)
  return tb1
end
function Config_UGC.GetCurFixedTabShowConfig()
  local curRecommendCfg = _NewHotThemeTab
  local TableUtil = require("common.table_util")
  local recommendTabData = TableUtil.CopyTable(curRecommendCfg)
  recommendTabData.Name = recommendTabData.nNameID
  local tabList = {recommendTabData}
  local LogicUGCHall = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_hall)
  local UGCRankConfig = CDataTable.GetTable("UGCRankConfig")
  for _, v in pairs(UGCRankConfig) do
    if tonumber(v.ID) == Config_UGC.Config_UGC_TabID.All then
      if not LogicUGCHall:CheckIsOpen() then
        local tabData = _GetTabData(v)
        if tabData then
          tabData.TLog = TLogEventDefine.UGC_Click_Tab_All
          table.insert(tabList, tabData)
        end
      end
      break
    end
  end
  local tb1, _TempTab
  local logic_ugc_new_map = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_new_map)
  local abtest = logic_ugc_new_map.gallery_new_mod_abtest
  if LobbySystem.CheckOpen(BP_UGC_RANDREC_SWITCH) and not LogicUGCHall:CheckIsOpen() then
    log(bWriteLog and "Config_UGC.GetCurFixedTabShowConfig abtest = " .. tostring(abtest))
    if abtest == 1 then
      _TempTab = TableUtil.CopyTable(_NewMapTab)
    else
      _TempTab = TableUtil.CopyTable(_RandomTab)
    end
    _TempTab.Name = _TempTab.nNameID
    table.insert(tabList, _TempTab)
  end
  local logic_ugc_mine = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_mine)
  local MineABTest = logic_ugc_mine.mine_homepage_abtest
  if MineABTest == 1 then
    tb1 = TableUtil.CopyTable(_NewPlayTab)
  else
    tb1 = TableUtil.CopyTable(_PlayTab)
  end
  tb1.Name = tb1.nNameID
  table.insert(tabList, tb1)
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() or PublishRegionMacros.IsBLUEHOLE() then
  else
    local tb2 = TableUtil.CopyTable(_NewUGCSeasonTab)
    tb2.Name = tb2.nNameID
    table.insert(tabList, tb2)
  end
  if LogicUGCHall:CheckIsOpen() then
    local fineModTab = TableUtil.CopyTable(_FineModTab)
    fineModTab.Name = fineModTab.nNameID
    table.insert(tabList, fineModTab)
    if not _ModPlazaTab.fCheck or _ModPlazaTab.fCheck() then
      local modPlazaTab = TableUtil.CopyTable(_ModPlazaTab)
      modPlazaTab.Name = _ModPlazaTab.nNameID
      table.insert(tabList, modPlazaTab)
    end
  end
  return tabList
end
function Config_UGC.GetTabSort(tabID)
  if not tabID then
    return
  end
  local cfg = CDataTable.GetTableData("UGCTabSortConfig", tabID)
  return cfg and cfg.Sort
end
local _RankFilterKey_type_play_cnt_week = "type_play_cnt_week"
local _RankFilter = {
  {
    sKey = "type_play_time_week",
    nNameID = 70077
  },
  {
    sKey = "type_play_cnt",
    nNameID = 70065
  },
  {
    sKey = "type_collect_cnt",
    nNameID = 70067
  },
  {
    sKey = "type_publish_time",
    nNameID = 70064
  }
}
Config_UGC.CConfig_UGC.RankFilterKey_type_play_cnt_week = _RankFilterKey_type_play_cnt_week
function Config_UGC.GetRankFilter(switchs)
  local filterList = {}
  if not switchs then
    return filterList
  end
  for _, filter in ipairs(_RankFilter) do
    if switchs[filter.sKey] and switchs[filter.sKey] > 0 then
      table.insert(filterList, filter)
    end
  end
  return filterList
end
local _HomeRankFilter = {
  {
    sKey = "type_play_cnt",
    nNameID = "\231\131\173\229\186\166"
  },
  {
    sKey = "type_play_cnt_week",
    nNameID = "\229\145\168\231\131\173\229\186\166"
  },
  {
    sKey = "type_prosperity",
    nNameID = "\231\185\129\232\141\163\229\186\166"
  },
  {
    sKey = "type_popularity",
    nNameID = "\228\186\186\230\176\148\229\128\188"
  }
}
Config_UGC.C_RankHomeFilter = _HomeRankFilter
local _MineRankFilter = {
  {
    sKey = "last_play_time",
    nNameID = 38905
  },
  {
    sKey = "type_play_cnt",
    nNameID = 70065
  },
  {
    sKey = "type_play_cnt_week",
    nNameID = 70077
  }
}
Config_UGC.UGC_RankMineFilter = _MineRankFilter
Config_UGC.UGC_CollectionFilter = {
  {
    sKey = "type_play_cnt",
    nNameID = 70065
  },
  {
    sKey = "type_play_cnt_week",
    nNameID = 70077
  }
}
function Config_UGC.GetHomeRankFilter()
  local filterList = {}
  for _, filter in ipairs(_HomeRankFilter) do
    table.insert(filterList, filter)
  end
  return filterList
end
local _DetailTabID = {
  Detail = 1,
  Update = 2,
  Comment = 3,
  Guide = 4,
  About = 5,
  MineDetail = 6,
  MineUpdate = 7,
  ReviewDetail = 8,
  Rank = 9,
  Exposure = 10,
  Collections = 11,
  CrystallizedIncome = 12,
  PropShop = 13,
  PlayHistory = 14
}
Config_UGC.Config_UGClocal _DetailTab = {
  nID = _DetailTabID.Detail,
  sIcon = "/Game/UMG/Texture_200/Atlas/CreativeMode/Frames/UGC_tab03_png.UGC_tab03_png",
  dIcon = "/Game/UMG/Texture_200/Atlas/CreativeMode/Frames/UGC_tab04_png.UGC_tab04_png",
  sModule = "UGCDetailInfoSubPanel",
  sRoot = "CanvasPanel_Detail"
}
local _UpdateTab = {
  nID = _DetailTabID.Update,
  sIcon = "/Game/UMG/Texture_200/Atlas/CreativeMode/Frames/UGC_tab01_png.UGC_tab01_png",
  dIcon = "/Game/UMG/Texture_200/Atlas/CreativeMode/Frames/UGC_tab02_png.UGC_tab02_png",
  sModule = "UGCDetailUpdateLogPanel",
  sRoot = "CanvasPanel_Update"
}
local _RankTab = {
  nID = _DetailTabID.Rank,
  sIcon = "/Game/UMG/Texture_200/Atlas/CreativeMode/Frames/Ugc_Tab_Rank_Xuanzhong_png.Ugc_Tab_Rank_Xuanzhong_png",
  dIcon = "/Game/UMG/Texture_200/Atlas/CreativeMode/Frames/Ugc_Tab_Rank_png.Ugc_Tab_Rank_png",
  sModule = "UGC_Rank_UIBP",
  sRoot = "CanvasPanel_Rank"
}
local _CollectionListTab = {
  nID = _DetailTabID.Collections,
  sIcon = "/Game/UMG/Texture_200/Atlas/CreativeMode/Frames/Common_Tab_Compilation_xuanzhong_png.Common_Tab_Compilation_xuanzhong_png",
  dIcon = "/Game/UMG/Texture_200/Atlas/CreativeMode/Frames/Common_Tab_Compilation_png.Common_Tab_Compilation_png",
  sModule = "UGCCollectionSubUI",
  sRoot = "CanvasPanel_CollectionListRecord"
}
Config_UGC.Config_UGClocal _CrystallizationIncomeTab = {
  nID = _DetailTabID.CrystallizedIncome,
  sIcon = "/Game/UMG/Texture_200/Atlas/CreativeMode/Frames/Ugc_Tab_IncomeRecord_Select_png.Ugc_Tab_IncomeRecord_Select_png",
  dIcon = "/Game/UMG/Texture_200/Atlas/CreativeMode/Frames/Ugc_Tab_IncomeRecord_png.Ugc_Tab_IncomeRecord_png",
  sModule = "UGCCrystallizedIncomeSubUI",
  sRoot = "CanvasPanel_CrystallizedIncome",
  Open = function(Modinfo)
    if Modinfo and tonumber(Modinfo.base.uid) == tonumber(DataMgr.roleData.uid) and Modinfo.setting and Modinfo.setting.has_mod_market and not GameStatus.IsInFightingStatus() then
      return true
    end
    return false
  end
}
local _PropShop = {
  nID = _DetailTabID.PropShop,
  sIcon = "/Game/UMG/Texture_200/Atlas/CreativeMode/Frames/Common_Tab_Shop_Select_png.Common_Tab_Shop_Select_png",
  dIcon = "/Game/UMG/Texture_200/Atlas/CreativeMode/Frames/Common_Tab_Shop_png.Common_Tab_Shop_png",
  sModule = "UGC_PropShopPanel",
  sRoot = "CanvasPanel_MapShop",
  Open = function(Modinfo)
    if not GameStatus.IsInLobbyOrMainCity() then
      print(bWriteLog and "_DetailTabID.PropShop:IsInLobbyOrMainCity false")
      return false
    end
    if not Modinfo then
      print(bWriteLog and "_DetailTabID.PropShop:Modinfo nil")
      return false
    end
    if not LobbySystem.CheckOpen(BP_ENUM_WOW_PROPSHOP_SWITCH) and not LobbySystem.CheckMarketWhiteListModID(Modinfo.mod_id) then
      print(bWriteLog and "_DetailTabID.PropShop:CheckOpen false")
      return false
    end
    local Util_UGC = require("client.slua.logic.ugc.util_ugc")
    if not Util_UGC.IsModVersionValid(Modinfo) then
      print(bWriteLog and "_DetailTabID.PropShop:IsModVersionValid false")
      return false
    end
    if Modinfo.setting.has_mod_market then
      return true
    end
    print(bWriteLog and "_DetailTabID.PropShop:has_mod_market false")
    return false
  end
}
local _PlayHistoryTab = {
  nID = _DetailTabID.PlayHistory,
  sIcon = "/Game/UMG/Texture_200/Atlas/CreativeMode/Frames/Common_Tab_Play_Review_Select_png.Common_Tab_Play_Review_Select_png",
  dIcon = "/Game/UMG/Texture_200/Atlas/CreativeMode/Frames/Common_Tab_Play_Review_png.Common_Tab_Play_Review_png",
  sModule = "UGCDetailPlayHistorySubPanel",
  sRoot = "CanvasPanel_PlayHistory"
}
Config_UGC.Config_UGClocal _UGC_DetailTabs = {
  _DetailTab,
  _RankTab,
  _CollectionListTab,
  _PropShop,
  _PlayHistoryTab,
  _CrystallizationIncomeTab
}
Config_UGC.Configlocal _UGC_DetailTabPrivate = {_DetailTab, _PropShop}
Config_UGC.Config_UGC_DetailPrivateTabs = _UGC_DetailTabPrivate
local _UGC_WoWSeason_DetailTabs = {
  _DetailTab,
  _PlayHistoryTab,
  _CollectionListTab,
  _PropShop,
  _CrystallizationIncomeTab
}
Config_UGC.Configlocal _ExposureRecordTab = {
  nID = _DetailTabID.Exposure,
  sIcon = "/Game/UMG/Texture_200/Atlas/CreativeMode/Frames/Common_Tab_Exposure_xuanzhong_png.Common_Tab_Exposure_xuanzhong_png",
  dIcon = "/Game/UMG/Texture_200/Atlas/CreativeMode/Frames/Common_Tab_Exposure_png.Common_Tab_Exposure_png",
  sModule = "UGCExposureRecordSubUI",
  sRoot = "CanvasPanel_PromotionRecord"
}
Config_UGC.Config_UGClocal _MinePubDetailTab = {
  nID = _DetailTabID.MineDetail,
  sIcon = "/Game/UMG/Texture_200/Atlas/CreativeMode/Frames/UGC_tab03_png.UGC_tab03_png",
  dIcon = "/Game/UMG/Texture_200/Atlas/CreativeMode/Frames/UGC_tab04_png.UGC_tab04_png",
  sModule = "ugc_mine_edit_public_work",
  sRoot = "CanvasPanel_Detail"
}
local _UGC_MinePubDetailTabs = {
  _MinePubDetailTab,
  _RankTab,
  _CollectionListTab,
  _PropShop,
  _PlayHistoryTab,
  _ExposureRecordTab,
  _CrystallizationIncomeTab
}
Config_UGC.Configlocal _MineReviewDetailTab = {
  nID = _DetailTabID.ReviewDetail,
  sIcon = "/Game/UMG/Texture_200/Atlas/CreativeMode/Frames/UGC_tab03_png.UGC_tab03_png",
  dIcon = "/Game/UMG/Texture_200/Atlas/CreativeMode/Frames/UGC_tab04_png.UGC_tab04_png",
  sModule = "ugc_edit_review_detail",
  sRoot = "CanvasPanel_Detail2"
}
local _UGC_MineReviewDetailTabs = {_MineReviewDetailTab}
Config_UGC.Configlocal _UpdateTabID = {Relate = 1, UpdateLog = 2}
local _RelateTab = {
  nID = _UpdateTabID.Relate,
  nNameID = 70086,
  nSwitcherIndex = 0,
  sCallFunc = "ShowRelate"
}
local _UpdateLogTab = {
  nID = _UpdateTabID.UpdateLog,
  nNameID = 70087,
  nSwitcherIndex = 1,
  sCallFunc = "ShowUpdateLog"
}
local Config_Update_Tabs = {_RelateTab, _UpdateLogTab}
Config_UGC.local _WOWAchievementReuseFallItemType = {
  Content = 1,
  Time = 2,
  Space = 3
}
Config_UGC.Config_UGClocal _MineTabID = {
  Mine = 1,
  Album = 2,
  Comment = 3,
  Message = 4
}
Config_UGC.Config_UGCConfig_UGC.Display_Friend_Type = {
  Played = 1,
  Collection = 2,
  Recommend = 3
}
local _MineTab = {
  nID = _MineTabID.Mine,
  nNameID = 76985,
  sModule = "ugc_mine_works",
  checkShowFunc = function()
    return true
  end
}
local _MessageTab = {
  nID = _MineTabID.Message,
  nNameID = 70069,
  sModule = "UGC_Mine_MessagePanel",
  MaxCount = 120,
  checkShowFunc = function()
    return true
  end
}
local _AlbumTab = {
  nID = _MineTabID.Album,
  nNameID = 70070,
  sModule = "ugc_mine_photo_new",
  checkShowFunc = function()
    return true
  end
}
local _CommentTab = {
  nID = _MineTabID.Comment,
  nNameID = 63019,
  sModule = "Comment_Manage_AllWork_UIBP",
  checkShowFunc = function()
    local logic_ugc_comment_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_comment_switch)
    if not logic_ugc_comment_switch:CheckCommentSwitchOpen() then
      return false
    end
    local LogicUGCAuthor = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthor)
    if LogicUGCAuthor:IsBanned(false) then
      return false
    end
    return true
  end
}
local _UGC_MineTabs = {
  _MineTab,
  _AlbumTab,
  _CommentTab,
  _MessageTab
}
Config_UGC.Configlocal _UGCMessageTabID = {System = 1, Secure = 2}
Config_UGC.Configlocal _SystemTab = {
  nID = _UGCMessageTabID.System,
  NameId = 33711,
  SubID = 1
}
local _SecureTab = {
  nID = _UGCMessageTabID.Secure,
  NameId = 33715,
  SubID = 2
}
local _UGC_MessageTabs = {_SystemTab, _SecureTab}
Config_UGC.Configlocal _UGC_MessageType = {System = 1, Secure = 2}
Config_UGC.Configlocal _UGC_OnlyPhotoTabs = {_AlbumTab}
Config_UGC.Configlocal _EditTabID = {Unpublished = 1, Published = 2}
Config_UGC.Config_UGClocal _UnpublishedTab = {
  nID = _EditTabID.Unpublished,
  nNameID = 70013,
  nSwitcherIndex = 0,
  sCallFunc = "ShowUnpublished"
}
local _PublishedTab = {
  nID = _EditTabID.Published,
  nNameID = 70012,
  nSwitcherIndex = 1,
  sCallFunc = "ShowPublished"
}
local _EditTabs = {_UnpublishedTab, _PublishedTab}
Config_UGC.Config_UGClocal _PublishState = {
  Not = 101,
  Review = 201,
  Published = 401,
  OffShelf = 501,
  ManualReview = 601,
  Rectification = 602,
  Private = 402
}
Config_UGC.Elocal _ModPubState = {Publish = 1, Private = 2}
Config_UGC.Elocal _DisplayFriendState = {
  Friend = 1,
  Collection = 2,
  Recommend = 3
}
Config_UGC.EConfig_UGC.TlogStrState = {
  FriendPlay = 1,
  Collection = 2,
  Recommend = 3,
  FriendPublish = 100,
  Publish = 201,
  Update = 202
}
local _Publish_Localizes = {
  [_PublishState.Not] = 70032,
  [_PublishState.Review] = 70033,
  [_PublishState.Published] = 70035
}
Config_UGC.Configlocal _AuthorWorkInfo = {
  Collect = 1,
  Played = 2,
  Follow = 3,
  Hot = 4,
  Publish = 5
}
Config_UGC.Elocal _AuthorWorkInfo_Localizes = {
  [_AuthorWorkInfo.Collect] = 62716,
  [_AuthorWorkInfo.Played] = 62717,
  [_AuthorWorkInfo.Follow] = 62718,
  [_AuthorWorkInfo.Hot] = 82243,
  [_AuthorWorkInfo.Publish] = 65169
}
Config_UGC.Configlocal _AuthorPlayData = {
  PlayMap = 1,
  CollectMap = 2,
  PlayCount = 3,
  PlayAllTime = 4,
  RankCount = 5,
  Followed = 6,
  ModCollection = 7
}
Config_UGC.Elocal _AuthorPlayData_Localizes = {
  [_AuthorPlayData.PlayMap] = 8910003,
  [_AuthorPlayData.CollectMap] = 8910004,
  [_AuthorPlayData.PlayCount] = 8910005,
  [_AuthorPlayData.PlayAllTime] = 8910006,
  [_AuthorPlayData.RankCount] = 0,
  [_AuthorPlayData.Followed] = 8910007,
  [_AuthorPlayData.ModCollection] = 77905
}
Config_UGC.Configlocal _AuthorGuestSortType = {
  UpdateDate = 1,
  HeatTotal = 2,
  HeatWeek = 3,
  CollectCnt = 4
}
Config_UGC.Clocal _AuthorGuestSortConfig = {
  [_AuthorGuestSortType.UpdateDate] = {
    sKey = "update_date",
    nNameID = 70064
  },
  [_AuthorGuestSortType.HeatTotal] = {sKey = "play_cnt", nNameID = 49635},
  [_AuthorGuestSortType.HeatWeek] = {
    sKey = "play_cnt_week",
    nNameID = 49637
  },
  [_AuthorGuestSortType.CollectCnt] = {
    sKey = "collect_cnt",
    nNameID = 49636
  }
}
Config_UGC.Clocal _FilterTagType = {ETag_Type = 3, ETag_RanTab = 1}
function Config_UGC.GetTemplateConfig()
  return CDataTable.GetTable("UGCTemplateConfig")
end
function Config_UGC.GetTemplateConfigByID(id)
  local LogicUGCTemplate = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCTemplate)
  return LogicUGCTemplate:GetTemplateByID(id)
end
function Config_UGC.GetMapIDByTemplateID(TemplateID)
  local TemplateConfig = Config_UGC.GetTemplateConfigByID(TemplateID)
  return TemplateConfig.MapID
end
function Config_UGC.GetTemplateShowConfig()
  local LogicUGCTemplate = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCTemplate)
  return LogicUGCTemplate:GetTemplates()
end
function Config_UGC.GetTemplateShowConfigByID(id)
  local LogicUGCTemplate = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCTemplate)
  return LogicUGCTemplate:GetTemplateByID(id)
end
function Config_UGC.GetZoneList()
  local zoneList = {}
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  if 6 == ZoneSystem.nChooseZoneID then
    table.insert(zoneList, ZoneSystem.chooseZoneList[ZoneSystem.nChooseZoneID])
    return zoneList
  end
  for _, v in ipairs(ZoneSystem.chooseZoneList) do
    if 6 ~= v.zone_id then
      table.insert(zoneList, v)
    end
  end
  return zoneList
end
local _ShowParamMap = {
  [1] = {
    nLocalizeID = 70017,
    sKey = "min_start_player"
  },
  [2] = {nLocalizeID = 70018, sKey = "map_size"},
  [3] = {nLocalizeID = 70048, sKey = "game_turn"},
  [4] = {nLocalizeID = 87776, sKey = "team_size"},
  [5] = {
    nLocalizeID = 87777,
    sKey = "game_rounds"
  }
}
function Config_UGC.GetShowParam(id)
  return _ShowParamMap[tonumber(id)]
end
local _TemplateType = {
  Base = 1,
  Advanced = 2,
  Guide = 3
}
Config_UGC.EConfig_UGC.AllTemplateID = 99
Config_UGC.AllTemplateConfig = {
  ID = Config_UGC.AllTemplateID,
  Name = ""
}
local _BaseTemplateTab = {
  nNameID = 70052,
  nTitleID = 70078,
  nType = Config_UGC.E_TemplateType.Base
}
local _AdvancedTemplateTab = {
  nNameID = 8502014,
  nTitleID = 70079,
  nType = Config_UGC.E_TemplateType.Advanced
}
local _GuideTemplateTab = {
  nNameID = 71007,
  nTitleID = 70079,
  nType = Config_UGC.E_TemplateType.Guide
}
local Config_Template_Tabs = {
  _BaseTemplateTab,
  _AdvancedTemplateTab,
  _GuideTemplateTab
}
Config_UGC.local _TagUIType = {
  Base = 1,
  Set = 2,
  Filter = 3
}
Config_UGC.E
function Config_UGC.GetTemplateTypeConfigByID(id)
  return CDataTable.GetTableData("UGCTemplateTypeConfig", id)
end
function Config_UGC.GetTemplateTypeConfigByType(type)
  local UGCTemplateTypeConfigs = CDataTable.GetTable("UGCTemplateTypeConfig")
  local templateTypeConfigs = {}
  for _, config in pairs(UGCTemplateTypeConfigs) do
    if config.Type == type then
      table.insert(templateTypeConfigs, config)
    end
  end
  return templateTypeConfigs
end
function Config_UGC.GetTemplateShowConfigByType(type)
  local LogicUGCTemplate = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCTemplate)
  local UGCTemplateConfig = LogicUGCTemplate:GetTemplates() or {}
  local templateList = {}
  local clientVersion = Client.GetAppVersion()
  local version_util = require("client.common.version_util")
  for _, config in pairs(UGCTemplateConfig) do
    if (not config.Version or version_util.CompareVersionStandard(clientVersion, config.Version) >= 0) and config.Type == type then
      table.insert(templateList, config)
    end
  end
  table.sort(templateList, function(a, b)
    if a.Sort ~= b.Sort then
      return a.Sort < b.Sort
    else
      return a.ID < b.ID
    end
  end)
  return templateList
end
function Config_UGC.GetTagConfigByID(id)
  return CDataTable.GetTableData("UGCTagConfig", id)
end
function Config_UGC.GetCompilationsTagConfigByID(id)
  return CDataTable.GetTableData("UGCModCollection", id)
end
function Config_UGC.GetTagTypeConfigByID(id)
  return CDataTable.GetTableData("UGCTagTypeConfig", id)
end
function Config_UGC.GetTagTypeConfigByTag(tag)
  local tagConfig = Config_UGC.GetTagConfigByID(tag)
  if tagConfig then
    return CDataTable.GetTableData("UGCTagTypeConfig", tagConfig.Type)
  else
    return nil
  end
end
function Config_UGC.GetAllTagShowList(type)
  local UGCTagConfig = CDataTable.GetTable("UGCTagConfig")
  local map = {}
  for _, config in pairs(UGCTagConfig) do
    local tagType = config.Type
    local tagTypeCofig = CDataTable.GetTableData("UGCTagTypeConfig", tagType)
    if (type == tagTypeCofig.type or tagTypeCofig.type == _TagUIType.Base) and config.isInvisible ~= 1 then
      if not map[tagType] then
        map[tagType] = {}
      end
      table.insert(map[tagType], config)
    end
  end
  for _, list in pairs(map) do
    table.sort(list, function(a, b)
      if a.SortType == b.SortType then
        return a.ID < b.ID
      else
        return a.SortType > b.SortType
      end
    end)
    local title = CDataTable.GetTableData("UGCTagTypeConfig", list[1].Type)
    table.insert(list, 1, {
      ID = title.ID,
      Name = title.Name,
      Sort = title.Sort,
      Single = title.Single,
      MustSet = title.MustSet
    })
    table.insert(list, 1, {
      ID = title.ID,
      Sort = title.Sort
    })
  end
  local sortList = {}
  for _, v in pairs(map) do
    table.insert(sortList, v)
  end
  table.sort(sortList, function(a, b)
    return a[1].Sort > b[1].Sort
  end)
  local TableUtil = require("common.table_util")
  local showList = {}
  for _, v in ipairs(sortList) do
    showList = TableUtil.TableConcat(showList, v)
  end
  table.remove(showList, 1)
  return showList
end
function Config_UGC.CompilationsGetAllTagShowList()
  local UGCModCollection = CDataTable.GetTable("UGCModCollection")
  local map = {}
  for k, v in pairs(UGCModCollection) do
    table.insert(map, {
      Desc = v.Desc,
      ID = v.ID,
      Name = v.Name,
      Sort = v.Sort,
      Type = 3
    })
  end
  table.sort(map, function(a, b)
    return a.Sort < b.Sort
  end)
  return map
end
function Config_UGC.GetAllGameTypeShowList()
  local UGCTagConfig = CDataTable.GetTable("UGCTagConfig")
  local GameTypeTable = {}
  for _, config in pairs(UGCTagConfig) do
    if config.RankTab == _FilterTagType.ETag_RanTab then
      table.insert(GameTypeTable, config)
    end
  end
  table.sort(GameTypeTable, function(a, b)
    if a.Sort == b.Sort then
      return a.ID < b.ID
    else
      return a.Sort > b.Sort
    end
  end)
  return GameTypeTable
end
function Config_UGC.GetAllTabTypeShowList(Config)
  local UGCTagConfig = CDataTable.GetTable(Config)
  local GameTypeTable = {}
  for _, config in pairs(UGCTagConfig) do
    if config.RankTab == _FilterTagType.ETag_RanTab then
      table.insert(GameTypeTable, config)
    end
  end
  table.sort(GameTypeTable, function(a, b)
    if a.Sort == b.Sort then
      return a.ID < b.ID
    else
      return a.Sort > b.Sort
    end
  end)
  return GameTypeTable
end
function Config_UGC.GetAllGameTypeShowList()
  local UGCTagConfig = CDataTable.GetTable("UGCTagConfig")
  local GameTypeTable = {}
  for _, config in pairs(UGCTagConfig) do
    if config.RankTab == _FilterTagType.ETag_RanTab then
      table.insert(GameTypeTable, config)
    end
  end
  table.sort(GameTypeTable, function(a, b)
    if a.Sort == b.Sort then
      return a.ID < b.ID
    else
      return a.Sort > b.Sort
    end
  end)
  return GameTypeTable
end
function Config_UGC.GetTagTitleConfig(type)
  local UGCTagTypeConfig = CDataTable.GetTable("UGCTagTypeConfig")
  local tagTitleList = {}
  local maxTagNum = 0
  for _, v in pairs(UGCTagTypeConfig) do
    if (type == v.type or v.type == _TagUIType.Base) and v.isInvisible ~= 1 then
      table.insert(tagTitleList, {
        txt = v.NAME,
        Sort = v.Sort,
        Type = v.ID,
        MinNum = v.MinNum,
        MaxNum = v.MaxNum,
        MustSet = v.MustSet
      })
      maxTagNum = maxTagNum + v.MaxNum
    end
  end
  table.sort(tagTitleList, function(a, b)
    return a.Sort > b.Sort
  end)
  return tagTitleList, maxTagNum
end
function Config_UGC.GetTagMaxCountByID(id)
  local config = CDataTable.GetTableData("UGCTagTypeConfig", id)
  if not config then
    return 0
  end
  return config.MaxNum
end
function Config_UGC.GetModReasonConfigByID(reasonId)
  return CDataTable.GetTableData("UGCModReasonConfig", reasonId)
end
Config_UGC.Config_Open_Filter = {
  OpenFilter_Search = 1,
  Openfilter_Collection = 2,
  OpenFilter_Ranking = 3,
  OpenFilter_Season = 4,
  OpenFilter_LabelingFilter_Self = 5,
  OpenFilter_LabelingFilter_Other = 6,
  OpenFilter_WOWTeam = 7,
  OpendFilter_SetLikeTag = 8
}
function Config_UGC:GetAllTagList()
  local UGCTagTypeConfig = self:GetTitleConfig()
  local UGCPrimaryTypeConfig = self:GetPrimaryTypeConfig()
  local UGCTagConfig = self:GetTagConfig()
  for k, v in ipairs(UGCPrimaryTypeConfig) do
    table.insert(UGCTagTypeConfig, v)
  end
  for _, TypeValue in ipairs(UGCTagTypeConfig) do
    local Tag = {}
    for _, TagValue in pairs(UGCTagConfig) do
      if TypeValue.ID == TagValue.Type then
        table.insert(Tag, TagValue)
      end
    end
    if 0 < #Tag then
      table.sort(Tag, function(a, b)
        return a.Sort < b.Sort
      end)
      TypeValue.Tags = Tag
    end
  end
  table.sort(UGCTagTypeConfig, function(a, b)
    return a.Sort < b.Sort
  end)
  return UGCTagTypeConfig
end
function Config_UGC:GetPrimaryTagList()
  local UGCPrimaryTypeConfig = self:GetPrimaryTypeConfig()
  local UGCTagConfig = self:GetTagConfig()
  for _, TypeValue in ipairs(UGCPrimaryTypeConfig) do
    local Tag = {}
    for _, TagValue in pairs(UGCTagConfig) do
      if TypeValue.ID == TagValue.PrimaryType then
        table.insert(Tag, TagValue)
      end
    end
    if 0 < #Tag then
      table.sort(Tag, function(a, b)
        return a.Sort < b.Sort
      end)
      TypeValue.Tags = Tag
    end
  end
  table.sort(UGCPrimaryTypeConfig, function(a, b)
    return a.Sort < b.Sort
  end)
  return UGCPrimaryTypeConfig
end
function Config_UGC:GetFeatureTagList()
  local UGCTagTypeConfig = self:GetTitleConfig()
  local UGCTagConfig = self:GetTagConfig()
  for _, TypeValue in ipairs(UGCTagTypeConfig) do
    local Tag = {}
    for _, TagValue in pairs(UGCTagConfig) do
      if TypeValue.ID == TagValue.Type then
        table.insert(Tag, TagValue)
      end
    end
    if 0 < #Tag then
      table.sort(Tag, function(a, b)
        return a.Sort < b.Sort
      end)
      TypeValue.Tags = Tag
    end
  end
  table.sort(UGCTagTypeConfig, function(a, b)
    return a.Sort < b.Sort
  end)
  return UGCTagTypeConfig
end
function Config_UGC:GetAutoTagList(NeedFilterable)
  local UGCTagTypeConfig = self:GetTitleConfig(true)
  local UGCTagConfig = self:GetTagConfig()
  local AutoTypeConfig = {}
  local AutoTag = {}
  for _, Tags in pairs(UGCTagConfig) do
    if (Tags.Type == 23 or Tags.Type == 24) and (not NeedFilterable or Tags.Filterable == 1) then
      table.insert(AutoTag, Tags)
    end
  end
  for _, TypeValue in ipairs(UGCTagTypeConfig) do
    local Tag = {}
    local needInsert = false
    for _, TagValue in pairs(AutoTag) do
      if TypeValue.ID == TagValue.Type then
        table.insert(Tag, TagValue)
        needInsert = true
      end
    end
    if 0 < #Tag then
      table.sort(Tag, function(a, b)
        return a.Sort < b.Sort
      end)
      TypeValue.Tags = Tag
    end
    if needInsert then
      table.insert(AutoTypeConfig, TypeValue)
    end
  end
  table.sort(AutoTypeConfig, function(a, b)
    return a.Sort < b.Sort
  end)
  return AutoTypeConfig
end
function Config_UGC:GetTitleConfig(NoNeedVisibilityCheck)
  local UGCTagTypeConfig = self:SetTagList(CDataTable.GetTable("UGCTagTypeConfig"), 1, NoNeedVisibilityCheck)
  return UGCTagTypeConfig
end
function Config_UGC:GetTagConfig()
  local UGCTagConfig = self:SetTagList(CDataTable.GetTable("UGCTagConfig"), 2)
  return UGCTagConfig
end
function Config_UGC:GetPrimaryTypeConfig()
  local UGCPrimaryTypeConfig = self:SetTagList(CDataTable.GetTable("UGCPrimaryTypeConfig"), 1)
  return UGCPrimaryTypeConfig
end
function Config_UGC:GetSublabelConfig()
  local UGCSublabelsConfig = self:SetTagList(CDataTable.GetTable("UGCSublabelsConfig"))
  return UGCSublabelsConfig
end
function Config_UGC:SetTagList(TagDataTable, Type, NoNeedVisibilityCheck)
  local DataTable = {}
  local StringUtil = require("common.string_util")
  if not NoNeedVisibilityCheck then
    for k, v in pairs(TagDataTable) do
      if v.isInvisible and v.isInvisible ~= 1 then
        table.insert(DataTable, v)
      end
    end
  else
    local table_util = require("common.table_util")
    DataTable = table_util.CopyTable(TagDataTable)
  end
  if Type == 1 then
    local TagType = {}
    for k, v in pairs(DataTable) do
      table.insert(TagType, {
        ID = v.ID,
        Name = v.Name,
        Sort = v.Sort,
        MinNum = v.MinNum,
        MaxNum = v.MaxNum,
        Tags = 0
      })
    end
    return TagType
  elseif Type == 2 then
    local Tag = {}
    for k, v in pairs(DataTable) do
      local FTags = StringUtil.SplitToNum(v.FeaturesTag, ";")
      table.insert(Tag, {
        ID = v.ID,
        Name = v.Name,
        Sort = v.Sort,
        Type = v.Type,
        Filterable = v.Filterable,
        TagDescriptionKey = v.TagDescriptionKey,
        Sublabels = 0,
        FeaturesTag = FTags,
        PrimaryType = v.PrimaryType
      })
    end
    return Tag
  end
  return DataTable
end
Config_UGC.C_SearchHistoryTagStatus = {
  OpenStatus = 1,
  CloseStatus = 2,
  DeletStatus = 3
}
function Config_UGC.GetAuthorLevelConfig()
  return CDataTable.GetTable("UGCAuthorLevelConfig")
end
function Config_UGC.GetAuthorLevelConfigByID(id)
  return CDataTable.GetTableData("UGCAuthorLevelConfig", id)
end
function Config_UGC.GetCoverMaxNum(authorLevel)
  local authorLevelConfig = Config_UGC.GetAuthorLevelConfigByID(authorLevel)
  if authorLevelConfig then
    return authorLevelConfig.ViewPicMaxNum
  end
  return Config_UGC.DefaultCoverMaxNum
end
function Config_UGC.GetCoverAlbumMaxNum(authorLevel)
  local authorLevelConfig = Config_UGC.GetAuthorLevelConfigByID(authorLevel)
  if authorLevelConfig then
    return authorLevelConfig.AlbumMaxNum
  end
  return Config_UGC.DefaultCoverMaxNum
end
function Config_UGC.GetPerformanceShowCfgByCost(costValue)
  if not costValue then
    log(bWriteLog and "Config_UGC.GetPerformanceShowCfgByCost costValue is invalid")
    return nil
  end
  local UGCPerformanceCostCfg = CDataTable.GetTable("UGCPerformanceCostCfg")
  if not UGCPerformanceCostCfg then
    log(bWriteLog and "Config_UGC.GetPerformanceShowCfgByCost costValue is invalid")
    return nil
  end
  local costCfg
  for _, cfg in pairs(UGCPerformanceCostCfg) do
    if costValue >= cfg.MinCost and (cfg.MinCost >= cfg.MaxCost or costValue < cfg.MaxCost) then
      costCfg = cfg
    end
  end
  return costCfg
end
function Config_UGC.GetMineTabs()
  local tabs = {}
  for _, tab in ipairs(Config_UGC.Config_UGC_MineTabs) do
    if tab.checkShowFunc() then
      table.insert(tabs, tab)
    end
  end
  return tabs
end
function Config_UGC.GetConfigFeedbackOptions()
  local Config_Feedback_Options = {}
  local FeedbackTable = CDataTable.GetTable("UGCGuessLikeFeedback")
  if FeedbackTable then
    for _, Entry in pairs(FeedbackTable) do
      table.insert(Config_Feedback_Options, {
        nNameID = Entry.Title,
        OptionIdx = Entry.Tag
      })
    end
  end
  return Config_Feedback_Options
end
function Config_UGC.RefreshWOWDepot()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local Refresh = {}
  PlayerPrefsSystem.SaveTableToFile_N(Refresh, PlayerPrefsSystem.ePlayerPrefsType.eUGCInventoryRedDot)
end
local Enum_RedPoint_SubID = {Msg = 1, MsgWithAttach = 2}
Config_UGC.local Enum_SearchType = {
  Mod = 1,
  Collections = 2,
  Ranking = 3,
  Season = 4,
  WoWTeam = 5,
  WoWHall = 6
}
Config_UGC.local C_SearchTabs = {
  [1] = {
    Type = Enum_SearchType.Mod,
    Name = 8910013,
    FilterIndex = 2
  },
  [2] = {
    Type = Enum_SearchType.Collections,
    Name = 69262,
    FilterIndex = 3
  }
}
Config_UGC.local C_ScreenTags = {
  [1] = {
    Type = Enum_SearchType.Mod,
    Name = 8910013,
    FilterIndex = 2
  },
  [2] = {
    Type = Enum_SearchType.Collections,
    Name = 69262,
    FilterIndex = 3
  },
  [3] = {
    Type = Enum_SearchType.Ranking,
    Name = 69262,
    FilterIndex = 1
  },
  [4] = {
    Type = Enum_SearchType.season,
    Name = 69262,
    FilterIndex = 4
  },
  [5] = {
    Type = Enum_SearchType.WoWTeam,
    Name = 69262,
    FilterIndex = 5
  }
}
Config_UGC.local C_ModSearchRankType = {
  [1] = {
    Type = "type_default",
    Name = 72015
  },
  [2] = {
    Type = "type_play_time_week",
    Name = 72011
  },
  [3] = {
    Type = "type_play_cnt",
    Name = 72012
  },
  [4] = {
    Type = "type_collect_cnt",
    Name = 72013
  },
  [5] = {
    Type = "type_publish_time",
    Name = 72014
  }
}
Config_UGC.local C_ModSearchRanKingType = {
  [1] = {
    Type = "type_play_time_week",
    Name = 72011
  },
  [2] = {
    Type = "type_play_cnt",
    Name = 72012
  },
  [3] = {
    Type = "type_collect_cnt",
    Name = 72013
  },
  [4] = {
    Type = "type_publish_time",
    Name = 72014
  }
}
Config_UGC.local C_CollectionSearchRankType = {
  [1] = {Type = "default", Name = 72015},
  [2] = {Type = "play_total", Name = 72012},
  [3] = {Type = "num_total", Name = 72013},
  [4] = {Type = "edit_time", Name = 72014}
}
Config_UGC.local C_SearchIndex = {
  One = 1,
  Two = 2,
  Three = 3,
  Four = 4,
  Five = 5,
  Six = 6
}
Config_UGC.local C_SerchState = {
  FastSearch = 1,
  CancelSearch = 2,
  FastSearchTow = 3,
  FormerSearch = 4
}
Config_UGC.local C_UGCShareSrc = {
  ChannelWorld = 1,
  ChannelCorps = 2,
  Club = 3,
  CircleFriends = 4,
  sms = 5,
  twitter = 6,
  facebook = 7,
  whatsapp = 8,
  messenger = 9,
  vk = 10,
  line = 11,
  web = 12,
  qr = 13,
  ChannelFriends = 14
}
Config_UGC.Config_UGC.C_EnterGameNewbieScheme = {
  A_NoMoreGuidance = 1,
  B_GoToBR = 2,
  C_GoToSelectedWoWMod = 3
}
local _DetailSubTabID = {
  None = 0,
  Comment = 1,
  Room = 2
}
Config_UGC.CConfig_UGC.HotRankSubTabID = {
  HotRankHot = 201,
  HotRankCreative = 202,
  HotRankNew = 203
}
Config_UGC.TournamentStage = {
  Vote = 1,
  Play = 2,
  Selection = 3,
  Appeal = 4,
  Publicity = 5
}
Config_UGC.TournamentMODAward = {
  Not_Define = 0,
  Gold = 1,
  Silver = 2,
  Bronze = 3,
  Popularity = 4
}
Config_UGC.ModRankType = {
  Normal = 0,
  Season = 1,
  Friend = 2
}
Config_UGC.E_HomeAuthorWorkInfo = {
  Follow = 1,
  Publish = 2,
  Collect = 3
}
Config_UGC.E_HomeCreativeRevInfo = {
  TotalEarnings = 1,
  DailyEarnings = 2,
  Balance = 3
}
Config_UGC.E_HomeModInfo = {
  TotalPlays = 1,
  TotalCollect = 2,
  TotalHot = 3
}
Config_UGC.SeasonModType = {PVP = 1, ForFun = 2}
Config_UGC.DetailRankReportType = {Gift = 1, Buy = 2}
Config_UGC.UGCReportType = {Normal = 0, Season = 1}
Config_UGC.E_UGCGameStartType = {Normal = 0, Smart = 1}
Config_UGC.E_UGCSmartStartHeatLevelState = {
  QuickStart = 1,
  JoinRoom = 2,
  CreateRoom = 3
}
Config_UGC.E_UGCJoinPlayHallType = {
  Normal = 0,
  Specify = 1,
  HallFirst = 2
}
Config_UGC.E_PlayHallRoomInfoChangeOpt = {
  Add_Room = 1,
  Del_Room = 2,
  Add_Mem = 11,
  Del_Mem = 12,
  Change_State = 101,
  QuickChat = 102
}
Config_UGC.E_UGCPlayHallRoomState = {
  Default = 0,
  Idle = 1,
  CountDown = 2,
  Playing = 3
}
Config_UGC.Enum_DelayUseType = {LimitStartTime = 1, LimitEndTime = 2}
Config_UGC.SpecialAssetParam = {
  [421] = 3
}
Config_UGC.Enum_WOW_FaceStyle = {
  Pic = 1,
  PicTxt = 2,
  Txt = 3
}
Config_UGC.Enum_UGCPASSTask_Status = {
  UnFinish = 0,
  UnReward = 1,
  Finish = 2,
  Expired = 3
}
Config_UGC.Enum_UGCCustomPic_BanType = {Temporary = 1, Permanent = 2}
Config_UGC.Enum_UGCPopup_Type = {
  MineWorksPanel = {
    scene_type = "ugc_mine_main",
    check_strongnewguide_fun = function()
      local logic_ugc_popupcheck = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_popupcheck)
      local bHasStrongNewGuide = logic_ugc_popupcheck.CheckUGCMineMainUIStrongNewGuide()
      return bHasStrongNewGuide
    end
  },
  ModeSelection_Main_UIBP = {
    scene_type = "mode_selection_main",
    check_strongnewguide_fun = function()
      local logic_ugc_popupcheck = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_popupcheck)
      local bHasStrongNewGuide = logic_ugc_popupcheck.CheckUGCModeSelectMainUIStrongNewGuide()
      return bHasStrongNewGuide
    end
  },
  ModeSelection_Wow_UIBP = {
    scene_type = "ModeSelection_Wow_UIBP",
    check_strongnewguide_fun = function()
      local logic_ugc_popupcheck = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_popupcheck)
      local bHasStrongNewGuide = logic_ugc_popupcheck.CheckUGCModeSelectWOWUIStrongNewGuide()
      return bHasStrongNewGuide
    end
  },
  UGC_Hall_UIBP = {
    scene_type = "UGC_Hall_UIBP",
    check_strongnewguide_fun = function()
      local logic_ugc_popupcheck = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_popupcheck)
      local bHasStrongNewGuide = logic_ugc_popupcheck.CheckUGCModeSelectMainUIStrongNewGuide()
      return bHasStrongNewGuide
    end
  }
}
Config_UGC.Enum_WOW_PopupPriority = {
  UGC_AutoTranslate_Popup_UIBP = {
    ui_name = "UGC_AutoTranslate_Popup_UIBP",
    scene_type = Config_UGC.Enum_UGCPopup_Type.ModeSelection_Main_UIBP.scene_type
  },
  UGC_FaceSlap_Popup_UIBP = {
    ui_name = "UGC_FaceSlap_Popup_UIBP",
    scene_type = Config_UGC.Enum_UGCPopup_Type.ModeSelection_Main_UIBP.scene_type
  },
  UGC_WOW_PASS_Pop_BuyPassGuide = {
    ui_name = "UGC_WOW_PASS_Pop_BuyPassGuide",
    scene_type = Config_UGC.Enum_UGCPopup_Type.ModeSelection_Main_UIBP.scene_type
  },
  UGC_WoWPass_Cover_UIBP = {
    ui_name = "UGC_WoWPass_Cover_UIBP",
    scene_type = Config_UGC.Enum_UGCPopup_Type.ModeSelection_Main_UIBP.scene_type
  },
  UGC_CrystalIncentive_Popup_UIBP = {
    ui_name = "UGC_CrystalIncentive_Popup_UIBP",
    scene_type = Config_UGC.Enum_UGCPopup_Type.ModeSelection_Main_UIBP.scene_type
  },
  UGC_Main_Intention_Panel_UI = {
    ui_name = "UGC_Main_Intention_Panel_UI",
    scene_type = Config_UGC.Enum_UGCPopup_Type.ModeSelection_Main_UIBP.scene_type
  },
  UGC_ThemePlay_ActivityTemplate_FaceSlap_UIBP = {
    ui_name = "UGC_ThemePlay_ActivityTemplate_FaceSlap_UIBP",
    scene_type = Config_UGC.Enum_UGCPopup_Type.ModeSelection_Main_UIBP.scene_type
  },
  UGC_WOWCoinRecharge_Notice_UIBP = {
    ui_name = "UGC_WOWCoinRecharge_Notice_UIBP",
    scene_type = Config_UGC.Enum_UGCPopup_Type.ModeSelection_Main_UIBP.scene_type
  }
}
Config_UGC.Enum_WOW_QuickEntry_PopupPriority = {
  UGC_AutoTranslate_Popup_UIBP = {
    ui_name = "UGC_AutoTranslate_Popup_UIBP",
    scene_type = Config_UGC.Enum_UGCPopup_Type.ModeSelection_Wow_UIBP.scene_type
  },
  UGC_FaceSlap_Popup_UIBP = {
    ui_name = "UGC_FaceSlap_Popup_UIBP",
    scene_type = Config_UGC.Enum_UGCPopup_Type.ModeSelection_Wow_UIBP.scene_type
  },
  UGC_WOW_PASS_Pop_BuyPassGuide = {
    ui_name = "UGC_WOW_PASS_Pop_BuyPassGuide",
    scene_type = Config_UGC.Enum_UGCPopup_Type.ModeSelection_Wow_UIBP.scene_type
  },
  UGC_ThemePlay_ActivityTemplate_FaceSlap_UIBP = {
    ui_name = "UGC_ThemePlay_ActivityTemplate_FaceSlap_UIBP",
    scene_type = Config_UGC.Enum_UGCPopup_Type.ModeSelection_Wow_UIBP.scene_type
  },
  UGC_WoWPass_Cover_UIBP = {
    ui_name = "UGC_WoWPass_Cover_UIBP",
    scene_type = Config_UGC.Enum_UGCPopup_Type.ModeSelection_Wow_UIBP.scene_type
  },
  UGC_CrystalIncentive_Popup_UIBP = {
    ui_name = "UGC_CrystalIncentive_Popup_UIBP",
    scene_type = Config_UGC.Enum_UGCPopup_Type.ModeSelection_Wow_UIBP.scene_type
  },
  UGC_Main_Intention_Panel_UI = {
    ui_name = "UGC_Main_Intention_Panel_UI",
    scene_type = Config_UGC.Enum_UGCPopup_Type.ModeSelection_Wow_UIBP.scene_type
  },
  UGC_WOWCoinRecharge_Notice_UIBP = {
    ui_name = "UGC_WOWCoinRecharge_Notice_UIBP",
    scene_type = Config_UGC.Enum_UGCPopup_Type.ModeSelection_Wow_UIBP.scene_type
  }
}
Config_UGC.Enum_Hall_Left_PopupPriority = {
  UGC_AutoTranslate_Popup_UIBP = {
    ui_name = "UGC_AutoTranslate_Popup_UIBP",
    scene_type = Config_UGC.Enum_UGCPopup_Type.UGC_Hall_UIBP.scene_type
  },
  UGC_FaceSlap_Popup_UIBP = {
    ui_name = "UGC_FaceSlap_Popup_UIBP",
    scene_type = Config_UGC.Enum_UGCPopup_Type.UGC_Hall_UIBP.scene_type
  },
  UGC_WOW_PASS_Pop_BuyPassGuide = {
    ui_name = "UGC_WOW_PASS_Pop_BuyPassGuide",
    scene_type = Config_UGC.Enum_UGCPopup_Type.UGC_Hall_UIBP.scene_type
  },
  UGC_WoWPass_Cover_UIBP = {
    ui_name = "UGC_WoWPass_Cover_UIBP",
    scene_type = Config_UGC.Enum_UGCPopup_Type.UGC_Hall_UIBP.scene_type
  },
  UGC_CrystalIncentive_Popup_UIBP = {
    ui_name = "UGC_CrystalIncentive_Popup_UIBP",
    scene_type = Config_UGC.Enum_UGCPopup_Type.UGC_Hall_UIBP.scene_type
  },
  UGC_Main_Intention_Panel_UI = {
    ui_name = "UGC_Main_Intention_Panel_UI",
    scene_type = Config_UGC.Enum_UGCPopup_Type.UGC_Hall_UIBP.scene_type
  },
  UGC_ThemePlay_ActivityTemplate_FaceSlap_UIBP = {
    ui_name = "UGC_ThemePlay_ActivityTemplate_FaceSlap_UIBP",
    scene_type = Config_UGC.Enum_UGCPopup_Type.UGC_Hall_UIBP.scene_type
  },
  UGC_WOWCoinRecharge_Notice_UIBP = {
    ui_name = "UGC_WOWCoinRecharge_Notice_UIBP",
    scene_type = Config_UGC.Enum_UGCPopup_Type.UGC_Hall_UIBP.scene_type
  }
}
Config_UGC.MineWorksPanelTips_Sort = {
  UGC_ColdBoot_Popup_UIBP = {
    ui_name = "UGC_ColdBoot_Popup_UIBP",
    scene_type = Config_UGC.Enum_UGCPopup_Type.MineWorksPanel.scene_type
  },
  UGC_MineEverydayDataTips = {
    ui_name = "UGC_MineEverydayDataTips",
    scene_type = Config_UGC.Enum_UGCPopup_Type.MineWorksPanel.scene_type
  },
  UGC_Author_Levelup_Popup_UIBP = {
    ui_name = "UGC_Author_Levelup_Popup_UIBP",
    scene_type = Config_UGC.Enum_UGCPopup_Type.MineWorksPanel.scene_type
  },
  UGC_Author_Levelup_Popup_UIBP2 = {
    ui_name = "UGC_Author_Levelup_Popup_UIBP2",
    scene_type = Config_UGC.Enum_UGCPopup_Type.MineWorksPanel.scene_type
  },
  UGCAuthorProgressPopUI = {
    ui_name = "UGCAuthorProgressPopUI",
    scene_type = Config_UGC.Enum_UGCPopup_Type.MineWorksPanel.scene_type
  },
  UGC_IncentiveRevenue_AuthorReward_Guide = {
    ui_name = "UGC_IncentiveRevenue_AuthorReward_Guide",
    scene_type = Config_UGC.Enum_UGCPopup_Type.MineWorksPanel.scene_type
  }
}
Config_UGC.Enum_WOWPass_RewardType = {Normal = 0, Elite = 1}
Config_UGC.Enum_WOWPass_Select = {
  WoWPass = "WoWPass",
  Task = "Task",
  Exchange = "Exchange"
}
Config_UGC.Enum_EditPublicWorkItemScore = {
  UgcMineWorksPanel = 1,
  UGC_PlayMap_Popup_UIBP = 2,
  UGC_AuthorModPage = 3,
  UGC_Author_CreativeCenter = 4,
  UI_UGC_Guest_Works = 5
}
Config_UGC.Enum_Promotion_ReqType = {UGCInternalSettlement = 1001, UGCHall = 1002}
Config_UGC.Enum_Become_Creator_Type = {
  ManagementSettings = 3,
  AnswerReview = 4,
  InvitationCode = 5,
  AnswerExemptReview = 7
}
Config_UGC.Enum_PromotionReportType = {
  HotThemePromotion = 100,
  ResultPromotion = 101,
  RankingPromotion = 102
}
Config_UGC.AuthorLevelOpenFreeInOut = 21
Config_UGC.Enum_Author_Type = {Old = 1, New = 2}
Config_UGC.Enum_NewMapTLogID = {Daily = 1060001, Potential = 1060002}
local _ResMgrTabID = {
  MyShare = 1,
  Added = 2,
  MyPrivate = 3
}
Config_UGC.Enum_PrefaMall_ResMgrTagID = _ResMgrTabID
local _MyShareTab = {
  nID = _ResMgrTabID.MyShare,
  nNameID = 8888685,
  sModule = "CreativeModePrefabMallMyShareUI"
}
local _PublishedTab = {
  nID = _ResMgrTabID.Added,
  nNameID = 99009831,
  sModule = "CreativeModePrefabMallMyFavoriteUI"
}
local _MyPrivateTab = {
  nID = _ResMgrTabID.MyPrivate,
  nNameID = 99009830,
  sModule = "CreativeModePrefabMallMyPrivateUI"
}
Config_UGC.Enum_PrefaMall_ResMgrTag = {
  _MyShareTab,
  _PublishedTab,
  _MyPrivateTab
}
Config_UGC.Enum_PrefaMall_SearchSource = {Mall = 1, Bag = 2}
Config_UGC.MetaWithAssetParamVersion = 10016
Config_UGC.AssetDependFeatureKey = {}
Config_UGC.EditorTypeDependResType = {
  1,
  6,
  62
}
Config_UGC.BeforeVersionPatchResList = {
  [10016] = {
    AssetIDList = {
      3101084,
      3101085,
      3101086,
      3101094,
      3101095,
      3101096,
      3101098
    },
    FeatureKeyList = {}
  }
}
Config_UGC.PatchResList = {
  [10016] = {
    AssetIDList = {},
    FeatureKeyList = {}
  }
}
Config_UGC.ForceDependAssetIDList = {3202100, 3202106}
Config_UGC.ExpiredFeatureKeys = {}
Config_UGC.Enum_UGCShareTask_Status = {
  Not = 0,
  Done = 1,
  Reward = 2
}
local _MineTabID = {
  MyCollect = 1,
  History = 2,
  Subscribe = 3
}
Config_UGC.Enumlocal _MyCollectTab = {
  nID = _MineTabID.MyCollect,
  nNameID = 65139,
  Tlog = TLogEventDefine.UGC_Mine_Collect,
  sModule = "UGC_WoW_Mine_Secondary_UI"
}
local _HistoryTab = {
  nID = _MineTabID.History,
  TlogID = _TabID.History,
  nNameID = 81317,
  Tlog = TLogEventDefine.UGC_Mine_History,
  sModule = "UGCHistoryPanel"
}
local _SubscribeTab = {
  nID = _MineTabID.Subscribe,
  nNameID = 81318,
  Tlog = TLogEventDefine.UGC_Mine_Subscribe,
  sModule = "UGC_WoW_Mine_Secondary_UI"
}
Config_UGC.Enum_UGCHall_Mine_Tab = {
  _MyCollectTab,
  _HistoryTab,
  _SubscribeTab
}
local _MineSubTabID = {
  CollectWorks = 104,
  MyCollection = 113,
  Collection = 114,
  FriendUpdates = 115,
  Follow = 107,
  Friend = 110
}
Config_UGC.Enumlocal _CollectWorksTab = {
  ID = _MineSubTabID.CollectWorks,
  NameID = 8910004,
  Tlog = TLogEventDefine.UGC_Mine_Sub_Collect,
  Module = "UGCCollectPanel"
}
local _MyCollectionTab = {
  ID = _MineSubTabID.MyCollection,
  NameID = 81329,
  Tlog = TLogEventDefine.UGC_Mine_Sub_MyCollection,
  Module = "UGCCollectionListPanel"
}
local _CollectionTab = {
  ID = _MineSubTabID.Collection,
  NameID = 81330,
  Tlog = TLogEventDefine.UGC_Mine_Sub_LikeCollection,
  Module = "UGCLikeCollectionListPanel"
}
local _MineCollectTabs = {
  _CollectWorksTab,
  _MyCollectionTab,
  _CollectionTab
}
Config_UGC.Enum_UGCHall_Mine_Collect_Tab = _MineCollectTabs
local _FriendUpdatesTab = {
  ID = _MineSubTabID.FriendUpdates,
  NameID = 81325,
  Tlog = TLogEventDefine.UGC_Mine_Sub_FriendUpdates,
  Module = "UGCFriendUpdatesPanel"
}
local _MyFollowTab = {
  ID = _MineSubTabID.Follow,
  NameID = 81326,
  Tlog = TLogEventDefine.UGC_Mine_Sub_Follow,
  Module = "UGCFollowPanel"
}
local _MyFriendTab = {
  ID = _MineSubTabID.Friend,
  NameID = 81327,
  Tlog = TLogEventDefine.UGC_Mine_Sub_Friend,
  Module = "UGCFriendPanel"
}
local _MineSubscribeTabs = {
  _FriendUpdatesTab,
  _MyFollowTab,
  _MyFriendTab
}
Config_UGC.Enum_UGCHall_Mine_Subscribe_Tab = _MineSubscribeTabs
local _EnumDownLoadSource = {
  UGCMineEditNoramlWorkItem = 1,
  UgcCreateModPanel = 2,
  UgcMineEditNormalWorkPanel = 3,
  UGCDetailOperateSubPanel = 4
}
Config_UGC.EnumDownLoadSource = _EnumDownLoadSource
Config_UGC.TemplateUpload = {MAX_MSG_CHAR_CNT_DESC = 128}
Config_UGC.UGC_RankMineHistoryFilter = {
  {
    sKey = "last_play_time",
    nNameID = 38905
  },
  {
    sKey = "type_play_cnt",
    nNameID = 70065
  },
  {
    sKey = "type_play_cnt_week",
    nNameID = 70077
  },
  {
    sKey = "type_total_play_time",
    nNameID = 81401
  }
}
Config_UGC.UGC_RankMineCollectFilter = {
  {
    sKey = "type_collect_time",
    nNameID = 81370
  },
  {
    sKey = "type_play_cnt",
    nNameID = 70065
  },
  {
    sKey = "type_play_cnt_week",
    nNameID = 70077
  },
  {
    sKey = "type_update_time",
    nNameID = 81371
  }
}
Config_UGC.SearchHotTagState = {
  MainPage = 1,
  HotSearch = 2,
  Typing = 3,
  SearchDone = 4
}
Config_UGC.ObtainExposureCouponPath = {
  {
    Name = 7095,
    color = nil,
    OpenFunc = function()
      return true
    end,
    ClickFunc = function()
      local Config_UGC_Center = require("client.slua.logic.ugc.center.config_ugc_center")
      local logic_ugc_center = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_center)
      logic_ugc_center:OpenUGCCenterMainUI(Config_UGC_Center.Config_UGC_Center_TabID.Store)
    end
  },
  {
    Name = 8600088,
    color = nil,
    OpenFunc = function()
      return true
    end,
    ClickFunc = function()
      local Config_UGC_Center = require("client.slua.logic.ugc.center.config_ugc_center")
      local logic_ugc_center = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_center)
      logic_ugc_center:OpenUGCCenterMainUI(Config_UGC_Center.Config_UGC_Center_TabID.CreatorsGrow, Config_UGC_Center.Config_UGC_Center_TabID.Mission)
    end
  },
  {
    Name = 68890,
    color = nil,
    OpenFunc = function()
      if IsWoWEditor then
        return false
      end
      return true
    end,
    ClickFunc = function()
      local logic_ugc_WOWPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_WOWPass)
      logic_ugc_WOWPass:OpenWowPassPanel(UIManager.UI_Config.UGC_WOW_PASS_MainUI, nil, true)
    end
  }
}
Config_UGC.Enum_OutcomeType = {
  Win = 0,
  Lose = 1,
  Draw = 2
}
return Config_UGC