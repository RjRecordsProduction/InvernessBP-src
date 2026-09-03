local logic_newbie_new_abtest = {}
function logic_newbie_new_abtest:DefineAndResetData()
  self.newbie_new_data = {}
end
function logic_newbie_new_abtest:OnInitialize()
end
function logic_newbie_new_abtest:RegistEvents()
end
function logic_newbie_new_abtest:OnLogin(bReLogin)
  self._groupID = nil
end
function logic_newbie_new_abtest:OnLogOut()
  self._groupID = nil
end
function logic_newbie_new_abtest:CheckUseNewNewbieLogic()
  local endTime = self:GetNewbieEndTime()
  local TimeUtil = require("client.common.time_util")
  if endTime - TimeUtil.GetServerTimeInSec() < 0 then
    log(bWriteLog and "logic_newbie_new_abtest:CheckUseNewNewbieLogic return in time end , curTime is " .. tostring(TimeUtil.GetServerTimeInSec()))
    return false
  end
  local ENewLogicNewbieABTestType = require("GameLua.Mod.MainCity.Client.logic.NewbieGuide.Config.newbie_guide_config").ENewLogicNewbieABTestType
  local LobbySystem = require("client.logic.login.logic_lobby")
  log(bWriteLog and "logic_newbie_new_abtest:CheckUseNewNewbieLogic newbie_rebuild_abtest_group is " .. tostring(LobbySystem.roleData.newbie_rebuild_abtest_group))
  if LobbySystem.roleData.newbie_rebuild_abtest_group and LobbySystem.roleData.newbie_rebuild_abtest_group == ENewLogicNewbieABTestType.Type_A then
    log(bWriteLog and "logic_newbie_new_abtest:CheckUseNewNewbieLogic use new logic way 1")
    return true
  end
  log(bWriteLog and "logic_newbie_new_abtest:CheckUseNewNewbieLogic newbie_abtest_group is " .. tostring(LobbySystem.roleData.newbie_abtest_group) .. " is_new_newbie_logic is " .. tostring(LobbySystem.roleData.is_new_newbie_logic))
  if LobbySystem.roleData.is_new_newbie_logic then
    log(bWriteLog and "logic_newbie_new_abtest:CheckUseNewNewbieLogic use new logic way 2")
    return true
  end
  return false
end
function logic_newbie_new_abtest:GetNewbieEndTime()
  local nRegisterTime = DataMgr.registertime or 0
  local TimeUtil = require("client.common.time_util")
  if nRegisterTime == 0 or nRegisterTime > TimeUtil.GetServerTimeInSec() then
    log_warning(bWriteLog and "logic_newbie_new_abtest:GetNewbieEndTime. register time is over current time")
    return 0
  end
  log_format(bWriteLog and "logic_newbie_new_abtest:GetNewbieEndTime nRegisterTime = %s ", nRegisterTime)
  local totalTime = 1209599
  local tDateTable = TimeUtil.GetDateByUnixTime(nRegisterTime)
  if next(tDateTable) then
    nRegisterTime = nRegisterTime - tDateTable.hour * 3600 - tDateTable.min * 60 - tDateTable.sec
  end
  return totalTime + nRegisterTime
end
function logic_newbie_new_abtest:CheckUseNewbieOptLogic()
  local ENewLogicNewbieABTestType = require("GameLua.Mod.MainCity.Client.logic.NewbieGuide.Config.newbie_guide_config").ENewLogicNewbieABTestType
  local LobbySystem = require("client.logic.login.logic_lobby")
  log(bWriteLog and "logic_newbie_new_abtest:CheckUseNewNewbieLogic newbie_rebuild_abtest_group is " .. tostring(LobbySystem.roleData.newbie_rebuild_abtest_group))
  if LobbySystem.roleData.newbie_rebuild_abtest_group and LobbySystem.roleData.newbie_rebuild_abtest_group == ENewLogicNewbieABTestType.Type_C then
    return true
  end
  return false
