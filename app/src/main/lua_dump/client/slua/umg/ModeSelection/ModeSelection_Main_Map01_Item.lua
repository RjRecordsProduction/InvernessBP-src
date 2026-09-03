local ModeSelection_Main_Map01_Item = {}
local specialMenuIds = {
  [120] = true,
  [130] = true
}
local PlantViewIds = {
  [1] = 90135,
  [2] = 90136,
  [3] = 90137,
  [4] = 90138,
  [5] = 90139,
  [6] = 90140
}
local PufferConst = require("client.slua.logic.download.puffer_const")
function ModeSelection_Main_Map01_Item:ctor(selfType, itemData, filterInfo, showDelay)
  self:SetData(itemData)
  self.  self.showDelay = showDelay or 0
  self.isShowRatingProtect = false
  self.logic_mode_map_download = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_map_download)
end
function ModeSelection_Main_Map01_Item:SetData(itemData)
  self.data = itemData
  if itemData == nil then
    return
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  self.themeData = logic_mode_selection:GetValidThemeData(itemData.id, true)
  self.isSelectTheme = self:GetIsSelectTheme(itemData, self.themeData)
end
function ModeSelection_Main_Map01_Item:OnInitialize()
  ModeSelection_Main_Map01_Item.__super.OnInitialize(self)
  self.util = require("client.slua_ui_framework.util")
  if self.UIRoot.LoopScrollBox_Group then
    self.GroupScroll = self:InitScrollBox(self.UIRoot.LoopScrollBox_Group)
  end
  if self.UIRoot.LoopScrollBox_Maps then
    self.LoopScrollBox_Maps = self:InitScrollBox(self.UIRoot.LoopScrollBox_Maps)
  end
  if self.UIRoot.Image_Guide_New then
    self:SetWidgetVisible(self.UIRoot.Image_Guide_New, false)
  end
