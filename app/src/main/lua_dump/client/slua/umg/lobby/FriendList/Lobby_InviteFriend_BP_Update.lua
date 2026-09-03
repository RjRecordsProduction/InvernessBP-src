local Lobby_InviteFriend_BP = require("client.slua.umg.lobby.FriendList.Lobby_InviteFriend_BP_Data")
local FLMacros = require("client.slua.logic.friend.refactor.friend_list_macros")
local local 
function Lobby_InviteFriend_BP:UpdateDeleteUI()
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  local state = logic_friend_list_ui:GetState()
  if state == FLMacros.ENUM_STATE.FRIENDS_DELETE then
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_TopConfirm, false)
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_DeleteConfirm, true)
    self.UIRoot.WidgetSwitcher_Top:SetActiveWidgetIndex(1)
    self.UIRoot.WidgetSwitcher_Bot:SetActiveWidgetIndex(1)
    self:UpdateBatchCntUI()
  elseif state == FLMacros.ENUM_STATE.FRIENDS_TOP then
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_TopConfirm, true)
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_DeleteConfirm, false)
    self.UIRoot.WidgetSwitcher_Top:SetActiveWidgetIndex(1)
    self.UIRoot.WidgetSwitcher_Bot:SetActiveWidgetIndex(1)
    self:UpdateBatchCntUI()
  else
    self.UIRoot.WidgetSwitcher_Top:SetActiveWidgetIndex(0)
    self.UIRoot.WidgetSwitcher_Bot:SetActiveWidgetIndex(0)
  end
  if self.UIRoot.CanvasPanel_Menu then
    self.UIRoot.CanvasPanel_Menu:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function Lobby_InviteFriend_BP:UpdateBatchCntUI()
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  local state = logic_friend_list_ui:GetState()
  local cnt = 0
  local max = 0
  if state == FLMacros.ENUM_STATE.FRIENDS_DELETE then
    cnt = logic_friend_list_ui:GetDelCnt()
    max = FLMacros.Friend_MaxBatchDelCount
  else
    if state == FLMacros.ENUM_STATE.FRIENDS_TOP then
      cnt = logic_friend_list_ui:GetTopCnt()
      max = FLMacros.Friend_MaxBatchTopCount
    else
    end
  end
  if max ~= 0 then
    self.UIRoot.Text_BatchDelete:SetText(LocUtil.LocalizeResFormat(6830, cnt, max))
  end
end
function Lobby_InviteFriend_BP:ShowHideStateList(bShow)
  if bShow then
    UIManager.ShowUI(UIManager.UI_Config.friend_choose_gamestate)
  else
    UIManager.CloseUI(UIManager.UI_Config.friend_choose_gamestate)
  end
end
function Lobby_InviteFriend_BP:ResetSearchText()
  log(bWriteLog and string.format("teamup_side_bar:ResetSearchText"))
  local inputEditorText = self.UIRoot.Common_Search_Item_UIBP.message_input
  inputEditorText:SetHintText("")
  inputEditorText:SetText("")
