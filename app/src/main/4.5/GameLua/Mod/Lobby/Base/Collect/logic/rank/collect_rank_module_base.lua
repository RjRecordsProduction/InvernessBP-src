local collect_rank_module_base = {}
local CONST = {
  reqPerPageNum = 10,
  maxRewardRank = 1000,
  reqPerPageRankNum = 100,
  maxReqInterval = 120
}
function collect_rank_module_base:CustomizeDerivedConfig()
  log_warning(bWriteLog and string.format("collect_rank_module:CustomizeDerivedConfig: Need to overload this function."))
end
function collect_rank_module_base:DefineAndResetData()
  self.selfRankData = nil
  self.rankDataList = nil
  self.userRankAwardList = nil
  self.reqPageMark = {}
  self:CustomizeDerivedConfig()
end
function collect_rank_module_base:OnLogOut()
  self:ClearData()
end
function collect_rank_module_base:ClearData()
  self.selfRankData = nil
  self.rankDataList = nil
  self.userRankAwardList = nil
  self.rankID = nil
  self.userRankMark = nil
  self.profileScene = nil
  self.reqPageMark = nil
end
function collect_rank_module_base:IsCharmValueRank(score_type)
  return score_type == self.rankID
end
function collect_rank_module_base:InitRankAndAwardData()
  if not self.rankID then
    log(bWriteLog and string.format("collect_rank_module:InitRankAndAwardData rankID is nil."))
    return
  end
  if not self.userRankAwardList and self.rankAwardName then
    local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
    BasicDataServerTable:GetOrReqData(self.rankAwardName, function(tableName, table_data)
      self:OnRankAwardCallBack(tableName, table_data)
    end)
  else
    self:InitRankData()
  end
end
function collect_rank_module_base:OnRankAwardCallBack(tableName, table_data)
  log(bWriteLog and string.format("collect_rank_module:OnRankAwardCallBack tableName = %s", tableName))
  log_tree("collect_rank_module:OnRankAwardCallBack", table_data)
  if table_data and next(table_data) and table_data[self.rankID] then
    self.userRankAwardList = table_data[self.rankID]
  end
  self:InitRankData()
end
function collect_rank_module_base:InsertRankRewardData(nRankNum, tRankData)
  if self.rankAwardName then
    self:InsertRewardDataByServerCfg(nRankNum, tRankData)
  else
    self:InsertRankRewardDataByCfg(nRankNum, tRankData)
  end
end
function collect_rank_module_base:InsertRewardDataByServerCfg(rank, rankData)
  if not self.userRankAwardList then
    return
  end
  local insertData = function(i, config)
    if config[string.format("item_id_%s", i)] > 0 then
      local temp = {
        itemId = config[string.format("item_id_%s", i)],
        count = config[string.format("item_num_%s", i)],
        expireTime = config[string.format("item_valid_hour_%s", i)]
      }
      rankData.rewardList[i] = temp
    end
  end
  for level, config in ipairs(self.userRankAwardList) do
    if rank >= config.rank_min and rank <= config.rank_max then
      for i = 1, 4 do
        insertData(i, config)
      end
    end
  end
end
function collect_rank_module_base:InsertRankRewardDataByCfg(nRankNum, tRankData)
  if not self.rankID then
    return
  end
  local rank_util = require("client.slua.logic.rank.rank_util")
  local uObj_rankCfg = rank_util.GetRankRewardCfg(self.rankID, true) or {}
  for _, v in pairs(uObj_rankCfg) do
    if nRankNum <= v.RankFloor and nRankNum >= v.RankCeilling then
      for i = 1, 4 do
        if v["RewardItemID" .. i] ~= 0 then
          local tItemData = {
            itemId = v["RewardItemID" .. i],
            count = v["RewardItemCnt" .. i],
            expireTime = v["RewardItemTimeLimit" .. i]
          }
          tRankData.rewardList[i] = tItemData
        end
      end
    end
  end
end
function collect_rank_module_base:InitRankData()
  if not self.rankID then
    log(bWriteLog and string.format("collect_rank_module:InitRankData rankID is nil."))
    return
  end
  self.reqPageMark = {}
  self:GetSelfRankReq()
  self:GetRankListReq()
end
function collect_rank_module_base:GetSelfRankReq()
  local RankHandler = require("client.network.Protocol.RankHandler")
  RankHandler.send_get_one_user_rank(self.userRankMark, 0, tonumber(DataMgr.roleData.uid), self.rankID)
