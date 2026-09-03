local EPlayerReturnType = require("client.common.uibase.ui_show_queue_config").EPlayerReturnType
local EmptySaveLoginData = {
  rejoin_start_time = 0,
  loginList = {}
}
local EmptyLoginListData = {time = 0}
local logic_player_return_login = {}
function logic_player_return_login:DefineAndResetData()
  self:_LoadLocalData()
end
function logic_player_return_login:_SaveLocalData()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(self.localLoginData, PlayerPrefsSystem.ePlayerPrefsType.eReturnPlayerLogin)
end
function logic_player_return_login:_LoadLocalData()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  self.localLoginData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eReturnPlayerLogin) or EmptySaveLoginData
  log_tree("logic_player_return_login:_LoadLocalData. localLoginData = ", self.localLoginData)
end
function logic_player_return_login:OnInitialize()
end
function logic_player_return_login:InitData(back_user_data)
  if not self:CheckIsReturnPlayer(back_user_data) then
    return
  end
  self.questionnaire_activity_id = back_user_data.questionnaire_activity_id
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  if back_user_data.rejoin_start_time and self.localLoginData.rejoin_start_time ~= back_user_data.rejoin_start_time then
    log_format("logic_player_return_login:InitData is new returner. localReturnTime = [%s], nowReturnTime = [%s]", self.localLoginData.rejoin_start_time, back_user_data.rejoin_start_time)
    self.localLoginData.rejoin_start_time = back_user_data.rejoin_start_time
    self.localLoginData.loginList = {}
  end
  local TableUtil = require("common.table_util")
  local data = TableUtil.CopyTable(EmptyLoginListData)
  data.time = nowTime
  table.insert(self.localLoginData.loginList, data)
  self:_SaveLocalData()
end
function logic_player_return_login:IsReturnFirstDay()
  if not self:CheckIsReturnPlayer() then
    return false
  end
  local rejoin_start_time = DataMgr.roleData.back_user_data.rejoin_start_time
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  local ret = TimeUtil.IsSameDay(now, rejoin_start_time)
  log_format("logic_player_return_login:IsReturnFirstDay. ret = [%s], returnTime = [%s], nowTime = [%s]", ret, rejoin_start_time, now)
  return ret
end
function logic_player_return_login:GetLoginTotalCountByDay(day)
  if not self:CheckIsReturnPlayer() or day < 1 then
    return 0
  end
  local remainTime = 86400 - math.fmod(self.localLoginData.rejoin_start_time, 86400)
  local endTime = self.localLoginData.rejoin_start_time + remainTime + (day - 1) * 86400 - 1
  local count = 0
  for _, loginData in ipairs(self.localLoginData.loginList) do
    if loginData.time >= self.localLoginData.rejoin_start_time and endTime >= loginData.time then
      count = count + 1
    end
  end
  return count, endTime
end
function logic_player_return_login:GetLoginTotalCount()
  if not self:CheckIsReturnPlayer() then
    return 0
  end
  local count = 0
  for _, loginData in ipairs(self.localLoginData.loginList) do
    if loginData.time >= self.localLoginData.rejoin_start_time then
      count = count + 1
    end
  end
  return count
end
function logic_player_return_login:GetQuestionnaireActivityId()
  return self.questionnaire_activity_id
end
function logic_player_return_login:CheckIsFirstDayLimit()
  return logic_player_return_login:CheckIsReturnLimit(EPlayerReturnType.FirstDayLimit)
end
function logic_player_return_login:CheckIsLoginTotalCountLimit(count)
  if not count then
    return false
  end
  return logic_player_return_login:CheckIsReturnLimit(EPlayerReturnType.LoginTotalCountLimit, count)
end
function logic_player_return_login:CheckIsFirstDayLoginTotalCountLimit(count)
  if not count then
    return false
  end
  return logic_player_return_login:CheckIsReturnLimit(EPlayerReturnType.FirstDayTotalCountLimit, count)
end
function logic_player_return_login:CheckIsReturnLimit(returnType, param)
  if not self:CheckIsReturnPlayer() then
    return false
  end
  local isReturnLimit = false
  local isReturnFirstDay = self:IsReturnFirstDay()
  if returnType == EPlayerReturnType.FirstDayLimit then
    isReturnLimit = isReturnFirstDay
    log_format("logic_player_return_login:CheckIsReturnLimit FirstDayLimit returnType:%s, isReturnFirstDay:%s", returnType, isReturnFirstDay)
  elseif returnType == EPlayerReturnType.LoginTotalCountLimit then
    local returnLoginCount = self:GetLoginTotalCount()
    isReturnLimit = param >= returnLoginCount
    log_format("logic_player_return_login:CheckIsReturnLimit LoginTotalCountLimit returnType:%s, returnLoginCount:%s, param:%s", returnType, returnLoginCount, param)
  elseif returnType == EPlayerReturnType.FirstDayTotalCountLimit and isReturnFirstDay then
    local returnLoginCount = logic_player_return_login:GetLoginTotalCountByDay(1)
    isReturnLimit = param >= returnLoginCount
    log_format("logic_player_return_login:CheckIsReturnLimit FirstDayTotalCountLimit returnType:%s, returnLoginCount:%s, param:%s", returnType, returnLoginCount, param)
  elseif returnType == EPlayerReturnType.FirstDayOrLoginTotalCountLimit then
    local returnLoginCount = self:GetLoginTotalCount()
    isReturnLimit = isReturnFirstDay or param >= returnLoginCount
    log_format("logic_player_return_login:CheckIsReturnLimit FirstDayOrLoginTotalCountLimit returnType:%s, isReturnFirstDay:%s, returnLoginCount:%s, param:%s", returnType, isReturnFirstDay, returnLoginCount, param)
  end
  log(bWriteLog and "logic_player_return_login:CheckIsReturnLimit isReturnLimit = " .. tostring(isReturnLimit))
  return isReturnLimit
end
function logic_player_return_login:CheckIsReturnPlayer(back_user_data)
  back_user_data = back_user_data or DataMgr.roleData.back_user_data
  local isReturnPlayer = back_user_data and back_user_data.rejoin_start_time and back_user_data.rejoin_start_time > 0
  return isReturnPlayer
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_player_return_login = class(CModuleBase, nil, logic_player_return_login)
return Clogic_player_return_login