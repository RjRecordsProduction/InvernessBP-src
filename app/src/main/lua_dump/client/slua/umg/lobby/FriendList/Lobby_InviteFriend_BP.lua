require("client.slua.umg.lobby.FriendList.Lobby_InviteFriend_BP_Guide")
require("client.slua.umg.lobby.FriendList.Lobby_InviteFriend_BP_Update")
require("client.slua.umg.lobby.FriendList.Lobby_InviteFriend_BP_Reg")
require("client.slua.umg.lobby.FriendList.Lobby_InviteFriend_BP_Req")
require("client.slua.umg.lobby.FriendList.Lobby_InviteFriend_BP_Click")
require("client.slua.umg.lobby.FriendList.Lobby_InviteFriend_BP_Search")
require("client.slua.umg.lobby.FriendList.Lobby_InviteFriend_BP_Group")
require("client.slua.umg.lobby.FriendList.Lobby_InviteFriend_BP_Tab")
require("client.slua.umg.lobby.FriendList.Lobby_InviteFriend_BP_Gift")
require("client.slua.umg.lobby.FriendList.Lobby_InviteFriend_BP_WOW")
require("client.slua.umg.lobby.FriendList.Lobby_InviteFriend_BP_Anim")
local Lobby_InviteFriend_BP = require("client.slua.umg.lobby.FriendList.Lobby_InviteFriend_BP_Data")
local LogicTeamUpSideBar = require("client.slua.logic.lobby.logic_teamup_side_bar")
local FLMacros = require("client.slua.logic.friend.refactor.friend_list_macros")
function Lobby_InviteFriend_BP:ctor(_, from, tab, jumpUid, modInfo)
  log(bWriteLog and string.format("Lobby_InviteFriend_BP:ctor %s %s %s", from, tab, jumpUid))
  self.  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  logic_friend_list_ui:SetFrom(self.from)
  local lastTabID = logic_friend_list_ui:GetTabID()
  logic_friend_list_ui:SetTabID(tab or lastTabID or LogicTeamUpSideBar.ENUM_TAB.ENUM_FRIEND_TAG)
  self.  self.bEnableLocalSearchFriend = false
  self.tLocalSearchFriendDataList = {}
  self.bSwitchTag = true
  self.ChoseToGift = {}
  self.giftIndex = 1
  self.IsFirsrRefresh = true
  self.EnableToGiftList = {}
  self.lastIndex = 0
  self.bCanShowtips = false
  self.end
function Lobby_InviteFriend_BP:OnInitialize()
  self.List = self:InitChildClassScrollBox(self.UIRoot.LoopScrollBox_1, "client.slua.umg.lobby.FriendList.Item.FriendsListItem_BP")
  self.WOWList = self:InitExtendedScrollGrid(self.UIRoot.ExtendedLoopScrollGrid_1, {
    "client.slua.umg.lobby.FriendList.WowItem.FriendsListWow_Title_item",
    "client.slua.umg.lobby.FriendList.WowItem.FriendsListWow_Item"
  })
  self.ReuseFall = self:InitReuseFallMultiSize(self.UIRoot.ReuseFall, "client.slua.umg.lobby.FriendList.ExtendItem.FriendsListReuseFall_Item")
  local UIComponentModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.UIComponentModule)
  self.Common_ScreenBox_UIBP = UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.Common_ScreenBox_UIBP, self.UIRoot.Common_ScreenBox_UIBP)
  local FriendHandler = require("client.network.Protocol.FriendHandler")
  FriendHandler.send_get_friend_status_detail_req()
  self:RequestUpdateFriendReserveData()
  local LBSFriendMgr = require("client.slua.logic.lbs.logic_lbs_friend")
  if LBSFriendMgr:CanOpenNearFriend() and LBSFriendMgr:CanGetNearFriendList() then
    local LBSHandler = require("client.network.Protocol.LBSHandler")
    LBSHandler.lbs_nearly_player_req()
  end
  local logic_lbs_warzone = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lbs_warzone)
  logic_lbs_warzone:InitLocationInterface()
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  PlayerStatusMgr:IsNeedUpdateWoWInfo()
  self.TabList = self:InitChildClassScrollBox(self.UIRoot.Common_Tab_Vertical_LevelOne_Icon_UIBP_L.LoopScrollBox_Tab, "client.slua.umg.lobby.FriendList.Item.Lobby_InviteFriend_Tab_Item")
  self:SetWidgetVisible(self.UIRoot.Common_Tab_Vertical_LevelOne_Icon_UIBP_L.Image_RightBg, true)
