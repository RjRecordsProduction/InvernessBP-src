local lobby_main_right_bottom_tab = {}
local gem_report_utils = require("client.logic.store.gem_report_utils")
local CheckInBottem = function(moduleId)
  local logic_lobby_system_extension = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lobby_system_extension)
  return logic_lobby_system_extension:CheckInSystemInfoByModuleID(moduleId)
end
function lobby_main_right_bottom_tab:ctor()
  self.bIsTabHidden = true
  self.mailAnimTimer = nil
  self.eGameRedTimer = nil
  self.bMailRedCanShow = false
  self.safeStationTimer = nil
  self.previousReddotAnchorShow = nil
end
function lobby_main_right_bottom_tab:OnInitialize()
  lobby_main_right_bottom_tab.__super.OnInitialize(self)
  self.WidgetSwitcher_Fold = self.UIRoot.WidgetSwitcher_Fold
  self.Image_Fold_Redpoint = self.UIRoot.Image_Fold_Redpoint
  self.Image_Club = self.UIRoot.Image_Club
  self.bIsMailUIOnTab = false
  local logic_lobby_system_extension = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lobby_system_extension)
  local lobby_system_entrance_marco = require("client.slua.logic.lobby.lobby_system_entrance_marco")
  local serverData = logic_lobby_system_extension:GetServerData()
  for k, v in pairs(serverData) do
    if v == lobby_system_entrance_marco.SystemIDDefine.MAIL then
      self.bIsMailUIOnTab = true
      break
    end
  end
  local tabLogic = require("client.slua.logic.lobby.Main.logic_lobby_main_right_bottom_tab")
  tabLogic:Init()
  self:SetLobbySystemInRightBottom()
  self:UpdateUI()
  self:NotifyCommunity()
  self:SetWidgetVisible(self.UIRoot.Image_Guide_New, false)
end
function lobby_main_right_bottom_tab:OnShow()
  self:CheckForHideFeature()
  self:ShowKolLobbyTip()
end
function lobby_main_right_bottom_tab:OnNotifySafeStation()
  local BanReddotSystem = require("client.slua.logic.ban_reddot.ban_reddot_system")
  if not BanReddotSystem.CanNotifySafeStationTips() then
    return
  end
  if self.safeStationTimer then
    self:RemoveTimer(self.safeStationTimer)
    self.safeStationTimer = nil
  end
  self.safeStationTimer = self:AddTimerOnce(10, function()
    BanReddotSystem.OpenSafeStationTips()
    self:RemoveTimer(self.safeStationTimer)
    self.safeStationTimer = nil
  end)
end
function lobby_main_right_bottom_tab:NotifyCommunity()
  local logic_community = require("client.slua.logic.community.logic_community")
  logic_community.OnLobbyMainShow()
  if logic_community.IsNeedReqVersionUpdateInfo() then
    logic_community.RequestVersionUpdate()
  end
end
function lobby_main_right_bottom_tab:BindWorkShopReddot()
  self:SetWidgetVisible(self.UIRoot.Reddot_Anchor_Workshop, false)
  local generalLabReddotData = require("client.slua.logic.lobby.lab.general_lab_reddot_data")
  local reddotData = generalLabReddotData.GetGropData()
  if reddotData then
    self.UIRoot.Reddot_Anchor_Workshop:UnBind()
    self:RegistReddotWidget(self.UIRoot.Reddot_Anchor_Workshop)
    self.UIRoot.Reddot_Anchor_Workshop:Bind(reddotData)
  end
end
function lobby_main_right_bottom_tab:RegistEvents()
  lobby_main_right_bottom_tab.__super.RegistEvents(self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_FoldUI_BottomRight, self.OnButton_FoldUI_BottomRightClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_FoldUI_Mail, self.OnButton_FoldUI_MailClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Season, self.OnButton_SeasonClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Workshop, self.OnButton_ArmoryClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Missions, self.OnButton_TaskNewClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_DepotSystemNew, self.OnButton_DepotSystemNewClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Lobby_Main_Bubble_Workshop.Button_LabVideo, self.OnButton_WorkshopBubbleClick, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_LOBBY_ON_CLICK_SET_SYSTEM_ENTRANCE, self.OnClickSetSystemEntrance, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_LOBBY_UPDATE_SYSTEM_ENTRANCE, self.UpdateSystemEntrance, self)
  self:AddCommonEvent(EVENTID_LOBBY_MAIN_REDDOT, EVENTID_LOBBY_MAIN_REDDOT_UPDATE, self.RedPointUpdate, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_SWITCHTO_PAGE_END, self.OnSwitchPageHideTab, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_ON_GIFTCENTER_NEW_MSG, self.UpdateNewMailUI, self)
  self:AddCommonEvent(EVENTTYPE_MAIL, EVENTID_MAIL_UPDATE_LIST, self.UpdateNewMailUI, self)
  self:AddCommonEvent(EVENTTYPE_MAIL, EVENTID_MAIL_ON_RECV_NEW_MAIL, self.OnReceiveNewMail, self)
  self:AddCommonEvent(EVENTTYPE_MAIL, EVENTID_MAIL_ON_CLOSE_MAIL_UI, self.OnViewAllNewMail, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_SHOW_LOBBY, self.OnShowLobby, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_HIDE_LOBBY, self.OnHideLobby, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_SHOW_BOTTOM_RIGHT_MENU, self.OnShowBottomRightMenu, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_HIDE_BOTTOM_RIGHT_MENU, self.OnHideBottomRightMenu, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_LOBBY_FADE_IN_ANIM_FINISH, self.OnLoadingFinish, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_WORKSHOP_UPDATE_LAB_REDPOINT, self.UpdateLobbyLabEntranceRedPoint, self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_SEASON_CHANGE, self.OnUpdateSeason, self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ROLE_RANK_CHANGE, self.OnRefreshSegment, self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_UPDATE_HIGH_SEGMENT, self.OnRefreshSegment, self)
  self:AddCommonEvent(EVENTTYPE_ROLEINFO, EVENTID_SEASON_UPDATE, self.OnRefreshSegment, self)
  self:AddCommonEvent(EVENTTYPE_ACTION, EVENTID_NEWBIE_GUIDE_WEAK_GUIDE_SHOW, self.UpdateWeakGuide, self)
  self:AddCommonEvent(EVENTTYPE_ACTION, EVENTID_NEWBIE_GUIDE_WEAK_GUIDE_HIDE, self.UpdateWeakGuide, self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_INIT, self.InitWardrobeData, self)
  self:InitWardrobeData()
  self:AddCommonEvent(EVENTTYPE_COMMUNITY, EVENTID_COMMUNITY_NOTIFY_REDDOT_INFO, self.UpdateArrowReddot, self)
  self:AddCommonEvent(EVENTTYPE_LEVEL_UNLOCK, EVENTID_LEVEL_UNLOCK_GET_DATA, self.OnGetLevelUnlockData, self)
  self:AddCommonEvent(EVENTTYPE_LOGIN, EVENTID_QR_LOGIN_QRCODE_RESTRICT_CHANGE, self.UpdateRestrict, self)
  self:AddCommonEvent(EVENTTYPE_REDDOT, EVENTID_REDDOT_INIT_SYSTEM_SUPERDATA, self.UpdateModuleRedChange, self)
  self:RegisterNodeRedDot()
  self:AddOnClickedEventByControl(self.UIRoot.Button_Theme, self.OnButton_ThemeClick, self)
  self:AddCommonEvent(EVENTTYPE_THEME_SYSTEM, EVENTID_THEME_SYSTEM_REFRESH_NEW_MARK, self.OnThemeSystemRefreshNewMark, self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_ROLE_LEVEL_CHANGE, self.CheckLevelUnlockThemeEntry, self)
  self:AddCommonEvent(EVENTTYPE_LEVEL_UNLOCK, EVENTID_LEVEL_UNLOCK_START_UNLOCK_GUIDE, self.OnLevelUnLockGuideStart, self)
