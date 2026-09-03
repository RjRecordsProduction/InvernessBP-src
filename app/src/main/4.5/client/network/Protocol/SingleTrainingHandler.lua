local RankDefine = require("GameLua.Mod.SingleTraining.GamePlay.Data.SingleTrainingRankDefine")
local RankParams = require("GameLua.Mod.SingleTraining.GamePlay.Data.SingleTrainingRankParams")
local LocalizeText = require("GameLua.Mod.SingleTraining.Client.SingleTrainingLocalizeText")
SingleTrainingHandler = SingleTrainingHandler or {
  RankDataT = {},
  RequestRanks = {},
  ignoreInviteMap = {},
  ignoreMaxTime = 300
}
function SingleTrainingHandler.Init()
  log(bWriteLog and "SingleTrainingHandler.Init")
end
function SingleTrainingHandler.get_rank_data(TrainingType, Level)
  local TrainingRankT = SingleTrainingHandler.RankDataT[TrainingType]
  if TrainingRankT ~= nil then
    return TrainingRankT[Level]
  end
  return nil
end
function SingleTrainingHandler.get_or_add_rank_data(TrainingType, Level)
  local TrainingRankT = SingleTrainingHandler.RankDataT[TrainingType]
  if TrainingRankT == nil then
    TrainingRankT = {}
    SingleTrainingHandler.RankDataT[TrainingType] = TrainingRankT
  end
  local RankData = TrainingRankT[Level]
  if RankData == nil then
    RankData = {
      RankInfo = {},
      RankStr = "",
      CurRankStr = ""
    }
    TrainingRankT[Level] = RankData
  end
  return RankData
end
function SingleTrainingHandler.calc_training_topn_percentage(training_type, score, top_1w_score, rankNo)
  local Params = RankParams[training_type]
  if Params == nil then
    print(bWriteLog and string.format("SingleTrainingHandler.calc_training_topn_percentage, training_type:{%d}", training_type))
    return ""
  end
  log_tree("SingleTrainingHandler.calc_training_topn_percentage Params, Type:" .. tostring(training_type), Params)
  if top_1w_score == nil or score == nil then
    return ""
  end
  local middle_score = (score - Params.K1) / (top_1w_score - Params.K1) * Params.K2 - Params.K3
  local percentage = math.max(math.min((1 / (1 + math.exp(-Params.P_A * middle_score)) - Params.P_B) * Params.P_C + Params.P_D, 1.0), 0)
  local ret = ""
  if math.abs(percentage - 1.0) <= 0.001 then
    ret = LocUtil.LocalizeResFormat(LocalizeText.RankHistoryFormat, "99.99%")
  else
    ret = LocUtil.LocalizeResFormat(LocalizeText.RankHistoryFormat, string.format("%.2f%%", percentage * 100))
  end
  log(bWriteLog and string.format("SingleTrainingHandler.calc_training_topn_percentage, training_type:{%d}, score:{%s}, top_1w_score:{%s}, rank_str:{%s}", training_type, tostring(score), tostring(top_1w_score), ret))
  return ret
end
function SingleTrainingHandler.post_rank_msg(TrainingType, Level, RankData)
  print(bWriteLog and string.format("SingleTrainingHandler.PostRankMsg, TrainingType:{%d}, Level:{%d}", TrainingType, Level))
  if TrainingType == RankDefine.ETrainingType.NormalShooting then
    EventSystem:postEvent(EVENTTYPE_SINGLE_TRAINNING, EVENTID_SINGLE_TRAIN_RANK_SHOOTING, Level, RankData)
  elseif TrainingType == RankDefine.ETrainingType.AI then
    EventSystem:postEvent(EVENTTYPE_SINGLE_TRAINNING, EVENTID_SINGLE_TRAIN_RANK_AI, Level, RankData)
  elseif TrainingType == RankDefine.ETrainingType.ThrowBomb then
    EventSystem:postEvent(EVENTTYPE_SINGLE_TRAINNING, EVENTID_SINGLE_TRAIN_RANK_THROWBOMB, Level, RankData)
  elseif TrainingType == RankDefine.ETrainingType.ReactionShooting then
    EventSystem:postEvent(EVENTTYPE_SINGLE_TRAINNING, EVENTID_SINGLE_TRAIN_RANK_SHOOTING_REACTION, Level, RankData)
  end
