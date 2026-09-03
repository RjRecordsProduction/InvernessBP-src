local logic_home_list_view = {}
local home_macros = require("client.slua.logic.home.home_macros")
local ModeSelection_Tab_Cfg = {
  [2] = {
    type = home_macros.ENUM_MODE_SELECTION_TAB_TYPE.Friend,
    txt = 64748,
    showFunc = function()
      return LobbySystem.CheckOpen(95008)
    end
  },
  [1] = {
    type = home_macros.ENUM_MODE_SELECTION_TAB_TYPE.Recommend,
    txt = 72031,
    showFunc = function()
      return LobbySystem.CheckOpen(95007)
    end
  },
  [3] = {
    type = home_macros.ENUM_MODE_SELECTION_TAB_TYPE.Rank,
    txt = 64750,
    showFunc = function()
      local logic_home_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_switch)
      if not logic_home_switch:CheckHomeRankSwitchOpen() then
        return false
      end
      return true
    end
  },
  [4] = {
    type = home_macros.ENUM_MODE_SELECTION_TAB_TYPE.History,
    txt = 64796,
    showFunc = function()
      return true
    end
  },
  [5] = {
    type = home_macros.ENUM_MODE_SELECTION_TAB_TYPE.Collect,
    txt = 64797,
    showFunc = function()
      return true
    end
  }
}
function logic_home_list_view:DefineAndResetData()
  self.friendDataList = {}
  self.rankDataList = {}
  for type = 1, #ModeSelection_Tab_Cfg do
    local rankID = self:GetRankIDByType(type)
    self.rankDataList[rankID] = {}
  end
  self.recommendUIDList = {}
  self.collectMap = nil
  self.historyDataList = {}
  self.curRecPage = 1
  self.IsMaxRecPage = false
  self.downloadStateMap = {}
end
function logic_home_list_view:OnGetHomeProfileByManorID(_, _, homeProfile)
  EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTTYPE_PLANPH_HOME_SEARCH_END, homeProfile)
end
function logic_home_list_view:OnJumpHomeFriend(_, _, param)
  local logic_home_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_switch)
  if not logic_home_switch:CheckHomeSwitchOpen(true) then
    return
  end
  if logic_home_switch:CheckHomeLimit(true) then
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.Lobby_Home_Friend_UIBP, param)
end
function logic_home_list_view:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_GET_PROFILE_BY_MANOR_ID, self.OnGetHomeProfileByManorID, self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_PLANPH_HOME_FRIEND, self.OnJumpHomeFriend, self)
end
function logic_home_list_view:SetDownloadStateByUID(uid, bIsShow)
  self.downloadStateMap[uid] = bIsShow
end
function logic_home_list_view:GetDownloadStateByUID(uid, bIsShow)
  return self.downloadStateMap[uid]
end
function logic_home_list_view:GetModeHomeItemTabType(data)
  if not data then
    return nil
  end
  if data.rank_no then
    return home_macros.ENUM_MODE_SELECTION_TAB_TYPE.Rank
  elseif data.recommend_version then
    return home_macros.ENUM_MODE_SELECTION_TAB_TYPE.Recommend
  elseif data.time then
    return home_macros.ENUM_MODE_SELECTION_TAB_TYPE.History
  elseif data.collectTimeStamp then
    return home_macros.ENUM_MODE_SELECTION_TAB_TYPE.Collect
  else
    return home_macros.ENUM_MODE_SELECTION_TAB_TYPE.Friend
  end
  return home_macros.ENUM_MODE_SELECTION_TAB_TYPE.Friend
end
function logic_home_list_view:IsModeHomeFriendItem(data)
  local tabType = self:GetModeHomeItemTabType(data)
  if not tabType then
    return nil
  end
  return tabType == home_macros.ENUM_MODE_SELECTION_TAB_TYPE.Friend