end
function lobby_main_right_bottom_tab:RegisterNodeRedDot()
  local MailRedPointData = require("client.slua.logic.mail.logic_mail_redpoint_data")
  if MailRedPointData.CheckHasBeenInitialized() then
    self:AddMailSuperDataListen()
  end
  local logic_lobby_reddot = require("client.slua.logic.lobby.logic_lobby_reddot")
  self:RegistReddotWidget(self.Image_Fold_Redpoint)
  self:RegistReddotWidget(self.UIRoot.Fold_Reddot_Anchor)
  self.UIRoot.Fold_Reddot_Anchor:Bind(logic_lobby_reddot.GetGroupData(), nil, function(oldValue, value)
    self.bReddotAnchorShow = value ~= 0
    if self.previousReddotAnchorShow ~= self.bReddotAnchorShow then
      self:UpdateArrowReddot()
    end
    self.previousReddotAnchorShow = self.bReddotAnchorShow
  end)
  if self.UIRoot.Reddot_Anchor_Season then
    local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
    local reddot_manager = require("client.slua.logic.reddot.reddot_manager")
    self:RegistReddotWidget(self.UIRoot.Reddot_Anchor_Season)
    reddot_manager:BindSystemEntry(self, self.UIRoot.Reddot_Anchor_Season, reddot_macro.SystemName.Season)
  end
  self:BindWorkShopReddot()
  self:BindCardCollectionRedDot()
end
function lobby_main_right_bottom_tab:OnGetLevelUnlockData()
  self:CheckForHideFeature()
end
function lobby_main_right_bottom_tab:CheckForHideFeature()
  log(bWriteLog and "lobby_main_right_bottom_tab:CheckForHideFeature")
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  level_unlock_manager:CheckForHideFeature(self.UIRoot.SizeBox_Workshop, level_unlock_manager.featureDef.workshop, BP_ENUM_SWITCH_WORK_SHOP)
  level_unlock_manager:CheckForHideFeature(self.UIRoot.SizeBox_Season, level_unlock_manager.featureDef.season)
  level_unlock_manager:CheckForHideFeature(self.UIRoot.SizeBox_Missions, level_unlock_manager.featureDef.collectCard)
end
function lobby_main_right_bottom_tab:AddMailSuperDataListen()
  local MailRedDotSystem = require("client.slua.logic.mail.logic_mail_redpoint_data")
  local mailRedDotSuperData = MailRedDotSystem.GetData()
  if mailRedDotSuperData then
    self:AddDataListener(mailRedDotSuperData, MailRedDotSystem.redDotCountName, function(_, value)
      self.bMailRedCanShow = value ~= 0
      self:UpdateNewMailUI()
    end)
  end
end
function lobby_main_right_bottom_tab:UpdateModuleRedChange(_, _, module_id)
  if module_id and module_id == BP_ENUM_MODULE_MAIL then
    self:AddMailSuperDataListen()
  end
end
function lobby_main_right_bottom_tab:InitWardrobeData()
  local wardrobe_red_point = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.wardrobe_red_point)
  local redpoint = wardrobe_red_point:GetWardrobeRedData()
  if redpoint then
    self:RegistReddotWidget(self.UIRoot.Reddot_Anchor_Wardrobe)
    self.UIRoot.Reddot_Anchor_Wardrobe:Bind(redpoint, nil, function(oldValue, value)
      log(bWriteLog and string.format("lobby_main_right_bottom_tab:InitWardrobeData value = %s", value))
      self:SetWardrobeRedPoint(value ~= 0)
    end)
  end
end
function lobby_main_right_bottom_tab:OnClose()
  if self.UIRoot then
    self.UIRoot.Fold_Reddot_Anchor:UnBind()
  end
  self.previousReddotAnchorShow = nil
end
function lobby_main_right_bottom_tab:OnPostInitialize()
  lobby_main_right_bottom_tab.__super.OnPostInitialize(self)
  if self.eGameRedTimer then
    self:RemoveTimer(self.eGameRedTimer)
    self.eGameRedTimer = nil
  end
  local LogicMatchCenterEntry = require("client.slua.logic.lobby.Mid.logic_lobby_mid_match_center_entry")
  self.eGameRedTimer = self:AddTimerLoop(0.5, function()
    LogicMatchCenterEntry.RedPointLoopTimer()
  end, TIMER_INFINITE, 120)
end
function lobby_main_right_bottom_tab:SetTabShow(bShow)
  self.bIsTabHidden = not bShow
  if bShow then
    self:UpdateNewMailUI()
  else
  end
end
function lobby_main_right_bottom_tab:OnShowLobby()
  self:SetTabShow(true)
end
function lobby_main_right_bottom_tab:OnHideLobby()
  self:SetTabShow(false)
end
function lobby_main_right_bottom_tab:OnShowBottomRightMenu()
  self:SetTabShow(false)
end
function lobby_main_right_bottom_tab:OnHideBottomRightMenu()
  self:SetTabShow(true)
end
function lobby_main_right_bottom_tab:OnLoadingFinish()
  self:SetTabShow(true)
  self:OnNotifySafeStation()
end
function lobby_main_right_bottom_tab:ShowKolLobbyTip()
  local kol_data_in = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.kol_data_in)
  if kol_data_in:CheckCanShowLobbyKolTip() then
    self:CreateChildWindow(self.UIRoot.CanvasPanel_7, UIManager.UI_Config.kol_lobby_tip)
  end
end
function lobby_main_right_bottom_tab:OnViewAllNewMail()
  log(bWriteLog and "lobby_main_right_bottom_tab:OnViewAllNewMail")
  local tabLogic = require("client.slua.logic.lobby.Main.logic_lobby_main_right_bottom_tab")
  if tabLogic:ShouldNoticeNewMail() then
    tabLogic:RemoveMailIconNewStatus()
  end
  tabLogic:SaveMailIconNewStatus()
  self.WidgetSwitcher_Fold:SetActiveWidgetIndex(0)
end
function lobby_main_right_bottom_tab:OnReceiveNewMail()
  log(bWriteLog and "lobby_main_right_bottom_tab:OnReceiveNewMail")
  local tabLogic = require("client.slua.logic.lobby.Main.logic_lobby_main_right_bottom_tab")
  tabLogic:OnGetNewMail()
  self:UpdateNewMailUI()
end
function lobby_main_right_bottom_tab:OnSwitchPageHideTab(_, _, fromPage, toPage)
  if toPage == ENUM_LobbyPageType.Mid then
    if self.bIsTabHidden then
      self.bIsTabHidden = false
      self:UpdateNewMailUI()
    end
  else
    log(bWriteLog and "dean lobby_main_right_bottom_tab:OnSwitchPageHideTab - tab is hidden")
    self.bIsTabHidden = true
  end