end
function collect_rank_module_base:BatchPullRankingDataByPage(index)
  local pageIndex = math.floor(index / CONST.reqPerPageRankNum) + 1
  log(bWriteLog and string.format("collect_rank_module_base:BatchPullRankingProfile index = %s, pageIndex = %s", index, pageIndex))
  if 1 < pageIndex and pageIndex <= 10 then
    self:GetRankListReq(pageIndex)
  end
end
function collect_rank_module_base:GetRankListReq(page)
  page = page or 1
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  self.reqPageMark = self.reqPageMark or {}
  if self.reqPageMark[page] and nowTime - self.reqPageMark[page] < CONST.maxReqInterval then
    return
  end
  self.reqPageMark[page] = nowTime
  log(bWriteLog and string.format("collect_rank_module:GetRankListReq page = %s", page))
  local RankHandler = require("client.network.Protocol.RankHandler")
  RankHandler.send_get_topn_rank(0, self.rankID, page)
end
function collect_rank_module_base:ResetSelfRealScore(_)
end
function collect_rank_module_base:SelfRankRsp(client_data, ok, rank_info)
  if client_data ~= self.userRankMark then
    return
  end
  if ok ~= 0 then
    log(bWriteLog and string.format("collect_rank_module:GetSelfRankRsp ok = %s", ok))
    return
  end
  rank_info = rank_info or {}
  self:ResetSelfRealScore(rank_info)
  self.selfRankData = {
    rank = rank_info.rank_no or -1,
    rankID = self.rankID,
    rank_no = rank_info.rank_no or -1,
    uid = rank_info.uid or DataMgr.roleData.uid,
    score = rank_info.score or 0,
    name = DataMgr.roleData.nickName,
    rewardList = {}
  }
  if self.activityID then
    local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
    local data = ActivityNewSystem.GetActivityByID(self.activityID)
    if self.selfRankData.score == 0 then
      local new_score = data and data.other and data.other.new_score or 0
      local his_score = data and data.other and data.other.his_score or 0
      self.selfRankData.score = new_score + his_score
    end
    self.selfRankData.join_flag = data and data.other and data.other.join_flag
  end
  local myRank = tonumber(self.selfRankData.rank) or -1
  if 0 < myRank and myRank <= CONST.maxRewardRank then
    self:InsertRankRewardData(myRank, self.selfRankData)
  end
  EventSystem:postEvent(EVENTTYPE_COLLECT, EVENTID_COLLECT_RANK_GET_SELF_DATA)
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetNormalProfiles({
    tonumber(DataMgr.roleData.uid)
  }, function(profileList)
    self:GetSelfProfileRsp(profileList)
  end, self.profileScene)
end
function collect_rank_module_base:RankListRsp(res, list, page)
  if res ~= 0 then
    log(bWriteLog and string.format("collect_rank_module:RankListRsp res = %s", res))
    return
  end
  log(bWriteLog and string.format("collect_rank_module:GetRankListRsp page = %s", page))
  log_tree("collect_rank_module:GetRankListRsp list", list)
  if not self.rankDataList then
    self.rankDataList = {}
  end
  local pageIndex = (page - 1) * CONST.reqPerPageRankNum
  for i, v in pairs(list) do
    local idx = i + pageIndex
    self.rankDataList[idx] = v
    self.rankDataList[idx].rank = idx
    self.rankDataList[idx].rewardList = {}
    self.rankDataList[idx].rankID = self.rankID
    if tonumber(self.rankDataList[idx].uid) == tonumber(DataMgr.roleData.uid) then
      self.rankDataList[idx].name = DataMgr.roleData.nickName
    end
  end
  local MaxNum = #self.rankDataList
  for i = 1 + pageIndex, MaxNum do
    self:InsertRankRewardData(i, self.rankDataList[i])
  end
  EventSystem:postEvent(EVENTTYPE_COLLECT, EVENTID_COLLECT_GET_RANK_LIST_DATA)
  local reqProfileUIDList = {}
  for i = 1, CONST.reqPerPageNum do
    if list[i] and not list[i].reqProfile then
      table.insert(reqProfileUIDList, list[i].uid)
      self.rankDataList[i + pageIndex].reqProfile = true
    end
  end
  self:GetRankProfileList(reqProfileUIDList)
end
function collect_rank_module_base:GetSelfRankData()
  return self.selfRankData