end
function ModeSelection_Main_Map01_Item:RegistEvents()
  ModeSelection_Main_Map01_Item.__super.RegistEvents(self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Detail, self.OnButton_DetailClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Item, self.OnButton_ItemClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Theme, self.OnButton_ThemeClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Theme1, self.OnButton_ThemeClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_RatingProtect, self.OnButton_RatingProtectClick, self)
  if self.UIRoot and self.UIRoot.Button_Group then
    self:AddOnClickedEventByControl(self.UIRoot.Button_Group, self.OnButton_GroupClick, self)
  end
  self:AddOnClickedEventByControl(self.UIRoot.Common_Download_Item_Style_Two.Button_Download, self.OnButton_DownloadClick, self)
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_MATCH_MODE_MAIN_FILTER_CHANGE, self.OnSyncFilterInfo, self)
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_MATCH_MAP_DOWNLOAD, self.OnUpdateDownloadState, self)
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_MATCH_MAP_DOWNLOAD_START, self.OnUpdateDownloadState, self)
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_MATCH_MAP_DOWNLOAD_ERROR, self.OnUpdateDownloadState, self)
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_MATCH_MAP_DOWNLOAD_RETURN, self.OnUpdateDownloadState, self)
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_MATCH_MAP_DOWNLOAD_PAUSE, self.OnUpdateDownloadState, self)
  self:AddCommonEvent(EVENTTYPE_DOWNLOAD, EVENTID_PUFFER_DOWNLOAD_PROGRESS, self.OnUpdateDownloadState, self)
  self:AddCommonEvent(EVENTTYPE_PUFFER, EVENTID_PUFFER_DOWNLOADPROGRESS, self.OnUpdateDownloadState, self)
  self:AddCommonEvent(EVENTTYPE_PUFFER, EVENTID_PUFFER_DOWNLOADFINISH, self.OnUpdateDownloadState, self)
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_STOP_MAP_ANIMATION, self.StopAnimationPlay, self)
  self:AddCommonEvent(EVENTTYPE_ACTIVITY, EVENTID_RATING_PROTECT_ACTIVITY_GET_CONFIG, self.RefreshRatingProtectData, self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, self.OnRefreshRatingProtectAct, self)
  self:AddCommonEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_PLANTINFO, self.UpdateThemePlantGuide, self)
  self:AddControlEventByControl(self.UIRoot.Animation_Change, "OnAnimationFinished", self.OnAnimationChangeEnd, self)
  self:AddControlEventByControl(self.UIRoot.Animation_Change02, "OnAnimationFinished", self.OnAnimationChange2End, self)
  self:AddControlEventByControl(self.UIRoot.Animation_Appear, "OnAnimationFinished", self.OnAnimationAppearEnd, self)
  if self.GroupScroll then
    self.GroupScroll:SetRefreshItemCallback(self.OnGroupItemRefresh, self)
    self.GroupScroll:AddItemWidgetChildEvent("Button_Item", "OnClicked", self.OnGroupItemClick, self)
  end
  if self.UIRoot.Button_RankReward then
    self:AddOnClickedEventByControl(self.UIRoot.Button_RankReward, self.OnButton_RankReward, self)
    self:AddCommonEvent(EVENTTYPE_ARENA, EVENTID_ARENA_GET_AWARD_RSP, self.UpdateRankRewardRedDot, self)
    self:AddCommonEvent(EVENTTYPE_ODPAKS, EVENTID_ODPAKS_UPDATEBUTTON, self.RefreshItem, self)
  end
  if self.UIRoot.Button_Update then
    self:AddOnClickedEventByControl(self.UIRoot.Button_Update, self.OnButton_DetailClick, self)
  end
  if self.UIRoot.Button_PSSkillSprint then
    self:AddOnClickedEventByControl(self.UIRoot.Button_PSSkillSprint, self.Button_PSSkillSprintClick, self)
    self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_ON_PSSKILL_SPRINT_ROLE_UPDATE, self.UpdatePSSkillSprint, self)
  end
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_LOBBY_NEWBIE_GUIDE_PLAYMODE_END, self.OnAnimHide, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_LOBBY_NEWBIE_GUIDE_PLAYMODE_BEGIN, self.OnAnimShow, self)
end
function ModeSelection_Main_Map01_Item:OnAnimationChangeEnd()
  self.UIRoot.Image_MapA:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self.UIRoot.Image_MapB:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self.UIRoot.Image_MapABuf:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.Image_MapBBuf:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function ModeSelection_Main_Map01_Item:OnAnimationChange2End()
  self.UIRoot.Image_MapA:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self.UIRoot.Image_MapB:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self.UIRoot.Image_MapABuf:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.Image_MapBBuf:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function ModeSelection_Main_Map01_Item:OnAnimationAppearEnd()
  EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_MATCH_MODE_VIEW_ITEM_ANIM_APPEAR_END, self, self.data.id)
  if Client.IsJaguar() then
    return
  end
  if UIManager.IsUIShow(UIManager.UI_Config.NewUGCMainPanel) then
    return
  end
  if self.UIRoot and self.UIRoot.CanvasPanel_Group then
    self.UIRoot.CanvasPanel_Group:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function ModeSelection_Main_Map01_Item:OnPostInitialize()
  ModeSelection_Main_Map01_Item.__super.OnPostInitialize(self)
  self:RefreshItem()
  if self.showDelayTimer then
    self:RemoveTimer(self.showDelayTimer)
    self.showDelayTimer = nil
  end
  self:UpdateIsNeedNewbieGuide()
  self:UpdateThemeChangeGuide()
  local UIUtil = require("client.common.ui_util")
  if self.showDelay >= 0 then
    self.UIRoot.CanvasPanel_0:SetWidgetVisibility(UIUtil.BoolToVisible(false, false))
    self.showDelayTimer = self:AddTimerOnce(self.showDelay, function()
      self.UIRoot.CanvasPanel_0:SetWidgetVisibility(UIUtil.BoolToVisible(true))
      self:PlayEnterAnimation()
      local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
      local matchMode, curSelectViewId, curSelectViewIds = logic_mode_selection:GetCurSelectInfo()
      local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
      local scrollId = mode_selection_macro.scrollViewId
      if self.data.id == curSelectViewId or self.themeData and self.themeData.id == curSelectViewId then
        self:PlayUserWidgetAnimation(self.UIRoot.Animation_Seletion_Loop, 0, 0, 0, 1)
      elseif scrollId == self.data.id then
        self:PlayUserWidgetAnimation(self.UIRoot.Animation_Seletion_Loop, 0, 0, 0, 1)
        mode_selection_macro.scrollViewId = nil
      else
        self.UIRoot:StopAnimation(self.UIRoot.Animation_Seletion_Loop)
      end
      local LogicPeakGameUtil = require("client.logic.PeakGame.LogicPeakGameUtil")
      if LogicPeakGameUtil.IsPeakGameBattleTypeIgnoreSwitch(matchMode) and specialMenuIds[self.data.menu_id] then
        self:PlayUserWidgetAnimation(self.UIRoot.Animation_Seletion_Loop, 0, 0, 0, 1)
      end
      self:RemoveTimer(self.showDelayTimer)
      self.showDelayTimer = nil
    end)
  else
    self.UIRoot.CanvasPanel_0:SetWidgetVisibility(UIUtil.BoolToVisible(true))
  end
  self.UIRoot:StopAnimation(self.UIRoot.Animation_Change)
  self.UIRoot:StopAnimation(self.UIRoot.Animation_Change02)
  if self.themeData then
    self.UIRoot.Image_MapA:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.Image_MapB:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.Image_MapABuf:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.Image_MapBBuf:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    if self.isSelectTheme then
      self:PlayUserWidgetAnimation(self.UIRoot.Animation_Change, 0, 1, 0, 1)
    else
      self:PlayUserWidgetAnimation(self.UIRoot.Animation_Change02, 0, 1, 0, 1)
    end
  else
    self.UIRoot.Image_MapA:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.Image_MapB:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.Image_MapABuf:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.Image_MapBBuf:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  self:UpdateRankRewardRedDot()
  self:UpdateTXmissionView()
  self:UpdateAsymmetricView()
  self:UpdatePSSkillSprint()
