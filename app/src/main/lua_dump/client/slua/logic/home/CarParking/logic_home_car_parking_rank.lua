local logic_home_car_parking_rank = {}
function logic_home_car_parking_rank:DefineAndResetData()
  self.rank_data_list = nil
  self.one_user_rank = nil
  self.awards = {}
  self.nextMondayTimestamp = 1748822400
  self.rankReadyStartTimestamp = 1748822400
  self.rankReadyEndTimestamp = 1748826000
  self.bUseFakeData = false
  self.fake_rank_data_list = {
    [1] = {
      rank_no = 1,
      score = 8543,
      uid = 5344807037
    },
    [2] = {
      ext_data = {
        master_uid = 510216555,
        mate_uid = 510216555,
        members = {
          [1] = 510218690,
          [2] = 510216555
        }
      },
      rank_no = 2,
      score = 4768,
      uid = 510218690
    }
  }
  self.fake_profiles_single = {
    [1] = {
      cur_avatar_box_id = 31261,
      nickName = "\231\142\169\229\174\182\229\144\141\229\173\151\228\184\131\228\184\170\229\173\151",
      picUrl = "http://pbs.twimg.com/profile_images/1797948226076590080/UPaLFKJn_bigger.jpg",
      uid = 5344807037,
      upass = {
        acc_score = 26154,
        acc_update_time = 1749542227,
        cur_season = 54,
        cur_value = 476,
        is_buy = 1,
        keep_buy = 3,
        level = 100,
        pass_type = 2,
        score = 314,
        switch = {
          battle_show = true,
          battle_title = true,
          record_privacy = false,
          ui = true
        }
      }
    }
  }
  self.fake_profiles_couple = {
    [1] = {
      cur_avatar_box_id = 2001001,
      nickName = "\230\159\146\228\184\131",
      picUrl = "http://thirdqq.qlogo.cn/ek_qqapp/AQXpzmMx6QRBNhtyogYFZwHq7jCaLtRunHtibGuSbNeQbtNdudREWjmuvzLnCUalI0icTDiacgq/100",
      uid = 510218690
    },
    [2] = {
      cur_avatar_box_id = 2001001,
      nickName = "kok54",
      picUrl = "10001",
      uid = 510216555
    }
  }
  self.fake_one_user_rank = {
    ext_data = {
      master_uid = 510203750,
      mate_uid = 510203750,
      members = {
        [1] = 510203750,
        [2] = 510219854
      }
    },
    rank_no = 7,
    score = 741,
    score_type = 90001,
    uid = 510219854
  }
end
function logic_home_car_parking_rank:OnInitialize()
  local RankConfig = require("client.slua.logic.rank.rank_config")
  local awardsTable = CDataTable.GetTable("RankRewardTable")
  for _, v in pairs(awardsTable) do
    if v.RankType == RankConfig.ScoreType.planph_car_parking then
      local data = {
        ceilling = v.RankCeilling,
        floor = v.RankFloor,
        awards = {
          {
            id = v.RewardItemID1,
            count = v.RewardItemCnt1
          },
          {
            id = v.RewardItemID2,
            count = v.RewardItemCnt2
          }
        }
      }
      table.insert(self.awards, data)
    end
  end
end
function logic_home_car_parking_rank:GetAllRankData()
  if self.rank_data_list == nil then
    log(bWriteLog and "logic_home_car_parking_rank:GetAllRankData self.rank_data_list == nil")
    return {}
  end
  local datas = self.rank_data_list
  if self:IsInReadyRankData() then
    log(bWriteLog and "logic_home_car_parking_rank:GetAllRankData rank is in ready")
    datas = {}
  end
  if self.bUseFakeData then
    log(bWriteLog and "logic_home_car_parking_rank:GetAllRankData self.bUseFakeData == true")
    datas = self.fake_rank_data_list
  end
  local res = {}
  for _, v in pairs(datas) do
    v.rank_type = 1
    for _, award in pairs(self.awards) do
      if v.rank_no >= award.ceilling and v.rank_no <= award.floor then
        v.awards = award.awards
      end
    end
    if v.ext_data and v.ext_data.members then
      v.members = v.ext_data.members
    end
    table.insert(res, v)
  end
  return res
