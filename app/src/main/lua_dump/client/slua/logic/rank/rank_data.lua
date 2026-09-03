local TableUtil = require("common.table_util")
local rank_item_template = require("client.slua.logic.rank.rank_item_template")
local rank_data_converter = require("client.slua.logic.rank.rank_data_converter")
local RankDataMgr = require("client.slua.logic.rank.rank_data_mgr")
local RankConfig = require("client.slua.logic.rank.rank_config")
local rank_util = require("client.slua.logic.rank.rank_util")
local rank_data = {}
local rank_item_list = {}
local rank_item_map = {}
local uid_rank_map = {}
local selfBelow1wDisplay = ""
local selfIntimacyRankUID
local friend_rank_map_cache = {}
local friend_rank_cache_zone_id
function rank_data.InitData()
  rank_data.ClearAllData()
  rank_data.CreateRankItem(DataMgr.roleData.uid)
  local rank_item = rank_item_map[tostring(DataMgr.roleData.uid)]
  if rank_item then
    rank_data_converter.ConvertSelfRoleData(rank_item)
  end
end
function rank_data.ClearAllData()
  log(bWriteLog and "[rank_data asdasd] ClearAllData")
  rank_data.ClearRankData()
  rank_item_map = {}
  selfIntimacyRankUID = nil
  friend_rank_map_cache = {}
  friend_rank_cache_zone_id = nil
end
function rank_data.CreateRankItem(uid)
  if not uid then
    log(bWriteLog and "[rank_data] nil uid to create rank item")
    return
  end
  if rank_item_map[tostring(uid)] then
    log(bWriteLog and "[rank_data] rank item already created: " .. tostring(uid))
    return
  end
  local rank_item = TableUtil.CopyTable(rank_item_template)
  rank_item.uid = tostring(uid)
  rank_item_map[tostring(uid)] = rank_item
end
function rank_data.IsItemInRank(rank_item)
  if RankDataMgr.IsXmissionType() and RankDataMgr.GetRankRegionType() ~= RankConfig.RegionEnum.friend then
    if rank_item.no > 0 and 0 < rank_item.score then
      return true
    end
  else
    return true
  end
  return false
end
function rank_data.SetRankDataList(raw_rank_list, convertFunction)
  if not raw_rank_list then
    log(bWriteLog and "[rank_data] nil raw rank list")
    return
  end
  local bIsGuardian = RankDataMgr.GetRankSelectType() == RankConfig.RankSelectEnum.guardian
  local bIsFriend = RankDataMgr.GetRankRegionType() == RankConfig.RegionEnum.friend
  local bKdRank = RankDataMgr.GetRankSelectType() == RankConfig.RankSelectEnum.peakgame_kd
  for raw_index, raw_rank_data in pairs(raw_rank_list) do
    if not rank_item_map[tostring(raw_rank_data.uid)] then
      rank_data.CreateRankItem(raw_rank_data.uid)
    else
      rank_data.ResetRankItem(rank_item_map[tostring(raw_rank_data.uid)])
    end
    local rank_item = rank_item_map[tostring(raw_rank_data.uid)]
    if rank_item and convertFunction then
      convertFunction(rank_item, raw_rank_data)
    end
    if rank_item and not uid_rank_map[tostring(raw_rank_data.uid)] and rank_data.IsItemInRank(rank_item) then
      if bIsGuardian and bIsFriend then
        if rank_item.ext_data and rank_item.ext_data.receiver_uid and rank_item.ext_data.receiver_uid > 0 then
          table.insert(rank_item_list, rank_item)
        end
      elseif bKdRank then
        rank_item.score = string.format("%.2f", rank_item.score)
        table.insert(rank_item_list, rank_item)
      else
        rank_item.score = math.floor(rank_item.score + 0.5)
        table.insert(rank_item_list, rank_item)
      end
      uid_rank_map[tostring(raw_rank_data.uid)] = raw_index
    end
  end
end
function rank_data.ResetRankItem(rank_item)
  if not rank_item then
    return
  end
  rank_item.profile_request_time = 0
  rank_item.home_profile_request_time = 0
end
function rank_data.GetRankDataList()
  return rank_item_list
