local Lobby_Main_UIBP = {showRightMode = false}
function Lobby_Main_UIBP:ctor()
  self._cObj_socialHallUI = nil
  self._tLobbyThemDownloadRes = nil
  self._tPlayerModelDownloadRes = nil
  self._tPlayerModelDownloadUIParams = nil
end
function Lobby_Main_UIBP:GetParentNames()
  local parentNameArr = {
    "Border_wifi",
    "Border_money",
    "Border_switch",
    "Border_Match_Entry",
    "Border_MidFriend",
    "Border_MidMessage",
    "Border_MidActivity",
    "Border_MidBanner",
    "Border_Downloader_Btn",
    "Border_TabRoot",
    "GridPanel_Chat",
    "Grid_Panel_Bottom_Right",
    "Border_MidExpression",
    "Border_WoWJoinTeam"
  }
  return parentNameArr
end
function Lobby_Main_UIBP:OnInitialize()
  Lobby_Main_UIBP.__super.OnInitialize(self)
  log(bWriteLog and "Lobby_Main_UIBP:OnInitialize.")
  self.util = require("client.slua_ui_framework.util")
  self.Lobby20_Control_Comp = self.UIRoot.Lobby20_Control_Comp
  local Lobby_Main_Control = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
  Lobby_Main_Control.curPage = ENUM_LobbyPageType.Mid
  local LobbyUIMacro = require("client.slua.umg.lobby.Main.Config.LobbyUIMacro")
  local uiTypeArr = LobbyUIMacro.lobbyUIArr
  local parentNameArr = self:GetParentNames()
  local UnknowPassUtil = require("client.slua.logic.unknow_pass.logic_unknowpass_util")
  local ResourseVersion = UnknowPassUtil.GetVersionNumber()
  Client.SetImageVersionString("1_3_0", ResourseVersion)
  self.childWindowMap = {}
  local utility = require("common.utility")
  for i = 1, #uiTypeArr do
    xpcall(function()
      self:AddChildUI(parentNameArr[i], uiTypeArr[i])
    end, utility.ErrorMessageHandler)
  end
  if IsWoWEditor then
    self.needAutoPlay = false
    return
  end
  local lobbyModuleArr = LobbyUIMacro.lobbyModulePreloadArr
  for i = 1, #lobbyModuleArr do
    xpcall(function()
      ModuleManager.GetModule(ModuleManager.LobbyModuleConfig[lobbyModuleArr[i]])
    end, utility.ErrorMessageHandler)
  end
  local LobbyEffect = require("client.logic.login.logic_LobbyEffect")
  LobbyEffect.UpdateEffectUI()
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  Lobby_camera_manager_module:LoadLightLevelByCameraID(10001)
  local Lobby_Main_City_Preload = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Preload")
  Lobby_Main_City_Preload.Preload()
