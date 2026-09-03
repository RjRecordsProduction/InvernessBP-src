local logic_home_profile = {}
local TimeUtil = require("client.common.time_util")
function logic_home_profile:OnInitialize()
  log(bWriteLog and "logic_home_profile:OnInitialize")
  self.playerHomeProfile = require("common.LRU")(700, nil)
  self.reqList = {}
  self.sendList = {}
  self.sendSeq = 0
  self.maxSendNum = 100
  self.jointRelationMap = {}
  self.expiredProfileThreshold = 600
  self.updateExpiredProfileCD = 60
  self.lastTimeUpdateExpiredProfile = nil
end
function logic_home_profile:OnDestroy()
  log(bWriteLog and "logic_home_profile:OnDestroy")
  self.playerHomeProfile:Clear()
  self.reqList = {}
  self.sendList = {}
  self.sendSeq = 0
end
function logic_home_profile:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_OLD_WIDGET, EVENTID_ON_ALL_WIDGET_HIDE, self.OnUIHide, self)
end
function logic_home_profile:OnPreSwitchGameStatus(_, nextState)
  log(bWriteLog and "logic_home_profile:OnPreSwitchGameStatus nextState = " .. nextState)
  if nextState == GameStatus.Login then
    self:OnDestroy()
  end
end
function logic_home_profile:HasAllProfileCache(uidList)
  local hasAll = true
  for _, uid in ipairs(uidList) do
    if not self:GetHomeProfileByUid(uid) then
      hasAll = false
      break
    end
  end
  return hasAll
