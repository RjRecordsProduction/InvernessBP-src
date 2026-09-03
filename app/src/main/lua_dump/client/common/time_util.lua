local TimeUtil = {nLocalTimeTick = 0}
local string_format = string.format
local string_sub = string.sub
local string_len = string.len
local string_match = string.match
require("common.loc_util")
local LocUtil_LocalizeResFormat = LocUtil.LocalizeResFormat
local LocUtil_GetLocalizeResStr = LocUtil.GetLocalizeResStr
local local local local local local local local slua_getMiliseconds = slua.getMiliseconds
local slua_getMicroseconds = slua.getMicroseconds
local math_ceil = math.ceil
local math_floor = math.floor
local math_fmod = math.fmod
local math_modf = math.modf
local os_difftime = os.difftime
local os_date = os.date
local os_time = os.time
local local SettingTimeDisplay = require("client.logic.setting.logic_setting_time_display")
local StringUtil = require("common.string_util")
local C_monthUnit = 2592000
local C_dayUnit = 86400
local C_hourUnit = 3600
local C_minUnit = 60
local time32_MAX = 2147483647
local nLastServerTime = 0
local nLastServerTimeWithFraction = 0
function TimeUtil.GetDeltaTimeWithCurTime(nTimeStamp)
  local serverTime = TimeUtil.GetServerTimeInSec()
  if nTimeStamp > serverTime then
    return nTimeStamp - serverTime
  end
  return 0
end
local OSTimeErrorReport = function(msg)
  local utility = require("common.utility")
  local ClientToolsReport = require("client.slua.logic.report.ClientToolsReport")
  utility.ErrorMessageHandler(msg, ClientToolsReport.Enum_CrashKit_Type.Enum_Lua)
end
local OSTimeError = function(msg, timeTable, needReport)
  local paramStr = ""
  if not timeTable then
    paramStr = "  timeTable is nil"
  elseif type(timeTable) ~= "table" then
    paramStr = "  timeTable is not a table"
  else
    paramStr = string_format("  timeTable: %s / %s / %s  %s : %s : %s", tostring(timeTable.year), tostring(timeTable.month), tostring(timeTable.day), tostring(timeTable.hour), tostring(timeTable.min), tostring(timeTable.sec))
  end
  local totalMsg = msg .. paramStr
  log_error(bWriteLog and totalMsg)
  if not needReport then
    return 0
  end
  if timeTable and timeTable.year and type(timeTable.year) == "number" and timeTable.year > 2039 then
    return 0
  end
  OSTimeErrorReport(totalMsg)
  return 0
end
local OSDateError = function(msg, format, time, needReport)
  local totalMsg = msg .. string_format("  format: %s   time: %s ", tostring(format), tostring(time))
  log_error(bWriteLog and totalMsg)
  if not needReport then
    return 0
  end
  OSTimeErrorReport(totalMsg)
  return 0
end
function TimeUtil.GetTimeShow(nTimeStamp, bIsToLocalTime, bIsShowUTC0Str, nShowIndex, sFormat_HMS)
  local sFormatStr = ""
  local sReturnStr = ""
  if bIsToLocalTime then
    local tb = TimeUtil.OSDate("*t", nTimeStamp)
    nTimeStamp = nTimeStamp + (tb.isdst and -3600 or 0)
  else
    sFormatStr = "!"
  end
  nShowIndex = nShowIndex or 1
  if nShowIndex == -1 then
    if sFormat_HMS then
      sFormatStr = sFormatStr .. sFormat_HMS
    else
      sFormatStr = sFormatStr .. "%H:%M:%S"
    end
    sReturnStr = TimeUtil.OSDate(sFormatStr, nTimeStamp)
  else
    local dateArr = StringUtil.Split(SettingTimeDisplay.dateFormat, SettingTimeDisplay.dateSeparator)
    local dateFormat = ""
    for k, v in pairs(dateArr) do
      local needSeparator = true
      if string_sub(v, 1, 1) == "Y" and nShowIndex == 2 then
        needSeparator = false
      elseif v == "DD" and nShowIndex == 3 then
        needSeparator = false
      elseif v == "YYYY" then
        dateFormat = dateFormat .. "%Y"
      elseif v == "YY" then
        dateFormat = dateFormat .. "%y"
      elseif v == "MM" then
        dateFormat = dateFormat .. "%m"
      elseif v == "DD" then
        dateFormat = dateFormat .. "%d"
      end
      if needSeparator and k ~= 3 then
        dateFormat = dateFormat .. SettingTimeDisplay.dateSeparator
      elseif not needSeparator and k == 3 then
        dateFormat = string_sub(dateFormat, 1, string_len(dateFormat) - 1)
      end
    end
    if sFormat_HMS then
      sFormatStr = sFormatStr .. string_format("%s %s", dateFormat, sFormat_HMS)
    else
      sFormatStr = sFormatStr .. dateFormat
    end
    sReturnStr = TimeUtil.OSDate(sFormatStr, nTimeStamp)
  end
  if not bIsToLocalTime and bIsShowUTC0Str then
    sReturnStr = LocUtil_LocalizeResFormat(45114, sReturnStr)
  end
  return sReturnStr
end
local GetDifferentCountryTimeFormat = function(nTimeStamp, bIsToLocalTime, bIsShowUTC0Str, nShowIndex, sFormat_HMS)
  if not nTimeStamp then
    return nil
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local strRegion = Client.GetPublishRegion()
  if strRegion == PublishRegionMacros.BLUEHOLE or PublishRegionMacros.IsJapanOrKorea() then
    bIsToLocalTime = true
    bIsShowUTC0Str = false
  end
  return TimeUtil.GetTimeShow(nTimeStamp, bIsToLocalTime, bIsShowUTC0Str, nShowIndex, sFormat_HMS)
end
function TimeUtil.FormatTime_YMDHMS(nTimeStamp, bIsToLocalTime, bIsShowUTC0Str)
  if not nTimeStamp or nTimeStamp < 0 then
    return ""
  end
  return GetDifferentCountryTimeFormat(nTimeStamp, bIsToLocalTime, bIsShowUTC0Str, 1, "%H:%M:%S")