end
function lobby_main_right_bottom_tab:UpdateNewMailUI()
  if LobbySystem.CheckOpen(BP_ENUM_LOBBY_MENU_MAIL) == false or not self.bMailRedCanShow then
    self.WidgetSwitcher_Fold:SetActiveWidgetIndex(0)
    log(bWriteLog and "lobby_main_right_bottom_tab:UpdateNewMailUI - mail not open")
    return
  end
  log(bWriteLog and "lobby_main_right_bottom_tab:UpdateNewMailUI")
  if self.bIsTabHidden then
    log(bWriteLog and "lobby_main_right_bottom_tab:UpdateNewMailUI - tab is hidden")
    return
  end
  local tabLogic = require("client.slua.logic.lobby.Main.logic_lobby_main_right_bottom_tab")
  local bShouldPlayAnim = tabLogic:ShouldNoticeNewMail()
  log(bWriteLog and "lobby_main_right_bottom_tab:UpdateNewMailUI - tab is shown, bShouldPlayAnim: " .. tostring(bShouldPlayAnim))
  tabLogic:RemoveMailIconNewStatus()
  tabLogic:SaveMailIconNewStatus()
  if bShouldPlayAnim and self.bIsMailUIOnTab ~= true then
    log(bWriteLog and "lobby_main_right_bottom_tab:UpdateNewMailUI - should play anim")
    self.WidgetSwitcher_Fold:SetActiveWidgetIndex(1)
    self:PlayNewMailAnim()
  elseif self.mailAnimTimer == nil then
    self.WidgetSwitcher_Fold:SetActiveWidgetIndex(0)
  end
end
function lobby_main_right_bottom_tab:GetRedPointType()
  local logic_lobby_reddot = require("client.slua.logic.lobby.logic_lobby_reddot")
  local logic_lobby_system_extension = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lobby_system_extension)
  local tempRedPoint = false
  local redpointType = 0
  if self:NeedShowFoldNew() then
    tempRedPoint = true
    redpointType = 2
  end
  if not tempRedPoint then
    local settingModuleId = BP_ENUM_MODULE_SETTING
    local moduleId = 0
    for SystemID, moduleId in pairs(logic_lobby_system_extension:GetMainSystemID2ModuleIDMap()) do
      if settingModuleId ~= moduleId and logic_lobby_system_extension:CheckInSystemInfo(SystemID) == false then
        tempRedPoint = logic_lobby_reddot.redDotMap[moduleId] or false
        if tempRedPoint then
          redpointType = 1
          break
        end
      end
    end
  end
  if not tempRedPoint then
    local moduleList = {
      BP_ENUM_MODULE_ALLIANCE_MAIN_PANEL,
      BP_ENUM_VLINK_SDK,
      BP_ENUM_MODULE_ESPORT,
      BP_ENUM_MODULE_BAN,
      BP_ENUM_LOBBY_MENU_INDIA_CHAMPIONSHIP_SYSTEM,
      BP_ENUM_MODULE_BOUNUS
    }
    for k, v in pairs(moduleList) do
      local tempRedPoint2 = lobby_main_right_bottom_tab:SetSystemAdditionalRedPoint(v)
      if lobby_main_right_bottom_tab:SetSystemAdditionalRedPoint(v) and logic_lobby_system_extension:CheckInSystemInfoByModuleID(v) then
        log(bWriteLog and "[v_ywuyuan] lobby_main_right_bottom_tab:GetRedPointType moduleList " .. ":" .. tostring(v) .. ":" .. tostring(k))
        tempRedPoint = tempRedPoint2
        redpointType = 1
        break
      end
    end
  end
  if not tempRedPoint then
    local SuperCoreRedDotData = require("client.slua.logic.supercore.supercore_reddot_data")
    local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
    tempRedPoint = ActivityNewSystem.CheckSuperVIP() and SuperCoreRedDotData.IsShowArrowRedDot() and not logic_lobby_system_extension:CheckInSystemInfoByModuleID(BP_ENUM_MODULE_SUPERCORE_ENTRY)
    if tempRedPoint then
      redpointType = 1
    end
  end
  if not tempRedPoint then
    local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
    local bHasReddot = LobbySystem.roleData.customer_service_reddot or false
    tempRedPoint = ActivityNewSystem.CheckPremiumHallSVIP() and bHasReddot
    if tempRedPoint then
      redpointType = 1
    end
  end
  if not tempRedPoint then
    local bInBottem = CheckInBottem(BP_ENUM_MODULE_SETTING)
    if bInBottem == false then
      tempRedPoint = logic_lobby_reddot.redDotMap[BP_ENUM_MODULE_SETTING] or false
      if tempRedPoint then
        log(bWriteLog and "[v_ywuyuan] lobby_main_right_bottom_tab:GetRedPointType setting  is red")
        redpointType = 2
      end
    end
  end
  if not tempRedPoint then
    local logic_community = require("client.slua.logic.community.logic_community")
    tempRedPoint = logic_community.GetShowEntryRedDot() and not logic_community.IsInLobbyEntrance()
    redpointType = 3
    log(bWriteLog and "tempRedPoint = " .. tostring(tempRedPoint))
  end
  if not tempRedPoint and LobbySystem.roleData.customer_service_reddot then
    tempRedPoint = true
    redpointType = 1
  end
  if not tempRedPoint then
    local reddotData = logic_lobby_reddot.GetReddotDataByModule(BP_ENUM_MODULE_ASSEMBLY)
    if reddotData and 0 < reddotData.newCount then
      tempRedPoint = true
      redpointType = 1
    end
  end
  log(bWriteLog and "[v_ywuyuan] lobby_main_right_bottom_tab:GetRedPointType" .. ":" .. tostring(tempRedPoint) .. ":" .. tostring(redpointType))
  return tempRedPoint, redpointType
end
function lobby_main_right_bottom_tab:UpdateArrowReddot()
  local bReddotAnchorShow = self.bReddotAnchorShow
  if self:NeedShowFoldNew() then
    bReddotAnchorShow = false
  end
  self:SetWidgetVisible(self.UIRoot.Fold_Reddot_Anchor, bReddotAnchorShow)
  self:ToggleReddotActivation(self.UIRoot.Fold_Reddot_Anchor, bReddotAnchorShow)
  if bReddotAnchorShow then
    self:ToggleReddotActivation(self.Image_Fold_Redpoint, false)
    self:SetWidgetVisible(self.Image_Club, false)
  else
    local hasRedPoint, redpointType = self:GetRedPointType()
    log(bWriteLog and "  : hasRedPoint=" .. tostring(hasRedPoint))
    log(bWriteLog and "  : redpointType" .. tostring(redpointType))
    if hasRedPoint then
      local SettingUtil = require("client.slua.logic.setting.setting_util")
      local redPath = SettingUtil.GetRedPointPath()
      if redpointType == 1 then
        self:ToggleReddotActivation(self.Image_Fold_Redpoint, true)
        self:SetWidgetVisible(self.Image_Club, false)
      elseif redpointType == 2 then
        self:ToggleReddotActivation(self.Image_Fold_Redpoint, true)
        self:SetWidgetVisible(self.Image_Club, false)
        redPath = SettingUtil.GetRedPointPath(true)
      elseif redpointType == 3 then
        self:ToggleReddotActivation(self.Image_Fold_Redpoint, false)
        self:SetWidgetVisible(self.Image_Club, true)
      end
      self:SetTexture(self.Image_Fold_Redpoint, redPath, {bMatchSize = true})
    else
      self:ToggleReddotActivation(self.Image_Fold_Redpoint, false)
      self:SetWidgetVisible(self.Image_Club, false)
    end
  end
