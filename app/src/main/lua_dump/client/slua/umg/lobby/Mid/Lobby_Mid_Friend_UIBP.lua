local Lobby_Mid_Friend_UIBP = {}
local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
local ENUM_FRIEND_TIPS_TYPE = {
  NONE = 1,
  NEW_INTIMACY = 2,
  NEW_PARTNER = 3,
  NEW_BANNED = 4
}
function Lobby_Mid_Friend_UIBP:ctor()
end
function Lobby_Mid_Friend_UIBP:OnInitialize()
  Lobby_Mid_Friend_UIBP.__super.OnInitialize(self)
  self.util = require("client.slua_ui_framework.util")
  self.FriendTipsGuideFlow = nil
  self.IntimacyList = {}
  self.ScrollBox = self:InitScrollBox(self.UIRoot.LoopScrollBox_0)
end
function Lobby_Mid_Friend_UIBP:RegistEvents()
  Lobby_Mid_Friend_UIBP.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_PROFILE, EVENTID_PROFILE_MSG, self.OnFriendChange, self)
  self:AddCommonEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_PROFILE_CHANGE, self.OnFriendChange, self)
  self:AddCommonEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_ADD_DELETE_FRIEND, self.OnFriendAddOrDelete, self)
  self:AddCommonEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_DELETE_BATCH_FRIEND, self.OnFriendAddOrDelete, self)
  self:AddCommonEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_ONLINE_STATE_CHANGE, self.OnFriendChange, self)
  self:AddCommonEvent(EVENTTYPE_FRIEND, EVENTID_BATCH_GET_PLAYERSTATUS, self.OnFriendChange, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENT_PROFILE_RESPONSE, self.OnFriendChange, self)
  self:AddCommonEvent(EVENTTYPE_PROFILE, EVENTID_PROFILE_LIST_UPDATE, self.OnProfileUpdate, self)
  self:AddCommonEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_APPLYLIST_CHANGE, self.ShowFriendApply, self)
  self:AddCommonEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_INTIMACYAPPLY_CHANGE, self.ShowFriendApply, self)
  self:AddCommonEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_INTIMACY_CHANGE, self.ShowFriendApply, self)
  self:AddCommonEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_REDDOT_UPDATE, self.ShowFriendApply, self)
  self:AddCommonEvent(EVENTTYPE_PLANPH_LOBBY, EVETNID_PLANPH_JOINT_INFO_UPDATE, self.ShowFriendApply, self)
  self:AddCommonEvent(EVENTTYPE_FLASH_TEAM, EVENTID_FLASH_TEAM_APPLY_LIST_CHANGE, self.ShowFriendApply, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_ON_FACESLAP_END, self.OnFaceSlapEnd, self)
  self:AddCommonEvent(EVENTTYPE_FRIEND, EVENTID_UPDATE_RECENT_STATUS, self.UpdateFriend, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENT_RECOMMEND_GENERATED, self.OnFriendChange, self)
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_MATCH_MODE_MAINUI_CLOSE, self.OnMatchModeMainUIClose, self)
  self:AddCommonEvent(EVENTTYPE_T_XMISSION, EVENTID_XMISSION_MATCH_MODE_CONFIRM, self.OnXMatchModeConfirm, self)
  self:AddCommonEvent(EVENTTYPE_FLASH_TEAM, EVENTID_FLASH_TEAM_ENTRY_UPDATE, self.UpdateTeamQuick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_OnlinePlayers2, self.OnButton_OnlinePlayersClick, self)
  self.ScrollBox:SetRefreshItemCallback(self.OnRefreshItem, self)
  self.ScrollBox:AddItemWidgetChildEvent("Button_Del", "OnClicked", self.OnButton_OnlinePlayersClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_TeamQuick, self.OnButton_TeamQuick, self)
  self:AddCommonEvent(EVENTTYPE_FLASH_TEAM, EVENTID_TOTAL_FLASH_TEAM_CHG, self.RefreshFlashTeamShow, self)
  self:AddControlEventByControl(self.UIRoot.Fadein, "OnAnimationFinished", self.StartTeamQuickEffect, self)
  self:AddControlEventByControl(self.UIRoot.Anim_Prompt, "OnAnimationFinished", self.EndTeamQuickEffect, self)
