local UI_Lobby_Downloader_Btn = {}
local LogicPufferBundle = require("client.slua.logic.download.bundle.logic_puffer_bundle")
local PufferConst = require("client.slua.logic.download.puffer_const")
local PufferSwitch = require("client.slua.logic.download.puffer_switch")
function UI_Lobby_Downloader_Btn:ctor()
  self.needRefreshPercent = true
end
function UI_Lobby_Downloader_Btn:OnInitialize()
  UI_Lobby_Downloader_Btn.__super.OnInitialize(self)
  self.util = require("client.slua_ui_framework.util")
  local UIUtil = require("client.common.ui_util")
  UIUtil.SetAdaptation(self.UIRoot.CanvasPanel_IPX)
end
function UI_Lobby_Downloader_Btn:RegistEvents()
  UI_Lobby_Downloader_Btn.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_DOWNLOAD, EVENTID_PUFFER_JSON_POSTPROCESS, self.OnPufferJsonPostProcess, self)
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_LOBBY_DOWNLOAD, self.RefreshDownloadPercent, self)
  self:AddCommonEvent(EVENTTYPE_DOWNLOAD, EVENTID_PUFFER_REFRESHALL, self.RefreshDownloadPercent, self)
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_MATCH_MAP_DOWNLOAD_ERROR, self.RefreshDownloadPercent, self)
  self:AddCommonEvent(EVENTTYPE_ODPAKS, EVENTID_ODPAKS_UPDATEBUTTON, self.RefreshReddot, self)
  self:AddCommonEvent(EVENTTYPE_DOWNLOAD, EVENTID_PUFFER_DELETE_SUCCESS, self.RefreshReddot, self)
  self:AddCommonEvent(EVENTTYPE_DOWNLOAD, EVENTID_DOWNLOADER_BTN_SHOWHIDE, self.ShowOrHideBtn, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY_SOCIAL, EVENTID_LOBBY_SOCIAL_PHOTO, self.ShowOrHideBtn, self)
  self:AddCommonEvent(EVENTTYPE_PUFFER, EVENTID_PUFFER_DOWNLOADPROGRESS, self.SetPercentRefreshFlag, self)
  self:AddCommonEvent(EVENTTYPE_PUFFER, EVENTID_PUFFER_DOWNLOADFINISH, self.SetPercentRefreshFlag, self)
  self:AddCommonEvent(EVENTTYPE_PUFFER, EVENTID_PUFFER_PAUSEALLDOWNLOAD, self.SetPercentRefreshFlag, self)
  self:AddCommonEvent(EVENTTYPE_PUFFER, EVENTID_RESERVE_REFRESH, self.RefreshReddot, self)
  self:AddCommonEvent(EVENTTYPE_PUFFER, EVENTID_PUFFER_STARTDOWNLOAD_ODPACK, self.OnDownloadODPackStart, self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_DOWNLOADER, self.OnHandleClick, self)
  self:AddControlEventByControl(self.UIRoot.CommonDragDropItem, "OnDragSuccess", self.OnDragSuccess, self)
  self:AddControlEventByControl(self.UIRoot.CommonDragDropItem, "OnDragReadyToShape", self.OnDrag, self)
  self:AddControlEventByControl(self.UIRoot.CommonDragDropItem, "OnDragCanceled", self.OnDragCancel, self)
  self:AddControlEventByControl(self.UIRoot.CommonDragDropItem, "OnDragClicked", self.OnClickBtn, self)
end
function UI_Lobby_Downloader_Btn:OnPostInitialize()
  UI_Lobby_Downloader_Btn.__super.OnPostInitialize(self)
  self:AddTimerOnce(0, function()
    self:InitUI()
    self:InitDrag()
  end)
  self:AddTimerLoop(1.5, function()
    self:RefreshReddot()
    self:UpdateButtonState()
  end, TIMER_INFINITE, 1.5)
  self:InitPercentRefresher()
  if PufferSwitch.AutoDownloadCfg.RecommendType == PufferConst.Enum_RecommendType.None then
    self:AddTimerOnce(3, function()
      PufferSwitch.AutoDownloadCfg.RecommendType = PufferSwitch.GetRecommendIndex()
    end)
  end
end
function UI_Lobby_Downloader_Btn:OnClose()
  log(bWriteLog and "UI_Lobby_Downloader_Btn.OnClose ")
  if self.UIRoot.CommonDragDropItem.dragDropWidget then
    log(bWriteLog and "UI_Lobby_Downloader_Btn.OnClose Hide CommonDragDropItem")
    self.UIRoot.CommonDragDropItem.dragDropWidget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function UI_Lobby_Downloader_Btn:InitUI()
  log(bWriteLog and "UI_Lobby_Downloader_Btn:InitUI")
  self.UIRoot.CanvasPanel_Downloading_ODPack:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function UI_Lobby_Downloader_Btn:InitPercentRefresher()
  if not slua.isValid(self.UIRoot) then
    return
  end
  local mat = self.UIRoot.Image_Progress:GetDynamicMaterial()
  if mat then
    mat:SetScalarParameterValue("Mask_Percent", 0)
  end
  self:AddTimerLoop(10, function()
    if self.needRefreshPercent then
      self:RefreshDownloadPercent()
      self.needRefreshPercent = false
    end
  end, TIMER_INFINITE, 1)
