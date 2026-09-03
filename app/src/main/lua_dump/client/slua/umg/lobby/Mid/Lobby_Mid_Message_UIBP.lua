local Lobby_Mid_Message_UIBP = {}
local foldAniPhrase = {
  idle = 1,
  playing = 2,
  stop = 3
}
function Lobby_Mid_Message_UIBP:ctor()
  self.teamPlatformTips = nil
  self.MentorBubble = nil
  self.MentorBubbleLeft = nil
  self.TeamPlatformGuideFlowLeft = nil
  self.TeamPlatformGuideFlow = nil
  self.grow_TeamPlat_tipsUI = nil
  self.teamPlatFormTipTime = 10
  self.curFoldAniPhrase = foldAniPhrase.idle
  self.tipsDelayTimer = nil
  self.bInit = false
end
function Lobby_Mid_Message_UIBP:OnInitialize()
  Lobby_Mid_Message_UIBP.__super.OnInitialize(self)
  self.util = require("client.slua_ui_framework.util")
  self.Common_Avatar_BP = self.UIRoot.Common_Avatar_BP
  self.TextBlock_NickName = self.UIRoot.TextBlock_NickName
  self.TextBlock_Team = self.UIRoot.TextBlock_Team
  self.Button_Observe = self.UIRoot.Button_Observe
  self.tipsCount = 0
  self.bHasGoldCard = false
  self.bHasExpCard = false
  self.bHasVSTeamWeaponExpCard = false
  local MentorSystem = require("client.slua.logic.mentor.logic_mentor")
  MentorSystem.GetServerTableData()
  self:SetWidgetVisible(self.UIRoot.Image_Avatar_New, false)
  self:SetWidgetVisible(self.UIRoot.Image_Home_Guide_New, false)
  self:SetWidgetVisible(self.UIRoot.Image_New, false)
  self.preLevel = nil
end
function Lobby_Mid_Message_UIBP:RegistEvents()
  Lobby_Mid_Message_UIBP.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_MAILINFO, self.UpdateObserveButton, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_UPDATE_LOBBY_AVATAR, self.UpdatePlayerAvatar, self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_ROLE_LEVEL_CHANGE, self.OnPlayerLevelChange, self)
  self:AddCommonEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_ROLENAME, self.UpdatePlayerNickName, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_SHOW_LOBBY, self.RefreshAvatarRedDot, self)
  self:AddCommonEvent(EVENTTYPE_COLLECT, EVENTID_COLLECT_NICKNAME_COLOR_CHANGE, self.OnNickNameColorChange, self)
  self:AddCommonEvent(EVENTTYPE_COLLECT, EVENTID_COLLECT_DATA_NOTIFY, self.UpdatePlayerAvatar, self)
  self:AddCommonEvent(EVENTTYPE_ROLEINFO, EVENTID_SEASON_UPDATE, self.UpdatePlayerAvatar, self)
  self:AddCommonEvent(EVENTTYPE_CRAZYWEEKEND, EVENTID_CRAZYWEEKEND_ACT_UPDATE, self.CheckCrazyWeekendAct, self)
  self:AddCommonEvent(EVENTTYPE_LEVEL_UNLOCK, EVENTID_LEVEL_UNLOCK_START_UNLOCK_GUIDE, self.DelayRefreshAvatarRedDot, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_CrazyWeekend, self.OnButton_CrazyWeekend, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Observe, self.OnButton_ObserveCick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_TeamUp, self.OnButton_TeamUpClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Collect_TreasureLvTab_Item_UIBP.Button_Treasure, self.OnClickCollectEntrance, self)
  self:AddControlEventByControl(self.UIRoot.Common_Avatar_BP, "OnClickItemCallback", self.OnClickItemCallback, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAM_PLATFORM_RECRUIT_PUBLISH, self.CheckTeamPlatformTips, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAM_PLATFORM_RECRUIT_CANCEL, self.UpdateEntryTips, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAM_PLATFORM_RECRUIT_TIMEOUT, self.UpdateEntryTips, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC, self.UpdateEntryTips, self)
  self:AddCommonEvent(EVENTTYPE_MENTOR, EVENTID_MENTOR_STATUS_NOTIFY, self.mentor_status_notify, self)
  self:AddCommonEvent(EVENTTYPE_MENTOR, EVENTID_MENTOR_REDDOT_NOTIFY, self.mentor_reddot_bind_notify, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_LOBBY_SOCIAL_UPDATE_HEAD_ICON, self.UpdateHeadFromSocial, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_LOBBY_MID_SHOW_NEXT_TIPS, self.OnShowNextTips, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_LOBBY_ISLAND_TIPS_FOR_COMEBACK_TASK, self.ComebackTaskToShowTips, self)
  self:AddCommonEvent(EVENTTYPE_ACTION, EVENTID_NEWBIE_GUIDE_WEAK_GUIDE_HIDE, self.UpdateWeakGuide, self)
  self:AddCommonEvent(EVENTTYPE_ACTION, EVENTID_NEWBIE_GUIDE_WEAK_GUIDE_SHOW, self.UpdateWeakGuide, self)
  self:AddCommonEvent(EVENTTYPE_LEVEL_UNLOCK, EVENTID_LEVEL_UNLOCK_OPEN_MAIN, self.OnLevelUnlockClickMain, self)
  self:AddCommonEvent(EVENTTYPE_LEVEL_UNLOCK, EVENTID_LEVEL_UNLOCK_GET_DATA, self.OnLevelUnlockGetData, self)
  self:AddCommonEvent(EVENTTYPE_COLLECT, EVENTID_COLLECT_PRIVILEGE_DATA_REFRESH, self.SetCollectLevel, self)
  self:AddCommonEvent(EVENTTYPE_COLLECT, EVENTID_COLLECT_MAIN_DATA, self.RefreshCollectEntrance, self)
  self:AddCommonEvent(EVENTTYPE_COLLECT, EVENTID_COLLECT_ROAD_LEVEL_UP, self.RefreshCollectEntrance, self)
  self:AddCommonEvent(EVENTTYPE_MENTOR, EVENTID_MENTOR_DATA, self.ShowMentorEntry, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_LOBBY_SHOW_OR_HIDE_PANEL, self.ShowOrHideLobbyPanel, self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_ROLE_LEVEL_CHANGE, self.CheckHomeEntry, self)
