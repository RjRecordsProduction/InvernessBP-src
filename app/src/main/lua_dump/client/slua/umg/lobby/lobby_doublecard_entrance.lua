local logic_buffer_panel_for_act = require("client.slua.logic.activity.rating_protect_activity.logic_buffer_panel_for_act")
local Lobby_Segment_Protect_UIBP = {}
local E_IconType = {
  ChallengeScore = 6,
  KeyGame = 8,
  ChallengeScoreAddtion = 9,
  CSNotEnough = 10,
  CSNotEnoughAddtion = 11,
  WorldCupScorePortect = 16,
  WorldCupTeamUpAddRating = 17,
  WorldCupDoubleChallenge = 18,
  WorldCupUpvoteDoublePopularity = 19,
  WorldCupTeamUpDoubleIntimacy = 20
}
local DefaultScrollBgPath = "/Game/UMG/Texture/Atlas/Common_Atlas/Frames/DL_icon_tips_png.DL_icon_tips_png"
local ActCfgList = {
  CrazyWeekendAct = {
    ScrollBgPath = "/Game/UMG/Texture_200/Lobby_NoAtlas/Lobby_Activity/CrazyWeeken/CrazyWeekend_Tips_410BG.CrazyWeekend_Tips_410BG",
    IconPath = "/Game/UMG/Texture_200/Lobby_NoAtlas/Lobby_Activity/CrazyWeeken/CrazyWeekend_Icon_410Fist.CrazyWeekend_Icon_410Fist"
  }
}
function Lobby_Segment_Protect_UIBP:ctor(selfType, IsPeakGame)
  log(bWriteLog and "Lobby_Segment_Protect_UIBP:ctor IsPeakGame = " .. tostring(IsPeakGame))
  self.  self.DelayRefreshIconAndTipsTimer = nil
  self.bCreatedInMainCity = GameStatus.IsInMainCity() or false
end
function Lobby_Segment_Protect_UIBP:OnInitialize()
  Lobby_Segment_Protect_UIBP.__super.OnInitialize(self)
  log(bWriteLog and "Lobby_Segment_Protect_UIBP:OnInitialize")
  self.Canvas_ShieldInfpTips = self.UIRoot.Canvas_ShieldInfpTips
  self.bShowScrollTips = false
  self.bClassicMode = true
  self.hasDataShow = false
  self.bFirstWinVisible = false
end
function Lobby_Segment_Protect_UIBP:RegistEvents()
  Lobby_Segment_Protect_UIBP.__super.RegistEvents(self)
  log(bWriteLog and "Lobby_Segment_Protect_UIBP:RegistEvents")
  self:AddOnClickedEventByControl(self.UIRoot.Button_0, self.OnClickShowProtectTips, self)
  if self.UIRoot.Button_Veteran then
    self:AddOnClickedEventByControl(self.UIRoot.Button_Veteran, self.OnClickVeteran, self)
  end
  if self.UIRoot.Button_Qualifying then
    self:AddOnClickedEventByControl(self.UIRoot.Button_Qualifying, self.OnClickShowPromotionTips, self)
  end
  if self.UIRoot.Button_Gift then
    self:AddOnClickedEventByControl(self.UIRoot.Button_Gift, self.OnClickButton_Gift, self)
  end
  if self.UIRoot.Common_Qualifying_Rounds_ArrowButton_UIBP and self.UIRoot.Common_Qualifying_Rounds_ArrowButton_UIBP.Button_ArrowTips then
    self:AddOnClickedEventByControl(self.UIRoot.Common_Qualifying_Rounds_ArrowButton_UIBP.Button_ArrowTips, self.OnClickShowPromotionChallenge, self)
  end
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_SWITCHTO_PAGE_END, self.OnSwitchToPageEnd, self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, self.OnActivityDataChanged, self)
  self:AddCommonEvent(EVENTTYPE_ROLEINFO, EVENTID_SEASON_CHANLLENGE_SCORE, self.DelayRefreshIconAndTips, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_LOBBY_SOCIAL_PHOTO, self.OnRefreshUIVisible, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_LOBBY_SOCIAL_EDIT_STATUS, self.OnRefreshUIVisible, self)
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_MATCH_MODE_SELECT_CHANGE, self.OnSelectionModeChange, self)
  self:AddCommonEvent(EVENTTYPE_ACTIVITY, EVENTID_RATING_PROTECT_ACTIVITY_GET_CONFIG, self.OnGetScoreProtectModeCfg, self)
  self:AddCommonEvent(EVENTTYPE_WORLDCUP, EVENTID_WORLDCUP_GET_ACTIVITY_LIST, self.DelayRefreshIconAndTips, self)
  self:AddCommonEvent(EVENTTYPE_DOUBLECARD, EVENTID_SYNC_SEGMENT_PROTECT_BUFF_DATA, self.DelayRefreshIconAndTips, self)
  self:AddCommonEvent(EVENTTYPE_DOUBLECARD, EVENTID_SYNC_ADD_SCORE_BUFF_DATA, self.DelayRefreshIconAndTips, self)
  self:AddCommonEvent(EVENTTYPE_CRAZYWEEKEND, EVENTID_CRAZYWEEKEND_ACT_UPDATE, self.DelayRefreshIconAndTips, self)
  self:AddCommonEvent(EVENTTYPE_TASK, EVENTID_TASK_NEWBIE_LOBBY_ENTRANCE_UPDATE, self.DelayRefreshIconAndTips, self)
  self:AddCommonEvent(EVENTTYPE_MENTOR, EVENTID_MENTOR_STATUS_NOTIFY, self.OnMentorStatusNotify, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_INTL_SELECT_ZONE_RSP, self.DelayRefreshIconAndTips, self)
  self:AddCommonEvent(EVENTTYPE_PROMOTION, EVENTID_PROMOTION_SELECT_PROMOTION_RSP, self.DelayRefreshIconAndTips, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_DoubleCardShowTips, self.OnClickShowBuffPanel, self)
  self:AddCommonEvent(EVENTTYPE_DOUBLECARD, EVENTID_DOUBLECARD_PANEL_CLOSED, self.OnRefreshButtonState, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_SYNC_DOUBLECARD_STATE, self.RefreshCardTipsUI, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_ON_FACESLAP_END, self.OnFaceSlapEnd, self)
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_MATCH_VIEW_SELECT_CHANGE, self.OnMatchViewSelectChange, self)
end
function Lobby_Segment_Protect_UIBP:OnPostInitialize()
  Lobby_Segment_Protect_UIBP.__super.OnPostInitialize(self)
  log(bWriteLog and "Lobby_Segment_Protect_UIBP:OnPostInitialize")
  self:ShowRoot(false)
  self:SetIsScoreProtect()
  self:UpdateUI()
  self.UIRoot.HorizontalBox_7:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  local DoubleCardHandler = require("client.network.Protocol.DoubleCardHandler")
  DoubleCardHandler.send_get_rating_protect_list_req()
  DoubleCardHandler.send_get_add_rating_list_req()
  self:RefreshCardTipsUI()
  self:SetImageUpOrDown(true)
