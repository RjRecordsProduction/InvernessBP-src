local Logic_Warm_Up_Group = {}
local ENUM_INVITE_CORPS = 1
local ENUM_INVITE_FRIEND = 2
function Logic_Warm_Up_Group:ctor()
  self.actData = nil
  self.actConfig = nil
  self.friendsTeamInfos = {}
  self.nRecommendCountLimit = 5
  self.nBeInvitedRecommendCountLimit = 10
  self.nSendGetTopNumRandomOnlineFriendProfileCount = 10
  self.bOnlineLimit = true
  self.tOpenInvitorRecordUIBPCacheData = nil
  self.tSendGetBeInvitedRecordDataPromise = nil
  self.tSendGetRandomFriendDataPromise = nil
  log(bWriteLog and "Logic_Warm_Up_Group:ctor")
end
function Logic_Warm_Up_Group:OnInitialize()
  log(bWriteLog and "Logic_Warm_Up_Group:OnInitialize")
end
function Logic_Warm_Up_Group:DefineAndResetData()
end
function Logic_Warm_Up_Group:OnLogin(bReLogin)
  if bReLogin then
    self:TryGetAllData()
  end
  log(bWriteLog and "Logic_Warm_Up_Group:OnLogin")
end
function Logic_Warm_Up_Group:OnLoginOut()
  log(bWriteLog and "Logic_Warm_Up_Group:OnLoginOut")
end
function Logic_Warm_Up_Group:GetAllTeamID()
  local tMap = {}
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local friendList = LogicFriend.GetFriendList(true) or {}
  for i, j in pairs(friendList) do
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    if j.uid then
      local profile = logic_profile:GetLocalProfile(j.uid)
      if profile and profile.pre_team_id then
        tMap[profile.pre_team_id] = true
      end
    end
  end
  return tMap
end
function Logic_Warm_Up_Group:GetCountDown()
  local TimeUtil = require("client.common.time_util")
  local currentTime = TimeUtil.GetServerTimeInSec()
  local endTime = self:GetEndTime() or 0
  return endTime - currentTime
end
function Logic_Warm_Up_Group:SortRecommendData(tRecommendData1, tRecommendData2)
  return self:SortBeInvitedData(tRecommendData1, tRecommendData2)
end
function Logic_Warm_Up_Group:SortBeInvitedData(tRecommendData1, tRecommendData2)
  if not tRecommendData1.create_time then
    return false
  end
  if not tRecommendData2.create_time then
    return false
  end
  if not tRecommendData1.member_count then
    return false
  end
  if not tRecommendData2.member_count then
    return false
  end
  if tRecommendData1.create_time == tRecommendData2.create_time then
    return tRecommendData1.member_count > tRecommendData2.member_count
  end
  return tRecommendData1.create_time < tRecommendData2.create_time
