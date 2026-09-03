local SeasonReviewSystem = {
  curReviewUid = "",
  SeasonLookbackData = {},
  SeasonRecordsSummary = {}
}
local GetTranslator = function()
  local UIUtil = require("client.common.ui_util")
  local _GameFrontendHUD = UIUtil.GetGameInstance():GetAssociatedFrontendHUD()
  if _GameFrontendHUD then
    return _GameFrontendHUD:GetTranslator()
  end
  return nil
end
function SeasonReviewSystem.OnLogin()
  SeasonReviewSystem.SeasonRecordsSummary = {}
end
function SeasonReviewSystem.OnGetAccessToken(IsSuccess, Data)
  local Translator = GetTranslator()
  if Translator then
    Translator.OnGetAccessTokenDelegate:Clear()
  end
  if not IsSuccess then
    log(bWriteLog and "SeasonReviewSystem.OnGetAccessToken not IsSuccess")
    return
  end
  Data = string.gsub(Data, "Bearer ", "")
  local seasonTable = json.decode(Data)
  if seasonTable ~= nil and seasonTable.state ~= "FAILURE" then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    PlayerPrefsSystem.SaveTableToFile_N(seasonTable, PlayerPrefsSystem.ePlayerPrefsType.eSeasonLookback)
  end
  EventSystem:postEvent(EVENTTYPE_SEASONLOOKBACK, EVENTID_SEASONLOOKBACK_UPDATEUI)
end
function SeasonReviewSystem.sendGetSeasonReviewSummy(uid)
  SeasonReviewSystem.curReviewUid = uid
  local SeasonHandler = require("client.network.Protocol.SeasonHandler")
  SeasonHandler.send_get_season_file_summy(tonumber(uid))
end
function SeasonReviewSystem.sendGetSeasonFile(uid, seasonId, tabType)
  log(bWriteLog and "get_season_file uid:" .. uid .. ", seasonId:" .. seasonId .. ", tabType:" .. tabType)
  local SeasonHandler = require("client.network.Protocol.SeasonHandler")
  SeasonHandler.send_get_season_file(tonumber(uid), seasonId, tabType)
end
function SeasonReviewSystem.OnGetSeasonFileSummyRsp(target_uid, season_file_summy_list)
  log(bWriteLog and "get_season_file_summy_rsp target_uid:" .. target_uid .. ", count:" .. #season_file_summy_list)
  if tonumber(SeasonReviewSystem.curReviewUid) ~= target_uid then
    return
  end
  log_tree("season_file_summy_list", season_file_summy_list)
  EventSystem:postEvent(EVENTTYPE_SEASON_REVIEW, EVENTID_SEASON_REVIEW_SUMMARY_FILE, season_file_summy_list)
end
function SeasonReviewSystem.OnGetSeasonFileRsp(ret, target_uid, season_id, record_type, record)
  log_tree("SeasonReviewSystem.OnGetSeasonFileRsp", record)
  log(bWriteLog and "get_season_file_rsp ret:" .. ret .. ", target_uid:" .. tostring(target_uid) .. ", season_id:" .. tostring(season_id) .. ", record_type:" .. tostring(record_type))
  if tonumber(SeasonReviewSystem.curReviewUid) ~= target_uid then
    return
  end
  if ret == NetErrorCode_NONE then
    EventSystem:postEvent(EVENTTYPE_SEASON_REVIEW, EVENTID_SEASON_REVIEW_DETAIL_FILE, target_uid, season_id, record_type, record)
  end
end
function SeasonReviewSystem.sendGetPeakGameSeasonFile(uid, seasonId, tabType)
  log(bWriteLog and "SeasonReviewSystem.sendGetPeakGameSeasonFile uid:" .. uid .. ", seasonId:" .. seasonId .. ", tabType:" .. tabType)
  local SeasonHandler = require("client.network.Protocol.SeasonHandler")
  SeasonHandler.send_get_peakgame_season_file_req(tonumber(uid), seasonId, tabType)
end
function SeasonReviewSystem.OnGetPeakGameSeasonFileRsp(ok, target_uid, season_id, rsp)
  log_tree("SeasonReviewSystem.OnGetSeasonFileRsp", rsp)
  if tonumber(SeasonReviewSystem.curReviewUid) ~= target_uid then
    return
  end
  if ok == NetErrorCode_NONE then
    EventSystem:postEvent(EVENTTYPE_SEASON_REVIEW, EVENTID_PEAK_SEASON_REVIEW_DETAIL_FILE, target_uid, season_id, rsp)
  else
  end
end
return SeasonReviewSystem