end
function TimeUtil.FormatTime_YMDHM(nTimeStamp, bIsToLocalTime, bIsShowUTC0Str)
  if not nTimeStamp or nTimeStamp < 0 then
    return ""
  end
  return GetDifferentCountryTimeFormat(nTimeStamp, bIsToLocalTime, bIsShowUTC0Str, 1, "%H:%M")
end
function TimeUtil.FormatTime_MDHMS(nTimeStamp, bIsToLocalTime, bIsShowUTC0Str)
  if not nTimeStamp or nTimeStamp < 0 then
    return ""
  end
  return GetDifferentCountryTimeFormat(nTimeStamp, bIsToLocalTime, bIsShowUTC0Str, 2, "%H:%M:%S")
end
function TimeUtil.FormatTime_YMD(nTimeStamp, bIsToLocalTime, bIsShowUTC0Str)
  if not nTimeStamp or nTimeStamp < 0 then
    return ""
  end
  return GetDifferentCountryTimeFormat(nTimeStamp, bIsToLocalTime, bIsShowUTC0Str, 1)
end
function TimeUtil.FormatTime_YM(nTimeStamp, bIsToLocalTime, bIsShowUTC0Str)
  if not nTimeStamp or nTimeStamp < 0 then
    return ""
  end
  return GetDifferentCountryTimeFormat(nTimeStamp, bIsToLocalTime, bIsShowUTC0Str, 3)
end
function TimeUtil.FormatTime_MD(nTimeStamp, bIsToLocalTime, bIsShowUTC0Str)
  if not nTimeStamp or nTimeStamp < 0 then
    return ""
  end
  return GetDifferentCountryTimeFormat(nTimeStamp, bIsToLocalTime, bIsShowUTC0Str, 2)
end
function TimeUtil.FormatTime_MDHM(nTimeStamp, bIsToLocalTime, bIsShowUTC0Str)
  if not nTimeStamp or nTimeStamp < 0 then
    return ""
  end
  return GetDifferentCountryTimeFormat(nTimeStamp, bIsToLocalTime, bIsShowUTC0Str, 2, "%H:%M")
end
function TimeUtil.FormatTime_HM(nTimeStamp, bIsToLocalTime, bIsShowUTC0Str)
  return GetDifferentCountryTimeFormat(nTimeStamp, bIsToLocalTime, bIsShowUTC0Str, -1, "%H:%M")
end
function TimeUtil.FormatTime_HMS(nTimeStamp, bIsToLocalTime, bIsShowUTC0Str)
  return GetDifferentCountryTimeFormat(nTimeStamp, bIsToLocalTime, bIsShowUTC0Str, -1, "%H:%M:%S")
end
function TimeUtil.FormatTime_timeFrame(nTimeStamp1, nTimeStamp2, bIsToLocalTime, bIsShowUTC0Str, fTimeFormatFun)
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local strRegion = Client.GetPublishRegion()
  if strRegion == PublishRegionMacros.BLUEHOLE or PublishRegionMacros.IsJapanOrKorea() then
    fTimeFormatFun = TimeUtil.FormatTime_YMDHM
    bIsToLocalTime = true
    bIsShowUTC0Str = false
  else
    fTimeFormatFun = fTimeFormatFun or TimeUtil.FormatTime_YMD
  end
  local sReturnStr
  local timeStr1 = fTimeFormatFun(nTimeStamp1, bIsToLocalTime, false)
  local timeStr2 = fTimeFormatFun(nTimeStamp2, bIsToLocalTime, false)
  if not bIsToLocalTime and bIsShowUTC0Str then
    sReturnStr = LocUtil_LocalizeResFormat(24960, timeStr1, timeStr2)
  else
    sReturnStr = LocUtil_LocalizeResFormat(7545, timeStr1, timeStr2)
  end
  return sReturnStr
end
function TimeUtil.FormatCountDownTime_D_SocialCard(nTotalTime)
  if not nTotalTime or nTotalTime <= 0 then
    return ""
  end
  local days = math_ceil(nTotalTime / 86400)
  return LocUtil_LocalizeResFormat(4409, days)
end
function TimeUtil.FormatCountDownTime_D_or_HMS(nTotalTime, nDay)
  if not nTotalTime or nTotalTime < 0 then
    return ""
  end
  local days = math_floor(nTotalTime / 86400)
  local hours = math_fmod(math_floor(nTotalTime / 3600), 24)
  local mins = math_fmod(math_floor(nTotalTime / 60), 60)
  local seconds = math_fmod(math_floor(nTotalTime), 60)
  nDay = nDay or 2
  if days >= nDay then
    return LocUtil_LocalizeResFormat(4409, days)
  else
    if 0 < days then
      hours = hours + days * 24
    end
    local sHour = string_format("%02d", hours)
    local sMin = string_format("%02d", mins)
    local sSec = string_format("%02d", seconds)
    return LocUtil.LocalizeResFormat(76744, sHour, sMin, sSec)
  end
end
function TimeUtil.FormatCountDownTime_D_or_HM(nTotalTime, nDay)
  if not nTotalTime or nTotalTime <= 0 then
    return ""
  end
  local days = math_floor(nTotalTime / 86400)
  local hours = math_fmod(math_floor(nTotalTime / 3600), 24)
  local mins = math_fmod(math_floor(nTotalTime / 60), 60)
  nDay = nDay or 2
  if days >= nDay then
    return LocUtil_LocalizeResFormat(4409, days)
  else
    if 0 < days then
      hours = hours + days * 24
    end
    return string.format("%02d:%02d", hours, mins)
  end