end
function Lobby_Mid_Friend_UIBP:OnPostInitialize()
  Lobby_Mid_Friend_UIBP.__super.OnPostInitialize(self)
  self.curTipsStatus = ENUM_FRIEND_TIPS_TYPE.NONE
  self:RegistReddotWidget(self.UIRoot.CanvasPanel_FriendReddot)
  self:UpdateUI()
  self:UpdateOnlineNum()
  self:UpdateFriend()
  self:UpdateTeamQuick()
  self:ShowRapportChangeEffect()
  local OpenUIAction = require("client.slua.logic.GuideFlow.Action.OpenUIAction")
  OpenUIAction.HandleHoldingAction()
  local logic_friend_reserve = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_friend_reserve)
  logic_friend_reserve:InquiryHistoryReserveInfoReq()
  local PHomeJointHandler = require("client.network.Protocol.PHomeJointHandler")
  PHomeJointHandler.send_manor_joint_info_req()
  local PHomeAuditHandler = require("client.network.Protocol.PHomeAuditHandler")
  PHomeAuditHandler.send_manor_scene_draft_state_req()
end
function Lobby_Mid_Friend_UIBP:UpdateUI()
  self:ShowFriendApply()
  self:InitEntryTips()
end
function Lobby_Mid_Friend_UIBP:OnProfileUpdate()
  self:OnFriendChange()
  self:ShowFriendApply()
end
function Lobby_Mid_Friend_UIBP:OnFriendChange()
  if self.friendChangeTimer then
    return
  end
  self.friendChangeTimer = self:AddTimer(0.25, function()
    self:_implOnFriendChange()
  end)
end
function Lobby_Mid_Friend_UIBP:_implOnFriendChange()
  if not self or not self.UIRoot then
    return
  end
  self:UpdateOnlineNum()
  self:UpdateFriend()
  local LogicSettingBasic = require("client.slua.logic.setting.logic_setting_basic")
  local IsShowHint = LogicSettingBasic.GetOneSettingValue("DoubleIntimacyHint")
  if IsShowHint then
    self:ShowIntimateBanned()
  end
  self.friendChangeTimer = nil
end
function Lobby_Mid_Friend_UIBP:OnMatchModeMainUIClose()
  log(bWriteLog and "[v_zhaopwei] Lobby_Mid_Friend_UIBP:OnMatchModeMainUIClose start")
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  if not logic_mode_selection.IsFromLobby() then
    return
  end
  if UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP) then
    local Lobby_Main_Control = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
    local page = Lobby_Main_Control.curPage
    if page ~= ENUM_LobbyPageType.Mid then
      return
    end
  end
  local lastTimeTeamNum = logic_mode_selection:GetLastTimeTeamNum()
  if not lastTimeTeamNum then
    return
  end
  if lastTimeTeamNum == self.lastTimeTeamNum then
    log(bWriteLog and "Lobby_Mid_Friend_UIBP:OnMatchModeMainUIClose lastTimeTeamNum = " .. tostring(lastTimeTeamNum) .. " self.lastTimeTeamNum = " .. tostring(self.lastTimeTeamNum))
    return
  end
  self.  local filterInfo = logic_mode_selection:GetFilterInfo()
  local curTeamNum = filterInfo.teamNum
  if lastTimeTeamNum >= curTeamNum then
    log(bWriteLog and "Lobby_Mid_Friend_UIBP:OnMatchModeMainUIClose lastTimeTeamNum = " .. tostring(lastTimeTeamNum) .. " curTeamNum = " .. tostring(curTeamNum))
    return
  end
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  if not LogicFriend.IsAtLeastOneOnlineAndFree() then
    log(bWriteLog and "Lobby_Mid_Friend_UIBP:OnMatchModeMainUIClose LogicFriend.IsAtLeastOneOnlineAndFree return")
    return
  end
  local logic_ugc_mode = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_mode)
  if logic_ugc_mode:IsSelectUgcMode() then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local lastOpenTimeTable = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eWOWModeLastOpenTeamupSidebarTime) or {}
    local TimeUtil = require("client.common.time_util")
    local currentTime = TimeUtil.GetServerTimeInSec()
    log(bWriteLog and "[v_zhaopwei]teamup_side_bar:GetLastOpenTimeIsTodayByWOWMode  lastOpenTimeTable.time" .. tostring(lastOpenTimeTable.time or 0) .. ", currentTime:" .. tostring(currentTime))
    if lastOpenTimeTable.time and TimeUtil.IsSameDay(lastOpenTimeTable.time, currentTime) then
      return
    end
    lastOpenTimeTable.time = currentTime
    PlayerPrefsSystem.SaveTableToFile_N(lastOpenTimeTable, PlayerPrefsSystem.ePlayerPrefsType.eWOWModeLastOpenTeamupSidebarTime)
  end
  local playerContentText = {
    [1] = 993048,
    [2] = 993049,
    [4] = 993050,
    [8] = 993098
  }
  local playerNumText = LocUtil.LocalizeResFormat(playerContentText[curTeamNum])
  local perspectText = LocUtil.LocalizeResFormat(filterInfo.perspective)
  ShowNotice(LocUtil.LocalizeResFormat(38784, perspectText, playerNumText))
  log(bWriteLog and "Lobby_Mid_Friend_UIBP:OnMatchModeMainUIClose lastTimeTeamNum = " .. tostring(lastTimeTeamNum) .. " curTeamNum = " .. tostring(curTeamNum))
  self:AddTimerOnce(0.5, function()
    local LogicTeamUpSideBar = require("client.slua.logic.lobby.logic_teamup_side_bar")
    LogicTeamUpSideBar.ShowTeamUpSideBar(LogicTeamUpSideBar.ENUM_OPEN_FROM.ISMOREPLAYERNUM)
  end)