end
function UI_Lobby_Downloader_Btn:InitDrag()
  self.UIRoot.CommonDragDropItem:SetDragEnable(true)
  self.UIRoot.CommonDragDropItem:RegisterDrag(1, 0, 0, "")
  self.UIRoot.CommonDragDropItem:SetEnable(true)
  self.UIRoot.CommonDragDropItem:SetAllDirectionEnable(true)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eDownloaderPos)
  if saveData and saveData.X and saveData.Y and tonumber(saveData.X) and tonumber(saveData.Y) then
    saveData.X = math.max(saveData.X, 10)
    saveData.Y = math.max(saveData.Y, 10)
    self.UIRoot.Panel_Drag.Slot:SetPosition(FVector2D(tonumber(saveData.X), tonumber(saveData.Y)))
    self.UIRoot.CommonDragDropItem.Slot:SetPosition(FVector2D(saveData.X - 20, saveData.Y - 20))
  end
end
function UI_Lobby_Downloader_Btn:RefreshReddot()
  if IsWoWEditor then
    self:ToggleReddotActivation(self.UIRoot.Image_Reddot, false)
    return
  end
  local showReddot = false
  if PufferDownloader.PufferJsonDownloadReturn then
    showReddot = self:NeedShowReddot()
    log_format("UI_Lobby_Downloader_Btn:RefreshReddot. showReddot=%s", showReddot)
  else
    log_format("UI_Lobby_Downloader_Btn:RefreshReddot. PufferJsonDownloadReturn false")
  end
  self:SetWidgetVisible(self.UIRoot.Reddot_Anchor_Item03, false)
  local list = {
    self.UIRoot.Image_Reddot,
    self.UIRoot.Image_Reddot1
  }
  for k, widget in pairs(list) do
    if widget then
      self:SetWidgetVisible(widget, showReddot)
    end
  end
end
function UI_Lobby_Downloader_Btn:UpdateButtonState()
  local switchIndex = 0
  local RecommendType = PufferSwitch.AutoDownloadCfg.RecommendType
  local bundleID = PufferConst.RecommendBundleIDs[RecommendType]
  local cfg = PufferDownloader.DownloadRewardCfg and PufferDownloader.DownloadRewardCfg[PufferConst.Enum_BundleID.Recommend]
  if cfg and not cfg.is_got and LogicPufferBundle.GetBundleState(bundleID) ~= PufferConst.ENUM_DownloadState.Done and not PufferDownloader.RecommendReddot then
    switchIndex = 1
    local cSize, tSize = LogicPufferBundle.GetBundleSize(bundleID)
    local pct = 1
    if tSize ~= 0 then
      pct = cSize / tSize
    end
    local material = self.UIRoot.Image_Progress_02:GetDynamicMaterial()
    if material then
      material:SetScalarParameterValue("Mask_Percent", pct)
    end
  end
  self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(switchIndex)
  local y = 8
  local x = 70
  if switchIndex == 1 then
    x = 85
  end
  self.UIRoot.CanvasPanel_Downloading_ODPack.Slot:SetPosition(FVector2D(x, y))
end
function UI_Lobby_Downloader_Btn:NeedShowReddot()
  if PufferDownloader.DownloadRewardCfg then
    local data = PufferDownloader.DownloadRewardCfg[PufferConst.Enum_BundleID.Recommend]
    if data and data.itemid1 > 0 then
      if data.is_got then
        PufferDownloader.RecommendReddot = false
      elseif LogicPufferBundle.CheckRecommendReddot() then
        self:SetWidgetVisible(self.UIRoot.Reddot_Anchor_Item03, true)
        return true
      end
    end
  end
  self:SetWidgetVisible(self.UIRoot.Reddot_Anchor_Item03, false)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  if PufferSwitch.GetPrefetchSwitch() then
    local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.ePrefetchReddot)
    if not data then
      data = {}
      data.BigAppVersion = "0"
      PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.ePrefetchReddot)
      return true
    elseif data.BigAppVersion == "0" then
      return true
    end
    local PufferPrefetchManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_prefetch_manager)
    if PufferPrefetchManager.BigAppVersion ~= data.BigAppVersion then
      log(bWriteLog and "UI_Lobby_Downloader_Btn:NeedShowReddot.version not match")
      return true
    end
  end
  local Logic_Lobby_DownLoad = require("client.slua.logic.download.logic_lobby_downloader")
  local hasReddot = false
  for bundleID, v in pairs(PufferDownloader.DownloadRewardCfg) do
    if not v.is_got and v.itemid1 and v.itemid1 > 0 then
      local cfg = CDataTable.GetTableDataByFilter("DownloaderNewTable", "BundleID", bundleID)
      if cfg then
        if LogicPufferBundle.GetBundleState(bundleID) == PufferConst.ENUM_DownloadState.Done then
          if bundleID == PufferConst.PREFETCH_BUNDLE_ID then
            local PufferPrefetchManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_prefetch_manager)
            if PufferPrefetchManager:GetReserveState() == PufferConst.ENUM_ReserveState.CanDownload then
              return true
            end
          elseif bundleID ~= PufferConst.Enum_BundleID.Recommend then
            return true
          end
        end
      elseif Logic_Lobby_DownLoad.GetMapHasCanReward(bundleID) then
        return true
      end
    end
  end
  return hasReddot
