local WeekSignManager = {
  SignUpDay = nil,
  SignUpCost = nil,
  today = nil,
  LoginConfig = {
    {},
    {},
    {},
    {},
    {},
    {},
    {}
  },
  status_notfinish = 0,
  status_notaward = 1,
  status_awarded = 2,
  status_resignup = 3,
  status_fakeresignup = 4,
  StringID_Desc = 430002,
  StringID_NotEnough = 110055
}
local ActivityMacros = require("client.slua.logic.activity.RedPoint.ActivityMacros")
function WeekSignManager.GetActivitySubData_WeekSign()
  if WeekSignManager.GetBlackFiveWeekSign() then
    return nil
  end
  local url = string.format("%s/pictures/ActivityCenter/sign_in_banner.png", FuncUtil.GetDomainByID(3366036))
  local TimeUtil = require("client.common.time_util")
  return {
    nActID = ActivityFixedID.WEEK_SIGNUP,
    sName = LocUtil.GetLocalizeResStr(33828),
    bRedDot = WeekSignManager.CheckRedDot,
    sBgUrl = "",
    ImgUrl = "",
    ImgLink = "",
    Order = WeekSignManager.GetActivityShowOrder(),
    nStartTime = TimeUtil.GetServerTimeInSec(),
    sTabImageUrl = url
  }
end
function WeekSignManager.GetBlackFiveWeekSign()
  local extraID = DataMgr.WeekSignUpInfo.is_black_friday
  if extraID ~= 1 then
    return nil
  end
  local TimeUtil = require("client.common.time_util")
  return {
    nActID = ActivityFixedID.WEEK_SIGNUP,
    sName = LocUtil.GetLocalizeResStr(44620),
    bRedDot = WeekSignManager.CheckBlackFiveRedDot,
    sBgUrl = "",
    ImgUrl = "",
    ImgLink = "",
    Order = WeekSignManager.GetActivityShowOrder(),
    nStartTime = TimeUtil.GetServerTimeInSec()
  }
end
function WeekSignManager.CheckRedDot()
  local hasRedDot = false
  local ActivityMacros = require("client.slua.logic.activity.RedPoint.ActivityMacros")
  local RedDotType = ActivityMacros.RedDotType.None
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  local curDate = TimeUtil.OSDate("!*t", curTime)
  local weekDay = TimeUtil.GetWeekDay(curDate.wday)
  if DataMgr.WeekSignUpInfo.AwardState[weekDay] ~= WeekSignManager.status_awarded then
    hasRedDot = true
    RedDotType = ActivityMacros.RedDotType.Reward
  end
  return hasRedDot, RedDotType
end
function WeekSignManager.CheckBlackFiveRedDot()
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  local curDate = TimeUtil.OSDate("!*t", curTime)
  local weekDay = TimeUtil.GetWeekDay(curDate.wday)
  local day = 7
  if not WeekSignManager.today then
    WeekSignManager.UpdateTime()
  end
  local today = WeekSignManager.today
  local uc = DataMgr.WeekSignUpInfo.weeklyUc
  local HasAward = false
  local HasExtraAward = function(i)
    local signCfg = WeekSignManager.WeekSignUpTable[i]
    if signCfg and DataMgr.WeekSignUpInfo.AwardState[i] == WeekSignManager.status_awarded and signCfg.ExtraResID ~= 0 and uc ~= 0 and DataMgr.WeekSignUpInfo.UCAwardState[i] ~= WeekSignManager.status_awarded then
      return true
    end
    return false
  end
  for i = 1, day do
    if i < today then
      if HasExtraAward(i) then
        HasAward = true
        break
      end
    elseif i == today then
      if DataMgr.WeekSignUpInfo.AwardState[i] ~= WeekSignManager.status_awarded then
        HasAward = true
        break
      elseif HasExtraAward(i) then
        HasAward = true
        break
      end
    else
      break
    end
  end
  if HasAward then
    return true, ActivityMacros.RedDotType.Reward
  else
    return false, ActivityMacros.RedDotType.None
  end
