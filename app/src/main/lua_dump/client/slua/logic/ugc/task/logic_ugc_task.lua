local LogicUGCTask = {}
local NewDayTaskSystem = require("client.slua.logic.task.logic_new_day_task")
local TableUtil = require("common.table_util")
function LogicUGCTask:DefineAndResetData()
  self.DailyTasks = {}
  self.LimitTask = {}
  self.WeeklyActive = {
    act_id = 0,
    value = 0,
    received = {}
  }
  self.RefreshCount = 0
  self.RefreshTime = 0
  self.RefreshLimit = 2
  self.SeasonTasks = {}
end
function LogicUGCTask:RegistEvents()
  log(bWriteLog and "[edward] LogicUGCTask:RegistEvents")
end
function LogicUGCTask:OnLogin(bReLogin)
  log(bWriteLog and "[edward] LogicUGCTask:OnLogin")
end
function LogicUGCTask:OnLogOut()
end
function LogicUGCTask:OnPostSwitchGameStatus(preState, nextState)
end
function LogicUGCTask:ConvertDailyTask(data)
  self.DailyTasks = {}
  self.SeasonTasks = {}
  self.RefreshCount = data.refresh_count or 0
  self.RefreshTime = data.refresh_time
  local logic_lobby_google_task = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lobby_google_task)
  local bCanShowGoogleTask = logic_lobby_google_task:CanShow()
  if data.task_data then
    local AD_macro = require("client.slua.logic.advertisement.AD_macro")
    local logic_advertisement_BlueHole = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_advertisement_BlueHole)
    if data.task_data[AD_macro.DALIYTASKID] then
      logic_advertisement_BlueHole:SetAdvertisementtTaskData(data.task_data[AD_macro.DALIYTASKID])
    else
      log(bWriteLog and "[mxiliu]: data.task_data[9999] no have")
    end
    for task_id, task_data in pairs(data.task_data) do
      local daily_task = NewDayTaskSystem.CreateDailyTask(task_id, task_data)
      daily_task.IsUGC = true
      if daily_task.task_type == NewDayTaskSystem.LimitedTimeTaskType then
        NewDayTaskSystem.LimitTask = daily_task
      else
        if daily_task.task_type ~= NewDayTaskSystem.AdvertiseTaskType or bCanShowGoogleTask then
          table.insert(self.DailyTasks, daily_task)
        end
        if task_id == AD_macro.DALIYTASKID and logic_advertisement_BlueHole:CheckCanGetAdvertisementData() then
          table.insert(self.DailyTasks, daily_task)
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
      table.insert(self.DailyTasks, login_task_data)
    end
    self:SortTask(self.DailyTasks)
    self:SetSeasonTasks()
  end
end
function LogicUGCTask:SetSeasonTasks()
  local tasksToRemove = {}
  if not self.DailyTasks and not next(self.DailyTasks) then
    log(bWriteLog and "[v_yibxu]  LogicUGCTask:SetSeasonTasks self.DailyTasks = nil ")
    return
  end
  for key, value in pairs(self.DailyTasks) do
    if value.is_ugc_season_task then
      table.insert(self.SeasonTasks, value)
      table.insert(tasksToRemove, key)
    end
  end
  if 0 < #tasksToRemove then
    for i = #tasksToRemove, 1, -1 do
      table.remove(self.DailyTasks, tasksToRemove[i])
    end
  end
  table.sort(self.SeasonTasks, function(l, r)
    return l.task_id > r.task_id
  end)
  log_tree("[v_yibxu] LogicUGCTask:SetSeasonTasks self.SeasonTasks = ", self.SeasonTasks)
end
function LogicUGCTask:UpdateWeeklyActive(weekly_active)
  if weekly_active then
    self.WeeklyActive.act_id = weekly_active.act_id
    self.WeeklyActive.value = weekly_active.value
    local received = self.WeeklyActive.received
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
function LogicUGCTask:on_general_task_sync_all_rsp(data)
  self:on_ugc_daily_task_get_task_data_rsp(data.ugc_daily_task)
  self:on_ugc_weekly_active_sync(data.ugc_weekly_activeness)