end
function SingleTrainingHandler.AsyncGetUserRankData(TrainingType, Level)
  local RankID = RankDefine:TypeToID(TrainingType, Level)
  if RankID == nil then
    log_error(string.format("SingleTrainingHandler.get_user_training_data, Type:{%d}, Level:{%d}", TrainingType, Level))
    return
  end
  local RequestSymbol = string.format("%s_%d", RankDefine.Symbol, RankID)
  if SingleTrainingHandler.RequestRanks[RequestSymbol] == nil then
    local RankHandler = require("client.network.Protocol.RankHandler")
    SingleTrainingHandler.RequestRanks[RequestSymbol] = RankID
    RankHandler.send_get_one_user_rank(RequestSymbol, 0, 0, RankID)
  else
    local RankData = SingleTrainingHandler.get_rank_data(TrainingType, Level)
    if RankData ~= nil then
      SingleTrainingHandler.post_rank_msg(TrainingType, Level, RankData)
    end
  end
end
function SingleTrainingHandler.ClearUserRankData()
  print(bWriteLog and "SingleTrainingHandler.ClearUserRankData")
  SingleTrainingHandler.RequestRanks = {}
end
function SingleTrainingHandler.OnGetOneUserRankRsp(client_data, ok, zoneId, rank_info)
  local RankID = SingleTrainingHandler.RequestRanks[client_data]
  if RankID ~= nil then
    log_tree("SingleTrainingHandler.on_get_one_user_rank_rsp", rank_info)
    if rank_info == nil then
      log(bWriteLog and "SingleTrainingHandler.on_get_one_user_rank_rsp, rank_info is nil")
      return
    end
    local TrainingType, Level = RankDefine:IDToType(RankID)
    local RankData = SingleTrainingHandler.get_or_add_rank_data(TrainingType, Level)
    local RankInfo = RankData.RankInfo
    RankInfo.top1w = rank_info.top1w
    RankInfo.rank_no = rank_info.rank_no
    local ExtraData = rank_info.extra_data
    local PrevRankScore = RankInfo.rank_score
    if PrevRankScore ~= nil then
      local NewRankScore = rank_info.rank_score
      if NewRankScore == nil or PrevRankScore >= NewRankScore then
        RankData.RankStr = SingleTrainingHandler.calc_training_topn_percentage(TrainingType, PrevRankScore, RankInfo.top1w, RankInfo.rank_no)
        SingleTrainingHandler.post_rank_msg(TrainingType, Level, RankData)
        return
      end
    end
    if ExtraData == nil then
      SingleTrainingHandler.UpdateLocalRank(RankID, rank_info.rank_score, nil, nil)
    else
      SingleTrainingHandler.UpdateLocalRank(RankID, rank_info.rank_score, ExtraData.score, ExtraData.game_duration)
    end
  end
end
function SingleTrainingHandler.GetCurrentRankText(TrainingType, Level)
  local RankData = SingleTrainingHandler.get_rank_data(TrainingType, Level)
  if RankData == nil then
    return ""
  end
  return RankData.CurRankStr
end
function SingleTrainingHandler.UpdateLocalRank(RankID, NewRankScore, Score, GameDuration)
  local TrainingType, Level = RankDefine:IDToType(RankID)
  if TrainingType == nil then
    log(bWriteLog and string.format("SingleTrainingHandler.UpdateLocalRank, RankID:{%s} error", tostring(RankID)))
    return
  end
  NewRankScore = NewRankScore or 0
  local RankData = SingleTrainingHandler.get_or_add_rank_data(TrainingType, Level)
  local RankInfo = RankData.RankInfo
  local RankStr = SingleTrainingHandler.calc_training_topn_percentage(TrainingType, NewRankScore, RankInfo.top1w, RankInfo.rank_no)
  local PrevScore = RankInfo.rank_score or 0
  if RankInfo.rank_score == nil or NewRankScore > PrevScore then
    print(bWriteLog and string.format("SingleTrainingHandler.UpdateLocalRank, RankID:{%d}, From:{%s} To {%s}", RankID, tostring(RankInfo.rank_score), tostring(NewRankScore)))
    RankInfo.rank_score = NewRankScore
    RankData.    RankData.BreakHistoricalRecords = NewRankScore > PrevScore
    local tExtraData = RankInfo.extra_data
    if tExtraData == nil then
      tExtraData = {}
      RankInfo.extra_data = tExtraData
    end
    tExtraData.score = Score
    tExtraData.game_duration = GameDuration
  else
    RankData.BreakHistoricalRecords = false
  end
  RankData.Cur  SingleTrainingHandler.post_rank_msg(TrainingType, Level, RankData)
end
function SingleTrainingHandler.CheckCurrentScoreBetter(TrainingType, Level)
  local RankData = SingleTrainingHandler.get_rank_data(TrainingType, Level)
  if RankData and RankData.BreakHistoricalRecords then
    return true
  end
  return false
