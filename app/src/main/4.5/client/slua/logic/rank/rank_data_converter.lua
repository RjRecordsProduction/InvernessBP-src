local RankDataMgr = require("client.slua.logic.rank.rank_data_mgr")
local RankConfig = require("client.slua.logic.rank.rank_config")
local rank_util = require("client.slua.logic.rank.rank_util")
local TimeUtil = require("client.common.time_util")
local rank_data_converter = {}
function rank_data_converter.ConvertTotalRankRsp(rank_item, raw_rank_data)
  rank_item.no = raw_rank_data.rank_no
  rank_item.score = raw_rank_data.score or 0
  rank_item.ext_data = raw_rank_data.ext_data or {}
  rank_item.rank_data_update_time = TimeUtil.GetServerTimeInSec()
end
function rank_data_converter.ConvertSelfRankRsp(rank_item, raw_rank_data)
  rank_item.no = raw_rank_data.rank_no or 0
  rank_item.top1w = raw_rank_data.top1w or 0
  if RankDataMgr.IsIntimacy() and raw_rank_data.ext_data and raw_rank_data.ext_data.uid_s then
    rank_item.score = raw_rank_data.score or 0
    rank_item.ext_data = raw_rank_data.ext_data
  end
  if 0 < rank_item.gift_update_score_time or 0 < rank_item.profile_update_content_time or 0 < rank_item.planPH_update_score_time then
    rank_item.rank_data_update_time = TimeUtil.GetServerTimeInSec()
    return
  end
  rank_item.score = raw_rank_data.score or 0
  rank_item.ext_data = raw_rank_data.ext_data or {}
  rank_item.rank_data_update_time = TimeUtil.GetServerTimeInSec()
