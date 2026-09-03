local UI_Wardrobe = {}
local ESlateVisibility = UEnums.ESlateVisibility
local Visible = ESlateVisibility.Visible
local Hidden = ESlateVisibility.Hidden
local Collapsed = ESlateVisibility.Collapsed
local HitTestInvisible = ESlateVisibility.HitTestInvisible
local SelfHitTestInvisible = ESlateVisibility.SelfHitTestInvisible
local ENUM_UIRESTRIC_ZONE_TYPE = {DEFAULT = 1, FASHION_BAG = 2}
local UIRESTRICMAP = {
  [ENUM_UIRESTRIC_ZONE_TYPE.DEFAULT] = {
    L = 0,
    R = 574,
    U = 0,
    D = 0
  },
  [ENUM_UIRESTRIC_ZONE_TYPE.FASHION_BAG] = {
    L = 560,
    R = 0,
    U = 0,
    D = 0
  }
}
local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
local WardrobeDataManger = require("client.slua.logic.wardrobe.wardrobe_data")
local ui_util = require("client.common.ui_util")
local NeedHideBlurMaskSubTab = {
  [wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_quicksign] = true,
  [wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_quickmessage] = true
}
function UI_Wardrobe:ctor(selfType, jumpPageId, jumpSubTabId, args, eWardrobeEditMode, isJumpBack)
  local logic_cost_collector = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cost_collector)
  logic_cost_collector:MarkIsolatedEventStart(logic_cost_collector.ISOLATED_EVENT_NAMES.OpenWardrobeUI)
  self.jumpPageId = jumpPageId or nil
  self.jumpSubTabId = jumpSubTabId or nil
  self.  self.eWardrobeEditMode = eWardrobeEditMode or wardrobe_macro.EWardrobeEditMode.None
  self.shareBagSubType = 1
  self.LeftCornerShown = true
  self.LeftCornerSuspendTime = 5
  self.Timer = nil
  self.AutoFoldEnabled = false
  self.currentPageId = jumpPageId
  self.currentSubTabId = jumpSubTabId
  local wardrobeLogic = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  if isJumpBack then
    self.    wardrobeLogic:EnterBeforShowUI()
  end
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  local preWingmanSkinIns = fashionbag_data:GetWingmanSkin()
  local preWingmanData = WardrobeDataManger:GetHallDepotItemDataByInsID(preWingmanSkinIns)
  self.preWingmanSkinID = preWingmanData and preWingmanData.resID or nil
  self.subTabMap = {}
  self:SwitchUIRestrictZone(ENUM_UIRESTRIC_ZONE_TYPE.DEFAULT)
  self.bCloseWithoutSubscribePopup = false
  self.bOpenAnimationFinish = false
  self.bShowSubscribeShareTips = false
  self.bOnPageClickArrive = false
  self.bEnterFashionSaveMode = false
  self.bWaitingJumpOut = false
  self.curDownloaderItemID = nil
  self.curDownloaderSubItemID = nil
end
function UI_Wardrobe:OnInitialize()
  UI_Wardrobe.__super.OnInitialize(self)
  self.Common_Tab_Vertical_LevelOne_Icon_UIBP = self:InitVerticalIconTab(self.UIRoot.Common_Tab_Vertical_LevelOne_Icon_UIBP, true)
  self.Common_Tab_Vertical_LevelOne_Icon_UIBP:AddOnTabRefreshCallback(self.OnRefreshTabItem, self)
  self.Common_Tab_Vertical_LevelOne_Icon_UIBP:AddOnTabClickedCallback(self.OnClickTabItem, self)
  local LobbyThemeManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyThemeManager)
  if self.eWardrobeEditMode ~= wardrobe_macro.EWardrobeEditMode.FashionBag then
    LobbyThemeManager:EndPreviewTheme()
  end
  local WardrobeGunLogic = require("client.slua.logic.wardrobe.logic_wardrobe_gun")
  WardrobeGunLogic:InitSpecialWeaponData()
  local logic_outfit_combination = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_outfit_combination)
  logic_outfit_combination:RequireOutfitCombinationsUseTimes()
  self:LoadSortPreference()
end
function UI_Wardrobe:RegistEvents()
  UI_Wardrobe.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SubTab_Clicked, self.OnSubTabClicked, self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_GOLD_CHANGE, self.OnUpdateGold, self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_DIAMOND_CHANGE, self.OnUpdateDiamond, self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_ETERNAL_DIAMOND_CHANGE, self.OnUpdateEternalDiamond, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_ACCEPT_INVITE, self.OnTeamupAcceptInvite, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SWITCH_USE_ROLEWEAR, self.OnFashionBagChange, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SHOW_BG, self.OnShowBG, self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_UPDATE_NEWBIE_STATUS, self.AutoFold, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_RESET_AUTO_FOLD, self.AutoFold, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_CreateDownloader, self.CreateDownloader, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SUBPAGE_OPEN, self.OnSubPageOpened, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_RESET_DEFAULT_RESTRICT_ZONE, self.ResetDefaultUIRestrictZone, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SUBSCRIBE_ENTRY_CHANGED, self.OnSubscribeEntryChanged, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SUBSCRIBE_CLEAR_TIPS, self.OnSubscribeEntryClicked, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SHARED_BAG_GUIDE_STATUS, self.OnSharedBagGuideStatusUpdate, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_REFRESH_PAGE, self.RefreshPage, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SHOW_ENTRY_ICON, self.OnShowEntryIcon, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SHOW_ENTRY_EXTRA, self.OnShowExtraButton, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_DECAL_EXCHANGE_ENTRY_CHANGED, self.OnDecalExchangeEntryChanged, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_DECAL_EXCHANGE_CLEAR_TIPS, self.OnDecalExchangeEntryClearTips, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_BREAK_INHERIT, self.OnBreakInherit, self)
  self:AddCommonEvent(EVENTTYPE_LOGIN, EVENTID_LOGIN_SUCCESS, self.OnLoginSuccess, self)
  self:AddOnClickedEventByControl(self.UIRoot.btn_close, self.OnCloseClicked, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_0, self.LeftCornerStateChange, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_JumpToTask, self.OnCloseGuide, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_FashionBag, self.OnButtonClicked_ShowFashionBag, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Placard, self.OnClickButton_Placard, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Inherit, self.OnClickInherit, self)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Revocation, true, false)
  self:AddOnClickedEventByControl(self.UIRoot.Button_undo, self.OnButtonClicked_Undo, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Save, self.OnButtonClicked_Save, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Preserve, self.OnButtonClicked_Preserve, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_BP, self.OnButtonClicked_BP, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Silver, self.OnButtonClicked_Silver, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_AG, self.OnButtonClicked_AG, self)
  self:AddControlEventByControl(self.UIRoot.DX_Close, "OnAnimationFinished", self.OnOpenAnimationFinished, self)
  self:AddOnCheckStateChangedEventByControl(self.UIRoot.CheckBox_ApplyAfterEdit, self.OnCheckBox_ApplyAfterEdit, self)
end
function UI_Wardrobe:OnBreakInherit()
  log(bWriteLog and "UI_Wardrobe:OnBreakInherit()")
  if self.eWardrobeEditMode == wardrobe_macro.EWardrobeEditMode.Inherit then
    self:CloseWardrobe()
  end
end
function UI_Wardrobe:OnLoginSuccess()
  log(bWriteLog and "UI_Wardrobe:OnLoginSuccess()")
  if self.eWardrobeEditMode == wardrobe_macro.EWardrobeEditMode.Inherit then
    self:CloseWardrobe()
  end
end
function UI_Wardrobe:OnPostInitialize()
  log(bWriteLog and "UI_Wardrobe:OnPostInitialize")
  UI_Wardrobe.__super.OnPostInitialize(self)
  self:InitEntryIcon()
  self:InitUI()
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_OPEN)
  if self.isJumpBack then
    self.hasInit = true
    self:OnPostJumpBack()
  end
  self.isJumpBack = nil
  local BlackFridayGunModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.BlackFridayGunModule)
  BlackFridayGunModule:ReqOptionalGunBoxData()
  local logic_wardrobe_tag_mgr = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_wardrobe_tag_mgr)
  logic_wardrobe_tag_mgr:GetCustomTagList()
  local FashionBagEditUtils = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.FashionBagEditUtils)
  local bApplyAfterEdit = FashionBagEditUtils:GetApplyAfterEditFlag()
  self.UIRoot.CheckBox_ApplyAfterEdit:SetCheckedState(bApplyAfterEdit and UEnums.ECheckBoxState.Checked or UEnums.ECheckBoxState.Unchecked)
  self.UIRoot.TextBlock_ApplyTips:SetText(LocUtil.GetLocalizeResStr(69122))
  local logic_cost_collector = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_cost_collector)
  logic_cost_collector:MarkIsolatedEventEnd(logic_cost_collector.ISOLATED_EVENT_NAMES.OpenWardrobeUI)
