local NewDayTaskSystem = {
  Mission_NotFinish = 0,
  Mission_Finished = 1,
  Mission_HasGet = 2,
  Mission_List = {},
  UnfinishedDailyTaskNum = 0,
  UpdateInfoTime = 0,
  ImmFinish_Item_Num = 0,
  Active_Num = 0,
  DailyTasks = {},
  LimitTask = {},
  WeeklyActive = {
    act_id = 1,
    value = 0,
    received = {}
  },
  HasInit = false,
  RefreshCount = 0,
  RefreshLimit = 3,
  AdvertiseTaskType = 33,
  LimitedTimeTaskType = 34,
  nActiveNessItemId = 1018,
  canShowAdvertiseTask = false,
  status = 2,
  drop_id = 0,
  tRspTaskData = {},
  GetDailyTaskDescCache = {}
}
local TableUtil = require("common.table_util")
local ResultTask_Macro = require("GameLua.Mod.BRMod.Client.BattleResult.Task.ResultTask_Macro")
function NewDayTaskSystem.OnLogout()
  NewDayTaskSystem.Mission_List = {}
  NewDayTaskSystem.UnfinishedDailyTaskNum = 0
  NewDayTaskSystem.UpdateInfoTime = 0
  NewDayTaskSystem.ImmFinish_Item_Num = 0
  NewDayTaskSystem.Active_Num = 0
  NewDayTaskSystem.DailyTasks = {}
  NewDayTaskSystem.LimitTask = {}
  NewDayTaskSystem.WeeklyActive = {
    act_id = 1,
    value = 0,
    received = {}
  }
  NewDayTaskSystem.HasInit = false
  NewDayTaskSystem.RefreshCount = 0
  NewDayTaskSystem.RefreshLimit = 3
  NewDayTaskSystem.nActiveNessItemId = 1018
  NewDayTaskSystem.canShowAdvertiseTask = false
  NewDayTaskSystem.status = 2
  NewDayTaskSystem.drop_id = 0
  NewDayTaskSystem.GetDailyTaskDescCache = {}
end
function NewDayTaskSystem.UpdateDayMissionList()
end
function NewDayTaskSystem.GetTaskCardNum()
  local CardId = NewDayTaskSystem.GetTaskCardId()
  local UnknowPassTreasureBoxSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_treasurebox")
  return UnknowPassTreasureBoxSystem.GetItemCount(CardId)
end
function NewDayTaskSystem.GetTaskCardId()
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  local general_task_imm_card_cfg = BasicDataServerTable:GetCacheData(data_config_marco.general_task_imm_card_cfg)
  if not general_task_imm_card_cfg then
    log(bWriteLog and "NewDayTaskSystem.GetTaskCardId no general_task_imm_card_cfg")
    return 0
  end
  local rewards = general_task_imm_card_cfg[tonumber(UnknowPassSystem.Season)]
  if not rewards then
    log(bWriteLog and "NewDayTaskSystem.GetTaskCardId no rewards")
    return 0
  end
  local _, reward = next(rewards)
  return reward and reward.card_res_id or 0
end
function NewDayTaskSystem.GetAllTaskConfig(func)
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  local AllTaskConfig = {
    data_config_marco.general_task_week_diff_cfg_simple,
    data_config_marco.general_task_week_content_cfg,
    data_config_marco.general_task_cond_cfg_simple,
    data_config_marco.general_week_active_award_cfg,
    data_config_marco.general_task_imm_card_cfg
  }
  BasicDataServerTable:BatchGetOrReqData(AllTaskConfig, func)
end
function NewDayTaskSystem.send_general_task_sync_all_req()
  NewDayTaskSystem.GetAllTaskConfig(function(tables)
    local UpassHandle = require("client.network.Protocol.UpassHandle")
    UpassHandle.send_general_task_sync_all_req()
    UpassHandle.send_get_daily_task_ext_reward_info()
  end)
end
function NewDayTaskSystem.GeneralTaskRsp(data)
  NewDayTaskSystem.tRspTaskData = data
  local queue_task_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.queue_task_module)
  local task = {
    module = NewDayTaskSystem,
    funcName = "HandleGeneralTaskData",
    param = NewDayTaskSystem,
    debugInfo = "NewDayTaskSystem",
    protect = true
  }
  queue_task_module:Enqueue(queue_task_module.TaskEnum.Lobby, task)