end
function rank_data.SetSelfRankData(raw_self_rank_data, convertFunction)
  if not raw_self_rank_data.uid then
    return
  end
  if not rank_item_map[tostring(raw_self_rank_data.uid)] then
    rank_data.CreateRankItem(raw_self_rank_data.uid)
    local rank_item = rank_item_map[tostring(raw_self_rank_data.uid)]
    if rank_item then
      rank_data_converter.ConvertSelfRoleData(rank_item)
    end
  end
  local rank_item = rank_item_map[tostring(raw_self_rank_data.uid)]
  if not rank_item then
    log(bWriteLog and "[rank_data] invalid self rank item")
    return
  end
  if convertFunction then
    convertFunction(rank_item, raw_self_rank_data)
  end
  if RankDataMgr.IsXmissionType() and rank_item.score <= 0 then
    rank_item.no = 0
  end
end
function rank_data.ChangeSelfRankInfo(rank_no, score)
  local rank_item = rank_item_map[tostring(DataMgr.roleData.uid)]
  if not rank_item then
    log(bWriteLog and "[rank_data] invalid self rank item")
    return
  end
  rank_item.no = rank_no or ""
  rank_item.score = score or 0
  local zone_id = RankDataMgr.GetRankSelectZoneId()
  rank_item.segment = rank_data.GetArenaRatingScoreOrSegment(rank_item, zone_id, "segment_id")
end
function rank_data.SetSelfBelow1wDisplay(content)
  selfBelow1wDisplay = content
end
function rank_data.GetSelfBelow1wDisplay()
  return selfBelow1wDisplay
end
function rank_data.GetSelfRankData()
  local selfRankUID = DataMgr.roleData.uid
  if RankDataMgr.IsIntimacy() then
    if not selfIntimacyRankUID then
      log(bWriteLog and "rank_data.GetSelfRankData not selfIntimacyRankUID")
      return TableUtil.CopyTable(rank_item_template)
    end
    selfRankUID = selfIntimacyRankUID
  end
  if not rank_item_map[tostring(selfRankUID)] then
    rank_data.CreateRankItem(selfRankUID)
    local rank_item = rank_item_map[tostring(selfRankUID)]
    if rank_item then
      rank_data_converter.ConvertSelfRoleData(rank_item)
    end
  end
  return rank_item_map[tostring(selfRankUID)]
end
function rank_data.SetIntimacySelfRoleData()
  if not selfIntimacyRankUID then
    log(bWriteLog and "rank_data.SetIntimacySelfRoleData not selfIntimacyRankUID")
    return
  end
  if not rank_item_map[tostring(selfIntimacyRankUID)] then
    rank_data.CreateRankItem(selfIntimacyRankUID)
  end
  local rank_item = rank_item_map[tostring(selfIntimacyRankUID)]
  if rank_item then
    rank_data_converter.ConvertSelfRoleData(rank_item)
  end
end
function rank_data.SetItemProfile(uid, profile, convertFunction)
  if not uid or not profile then
    log(bWriteLog and "[rank_data] nil profile data to set")
    return
  end
  if not rank_item_map[tostring(uid)] then
    rank_data.CreateRankItem(uid)
  end
  local rank_item = rank_item_map[tostring(uid)]
  if rank_item and convertFunction then
    convertFunction(rank_item, profile)
  end
end
function rank_data.SetItemContentByProfile(uid)
  if not uid then
    log(bWriteLog and "[rank_data] nil uid to set")
    return
  end
  local rank_item = rank_item_map[tostring(uid)]
  if not rank_item then
    log(bWriteLog and "[rank_data] nil rank item for uid: " .. tostring(uid))
    return
  end
  uid = tostring(uid)
  local rankSelectType = RankDataMgr.GetRankSelectType()
  local rankPeriodType = RankDataMgr.GetRankPeriodType()
  local selectZoneId = RankDataMgr.GetRankSelectZoneId()
  rank_data.SetRankZoneData(rank_item, selectZoneId)
  rank_data.SetUpassData(rank_item)
  if selectZoneId ~= 7 then
    rank_item.segment, rank_item.segmentTitleId, rank_item.segmentModeId, rank_item.segmentZoneId = rank_data.GetSegmentAndSegmentTitle(rank_item, selectZoneId)
  end
  if rankSelectType == RankConfig.RankSelectEnum.like then
    if rankPeriodType == RankConfig.PeriodEnum.total then
      rank_item.score = rank_item.upvote
    else
      rank_item.score = rank_item.recent_upvote
    end
  end
  if rankSelectType == RankConfig.RankSelectEnum.arena then
    rank_item.score = rank_data.GetArenaScore(rank_item, selectZoneId)
  end
  if uid == DataMgr.roleData.uid and rankSelectType == RankConfig.RankSelectEnum.pve then
    rank_item.score = rank_item.pve_level
  end
  if uid == DataMgr.roleData.uid and rankSelectType == RankConfig.RankSelectEnum.charisma then
    rank_item.score = rank_item.charisma
  end
  if uid == DataMgr.roleData.uid and rankSelectType == RankConfig.RankSelectEnum.achievement then
    local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
    rank_item.score = 0
    if LobbySocialSystem.self_achievement_summary then
      rank_item.score = LobbySocialSystem.self_achievement_summary.achieve_score or 0
    end
  end
  if uid == DataMgr.roleData.uid and rankSelectType == RankConfig.RankSelectEnum.career then
    local CareerSystem = require("client.slua.logic.career.logic_career")
    rank_item.score = CareerSystem.GetMyCareerTotalPro() or 0
  end
  if uid == DataMgr.roleData.uid and rankSelectType == RankConfig.RankSelectEnum.peak then
    local LogicPeakGameSegmentUtil = require("client.logic.PeakGame.LogicPeakGameSegmentUtil")
    rank_item.score = LogicPeakGameSegmentUtil.GetSelfCurZonePeakGameRating() or 0
  end
  rank_data.SetSelfPeakGameRankScoreByProfile(uid, rank_item)
  if rankSelectType == RankConfig.RankSelectEnum.peakgame_kd then
    rank_item.score = string.format("%.2f", rank_item.score)
  else
    rank_item.score = rank_util.RankScoreRound(rank_item.score)
  end
  local TimeUtil = require("client.common.time_util")
  rank_item.profile_update_content_time = TimeUtil.GetServerTimeInSec()
