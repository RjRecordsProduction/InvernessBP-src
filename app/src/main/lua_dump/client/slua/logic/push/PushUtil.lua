local PushUtil = {}
function PushUtil:_IsValidKey(str, key)
  if str and tostring(str) ~= "" and tostring(str) ~= "0" and key and tostring(key) ~= "" then
    local StringUtil = require("common.string_util")
    local list = StringUtil.Split(str, ";")
    if list and next(list) then
      for _, v in pairs(list) do
        if string.lower(tostring(v)) == string.lower(tostring(key)) then
          return true
        end
      end
    end
    return false
  end
  return true
end
function PushUtil:CheckPushNightTime(data)
  if not (data and data.id and data.hour) or tonumber(data.id) <= 0 then
    return
  end
  local strRegion = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local ConstPush = require("client.slua.logic.push.ConstPush")
  local StartHour = ConstPush.PUSH_START_HOUR
  if strRegion == PublishRegionMacros.KOREA then
    StartHour = ConstPush.PUSH_START_HOUR_KR
  end
  local EndHour = ConstPush.PUSH_END_HOUR
  if strRegion == PublishRegionMacros.KOREA then
    EndHour = ConstPush.PUSH_END_HOUR_KR
  end
  if StartHour > data.hour or EndHour <= data.hour then
    if math.abs(data.hour - StartHour) < math.abs(data.hour - EndHour) then
      data.hour = 12
    else
      data.hour = EndHour - 1
    end
    data.minute = 0
    data.second = 0
  end
end
function PushUtil:GetPushSetDataByID(id, pushTime, cfg)
  local TimeUtil = require("client.common.time_util")
  local nowClient = TimeUtil.OSTime()
  local endTime = TimeUtil.TimeStringToUnixstamp(cfg.end_time)
  if pushTime < nowClient or pushTime > endTime then
    log(bWriteLog and "LocalPushSetInfo:PushUtil:GetPushData not match time pushTime:" .. tostring(pushTime) .. " nowClient:" .. tostring(nowClient) .. " endTime:" .. tostring(endTime) .. " id:" .. tostring(id))
    return nil
  end
  local retData = {id = id}
  local date = TimeUtil.GetDateByUnixTime(pushTime, true)
  retData.year = date.year or 0
  retData.month = date.month or 0
  retData.day = date.day or 0
  retData.hour = date.hour or 0
  retData.minute = date.min or 0
  retData.second = date.sec or 0
  retData.title = cfg.push_title_client
  retData.body = cfg.push_content_client
  retData.priority = cfg.push_priority
  retData.push_id = self:GetPushIDByID(id)
  retData.type = cfg.push_type
  retData.cond1 = cfg.push_cond1
  retData.param1 = cfg.push_param1
  retData.pushTimeSec = pushTime
  self:CheckPushNightTime(retData)
  return retData
end
function PushUtil:GetConditionValue(cfg, condID)
  if not condID or condID <= 0 or not cfg then
    return nil
  end
  if cfg.push_cond1 == condID then
    return cfg.push_param1
  elseif cfg.push_cond2 == condID then
    return cfg.push_param2
  elseif cfg.push_cond3 == condID then
    return cfg.push_param3
  elseif cfg.push_cond4 == condID then
    return cfg.push_param4
  end
  return nil
end
function PushUtil:ResetPushIDByPriority(data1, data2)
  if not (data1 and data2 and data1.id and data2.id) or data1.id == 0 or data2.id == 0 then
    return data1
  end
  if data1.priority > data2.priority then
    log(bWriteLog and string.format("LocalPushSetInfo:PushUtil:ResetPushIDByPriority priority1(%s) > priority2(%s), id2(%s) = 0, id1(%s)", tostring(data1.priority), tostring(data2.priority), tostring(data2.id), tostring(data1.id)))
    data2.id = 0
    return data1
  elseif data1.priority == data2.priority then
    if data1.type == data2.type and data1.cond1 == data2.cond1 and data1.param1 == data2.param1 then
      local random = math.random(1, 2)
      if 1 < random then
        log(bWriteLog and string.format("LocalPushSetInfo:PushUtil:ResetPushIDByPriority priority1(%s) == priority2(%s), random(%s), id2(%s) = 0, id1(%s), type(%s), cond1(%s), param1(%s)", tostring(data1.priority), tostring(data2.priority), tostring(random), tostring(data2.id), tostring(data1.id), tostring(data1.type), tostring(data1.cond1), tostring(data1.param1)))
        data2.id = 0
        return data1
      else
        log(bWriteLog and string.format("LocalPushSetInfo:PushUtil:ResetPushIDByPriority priority1(%s) == priority2(%s), random(%s), id1(%s) = 0, id2(%s), type(%s), cond1(%s), param1(%s)", tostring(data1.priority), tostring(data2.priority), tostring(random), tostring(data1.id), tostring(data2.id), tostring(data1.type), tostring(data1.cond1), tostring(data1.param1)))
        data1.id = 0
        return data2
      end
    elseif data1.type > data2.type or data1.cond1 > data2.cond1 and data1.param1 > data2.param1 then
      log(bWriteLog and string.format("LocalPushSetInfo:PushUtil:ResetPushIDByPriority priority1(%s) == priority2(%s), id2(%s) = 0, id1(%s), type1(%d)type2(%s), cond1(%d)cond2(%s), param1(%s)param2(%s)", tostring(data1.priority), tostring(data2.priority), tostring(data2.id), tostring(data1.id), tostring(data1.type), tostring(data2.type), tostring(data1.cond1), tostring(data2.cond1), tostring(data1.param1), tostring(data2.param1)))
      data2.id = 0
      return data1
    else
      log(bWriteLog and string.format("LocalPushSetInfo:PushUtil:ResetPushIDByPriority priority1(%s) == priority2(%s), id1(%s) = 0, id2(%s), type1(%d)type2(%s), cond1(%s)cond2(%s), param1(%s)param2(%s)", tostring(data1.priority), tostring(data2.priority), tostring(data1.id), tostring(data2.id), tostring(data1.type), tostring(data2.type), tostring(data1.cond1), tostring(data2.cond1), tostring(data1.param1), tostring(data2.param1)))
      data1.id = 0
      return data2
    end
  else
    log(bWriteLog and string.format("LocalPushSetInfo:PushUtil:ResetPushIDByPriority priority1(%s) < priority2(%s), id1(%s) = 0, id2(%s)", tostring(data1.priority), tostring(data2.priority), tostring(data1.id), tostring(data2.id)))
    data1.id = 0
  end
  return data2
end
function PushUtil:CheckSameDayPush(pushTable, retData)
  if not (retData and retData.id and not (tonumber(retData.id) <= 0) and pushTable) or not next(pushTable) then
    return
  end
  for i, v in pairs(pushTable) do
    local tmpRetData = retData
    if v.year == retData.year and v.month == retData.month and v.day == retData.day then
      tmpRetData = self:ResetPushIDByPriority(retData, v)
      if v.id == 0 then
        pushTable[i] = nil
      end
    end
    if v.cycleTable and next(v.cycleTable) then
      for j, u in pairs(v.cycleTable) do
        if u.year == tmpRetData.year and u.month == tmpRetData.month and u.day == tmpRetData.day then
          tmpRetData = self:ResetPushIDByPriority(tmpRetData, u)
          if u.id == 0 then
            pushTable[j] = nil
          end
        end
      end
    end
  end
end
function PushUtil:GetPushIDByID(id)
  if not id or tonumber(id) == 0 then
    return id
  end
  local push_id = math.floor(math.fmod(id, 100000) / 100)
  return push_id
end
return PushUtil