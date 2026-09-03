local UI_Match_Entry = {}
local gem_report_utils = require("client.logic.store.gem_report_utils")
local MatchSystem = require("client.slua.logic.match.logic_match")
local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
local LogicMatchEntry = require("client.slua.logic.lobby.Mid.logic_match_entry")
local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
local local SHRINK = 0
local EXPAND = 1
local E_MatchStatus = ENUM_MatchStatus
local C_SkinID = 10001
local C_NormalButtonImagePath = "/Game/UMG/Texture/Atlas/LobbyUI_Button/Frames/LOBBY_image_anniu_common_png.LOBBY_image_anniu_common_png"
local IsTeamLeader = true
local show = function(widget)
  if widget then
    widget:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  end
end
local collapse = function(widget)
  if widget then
    widget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
local selfHit = function(widget)
  if widget then
    widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
end
local GetSkinStyleID = function(skinID)
  skinID = skinID or C_SkinID
  return skinID * 10 + 6
end
local ENUM_LT_REC_TYPE = {
  RECENT = 1,
  VERSION = 2,
  SHORTEST = 3
}
local ENUM_MatchPanelState = {
  Collapsed = 0,
  LTOnly = 1,
  LTExpanded = 2,
  NormalExpand = 3
}
function UI_Match_Entry:ctor()
  self.bShowTextTip = false
  self.hideTipTimer = nil
  self.bClickTipButton = false
  self.resetClickTipTimer = nil
  self.autoTestTimer = nil
  self.reqDataTimer = nil
  self.bSameLanguageMatch = false
  self.nConfirmCloseTime = 0
  self.bShowPloyTextTip = false
  self.nSkinID = C_SkinID
  self.preMatchState = nil
  self.MathInfoState = SHRINK
  self.nMatchPanelState = ENUM_MatchPanelState.Collapsed
  self.bWaitForMatchShown = false
  self.bHighLevelTipsExpanded = false
  self.bDebugTimersSet = false
  self.bShowHistory = false
  self.needRecoverWin = false
  self.LTMatchAnimTimer = nil
end
function UI_Match_Entry:OnInitialize()
  UI_Match_Entry.__super.OnInitialize(self)
  MatchSystem.InitData()
  self.doubelCardUI = self:CreateChildWindow("CanvasPanel_DoubleCard", UIManager.UI_Config.lobby_doublecard_entrance)
  log("UI_Match_Entry:OnInitialize")
end
function UI_Match_Entry:SelfHitTestInvisible()
  UI_Match_Entry.__super.SelfHitTestInvisible(self)
end
function UI_Match_Entry:RegistEvents()
  UI_Match_Entry.__super.RegistEvents(self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Entry, self.OnClickEntry, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Expand, self.OnClickExpand, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_0, self.OnClickOpenSettings, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_ArenaWeapon, self.OnClickArenaWeapon, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Mask, self.OnClickCurMode, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Lock, self.OnClickEntryRestrict, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Close, self.OnClickCloseRewardTips, self)
  self:AddControlEventByControl(self.UIRoot.Anina_Permanent, "OnAnimationFinished", self.LobbyEffectEnd, self)
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_MATCH_MODE_SELECT_CHANGE, self.OnMatchModSelectChange, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_SWITCHTO_PAGE_START, self.OnSwitchToPageStart, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_SWITCHTO_PAGE_END, self.OnSwitchToPageEnd, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_LOBBY_FADE_IN_ANIM_FINISH, self.OnEnter, self)
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_MATCH_UPDATE_STATUS, self.OnUpdateMatchStatus, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC, self.OnUpdateMatchStatus, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CHECK_TEAM_STATE, self.OnCheckTeamMatchState, self)
  self:AddCommonEvent(EVENTTYPE_MENTOR, EVENTID_MENTOR_TEAM_REQUEST_NOTIFY_OTHERS, self.UpdateMentorTeamWaiting, self)
  self:AddCommonEvent(EVENTTYPE_MENTOR, EVENTID_MENTOR_PREMATCH_STATE, self.UpdateMentorPrematchState, self)
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_MATCH_UPDATE_TIME, self.OnUpdateMatching, self)
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_ON_MATCH_RES_OK, self.OnMatchResOK, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_LOBBY_SOCIAL_EDIT_STATUS, self.UpdateEditingState, self)
  self:AddCommonEvent(EVNETID_MATCH_NEW_GUIDE, EVENTID_MATCH_NEWBIE_CLICK_Entry, self.OnClickEntry, self)
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_ON_MATCH_OPTION_SAVE, self.OnMatchOptionsChange, self)
  self:AddCommonEvent(EVENTTYPE_NEXTDAY, EVENTID_NEXTDAY_ZERO, self.OnNextDayHandler, self)
  self:AddCommonEvent(EVENTTYPE_ACTION, EVENTID_START_BTN_ACTION, self.OnStartBtnAction, self)
  self:AddCommonEvent(EVENTTYPE_ACTION, EVENTID_GROWTH_PROJECT_DEPOT_GUIDE_MATCH, self.UpdateGrowthDepotGuideReLogin, self)
  self:AddCommonEvent(EVENTTYPE_ACTION, EVENTID_HIDE_MATCH_HAND_TIP, self.OnHideMatchHandTip, self)
  self:AddCommonEvent(EVENTTYPE_ACTION, EVENTID_ACTION_MATCH_EVENT, self.UpdateCDFinishDepotGuide, self)
  self:AddCommonEvent(EVENTTYPE_ACTION, EVENTID_NEWBIE_GUIDE_MATCH_NUM, self.UpdateMatchNumOnCloseBtn, self)
  self:AddControlEventByControl(self.UIRoot.Animation_Hand, "OnAnimationFinished", self.OnAnimationEnd, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_LOBBY_SOCIAL_PHOTO, self.UpdatePhoto, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_LOBBY_SHOW_SELECT_MODE, self.DoClickSelectModeEvent, self)
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_ON_MATCH_LT_GET_DATA, self.OnMatchLTGetData, self)
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_ON_MATCH_LT_SWITCHMODE, self.OnMatchLTSwitchMode, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_LOBBY_COME_BACK_FIRSTBATTLE_START_MATCH, self.ONFBStartMatch, self)
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_MATCH_CROSS_SUCCESS, self.UpDateCrossSuccess, self)
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_ON_SAME_LANGUAGE_MATCH_TIMEOUT, self.OnSameLanguageMatchTimeOut, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_MATCH_UGC_AUTOMATCH, self.OnClickEntry, self)
  self:AddCommonEvent(EVENTTYPE_LOGIN, EVENTID_QR_LOGIN_QRCODE_RESTRICT_CHANGE, self.OnQRCodeRestrictChange, self)
  self:AddCommonEvent(EVENTTYPE_OLD_WIDGET, EVENTID_ON_ALL_WIDGET_HIDE, self.OnWidgetHide, self)
  self:AddCommonEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_POST_SWITCH, self.OnModePostSwitch, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_PLAY_HALL_MATCHMOD_HOT_STAT_CHANGE, self.OnModHotStatChange, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_PLAY_HALL_ROOM_CREATE, self.OnUGCPlayHallRoomCreate, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_PLAY_HALL_ROOM_EXIT_ALL, self.OnUGCPlayHallRoomExit, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_PLAY_HALL_ROOM_AUTOSTART_INFO_CHANGE, self.OnRoomAutoStartInfoChange, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_PLAY_HALL_ROOM_PLAYER_CHANGE, self.OnMatchRoomPlayerChange, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_PENDING_MATCH_CANCEL, self.OnUGCPlayHallPendingMatchCancel, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_CHANGE_MOD_NOTIFY, self.OnMatchModSelectChange, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_STARTGAME_NEWPROCESS, self.OnUGCStartGame, self)
  self:AddCommonEvent(EVENTTYPE_PUFFER, EVENTID_PUFFER_DOWNLOADFINISH, self.OnMapDownloadFinish, self)
end
function UI_Match_Entry:UpdatePhoto(_, _, in_photo)
  if in_photo then
    self:Collapsed()
  else
    local logic_home_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_switch)
    local Lobby_Main_Control = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
    local page = Lobby_Main_Control.curPage
    if logic_home_switch:CheckHomeSwitchOpen() and page == ENUM_LobbyPageType.Left then
      return
    end
    self:SelfHitTestInvisible()
  end
end
function UI_Match_Entry:OnPostInitialize()
  log(bWriteLog and "UI_Match_Entry:OnPostInitialize")
  UI_Match_Entry.__super.OnPostInitialize(self)
  self._needInit = true
  self:SetEnterMetroTxMissionDesc()
end
function UI_Match_Entry:OnShow()
  log(bWriteLog and "UI_Match_Entry:OnShow")
  if MatchSystem.nMatchStatus ~= E_MatchStatus.Matching then
    collapse(self.UIRoot.WaitForMatch)
    collapse(self.UIRoot.TeammateMatch)
    collapse(self.UIRoot.SameLanguageMatch)
    self:SetWidgetVisible(self.UIRoot.Border_MatchInfo, false)
    self:SetWidgetVisible(self.UIRoot.Border_0, false)
    self:SetWidgetVisible(self.UIRoot.GridPanel_LTMatch, false)
    collapse(self.UIRoot.SizeBox_top)
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_highLeveTips, false)
    self:SetWidgetVisible(self.UIRoot.Common_Tips_Bg02_UIBP, false)
    self.MathInfoState = SHRINK
    self.bWaitForMatchShown = false
    self.bHighLevelTipsExpanded = false
    self.nMatchPanelState = ENUM_MatchPanelState.Collapsed
    self.UIRoot.Image_13:SetRenderAngle(0)
    local anim = self.UIRoot.Animation_ShrinkAndExpansion
    self:PlayUserWidgetAnimation(anim, 0, 1, SHRINK, 1)
  end
end
function UI_Match_Entry:SetEnterMetroTxMissionDesc()
  log(bWriteLog and "UI_Match_Entry:SetEnterMetroTxMissionDesc")
  local logic_mode_selection_for_umg = require("client.slua.logic.mode_selection.logic_mode_selection_for_umg")
  logic_mode_selection_for_umg.SetEnterMetroTxMissionDesc(self)
end
function UI_Match_Entry:OnModePostSwitch()
  log(bWriteLog and "UI_Match_Entry:OnModePostSwitch")
  if not self._needInit then
    return
  end
  self.bShowHistory = false
  self:InitUI()
  self:CheckAndAddEffect()
  self:CheckAndShowTips()
  local Utility = require("common.utility")
  local GameAutotest = Utility.GetGameInstanceSubsystemByName("AutoTestSubsystem")
  if slua.isValid(GameAutotest) and GameAutotest:IsAutoRunTestGame() and not GameAutotest:IsGAutomatorTest() then
    self.autoTestTimer = self:AddTimer(5, function()
      self:StartMatch()
      self:RemoveTimer(self.autoTestTimer)
      self.autoTestTimer = nil
    end)
  end
  local SeasonHandler = require("client.network.Protocol.SeasonHandler")
  SeasonHandler.send_query_challenge_info_req()
  local new_mode_entry_ui = self:CreateChildWindow(self.UIRoot.New_Mode, UIManager.UI_Config.lobby_mode_entry)
  new_mode_entry_ui:SetAutoSize(true)
  self.  self:UpdatePreBtn()
  self:RefreshHandGuide()
  local LogicUgcFilterTag = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUgcFilterTag)
  LogicUgcFilterTag:SetAllTagList()
  local logic_ugc_mode = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_mode)
  logic_ugc_mode:FriendPlayingReq()
  self._needInit = false
  local Lobby_Main_Control = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
  self:UpdateTeamCnt()
  self:UpdatePreBtn()
  if Lobby_Main_Control.curPage ~= ENUM_LobbyPageType.Mid then
    self:ShrinkMatchInfo()
  end
end
function UI_Match_Entry:UpdateEditingState(_, _, IsEditing)
  local logic_home_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_switch)
  if logic_home_switch:CheckHomeSwitchOpen() then
    return
  end
  self:SetWidgetVisibility(IsEditing and UEnums.ESlateVisibility.Collapsed or UEnums.ESlateVisibility.SelfHitTestInvisible)
end
function UI_Match_Entry:OnModePreSwitch(preStatus, currentStatus)
  log(bWriteLog and "[edward][match_entry] UI_Match_Entry:OnModePreSwitch, preStatus = " .. preStatus .. ", currentStatus = " .. currentStatus)
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  if not MatchModeMgrSystem.IsSocialIslandMode(true) then
    MatchSystem.ResetData()
  end
  self:ResetData()
end
function UI_Match_Entry:OnSwitchToPageStart(_, _, toPage)
  self.UIRoot.CanvasPanel_TeamCnt:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.CanvasPanel_Pre:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function UI_Match_Entry:OnSwitchToPageEnd(_, _, fromPage, toPage)
  self:UpdateTeamCnt()
  self:UpdatePreBtn()
  if fromPage ~= ENUM_LobbyPageType.Mid or toPage == ENUM_LobbyPageType.Left or toPage == ENUM_LobbyPageType.Right then
  end
end
function UI_Match_Entry:OnClose()
  log(bWriteLog and "[zwl][match_new_entry] UI_Match_Entry:OnClose")
  self.hideTipTimer = nil
  self.resetClickTipTimer = nil
  MatchSystem.bShowGuideMatchTips = false
  if self.tipsUI then
    self.tipsUI:Close()
    self.tipsUI = nil
  end
  if self.LTMatchAnimTimer then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(self.LTMatchAnimTimer)
    self.LTMatchAnimTimer = nil
  end
  if self.ugcPlayHallTimer then
    self:RemoveTimer(self.ugcPlayHallTimer)
    self.ugcPlayHallTimer = nil
  end
  UI_Match_Entry.__super.OnClose(self)
end
function UI_Match_Entry:InitUI()
  self:UpdateStatus()
  self:UpdateNewbieGuid()
  self:InitBattleRestirct()
end
function UI_Match_Entry:RefreshHandGuide()
  log(bWriteLog and "UI_Match_Entry:RefreshHandGuide")
  local logic_lobby_guide_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lobby_guide_manager)
  local bCanGuide = logic_lobby_guide_manager:CheckCanGuide_StartGameGuide()
  log(bWriteLog and "UI_Match_Entry:RefreshHandGuide bCanGuide = " .. tostring(bCanGuide))
  if not bCanGuide then
    return
  end
  local logic_newbie_guide_force_rank = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_guide_force_rank)
  local bForceRank = logic_newbie_guide_force_rank:NeedShowGuide()
  log(bWriteLog and "logic_lobby_guide_manager:RefreshHandGuide bForceRank = " .. tostring(bForceRank))
  if bForceRank then
    return false
  end
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  local bNeedMatchEntryGuide = growthprojectMgrB.CheckNeedMatchEntryGuide()
  log(bWriteLog and "UI_Match_Entry:RefreshHandGuide bNeedMatchEntryGuide = " .. tostring(bNeedMatchEntryGuide))
  if not bNeedMatchEntryGuide then
    return
  end
  log(bWriteLog and "UI_Match_Entry:RefreshHandGuide bNeedMatchEntryGuide start guide")
  self.UIRoot.Canvas_Panel_HandGuide:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self:PlayUserWidgetAnimation(self.UIRoot.Animation_Hand, 0, 0, 0, 1)
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  DataMgr.SetNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_MATCH_ENTRY_GUIDE, 1)
end
function UI_Match_Entry:OnHideMatchHandTip()
  log(bWriteLog and "UI_Match_Entry:OnHideMatchHandTip")
  self:ClearHandEffect()