end
function rank_data.SetSelfPeakGameRankScoreByProfile(uid, rank_item)
  log(bWriteLog and "rank_data.SetSelfPeakGameRankScoreByProfile")
  local rankSelectType = RankDataMgr.GetRankSelectType()
  local rankPeriodType = RankDataMgr.GetRankPeriodType()
  if tonumber(uid) == tonumber(DataMgr.roleData.uid) and rankSelectType == RankConfig.RankSelectEnum.peakgame_kd then
    local LogicPeakGameSegmentUtil = require("client.logic.PeakGame.LogicPeakGameSegmentUtil")
    local zone_id = RankDataMgr.GetRankSelectZoneId() or 1
    local kd_v2 = LogicPeakGameSegmentUtil.GetSelfPeakKDByZoneId(zone_id) or 0
    log(bWriteLog and "rank_data.SetSelfPeakGameRankScoreByProfile kd_v2 = " .. tostring(kd_v2))
    rank_item.score = kd_v2
  end
  if tonumber(uid) == tonumber(DataMgr.roleData.uid) and rankSelectType == RankConfig.RankSelectEnum.peakgame_win then
    local rankSelectMember = RankDataMgr.GetRankSelectMemberType()
    log(bWriteLog and "rank_data.SetSelfPeakGameRankScoreByProfile rankSelectMember = " .. tostring(rankSelectMember))
    local win_num = 0
    local LogicPeakGameSegmentUtil = require("client.logic.PeakGame.LogicPeakGameSegmentUtil")
    local zone_id = RankDataMgr.GetRankSelectZoneId() or 1
    if rankPeriodType == RankConfig.PeriodEnum.total then
      if rankSelectMember == RankConfig.MemberEnum.single then
        win_num = LogicPeakGameSegmentUtil.GetSelfPeakWinNum(zone_id, 1, "solo_win_num") or 0
      elseif rankSelectMember == RankConfig.MemberEnum.double then
        win_num = LogicPeakGameSegmentUtil.GetSelfPeakWinNum(zone_id, 1, "duo_win_num") or 0
      elseif rankSelectMember == RankConfig.MemberEnum.team then
        win_num = LogicPeakGameSegmentUtil.GetSelfPeakWinNum(zone_id, 1, "squad_win_num") or 0
      end
    elseif rankSelectMember == RankConfig.MemberEnum.single then
      win_num = LogicPeakGameSegmentUtil.GetSelfPeakWinNum(zone_id, 2, "solo_win_num") or 0
    elseif rankSelectMember == RankConfig.MemberEnum.double then
      win_num = LogicPeakGameSegmentUtil.GetSelfPeakWinNum(zone_id, 2, "duo_win_num") or 0
    elseif rankSelectMember == RankConfig.MemberEnum.team then
      win_num = LogicPeakGameSegmentUtil.GetSelfPeakWinNum(zone_id, 2, "squad_win_num") or 0
    end
    log(bWriteLog and "rank_data.SetSelfPeakGameRankScoreByProfile win_num = " .. tostring(win_num))
    rank_item.score = win_num
  end
