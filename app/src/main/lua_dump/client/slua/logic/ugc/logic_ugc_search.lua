local Logic_ugc_search = {
  bShowGuidePopTip = false,
  ugc_V420_all_mix = nil,
  LanguageTab = {},
  mod_metaList = {},
  mod_compcompilations_List = {},
  SearchText = "",
  temp = 0,
  GuessTable = {}
}
local C_SearchInfoReqCD = 300
local C_SearchResultReqCD = 120
function Logic_ugc_search:DefineAndResetData()
  self.RecommendSearchTextIndex = 0
  self.RecommendSearchTextRandomList = nil
  self.SearchInfoReqTime = 0
  self.LanguageTab = {}
  self.GuessTable = {}
  self.SearchText = ""
  self.OldSearchText = ""
  self.SearchModMetaMap = {}
  self.SearchCollectionMetaMap = {}
  self.keywordName = ""
  self.SelectFilterTags = {}
  self.SearchTipsData = {}
  self.WordCompReqTimer = nil
  self.Search_extra_data = {}
  self.SearchModMetaMapFeeds = {}
end
function Logic_ugc_search:OnInitialize()
end
function Logic_ugc_search:OnLogin(bReLogin)
end
function Logic_ugc_search:OnLogOut()
end
function Logic_ugc_search:CheckShowGuide()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local NewLevelSlapData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCSearchGuidance)
  if NewLevelSlapData then
    return false
  else
    return true
  end
end
function Logic_ugc_search:SetSearchText(Text)
  self.Searchend
function Logic_ugc_search:SetShowGuidePop(bShow)
  self.bShowGuidePopTip = bShow
end
function Logic_ugc_search:ReqGetSearchInfo()
  local TimeUtil = require("client.common.time_util")
  local NowTime = TimeUtil.GetServerTimeInSec()
  if NowTime > self.SearchInfoReqTime + C_SearchInfoReqCD then
    self.SearchInfoReqTime = NowTime
    self.RecommendSearchTextIndex = 0
    local UGCSearchHandler = require("client.network.Protocol.UGCSearchHandler")
    local Language = Client.GetCurrentLanguage()
    Language = string.lower(Language)
    UGCSearchHandler.send_ugc_get_search_info_req(Language)
  else
    self:UpdateRecommendSearchText()
  end