end
function Lobby_InviteFriend_BP:OnShow()
  self:InitReturnPlayer()
  self:InitDeskTopToolBtn()
  self:InitFriendButton()
  self:SetWidgetVisible(self.UIRoot.HorizontalBox_Bottom, true, true)
  self:InitButtonMenu()
  self:SetWidgetVisible(self.UIRoot.Button_Intimacy, false, true)
  self:SetWidgetVisible(self.UIRoot.Button_OldFriend, false)
  self:InitLuckyStarData()
  self:RefreshLuckyStarBtn()
  self:ShowFriendApply()
  self:InitTabList()
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  local currentTabID = logic_friend_list_ui:GetTabID()
  self:SwitchTab(currentTabID)
  local tabIndex = self:GetTabIndexByTabID(currentTabID)
  if tabIndex then
    self.TabList:Select(tabIndex)
  else
    log(bWriteLog and string.format("OnShow: currentTabID %s not available, select first tab", tostring(currentTabID)))
    if self.CurrentTabList and #self.CurrentTabList > 0 then
      self.TabList:Select(1)
      local firstTabID = self.CurrentTabList[1].TabID
      logic_friend_list_ui:SetTabID(firstTabID)
      self:SwitchTab(firstTabID)
    end
  end
  local CorpsMemberSystem = require("client.slua.logic.corps.logic_corps_member")
  CorpsMemberSystem.GetCorpsMemberList()
  self:OnRecentReqResponse()
  self:CheckNewStatusGuide()
  self:RefreshMyStatus()
  self:ShowPopUpUI()
  self:JumpToSpecifyPlayer()
  self:SaveOpenTime()
  self:InitInviteTeam()
  local tabID = logic_friend_list_ui:GetTabID()
  if tabID ~= FLMacros.ENUM_TAB.ENUM_TEAM_TAG then
    self:SetWidgetVisible(self.UIRoot.HorizontalBox_SearchFriend, false, true)
    self:SetWidgetVisible(self.UIRoot.Button_SearchFriendLocal, true, true)
    self:SetWidgetVisible(self.UIRoot.HorizontalBox_TopButton, true, true)
  end
end
function Lobby_InviteFriend_BP:InitReturnPlayer()
  local logic_return_team_recommend = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_team_recommend)
  if logic_return_team_recommend:IsShowFriendBarEntry() then
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_Return, true)
    local shareCardInfo = LobbySystem.roleData.share_card_info
    if shareCardInfo and not shareCardInfo.is_share_card_sent and logic_return_team_recommend:CheckShareCardExist() then
      self.UIRoot.TextBlock_Return:SetText(LocUtil.LocalizeResFormat(86258, 0, 1))
    else
      self.UIRoot.TextBlock_Return:SetText(LocUtil.GetLocalizeResStr(86259))
    end
  else
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_Return, false)
  end
end
function Lobby_InviteFriend_BP:InitDeskTopToolBtn()
  log(bWriteLog and "Lobby_InviteFriend_BP:InitDeskTopToolBtn")
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_DeskTopTool, false)
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  local tabID = logic_friend_list_ui:GetTabID()
  if tabID == FLMacros.ENUM_TAB.ENUM_TEAM_TAG then
    log_format("Lobby_InviteFriend_BP:InitDeskTopToolBtn return of tabID == FLMacros.ENUM_TAB.ENUM_TEAM_TAG")
    return
  end
  local logic_return_team_recommend = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_team_recommend)
  if logic_return_team_recommend:IsShowFriendBarEntry() then
    log(bWriteLog and "Lobby_InviteFriend_BP:InitDeskTopToolBtn return of logic_return_team_recommend:IsShowFriendBarEntry")
    return
  end
  local ModuleManager = require("client.module_framework.ModuleManager")
  local logic_friend_spk_fb = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_spk_fb)
  self.sync_fb_friend = logic_friend_spk_fb:NeedShowRefresh()
  if self.sync_fb_friend then
    if self.UIRoot.Image_72 then
      self:SetTexture(self.UIRoot.Image_72, "/Game/UMG/Texture/Atlas/ShareUI/Frames/T_icon_FaceBook_png.T_icon_FaceBook_png")
    end
    self.UIRoot.TextBlock_DeskTopTool:SetText(LocUtil.GetLocalizeResStr(655715))
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_DeskTopTool, true)
    log(bWriteLog and "Lobby_InviteFriend_BP:InitDeskTopToolBtn return of sync_fb_friend")
    return
  end
  local logic_community = require("client.slua.logic.community.logic_community")
  local bNeedShow, nTriggerReason = logic_community.IsNeedShowFriendDeskTopToolEntry()
  if not bNeedShow then
    log(bWriteLog and "teamup_side_bar:InitDeskTopToolBtn return of not logic_community.IsNeedShowFriendDeskTopToolEntry")
    return
  end
  if logic_community.IsClickFriendDeskTopToolGuideEntry() then
    log(bWriteLog and "teamup_side_bar:InitDeskTopToolBtn return of not logic_community.IsClickFriendDeskTopToolGuideEntry")
    return
  end
  self.UIRoot.TextBlock_DeskTopTool:SetText(LocUtil.GetLocalizeResStr(73125))
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_DeskTopTool, true)
  if self.UIRoot.Image_72 then
    self:SetTexture(self.UIRoot.Image_72, "/Game/UMG/Texture_200/Atlas/LobbyUI/Frames/Lobby_Icon_Friendship_Desktop_png.Lobby_Icon_Friendship_Desktop_png")
  end
  self.nDeskTopToolTriggerReason = nTriggerReason or 0
  log(bWriteLog and "Lobby_InviteFriend_BP:InitDeskTopToolBtn Expose nDeskTopToolTriggerReason = " .. tostring(self.nDeskTopToolTriggerReason))
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.Expose_Friend_DeskTopTool_Guide, self.nDeskTopToolTriggerReason)
end
function Lobby_InviteFriend_BP:InitFriendButton()
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  local from = logic_friend_list_ui:GetFrom()
  local LogicTeamUpSideBar = require("client.slua.logic.lobby.logic_teamup_side_bar")
  if LogicTeamUpSideBar.IsInRoom() or from == FLMacros.ENUM_OPEN_FROM.PLANPH then
    self:SetWidgetVisible(self.UIRoot.Button_SearchFriend, false)
  else
    self:SetWidgetVisible(self.UIRoot.Button_SearchFriend, true, true)
  end
