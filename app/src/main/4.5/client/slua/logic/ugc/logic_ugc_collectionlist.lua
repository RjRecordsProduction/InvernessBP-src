local LogicUGCCollectionList = {}
local BatchSize = 10
local bFakeTest = false and _G.IsEditor
function LogicUGCCollectionList:DefineAndResetData()
  self.MyCollectionList = {}
  self.LikeCollectionList = {}
  self.RecommendList = {}
  self.CacheCollectionDataMap = {}
  self.ToRequestCollectionList = {}
  self.InvalidMap = {}
  self.bInitRequest = false
  self.TagConfigs = {}
  local Table = CDataTable.GetTable("UGCModCollection")
  for _, V in pairs(Table) do
    table.insert(self.TagConfigs, V)
  end
  table.sort(self.TagConfigs, function(a, b)
    return a.Sort > b.Sort
  end)
  if bFakeTest then
    local FakeCache = self:_TestCode_GenFakeCollections(100)
    for _, Fake in pairs(FakeCache) do
      local Idx = Fake.mod_collection_id
      self:CacheCollectionDataList(FakeCache)
      if Idx % 2 == 0 then
        table.insert(self.LikeCollectionList, Idx)
      else
        Fake.uid = tonumber(DataMgr.roleData.uid)
        table.insert(self.MyCollectionList, Idx)
      end
    end
  end
  self.CurSelectCollectionID = nil
end
function LogicUGCCollectionList:OnLogOut()
  self:_ClearTimer()
end
function LogicUGCCollectionList:OnDestroy()
end
function LogicUGCCollectionList:GetTagName(TagId)
  for _, V in pairs(self.TagConfigs) do
    if V.ID == TagId then
      return V.Name
    end
  end
  return ""
end
function LogicUGCCollectionList:GetSelectBundleName(BundleID)
  return LocUtil.GetLocalizeResStr(69262)
end
function LogicUGCCollectionList:GetSelectBundlePic(BundleID)
  if self:IsInvalidCollection(BundleID) then
    return nil
  end
  local Bundle = self:GetCollectionInfo(BundleID)
  if Bundle then
    if Bundle.pic_url and Bundle.pic_url ~= "" then
      return Bundle.pic_url
    end
    local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
    for ModID, _ in pairs(Bundle.pub_mod_list) do
      local ModInfo = LogicUGC:GetModByAllCache(ModID)
      if ModInfo then
        local ModInfo = ModInfo.pub_mod_meta
        local Util_UGC = require("client.slua.logic.ugc.util_ugc")
        return Util_UGC.GetCoverImageUrl(ModInfo.setting, ModInfo.base.template_id, false)
      end
    end
  end
  self:RequestCollectionData(BundleID)
  return nil
end
function LogicUGCCollectionList:GetSelectBundleModList(BundleID)
  if self:IsInvalidCollection(BundleID) then
    return nil
  end
  local Bundle = self:GetCollectionInfo(BundleID)
  if Bundle then
    local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
    local ModList = {}
    for ModID, _ in pairs(Bundle.pub_mod_list) do
      local ModInfo = LogicUGC:GetModByAllCache(ModID)
      if ModInfo then
        table.insert(ModList, ModID)
      end
    end
    return ModList
  end
  return nil
end
function LogicUGCCollectionList:CheckModListReady(BundleID)
  if not self:GetCollectionInfo(BundleID) then
    self:RequestCollectionData(BundleID)
    return false
  end
  return true