end
function rank_data_converter.ConvertNormalFriendRsp(rank_item, raw_rank_data)
  local rankSelectMember = RankDataMgr.GetRankSelectMemberType()
  local rankSelectType = RankDataMgr.GetRankSelectType()
  local rankPeriodType = RankDataMgr.GetRankPeriodType()
  if rankSelectType == RankConfig.RankSelectEnum.fpp_total then
    rank_item.score = raw_rank_data.fpp_total_rank_rating
  else
    rank_item.score = raw_rank_data.total_rank_rating
  end
  rank_item.ext_data = raw_rank_data.ext_data or {}
  if rankSelectMember == RankConfig.MemberEnum.single then
    if rankSelectType == RankConfig.RankSelectEnum.sum then
      rank_item.score = raw_rank_data.solo_rank_rating
    elseif rankSelectType == RankConfig.RankSelectEnum.win then
      rank_item.score = raw_rank_data.solo_win_rating
    elseif rankSelectType == RankConfig.RankSelectEnum.beat then
      rank_item.score = raw_rank_data.solo_kill_rating
    end
    if rankSelectType == RankConfig.RankSelectEnum.fpp_sum then
      rank_item.score = raw_rank_data.fpp_solo_rank_rating
    elseif rankSelectType == RankConfig.RankSelectEnum.fpp_win then
      rank_item.score = raw_rank_data.fpp_solo_win_rating
    elseif rankSelectType == RankConfig.RankSelectEnum.fpp_beat then
      rank_item.score = raw_rank_data.fpp_solo_kill_rating
    end
  elseif rankSelectMember == RankConfig.MemberEnum.double then
    if rankSelectType == RankConfig.RankSelectEnum.sum then
      rank_item.score = raw_rank_data.duo_rank_rating
    elseif rankSelectType == RankConfig.RankSelectEnum.win then
      rank_item.score = raw_rank_data.duo_win_rating
    elseif rankSelectType == RankConfig.RankSelectEnum.beat then
      rank_item.score = raw_rank_data.duo_kill_rating
    end
    if rankSelectType == RankConfig.RankSelectEnum.fpp_sum then
      rank_item.score = raw_rank_data.fpp_duo_rank_rating
    elseif rankSelectType == RankConfig.RankSelectEnum.fpp_win then
      rank_item.score = raw_rank_data.fpp_duo_win_rating
    elseif rankSelectType == RankConfig.RankSelectEnum.fpp_beat then
      rank_item.score = raw_rank_data.fpp_duo_kill_rating
    end
  elseif rankSelectMember == RankConfig.MemberEnum.team then
    if rankSelectType == RankConfig.RankSelectEnum.sum then
      rank_item.score = raw_rank_data.squad_rank_rating
    elseif rankSelectType == RankConfig.RankSelectEnum.win then
      rank_item.score = raw_rank_data.squad_win_rating
    elseif rankSelectType == RankConfig.RankSelectEnum.beat then
      rank_item.score = raw_rank_data.squad_kill_rating
    end
    if rankSelectType == RankConfig.RankSelectEnum.fpp_sum then
      rank_item.score = raw_rank_data.fpp_squad_rank_rating
    elseif rankSelectType == RankConfig.RankSelectEnum.fpp_win then
      rank_item.score = raw_rank_data.fpp_squad_win_rating
    elseif rankSelectType == RankConfig.RankSelectEnum.fpp_beat then
      rank_item.score = raw_rank_data.fpp_squad_kill_rating
    end
  end
  if rankSelectType == RankConfig.RankSelectEnum.like then
    if rankPeriodType == RankConfig.RankSelectEnum.total then
      rank_item.score = raw_rank_data.upvote_rating or 0
    else
      rank_item.score = raw_rank_data.recent_upvote_rating or 0
    end
  end
  if rankSelectType == RankConfig.RankSelectEnum.charisma then
    rank_item.score = raw_rank_data.charisma_rating
  end
  if rankSelectType == RankConfig.RankSelectEnum.arena then
    rank_item.score = raw_rank_data.vs_team_rank_rating or 0
  end
  if rankSelectType == RankConfig.RankSelectEnum.career then
    rank_item.score = raw_rank_data.career_pro_rating or 0
  end
  if rankSelectType == RankConfig.RankSelectEnum.pve then
    rank_item.score = raw_rank_data.pve_level or 1
  end
  if rankSelectType == RankConfig.RankSelectEnum.upass then
    if raw_rank_data.upass then
      rank_item.score = raw_rank_data.upass.acc_score or 0
    else
      rank_item.score = 0
    end
  end
  if rankSelectType == RankConfig.RankSelectEnum.achievement then
    rank_item.score = raw_rank_data.achievement_score or 0
  end
  rank_item.score = RankDataMgr.TxmissionScoreFilter(raw_rank_data, rank_item.score)
  rank_item.upass.level = raw_rank_data.upass.level
  rank_item.upass.acc_score = raw_rank_data.upass.acc_score
  rank_item.upass.acc_update_time = raw_rank_data.upass.acc_update_time
  if rankSelectType == RankConfig.RankSelectEnum.fpp_sum then
    local win_rating = 0
    local kill_rating = 0
    if rankSelectMember == RankConfig.MemberEnum.single then
      win_rating = raw_rank_data.fpp_solo_win_rating
      kill_rating = raw_rank_data.fpp_solo_kill_rating
    elseif rankSelectMember == RankConfig.MemberEnum.double then
      win_rating = raw_rank_data.fpp_duo_win_rating
      kill_rating = raw_rank_data.fpp_duo_kill_rating
    elseif rankSelectMember == RankConfig.MemberEnum.team then
      win_rating = raw_rank_data.fpp_squad_win_rating
      kill_rating = raw_rank_data.fpp_squad_kill_rating
    end
    rank_item.content2 = rank_util.RankScoreRound(win_rating)
    rank_item.content3 = rank_util.RankScoreRound(kill_rating)
  end
  rank_item.ext_data.ugc_play_level = raw_rank_data.ugc_play_level
  rank_item.ext_data.ugc_play_exp = raw_rank_data.ugc_play_exp
  rank_item.rank_data_update_time = TimeUtil.GetServerTimeInSec()
  rank_item.solo_promo_rank_rating = raw_rank_data.solo_promo_rank_rating
  rank_item.solo_promo_win_rating = raw_rank_data.solo_promo_win_rating
  rank_item.solo_promo_kill_rating = raw_rank_data.solo_promo_kill_rating
  rank_item.duo_promo_rank_rating = raw_rank_data.duo_promo_rank_rating
  rank_item.duo_promo_win_rating = raw_rank_data.duo_promo_win_rating
  rank_item.duo_promo_kill_rating = raw_rank_data.duo_promo_kill_rating
  rank_item.squad_promo_rank_rating = raw_rank_data.squad_promo_rank_rating
  rank_item.squad_promo_win_rating = raw_rank_data.squad_promo_win_rating
  rank_item.squad_promo_kill_rating = raw_rank_data.squad_promo_kill_rating
  rank_item.fpp_solo_promo_rank_rating = raw_rank_data.fpp_solo_promo_rank_rating
  rank_item.fpp_solo_promo_win_rating = raw_rank_data.fpp_solo_promo_win_rating
  rank_item.fpp_solo_promo_kill_rating = raw_rank_data.fpp_solo_promo_kill_rating
  rank_item.fpp_duo_promo_rank_rating = raw_rank_data.fpp_duo_promo_rank_rating
  rank_item.fpp_duo_promo_win_rating = raw_rank_data.fpp_duo_promo_win_rating
  rank_item.fpp_duo_promo_kill_rating = raw_rank_data.fpp_duo_promo_kill_rating
  rank_item.fpp_squad_promo_rank_rating = raw_rank_data.fpp_squad_promo_rank_rating
  rank_item.fpp_squad_promo_win_rating = raw_rank_data.fpp_squad_promo_win_rating
  rank_item.fpp_squad_promo_kill_rating = raw_rank_data.fpp_squad_promo_kill_rating
