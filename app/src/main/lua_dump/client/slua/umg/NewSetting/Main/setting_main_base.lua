local Setting_Main = {}
local SettingSystem = require("client.logic.setting.logic_setting")
local ClientEvoConfig = require("client.logic.client_evo_config.client_evo_config")
local gc_util = require("common.gc_util")
function Setting_Main:ctor(_, Catalog, PageKey, Param)
  print(bWriteLog and "Setting_Main:ctor")
  self.  self.CanShowEscapeNotice = false
  self._PendingOpenPageKey = PageKey or false
  self._PendingOpenPageParam = Param or false
end
function Setting_Main:OnInitialize()
  print(bWriteLog and "Setting_Main:OnInitialize")
  self.Common_Tab_Page = self:InitVerticalTextTab(self.UIRoot.Common_Tab_Vertical_LevelOne_Text_UIBP)
  self.Common_Tab_Header = self:InitHorizontalLevelOneTextTab(self.UIRoot.Common_Tab_Header, {bDarkMode = true})
  slua_GameFrontendHUD:BeginModifyUserSettings()
  if GameStatus.IsInLobbyOrMainCity() then
    local SettingRedManager = require("client.slua.logic.setting.setting_redpoint_manager")
    self.CurrentReddotTable = SettingRedManager:GetReddotPathTable()
  else
    self.CurrentReddotTable = {}
  end
end
function Setting_Main:RegistEvents()
  print(bWriteLog and "Setting_Main:RegistEvents")
  self:AddOnClickedEventByControl(self.UIRoot.button_close, self.OnClickClose, self)
  self.Common_Tab_Page:AddOnTabRefreshCallback(self.OnRefreshTab_Page, self)
  self.Common_Tab_Page:AddOnTabSelectedCallback(self.OnSelectTab_Page, self)
  self.Common_Tab_Header:AddOnSelectedCallback(self.OnSelectTab_Category, self)
  self.Common_Tab_Header:AddOnTabRefreshCallback(self.OnRefreshTab_Category, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_HIDE_ALL_UI, self.CloseSelf, self)
  self:AddCommonEvent(EVENTTYPE_STATE, EVENTID_GAMESTATE_ON_BATTLE_RESULT, self.CloseSelf, self)
  self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_SHOW_TDM_TAB_PANEL, self.CloseSelf, self)
  self:AddCommonEvent(EVENTTYPE_SETTING, EVENTID_SETTING_CONSUME_RED_POINT, self.OnConsumeReddot, self)
  self:AddCommonEvent(EVENTTYPE_SETTING, EVENTID_SETTING_UIELEMLAYOUT_SHOW, function(_, __, bShow)
    if bShow then
      self.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    else
      self.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
  end)
  SettingSystem.DebugSuggestion.RegistEvents()
end
function Setting_Main:OnPostInitialize()
  print(bWriteLog and "Setting_Main:OnPostInitialize")
  self:PrepareDataOnInit()
  if not assert(self.Catalog ~= nil, "Setting_Main:OnPostInitialize self.Catalog is nil") then
    return
  end
  local InitialIndex
  local AvailablePageList = {}
  for Index, Page in ipairs(self.Catalog) do
    if not Page.VisibilityFunc or Page.VisibilityFunc() then
      table.insert(AvailablePageList, Page)
      if self._PendingOpenPageKey and not InitialIndex and self._PendingOpenPageKey == Page.Key then
        InitialIndex = #AvailablePageList
      end
    end
  end
  self.Common_Tab_Page:SetTabs(AvailablePageList, InitialIndex)
  self:PlayUserWidgetAnimation(self.UIRoot.fadein, 0, 1, 0, 1)
  self:HideRedTitle()
