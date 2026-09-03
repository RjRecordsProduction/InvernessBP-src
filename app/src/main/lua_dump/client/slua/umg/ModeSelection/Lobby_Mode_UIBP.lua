local Lobby_Mode_UIBP = {}
function Lobby_Mode_UIBP:ctor()
  self.hasShowUGCDownloadGuide = false
  self.DelayRefreshThemeExchangeReddotUITimer = nil
  self.DelayUpdateUITimer = nil
  self.bPreLoadTable = false
  self.specialPlayActivityCfg = nil
  self.specialPlayCfg = nil
end
function Lobby_Mode_UIBP:OnInitialize()
  Lobby_Mode_UIBP.__super.OnInitialize(self)
  self.util = require("client.slua_ui_framework.util")
  self.Text_MapName = self.UIRoot.Text_MapName
  self.Image_Mode_PlayerCnt = self.UIRoot.Image_Mode_PlayerCnt
  self.Text_PerspectiveType = self.UIRoot.Text_PerspectiveType
  self.TextBlock_0 = self.UIRoot.TextBlock_0
end
function Lobby_Mode_UIBP:RegistEvents()
  Lobby_Mode_UIBP.__super.RegistEvents(self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Enter, self.OnButton_EnterClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Tips_ChangeMode, self.OnButton_Tips_ChangeModeClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_RankLimitTip, self.OnButtonTipClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_ModeLock, self.OnModeRestrictClick, self)
  self:AddOnCheckStateChangedEventByControl(self.UIRoot.CheckBox_CrossMatch, self.OnClickCheckBox_CrossMatch, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_TeamStatus, self.OnButton_TeamStatusClick, self)
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_MATCH_MODE_SELECT_CHANGE, self.OnModeChange, self)
  self:AddCommonEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_INFO, self.UpdateActivityMode, self)
  self:AddCommonEvent(EVENTTYPE_LEVEL_UNLOCK, EVENTID_LEVEL_UNLOCK_END_MODE_GUIDE, self.HideLevelUnlockGuide, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_SWITCHTO_PAGE_START, self.OnSwitchToPageStart, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_SWITCHTO_PAGE_END, self.OnSwitchToPageEnd, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CHECK_TEAM_STATE, self.OnCheckTeamMatchState, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_NEW_TEAM_MATCH_MODE, self.CheckAbnormalStatusShow, self)
  self:AddCommonEvent(EVENTTYPE_PUFFER, EVENTID_PUFFER_DOWNLOADFINISH, self.OnMapDownloadFinish, self)
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_MATCH_UPDATE_STATUS, self.OnUpdateMatchStatus, self)
  self:AddCommonEvent(EVENTTYPE_STATE, EVENTID_ON_MODE_PRE_SWITCH, self.CloseSelf, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_CHANGE_MOD_NOTIFY, self.OnUGCModeChange, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_GET_MOD_BATCH, self.OnNotifyReqModInfoSuccess, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_NOTIFY_THEME_FLASH, self.ShowFlashAnimation, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_NOTIFY_THEME_RES_INFO, self.UpdateModResState, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_NOTIFY_OTHER_FINISH, self.UpdateModResState, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_SELECT_MOD, self.UpdateModResState, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Collection, self.OnButton_EnterClick, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_MULTI_BUNDLE, self.OnUpdateUI, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_MULTI_DOWNLOAD_STATE, self.UpdateUGCMultiResState, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_UPDATE_AUTHOR, self.OnUpdateUI, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_SELECT_RANDOM_RECOMMEND_CHANGE, self.OnUpdateUI, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_RANDOM_RECOMMEND_DATA_READY, self.OnUpdateUI, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_HOTTHEME_LIST_MODINFO_RSP, self.OnUpdateUI, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_MIXEDBANNER_UPDATE, self.OnUpdateUI, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_GET_MINE_MODS, self.OnUpdateUI, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_BATCH_REQUESTCOLLECTION_META, self.OnUpdateUI, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_SEASON_GET_MOD_LIST, self.OnUpdateUI, self)
  self:AddCommonEvent(EVENTTYPE_LOGIN, EVENTID_QR_LOGIN_QRCODE_RESTRICT_CHANGE, self.OnQRCodeRestrictChange, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_GET_SEASON_CONFIG, self.OnUpdateUGCSeaonMod, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CHANGE_MATCH_STRATEGY_NOTIFY, self.OnChangeMatchStrategyNotify, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_BE_KICKED_OUT, self.OnQuit, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_EXIT_OTHER_PLAYER, self.OnExitMember, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CHANGE_LEADER_NOTIFY, self.OnTeamChangeLeader, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CROSS_MATCH_NOTIFY, self.OnCrossMatchNotify, self)
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_MATCH_ASYM_INFO_CHANGE, self.SetAsymmetricInfo, self)
  self:AddCommonEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAIN_CITY_RETURN_TO_LOBBY, self.OnMainCityReturnToLobby, self)
  self:AddCommonEvent(EVENTTYPE_DOUBLECARD, EVENTID_TDM_PROTECT_INFO_RSP, self.SetTDMProtectInfo, self)
  self:AddCommonEvent(EVENTTYPE_DOWNLOAD, EVENTID_PUFFER_DELETE_SUCCESS, self.OnMapResDeleted, self)
  self:AddCommonEvent(EVENTTYPE_LOGIN, EVENTID_LOGIN_SUCCESS, self.OnReLogin, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_ON_PSSKILL_SPRINT_ROLE_UPDATE, self.UpdatePSSkillSprint, self)
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_ON_MATCH_RES_OK, self.ShowSpecialPlayPanel, self)
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_ON_CANCEL_MATCH_RES_OK, self.ShowSpecialPlayPanel, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_PLAY_HALL_ROOM_EXIT_ALL, self.ShowSpecialPlayPanel, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Search, self.OnButton_UGCModClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_SearchCompilation, self.OnButton_UGCModClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_SpecialPlay, self.Button_SpecialPlayClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_PSSkillSprint, self.Button_PSSkillSprintClick, self)
end
function Lobby_Mode_UIBP:OnMainCityReturnToLobby()
  log(bWriteLog and "Lobby_Mode_UIBP:OnMainCityReturnToLobby")
  self:DelayRefreshThemeExchangeReddotUI()
end
function Lobby_Mode_UIBP:OnMapResDeleted()
  log(bWriteLog and "Lobby_Mode_UIBP:OnMapResDeleted")
  self:DelayUpdateUI()
end
function Lobby_Mode_UIBP:OnReLogin()
  log(bWriteLog and "Lobby_Mode_UIBP:OnReLogin")
  self:DelayUpdateUI()
end
function Lobby_Mode_UIBP:OnPostInitialize()
  Lobby_Mode_UIBP.__super.OnPostInitialize(self)
  self:HideUI()
  self:DelayUpdateUI()
  self:HideLevelUnlockGuide()
  local UIComponentModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.UIComponentModule)
  self.NewSkillLobbyEntrance = UIComponentModule:InitWithoutParentComponent(UIComponentModule.Config.NewSkillLobbyEntrance, self.UIRoot)
  self:DelayRefreshThemeExchangeReddotUI()
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Qualifying_Rounds, true)
  local logic_promotion_mode = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_promotion_mode)
  logic_promotion_mode:InitQualifyingItemByWidget(self, self.UIRoot.Common_Qualifying_Rounds_Item_UIBP)
  local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
  local data_config_marco = require("client.logic.data.data_config_marco")
  BasicDataServerTable:GetOrReqData(data_config_marco.lobby_banner_cfg, function(table_name, data)
    if self and slua.isValid(self.UIRoot) then
      self.specialPlayCfg = data
      self:SpecialPlayUIUpdate(table_name, data)
    end
  end)
end
local _teamIconMap = {
  [1] = "/Game/UMG/Texture/Atlas/Lobby_Match/Frames/LOBBY_Icon_siren1_png.LOBBY_Icon_siren1_png",
  [2] = "/Game/UMG/Texture/Atlas/Lobby_Match/Frames/LOBBY_Icon_siren3_png.LOBBY_Icon_siren3_png",
  [3] = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Person_3_png.Common_Icon_Person_3_png",
  [4] = "/Game/UMG/Texture/Atlas/Lobby_Match/Frames/LOBBY_Icon_siren_png.LOBBY_Icon_siren_png"
}
function Lobby_Mode_UIBP:GetTeamIcon(num)
  local icon = _teamIconMap[num]
  if icon == nil then
    icon = _teamIconMap[4]
  end
  return icon
end
function Lobby_Mode_UIBP:SetTipsBarVisibility(TipsBarWidget, Visibility)
  if not TipsBarWidget then
    log_warning("Lobby_Mode_UIBP:SetTipsBarVisibility TipsBarWidget is nil")
    return
  end
  TipsBarWidget:SetWidgetVisibility(Visibility)
  if Visibility == UEnums.ESlateVisibility.Visible or Visibility == UEnums.ESlateVisibility.SelfHitTestInvisible or Visibility == UEnums.ESlateVisibility.HitTestInvisible then
    EventSystem:postEvent(EVENTTYPE_SKILL_SELECTION, EVENTID_SKILL_SELECTION_MODE_OTHER_TIPS_SHOW)
  else
    EventSystem:postEvent(EVENTTYPE_SKILL_SELECTION, EVENTID_SKILL_SELECTION_MODE_OTHER_TIPS_HIDE)
  end
  self:ShowSpecialPlayPanel()
end
function Lobby_Mode_UIBP:OnModeChange()
  self:DelayUpdateUI(function()
    self:PlayUserWidgetAnimation(self.UIRoot.Animation_Seletion, 0, 1, 0, 1)
  end)
  self:CheckReturnMatchTips()
end
function Lobby_Mode_UIBP:OnUGCModeChange(_, _, isChange)
  log(bWriteLog and "[edward] Lobby_Mode_UIBP:OnUGCModeChange isChange = " .. tostring(isChange))
  if not isChange then
    return
  end
  self:OnModeChange()
  self:CheckReportResState()