end
function rank_data.SetSelfIntimacyRankUID(uid)
  selfIntimacyRankUID = uid
end
function rank_data.GetSelfIntimacyRankUID()
  return selfIntimacyRankUID
end
function rank_data.SortTotalRankList()
  log(bWriteLog and "rank_data.SortTotalRankList")
  local compFunc = function(a1, a2)
    return a1.no < a2.no
  end
  table.sort(rank_item_list, compFunc)
  rank_data.UpdateUidRankMap()
end
function rank_data.SortNormalFriendRankList()
  local rankSelectType = RankDataMgr.GetRankSelectType()
  if rankSelectType ~= RankConfig.RankSelectEnum.upass then
    if rankSelectType == RankConfig.RankSelectEnum.wow_play_level then
      local compFunc = function(a1, a2)
        local ALevel = a1.ext_data.ugc_play_level or 1
        local BLevel = a2.ext_data.ugc_play_level or 1
        local AExp = a1.ext_data.ugc_play_exp or 0
        local BExp = a2.ext_data.ugc_play_exp or 0
        if ALevel == BLevel then
          if AExp == BExp then
            return tonumber(a1.uid) > tonumber(a2.uid)
          end
          return AExp > BExp
        else
          return ALevel > BLevel
        end
      end
      table.sort(rank_item_list, compFunc)
    else
      local compFunc = function(a1, a2)
        if a1.score == a2.score then
          return tonumber(a1.uid) > tonumber(a2.uid)
        end
        return a1.score > a2.score
      end
      table.sort(rank_item_list, compFunc)
    end
  else
    local compFuncUpass = function(a1, a2)
      if a1.upass.level ~= a2.upass.level then
        return a1.upass.level > a2.upass.level
      elseif a1.upass.acc_score ~= a2.upass.acc_score then
        return a1.upass.acc_score > a2.upass.acc_score
      else
        return a1.upass.acc_update_time < a2.upass.acc_update_time
      end
    end
    table.sort(rank_item_list, compFuncUpass)
  end
  rank_data.UpdateUidRankMap()
end
function rank_data.SortFriendRankList()
  local compFunc = function(a1, a2)
    local score1 = tonumber(a1.score) or 0
    local score2 = tonumber(a2.score) or 0
    if score1 == score2 then
      return tonumber(a1.uid) > tonumber(a2.uid)
    end
    return score1 > score2
  end
  table.sort(rank_item_list, compFunc)
  rank_data.UpdateUidRankMap()
end
function rank_data.UpdateUidRankMap()
  for rank_index, rank_item in ipairs(rank_item_list) do
    uid_rank_map[tostring(rank_item.uid)] = rank_index
    rank_item.no = rank_index
  end
end
function rank_data.ClearRankData()
  log(bWriteLog and "[rank_data] ClearRankData")
  rank_item_list = {}
  uid_rank_map = {}
  rank_data.ResetSelfRankItem()
  rank_data.ResetContentCache()
end
function rank_data.ClearFriendRankCache()
  log(bWriteLog and "[rank_data] ClearFriendRankCache")
  friend_rank_map_cache = {}
  friend_rank_cache_zone_id = nil
end
function rank_data.IsFriendRankCacheValid(zone_id)
  if next(friend_rank_map_cache) == nil then
    return false
  end
  if friend_rank_cache_zone_id ~= zone_id then
    return false
  end
  return true
end
function rank_data.LoadFriendRankFromCache()
  rank_data.SetRankDataList(friend_rank_map_cache, rank_data_converter.ConvertNormalFriendRsp)
  rank_data.SortNormalFriendRankList()
end
function rank_data.SaveFriendRankToCache(zone_id, friend_rank_map)
  log(bWriteLog and "[rank_data] SaveFriendRankToCache zone_id = " .. tostring(zone_id))
  if friend_rank_cache_zone_id ~= zone_id then
    friend_rank_map_cache = {}
    friend_rank_cache_  end
  if not friend_rank_map_cache then
    friend_rank_map_cache = {}
  end
  for uid, rank_info in pairs(friend_rank_map) do
    friend_rank_map_cache[uid] = TableUtil.CopyTable(rank_info)
  end
end
function rank_data.ResetSelfRankItem()
  rank_data.ResetRankItemByUID(DataMgr.roleData.uid)
  if selfIntimacyRankUID then
    rank_data.ResetRankItemByUID(selfIntimacyRankUID)
    selfIntimacyRankUID = nil
  end