end
function NewDayTaskSystem.HandleGeneralTaskData()
  NewDayTaskSystem.on_general_task_sync_all_rsp(NewDayTaskSystem.tRspTaskData)
  local UnknowPassMissionSystem = require("client.slua.logic.unknow_pass.logic_unknowpass_mission")
  UnknowPassMissionSystem.HandleWeekServerData(NewDayTaskSystem.tRspTaskData)
  UnknowPassMissionSystem.OnInfoUpdate()
  local LogicUGCTask = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_task)
  if LogicUGCTask then
    LogicUGCTask:on_general_task_sync_all_rsp(NewDayTaskSystem.tRspTaskData)
  end
end
function NewDayTaskSystem.on_general_task_sync_all_rsp(data)
  NewDayTaskSystem.ConvertData(data)
  NewDayTaskSystem.HasInit = true
  EventSystem:postEvent(EVENTTYPE_TASK, EVENTID_NEW_DAY_TASK_SYNC)
end
function NewDayTaskSystem.on_general_task_sync_daily_task_change(daily_task)
  log_tree("NewDayTaskSystem.on_general_task_sync_daily_task_change daily_task", daily_task)
  for task_id, task_data in pairs(daily_task) do
    NewDayTaskSystem.ChangeDailyTask(task_id, task_data)
  end
  local TaskMgrSystem = require("client.slua.logic.task.logic_mgr_task")
  TaskMgrSystem.RefreshLobbyTaskRedDot()
  if GameStatus.IsInLobbyOrMainCity() then
    EventSystem:postEvent(EVENTTYPE_TASK, EVENTID_NEW_DAY_TASK_CHANGE)
  end
end
function NewDayTaskSystem.on_general_task_sync_daily_reward_data(result)
  log_tree("NewDayTaskSystem on_general_task_sync_daily_reward_data  result", result)
  local daily_reward = result.daily_reward
  local index = TableUtil.FindTable(NewDayTaskSystem.DailyTasks, function(_, task)
    return task.isLoginAward == true
  end)
  if index == nil then
    return
  end
  local login_task_data = {}
  login_task_data.status = daily_reward.status + 1
  login_task_data.reward_level, login_task_data.rewards = NewDayTaskSystem.GetTaskRewardCfg(daily_reward.reward_id)
  login_task_data.isLoginAward = true
  login_task_data.reward_id = daily_reward.reward_id
  login_task_data.task_type = 0
  login_task_data.finish_value = login_task_data.finish_value or 1
  login_task_data.value = login_task_data.value or 0
  NewDayTaskSystem.DailyTasks[index] = login_task_data
  local TaskMgrSystem = require("client.slua.logic.task.logic_mgr_task")
  TaskMgrSystem.RefreshLobbyTaskRedDot()
  EventSystem:postEvent(EVENTTYPE_TASK, EVENTID_NEW_DAY_TASK_CHANGE)
end
function NewDayTaskSystem.ChangeDailyTask(task_id, task_data)
  if task_id == NewDayTaskSystem.LimitTask.task_id then
    NewDayTaskSystem.LimitTask.value = task_data.value or NewDayTaskSystem.LimitTask.value
    NewDayTaskSystem.LimitTask.status = task_data.value or NewDayTaskSystem.LimitTask.status
    return
  end
  local index = TableUtil.FindTable(NewDayTaskSystem.DailyTasks, function(_, task)
    return task.task_id == task_id
  end)
  if index then
    local task = NewDayTaskSystem.DailyTasks[index]
    if task then
      if task_data.value then
        task.value = task_data.value
      end
      if task_data.status then
        task.status = task_data.status
      end
      local AD_macro = require("client.slua.logic.advertisement.AD_macro")
      if task_id == AD_macro.DALIYTASKID then
        local logic_advertisement_BlueHole = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_advertisement_BlueHole)
        logic_advertisement_BlueHole:SetAdvertisementtTaskData(task)
      end
    end
  end
