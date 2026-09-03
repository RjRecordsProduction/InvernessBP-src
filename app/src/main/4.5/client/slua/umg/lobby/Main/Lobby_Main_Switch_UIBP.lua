local Lobby_Main_Switch_UIBP = {}
local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
local string_util = require("common.string_util")
local ANI_NAMES = {
  [1] = "Anim_Offset_Tab_SocialToLobby",
  [2] = "Anim_Offset_Tab_SocialToMode",
  [10] = "Anim_Offset_Tab_LobbyToSocial",
  [12] = "Anim_Offset_Tab_LobbyToMode",
  [20] = "Anim_Offset_Tab_ModeToSocial",
  [21] = "Anim_Offset_Tab_ModeToLobby"
}
local SELECT_BORDER_NAMES = {
  [ENUM_LobbyPageType.Left] = "Border_Left_Select",
  [ENUM_LobbyPageType.Mid] = "Border_Mid_Select",
  [ENUM_LobbyPageType.Right] = "Border_Right_Select"
}
local VISIBLE_COLOR = FLinearColor(1, 1, 1, 1)
local HIDE_COLOR = FLinearColor(1, 1, 1, 0)
function Lobby_Main_Switch_UIBP:ctor()
end
function Lobby_Main_Switch_UIBP:OnInitialize()
  Lobby_Main_Switch_UIBP.__super.OnInitialize(self)
  self:InitJaguarDisplay()
  self.util = require("client.slua_ui_framework.util")
  self.Button_Left = self.UIRoot.Button_Left
  self.Button_Mid = self.UIRoot.Button_Mid
  self.Button_Right = self.UIRoot.Button_Right
  self.isJumpPage = false
  self.IsShowRightMode = false
end
function Lobby_Main_Switch_UIBP:RegistEvents()
  Lobby_Main_Switch_UIBP.__super.RegistEvents(self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Left, self.OnButton_LeftClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Mid, self.OnButton_MidClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Right, self.OnButton_RightClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Report, self.OnButton_ReportClick, self)
  self:AddControlEventByControl(self.UIRoot.Fadeout, "OnAnimationFinished", self.OnAniFadeoutEnd, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_SWITCHTO_PAGE_SIMU, self.SwitchToPageEvent, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_SWITCHTO_PAGE_END, self.UpdateNewIcon, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_ON_NOTIFY_LOBBY_TOP_NEWS, self.UpdateNewIcon, self)
  self:AddCommonEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_APPLYLIST_CHANGE, self.OnFriendApplylistChanged, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_SWITCH_PAGE_SHOW_HIDE, self.ShowHide, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_LOBBY_SOCIAL_PHOTO, self.UpdatePhoto, self)
  self:AddCommonEvent(EVENTTYPE_DOWNLOAD, EVENTID_PUFFER_JSON_POSTPROCESS, self.UpdateDownloadUI, self)
  self:AddCommonEvent(EVENTTYPE_DOWNLOAD, EVENTID_PUFFER_DELETE_SUCCESS, self.UpdateDownloadUI, self)
  self:AddCommonEvent(EVENTTYPE_DOWNLOAD, EVENTID_PUFFER_REFRESH_MAP, self.UpdateXmissionDownloadUI, self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, self.UpdateXmissionDownloadUI, self)
  self:AddCommonEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_INTIMACY_CHANGE, self.OnUpdateLeftNewIcon, self)
  self:AddCommonEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_INTIMACYAPPLY_CHANGE, self.OnUpdateLeftNewIcon, self)
  self:AddCommonEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PERSONSPACE_REDDOT_UPDATE, self.OnUpdateLeftNewIcon, self)
  self:AddCommonEvent(EVENTTYPE_MOMENT, EVENTID_MOMENT_BackGround_GetInfo, self.UpdateMomentReddot, self)
  self:AddCommonEvent(EVENTTYPE_MOMENT, EVENTID_MOMENT_BackGround_IsNew_Change, self.UpdateMomentReddot, self)
  self:AddCommonEvent(EVENTTYPE_MOMENT, EVENTID_MOMENT_BackGround_GETNEWBG, self.UpdateMomentReddot, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_ROLEINFO_CHANGE_CONVIENCE_MODE_SETTINGS, self.OnChangeConvienceSettingsRsp, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_NOTIFY_TOPHIDEPANEL, self.OnPlayedSlide, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_NOTIFY_RESETTOPPANEL, self.OnResetTopPanel, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_WOW_PASS_RED_DOT_STATE_CHANGE, self.OnWowHallRedPointChange, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_INVENTORY_SET_NEWITEM, self.OnWowHallRedPointChange, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_GET_APPRECIATIONGROUP_INFO, self.OnWowHallRedPointChange, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_JOIN_APPRECIATIONGROUP_SUCCESS, self.OnWowHallRedPointChange, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_APPRECIATION_TASK_SYNC, self.OnWowHallRedPointChange, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_APPRECIATION_TAKE_AWARD_RSP, self.OnWowHallRedPointChange, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_HALL_VISIT_INFO_UPDATE, self.OnWowHallRedPointChange, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_MAIN_CITY_REFRESH_ENTRY_SHOW, self.UpdateMainCityEntryShow, self)
  self:AddCommonEvent(EVENTTYPE_LEVEL_UNLOCK, EVENTID_LEVEL_UNLOCK_START_UNLOCK_GUIDE, self.UpdateMainCityEntryShow, self)