end
function Lobby_Mid_Friend_UIBP:OnXMatchModeConfirm()
  local LogicTxMissionMatch = require("client.slua.logic.TxMission.match.logic_xmission_match")
  local oldTeamNum = LogicTxMissionMatch.GetMatchTeam(true)
  local curTeamNum = LogicTxMissionMatch.GetMatchTeam()
  log(bWriteLog and "Lobby_Mid_Friend_UIBP:OnXMatchModeConfirm oldTeamNum = " .. tostring(oldTeamNum) .. " curTeamNum = " .. tostring(curTeamNum))
  if oldTeamNum >= curTeamNum then
    return
  end
  self:AddTimerOnce(0.5, function()
    local LogicTeamUpSideBar = require("client.slua.logic.lobby.logic_teamup_side_bar")
    LogicTeamUpSideBar.ShowTeamUpSideBar(LogicTeamUpSideBar.ENUM_OPEN_FROM.TPLANISMOREPLAYERNUM)
    local noticeSystem = require("client.slua.logic.common.logic_notice_mgr")
    noticeSystem.RemoveAllNotice()
    ShowNotice(38812)
  end)
end
function Lobby_Mid_Friend_UIBP:OnFriendAddOrDelete(_, _, _, isAddFriend)
  log(bWriteLog and "Lobby_Mid_Friend_UIBP:OnFriendAddOrDelete isAddFriend: " .. tostring(isAddFriend))
  local LogicTeamUpSideBar = require("client.slua.logic.lobby.logic_teamup_side_bar")
  if LogicTeamUpSideBar.EnableRecommend and isAddFriend then
    LogicTeamUpSideBar.Recommend(false)
  else
    self:OnFriendChange()
  end
  log(bWriteLog and "[DeanJYT] Lobby_Mid_Friend_UIBP:OnFriendAddOrDelete get latest manor joint info for friend change")
  local PHomeJointHandler = require("client.network.Protocol.PHomeJointHandler")
  PHomeJointHandler.send_manor_joint_info_req()
end
function Lobby_Mid_Friend_UIBP:UpdateOnlineNum(numRecommend)
  log(bWriteLog and "Lobby_Mid_Friend_UIBP:UpdateOnlineNum")
  local LogicTeamUpSideBar = require("client.slua.logic.lobby.logic_teamup_side_bar")
  local AllData = LogicTeamUpSideBar.GetFriends() or {}
  local totalCount = #AllData
  local onlineCount = 0
  for k, v in pairs(AllData) do
    if v.online == 1 then
      onlineCount = onlineCount + 1
    end
  end
  if numRecommend then
    onlineCount = onlineCount + numRecommend
    totalCount = totalCount + numRecommend
  end
  self.UIRoot.TextBlock_0:SetText(LocUtil.LocalizeResFormat(6830, onlineCount, totalCount))
