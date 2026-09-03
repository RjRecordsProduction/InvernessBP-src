local RankConfig = require("client.slua.logic.rank.rank_config")
local rank_data = require("client.slua.logic.rank.rank_data")
local rank_data_converter = require("client.slua.logic.rank.rank_data_converter")
local RankDataMgr = require("client.slua.logic.rank.rank_data_mgr")
local rank_util = require("client.slua.logic.rank.rank_util")
local rank_ctrl = {}
function rank_ctrl.GetRankDataReq(zone_id)
  log(bWriteLog and "[rank_ctrl] GetRankDataReq: " .. tostring(zone_id))
  if zone_id == nil then
    zone_id = RankDataMgr.GetRankSelectZoneId()
  end
  local rankRegionType = RankDataMgr.GetRankRegionType()
  if rankRegionType == RankConfig.RegionEnum.all or RankDataMgr.IsIntimacy() then
    rank_ctrl.GetTotalRankReq(zone_id)
    log(bWriteLog and "[rank_ctrl] GetRankDataReq: rankRegionType == RankConfig.RegionEnum.all")
  else
    log(bWriteLog and "[rank_ctrl] GetRankDataReq: rankRegionType != RankConfig.RegionEnum.all")
    local rankSelectType = RankDataMgr.GetRankSelectType()
    if rankSelectType == RankConfig.RankSelectEnum.wow_author then
      rank_ctrl.GetTotalRankReq(zone_id)
      return
    end
    rank_ctrl.GetFriendRankReq(zone_id)
  end
end
function rank_ctrl.GetTotalRankReq(zone_id)
  log(bWriteLog and "[rank_ctrl] GetTotalRankReq: " .. tostring(zone_id))
  local RankHandler = require("client.network.Protocol.RankHandler")
  rank_data.ClearRankData()
  local rankSelectType = RankDataMgr.GetRankSelectType()
  if not RankDataMgr.IsClassicRanking() and not RankDataMgr.IsPeakGameRanking() and not RankDataMgr.IsArenaRanking() and not RankDataMgr.IsWeaponUsageScoreRanking() then
    zone_id = 0
  end
  local rankPeriodType = RankDataMgr.GetRankPeriodType()
  local rankSelectMember = RankDataMgr.GetRankSelectMemberType()
  local planPHType = RankDataMgr.GetPlanPHType()
  local WoWAuthorType = RankDataMgr.GetWoWAuthorType()
  local SubSelectType = rankSelectType == RankConfig.RankSelectEnum.wow_author and WoWAuthorType or planPHType
  local rankRequireID = RankDataMgr.GetRankRequireID(rankSelectType, rankSelectMember, rankPeriodType, SubSelectType)
  log(bWriteLog and "[PXY]RankHandler.send_get_one_user_rank  -|" .. tostring(rankSelectType) .. "|-   rankPeriodType   -|" .. rankPeriodType .. "|-  rankSelectMember   -|" .. rankSelectMember)
  if rankSelectType == RankConfig.RankSelectEnum.weapon_usage_score then
    if RankDataMgr.GetLBSMode() then
      zone_id = RankDataMgr.GetCountryID()
    elseif zone_id == 0 then
      local WeaponStrength_Config = require("client.slua.umg.Season_WeaponStrength.WeaponStrength_Config")
      zone_id = WeaponStrength_Config.WeaponRankHonorRegion.Global
    end
    local weapon_rank_id = RankDataMgr.GetWeaponRankID()
    local logic_weapon_strength_rank = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_weapon_strength_rank)
    logic_weapon_strength_rank:send_get_weapon_power_rank_req(zone_id, weapon_rank_id, {from = "rank_ctrl"})
  else
    if rankRequireID == 0 then
      return
    end
    RankHandler.send_get_topn_rank(zone_id, rankRequireID, nil, {
      reqFromType = RankConfig.ReqFromType.lobbyRank
    })
  end
  if rankSelectType == RankConfig.RankSelectEnum.arena then
    zone_id = RankDataMgr.GetRankSelectZoneId()
    RankHandler.send_get_one_user_rank("arena", zone_id, 0, rankRequireID)
    local ArenaSystem = require("client.slua.logic.arena.logic_arena")
    ArenaSystem.SendGetArenaSeasonRecordReq(zone_id)
  elseif rankSelectType == RankConfig.RankSelectEnum.popularity or rankSelectType == RankConfig.RankSelectEnum.pround or rankSelectType == RankConfig.RankSelectEnum.guardian then
    RankHandler.send_get_one_user_rank("rank", zone_id, 0, rankRequireID)
    RankHandler.send_batch_get_popularit_summary_req({
      tonumber(DataMgr.roleData.uid)
    }, RankConfig.PopularityReqType.selfReq)
  elseif rankSelectType == RankConfig.RankSelectEnum.planPH then
    local logic_home_joint = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_joint)
    local rankUID = 0
    local jointInfo = logic_home_joint:GetHomeJointInfo()
    if jointInfo and jointInfo.joint_id then
      rankUID = jointInfo.joint_id
    end
    RankHandler.send_get_one_user_rank("rank", zone_id, rankUID, rankRequireID)
    local logic_home_profile = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_profile)
    local callback = function()
      local logic_home_rank = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_rank)
      logic_home_rank:GetPlanPHSelfRank()
    end
    logic_home_profile:GetOrReqHomeProfile({
      DataMgr.roleData.uid
    }, callback, true)
  elseif RankDataMgr.IsIntimacy() then
    local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
    local rankUIDList = LogicFriend.GetIntimacyRankUIDList()
    if 0 < #rankUIDList then
      RankHandler.send_get_special_user_rank(RankConfig.RankSelectEnum.intimacy, zone_id, rankUIDList, rankRequireID, {all_self = true})
    else
      rank_ctrl.ParseSpecialUserRank(0, RankConfig.RankSelectEnum.intimacy, {})
    end
  elseif rankSelectType == RankConfig.RankSelectEnum.wow_author then
    RankHandler.send_get_one_user_rank("rank", zone_id, 0, rankRequireID)
    if WoWAuthorType == RankConfig.WoWAuthorEnum.level then
      local LogicUGCAuthor = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthor)
      LogicUGCAuthor:RequestAuthorInfo(tonumber(DataMgr.roleData.uid))
    elseif WoWAuthorType == RankConfig.WoWAuthorEnum.popularity and rankPeriodType == RankConfig.PeriodEnum.total then
      local UGCAuthorHandler = require("client.network.Protocol.UGCAuthorHandler")
      UGCAuthorHandler.send_ugc_author_summary_req(DataMgr.roleData.uid)
    end
  elseif rankSelectType == RankConfig.RankSelectEnum.wow_play_level then
    RankHandler.send_get_one_user_rank("rank", zone_id, 0, rankRequireID)
    local UGCAuthorHandler = require("client.network.Protocol.UGCAuthorHandler")
    UGCAuthorHandler.send_ugc_play_level_get_award_info_req()
  elseif rankSelectType == RankConfig.RankSelectEnum.weapon_usage_score then
    if zone_id == 0 then
      local WeaponStrength_Config = require("client.slua.umg.Season_WeaponStrength.WeaponStrength_Config")
      zone_id = WeaponStrength_Config.WeaponRankHonorRegion.Global
    end
    local weapon_rank_id = RankDataMgr.GetWeaponRankID()
    local WeaponStrengthHandler = require("client.network.Protocol.WeaponStrengthHandler")
    WeaponStrengthHandler.send_get_on_user_weapon_power_rank_req(tonumber(DataMgr.roleData.uid), zone_id, weapon_rank_id, {from = "rank_ctrl"})
  else
    RankHandler.send_get_one_user_rank("rank", zone_id, 0, rankRequireID)
    log(bWriteLog and "[PXY]RankHandler.send_get_one_user_rank" .. tostring(zone_id) .. "rankRequireID" .. rankRequireID)
  end