end
function Lobby_InviteFriend_BP:InitButtonMenu()
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  local from = logic_friend_list_ui:GetFrom()
  if from == FLMacros.ENUM_OPEN_FROM.PLANPH then
    self:SetWidgetVisible(self.UIRoot.Button_Menu, false)
  else
    self:SetWidgetVisible(self.UIRoot.Button_Menu, true, true)
    local bShowTeamButton = true
    if from == FLMacros.ENUM_OPEN_FROM.TPLAN or from == FLMacros.ENUM_OPEN_FROM.CREATIVEWOW or from == FLMacros.ENUM_OPEN_FROM.ISLAND then
      bShowTeamButton = false
    end
    self:SetWidgetVisible(self.UIRoot.Button_FaceTeam, bShowTeamButton, true)
    local bShowSetDisplayButton = true
    if from ~= FLMacros.ENUM_OPEN_FROM.LOBBY and from ~= FLMacros.ENUM_OPEN_FROM.WOWMod then
      bShowSetDisplayButton = false
    end
    self:SetWidgetVisible(self.UIRoot.Button_SetDisplay, bShowSetDisplayButton, true)
  end
end
function Lobby_InviteFriend_BP:InitFaceTeamButton()
  if not self.UIRoot.InviteTeam then
    return
  end
  local isOpen = LobbySystem.CheckOpen(BP_ENUM_MODULE_FACE_TEAM)
  if isOpen then
    self:SetWidgetVisible(self.UIRoot.InviteTeam, true)
  else
    self:SetWidgetVisible(self.UIRoot.InviteTeam, false)
  end
end
function Lobby_InviteFriend_BP:InitLuckyStarData()
  log(bWriteLog and "[teamup_side_bar] InitLuckyStarData")
  local logic_luckystar = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_luckystar)
  local LogicTeamUpSideBar = require("client.slua.logic.lobby.logic_teamup_side_bar")
  if not logic_luckystar:IsLuckyStarValid() or LogicTeamUpSideBar.IsInRoom() then
    log(bWriteLog and "[teamup_side_bar] lucky star not valid")
    return
  end
  local lucky_star_map = logic_luckystar:GetLuckyStarMap()
  if not lucky_star_map then
    logic_luckystar:GetLuckyStarMapReq()
  end