end
function Lobby_Mode_UIBP:CheckIsMetroTxMissionMode()
  local logic_mode_selection_for_umg = require("client.slua.logic.mode_selection.logic_mode_selection_for_umg")
  self.isMTModel = logic_mode_selection_for_umg.CheckIsMetroTxMissionMode(self)
end
function Lobby_Mode_UIBP:HideUI()
  self:SetWidgetVisible(self.UIRoot.WidgetSwitcher_Mode, false)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Plant, false)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_SpecialPlay, false)
end
function Lobby_Mode_UIBP:DelayUpdateUI(fCallback)
  log(bWriteLog and "Lobby_Mode_UIBP:DelayUpdateUI")
  if self.DelayUpdateUITimer then
    self:RemoveTimer(self.DelayUpdateUITimer)
    self.DelayUpdateUITimer = nil
  end
  self.DelayUpdateUITimer = self:AddTimerOnce(0, function()
    self:SetWidgetVisible(self.UIRoot.WidgetSwitcher_Mode, true)
    if fCallback then
      fCallback()
    end
    self:UpdateUI()
  end)
end
function Lobby_Mode_UIBP:UpdateUI()
  self:CheckIsMetroTxMissionMode()
  self:SetTDMProtectInfo()
  self:UpdatePSSkillSprint()
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_RankLimit, false)
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  local hasUGCMatchInfo = LogicUGCMatch:HasUGCMatchInfo()
  log(bWriteLog and "Lobby_Mode_UIBP:UpdateUI " .. tostring(hasUGCMatchInfo))
  log(bWriteLog and "Lobby_Mode_UIBP:UpdateUI self.isMTModel = " .. tostring(self.isMTModel))
  self:SetWidgetVisible(self.UIRoot.SizeBox_SearchCompilation, false, true)
  self:SetWidgetVisible(self.UIRoot.SizeBox_Search, false, true)
  self:SetWidgetVisible(self.UIRoot.SizeBox_Icon, false)
  self:SetWidgetVisible(self.UIRoot.SizeBox_Icon1, false)
  if hasUGCMatchInfo and not self.isMTModel then
    self:UpdateUIForUGC()
    self:UpdateActivityMode()
    self:OnSwitchToPageEnd()
    self:UpdateUgcMulti()
    self:UpdateRestrictState()
    self:RefreshThemeEntrance()
    return
  else
    local UGCPlayHallRoom = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.UGCPlayHallRoom)
    UGCPlayHallRoom:ClearMapHotStatReqTimerTick()
  end
  self.UIRoot.WidgetSwitcher_1:SetActiveWidgetIndex(0)
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local modeid, viewid, viewIds = logic_mode_selection:GetCurSelectInfo()
  if not modeid then
    log_warning(bWriteLog and "Lobby_Mode_UIBP:UpdateUI modeid is nil")
    return
  end
  self:UpdateRestrictState()
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local filterInfo = logic_mode_selection:GetFilterInfo()
  self:UpdatePerspectiveAndTeamNum(filterInfo)
  self:SetBgImgAndTextByViewId(viewid, viewIds)
  self:UpdateActivityMode()
  self:OnSwitchToPageEnd()
  self:UpdateUgcMulti()
  self:RefreshThemeEntrance()
  self:SetAsymmetricInfo()
  self:ShowSpecialPlayPanel()
  self:CheckReturnMatchTips()
  self:CheckAbnormalStatusShow()
end
function Lobby_Mode_UIBP:UpdatePerspectiveAndTeamNum(filterInfo)
  self.UIRoot.HorizontalBox_0:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self.UIRoot.Image_1:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self.UIRoot.Text_PerspectiveType:SetText(LocUtil.LocalizeResFormat(filterInfo.perspective))
  self.UIRoot.TextBlock_Pers:SetText(LocUtil.LocalizeResFormat(filterInfo.perspective))
  self:SetTexture(self.UIRoot.Image_Mode_PlayerCnt, self:GetTeamIcon(filterInfo.teamNum), {sync = false})
  if filterInfo.teamNum < 0 then
    self.UIRoot.TextBlock_TeamCnt:SetText("")
  else
    self.UIRoot.TextBlock_TeamCnt:SetText(filterInfo.teamNum)
  end
  self:SetTexture(self.UIRoot.Image_Team, self:GetTeamIcon(filterInfo.teamNum), {sync = false})
end
function Lobby_Mode_UIBP:UpdateRestrictState()
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  local isRestrict = QRcodeRestrictManager:IsRestrictBatlleAll()
  self:SetWidgetVisible(self.UIRoot.Button_ModeLock, isRestrict, true)
end
function Lobby_Mode_UIBP:UpdateUIForUGC()
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  local editMatchInfo = LogicUGCMatch:GetEditMatchInfo()
  if editMatchInfo then
    self:UpdateEditMatchUIForUGC(editMatchInfo)
  else
    self:UpdateMatchUIForUGC(LogicUGCMatch:GetMatchInfo())
  end
  self:SetWidgetVisible(self.UIRoot.SizeBox_Search, true, true)
  local UGCPlayHallRoom = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.UGCPlayHallRoom)
  if UGCPlayHallRoom:IsSystemOpen() then
    UGCPlayHallRoom:CreateMapHotStatReqTimerTick()
  end
end
function Lobby_Mode_UIBP:UpdateEditMatchUIForUGC(editMatchInfo)
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  local editMatchInfo = LogicUGCMatch:GetEditMatchInfo() or {}
  local root = self.UIRoot
  root.HorizontalBox_0:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  root.Image_1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  root.Text_ModelName:SetText(LocUtil.GetLocalizeResStr(70122))
  root.TextBlock_Mode:SetText(LocUtil.LocalizeResFormat(12918, editMatchInfo.name or ""))
  root.Text_MapName:SetText(editMatchInfo.name or "")
  if root.CanvasPanel_loading then
    self:SetWidgetVisible(root.CanvasPanel_loading, true)
    root:PlayUserWidgetAnimation(root.Animation_LoadingLoop, 0, 0, 0, 1)
  end
  local Util_UGC = require("client.slua.logic.ugc.util_ugc")
  local callback = function()
    if root.CanvasPanel_loading then
      self:SetWidgetVisible(root.CanvasPanel_loading, false)
      root:StopAnimation(root.Animation_LoadingLoop)
    end
  end
  local url = editMatchInfo.thumb_info.thumb_url or ""
  if url == "" then
    local Config_UGC = require("client.slua.logic.ugc.config_ugc")
    local config = Config_UGC.GetTemplateConfigByID(editMatchInfo.template_id)
    if config then
      url = config.BgImage
    end
  else
    url = editMatchInfo.thumb_info.thumb_url
  end
  self:SetWidgetVisible(root.Image_BG_UGC, true)
  self:SetWidgetVisible(root.Image_BG, false)
  local image_download_mgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.image_download_mgr)
  local DiskCacheTypeEnum = image_download_mgr:GetDiskCacheTypeEnum()
  Util_UGC.SetUGCImage(self, root.Image_BG_UGC, url, false, callback, nil, DiskCacheTypeEnum.NeverDelete)
end
function Lobby_Mode_UIBP:UpdateMatchUIForUGC(matchInfo)
  local root = self.UIRoot
  local perspective = matchInfo.perspective or ENUM_PerspectiveType.TPP
  local perspectiveStr = LocUtil.LocalizeResFormat(perspective)
  root.Text_PerspectiveType:SetText(perspectiveStr)
  root.TextBlock_Pers:SetText(perspectiveStr)
  root.HorizontalBox_0:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  root.Image_1:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  local teamSize = matchInfo.setting.team_size or 1
  if teamSize < 0 then
    root.TextBlock_TeamCnt:SetText("")
  else
    root.TextBlock_TeamCnt:SetText(teamSize)
  end
  local teamIcon = self:GetTeamIcon(teamSize)
  self:SetTexture(root.Image_Mode_PlayerCnt, teamIcon)
  self:SetTexture(root.Image_Team, teamIcon)
  root.Text_ModelName:SetText(LocUtil.GetLocalizeResStr(70063))
  root.TextBlock_Mode:SetText(LocUtil.LocalizeResFormat(12918, matchInfo.setting.name))
  root.Text_MapName:SetText(matchInfo.setting.name)
  if root.CanvasPanel_loading then
    self:SetWidgetVisible(root.CanvasPanel_loading, true)
    root:PlayUserWidgetAnimation(root.Animation_LoadingLoop, 0, 0, 0, 1)
  end
  local Util_UGC = require("client.slua.logic.ugc.util_ugc")
  local callback = function()
    if root.CanvasPanel_loading then
      self:SetWidgetVisible(root.CanvasPanel_loading, false)
      root:StopAnimation(root.Animation_LoadingLoop)
    end
  end
  self:SetWidgetVisible(root.Image_BG_UGC, true)
  self:SetWidgetVisible(root.Image_BG, false)
  local url = Util_UGC.GetCoverImageUrl(matchInfo.setting, matchInfo.template_id, false)
  local image_download_mgr = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.image_download_mgr)
  local DiskCacheTypeEnum = image_download_mgr:GetDiskCacheTypeEnum()
  Util_UGC.SetUGCImage(self, root.Image_BG_UGC, url, false, callback, nil, DiskCacheTypeEnum.NeverDelete)
