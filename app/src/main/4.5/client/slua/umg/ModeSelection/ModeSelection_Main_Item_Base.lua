local specialMenuIds = {
  [120] = true,
  [130] = true
}
local ModeSelection_Main_Item_Base = {}
local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
local event = require("client.slua.config.event.event")
local Enum_Lock_State = mode_selection_macro.Enum_Lock_State
ModeSelection_Main_Item_Base.
function ModeSelection_Main_Item_Base:ctor(selfType, itemData, filterInfo, showDelay, forceUseSmallBg)
  self.itemClickCallback = nil
  self.  self.state = nil
end
function ModeSelection_Main_Item_Base:SetItemClickCallback(itemClickCallback)
  self.end
function ModeSelection_Main_Item_Base:SetMapData(data, filterInfo)
end
function ModeSelection_Main_Item_Base:GetIsSelectTheme(itemData, themeData)
  if not themeData then
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eModeSelectionMainUI) or {}
  if cfg.themeSelect and type(cfg.themeSelect[itemData.id]) ~= "nil" then
    return cfg.themeSelect[itemData.id]
  end
  for _, v in ipairs(itemData.group_view) do
    if v.view_id == itemData.id then
      return false
    elseif v.view_id == themeData.id then
      return true
    end
  end
  return false
end
function ModeSelection_Main_Item_Base:SetIsSelectTheme(itemData, isSelect)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eModeSelectionMainUI) or {}
  cfg.themeSelect = cfg.themeSelect or {}
  cfg.themeSelect[itemData.id] = isSelect
  PlayerPrefsSystem.SaveTableToFile_N(cfg, PlayerPrefsSystem.ePlayerPrefsType.eModeSelectionMainUI)
