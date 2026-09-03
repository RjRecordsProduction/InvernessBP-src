local ModeSelection_Main_MultiMap01_Item = {}
local PufferConst = require("client.slua.logic.download.puffer_const")
local E_DownloadState = PufferConst.ENUM_DownloadState
local PufferSwitch = require("client.slua.logic.download.puffer_switch")
function ModeSelection_Main_MultiMap01_Item:ctor(selfType, itemData, filterInfo, showDelay)
  self:SetData(itemData)
  self.  self.showDelay = showDelay or 0
  self.selectViewIDs = {}
  self.bIsOption = false
  self.nSelectMinNum = 1
  self.nCheckMapIndex = 1
  self.needCheckMaps = {}
end
function ModeSelection_Main_MultiMap01_Item:SetData(itemData)
  self.data = itemData
  self.bIsClassic = itemData.is_random and itemData.is_random == 1 or false
  self.groupView = itemData.group_view or {
    [1] = {
      view_id = itemData.id,
      show_name = itemData.subtitle
    }
  }
end
function ModeSelection_Main_MultiMap01_Item:RegistEvents()
  ModeSelection_Main_MultiMap01_Item.__super.RegistEvents(self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Detail, self.OnButton_DetailClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Item, self.OnButton_ItemClick, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_SwitchMap, self.OnButton_SwitchMapClick, self)
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_MATCH_MAP_DOWNLOAD_START, self.OnDownloadMap, self)
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_MATCH_MODE_SELECT_MAP, self.OnSelectMap, self)
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_MATCH_MODE_MAIN_FILTER_CHANGE, self.OnSyncFilterInfo, self)
  self:AddCommonEvent(EVENTTYPE_MATCH, EVENTID_STOP_MAP_ANIMATION, self.StopAnimationPlay, self)
end
function ModeSelection_Main_MultiMap01_Item:OnPostInitialize()
  ModeSelection_Main_MultiMap01_Item.__super.OnPostInitialize(self)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Plant, false)
  local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
  self.nSelectMinNum = self.bIsClassic and mode_selection_macro.C_SelectMapMinNum.Classic or mode_selection_macro.C_SelectMapMinNum.Arena
  assert(next(self.selectViewIDs) or next(self.groupView) or #self.groupView >= self.nSelectMinNum, "ModeSelection_Main_MultiMap01_Item:RegistEvents next(self.selectViewIDs) or next(self.groupView) or #self.groupView >= self.nSelectMinNum")
  if self:CheckAllMap() then
    self:InitSelectViews()
    self:FixedSelectViews()
  end
  self:RefreshItem()
  if self.showDelayTimer then
    self:RemoveTimer(self.showDelayTimer)
    self.showDelayTimer = nil
  end
  local UIUtil = require("client.common.ui_util")
  local showDelay = self.showDelay
  if 0 <= showDelay then
    self.UIRoot.CanvasPanel_0:SetWidgetVisibility(UIUtil.BoolToVisible(false, false))
    self.showDelayTimer = self:AddTimerOnce(showDelay, function()
      self.UIRoot.CanvasPanel_0:SetWidgetVisibility(UIUtil.BoolToVisible(true))
      self:PlayUserWidgetAnimation(self.UIRoot.Animation_Appear, 0, 1, 0, 1)
      self:RemoveTimer(self.showDelayTimer)
      self.showDelayTimer = nil
    end)
  else
    self.UIRoot.CanvasPanel_0:SetWidgetVisibility(UIUtil.BoolToVisible(true))
  end
end
function ModeSelection_Main_MultiMap01_Item:OnClose()
  self:RemoveMainDownloader()
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Download, true)
  if self.subDownloader then
    self.subDownloader:Close()
    self.subDownloader = nil
  end
