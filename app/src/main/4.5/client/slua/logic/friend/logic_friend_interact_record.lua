local logic_friend_interact_record = {}
local C_EmptyDataPlaceHolder = "-"
local C_DataTypeEnum = {
  Integer = "int",
  Float = "float",
  String = "string",
  Date = "date"
}
local C_DataRequestCD = 300
local C_MaxHighFrequencyReqCount = 5
local C_HighFrequencyDataReqCD = 2
local C_MAX_ADD_FRIEND_DAYS = 10000
function logic_friend_interact_record:OnInitialize()
  self.resInteractData = nil
  self.cachedSeasonData = {}
  self.cachedCumulativeData = {}
  self.cachedHighFrequencyData = {}
  self.recentInteractData = {}
  self.recentDataMap = {}
  self.openType = {
    PersonSpace = 1,
    ChatMenu = 2,
    Intimacy = 3,
    Partner = 4,
    Return = 5
  }
  self.reportInteractionType = {PersonSpaceOrInfo = 6}
  self.curHighFrequencyReqTry = 0
end
function logic_friend_interact_record:ShowInteractRecordWithPlayer(uid, openType)
  if not LobbySystem.CheckLobbyMenuOpen(BP_ENUM_MODULE_FRIEND_INTERACT_RECORD) then
    ShowNotice(120001)
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.Lobby_RoleInfo_InteractRecord_UIBP, uid)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.InteractRecord_Enter, openType)
end
function logic_friend_interact_record:RequestCumulativeInteractDataForPlayer(uid, bForceUpdate)
  log(bWriteLog and "[DeanJYT] logic_friend_interact_record:RequestCumulativeInteractDataForPlayer uid = " .. tostring(uid) .. ", bForceUpdate = " .. tostring(bForceUpdate))
  local bShouldUpdate = bForceUpdate or false
  if self.cachedCumulativeData[uid] then
    local TimeUtil = require("client.common.time_util")
    local curTime = TimeUtil.GetServerTimeInSec()
    local lastUpdateTime = tonumber(self.cachedCumulativeData[uid].lastUpdateTime) or 0
    if curTime - lastUpdateTime > C_DataRequestCD then
      bShouldUpdate = true
    end
  else
    bShouldUpdate = true
  end
  if bShouldUpdate then
    local FriendHandler = require("client.network.Protocol.FriendHandler")
    FriendHandler.send_get_interact_records_req(uid)
  else
    EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_CUMULATIVE_ROLEINFO_INTERACT_RECORD, uid, self.cachedCumulativeData[uid])
  end
end
function logic_friend_interact_record:RequestSeasonInteractDataForPlayer(uid, bForceUpdate)
  log(bWriteLog and "[DeanJYT] logic_friend_interact_record:RequestSeasonInteractDataForPlayer uid = " .. tostring(uid) .. ", bForceUpdate = " .. tostring(bForceUpdate))
  local bShouldUpdate = bForceUpdate or false
  if self.cachedSeasonData[uid] then
    local TimeUtil = require("client.common.time_util")
    local curTime = TimeUtil.GetServerTimeInSec()
    local lastUpdateTime = tonumber(self.cachedSeasonData[uid].lastUpdateTime) or 0
    if curTime - lastUpdateTime > C_DataRequestCD then
      bShouldUpdate = true
    end
  else
    bShouldUpdate = true
  end
  if bShouldUpdate then
    local FriendHandler = require("client.network.Protocol.FriendHandler")
    FriendHandler.send_get_season_interact_records_req(uid)
  else
    EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_SEASON_ROLEINFO_INTERACT_RECORD, uid, self.cachedSeasonData[uid])
  end
end
function logic_friend_interact_record:RequestHighFrequencyInteractData()
  log(bWriteLog and "[DeanJYT] logic_friend_interact_record:RequestHighFrequencyInteractData")
  if self.curHighFrequencyReqTry >= C_MaxHighFrequencyReqCount then
    log(bWriteLog and "[DeanJYT] [DeanJYT] logic_friend_interact_record:RequestHighFrequencyInteractData reached max try")
    return
  end
  local FriendHandler = require("client.network.Protocol.FriendHandler")
  FriendHandler.send_get_all_friendlist_interact_req()
  self.curHighFrequencyReqTry = self.curHighFrequencyReqTry + 1
