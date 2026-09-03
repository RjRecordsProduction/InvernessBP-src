local RPCrtScoreSystem = {
  EScoreStatus = {
    CAN_RECEIVE_INIT = 0,
    CAN_RECEIVE_TOTAL = 1,
    RECEIVED_TOAL_SCORE = 2
  },
  ETaskStatus = {
    NotFinish = 0,
    Finished = 1,
    Awarded = 2,
    Expired = 3
  },
  EPayType = {Free = 0, Money = 1},
  CfgData = {},
  TaskList = {},
  CurTotalScore = 0,
  CurScoreStatus = 0,
  IsScoreLimit = false,
  CurCrtCount = 0,
  FakeBarrages = {},
  NeedActiveTasks = {},
  RPScoreResId = 1099,
  CrtFxBound = 35,
  Score2ImgInfo = {
    [1] = {min_score = 0, max_score = 20},
    [2] = {min_score = 21, max_score = 50},
    [3] = {min_score = 51, max_score = 200},
    [4] = {min_score = 201, max_score = 999999}
  },
  NotRecieveIconBgPath = "/Game/UMG/Texture/Lobby_NoAtlas/UnknowPass/RP_integral_crit/RP_integral_Image_typeBg03.RP_integral_Image_typeBg03",
  RecievedIconBgPath = "/Game/UMG/Texture/Lobby_NoAtlas/UnknowPass/RP_integral_crit/RP_integral_Image_typeBg.RP_integral_Image_typeBg",
  CrtAkAudioPath = "/Game/WwiseEvent/UI_hall/RP_General/Play_RP_Bonus.Play_RP_Bonus"
}
local TaskShowPriority = {
  [RPCrtScoreSystem.ETaskStatus.Finished] = 4,
  [RPCrtScoreSystem.ETaskStatus.NotFinish] = 3,
  [RPCrtScoreSystem.ETaskStatus.Awarded] = 2,
  [RPCrtScoreSystem.ETaskStatus.Expired] = 1
}
local TimeUtil = require("client.common.time_util")
local RPCrtTaskSortFunc = function(left, right)
  if TaskShowPriority[left.TaskStatus] ~= TaskShowPriority[right.TaskStatus] then
    return TaskShowPriority[left.TaskStatus] > TaskShowPriority[right.TaskStatus]
  end
  local left_active = RPCrtScoreSystem.NeedActiveTasks[left.TaskId] or 0
  local right_active = RPCrtScoreSystem.NeedActiveTasks[right.TaskId] or 0
  if left_active ~= right_active then
    return left_active < right_active
  end
  return left.TaskId < right.TaskId
end
function RPCrtScoreSystem.InitData()
  EventSystem:registEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_GET_ACT_COLLECTION_PAGEINFO, RPCrtScoreSystem.UpdateRpCrtTimeInfo)
  EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, RPCrtScoreSystem.UpdateRpCrtScoreRedDot)
end
function RPCrtScoreSystem.RefreshLocalCacheData()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cache_info = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eActivityRpCrtScroe) or {}
  local bSaveFlag = false
  local cur_time = TimeUtil.GetServerTimeInSec()
  if cache_info.LastShowTime == nil or not TimeUtil.IsSameDay(cache_info.LastShowTime, cur_time) then
    cache_info.LastShowTime = cur_time
    bSaveFlag = true
  end
  do
    local CfgData = RPCrtScoreSystem.CfgData
    if not (CfgData and CfgData.StartTime and CfgData.EndTime) or not CfgData.ScoreUseSeason then
      cache_info.ShowInitTime = cur_time
    else
      if RPCrtScoreSystem.CurScoreStatus == RPCrtScoreSystem.EScoreStatus.CAN_RECEIVE_INIT then
        local show_init_time = cache_info.ShowInitTime or 0
        if show_init_time >= CfgData.StartTime and show_init_time <= CfgData.EndTime then
          goto lbl_88
        end
        cache_info.ShowInitTime = cur_time
        bSaveFlag = true
        log(bWriteLog and "[jackey]RPCrtScoreSystem.RefreshLocalCacheData->save ShowInitTime: " .. tostring(cur_time))
      end
      if RPCrtScoreSystem.CurScoreStatus == RPCrtScoreSystem.EScoreStatus.CAN_RECEIVE_TOTAL and CfgData.ScoreUseSeason ~= cache_info.TipReceivedSeason then
        cache_info.TipReceivedSeason = CfgData.ScoreUseSeason
        log(bWriteLog and "[jackey]RPCrtScoreSystem.RefreshLocalCacheData->save TipReceivedSeason: " .. tostring(CfgData.ScoreUseSeason))
        bSaveFlag = true
      end
    end
  end
  ::lbl_88::
  if bSaveFlag then
    PlayerPrefsSystem.SaveTableToFile_N(cache_info, PlayerPrefsSystem.ePlayerPrefsType.eActivityRpCrtScroe)
  end