end
function NewDayTaskSystem.on_general_task_daily_task_imm_rsp(task_id)
  log(bWriteLog and "on_general_task_daily_task_imm_rsp:" .. tostring(task_id))
  local _, task = TableUtil.FindTable(NewDayTaskSystem.DailyTasks, function(_, task)
    return task.task_id == task_id
  end)
  if task_id == NewDayTaskSystem.LimitTask.task_id then
    task = NewDayTaskSystem.LimitTask
  end
  if task then
    task.status = 1
  end
  local TaskMgrSystem = require("client.slua.logic.task.logic_mgr_task")
  TaskMgrSystem.RefreshLobbyTaskRedDot()
  EventSystem:postEvent(EVENTTYPE_TASK, EVENTID_NEW_DAY_TASK_CHANGE)
  EventSystem:postEvent(EVENTTYPE_TASK, EVENTID_NEW_DAY_TASK_IMM, task_id)
end
function NewDayTaskSystem.on_general_weekly_active_sync(data)
  log_tree("NewDayTaskSystem.on_general_weekly_active_sync data", data)
  NewDayTaskSystem.UpdateWeeklyActive(data)
  EventSystem:postEvent(EVENTTYPE_TASK, EVENTID_NEW_DAY_TASK_WEEKLY_ACTIVE, data.value)
end
function NewDayTaskSystem.on_general_weekly_active_award_rsp(award_id)
  log(bWriteLog and "on_general_weekly_active_award_rsp:" .. tostring(award_id))
  if NewDayTaskSystem.WeeklyActive.received then
    local received = NewDayTaskSystem.WeeklyActive.received[award_id]
    if received then
      received.status = 2
      NewDayTaskSystem.ShowReward(received.reward_id)
    end
  end
  EventSystem:postEvent(EVENTTYPE_TASK, EVENTID_NEW_DAY_TASK_WEEKLY_ACTIVE)
end
function NewDayTaskSystem.on_general_task_daily_refresh_rsp(old_task_id, new_task_id, task_data, refresh_count)
  log(bWriteLog and "on_general_task_daily_refresh_rsp:" .. tostring(old_task_id) .. ",new_task_id\239\188\154" .. tostring(new_task_id) .. ",refresh_count:" .. tostring(refresh_count))
  log_tree("on_general_task_daily_refresh_rsp task_data", task_data)
  local old_index = TableUtil.FindTable(NewDayTaskSystem.DailyTasks, function(_, task)
    return task.task_id == old_task_id
  end)
  if old_index then
    NewDayTaskSystem.DailyTasks[old_index] = NewDayTaskSystem.CreateDailyTask(new_task_id, task_data)
  end
  NewDayTaskSystem.RefreshCount = refresh_count
  EventSystem:postEvent(EVENTTYPE_TASK, EVENTID_NEW_DAY_TASK_REFRESH, old_index)
end
function NewDayTaskSystem.on_general_task_daily_login_reward_rsp(ext_err, res_map)
  log(bWriteLog and "on_general_task_daily_login_reward_rsp")
  local _, task = TableUtil.FindTable(NewDayTaskSystem.DailyTasks, function(_, _task)
    return _task.isLoginAward
  end)
  if task then
    task.status = 2
    NewDayTaskSystem.ShowReward(task.reward_id, ext_err, res_map)
    NewDayTaskSystem.SortTask(NewDayTaskSystem.DailyTasks)
    local TaskMgrSystem = require("client.slua.logic.task.logic_mgr_task")
    TaskMgrSystem.RefreshLobbyTaskRedDot()
    EventSystem:postEvent(EVENTTYPE_TASK, EVENTID_NEW_DAY_TASK_CHANGE)
  end