end
function ModeSelection_Main_Item_Base:SetItemData(widget, itemData, themeData, isSelectTheme)
  if not itemData then
    widget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  local data = isSelectTheme and themeData or itemData
  if not themeData then
    data = itemData
  end
  widget.TextBlock_Title:SetText(LocUtil.GetLocalizeResStr(data.title))
  if widget.TextBlock_5 then
    widget.TextBlock_5:SetText(LocUtil.GetLocalizeResStr(data.title))
  end
  widget.TextBlock_SubTitle:SetText(LocUtil.GetLocalizeResStr(data.subtitle))
  if widget.WidgetSwitcher_2 then
    local _hasSubTitle = data.subtitle and data.subtitle ~= 0 or false
    widget.WidgetSwitcher_2:SetActiveWidgetIndex(_hasSubTitle and 0 or 1)
  end
  widget.TextBlock_Desc:SetText(LocUtil.GetLocalizeResStr(data.describe))
  self:SetBgAndEffect(widget, itemData, themeData, isSelectTheme)
  if specialMenuIds[itemData.menu_id] then
    widget.Image_Bg:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  widget.Button_Theme:SetWidgetVisibility(themeData and UEnums.ESlateVisibility.Visible or UEnums.ESlateVisibility.Collapsed)
  if widget.Button_Theme1 then
    widget.Button_Theme1:SetWidgetVisibility(themeData and UEnums.ESlateVisibility.Visible or UEnums.ESlateVisibility.Collapsed)
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local isNew = logic_mode_selection:IsSubViewNew(data.id)
  local isBETA = data.hint and data.hint ~= ""
  log_tree("data.hot_status ", itemData)
  if widget.WidgetSwitcher_Hot and widget.Image_NEW then
    self.UIRoot.TextBlock_4:SetText(LocUtil.LocalizeResFormat(42664))
    self:SetWidgetVisible(widget.WidgetSwitcher_Hot, false)
    if data.hot_status and data.hot_status == 2 then
      self:SetWidgetVisible(widget.WidgetSwitcher_Hot, true)
      widget.WidgetSwitcher_Hot:SetActiveWidgetIndex(0)
    elseif isNew or isBETA then
      self:SetWidgetVisible(widget.WidgetSwitcher_Hot, true)
      widget.WidgetSwitcher_Hot:SetActiveWidgetIndex(1)
      if isNew then
        self:SetTexture(widget.Image_NEW, mode_selection_macro.C_New_Icon_Path)
      elseif isBETA then
        self:SetTexture(widget.Image_NEW, mode_selection_macro.C_Beta_Icon_Path)
      end
    elseif data.hot_status and data.hot_status == 1 then
      self:SetWidgetVisible(widget.WidgetSwitcher_Hot, true)
      widget.WidgetSwitcher_Hot:SetActiveWidgetIndex(2)
    end
  end
  if widget.Image_Icon then
    if data.icon and data.icon ~= "" then
      self:SetTexture(widget.Image_Icon, data.icon)
      widget.Image_Icon:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
      widget.Image_Icon:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
  if mode_selection_macro.jumpUrlViewId and mode_selection_macro.jumpUrlViewId == data.id then
    self:PlayWidgetAnimation(widget, widget.Animation_LobbySeletion, 0, 1, 0, 1)
    mode_selection_macro.jumpUrlViewId = nil
  end
  local nextDate = isSelectTheme and itemData or themeData
  if nextDate then
    if nextDate.group_icon and nextDate.group_icon ~= "" then
      self:SetTexture(widget.Image_group_nextTheme, nextDate.group_icon)
      self:SetTexture(widget.Image_group_nextTheme1, nextDate.group_icon)
    end
    if nextDate.group_icon_background and nextDate.group_icon_background ~= "" then
      self:SetTexture(widget.Image_group_BG, nextDate.group_icon_background)
      self:SetTexture(widget.Image_group_BG1, nextDate.group_icon_background)
    end
  end
  widget:StopAnimation(widget.Animation_Seletion_Loop)
  if widget.Image_Page_2 then
    if not data.is_ranked or data.is_ranked ~= 2 then
      widget.Button_RankReward:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      widget.Image_Page_2:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      widget.Image_Page_Sub_2:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      widget.TextBlock_3:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      return
    end
    widget.Button_RankReward:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    widget.Image_Page_2:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    widget.Image_Page_Sub_2:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    widget.TextBlock_3:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
    local zoneID = ZoneSystem.nChooseZoneID or 0
    local segment = 101
    if DataMgr.roleData.arena_rating_and_segment and DataMgr.roleData.arena_rating_and_segment[zoneID] and DataMgr.roleData.arena_rating_and_segment[zoneID].vs_team then
      segment = DataMgr.roleData.arena_rating_and_segment[zoneID].vs_team.segment_id or 101
    end
    local ArenaStageConfig = CDataTable.GetTableData("ArenaSegmentConfig", segment)
    self:SetTexture(widget.Image_Page_2, ArenaStageConfig.BigIcon)
    self:SetTexture(widget.Image_Page_Sub_2, ArenaStageConfig.SubIcon)
    widget.TextBlock_3:SetText(ArenaStageConfig.SegmentName)
  end
