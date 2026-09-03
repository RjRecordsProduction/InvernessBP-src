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
local C_BtnBGNarutoPath = "/Game/UMG/Texture_200/Atlas/Lobby/Frames/Lobby_Image_Start_Bg04_png.Lobby_Image_Start_Bg04_png"
local C_BtnBGNormalPath = "/Game/UMG/Texture_200/Atlas/Lobby/Frames/Lobby_Image_Start_Bg02_png.Lobby_Image_Start_Bg02_png"
local C_BtnBGNormalYellowPath = "/Game/UMG/Texture_200/Atlas/Lobby/Frames/Lobby_Image_Start_Bg_png.Lobby_Image_Start_Bg_png"
local bgNodeList = {
  "Image_bg2",
  "Image_bg3",
  "Image_bg5",
  "Image_bg6",
  "Image_bg9",
  "Image_bg10"
}
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
  self.nConfirmCloseTime = 0
  self.bShowPloyTextTip = false
  self.nSkinID = C_SkinID
  self.preMatchState = nil
  self.MathInfoState = SHRINK
  self.nMatchPanelState = ENUM_MatchPanelState.Collapsed
  self.bHighLevelTipsExpanded = false
  self.bDebugTimersSet = false
  self._bLTMatchShown = false
  self._bHighLevelTipsShown = false
  self.bTeammatesMatched = false
  self.bTeammatesMatchedTimerPending = false
  self.bTeammatesMatchedTimer = nil
  self.bShowHistory = false
  self.needRecoverWin = false
  self.LTMatchAnimTimer = nil
  self.bIsNarutoView = false
end
function UI_Match_Entry:OnInitialize()
  UI_Match_Entry.__super.OnInitialize(self)
  MatchSystem.InitData()
  self.doubelCardUI = self:CreateChildWindow("CanvasPanel_DoubleCard", UIManager.UI_Config.lobby_doublecard_entrance)
  log("UI_Match_Entry:OnInitialize")
  self.isInNarutoVersionTime = LobbySystem.IsInNarutoVersionTime()
  if self.isInNarutoVersionTime then
    self.FlameShadow_Start_UIBP = self:CreateChildWindow("CanvasPanel_Theme", UIManager.UI_Config.FlameShadow_Start_UIBP)
  end
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
  self:AddCommonEvent(EVENTTYPE_PROMOTION, EVENTID_PROMOTION_SELECT_PROMOTION_RSP, self.OnPromotionSelectChanged, self)
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_MATCH_VIEW_SELECT_CHANGE, self.OnMatchViewSelectChange, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_NEW_TEAM_MATCH_MODE, self.CheckReturnMatchTips, self)
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
  show(self.UIRoot.Common_Tips_Bg02_UIBP)
  self:CheckReturnMatchTips()