end
function LogicUGCCollectionList:RequestCollectionList()
  if self.bInitRequest and self.LikeCollectionList and #self.LikeCollectionList > 0 then
    return
  end
  self.bInitRequest = true
  local UGCModHandler = require("client.network.Protocol.UGCModHandler")
  UGCModHandler.send_ugc_get_mod_collection_list_req():Then(function(ErrCode, MyCollectionList, LikeCollectionList, RecommendList)
    self.MyCollectionList = MyCollectionList or {}
    self.LikeCollectionList = LikeCollectionList or {}
    self.RecommendList = RecommendList or {}
    local FetchList = {}
    if #self.LikeCollectionList == 0 then
      for i = 1, 10 do
        if self.RecommendList[i] == nil then
          break
        end
        FetchList[i] = self.RecommendList[i]
      end
    else
      for i = 1, 10 do
        if self.LikeCollectionList[i] == nil then
          break
        end
        FetchList[i] = self.LikeCollectionList[i]
      end
    end
    if 0 < #FetchList then
      UGCModHandler.send_ugc_batch_get_mod_collection_data_req(FetchList):Then(function(ErrCode, CollectionDataList, Invalids)
        self:UpdateInvalidCollections(Invalids)
        self:CacheCollectionDataList(CollectionDataList)
        EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_REQUESTCOLLECTIONLIST)
      end, function(Reason)
        log(bWriteLog and "LogicUGCCollectionList:RequestCollectionList send_ugc_batch_get_mod_collection_data_req failed." .. tostring(Reason))
      end)
    else
      EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_REQUESTCOLLECTIONLIST)
    end
  end, function(Reason)
    log(bWriteLog and "LogicUGCCollectionList:RequestCollectionList failed." .. tostring(Reason))
  end)
  if bFakeTest then
    self:AddTimer(1, function()
      EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_REQUESTCOLLECTIONLIST)
    end)
  end
end
function LogicUGCCollectionList:SplitTable(t)
  local t1 = {}
  local t2 = {}
  for i = 1, #t do
    if i <= BatchSize then
      table.insert(t1, t[i])
    else
      table.insert(t2, t[i])
    end
  end
  return t1, t2
end
function LogicUGCCollectionList:RequestCollectionData(CollectionID)
  if CollectionID then
    if self.InvalidMap[CollectionID] then
      log(bWriteLog and "LogicUGCCollectionList:RequestCollectionData Collection is not accessible.  CollectionID: " .. tostring(CollectionID))
      return
    end
    local bRepeated = false
    for _, Id in pairs(self.ToRequestCollectionList) do
      if Id == CollectionID then
        bRepeated = true
        break
      end
    end
    if bRepeated == false then
      table.insert(self.ToRequestCollectionList, CollectionID)
    end
    if self.RequestCollectionDataTimer == nil then
      self.RequestCollectionDataTimer = self:AddTimerOnce(0, function()
        local UGCModHandler = require("client.network.Protocol.UGCModHandler")
        local RequestIds, SplitTable = self:SplitTable(self.ToRequestCollectionList)
        UGCModHandler.send_ugc_batch_get_mod_collection_data_req(RequestIds):Then(function(ErrCode, CollectionDataList, Invalids)
          self:UpdateInvalidCollections(Invalids)
          self:CacheCollectionDataList(CollectionDataList)
          EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_BATCH_REQUESTCOLLECTION_META)
        end, function(Reason)
          log(bWriteLog and "LogicUGCCollectionList:RequestCollectionData send_ugc_batch_get_mod_collection_data_req failed." .. tostring(Reason))
        end)
        self.ToRequestCollectionList = SplitTable
        self.RequestCollectionDataTimer = nil
        if 0 < #SplitTable then
          self:RequestCollectionData(SplitTable[1])
        end
      end)
    end
  end
end
function LogicUGCCollectionList:CanHaveMoreCollection()
  if not self.ModCollectionCount then
    return false
  end
  if not self.MyCollectionList then
    return false
  end
  return #self.MyCollectionList < self.ModCollectionCount
end
function LogicUGCCollectionList:CanLikeMoreCollection()
  return self.LikeModCollectionCount and #self.LikeCollectionList < self.LikeModCollectionCount
end
function LogicUGCCollectionList:UpdateInvalidCollections(Invalids)
  if Invalids then
    for K, _ in pairs(Invalids) do
      self.InvalidMap[K] = true
    end
  end
end
function LogicUGCCollectionList:CacheCollectionDataList(CollectionDataList)
  if CollectionDataList then
    for _, Data in pairs(CollectionDataList) do
      self:_PostProcessCollectionMeta(Data)
      self.CacheCollectionDataMap[Data.mod_collection_id] = Data
    end
  end
end
function LogicUGCCollectionList:_PostProcessCollectionMeta(Data)
  Data.ModList = {}
  for ModId, ModData in pairs(Data.pub_mod_list) do
    table.insert(Data.ModList, {
      ModId = ModId,
      UpdateTime = ModData.update_time
    })
  end
  table.sort(Data.ModList, function(a, b)
    return a.UpdateTime > b.UpdateTime
  end)
