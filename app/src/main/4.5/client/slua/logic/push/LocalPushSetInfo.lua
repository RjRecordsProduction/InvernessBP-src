local LocalPushSetInfo = {}
function LocalPushSetInfo:_GetPushPassUnlock(cfg, id)
  local retData
  local TimeUtil = require("client.common.time_util")
  local PushUtil = require("client.slua.logic.push.PushUtil")
  local nowClient = TimeUtil.OSTime()
  local endTime = TimeUtil.TimeStringToUnixstamp(cfg.end_time)
  local curTime = nowClient
  while curTime < nowClient + 604800 and endTime > curTime do
    curTime = curTime + 86400
    local week = TimeUtil.GetWeekDayByTime(curTime, true)
    if week == cfg.cycle_time then
      retData = PushUtil:GetPushSetDataByID(id, curTime, cfg)
      break
    end
  end
  return retData
end
function LocalPushSetInfo:_GetPushBirthDay(cfg, id)
  local SocialCardSystem = require("client.slua.logic.lobby.Left.logic_social_card")
  if not (SocialCardSystem.SocialCard and SocialCardSystem.SocialCard.birthday) or SocialCardSystem.SocialCard.birthday == "" then
    log(bWriteLog and string.format("LocalPushSetInfo:LocalPushSetInfo:_GetPushBirthDay not SocialCard or not birthday id:%s", tostring(id)))
    return nil
  end
  local TimeUtil = require("client.common.time_util")
  local PushUtil = require("client.slua.logic.push.PushUtil")
  local nowClient = TimeUtil.OSTime()
  local StringUtil = require("common.string_util")
  local birthDate = SocialCardSystem.SocialCard.birthday
  local m = StringUtil.Split(birthDate, "-")[2]
  local d = StringUtil.Split(birthDate, "-")[3]
  local y = TimeUtil.OSDate("*t").year
  local happyBirthDate = string.format("%s-%s-%s 00:00:00", y, m, d)
  local birthUTC = TimeUtil.TimeStringToUnixstamp(happyBirthDate)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local needNextYear = false
  local birthdayPushData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eBirthdayPush)
  if birthdayPushData and TimeUtil.IsSameDay(tonumber(birthdayPushData.birthUTC), birthUTC) then
    needNextYear = true
  end
  if nowClient > birthUTC + 86400 or needNextYear then
    y = tonumber(y) + 1
    happyBirthDate = string.format("%d-%s-%s 00:00:00", y, m, d)
    birthUTC = TimeUtil.TimeStringToUnixstamp(happyBirthDate)
  end
  local pushTimeSec = 0
  if nowClient > birthUTC then
    pushTimeSec = nowClient + 20
    local data = {}
    data.    PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.eBirthdayPush)
  else
    pushTimeSec = birthUTC
  end
  local retData = PushUtil:GetPushSetDataByID(id, pushTimeSec, cfg)
  log(bWriteLog and string.format("LocalPushSetInfo:LocalPushSetInfo:_GetPushBirthDay pushTimeSec:%s id:%s", tostring(TimeUtil.FormatTime_MDHMS(pushTimeSec)), tostring(id)))
  return retData
end
function LocalPushSetInfo:_GetPushPassScoreUnUse(cfg, id)
  local retData
  local TimeUtil = require("client.common.time_util")
  local ConstPush = require("client.slua.logic.push.ConstPush")
  local PushUtil = require("client.slua.logic.push.PushUtil")
  local nowClient = TimeUtil.OSTime()
  local endTime = TimeUtil.TimeStringToUnixstamp(cfg.end_time)
  local curDiffDay = 90
  local curTime = endTime - 86400 * curDiffDay
  local diffDay = tonumber(PushUtil:GetConditionValue(cfg, ConstPush.Enum_Condition_Type.Enum_PassEndDay))
  while endTime > curTime do
    if curDiffDay == diffDay then
      if nowClient < curTime then
        retData = PushUtil:GetPushSetDataByID(id, curTime, cfg)
      end
      break
    end
    curTime = curTime + 86400
    curDiffDay = curDiffDay - 1
  end
  return retData