end
function UI_Wardrobe:InitUI()
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  WardrobeLogicManager:SwitchCameraInWardrobe()
  WardrobeLogicManager:SetSearchString("")
  WardrobeLogicManager:SetWardrobeEditMode(self.eWardrobeEditMode, self.shareBagSubType)
  self:SetWidgetVisible(self.UIRoot.ScaleBox_2, true)
  self:InitFashionBagSwitch()
  self:RefreshPageTab()
  self:UpdateLeftPanelByEditMode()
  local fashionbag_undo = require("client.slua.logic.wardrobe.fashionbag.fashionbag_undo")
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  fashionbag_undo.OnOpenBag(fashionbag_data:GetFashionBagUseIndex())
  print(bWriteLog and string.format(" UI_Wardrobe:InitUI self.eWardrobeEditMode:%s", tostring(self.eWardrobeEditMode)))
  self:ProcessSubTabDisplayByEditMode()
  if self.eWardrobeEditMode ~= wardrobe_macro.EWardrobeEditMode.None then
    if self.eWardrobeEditMode ~= wardrobe_macro.EWardrobeEditMode.FashionBag and self.eWardrobeEditMode ~= wardrobe_macro.EWardrobeEditMode.Inherit then
      self:SetWidgetVisible(self.UIRoot.vx_Border_Money, false)
    else
      self:SetWidgetVisible(self.UIRoot.vx_Border_Money, true)
    end
    self:SetWidgetVisible(self.UIRoot.ScaleBox_2, false)
    self:SetWidgetVisible(self.UIRoot.Button_0, false)
    self:SetWidgetVisible(self.UIRoot.Button_Placard, false, true)
  else
    self:SetWidgetVisible(self.UIRoot.vx_Border_Money, true)
    self:SetWidgetVisible(self.UIRoot.Button_0, true, true)
  end
  self:SetWidgetVisible(self.UIRoot.Button_Inherit, self:NeedShowInheritButton(), true)
  self:RefreshBagName()
end
function UI_Wardrobe:NeedShowInheritButton()
  if self.currentSubTabId == wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_quicksign or self.currentSubTabId == wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_quickmessage then
    return false
  end
  return self.eWardrobeEditMode == wardrobe_macro.EWardrobeEditMode.None and LobbySystem.roleData.has_inherit_data
end
function UI_Wardrobe:ReInitUI()
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  WardrobeLogicManager:SetWardrobeEditMode(self.eWardrobeEditMode, self.shareBagSubType)
  self:SwitchUIRestrictZone(ENUM_UIRESTRIC_ZONE_TYPE.DEFAULT)
  local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
  MallSystemWeaponModelHandler.RefreshWeaponLocation()
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SHARE_SKIN_MODE_REFRESH, self.eWardrobeEditMode, {
    shareBagSubType = self.shareBagSubType
  })
  local tipsMgr = require("client.slua.umg.Wardrobe.tips.item_tips_mgr")
  tipsMgr:Hide()
  print(bWriteLog and string.format(" UI_Wardrobe:ReInitUI self.eWardrobeEditMode:%s", tostring(self.eWardrobeEditMode)))
  self:RefreshPageTab()
  self:ProcessSubTabDisplayByEditMode()
  self:UpdateLeftPanelByEditMode()
  if self.eWardrobeEditMode ~= wardrobe_macro.EWardrobeEditMode.None then
    if self.eWardrobeEditMode ~= wardrobe_macro.EWardrobeEditMode.FashionBag then
      self:SetWidgetVisible(self.UIRoot.vx_Border_Money, false)
    else
      self:SetWidgetVisible(self.UIRoot.vx_Border_Money, true)
    end
    self:SetWidgetVisible(self.UIRoot.ScaleBox_2, false)
    self:SetWidgetVisible(self.UIRoot.Button_0, false)
  else
    self:SetWidgetVisible(self.UIRoot.vx_Border_Money, true)
    self:SetWidgetVisible(self.UIRoot.ScaleBox_2, true)
    self:SetWidgetVisible(self.UIRoot.Button_0, true, true)
  end
  self:RefreshBagName()
  self:SetWidgetVisible(self.UIRoot.Button_Inherit, self:NeedShowInheritButton(), true)
  self.jumpPageId = nil
  self.jumpSubTabId = nil
end
function UI_Wardrobe:Close()
  self.UIRoot.CanvasPanel_Slot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  if self.eWardrobeEditMode and not self.bWaitingJumpOut then
    local FashionBagEditUtils = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.FashionBagEditUtils)
    FashionBagEditUtils:AbortFashionBagModify()
  end
  logic_connection_waiting:Hide(0)
  self:DestroyTipsPanel()
  self:DestroyEntryIcon()
  self:DestroyPreviewPanel()
  self:DestroyFashionBag()
  local emoji_bubble_preview = require("client.slua.umg.Wardrobe.emoji_bubble_preview")
  emoji_bubble_preview:Destroy()
  LobbySceneManager.LoadStreamLevel(false, LobbySceneManager.LEVEL_NAME.MALL)
  local logic_lobby_garage_scene = require("client.maps.logic_lobby_garage_scene")
  logic_lobby_garage_scene.UnLoadVehicleScene()
  logic_lobby_garage_scene.UnLoadSuperCarVehicleScene()
  local GlideSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.GlideSystem)
  GlideSystem:ExitGlideScene()
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  ModelDisplayer.Destroy()
  self:SaveSortPreference()
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  if not HallThemeUtils.bIsWingManShowPermanently then
    local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
    local postWingmanSkinIns = fashionbag_data:GetWingmanSkin()
    local postWingmanData = WardrobeDataManger:GetHallDepotItemDataByInsID(postWingmanSkinIns)
    local postWingmanSkinID = postWingmanData and postWingmanData.resID or nil
    if postWingmanSkinID ~= nil and postWingmanSkinID ~= self.preWingmanSkinID then
      HallThemeUtils.PlayHallWingmanAnim(postWingmanSkinID)
    end
    self.preWingmanSkinIns = nil
  end
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  WardrobeLogicManager:SetWardrobeEditMode(wardrobe_macro.EWardrobeEditMode.None)
  UI_Wardrobe.__super.Close(self)
end
function UI_Wardrobe:EnterShareEditMode()
  self.eWardrobeEditMode = wardrobe_macro.EWardrobeEditMode.Intimacy
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  Lobby_camera_manager_module:SwitchCamera(10002, 0.3)
  self:ReInitUI()
  self.UIRoot.CanvasPanel_Slot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  WardrobeLogicManager:RecordCurrentFashion()
end
function UI_Wardrobe:EnterShareBagEditMode(shareItemsInfo, shareType)
  self.eWardrobeEditMode = wardrobe_macro.EWardrobeEditMode.ShareBag
  self.shareBagSubType = shareType
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  Lobby_camera_manager_module:SwitchCamera(10002, 0.3)
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  WardrobeLogicManager:SetSubscribeShareList(shareItemsInfo, shareType)
  self:ReInitUI()
  self.UIRoot.CanvasPanel_Slot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  WardrobeLogicManager:RecordCurrentFashion()
end
function UI_Wardrobe:EnterFashionBagEditMode(FashionBagIndex)
  if FashionBagIndex == 5 then
    FashionBagIndex = FashionBagIndex + 1
  end
  self.eWardrobeEditMode = wardrobe_macro.EWardrobeEditMode.FashionBag
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  Lobby_camera_manager_module:SwitchCamera(10002, 0.3)
  self.CurrentEdit  self:ReInitUI()
  self.UIRoot.CanvasPanel_Slot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  WardrobeLogicManager:RecordCurrentFashion()
  local FashionBagEditUtils = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.FashionBagEditUtils)
  FashionBagEditUtils:StartEditFashionBag(FashionBagIndex)
end
function UI_Wardrobe:OnAndroidBack()
  self:CloseWardrobe()
end
function UI_Wardrobe:OnShow()
  log(bWriteLog and "UI_Wardrobe:OnShow")
  self:PlayUserWidgetAnimation(self.UIRoot.Fadein, 0, 1, 0, 1)
  local logic_lobby = require("client.slua.logic.lobby.logic_lobby_main")
  logic_lobby.HideLobbyUI()
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.ForceSwitchTeamGroup(1)
  self:UpdateGold()
  self:UpdateDiamond()
  self:UpdateEternalDiamond()
  self:RefreshBagName()
  self:UpdateLeftPanelByEditMode()
  self:AutoFold()
  local reddot_manager = require("client.slua.logic.reddot.reddot_manager")
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  reddot_manager:OnSystemShow(self, reddot_macro.SystemName.Wardrobe)
  local logic_wardrobe_gun = require("client.slua.logic.wardrobe.logic_wardrobe_gun")
  logic_wardrobe_gun:InitGunIDByLoginGunID()
end
function UI_Wardrobe:OnHide()
  log(bWriteLog and "UI_Wardrobe:OnHide")
  if slua.isValid(self.UIRoot) then
    self:PlayUserWidgetAnimation(self.UIRoot.Fadeout, 0, 1, 0, 1)
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.RevertTeamGroup()
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  WardrobeLogicManager:ExitWardrobeScene()
  local logic_wardrobe_avatar = require("client.slua.logic.wardrobe.logic_wardrobe_avatar")
  logic_wardrobe_avatar:PutOffTimeOutWear()
  logic_wardrobe_avatar:ResetCurrentWearPreviewMapInited()
  self:RefreshAvatarByDisplaySetting()
  WardrobeLogicManager:SetCurrentPageId(-1)
  WardrobeLogicManager:SetCurrentTabId(wardrobe_macro.ENUM_WardrobeSubTabString.ENUM_WardrobeSubTabString_empty)
  self:SaveSortPreference()
  WardrobeLogicManager.isInShareSetup = false
end
function UI_Wardrobe:OnCloseClicked()
  self:PlayAudio(sound_config.close_v1)
  self:CloseWardrobe()