end
function logic_home_car_parking_rank:GetMyRankDataInAll()
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local getDefualtMyRankData = function()
    local res = {
      uid = DataMgr.roleData.uid,
      score = 0
    }
    local logic_home_profile = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_profile)
    local summary = logic_home_profile:GetHomeProfileByUid(res.uid)
    if summary.joint_members then
      local uidL = next(summary.joint_members)
      local uidR = next(summary.joint_members, uidL)
      local profileL = logic_profile:GetLocalProfile(uidL)
      local profileR = logic_profile:GetLocalProfile(uidR)
      if profileL and next(profileL) and profileR and next(profileR) then
        res.members = {}
        table.insert(res.members, uidL)
        table.insert(res.members, uidR)
      else
        log(bWriteLog and string.format("logic_home_car_parking_rank:GetMyRankDataInAll profileL or profileR is nil, uidL = %s, uidR = %s", tostring(uidL), tostring(uidR)))
      end
    end
    local TimeUtil = require("client.common.time_util")
    local nowTime = TimeUtil.GetServerTimeInSec()
    if summary.parking_info and summary.parking_info.weekly_currency_refresh_tm and TimeUtil.IsSameWeek(nowTime, summary.parking_info.weekly_currency_refresh_tm) then
      if summary.parking_info.weekly_currency_mmbr then
        local uidL, score1 = next(summary.parking_info.weekly_currency_mmbr)
        local _, score2 = next(summary.parking_info.weekly_currency_mmbr, uidL)
        res.score = math.max(score1 or 0, score2 or 0)
      elseif summary.parking_info.weekly_currency then
        res.score = summary.parking_info.weekly_currency
      else
        res.score = 0
      end
    end
    return res
  end
  local data = getDefualtMyRankData()
  if self.one_user_rank and next(self.one_user_rank) and self.one_user_rank.score and self.one_user_rank.uid and self.one_user_rank.rank_no then
    data = self.one_user_rank
  end
  if self:IsInReadyRankData() then
    data.rank_no = nil
    data.rank_str = LocUtil.GetLocalizeResStr(102127)
    data.score = 0
  end
  if self.bUseFakeData then
    log(bWriteLog and "logic_home_car_parking_rank:GetMyRankDataInAll self.bUseFakeData == true")
    data = self.fake_rank_data_list[math.random(1, 2)]
  end
  data.rank_type = 1
  if data.score == nil or data.rank_no == nil or data.rank_no <= 0 then
    data.rank_str = LocUtil.GetLocalizeResStr(102127)
  elseif data.rank_no <= 10000 then
    data.rank_str = data.rank_no
    for _, award in pairs(self.awards) do
      if data.rank_no >= award.ceilling and data.rank_no <= award.floor then
        data.awards = award.awards
      end
    end
  else
    local top100_score = data.score * 2
    if 0 < #self.rank_data_list then
      top100_score = self.rank_data_list[#self.rank_data_list].score
    end
    data.rank_str = self:GetPercentStr(data.score, top100_score)
  end
  log(bWriteLog and "logic_home_car_parking_rank:GetMyRankDataInAll rank_str: " .. tostring(data.rank_str))
  if data.ext_data and data.ext_data.members then
    data.members = data.ext_data.members
  end
  return data
end
function logic_home_car_parking_rank:ReqFriendRankData()
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local friends = LogicFriend.GetFriendList(false)
  local uids = {}
  for _, v in pairs(friends) do
    table.insert(uids, tonumber(v.uid))
  end
  local my_uid = tonumber(DataMgr.roleData.uid)
  table.insert(uids, my_uid)
  local bSummary = false
  local bProfile = false
  local finished = function()
    log(bWriteLog and "logic_home_car_parking_rank:ReqFriendRankData finished")
    EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_CAR_PARKING_RANK_UPDATE_LIST)
  end
  local summary_callback = function()
    log(bWriteLog and "logic_home_car_parking_rank:ReqFriendRankData summary_callback")
    bSummary = true
    if bSummary and bProfile then
      finished()
    end
  end
  local profile_callback = function()
    log(bWriteLog and "logic_home_car_parking_rank:ReqFriendRankData profile_callback")
    bProfile = true
    if bSummary and bProfile then
      finished()
    end
  end
  local logic_home_profile = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_profile)
  logic_home_profile:GetOrReqHomeProfile(uids, summary_callback, true)
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetNormalProfiles(uids, profile_callback, Enum_PROFILE_REPORT_CFG.PLANPH_CAR_PARKING, 0, true)
end
function logic_home_car_parking_rank:GetFriendRankData()
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local logic_home_profile = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_profile)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  local processed = {}
  local res = {}
  local friends = LogicFriend.GetFriendList(false)
  local datas = {}
  for _, v in pairs(friends) do
    local uid = tonumber(v.uid)
    datas[uid] = {
      uid = uid,
      rank_type = 2,
      score = 0
    }
  end
  local my_uid = tonumber(DataMgr.roleData.uid)
  datas[my_uid] = {
    uid = my_uid,
    rank_type = 2,
    score = 0
  }
  for _, v in pairs(datas) do
    local uid = tonumber(v.uid)
    local profile = logic_profile:GetLocalProfile(uid)
    if processed[uid] or profile == nil or next(profile) == nil then
    else
      local summary = logic_home_profile:GetHomeProfileByUid(uid)
      table.insert(res, datas[uid])
      if summary and summary.joint_members then
        local uidL = next(summary.joint_members)
        local uidR = next(summary.joint_members, uidL)
        local profileL = logic_profile:GetLocalProfile(uidL)
        local profileR = logic_profile:GetLocalProfile(uidR)
        if profileL and next(profileL) and profileR and next(profileR) then
          datas[uid].members = {}
          table.insert(datas[uid].members, uidL)
          table.insert(datas[uid].members, uidR)
          processed[uidL] = true
          processed[uidR] = true
        else
          log(bWriteLog and string.format("logic_home_car_parking_rank:GetFriendRankData profileL or profileR is nil, uidL = %s, uidR = %s", tostring(uidL), tostring(uidR)))
        end
      end
      if summary and summary.parking_info and summary.parking_info.weekly_currency_refresh_tm and TimeUtil.IsSameWeek(nowTime, summary.parking_info.weekly_currency_refresh_tm) then
        if summary.parking_info.weekly_currency_mmbr then
          local uidL, score1 = next(summary.parking_info.weekly_currency_mmbr)
          local _, score2 = next(summary.parking_info.weekly_currency_mmbr, uidL)
          datas[uid].score = math.max(score1 or 0, score2 or 0)
        elseif summary.parking_info.weekly_currency then
          datas[uid].score = summary.parking_info.weekly_currency
        else
          datas[uid].score = 0
        end
      end
    end
  end
  local sort = function(l, r)
    return l.score > r.score
  end
  table.sort(res, sort)
  for i, v in pairs(res) do
    v.rank_no = i
  end
  if self:IsInReadyRankData() then
    for _, v in pairs(res) do
      v.score = 0
    end
  end
  return res