end
function logic_home_list_view:GetModeHomeItemSceneID(data)
  local tabType = self:GetModeHomeItemTabType(data)
  if tabType == home_macros.ENUM_MODE_SELECTION_TAB_TYPE.Friend then
    return home_macros.ENUM_DETAIL_SCENE_TYPE.FriendTab
  elseif tabType == home_macros.ENUM_MODE_SELECTION_TAB_TYPE.Recommend then
    return home_macros.ENUM_DETAIL_SCENE_TYPE.Recommend
  elseif tabType == home_macros.ENUM_MODE_SELECTION_TAB_TYPE.Rank then
    return home_macros.ENUM_DETAIL_SCENE_TYPE.RankTab
  elseif tabType == home_macros.ENUM_MODE_SELECTION_TAB_TYPE.History then
    return home_macros.ENUM_DETAIL_SCENE_TYPE.HistoryTab
  elseif tabType == home_macros.ENUM_MODE_SELECTION_TAB_TYPE.Collect then
    return home_macros.ENUM_DETAIL_SCENE_TYPE.CollectTab
  end
end
function logic_home_list_view:GetModeSelectionTabCfg()
  return ModeSelection_Tab_Cfg
end
function logic_home_list_view:GetFriendHomeList()
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local friendUIDList = LogicFriend.GetAllFriendList()
  if not next(friendUIDList) then
    log(bWriteLog and "logic_home_list_view:GetFriendHomeList empty friends")
    EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTTYPE_PLANPH_MODESELECTION_DATA_READY, {}, home_macros.ENUM_MODE_SELECTION_TAB_TYPE.Friend)
  else
    local logic_home_visit_count = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_visit_count)
    local logic_home_profile = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_profile)
    local TimeUtil = require("client.common.time_util")
    if not self.lastReqFriendTabSummaryCD or TimeUtil.GetServerTimeInSec() >= self.lastReqFriendTabSummaryCD then
      local needReqUIDList = {}
      if not self.lastReqFriendTabSummaryCD then
        needReqUIDList = friendUIDList
      else
        for i, v in ipairs(friendUIDList) do
          local homeProfile = logic_home_profile:GetHomeProfileByUid(v)
          if not homeProfile or homeProfile and homeProfile.grow_info.level >= 4 then
            table.insert(needReqUIDList, v)
          end
        end
      end
      log_tree(bWriteLog and "logic_home_list_view:GetFriendHomeList needReqUIDList", needReqUIDList)
      logic_home_profile:GetOrReqHomeProfile(needReqUIDList, function()
        log(bWriteLog and string.format("logic_home_list_view:GetFriendHomeList 1"))
        logic_home_visit_count:GetOrReqHomeVisCnt(friendUIDList, function()
          log(bWriteLog and string.format("logic_home_list_view:GetFriendHomeList 2"))
          table.sort(friendUIDList, function(a, b)
            local visDataA = logic_home_visit_count:GetHomeVisCntByUid(a)
            local visDataB = logic_home_visit_count:GetHomeVisCntByUid(b)
            local homeprofileA = logic_home_profile:GetHomeProfileByUid(a)
            local homeprofileB = logic_home_profile:GetHomeProfileByUid(b)
            if visDataA and visDataB then
              local nHaveOnwerA = visDataA.owner_inst_ids and 1 or 0
              local nHaveOnwerB = visDataB.owner_inst_ids and 1 or 0
              if nHaveOnwerA == nHaveOnwerB then
                if homeprofileA.grow_info.level == homeprofileB.grow_info.level then
                  if homeprofileA.grow_info.prosperity == homeprofileB.grow_info.prosperity then
                    return a < b
                  else
                    return homeprofileA.grow_info.prosperity > homeprofileB.grow_info.prosperity
                  end
                else
                  return homeprofileA.grow_info.level > homeprofileB.grow_info.level
                end
              else
                return nHaveOnwerA > nHaveOnwerB
              end
            elseif visDataA and not visDataB then
              return true
            elseif not visDataA and visDataB then
              return false
            elseif homeprofileA.grow_info.level == homeprofileB.grow_info.level then
              if homeprofileA.grow_info.prosperity == homeprofileB.grow_info.prosperity then
                return a < b
              else
                return homeprofileA.grow_info.prosperity > homeprofileB.grow_info.prosperity
              end
            else
              return homeprofileA.grow_info.level > homeprofileB.grow_info.level
            end
          end)
          self.friendDataList = {}
          for k, v in ipairs(friendUIDList) do
            table.insert(self.friendDataList, {uid = v})
          end
          log_tree(bWriteLog and "logic_home_list_view:GetFriendHomeList self.friendDataList 1", self.friendDataList)
          EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTTYPE_PLANPH_MODESELECTION_DATA_READY, self.friendDataList, home_macros.ENUM_MODE_SELECTION_TAB_TYPE.Friend)
        end, {
          fromType = home_macros.ENUM_VISCNT_REQ_TYPE.ModeSelection
        }, false)
      end, true)
      self.lastReqFriendTabSummaryCD = TimeUtil.GetServerTimeInSec() + home_macros.visCntRefreshCD
    else
      log_tree(bWriteLog and "logic_home_list_view:GetFriendHomeList self.friendDataList 2", self.friendDataList)
      EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTTYPE_PLANPH_MODESELECTION_DATA_READY, self.friendDataList, home_macros.ENUM_MODE_SELECTION_TAB_TYPE.Friend)
    end
  end