end
function Lobby_InviteFriend_BP:RefreshLuckyStarBtn()
  log(bWriteLog and "[teamup_side_bar] RefreshLuckyStarBtn")
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  local from = logic_friend_list_ui:GetFrom()
  if from == FLMacros.ENUM_OPEN_FROM.PLANPH then
    self:SetWidgetVisible(self.UIRoot.Button_Lucky, false)
    return
  end
  local tabID = logic_friend_list_ui:GetTabID()
  if tabID == FLMacros.ENUM_TAB.ENUM_TEAM_TAG then
    self:SetWidgetVisible(self.UIRoot.Button_Lucky, false)
    return
  end
  local logic_luckystar = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_luckystar)
  local LogicTeamUpSideBar = require("client.slua.logic.lobby.logic_teamup_side_bar")
  if not logic_luckystar:IsLuckyStarValid() or LogicTeamUpSideBar.IsInRoom() then
    log(bWriteLog and "[teamup_side_bar] lucky star time not valid")
    self:SetWidgetVisible(self.UIRoot.Button_Lucky, false)
    return
  end
  local lucky_star_map = logic_luckystar:GetLuckyStarMap()
  if lucky_star_map then
    self:SetWidgetVisible(self.UIRoot.Button_Lucky, true, true)
  else
    self:SetWidgetVisible(self.UIRoot.Button_Lucky, false)
  end
end
function Lobby_InviteFriend_BP:SetNearsTab()
  local UIUtil = require("client.common.ui_util")
  local LBSFriendMgr = require("client.slua.logic.lbs.logic_lbs_friend")
  if not self.UIRoot.CanvasPanel_LBS then
    return
  end
  self.UIRoot.CanvasPanel_LBS:SetWidgetVisibility(UIUtil.BoolToVisible(LBSFriendMgr:CanOpenNearFriend()))
end
function Lobby_InviteFriend_BP:JumpToSpecifyPlayer()
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  local tabID = logic_friend_list_ui:GetTabID()
  if not (tabID == FLMacros.ENUM_TAB.ENUM_FRIEND_TAG and self.jumpUid) or self.isUserScrolled then
    return
  end
  local playerList = self:GetPlayerListSetData()
  if not playerList or #playerList <= 0 then
    return
  end
  local jumpIndex = -1
  for index, player in ipairs(playerList) do
    if player.uid and player.uid == self.jumpUid and player.online ~= 0 then
      jumpIndex = index
      break
    end
  end
  if jumpIndex <= 0 then
    return
  end
  self:AddTimerOnce(0.3, function()
    self.ReuseFall:ScrollToItem(jumpIndex, true)
  end)
end
function Lobby_InviteFriend_BP:UpdateFriendNumText()
  local logic_new_friend = require("client.slua.logic.friend.logic_new_friend")
  local onlineCount, totalCount = logic_new_friend.GetFriendOnlineCount()
  self.UIRoot.TextBlock_Nomber_friends:SetText(string.format("%s/%s", onlineCount, totalCount))
end
function Lobby_InviteFriend_BP:ShowListBackGround(length)
  if 0 < length then
    self:SetWidgetVisible(self.UIRoot.ChickenTips, false)
    if self.UIRoot.CanvasPanel_Bind then
      self:SetWidgetVisible(self.UIRoot.CanvasPanel_Bind, false)
    end
  else
    local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
    local tabID = logic_friend_list_ui:GetTabID()
    if tabID == FLMacros.ENUM_TAB.ENUM_FRIEND_TAG then
      self:SetWidgetVisible(self.UIRoot.ChickenTips, true, true)
      if self.bEnableLocalSearchFriend then
        self.UIRoot.TextBlock_tips:SetText(LocUtil.GetLocalizeResStr(69995))
      else
        self.UIRoot.TextBlock_tips:SetText(LocUtil.GetLocalizeResStr(8046))
      end
    elseif tabID == FLMacros.ENUM_TAB.ENUM_RECENT_TAG then
      self:SetWidgetVisible(self.UIRoot.ChickenTips, true, true)
      self.UIRoot.TextBlock_tips:SetText(LocUtil.GetLocalizeResStr(8045))
    elseif tabID == FLMacros.ENUM_TAB.ENUM_CORPS_TAG then
      self:SetWidgetVisible(self.UIRoot.ChickenTips, true, true)
      self.UIRoot.TextBlock_tips:SetText(LocUtil.GetLocalizeResStr(8044))
    elseif tabID == FLMacros.ENUM_TAB.ENUM_LBS_NEAR then
      self:SetWidgetVisible(self.UIRoot.ChickenTips, true, true)
      self.UIRoot.TextBlock_tips:SetText(LocUtil.GetLocalizeResStr(8045))
    elseif tabID == FLMacros.ENUM_TAB.ENUM_WOW_TAG then
      self:SetWidgetVisible(self.UIRoot.ChickenTips, true, true)
      self.UIRoot.TextBlock_tips:SetText(LocUtil.GetLocalizeResStr(8045))
    elseif tabID == FLMacros.ENUM_TAB.ENUM_TEAM_TAG then
      self:SetWidgetVisible(self.UIRoot.ChickenTips, false, true)
      self.UIRoot.TextBlock_tips:SetText(LocUtil.GetLocalizeResStr(8045))
    end
  end