end
function Lobby_Segment_Protect_UIBP:OnClose()
  log(bWriteLog and "Lobby_Segment_Protect_UIBP:OnClose")
  self:ReleaseFirstWinTimer()
end
function Lobby_Segment_Protect_UIBP:ShowRoot(bShow)
  log(bWriteLog and "Lobby_Segment_Protect_UIBP:ShowRoot bShow = " .. tostring(bShow))
  if bShow then
    self.UIRoot.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self:NotifyParentDoubleCardVisible()
  end
end
function Lobby_Segment_Protect_UIBP:HasAnyVisibleContent()
  if self.hasDataShow and self.bClassicMode then
    return true
  end
  if self.hasActDataShow then
    return true
  end
  if self.tipsCount and self.tipsCount > 0 then
    return true
  end
  local logic_promotion_mode = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_promotion_mode)
  if logic_promotion_mode:IsCanSelect() and logic_promotion_mode:IsOpenPromotion() then
    return true
  end
  if self.bCreatedInMainCity then
    local logic_return_activity_first_battle = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_activity_first_battle)
    if logic_return_activity_first_battle:IsShowMatchGuide() then
      return true
    end
  end
  local MentorSystem = require("client.slua.logic.mentor.logic_mentor")
  if MentorSystem.identity == MentorSystem.EIdentity.Mentor and MentorSystem.waiting_status == MentorSystem.EWaitingStatus.Wait then
    return true
  end
  if self.bFirstWinVisible then
    return true
  end
  return false
end
function Lobby_Segment_Protect_UIBP:NotifyParentDoubleCardVisible()
  if not self.bCreatedInMainCity then
    return
  end
  local parentUI = self:GetParentUI()
  if parentUI and parentUI.RefreshDoubleCardVisible then
    parentUI:RefreshDoubleCardVisible()
  end
end
function Lobby_Segment_Protect_UIBP:OnClickShowProtectTips()
  self:PlayAudio(sound_config.click_v1)
  self:OnRefreshIconAndTips()
  if not self.hasDataShow then
    log(bWriteLog and "Lobby_Segment_Protect_UIBP:OnClickShowProtectTips has no data to show")
    ShowNotice(79644)
    return
  end
  if GameStatus.IsInMainCity() and not UIManager.IsUIShow(UIManager.UI_Config.mode_selection_main) then
    UIManager.ShowUI(UIManager.UI_Config.MainCity_Lobby_Mid_DoubleCard_Buff_Panel_160_UIBP, nil, nil, self.UIRoot.Canvas_ShieldInfpTips, {
      bClassicMode = self.bClassicMode
    })
  else
    UIManager.ShowUI(UIManager.UI_Config.segment_protect_tips, nil, nil, self.UIRoot.Canvas_ShieldInfpTips, {
      bClassicMode = self.bClassicMode
    })
  end