end
function logic_home_list_view:IsPHomeRank(rankID)
  local RankConfig = require("client.slua.logic.rank.rank_config")
  return rankID == RankConfig.ScoreType.planph_popularity or rankID == RankConfig.ScoreType.planph_prosperity or rankID == RankConfig.ScoreType.planph_total_heat or rankID == RankConfig.ScoreType.planph_week_heat or rankID == RankConfig.ScoreType.planph_newest or rankID == RankConfig.ScoreType.planph_highest_prosperity or rankID == RankConfig.ScoreType.planph_style_score or rankID == "business info not configed in topn svr"
end
function logic_home_list_view:GetRankNum(rankID, uid)
  for _, data in ipairs(self.rankDataList[rankID]) do
    if tonumber(data.uid) == uid then
      return data.rank_no
    end
  end
  return nil
end
function logic_home_list_view:GetRankIDByType(type)
  local rankID
  local RankConfig = require("client.slua.logic.rank.rank_config")
  if type == 1 then
    rankID = RankConfig.ScoreType.planph_prosperity
  elseif type == 2 then
    rankID = RankConfig.ScoreType.planph_popularity
  elseif type == 3 then
    rankID = RankConfig.ScoreType.planph_total_heat
  elseif type == 4 then
    rankID = RankConfig.ScoreType.planph_week_heat
  elseif type == 5 then
    rankID = RankConfig.ScoreType.planph_newest
  end
  return rankID
end
function logic_home_list_view:CheckOpenGuideTips()
  local logic_home_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_switch)
  if not logic_home_switch:CheckHomeSwitchOpen(false) then
    log(bWriteLog and "logic_home_list_view:CheckOpenGuideTips, switch not open")
    return
  end
  local logic_home_profile = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_profile)
  logic_home_profile:GetOrReqHomeProfile({
    DataMgr.roleData.uid
  }, function()
    local profile = logic_home_profile:GetHomeProfileByUid(DataMgr.roleData.uid)
    if profile then
      if profile.bUnLock then
        log(bWriteLog and string.format("logic_home_list_view:CheckOpenGuideTips, profile.bUnLock:%s", profile.bUnLock))
        return
      end
      local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
      if not PlayerPrefsSystem.CheckAndSaveCurrentDate_N(PlayerPrefsSystem.ePlayerPrefsType.eHomeOpenGuideShowMonth, true, 30) then
        log(bWriteLog and "logic_home_list_view:CheckOpenGuideTips, eHomeOpenGuideShowMonth")
        return
      end
      if not PlayerPrefsSystem.CheckAndSaveCurrentDate_N(PlayerPrefsSystem.ePlayerPrefsType.eHomeOpenGuideShowWeek, true, 7) then
        log(bWriteLog and "logic_home_list_view:CheckOpenGuideTips, eHomeOpenGuideShowWeek")
        return
      end
      self:send_not_open_manor_be_visit_info_req()
    end
  end)
end
function logic_home_list_view:IsCollectHome(uid)
  if not self.collectMap then
    return false
  end
  return self.collectMap[uid] ~= nil