end
function LogicUGCCollectionList:CancelLikeCollection(CollectionId)
  if self.LikeCollectionList then
    for Idx, Id in pairs(self.LikeCollectionList) do
      if Id == CollectionId then
        table.remove(self.LikeCollectionList, Idx)
        EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_LIKEUPDATE_COLLECTION)
        return
      end
    end
  end
end
function LogicUGCCollectionList:LikeCollection(CollectionId)
  if self.LikeCollectionList then
    for _, Id in pairs(self.LikeCollectionList) do
      if Id == CollectionId then
        return
      end
    end
    table.insert(self.LikeCollectionList, 1, CollectionId)
  else
    self.LikeCollectionList = {CollectionId}
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_LIKEUPDATE_COLLECTION)
end
function LogicUGCCollectionList:IsLike(CollectionId)
  if self.LikeCollectionList then
    for _, Id in pairs(self.LikeCollectionList) do
      if Id == CollectionId then
        return true
      end
    end
  end
  return false
end
function LogicUGCCollectionList:AddNewCollection(CollectionId, CollectionMeta)
  self.MyCollectionList = self.MyCollectionList or {}
  table.insert(self.MyCollectionList, 1, CollectionId)
  self:_PostProcessCollectionMeta(CollectionMeta)
  self.CacheCollectionDataMap[CollectionMeta.mod_collection_id] = CollectionMeta
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_NEW_COLLECTION)
end
function LogicUGCCollectionList:DelCollection(CollectionId)
  self.MyCollectionList = self.MyCollectionList or {}
  for Idx, Id in pairs(self.MyCollectionList) do
    if Id == CollectionId then
      table.remove(self.MyCollectionList, Idx)
      EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_DEL_COLLECTION)
      return
    end
  end
end
function LogicUGCCollectionList:UpdateCollection(CollectionId, CollectionMeta, bIgnore)
  self:_PostProcessCollectionMeta(CollectionMeta)
  self.CacheCollectionDataMap[CollectionMeta.mod_collection_id] = CollectionMeta
  if not bIgnore then
    for Idx, Id in pairs(self.MyCollectionList) do
      if Id == CollectionId then
        table.remove(self.MyCollectionList, Idx)
        table.insert(self.MyCollectionList, 1, CollectionId)
        break
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_UPDATE_COLLECTION)
end
function LogicUGCCollectionList:GetCollectionInfo(CollectionID)
  if not CollectionID then
    return nil
  end
  if self.CacheCollectionDataMap then
    return self.CacheCollectionDataMap[CollectionID]
  end
  return nil
end
function LogicUGCCollectionList:IsInvalidCollection(CollectionID)
  if not CollectionID then
    return true
  end
  if self.InvalidMap[CollectionID] then
    return true
  end
  return false
end
function LogicUGCCollectionList:_ClearTimer()
  if self.RequestCollectionDataTimer ~= nil then
    self:RemoveTimer(self.RequestCollectionDataTimer)
    self.RequestCollectionDataTimer = nil
  end