end
function rank_ctrl.GetTopNRankRsp(res, zone_id, rank_requird_id, rank_data_list, page, extra_data)
  log(bWriteLog and "[rank_ctrl] GetTopNRankRsp: " .. tostring(zone_id))
  log_tree(bWriteLog and "rank_ctrl.GetTopNRankRsp extra_data", extra_data)
  local LogicCorps = require("client.slua.logic.corps.logic_corps")
  if LogicCorps.IsCorpsRank(rank_requird_id) then
    local NewCorpsRankSystem = require("client.slua.logic.corps.logic_corps_rank")
    NewCorpsRankSystem.OnGetRankData(res, rank_requird_id, rank_data_list)
    return
  end
  local BlackFridayRankModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.BlackFridayRankModule)
  if BlackFridayRankModule:IsBlackFridayRank(rank_requird_id) then
    BlackFridayRankModule:HandleTopNRankResponse(res, rank_data_list)
    return
  end
  local logic_rank_ice = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_rank_ice)
  if logic_rank_ice:IsCharmValueRank(rank_requird_id) then
    logic_rank_ice:GetRankListRsp(res, rank_data_list, page)
    return
  end
  local collect_rank_season_module = ModuleManager.GetSplitModuleDownload(ModuleManager.LobbyModuleConfig.collect_rank_season_module)
  if collect_rank_season_module and collect_rank_season_module:IsCharmValueRank(rank_requird_id) then
    collect_rank_season_module:RankListRsp(res, rank_data_list, page)
  end
  local CollectLikeRankModule = ModuleManager.GetSplitModuleDownload(ModuleManager.LobbyModuleConfig.CollectLikeRankModule)
  if CollectLikeRankModule and CollectLikeRankModule:IsCharmValueRank(rank_requird_id) then
    CollectLikeRankModule:RankListRsp(res, rank_data_list, page)
  end
  local collect_rank_total_module = ModuleManager.GetSplitModuleDownload(ModuleManager.LobbyModuleConfig.collect_rank_total_module)
  if collect_rank_total_module and collect_rank_total_module:IsCharmValueRank(rank_requird_id) then
    collect_rank_total_module:RankListRsp(res, rank_data_list, page)
  end
  local logic_rank_collection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_rank_collection)
  if logic_rank_collection:IsCharmValueRank(rank_requird_id) then
    logic_rank_collection:GetRankListRsp(res, rank_data_list, page)
    return
  end
  local logic_popular_gift_pk = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_gift_pk)
  if logic_popular_gift_pk:IsPopularityPKRank(rank_requird_id) then
    logic_popular_gift_pk:proc_get_topn_rank_rsp(res, rank_data_list)
    return
  end
  local peakgame_hall_tool = require("client.logic.PeakGame.Tool.peakgame_hall_tool")
  local LogicPeakGameHall = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGameHall)
  if peakgame_hall_tool.IsWeeklyRank(rank_requird_id, extra_data) then
    LogicPeakGameHall:OnGetTopnRankRsp(res, zone_id, rank_requird_id, rank_data_list, extra_data)
    return
  end
  if peakgame_hall_tool.CheckAbilityRank(rank_requird_id, extra_data) then
    LogicPeakGameHall:OnGetAbilityTopnRankRsp(res, zone_id, rank_requird_id, rank_data_list, extra_data)
    return
  end
  local logic_popular_team_pk = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_team_pk)
  if logic_popular_team_pk:IsPopularityTeamPKRank(rank_requird_id) then
    logic_popular_team_pk:proc_get_topn_rank_rsp(res, rank_data_list)
    return
  end
  local logic_popular_home_pk = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_home_pk)
  if logic_popular_home_pk:IsHomePKSeasonRank(rank_requird_id) then
    logic_popular_home_pk:ProcSeasonRankRsp(res, rank_data_list)
    return
  end
  local logic_popular_home_pk = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_home_pk)
  if logic_popular_home_pk:IsHomePKSquareRank(rank_requird_id) then
    logic_popular_home_pk:ProcSquareRank(res, rank_data_list)
    return
  end
  if logic_popular_home_pk:IsHomePKStyleRank(rank_requird_id) then
    logic_popular_home_pk:ProcStyleRank(res, rank_data_list)
    return
  end
  local logic_home_list_view = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_list_view)
  if logic_home_list_view:IsPHomeRank(rank_requird_id) and extra_data and extra_data.reqFromType == RankConfig.ReqFromType.modeSelection then
    logic_home_list_view:proc_get_topn_rank_rsp(res, rank_requird_id, rank_data_list)
    return
  end
  local logic_home_collection_rank = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_collection_rank)
  if logic_home_list_view:IsPHomeRank(rank_requird_id) and extra_data and extra_data.reqFromType == RankConfig.ReqFromType.homeCollectionRank then
    logic_home_collection_rank:proc_get_topn_rank_rsp(res, rank_requird_id, rank_data_list)
    return
  end
  local logicSnowMan = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicSnowMan)
  if logicSnowMan:IsSnowManRankData(rank_requird_id) then
    rank_data_list = rank_data_converter.ConvertJointRankDataList(rank_data_list)
    logicSnowMan:ProcSnowManRankRsp(res, rank_requird_id, rank_data_list)
    return
  end
  local logic_home_car_parking_rank = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_car_parking_rank)
  if logic_home_car_parking_rank:IsCarParkingRank(rank_requird_id) then
    logic_home_car_parking_rank:proc_get_topn_rank_rsp(res, rank_requird_id, rank_data_converter.ConvertJointRankDataList(rank_data_list))
    return
  end
  local logic_popular_pk_fun_awards = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_pk_fun_awards)
  if logic_popular_pk_fun_awards:IsPopularPKFunAwardsRank(rank_requird_id) then
    logic_popular_pk_fun_awards:proc_get_topn_rank_rsp(res, rank_requird_id, rank_data_list)
    return
  end
  local rankSelectType = RankDataMgr.GetRankSelectType()
  if res ~= 0 then
    log(bWriteLog and "[rank_ctrl] GetTopNRankRsp failed: " .. tostring(res))
    EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_RANK_UPDATE_LIST, rankSelectType)
    if rankSelectType == RankConfig.RankSelectEnum.upass then
      EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_RANK_UPDATE_LIST, rankSelectType)
    end
    return
  end
  local rank_require_config = RankConfig.RankRequireConfig[rank_requird_id]
  if not rank_require_config then
    log(bWriteLog and "[rank_ctrl] nil rank_require_config: " .. tostring(rank_requird_id))
    return
  end
  local curSelect = rank_require_config.rank_type
  log_format(bWriteLog and "[rank_ctrl] GetTopNRankRsp curSelect %s\239\188\140 rankSelectType %s ", curSelect, rankSelectType)
  if curSelect ~= rankSelectType then
    log_format(bWriteLog and "[rank_ctrl] GetTopNRankRsp curSelect ~= rankSelectType ")
    return
  end
  if RankDataMgr.IsIntimacyRankID(rank_requird_id) then
    rank_data_list = rank_data_converter.ConvertIntimacyRankDataList(rank_data_list)
  end
  if logic_home_list_view:IsPHomeRank(rank_requird_id) then
    rank_data_list = rank_data_converter.ConvertJointRankDataList(rank_data_list)
  end
  RankDataMgr.SetRankRegionType(RankConfig.RegionEnum.all)
  RankDataMgr.SetRankSelectMemberType(rank_require_config.member_type)
  RankDataMgr.SetRankPeriodType(rank_require_config.period_type or RankConfig.PeriodEnum.total)
  if rank_require_config.rank_type == RankConfig.RankSelectEnum.wow_author then
    RankDataMgr.SetWoWAuthorType(rank_require_config.planPH_type)
  else
    RankDataMgr.SetPlanPHType(rank_require_config.planPH_type)
  end
  if rank_requird_id == RankConfig.ScoreType.peakgame_kd_rating then
    for raw_index, raw_rank_data in pairs(rank_data_list or {}) do
      if raw_rank_data.score then
        raw_rank_data.score = raw_rank_data.score / 100
      end
    end
    log_tree(bWriteLog and "rank_ctrl.GetTopNRankRsp rank_data_list = ", rank_data_list)
  end
  rank_data.SetRankDataList(rank_data_list, rank_data_converter.ConvertTotalRankRsp)
  rank_data.SortTotalRankList()
  EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_RANK_UPDATE_LIST, rank_require_config.rank_type)
  if rankSelectType == RankConfig.RankSelectEnum.upass then
    EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_RANK_UPDATE_LIST, rank_require_config.rank_type)
  end