end
function Lobby_Main_Switch_UIBP:UpdatePhoto(_, _, in_photo)
  if in_photo then
    self:Collapsed()
  else
    self:SelfHitTestInvisible()
  end
end
function Lobby_Main_Switch_UIBP:ShowHide(_, _, isShow)
  self:SetWidgetVisibility(isShow and UEnums.ESlateVisibility.SelfHitTestInvisible or UEnums.ESlateVisibility.Collapsed)
end
function Lobby_Main_Switch_UIBP:OnPostInitialize()
  Lobby_Main_Switch_UIBP.__super.OnPostInitialize(self)
  local lobbyLogic = require("client.slua.logic.lobby.logic_lobby_main")
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsJapanOrKorea() then
    local imagePath = "/Game/UMG/Texture_200/Lobby_Image_JK_Tab_png.Lobby_Image_JK_Tab_png"
    if self.UIRoot.TextBlock_WoW then
      self:SetTexture(self.UIRoot.TextBlock_WoW, imagePath)
    end
    if self.UIRoot.TextBlock_WoW1 then
      self:SetTexture(self.UIRoot.TextBlock_WoW1, imagePath)
    end
  end
  self:SetWidgetVisible(self.UIRoot.Border_0, false)
  self:UpdateUI()
  self:UpdateDownloadUI()
  self:AddTimerLoop(0, function()
    if lobbyLogic.lobbyTopNewsStatus[ENUM_LobbyPageType.Left] == true or lobbyLogic.lobbyTopNewsStatus[ENUM_LobbyPageType.Mid] == true or self.bHaveRightUpdate == true then
      self:PlayNewInfoAnim()
    end
  end, TIMER_INFINITE, 2.5)
  self:ShowBtnReport()
  self:UpdateRightModeImage()
  self:AddTimerOnce(0, function()
    if slua.isValid(self.UIRoot) then
      self:SetWidgetVisible(self.UIRoot.Border_0, true)
    end
  end)
end
function Lobby_Main_Switch_UIBP:UpdateUI()
  log(bWriteLog and "Lobby_Main_Switch_UIBP:UpdateUI")
  local isRootValid = slua.isValid(self.UIRoot)
  if not isRootValid then
    return
  end
  local logic_home_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_switch)
  self.IsShowRightMode = logic_home_switch.isShowLobbyRightMode
  self:SetWidgetVisible(self.UIRoot.Canvas_R, self.IsShowRightMode)
  self:StopAnimation("Fadein")
  local mainLobbyLogic = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
  local curPage = mainLobbyLogic.curPage or ENUM_LobbyPageType.Mid
  self:AddTimerOnce(0, function()
    self:SetCurrentPage(curPage)
  end)
  log(bWriteLog and "Lobby_Main_Switch_UIBP:UpdateUI - cur page is: " .. curPage)
  self:UpdateNewIcon()
  self:CheckShowRightScreenNewbie()
  self:UpdateMainCityEntryShow()
  if isRootValid and self.UIRoot.Border_0 then
    self.UIRoot.Border_0:SetContentColorAndOpacity(VISIBLE_COLOR)
  end
  local LogicPufferBundle = require("client.slua.logic.download.bundle.logic_puffer_bundle")
  local isDownloaded = LogicPufferBundle.IsFitLobbyResDownloaded()
  self:SetWidgetVisible(self.UIRoot.Canvas_L, isDownloaded)
end
function Lobby_Main_Switch_UIBP:InitJaguarDisplay()
  self:SetWidgetVisible(self.UIRoot.Canvas_L, true)
  self:SetWidgetVisible(self.UIRoot.Canvas_M, true)
  self:SetWidgetVisible(self.UIRoot.Canvas_R, false)
end
function Lobby_Main_Switch_UIBP:UpdateNewIcon()
  self:UpdateLeftNewIcon()
  self:UpdateMidNewIcon()
  self:UpdateMomentReddot()
  self.UIRoot.Border_Right_New:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self:UpdateDownloadUI()
  self:UpdateRightModeImage()