end
function Lobby_Main_UIBP:RegistEvents()
  Lobby_Main_UIBP.__super.RegistEvents(self)
  local Lobby_Main_Control = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
  Lobby_Main_Control.Init()
  if IsWoWEditor then
    return
  end
  self:AddControlEventByControl(self.UIRoot.Lobby20_Control_Comp, "OnTouchEndedDispatcher", Lobby_Main_Control.OnScrollEnd)
  self:AddControlEventByControl(self.UIRoot.Lobby20_Control_Comp, "OnTouchStartedDispatcher", Lobby_Main_Control.OnTouchStartedEvent)
  self:AddControlEventByControl(self.UIRoot.Lobby20_Control_Comp, "OnLobbyEndedDispatcher", Lobby_Main_Control.OnLobbyEndedDispatcher)
  self:AddControlEventByControl(self.UIRoot.Anim_Offset_Blur_SocialToLobby, "OnAnimationFinished", Lobby_Main_Control.OnAniLeftMidEnd)
  self:AddControlEventByControl(self.UIRoot.Anim_Offset_Blur_LobbyToMode, "OnAnimationFinished", Lobby_Main_Control.OnAniMidRightEnd)
  self:AddControlEventByControl(self.UIRoot.Anim_Offset_UI_SocialToLobby, "OnAnimationFinished", function()
    EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_LOBBY_OFFSET_UI_SOCIAL_TO_LOBBY_ANIM_FINISH)
  end)
  self:AddControlEventByControl(self.UIRoot.Fadein, "OnAnimationFinished", function()
    log_format("Lobby_Main_UIBP:RegistEvents. OnAnimationFinished")
    self.PlayingAnimIn = false
    EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_LOBBY_FADE_IN_ANIM_FINISH)
  end)
  local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
  LobbySocialSystem.RegisterEvents()
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_LOBBY_SHOW_OR_HIDE_PANEL, self.ShowOrHideLobbyPanel, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY_SKIN, EVENTID_LOBBY_SKIN_CHANGE, self.UpdateLobbySkin, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_LOBBY_SOCIAL_PHOTO, self.UpdatePhoto, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_LOADING_FINISH, self.ShowAnimIn, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_NATIFICATION_RSP, self.ShowNatification, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_SWITCHTO_PAGE_START, self.OnSwitchToPageStartEvent, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_SWITCHTO_PAGE_END, self.OnSwitchToPageEndEvent, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_SET_SOCIAL_LOBBY_UI_SHOW_OR_CLOSE, self.OnSetSocialLobbyUIShowOrCloseEvent, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_UPDATE_LOBBY_THEME_RES_DOWNLOAD_UI, self.OnUpdateLobbyThemeResDownloadEvent, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_UPDATE_LOBBY_PLAYER_MODE_DOWNLOAD_UI, self.OnUpdateLobbyPlayerModelResDownloadUIEvent, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_CURRENT_PUT_ON_GUN, self.RefreshCharacterDownloadUIShow, self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_HALL_DEPOT_DATA_INIT, self.RefreshCharacterDownloadUIShow, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CREATE_TEAM, self.OnJoinTeamEvent, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_DESTROY_TEAM, self.OnLeaveTeamEvent, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_BE_KICKED_OUT, self.OnLeaveTeamEvent, self)
  self:AddCommonEvent(EVENTID_UI, BP_ENUM_UI_SHOW, self.OnOtherUIShow, self)
end
function Lobby_Main_UIBP:OnUnRegistEvents()
  local Lobby_Main_Control = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
  Lobby_Main_Control.Destroy()
  local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
  LobbySocialSystem.UnRegisterEvents()
end
function Lobby_Main_UIBP:UpdatePhoto(_, _, in_photo)
  if in_photo then
    self.UIRoot.Border1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    self.UIRoot.Border1:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
end
function Lobby_Main_UIBP:ShowAnimIn()
  log(bWriteLog and "[v_ywuyuan] Lobby_Main_UIBP:ShowAnimIn")
  self.PlayingAnimIn = true
  self:AddTimerOnce(0.1, function()
    log(bWriteLog and "[v_ywuyuan] Lobby_Main_UIBP:ShowAnimIn EEEE")
    if slua.isValid(self.UIRoot) then
      self.UIRoot:PlayAnimationTo(self.UIRoot.Fadein, 0, 1.4666666666666666, 1, 0, 1)
    end
  end)
end
function Lobby_Main_UIBP:ShowNatification()
  if self:GetChildUI(UIManager.UI_Config.Lobby_Main_Notice_UIBP) or UIManager.GetUI(UIManager.UI_Config.xmission_main) then
    return
  end
  local logic_notification_system = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_notification_system)
  local data = logic_notification_system:GetLastNotify()
  if not data then
    return
  end
  if self.noticTimer then
    self:RemoveTimer(self.noticTimer)
    self.noticTimer = nil
  end
  self.noticTimer = self:AddTimerOnce(data.next_time, function()
    self:AddChildUI("Border_notification", UIManager.UI_Config.Lobby_Main_Notice_UIBP, data)
    self:AddTimerOnce(data.timer, function()
      if self and slua.isValid(self.UIRoot) then
        self:CloseChildUI(UIManager.UI_Config.Lobby_Main_Notice_UIBP)
      end
    end)
  end)