end
function ModeSelection_Main_MultiMap01_Item:RemoveMainDownloader()
  if self.downloader then
    self.downloader:Close()
    self.downloader = nil
  end
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Download, false)
end
function ModeSelection_Main_MultiMap01_Item:CheckAllMap()
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local logic_mode_map_download = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_map_download)
  local readyViewIDs = {}
  self.mapDownloadInfoDict = {}
  self.needCheckMaps = {}
  self.nCheckMapIndex = 1
  for i = 1, #self.groupView do
    local viewInfo = self.groupView[i]
    local viewID = viewInfo.view_id
    local downloadViewData = logic_mode_selection:GetSubviewInfoBySubviewID(viewID)
    local mapKeyList, mapKeyDict = self:GetMapKeyInfo(self.UIRoot, downloadViewData)
    local state = logic_mode_map_download:GetMapListState(mapKeyList)
    if state == E_DownloadState.Done then
      table.insert(readyViewIDs, viewID)
      self.needCheckMaps[viewID] = true
      self.nCheckMapIndex = self.nCheckMapIndex + 1
    end
    self.mapDownloadInfoDict[viewID] = {
      mapKeyList = mapKeyList,
      mapKeyDict = mapKeyDict,
      downloadStatus = state,
      isOpen = logic_mode_selection:GetTimeLimitStr(downloadViewData)
    }
  end
  local TableUtil = require("common.table_util")
  local needCheckMapNum = TableUtil.CountTable(self.needCheckMaps)
  if needCheckMapNum < self.nSelectMinNum then
    local diff = self.nSelectMinNum - needCheckMapNum
    for i = 1, diff do
      local viewInfo = self.groupView[i]
      if viewInfo then
        self.needCheckMaps[viewInfo.view_id] = true
      end
    end
  end
  if #readyViewIDs == 0 then
    self:CoverSelectViews()
    self.data = logic_mode_selection:GetSubviewInfoBySubviewID(self.selectViewIDs[1])
    return false
  end
  return true
end
function ModeSelection_Main_MultiMap01_Item:InitSelectViews()
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local isSelected = false
  local _, _, viewIDs = logic_mode_selection:GetCurSelectInfo()
  local isPeakGame = false
  for k, v in pairs(self.groupView) do
    if v.view_id == 90069 then
      isPeakGame = true
    end
  end
  if isPeakGame then
    local PufferConst = require("client.slua.logic.download.puffer_const")
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {"map_desert"})
    if state == PufferConst.ENUM_DownloadState.Done then
      for k, v in pairs(self.groupView) do
        table.insert(self.selectViewIDs, v.view_id)
      end
      return
    end
  end
  if self.UIRoot.Image_seletion_Loop then
    self.UIRoot.Image_seletion_Loop:SetColorAndOpacity((FLinearColor(1, 1, 1, 0)))
  end
  if self.UIRoot.Image_seletion_Loop02 then
    self.UIRoot.Image_seletion_Loop02:SetColorAndOpacity((FLinearColor(1, 1, 1, 0)))
  end
  self.UIRoot:StopAnimation(self.UIRoot.Animation_Seletion_Loop)
  for _, viewInfo in ipairs(self.groupView) do
    if not isSelected and viewIDs then
      for _, viewID in pairs(viewIDs) do
        if viewInfo.view_id == viewID and 0 <= self.showDelay then
          isSelected = true
          self.selectViewIDs = viewIDs
          print(bWriteLog and "ModeSelection_Main_MultiMap01_Item:InitSelectViews isSelected " .. tostring(self.data.id))
          self:PlayUserWidgetAnimation(self.UIRoot.Animation_Seletion_Loop, 0, 0, 0, 1)
          break
        end
      end
    end
  end
  if not isSelected then
    local logic_mode_utils = require("client.slua.logic.mode_selection.logic_mode_utils")
    self.selectViewIDs = logic_mode_utils.GetLocalSaveOrDefaultSelectData(self.data.id, self.groupView)
  end
end
function ModeSelection_Main_MultiMap01_Item:FixedSelectViews()
  local isFixed = false
  for i = #self.selectViewIDs, 1, -1 do
    local viewID = self.selectViewIDs[i]
    local downloadInfo = self.mapDownloadInfoDict[viewID]
    if downloadInfo then
      local downloadStatus = downloadInfo.downloadStatus
      if downloadStatus ~= E_DownloadState.Done then
        isFixed = true
        table.remove(self.selectViewIDs, i)
      else
        local isOpen = downloadInfo.isOpen
        if not isOpen then
          isFixed = true
          table.remove(self.selectViewIDs, i)
        end
      end
    else
      isFixed = true
      table.remove(self.selectViewIDs, i)
    end
  end
  local index = 1
  while #self.selectViewIDs < self.nSelectMinNum do
    local viewInfo = self.groupView[index]
    if viewInfo then
      local viewID = viewInfo.view_id
      local downloadInfo = self.mapDownloadInfoDict[viewID]
      if downloadInfo then
        local downloadStatus = downloadInfo.downloadStatus
        local isOpen = downloadInfo.isOpen
        if downloadStatus == E_DownloadState.Done and isOpen then
          local isExist = false
          for i, selectViewID in ipairs(self.selectViewIDs) do
            if viewID == selectViewID then
              isExist = true
              break
            end
          end
          if not isExist then
            table.insert(self.selectViewIDs, viewID)
          end
        end
      end
      index = index + 1
    else
      break
    end
  end
  if #self.selectViewIDs < self.nSelectMinNum then
    self:CoverSelectViews()
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  self.data = logic_mode_selection:GetSubviewInfoBySubviewID(self.selectViewIDs[1])
  if isFixed then
    EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_MATCH_MODE_REFRESH_SELECT, self.selectViewIDs)
  end