end
function logic_friend_interact_record:OnCumulativeInteractDataForPlayerRsp(uid, data)
  local uidNum = tonumber(uid)
  if not uidNum then
    return
  end
  local TimeUtil = require("client.common.time_util")
  self.cachedCumulativeData[uidNum] = {
    data = data,
    lastUpdateTime = TimeUtil.GetServerTimeInSec()
  }
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_CUMULATIVE_ROLEINFO_INTERACT_RECORD, uid, data)
end
function logic_friend_interact_record:OnSeasonInteractDataForPlayerRsp(uid, data)
  local uidNum = tonumber(uid)
  if not uidNum then
    return
  end
  local TimeUtil = require("client.common.time_util")
  self.cachedSeasonData[uidNum] = {
    data = data,
    lastUpdateTime = TimeUtil.GetServerTimeInSec()
  }
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_SEASON_ROLEINFO_INTERACT_RECORD, uid, data)
end
function logic_friend_interact_record:proc_get_all_friendlist_interact_rsp(res, data)
  log(bWriteLog and "logic_friend_interact_record:proc_get_all_friendlist_interact_rsp")
  if res ~= 0 or not data then
    self:AddTimerOnce(C_HighFrequencyDataReqCD, function()
      self:RequestHighFrequencyInteractData()
    end)
    return
  end
  self.resInteractData = data
  for k, v in pairs(data) do
    if self.cachedHighFrequencyData[k] then
      local add_friend_date = self.cachedHighFrequencyData[k].add_friend_date
      local add_friend_days = self.cachedHighFrequencyData[k].add_friend_days
      self.cachedHighFrequencyData[k] = v
      self.cachedHighFrequencyData[k].      self.cachedHighFrequencyData[k].    end
  end
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_INTERACT_GET_ALL_FRIENDLIST)
end
function logic_friend_interact_record:SetHighFrequencyInteractData(data)
  self.cachedHighFrequencyData = data
end
function logic_friend_interact_record:AddInnerFriendData(innerList)
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  local logic_new_friend = require("client.slua.logic.friend.logic_new_friend")
  for _, uid in pairs(innerList) do
    local friendInfo = logic_new_friend.GetFriendData(uid)
    if friendInfo then
      local data = self.cachedHighFrequencyData[uid] or {}
      if friendInfo.create_time and friendInfo.create_time > 0 then
        data.add_friend_date = friendInfo.create_time
        local create_days = math.ceil((now - friendInfo.create_time) / 86400)
        data.add_friend_days = create_days
      end
      if friendInfo.add_from and not data.add_from then
        data.add_from = friendInfo.add_from
      end
      self.cachedHighFrequencyData[uid] = data
    end
  end
end
function logic_friend_interact_record.IsAddFriendDaysValid(day)
  local bIsValid = 0 < day and day < C_MAX_ADD_FRIEND_DAYS
  if not bIsValid then
    log(bWriteLog and "logic_friend_interact_record.IsAddFriendDaysValid failed: " .. tostring(day))
  end
  return bIsValid
end
function logic_friend_interact_record:OnPreSwitchGameStatus(_, next)
  log(bWriteLog and "[DeanJYT] logic_friend_interact_record:OnPreSwitchGameStatus")
  if next == GameStatus.Lobby or GameStatus.IsInMainCity() then
    log(bWriteLog and "[DeanJYT] logic_friend_interact_record:OnPreSwitchGameStatus not exiting from lobby, do not need to empty data")
    return
  end
  self.cachedSeasonData = {}
  self.cachedCumulativeData = {}
  self.cachedHighFrequencyData = {}
end
function logic_friend_interact_record:GetInteractRecordData(uid, seasonID)
  log(bWriteLog and "[DeanJYT] logic_friend_interact_record:GetInteractRecordData uid = " .. tostring(uid))
  local TableUtil = require("common.table_util")
  local cumulativeData = self:GetCumulativeInteractRecordData(uid)
  if not seasonID or seasonID == 0 then
    return cumulativeData
  end
  local seasonData = TableUtil.GetTableValue(self.cachedSeasonData, uid, "data", seasonID)
  if not seasonData then
    return nil
  end
  local result = TableUtil.CopyTable(seasonData)
  for k, v in pairs(cumulativeData) do
    local dataCfg = CDataTable.GetTableData("FriendInteractDataMapping", k)
    if dataCfg and not dataCfg.bIsSeasonData then
      result[k] = v
    end
  end
  return result