end
function rank_data_converter.ConvertGiftFriendRsp(rank_item, raw_rank_data)
  local rankSelectType = RankDataMgr.GetRankSelectType()
  local rankPeriodType = RankDataMgr.GetRankPeriodType()
  rank_item.ext_data = raw_rank_data.ext_data or {}
  if rankSelectType == RankConfig.RankSelectEnum.popularity then
    if rankPeriodType == RankConfig.PeriodEnum.total then
      rank_item.score = raw_rank_data.total_devote or 0
    else
      rank_item.score = raw_rank_data.last_week_devote or 0
    end
  end
  if rankSelectType == RankConfig.RankSelectEnum.pround then
    if rankPeriodType == RankConfig.PeriodEnum.total then
      rank_item.score = raw_rank_data.total_pround or 0
    else
      rank_item.score = raw_rank_data.last_week_pround or 0
    end
  end
  if rankSelectType == RankConfig.RankSelectEnum.guardian then
    if rankPeriodType == RankConfig.PeriodEnum.total then
      rank_item.score = raw_rank_data.total_guardian or 0
      rank_item.ext_data.receiver_uid = raw_rank_data.total_guardian_receiver
    else
      rank_item.score = raw_rank_data.last_week_guardian or 0
      rank_item.ext_data.receiver_uid = raw_rank_data.last_week_guardian_receiver
    end
  end
  rank_item.rank_data_update_time = TimeUtil.GetServerTimeInSec()
end
function rank_data_converter.ConvertSelfGiftRsp(rank_item, raw_rank_data)
  rank_data_converter.ConvertGiftFriendRsp(rank_item, raw_rank_data)
  rank_item.gift_update_score_time = TimeUtil.GetServerTimeInSec()
end
function rank_data_converter.ConvertPeakFriendRsp(rank_item, raw_rank_data)
  log(bWriteLog and "rank_data_converter.ConvertPeakFriendRsp")
  local RankDataMgr = require("client.slua.logic.rank.rank_data_mgr")
  local rankSelectType = RankDataMgr.GetRankSelectType()
  local RankConfig = require("client.slua.logic.rank.rank_config")
  if rankSelectType ~= RankConfig.RankSelectEnum.peak and rankSelectType ~= RankConfig.RankSelectEnum.peakgame_kd then
    return
  end
  local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
  local data = raw_rank_data[PeakGameConfig.BattleType.Squad]
  if rankSelectType == RankConfig.RankSelectEnum.peak then
    rank_item.score = data and data.rating or 0
  elseif rankSelectType == RankConfig.RankSelectEnum.peakgame_kd then
    rank_item.score = data and data.kd_v2 or 0
  end
  rank_item.segment_id = data and data.segment_id or 0