end
function UI_Match_Entry:OnShow()
  log(bWriteLog and "UI_Match_Entry:OnShow")
  if MatchSystem.nMatchStatus ~= E_MatchStatus.Matching then
    self:SetWidgetVisible(self.UIRoot.Border_0, false)
    self:_SetLTMatchVisible(false)
    collapse(self.UIRoot.SizeBox_top)
    self:_SetHighLevelTipsVisible(false)
    self:UpdateWaitForMatchBackground()
    self.MathInfoState = SHRINK
    self.bHighLevelTipsExpanded = false
    self.nMatchPanelState = ENUM_MatchPanelState.Collapsed
    self.UIRoot.Image_13:SetRenderAngle(0)
    local anim = self.UIRoot.Animation_ShrinkAndExpansion
    self:PlayUserWidgetAnimation(anim, 0, 1, SHRINK, 1)
  end
  self:SetWidgetVisible(self.UIRoot.Image_29, false)
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
  local LobbyModUtils = require("GameLua.Mod.Lobby.Base.Common.LobbyModUtils")
  if LobbyModUtils.IsModDownloaded(LobbyModUtils.Enum_Mod_Name.EName_ModeSelection) then
    log(bWriteLog and "UI_Match_Entry:OnModePostSwitch EName_ModeSelection has download")
    local new_mode_entry_ui = self:CreateChildWindow(self.UIRoot.New_Mode, UIManager.UI_Config.lobby_mode_entry)
    new_mode_entry_ui:SetAutoSize(true)
    self.  else
    LobbyModUtils.CreateDownloadUIByModKeyReturnUIBase(LobbyModUtils.Enum_Mod_Name.EName_ModeSelection, self, self.UIRoot.New_Mode, {
      callback = function()
        log(bWriteLog and "UI_Match_Entry:OnModePostSwitch EName_ModeSelection callback")
        if not slua.isValid(self.UIRoot) then
          return
        end
        if self.new_mode_entry_ui then
          return
        end
        local new_mode_entry_ui = self:CreateChildWindow(self.UIRoot.New_Mode, UIManager.UI_Config.lobby_mode_entry)
        new_mode_entry_ui:SetAutoSize(true)
        self.      end
    })
  end
  self:UpdatePreBtn()
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
        self:TryApplyCustomState(true)
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
  local WidgetSwitcher_Matching = self.UIRoot.WidgetSwitcher_Matching
  log(bWriteLog and "UI_Match_Entry:InitMatchStyle is_sync_match_process = ", MatchSystem.is_sync_match_process)
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
    self:_SetHighLevelTipsVisible(false, false)
    self:UpdateWaitForMatchBackground()
    self.canShowBigBG = false
  end
  if status == ENUM_MatchStatus.Matching then
    self:InitMatchStyle()
  else
    self.UIRoot.WidgetSwitcher_Matching:SetActiveWidgetIndex(0)
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
      self:TryApplyCustomState(true)
      root.Text_State:SetText(LocUtil.LocalizeResFormat(8982, MentorSystem.mentor_team_waiting_time))
    elseif TeamUpNewSystem.IsTeamLeader() then
      if TeamUpNewSystem.GetTeamNum() > 1 and not TeamUpNewSystem.IsEverybodyReady() then
        self:RefreshTeamReadyNum(root)
      else
        root.WidgetSwitcher_State:SetActiveWidgetIndex(3)
        self:TryApplyCustomState()
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
    self:TryApplyCustomState()
    root.Text_State:SetText(LocUtil.GetLocalizeResStr(7504))
  elseif TeamUpNewSystem.IsTeamLeader() then
    if TeamUpNewSystem.GetTeamNum() > 1 and not TeamUpNewSystem.IsEverybodyReady() then
      self:RefreshTeamReadyNum(root)
    elseif self:IsFreeInOutState() then
      root.WidgetSwitcher_State:SetActiveWidgetIndex(6)
      self:TryApplyCustomState()
      root.TextBlock_JoinGame:SetText(LocUtil.GetLocalizeResStr(78430))
    else
      root.WidgetSwitcher_State:SetActiveWidgetIndex(3)
      self:TryApplyCustomState()
    end
    log(bWriteLog and "[DeanJYT] UI_Match_Entry:UpdateStatus IsTeamLeader")
    self:_SetLTMatchVisible(false)
    self:SetWidgetVisible(self.UIRoot.Border_0, false)
    self:UpdateWaitForMatchBackground()
    EventSystem:postEvent(EVENTTYPE_SKILL_SELECTION, EVENTID_SKILL_SELECTION_MODE_OTHER_TIPS_HIDE)
  elseif not self:CheckMemberMatchRestrict(root) then
    root.WidgetSwitcher_State:SetActiveWidgetIndex(0)
    self:TryApplyCustomState(true)
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
    LogicMatchEntry.CalculateMatchDisplay()
    self:RefreshFindingTeammates()
    self:ProcessEnterMatch()
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
  self:_ApplyPromotionStartButtonStateIfNeeded(status)