end
function Lobby_Main_UIBP:OnOtherUIShow(_, _, cfg)
  local Lobby_Main_Control = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
  Lobby_Main_Control.CancelScroll()
end
function Lobby_Main_UIBP:OnPostInitialize()
  Lobby_Main_UIBP.__super.OnPostInitialize(self)
  local logic_lobby = require("client.slua.logic.lobby.logic_lobby_main")
  logic_lobby.isCurrentShow = true
  local StatManager = import("StatManager")
  log(bWriteLog and "[stat] report event 30")
  StatManager.GetInstance():ReportEventWithNoParam(30, true)
  local logic_user_ctrl = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_user_ctrl)
  logic_user_ctrl:ReportEventNewUserFirstInLobby()
  self:UpdateUI()
  self.UIRoot:PlayAnimationTo(self.UIRoot.Anim_Offset_Blur_SocialToLobby, 1, 1, 1, 0, 0)
  local lobbyMainLogic = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
  lobbyMainLogic.ShowPage(lobbyMainLogic.curPage, true)
  local LogicMatchCenterEntry = require("client.slua.logic.lobby.Mid.logic_lobby_mid_match_center_entry")
  self:AddTimerLoop(0, function()
    LogicMatchCenterEntry.CheckAndAddMatchCenterEntryUI()
  end, TIMER_INFINITE, 5)
  local audio_util = require("client.common.audio_util")
  audio_util.SetRTPCValue("Heartbeat", 0, 0)
  audio_util.SetRTPCValue("ContestMode", 0, 0)
  local logic_community = require("client.slua.logic.community.logic_community")
  logic_community.SendEnterGameLobby()
  if IsWoWEditor then
    return
  end
  local newbieGuideManager = require("client.logic.newbie_manager.newbie_guide_manager")
  local needUpdateRole = newbieGuideManager.NeedUpdateRole()
  print(bWriteLog and "Lobby_Main_UIBP:OnPostInitialize needUpdateRole = " .. tostring(needUpdateRole))
  if needUpdateRole then
    self:AddTimerOnce(0, function()
      newbieGuideManager.ShowCreateRole()
    end)
  else
    self:ShowGDPR()
  end
  local logic_ce = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ce)
  logic_ce:OpenH5CEBind()
  local main_city_process_util = require("GameLua.Mod.MainCity.Client.logic.Process.main_city_process_util")
  local IsPendingAutoEnterMainCity = main_city_process_util.CheckIsPendingAutoEnterMainCity()
  log(bWriteLog and "Lobby_Main_UIBP:OnPostInitialize IsPendingAutoEnterMainCity = " .. tostring(IsPendingAutoEnterMainCity))
  if IsPendingAutoEnterMainCity then
    log(bWriteLog and "Lobby_Main_UIBP:OnPostInitialize jump 1")
    if self.linkTimer then
      self:RemoveTimer(self.linkTimer)
      self.linkTimer = nil
    end
    self.linkTimer = self:AddTimerLoop(0, function()
      local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
      if GameStatus.IsInMainCity() and not Lobby_Main_City_Enter.bEnterMainCityLoading and not logic_ce:GetIsBinding() and UIManager.IsUIShow(UIManager.UI_Config.MainCity_Main_UIBP) then
        local AdjustSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.AdjustSystem)
        AdjustSystem:CheckAdjustJumpTo()
        local PushSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PushSystem)
        PushSystem:CheckNotificationJumpTo()
        AdjustSystem.HasCheckJump = true
        if not needUpdateRole then
          local SceneSwitchLatenQueueSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SceneSwitchLatenQueueSystem)
          SceneSwitchLatenQueueSystem:BeginLobbyQueue()
        end
        if self.linkTimer then
          self:RemoveTimer(self.linkTimer)
          self.linkTimer = nil
        end
      end
    end, TIMER_INFINITE, 0.3)
  else
    log(bWriteLog and "Lobby_Main_UIBP:OnPostInitialize jump 2")
    self:AddTimerOnce(3, function()
      if not logic_ce:GetIsBinding() then
        local AdjustSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.AdjustSystem)
        AdjustSystem:CheckAdjustJumpTo()
        local PushSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.PushSystem)
        PushSystem:CheckNotificationJumpTo()
        AdjustSystem.HasCheckJump = true
        if not needUpdateRole then
          local SceneSwitchLatenQueueSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SceneSwitchLatenQueueSystem)
          SceneSwitchLatenQueueSystem:BeginLobbyQueue()
        end
      end
    end)
  end
  local LogicFPSAutoAdjust = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicFPSAutoAdjust)
  LogicFPSAutoAdjust:Initialize()
  if self:GetChildUI(UIManager.UI_Config.Lobby_Main_Notice_UIBP) then
    self:CloseChildUI(UIManager.UI_Config.Lobby_Main_Notice_UIBP)
  end
  self:AddTimerOnce(8, function()
    if slua.isValid(self) and slua.isValid(self.UIRoot) then
      self:ShowNatification()
    end
  end)
  self:AddTimerOnce(2, function()
    local logic_history_combat = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_history_combat)
    logic_history_combat:CheckShowHunterVsHuntedPop()
    local logic_marketing_agreement = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_marketing_agreement)
    logic_marketing_agreement:OnEnterLobby(needUpdateRole)
    local logic_gamelet_interface_update_nonage = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_gamelet_interface_update_nonage)
    logic_gamelet_interface_update_nonage:OnEnterLobby(needUpdateRole)
  end)