end
function SingleTrainingHandler.UpdateTrainingRankTest(TrainingType, Level, Top1wScore, Score)
  print(bWriteLog and string.format("UpdateTrainingRankTest:{%d}, {%d}, {%d}, {%d}", TrainingType, Level, Top1wScore, Score))
  if TrainingType < 1 or 4 < TrainingType then
    return
  end
  if Level < 1 or 3 < Level then
    return
  end
  Top1wScore = math.max(0, math.ceil(Top1wScore))
  Score = math.max(0, math.ceil(Score))
  local RankData = SingleTrainingHandler.get_or_add_rank_data(TrainingType, Level)
  RankData.RankInfo = {
    rank_score = Score,
    top1w = Top1wScore,
    extra_data = {__filled = true}
  }
  RankData.RankStr = SingleTrainingHandler.calc_training_topn_percentage(TrainingType, RankData.RankInfo.rank_score, RankData.RankInfo.top1w, RankData.RankInfo.rank_no)
  SingleTrainingHandler.post_rank_msg(TrainingType, Level, RankData)
end
function SingleTrainingHandler.send_single_training_apply_req(respondent_uid, follow_type, from_type)
  log(bWriteLog and "SingleTrainingHandler.send_single_training_apply_req ruid " .. tostring(respondent_uid) .. " follow_type " .. tostring(follow_type) .. " from_type " .. tostring(from_type))
  follow_type = follow_type or 1
  from_type = from_type or 1
  local NetManager = require("client.network.comm.NetManager")
  NetManager.SendPkg(1581758243, respondent_uid, follow_type, from_type)
end
function SingleTrainingHandler.on_single_training_apply_rsp(err_code, respondent_uid, follow_type, from_type)
  log(bWriteLog and "SingleTrainingHandler.on_single_training_apply_rsp err_code " .. tostring(err_code) .. " ruid " .. tostring(respondent_uid) .. " follow_type " .. tostring(follow_type) .. " from_type " .. tostring(from_type))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
end
function SingleTrainingHandler.send_single_training_invite_req(invitee_uid)
  log(bWriteLog and string.format("SingleTrainingHandler.send_single_training_invite_req, invitee_uid:{%d}", invitee_uid))
  local TimeUtil = require("client.common.time_util")
  local lastInviteTime = SingleTrainingHandler.lastInviteTime or 0
  if math.abs(TimeUtil.GetServerTimeInSec() - lastInviteTime) < 2 then
    ShowNotice(10060038)
    return
  end
  local NetManager = require("client.network.comm.NetManager")
  NetManager.SendPkg(841755367, invitee_uid)
  SingleTrainingHandler.lastInviteTime = TimeUtil.GetServerTimeInSec()
end
function SingleTrainingHandler.on_single_training_invite_rsp(err_code, uid, invitee_uid)
  log(bWriteLog and "SingleTrainingHandler.on_single_training_invite_rsp err_code " .. tostring(err_code) .. " uid " .. tostring(uid) .. " invitee_uid " .. tostring(invitee_uid))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  else
    ShowNotice(301265)
  end
end
function SingleTrainingHandler.on_single_training_invite_notify(inviter_uid, single_training_info)
  log(bWriteLog and "SingleTrainingHandler.on_single_training_invite_notify inviter_uid " .. tostring(inviter_uid))
  log_tree("SingleTrainingHandler.on_single_training_invite_notify single_training_info = ", single_training_info)
  local ignoreTime = SingleTrainingHandler.ignoreInviteMap[inviter_uid]
  if ignoreTime then
    local TimeUtil = require("client.common.time_util")
    local tNow = TimeUtil.GetServerTimeInSec()
    if tNow - ignoreTime <= SingleTrainingHandler.ignoreMaxTime then
      log(bWriteLog and "SingleTrainingHandler ignore invite " .. tostring(inviter_uid))
      return
    end
  end
  SingleTrainingHandler.  SingleTrainingHandler.  UIManager.ShowUI(UIManager.UI_Config.SingleTraining_Invite_Notify_UIBP, single_training_info)
end
function SingleTrainingHandler.send_single_training_enter_req(single_training_info)
  log(bWriteLog and string.format("SingleTrainingHandler.send_single_training_enter_req"))
  log_tree("SingleTrainingHandler.send_single_training_enter_req single_training_info = ", single_training_info)
  local NetManager = require("client.network.comm.NetManager")
  NetManager.SendPkg(929960003, single_training_info)
end
function SingleTrainingHandler.on_single_training_enter_rsp(err_code, from_type)
  log(bWriteLog and "SingleTrainingHandler.on_single_training_enter_rsp err_code " .. tostring(err_code) .. " from_type " .. tostring(from_type))
  if err_code ~= 0 then
    ShowNotice(err_code)
    return
  end
end
return SingleTrainingHandler