end
function TimeUtil.FormatCountDownTime_DHM_or_HMS(nTotalTime, nDay)
  if not nTotalTime or nTotalTime <= 0 then
    return ""
  end
  local days = math_floor(nTotalTime / 86400)
  local hours = math_fmod(math_floor(nTotalTime / 3600), 24)
  local mins = math_fmod(math_floor(nTotalTime / 60), 60)
  local seconds = math_fmod(math_floor(nTotalTime), 60)
  nDay = nDay or 1
  if days >= nDay then
    return LocUtil.LocalizeResFormat(44945, days, hours, mins)
  else
    if 0 < days then
      hours = hours + days * 24
    end
    local sHour = string_format("%02d", hours)
    local sMin = string_format("%02d", mins)
    local sSec = string_format("%02d", seconds)
    return LocUtil.LocalizeResFormat(76744, sHour, sMin, sSec)
  end
end
function TimeUtil.FormatCountDownTime_DHMS(nTotalTime)
  if not nTotalTime or nTotalTime <= 0 then
    return ""
  end
  local days = math_floor(nTotalTime / 86400)
  local hours = math_fmod(math_floor(nTotalTime / 3600), 24)
  local mins = math_fmod(math_floor(nTotalTime / 60), 60)
  local seconds = math_fmod(nTotalTime, 60)
  if 0 < days then
    return LocUtil.LocalizeResFormat(76745, days, hours, mins, seconds)
  elseif 0 < hours then
    return LocUtil.LocalizeResFormat(76746, hours, mins, seconds)
  elseif 0 < mins then
    return LocUtil.LocalizeResFormat(76747, mins, seconds)
  else
    return LocUtil.LocalizeResFormat(301157, seconds)
  end
end
function TimeUtil.FormatCountDownTime_DHMSTab(nTotalTime)
  if not nTotalTime or nTotalTime <= 0 then
    return nil
  end
  local days = math_floor(nTotalTime / 86400)
  local hours = math_fmod(math_floor(nTotalTime / 3600), 24)
  local mins = math_fmod(math_floor(nTotalTime / 60), 60)
  local seconds = math_fmod(nTotalTime, 60)
  return {
    day = days,
    hour = hours,
    min = mins,
    sec = seconds
  }
end
function TimeUtil.FormatCountDownTime_DH_or_HMS(nTotalTime, bShowZero)
  if not nTotalTime or nTotalTime <= 0 then
    if bShowZero then
      return LocUtil.LocalizeResFormat(76744, "00", "00", "00")
    else
      return ""
    end
  end
  local days = math_floor(nTotalTime / 86400)
  local hours = math_fmod(math_floor(nTotalTime / 3600), 24)
  local mins = math_fmod(math_floor(nTotalTime / 60), 60)
  local seconds = math_fmod(nTotalTime, 60)
  if 0 < days then
    return LocUtil_LocalizeResFormat(301152, days, hours)
  else
    local sHour = string_format("%02d", hours)
    local sMin = string_format("%02d", mins)
    local sSec = string_format("%02d", seconds)
    return LocUtil.LocalizeResFormat(76744, sHour, sMin, sSec)
  end
end
function TimeUtil.FormatCountDownTime_DH_or_HMS_or_MS(nTotalTime, bShowZero)
  if not nTotalTime or nTotalTime <= 0 then
    if bShowZero then
      return LocUtil.LocalizeResFormat(7616, "00", "00")
    else
      return ""
    end
  end
  local days = math_floor(nTotalTime / 86400)
  local hours = math_fmod(math_floor(nTotalTime / 3600), 24)
  local mins = math_fmod(math_floor(nTotalTime / 60), 60)
  local seconds = math_fmod(nTotalTime, 60)
  if 0 < days then
    return LocUtil.LocalizeResFormat(67737, days, hours)
  else
    local sMin = string_format("%02d", mins)
    local sSec = string_format("%02d", seconds)
    if 0 < hours then
      local sHour = string_format("%02d", hours)
      return LocUtil.LocalizeResFormat(76744, sHour, sMin, sSec)
    else
      return LocUtil.LocalizeResFormat(7616, sMin, sSec)
    end
  end
end
function TimeUtil.FormatCountDownTime_HMS(nTotalTime, bShowZero)
  if not nTotalTime or nTotalTime <= 0 then
    if bShowZero then
      return LocUtil.LocalizeResFormat(76744, "00", "00", "00")
    else
      return ""
    end
  end
  local hours = string_format("%02d", math_fmod(math_floor(nTotalTime / 3600), 24))
  local mins = string_format("%02d", math_fmod(math_floor(nTotalTime / 60), 60))
  local seconds = string_format("%02d", math_fmod(math_floor(nTotalTime), 60))
  local sTimeStr = LocUtil.LocalizeResFormat(76744, hours, mins, seconds)
  return sTimeStr, hours, mins, seconds
end
function TimeUtil.FormatCountDownTime_HMS2(nTotalTime, bColonFormat)
  if not nTotalTime or nTotalTime <= 0 then
    return ""
  end
  local hours = math_floor(nTotalTime / 3600)
  local mins = math_fmod(math_floor(nTotalTime / 60), 60)
  local seconds = math_fmod(nTotalTime, 60)
  if bColonFormat then
    return LocUtil.LocalizeResFormat(76744, hours, mins, seconds)
  end
  if 0 < hours then
    return LocUtil.LocalizeResFormat(76746, hours, mins, seconds)
  elseif 0 < mins then
    return LocUtil.LocalizeResFormat(76747, mins, seconds)
  else
    return LocUtil.LocalizeResFormat(301157, seconds)
  end
end
function TimeUtil.FormatCountDownTime_MS(nTotalTime, bShowZero)
  if not nTotalTime or nTotalTime <= 0 then
    if bShowZero then
      return LocUtil.LocalizeResFormat(7616, "00", "00")
    else
      return ""
    end
  end
  local mins = math_fmod(math_floor(nTotalTime / 60), 60)
  local seconds = math_fmod(math_floor(nTotalTime), 60)
  local sMin = string_format("%02d", mins)
  local sSec = string_format("%02d", seconds)
  return LocUtil.LocalizeResFormat(7616, sMin, sSec)