end
function UI_Match_Entry:UpdateNewbieGuid()
  log(bWriteLog and "UI_Match_Entry:UpdateNewbieGuid")
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission(true) then
    return
  end
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  if LogicNewbie.IsNewbie() and (LogicNewbie.NeedShowNewbieGuide(20001) or LogicNewbie.NeedShowNewbieGuide(10031)) then
    UIManager.ShowUI(UIManager.UI_Config.newbie_lobby_match)
  end
end
function UI_Match_Entry:NeedShowActImg()
  log(bWriteLog and "UI_Match_Entry:NeedShowActImg")
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  local actData, _, _ = MatchModeMgrSystem.GetNewMatchModeData()
  if not actData or not actData.ImgUrl then
    return false, false
  end
  log(bWriteLog and "UI_Match_Entry:UpdateActivityMode imgUrl = " .. actData.ImgUrl)
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eMatchEntryActImgUrl)
  if not cfg or cfg.ID ~= actData.ID then
    return true, false
  else
    return false, true
  end
end
function UI_Match_Entry:UpdateMentorTeamWaiting(_, _, updateStatus)
  log(bWriteLog and "UI_Match_Entry:UpdateMentorTeamWaiting updateStatus = " .. tostring(updateStatus))
  if updateStatus then
    self:UpdateStatus()
  else
    local status = MatchSystem.nMatchStatus
    if status == E_MatchStatus.Ready then
      local MentorSystem = require("client.slua.logic.mentor.logic_mentor")
      if MentorSystem.mentor_team_waiting then
        self.UIRoot.WidgetSwitcher_State:SetActiveWidgetIndex(0)
        self.UIRoot.Text_State:SetText(LocUtil.LocalizeResFormat(8982, MentorSystem.mentor_team_waiting_time))
      end
    end
  end
end
function UI_Match_Entry:UpdateMentorPrematchState(_, _, updateStatus)
  log(bWriteLog and "UI_Match_Entry:UpdateMentorPrematchState updateStatus = " .. tostring(updateStatus))
  if updateStatus then
    self:UpdateStatus()
  else
    local status = MatchSystem.nMatchStatus
    if status == E_MatchStatus.Ready or status == E_MatchStatus.Not then
      local MentorSystem = require("client.slua.logic.mentor.logic_mentor")
      if MentorSystem.mentor_prematch_state then
        local root = self.UIRoot
        local TimeUtil = require("client.common.time_util")
        local timeStr = TimeUtil.FormatCountDownTime_DH_or_HMS_or_MS(MentorSystem.mentor_prematch_state_time)
        root.TextBlock_MatchingTime:SetText(timeStr)
      end
    end
  end
end
function UI_Match_Entry:UpdateMatchStyle_internal()
  if not MatchSystem.is_sync_match_process then
    log(bWriteLog and "UI_Match_Entry:UpdateMatchStyle_internal is_sync_match_process is false")
    return
  end
  local isConnecting = MatchSystem.isConnecting
  if not isConnecting then
    log(bWriteLog and "UI_Match_Entry.UpdateMatchStyle_internal network is disconnected")
    return
  end
  log(bWriteLog and "UI_Match_Entry:UpdateMatchStyle_internal")
  local match_progress_update = require("client.slua.umg.MainCity.Main.Match.match_progress_update")
  local root = self.UIRoot
  local WidgetSwitcher_Progress = root.WidgetSwitcher_Progress
  local progressText = root.UTRichTextBlock_209
  local matchText = root.TextBlock_Matching_New
  local estimateTimeText = root.UTRichTextBlock_210
  local estimateTimePanel = root.CanvasPanel_77
  if MatchSystem.ShowProgress then
    if MatchSystem.will_success then
      WidgetSwitcher_Progress:SetActiveWidgetIndex(1)
      local uObj_font = matchText.Font
      uObj_font.Size = match_progress_update.MatchSoonFontSize
      matchText:SetFont(uObj_font)
      matchText:SetText(LocUtil.GetLocalizeResStr(8075917))
      matchText:SetColorAndOpacity(match_progress_update.yellow)
    else
      WidgetSwitcher_Progress:SetActiveWidgetIndex(0)
      local processStr = match_progress_update.GetProgress()
      if processStr then
        progressText:SetText(processStr)
      end
      local nEstimateTime = MatchSystem.nEstimateTime or 0
      if 0 < nEstimateTime then
        estimateTimePanel:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        local TimeUtil = require("client.common.time_util")
        local estimateTimeStr = TimeUtil.FormatCountDownTime_DH_or_HMS_or_MS(MatchSystem.nEstimateTime)
        estimateTimeText:SetText(estimateTimeStr)
      else
        estimateTimePanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      end
    end
  else
    WidgetSwitcher_Progress:SetActiveWidgetIndex(1)
    local uObj_font = matchText.Font
    uObj_font.Size = match_progress_update.MatchFontSize
    matchText:SetFont(uObj_font)
    matchText:SetText(LocUtil.GetLocalizeResStr(7502))
    matchText:SetColorAndOpacity(match_progress_update.black)
  end
end
function UI_Match_Entry:InitMatchStyle()
  log(bWriteLog and "UI_Match_Entry:InitMatchStyle")
  local WidgetSwitcher_Matching = self.UIRoot.WidgetSwitcher_Matching
  if MatchSystem.is_sync_match_process then
    WidgetSwitcher_Matching:SetActiveWidgetIndex(1)
  else
    WidgetSwitcher_Matching:SetActiveWidgetIndex(0)
  end
end
function UI_Match_Entry:UpdateStatus()
  log(bWriteLog and "UI_Match_Entry:UpdateStatus")
  local root = self.UIRoot
  root.TextBlock_14:SetText(LocUtil.LocalizeResFormat(68193))
  root.TextBlock_Readying:SetText(LocUtil.GetLocalizeResStr(7503))
  root.Text_State:SetText(LocUtil.GetLocalizeResStr(7501))
  self:SetWidgetVisible(root.Button_Entry, true, true)
  local status = MatchSystem.nMatchStatus
  log(bWriteLog and "[DeanJYT] UI_Match_Entry:UpdateStatus MatchSystem.nMatchStatus = " .. tostring(MatchSystem.nMatchStatus))
  if status ~= ENUM_MatchStatus.Matching then
    local match_progress_update = require("client.slua.umg.MainCity.Main.Match.match_progress_update")
    match_progress_update.ClearProgressInfo()
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_highLeveTips, false, false)
    self.canShowBigBG = false
  end
  if status == ENUM_MatchStatus.Matching then
    self:InitMatchStyle()
  end
  self:ResetMatchUI()
  local UGCPlayHallRoom = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.UGCPlayHallRoom)
  if UGCPlayHallRoom then
    if UGCPlayHallRoom:GetRoomInfo() then
      log(bWriteLog and "UI_Match_Entry:UpdateStatus InitUGCPlayHallRoomShow")
      self:InitUGCPlayHallRoomShow()
      return
    else
      if self.ugcPlayHallTimer then
        self:RemoveTimer(self.ugcPlayHallTimer)
        self.ugcPlayHallTimer = nil
      end
      if UGCPlayHallRoom:CheckPendingMatchState() and not self:RefreshUGCMatchPendingShow() then
        return
      end
    end
  end
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  if LogicUGCMatch:HasUGCMatchInfo() and UGCPlayHallRoom and UGCPlayHallRoom:IsSystemOpen() then
    local ModID = tonumber(LogicUGCMatch:GetMatchModID())
    local HotStatCache = UGCPlayHallRoom:GetModHotStatByID(ModID)
    log(bWriteLog and "UI_Match_Entry:UpdateStatus InitModHotStatShow", ModID)
    self:InitModHotStatShow(HotStatCache)
  else
    self:InitModHotStatShow(nil)
  end
  if status == E_MatchStatus.Ready then
    local MentorSystem = require("client.slua.logic.mentor.logic_mentor")
    if MentorSystem.mentor_team_waiting then
      root.WidgetSwitcher_State:SetActiveWidgetIndex(0)
      root.Text_State:SetText(LocUtil.LocalizeResFormat(8982, MentorSystem.mentor_team_waiting_time))
    elseif TeamUpNewSystem.IsTeamLeader() then
      if TeamUpNewSystem.GetTeamNum() > 1 and not TeamUpNewSystem.IsEverybodyReady() then
        self:RefreshTeamReadyNum(root)
      else
        root.WidgetSwitcher_State:SetActiveWidgetIndex(3)
      end
    elseif not self:CheckMemberMatchRestrict(root) then
      root.WidgetSwitcher_State:SetActiveWidgetIndex(1)
      root.TextBlock_Readying:SetText(LocUtil.GetLocalizeResStr(7503))
    end
  elseif status == E_MatchStatus.Matching then
    root.WidgetSwitcher_State:SetActiveWidgetIndex(2)
    collapse(self.UIRoot.Panel_Mode_Selected)
  elseif status == E_MatchStatus.Success then
    root.WidgetSwitcher_State:SetActiveWidgetIndex(0)
    root.Text_State:SetText(LocUtil.GetLocalizeResStr(7504))
  elseif TeamUpNewSystem.IsTeamLeader() then
    if TeamUpNewSystem.GetTeamNum() > 1 and not TeamUpNewSystem.IsEverybodyReady() then
      self:RefreshTeamReadyNum(root)
    elseif self:IsFreeInOutState() then
      root.WidgetSwitcher_State:SetActiveWidgetIndex(6)
      root.TextBlock_JoinGame:SetText(LocUtil.GetLocalizeResStr(78430))
    else
      root.WidgetSwitcher_State:SetActiveWidgetIndex(3)
    end
    log(bWriteLog and "[DeanJYT] UI_Match_Entry:UpdateStatus IsTeamLeader")
    self:SetWidgetVisible(self.UIRoot.GridPanel_LTMatch, false)
    self:SetWidgetVisible(self.UIRoot.Border_0, false)
    self:UpdateWaitForMatchBackground()
    EventSystem:postEvent(EVENTTYPE_SKILL_SELECTION, EVENTID_SKILL_SELECTION_MODE_OTHER_TIPS_HIDE)
  elseif not self:CheckMemberMatchRestrict(root) then
    root.WidgetSwitcher_State:SetActiveWidgetIndex(0)
    log(bWriteLog and "[DeanJYT] UI_Match_Entry:UpdateStatus NOT IsTeamLeader")
    root.Text_State:SetText(LocUtil.GetLocalizeResStr(7501))
  end
  if status == E_MatchStatus.Matching then
    root.ScaleBox_EstimateTime:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
    local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
    if MatchModeMgrSystem.bIsMatchingSocialIsland then
      root.TextBlock_Matching:SetText(LocUtil.GetLocalizeResStr(10123))
    else
      root.TextBlock_Matching:SetText(LocUtil.GetLocalizeResStr(7502))
    end
    if LogicMatchEntry.FigureWaitForMatch() then
      show(self.UIRoot.WaitForMatch)
      self:UpdateWaitForMatchBackground()
      self:WaitForMatch()
      self:ProcessEnterMatch(true)
    else
      LogicMatchEntry.CalculateMatchDisplay()
      self:SameLanguageMatch()
      self:TeammateMatch()
      self:ProcessEnterMatch()
    end
    IsTeamLeader = TeamUpNewSystem.IsTeamLeader()
    self:OnUpdateMatching()
    local UIUtil = require("client.common.ui_util")
    root.Panel_laodaixin:SetWidgetVisibility(UIUtil.BoolToVisible(LobbySystem.isMentorMatch, true))
  else
    local MentorSystem = require("client.slua.logic.mentor.logic_mentor")
    if (status == E_MatchStatus.Ready or status == E_MatchStatus.Not) and MentorSystem.mentor_prematch_state then
      root.WidgetSwitcher_State:SetActiveWidgetIndex(2)
      root.ScaleBox_EstimateTime:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
      local TimeUtil = require("client.common.time_util")
      local timeStr = TimeUtil.FormatCountDownTime_DH_or_HMS_or_MS(MentorSystem.mentor_prematch_state_time)
      root.TextBlock_MatchingTime:SetText(timeStr)
      root.TextBlock_Matching:SetText(LocUtil.LocalizeResFormat(10464))
      root.Panel_laodaixin:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
  end
  if self.preMatchState == E_MatchStatus.Matching then
    self:ProcessLeaveMatching()
  end
  self:UpdateTeamCnt()
  self.preMatchState = status
  if not MatchSystem.bIsSwitchServerShowed and 0 < MatchSystem.nSwitchServerTime then
    self.UIRoot.CanvasPanel_JK:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  self:SetEnterMetroTxMissionDesc()
end
function UI_Match_Entry:OnMapDownloadFinish(_, _, eventData)
  if not eventData then
    return
  end
  local PufferConst = require("client.slua.logic.download.puffer_const")
  if eventData.downloadType ~= PufferConst.ENUM_DownloadType.MAP then
    return
  end
  log(bWriteLog and "[DeanJYT] UI_Match_Entry:OnMapDownloadFinish, mapKey:", eventData.mapKey)
  self:UpdateStatus()
end
function UI_Match_Entry:OnCheckTeamMatchState()
  log(bWriteLog and "UI_Match_Entry:OnCheckTeamMatchState")
  self:UpdateStatus()