end
function ModeSelection_Main_Item_Base:SetBgAndEffect(widget, itemData, themeData, isSelectTheme)
  local data = isSelectTheme and themeData or itemData
  local image1 = isSelectTheme and widget.Image_MapBBuf or widget.Image_MapABuf
  local image2 = isSelectTheme and widget.Image_MapABuf or widget.Image_MapBBuf
  if not themeData then
    data = itemData
  end
  local useSmallBg = data.show_type == "NORMAL" or self.forceUseSmallBg
  local img_path = useSmallBg and data.small_bg or data.big_bg
  self:SetTexture(widget.Image_Bg, img_path, {
    tryTimes = 3,
    needLocalize = true,
    onDownloadSuccess = function()
      if widget.CanvasPanel_loading then
        self:SetWidgetVisible(widget.CanvasPanel_loading, false)
      end
      if specialMenuIds[itemData.menu_id] then
        widget.Image_Bg:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      end
    end
  })
  local asset_util = require("common.asset_util")
  useSmallBg = itemData.show_type == "NORMAL" or self.forceUseSmallBg
  img_path = useSmallBg and itemData.small_bg or itemData.big_bg
  self:SetTexture(widget.Image_temp, img_path, {
    tryTimes = 3,
    needLocalize = true,
    sync = true,
    onDownloadSuccess = function()
      if not self or not self.UIRoot then
        return
      end
      local mat = self.UIRoot.Image_MapB:GetDynamicMaterial()
      local toTexture = asset_util.GetAssetSync(img_path)
      if toTexture and mat then
        mat:SetTextureParameterValue("TextureMap", toTexture)
      end
      mat = image1:GetDynamicMaterial()
      if toTexture and mat then
        mat:SetTextureParameterValue("TextureMap", toTexture)
      end
    end
  })
  widget.Image_MapABuf:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  widget.Image_MapBBuf:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if themeData then
    useSmallBg = themeData.show_type == "NORMAL" or self.forceUseSmallBg
    img_path = useSmallBg and themeData.small_bg or themeData.big_bg
    self:SetTexture(widget.Image_temp, img_path, {
      needLocalize = true,
      sync = true,
      onDownloadSuccess = function()
        if not self or not self.UIRoot then
          return
        end
        local mat = self.UIRoot.Image_MapA:GetDynamicMaterial()
        local toTexture = asset_util.GetAssetSync(img_path)
        if toTexture and mat then
          mat:SetTextureParameterValue("TextureMap", toTexture)
        end
        mat = image2:GetDynamicMaterial()
        if toTexture and mat then
          mat:SetTextureParameterValue("TextureMap", toTexture)
        end
      end
    })
    widget.Image_MapA:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    widget.Image_MapB:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    widget.Image_Bg:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    widget.Image_MapA:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    widget.Image_MapB:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    widget.Image_Bg:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