end
function lobby_main_right_bottom_tab:SetSystemAdditionalRedPoint(moduleId)
  local logic_lobby_reddot = require("client.slua.logic.lobby.logic_lobby_reddot")
  local logic_lobby_system_extension = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lobby_system_extension)
  local hasSystem = logic_lobby_system_extension:HasSystem(moduleId)
  if not hasSystem then
    return
  end
  local redPoint = logic_lobby_reddot.redDotMap[moduleId] or false
  local state = false
  if moduleId == BP_ENUM_MODULE_SETTING and redPoint == false then
    local logic_setting = require("client.logic.setting.logic_setting")
    state = logic_setting.NeedShowSettingRed()
  elseif moduleId == BP_ENUM_MODULE_ALLIANCE_MAIN_PANEL then
    state = false
  elseif moduleId == BP_ENUM_VLINK_SDK then
    local logic_vlink_sdk = require("client.slua.logic.vlink_sdk.logic_vlink_sdk")
    state = logic_vlink_sdk.IsWikiRedpoint()
  elseif moduleId == BP_ENUM_MODULE_ESPORT then
    state = LobbySystem.bHaveBroadcastRedpoint
  elseif moduleId == BP_ENUM_LOBBY_MENU_INDIA_CHAMPIONSHIP_SYSTEM then
    local TournamentsManager = require("client.slua.logic.tournament.TournamentsManager")
    state = TournamentsManager.isNeedRedPoint
  elseif moduleId == BP_ENUM_MODULE_BOUNUS then
    local TournamentsManager = require("client.slua.logic.tournament.TournamentsManager")
    state = TournamentsManager.bonusCfg.redPointBonus
  end
  return state
end
function lobby_main_right_bottom_tab:PlayNewMailAnim()
  if self.mailAnimTimer then
    self:RemoveTimer(self.mailAnimTimer)
    self.mailAnimTimer = nil
  end
  self.mailAnimTimer = self:AddTimerOnce(10, function()
    self.UIRoot:StopAnimation(self.UIRoot.NewAnimation_Fold_Mail)
    self.WidgetSwitcher_Fold:SetActiveWidgetIndex(0)
    self:RemoveTimer(self.mailAnimTimer)
    self.mailAnimTimer = nil
  end)
  self.UIRoot:PlayAnimationTo(self.UIRoot.NewAnimation_Fold_Mail, 0, 1, 0, 0, 1)
end
function lobby_main_right_bottom_tab:UpdateUI()
  self.UIRoot.TextBlock_season:SetText(LocUtil.LocalizeResFormat(4720))
  self.UIRoot.TextBlock_AmoryTitle:SetText(LocUtil.LocalizeResFormat(7664))
  self.UIRoot.TextBlock_Corps:SetText(LocUtil.LocalizeResFormat(33020157))
  self.UIRoot.TextBlock_DepotTitleNew:SetText(LocUtil.LocalizeResFormat(4313))
  self:UpdateNewMailUI()
  self:SetSeasonIcon()
  self:SetSegmentIcon()
  self:SeasonIsOpen()
  self:UpdateWeakGuide()
  self:UpdateRestrict()
  self:RefreshThemeEntrance()
end
function lobby_main_right_bottom_tab:UpdateRestrict()
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  local isRestrict = QRcodeRestrictManager:IsRestrictDepotCheck()
  self:SetWidgetVisible(self.UIRoot.Image_lock, isRestrict)
end
function lobby_main_right_bottom_tab:UpdateWeakGuide()
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  if growthprojectMgrB.IsWeakGuideSeasonStep1() then
    self.UIRoot.NewbieGuide_Season:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.TextBlock_3:SetText(LocUtil.GetLocalizeResStr(12763))
  else
    self.UIRoot.NewbieGuide_Season:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if growthprojectMgrB.IsWeakGuideTaskStep1() then
    self.UIRoot.Canvas_NewbieGuide:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.TextBlock_2:SetText(LocUtil.GetLocalizeResStr(12757))
  else
    self.UIRoot.Canvas_NewbieGuide:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if growthprojectMgrB.IsWeakGuideDeleteResidEntentry() then
    local ui = self:CreateChildWindow(self.UIRoot.CanvasPanel_0, UIManager.UI_Config.Lobby_Mid_Newbie_Tab_Close_UIBP)
    self:SetWidgetVisible(self.UIRoot.Lobby_Tab_Item_UIBP.CanvasPanel_Tips, true)
    self.UIRoot.Lobby_Tab_Item_UIBP.UTRichTextBlock_2:SetText(LocUtil.GetLocalizeResStr(29605))
  else
    local ui = UIManager.GetUI(UIManager.UI_Config.Lobby_Mid_Newbie_Tab_Close_UIBP)
    if ui then
      UIManager.CloseUI(UIManager.UI_Config.Lobby_Mid_Newbie_Tab_Close_UIBP)
    end
    self:SetWidgetVisible(self.UIRoot.Lobby_Tab_Item_UIBP.CanvasPanel_Tips, false)
  end
end
function lobby_main_right_bottom_tab:OnLevelUnLockGuideStart()
  self:SetWidgetVisible(self.UIRoot.SizeBox_Workshop, true)
  self:SetWidgetVisible(self.UIRoot.SizeBox_Season, true)
  self:CheckForHideFeature()
end
function lobby_main_right_bottom_tab:Close()
  self.lobbySystemInRightBottom = nil
  if self.safeStationTimer then
    self:RemoveTimer(self.safeStationTimer)
    self.safeStationTimer = nil
  end
  lobby_main_right_bottom_tab.__super.Close(self)
  if not self.UIRoot then
    return
  end
  self.UIRoot.Reddot_Anchor_Wardrobe:UnBind()
end
function lobby_main_right_bottom_tab:OnButton_FoldUI_MailClick()
  self:PlayAudio(sound_config.new_mailBtn)
  local logic_mail = require("client.slua.logic.mail.logic_mail")
  logic_mail.OpenMailUI()
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.LobbyMail, 0, "Strongtips")
end
function lobby_main_right_bottom_tab:OnButton_FoldUI_BottomRightClick()
  self:PlayAudio(sound_config.popup_v1)
  local logic_lobby_system_extension = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lobby_system_extension)
  UIManager.ShowUI(UIManager.UI_Config.Lobby_Mid_LobbySystemEntrance_UIBP)
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_OPEN_RIGHTBOTTOM_MENU)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.LobbyMore)
  local level_unlock_util = require("client.logic.level_unlock.util.level_unlock_util")
  local bHaveLockedFeature = level_unlock_util:HaveLockedFeature()
  log(bWriteLog and "lobby_main_right_bottom_tab:OnButton_FoldUI_BottomRightClick bHaveLockedFeature = " .. tostring(bHaveLockedFeature))
  if bHaveLockedFeature then
    local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
    level_unlock_manager:ResetShowFoldNew()
    self:UpdateArrowReddot()
  end
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  level_unlock_manager:OnClickMain(UIManager.UI_Config.lobby_main_right_bottom_tab)
end
function lobby_main_right_bottom_tab:OnButton_SeasonClick()
  local logic_leisure_season = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_leisure_season)
  if not logic_leisure_season:IsLeisureSeasonOpen() then
    log(bWriteLog and "lobby_main_right_bottom_tab:OnButton_SeasonClick old season")
    self:OnButton_SeasonClick_Old()
    return
  end
  self:PlayAudio(sound_config.click_v1)
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  growthprojectMgrB.HideWeakGuide(7, 1)
  if not LobbySystem.CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_SEASON) then
    log_warning(bWriteLog and "obby_main_right_bottom_tab:OnButton_SeasonClick menu not open")
    return
  end
  local SeasonVerCfg = CDataTable.GetTableData("SeasonVersion", DataMgr.season_id)
  local version_util = require("client.common.version_util")
  local _clientVersion3 = version_util.GetClientFormat(Client.GetAppVersion())
  if not SeasonVerCfg then
    log_warning(bWriteLog and "obby_main_right_bottom_tab:OnButton_SeasonClick SeasonVerCfg is nil, season_id = " .. DataMgr.season_id .. "")
    return
  end
  if SeasonVerCfg and version_util.CompareVersionStandard(_clientVersion3, SeasonVerCfg.MinVersion) < 0 then
    ShowNotice(9409)
    return
  end
  local logic_season_util = require("client.logic.season.logic_season_util")
  logic_season_util.OpenClassicSeasonUI()
  gem_report_utils.ReportLobbyClickEvent("LobbySeason")
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.LobbySeason, 0, "lobbyEntrance")
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  level_unlock_manager:OnClickFeature(level_unlock_manager.featureDef.season)
  local regionGroupConfig = CDataTable.GetTableData("RegionGroupConfig", FuncUtil.GetAccountRegionForBP())
  if regionGroupConfig and regionGroupConfig.CommunityEntranceSwitch ~= 0 then
    local wonderfulPBReddot = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_peakgame_WonderfulPlayBack_Reddot)
    wonderfulPBReddot:RequestWonderfulPlayBackState("main")
  end