end
function Lobby_Main_Switch_UIBP:UpdateLeftNewIcon()
  log(bWriteLog and "Lobby_Main_Switch_UIBP:UpdateLeftNewIcon")
  local mainLobbyLogic = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
  local lobbyLogic = require("client.slua.logic.lobby.logic_lobby_main")
  local curPage = mainLobbyLogic.curPage
  if curPage == ENUM_LobbyPageType.Left then
    lobbyLogic.close_top_red_point_req(1)
    self.UIRoot.Border_Left_New:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  local SocialReddotSystem = require("client.slua.logic.lobby.Left.logic_social_reddot")
  local logic_lobby_souvenirs = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lobby_souvenirs)
  local souvenirs_macro = require("client.slua.logic.TxMission.souvenirs.souvenirs_macro")
  if lobbyLogic.lobbyTopNewsStatus[ENUM_LobbyPageType.Left] == true or SocialReddotSystem.HaveRelationReddot() or logic_lobby_souvenirs:isCurStep(souvenirs_macro.LobbyTSouvenirsGuideStepType.EnumType_Click_Person_Space_Entry) then
    self.UIRoot.Border_Left_New:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot.Border_Left_New:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function Lobby_Main_Switch_UIBP:UpdateDownloadUI()
  self:UpdateXmissionDownloadUI()
  if not Client.IsJaguar() then
  end
  local common_download_handler = require("client.slua.common.common_download_handler")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local params = self:GetDownloaderParams(nil, ENUM_LobbyPageType.Left)
  common_download_handler.CreateDownloadUIReturnUIBase(PufferConst.ENUM_DownloadType.ODPACK, {
    PufferConst.EODPackID.SocialLobby
  }, self, self.UIRoot.Panel_Download, params)
end
function Lobby_Main_Switch_UIBP:UpdateMidNewIcon()
  log(bWriteLog and "Lobby_Main_Switch_UIBP:UpdateMidNewIcon")
  local mainLobbyLogic = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
  local lobbyLogic = require("client.slua.logic.lobby.logic_lobby_main")
  local curPage = mainLobbyLogic.curPage
  if curPage == ENUM_LobbyPageType.Mid then
    lobbyLogic.close_top_red_point_req(2)
    self.bHaveMidUpdate = false
    self.UIRoot.Border_Mid_New:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  if lobbyLogic.lobbyTopNewsStatus[ENUM_LobbyPageType.Mid] == true or self.bHaveMidUpdate then
    self.UIRoot.Border_Mid_New:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot.Border_Mid_New:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function Lobby_Main_Switch_UIBP:PlayNewInfoAnim()
  self.UIRoot:StopAnimation(self.UIRoot.NewAnimation_New)
  self.UIRoot:PlayAnimationTo(self.UIRoot.NewAnimation_New, 1, 1, 1, 0, 1)
end
function Lobby_Main_Switch_UIBP:OnUpdateLeftNewIcon()
  self:UpdateLeftNewIcon()
end
function Lobby_Main_Switch_UIBP:OnFriendApplylistChanged()
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local nums = LogicFriend.GetAllApplyCntWithProfileCheck()
  if 0 < nums then
    self.bHaveMidUpdate = true
  end
  self:UpdateMidNewIcon()
  self:UpdateLeftNewIcon()
end
function Lobby_Main_Switch_UIBP:SwitchToPageEvent(_, _, toPage, callback)
  log(bWriteLog and "Lobby_Main_Switch_UIBP:SwitchToPageEvent toPage = " .. tostring(toPage) .. " callback = " .. tostring(callback))
  local lobbyMainLogic = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
  local curPage = lobbyMainLogic.curPage
  if curPage == toPage then
    if callback then
      callback(false)
    end
  else
    self:SwitchToPage(toPage)
    if callback then
      callback(true)
    end
  end
end
function Lobby_Main_Switch_UIBP:HideNewbieUI()
  log(bWriteLog and "Lobby_Main_Switch_UIBP:HideNewbieUI.")
  if self.UIRoot.CanvasPanel_Newbie then
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_Newbie, false)
  end
end
function Lobby_Main_Switch_UIBP:SwitchToPage(toPage)
  local lobbyMainLogic = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
  local curPage = lobbyMainLogic.curPage
  if curPage == toPage then
    log(bWriteLog and "Lobby_Main_Switch_UIBP:SwitchToPage.same page = " .. tostring(curPage))
    return false
  end
  local LogicPufferBundle = require("client.slua.logic.download.bundle.logic_puffer_bundle")
  if not LogicPufferBundle.IsFitLobbyResDownloaded() and toPage == ENUM_LobbyPageType.Left then
    log_format("Lobby_Main_Switch_UIBP:SwitchToPage. left page not downloaded")
    return false
  end
  if not self.IsShowRightMode and toPage == ENUM_LobbyPageType.Right then
    log(bWriteLog and "Lobby_Main_Switch_UIBP:SwitchToPage. rightmode not open")
    return
  end
  if toPage == ENUM_LobbyPageType.Mid then
    local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
    if not FuncUtil.IsInXMission() then
      Lobby_camera_manager_module:LoadLightLevelByCameraID(Lobby_camera_manager_module.Enum_CameraID.Lobby_Default)
    end
  end
  if toPage == 0 then
    local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
    growthprojectMgrB.HideWeakGuide(5, 1)
  end
  lobbyMainLogic.lockPageTime = 5
  if toPage == ENUM_LobbyPageType.Right then
    local logic_home_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_switch)
    if logic_home_switch.lobbyRightMode == ENUM_LobbyRightMode.WowMode then
      lobbyMainLogic.lockPageTime = 0
    end
  end
  if lobbyMainLogic.LockPage() then
    if lobbyMainLogic.MoveToPage(toPage) then
      self:PlaySwitchPageButtonAnimation(curPage, toPage)
    else
      lobbyMainLogic.bAni = false
      logic_connection_waiting:Hide(0)
    end
    return true
  end
  return false