end
function Lobby_InviteFriend_BP:ShowFriendApply()
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local nums = LogicFriend.GetAllApplyCntWithProfileCheck()
  self.UIRoot:StopAnimation(self.UIRoot.NewAnimation_bell)
  if 0 < nums then
    self:SetWidgetVisible(self.UIRoot.Button_FriendApplyList, true, true)
    self.UIRoot.Text_Apply_Cnt:SetText(nums)
    self:PlayUserWidgetAnimation(self.UIRoot.NewAnimation_bell, 0, 0, 0, 1)
  else
    self:SetWidgetVisible(self.UIRoot.Button_FriendApplyList, false)
  end
  self:ShowFriendRedDot()
end
function Lobby_InviteFriend_BP:UpdatePlayerNew(UID)
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  log(bWriteLog and "teamup_side_bar:UpdatePlayerNew " .. tostring(UID))
  local List = logic_friend_list_ui:GetFriendList()
  if not List then
    return
  end
  for index, player in pairs(List) do
    if type(player) == "table" and next(player) and player.uid and tonumber(player.uid) == tonumber(UID) then
      if self.List:GetItemData(index) then
        self.List:RefreshItem(index, player)
      end
      return
    end
  end
end
function Lobby_InviteFriend_BP:ShowFriendRedDot()
  local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
  if PersonSpaceSystem.HasIntimacyReddot(PersonSpaceReddotType.REDOT_NEW_INTIMACY_RELATION_AVAILABLE) or PersonSpaceSystem.HasIntimacyReddot(PersonSpaceReddotType.REDOT_NEW_INTIMACY_PARTNER_AVAILABLE) then
    self:SetWidgetVisible(self.UIRoot.Image_Reddot_Intimacy, true, true)
  else
    self:SetWidgetVisible(self.UIRoot.Image_Reddot_Intimacy, false)
  end