end
function lobby_main_right_bottom_tab:OnButton_SeasonClick_Old()
  local season_year_util = require("client.logic.season_year.util.season_year_util")
  local seasonYearOpen = season_year_util.CheckFunctionIsOpen()
  if seasonYearOpen then
    self:PlayAudio(sound_config.click_v1)
  else
    self:PlayAudio(sound_config.new_seasonBtn)
  end
  local BusinessHelper = import("BusinessHelper")
  BusinessHelper.StartUIStat("\232\181\155\229\173\163")
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  growthprojectMgrB.HideWeakGuide(7, 1)
  if not LobbySystem.CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_SEASON) then
    return
  end
  local SeasonVerCfg = CDataTable.GetTableData("SeasonVersion", DataMgr.season_id)
  local version_util = require("client.common.version_util")
  local _clientVersion3 = version_util.GetClientFormat(Client.GetAppVersion())
  if not SeasonVerCfg then
    return
  end
  if SeasonVerCfg and version_util.CompareVersionStandard(_clientVersion3, SeasonVerCfg.MinVersion) < 0 then
    ShowNotice(9409)
    return
  end
  local SeasonSystem = require("client.logic.season.logic_season")
  local logic_season_switch_slap = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_switch_slap)
  if logic_season_switch_slap:TryShowSeasonSwitchSlapForReturner() then
    log(bWriteLog and "MainCity_Lobby_Main_Match_Entry_UIBP:OnButton_SeasonClick_Old show season switch slap for returner")
    return
  end
  local ClientVersion = Client.GetAppVersion()
  log(bWriteLog and "[COLE]ClientVersion " .. tostring(ClientVersion) .. "  MinVersion " .. tostring(SeasonVerCfg.MinVersion) .. " MaxVersion " .. SeasonVerCfg.MaxVersion .. " DataMgr.season_id " .. DataMgr.season_id)
  if not seasonYearOpen and 0 > version_util.CompareVersionFull(ClientVersion, SeasonVerCfg.MaxVersion) and 0 <= version_util.CompareVersionFull(ClientVersion, SeasonVerCfg.MinVersion) then
    UIManager.ShowUI(UIManager.UI_Config.ui_season_anim_mgr)
    gem_report_utils.ReportBtnClickEvent(gem_report_utils.SubEventName_LobbySeason)
  elseif SeasonSystem.CheckShowSeasonGuide() then
    SeasonSystem.ShowSeasonGuide()
  else
    SeasonSystem.ShowSeasonHomepage()
  end
  gem_report_utils.ReportLobbyClickEvent("LobbySeason")
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.LobbySeason, 0, "lobbyEntrance")
  BusinessHelper.StopUIStat("\232\181\155\229\173\163", true)
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  level_unlock_manager:OnClickFeature(level_unlock_manager.featureDef.season)
end
function lobby_main_right_bottom_tab:OnButton_ArmoryClick()
  self:PlayAudio(sound_config.new_workshopBtn)
  self:OpenWorkshop()
end
function lobby_main_right_bottom_tab:OnButton_TaskNewClick()
  self:PlayAudio(sound_config.new_taskBtn)
  if not LobbySystem.CheckOpen(BP_ENUM_CARDCOLLECTION_SWITCH) then
    ShowNotice(23579)
    return
  end
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.LobbyCardCollection, 0)
  local CardCollectionUtil = require("client.slua.umg.CardCollection.CardCollectionUtil")
  local CardCollectionSeasonUIConfig = require("client.slua.logic.card_collection_season.CardCollectionSeasonUIConfig")
  CardCollectionUtil.OpenPanel(CardCollectionSeasonUIConfig.ECardCollectionPanelType.Main)
end
function lobby_main_right_bottom_tab:OnButton_DepotSystemNewClick()
  self:PlayAudio(sound_config.new_wareBtn)
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:IsRestrictDepotCheck() then
    QRcodeRestrictManager:ShowRestrictTips()
    return
  end
  local BusinessHelper = import("BusinessHelper")
  BusinessHelper.StartUIStat("\228\187\147\229\186\147")
  if not LobbySystem.CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_WARDROBE) then
    return
  end
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  WardrobeLogicManager:Enter()
  local wardrobe_red_point = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.wardrobe_red_point)
  wardrobe_red_point:HideWardrobeRedData()
  self:SetWardrobeRedPoint(false, true)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.LobbyRightBtnInventory)
  BusinessHelper.StopUIStat("\228\187\147\229\186\147", true)
end
function lobby_main_right_bottom_tab:OnButton_WorkshopBubbleClick()
  self:PlayAudio(sound_config.click)
  local logic_lab_new = require("client.slua.logic.lobby.lab.logic_lab_new")
  logic_lab_new.OnClickVideoBanner()
end
function lobby_main_right_bottom_tab:OpenWorkshop()
  local bSwitch = LobbySystem.CheckLobbyMenuOpen(BP_ENUM_SWITCH_WORK_SHOP, true)
  if not bSwitch then
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.lobby_lab_entrance)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.LobbyWorkshop)
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  level_unlock_manager:OnClickMain(UIManager.UI_Config.lobby_lab_entrance)
end
function lobby_main_right_bottom_tab:SetWardrobeRedPoint(show, force)
  log(bWriteLog and "lobby_main_right_bottom_tab:SetWardrobeRedPoint show:" .. tostring(show))
  self:ToggleReddotActivation(self.UIRoot.Reddot_Anchor_Wardrobe, show)
  self:SetWidgetVisible(self.UIRoot.Reddot_Anchor_Wardrobe, show)
  local logic_reddot_limitation = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_reddot_limitation)
  self.allowUpdate = logic_reddot_limitation:GetSyncReddotState("wardrobe").bUpdate
  if force then
    self.allowUpdate = false
    self:SetWidgetVisible(self.UIRoot.Reddot_Anchor_Wardrobe.CanvasPanel_Anchor, show)
    logic_reddot_limitation:SyncReddotState("wardrobe", show, false)
  elseif self.allowUpdate ~= false then
    self:SetWidgetVisible(self.UIRoot.Reddot_Anchor_Wardrobe.CanvasPanel_Anchor, show)
    logic_reddot_limitation:SyncReddotState("wardrobe", show)
  end
end
function lobby_main_right_bottom_tab:RedPointUpdate(eventId, eventName, moduleId, RedPoint)
  if moduleId == BP_ENUM_MODULE_WorkShop then
    self:BindWorkShopReddot()
  end
  self:UpdateArrowReddot()
end
function lobby_main_right_bottom_tab:OnUpdateSeason()
  self:SetSeasonIcon()
end
function lobby_main_right_bottom_tab:OnRefreshSegment()
  self:SetSeasonIcon()
  self:SetSegmentIcon()