end
function Lobby_Segment_Protect_UIBP:OnClickVeteran()
  self:PlayAudio(sound_config.click_v1)
  local logic_mentor = require("client.slua.logic.mentor.logic_mentor")
  logic_mentor.OpenMentorWaitingTips(self.UIRoot.Button_Veteran)
end
function Lobby_Segment_Protect_UIBP:OnSwitchToPageEnd(_, _, fromPage, toPage)
  log(bWriteLog and "Lobby_Segment_Protect_UIBP:OnSwitchToPageEnd")
  if toPage == ENUM_LobbyPageType.Left then
    return
  end
  self.UIRoot.HorizontalBox_7:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self:UpdateUI()
end
function Lobby_Segment_Protect_UIBP:OnFaceSlapEnd()
  self:CheckGiftEntryShow()
end
function Lobby_Segment_Protect_UIBP:OnMatchViewSelectChange()
  self:CheckGiftEntryShow()
end
function Lobby_Segment_Protect_UIBP:OnActivityDataChanged(eventType, eventID, changeList)
  if not changeList or not changeList.typeList then
    log(bWriteLog and "Lobby_Segment_Protect_UIBP:RefreshScorePortected changeList is nil")
    return
  end
  if changeList.typeList[ActivityType.HAPPY_TO_TEAM] then
    self:SetIsScoreProtect()
    self:UpdateUI()
  end
end
function Lobby_Segment_Protect_UIBP:OnGetScoreProtectModeCfg()
  self:SetIsScoreProtect()
  self:UpdateUI()
end
function Lobby_Segment_Protect_UIBP:OnHallDepotDataChange(_, __, changelist)
  if not changelist or type(changelist) ~= "table" then
    log(bWriteLog and "Lobby_Segment_Protect_UIBP:OnHallDepotDataChange changelist is invalid")
    return
  end
  local LogicAddScordCard = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicAddScordCard)
  local logic_team_add_score_card = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_team_add_score_card)
  for _, v in pairs(changelist) do
    if v.res_id and (LogicAddScordCard:IsDefaultUseSeasonAddScoreCard(v.res_id) or logic_team_add_score_card:IsDefaultUseTeamAddScoreCard(v.res_id)) then
      log(bWriteLog and "Lobby_Segment_Protect_UIBP:OnHallDepotDataChange update")
      self:UpdateUI()
      return
    end
  end
end
function Lobby_Segment_Protect_UIBP:OnSelectionModeChange()
  self:SetIsScoreProtect()
  self:DelayRefreshIconAndTips()
end
function Lobby_Segment_Protect_UIBP:DelayRefreshIconAndTips()
  if self.DelayRefreshIconAndTipsTimer then
    self:RemoveTimer(self.DelayRefreshIconAndTipsTimer)
    self.DelayRefreshIconAndTipsTimer = nil
  end
  self.DelayRefreshIconAndTipsTimer = self:AddTimerOnce(0, function()
    self:OnRefreshIconAndTips()
    if GameStatus.IsInMainCity() == self.bCreatedInMainCity then
      self:CheckGiftEntryShow(false, true)
    end
  end)
end
function Lobby_Segment_Protect_UIBP:OnRefreshIconAndTips()
  self:ShowRoot(true)
  local bShowPromotion = self:OnRefreshPromotion()
  if bShowPromotion then
    self:NotifyParentDoubleCardVisible()
    return
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local matchMode, _, __ = logic_mode_selection:GetCurSelectInfo()
  local isShowIcon = self:IsClassicRankMode(matchMode)
  self.isPeakGameShowIcon = self:IsClassicPeakGameMode(matchMode) or self.IsPeakGame
  if isShowIcon or self.isPeakGameShowIcon then
    self.bClassicMode = true
    self.UIRoot.GridPanel_1:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    EventSystem:postEvent(EVENTTYPE_SKILL_SELECTION, EVENTID_SKILL_DOUBLECARD_SHOW)
  else
    self.bClassicMode = false
    self.UIRoot.GridPanel_1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    EventSystem:postEvent(EVENTTYPE_SKILL_SELECTION, EVENTID_SKILL_DOUBLECARD_HIDE)
  end
  self:UpdateIconAndTips()
  if self.bShowScrollTips and not self.UIRoot:IsAnimationPlaying(self.UIRoot.Animation_Appear) then
    self.UIRoot.ScrollPanel:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self:PlayUserWidgetAnimation(self.UIRoot.Animation_Appear, 0, 0, 0, 1)
  end
  self:NotifyParentDoubleCardVisible()