end
function Lobby_Mode_UIBP:UpdateUgcMulti()
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_UGC_Multi, false)
  self.UIRoot.WidgetSwitcher_1:SetActiveWidgetIndex(0)
  self.UIRoot.TextBlock_11:SetText("")
  local LogicUGCMulti = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMulti)
  local bIsBundleMatch = LogicUGCMulti.bIsBundleMatch
  if not bIsBundleMatch then
    return
  end
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  self:SetWidgetVisible(self.UIRoot.SizeBox_SearchCompilation, true, true)
  self:SetWidgetVisible(self.UIRoot.SizeBox_Search, true)
  self:SetWidgetVisible(self.UIRoot.SizeBox_SearchCompilation, true)
  self.UIRoot.WidgetSwitcher_1:SetActiveWidgetIndex(1)
  self.UIRoot.WidgetSwitcher_Mod:SetActiveWidgetIndex(0)
  self.UIRoot.TextBlock_WOW:SetText(LocUtil.GetLocalizeResStr(70063))
  self.UIRoot.TextBlock_11:SetText(LogicUGCMulti:GetSelectBundleName())
  self.UIRoot.UTRichTextBlock_MapSelected:SetText(LocUtil.LocalizeResFormat(48974, LogicUGCMulti:GetSelectBundleModCount()))
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  local LogicUGCMulti = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMulti)
  self:SetWidgetVisible(self.UIRoot.Image_13, LogicUGCMulti.BundleType ~= Config_UGC.Enum_Bundle_Type.Season)
  local CoverPath, bIsLocal = LogicUGCMulti:GetSelectBundlePic()
  if bIsLocal then
    self:SetTexture(self.UIRoot.Image_Mod, CoverPath)
  else
    local Util_UGC = require("client.slua.logic.ugc.util_ugc")
    Util_UGC.SetUGCCollectionsImage(self, self.UIRoot.Image_Mod, CoverPath)
  end
  self:UpdateUGCMultiResState()
end
function Lobby_Mode_UIBP:UpdateUGCMultiResState()
  log(bWriteLog and "Lobby_Mode_UIBP:UpdateUGCMultiResState")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local LogicUGCMulti = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMulti)
  local state, cSize, tSize = LogicUGCMulti:GetResState()
  if state == PufferConst.ENUM_DownloadState.Done then
    self.UIRoot.WidgetSwitcher_Mod:SetActiveWidgetIndex(0)
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_UGCDownloadGuide, false)
    self:CheckAbnormalStatusShow()
  else
    if state == PufferConst.ENUM_DownloadState.Download then
      self.UIRoot.WidgetSwitcher_Mod:SetActiveWidgetIndex(1)
    else
      self.UIRoot.WidgetSwitcher_Mod:SetActiveWidgetIndex(0)
    end
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    if TeamUpNewSystem.IsInTeam() then
      self:CheckAbnormalStatusShow()
    elseif self.UIRoot.CanvasPanel_TeamStatus then
      self:SetWidgetVisible(self.UIRoot.CanvasPanel_TeamStatus, true)
      local LeftSize = string.format("%.1f", math.max(tSize - cSize, 0.1))
      self.UIRoot.UTRichTextBlock_Text:SetText(LocUtil.LocalizeResFormat(48498, LeftSize))
      self.UIRoot.WidgetSwitcher_Status:SetActiveWidgetIndex(0)
      log(bWriteLog and "Lobby_Mode_UIBP:UpdateUGCMultiResState show bundle map not downloaded (solo)")
    end
    self:CheckShowUGCDownloadGuide()
  end
  self:ShowSpecialPlayPanel()
end
function Lobby_Mode_UIBP:UpdateModResState()
  log(bWriteLog and "Lobby_Mode_UIBP:UpdateModResState")
  local LogicUGCMulti = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMulti)
  if LogicUGCMulti.bIsBundleMatch then
    return
  end
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  if not LogicUGCMatch:HasUGCMatchInfo() then
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.IsInTeam() then
    local state = self:GetUgcModResState()
    if state == false then
      self:CheckShowUGCDownloadGuide()
    elseif state == true then
      self:SetWidgetVisible(self.UIRoot.CanvasPanel_UGCDownloadGuide, false)
    end
    self:CheckAbnormalStatusShow()
    self:ShowSpecialPlayPanel()
    return
  end
  self:CheckAbnormalStatusShow()
  self:ShowSpecialPlayPanel()
end
function Lobby_Mode_UIBP:OnClickUGCResStateBtn()
  local modInfo = self:GetUgcModInfo()
  if modInfo then
    local state = self:GetUgcModResState()
    if state == false then
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      local title = LocUtil.GetLocalizeResStr(5077)
      local downloadBtn = LocUtil.GetLocalizeResStr(7420)
      local resManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCResManager)
      local cSize, tSize = resManager:GetResSize(resManager.DownloaderType.ModCopy, modInfo)
      if cSize < 0 then
        cSize = 0
      end
      if tSize < 0.1 then
        tSize = 0.1
      end
      local cSizeStr = string.format("%.1f", cSize)
      local tSizeStr = string.format("%.1f", tSize)
      local content = LocUtil.LocalizeResFormat(512020, cSizeStr, tSizeStr)
      CommonMsgBoxMgr.Show(CommonMsgBoxMgr.SHOW_TYPE_TWO, title, content, function()
        if modInfo.mod_id and modInfo.mod_id > 0 then
          resManager:DownloadRes(resManager.DownloaderType.ModCopy, modInfo)
        else
          resManager:DownloadRes(resManager.DownloaderType.MyWork, modInfo)
        end
      end, nil, downloadBtn)
    elseif state == true then
      local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
      if TeamUpNewSystem.IsTeamLeader() then
        local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
        local title = LocUtil.GetLocalizeResStr(5077)
        local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
        local content = LogicUGC:GetUgcChooseModNoMapUidsStr(modInfo.mod_id)
        CommonMsgBoxMgr.Show(CommonMsgBoxMgr.SHOW_TYPE_ONE, title, content)
      end
    end
  end
end
function Lobby_Mode_UIBP:OnClickUGCMultiResStateBtn()
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local LogicUGCMulti = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMulti)
  local state, cSize, tSize = LogicUGCMulti:GetResState()
  if state == PufferConst.ENUM_DownloadState.Done then
    log(bWriteLog and "Lobby_Mode_UIBP:OnClickUGCMultiResStateBtn done")
    return
  end
  local title = LocUtil.GetLocalizeResStr(5077)
  local downloadBtn = LocUtil.GetLocalizeResStr(7420)
  local content = LocUtil.LocalizeResFormat(63000, string.format("%.1f", math.max(tSize - cSize, 0.1)))
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(CommonMsgBoxMgr.SHOW_TYPE_FOUR, title, content, function()
    LogicUGCMulti:DownloadMultiModList()
  end, nil, downloadBtn)
end
function Lobby_Mode_UIBP:GetUgcModInfo()
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  local matchInfo = LogicUGCMatch:GetMatchInfo()
  if matchInfo == nil then
    return nil
  end
  local modId = matchInfo.mod_id
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local cacheMod = LogicUGC:GetModByAllCache(modId)
  if cacheMod and cacheMod.pub_mod_meta then
    return cacheMod.pub_mod_meta
  end
  return nil
end
function Lobby_Mode_UIBP:GetUgcModResState()
  local modInfo = self:GetUgcModInfo()
  local PufferConst = require("client.slua.logic.download.puffer_const")
  if modInfo then
    local resManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCResManager)
    local state = PufferConst.ENUM_DownloadState.Not
    if modInfo.mod_id and modInfo.mod_id > 0 then
      state = resManager:GetResState(resManager.DownloaderType.ModCopy, modInfo)
    else
      state = resManager:GetResState(resManager.DownloaderType.MyWork, modInfo)
    end
    if state == PufferConst.ENUM_DownloadState.Done then
      return true
    end
    return false
  end
  return nil
end
function Lobby_Mode_UIBP:CheckReportResState()
  local LogicUGCResManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCResManager)
  LogicUGCResManager:CheckReportCurUGCModState()
end
function Lobby_Mode_UIBP:OnNotifyReqModInfoSuccess(_, _, lisType)
  local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
  if not UGCMacros.CheckMetaType(lisType, UGCMacros.ENUM_MODE_TYPE.UgcMatch) then
    return
  end
  local LogicUGCMulti = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMulti)
  local bIsBundleMatch = LogicUGCMulti.bIsBundleMatch
  if bIsBundleMatch then
    self:UpdateUgcMulti()
  else
    self:CheckReportResState()
  end
end
function Lobby_Mode_UIBP:ShowFlashAnimation()
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  local matchInfo = LogicUGCMatch:HasUGCMatchInfo()
  if matchInfo then
    self:PlayUserWidgetAnimation(self.UIRoot.Animation_Seletion, 0, 1, 0, 1)
  end
end
function Lobby_Mode_UIBP:OnUGCEditMatchInfoChange()
  log(bWriteLog and "[lucasji] Lobby_Mode_UIBP:OnUGCEditMatchInfoChange")
  self:OnModeChange()
  self:CheckReportResState()
end
function Lobby_Mode_UIBP:OnUpdateUI()
  log(bWriteLog and "[edward] Lobby_Mode_UIBP:OnUpdateUI")
  self:DelayUpdateUI()
end
function Lobby_Mode_UIBP:OnQRCodeRestrictChange()
  log(bWriteLog and "Lobby_Mode_UIBP:OnQRCodeRestrictChange")
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  local isRestrictBattle = QRcodeRestrictManager:IsRestrictBatlleAll()
  self:SetWidgetVisible(self.UIRoot.Button_ModeLock, isRestrictBattle, true)
