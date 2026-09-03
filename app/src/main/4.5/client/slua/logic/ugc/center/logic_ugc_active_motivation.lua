local config_ugc_commercialization = require("client.slua.umg.ugc.Commercialization.config_ugc_commercialization")
local logic_ugc_active_motivation = {
  SlapState = false,
  AuthorRewardData = {
    total = {reward = 10, HC = 5000},
    task1 = {reward = 2, HC = 500},
    task2 = {reward = 2.5, HC = 1000},
    task3 = {reward = 2.5, HC = 2000},
    task4 = {reward = 3, HC = 5000}
  }
}
function logic_ugc_active_motivation:DefineAndResetData()
  self.ActiveMotivationState = nil
  self.IncentiveProgramOpenLimit = 500
  self.TaskList = {}
  self.NotJoinAwardList = 45343
end
function logic_ugc_active_motivation:OnLogOut()
  log(bWriteLog and "logic_ugc_active_motivation:OnLogOut")
end
function logic_ugc_active_motivation:ClearData()
end
function logic_ugc_active_motivation:send_wow_apply_join_incentive_program_req()
  log(bWriteLog and "logic_ugc_active_motivation:send_ugc_get_creator_wallet_data_req")
  local UGCPassHandler = require("client.network.Protocol.UGCPassHandler")
  UGCPassHandler.send_wow_apply_join_incentive_program_req()
end
function logic_ugc_active_motivation:on_wow_apply_join_incentive_program_rsp(err_code, incentive_program_data)
  log_tree("logic_ugc_active_motivation:on_wow_apply_join_incentive_program_rsp incentive_program_data = ", incentive_program_data)
  local MsgContent, GoBindTip
  local MsgTitle = LocUtil.GetLocalizeResStr(68690)
  if err_code == 0 then
    self.ActiveMotivationState = incentive_program_data.join_state
    DataMgr.roleData.incentive_program_join_state = incentive_program_data.join_state
    self.TaskList = {}
    for ID, data in pairs(incentive_program_data.task_data) do
      table.insert(self.TaskList, {
        TaskID = ID,
        value = data.value,
        status = data.status,
        reward_id = data.reward_id
      })
    end
    local TimeUtil = require("client.common.time_util")
    self.WalletDataTimeStamp = TimeUtil.GetServerTimeInSec()
    if incentive_program_data.join_state == config_ugc_commercialization.C_UGCIncentiveProgramState.JoinSucceed then
      log(bWriteLog and "logic_ugc_active_motivation:on_wow_apply_join_incentive_program_rsp join_state = JoinSucceed")
      EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_DATA_ACTIVEMOTIVATION_RRFRESH)
      return
    elseif incentive_program_data.join_state == config_ugc_commercialization.C_UGCIncentiveProgramState.AuditFailed then
      MsgContent = LocUtil.GetLocalizeResStr(68692)
      GoBindTip = LocUtil.GetLocalizeResStr(68753)
    end
  else
    MsgContent = LocUtil.GetLocalizeResStr(68692)
    GoBindTip = LocUtil.GetLocalizeResStr(68753)
  end
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, MsgTitle, MsgContent, function(bIsCheck)
    if err_code == 0 then
      if incentive_program_data.join_state == config_ugc_commercialization.C_UGCIncentiveProgramState.AuditFailed then
        log(bWriteLog and "logic_ugc_active_motivation:on_wow_apply_join_incentive_program_rsp err_code = 0 ,bIscheck")
        local LogicCustomerService = require("client.slua.logic.CustomerService.LogicCustomerService")
        LogicCustomerService.Open(LogicCustomerService.E_EntranceType.Settings)
      end
    else
      log(bWriteLog and "logic_ugc_active_motivation:on_wow_apply_join_incentive_program_rsp err_code ~= 0 ,bIscheck")
      local LogicCustomerService = require("client.slua.logic.CustomerService.LogicCustomerService")
      LogicCustomerService.Open(LogicCustomerService.E_EntranceType.Settings)
    end
  end, nil, GoBindTip)
end
function logic_ugc_active_motivation:send_wow_query_incentive_program_join_state_req()
  local UGCPassHandler = require("client.network.Protocol.UGCPassHandler")
  UGCPassHandler.send_wow_query_incentive_program_join_state_req()