end
function Lobby_Segment_Protect_UIBP:OnRefreshPromotion()
  local logic_promotion_mode = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_promotion_mode)
  if not logic_promotion_mode:IsCanSelect() or not logic_promotion_mode:IsOpenPromotion() then
    log(bWriteLog and "Lobby_Segment_Protect_UIBP:OnRefreshPromotion IsCanSelect or IsOpenPromotion is false")
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_ArrowTips, false)
    return false
  end
  if not self.UIRoot.Common_Qualifying_Rounds_ArrowButton_UIBP then
    return false
  end
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_ArrowTips, true)
  self:SetWidgetVisible(self.UIRoot.ActivityInfoCanvas, false)
  self:SetWidgetVisible(self.UIRoot.Canvas_ShieldInfpTips, false)
  self:SetWidgetVisible(self.UIRoot.GridPanel_1, true)
  local logic_promotion_homepage = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_promotion_homepage)
  local cur_protect_cnt, max_protect_cnt = logic_promotion_homepage:GetCurProtectCount()
  log(bWriteLog and "Lobby_Segment_Protect_UIBP:OnRefreshPromotion cur_protect_cnt = " .. tostring(cur_protect_cnt) .. " max_protect_cnt = " .. tostring(max_protect_cnt))
  if 0 < cur_protect_cnt then
    self.UIRoot.Common_Qualifying_Rounds_ArrowButton_UIBP.WidgetSwitcher_0:SetActiveWidgetIndex(1)
  else
    self.UIRoot.Common_Qualifying_Rounds_ArrowButton_UIBP.WidgetSwitcher_0:SetActiveWidgetIndex(0)
  end
  return true
end
function Lobby_Segment_Protect_UIBP:OnClickShowPromotionTips()
  log(bWriteLog and "Lobby_Segment_Protect_UIBP:OnClickShowPromotionTips")
  self:PlayAudio(sound_config.click_v1)
  if GameStatus.IsInMainCity() and not UIManager.IsUIShow(UIManager.UI_Config.mode_selection_main) then
    UIManager.ShowUI(UIManager.UI_Config.Common_Qualifying_Rounds_Tips_MC, nil, nil, self.UIRoot.Button_Qualifying)
  else
    UIManager.ShowUI(UIManager.UI_Config.Common_Qualifying_Rounds_Tips, nil, nil, self.UIRoot.Button_Qualifying)
  end
end
function Lobby_Segment_Protect_UIBP:OnClickShowPromotionChallenge()
  self:PlayAudio(sound_config.click_v1)
  log(bWriteLog and "Lobby_Segment_Protect_UIBP:OnClickShowPromotionChallenge")
  UIManager.ShowUI(UIManager.UI_Config.Lobby_Season_PromotionProtection_Popup_UIBP)
end
function Lobby_Segment_Protect_UIBP:CheckGiftEntryShow(isManualClick, onlySetVisible)
  log(bWriteLog and "Lobby_Segment_Protect_UIBP:CheckGiftEntryShow isManualClick=" .. tostring(isManualClick) .. " onlySetVisible=" .. tostring(onlySetVisible))
  if GameStatus.IsInMainCity() ~= self.bCreatedInMainCity then
    log(bWriteLog and "Lobby_Segment_Protect_UIBP:CheckGiftEntryShow return SceneMismatch IsInMainCity=" .. tostring(GameStatus.IsInMainCity()) .. " bCreatedInMainCity=" .. tostring(self.bCreatedInMainCity))
    return
  end
  local logic_return_activity_first_battle = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_activity_first_battle)
  local bShowGuide = logic_return_activity_first_battle:IsShowMatchGuide()
  self:SetWidgetVisible(self.UIRoot.Button_Gift, bShowGuide, true)
  if onlySetVisible then
    log(bWriteLog and "Lobby_Segment_Protect_UIBP:CheckGiftEntryShow return onlySetVisible bShowGuide=" .. tostring(bShowGuide))
    return
  end
  if not bShowGuide then
    log(bWriteLog and "Lobby_Segment_Protect_UIBP:CheckGiftEntryShow return bShowGuide=false")
    UIManager.CloseUI(UIManager.UI_Config.ReturnActivity_Tips_UIBP)
    return
  end
  local NewFaceSlapSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NewFaceSlapSystem)
  if not NewFaceSlapSystem:IsSlapEnd() then
    log(bWriteLog and "Lobby_Segment_Protect_UIBP:CheckGiftEntryShow return IsInSlap")
    return
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  if logic_mode_selection:IsPeakGameView() then
    log(bWriteLog and "Lobby_Segment_Protect_UIBP:CheckGiftEntryShow return IsPeakGameView")
    return
  end
  if UIManager.GetUI(UIManager.UI_Config.ReturnActivity_Tips_UIBP) then
    log(bWriteLog and "Lobby_Segment_Protect_UIBP:CheckGiftEntryShow close existing Tips")
    UIManager.CloseUI(UIManager.UI_Config.ReturnActivity_Tips_UIBP)
  end
  if not self.UIRoot or not self.UIRoot.Button_Gift then
    log(bWriteLog and "Lobby_Segment_Protect_UIBP:CheckGiftEntryShow return UIRoot or Button_Gift is nil")
    return
  end
  if isManualClick then
    log(bWriteLog and "Lobby_Segment_Protect_UIBP:CheckGiftEntryShow CreateChildWindow isManualClick=true")
    UIManager.ShowUI(UIManager.UI_Config.ReturnActivity_Tips_UIBP, {
      anchorWidget = self.UIRoot.Button_Gift,
      isManualClick = true,
      anchorOffsetX = 10
    })
  else
    self:AddTimerOnce(0.1, function()
      if not self.UIRoot or not self.UIRoot.Button_Gift then
        log(bWriteLog and "Lobby_Segment_Protect_UIBP:CheckGiftEntryShow delayed return UIRoot or Button_Gift is nil")
        return
      end
      local parentUI = self:GetParentUI()
      self:SetWidgetVisible(parentUI.UIRoot.Canvas_FirstBattle_Newbie, true)
      self:CreateChildWindow(parentUI.UIRoot.Canvas_FirstBattle_Newbie, UIManager.UI_Config.ReturnActivity_Tips_UIBP, {
        anchorWidget = self.UIRoot.Button_Gift,
        isManualClick = false,
        anchorOffsetX = 5
      })
    end)
  end
