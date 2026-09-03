local HostedFriendProtocol = {}
local UIUtil = require("client.common.ui_util")
function HostedFriendProtocol:GetFriendListCount(data, appType)
  local actid = data.actid
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local tempFriendsList = LogicFriend.GetFriendList(false)
  local tab = {
    type = "GetFriendListCountRet",
    content = #tempFriendsList,
    actid = actid,
    ready = self.FriendDataReady and 1 or 0
  }
  local HostedProtoBridge = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.HostedProtoBridge)
  HostedProtoBridge:OnSendMessage(appType, tab)
end
function HostedFriendProtocol:GetFriendList(data, appType)
  local startIndex = tonumber(data.startIndex) or 1
  local endIndex = tonumber(data.endIndex) or 1
  local actid = data.actid
  if 20 <= endIndex - startIndex then
    log_error("GetFriendList be not more than 20")
  end
  if not self.FriendListCache then
    self.FriendListCache = {}
  end
  if not self.FriendCacheTimer then
    self.FriendCacheTimer = {}
  end
  if startIndex == 1 then
    self.FriendListCache[appType] = nil
    if self.FriendCacheTimer[appType] then
      local Handle = self.FriendCacheTimer[appType]
      self:RemoveTimer(Handle)
      self.FriendCacheTimer[appType] = nil
    end
  end
  local tempFriendsList = self.FriendListCache[appType]
  if not tempFriendsList then
    local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
    tempFriendsList = LogicFriend.GetFriendList(true)
    self.FriendListCache[appType] = tempFriendsList
    self.FriendCacheTimer[appType] = self:AddTimerOnce(300, function()
      self.FriendListCache[appType] = nil
      self.FriendCacheTimer[appType] = nil
    end)
  end
  local friendsList = {}
  for i = startIndex, endIndex do
    local friendData = tempFriendsList[i]
    if friendData ~= nil then
      local v = self:ConvertFriendData(friendData)
      friendsList[#friendsList + 1] = v
    end
  end
  local tab = {
    type = "GetFriendListRet",
    ready = self.FriendDataReady and 1 or 0,
    content = friendsList,
    actid = actid,
    startIndex = startIndex,
      }
  local HostedProtoBridge = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.HostedProtoBridge)
  HostedProtoBridge:OnSendMessage(appType, tab)
end
function HostedFriendProtocol:SearchFriend(data, appType)
  local searchWorld = data.searchWorld
  local actid = data.actid
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local tempFriendsList = LogicFriend.GetFriendList(true)
  local friendsList = {}
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  for i = 1, #tempFriendsList do
    local profile = logic_profile:GetLocalProfile(tempFriendsList[i].uid) or {}
    local NickName = profile.nickName
    local PlatName = profile.platName
    if NickName ~= nil and self:IsFriendFound(NickName, searchWorld) or PlatName ~= nil and self:IsFriendFound(PlatName, searchWorld) then
      local v = self:ConvertFriendData(tempFriendsList[i])
      table.insert(friendsList, v)
    end
  end
  local tab = {
    type = "SearchFriendRet",
    content = friendsList,
    actid = actid,
      }
  local HostedProtoBridge = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.HostedProtoBridge)
  HostedProtoBridge:OnSendMessage(appType, tab)
end
function HostedFriendProtocol:OnFriendDataReady()
  self.FriendDataReady = true
end
function HostedFriendProtocol:FriendListRet()
  log(bWriteLog and "pandora_common_protocol.FriendListRet: ")
  local gamelet_define = require("client.slua.logic.gamelet.gamelet_define")
  local HostedConst = require("client.slua.logic.HostedProtoBridge.HostedConst")
  local appList = {
    HostedConst.HostedType.Pandora,
    gamelet_define.GameletApp.WOW_BBS
  }
  local tab = {
    type = "FriendListRet"
  }
  for _, appType in pairs(appList) do
    local HostedProtoBridge = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.HostedProtoBridge)
    HostedProtoBridge:OnSendMessage(appType, tab)
  end
