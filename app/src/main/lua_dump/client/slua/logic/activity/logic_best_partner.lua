local logic_best_partner = {}
function logic_best_partner:DefineAndResetData()
  self.taskDataMap = {}
  self.baseActData = {}
  self.friendDataList = {}
  self.localSaveType = {
    teampCountDown = 1,
    redDot = 2,
    rightBottomTips = 3,
    receivewDot = 4,
    bannerRed = 5
  }
  self.teamUpModeType = {four = 4, two = 2}
  self.uiType = {
    main = 1,
    recevie = 2,
    invite = 3
  }
  self.currUIType = 1
  self.isResetShow = false
  self.invite_list = {}
  self.beinvited_list = {}
  self.activity_teams = {}
  self.inviteTeamMap = {}
  self.strangerFriend = {}
  self.playerInfoMap = {}
  self.channeltype = {}
  self.isInvite = false
  self.newInvitedReddot = false
end
function logic_best_partner:OnInitialize()
  if not next(self.activity_teams) then
    self:SetActvityTeamsData(DataMgr.activity_teams)
    DataMgr.activity_teams = nil
  end
end
function logic_best_partner:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_BEST_PARTNER, self.OnJumpBestPartner, self)
end
function logic_best_partner:OnPostSwitchGameStatus(preState, nextState)
  if preState == GameStatus.Fighting and nextState == GameStatus.Lobby then
    EventSystem:postEvent(EVENTTYPE_ACTIVITY_BEST_PARTNER, EVENTID_ACTIVITY_BEST_PARTNER_REFRESH_REDDOT)
  elseif nextState == GameStatus.Login then
    self:ResetLocalData()
  end
end
function logic_best_partner:CheckShowReddot()
  local airdrop_macro = require("client.slua.logic.lobby_activity.super_airdrop.airdrop_macro")
  local logic_airdrop_collection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_airdrop_collection)
  local bShow = logic_airdrop_collection:CheckInActTime(airdrop_macro.ActId.ActId2)
  if not bShow then
    log(bWriteLog and "logic_best_partner:CheckShowReddot not bShow")
    return false
  end
  if not self:CheckInActivityTime() then
    log(bWriteLog and "logic_best_partner:CheckShowReddot not in activity time")
    return false
  end
  if self.newInvitedReddot then
    log(bWriteLog and "logic_best_partner:CheckShowReddot self.newInvitedReddot = true")
    return true
  end
  local type = self.localSaveType.redDot
  local isFirstRed = self:IsLocalSaveData(type)
  if isFirstRed then
    log(bWriteLog and "logic_best_partner:CheckShowReddot isFirstRed = true")
    return true
  end
  local isInviteRed = self:IsRedReceivewRedDot()
  if isInviteRed then
    log(bWriteLog and "logic_best_partner:CheckShowReddot isInviteRed = true")
    return true
  end
  local isTaskRed = self:IsTaskRedDot()
  log(bWriteLog and "logic_best_partner:CheckShowReddot isTaskRed = " .. tostring(isTaskRed))
  return isTaskRed
end
function logic_best_partner:SetCurrUIType(currUIType)
  self.end
function logic_best_partner:InitLocalData()
  local type = self.teamUpModeType.four
  local actData = self:GetTeamUpActData(type)
  if not actData or not next(actData) then
    log(bWriteLog and "logic_best_partner:InitLocalData not data")
    return false
  end
  log(bWriteLog and "logic_best_partner:InitLocalData success")
  self:SaveLocalData(self.localSaveType.redDot)
  return true
end
function logic_best_partner:RemoveNewInvitedReddot()
  self.newInvitedReddot = false
end
function logic_best_partner:GetTeamUpActData(type, isSetData)
  local actvityType = ActivityType.BEST_PARTNER_FOUR
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local dataListMap = ActivityNewSystem.GetActivityMap()
  for i, v in pairs(dataListMap) do
    if v and tonumber(v.Type) == actvityType and tostring(v.BackupParam1) == tostring(type) then
      if isSetData and v and next(v.other) and v.other.beinvite_list then
        v.other.beinvite_list = {}
      end
      self.baseActData = v
      return v or {}
    end
  end
  return {}
end
function logic_best_partner:GetActId(type)
  local actData = self:GetTeamUpActData(type)
  return actData.ID or 0