end
function TimeUtil.FormatCountDownTime_MS_Ms(nTotalTime)
  if not nTotalTime or nTotalTime <= 0 then
    return LocUtil.LocalizeResFormat(76744, "00", "00", "00")
  end
  local mins = math_fmod(math_floor(nTotalTime / 60), 60)
  local seconds = math_fmod(math_floor(nTotalTime), 60)
  local _, frac = math_modf(nTotalTime)
  frac = math_floor(frac * 100)
  local sMin = string_format("%02d", mins)
  local sSec = string_format("%02d", seconds)
  local sFrac = string_format("%02d", frac)
  return LocUtil.LocalizeResFormat(76744, sMin, sSec, sFrac)
end
function TimeUtil.FormatCountDownTime_DH_or_HM(nTotalTime, bShowZero)
  if not nTotalTime then
    log_error("TimeUtil.FormatCountDownTime_DH_or_HM nTotalTime = nil")
    return
  end
  if nTotalTime <= 0 then
    if bShowZero then
      return LocUtil_LocalizeResFormat(6007, 1)
    else
      return ""
    end
  end
  local timeStr = ""
  local days = math_floor(nTotalTime / 86400)
  local hours = math_fmod(math_floor(nTotalTime / 3600), 24)
  local mins = math_fmod(math_floor(nTotalTime / 60), 60)
  local seconds = math_fmod(nTotalTime, 60)
  if 0 < seconds then
    mins = mins + 1
    if 60 <= mins then
      mins = mins - 60
      hours = hours + 1
      if 24 <= hours then
        hours = hours - 24
        days = days + 1
      end
    end
  end
  if 0 < days then
    if 0 < hours then
      timeStr = LocUtil_LocalizeResFormat(67737, days, hours)
    else
      timeStr = LocUtil_LocalizeResFormat(4409, days)
    end
    return timeStr
  end
  if 0 < hours then
    if 0 < mins then
      timeStr = LocUtil_LocalizeResFormat(67738, hours, mins)
    else
      timeStr = LocUtil_LocalizeResFormat(4795, hours)
    end
    return timeStr
  end
  timeStr = LocUtil_LocalizeResFormat(6007, mins)
  return timeStr
end
function TimeUtil.FormatCountDownTime_D_or_H_or_M(nTotalTime, bShowZero)
  if not nTotalTime then
    log_error("TimeUtil.FormatCountDownTime_DH_or_HM nTotalTime = nil")
    return
  end
  if nTotalTime <= 0 then
    if bShowZero then
      return LocUtil_LocalizeResFormat(6007, 1)
    else
      return ""
    end
  end
  local timeStr = ""
  local days = math_floor(nTotalTime / 86400)
  local hours = math_fmod(math_floor(nTotalTime / 3600), 24)
  local mins = math_fmod(math_floor(nTotalTime / 60), 60)
  local seconds = math_fmod(nTotalTime, 60)
  if 0 < seconds then
    mins = mins + 1
    if 60 <= mins then
      mins = mins - 60
      hours = hours + 1
      if 24 <= hours then
        hours = hours - 24
        days = days + 1
      end
    end
  end
  if 0 < days then
    timeStr = LocUtil_LocalizeResFormat(4409, days)
    return timeStr
  end
  if 0 < hours then
    timeStr = LocUtil_LocalizeResFormat(4795, hours)
    return timeStr
  end
  timeStr = LocUtil_LocalizeResFormat(6007, mins)
  return timeStr
end
function TimeUtil.TimeStringToUnixstamp(sTimeString, bIsLocalTime)
  if not sTimeString or string_len(sTimeString) == 0 then
    return 0
  end
  local p = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"
  local year, month, day, hour, min, sec = string_match(sTimeString, p)
  if year and month and day and hour and min and sec then
    return TimeUtil.UnixTimeToUnixstamp(year, month, day, hour, min, sec, bIsLocalTime)
  end
  return 0
end
function TimeUtil.UnixTimeToUnixstamp(year, month, day, hour, min, sec, bIsLocalTime)
  year = year or 2038
  month = month or 1
  day = day or 1
  hour = hour or 0
  min = min or 0
  sec = sec or 0
  local timeTable = {
    year = year,
    month = month,
    day = day,
    hour = hour,
    min = min,
      }
  if not bIsLocalTime then
    timeTable.isdst = false
    local timeZone = TimeUtil.GetTimeZone(nil, true)
    local offset = timeZone * 3600
    return TimeUtil.OSTime(timeTable) + offset
  else
    return TimeUtil.OSTime(timeTable)
  end
end
function TimeUtil.TimeStringToUnixstamp_LoopOptimize(sTimeString, timeZone, refTimeTable)
  local p = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"
  local year, month, day, hour, min, sec = string_match(sTimeString, p)
  if day == nil then
    log_error("TimeUtil.TimeStringToUnixstamp_LoopOptimize day is nil. sTimeString = " .. tostring(sTimeString))
    return 0
  end
  refTimeTable.  refTimeTable.  refTimeTable.  refTimeTable.  refTimeTable.  refTimeTable.  refTimeTable.isdst = false
  local offset = timeZone * 3600
  return TimeUtil.OSTime(refTimeTable) + offset
end
function TimeUtil.GetBirthdayTimeFormat(year, month, day)
  local dateArr = StringUtil.Split(SettingTimeDisplay.dateFormat, SettingTimeDisplay.dateSeparator)
  local dateSeparator = SettingTimeDisplay.dateSeparator
  local dateStr = ""
  for k, v in pairs(dateArr) do
    if v == "YYYY" then
      dateStr = dateStr .. tostring(year)
    elseif v == "YY" then
      dateStr = dateStr .. tostring(year % 100)
    elseif v == "MM" then
      if month < 10 then
        dateStr = dateStr .. "0" .. tostring(month)
      else
        dateStr = dateStr .. tostring(month)
      end
    elseif v == "DD" then
      if day < 10 then
        dateStr = dateStr .. "0" .. tostring(day)
      else
        dateStr = dateStr .. tostring(day)
      end
    end
    if k ~= 3 then
      dateStr = dateStr .. dateSeparator
    end
  end
  return dateStr
