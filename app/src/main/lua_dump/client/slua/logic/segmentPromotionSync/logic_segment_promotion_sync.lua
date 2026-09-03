local LogicSegmentPromotionSync = {}
local IsClassicMode = function(modeId)
  return modeId == 101 or modeId == 102 or modeId == 103 or modeId == 401 or modeId == 402 or modeId == 403
end
function LogicSegmentPromotionSync.GetModeSegmentAndRating(zoneId, modeId)
  local segmentData = DataMgr.GetSegmentByZoneId(zoneId)
  local rating
  if DataMgr.roleData.segment_rating then
    rating = DataMgr.roleData.segment_rating[zoneId]
  end
  if segmentData == nil or rating == nil then
    log_warning("LogicSegmentPromotionSync have no segment data, zoneID = " .. tostring(zoneId))
    return nil, nil
  end
  if modeId == 101 then
    return segmentData.solo, rating[enum_SegmentType.solo]
  elseif modeId == 102 then
    return segmentData.double, rating[enum_SegmentType.double]
  elseif modeId == 103 then
    return segmentData.team, rating[enum_SegmentType.team]
  elseif modeId == 401 then
    return segmentData.fpp_solo, rating[enum_SegmentType.fpp_solo]
  elseif modeId == 402 then
    return segmentData.fpp_double, rating[enum_SegmentType.fpp_double]
  elseif modeId == 403 then
    return segmentData.fpp_team, rating[enum_SegmentType.fpp_team]
  else
    return nil, nil
  end
end
function LogicSegmentPromotionSync.GetSegmentSyncData(curMode, lastMode)
  if not LobbySystem.CheckOpen(BP_ENUM_SEGMENT_SYNC_SWITCH) then
    log(bWriteLog and "BP_ENUM_SEGMENT_SYNC_SWITCH is close")
    return
  end
  if GameStatus.GetGameStatus() ~= GameStatus.Lobby then
    log(bWriteLog and "LogicSegmentPromotionSync GetSegmentSyncData is not in lobby")
    return
  end
  local curModeid = tonumber(curMode)
  local lastModeid = tonumber(lastMode)
  if not IsClassicMode(curModeid) then
    return
  end
  if lastModeid == curModeid then
    return
  end
  log(bWriteLog and "LogicSegmentPromotionSync.GetSegmentSyncData send")
  LogicSegmentPromotionSync.send_get_rating_sync_info_req(curModeid)
end
function LogicSegmentPromotionSync.ShowSyncNoticeUI(mainMode, rating, segID, ratingSyncData)
  log(bWriteLog and "LogicSegmentPromotionSync ShowSyncNoticeUI")
  if mainMode == nil or ratingSyncData == nil or segID == nil or rating == nil then
    log(bWriteLog and "LogicSegmentPromotionSync ShowSyncNoticeUI data is nil or not in lobby")
    return
  end
  if not GameStatus.IsInLobbyOrMainCity() then
    log(bWriteLog and "LogicSegmentPromotionSync ShowSyncNoticeUI is not in lobby")
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.Segment_Sync_Notice_UIBP, mainMode, rating, segID, ratingSyncData)
  local SegmentSyncHandler = require("client.network.Protocol.SegmentSyncHandler")
  SegmentSyncHandler.send_set_rating_sync_info_flag_req(mainMode)
end
function LogicSegmentPromotionSync.send_get_rating_sync_info_req(modeId)
  local SegmentSyncHandler = require("client.network.Protocol.SegmentSyncHandler")
  SegmentSyncHandler.send_get_rating_sync_info_req(modeId)
end
function LogicSegmentPromotionSync.on_get_rating_sync_info_rsp(rating_sync_info)
  if not LobbySystem.CheckOpen(BP_ENUM_SEGMENT_SYNC_SWITCH) then
    log(bWriteLog and "BP_ENUM_SEGMENT_SYNC_SWITCH is close")
    return
  end
  if rating_sync_info == nil or rating_sync_info.detail == nil or not GameStatus.IsInLobbyOrMainCity() then
    log(bWriteLog and "LogicSegmentPromotionSync rating_sync_info is nil or not in lobby")
    return
  end
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  local zoneId = rating_sync_info.zone_id
  if zoneId == nil or ZoneSystem.nChooseZoneID == nil or zoneId ~= ZoneSystem.nChooseZoneID then
    log(bWriteLog and "LogicSegmentPromotionSync rating_sync_info Not current zone, zoneid" .. tostring(zoneId))
    return
  end
  local mainMode = rating_sync_info.mode or 0
  if not IsClassicMode(mainMode) then
    log(bWriteLog and "LogicSegmentPromotionSync rating_sync_info is not Classic Mode. curmode is " .. tostring(mainMode))
    return
  end
  local segID, rating = LogicSegmentPromotionSync.GetModeSegmentAndRating(zoneId, mainMode)
  if segID == nil or rating == nil then
    log(bWriteLog and "LogicSegmentPromotionSync cannot get mode segment or rating")
    return
  end
  log(bWriteLog and "LogicSegmentPromotionSync segID " .. tostring(segID) .. "rating " .. tostring(rating) .. "mainMode " .. tostring(mainMode))
  local ratingSyncData = {}
  for k, v in pairs(rating_sync_info.detail) do
    if IsClassicMode(k) then
      local syncSeg, syncRating = LogicSegmentPromotionSync.GetModeSegmentAndRating(zoneId, k)
      log(bWriteLog and "LogicSegmentPromotionSync ratingSyncData segID " .. tostring(syncSeg) .. "rating " .. tostring(syncRating) .. "mode " .. tostring(k))
      ratingSyncData[k] = {
        rank_rating_change = v,
        new_segment_info = syncSeg or 0,
        new_rank_rating = syncRating or 0
      }
    end
  end
  local time_ticker = require("common.time_ticker")
  time_ticker.AddTimerOnce(0.5, function()
    LogicSegmentPromotionSync.ShowSyncNoticeUI(mainMode, rating, segID, ratingSyncData)
  end)
end
return LogicSegmentPromotionSync