end
function logic_home_profile:GetOrReqHomeProfile(uids, callback, bRealRefresh)
  log(bWriteLog and "logic_home_profile:GetOrReqHomeProfile bRealRefresh = " .. tostring(bRealRefresh))
  log_tree("uids = ", uids)
  local bDelayWithBatch = true
  if self:HasAllProfileCache(uids) then
    bDelayWithBatch = false
  end
  local reqInfo = self:SplitReqInfo(uids, callback, bRealRefresh)
  self.reqList[#self.reqList + 1] = reqInfo
  local logic_home_proto_queue = require("client.slua.logic.home.Profile.logic_home_proto_queue")
  local protoMap = logic_home_proto_queue.requestProtoMap.manor_summarys_req
  if protoMap == nil or not next(protoMap) then
    log(bWriteLog and "logic_home_profile:GetOrReqHomeProfile 1")
    if bDelayWithBatch then
      local time_ticker = require("common.time_ticker")
      time_ticker.AddTimerOnce(0.03, function()
        self:Update()
      end)
    else
      self:Update()
    end
    return
  end
  log(bWriteLog and "logic_home_profile:GetOrReqHomeProfile 2")
  if bDelayWithBatch then
    local time_ticker = require("common.time_ticker")
    time_ticker.AddTimerOnce(0.8, function()
      self:Update()
    end)
  else
    self:Update()
  end
end
function logic_home_profile:SplitReqInfo(uidList, callback, bRealRefresh)
  log(bWriteLog and "logic_home_profile:SplitReqInfo")
  local notGetUidMap = {}
  local notGetUidNum = 0
  if bRealRefresh then
    for _, uid in ipairs(uidList) do
      local uid_number = tonumber(uid)
      if uid_number and not notGetUidMap[uid_number] then
        notGetUidMap[uid_number] = true
        notGetUidNum = notGetUidNum + 1
      end
    end
  else
    for _, uid in ipairs(uidList) do
      local uid_number = tonumber(uid)
      if uid_number then
        local profile = self.playerHomeProfile:Get(uid_number, false)
        if profile then
        elseif not notGetUidMap[uid_number] then
          notGetUidMap[uid_number] = true
          notGetUidNum = notGetUidNum + 1
        end
      end
    end
  end
  log_tree("notGetUidMap = ", notGetUidMap)
  log(bWriteLog and "notGetUidNum = " .. notGetUidNum)
  local reqInfo = {
    notGetUidMap = notGetUidMap,
    notGetUidNum = notGetUidNum,
      }
  return reqInfo
end
function logic_home_profile:MergeReqInfo(newReqInfo, reqInfo)
  log(bWriteLog and "logic_home_profile:MergeReqInfo")
  for uid, v in pairs(reqInfo.notGetUidMap) do
    if not newReqInfo.notGetUidMap[uid] then
      newReqInfo.notGetUidMap[uid] = true
      newReqInfo.notGetUidNum = newReqInfo.notGetUidNum + 1
    end
  end
  newReqInfo.callbackList[#newReqInfo.callbackList + 1] = reqInfo.callback
end
function logic_home_profile:Update()
  log(bWriteLog and "logic_home_profile:Update")
  local reqLen = #self.reqList
  if reqLen == 0 then
    return
  end
  print(bWriteLog and "home_profile_request_merge_comp:Update reqList len = " .. #self.reqList)
  local newReqInfo = {
    notGetUidMap = {},
    notGetUidNum = 0,
    callbackList = {},
    totalCallBack = nil
  }
  for i = 1, reqLen do
    self:MergeReqInfo(newReqInfo, self.reqList[i])
  end
  function newReqInfo.totalCallBack(...)
    for i = 1, #newReqInfo.callbackList do
      newReqInfo.callbackList[i](...)
    end
  end
  self.reqList = {}
  self:_ReqHomeProfile(newReqInfo)
end
function logic_home_profile:_ReqHomeProfile(newReqInfo)
  log(bWriteLog and "logic_home_profile:_ReqHomeProfile")
  log_tree("newReqInfo = ", newReqInfo)
  local cb_data = {}
  if newReqInfo.notGetUidNum > 0 then
    self.sendSeq = self.sendSeq + 1
    cb_data.sendSeq = self.sendSeq
    local binCbDataStr = slua.LuaArchiverEncode(LuaStateWrapper, cb_data)
    local sendCount = 0
    local PHomeProfileHandler = require("client.network.Protocol.PHomeProfileHandler")
    if newReqInfo.notGetUidNum > self.maxSendNum then
      local listSendUid = {}
      local sendUidLen = 0
      for uid, v in pairs(newReqInfo.notGetUidMap) do
        if sendUidLen >= self.maxSendNum then
          local binListUid = slua.LuaArchiverEncode(LuaStateWrapper, listSendUid)
          PHomeProfileHandler.send_manor_summarys_req(binListUid, binCbDataStr)
          sendCount = sendCount + 1
          listSendUid = {}
          sendUidLen = 0
        end
        sendUidLen = sendUidLen + 1
        listSendUid[tonumber(uid)] = true
      end
      if next(listSendUid) then
        local binListUid = slua.LuaArchiverEncode(LuaStateWrapper, listSendUid)
        PHomeProfileHandler.send_manor_summarys_req(binListUid, binCbDataStr)
        sendCount = sendCount + 1
      end
    else
      sendCount = 1
      local binUidsStr = slua.LuaArchiverEncode(LuaStateWrapper, newReqInfo.notGetUidMap)
      PHomeProfileHandler.send_manor_summarys_req(binUidsStr, binCbDataStr)
    end
    self.sendList[self.sendSeq] = {
      callback = newReqInfo.totalCallBack,
          }
    local seq = self.sendSeq
    self:AddTimerOnce(10, function()
      local sendData = self.sendList[seq]
      if sendData then
        log(bWriteLog and "logic_home_profile:_ReqHomeProfile timeout, clean sendSeq = " .. tostring(seq))
        if sendData.callback then
          local utility = require("common.utility")
          xpcall(sendData.callback, utility.ErrorMessageHandler)
        end
        EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_GET_PROFILE)
        self.sendList[seq] = nil
      end
    end)
  else
    if newReqInfo.totalCallBack then
      local utility = require("common.utility")
      xpcall(newReqInfo.totalCallBack, utility.ErrorMessageHandler)
    end
    EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_GET_PROFILE)
  end
end
function logic_home_profile:proc_manor_summarys_rsp(summarys, cb_data)
  log(bWriteLog and "logic_home_profile:proc_manor_summarys_rsp")
  local profiles = self:_DecodeHomeProfile(summarys)
  log_tree("logic_home_profile:proc_manor_summarys_rsp profiles", profiles)
  self:_CallbackHomeProfile(cb_data, profiles)
end
function logic_home_profile:ReqHomeProfileByManorID(manorID)
  log(bWriteLog and string.format("ReqHomeProfileByManorID, manorID:%s", manorID))
  local PHomeProfileHandler = require("client.network.Protocol.PHomeProfileHandler")
  PHomeProfileHandler.send_manor_summary_by_manor_id_req(manorID)
end
function logic_home_profile:proc_manor_summary_by_manor_id_rsp(summary)
  log(bWriteLog and "logic_home_profile:proc_manor_summary_by_manor_id_rsp")
  local profile = self:_DecodeSingleHomeProfile(summary)
  log_tree("logic_home_profile:proc_manor_summary_by_manor_id_rsp profiles", profile)
  EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_GET_PROFILE_BY_MANOR_ID, profile)