end
function logic_ugc_active_motivation:on_wow_query_incentive_program_join_state_rsp(join_state)
  log(bWriteLog and "logic_ugc_active_motivation:on_wow_query_incentive_program_join_state_rsp join_state = " .. tostring(join_state))
  self.ActiveMotivationState = join_state
  DataMgr.roleData.incentive_program_  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_DATA_ACTIVEMOTIVATION_JOIN_STATE_RRFRESH)
end
function logic_ugc_active_motivation:send_wow_query_incentive_program_task_data_req()
  local UGCPassHandler = require("client.network.Protocol.UGCPassHandler")
  UGCPassHandler.send_wow_query_incentive_program_task_data_req()
end
function logic_ugc_active_motivation:on_wow_query_incentive_program_task_data_rsp(task_data)
  log(bWriteLog and "logic_ugc_active_motivation:on_wow_query_incentive_program_task_data_rsp")
  self.TaskList = {}
  if not task_data or not next(task_data) then
    self.TaskList = {}
  else
    for ID, data in pairs(task_data) do
      table.insert(self.TaskList, {
        TaskID = ID,
        value = data.value,
        status = data.status,
        reward_id = data.reward_id
      })
    end
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_DATA_ACTIVEMOTIVATION_RRFRESH)
end
function logic_ugc_active_motivation:on_notify_update_wow_incentive_program_data(incentive_program_data)
  log_tree("logic_ugc_active_motivation:on_notify_update_wow_incentive_program_data incentive_program_data = ", incentive_program_data)
  self.ActiveMotivationState = incentive_program_data.join_state
  self.TaskList = {}
  for ID, data in pairs(incentive_program_data.task_data) do
    table.insert(self.TaskList, {
      TaskID = ID,
      value = data.value,
      status = data.status,
      reward_id = data.reward_id
    })
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_DATA_ACTIVEMOTIVATION_RRFRESH)
end
function logic_ugc_active_motivation:send_wow_get_incentive_program_award_req(task_id)
  log(bWriteLog and "logic_ugc_active_motivation:send_wow_get_incentive_program_award_req task_id = " .. tostring(task_id))
  local UGCPassHandler = require("client.network.Protocol.UGCPassHandler")
  UGCPassHandler.send_wow_get_incentive_program_award_req(task_id)
end
function logic_ugc_active_motivation:on_wow_get_incentive_program_award_rsp(task_id, task_data)
  log(bWriteLog and "logic_ugc_active_motivation:on_wow_get_incentive_program_award_rsp")
  local LogicUGCCenter = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_center)
  local AwardList = LogicUGCCenter:GetMissionAwardList(task_id)
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  Logic_CommonItemGet.ShowPanel_DefaultStyle(AwardList)
  self.TaskList = {}
  if not task_data or not next(task_data) then
    self.TaskList = {}
  else
    for ID, data in pairs(task_data) do
      table.insert(self.TaskList, {
        TaskID = ID,
        value = data.value,
        status = data.status,
        reward_id = data.reward_id
      })
    end
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_DATA_ACTIVEMOTIVATION_RRFRESH)
end
function logic_ugc_active_motivation:SetActiveMotivationState(state)
  log(bWriteLog and "logic_ugc_active_motivation:SetActiveMotivationState state = " .. tostring(state))
  self.ActiveMotivationState = state
end
function logic_ugc_active_motivation:GetActiveMotivationState()
  return self.ActiveMotivationState
end
function logic_ugc_active_motivation:SetIncentiveProgramOpenLimit(data)
  if data.IncentiveProgramOpenLimit and tonumber(data.IncentiveProgramOpenLimit) then
    self.IncentiveProgramOpenLimit = tonumber(data.IncentiveProgramOpenLimit) or 500
    log(bWriteLog and "logic_ugc_active_motivation:SetIncentiveProgramOpenLimit self.IncentiveProgramOpenLimit:" .. tostring(self.IncentiveProgramOpenLimit))
  end
  if data.MonthReward and tonumber(data.MonthReward) then
    self.NotJoinAwardList = tonumber(data.MonthReward)
    log_tree("logic_ugc_active_motivation:SetIncentiveProgramOpenLimit self.NotJoinAwardList:", self.NotJoinAwardList)
  end
end
function logic_ugc_active_motivation:GetIncentiveProgramOpenLimit()
  log(bWriteLog and "logic_ugc_active_motivation:GetIncentiveProgramOpenLimit self.IncentiveProgramOpenLimit = " .. tostring(self.IncentiveProgramOpenLimit))
  return self.IncentiveProgramOpenLimit
end
function logic_ugc_active_motivation:GetNotJoinAwardList()
  return self.NotJoinAwardList