end
function UI_Match_Entry:CheckMemberMatchRestrict(root)
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  log(bWriteLog and "UI_Match_Entry:CheckMemberMatchRestrict IsInXMission " .. tostring(LogicTxMissionMain.IsInXMission(true)))
  if LogicTxMissionMain.IsInXMission(true) then
    log(bWriteLog and "UI_Match_Entry:CheckMemberMatchRestrict IsInXMission return false")
    return false
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  log(bWriteLog and "UI_Match_Entry:CheckMemberMatchRestrict hasSelectTxMission " .. tostring(logic_mode_selection.hasSelectTxMission))
  if logic_mode_selection and logic_mode_selection.hasSelectTxMission then
    log(bWriteLog and "UI_Match_Entry:CheckMemberMatchRestrict hasSelectTxMission return false")
    return false
  end
  local bMapNotDownloaded = false
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local LogicUGCMulti = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMulti)
  if LogicUGCMulti and LogicUGCMulti.bIsBundleMatch then
    local bundleState = LogicUGCMulti:GetResState()
    bMapNotDownloaded = bundleState ~= PufferConst.ENUM_DownloadState.Done
  else
    local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
    if LogicUGCMatch:HasUGCMatchInfo() then
      local matchInfo = LogicUGCMatch:GetMatchInfo()
      if matchInfo and matchInfo.mod_id then
        local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
        local cacheMod = LogicUGC:GetModByAllCache(matchInfo.mod_id)
        if cacheMod and cacheMod.pub_mod_meta then
          local resManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCResManager)
          local modInfo = cacheMod.pub_mod_meta
          local state = PufferConst.ENUM_DownloadState.Not
          if modInfo.mod_id and modInfo.mod_id > 0 then
            state = resManager:GetResState(resManager.DownloaderType.ModCopy, modInfo)
          else
            state = resManager:GetResState(resManager.DownloaderType.MyWork, modInfo)
          end
          bMapNotDownloaded = state ~= PufferConst.ENUM_DownloadState.Done
        else
          bMapNotDownloaded = true
        end
      else
        bMapNotDownloaded = true
      end
    else
      local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
      local _, viewId, viewIds = logic_mode_selection:GetCurSelectInfo()
      local allViewIds = viewIds and next(viewIds) and viewIds or viewId and {viewId} or nil
      if allViewIds then
        local logic_mode_map_download = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_map_download)
        local mapKeyDict = {}
        for _, vid in ipairs(allViewIds) do
          local keyList = logic_mode_map_download:GetMapKeyListByViewId(vid)
          if keyList then
            for _, key in ipairs(keyList) do
              mapKeyDict[key] = true
            end
          end
        end
        local mapKeyList = {}
        for key, _ in pairs(mapKeyDict) do
          table.insert(mapKeyList, key)
        end
        if next(mapKeyList) then
          local mapState = logic_mode_map_download:GetMapListState(mapKeyList)
          bMapNotDownloaded = mapState ~= PufferConst.ENUM_DownloadState.Done
        end
      end
    end
  end
  local bSegmentLimit = false
  local logic_team_match_state = require("client.slua.logic.teamup.logic_team_match_state")
  local selfUID = TeamUpNewSystem.GetSelfUID()
  if logic_team_match_state:IsSegmentLimit(selfUID) then
    bSegmentLimit = true
  end
  if bMapNotDownloaded or bSegmentLimit then
    root.WidgetSwitcher_State:SetActiveWidgetIndex(1)
    root.TextBlock_Readying:SetText(LocUtil.GetLocalizeResStr(7501))
    self:SetWidgetVisible(root.Button_Entry, true, false)
    if MatchSystem.nMatchStatus == E_MatchStatus.Ready then
      self:CancelReady()
    end
    log(bWriteLog and "UI_Match_Entry:CheckMemberMatchRestrict restrict found, mapNotDownloaded=" .. tostring(bMapNotDownloaded) .. " segmentLimit=" .. tostring(bSegmentLimit))
    return true
  end
  return false
end
function UI_Match_Entry:RefreshTeamReadyNum(root)
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local readyCount, totalCount = TeamUpNewSystem.GetTeamReadyInfo()
  root.WidgetSwitcher_State:SetActiveWidgetIndex(5)
  root.TextBlock_Num:SetText(LocUtil.LocalizeResFormat(805947, readyCount, totalCount))
end
function UI_Match_Entry:UpdateTeamCnt()
  log(bWriteLog and "UI_Match_Entry:UpdateTeamCnt")
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local _, curSelectViewId = logic_mode_selection:GetCurSelectInfo()
  if not curSelectViewId then
    return
  end
  local playerNum = logic_mode_selection:GetModeMaxTeamNum()
  local cnt = TeamUpNewSystem.GetTeamNum()
  self.UIRoot.CanvasPanel_TeamCnt:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  local myColor = FLinearColor(1, 1, 1, 1)
  if 1 < cnt then
    local Lobby_Main_Control = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
    if Lobby_Main_Control.curPage == ENUM_LobbyPageType.Left or Lobby_Main_Control.curPage == ENUM_LobbyPageType.Right then
      self.UIRoot.CanvasPanel_TeamCnt:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      self.UIRoot.Text_TeamCnt:SetText(LocUtil.LocalizeResFormat(6830, cnt, playerNum))
      if TeamUpNewSystem.IsEverybodyReady() then
        myColor = FLinearColor(0.127, 1, 0, 1)
      end
    end
  end
  self.UIRoot.Image_TeamFlag:SetColorAndOpacity(myColor)
end
function UI_Match_Entry:OnMatchModSelectChange()
  log(bWriteLog and "UI_Match_Entry:OnMatchModSelectChange")
  self:UpdatePreBtn()
  local UGCPlayHallRoom = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.UGCPlayHallRoom)
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  if LogicUGCMatch:HasUGCMatchInfo() and UGCPlayHallRoom and UGCPlayHallRoom:IsSystemOpen() then
    local ModID = tonumber(LogicUGCMatch:GetMatchModID())
    local HotStatCache = UGCPlayHallRoom:GetModHotStatByID(ModID)
    log(bWriteLog and "UI_Match_Entry:OnMatchModSelectChange InitModHotStatShow", ModID)
    self:InitModHotStatShow(HotStatCache)
  else
    self:InitModHotStatShow(nil)
  end
  self:UpdateStatus()
end
function UI_Match_Entry:IsFreeInOutState()
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  if not LogicUGCMatch or not LogicUGCMatch.IsFreeInOutMatch then
    return false
  end
  return LogicUGCMatch:IsFreeInOutMatch()
end
function UI_Match_Entry:UpdatePreBtn()
  log(bWriteLog and "UI_Match_Entry:UpdatePreBtn")
  local Lobby_Main_Control = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
  if not self.UIRoot then
    return
  end
  if Lobby_Main_Control.curPage == ENUM_LobbyPageType.Left or Lobby_Main_Control.curPage == ENUM_LobbyPageType.Right then
    self.UIRoot.CanvasPanel_Pre:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local modeInfo = logic_mode_selection:GetFilterInfo()
  local matchId, viewId, viewIds = logic_mode_selection:GetCurSelectInfo()
  if not viewId then
    log(bWriteLog and "[COLE] UI_Match_Entry:UpdatePreBtn get nil view id")
    return
  end
  local tabList = logic_mode_selection:GetMenuListByViewID(viewId)
  if tabList and tabList[1] and (tabList[1] == 220 or tabList[1] == 130) then
    if self.UIRoot.CanvasPanel_Pre:GetVisibility() == UEnums.ESlateVisibility.Collapsed then
      self:PlayUserWidgetAnimation(self.UIRoot.Anim_Weapon, 0, 1, 0, 1)
    end
    self.UIRoot.CanvasPanel_Pre:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot.CanvasPanel_Pre:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  self:RefreshQRCodeBattleRestrict()
end
function UI_Match_Entry:OnUGCStartGame()
  log(bWriteLog and "UI_Match_Entry:OnUGCStartGame")
  self:OnClickEntry()
end
function UI_Match_Entry:OnUpdateMatching()
  log(bWriteLog and "UI_Match_Entry:OnUpdateMatching")
  self:UpdateMatchingTime()
  self:WaitForMatch()
  local logic_long_time_match = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_long_time_match)
  if not logic_long_time_match:GetIsShowLTMatch() or self.nMatchPanelState == ENUM_MatchPanelState.LTExpanded then
    self:TeammateMatch()
  end
  self:ReqLTMatch()
  self:CheckMatchUpdateTips()
end
function UI_Match_Entry:IsNeedCrossSever(nMatchTime)
  log(bWriteLog and "UI_Match_Entry:IsNeedCrossSever nMatchTime = " .. tostring(nMatchTime))
  if DataMgr.JPKRMatchServerOn and 0 < nMatchTime and 0 < MatchSystem.nSwitchServerTime and nMatchTime % MatchSystem.nSwitchServerTime == 0 then
    log(bWriteLog and "UI_Match_Entry:IsNeedCrossSever true")
    return true
  end
  return false
end
function UI_Match_Entry:GetEstimateTimeCfg(estimateTime)
  log(bWriteLog and "UI_Match_Entry:IsNeedCrossSever estimateTime = " .. tostring(estimateTime))
  for i, v in pairs(CDataTable.GetTable("EstimateTimeTable")) do
    if estimateTime <= 0 and v.EstimateTimeMin == -1 then
      return v
    end
    if estimateTime >= v.EstimateTimeMin and estimateTime <= v.EstimateTimeMax then
      return v
    end
  end
  return nil
end
function UI_Match_Entry:UpdateMatchingTime()
  log(bWriteLog and "UI_Match_Entry:UpdateMatchingTime123213")
  local matchingTime = MatchSystem.nMatchingTime
  local estimateTime = MatchSystem.nEstimateTime
  if not self.UIRoot then
    return
  end
  self:UpdateMatchStyle_internal()
  local LogicModeMatchProgress = require("client.slua.logic.mode_selection.LogicModeMatchProgress")
  local canShow, tipsLocID = LogicModeMatchProgress.CanShowHighLevelMatchTips()
  self.UIRoot.UTRichTextBlock_highLevelTips:SetText(LocUtil.GetLocalizeResStr(tipsLocID))
  local logic_long_time_match = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_long_time_match)
  if not logic_long_time_match:GetIsShowLTMatch() or self.nMatchPanelState == ENUM_MatchPanelState.LTExpanded then
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_highLeveTips, canShow, false)
  end
  if canShow and not self.bHighLevelTipsExpanded then
    self.bHighLevelTipsExpanded = true
    if not logic_long_time_match:GetIsShowLTMatch() then
      show(self.UIRoot.SizeBox_top)
      self:SetWidgetVisible(self.UIRoot.Common_Tips_Bg02_UIBP, true)
      self:UpdateWaitForMatchBackground()
      self:ExpandMatchInfo()
    elseif self.nMatchPanelState ~= ENUM_MatchPanelState.LTExpanded then
      self.MathInfoState = SHRINK
      self.UIRoot.Image_13:SetRenderAngle(0)
    end
  end
  log(bWriteLog and "UI_Match_Entry:UpdateMatchingTime matchingTime = " .. tostring(matchingTime) .. " estimateTime = " .. tostring(estimateTime))
  local TimeUtil = require("client.common.time_util")
  local timeStr = TimeUtil.FormatCountDownTime_DH_or_HMS_or_MS(matchingTime, true)
  local root = self.UIRoot
  root.TextBlock_MatchingTime:SetText(timeStr)
  root.TextBlock_53:SetText(timeStr)
  if not LogicMatchEntry.IsShowWaitForMatch() then
    local cfg = self:GetEstimateTimeCfg(estimateTime)
    if cfg then
      if matchingTime >= cfg.WaitShowEstimateTime1 then
        root.ScaleBox_EstimateTime:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        local estimateTimeStr
        if matchingTime >= cfg.WaitShowEstimateTime2 and 0 < cfg.WaitTips2 then
          estimateTimeStr = LocUtil.GetLocalizeResStr(cfg.WaitTips2)
        elseif 0 < cfg.WaitTips1 then
          estimateTimeStr = LocUtil.GetLocalizeResStr(cfg.WaitTips1)
        else
          estimateTimeStr = TimeUtil.FormatCountDownTime_DH_or_HMS_or_MS(estimateTime)
          estimateTimeStr = LocUtil.LocalizeResFormat(35013, estimateTimeStr)
        end
        root.UTRichTextBlock_RemainingTime:SetText(estimateTimeStr)
        self:SetWidgetVisible(root.UTRichTextBlock_RemainingTime, true)
      else
        root.UTRichTextBlock_RemainingTime:SetText("")
        self:SetWidgetVisible(root.UTRichTextBlock_RemainingTime, false)
      end
      if 0 < estimateTime then
        local almost_match_time = CDataTable.GetTableData("CancelMatchParams", "almost_match_time").Value
        if almost_match_time >= estimateTime - matchingTime then
          local almost_match_key = CDataTable.GetTableData("CancelMatchParams", "almost_match_key").Value
          local str = LocUtil.GetLocalizeResStr(almost_match_key)
          root.ScaleBox_EstimateTime:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
          root.UTRichTextBlock_RemainingTime:SetText(str)
          self:SetWidgetVisible(root.UTRichTextBlock_RemainingTime, true)
        end
        local match_show_wait_time = CDataTable.GetTableData("CancelMatchParams", "match_show_wait_time").Value
        if match_show_wait_time <= matchingTime - (estimateTime - cfg.WaitShowEstimateTime1) then
          local match_show_wait_key = CDataTable.GetTableData("CancelMatchParams", "match_show_wait_key").Value
          local str = LocUtil.GetLocalizeResStr(match_show_wait_key)
          root.ScaleBox_EstimateTime:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
          root.UTRichTextBlock_RemainingTime:SetText(str)
          self:SetWidgetVisible(root.UTRichTextBlock_RemainingTime, true)
        end
      end
    end
  end
  if IsTeamLeader and not MatchSystem.bIsSwitchServerShowed and self:IsNeedCrossSever(matchingTime) then
    local state = MatchSystem.GetCrossMatchState()
    if state == 1 then
      MatchSystem.bIsSwitchServerShowed = true
      UIManager.ShowUI(UIManager.UI_Config.Cross_Server_Popup)
    end
  end
end
function UI_Match_Entry:UpdateSkin(skinID)
  log(bWriteLog and "[edward][match_entry] UI_Match_Entry:UpdateSkin, skinID = " .. tostring(skinID))
  self.nSkinID = skinID or C_SkinID
  local root = self.UIRoot
  local imagePath, slateColor, skinEffectIndex
  local skinKey = GetSkinStyleID(self.nSkinID)
  local config
  if config then
    if config.Image1Path ~= "" then
      imagePath = config.Image1Path
    else
      imagePath = C_NormalButtonImagePath
    end
    if config.Text1RGBA ~= "" then
      local StringUtil = require("common.string_util")
      local rgba = StringUtil.Split(config.Text1RGBA, ";")
      for i, v in ipairs(rgba) do
        v = tonumber(v)
      end
      slateColor = FSlateColor(FLinearColor(rgba[1], rgba[2], rgba[3], rgba[4]))
    else
      slateColor = FSlateColor(FLinearColor(1, 1, 1, 1))
    end
    if config.Image2Path ~= "" then
      skinEffectIndex = tonumber(config.Image2Path)
    else
      skinEffectIndex = 0
    end
  else
    imagePath = C_NormalButtonImagePath
    slateColor = FSlateColor(FLinearColor(1, 1, 1, 1))
    skinEffectIndex = 0
  end
  self:SetTexture(root.Image_Button, imagePath)
  root.TextBlock_Matching:SetColorAndOpacity(slateColor)
end
function UI_Match_Entry:InitBattleRestirct()
  log(bWriteLog and "UI_Match_Entry:InitBattleRestirct")
  self:RefreshQRCodeBattleRestrict()
end
function UI_Match_Entry:RefreshQRCodeBattleRestrict()
  log(bWriteLog and "UI_Match_Entry:RefreshQRCodeBattleRestrict")
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  local isRestrictBattleAll = QRcodeRestrictManager:IsRestrictBatlleAll()
  if not isRestrictBattleAll then
    local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
    local matchMode = logic_mode_selection:GetCurSelectInfo()
    if logic_mode_selection:IsClassicRankMode(matchMode) and QRcodeRestrictManager:IsRestrictBatlleRank() then
      self:SetWidgetVisible(self.UIRoot.Button_Lock, true, true)
      return
    end
  end
  self:SetWidgetVisible(self.UIRoot.Button_Lock, isRestrictBattleAll, true)