end
function UI_Match_Entry:_ApplyPromotionStartButtonStateIfNeeded(matchStatus)
  if not self:IsValid() or not slua.isValid(self.UIRoot) then
    return
  end
  if matchStatus == E_MatchStatus.Matching or matchStatus == E_MatchStatus.Success then
    self:_SetPromotionFxVisible(false)
    return
  end
  local logic_promotion_mode = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_promotion_mode)
  local bIsOpenPromotion = logic_promotion_mode and logic_promotion_mode:IsOpenPromotion()
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local bIsInTeam = TeamUpNewSystem.GetTeamNum() > 1
  if bIsInTeam then
    local bShowFx = false
    if bIsOpenPromotion then
      local curIndex = self.UIRoot.WidgetSwitcher_State:GetActiveWidgetIndex()
      bShowFx = curIndex == 0 or curIndex == 3
    end
    self:_SetPromotionFxVisible(bShowFx)
    return
  end
  if not bIsOpenPromotion then
    self:_SetPromotionFxVisible(false)
    return
  end
  log(bWriteLog and "UI_Match_Entry:_ApplyPromotionStartButtonStateIfNeeded set state to 7")
  self.UIRoot.WidgetSwitcher_State:SetActiveWidgetIndex(7)
  self:TryApplyCustomState()
  self.UIRoot.TextBlock_0:SetText(LocUtil.LocalizeResFormat(68193))
  self:_SetPromotionFxVisible(true)
end
function UI_Match_Entry:_SetPromotionFxVisible(bVisible)
  if self.UIRoot.Fx_CanvasPanel then
    self:SetWidgetVisible(self.UIRoot.Fx_CanvasPanel, bVisible)
  end
end
function UI_Match_Entry:OnPromotionSelectChanged()
  log(bWriteLog and "UI_Match_Entry:OnPromotionSelectChanged")
  self:UpdateStatus()
end
function UI_Match_Entry:TryApplyCustomState(jumpSetState)
  self:SetBtnBgByIsNaruto()
  local curIndex = self.UIRoot.WidgetSwitcher_State:GetActiveWidgetIndex()
  if curIndex == 10 and self.lastStateIndex then
    self.UIRoot.WidgetSwitcher_State:SetActiveWidgetIndex(self.lastStateIndex)
  end
  local bShouldApply = self.isInNarutoVersionTime
  if not bShouldApply then
    return
  end
  if not self.FlameShadow_Start_UIBP then
    log(bWriteLog and "UI_Match_Entry:TryApplyCustomState no FlameShadow_Start_UIBP")
    return
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local _, viewId = logic_mode_selection:GetCurSelectInfo()
  local logic_mode_utils = require("client.slua.logic.mode_selection.logic_mode_utils")
  if not viewId or not logic_mode_utils.IsNarutoView(viewId) then
    return
  end
  if jumpSetState then
    log(bWriteLog and "UI_Match_Entry:TryApplyCustomState jumpSetState")
    return
  end
  log(bWriteLog and "UI_Match_Entry:TryApplyCustomState set state to 10, from " .. tostring(curIndex))
  if curIndex == 0 or curIndex == 3 or curIndex == 6 or curIndex == 7 then
    self.lastStateIndex = curIndex
    self.UIRoot.WidgetSwitcher_State:SetActiveWidgetIndex(10)
  end
end
function UI_Match_Entry:SetBtnBgByIsNaruto()
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local _, viewId = logic_mode_selection:GetCurSelectInfo()
  local logic_mode_utils = require("client.slua.logic.mode_selection.logic_mode_utils")
  local bIsNaruto = viewId and logic_mode_utils.IsNarutoView(viewId)
  if self.bIsNarutoView == bIsNaruto then
    return
  end
  self.bIsNarutoView = bIsNaruto
  local bgPath = bIsNaruto and C_BtnBGNarutoPath or C_BtnBGNormalPath
  for k, v in ipairs(bgNodeList) do
    if self.UIRoot[v] then
      self:SetTexture(self.UIRoot[v], bgPath)
    end
  end
  local yellowBgPath = bIsNaruto and C_BtnBGNarutoPath or C_BtnBGNormalYellowPath
  if self.UIRoot.Image_bg1 then
    self:SetTexture(self.UIRoot.Image_bg1, yellowBgPath)
  end
