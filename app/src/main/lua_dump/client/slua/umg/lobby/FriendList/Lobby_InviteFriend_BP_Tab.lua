local Lobby_InviteFriend_BP = require("client.slua.umg.lobby.FriendList.Lobby_InviteFriend_BP_Data")
local FLMacros = require("client.slua.logic.friend.refactor.friend_list_macros")
local LogicTeamUpSideBar = require("client.slua.logic.lobby.logic_teamup_side_bar")
local lastCommunityRequestTime = 0
function Lobby_InviteFriend_BP:SetOneTabData(isInit, DoNotRequestUserChatState)
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  local tabID = logic_friend_list_ui:GetTabID()
  log(bWriteLog and string.format("teamup_side_bar:SetOneTabData tag = %s EnableRecommend = %s", tabID, LogicTeamUpSideBar.EnableRecommend))
  local AllData = {}
  if tabID == FLMacros.ENUM_TAB.ENUM_FRIEND_TAG then
    if LogicTeamUpSideBar.EnableRecommend then
      LogicTeamUpSideBar.Recommend(true)
    else
      LogicTeamUpSideBar.FetchFriends()
    end
    if self.bEnableLocalSearchFriend then
      AllData = self.tLocalSearchFriendDataList
    else
      AllData = LogicTeamUpSideBar.GetFriends() or {}
    end
  elseif tabID == FLMacros.ENUM_TAB.ENUM_RECENT_TAG then
    AllData = LogicTeamUpSideBar.GetRecent() or {}
    self:HideFriendEnableGifted()
  elseif tabID == FLMacros.ENUM_TAB.ENUM_CORPS_TAG then
    AllData = LogicTeamUpSideBar.GetCorps() or {}
    local logic_teamup_side_bar = require("client.slua.logic.lobby.logic_teamup_side_bar")
    table.sort(AllData, logic_teamup_side_bar.CorpsSortFunc)
    self:HideFriendEnableGifted()
  elseif tabID == FLMacros.ENUM_TAB.ENUM_LBS_NEAR then
    local LBSFriendMgr = require("client.slua.logic.lbs.logic_lbs_friend")
    local nearList = LBSFriendMgr:GetNearFriendList()
    local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
    LogicFriend.SortNearList(nearList)
    AllData = nearList
    self:HideFriendEnableGifted()
  elseif tabID == FLMacros.ENUM_TAB.ENUM_WOW_TAG then
    local logic_ugc_mode = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_mode)
    if self.modInfo and self.modInfo.mod_id then
      if self.bEnableLocalSearchFriend then
        AllData = logic_ugc_mode:GetWOWFriendList(self.modInfo.mod_id, self.tLocalSearchFriendDataList, false)
      else
        local Data = LogicTeamUpSideBar.GetFriends() or {}
        AllData = logic_ugc_mode:GetWOWFriendList(self.modInfo.mod_id, Data, false)
      end
    else
      AllData = {}
    end
    self:HideFriendEnableGifted()
  end
  if self.bSwitchTag then
    self:RefreshTagList()
    self.bSwitchTag = false
  end
  log_tree("AllData ", AllData)
  self:RefreshFriendList(isInit, AllData)
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  local CorpsMemberSystem = require("client.slua.logic.corps.logic_corps_member")
  local onlineNum = 0
  for k, v in pairs(AllData) do
    local status
    if tabID == FLMacros.ENUM_TAB.ENUM_CORPS_TAG then
      status = CorpsMemberSystem.GetOnlineStatus(v.uid)
    else
      status = PlayerStatusMgr:GetStatusData(v.uid)
    end
    if status and status.online == 1 then
      onlineNum = onlineNum + 1
    end
  end
  local str = onlineNum .. "/" .. #AllData
  self.UIRoot.TextBlock_Nomber_friends:SetText(str)
  self:RefreshOnlineNumber()
  self:CheckMemberStatus()
  local chatData = AllData
  local logic_community = require("client.slua.logic.community.logic_community")
  if not DoNotRequestUserChatState and logic_community.GetShowEntry() and tabID == FLMacros.ENUM_TAB.ENUM_FRIEND_TAG and chatData then
    local now = os.time()
    if now - lastCommunityRequestTime < 1 then
      print(bWriteLog and "UI:SetOneTabData: community request interval too short")
    else
      lastCommunityRequestTime = now
      local maxCnt = 200
      local RequestChatState = function(iBegin, iEnd)
        local chatlist = {}
        for i = iBegin, iEnd do
          if chatData[i] then
            chatlist[#chatlist + 1] = tostring(chatData[i].uid)
          else
            break
          end
        end
        if 0 < #chatlist then
          logic_community.RequestUserChatState(chatlist, function()
            EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_CLUB_STATE_UPDATE)
          end)
        end
      end
      RequestChatState(1, maxCnt)
      RequestChatState(1 + maxCnt, 2 * maxCnt)
    end
  end