end
function logic_home_profile:_DecodeSingleHomeProfile(summary)
  summary = slua.LuaArchiverDecode(LuaStateWrapper, summary)
  local profile = {}
  profile = summary
  if summary.uid ~= profile.joint_id then
    profile.uid = summary.uid
  else
    profile.uid = self:GetRealUID(summary)
  end
  self:_SetDefaultValue(profile)
  self.playerHomeProfile:Set(tonumber(summary.uid), profile, false)
  self:UpdateJointRelationMap(profile, tonumber(summary.uid))
  return profile
end
function logic_home_profile:_DecodeHomeProfile(summarys)
  local profiles = {}
  summarys = slua.LuaArchiverDecode(LuaStateWrapper, summarys)
  for uid, summary in pairs(summarys) do
    local profile = {}
    if type(summary) == "string" then
      profile = slua.LuaArchiverDecode(LuaStateWrapper, summary)
      if profile.manor_not_open == nil then
        if profile.grow_info and next(profile.grow_info) and profile.grow_info.level and profile.grow_info.level > 1 then
          profile.bUnLock = true
        else
          profile.bUnLock = false
        end
      elseif profile.manor_not_open == false then
        profile.bUnLock = true
      else
        profile.bUnLock = false
      end
    elseif type(summary) == "number" and summary == -1 then
      profile.bUnLock = false
    end
    if uid ~= profile.joint_id then
      profile.    else
      profile.uid = self:GetRealUID(profile)
    end
    self:_SetDefaultValue(profile)
    table.insert(profiles, profile)
    self.playerHomeProfile:Set(tonumber(uid), profile, false)
    self:UpdateJointRelationMap(profile, uid)
  end
  return profiles
end
function logic_home_profile:UpdateJointRelationMap(profile, uid)
  if profile.joint_id then
    if profile.joint_id == uid then
      for k, v in pairs(profile.joint_members or {}) do
        self.jointRelationMap[k] = uid
      end
    else
      self.jointRelationMap[profile.joint_id] = uid
      local jointUID = self:GetHomeJointUID(uid)
      if jointUID then
        self.jointRelationMap[jointUID] = uid
      end
    end
    self.jointRelationMap[uid] = uid
  elseif self.jointRelationMap[uid] then
    local keys_to_remove = {}
    for k, v in pairs(self.jointRelationMap) do
      if #keys_to_remove == 3 then
        break
      end
      if v == uid then
        table.insert(keys_to_remove, k)
      end
    end
    for _, key in ipairs(keys_to_remove) do
      self.jointRelationMap[key] = nil
    end
  end
end
function logic_home_profile:GetRealUID(profile)
  if not profile.joint_members then
    return profile.uid
  end
  if not next(profile.joint_members) then
    return profile.uid
  end
  return next(profile.joint_members)
end
function logic_home_profile:_SetDefaultValue(profile)
  local default_home_profile = require("client.slua.logic.home.Config.default_home_profile")
  local TableUtil = require("common.table_util")
  TableUtil.FillDefaults(profile, default_home_profile)
  if not profile.manor_id or profile.manor_id == 0 then
    profile.manor_id = profile.uid
  end
  profile.last_update_time = TimeUtil.GetServerTimeInSec()