end
function TimeUtil.GetBirthdayTimeFormat_MD(month, day)
  local dateArr = StringUtil.Split(SettingTimeDisplay.dateFormat, SettingTimeDisplay.dateSeparator)
  local dateSeparator = SettingTimeDisplay.dateSeparator
  local dateStr = ""
  local SeparatorCnt = 0
  month = month or 0
  day = day or 0
  for _, v in pairs(dateArr) do
    if v == "MM" then
      if month < 10 then
        dateStr = dateStr .. "0" .. tostring(month)
      else
        dateStr = dateStr .. tostring(month)
      end
    elseif v == "DD" then
      if day < 10 then
        dateStr = dateStr .. "0" .. tostring(day)
      else
        dateStr = dateStr .. tostring(day)
      end
    end
    if dateStr ~= "" and SeparatorCnt < 1 then
      dateStr = dateStr .. dateSeparator
      SeparatorCnt = SeparatorCnt + 1
    end
  end
  return dateStr
end
function TimeUtil.InDaysFrom(targetTime, nDays)
  local curTime = TimeUtil.GetServerTimeInSec()
  local nTimes = 86400 * nDays
  local target = tonumber(targetTime)
  local detalTime = curTime - target - nTimes
  return detalTime <= 0
end
function TimeUtil.WithinInNDay(nTargetTime, nDays)
  local nCurTime = TimeUtil.GetServerTimeInSec()
  local nTimes = 86400 * nDays
  local target = tonumber(nTargetTime)
  local nDisTime = nCurTime - target
  return 0 <= nDisTime and nTimes >= nDisTime
end
function TimeUtil.GetTimeZone(time, ignoreDST)
  local localDate = TimeUtil.OSDate("*t", time)
  local localTime = TimeUtil.OSTime(localDate)
  local utcDate = TimeUtil.OSDate("!*t", time)
  local utcTime = TimeUtil.OSTime(utcDate)
  if ignoreDST then
  else
    localDate.isdst = false
  end
  return os_difftime(localTime, utcTime) / 3600
end
function TimeUtil.GetMiliseconds()
  return slua_getMiliseconds()
end
function TimeUtil.GetMicroseconds()
  return slua_getMicroseconds()
end
function TimeUtil.GetMonthMaxDay(year, month)
  if not (year and month) or year == 0 or month == 0 then
    return 0
  end
  local date = {
    year = year,
    month = month + 1
  }
  date.day = 0
  local maxDay = TimeUtil.OSDate("%d", TimeUtil.OSTime(date))
  return maxDay
end
function TimeUtil.IsSameWeek(nTotalTime1, nTotalTime2)
  return TimeUtil.GetWeekStartTime(nTotalTime1) == TimeUtil.GetWeekStartTime(nTotalTime2)
end
function TimeUtil.GetWeekStartTime(nTotalTime)
  local nTempTime = 259200
  return math_floor((nTotalTime + nTempTime) / 604800) * 604800 - nTempTime
end
function TimeUtil.GetWeekDay(nWeekDay)
  if nWeekDay == 1 then
    return 7
  else
    return nWeekDay - 1
  end
end
function TimeUtil.GetWeekDayByTime(nTimeStamp, bIsToLocalTime)
  local sFormatStr = bIsToLocalTime and "%w" or "!%w"
  local nWeekDay = tonumber(TimeUtil.OSDate(sFormatStr, nTimeStamp))
  if nWeekDay and nWeekDay == 0 then
    nWeekDay = 7
  end
  return nWeekDay
end
function TimeUtil.GetServerWeekDay()
  return TimeUtil.GetWeekDayByTime(TimeUtil.GetServerTimeInSec())
end
function TimeUtil.GetTotalSecByTime(nHour, nMin, nSec)
  return nHour * 3600 + nMin * 60 + nSec
end
function TimeUtil.GetHouseByTotalSec(nTotalTime)
  if not nTotalTime or nTotalTime < 0 then
    return 0
  end
  return math_ceil(nTotalTime / 3600)
end
function TimeUtil.GetLastOnlineTimeStr(nLastOnlineTime)
  if not nLastOnlineTime then
    return ""
  end
  local nDiff = TimeUtil.GetServerTimeInSec() - nLastOnlineTime
  local nDays = math_floor(nDiff / 86400)
  local nHours = math_fmod(math_floor(nDiff / 3600), 24)
  local nMins = math_fmod(math_floor(nDiff / 60), 60)
  if 7 < nDays then
    return LocUtil_GetLocalizeResStr(29775)
  elseif 1 <= nDays then
    return string_format(LocUtil_GetLocalizeResStr(5095), tostring(nDays))
  elseif 1 <= nHours then
    return string_format(LocUtil_GetLocalizeResStr(5096), tostring(nHours))
  elseif 1 <= nMins then
    return string_format(LocUtil_GetLocalizeResStr(5097), tostring(nMins))
  else
    return LocUtil_GetLocalizeResStr(5098)
  end
end
function TimeUtil.GetTimeAgoStr(nLastTime, bIsShowSec, nCurTime)
  if not nLastTime then
    return ""
  end
  nCurTime = nCurTime or TimeUtil.GetServerTimeInSec()
  local nDiff = nCurTime - nLastTime
  if nDiff <= 0 then
    return ""
  end
  local nDays = math_floor(nDiff / 86400)
  local nHours = math_fmod(math_floor(nDiff / 3600), 24)
  local nMins = math_fmod(math_floor(nDiff / 60), 60)
  local nSec = math_fmod(nDiff, 60)
  if 1 <= nDays then
    return string_format(LocUtil_GetLocalizeResStr(301255), tostring(nDays))
  elseif 1 <= nHours then
    return string_format(LocUtil_GetLocalizeResStr(301257), tostring(nHours))
  elseif 1 <= nMins then
    return string_format(LocUtil_GetLocalizeResStr(301264), tostring(nMins))
  elseif bIsShowSec and 0 < nSec then
    return string_format(LocUtil_GetLocalizeResStr(301149), tostring(nSec))
  else
    return LocUtil_GetLocalizeResStr(301105)
  end