end
function LocalPushSetInfo:_GetPushAllStar(cfg, id)
  local retData
  local ESportAllStarSystem = require("client.slua.logic.esport.logic_esport_allstar")
  local _, time = ESportAllStarSystem.CheckPushConditionTime(tonumber(cfg.push_param1))
  if time ~= 0 then
    local PushUtil = require("client.slua.logic.push.PushUtil")
    retData = PushUtil:GetPushSetDataByID(id, time - 600, cfg)
  end
  return retData
end
function LocalPushSetInfo:_SetPushActivity(cfg)
  local ActivityPushSystem = require("client.slua.logic.activity.logic_activity_push")
  local TimeUtil = require("client.common.time_util")
  local pushData = {
    nActId = cfg.push_param1,
    loginDay = cfg.push_param2,
    ucNum = cfg.push_param3,
    startTime = TimeUtil.TimeStringToUnixstamp(cfg.start_time),
    nEndTime = TimeUtil.TimeStringToUnixstamp(cfg.end_time)
  }
  ActivityPushSystem.SetPush(pushData)
end
function LocalPushSetInfo:_GetPushLossLogin(cfg, id)
  local retData
  local logic_prechurn_loginreward = require("client.slua.logic.activity.logic_prechurn_loginreward")
  local time = logic_prechurn_loginreward.GetNextLocalPushTime()
  if time then
    local PushUtil = require("client.slua.logic.push.PushUtil")
    retData = PushUtil:GetPushSetDataByID(id, time, cfg)
  end
  return retData
end
function LocalPushSetInfo:_GetSpecialTypePushTime(pushType)
  local logic_popular_pk_push = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_popular_pk_push)
  local ConstPush = require("client.slua.logic.push.ConstPush")
  if pushType == ConstPush.Enum_Push_Type.Enum_TeamPK_Start then
    return logic_popular_pk_push:GetTeamPkStartPushTime()
  elseif pushType == ConstPush.Enum_Push_Type.Enum_TeamPK_End then
    return logic_popular_pk_push:GetTeamPkEndingPushTime()
  elseif pushType == ConstPush.Enum_Push_Type.Enum_PopularPK_Start then
    return logic_popular_pk_push:GetPopularPkStartPushTime()
  elseif pushType == ConstPush.Enum_Push_Type.Enum_PopularPK_End then
    return logic_popular_pk_push:GetPopularPkEndingPushTime()
  end
  return nil
end
function LocalPushSetInfo:_GetPushSpecial(cfg, id)
  local retData
  local time = self:_GetSpecialTypePushTime(cfg.push_type)
  log(bWriteLog and "LocalPushSetInfo:_GetPushSpecial, cfg.push_type is:" .. tostring(cfg.push_type) .. ", time is: " .. tostring(time))
  if time then
    local PushUtil = require("client.slua.logic.push.PushUtil")
    retData = PushUtil:GetPushSetDataByID(id, time, cfg)
  end
  return retData
end
function LocalPushSetInfo:_GetPushPeakGameStartTime(cfg, id)
  local retDataList = {}
  local peakgame_start_time_list = DataMgr.roleData.peakgame_start_time_list
  local new_  if peakgame_start_time_list and next(peakgame_start_time_list) then
    local PushUtil = require("client.slua.logic.push.PushUtil")
    for index, time in pairs(peakgame_start_time_list) do
      local retData = PushUtil:GetPushSetDataByID(new_id, time, cfg)
      if retData then
        table.insert(retDataList, retData)
        new_id = new_id + 1
      end
    end
  end
  log_tree("LocalPushSetInfo:_GetPushPeakGameStartTime retDataList = ", retDataList)
  return retDataList
end
function LocalPushSetInfo:_GetCrazyWeekendActOpenDay(pushData, cfg)
  log(bWriteLog and "LocalPushSetInfo:_GetCrazyWeekendActOpenDay")
  if not pushData then
    log(bWriteLog and "LocalPushSetInfo:_GetCrazyWeekendActOpenDay pushData is nil")
    return nil
  end
  local curTime = pushData.pushTimeSec
  local TimeUtil = require("client.common.time_util")
  local logic_crazy_weekend_teamUp_activity = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_crazy_weekend_teamUp_activity)
  local openDay = logic_crazy_weekend_teamUp_activity.weekDays[1]
  if openDay and 0 < openDay then
    local curWeekDay = TimeUtil.GetWeekDayByTime(pushData.pushTimeSec, true)
    if openDay < curWeekDay then
      pushData.pushTimeSec = curTime + 86400 * (7 - (curWeekDay - openDay))
    elseif openDay > curWeekDay then
      pushData.pushTimeSec = curTime + 86400 * (openDay - curWeekDay)
    end
    local PushUtil = require("client.slua.logic.push.PushUtil")
    log_format("bWriteLog and LocalPushSetInfo:_GetCrazyWeekendActOpenDay curTime:%s, openDay:%s", tostring(TimeUtil.FormatTime_MDHMS(pushData.pushTimeSec)), openDay)
    return PushUtil:GetPushSetDataByID(pushData.id, pushData.pushTimeSec, cfg)
  else
    log(bWriteLog and "LocalPushSetInfo:_GetCrazyWeekendActOpenDay openDay is nil")
    pushData.id = 0
  end