end
function NewDayTaskSystem.ShowReward(reward_id, ext_err, res_map)
  local time_ticker = require("common.time_ticker")
  local timer
  timer = time_ticker.AddTimerLoop(0, function()
    if UIManager.GetUI(UIManager.UI_Config.levelup_panel) then
    else
      local _, rewards = NewDayTaskSystem.GetTaskRewardCfg(reward_id)
      local _rewards = {}
      for i, v in ipairs(rewards) do
        table.insert(_rewards, {
          res_id = v.res_id,
          count = v.res_num,
          valid_hours = v.res_time_limit or 0
        })
      end
      if ext_err == 0 then
        local reqDropID = NewDayTaskSystem.drop_id
        local callback = function(drop_id, dropList)
          if reqDropID == drop_id then
            for k, v in pairs(res_map) do
              if type(v) == "number" then
                table.insert(_rewards, 1, {
                  res_id = k,
                  count = v,
                  isTreasureBox = true
                })
              else
                table.insert(_rewards, 1, {
                  res_id = v.res_id,
                  count = v.count,
                  valid_hours = v.valid_hours,
                  expire_ts = v.expire_ts,
                  isTreasureBox = true
                })
              end
            end
            NewDayTaskSystem.ShowCommonItemGet(_rewards)
          end
        end
        local BasicDataDropTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataDropTable)
        BasicDataDropTable:GetOrReqData(reqDropID, callback)
      end
      if ext_err ~= 0 then
        NewDayTaskSystem.ShowCommonItemGet(_rewards)
      end
      time_ticker.RemoveTimer(timer)
    end
  end, TIMER_INFINITE, 1)
end
function NewDayTaskSystem.ShowCommonItemGet(_rewards)
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  local tExtendData = {
    fCloseCallback = function()
      ModuleManager.GetSplitModuleDownload(ModuleManager.LobbyModuleConfig.CardCollectionPackModule, function(m)
        if m then
          m:ResumeCardPack("DailyTaskReward")
        end
      end)
      local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
      level_unlock_manager:ShowLevelup()
    end
  }
  Logic_CommonItemGet.ShowPanel_DefaultStyle(_rewards, false, true, tExtendData)
end
function NewDayTaskSystem.GetBestRewardedTask(isLoginAward)
  local RewardedTasks = {}
  for _, task in ipairs(NewDayTaskSystem.DailyTasks) do
    if isLoginAward then
      if task.status == 1 and task.isLoginAward then
        table.insert(RewardedTasks, task)
      end
    elseif task.status == 1 and not task.isLoginAward then
      table.insert(RewardedTasks, task)
    end
  end
  if NewDayTaskSystem.LimitTask.status == 1 then
    table.insert(RewardedTasks, NewDayTaskSystem.LimitTask)
  end
  table.sort(RewardedTasks, function(l, r)
    return l.reward_level > r.reward_level
  end)
  return 1 <= #RewardedTasks and RewardedTasks[1] or nil
end
function NewDayTaskSystem.GetAllRewardedTaskItems(isLoginAward)
  local reddotUtil = require("client.slua.logic.reddot.reddot_util")
  local Items = {}
  for _, task in ipairs(NewDayTaskSystem.DailyTasks) do
    if isLoginAward then
      if task.status == 1 and task.isLoginAward then
        for _, v in pairs(task.rewards) do
          local itemCfg = CDataTable.GetTableData("Item", v.res_id)
          if itemCfg then
            local tb = reddotUtil.CreateItem(v.res_id, v.res_num)
            tb.ItemQuality = itemCfg.ItemQuality
            table.insert(Items, tb)
          end
        end
      end
    elseif task.status == 1 and not task.isLoginAward then
      for _, v in pairs(task.rewards) do
        local itemCfg = CDataTable.GetTableData("Item", v.res_id)
        if itemCfg then
          local tb = reddotUtil.CreateItem(v.res_id, v.res_num)
          tb.ItemQuality = itemCfg.ItemQuality
          table.insert(Items, tb)
        end
      end
    end
  end
  if NewDayTaskSystem.LimitTask.status == 1 then
    for _, v in pairs(NewDayTaskSystem.LimitTask.rewards) do
      local itemCfg = CDataTable.GetTableData("Item", v.res_id)
      if itemCfg then
        local tb = reddotUtil.CreateItem(v.res_id, v.res_num)
        tb.ItemQuality = itemCfg.ItemQuality
        table.insert(Items, tb)
      end
    end
  end
  table.sort(Items, function(l, v)
    return l.ItemQuality > v.ItemQuality
  end)
  return Items
