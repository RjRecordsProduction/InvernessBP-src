local EightDaySystem = {
  DayAmount = 8,
  StringID_Name = 430001,
  StringID_DateFormat = 430101,
  EightDays = {},
  TimeStep = 1209599,
  ErrorCode_End = 430104,
  StringNameFormat = "",
  StringDateFormat = "",
  IsClickButtonEightDay = false,
  ActiveTime = "",
  RemainingTime = "",
  OptionalAwards = {}
}
function EightDaySystem.OnJumpUrl(eventType, eventID, vars)
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  log(bWriteLog and "[qintong] EightDaySystem.ShowUI" .. tostring(growthprojectMgrB.fromClickBanner))
  if growthprojectMgrB.fromClickBanner then
    growthprojectMgrB.fromClickBanner = false
  else
    local enter_guide = require("client.slua.logic.growth_project.enter_guide")
    if not growthprojectMgrB.IsFinishAllNewGuide() then
      return
    end
    if enter_guide.executeFightGuide then
      return
    end
  end
  EightDaySystem.ShowUI()
end
function EightDaySystem.ShowUI()
  local errorCode = EightDaySystem.GetShowErrorCode()
  if errorCode ~= 0 then
    if errorCode == EightDaySystem.ErrorCode_End then
      ShowNotice(errorCode)
    end
    return
  end
  local textData = LocUtil.GetLocalizeResStr(EightDaySystem.StringID_Name)
  if textData ~= nil then
    EightDaySystem.StringNameFormat = textData
  end
  textData = LocUtil.GetLocalizeResStr(EightDaySystem.StringID_DateFormat)
  if textData ~= nil then
    EightDaySystem.StringDateFormat = textData
  end
  UIManager.ShowUI(UIManager.UI_Config.Flap_Newbie_EightDays)
end
function EightDaySystem.GetActivityData()
  local NewbieActivitySystem = require("client.slua.logic.activity.newbie.logic_newbie_activity")
  if not NewbieActivitySystem.HasNewbieActivity() then
    return nil
  end
  return NewbieActivitySystem.activity_data.newbie_sign
end
function EightDaySystem.GetActivityRemainTime()
  local TimeUtil = require("client.common.time_util")
  return EightDaySystem.GetActivityEndTime() - TimeUtil.GetServerTimeInSec()
end
function EightDaySystem.GetActivityEndTime()
  local NewbieActivitySystem = require("client.slua.logic.activity.newbie.logic_newbie_activity")
  if not NewbieActivitySystem.HasNewbieActivity() then
    return nil
  end
  return NewbieActivitySystem.activity_data.open_time + EightDaySystem.TimeStep
end
function EightDaySystem.GetShowErrorCode()
  log(bWriteLog and "EightDaySystem.GetShowErrorCode")
  local NewbieActivitySystem = require("client.slua.logic.activity.newbie.logic_newbie_activity")
  if not NewbieActivitySystem.HasNewbieActivity() then
    return 1
  end
  local endTime = NewbieActivitySystem.activity_data.open_time + EightDaySystem.TimeStep
  local TimeUtil = require("client.common.time_util")
  if endTime < TimeUtil.GetServerTimeInSec() then
    return EightDaySystem.ErrorCode_End
  end
  local signedCount = 0
  for _, status in ipairs(NewbieActivitySystem.activity_data.newbie_sign.status) do
    if status == 2 then
      signedCount = signedCount + 1
    end
  end
  if signedCount >= EightDaySystem.DayAmount then
    return EightDaySystem.ErrorCode_End
  end
  return 0