end
function Setting_Main:OnShow()
  self.UIRoot.LoopScrollBox_Tab:ScrollToStart()
  EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SHOW_SETTING, true)
  local UIUtil = require("client.common.ui_util")
  UIUtil.ShowLobbyCamera(false)
  local LogicLoginVerify = require("client.slua.logic.login.logic_login_verify")
  LogicLoginVerify.ProcessSecurityPopup()
  Client.RequireSlateTickEveryFrame(SlateUI_ID.SETTING_MAIN_BASE)
  self:SetWidgetVisible(self.UIRoot.Common_Tab_Vertical_LevelOne_Text_UIBP.Image_RightBg, false)
  local Brush = self.UIRoot.Common_Tab_Vertical_LevelOne_Text_UIBP.Image_Line.Brush
  Brush.TintColor = FSlateColor(FLinearColor(1, 1, 1, 0.1))
  self.UIRoot.Common_Tab_Vertical_LevelOne_Text_UIBP.Image_Line:SetBrush(Brush)
  if self.GIState == nil then
    self.GIState = ClientEvoConfig.GetSlateGIState()
    log_shipping_client("Setting_Main:OnShow store GIState: " .. tostring(self.GIState))
  end
  ClientEvoConfig.ToggleSlateGI(false)
end
function Setting_Main:OnClose()
  if self.UIRoot.Common_Tab_Vertical_LevelOne_Text_UIBP then
    local Brush = self.UIRoot.Common_Tab_Vertical_LevelOne_Text_UIBP.Image_Line.Brush
    Brush.TintColor = FSlateColor(FLinearColor(0, 0, 0, 0.08))
    self.UIRoot.Common_Tab_Vertical_LevelOne_Text_UIBP.Image_Line:SetBrush(Brush)
  end
  Client.ResetSlateTickEveryFrame(SlateUI_ID.SETTING_MAIN_BASE)
  SettingSystem.UploadSettingConfigToCloud()
  UIManager.CloseUI(UIManager.UI_Config.common_questionmark_style_three)
  UIManager.CloseUI(UIManager.UI_Config.setting_red_title)
  slua_GameFrontendHUD:FinishModifyUserSettings()
  EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SHOW_SETTING, false)
  SettingSystem.DebugSuggestion.UnregistEvents()
  local UIUtil = require("client.common.ui_util")
  UIUtil.ShowLobbyCamera(true)
  LobbySystem.UpdateSettingRedPoint()
  self:TLogDataCloseUI()
  gc_util.GCByMaxObjectOrMemory()
  log_shipping_client("Setting_Main:OnClose restore GIState: " .. tostring(self.GIState))
  ClientEvoConfig.ToggleSlateGI(self.GIState)
  self.GIState = nil
end
function Setting_Main:PrepareDataOnInit()
  self:InitRegionInfo()
  self:InitWhenSimulator()
  local logic_setting_recommended = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_setting_recommended)
  logic_setting_recommended:send_get_recommend_open_req()
  local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
  RoleInfoPopularitySystem.send_get_pspace_hidden_visitor_track()
  local SocialLobbyHandler = require("client.network.Protocol.SocialLobbyHandler")
  SocialLobbyHandler.send_get_role_privacy()
  local SettingAccount = require("client.logic.setting.logic_setting_account")
  SettingAccount.CheckRequestData()
  local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
  PersonSpaceSystem.get_intimacy_relation_visible_req()
  local logic_season_lookback = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_lookback)
  logic_season_lookback:send_get_season_lookback_privacy_req()
  RoleInfoPopularitySystem.get_popularity_req(tonumber(DataMgr.roleData.uid), RoleInfoPopularitySystem.EPopularityScene.SettingMain)
  local PersonSpaceHandler = require("client.network.Protocol.PersonSpaceHandler")
  PersonSpaceHandler.send_get_intimacy_relation_prior_show()
  local CareerSystem = require("client.slua.logic.career.logic_career")
  if CareerSystem.IsOpen() and GameStatus.IsInLobbyOrMainCity() then
    local CareerSystem = require("client.slua.logic.career.logic_career")
    CareerSystem.ReqCareerIsPublic()
  end
  local logic_ugc_playlevel = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_playlevel)
  logic_ugc_playlevel:ReqGetPrivacy(DataMgr.roleData.uid)
  local SettingUtil = require("client.slua.logic.setting.setting_util")
  SettingUtil.KRJPDelAccountLeftTime = DataMgr.krjp_del_account_left_time
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  if login_module.commonSwitch and login_module.commonSwitch.KRJPDelAccountSwitch then
    SettingUtil.KRJPDelAccountSwitch = login_module.commonSwitch.KRJPDelAccountSwitch
  end
  local LobbyHandler = require("client.network.Protocol.LobbyHandler")
  LobbyHandler.send_get_account_bind_req()
  local logic_chat_channel_world = require("client.slua.logic.lobby_chat.logic_chat_channel_world")
  logic_chat_channel_world.topic_fetch_lang_list_req()
  local SocialIslandHandler = require("client.network.Protocol.SocialIslandHandler")
  SocialIslandHandler.send_get_apply_onoff_req()