end
function Lobby_InviteFriend_BP:RefreshMyStatus()
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  local from = logic_friend_list_ui:GetFrom()
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local logic_friend_list = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list)
  if logic_friend_list.res_set_status_data and logic_friend_list.res_set_status_data.switch == 1 then
    if from == FLMacros.ENUM_OPEN_FROM.PLANPH then
      self:SetWidgetVisible(self.UIRoot.Button_NewState, false)
      self:SetWidgetVisible(self.UIRoot.Button_State_Home, true, true)
    else
      self:SetWidgetVisible(self.UIRoot.Button_State_Home, false)
      self:SetWidgetVisible(self.UIRoot.Button_NewState, true, true)
    end
  else
    self:SetWidgetVisible(self.UIRoot.Button_State_Home, false)
    self:SetWidgetVisible(self.UIRoot.Button_NewState, false)
  end
  local widget_Image_OnlineState = self.UIRoot.Image_95
  if from == FLMacros.ENUM_OPEN_FROM.PLANPH then
    widget_Image_OnlineState = self.UIRoot.Image_OnlineState_Home
  end
  if not LobbySystem.CheckOpen(BP_ENUM_NEW_FRIEND_STATUS_SWITCH) then
    local PlayerStatusUtil = require("client.slua.logic.player_status.PlayerStatusUtil")
    log(bWriteLog and "Lobby_InviteFriend_BP:RefreshMyStatus, status.teamState = " .. tostring(LogicFriend.teamState))
    if PlayerStatusUtil.IsIdle(LogicFriend) then
      self:SetTexture(widget_Image_OnlineState, "/Game/UMG/Texture/Atlas/LobbyUI/Frames/LOBBY_btn_Idle_png.LOBBY_btn_Idle_png")
    elseif PlayerStatusUtil.IsFree(LogicFriend) then
      self:SetTexture(widget_Image_OnlineState, "/Game/UMG/Texture/Atlas/LobbyUI/Frames/LOBBY_btn_Appointment_png.LOBBY_btn_Appointment_png")
    elseif PlayerStatusUtil.IsBusy(LogicFriend) then
      self:SetTexture(widget_Image_OnlineState, "/Game/UMG/Texture/Atlas/LobbyUI/Frames/LOBBY_btn_Busy_png.LOBBY_btn_Busy_png")
    elseif PlayerStatusUtil.IsStealth(LogicFriend) then
      self:SetTexture(widget_Image_OnlineState, "/Game/UMG/Texture/Atlas/LobbyUI/Frames/LOBBY_btn_Hide_png.LOBBY_btn_Hide_png")
    elseif PlayerStatusUtil.IsDoNotBother(LogicFriend) then
      self:SetTexture(widget_Image_OnlineState, "/Game/UMG/Texture/Atlas/LobbyUI/Frames/LOBBY_btn_Busy_png.LOBBY_btn_Busy_png")
    end
  else
    self:SetTexture(widget_Image_OnlineState, "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_AddFriends_3_png.Common_Icon_AddFriends_3_png")
    local FriendHandler = require("client.network.Protocol.FriendHandler")
    log_tree("FriendHandler.friend_status_data ", FriendHandler.friend_status_data)
    if FriendHandler.friend_status_data then
      local endTime = FriendHandler.friend_status_data.status_endtime or 0
      local TimeUtil = require("client.common.time_util")
      if endTime >= TimeUtil.GetServerTimeInSec() then
        local SelfStatusID = FriendHandler.friend_status_data.sub_status_id or 0
        local cfg = CDataTable.GetTableData("FriendStatusCfg", SelfStatusID)
        if cfg and SelfStatusID ~= 13 then
          self:SetTexture(widget_Image_OnlineState, cfg.icon_url)
        elseif SelfStatusID == 13 and FriendHandler.friend_status_data.icon_idx then
          local path = "/Game/UMG/Texture/Atlas/ChatEmojiUI/Frames/emoji_1_50_" .. tostring(FriendHandler.friend_status_data.icon_idx) .. "_png.emoji_1_50_" .. tostring(FriendHandler.friend_status_data.icon_idx) .. "_png"
          self:SetTexture(widget_Image_OnlineState, path)
        end
        local likedMap = FriendHandler.friend_status_data.liked_list or {}
        local likedList = {}
        for uid, timestamp in pairs(likedMap) do
          table.insert(likedList, {uid = uid, timestamp = timestamp})
        end
        table.sort(likedList, function(a, b)
          return a.timestamp > b.timestamp
        end)
        local latestTimeStamp = 0 < #likedList and likedList[1].timestamp or 0
        local newbieValue = DataMgr.GetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_NEW_FRIENDSTATUS, 2)
        if latestTimeStamp ~= 0 and (not newbieValue or latestTimeStamp > newbieValue) then
          self:SetWidgetVisible(self.UIRoot.image_Reddot_status, true, true)
        end
      end
    end
  end
end
function Lobby_InviteFriend_BP:InitInviteTeam()
  self:SetWidgetVisible(self.UIRoot.InviteTeam, false)
  self:SetWidgetVisible(self.UIRoot.Button_InviteTeam, true, true)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local path, tintColor = LogicFriend.GetLoginChannelIcon()
  self:SetTexture(self.UIRoot.Image_Invite, path)
  self.UIRoot.Image_Invite.Brush.TintColor = tintColor