end
function ModeSelection_Main_Item_Base:SetLimitStateFilter(data, filterInfo)
  self.lockState = Enum_Lock_State.Not
  self.UIRoot.WidgetSwitcher_0:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if self.endNoticeTimer then
    self:RemoveTimer(self.endNoticeTimer)
  end
  local topBarComp = self.UIRoot.Image_title
  if self.UIRoot.CanvasPanel_4 and self.UIRoot.CanvasPanel_2 and self.UIRoot.WidgetSwitcher_Hot then
    if self.UIRoot.WidgetSwitcher_Hot:GetVisibility() == UEnums.ESlateVisibility.Collapsed then
      topBarComp = self.UIRoot.CanvasPanel_2
    else
      self.UIRoot.CanvasPanel_2:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
  end
  topBarComp:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if self.UIRoot.Button_RankReward then
    self.UIRoot.Button_RankReward:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if self.UIRoot.WidgetSwitcher_Hot and self.UIRoot.WidgetSwitcher_Hot:GetVisibility() == UEnums.ESlateVisibility.SelfHitTestInvisible and self.UIRoot.WidgetSwitcher_Hot:GetActiveWidgetIndex() == 0 then
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(3)
    self.UIRoot.WidgetSwitcher_0:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    topBarComp:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    return
  end
  if not data or not filterInfo then
    return
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local timeOpen, timeStr, leftTime, timeData = logic_mode_selection:GetTimeLimitStr(data)
  local level_unlock_util = require("client.logic.level_unlock.util.level_unlock_util")
  local bLevelUnlockSwitchOpen = level_unlock_util:IsSwitchOpen()
  log(bWriteLog and "ModeSelection_Main_Item_Base:SetLimitStateFilter = " .. tostring(bLevelUnlockSwitchOpen))
  if data.level_limit and data.level_limit > DataMgr.roleData.level and (not (not bLevelUnlockSwitchOpen and data.is_ranked) or data.is_ranked ~= 1) then
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(0)
    self.UIRoot.Text:SetText(LocUtil.LocalizeResFormat(31023, data.level_limit))
    self.lockState = Enum_Lock_State.Level
    self.UIRoot.WidgetSwitcher_0:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    topBarComp:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    return
  elseif not timeOpen then
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(0)
    self.UIRoot.Text:SetText(timeStr)
    self:SetLeftTimeTimer(leftTime)
    self.lockState = Enum_Lock_State.Time
    self.UIRoot.WidgetSwitcher_0:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    topBarComp:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    return
  end
  if not data.options then
    log_tree("ModeSelection_Main_Item_Base:SetLimitStateFilter t =", data)
    return
  end
  self.UIRoot.WidgetSwitcher_0:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  topBarComp:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  if not data.options.team_type[filterInfo.perspective] then
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(1)
    local tempStr = filterInfo.perspective == 100054 and LocUtil.LocalizeResFormat(100053) or LocUtil.LocalizeResFormat(100054)
    self.UIRoot.UTRichTextBlock_0:SetText(LocUtil.LocalizeResFormat(31027, tempStr))
    self.lockState = Enum_Lock_State.Person
    return
  elseif not data.options.team_type[filterInfo.perspective][filterInfo.teamNum] then
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(1)
    local tempStr = ""
    for k, v in pairs(data.options.team_type[filterInfo.perspective]) do
      tempStr = tempStr .. string.format("<img src=\"MODE_%d\"/>", k) .. tostring(k) .. " "
    end
    self.UIRoot.UTRichTextBlock_0:SetText(LocUtil.LocalizeResFormat(31027, tempStr))
    self.lockState = Enum_Lock_State.TeamNum
    return
  end
  if timeStr ~= "" then
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(2)
    self.UIRoot.TextBlock_2:SetText(timeStr)
  else
    topBarComp:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.WidgetSwitcher_0:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if self.UIRoot.Button_RankReward and data.is_ranked and data.is_ranked == 2 then
    self.UIRoot.Button_RankReward:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  end
  if topBarComp:GetVisibility() == UEnums.ESlateVisibility.Collapsed and timeData and timeData.end_notice_hours and timeData.end_notice_hours ~= 0 then
    local TimeUtil = require("client.common.time_util")
    self.endNoticeTimer = self:AddTimerLoop(0, function(deltaTime)
      local serverTime = TimeUtil.GetServerTimeInSec()
      if timeData.close_timestamp - serverTime < timeData.end_notice_hours * 3600 then
        topBarComp:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        self.UIRoot.WidgetSwitcher_0:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(2)
        self.UIRoot.TextBlock_2:SetText(LocUtil.LocalizeResFormat(timeData.end_notice_content or 45413, TimeUtil.FormatCountDownTime_D_or_HMS(timeData.close_timestamp - serverTime, 2)))
      else
        self.UIRoot.WidgetSwitcher_0:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        topBarComp:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        if self.endNoticeTimer then
          self:RemoveTimer(self.endNoticeTimer)
        end
      end
    end, 0, 1)
  end
end
function ModeSelection_Main_Item_Base:SetLeftTimeTimer(leftTime)
  self:StopLeftTimeTimer()
  local TimeUtil = require("client.common.time_util")
  self.nStartTime = TimeUtil.GetServerTimeInSec() + leftTime
  if leftTime < 0 then
    return
  end
  self.leftTimeTimer = self:AddTimerLoop(0, function()
    local leftSecond = self.nStartTime - TimeUtil.GetServerTimeInSec()
    if 0 < leftSecond then
      self.UIRoot.Text:SetText(LocUtil.LocalizeResFormat(7462, TimeUtil.GetTimeLengthStr(leftSecond, true)))
    else
      self:StopLeftTimeTimer()
    end
  end, TIMER_INFINITE, 5)
end
function ModeSelection_Main_Item_Base:StopLeftTimeTimer()
  if self.leftTimeTimer then
    self:RemoveTimer(self.leftTimeTimer)
    self.leftTimeTimer = nil
  end
end
function ModeSelection_Main_Item_Base:GetMapKeyInfo(widget, itemData, themeData, isSelectTheme)
  if not itemData then
    return nil, nil
  end
  local data = isSelectTheme and themeData or itemData
  local logic_mode_map_download = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_map_download)
  local mapKeyList, mapKeyDict = logic_mode_map_download:GetMapKeyListByViewData(data)
  return mapKeyList, mapKeyDict
