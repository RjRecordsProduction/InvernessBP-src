local SignInSystem = {
  nowIndex = 0,
  signType = {
    fives = 5,
    seven = 7,
    nine = 9
  },
  bindType = {
    phone = 0,
    mail = 1,
    guest = 3
  }
}
function SignInSystem.GetSignInData()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local actData = ActivityNewSystem.GetActivity()
  local data
  local id = 0
  for i, v in ipairs(actData) do
    if ActivityNewSystem.IsSignInType(v) and (id == 0 or id > v.ID) then
      id = v.ID
      data = v
      SignInSystem.nowIndex = #data.List
    end
  end
  return data
end
function SignInSystem.ShouldSlapSignIn()
  local data = SignInSystem.GetSignInData()
  if data then
    local ActivityStatus = ActivityProgressStatus
    for i, v in ipairs(data.List) do
      if v.Status == ActivityStatus.Done and i <= SignInSystem.nowIndex then
        return true
      end
    end
  end
  return false
end
function SignInSystem.SlapSignIn(_, __, vars)
  local data = SignInSystem.GetSignInData()
  if not data then
    return
  end
  if data.StartTime and data.EndTime then
    local TimeUtil = require("client.common.time_util")
    local now = TimeUtil.GetServerTimeInSec()
    if now < data.StartTime or now > data.EndTime then
      local beginTimeStr = TimeUtil.FormatTime_YMD(data.StartTime, true)
      local endTimeStr = TimeUtil.FormatTime_YMD(data.EndTime, true)
      local timeTipStr = LocUtil.LocalizeResFormat(7545, beginTimeStr, endTimeStr)
      ShowNotice(timeTipStr)
      return
    end
  end
  if SignInSystem.nowIndex == SignInSystem.signType.fives then
    SignInSystem.nowIndex = SignInSystem.signType.fives
  elseif SignInSystem.nowIndex == SignInSystem.signType.seven then
    SignInSystem.nowIndex = SignInSystem.signType.seven
  elseif SignInSystem.nowIndex == SignInSystem.signType.nine then
    SignInSystem.nowIndex = SignInSystem.signType.nine
  end
  if SignInSystem.nowIndex == 0 then
    return
  end
  local ParamTable
  if vars and vars.IsSlapIn then
    local ui_show_queue_config = require("client.common.uibase.ui_show_queue_config")
    ParamTable = ui_show_queue_config.GetParamTable(nil, "IsSlapUI")
  end
  if SignInSystem.nowIndex == SignInSystem.signType.fives then
    UIManager.ShowUI(UIManager.UI_Config.sign_fives_in_gift, ParamTable)
  elseif SignInSystem.nowIndex == SignInSystem.signType.seven then
    UIManager.ShowUI(UIManager.UI_Config.sign_in_gift, ParamTable)
  else
    UIManager.ShowUI(UIManager.UI_Config.sign_nine_in_gift, ParamTable)
  end
end
return SignInSystem