end
function TimeUtil.GetTimeAgoStrToDetail(nLastTime, bIsShowSec, nCurTime)
  if not nLastTime then
    return ""
  end
  nCurTime = nCurTime or TimeUtil.GetServerTimeInSec()
  local nDiff = nCurTime - nLastTime
  if nDiff <= 0 then
    return ""
  end
  local nDays = math_floor(nDiff / 86400)
  local nHours = math_fmod(math_floor(nDiff / 3600), 24)
  local nMins = math_fmod(math_floor(nDiff / 60), 60)
  local nSec = math_fmod(nDiff, 60)
  if 1 <= nDays then
    return string_format(LocUtil_GetLocalizeResStr(301153), tostring(nDays))
  elseif 1 <= nHours then
    return string_format(LocUtil_GetLocalizeResStr(301155), tostring(nHours))
  elseif 1 <= nMins then
    return string_format(LocUtil_GetLocalizeResStr(301156), tostring(nMins))
  elseif bIsShowSec and 0 < nSec then
    return string_format(LocUtil_GetLocalizeResStr(301157), tostring(nSec))
  else
    return string_format(LocUtil_GetLocalizeResStr(301156), tostring(1))
  end
end
function TimeUtil.GetTimeLengthStr(nTotalTime, bIsShowTwoUnits)
  if not nTotalTime or nTotalTime <= 0 then
    return ""
  end
  local days = math_floor(nTotalTime / 86400)
  local hours = math_fmod(math_floor(nTotalTime / 3600), 24)
  local mins = math_fmod(math_floor(nTotalTime / 60), 60)
  local sec = math_fmod(nTotalTime, 60)
  local str
  if 0 < days then
    if bIsShowTwoUnits then
      if mins == 59 and 0 < sec then
        hours = hours + 1
      end
      if hours == 24 then
        days = days + 1
        hours = 0
      end
      str = LocUtil_LocalizeResFormat("301152", days, hours)
    else
      if 0 < hours then
        days = days + 1
      end
      str = LocUtil_LocalizeResFormat("301153", days)
    end
  elseif 0 < hours then
    if bIsShowTwoUnits then
      if 0 < sec then
        mins = mins + 1
      end
      if mins == 60 then
        hours = hours + 1
        mins = 0
      end
      str = LocUtil_LocalizeResFormat("301154", hours, mins)
    else
      if 0 < mins then
        hours = hours + 1
      end
      str = LocUtil_LocalizeResFormat("301155", hours)
    end
  else
    if 0 < sec then
      mins = mins + 1
    end
    str = LocUtil_LocalizeResFormat("301156", mins)
  end
  return str
end
function TimeUtil.GetOpenedTimeStr(nOpenedTime)
  if not nOpenedTime then
    return
  end
  local hours = math_fmod(math_floor(nOpenedTime / 3600), 24)
  local mins = math_fmod(math_floor(nOpenedTime / 60), 60)
  local seconds = math_fmod(nOpenedTime, 60)
  if 1 <= hours then
    if 1 <= mins then
      return LocUtil_LocalizeResFormat(13122, tostring(hours), tostring(mins))
    elseif mins < 1 and 0 <= mins then
      return LocUtil_LocalizeResFormat(13123, tostring(hours))
    end
  end
  if 1 <= mins then
    return LocUtil_LocalizeResFormat(13124, tostring(mins), tostring(seconds))
  end
  return LocUtil_LocalizeResFormat(13125, tostring(seconds))
end
function TimeUtil.GetTodayTimestamp()
  return 86400 - math_fmod(TimeUtil.GetServerTimeInSec(), 86400)
end
function TimeUtil.IsInUTCDayTimeRange(nCurTime, sStartHourTime, sEndHourTime)
  if not (sStartHourTime and sStartHourTime ~= "" and sEndHourTime) or sEndHourTime == "" then
    return true
  end
  local pattern = "(%d+):(%d+):(%d+)"
  local startHourStr, startMinStr, startSecStr = string_match(sStartHourTime, pattern)
  local endHourStr, endMinStr, endSecStr = string_match(sEndHourTime, pattern)
  local ut = TimeUtil.OSDate("!*t", nCurTime)
  local startSec = TimeUtil.GetTotalSecByTime(startHourStr, startMinStr, startSecStr)
  local endSec = TimeUtil.GetTotalSecByTime(endHourStr, endMinStr, endSecStr)
  local curSec = TimeUtil.GetTotalSecByTime(ut.hour, ut.min, ut.sec)
  local inRange = startSec <= curSec and endSec >= curSec
  return inRange
end
function TimeUtil.UnixTimeBetween(nStartTime, nEndTime)
  if nEndTime < nStartTime then
    log_error("TimeUtil.UnixTimeBetween startTime > endTime")
  end
  local nNowTime = TimeUtil.GetServerTimeInSec()
  if nStartTime > nNowTime then
    return -1
  elseif nEndTime < nNowTime then
    return 1
  else
    return 0
  end
end
function TimeUtil.UnixTimeStrBetween(sStartTime, sEndTime)
  local startTime = TimeUtil.TimeStringToUnixstamp(sStartTime)
  local endTime = TimeUtil.TimeStringToUnixstamp(sEndTime)
  return TimeUtil.UnixTimeBetween(startTime, endTime)
end
function TimeUtil.IsSameDay(nTime1, nTime2)
  return math_floor(nTime1 / 86400) == math_floor(nTime2 / 86400)
end
function TimeUtil.IsToday(endTime)
  return TimeUtil.IsSameDay(TimeUtil.GetServerTimeInSec(), endTime)