end
function WeekSignManager.GetSignUpCost(day)
  local cost = 0
  if day < WeekSignManager.today and WeekSignManager.WeekReSignTable and next(WeekSignManager.WeekReSignTable) ~= nil then
    local data = WeekSignManager.WeekReSignTable[day]
    if data ~= nil then
      cost = data.ResignCost
    end
  end
  return cost
end
function WeekSignManager.ReportAdjustEventSign()
  local StatManager = import("StatManager")
  StatManager.GetInstance():ReportEventWithNoParam(32, true)
end
function WeekSignManager.SendSignMsg()
  WeekSignManager.SendWeekSignUpReq(WeekSignManager.SignUpDay, WeekSignManager.SignUpCost, 0)
end
function WeekSignManager.ShowNoGold(cost)
  local msg = string.format(LocUtil.GetLocalizeResStr(WeekSignManager.StringID_NotEnough), cost)
  msg = string.gsub(msg, "%$%$", "\"")
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(1, LocUtil.GetLocalizeResStr("430003"), msg)
end
function WeekSignManager.OnClickSign(index)
  log_warning(bWriteLog and "  :OnClickSign index: " .. tostring(index))
  WeekSignManager.SignUpDay = index
  local state = DataMgr.WeekSignUpInfo.AwardState[index]
  if index > WeekSignManager.today or state == WeekSignManager.status_awarded then
    return false
  end
  local cost = WeekSignManager.GetSignUpCost(index)
  WeekSignManager.SignUpCost = cost
  if 0 < cost then
    local resign = LocUtil.GetLocalizeResStr("430003")
    if cost > DataMgr.gold then
      WeekSignManager.ShowNoGold(cost)
    else
      local msg = string.format(LocUtil.GetLocalizeResStr(WeekSignManager.StringID_Desc), cost)
      msg = string.gsub(msg, "%$%$", "\"")
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.Show(2, resign, msg, function()
        WeekSignManager.SendSignMsg()
        WeekSignManager.ReportAdjustEventSign()
      end)
    end
  else
    WeekSignManager.SendSignMsg()
    WeekSignManager.ReportAdjustEventSign()
  end
  return true
end
function WeekSignManager.CanBatchSign(i)
  WeekSignManager.SignUpDay = i
  local uc = DataMgr.WeekSignUpInfo.weeklyUc
  if uc and uc ~= 0 then
    log(bWriteLog and "  :SendSignMsgWithOffset WeekSignManager.SignUpDay" .. tostring(WeekSignManager.SignUpDay))
    if i < WeekSignManager.today and DataMgr.WeekSignUpInfo.AwardState[i] ~= WeekSignManager.status_awarded and DataMgr.WeekSignUpInfo.UCAwardState[i] ~= WeekSignManager.status_awarded then
      local cost = WeekSignManager.GetSignUpCost(WeekSignManager.SignUpDay)
      if 0 < cost then
        local resign = LocUtil.GetLocalizeResStr("430003")
        if cost > DataMgr.gold then
          WeekSignManager.ShowNoGold(cost)
        else
          local msg = string.format(LocUtil.GetLocalizeResStr(WeekSignManager.StringID_Desc), cost)
          msg = string.gsub(msg, "%$%$", "\"")
          local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
          CommonMsgBoxMgr.Show(2, resign, msg, function()
            local ActivityHandler = require("client.network.Protocol.ActivityHandler")
            ActivityHandler.send_week_batch_signup_award_req(i)
            WeekSignManager.ReportAdjustEventSign()
          end)
        end
      end
      return true
    end
    return false
  end
  return false