end
function logic_best_partner:GetLableByAct(actId)
  local lable2 = self.teamUpModeType.two
  local lable4 = self.teamUpModeType.four
  local actId_2 = self:GetActId(lable2)
  if tostring(actId) == tostring(actId_2) then
    return lable2
  else
    return lable4
  end
end
function logic_best_partner:IsRedReceivewRedDot()
  log(bWriteLog and "logic_best_partner:IsRedReceivewRedDot")
  local actType4 = self.teamUpModeType.four
  local actData4 = self:GetTeamUpActData(actType4)
  local beinvite_list_4 = self:GetBeinvitedListByAct(actType4)
  local beinviteArray4 = self:GetBeinvitedNum(beinvite_list_4)
  local teamIdInfo4 = self.activity_teams[tonumber(actData4.ID)] or {}
  local type = self.localSaveType.bannerRed
  local isRed_4 = self:IsLocalSaveData(type, beinviteArray4[1] or 0, actData4.ID)
  if beinviteArray4 and 0 < #beinviteArray4 and isRed_4 then
    log(bWriteLog and "logic_best_partner:IsRedReceivewRedDot isRed_4")
    local isInviteRed4 = self:IsLocalSaveData(self.localSaveType.receivewDot, beinviteArray4[1] or 0, actData4.ID)
    if isInviteRed4 and next(teamIdInfo4) and #teamIdInfo4.role_list < 4 then
      log(bWriteLog and "logic_best_partner:IsRedReceivewRedDot isInviteRed4")
      return true
    end
  end
  local actType2 = self.teamUpModeType.two
  local actData2 = self:GetTeamUpActData(actType2)
  local beinvite_list_2 = self:GetBeinvitedListByAct(actType2)
  local beinviteArray2 = self:GetBeinvitedNum(beinvite_list_2)
  local teamIdInfo2 = self.activity_teams[tonumber(actData2.ID)] or {}
  local isRed_2 = self:IsLocalSaveData(type, beinviteArray2[1] or 0, actData2.ID)
  if beinviteArray2 and 0 < #beinviteArray2 and isRed_2 then
    log(bWriteLog and "logic_best_partner:IsRedReceivewRedDot isRed_2")
    local isInviteRed2 = self:IsLocalSaveData(self.localSaveType.receivewDot, beinviteArray2[1] or 0, actData2.ID)
    if isInviteRed2 and next(teamIdInfo2) and #teamIdInfo2.role_list < 2 then
      log(bWriteLog and "logic_best_partner:IsRedReceivewRedDot isInviteRed2")
      return true
    end
  end
  return false
end
function logic_best_partner:IsTaskRedDot()
  local actType4 = self.teamUpModeType.four
  local fourRedPoint = self:IsRedPointByModeType(actType4)
  if fourRedPoint then
    return fourRedPoint
  end
  local actType2 = self.teamUpModeType.two
  local twoRedPoint = self:IsRedPointByModeType(actType2)
  if twoRedPoint then
    return twoRedPoint
  end
  return false
end
function logic_best_partner:IsRedPointByModeType(type)
  local actData = {}
  local taskList = {}
  actData = self.baseActData or self:GetTeamUpActData(type)
  taskList = self:GetTaskActDataList(type, actData.ID)
  if 0 < #taskList then
    for i = 1, #taskList do
      if taskList[i].Status == ActivityProgressStatus.Done then
        return true
      end
    end
  end
  return false
end
function logic_best_partner:GetTaskActDataList(type, actID)
  local nCurActID = self:GetActId(type)
  if tonumber(nCurActID) == 0 then
    nCurActID = actID
  end
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local TableUtil = require("common.table_util")
  local activityDataTable = ActivityNewSystem.GetServerData()
  for k, value in pairs(activityDataTable) do
    local fatherID = TableUtil.GetTableValue(value, "data", "related_id")
    if tonumber(nCurActID) == tonumber(fatherID) then
      local dataList = self:SetTaskDataList(value)
      return dataList
    end
  end
  return {}
end
function logic_best_partner:SetTaskDataList(actData)
  local dataList = {}
  for index, v in pairs(actData.data.award) do
    local data = {}
    data.ID = actData.cfg.id or 0
    data.Type = data.type
    data.ImgLink = actData.cfg.page_link or ""
    data.StartTime = actData.cfg.start_time
    data.other = actData.other
    local cfgData = actData.cfg.award[index] or {}
    self:InitCond(data, cfgData.cond or {})
    data.    data.Drop = cfgData.drop
    data.Desc = cfgData.task_desc
    data.Title = cfgData.task_title or data.activity_name or ""
    data.Status = v.status
    if not actData.data.other.progress then
      data.Progress = 0
    else
      data.Progress = actData.data.other.progress[index] or 0
    end
    table.insert(dataList, data)
  end
  return dataList