end
function Lobby_Mid_Friend_UIBP:UpdateFriend()
  local LogicTeamUpSideBar = require("client.slua.logic.lobby.logic_teamup_side_bar")
  local recommend = 0
  if LogicTeamUpSideBar.EnableRecommend and LogicTeamUpSideBar.HasRecommend() then
    recommend = LogicTeamUpSideBar.GetRecommendNum()
    self:UpdateOnlineNum(recommend)
  end
  log(bWriteLog and "[v_ywuyuan] Lobby_Mid_Friend_UIBP:UpdateFriend")
  self:UpdateFriendList()
end
function Lobby_Mid_Friend_UIBP:UpdateFriendList()
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local logic_friend = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend)
  local LogicTeamUpSideBar = require("client.slua.logic.lobby.logic_teamup_side_bar")
  local list = {}
  if LogicTeamUpSideBar.EnableRecommend and LogicTeamUpSideBar.HasRecommend() then
    list = LogicTeamUpSideBar.GetFriendsWithRecommend()
  else
    list = LogicTeamUpSideBar.GetFriends()
  end
  local dtlist = {}
  for i, v in ipairs(list) do
    dtlist[i] = v.uid
  end
  if #dtlist < 4 then
    for i = #dtlist + 1, 4 do
      dtlist[i] = 0
    end
  end
  log(bWriteLog and "Lobby_Mid_Friend_UIBP:UpdateFriendList #dtlist = " .. #dtlist)
  self.ScrollBox:SetData(dtlist)
end
function Lobby_Mid_Friend_UIBP:OnRefreshItem(widget, index)
  local uid = self.ScrollBox:GetItemData(index)
  log(bWriteLog and "Lobby_Mid_Friend_UIBP:OnRefreshItem uid = " .. uid)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(uid)
  if not profile then
    widget.WidgetSwitcher_0:SetActiveWidgetIndex(0)
  else
    widget.WidgetSwitcher_0:SetActiveWidgetIndex(1)
    local sex = tonumber(profile.sex) or 0
    local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
    local status = PlayerStatusMgr:GetStatusData(uid)
    local online = 0
    if status then
      online = status.online
    end
    widget.Common_Avatar_BP_C_0:InitView(2, uid, profile.picUrl, sex + 1, profile.cur_avatar_box_id, profile.level, false, "", online == 1)
    widget.Common_Avatar_BP_C_0:SetButtonEnabled(false)
    if online == 1 then
      widget.Common_Avatar_BP_C_0:SetColorAndOpacity(FLinearColor(1, 1, 1, 1))
    else
      widget.Common_Avatar_BP_C_0:SetColorAndOpacity(FLinearColor(1, 1, 1, 0.6))
    end
  end
end
function Lobby_Mid_Friend_UIBP:OnButton_OnlinePlayersClick()
  log(bWriteLog and "Lobby_Mid_Friend_UIBP:OnButton_OnlinePlayersClick")
  self:PlayAudio(sound_config.new_socialBtn)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.LobbyFriend)
  local LogicTeamUpSideBar = require("client.slua.logic.lobby.logic_teamup_side_bar")
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  local ugcMatchInfo = LogicUGCMatch:GetUgcMatchModInfo()
  local FLMacros = require("client.slua.logic.friend.refactor.friend_list_macros")
  if ugcMatchInfo then
    LogicTeamUpSideBar.ShowWOWFriend(ugcMatchInfo)
  else
    LogicTeamUpSideBar.ShowTeamUpSideBar(LogicTeamUpSideBar.ENUM_OPEN_FROM.LOBBY, FLMacros.ENUM_TAB.ENUM_FRIEND_TAG)
  end
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:IsRestrictGift() then
    log(bWriteLog and "[v_zhwvzhang] Lobby_Mid_Friend_UIBP:OnButton_OnlinePlayersClick return of QRcodeRestrictManager:IsRestrictGift()")
    return
  else
    local logic_send_gift = require("client.slua.logic.gift.logic_send_gift")
    logic_send_gift:send_query_quick_gift_friends_req()
  end
  self:CloseFriendTipsGuideFlow()