end
function Lobby_Segment_Protect_UIBP:OnClickButton_Gift()
  self:PlayAudio(sound_config.click_v1)
  self:CheckGiftEntryShow(true)
end
function Lobby_Segment_Protect_UIBP:OnRefreshUIVisible(_, __, IsVisible)
  self:ShowRoot(not IsVisible)
end
function Lobby_Segment_Protect_UIBP:IsClassicRankMode(matchMode)
  return matchMode == 101 or matchMode == 102 or matchMode == 103 or matchMode == 401 or matchMode == 402 or matchMode == 403
end
function Lobby_Segment_Protect_UIBP:IsClassicPeakGameMode(matchMode)
  return matchMode == 11201
end
function Lobby_Segment_Protect_UIBP:OnMentorStatusNotify()
  self:ShowVeteranEntry()
end
function Lobby_Segment_Protect_UIBP:UpdateUI()
  self:DelayRefreshIconAndTips()
  self:ShowVeteranEntry()
end
function Lobby_Segment_Protect_UIBP:UpdateIconAndTips()
  log(bWriteLog and "Lobby_Segment_Protect_UIBP:UpdateIconAndTips")
  local bRefreshShield = self:ShowShieldIcon()
  bRefreshShield = self:ShowActShieldIcon(bRefreshShield)
  self:RefreshTipsPanel(bRefreshShield)
  self.bShowScrollTips = bRefreshShield and self.bClassicMode
  if not self.bShowScrollTips then
    self.UIRoot:StopAnimation(self.UIRoot.Animation_Appear)
    self.UIRoot.ScrollPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function Lobby_Segment_Protect_UIBP:SetIsScoreProtect()
  local LogicRatingProtectActivity = require("client.slua.logic.activity.rating_protect_activity.logic_rating_protect_activity")
  self.isScoreProtected = LogicRatingProtectActivity.IsShowRatingProtected()
end
function Lobby_Segment_Protect_UIBP:ShowActShieldIcon(hasOtherBuffer)
  log(bWriteLog and "Lobby_Segment_Protect_UIBP:ShowActShieldIcon", hasOtherBuffer)
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  self.isPeakGameShowIcon = logic_mode_selection:IsPeakGameView() or self.IsPeakGame
  self:SetWidgetVisible(self.Canvas_ShieldInfpTips, hasOtherBuffer, false)
  log(bWriteLog and "Lobby_Segment_Protect_UIBP:ShowActShieldIcon isPeakGameShowIcon: " .. tostring(self.isPeakGameShowIcon))
  if not self.isPeakGameShowIcon then
    local ItemDataList = logic_buffer_panel_for_act.GetActListForSegmentBuffer()
    if ItemDataList and next(ItemDataList) then
      local actCount = 0
      local actName, actCfg, segmentID
      for _, dataCfg in pairs(ItemDataList) do
        actCount = actCount + 1
        actName = dataCfg.actName
        if not actCfg and ActCfgList[actName] then
          actCfg = ActCfgList[actName]
        end
        local DataItem = dataCfg.data[1]
        segmentID = segmentID or DataItem.protect_id
      end
      log_format("Lobby_Segment_Protect_UIBP:ShowShieldIcon hasAct actName: %s ,actCfg = %s, segmentID = %s ", actName, actCfg, segmentID)
      self.Canvas_ShieldInfpTips:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      self:SetWidgetVisible(self.UIRoot.GridPanel_1, true, false)
      self.hasDataShow = true
      self.hasActDataShow = true
      if actCfg then
        self:SetTexture(self.UIRoot.Image_ScrollBg, actCfg.ScrollBgPath)
        self:SetTexture(self.UIRoot.Image_23, actCfg.IconPath)
      else
        local segmentProtectState = CDataTable.GetTable("SegmentProtected")
        self:SetTexture(self.UIRoot.Image_ScrollBg, DefaultScrollBgPath)
        if segmentID then
          self:SetTexture(self.UIRoot.Image_23, segmentProtectState[segmentID].IconPath)
        end
      end
      if hasOtherBuffer or 1 < actCount then
        self.UIRoot.ScrollText:SetText(LocUtil.GetLocalizeResStr(44255))
      else
        log(bWriteLog and "Lobby_Segment_Protect_UIBP:ShowShieldIcon hasAct " .. tostring(actName))
        local title = logic_buffer_panel_for_act.GetBufferPanelTitle(actName)
        if title then
          self.UIRoot.ScrollText:SetText(title)
        else
          self.UIRoot.ScrollText:SetText(LocUtil.GetLocalizeResStr(44255))
        end
      end
      return true, true
    end
  end
