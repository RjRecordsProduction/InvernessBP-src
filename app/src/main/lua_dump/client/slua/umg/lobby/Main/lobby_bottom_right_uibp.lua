local lobby_bottom_right_uibp = {}
function lobby_bottom_right_uibp:ctor()
end
function lobby_bottom_right_uibp:RegistEvents()
  lobby_bottom_right_uibp.__super.RegistEvents(self)
  self:AddOnClickedEventByControl(self.UIRoot.Lobby_Main_Expression_UIBP.Button_0, self.ShowLobbyToyPanel, self)
  self:AddOnClickedEventByControl(self.UIRoot.Lobby_Main_Expression_UIBP.Button_1, self.HideLobbyToyPanel, self)
  self:AddOnClickedEventByControl(self.UIRoot.Lobby_Main_Expression_UIBP.Button_Overlay_Ainm_1, self.ShowPetAndPlayerExpressionPanel, self)
  self:AddOnClickedEventByControl(self.UIRoot.Lobby_Main_Expression_UIBP.Button_Overlay_Ainm_2, self.OnClickHideExpressionPanel, self)
  self:AddOnClickedEventByControl(self.UIRoot.Lobby_Main_Expression_UIBP.Button_SimpleUI, self.EnterSimpleUI, self)
  self:AddCommonEvent(EVENTTYPE_MOTION, EVENTID_MOTION_CLOSE_EXPERSSION_UI, self.HidePetAndPlayerExpressionPanel, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY_TOY, EVENTID_LOBBY_TOY_PANEL_CLOSE, self.OnLobbyToyPanelClose, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_PUT_ON_DATA, self.OnRefreshGuide, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_CREATE_LOBBY_AVATAR, self.OnRefreshGuide, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_UPDATE_PUT_DOWN_DATA, self.OnRefreshGuide, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_SWITCH_USE_ROLEWEAR, self.OnRefreshGuide, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_CAR_GUIDE_VISIBLE_CHANGE, self.OnRefreshGuide, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_LOBBY_EXPRESSION_REDDOT, self.OnExpressionReddotRefresh, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_SHOW_LOBBY, self.OnShowLobbyUI, self)
end
function lobby_bottom_right_uibp:OnPostInitialize()
  lobby_bottom_right_uibp.__super.OnPostInitialize(self)
  local LobbyEmoteManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyEmoteManager)
  LobbyEmoteManager:ReqSelfMileStoneData()
  self:UpdateUI()
end
function lobby_bottom_right_uibp:OnShow()
  lobby_bottom_right_uibp.__super.OnShow(self)
  self:resetPetAndPlayerExpressionPanel()
  self:SetButtonVisible()
  self:AddTimerOnce(3, function()
    self:ShowChangeFormGuide()
  end)
  local xmission_main = UIManager.GetUI(UIManager.UI_Config.xmission_main)
  if xmission_main and xmission_main:IsShow() then
    self:SetWidgetVisible(self.UIRoot.Lobby_Main_Expression_UIBP.Button_SimpleUI, false)
  end
end
function lobby_bottom_right_uibp:OnShowLobbyUI()
  self:ShowMileStoneGuide()
  self:ShowCardCollectionAction()
end
function lobby_bottom_right_uibp:UpdateUI()
  self:RefreshReddot()
end
function lobby_bottom_right_uibp:SetButtonVisible()
  local charSwitch = LobbySystem.CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_EXPRESSION, false)
  if charSwitch then
    self.UIRoot.Lobby_Main_Expression_UIBP:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot.Lobby_Main_Expression_UIBP:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function lobby_bottom_right_uibp:ShowLobbyToyPanel()
  self:PlayAudio(sound_config.popup_v1)
  self.UIRoot.Lobby_Main_Expression_UIBP.WidgetSwitcher_FunProp:SetActiveWidgetIndex(1)
  local Expression_Util = require("client.slua.umg.Souvenirs.Expression_Util")
  Expression_Util.OpenFunPropListUI()
  self:SetWidgetVisible(self.UIRoot.Lobby_Main_Expression_UIBP.CanvasPanel_8, false, false)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N({show = true}, PlayerPrefsSystem.ePlayerPrefsType.eLobbyPaintSHowTips)