end
function Setting_Main:HideRedTitle()
  self:SetWidgetVisible(self.UIRoot.TopRoot, false)
end
function Setting_Main:OnClickClose()
  self:PlayAudio(sound_config.click_v1)
  if UIManager.UI_Config.xmission_main and UIManager.IsUIShow(UIManager.UI_Config.xmission_main) then
    UIManager.ShowUI(UIManager.UI_Config.FADE_UIBP)
  end
  self:CloseSelf()
end
function Setting_Main:OnAndroidBack()
  self:OnClickClose()
end
function Setting_Main:OnSelectTab_Page(lastIndex, index, bIsFromClick)
  if lastIndex == index then
    return
  end
  if bIsFromClick then
    self:PlayAudio(sound_config.tab_v1)
  end
  local lastPageData = lastIndex and 0 < lastIndex and self.Common_Tab_Page:GetTabData(lastIndex) or nil
  local newPageData = self.Common_Tab_Page:GetTabData(index)
  local lastPageKey = lastPageData and lastPageData.Key or nil
  local newPageKey = newPageData and newPageData.Key or nil
  EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_TAB_SWITCH, lastPageKey, newPageKey)
  if self._PageUI then
    self._PageUI:CloseSelf()
    self._PageUI = nil
  end
  if self._CategoryUI then
    self._CategoryUI:CloseSelf()
    self._CategoryUI = nil
  end
  if self.CurrentReddotTable[lastPageKey] then
    Setting_Main.CleanupInnerReddot(self.CurrentReddotTable[lastPageKey])
  end
  local NewPage = self.Common_Tab_Page:GetTabData(index)
  if NewPage.UIKey then
    if NewPage.Stack then
      self._PageUI = self:CreateChildWindow(self.UIRoot.StackRoot, UIManager.UI_Config[NewPage.UIKey], NewPage.Stack)
    else
      self._PageUI = self:CreateChildWindow(self.UIRoot.StackRoot, UIManager.UI_Config[NewPage.UIKey], self._PendingOpenPageParam)
    end
  end
  self._PendingOpenPageKey = false
  self._PendingOpenPageParam = false
  if self.CurrentReddotTable[newPageKey] then
    self:AddReddotOnStack(self.CurrentReddotTable[newPageKey], self._PageUI)
  end
  if NewPage.Category then
    local TextList = {}
    for _, data in ipairs(NewPage.Category) do
      if not data.VisibilityFunc or data.VisibilityFunc() then
        table.insert(TextList, LocUtil.GetLocalizeResStr(data.loc))
      end
    end
    self.Common_Tab_Header:SetTabs(TextList)
    self:SetWidgetVisible(self.UIRoot.Border_Header, true)
  else
    self:SetWidgetVisible(self.UIRoot.Border_Header, false)
  end
  self:PlayUserWidgetAnimation(self.UIRoot.Fadein_Page, 0, 1, 0, 1)
  self:GCSilently()