end
function ModeSelection_Main_Map01_Item:UpdateTXmissionView()
  if not self.UIRoot.CanvasPanel_Desc or not self.UIRoot.CanvasPanel_Subway then
    return
  end
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Desc, true)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Subway, false)
  if self.data.id == 20000 or self.data.id == 20010 or self.data.id == 90112 then
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_Desc, false)
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_Subway, true)
    self.UIRoot.TextBlock_subway:SetText(LocUtil.GetLocalizeResStr(self.data.describe))
    self:SetTexture(self.UIRoot.Image_Logo, self.data.id == 90112 and "/Game/UMG/Texture/Lobby_NoAtlas/Lobby_Match_SelectMap/ModeSelection_New/Icon/Lobby_match_lcon04.Lobby_match_lcon04" or "/Game/UMG/Texture/Lobby_NoAtlas/Lobby_Match_SelectMap/ModeSelection_New/Icon/Lobby_match_lcon03.Lobby_match_lcon03")
  end
end
function ModeSelection_Main_Map01_Item:UpdateAsymmetricView()
  if self.UIRoot.CanvasPanel_EscapeTips then
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_EscapeTips, false)
  end
  if self.UIRoot.ModeSelection_Main_Map03_SubItem_UIBP then
    self:SetWidgetVisible(self.UIRoot.ModeSelection_Main_Map03_SubItem_UIBP, false)
  end
  if self.UIRoot.CanvasPanel_QuickCreateRoom then
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_QuickCreateRoom, false)
  end
end
function ModeSelection_Main_Map01_Item:UpdateRankRewardRedDot()
  if not self.UIRoot.Image_RedDot then
    return
  end
  local ArenaSystem = require("client.slua.logic.arena.logic_arena")
  if ArenaSystem.HaveAwardToGet() then
    self.UIRoot.Image_RedDot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UIRoot.Image_RedDot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function ModeSelection_Main_Map01_Item:UpdateIsNeedNewbieGuide()
end
function ModeSelection_Main_Map01_Item:UpdateThemeChangeGuide()
end
function ModeSelection_Main_Map01_Item:UpdateThemePlantGuide()
  if self.data.group_type and self.data.group_type == "theme" then
    local viewid = self.isSelectTheme and self.themeData.id or self.data.id
    local plantKey = 0
    for key, value in pairs(PlantViewIds) do
      if value == viewid then
        plantKey = key
        break
      end
    end
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_Plant, plantKey ~= 0)
    if plantKey ~= 0 then
      local logic_theme_system = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_theme_system)
      local plantInfo = logic_theme_system:GetSinglePlantInfo(plantKey)
      local progress = plantInfo and plantInfo.progress or nil
      log(bWriteLog and "ModeSelection_Main_Map01_Item.UpdateThemePlantGuide progress = " .. tostring(progress) .. " plantKey = " .. tostring(plantKey))
      log_tree(bWriteLog and "ModeSelection_Main_Map01_Item.UpdateThemePlantGuide plant_info = ", plantInfo)
      if self.UIRoot.WidgetSwitcher_5 then
        if progress == nil then
          self.UIRoot.WidgetSwitcher_5:SetActiveWidgetIndex(3)
        elseif progress == 0 then
          self.UIRoot.WidgetSwitcher_5:SetActiveWidgetIndex(2)
        elseif progress == 1 then
          self.UIRoot.WidgetSwitcher_5:SetActiveWidgetIndex(1)
        else
          self.UIRoot.WidgetSwitcher_5:SetActiveWidgetIndex(0)
        end
      end
    end
  else
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_Plant, false)
  end