end
function Lobby_Main_Switch_UIBP:StopAllAnimations()
  log_format("Lobby_Main_Switch_UIBP:StopAllAnimations. %s", self)
  self:SetWidgetVisible(self.UIRoot.Border_0, true)
  for _, aniName in pairs(ANI_NAMES) do
    self:StopAnimation(aniName)
  end
end
function Lobby_Main_Switch_UIBP:PlaySwitchPageButtonAnimation(curPage, toPage, skipAudio)
  log_format("Lobby_Main_Switch_UIBP:PlaySwitchPageButtonAnimation. curPage=%s, toPage=%s, %s", curPage, toPage, self)
  if toPage == ENUM_LobbyPageType.Right and not self.IsShowRightMode then
    return
  end
  if not skipAudio then
    if ENUM_LobbyPageType.Left == curPage or ENUM_LobbyPageType.Left == toPage then
      self:PlayAudio(sound_config.new_hallSwitchHome)
    else
      self:PlayAudio(sound_config.new_hallSwitchActivity)
    end
  end
  self:StopAllAnimations()
  local key = curPage * 10 + toPage
  local animName = ANI_NAMES[key]
  if animName then
    self:PlayAnimation(animName, 0, 1, 0, 1)
  end
end
function Lobby_Main_Switch_UIBP:SetCurrentPage(toPage)
  log_format("Lobby_Main_Switch_UIBP:SetCurrentPage. toPage = %s, %s", toPage, self)
  self:StopAllAnimations()
  for key, borderName in pairs(SELECT_BORDER_NAMES) do
    local border = self.UIRoot[borderName]
    if border then
      local color = HIDE_COLOR
      if key == toPage then
        color = VISIBLE_COLOR
      end
      border:SetContentColorAndOpacity(color)
    end
  end
end
function Lobby_Main_Switch_UIBP:PlayFadeoutAnim()
  log(bWriteLog and "Lobby_Main_Switch_UIBP:PlayFadeoutAnim")
  self:PlayUserWidgetAnimation(self.UIRoot.Fadeout, 0, 1, 0, 1)
end
function Lobby_Main_Switch_UIBP:OnAniFadeoutEnd()
  log(bWriteLog and "Lobby_Main_Switch_UIBP:OnAniFadeoutEnd")
  self:AddTimerOnce(0.5, function()
    if slua.isValid(self.UIRoot) and self.UIRoot.Border_0 then
      self.UIRoot.Border_0:SetContentColorAndOpacity(VISIBLE_COLOR)
    end
  end)
end
function Lobby_Main_Switch_UIBP:OnButton_LeftClick()
  log(bWriteLog and "Lobby_Main_Switch_UIBP:OnButton_LeftClick")
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  if not growthprojectMgrB.CanSwitchUI() then
    return
  end
  local UIUtil = require("client.common.ui_util")
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.LobbyModel) then
    return
  end
  local Logic_SC_DownloadTools = require("client.slua.logic.lobby.Left.SocialLobby.Logic_SC_DownloadTools")
  if not Logic_SC_DownloadTools.GetSocialLobbyResIsDownloaded() then
    Logic_SC_DownloadTools.ShowSocialLobbyDownloadPopup(tonumber(DataMgr.roleData.uid))
    return
  end
  if self:SwitchToPage(ENUM_LobbyPageType.Left) then
    self:DelayClientSendBAReport(TLogEventDefine.LobbyMainClickSocialPage)
  end
end
function Lobby_Main_Switch_UIBP:OnButton_MidClick()
  log(bWriteLog and "Lobby_Main_Switch_UIBP:OnButton_MidClick")
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  if not growthprojectMgrB.CanSwitchUI() then
    return
  end
  local UIUtil = require("client.common.ui_util")
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.LobbyModel) then
    return
  end
  local lobbyMainLogic = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
  local curPage = lobbyMainLogic.curPage
  if curPage == ENUM_LobbyPageType.Mid then
    log(bWriteLog and "Lobby_Main_Switch_UIBP:OnButton_MidClick click Mid Button EnterMainCity")
    UIManager.CloseUI(UIManager.UI_Config.MainCity_Newbie_Slide_UIBP)
    local Main_City_Download_Tool = require("client.slua.logic.lobby.MainCity.Main_City_Download_Tool")
    local main_city_process_util = require("GameLua.Mod.MainCity.Client.logic.Process.main_city_process_util")
    if Main_City_Download_Tool.IsMainCityMapDownloaded(true) and main_city_process_util.IsMainCityEntryOpen(true) then
      UIManager.ShowUI(UIManager.UI_Config.ModeSelection_Opening_MainCity)
    end
    local logic_main_city_enter_report = require("GameLua.Mod.MainCity.Client.logic.logic_main_city_enter_report")
    logic_main_city_enter_report.SetReportData("NewEnterMainCity", "EnterMCFromLobby", "ClickLobbyBtnIntoMC")
    return
  end
  if self:SwitchToPage(ENUM_LobbyPageType.Mid) then
    self:DelayClientSendBAReport(TLogEventDefine.LobbyMainClickMainPage)
  end