end
function Lobby_Main_UIBP:OnShow()
  local Lobby_Main_Control = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
  if Lobby_Main_Control.GetCurPage() == ENUM_LobbyPageType.Left then
    if not self._cObj_socialHallUI then
      return
    end
    self._cObj_socialHallUI:ReCheckSceneShow()
  end
end
function Lobby_Main_UIBP:OnSwitchToPageStartEvent(_, _, nTargetPage)
  if nTargetPage == ENUM_LobbyPageType.Left then
    self:ShowSocialLobbyUI(false)
  end
end
function Lobby_Main_UIBP:OnSwitchToPageEndEvent(_, _, nFormPage, nTargetPage)
  if nFormPage == ENUM_LobbyPageType.Left then
    self:CloseSocialLobbyUI()
  end
end
function Lobby_Main_UIBP:OnSetSocialLobbyUIShowOrCloseEvent(_, _, bIsShow)
  local Lobby_Main_Control = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
  if bIsShow and Lobby_Main_Control.GetCurPage() == ENUM_LobbyPageType.Left then
    self:ShowSocialLobbyUI(true)
  else
    self:CloseSocialLobbyUI()
  end
end
function Lobby_Main_UIBP:OnUpdateLobbyThemeResDownloadEvent(_, _, tDownloadResList)
  local TableUtil = require("common.table_util")
  if TableUtil.IsSameTable(self._tLobbyThemDownloadRes, tDownloadResList) then
    return
  end
  self._tLobbyThemDownloadRes = tDownloadResList
  self:RefreshLobbyResDownloadUIShow()
end
function Lobby_Main_UIBP:OnUpdateLobbyPlayerModelResDownloadUIEvent(_, _, tDownloadResList)
  self._tPlayerModelDownloadRes = tDownloadResList
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.IsInTeam() then
    self:HidePlayerModelDownloadUI()
    return
  end
  self:RefreshPlayerModelDownloadUIShow()
end
function Lobby_Main_UIBP:OnJoinTeamEvent()
  self:HidePlayerModelDownloadUI()
end
function Lobby_Main_UIBP:OnLeaveTeamEvent()
  self:RefreshPlayerModelDownloadUIShow()
end
function Lobby_Main_UIBP:UpdateUI()
  self:RefreshCharacterDownloadUIShow()
end
function Lobby_Main_UIBP:RefreshCharacterDownloadUIShow()
  local RecommendHandler = require("client.slua.logic.download.recommend.logic_recommend_handler")
  RecommendHandler.DownloadEquipment()