end
function lobby_bottom_right_uibp:HideLobbyToyPanel()
  self:PlayAudio(sound_config.popup_v1)
  self.UIRoot.Lobby_Main_Expression_UIBP.WidgetSwitcher_FunProp:SetActiveWidgetIndex(0)
  local Expression_Util = require("client.slua.umg.Souvenirs.Expression_Util")
  Expression_Util.CloseFunPropListUI()
end
function lobby_bottom_right_uibp:OnLobbyToyPanelClose()
  log(bWriteLog and "lobby_bottom_right_uibp:OnLobbyToyPanelClose")
  self.UIRoot.Lobby_Main_Expression_UIBP.WidgetSwitcher_FunProp:SetActiveWidgetIndex(0)
end
function lobby_bottom_right_uibp:ShowPetAndPlayerExpressionPanel(actionID)
  self:PlayAudio(sound_config.popup_v1)
  local LogicTeamUpSideBar = require("client.slua.logic.lobby.logic_teamup_side_bar")
  LogicTeamUpSideBar.CloseTeamUpSideBar()
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.LobbyExpression)
  local Expression_Util = require("client.slua.umg.Souvenirs.Expression_Util")
  Expression_Util.OpenExpressionPopUI(actionID)
  if not slua.isValid(self.UIRoot) then
    return
  end
  self.UIRoot.Lobby_Main_Expression_UIBP.WidgetSwitcher_Ainm:SetActiveWidgetIndex(1)
  self:UpdateGuideState()
  self:SetWidgetVisible(self.UIRoot.Lobby_Main_Expression_UIBP.CanvasPanel_LookbackGuide, false, false)
end
function lobby_bottom_right_uibp:OnClickHideExpressionPanel()
  self:PlayAudio(sound_config.click)
  self:HidePetAndPlayerExpressionPanel()
end
function lobby_bottom_right_uibp:HidePetAndPlayerExpressionPanel()
  self.UIRoot.Lobby_Main_Expression_UIBP.WidgetSwitcher_Ainm:SetActiveWidgetIndex(0)
end
function lobby_bottom_right_uibp:EnterSimpleUI()
  self:PlayAudio(sound_config.click)
  log(bWriteLog and "[wzp]lobby_bottom_right_uibp:EnterSimpleUI start")
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.LobbyBottomRightBtnSimpleUI)
  UIManager.ShowUI(UIManager.UI_Config.Lobby_SimpleUI_Main_UIBP)
  ShowNotice(62513)
  local UIUtil = require("client.common.ui_util")
  UIUtil.ShowLobbyUI(false)
end
function lobby_bottom_right_uibp:resetPetAndPlayerExpressionPanel()
  self.UIRoot.Lobby_Main_Expression_UIBP.WidgetSwitcher_Ainm:SetActiveWidgetIndex(0)
end
function lobby_bottom_right_uibp:OnRefreshGuide(_, __, CurrentIndex)
  self:ShowChangeFormGuide()
end
function lobby_bottom_right_uibp:RefreshReddot()
  log(bWriteLog and "lobby_bottom_right_uibp:RefreshReddot")
  self:OnExpressionReddotRefresh()
end
function lobby_bottom_right_uibp:OnExpressionReddotRefresh()
  log(bWriteLog and "lobby_bottom_right_uibp:OnExpressionReddotRefresh")
  local bShow = false
  local bShowSouvenirsReddot
  local logic_lobby_souvenirs = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lobby_souvenirs)
  bShowSouvenirsReddot = logic_lobby_souvenirs:GetExpressionReddotShow()
  bShow = bShowSouvenirsReddot
  log(bWriteLog and "lobby_bottom_right_uibp:OnExpressionReddotRefresh : " .. tostring(bShow))
  self:SetWidgetVisible(self.UIRoot.Lobby_Main_Expression_UIBP.Reddot_Anchor_Item01, bShow)