end
function logic_home_list_view:send_get_manor_recommend_req(page_size)
  if self.isSendRecReq then
    log(bWriteLog and string.format("logic_home_list_view:send_get_manor_recommend_req, self.isSendRecReq:%s", self.isSendRecReq))
    return
  end
  if self.IsMaxRecPage then
    ShowNotice(62341)
    return
  end
  self.isSendRecReq = true
  local time_ticker = require("common.time_ticker")
  if not self.sendRecReqTimer then
    self.sendRecReqTimer = time_ticker.AddTimerOnce(3, function()
      self.isSendRecReq = false
      time_ticker.RemoveTimer(self.sendRecReqTimer)
      self.sendRecReqTimer = nil
    end)
  end
  local UIUtil = require("client.common.ui_util")
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.PlanPH_Rec_Home_Req, false) then
    log(bWriteLog and "logic_home_list_view:send_get_manor_recommend_req, In Req CD 0.5s")
    return
  end
  page_size = page_size or 3
  page_size = FuncUtil.Clamp(page_size, 3, 10)
  local PHomeListViewHandler = require("client.network.Protocol.PHomeListViewHandler")
  PHomeListViewHandler.send_get_manor_recommend_req(page_size, self.curRecContext)
end
function logic_home_list_view:ResetRecPageData()
  self.curRecPage = 1
  self.IsMaxRecPage = false
  self.recommendUIDList = {}
  self.curRecContext = nil
end
local removeDuplicates = function(list)
  local logic_friend_blacklist = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_blacklist)
  local seen = {}
  local newList = {}
  for _, element in ipairs(list) do
    if not seen[element] and not logic_friend_blacklist:IsBlacklist(element) then
      table.insert(newList, element)
      seen[element] = true
    end
  end
  return newList
end
function logic_home_list_view:on_get_manor_recommend_rsp(errcode, page_size, recommend_result, context)
  self.isSendRecReq = false
  if errcode ~= 0 then
    ShowNotice(errcode)
    EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTTYPE_PLANPH_MODESELECTION_DATA_READY, self.recommendUIDList, home_macros.ENUM_MODE_SELECTION_TAB_TYPE.Recommend, {
      pageNo = self.curRecPage
    })
    return
  end
  local TableUtil = require("common.table_util")
  self.recommendUIDList = TableUtil.Merge(self.recommendUIDList, recommend_result)
  self.recommendUIDList = removeDuplicates(self.recommendUIDList)
  self.curRecContext = context
  if context == nil then
    self.IsMaxRecPage = true
  end
  if not recommend_result then
    EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTTYPE_PLANPH_MODESELECTION_DATA_READY, self.recommendUIDList, home_macros.ENUM_MODE_SELECTION_TAB_TYPE.Recommend, {
      pageNo = self.curRecPage
    })
    return
  end
  EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTTYPE_PLANPH_MODESELECTION_DATA_READY, self.recommendUIDList, home_macros.ENUM_MODE_SELECTION_TAB_TYPE.Recommend, {
    pageNo = self.curRecPage
  })
  self.curRecPage = self.curRecPage + 1
end
function logic_home_list_view:send_get_topn_rank(type)
  local rankID = self:GetRankIDByType(type)
  if not rankID then
    log(bWriteLog and string.format("logic_home_list_view:send_get_topn_rank, wrong type:%s", type))
    return
  end
  local RankConfig = require("client.slua.logic.rank.rank_config")
  local RankHandler = require("client.network.Protocol.RankHandler")
  log(bWriteLog and string.format("logic_home_list_view:send_get_topn_rank, rankID:%s", rankID))
  RankHandler.send_get_topn_rank(0, rankID, 1, {
    reqFromType = RankConfig.ReqFromType.modeSelection
  })
end
function logic_home_list_view:proc_get_topn_rank_rsp(res, rankID, rank_data_list)
  log(bWriteLog and string.format("logic_home_list_view:proc_get_topn_rank_rsp, res:%s", res))
  log(bWriteLog and string.format("logic_home_list_view:proc_get_topn_rank_rsp, rankID:%s", rankID))
  log_tree(bWriteLog and "logic_home_list_view:proc_get_topn_rank_rsp rank_data_list", rank_data_list)
  if res ~= 0 then
    EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTTYPE_PLANPH_MODESELECTION_DATA_READY, self.rankDataList[rankID], home_macros.ENUM_MODE_SELECTION_TAB_TYPE.Rank, {rankID = rankID})
    return
  end
  if not next(rank_data_list) then
    EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTTYPE_PLANPH_MODESELECTION_DATA_READY, self.rankDataList[rankID], home_macros.ENUM_MODE_SELECTION_TAB_TYPE.Rank, {rankID = rankID})
    return
  end
  self.rankDataList[rankID] = rank_data_list
  EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTTYPE_PLANPH_MODESELECTION_DATA_READY, self.rankDataList[rankID], home_macros.ENUM_MODE_SELECTION_TAB_TYPE.Rank, {rankID = rankID})