end
local _textPath = {
  [0] = 29868,
  [1] = 29867,
  [2] = 29867,
  [3] = 11149,
  [4] = 7420,
  [5] = 29867
}
local _textPathNoTheme = {
  [0] = 31052,
  [1] = 31044,
  [2] = 31044,
  [3] = 11149,
  [4] = 7420,
  [5] = 31044
}
local E_DownloadState = ENUM_DownloadState
local _texturePath = {
  [E_DownloadState.Not] = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Download_png.Common_Icon_Download_png",
  [E_DownloadState.Download] = "/Game/UMG/Texture_200/Lobby_NoAtlas/Download/Download_Icon_Cloud.Download_Icon_Cloud",
  [E_DownloadState.Pause] = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Begin_png.Common_Icon_Begin_png",
  [E_DownloadState.Done] = "",
  [E_DownloadState.Error] = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Download_png.Common_Icon_Download_png",
  [E_DownloadState.Wait] = "/Game/UMG/Texture/Atlas/Common_Atlas/Frames/Setting_icon_dengdai_png.Setting_icon_dengdai_png"
}
function ModeSelection_Main_Item_Base:RefreshDownloadInfo(widget, mapKeyList, itemData)
  if not widget or not mapKeyList then
    return ENUM_DownloadState.Done, 0, 0
  end
  local logic_mode_map_download = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_map_download)
  local state = logic_mode_map_download:GetMapListState(mapKeyList)
  local Logic_Lobby_DownLoad = require("client.slua.logic.download.logic_lobby_downloader")
  if state == ENUM_DownloadState.Done then
    widget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return ENUM_DownloadState.Done, 0, 0
  elseif Logic_Lobby_DownLoad.IsModeSwitchDownLoadReward(mapKeyList) then
    widget.Image_reward_bg:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    widget.Image_reward:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  else
    widget.Image_reward_bg:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    widget.Image_reward:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  widget.Panel_Download:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  local curSize, totalSize, dependSize, dependTotal = logic_mode_map_download:GetMapListSize(mapKeyList)
  local PufferConst = require("client.slua.logic.download.puffer_const")
  log(bWriteLog and "ModeSelection_Main_Item_Base:RefreshDownloadInfo curSize = " .. tostring(curSize) .. " totalSize = " .. tostring(totalSize))
  log(bWriteLog and "ModeSelection_Main_Item_Base:RefreshDownloadInfo dependSize = " .. tostring(dependSize) .. " dependTotal = " .. tostring(dependTotal))
  local Slot = widget.Text_Download and widget.Text_Download.Slot
  if Slot then
    Slot:SetPosition(FVector2D(0, 15))
  end
  local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
  local Common_Download_StateUI = widget.Common_Download_StateUI
  if state == PufferConst.ENUM_DownloadState.Download and totalSize - curSize < PufferConst.MB and dependSize == dependTotal then
    for key, value in pairs(mapKeyList) do
      if not PufferMapManager:CanPause(value) then
        self:SetWidgetVisible(Common_Download_StateUI.CanvasPanel_Arrow, false)
        self:SetTexture(Common_Download_StateUI.Image_State, "/Game/UMG/Texture/Atlas/Common_Atlas/Frames/Setting_icon_anzhuang_png.Setting_icon_anzhuang_png")
        widget.ProgressBar_Mask:SetPercent(0)
        widget.Text_Progress:SetText("")
        widget.Text_Download:SetText(LocUtil.LocalizeResFormat(29871))
        return ENUM_DownloadState.Download, 0, 0
      end
    end
  end
  if state == ENUM_DownloadState.Not then
    totalSize = totalSize - curSize
    dependTotal = dependTotal - dependSize
    curSize = 0
  end
  if state == ENUM_DownloadState.Error then
    widget.ProgressBar_Mask:SetPercent(1)
  else
    widget.ProgressBar_Mask:SetPercent(1 - curSize / totalSize)
  end
  local common_download_handler = require("client.slua.common.common_download_handler")
  if self.state ~= state then
    common_download_handler.UpdateCommonDownloadStateUI(Common_Download_StateUI, state)
    self.  end
  local pct = 0
  if 0 < totalSize then
    pct = curSize / totalSize
  end
  common_download_handler.UpdateCommonDownloadStateUIPercent(Common_Download_StateUI, pct)
  if totalSize == 0 and curSize == 0 then
    widget.Text_Download:SetText("")
    widget.Text_Progress:SetText("")
    return state, curSize, totalSize
  end
  curSize = math.max(curSize, PufferConst.MB * 0.1)
  totalSize = math.max(totalSize, PufferConst.MB * 0.1)
  if state == ENUM_DownloadState.Done or state == ENUM_DownloadState.Error then
    widget.Text_Progress:SetText("")
    widget.Text_Download:SetText(LocUtil.LocalizeResFormat(_textPath[state]))
  else
    if not (itemData and itemData.group_type and itemData.group_type == "theme" and dependTotal / PufferConst.MB > 10) or (totalSize - dependTotal) / PufferConst.MB > 1 then
    else
    end
    local remainSize = math.floor((totalSize - curSize) / PufferConst.MB + 0.5)
    if remainSize < 1 then
      remainSize = 1
    end
    widget.Text_Progress:SetText(LocUtil.LocalizeResFormat(31052, remainSize))
    widget.Text_Download:SetText("")
  end
  return state, curSize, totalSize