end
function ModeSelection_Main_Map01_Item:PlayEnterAnimation()
  self.UIRoot:StopAnimation(self.UIRoot.Animation_Theme_Appear)
  self:PlayUserWidgetAnimation(self.UIRoot.Animation_Appear, 0, 1, 0, 1)
end
function ModeSelection_Main_Map01_Item:ShowDownLoadTips()
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  if self.totalSize and self.curSize then
    local size = math.floor((self.totalSize - self.curSize) / PufferConst.MB + 0.5)
    size = math.max(size, 1)
    local fun = function()
      self:OnButton_DownloadClick()
    end
    CommonMsgBoxMgr.Show(2, nil, LocUtil.LocalizeResFormat(45001, size), fun)
  end
end
function ModeSelection_Main_Map01_Item:_GetMapKeyInfo()
  return self:GetMapKeyInfo(self.UIRoot, self.data, self.themeData, self.isSelectTheme)
end
function ModeSelection_Main_Map01_Item:RefreshItem()
  self:SetItemData(self.UIRoot, self.data, self.themeData, self.isSelectTheme)
  self.mapKeyList, self.mapKeyDict = self:_GetMapKeyInfo()
  self.mapPakNames = {}
  if self.mapKeyList then
    local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
    for k, mapKey in pairs(self.mapKeyList) do
      local pakName = PufferMapManager:GetMapPakName(mapKey)
      if pakName ~= "" then
        self.mapPakNames[pakName] = true
      end
    end
  end
  self.UIRoot.Common_Download_Item_Style_Two:SetWidgetVisibility(UEnums.GSlateVisibility.Collapsed)
  if self.data.menu_id ~= 120 then
    self.downloadStatus, self.curSize, self.totalSize = self:RefreshDownloadInfo(self.UIRoot.Common_Download_Item_Style_Two, self.mapKeyList, self.data)
    if self.downloadStatus == ENUM_DownloadState.Not and self.totalSize - self.curSize < PufferConst.MB * 5 then
      self:OnButton_DownloadClick(true)
    end
  end
  self:RefreshRatingProtectData()
  self:SetLimitStateFilter(self.isSelectTheme and self.themeData or self.data, self.filterInfo)
end
function ModeSelection_Main_Map01_Item:OnClose()
  self.logic_mode_map_download = nil
  self.UIRoot:StopAnimation(self.UIRoot.Animation_TopIn)
  ModeSelection_Main_Map01_Item.__super.OnClose(self)
  UIManager.CloseUI(UIManager.UI_Config.NewbieGuide_UIBP)
end
function ModeSelection_Main_Map01_Item:OnButton_DetailClick()
  self:PlayAudio(sound_config.click)
  local viewID = self.data.id
  local config_arena = require("client.slua.logic.arena.config_arena")
  if self.data.menu_id == 120 then
    viewID = 90069
  elseif self.data.menu_id == config_arena.ModeMenuId then
    viewID = 90117
  end
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.NewModeSelection_ClickViewDetailIntroduce, 0, viewID)
  if self.data.group_type and self.data.group_type == "group" then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eModeSelectionMainUI) or {}
    local select = 1
    if cfg.groupSelect and cfg.groupSelect[self.data.id] then
      select = cfg.groupSelect[self.data.id]
    end
    if self.data.group_view and self.data.group_view[select] then
      viewID = self.data.group_view[select].view_id
    end
  elseif self.data.group_type and self.data.group_type == "theme" then
    viewID = self.isSelectTheme and self.themeData.id or self.data.id
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  if self.UIRoot.CanvasPanel_4 and self.UIRoot.CanvasPanel_Update then
    local isNew2 = logic_mode_selection:IsSubViewNew2(viewID)
    if isNew2 then
      logic_mode_selection:ClickSubViewDetail(viewID)
      self:RefreshItem()
    end
  end
  logic_mode_selection:OpenModeSelectionDetails(viewID)