end
local NewType2Text = {
  [1] = 69330,
  [2] = 69331,
  [3] = 69332
}
function Lobby_Mode_UIBP:SetAnimationMaterial(matPath, imagePath, imageWidget, texName)
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
function Lobby_Mode_UIBP:SetBgImgAndTextByViewId(viewid, viewIds)
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local data = logic_mode_selection:GetSubviewInfoBySubviewID(viewid)
  if not data then
    return
  end
  self.UIRoot.Text_ModelName:SetText(LocUtil.GetLocalizeResStr(data.lobby_name))
  self.UIRoot.TextBlock_Mode:SetText(LocUtil.LocalizeResFormat(12918, LocUtil.GetLocalizeResStr(data.title)))
  if self.UIRoot.CanvasPanel_loading then
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_loading, true)
    self:PlayUserWidgetAnimation(self.UIRoot.Animation_LoadingLoop, 0, 0, 0, 1)
  end
  self:SetWidgetVisible(self.UIRoot.Image_BG_UGC, false)
  self:SetWidgetVisible(self.UIRoot.Image_BG, true)
  local isMultiSelect = next(viewIds) and 1 < #viewIds
  local logic_mode_utils = require("client.slua.logic.mode_selection.logic_mode_utils")
  local bgPath = isMultiSelect and logic_mode_utils.GetMultiImage(false, data.is_random and data.is_random == 1, viewIds) or data.lobby_bg
  local util = require("client.slua_ui_framework.util")
  if util.IsOnlineImageUrl(bgPath) then
    self:SetTexture(self.UIRoot.Image_Bg, bgPath, {
      needLocalize = true,
      onDownloadSuccess = function()
        if self.UIRoot and self.UIRoot.CanvasPanel_loading then
          self:SetWidgetVisible(self.UIRoot.CanvasPanel_loading, false)
          self.UIRoot:StopAnimation(self.UIRoot.Animation_LoadingLoop)
        end
      end
    })
  else
    bgPath = util.GetUrlByLanguage(bgPath)
    self:SetTexture(self.UIRoot.Image_Bg, bgPath)
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_loading, false)
    self.UIRoot:StopAnimation(self.UIRoot.Animation_LoadingLoop)
  end
  if isMultiSelect then
    self.UIRoot.Text_MapName:SetText(LocUtil.LocalizeResFormat(500048, #viewIds))
  else
    local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
    local mapName = data.title
    if data.group_type == mode_selection_macro.Enum_Group_Type.Multi or data.is_ranked == 2 then
      mapName = data.subtitle
    end
    self.UIRoot.Text_MapName:SetText(LocUtil.LocalizeResFormat(mapName))
  end
end
function Lobby_Mode_UIBP:OnSwitchToPageStart(_, _, toPage)
  log(bWriteLog and "Lobby_Mode_UIBP:OnSwitchToPageStart. toPage = " .. tostring(toPage))
  if toPage == ENUM_LobbyPageType.Left or toPage == ENUM_LobbyPageType.Right then
    self.UIRoot.WidgetSwitcher_Mode:SetActiveWidgetIndex(1)
  else
    self.UIRoot.WidgetSwitcher_Mode:SetActiveWidgetIndex(0)
  end
end
function Lobby_Mode_UIBP:OnSwitchToPageEnd()
end
function Lobby_Mode_UIBP:UpdateActivityMode()
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  self.act = logic_mode_selection:GetModeJumpActivity()
  if self.act then
    self:SetTipsBarVisibility(self.UIRoot.CanvasPanel_Activity, UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.TextBlock_Activity:SetText(self.act.Desc)
  else
    self:SetTipsBarVisibility(self.UIRoot.CanvasPanel_Activity, UEnums.ESlateVisibility.Collapsed)
  end
end
function Lobby_Mode_UIBP:OnButton_UGCModClick()
  self:PlayAudio(sound_config.click)
  local LogicUgcFilterTag = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUgcFilterTag)
  LogicUgcFilterTag:ReSetFilterTag()
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  local bIsUGCOpen = Config_UGC.IsUGCReleased()
  if bIsUGCOpen then
    local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
    if LogicUGCMatch:HasUGCMatchInfo() then
      local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
      self:ShowUGCMainUIInDetail(TeamUpNewSystem.IsTeamLeader())
      tlog_report_utils.ReportTLogEvent(TLogEventDefine.NewModeSelection_ClickMagnifyingGlass, 0, "LobbyModMatch")
      self:HideLevelUnlockGuide()
      return
    end
    local LogicUGCMulti = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMulti)
    if LogicUGCMulti.bIsBundleMatch then
      local LogicUGCMulti = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMulti)
      if not LogicUGCMulti.bIsBundleMatch then
        return
      end
      local Config_UGC = require("client.slua.logic.ugc.config_ugc")
      if LogicUGCMulti.BundleType == Config_UGC.Enum_Bundle_Type.Season then
        return
      end
      UIManager.ShowUI(UIManager.UI_Config.UGC_RandomPlay_Popup_UIBP)
      tlog_report_utils.ReportTLogEvent(TLogEventDefine.NewModeSelection_ClickMagnifyingGlass, 0, "LobbyBundleMatch")
      self:HideLevelUnlockGuide()
      return
    end
  end
end
function Lobby_Mode_UIBP:ShowUGCMainUIInDetail(isTeamLeader)
  log(bWriteLog and "Lobby_Mode_UIBP:ShowUGCMainUI isTeamLeader" .. tostring(isTeamLeader))
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  local editMatchInfo = LogicUGCMatch:GetEditMatchInfo()
  local matchInfo = LogicUGCMatch:GetMatchInfo()
  if editMatchInfo and isTeamLeader then
    self:AddTimerOnce(0.2, function()
      if IsWoWEditor then
        return
      end
      UIManager.ShowUI(UIManager.UI_Config.ugc_mine_main)
    end)
    local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
    UIManager.ShowUI(UIManager.UI_Config.mode_selection_main, {
      menuList = tostring(mode_selection_macro.Enum_TabID.UGC)
    })
  elseif not editMatchInfo and matchInfo and matchInfo.mod_id then
    local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
    logic_mode_selection:SetFromLobby(true)
    local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
    LogicUGC:BatchGetModInfo({
      matchInfo.mod_id
    }, LogicUGC.C_ModListTypes.UgcMatch, function(MetaList, ListType, Param, bUseCache, FilterOfflineModList)
      local _, Mod = next(MetaList)
      if not Mod then
        return
      end
      local Config_UGC = require("client.slua.logic.ugc.config_ugc")
      local ugc_detail_config = Config_UGC.Config_UGC_DetailTabs
      local LogicUGCCRUD = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCCRUD)
      local bHide = LogicUGCCRUD:CheckUGCDetailUINeedHide(Mod.pub_mod_meta)
      if bHide then
        ugc_detail_config = Config_UGC.Config_UGC_DetailPrivateTabs
      end
      if LobbySystem.isInMatch then
        UIManager.ShowUI(UIManager.UI_Config.UGCDetailMainPanel, ugc_detail_config, Mod.pub_mod_meta)
      else
        local UGCDetailUIInfo = {
          ugc_detail_config,
          Mod.pub_mod_meta,
          false
        }
        local notPlayItemAnim = true
        local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
        UIManager.ShowUI(UIManager.UI_Config.mode_selection_main, {
          menuList = tostring(mode_selection_macro.Enum_TabID.UGC),
          UGCNotPlayItemAnim = notPlayItemAnim,
          UGCDetailUIData = UGCDetailUIInfo
        })
      end
    end)
  end
end
function Lobby_Mode_UIBP:OnButton_EnterClick()
  self:PlayAudio(sound_config.click)
  if LobbySystem.isInMatch then
    local UGCPlayHallRoom = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.UGCPlayHallRoom)
    if UGCPlayHallRoom and not UGCPlayHallRoom:GetRoomMatchInfo() then
      log(bWriteLog and "[edward][match_select_entry] UI_Match_Select_Entry:OnClickEntry, is matching!!!")
      ShowNotice(110014)
      return
    end
  end
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  local LogicUgcFilterTag = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUgcFilterTag)
  LogicUgcFilterTag:ReSetFilterTag()
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  local bIsUGCOpen = Config_UGC.IsUGCReleased()
  if bIsUGCOpen and not self.isMTModel then
    local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
    if LogicUGCMatch:HasUGCMatchInfo() then
      local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
      self:ShowUGCMainUI(TeamUpNewSystem.IsTeamLeader())
      tlog_report_utils.ReportTLogEvent(TLogEventDefine.NewModeSelection_LobbyEntrance)
      self:HideLevelUnlockGuide()
      return
    end
    local LogicUGCMulti = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMulti)
    if LogicUGCMulti.bIsBundleMatch then
      local BundleID = LogicUGCMulti.BundleSelect and LogicUGCMulti.BundleSelect[1]
      if BundleID and LogicUGCMulti.BundleType == Config_UGC.Enum_Bundle_Type.Season then
        local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
        UIManager.ShowUI(UIManager.UI_Config.mode_selection_main, {
          menuList = tostring(mode_selection_macro.Enum_TabID.UGC),
          ugcSeason = 1,
          openUgcSeasonMatch = true
        })
        return
      end
      self:ShowUGCMainUI()
      tlog_report_utils.ReportTLogEvent(TLogEventDefine.NewModeSelection_LobbyEntrance)
      self:HideLevelUnlockGuide()
      return
    end
  end
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  if self.act then
    self.act = logic_mode_selection:OnJumpActivityUrl(self.act)
    self:UpdateActivityMode()
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.NewModeSelection_LobbyEntranceByAct)
  else
    local logic_return_activity_first_battle = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_return_activity_first_battle)
    if logic_return_activity_first_battle:ShouldShowReturnModeSelect() then
      local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
      local clickData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eReturnPlayerModeSelectClick) or {}
      local TimeUtil = require("client.common.time_util")
      clickData[DataMgr.roleData.back_user_data.rejoin_start_time] = TimeUtil.GetServerTimeInSec()
      PlayerPrefsSystem.SaveTableToFile_N(clickData, PlayerPrefsSystem.ePlayerPrefsType.eReturnPlayerModeSelectClick)
      local ui_show_queue_config = require("client.common.uibase.ui_show_queue_config")
      local ParamTable = ui_show_queue_config.GetParamTable(nil, "Click")
      local Promise = require("common.Promise")
      local promise = Promise.new()
      UIManager.ShowUI(UIManager.UI_Config.Return_ModeSelect_UIBP, promise, ParamTable)
      promise:Then(function()
        logic_mode_selection:ShowMainUI(nil, true)
      end)
    else
      logic_mode_selection:ShowMainUI(nil, true)
    end
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.NewModeSelection_LobbyEntrance)
  end
  local regionGroupConfig = CDataTable.GetTableData("RegionGroupConfig", FuncUtil.GetAccountRegionForBP())
  if regionGroupConfig and regionGroupConfig.CommunityEntranceSwitch ~= 0 then
    local wonderfulPBReddot = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_peakgame_WonderfulPlayBack_Reddot)
    wonderfulPBReddot:RequestWonderfulPlayBackState("mode")
  end
  self:HideLevelUnlockGuide()