end
function logic_home_profile:_CallbackHomeProfile(cb_data, profiles)
  local cb_data = slua.LuaArchiverDecode(LuaStateWrapper, cb_data) or {}
  local sendSeq = cb_data.sendSeq
  if sendSeq and self.sendList[sendSeq] then
    local sendData = self.sendList[sendSeq]
    sendData.sendCount = sendData.sendCount - 1
    if sendData.sendCount == 0 then
      local callback = sendData.callback
      if callback then
        local utility = require("common.utility")
        xpcall(callback, utility.ErrorMessageHandler)
      end
      EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVENTID_PLANPH_GET_PROFILE)
      self.sendList[sendSeq] = nil
    else
      log(bWriteLog and "logic_home_profile:_CallbackHomeProfile waiting for the remaining response")
    end
  end
  local logic_housekeeper_dialog_battle = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_housekeeper_dialog_battle)
  logic_housekeeper_dialog_battle:proc_manor_summarys_rsp(profiles)
end
function logic_home_profile:GetHomeProfileByUid(uid, bCheckTtl)
  log(bWriteLog and "logic_home_profile:GetHomeProfileByUid uid = " .. tostring(uid))
  if uid == nil then
    return nil
  end
  local profile
  local relationUID = self.jointRelationMap[uid]
  if relationUID then
    profile = self.playerHomeProfile:Get(tonumber(relationUID), bCheckTtl)
    if profile then
      profile.uid = tonumber(uid)
    end
  else
    profile = self.playerHomeProfile:Get(tonumber(uid), bCheckTtl)
  end
  if profile == nil then
    log(bWriteLog and "logic_home_profile:GetHomeProfileByUid. profile = nil")
  end
  return profile
end
function logic_home_profile:GetHomeIdByUid(uid, bCheckTtl)
  log(bWriteLog and "logic_home_profile:GetHomeIdByUid uid = " .. tostring(uid))
  if uid == nil then
    return nil
  end
  local logic_home_joint = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_joint)
  if not self:GetHomeJointUID(uid) then
    return uid
  end
  local profile = self:GetHomeProfileByUid(uid, bCheckTtl)
  if not profile then
    return uid
  end
  if profile.joint_id then
    return profile.joint_id
  end
  return profile.uid
end
function logic_home_profile:ParseUID(uid)
  local result = {}
  result.manor_id = self:GetHomeIdByUid(tonumber(uid))
  log(bWriteLog and "logic_home_profile:ParseUID parse manor_id = " .. tostring(result.manor_id))
  if uid == result.manor_id then
    local list = self:GetHomeJointMemberList(tonumber(uid))
    if not list then
      result.uid = tonumber(uid)
    else
      result.uid = list[1]
      result.joint_uid = list[2]
    end
  else
    result.    result.joint_uid = self:GetHomeJointUID(tonumber(uid))
  end
  if not result.manor_id then
    result.manor_id = tonumber(uid)
  end
  return result
end
function logic_home_profile:GetHomeCoverUrl(uid)
  local profile = self:GetHomeProfileByUid(uid)
  if profile then
    if profile.entrance_thumbnail_pic then
      return profile.entrance_thumbnail_pic, true
    elseif profile.entrance_pic then
      return profile.entrance_pic, false
    end
  end
  return nil, false
end
function logic_home_profile:IsUIDMatchProfile(uid, profile)
  if not profile then
    return false
  end
  if uid == profile.manor_id then
    return true
  end
  if uid == profile.joint_id then
    return true
  end
  if not profile.joint_members then
    return uid == profile.uid
  end
  if not next(profile.joint_members) then
    return uid == profile.uid
  end
  return profile.joint_members[uid] ~= nil
end
function logic_home_profile:IsJointHome(profile)
  if not profile then
    return false
  end
  local TableUtil = require("common.table_util")
  return TableUtil.CountTable(profile.joint_members) > 1