end
function logic_best_partner:InitCond(data, cond)
  if not cond then
    data.Total = 0
    return
  end
  local StringUtil = require("common.string_util")
  local condition = StringUtil.Split(cond, ",")
  data.Total = 0
  if 0 < #condition then
    data.Total = tonumber(condition[2])
  end
  for i, v in ipairs(condition) do
    condition[i] = tonumber(v)
  end
  data.Condition = condition
end
function logic_best_partner:GetBeinvitedNum(beinvite_list)
  local beinviteArray = {}
  if not beinvite_list or not next(beinvite_list) then
    return beinviteArray
  end
  for _, value in pairs(beinvite_list) do
    if value and next(value) then
      table.insert(beinviteArray, value.invite_time)
    end
  end
  table.sort(beinviteArray, function(a, b)
    return b < a
  end)
  return beinviteArray
end
function logic_best_partner:GetBeinvitedListByAct(type)
  local actData = self:GetTeamUpActData(type)
  local beinviteListMap = {}
  if self.beinvited_list and self.beinvited_list[actData.ID] and next(self.beinvited_list[actData.ID]) then
    beinviteListMap = self.beinvited_list[actData.ID]
  elseif actData and actData.other and actData.other.beinvite_list then
    beinviteListMap = actData.other.beinvite_list
  end
  return beinviteListMap
end
function logic_best_partner:IsBeinvitedExpired()
  local now = FuncUtil.GetServerTimeInSec()
  local actType4 = self.teamUpModeType.four
  local beinviteListMap4 = self:GetBeinvitedListByAct(actType4)
  local isBeinviteTime4 = false
  for k, v4 in pairs(beinviteListMap4) do
    if now < v4.invite_time + 86400 then
      isBeinviteTime4 = true
      break
    end
  end
  local actType2 = self.teamUpModeType.two
  local beinviteListMap2 = self:GetBeinvitedListByAct(actType2)
  local isBeinviteTime2 = false
  for k, v2 in pairs(beinviteListMap2) do
    if now < v2.invite_time + 86400 then
      isBeinviteTime2 = true
      break
    end
  end
  return isBeinviteTime4, isBeinviteTime2
end
function logic_best_partner:SetAvatarDataByuid(uid)
  local roleData = {}
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(uid)
  if profile then
    roleData.    roleData.picUrl = profile.picUrl
    roleData.gender = profile.sex
    roleData.cur_avatar_box_id = profile.cur_avatar_box_id
    roleData.level = profile.level
    roleData.ignorFrame = false
    roleData.nation = profile.nation
    roleData.nickName = profile.nickName
    roleData.segment_info = profile.segment_info or {}
  end
  return roleData
end
function logic_best_partner:GetFriendTeamInfo()
  local arrayFriendUidList = {}
  self.friendDataList = self:GetFriendListByMacyList(false)
  for i = 1, #self.friendDataList do
    local uid = self.friendDataList[i]
    if uid then
      table.insert(arrayFriendUidList, uid)
    end
  end
  return arrayFriendUidList
end
function logic_best_partner:GetFriendListByMacyList(isAllData)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local allList = LogicFriend.GetInnerList(false)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  table.sort(allList, function(a, b)
    local dataA = logic_profile:GetLocalProfile(a)
    local dataB = logic_profile:GetLocalProfile(b)
    if not dataA or not dataB then
      return false
    end
    if dataA.intimacy == dataB.intimacy then
      if tonumber(dataA.level) == tonumber(dataB.level) then
        return dataA.lastOnlineTime > dataB.lastOnlineTime
      end
      local levelA = dataA.level or 0
      local levelB = dataB.level or 0
      return tonumber(levelA) > tonumber(levelB)
    else
      return dataA.intimacy > dataB.intimacy
    end
  end)
  local friendList = self:GetBestPartnerFriendData(allList, isAllData)
  return friendList or {}
end
function logic_best_partner:GetBestPartnerFriendData(allList, isFristPage)
  local friendList = {}
  for i = 1, #allList do
    if isFristPage and 10 <= #friendList then
      return friendList
    end
    table.insert(friendList, allList[i])
  end
  return friendList