end
function Lobby_Main_Switch_UIBP:OnButton_RightClick()
  log(bWriteLog and "Lobby_Main_Switch_UIBP:OnButton_RightClick")
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  if not growthprojectMgrB.CanSwitchUI() then
    return
  end
  local UIUtil = require("client.common.ui_util")
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.LobbyModel) then
    return
  end
  if LogicTxMissionMain.IsInXMission(false) then
    log(bWriteLog and "Lobby_Main_Switch_UIBP:OnButton_RightClick, IsInXMission")
    return
  end
  if self:SwitchToPage(ENUM_LobbyPageType.Right) then
    local eventId = TLogEventDefine.LobbyMainClickCommercialPage
    local logic_ugc_hall = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_hall)
    local logic_home_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_switch)
    if logic_home_switch.lobbyRightMode == ENUM_LobbyRightMode.UGCHall and logic_ugc_hall:CheckIsOpen() then
      eventId = TLogEventDefine.LobbyMain_Click_To_UGC_Hall
    end
    self:DelayClientSendBAReport(eventId)
  end
end
function Lobby_Main_Switch_UIBP:ShowBtnReport()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsCEVersion() then
    self.UIRoot.CanvasPanel_Report:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot.CanvasPanel_Report:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function Lobby_Main_Switch_UIBP:OnButton_ReportClick()
  self:PlayAudio(sound_config.click_v1)
  local LogicReportBug = require("client.logic.battle.logic_reportbug")
  LogicReportBug.ShowLobbyReportPanel()
end
function Lobby_Main_Switch_UIBP:UpdateMomentReddot()
  local logic_moment_background = require("client.slua.logic.moment.logic_moment_background")
  local localRedDotFileTb = logic_moment_background.GetLocalRedDotFileTb()
  if logic_moment_background.HasNew() and localRedDotFileTb[1] == nil then
    self:SetWidgetVisible(self.UIRoot.Border_Moment_New, true)
  else
    self:SetWidgetVisible(self.UIRoot.Border_Moment_New, false)
    local moment_reddot_data = require("client.slua.logic.moment.moment_reddot_data")
    local momentRedPoint = moment_reddot_data.GetData()
    if momentRedPoint then
      self:AddDataListener(momentRedPoint, "has_new", function(oldValue, value)
        local logic_moment = require("client.slua.logic.moment.logic_moment")
        if logic_moment.IsCanOpenSelfMoment(false) then
          self:SetWidgetVisible(self.UIRoot.Border_Moment_New, value)
        end
      end)
    end
  end
end
function Lobby_Main_Switch_UIBP:OnChangeConvienceSettingsRsp()
  self:UpdateRightModeImage()
end
function Lobby_Main_Switch_UIBP:OnWowHallRedPointChange()
  self:UpdateRightModeImage()
end
function Lobby_Main_Switch_UIBP:OnPlayedSlide(_, _, state)
  log(bWriteLog and "Lobby_Main_Switch_UIBP:OnPlayedSlide state = " .. tostring(state))
  if slua.isValid(self.UIRoot) and self.UIRoot.Border_0 then
    if state then
      self:SetWidgetVisible(self.UIRoot.Border_0, false)
    else
      self:SetWidgetVisible(self.UIRoot.Border_0, true)
    end
  end
end
function Lobby_Main_Switch_UIBP:OnResetTopPanel()
  if slua.isValid(self.UIRoot) and self.UIRoot.Border_0 then
    log(bWriteLog and "Lobby_Main_Switch_UIBP:OnResetTopPanel")
    self:SetWidgetVisible(self.UIRoot.Border_0, true)
  end
end
function Lobby_Main_Switch_UIBP:DelayClientSendBAReport(eventType)
  self:AddTimerOnce(2, function()
    ClientSendBAReport(eventType, 0)
  end)