end
function rank_ctrl.GetOneUserRankRsp(rank_source, res, zone_id, rank_info, extra_data)
  log(bWriteLog and "[rank_ctrl] GetOneUserRankRsp: " .. tostring(zone_id))
  rank_ctrl.ParseOneUserRankRsp(rank_source, res, zone_id, rank_info)
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  RoleInfoSystem.get_role_rank_info_rsp(rank_source, res, zone_id, rank_info)
  local SeasonSystem = require("client.logic.season.logic_season")
  SeasonSystem.get_one_user_rank_rsp(rank_source, res, zone_id, rank_info)
  local NewCorpsRankSystem = require("client.slua.logic.corps.logic_corps_rank")
  NewCorpsRankSystem.OnGetMyRankInfoData(rank_source, res, zone_id, rank_info)
  BattleResultUI.get_one_user_rank_rsp(rank_source, res, zone_id, rank_info)
  local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
  RoleInfoPopularitySystem.get_one_user_rank_rsp(rank_source, res, zone_id, rank_info)
  local ArenaSystem = require("client.slua.logic.arena.logic_arena")
  ArenaSystem.OnGetOneUserRankRsp(rank_source, res, zone_id, rank_info)
  local SingleTrainingHandler = require("client.network.Protocol.SingleTrainingHandler")
  SingleTrainingHandler.OnGetOneUserRankRsp(rank_source, res, zone_id, rank_info)
  local BlackFridayRankModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.BlackFridayRankModule)
  BlackFridayRankModule:HandleOneUserRankResponse(rank_source, res, rank_info)
  local logic_achievement = require("client.slua.logic.achievement.logic_achievement")
  logic_achievement.SavePKInfo(rank_source, res, rank_info)
  local logic_popular_gift_pk = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_gift_pk)
  logic_popular_gift_pk:on_get_one_user_rank_rsp(rank_source, res, rank_info)
  local logic_popular_team_pk = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_team_pk)
  logic_popular_team_pk:on_get_one_user_rank_rsp(rank_source, res, rank_info)
  local logic_popular_home_pk = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_home_pk)
  logic_popular_home_pk:ProcSelfSeasonRankRsp(rank_source, res, rank_info)
  logic_popular_home_pk:ProcSelfStyleRankRsp(rank_source, res, rank_info)
  local logic_rank_ice = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_rank_ice)
  logic_rank_ice:GetSelfRankRsp(rank_source, res, rank_info)
  local logic_rank_collection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_rank_collection)
  logic_rank_collection:GetSelfRankRsp(rank_source, res, rank_info)
  local logic_home_collection_rank = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_collection_rank)
  logic_home_collection_rank:on_get_one_user_rank_rsp(rank_source, res, rank_info)
  local collect_rank_total_module = ModuleManager.GetSplitModuleDownload(ModuleManager.LobbyModuleConfig.collect_rank_total_module)
  if collect_rank_total_module then
    collect_rank_total_module:SelfRankRsp(rank_source, res, rank_info)
  end
  local collect_rank_season_module = ModuleManager.GetSplitModuleDownload(ModuleManager.LobbyModuleConfig.collect_rank_season_module)
  if collect_rank_season_module then
    collect_rank_season_module:SelfRankRsp(rank_source, res, rank_info)
  end
  local CollectLikeRankModule = ModuleManager.GetSplitModuleDownload(ModuleManager.LobbyModuleConfig.CollectLikeRankModule)
  if CollectLikeRankModule then
    CollectLikeRankModule:SelfRankRsp(rank_source, res, rank_info)
  end
  local LogicSnowMan = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicSnowMan)
  LogicSnowMan:ProcSelfSnowManRankRsp(rank_source, res, rank_info)
  local Logic_UGC_AuthorHome = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_authorhome)
  Logic_UGC_AuthorHome:UGCCreatorRankRsp(rank_source, res, rank_info)
  local logic_home_car_parking_rank = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_car_parking_rank)
  logic_home_car_parking_rank:proc_get_one_user_rank(rank_source, res, rank_info)
  local logic_popular_pk_fun_awards = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_pk_fun_awards)
  logic_popular_pk_fun_awards:proc_get_one_user_rank(rank_source, res, rank_info)