end
function RPCrtScoreSystem.UpdateRpCrtTimeInfo()
  RPCrtScoreSystem.TimeList = {}
  local current_version = Client.GetAppVersion()
  local logic_unknowpass_activity_collection = require("client.slua.logic.unknow_pass.logic_unknowpass_activity_collection")
  local version_util = require("client.common.version_util")
  for _, act_info in pairs(logic_unknowpass_activity_collection.page_info or {}) do
    local min_version = act_info.min_cli_ver or ""
    if not version_util.LowerVersion(current_version, min_version) and act_info.act_type == BP_ENUM_MODULE_RP_CRT_SCORE then
      table.insert(RPCrtScoreSystem.TimeList, {
        open_time = act_info.open_time,
        end_time = act_info.end_time
      })
    end
  end
  log(bWriteLog and "[jackey]->RPCrtScoreSystem.UpdateRpCrtTimeInfo->TimeList: " .. tostring(#RPCrtScoreSystem.TimeList) .. ", current_version: " .. tostring(current_version))
end
function RPCrtScoreSystem.CheckActIsOpen()
  local now = TimeUtil.GetServerTimeInSec()
  for _, time_info in ipairs(RPCrtScoreSystem.TimeList) do
    if now >= time_info.open_time and now < time_info.end_time then
      return true
    end
  end
  return false
end
function RPCrtScoreSystem.UpdateRpCrtScoreRedDot()
  local isShowRedDot = RPCrtScoreSystem.CanShowBannerRedDot()
  log(bWriteLog and "[jackey]RPCrtScoreSystem.UpdateRpCrtScoreRedDot->isShowRedDot:" .. tostring(isShowRedDot))
  local ActivityCenterModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ActivityCenterModule)
  ActivityCenterModule:SetExternalImageRedDot(BP_ENUM_MODULE_RP_CRT_SCORE, true, isShowRedDot)
  LobbySystem.LobbyRedPointUpdate(BP_ENUM_MODULE_RP_CRT_SCORE, isShowRedDot)
  EventSystem:postEvent(EVENTTYPE_RP_CRT_SCORE, EVENTID_RP_CRT_REDDOT_CHANGE_NOTIFY)
end
function RPCrtScoreSystem.CanShowBannerRedDot()
  local EScoreStatus = RPCrtScoreSystem.EScoreStatus
  log(bWriteLog and " RPCrtScoreSystem.CanShowBannerRedDot->CurScoreStatus: " .. tostring(RPCrtScoreSystem.CurScoreStatus))
  if RPCrtScoreSystem.CurScoreStatus == EScoreStatus.CAN_RECEIVE_INIT then
    return true
  end
  if not RPCrtScoreSystem.CheckActIsOpen() then
    log(bWriteLog and "RPCrtScoreSystem.CanShowBannerRedDot->CheckActIsOpen ")
    return false
  end
  local awardList = RPCrtScoreSystem.GetCanReceiveAwards()
  if awardList and next(awardList) then
    log(bWriteLog and "RPCrtScoreSystem.CanShowBannerRedDot->GetCanReceiveAwards")
    return true
  end
  log(bWriteLog and "RPCrtScoreSystem.CanShowBannerRedDot->false")
  return false
end
function RPCrtScoreSystem.ReqRpCrtScoreData()
  log(bWriteLog and "[jackey]RPCrtScoreSystem.ReqRpCrtScoreData")
  local rp_crt_handler = require("client.network.Protocol.RPCrtScoreHandler")
  rp_crt_handler.send_get_rp_crt_score_data_req()
end
function RPCrtScoreSystem.ReqReceiveInitScore()
  local EScoreStatus = RPCrtScoreSystem.EScoreStatus
  if RPCrtScoreSystem.CurScoreStatus and RPCrtScoreSystem.CurScoreStatus ~= EScoreStatus.CAN_RECEIVE_INIT then
    ShowNotice(9940013)
    return
  end
  local cfg_pay_info = RPCrtScoreSystem.CfgData.CfgPayInfo
  if not cfg_pay_info then
    return
  end
  local cost_num = cfg_pay_info[2] or 0
  if 0 < cost_num then
    local reward_init_cb = function()
      if cost_num <= DataMgr.ticket then
        local rp_crt_handler = require("client.network.Protocol.RPCrtScoreHandler")
        rp_crt_handler.send_rp_crt_init_score_req()
      else
        local CommonPayBoxMgr = require("client.slua.logic.common.Payclass.logic_common_pay_box")
        CommonPayBoxMgr.ShowUcRechargeMsg(cost_num)
      end
    end
    local title = LocUtil.GetLocalizeResStr(5077)
    local CfgData = RPCrtScoreSystem.CfgData
    local tips = LocUtil.LocalizeResFormat(21211, cfg_pay_info[2], CfgData.CfgInitScore)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, title, tips, reward_init_cb)
  else
    local rp_crt_handler = require("client.network.Protocol.RPCrtScoreHandler")
    rp_crt_handler.send_rp_crt_init_score_req()
  end