end
function UI_Match_Entry:RefreshHistory(bShow)
  log(bWriteLog and "UI_Match_Entry:RefreshHistory bShow = " .. tostring(bShow))
  local LobbyMidMessageUIBP, LobbyExtraTeamUIBP
  local lobbyMain = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  if lobbyMain then
    LobbyMidMessageUIBP = lobbyMain:GetChildUI(UIManager.UI_Config.Lobby_Mid_Message_UIBP)
    LobbyExtraTeamUIBP = lobbyMain:GetChildUI(UIManager.UI_Config.team_extra_main)
  end
  if bShow then
    self.bShowHistory = true
    show(self.UIRoot.Button_Mask)
    if LobbyMidMessageUIBP then
      LobbyMidMessageUIBP:HideVerticalButtonList()
    end
    if LobbyExtraTeamUIBP then
      LobbyExtraTeamUIBP:Collapsed()
    end
  else
    self.bShowHistory = false
    collapse(self.UIRoot.Button_Mask)
    if LobbyMidMessageUIBP then
      LobbyMidMessageUIBP:ShowVerticalButtonList()
    end
    if LobbyExtraTeamUIBP then
      LobbyExtraTeamUIBP:SelfHitTestInvisible()
    end
  end
end
function UI_Match_Entry:PlayEnterAnimation()
  log(bWriteLog and "UI_Match_Entry:PlayEnterAnimation")
  self:PlayUserWidgetAnimation(self.UIRoot.DX_Transitions_Enter, 0, 1, 0, 1)
end
function UI_Match_Entry:ResetData()
  log(bWriteLog and "[edward][match_entry] UI_Match_Entry:ResetData")
  self:RemoveAllTimer()
  self.hideTipTimer = nil
  self.resetClickTipTimer = nil
  self.bShowTextTip = false
  self.bClickTipButton = false
  self.nConfirmCloseTime = 0
  self.bShowPloyTextTip = false
end
function UI_Match_Entry:StartMatch(isForce)
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  log(bWriteLog and "[edward][match_entry] UI_Match_Entry:StartMatch")
  local TournamentsManager = require("client.slua.logic.tournament.TournamentsManager")
  if TournamentsManager.LobbyMatchCheck() then
    log(bWriteLog and "[edward][match_entry] UI_Match_Entry:StartMatch, Return by TournamentsManager")
    return
  end
  gem_report_utils.ReportBtnClickEvent(gem_report_utils.SubEventName_MatchStartGame)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.MatchStartGame)
  local LogicTeamUpSideBar = require("client.slua.logic.lobby.logic_teamup_side_bar")
  LogicTeamUpSideBar.CloseTeamUpSideBar()
  self:ResetData()
  local function StartMatchCallback()
    local newbieGuideManager = require("client.logic.newbie_manager.newbie_guide_manager")
    if newbieGuideManager.NeedPopModTip() then
      local teamNum = TeamUpNewSystem.GetTeamNum()
      if 1 < teamNum then
        log(bWriteLog and "[boteliu][match_entry] UI_Match_Entry:StartMatchCallback, teamNum > 1")
        newbieGuideManager.SetModTip()
      else
        log(bWriteLog and "[boteliu][match_entry] UI_Match_Entry:StartMatchCallback, show mod tip")
        newbieGuideManager.ShowModTip(StartMatchCallback)
        return
      end
    end
    log(bWriteLog and "[edward][match_entry] StartMatchCallback, \229\188\128\229\167\139\229\140\185\233\133\141")
    MatchSystem.bShowMatchTimeoutNotice = false
    MatchSystem.SetSameLanguageMatchTimeOut(false)
    BattleResult.IgnoreDSError = false
    local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
    local LogicUGCMulti = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMulti)
    if LogicUGCMatch:HasUGCMatchInfo() then
      local editMatchInfo = LogicUGCMatch:GetEditMatchInfo()
      if editMatchInfo then
        local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
        local bInTeam = TeamUpNewSystem.IsInTeam()
        local LogicUGCCRUD = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCCRUD)
        if bInTeam then
          LogicUGCCRUD:EnterTeamCreate(editMatchInfo.slot, editMatchInfo.base.template_id)
        else
          LogicUGCCRUD:ReqStartEditGame(editMatchInfo.slot, true)
        end
      else
        LogicUGCMatch:ReqStartGame("Lobby")
      end
    elseif LogicUGCMulti.bIsBundleMatch then
      LogicUGCMulti:StartMatch()
    else
      LobbySystem.on_start_match_req()
    end
    local corp_fight = require("client.slua.logic.corps.logic_corps_fight")
    if corp_fight.CheckShowFightBeginTip(MatchModeMgrSystem.nSelectMatchID) then
      corp_fight.ShowTipUI(LocUtil.GetLocalizeResStr(23763))
    end
  end
  if TeamUpNewSystem.IsInOneMoreGameTeam() then
    local title = LocUtil.GetLocalizeResStr(101001)
    local msg = LocUtil.GetLocalizeResStr(8028)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, title, msg, StartMatchCallback)
    return
  end
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local bIsBLUEHOLE = Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE
  log(bWriteLog and "UI_Match_Entry:StartMatch bIsBLUEHOLE = " .. tostring(bIsBLUEHOLE))
  if not ZoneSystem.nChooseZoneID or ZoneSystem.nChooseZoneID == 0 then
    if GlobalData.IsJapanOrKorea() then
      ZoneSystem.on_select_zone_req(6)
      StartMatchCallback()
    elseif bIsBLUEHOLE then
      ZoneSystem.on_select_zone_req(3)
      StartMatchCallback()
    else
      local ShowZoneOption = function()
        UIManager.ShowUI(UIManager.UI_Config.Setting_ChangeServer, function()
        end)
      end
      local title = LocUtil.GetLocalizeResStr(101001)
      local msg = LocUtil.GetLocalizeResStr(7568)
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.Show(2, title, msg, ShowZoneOption)
    end
    return
  end
  local logic_zone_delay = require("client.slua.logic.match.logic_zone_delay")
  local isChoosingZoneAccess = logic_zone_delay.IsChoosingZoneAccess()
  local isMatchVersion = Client.IsMatchVersion()
  if isChoosingZoneAccess or isForce or bIsBLUEHOLE or isMatchVersion then
    StartMatchCallback()
  else
    logic_zone_delay.ShowDelayTips(StartMatchCallback)
  end
end
function UI_Match_Entry:CancelMatch()
  log(bWriteLog and "[edward][match_entry] UI_Match_Entry:CancelMatch")
  LobbySystem.on_match_cancel_req()
end
function UI_Match_Entry:ReadyMatch()
  log(bWriteLog and "[edward][match_entry] UI_Match_Entry:ReadyMatch")
  local reqStatus = E_MatchStatus.Ready
  log(bWriteLog and "request switch my status to : " .. reqStatus)
  local TeamupHandler = require("client.network.Protocol.TeamupHandler")
  local DeviceOSInfo = require("client.logic.data.data_device_os")
  DeviceOSInfo.getDeviceOSInfo()
  TeamupHandler.send_team_change_member_status_request(reqStatus, DeviceOSInfo.InfoList)
end
function UI_Match_Entry:CancelReady()
  log(bWriteLog and "[edward][match_entry] UI_Match_Entry:CancelReady")
  local reqStatus = E_MatchStatus.Not
  log(bWriteLog and "request switch my status to : " .. reqStatus)
  local TeamupHandler = require("client.network.Protocol.TeamupHandler")
  local DeviceOSInfo = require("client.logic.data.data_device_os")
  DeviceOSInfo.getDeviceOSInfo()
  TeamupHandler.send_team_change_member_status_request(reqStatus, DeviceOSInfo.InfoList)
end
function UI_Match_Entry:OnCheckAllMapPakResult(bOK)
  log(bWriteLog and "UI_Match_Entry:OnCheckAllMapPakResult bOK = " .. tostring(bOK))
  if bOK then
    self:OnClickEntryInternal()
  end
end
function UI_Match_Entry:OnClickCurMode()
  self:PlayAudio(sound_config.popup_v1)
  if LobbySystem.isInMatch then
    log(bWriteLog and "[edward][match_new_entry] UI_Match_Entry:OnClickCurMode, is matching!!!")
    ShowNotice(110014)
    return
  end
  local XMissionSystem = require("client.slua.logic.TxMission.logic_xmission_main")
  if XMissionSystem.IsInXMission(true) then
    return
  end
  if self.bShowHistory then
    self:RefreshHistory(false)
  end
end
function UI_Match_Entry:UpdateGrowthDepotGuideReLogin()
  log(bWriteLog and "UI_Match_Entry:UpdateGrowthDepotGuideReLogin")
  local logic_lobby_guide_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lobby_guide_manager)
  local bCanGuide = logic_lobby_guide_manager:CheckCanGuide_StartGameGuide()
  log(bWriteLog and "UI_Match_Entry:UpdateGrowthDepotGuideReLogin bCanGuide = " .. tostring(bCanGuide))
  if not bCanGuide then
    return
  end
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  local DoFirstMatch = growthprojectMgrB.DoFirstMatch
  log(bWriteLog and "[qintong] UI_Match_Entry.UpdateGrowthDepotGuideReLogin DoFirstMatch =" .. tostring(DoFirstMatch))
  if DoFirstMatch then
    local logic_newbie_guide_force_rank = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_guide_force_rank)
    if logic_newbie_guide_force_rank:NeedShowGuide() then
      log_warning(bWriteLog and "Lobby_Mid_Activity_UIBP:UpdateXmissionGuide return IsInNewbieForceRankABTest")
      logic_newbie_guide_force_rank:StartGuide()
      return
    end
    local newbie_guide_util = require("client.slua.logic.growth_project.newbie_guide_util")
    local mcNewbieActivityTip = newbie_guide_util.GetMCNewbieActivityTip()
    if mcNewbieActivityTip then
      log_warning(bWriteLog and "Lobby_Mid_Activity_UIBP:UpdateXmissionGuide return mcNewbieActivityTip")
      return
    end
    local isInJKABTest = newbie_guide_util.IsInJapanKoreaNewbieABTest()
    if isInJKABTest then
      log_warning(bWriteLog and "Lobby_Mid_Activity_UIBP:UpdateXmissionGuide return isInJKABTest")
      return
    end
    logic_connection_waiting:Show(0, false)
    local time_ticker = require("common.time_ticker")
    local timer = time_ticker.AddTimerOnce(1, function()
      logic_connection_waiting:Hide(0)
    end)
    self:AddTimer(1, function()
      local useNewGuide = LobbySystem.CheckUseNewGuide()
      local cb = function()
        self:OnClickEntry()
        if useNewGuide then
          self:SetWidgetVisible(self.UIRoot.GuidePanel, false)
        end
      end
      local LogicNewbie = require("client.logic.newbie.logic_newbie")
      local isFirstGame = LogicNewbie.newbieTotalGameCnt == 0
      log(bWriteLog and "UI_Match_Entry:UpdateGrowthDepotGuideReLogin. LogicNewbie.newbieTotalGameCnt = " .. tostring(LogicNewbie.newbieTotalGameCnt))
      if useNewGuide then
        self:SetWidgetVisible(self.UIRoot.GuidePanel, true, isFirstGame)
        self.UIRoot.GuideTip:SetText(LocUtil.GetLocalizeResStr(27323))
        if isFirstGame then
          self:PlayUserWidgetAnimation(self.UIRoot.Animation_Mask, 0, 1, 0, 1)
        end
        self:PlayUserWidgetAnimation(self.UIRoot.Animation_Hand_Loop, 0, 0, 0, 1)
        self:AddOnClickedEventByControl(self.UIRoot.GuideBtn, cb)
      else
        local ui = UIManager.GetUI(UIManager.UI_Config.NewbieGuide_UIBP)
        if ui then
          UIManager.CloseUI(UIManager.UI_Config.NewbieGuide_UIBP)
        end
        local txt = LocUtil.GetLocalizeResStr(12752)
        local ui_show_queue_config = require("client.common.uibase.ui_show_queue_config")
        local ParamTable = ui_show_queue_config.GetParamTable(nil, "IsLobbyPageMid")
        UIManager.ShowUI(UIManager.UI_Config.NewbieGuide_UIBP, 2, txt, self.UIRoot.Button_Entry, cb, true, 2, not isFirstGame, not isFirstGame, nil, nil, nil, nil, nil, ParamTable)
      end
    end)
    growthprojectMgrB.DoFirstMatch = false
  end
end
function UI_Match_Entry:UpdateCDFinishDepotGuide()
  log(bWriteLog and "UI_Match_Entry:UpdateCDFinishDepotGuide")
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  self:SetWidgetVisible(self.UIRoot.Image_11, not growthprojectMgrB.CanntClickMatch)
end
function UI_Match_Entry:UpdateMatchNumOnCloseBtn()
  log(bWriteLog and "UI_Match_Entry:UpdateMatchNumOnCloseBtn")
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  if LogicNewbie.newbieTotalGameCnt == 0 then
    self.UIRoot.Image_11:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    self.UIRoot.Image_11:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
end
function UI_Match_Entry:OnClickEntryRestrict()
  log(bWriteLog and "UI_Match_Entry:OnClickEntryRestrict")
  self:PlayAudio(sound_config.click_v1)
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  QRcodeRestrictManager:ShowRestrictTips()
end
function UI_Match_Entry:GotoTxMissionLobby()
  log(bWriteLog and "UI_Match_Entry:GotoTxMissionLobby")
  local logic_mode_selection_for_umg = require("client.slua.logic.mode_selection.logic_mode_selection_for_umg")
  logic_mode_selection_for_umg.GotoTxMissionLobby()