end
function Lobby_Mid_Friend_UIBP:ShowVerticalButtonList()
  self.UIRoot.VerticalBox_ButtonList:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
end
function Lobby_Mid_Friend_UIBP:HideVerticalButtonList()
  self.UIRoot.VerticalBox_ButtonList:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function Lobby_Mid_Friend_UIBP:OnFaceSlapEnd()
  self:ShowFriendBanned()
end
function Lobby_Mid_Friend_UIBP:ShowFriendBanned()
  if self.curTipsStatus ~= ENUM_FRIEND_TIPS_TYPE.NONE or self.FriendTipsGuideFlow then
    log(bWriteLog and "[DeanJYT] Lobby_Mid_Friend_UIBP:ShowFriendBanned - other tips showing")
    return
  end
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local lastShowTime = tonumber(LobbySystem.roleData.friend_banned_tips_time)
  local bShouldShow = LogicFriend.bShouldShowFriendBanned
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  log(bWriteLog and "[DeanJYT] Lobby_Mid_Friend_UIBP:ShowFriendBanned, bShouldShow = " .. tostring(bShouldShow) .. ", lastShowTime = " .. tostring(lastShowTime) .. ", curTime = " .. tostring(curTime))
  if not (bShouldShow and lastShowTime) or lastShowTime > curTime then
    return
  end
  self:SetWidgetVisible(self.UIRoot.Lobby_Mid_Tips_Friend_UIBP_C_0, true)
  self.UIRoot.Lobby_Mid_Tips_Friend_UIBP_C_0.Text_Friend_Tips:SetText(LocUtil.LocalizeResFormat(800008))
  self.curTipsStatus = ENUM_FRIEND_TIPS_TYPE.NEW_BANNED
  self:AddTimerOnce(8, function()
    log(bWriteLog and "[DeanJYT] Lobby_Mid_Friend_UIBP:ShowFriendBanned done")
    self:SetWidgetVisible(self.UIRoot.Lobby_Mid_Tips_Friend_UIBP_C_0, false)
    self.curTipsStatus = ENUM_FRIEND_TIPS_TYPE.NONE
    local FriendHandler = require("client.network.Protocol.FriendHandler")
    FriendHandler.send_set_friend_banned_tips_time()
    self:ShowFriendApply()
  end)
  LogicFriend.bShouldShowFriendBanned = false
end
function Lobby_Mid_Friend_UIBP:ShowIntimateBanned()
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local UIUtil = require("client.common.ui_util")
  local ChangeInitList = {}
  local list = LogicFriend.GetIntimacyHasBuildList()
  if list == nil or #list == 0 then
    return
  end
  if self.IntimacyList and next(self.IntimacyList) then
    local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    for k, data in pairs(list) do
      local profile = logic_profile:GetLocalProfile(data.uid)
      local status = PlayerStatusMgr:GetStatusData(data.uid)
      if not status then
        self.IntimacyList[data.uid] = 0
      elseif status.online == 1 then
        if self.IntimacyList[data.uid] == 0 then
          self.IntimacyList[data.uid] = 1
          if profile then
            local a = {
              param = data.param,
              lastLoginTime = profile.lastLoginTime
            }
            table.insert(ChangeInitList, a)
          end
        end
      else
        self.IntimacyList[data.uid] = 0
      end
    end
    if ChangeInitList and 1 < #ChangeInitList then
      table.sort(ChangeInitList, function(a, b)
        if a.lastLoginTime < b.lastLoginTime then
          return true
        end
      end)
    end
    if ChangeInitList and ChangeInitList[1] then
      local relationName = UIUtil.GetIntimacyRelationName(ChangeInitList[1].param)
      self:SetWidgetVisible(self.UIRoot.Lobby_Mid_Tips_Friend_UIBP_C_0, true)
      self.UIRoot.Lobby_Mid_Tips_Friend_UIBP_C_0.Text_Friend_Tips:SetText(LocUtil.LocalizeResFormat(43934, relationName))
    end
    self:AddTimerOnce(5, function()
      self:SetWidgetVisible(self.UIRoot.Lobby_Mid_Tips_Friend_UIBP_C_0, false)
    end)
  else
    local PlayerStatusMgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PlayerStatusMgr)
    for k, data in pairs(list) do
      local status = PlayerStatusMgr:GetStatusData(data.uid)
      local online = 0
      if status then
        online = status.online
      end
      self.IntimacyList[data.uid] = online
    end
  end