end
function ModeSelection_Main_Map01_Item:StopAnimationPlay()
  if slua.isValid(self.UIRoot.Animation_Seletion_Loop) and self.UIRoot.Animation_Seletion_Loop then
    self.UIRoot:StopAnimation(self.UIRoot.Animation_Seletion_Loop)
  end
end
function ModeSelection_Main_Map01_Item:OnButton_ItemClick()
  if not self or not self.UIRoot then
    return
  end
  self:PlayAudio(sound_config.click)
  if self.itemClickCallback then
    self.itemClickCallback()
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if self.data.hot_status and self.data.hot_status == 2 and TeamUpNewSystem.IsTeamLeader() then
    ShowNotice(42665)
    return
  end
  EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_STOP_MAP_ANIMATION)
  self:PlayUserWidgetAnimation(self.UIRoot.Animation_Seletion_Loop, 0, 0, 0, 1)
  self:PlayUserWidgetAnimation(self.UIRoot.Animation_Seletion, 0, 1, 0, 1)
  if self.lockState == self.Enum_Lock_State.Level then
    ShowNotice(LocUtil.LocalizeResFormat(31028, self.data.level_limit))
    if self.data.aux_name == 11625 then
      ClientSendTLogReport(TLogEventDefine.TPlan_Enter_Block, 0, tostring(DataMgr.roleData.level))
    end
    return
  elseif self.lockState == self.Enum_Lock_State.Time then
    if self.nStartTime then
      local TimeUtil = require("client.common.time_util")
      ShowNotice(LocUtil.LocalizeResFormat(27754, TimeUtil.FormatCountDownTime_D_or_HMS(self.nStartTime - TimeUtil.GetServerTimeInSec())))
    end
    return
  end
  local viewid = self.data.id
  if self.data.group_type and self.data.group_type == "group" then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eModeSelectionMainUI) or {}
    local select = 1
    if cfg.groupSelect and cfg.groupSelect[self.data.id] then
      select = cfg.groupSelect[self.data.id]
    end
    if self.data.group_view and self.data.group_view[select] then
      viewid = self.data.group_view[select].view_id
    end
  elseif self.data.group_type and self.data.group_type == "theme" then
    viewid = self.isSelectTheme and self.themeData.id or self.data.id
    if self.isSelectTheme and self.themeData.hot_status and self.themeData.hot_status == 2 and TeamUpNewSystem.IsTeamLeader() then
      self.UIRoot:StopAnimation(self.UIRoot.Animation_Seletion_Loop, 0, 0, 0, 1)
      self.UIRoot:StopAnimation(self.UIRoot.Animation_Seletion, 0, 1, 0, 1)
      ShowNotice(42665)
      return
    end
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  logic_mode_selection:ClickSubView(viewid)
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  local feature = level_unlock_manager:GetCurrentGuideFeature()
  local pveMode = level_unlock_manager.featureDef.pveMode
  if self.data.id == 10353 and feature == pveMode then
    level_unlock_manager:OnClickFeature(pveMode)
  end
  EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_MATCH_MODE_VIEW_CLICK, viewid)
end
function ModeSelection_Main_Map01_Item:OnButton_ThemeClick()
  self:PlayAudio(sound_config.click)
  self:SendTLogClickBtnTheme()
  self.isSelectTheme = not self.isSelectTheme
  self:SetIsSelectTheme(self.data, self.isSelectTheme)
  self:RefreshItem()
  self:UpdatePSSkillSprint()
  if self.isSelectTheme then
    self.UIRoot:StopAnimation(self.UIRoot.Animation_Change)
    self.UIRoot:StopAnimation(self.UIRoot.Animation_Change02)
    self:PlayUserWidgetAnimation(self.UIRoot.Animation_Change, 0, 1, 0, 1)
  else
    self.UIRoot:StopAnimation(self.UIRoot.Animation_Change)
    self.UIRoot:StopAnimation(self.UIRoot.Animation_Change02)
    self:PlayUserWidgetAnimation(self.UIRoot.Animation_Change02, 0, 1, 0, 1)
  end
end
function ModeSelection_Main_Map01_Item:SendTLogClickBtnTheme()
  local viewID
  if self.isSelectTheme then
    viewID = self.themeData and self.themeData.id
  else
    viewID = self.data and self.data.id
  end
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.NewModeSelection_ClickBtnTheme, 0, viewID)
end
function ModeSelection_Main_Map01_Item:OnButton_RankReward()
  self:PlayAudio(sound_config.click)
  UIManager.ShowUI(UIManager.UI_Config.arena_main, true)