end
function UI_Match_Entry:OnClickEntry()
  log(bWriteLog and "UI_Match_Entry:OnClickEntry")
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.IsTeamLeader() and TeamUpNewSystem.GetTeamNum() > 1 and not TeamUpNewSystem.IsEverybodyReady() then
    ShowNotice(111013)
    return
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local matchMode, viewID, viewIDs = logic_mode_selection:GetCurSelectInfo()
  local viewInfo = logic_mode_selection:GetSubviewInfoBySubviewID(viewID)
  local config_arena = require("client.slua.logic.arena.config_arena")
  if logic_mode_selection.hasSelectTxMission then
    log(bWriteLog and "UI_Match_Entry:OnClickEntry hasSelectTxMission")
    self:GotoTxMissionLobby()
    return
  end
  local iPadVirReduce = HDmpveRemote.HDmpveRemoteConfigGetInt("iPadVirReduce", 0)
  if 0 < iPadVirReduce then
    local gc_util = require("common.gc_util")
    gc_util.FullGC()
  end
  self:PlayAudio(sound_config.click)
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  local status = MatchSystem.nMatchStatus
  log(bWriteLog and "[qintong]:growthprojectMgrB.CanntClickMatch status =" .. tostring(status) .. "  " .. tostring(growthprojectMgrB.CanntClickMatch))
  growthprojectMgrB.StartMatchTimer()
  growthprojectMgrB.OnClickMatchEntry()
  local BasicDataTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataTLogReport)
  local Lobby_Main_Control = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
  BasicDataTLogReport:ReportDelay(Lobby_Main_Control.curPage == ENUM_LobbyPageType.Mid and TLogEventDefine.SelectModeStart1 or TLogEventDefine.SelectModeStart2)
  local UGCPlayHallRoom = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.UGCPlayHallRoom)
  if UGCPlayHallRoom then
    if UGCPlayHallRoom:GetRoomInfo() then
      EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_SHOW_PLAY_HALL_ROOM_UI, "Lobby")
      return
    elseif UGCPlayHallRoom:CheckPendingMatchState() then
      return
    end
  end
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  local ugcMatchInfo = LogicUGCMatch:HasUGCMatchInfo()
  local logic_season_guide_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_guide_manager)
  if ugcMatchInfo then
    logic_season_guide_manager:RecordClassicRank(false)
  else
    logic_season_guide_manager:RecordClassicRank(logic_mode_selection:IsClassicRankMode(matchMode))
  end
  if status == E_MatchStatus.Matching and growthprojectMgrB.CanntClickMatch then
    return
  end
  self:ClearResetDepotGuide()
  self:ClearActionEffect()
  if self.tipsUI then
    self.tipsUI:Close()
    self.tipsUI = nil
  end
  self:ClearHandEffect()
  self:RefreshHistory(false)
  local UIUtil = require("client.common.ui_util")
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.ActivitySwitch) then
    return
  end
  if GameStatus.IsInFightingNotSocialNotMainCityNotHome() then
    return
  end
  local XMissionSystem = require("client.slua.logic.TxMission.logic_xmission_main")
  if XMissionSystem.IsInXMission(true) then
    return
  end
  if ugcMatchInfo then
    self:OnClickEntryForUGC(status)
    return
  end
  if viewInfo and viewInfo.menu_id == config_arena.ModeMenuId and status ~= E_MatchStatus.Matching then
    local ArenaSystem = require("client.slua.logic.arena.logic_arena")
    if not ArenaSystem.IsInArenaSeason() then
      ShowNotice(108108)
      return
    end
  end
  self:CheckEntry()
  if 0 < iPadVirReduce then
    local gc_util = require("common.gc_util")
    gc_util.FullGC()
  end
end
function UI_Match_Entry:OnQRCodeRestrictChange()
  log(bWriteLog and "UI_Match_Entry:OnQRCodeRestrictChange")
  self:RefreshQRCodeBattleRestrict()
end
function UI_Match_Entry:CheckEntry()
  log(bWriteLog and "UI_Match_Entry:CheckEntry")
  local status = MatchSystem.nMatchStatus
  if status == E_MatchStatus.Not or status == E_MatchStatus.Ready then
    MatchSystem.RecordDsVersion()
    if PufferDownloader.CheckAllMapPak(self, self.OnCheckAllMapPakResult) then
      self:OnClickEntryInternal()
    end
    return
  end
  self:OnClickEntryInternal()
end
function UI_Match_Entry:OnClickEntryForUGC(status)
  print(bWriteLog and "UI_Match_Entry:OnClickEntryForUGC")
  if status == E_MatchStatus.Not then
    local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
    local FinishCallback = function()
      self:CheckEntry()
    end
    local logic_ugc_new_process = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_new_process)
    local bShowTrans = logic_ugc_new_process:GetShowTranslateWindow()
    log(bWriteLog and "UI_Match_Entry:OnClickEntryForUGC bShowTrans = " .. tostring(bShowTrans))
    if bShowTrans then
      log(bWriteLog and "UI_Match_Entry:OnClickEntryForUGC Translation pop-up window does not display")
      self:CheckEntry()
      return
    end
    if LogicUGC:ShowAutoTranslateCheckWindow(FinishCallback) == false then
      self:CheckEntry()
    end
  else
    self:CheckEntry()
  end
end
function UI_Match_Entry:OnClickSelectMode()
  log(bWriteLog and "UI_Match_Entry:OnClickSelectMode")
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  growthprojectMgrB.HideWeakGuide(3, 1)
  self:DoClickSelectMode(self:NeedShowActImg())
end
function UI_Match_Entry:OnClickCloseRewardTips()
  log(bWriteLog and "UI_Match_Entry:OnClickCloseRewardTips")
  self:PlayAudio(sound_config.click)
  self.UIRoot.CanvasPanel_19:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.Button_Close:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function UI_Match_Entry:DoClickSelectModeEvent(_, _, IsBanner)
  log(bWriteLog and "UI_Match_Entry:DoClickSelectModeEvent IsBanner = " .. tostring(IsBanner))
  self:DoClickSelectMode(IsBanner)
end
function UI_Match_Entry:UpDateCrossSuccess()
  log(bWriteLog and "UI_Match_Entry:UpDateCrossSuccess")
  ShowNotice(39191)
  self.UIRoot.CanvasPanel_JK:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self.UIRoot.TextBlock_Cross:SetText(LocUtil.GetLocalizeResStr(42752))
end
function UI_Match_Entry:DoClickSelectMode(IsBanner)
  log(bWriteLog and "UI_Match_Entry:DoClickSelectMode IsBanner = " .. tostring(IsBanner))
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  if not TeamUpNewSystem.IsTeamLeader() then
    log(bWriteLog and "[edward][match_select_entry] UI_Match_Select_Entry:OnClickEntry, is not team leader!!!")
    ShowNotice(500045)
    return
  end
  if LobbySystem.isInMatch then
    log(bWriteLog and "[edward][match_select_entry] UI_Match_Select_Entry:OnClickEntry, is matching!!!")
    ShowNotice(110014)
    return
  end
  if IsBanner then
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    local actData, matchID, modeIDs, viewIDs, newViewIDs = MatchModeMgrSystem.GetNewMatchModeData()
    if not actData then
      return
    end
    local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eMatchEntryActImgUrl) or {}
    cfg.ID = actData.ID
    cfg.imgUrl = actData.ImgUrl
    PlayerPrefsSystem.SaveTableToFile_N(cfg, PlayerPrefsSystem.ePlayerPrefsType.eMatchEntryActImgUrl)
    log(bWriteLog and "UI_Match_Entry:DoClickSelectMode " .. tostring(actData.ImgUrl))
    if string.find(actData.ImgLink, "module=" .. BP_ENUM_MODULE_TXMISSION_LOBBY_FROM_JUMP) then
      local logic_xmission_entrance = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_entrance)
      logic_xmission_entrance:OpenTxMissionByClick()
      return
    elseif string.find(actData.ImgLink, "module=" .. BP_ENUM_MODULE_MATCH_MODE_NOTICE) then
      return
    elseif string.find(actData.ImgLink, "module=" .. BP_ENUM_MODULE_MATCH_MODE_CHOOSE) then
      local modeID = next(modeIDs)
      tlog_report_utils.ReportTLogEvent(TLogEventDefine.SelectModeEntry, 0, "ClickSelectModeWhenActShow-" .. tostring(modeID))
      local TempMapdata = {}
      for k, v in pairs(modeIDs) do
        local MapKey = MatchModeMgrSystem.GetMapKeyBySubMode(v)
        TempMapdata = {}
        TempMapdata[MapKey] = 1
      end
      MatchModeMgrSystem.SaveMatchMode(modeIDs, viewIDs, MatchModeMgrSystem.autoMatch, newViewIDs)
      return
    elseif string.find(actData.ImgLink, "module=") then
      local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
      ActivityNewSystem.JumpUrl(actData.ImgLink)
      return
    end
  end
end
function UI_Match_Entry:OnClickEntryInternal()
  log(bWriteLog and "UI_Match_Entry:OnClickEntryInternal")
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  if MatchSystem.bShowWeakGuide then
    MatchSystem.bShowWeakGuide = false
    DataMgr.team_up_has_weak_guide = true
  end
  MatchModeMgrSystem.bIsMatchingTrainMode = false
  MatchModeMgrSystem.bIsMatchingSocialIsland = false
  local status = MatchSystem.nMatchStatus
  log(bWriteLog and "[  status" .. tostring(status))
  if status == E_MatchStatus.Not then
    local MentorSystem = require("client.slua.logic.mentor.logic_mentor")
    if MentorSystem.mentor_prematch_state then
      MentorSystem.send_mentor_prematch_cancel_req()
      return
    end
    if MentorSystem.IsMentorOpen() and MentorSystem.identity == 2 and MentorSystem.waiting_status == 1 then
      local common_save_game = require("client.logic.LogicPlayerPrefs.common_save_game")
      if not common_save_game.GetSaveData(common_save_game.Configs.Mentor_StartGame_Tips) then
        local title = LocUtil.LocalizeResFormat("101001")
        local tip = LocUtil.LocalizeResFormat("9206")
        local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
        CommonMsgBoxMgr.Show(2, title, tip, function()
          self:OnClickEntryInternal()
        end)
        common_save_game.SaveData(common_save_game.Configs.Mentor_StartGame_Tips)
        return
      end
    end
    if TeamUpNewSystem.IsTeamLeader() then
      self:StartMatch()
    else
      self:ReadyMatch()
    end
  elseif status == E_MatchStatus.Ready then
    local MentorSystem = require("client.slua.logic.mentor.logic_mentor")
    if MentorSystem.mentor_prematch_state then
      MentorSystem.send_mentor_prematch_cancel_req()
      return
    end
    if TeamUpNewSystem.IsTeamLeader() then
      self:StartMatch()
    else
      self:CancelReady()
      self:PlayAudio(sound_config.new_cancelStartGameBtn)
      return
    end
  elseif status == E_MatchStatus.Matching then
    self:PlayAudio(sound_config.new_cancelStartGameBtn)
    local logic_long_time_match = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_long_time_match)
    if logic_long_time_match:IsShowLTMatchCancelTips() then
      self:ShowLTMatchCancelTips()
      return
    end
    local logic_multi_select_match = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_multi_select_match)
    if logic_multi_select_match:CheckGuideWhenCancelMatch() then
      logic_multi_select_match:ShowGuideWhenCancelMatch()
      return
    end
    self:CancelMatch()
    return
  elseif status == E_MatchStatus.Success then
    if TeamUpNewSystem.IsTeamLeader() then
      self:StartMatch()
    else
      self:ReadyMatch()
    end
  end
  self:PlayAudio(sound_config.new_startGameBtn)
end
function UI_Match_Entry:AddClickTipTimer()
  log(bWriteLog and "UI_Match_Entry:AddClickTipTimer")
  self.bClickTipButton = true
  if self.resetClickTipTimer then
    self:RemoveTimer(self.resetClickTipTimer)
  end
  self.resetClickTipTimer = self:AddTimer(1, function()
    self.bClickTipButton = false
    self:RemoveTimer(self.resetClickTipTimer)
    self.resetClickTipTimer = nil
  end)
end
function UI_Match_Entry:OnEnter()
  log(bWriteLog and "UI_Match_Entry:OnEnter")
  local gameStatus = GameStatus.GetGameStatus()
  log(bWriteLog and "[edward][match_entry] UI_Match_Entry:OnEnter, gameStatus = " .. gameStatus)
  if GameStatus.IsInLobbyOrMainCity() then
    local XMissionSystem = require("client.slua.logic.TxMission.logic_xmission_main")
    if XMissionSystem.IsInXMission(true) then
      return
    end
    local Lobby_Main_Control = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
    if Lobby_Main_Control.curPage ~= ENUM_LobbyPageType.Mid then
      log_format("UI_Match_Entry:OnEnter. curPage is not middle")
      return
    end
    self:Hide()
    self:PlayEnterAnimation()
    self:SelfHitTestInvisible()
  end
end
function UI_Match_Entry:OnUpdateMatchStatus(eventType, eventID, type, status, uid)
  log(bWriteLog and "[edward][match_entry] UI_Match_Entry:OnUpdateMatchStatus, type = " .. tostring(type) .. ", status = " .. tostring(status) .. ", uid = " .. tostring(uid))
  self:ResetData()
  if type and type ~= ENUM_TeamInfoSyncType.Compatible and type ~= ENUM_TeamInfoSyncType.All and type ~= ENUM_TeamInfoSyncType.Ready then
    return
  end
  if TeamUpNewSystem.IsTeamLeader() then
    if MatchSystem.nMatchStatus == E_MatchStatus.Ready then
      MatchSystem.nMatchStatus = E_MatchStatus.Not
    end
  elseif status and tostring(uid) == DataMgr.roleData.uid then
    MatchSystem.nMatchStatus = status
  else
    local menberInfo = TeamUpNewSystem.GetMemberInfo(DataMgr.roleData.uid)
    if menberInfo and menberInfo.status and MatchSystem.nMatchStatus ~= E_MatchStatus.Matching then
      log(bWriteLog and "[edward][match_entry] UI_Match_Entry:OnUpdateMatchStatus, menberInfo.status = " .. menberInfo.status)
      MatchSystem.nMatchStatus = menberInfo.status
    end
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local isPakegame = logic_mode_selection:IsPeakGameView()
  if isPakegame then
    self:SetWidgetVisible(self.UIRoot.Canvas_Panel_HandGuide01, false)
  end
  self:UpdateStatus()
end
function UI_Match_Entry:ResetMatchUI()
  log(bWriteLog and "UI_Match_Entry:ResetMatchUI")
  collapse(self.UIRoot.SameLanguageMatch)
  collapse(self.UIRoot.TeammateMatch)
  collapse(self.UIRoot.WaitForMatch)
  selfHit(self.UIRoot.Panel_Mode_Selected)
  collapse(self.UIRoot.HorizontalBox_HotStat)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_44, false)
end
function UI_Match_Entry:ProcessEnterMatch(display)
  log(bWriteLog and "UI_Match_Entry:ProcessEnterMatch", display)
  if MatchSystem.nMatchStatus ~= E_MatchStatus.Matching then
    return
  end
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  if tonumber(LogicUGCMatch:GetMatchModID()) > 0 then
    return
  end
  local LogicUGCMulti = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMulti)
  if LogicUGCMulti.bIsBundleMatch then
    return
  end
  local Lobby_Main_Control = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
  if display or LogicMatchEntry.HasMatchInfoToDisplay() then
    show(self.UIRoot.SizeBox_top)
    self:SetWidgetVisible(self.UIRoot.Common_Tips_Bg02_UIBP, true)
    self:UpdateWaitForMatchBackground()
    if Lobby_Main_Control.curPage == ENUM_LobbyPageType.Mid then
      self:ExpandMatchInfo()
    end
  end