end
function Lobby_Main_UIBP:GetChildUI(config)
  if config == nil then
    log(bWriteLog and "Lobby_Main_UIBP:GetChildUI config == nil !")
    return nil
  end
  return self.childWindowMap and self.childWindowMap[config.moduleName]
end
function Lobby_Main_UIBP:AddChildUI(parentName, config, ...)
  log(bWriteLog and "Lobby_Main_UIBP:AddChildUI parentName = " .. parentName)
  if config == nil then
    log(bWriteLog and "Lobby_Main_UIBP:AddChildUI config == nil !")
    return nil
  end
  if not self.childWindowMap then
    log(bWriteLog and "Lobby_Main_UIBP:AddChildUI childWindowMap is nil")
    return nil
  end
  local childUI = self.childWindowMap[config.moduleName]
  if childUI then
    return childUI
  end
  childUI = self:CreateChildWindow(parentName, config, ...)
  if not childUI then
    log(bWriteLog and "Lobby_Main_UIBP:AddChildUI. childUI is nil")
    return nil
  end
  self.childWindowMap[config.moduleName] = childUI
  return childUI
end
function Lobby_Main_UIBP:CloseChildUI(config)
  if config == nil or config.moduleName == nil then
    log(bWriteLog and "Lobby_Main_UIBP:CloseChildUI config == nil !")
    return
  end
  log(bWriteLog and "Lobby_Main_UIBP:CloseChildUI " .. config.moduleName)
  local childUI = self.childWindowMap and self.childWindowMap[config.moduleName]
  if childUI == nil then
    log(bWriteLog and "Lobby_Main_UIBP:CloseChildUI childUI == nil !")
    return
  end
  self.childWindowMap[config.moduleName] = nil
  local base_config_util = require("client.common.uibase.base_config_util")
  if base_config_util.IsSingleton(config) then
    UIManager.CloseUI(config)
  else
    childUI:Close()
  end
end
function Lobby_Main_UIBP:ShowOrHideLobbyPanel(_, _, isShow, parentName, config)
  log(bWriteLog and "Lobby_Main_UIBP:ShowOrHideLobbyPanel isShow = " .. tostring(isShow) .. ", parentName = " .. parentName .. ", config = " .. config.moduleName)
  if isShow then
    self:AddChildUI(parentName, config)
  else
    self:CloseChildUI(config)
  end
end
function Lobby_Main_UIBP:Close()
  self.childWindowMap = nil
  Lobby_Main_UIBP.__super.Close(self)
end
function Lobby_Main_UIBP:UpdateLobbySkin(eventType, eventID, skinId)
  local cfg = CDataTable.GetTableData("LobbySceneSkinTable", skinId)
  local LobbyThemeManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyThemeManager)
  local defaultSkin = LobbyThemeManager:GetDefaultLobbySkin()
  if not cfg then
    cfg = CDataTable.GetTableData("LobbySceneSkinTable", defaultSkin)
    if not cfg then
      return
    end
  end
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local state2 = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {
    cfg.hallMaskPic2
  })
  local left_mid_pic, train_pic
  if state2 ~= PufferConst.ENUM_DownloadState.Done then
    log(bWriteLog and "Lobby_Main_UIBP:UpdateLobbySkin state2 is not done")
    local default_pic = "/Game/UMG/UI_Effect/Textures/dating/t_mask_mohu_Graffiti.t_mask_mohu_Graffiti"
    self:SetTexture(self.UIRoot.Image_Left_Mid, default_pic)
    self:SetTexture(self.UIRoot.Image_Train, default_pic)
    left_mid_pic = cfg.MaskPic2
    train_pic = cfg.MaskPic3
  else
    left_mid_pic = cfg.hallMaskPic2
    train_pic = cfg.hallMaskPic3
  end
  if left_mid_pic and left_mid_pic ~= "" then
    self:SetTexture(self.UIRoot.Image_Left_Mid, left_mid_pic)
  end
  if train_pic and train_pic ~= "" then
    self:SetTexture(self.UIRoot.Image_Train, train_pic)
  end
  local pak_util = require("client.common.pak_util")
  local downloaded = pak_util.IsPufferDownloaded(cfg.hallMaskPic1)
  log_format("Lobby_Main_UIBP:UpdateLobbySkin. downloaded=%s", downloaded)
  self.curSkinPath = cfg.hallMaskPic1
  if not downloaded then
    PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {
      cfg.hallMaskPic1
    })
    self.curSkinPath = "/Game/UMG/Texture/Lobby_NoAtlas/Lobby_Match_SelectMap/ModeSelection_New/BG/ModeCustom_Image_BG.ModeCustom_Image_BG"
  end
  self:SetTexture(self.UIRoot.Image_1, self.curSkinPath)
  if skinId == defaultSkin or skinId == 10012 or skinId == 10027 or skinId == 10043 then
    self.UIRoot.Image_bg_mask:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot.Image_bg_mask:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function Lobby_Main_UIBP:ChangeRightModeBg()
  self:SetTexture(self.UIRoot.Image_1, "/Game/UMG/Texture/Lobby_NoAtlas/Lobby_Match_SelectMap/ModeSelection_New/BG/ModeCustom_Image_BG.ModeCustom_Image_BG")