end
function Setting_Main:OnSelectTab_Category(lastIndex, index, bIsFromClick)
  if lastIndex == index and bIsFromClick then
    return
  end
  local CurrentPage = self.Common_Tab_Page:GetTabData(self.Common_Tab_Page:GetSelectedTabIndex())
  if not CurrentPage.Category then
    return
  end
  if bIsFromClick then
    self:PlayAudio(sound_config.tab_v1)
  end
  if 0 < lastIndex and self._CategoryUI then
    self._CategoryUI:CloseSelf()
    self._CategoryUI = nil
  end
  local StackContainer
  local NewCategory = CurrentPage.Category[index]
  if NewCategory then
    if NewCategory.UIKey then
      if NewCategory.Stack then
        self._CategoryUI = self:CreateChildWindow(self.UIRoot.StackRoot, UIManager.UI_Config[NewCategory.UIKey], NewCategory.Stack)
        StackContainer = self._CategoryUI
      else
        self._CategoryUI = self:CreateChildWindow(self.UIRoot.StackRoot, UIManager.UI_Config[NewCategory.UIKey])
      end
    elseif NewCategory.Stack and self._PageUI.ReloadStack then
      self._PageUI:ReloadStack(NewCategory.Stack)
      StackContainer = self._PageUI
    end
  end
  self:PlayUserWidgetAnimation(self.UIRoot.Fadein_Category, 0, 1, 0, 1)
  if self.CurrentReddotTable[CurrentPage.Key] and self.CurrentReddotTable[CurrentPage.Key][NewCategory.Key] then
    self:AddReddotOnStack(self.CurrentReddotTable[CurrentPage.Key][NewCategory.Key], StackContainer)
  end
end
function Setting_Main:OnRefreshTab_Page(widget, index)
  local curSelectIndex = self.Common_Tab_Page:GetSelectedTabIndex()
  self:SetTexture(widget.Image_Selected_Bg, "/Game/UMG/Texture_200/Lobby_NoAtlas/Common/Tab/Vertical/LevelOne/Text/Common_Tab_Vertical_LevelOne_Text_Button_02.Common_Tab_Vertical_LevelOne_Text_Button_02")
  if curSelectIndex == index then
    widget.TextBlock_Name:SetColorAndOpacity(FSlateColor(FLinearColor(0, 0, 0, 1)))
  else
    widget.TextBlock_Name:SetColorAndOpacity(FSlateColor(FLinearColor(1, 1, 1, 0.7)))
  end
  if next(self.CurrentReddotTable) then
    local PageData = self.Common_Tab_Page:GetTabData(index)
    local ReddotTable = self.CurrentReddotTable[PageData.Key]
    self:AddReddotOnTab(ReddotTable, widget.Reddot_Anchor.CanvasPanel_Anchor)
    if not ReddotTable then
      local leftoverChild = widget.Reddot_Anchor.CanvasPanel_Anchor:GetChildAt(0)
      if leftoverChild then
        log(bWriteLog and string.format("SettingUI:OnRefreshTab - hiding leftover reddot, index = %s, PageKey = %s", tostring(index), tostring(PageData.Key)))
        self:SetWidgetVisible(leftoverChild, false)
      end
    end
  end
end
function Setting_Main:OnRefreshTab_Category(widget, index)
  if next(self.CurrentReddotTable) then
    local PageData = self.Common_Tab_Page:GetTabData(self.Common_Tab_Page:GetSelectedTabIndex())
    if self.CurrentReddotTable[PageData.Key] then
      local CategoryKey = PageData.Category[index].Key
      local ReddotTable = self.CurrentReddotTable[PageData.Key][CategoryKey]
      self:AddReddotOnTab(ReddotTable, widget.CanvasPanel_Tab)
    end
  end