end
function UI_Match_Entry:OnMatchViewSelectChange()
  self:TryApplyCustomState()
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
          log(bWriteLog and "match_new_entry:CheckMemberMatchRestrict state =" .. tostring(state))
          bMapNotDownloaded = state ~= PufferConst.ENUM_DownloadState.Done
        else
          log(bWriteLog and "UI_Match_Entry:CheckMemberMatchRestrict cacheMod or pub_mod_meta is nil")
          bMapNotDownloaded = true
        end
      else
        log(bWriteLog and "UI_Match_Entry:CheckMemberMatchRestrict matchInfo or mod_id is nil")
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
  self:RefreshFindingTeammates()
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
    self:_SetHighLevelTipsVisible(canShow, false)
    self:UpdateWaitForMatchBackground()
  end
  if canShow and not self.bHighLevelTipsExpanded then
    self.bHighLevelTipsExpanded = true
    if not logic_long_time_match:GetIsShowLTMatch() then
      show(self.UIRoot.SizeBox_top)
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
  self.bTeammatesMatched = false
  self.bTeammatesMatchedTimerPending = false
  if self.bTeammatesMatchedTimer then
    self:RemoveTimer(self.bTeammatesMatchedTimer)
    self.bTeammatesMatchedTimer = nil
  end
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
  if not DoFirstMatch then
    return
  end
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
  time_ticker.AddTimerOnce(1, function()
    logic_connection_waiting:Hide(0)
  end)
  local delayCallback = function()
    local useNewGuide = LobbySystem.CheckUseNewGuide()
    local cb = function()
      self:OnClickEntry()
      if useNewGuide then
        self:HideGuidePanel()
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
  end
  self:AddTimer(1, delayCallback)
  growthprojectMgrB.DoFirstMatch = false
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
  collapse(self.UIRoot.TeammateMatch)
  selfHit(self.UIRoot.Panel_Mode_Selected)
  collapse(self.UIRoot.HorizontalBox_HotStat)
  self:_SetLTMatchVisible(false)
  self:_SetHighLevelTipsVisible(false)
  self:UpdateWaitForMatchBackground()
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
  if display or LogicMatchEntry.HasMatchInfoToDisplay() then
    self:UpdateWaitForMatchBackground()
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
    if self.bTeammatesMatchedTimer then
      self:RemoveTimer(self.bTeammatesMatchedTimer)
      self.bTeammatesMatchedTimer = nil
      self.bTeammatesMatchedTimerPending = false
    end
    self:SetWidgetVisible(self.UIRoot.Border_0, false)
    self:_SetLTMatchVisible(false)
    collapse(self.UIRoot.SizeBox_top)
    self:_SetHighLevelTipsVisible(false)
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
      if not self:_IsLTMatchShown() then
        self:_SetLTMatchVisible(true)
        self:SetWidgetVisible(self.UIRoot.Border_0, true)
        self:PlayUserWidgetAnimation(self.UIRoot.Animation_MatchingGuide, 0, 1, 1, 1)
        self:_SetHighLevelTipsVisible(false)
        self:UpdateWaitForMatchBackground()
        self.MathInfoState = SHRINK
        local LogicModeMatchProgress = require("client.slua.logic.mode_selection.LogicModeMatchProgress")
        local canShowHL = LogicModeMatchProgress.CanShowHighLevelMatchTips()
        if not canShowHL then
          self.UIRoot.Image_13:SetRenderAngle(180)
        else
          self.UIRoot.Image_13:SetRenderAngle(0)
        end
      else
        self:SetWidgetVisible(self.UIRoot.Border_0, true)
        LogicMatchEntry.CalculateMatchDisplay()
        local LogicModeMatchProgress = require("client.slua.logic.mode_selection.LogicModeMatchProgress")
        local canShowHL = LogicModeMatchProgress.CanShowHighLevelMatchTips()
        if not canShowHL then
          log(bWriteLog and "UI_Match_Entry:Driven EXPAND - no sub-panel data, shrink directly")
          self.UIRoot.Image_13:SetRenderAngle(180)
          self:Driven(SHRINK)
          return
        end
        self:_SetHighLevelTipsVisible(canShowHL)
        self:UpdateWaitForMatchBackground()
        self:UpdateMatchingTime()
        self.nMatchPanelState = ENUM_MatchPanelState.LTExpanded
        self.UIRoot.Image_13:SetRenderAngle(180)
      end
    elseif self.nMatchPanelState == ENUM_MatchPanelState.LTExpanded then
      self:_SetHighLevelTipsVisible(false)
      self:UpdateWaitForMatchBackground()
      self.nMatchPanelState = ENUM_MatchPanelState.LTOnly
      self.MathInfoState = EXPAND
      self.UIRoot.Image_13:SetRenderAngle(180)
    else
      self:_SetHighLevelTipsVisible(false)
      self:PlayUserWidgetAnimation(self.UIRoot.Animation_MatchingGuide, 0, 1, 0, 1)
      self:_SetLTMatchVisible(false)
      self:SetWidgetVisible(self.UIRoot.Border_0, false)
      self:UpdateWaitForMatchBackground()
      self.UIRoot.Image_13:SetRenderAngle(0)
    end
  else
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
function UI_Match_Entry:OnQRCodeRestrictChange()
  log(bWriteLog and "UI_Match_Entry:OnQRCodeRestrictChange")
  self:RefreshQRCodeBattleRestrict()