end
function lobby_main_right_bottom_tab:SetSeasonIcon()
  self:SetWidgetVisible(self.UIRoot.SizeBox_3, false)
  if not DataMgr.season_id then
    self.UIRoot.TextBlock_0:SetText("")
    self.UIRoot.Image_SeasonIcon:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.Common_RankIntegralLevel_Style_Small_UIBP:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  local info = CDataTable.GetTableData("SeasonInfo", DataMgr.season_id)
  if info then
    local iconPath = info.SeasonIconPath
    self:SetTexture(self.UIRoot.Image_SeasonIcon, iconPath)
    self.UIRoot.Image_SeasonIcon:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.Common_RankIntegralLevel_Style_Small_UIBP:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.TextBlock_0:SetText(info.SeasonNameNew .. "/")
  end
end
function lobby_main_right_bottom_tab:SetSegmentIcon()
  local maxRank = 101
  for _, v in pairs(DataMgr.roleData.allzoneSegment) do
    for kk, vv in pairs(v) do
      if maxRank < tonumber(vv) then
        maxRank = tonumber(vv)
      end
    end
  end
  self.UIRoot.Common_RankIntegralLevel_Style_Small_UIBP:SetRankInteral(maxRank, nil)
end
function lobby_main_right_bottom_tab:SeasonIsOpen()
  if not LobbySystem.CheckOpen(BP_ENUM_LOBBY_MENU_SEASON) then
    self.UIRoot.SizeBox_12:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    return
  end
  local SeasonVerCfg = CDataTable.GetTableData("SeasonVersion", DataMgr.season_id)
  local version_util = require("client.common.version_util")
  local ClientVersion = version_util.GetClientFormat(Client.GetAppVersion())
  if SeasonVerCfg and version_util.CompareVersionStandard(ClientVersion, SeasonVerCfg.MinVersion) < 0 then
    self.UIRoot.SizeBox_12:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    return
  end
  self.UIRoot.SizeBox_12:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function lobby_main_right_bottom_tab:SetLobbySystemInRightBottom()
  local UIComponentModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.UIComponentModule)
  self.lobbySystemInRightBottom = UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.lobby_system_in_right_bottom, self.UIRoot.Lobby_Tab_Item_UIBP)
end
function lobby_main_right_bottom_tab:OnClickSetSystemEntrance(eventid, eventname, type, SystemID)
  local lobby_system_entrance_marco = require("client.slua.logic.lobby.lobby_system_entrance_marco")
  if type == lobby_system_entrance_marco.PopUIType.lobby_system_in_right_bottom then
    if SystemID == lobby_system_entrance_marco.SystemIDDefine.MAIL then
      self.bIsMailUIOnTab = false
      self:UpdateNewMailUI()
    end
  elseif type == lobby_system_entrance_marco.PopUIType.Lobby_Mid_LobbySystemEntrance_UIBP and SystemID == lobby_system_entrance_marco.SystemIDDefine.MAIL then
    self.bIsMailUIOnTab = true
    self:UpdateNewMailUI()
  end
end
function lobby_main_right_bottom_tab:UpdateLobbyLabEntranceRedPoint()
  local logic_lab_new = require("client.slua.logic.lobby.lab.logic_lab_new")
  local bannerData = logic_lab_new.GetVideoBannerData()
  local labEntrance = UIManager.GetUI(UIManager.UI_Config.lobby_lab_entrance)
  if bannerData and not labEntrance then
    self.UIRoot.Lobby_Main_Bubble_Workshop:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    local videoCfg = CDataTable.GetTableData("LabVideoCfg", bannerData.item_id)
    if videoCfg then
      local asset_util = require("common.asset_util")
      local texture = asset_util.GetAssetSync(videoCfg.icon)
      self.UIRoot.Lobby_Main_Bubble_Workshop.Image_ResearchBanner:SetBrushFromTexture(texture, false)
    end
  else
    self.UIRoot.Lobby_Main_Bubble_Workshop:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if logic_lab_new.CheckNeedNew() then
    self.UIRoot.Image_ReserchNew:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    LobbySystem.LobbyRedPointUpdate(BP_ENUM_LOBBY_MENU_LAB, false)
    return
  else
    self.UIRoot.Image_ReserchNew:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function lobby_main_right_bottom_tab:UpdateSystemEntrance()
  self:UpdateArrowReddot()
end
function lobby_main_right_bottom_tab:NeedShowFoldNew()
  local level_unlock_util = require("client.logic.level_unlock.util.level_unlock_util")
  local bHaveLockedFeature = level_unlock_util:HaveLockedFeature()
  log(bWriteLog and "lobby_main_right_bottom_tab:OnButton_FoldUI_BottomRightClick bHaveLockedFeature = " .. tostring(bHaveLockedFeature))
  if bHaveLockedFeature then
    local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
    return level_unlock_manager:IsShowFoldNew()
  end
  return false