end
function LogicUGCCollectionList:_TestCode_GenFakeCollections(num)
  local uid_list = {
    54300027147,
    54300029095,
    54300025446,
    54300024371,
    54300025043,
    54300020600
  }
  local mod_id_list = {
    79411,
    18656,
    16882,
    18076,
    19332
  }
  local start_idx = 10000
  local screenshotPathUrls = {
    "ugc/20230529/igshare1381581591688081685376610_03645685.jpg",
    "ugc/20230608/igshare1381581591688081686247619_04922691.jpg",
    "ugc/20230608/igshare1381581591688081686247721_01092270.jpg",
    "ugc/20230608/igshare1381581591688081686248683_04738948.jpg",
    "ugc/20230608/igshare1381581591688081686248612_08296212.jpg",
    "ugc/20230608/igshare1381581591688081686245596_04718183.jpg",
    ""
  }
  local tag_list = {}
  for _, Tag in pairs(self.TagConfigs) do
    table.insert(tag_list, Tag.ID)
  end
  local collections = {}
  for i = 1, num do
    local collection = {
      name = "\228\189\156\229\147\129\229\144\136\233\155\134" .. tostring(i),
      desc = "\232\191\153\230\152\175\228\189\156\229\147\129\229\144\136\233\155\134" .. tostring(i) .. "\231\154\132\230\143\143\232\191\176",
      tag = tag_list[math.random(#tag_list)],
      uid = uid_list[math.random(#uid_list)],
      openid = "openid" .. tostring(i),
      game_app_id = "gameappid" .. tostring(i),
      mod_collection_id = start_idx + i,
      pic_url = screenshotPathUrls[math.random(#screenshotPathUrls)],
      last_edit_time = os.time(),
      play_cnt = math.random(1000),
      collect_cnt = math.random(1000),
      view_cnt = math.random(1000),
      share_cnt = math.random(1000),
      pub_mod_list_count = math.random(#mod_id_list),
      state_release = math.random(2) - 1,
      pub_mod_list = {}
    }
    for j = 1, collection.pub_mod_list_count do
      collection.pub_mod_list[mod_id_list[math.random(#mod_id_list)]] = {update_time = 0}
    end
    table.insert(collections, collection)
  end
  return collections
end
function LogicUGCCollectionList:ReqSearchCollection(Key)
  local UGCSearchHandler = require("client.network.Protocol.UGCSearchHandler")
  UGCSearchHandler.send_ugc_search_mod_collection_req(Key):Then(function(ErrCode, Key, CollectionDataList)
    if CollectionDataList and 0 < #CollectionDataList then
      self:CacheCollectionDataList(CollectionDataList)
    end
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_SEARCH_MOD_COLLECTIONS, Key, CollectionDataList)
  end, function(Reason)
    log(bWriteLog and "LogicUGCCollectionList:ReqSearchCollection failed." .. tostring(Reason))
  end)
  if _G.IsEditor and false then
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_SEARCH_MOD_COLLECTIONS, Key, self:_TestCode_GenFakeCollections(10))
  end
end
function LogicUGCCollectionList:NewReqSearchCollection(tag_list)
  local UGCModHandler = require("client.network.Protocol.UGCModHandler")
  UGCModHandler.send_ugc_batch_get_mod_collection_data_req(tag_list):Then(function(ErrCode, CollectionDataList, Invalids)
    self:UpdateInvalidCollections(Invalids)
    self:CacheCollectionDataList(CollectionDataList)
    if CollectionDataList and 0 < #CollectionDataList then
      EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_NEWCCOMPILATIONSSEARCH_MOD, false, true)
    else
      EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_NEWCCOMPILATIONSSEARCH_MOD, false, false)
    end
  end, function(Reason)
    log(bWriteLog and "LogicUGCCollectionList:ReqSearchCollection failed." .. tostring(Reason))
  end)
end
function LogicUGCCollectionList:GetOpenCollection()
  return self.OpenCollectionId
end
function LogicUGCCollectionList:OpenDetails(CollectionId)
  self.Open  print(bWriteLog and "LogicUGCCollectionList:OpenDetails " .. tostring(CollectionId))
end
function LogicUGCCollectionList:CloseDetails()
  self.OpenCollectionId = nil
  print(bWriteLog and "LogicUGCCollectionList:CloseDetails")
end
function LogicUGCCollectionList:IsFirstClickMineCollection()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local Data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCNewbieMineCollections)
  if Data then
    return Data.NewbieMineCollections ~= true
  end
  return true
end
function LogicUGCCollectionList:MarkClickedMineCollection()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local Data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCNewbieMineCollections) or {}
  if Data and not Data.NewbieMineCollections then
    Data.NewbieMineCollections = true
    PlayerPrefsSystem.SaveTableToFile_N(Data, PlayerPrefsSystem.ePlayerPrefsType.eUGCNewbieMineCollections)
  end
end
function LogicUGCCollectionList:GetShareCollectionData()
  return self.ShareCollectionData
end
function LogicUGCCollectionList:SetShareCollectionData(Data)
  self.ShareCollectionend
function LogicUGCCollectionList:SetCurSelectCollectionID(CollectionId)
  log(bWriteLog and "LogicUGCCollectionList:SetCurSelectCollectionID CollectionId = " .. tostring(CollectionId))
  self.CurSelectCollectionID = CollectionId
end
function LogicUGCCollectionList:GetCurSelectCollectionID()
  return self.CurSelectCollectionID
end
local class = require("class")
local CJumpModuleBase = require("client.module_framework.ModuleBase")
local CLogicUGCRank = class(CJumpModuleBase, nil, LogicUGCCollectionList)
return CLogicUGCRank