end
function UI_Wardrobe:CloseWardrobe()
  if self.eWardrobeEditMode == wardrobe_macro.EWardrobeEditMode.Intimacy then
    self:ShowFashionBag(false)
    return
  elseif self.eWardrobeEditMode == wardrobe_macro.EWardrobeEditMode.ShareBag and not self.bCloseWithoutSubscribePopup then
    self:ShowFashionBag(false)
    local logic_share_bag_team_util = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_share_bag_team_util)
    logic_share_bag_team_util:ResetMyAvatarWeapon()
    return
  elseif self.eWardrobeEditMode == wardrobe_macro.EWardrobeEditMode.FashionBag then
    local FashionBagEditUtils = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.FashionBagEditUtils)
    if FashionBagEditUtils:HasModified() then
      local Title = LocUtil.LocalizeResFormat(5077)
      local Content = LocUtil.GetLocalizeResStr(69125)
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.Show(2, Title, Content, function()
        FashionBagEditUtils:AbortFashionBagModify()
        self:ShowFashionBag(false)
      end, function()
      end)
    else
      FashionBagEditUtils:AbortFashionBagModify()
      self:ShowFashionBag(false)
    end
    return
  end
  local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local logic_wardrobe_gun = require("client.slua.logic.wardrobe.logic_wardrobe_gun")
  local AvatarCaptureSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_avatar_capture_system)
  local mergedPoseIds = AvatarCaptureSystem:GetRoleInfoPoseIds()
  if LobbySystem.CheckOpen(BP_ENUM_LOBBY_AVATAR_CAPTURE_SWITCH) then
    if logic_wardrobe.bFirstEnter or logic_wardrobe.bTriggerPutOn or logic_wardrobe_gun.bTriggerPutOn or logic_wardrobe.bTriggerSuitDye then
      logic_wardrobe:SetFristEnter(false)
      logic_wardrobe:SetTriggerPutOn(false)
      logic_wardrobe:SetTriggerSuitDye(false)
      logic_wardrobe_gun:SetTriggerPutOn(false)
      mergedPoseIds = AvatarCaptureSystem:MergePoseIds(mergedPoseIds, AvatarCaptureSystem:GetBasePoseIds())
    end
  else
    local Avatar = wardrobe_macro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Avatar
    local Weapon = wardrobe_macro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Weapon
    local pageId = logic_wardrobe.GetCurrentPageId()
    if pageId == Avatar or pageId == Weapon then
      local weapon_time = logic_wardrobe_gun.recordTime or 0
      local avatar_time = logic_wardrobe.recordTime or 0
      local wear_time = weapon_time > avatar_time and weapon_time or avatar_time
      local TimeUtil = require("client.common.time_util")
      local curr_time = TimeUtil.GetServerTimeInSec()
      log(bWriteLog and "weapon_time = " .. tostring(weapon_time) .. " avatar_time = " .. tostring(avatar_time))
      log(bWriteLog and "wear_time = " .. tostring(wear_time) .. " curr_time = " .. tostring(curr_time))
      if 0 < curr_time - wear_time then
        local avatar_capture = require("client.logic.share.logic_avatar_capture")
        avatar_capture.CaptureAvatar()
        avatar_capture.bufferTexture = nil
      end
    end
  end
  if mergedPoseIds and 0 < #mergedPoseIds then
    AvatarCaptureSystem:CaptureAvatarWithHandsomePose(mergedPoseIds)
  end
  local logic_outfit_combination = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_outfit_combination)
  if logic_outfit_combination:IsPopDailyRandomTips() then
    logic_outfit_combination:PopDailyRandomTips()
    return
  end
  UIManager.CloseUI(UIManager.UI_Config.wardrobe)
end
function UI_Wardrobe:OnCloseGuide()
  if self.tipHandUI then
    self.tipHandUI:Close()
    self.tipHandUI = nil
  end
  self.UIRoot.Canvas_NewbieGuide:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self:OnCloseClicked()
  EventSystem:postEvent(EVENTTYPE_ACTION, EVENTID_GROWTH_PROJECT_DEPOT_GUIDE_DONE)
end
function UI_Wardrobe:RefreshPage(_, __, bKeepSubTab)
  local config = require("client.slua.umg.Wardrobe.wardrobe_config")
  local PageTabIns = config:GetTabPageConfig(self.currentPageId)
  self.jumpPageId = self.currentPageId
  if bKeepSubTab then
    self.jumpSubTabId = self.currentSubTabId
  end
  self.bOnPageClickArrive = false
  self:OnPageTabClicked(PageTabIns)
end
function UI_Wardrobe:OnPageTabClicked(pageTabConfig)
  log(bWriteLog and "UI_Wardrobe:OnPageTabClicked")
  self:SetWidgetVisible(self.UIRoot.Image_18, true)
  self:HideTipsPanel()
  self:DestroyPreviewPanel()
  local emoji_bubble_preview = require("client.slua.umg.Wardrobe.emoji_bubble_preview")
  emoji_bubble_preview:Destroy()
  self.currentPageId = pageTabConfig.pageId
  self:CreateDownloader(nil, nil, 0)
  if pageTabConfig.onPageClick ~= nil then
    self:AttachChildBP(pageTabConfig.onPageClick.onClickModuleName, pageTabConfig.onPageClick.onClickBP, pageTabConfig.onPageClick.onClickAttachPoint, pageTabConfig.uiStat_name)
    self.UIRoot.Tab_Level2:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self:HandlerFashionBagIconVisibility()
  else
    self.UIRoot.Tab_Level2:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    local config = require("client.slua.umg.Wardrobe.wardrobe_config")
    local subTabList = config:GetSubTabListByPageId(pageTabConfig.pageId)
    for i, v in pairs(self.subTabMap) do
      v:Close()
    end
    self.subTabMap = {}
    local WardrobeUtils = require("client.slua.logic.wardrobe.wardrobe_utils")
    for _, v in ipairs(subTabList) do
      if WardrobeUtils.CanInitSubTab(v) then
        local subtab = self:InitSubTab(v)
        self.subTabMap[v.subTabId] = subtab
      end
    end
    self:ProcessSubTabDisplayByEditMode()
    self.UIRoot.ScrollBox_SubTab:SetScrollOffset(0)
  end
  self:ClearJumpChainIfNeed()
  local entryIconMgr = require("client.slua.umg.Wardrobe.entry.entry_icon_mgr")
  entryIconMgr:OnWardrobePageChanged(self.currentPageId)
  if not self.bOnPageClickArrive then
    self.jumpPageId = nil
    self.jumpSubTabId = nil
    self.bOnPageClickArrive = true
  end
end
function UI_Wardrobe:InitSubTab(subTabConfig)
  local SubTabIns = self:CreateChildWindowWithLuaAndBpPath("ScrollBox_SubTab", UIManager.UI_Config.ChildUIWithoutLuaAndBpPath, subTabConfig.moduleName, subTabConfig.bpPath, subTabConfig, self.jumpSubTabId)
  return SubTabIns
end
function UI_Wardrobe:OnSubTabClicked(eventType, eventID, subTabConfig)
  self:HideTipsPanel()
  self:DestroyPreviewPanel()
  local emoji_bubble_preview = require("client.slua.umg.Wardrobe.emoji_bubble_preview")
  emoji_bubble_preview:Destroy()
  if subTabConfig.OnClick ~= nil then
    self:AttachChildBP(subTabConfig.OnClick.moduleName, subTabConfig.OnClick.bpPath, subTabConfig.OnClick.attachPoint, subTabConfig.uiStat_name, subTabConfig)
    self:HandlerFashionBagIconVisibility()
  end
  self.currentSubTabId = subTabConfig.subTabId
  self:ClearJumpChainIfNeed()
  local entryIconMgr = require("client.slua.umg.Wardrobe.entry.entry_icon_mgr")
  entryIconMgr:OnWardrobeSubPageChanged(self.currentPageId, self.currentSubTabId)
  if NeedHideBlurMaskSubTab[self.currentSubTabId] then
    self:SetWidgetVisible(self.UIRoot.Image_18, false)
  else
    self:SetWidgetVisible(self.UIRoot.Image_18, true)
  end
  self:SetWidgetVisible(self.UIRoot.Button_Inherit, self:NeedShowInheritButton(), true)
end
function UI_Wardrobe:AttachChildBP(moduleName, bpPath, parentName, uiStat_name, config)
  if moduleName == nil or bpPath == nil or parentName == nil then
    return
  end
  local BusinessHelper = import("BusinessHelper")
  if uiStat_name ~= nil then
    BusinessHelper.StartUIStat(uiStat_name)
  end
  if self.curIns ~= nil then
    self.curIns:Close()
    self.curIns = nil
  end
  log_tree("[  AttachChildBP== " .. moduleName, self.args)
  local Class = require(moduleName)
  local Ins = Class(config, self.args, self.isJumpBack)
  self.cur  Ins:Init(bpPath, UIContainers.None, EFixedZOrder.Default, nil, true)
  local statUIInfo
  if uiStat_name ~= nil then
    statUIInfo = {
      bStatUI = true,
      uiStatName = uiStat_name,
      path = bpPath,
      time = slua.getMiliseconds()
    }
  end
  Ins:PostShowUI(UEnums.ESlateVisibility.SelfHitTestInvisible, statUIInfo)
  self:AttachChildWindowByControl(self.UIRoot[parentName], Ins)
  Ins:SetAnchors(0, 0, 1, 1)
  Ins:SetOffsets(0, 0, 0, 0)
  Ins:SetAutoSize(true)
end
function UI_Wardrobe:InitFashionBagSwitch()
  self:PlayUserWidgetAnimation(self.UIRoot.DX_Close, 0, 1, 1, 1)
  self:PlayUserWidgetAnimation(self.UIRoot.DX_Open, 0, 1, 0, 1)
end
function UI_Wardrobe:OnUpdateGold()
  self:UpdateGold()
end
function UI_Wardrobe:UpdateGold()
  local goldText = FuncUtil.Conv_Int64ToText(DataMgr.gold)
  self.UIRoot.TextBlock_Gold:SetText(goldText)
end
function UI_Wardrobe:OnUpdateDiamond()
  self:UpdateDiamond()