end
function NewDayTaskSystem.GetAllRewardedActiveItems()
  local Items = {}
  local reddotUtil = require("client.slua.logic.reddot.reddot_util")
  for _, receive in pairs(NewDayTaskSystem.WeeklyActive.received) do
    if receive.status == 1 then
      for _, v in pairs(receive.rewards) do
        local itemCfg = CDataTable.GetTableData("Item", v.res_id)
        if itemCfg then
          local tb = reddotUtil.CreateItem(v.res_id, v.res_num)
          tb.ItemQuality = itemCfg.ItemQuality
          table.insert(Items, tb)
        end
      end
    end
  end
  table.sort(Items, function(l, v)
    return l.ItemQuality > v.ItemQuality
  end)
  return Items
end
function NewDayTaskSystem.on_general_task_daily_task_reward_rsp(task_id)
  log(bWriteLog and "on_general_task_daily_task_reward_rsp:" .. tostring(task_id))
  local _, task = TableUtil.FindTable(NewDayTaskSystem.DailyTasks, function(_, _task)
    return _task.task_id == task_id
  end)
  if task then
    task.status = 2
    NewDayTaskSystem.ShowReward(task.reward_id)
  end
  NewDayTaskSystem.SortTask(NewDayTaskSystem.DailyTasks)
  local AD_macro = require("client.slua.logic.advertisement.AD_macro")
  if task_id == AD_macro.DALIYTASKID then
    local index = TableUtil.FindTable(NewDayTaskSystem.DailyTasks, function(_, task)
      return task.task_id == task_id
    end)
    if index then
      local task = NewDayTaskSystem.DailyTasks[index]
      local logic_advertisement_BlueHole = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_advertisement_BlueHole)
      logic_advertisement_BlueHole:SetAdvertisementtTaskData(task)
    end
  end
  local TaskMgrSystem = require("client.slua.logic.task.logic_mgr_task")
  TaskMgrSystem.RefreshLobbyTaskRedDot()
  EventSystem:postEvent(EVENTTYPE_TASK, EVENTID_NEW_DAY_TASK_CHANGE)
end
function NewDayTaskSystem.on_get_daily_task_ext_reward_info_res(status, drop_id, ext_reward_res_map)
  NewDayTaskSystem.  NewDayTaskSystem.  if status == 0 and drop_id == 0 then
    NewDayTaskSystem.status = 2
  end
  NewDayTaskSystem.  EventSystem:postEvent(EVENTTYPE_TASK, EVENTID_NEW_DAY_TASK_CHANGE)
end
function NewDayTaskSystem.GetTaskRewardCfg(reward_id)
  local reward_cfg = CDataTable.GetTableData("general_task_reward_cfg", reward_id)
  local rewards = {}
  if reward_cfg then
    for i = 1, 4 do
      local res_id = reward_cfg["res_id" .. i]
      local res_num = reward_cfg["res_num" .. i]
      local res_time_limit = reward_cfg["res_time_limit" .. i]
      if res_id == 0 then
        break
      end
      table.insert(rewards, {
        res_id = res_id,
        res_num = res_num,
              })
    end
  end
  return nil, rewards
end
function NewDayTaskSystem.GetTaskCardCfg(reward_id)
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  local general_task_imm_card_cfg = BasicDataServerTable:GetCacheData(data_config_marco.general_task_imm_card_cfg)
  if not general_task_imm_card_cfg then
    return 1613099, 1
  end
  local rewards = general_task_imm_card_cfg[tonumber(UnknowPassSystem.Season)]
  if not rewards then
    return 1613099, 1
  end
  local reward = rewards[reward_id]
  if not reward then
    return 1613099, 1
  end
  return reward.card_res_id, reward.card_num
end
function NewDayTaskSystem.GetTaskType(task_id)
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  local general_task_cond_cfg_simple = BasicDataServerTable:GetCacheData(data_config_marco.general_task_cond_cfg_simple)
  if not general_task_cond_cfg_simple then
    return 1
  end
  local cfg = general_task_cond_cfg_simple[task_id]
  if not cfg then
    return 1
  end
  return cfg.task_type