end
function Lobby_InviteFriend_BP:InitTabList()
  log(bWriteLog and "Lobby_InviteFriend_BP:InitTabList")
  local FLMacros = require("client.slua.logic.friend.refactor.friend_list_macros")
  local TabPicMap = {
    [FLMacros.ENUM_TAB.ENUM_FRIEND_TAG] = FLMacros.C_FriendTabPic.Friend,
    [FLMacros.ENUM_TAB.ENUM_RECENT_TAG] = FLMacros.C_FriendTabPic.Recent,
    [FLMacros.ENUM_TAB.ENUM_CORPS_TAG] = FLMacros.C_FriendTabPic.Corps,
    [FLMacros.ENUM_TAB.ENUM_LBS_NEAR] = FLMacros.C_FriendTabPic.Near,
    [FLMacros.ENUM_TAB.ENUM_WOW_TAG] = FLMacros.C_FriendTabPic.Wow,
    [FLMacros.ENUM_TAB.ENUM_TEAM_TAG] = FLMacros.C_FriendTabPic.Team
  }
  local DefaultTabs = {}
  local LBSFriendMgr = require("client.slua.logic.lbs.logic_lbs_friend")
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  for _, TabID in ipairs({
    FLMacros.ENUM_TAB.ENUM_FRIEND_TAG,
    FLMacros.ENUM_TAB.ENUM_RECENT_TAG,
    FLMacros.ENUM_TAB.ENUM_CORPS_TAG,
    FLMacros.ENUM_TAB.ENUM_LBS_NEAR,
    FLMacros.ENUM_TAB.ENUM_WOW_TAG,
    FLMacros.ENUM_TAB.ENUM_TEAM_TAG
  }) do
    local shouldAdd = true
    if TabID == FLMacros.ENUM_TAB.ENUM_LBS_NEAR then
      shouldAdd = LBSFriendMgr:CanOpenNearFriend()
    end
    if TabID == FLMacros.ENUM_TAB.ENUM_WOW_TAG then
      shouldAdd = self.modInfo ~= nil
    end
    if TabID == FLMacros.ENUM_TAB.ENUM_TEAM_TAG then
      local logic_teamquick_entry = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_teamquick_entry)
      shouldAdd = logic_teamquick_entry:CheckCanShow()
    end
    local from = logic_friend_list_ui:GetFrom()
    if TabID == FLMacros.ENUM_TAB.ENUM_TEAM_TAG and from ~= FLMacros.ENUM_OPEN_FROM.LOBBY and from ~= FLMacros.ENUM_OPEN_FROM.WOWMod and from ~= FLMacros.ENUM_OPEN_FROM.WOWNewHall then
      shouldAdd = false
    end
    if shouldAdd then
      table.insert(DefaultTabs, {
        TabID = TabID,
        SelectedIconPath = TabPicMap[TabID].Selected,
        UnSelectIconPath = TabPicMap[TabID].UnSelect
      })
    end
  end
  self.TabList:SetData(DefaultTabs)
  self.CurrentTabList = DefaultTabs
end
function Lobby_InviteFriend_BP:GetTabIndexByTabID(tabID)
  if not self.CurrentTabList or #self.CurrentTabList == 0 then
    log(bWriteLog and string.format("GetTabIndexByTabID: CurrentTabList is empty, return nil"))
    return nil
  end
  for index, tabData in ipairs(self.CurrentTabList) do
    if tabData.TabID == tabID then
      return index
    end
  end
  log(bWriteLog and string.format("GetTabIndexByTabID: tabID %s not found in CurrentTabList, return nil", tostring(tabID)))
  return nil
end
function Lobby_InviteFriend_BP:OnGPSLBSInfoChenged(_, _, msgType)
  log(bWriteLog and "Lobby_InviteFriend_BP:OnGPSLBSInfoChenged msgType" .. tostring(msgType))
  local logic_lbs_warzone = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lbs_warzone)
  logic_lbs_warzone:ShowMsgBoxMgr(msgType)
end