end
function Logic_ugc_search:InitRecommendSearchText()
  local MaxNum = math.min(#self.LanguageTab, 10)
  local RandomList = {}
  for i = 1, MaxNum do
    RandomList[i] = i
  end
  self.RecommendSearchTextRandomList = {}
  while 0 < #RandomList do
    local Random = math.random(1, #RandomList)
    local RandomVal = table.remove(RandomList, Random)
    table.insert(self.RecommendSearchTextRandomList, RandomVal)
  end
end
function Logic_ugc_search:UpdateRecommendSearchText()
  if not self.LanguageTab or not next(self.LanguageTab) then
    return
  end
  local MaxNum = math.min(#self.LanguageTab, 10)
  if self.RecommendSearchTextIndex == 0 or MaxNum < self.RecommendSearchTextIndex then
    self.RecommendSearchTextIndex = 1
    self:InitRecommendSearchText()
  else
    self.RecommendSearchTextIndex = self.RecommendSearchTextIndex + 1
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_HOT_SEARCH_RSP)
end
function Logic_ugc_search:GetRecommendSearchText()
  local RandomIndex = 1
  if self.RecommendSearchTextRandomList then
    RandomIndex = self.RecommendSearchTextRandomList[self.RecommendSearchTextIndex] or 1
  end
  if self.LanguageTab and #self.LanguageTab > 0 and RandomIndex <= #self.LanguageTab then
    return self.LanguageTab[RandomIndex].name or ""
  end
  return ""
end
function Logic_ugc_search:SetOldsearchhText(NameText)
  self.OldSearchText = NameText
end
function Logic_ugc_search:GetOldsearchhText(NameText)
  return self.OldSearchText
end
function Logic_ugc_search:GetSearchText()
  if self.SearchText and self.SearchText ~= "" then
    return self.SearchText
  end
  return self:GetRecommendSearchText()
end
function Logic_ugc_search:GenerateSearchCacheKey(keyword, rank_type, tag_list, is_ugc_season, feature_tag_list)
  if keyword == nil then
    keyword = ""
  end
  if tag_list == nil then
    tag_list = {}
  end
  if not is_ugc_season then
    is_ugc_season = ""
  else
    is_ugc_season = "is_ugc_season"
  end
  if rank_type == nil then
    rank_type = ""
  end
  if feature_tag_list == nil then
    feature_tag_list = {}
  end
  local TagKey = table.concat(tag_list, "-")
  local FeatureTagKey = table.concat(feature_tag_list, "-")
  local CacheKey = keyword .. "|-|" .. rank_type .. "|-|" .. TagKey .. "|-|" .. is_ugc_season .. "|-|" .. FeatureTagKey
  return CacheKey
end
function Logic_ugc_search:GetSearchModMetaList(keyword, rank_type, tag_list, is_ugc_season, feature_tag_list)
  local Key = self:GenerateSearchCacheKey(keyword, rank_type, tag_list, is_ugc_season, feature_tag_list)
  return self.SearchModMetaMap[Key]
end
function Logic_ugc_search:SetSearchModMeta(keyword, rank_type, tag_list, ret_info, is_ugc_season, feature_tag_list)
  local TimeUtil = require("client.common.time_util")
  local NowTime = TimeUtil.GetServerTimeInSec()
  local Cache = {
    MetaList = ret_info or {},
    ReqTime = NowTime
  }
  local Key = self:GenerateSearchCacheKey(keyword, rank_type, tag_list, is_ugc_season, feature_tag_list)
  self.SearchModMetaMap[Key] = Cache
end
function Logic_ugc_search:GetSearchCollectionMetaList(keyword, rank_type, tag_list, feature_tag_list)
  local Key = self:GenerateSearchCacheKey(keyword, rank_type, tag_list, feature_tag_list)
  local Cache = self.SearchCollectionMetaMap[Key]
  if Cache then
    local TimeUtil = require("client.common.time_util")
    local NowTime = TimeUtil.GetServerTimeInSec()
    if NowTime > Cache.ReqTime + C_SearchResultReqCD then
      self.SearchCollectionMetaMap[Key] = nil
    end
  end
  return self.SearchCollectionMetaMap[Key]
end
function Logic_ugc_search:SetSearchCollectionMeta(keyword, rank_type, tag_list, ret_info, feature_tag_list)
  local TimeUtil = require("client.common.time_util")
  local NowTime = TimeUtil.GetServerTimeInSec()
  local Cache = {
    MetaList = ret_info or {},
    ReqTime = NowTime
  }
  local Key = self:GenerateSearchCacheKey(keyword, rank_type, tag_list, feature_tag_list)
  self.SearchCollectionMetaMap[Key] = Cache
end
function Logic_ugc_search:SaveHistory(keyword)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  if not keyword then
    return
  end
  local StringUtil = require("common.string_util")
  local _, _, SaveText = StringUtil.CheckNameNew(keyword, true, 20, true)
  local bAllSpace = StringUtil:CheckStringWithSpace(SaveText)
  if SaveText == "" or bAllSpace then
    return
  end
  local redPoint = {}
  local SavePoint = {}
  redPoint = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCSearchHistory)
  if not redPoint then
    table.insert(SavePoint, SaveText)
    PlayerPrefsSystem.SaveTableToFile_N(SavePoint, PlayerPrefsSystem.ePlayerPrefsType.eUGCSearchHistory)
    return
  end
  for k, v in pairs(redPoint) do
    if SaveText == v then
      table.remove(redPoint, k)
      break
    end
  end
  if 12 <= #redPoint then
    table.remove(redPoint, 1)
  end
  table.insert(redPoint, SaveText)
  PlayerPrefsSystem.SaveTableToFile_N(redPoint, PlayerPrefsSystem.ePlayerPrefsType.eUGCSearchHistory)
end
function Logic_ugc_search:GetRankMechanism(Mechanism)
  log(bWriteLog and "Logic_ugc_search:GetRankMechanism Mechanism: " .. tostring(Mechanism))
  self.ugc_V420_all_mix = Mechanism
end
function Logic_ugc_search:OnUgcGetSearchInfoRsp(HotSearch, Icon_search)
  log_tree("Logic_ugc_search:OnUgcGetSearchInfoRsp  HotSearch = ", HotSearch)
  log_tree("Logic_ugc_search:OnUgcGetSearchInfoRsp  Icon_search = ", Icon_search)
  local Hot = {}
  if HotSearch then
    for k, v in pairs(HotSearch) do
      if Icon_search and Icon_search[v] then
        Hot[k] = {
          name = v,
          icon = Icon_search[v]
        }
      else
        Hot[k] = {name = v}
      end
    end
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    if PublishRegionMacros.IsBLUEHOLE() then
      self.LanguageTab = {}
    else
      self.LanguageTab = Hot
    end
  end
  if self.LanguageTab and #self.LanguageTab > 0 then
    self.randomIndex = math.random(1, #self.LanguageTab)
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_NEWSERCHHITTEXT_MOD, self.LanguageTab[self.randomIndex].name)
  end
  self:UpdateRecommendSearchText()
end
function Logic_ugc_search:on_ugc_combined_search_mod_rsp(err_code, keyword, rank_type, tag_list, ret_info, is_ugc_season, feature_tag_list, extra_data)
  if bWriteLog then
    print(bWriteLog and "[edward] Logic_ugc_search:on_ugc_combined_search_mod_rsp ,keyword, rank_type, tag_list, ret_info, feature_tag_list = ", keyword, rank_type, tag_list, ret_info, feature_tag_list)
  end
  if not keyword then
    self.keywordName = ""
  else
    self.keywordName = keyword
  end
  if err_code == 0 then
    self:SaveHistory(self.keywordName)
  end
  self.Search_  self:SetSearchModMeta(keyword, rank_type, tag_list, ret_info, is_ugc_season, feature_tag_list)
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  LogicUGC.PromotionShowIndex = 0
  if not ret_info or #ret_info == 0 then
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_SEARCH_THERESULTNIU)
    return
  end
  self:CheckMoreMapList(ret_info, keyword, is_ugc_season)