end
function Logic_Warm_Up_Group:HandleRecommendData(tRecommendDataServer, tMapTeamID2FriendUid)
  local   local tRecommendData = {}
  local nMaxMemberCount = self:GetMaxMemberCount()
  if tRecommendDataServer then
    for _, team_info in pairs(tRecommendDataServer) do
      if team_info.member_count and nMaxMemberCount > team_info.member_count then
        table.insert(tRecommendData, {
          team_id = team_info.team_id,
          member_count = team_info.member_count or 0,
          uid = team_info.team_id and tMapTeamID2FriendUid[team_info.team_id] or 0,
          create_time = team_info.create_time or 0
        })
      end
    end
  end
  table.sort(tRecommendData, function(team1, team2)
    return self:SortRecommendData(team1, team2)
  end)
  local tResult = {}
  for i = 1, math.min(self.nRecommendCountLimit, #tRecommendData) do
    table.insert(tResult, tRecommendData[i])
  end
  return tResult
end
function Logic_Warm_Up_Group:HandleBeInvitedData(tRecommendDataServer, tBeInvitedData)
  local   local tRecommendDataServerMap = {}
  if tRecommendDataServer then
    for _, team_info in pairs(tRecommendDataServer) do
      if team_info.team_id then
        tRecommendDataServerMap[team_info.team_id] = team_info
      end
    end
  end
  local tRecommendData = {}
  local nMaxMemberCount = self:GetMaxMemberCount()
  if tBeInvitedData then
    for _, tBeInvitedRecord in pairs(tBeInvitedData) do
      if tBeInvitedRecord.is_gm then
        table.insert(tRecommendData, {
          team_id = tBeInvitedRecord.team_id,
          member_count = 1,
          uid = tBeInvitedRecord.inviter_uid or 0,
          create_time = tBeInvitedRecord.timestamp or 0,
          is_gm = true
        })
      else
        local nMember_Count = tRecommendDataServerMap[tBeInvitedRecord.team_id] and tRecommendDataServerMap[tBeInvitedRecord.team_id].member_count
        if nMember_Count and nMaxMemberCount > nMember_Count then
          table.insert(tRecommendData, {
            team_id = tBeInvitedRecord.team_id,
            member_count = nMember_Count or tBeInvitedRecord.team_member_count or 0,
            uid = tBeInvitedRecord.inviter_uid or 0,
            create_time = tBeInvitedRecord.timestamp or 0
          })
        end
      end
    end
  end
  table.sort(tRecommendData, function(team1, team2)
    return self:SortRecommendData(team1, team2)
  end)
  local tResult = {}
  for i = 1, math.min(self.nBeInvitedRecommendCountLimit, #tRecommendData) do
    table.insert(tResult, tRecommendData[i])
  end
  return tResult
end
function Logic_Warm_Up_Group:GetBeInvitedData()
  local tActData = self:GetActivityData()
  if not tActData then
    log_error("Logic_Warm_Up_Group:GetBeInvitedData")
    return {}
  end
  local tBeInvitedMap = tActData.beinvited_list or {}
  local tBeInvitedList = {}
  for nUid, tData in pairs(tBeInvitedMap) do
    table.insert(tBeInvitedList, tData)
  end
  return tBeInvitedList
end
function Logic_Warm_Up_Group:GetMyGroupCount()
  local tGroupData = self:GetMyGroupData()
  if not tGroupData then
    log_error("Logic_Warm_Up_Group:GetMyGroupCount data = nil")
    return 0
  end
  if not tGroupData.members then
    return 0
  end
  local table_util = require("common.table_util")
  return table_util.CountTable(tGroupData.members) or 0
end
function Logic_Warm_Up_Group:IsTeamFull()
  return self:GetMaxMemberCount() == self:GetMyGroupCount()
end
function Logic_Warm_Up_Group:GetMyGroupData()
  local tWholeActData = self:GetWholeActivityData()
  if not tWholeActData then
    log_error("Logic_Warm_Up_Group:GetMyGroupData tWholeActData = nil")
    return {}
  end
  return tWholeActData.team_info or {}
end
function Logic_Warm_Up_Group:GetMemberData()
  local tGroupData = self:GetMyGroupData()
  if not tGroupData then
    log_error("Logic_Warm_Up_Group:GetMemberData data = nil")
    return {}
  end
  local tMap = tGroupData.members or {}
  local tList = {}
  local nMaxCount = self:GetMaxMemberCount()
  local nCount = 0
  for _, tMember in pairs(tMap) do
    table.insert(tList, tMember)
    nCount = nCount + 1
    if nMaxCount <= nCount then
      break
    end
  end
  table.sort(tList, function(tMember1, tMember2)
    if not tMember1.join_time or not tMember2.join_time then
      return false
    end
    return tMember1.join_time < tMember2.join_time
  end)
  for i = 1, nMaxCount do
    if tList[i].is_leader then
      local tTemp = tList[1]
      tList[1] = tList[i]
      tList[i] = tTemp
      break
    end
  end
  for i = nCount + 1, nMaxCount do
    table.insert(tList, {})
  end
  return tList
end
function Logic_Warm_Up_Group:SetMyGroupData(info)
  local tActData = self:GetWholeActivityData()
  if not tActData then
    log_error("Logic_Warm_Up_Group:SetMyGroupData tActData = nil")
    return
  end
  tActData.team_end
function Logic_Warm_Up_Group:GetMyGroupID()
  local tGroupData = self:GetMyGroupData()
  return tGroupData.team_id or 0
end
function Logic_Warm_Up_Group:IsHaveTeam()
  local tGroupData = self:GetMyGroupData()
  if not tGroupData then
    return false
  end
  return tGroupData.team_id ~= nil and tGroupData.team_id ~= 0
end
function Logic_Warm_Up_Group:GetWholeActivityData()
  return self.actData
end
function Logic_Warm_Up_Group:GetActivityData()
  local tActData = self:GetWholeActivityData()
  return tActData and tActData.pre_team_act
end
function Logic_Warm_Up_Group:IsActivityInTime()
  local time_util = require("client.common.time_util")
  local curTime = time_util.GetServerTimeInSec()
  local beginTime, endTime = self:GetCurActivityTime()
  return curTime >= beginTime and curTime <= endTime
end
function Logic_Warm_Up_Group:GetStageData()
  local tActData = self:GetActivityData()
  if not tActData then
    log_error("Logic_Warm_Up_Group:GetStageData tActData = nil")
    return {}
  end
  local tCfg = self:GetSeverCfg()
  if not tCfg then
    log_error("Logic_Warm_Up_Group:GetStageData tCfg = nil")
    return {}
  end
  local tResult = {}
  local tRewardCfgs = tCfg.stages or {}
  local tStatus = tActData.rewards_status or {}
  local nmyMemberCount = self:GetMyGroupCount()
  for nMemberCount, tRewardCfg in pairs(tRewardCfgs) do
    local nStatus = nMemberCount <= nmyMemberCount and ActivityProgressStatus.Done or ActivityProgressStatus.Not
    if tStatus[nMemberCount] then
      nStatus = ActivityProgressStatus.Get
    end
    table.insert(tResult, {
      rewardCfg = tRewardCfg,
      status = nStatus,
      memberCount = nMemberCount
    })
  end
  table.sort(tResult, function(tData1, tData2)
    return tData1.memberCount < tData2.memberCount
  end)
  return tResult
end
function Logic_Warm_Up_Group:HasReddot()
  local tStageData = self:GetStageData()
  for _, tData in pairs(tStageData) do
    if tData.status == ActivityProgressStatus.Done then
      return true
    end
  end
  return false
end
function Logic_Warm_Up_Group:SetJoinUICacheData(tOpenInvitorRecordUIBPCacheData)
  self.end
function Logic_Warm_Up_Group:GetJoinUICacheData()
  return self.tOpenInvitorRecordUIBPCacheData
end
function Logic_Warm_Up_Group:IsActivityOpen()
  local bModule = self:CheckIsModuleOpen()
  local bData = self:CheckDataValid()
  local bInTime = self:IsActivityInTime()
  return bModule and bData and bInTime
end
function Logic_Warm_Up_Group:GetTeamInfo(tTeamIds)
  local tData = {}
  for nUid, _ in pairs(tTeamIds) do
    if self.friendsTeamInfos[nUid] then
      table.insert(tData, self.friendsTeamInfos[nUid])
    end
  end
  return tData
end
function Logic_Warm_Up_Group:HasInvited(uid)
  if not uid then
    log_error("Logic_Warm_Up_Group:HasInvited uid = nil")
    return false
  end
  local tActData = self:GetActivityData()
  if not tActData then
    return false
  end
  local tHasInvitedMap = tActData.invited_list
  if tHasInvitedMap == nil then
    return false
  end
  return tHasInvitedMap[uid] ~= nil
end
function Logic_Warm_Up_Group:GetInviteOther()
  local teamInfo = self:GetMyGroupData()
  if not teamInfo then
    log(bWriteLog and "Logic_Warm_Up_Group:TryGetInviteOther.NoTeamInfo")
    return
  end
  local time_util = require("client.common.time_util")
  local data = {
    member_count = self:GetMyGroupCount(),
    max_member_count = self:GetMaxMemberCount(),
    sgroup_id = tostring(self:GetMyGroupID()),
    invite_time = time_util.GetServerTimeInSec()
  }
  return data
end
function Logic_Warm_Up_Group:CheckIsModuleOpen()
  local bModuleOpen = LobbySystem.CheckOpen(BP_ENUM_MODULE_WARM_UP_GROUP)
  return bModuleOpen
end
function Logic_Warm_Up_Group:CheckDataValid()
  if self:GetSeverCfg() == nil then
    return false
  end
  if self:GetWholeActivityData() == nil then
    return false
  end
  return true
end
function Logic_Warm_Up_Group:JumpCheck(tAllParam)
  local bIsDeepLink = tAllParam and tAllParam.isDeepLink == 1 or false
  if bIsDeepLink then
    return false
  end
  if not self:CheckIsModuleOpen() then
    return
  end
  if not self:CheckDataValid() then
    self:TryGetCfg():Then(function()
      if not self:IsActivityInTime() then
        log(bWriteLog and "Logic_Warm_Up_Group:JumpCheck IsActivityInTime false")
        ShowNotice(4002)
        return
      end
      self:SendGetActData()
      log(bWriteLog and "Logic_Warm_Up_Group:JumpCheck SendGetActData")
    end)
    return false
  end
  return true
end
function Logic_Warm_Up_Group:ShowModule(_)
  self:SendGetActData(true):Then(function()
    UIManager.ShowUI(UIManager.UI_Config.Warm_Up_Group_UIBP)
  end)
end
function Logic_Warm_Up_Group:CloseModule()
  UIManager.CloseUI(UIManager.UI_Config.Warm_Up_Group_UIBP)
end
local Trait = require("common.trait")
local Traits = {
  require("client.slua.logic.warm_up_group.Logic_Warm_Up_Group_Net"),
  require("client.slua.logic.warm_up_group.Logic_Warm_Up_Group_Cfg")
}
local class = require("class")
local CModuleBase = require("client.module_framework.JumpModuleBase")
local CLogic_Warm_Up_Group = Trait.TraitClass(CModuleBase, nil, Logic_Warm_Up_Group, Traits)
return CLogic_Warm_Up_Group