end
function HostedFriendProtocol:ConvertFriendData(friendData)
  local v = {}
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local logic_new_friend = require("client.slua.logic.friend.logic_new_friend")
  local logic_oldfriend_care = require("client.slua.logic.oldfriend.logic_oldfriend_care")
  local profile = logic_profile:GetLocalProfile(friendData.uid) or {}
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  local FriendInteractRecord = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_interact_record)
  local recordData = FriendInteractRecord:GetCumulativeInteractRecordData(friendData.uid)
  local status = PlayerStatusMgr:GetStatusData(friendData.uid) or {}
  v.gid = tostring(friendData.uid)
  v.sex = profile.sex
  v.level = profile.level
  v.teamupCount = recordData and recordData.teamup_num or 0
  v.region = profile.region
  v.nickName = profile.nickName
  v.platName = profile.platName
  v.intimacy = logic_new_friend.GetInnerFriendIntimacy(friendData.uid)
  v.online = status.online or 0
  local bIsRejoin = logic_oldfriend_care.IsRejoinPlayer(profile)
  v.rejoin_user_status = bIsRejoin and 1 or 0
  if bIsRejoin then
    v.no_login_seconds = profile.rejoin_start_time - profile.lastOnlineTime
    v.no_login_days = (profile.rejoin_start_time - profile.lastOnlineTime) / 86400
  end
  v.frame = UIUtil.GetItemSmallIcon(profile.cur_avatar_box_id) or ""
  v.portrait = profile.picUrl
  return v
end
function HostedFriendProtocol:IsFriendFound(FriendName, searchWorld)
  local findFlag = string.find(FriendName, searchWorld)
  return findFlag ~= nil
end
local FriendIds, ReqFriendIds, NActId, RegionMap, SRegion, CacheAppType
function HostedFriendProtocol:GetFriendsByRegion(data, appType)
  CacheAppType = appType
  log_tree("HostedFriendProtocol:GetFriendsByRegion data", data)
  local region = data and data.region
  if region then
    self:SetActId(data.actid)
    self:SetRegion(region)
    if self:HasAllFriendProfile() then
      self:BuildData()
    else
      self:ReqProfileData()
    end
  end
end
function HostedFriendProtocol:OnBuildRegionFriends(friends, actId, region)
  local tab = {
    type = "GetRegionFriendsRet",
    content = friends,
    actid = actId,
      }
  local HostedProtoBridge = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.HostedProtoBridge)
  HostedProtoBridge:OnSendMessage(CacheAppType, tab)
  CacheAppType = nil
end
function HostedFriendProtocol:SetActId(actId)
  NActId = actId
  log(bWriteLog and "HostedFriendProtocol:SetActId " .. tostring(NActId))
end
function HostedFriendProtocol:SetRegion(region)
  SRegion = region
  local StringUtil = require("common.string_util")
  local regions = StringUtil.Split(region, ";")
  RegionMap = {}
  for _, v in pairs(regions) do
    RegionMap[v] = true
  end
  log_tree("HostedFriendProtocol:SetRegion RegionMap", RegionMap)