end
function rank_data.ResetRankItemByUID(uid)
  local self_rank_item = rank_item_map[tostring(uid)]
  if self_rank_item then
    self_rank_item.no = 0
    self_rank_item.score = 0
    self_rank_item.top1w = 0
    self_rank_item.ext_data = {}
    self_rank_item.profile_update_content_time = 0
    self_rank_item.gift_update_score_time = 0
    self_rank_item.planPH_update_score_time = 0
    self_rank_item.profile_request_time = 0
    self_rank_item.profile_update_time = 0
    self_rank_item.rank_data_update_time = 0
    self_rank_item.home_profile_request_time = 0
  end
end
function rank_data.ResetContentCache()
  for _, rank_item in pairs(rank_item_map) do
    rank_item.score = 0
    rank_item.content1 = "-"
    rank_item.content2 = "-"
    rank_item.content3 = "-"
  end
end
function rank_data.SetRankZoneData(rank_item, zone_id)
  if not rank_item.allzonerankdata then
    return
  end
  local zData = rank_item.allzonerankdata[zone_id]
  if rank_item.allzonerankdata[zone_id] then
    rank_data.SetClassicRankContent(zData, rank_item)
    rank_data.SetClassicScore(zData, rank_item)
  end
end
function rank_data.SetClassicRankContent(zData, rank_item)
  if not RankDataMgr.IsTpp() and not RankDataMgr.IsFpp() then
    return
  end
  local TimeUtil = require("client.common.time_util")
  local rankSelectMember = RankDataMgr.GetRankSelectMemberType()
  local rankSelectType = RankDataMgr.GetRankSelectType()
  local temp
  if RankDataMgr.IsTpp() then
    if rankSelectMember == RankConfig.MemberEnum.single then
      temp = zData.solo
    elseif rankSelectMember == RankConfig.MemberEnum.double then
      temp = zData.duo
    elseif rankSelectMember == RankConfig.MemberEnum.team then
      temp = zData.squad
    end
  elseif RankDataMgr.IsFpp() then
    if rankSelectMember == RankConfig.MemberEnum.single then
      temp = zData.fppsolo
    elseif rankSelectMember == RankConfig.MemberEnum.double then
      temp = zData.fppduo
    elseif rankSelectMember == RankConfig.MemberEnum.team then
      temp = zData.fppsquad
    end
  end
  if rankSelectType == RankConfig.RankSelectEnum.sum or rankSelectType == RankConfig.RankSelectEnum.fpp_sum then
    rank_item.content1 = temp == nil and "0" or TimeUtil.GetSurvivalTimeOfRank(temp.playtime)
    rank_item.content2 = temp == nil and "0" or tostring(rank_util.RankScoreRound(temp.win_rating))
    rank_item.content3 = temp == nil and "0" or tostring(rank_util.RankScoreRound(temp.kill_rating))
  elseif rankSelectType == RankConfig.RankSelectEnum.win or rankSelectType == RankConfig.RankSelectEnum.fpp_win then
    rank_item.content1 = temp == nil and "0" or tostring(temp.win_num)
    rank_item.content2 = temp == nil and "0" or tostring(temp.top10_count)
    rank_item.content3 = temp == nil and "0.00%" or string.format("%.2f%%", temp.win_ratio * 100)
  elseif rankSelectType == RankConfig.RankSelectEnum.beat or rankSelectType == RankConfig.RankSelectEnum.fpp_beat then
    rank_item.content1 = temp == nil and "0" or tostring(temp.kill_num)
    rank_item.content2 = temp == nil and "0" or tostring(temp.max_kill)
    rank_item.content3 = temp == nil and "0.00" or string.format("%.2f", temp.kd_v2 or temp.kd)
  elseif rankSelectType == RankConfig.RankSelectEnum.total then
    rank_item.content1 = zData.solo == nil and tostring(RankConfig.Const.C_DefaultScore) or tostring(rank_util.RankScoreRound(zData.solo.rank_rating))
    rank_item.content2 = zData.duo == nil and tostring(RankConfig.Const.C_DefaultScore) or tostring(rank_util.RankScoreRound(zData.duo.rank_rating))
    rank_item.content3 = zData.squad == nil and tostring(RankConfig.Const.C_DefaultScore) or tostring(rank_util.RankScoreRound(zData.squad.rank_rating))
  elseif rankSelectType == RankConfig.RankSelectEnum.fpp_total then
    rank_item.content1 = zData.fppsolo == nil and tostring(RankConfig.Const.C_DefaultScore) or tostring(rank_util.RankScoreRound(zData.fppsolo.rank_rating))
    rank_item.content2 = zData.fppduo == nil and tostring(RankConfig.Const.C_DefaultScore) or tostring(rank_util.RankScoreRound(zData.fppduo.rank_rating))
    rank_item.content3 = zData.fppsquad == nil and tostring(RankConfig.Const.C_DefaultScore) or tostring(rank_util.RankScoreRound(zData.fppsquad.rank_rating))
  end