end
function Lobby_Segment_Protect_UIBP:ShowShieldIcon()
  log(bWriteLog and "Lobby_Segment_Protect_UIBP:ShowShieldIcon")
  local segmentProtectState = CDataTable.GetTable("SegmentProtected")
  self.Canvas_ShieldInfpTips:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.hasDataShow = false
  self:SetTexture(self.UIRoot.Image_ScrollBg, DefaultScrollBgPath)
  local logic_rating_card_buff_mgr = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_rating_card_buff_mgr)
  local addScoreList = logic_rating_card_buff_mgr:GetAddScoreList(self.isPeakGameShowIcon)
  if addScoreList then
    for _, addScore in ipairs(addScoreList) do
      if addScore.protect_id and segmentProtectState[addScore.protect_id] then
        self.Canvas_ShieldInfpTips:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        self:SetTexture(self.UIRoot.Image_23, segmentProtectState[addScore.protect_id].IconPath)
        if self.isPeakGameShowIcon then
          local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
          local str
          if addScore.res_id and (addScore.res_id == PeakGameConfig.ProtectCard.PeakGame20AddCard or addScore.res_id == PeakGameConfig.ProtectCard.PeakGame20AddCardLast) then
            str = LocUtil.GetLocalizeResStr(PeakGameConfig.MainAddScoreTips.AddScore20)
          elseif addScore.res_id and (addScore.res_id == PeakGameConfig.ProtectCard.PeakGame10AddCard or addScore.res_id == PeakGameConfig.ProtectCard.PeakGame20AddCardLast) then
            str = LocUtil.GetLocalizeResStr(PeakGameConfig.MainAddScoreTips.AddScore10)
          elseif addScore.cfg and addScore.cfg.id == PeakGameConfig.Activity.MiLExtraPoints then
            str = addScore.cfg.activity_name
          elseif addScore.cfg and addScore.cfg.id == PeakGameConfig.Activity.AllExtraPoints then
            str = addScore.cfg.activity_name
          elseif addScore.protect_id == 32 then
            local logic_rating_protect_peak = require("client.slua.logic.activity.rating_protect_activity.logic_rating_protect_peak")
            str = logic_rating_protect_peak.GetPeakMapNameByGroupID(addScore.groupModID)
          end
          self.UIRoot.ScrollText:SetText(LocUtil.GeneralFormat(segmentProtectState[addScore.protect_id].ScrollText, str))
        else
          self.UIRoot.ScrollText:SetText(segmentProtectState[addScore.protect_id].ScrollText)
        end
        self.hasDataShow = true
        return true, true
      end
    end
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local matchMode, _, __ = logic_mode_selection:GetCurSelectInfo()
  self.isPeakGameShowIcon = self:IsClassicPeakGameMode(matchMode) or self.IsPeakGame
  local segProtectList = logic_rating_card_buff_mgr:GetSegmentProtectList(self.isPeakGameShowIcon)
  if segProtectList then
    for _, segProtect in ipairs(segProtectList) do
      if segProtect.protect_id and segmentProtectState[segProtect.protect_id] then
        self.Canvas_ShieldInfpTips:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        self:SetTexture(self.UIRoot.Image_23, segmentProtectState[segProtect.protect_id].IconPath)
        self.UIRoot.ScrollText:SetText(segmentProtectState[segProtect.protect_id].ScrollText)
        self.hasDataShow = true
        return true, true
      end
    end
  end
  local SeasonSystem = require("client.logic.season.logic_season")
  local isValid, tag = SeasonSystem.IsScoreValid()
  if isValid and not self.isPeakGameShowIcon then
    if tag then
      self:SetTexture(self.UIRoot.Image_23, segmentProtectState[E_IconType.ChallengeScoreAddtion].IconPath)
      self.UIRoot.ScrollText:SetText(segmentProtectState[E_IconType.ChallengeScoreAddtion].ScrollText)
    else
      self:SetTexture(self.UIRoot.Image_23, segmentProtectState[E_IconType.ChallengeScore].IconPath)
      self.UIRoot.ScrollText:SetText(segmentProtectState[E_IconType.ChallengeScore].ScrollText)
    end
    self.Canvas_ShieldInfpTips:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.hasDataShow = true
    return true, true
  end
  return false, false