end
function Lobby_Main_UIBP:RecoverLobbySkin()
  if self.curSkinPath == nil then
    return
  end
  self:SetTexture(self.UIRoot.Image_1, self.curSkinPath)
end
function Lobby_Main_UIBP:RemoveSpecialChildUI(uiTypeArr, paraneNameArr)
end
function Lobby_Main_UIBP:SetChildUIWidgetVisibility(uiConfig, widgetName, isVisible, isButton)
  if uiConfig == nil or widgetName == nil or isVisible == nil or isButton == nil then
    return
  end
  local childUI = self:GetChildUI(uiConfig)
  if childUI == nil or childUI.UIRoot[widgetName] == nil then
    return
  end
  childUI:SetWidgetVisible(childUI.UIRoot[widgetName], isVisible, isButton)
end
function Lobby_Main_UIBP:ShowGDPR()
  log(bWriteLog and "Lobby_Main_UIBP:ShowGDPR")
  local NewFaceSlapSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NewFaceSlapSystem)
  NewFaceSlapSystem:ReleaseBlockSlap()
  local GdprSystem = require("client.slua.logic.gdpr.logic_gdpr")
  GdprSystem.TryToShowEuGdpr()
end
function Lobby_Main_UIBP:ShowSocialLobbyUI(bIsShowTransitionAnim)
  if self._cObj_socialHallUI then
    return
  end
  local DeviceUtils = require("common.DeviceUtils")
  local nMemoryType = DeviceUtils.GetDeviceMemoryType()
  if nMemoryType >= DeviceUtils.ENum_MemorySize.GreaterThan3G then
    local HDmpveRemote = require("client.slua.logic.HDmpveRemote.HDmpveRemote")
    local iDisableShowSocialLobbyGC = HDmpveRemote.HDmpveRemoteConfigGetInt("DisableShowSocialLobbyGC", 0)
    if iDisableShowSocialLobbyGC == 0 then
      local gc_util = require("common.gc_util")
      gc_util.FullGC()
    end
  end
  local node_root = self.UIRoot
  local sUId = DataMgr.roleData.uid
  local Logic_SocialLobbyModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SocialLobbyModule)
  Logic_SocialLobbyModule:SetCurUId(sUId)
  self._cObj_socialHallUI = self:CreateChildWindow(node_root.Border_SocialHall, UIManager.UI_Config.Lobby_SocialLobby_UIBP, sUId, true, {bIsShowTransitionAnim = bIsShowTransitionAnim})
end
function Lobby_Main_UIBP:CloseSocialLobbyUI()
  if not self._cObj_socialHallUI then
    return
  end
  self._cObj_socialHallUI:CloseSelf()
  self._cObj_socialHallUI = nil