end
function logic_newbie_new_abtest:ShowNewbieAward(awards)
  local allData = {}
  if not awards or not next(awards) then
    return
  end
  for _, v in pairs(awards) do
    local data = {
      res_id = v.resid,
      count = v.count,
      valid_hours = v.valid_hours,
      expire_time = 0
    }
    table.insert(allData, data)
  end
  local CommonItemGet_Const = require("client.slua.logic.common.CommonItemGet.CommonItemGet_Const")
  local Logic_CommonItemGet = require("client.slua.logic.common.CommonItemGet.Logic_CommonItemGet")
  local tShowConfig = {
    nItemListStyle = CommonItemGet_Const.Enum_ItemListStyle.Default,
    bCheckSpecialItem = false,
    fCloseCallback = function()
      EventSystem:postEvent(EVENTTYPE_NEW_NEWBIE, EVENTID_NEW_NEWBIE_CHECK_SHOW_OPTIONS_REWARD)
    end
  }
  Logic_CommonItemGet.ShowPanel_FullCustom(allData, tShowConfig)
end
function logic_newbie_new_abtest:GetGroupID()
  return self._groupID
end
function logic_newbie_new_abtest:UpdateNewbieNewData(newbie_new_data)
  self.  EventSystem:postEvent(EVENTTYPE_NEW_NEWBIE, EVENTID_NEW_NEWBIE_UPDATE_ALL_INFO)
end
function logic_newbie_new_abtest:UpdateNewbieNewDataLoginDay(login_day)
  self.newbie_new_data.  EventSystem:postEvent(EVENTTYPE_NEW_NEWBIE, EVENTID_NEW_NEWBIE_LOGIN_DAY_CHANGE)
end
function logic_newbie_new_abtest:UpdateNewbieNewDataTaskData(task_id)
  if not self.newbie_new_data.tasks then
    self.newbie_new_data.tasks = {}
  end
  if not self.newbie_new_data.tasks[task_id] then
    self.newbie_new_data.tasks[task_id] = {}
  end
  self.newbie_new_data.tasks[task_id].status = 2
  EventSystem:postEvent(EVENTTYPE_NEW_NEWBIE, EVENTID_NEW_NEWBIE_TASK_UPDATE_REWARD)
  local NewbieNewLogicHandle = require("client.network.Protocol.NewbieNewLogicHandle")
  NewbieNewLogicHandle.send_newbie_new_info_req()
end
function logic_newbie_new_abtest:UpdateNewbieNewDataLevelData(level)
  self.newbie_new_data.upgrade_awards[level] = true
  EventSystem:postEvent(EVENTTYPE_NEW_NEWBIE, EVENTID_NEW_NEWBIE_UPGRADE_DATA)
end
function logic_newbie_new_abtest:UpdateNewbieNewDataLoginData(day)
  self.newbie_new_data.daily_login_awards[day] = true
  EventSystem:postEvent(EVENTTYPE_NEW_NEWBIE, EVENTID_NEW_NEWBIE_DAILY_LOGIN_DAY)
end
function logic_newbie_new_abtest:UpdateNewbieNewDataPointData(point)
  self.newbie_new_data.points_awards[point] = true
  EventSystem:postEvent(EVENTTYPE_NEW_NEWBIE, EVENTID_NEW_NEWBIE_POINTS_UPDATE_SCORE)
end
function logic_newbie_new_abtest:UpdateActivityCount(rating_protect_cnt, rating_adtnl_cnt)
  if rating_protect_cnt then
    self.segmentProtectionTimes = rating_protect_cnt
  end
  if rating_adtnl_cnt then
    self.segmentAddScoreTimes = rating_adtnl_cnt
  end
  EventSystem:postEvent(EVENTTYPE_TASK, EVENTID_TASK_NEWBIE_UPDATE_RATING_PROTECT_INFO)