end
function UI_Match_Entry:OnClickArenaWeapon()
  log(bWriteLog and "UI_Match_Entry:OnClickArenaWeapon")
  self:PlayAudio(sound_config.click_v1)
  local PrepareSchemeSystem = require("client.slua.logic.prepareScheme.logic_prepare_scheme")
  PrepareSchemeSystem.OpenPrepareSchemeMain()
  gem_report_utils.ReportBtnClickEvent(gem_report_utils.SubEventName_From_Mode_Select)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.From_Mode_Select)
  local ArenaRedDotSystem = require("client.slua.logic.arena.logic_AW_red_dot")
  ArenaRedDotSystem.SetEntranceRedState()
end
function UI_Match_Entry:ProcessLeaveMatching()
  log(bWriteLog and "UI_Match_Entry:ProcessLeaveMatching")
  if MatchSystem.nMatchStatus ~= E_MatchStatus.Matching then
    if self.LTMatchAnimTimer then
      local time_ticker = require("common.time_ticker")
      time_ticker.RemoveTimer(self.LTMatchAnimTimer)
      self.LTMatchAnimTimer = nil
    end
    collapse(self.UIRoot.WaitForMatch)
    collapse(self.UIRoot.TeammateMatch)
    collapse(self.UIRoot.SameLanguageMatch)
    self:SetWidgetVisible(self.UIRoot.Border_MatchInfo, false)
    self:SetWidgetVisible(self.UIRoot.Border_0, false)
    self:SetWidgetVisible(self.UIRoot.GridPanel_LTMatch, false)
    collapse(self.UIRoot.SizeBox_top)
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_highLeveTips, false)
    self:SetWidgetVisible(self.UIRoot.Common_Tips_Bg02_UIBP, false)
    self:UpdateWaitForMatchBackground()
    self.UIRoot.Image_13:SetRenderAngle(0)
    self.bHighLevelTipsExpanded = false
    self.nMatchPanelState = ENUM_MatchPanelState.Collapsed
    if self.MathInfoState == EXPAND then
      local anim = self.UIRoot.Animation_ShrinkAndExpansion
      self:PlayUserWidgetAnimation(anim, 0, 1, SHRINK, 1)
    end
    self.MathInfoState = SHRINK
    self.bDebugTimersSet = false
    self.bWaitForMatchShown = false
    local logic_long_time_match = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_long_time_match)
    logic_long_time_match:SetIsShowLTMatch(false)
    local LobbyMidMessageUIBP_recover, LobbyExtraTeamUIBP_recover
    local lobbyMain_recover = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
    if lobbyMain_recover then
      LobbyMidMessageUIBP_recover = lobbyMain_recover:GetChildUI(UIManager.UI_Config.Lobby_Mid_Message_UIBP)
      LobbyExtraTeamUIBP_recover = lobbyMain_recover:GetChildUI(UIManager.UI_Config.team_extra_main)
    end
    if LobbyMidMessageUIBP_recover then
      LobbyMidMessageUIBP_recover:ShowVerticalButtonList()
    end
    if LobbyExtraTeamUIBP_recover then
      LobbyExtraTeamUIBP_recover:SelfHitTestInvisible()
    end
  end
end
function UI_Match_Entry:ExpandMatchInfo()
  log(bWriteLog and "UI_Match_Entry:ExpandMatchInfo")
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  if tonumber(LogicUGCMatch:GetMatchModID()) > 0 then
    return
  end
  if LogicUGCMatch:IsCreativeWoW() then
    return
  end
  if self.MathInfoState == SHRINK then
    self:Driven(EXPAND)
  end
end
function UI_Match_Entry:ShrinkMatchInfo()
  log(bWriteLog and "UI_Match_Entry:ShrinkMatchInfo")
  if self.MathInfoState == EXPAND then
    self:Driven(SHRINK)
  end
end
function UI_Match_Entry:OnClickExpand()
  log(bWriteLog and "UI_Match_Entry:OnClickExpand")
  self:PlayAudio(sound_config.click)
  if self.MathInfoState == EXPAND then
    self:Driven(SHRINK)
  else
    self:ExpandMatchInfo()
  end
end
function UI_Match_Entry:OnClickShrink()
  log(bWriteLog and "UI_Match_Entry:OnClickShrink")
  self:PlayAudio(sound_config.click)
  self:ShrinkMatchInfo()
end
function UI_Match_Entry:Driven(state)
  log(bWriteLog and "GetMatchModID " .. state)
  self.MathInfoState = state
  if state == EXPAND then
    self.UIRoot.Image_13:SetRenderAngle(180)
  else
    self.UIRoot.Image_13:SetRenderAngle(0)
  end
  local logic_long_time_match = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_long_time_match)
  if logic_long_time_match:GetIsShowLTMatch() then
    if state == EXPAND then
      if not self.UIRoot.GridPanel_LTMatch:IsVisible() then
        self:SetWidgetVisible(self.UIRoot.GridPanel_LTMatch, true)
        self:SetWidgetVisible(self.UIRoot.Border_0, true)
        self:PlayUserWidgetAnimation(self.UIRoot.Animation_MatchingGuide, 0, 1, 1, 1)
        collapse(self.UIRoot.WaitForMatch)
        collapse(self.UIRoot.SameLanguageMatch)
        self:SetWidgetVisible(self.UIRoot.Border_MatchInfo, false)
        self:SetWidgetVisible(self.UIRoot.CanvasPanel_highLeveTips, false)
        self.MathInfoState = SHRINK
        local LogicMatchEntry = require("client.slua.logic.lobby.Mid.logic_match_entry")
        local hasWaitForMatch = LogicMatchEntry.FigureWaitForMatch()
        local hasSameLanguage = LogicMatchEntry.IsShowSameLanguageMatch()
        local LogicModeMatchProgress = require("client.slua.logic.mode_selection.LogicModeMatchProgress")
        local canShowHL = LogicModeMatchProgress.CanShowHighLevelMatchTips()
        if not hasWaitForMatch and not hasSameLanguage and not canShowHL then
          self.UIRoot.Image_13:SetRenderAngle(180)
        else
          self.UIRoot.Image_13:SetRenderAngle(0)
        end
      else
        self:SetWidgetVisible(self.UIRoot.Border_0, true)
        LogicMatchEntry.CalculateMatchDisplay()
        local hasWaitForMatch = LogicMatchEntry.FigureWaitForMatch()
        local hasSameLanguage = LogicMatchEntry.IsShowSameLanguageMatch()
        local LogicModeMatchProgress = require("client.slua.logic.mode_selection.LogicModeMatchProgress")
        local canShowHL = LogicModeMatchProgress.CanShowHighLevelMatchTips()
        if not hasWaitForMatch and not hasSameLanguage and not canShowHL then
          log(bWriteLog and "UI_Match_Entry:Driven EXPAND - no sub-panel data, shrink directly")
          self.UIRoot.Image_13:SetRenderAngle(180)
          self:Driven(SHRINK)
          return
        end
        if hasWaitForMatch then
          show(self.UIRoot.WaitForMatch)
          self:UpdateWaitForMatchBackground()
          self:WaitForMatch(true)
        end
        self:TeammateMatch()
        if hasSameLanguage then
          self:SameLanguageMatch()
        end
        self:SetWidgetVisible(self.UIRoot.CanvasPanel_highLeveTips, canShowHL)
        self:SetWidgetVisible(self.UIRoot.Border_MatchInfo, hasWaitForMatch or hasSameLanguage)
        self:UpdateMatchingTime()
        self.nMatchPanelState = ENUM_MatchPanelState.LTExpanded
        self.UIRoot.Image_13:SetRenderAngle(180)
      end
    elseif self.nMatchPanelState == ENUM_MatchPanelState.LTExpanded then
      collapse(self.UIRoot.WaitForMatch)
      collapse(self.UIRoot.SameLanguageMatch)
      self:SetWidgetVisible(self.UIRoot.Border_MatchInfo, false)
      self:SetWidgetVisible(self.UIRoot.CanvasPanel_highLeveTips, false)
      self.nMatchPanelState = ENUM_MatchPanelState.LTOnly
      self.bWaitForMatchShown = false
      self.bHighLevelTipsExpanded = false
      self.MathInfoState = EXPAND
      self.UIRoot.Image_13:SetRenderAngle(180)
    else
      collapse(self.UIRoot.WaitForMatch)
      collapse(self.UIRoot.SameLanguageMatch)
      self:SetWidgetVisible(self.UIRoot.Border_MatchInfo, false)
      self:SetWidgetVisible(self.UIRoot.CanvasPanel_highLeveTips, false)
      self:PlayUserWidgetAnimation(self.UIRoot.Animation_MatchingGuide, 0, 1, 0, 1)
      self:SetWidgetVisible(self.UIRoot.GridPanel_LTMatch, false)
      self:SetWidgetVisible(self.UIRoot.Border_0, false)
      self.UIRoot.Image_13:SetRenderAngle(0)
    end
  else
    if state == EXPAND then
      self:SetWidgetVisible(self.UIRoot.Border_MatchInfo, true)
    else
      self:SetWidgetVisible(self.UIRoot.Border_MatchInfo, false)
    end
    local anim = self.UIRoot.Animation_ShrinkAndExpansion
    self:PlayUserWidgetAnimation(anim, 0, 1, state, 1)
  end
  local LobbyMidMessageUIBP, LobbyExtraTeamUIBP
  local lobbyMain = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  if lobbyMain then
    LobbyMidMessageUIBP = lobbyMain:GetChildUI(UIManager.UI_Config.Lobby_Mid_Message_UIBP)
    LobbyExtraTeamUIBP = lobbyMain:GetChildUI(UIManager.UI_Config.team_extra_main)
  end
  if state == EXPAND then
    if LobbyMidMessageUIBP then
      LobbyMidMessageUIBP:HideVerticalButtonList()
    end
    if LobbyExtraTeamUIBP then
      LobbyExtraTeamUIBP:Collapsed()
    end
  else
    if LobbyMidMessageUIBP then
      LobbyMidMessageUIBP:ShowVerticalButtonList()
    end
    if LobbyExtraTeamUIBP then
      LobbyExtraTeamUIBP:SelfHitTestInvisible()
    end
  end
end
function UI_Match_Entry:OnClickOpenSettings()
  log(bWriteLog and "UI_Match_Entry:OnClickOpenSettings")
  self:PlayAudio(sound_config.click)
  UIManager.ShowUI(UIManager.UI_Config.mode_selection_option)
end
function UI_Match_Entry:SameLanguageMatch()
  log(bWriteLog and "UI_Match_Entry:SameLanguageMatch")
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  local LogicUGCMulti = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMulti)
  local logic_long_time_match = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_long_time_match)
  if LogicMatchEntry.IsShowSameLanguageMatch() and not (tonumber(LogicUGCMatch:GetMatchModID()) > 0) and not LogicUGCMulti.bIsBundleMatch then
    local MatchSystem = require("client.slua.logic.match.logic_match")
    if MatchSystem.IsSameLanguageMatchTimeOut() then
      log(bWriteLog and "UI_Match_Entry:SameLanguageMatch time out")
      self.UIRoot.TextBlock_SameLangMatch:SetText(LocUtil.GetLocalizeResStr(64164))
      self:SetWidgetVisible(self.UIRoot.MatchInfo_HorizontalSplitLine, false)
      self:SetWidgetVisible(self.UIRoot.MatchTips, false)
    else
      local lan1 = ""
      local LanguageSelectSystem = require("client.logic.language_select.logic__language_select")
      local lan2 = LanguageSelectSystem.secondDefautLanguageName
      local MatchLanguage = LogicMatchEntry.GetMatchLanguage()
      log_tree("UI_Match_Entry:SameLanguageMatch matching matchLang = ", MatchLanguage)
      if not MatchLanguage or not next(MatchLanguage) then
        return
      end
      local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
      if Client.GetPublishRegion() ~= PublishRegionMacros.BLUEHOLE then
        local LogicChatChannelWorld = require("client.slua.logic.lobby_chat.logic_chat_channel_world")
        for _, v in ipairs(LogicChatChannelWorld.language_data_list) do
          if v.id == MatchLanguage[1] then
            lan1 = v.langName
          end
          if v.id == MatchLanguage[2] then
            lan2 = v.langName
          end
        end
      else
        local configs = CDataTable.GetTable("BlueHoleMatchLang")
        for _, v in pairs(configs) do
          if v.id == MatchLanguage[1] then
            lan1 = v.langName
          end
          if v.id == MatchLanguage[2] then
            lan2 = v.langName
          end
        end
      end
      local text = lan1 .. "/" .. lan2
      self.UIRoot.TextBlock_SameLangMatch:SetText(text)
      self:SetWidgetVisible(self.UIRoot.MatchInfo_HorizontalSplitLine, true)
      self:SetWidgetVisible(self.UIRoot.MatchTips, true)
    end
    show(self.UIRoot.SameLanguageMatch)
    self:SetWidgetVisible(self.UIRoot.Common_Tips_Bg02_UIBP, true)
  else
    collapse(self.UIRoot.SameLanguageMatch)
    self:SetWidgetVisible(self.UIRoot.MatchInfo_HorizontalSplitLine, false)
    self:SetWidgetVisible(self.UIRoot.MatchTips, false)
  end
  self:UpdateWaitForMatchBackground()
end
function UI_Match_Entry:OnSameLanguageMatchTimeOut()
  log(bWriteLog and "UI_Match_Entry:OnSameLanguageMatchTimeOut")
  local sameLanguageMatchTime = CDataTable.GetTableData("IntlSystemConfig", "DynamicLanguageMatchTime").ConfigValue
  local tip = LocUtil.LocalizeResFormat(64163, sameLanguageMatchTime)
  ShowNotice(tip)
  self.UIRoot.TextBlock_SameLangMatch:SetText(LocUtil.GetLocalizeResStr(64164))
  self:SetWidgetVisible(self.UIRoot.MatchInfo_HorizontalSplitLine, false)
  self:SetWidgetVisible(self.UIRoot.MatchTips, false)
end
function UI_Match_Entry:OnQRCodeRestrictChange()
  log(bWriteLog and "UI_Match_Entry:OnQRCodeRestrictChange")
  self:RefreshQRCodeBattleRestrict()
end
function UI_Match_Entry:TeammateMatch()
  log(bWriteLog and "UI_Match_Entry:TeammateMatch")
  if not self.UIRoot or not self.UIRoot.TeammateMatch then
    return
  end
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  local LogicUGCMulti = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMulti)
  local logic_long_time_match = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_long_time_match)
  if LogicMatchEntry.IsShowTeammateMatch() and (not logic_long_time_match:GetIsShowLTMatch() or self.MathInfoState == EXPAND) and not (tonumber(LogicUGCMatch:GetMatchModID()) > 0) and not LogicUGCMulti.bIsBundleMatch then
    show(self.UIRoot.TeammateMatch)
    local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
    local teamNum = 4
    local filterInfo = logic_mode_selection:GetFilterInfo()
    teamNum = filterInfo.teamNum
    local logic_mode_asymmertric = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_asymmertric)
    if logic_mode_asymmertric:GetHasSelectedCamp() and logic_mode_asymmertric:GetCampForMatch() == 1 then
      teamNum = 1
    end
    local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
    local _teamIconMap = mode_selection_macro.TeamNumIcon_Path_Config
    self:SetTexture(self.UIRoot.Image_44, _teamIconMap[teamNum] or "")
    self.UIRoot.UTRichTextBlock_TeamMatch:SetText(LocUtil.LocalizeResFormat(35014, math.min(LogicMatchEntry.GetTeammateMatchNum(), teamNum), teamNum))
  else
    collapse(self.UIRoot.TeammateMatch)
  end
  self:UpdateWaitForMatchBackground()