end
function LogicUGCTask:on_ugc_weekly_active_award_rsp(award_id)
  if self.WeeklyActive.received then
    local received = self.WeeklyActive.received[award_id]
    if received then
      received.status = 2
      NewDayTaskSystem.ShowReward(received.reward_id)
    end
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_WEEKLY_ACTIVE_UPDATE)
end
function LogicUGCTask:on_ugc_daily_task_get_task_data_rsp(task_data)
  if not task_data then
    return
  end
  self:ConvertDailyTask(task_data)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_DAY_TASK_SYNC)
end
function LogicUGCTask:on_ugc_daily_task_refresh_rsp(task_id, new_task_id, new_task_info, refresh_count)
  local old_index = TableUtil.FindTable(self.DailyTasks, function(_, task)
    return task.task_id == task_id
  end)
  if old_index then
    local daily_task = NewDayTaskSystem.CreateDailyTask(new_task_id, new_task_info)
    daily_task.IsUGC = true
    self.DailyTasks[old_index] = daily_task
  end
  self.RefreshCount = refresh_count
  EventSystem:postEvent(EVENTTYPE_TASK, EVENTID_NEW_DAY_TASK_REFRESH, old_index)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_DAY_TASK_SYNC)
end
function LogicUGCTask:on_ugc_daily_task_complete_imm_rsp(task_id)
  local _, task = TableUtil.FindTable(self.DailyTasks, function(_, task)
    return task.task_id == task_id
  end)
  if task then
    task.status = 1
  end
  EventSystem:postEvent(EVENTTYPE_TASK, EVENTID_NEW_DAY_TASK_CHANGE)
  EventSystem:postEvent(EVENTTYPE_TASK, EVENTID_NEW_DAY_TASK_IMM, task_id)
end
function LogicUGCTask:on_ugc_daily_task_get_award_rsp(task_id, task_data)
  local _, task = TableUtil.FindTable(self.DailyTasks, function(_, _task)
    return _task.task_id == task_id
  end)
  if task then
    task.status = 2
    NewDayTaskSystem.ShowReward(task.reward_id)
  end
  self:SortTask(self.DailyTasks)
  local AD_macro = require("client.slua.logic.advertisement.AD_macro")
  if task_id == AD_macro.DALIYTASKID then
    local index = TableUtil.FindTable(self.DailyTasks, function(_, task)
      return task.task_id == task_id
    end)
    if index then
      local task = self.DailyTasks[index]
      local logic_advertisement_BlueHole = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_advertisement_BlueHole)
      logic_advertisement_BlueHole:SetAdvertisementtTaskData(task)
    end
  end
  EventSystem:postEvent(EVENTTYPE_TASK, EVENTID_NEW_DAY_TASK_CHANGE)
end
function LogicUGCTask:on_ugc_weekly_active_sync(task_data)
  if not task_data then
    return
  end
  self:UpdateWeeklyActive(task_data)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_WEEKLY_ACTIVE_UPDATE)
end
function LogicUGCTask:on_ugc_daily_task_sync(task_data)
  self:on_ugc_daily_task_get_task_data_rsp(task_data)
end
function LogicUGCTask:SortTask(tTasks)
  if not tTasks then
    return
  end
  local GetCompareNum = function(data)
    local Num = 0
    if data.status == 1 then
      Num = Num + 30000
    end
    if data.status == 0 then
      Num = Num + 20000
    end
    if data.status == 2 then
      Num = Num + 10000
    end
    if data.task_pool == 1 then
      Num = Num + 100
    else
      Num = Num + 50
    end
    return Num
  end
  table.sort(tTasks, function(l, r)
    local l_num = GetCompareNum(l)
    local r_num = GetCompareNum(r)
    if l_num == r_num then
      return l.task_id < r.task_id
    end
    return l_num > r_num
  end)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicUGCTask = class(CModuleBase, nil, LogicUGCTask)
return CLogicUGCTask