end
function lobby_main_right_bottom_tab:RefreshThemeEntrance()
  local ThemeConfig = require("client.slua.logic.theme_system.theme_config")
  local entryConfig = ThemeConfig.GetEntryBannerConfig()
  if entryConfig then
    local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
    local bHasUGCMatchInfo = LogicUGCMatch:HasUGCMatchInfo()
    if bHasUGCMatchInfo then
      local MatchInfo = LogicUGCMatch:GetMatchInfo()
      if MatchInfo and MatchInfo.setting and MatchInfo.setting.team_size then
        local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
        local DefaultTeamSize = TeamUpNewSystem.GetDefaultMaxTeamNum()
        if DefaultTeamSize < MatchInfo.setting.team_size then
          self.UIRoot.SizeBox_Theme:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
          self.UIRoot.CanvasPanel_Theme:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
          return
        end
      end
    end
    local playerLevel = DataMgr.roleData.level
    if playerLevel < 5 then
      self.preLevel = playerLevel
      log(bWriteLog and "lobby_main_right_bottom_tab:RefreshThemeEntrance hide theme entrance.")
      return
    end
    local urlPath = entryConfig.EntryURL
    local util = require("client.slua_ui_framework.util")
    if urlPath and urlPath ~= "" then
      if util.IsOnlineImageUrl(urlPath) then
        local imgUrl = util.GetUrlByLanguage(urlPath)
        local failFunc = function(url)
          self:SetTexture(self.UIRoot.Theme_EntranceIcon, urlPath, {ifAddRef = true, tryTimes = 2})
        end
        self:SetTexture(self.UIRoot.Theme_EntranceIcon, imgUrl, {ifAddRef = true, onDownloadFail = failFunc})
      else
        self:SetTexture(self.UIRoot.Theme_EntranceIcon, urlPath, {sync = true})
      end
    end
    self.UIRoot.SizeBox_Theme:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.CanvasPanel_Theme:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.TextBlock_7:SetText(LocUtil.GetLocalizeResStr(77491))
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_Version1, true, false)
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_Version2, false, false)
    local newEntryConfig = ThemeConfig.GetNextVersionEntryBannerConfig()
    if newEntryConfig then
      self.UIRoot.TextBlock_12:SetText(LocUtil.GetLocalizeResStr(77491))
      local newUrlPath = newEntryConfig.EntryURL
      if newUrlPath and newUrlPath ~= "" then
        if util.IsOnlineImageUrl(newUrlPath) then
          local imgUrl = util.GetUrlByLanguage(newUrlPath)
          local failFunc = function(url)
            self:SetTexture(self.UIRoot.Theme_EntranceIcon_Version2, newUrlPath, {ifAddRef = true, tryTimes = 2})
          end
          self:SetTexture(self.UIRoot.Theme_EntranceIcon_Version2, imgUrl, {ifAddRef = true, onDownloadFail = failFunc})
        else
          self:SetTexture(self.UIRoot.Theme_EntranceIcon_Version2, newUrlPath, {sync = true})
        end
      end
    end
    local theme_system_reddot = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.theme_system_reddot)
    local logic_theme_system = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_theme_system)
    if logic_theme_system:CheckThemeSystemNew() then
      theme_system_reddot:SetNewRedDot()
      log(bWriteLog and string.format("lobby_main_right_bottom_tab:RefreshThemeEntrance show new red dot."))
    else
      log(bWriteLog and string.format("lobby_main_right_bottom_tab:RefreshThemeEntrance hide new red dot."))
      theme_system_reddot:CloseNewRedDot()
    end
    if logic_theme_system:CheckNextVersionPreheatRedDot() then
      log(bWriteLog and "lobby_main_right_bottom_tab:RefreshThemeEntrance show next version preheat red dot.")
      theme_system_reddot:SetNextVersionPreheatRedDot()
    else
      log(bWriteLog and "lobby_main_right_bottom_tab:RefreshThemeEntrance hide next version preheat red dot.")
      theme_system_reddot:CloseNextVersionPreheatRedDot()
    end
    if logic_theme_system:CheckMidTermActivityPreheatRedDot() then
      log(bWriteLog and "lobby_main_right_bottom_tab:RefreshThemeEntrance show mid term activity preheat red dot.")
      theme_system_reddot:SetNewActivityRedDot()
    else
      log(bWriteLog and "lobby_main_right_bottom_tab:RefreshThemeEntrance hide mid term activity preheat red dot.")
      theme_system_reddot:CloseNewActivityRedDot()
    end
    if logic_theme_system:CheckCurThemeActOpenRedDot() then
      log(bWriteLog and "lobby_main_right_bottom_tab:RefreshThemeEntrance show CurThemeActOpen red dot.")
      theme_system_reddot:SetThemeActOpenRedDot()
    else
      log(bWriteLog and "lobby_main_right_bottom_tab:RefreshThemeEntrance hide CurThemeActOpen red dot.")
      theme_system_reddot:CloseThemeActOpenRedDot()
    end
    theme_system_reddot:UpdateThemeActRewardRedDot()
    theme_system_reddot:UpdateThemeSystemTaskReddot()
    local redDotData = theme_system_reddot:GetRedDotData()
    self.UIRoot.Theme_RedDot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.Theme_RedDot:UnBind()
    self:RegistReddotWidget(self.UIRoot.Theme_RedDot)
    self.UIRoot.Theme_RedDot:Bind(redDotData)
  else
    self.UIRoot.SizeBox_Theme:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.CanvasPanel_Theme:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function lobby_main_right_bottom_tab:OnButton_ThemeClick()
  self:PlayAudio(sound_config.click_v1)
  local ui_jump_manager = require("client.common.uibase.ui_jump_manager")
  local logic_theme_system = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_theme_system)
  local theme_system_reddot = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.theme_system_reddot)
  local ThemeConfig = require("client.slua.logic.theme_system.theme_config")
  if logic_theme_system:CheckThemeSystemNew() then
    ui_jump_manager.OpenJumpModule(BP_ENUM_MODULE_THEME_SYSTEM, {
      tab = ThemeConfig.SubSystem.GameIntroduction
    })
  elseif logic_theme_system:CheckNextVersionPreheatRedDot() then
    ui_jump_manager.OpenJumpModule(BP_ENUM_MODULE_THEME_SYSTEM, {
      tab = ThemeConfig.SubSystem.GameIntroduction
    })
  elseif logic_theme_system:CheckMidTermActivityPreheatRedDot() then
    ui_jump_manager.OpenJumpModule(BP_ENUM_MODULE_THEME_SYSTEM, {
      tab = ThemeConfig.SubSystem.MapIntroduction
    })
  elseif logic_theme_system:CheckCurThemeActOpenRedDot() then
    ui_jump_manager.OpenJumpModule(BP_ENUM_MODULE_THEME_SYSTEM, {
      tab = ThemeConfig.SubSystem.GameIntroduction
    })
  elseif theme_system_reddot:HasExchangeNewRedDot() then
    ui_jump_manager.OpenJumpModule(BP_ENUM_MODULE_THEME_SYSTEM, {
      tab = ThemeConfig.SubSystem.ExchangeStore
    })
  elseif logic_theme_system:CheckTaskFinishedRedDot() then
    ui_jump_manager.OpenJumpModule(BP_ENUM_MODULE_THEME_SYSTEM, {
      tab = ThemeConfig.SubSystem.Task
    })
  elseif theme_system_reddot:HasAwardReddot() then
    ui_jump_manager.OpenJumpModule(BP_ENUM_MODULE_THEME_SYSTEM, {
      tab = ThemeConfig.SubSystem.GameIntroduction
    })
  else
    ui_jump_manager.OpenJumpModule(BP_ENUM_MODULE_THEME_SYSTEM, {lastSelect = true})
  end
  ClientSendTLogReport(TLogEventDefine.ThemeSystemEnter, 0)
end
function lobby_main_right_bottom_tab:OnThemeSystemRefreshNewMark()
  self:DelayRefreshThemeExchangeReddotUI()
end
function lobby_main_right_bottom_tab:DelayRefreshThemeExchangeReddotUI()
  if self.DelayRefreshThemeExchangeReddotUITimer then
    self:RemoveTimer(self.DelayRefreshThemeExchangeReddotUITimer)
    self.DelayRefreshThemeExchangeReddotUITimer = nil
  end
  self.DelayRefreshThemeExchangeReddotUITimer = self:AddTimerOnce(0, function()
    self:RefreshThemeExchangeReddotUI()
  end)