end
function Lobby_InviteFriend_BP:RegistEvents()
  self:AddOnClickedEventByControl(self.UIRoot.Button_BatchDelete, self.OnClickFriendsDelete, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_LeaveDelete, self.OnLeaveFriendsDelete, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_BatchTop, self.OnClickFriendsTop, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_TopConfirm, self.ClickConfirmTop, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Lock, self.OnButton_LockClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_FriendApplyList, self.ClickFriendApply, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_SearchFriend, self.ClickTopAddFriends, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Close, self.ClosePanelMute, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_FaceTeam, self.ClickFaceTeam, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Menu, self.ClickMenu, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_DeleteConfirm, self.ClickConfirmDelete, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_BlackList, self.ClickBlackList, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_State_Home, self.ClickShowState, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Lucky, self.ClickLuckyStar, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_DeskTopTool, self.ClickDeskTopTool, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Tips, self.ClickReturnTips, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_SearchFriendLocal, self.OnClickButtonSearchFriendLocal, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_SearchFriendCommit, self.OnClickButton_SearchFriendCommit, self)
  self:AddControlEventByControl(self.UIRoot.Common_Search_Item_UIBP.message_input, "OnTextCommitted", self.OnInputBoxCommitted, self)
  self:AddControlEventByControl(self.UIRoot.Common_Search_Item_UIBP.close, "OnClicked", self.OnClickCancelSearch, self)
  self:AddControlEventByControl(self.UIRoot.LoopScrollBox_1, "OnUserScrolled", self.OnUserScrolled, self)
  self:AddControlEventByControl(self.UIRoot.LoopScrollBox_1, "OnEndScroll", self.OnEndScroll, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Gift, self.ShowFriendGift, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_WorkName, self.OnClickWorkName, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_InviteTeam, self.ClickInviteJoin, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_NewState, self.ClickShowState, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_SetDisplay, self.OnClickButton_SetDisplay, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_SNSTeam, self.OnClickSNSInvite, self)
  self.ReuseFall:SetBeforeNewItemCallback(self.OnSetBeforeNewListItem, self)
  self.Common_ScreenBox_UIBP:SetCheckBoxStateChangeCallBack(self.OnSelectTagOption, self)
  self.Common_ScreenBox_UIBP:SetFirstClickSelectCallBack(self.OnFirstClickSelectCallBack, self)
  self.Common_ScreenBox_UIBP:SetClickSelectCallBack(self.OnClickSelectCallBack, self)
  self.Common_ScreenBox_UIBP:SetClearCallBack(self.OnClearTagSelectCallBack, self)
  self:AddCommonEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_APPLYLIST_CHANGE, self.ShowFriendApply, self)
  self:AddCommonEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_INTIMACYAPPLY_CHANGE, self.ShowFriendApply, self)
  self:AddCommonEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_ADD_DELETE_FRIEND, self.OnFriendAddOrDelete, self)
  self:AddCommonEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_DELETE_BATCH_FRIEND, self.OnLeaveFriendsDelete, self)
  self:AddCommonEvent(EVENTTYPE_FRIEND, EVENTID_BATCH_GET_PLAYERSTATUS, self.OnFriendStatusChange, self)
  self:AddCommonEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_UPDATE_REMARK, self.OnFriendStatusChange, self)
  self:AddCommonEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_GROUP_ONLINE_CHANGE, self.OnFriendStatusChange, self)
  self:AddCommonEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_INTIMACY_UPDATE, self.OnFriendStatusChange, self)
  self:AddCommonEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_STATUS_CHANGE, self.OnFriendStatusChange, self)
  self:AddCommonEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_TOP_STATUS_CHANGE, self.OnFriendStatusChange, self)
  self:AddCommonEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_SELF_STATUS_CHANGE, self.RefreshMyStatus, self)
  self:AddCommonEvent(EVENTTYPE_FRIEND, EVENTID_UPDATE_RECENT_STATUS, self.OnRecentReqResponse, self)
  self:AddCommonEvent(EVENTTYPE_CORPS, EVENTID_CORPS_GET_MEMBERLIST, self.OnGetCorpsData, self)
  self:AddCommonEvent(EVENTTYPE_CHAT, EVENTTYPE_CHAT_RESERVE_RESPONSE, self.OnFriendReserved, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENT_PROFILE_RESPONSE, self.GetProfile, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENT_RANKPROFILE_RESPONSE, self.GetRankProfile, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENT_CLOSE_SIDEBAR, self.OnAndroidBack, self)
  self:AddCommonEvent(EVENTTYPE_CORPS, EVENTID_CORPS_MEMBER_ONLINE_INFO_UPDATE, self.UpdateCorpsMembers, self)
  self:AddCommonEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PARTNER_PREVIEW_OPEN, self.PartnerPreviewOpen, self)
  self:AddCommonEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PARTNER_PREVIEW_CLOSE, self.PartnerPreviewClose, self)
  self:AddCommonEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_REDDOT_UPDATE, self.ShowFriendApply, self)
  self:AddCommonEvent(EVENTTYPE_CORPS, EVENTID_CORPS_MEMBER_STATUS_UPDATE, self.OnCorpsStatusChange, self)
  self:AddCommonEvent(EVENTTYPE_FRIEND, EVENTID_MY_ONLINE_STATE_CHANGE, self.RefreshMyStatus, self)
  self:AddCommonEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_FRIEND_LIKED_NOTIFY, self.RefreshMyStatus, self)
  self:AddCommonEvent(EVENTTYPE_LBS, EVENTID_LBS_UPDATE_TEAM_BAR_LIST, self.UpdateNearsData, self)
  self:AddCommonEvent(EVENTTYPE_LBS, EVENTID_LBS_UPDATE_TEAM_BAR_STATUS, self.UpdateNearsData, self)
  self:AddCommonEvent(EVENTTYPE_LBS, EVENTID_LBS_UPDATE_MY_ZONE, self.UpdateLbsHandler, self)
  self:AddCommonEvent(EVENTTYPE_LBS, EVENTID_LBS_UPDATE_JOIN_LBS, self.UpdateLbsHandler, self)
  self:AddCommonEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_CLUB_STATE_UPDATE, self.UpdateClubsStatus, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_SHARE_TEAM_INVITE_LINK, self.OnInviteOfflineMessageFriend, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_SWITCHTO_PAGE_END, self.OnPageSwitched, self)
  self:AddCommonEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_RESERVE_FORCEUPDATE_DATA, self.OnForceUpdateFriendReserveState, self)
  self:AddCommonEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_RESERVE_STATUS_CHANGE, self.OnFriendReserved, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_LUCKY_STAR_UPDATE, self.RefreshLuckyStarBtn, self)
  self:AddCommonEvent(EVENTTYPE_FRIEND, EVENTID_RECENT_GET_INTERACT_DATA, self.OnGetRecentInteractData, self)
  self:AddCommonEvent(EVENTTYPE_PLANPH_LOBBY, EVETNID_PLANPH_JOINT_INFO_UPDATE, self.ShowFriendApply, self)
  self:AddCommonEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_GIFT_SEND, self.HideFriendEnableGifted, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_FRIEND_QUERY_QUiCK_GIFT_DATA, self.RefreshEnableToGiftListAndChoseToGift, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_FRIEND_GIFT_SEND_SUCESSFUL, self.QueryQuickGiftScucess, self)
  self:AddCommonEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_PRE_SWITCH, self.CloseSelf, self)
  local logic_lbs_warzone = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lbs_warzone)
  if logic_lbs_warzone:CheackIsOpenZoneGPS() then
    self:AddCommonEvent(EVENTTYPE_LBS, EVENTID_LBS_UPDATE_LOCATION_INFO, self.OnGPSLBSInfoChenged, self)
  end
  self:AddCommonEvent(EVENTTYPE_FLASH_TEAM, EVENTID_FLASH_TEAM_APPLY_LIST_CHANGE, self.ShowFriendApply, self)
  self:AddOnAnimationFinishedEvent("Anim_Enter", self.OnEnterAnimationFinished, self)
  self:AddCommonEvent(EVENTTYPE_FLASH_TEAM, EVENTID_FLASH_TEAM_DATA_CHG, self.RefreshFlashTeamNumber, self)