end
function NewDayTaskSystem.GetTaskProgress(task_id, progress, addition, Text_type)
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  local general_task_cond_cfg_simple = BasicDataServerTable:GetCacheData(data_config_marco.general_task_cond_cfg_simple)
  if not general_task_cond_cfg_simple then
    return ""
  end
  local cfg = general_task_cond_cfg_simple[task_id]
  if not cfg then
    return ""
  end
  local ProgressText = math.floor(tonumber(progress or 0))
  local finishValue = cfg.finish_value
  if cfg.finish_type == 2 then
    ProgressText = tonumber(progress) >= cfg.finish_value and 1 or 0
    finishValue = 1
  end
  if addition and 0 < addition then
    ProgressText = ProgressText .. "+" .. addition
  end
  local LocID = 7255
  if Text_type then
    if Text_type == 2 then
      LocID = 18185
    end
  else
    LocID = 7255
  end
  return LocUtil.LocalizeResFormat(LocID, ProgressText, finishValue)
end
function NewDayTaskSystem.GetDailyTaskDesc(task_id, finish_value)
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  local general_task_cond_cfg_simple = BasicDataServerTable:GetCacheData(data_config_marco.general_task_cond_cfg_simple)
  if not general_task_cond_cfg_simple then
    return ""
  else
    local cfg = general_task_cond_cfg_simple[task_id]
    if not cfg then
      return ""
    end
    local RPTaskDesc = CDataTable.GetTableData("RPTaskDesc", task_id)
    if not RPTaskDesc then
      return ""
    end
    local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
    local OgriDescID
    if LogicTxMissionMain.IsInXMission() and RPTaskDesc.SubwayDesc and RPTaskDesc.SubwayDesc ~= 0 then
      OgriDescID = RPTaskDesc.SubwayDesc
    else
      OgriDescID = RPTaskDesc.Desc
    end
    local desc = ""
    if RPTaskDesc then
      local sFinishCnt
      local finish = finish_value and tonumber(finish_value) or cfg.finish_value
      sFinishCnt = finish
      if RPTaskDesc.Content == "" and RPTaskDesc.LocalizeContent == 0 then
        desc = LocUtil.LocalizeResFormat(OgriDescID, sFinishCnt)
      elseif RPTaskDesc.Content ~= "" then
        desc = LocUtil.LocalizeResFormat(OgriDescID, RPTaskDesc.Content, sFinishCnt)
      elseif RPTaskDesc.LocalizeContent ~= 0 then
        local content = LocUtil.LocalizeResFormat(RPTaskDesc.LocalizeContent)
        desc = LocUtil.LocalizeResFormat(OgriDescID, content, sFinishCnt)
      end
    end
    NewDayTaskSystem.GetDailyTaskDescCache[task_id] = desc
    return desc
  end
end
function NewDayTaskSystem.IsHideReward(reward_id)
  local reward_cfg = CDataTable.GetTableDataByFilter("general_task_reward_cfg", "reward_id", reward_id)
  if reward_cfg and reward_cfg.ahead_hide and reward_cfg.ahead_hide == ResultTask_Macro.ENUM_HIDE_TYPE.ForeverHide then
    return true
  end
  return false
end
function NewDayTaskSystem.HasRedpoint()
  if NewDayTaskSystem.LimitTask.status == 1 then
    return true
  end
  for _, task in ipairs(NewDayTaskSystem.DailyTasks) do
    if task.status == 1 then
      return true
    end
  end
  for _, receive in ipairs(NewDayTaskSystem.WeeklyActive.received) do
    if receive.status == 1 then
      return true
    end
  end
  return false
end
function NewDayTaskSystem.CheckAdvertiseTask()
  log(bWriteLog and "NewDayTaskSystem.CheckAdvertiseTask")
  NewDayTaskSystem.canShowAdvertiseTask = false
  if BP_Global_AdvertiseNeedShowtask then
    log(bWriteLog and "NewDayTaskSystem.CheckAdvertiseTask 1")
    local AdvertiseSdk = require("client.logic.advertise.logic_advertise_sdk")
    if AdvertiseSdk:IsAdvertiseVaild() then
      log(bWriteLog and "NewDayTaskSystem.CheckAdvertiseTask 2")
      NewDayTaskSystem.canShowAdvertiseTask = true
    end
  end
  log(bWriteLog and "TaskDailySystem.CheckAdvertiseTask : " .. tostring(NewDayTaskSystem.canShowAdvertiseTask))