end
function UI_Wardrobe:UpdateDiamond()
  local diamondText = FuncUtil.Conv_Int64ToText(DataMgr.diamond or 0)
  self.UIRoot.TextBlock_Diamond:SetText(diamondText or "")
end
function UI_Wardrobe:OnUpdateEternalDiamond()
  self:UpdateEternalDiamond()
end
function UI_Wardrobe:UpdateEternalDiamond()
  local StoreUtils = require("client.slua.logic.store.utils.store_utils")
  if StoreUtils.CanShowDiamond() then
    self.UIRoot.HorizontalBox_0:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    local diamondText = FuncUtil.Conv_Int64ToText(DataMgr.eternal_diamond)
    self.UIRoot.TextBlock_0:SetText(diamondText)
  else
    self.UIRoot.HorizontalBox_0:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function UI_Wardrobe:OnTeamupAcceptInvite()
  UIManager.CloseUI(UIManager.UI_Config.wardrobe)
end
function UI_Wardrobe:OnFashionBagChange(_, __, CurrentIndex)
  self:RefreshBagName(CurrentIndex)
end
function UI_Wardrobe:InitEntryIcon()
  local entryIconMgr = require("client.slua.umg.Wardrobe.entry.entry_icon_mgr")
  entryIconMgr:Init(self.currentPageId)
end
function UI_Wardrobe:DestroyEntryIcon()
  local entryIconMgr = require("client.slua.umg.Wardrobe.entry.entry_icon_mgr")
  entryIconMgr:Destroy()
end
function UI_Wardrobe:HideTipsPanel()
  local itemTipsMgr = require("client.slua.umg.Wardrobe.tips.item_tips_mgr")
  itemTipsMgr:Hide()
end
function UI_Wardrobe:DestroyTipsPanel()
  local itemTipsMgr = require("client.slua.umg.Wardrobe.tips.item_tips_mgr")
  itemTipsMgr:Destroy()
end
function UI_Wardrobe:RefreshAvatarByDisplaySetting()
  local display_setting = require("client.slua.logic.wardrobe.logic_display_setting")
  display_setting.RefreshAvatar()
end
function UI_Wardrobe:DestroyPreviewPanel()
  local itemTipsMgr = require("client.slua.umg.Paint.item_preview")
  itemTipsMgr:Destroy()
end
function UI_Wardrobe:DestroyFashionBag()
  UIManager.CloseUI(UIManager.UI_Config.fashion_bag_overview)
end
function UI_Wardrobe:OnShowBG(eventType, eventID, show)
  self:SetWidgetVisible(self.UIRoot.Image_d, show)
  self:SetWidgetVisible(self.UIRoot.Image_L, show)
end
function UI_Wardrobe:LoadSortPreference()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local TempTable = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eWardrobeSortPreference)
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  if TempTable and TempTable.version then
    WardrobeLogicManager.SortConfig = TempTable
  end
  WardrobeLogicManager.SortConfig.version = Client.GetAppVersion()
end
function UI_Wardrobe:SaveSortPreference()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  PlayerPrefsSystem.SaveTableToFile_N(WardrobeLogicManager.SortConfig, PlayerPrefsSystem.ePlayerPrefsType.eWardrobeSortPreference)
end
function UI_Wardrobe:LeftCornerStateChange()
  local logic_mvp_action = require("client.slua.logic.teamup.logic_mvp_action")
  logic_mvp_action:MarkTeamPositionTipsShowed()
  if self.LeftCornerShown then
    self:LeftCornerHide()
  else
    self:LeftCornerShow()
  end
end
function UI_Wardrobe:LeftCornerShow()
  self:PlayAudio(sound_config.popup_v1)
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_LEFT_CORNER_CLICK, true)
  self.LeftCornerShown = true
  self:PlayUserWidgetAnimation(self.UIRoot.DX_Close, 0, 1, 1, 1)
  self:PlayUserWidgetAnimation(self.UIRoot.DX_Open, 0, 1, 0, 1)
  self:AutoFold()
end
function UI_Wardrobe:LeftCornerHide()
  self:PlayAudio(sound_config.popup_v1)
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_LEFT_CORNER_CLICK, false)
  self.LeftCornerShown = false
  self:PlayUserWidgetAnimation(self.UIRoot.DX_Receive, 0, 1, 0, 1)
  self:PlayUserWidgetAnimation(self.UIRoot.DX_Close, 0, 1, 0, 1)
end
function UI_Wardrobe:AutoFold()
  if self.Timer then
    self:RemoveTimer(self.Timer)
  end
  self.Timer = self:AddTimerOnce(self.LeftCornerSuspendTime, function()
    if self.LeftCornerShown then
      self:LeftCornerHide()
    end
  end)
end
function UI_Wardrobe:CreateDownloader(_, _, itemID, itemSubID, callback)
  log_format("UI_Wardrobe:CreateDownloader. itemID=%s, itemSubID=%s, callback=%s", itemID, itemSubID, callback)
  if itemID == nil and itemSubID ~= nil then
    itemID = self.curDownloaderItemID
  end
  if self.curDownloaderItemID == itemID and self.curDownloaderSubItemID == itemSubID then
    log_format("UI_Wardrobe:CreateDownloader. same itemID")
    return
  end
  log_format("UI_Wardrobe:CreateDownloader. create new downloader")
  self.curDownloaderItemID = itemID
  self.curDownloaderSubItemID = itemSubID
  local common_download_handler = require("client.slua.common.common_download_handler")
  local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
  local itemList = {itemID, itemSubID}
  local params = {
    showGray = true,
    hideMask = true,
    showSize = true,
    pos = FVector2D(64, -40),
    callback = callback,
    clickCallback = function()
      log_format("UI_Wardrobe:CreateDownloader. click callback")
      local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
      local PufferConst = require("client.slua.logic.download.puffer_const")
      local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, itemList)
      local curSize, totalSize = PufferManager.GetSize(PufferConst.ENUM_DownloadType.ODPAK, itemList)
      if state ~= PufferConst.ENUM_DownloadState.Download then
        PufferTlog.SendTLog(PufferTlog.Enum_TLog_From.Wardrobe, PufferTlog.Enum_TLog_Optype.UIOperate, "Skin_Download_Click_UI", totalSize)
      end
    end,
    size = 60,
    from = PufferTlog.Enum_TLog_From.Wardrobe,
    showAlertSize = true
  }
  local PufferConst = require("client.slua.logic.download.puffer_const")
  common_download_handler.CreateDownloadUIReturnUIBase(PufferConst.ENUM_DownloadType.ODPAK, itemList, self, self.UIRoot.CanvasPanel_Download, params)
end
function UI_Wardrobe:OnButtonClicked_Undo()
  self:PlayAudio(sound_config.click)
  local UIUtil = require("client.common.ui_util")
  if UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.WardrobeUndo) == false then
    return
  end
  local fashionbag_undo = require("client.slua.logic.wardrobe.fashionbag.fashionbag_undo")
  local fashionbag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  fashionbag_undo.Undo(fashionbag_data:GetFashionBagUseIndex())
  local tipsMgr = require("client.slua.umg.Wardrobe.tips.item_tips_mgr")
  tipsMgr:Hide()
end
function UI_Wardrobe:OnButtonClicked_Save()
  self:PlayAudio(sound_config.click)
  self:ShowFashionBag(true)
end
function UI_Wardrobe:OnButtonClicked_Preserve()
  self:PlayAudio(sound_config.click_v1)
  local FashionBagEditUtils = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.FashionBagEditUtils)
  FashionBagEditUtils:ClearFahsionBagGuide(FashionBagEditUtils.ENUM_FashionBagGuideType.SaveToPlan)
  FashionBagEditUtils:ApplySaveFashionBagData()
  self:ShowFashionBag(false)
end
function UI_Wardrobe:OnButtonClicked_BP()
  self:PlayAudio(sound_config.click_v1)
  local strContent = LocUtil.LocalizeResFormat("6613")
  self:ShowFloatTips(self.UIRoot.Button_BP, strContent, 20, 95)
end
function UI_Wardrobe:OnButtonClicked_Silver()
  self:PlayAudio(sound_config.click_v1)
  local strContent = LocUtil.LocalizeResFormat("6615")
  self:ShowFloatTips(self.UIRoot.Button_Silver, strContent, 20, 95)
end
function UI_Wardrobe:OnButtonClicked_AG()
  self:PlayAudio(sound_config.click_v1)
  local strContent = LocUtil.LocalizeResFormat("9885")
  self:ShowFloatTips(self.UIRoot.Button_AG, strContent, 20, 95)
end
function UI_Wardrobe:ShowFloatTips(widget, tips, extraOffsetX, extraOffsetY)
  if not tips or tips == "" then
    return
  end
  local tipsUI = UIManager.ShowUI(UIManager.UI_Config.common_float_tips)
  local TipsParam = {
    offsetX = extraOffsetX or 20,
    offsetY = extraOffsetY or 100,
    wrapWidthType = 2
  }
  tipsUI:SetTips(widget, tips, TipsParam)