end
function Lobby_Mid_Friend_UIBP:ShowFriendApply()
  log(bWriteLog and "[DeanJYT] Lobby_Mid_Friend_UIBP:ShowFriendApply")
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local nums = LogicFriend.GetAllApplyCntWithProfileCheck()
  self.UIRoot:StopAnimation(self.UIRoot.Friend_Remind)
  local FriendRedPointData = require("client.slua.logic.friend.RedPoint.Friend_redpoint_data")
  if 0 < nums then
    FriendRedPointData.AddRedPointData(1)
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_17, true)
    self.UIRoot.TextBlock_1:SetText(nums)
    if self:CheckCanShowReddot(1) then
      self:ToggleReddotActivation(self.UIRoot.CanvasPanel_FriendReddot, true)
      self:PlayUserWidgetAnimation(self.UIRoot.Friend_Remind, 0, 0, 0, 1)
    end
  else
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_17, false)
    self:ToggleReddotActivation(self.UIRoot.CanvasPanel_FriendReddot, false)
    FriendRedPointData.RemoveRedPointData(1)
  end
  local bIsShowingBan = self.curTipsStatus == ENUM_FRIEND_TIPS_TYPE.NEW_BANNED
  if not bIsShowingBan then
    self:SetWidgetVisible(self.UIRoot.Lobby_Mid_Tips_Friend_UIBP_C_0, false)
    self.curTipsStatus = ENUM_FRIEND_TIPS_TYPE.NONE
  end
  local bReddot = false
  if not bReddot then
    FriendRedPointData.RemoveRedPointData(2)
  end
end
function Lobby_Mid_Friend_UIBP:ShowFriendTipsGuideFlow(isNormal)
  if self.UIRoot.Lobby_Mid_Tips_Friend_UIBP_C_0:GetVisibility() == UEnums.ESlateVisibility.SelfHitTestInvisible then
    return
  end
  if not self.FriendTipsGuideFlow then
    local OpenUIAction = require("client.slua.logic.GuideFlow.Action.OpenUIAction")
    if isNormal then
      OpenUIAction.ShowingType = 1
      self.FriendTipsGuideFlow = self:CreateChildWindow(self.UIRoot.CanvasPanel_1, UIManager.UI_Config.Common_Normal_Tips_UIBP, 1, false)
    else
      OpenUIAction.ShowingType = 2
      self.FriendTipsGuideFlow = self:CreateChildWindow(self.UIRoot.CanvasPanel_1, UIManager.UI_Config.Common_Special_Tips_UIBP, 1, false)
    end
  end
end
function Lobby_Mid_Friend_UIBP:CloseFriendTipsGuideFlow()
  if self.FriendTipsGuideFlow then
    self.FriendTipsGuideFlow:Close()
    self.FriendTipsGuideFlow = nil
  end
end
function Lobby_Mid_Friend_UIBP:CheckCanShowReddot(instance)
  local FriendRedPointData = require("client.slua.logic.friend.RedPoint.Friend_redpoint_data")
  local data = FriendRedPointData.GetRedPointSuperData()
  if data and data.pages[instance].realCount and data.pages[instance].realCount > 0 then
    return true
  end
  return false
end
function Lobby_Mid_Friend_UIBP:RefreshFlashTeamShow()
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  local TeamInfo = logic_flash_match_team:getOwnFlashTeamInfo()
  if not TeamInfo or not TeamInfo.squad_count then
    self.UIRoot.Text_Value:SetText("0")
    return
  end
  self.UIRoot.Text_Value:SetText(TeamInfo.squad_count)
end
function Lobby_Mid_Friend_UIBP:OnButton_TeamQuick()
  self:PlayAudio(sound_config.click_v1)
  log(bWriteLog and "Lobby_Mid_Friend_UIBP:OnButton_TeamQuick")
  local FLMacros = require("client.slua.logic.friend.refactor.friend_list_macros")
  UIManager.ShowUI(UIManager.UI_Config.Lobby_InviteFriend_BP, FLMacros.ENUM_OPEN_FROM.LOBBY, FLMacros.ENUM_TAB.ENUM_TEAM_TAG)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.QuickTeamList, 0)