end
function Lobby_Main_Switch_UIBP:UpdateRightModeImage()
  local logic_home_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_switch)
  if not logic_home_switch.isShowLobbyRightMode then
    return
  end
  local lobbyRightMode = logic_home_switch.lobbyRightMode
  self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(lobbyRightMode)
  self.UIRoot.WidgetSwitcher_1:SetActiveWidgetIndex(lobbyRightMode)
  self:UpdateXmissionDownloadUI()
  local bShowRedPoint = false
  local convience_mode_settings = DataMgr.roleData and DataMgr.roleData.convience_mode_settings
  bShowRedPoint = convience_mode_settings and convience_mode_settings.rightMode and convience_mode_settings.rightModeShowedRed == nil
  local bShowWowHallNew = false
  log(bWriteLog and "Lobby_Main_Switch_UIBP:UpdateRightModeImage. lobbyRightMode = " .. tostring(lobbyRightMode))
  local LogicUGCHall = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_hall)
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local bIsWowUnlocked = LogicUGC:IsWOWOpen() and LogicUGCHall:CheckIsOpen()
  if not bIsWowUnlocked then
    log(bWriteLog and "Lobby_Main_Switch_UIBP:UpdateRightModeImage. wow not unlocked")
    self:SetWidgetVisible(self.UIRoot.Image_RedPoint, false)
    if self.WowHallNewTipsUI then
      self.WowHallNewTipsUI:CloseSelf()
      self.WowHallNewTipsUI = nil
    end
    return
  end
  local bSetRightToWowMode = lobbyRightMode == ENUM_LobbyRightMode.UGCHall
  local Lobby_Main_Control = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
  local bIsCurrentInWowMode = Lobby_Main_Control.curPage == ENUM_LobbyPageType.Right and bSetRightToWowMode
  local bSetRightToXmission = lobbyRightMode == ENUM_LobbyRightMode.XMission
  local bIsCurrentInXmission = Lobby_Main_Control.curPage == ENUM_LobbyPageType.Right and bSetRightToXmission
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local WowHallVisitInfo = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCWOWHallVisitInfo)
  local bHaventVisitWowHall = not WowHallVisitInfo or WowHallVisitInfo.visitTime == nil
  if bSetRightToWowMode and bHaventVisitWowHall and not bIsCurrentInWowMode then
    bShowWowHallNew = true
    if not self.WowHallNewTipsUI then
      local Text = LocUtil.GetLocalizeResStr(78434)
      self.WowHallNewTipsUI = self:CreateChildWindow(self.UIRoot.Canvas_R, UIManager.UI_Config.Common_Tips_Buttom_UIBP, Text)
    end
  else
    log(bWriteLog and "Lobby_Main_Switch_UIBP:UpdateRightModeImage. not show wow new tips. bSetRightToWowMode = " .. tostring(bSetRightToWowMode) .. " bHaventVisitWowHall = " .. tostring(bHaventVisitWowHall))
    if self.WowHallNewTipsUI then
      self.WowHallNewTipsUI:CloseSelf()
      self.WowHallNewTipsUI = nil
    end
  end
  if bSetRightToXmission and not bIsCurrentInXmission then
    local enableUGCHall = LogicUGCHall:CheckIsOpen()
    local logic_xmission_entrance = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_entrance)
    local reqLevel = logic_xmission_entrance:GetXmissionReqLevel()
    local isLevelUnlocked = reqLevel <= DataMgr.roleData.level
    bShowRedPoint = enableUGCHall and isLevelUnlocked and convience_mode_settings and convience_mode_settings.rightMode and convience_mode_settings.UGCHallShowedRedDot == nil
    log(bWirteLog and "Lobby_Main_Switch_UIBP:UpdateRightModeImage. show red point for xmissionPlayer UGCHallShowRedDot = " .. tostring(bShowRedPoint))
    self:SetWidgetVisible(self.UIRoot.Image_RedPoint, bShowRedPoint)
    return
  end
  if not bSetRightToWowMode or bIsCurrentInWowMode then
    log(bWriteLog and "Lobby_Main_Switch_UIBP:UpdateRightModeImage. not wow red because setRightToWowMode = " .. tostring(bSetRightToWowMode) .. " bIsCurrentInWowMode = " .. tostring(bIsCurrentInWowMode))
    self:SetWidgetVisible(self.UIRoot.Image_RedPoint, false)
    return
  end
  local logic_ugc_hall = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_hall)
  bShowRedPoint = bShowRedPoint or logic_ugc_hall:ShouldShowReddot()
  bShowRedPoint = bShowRedPoint or bShowWowHallNew
  self:SetWidgetVisible(self.UIRoot.Image_RedPoint, bShowRedPoint)
end
function Lobby_Main_Switch_UIBP:GetDownloaderParams(callback, pageType)
  local Lobby_Main_Control = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
  local alpha = Lobby_Main_Control.curPage == pageType and 0.4 or 0.2
  local params = {
    size = 18,
    hideIconBg = true,
    showProgress = true,
    hideProgressText = true,
    callback = callback,
    progressMaskColor = FLinearColor(1, 1, 1, alpha),
    progressFillType = 0
  }
  return params