end
function UI_Lobby_Downloader_Btn:SetPercentRefreshFlag()
  self.needRefreshPercent = true
end
function UI_Lobby_Downloader_Btn:RefreshDownloadPercent()
  local percent = LogicPufferBundle.GetDownloadingPercent()
  if percent == 1 then
    percent = 0
  end
  local mat = self.UIRoot.Image_Progress:GetDynamicMaterial()
  if mat then
    mat:SetScalarParameterValue("Mask_Percent", percent)
  end
  if percent == 0 then
    self.UIRoot.WidgetSwitcher_Download:SetActiveWidgetIndex(0)
  else
    self.UIRoot.WidgetSwitcher_Download:SetActiveWidgetIndex(1)
  end
end
function UI_Lobby_Downloader_Btn:ShowOrHideBtn(_, _, bHide)
  log(bWriteLog and "UI_Lobby_Downloader_Btn:ShowOrHideBtn bHide = " .. tostring(bHide))
  if bHide then
    self.UIRoot.Panel_Downloader:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    self.UIRoot.Panel_Downloader:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
end
function UI_Lobby_Downloader_Btn:OnPufferJsonPostProcess()
  log_format("UI_Lobby_Downloader_Btn:OnPufferJsonPostProcess.")
  self:RefreshReddot()
end
function UI_Lobby_Downloader_Btn:OnClickBtn(Params)
  log(bWriteLog and "UI_Lobby_Downloader_Btn:OnClickBtn")
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  if not PufferDownloader.PufferJsonDownloadReturn then
    log(bWriteLog and "UI_Lobby_Downloader_Btn:OnClickBtn PufferJsonDownloadReturn false")
    PufferDownloader.ShowPufferInitProgressNotice()
    PufferDownloader.ReportPufferWarning()
    if GameStatus.IsInMainCity() then
      local MainCityUITriggertLog = require("GameLua.Mod.MainCity.Client.Config.MainCityUITriggertLog")
      MainCityUITriggertLog.ReportTLogEvent(MainCityUITriggertLog.UIEnum.download, "return")
    else
      tlog_report_utils.ReportTLogEvent(TLogEventDefine.LobbyDownloadBtn, nil, "return")
    end
    return
  end
  EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_LOBBY_DOWNLOAD)
  if GameStatus.IsInMainCity() then
    local MainCityUITriggertLog = require("GameLua.Mod.MainCity.Client.Config.MainCityUITriggertLog")
    MainCityUITriggertLog.ReportTLogEvent(MainCityUITriggertLog.UIEnum.download, "show")
    local logic_main_city_music = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_music)
    logic_main_city_music:OnUIShowOrHide("Download_Main_UIBP", true)
  else
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.LobbyDownloadBtn, nil, "show")
  end
  if not UIManager.IsUIShow(UIManager.UI_Config.Download_Main_UIBP) then
    if Params then
      UIManager.ShowUI(UIManager.UI_Config.Download_Main_UIBP, Params.JumpInfo, Params.bShowWarningPopUp)
    else
      UIManager.ShowUI(UIManager.UI_Config.Download_Main_UIBP)
    end
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  if PufferSwitch.GetPrefetchSwitch() then
    local data = {}
    local PufferPrefetchManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_prefetch_manager)
    data.BigAppVersion = PufferPrefetchManager.BigAppVersion
    PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.ePrefetchReddot)
    self:RefreshReddot()
  end
  if not Params then
    self:PlayAudio(sound_config.popup_v1)
  end
end
function UI_Lobby_Downloader_Btn:OnHandleClick(_, _, Params)
  log(bWriteLog and "UI_Lobby_Downloader_Btn:OnHandleClick")
  self:OnClickBtn(Params)