end
function UI_Wardrobe:HandlerFashionBagIconVisibility()
  self:AddTimerOnce(0, function()
    local vis_Canvas_FashionButtons = UEnums.ESlateVisibility.SelfHitTestInvisible
    local vis_Button_0 = UEnums.ESlateVisibility.Visible
    local vis_Button_Placard = UEnums.ESlateVisibility.Collapsed
    local vis_WidgetSwitcher_LeftButton = UEnums.ESlateVisibility.SelfHitTestInvisible
    local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
    local PageId = logic_wardrobe.GetCurrentPageId()
    local subPageId = logic_wardrobe.GetCurrentTabId()
    if PageId and PageId == wardrobe_macro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Vehicle then
      vis_Canvas_FashionButtons = UEnums.ESlateVisibility.Collapsed
      vis_Button_0 = UEnums.ESlateVisibility.Collapsed
    end
    if PageId and PageId == wardrobe_macro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Tool then
      vis_Canvas_FashionButtons = UEnums.ESlateVisibility.Collapsed
      vis_Button_0 = UEnums.ESlateVisibility.Collapsed
    end
    if PageId and PageId == wardrobe_macro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Parachute then
      local tmp = logic_wardrobe.GetCurrentTabId()
      local macroTabString = wardrobe_macro.ENUM_WardrobeSubTabString
      if tmp == macroTabString.ENUM_WardrobeSubTabString_emoji_bubble or tmp == macroTabString.ENUM_WardrobeSubTabString_plating or tmp == macroTabString.ENUM_WardrobeSubTabString_quicksign or tmp == macroTabString.ENUM_WardrobeSubTabString_quickmessage or tmp == macroTabString.ENUM_WardrobeSubTabString_holography or tmp == macroTabString.Enum_WardrobeSubTabString_SpecialVehicle or tmp == macroTabString.ENUM_WardrobeSubTabString_MiniTVSuit or tmp == macroTabString.ENUM_WardrobeSubTabString_character_MVP_MOTION then
        vis_Canvas_FashionButtons = UEnums.ESlateVisibility.Collapsed
        if tmp == macroTabString.ENUM_WardrobeSubTabString_quicksign or tmp == macroTabString.ENUM_WardrobeSubTabString_quickmessage or tmp == macroTabString.Enum_WardrobeSubTabString_SpecialVehicle then
          vis_Button_0 = UEnums.ESlateVisibility.Collapsed
        end
      end
      if tmp == macroTabString.ENUM_WardrobeSubTabString_plane then
        vis_Button_0 = UEnums.ESlateVisibility.Collapsed
      end
    end
    if PageId and PageId == wardrobe_macro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Appearance then
      vis_Canvas_FashionButtons = UEnums.ESlateVisibility.Collapsed
    end
    if self.eWardrobeEditMode == wardrobe_macro.EWardrobeEditMode.ShareBag then
      vis_Canvas_FashionButtons = UEnums.ESlateVisibility.Collapsed
    end
    if self.eWardrobeEditMode ~= wardrobe_macro.EWardrobeEditMode.None then
      vis_Button_0 = UEnums.ESlateVisibility.Collapsed
    end
    if PageId == wardrobe_macro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Parachute and subPageId == wardrobe_macro.ENUM_WardrobeSubTabString.Enum_WardrobeSubTabString_ShowBrand then
      vis_Button_Placard = UEnums.ESlateVisibility.Collapsed
      vis_Button_0 = UEnums.ESlateVisibility.Collapsed
      vis_Canvas_FashionButtons = UEnums.ESlateVisibility.Collapsed
      vis_WidgetSwitcher_LeftButton = UEnums.ESlateVisibility.Collapsed
    end
    printf("wardrobe_main:HandlerFashionBagIconVisibility vis_Canvas_FashionButtons:%s", vis_Canvas_FashionButtons)
    self.UIRoot.Canvas_FashionButtons:SetWidgetVisibility(vis_Canvas_FashionButtons)
    self.UIRoot.Button_0:SetWidgetVisibility(vis_Button_0)
    self.UIRoot.Button_Placard:SetWidgetVisibility(vis_Button_Placard)
    self.UIRoot.WidgetSwitcher_LeftButton:SetWidgetVisibility(vis_WidgetSwitcher_LeftButton)
  end)
end
function UI_Wardrobe:OnClickButton_Placard()
  self:PlayAudio(sound_config.click_v1)
  local subUI = self.curIns
  subUI:OnClickButton_Placard()
end
function UI_Wardrobe:OnClickInherit()
  self:PlayAudio(sound_config.click_v1)
  local LogicInheritSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicInheritSystem)
  LogicInheritSystem:EnterInheritWardrobe()
end
function UI_Wardrobe:OnButtonClicked_ShowFashionBag()
  self:PlayAudio(sound_config.click_v1)
  if self.eWardrobeEditMode == wardrobe_macro.EWardrobeEditMode.Inherit then
    ShowNotice(32104)
    return
  end
  self:ShowFashionBag(false)
end
function UI_Wardrobe:ShowFashionBag(bSaveMode)
  if not bSaveMode then
    local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
    WardrobeLogicManager:SetWardrobeEditMode(wardrobe_macro.EWardrobeEditMode.None, nil)
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_FASHION_BAG_EDIT_EXIT)
  end
  self.bEnterFashionSaveMode = bSaveMode
  local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local macroTabString = wardrobe_macro.ENUM_WardrobeSubTabString
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  local tmp = logic_wardrobe.GetCurrentTabId()
  self:SetWidgetVisible(self.UIRoot.Image_18, false)
  self.UIRoot.CanvasPanel_Slot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SHOW_FASHION_BAG)
  local OnBackWardrobe = function()
    self.UIRoot.CanvasPanel_Slot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self:SwitchUIRestrictZone(ENUM_UIRESTRIC_ZONE_TYPE.DEFAULT)
    local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
    MallSystemWeaponModelHandler.RefreshWeaponLocation()
    if self.eWardrobeEditMode ~= wardrobe_macro.EWardrobeEditMode.None and self.eWardrobeEditMode ~= wardrobe_macro.EWardrobeEditMode.Inherit then
      self.eWardrobeEditMode = wardrobe_macro.EWardrobeEditMode.None
      self:ReInitUI()
    end
    if self.eWardrobeEditMode == wardrobe_macro.EWardrobeEditMode.Inherit then
      local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
      WardrobeLogicManager:SetWardrobeEditMode(wardrobe_macro.EWardrobeEditMode.Inherit, nil)
    end
    EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_BACK_FASHION_BAG)
    self:SetWidgetVisible(self.UIRoot.Image_18, true)
  end
  local extraData = {bSaveMode = bSaveMode}
  if self.eWardrobeEditMode ~= wardrobe_macro.EWardrobeEditMode.None then
    if self.eWardrobeEditMode == wardrobe_macro.EWardrobeEditMode.Intimacy then
      Lobby_camera_manager_module:SwitchCamera(10160, 0.3)
      UIManager.ShowUI(UIManager.UI_Config.fashion_bag_overview, function()
        Lobby_camera_manager_module:SwitchCamera(10002, 0.3)
        OnBackWardrobe()
      end, 2, extraData)
      return
    elseif self.eWardrobeEditMode == wardrobe_macro.EWardrobeEditMode.ShareBag then
      self.UIRoot.CanvasPanel_Slot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      self.eWardrobeEditMode = wardrobe_macro.EWardrobeEditMode.None
      self:ReInitUI()
      self:HandlerFashionBagIconVisibility()
      local logic_share_bag_privilege_util = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_share_bag_privilege_util)
      logic_share_bag_privilege_util:OpenShareBagConfigPanel()
      return
    end
  end
  if tmp == macroTabString.ENUM_WardrobeSubTabString_throw_object or tmp == macroTabString.ENUM_WardrobeSubTabString_emoji_bubble or tmp == macroTabString.ENUM_WardrobeSubTabString_plating then
    log(bWriteLog and "[cw] wardrobe Scene ")
    Lobby_camera_manager_module:SwitchCamera(10161, 0.3)
    UIManager.ShowUI(UIManager.UI_Config.fashion_bag_overview, function()
      Lobby_camera_manager_module:SwitchCamera(Lobby_camera_manager_module.Enum_CameraID.store_general, 0.3)
      OnBackWardrobe()
    end, nil, extraData)
  elseif tmp == macroTabString.ENUM_WardrobeSubTabString_effect then
    UIManager.ShowUI(UIManager.UI_Config.fashion_bag_overview, function()
      OnBackWardrobe()
    end, nil, extraData)
  elseif tmp == macroTabString.ENUM_WardrobeSubTabString_parachute then
    log(bWriteLog and "[cw] wardrobe parachute Scene ")
    Lobby_camera_manager_module:SwitchCamera(10162, 0.3)
    UIManager.ShowUI(UIManager.UI_Config.fashion_bag_overview, function()
      Lobby_camera_manager_module:SwitchCamera(Lobby_camera_manager_module.Enum_CameraID.store_general, 0.3)
      self.UIRoot.CanvasPanel_Slot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      self:SwitchUIRestrictZone(ENUM_UIRESTRIC_ZONE_TYPE.DEFAULT)
      local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
      MallSystemWeaponModelHandler.RefreshWeaponLocation()
      if self.eWardrobeEditMode ~= wardrobe_macro.EWardrobeEditMode.None then
        self.eWardrobeEditMode = wardrobe_macro.EWardrobeEditMode.None
        self:ReInitUI()
      end
      EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_BACK_FASHION_BAG)
      self:SetWidgetVisible(self.UIRoot.Image_18, true)
    end, nil, extraData)
  elseif tmp == macroTabString.ENUM_WardrobeSubTabString_plane or tmp == macroTabString.Enum_WardrobeSubTabString_SpecialVehicle then
    local subtmp = logic_wardrobe.GetCurrentPlaneObjectType()
    if subtmp == macroTabString.ENUM_WardrobeSubTabString_plane then
      log(bWriteLog and "[cw] lobby Scene aircraft ")
      Lobby_camera_manager_module:SwitchCamera(10176, 0.3)
      UIManager.ShowUI(UIManager.UI_Config.fashion_bag_overview, function()
        Lobby_camera_manager_module:SwitchCamera(Lobby_camera_manager_module:GetStoreVehicleTopViewCameraId(), 0.3)
        OnBackWardrobe()
      end, nil, extraData)
    else
      log(bWriteLog and "[cw] lobby Scene aircraft ")
      Lobby_camera_manager_module:SwitchCamera(10176, 0.3)
      UIManager.ShowUI(UIManager.UI_Config.fashion_bag_overview, function()
        Lobby_camera_manager_module:SwitchCamera(Lobby_camera_manager_module:GetStoreVehicleCameraId(), 0.3)
        OnBackWardrobe()
      end, nil, extraData)
    end
  else
    log(bWriteLog and "[cw] lobby Scene ")
    Lobby_camera_manager_module:SwitchCamera(10160, 0.3)
    UIManager.ShowUI(UIManager.UI_Config.fashion_bag_overview, function()
      Lobby_camera_manager_module:SwitchCamera(10002, 0.3)
      OnBackWardrobe()
    end, nil, extraData)
  end
  self:SwitchUIRestrictZone(ENUM_UIRESTRIC_ZONE_TYPE.FASHION_BAG)
  local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
  MallSystemWeaponModelHandler.RefreshWeaponLocation()