end
function lobby_main_right_bottom_tab:RefreshThemeExchangeReddotUI()
  log(bWriteLog and "lobby_main_right_bottom_tab:RefreshThemeExchangeReddotUI")
  local theme_system_reddot = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.theme_system_reddot)
  local logic_theme_system = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_theme_system)
  self:StopAnimationCheck(self.UIRoot.Anim_NewAward_Loop)
  self:StopAnimationCheck(self.UIRoot.Anim_NewAward)
  self:StopAnimationCheck(self.UIRoot.Anim_ThemePreheat)
  self:PlayUserWidgetAnimationCheck(self.UIRoot.Anim_NoAward, 0, 1, 0, 1)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Version2, false, false)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Version1, true, false)
  if theme_system_reddot:HasNewRedDot() then
    log(bWriteLog and "lobby_main_right_bottom_tab:RefreshThemeExchangeReddotUI has playmode new")
  elseif theme_system_reddot:HasNextVersionPreheatRedDot() then
    log(bWriteLog and "lobby_main_right_bottom_tab:RefreshThemeExchangeReddotUI has next version preheat")
    if not self.bInitNewThemeEntryEffect then
      local ThemeConfig = require("client.slua.logic.theme_system.theme_config")
      local newEntryConfig = ThemeConfig.GetNextVersionEntryBannerConfig()
      if newEntryConfig then
        local highLighPath = newEntryConfig.EntryLightImagePath
        local maskPath = newEntryConfig.EntryMaskPath
        self:SetTexture(self.UIRoot.Theme_EntranceIcon_Yellow_Version2, highLighPath, {sync = true})
        self:SetAnimationMaterial(ThemeConfig.ThemeEntryMat2, maskPath, self.UIRoot.Image_SweepLight_2, "Tex")
        self:SetAnimationMaterial(ThemeConfig.ThemeEntryLoopMat2, maskPath, self.UIRoot.Image_SweepLight_Loop_2, "MaskTexture")
        self.bInitNewThemeEntryEffect = true
      end
    end
    if self.bInitNewThemeEntryEffect then
      log(bWriteLog and "lobby_main_right_bottom_tab:RefreshThemeExchangeReddotUI play Anim_ThemePreheat")
      self:SetWidgetVisible(self.UIRoot.CanvasPanel_Version2, true, false)
      self:SetWidgetVisible(self.UIRoot.CanvasPanel_Version1, false, false)
    end
  elseif theme_system_reddot:HasNewActivityRedDot() then
    log(bWriteLog and "lobby_main_right_bottom_tab:RefreshThemeExchangeReddotUI has new activity reddot")
    local ThemeConfig = require("client.slua.logic.theme_system.theme_config")
    local midTermActivityConfig = ThemeConfig.GetOperationActivityConfig()
    if not self.bInitThemeEntryEffect then
      self.bInitThemeEntryEffect = true
      local ThemeConfig = require("client.slua.logic.theme_system.theme_config")
      local entryConfig = ThemeConfig.GetEntryBannerConfig()
      local highLighPath = entryConfig.EntryLightImagePath
      local maskPath = entryConfig.EntryMaskPath
      self:SetTexture(self.UIRoot.Theme_EntranceIcon_Yellow, highLighPath, {sync = true})
      self:SetAnimationMaterial(ThemeConfig.ThemeEntryMat, maskPath, self.UIRoot.Image_SweepLight, "Tex")
      self:SetAnimationMaterial(ThemeConfig.ThemeEntryLoopMat, maskPath, self.UIRoot.Image_SweepLight_Loop, "MaskTexture")
    end
    self:AddTimerOnce(0, function()
      self.UIRoot.TextBlock_8:SetText(midTermActivityConfig.Name)
      self:PlayUserWidgetAnimationCheck(self.UIRoot.Anim_NewAward, 0, 1, 0, 1)
      local animTime = self.UIRoot.Anim_NewAward:GetEndTime()
      self:AddTimerOnce(animTime, function()
        self:PlayUserWidgetAnimationCheck(self.UIRoot.Anim_NewAward_Loop, 0, 0, 0, 1)
      end)
    end)
  elseif theme_system_reddot:HasExchangeNewRedDot() then
    log(bWriteLog and "lobby_main_right_bottom_tab:RefreshThemeExchangeReddotUI has reddot")
    if not self.bInitThemeEntryEffect then
      self.bInitThemeEntryEffect = true
      local ThemeConfig = require("client.slua.logic.theme_system.theme_config")
      local entryConfig = ThemeConfig.GetEntryBannerConfig()
      local highLighPath = entryConfig.EntryLightImagePath
      local maskPath = entryConfig.EntryMaskPath
      self:SetTexture(self.UIRoot.Theme_EntranceIcon_Yellow, highLighPath, {sync = true})
      self:SetAnimationMaterial(ThemeConfig.ThemeEntryMat, maskPath, self.UIRoot.Image_SweepLight, "Tex")
      self:SetAnimationMaterial(ThemeConfig.ThemeEntryLoopMat, maskPath, self.UIRoot.Image_SweepLight_Loop, "MaskTexture")
    end
    self:AddTimerOnce(0, function()
      local NewType2Text = {
        [1] = 69330,
        [2] = 69331,
        [3] = 69332
      }
      log(bWriteLog and "lobby_main_right_bottom_tab:RefreshThemeExchangeReddotUI play Anim_NewAward")
      local newType = logic_theme_system:GetExchangeNewType()
      self.UIRoot.TextBlock_8:SetText(LocUtil.GetLocalizeResStr(NewType2Text[newType]))
      self:PlayUserWidgetAnimationCheck(self.UIRoot.Anim_NewAward, 0, 1, 0, 1)
      local animTime = self.UIRoot.Anim_NewAward:GetEndTime()
      self:AddTimerOnce(animTime, function()
        log(bWriteLog and "lobby_main_right_bottom_tab:RefreshThemeExchangeReddotUI play Anim_NewAward_Loop")
        self:PlayUserWidgetAnimationCheck(self.UIRoot.Anim_NewAward_Loop, 0, 0, 0, 1)
      end)
    end)
  elseif theme_system_reddot:HasTaskFinishedRedDot() then
    log(bWriteLog and "lobby_main_right_bottom_tab:RefreshThemeExchangeReddotUI has TaskFinished")
  elseif theme_system_reddot:HasThemeActOpenRedDot() then
    log(bWriteLog and "lobby_main_right_bottom_tab:RefreshThemeExchangeReddotUI has ThemeActOpen")
  elseif theme_system_reddot:HasThemeActRewardRedDot() then
    log(bWriteLog and "lobby_main_right_bottom_tab:RefreshThemeExchangeReddotUI has ThemeActReward")
  else
    log(bWriteLog and "lobby_main_right_bottom_tab:RefreshThemeExchangeReddotUI no reddot")
  end
end
function lobby_main_right_bottom_tab:PlayUserWidgetAnimationCheck(WidgetAnimation, startAtTime, numLoopsToPlay, playMode, playbackSpeed)
  if WidgetAnimation then
    self:PlayUserWidgetAnimation(WidgetAnimation, startAtTime, numLoopsToPlay, playMode, playbackSpeed)
  else
    log(bWriteLog and "lobby_main_right_bottom_tab:PlayUserWidgetAnimationCheck WidgetAnimation is nil")
  end
end
function lobby_main_right_bottom_tab:StopAnimationCheck(WidgetAnimation)
  if WidgetAnimation then
    self:StopAnimation(WidgetAnimation)
  end
end
function lobby_main_right_bottom_tab:SetAnimationMaterial(matPath, imagePath, imageWidget, texName)
  if not (matPath and imagePath) or not imageWidget then
    return
  end
  local asset_util = require("common.asset_util")
  local KismetMaterialLibrary = import("KismetMaterialLibrary")
  local UIUtil = require("client.common.ui_util")
  local material = asset_util.GetAssetSync(matPath)
  local dynamicMatIns = KismetMaterialLibrary.CreateDynamicMaterialInstance(UIUtil.GetGameInstance(), material)
  local texture = asset_util.GetAssetSync(imagePath)
  if dynamicMatIns and texture then
    dynamicMatIns:SetTextureParameterValue(texName, texture)
    self:SetWidgetVisible(imageWidget, true)
    imageWidget:SetBrushFromMaterial(dynamicMatIns)
  end
end
function lobby_main_right_bottom_tab:CheckLevelUnlockThemeEntry()
  log(bWriteLog and "lobby_main_right_bottom_tab:CheckLevelUnlockThemeEntry")
  if not self.preLevel then
    log(bWriteLog and "lobby_main_right_bottom_tab:CheckLevelUnlockThemeEntry preLevel is nil")
    return
  end
  if DataMgr.roleData.level >= 5 then
    self:RefreshThemeEntrance()
    self.preLevel = nil
  else
    log(bWriteLog and "lobby_main_right_bottom_tab:CheckLevelUnlockThemeEntry level not reached")
  end
end
function lobby_main_right_bottom_tab:BindCardCollectionRedDot()
  local card_collection_reddot_data = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.card_collection_reddot_data)
  local redDotData = card_collection_reddot_data:GetRedDotData()
  if redDotData and self.UIRoot.Reddot_Anchor_TaskNewTips then
    self.UIRoot.Reddot_Anchor_TaskNewTips:Bind(redDotData)
    self:RegistReddotWidget(self.UIRoot.Reddot_Anchor_TaskNewTips)
    card_collection_reddot_data:RefreshAllReddots()
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local Clobby_main_right_bottom_tab = class(ui_base, nil, lobby_main_right_bottom_tab)
return Clobby_main_right_bottom_tab