end
function Logic_ugc_search:on_ugc_personal_recommond_rsp(info)
  log_tree("Logic_ugc_search:on_ugc_personal_recommond_rsp info = ", info)
  if not info or not next(info) then
    log(bWriteLog and "Logic_ugc_search:on_ugc_personal_recommond_rsp info is nil")
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_INDIVIDUATION_THERESULTNIL)
    return
  end
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  self.IndividuationModIdList = {}
  for _, Mod in ipairs(info) do
    table.insert(self.IndividuationModIdList, Mod.mod_id)
  end
  self:SetSearchModMeta("", Config_UGC.C_ModSearchRankType[1].Type, {}, self.IndividuationModIdList)
  self:CheckMoreMapList(self.IndividuationModIdList, "", nil, true)
end
function Logic_ugc_search:ugc_get_guess_search_text_rsp(table)
  log_tree("Logic_ugc_search:ugc_get_guess_search_text_rsp Table = ", table)
  self.GuessTable = table or {}
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_SEARCH_GEUSSYOU)
end
function Logic_ugc_search:GetGuessYouTable()
  if self.GuessTable and #self.GuessTable > 0 then
    return true
  end
  local UGCSearchHandler = require("client.network.Protocol.UGCSearchHandler")
  UGCSearchHandler.send_ugc_get_guess_search_text_req()
  return false
end
function Logic_ugc_search:SetMapListClear()
  self.mod_metaList = nil
end
function Logic_ugc_search:CompilationsSetMapListClear()
  self.mod_compcompilations_List = nil
end
function Logic_ugc_search:SetLanguageTabClear()
  self.LanguageTab = {}