end
function rank_ctrl.ParseOneUserRankRsp(rank_source, res, zone_id, rank_info)
  log(bWriteLog and "[rank_ctrl] ParseOneUserRankRsp")
  if rank_source ~= "rank" then
    return
  end
  if res ~= 0 then
    log(bWriteLog and "[rank_ctrl] get self rank data failed: " .. tostring(res))
    return
  end
  local rankSelectType = RankDataMgr.GetRankSelectType()
  if rankSelectType == RankConfig.RankSelectEnum.planPH and rank_info.ext_data then
    rank_info.ext_data = slua.LuaArchiverDecode(LuaStateWrapper, rank_info.ext_data)
    if rank_info.ext_data.members then
      if rank_info.ext_data.members[2] == tonumber(DataMgr.roleData.uid) then
        rank_info.uid = rank_info.ext_data.members[2]
        rank_info.ext_data.mate_uid = rank_info.ext_data.members[1]
      else
        rank_info.uid = rank_info.ext_data.members[1]
        rank_info.ext_data.mate_uid = rank_info.ext_data.members[2]
      end
    end
  end
  zone_id = zone_id or 0
  if rankSelectType == RankConfig.RankSelectEnum.weapon_usage_score then
    local WeaponStrength_Config = require("client.slua.umg.Season_WeaponStrength.WeaponStrength_Config")
    if zone_id == WeaponStrength_Config.WeaponRankHonorRegion.Global then
      zone_id = 0
    end
  end
  if rankSelectType == RankConfig.RankSelectEnum.peakgame_kd then
    if rank_info.score then
      rank_info.score = rank_info.score / 100
    end
    log_tree(bWriteLog and "rank_ctrl.ParseOneUserRankRsp rank_info = ", rank_info)
  end
  rank_data.SetSelfRankData(rank_info, rank_data_converter.ConvertSelfRankRsp)
  rank_data.SetItemContentByProfile(DataMgr.roleData.uid)
  local self_rank_data = rank_data.GetSelfRankData()
  if RankDataMgr.IsTpp() or RankDataMgr.IsFpp() then
    local rankInspectSystem = require("client.slua.logic.rank.logic_rank_inspect")
    rankInspectSystem.CheckPopWhenOpenRank(self_rank_data.no)
  end
  local score = self_rank_data.score
  if rankSelectType == RankConfig.RankSelectEnum.upass then
    score = DataMgr.roleData.upass.acc_score
    local UnknowPassRankSystem = require("client.slua.logic.unknow_pass.rank.logic_unknowpass_rank")
    UnknowPassRankSystem.top_1w_score = self_rank_data.top1w
  end
  local num = rank_util.calc_topn_percentage(score, self_rank_data.top1w, rankSelectType, self_rank_data.no)
  rank_data.SetSelfBelow1wDisplay(num)
  if rankSelectType == RankConfig.RankSelectEnum.guardian and rank_info.ext_data and rank_info.ext_data.receiver_uid then
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetRankProfiles(Enum_PROFILE_REPORT_CFG.RANK_ENTER, {
      tonumber(rank_info.ext_data.receiver_uid)
    }, rank_ctrl.GetRankProfileRsp)
  end
  if rankSelectType == RankConfig.RankSelectEnum.planPH and rank_info.ext_data and rank_info.ext_data.mate_uid then
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles({
      self_rank_data.ext_data.mate_uid
    }, rank_ctrl.GetMateProfileRsp, Enum_PROFILE_REPORT_CFG.RANK_ENTER)
  end
  EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_RANK_UPDATE_SELF, rankSelectType)
  if rankSelectType == RankConfig.RankSelectEnum.upass then
    EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_RANK_UPDATE_SELF, rankSelectType)
  end