end
function Lobby_InviteFriend_BP:OnPostInitialize()
  local UIUtil = require("client.common.ui_util")
  UIUtil.SetAdaptation(self.UIRoot.CanvasPanel_IPX)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_IPX, true)
  self:UpdateDeleteUI()
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  local isRestrict = QRcodeRestrictManager:IsRestrictSocial()
  self:SetWidgetVisible(self.UIRoot.Button_Lock, isRestrict, true)
  if isRestrict then
    self:SetWidgetVisible(self.UIRoot.Button_DeleteConfirm, true, false)
  else
    self:SetWidgetVisible(self.UIRoot.Button_DeleteConfirm, true, true)
  end
  self:ShowHideStateList(false)
  self.UIRoot.TextBlock_platform:SetText(LocUtil.LocalizeResFormat(69992))
  self.UIRoot.TextBlock_15:SetText(LocUtil.LocalizeResFormat(69992))
  self.UIRoot.TextBlock_9:SetText(LocUtil.LocalizeResFormat(69990))
  self.UIRoot.TextBlock_10:SetText(LocUtil.LocalizeResFormat(69991))
  self.UIRoot.TextBlock_platform:SetText(LocUtil.LocalizeResFormat(87395))
  self.UIRoot.TextBlock_SetDisPlay:SetText(LocUtil.LocalizeResFormat(87398))
  local logic_friendnum_limit = require("client.slua.logic.friend.logic_friendnum_limit")
  local bAdd = logic_friendnum_limit.CheckAndShowFriendNumLimitTipsUI(self, "CanvasPanel_tips")
  if bAdd then
    self:AddTimerOnce(5, function()
      logic_friendnum_limit.CloseFriendNumLimitTipsUI(self, false)
    end)
  end
  self:ResetSearchText()
  self:ReqRecentData()
  self:SetWidgetVisible(self.ReuseFall, false)
  self:ShowFriendWOW()
  local logic_new_friend = require("client.slua.logic.friend.logic_new_friend")
  local onlineCount, totalCount = logic_new_friend.GetFriendOnlineCount()
  if totalCount < 1 and 5 > self.reqListTime then
    self.reqListTime = self.reqListTime + 1
    local FriendHandler = require("client.network.Protocol.FriendHandler")
    FriendHandler.send_get_all_friendlist_req()
  end
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  PlayerStatusMgr:SetEnableRequestModInfo(true)
end
function Lobby_InviteFriend_BP:OnClose()
  local logic_poke = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_poke)
  logic_poke:ChatClosePokeBox()
  self.modInfo = nil
  local UI_NewbieGuide_UIBP = UIManager.GetUI(UIManager.UI_Config.NewbieGuide_UIBP)
  if UI_NewbieGuide_UIBP then
    UIManager.CloseUI(UIManager.UI_Config.NewbieGuide_UIBP)
  end
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  local from = logic_friend_list_ui:GetFrom()
  local FLMacros = require("client.slua.logic.friend.refactor.friend_list_macros")
  if from == FLMacros.ENUM_OPEN_FROM.PLANPH then
    EventSystem:postEvent(EVENTTYPE_PLANPH_NORMAL, EVENTID_CLOSE_PLANPH_INVITE)
  elseif from == FLMacros.ENUM_OPEN_FROM.PLANCH then
    EventSystem:postEvent(EVENTTYPE_PLANCH_NORMAL, EVENTID_PLANCH_CLOSE_INVITE)
  end
  LogicTeamUpSideBar.ClearData()
  self:ShowHideStateList(false)
  self:HideOrShowReserveGuideTips()
  self:UpdateFriendReserveGuideData()
  local logic_lbs_warzone = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lbs_warzone)
  logic_lbs_warzone:DestroyLocationInterface()
  local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
  PlayerStatusMgr:SetEnableRequestModInfo(false)
  self.pendingTabTextUpdates = nil
  if self.UIRoot.Common_Tab_Vertical_LevelOne_Icon_UIBP_L then
    self:SetWidgetVisible(self.UIRoot.Common_Tab_Vertical_LevelOne_Icon_UIBP_L.Image_RightBg, false)
  end
  log_format("Lobby_InviteFriend_BP:OnClose. _teamQuickGuideInfo = [%s]", self._teamQuickGuideInfo)
  if self._teamQuickGuideInfo and self._teamQuickGuideInfo:IsShow() then
    log(bWriteLog and "Lobby_InviteFriend_BP:OnClose. close team quick guide")
    self._teamQuickGuideInfo:CloseSelf()
  end
  self._teamQuickGuideInfo = nil
  Lobby_InviteFriend_BP.__super.OnClose(self)