end
function Lobby_Mode_UIBP:OnButton_Tips_ChangeModeClick()
  self:PlayAudio(sound_config.click)
  ShowNotice(35121)
end
function Lobby_Mode_UIBP:OnButtonTipClick()
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_UGCDownloadGuide, false)
  local LogicUGCMulti = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMulti)
  local modInfo = self:GetUgcModInfo()
  if modInfo then
    self:OnClickUGCResStateBtn()
  elseif LogicUGCMulti.bIsBundleMatch then
    self:OnClickUGCMultiResStateBtn()
  else
    self:OnButton_EnterClick()
  end
end
function Lobby_Mode_UIBP:OnButton_UGCMultiClick()
  self:PlayAudio(sound_config.click)
  local LogicUGCMulti = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMulti)
  if not LogicUGCMulti.bIsBundleMatch then
    return
  end
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  if LogicUGCMulti.BundleType == Config_UGC.Enum_Bundle_Type.Season then
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.UGC_RandomPlay_Popup_UIBP)
end
function Lobby_Mode_UIBP:OnModeRestrictClick()
  self:PlayAudio(sound_config.click_v1)
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:IsRestrictBatlleAll() then
    QRcodeRestrictManager:ShowRestrictTips()
  end
end
function Lobby_Mode_UIBP:Close()
  Lobby_Mode_UIBP.__super.Close(self)
end
function Lobby_Mode_UIBP:OnLevelUnlockGuide(_, __, featureConfig)
  if not GameStatus.IsIn2DLobby() then
    log(bWriteLog and "MainCity_Lobby_Main_Match_Entry_UIBP:OnLevelUnlockGuide not in 2D lobby")
    return
  end
  local level_unlock_util = require("client.logic.level_unlock.util.level_unlock_util")
  local bHaveLockedFeature = level_unlock_util:HaveLockedFeature()
  log(bWriteLog and "Lobby_Mode_UIBP:OnLevelUnlockGuide bHaveLockedFeature = " .. tostring(bHaveLockedFeature))
  if bHaveLockedFeature then
    local widget = self.UIRoot.CanvasPanel_Activity
    self:SetTipsBarVisibility(widget, UEnums.ESlateVisibility.SelfHitTestInvisible)
    local textBlock = self.UIRoot.TextBlock_Activity
    textBlock:SetText(LocUtil.LocalizeResFormat(29725, LocUtil.GetLocalizeResStr(featureConfig.localizeID)))
    local buttonEnter = self.UIRoot.WidgetSwitcher_Mode
    if buttonEnter then
      self:AddTimerOnce(0.1, function()
        local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
        level_unlock_manager:StartUnlockTip(buttonEnter, featureConfig.currentUnlock, true)
      end)
    end
  end
end
function Lobby_Mode_UIBP:HideLevelUnlockGuide()
  local level_unlock_util = require("client.logic.level_unlock.util.level_unlock_util")
  local bHaveLockedFeature = level_unlock_util:HaveLockedFeature()
  log(bWriteLog and "Lobby_Mode_UIBP:OnLevelUnlockGuide bHaveLockedFeature = " .. tostring(bHaveLockedFeature))
  if bHaveLockedFeature then
    local widget = self.UIRoot.CanvasPanel_Activity
    self:SetTipsBarVisibility(widget, UEnums.ESlateVisibility.Collapsed)
  end
end
function Lobby_Mode_UIBP:ShowUGCMainUI(isTeamLeader)
  log(bWriteLog and "Lobby_Mode_UIBP:ShowUGCMainUI isTeamLeader" .. tostring(isTeamLeader))
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  local editMatchInfo = LogicUGCMatch:GetEditMatchInfo()
  if editMatchInfo and isTeamLeader then
    self:AddTimerOnce(0.2, function()
      if IsWoWEditor then
        return
      end
      UIManager.ShowUI(UIManager.UI_Config.ugc_mine_main)
    end)
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  logic_mode_selection:SetFromLobby(true)
  local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
  UIManager.ShowUI(UIManager.UI_Config.mode_selection_main, {
    menuList = tostring(mode_selection_macro.Enum_TabID.UGC)
  })
end
function Lobby_Mode_UIBP:SetImageBgByModeData()
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local modeid, viewid, viewIds = logic_mode_selection:GetCurSelectInfo()
  if not modeid then
    return
  end
  local data = logic_mode_selection:GetSubviewInfoBySubviewID(viewid)
  if not data then
    return
  end
  if self.UIRoot.CanvasPanel_loading then
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_loading, true)
    self:PlayUserWidgetAnimation(self.UIRoot.Animation_LoadingLoop, 0, 0, 0, 1)
  end
  self:SetWidgetVisible(self.UIRoot.Image_BG_UGC, false)
  self:SetWidgetVisible(self.UIRoot.Image_BG, true)
  local isMultiSelect = next(viewIds) and 1 < #viewIds or data.is_random and data.is_random == 1
  local logic_mode_utils = require("client.slua.logic.mode_selection.logic_mode_utils")
  local bgPath = isMultiSelect and logic_mode_utils.GetMultiImage(false, data.is_random and data.is_random == 1) or data.lobby_bg
  self:SetTexture(self.UIRoot.Image_Bg, bgPath, {
    needLocalize = true,
    onDownloadSuccess = function()
      if self.UIRoot.CanvasPanel_loading then
        self:SetWidgetVisible(self.UIRoot.CanvasPanel_loading, false)
        self.UIRoot:StopAnimation(self.UIRoot.Animation_LoadingLoop)
      end
    end
  })
end
function Lobby_Mode_UIBP:OnUpdateMatchStatus()
  local MatchSystem = require("client.slua.logic.match.logic_match")
  local status = MatchSystem.nMatchStatus
  if status == ENUM_MatchStatus.Matching then
    local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
    if MatchModeMgrSystem.bIsMatchingSocialIsland then
      self:SetBgImgAndTextByViewId(20999, {})
    elseif MatchModeMgrSystem.bIsMatchingTrainMode then
      self:SetBgImgAndTextByViewId(20011, {})
    else
      self:DelayUpdateUI()
    end
  else
    self:DelayUpdateUI()
  end
  self:CheckCrossMatchUIShow()
  self:CheckAbnormalStatusShow()
end
function Lobby_Mode_UIBP:OnClose()
  Lobby_Mode_UIBP.__super.OnClose(self)
  self.NewSkillLobbyEntrance:Close()
  self.NewSkillLobbyEntrance = nil
end
function Lobby_Mode_UIBP:CheckShowUGCDownloadGuide()
  if self.hasShowUGCDownloadGuide then
    log(bWriteLog and "Lobby_Mode_UIBP:CheckShowUGCDownloadGuide  has show 1")
    return
  end
  log(bWriteLog and "Lobby_Mode_UIBP:CheckShowUGCDownloadGuide")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local downloadGuideData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCModSelectDownloadGuide) or {}
  if downloadGuideData.HasShowGuide == 1 then
    log(bWriteLog and "Lobby_Mode_UIBP:CheckShowUGCDownloadGuide has show")
    return
  end
  self.hasShowUGCDownloadGuide = true
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_UGCDownloadGuide, true)
  self.UIRoot.TextBlock_Guide:SetText(LocUtil.GetLocalizeResStr(62999) or "")
  self:AddTimerOnce(8, function()
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_UGCDownloadGuide, false)
  end)
  downloadGuideData.HasShowGuide = 1
  PlayerPrefsSystem.SaveTableToFile_N(downloadGuideData, PlayerPrefsSystem.ePlayerPrefsType.eUGCModSelectDownloadGuide)
end
function Lobby_Mode_UIBP:RefreshThemeEntrance()
  self.UIRoot.CanvasPanel_Theme:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  do return end
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
          self.UIRoot.CanvasPanel_Theme:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
          return
        end
      end
    end
    local urlPath = entryConfig.EntryURL
    local util = require("client.slua_ui_framework.util")
    if urlPath ~= "" and util.IsOnlineImageUrl(urlPath) then
      local imgUrl = util.GetUrlByLanguage(urlPath)
      local failFunc = function(url)
        self:SetTexture(self.UIRoot.Theme_EntranceIcon, urlPath, {ifAddRef = true, tryTimes = 2})
      end
      self:SetTexture(self.UIRoot.Theme_EntranceIcon, imgUrl, {ifAddRef = true, onDownloadFail = failFunc})
    end
    self.UIRoot.CanvasPanel_Theme:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.TextBlock_7:SetText(entryConfig.EntryName)
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_Version2, false, false)
    local newEntryConfig = ThemeConfig.GetNextVersionEntryBannerConfig()
    if newEntryConfig then
      self.UIRoot.TextBlock_12:SetText(newEntryConfig.EntryName)
      local newUrlPath = newEntryConfig.EntryURL
      if newUrlPath ~= "" and util.IsOnlineImageUrl(newUrlPath) then
        do
          local imgUrl = util.GetUrlByLanguage(newUrlPath)
          local failFunc = function(url)
            self:SetTexture(self.UIRoot.Theme_EntranceIcon_Version2, newUrlPath, {ifAddRef = true, tryTimes = 2})
          end
          self:SetTexture(self.UIRoot.Theme_EntranceIcon_Version2, imgUrl, {ifAddRef = true, onDownloadFail = failFunc})
        end
      end
    end
    local theme_system_reddot = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.theme_system_reddot)
    local logic_theme_system = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_theme_system)
    if logic_theme_system:CheckThemeSystemNew() then
      theme_system_reddot:SetNewRedDot()
      log(bWriteLog and string.format("Lobby_Mode_UIBP:RefreshThemeEntrance show new red dot."))
    else
      log(bWriteLog and string.format("Lobby_Mode_UIBP:RefreshThemeEntrance hide new red dot."))
      theme_system_reddot:CloseNewRedDot()
    end
    if logic_theme_system:CheckNextVersionPreheatRedDot() then
      log(bWriteLog and "Lobby_Mode_UIBP:RefreshThemeEntrance show next version preheat red dot.")
      theme_system_reddot:SetNextVersionPreheatRedDot()
    else
      log(bWriteLog and "Lobby_Mode_UIBP:RefreshThemeEntrance hide next version preheat red dot.")
      theme_system_reddot:CloseNextVersionPreheatRedDot()
    end
    if logic_theme_system:CheckMidTermActivityPreheatRedDot() then
      log(bWriteLog and "Lobby_Mode_UIBP:RefreshThemeEntrance show mid term activity preheat red dot.")
      theme_system_reddot:SetNewActivityRedDot()
    else
      log(bWriteLog and "Lobby_Mode_UIBP:RefreshThemeEntrance hide mid term activity preheat red dot.")
      theme_system_reddot:CloseNewActivityRedDot()
    end
    if logic_theme_system:CheckCurThemeActOpenRedDot() then
      log(bWriteLog and "Lobby_Mode_UIBP:RefreshThemeEntrance show CurThemeActOpen red dot.")
      theme_system_reddot:SetThemeActOpenRedDot()
    else
      log(bWriteLog and "Lobby_Mode_UIBP:RefreshThemeEntrance hide CurThemeActOpen red dot.")
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
    self.UIRoot.CanvasPanel_Theme:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function Lobby_Mode_UIBP:OnButton_ThemeClick()
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
function Lobby_Mode_UIBP:OnThemeSystemRefreshNewMark()
  self:DelayRefreshThemeExchangeReddotUI()