end
function ModeSelection_Main_MultiMap01_Item:CoverSelectViews()
  self.nCheckMapIndex = 1
  if not self.selectViewIDs then
    self.selectViewIDs = {}
  end
  local index = 1
  while #self.selectViewIDs < self.nSelectMinNum do
    local viewInfo = self.groupView[index]
    if viewInfo then
      local viewID = viewInfo.view_id
      local isExist = false
      for i, selectViewID in ipairs(self.selectViewIDs) do
        if viewID == selectViewID then
          isExist = true
          break
        end
      end
      if not isExist then
        table.insert(self.selectViewIDs, viewID)
      end
      index = index + 1
    else
      break
    end
  end
  if #self.selectViewIDs < self.nSelectMinNum then
    log_error(bWriteLog and "[edward] ModeSelection_Main_MultiMap01_Item:CoverSelectViews, config is error, \229\183\178\233\128\137\229\156\176\229\155\190\230\149\176\228\189\142\228\186\142\230\156\128\228\189\142\229\128\188")
  end
end
function ModeSelection_Main_MultiMap01_Item:RefreshItem()
  if not self.UIRoot then
    return
  end
  self:SetItemData()
  self:SetDownloadData()
  if #self.groupView <= self.nSelectMinNum then
    self:HideSubDownload()
  else
    self:SetSubDownloadData()
  end
  self:UpdateMultiInfo()
  self:SetLimitStateFilter(self.data, self.filterInfo)
end
function ModeSelection_Main_MultiMap01_Item:SetItemData()
  if not self.data then
    self.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  self.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self:UpdateBaseInfo()
  self:UpdateNewFlag()
end
function ModeSelection_Main_MultiMap01_Item:UpdateBaseInfo()
  local root = self.UIRoot
  local data = self.data
  if data.menu_id == 120 then
    root.TextBlock_Title:SetText(LocUtil.GetLocalizeResStr(88902))
  else
    root.TextBlock_Title:SetText(LocUtil.GetLocalizeResStr(data.title))
  end
  local node = root.SizeBox_SubTitle or root.TextBlock_SubTitle
  if data.describe > 0 then
    root.TextBlock_SubTitle:SetText(LocUtil.GetLocalizeResStr(data.describe))
    node:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    node:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local isNew = logic_mode_selection:IsSubViewNew(data.id)
  local isBETA = data.hint and data.hint ~= ""
  if root.WidgetSwitcher_Hot and root.Image_NEW then
    self:SetWidgetVisible(root.WidgetSwitcher_Hot, false)
    if data.hot_status and data.hot_status == 2 then
      self:SetWidgetVisible(root.WidgetSwitcher_Hot, true)
      root.WidgetSwitcher_Hot:SetActiveWidgetIndex(0)
    elseif isNew or isBETA then
      self:SetWidgetVisible(root.WidgetSwitcher_Hot, true)
      root.WidgetSwitcher_Hot:SetActiveWidgetIndex(1)
      if isNew then
        self:SetTexture(root.Image_NEW, mode_selection_macro.C_New_Icon_Path, {sync = false})
      elseif isBETA then
        self:SetTexture(root.Image_NEW, mode_selection_macro.C_Beta_Icon_Path, {sync = false})
      end
    elseif data.hot_status and data.hot_status == 1 then
      self:SetWidgetVisible(root.WidgetSwitcher_Hot, true)
      root.WidgetSwitcher_Hot:SetActiveWidgetIndex(2)
    end
  end
  root.CanvasPanel_SwitchMap:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  if #self.groupView > self.nSelectMinNum then
    root.Button_SwitchMap:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    root.Image_SwtichMap:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    root.Button_SwitchMap:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
    root.Image_SwtichMap:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  for k, v in pairs(self.groupView) do
    if v.view_id == 90069 then
      self:SetWidgetVisible(self.UIRoot.CanvasPanel_SwitchMap, false, false)
    end
  end
  local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
  if mode_selection_macro.jumpUrlViewId and mode_selection_macro.jumpUrlViewId == data.id then
    root:PlayUserWidgetAnimation(root.Animation_LobbySeletion, 0, 1, 0, 1)
    mode_selection_macro.jumpUrlViewId = nil
  end