end
function TimeUtil.GetDifferentCountryTimeFormatGMT(nTimeStamp, bStartFromMonth, sFormat_HMS, bOnlyShowTime)
  local nShowIndex = 1
  if bOnlyShowTime then
    nShowIndex = -1
  elseif bStartFromMonth then
    nShowIndex = 2
  end
  return GetDifferentCountryTimeFormat(nTimeStamp, true, true, nShowIndex, sFormat_HMS)
end
function TimeUtil.GetDateByUnixTime(nTimeStamp, bIsToLocalTime)
  local tb = {}
  if not nTimeStamp or nTimeStamp <= 0 or nTimeStamp >= time32_MAX then
    return tb
  end
  if bIsToLocalTime then
    tb = TimeUtil.OSDate("*t", nTimeStamp)
  else
    tb = TimeUtil.OSDate("!*t", nTimeStamp)
  end
  return tb
end
function TimeUtil.GetTodayStartTimestamp(bIsToLocalTime)
  local nTimeStamp = TimeUtil.GetServerTimeInSec()
  local tDateTable = TimeUtil.GetDateByUnixTime(nTimeStamp, bIsToLocalTime)
  if next(tDateTable) then
    nTimeStamp = nTimeStamp - tDateTable.hour * 3600 - tDateTable.min * 60 - tDateTable.sec
  end
  return nTimeStamp
end
function TimeUtil.GetSurvivalTimeOfRank(nTime)
  if type(nTime) ~= "number" then
    return ""
  end
  nTime = math_modf(nTime)
  local months = math_modf(nTime / C_monthUnit)
  if 1 <= months then
    local days = math_modf(math_fmod(nTime, C_monthUnit) / C_dayUnit)
    if 0 < days then
      return LocUtil_LocalizeResFormat(301150, months, days)
    else
      return LocUtil_LocalizeResFormat(301151, months)
    end
  end
  local days = math_modf(nTime / C_dayUnit)
  if 1 <= days then
    local hours = math_modf(math_fmod(nTime, C_dayUnit) / C_hourUnit)
    if 0 < hours then
      return LocUtil_LocalizeResFormat(301152, days, hours)
    else
      return LocUtil_LocalizeResFormat(301153, days)
    end
  end
  local hours = math_modf(nTime / C_hourUnit)
  if 1 <= hours then
    local mins = math_modf(math_fmod(nTime, C_hourUnit) / C_minUnit)
    if 0 < mins then
      return LocUtil_LocalizeResFormat(301154, hours, mins)
    else
      return LocUtil_LocalizeResFormat(301155, hours)
    end
  end
  local mins = math_modf(nTime / C_minUnit)
  local last_tm = math_fmod(nTime, C_minUnit)
  if 1 <= mins then
    return LocUtil_LocalizeResFormat(301156, mins)
  end
  return LocUtil_LocalizeResFormat(301157, last_tm)
end
function TimeUtil.GetLeftTimeStr(nTotalTime)
  if not nTotalTime or type(nTotalTime) ~= "number" then
    return ""
  end
  local nowTime = TimeUtil.GetServerTimeInSec()
  nTotalTime = nTotalTime - nowTime
  if nTotalTime <= 0 then
    return ""
  end
  local days = math_floor(nTotalTime / 86400)
  local hours = math_fmod(math_floor(nTotalTime / 3600), 24)
  local minutes = math_fmod(math_floor(nTotalTime / 60), 60)
  local seconds = math_fmod(nTotalTime, 60)
  local timeStr = ""
  if 0 < days then
    return LocUtil_LocalizeResFormat(4409, days)
  end
  if 0 < hours then
    return LocUtil_LocalizeResFormat(4795, hours)
  end
  if 0 < minutes then
    return LocUtil_LocalizeResFormat(6007, minutes)
  end
  if 0 < seconds then
    return LocUtil_LocalizeResFormat(6704, seconds)
  end
  return timeStr
end
local currentTimeTable
local TimeErrorReport = function(Message)
  return OSTimeError("TimeUtil.OSTime Default " .. Message, currentTimeTable, true)
end
function TimeUtil.OSTime(timeTable)
  currentTimeTable = timeTable
  if timeTable and timeTable.year and type(timeTable.year) == "number" and timeTable.year > 3800 then
    timeTable.year = timeTable.year - 1900
  end
  local bCallSuccess, output = xpcall(os_time, TimeErrorReport, timeTable)
  if bCallSuccess then
    return output
  end
  if type(timeTable) == "table" and timeTable.year and timeTable.month and timeTable.day then
    local newTable = {
      year = timeTable.year,
      month = timeTable.month,
      day = timeTable.day,
      hour = timeTable.hour or 12,
      min = timeTable.min or 0,
      sec = timeTable.sec or 0,
      isdst = timeTable.isdst
    }
    if newTable.year >= 2038 or newTable.month > 12 or newTable.day > 31 or newTable.hour > 24 or newTable.min > 60 or newTable.sec > 60 then
      newTable.min = newTable.min + math_floor(newTable.sec / 60)
      newTable.hour = newTable.hour + math_floor(newTable.min / 60)
      newTable.day = newTable.day + math_floor(newTable.hour / 24)
      newTable.month = newTable.month + math_floor(newTable.day / 30)
      newTable.year = newTable.year + math_floor(newTable.month / 12)
      if newTable.year >= 2038 then
        OSTimeError("TimeUtil.OSTime hit overflow time return = time32_MAX, ", timeTable, false)
        return time32_MAX
      end
    end
    newTable = {
      year = timeTable.year,
      month = timeTable.month,
      day = timeTable.day,
      hour = timeTable.hour or 12,
      min = timeTable.min or 0,
      sec = timeTable.sec or 0,
      isdst = timeTable.isdst
    }
    if newTable.year < 1970 or newTable.month < 1 or newTable.day < 1 or newTable.hour < 0 or newTable.min < 0 or 0 > newTable.sec then
      newTable.min = newTable.min + math_floor(newTable.sec / 60)
      newTable.hour = newTable.hour + math_floor(newTable.min / 60)
      newTable.day = newTable.day + math_floor(newTable.hour / 24)
      newTable.month = newTable.month + math_floor(newTable.day / 30)
      newTable.year = newTable.year + math_floor(newTable.month / 12)
      if newTable.year < 1969 then
        OSTimeError("TimeUtil.OSTime hit underflow time return = 0, ", timeTable, false)
        return 0
      end
    end
    local preDayTable = {
      year = timeTable.year,
      month = timeTable.month,
      day = timeTable.day - 1,
      hour = timeTable.hour or 12,
      min = timeTable.min or 0,
      sec = timeTable.sec or 0,
      isdst = timeTable.isdst
    }
    local bPre, preDate = xpcall(os_time, function(msg)
      msg = msg .. "preDate error "
      return OSTimeError("TimeUtil.OSTime Default summer time pre " .. msg, timeTable, false)
    end, preDayTable)
    if bPre and preDate == -86401 then
      OSTimeError("TimeUtil.OSTime hit overflow time return = -1 ", timeTable, false)
      return -1
    end
    local nextDayTable = {
      year = timeTable.year,
      month = timeTable.month,
      day = timeTable.day + 1,
      hour = timeTable.hour or 12,
      min = timeTable.min or 0,
      sec = timeTable.sec or 0,
      isdst = timeTable.isdst
    }
    local bNext, nextDate = xpcall(os_time, function(msg)
      msg = msg .. "nextDate error "
      return OSTimeError("TimeUtil.OSTime Default summer time next " .. msg, timeTable, false)
    end, nextDayTable)
    if bPre and bNext and nextDate - preDate ~= 172800 then
      OSTimeError("TimeUtil.OSTime hit error summer time return = " .. tostring(preDate + 86400) .. " ", timeTable, false)
      return preDate + 86400
    end
  end
  return 0