end
function Lobby_Mode_UIBP:DelayRefreshThemeExchangeReddotUI()
  if self.DelayRefreshThemeExchangeReddotUITimer then
    self:RemoveTimer(self.DelayRefreshThemeExchangeReddotUITimer)
    self.DelayRefreshThemeExchangeReddotUITimer = nil
  end
  self.DelayRefreshThemeExchangeReddotUITimer = self:AddTimerOnce(0, function()
    self:RefreshThemeExchangeReddotUI()
  end)
end
function Lobby_Mode_UIBP:RefreshThemeExchangeReddotUI()
  log(bWriteLog and "Lobby_Mode_UIBP:RefreshThemeExchangeReddotUI")
  local theme_system_reddot = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.theme_system_reddot)
  local logic_theme_system = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_theme_system)
  self.UIRoot:StopAnimation(self.UIRoot.Anim_NewAward_Loop)
  self.UIRoot:StopAnimation(self.UIRoot.Anim_NewAward)
  self.UIRoot:StopAnimation(self.UIRoot.Anim_ThemePreheat)
  self:PlayUserWidgetAnimation(self.UIRoot.Anim_NoAward, 0, 1, 0, 1)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Version2, false, false)
  if theme_system_reddot:HasNewRedDot() then
    log(bWriteLog and "Lobby_Mode_UIBP:RefreshThemeExchangeReddotUI has playmode new")
  elseif theme_system_reddot:HasNextVersionPreheatRedDot() then
    log(bWriteLog and "Lobby_Mode_UIBP:RefreshThemeExchangeReddotUI has next version preheat")
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
      log(bWriteLog and "Lobby_Mode_UIBP:RefreshThemeExchangeReddotUI play Anim_ThemePreheat")
      self:SetWidgetVisible(self.UIRoot.CanvasPanel_Version2, true, false)
      self:PlayUserWidgetAnimation(self.UIRoot.Anim_ThemePreheat, 0, 0, 0, 1)
    end
  elseif theme_system_reddot:HasNewActivityRedDot() then
    log(bWriteLog and "Lobby_Mode_UIBP:RefreshThemeExchangeReddotUI has new activity reddot")
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
      self:PlayUserWidgetAnimation(self.UIRoot.Anim_NewAward, 0, 1, 0, 1)
      local animTime = self.UIRoot.Anim_NewAward:GetEndTime()
      self:AddTimerOnce(animTime, function()
        self:PlayUserWidgetAnimation(self.UIRoot.Anim_NewAward_Loop, 0, 0, 0, 1)
      end)
    end)
  elseif theme_system_reddot:HasExchangeNewRedDot() then
    log(bWriteLog and "Lobby_Mode_UIBP:RefreshThemeExchangeReddotUI has reddot")
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
      log(bWriteLog and "Lobby_Mode_UIBP:RefreshThemeExchangeReddotUI play Anim_NewAward")
      local newType = logic_theme_system:GetExchangeNewType()
      self.UIRoot.TextBlock_8:SetText(LocUtil.GetLocalizeResStr(NewType2Text[newType]))
      self:PlayUserWidgetAnimation(self.UIRoot.Anim_NewAward, 0, 1, 0, 1)
      local animTime = self.UIRoot.Anim_NewAward:GetEndTime()
      self:AddTimerOnce(animTime, function()
        log(bWriteLog and "Lobby_Mode_UIBP:RefreshThemeExchangeReddotUI play Anim_NewAward_Loop")
        self:PlayUserWidgetAnimation(self.UIRoot.Anim_NewAward_Loop, 0, 0, 0, 1)
      end)
    end)
  elseif theme_system_reddot:HasThemeActOpenRedDot() then
    log(bWriteLog and "Lobby_Mode_UIBP:RefreshThemeExchangeReddotUI has ThemeActOpen")
  elseif theme_system_reddot:HasThemeActRewardRedDot() then
    log(bWriteLog and "Lobby_Mode_UIBP:RefreshThemeExchangeReddotUI has ThemeActReward")
  else
    log(bWriteLog and "Lobby_Mode_UIBP:RefreshThemeExchangeReddotUI no reddot")
  end
end
function Lobby_Mode_UIBP:OnUpdateUGCSeaonMod()
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  local LogicUGCMulti = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMulti)
  if LogicUGCMulti.BundleType ~= Config_UGC.Enum_Bundle_Type.Season then
    return
  end
  local Logic_UGC_Season = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_season)
  local CoverPath = Logic_UGC_Season:GetSelectBundlePic()
  self:SetTexture(self.UIRoot.Image_Mod, CoverPath)
end
function Lobby_Mode_UIBP:OnExitMember(_, _, uid)
  if tostring(uid) == DataMgr.roleData.uid then
    self:CheckCrossMatchUIShow()
    self:CheckAbnormalStatusShow()
  else
    self:CheckAbnormalStatusShow()
  end
end
function Lobby_Mode_UIBP:OnQuit()
  self:CheckCrossMatchUIShow()
  self:CheckAbnormalStatusShow()
end
function Lobby_Mode_UIBP:OnTeamChangeLeader()
  self:CheckCrossMatchUIShow()
  self:CheckAbnormalStatusShow()
end
function Lobby_Mode_UIBP:OnChangeMatchStrategyNotify()
  self:CheckAbnormalStatusShow()
end
function Lobby_Mode_UIBP:GetSelfResDownloadState()
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local LogicUGCMulti = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMulti)
  if LogicUGCMulti.bIsBundleMatch then
    local bundleState, cSize, tSize = LogicUGCMulti:GetResState()
    if bundleState ~= PufferConst.ENUM_DownloadState.Done then
      local leftSize = math.max(tSize - cSize, 0.1)
      log(bWriteLog and string.format("Lobby_Mode_UIBP:GetSelfResDownloadState UGC bundle not downloaded, leftSize=%.1f", leftSize))
      return true, leftSize
    end
    return false, nil
  end
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  if LogicUGCMatch:HasUGCMatchInfo() then
    local ugcModResState = self:GetUgcModResState()
    if ugcModResState == true then
      return false, nil
    end
    if ugcModResState == nil then
      log(bWriteLog and "Lobby_Mode_UIBP:GetSelfResDownloadState UGC mod info not ready, skip download prompt")
      return false, nil
    end
    local leftSize
    if ugcModResState == false then
      local modInfo = self:GetUgcModInfo()
      if modInfo then
        local resManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCResManager)
        local cSize, tSize = resManager:GetResSize(resManager.DownloaderType.ModCopy, modInfo)
        leftSize = math.max(tSize - cSize, 0.1)
      end
    end
    log(bWriteLog and string.format("Lobby_Mode_UIBP:GetSelfResDownloadState UGC mod not ready, state=%s leftSize=%s", tostring(ugcModResState), tostring(leftSize)))
    return true, leftSize
  end
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  if LogicUGCMatch:GetMatchModID() > 0 then
    log(bWriteLog and "Lobby_Mode_UIBP:GetSelfResDownloadState UGC mode but matchInfo not ready, skip classic map check")
    return false, nil
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local _, viewid, viewids = logic_mode_selection:GetCurSelectInfo()
  local allViewIds = viewids and next(viewids) and viewids or viewid and {viewid} or nil
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
      local state = logic_mode_map_download:GetMapListState(mapKeyList)
      if state ~= PufferConst.ENUM_DownloadState.Done then
        local curSize, totalSize = logic_mode_map_download:GetMapListSize(mapKeyList)
        local leftSize = math.max((totalSize - curSize) / PufferConst.MB, 0.1)
        log(bWriteLog and string.format("Lobby_Mode_UIBP:GetSelfResDownloadState classic map not downloaded, state=%s leftSize=%.1f", tostring(state), leftSize))
        return true, leftSize
      end
    end
  end
  return false, nil
end
function Lobby_Mode_UIBP:CheckSoloMapDownloadStatus()
  local bNotDownloaded, leftSize = self:GetSelfResDownloadState()
  if bNotDownloaded then
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_TeamStatus, true)
    if leftSize then
      self.UIRoot.UTRichTextBlock_Text:SetText(LocUtil.LocalizeResFormat(48498, string.format("%.1f", leftSize)))
    else
      self.UIRoot.UTRichTextBlock_Text:SetText(LocUtil.GetLocalizeResStr(817439))
    end
    self.UIRoot.WidgetSwitcher_Status:SetActiveWidgetIndex(0)
    log(bWriteLog and "Lobby_Mode_UIBP:CheckSoloMapDownloadStatus show not downloaded")
  else
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_TeamStatus, false)
    log(bWriteLog and "Lobby_Mode_UIBP:CheckSoloMapDownloadStatus all downloaded, hide")
  end