end
function logic_best_partner:SaveLocalData(type, num, actId)
  local actJson = self:LoadPlayerprefsFile()
  if type == self.localSaveType.receivewDot then
    if not actJson.receivewNum then
      actJson.receivewNum = {}
    end
    if not actJson.receivewNum[tostring(actId)] then
      actJson.receivewNum[tostring(actId)] = {}
    end
    actJson.receivewNum[tostring(actId)].time = num
  elseif type == self.localSaveType.redDot then
    actJson.redDot = true
  elseif type == self.localSaveType.rightBottomTips then
    if not actJson.lastTimes then
      actJson.lastTimes = {}
    end
    if not actJson.lastTimes[tostring(actId)] then
      actJson.lastTimes[tostring(actId)] = {}
    end
    actJson.lastTimes[tostring(actId)].  elseif type == self.localSaveType.bannerRed then
    if not actJson.receivewBannerNum then
      actJson.receivewBannerNum = {}
    end
    if not actJson.receivewBannerNum[tostring(actId)] then
      actJson.receivewBannerNum[tostring(actId)] = {}
    end
    actJson.receivewBannerNum[tostring(actId)].time = num
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(actJson, PlayerPrefsSystem.ePlayerPrefsType.eBestPartner)
end
function logic_best_partner:IsLocalSaveData(type, num, actId)
  local actJson = self:LoadPlayerprefsFile()
  if type == self.localSaveType.receivewDot then
    if actJson and actJson.receivewNum and actJson.receivewNum[tostring(actId)] then
      return num > tonumber(actJson.receivewNum[tostring(actId)].time)
    end
  elseif type == self.localSaveType.redDot then
    if actJson and actJson.redDot then
      return false
    end
  elseif type == self.localSaveType.rightBottomTips then
    if actJson and actJson.lastTimes and actJson.lastTimes[tostring(actId)] then
      return tonumber(num) > tonumber(actJson.lastTimes[tostring(actId)].num)
    end
  elseif type == self.localSaveType.bannerRed and actJson and actJson.receivewBannerNum and actJson.receivewBannerNum[tostring(actId)] then
    return tonumber(num) > tonumber(actJson.receivewBannerNum[tostring(actId)].time)
  end
  return true
end
function logic_best_partner:LoadPlayerprefsFile()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  return PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eBestPartner) or {}
end
function logic_best_partner:SetArrayBeinviteList(beinvited_list)
  if not beinvited_list or not next(beinvited_list) then
    return {}
  end
  local beinviteList = {}
  for k, value in pairs(beinvited_list) do
    local data = {
      uid = k,
      team_id = value,
      invite_time = value.invite_time or 0
    }
    table.insert(beinviteList, data)
  end
  table.sort(beinviteList, function(a, b)
    return a.invite_time > b.invite_time
  end)
  return beinviteList
end
function logic_best_partner:SetReqArrayData(beinviteMap4)
  if not beinviteMap4 or not next(beinviteMap4) then
    return {}
  end
  local arrayData = {}
  for i, v in pairs(beinviteMap4) do
    if v and v.team_id then
      table.insert(arrayData, v.team_id)
    end
  end
  return arrayData
end
function logic_best_partner:SetActvityTeamsData(activity_teams)
  self.activity_teams = activity_teams or {}
end
function logic_best_partner:UpdateTeamDataMap(lable, teamInfo)
  if not self.playerInfoMap[lable] then
    self.playerInfoMap[lable] = {}
  end
  self.playerInfoMap[lable] = teamInfo
end
function logic_best_partner:SetInviteList(invited_list, activity_id)
  if not self.invite_list then
    self.invite_list = {}
  end
  if not self.invite_list[activity_id] then
    self.invite_list[activity_id] = {}
  end
  self.invite_list[activity_id] = invited_list or {}
end
function logic_best_partner:SetBeInviteList(beinvited_list, activity_id)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.receivewInivte)
  if not self.beinvited_list then
    self.beinvited_list = {}
  end
  if not self.beinvited_list[activity_id] then
    self.beinvited_list[activity_id] = {}
  end
  self.beinvited_list[activity_id] = beinvited_list or {}
  local lable = self:GetLableByAct(activity_id)
  local teamInfo = self.activity_teams[activity_id] or {}
  if next(teamInfo) and lable <= #teamInfo.role_list then
    return
  end
  self.newInvitedReddot = true
  EventSystem:postEvent(EVENTTYPE_ACTIVITY_BEST_PARTNER, EVENTID_ACTIVITY_BEST_PARTNER_REFRESH_REDDOT)