end
function Lobby_InviteFriend_BP:SwitchTab(tag)
  self:PlayAudio(sound_config.click)
  log(bWriteLog and string.format("Lobby_InviteFriend_BP:SwitchTab %s", tag))
  self.UIRoot.ReuseFall:ScrollToStart()
  self.List:ScrollToItem(1)
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  local tabID = logic_friend_list_ui:GetTabID()
  if tabID ~= tag then
    self.bSwitchTag = true
    if self.bShowComboBoxGuide and (tag ~= FLMacros.ENUM_TAB.ENUM_FRIEND_TAG or tag ~= FLMacros.ENUM_TAB.ENUM_RECENT_TAG) then
      self.bShowComboBoxGuide = false
      self:SetWidgetVisible(self.UIRoot.CanvasPanel_ScreenGuid, false)
      local logic_friend_group_tools = require("client.slua.logic.friend.logic_friend_group_tools")
      logic_friend_group_tools.SetHasShowDropGuide()
    end
    if self.reserveGuideShowed then
      local Friend_ReserveGuide_Tips = UIManager.GetUI(UIManager.UI_Config.Friend_ReserveGuide_Tips)
      if Friend_ReserveGuide_Tips and Friend_ReserveGuide_Tips:IsShow() then
        self:HideOrShowReserveGuideTips()
      end
    end
  end
  logic_friend_list_ui:SetTabID(tag)
  local logic_friend_group = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_group)
  LogicTeamUpSideBar.SetTag(tag)
  self:InitDeskTopToolBtn()
  if tag == FLMacros.ENUM_TAB.ENUM_FRIEND_TAG then
    self.UIRoot.TextBlock_All:SetText(LocUtil.GetLocalizeResStr(102124))
    self:RequestUpdateFriendReserveData()
    logic_friend_group:SetFoldingFirstGroup(false)
    logic_friend_group:ResetSelectGroupList()
    self:SetWidgetVisible(self.UIRoot.ScaleBox_Toptext, false)
  elseif tag == FLMacros.ENUM_TAB.ENUM_RECENT_TAG then
    self.UIRoot.TextBlock_All:SetText(LocUtil.GetLocalizeResStr(7890))
    logic_friend_group:SetFoldingFirstGroup(false)
    logic_friend_group:ResetSelectGroupList()
    self:ReqRecentData()
    self:SetWidgetVisible(self.UIRoot.ScaleBox_Toptext, false)
  elseif tag == FLMacros.ENUM_TAB.ENUM_CORPS_TAG then
    logic_friend_group:SetFoldingFirstGroup(false)
    logic_friend_group:ResetSelectGroupList()
    self.UIRoot.TextBlock_All:SetText(LocUtil.GetLocalizeResStr(6224))
    self:SetWidgetVisible(self.UIRoot.ScaleBox_Toptext, true)
  elseif tag == FLMacros.ENUM_TAB.ENUM_LBS_NEAR then
    logic_friend_group:SetFoldingFirstGroup(false)
    logic_friend_group:ResetSelectGroupList()
    self.UIRoot.TextBlock_All:SetText(LocUtil.GetLocalizeResStr(24601))
    self:SetWidgetVisible(self.UIRoot.ScaleBox_Toptext, false)
  elseif tag == FLMacros.ENUM_TAB.ENUM_WOW_TAG then
    logic_friend_group:SetFoldingFirstGroup(false)
    logic_friend_group:ResetSelectGroupList()
    self.UIRoot.TextBlock_All:SetText(LocUtil.GetLocalizeResStr(792510))
    self:SetWidgetVisible(self.UIRoot.ScaleBox_Toptext, false)
  end
  if self.bSwitchTag then
    self.Common_ScreenBox_UIBP:SetSelectIndex(1)
    self.Common_ScreenBox_UIBP:RefreshSwitcher(true)
  end
  logic_friend_list_ui:SetState(FLMacros.ENUM_STATE.FRIENDS)
  self:UpdateDeleteUI()
  self:SetOneTabData(true)
  if tag == LogicTeamUpSideBar.ENUM_TAB.ENUM_LBS_NEAR then
    local LBSFriendMgr = require("client.slua.logic.lbs.logic_lbs_friend")
    if LBSFriendMgr:CanOpenNearFriend() and not LBSFriendMgr:CanGetNearFriendList() then
      log(bWriteLog and "Lobby_InviteFriend_BP:SwitchTab lsb")
      local logic_lbs_warzone = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lbs_warzone)
      if logic_lbs_warzone:RefreshGPSZone(true) then
        ShowNotice(113100007)
      end
    end
  end
  if tag == LogicTeamUpSideBar.ENUM_TAB.ENUM_FRIEND_TAG then
    self:SetWidgetVisible(self.UIRoot.Button_BatchDelete, true, true)
    self:SetWidgetVisible(self.UIRoot.Button_BatchTop, true, true)
  else
    self:SetWidgetVisible(self.UIRoot.Button_BatchDelete, false)
    self:SetWidgetVisible(self.UIRoot.Button_BatchTop, false)
  end
  self:SetWidgetVisible(self.UIRoot.HorizontalBox_SearchFriend, false, true)
  self:SetWidgetVisible(self.UIRoot.Button_SearchFriendLocal, tag == FLMacros.ENUM_TAB.ENUM_FRIEND_TAG or tag == FLMacros.ENUM_TAB.ENUM_WOW_TAG, true)
  self:SetWidgetVisible(self.UIRoot.HorizontalBox_TopButton, true, true)
  if tag ~= FLMacros.ENUM_TAB.ENUM_FRIEND_TAG then
    self.bEnableLocalSearchFriend = false
    self.tLocalSearchFriendDataList = {}
    self:ResetSearchText()
  end
  if tag == FLMacros.ENUM_TAB.ENUM_WOW_TAG then
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_WOW, true, false)
    self:SetWidgetVisible(self.UIRoot.Common_ScreenBox_UIBP, false, false)
    self:HideFriendEnableGifted()
  else
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_WOW, false)
  end
  self:Update_TeamTab(tag)