end
function NewDayTaskSystem.CheckCanShowAdvertiseWhenGet()
  local logic_lobby_google_task = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lobby_google_task)
  local bCanShow = logic_lobby_google_task:CanShow()
  if not bCanShow then
    return false
  end
  for _, taskInfo in pairs(NewDayTaskSystem.DailyTasks) do
    if taskInfo.task_type == NewDayTaskSystem.AdvertiseTaskType and taskInfo.status == 0 then
      log(bWriteLog and "NewDayTaskSystem.CheckCanShowAdvertiseWhenGet 4")
      return true
    end
  end
  log(bWriteLog and "NewDayTaskSystem.CheckCanShowAdvertiseWhenGet 5")
  return false
end
function NewDayTaskSystem.CreateDailyTask(task_id, task_data)
  local daily_task = TableUtil.CopyTable(task_data)
  daily_task.  daily_task.reward_level, daily_task.rewards = NewDayTaskSystem.GetTaskRewardCfg(task_data.reward_id)
  daily_task.card_res_id, daily_task.card_num = NewDayTaskSystem.GetTaskCardCfg(task_data.reward_id)
  daily_task.isLoginAward = false
  daily_task.finish_value = task_data.finish_value or 1
  daily_task.value = task_data.value or 0
  daily_task.task_type = NewDayTaskSystem.GetTaskType(task_id)
  return daily_task
end
function NewDayTaskSystem.UpdateWeeklyActive(weekly_active)
  NewDayTaskSystem.WeeklyActive = {
    act_id = 1,
    value = 0,
    received = {}
  }
  if weekly_active then
    NewDayTaskSystem.WeeklyActive.act_id = weekly_active.act_id
    NewDayTaskSystem.WeeklyActive.value = weekly_active.value
    local received = NewDayTaskSystem.WeeklyActive.received
    local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
    local data_config_marco = require("client.logic.data.data_config_marco")
    local general_week_active_award_cfg = BasicDataServerTable:GetCacheData(data_config_marco.general_week_active_award_cfg)
    if general_week_active_award_cfg then
      local cfg = general_week_active_award_cfg[weekly_active.act_id]
      if cfg then
        for i, v in ipairs(cfg) do
          local reward_level, rewards = NewDayTaskSystem.GetTaskRewardCfg(v.reward_id)
          local data = {
            reward_id = v.reward_id,
            finish_value = v.value,
            reward_level = reward_level,
                      }
          if weekly_active.received and weekly_active.received[i] then
            data.status = 2
          elseif weekly_active.value >= v.value then
            data.status = 1
          else
            data.status = 0
          end
          received[i] = data
        end
        for i = 1, #received do
          if i == 1 then
            received[i].pre_finish_value = 0
          else
            received[i].pre_finish_value = received[i - 1].finish_value
          end
        end
      end
    end
  end