end
function ModeSelection_Main_Map01_Item:OnButton_GroupClick()
  self:PlayAudio(sound_config.click)
  self.UIRoot.CanvasPanel_Group:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
end
function ModeSelection_Main_Map01_Item:OnButton_DownloadClick(b4GNotDownload)
  if not b4GNotDownload then
    self:PlayAudio(sound_config.click)
  end
  if not self.mapKeyList or not self.downloadStatus then
    return
  end
  if self.downloadStatus == ENUM_DownloadState.Download then
    self:PausedMapKeyList(self.mapKeyList)
  else
    self:DownloadMapKeyList(self.mapKeyList, b4GNotDownload)
  end
end
function ModeSelection_Main_Map01_Item:OnButton_RatingProtectClick()
  self:PlayAudio(sound_config.click)
  local LogicRatingProtectActivity = require("client.slua.logic.activity.rating_protect_activity.logic_rating_protect_activity")
  local viewId = self.isSelectTheme and self.themeData.id or self.data.id
  local ifShowRatingProtectBanner, activityId = LogicRatingProtectActivity.CheckModeHasRatingProtectActivity(viewId)
  if not ifShowRatingProtectBanner then
    return
  end
  local remainNum = LogicRatingProtectActivity.GetRatingProtectRemainNumber(activityId)
  local startTime, endTime = LogicRatingProtectActivity.GetRatingProtectActivityTimeById(activityId)
  local TimeUtil = require("client.common.time_util")
  local time = TimeUtil.FormatTime_timeFrame(startTime, endTime, false, true)
  local UIUtil = require("client.common.ui_util")
  local tipPos = UIUtil.GetWidgetViewportPos(self.UIRoot.Button_RatingProtect)
  local helpTipsUI = UIManager.ShowUI(UIManager.UI_Config.Common_HelpTips_UIBP)
  if helpTipsUI then
    helpTipsUI:ShowPanelStrWithPos(LocUtil.LocalizeFormatConcatenation(52019, remainNum, time), tipPos.X - 50, tipPos.Y - 15, true, true)
  end
end
function ModeSelection_Main_Map01_Item:OnUpdateDownloadState(evtType, evtID, eventData)
  ModeSelection_Main_Map01_Item.__super.DownloadResRet(self, evtType, evtID, eventData)
  if not (self.mapPakNames and self.mapKeyList) or self.data.menu_id == 120 then
    return
  end
  if eventData.packID and eventData.packID == 70002 then
    self.downloadStatus = self:RefreshDownloadInfo(self.UIRoot.Common_Download_Item_Style_Two, self.mapKeyList, self.data)
    return
  end
  local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
  local pakName = eventData.pakName
  if pakName and self.mapPakNames[pakName] then
    self.downloadStatus = self:RefreshDownloadInfo(self.UIRoot.Common_Download_Item_Style_Two, self.mapKeyList, self.data)
    return
  else
    local undependState = self.logic_mode_map_download:GetMapListStateSkipDepend(self.mapKeyList)
    if undependState and undependState ~= PufferConst.ENUM_DownloadState.Done then
      return
    end
    local dependKey = pakName
    for _, v in pairs(self.mapKeyList) do
      if PufferMapManager:IsDepend(v, dependKey, true) then
        self.downloadStatus = self:RefreshDownloadInfo(self.UIRoot.Common_Download_Item_Style_Two, self.mapKeyList, self.data)
        break
      end
    end
  end
end
function ModeSelection_Main_Map01_Item:OnSyncFilterInfo(_, _, filterInfo)
  self.  self:SetLimitStateFilter(self.isSelectTheme and self.themeData or self.data, self.filterInfo)