end
function rank_ctrl.ParseSpecialUserRank(err_code, client_data, rank_list)
  log(bWriteLog and "rank_ctrl.ParseSpecialUserRank")
  if err_code ~= 0 then
    log(bWriteLog and "rank_ctrl.ParseSpecialUserRank err_code = " .. tostring(err_code))
    return
  end
  if client_data ~= RankConfig.RankSelectEnum.intimacy then
    log(bWriteLog and "rank_ctrl.ParseSpecialUserRank not intimacy rank info")
    return
  end
  local TableUtil = require("common.table_util")
  local rank_info = {}
  for _, v in pairs(rank_list or {}) do
    if not next(rank_info) then
      rank_info = v
    end
    if v.rank_no and not rank_info.rank_no then
      rank_info = TableUtil.CopyTable(v)
    elseif v.rank_no and rank_info.rank_no and v.rank_no < rank_info.rank_no then
      rank_info = TableUtil.CopyTable(v)
    elseif not v.rank_no and not rank_info.rank_no and v.score > rank_info.score then
      rank_info = TableUtil.CopyTable(v)
    end
  end
  if next(rank_info) then
    local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
    local friendUID, intimacy = LogicFriend.GetFriendUIDAndIntimacyByRankUID(rank_info.uid)
    rank_info.ext_data = {
      uid_s = DataMgr.roleData.uid,
      uid_l = friendUID,
      total_    }
    rank_info = rank_data_converter.ConvertSelfIntimacyRankInfo(rank_info)
    rank_data.SetSelfIntimacyRankUID(rank_info.uid)
  else
    rank_info = {
      uid = DataMgr.roleData.uid,
      ext_data = {
        uid_s = DataMgr.roleData.uid
      }
    }
    rank_data.SetSelfIntimacyRankUID(DataMgr.roleData.uid)
  end
  rank_data.SetIntimacySelfRoleData()
  rank_data.SetSelfRankData(rank_info, rank_data_converter.ConvertSelfRankRsp)
  rank_data.SetItemContentByProfile(rank_info.uid)
  local self_rank_data = rank_data.GetSelfRankData()
  local score = self_rank_data.score
  local rankSelectType = RankDataMgr.GetRankSelectType()
  local num = rank_util.calc_topn_percentage(score, self_rank_data.top1w, rankSelectType, self_rank_data.no)
  rank_data.SetSelfBelow1wDisplay(num)
  if RankDataMgr.IsIntimacy() and rank_info.ext_data and rank_info.ext_data.uid_l then
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles({
      tonumber(rank_info.ext_data.uid_l)
    }, rank_ctrl.GetIntimacyProfileRsp, Enum_PROFILE_REPORT_CFG.RANK_ENTER)
  end
  EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_RANK_UPDATE_SELF, rankSelectType)
end
function rank_ctrl.GetFriendRankReq(zone_id)
  log(bWriteLog and "[rank_ctrl] GetFriendRankReq: " .. tostring(zone_id))
  local rankSelectType = RankDataMgr.GetRankSelectType()
  local flag = RankDataMgr.GetPlanPHDataFlag()
  log(bWriteLog and "rank_ctrl.GetFriendRankReq rankSelectType = " .. tostring(rankSelectType) .. " flag = " .. tostring(flag))
  if flag and rankSelectType == RankConfig.RankSelectEnum.planPH then
  else
    rank_data.ClearRankData()
  end
  RankDataMgr.SetPlanPHDataFlag(false)
  if rankSelectType == RankConfig.RankSelectEnum.popularity or rankSelectType == RankConfig.RankSelectEnum.pround or rankSelectType == RankConfig.RankSelectEnum.guardian then
    rank_ctrl.GetGiftFriendRankReq()
  elseif rankSelectType == RankConfig.RankSelectEnum.planPH then
    local logic_home_rank = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_rank)
    logic_home_rank:GetPlanPHFriendRankReq()
  elseif RankDataMgr.IsPeakGameRanking(rankSelectType) then
    local LogicPeakGameRank = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGameRank)
    LogicPeakGameRank:ReqFriendRankListData()
  else
    rank_ctrl.GetNormalFriendRankReq(zone_id)
  end
end
local friend_rank_batch_info = {
  total_batch = 0,
  received_batch = 0,
  zone_id = nil
}
function rank_ctrl.GetNormalFriendRankReq(zone_id)
  log(bWriteLog and "[rank_ctrl] GetNormalFriendRankReq zone_id = " .. tostring(zone_id))
  if rank_data.IsFriendRankCacheValid(zone_id) then
    log(bWriteLog and "[rank_ctrl] GetNormalFriendRankReq use cache")
    rank_data.LoadFriendRankFromCache()
    local rankSelectType = RankDataMgr.GetRankSelectType()
    EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_RANK_UPDATE_LIST, rankSelectType)
    if rankSelectType == RankConfig.RankSelectEnum.upass then
      EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_RANK_UPDATE_LIST, rankSelectType)
    end
    EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_RANK_UPDATE_SELF, rankSelectType)
    if rankSelectType == RankConfig.RankSelectEnum.upass then
      EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_RANK_UPDATE_SELF, rankSelectType)
    end
    return
  end
  log(bWriteLog and "[rank_ctrl] GetNormalFriendRankReq request from server")
  friend_rank_batch_info.total_batch = 0
  friend_rank_batch_info.received_batch = 0
  friend_rank_batch_info.  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local friend_list = LogicFriend.GetAllFriendList()
  local rank_friend_list = rank_util.FilterPlatformsFriendList(friend_list)
  local RankHandler = require("client.network.Protocol.RankHandler")
  local curReqList = {}
  table.insert(curReqList, DataMgr.roleData.uid)
  for _, uid in pairs(rank_friend_list) do
    table.insert(curReqList, uid)
    if 100 <= #curReqList then
      RankHandler.send_get_friend_rank(zone_id, curReqList)
      friend_rank_batch_info.total_batch = friend_rank_batch_info.total_batch + 1
      curReqList = {}
    end
  end
  if 0 < #curReqList then
    RankHandler.send_get_friend_rank(zone_id, curReqList)
    friend_rank_batch_info.total_batch = friend_rank_batch_info.total_batch + 1
  end