end
function UI_Match_Entry:RefreshFindingTeammates()
  if not self.UIRoot or not self.UIRoot.WidgetSwitcher_State then
    return
  end
  if MatchSystem.nMatchStatus ~= E_MatchStatus.Matching then
    return
  end
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  local LogicUGCMulti = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMulti)
  if tonumber(LogicUGCMatch:GetMatchModID()) > 0 or LogicUGCMulti.bIsBundleMatch then
    return
  end
  local widgetSwitcher = self.UIRoot.WidgetSwitcher_State
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local filterInfo = logic_mode_selection:GetFilterInfo()
  local teamNum = filterInfo.teamNum or 4
  local logic_mode_asymmertric = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_asymmertric)
  if logic_mode_asymmertric:GetHasSelectedCamp() and logic_mode_asymmertric:GetCampForMatch() == 1 then
    teamNum = 1
  end
  local bShowTeammateMatch = LogicMatchEntry.IsShowTeammateMatch()
  local matchedNum = math.min(LogicMatchEntry.GetTeammateMatchNum(), teamNum)
  local bFinding = bShowTeammateMatch and not self.bTeammatesMatched
  if bShowTeammateMatch and teamNum <= matchedNum and not self.bTeammatesMatched and not self.bTeammatesMatchedTimerPending then
    self.bTeammatesMatchedTimerPending = true
    if self.bTeammatesMatchedTimer then
      self:RemoveTimer(self.bTeammatesMatchedTimer)
      self.bTeammatesMatchedTimer = nil
    end
    self.bTeammatesMatchedTimer = self:AddTimerOnce(2, function()
      self.bTeammatesMatchedTimer = nil
      if self and not self.bTeammatesMatched and self.UIRoot then
        self.bTeammatesMatched = true
        self.bTeammatesMatchedTimerPending = false
        self:RefreshFindingTeammates()
      end
    end)
  end
  local TimeUtil = require("client.common.time_util")
  local timeStr = TimeUtil.FormatCountDownTime_DH_or_HMS_or_MS(MatchSystem.nMatchingTime or 0, true)
  if bFinding then
    widgetSwitcher:SetActiveWidgetIndex(8)
    if self.UIRoot.TextBlock_FindingTeammatesNum then
      self.UIRoot.TextBlock_FindingTeammatesNum:SetText(LocUtil.LocalizeResFormat(35014, matchedNum, teamNum))
    end
    if self.UIRoot.TextBlock_FindingTeammatesTime then
      self.UIRoot.TextBlock_FindingTeammatesTime:SetText(timeStr)
    end
  elseif MatchSystem.waitLine and MatchSystem.waitLine.nPos and 0 < MatchSystem.waitLine.nPos then
    widgetSwitcher:SetActiveWidgetIndex(9)
    if self.UIRoot.TextBlock_QueueError then
      local nPos = MatchSystem.waitLine.nPos
      local posStr = nPos < 100 and "100+" or tostring(nPos)
      self.UIRoot.TextBlock_QueueError:SetText(LocUtil.LocalizeResFormat(6382, posStr))
    end
    if self.UIRoot.TextBlock_QueueErrorTime then
      self.UIRoot.TextBlock_QueueErrorTime:SetText(timeStr)
    end
  else
    widgetSwitcher:SetActiveWidgetIndex(2)
  end
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
    self:_SetLTMatchVisible(true)
    self:UpdateWaitForMatchBackground()
    EventSystem:postEvent(EVENTTYPE_SKILL_SELECTION, EVENTID_SKILL_SELECTION_MODE_OTHER_TIPS_SHOW)
    self:SetWidgetVisible(self.UIRoot.Border_0, true)
    self:_SetHighLevelTipsVisible(false)
    self:UpdateWaitForMatchBackground()
    self:PlayUserWidgetAnimation(self.UIRoot.Animation_MatchingGuide, 0, 1, 1, 1)
    self.MathInfoState = SHRINK
    self.nMatchPanelState = ENUM_MatchPanelState.LTOnly
    local LogicModeMatchProgress = require("client.slua.logic.mode_selection.LogicModeMatchProgress")
    local canShowHL = LogicModeMatchProgress.CanShowHighLevelMatchTips()
    if not canShowHL then
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
function UI_Match_Entry:_SetLTMatchVisible(bShow)
  self._bLTMatchShown = bShow and true or false
  self:SetWidgetVisible(self.UIRoot.GridPanel_LTMatch, bShow)