end
function ModeSelection_Main_MultiMap01_Item:UpdateNewFlag()
  local subNewFlag = false
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  for _, viewInfo in ipairs(self.groupView) do
    local isSelected = false
    for _, viewID in ipairs(self.selectViewIDs) do
      if viewInfo.view_id == viewID then
        isSelected = true
        break
      end
    end
    if not isSelected then
      subNewFlag = logic_mode_selection:IsSubViewNew(viewInfo.view_id)
    end
    if subNewFlag then
      break
    end
  end
  self.UIRoot.Image_NewMap:SetWidgetVisibility(subNewFlag and UEnums.ESlateVisibility.SelfHitTestInvisible or UEnums.ESlateVisibility.Collapsed)
end
function ModeSelection_Main_MultiMap01_Item:UpdateMultiInfo()
  local root = self.UIRoot
  if not self.selectViewIDs then
    root.TextBlock_Multi:SetText("")
  elseif self.selectViewIDs[90091] then
  else
    local selectNum = #self.selectViewIDs
    if selectNum == 0 then
      root.TextBlock_Multi:SetText("")
    elseif selectNum == 1 then
      if self.data and self.data.subtitle then
        if self.downloader and self.downloader.UIRoot:GetState() ~= E_DownloadState.Done then
          root.TextBlock_Multi:SetText(LocUtil.LocalizeResFormat(29869, LocUtil.GetLocalizeResStr(self.data.subtitle)))
        else
          root.TextBlock_Multi:SetText(LocUtil.LocalizeResFormat(29363, LocUtil.GetLocalizeResStr(self.data.subtitle)))
        end
      else
        root.TextBlock_Multi:SetText("")
      end
    elseif self.downloader and self.downloader.UIRoot:GetState() ~= E_DownloadState.Done then
      local lastSelectViewID = self.selectViewIDs[self.nSelectMinNum]
      if not lastSelectViewID then
        root.TextBlock_Multi:SetText("")
        return
      end
      local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
      local lastSelectViewInfo = logic_mode_selection:GetSubviewInfoBySubviewID(lastSelectViewID)
      if not lastSelectViewInfo then
        root.TextBlock_Multi:SetText("")
        return
      end
      root.TextBlock_Multi:SetText(LocUtil.LocalizeResFormat(29869, LocUtil.GetLocalizeResStr(lastSelectViewInfo.subtitle)))
    else
      root.TextBlock_Multi:SetText(LocUtil.LocalizeResFormat(29364, selectNum))
    end
  end
  self:UpdateBg()
end
function ModeSelection_Main_MultiMap01_Item:UpdateBg()
  if not self.data then
    return
  end
  local root = self.UIRoot
  local modeBgPath = ""
  local isNormal = self.data.show_type == "NORMAL" or self.forceUseSmallBg
  if next(self.selectViewIDs) and #self.selectViewIDs > 1 then
    local logic_mode_utils = require("client.slua.logic.mode_selection.logic_mode_utils")
    modeBgPath = logic_mode_utils.GetMultiImage(not isNormal, self.data.is_random and self.data.is_random == 1, self.selectViewIDs)
  else
    modeBgPath = isNormal and self.data.small_bg or self.data.big_bg
  end
  self:SetTexture(root.Image_Bg, modeBgPath, {
    sync = false,
    needLocalize = true,
    onDownloadSuccess = function()
      if root.CanvasPanel_loading then
        self:SetWidgetVisible(root.CanvasPanel_loading, false)
      end
    end
  })