end
function Setting_Main:OnConsumeReddot(_, __, Key, Path)
  local Page = Path[1]
  local Category = Path[2]
  log(bWriteLog and string.format("SettingUI:OnConsumeReddot - Key = %s, Page = %s, Category = %s", tostring(Key), tostring(Page), tostring(Category)))
  if Page and Category then
    local t = self.CurrentReddotTable[Page][Category]
    t[Key] = nil
    if t and next(t) == "__ui" and next(t, "__ui") == nil then
      t.__ui:Close()
      t.__ui = nil
      self.CurrentReddotTable[Page][Category] = nil
    end
  end
  if Page then
    local t = self.CurrentReddotTable[Page]
    if not Category then
      t[Key] = nil
    end
    if t and next(t) == "__ui" and next(t, "__ui") == nil then
      t.__ui:Close()
      t.__ui = nil
      self.CurrentReddotTable[Page] = nil
    end
  end
end
function Setting_Main:AddReddotOnTab(ReddotTable, ParentWidget)
  if ReddotTable and not ReddotTable.__ui then
    log(bWriteLog and string.format("SettingUI:AddReddotOnTab  - creating new reddot UI"))
    local ReddotUI = self:CreateChildWindow(ParentWidget, UIManager.UI_Config.Setting_Reddot_New)
    ReddotUI:SetZOrder(1)
    ReddotTable.__ui = ReddotUI
  elseif ReddotTable and ReddotTable.__ui then
    if ReddotTable.__ui.UIRoot:GetParent() ~= ParentWidget then
      log(bWriteLog and string.format("SettingUI:AddReddotOnTab  - reparenting reddot UI to new ParentWidget"))
      ReddotTable.__ui.UIRoot:RemoveFromParent()
      ParentWidget:AddChild(ReddotTable.__ui.UIRoot)
      ReddotTable.__ui:SetOffsets(0, 0, 0, 0)
      ReddotTable.__ui:SetAnchors(0, 1, 0, 1)
      ReddotTable.__ui:SetZOrder(1)
    end
    log(bWriteLog and string.format("SettingUI:AddReddotOnTab - SelfHitTestInvisible"))
    ReddotTable.__ui:SelfHitTestInvisible()
  end
end
function Setting_Main:AddReddotOnStack(ReddotTable, StackContainer)
  local NewOptionKeyList
  for key, value in pairs(ReddotTable) do
    if type(value) ~= "table" then
      NewOptionKeyList = NewOptionKeyList or {}
      table.insert(NewOptionKeyList, key)
    end
  end
  if NewOptionKeyList then
    StackContainer:SetLoadedDelegate(function(UI)
      for Index, OptionKey in ipairs(NewOptionKeyList) do
        local ItemUI = UI:GetItemUI(OptionKey)
        if ItemUI then
          ItemUI:Decorate(UIManager.UI_Config.Setting_Decoration_New)
          if Index == 1 and UI.StackContainerWidget.ScrollWidgetIntoView then
            UI.StackContainerWidget:ScrollWidgetIntoView(ItemUI.UIRoot, true, 0)
          end
        end
      end
    end)
  end
end
function Setting_Main.CleanupInnerReddot(ReddotTable)
  for K, InnerTable in pairs(ReddotTable) do
    if K ~= "__ui" and type(InnerTable) == "table" then
      Setting_Main.CleanupInnerReddot(InnerTable)
      if InnerTable.__ui then
        InnerTable.__ui:Close()
        InnerTable.__ui = nil
      end
    end
  end
end
function Setting_Main:SwitchPage(PageKey, param)
  if self.Common_Tab_Page then
    if PageKey then
      local TabDataList = self.Common_Tab_Page:GetAllTabData()
      for Index, Page in ipairs(TabDataList) do
        if Page.Key == PageKey then
          self.Common_Tab_Page:SelectTab(Index)
          break
        end
      end
    else
      self.Common_Tab_Page:SelectTab(1)
    end
  else
    self._PendingOpen    self._PendingOpenPageParam = param
  end