end
function collect_rank_module_base:GetRankDataList()
  return self.rankDataList
end
function collect_rank_module_base:BatchPullRankingProfile(index)
  local reqProfileUIDList = {}
  for i = index, index + CONST.reqPerPageNum do
    if self.rankDataList[i] and not self.rankDataList[i].reqProfile then
      self.rankDataList[i].reqProfile = true
      table.insert(reqProfileUIDList, self.rankDataList[i].uid)
    end
  end
  self:GetRankProfileList(reqProfileUIDList)
end
function collect_rank_module_base:GetRankProfileList(uidList)
  log_tree("GetRankProfileList", uidList)
  if not uidList or #uidList <= 0 then
    return
  end
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetNormalProfiles(uidList, function(profileList)
    self:GetRankListProfileRsp(profileList)
  end, self.profileScene)
end
function collect_rank_module_base:GetRankListProfileRsp(profileList)
  if not profileList or not next(profileList) then
    log(bWriteLog and string.format("collect_rank_module:GetRankListProfileRsp profileList is nil."))
    return
  end
  if not self.rankDataList then
    log(bWriteLog and string.format("collect_rank_module:GetRankListProfileRsp self.rankDataList is nil."))
    return
  end
  local profileMap = {}
  for _, profile_data in ipairs(profileList) do
    profileMap[tonumber(profile_data.uid)] = profile_data
  end
  local match_rank_map = {}
  for index, rank_item in pairs(self.rankDataList) do
    self:StructuringRankProfileData(profileMap, rank_item)
    match_rank_map[index] = rank_item
  end
  EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_RANK_ICE_PROFILE_UPDATE, match_rank_map)
end
function collect_rank_module_base:GetSelfProfileRsp(profileList)
  if not profileList or not next(profileList) then
    log(bWriteLog and string.format("collect_rank_module:GetRankListProfileRsp profileList is nil."))
    return
  end
  if not self.selfRankData then
    log(bWriteLog and string.format("collect_rank_module:GetRankListProfileRsp self.selfRankData is nil."))
    return
  end
  local profileMap = {}
  for _, profile_data in ipairs(profileList) do
    profileMap[tonumber(profile_data.uid)] = profile_data
  end
  self:StructuringRankProfileData(profileMap, self.selfRankData)
  EventSystem:postEvent(EVENTTYPE_COLLECT, EVENTID_COLLECT_RANK_GET_SELF_DATA)
end
function collect_rank_module_base:StructuringRankProfileData(profileMap, rank_item)
  local profile = profileMap[tonumber(rank_item.uid)]
  if profile then
    rank_item.name = profile.nickName
    rank_item.nation = profile.nation
    rank_item.city = profile.city
    rank_item.url = profile.picUrl
    rank_item.level = profile.level
    rank_item.gender = profile.sex
    rank_item.cur_avatar_box_id = profile.cur_avatar_box_id
    rank_item.startup_type = profile.startup_type
    rank_item.friend_nickname_skin = profile.friend_nickname_skin
    rank_item.auth_type = profile.auth_type
    rank_item.auth_end_time = profile.auth_end_time
    rank_item.upass = {}
    rank_item.upass.level = profile.upass.level
    rank_item.upass.acc_score = profile.upass.acc_score
    rank_item.upass.acc_update_time = profile.upass.acc_update_time
    rank_item.upass.uishow = profile.upass.switch.ui
    rank_item.upass.is_buy = profile.upass.is_buy
    rank_item.upass.keep_buy = profile.upass.keep_buy or 0
    rank_item.upass.cur_value = profile.upass.cur_value or 0
    rank_item.upass.pass_type = profile.upass.pass_type or 0
    rank_item.light_board_info = profile.light_board_info
    rank_item.collect_data = profile.collect_data
    rank_item.total_popularity = profile.total_devote or -1
    rank_item.light_board_info = profile.light_board_info
  end
  if tonumber(rank_item.uid) == tonumber(DataMgr.roleData.uid) then
    rank_item.name = DataMgr.roleData.nickName
    rank_item.url = DataMgr.roleData.headIconUrl
    rank_item.gender = DataMgr.roleData.gender
    rank_item.cur_avatar_box_id = DataMgr.roleData.cur_avatar_box_id
    rank_item.level = DataMgr.roleData.level
    rank_item.total_popularity = DataMgr.roleData.total_devote or -1
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, collect_rank_module_base)
return CModuleTemplate