end
function ModeSelection_Main_Item_Base:DownloadMapKeyList(mapKeyList, b4GNotDownload)
  local logic_mode_map_download = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_map_download)
  logic_mode_map_download:DownloadMapKeyList(mapKeyList, b4GNotDownload)
end
function ModeSelection_Main_Item_Base:PausedMapKeyList(mapKeyList)
  local logic_mode_map_download = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_map_download)
  logic_mode_map_download:PausedMapKeyList(mapKeyList)
end
function ModeSelection_Main_Item_Base:GetNewbieGuideWidget()
  return self.UIRoot.Button_Item
end
function ModeSelection_Main_Item_Base:GetItemData()
  return self.data
end
function ModeSelection_Main_Item_Base:SetExtraInfoVisible(visible)
  if not self.UIRoot.WidgetSwitcher_ExtraInfo then
    return
  end
  local is_ranked = self.data.is_ranked
  self:SetWidgetVisible(self.UIRoot.WidgetSwitcher_ExtraInfo, visible)
  if visible then
    local index = is_ranked == 1 and 0 or 1
    self.UIRoot.WidgetSwitcher_ExtraInfo:SetActiveWidgetIndex(index)
  end
end
function ModeSelection_Main_Item_Base:OnClose()
  self:SetExtraInfoVisible(false)
  if self.UIRoot and self.UIRoot.Button_Detail then
    self:SetWidgetVisible(self.UIRoot.Button_Detail, true, true)
  end
end
function ModeSelection_Main_Item_Base:RegistEvents()
  ModeSelection_Main_Item_Base.__super.RegistEvents(self)
end
local pakNameCache = {}
function ModeSelection_Main_Item_Base:DownloadResRet(_, __, eventData)
  if not (eventData and eventData.pakName) or eventData.errorCode ~= 0 then
    return
  end
  if not self.data and not self.themeData then
    return
  end
  local _judgeUsePak = function(data, InPakName)
    if not data then
      return false
    end
    if not InPakName then
      return false
    end
    local useSmallBg = data.show_type == "NORMAL" or self.forceUseSmallBg
    local img_path = useSmallBg and data.small_bg or data.big_bg
    local pakName = pakNameCache[img_path]
    if not pakName then
      local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
      pakName = PufferManager.GetPakName(img_path)
      pakNameCache[img_path] = pakName
    end
    return pakName == InPakName
  end
  if not _judgeUsePak(self.data, eventData.pakName) and not _judgeUsePak(self.themeData, eventData.pakName) then
    return
  end
  self:SetItemData(self.UIRoot, self.data, self.themeData, self.isSelectTheme)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, ModeSelection_Main_Item_Base)