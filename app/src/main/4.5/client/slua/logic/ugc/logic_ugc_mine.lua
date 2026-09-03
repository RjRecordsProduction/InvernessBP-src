local logic_ugc_mine = {mine_homepage_abtest = nil}
local TimeUtil = require("client.common.time_util")
local TableUtil = require("common.table_util")
function logic_ugc_mine:DefineAndResetData()
  self.DynamicList = {}
  self.FollowDataList = {}
  self.FriendDataList = {}
  self.CollectModList = {}
  self.HistoryModList = {}
end
function logic_ugc_mine:OnLogOut()
  log(bWriteLog and "logic_ugc_mine:OnLogOut")
end
function logic_ugc_mine:ClearCacheData()
  self.DynamicList = {}
end
function logic_ugc_mine:SetMineABTest(abTest)
  log(bWriteLog and "logic_ugc_mine:SetMineABTest abTest = " .. tostring(abTest))
  self.mine_homepage_abtest = abTest
end
function logic_ugc_mine:SetFollowData(FollowData, offlineMods)
  local followKeyList = FollowData or {}
  local list = {}
  self.FollowDataList = {}
  if not FollowData or not next(FollowData) then
    self:DataIntegration(self.DynamicList)
    return
  end
  for k, v in pairs(followKeyList) do
    list[#list + 1] = {
      mod_id = k,
      author_uid = v.author_uid,
      verify_time = v.verify_time,
      bFollow = true
    }
  end
  log(bWriteLog and "logic_ugc_mine:SetFollowData #Followlist = " .. tostring(#list))
  for i, temp in ipairs(list) do
    local nowTime = TimeUtil.GetServerTimeInSec()
    local TimeInterval = nowTime - temp.verify_time
    if TimeInterval <= 604800 then
      table.insert(self.FollowDataList, temp)
    end
  end
  table.sort(self.FollowDataList, function(a, b)
    return a.verify_time > b.verify_time
  end)
  log(bWriteLog and "logic_ugc_mine:SetFollowData #self.FollowDataList = " .. tostring(#self.FollowDataList))
  self:DataIntegration(self.DynamicList, self.FollowDataList)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_MINE_DATA_UPDATE)
end
function logic_ugc_mine:SetFriendData(FriendData, offlineMods)
  local FriendKeyList = FriendData or {}
  local list = {}
  self.FriendDataList = {}
  if not FriendData or not next(FriendData) then
    self:DataIntegration(self.DynamicList)
    return
  end
  for k, v in pairs(FriendKeyList) do
    list[#list + 1] = {
      mod_id = k,
      author_uid = v.author_uid,
      verify_time = v.verify_time,
      bFriend = true
    }
  end
  log_tree("logic_ugc_mine:SetFriendData list = ", list)
  log(bWriteLog and "logic_ugc_mine:SetFriendData #FriendList = " .. tostring(#list))
  for i, temp in ipairs(list) do
    local nowTime = TimeUtil.GetServerTimeInSec()
    local TimeInterval = nowTime - temp.verify_time
    if TimeInterval <= 604800 then
      table.insert(self.FriendDataList, temp)
    end
  end
  table.sort(self.FriendDataList, function(a, b)
    return a.verify_time > b.verify_time
  end)
  log(bWriteLog and "logic_ugc_mine:SetFriendData #self.FriendDataList = " .. tostring(#self.FriendDataList))
  log_tree("logic_ugc_mine:SetFriendData #self.FriendDataList = ", self.FriendDataList)
  self:DataIntegration(self.DynamicList, self.FriendDataList)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_MINE_DATA_UPDATE)
end
local mergeUniqueById = function(t1, t2)
  local result = {}
  local seen = {}
  for _, item in ipairs(t1) do
    if not seen[item.mod_id] then
      table.insert(result, item)
      seen[item.mod_id] = true
    end
  end
  for _, item in ipairs(t2) do
    if not seen[item.mod_id] then
      table.insert(result, item)
      seen[item.mod_id] = true
    end
  end
  return result
end
function logic_ugc_mine:DataIntegration(table1, table2)
  table1 = table1 or {}
  table2 = table2 or {}
  local mergedList = mergeUniqueById(table1, table2)
  log_tree("logic_ugc_mine:DataIntegration mergedList", mergedList)
  table.sort(mergedList, function(a, b)
    a.verify_time = a.verify_time or 0
    b.verify_time = b.verify_time or 0
    return a.verify_time > b.verify_time
  end)
  self.DynamicList = mergedList
  self:ReqModInfoBatch(mergedList)
end
function logic_ugc_mine:GetDynamicList()
  return self.DynamicList
end
function logic_ugc_mine:ReqModInfoBatch(mergedList)
  local modIdList = {}
  for i, v in ipairs(mergedList) do
    table.insert(modIdList, v.mod_id)
  end
  log(bWriteLog and "logic_ugc_mine:ReqModInfoBatch #modIdList = " .. tostring(#modIdList))
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  LogicUGC:BatchGetModInfo(modIdList, LogicUGC.C_ModListTypes.Follow, nil, {bSplit = true})
end
function logic_ugc_mine:SetFriendPlayData(FriendPlayingList)
  log(bWriteLog and "logic_ugc_mine:SetFriendPlayData")
  local logic_ugc_mode = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_mode)
  log_tree("logic_ugc_mine:SetFriendPlayData FriendPlayingList = ", FriendPlayingList)
  local FriendPlayingData = FriendPlayingList or {}
  self.FriendPlayingList = {}
  self.FriendCollectList = {}
  self.FriendRecommendList = {}
  for from_uid, mod_data in pairs(FriendPlayingData) do
    for mod_id, time_data in pairs(mod_data) do
      if time_data and time_data.collect_time then
        log(bWriteLog and string.format("logic_ugc_mine:SetFriendPlayData from_uid %d, mod_id %d, collect_time", from_uid, mod_id))
        local FriendData = {
          mod_id = mod_id,
          from_uid = from_uid,
          verify_time = time_data.collect_time,
          bCollectMod = true
        }
        table.insert(self.FriendCollectList, FriendData)
      end
      if time_data and time_data.comment_recommend_time then
        log(bWriteLog and string.format("logic_ugc_mine:SetFriendPlayData from_uid %d, mod_id %d, comment_recommend_time", from_uid, mod_id))
        local FriendData = {
          mod_id = mod_id,
          from_uid = from_uid,
          verify_time = time_data.comment_recommend_time,
          bComment_recommendMod = true
        }
        table.insert(self.FriendRecommendList, FriendData)
      end
    end
    if not logic_ugc_mode:FriendIsHidden(from_uid) and not logic_ugc_mode:CheckFriendPrivacy(from_uid) then
      self.FriendPlayingList = {}
      for mod_id, time_data in pairs(mod_data) do
        if not time_data.collect_time and not time_data.comment_recommend_time then
          local tempTime = 0
          if time_data.start_time and time_data.end_time then
            tempTime = math.max(time_data.start_time, time_data.end_time)
            if time_data.end_time <= time_data.start_time then
              time_data.end_time = nil
            end
          end
          local FriendData = {
            mod_id = mod_id,
            start_time = time_data.start_time or nil,
            end_time = time_data.end_time or nil,
            from_uid = from_uid,
            IsPlaying = time_data.start_time and not time_data.end_time,
            outcome = time_data.outcome,
            verify_time = tempTime or 0
          }
          if time_data.end_time then
            table.insert(self.FriendPlayingList, FriendData)
          end
        end
      end
    end
  end
  self.DynamicList = TableUtil.TableConcat(self.DynamicList, self.FriendPlayingList)
  self.DynamicList = TableUtil.TableConcat(self.DynamicList, self.FriendRecommendList)
  self.DynamicList = TableUtil.TableConcat(self.DynamicList, self.FriendCollectList)
  log_tree("logic_ugc_mine:SetFriendPlayData DynamicList = ", self.DynamicList)
  self:ReqModInfoBatch(self.DynamicList)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_MINE_DATA_UPDATE)
end
function logic_ugc_mine:GetFriendPriorityList(UID, FriendList)
  local logic_ugc_mode = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_mode)
  local interactedFriends = {}
  for i, v in ipairs(FriendList) do
    if v.from_uid == UID then
      return interactedFriends
    end
  end
  if self.FriendPlayingList then
    for _, mod_data in pairs(self.FriendPlayingList) do
      if mod_data[UID] and not logic_ugc_mode:FriendIsHidden(UID) and not logic_ugc_mode:CheckFriendPrivacy(UID) then
        interactedFriends[UID] = self.INTERACTION_TYPES.PLAYING
      end
    end
  end
end
local compareIntimacy = function(a, b)
  local KeyA = a.intimacy or 0
  local KeyB = b.intimacy or 0
  return KeyA > KeyB
end
local C_FRIEND_MAX = 50
function logic_ugc_mine:GetFriendList()
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local FriendMap = LogicFriend.GetAllFriendData()
  self.FriendUids = {}
  local Cnt = 0
  table.sort(FriendMap, compareIntimacy)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  for Uid, Info in pairs(FriendMap) do
    local LocalProfile = logic_profile:GetLocalProfile(Uid)
    if LocalProfile and LocalProfile.ugc_author_info and LocalProfile.ugc_author_info.state == 1 then
      table.insert(self.FriendUids, Uid)
      Cnt = Cnt + 1
      if Cnt >= C_FRIEND_MAX then
        break
      end
    end
  end
  return self.FriendUids
end
function logic_ugc_mine:SearchModFuzzy(text, list)
  log(bWriteLog and string.format("logic_ugc_mine:SearchModFuzzy, text: %s", text))
  local StringUtil = require("common.string_util")
  local searchKeyTable = {
    "mod_id",
    "name",
    "uid"
  }
  local matchTable = {}
  for k, v in ipairs(list) do
    local Mod = v.pub_mod_meta
    log(bWriteLog and bWriteLog and string.format("teamup_side_bar:SearchFriendFuzzy, ipairs(friendList), index: %s, name: %s, remark: %s, uid: %s", k, Mod.mod_id, Mod.setting.name, Mod.base.uid))
    for _, searchKey in ipairs(searchKeyTable) do
      local src = Mod[searchKey] or Mod.setting[searchKey] or Mod.base[searchKey]
      if src then
        local isPattrnFound = StringUtil.StrFind(string.lower(src), string.lower(text))
        if isPattrnFound then
          table.insert(matchTable, v)
          break
        end
      end
    end
  end
  log_tree("teamup_side_bar:SearchFriendFuzzy, matchTable", matchTable)
  return matchTable
end
function logic_ugc_mine:SetCollectModList(CollectModList)
  self.end
function logic_ugc_mine:SetHistoryModList(HistoryModList)
  self.end
function logic_ugc_mine:SearchCollectModFuzzy(Text)
  return self:SearchModFuzzy(Text, self.CollectModList)
end
function logic_ugc_mine:SearchHistoryModFuzzy(Text)
  return self:SearchModFuzzy(Text, self.HistoryModList)
end
function logic_ugc_mine:GetFriendUpdatesDataUI()
  local ShowCacheList = {}
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  if not self.DynamicList or not next(self.DynamicList) then
    return {}
  end
  for i, temp in ipairs(self.DynamicList) do
    local Mod = LogicUGC:BatchGetModInfo({
      temp.mod_id
    }, nil, nil, {bExportArray = true}) or {}
    if Mod and next(Mod) then
      if temp.bComment_recommendMod then
        table.insert(ShowCacheList, {
          modInfo = Mod[1].pub_mod_meta,
          mod_id = temp.mod_id,
          author_uid = temp.author_uid or temp.from_uid,
          verify_time = temp.verify_time or 0,
          IsRecommend = true
        })
      elseif temp.bCollectMod then
        table.insert(ShowCacheList, {
          modInfo = Mod[1].pub_mod_meta,
          mod_id = temp.mod_id,
          author_uid = temp.author_uid or temp.from_uid,
          verify_time = temp.verify_time or 0,
          IsCollect = true
        })
      elseif temp.bFollow then
        table.insert(ShowCacheList, {
          modInfo = Mod[1].pub_mod_meta,
          mod_id = temp.mod_id,
          author_uid = temp.author_uid or temp.from_uid,
          verify_time = temp.verify_time or 0,
          bFollow = true
        })
      elseif temp.bFriend then
        table.insert(ShowCacheList, {
          modInfo = Mod[1].pub_mod_meta,
          mod_id = temp.mod_id,
          author_uid = temp.author_uid or temp.from_uid,
          verify_time = temp.verify_time or 0,
          bFriend = true
        })
      else
        table.insert(ShowCacheList, {
          modInfo = Mod[1].pub_mod_meta,
          mod_id = temp.mod_id,
          author_uid = temp.author_uid or temp.from_uid,
          verify_time = temp.verify_time or 0,
          start_time = temp.start_time or nil,
          end_time = temp.end_time or nil,
          IsPlaying = temp.start_time and not temp.end_time,
          outcome = temp.outcome
        })
      end
    end
  end
  table.sort(ShowCacheList, function(a, b)
    return a.verify_time > b.verify_time
  end)
  log_tree("UGC_Main_Mine_UI:UpdateStatusList, ShowCacheList", ShowCacheList)
  return ShowCacheList
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_ugc_mine = class(CModuleBase, nil, logic_ugc_mine)
return Clogic_ugc_mine