end
function UI_Match_Entry:OnNextDayHandler()
  log(bWriteLog and "UI_Match_Entry:OnNextDayHandler")
  if self.reqDataTimer then
    self:RemoveTimer(self.reqDataTimer)
    self.reqDataTimer = nil
  end
  local interval = math.random(120)
  log(bWriteLog and "[edward][match_select_entry] UI_Match_Select_Entry:OnNextDayHandler.Tick, random = " .. interval)
  self.reqDataTimer = self:AddTimer(interval, function()
    self:OnTimerNextDayByRandomDelay()
  end)
end
function UI_Match_Entry:OnStartBtnAction(_, _, actType)
  log(bWriteLog and "UI_Match_Entry:OnStartBtnAction actType = " .. actType)
  self:CheckAndAddEffect()
  self:CheckAndShowTips()
  self:CheckAndAddHandEffect()
end
function UI_Match_Entry:CheckAndAddEffect()
  log(bWriteLog and "UI_Match_Entry:CheckAndAddEffect")
  local StartBtnEffectAction = require("client.slua.logic.GuideFlow.Action.StartBtnEffectAction")
  if StartBtnEffectAction.bPlayFxEffect and self.UIRoot.EntryGuide_FX then
    self.UIRoot.EntryGuide_FX:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
end
function UI_Match_Entry:CheckAndShowTips()
  log(bWriteLog and "UI_Match_Entry:CheckAndShowTips")
  local StartBtnEffectAction = require("client.slua.logic.GuideFlow.Action.StartBtnEffectAction")
  if StartBtnEffectAction.bShowTips and self.tipsUI == nil then
    StartBtnEffectAction.bShowTips = false
    self.tipsUI = self:CreateChildWindow(self.UIRoot.CanvasPanel_tips, UIManager.UI_Config.Common_Normal_Tips_UIBP, 2, false)
    self.tipsUI:SetOffsets(0, 0, 0, 0)
    self.tipsUI:SetTips(LocUtil.GetLocalizeResStr("11825"))
  end
end
function UI_Match_Entry:CheckAndAddHandEffect()
  log(bWriteLog and "UI_Match_Entry:CheckAndAddHandEffect")
  local StartBtnEffectAction = require("client.slua.logic.GuideFlow.Action.StartBtnEffectAction")
  if LobbySystem.CheckUseNewGuide() then
    local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
    if not growthprojectMgrB.IsFinishAllNewGuide() then
      local LogicNewbie = require("client.logic.newbie.logic_newbie")
      local needGuide = growthprojectMgrB.CheckGuideStep(LogicNewbie.NEWBIE_GUIDE_MODULE_ID_FIRST_BATTLE_AFTER_TASK, 0)
      if needGuide then
        log(bWriteLog and "UI_Match_Entry:CheckAndAddHandEffect show")
        self.UIRoot.Canvas_Panel_HandGuide:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        self:PlayUserWidgetAnimation(self.UIRoot.Animation_Hand, 0, 5, 0, 1)
      end
      return
    end
  end
  log(bWriteLog and "UI_Match_Entry:CheckAndAddHandEffect StartBtnEffectAction.bShowHandEffect = " .. tostring(StartBtnEffectAction.bShowHandEffect) .. " StartBtnEffectAction.bThirdlyWeekGuide = " .. tostring(StartBtnEffectAction.bThirdlyWeekGuide))
  if StartBtnEffectAction.bShowHandEffect then
    StartBtnEffectAction.bShowHandEffect = false
    self.UIRoot.Canvas_Panel_HandGuide:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self:PlayUserWidgetAnimation(self.UIRoot.Animation_Hand, 0, 5, 0, 1)
  end
  if StartBtnEffectAction.bThirdlyWeekGuide then
    StartBtnEffectAction.bThirdlyWeekGuide = false
    self.UIRoot.Canvas_Panel_HandGuide:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self:PlayUserWidgetAnimation(self.UIRoot.Animation_Hand, 0, 0, 0, 1)
  end
end
function UI_Match_Entry:ClearResetDepotGuide()
  log(bWriteLog and "UI_Match_Entry:ClearResetDepotGuide")
  self.UIRoot.Canvas_Panel_HandGuide:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.Button_Mask:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot:StopAnimation(self.UIRoot.Animation_Hand)
end
function UI_Match_Entry:ClearActionEffect()
  log(bWriteLog and "UI_Match_Entry ClearActionEffect")
  local StartBtnEffectAction = require("client.slua.logic.GuideFlow.Action.StartBtnEffectAction")
  StartBtnEffectAction.bPlayFxEffect = false
  if self.UIRoot.EntryGuide_FX then
    self.UIRoot.EntryGuide_FX:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function UI_Match_Entry:OnTimerNextDayByRandomDelay()
  log(bWriteLog and "[edward][match_select_entry] UI_Match_Select_Entry:OnTimerNextDayByRandomDelay")
  if self.reqDataTimer then
    self:RemoveTimer(self.reqDataTimer)
    self.reqDataTimer = nil
  end
end
function UI_Match_Entry:WaitForMatch(bForceShow)
  log(bWriteLog and "UI_Match_Entry:WaitForMatch")
  local waitLine = MatchSystem.waitLine
  if not (waitLine.nPos and waitLine.nSpeed) or waitLine.nPos <= 0 then
    return
  end
  if bForceShow then
    show(self.UIRoot.SizeBox_top)
    self:SetWidgetVisible(self.UIRoot.Common_Tips_Bg02_UIBP, true)
    show(self.UIRoot.WaitForMatch)
    self:UpdateWaitForMatchBackground()
  elseif not self.bWaitForMatchShown then
    self.bWaitForMatchShown = true
    show(self.UIRoot.SizeBox_top)
    self:SetWidgetVisible(self.UIRoot.Common_Tips_Bg02_UIBP, true)
    self:UpdateWaitForMatchBackground()
    local logic_long_time_match = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_long_time_match)
    if not logic_long_time_match:GetIsShowLTMatch() then
      show(self.UIRoot.WaitForMatch)
      self:ExpandMatchInfo()
    elseif self.nMatchPanelState ~= ENUM_MatchPanelState.LTExpanded then
      self.MathInfoState = SHRINK
      self.UIRoot.Image_13:SetRenderAngle(0)
    else
      show(self.UIRoot.WaitForMatch)
    end
  end
  if waitLine.nPos < 100 then
    self.UIRoot.Text_WaitForMatchNum:SetText(LocUtil.LocalizeResFormat(6382, "100+"))
  else
    self.UIRoot.Text_WaitForMatchNum:SetText(LocUtil.LocalizeResFormat(6382, waitLine.nPos))
  end
end
function UI_Match_Entry:OnMatchOptionsChange()
  log(bWriteLog and "UI_Match_Entry:OnMatchOptionsChange")
  self:OnClickEntryInternal()
end
function UI_Match_Entry:OnAnimationEnd()
  log(bWriteLog and "UI_Match_Entry:OnAnimationEnd")
  self.UIRoot.Canvas_Panel_HandGuide:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function UI_Match_Entry:ClearHandEffect()
  log(bWriteLog and "UI_Match_Entry:ClearHandEffect")
  self.UIRoot.Canvas_Panel_HandGuide:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot:StopAnimation(self.UIRoot.Animation_Hand)
end
function UI_Match_Entry:PlayLobbyEffect(aniIntervalTime, aniName)
  log(bWriteLog and "UI_Match_Entry:PlayLobbyEffect aniIntervalTime = " .. tostring(aniIntervalTime) .. " aniName = " .. tostring(aniName))
  if self.isPlayingEffect then
    return
  end
  self.isPlayingEffect = true
  self.aniIntervalTime = aniIntervalTime or 2
  self:PlayUserWidgetAnimation(self.UIRoot.Anina_Permanent, 0, 1, 0, 1)
end
function UI_Match_Entry:StopLobbyEffect(aniName)
  log(bWriteLog and "UI_Match_Entry:ClearHandEffect aniName = " .. tostring(aniName))
  if not self.isPlayingEffect then
    return
  end
  self.isPlayingEffect = false
  self.aniIntervalTime = 0
  self.UIRoot:StopAnimation(self.UIRoot.Anina_Permanent)
end
function UI_Match_Entry:LobbyEffectEnd()
  if not self.isPlayingEffect then
    return
  end
  self:AddTimerOnce(self.aniIntervalTime, function()
    if self.UIRoot and slua.isValid(self.UIRoot) then
      self:PlayUserWidgetAnimation(self.UIRoot.Anina_Permanent, 0, 1, 0, 1)
    end
  end)
end
function UI_Match_Entry:OnMatchLTGetData(_, _, isTest)
  log(bWriteLog and "UI_Match_Entry:OnMatchLTGetData isTest = " .. tostring(isTest))
  local logic_long_time_match = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_long_time_match)
  local shortestInfo = logic_long_time_match:GetLTMatchGuideInfo(ENUM_LT_REC_TYPE.SHORTEST)
  local recentInfo = logic_long_time_match:GetLTMatchGuideInfo(ENUM_LT_REC_TYPE.RECENT)
  local versionInfo = logic_long_time_match:GetLTMatchGuideInfo(ENUM_LT_REC_TYPE.VERSION)
  if not shortestInfo and not versionInfo and not recentInfo and not isTest then
    return
  end
  for i = 1, 2 do
    self:SetWidgetVisible(self.UIRoot["Button_RecPlay" .. i], false, true)
    self:SetWidgetVisible(self.UIRoot["Image_Line" .. i], false)
  end
  if not isTest then
    local recTypeList = logic_long_time_match:GetRecommendTypeList()
    local index = 1
    local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
    local _, curViewId = logic_mode_selection:GetCurSelectInfo()
    log(bWriteLog and string.format("UI_Match_Entry:OnMatchLTGetData curViewId=%s, recTypeCount=%d", tostring(curViewId), #recTypeList))
    for i = 1, #recTypeList do
      local info = logic_long_time_match:GetLTMatchGuideInfo(recTypeList[i])
      if info and info.view_id ~= curViewId then
        log(bWriteLog and string.format("UI_Match_Entry:OnMatchLTGetData accept rec_type=%d, view_id=%s, predict_time=%s", recTypeList[i], tostring(info.view_id), tostring(info.predict_time)))
        self:UpdateLTUI(index, info)
        index = index + 1
      else
        log(bWriteLog and string.format("UI_Match_Entry:OnMatchLTGetData skip rec_type=%d, view_id=%s, reason=%s", recTypeList[i], tostring(info and info.view_id), info == nil and "no data" or "same as current"))
      end
    end
    if index == 1 then
      log(bWriteLog and "UI_Match_Entry:OnMatchLTGetData no valid recommendation after filtering, skip")
      return
    end
  else
    logic_long_time_match:SetIsShowLTMatch(true)
    LogicMatchEntry.GMSetFakeDisplayData()
    local infos = {
      [1] = {
        map_info = {
          bAutoFill = false,
          isEnableFill = false,
          teamNum = 4,
          perspective = 100054
        },
        view_id = 10001,
        rec_type = 3,
        predict_time = 24
      },
      [2] = {
        map_info = {
          bAutoFill = false,
          isEnableFill = false,
          teamNum = 4,
          perspective = 100054
        },
        view_id = 12111,
        rec_type = 2,
        predict_time = 24
      }
    }
    for i = 1, 2 do
      self:SetWidgetVisible(self.UIRoot["Button_RecPlay" .. i], true, true)
      self:SetWidgetVisible(self.UIRoot["Image_Line" .. i], true)
      self:UpdateLTUI(i, infos[i])
    end
  end
  self:PlayExpandLTAnim(true)
end
function UI_Match_Entry:PlayExpandLTAnim(isShowTips)
  log(bWriteLog and "UI_Match_Entry:PlayExpandLTAnim isShowTips = " .. tostring(isShowTips))
  local time_ticker = require("common.time_ticker")
  if self.LTMatchAnimTimer then
    time_ticker.RemoveTimer(self.LTMatchAnimTimer)
    self.LTMatchAnimTimer = nil
  end
  self.LTMatchAnimTimer = time_ticker.AddTimer(self.UIRoot.Animation_ShrinkAndExpansion:GetEndTime(), function()
    self:SetWidgetVisible(self.UIRoot.SizeBox_top, true)
    self:SetWidgetVisible(self.UIRoot.Common_Tips_Bg02_UIBP, true)
    self:SetWidgetVisible(self.UIRoot.GridPanel_LTMatch, true)
    self:UpdateWaitForMatchBackground()
    EventSystem:postEvent(EVENTTYPE_SKILL_SELECTION, EVENTID_SKILL_SELECTION_MODE_OTHER_TIPS_SHOW)
    collapse(self.UIRoot.WaitForMatch)
    collapse(self.UIRoot.SameLanguageMatch)
    self:SetWidgetVisible(self.UIRoot.Border_0, true)
    self:SetWidgetVisible(self.UIRoot.Border_MatchInfo, false)
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_highLeveTips, false)
    self:PlayUserWidgetAnimation(self.UIRoot.Animation_MatchingGuide, 0, 1, 1, 1)
    self.MathInfoState = SHRINK
    self.nMatchPanelState = ENUM_MatchPanelState.LTOnly
    local LogicMatchEntry = require("client.slua.logic.lobby.Mid.logic_match_entry")
    local hasWaitForMatch = LogicMatchEntry.FigureWaitForMatch()
    local hasSameLanguage = LogicMatchEntry.IsShowSameLanguageMatch()
    local LogicModeMatchProgress = require("client.slua.logic.mode_selection.LogicModeMatchProgress")
    local canShowHL = LogicModeMatchProgress.CanShowHighLevelMatchTips()
    if not hasWaitForMatch and not hasSameLanguage and not canShowHL then
      self.MathInfoState = EXPAND
      self.UIRoot.Image_13:SetRenderAngle(180)
    else
      self.MathInfoState = SHRINK
      self.UIRoot.Image_13:SetRenderAngle(0)
    end
    coroutine.yield(self.UIRoot.Animation_MatchingGuide:GetEndTime())
    if isShowTips then
      local noticeSystem = require("client.slua.logic.common.logic_notice_mgr")
      noticeSystem.RemoveAllNotice()
      ShowNotice(38902)
    end
  end)
end
function UI_Match_Entry:OnMatchLTSwitchMode()
  log(bWriteLog and "UI_Match_Entry:OnMatchLTSwitchMode")
  self:StartMatch(true)
end
function UI_Match_Entry:UpdateLTUI(index, info)
  log(bWriteLog and "UI_Match_Entry:UpdateLTUI")
  self:SetWidgetVisible(self.UIRoot["Button_RecPlay" .. index], true, true)
  self:SetWidgetVisible(self.UIRoot["Image_Line" .. index], true)
  local logic_mode_utils = require("client.slua.logic.mode_selection.logic_mode_utils")
  local mapName = logic_mode_utils.GetMapNameByViewID(info.view_id, true) or ""
  self.UIRoot["TextBlock_LModeName" .. index]:SetText(mapName)
  local typeNameKey = 38905
  if info.rec_type == ENUM_LT_REC_TYPE.VERSION then
    typeNameKey = 38906
  elseif info.rec_type == ENUM_LT_REC_TYPE.SHORTEST then
    typeNameKey = 38907
  end
  if self.UIRoot["TextBlock_LTMatchType" .. index] then
    self.UIRoot["TextBlock_LTMatchType" .. index]:SetText(LocUtil.LocalizeResFormat(typeNameKey))
  end
  local teamNumKey = 38911
  if info.map_info.teamNum == 2 then
    teamNumKey = 38912
  elseif info.map_info.teamNum == 4 then
    teamNumKey = 38913
  end
  local teamNumText = LocUtil.LocalizeResFormat(teamNumKey)
  local perspectiveKey = 38904
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local filterInfo = logic_mode_selection:GetFilterInfo()
  if filterInfo.perspective == info.map_info.perspective and filterInfo.teamNum == info.map_info.teamNum then
    perspectiveKey = 7545
  end
  local perspectiveText = LocUtil.LocalizeResFormat(perspectiveKey, LocUtil.LocalizeResFormat(38909), teamNumText)
  if info.map_info.perspective and info.map_info.perspective == 100053 then
    perspectiveText = LocUtil.LocalizeResFormat(perspectiveKey, LocUtil.LocalizeResFormat(38910), teamNumText)
  end
  self.UIRoot["UTRichTextBlock_LPerspective" .. index]:SetText(perspectiveText)
  local TimeUtil = require("client.common.time_util")
  local time = TimeUtil.FormatCountDownTime_DH_or_HMS_or_MS(info.predict_time, true)
  self.UIRoot["UTRichTextBlock_LTime" .. index]:SetText(LocUtil.LocalizeResFormat(38914, time))
  self:AddOnClickedEventByControl(self.UIRoot["Button_RecPlay" .. index], self.OnClickButton_RecPlay, self, info, mapName, teamNumText)
end
function UI_Match_Entry:OnClickButton_RecPlay(info, mapName, teamNumText)
  log(bWriteLog and "UI_Match_Entry:OnClickButton_RecPlay")
  local perspectiveText = info.map_info.perspective == 100054 and LocUtil.LocalizeResFormat(38909) or LocUtil.LocalizeResFormat(38910)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  local msgData = {
    msg = LocUtil.LocalizeResFormat(38908, mapName, perspectiveText, teamNumText),
    styleType = CommonMsgBoxMgr.SHOW_TYPE_FOUR,
    clickOkCallback = function()
      local logic_long_time_match = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_long_time_match)
      logic_long_time_match:SetLTMatchSelectType(info.rec_type)
      self:CancelMatch()
    end
  }
  CommonMsgBoxMgr.Show(msgData.styleType, "", msgData.msg, msgData.clickOkCallback)