end
function Lobby_Mid_Message_UIBP:OnPostInitialize()
  Lobby_Mid_Message_UIBP.__super.OnPostInitialize(self)
  if DataMgr.roleData.level and DataMgr.roleData.level < 11 then
    self.preLevel = DataMgr.roleData.level
  end
  self:CheckOpenTeamPlatform()
  self:UpdateEntryTips()
  self:mentor_status_notify()
  self:UpdateWeakGuide()
  self:RegistReddotWidget(self.Common_Avatar_BP)
  self:AddTimer(0.1, function()
    self:UpdateUI()
    local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
    local spData = RoleInfoMainSystem.GetSuperData()
    for key, _ in pairs(spData) do
      self:AddDataListener(spData, key, self.RefreshAvatarRedDot, self)
    end
    self.bInit = true
    self:mentor_reddot_bind()
  end)
  self:ReqMentorData()
  self:CheckCrazyWeekendAct()
  local title = "CRAZY CHICKEN DAY"
  self.UIRoot.TextBlock_CrazyWeekend:SetText(title)
end
function Lobby_Mid_Message_UIBP:CheckCrazyWeekendAct()
  log(bWriteLog and "Lobby_Mid_Message_UIBP:CheckCrazyWeekendAct")
  local logic_crazy_weekend_teamUp_activity = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_crazy_weekend_teamUp_activity)
  local actIsOpen = logic_crazy_weekend_teamUp_activity:IsOpen()
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_CrazyWeekend, actIsOpen, false)
  local hasAwardCanGet = logic_crazy_weekend_teamUp_activity:hasAwardCanGet()
  self:SetWidgetVisible(self.UIRoot.Reddot_CrazyWeekend, hasAwardCanGet, false)
end
function Lobby_Mid_Message_UIBP:OnButton_CrazyWeekend()
  self:PlayAudio(sound_config.click_v1)
  local logic_crazy_weekend_teamUp_activity = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_crazy_weekend_teamUp_activity)
  local isOpen = logic_crazy_weekend_teamUp_activity:IsOpen()
  log(bWriteLog and "Lobby_Mid_Message_UIBP:OnButton_CrazyWeekend", tostring(isOpen))
  if isOpen then
    UIManager.ShowUI(UIManager.UI_Config.CrazyWeekend_HomePage_UIBP)
  else
    ShowNotice(85803)
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_CrazyWeekend, false, false)
  end
end
function Lobby_Mid_Message_UIBP:OnShow()
  self:CheckHideFeature()
  local OpenUIAction = require("client.slua.logic.GuideFlow.Action.OpenUIAction")
  OpenUIAction.HandleHoldingAction()
end
function Lobby_Mid_Message_UIBP:OnClose()
  local reddot_node_collect_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.reddot_node_collect_manager)
  local CollectTab = reddot_node_collect_manager:GetCollectTab()
  reddot_node_collect_manager:HideNodeAllChildNewReddot(CollectTab.collect_lobby, true)
  reddot_node_collect_manager:HideNodeAllChildBoxReddot(CollectTab.collect_lobby, true)
end
function Lobby_Mid_Message_UIBP:UpdateWeakGuide()
  local level_unlock_util = require("client.logic.level_unlock.util.level_unlock_util")
  local bLevelUnlockSwitchOpen = level_unlock_util:IsSwitchOpen()
  log(bWriteLog and "Lobby_Mid_Message_UIBP:UpdateWeakGuide = " .. tostring(bLevelUnlockSwitchOpen))
  if bLevelUnlockSwitchOpen then
    return
  end
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  self.UIRoot.CanvasPanel_12:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if growthprojectMgrB.IsWeakGuideTeamPlatform() then
    self:ShowUnfoldGrowProjectTeamPlatform()
  else
    self.UIRoot.NewbieGuide_TeamPlatformEntry:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function Lobby_Mid_Message_UIBP:mentor_status_notify()
  local MentorSystem = require("client.slua.logic.mentor.logic_mentor")
  local isSearching = MentorSystem.identity == MentorSystem.EIdentity.Mentor and MentorSystem.waiting_status == MentorSystem.EWaitingStatus.Wait
  if isSearching then
    MentorSystem.get_mentor_predictive_wait_time_req()
  end
end
function Lobby_Mid_Message_UIBP:mentor_reddot_bind_notify()
  self:mentor_reddot_bind()
end
function Lobby_Mid_Message_UIBP:mentor_reddot_bind()
  local MentorRedPointData = require("client.slua.logic.mentor.mentor_reddot_data")
  local rData = MentorRedPointData.GetData()
  if rData then
    self.UIRoot.Reddot_Anchor:UnBind()
    self:RegistReddotWidget(self.UIRoot.Reddot_Anchor)
    self.UIRoot.Reddot_Anchor:Bind(rData)
  end
end
function Lobby_Mid_Message_UIBP:OnClickItemCallback()
  self:PlayAudio(sound_config.click_v1)
  local UIUtil = require("client.common.ui_util")
  if UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.LobbyBtn) == false then
    return
  end
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  growthprojectMgrB.HideWeakGuide(1, 1)
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  RoleInfoMainSystem.Show(RoleInfoMainSystem.Segment, RoleInfoMainSystem.RoleInfoOpenFromType.Lobby, DataMgr.roleData.uid)
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  level_unlock_manager:OnClickFeature(level_unlock_manager.featureDef.achievement)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.LobbyHeadImage)
  self:UpdatePlayerAvatar()