end
function TimeUtil.OSDate(format, time)
  local bCallSuccess, output = xpcall(os_date, function(msg)
    return OSDateError("TimeUtil.OSDate default " .. msg, format, time, true)
  end, format, time)
  if bCallSuccess then
    return output
  end
  if time and time >= time32_MAX then
    log(bWriteLog and "TimeUtil.OSDate hit overflow time ")
    local bTryMax, maxOutput = xpcall(os_date, function(msg)
      return OSDateError("TimeUtil.OSDate tryMax error " .. msg, format, time, false)
    end, format, time32_MAX - 86400)
    if bTryMax then
      return maxOutput
    end
  end
  if time and time < 0 then
    log(bWriteLog and "TimeUtil.OSDate hit underflow time ")
    local bTryMin, minOutput = xpcall(os_date, function(msg)
      return OSDateError("TimeUtil.OSDate tryMin error " .. msg, format, time, false)
    end, format, 0)
    if bTryMin then
      return minOutput
    end
  end
  log(bWriteLog and "TimeUtil.OSDate convert error, format is :" .. tostring(format) .. " , time is:" .. tostring(time))
  if Client.IsDevelopment() then
    local _, default = xpcall(os_date, function(msg)
      return OSDateError("TimeUtil.OSDate convert error return 1970" .. msg, format, time, false)
    end, format, 0)
    return default
  else
    local _, default = xpcall(os_date, function(msg)
      return OSDateError("TimeUtil.OSDate convert error return curtime " .. msg, format, time, false)
    end, format)
    return default
  end
end
function TimeUtil.SetServerTimeInSec(serverTime)
  if serverTime == nil then
    return
  end
  TimeUtil.nLocalTimeTick = 0
  nLastServerTime = serverTime
  nLastServerTimeWithFraction = serverTime
end
function TimeUtil.GetServerTimeInSec()
  if nLastServerTime == 0 then
    return TimeUtil.OSTime()
  end
  return nLastServerTime + math_ceil(TimeUtil.nLocalTimeTick)
end
function TimeUtil.GetServerTimeInSecWithFraction()
  if nLastServerTimeWithFraction == 0 then
    return TimeUtil.OSTime()
  end
  return nLastServerTimeWithFraction + TimeUtil.nLocalTimeTick
end
function TimeUtil.CheckAfterTimeStr(timeStr)
  if timeStr == "" then
    return true
  end
  local timeStamp = TimeUtil.TimeStringToUnixstamp(timeStr)
  if timeStamp > TimeUtil.GetServerTimeInSec() then
    return false
  end
  return true
end
function TimeUtil.GetDaysInMonth(month)
  month = month or TimeUtil.OSDate("%m")
  local year = tonumber(TimeUtil.OSDate("%Y"))
  if month == 12 then
    year = year + 1
    month = 1
  else
    month = month + 1
  end
  local t = TimeUtil.OSTime({
    year = year,
    month = month,
    day = 0
  })
  return TimeUtil.OSDate("*t", t).day
end
function TimeUtil.GetYearsBetween(start_time, end_time)
  local end_date = TimeUtil.OSDate("*t", end_time)
  local strat_date = TimeUtil.OSDate("*t", start_time)
  local end_year = end_date.year
  local start_year = strat_date.year
  if end_year <= start_year then
    return 0
  end
  local year_diff = end_year - start_year
  local end_month = end_date.month
  local start_month = strat_date.month
  if end_month > start_month then
    return year_diff
  elseif end_month < start_month then
    return year_diff - 1
  else
    local end_day = end_date.day
    local start_day = strat_date.day
    if end_day > start_day then
      return year_diff
    elseif end_day < start_day then
      return year_diff - 1
    else
      return year_diff
    end
  end
end
function TimeUtil.GetNextDayZeroTime()
  local cur_time = TimeUtil.GetServerTimeInSec()
  local temp_date = TimeUtil.OSDate("!*t", cur_time + 86400)
  local diff_time = TimeUtil.GetTimeZone() * 3600
  local next_day_UnixTime = TimeUtil.OSTime({
    year = temp_date.year,
    month = temp_date.month,
    day = temp_date.day,
    hour = 0
  })
  local next_day_time0 = next_day_UnixTime + diff_time
  return next_day_time0
end
return TimeUtil