end
function logic_friend_interact_record:GetAllSeasonInteractRecordData(uid)
  local TableUtil = require("common.table_util")
  return TableUtil.GetTableValue(self.cachedSeasonData, uid, "data")
end
function logic_friend_interact_record:GetCumulativeInteractRecordData(uid)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  if not LogicFriend.IsMyFriend(uid) then
    return nil
  end
  if self.cachedCumulativeData[uid] and next(self.cachedCumulativeData[uid]) then
    return self.cachedCumulativeData[uid].data
  end
  return self.cachedHighFrequencyData[uid]
end
function logic_friend_interact_record:GetCumulativeInteractRecordDataHighFrequency(uid)
  return self.cachedHighFrequencyData[uid]
end
local ShowInfoSortFunc = function(a, b)
  local priorityA = a.priority or 0
  local priorityB = b.priority or 0
  if priorityA > priorityB then
    return true
  elseif priorityA < priorityB then
    return false
  end
  local weightA = a.totalWeight
  local weightB = b.totalWeight
  return weightA > weightB
end
function logic_friend_interact_record:GetShowInfoBySlot(uid, slotName, seasonID)
  log(bWriteLog and "[DeanJYT] logic_friend_interact_record:GetShowInfoBySlot slotName = " .. tostring(slotName))
  local record = self:GetInteractRecordData(uid, seasonID)
  if not record then
    log(bWriteLog and "[DeanJYT] logic_friend_interact_record:GetShowInfoBySlot invalid record from player")
  end
  local slotCfgs = CDataTable.GetTableByFilter("FriendInteractDataViewCfg", "ShowSlot", slotName)
  local validData = {}
  for _, v in pairs(slotCfgs) do
    local slotData = self:ParseSlotData(record, v)
    if slotData then
      validData[#validData + 1] = slotData
    end
  end
  table.sort(validData, ShowInfoSortFunc)
  return validData
end
function logic_friend_interact_record:GetSingleShowInfoBySlot(uid, slotName, seasonID)
  log(bWriteLog and "[DeanJYT] logic_friend_interact_record:GetSingleShowInfoBySlot slotName = " .. tostring(slotName))
  local showDataList = self:GetShowInfoBySlot(uid, slotName, seasonID)
  log_tree("[DeanJYT] logic_friend_interact_record:GetSingleShowInfoBySlot showDataList = ", showDataList)
  return showDataList and showDataList[1] or nil
end
function logic_friend_interact_record:ParseSlotData(record, slotInfo)
  local TimeUtil = require("client.common.time_util")
  local defaultData = {
    validDataList = {},
    priority = 0,
    totalWeight = 0,
    descID = slotInfo.DataDescID,
    unitID = slotInfo.DataUnitID,
    detailedDescID = slotInfo.DataDetailedDescID,
    desc = LocUtil.LocalizeResFormat(slotInfo.DataDescID),
    value = C_EmptyDataPlaceHolder,
    icon = slotInfo.DataIconPath,
    recordStartTime = TimeUtil.TimeStringToUnixstamp(slotInfo.DataRecordStartTime),
    bIsDefault = true
  }
  if not record then
    log(bWriteLog and "[DeanJYT] logic_friend_interact_record:ParseSlotData record missing")
    return defaultData
  end
  local validDataList = {}
  local totalWeight = 0
  for _, v in pairs(slotInfo.DataNameList_as) do
    if v ~= "" then
      local curData = record[v]
      if not curData then
        log(bWriteLog and "[DeanJYT] logic_friend_interact_record:ParseSlotData curData missing")
        return defaultData
      end
      local dataType = self:GetDataType(v)
      local specialData = self:ApplySpecialDataFormat(v, curData, record)
      if specialData then
        if specialData == C_EmptyDataPlaceHolder then
          return defaultData
        end
        curData = specialData
      elseif dataType ~= C_DataTypeEnum.String then
        local curDataNum = tonumber(curData)
        if not curDataNum then
          log(bWriteLog and "[DeanJYT] logic_friend_interact_record:ParseSlotData curDataNum missing")
          return defaultData
        end
        if curDataNum < slotInfo.DataThreshold then
          log(bWriteLog and "[DeanJYT] logic_friend_interact_record:ParseSlotData curDataNum under DataThreshold")
          return defaultData
        end
        if dataType == C_DataTypeEnum.Float then
          curData = string.format("%.1f", curDataNum)
        end
        if dataType == C_DataTypeEnum.Date then
          curData = TimeUtil.FormatTime_YMD(curData, false, true)
        end
        totalWeight = totalWeight + curDataNum * slotInfo.DataWeight
      end
      log(bWriteLog and "[DeanJYT] logic_friend_interact_record:ParseSlotData curData = " .. tostring(curData))
      validDataList[#validDataList + 1] = curData
    end
  end
  log_tree("[DeanJYT] logic_friend_interact_record:ParseSlotData validDataList", validDataList)
  return {
    validDataList = validDataList,
    priority = slotInfo.ShowPriority,
    totalWeight = totalWeight,
    descID = slotInfo.DataDescID,
    unitID = slotInfo.DataUnitID,
    detailedDescID = slotInfo.DataDetailedDescID,
    desc = LocUtil.LocalizeResFormat(slotInfo.DataDescID, table.unpack(validDataList)),
    value = slotInfo.DataUnitID ~= 0 and LocUtil.LocalizeResFormat(slotInfo.DataUnitID, table.unpack(validDataList)) or validDataList[1],
    icon = slotInfo.DataIconPath,
    recordStartTime = TimeUtil.TimeStringToUnixstamp(slotInfo.DataRecordStartTime),
    bIsDefault = false
  }
end
function logic_friend_interact_record:GetDataType(dataName)
  local dataCfg = CDataTable.GetTableData("FriendInteractDataMapping", dataName)
  return dataCfg and dataCfg.DataType or ""
end
function logic_friend_interact_record:ApplySpecialDataFormat(dataName, data, record)
  if dataName == "teamup_game_time" then
    local sec = tonumber(data)
    if not sec then
      return data
    end
    return string.format("%.1f", data / 3600)
  elseif dataName == "most_played_mode" then
    local interactModeCfg = CDataTable.GetTableData("FriendInteractModeCfg", data)
    if interactModeCfg then
      return LocUtil.GetLocalizeResStr(interactModeCfg.LocID)
    end
  elseif dataName == "add_friend_date" then
    if tonumber(data) and tonumber(data) <= 0 then
      log(bWriteLog and "[DeanJYT] logic_friend_interact_record:ApplySpecialDataFormat add_friend_date invalid")
      return C_EmptyDataPlaceHolder
    end
  elseif dataName == "add_friend_days" and (not tonumber(record.add_friend_date) or tonumber(record.add_friend_date) <= 0) then
    log(bWriteLog and "[DeanJYT] logic_friend_interact_record:ApplySpecialDataFormat add_friend_days invalid")
    return C_EmptyDataPlaceHolder
  end
  return nil
end
function logic_friend_interact_record:GetInteractTitle(uid)
  log(bWriteLog and "[DeanJYT] logic_friend_interact_record:GetInteractTitle")
  local data = self:GetCumulativeInteractRecordData(uid)
  if not data then
    return nil
  end
  local priorityMax = -1
  local titleNameID = 0
  local titleDescID = 0
  local interactTitleCfg = CDataTable.GetTable("FriendInteractTitleCfg")
  for _, v in pairs(interactTitleCfg) do
    if self:CheckCanUseTitle(data, v) and priorityMax < v.TitlePriority then
      titleNameID = v.TitleNameID
      titleDescID = v.TitleDescID
      priorityMax = v.TitlePriority
    end
  end
  return {
    title = titleNameID ~= 0 and LocUtil.GetLocalizeResStr(titleNameID) or "",
    desc = titleDescID ~= 0 and LocUtil.GetLocalizeResStr(titleDescID) or ""
  }
end
function logic_friend_interact_record:CheckCanUseTitle(data, cfg)
  local friend_interact_record_config = require("client.slua.logic.friend.friend_interact_record_config")
  local paramNameList = cfg.DataNameList_as
  local paramList = {}
  local paramCount = 0
  for k, v in pairs(paramNameList) do
    if v ~= "" then
      paramCount = paramCount + 1
      if data[v] ~= nil then
        paramList[#paramList + 1] = data[v]
      end
    end
  end
  if paramCount > #paramList then
    log(bWriteLog and "[DeanJYT] logic_friend_interact_record:CheckCanUseTitle some params missing")
    return false
  end
  log_tree("[DeanJYT] logic_friend_interact_record:CheckCanUseTitle paramList", paramList)
  local func = friend_interact_record_config.friendTitleRules[cfg.ID]
  if not func then
    log(bWriteLog and "[DeanJYT] logic_friend_interact_record:CheckCanUseTitle check function missing for cfg.ID = " .. tostring(cfg.ID))
    return false
  end
  return func(paramList)
end
function logic_friend_interact_record:ReportInteractionReq(toUID, interactionType)
  if toUID and tonumber(toUID) ~= tonumber(DataMgr.roleData.uid) then
    log(bWriteLog and "logic_friend_interact_record:ReportInteractionReq uid = " .. tostring(toUID) .. " interactionType = " .. tostring(interactionType))
    local FriendHandler = require("client.network.Protocol.FriendHandler")
    FriendHandler.send_report_interaction_req(toUID, interactionType)
  else
    log(bWriteLog and "logic_friend_interact_record:ReportInteractionReq self not report toUID = " .. tostring(toUID))
  end
end
function logic_friend_interact_record:SetRecentInteractData(interact_data)
  self.recentInteractData = interact_data
  if interact_data and next(interact_data) and next(interact_data.list) then
    log(bWriteLog and "logic_friend_interact_record:SetRecentInteractData")
    local idlist = {}
    self.recentDataMap = {}
    for interactType, interactIdListData in pairs(interact_data.list) do
      for _uid, _interactData in pairs(interactIdListData) do
        if tonumber(_uid) ~= tonumber(DataMgr.roleData.uid) then
          local data = self.recentDataMap[_uid]
          if not data then
            table.insert(idlist, _uid)
            data = {
              interactServerData = {}
            }
            self.recentDataMap[_uid] = data
          end
          data.interactServerData[interactType] = _interactData
          if not data.newestInteractTime or data.newestInteractTime < _interactData.time then
            data.newestInteractType = interactType
            data.newestInteractTime = _interactData.time
            data.newestInteractOp = _interactData.op
          end
          if not data.oldestKnowTime or data.oldestKnowTime > _interactData.know_time then
            data.oldestInteractType = interactType
            data.oldestKnowTime = _interactData.know_time
            data.oldestInteractOp = _interactData.op
          end
        end
      end
    end
    local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
    if 0 < #idlist then
      log(bWriteLog and "logic_friend_interact_record:SetRecentInteractData request recent profile")
      local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
      logic_profile_get_wrap.GetNormalProfiles(idlist, LogicFriend.on_batch_get_profile_rsp, Enum_PROFILE_REPORT_CFG.FRIEND_LIST)
      local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
      PlayerStatusMgr:GetOrReqStatusData(ENUM_BATCH_GET_GROUP_AND_ONLINE.RecentTeammate, idlist, function()
        EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_UPDATE_RECENT_STATUS)
        EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_RECENT_STATE_UPDATE)
      end)
    else
      log(bWriteLog and "logic_friend_interact_record:SetRecentInteractData no recent Data 1")
      EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_RECENT_STATE_UPDATE)
    end
  else
    log(bWriteLog and "logic_friend_interact_record:SetRecentInteractData no recent Data")
    EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_RECENT_STATE_UPDATE)
  end
end
function logic_friend_interact_record:OnLogOut()
  self.recentDataMap = {}
  self.send_recent_time = nil
end
function logic_friend_interact_record:send_get_not_fir_interaction_req()
  local hasData = self.recentDataMap and next(self.recentDataMap)
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  local cdLimit = not self.send_recent_time or curTime - self.send_recent_time > 60
  if hasData and not cdLimit then
    log(bWriteLog and string.format("logic_friend_interact_record:send_get_not_fir_interaction_req return %s %s", hasData, cdLimit))
    return false
  end
  self.send_recent_time = curTime
  local FriendHandler = require("client.network.Protocol.FriendHandler")
  FriendHandler.send_get_not_fir_interaction_req()
  return true
end
function logic_friend_interact_record:GetRecentInteractData()
  return self.recentInteractData
end
function logic_friend_interact_record:GetRecentDataMap()
  return self.recentDataMap
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_friend_interact_record = class(CModuleBase, nil, logic_friend_interact_record)
return Clogic_friend_interact_record