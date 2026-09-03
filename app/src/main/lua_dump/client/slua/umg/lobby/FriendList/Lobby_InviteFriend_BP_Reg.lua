local Lobby_InviteFriend_BP = require("client.slua.umg.lobby.FriendList.Lobby_InviteFriend_BP_Data")
local FLMacros = require("client.slua.logic.friend.refactor.friend_list_macros")
local LogicTeamUpSideBar = require("client.slua.logic.lobby.logic_teamup_side_bar")
function Lobby_InviteFriend_BP:OnFriendReserved(eventType, eventID, UID)
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  local tabID = logic_friend_list_ui:GetTabID()
  if tabID == FLMacros.ENUM_TAB.ENUM_FRIEND_TAG then
    self:SetOneTabData(true)
  end
end
function Lobby_InviteFriend_BP:OnFriendAddOrDelete(eventType, eventID, UID, isAddFriend)
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  local tabID = logic_friend_list_ui:GetTabID()
  if tabID == FLMacros.ENUM_TAB.ENUM_FRIEND_TAG then
    self:SetOneTabData(true)
  end
end
function Lobby_InviteFriend_BP:OnBatchGetPlayerStatus(eventType, eventID, infos)
  for uid, v in pairs(infos) do
    self:OnFriendStatusChange(eventType, eventID, uid)
  end
end
function Lobby_InviteFriend_BP:OnFriendStatusChange(eventType, eventID, UID)
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  local state = logic_friend_list_ui:GetState()
  if state == FLMacros.ENUM_STATE.FRIENDS_DELETE then
    return
  end
  self:RefreshOnlineNumber()
  local tabID = logic_friend_list_ui:GetTabID()
  if tabID == FLMacros.ENUM_TAB.ENUM_FRIEND_TAG then
    self:SetOneTabData(true)
  else
    self.List:RefreshAllItems()
  end
end
function Lobby_InviteFriend_BP:OnRecentReqResponse()
  log(bWriteLog and "teamup_side_bar:OnRecentReqResponse")
  LogicTeamUpSideBar.OnRecentReqResponse()
  self:RefreshOnlineRecentNumber()
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  local tabID = logic_friend_list_ui:GetTabID()
  if tabID == FLMacros.ENUM_TAB.ENUM_RECENT_TAG then
    self:SetOneTabData(true)
  end
  self:CheckMemberStatus()
end
function Lobby_InviteFriend_BP:UpdateCorpsMembers(_, _, idList)
  LogicTeamUpSideBar.UpdateCorpsMembersStatus(idList)
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  local tabID = logic_friend_list_ui:GetTabID()
  if tabID == FLMacros.ENUM_TAB.ENUM_CORPS_TAG then
    self:SetOneTabData(true)
  end
end
function Lobby_InviteFriend_BP:OnGetCorpsData(eventType, eventID, data, isInited)
  log(bWriteLog and "teamup_side_bar:OnGetCorpsData isInited = " .. tostring(isInited))
  local isReq = not isInited
  LogicTeamUpSideBar.FetchCorps(data, function()
    self:RefreshOnlineCorpsNumber()
  end, isReq)
  self:RefreshOnlineCorpsNumber()
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  local tabID = logic_friend_list_ui:GetTabID()
  if tabID == FLMacros.ENUM_TAB.ENUM_CORPS_TAG then
    self:SetOneTabData(true)
  end
end
function Lobby_InviteFriend_BP:GetProfile(eventType, eventID, profileList)
  log(bWriteLog and "teamup_side_bar:GetProfile")
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  logic_friend_list_ui:ClearProfileReqMap()
  for _, profile in pairs(profileList) do
    self:UpdatePlayerNew(profile.uid)
  end
end
local RankProfileRequestMap = {}
local RankProfileRequestQueue = {}
function Lobby_InviteFriend_BP:RequestRankProfile(UID, index)
  if RankProfileRequestMap[UID] then
    return
  else
    log(bWriteLog and bWriteLog and "teamup_side_bar:RequestRankProfile uid = " .. tostring(UID) .. ", index = " .. tostring(index))
    self:RemoveRankSender()
  end
  local logic_segment_title = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_segment_title)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  local profile_config = require("client.slua.logic.user.profile.profile_config")
  for i = index, index + profile_config.ENUM_REQ_SIZE.WITH_RANK do
    if 1 <= i and i <= #(self:GetPlayerListSetData() or {}) then
      local player = logic_friend_list_ui:GetPlayerData(i)
      local profile = {}
      local bIsHighestSegment = false
      if type(player) == "table" and next(player) and player.uid then
        profile = logic_profile:GetLocalProfile(player.uid) or {}
        local segment = logic_segment_title:GetMaxSegementLevelWithZoneAndModeId(profile.segment_info)
        bIsHighestSegment = logic_segment_title:IsHighestSegment(segment)
      end
      if bIsHighestSegment and not profile.rankdata then
        log(bWriteLog and "teamup_side_bar:RequestRankProfile request index = " .. tostring(i))
        RankProfileRequestMap[player.uid] = true
        table.insert(RankProfileRequestQueue, player.uid)
      end
    end
  end
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  local _myselfOnIsland = MatchModeMgrSystem.IsSocialIslandMode()
  local _tag = _myselfOnIsland and Enum_PROFILE_REPORT_CFG.SOCIAL_ISLAND_FRIEND_SIDE_BAR or Enum_PROFILE_REPORT_CFG.FRIEND_LIST
  local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
  logic_profile_get_wrap.GetRankProfiles(_tag, RankProfileRequestQueue, LogicTeamUpSideBar.OnRankProfileResponse)