end
function Setting_Main:GCSilently()
  if self._SilentGCTimer then
    self:RemoveTimer(self._SilentGCTimer)
  end
  self._SilentGCTimer = self:AddTimerOnce(3, gc_util.GCByMaxObjectOrMemory)
end
function Setting_Main:InitWhenSimulator()
  local isEmulatorNoChromeBook = Client.IsEmulatorWhenInit()
  if not isEmulatorNoChromeBook then
    return
  end
  local SettingUtil = require("client.slua.logic.setting.setting_util")
  local settingConfig = SettingUtil.GetSettingConfig()
  if not settingConfig.IsSimulatorFirstStartup then
    return
  end
  settingConfig.CameraLensSensibility = 4
  settingConfig.CamLensSenNoneSniper = 0.2
  settingConfig.CamLensSenRedDotSniper = 0.2
  settingConfig.CamLensSen2XSniper = 0.15
  settingConfig.CamLensSen4XSniper = 0.11
  settingConfig.CamLensSen8XSniper = 0.04
  settingConfig.FireCameraLensSensibility = 4
  settingConfig.FireCamLensSenNoneSniper = 0.2
  settingConfig.FireCamLensSenRedDotSniper = 0.2
  settingConfig.FireCamLensSen2XSniper = 0.17
  settingConfig.FireCamLensSen4XSniper = 0.11
  settingConfig.FireCamLensSen8XSniper = 0.08
  settingConfig.VehicleControlMode = 2
  settingConfig.IsSimulatorFirstStartup = false
end
function Setting_Main:InitRegionInfo()
  local data = DataMgr.RegionData
  local SettingAccount = require("client.logic.setting.logic_setting_account")
  if not data.region then
    SettingAccount.Setting_Region_Name = ""
    SettingAccount.Setting_Region_Set_Time = ""
    log(bWriteLog and "SettingUI:InitRegionInfo, region = " .. tostring(SettingAccount.Setting_Region_Name))
    log(bWriteLog and "SettingUI:InitRegionInfo, CD = " .. tostring(SettingAccount.Setting_Region_Set_Time))
    return
  end
  local regionConfig = CDataTable.GetTableData("RegionConfig", data.region)
  SettingAccount.Setting_Region_Name = regionConfig and regionConfig.RegionName or ""
  if not (data.setCount and data.setCD) or data.setCount == 0 and data.setTime == 0 then
    SettingAccount.Setting_Region_Set_Time = ""
  else
    local cdTime = data.setCD
    if 0 < cdTime and data.setTime then
      local TimeUtil = require("client.common.time_util")
      local now = TimeUtil.GetServerTimeInSec()
      local endTime = data.setTime + cdTime * 86400
      SettingAccount.Setting_Region_Set_Time = TimeUtil.GetTimeLengthStr(endTime - now)
    else
      SettingAccount.Setting_Region_Set_Time = ""
    end
  end
  log(bWriteLog and "SettingUI:InitRegionInfo, region = " .. tostring(SettingAccount.Setting_Region_Name))
  log(bWriteLog and "SettingUI:InitRegionInfo, CD = " .. tostring(SettingAccount.Setting_Region_Set_Time))
end
function Setting_Main:TLogDataCloseUI()
  if GameStatus.IsInFightingNotSocialNotMainCityNotHome() then
    return
  end
  local SettingHandler = require("client.network.Protocol.SettingHandler")
  if BP_Setting_Sensitivity_CountInfo then
    SettingHandler.send_gun_sensitivity_setting(1, BP_Setting_Sensitivity_CountInfo)
    BP_Setting_Sensitivity_CountInfo = nil
    BP_Setting_Sensitivity_CountInfo_Attr = nil
  end
  if BP_Setting_Accessories_CountInfo then
    SettingHandler.send_gun_accessories_setting(BP_Setting_Accessories_CountInfo)
    BP_Setting_Accessories_CountInfo = nil
    BP_Setting_Accessories_CountInfo_IndexInItem = nil
  end
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
return class(UIBase, nil, Setting_Main)