end
function rank_ctrl.GetNormalFriendRankRsp(res, zone_id, friend_rank_map)
  log(bWriteLog and "[rank_ctrl] GetNormalFriendRankRsp: " .. tostring(zone_id))
  if res ~= 0 then
    log(bWriteLog and "[rank_ctrl] get normal friend rank failed: " .. tostring(res))
    return
  end
  for uid, friend_rank_data in pairs(friend_rank_map) do
    friend_rank_data.  end
  rank_data.SaveFriendRankToCache(zone_id, friend_rank_map)
  friend_rank_batch_info.received_batch = friend_rank_batch_info.received_batch + 1
  if friend_rank_batch_info.received_batch >= friend_rank_batch_info.total_batch then
    rank_data.LoadFriendRankFromCache()
    local rankSelectType = RankDataMgr.GetRankSelectType()
    EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_RANK_UPDATE_LIST, rankSelectType)
    if rankSelectType == RankConfig.RankSelectEnum.upass then
      EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_RANK_UPDATE_LIST, rankSelectType)
    end
    EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_RANK_UPDATE_SELF, rankSelectType)
    if rankSelectType == RankConfig.RankSelectEnum.upass then
      EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_RANK_UPDATE_SELF, rankSelectType)
    end
    friend_rank_batch_info.total_batch = 0
    friend_rank_batch_info.received_batch = 0
    friend_rank_batch_info.zone_id = nil
  end
end
function rank_ctrl.GetGiftFriendRankReq()
  log(bWriteLog and "[rank_ctrl] GetGiftFriendRankReq")
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local friend_list = LogicFriend.GetAllFriendList()
  local rank_friend_list = rank_util.FilterPlatformsFriendList(friend_list)
  local cached_rank, reqList = {}, {}
  for _, uid in pairs(rank_friend_list) do
    local cached_friend_rank = RankDataMgr.GetRankSummaryRspDataByUID(uid)
    if cached_friend_rank then
      cached_rank[uid] = cached_friend_rank
    else
      table.insert(reqList, uid)
    end
  end
  table.insert(reqList, tonumber(DataMgr.roleData.uid))
  if next(cached_rank) then
    rank_ctrl.GetGiftFriendRankRsp(0, cached_rank, RankConfig.PopularityReqType.friendReq)
  end
  local RankHandler = require("client.network.Protocol.RankHandler")
  if #reqList <= 100 then
    RankHandler.send_batch_get_popularit_summary_req(reqList, RankConfig.PopularityReqType.friendReq)
  else
    local curReqList = {}
    for _, uid in ipairs(reqList) do
      table.insert(curReqList, uid)
      if 100 <= #curReqList then
        RankHandler.send_batch_get_popularit_summary_req(curReqList, RankConfig.PopularityReqType.friendReq)
        curReqList = {}
      end
    end
    if 0 < #curReqList then
      RankHandler.send_batch_get_popularit_summary_req(curReqList, RankConfig.PopularityReqType.friendReq)
    end
  end
end
function rank_ctrl.GetGiftFriendRankRsp(res, result, reqType)
  log(bWriteLog and "[rank_ctrl] GetGiftFriendRankRsp")
  if res ~= 0 then
    log(bWriteLog and "[rank_ctrl] get gift friend rank failed: " .. tostring(res))
    return
  end
  local raw_data_map = {}
  for uid, bin_info in pairs(result) do
    local friend_data = bin_info
    if type(friend_data) == "string" then
      friend_data = slua.LuaArchiverDecode(LuaStateWrapper, bin_info)
    end
    local TimeUtil = require("client.common.time_util")
    local curTime = TimeUtil.GetServerTimeInSec()
    if not TimeUtil.IsSameWeek(friend_data.last_update_time or 0, curTime) then
      friend_data.last_week_devote = 0
    end
    if friend_data.last_pround_update_time and not TimeUtil.IsSameWeek(friend_data.last_pround_update_time or 0, curTime) then
      friend_data.last_week_pround = 0
    end
    if friend_data.last_guardian_update_time and not TimeUtil.IsSameWeek(friend_data.last_guardian_update_time or 0, curTime) then
      friend_data.last_week_guardian = 0
      friend_data.last_week_guardian_receiver = nil
    end
    friend_data.    raw_data_map[uid] = friend_data
  end
  if reqType == RankConfig.PopularityReqType.teamPKReq then
    local logic_popular_team_pk_invitefriend = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_team_pk_invitefriend)
    logic_popular_team_pk_invitefriend:OnPopularLevelRsp(raw_data_map)
    return
  end
  if reqType == RankConfig.PopularityReqType.friendReq then
    rank_data.SetRankDataList(raw_data_map, rank_data_converter.ConvertGiftFriendRsp)
    rank_data.SortFriendRankList()
  elseif reqType == RankConfig.PopularityReqType.selfReq then
    rank_data.SetSelfRankData(raw_data_map[tonumber(DataMgr.roleData.uid)], rank_data_converter.ConvertSelfGiftRsp)
    local self_rank_data = rank_data.GetSelfRankData()
    if self_rank_data.ext_data.receiver_uid then
      local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
      logic_profile_get_wrap.GetNormalProfiles({
        self_rank_data.ext_data.receiver_uid
      }, rank_ctrl.GetGuardedProfileRsp, Enum_PROFILE_REPORT_CFG.RANK_ENTER)
    end
  end
  local rankSelectType = RankDataMgr.GetRankSelectType()
  EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_RANK_UPDATE_LIST, rankSelectType)
  if rankSelectType == RankConfig.RankSelectEnum.upass then
    EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_RANK_UPDATE_LIST, rankSelectType)
  end
  EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_RANK_UPDATE_SELF, rankSelectType)
  if rankSelectType == RankConfig.RankSelectEnum.upass then
    EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_RANK_UPDATE_SELF, rankSelectType)
  end
end
function rank_ctrl.InitMyRankInfo()
  log(bWriteLog and "[rank_ctrl] InitMyRankInfo")
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetRankProfiles(Enum_PROFILE_REPORT_CFG.RANK_ENTER, {
    tonumber(DataMgr.roleData.uid)
  }, rank_ctrl.GetRankProfileRsp)