end
function Lobby_InviteFriend_BP:GetRankProfile(eventType, eventID, profileList)
  log(bWriteLog and "teamup_side_bar:GetRankProfile")
  self:RemoveRankSender()
  for _, profile in pairs(profileList) do
    self:UpdatePlayerNew(profile.uid)
  end
end
function Lobby_InviteFriend_BP:RemoveRankSender()
  RankProfileRequestMap = {}
  RankProfileRequestQueue = {}
end
function Lobby_InviteFriend_BP:UpdateNearsData()
  self:RefreshOnlineLBSNumber()
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  local tabID = logic_friend_list_ui:GetTabID()
  if tabID == FLMacros.ENUM_TAB.ENUM_LBS_NEAR then
    self:SetOneTabData(true)
  end
  self:CheckMemberStatus()
end
function Lobby_InviteFriend_BP:GetItemSize(index)
  local player = logic_friend_list_ui:GetPlayerData(index)
  local vec = FVector2D(380, 82)
  if not player or not player.uid then
    return vec
  end
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local relation = LogicFriend.GetRelation(player.uid)
  if 0 < relation then
    vec.Y = 100
  else
    vec.Y = 82
  end
  return vec
end
function Lobby_InviteFriend_BP:PartnerPreviewOpen()
  local UIUtil = require("client.common.ui_util")
  self.UIRoot.CanvasPanel_IPX:SetWidgetVisibility(UIUtil.BoolToVisible(false))
end
function Lobby_InviteFriend_BP:PartnerPreviewClose()
  local UIUtil = require("client.common.ui_util")
  self.UIRoot.CanvasPanel_IPX:SetWidgetVisibility(UIUtil.BoolToVisible(true))
end
function Lobby_InviteFriend_BP:OnInviteOfflineMessageFriend()
  local AdjustSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.AdjustSystem)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  LogicFriend.invite_offline_friend_req(LogicFriend.InviteByMessenger, AdjustSystem.E_TokenType.MessageInvite)
end
function Lobby_InviteFriend_BP:OnPageSwitched(_, _, _, toPage)
  if toPage ~= ENUM_LobbyPageType.Mid then
    self:ClosePanelMute()
  end
end
function Lobby_InviteFriend_BP:OnForceUpdateFriendReserveState()
  log(bWriteLog and "[v_wllwu] teamup_side_bar OnForceUpdateFriendReserveState")
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  local tabID = logic_friend_list_ui:GetTabID()
  if tabID ~= FLMacros.ENUM_TAB.ENUM_FRIEND_TAG then
    log(bWriteLog and "[v_wllwu] teamup_side_bar OnForceUpdateFriendReserveState return")
    return
  end
  self:RequestUpdateFriendReserveData()
end
function Lobby_InviteFriend_BP:OnCorpsStatusChange(_, _, UID)
  log(bWriteLog and "teamup_side_bar:OnCorpsStatusChange : " .. tostring(UID))
  if LogicTeamUpSideBar.EnableRecommend and LogicTeamUpSideBar.IsRecommendPlayer(UID) then
    LogicTeamUpSideBar.OnRecommendStatusChange(UID, LogicTeamUpSideBar.UpdateCorpsMemberStatus)
  end
  LogicTeamUpSideBar.UpdateCorpsMembersStatus({UID})
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  local tabID = logic_friend_list_ui:GetTabID()
  if tabID == FLMacros.ENUM_TAB.ENUM_CORPS_TAG then
    self:SetOneTabData(true)
  end
end
function Lobby_InviteFriend_BP:UpdateLbsHandler()
  self:SetOneTabData(true)
  self:SetNearsTab()
  local LBSFriendMgr = require("client.slua.logic.lbs.logic_lbs_friend")
  if LBSFriendMgr:CanGetNearFriendList() and LBSFriendMgr:CanOpenNearFriend() then
    local LBSHandler = require("client.network.Protocol.LBSHandler")
    LBSHandler.lbs_nearly_player_req()
  end
end
function Lobby_InviteFriend_BP:UpdateClubsStatus()
  self:SetOneTabData(false, true)
