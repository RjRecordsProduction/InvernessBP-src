local Lobby_InviteFriend_BP = require("client.slua.umg.lobby.FriendList.Lobby_InviteFriend_BP_Data")
local FLMacros = require("client.slua.logic.friend.refactor.friend_list_macros")
function Lobby_InviteFriend_BP:UpdateReserveGuideShow()
  self:SetWidgetVisible(self.UIRoot.ReserveTips, false)
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  local tabID = logic_friend_list_ui:GetTabID()
  if tabID ~= FLMacros.ENUM_TAB.ENUM_FRIEND_TAG then
    return
  end
  if self.isUserScrolled then
    return
  end
  local logic_friend_reserve = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_reserve)
  if logic_friend_reserve:IsReserveGuideShowed() then
    return
  end
  local friendList = logic_friend_list_ui:GetFriendList()
  local index = logic_friend_reserve:GetReserveGuideFriendIndex(friendList)
  log(bWriteLog and "[v_wllwu] teamup_side_bar:UpdateReserveGuideShow, friendGuideItemIndex:" .. tostring(index))
  if not index then
    return
  end
  logic_friend_list_ui.friendGuideItemIndex = index
  if not logic_friend_list_ui.friendGuideItemIndex or logic_friend_list_ui.friendGuideItemIndex <= 0 then
    return
  end
  log(bWriteLog and "[v_wllwu] teamup_side_bar:UpdateReserveGuideShow scroll")
  self.jumpUid = nil
  self:RemoveDalayScrollTimer()
  self.scrollListDelayTimer = self:AddTimer(0.3, function()
    self.ReuseFall:ScrollToItem(logic_friend_list_ui.friendGuideItemIndex, true)
    coroutine.yield(0.5)
    local count = self.ReuseFall:GetItemCount()
    if count >= index then
      self.isCanShow = true
      self.ReuseFall:RefreshItem(index)
    end
  end)
end
function Lobby_InviteFriend_BP:RemoveDalayScrollTimer()
  if self.scrollListDelayTimer then
    self:RemoveTimer(self.scrollListDelayTimer)
    self.scrollListDelayTimer = nil
  end
end
function Lobby_InviteFriend_BP:RemoveReserveGuideTimer()
  if self.reserveGuideTimer then
    self:RemoveTimer(self.reserveGuideTimer)
    self.reserveGuideTimer = nil
  end
end
local reserveGuideShowed
function Lobby_InviteFriend_BP:HideOrShowReserveGuideTips(bShow, widget, index)
  if not bShow then
    self:RemoveReserveGuideTimer()
    self:RemoveDalayScrollTimer()
    UIManager.CloseUI(UIManager.UI_Config.Friend_ReserveGuide_Tips)
    self:UpdateFriendReserveGuideData()
    return
  end
  if not widget or not index then
    return
  end
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  if not logic_friend_list_ui.friendGuideItemIndex or logic_friend_list_ui.friendGuideItemIndex ~= index then
    return
  end
  if not self.isCanShow then
    return
  end
  self.isCanShow = nil
  reserveGuideShowed = true
  local bIsUGCReserve = false
  local nFriendSubMode = 0
  local friendData = logic_friend_list_ui:GetPlayerData(index)
  if friendData then
    local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
    local status = PlayerStatusMgr:GetStatusData(friendData.uid)
    if status and status.mod_id and 0 < status.mod_id then
      bIsUGCReserve = true
    end
    nFriendSubMode = status and status.game_sub_mode or 0
  end
  log(bWriteLog and "Lobby_InviteFriend_BP_Guide:ShowReserveGuideTips nFriendSubMode =" .. tostring(nFriendSubMode) .. " bIsUGCReserve =" .. tostring(bIsUGCReserve))
  local extraparam = {bIsUGCReserve = bIsUGCReserve, nFriendSubMode = nFriendSubMode}
  UIManager.ShowUI(UIManager.UI_Config.Friend_ReserveGuide_Tips, widget.Button_Reserved, extraparam)
  self.reserveGuideTimer = self:AddTimerOnce(5, function()
    self:HideOrShowReserveGuideTips()
  end)
end
function Lobby_InviteFriend_BP:UpdateFriendReserveGuideData()
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  logic_friend_list_ui.friendGuideItemIndex = nil
  if not reserveGuideShowed then
    return
  end
  local logic_friend_reserve = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_reserve)
  logic_friend_reserve:UpdateReserveGuideData()
end
function Lobby_InviteFriend_BP:CheckNewStatusGuide()
  local haveNewbie = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_NEW_FRIENDSTATUS, 1)
  if haveNewbie and LobbySystem.CheckOpen(BP_ENUM_NEW_FRIEND_STATUS_SWITCH) then
    self:SetWidgetVisible(self.UIRoot.image_Reddot_status, true)
    self:PlayUserWidgetAnimation(self.UIRoot.Anim_Guide, 0, 0, 0, 1)
  else
    self:SetWidgetVisible(self.UIRoot.image_Reddot_status, false)
    self.UIRoot:StopAnimation(self.UIRoot.Anim_Guide)
  end