end
function logic_home_car_parking_rank:GetPercentStr(score, top100_score)
  local gap_ratio = (top100_score - score) / top100_score
  local percent = 99
  if gap_ratio <= 0.3 then
    percent = gap_ratio * 100 * 0.3
  elseif gap_ratio <= 0.7 then
    percent = 9 + (gap_ratio - 0.3) * 100 * 1.4
  else
    percent = 65 + (gap_ratio - 0.7) * 100 * 0.6
  end
  percent = math.floor(percent + 0.5)
  percent = math.min(99, math.max(1, percent))
  return tostring(percent) .. "%"
end
function logic_home_car_parking_rank:GetFakeProfile(num)
  if num == 1 then
    return self.fake_profiles_single[1]
  elseif num == 2 then
    return self.fake_profiles_couple[1]
  elseif num == 3 then
    return self.fake_profiles_couple[2]
  end
end
function logic_home_car_parking_rank:GetRemainingTimeStr()
  local TimeUtil = require("client.common.time_util")
  local logic_home_car_parking = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_car_parking)
  local session = logic_home_car_parking:GetSessionConfig()
  local sessionEndTime = TimeUtil.TimeStringToUnixstamp(session.EndTime)
  local nowTimestamp = TimeUtil.GetServerTimeInSec()
  while nowTimestamp > self.nextMondayTimestamp do
    self.nextMondayTimestamp = self.nextMondayTimestamp + 604800
    log(bWriteLog and "logic_home_car_parking_rank:GetRemainingTimeStr nowTimestamp=" .. tostring(nowTimestamp) .. ", nextMondayTimestamp=" .. tostring(self.nextMondayTimestamp))
  end
  local deadline = math.min(self.nextMondayTimestamp, sessionEndTime)
  if deadline == sessionEndTime then
    log(bWriteLog and "logic_home_car_parking_rank:GetRemainingTimeStr nowTimestamp=" .. tostring(nowTimestamp) .. ", sessionEndTime=" .. tostring(sessionEndTime))
  end
  local remainingTimestamp = deadline - nowTimestamp
  return TimeUtil.FormatCountDownTime_DHM_or_HMS(remainingTimestamp, 1)