end
function rank_data_converter.ConvertSelfRoleData(rank_item)
  rank_item.name = DataMgr.roleData.nickName
  rank_item.nation = DataMgr.roleData.nation
  rank_item.url = DataMgr.roleData.headIconUrl
  rank_item.level = DataMgr.roleData.level
  rank_item.gender = DataMgr.roleData.gender
  rank_item.cur_avatar_box_id = DataMgr.roleData.cur_avatar_box_id
  rank_item.startup_type = BP_StartUpType
  rank_item.friend_nickname_skin = DataMgr.roleData.friend_nickname_skin
  rank_item.pve_level = DataMgr.roleData.pve_level
  local SocialCardSystem = require("client.slua.logic.lobby.Left.logic_social_card")
  if SocialCardSystem.MySocialCard then
    rank_item.new_sex = SocialCardSystem.MySocialCard.new_sex or 0
  end
  rank_item.upass.level = DataMgr.roleData.upass.level
  rank_item.upass.acc_score = DataMgr.roleData.upass.acc_score
  rank_item.upass.acc_update_time = DataMgr.roleData.upass.acc_update_time
  rank_item.upass.is_buy = DataMgr.roleData.upass.is_buy
  rank_item.upass.keep_buy = DataMgr.roleData.upass.keep_buy or 0
  rank_item.upass.cur_value = DataMgr.roleData.upass.cur_value or 0
  rank_item.upass.pass_type = DataMgr.roleData.upass.pass_type or 0
  rank_item.alias.id = DataMgr.roleData.alias.id
  rank_item.alias.title = DataMgr.roleData.alias.title
  rank_item.alias.nation = DataMgr.roleData.alias.nation
  rank_item.alias.rank_id = DataMgr.roleData.alias.rank_id
  rank_item.total_popularity = DataMgr.roleData.total_devote or 0
  local pround_info = DataMgr.roleData.pround_info or {}
  rank_item.pround_info.level = pround_info.level
  rank_item.pround_info.exp = pround_info.exp
  rank_item.pround_info.is_visable = pround_info.is_visable
  rank_item.hsegment_title_det = DataMgr.roleData.allzoneSegmentTitle
  rank_item.auth_type = DataMgr.roleData.auth_type
  rank_item.auth_end_time = DataMgr.roleData.auth_end_time
  local ugc_author_info = DataMgr.ugc_author_info or {}
  rank_item.ext_data = rank_item.ext_data or {}
  rank_item.ext_data.level = ugc_author_info.new_level or 0
  rank_item.ext_data.level_exp = ugc_author_info.new_level_exp or 0
end
function rank_data_converter.ConvertIntimacyRankDataList(rankDataList)
  if not rankDataList then
    return nil
  end
  for _, v in pairs(rankDataList) do
    if tostring(DataMgr.roleData.uid) == tostring(v.ext_data.uid_l) then
      v.ext_data.uid_l = v.ext_data.uid_s
      v.ext_data.uid_s = DataMgr.roleData.uid
    end
  end
  return rankDataList
end
function rank_data_converter.ConvertSelfIntimacyRankInfo(rankInfo)
  if not rankInfo then
    return nil
  end
  if tostring(DataMgr.roleData.uid) == tostring(rankInfo.ext_data.uid_l) then
    rankInfo.ext_data.uid_l = rankInfo.ext_data.uid_s
    rankInfo.ext_data.uid_s = DataMgr.roleData.uid
  end
  return rankInfo
end
function rank_data_converter.ConvertJointRankDataList(rankDataList)
  if not rankDataList then
    return nil
  end
  for k, v in pairs(rankDataList) do
    if v.ext_data then
      rank_data_converter.ConvertJointRankData(v)
    end
  end
  return rankDataList