end
function UI_Wardrobe:RefreshBagName(CurrentIndex)
  local fashionBag_data = require("client.slua.logic.wardrobe.fashionbag.fashionbag_data")
  if self.eWardrobeEditMode ~= wardrobe_macro.EWardrobeEditMode.None and self.eWardrobeEditMode ~= wardrobe_macro.EWardrobeEditMode.Inherit then
    self.UIRoot.Text_BagIndex:SetWidgetVisibility(Collapsed)
    local sprite = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/WH_icon_xia_Open_Share_png.WH_icon_xia_Open_Share_png"
    self:SetTexture(self.UIRoot.Image_14, sprite, {bMatchSize = true})
  else
    self.UIRoot.Text_BagIndex:SetWidgetVisibility(SelfHitTestInvisible)
    local sprite = "/Game/UMG/Texture_200/Atlas/WardrobeUI_New/Frames/Wardrobe_icon_SharedBag_png.Wardrobe_icon_SharedBag_png"
    self:SetTexture(self.UIRoot.Image_14, sprite)
    local selectedBagIndex = CurrentIndex or fashionBag_data:GetFashionBagUseIndex()
    self.UIRoot.Text_BagIndex:SetText("")
  end
  self:SetWidgetVisible(self.UIRoot.TextBlock_PlanName, false, false)
  if self.eWardrobeEditMode == wardrobe_macro.EWardrobeEditMode.FashionBag then
    local EditIndex = self.CurrentEditFashionBagIndex or 1
    local BagName
    if EditIndex == 4 then
      BagName = LocUtil.GetLocalizeResStr(69126)
    elseif EditIndex == 6 then
      BagName = LocUtil.GetLocalizeResStr(87405)
    else
      BagName = LocUtil.LocalizeResFormat(69124, EditIndex)
    end
    self.UIRoot.TextBlock_PlanName:SetText(BagName)
    self:SetWidgetVisible(self.UIRoot.TextBlock_PlanName, true, false)
  elseif self.eWardrobeEditMode == wardrobe_macro.EWardrobeEditMode.Inherit then
    self.UIRoot.TextBlock_PlanName:SetText(LocUtil.GetLocalizeResStr(77723))
    self:SetWidgetVisible(self.UIRoot.TextBlock_PlanName, true, false)
  end
end
function UI_Wardrobe:GetDataForJumpBack()
  local FashionBagEditUtils = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.FashionBagEditUtils)
  self.bWaitingJumpOut = true
  if self.args and type(self.args) == "table" then
    self.args.TransientData = nil
  end
  local WardrobeLogic = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local restoreShareType, restoreShareList
  if self.eWardrobeEditMode == wardrobe_macro.EWardrobeEditMode.ShareBag then
    restoreShareType = WardrobeLogic:GetShareType()
    restoreShareList = WardrobeLogic:GetShareBagItemList()
  end
  return {
    ctorData = {
      [1] = self.currentPageId,
      [2] = self.currentSubTabId,
      [3] = self.args,
      [4] = self.eWardrobeEditMode,
      [5] = true
    },
    uiData = {
      isShowFashionBag = UIManager.IsUIShow(UIManager.UI_Config.fashion_bag_overview),
      bNeedRestoreEditData = FashionBagEditUtils:StoreFashionBagEditData(),
      restoreShareType = restoreShareType,
          }
  }
end
function UI_Wardrobe:OnPostJumpBack()
  if self.hasInit and self.uiData then
    if self.uiData.isShowFashionBag then
      self:ShowFashionBag(false)
    end
    if self.uiData then
      if self.uiData.bNeedRestoreEditData then
        local FashionBagEditUtils = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.FashionBagEditUtils)
        FashionBagEditUtils:RestoreFashionBagData()
        FashionBagEditUtils:BeginPreviewCurrentTheme()
        EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_FASHION_BAG_EDIT_JUMPBACK)
      end
      if self.uiData.restoreShareType and self.uiData.restoreShareList then
        self:EnterShareBagEditMode(self.uiData.restoreShareList, self.uiData.restoreShareType)
      end
    end
    self.uiData = nil
  end
end
function UI_Wardrobe:JumpBack(uiData)
  self.  self:OnPostJumpBack()
end
function UI_Wardrobe:ClearJumpChainIfNeed()
  if type(self.args) == "table" and self.args.clearJumpChainWhenChangeTab and not self.jumpPageId and not self.jumpSubTabId then
    local ui_jump_manager = require("client.common.uibase.ui_jump_manager")
    ui_jump_manager.Clear()
    self.args.clearJumpChainWhenChangeTab = nil
  end
end
function UI_Wardrobe:OnSubPageOpened()
  if type(self.args) == "table" then
    if self.args.bShowSubscribeSharePopup then
      self:AddTimerOnce(0.5, function()
        UIManager.ShowUI(UIManager.UI_Config.Wardrobe_ShareBackpack_Popup_UIBP, self.args.ShareType)
        self.args.bShowSubscribeSharePopup = nil
      end)
    elseif self.args.bEnterSubscribeShareEditMode then
      self.args.bEnterSubscribeShareEditMode = nil
      self.bCloseWithoutSubscribePopup = true
      self:EnterShareBagEditMode(self.args.initSharedList or {}, self.args.ShareType)
    end
  end
end
function UI_Wardrobe:SwitchUIRestrictZone(ZoneType)
  local Cfg = UIRESTRICMAP[ZoneType]
  local GetUIRestricZoneFunc = function()
    local UIUtil = require("client.common.ui_util")
    local ScreenPixelSize = UIUtil.GetViewportSize()
    local DPI = UIUtil.GetViewportScale()
    local ScreenX = ScreenPixelSize.X / DPI
    local ScreenY = ScreenPixelSize.Y / DPI
    return {
      L = Cfg.L * math.min(ScreenX / 1334, ScreenY / 750),
      R = Cfg.R * math.min(ScreenX / 1334, ScreenY / 750),
      U = Cfg.U,
      D = Cfg.D
    }
  end
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  ModelDisplayer.RegistGetUIRestrictZoneFunc(GetUIRestricZoneFunc)
end
function UI_Wardrobe:OnClose()
  log(bWriteLog and "UI_Wardrobe:OnClose")
  self:HideSubscribeShareBagTips()
  self.bEnterFashionSaveMode = false
  if UIManager.GetUI(UIManager.UI_Config.Wardrobe_ShareBackpack_Popup_UIBP) then
    UIManager.CloseUI(UIManager.UI_Config.Wardrobe_ShareBackpack_Popup_UIBP)
  end
  local logic_lobby_toy = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lobby_toy)
  if logic_lobby_toy:IsPreview() then
    logic_lobby_toy:ClearEffect()
  end
  local wardrobe_red_point = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.wardrobe_red_point)
  wardrobe_red_point:RemoveAllWidget()
  local sub_tab_buttons_mgr = require("client.slua.umg.Wardrobe.sub_tab_buttons_mgr")
  sub_tab_buttons_mgr:ClearIns()
  local sub_tab_supercar_buttons_mgr = require("client.slua.umg.Wardrobe.sub_tab_supercar_buttons_mgr")
  sub_tab_supercar_buttons_mgr:ClearIns()
  self:CloseTagEditPanels()
  self.bOpenAnimationFinish = false
  local logic_subscribe_handler = require("client.slua.logic.subscribe.logic_subscribe_handler")
  local subscribeModuleObj = logic_subscribe_handler.GetSubscribeModuleObj()
  local SubscribeEnumConfig = require("client.slua.logic.subscribe.logic_subscribe_enum_config")
  if subscribeModuleObj:Get_Is_Valid(SubscribeEnumConfig.ENUM_SubId.Super) and self.bShowSubscribeShareTips then
    local logic_share_bag_guide = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_share_bag_guide)
    logic_share_bag_guide:SetShareBagGuideStatus(logic_share_bag_guide.SHARE_TYPE_SUBSCRIPBE, logic_share_bag_guide.GUIDETYPE_SUBSCRIBE_WARDROBE, logic_share_bag_guide.GUIDE_SHOWSTATUS_HAS_SHOWN)
  end
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_CLOSE)
  if HDmpveRemote.HDmpveRemoteConfigGetBool("ReleaseRepoLuaTableData", false) then
    log(bWriteLog and "UI_Wardrobe:OnClose ReleaseRepoLuaTableData")
    self.jumpPageId = nil
    self.jumpSubTabId = nil
    self.args = nil
    self.eWardrobeEditMode = nil
    self.shareBagSubType = nil
    self.LeftCornerShown = nil
    self.LeftCornerSuspendTime = nil
    self.Timer = nil
    self.AutoFoldEnabled = nil
    self.currentPageId = nil
    self.currentSubTabId = nil
    self.isJumpBack = nil
    self.preWingmanSkinID = nil
    self.subTabMap = nil
    self.bCloseWithoutSubscribePopup = nil
    self.bOpenAnimationFinish = nil
    self.bShowSubscribeShareTips = nil
    self.bOnPageClickArrive = nil
    self.bEnterFashionSaveMode = nil
    self.bWaitingJumpOut = nil
    self.curIns = nil
    self.CurrentEditFashionBagIndex = nil
    self.hasInit = nil
    self.uiData = nil
    self.preWingmanSkinIns = nil
  end
  UI_Wardrobe.__super.OnClose(self)