end
function logic_home_car_parking_rank:IsInReadyRankData()
  local TimeUtil = require("client.common.time_util")
  local nowTimestamp = TimeUtil.GetServerTimeInSec()
  while nowTimestamp > self.rankReadyEndTimestamp do
    self.rankReadyStartTimestamp = self.rankReadyStartTimestamp + 604800
    self.rankReadyEndTimestamp = self.rankReadyEndTimestamp + 604800
    log(bWriteLog and "logic_home_car_parking_rank:IsInReadyRankData nowTimestamp=" .. tostring(nowTimestamp) .. ", rankReadyStartTimestamp=" .. tostring(self.rankReadyStartTimestamp) .. ", rankReadyEndTimestamp=" .. tostring(self.rankReadyEndTimestamp))
  end
  return TimeUtil.UnixTimeBetween(self.rankReadyStartTimestamp, self.rankReadyEndTimestamp) == 0
end
function logic_home_car_parking_rank:IsCarParkingRank(rank_requird_id)
  local RankConfig = require("client.slua.logic.rank.rank_config")
  return rank_requird_id == RankConfig.ScoreType.planph_car_parking
end
function logic_home_car_parking_rank:send_get_topn_rank()
  log(bWriteLog and "logic_home_car_parking_rank:send_get_topn_rank")
  local RankHandler = require("client.network.Protocol.RankHandler")
  local RankConfig = require("client.slua.logic.rank.rank_config")
  RankHandler.send_get_topn_rank(0, RankConfig.ScoreType.planph_car_parking, 1)
end
function logic_home_car_parking_rank:proc_get_topn_rank_rsp(res, rank_requird_id, rank_data_list)
  local RankConfig = require("client.slua.logic.rank.rank_config")
  if rank_requird_id == RankConfig.ScoreType.planph_car_parking then
    log(bWriteLog and string.format("logic_home_car_parking_rank:proc_get_topn_rank_rsp, res:%s", res))
    log_tree(bWriteLog and "logic_home_car_parking_rank:proc_get_topn_rank_rsp rank_data_list", rank_data_list)
  end
  if res == 0 then
    local TableUtil = require("common.table_util")
    self.rank_data_list = TableUtil.CopyTable(rank_data_list)
  end
  EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_CAR_PARKING_RANK_UPDATE_LIST)
  local callback = function(profiles)
    log_tree(bWriteLog and "logic_home_car_parking_rank:proc_get_topn_rank_rsp callback profiles", profiles)
    EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_CAR_PARKING_RANK_UPDATE_ITEM)
  end
  local uids = {}
  for _, v in pairs(rank_data_list) do
    if v.ext_data and v.ext_data.members then
      table.insert(uids, tonumber(v.ext_data.members[1]))
      table.insert(uids, tonumber(v.ext_data.members[2]))
    else
      table.insert(uids, tonumber(v.uid))
    end
  end
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetNormalProfiles(uids, callback, Enum_PROFILE_REPORT_CFG.PLANPH_CAR_PARKING, 0, true)
end
function logic_home_car_parking_rank:send_get_one_user_rank()
  log(bWriteLog and "logic_home_car_parking_rank:send_get_one_user_rank")
  local RankHandler = require("client.network.Protocol.RankHandler")
  local RankConfig = require("client.slua.logic.rank.rank_config")
  local logic_home_joint = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_joint)
  local jointInfo = logic_home_joint:GetHomeJointInfo()
  if jointInfo and jointInfo.joint_id then
    RankHandler.send_get_one_user_rank("HomeCarParkingRank", 0, jointInfo.joint_id, RankConfig.ScoreType.planph_car_parking)
  else
    RankHandler.send_get_one_user_rank("HomeCarParkingRank", 0, 0, RankConfig.ScoreType.planph_car_parking)
  end
end
function logic_home_car_parking_rank:proc_get_one_user_rank(rank_source, res, rank_info)
  if rank_source == "HomeCarParkingRank" then
    log(bWriteLog and string.format("logic_home_car_parking_rank:proc_get_one_user_rank, res:%s", res))
    log_tree(bWriteLog and "logic_home_car_parking_rank:proc_get_one_user_rank rank_info", rank_info)
  end
  if rank_source == "HomeCarParkingRank" and res == 0 then
    local TableUtil = require("common.table_util")
    self.one_user_rank = TableUtil.CopyTable(rank_info)
    EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_CAR_PARKING_RANK_UPDATE_SELF)
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_home_car_parking_rank = class(CModuleBase, nil, logic_home_car_parking_rank)
return Clogic_home_car_parking_rank