end
function Lobby_Segment_Protect_UIBP:RefreshTipsPanel(bRefresh)
  local uiSegmentProtectTips = UIManager.GetUI(UIManager.UI_Config.segment_protect_tips)
  if uiSegmentProtectTips and uiSegmentProtectTips:IsShow() then
    if bRefresh then
      return
    end
    UIManager.CloseUI(UIManager.UI_Config.segment_protect_tips)
  end
end
function Lobby_Segment_Protect_UIBP:OnClickCloseRewardTips()
  self:PlayAudio(sound_config.click)
  self.UIRoot.CanvasPanel_19:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.Button_Close:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function Lobby_Segment_Protect_UIBP:OnRefreshDailyWinIcon(_, _, type)
  if type == 1 then
    self:ShowFirstGameGift(true)
    self:BindFirstWinBtnFunc()
    self:NotifyParentDoubleCardVisible()
  elseif type == 2 then
    self:ShowFirstGameGift(false)
    self:BindFirstWinBtnFunc()
    self:NotifyParentDoubleCardVisible()
  elseif type == 3 then
    self:PlayFirstWinAnim()
    self:BindGetFirstWinGiftFunc()
    self:NotifyParentDoubleCardVisible()
  elseif type == 4 then
    self:HideFirstGameGift()
  end
end
function Lobby_Segment_Protect_UIBP:ShowFirstGameGift(bTip)
  self.bFirstWinVisible = true
  self.UIRoot.CanvasPanel_FirstWin:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(0)
  if bTip then
    self.UIRoot.CanvasPanel_19:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.Button_Close:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    self:ShowHideFirstWinAnimation()
  end
  self:InitFirstWinRewardInfo()
end
function Lobby_Segment_Protect_UIBP:ShowHideFirstWinAnimation()
  self:ReleaseFirstWinTimer()
  local time_ticker = require("common.time_ticker")
  self.firstWinTimer = time_ticker.AddTimer(2, function()
    self.UIRoot.CanvasPanel_19:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.Button_Close:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end)
end
function Lobby_Segment_Protect_UIBP:ReleaseFirstWinTimer()
  if self.firstWinTimer then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(self.firstWinTimer)
  end
end
function Lobby_Segment_Protect_UIBP:InitFirstWinRewardInfo()
  if DataMgr.roleData and DataMgr.roleData.back_user_data and DataMgr.roleData.back_user_data.daily_battle_data and DataMgr.roleData.back_user_data.daily_battle_data.reward_cfg then
    local item = DataMgr.roleData.back_user_data.daily_battle_data.reward_cfg[1]
    if item then
      self.UIRoot.FirstWinReward:InitView(item.res_id, item.res_num, 1, item.valid_hours, true, false)
    end
  end
  self.UIRoot.TextBlock_5:SetText(LocUtil.GetLocalizeResStr(16182))
end
function Lobby_Segment_Protect_UIBP:BindFirstWinBtnFunc()
  self:AddOnClickedEventByControl(self.UIRoot.Button_FirstWin, function()
    self:ReleaseFirstWinTimer()
    self:ChangeFirstWinVisible()
  end)
end
function Lobby_Segment_Protect_UIBP:ChangeFirstWinVisible()
  if self.UIRoot.CanvasPanel_19:GetVisibility() == UEnums.ESlateVisibility.SelfHitTestInvisible then
    self.UIRoot.CanvasPanel_19:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.Button_Close:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    self.UIRoot.CanvasPanel_19:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.Button_Close:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  end
end
function Lobby_Segment_Protect_UIBP:PlayFirstWinAnim()
  self.bFirstWinVisible = true
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_FWParent, true)
  self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(1)
  self.UIRoot.CanvasPanel_FirstWin:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self.UIRoot.CanvasPanel_19:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self:PlayUserWidgetAnimation(self.UIRoot.NewAnimation_1, 0, 0, 0, 1)
end
function Lobby_Segment_Protect_UIBP:BindGetFirstWinGiftFunc()
  self:AddOnClickedEventByControl(self.UIRoot.Button_FirstWin, function()
    local playerReturn = require("client.slua.logic.player_return.logic_player_return")
    playerReturn.send_backuser_get_daily_reward_req()
  end)
end
function Lobby_Segment_Protect_UIBP:HideFirstGameGift()
  self.bFirstWinVisible = false
  self.UIRoot.CanvasPanel_FirstWin:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.CanvasPanel_19:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_FWParent, false)
  self:NotifyParentDoubleCardVisible()
end
function Lobby_Segment_Protect_UIBP:ShowVeteranEntry()
  local MentorSystem = require("client.slua.logic.mentor.logic_mentor")
  if MentorSystem.identity == MentorSystem.EIdentity.Mentor and MentorSystem.waiting_status == MentorSystem.EWaitingStatus.Wait then
    self:SetWidgetVisible(self.UIRoot.Button_Veteran, true, true)
  else
    self:SetWidgetVisible(self.UIRoot.Button_Veteran, false, true)
  end
  self:NotifyParentDoubleCardVisible()