end
function UI_Match_Entry:ShowLTMatchCancelTips()
  log(bWriteLog and "UI_Match_Entry:ShowLTMatchCancelTips")
  if not GameStatus.IsInLobbyOrMainCity() then
    return
  end
  local week = 7
  local TimeUtil = require("client.common.time_util")
  local time = TimeUtil.FormatCountDownTime_DH_or_HMS_or_MS(MatchSystem.nEstimateTime, true)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  local almost_match_time = CDataTable.GetTableData("CancelMatchParams", "almost_match_time").Value
  local cancel_match_remind_time = CDataTable.GetTableData("CancelMatchParams", "cancel_match_remind_time").Value
  local matchingTime = MatchSystem.nMatchingTime
  local estimateTime = MatchSystem.nEstimateTime
  log(bWriteLog and string.format("UI_Match_Entry:ShowLTMatchCancelTips matchingTime:%s estimateTime:%s", tostring(matchingTime), tostring(estimateTime)))
  local stContent = LocUtil.LocalizeResFormat(38899, time or "")
  local result = matchingTime + almost_match_time - estimateTime
  if 0 < estimateTime and 0 < result and cancel_match_remind_time >= result then
    local cancel_match_remind_key = CDataTable.GetTableData("CancelMatchParams", "cancel_match_remind_key").Value
    stContent = LocUtil.GetLocalizeResStr(cancel_match_remind_key)
  end
  local msgData = {
    msg = stContent,
    styleType = CommonMsgBoxMgr.SHOW_TYPE_TWO,
    btnOK = LocUtil.LocalizeResFormat(38900),
    btnCancel = LocUtil.LocalizeResFormat(38901),
    clickOkCallback = function(isCheck)
      local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
      local reason = 1
      tlog_report_utils.ReportTLogEvent(TLogEventDefine.MatchLT_SelectResult, reason)
      if not isCheck then
        return
      end
      tlog_report_utils.ReportTLogEvent(TLogEventDefine.MatchLT_CheckNoTips)
      PlayerPrefsSystem.CheckAndSaveCurrentDate_N(PlayerPrefsSystem.ePlayerPrefsType.eMatchLTTipsCheckTime, false, week)
    end,
    clickCancelCallback = function(isCheck)
      self:CancelMatch()
      local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
      local reason = 2
      tlog_report_utils.ReportTLogEvent(TLogEventDefine.MatchLT_SelectResult, reason)
      if not isCheck then
        return
      end
      tlog_report_utils.ReportTLogEvent(TLogEventDefine.MatchLT_CheckNoTips)
      PlayerPrefsSystem.CheckAndSaveCurrentDate_N(PlayerPrefsSystem.ePlayerPrefsType.eMatchLTTipsCheckTime, false, week)
    end,
    extraData = {
      isShowCheckBox = true,
      checkBoxText = LocUtil.LocalizeResFormat(42731),
      closeOnSwitch = true
    }
  }
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(msgData.styleType, msgData.title or "", msgData.msg, msgData.clickOkCallback, msgData.clickCancelCallback, msgData.btnOK, msgData.btnCancel, msgData.extraData)
end
function UI_Match_Entry:ReqLTMatch()
  log(bWriteLog and "UI_Match_Entry:ReqLTMatch")
  local logic_long_time_match = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_long_time_match)
  if not logic_long_time_match:IsNeedReqLTMatch() then
    return
  end
  logic_long_time_match:get_long_time_match_mode()
end
function UI_Match_Entry:OnMatchResOK()
  local logic_long_time_match = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_long_time_match)
  self.bMatching = logic_long_time_match:CheckShowMatchUpdateTips(false)
end
function UI_Match_Entry:CheckMatchUpdateTips()
  local logic_long_time_match = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_long_time_match)
  if self.bMatching and logic_long_time_match:CheckShowMatchUpdateTips(true) then
    self.bMatching = false
    logic_long_time_match:ShowMatchUpdateTips()
  end
end
function UI_Match_Entry:ONFBStartMatch()
  log(bWriteLog and "UI_Match_Entry:ONFBStartMatch")
  self:StartMatch(true)
end
function UI_Match_Entry:OnWidgetHide()
  log(bWriteLog and "UI_Match_Entry:OnWidgetHide")
  self:AddTimerOnce(0, function()
    if not GameStatus.IsInLobbyOrMainCity() then
      return
    end
    local lobbyMain = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
    if not lobbyMain or lobbyMain:GetVisibility() == UEnums.ESlateVisibility.Collapsed then
      log(bWriteLog and "UI_Match_Entry:OnWidgetHide isn't in lobby!")
      return
    end
    if self.UIRoot.GuidePanel:GetVisibility() ~= UEnums.ESlateVisibility.Collapsed then
      return
    end
    self:RefreshHandGuide()
  end)
end
function UI_Match_Entry:OnModHotStatChange(_, _, ModID, HotStat)
  print(bWriteLog and "UI_Match_Entry:OnModHotStatChange", ModID)
  self:InitModHotStatShow(HotStat)
end
function UI_Match_Entry:InitModHotStatShow(HotStat)
  if FuncUtil.IsInXMission() then
    self.UIRoot.HorizontalBox_HotStat:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  if logic_mode_selection.hasSelectTxMission then
    self.UIRoot.HorizontalBox_HotStat:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  local Util_UGC = require("client.slua.logic.ugc.util_ugc")
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  local mod_id = tonumber(LogicUGCMatch:GetMatchModID())
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local modInfo = LogicUGC:GetModByAllCache(mod_id)
  if HotStat and HotStat.start_type == Config_UGC.E_UGCGameStartType.Smart and not Util_UGC.IsSubModeGameMod(modInfo and modInfo.pub_mod_meta) then
    self.UIRoot.HorizontalBox_HotStat:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    local state = HotStat.heat_level - 1
    self.UIRoot.Image_Hot:SetActiveColorIndex(state)
    if state == 0 then
      self.UIRoot.TextBlock_QuickStart:SetText(LocUtil.LocalizeResFormat(792523))
    elseif state == 1 then
      self.UIRoot.TextBlock_QuickStart:SetText(LocUtil.LocalizeResFormat(792524))
    else
      self.UIRoot.HorizontalBox_HotStat:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  else
    self.UIRoot.HorizontalBox_HotStat:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function UI_Match_Entry:OnUGCPlayHallRoomCreate()
  print(bWriteLog and "UI_Match_Entry:OnUGCPlayHallRoomCreate")
  self:InitUGCPlayHallRoomShow()
end
function UI_Match_Entry:InitUGCPlayHallRoomShow()
  self.UIRoot.WidgetSwitcher_State:SetActiveWidgetIndex(4)
  self.UIRoot.TextBlock_Entry:SetText(LocUtil.LocalizeResFormat(792521))
  local MatchInfo
  local UGCPlayHallRoom = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.UGCPlayHallRoom)
  if not UGCPlayHallRoom then
    return
  end
  local MatchNum = UGCPlayHallRoom:GetMatchNum()
  if 1 < MatchNum then
    MatchInfo = UGCPlayHallRoom:GetFastestMatchInfo()
    if MatchInfo then
      local Num1, Num2 = UGCPlayHallRoom:GetCurMatchStartPlayerNumByID(MatchInfo.RoomID)
      if MatchInfo then
        local NumStr = LocUtil.LocalizeResFormat(792522, Num1, Num2)
        self.UIRoot.TextBlock_Player:SetText(LocUtil.LocalizeResFormat(86343, NumStr))
      end
    end
  else
    MatchInfo = UGCPlayHallRoom:GetRoomMatchInfo()
    if MatchInfo then
      local Num1, Num2 = UGCPlayHallRoom:GetCurMatchStartPlayerNumByID(MatchInfo.RoomID)
      self.UIRoot.TextBlock_Player:SetText(LocUtil.LocalizeResFormat(792522, Num1, Num2))
    end
  end
  if self.ugcPlayHallTimer then
    self:RemoveTimer(self.ugcPlayHallTimer)
  end
  self.ugcPlayHallTimer = self:AddTimerLoop(0, function()
    local TimeUtil = require("client.common.time_util")
    local UGCPlayHallRoom = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.UGCPlayHallRoom)
    if UGCPlayHallRoom then
      local room = UGCPlayHallRoom:GetLongestRoom()
      local time = TimeUtil.GetServerTimeInSec() - (room and room.CreateTime or 0) + 1
      time = math.max(1, time)
      local timeStr = TimeUtil.FormatCountDownTime_DH_or_HMS_or_MS(time)
      self.UIRoot.TextBlock_UGCMatchTime:SetText(timeStr)
    end
  end, TIMER_INFINITE, 1)
end
function UI_Match_Entry:OnRoomAutoStartInfoChange()
  print(bWriteLog and "UI_Match_Entry:OnRoomAutoStartInfoChange")
  self:InitUGCPlayHallRoomShow()
end
function UI_Match_Entry:OnMatchRoomPlayerChange()
  print(bWriteLog and "UI_Match_Entry:OnMatchRoomPlayerChange")
  self:InitUGCPlayHallRoomShow()
end
function UI_Match_Entry:OnUGCPlayHallRoomExit()
  self:UpdateStatus()
end
function UI_Match_Entry:RefreshUGCMatchPendingShow()
  local Status = MatchSystem.nMatchStatus
  local UGCPlayHallRoom = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.UGCPlayHallRoom)
  if not UGCPlayHallRoom then
    return
  end
  local bPendingMatch = UGCPlayHallRoom:CheckPendingMatchState()
  print(bWriteLog and "UI_Match_Entry:RefreshUGCMatchPendingShow", Status, bPendingMatch)
  local WidgetSwitcher_State = self.UIRoot.WidgetSwitcher_State
  local TextBlock_Readying = self.UIRoot.TextBlock_Readying
  if Status == E_MatchStatus.Matching then
    if bPendingMatch then
      WidgetSwitcher_State:SetActiveWidgetIndex(1)
      TextBlock_Readying:SetText(LocUtil.GetLocalizeResStr(86342))
      return false
    else
    end
  else
    if Status == E_MatchStatus.Not and bPendingMatch then
      WidgetSwitcher_State:SetActiveWidgetIndex(1)
      TextBlock_Readying:SetText(LocUtil.GetLocalizeResStr(86342))
      return false
    else
    end
  end
  return true
end
function UI_Match_Entry:OnUGCPlayHallPendingMatchCancel()
  print(bWriteLog and "UI_Match_Entry:OnUGCPlayHallPendingMatchCancel")
  self:UpdateStatus()
end
function UI_Match_Entry:UpdateWaitForMatchBackground()
  local bWaitForMatchVisible = self.UIRoot.WaitForMatch:GetVisibility() ~= UEnums.ESlateVisibility.Collapsed
  local bLTMatchVisible = self.UIRoot.GridPanel_LTMatch:GetVisibility() ~= UEnums.ESlateVisibility.Collapsed
  local bSameLanguageMatchVisible = self.UIRoot.SameLanguageMatch:GetVisibility() ~= UEnums.ESlateVisibility.Collapsed
  local bTeammateMatchVisible = self.UIRoot.TeammateMatch:GetVisibility() ~= UEnums.ESlateVisibility.Collapsed
  local bMatchTipsVisible = self.UIRoot.MatchTips:GetVisibility() ~= UEnums.ESlateVisibility.Collapsed
  local bHighLevelTipsVisible = self.UIRoot.CanvasPanel_highLeveTips:GetVisibility() ~= UEnums.ESlateVisibility.Collapsed
  local bShowBackground = bWaitForMatchVisible or bLTMatchVisible or bSameLanguageMatchVisible or bTeammateMatchVisible or bMatchTipsVisible or bHighLevelTipsVisible
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_44, bShowBackground)
  self:SetWidgetVisible(self.UIRoot.Image_Arrow, bShowBackground)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CUIMatch_Entry = class(ui_base, nil, UI_Match_Entry)
return CUIMatch_Entry