end
function Lobby_Mid_Message_UIBP:UpdateUI()
  log(bWriteLog and "Lobby_Mid_Message_UIBP:UpdateUI")
  self:UpdatePlayerAvatar()
  self:UpdateObserveButton()
  local nickName = DataMgr.roleData.nickName
  self.TextBlock_NickName:SetText(nickName)
  self:UpdateNicknameColor()
  self:ShowVNGLogo()
  self:ShowHomeEntry()
  self:RefreshCollectEntrance()
end
function Lobby_Mid_Message_UIBP:UpdatePlayerNickName()
  self.UIRoot.TextBlock_NickName:SetText(DataMgr.roleData.nickName)
end
function Lobby_Mid_Message_UIBP:UpdateNicknameColor()
  log(bWriteLog and "Lobby_Mid_Message_UIBP:UpdateNicknameColor")
  local NicknameColorManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NicknameColorManager)
  self.UIRoot.TextBlock_NickName:SetColorAndOpacity(NicknameColorManager:GetColorByUID(DataMgr.roleData.uid))
end
function Lobby_Mid_Message_UIBP:OnNickNameColorChange(_, _, UID)
  if tostring(DataMgr.roleData.uid) == tostring(UID) then
    self:UpdateNicknameColor()
  end
end
function Lobby_Mid_Message_UIBP:OnPlayerLevelChange()
  self:UpdatePlayerAvatar()
  self:ShowHomeEntry()
end
function Lobby_Mid_Message_UIBP:UpdatePlayerAvatar()
  log(bWriteLog and "Lobby_Mid_Message_UIBP:UpdatePlayerAvatar")
  local extraPara = {
    collectPara = {
      collectData = DataMgr.roleData.brief_collect_data,
      showCollectTips = false
    }
  }
  log_tree("Lobby_Mid_Message_UIBP:UpdatePlayerAvatar extraPara", extraPara)
  log(bWriteLog and "Lobby_Mid_Message_UIBP:UpdatePlayerAvatar" .. tostring(DataMgr.roleData.cur_avatar_box_id))
  self.Common_Avatar_BP:InitView(1, DataMgr.roleData.uid, DataMgr.roleData.headIconUrl, tonumber(DataMgr.roleData.gender), DataMgr.roleData.cur_avatar_box_id, DataMgr.roleData.level, false, "", nil, extraPara)
end
function Lobby_Mid_Message_UIBP:Close()
  self:ClearTipsData()
  self.tipsDelayTimer = nil
  Lobby_Mid_Message_UIBP.__super.Close(self)
end
function Lobby_Mid_Message_UIBP:EnterMentor()
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.IsInLargeTeam() then
    ShowNotice(27571)
    return false
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  if logic_mode_selection:IsSelect8PlayersMode() then
    ShowNotice(27572)
    return false
  end
  log(bWriteLog and "OpenMentor")
  local MentorSystem = require("client.slua.logic.mentor.logic_mentor")
  MentorSystem.OpenUI()
  self:CloseMentorBubble()
  self:HideTipsByType(LobbyMidTipsType.MentorBubbleGuideFlow)
end
function Lobby_Mid_Message_UIBP:ShowVerticalButtonList()
  self.UIRoot.CanvasPanel_ButtonList:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
end
function Lobby_Mid_Message_UIBP:HideVerticalButtonList()
  self.UIRoot.CanvasPanel_ButtonList:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function Lobby_Mid_Message_UIBP:UpdateEntryTips()
  self:CheckMentorTips()
  self:CheckTeamPlatformTips()