end
function ModeSelection_Main_MultiMap01_Item:SetDownloadData()
  local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
  if self.nCheckMapIndex > self.nSelectMinNum then
    self:RemoveMainDownloader()
    return
  end
  local viewID = self.selectViewIDs[self.nCheckMapIndex]
  if not viewID then
    self:RemoveMainDownloader()
    return
  end
  log(bWriteLog and "[edward] ModeSelection_Main_MultiMap01_Item:SetDownloadData viewID = " .. tostring(viewID))
  local mapDownloadInfoDict = self.mapDownloadInfoDict[viewID]
  if not mapDownloadInfoDict then
    log_error(bWriteLog and "[edward] ModeSelection_Main_MultiMap01_Item:SetDownloadData, downloadData is error")
    self:RemoveMainDownloader()
    return
  end
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Download, true)
  self.mapKeyList = mapDownloadInfoDict.mapKeyList
  if mapDownloadInfoDict.mapKeyDict then
    if self.mapKeyDict then
      for mapKey, info in pairs(mapDownloadInfoDict.mapKeyDict) do
        self.mapKeyDict[mapKey] = info
      end
    else
      self.mapKeyDict = mapDownloadInfoDict.mapKeyDict
    end
  end
  local downloadStatus = self.mapDownloadInfoDict[viewID].downloadStatus
  local OnMapFinish = function()
    if downloadStatus ~= E_DownloadState.Done or self.nCheckMapIndex < self.nSelectMinNum then
      self.nCheckMapIndex = self.nCheckMapIndex + 1
      self:AddTimerOnce(0.1, function()
        self:CheckAllMap()
        self:FixedSelectViews()
        self:RefreshItem()
      end)
    end
  end
  if next(self.mapKeyList) then
    if self.downloader then
      self.downloader.UIRoot:SetData(self.mapKeyList[1], OnMapFinish, PufferTlog.Enum_TLog_From.ModeSelect)
    elseif self.UIRoot.CanvasPanel_Download then
      local common_download_handler = require("client.slua.common.common_download_handler")
      self.downloader = common_download_handler.CreateMapDownloader(1, self.mapKeyList[1], self, self.UIRoot.CanvasPanel_Download, OnMapFinish, nil, nil, PufferTlog.Enum_TLog_From.ModeSelect)
    end
  end
end
function ModeSelection_Main_MultiMap01_Item:HideSubDownload()
  if not self.UIRoot then
    return
  end
  self.UIRoot.CanvasPanel_Sub_Download:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if self.subDownloader then
    self.subDownloader.UIRoot:SetVisibilityInner(false)
  end
end
function ModeSelection_Main_MultiMap01_Item:SetSubDownloadData(mapKey)
  local downloadStatus = E_DownloadState.Done
  if mapKey then
    if self.mapKeyDict and self.mapKeyDict[mapKey] then
      self:HideSubDownload()
      return
    end
    local isSubMap = false
    for _, mapDownloadInfo in pairs(self.mapDownloadInfoDict) do
      if mapDownloadInfo.mapKeyDict and mapDownloadInfo.mapKeyDict[mapKey] then
        isSubMap = true
        downloadStatus = mapDownloadInfo.downloadStatus
        break
      end
    end
    if not isSubMap then
      self:HideSubDownload()
      return
    end
  else
    for mapDownloadViewID, mapDownloadInfo in pairs(self.mapDownloadInfoDict) do
      if not self.needCheckMaps[mapDownloadViewID] and mapDownloadInfo.downloadStatus == E_DownloadState.Download then
        mapKey = mapDownloadInfo.mapKeyList[1]
        downloadStatus = mapDownloadInfo.downloadStatus
        break
      end
    end
    if not mapKey then
      self:HideSubDownload()
      return
    end
  end
  local OnMapFinish = function()
    if downloadStatus ~= E_DownloadState.Done then
      self:HideSubDownload()
      self:AddTimerOnce(0.1, function()
        self:CheckAllMap()
        self:FixedSelectViews()
        self:RefreshItem()
      end)
    end
  end
  local OnMapPause = function()
    self:HideSubDownload()
    self:CheckAllMap()
    self:SetSubDownloadData()
  end
  if not self.UIRoot then
    return
  end
  self.UIRoot.CanvasPanel_Sub_Download:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
  if self.subDownloader then
    if self.subDownloader.UIRoot:GetState() ~= E_DownloadState.Download then
      self.subDownloader.UIRoot:SetData(mapKey, OnMapFinish, OnMapPause, PufferTlog.Enum_TLog_From.ModeSelect)
    else
      self.subDownloader.UIRoot:SetVisibilityInner(true)
    end
  elseif self.UIRoot.CanvasPanel_Sub_Download then
    local common_download_handler = require("client.slua.common.common_download_handler")
    self.subDownloader = common_download_handler.CreateMapDownloader(2, mapKey, self, self.UIRoot.CanvasPanel_Sub_Download, OnMapFinish, nil, OnMapPause, PufferTlog.Enum_TLog_From.ModeSelect)
  end
  if self.downloader and self.downloader.UIRoot:GetState() ~= E_DownloadState.Done then
    self:HideSubDownload()
  end