end
function ModeSelection_Main_Map01_Item:SetLimitStateFilter(data, filterInfo)
  self.lockState = self.Enum_Lock_State.Not
  log(bWriteLog and "[edward] ModeSelection_Main_Map01_Item:SetLimitStateFilter" .. tostring(data))
  log(bWriteLog and "[edward] ModeSelection_Main_Map01_Item:SetLimitStateFilter" .. tostring(filterInfo))
  if not data or not filterInfo then
    return
  end
  if data.group_type and data.group_type == "group" then
    if self.UIRoot.WidgetSwitcher_3 then
      self.UIRoot.WidgetSwitcher_3:SetActiveWidgetIndex(1)
    end
    self:SetGroupData()
  elseif self.UIRoot.WidgetSwitcher_3 then
    self.UIRoot.WidgetSwitcher_3:SetActiveWidgetIndex(0)
  end
  ModeSelection_Main_Map01_Item.__super.SetLimitStateFilter(self, data, filterInfo)
  if self.UIRoot.Image_lock then
    local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
    local Enum_Lock_State = mode_selection_macro.Enum_Lock_State
    if self.lockState and self.lockState == Enum_Lock_State.Time and self.downloadStatus and self.downloadStatus == ENUM_DownloadState.Done then
      self.UIRoot.Image_lock:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
      self.UIRoot.Image_lock:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  if self.UIRoot.CanvasPanel_4 and self.UIRoot.CanvasPanel_Update then
    local isNew2 = logic_mode_selection:IsSubViewNew2(data.id)
    log(bWriteLog and "[v_yunjxing1] logic_mode_selection:IsSubViewNew2 " .. tostring(isNew2) .. self.data.id)
    if isNew2 then
      self.UIRoot.TextBlock_ModePrompt:SetText(LocUtil.GetLocalizeResStr(665487))
      self.UIRoot.CanvasPanel_Update:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
      self:AddTimerOnce(0.25, function()
        self:PlayUserWidgetAnimation(self.UIRoot.Animation_TopIn, 0, 1, 0, 1)
      end)
      self:AddTimerOnce(0.5, function()
        self:PlayUserWidgetAnimation(self.UIRoot.Animation_TopLoop, 0, 0, 0, 1)
      end)
      if self.UIRoot.SizeBox_3 then
        self.UIRoot.SizeBox_3.Slot:SetPosition(FVector2D(0, 38))
      end
    else
      self.UIRoot.CanvasPanel_Update:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      if self.UIRoot.SizeBox_3 then
        self.UIRoot.SizeBox_3.Slot:SetPosition(FVector2D(0, 0))
      end
    end
  end
end
function ModeSelection_Main_Map01_Item:SetGroupData()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eModeSelectionMainUI) or {}
  local select = 1
  if cfg.groupSelect and cfg.groupSelect[self.data.id] then
    select = cfg.groupSelect[self.data.id]
  end
  self.GroupScroll:SetData(self.data.group_view)
  self.UIRoot.TextBlock_Group:SetText(LocUtil.LocalizeResFormat(self.data.group_view[select].show_name))
end
function ModeSelection_Main_Map01_Item:OnGroupItemRefresh(widget, index)
  local data = self.GroupScroll:GetItemData(index)
  widget.TextBlock_Name:SetText(LocUtil.LocalizeResFormat(data.show_name))
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local viewData = logic_mode_selection:GetSubviewInfoBySubviewID(data.view_id)
  if viewData.level_limit <= DataMgr.roleData.level then
    widget.TextBlock_Name:SetColorAndOpacity(FSlateColor(FLinearColor(1, 1, 1, 1)))
    widget.Image_Lock:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    widget.TextBlock_Name:SetColorAndOpacity(FSlateColor(FLinearColor(1, 1, 1, 0.5)))
    widget.Image_Lock:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
end
function ModeSelection_Main_Map01_Item:OnGroupItemClick(widget, index)
  self:PlayAudio(sound_config.click)
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local data = self.GroupScroll:GetItemData(index)
  local viewData = logic_mode_selection:GetSubviewInfoBySubviewID(data.view_id)
  if not viewData then
    return
  end
  if viewData.level_limit > DataMgr.roleData.level then
    ShowNotice(LocUtil.LocalizeResFormat("6573", viewData.level_limit))
    return
  end
  self.UIRoot.CanvasPanel_Group:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.TextBlock_Group:SetText(LocUtil.LocalizeResFormat(data.show_name))
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eModeSelectionMainUI) or {}
  cfg.groupSelect = cfg.groupSelect or {}
  cfg.groupSelect[self.data.id] = index
  PlayerPrefsSystem.SaveTableToFile_N(cfg, PlayerPrefsSystem.ePlayerPrefsType.eModeSelectionMainUI)
end
function ModeSelection_Main_Map01_Item:OnRefreshRatingProtectAct()
  log(bWriteLog and "ModeSelection_Main_Map01_Item:OnRefreshRatingProtectAct Data is change")
  self:RefreshRatingProtectData()
