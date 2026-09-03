local recentbadgamesnumcondition = require("client.slua.logic.GuideFlow.Condition.RecentBadGamesNumCondition")
local Logic_UGC_Rank = {
  rankCache = {},
  pageCache = {},
  CurrentFilterKey = "",
  filterTag = nil,
  hotRankMateCache = {},
  static_season_info = nil
}
function Logic_UGC_Rank:OnLogin(bReLogin)
  local UGCPassHandler = require("client.network.Protocol.UGCPassHandler")
  UGCPassHandler.send_ugc_pass_get_info_req()
end
function Logic_UGC_Rank:OnPostSwitchGameStatus(preState, nextState)
  local UGCPassHandler = require("client.network.Protocol.UGCPassHandler")
  UGCPassHandler.send_ugc_pass_get_info_req()
end
function Logic_UGC_Rank:ClearCache()
  self.rankCache = {}
  self.pageCache = {}
end
function Logic_UGC_Rank:GetCachePage(id, filter)
  if not id then
    return 1
  end
  if not self.pageCache[id] then
    return 1
  end
  return self.pageCache[id][filter] or 1
end
function Logic_UGC_Rank:CachePage(id, filter, page)
  if not self.pageCache[id] then
    self.pageCache[id] = {}
  end
  self.pageCache[id][filter] = page or 1
end
function Logic_UGC_Rank:ClearCacheForFilterChange(id, filter)
  if not self.pageCache[id] then
    return
  end
  if not self.rankCache[id] then
    return
  end
  self.pageCache[id][filter] = nil
  self.rankCache[id][filter] = nil
end
function Logic_UGC_Rank:SetFilterTag(tag)
  self:ClearCache()
  self.filterTag = tag
end
function Logic_UGC_Rank:ClearFilterTagForClose()
  if self.filterTag then
    self.filterTag = nil
    self:ClearCache()
  end
end
function Logic_UGC_Rank:OnPubModRankRsp(id, filter, page, list, hasServerData, searchFilter)
  if not self.rankCache[id] then
    self.rankCache[id] = {}
  end
  if not self.rankCache[id][filter] then
    self.rankCache[id][filter] = {}
  end
  if not list then
    return
  end
  local hasData = false
  local hasNewData = false
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  list = self:SortByKey(list, searchFilter)
  local isExist
  for k, v in pairs(list) do
    local count = #self.rankCache[id][filter]
    if count >= Config_UGC.RankMaxCount then
      break
    end
    hasData = true
    isExist = false
    for kk, vv in pairs(self.rankCache[id][filter]) do
      if v.mod_id == vv.mod_id then
        isExist = true
        break
      end
    end
    if not isExist then
      hasNewData = true
      table.insert(self.rankCache[id][filter], v)
    end
  end
  for k, v in pairs(self.rankCache[id][filter]) do
    v.index = k
  end
  if hasServerData then
    self:CachePage(id, filter, page)
  end
  local dataCount = #self.rankCache[id][filter]
  local isDataLack = dataCount <= Config_UGC.RankMinCount
  local rankDataState = Config_UGC.RankDataState.serverNodata
  if hasServerData then
    if hasData then
      rankDataState = hasNewData and Config_UGC.RankDataState.clientHasNewData or Config_UGC.RankDataState.clientNoNewData
    else
      rankDataState = Config_UGC.RankDataState.clientNoData
    end
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_GET_RANK_LIST, id, filter, rankDataState, isDataLack)
  log(bWriteLog and string.format("[UGC] Logic_UGC_Rank:OnPubModRankRsp, page: %d, list count: %d, hasServerData: %s", page, #list, tostring(hasServerData)))
end
function Logic_UGC_Rank:SortByKey(list, searchFilter)
  local keyList = {}
  local sortedList = {}
  for k, v in pairs(list) do
    table.insert(keyList, k)
  end
  table.sort(keyList, function(a, b)
    return a < b
  end)
  for k, v in pairs(keyList) do
    table.insert(sortedList, list[v])
  end
  table.sort(sortedList, function(a, b)
    local aIndex, bIndex = #searchFilter + 1, #searchFilter + 1
    for k, v in ipairs(searchFilter) do
      if a.setting.tag[1] == v then
        aIndex = k
      end
      if b.setting.tag[1] == v then
        bIndex = k
      end
    end
    if aIndex ~= bIndex then
      return aIndex < bIndex
    elseif a.setting.tag[1] == nil then
      return false
    elseif b.setting.tag[1] == nil then
      return true
    else
      return a.setting.tag[1] > b.setting.tag[1]
    end
  end)
  return sortedList
end
function Logic_UGC_Rank:GetHotRankList()
  if self.hotRankIDListCache and next(self.hotRankIDListCache) then
    return self.hotRankIDListCache
  else
    local UGCSearchHandler = require("client.network.Protocol.UGCSearchHandler")
    UGCSearchHandler.send_ugc_hot_theme_ext_req()
    return {}
  end
end
function Logic_UGC_Rank:OnGetHotRankListRsp(mod_list)
  self.hotRankIDListCache = mod_list
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_UGC_HOTRANK_LIST_UPDATE, mod_list)
end
function Logic_UGC_Rank:GetHotRankMateList()
  return self.hotRankMateCache
end
function Logic_UGC_Rank:SetHotRankMateList(MetaList)
  for k, v in pairs(self.hotRankIDListCache) do
    local tempList = {}
    for _, v2 in pairs(v.mod_id_list) do
      if MetaList[v2] then
        tempList[v2] = MetaList[v2]
      end
    end
    for k2, v2 in pairs(tempList) do
      if not self.hotRankMateCache[k] then
        self.hotRankMateCache[k] = {}
      end
      self.hotRankMateCache[k][k2] = v2
    end
  end
end
function Logic_UGC_Rank:GetHotRankRequestIndex(RankType)
  if not self.hotRankRequestIndexCache then
    self.hotRankRequestIndexCache = {}
  end
  if not self.hotRankRequestIndexCache[RankType] then
    self.hotRankRequestIndexCache[RankType] = 1
    return self.hotRankRequestIndexCache[RankType]
  end
  self.hotRankRequestIndexCache[RankType] = self.hotRankRequestIndexCache[RankType] + 5
  return self.hotRankRequestIndexCache[RankType]
end
function Logic_UGC_Rank:send_ugc_pass_get_static_season_info_req()
  if self.static_season_info then
    return
  end
  local UGCPassHandler = require("client.network.Protocol.UGCPassHandler")
  UGCPassHandler.send_ugc_pass_get_static_season_info_req()
end
function Logic_UGC_Rank:ugc_pass_get_static_season_info_rsp(static_season_info)
  self.  EventSystem:postEvent(EVENTTYPE_WOW_PASS, EVENTID_WOW_PASS_SEASON_ID)
end
function Logic_UGC_Rank:GetSeason_id()
  if not self.static_season_info then
    log(bWriteLog and "Logic_UGC_Rank:GetSeason_id not self.static_season_info ")
    return 0
  end
  return self.static_season_info.season_id
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicUGCRank = class(CModuleBase, nil, Logic_UGC_Rank)
return CLogicUGCRank