end
local SUBSCRIBE_SHARE_TIPS_CONTENT_OFFSET_X = 28
local SUBSCRIBE_SHARE_TIPS_CONTENT_SIZE = 40
function UI_Wardrobe:CheckAndShowSubscribeShareBagTips()
  log(bWriteLog and "UI_Wardrobe:CheckAndShowSubscribeShareBagTips")
  local bCanShow = false
  local logic_subscribe_handler = require("client.slua.logic.subscribe.logic_subscribe_handler")
  local subscribeModuleObj = logic_subscribe_handler.GetSubscribeModuleObj()
  local SubscribeEnumConfig = require("client.slua.logic.subscribe.logic_subscribe_enum_config")
  local guideStatus
  local logic_share_bag_guide = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_share_bag_guide)
  if subscribeModuleObj:Get_Is_Valid(SubscribeEnumConfig.ENUM_SubId.Super) then
    guideStatus = logic_share_bag_guide:GetShareBagGuideStatus(logic_share_bag_guide.SHARE_TYPE_SUBSCRIPBE, logic_share_bag_guide.GUIDETYPE_SUBSCRIBE_WARDROBE)
  end
  bCanShow = guideStatus == logic_share_bag_guide.GUIDE_SHOWSTATUS_NOT
  if not bCanShow then
    self:HideSubscribeShareBagTips()
    return
  end
  if not self.LeftCornerShown then
    self:HideSubscribeShareBagTips()
    return
  end
  local EntryIconMgr = require("client.slua.umg.Wardrobe.entry.entry_icon_mgr")
  local iconEntryShare = EntryIconMgr:GetIconNoCreat(EntryIconMgr.ENUM_SUBSCRIBE_SHARE)
  if not iconEntryShare or not iconEntryShare:IsShow() then
    self:HideSubscribeShareBagTips()
    return
  end
  log(bWriteLog and "[debug] CheckAndShowSubscribeShareBagTips iconEntryShare:IsShow() " .. tostring(iconEntryShare:IsShow()))
  self.bShowSubscribeShareTips = true
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_GuideContent, true, false)
  self:RefreshSubscribeShareBagTipsPos()
end
function UI_Wardrobe:RefreshSubscribeShareBagTipsPos()
  local EntryIconMgr = require("client.slua.umg.Wardrobe.entry.entry_icon_mgr")
  local iconEntryShare = EntryIconMgr:GetIconNoCreat(EntryIconMgr.ENUM_SUBSCRIBE_SHARE)
  if not iconEntryShare or not iconEntryShare:IsShow() then
    self:HideSubscribeShareBagTips()
    return
  end
  local guideContent = self.UIRoot.CanvasPanel_GuideContent
  local tipsVisibility = guideContent:GetVisibility()
  if tipsVisibility ~= UEnums.ESlateVisibility.Collapsed and tipsVisibility ~= UEnums.ESlateVisibility.Hidden then
    local SlateBlueprintLibrary = import("SlateBlueprintLibrary")
    local iconEntryShareGeometry = iconEntryShare.UIRoot:GetCachedGeometry()
    local guideRootGeometry = self.UIRoot.CanvasPanel_SubscribeShareGuide:GetCachedGeometry()
    local entryAbsPos = SlateBlueprintLibrary.LocalToAbsolute(iconEntryShareGeometry, FVector2D(0, 0))
    local newLocalPos = SlateBlueprintLibrary.AbsoluteToLocal(guideRootGeometry, entryAbsPos)
    log(bWriteLog and string.format("[debug][share_entry] CheckAndShowSubscribeShareBagTips iconEntryShare entryAbsPos(%f,%f) new local pos(%f,%f)", entryAbsPos.X, entryAbsPos.Y, newLocalPos.X, newLocalPos.Y))
    if guideContent.Slot then
      guideContent.Slot:SetAnchors(FAnchors(0, 0, 0, 0))
      guideContent.Slot:SetPosition(FVector2D(SUBSCRIBE_SHARE_TIPS_CONTENT_OFFSET_X, newLocalPos.Y + SUBSCRIBE_SHARE_TIPS_CONTENT_SIZE / 2))
    end
  end
end
function UI_Wardrobe:RefreshDecomposeIcon()
  local EntryIconMgr = require("client.slua.umg.Wardrobe.entry.entry_icon_mgr")
  local iconDecompose = EntryIconMgr:GetIconNoCreat(EntryIconMgr.ENUM_DECOMPOSE)
  if iconDecompose and iconDecompose:IsShow() then
    local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
    local isRestrict = QRcodeRestrictManager:IsRestrictDepotDecompose()
    iconDecompose:SetWidgetVisible(iconDecompose.UIRoot.Button, not isRestrict, true)
    iconDecompose:SetWidgetVisible(iconDecompose.UIRoot.Button_0, isRestrict, true)
  end
end
function UI_Wardrobe:CheckAndShowDecalExchangeTips()
  log(bWriteLog and "UI_Wardrobe:CheckAndShowDecalExchangeTips")
  local LogicVehicleDecalExchange = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicVehicleDecalExchange)
  local bCanShow = LogicVehicleDecalExchange:NeedShowDecalGuide()
  if not bCanShow then
    self:HideDecalExchangeGuide()
    log(bWriteLog and "UI_Wardrobe:CheckAndShowDecalExchangeTips. bCanShow is false")
    return
  end
  if not self.LeftCornerShown then
    self:HideDecalExchangeGuide()
    log(bWriteLog and "UI_Wardrobe:CheckAndShowDecalExchangeTips. LeftCornerShown is false")
    return
  end
  local EntryIconMgr = require("client.slua.umg.Wardrobe.entry.entry_icon_mgr")
  local iconEntryDecalExchange = EntryIconMgr:GetIconNoCreat(EntryIconMgr.ENUM_SPRAY_EXCHANGE)
  if not iconEntryDecalExchange or not iconEntryDecalExchange:IsShow() then
    self:HideDecalExchangeGuide()
    log(bWriteLog and "UI_Wardrobe:CheckAndShowDecalExchangeTips. iconEntryDecalExchange:IsShow() is false")
    return
  end
  log(bWriteLog and "UI_Wardrobe:CheckAndShowDecalExchangeTips iconEntryShare:IsShow() " .. tostring(iconEntryDecalExchange:IsShow()))
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_DecalExchange_Content, true, false)
  self:RefreshDecalExchangeTipsPos()
end
function UI_Wardrobe:RefreshDecalExchangeTipsPos()
  local EntryIconMgr = require("client.slua.umg.Wardrobe.entry.entry_icon_mgr")
  local iconExtraDecalExchange = EntryIconMgr:GetIconNoCreat(EntryIconMgr.ENUM_SPRAY_EXCHANGE)
  if not iconExtraDecalExchange or not iconExtraDecalExchange:IsShow() then
    self:HideDecalExchangeGuide()
    return
  end
  local guideContent = self.UIRoot.CanvasPanel_DecalExchange_Content
  local tipsVisibility = guideContent:GetVisibility()
  if tipsVisibility ~= UEnums.ESlateVisibility.Collapsed and tipsVisibility ~= UEnums.ESlateVisibility.Hidden then
    local SlateBlueprintLibrary = import("SlateBlueprintLibrary")
    local iconEntryDecalExchangeGeometry = iconExtraDecalExchange.UIRoot:GetCachedGeometry()
    local guideRootGeometry = self.UIRoot.CanvasPanel_DecalExchangeGuide:GetCachedGeometry()
    local entryAbsPos = SlateBlueprintLibrary.LocalToAbsolute(iconEntryDecalExchangeGeometry, FVector2D(0, 0))
    local newLocalPos = SlateBlueprintLibrary.AbsoluteToLocal(guideRootGeometry, entryAbsPos)
    log(bWriteLog and string.format("RefreshDecalExchangeTipsPos iconEntryDecalExchangeGeometry entryAbsPos(%f,%f) new local pos(%f,%f)", entryAbsPos.X, entryAbsPos.Y, newLocalPos.X, newLocalPos.Y))
    if guideContent.Slot then
      guideContent.Slot:SetAnchors(FAnchors(0, 0, 0, 0))
      guideContent.Slot:SetPosition(FVector2D(SUBSCRIBE_SHARE_TIPS_CONTENT_OFFSET_X, newLocalPos.Y + SUBSCRIBE_SHARE_TIPS_CONTENT_SIZE / 2))
    end
  end
end
function UI_Wardrobe:HideDecalExchangeGuide()
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_DecalExchange_Content, false, false)
end
function UI_Wardrobe:OnOpenAnimationFinished()
  self.bOpenAnimationFinish = true
  if self.LeftCornerShown then
    self:AddTimerOnce(0.3, function()
      self:CheckAndShowSubscribeShareBagTips()
      self:CheckAndShowDecalExchangeTips()
    end)
  else
    self:HideSubscribeShareBagTips()
    self:HideDecalExchangeGuide()
  end
  self:RefreshDecomposeIcon()
end
function UI_Wardrobe:HideSubscribeShareBagTips()
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_GuideContent, false, false)
end
function UI_Wardrobe:ResetDefaultUIRestrictZone()
  self:SwitchUIRestrictZone(ENUM_UIRESTRIC_ZONE_TYPE.DEFAULT)
