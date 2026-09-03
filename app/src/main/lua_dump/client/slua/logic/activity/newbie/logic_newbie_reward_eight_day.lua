local logic_newbie_reward_eight_day = {
  DayAmount = 8,
  StringID_Name = 430001,
  StringID_DateFormat = 430101,
  TimeStep = 1209599,
  ErrorCode_End = 430104,
  StringNameFormat = "",
  StringDateFormat = ""
}
function logic_newbie_reward_eight_day.IsOpen()
  local logic_newbie_new_abtest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_new_abtest)
  if not logic_newbie_new_abtest:CheckUseNewNewbieLogic() then
    log(bWriteLog and "logic_newbie_reward.IsOpen return not in ABTest new Group")
    return false
  end
  local endTime = logic_newbie_reward_eight_day:GetNewbieEndTime()
  local TimeUtil = require("client.common.time_util")
  if endTime - TimeUtil.GetServerTimeInSec() < 0 then
    log(bWriteLog and "logic_newbie_reward.IsOpen return not in time end")
    return false
  end
  return true
end
function logic_newbie_reward_eight_day.ShowUI()
  local errorCode = logic_newbie_reward_eight_day.GetShowErrorCode()
  if errorCode ~= 0 then
    if errorCode == logic_newbie_reward_eight_day.ErrorCode_End then
      ShowNotice(errorCode)
    end
    return
  end
  local textData = LocUtil.GetLocalizeResStr(logic_newbie_reward_eight_day.StringID_Name)
  if textData ~= nil then
    logic_newbie_reward_eight_day.StringNameFormat = textData
  end
  textData = LocUtil.GetLocalizeResStr(logic_newbie_reward_eight_day.StringID_DateFormat)
  if textData ~= nil then
    logic_newbie_reward_eight_day.StringDateFormat = textData
  end
  UIManager.ShowUI(UIManager.UI_Config.Flap_Newbie_Reward_Eight_Days)
end
function logic_newbie_reward_eight_day.LoadConfig(group_id)
  log(bWriteLog and "logic_newbie_reward_eight_day:LoadConfig group_id is " .. tostring(group_id))
  local NewbieLoginConfig = CDataTable.GetTable("NewbieLoginConfig")
  logic_newbie_reward_eight_day.NewbieLoginConfig = {}
  for _, data in pairs(NewbieLoginConfig) do
    if data.GroupId == group_id then
      local config = {}
      config.Day = data.Day
      config.Reward1 = data.Reward1
      config.Reward1Number = data.Reward1Number
      config.Reward1Time = data.Reward1Time
      config.Reward2 = data.Reward2
      config.Reward2Number = data.Reward2Number
      config.Reward2Time = data.Reward2Time
      config.Reward3 = data.Reward3
      config.Reward3Number = data.Reward3Number
      config.Reward3Time = data.Reward3Time
      table.insert(logic_newbie_reward_eight_day.NewbieLoginConfig, config)
    end
  end
end
function logic_newbie_reward_eight_day.GetNewbieLoginConfig()
  return logic_newbie_reward_eight_day.NewbieLoginConfig or {}
end
function logic_newbie_reward_eight_day.GetOptionsRewardData()
  local logic_newbie_new_abtest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_new_abtest)
  local data = {}
  local loginDay = logic_newbie_new_abtest:GetNewbieNewDataLoginDay()
  local loginData = logic_newbie_new_abtest:GetNewbieNewDataLoginData()
  if logic_newbie_reward_eight_day.NewbieLoginConfig and next(logic_newbie_reward_eight_day.NewbieLoginConfig) then
    for _, v in pairs(logic_newbie_reward_eight_day.NewbieLoginConfig) do
      if v.Reward2 ~= 0 and v.Reward3 ~= 0 and loginDay >= v.Day and not loginData[v.Day] then
        table.insert(data, {
          itemId = v.Reward1,
          itemNum = v.Reward1Number,
          itemTime = v.Reward1Time
        })
        table.insert(data, {
          itemId = v.Reward2,
          itemNum = v.Reward2Number,
          itemTime = v.Reward2Time
        })
        table.insert(data, {
          itemId = v.Reward3,
          itemNum = v.Reward3Number,
          itemTime = v.Reward3Time
        })
      end
    end
  end
  return data