end
function Lobby_Mode_UIBP:CancelReady()
  log(bWriteLog and "Lobby_Mode_UIBP:CancelReady")
  local TeamupHandler = require("client.network.Protocol.TeamupHandler")
  local DeviceOSInfo = require("client.logic.data.data_device_os")
  DeviceOSInfo.getDeviceOSInfo()
  TeamupHandler.send_team_change_member_status_request(ENUM_MatchStatus.Not, DeviceOSInfo.InfoList)
end
function Lobby_Mode_UIBP:CheckAbnormalStatusShow()
  log(bWriteLog and "Lobby_Mode_UIBP:CheckAbnormalStatusShow")
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission(true) then
    log(bWriteLog and "Lobby_Mode_UIBP:CheckAbnormalStatusShow IsInXMission, skip")
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_TeamStatus, false)
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if not TeamUpNewSystem.IsInTeam() then
    self:CheckSoloMapDownloadStatus()
    log(bWriteLog and "Lobby_Mode_UIBP:CheckAbnormalStatusShow not in team, skip")
    return
  end
  local logic_team_match_state = require("client.slua.logic.teamup.logic_team_match_state")
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local LogicPeakGameUtil = require("client.logic.PeakGame.LogicPeakGameUtil")
  local curMatchMode = logic_mode_selection and logic_mode_selection:GetCurSelectInfo()
  local isPeakGame = LogicPeakGameUtil.IsPeakGameBattleType(curMatchMode)
  log(bWriteLog and string.format("Lobby_Mode_UIBP:CheckAbnormalStatusShow curMatchMode=%s isPeakGame=%s", tostring(curMatchMode), tostring(isPeakGame)))
  local bSegmentMismatch = false
  if isPeakGame then
    bSegmentMismatch = logic_team_match_state:HasAnyCannotPeakGame()
  else
    bSegmentMismatch = logic_team_match_state:HasAnySegmentLimit()
  end
  log(bWriteLog and string.format("Lobby_Mode_UIBP:CheckAbnormalStatusShow bSegmentMismatch=%s", tostring(bSegmentMismatch)))
  local bSelfMapNotDownloaded, selfMapLeftSize = self:GetSelfResDownloadState()
  log(bWriteLog and string.format("Lobby_Mode_UIBP:CheckAbnormalStatusShow bSelfMapNotDownloaded=%s selfMapLeftSize=%s", tostring(bSelfMapNotDownloaded), tostring(selfMapLeftSize)))
  local bTeammateMapNotDownloaded = false
  if not bSelfMapNotDownloaded then
    bTeammateMapNotDownloaded = logic_team_match_state:HasAnyMapIssue()
    log(bWriteLog and string.format("Lobby_Mode_UIBP:CheckAbnormalStatusShow bTeammateMapNotDownloaded=%s", tostring(bTeammateMapNotDownloaded)))
  end
  local bNetAbnormal = false
  local logic_team_zone_ping = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_team_zone_ping)
  local bIsUseLeaderStrategy = logic_team_zone_ping:IsUseLeaderStrategy()
  if bIsUseLeaderStrategy ~= nil then
    bNetAbnormal = true
    log(bWriteLog and string.format("Lobby_Mode_UIBP:CheckAbnormalStatusShow bNetAbnormal=true bIsUseLeaderStrategy=%s", tostring(bIsUseLeaderStrategy)))
  end
  if bSegmentMismatch then
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_TeamStatus, true)
    self.UIRoot.UTRichTextBlock_Text:SetText(LocUtil.GetLocalizeResStr(817438))
    self.UIRoot.WidgetSwitcher_Status:SetActiveWidgetIndex(0)
    log(bWriteLog and "Lobby_Mode_UIBP:CheckAbnormalStatusShow show segment mismatch")
  elseif bSelfMapNotDownloaded then
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_TeamStatus, true)
    if selfMapLeftSize then
      self.UIRoot.UTRichTextBlock_Text:SetText(LocUtil.LocalizeResFormat(48498, string.format("%.1f", selfMapLeftSize)))
    else
      self.UIRoot.UTRichTextBlock_Text:SetText(LocUtil.GetLocalizeResStr(817439))
    end
    self.UIRoot.WidgetSwitcher_Status:SetActiveWidgetIndex(0)
    log(bWriteLog and "Lobby_Mode_UIBP:CheckAbnormalStatusShow show self map not downloaded")
    local myStatus = TeamUpNewSystem.GetMyStatus()
    if myStatus == ENUM_MatchStatus.Ready then
      log(bWriteLog and "Lobby_Mode_UIBP:CheckAbnormalStatusShow cancel ready due to self map not downloaded")
      self:CancelReady()
    end
  elseif bTeammateMapNotDownloaded then
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_TeamStatus, true)
    self.UIRoot.UTRichTextBlock_Text:SetText(LocUtil.GetLocalizeResStr(817439))
    self.UIRoot.WidgetSwitcher_Status:SetActiveWidgetIndex(0)
    log(bWriteLog and "Lobby_Mode_UIBP:CheckAbnormalStatusShow show teammate map not downloaded")
  elseif bNetAbnormal then
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_TeamStatus, true)
    self.UIRoot.UTRichTextBlock_Text:SetText(LocUtil.GetLocalizeResStr(817440))
    self.UIRoot.WidgetSwitcher_Status:SetActiveWidgetIndex(1)
    log(bWriteLog and "Lobby_Mode_UIBP:CheckAbnormalStatusShow show net abnormal")
  else
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_TeamStatus, false)
    log(bWriteLog and "Lobby_Mode_UIBP:CheckAbnormalStatusShow no abnormal, hide")
  end
end
function Lobby_Mode_UIBP:OnCheckTeamMatchState()
  log(bWriteLog and "Lobby_Mode_UIBP:OnCheckTeamMatchState")
  self:CheckAbnormalStatusShow()
end
function Lobby_Mode_UIBP:OnMapDownloadFinish(_, _, eventData)
  if not eventData then
    return
  end
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local dt = eventData.downloadType
  if dt ~= PufferConst.ENUM_DownloadType.MAP and dt ~= PufferConst.ENUM_DownloadType.UGCPAK and dt ~= PufferConst.ENUM_DownloadType.UGCPACK then
    return
  end
  log(bWriteLog and string.format("Lobby_Mode_UIBP:OnMapDownloadFinish, downloadType=%s mapKey=%s", tostring(dt), tostring(eventData.mapKey)))
  self:CheckAbnormalStatusShow()
end
function Lobby_Mode_UIBP:OnButton_TeamStatusClick()
  self:PlayAudio(sound_config.click_v1)
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.IsInTeam() then
    UIManager.ShowUI(UIManager.UI_Config.Lobby_AbnormalStatus_Popup_UIBP)
  else
    local bNotDownloaded = self:GetSelfResDownloadState()
    if not bNotDownloaded then
      self:CheckAbnormalStatusShow()
      return
    end
    self:OnButtonTipClick()
  end
end
function Lobby_Mode_UIBP:OnCrossMatchNotify()
  self:CheckCrossMatchUIShow()
end
function Lobby_Mode_UIBP:OnClickCheckBox_CrossMatch(isCheck)
  self:PlayAudio(sound_config.toggle_v1)
  local BasicDataTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataTLogReport)
  if isCheck then
    self.UIRoot.CheckBox_CrossMatch:SetCheckedState(0)
    local TeamupHandler = require("client.network.Protocol.TeamupHandler")
    TeamupHandler.send_change_cross_shadow_req(false):Then(function(res)
      if res == NetErrorCode_NONE then
        ShowNotice(76510)
        self:CheckCrossMatchUIShow()
      end
    end)
    BasicDataTLogReport:ReportImmediate(TLogEventDefine.Team_Cross_Match_Click, 1, isCheck and 1 or 0)
  else
    self.UIRoot.CheckBox_CrossMatch:SetCheckedState(1)
    local TeamupHandler = require("client.network.Protocol.TeamupHandler")
    TeamupHandler.send_change_cross_shadow_req(true):Then(function(res)
      if res == NetErrorCode_NONE then
        self:CheckCrossMatchUIShow()
      end
    end)
    BasicDataTLogReport:ReportImmediate(TLogEventDefine.Team_Cross_Match_Click, 0, isCheck and 1 or 0)
  end
end
function Lobby_Mode_UIBP:CheckCrossMatchUIShow()
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_CrossMatch, false)
  local logic_team_zone_ping = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_team_zone_ping)
  if logic_team_zone_ping:GMGetLobbyCrossShow() then
    self.UIRoot.UTRichTextBlock_CrossMatch:SetText(LocUtil.GetLocalizeResStr(76511))
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_CrossMatch, true)
    self:PlayUserWidgetAnimation(self.UIRoot.Anim_Tips, 0, 1, 0, 1)
    return
  end
  local notCrossMatch = logic_team_zone_ping:GetNotCrossMatch()
  if notCrossMatch == nil then
    log(bWriteLog and "Lobby_Mode_UIBP:CheckCrossMatchUIShow return of notCrossMatch == nil")
    return
  end
  local MatchSystem = require("client.slua.logic.match.logic_match")
  local status = MatchSystem.nMatchStatus
  if status == ENUM_MatchStatus.Matching then
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    if TeamUpNewSystem.IsTeamLeader() then
      self.UIRoot.UTRichTextBlock_CrossMatch:SetText(LocUtil.GetLocalizeResStr(76511))
      self:SetWidgetVisible(self.UIRoot.CanvasPanel_CrossMatch, true)
      self.UIRoot.CheckBox_CrossMatch:SetCheckedState(notCrossMatch and 0 or 1)
      self:PlayUserWidgetAnimation(self.UIRoot.Anim_Tips, 0, 1, 0, 1)
    end
  end