end
function ModeSelection_Main_MultiMap01_Item:OnButton_DetailClick()
  self:PlayAudio(sound_config.click)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.NewModeSelection_ClickViewDetailIntroduce, 0, self.selectViewIDs[1])
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  logic_mode_selection:OpenModeSelectionDetails(self.selectViewIDs[1])
end
function ModeSelection_Main_MultiMap01_Item:StopAnimationPlay()
  self.UIRoot:StopAnimation(self.UIRoot.Animation_Seletion_Loop)
end
function ModeSelection_Main_MultiMap01_Item:OnButton_ItemClick()
  self:PlayAudio(sound_config.click)
  if self.itemClickCallback then
    self.itemClickCallback()
    return
  end
  self:PlayUserWidgetAnimation(self.UIRoot.Animation_Seletion, 0, 1, 0, 1)
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if self.data and self.data.hot_status and self.data.hot_status == 2 and TeamUpNewSystem.IsTeamLeader() then
    ShowNotice(42665)
    return
  end
  EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_STOP_MAP_ANIMATION)
  self:PlayUserWidgetAnimation(self.UIRoot.Animation_Seletion_Loop, 0, 0, 0, 1)
  if self.lockState == self.Enum_Lock_State.Level then
    ShowNotice(LocUtil.LocalizeResFormat(31028, self.data.level_limit))
    return
  elseif self.lockState == self.Enum_Lock_State.Time then
    if self.nStartTime then
      local TimeUtil = require("client.common.time_util")
      ShowNotice(LocUtil.LocalizeResFormat(27754, TimeUtil.FormatCountDownTime_D_or_HMS(self.nStartTime - TimeUtil.GetServerTimeInSec())))
    end
    return
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  for i, v in ipairs(self.selectViewIDs) do
    logic_mode_selection:ClickSubView(v)
  end
  EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_MATCH_MODE_VIEW_CLICK, self.selectViewIDs)
end
function ModeSelection_Main_MultiMap01_Item:OnButton_SwitchMapClick()
  if #self.groupView <= self.nSelectMinNum then
    return
  end
  self:PlayAudio(sound_config.click)
  self.bIsOption = true
  UIManager.ShowUI(UIManager.UI_Config.mode_selection_multi_popup, self.groupView, self.selectViewIDs, self.nSelectMinNum)
end
function ModeSelection_Main_MultiMap01_Item:OnDownloadMap(_, _, eventData)
  local pakName = eventData.pakName
  if not pakName or eventData.downloadType ~= PufferConst.ENUM_DownloadType.MAP then
    return
  end
  local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
  local mapKeys = PufferMapManager:GetMapKeysByPakName(pakName)
  if mapKeys then
    for _, mapKey in pairs(mapKeys) do
      self:SetSubDownloadData(mapKey)
    end
  end
end
function ModeSelection_Main_MultiMap01_Item:OnSelectMap(_, _, newViewIDs)
  if not self.bIsOption then
    return
  end
  self.bIsOption = false
  self.selectViewIDs = newViewIDs
  local showViewID = #self.selectViewIDs == 1 and self.selectViewIDs[1] or self.groupView[1].view_id
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  self.data = logic_mode_selection:GetSubviewInfoBySubviewID(showViewID)
  local logic_mode_utils = require("client.slua.logic.mode_selection.logic_mode_utils")
  logic_mode_utils.UpdateLocalSelectViewIDs(self.data and self.data.group_view, newViewIDs)
  self:UpdateNewFlag()
  self:UpdateMultiInfo()
end
function ModeSelection_Main_MultiMap01_Item:OnSyncFilterInfo(_, _, filterInfo)
  self.  self:SetLimitStateFilter(self.data, self.filterInfo)
end
function ModeSelection_Main_MultiMap01_Item:SetMapData(data, filterInfo)
  self:SetData(data)
  self:OnSyncFilterInfo(nil, nil, filterInfo)
  self:RefreshItem()
end
local class = require("class")
local ui_base = require("client.slua.umg.ModeSelection.ModeSelection_Main_Item_Base")
local CModeSelection_Main_MultiMap01_Item = class(ui_base, nil, ModeSelection_Main_MultiMap01_Item)
return CModeSelection_Main_MultiMap01_Item