end
function Lobby_Main_UIBP:RefreshLobbyResDownloadUIShow()
  local uNode_root = self.UIRoot
  local tNeedDownloadRes = self._tLobbyThemDownloadRes
  if not tNeedDownloadRes or not next(tNeedDownloadRes) then
    self:HideLobbyThemeDownloadUI()
    return
  end
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local nDownloadState = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, tNeedDownloadRes)
  if nDownloadState == ENUM_DownloadState.Done then
    self:HideLobbyThemeDownloadUI()
    return
  end
  local Logic_LobbyModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_LobbyModule)
  Logic_LobbyModule:TriggerShowNotAutoDownloadTip()
  if not self._cObj_themeDownloadUI then
    self._cObj_themeDownloadUI = self:CreateChildWindow(uNode_root.CanvasPanel_ThemeDownloadUIParent, UIManager.UI_Config.Lobby_Main_ThemeDownloadUI_UIBP, tNeedDownloadRes)
  else
    self._cObj_themeDownloadUI:RefreshDownloadUI(tNeedDownloadRes)
  end
  self:SetWidgetVisible(uNode_root.CanvasPanel_ThemeDownloadUIParent, true, false)
end
function Lobby_Main_UIBP:HideLobbyThemeDownloadUI()
  local uNode_root = self.UIRoot
  if self._cObj_themeDownloadUI then
    self._cObj_themeDownloadUI:CloseSelf()
    self._cObj_themeDownloadUI = nil
  end
  self:SetWidgetVisible(uNode_root.CanvasPanel_ThemeDownloadUIParent, false, false)
end
function Lobby_Main_UIBP:RefreshPlayerModelDownloadUIShow()
  local uNode_root = self.UIRoot
  local tNeedDownloadRes = self._tPlayerModelDownloadRes
  if not tNeedDownloadRes or not next(tNeedDownloadRes) then
    self:HidePlayerModelDownloadUI()
    return
  end
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local nDownloadState = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, tNeedDownloadRes)
  if nDownloadState == ENUM_DownloadState.Done then
    self:HidePlayerModelDownloadUI()
    return
  end
  local Logic_LobbyModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_LobbyModule)
  Logic_LobbyModule:TriggerShowNotAutoDownloadTip()
  local tDownLoadParams = self._tPlayerModelDownloadUIParams
  if not tDownLoadParams then
    local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
    local Enum_DownloadDoubleConfirmScene = PufferTlog.Enum_DownloadDoubleConfirmScene
    tDownLoadParams = {
      size = 35,
      isInCenter = true,
      useNewAni = true,
      hideMask = true,
      showAlertSize = true,
      nResDownloadScene = Enum_DownloadDoubleConfirmScene.LobbyMainUI_SelfAvatar
    }
    self._tPlayerModelDownloadUIParams = tDownLoadParams
  end
  local common_download_handler = require("client.slua.common.common_download_handler")
  common_download_handler.CreateDownloadUIReturnUIBase(PufferConst.ENUM_DownloadType.ODPAK, tNeedDownloadRes, self, uNode_root.CanvasPanel_PlayerModelDownloadUI, tDownLoadParams)
end
function Lobby_Main_UIBP:HidePlayerModelDownloadUI()
  local uNode_root = self.UIRoot
  local common_download_handler = require("client.slua.common.common_download_handler")
  common_download_handler:CloseDownloadUI(self, uNode_root.CanvasPanel_PlayerModelDownloadUI)
end
function Lobby_Main_UIBP:PlayAnimationSimple(animName, forward)
  log_format("Lobby_Main_UIBP:PlayAnimationSimple. animName=%s, forward=%s", animName, forward)
  if not animName then
    return
  end
  local anim = self.UIRoot[animName]
  if not anim then
    return
  end
  local playMode = 0
  if not forward then
    playMode = 1
  end
  self:PlayUserWidgetAnimation(anim, 0, 1, playMode, 1)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CLobby_Main_UIBP = class(ui_base, nil, Lobby_Main_UIBP)
return CLobby_Main_UIBP