end
function logic_newbie_new_abtest:LoadConfig(group_id)
  if self:CheckUseNewNewbieLogic() then
    local logic_newbie_reward = require("client.slua.logic.activity.newbie.logic_newbie_reward")
    logic_newbie_reward.LoadConfig(group_id)
    local logic_newbie_reward_level_sprint = require("client.slua.logic.activity.newbie.logic_newbie_reward_level_sprint")
    logic_newbie_reward_level_sprint.LoadConfig(group_id)
    local logic_newbie_reward_eight_day = require("client.slua.logic.activity.newbie.logic_newbie_reward_eight_day")
    logic_newbie_reward_eight_day.LoadConfig(group_id)
  else
    log(bWriteLog and "logic_newbie_new_abtest:LoadConfig not use new newbie logic ")
  end
end
function logic_newbie_new_abtest:GetNewbieNewDataPoints()
  return self.newbie_new_data.points or 1
end
function logic_newbie_new_abtest:GetNewbieNewDataTaskData()
  local taskData = self.newbie_new_data and self.newbie_new_data.tasks or {}
  return taskData
end
function logic_newbie_new_abtest:GetNewbieNewDataPointData()
  local pointData = self.newbie_new_data and self.newbie_new_data.points_awards or {}
  return pointData
end
function logic_newbie_new_abtest:GetNewbieNewDataLoginData()
  local loginData = self.newbie_new_data and self.newbie_new_data.daily_login_awards or {}
  return loginData
end
function logic_newbie_new_abtest:GetNewbieNewDataUpgradeData()
  local upgradeData = self.newbie_new_data and self.newbie_new_data.upgrade_awards or {}
  return upgradeData
end
function logic_newbie_new_abtest:GetNewbieNewDataLoginDay()
  return self.newbie_new_data.login_day or 0
end
function logic_newbie_new_abtest:GetNewbieNewDataPrivilegesData()
  return self.segmentProtectionTimes or 0, self.segmentAddScoreTimes or 0
end
function logic_newbie_new_abtest:GetNewbieNewData()
  return self.newbie_new_data
end
function logic_newbie_new_abtest:on_send_newbie_task_reward_req(taskId)
  local NewbieNewLogicHandle = require("client.network.Protocol.NewbieNewLogicHandle")
  NewbieNewLogicHandle.send_newbie_task_reward_req(taskId)
end
function logic_newbie_new_abtest:on_send_newbie_upgrade_reward_req(level)
  local NewbieNewLogicHandle = require("client.network.Protocol.NewbieNewLogicHandle")
  NewbieNewLogicHandle.send_newbie_upgrade_reward_req(level)
end
function logic_newbie_new_abtest:on_send_newbie_login_reward_req(day, award_idx)
  local NewbieNewLogicHandle = require("client.network.Protocol.NewbieNewLogicHandle")
  NewbieNewLogicHandle.send_newbie_login_reward_req(day, award_idx)
end
function logic_newbie_new_abtest:on_send_newbie_points_reward_req(points_id, award_idx)
  local NewbieNewLogicHandle = require("client.network.Protocol.NewbieNewLogicHandle")
  NewbieNewLogicHandle.send_newbie_points_reward_req(points_id, award_idx)
end
function logic_newbie_new_abtest:on_send_newbie_reward_all_task_and_points_req()
  local NewbieNewLogicHandle = require("client.network.Protocol.NewbieNewLogicHandle")
  NewbieNewLogicHandle.send_newbie_reward_all_task_and_points_req()
end
function logic_newbie_new_abtest:on_send_newbie_new_info_req()
  local NewbieNewLogicHandle = require("client.network.Protocol.NewbieNewLogicHandle")
  NewbieNewLogicHandle.send_newbie_new_info_req()
end
function logic_newbie_new_abtest:send_newbie_rating_protect_info_req()
  local NewbieTaskHandler = require("client.network.Protocol.NewbieTaskHandler")
  NewbieTaskHandler.send_newbie_rating_protect_info_req()
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_newbie_new_abtest = class(CModuleBase, nil, logic_newbie_new_abtest)
return Clogic_newbie_new_abtest