end
function rank_data_converter.ConvertJointRankData(rankData)
  if not rankData or not rankData.ext_data then
    return
  end
  if type(rankData.ext_data) == "string" then
    log(bWriteLog and "rank_data_converter.ConvertJointRankData decode ext_data")
    local decodeTable = slua.LuaArchiverDecode(LuaStateWrapper, rankData.ext_data)
    if type(decodeTable) == "table" then
      log_tree("rank_data_converter.ConvertJointRankData decodeTable=", decodeTable)
      rankData.ext_data = decodeTable
    end
  end
  if type(rankData.ext_data) ~= "table" then
    log(bWriteLog and "rank_data_converter.ConvertJointRankData ext_data is not a table: ", tostring(rankData.ext_data))
    return
  end
  if rankData.ext_data.members then
    log_tree("rank_data_converter.ConvertJointRankData rank data 1 =", rankData)
    if rankData.ext_data.members[2] == tonumber(DataMgr.roleData.uid) then
      rankData.uid = rankData.ext_data.members[2]
      rankData.ext_data.mate_uid = rankData.ext_data.members[1]
    else
      rankData.uid = rankData.ext_data.members[1]
      rankData.ext_data.mate_uid = rankData.ext_data.members[2]
    end
    log_tree("rank_data_converter.ConvertJointRankData rank data 2 =", rankData)
  end
end
function rank_data_converter.ConvertProfileRsp(rank_item, profile)
  rank_item.name = profile.nickName
  rank_item.nation = profile.nation
  rank_item.city = profile.city
  rank_item.url = profile.picUrl
  rank_item.level = profile.level
  rank_item.gender = profile.sex
  rank_item.cur_avatar_box_id = profile.cur_avatar_box_id
  rank_item.startup_type = profile.startup_type
  rank_item.friend_nickname_skin = profile.friend_nickname_skin
  if profile.social_card then
    rank_item.new_sex = profile.social_card.new_sex or 0
  end
  rank_item.auth_type = profile.auth_type
  rank_item.auth_end_time = profile.auth_end_time
  rank_item.arena_rating_and_segment = profile.arena_rating_and_segment
  rank_item.upvote = profile.upvote or 0
  rank_item.recent_upvote = profile.recent_upvote or 0
  rank_item.charisma = profile.charisma or 0
  rank_item.pve_level = profile.pve_level or 1
  rank_item.upass.level = profile.upass.level
  rank_item.upass.acc_score = profile.upass.acc_score
  rank_item.upass.acc_update_time = profile.upass.acc_update_time
  rank_item.upass.uishow = profile.upass.switch.ui
  rank_item.upass.is_buy = profile.upass.is_buy
  rank_item.upass.keep_buy = profile.upass.keep_buy or 0
  rank_item.upass.cur_value = profile.upass.cur_value or 0
  rank_item.upass.pass_type = profile.upass.pass_type or 0
  rank_item.alias.id = profile.alias.id
  rank_item.alias.title = profile.alias.title
  rank_item.alias.nation = profile.alias.nation
  rank_item.alias.rank_id = profile.alias.rank_id
  rank_item.total_popularity = profile.total_devote or 0
  if profile.pround_info then
    rank_item.pround_info.level = profile.pround_info.level or 0
    rank_item.pround_info.exp = profile.pround_info.exp or 0
    rank_item.pround_info.is_visable = profile.pround_info.is_visable
  end
  if type(profile.platName) == "string" and profile.platName ~= "" then
    rank_item.plat_name = profile.platName
  else
    rank_item.plat_name = ""
  end
  if profile.remarks_name ~= "" then
    rank_item.plat_name = profile.remarks_name
  end
  rank_item.allzonerankdata = profile.rankdata
  local rankSelectZoneId = RankDataMgr.GetRankSelectZoneId()
  if type(profile.rankdata) == "table" and profile.rankdata[rankSelectZoneId] ~= nil then
    local TableUtil = require("common.table_util")
    rank_item.rankdata = TableUtil.CopyTable(profile.rankdata[rankSelectZoneId])
  end
  rank_item.all_segment_info = profile.segment_info
  rank_item.hsegment_title_det = profile.hsegment_title_det
  if rank_item.all_segment_info and rank_item.all_segment_info[rankSelectZoneId] ~= nil then
    for id, _ in ipairs(rank_item.segment_info) do
      rank_item.segment_info[id] = rank_item.all_segment_info[rankSelectZoneId][id]
    end
  end
  rank_item.metro_summary = profile.metro_summary
  rank_item.light_board_info = profile.light_board_info
  rank_item.collect_data = profile.collect_data
  rank_item.ext_data = rank_item.ext_data or {}
  if type(rank_item.ext_data) ~= "table" then
    rank_item.ext_data = {}
  end
  rank_item.ext_data.ugc_play_level = profile.ugc_play_level
  rank_item.ext_data.ugc_play_exp = profile.ugc_play_exp
  local ugc_author_info = profile.ugc_author_info or {}
  rank_item.ext_data.level = ugc_author_info.new_level or 0
  rank_item.ext_data.level_exp = ugc_author_info.new_level_exp or 0
  rank_item.profile_update_time = TimeUtil.GetServerTimeInSec()