end
function UI_Wardrobe:OnSubscribeEntryChanged()
  if self.bOpenAnimationFinish then
    self:CheckAndShowSubscribeShareBagTips()
  end
end
function UI_Wardrobe:OnSubscribeEntryClicked()
  self:HideSubscribeShareBagTips()
end
function UI_Wardrobe:OnShowEntryIcon(eventType, eventID, show)
  self:SetWidgetVisible(self.UIRoot.ScaleBox_2, show)
end
function UI_Wardrobe:OnShowExtraButton(_, __, show)
  self:SetWidgetVisible(self.UIRoot.Button_0, show, true)
end
function UI_Wardrobe:OnSharedBagGuideStatusUpdate(_, __, shareType, statusTable)
  if not shareType or not statusTable then
    return
  end
  local logic_share_bag_guide = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_share_bag_guide)
  if shareType ~= logic_share_bag_guide.SHARE_TYPE_SUBSCRIPBE then
    return
  end
  self:CheckAndShowSubscribeShareBagTips()
end
function UI_Wardrobe:IsCurrentPageShowTagFilter()
  local WardrobeLogic = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  if WardrobeLogic:IsInInheritMode() then
    return false
  end
  if self.curIns == nil or self.curIns.CanShowTagFilter == nil then
    return false
  end
  return self.curIns:CanShowTagFilter()
end
function UI_Wardrobe:CloseTagEditPanels()
  if UIManager.GetUI(UIManager.UI_Config.Wardrobe_Sift_Suit_Popup_UIBP) then
    UIManager.CloseUI(UIManager.UI_Config.Wardrobe_Sift_Suit_Popup_UIBP)
  end
  if UIManager.GetUI(UIManager.UI_Config.Wardrobe_TipsPanel_Favorites_UIBP) then
    UIManager.CloseUI(UIManager.UI_Config.Wardrobe_TipsPanel_Favorites_UIBP)
  end
  if UIManager.GetUI(UIManager.UI_Config.Wardrobe_EditTag_Popup_UIBP) then
    UIManager.CloseUI(UIManager.UI_Config.Wardrobe_EditTag_Popup_UIBP)
  end
end
function UI_Wardrobe:ProcessSubTabDisplayByEditMode()
  local wardrobe_fashion_utils = require("client.slua.logic.wardrobe.fashionbag.wardrobe_fashion_utils")
  for k, v in pairs(self.subTabMap) do
    local ItemSubTypeList = v.tabConfig.ItemSubTypeIDs
    local PageId = v.tabConfig.pageId
    local SubTabId = v.tabConfig.subTabId
    local bShow = wardrobe_fashion_utils:CheckSubTabShowBySubTabInfo(self.eWardrobeEditMode, PageId, SubTabId, ItemSubTypeList)
    self:SetWidgetVisible(v, bShow, true)
  end
end
function UI_Wardrobe:UpdateLeftPanelByEditMode()
  if self.eWardrobeEditMode == wardrobe_macro.EWardrobeEditMode.FashionBag then
    self.UIRoot.WidgetSwitcher_LeftButton:SetActiveWidgetIndex(1)
  else
    self.UIRoot.WidgetSwitcher_LeftButton:SetActiveWidgetIndex(0)
  end
end
function UI_Wardrobe:OnCheckBox_ApplyAfterEdit(isCheck)
  self:PlayAudio(sound_config.click_v1)
  local FashionBagEditUtils = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.FashionBagEditUtils)
  FashionBagEditUtils:SetApplyAfterEditFlag(isCheck)
end
function UI_Wardrobe:OnDecalExchangeEntryChanged()
  if self.bOpenAnimationFinish then
    self:AddTimer(0.2, function()
      self:CheckAndShowDecalExchangeTips()
    end)
  end
end
function UI_Wardrobe:OnDecalExchangeEntryClearTips()
  self:HideDecalExchangeGuide()
end
function UI_Wardrobe:ShowTeamPositionTips(bShow)
  if bShow then
    self.UIRoot.CanvasPanel_TeamPoseGuide:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot.CanvasPanel_TeamPoseGuide:SetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function UI_Wardrobe:RefreshPageTab()
  local showPageTabs = {}
  local wardrobe_fashion_utils = require("client.slua.logic.wardrobe.fashionbag.wardrobe_fashion_utils")
  local config = require("client.slua.umg.Wardrobe.wardrobe_config")
  for i, tabConfig in ipairs(config.PageTab_Config) do
    if wardrobe_fashion_utils:CheckTabShowByPageType(self.eWardrobeEditMode, tabConfig.pageId, {
      shareBagSubType = self.shareBagSubType
    }) then
      showPageTabs[#showPageTabs + 1] = tabConfig
    end
  end
  local initialIndex = self:GetInitialTabIndex(showPageTabs)
  self.Common_Tab_Vertical_LevelOne_Icon_UIBP:SetTabs(showPageTabs, initialIndex)
  self:OnClickTabItem(nil, initialIndex)
end
function UI_Wardrobe:GetInitialTabIndex(showPageTabs)
  local wardrobeMacro = require("client.slua.umg.Wardrobe.wardrobe_macro")
  if self.eWardrobeEditMode ~= wardrobeMacro.EWardrobeEditMode.None then
    return self:GetSpecialModeTabIndex(showPageTabs, wardrobeMacro)
  else
    return self:GetNormalModeTabIndex(showPageTabs)
  end
end
function UI_Wardrobe:GetSpecialModeTabIndex(showPageTabs, wardrobeMacro)
  local jumpPageId = wardrobeMacro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Avatar
  if self.eWardrobeEditMode == wardrobeMacro.EWardrobeEditMode.ShareBag then
    jumpPageId = self:GetShareBagJumpPageId(wardrobeMacro)
  end
  for i, tabConfig in ipairs(showPageTabs) do
    if jumpPageId == tabConfig.pageId then
      return i
    end
  end
  return 1
end
function UI_Wardrobe:GetShareBagJumpPageId(wardrobeMacro)
  local jumpPageId = wardrobeMacro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Avatar
  local share_bag_macros = require("client.slua.logic.share_bag.share_bag_macros")
  if self.shareBagSubType == share_bag_macros.ENUM_ShareType.Weapon then
    jumpPageId = wardrobeMacro.ENUM_WardrobePageTypeId.ENUM_WardrobePageType_Weapon
  end
  return jumpPageId
end
function UI_Wardrobe:GetNormalModeTabIndex(showPageTabs)
  for i, tabConfig in ipairs(showPageTabs) do
    if self.jumpPageId and self.jumpPageId == tabConfig.pageId then
      return i
    end
    if not self.jumpPageId and tabConfig.defaultSelected then
      return i
    end
  end
  return 1
end
function UI_Wardrobe:OnRefreshTabItem(widget, index)
  local data = self.Common_Tab_Vertical_LevelOne_Icon_UIBP:GetTabData(index)
  if not data then
    return
  end
  local wardrobe_red_point = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.wardrobe_red_point)
  local validityCheck = function()
    if self:InInheritMode() then
      return false
    end
    if data.onPageClick then
      return true
    end
    local wardrobe_fashion_utils = require("client.slua.logic.wardrobe.fashionbag.wardrobe_fashion_utils")
    local WardrobeConfig = require("client.slua.umg.Wardrobe.wardrobe_config")
    local WardrobeUtils = require("client.slua.logic.wardrobe.wardrobe_utils")
    local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
    local eWardrobeEditMode = WardrobeLogicManager:GetWardrobeEditMode()
    local subTabIDList = WardrobeConfig:GetSubTabListByPageId(data.pageId)
    for _, data in ipairs(subTabIDList) do
      if WardrobeUtils.CanInitSubTab(data) then
        local itemSubTypeList = data.ItemSubTypeIDs
        local pageId = data.pageId
        local subTabId = data.subTabId
        if wardrobe_fashion_utils:CheckSubTabShowBySubTabInfo(eWardrobeEditMode, pageId, subTabId, itemSubTypeList) then
          local node = wardrobe_red_point:GetTab(subTabId)
          if node and node:CheckShow() then
            return true
          end
        end
      end
    end
    return false
  end
  widget.Reddot_Anchor:UnBind()
  widget.Reddot_Anchor:ShowRedPointByPath(wardrobe_red_point.C_Wardrobe_RedPoint_Style)
  local node = wardrobe_red_point:GetPage(data.pageId)
  if node then
    node:RegisterWidget(widget.Reddot_Anchor, validityCheck)
  end
end
function UI_Wardrobe:OnClickTabItem(widget, index)
  local data = self.Common_Tab_Vertical_LevelOne_Icon_UIBP:GetTabData(index)
  if not data then
    return
  end
  local logic_wardrobe = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local pageId = logic_wardrobe:GetCurrentPageId()
  if widget and pageId == data.pageId then
    log(bWriteLog and string.format("UI_Wardrobe:OnClickTabItem: already in this page  "))
    return
  end
  if widget then
    self:PlayAudio(sound_config.tab_v1)
    self:PlayUserWidgetAnimation(self.UIRoot.Anim_Select, 0, 1, 0, 1)
  end
  logic_wardrobe:ChangeToLobbyScene(data.pageId)
  logic_wardrobe:SetCurrentPageId(data.pageId)
  self:OnPageTabClicked(data)
end
function UI_Wardrobe:InInheritMode()
  local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
  local eWardrobeEditMode = WardrobeLogicManager:GetWardrobeEditMode()
  if eWardrobeEditMode == wardrobe_macro.EWardrobeEditMode.Inherit then
    return true
  end
  return false
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CUIWardrobe = class(ui_base, nil, UI_Wardrobe)
return CUIWardrobe