end
function RPCrtScoreSystem.ReqReceiveTotalScore()
  local CfgData = RPCrtScoreSystem.CfgData
  if UnknowPassSystem.Season ~= CfgData.ScoreUseSeason then
    ShowNotice(19941)
    return
  end
  local rp_crt_handler = require("client.network.Protocol.RPCrtScoreHandler")
  if not RPCrtScoreSystem.IsScoreLimit then
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    local title = LocUtil.GetLocalizeResStr(5077)
    local award_totl_score_cb = function()
      rp_crt_handler.send_rp_crt_score_total_award_req()
    end
    local finish_all_task = true
    for _, task_data in pairs(RPCrtScoreSystem.TaskList) do
      if task_data.TaskStatus <= RPCrtScoreSystem.ETaskStatus.Finished then
        finish_all_task = false
        break
      end
    end
    if not finish_all_task then
      local msg = LocUtil.GetLocalizeStrConcatenation(29825)
      CommonMsgBoxMgr.Show(2, title, msg, award_totl_score_cb)
      return
    end
    if RPCrtScoreSystem.CurCrtCount > 0 then
      local msg = LocUtil.GetLocalizeStrConcatenation(29826)
      CommonMsgBoxMgr.Show(2, title, msg, award_totl_score_cb)
      return
    end
  end
  rp_crt_handler.send_rp_crt_score_total_award_req()
end
function RPCrtScoreSystem.ReqCrtScore()
  log(bWriteLog and "[jackey]RPCrtScoreSystem.ReqCrtScore")
  local rp_crt_handler = require("client.network.Protocol.RPCrtScoreHandler")
  rp_crt_handler.send_rp_crt_score_req()
end
function RPCrtScoreSystem.ReqCrtTaskReward(task_id)
  local rp_crt_handler = require("client.network.Protocol.RPCrtScoreHandler")
  rp_crt_handler.send_rp_crt_score_task_award_req(task_id)