end
function Lobby_Mode_UIBP:SetAsymmetricInfo()
  log(bWriteLog and "Lobby_Mode_UIBP:SetAsymmetricInfo")
  local logic_mode_asymmertric = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_asymmertric)
  local isCurModAsym = logic_mode_asymmertric:GetHasSelectedCamp()
  self:SetWidgetVisible(self.UIRoot.SizeBox_Icon, isCurModAsym)
  if not isCurModAsym then
    self:SetWidgetVisible(self.UIRoot.SizeBox_Icon1, false)
    self:SetWidgetVisible(self.UIRoot.SizeBox_TeameName, isCurModAsym)
    return
  end
  local isHunt = logic_mode_asymmertric:GetIsHunter()
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  self:SetTexture(self.UIRoot.Image_Icon, isHunt and "/Game/UMG/Texture_200/Atlas/Lobby/Frames/Lobby_Icon_EscapeMode02_png.Lobby_Icon_EscapeMode02_png" or "/Game/UMG/Texture_200/Atlas/Lobby/Frames/Lobby_Icon_EscapeMode01_png.Lobby_Icon_EscapeMode01_png")
  self.UIRoot.TextBlock_9:SetText(LocUtil.GetLocalizeResStr(isHunt and 4002062 or 4002061))
  local isRandom = logic_mode_asymmertric:GetIsRandomCamp()
  self:SetWidgetVisible(self.UIRoot.SizeBox_TeameName, not isRandom)
  self:SetWidgetVisible(self.UIRoot.SizeBox_Icon1, isRandom)
  local filterInfo = logic_mode_selection:GetFilterInfo()
  if isHunt and not isRandom then
    filterInfo.teamNum = 1
  end
  self:UpdatePerspectiveAndTeamNum(filterInfo)
  self.UIRoot.Text_PerspectiveType:SetText("")
  self:SetWidgetVisible(self.UIRoot.HorizontalBox_0, not isRandom)
  self.UIRoot.Image_1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function Lobby_Mode_UIBP:SpecialPlayUIUpdate(table_name, data)
  log_tree(bWriteLog and "Lobby_Mode_UIBP:SpecialPlayUIUpdate", data)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_SpecialPlay, false)
  self.specialPlayActivityCfg = nil
  if not self.specialPlayUIUpdateNum then
    self.specialPlayUIUpdateNum = 0
  end
  self.specialPlayUIUpdateNum = self.specialPlayUIUpdateNum + 1
  log(bWriteLog and "Lobby_Mode_UIBP:SpecialPlayUIUpdate specialPlayUIUpdateNum:" .. tostring(self.specialPlayUIUpdateNum))
  if self.specialPlayUIUpdateNum > 5 then
    return
  end
  local SpecialPlayEnum = {
    PENDING = 0,
    ACTIVE = 1,
    EXPIRED = 2
  }
  local panelState = SpecialPlayEnum.EXPIRED
  if self.specialPlayClock then
    self:RemoveClock(self.specialPlayClock)
    self.specialPlayClock = nil
  end
  local TimeUtil = require("client.common.time_util")
  local currentTime = TimeUtil.GetServerTimeInSec()
  local curVersion = Client.GetAppVersion()
  local StringUtil = require("common.string_util")
  local gameId = Client.GetITopGameId()
  log(bWriteLog and "Lobby_Mode_UIBP:SpecialPlayUIUpdate gameId:" .. tostring(gameId))
  local TimeStampFrom, TimeStampTo
  if data and next(data) then
    for k, v in pairs(data) do
      local startTime = v.start_time
      local endtTime = v.end_time
      local minVersion = v.min_version
      local appids = v.appids
      local version_util = require("client.common.version_util")
      local curFormatVersion = version_util.GetClientFormat(curVersion)
      local reqFormatVersion = version_util.GetClientFormat(minVersion)
      if 0 <= version_util.CompareVersionStandard(curFormatVersion, reqFormatVersion) then
        local appIDList = StringUtil.Split(appids, "|")
        local bIsAppIDValid = false
        for _, appID in pairs(appIDList) do
          if appID == gameId then
            bIsAppIDValid = true
            break
          end
        end
        if bIsAppIDValid then
          TimeStampFrom = TimeUtil.TimeStringToUnixstamp(startTime)
          TimeStampTo = TimeUtil.TimeStringToUnixstamp(endtTime)
          if currentTime >= TimeStampFrom and currentTime <= TimeStampTo then
            log(bWriteLog and "Lobby_Mode_UIBP:SpecialPlayUIUpdate ACTIVE index:" .. tostring(k))
            panelState = SpecialPlayEnum.ACTIVE
            self.specialPlayActivityCfg = v
            self.UIRoot.TextBlock_SpecialPlay:SetText(LocUtil.LocalizeResFormat(v.banner_text))
            self:SetTexture(self.UIRoot.Image_20, v.pic_url)
            break
          elseif currentTime < TimeStampFrom then
            log(bWriteLog and "Lobby_Mode_UIBP:SpecialPlayUIUpdate PENDING index:" .. tostring(k))
            panelState = SpecialPlayEnum.PENDING
            break
          end
        end
      end
    end
  end
  if panelState == SpecialPlayEnum.ACTIVE and TimeStampTo then
    self.specialPlayClock = self:AddClock(TimeStampTo + 2, nil, function()
      log(bWriteLog and "Lobby_Mode_UIBP:SpecialPlayUIUpdate ACTIVE EndFunc")
      if self and slua.isValid(self.UIRoot) then
        self.specialPlayClock = nil
        self:SpecialPlayUIUpdate(nil, self.specialPlayCfg)
      end
    end)
  elseif panelState == SpecialPlayEnum.PENDING and TimeStampFrom then
    self.specialPlayClock = self:AddClock(TimeStampFrom + 2, nil, function()
      log(bWriteLog and "Lobby_Mode_UIBP:SpecialPlayUIUpdate PENDING EndFunc")
      if self and slua.isValid(self.UIRoot) then
        self.specialPlayClock = nil
        self:SpecialPlayUIUpdate(nil, self.specialPlayCfg)
      end
    end)
  end
  self:ShowSpecialPlayPanel()
end
function Lobby_Mode_UIBP:Button_SpecialPlayClick()
  self:PlayAudio(sound_config.click)
  if not self.specialPlayActivityCfg then
    log(bWriteLog and "Lobby_Mode_UIBP:Button_SpecialPlayClick no cfg")
    return
  end
  local jump_url = self.specialPlayActivityCfg.jump_url
  local jump_id = self.specialPlayActivityCfg.face_pic_id
  log_format(bWriteLog and "Lobby_Mode_UIBP:Button_SpecialPlayClick JumpUrl:%s JumpID:%s", tostring(jump_url), tostring(jump_id))
  if jump_url and jump_url ~= "" then
    GlobalData.JumpUrl(jump_url)
  elseif jump_id and jump_id ~= "" then
    UIManager.ShowUI(UIManager.UI_Config.Lobby_BT_Guide_UIBP, jump_id)
  end
end
function Lobby_Mode_UIBP:ShowSpecialPlayPanel()
  log(bWriteLog and "Lobby_Mode_UIBP:ShowSpecialPlayPanel")
  if self.DelayUpdateSpecialPlayPanelTimer then
    self:RemoveTimer(self.DelayUpdateSpecialPlayPanelTimer)
    self.DelayUpdateSpecialPlayPanelTimer = nil
  end
  self.DelayUpdateSpecialPlayPanelTimer = self:AddTimerOnce(0, function()
    if not self or not slua.isValid(self.UIRoot) then
      return
    end
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_SpecialPlay, false)
    if not self.specialPlayActivityCfg then
      log(bWriteLog and "Lobby_Mode_UIBP:ShowSpecialPlayPanel no cfg")
      return
    end
    local hideId = self.specialPlayActivityCfg.hide_id
    local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
    local modID = LogicUGCMatch:GetMatchModID()
    log_format(bWriteLog and "Lobby_Mode_UIBP:ShowSpecialPlayPanel specialPlayHideID:%s modeID:%s", tostring(hideId), tostring(modID))
    if tonumber(modID) == hideId then
      return
    end
    if LobbySystem.isInMatch then
      log(bWriteLog and "Lobby_Mode_UIBP:ShowSpecialPlayPanel isInMatch")
      return
    end
    local canvasPanelState = {}
    for k, v in pairs(canvasPanelState) do
      local widget = self.UIRoot[v]
      if widget and widget.GetVisibility then
        local state = widget:GetVisibility()
        log_format(bWriteLog and "Lobby_Mode_UIBP:ShowSpecialPlayPanel  %s  state:%s", tostring(v), tostring(state))
        if state == UEnums.ESlateVisibility.Visible or state == UEnums.ESlateVisibility.SelfHitTestInvisible or state == UEnums.ESlateVisibility.HitTestInvisible then
          return
        end
      end
    end
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_SpecialPlay, true)
  end)
end
function Lobby_Mode_UIBP:Button_PSSkillSprintClick()
  self:PlayAudio(sound_config.click)
  local psSkill_sprint_util = require("client.slua.logic.psSkill_sprint.psSkill_sprint_util")
  psSkill_sprint_util.OpenMainUI()
end
function Lobby_Mode_UIBP:UpdatePSSkillSprint()
  local psSkill_sprint_util = require("client.slua.logic.psSkill_sprint.psSkill_sprint_util")
  local isTargetView = psSkill_sprint_util.CheckIsSelectedTargetView()
  self:SetWidgetVisible(self.UIRoot.Button_PSSkillSprint, isTargetView, true)
  local config = psSkill_sprint_util.GetCurrentRoleConfig()
  if config then
    self:SetTexture(self.UIRoot.Image_PSSkillSprint_RoleIcon, config.LobbyIcon)
  end
end
function Lobby_Mode_UIBP:SetTDMProtectInfo()
  local logic_tdm_rating_protect = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_tdm_rating_protect)
  local isProtect = logic_tdm_rating_protect:GetIsProtect()
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Protect, isProtect)
  if isProtect then
    self.UIRoot.TextBlock_Protect:SetText(LocUtil.GetLocalizeResStr(612401054))
  end
end
function Lobby_Mode_UIBP:CheckReturnMatchTips()
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
local CLobby_Mode_UIBP = class(ui_base, nil, Lobby_Mode_UIBP)
return CLobby_Mode_UIBP