end
function HostedFriendProtocol:HasAllFriendProfile()
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  if not FriendIds then
    FriendIds = LogicFriend.GetFriendList(true)
    log(bWriteLog and "HostedFriendProtocol:HasAllFriendProfile FriendIds" .. tostring(#FriendIds))
  end
  local hasAll = true
  ReqFriendIds = {}
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  for _, data in pairs(FriendIds) do
    local uid = data.uid
    if not logic_profile:GetLocalProfile(uid) then
      table.insert(ReqFriendIds, uid)
      hasAll = false
    end
  end
  return hasAll
end
function HostedFriendProtocol:ReqProfileData()
  if not ReqFriendIds or not next(ReqFriendIds) then
    log(bWriteLog and "  : dont need to req")
    return
  end
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetNormalProfiles(ReqFriendIds, function(profileList)
    self:OnGetProfileData(profileList)
  end, Enum_PROFILE_REPORT_CFG.PANDORA)
end
function HostedFriendProtocol:OnGetProfileData(list)
  if not list or not next(list) then
    log(bWriteLog and "HostedFriendProtocol:OnGetProfileData  noData")
    self:ReqProfileData()
    return
  end
  self:BuildData()
end
function HostedFriendProtocol:BuildData()
  local result = {}
  local oneProfile, oneRecordData, oneRegion
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  local FriendInteractRecord = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_interact_record)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  for _, data in pairs(FriendIds) do
    local uid = data.uid
    oneProfile = logic_profile:GetLocalProfile(uid)
    oneRecordData = FriendInteractRecord:GetCumulativeInteractRecordData(uid)
    oneRegion = oneProfile and oneProfile.region
    if oneRegion and RegionMap[oneRegion] then
      local oneData = {
        gid = 0,
        sex = 0,
        nickName = "",
        platName = "",
        region = ""
      }
      oneData.gid = tostring(oneProfile.uid)
      oneData.sex = oneProfile.sex
      oneData.nickName = oneProfile.nickName
      oneData.platName = oneProfile.platName
      oneData.ip_region = oneProfile.ip_region
      oneData.intimacy = oneProfile.intimacy
      oneData.level = oneProfile.level
      oneData.tempupCount = oneRecordData and oneRecordData.teamup_num or 0
      local logic_oldfriend_care = require("client.slua.logic.oldfriend.logic_oldfriend_care")
      local bIsRejoin = logic_oldfriend_care.IsRejoinPlayer(oneProfile)
      oneData.rejoin_user_status = bIsRejoin and 1 or 0
      if bIsRejoin then
        oneData.no_login_seconds = oneProfile.rejoin_start_time - oneProfile.lastOnlineTime
        oneData.no_login_days = (oneProfile.rejoin_start_time - oneProfile.lastOnlineTime) / 86400
      end
      oneData.region = oneProfile.region
      local status = PlayerStatusMgr:GetStatusData(oneProfile.uid)
      oneData.online = status and status.online or 0
      local HeadPath, FramePath = self:GetHeadAndFrame(oneProfile.picUrl, oneProfile.cur_avatar_box_id)
      oneData.portrait = HeadPath
      oneData.frame = FramePath
      table.insert(result, oneData)
    end
  end
  self:OnBuildRegionFriends(result, NActId, SRegion)
end
function HostedFriendProtocol:GetHeadAndFrame(picUrl, avatar_box_id)
  local HeadPath = ""
  local FramePath = ""
  if string.find(picUrl, "http") then
    HeadPath = picUrl
  else
    local itemCfg = CDataTable.GetTableData("Item", picUrl)
    if itemCfg then
      HeadPath = itemCfg.ItemSmallIcon
    else
      log_error_format("HostedFriendProtocol:GetHeadAndFrame. picUrl=%s has no itemCfg", tostring(picUrl))
    end
  end
  local frameCfg = CDataTable.GetTableData("Item", avatar_box_id)
  if frameCfg then
    FramePath = frameCfg.ItemSmallIcon
  else
    log_error_format("HostedFriendProtocol:GetHeadAndFrame. avatar_box_id=%s has no itemCfg", tostring(avatar_box_id))
  end
  return HeadPath, FramePath
end
function HostedFriendProtocol:DefineAndResetData()
  self.FriendListCache = nil
  self.FriendCacheTimer = nil
  self.FriendDataReady = false
end
function HostedFriendProtocol:OnLogOut()
  FriendIds = nil
  ReqFriendIds = nil
  NActId = nil
  RegionMap = nil
  SRegion = nil
  CacheAppType = nil
end
local Class = require("class")
local ModuleBase = require("client.module_framework.ModuleBase")
local CHostedFriendProtocol = Class(ModuleBase, nil, HostedFriendProtocol)
return CHostedFriendProtocol