end
function EightDaySystem.ShouldSlap()
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  local NewbieActivitySystem = require("client.slua.logic.activity.newbie.logic_newbie_activity")
  log(bWriteLog and "EightDaySystem.ShouldSlap")
  if not NewbieActivitySystem.HasNewbieActivity() then
    return false
  end
  if EightDaySystem.GetShowErrorCode() ~= 0 then
    return false
  end
  local hasSignIn = false
  for _, status in ipairs(NewbieActivitySystem.activity_data.newbie_sign.status) do
    if status == 1 then
      hasSignIn = true
    end
  end
  log(bWriteLog and "XZF eight day " .. tostring(LobbySystem.CheckOpen(BP_ENUM_EXAMINE_UI_EIGHT_DAY)))
  if not LobbySystem.CheckOpen(BP_ENUM_EXAMINE_UI_EIGHT_DAY) then
    hasSignIn = false
  end
  if LogicNewbie.IsNewbie() and not LogicNewbie.NeedShowNewbieGuide(20000) then
    return false
  end
  DataMgr.IsEightDaySlpaed = hasSignIn
  log(bWriteLog and "EightDaySystem.ShouldSlap DataMgr.IsEightDaySlpaed = " .. tostring(DataMgr.IsEightDaySlpaed))
  return hasSignIn
end
function EightDaySystem.HasRedDot()
  local NewbieActivitySystem = require("client.slua.logic.activity.newbie.logic_newbie_activity")
  if not NewbieActivitySystem.HasNewbieActivity() then
    return false
  end
  local data = EightDaySystem.GetActivityData()
  if not data then
    return false
  end
  for _, v in ipairs(data.status) do
    if v == 1 then
      return true
    end
  end
  return false
end
function EightDaySystem.UpdateRedDot()
  local logicRedDot = require("client.slua.logic.activity.newbie.logic_newbie_activity_reddot")
  local activityConfig = require("client.slua.logic.activity.newbie.logic_newbie_activity_config")
  local redPointData = logicRedDot.GetSuperDataByAct(activityConfig.activityDef.EightDay)
  if redPointData then
    EightDaySystem.UpdateRedDotCount(redPointData)
  end
end
function EightDaySystem.UpdateRedDotCount(superData)
  if not superData then
    return
  end
  local count = 0
  local NewbieActivitySystem = require("client.slua.logic.activity.newbie.logic_newbie_activity")
  if not NewbieActivitySystem.HasNewbieActivity() then
    return count
  end
  local data = EightDaySystem.GetActivityData()
  if data then
    for _, v in ipairs(data.status) do
      if v == 1 then
        count = count + 1
      end
    end
  end
  superData.newCount = count
  log(bWriteLog and "==============> newbie activity EightDaySystem UpdateRedDotCount: " .. count)
end
function EightDaySystem.GetActivitySubData()
  local NewbieActivitySystem = require("client.slua.logic.activity.newbie.logic_newbie_activity")
  if not NewbieActivitySystem.HasNewbieActivity() then
    return
  end
  if not LobbySystem.CheckOpen(50002) then
    return
  end
  return {
    nActID = ActivityFixedID.Newbie_EightDay,
    sName = LocUtil.GetLocalizeResStr(12204),
    bRedDot = EightDaySystem.HasRedDot,
    sBgUrl = "",
    ImgUrl = "",
    ImgLink = "",
    nStartTime = 0
  }
end
function EightDaySystem.ReceiveOne(index)
  if index <= 7 then
    local NewbieActivityHandle = require("client.network.Protocol.NewbieActivityHandle")
    NewbieActivityHandle.send_newbie_activity_get_sign_reward_req(index, 1)
  else
    UIManager.ShowUI(UIManager.UI_Config.EightDays_SelectAwardUI)
  end
end
function EightDaySystem.ReceiveFromRedHot(instanceKey)
  if instanceKey and instanceKey == ActivityFixedID.Newbie_EightDay then
    local data = EightDaySystem.GetActivityData()
    local time_ticker = require("common.time_ticker")
    for index = 1, 8 do
      if data and data.status[index] == 1 then
        time_ticker.AddTimerOnce(0.2, function()
          EightDaySystem.ReceiveOne(index)
        end)
      end
    end
  end
end
function EightDaySystem.GetCanReceiveAwards(instanceKey)
  local awardList = {}
  local data = EightDaySystem.GetActivityData()
  if not data then
    return awardList
  end
  local reddotUtil = require("client.slua.logic.reddot.reddot_util")
  for index = 1, 7 do
    local status = data.status[index] or 0
    if status == 1 then
      local cfg = data.cfg[index][1]
      table.insert(awardList, reddotUtil.CreateItem(cfg and cfg.itemid, cfg and cfg.cnt))
    end
  end
  return awardList
end
return EightDaySystem