end
function Logic_ugc_search:CheckMoreMapList(MetaList, keyword, is_ugc_season, is_Individuation)
  if not MetaList or #MetaList == 0 then
    log(bWriteLog and "[edward] Logic_ugc_search:CheckMoreMapList, no meta list")
    return
  end
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local ListType
  local LogicUgcFilterTag = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUgcFilterTag)
  if is_ugc_season then
    ListType = LogicUGC.C_ModListTypes.WonderSeason
  elseif is_Individuation then
    ListType = LogicUGC.C_ModListTypes.RankTypeDefault
  else
    ListType = LogicUGC.C_ModListTypes.SearchWorks
  end
  local _, ReqList = LogicUGC:BatchGetModInfo(MetaList, ListType, nil, {bSplit = true, bGetPlayReq = true})
  local bToRequest = ReqList and 0 < #ReqList
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_NEWCSEARCH_MOD, bToRequest, nil, self.keywordName)
end
function Logic_ugc_search:on_ugc_combined_search_collection_rsp(keyword, rank_type, tag_list, ret_info, feature_tag_list)
  print(bWriteLog and "[edward] Logic_ugc_search:on_ugc_combined_search_collection_rsp, ", keyword, rank_type)
  self:SetSearchCollectionMeta(keyword, rank_type, tag_list, ret_info, feature_tag_list)
  if not ret_info or #ret_info == 0 then
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_SEARCH_THERESULTNIU)
    return
  end
  self:CheckMoreCollectionList(ret_info)
end
function Logic_ugc_search:CheckMoreCollectionList(MetaList)
  if not MetaList or #MetaList == 0 then
    log(bWriteLog and "[edward] Logic_ugc_search:CheckMoreCollectionList, no meta list")
    return
  end
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  local MaxReqNum = Config_UGC.ReqModInfoMaxNum
  local ReqList = {}
  local LogicUGCCollectionList = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCCollectionList)
  for k, CollectionID in ipairs(MetaList) do
    local Collection = LogicUGCCollectionList:GetCollectionInfo(CollectionID)
    if not Collection then
      table.insert(ReqList, CollectionID)
    end
    if MaxReqNum <= #ReqList then
      log(bWriteLog and "[edward] Logic_ugc_search:CheckMoreCollectionList, ReqList is max ")
      break
    end
  end
  local bToRequest = false
  if 0 <= #ReqList then
    bToRequest = true
    LogicUGCCollectionList:NewReqSearchCollection(ReqList)
  end
  log(bWriteLog and "[edward] Logic_ugc_search:CheckMoreCollectionList, #ReqList = " .. #ReqList)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_NEWCCOMPILATIONSSEARCH_MOD, bToRequest)
end
function Logic_ugc_search:OnModInfoBatchRsp(MetaList, ListType, Param, FilterOfflineModList)
  local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
  if not UGCMacros.CheckMetaType(ListType, UGCMacros.ENUM_MODE_TYPE.SearchWorks) and not UGCMacros.CheckMetaType(ListType, UGCMacros.ENUM_MODE_TYPE.WonderSeason) and not UGCMacros.CheckMetaType(ListType, UGCMacros.ENUM_MODE_TYPE.RankTypeDefault) then
    return
  end
  local bIsDirty = false
  if next(MetaList) then
    bIsDirty = true
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_NEWCSEARCH_MOD, false, bIsDirty, self.keywordName)
end
function Logic_ugc_search:SetSelectFilterTags(FilterTags)
  self.Selectend
function Logic_ugc_search:SearchWordCompReq(input)
  if not input then
    log(bWriteLog and "Logic_ugc_search:SearchWordCompReq input nil")
    return
  end
  if self.WordCompReqTimer then
    self:RemoveTimer(self.WordCompReqTimer)
    self.WordCompReqTimer = nil
  end
  if #self.SearchTipsData >= 1 and self.SearchTipsData[input] then
    self:SearchWordCompRsp(input, self.SearchTipsData[input])
  else
    self.WordCompReqTimer = self:AddTimerOnce(0.5, function()
      self.WordCompReqTimer = nil
      local UGCSearchHandler = require("client.network.Protocol.UGCSearchHandler")
      UGCSearchHandler.send_ugc_search_word_comp_req(input)
    end)
  end