end
function rank_data.SetClassicScore(zData, rank_item)
  if not RankDataMgr.IsTpp() and not RankDataMgr.IsFpp() then
    return
  end
  local rankSelectMember = RankDataMgr.GetRankSelectMemberType()
  local rankSelectType = RankDataMgr.GetRankSelectType()
  if rank_item.no == 0 and rank_item.score == 0 then
    if rankSelectType == RankConfig.RankSelectEnum.fpp_total then
      rank_item.score = zData.fpp_total_rank_rating or 0
    else
      rank_item.score = zData.total_rank_rating or 0
    end
    if rankSelectMember == RankConfig.MemberEnum.single then
      if rankSelectType == RankConfig.RankSelectEnum.sum then
        rank_item.score = zData.solo.rank_rating or 0
      elseif rankSelectType == RankConfig.RankSelectEnum.win then
        rank_item.score = zData.solo.win_rating or 0
      elseif rankSelectType == RankConfig.RankSelectEnum.beat then
        rank_item.score = zData.solo.kill_rating or 0
      elseif rankSelectType == RankConfig.RankSelectEnum.fpp_sum then
        rank_item.score = zData.fppsolo and zData.fppsolo.rank_rating or 0
      elseif rankSelectType == RankConfig.RankSelectEnum.fpp_win then
        rank_item.score = zData.fppsolo and zData.fppsolo.win_rating or 0
      elseif rankSelectType == RankConfig.RankSelectEnum.fpp_beat then
        rank_item.score = zData.fppsolo and zData.fppsolo.kill_rating or 0
      end
    elseif rankSelectMember == RankConfig.MemberEnum.double then
      if rankSelectType == RankConfig.RankSelectEnum.sum then
        rank_item.score = zData.duo.rank_rating or 0
      elseif rankSelectType == RankConfig.RankSelectEnum.win then
        rank_item.score = zData.duo.win_rating or 0
      elseif rankSelectType == RankConfig.RankSelectEnum.beat then
        rank_item.score = zData.duo.kill_rating or 0
      elseif rankSelectType == RankConfig.RankSelectEnum.fpp_sum then
        rank_item.score = zData.fppduo and zData.fppduo.rank_rating or 0
      elseif rankSelectType == RankConfig.RankSelectEnum.fpp_win then
        rank_item.score = zData.fppduo and zData.fppduo.win_rating or 0
      elseif rankSelectType == RankConfig.RankSelectEnum.fpp_beat then
        rank_item.score = zData.fppduo and zData.fppduo.fpp_kill_rating or 0
      end
    elseif rankSelectMember == RankConfig.MemberEnum.team then
      if rankSelectType == RankConfig.RankSelectEnum.sum then
        rank_item.score = zData.squad.rank_rating
      elseif rankSelectType == RankConfig.RankSelectEnum.win then
        rank_item.score = zData.squad.win_rating
      elseif rankSelectType == RankConfig.RankSelectEnum.beat then
        rank_item.score = zData.squad.kill_rating
      elseif rankSelectType == RankConfig.RankSelectEnum.fpp_sum then
        rank_item.score = zData.fppsquad and zData.fppsquad.rank_rating or 0
      elseif rankSelectType == RankConfig.RankSelectEnum.fpp_win then
        rank_item.score = zData.fppsquad and zData.fppsquad.win_rating or 0
      elseif rankSelectType == RankConfig.RankSelectEnum.fpp_beat then
        rank_item.score = zData.fppsquad and zData.fppsquad.kill_rating or 0
      end
    end
    rank_item.score = rank_util.RankScoreRound(rank_item.score)
  end
end
function rank_data.SetUpassData(rank_item)
  local TimeUtil = require("client.common.time_util")
  local rankSelectType = RankDataMgr.GetRankSelectType()
  if rankSelectType == RankConfig.RankSelectEnum.upass then
    if rank_item.upass.acc_update_time == 0 then
      rank_item.upass.level = 1
      rank_item.content3 = "0"
      rank_item.content1 = "-"
    else
      rank_item.content3 = tostring(rank_item.score)
      local currentTime = TimeUtil.FormatTime_YMD(rank_item.upass.acc_update_time)
      rank_item.content1 = tostring(currentTime)
      if tostring(rank_item.uid) == tostring(DataMgr.roleData.uid) then
        rank_item.content3 = tostring(rank_item.upass.acc_score)
      end
    end
  end