end
function LocalPushSetInfo:_SetCycleTable(pushData, cfg)
  if not (pushData and pushData.id) or tonumber(pushData.id) <= 0 then
    return
  end
  if not (cfg and cfg.cycle_type) or 0 >= cfg.cycle_type then
    return
  end
  local TimeUtil = require("client.common.time_util")
  local ConstPush = require("client.slua.logic.push.ConstPush")
  local PushUtil = require("client.slua.logic.push.PushUtil")
  pushData.cycleTable = {}
  local endTime = TimeUtil.TimeStringToUnixstamp(cfg.end_time)
  local curTime = pushData.pushTimeSec
  local indexID = pushData.id
  local cycleTime = 0
  if cfg.cycle_type == ConstPush.Enum_Cycle_Type.Enum_Day then
    cycleTime = 86400 * tonumber(cfg.cycle_time)
  elseif cfg.cycle_type == ConstPush.Enum_Cycle_Type.Enum_Week then
    cycleTime = 604800
    if cfg.cycle_time and 0 < tonumber(cfg.cycle_time) then
      local curWeekDay = TimeUtil.GetWeekDayByTime(pushData.pushTimeSec, true)
      if curWeekDay > tonumber(cfg.cycle_time) then
        pushData.pushTimeSec = curTime + 86400 * (7 - (curWeekDay - tonumber(cfg.cycle_time)))
      elseif curWeekDay < tonumber(cfg.cycle_time) then
        pushData.pushTimeSec = curTime + 86400 * (tonumber(cfg.cycle_time) - curWeekDay)
      end
      curTime = pushData.pushTimeSec
      PushUtil:GetPushSetDataByID(pushData.id, pushData.pushTimeSec, cfg)
    end
  elseif cfg.cycle_type == ConstPush.Enum_Cycle_Type.Enum_Month then
    if cfg.cycle_time and 0 < tonumber(cfg.cycle_time) then
      local curWeekDay = TimeUtil.GetWeekDayByTime(pushData.pushTimeSec, true)
      local date = TimeUtil.GetDateByUnixTime(pushData.pushTimeSec, true)
      local curMonthDay = date.day or 0
      if curMonthDay > tonumber(cfg.cycle_time) then
        local nextYear = date.year
        local nextMonth = date.month
        local nextDay = tonumber(cfg.cycle_time)
        if date.month >= 12 then
          nextYear = date.year + 1
          nextMonth = 1
        end
        pushData.pushTimeSec = 0
        local func = function()
          pushData.pushTimeSec = TimeUtil.OSTime({
            year = nextYear,
            month = nextMonth,
            day = nextDay,
            hour = date.hour,
            min = date.min,
            sec = date.sec
          })
        end
        local utility = require("common.utility")
        xpcall(func, utility.ErrorMessageHandler)
      elseif curWeekDay < tonumber(cfg.cycle_time) then
        pushData.pushTimeSec = curTime + 86400 * (tonumber(cfg.cycle_time) - curMonthDay)
      end
      curTime = pushData.pushTimeSec
      PushUtil:GetPushSetDataByID(pushData.id, pushData.pushTimeSec, cfg)
    end
    while endTime > curTime do
      local date = TimeUtil.GetDateByUnixTime(curTime, true)
      local maxDay = TimeUtil.GetMonthMaxDay(date.year or 0, date.month or 0)
      curTime = curTime + 86400 * maxDay
      indexID = indexID + 1
      local cycleItem = PushUtil:GetPushSetDataByID(indexID, curTime, cfg)
      if cycleItem then
        pushData.cycleTable[indexID] = cycleItem
      end
    end
  end
  if 0 < cycleTime and 0 < curTime then
    while endTime > curTime do
      curTime = curTime + cycleTime
      if endTime >= curTime then
        indexID = indexID + 1
        local cycleItem = PushUtil:GetPushSetDataByID(indexID, curTime, cfg)
        if cycleItem then
          pushData.cycleTable[indexID] = cycleItem
        end
      end
    end
  end