end
function UI_Match_Entry:_SetHighLevelTipsVisible(bShow, bUseCollapse)
  self._bHighLevelTipsShown = bShow and true or false
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_highLeveTips, bShow, bUseCollapse)
end
function UI_Match_Entry:_IsLTMatchShown()
  return self._bLTMatchShown == true
end
function UI_Match_Entry:UpdateWaitForMatchBackground()
  local bShowBackground = self._bLTMatchShown or self._bHighLevelTipsShown
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_BG, bShowBackground)
  self:SetWidgetVisible(self.UIRoot.Image_Arrow, bShowBackground)
end
function UI_Match_Entry:HideGuidePanel()
  log(bWriteLog and "UI_Match_Entry:HideGuidePanel")
  self:SetWidgetVisible(self.UIRoot.GuidePanel, false)
end
function UI_Match_Entry:CheckReturnMatchTips()
  local logic_return_activity_first_battle = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_activity_first_battle)
  if logic_return_activity_first_battle:IsShowMatchTips() then
    self:SetWidgetVisible(self.UIRoot.ReturnActivity, true)
    self.UIRoot.UTRichTextBlock_1:SetText(LocUtil.GetLocalizeResStr(67997))
  else
    self:SetWidgetVisible(self.UIRoot.ReturnActivity, false)
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CUIMatch_Entry = class(ui_base, nil, UI_Match_Entry)
return CUIMatch_Entry