end
function rank_ctrl.QueryRankRoleInfoByScroll(indexFrom)
  log(bWriteLog and "[rank_ctrl] QueryRankRoleInfoByScroll: " .. tostring(indexFrom))
  local req_profile_uid_list, guarded_profile_uid_list, reqIntimacyProfileUidList, reqMateProfileUidList = rank_data.GetReqProfileList(indexFrom)
  if 0 < #req_profile_uid_list then
    log(bWriteLog and "[rank_ctrl] QueryRankRoleInfoByScroll #listUid = " .. tostring(#req_profile_uid_list))
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetRankProfiles(Enum_PROFILE_REPORT_CFG.RANK_SCROLL, req_profile_uid_list, rank_ctrl.GetRankProfileRsp)
  end
  if 0 < #guarded_profile_uid_list then
    log(bWriteLog and "[rank_ctrl] QueryRankRoleInfoByScroll guarded #listUid = " .. tostring(#guarded_profile_uid_list))
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles(guarded_profile_uid_list, rank_ctrl.GetGuardedProfileRsp, Enum_PROFILE_REPORT_CFG.RANK_SCROLL)
  end
  if 0 < #reqIntimacyProfileUidList then
    log(bWriteLog and "[rank_ctrl] QueryRankRoleInfoByScroll intimacy #listUid = " .. tostring(#reqIntimacyProfileUidList))
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles(reqIntimacyProfileUidList, rank_ctrl.GetIntimacyProfileRsp, Enum_PROFILE_REPORT_CFG.RANK_SCROLL)
  end
  if 0 < #reqMateProfileUidList then
    log(bWriteLog and "[rank_ctrl] QueryRankRoleInfoByScroll home #listUid = " .. tostring(#reqMateProfileUidList))
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles(reqMateProfileUidList, rank_ctrl.GetMateProfileRsp, Enum_PROFILE_REPORT_CFG.RANK_SCROLL)
  end
  local reqHomeProfileUidList = rank_data.GetReqHomeProfileList(indexFrom)
  log(bWriteLog and "rank_ctrl.QueryRankRoleInfoByScroll #reqHomeProfileUidList = " .. tostring(#reqHomeProfileUidList))
  if 0 < #reqHomeProfileUidList then
    local logic_home_profile = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_profile)
    local callback = function()
      local logic_home_rank = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_rank)
      logic_home_rank:GetPlanPHTotalRank(reqHomeProfileUidList)
    end
    logic_home_profile:GetOrReqHomeProfile(reqHomeProfileUidList, callback, false)
  end
end
function rank_ctrl.GetGuardedProfileRsp(profileList)
  log(bWriteLog and "[rank_ctrl] GetGuardedProfileRsp")
  if type(profileList) ~= "table" then
    log(bWriteLog and "[rank_ctrl] nil profile list")
    return
  end
  local profileMap = {}
  for i, v in ipairs(profileList) do
    profileMap[tostring(v.uid)] = v
  end
  local rankSelectType = RankDataMgr.GetRankSelectType()
  local rank_data_list = rank_data.GetRankDataList()
  for _, rank_item in ipairs(rank_data_list) do
    if rank_item.ext_data and rank_item.ext_data.receiver_uid and profileMap[tostring(rank_item.ext_data.receiver_uid)] then
      local guarded_profile = profileMap[tostring(rank_item.ext_data.receiver_uid)]
      rank_data.SetItemProfile(rank_item.uid, guarded_profile, rank_data_converter.ConvertGuardedProfileRsp)
      EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_RANK_UPDATE_ITEM, rank_item, rankSelectType)
    end
  end
  local self_rank_data = rank_data.GetSelfRankData()
  if rankSelectType == RankConfig.RankSelectEnum.guardian and self_rank_data and self_rank_data.ext_data and self_rank_data.ext_data.receiver_uid and profileMap[tostring(self_rank_data.ext_data.receiver_uid)] then
    rank_data.SetItemProfile(DataMgr.roleData.uid, profileMap[tostring(self_rank_data.ext_data.receiver_uid)], rank_data_converter.ConvertGuardedProfileRsp)
    EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_RANK_UPDATE_SELF, rankSelectType)
  end
end
function rank_ctrl.GetIntimacyProfileRsp(profileList)
  log(bWriteLog and "rank_ctrl.GetIntimacyProfileRsp")
  if type(profileList) ~= "table" then
    log(bWriteLog and "rank_ctrl.GetIntimacyProfileRsp nil profile list")
    return
  end
  local profileMap = {}
  for i, v in ipairs(profileList) do
    profileMap[tostring(v.uid)] = v
  end
  local rankSelectType = RankDataMgr.GetRankSelectType()
  local rank_data_list = rank_data.GetRankDataList()
  for _, rank_item in ipairs(rank_data_list) do
    if rank_item.ext_data and rank_item.ext_data.uid_l and profileMap[tostring(rank_item.ext_data.uid_l)] then
      local intimacy_profile = profileMap[tostring(rank_item.ext_data.uid_l)]
      rank_data.SetItemProfile(rank_item.uid, intimacy_profile, rank_data_converter.ConvertIntimacyProfileRsp)
      EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_RANK_UPDATE_ITEM, rank_item, rankSelectType)
    end
  end
  local self_rank_data = rank_data.GetSelfRankData()
  if RankDataMgr.IsIntimacy() and self_rank_data and self_rank_data.ext_data and self_rank_data.ext_data.uid_l and profileMap[tostring(self_rank_data.ext_data.uid_l)] then
    rank_data.SetItemProfile(self_rank_data.uid, profileMap[tostring(self_rank_data.ext_data.uid_l)], rank_data_converter.ConvertIntimacyProfileRsp)
    EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_RANK_UPDATE_SELF, rankSelectType)
  end
end
function rank_ctrl.GetMateProfileRsp(profileList)
  log(bWriteLog and "[rank_ctrl] GetMateProfileRsp")
  if type(profileList) ~= "table" then
    log(bWriteLog and "[rank_ctrl] GetMateProfileRsp profile list invalid")
    return
  end
  local profileMap = {}
  for i, v in ipairs(profileList) do
    profileMap[tostring(v.uid)] = v
  end
  local rankSelectType = RankDataMgr.GetRankSelectType()
  local rank_data_list = rank_data.GetRankDataList()
  for _, rank_item in ipairs(rank_data_list) do
    if rank_item.ext_data and rank_item.ext_data.mate_uid and profileMap[tostring(rank_item.ext_data.mate_uid)] then
      local mate_profile = profileMap[tostring(rank_item.ext_data.mate_uid)]
      rank_data.SetItemProfile(rank_item.uid, mate_profile, rank_data_converter.ConvertMateProfileRsp)
      EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_RANK_UPDATE_ITEM, rank_item, rankSelectType)
    end
  end
  local self_rank_data = rank_data.GetSelfRankData()
  if rankSelectType == RankConfig.RankSelectEnum.planPH and self_rank_data and self_rank_data.ext_data and self_rank_data.ext_data.mate_uid and profileMap[tostring(self_rank_data.ext_data.mate_uid)] then
    rank_data.SetItemProfile(DataMgr.roleData.uid, profileMap[tostring(self_rank_data.ext_data.mate_uid)], rank_data_converter.ConvertMateProfileRsp)
    EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_RANK_UPDATE_SELF, rankSelectType)
  end
end
function rank_ctrl.GetRankProfileRsp(profileList)
  log(bWriteLog and "[rank_ctrl] GetRankProfileRsp")
  if type(profileList) ~= "table" then
    log(bWriteLog and "[rank_ctrl] nil profile list")
    return
  end
  local profileMap = {}
  for _, v in ipairs(profileList) do
    profileMap[tostring(v.uid)] = v
  end
  local rankSelectType = RankDataMgr.GetRankSelectType()
  local rank_data_list = rank_data.GetRankDataList()
  for _, rank_item in ipairs(rank_data_list) do
    local currentUID
    if rank_item.ext_data and rank_item.ext_data.uid_s then
      currentUID = rank_item.ext_data.uid_s
    else
      currentUID = rank_item.uid
    end
    local profile = profileMap[tostring(currentUID)]
    if profile then
      rank_data.SetItemProfile(rank_item.uid, profile, rank_data_converter.ConvertProfileRsp)
      rank_data.SetItemContentByProfile(rank_item.uid)
      EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_RANK_UPDATE_ITEM, rank_item, rankSelectType)
      if rankSelectType == RankConfig.RankSelectEnum.upass then
        EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_RANK_UPDATE_ITEM, rank_item, rankSelectType)
      end
    end
    if rank_item.ext_data and rank_item.ext_data.receiver_uid and profileMap[tostring(rank_item.ext_data.receiver_uid)] then
      local guarded_profile = profileMap[tostring(rank_item.ext_data.receiver_uid)]
      rank_data.SetItemProfile(rank_item.uid, guarded_profile, rank_data_converter.ConvertGuardedProfileRsp)
      EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_RANK_UPDATE_ITEM, rank_item, rankSelectType)
    end
    if rank_item.ext_data and rank_item.ext_data.uid_l and profileMap[tostring(rank_item.ext_data.uid_l)] then
      local intimacy_profile = profileMap[tostring(rank_item.ext_data.uid_l)]
      rank_data.SetItemProfile(rank_item.uid, intimacy_profile, rank_data_converter.ConvertIntimacyProfileRsp)
      EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_RANK_UPDATE_ITEM, rank_item, rankSelectType)
    end
    if rank_item.ext_data and rank_item.ext_data.mate_uid and profileMap[tostring(rank_item.ext_data.mate_uid)] then
      local mate_profile = profileMap[tostring(rank_item.ext_data.mate_uid)]
      rank_data.SetItemProfile(rank_item.uid, mate_profile, rank_data_converter.ConvertMateProfileRsp)
      EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_RANK_UPDATE_ITEM, rank_item, rankSelectType)
    end
  end
  if profileMap[tostring(DataMgr.roleData.uid)] then
    rank_data.SetItemProfile(DataMgr.roleData.uid, profileMap[tostring(DataMgr.roleData.uid)], rank_data_converter.ConvertProfileRsp)
    rank_data.SetItemContentByProfile(DataMgr.roleData.uid)
    EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_RANK_UPDATE_SELF, rankSelectType)
    if rankSelectType == RankConfig.RankSelectEnum.upass then
      EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_RANK_UPDATE_SELF, rankSelectType)
    end
  end
  local self_rank_data = rank_data.GetSelfRankData()
  if rankSelectType == RankConfig.RankSelectEnum.guardian and self_rank_data and self_rank_data.ext_data and self_rank_data.ext_data.receiver_uid and profileMap[tostring(self_rank_data.ext_data.receiver_uid)] then
    rank_data.SetItemProfile(DataMgr.roleData.uid, profileMap[tostring(self_rank_data.ext_data.receiver_uid)], rank_data_converter.ConvertGuardedProfileRsp)
    EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_RANK_UPDATE_SELF, rankSelectType)
  end
  if RankDataMgr.IsIntimacy() and self_rank_data and self_rank_data.ext_data and self_rank_data.ext_data.uid_s and self_rank_data.ext_data.uid_l then
    if profileMap[tostring(self_rank_data.ext_data.uid_s)] then
      rank_data.SetItemProfile(self_rank_data.uid, profileMap[tostring(DataMgr.roleData.uid)], rank_data_converter.ConvertProfileRsp)
      rank_data.SetItemContentByProfile(self_rank_data.uid)
    end
    if profileMap[tostring(self_rank_data.ext_data.uid_l)] then
      rank_data.SetItemProfile(self_rank_data.uid, profileMap[tostring(self_rank_data.ext_data.uid_l)], rank_data_converter.ConvertIntimacyProfileRsp)
      EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_RANK_UPDATE_SELF, rankSelectType)
    end
  end
  local self_rank_data = rank_data.GetSelfRankData()
  if rankSelectType == RankConfig.RankSelectEnum.planPH and self_rank_data and self_rank_data.ext_data and self_rank_data.ext_data.mate_uid and profileMap[tostring(self_rank_data.ext_data.mate_uid)] then
    rank_data.SetItemProfile(DataMgr.roleData.uid, profileMap[tostring(self_rank_data.ext_data.mate_uid)], rank_data_converter.ConvertMateProfileRsp)
    EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_RANK_UPDATE_SELF, rankSelectType)
  end
end
return rank_ctrl