end
function Lobby_InviteFriend_BP:ShowPopUpUI()
  log(bWriteLog and "Lobby_InviteFriend_BP:ShowPopUpUI")
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_ScreenGuid, false)
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  local from = logic_friend_list_ui:GetFrom()
  if from == FLMacros.ENUM_OPEN_FROM.PLANPH then
    log_warning(bWriteLog and "Lobby_InviteFriend_BP:ShowPopUpUI. is in planph")
    return
  end
  local LogicTeamUpSideBar = require("client.slua.logic.lobby.logic_teamup_side_bar")
  local logic_luckystar_face_slap = require("client.slua.logic.lucky_star.logic_luckystar_face_slap")
  if not LogicTeamUpSideBar.IsInRoom() and logic_luckystar_face_slap.ShouldSlap() then
    log(bWriteLog and "Lobby_InviteFriend_BP:ShowPopUpUI show lucky star face slap")
    UIManager.ShowUI(UIManager.UI_Config.Lobby_Lucky_Teammate_UIBP)
    return
  end
  self:UpdateReserveGuideShow()
  local level_unlock_util = require("client.logic.level_unlock.util.level_unlock_util")
  local bHaveLockedFeature = level_unlock_util:HaveLockedFeature()
  log(bWriteLog and "Lobby_InviteFriend_BP:ShowPopUpUI bHaveLockedFeature = " .. tostring(bHaveLockedFeature))
  local tabID = logic_friend_list_ui:GetTabID()
  if tabID == FLMacros.ENUM_TAB.ENUM_WOW_TAG or tabID == FLMacros.ENUM_TAB.ENUM_TEAM_TAG then
    log_warning(bWriteLog and "Lobby_InviteFriend_BP:ShowPopUpUI. return by tabID = " .. tabID)
    return
  end
  local logic_friend_group_tools = require("client.slua.logic.friend.logic_friend_group_tools")
  if not bHaveLockedFeature and logic_friend_group_tools.NeedShowDropGuide() then
    log(bWriteLog and "[v_vvyangli] Lobby_InviteFriend_BP:ShowPopUpUI tabID = ", tabID)
    self.bShowComboBoxGuide = true
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_ScreenGuid, true)
    self.UIRoot.UTRichTextBlock_Tips:SetText(LocUtil.GetLocalizeResStr(73572))
    self:AddTimerOnce(3, function()
      self:SetWidgetVisible(self.UIRoot.CanvasPanel_ScreenGuid, false)
      self.bShowComboBoxGuide = false
      logic_friend_group_tools.SetHasShowDropGuide()
    end)
  end
  if not self.bShowComboBoxGuide then
    self.bCanShowtips = true
  end
end
function Lobby_InviteFriend_BP:SaveOpenTime()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local TimeUtil = require("client.common.time_util")
  local data = {}
  data.time = TimeUtil.GetServerTimeInSec()
  PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.eOpenTeamupSideBatTime)
end
function Lobby_InviteFriend_BP:OnUserScrolled()
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Menu, false)
  self.isUserScrolled = true
  if self.reserveGuideShowed then
    local Friend_ReserveGuide_Tips = UIManager.GetUI(UIManager.UI_Config.Friend_ReserveGuide_Tips)
    if Friend_ReserveGuide_Tips and Friend_ReserveGuide_Tips:IsShow() then
      self:HideOrShowReserveGuideTips()
    end
  else
    self.friendGuideItemIndex = nil
    self:RemoveReserveGuideTimer()
    self:RemoveDalayScrollTimer()
  end
end
function Lobby_InviteFriend_BP:OnEndScroll()
  self.isUserScrolled = nil
end
function Lobby_InviteFriend_BP:ShowTeamQuickGuide()
  log(bWriteLog and "Lobby_InviteFriend_BP:ShowTeamQuickGuide")
  if not self.Lobby_InviteFriend_TeamQuick_UIBP then
    log_warning(bWriteLog and "Lobby_InviteFriend_BP:ShowTeamQuickGuide Lobby_InviteFriend_TeamQuick_UIBP is nil")
    return
  end
  local uiInfo = self.Lobby_InviteFriend_TeamQuick_UIBP:ShowNewbieGuide()
  local isShow = uiInfo ~= nil
  self._teamQuickGuideInfo = uiInfo
  if not isShow then
    log_warning(bWriteLog and "Lobby_InviteFriend_BP:ShowTeamQuickGuide isShow is false")
    return
  end
  local tabIndex = self:GetTabIndexByTabID(FLMacros.ENUM_TAB.ENUM_TEAM_TAG)
  if not tabIndex then
    log_warning(bWriteLog and "Lobby_InviteFriend_BP:ShowTeamQuickGuide tabIndex is nil")
    return
  end
  local tabItem = self.TabList:GetIndexOfItem(tabIndex)
  if not tabItem then
    log_warning(bWriteLog and "Lobby_InviteFriend_BP:ShowTeamQuickGuide tabItem is nil")
    return
  end
  tabItem:ShowFlashGlow()
end