end
function Lobby_InviteFriend_BP:UpdateUI()
  log(bWriteLog and "Lobby_InviteFriend_BP:UpdateUI")
  local item_data = {}
  self.LoopScrollBox_Friend:SetData(item_data)
end
function Lobby_InviteFriend_BP:HideMenu()
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Menu, false)
end
function Lobby_InviteFriend_BP:HideNewbie()
  self:SetWidgetVisible(self.UIRoot.Panel_NewbieGuide, false)
end
function Lobby_InviteFriend_BP:ShowMenu(uid)
  local ChatMenuSystem = require("client.slua.logic.lobby_chat.logic_chat_menu")
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  local tabID = logic_friend_list_ui:GetTabID()
  local menuUI = UIManager.ShowUI(UIManager.UI_Config.ChatMenu_BP, {
    Uid = uid,
    IsShowReport = false,
    openTag = tabID
  }, ChatMenuSystem.EShowLocationType.Friend)
  local UIUtil = require("client.common.ui_util")
  local viewPortScale = UIUtil.GetViewportSize()
  local offsetX = 20
  if viewPortScale.X / viewPortScale.Y >= 1.5 and viewPortScale.X > 1500 then
    offsetX = 60
  end
  menuUI:SetTipsForInviteFriend(self.UIRoot.FriendListGroup, offsetX, 60)
end
function Lobby_InviteFriend_BP:OnClickTab(tag)
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  if logic_friend_list_ui:GetTabID() == tag then
    log(bWriteLog and "Lobby_InviteFriend_BP:OnClickTab return same tab")
    return
  end
  self:SwitchTab(tag)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, Lobby_InviteFriend_BP)