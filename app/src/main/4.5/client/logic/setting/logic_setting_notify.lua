local logic_setting_notify = {}
local FCMPushHandler = require("client.network.Protocol.FCMPushHandler")
local TimeUtil = require("client.common.time_util")
local _switch_cfg, _can_not_set_ids, _once_get_callback
local IntimateOnlineFuncId = 5
local BackUserFirstOnlineFuncId = 6
local BackUserOtherOnlineFuncId = 7
function logic_setting_notify.TryGetFcmSwitchInfo(callback)
  if _switch_cfg then
    callback(_switch_cfg, _can_not_set_ids)
    _switch_cfg = nil
    return
  end
  _once_get_  FCMPushHandler.send_get_fcm_switch_info_req()
end
function logic_setting_notify.InitFcmSwitchInfo(switch_cfg, can_not_set_ids)
  _  can_not_set_ids = can_not_set_ids or {}
  local tmpSet = {}
  for i = 1, #can_not_set_ids do
    local id = can_not_set_ids[i]
    if id ~= nil then
      tmpSet[id] = true
    end
  end
  _can_not_set_ids = tmpSet
  if _once_get_callback then
    _once_get_callback(_switch_cfg, _can_not_set_ids)
    _once_get_callback = nil
  end
end
function logic_setting_notify.ProcessOnlinePush()
  local data_config_marco = require("client.logic.data.data_config_marco")
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  BasicDataServerTable:GetOrReqData(data_config_marco.fcm_msg_client_table, function()
    local fcm_switch_cfg = DataMgr.roleData.fcm_switch_cfg
    print(bWriteLog and "logic_setting_notify.ProcessOnlinePush " .. #fcm_switch_cfg)
    logic_setting_notify._ProcessTotal(fcm_switch_cfg)
  end)
end
function logic_setting_notify.IsMyselfSwitchOpen(func_id)
  if _can_not_set_ids and _can_not_set_ids[func_id] then
    log(bWriteLog and "logic_setting_notify.IsMyselfSwitchOpen in can_not_set_ids. " .. func_id)
    return true
  end
  local fcm_switch_data = DataMgr.roleData.fcm_switch_data
  if fcm_switch_data then
    log(bWriteLog and string.format(" logic_setting_notify.IsMyselfSwitchOpen ret:%s", fcm_switch_data[func_id]))
    return fcm_switch_data[func_id]
  end
  local fcm_switch_cfg = DataMgr.roleData.fcm_switch_cfg
  if fcm_switch_cfg then
    log(bWriteLog and string.format(" logic_setting_notify.IsMyselfSwitchOpen ret default:%s", fcm_switch_cfg[func_id].is_default_open))
    return fcm_switch_cfg[func_id].is_default_open
  end
  log(bWriteLog and " logic_setting_notify.IsMyselfSwitchOpen ret false")
  return false
end
function logic_setting_notify.IsBackFirstDay()
  return logic_setting_notify._IsBackFirstDay()
end
function logic_setting_notify._ProcessTotal(switch_cfg)
  local TimeTicker = require("common.time_ticker")
  local prefilter = function(idx, func_id, cfg)
    if cfg then
      local needProcess = true
      if cfg.is_all_open_limit == 1 and logic_setting_notify.IsMyselfSwitchOpen(func_id) == false then
        needProcess = false
      end
      if needProcess then
        TimeTicker.AddTimerOnce(idx, function()
          logic_setting_notify._ProcessAfterFilter(func_id, cfg.is_all_open_limit)
        end)
      end
    end
  end
  prefilter(0, IntimateOnlineFuncId, switch_cfg[IntimateOnlineFuncId])
  prefilter(1, BackUserFirstOnlineFuncId, switch_cfg[BackUserFirstOnlineFuncId])
  prefilter(2, BackUserOtherOnlineFuncId, switch_cfg[BackUserOtherOnlineFuncId])
end
function logic_setting_notify._ProcessAfterFilter(func_id, is_all_open_limit)
  print(bWriteLog and string.format(" logic_setting_notify._ProcessAfterFilter func_id:%s, is_all_open_limit:%s", func_id, is_all_open_limit))
  local data_config_marco = require("client.logic.data.data_config_marco")
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local fcm_msg_client_table = BasicDataServerTable:GetCacheData(data_config_marco.fcm_msg_client_table) or {}
  log_tree(" logic_setting_notify._ProcessAfterFilter fcm_msg_client_table", fcm_msg_client_table)
  local push_logindays_min = tonumber(fcm_msg_client_table.push_logindays_min) or 100
  local push_Intimacy_min = tonumber(fcm_msg_client_table.push_Intimacy_min) or 10
  local push_friends = tonumber(fcm_msg_client_table.push_friends) or 10
  local cli_trigger_day_num = tonumber(fcm_msg_client_table.cli_trigger_day_num) or 100
  local logic_fcm_push = require("client.slua.logic.push.logic_fcm_push")
  if func_id == IntimateOnlineFuncId then
    local hasToday, count = logic_fcm_push.GetRecordOfTodayByKey("OnlineFCMPush_" .. func_id)
    print(bWriteLog and string.format(" logic_setting_notify._ProcessAfterFilter hasToday:%s, count:%s", hasToday, count))
    if not hasToday or cli_trigger_day_num > count then
      local PersonSpaceRelationship = require("client.logic.personspace.logic_person_space_relationship")
      PersonSpaceRelationship.InitStatusData()
      PersonSpaceRelationship.UpdataRelationStatusData()
      log_tree(" _ProcessAfterFilter", PersonSpaceRelationship.RelationShip_Status)
      local frd_uids = {}
      local targetNeedOpen = is_all_open_limit == 1
      for k, v in pairs(PersonSpaceRelationship.RelationShip_Status) do
        if v.InitmacyFriendList then
          table.sort(v.InitmacyFriendList, function(a, b)
            return a.intimacy > b.intimacy
          end)
          for kk, vv in ipairs(v.InitmacyFriendList) do
            if logic_setting_notify._CheckCond(vv.gid, vv.intimacy, func_id, targetNeedOpen, push_logindays_min, push_Intimacy_min) then
              frd_uids[#frd_uids + 1] = tonumber(vv.gid)
            end
          end
        end
      end
      logic_setting_notify._FilterFriendsMax(frd_uids, push_friends)
      if 0 < #frd_uids then
        FCMPushHandler.send_trigger_fcm_msg_req(func_id, frd_uids)
        logic_fcm_push.SetRecordOfTodayByKey("OnlineFCMPush_" .. func_id)
      end
    end
  end
  if func_id == BackUserFirstOnlineFuncId or func_id == BackUserOtherOnlineFuncId then
    local hasToday, count = logic_fcm_push.GetRecordOfTodayByKey("OnlineFCMPush_" .. func_id)
    print(bWriteLog and string.format(" logic_setting_notify._ProcessAfterFilter hasToday:%s, count:%s", hasToday, count))
    if (not hasToday or cli_trigger_day_num > count) and logic_setting_notify:_IsBackUser() and (func_id == BackUserFirstOnlineFuncId and logic_setting_notify._IsBackFirstDay() or func_id == BackUserOtherOnlineFuncId and logic_setting_notify._IsBackOtherDay()) then
      local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
      local Friends = LogicFriend.GetFriendList(true)
      local frd_uids = {}
      local targetNeedOpen = is_all_open_limit == 1
      for kk, vv in pairs(Friends) do
        if logic_setting_notify._CheckCond(vv.uid, tonumber(vv.intimacy), func_id, targetNeedOpen, push_logindays_min, push_Intimacy_min) then
          frd_uids[#frd_uids + 1] = tonumber(vv.uid)
        end
      end
      logic_setting_notify._FilterFriendsMax(frd_uids, push_friends)
      if 0 < #frd_uids then
        FCMPushHandler.send_trigger_fcm_msg_req(func_id, frd_uids)
        logic_fcm_push.SetRecordOfTodayByKey("OnlineFCMPush_" .. func_id)
      end
    end
  end
end
function logic_setting_notify._IsBackUser()
  local logic_player_return = require("client.slua.logic.player_return.logic_player_return")
  local ret = logic_player_return.isPlayerReturnOpenNew()
  print(bWriteLog and string.format(" logic_setting_notify._IsBackUser ret:%s", ret))
  return ret
end
function logic_setting_notify._IsBackFirstDay()
  if not DataMgr.roleData.back_user_data then
    return false
  end
  local rejoin_start_time = DataMgr.roleData.back_user_data.rejoin_start_time
  local now = TimeUtil.GetServerTimeInSec()
  local ret = TimeUtil.IsSameDay(now, rejoin_start_time)
  print(bWriteLog and string.format(" logic_setting_notify._IsBackFirstDay ret:%s", ret))
  return ret
end
function logic_setting_notify._IsBackOtherDay()
  local rejoin_start_time = DataMgr.roleData.back_user_data.rejoin_start_time
  local now = TimeUtil.GetServerTimeInSec()
  local ret = not TimeUtil.IsSameDay(now, rejoin_start_time)
  print(bWriteLog and string.format(" logic_setting_notify._IsBackOtherDay ret:%s", ret))
  return ret
end
function logic_setting_notify._CheckCond(uid, intimacy, func_id, targetNeedOpen, push_logindays_min, push_Intimacy_min)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(uid)
  if not profile then
    log(bWriteLog and " logic_setting_notify._CheckCond no profile. uid:" .. uid)
    return false
  end
  if targetNeedOpen then
    local fcm_switch_data = profile.fcm_switch_data
    if fcm_switch_data and fcm_switch_data[func_id] == false then
      log(bWriteLog and " logic_setting_notify._CheckCond failed fcm_switch_data. uid:" .. uid)
      return false
    end
  end
  local lasttime = profile.lastOnlineTime
  local now = TimeUtil.GetServerTimeInSec()
  if lasttime and now - lasttime < push_logindays_min * 86400 then
  else
    log(bWriteLog and " logic_setting_notify._CheckCond failed online time. uid:" .. uid .. " lasttime:" .. tostring(lasttime) .. " now:" .. tostring(now))
    return false
  end
  if intimacy and push_Intimacy_min < intimacy then
  else
    log(bWriteLog and " logic_setting_notify._CheckCond failed intimacy. uid:" .. uid .. " intimacy:" .. tostring(intimacy))
    return false
  end
  return true
end
function logic_setting_notify._FilterFriendsMax(list, push_friends)
  log(bWriteLog and string.format(" logic_setting_notify._FilterFriendsMax before len #list:%s", #list))
  local len = #list
  if push_friends < len then
    for i = len, push_friends + 1, -1 do
      table.remove(list, i)
    end
  end
  log(bWriteLog and string.format(" logic_setting_notify._FilterFriendsMax after len #list:%s", #list))
end
return logic_setting_notify