local promotion_match_util = {}
function promotion_match_util.GetPromotionSwitch()
  log(bWriteLog and "promotion_match_util.GetPromotionSwitch")
  local promotion_switch_on = LobbySystem.roleData.promotion_switch_on
  log(bWriteLog and "promotion_match_util.GetPromotionSwitch promotion_switch_on = " .. tostring(promotion_switch_on))
  return promotion_switch_on
end
function promotion_match_util.GetPromotionStartSeasonId()
  log(bWriteLog and "promotion_match_util.GetPromotionStartSeasonId")
  local promotion_start_seasonid = LobbySystem.roleData.promotion_start_seasonid
  log(bWriteLog and "promotion_match_util.GetPromotionStartSeasonId promotion_start_seasonid = " .. tostring(promotion_start_seasonid))
  return promotion_start_seasonid
end
function promotion_match_util.GetPromotionData()
  log(bWriteLog and "promotion_match_util.GetPromotionData")
  local cur_promotion_data = LobbySystem.roleData.cur_promotion_data
  if cur_promotion_data then
    cur_promotion_data.challenge_value = cur_promotion_data.challenge_value or 0
  end
  log_tree("promotion_match_util.GetPromotionData cur_promotion_data", cur_promotion_data)
  return cur_promotion_data
end
function promotion_match_util.UpdatePromotionData(cur_promotion_data)
  log(bWriteLog and "promotion_match_util.UpdatePromotionData")
  log_tree("promotion_match_util.UpdatePromotionData new cur_promotion_data", cur_promotion_data)
  if LobbySystem and LobbySystem.roleData then
    log(bWriteLog and "promotion_match_util.UpdatePromotionData old cur_promotion_data = " .. tostring(LobbySystem.roleData.cur_promotion_data))
    LobbySystem.roleData.  end
end
function promotion_match_util.GetPromotionChallengeSwitch()
  log(bWriteLog and "promotion_match_util.GetPromotionChallengeSwitch")
  local promotion_challenge_switch_on = LobbySystem.roleData.promotion_challenge_switch_on
  log(bWriteLog and "promotion_match_util.GetPromotionChallengeSwitch promotion_challenge_switch_on = " .. tostring(promotion_challenge_switch_on))
  return promotion_challenge_switch_on
end
function promotion_match_util.GetPromotionChallengeScoreStartSeasonId()
  log(bWriteLog and "promotion_match_util.GetPromotionChallengeScoreStartSeasonId")
  local promo_challenge_score_start_season_id = LobbySystem.roleData.promo_challenge_score_start_season_id
  log(bWriteLog and "promotion_match_util.GetPromotionChallengeScoreStartSeasonId promo_challenge_score_start_season_id = " .. tostring(promo_challenge_score_start_season_id))
  return promo_challenge_score_start_season_id
end
function promotion_match_util.UpdatePromoChallengeData(challenge_Info)
  log_tree(bWriteLog and "promotion_match_util.UpdatePromoChallengeData challenge_Info = ", challenge_Info)
  if LobbySystem and LobbySystem.roleData and LobbySystem.roleData.cur_promotion_data and challenge_Info then
    log(bWriteLog and "promotion_match_util.UpdatePromoChallengeData old challenge_value = " .. tostring(LobbySystem.roleData.cur_promotion_data.challenge_value))
    LobbySystem.roleData.cur_promotion_data.challenge_value = challenge_Info.challenge_value
  end
end
function promotion_match_util.ReqPromotionBaseConfig(callback)
  log(bWriteLog and "promotion_match_util.ReqPromotionBaseConfig callback = " .. tostring(callback))
  local data_config_marco = require("client.logic.data.data_config_marco")
  local promotion_base_config = data_config_marco.promotion_base_config
  local promotion_base_config_new = data_config_marco.promotion_base_config_new
  local season_id = DataMgr.season_id
  log(bWriteLog and "promotion_match_util.ReqPromotionBaseConfig season_id = " .. tostring(season_id))
  local use_config
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local isBlueHole = Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE
  log(bWriteLog and "promotion_match_util.ReqPromotionBaseConfig isBlueHole = " .. tostring(isBlueHole))
  if isBlueHole then
    if 47 <= season_id then
      use_config = promotion_base_config_new
    else
      use_config = promotion_base_config
    end
  elseif 48 <= season_id then
    use_config = promotion_base_config_new
  else
    use_config = promotion_base_config
  end
  local callback_inner = function(table_name, table_data)
    log(bWriteLog and "promotion_match_util:ReqPromotionBaseConfig callback_inner table_name = " .. tostring(table_name))
    if table_name ~= use_config or not table_data then
      log(bWriteLog and "promotion_match_util:ReqPromotionBaseConfig callback_inner table_name ~= promotion_base_config or not table_data")
      return
    end
    log_tree("promotion_match_util.GetPromotionMatchData promotion_base_config", table_data)
    if callback then
      callback(table_data)
    end
  end
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  BasicDataServerTable:GetOrReqData(use_config, callback_inner)
end
function promotion_match_util.GetPromotionRatingData()
  log(bWriteLog and "promotion_match_util.GetPromotionRatingData")
  local promo_rating = LobbySystem.roleData.promo_rating
  log_tree("promotion_match_util.GetPromotionRatingData promo_rating", promo_rating)
  return promo_rating
end
function promotion_match_util.UpdatePromotionRatingData(zone_id, mode_type, promo_rank_rating)
  log(bWriteLog and "promotion_match_util.UpdatePromotionRatingData zone_id = " .. tostring(zone_id) .. " mode_type = " .. tostring(mode_type))
  if not zone_id or not mode_type then
    log(bWriteLog and "promotion_match_util.UpdatePromotionRatingData zone_id or mode_type is nil")
    return
  end
  if LobbySystem and LobbySystem.roleData and LobbySystem.roleData.promo_rating then
    LobbySystem.roleData.promo_rating[zone_id] = LobbySystem.roleData.promo_rating[zone_id] or {}
    LobbySystem.roleData.promo_rating[zone_id][mode_type] = LobbySystem.roleData.promo_rating[zone_id][mode_type] or 0
    LobbySystem.roleData.promo_rating[zone_id][mode_type] = promo_rank_rating
  end
end
function promotion_match_util.ClearPromotionRatingData()
  log(bWriteLog and "promotion_match_util.ClearPromotionRatingData")
  if LobbySystem and LobbySystem.roleData then
    LobbySystem.roleData.promo_rating = nil
  end
end
function promotion_match_util.GetBigSementUpConfig(segment_type)
  log(bWriteLog and "promotion_match_util.GetBigSementUpConfig segment_type = " .. tostring(segment_type))
  local season_id = DataMgr.season_id
  local seasonCfg = CDataTable.GetTableData("SeasonInfo", season_id)
  if not seasonCfg then
    log(bWriteLog and "promotion_match_util.GetBigSementUpConfig SeasonInfo is nil")
    return
  end
  local SegmentVideoType = seasonCfg.SegmentVideoType
  log(bWriteLog and "promotion_match_util.GetBigSementUpConfig SegmentVideoType = " .. tostring(SegmentVideoType))
  if not SegmentVideoType then
    log(bWriteLog and "promotion_match_util.GetBigSementUpConfig SegmentVideoType is nil")
    return
  end
  local segUpConfig = CDataTable.GetTableDataByFilter("BigSegmentUpConfig", "SegmentVideoType", SegmentVideoType, "TypeID", segment_type)
  if not segUpConfig then
    log(bWriteLog and "promotion_match_util.GetBigSementUpConfig BigSegmentUpConfig is nil")
    return
  end
  return segUpConfig
end
return promotion_match_util