local logic_return_activity_utils = {}
local C_OneDaySecondsTime = 86400
local _GetActTime = function()
  local TableUtil = require("common.table_util")
  local lifeTime = TableUtil.GetTableValue(DataMgr.roleData, "back_user_data", "dynamic_life_time")
  return lifeTime or 0
end
function logic_return_activity_utils.GetTimeEndTime()
  local actDayTime = _GetActTime()
  return logic_return_activity_utils.GetTime(actDayTime)
end
function logic_return_activity_utils.GetTime(n)
  local TableUtil = require("common.table_util")
  local rejoinStartTime = TableUtil.GetTableValue(DataMgr.roleData, "back_user_data", "rejoin_start_time")
  n = math.min(n, _GetActTime())
  n = math.max(n, 0)
  local endTime = 0
  if rejoinStartTime then
    endTime = rejoinStartTime + n * C_OneDaySecondsTime
  end
  return endTime
end
function logic_return_activity_utils.GetTimeLimitedPrivilegeEndTime()
  local TableUtil = require("common.table_util")
  local rejoinStartTime = TableUtil.GetTableValue(DataMgr.roleData, "back_user_data", "rejoin_start_time")
  local privilegeExpireDay = TableUtil.GetTableValue(DataMgr.roleData, "back_user_data", "privilege_expire_day")
  local endTime = 0
  if rejoinStartTime and privilegeExpireDay then
    endTime = rejoinStartTime + privilegeExpireDay * C_OneDaySecondsTime
  end
  return endTime
end
function logic_return_activity_utils.GetPlayGameTaskList()
  local logic_player_return = require("client.slua.logic.player_return.logic_player_return")
  local privilegeInfo = logic_player_return.privilege_info
  if not privilegeInfo or not next(privilegeInfo) then
    log(bWriteLog and "[v_wllwu] logic_return_activity_utils.GetPlayGameTaskList privilegeInfo is nil")
    return
  end
  local taskList = {}
  for k, v in pairs(privilegeInfo.task_cfg) do
    v.counts = k
    table.insert(taskList, v)
  end
  if 1 < #taskList then
    table.sort(taskList, function(a, b)
      return a.counts < b.counts
    end)
  end
  return taskList
end
function logic_return_activity_utils.IsTabMenuOpen(menuId, bOnlyClient)
  if bOnlyClient then
    return LobbySystem.CheckOpen(menuId)
  end
  local TableUtil = require("common.table_util")
  local openFlag = TableUtil.GetTableValue(DataMgr.roleData, "back_user_data", "page_info", menuId)
  if openFlag and LobbySystem.CheckOpen(menuId) then
    return true
  end
  return false
end
function logic_return_activity_utils.IsGameRewardOpen()
  local TableUtil = require("common.table_util")
  local taskFlag = TableUtil.GetTableValue(DataMgr.roleData, "back_user_data", "battle_task_plan_id")
  if taskFlag and 0 < taskFlag then
    return true
  end
  return false
end
function logic_return_activity_utils.IsNewActOpen()
  local lifeTime = _GetActTime()
  if lifeTime and 0 < lifeTime then
    log(bWriteLog and "[v_wllwu] logic_return_activity_utils:IsOpen lifeTime = " .. tostring(lifeTime))
    return true
  end
  return false
end
function logic_return_activity_utils.IsActInProgress()
  if not LobbySystem.CheckOpen(BP_ENUM_PLAYER_RETURN_ID) then
    log(bWriteLog and "[v_wllwu] logic_return_activity_utils.IsActInProgres not open")
    return false
  end
  if not logic_return_activity_utils.IsNewActOpen() then
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  local endTime = logic_return_activity_utils.GetTimeEndTime()
  return nowTime < endTime
end
function logic_return_activity_utils.IsActInProgressDay(n)
  if not LobbySystem.CheckOpen(BP_ENUM_PLAYER_RETURN_ID) then
    log(bWriteLog and "[v_wllwu] logic_return_activity_utils.IsActInProgres not open")
    return false
  end
  if not logic_return_activity_utils.IsNewActOpen() then
    return false
  end
  n = math.max(n - 1, 0)
  local targetTime = logic_return_activity_utils.GetTime(n)
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  return TimeUtil.IsSameDay(nowTime, targetTime)
end
return logic_return_activity_utils