end
function logic_home_profile:GetHomeJointUID(uid)
  local profile = self:GetHomeProfileByUid(uid)
  if not profile then
    return nil
  end
  if not profile.joint_members then
    return nil
  end
  if not next(profile.joint_members) then
    return nil
  end
  for jointUID, _ in pairs(profile.joint_members) do
    if tonumber(jointUID) ~= tonumber(uid) then
      return jointUID
    end
  end
  return nil
end
function logic_home_profile:GetHomeJointMemberList(uid)
  local profile = self:GetHomeProfileByUid(uid)
  if not profile then
    return nil
  end
  if not profile.joint_members then
    return nil
  end
  if not next(profile.joint_members) then
    return nil
  end
  local list = {}
  for uid, _ in pairs(profile.joint_members) do
    table.insert(list, uid)
  end
  return list
end
function logic_home_profile:GetHomeName(uid, skipSetName)
  local name = ""
  local jointNames = {}
  local homeProfile = self:GetHomeProfileByUid(uid)
  if not homeProfile then
    return name, jointNames
  end
  if not skipSetName and homeProfile.name and homeProfile.name ~= "" then
    return homeProfile.name, jointNames
  end
  if homeProfile.joint_members then
    for k, v in pairs(homeProfile.joint_members) do
      if type(v) == "table" then
        table.insert(jointNames, v.name)
      end
    end
    name = LocUtil.LocalizeResFormat(655768, jointNames[1] or "", jointNames[2] or "")
  else
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local nickName = logic_profile:GetNickName(uid)
    if not nickName then
      return name, jointNames
    end
    name = LocUtil.LocalizeResFormat(64759, nickName)
  end
  return name, jointNames
end
function logic_home_profile:UpdatePlayerHomeProfile(uid, key, value)
  log(bWriteLog and "logic_home_detail:UpdatePlayerHomeProfile uid = " .. tostring(uid) .. " key = " .. tostring(key) .. " value = " .. tostring(value))
  local uid = tonumber(uid)
  local profile = self:GetHomeProfileByUid(uid, false)
  if not profile then
    log(bWriteLog and "logic_home_detail:UpdatePlayerHomeProfile not get cache profile")
    return
  end
  profile[key] = value
end
function logic_home_profile:RemoveHomeProfileByUid(uid)
  log(bWriteLog and "logic_home_profile:RemoveHomeProfileByUid uid = " .. tostring(uid))
  if uid == nil then
    return
  end
  local relationUID = self.jointRelationMap[uid]
  if relationUID then
    uid = relationUID
  end
  self.playerHomeProfile:Remove(tonumber(uid))
end
function logic_home_profile:ClearHomeProfiles()
  log(bWriteLog and "logic_home_profile:ClearHomeProfiles")
  self.playerHomeProfile:Clear()
end
function logic_home_profile:BatchUpdateExpiredHomeProfiles()
  log(bWriteLog and "logic_home_profile:BatchUpdateExpiredHomeProfiles")
  local curTime = TimeUtil.GetServerTimeInSec()
  if self.lastTimeUpdateExpiredProfile and curTime - self.lastTimeUpdateExpiredProfile < self.updateExpiredProfileCD then
    log(bWriteLog and "logic_home_profile:BatchUpdateExpiredHomeProfiles cold down")
    return
  end
  self.lastTimeUpdateExpiredProfile = curTime
  local expiredTime = curTime - self.expiredProfileThreshold
  local reqList = {}
  local count = 0
  for key, node in pairs(self.playerHomeProfile.cache) do
    local profile = node.value
    if profile and profile.last_update_time and expiredTime > profile.last_update_time then
      count = count + 1
      table.insert(reqList, key)
      if count >= self.maxSendNum then
        log(bWriteLog and "logic_home_profile:BatchUpdateExpiredHomeProfiles reach max send num, break")
        break
      end
    end
  end
  log_tree("logic_home_profile:BatchUpdateExpiredHomeProfiles reqList=", reqList)
  if 0 < count then
    self:GetOrReqHomeProfile(reqList, nil, true)
  end
end
function logic_home_profile:OnUIHide()
  self.playerHomeProfile:RemoveOutOfRangeNodes()
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
return class(CModuleBase, nil, logic_home_profile)