end
function ModeSelection_Main_Map01_Item:RefreshRatingProtectData()
  if not slua.isValid(self.UIRoot) then
    log(bWriteLog and "ModeSelection_Main_Map01_Item:RefreshRatingProtectData uiroot is invalid!")
    return
  end
  self:UpdateThemePlantGuide()
  local viewId = self.isSelectTheme and self.themeData and self.themeData.id or self.data.id
  local isRank = self.data.is_ranked
  if not isRank or isRank ~= 1 then
    log(bWriteLog and "ModeSelection_Main_Map01_Item:RefreshRatingProtectData is not ranked")
    self.UIRoot.WidgetSwitcher_Desc:SetActiveWidgetIndex(0)
    self.isShowRatingProtect = false
    return
  end
  local isLastShowBanner = self.isShowRatingProtect
  local LogicRatingProtectActivity = require("client.slua.logic.activity.rating_protect_activity.logic_rating_protect_activity")
  local ifShowRatingProtectBanner, activityId = LogicRatingProtectActivity.CheckModeHasRatingProtectActivity(viewId)
  self.isShowRatingProtect = ifShowRatingProtectBanner
  self.UIRoot.WidgetSwitcher_Desc:SetActiveWidgetIndex(ifShowRatingProtectBanner and 1 or 0)
  if not ifShowRatingProtectBanner then
    log(bWriteLog and "ModeSelection_Main_Map01_Item:RefreshRatingProtectData not show")
    return
  end
  if not isLastShowBanner then
    self:PlayUserWidgetAnimation(self.UIRoot.Animation_NoPoints, 0, 1, 0, 1)
  end
  local actData = LogicRatingProtectActivity.GetRatingProtectActivityDataById(activityId)
  local key = 52014
  if LogicRatingProtectActivity.IsReturnRatingProtectAct(actData) then
    key = 52021
  end
  local remainNum = LogicRatingProtectActivity.GetRatingProtectRemainNumber(activityId)
  self.UIRoot.TextBlock_RatingProtect:SetText(LocUtil.LocalizeResFormat(key, remainNum))
end
function ModeSelection_Main_Map01_Item:SetMapData(data, filterInfo)
  self:SetData(data)
  self:OnSyncFilterInfo(nil, nil, filterInfo)
  self:RefreshItem()
end
function ModeSelection_Main_Map01_Item:OnHide()
  log(bWriteLog and "ModeSelection_Main_Map01_Item:OnHide")
  if UIManager.GetUI(UIManager.UI_Config.NewbieGuide_UIBP) then
    UIManager.CloseUI(UIManager.UI_Config.NewbieGuide_UIBP)
  end
end
function ModeSelection_Main_Map01_Item:Button_PSSkillSprintClick()
  self:PlayAudio(sound_config.click)
  local psSkill_sprint_util = require("client.slua.logic.psSkill_sprint.psSkill_sprint_util")
  psSkill_sprint_util.OpenMainUI()
end
function ModeSelection_Main_Map01_Item:UpdatePSSkillSprint()
  if not self.UIRoot.Button_PSSkillSprint then
    return
  end
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_PSSkillSprint, false)
  local psSkill_sprint_util = require("client.slua.logic.psSkill_sprint.psSkill_sprint_util")
  local config = psSkill_sprint_util.GetCurrentRoleConfig()
  if config then
    self.UIRoot.TextBlock_PSSkillSprint_Role:SetText(LocUtil.LocalizeResFormat(config.Name))
    self:SetTexture(self.UIRoot.Image_PSSkillSprint_RoleIcon, config.LobbyIcon)
  end
end
function ModeSelection_Main_Map01_Item:OnAnimShow()
  log(bWriteLog and "ModeSelection_Main_Map01_Item:OnAnimShow")
  local themedata = self.themeData
  if themedata and self.UIRoot.Image_Highlight then
    self:SetWidgetVisible(self.UIRoot.Image_Highlight, true)
  else
    self:SetWidgetVisible(self.UIRoot.Image_Highlight, false)
  end
end
function ModeSelection_Main_Map01_Item:OnAnimHide()
  log(bWriteLog and "ModeSelection_Main_Map01_Item:OnAnimHide")
  if self.UIRoot.Image_Highlight then
    self:SetWidgetVisible(self.UIRoot.Image_Highlight, false)
  end
end
local class = require("class")
local ui_base = require("client.slua.umg.ModeSelection.ModeSelection_Main_Item_Base")
local CModeSelection_Main_Map01_Item = class(ui_base, nil, ModeSelection_Main_Map01_Item)
return CModeSelection_Main_Map01_Item