end
function Lobby_Mid_Message_UIBP:OnButton_TeamUpClick()
  self:PlayAudio(sound_config.click_v1)
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  if logic_mode_selection.hasSelectTxMission then
    ShowNotice(87013)
    return
  end
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  growthprojectMgrB.HideWeakGuide(4, 1)
  if self.grow_TeamPlat_tipsUI then
    self.grow_TeamPlat_tipsUI:Close()
    self.grow_TeamPlat_tipsUI = nil
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local TeamPlatformSystem = require("client.slua.logic.teamup.logic_team_platform")
  local isSendRecruitDirectly = false
  local TeamPlatform_Macro = require("client.slua.logic.teamup.teamplatform_macro")
  local tlogReason = TeamPlatform_Macro.Enum_ButtonEntranceState.FindTeam
  if TeamPlatformSystem.IsInRecruit() then
    tlogReason = TeamPlatform_Macro.Enum_ButtonEntranceState.InRecruit
  elseif 1 < TeamUpNewSystem.GetTeamNum() and TeamUpNewSystem.IsTeamLeader() then
    isSendRecruitDirectly = true
    tlogReason = TeamPlatform_Macro.Enum_ButtonEntranceState.SendRecruit
  end
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  local LogicUGCMulti = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMulti)
  local Opentype
  if LogicUGCMatch:GetMatchModID() > 0 or LogicUGCMulti.bIsBundleMatch then
    Opentype = 3
    TeamPlatformSystem.ShowUI(Opentype, isSendRecruitDirectly)
  else
    Opentype = 1
    TeamPlatformSystem.ShowUI(Opentype, isSendRecruitDirectly)
  end
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.TeamPlatFormEntranceClick, nil, tlogReason)
  self:UpdatePlatFormGuideSaveData()
  self:HideTipsByType(LobbyMidTipsType.TeamPlatform)
  self:CloseTeamPlatformGuideFlow()
  self:HideTipsByType(LobbyMidTipsType.TeamPlatformGuideFlow)
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  level_unlock_manager:OnClickFeature(level_unlock_manager.featureDef.teamLobby)
end
function Lobby_Mid_Message_UIBP:CheckTeamPlatformTips()
  self:SetWidgetVisible(self.TextBlock_Team, false)
  self:SetWidgetVisible(self.UIRoot.Border_2, false)
  self:SetWidgetVisible(self.UIRoot.Image_Bg, true)
  self:SetWidgetVisible(self.UIRoot.Image_Effect, false)
  self:SetWidgetVisible(self.UIRoot.Image_Effect2, false)
  local TeamPlatformSystem = require("client.slua.logic.teamup.logic_team_platform")
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if not TeamPlatformSystem.IsOpen() then
    self:CloseTeamPlatformGuideTips()
    return
  end
  local logic_access_restriction = require("client.logic.common.logic_access_restriction")
  if not logic_access_restriction.CheckAccess(logic_access_restriction.EAccessType.TeamPlatform) then
    return
  end
  if TeamUpNewSystem.GetTeamNum() > 1 then
    self.UIRoot.WidgetSwitcher_ImageTeamUp:SetActiveWidgetIndex(1)
  else
    self.UIRoot.WidgetSwitcher_ImageTeamUp:SetActiveWidgetIndex(0)
  end
  if TeamPlatformSystem.IsInRecruit() then
    self:CloseTeamPlatformGuideTips()
    if not TeamPlatformSystem.IsFull() then
      self:SetWidgetVisible(self.UIRoot.Image_Bg, false)
      self:SetWidgetVisible(self.UIRoot.Image_Effect, true)
      self:SetWidgetVisible(self.UIRoot.Image_Effect2, true)
      local curNum = TeamUpNewSystem.GetTeamNum()
      local teamPublishOption = TeamPlatformSystem.GetTeamPublishOption()
      local teamMaxNum = teamPublishOption and teamPublishOption.nPlayerNum or 4
      self:SetWidgetVisible(self.UIRoot.Border_2, true)
      self:SetWidgetVisible(self.TextBlock_Team, true)
      self.TextBlock_Team:SetText(LocUtil.LocalizeResFormat(6830, tostring(curNum), tostring(teamMaxNum)))
      self.UIRoot.WidgetSwitcher_ImageTeamUp:SetActiveWidgetIndex(1)
    end
  else
    local isShowLeaderGuide = false
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    if TeamUpNewSystem.GetTeamNum() > 1 and TeamUpNewSystem.IsTeamLeader() then
      self:SetWidgetVisible(self.UIRoot.Border_2, false)
      self:SetWidgetVisible(self.TextBlock_Team, true)
      local logic_team_platform_new = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_team_platform_new)
      isShowLeaderGuide = logic_team_platform_new:IsNeedShowLeaderGuide()
    end
    local levelLimit = TeamPlatformSystem.GetLevelLimit()
    levelLimit = tonumber(levelLimit) or 0
    if levelLimit > DataMgr.roleData.level then
      self:CloseTeamPlatformGuideTips()
      return
    end
    local MentorSystem = require("client.slua.logic.mentor.logic_mentor")
    if MentorSystem.GetGuideStatus() then
      self:CloseTeamPlatformGuideTips()
      return
    end
    if isShowLeaderGuide then
      self:TryShowTips(LobbyMidTipsType.TeamPlatform)
    end
  end
end
function Lobby_Mid_Message_UIBP:ShowTeamPlatformGuideTips()
  log(bWriteLog and "Lobby_Mid_Message_UIBP:ShowTeamPlatformGuideTips")
  if self.isShowMentorEntry then
    log(bWriteLog and "Lobby_Mid_Message_UIBP:ShowTeamPlatformGuideTips isShowMentorEntry")
    return
  end
  if not self.teamPlatformTips then
    self.teamPlatformTips = self:CreateChildWindow(self.UIRoot.CanvasPanel_TeamPlatformTips, UIManager.UI_Config.Common_Normal_Tips_UIBP, 5, true)
    self:AddTimerOnce(self.teamPlatFormTipTime, function()
      self:CloseTeamPlatformGuideTips()
      self:UpdatePlatFormGuideSaveData()
    end)
  end
end
function Lobby_Mid_Message_UIBP:UpdatePlatFormGuideSaveData()
  local logic_team_platform_new = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_team_platform_new)
  logic_team_platform_new:UpdateSendRecruitGuideSaveData()
end
function Lobby_Mid_Message_UIBP:UpdateMentorBubble(isNormal)
  if not self.MentorBubble then
    local OpenUIAction = require("client.slua.logic.GuideFlow.Action.OpenUIAction")
    if isNormal then
      OpenUIAction.ShowingType = 5
      self.MentorBubble = self:CreateChildWindow(self.UIRoot.CanvasPanel_MentorTips, UIManager.UI_Config.Common_Normal_Tips_UIBP, 3, true)
    else
      OpenUIAction.ShowingType = 6
      self.MentorBubble = self:CreateChildWindow(self.UIRoot.CanvasPanel_MentorTips, UIManager.UI_Config.Common_Special_Tips_UIBP, 3, true)
    end
  end
end
function Lobby_Mid_Message_UIBP:UpdateMentorBubbleLeft(isNormal)
  if not self.MentorBubbleLeft then
    local OpenUIAction = require("client.slua.logic.GuideFlow.Action.OpenUIAction")
    if isNormal then
      OpenUIAction.ShowingType = 5
      self.MentorBubbleLeft = self:CreateChildWindow(self.UIRoot.CanvasPanel_4, UIManager.UI_Config.Common_Normal_Tips_UIBP, 3, false)
    else
      OpenUIAction.ShowingType = 6
      self.MentorBubbleLeft = self:CreateChildWindow(self.UIRoot.CanvasPanel_4, UIManager.UI_Config.Common_Special_Tips_UIBP, 3, false)
    end
  end
end
function Lobby_Mid_Message_UIBP:UpdateTeamPlatformGuideFlow(isNormal)
  if not self.TeamPlatformGuideFlow then
    if isNormal then
      self.TeamPlatformGuideFlow = self:CreateChildWindow(self.UIRoot.CanvasPanel_TeamPlatformTips, UIManager.UI_Config.Common_Normal_Tips_UIBP, 2, true)
    else
      self.TeamPlatformGuideFlow = self:CreateChildWindow(self.UIRoot.CanvasPanel_TeamPlatformTips, UIManager.UI_Config.Common_Special_Tips_UIBP, 2, true)
    end
  end