end
function UI_Lobby_Downloader_Btn:OnDrag(DragWidget, Index, GeneratedWidget, DragDropData)
  log(bWriteLog and "UI_Lobby_Downloader_Btn:OnDrag")
  if DragWidget then
    self:SetTexture(DragWidget.Image_Icon, "Texture2D'/Game/UMG/Texture/Atlas/Common_Atlas/Frames/lobby_download_btn_drag_icon.lobby_download_btn_drag_icon'")
    self:SetWidgetVisible(DragWidget.Image_Icon, true)
    self:SetTexture(DragWidget.Image_BlackBg, "")
    self:SetWidgetVisible(DragWidget.Image_BlackBg, false)
  end
  self:SetWidgetVisible(self.UIRoot.Panel_Downloader, false)
end
function UI_Lobby_Downloader_Btn:OnDragSuccess(DragWidget, Index, DragDropData)
  log(bWriteLog and "UI_Lobby_Downloader_Btn:OnDragSuccess")
  self.UIRoot.Panel_Downloader:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
end
function UI_Lobby_Downloader_Btn:OnDragCancel(DragWidget, Index, DragDropData)
  log(bWriteLog and "UI_Lobby_Downloader_Btn:OnDragCancel")
  local UIUtil = require("client.common.ui_util")
  local viewportPosition = UIUtil.GetWidgetViewportPos(DragWidget.DefaultDragVisual.Image_Icon)
  log(bWriteLog and "UI_Lobby_Downloader_Btn:OnDragCancel viewportPosition.X = " .. tostring(viewportPosition.X) .. " viewportPosition.Y = " .. tostring(viewportPosition.Y))
  if viewportPosition.X == 0 and viewportPosition.Y == 0 then
    self.UIRoot.Panel_Downloader:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    return
  end
  local viewportSize = UIUtil.GetViewportSize()
  local DPI = UIUtil.GetViewportScale()
  local ScreenX = viewportSize.X / DPI
  local ScreenY = viewportSize.Y / DPI
  local ScaleSize = math.min(ScreenX / 1136, ScreenY / 640)
  local ViewSizeX = ScreenX / ScaleSize
  viewportPosition = viewportPosition / ScaleSize
  if viewportPosition.X < 10 then
    viewportPosition.X = 10
  end
  if viewportPosition.X > ViewSizeX - 650 then
    viewportPosition.X = ViewSizeX - 650
  end
  viewportPosition.Y = math.max(viewportPosition.Y, 10)
  self.UIRoot.Panel_Drag.Slot:SetPosition(FVector2D(viewportPosition.X, viewportPosition.Y))
  self.UIRoot.CommonDragDropItem.Slot:SetPosition(FVector2D(viewportPosition.X - 20, viewportPosition.Y - 20))
  self.UIRoot.Panel_Downloader:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local pos = {}
  pos.X = viewportPosition.X
  pos.Y = viewportPosition.Y
  PlayerPrefsSystem.SaveTableToFile_N(pos, PlayerPrefsSystem.ePlayerPrefsType.eDownloaderPos)
end
function UI_Lobby_Downloader_Btn:OnDownloadODPackStart(_, _, ODPackID)
  local cfg = CDataTable.GetTableData("PakInfoTable", ODPackID)
  if not cfg then
    log(bWriteLog and string.format("UI_Lobby_Downloader_Btn:OnDownloadODPackStart cfg is nil ODPackID:%s", ODPackID))
    return
  end
  if ODPackID == 66629 or ODPackID == 66630 then
    log_format("UI_Lobby_Downloader_Btn:OnDownloadODPackStart ODPackID is 66629 or 66630")
    return
  end
  local strContent = LocUtil.LocalizeResFormat(18315, cfg.PakName)
  self.UIRoot.Text_Downloading_ODPack:SetText(strContent)
  self.UIRoot.CanvasPanel_Downloading_ODPack:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self:AddTimerOnce(5, function()
    self.UIRoot.CanvasPanel_Downloading_ODPack:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end)
end
function UI_Lobby_Downloader_Btn:ResetDragPosition()
  log(bWriteLog and "UI_Lobby_Downloader_Btn:ResetDragPosition")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local initPos = FVector2D(470, -10)
  local savePos = {
    X = initPos.X,
    Y = initPos.Y
  }
  PlayerPrefsSystem.SaveTableToFile_N(savePos, PlayerPrefsSystem.ePlayerPrefsType.eDownloaderPos)
  self.UIRoot.Panel_Drag.Slot:SetPosition(initPos)
  self.UIRoot.CommonDragDropItem.Slot:SetPosition(FVector2D(initPos.X - 20, initPos.Y - 20))
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CUI_Lobby_Downloader_Btn = class(ui_base, nil, UI_Lobby_Downloader_Btn)
return CUI_Lobby_Downloader_Btn