end
function Lobby_Mid_Friend_UIBP:InitEntryTips()
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_TeamQuick, true)
  local UIComponentModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.UIComponentModule)
  self.Lobby_Mid_Squad_Tips_UIBP = UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.Lobby_Mid_Squad_Tips_UIBP, self.UIRoot.Lobby_Mid_Squad_Tips_UIBP)
  self.Lobby_Mid_Squad_Tips_UIBP:UpdateUI()
  local FlashTeamHandler = require("client.network.Protocol.FlashTeamHandler")
  self:RefreshFlashTeamShow()
end
function Lobby_Mid_Friend_UIBP:ShowRapportChangeEffect()
  local logic_flash_match_team = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_flash_match_team)
  local change_data = logic_flash_match_team:GetRapportChangeData()
  if not change_data then
    self:SetWidgetVisible(self.UIRoot.WidgetSwitcher_TeamQuick, false)
    return
  end
  log_tree("Lobby_Mid_Friend_UIBP:ShowRapportChangeEffect change_data:", change_data)
  local showList = {}
  for k, v in pairs(change_data.flash_squad_rapport_changes) do
    if v and v.delta > 0 then
      local teamInfo = logic_flash_match_team:GetFlashTeamSummaryById(v.squad_id)
      log_tree("Lobby_Mid_Friend_UIBP:ShowRapportChangeEffect teamInfo:", teamInfo)
      if teamInfo then
        local tipText = LocUtil.LocalizeResFormat(18010394, teamInfo.name, v.delta)
        table.insert(showList, tipText)
      end
    end
  end
  local checkShow = function()
    local isAndroidStackEmpty, failUIKey = UIManager.IsAndroidStackEmpty()
    log(bWriteLog and "Lobby_Mid_Friend_UIBP:ShowRapportChangeEffect checkShow isAndroidStackEmpty = " .. tostring(isAndroidStackEmpty) .. ", failUIKey = " .. tostring(failUIKey))
    return isAndroidStackEmpty
  end
  if self.rapportChangeEffectTimer then
    self:RemoveTimer(self.rapportChangeEffectTimer)
    self.rapportChangeEffectTimer = nil
  end
  self.rapportChangeEffectTimer = self:AddTimerLoop(0.5, function()
    if not self.UIRoot or not self.UIRoot.Fadein then
      return
    end
    if not checkShow() then
      return
    end
    logic_flash_match_team:ClearRapportChangeData()
    for index, value in ipairs(showList) do
      ShowNotice(value)
    end
    self:SetWidgetVisible(self.UIRoot.WidgetSwitcher_TeamQuick, true)
    self.UIRoot.WidgetSwitcher_TeamQuick:SetActiveWidgetIndex(change_data.is_level_up and 1 or 0)
    self:PlayUserWidgetAnimation(self.UIRoot.Fadein, 0, 1, 0, 1)
    self:RemoveTimer(self.rapportChangeEffectTimer)
    self.rapportChangeEffectTimer = nil
  end, TIMER_INFINITE, 0.5)
end
function Lobby_Mid_Friend_UIBP:StartTeamQuickEffect()
  if not self.UIRoot or not self.UIRoot.Fadein then
    return
  end
  self:PlayUserWidgetAnimation(self.UIRoot.Anim_Prompt, 0, 1, 0, 1)
end
function Lobby_Mid_Friend_UIBP:EndTeamQuickEffect()
  if not self.UIRoot or not self.UIRoot.Anim_Prompt then
    return
  end
  self:PlayUserWidgetAnimation(self.UIRoot.Fadeout, 0, 1, 0, 1)
end
function Lobby_Mid_Friend_UIBP:UpdateTeamQuick()
  local logic_teamquick_entry = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_teamquick_entry)
  local canShow = logic_teamquick_entry:CheckCanShow()
  log(bWriteLog and "Lobby_Mid_Friend_UIBP:UpdateTeamQuick. canShow = " .. tostring(canShow))
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_TeamQuick, canShow)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CLobby_Mid_Friend_UIBP = class(ui_base, nil, Lobby_Mid_Friend_UIBP)
return CLobby_Mid_Friend_UIBP