end
function Lobby_Mid_Message_UIBP:UpdateTeamPlatformGuideFlowLeft(isNormal)
  if not self.TeamPlatformGuideFlowLeft then
    if isNormal then
      self.TeamPlatformGuideFlowLeft = self:CreateChildWindow(self.UIRoot.CanvasPanel_8, UIManager.UI_Config.Common_Normal_Tips_UIBP, 2, false)
    else
      self.TeamPlatformGuideFlowLeft = self:CreateChildWindow(self.UIRoot.CanvasPanel_8, UIManager.UI_Config.Common_Special_Tips_UIBP, 2, false)
    end
  end
end
function Lobby_Mid_Message_UIBP:ShowUnfoldGrowProjectTeamPlatform()
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  if growthprojectMgrB.IsWeakGuideTeamPlatform() then
    self:ShowWeakGuidePlatFormTips()
  else
    self.UIRoot.NewbieGuide_TeamPlatformEntry:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function Lobby_Mid_Message_UIBP:ShowWeakGuidePlatFormTips()
  log(bWriteLog and "[v_wllwu] Lobby_Mid_Message_UIBP:ShowWeakGuidePlatFormTips")
  if self.closeWeakGuideTimer then
    self:RemoveTimer(self.closeWeakGuideTimer)
    self.closeWeakGuideTimer = nil
  end
  self.UIRoot.TextBlock_1:SetText(LocUtil.GetLocalizeResStr(12760))
  self:SetWidgetVisible(self.UIRoot.NewbieGuide_TeamPlatformEntry, true)
  self.closeWeakGuideTimer = self:AddTimerOnce(self.teamPlatFormTipTime, function()
    self:SetWidgetVisible(self.UIRoot.NewbieGuide_TeamPlatformEntry, false)
  end)
end
function Lobby_Mid_Message_UIBP:ShowFoldGrowProjectTeamPlatform()
  if not self.grow_TeamPlat_tipsUI then
    local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
    if growthprojectMgrB.IsWeakGuideTeamPlatform() then
      self.grow_TeamPlat_tipsUI = self:CreateChildWindow(self.UIRoot.CanvasPanel_TeamPlatformTips, UIManager.UI_Config.Common_Normal_Tips_UIBP, 2, true)
      self.grow_TeamPlat_tipsUI:SetTips2(LocUtil.GetLocalizeResStr("12760"))
    end
  end
end
function Lobby_Mid_Message_UIBP:CloseUnfoldGrowProjectTeamPlatform()
  log(bWriteLog and "[qintong] CloseUnfoldGrowProjectTeamPlatform")
  if self.UIRoot.NewbieGuide_TeamPlatformEntry:GetVisibility() == UEnums.ESlateVisibility.SelfHitTestInvisible then
    self.UIRoot.NewbieGuide_TeamPlatformEntry:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function Lobby_Mid_Message_UIBP:CloseMentorBubble()
  log(bWriteLog and "Lobby_Mid_Message_UIBP:CloseMentorBubble")
  if self.MentorBubble then
    self.MentorBubble:Close()
    self.MentorBubble = nil
  end
  if self.MentorBubbleLeft then
    self.MentorBubbleLeft:Close()
    self.MentorBubbleLeft = nil
  end
end
function Lobby_Mid_Message_UIBP:CloseFoldGrowProjectTeamPlatform()
  if self.grow_TeamPlat_tipsUI then
    self.grow_TeamPlat_tipsUI:Close()
    self.grow_TeamPlat_tipsUI = nil
  end
  self:ShowNextTips(false)
end
function Lobby_Mid_Message_UIBP:CloseTeamPlatformGuideFlow()
  if self.TeamPlatformGuideFlow then
    self.TeamPlatformGuideFlow:Close()
    self.TeamPlatformGuideFlow = nil
  end
  if self.TeamPlatformGuideFlowLeft then
    self.TeamPlatformGuideFlowLeft:Close()
    self.TeamPlatformGuideFlowLeft = nil
  end
end
function Lobby_Mid_Message_UIBP:CloseTeamPlatformGuideTips()
  log(bWriteLog and "god test CloseTeamPlatformGuideTips")
  if self.teamPlatformTips then
    self.teamPlatformTips:Close()
    self.teamPlatformTips = nil
  end
end
function Lobby_Mid_Message_UIBP:CheckOpenTeamPlatform()
  local TeamPlatformSystem = require("client.slua.logic.teamup.logic_team_platform")
  if not TeamPlatformSystem.IsOpen() then
    self.UIRoot.CanvasPanel_TeamPlatformEntry:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    self.UIRoot.CanvasPanel_TeamPlatformEntry:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
end
function Lobby_Mid_Message_UIBP:ShowVNGLogo()
  local VNGMenuOpenStatus = LobbySystem.CheckOpen(BP_ENUM_VNG_OPENMARK_Lobby)
  local showLogo = false
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if not GlobalData.IsIOSCheck() and Client.GetPublishRegion() == PublishRegionMacros.VNG then
    log(bWriteLog and "Lobby_Mid_Message_UIBP:ShowVNGLogo" .. tostring(VNGMenuOpenStatus))
    showLogo = VNGMenuOpenStatus
  end
  if showLogo then
    self.UIRoot["18+"]:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot["18+"]:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function Lobby_Mid_Message_UIBP:UpdateHeadFromSocial()
  self:UpdatePlayerAvatar()