end
function rank_data.GetArenaScore(rank_item, zone_id)
  return rank_data.GetArenaRatingScoreOrSegment(rank_item, zone_id, "rank_rating")
end
function rank_data.GetArenaRatingScoreOrSegment(rank_item, zone_id, key)
  local temp = 0
  if rank_item and rank_item.arena_rating_and_segment and rank_item.arena_rating_and_segment[zone_id] and rank_item.arena_rating_and_segment[zone_id].vs_team then
    temp = rank_item.arena_rating_and_segment[zone_id].vs_team[key] or 0
  end
  return temp
end
function rank_data.GetSegmentAndSegmentTitle(rank_item, zone_id)
  local segmentTitleId
  local segment = RankConfig.Const.C_DefaultSegment
  local segmentModeId
  local segmentZoneId = zone_id
  local rankSelectType = RankDataMgr.GetRankSelectType()
  local cfg = RankConfig.RankInfoDiffConfig[rankSelectType]
  if cfg and cfg.SegmentType then
    if cfg.SegmentType == RankConfig.SegmentType.maxSegment then
      segment, segmentZoneId, segmentModeId = rank_data.GetMaxSegment(rank_item, zone_id)
      local logic_segment_title = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_segment_title)
      segmentTitleId = logic_segment_title:GetSegmentTitleId(rank_item.hsegment_title_det, segmentZoneId, segmentModeId)
    elseif cfg.SegmentType == RankConfig.SegmentType.classic then
      if rank_item.segment_info then
        segment, segmentTitleId, segmentModeId = rank_data.GetClassicSegmentAndSegTitle(rank_item.segment_info, rank_item.hsegment_title_det, zone_id)
      end
    elseif cfg.SegmentType == RankConfig.SegmentType.arenaSegment then
      segment = rank_data.GetArenaSegment(rank_item, zone_id)
    end
  end
  return segment, segmentTitleId, segmentModeId, segmentZoneId
end
function rank_data.GetMaxSegment(rank_item, zone_id)
  local segment = RankConfig.Const.C_DefaultSegment
  local maxSegZoneId = zone_id
  local maxSegModeId = 1
  if rank_item.all_segment_info then
    for zone, v in pairs(rank_item.all_segment_info) do
      for i, seg in pairs(v) do
        if seg > segment then
          segment = seg
          maxSegModeId = i
          maxSegZoneId = zone
        end
      end
    end
  end
  return segment, maxSegZoneId, maxSegModeId
end
function rank_data.GetClassicSegmentAndSegTitle(segment_info, segmentTitleData, zone_id)
  local segment = RankConfig.Const.C_DefaultSegment
  local segmentTitleId, segmentModeId
  local rankSelectMember = RankDataMgr.GetRankSelectMemberType()
  local rankSelectType = RankDataMgr.GetRankSelectType()
  if RankDataMgr.IsTpp() then
    if rankSelectMember == RankConfig.MemberEnum.single then
      segment = segment_info[1]
      segmentModeId = 1
    elseif rankSelectMember == RankConfig.MemberEnum.double then
      segment = segment_info[2]
      segmentModeId = 2
    elseif rankSelectMember == RankConfig.MemberEnum.team then
      segment = segment_info[3]
      segmentModeId = 3
    end
  elseif RankDataMgr.IsFpp() then
    if rankSelectMember == RankConfig.MemberEnum.single then
      segment = segment_info[4]
      segmentModeId = 4
    elseif rankSelectMember == RankConfig.MemberEnum.double then
      segment = segment_info[5]
      segmentModeId = 5
    elseif rankSelectMember == RankConfig.MemberEnum.team then
      segment = segment_info[6]
      segmentModeId = 6
    end
  end
  if rankSelectType == RankConfig.RankSelectEnum.total then
    if segment_info[1] ~= nil and segment_info[2] ~= nil and segment_info[3] ~= nil then
      segment = segment_info[1]
      segmentModeId = 1
      for i = 2, 3 do
        if segment < segment_info[i] then
          segment = segment_info[i]
          segmentModeId = i
        end
      end
    end
  elseif rankSelectType == RankConfig.RankSelectEnum.fpp_total and segment_info[4] ~= nil and segment_info[5] ~= nil and segment_info[6] ~= nil then
    segment = segment_info[4]
    segmentModeId = 4
    for i = 5, 6 do
      if segment < segment_info[i] then
        segment = segment_info[i]
        segmentModeId = i
      end
    end
  end
  local logic_segment_title = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_segment_title)
  segmentTitleId = logic_segment_title:GetSegmentTitleId(segmentTitleData, zone_id, segmentModeId)
  return segment, segmentTitleId, segmentModeId