end
function rank_data_converter.ConvertGuardedProfileRsp(rank_item, guarded_profile)
  rank_item.guarded_profile.uid = guarded_profile.uid
  rank_item.guarded_profile.url = guarded_profile.picUrl
  rank_item.guarded_profile.name = guarded_profile.nickName
  rank_item.guarded_profile.gender = guarded_profile.gender
  rank_item.guarded_profile.cur_avatar_box_id = guarded_profile.cur_avatar_box_id
  rank_item.guarded_profile.level = guarded_profile.level
  rank_item.guarded_profile.friend_nickname_skin = guarded_profile.friend_nickname_skin
  rank_item.guarded_profile.collect_data = guarded_profile.collect_data
end
function rank_data_converter.ConvertIntimacyProfileRsp(rank_item, intimacy_profile)
  rank_item.intimacy_profile.uid = intimacy_profile.uid
  rank_item.intimacy_profile.url = intimacy_profile.picUrl
  rank_item.intimacy_profile.name = intimacy_profile.nickName
  rank_item.intimacy_profile.gender = intimacy_profile.gender
  rank_item.intimacy_profile.cur_avatar_box_id = intimacy_profile.cur_avatar_box_id
  rank_item.intimacy_profile.level = intimacy_profile.level
  rank_item.intimacy_profile.friend_nickname_skin = intimacy_profile.friend_nickname_skin
  rank_item.intimacy_profile.collect_data = intimacy_profile.collect_data
end
function rank_data_converter.ConvertMateProfileRsp(rank_item, mate_profile)
  rank_item.mate_profile.uid = mate_profile.uid
  rank_item.mate_profile.url = mate_profile.picUrl
  rank_item.mate_profile.name = mate_profile.nickName
  rank_item.mate_profile.gender = mate_profile.gender
  rank_item.mate_profile.cur_avatar_box_id = mate_profile.cur_avatar_box_id
  rank_item.mate_profile.level = mate_profile.level
  rank_item.mate_profile.friend_nickname_skin = mate_profile.friend_nickname_skin
  rank_item.mate_profile.collect_data = mate_profile.collect_data
end
function rank_data_converter.ConvertWoWAuthorProfileRsp(rank_item, author_profile)
  rank_item.ext_data.level = author_profile.new_level
  rank_item.ext_data.level_exp = author_profile.new_level_exp
end
function rank_data_converter.ConvertWoWPlayProfileRsp(rank_item, play_profile)
  rank_item.ext_data.ugc_play_level = play_profile.ugc_play_level
  rank_item.ext_data.ugc_play_exp = play_profile.ugc_play_exp
end
function rank_data_converter.ConvertWoWModProfileRsp(rank_item, mod_profile)
  rank_item.score = mod_profile.total_play_total_time or 0
end
return rank_data_converter