end
local tipsList = {}
local isTipsShowing = false
local showingTipsType = 0
local nextTipsInterval = 5
local tipsFuncList = {
  [LobbyMidTipsType.TeamPlatform] = {
    showFunc = "ShowTeamPlatformGuideTips",
    hideFunc = "CloseTeamPlatformGuideTips"
  },
  [LobbyMidTipsType.MentorBubbleGuideFlow] = {
    showFunc = "UpdateMentorBubble",
    hideFunc = "CloseMentorBubble"
  },
  [LobbyMidTipsType.TeamPlatformGuideFlow] = {
    showFunc = "UpdateTeamPlatformGuideFlow",
    hideFunc = "CloseTeamPlatformGuideFlow"
  },
  [LobbyMidTipsType.GrowProjectTeamPlatform] = {
    showFunc = "ShowFoldGrowProjectTeamPlatform",
    hideFunc = "CloseFoldGrowProjectTeamPlatform"
  }
}
function Lobby_Mid_Message_UIBP:_ShowTipsByType(type, extra)
  local cfg = tipsFuncList[type]
  if cfg and cfg.showFunc and cfg.showFunc ~= "" then
    self[cfg.showFunc](self, extra)
    isTipsShowing = true
    showingTipsType = type
  end
end
function Lobby_Mid_Message_UIBP:HideTipsByType(type)
  for i, v in pairs(tipsList) do
    if v.type == type then
      table.remove(tipsList, i)
      break
    end
  end
  if type == showingTipsType then
    local cfg = tipsFuncList[type]
    if cfg and cfg.hideFunc and cfg.hideFunc ~= "" then
      self[cfg.hideFunc](self)
      self:ClearTipsShowingState()
    end
  end
end
function Lobby_Mid_Message_UIBP:_ShowTipsFromList()
  log_tree("_ShowTipsFromList tipsList:", tipsList)
  if 0 < #tipsList then
    self:_ShowTipsByType(tipsList[1].type, tipsList[1].extra)
    table.remove(tipsList, 1)
  end
end
function Lobby_Mid_Message_UIBP:OnShowNextTips()
  self:ClearTipsShowingState()
  log(bWriteLog and "god test OnShowNextTips ")
  self:ShowNextTips(false)
end
function Lobby_Mid_Message_UIBP:ShowNextTips(immediate)
  if 0 < #tipsList then
    if immediate then
      self:_ShowTipsFromList()
    elseif tipsList[1] and tipsList[1].extra and type(tipsList[1].extra) == "table" and tipsList[1].extra.immediate then
      self:_ShowTipsFromList()
    else
      self:CloseTipsDelayTimer()
      self.tipsDelayTimer = self:AddTimer(nextTipsInterval, function()
        self.tipsDelayTimer = nil
        self:_ShowTipsFromList()
      end)
    end
  end
end
function Lobby_Mid_Message_UIBP:TryShowTips(type, extra)
  if isTipsShowing and showingTipsType == type then
    self:_ShowTipsByType(type, extra)
    return
  end
  if isTipsShowing then
    self:AddCachedTips(type, extra)
    return
  end
  if self.tipsDelayTimer then
    self:AddCachedTips(type, extra)
    return
  end
  self:_ShowTipsByType(type, extra)
end
function Lobby_Mid_Message_UIBP:TryShowTipsOutSide(type, extra)
  if self.curFoldAniPhrase == foldAniPhrase.idle then
    if type == LobbyMidTipsType.TeamPlatformGuideFlow then
      self:UpdateTeamPlatformGuideFlowLeft(extra)
    elseif type == LobbyMidTipsType.MentorBubbleGuideFlow then
      self:UpdateMentorBubbleLeft(extra)
    elseif type == LobbyMidTipsType.SocialIslandGuideFlow then
    end
  end
  self:TryShowTips(type, extra)
end
function Lobby_Mid_Message_UIBP:AddCachedTips(type, extra)
  for i, v in pairs(tipsList) do
    if v.type == type then
      table.remove(tipsList, i)
      break
    end
  end
  local param = {}
  param.  param.  table.insert(tipsList, param)
  table.sort(tipsList, function(a, b)
    return a.type < b.type
  end)
  log_tree("god test tipsList ", tipsList)
end
function Lobby_Mid_Message_UIBP:CheckMentorTips()
  log(bWriteLog and "CheckMentorTips")
  local MentorSystem = require("client.slua.logic.mentor.logic_mentor")
  if MentorSystem.GetGuideStatus() then
    self:TryShowTips(LobbyMidTipsType.Mentor)
  else
    self:HideTipsByType(LobbyMidTipsType.Mentor)
  end
end
function Lobby_Mid_Message_UIBP:DelayRefreshAvatarRedDot()
  if self._delayRefreshAvatarRedDotTimer then
    self:RemoveTimer(self._delayRefreshAvatarRedDotTimer)
    self._delayRefreshAvatarRedDotTimer = nil
  end
  self._delayRefreshAvatarRedDotTimer = self:AddTimerOnce(0, function()
    log(bWriteLog and "Lobby_Mid_Message_UIBP:DelayRefreshAvatarRedDot")
    self:RefreshAvatarRedDot()
  end)
end
function Lobby_Mid_Message_UIBP:RefreshAvatarRedDot()
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  local bIsTotalRed = false
  local spData = RoleInfoMainSystem.GetSuperData()
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  if level_unlock_manager:IsFeatureUnlocked(level_unlock_manager.featureDef.achievement) then
    log_warning(bWriteLog and "Lobby_Mid_Message_UIBP:RefreshAvatarRedDot. is achievement unlocked")
    bIsTotalRed = false
  else
    for key, bIsTabRed in pairs(spData) do
      if bIsTabRed then
        log(bWriteLog and "Lobby_Mid_Message_UIBP:RefreshAvatarRedDot key " .. tostring(key))
        bIsTotalRed = true
        break
      end
    end
  end
  log(bWriteLog and "Lobby_Mid_Message_UIBP:RefreshAvatarRedDot bIsTotalRed " .. tostring(bIsTotalRed))
  if not self.bInit then
    if bIsTotalRed then
      self:ToggleReddotActivation(self.Common_Avatar_BP, bIsTotalRed)
      self.bInit = true
    end
  else
    self:ToggleReddotActivation(self.Common_Avatar_BP, bIsTotalRed)
  end
  local bShow = self:IsShowingAvatarReddot()
  if bIsTotalRed and bShow then
    log(bWriteLog and "Lobby_Mid_Message_UIBP:RefreshAvatarRedDot Refresh")
    self.Common_Avatar_BP:SetRedDot(false)
    self.Common_Avatar_BP:SetRedDot(true)
    self:SetWidgetVisible(self.UIRoot.Image_Avatar_New, false)
  end