end
function RPCrtScoreSystem.UpdateRpCrtScoreData(sync_data)
  if not sync_data then
    log_error("[jackey]RPCrtScoreSystem::UpdateRpCrtScoreData->sync_data is nil")
    return false
  end
  if not sync_data.task_list or not next(sync_data.task_list) then
    log_error("[jackey]RPCrtScoreSystem::UpdateRpCrtScoreData->sync task list error")
    return false
  end
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  local general_task_cond_cfg_simple = BasicDataServerTable:GetCacheData(data_config_marco.general_task_cond_cfg_simple)
  if not general_task_cond_cfg_simple then
    BasicDataServerTable:GetOrReqData(data_config_marco.general_task_cond_cfg_simple, function(_, _general_task_cond_cfg_simple)
      if _general_task_cond_cfg_simple then
        RPCrtScoreSystem.UpdateRpCrtScoreData(sync_data)
        EventSystem:postEvent(EVENTTYPE_RP_CRT_SCORE, EVENTID_RP_CRT_ACTIVITY_DATA)
      end
    end)
    log_error("[jackey]RPCrtScoreSystem::UpdateRpCrtScoreData->get task simple cfg failed!")
    return false
  end
  local sync_cfg_data = sync_data.cfg_data
  local Cfg_Data = RPCrtScoreSystem.CfgData
  Cfg_Data.StartTime = sync_cfg_data.start_time
  Cfg_Data.EndTime = sync_cfg_data.end_time
  Cfg_Data.ScoreUseSeason = sync_cfg_data.use_season_id
  Cfg_Data.CfgInitScore = sync_cfg_data.init_score
  Cfg_Data.InitScoreApproch = sync_cfg_data.init_score_approch
  Cfg_Data.CfgPayInfo = sync_cfg_data.reward_pay_info or {}
  Cfg_Data.CfgBarrageMax = sync_cfg_data.max_barrage_cnt
  Cfg_Data.MaxScore = sync_cfg_data.rp_score_max
  Cfg_Data.BarrageScoreMin = sync_cfg_data.barrage_trigger_score
  RPCrtScoreSystem.NeedActiveTasks = sync_data.need_active_tasks or {}
  local NewDayTaskSystem = require("client.slua.logic.task.logic_new_day_task")
  RPCrtScoreSystem.TaskList = {}
  local TaskList = RPCrtScoreSystem.TaskList
  local table_insert = table.insert
  for task_id, task_data in pairs(sync_data.task_list) do
    local cfg = general_task_cond_cfg_simple[task_id]
    if cfg then
      table_insert(TaskList, {
        TaskId = task_id,
        TaskProgress = task_data.value,
        TaskStatus = task_data.status,
        TaskRewardId = task_data.reward_id,
        FinishProgress = cfg.finish_value,
        TaskDesc = NewDayTaskSystem.GetDailyTaskDesc(task_id)
      })
    else
      log_error("[jackey]RPCrtScoreSystem::UpdateRpCrtScoreData->get task cfg failed! task_id:" .. tostring(task_id))
    end
  end
  table.sort(RPCrtScoreSystem.TaskList, RPCrtTaskSortFunc)
  RPCrtScoreSystem.CurTotalScore = sync_data.total_score
  RPCrtScoreSystem.CurScoreStatus = sync_data.score_status
  RPCrtScoreSystem.IsScoreLimit = sync_data.is_score_limit
  RPCrtScoreSystem.FakeBarrages = sync_data.fake_barrage or {}
  RPCrtScoreSystem.CurCrtCount = sync_data.crt_count
  RPCrtScoreSystem.UpdateRpCrtScoreRedDot()
  return true
end
function RPCrtScoreSystem.SyncTaskChangeInfo(sync_task_list)
  local show_red_point = false
  for task_id, sync_task_data in pairs(sync_task_list) do
    for _, task_info in ipairs(RPCrtScoreSystem.TaskList) do
      if task_info.TaskId == task_id then
        task_info.TaskProgress = sync_task_data.value
        task_info.TaskStatus = sync_task_data.status
        if sync_task_data.status == RPCrtScoreSystem.ETaskStatus.Finished then
          show_red_point = true
        end
      end
    end
  end
  table.sort(RPCrtScoreSystem.TaskList, RPCrtTaskSortFunc)
  if show_red_point then
    local ActivityCenterModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ActivityCenterModule)
    ActivityCenterModule:SetExternalImageRedDot(BP_ENUM_MODULE_RP_CRT_SCORE, true, true)
    LobbySystem.LobbyRedPointUpdate(BP_ENUM_MODULE_RP_CRT_SCORE, true)
    EventSystem:postEvent(EVENTTYPE_RP_CRT_SCORE, EVENTID_RP_CRT_REDDOT_CHANGE_NOTIFY)
  end
end
function RPCrtScoreSystem.UpdateTaskInfo(task_id, task_status, crt_count)
  log(bWriteLog and "[jackey]->RPCrtScoreSystem.UpdateTaskInfo->task_id: " .. tostring(task_id) .. ", task_status: " .. tostring(task_status) .. ", crt_count: " .. tostring(crt_count))
  for _, task_info in ipairs(RPCrtScoreSystem.TaskList) do
    if task_info.TaskId == task_id then
      task_info.TaskStatus = task_status
      break
    end
  end
  table.sort(RPCrtScoreSystem.TaskList, RPCrtTaskSortFunc)
  RPCrtScoreSystem.CurCrtCount = crt_count
  local ActivityCenterModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ActivityCenterModule)
  local isShowRedDot = RPCrtScoreSystem.CanShowBannerRedDot()
  ActivityCenterModule:SetExternalImageRedDot(BP_ENUM_MODULE_RP_CRT_SCORE, true, isShowRedDot)
