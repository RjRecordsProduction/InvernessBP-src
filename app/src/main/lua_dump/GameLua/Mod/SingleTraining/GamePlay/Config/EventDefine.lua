local EventConfig = {}
function EventConfig.Init(InitFunction)
  local bShipping = Client and Client.IsShipping()
  local _ENV = {}
  InitFunction(bShipping, _ENV)
  _ENV.EVENTTYPE_SINGLE_TRAIN = nil
  _ENV.EVENTID_SINGLE_SHOOTING_BEGIN = nil
  _ENV.EVENTID_SINGLE_TRAIN_THROW_BOMB_START = nil
  _ENV.EVENTID_SINGLE_TRAIN_THROW_BOMB_ON_SCORE_TARGET_HIT = nil
  _ENV.EVENTID_SINGLE_TRAIN_THROW_BOMB_EXIT = nil
  _ENV.EVENTID_SINGLE_TRAIN_AI_TRAIN_EVENT = nil
  _ENV.EVENTID_SINGLE_TRAIN_CLIENT_TLOG = nil
  _ENV.EVENTID_SINGLE_TRAIN_CHANGE_FLOOR_MAT = nil
  _ENV.EVENTID_SINGLE_TRAIN_CURLEVEL = nil
  _ENV.EVENTID_SINGLE_TRAIN_MODEL_TAGET_SHOW = nil
  _ENV.EVENTID_SINGLE_TRAIN_MODEL_TAGET_SHOW_ARROW = nil
  _ENV.EVENTID_SINGLE_TRAIN_STATE_CHANGED = nil
end
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
EventConfig.Init(GamePlayTools.InitEvent)
local ClientToDSRoute = {
  single_training_ai = {
    moduleName = "GameLua.Mod.SingleTraining.Client.AI.SingleTrainingAIClient",
    pbFileName = "single_trianing_ai_train.pb",
    routes = {
      ai_train_start_req = true,
      ai_train_skip_prepare_req = true,
      ai_train_exit_req = true,
      ai_train_finish_count_down_ack = true,
      ai_train_start_ack = "recv_ai_train_start_ack",
      ai_train_update_wave = "recv_ai_train_update_wave",
      ai_train_update_progress = "recv_ai_train_update_progress",
      ai_train_show_fight_result = "recv_ai_train_show_fight_result",
      ai_train_finish_count_down = "recv_ai_train_finish_count_down",
      single_train_update_rank_score = "recv_single_train_update_rank_score"
    }
  },
  single_training_throwBombProtocol = {
    moduleName = "GameLua.Mod.SingleTraining.Client.Bomb.singleTrainingThrowBombLogicClient",
    pbFileName = "single_trianing_bomb.pb",
    routes = {
      bomb_train_req = true,
      bomb_train_rsp = "ServerTrainRsp",
      bomb_train_refresh_wave_notify = "ServerPushRefreshBoss",
      bomb_train_result_notify = "ServerPushBattleResult",
      bomb_train_kill_all_notify = "ServerPushKillAll",
      bomb_train_kill_notify = "ServerPushKillOne",
      bomb_train_end_req = true
    }
  },
  single_train_shooting = {
    moduleName = "GameLua.Mod.SingleTraining.Client.Shooting.SingleTrainingShootClientLogic",
    pbFileName = "shooting_train.pb",
    routes = {
      single_normal_shooting_train_default = true,
      single_shooting_train_update_wave = "UpdateWave",
      single_shooting_train_req_wave = true,
      single_shooting_target_dead = "HandleTargetDead",
      single_normal_shooting_train_custom = true,
      single_normal_shooting_train_end = "HandleNormalResult",
      single_reaction_shooting_train_default = true,
      single_shooting_train_knock_all_target = "HandleKnockAllTargets",
      single_reaction_shooting_train_custom = true,
      single_reaction_shooting_train_end = "HandleReactionResult",
      single_shooting_req_cancel = true,
      single_shooting_rep_cancel_success = "HandleCancelSuccess"
    }
  }
}
local DSToClient = {
  single_training_ai = {
    moduleName = "GameLua.Mod.SingleTraining.DS.AI.SingleTrainingAIDS",
    pbFileName = "single_trianing_ai_train.pb",
    routes = {
      ai_train_start_req = "recv_ai_train_start_req",
      ai_train_skip_prepare_req = "recv_ai_train_skip_prepare_req",
      ai_train_exit_req = "recv_ai_train_exit_req",
      ai_train_finish_count_down_ack = "recv_ai_train_finish_count_down_ack",
      ai_train_start_ack = true,
      ai_train_update_wave = true,
      ai_train_update_progress = true,
      ai_train_show_fight_result = true,
      ai_train_finish_count_down = true,
      single_train_update_rank_score = true
    }
  },
  single_training_throwBombProtocol = {
    moduleName = "GameLua.Mod.SingleTraining.DS.Bomb.SingleTrainThrowBombDS",
    pbFileName = "single_trianing_bomb.pb",
    routes = {
      bomb_train_req = "ClientBattleReq",
      bomb_train_rsp = true,
      bomb_train_refresh_wave_notify = true,
      bomb_train_result_notify = true,
      bomb_train_kill_all_notify = true,
      bomb_train_kill_notify = true,
      bomb_train_end_req = "ClientBattleEndReq"
    }
  },
  single_train_shooting = {
    moduleName = "GameLua.Mod.SingleTraining.DS.Shooting.SingleTraningShootingDSLogic",
    pbFileName = "shooting_train.pb",
    routes = {
      single_normal_shooting_train_default = "NormalShootingTrainDefaultBegin",
      single_shooting_train_update_wave = true,
      single_shooting_train_req_wave = "HandleReqWave",
      single_shooting_target_dead = true,
      single_normal_shooting_train_custom = "NormalShootingTrainCustomBegin",
      single_normal_shooting_train_end = true,
      single_reaction_shooting_train_default = "ReactionShootingTrainDefaultBegin",
      single_shooting_train_knock_all_target = true,
      single_reaction_shooting_train_custom = "ReactionShootingTrainCustomBegin",
      single_reaction_shooting_train_end = true,
      single_shooting_rep_cancel_success = true,
      single_shooting_req_cancel = "HandleCancel"
    }
  }
}
if Client then
  return ClientToDSRoute
else
  return DSToClient
end