end
function Lobby_InviteFriend_BP:RefreshOnlineNumber()
  local recommend = 0
  if LogicTeamUpSideBar.EnableRecommend and LogicTeamUpSideBar.HasRecommend() then
    recommend = LogicTeamUpSideBar.GetRecommendNum()
  end
  local AllData = {}
  local onlineNum = 0
  AllData = LogicTeamUpSideBar.GetFriends() or {}
  for k, v in pairs(AllData) do
    if v.online == 1 then
      onlineNum = onlineNum + 1
    end
  end
  local str = onlineNum + recommend .. "/" .. #AllData + recommend
  self:RefreshTabText(FLMacros.ENUM_TAB.ENUM_FRIEND_TAG, LocUtil.LocalizeResFormat(6830, onlineNum + recommend, #AllData + recommend))
  self:RefreshOnlineRecentNumber()
  self:RefreshOnlineCorpsNumber()
  self:RefreshOnlineLBSNumber()
  self:RefreshOnlineWowNumber()
  self:RefreshFlashTeamNumber()
end
function Lobby_InviteFriend_BP:RefreshOnlineRecentNumber()
  local AllData = {}
  local onlineNum = 0
  AllData = LogicTeamUpSideBar.GetRecent() or {}
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  for k, v in pairs(AllData) do
    local status = PlayerStatusMgr:GetStatusData(v.uid)
    if status and status.online == 1 then
      onlineNum = onlineNum + 1
    end
  end
  local str = onlineNum .. "/" .. #AllData
  self:RefreshTabText(FLMacros.ENUM_TAB.ENUM_RECENT_TAG, LocUtil.LocalizeResFormat(6830, onlineNum, #AllData))
end
function Lobby_InviteFriend_BP:RefreshOnlineCorpsNumber()
  local AllData = {}
  local onlineNum = 0
  AllData = LogicTeamUpSideBar.GetCorps() or {}
  local CorpsMemberSystem = require("client.slua.logic.corps.logic_corps_member")
  for k, v in pairs(AllData) do
    local status = CorpsMemberSystem.GetOnlineStatus(v.uid)
    if status and status.online == 1 then
      onlineNum = onlineNum + 1
    end
  end
  local str = onlineNum .. "/" .. #AllData
  self:RefreshTabText(FLMacros.ENUM_TAB.ENUM_CORPS_TAG, LocUtil.LocalizeResFormat(6830, onlineNum, #AllData))
end
function Lobby_InviteFriend_BP:RefreshOnlineLBSNumber()
  local allDataNum = 0
  local onlineNum = 0
  local LBSFriendMgr = require("client.slua.logic.lbs.logic_lbs_friend")
  local nearList = LBSFriendMgr:GetNearFriendList() or {}
  allDataNum = #nearList
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  for k, v in pairs(nearList) do
    local status = PlayerStatusMgr:GetStatusData(v.uid)
    if status and status.online == 1 then
      onlineNum = onlineNum + 1
    end
  end
  local str = onlineNum .. "/" .. allDataNum
  self:RefreshTabText(FLMacros.ENUM_TAB.ENUM_LBS_NEAR, LocUtil.LocalizeResFormat(6830, onlineNum, allDataNum))
end
function Lobby_InviteFriend_BP:GetDataForJumpBack()
  return {
    ctorData = {
      [1] = self.from,
      [2] = self.tab,
      [3] = self.jumpUid
    }
  }
end
function Lobby_InviteFriend_BP:RefreshOnlineWowNumber()
  if not self.modInfo then
    return
  end
  local logic_ugc_mode = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_mode)
  local Data = LogicTeamUpSideBar.GetFriends() or {}
  local AllData = logic_ugc_mode:GetWOWFriendList(self.modInfo.mod_id, Data)
  local OnlineIndex = logic_ugc_mode:GetOnlinFriendIndex(AllData)
  local str = OnlineIndex .. "/" .. #AllData
  self:RefreshTabText(FLMacros.ENUM_TAB.ENUM_WOW_TAG, LocUtil.LocalizeResFormat(6830, OnlineIndex, #AllData))
end
function Lobby_InviteFriend_BP:RefreshFlashTeamNumber()
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  local count = logic_flash_match_team:getOnlineTeamCount()
  local totalNum = #logic_flash_match_team:getMyTeams()
  self:RefreshTabText(FLMacros.ENUM_TAB.ENUM_TEAM_TAG, LocUtil.LocalizeResFormat(6830, count, totalNum))
end
function Lobby_InviteFriend_BP:RefreshTabText(tabID, text)
  if not self.pendingTabTextUpdates then
    self.pendingTabTextUpdates = {}
  end
  self.pendingTabTextUpdates[tabID] = text
  local tabIndex = self:GetTabIndexByTabID(tabID)
  if tabIndex then
    local TabItem = self.TabList:GetIndexOfItem(tabIndex)
    if TabItem then
      TabItem:RefreshText(text)
      self.pendingTabTextUpdates[tabID] = nil
    else
      log(bWriteLog and "teamup_side_bar:RefreshTabText: TabItem not found")
    end
  else
    log(bWriteLog and string.format("teamup_side_bar:RefreshTabText: tabID %s not in CurrentTabList", tostring(tabID)))
  end
end