end
function Lobby_Mid_Message_UIBP:IsShowingAvatarReddot()
  local logic_reddot_limitation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_reddot_limitation)
  local bShow = logic_reddot_limitation:IsShowingReddot(self.Common_Avatar_BP)
  log(bWriteLog and "Lobby_Mid_Message_UIBP:IsShowingAvatarReddot " .. tostring(bShow))
  return bShow
end
function Lobby_Mid_Message_UIBP:ShowMentorStatus(txt)
  if self.mentor_status_tips == nil then
    self.mentor_status_tips = self:CreateChildWindow(self.UIRoot.CanvasPanel_MentorTips, UIManager.UI_Config.Lobby_Mid_Tips)
  end
  self.mentor_status_tips:SetTips(txt)
  if self.mentorStatusTimer then
    self:RemoveTimer(self.mentorStatusTimer)
    self.mentorStatusTimer = nil
  end
  self.mentorStatusTimer = self:AddTimer(15, function()
    self.mentorStatusTimer = nil
    self:HideTipsByType(LobbyMidTipsType.MentorStatus)
  end)
end
function Lobby_Mid_Message_UIBP:CloseMentorStatus()
  if self.mentor_status_tips then
    self.mentor_status_tips:Close()
    self.mentor_status_tips = nil
  end
  if self.mentorStatusTimer then
    self:RemoveTimer(self.mentorStatusTimer)
    self.mentorStatusTimer = nil
  end
end
function Lobby_Mid_Message_UIBP:ClearTipsData()
  self.curFoldAniPhrase = foldAniPhrase.idle
  tipsList = {}
  self:ClearTipsShowingState()
end
function Lobby_Mid_Message_UIBP:CloseTipsDelayTimer()
  if self.tipsDelayTimer then
    self:RemoveTimer(self.tipsDelayTimer)
    self.tipsDelayTimer = nil
  end
end
function Lobby_Mid_Message_UIBP:ClearTipsShowingState()
  isTipsShowing = false
  showingTipsType = 0
end
function Lobby_Mid_Message_UIBP:ComebackTaskToShowTips()
  log(bWriteLog and "god test ComebackTaskToShowTips isTipsShowing " .. tostring(isTipsShowing) .. " showingTipsType " .. tostring(showingTipsType))
  local extra = {immediate = true}
  if isTipsShowing and showingTipsType ~= 0 then
    if showingTipsType == LobbyMidTipsType.ComeBackTaskForSocialIsland then
      self:_ShowTipsByType(LobbyMidTipsType.ComeBackTaskForSocialIsland, extra)
    else
      self:TryShowTips(LobbyMidTipsType.ComeBackTaskForSocialIsland, extra)
      self:HideTipsByType(showingTipsType)
    end
  else
    self:_ShowTipsByType(LobbyMidTipsType.ComeBackTaskForSocialIsland, extra)
  end
end
function Lobby_Mid_Message_UIBP:OnButton_ObserveCick()
  self:PlayAudio(sound_config.click)
  local ext_info = DataMgr.roleData.mil_info and DataMgr.roleData.mil_info.ext_info
  log_tree("[ljw] DataMgr.roleData.mil_info", DataMgr.roleData.mil_info)
  local banTipStr
  if ext_info and next(ext_info) then
    local TimeUtil = require("client.common.time_util")
    local remainTime = DataMgr.roleData.mil_info.expire_time - TimeUtil.GetServerTimeInSec()
    remainTime = math.max(0, remainTime)
    local time = TimeUtil.FormatCountDownTime_DHMS(remainTime)
    if time then
      banTipStr = LocUtil.LocalizeResFormat(ext_info.mail_id, time)
    else
      banTipStr = LocUtil.GetLocalizeResStr(ext_info.mail_id)
    end
  end
  local MatchSystem = require("client.slua.logic.match.logic_match")
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsBLUEHOLE() or ext_info and ext_info.appeal_link_switch then
    MatchSystem.ShowNewObserveTips(banTipStr)
  else
    MatchSystem.ShowObserveTips(banTipStr)
  end
end
function Lobby_Mid_Message_UIBP:UpdateObserveButton()
  local mil_info = DataMgr.roleData and DataMgr.roleData.mil_info
  local mail_info_lable = mil_info and mil_info.label
  local is_flag_visible = mil_info and mil_info.is_flag_visible
  log(bWriteLog and "[ljw] mail_info_lable" .. tostring(mail_info_lable))
  log(bWriteLog and "[ljw] is_flag_visible" .. tostring(is_flag_visible))
  if self.Button_Observe then
    if mail_info_lable and tonumber(mail_info_lable) == 2 and is_flag_visible and tonumber(is_flag_visible) == 1 then
      self.Button_Observe:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    else
      self.Button_Observe:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  else
    log_error("button had been freed, can't be used")
  end
  self.UIRoot.TextBlock_0:SetText(LocUtil.GetLocalizeResStr(10050))
end
function Lobby_Mid_Message_UIBP:OnLevelUnlockClickMain(_, __, feature)
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  if feature == level_unlock_manager.featureDef.mentor then
    level_unlock_manager:OnClickFeature(level_unlock_manager.featureDef.mentor)
    self:EnterMentor()
  end