end
function NewDayTaskSystem.ConvertData(data)
  NewDayTaskSystem.CheckAdvertiseTask()
  NewDayTaskSystem.DailyTasks = {}
  local daily_task_refresh = data.daily_task_refresh
  if daily_task_refresh then
    NewDayTaskSystem.RefreshCount = daily_task_refresh.refresh_count or 0
    NewDayTaskSystem.RefreshLimit = daily_task_refresh.refresh_limit or 3
  end
  local logic_lobby_google_task = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lobby_google_task)
  local bCanShowGoogleTask = logic_lobby_google_task:CanShow()
  if data.daily_task then
    local AD_macro = require("client.slua.logic.advertisement.AD_macro")
    local logic_advertisement_BlueHole = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_advertisement_BlueHole)
    if data.daily_task[AD_macro.DALIYTASKID] then
      logic_advertisement_BlueHole:SetAdvertisementtTaskData(data.daily_task[AD_macro.DALIYTASKID])
    else
      log(bWriteLog and "[mxiliu]: data.daily_task[9999] no have")
    end
    for task_id, task_data in pairs(data.daily_task) do
      local daily_task = NewDayTaskSystem.CreateDailyTask(task_id, task_data)
      if daily_task.task_type == NewDayTaskSystem.LimitedTimeTaskType then
        NewDayTaskSystem.LimitTask = daily_task
      else
        if daily_task.task_type ~= NewDayTaskSystem.AdvertiseTaskType or bCanShowGoogleTask then
          table.insert(NewDayTaskSystem.DailyTasks, daily_task)
        end
        if task_id == AD_macro.DALIYTASKID and logic_advertisement_BlueHole:CheckCanGetAdvertisementData() then
          table.insert(NewDayTaskSystem.DailyTasks, daily_task)
        end
      end
    end
    local daily_reward = data.daily_reward
    if daily_reward then
      local login_task_data = {}
      login_task_data.status = daily_reward.status + 1
      login_task_data.reward_level, login_task_data.rewards = NewDayTaskSystem.GetTaskRewardCfg(daily_reward.reward_id)
      login_task_data.isLoginAward = true
      login_task_data.reward_id = daily_reward.reward_id
      login_task_data.task_type = 0
      login_task_data.finish_value = login_task_data.finish_value or 1
      login_task_data.value = login_task_data.value or 0
      table.insert(NewDayTaskSystem.DailyTasks, login_task_data)
    end
    NewDayTaskSystem.SortTask(NewDayTaskSystem.DailyTasks)
  end
  NewDayTaskSystem.UpdateWeeklyActive(data.weekly_active)
end
function NewDayTaskSystem.SortTask(tTasks)
  if not tTasks then
    return
  end
  local GetCompareNum = function(data)
    local Num = 0
    local AD_macro = require("client.slua.logic.advertisement.AD_macro")
    if data.task_id == AD_macro.DALIYTASKID and data.status ~= 2 then
      Num = Num + 50000
    end
    if data.task_type == NewDayTaskSystem.LimitedTimeTaskType then
      Num = Num + 40000
    end
    if data.status == 1 then
      Num = Num + 30000
    end
    if data.status == 0 then
      Num = Num + 20000
    end
    if data.status == 2 then
      Num = Num + 10000
    end
    if data.isLoginAward then
      Num = Num + 5000
    end
    for _, reward in pairs(data.rewards) do
      if reward.res_id == NewDayTaskSystem.nActiveNessItemId then
        Num = Num + reward.res_num * 10
      end
    end
    if data.reward_level then
      Num = Num + data.reward_level
    end
    return Num
  end
  table.sort(tTasks, function(l, r)
    local l_num = GetCompareNum(l)
    local r_num = GetCompareNum(r)
    if l_num == r_num then
      local progress1 = l.value / l.finish_value
      local progress2 = r.value / r.finish_value
      if progress1 == progress2 then
        return l.finish_value < r.finish_value
      else
        return progress1 > progress2
      end
    end
    return l_num > r_num
  end)
end
function NewDayTaskSystem.DirectBuyMissionCard()
  log(bWriteLog and "NewDayTaskSystem.DirectBuyMissionCard - Start processing direct buy mission card")
  local TableUtil = require("common.table_util")
  local TimeUtil = require("client.common.time_util")
  local end_timestamp = TableUtil.GetTableValue(UnknowPassSystem.SeasonInfo, "cfg", "end_timestamp")
  if not end_timestamp or end_timestamp < TimeUtil.GetServerTimeInSec() then
    log(bWriteLog and string.format("NewDayTaskSystem.DirectBuyMissionCard - Season ended or invalid timestamp. end_timestamp: %s", tostring(end_timestamp)))
    ShowNotice(502015)
    return
  end
  local CommonItemBuySystem = require("client.slua.logic.common.logic_common_item_buy")
  local task_card_id = NewDayTaskSystem.GetTaskCardId()
  log(bWriteLog and string.format("NewDayTaskSystem.DirectBuyMissionCard - Showing buy UI for task card. task_card_id: %s", tostring(task_card_id)))
  CommonItemBuySystem.ShowBuyItemUI(task_card_id)
end
return NewDayTaskSystem