end
function logic_home_list_view:send_not_open_manor_be_visit_info_req()
  local PHomeListViewHandler = require("client.network.Protocol.PHomeListViewHandler")
  PHomeListViewHandler.send_not_open_manor_be_visit_info_req()
end
function logic_home_list_view:on_not_open_manor_be_visit_info_rsp(be_visited_cnt, visit_friend_list)
  EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTTYPE_PLANPH_HOME_NOT_OPEN_INFO_RSP, be_visited_cnt, visit_friend_list)
end
function logic_home_list_view:send_get_manor_visit_history_req()
  local PHomeListViewHandler = require("client.network.Protocol.PHomeListViewHandler")
  PHomeListViewHandler.send_get_manor_visit_history_req()
end
function logic_home_list_view:on_get_manor_visit_history_rsp(err, list)
  if err ~= 0 then
    ShowNotice(err)
    EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTTYPE_PLANPH_MODESELECTION_DATA_READY, self.historyDataList, home_macros.ENUM_MODE_SELECTION_TAB_TYPE.History)
    return
  end
  self.historyDataList = list
  EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTTYPE_PLANPH_MODESELECTION_DATA_READY, list, home_macros.ENUM_MODE_SELECTION_TAB_TYPE.History)
end
function logic_home_list_view:send_manor_add_collect_req(collect_id, scene_id)
  local is_add = 1
  if self.collectMap then
    is_add = self.collectMap[collect_id] == nil and 1 or 0
  end
  local PHomeListViewHandler = require("client.network.Protocol.PHomeListViewHandler")
  PHomeListViewHandler.send_manor_add_collect_req(collect_id, is_add, scene_id or 0)
end
function logic_home_list_view:on_manor_add_collect_rsp(collect_id, is_add)
  if is_add == 1 then
    ShowNotice(6797)
  else
    local logic_home_profile = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_profile)
    local homeProfile = logic_home_profile:GetHomeProfileByUid(collect_id)
    if not homeProfile.bUnLock and tostring(collect_id):sub(1, 2) == "50" then
      ShowNotice(655897)
    else
      ShowNotice(6798)
    end
  end
  if not self.collectMap then
    self.collectMap = {}
  end
  if is_add == 1 then
    local TimeUtil = require("client.common.time_util")
    self.collectMap[collect_id] = TimeUtil.GetServerTimeInSec()
  else
    self.collectMap[collect_id] = nil
  end
  EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTTYPE_PLANPH_MODESELECTION_DATA_READY, self.collectMap, home_macros.ENUM_MODE_SELECTION_TAB_TYPE.Collect)
  EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTTYPE_PLANPH_HOME_COLLECT_RSP)
end
function logic_home_list_view:send_get_manor_collect_req(isFromDetail)
  if isFromDetail and self.collectMap then
    return
  end
  if self.collectMap then
    log_tree(bWriteLog and "logic_home_list_view:send_get_manor_collect_req self.collectMap", self.collectMap)
    EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTTYPE_PLANPH_MODESELECTION_DATA_READY, self.collectMap, home_macros.ENUM_MODE_SELECTION_TAB_TYPE.Collect)
    return
  end
  local PHomeListViewHandler = require("client.network.Protocol.PHomeListViewHandler")
  PHomeListViewHandler.send_get_manor_collect_req()
end
function logic_home_list_view:on_get_manor_collect_rsp(err, collectMap)
  if err ~= 0 then
    ShowNotice(err)
    EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTTYPE_PLANPH_MODESELECTION_DATA_READY, self.collectMap, home_macros.ENUM_MODE_SELECTION_TAB_TYPE.Collect)
    return
  end
  self.  EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTTYPE_PLANPH_MODESELECTION_DATA_READY, self.collectMap, home_macros.ENUM_MODE_SELECTION_TAB_TYPE.Collect)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_home_list_view = class(CModuleBase, nil, logic_home_list_view)
return Clogic_home_list_view