end
function Lobby_Main_Switch_UIBP:UpdateXmissionDownloadUI()
  local logic_home_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_switch)
  log(bWriteLog and "Lobby_Main_Switch_UIBP:UpdateXmissionDownloadUI. show = " .. tostring(logic_home_switch.isShowLobbyRightMode))
  log(bWriteLog and "Lobby_Main_Switch_UIBP:UpdateXmissionDownloadUI. lobbyRightMode = " .. tostring(logic_home_switch.lobbyRightMode))
  if not logic_home_switch.isShowLobbyRightMode then
    return
  end
  local lobbyRightMode = logic_home_switch.lobbyRightMode
  if lobbyRightMode == ENUM_LobbyRightMode.XMission then
    local LogicTxMissionDownload = require("client.slua.logic.TxMission.logic_xmission_download")
    local downloaded = LogicTxMissionDownload.CheckResHasDownloaded()
    log(bWriteLog and "Lobby_Main_Switch_UIBP:UpdateXmissionDownloadUI. map downloaded = " .. tostring(downloaded))
    if not downloaded then
      local common_download_handler = require("client.slua.common.common_download_handler")
      local callback = function()
        log(bWriteLog and "Lobby_Main_Switch_UIBP:UpdateXmissionDownloadUI. download complete")
        if slua.isValid(self.UIRoot) then
          self:CheckShowRightScreenNewbie()
        end
      end
      local params = self:GetDownloaderParams(callback, ENUM_LobbyPageType.Right)
      local PufferConst = require("client.slua.logic.download.puffer_const")
      common_download_handler.CreateDownloadUIReturnUIBase(PufferConst.ENUM_DownloadType.MAP, {
        LogicTxMissionDownload.MAP_KEY
      }, self, self.UIRoot.CanvasPanel_RDownload, params)
      local logic_xmission_entrance = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_entrance)
      local activityInfo = logic_xmission_entrance:GetTxMissionActivityInfo()
      self:SetWidgetVisible(self.UIRoot.CanvasPanel_RDownload, activityInfo ~= nil)
    else
      self:SetWidgetVisible(self.UIRoot.CanvasPanel_RDownload, false)
    end
  else
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_RDownload, false)
  end
end
function Lobby_Main_Switch_UIBP:CheckShowRightScreenNewbie()
  local logic_player_return = require("client.slua.logic.player_return.logic_player_return")
  local isReturn = logic_player_return.isPlayerReturnOpenNew()
  if isReturn then
    log(bWriteLog and "Lobby_Main_Switch_UIBP:CheckShowRightScreenNewbie. return user")
    return
  end
  if not self.IsShowRightMode then
    return
  end
  if LogicTxMissionMain.IsInXMission() then
    log(bWriteLog and "Lobby_Main_Switch_UIBP:CheckShowRightScreenNewbie. Is in xmission")
    return
  end
  local level_unlock_util = require("client.logic.level_unlock.util.level_unlock_util")
  local bHaveLockedFeature = level_unlock_util:HaveLockedFeature()
  if bHaveLockedFeature then
    log(bWriteLog and "Lobby_Main_Switch_UIBP:CheckShowRightScreenNewbie. lv not enough")
    return
  end
  local growthprojectMgr = require("client.slua.logic.growth_project.logic_growth_project_b")
  local isFinishNewGuide = growthprojectMgr.IsFinishAllNewGuide()
  if not isFinishNewGuide then
    log(bWriteLog and "Lobby_Main_Switch_UIBP:CheckShowNewbie. isFinishNewGuide = " .. tostring(isFinishNewGuide))
    return
  end
  local logic_home_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_switch)
  local lobbyRightMode = logic_home_switch.lobbyRightMode
  local lobbyMainLogic = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
  local curPage = lobbyMainLogic.curPage
  if curPage == ENUM_LobbyPageType.Mid then
    if UIManager.IsUIShow(UIManager.UI_Config.NewbieGuide_UIBP) then
      return
    end
    local key = 0
    local textID = 0
    local LogicTxMissionDownload = require("client.slua.logic.TxMission.logic_xmission_download")
    if lobbyRightMode == ENUM_LobbyRightMode.None then
      key = logic_home_switch.Enum_RightModeNewbieGuideKey.UnSet
      textID = 69663
    elseif lobbyRightMode == ENUM_LobbyRightMode.XMission and LogicTxMissionDownload.CheckResHasDownloaded() and lobbyMainLogic.nextPage == nil then
      key = logic_home_switch.Enum_RightModeNewbieGuideKey.FirstSetXmission
      textID = 69676
    end
    if key == 0 then
      return
    end
    local value = DataMgr.GetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_RIGHT_MODE, key) or 0
    if value == 0 then
      if #UIManager.GetTopUINameList(1) ~= 0 then
        self:AddTimerOnce(1, function()
          self:CheckShowRightScreenNewbie()
        end)
        return
      end
      local content = LocUtil.GetLocalizeResStr(textID)
      self:SetWidgetVisible(self.UIRoot.CanvasPanel_Newbie, true)
      self.UIRoot.UTRichTextBlock_0:SetText(content)
      logic_home_switch:SetRightModeNewbie(key, true)
    end
  end