end
function LocalPushSetInfo:GetPushSetInfo(id, cfg, pushTable)
  local TimeUtil = require("client.common.time_util")
  local ConstPush = require("client.slua.logic.push.ConstPush")
  local PushUtil = require("client.slua.logic.push.PushUtil")
  local retData
  local nowClient = TimeUtil.OSTime()
  local retData2
  pushTable = pushTable or {}
  if cfg.push_type == ConstPush.Enum_Push_Type.Enum_PassUnlock then
    retData = self:_GetPushPassUnlock(cfg, id)
  elseif cfg.push_type == ConstPush.Enum_Push_Type.Enum_Birthday then
    retData = self:_GetPushBirthDay(cfg, id)
  elseif cfg.push_type == ConstPush.Enum_Push_Type.Enum_PassScoreUnUse then
    retData = self:_GetPushPassScoreUnUse(cfg, id)
  elseif cfg.push_type == ConstPush.Enum_Push_Type.Enum_AllStar then
    retData = self:_GetPushAllStar(cfg, id)
  elseif cfg.push_type == ConstPush.Enum_Push_Type.Enum_Activity then
    self:_SetPushActivity(cfg)
  elseif cfg.push_type == ConstPush.Enum_Push_Type.Enum_PreLoss_LoginReward then
    retData = self:_GetPushLossLogin(cfg, id)
  elseif ConstPush.IsSpecialType(cfg.push_type) then
    retData = self:_GetPushSpecial(cfg, id)
  elseif cfg.push_type == ConstPush.Enum_Push_Type.Enum_PeakGame_Start then
    log(bWriteLog and "LocalPushSetInfo:GetPushSetInfo Enum_PeakGame_Start")
    local retDataList = self:_GetPushPeakGameStartTime(cfg, id)
    local PushUtil = require("client.slua.logic.push.PushUtil")
    for key, retDataInfo in pairs(retDataList or {}) do
      PushUtil:CheckSameDayPush(pushTable, retDataInfo)
      if retDataInfo and retDataInfo.id and retDataInfo.id > 0 then
        pushTable[retDataInfo.id] = retDataInfo
      end
    end
    return
  else
    local loginDay = tonumber(PushUtil:GetConditionValue(cfg, ConstPush.Enum_Condition_Type.Enum_LastLoginDay))
    local registerDay = tonumber(PushUtil:GetConditionValue(cfg, ConstPush.Enum_Condition_Type.Enum_RegisterDay))
    if loginDay and 0 < loginDay or registerDay and 0 < registerDay then
      if loginDay and 0 < loginDay then
        retData = PushUtil:GetPushSetDataByID(id, nowClient + 86400 * tonumber(loginDay), cfg)
      end
      if registerDay and 0 < registerDay then
        local registerTime = DataMgr.registertime or nowClient
        if not retData then
          retData = PushUtil:GetPushSetDataByID(id, registerTime + 86400 * tonumber(registerDay), cfg)
        else
          retData2 = PushUtil:GetPushSetDataByID(id, registerTime + 86400 * tonumber(registerDay), cfg)
        end
      end
    else
      retData = PushUtil:GetPushSetDataByID(id, nowClient, cfg)
    end
  end
  if cfg.push_type == ConstPush.Enum_Push_Type.Enum_CrazyWeekend_Start then
    retData = self:_GetCrazyWeekendActOpenDay(retData, cfg)
  end
  if retData and retData.id > 0 then
    self:_SetCycleTable(retData, cfg)
  end
  local PushUtil = require("client.slua.logic.push.PushUtil")
  PushUtil:CheckSameDayPush(pushTable, retData)
  if retData and retData.id > 0 then
    pushTable[retData.id] = retData
  end
  if retData2 and retData2.id > 0 then
    pushTable[retData2.id] = retData2
  end
end
return LocalPushSetInfo