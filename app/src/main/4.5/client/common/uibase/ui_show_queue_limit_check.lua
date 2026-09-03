local ui_show_queue_config = require("client.common.uibase.ui_show_queue_config")
local ui_show_queue_server_data = require("client.common.uibase.ui_show_queue_server_data")
local EPlayerType = ui_show_queue_config.EPlayerType
local EPlayerReturnType = ui_show_queue_config.EPlayerReturnType
local ECantAddReason = ui_show_queue_config.ECantAddReason
local ui_show_queue_limit_check = {}
function ui_show_queue_limit_check.CheckIsReturnLimit(lqcUIPlayerTypeConfig)
  local dayFromRegister = FuncUtil.GetRegisterDay()
  local isReturnLimit = false
  local returnLoginCount = 0
  local returnLimitEndTime = 0
  local logic_player_return_login = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_player_return_login)
  local isReturnFirstDay = false
  local returnParam = lqcUIPlayerTypeConfig.ReturnParam and tonumber(lqcUIPlayerTypeConfig.ReturnParam) or 0
  local isReturnPlayerType = lqcUIPlayerTypeConfig.PlayerType == EPlayerType.ShortReturn or lqcUIPlayerTypeConfig.PlayerType == EPlayerType.LongReturn
  local hasReturnData = DataMgr.roleData.back_user_data and DataMgr.roleData.back_user_data.rejoin_start_time and 0 < DataMgr.roleData.back_user_data.rejoin_start_time
  local cantAddReason = ECantAddReason.None
  local resultData = {
    dayFromRegister = FuncUtil.GetRegisterDay(),
    isReturnLimit = isReturnLimit,
    returnType = lqcUIPlayerTypeConfig.ReturnType,
    returnParam = returnParam,
    returnLoginCount = returnLoginCount,
    returnFirstDay = isReturnFirstDay,
    returnLimitEndTime = returnLimitEndTime,
      }
  log_tree("ui_show_queue_limit_check.CheckIsReturnLimit pre resultData = ", resultData)
  if not isReturnPlayerType or not hasReturnData then
    return resultData
  end
  isReturnFirstDay = logic_player_return_login:IsReturnFirstDay()
  local tNow = FuncUtil.GetServerTimeInSec()
  dayFromRegister = (tNow - DataMgr.roleData.back_user_data.rejoin_start_time) / 86400
  if lqcUIPlayerTypeConfig.ReturnType == EPlayerReturnType.FirstDayLimit then
    isReturnLimit = isReturnFirstDay
    returnParam = 1
    returnLoginCount, returnLimitEndTime = logic_player_return_login:GetLoginTotalCountByDay(1)
    cantAddReason = ECantAddReason.ReturnFirstDayLimit
    log_format("ui_show_queue_limit_check.CheckIsReturnLimit FirstDayLimit isReturnLimit = %s, returnLoginCount = %d, returnLimitEndTime = %d", isReturnLimit, returnLoginCount, returnLimitEndTime)
  elseif lqcUIPlayerTypeConfig.ReturnType == EPlayerReturnType.LoginTotalCountLimit then
    returnLoginCount = logic_player_return_login:GetLoginTotalCount()
    isReturnLimit = returnParam >= returnLoginCount
    cantAddReason = ECantAddReason.ReturnLoginTotalCountLimit
    log_format("ui_show_queue_limit_check.CheckIsReturnLimit LoginTotalCountLimit returnLoginCount = %d, returnParam = %d, isReturnLimit = %s", returnLoginCount, returnParam, isReturnLimit)
  elseif lqcUIPlayerTypeConfig.ReturnType == EPlayerReturnType.FirstDayTotalCountLimit and isReturnFirstDay then
    returnLoginCount, returnLimitEndTime = logic_player_return_login:GetLoginTotalCountByDay(1)
    isReturnLimit = returnParam >= returnLoginCount
    cantAddReason = ECantAddReason.ReturnFirstDayTotalCountLimit
    log_format("ui_show_queue_limit_check.CheckIsReturnLimit FirstDayTotalCountLimit returnLoginCount = %d, returnParam = %d, isReturnLimit = %s", returnLoginCount, returnParam, isReturnLimit)
  elseif lqcUIPlayerTypeConfig.ReturnType == EPlayerReturnType.FirstDayOrLoginTotalCountLimit then
    returnLoginCount = logic_player_return_login:GetLoginTotalCount()
    isReturnLimit = isReturnFirstDay or returnParam >= returnLoginCount
    cantAddReason = ECantAddReason.ReturnFirstDayOrLoginTotalCountLimit
    log_format("ui_show_queue_limit_check.CheckIsReturnLimit FirstDayOrLoginTotalCountLimit isReturnFirstDay = %s, returnLoginCount = %d, returnParam = %d, isReturnLimit = %s", isReturnFirstDay, returnLoginCount, returnParam, isReturnLimit)
  end
  resultData.  resultData.  resultData.  resultData.  resultData.  resultData.returnFirstDay = isReturnFirstDay
  resultData.  resultData.  log_tree("ui_show_queue_limit_check.CheckIsReturnLimit after resultData = ", resultData)
  return resultData
end
function ui_show_queue_limit_check.CheckIsShowCountLimit(lqcUIConfig, lqcUIPlayerTypeConfig, returnData)
  local dayFromRegister = returnData.registerDay
  if dayFromRegister <= 0 then
    log_warning(bWriteLog and "ui_show_queue_limit_check.CheckIsShowCountLimit register day = 0")
    return false
  end
  local timeSpanIndex = 0
  for i = 1, 2 do
    local startTime = lqcUIPlayerTypeConfig["TimeSpan" .. i .. "_startTime"]
    local endTime = lqcUIPlayerTypeConfig["TimeSpan" .. i .. "_endTime"]
    if dayFromRegister >= startTime - 1 and dayFromRegister <= endTime - 1 then
      timeSpanIndex = i
      returnData.      returnData.      returnData.      break
    end
  end
  returnData.cantAddReason = ECantAddReason.ShowCountLimit
  if timeSpanIndex == 0 then
    log_warning(bWriteLog and "ui_show_queue_limit_check.CheckIsShowCountLimit no time span\227\128\130dayFromRegister = " .. dayFromRegister)
    return true
  end
  local nCurShowCount = ui_show_queue_server_data.GetCurShowCount(lqcUIConfig.UIKey, timeSpanIndex)
  local limitCount = lqcUIPlayerTypeConfig["ShowCount" .. timeSpanIndex]
  returnData.currentCount = nCurShowCount
  returnData.  if nCurShowCount >= limitCount then
    log(bWriteLog and "ui_show_queue_limit_check.CheckIsShowCountLimit nCurShowCount = " .. nCurShowCount .. ", limitCount = " .. limitCount)
    return true
  end
  ui_show_queue_server_data.SetShowInfo(lqcUIConfig.UIKey, timeSpanIndex, nCurShowCount + 1)
  returnData.cantAddReason = ECantAddReason.None
  return false
end
return ui_show_queue_limit_check