end
function Lobby_InviteFriend_BP:Update_TeamTab(tag)
  local isTeamTag = tag == FLMacros.ENUM_TAB.ENUM_TEAM_TAG
  self:SetWidgetVisible(self.UIRoot.Lobby_InviteFriend_TeamQuick_UIBP, isTeamTag, true)
  self:SetWidgetVisible(self.UIRoot.HorizontalBox_TopButton, not isTeamTag, true)
  self:SetWidgetVisible(self.UIRoot.HorizontalBox_Bottom, not isTeamTag, true)
  if isTeamTag then
    self:HideFriendEnableGifted()
    self:SetWidgetVisible(self.UIRoot.ScaleBox_Toptext, false)
    self:SetWidgetVisible(self.UIRoot.ChickenTips, false)
    self:SetWidgetVisible(self.UIRoot.Button_NewState, false)
    self:SetWidgetVisible(self.UIRoot.Button_Lucky, false)
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_Return, false, true)
    if not self.Lobby_InviteFriend_TeamQuick_UIBP then
      local UIComponentModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.UIComponentModule)
      self.Lobby_InviteFriend_TeamQuick_UIBP = UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.Lobby_InviteFriend_TeamQuick_UIBP, self.UIRoot.Lobby_InviteFriend_TeamQuick_UIBP)
    else
      self.Lobby_InviteFriend_TeamQuick_UIBP:UpdateUI()
    end
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_ScreenGuid, false)
  else
    self:RefreshMyStatus()
    self:RefreshLuckyStarBtn()
    self:InitReturnPlayer()
    self:SetWidgetVisible(self.UIRoot.HorizontalBox_SearchFriend, false, true)
    self:SetWidgetVisible(self.UIRoot.Button_SearchFriendLocal, true, true)
  end
end