end
function WeekSignManager.SendBlackFiveSignMsg()
  WeekSignManager.SignUpCost = WeekSignManager.GetSignUpCost(WeekSignManager.SignUpDay)
  WeekSignManager.SendWeekSignUpReq(WeekSignManager.SignUpDay, WeekSignManager.SignUpCost, 1)
end
function WeekSignManager.RedChange()
  local changes = {
    idList = {
      [ActivityFixedID.WEEK_SIGNUP] = true
    },
    typeList = {}
  }
  EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, changes)
end
function WeekSignManager.SendWeekSignUpReq(day, cost, sign_type)
  local ActivityHandler = require("client.network.Protocol.ActivityHandler")
  log(bWriteLog and "  :SendWeekSignUpReq  cost" .. tostring(cost))
  log(bWriteLog and "  :sign_type" .. tostring(sign_type))
  ActivityHandler.send_week_signup_award_req(day, cost, sign_type)
end
function WeekSignManager.Week_Signup_Award_Res(res, day, itemList, resign_time, isCickReward, sign_type)
  log(bWriteLog and "WeekSignUpSystem.week_signup_award_res, received week_signup_award_res, res = " .. tostring(res) .. ", day = " .. tostring(day))
  log(bWriteLog and "  :sign_type" .. tostring(sign_type))
  if itemList and next(itemList) then
    log(bWriteLog and "  : #itemList" .. tostring(#itemList))
  end
  if res ~= nil and string.lower(res) == NetErrorCode_NONE then
    DataMgr.WeekSignUpInfo.Resign_times = resign_time
    if sign_type == 1 then
      WeekSignManager.LoginConfig[day].ucStatus = WeekSignManager.status_awarded
      DataMgr.WeekSignUpInfo.UCAwardState[day] = WeekSignManager.status_awarded
    else
      DataMgr.UpdateWeekSignUpInfo(day, WeekSignManager.status_awarded)
      WeekSignManager.LoginConfig[day].status = WeekSignManager.status_awarded
    end
    if isCickReward ~= 1 then
      EventSystem:postEvent(EVENTTYPE_WEEK_SIGNUP, EVENTID_WEEK_SIGNUP_AWARD_RESULT, {isSuccessed = true, dropList = itemList})
    end
    WeekSignManager.SignInfoChange()
  else
    if res ~= nil then
      DataMgr.ShowMessageBoxByID(res)
    end
    EventSystem:postEvent(EVENTTYPE_WEEK_SIGNUP, EVENTID_WEEK_SIGNUP_AWARD_RESULT, {isSuccessed = false})
  end
  WeekSignManager.RedChange()
end
function WeekSignManager.Week_Signup_Award_Offset_Res(res, day, itemList, resign_time, isCickReward, sign_type_ret)
  log(bWriteLog and "WeekSignUpSystem.Week_Signup_Award_Offset_Res, res = " .. tostring(res) .. ", day = " .. tostring(day))
  log_tree("  : sign_type_ret", sign_type_ret)
  log_tree("  : itemList", itemList)
  log(bWriteLog and "  :resign_time" .. tostring(resign_time))
  if res ~= nil and string.lower(res) == NetErrorCode_NONE then
    if isCickReward ~= 1 and (not itemList or not next(itemList)) then
      local errorCode = sign_type_ret and sign_type_ret[1]
      if errorCode == 0 then
        errorCode = sign_type_ret and sign_type_ret[0] or 108005
      end
      ShowNotice(errorCode)
      return
    end
    DataMgr.UpdateWeekSignUpInfo(day, WeekSignManager.status_awarded)
    local UCAwardState = WeekSignManager.status_notfinish
    if DataMgr.WeekSignUpInfo.is_black_friday == 1 and 0 < DataMgr.WeekSignUpInfo.weeklyUc then
      UCAwardState = WeekSignManager.status_awarded
    end
    DataMgr.WeekSignUpInfo.UCAwardState[day] = UCAwardState
    DataMgr.WeekSignUpInfo.Resign_times = resign_time
    if isCickReward ~= 1 then
      EventSystem:postEvent(EVENTTYPE_WEEK_SIGNUP, EVENTID_WEEK_SIGNUP_AWARD_RESULT, {isSuccessed = true, dropList = itemList})
    end
    WeekSignManager.SignInfoChange()
  else
    if res ~= nil then
      DataMgr.ShowMessageBoxByID(res)
    end
    EventSystem:postEvent(EVENTTYPE_WEEK_SIGNUP, EVENTID_WEEK_SIGNUP_AWARD_RESULT, {isSuccessed = false})
  end
  WeekSignManager.RedChange()
end
local WEEK_SIGNUP = ActivityFixedID.WEEK_SIGNUP
function WeekSignManager.SignInfoChange()
  EventSystem:postEvent(EVENTTYPE_WEEK_SIGNUP, EVENTID_WEEK_SIGNUP_SYNCINFO)
  local changeList = {
    idList = {
      [WEEK_SIGNUP] = true
    },
    typeList = {}
  }
  EventSystem:postEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, changeList)
end
function WeekSignManager.UpdateTime()
  local WeekSignUpSecondsOfDay = 86400
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  local curDate = TimeUtil.OSDate("!*t", curTime)
  local todaySec = curDate.hour * 3600 + curDate.min * 60 + curDate.sec
  curDate.hour = 0
  curDate.min = 0
  curDate.sec = 0
  WeekSignManager.today = TimeUtil.GetWeekDay(curDate.wday)
  local timeOffset = WeekSignManager.today - 1
  WeekSignManager.StartTimeInSec = curTime - todaySec - timeOffset * WeekSignUpSecondsOfDay
  WeekSignManager.EndTimeInSec = WeekSignManager.StartTimeInSec + 7 * WeekSignUpSecondsOfDay - 1
end
function WeekSignManager.SetSignUpTable(info)
  local signTable = info[1]
  local TimeUtil = require("client.common.time_util")
  if signTable and next(signTable) then
    table.sort(signTable, function(a, b)
      if a.Date ~= b.Date then
        local DateUnixA = TimeUtil.TimeStringToUnixstamp(a.Date)
        local DateUnixB = TimeUtil.TimeStringToUnixstamp(b.Date)
        return DateUnixA < DateUnixB
      else
        return a.WeekDay < b.WeekDay
      end
    end)
  end
  WeekSignManager.WeekSignUpTable = signTable
  WeekSignManager.WeekReSignTable = info[2]
  WeekSignManager.Resource_StartTime = info[3]
  WeekSignManager.Resource_EndTime = info[4]
  WeekSignManager.HandleLocalizationData(WeekSignManager.WeekSignUpTable, info[5])
  WeekSignManager.SignInfoChange()
end
function WeekSignManager.HandleLocalizationData(weekSignUpTables, localizationWeekSignUpTables)
  log(bWriteLog and "[weeksign]:signuptable" .. tostring(localizationWeekSignUpTables))
  if localizationWeekSignUpTables and next(localizationWeekSignUpTables) then
    for index1, localizationWeekSignUpTable in pairs(localizationWeekSignUpTables) do
      local localizationDataWeekDay = localizationWeekSignUpTable.week_day
      for index2, weekSignUpTable in pairs(weekSignUpTables) do
        local weekDay = weekSignUpTable.WeekDay
        if weekDay == localizationDataWeekDay then
          local bResIDvalid = localizationWeekSignUpTable.resid and localizationWeekSignUpTable.resid > 0
          if bResIDvalid then
            weekSignUpTable.ResID = localizationWeekSignUpTable.resid
          end
          local bCountValid = localizationWeekSignUpTable.count and 0 < localizationWeekSignUpTable.count
          if bCountValid then
            weekSignUpTable.Count = localizationWeekSignUpTable.count
          end
          local bTimeValid = localizationWeekSignUpTable.valid_hours and 0 <= localizationWeekSignUpTable.valid_hours
          if bTimeValid then
            weekSignUpTable.ValidHours = localizationWeekSignUpTable.valid_hours
          end
          local bWeightValid = localizationWeekSignUpTable.weight and 0 < localizationWeekSignUpTable.weight
          if bWeightValid then
            weekSignUpTable.weight = localizationWeekSignUpTable.weight
          end
          local bBackgroundPicValid = localizationWeekSignUpTable.background_pic and localizationWeekSignUpTable.background_pic ~= ""
          if bBackgroundPicValid then
            weekSignUpTable.background_pic = localizationWeekSignUpTable.background_pic
          end
          log(bWriteLog and "[weeksign]:weekSignUpTables ResID" .. tostring(weekSignUpTable.ResID) .. "Count " .. tostring(weekSignUpTable.Count) .. "WeekDay " .. tostring(weekSignUpTable.WeekDay) .. "weight " .. tostring(weekSignUpTable.weight) .. "background_pic " .. tostring(weekSignUpTable.background_pic))
          break
        end
      end
    end
  end
end
function WeekSignManager.GetActivityShowOrder()
  local weight
  WeekSignManager.UpdateTime()
  if WeekSignManager.WeekSignUpTable and WeekSignManager.today then
    local data = WeekSignManager.WeekSignUpTable[WeekSignManager.today]
    weight = data and data.weight
  end
  log(bWriteLog and "[weeksign]:GetActivityShowOrder" .. tostring(weight) .. "today" .. tostring(WeekSignManager.today))
  return weight
end
function WeekSignManager.ReceiveOne(index)
  local cfg = DataMgr.WeekSignUpInfo.AwardState
  if cfg == nil or cfg[index].status == 0 or cfg[index].status == 2 or cfg[index].status == 4 then
    return
  end
  local cost = WeekSignManager.GetSignUpCost(index)
  if cost <= 0 then
    WeekSignManager.SignUpDay = index
    WeekSignManager.SignUpCost = cost
    WeekSignManager.SendSignMsg()
  end
end
function WeekSignManager.ReceiveFromRedHot(instanceKey)
  if instanceKey and instanceKey == ActivityFixedID.WEEK_SIGNUP then
    WeekSignManager.UpdateTime()
    local time_ticker = require("common.time_ticker")
    for index = 1, 7 do
      time_ticker.AddTimerOnce(0.2, function()
        WeekSignManager.ReceiveOne(index)
      end)
    end
  end
end
function WeekSignManager.GetCanReceiveAwards(_)
  WeekSignManager.UpdateTime()
  local awardList = {}
  if not WeekSignManager.WeekSignUpTable then
    return awardList
  end
  local reddotUtil = require("client.slua.logic.reddot.reddot_util")
  local cfg = DataMgr.WeekSignUpInfo.AwardState
  for index = 1, WeekSignManager.today do
    if cfg and cfg[index] and cfg[index] == 1 then
      local cost = WeekSignManager.GetSignUpCost(index)
      if cost <= 0 then
        table.insert(awardList, reddotUtil.CreateItem(WeekSignManager.WeekSignUpTable[index].ResID, WeekSignManager.WeekSignUpTable[index].Count))
      end
    end
  end
  if DataMgr.WeekSignUpInfo.is_black_friday == 1 and 0 < DataMgr.WeekSignUpInfo.weeklyUc then
    local UCAwardcfg = DataMgr.WeekSignUpInfo.UCAwardState
    if UCAwardcfg and UCAwardcfg[WeekSignManager.today] and UCAwardcfg[WeekSignManager.today] == 0 then
      table.insert(awardList, reddotUtil.CreateItem(WeekSignManager.WeekSignUpTable[WeekSignManager.today].ExtraResID, WeekSignManager.WeekSignUpTable[WeekSignManager.today].ExtraCount))
    end
  end
  return awardList
end
return WeekSignManager