end
function lobby_bottom_right_uibp:ShowChangeFormGuide()
  local DragonChangeForm = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.DragonChangeForm)
  local guideState = DragonChangeForm:GetGuideState()
  local logic_player_return_login = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_player_return_login)
  local isReturnLimit = logic_player_return_login:CheckIsFirstDayLimit()
  local bShow = guideState and not isReturnLimit
  log_format("lobby_bottom_right_uibp:ShowChangeFormGuide guideState = %s, isReturnLimit = %s", guideState, isReturnLimit)
  self.UIRoot.Lobby_Main_Expression_UIBP.TextBlock_LookbackTips:SetText(LocUtil.GetLocalizeResStr(49720))
  self:SetWidgetVisible(self.UIRoot.Lobby_Main_Expression_UIBP.CanvasPanel_LookbackGuide, bShow, false)
  if bShow then
    DragonChangeForm:UpdateShowGuideNum()
  end
end
function lobby_bottom_right_uibp:ShowLobbyToyGuide()
  local logic_player_return = require("client.slua.logic.player_return.logic_player_return")
  local isReturn = logic_player_return.isPlayerReturnOpenNew()
  local logic_backuser_tips_mutex = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_backuser_tips_mutex)
  if isReturn then
    local tip_id = logic_backuser_tips_mutex:GetTip()
    if tip_id ~= logic_backuser_tips_mutex.tips_id.LobbyToyGuide then
      return
    end
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eLobbyPaintSHowTips)
  local bShow = true
  if data and data.show then
    bShow = false
  end
  local level_unlock_util = require("client.logic.level_unlock.util.level_unlock_util")
  local bHaveLockedFeature = level_unlock_util:HaveLockedFeature()
  log(bWriteLog and "lobby_bottom_right_uibp:ShowLobbyToyGuide bHaveLockedFeature = " .. tostring(bHaveLockedFeature))
  if bHaveLockedFeature then
    bShow = false
  end
  local logic_xmission_main = require("client.slua.logic.TxMission.logic_xmission_main")
  if logic_xmission_main.IsInXMission() then
    bShow = false
  end
  self.UIRoot.Lobby_Main_Expression_UIBP.TextBlock_0:SetText(LocUtil.GetLocalizeResStr(76749))
  self:SetWidgetVisible(self.UIRoot.Lobby_Main_Expression_UIBP.CanvasPanel_8, bShow, false)
end
function lobby_bottom_right_uibp:ShowMileStoneGuide()
  log(bWriteLog and "lobby_bottom_right_uibp:ShowMileStoneGuide")
  local LobbyEmoteManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyEmoteManager)
  if not LobbyEmoteManager:NeedShowMileStoneNewBie() then
    log(bWriteLog and "lobby_bottom_right_uibp:ShowMileStoneGuide Don`t Need Show")
    return
  end
  local logic_player_return_login = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_player_return_login)
  if logic_player_return_login:CheckIsFirstDayLimit() then
    log(bWriteLog and "lobby_bottom_right_uibp:ShowMileStoneGuide Return First Day Limit")
    return
  end
  self.UIRoot.Lobby_Main_Expression_UIBP.TextBlock_LookbackTips:SetText(LocUtil.GetLocalizeResStr(77522))
  self:SetWidgetVisible(self.UIRoot.Lobby_Main_Expression_UIBP.CanvasPanel_LookbackGuide, true, false)
  LobbyEmoteManager:RecordHasShowMileStoneNewBie()
  self:AddTimerOnce(5, function()
    log(bWriteLog and "lobby_bottom_right_uibp:ShowMileStoneGuide Hide Guide")
    self:SetWidgetVisible(self.UIRoot.Lobby_Main_Expression_UIBP.CanvasPanel_LookbackGuide, false, false)
  end)
end
function lobby_bottom_right_uibp:ShowCardCollectionAction()
  local logic_card_collection = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_card_collection)
  self:AddTimerOnce(1, function()
    if logic_card_collection:CheckToLobbyFlag() then
      self:ShowPetAndPlayerExpressionPanel(logic_card_collection:GetActionItemID())
    end
  end)
end
function lobby_bottom_right_uibp:UpdateGuideState()
  local state = self.UIRoot.Lobby_Main_Expression_UIBP.CanvasPanel_LookbackGuide:GetVisibility()
  if state == UEnums.ESlateVisibility.Collapsed then
    return
  end
  local DragonChangeForm = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.DragonChangeForm)
  DragonChangeForm:UpdateGuideState(1)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local Clobby_bottom_right_uibp = class(ui_base, nil, lobby_bottom_right_uibp)
return Clobby_bottom_right_uibp