end
function Lobby_Main_Switch_UIBP:HandleExitFromXmission()
  local Lobby_Main_Control = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
  log(bWriteLog and "Lobby_Main_Switch_UIBP:HandleExitFromXmission. ReturnFromTLobbyToPage" .. tostring(Lobby_Main_Control.ReturnFromTLobbyToPage))
  if Lobby_Main_Control.ReturnFromTLobbyToPage == nil then
    return
  end
  local toPage = Lobby_Main_Control.ReturnFromTLobbyToPage
  Lobby_Main_Control.ReturnFromTLobbyToPage = nil
  local fromPage
  if toPage == ENUM_LobbyPageType.Right then
    fromPage = ENUM_LobbyPageType.Mid
  else
    fromPage = toPage == ENUM_LobbyPageType.Mid and ENUM_LobbyPageType.Right or ENUM_LobbyPageType.Mid
  end
  self:SetCurrentPage(toPage)
  Lobby_Main_Control.curPage = fromPage
  self:AddTimerOnce(0.01, function()
    Lobby_Main_Control.curPage = fromPage
    Lobby_Main_Control.MoveToPage(toPage)
  end)
end
function Lobby_Main_Switch_UIBP:UpdateMainCityEntryShow()
  local icons = {
    [1] = "/Game/UMG/Texture_200/Atlas/Lobby/Frames/Lobby_Image_Tab_03_png.Lobby_Image_Tab_03_png",
    [2] = "/Game/UMG/Texture_200/Atlas/Lobby/Frames/Lobby_Image_Tab_07_png.Lobby_Image_Tab_07_png"
  }
  local main_city_process_util = require("GameLua.Mod.MainCity.Client.logic.Process.main_city_process_util")
  local isOpen = main_city_process_util.IsMainCityEntryOpen(nil, nil, true)
  self:SetWidgetVisible(self.UIRoot.VerticalBox_MainCity, isOpen)
  local iconPath = icons[isOpen and 2 or 1]
  if self.UIRoot.Image_MidTab then
    self:SetTexture(self.UIRoot.Image_MidTab, iconPath)
  end
  if self.UIRoot.Image_MidTab2 then
    self:SetTexture(self.UIRoot.Image_MidTab2, iconPath)
  end
  local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
  local isInMainCity = Lobby_Main_City_Enter.bInMainCity
  self.UIRoot.WidgetSwitcher_2:SetActiveWidgetIndex(isInMainCity and 0 or 1)
  self.UIRoot.WidgetSwitcher_3:SetActiveWidgetIndex(isInMainCity and 1 or 0)
  if self.UIRoot.ProgressBar_0 then
    self.UIRoot.ProgressBar_0:SetPercent(0)
    self:SetWidgetVisible(self.UIRoot.ProgressBar_0, false)
  end
  local Main_City_Download_Tool = require("client.slua.logic.lobby.MainCity.Main_City_Download_Tool")
  local isDownLoadMainCity = Main_City_Download_Tool.IsMainCityMapDownloaded()
  local needAddTimer = not isDownLoadMainCity and not self.mainCityDownloadTimer
  if needAddTimer then
    self.mainCityDownloadTimer = self:AddTimerLoop(1, function()
      self:UpdateMainCityDownloadProgress()
    end, TIMER_INFINITE, 1)
  end
end
function Lobby_Main_Switch_UIBP:UpdateMainCityDownloadProgress()
  local Main_City_Download_Tool = require("client.slua.logic.lobby.MainCity.Main_City_Download_Tool")
  local mapState = Main_City_Download_Tool.GetMainCityMapState()
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local ENUM_DownloadState = PufferConst.ENUM_DownloadState
  local mapDownloaded = mapState == ENUM_DownloadState.Done
  local pct = 0
  if mapDownloaded then
    if self.mainCityDownloadTimer then
      self:RemoveTimer(self.mainCityDownloadTimer)
      self.mainCityDownloadTimer = nil
    end
  else
    _, pct = Main_City_Download_Tool.GetMainCityMapSizeTextAndPct()
  end
  if self.UIRoot.ProgressBar_0 then
    self:SetWidgetVisible(self.UIRoot.ProgressBar_0, not mapDownloaded)
    self.UIRoot.ProgressBar_0:SetPercent(pct)
  end
  return mapDownloaded
end
function Lobby_Main_Switch_UIBP:UpdateWowUGCHallData()
  log(bWriteLog and "Lobby_Main_Switch_UIBP:UpdateWowUGCHallData")
  local LogicUGCHall = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_hall)
  local bIsWowUnlocked = LogicUGCHall and LogicUGCHall:CheckIsOpen()
  if not bIsWowUnlocked then
    return
  end
  LogicUGCHall:RequestUGCHallReddotData()
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CLobby_Main_Switch_UIBP = class(ui_base, nil, Lobby_Main_Switch_UIBP)
return CLobby_Main_Switch_UIBP