end
function RPCrtScoreSystem.UpdateCrtInfo(crt_count, total_score, is_score_limit)
  RPCrtScoreSystem.CurTotalScore = total_score
  RPCrtScoreSystem.CurCrtCount = crt_count
  RPCrtScoreSystem.IsScoreLimit = is_score_limit
end
function RPCrtScoreSystem.UpdateScoreInfo(total_score, score_status)
  RPCrtScoreSystem.CurTotalScore = total_score
  RPCrtScoreSystem.CurScoreStatus = score_status
  LobbySystem.roleData.crt_award_tip = nil
end
function RPCrtScoreSystem.ClearNeedActiveTasks()
  RPCrtScoreSystem.NeedActiveTasks = {}
end
function RPCrtScoreSystem.GetCanReceiveAwards()
  local awardList = {}
  if not RPCrtScoreSystem.CheckActIsOpen() then
    log(bWriteLog and "RPCrtScoreSystem.GetCanReceiveAwards->CheckActIsOpen")
    return awardList
  end
  if not RPCrtScoreSystem.TaskList or not next(RPCrtScoreSystem.TaskList) then
    log(bWriteLog and "RPCrtScoreSystem.GetCanReceiveAwards->TaskList is empty")
    return awardList
  end
  local reddotUtil = require("client.slua.logic.reddot.reddot_util")
  local EScoreStatus = RPCrtScoreSystem.EScoreStatus
  local CfgData = RPCrtScoreSystem.CfgData
  if UnknowPassSystem.Season == CfgData.ScoreUseSeason and RPCrtScoreSystem.CurScoreStatus == EScoreStatus.CAN_RECEIVE_TOTAL then
    log(bWriteLog and "RPCrtScoreSystem.GetCanReceiveAwards->UnknowPassSystem.Season == CfgData.ScoreUseSeason and RPCrtScoreSystem.CurScoreStatus == EScoreStatus.CAN_RECEIVE_TOTAL")
    table.insert(awardList, reddotUtil.CreateItem(RPCrtScoreSystem.RPScoreResId, RPCrtScoreSystem.CurTotalScore, 0))
  end
  local reward_res_id = 0
  local reward_res_num = 0
  local ETaskStatus = RPCrtScoreSystem.ETaskStatus
  for _, task_data in pairs(RPCrtScoreSystem.TaskList) do
    if task_data.TaskStatus == ETaskStatus.Finished then
      local res_id, res_num = RPCrtScoreSystem.GetTaskRewardInfo(task_data.TaskId)
      if res_id and res_num then
        reward_        reward_res_num = reward_res_num + res_num
      end
    end
  end
  if 0 < reward_res_id and 0 < reward_res_num then
    log(bWriteLog and "[jackey]RPCrtScoreSystem.GetCanReceiveAwards->reward_res_id:" .. tostring(reward_res_id) .. ",reward_res_num:" .. tostring(reward_res_num))
    table.insert(awardList, reddotUtil.CreateItem(reward_res_id, reward_res_num, 0))
  end
  log(bWriteLog and "[jackey]RPCrtScoreSystem.GetCanReceiveAwards->end->awardList:" .. tostring(#awardList))
  return awardList
end
function RPCrtScoreSystem.GetTaskFinishNum()
  local task_list = RPCrtScoreSystem.TaskList
  local total_task_num = #task_list
  local finish_num = 0
  local ETaskStatus = RPCrtScoreSystem.ETaskStatus
  for _, task_data in pairs(task_list) do
    if task_data.TaskStatus > ETaskStatus.Finished then
      finish_num = finish_num + 1
    end
  end
  return finish_num, total_task_num
end
function RPCrtScoreSystem.GetTaskDataByTaskId(task_id)
  local task_list = RPCrtScoreSystem.TaskList
  for _, task_data in pairs(task_list) do
    if task_data.TaskId == task_id then
      return task_data
    end
  end
end
function RPCrtScoreSystem.GetTaskRewardInfo(task_id)
  local NewDayTaskSystem = require("client.slua.logic.task.logic_new_day_task")
  local task_list = RPCrtScoreSystem.TaskList
  for _, task_data in pairs(task_list) do
    if task_data.TaskId == task_id then
      local reward_level, rewards = NewDayTaskSystem.GetTaskRewardCfg(task_data.TaskRewardId)
      if rewards and rewards[1] then
        return rewards[1].res_id, rewards[1].res_num
      end
    end
  end
end
function RPCrtScoreSystem.UpdateTaskChangeInfo(sync_task_list)
  if not sync_task_list or not next(sync_task_list) then
    return
  end
  if not RPCrtScoreSystem.TaskList or not next(RPCrtScoreSystem.TaskList) then
    return
  end
  for task_id, sync_data in pairs(sync_task_list) do
    local task_data = RPCrtScoreSystem.TaskList[task_id]
    if task_data then
      task_data.TaskProgress = sync_data.value
      task_data.TaskStatus = sync_data.status
    end
  end
end
local err_gentask_task_awarded = 100320003
local err_rp_crt_not_open = 108100001
local err_rp_crt_init_scored_received = 108100002
local err_rp_crt_config_error = 108100003
local err_rp_crt_processing_purchase = 108100004
local err_rp_crt_money_not_enough = 108100005
local err_rp_crt_params_error = 108100006
local err_rp_crt_must_get_init_score = 108100007
local err_rp_crt_cur_score_max = 108100008
local err_rp_crt_total_score_awarded = 108100009
local err_rp_crt_next_season_receive = 108100010
local err_rp_crt_crt_count_not_enough = 108100011
local err_rp_crt_act_game_over = 108100012
function RPCrtScoreSystem.ShowTipsByErrorCode(code)
  log(bWriteLog and "[jackey]RPCrtScoreSystem.ShowTipsByErrorCode->code = " .. tostring(code))
  if code == err_rp_crt_not_open then
    ShowNotice(120106)
  elseif code == err_rp_crt_config_error then
    ShowNotice(9920033)
  elseif code == err_rp_crt_processing_purchase then
    ShowNotice(502057)
  elseif code == err_rp_crt_params_error then
    ShowNotice(108066)
  elseif code == err_rp_crt_init_scored_received then
    ShowNotice(108104)
  elseif code == err_rp_crt_must_get_init_score then
    ShowNotice(19949)
  elseif code == err_rp_crt_cur_score_max then
    if UnknowPassSystem.Season == RPCrtScoreSystem.CfgData.ScoreUseSeason then
      ShowNotice(19942)
    else
      ShowNotice(21254)
    end
  elseif code == err_rp_crt_total_score_awarded then
    ShowNotice(19953)
  elseif code == err_rp_crt_next_season_receive then
    ShowNotice(19941)
  elseif code == err_gentask_task_awarded then
    ShowNotice(100320003)
  elseif code == err_rp_crt_crt_count_not_enough then
    ShowNotice(660020)
  elseif code == err_rp_crt_act_game_over then
    ShowNotice(4002)
  elseif code == err_rp_crt_money_not_enough then
    local CommonPayBoxMgr = require("client.slua.logic.common.Payclass.logic_common_pay_box")
    CommonPayBoxMgr.ShowUcRechargeMsg()
  else
    log_error("RPCrtScoreSystem::ShowTipsByErrorCode->notice failed! code:" .. tostring(code))
  end
end
function RPCrtScoreSystem.OnModePostSwitch(preState, nextState)
  log(bWriteLog and "RPCrtScoreSystem.OnModePostSwitch->nextState: " .. tostring(nextState))
  if nextState == GameStatus.Lobby then
    RPCrtScoreSystem.InitData()
  elseif not GameStatus.IsInLobbyOrMainCity() then
    RPCrtScoreSystem.ResetData()
  end
end
function RPCrtScoreSystem.ResetData()
  RPCrtScoreSystem.CfgData = {}
  RPCrtScoreSystem.TaskList = {}
  RPCrtScoreSystem.CurTotalScore = 0
  RPCrtScoreSystem.CurScoreStatus = 0
  RPCrtScoreSystem.IsScoreLimit = false
  RPCrtScoreSystem.CurCrtCount = 0
  RPCrtScoreSystem.FakeBarrages = {}
  RPCrtScoreSystem.NeedActiveTasks = {}
  RPCrtScoreSystem.TimeList = {}
end
function RPCrtScoreSystem.OnJumpHandler()
  if RPCrtScoreSystem.TimeList and next(RPCrtScoreSystem.TimeList) and not RPCrtScoreSystem.CheckActIsOpen() then
    ShowNotice(4002)
    return
  end
  local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
  if PassDataSystem.ShowRPDownloadTips() then
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.unknowpass_activity_crt_score)
end
return RPCrtScoreSystem