end
function rank_data.GetArenaSegment(rank_item, zone_id)
  return rank_data.GetArenaRatingScoreOrSegment(rank_item, zone_id, "segment_id")
end
function rank_data.GetReqProfileList(indexFrom)
  local reqProfileUidList = {}
  local guardedProfileUidList = {}
  local reqIntimacyProfileUidList = {}
  local reqMateProfileUidList = {}
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  local pageIndex = math.modf(indexFrom / RankConfig.Const.C_OnePageCount)
  for i = pageIndex - 1, pageIndex + 1 do
    for j = 1, RankConfig.Const.C_OnePageCount do
      local rankIndex = i * RankConfig.Const.C_OnePageCount + j
      local rank_item = rank_item_list[rankIndex]
      if rank_item then
        local lastReqTime = rank_item.profile_request_time
        if lastReqTime == 0 or 30 < curTime - lastReqTime then
          rank_item.profile_request_time = curTime
          if rank_item.ext_data.uid_s and rank_item.ext_data.uid_l then
            table.insert(reqProfileUidList, tonumber(rank_item.ext_data.uid_s))
            if rank_item.intimacy_profile.uid == "" then
              table.insert(reqIntimacyProfileUidList, tonumber(rank_item.ext_data.uid_l))
            end
          else
            table.insert(reqProfileUidList, tonumber(rank_item.uid))
          end
          if rank_item.ext_data and rank_item.ext_data.receiver_uid and rank_item.guarded_profile.uid == "" then
            table.insert(guardedProfileUidList, tonumber(rank_item.ext_data.receiver_uid))
          end
          if rank_item.ext_data and rank_item.ext_data.mate_uid and rank_item.mate_profile.uid == "" then
            table.insert(reqMateProfileUidList, tonumber(rank_item.ext_data.mate_uid))
          end
        end
      end
    end
  end
  return reqProfileUidList, guardedProfileUidList, reqIntimacyProfileUidList, reqMateProfileUidList
end
function rank_data.GetReqHomeProfileList(indexFrom)
  log(bWriteLog and "rank_data.GetReqHomeProfileList indexFrom = " .. tostring(indexFrom))
  local bPlanPH = RankDataMgr.GetRankSelectType() == "planPH"
  if not bPlanPH then
    return {}
  end
  local rankRegionType = RankDataMgr.GetRankRegionType()
  if rankRegionType ~= RankConfig.RegionEnum.all then
    return {}
  end
  local minLimit = 20
  local middleLimit = 60
  local maxLimit = 100
  local reqStarSeq = 0
  local reqEndSeq = 0
  if indexFrom <= minLimit then
    reqStarSeq = 1
    reqEndSeq = minLimit
  elseif indexFrom <= middleLimit then
    reqStarSeq = minLimit + 1
    reqEndSeq = middleLimit
  else
    reqStarSeq = middleLimit + 1
    reqEndSeq = maxLimit
  end
  local reqHomeProfileUidList = {}
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  for rankIndex = reqStarSeq, reqEndSeq do
    local rank_item = rank_item_list[rankIndex]
    if rank_item then
      if not rank_item.home_profile_request_time or rank_item.home_profile_request_time == 0 then
        log(bWriteLog and "rank_data.GetReqHomeProfileList 1 uid = " .. tostring(rank_item.uid))
        rank_item.home_profile_request_time = curTime
        table.insert(reqHomeProfileUidList, tonumber(rank_item.uid))
      else
        local homeProfileLastReqTime = rank_item.home_profile_request_time
        local grow_info = rank_item.grow_info
        if 2 < curTime - homeProfileLastReqTime and not grow_info then
          log(bWriteLog and "rank_data.GetReqHomeProfileList 2 uid = " .. tostring(rank_item.uid))
          rank_item.home_profile_request_time = curTime
          table.insert(reqHomeProfileUidList, tonumber(rank_item.uid))
        end
      end
    end
  end
  return reqHomeProfileUidList
end
function rank_data.GetRankItemByUid(uid)
  local rankIndex = uid_rank_map[tostring(uid)]
  if rankIndex then
    return rank_item_list[rankIndex]
  end
  return nil
end
return rank_data