end
function logic_ugc_active_motivation:GetTaskList()
  return self.TaskList
end
function logic_ugc_active_motivation:GetNextMonthZeroTime()
  local TimeUtil = require("client.common.time_util")
  local ServerTime = TimeUtil.GetServerTimeInSec()
  local now = TimeUtil.OSDate("!*t", ServerTime)
  local next_month_first = {
    year = now.year,
    month = now.month + 1,
    day = 1,
    hour = 0,
    min = 0,
    sec = 0
  }
  if next_month_first.month > 12 then
    next_month_first.month = 1
    next_month_first.year = next_month_first.year + 1
  end
  local now_timestamp = TimeUtil.OSTime(now)
  local next_month_first_timestamp = TimeUtil.OSTime(next_month_first)
  local diff = next_month_first_timestamp - now_timestamp
  local days = math.floor(diff / 86400)
  local hours = math.floor(diff % 86400 / 3600)
  local minutes = math.floor(diff % 3600 / 60)
  local seconds = diff % 60
  print(bWriteLog and string.format("\232\183\157\231\166\187\228\184\139\228\184\170\230\156\1361\229\143\183\232\191\152\230\156\137: %d\229\164\169 %d\229\176\143\230\151\182 %d\229\136\134\233\146\159 %d\231\167\146", days, hours, minutes, seconds))
  return days, hours
end
function logic_ugc_active_motivation:send_wow_get_incentive_program_revenue_req()
  if self.IncentiveProgramRevenueData then
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_DATA_ACTIVEMOTIVATION_PROGRAM_REVENUE, self.IncentiveProgramRevenueData)
  else
    local UGCPassHandler = require("client.network.Protocol.UGCPassHandler")
    UGCPassHandler.send_wow_get_incentive_program_revenue_req()
  end
end
function logic_ugc_active_motivation:on_wow_get_incentive_program_revenue_rsp(err_code, data)
  self.IncentiveProgramRevenueData = data
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_DATA_ACTIVEMOTIVATION_PROGRAM_REVENUE, self.IncentiveProgramRevenueData)
end
function logic_ugc_active_motivation:send_wow_get_IPR_des_cfg_req()
  if self.IncentiveIPRDesCfg then
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_DATA_ACTIVEMOTIVATION_IPR_CFG, self.IncentiveIPRDesCfg)
  else
    local UGCPassHandler = require("client.network.Protocol.UGCPassHandler")
    UGCPassHandler.send_wow_get_IPR_des_cfg_req()
  end
end
function logic_ugc_active_motivation:on_wow_get_IPR_des_cfg_rsp(err_code, data)
  self.IncentiveIPRDesCfg = data
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_DATA_ACTIVEMOTIVATION_IPR_CFG, self.IncentiveIPRDesCfg)
end
function logic_ugc_active_motivation:GetSlapState()
  return self.SlapState
end
function logic_ugc_active_motivation:SetSlapState()
  self.SlapState = true
end
function logic_ugc_active_motivation:send_wow_get_new_author_inspire_req()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsBLUEHOLE() then
    log(bWriteLog and "logic_ugc_active_motivation:send_wow_get_new_author_inspire_req is BLUEHOLE")
    return
  end
  if self.Incentive_Author_Inspire and next(self.Incentive_Author_Inspire) then
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_DATA_ACTIVEMOTIVATION_AUTHOR_INSPIRE, self.Incentive_Author_Inspire)
  else
    local UGCPassHandler = require("client.network.Protocol.UGCPassHandler")
    UGCPassHandler.send_wow_get_new_author_inspire_req()
  end
  if not self.ClearNewAuthorDataTimer then
    self.ClearNewAuthorDataTimer = self:AddTimerOnce(120, function()
      self.Incentive_Author_Inspire = nil
      self.ClearNewAuthorDataTimer = nil
    end)
  end
end
function logic_ugc_active_motivation:on_wow_get_new_author_inspire_rsp(err_code, data)
  if err_code ~= 0 and err_code ~= 522017 then
    ShowNotice(err_code)
  end
  self.Incentive_Author_Inspire = data
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_DATA_ACTIVEMOTIVATION_AUTHOR_INSPIRE, self.Incentive_Author_Inspire)
end
function logic_ugc_active_motivation:GetIncentiveAuthorInspire()
  return self.Incentive_Author_Inspire
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_ugc_active_motivation = class(CModuleBase, nil, logic_ugc_active_motivation)
return Clogic_ugc_active_motivation