end
function logic_newbie_reward_eight_day.GetShowErrorCode()
  local logic_newbie_new_abtest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_new_abtest)
  log(bWriteLog and "logic_newbie_reward_eight_day.GetShowErrorCode")
  if not logic_newbie_reward_eight_day.IsOpen() then
    return 1
  end
  local endTime = logic_newbie_reward_eight_day.GetNewbieEndTime()
  local TimeUtil = require("client.common.time_util")
  if endTime - TimeUtil.GetServerTimeInSec() < 0 then
    return logic_newbie_reward_eight_day.ErrorCode_End
  end
  local signedCount = 0
  local loginData = logic_newbie_new_abtest:GetNewbieNewDataLoginData()
  for _, status in ipairs(loginData) do
    if status then
      signedCount = signedCount + 1
    end
  end
  if signedCount >= logic_newbie_reward_eight_day.DayAmount then
    return logic_newbie_reward_eight_day.ErrorCode_End
  end
  return 0
end
function logic_newbie_reward_eight_day.IsShowNewbieRewardEightDaySlap()
  local logic_newbie_new_abtest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_new_abtest)
  log(bWriteLog and "logic_newbie_reward_eight_day.ShouldSlap")
  if not logic_newbie_reward_eight_day.IsOpen() then
    return false
  end
  if logic_newbie_reward_eight_day.GetShowErrorCode() ~= 0 then
    return false
  end
  local loginData = logic_newbie_new_abtest:GetNewbieNewDataLoginData()
  local hasSignIn = false
  local loginDay = logic_newbie_new_abtest:GetNewbieNewDataLoginDay()
  for i = 1, logic_newbie_reward_eight_day.DayAmount do
    if i <= loginDay and not loginData[i] then
      hasSignIn = true
    end
  end
  log(bWriteLog and "XZF eight day " .. tostring(LobbySystem.CheckOpen(BP_ENUM_EXAMINE_UI_EIGHT_DAY)))
  if not LobbySystem.CheckOpen(BP_ENUM_EXAMINE_UI_EIGHT_DAY) then
    hasSignIn = false
  end
  log(bWriteLog and "logic_newbie_reward_eight_day.IsShowNewbieRewardEightDaySlap hasSignIn = " .. tostring(hasSignIn))
  return hasSignIn
end
function logic_newbie_reward_eight_day.HasRedDot()
  local logic_newbie_new_abtest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_new_abtest)
  if not logic_newbie_reward_eight_day.IsOpen() then
    return false
  end
  local loginData = logic_newbie_new_abtest:GetNewbieNewDataLoginData()
  local loginDay = logic_newbie_new_abtest:GetNewbieNewDataLoginDay()
  for i = 1, logic_newbie_reward_eight_day.DayAmount do
    if i <= loginDay and not loginData[i] then
      return true
    end
  end
  return false
end
function logic_newbie_reward_eight_day.UpdateRedDotCount(superData)
  local logic_newbie_new_abtest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_new_abtest)
  if not superData then
    return
  end
  local count = 0
  if not logic_newbie_reward_eight_day.IsOpen() then
    superData.newCount = count
    return count
  end
  local loginData = logic_newbie_new_abtest:GetNewbieNewDataLoginData()
  local loginDay = logic_newbie_new_abtest:GetNewbieNewDataLoginDay()
  for i = 1, logic_newbie_reward_eight_day.DayAmount do
    if i <= loginDay and not loginData[i] then
      count = count + 1
    end
  end
  superData.newCount = count
  log(bWriteLog and "==============> newbie activity logic_newbie_reward_eight_day UpdateRedDotCount: " .. count)
end
function logic_newbie_reward_eight_day.GetActivitySubData()
  if not logic_newbie_reward_eight_day.IsOpen() then
    return
  end
  return {
    nActID = ActivityFixedID.Newbie_EightDay,
    sName = LocUtil.GetLocalizeResStr(12204),
    bRedDot = logic_newbie_reward_eight_day.HasRedDot,
    sBgUrl = "",
    ImgUrl = "",
    ImgLink = "",
    nStartTime = 0
  }
end
function logic_newbie_reward_eight_day.GetNewbieEndTime()
  local nRegisterTime = DataMgr.registertime or 0
  local TimeUtil = require("client.common.time_util")
  if nRegisterTime == 0 or nRegisterTime > TimeUtil.GetServerTimeInSec() then
    return 0
  end
  log_format(bWriteLog and "logic_newbie_reward_eight_day:GetNewbieEndTime nRegisterTime = %s ", nRegisterTime)
  local totalTime = logic_newbie_reward_eight_day.TimeStep
  local tDateTable = TimeUtil.GetDateByUnixTime(nRegisterTime)
  if next(tDateTable) then
    nRegisterTime = nRegisterTime - tDateTable.hour * 3600 - tDateTable.min * 60 - tDateTable.sec
  end
  return totalTime + nRegisterTime
end
return logic_newbie_reward_eight_day