end
function Lobby_Segment_Protect_UIBP:RefreshCardTipsUI()
  self:InitCardData()
  if self:IsNeedTimerRefresh() then
    self:SetTimerRefresh()
  else
    self:UpdateDoubleCardBtn()
  end
end
function Lobby_Segment_Protect_UIBP:InitCardData()
  local DoubleCardSystem = require("client.logic.double_card.logic_double_card")
  local logic_wardrobe_card = require("client.slua.logic.wardrobe.logic_wardrobe_card")
  local num = 0
  self.bHasGoldCard = DoubleCardSystem.HasGoldRate()
  if self.bHasGoldCard then
    num = num + 1
  end
  self.bHasExpCard = DoubleCardSystem.HasExpRate()
  if self.bHasExpCard then
    num = num + 1
  end
  self.bHasVSTeamWeaponExpCard = logic_wardrobe_card:HasVSTeamWeaponExpCard()
  if self.bHasVSTeamWeaponExpCard then
    num = num + 1
  end
  self.tipsCount = num
end
function Lobby_Segment_Protect_UIBP:IsNeedTimerRefresh()
  return self.bHasGoldCard or self.bHasExpCard or self.bHasVSTeamWeaponExpCard
end
function Lobby_Segment_Protect_UIBP:SetTimerRefresh()
  self:StopTimer()
  self.Timer = self:AddTimerLoop(1, function()
    self:InitCardData()
    self:UpdateDoubleCardBtn()
    if not self:IsNeedTimerRefresh() then
      self:StopTimer()
    end
  end, TIMER_INFINITE, 60)
end
function Lobby_Segment_Protect_UIBP:UpdateDoubleCardBtn()
  local b_refresh = false
  if self.tipsCount > 0 then
    self.UIRoot.Button_DoubleCardShowTips:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    if self.tipsCount > 1 then
      self.UIRoot.WidgetSwitcher_DoubleCardShowTips:SetActiveWidgetIndex(1)
      self.UIRoot.TextBlock_CardNum:SetText(tostring(self.tipsCount))
    else
      self.UIRoot.WidgetSwitcher_DoubleCardShowTips:SetActiveWidgetIndex(0)
    end
    b_refresh = true
    if self.UIRoot.CanvasPanel_DoubleCard then
      self:SetWidgetVisible(self.UIRoot.CanvasPanel_DoubleCard, true)
    end
  else
    self.UIRoot.Button_DoubleCardShowTips:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    if self.UIRoot.CanvasPanel_DoubleCard then
      self:SetWidgetVisible(self.UIRoot.CanvasPanel_DoubleCard, false)
    end
  end
  self:RefreshBuffPanel(b_refresh)
  self:NotifyParentDoubleCardVisible()
end
function Lobby_Segment_Protect_UIBP:StopTimer()
  if self.Timer then
    self:RemoveTimer(self.Timer)
  end
end
function Lobby_Segment_Protect_UIBP:RefreshBuffPanel(b_refresh)
  local ui_doublecard_tips = UIManager.GetUI(UIManager.UI_Config.lobby_doublecard_buff_panel)
  if ui_doublecard_tips and ui_doublecard_tips:IsShow() then
    if b_refresh then
      ui_doublecard_tips:UpdateTipData()
      return
    end
    UIManager.CloseUI(UIManager.UI_Config.lobby_doublecard_buff_panel)
  end
end
function Lobby_Segment_Protect_UIBP:SetImageUpOrDown(b_up)
end
function Lobby_Segment_Protect_UIBP:OnRefreshButtonState()
  log(bWriteLog and "Lobby_Segment_Protect_UIBP:OnRefreshButtonState")
  if self.tipsCount == 1 then
    self:SetImageUpOrDown(true)
  end
end
function Lobby_Segment_Protect_UIBP:OnClickShowBuffPanel()
  log(bWriteLog and "Lobby_Segment_Protect_UIBP:OnClickShowBuffPanel")
  self:PlayAudio(sound_config.click_v1)
  if self.tipsCount == 1 then
    self:SetImageUpOrDown(false)
  end
  if self.UIRoot.CanvasPanel_DoubleCard then
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_DoubleCard, true)
  end
  local DoubleCardSystem = require("client.logic.double_card.logic_double_card")
  if GameStatus.IsInMainCity() then
    self:CreateChildWindow(self.UIRoot.CanvasPanel_DoubleCard, UIManager.UI_Config.MainCity_Mid_DoubleCard_Buff_Panel_UIBP, DoubleCardSystem.Enum_Show_Panel_Tip.GoldAndEXP)
  else
    self:CreateChildWindow(self.UIRoot.CanvasPanel_DoubleCard, UIManager.UI_Config.lobby_doublecard_buff_panel, DoubleCardSystem.Enum_Show_Panel_Tip.GoldAndEXP)
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, Lobby_Segment_Protect_UIBP)