end
function logic_best_partner:CheckInActivityTime()
  local TimeUtil = require("client.common.time_util")
  local actDataTwo = self:GetTeamUpActData(self.teamUpModeType.two)
  if not next(actDataTwo) then
    log(bWriteLog and "logic_best_partner:CheckInActivityTime not two partner activity data")
    return false
  end
  local curTime = TimeUtil.GetServerTimeInSec()
  if curTime < actDataTwo.StartTime or curTime > actDataTwo.EndTime then
    log(bWriteLog and "logic_best_partner:CheckInActivityTime not in two partner activity time, StartTime = " .. tostring(actDataTwo.StartTime) .. ", EndTime = " .. tostring(actDataTwo.EndTime))
    return false
  end
  local actDataFour = self:GetTeamUpActData(self.teamUpModeType.four)
  if not next(actDataFour) then
    log(bWriteLog and "logic_best_partner:CheckInActivityTime not four partner activity data")
    return false
  end
  if curTime < actDataFour.StartTime or curTime > actDataFour.EndTime then
    log(bWriteLog and "logic_best_partner:CheckInActivityTime not in four partner activity time, StartTime = " .. tostring(actDataFour.StartTime) .. ", EndTime = " .. tostring(actDataFour.EndTime))
    return false
  end
  return true
end
function logic_best_partner:UpdateTeamInfoByActData(act_id, act_change_type_list)
  if act_change_type_list then
    for actType, _ in pairs(act_change_type_list) do
      if actType ~= ActivityType.BEST_PARTNER_FOUR and actType ~= ActivityType.BEST_PARTNER_TWO then
        log(bWriteLog and "[bgp] UpdateTeamInfoByActData: return")
        return
      end
    end
  end
  local actType2 = self.teamUpModeType.two
  local actType4 = self.teamUpModeType.four
  local actId_4 = self:GetActId(actType4)
  local actId_2 = self:GetActId(actType2)
  if tonumber(actId_4) == 0 or tonumber(actId_2) == 0 then
    return
  end
  if tostring(actId_4) ~= tostring(act_id) and tostring(actId_2) ~= tostring(act_id) then
    return
  end
  local invite_list = next(self.invite_list) and self.invite_list or {}
  local beinvite_list = next(self.beinvited_list) and self.beinvited_list or {}
  local dataList4 = self:GetTeamUpActData(actType4)
  if dataList4 and next(dataList4) and tostring(dataList4.ID) == tostring(act_id) then
    if invite_list[dataList4.ID] and next(invite_list[dataList4.ID]) then
      self.invite_list[dataList4.ID] = dataList4.other.invited_list or {}
    end
    if beinvite_list[dataList4.ID] and next(beinvite_list[dataList4.ID]) then
      self.beinvited_list[dataList4.ID] = dataList4.other.beinvite_list or {}
    end
  end
  local dataList2 = self:GetTeamUpActData(actType2)
  if dataList2 and next(dataList2) and tostring(dataList2.ID) == tostring(act_id) then
    if invite_list[dataList2.ID] and next(invite_list[dataList2.ID]) then
      self.invite_list[dataList2.ID] = dataList2.other.invited_list or {}
    end
    if beinvite_list[dataList2.ID] and next(beinvite_list[dataList2.ID]) then
      self.beinvited_list[dataList2.ID] = dataList2.other.beinvite_list or {}
    end
  end
end
function logic_best_partner:ResetSystemData()
  self.taskDataMap = {}
  self.baseActData = {}
  self.friendDataList = {}
  self.playerInfoMap = {}
end
function logic_best_partner:ResetLocalData()
  self.beinvited_list = {}
  self.invite_list = {}
  self.activity_teams = {}
  self.inviteTeamMap = {}
end
function logic_best_partner:CheckSearchInfo(list, NameOrUID)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local finallist = {}
  if list then
    for i, v in pairs(list) do
      local temp = LogicFriend.GetNamePure(v)
      if string.find(temp, NameOrUID) then
        table.insert(finallist, v)
      elseif tostring(v) == tostring(NameOrUID) then
        table.insert(finallist, v)
      end
    end
  else
    return
  end
  return finallist
end
function logic_best_partner:OnJumpBestPartner()
  UIManager.ShowUI(UIManager.UI_Config.BestPartner_Main_UIBP)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_best_partner = class(CModuleBase, nil, logic_best_partner)
return Clogic_best_partner