end
function Lobby_Mid_Message_UIBP:OnLevelUnlockGetData()
  self:CheckHideFeature()
end
function Lobby_Mid_Message_UIBP:CheckHideFeature()
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  level_unlock_manager:CheckForHideFeature(self.UIRoot.CanvasPanel_TeamPlatformEntry, level_unlock_manager.featureDef.teamLobby)
end
function Lobby_Mid_Message_UIBP:ShowHomeEntry()
  log(bWriteLog and "Lobby_Mid_Message_UIBP:ShowHomeEntry")
  if self.homeEntryUI then
    log(bWriteLog and "Lobby_Mid_Message_UIBP:ShowHomeEntry self.homeEntryUI exist")
    return
  end
  if not LobbySystem.CheckOpen(BP_ENUM_HOME_LOBBY_ENTRY_SWITCH_ID) then
    log(bWriteLog and "Lobby_Mid_Message_UIBP:ShowHomeEntry BP_ENUM_HOME_LOBBY_ENTRY_SWITCH_ID switch not open")
    return
  end
  local level = DataMgr.roleData.level
  if level < 11 then
    log(bWriteLog and "Lobby_Mid_Message_UIBP:ShowHomeEntry level not enough")
    return
  end
  local logic_home_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_switch)
  if not logic_home_switch:CheckHomeSwitchOpen() then
    log(bWriteLog and "Lobby_Mid_Message_UIBP:ShowHomeEntry CheckHomeSwitchOpen not open")
    return
  end
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Home_Entrance, true)
  self.homeEntryUI = self:CreateChildWindow(self.UIRoot.CanvasPanel_Home_Entrance, UIManager.UI_Config.Lobby_Home_Entrance_Item_UIBP)
  self.homeEntryUI:SetAutoSize(true)
end
function Lobby_Mid_Message_UIBP:RefreshCollectEntrance()
  local score, curLevel = 0, 0
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local tCollectData = collect_module:GetCollectData()
  if not tCollectData then
    local CollectHandler = require("client.network.Protocol.CollectHandler")
    CollectHandler.send_get_collect_sys_main_data_req()
  else
    score, curLevel = collect_module:GetCollectTotalScore()
  end
  if 0 < curLevel then
    self.UIRoot.Collect_TreasureLvTab_Item_UIBP.TextBlock_Lv:SetText(LocUtil.LocalizeResFormat(7000014, curLevel))
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_TreasureLvTab, true)
    self:SetWidgetVisible(self.UIRoot.Collect_TreasureLvTab_Item_UIBP.Button_Treasure, true, true)
  else
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_TreasureLvTab, false)
  end
end
function Lobby_Mid_Message_UIBP:OnClickCollectEntrance()
  self:PlayAudio(sound_config.click_v1)
  GlobalData.JumpUrl("game://?module=1002300&index=15&openTab=1")
end
function Lobby_Mid_Message_UIBP:SetCollectLevel()
  if self.Common_Avatar_BP then
    self.Common_Avatar_BP:SetCollectLevel()
  end
end
function Lobby_Mid_Message_UIBP:ShowMentorEntry()
  local logic_mentor = require("client.slua.logic.mentor.logic_mentor")
  if logic_mentor.IsCanShowLobbyEntry() then
    self.isShowMentorEntry = true
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_Regression, true)
    local regressionItem = self:CreateChildWindow("CanvasPanel_Regression", UIManager.UI_Config.Lobby_Mid_Regression_Item_UIBP)
    if regressionItem then
      regressionItem:SetAutoSize(true)
    end
    self:CloseTeamPlatformGuideTips()
  else
    self.isShowMentorEntry = false
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_Regression, false)
  end
end
function Lobby_Mid_Message_UIBP:ReqMentorData()
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  local bIsGuest = IMSDKHelperInstance:IsEqualCurLoginPlatform(ShareSource.Guest)
  if bIsGuest then
    log(bWriteLog and "Lobby_Mid_Message_UIBP:ReqMentorData. guest login")
    return
  end
  local levelUnlockManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  if not levelUnlockManager:IsFeatureUnlocked(levelUnlockManager.featureDef.mentor) then
    log(bWriteLog and "Lobby_Mid_Message_UIBP:ReqMentorData. mentor feature not unlocked")
    return
  end
  local logic_mentor = require("client.slua.logic.mentor.logic_mentor")
  local task = {
    module = logic_mentor,
    funcName = "get_mentor_data_req",
    param = logic_mentor,
    protect = true
  }
  local queue_task_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.queue_task_module)
  queue_task_module:Enqueue(queue_task_module.TaskEnum.Lobby, task)
end
function Lobby_Mid_Message_UIBP:ShowOrHideLobbyPanel(_, _, isShow, parentName, config)
  log_format(bWriteLog and "Lobby_Mid_Message_UIBP:ShowOrHideLobbyPanel isShow:%s parentName:%s config:%s", tostring(isShow), tostring(parentName), tostring(config and config.moduleName or "nil"))
  if parentName == "CanvasPanel_TeamExtra" and config == UIManager.UI_Config.team_extra_main then
    self.isShowMentorEntry = not isShow
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_Regression, not isShow)
  end
end
function Lobby_Mid_Message_UIBP:CheckHomeEntry()
  log(bWriteLog and "Lobby_Mid_Message_UIBP:CheckHomeEntry")
  if not self.preLevel then
    log(bWriteLog and "Lobby_Mid_Message_UIBP:CheckHomeEntry preLevel is nil")
    return
  end
  if DataMgr.roleData.level >= 11 then
    self:ShowHomeEntry()
    self.preLevel = nil
  else
    log(bWriteLog and "Lobby_Mid_Message_UIBP:CheckHomeEntry level not reached")
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CLobby_Mid_Message_UIBP = class(ui_base, nil, Lobby_Mid_Message_UIBP)
return CLobby_Mid_Message_UIBP