end
function Logic_ugc_search:SearchWordCompRsp(input, ret_info)
  if input then
    log(bWriteLog and "Logic_ugc_search:SearchWordCompRsp input = " .. input)
    log_tree("Logic_ugc_search:SearchWordCompRsp ret_info = ", ret_info)
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_SEARCH_COMPLETION, input, ret_info)
    if ret_info and 1 <= #ret_info then
      self.SearchTipsData[input] = ret_info
    end
  else
    log(bWriteLog and "Logic_ugc_search:SearchWordCompRsp input nil")
  end
end
function Logic_ugc_search:RemoveSearchTipsData()
  self.SearchTipsData = {}
end
function Logic_ugc_search:on_ugc_gallery_explore_mix_rsp(info)
  log_tree("Logic_ugc_search:on_ugc_gallery_explore_mix_rsp info = ", info)
  if not info or not next(info) then
    log(bWriteLog and "Logic_ugc_search:on_ugc_gallery_explore_mix_rsp info is nil")
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_INDIVIDUATION_THERESULTNIL)
    return
  end
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  self.ComprehensiveModIdList = {}
  self.ComprehensiveModIdList = info
  self:SetSearchModMeta("", Config_UGC.C_ModSearchRankType[1].Type, {}, self.ComprehensiveModIdList)
  self:CheckMoreMapList(self.ComprehensiveModIdList, "", nil, true)
end
function Logic_ugc_search:on_ugc_gallery_feeds_rsp(info)
  if not info or not next(info) then
    log(bWriteLog and "Logic_ugc_search:on_ugc_gallery_feeds_rsp info is nil")
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_INDIVIDUATION_THERESULTNIL)
    return
  end
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  self.ComprehensiveModIdList = {}
  self.ComprehensiveModIdList = info
  local LogicUgcFilterTag = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUgcFilterTag)
  local tag_list = {}
  if LogicUgcFilterTag.SlectFineModTag and LogicUgcFilterTag.SlectFineModTag.ID == 0 then
    tag_list = {}
  elseif LogicUgcFilterTag.SlectFineModTag then
    for k, v in pairs(LogicUgcFilterTag.SlectFineModTag.Tags) do
      table.insert(tag_list, v.ID)
    end
  end
  self:SetSearchModMetaFeeds("", Config_UGC.C_ModSearchRankType[2].Type, tag_list, self.ComprehensiveModIdList)
  self:CheckMoreMapList(self.ComprehensiveModIdList, "", nil, true)
end
function Logic_ugc_search:GetTraceid()
  if self.Search_extra_data and self.Search_extra_data.trace_id then
    return self.Search_extra_data.trace_id
  end
end
function Logic_ugc_search:GetSearchModMetaFeedsList(keyword, rank_type, tag_list, is_ugc_season, feature_tag_list)
  local Key = self:GenerateSearchCacheKey(keyword, rank_type, tag_list, is_ugc_season, feature_tag_list)
  return self.SearchModMetaMapFeeds[Key]
end
function Logic_ugc_search:SetSearchModMetaFeeds(keyword, rank_type, tag_list, ret_info, is_ugc_season, feature_tag_list)
  local TimeUtil = require("client.common.time_util")
  local NowTime = TimeUtil.GetServerTimeInSec()
  local Cache = {
    MetaList = ret_info or {},
    ReqTime = NowTime
  }
  local Key = self:GenerateSearchCacheKey(keyword, rank_type, tag_list, is_ugc_season, feature_tag_list)
  self.SearchModMetaMapFeeds[Key] = Cache
end
function Logic_ugc_search:ClearCacheData()
  log(bWriteLog and "Logic_ugc_search:ClearCacheData")
  self.SearchModMetaMap = {}
  self.SearchModMetaMapFeeds = {}
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogic_ugc_search = class(CModuleBase, nil, Logic_ugc_search)
return CLogic_ugc_search