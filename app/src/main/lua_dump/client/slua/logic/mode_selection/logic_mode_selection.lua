local logic_mode_selection = {}
local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
local menu, default, modeIdToSimpleViewInfo
local isInitMode = false
local viewTypeList, modeIdToMutiViewList, viewIDToModeID, modeViews2BgCfg
local cacheMapKeys = {}
local defaultSelectViewID
local isFromLobyy = false
function logic_mode_selection:OnInitialize()
  viewTypeList = nil
  self.matchInfo = {}
  if not menu or not default then
    self:RequireModeData()
  end
  self.tempMultiSelect = nil
  self._req_ugc = nil
  local logic_mode_selection_for_umg = require("client.slua.logic.mode_selection.logic_mode_selection_for_umg")
  self.hasSelectTxMission = logic_mode_selection_for_umg.GetTxMissionChoiceInLocal()
end
function logic_mode_selection:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC, self.OnSyncMatchInfoByTeam, self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_MATCH_MODE_SELECTION, self.OnUrlModeJump, self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_SOCIAL_ENTRY, self.EnterSocialIsland, self)
  self:AddCommonEvent(EVENTTYPE_LOGIN, EVENTID_LOGIN_SUCCESS, self.OnLogin, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_NEW_TEAM_MATCH_MODE, self.OnChangeTeamMatchMode, self)
  self:AddCommonEvent(EVENTTYPE_LEVEL_UNLOCK, EVENTID_LEVEL_UNLOCK_START_UNLOCK_GUIDE, self.OnStartUnlockGuide, self)
  self:AddCommonEvent(EVENTTYPE_NETWORK, EVENTID_LOBBY_SERVER_CONNECT_FAILED, self.OnServerError, self)
end
function logic_mode_selection:OnLogOut()
  defaultSelectViewID = nil
  isInitMode = false
  menu = nil
  default = nil
  viewIDToModeID = nil
  self._req_ugc = nil
end
function logic_mode_selection:OnPostSwitchGameStatus(preState, nextState)
  log(bWriteLog and "logic_mode_selection:OnPostSwitchGameStatus preState: " .. tostring(preState) .. " nextState: " .. tostring(nextState))
  if preState == GameStatus.Fighting and nextState == GameStatus.Lobby then
    local LogicNewbie = require("client.logic.newbie.logic_newbie")
    local enter_game_num = LogicNewbie.newbieTotalGameCnt
    log(bWriteLog and "logic_mode_selection:OnPostSwitchGameStatus enter_game_num = " .. tostring(enter_game_num))
    local bNeedPullModeSelection = false
    if DataMgr.GetNewbieGuideValue(LogicNewbie.NEWBIE_GUIDE_MODULE_ID_FIGHT_GUIDE, -2) then
      log(bWriteLog and "logic_mode_selection:OnPostSwitchGameStatus 1")
      bNeedPullModeSelection = enter_game_num and enter_game_num == 1
    else
      log(bWriteLog and "logic_mode_selection:OnPostSwitchGameStatus 2")
      bNeedPullModeSelection = enter_game_num and enter_game_num == 2
    end
    log(bWriteLog and "logic_mode_selection:OnPostSwitchGameStatus bNeedPullModeSelection = " .. tostring(bNeedPullModeSelection))
    if bNeedPullModeSelection then
      self:RequireModeData()
    end
  end
end
local _GetViewTypeMenuList = function()
  if not menu or not menu.sub_menus then
    return
  end
  local modeList = {}
  local function _GetFilterMenuList(menuInfo)
    for _, v in pairs(menuInfo) do
      if v.type == mode_selection_macro.Enum_Menu_Type.View and v.id ~= mode_selection_macro.Enum_TabID.MatchNewbie then
        table.insert(modeList, v)
      elseif v.sub_menus then
        _GetFilterMenuList(v.sub_menus)
      end
    end
  end
  _GetFilterMenuList(menu.sub_menus)
  if 1 < #modeList then
    table.sort(modeList, function(a, b)
      return a.sort_score < b.sort_score
    end)
  end
  return modeList
end
local function _GetMenuListByViewIDWithTable(menuInfo, view_id, menu_list)
  if not menuInfo then
    return false, {}
  end
  if menuInfo.type == mode_selection_macro.Enum_Menu_Type.View then
    for k, v in ipairs(menuInfo.sub_views) do
      if v == view_id then
        table.insert(menu_list, menuInfo.id)
        return true, menu_list
      else
        local viewData = default[v]
        if viewData.group_view then
          for kk, vv in pairs(viewData.group_view) do
            if vv and vv.view_id == view_id then
              table.insert(menu_list, menuInfo.id)
              return true, menu_list
            end
          end
        end
      end
    end
  else
    for k, v in ipairs(menuInfo.sub_menus) do
      local isGet, menuList = _GetMenuListByViewIDWithTable(v, view_id, menu_list)
      if isGet then
        table.insert(menuList, menuInfo.id)
        return true, menuList
      end
    end
  end
  return false, {}
end
function logic_mode_selection:OnSyncMatchInfo(match_info)
end
function logic_mode_selection:OnSyncMatchInfoByTeam(event_type, eventID, sync_type)
  log(bWriteLog and "logic_mode_selection:OnSyncMatchInfoByTeam")
  if sync_type and sync_type ~= ENUM_TeamInfoSyncType.All and sync_type ~= ENUM_TeamInfoSyncType.Compatible and sync_type ~= ENUM_TeamInfoSyncType.MatchMode then
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if not TeamUpNewSystem.teamInfo then
    log(bWriteLog and "logic_mode_selection:OnSyncMatchInfoByTeam get nil TeamUpNewSystem.teamInfo!!!")
    return
  end
  self.matchMode = TeamUpNewSystem.teamInfo.team_type
  self.bAutoFill = TeamUpNewSystem.teamInfo.fill == 1
  if TeamUpNewSystem.teamInfo.sub_mode_view_ids then
    local previewID = self.viewId
    local afterViewID = TeamUpNewSystem.teamInfo.sub_mode_view_ids[1]
    self.viewId = afterViewID
    self.viewIDs = TeamUpNewSystem.teamInfo.sub_mode_view_ids
    log_format("logic_mode_selection:OnSyncMatchInfoByTeam previewID: %s, afterViewID: %s", previewID, afterViewID)
    if previewID and previewID ~= afterViewID then
      EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_MATCH_VIEW_SELECT_CHANGE)
    end
  end
  self:SetSelectInfo()
  if self.perspective and self.teamNum then
    self:ResetModeToAvailableMap()
  end
  local logic_ugc_mode = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_mode)
  if logic_ugc_mode:IsSelectUgcMode() then
    local Util_UGC = require("client.slua.logic.ugc.util_ugc")
    local Config_UGC = require("client.slua.logic.ugc.config_ugc")
    Util_UGC.SetUGCNewbieGuideFinish(Config_UGC.Newbie_Guide_Type_Key.FirstSelectUGCMod)
  end
  EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_MATCH_MODE_SELECT_CHANGE)
  local logic_team_platform_new = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_team_platform_new)
  logic_team_platform_new:SetNeedRefreshModeList(true)
  local LogicUGCMulti = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMulti)
  LogicUGCMulti:RefreshIsBundleMatch()
  TeamUpNewSystem.ShowExtraTeamUI()
  if not self.viewId then
    return
  end
  local menuIdList = self:GetMenuListByViewID(self.viewId)
  if not menuIdList then
    return
  end
  local menuId = menuIdList[1]
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eModeSelectionMainUI) or {}
  if not (cfg and cfg.menuFilter) or not cfg.menuFilter[menuId] then
    return
  end
  cfg.menuFilter[menuId].perspective = self.perspective
  cfg.menuFilter[menuId].teamNum = self.teamNum
  cfg.menuFilter[menuId].bAutoFill = self.bAutoFill
  if not cfg.modeLogin200 then
    cfg.modeLogin200 = true
    cfg.multiSelect = nil
  end
  PlayerPrefsSystem.SaveTableToFile_N(cfg, PlayerPrefsSystem.ePlayerPrefsType.eModeSelectionMainUI)
end
function logic_mode_selection:OnUrlModeJump(event_type, event_id, params)
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:IsRestrictBatlleAll() then
    QRcodeRestrictManager:ShowRestrictTips()
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if not TeamUpNewSystem.IsTeamLeader() then
    log(bWriteLog and "[edward][match_select_entry] UI_Match_Select_Entry:OnClickEntry, is not team leader!!!")
    ShowNotice(500045)
    return
  end
  if LobbySystem.isInMatch then
    local UGCPlayHallRoom = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.UGCPlayHallRoom)
    if UGCPlayHallRoom and not UGCPlayHallRoom:GetRoomMatchInfo() then
      log(bWriteLog and "[edward][match_select_entry] UI_Match_Select_Entry:OnClickEntry, is matching!!!")
      ShowNotice(110014)
      return
    end
  end
  self:ShowMainUI(params)
end
function logic_mode_selection:SetFromLobby(isfrom)
  isFromLobyy = isfrom
end
function logic_mode_selection:IsFromLobby()
  return isFromLobyy
end
function logic_mode_selection:ShowMainUI(params, isFromLobby)
  isFromLobyy = isFromLobby or false
  if not default or not menu then
    self:RequireModeData()
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.mode_selection_main, params)
end
function logic_mode_selection:OnChangeTeamMatchMode(...)
  if not (self.old_perspective and self.old_teamNum and self.teamNum) or not self.perspective then
    return
  end
  local playerContentText = {
    [1] = 993048,
    [2] = 993049,
    [3] = 8800027,
    [4] = 993050,
    [5] = 8800028,
    [6] = 8800029,
    [7] = 8800030,
    [8] = 993098
  }
  local logic_long_time_match = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_long_time_match)
  local isSwtichLTMatch = logic_long_time_match:IsSwitchLTMatchMode()
  if isSwtichLTMatch then
    logic_long_time_match:SwitchLTMatchModeSuccess(self.teamNum, self.perspective)
  end
  local logic_multi_select_match = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_multi_select_match)
  local isSwitchingMSMatch = logic_multi_select_match:IsSwitchingMSMatch()
  if isSwitchingMSMatch then
    logic_multi_select_match:SwitchMSMatchSuccess()
  end
  if self.old_perspective == self.perspective and self.old_teamNum == self.teamNum then
    return
  end
  local logic_ugc_mode = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_mode)
  if not isSwtichLTMatch and not isSwitchingMSMatch and not logic_ugc_mode:IsSelectUgcMode() then
    local playerNumText = LocUtil.LocalizeResFormat(playerContentText[self.teamNum])
    local perspectText = LocUtil.LocalizeResFormat(self.perspective)
    local content = LocUtil.LocalizeResFormat(31200, perspectText, playerNumText)
    ShowNotice(content)
  end
  self.lastTimeTeamNum = self.old_teamNum
  self.old_perspective = self.perspective
  self.old_teamNum = self.teamNum
end
function logic_mode_selection:OnStartUnlockGuide(_, __, current_level)
  if current_level ~= 8 then
    return
  end
  if not LobbySystem.roleData.is_newbie_rankmode_open then
    log(bWriteLog and "logic_mode_selection:OnStartUnlockGuide is_newbie_rankmode_open" .. tostring(LobbySystem.roleData.is_newbie_rankmode_open))
    return
  end
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  local config = level_unlock_manager:GetUnlockFeature(current_level)
  if not config then
    log(bWriteLog and "logic_mode_selection:OnStartUnlockGuide config is nil, current_level " .. tostring(current_level))
    return
  end
  if config.currentUnlock == level_unlock_manager.featureDef.matchMode then
    local filter = {teamNum = 4, bAutoFill = true}
    local view_id = self:GetFirstAvailableViewId(true)
    log(bWriteLog and "logic_mode_selection:OnStartUnlockGuide " .. tostring(view_id))
    if view_id then
      self:SetSelectView(view_id, filter)
      ShowNotice(47402)
    end
  end
end
function logic_mode_selection:SetSelectInfo()
  if not self.matchMode then
    return
  end
  local modeCfg = CDataTable.GetTableData("MatchModeTable", tostring(self.matchMode))
  self.old_perspective = self.perspective
  self.old_teamNum = self.teamNum
  if not modeCfg then
    log_error(string.format("[COLE]logic_mode_selection:SetSelectInfo get nil config by id = %s", self.matchMode))
    return
  end
  self.perspective = modeCfg.PersonPerspective
  self.teamNum = modeCfg.MaxTeamPlayerNum
end
function logic_mode_selection:GetLastTimeTeamNum()
  return self.lastTimeTeamNum
end
function logic_mode_selection:GetMenuInfo()
  return menu
end
function logic_mode_selection:GetViewDictionary()
  return default
end
function logic_mode_selection:GetSimpleViewInfoDictionary()
  return modeIdToSimpleViewInfo
end
function logic_mode_selection:GetMutiViewInfoDictionary()
  return modeIdToMutiViewList
end
function logic_mode_selection:IsPeakGameViewID(viewID)
  return viewID == 90091 or viewID == 90069 or viewID == 90109
end
function logic_mode_selection:IsArenaViewID(viewID)
  return viewID == 90117 or viewID == 90118 or viewID == 90119 or viewID == 90120
end
function logic_mode_selection:GetBgCfgByViews(views)
  if not modeViews2BgCfg then
    return nil
  end
  if not views or type(views) ~= "table" then
    return nil
  end
  table.sort(views)
  for k, v in ipairs(views) do
    local viewInfo = default[v]
    if self:IsPeakGameViewID(v) or self:IsArenaViewID(v) then
      return viewInfo
    end
    if viewInfo and viewInfo.group_key and modeViews2BgCfg[viewInfo.group_key] then
      return modeViews2BgCfg[viewInfo.group_key]
    end
  end
  local selection_detail_key = table.concat(views, ",")
  if modeViews2BgCfg[selection_detail_key] then
    return modeViews2BgCfg[selection_detail_key]
  end
  return nil
end
function logic_mode_selection:GetTabInfoByTabID(tabId)
  if not tabId or not menu then
    return
  end
  local function GetSubviewList(list)
    local tabInfo
    for i, v in pairs(list) do
      if v.id == tabId then
        return v
      elseif v.sub_menus then
        tabInfo = GetSubviewList(v.sub_menus)
        if tabInfo then
          return tabInfo
        else
        end
      end
    end
  end
  return GetSubviewList(menu.sub_menus)
end
function logic_mode_selection:GetAllTabInfo()
  if not menu or not next(menu) then
    return
  end
  if not menu.sub_menus or not next(menu.sub_menus) then
    return
  end
  local tabInfo = {}
  for _, v in pairs(menu.sub_menus) do
    if v.id == 100 then
      tabInfo[v.id] = v.sub_views
    elseif v.id == 200 then
      for _, menuInfo in pairs(v.sub_menus) do
        tabInfo[menuInfo.id] = menuInfo.sub_views
      end
    end
  end
  return tabInfo
end
function logic_mode_selection:GetSubviewInfoBySubviewID(subviewID)
  if not subviewID or not default then
    return
  end
  return default[subviewID]
end
function logic_mode_selection:GetSelectMapName(subviewIDs)
  if not subviewIDs or not next(subviewIDs) then
    log_error(bWriteLog and "[ZH] logic_mode_selection:GetSelectMapName, viewIDs id empty")
    return
  end
  local subviewID = subviewIDs[1]
  local logic_mode_utils = require("client.slua.logic.mode_selection.logic_mode_utils")
  local mapName = logic_mode_utils.GetMapNameByViewID(subviewID) or ""
  return mapName
end
function logic_mode_selection:GetCurSelectInfo()
  log(bWriteLog and "[ZH] logic_mode_selection:GetCurSelectInfo" .. tostring(self.matchMode) .. " " .. tostring(self.viewId) .. " " .. tostring(self.viewIDs))
  local Lobby_Main_UIBP = UIManager.GetUI(UIManager.UI_Config.Sociallsland_SelectMap_UIBP)
  if GameStatus.IsSocialIslandMode() and Lobby_Main_UIBP then
    return self.matchMode, self.viewId, self.viewIDs
  end
  if self.hasSelectTxMission then
    log(bWriteLog and "[ZH] logic_mode_selection:GetCurSelectInfo, hasSelectTxMission")
    return 260, 20000, {20000}
  end
  return self.matchMode, self.viewId, self.viewIDs
end
function logic_mode_selection:GetFilterInfo()
  local modeInfo = {}
  modeInfo.perspective = self.perspective or 100054
  modeInfo.teamNum = self.teamNum or 1
  modeInfo.bAutoFill = self.bAutoFill
  return modeInfo
end
function logic_mode_selection:GetValidThemeData(view_id, isContainPreOpen)
  if not default or not view_id then
    return nil
  end
  local viewData = default[view_id]
  if not (viewData and viewData.group_type) or viewData.group_type ~= "theme" then
    return nil
  end
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  log(bWriteLog and "[v_wllwu] logic_mode_selection:GetValidThemeData serverTime = " .. tostring(serverTime))
  local PreOpenThemeData
  for k, v in pairs(viewData.group_view) do
    if v.view_id ~= view_id then
      local themeViewData = default[v.view_id]
      local isNeedFindPreOpen = isContainPreOpen and PreOpenThemeData == nil
      local isOpen, isPreOpen = self:IsThemeOpen(themeViewData, serverTime, isNeedFindPreOpen)
      if isOpen then
        return themeViewData
      elseif isPreOpen then
        PreOpenThemeData = themeViewData
      end
    end
  end
  if isContainPreOpen then
    return PreOpenThemeData
  end
  return nil
end
function logic_mode_selection:IsCpMode(ModeViewID)
  local curModeCfg = CDataTable.GetTableByFilter("SpecialPackageConfig", "ModeViewID", ModeViewID)
  if curModeCfg then
    for _, setCfg in pairs(curModeCfg) do
      if setCfg.ModeViewID == ModeViewID then
        log_format(bWriteLog and "logic_mode_selection:IsCpMode = true ,ModeViewID = %s , mapID = %s , PackageName = %s", tostring(setCfg.ModeViewID), tostring(setCfg.ID), tostring(setCfg.PackageName))
        return true, setCfg
      end
    end
  else
    log_format(bWriteLog and "logic_mode_selection:IsCpMode = false , ModeViewID = %s ", tostring(ModeViewID))
  end
  return false, nil
end
function logic_mode_selection:IsThemeOpen(themeViewData, curTime, isNeedFindPreOpen)
  if not themeViewData or not curTime then
    return nil, nil
  end
  if themeViewData.id and self:IsCpMode(themeViewData.id) then
    local isCp, curModeCfg = self:IsCpMode(themeViewData.id)
    if isCp and curModeCfg then
      local cpName = Client.GetUEPUBGMCPName()
      if curModeCfg.PackageName == cpName then
        return true, false
      else
        return false, false
      end
    end
  end
  local isPreOpen = false
  if not themeViewData.open_limits then
    return true, isPreOpen
  end
  local logic_mode_utils = require("client.slua.logic.mode_selection.logic_mode_utils")
  for kk, vv in pairs(themeViewData.open_limits) do
    if logic_mode_utils.IsViewOpen(vv, curTime) then
      return true
    elseif isNeedFindPreOpen and not isPreOpen then
      isPreOpen = logic_mode_utils.IsViewPreOpen(vv, curTime)
    end
  end
  return nil, isPreOpen
end
function logic_mode_selection:GetIsSelectTheme(itemData, themeData)
  if not themeData then
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eModeSelectionMainUI) or {}
  if cfg.themeSelect and cfg.themeSelect[itemData.id] then
    return cfg.themeSelect[itemData.id]
  end
  for _, v in ipairs(itemData.group_view or {}) do
    if v.view_id == itemData.id then
      return false
    elseif v.view_id == themeData.id then
      return true
    end
  end
  return false
end
function logic_mode_selection:CheckIsSelectedThemeView(targetMenuID)
  local _, selectViewID, _ = self:GetCurSelectInfo()
  local isTargetThemeView = self:CheckIsTargetThemeView(selectViewID, targetMenuID)
  if not isTargetThemeView then
    log_warning_format("logic_mode_selection:GetIsSelectedThemeView. isTargetThemeView is false. selectViewID = [%s]", selectViewID)
    return false
  end
  return true
end
function logic_mode_selection:CheckIsTargetThemeView(targetViewID, targetMenuID)
  local viewInfo = default and default[targetViewID]
  if not viewInfo then
    log_warning_format(bWriteLog and "logic_mode_selection:CheckIsTargetThemeView, not view. targetViewID = [%s]", targetViewID)
    return false
  end
  log_tree("logic_mode_selection:CheckIsTargetThemeView. viewInfo = ", viewInfo)
  if targetMenuID then
    local menuID = viewInfo.menu_id
    if menuID ~= targetMenuID then
      log_warning_format("logic_mode_selection:CheckIsTargetThemeView. menuID is not targetMenuID. menuID = [%s], targetMenuID = [%s]", menuID, targetMenuID)
      return false
    end
  end
  local modeID = self:GetModeIDByViewID(targetViewID)
  if not modeID then
    log_warning(bWriteLog and "logic_mode_selection:CheckIsTargetThemeView, not mode")
  end
  local isTargetView = false
  local modeConfig = CDataTable.GetTableData("BTMode", modeID)
  if modeConfig and modeConfig.BattleModeFightType == 1 then
    isTargetView = true
  end
  log_format("logic_mode_selection:CheckIsTargetThemeView. isTargetView = [%s]", isTargetView)
  return isTargetView
end
function logic_mode_selection:GetModeIDByViewID(viewID)
  local viewInfo = self:GetSubviewInfoBySubviewID(viewID)
  if not viewInfo then
    return
  end
  if not viewIDToModeID then
    viewIDToModeID = {}
    for modeID, viewIDList in pairs(modeIdToMutiViewList) do
      for _, v in pairs(viewIDList) do
        viewIDToModeID[v.id] = modeID
      end
    end
    log_tree("logic_mode_selection:GetModeIDByViewID. viewIDToModeID = ", viewIDToModeID)
  end
  return viewIDToModeID[viewID]
end
function logic_mode_selection:GetMatchModeByViewId(viewId, perspective, teamNum)
  local viewInfo = self:GetSubviewInfoBySubviewID(viewId)
  if not viewInfo or not viewInfo.options then
    log(bWriteLog and "[logic_mode_selection] GetMatchModeByViewId failed, viewInfo or options is nil, viewId = " .. tostring(viewId))
    return nil
  end
  local teamType = viewInfo.options.team_type
  if not teamType then
    log(bWriteLog and "[logic_mode_selection] GetMatchModeByViewId failed, team_type is nil, viewId = " .. tostring(viewId))
    return nil
  end
  local filterInfo = self:GetFilterInfo()
  perspective = perspective or filterInfo.perspective
  teamNum = teamNum or filterInfo.teamNum
  if not teamType[perspective] then
    log(bWriteLog and "[logic_mode_selection] GetMatchModeByViewId failed, perspective not found, viewId = " .. tostring(viewId) .. ", perspective = " .. tostring(perspective))
    return nil
  end
  local matchMode = teamType[perspective][teamNum]
  log(bWriteLog and "[logic_mode_selection] GetMatchModeByViewId success, viewId = " .. tostring(viewId) .. ", perspective = " .. tostring(perspective) .. ", teamNum = " .. tostring(teamNum) .. ", matchMode = " .. tostring(matchMode))
  return matchMode
end
function logic_mode_selection:GetNormalViewIdByThemeId(themeId)
  if not themeId then
    return
  end
  local viewInfo = default and default[themeId]
  local logic_mode_utils = require("client.slua.logic.mode_selection.logic_mode_utils")
  if not logic_mode_utils.IsThemeGroupView(viewInfo) then
    return
  end
  if viewInfo.is_group_base then
    return
  end
  for _, v in pairs(viewInfo.group_view) do
    if v.note == "base" then
      return v.view_id
    end
  end
  log(bWriteLog and "[v_Wllwu] logic_mode_selection:GetNormalViewIdByThemeId not find " .. tostring(themeId))
  return nil
end
function logic_mode_selection:GetMenuListByViewID(view_id)
  if not default or not menu then
    return {}
  end
  local isGet, menuList = _GetMenuListByViewIDWithTable(menu, view_id, {})
  return menuList
end
function logic_mode_selection:GetViewTypeMenuList(forceUpdate)
  if not viewTypeList or forceUpdate then
    viewTypeList = _GetViewTypeMenuList()
  end
  return viewTypeList or {}
end
function logic_mode_selection:GetMaxPlayerNumByViewId(viewId)
  if not viewId or not default then
    log(bWriteLog and "[v_wllwu] logic_mode_selection:GetMaxPlayerNumByViewId nil, viewId = " .. tostring(viewId))
    return
  end
  local TableUtil = require("common.table_util")
  local teamInfo = TableUtil.GetTableValue(default, viewId, "options", "team_type")
  if not teamInfo then
    log(bWriteLog and "[v_wllwu] logic_mode_selection:GetMaxPlayerNumByViewId teamInfo is nil, viewId = " .. tostring(viewId))
    return
  end
  local maxNum = 0
  for _, info in pairs(teamInfo) do
    for num, _ in pairs(info) do
      if num > maxNum then
        maxNum = num
      end
    end
  end
  return maxNum
end
function logic_mode_selection:GetModeMaxTeamNum()
  local _, selectViewID, _ = self:GetCurSelectInfo()
  return self:GetMaxPlayerNumByViewId(selectViewID) or 4
end
function logic_mode_selection:IsSelect8PlayersMode()
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  if LogicUGCMatch:GetMatchModID() > 0 then
    local matchInfo = LogicUGCMatch:GetMatchInfo()
    local teamSize = 1
    if not matchInfo or not matchInfo.setting then
      teamSize = 1
    else
      teamSize = matchInfo.setting.team_size or 1
      if teamSize == -1 then
        teamSize = matchInfo.setting.max_num or 1
      end
    end
    return 5 <= teamSize
  end
  return self:GetModeMaxTeamNum() == 8
end
function logic_mode_selection:IsClassicRankMode(matchMode)
  local rankModeList = {
    [101] = true,
    [102] = true,
    [103] = true,
    [401] = true,
    [402] = true,
    [403] = true,
    [11201] = true,
    [723] = true
  }
  return rankModeList[matchMode]
end
function logic_mode_selection:IsClassicMatchMode(matchMode)
  local matchModeList = {
    [111] = true,
    [112] = true,
    [113] = true,
    [411] = true,
    [412] = true,
    [413] = true
  }
  return matchModeList[matchMode]
end
function logic_mode_selection:GetModeJumpActivity()
  local   local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local actList = ActivityNewSystem.GetActivityListByType(ActivityType.GAME_URI)
  local actInfo = actList[1]
  if actInfo then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eModeSelectionMainUI)
    if cfg and cfg.actClick and cfg.actClick[actInfo.ID] then
      actInfo = nil
    end
  end
  return actInfo
end
function logic_mode_selection:CheckHasMapKey(mapKey)
  if not mapKey then
    return false
  end
  return cacheMapKeys[mapKey]
end
function logic_mode_selection:GetMenuPathStrByMapId(mapId)
  if not mapId then
    return
  end
  local logic_mode_map_download = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_map_download)
  local menuMapTable = logic_mode_map_download:GetMapIdListByTabId()
  if not menuMapTable or not next(menuMapTable) then
    return
  end
  for menuId, v in pairs(menuMapTable) do
    for _, Id in pairs(v) do
      if Id == tonumber(mapId) then
        return mode_selection_macro.jumpMenuConfig[menuId] or ""
      end
    end
  end
  return ""
end
function logic_mode_selection:GetMenuPathStrByMapKey(mapKey)
  if not mapKey then
    return
  end
  local logic_mode_map_download = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_map_download)
  local menuMapTable = logic_mode_map_download:GetMapIdListByTabId()
  if not menuMapTable or not next(menuMapTable) then
    return
  end
  for menuId, v in pairs(menuMapTable) do
    for _, Id in pairs(v) do
      local mapCfg = CDataTable.GetTableData("Map", Id)
      if mapCfg and mapCfg.MapKey == mapKey then
        return mode_selection_macro.jumpMenuConfig[menuId] or ""
      end
    end
  end
  return ""
end
function logic_mode_selection:GetDefaultViewID()
  return defaultSelectViewID
end
function logic_mode_selection:SetSelectView(view_id, filter_info, button_close)
  if not default then
    return
  end
  local view_ids = view_id
  if type(view_id) == "number" then
    view_ids = {view_id}
  end
  if not view_ids then
    return
  end
  if button_close then
    local bIsSameView = false
    if type(view_id) == "number" then
      bIsSameView = view_id == self.viewId
    elseif type(view_id) == "table" then
      local TableUtil = require("common.table_util")
      bIsSameView = TableUtil.IsSameTable(view_id, self.viewIDs)
    end
    local bIsSameFilter = filter_info.perspective == self.perspective and filter_info.teamNum == self.teamNum and filter_info.bAutoFill == self.bAutoFill
    if bIsSameView and bIsSameFilter then
      log_error("logic_mode_selection:SetSelectView is same view and filter")
      return
    end
  end
  log_tree("logic_mode_selection:SetSelectView", view_ids)
  if filter_info.teamNum == 1 then
    filter_info.bAutoFill = false
  end
  local config_arena = require("client.slua.logic.arena.config_arena")
  local downloadFailed = false
  for i = #view_ids, 1, -1 do
    local viewInfo = default[view_ids[i]]
    local isArena = viewInfo and viewInfo.menu_id == config_arena.ModeMenuId
    if not viewInfo or not self:IsModeMapAvailable(viewInfo) then
      log(bWriteLog and "[edward] logic_mode_selection:SetSelectView, Check Mode Map Download failed")
      downloadFailed = true
      if not isArena then
        table.remove(view_ids, i)
      end
    end
  end
  if #view_ids == 0 then
    if type(view_id) == "number" then
      log_error("[COLE]logic_mode_selection:SetSelectView get nil info by id= " .. tostring(view_id))
    elseif type(view_id) == "table" then
      log_error("[COLE]logic_mode_selection:SetSelectView get nil info by id= " .. tostring(view_id[1]))
    end
    if downloadFailed and not button_close then
      ShowNotice(505089)
    end
    return
  end
  local firstViewInfo = default[view_ids[1]]
  if firstViewInfo.url and firstViewInfo.url ~= "" then
    local StringUtil = require("common.string_util")
    local params = StringUtil.ParseURLParams(firstViewInfo.url)
    local moduleId = tonumber(params.module)
    local isSelf = moduleId == BP_ENUM_MODULE_MATCH_MODE_SELECTION
    local doWithSelfPanel = false
    if isSelf then
      if UIManager.IsUIShow(UIManager.UI_Config.mode_selection_main) then
        local mainPanel = UIManager.GetUI(UIManager.UI_Config.mode_selection_main)
        if mainPanel then
          doWithSelfPanel = true
          mainPanel:UpdateJumpData(params)
        end
      elseif UIManager.IsUIShow(UIManager.UI_Config.Sociallsland_SelectMap_UIBP) then
        local mainPanel = UIManager.GetUI(UIManager.UI_Config.Sociallsland_SelectMap_UIBP)
        if mainPanel then
          doWithSelfPanel = true
          mainPanel:JumpToArena()
        end
      end
    end
    if not doWithSelfPanel then
      local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
      ActivityNewSystem.JumpUrl(firstViewInfo.url)
    end
    local logic_newbie_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_mode_selection)
    local isNewbieView = logic_newbie_mode_selection:IsNewbieView(view_id)
    if isNewbieView then
      logic_newbie_mode_selection:SetSelectView(view_id)
    end
    if not doWithSelfPanel and not isSelf and (type(view_id) ~= "number" or not isNewbieView) then
      self:DelayCloseMainUI()
    end
    return
  end
  local options = firstViewInfo.options
  if not options then
    return
  end
  local teamType = options.team_type
  if not teamType[filter_info.perspective] then
    log_error("[COLE]logic_mode_selection:SetSelectView invalid perspective id=" .. tostring(view_ids[1]) .. " perspective=" .. tostring(filter_info.perspective))
    filter_info.perspective = options.default_person
  end
  if not teamType[filter_info.perspective][filter_info.teamNum] then
    log_error("[COLE]logic_mode_selection:SetSelectView invalid team num id=" .. tostring(view_ids[1]) .. " perspective=" .. tostring(filter_info.perspective) .. " team number=" .. tostring(filter_info.teamNum))
    filter_info.teamNum = options.default_team_size
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.GetTeamNum() > filter_info.teamNum then
    ShowNotice(27570)
    return
  end
  if filter_info.teamNum > TeamUpNewSystem.GetDefaultMaxTeamNum() and TeamUpNewSystem.IsMemberInSocialLand() then
    ShowNotice(27577)
    return
  end
  if not TeamUpNewSystem.IsTeamLeader() then
    ShowNotice(33241)
    return
  end
  self.selectedID = view_ids[1]
  if options.fill_team and options.fill_team.mutable == false then
    filter_info.bAutoFill = options.fill_team.default
  end
  TeamUpNewSystem.team_change_fill_request(filter_info.bAutoFill and 1 or 0)
  EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_SYNC_MATCH_PRESELECT, self:GetFilterInfo(), filter_info, true)
  local modeId = teamType[filter_info.perspective][filter_info.teamNum]
  local LogicSegmentPromotionSync = require("client.slua.logic.segmentPromotionSync.logic_segment_promotion_sync")
  if LogicSegmentPromotionSync then
    LogicSegmentPromotionSync.GetSegmentSyncData(modeId, self.matchMode)
  end
  TeamUpNewSystem.team_change_type_request(modeId, view_ids)
  if not button_close then
    local ui_jump_manager = require("client.common.uibase.ui_jump_manager")
    ui_jump_manager.Clear()
  end
  self:DelayCloseMainUI()
  self:RefreshModeSelectionGuideUIToLobby()
end
function logic_mode_selection:IsXMissionMode(viewId)
  if not (viewId and default) or not default[viewId] then
    log(bWriteLog and "[v_wllwu] logic_mode_selection:IsXMissionMode data is error " .. tostring(viewId))
    return true
  end
  local modeInfo = default[viewId]
  if not modeInfo.url then
    return false
  end
  if modeInfo.url == "" then
    return false
  end
  local s = string.find(modeInfo.url, tostring(BP_ENUM_MODULE_TXMISSION_LOBBY_FROM_JUMP))
  if s ~= nil then
    log(bWriteLog and "[v_wllwu] logic_mode_selection:IsXMissionMode " .. tostring(viewId))
    return true
  end
  return false
end
function logic_mode_selection:GetCurOpenThemeViewId()
  log(bWriteLog and "logic_mode_selection:GetCurOpenThemeViewId start")
  local mutiView_dict = self:GetMutiViewInfoDictionary() or {}
  local minThemeViewId
  for _, views in pairs(mutiView_dict) do
    for _, v in ipairs(views) do
      local themeData = self:GetValidThemeData(v.id, false)
      local data = self:GetSubviewInfoBySubviewID(v.id)
      if themeData and data and self:GetIsSelectTheme(data, themeData) and (not minThemeViewId or minThemeViewId > themeData.id) then
        minThemeViewId = themeData.id
      end
    end
  end
  local viewId = minThemeViewId or 10001
  log(bWriteLog and string.format("logic_mode_selection:GetCurOpenThemeViewId end viewId=%s", tostring(viewId)))
  return viewId
end
function logic_mode_selection:IsModeMapAvailable(viewData)
  local logic_mode_map_download = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_map_download)
  local mapKeyList, _ = logic_mode_map_download:GetMapKeyListByViewData(viewData)
  if not mapKeyList then
    return true
  end
  return logic_mode_map_download:GetMapListState(mapKeyList) == ENUM_DownloadState.Done
end
function logic_mode_selection:ResetModeToAvailableMap()
  if not default or not self.viewIDs then
    return
  end
  if isInitMode then
    return
  end
  isInitMode = true
  local logic_ugc_mode = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_mode)
  if logic_ugc_mode:IsSelectUgcMode() then
    log(bWriteLog and "[v_wllwu] logic_mode_selection:ResetModeToAvailableMap return when select ugc mode")
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.GetTeamNum() > 1 then
    return
  end
  local needSend = false
  local viewIDs = {}
  for _, v in ipairs(self.viewIDs) do
    local viewData = default[v]
    if viewData then
      local isReady = self:IsModeMapAvailable(viewData)
      if not isReady then
        needSend = true
      else
        local isOpen = self:CheckSubViewIsOpen(viewData.id)
        if isOpen then
          table.insert(viewIDs, viewData.id)
        end
      end
    end
  end
  log(bWriteLog and "[v_wllwu][logic_mode_selection] ResetModeToAvailableMap, needSend = " .. tostring(needSend))
  if not needSend then
    return
  end
  if #viewIDs <= 0 then
    local setSelectViewId = defaultSelectViewID or 10201
    viewIDs = {setSelectViewId}
  end
  local subViewID = viewIDs[1]
  local logic_mode_utils = require("client.slua.logic.mode_selection.logic_mode_utils")
  local matchId = logic_mode_utils.GetMtchIdByViewData(default[subViewID], self.perspective, self.teamNum)
  log(bWriteLog and "[v_wllwu][logic_mode_selection] ResetModeToAvailableMap matchId = " .. tostring(matchId))
  if not (matchId and viewIDs) or #viewIDs <= 0 then
    return
  end
  log(bWriteLog and "[v_wllwu][logic_mode_selection] ResetModeToAvailableMap" .. tostring(#self.viewIDs) .. " viewID = " .. tostring(viewIDs[1]))
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.team_change_type_request(matchId, viewIDs)
end
function logic_mode_selection:ForceResetModeToAvailableMap()
  if not default or not self.viewIDs then
    return
  end
  local needSend = false
  local setSelectViewId = defaultSelectViewID or 10201
  viewIDs = {setSelectViewId}
  local subViewID = viewIDs[1]
  local logic_mode_utils = require("client.slua.logic.mode_selection.logic_mode_utils")
  local matchId = logic_mode_utils.GetMtchIdByViewData(default[subViewID], self.perspective, self.teamNum)
  log(bWriteLog and "[logic_mode_selection] ForceResetModeToAvailableMap matchId = " .. tostring(matchId))
  if not (matchId and viewIDs) or #viewIDs <= 0 then
    return
  end
  log(bWriteLog and "[logic_mode_selection] ForceResetModeToAvailableMap" .. tostring(#self.viewIDs) .. " viewID = " .. tostring(viewIDs[1]))
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.team_change_type_request(matchId, viewIDs)
end
function logic_mode_selection:IsSubViewNew(viewId)
  if not viewId or not default then
    return false
  end
  local data = default[viewId]
  if not data then
    return false
  end
  if data.is_new and data.is_new == 1 then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eModeSelectionMainUI) or {}
    if cfg.mapClick and cfg.mapClick[viewId] then
      return false, cfg
    end
    return true, cfg
  end
  return false
end
function logic_mode_selection:IsSubViewNew2(viewId)
  if not viewId or not default then
    return false
  end
  local data = default[viewId]
  if not data then
    return false
  end
  if not data.is_new then
    return false
  end
  if data.is_new == 2 then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eModeSelectionMainUINewDetail) or {}
    if cfg.mapClick and cfg.mapClick[viewId] then
      return false, cfg
    end
    return true, cfg
  end
  return false
end
function logic_mode_selection:ClickSubViewDetail(viewId, cfg)
  if not viewId or not default then
    return false
  end
  local data = default[viewId]
  if not data then
    return false
  end
  if not data.is_new then
    return false
  end
  if data.is_new == 2 then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    cfg = cfg or PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eModeSelectionMainUINewDetail) or {}
    if not cfg.mapClick then
      cfg.mapClick = {}
    end
    if not cfg.mapClick[viewId] then
      cfg.mapClick[viewId] = 1
      PlayerPrefsSystem.SaveTableToFile_N(cfg, PlayerPrefsSystem.ePlayerPrefsType.eModeSelectionMainUINewDetail)
    end
  end
  return false, cfg
end
function logic_mode_selection:CheckSubViewIsOpen(viewId, dontCheckLevel)
  if not (viewId and default) or not default[viewId] then
    log(bWriteLog and "[v_Wllwu] logic_mode_selection:CheckSubViewIsOpen not open " .. tostring(viewId))
    return
  end
  local isOpen = false
  local viewData = default[viewId]
  if not viewData.open_limits then
    isOpen = true
  else
    isOpen = logic_mode_selection:GetTimeLimitStr(viewData)
  end
  if isOpen and not dontCheckLevel then
    local isLevelEnough = viewData.level_limit <= DataMgr.roleData.level
    local isPreLevelEnough = (viewData.pre_level_limit or 0) <= (DataMgr.roleData.pve_level or 0)
    if not isLevelEnough or not isPreLevelEnough then
      isOpen = false
    end
  end
  return isOpen
end
function logic_mode_selection:CheckMapKeyNeedDownload(mapKey)
  local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
  if PufferMapManager:IsDefaultMapKey(mapKey) then
    return false
  end
  if mapKey == "map_socialisland" or mapKey == "map_singletraining" then
    return true
  end
  local StringUtil = require("common.string_util")
  if StringUtil.Starts(mapKey, "map_tplan") then
    mapKey = "map_tplan"
  end
  if self:CheckHasMapKey(mapKey) then
    return true
  end
  if StringUtil.Starts(mapKey, "map_primeguide") then
    return true
  end
  return false
end
function logic_mode_selection:RefreshModeSelectionGuideUIToLobby()
  local VideoLibrary = require("client.slua.logic.video.lobby_video_function_library")
  if not self.selectedID then
    log(bWriteLog and "[ZH] no self.selectedID")
    return
  end
  log(bWriteLog and "[ZH] RefreshModeSelectionGuideUIToLobby")
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  local IsFirstChooseMode = DataMgr.HaveNewbieGuide(LogicNewbie.NEWBIE_GUIDE_MODULE_ID_MATCH_FIRST_SELECT, self.selectedID)
  if IsFirstChooseMode then
    local viewInfo = self:GetSubviewInfoBySubviewID(self.selectedID)
    if not viewInfo or not viewInfo.details then
      return
    end
    local popIndex = 1
    local isforcepop = false
    for k, v in pairs(viewInfo.details) do
      local info = viewInfo.details[k] or {}
      if info.force_popup then
        if info.type == 5 then
          local VideoPath = info.pads[1].url or ""
          if VideoLibrary.IsVideoFileReady(VideoPath) then
            isforcepop = true
          else
            log(bWriteLog and "[ZH] can not play vedio")
          end
        else
          isforcepop = true
        end
        popIndex = k
      end
    end
    if not isforcepop then
      log(bWriteLog and " [ZH]logic_mode_selection:RefreshModeSelectionGuideUIToLobby can not show detail in lobby")
      return
    end
    local time_ticker = require("common.time_ticker")
    time_ticker.AddTimerOnce(0.75, function()
      self:OpenModeSelectionDetails(self.selectedID, popIndex)
    end)
    DataMgr.SetNewbieGuide(LogicNewbie.NEWBIE_GUIDE_MODULE_ID_MATCH_FIRST_SELECT, self.selectedID)
  end
end
function logic_mode_selection:DelayCloseMainUI()
  local time_ticker = require("common.time_ticker")
  time_ticker.AddTimerOnce(0.2, function()
    EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_STOP_MAP_ANIMATION)
    EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_MATCH_MODE_MAINUI_CLOSE)
    isFromLobyy = false
    local mode_selection_main = UIManager.UI_Config.mode_selection_main
    if UIManager.IsUIShow(mode_selection_main) then
      UIManager.CloseUI(mode_selection_main)
    else
      local Lobby_Main_Control = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
      if Lobby_Main_Control.curPage == ENUM_LobbyPageType.Right then
        local ModeSelection_Custom_UIBP = UIManager.GetUI(UIManager.UI_Config.ModeSelection_Custom_UIBP)
        if ModeSelection_Custom_UIBP then
          ModeSelection_Custom_UIBP:ExitRightMode()
        end
      end
    end
  end)
end
function logic_mode_selection:OpenModeSelectionDetails(viewID, popIndex)
  if not viewID then
    log_error("[ZH] OpenModeSelectionDetails no view id")
    return
  end
  local viewInfo = self:GetSubviewInfoBySubviewID(viewID)
  if not (viewInfo and viewInfo.details) or not viewInfo.details[1] then
    log_error("[ZH] OpenModeSelectionDetails no view info")
    return
  end
  local details = viewInfo.details
  local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
  if details[1].type == mode_selection_macro.E_UITYPE.TEXT then
    UIManager.ShowUI(UIManager.UI_Config.ModeSelection_Guide_UIBP02, viewID, popIndex)
  elseif details[1].type == mode_selection_macro.E_UITYPE.GAMEGUIDE then
    UIManager.ShowUI(UIManager.UI_Config.GamePlayGuide_Popup_UIBP, viewID, popIndex)
  else
    UIManager.ShowUI(UIManager.UI_Config.ModeSelection_Guide_UIBP, viewID, popIndex)
  end
end
function logic_mode_selection:ClickSubView(viewId, cfg)
  if not viewId or not default then
    return false
  end
  local data = default[viewId]
  if not data then
    return false
  end
  if not data.is_new then
    return false
  end
  if data.is_new == 1 then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    cfg = cfg or PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eModeSelectionMainUI) or {}
    if not cfg.mapClick then
      cfg.mapClick = {}
    end
    if not cfg.mapClick[viewId] then
      cfg.mapClick[viewId] = 1
      PlayerPrefsSystem.SaveTableToFile_N(cfg, PlayerPrefsSystem.ePlayerPrefsType.eModeSelectionMainUI)
    end
  end
  return false, cfg
end
function logic_mode_selection:UpdateTempMultiSelect(viewId, selected)
  if not viewId or not default then
    return
  end
  local data = default[viewId]
  if not data then
    return
  end
  if not data.group_view then
    if selected then
      self.tempMultiSelect = {viewId}
    end
    return
  end
  if not self.tempMultiSelect then
    self.tempMultiSelect = {}
  end
  if selected then
    local newMultiSelect = {}
    for _, viewInfo in ipairs(data.group_view) do
      if viewInfo.view_id == viewId then
        table.insert(newMultiSelect, viewInfo.view_id)
      else
        for __, selectViewID in ipairs(self.tempMultiSelect) do
          if viewInfo.view_id == selectViewID then
            table.insert(newMultiSelect, viewInfo.view_id)
            break
          end
        end
      end
    end
    self.tempMultiSelect = newMultiSelect
  else
    for i, selectViewID in ipairs(self.tempMultiSelect) do
      if viewId == selectViewID then
        table.remove(self.tempMultiSelect, i)
        return
      end
    end
  end
end
function logic_mode_selection:GetTimeLimitStr(data)
  local isOpen = true
  local previewStr = ""
  if not data or not data.open_limits then
    return true, "", 0
  end
  local viewLimitInfo = data.open_limits
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  local curSecInDay = curTime % 86400
  local curWeekDay = TimeUtil.GetWeekDayByTime(curTime)
  local recentlyOpenTime = 0
  for k, v in pairs(viewLimitInfo) do
    local startTime = v.begin_timestamp
    local endTime = v.close_timestamp
    local startSecInDay = startTime % 86400
    local endSecInDay = endTime % 86400
    if curTime >= startTime and curTime <= endTime then
      if v.notice_content ~= 0 then
        previewStr = LocUtil.LocalizeResFormat(v.notice_content)
      end
      if v.open_type == 0 and curSecInDay <= endSecInDay and curSecInDay >= startSecInDay then
        return isOpen, previewStr, 0, v
      end
      if v.open_type == 1 then
        return isOpen, previewStr, 0, v
      end
      if v.open_type == 2 then
        local startWeekDay = TimeUtil.GetWeekDayByTime(startTime)
        local endWeekDay = TimeUtil.GetWeekDayByTime(endTime)
        if curWeekDay >= startWeekDay and curWeekDay <= endWeekDay then
          return isOpen, previewStr, 0, v
        end
      end
    end
    if curTime <= endTime then
      local tmpStartTime = 0
      local tmpEndTime = 0
      if v.open_type == 0 then
        if curTime < startTime then
          tmpStartTime = startTime
        else
          tmpStartTime = math.floor(curTime / 86400) * 86400 + startSecInDay
          tmpEndTime = math.floor(curTime / 86400) * 86400 + endSecInDay
          if curTime > tmpEndTime then
            tmpStartTime = tmpStartTime + 86400
          end
        end
        if recentlyOpenTime == 0 or recentlyOpenTime >= tmpStartTime then
          recentlyOpenTime = tmpStartTime
        end
      elseif v.open_type == 1 and curTime < startTime then
        if recentlyOpenTime == 0 or startTime < recentlyOpenTime then
          recentlyOpenTime = startTime
        end
      elseif v.open_type == 2 then
        if curTime < startTime then
          tmpStartTime = startTime
        else
          local startWeekDay = TimeUtil.GetWeekDayByTime(startTime)
          local endWeekDay = TimeUtil.GetWeekDayByTime(endTime)
          local curTimeDayStartSec = math.floor(curTime / 86400) * 86400
          if curWeekDay < startWeekDay then
            tmpStartTime = curTimeDayStartSec + (startWeekDay - curWeekDay) * 86400
          elseif curWeekDay > endWeekDay then
            tmpStartTime = curTimeDayStartSec + (7 - (curWeekDay - startWeekDay)) * 86400
          elseif endWeekDay >= curWeekDay + 1 then
            tmpStartTime = curTimeDayStartSec + 86400
          else
            tmpStartTime = 0
          end
        end
        if 0 < tmpStartTime and (recentlyOpenTime == 0 or recentlyOpenTime >= tmpStartTime) then
          recentlyOpenTime = tmpStartTime
        end
      end
    end
  end
  isOpen = false
  local leftSecond = 0
  if 0 < recentlyOpenTime then
    leftSecond = recentlyOpenTime - curTime
  end
  return isOpen, "", leftSecond
end
function logic_mode_selection:OnJumpActivityUrl(actData)
  if not actData then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eModeSelectionMainUI) or {}
  cfg.actClick = cfg.actClick or {}
  cfg.actClick[actData.ID] = true
  PlayerPrefsSystem.SaveTableToFile_N(cfg, PlayerPrefsSystem.ePlayerPrefsType.eModeSelectionMainUI)
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  ActivityNewSystem.JumpUrl(actData.ImgLink)
end
function logic_mode_selection:EnterSocialIsland(callBack)
  local level_unlock_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.level_unlock_manager)
  if not level_unlock_manager:IsFeatureUnlocked(level_unlock_manager.featureDef.socialIsland) then
    ShowNotice(level_unlock_manager:GetLockTip(level_unlock_manager.featureDef.socialIsland))
    return
  end
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  local SocialIslandHandler = require("client.network.Protocol.SocialIslandHandler")
  local pvtInfo = SocialIslandHandler.pvt_socialland_info
  local myUid = DataMgr.roleData.uid
  if pvtInfo and tostring(pvtInfo.owner) == tostring(myUid) then
    if not LobbySystem.CheckLobbyMenuOpen(BP_ENUM_SOCIAL_ISLAND_PVT_SWITCH, true) then
      return
    end
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.NewModeSelection_ClickSocialIsland)
    local title = LocUtil.GetLocalizeResStr(110115)
    local tips = LocUtil.GetLocalizeResStr(9872)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(2, title, tips, function()
      SocialIslandHandler.send_socialland_enter_req(pvtInfo)
    end, function()
      local isGoingSocialIsland = SocialIslandHandler.ReqEnterSystemIsland()
      if isGoingSocialIsland and callBack then
        callBack()
      end
    end)
  else
    if not LobbySystem.CheckLobbyMenuOpen(BP_ENUM_SOCIAL_ISLAND_SWITCH, true) then
      return
    end
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.NewModeSelection_ClickSocialIsland)
    local isGoingSocialIsland = SocialIslandHandler.ReqEnterSystemIsland()
    if isGoingSocialIsland and type(callBack) == "function" then
      callBack()
    end
  end
end
function logic_mode_selection:FindAllPeakGameView()
  local AllPeakGameViewData = {}
  for k, v in pairs(default) do
    if v.menu_id == 120 then
      table.insert(AllPeakGameViewData, v)
    end
  end
  table.sort(AllPeakGameViewData, function(a, b)
    return a.id < b.id
  end)
  return AllPeakGameViewData
end
function logic_mode_selection:IsPeakGameView()
  local matchMode, viewid, viewids = self:GetCurSelectInfo()
  if viewids and next(viewids) then
    for k, v in pairs(viewids) do
      if self:IsPeakGameViewID(v) then
        return true
      end
    end
  end
  return false
end
function logic_mode_selection:FindAllArenaGameView()
  local AllArenaGameViewData = {}
  local config_arena = require("client.slua.logic.arena.config_arena")
  for k, v in pairs(default) do
    if v.menu_id == config_arena.ModeMenuId then
      table.insert(AllArenaGameViewData, v)
    end
  end
  return AllArenaGameViewData
end
function logic_mode_selection:OnNotifyViewIdConflict(err_code, fixed_match_id, fixed_view_ids, conflict_reason)
  if not GameStatus.IsInLobbyOrMainCity() then
    return
  end
  if err_code == 31042 then
    local fixed_view_id = fixed_view_ids and fixed_view_ids[1] or 0
    if fixed_view_id == 0 then
      return
    end
    local modeViewData = self:GetSubviewInfoBySubviewID(fixed_view_id)
    if not modeViewData then
      return
    end
    local tipsId = err_code
    if conflict_reason and conflict_reason.simple and conflict_reason.simple ~= 0 then
      log(bWriteLog and "[v_wllwu] logic_mode_selection:OnNotifyViewIdConflict, conflict_errorcode is " .. tostring(conflict_reason.simple))
      local strTips = LocUtil.GetLocalizeResStr(conflict_reason.simple)
      if strTips and strTips ~= "" then
        tipsId = conflict_reason.simple
      end
    end
    local modeName = LocUtil.GetLocalizeResStr(modeViewData.lobby_name)
    local viewName = LocUtil.GetLocalizeResStr(modeViewData.title)
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(1, LocUtil.GetLocalizeResStr(101001), LocUtil.LocalizeResFormat(tipsId, modeName, viewName))
  elseif err_code == 31043 then
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    if TeamUpNewSystem.IsTeamLeader() then
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.Show(1, LocUtil.GetLocalizeResStr(101001), LocUtil.GetLocalizeResStr(err_code))
    end
  elseif err_code == 31044 then
    self:RequireModeData()
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    CommonMsgBoxMgr.Show(1, LocUtil.GetLocalizeResStr(101001), LocUtil.GetLocalizeResStr(31187))
  end
end
function logic_mode_selection:OnLogin(_, __, isRelogin)
  local logic_team_up = require("client.slua.logic.teamup.logic_team_up")
  logic_team_up.RemoveAllInvite()
  if isRelogin then
    return
  end
  self:RequireModeData()
end
function logic_mode_selection:RequireModeData()
  log(bWriteLog and "[boteliu] logic_mode_selection:RequireModeData")
  log(bWriteLog and "[boteliu] logic_mode_selection:RequireModeData send_get_mode_shield_v2_req")
  local NewModeHandler = require("client.network.Protocol.NewModeHandler")
  NewModeHandler.send_get_mode_shield_v2_req()
  if self._req_ugc or not DataMgr.is_open_ugc then
    return
  end
  self:RequireUGCData()
end
function logic_mode_selection:RequireUGCData()
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  LogicUGC:GetGalleryParamConfig()
  local LogicUGCTemplate = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCTemplate)
  LogicUGCTemplate:GetTemplate()
  self._req_ugc = true
end
function logic_mode_selection:HasSelectMetroTxMission(view_id)
  self.hasSelectTxMission = view_id == 20000
  log(bWriteLog and "zwl logic_mode_selection:HasSelectMetroTxMission" .. tostring(self.hasSelectTxMission))
  local logic_mode_selection_for_umg = require("client.slua.logic.mode_selection.logic_mode_selection_for_umg")
  logic_mode_selection_for_umg.SaveTxMissionChoiceInLocal(self.hasSelectTxMission)
end
function logic_mode_selection:OnGetModeShield(menu_object, default_view_id, _, sub_mode_to_view, default_viewid, sub_mode_to_mutiviews, selection_details)
  log(bWriteLog and "[v_wllwu] logic_mode_selection:OnGetModeShield default_viewid is " .. tostring(default_viewid))
  menu = menu_object
  default = default_view_id
  local map_ids = {}
  cacheMapKeys = {}
  for k, v in pairs(default) do
    if v.base_view_object then
      for kk, vv in pairs(v.base_view_object) do
        v[kk] = vv
      end
      v.base_view_object = nil
    end
    if v.options and type(v.options.team_type_maps) == "table" then
      for _, vv in pairs(v.options.team_type_maps) do
        for _, vvv in pairs(vv) do
          if not map_ids[vvv] then
            map_ids[vvv] = true
            local MapConfig = CDataTable.GetTableData("Map", vvv)
            if MapConfig then
              cacheMapKeys[MapConfig.MapKey] = true
            end
          end
        end
      end
    end
  end
  modeIdToSimpleViewInfo = sub_mode_to_view
  defaultSelectViewID = default_viewid
  modeIdToMutiViewList = sub_mode_to_mutiviews
  modeViews2BgCfg = selection_details
  self:FixedGroupView()
  self:GetViewTypeMenuList(true)
  local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
  log(bWriteLog and "logic_mode_selection:OnGetModeShield bHaveInitMapPaks = " .. tostring(PufferMapManager.bHaveInitMapPaks))
  if not PufferMapManager.bHaveInitMapPaks and not Client.IsWindows() then
    if PufferMapManager.bReEnterGame then
      if self.delayInitMapTimer then
        self:RemoveTimer(self.delayInitMapTimer)
        self.delayInitMapTimer = nil
      end
      PufferMapManager:InitMapPaks()
      if not PufferDownloader.PufferJsonDownloadReturn then
        PufferDownloader.forceInitMapPaks = true
      end
    elseif not self.delayInitMapTimer then
      local TeamupHandler = require("client.network.Protocol.TeamupHandler")
      TeamupHandler.send_update_client_map_info({
        [77] = 3
      })
      printf("logic_mode_selection:OnGetModeShield. add timer")
      self.delayInitMapTimer = self:AddTimerOnce(2, function()
        printf("logic_mode_selection:OnGetModeShield. delay check")
        self.delayInitMapTimer = nil
        if not PufferMapManager.bHaveInitMapPaks then
          PufferMapManager:InitMapPaks()
          if not PufferDownloader.PufferJsonDownloadReturn then
            PufferDownloader.forceInitMapPaks = true
          end
        end
      end)
    end
  else
    PufferMapManager:UploadClientMapState(nil, true)
    local LogicPufferBundle = require("client.slua.logic.download.bundle.logic_puffer_bundle")
    LogicPufferBundle.InitBundle()
  end
  EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_MATCH_RELOAD)
end
function logic_mode_selection:PlayAnimOnMatchSuccess()
  local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
  if not (MatchModeMgrSystem and not MatchModeMgrSystem.IsSocialIslandMode() and MatchModeMgrSystem.nInGameModeID) or MatchModeMgrSystem.nInGameModeID == 10080 or MatchModeMgrSystem.nInGameModeID == 20011 then
    return false
  end
  if MatchModeMgrSystem.nLastInGameModeID and MatchModeMgrSystem.nLastInGameModeID >= 21001 and MatchModeMgrSystem.nLastInGameModeID <= 21004 then
    return
  end
  if not modeIdToSimpleViewInfo then
    return
  end
  local simpleViewInfo = modeIdToSimpleViewInfo[MatchModeMgrSystem.nInGameModeID]
  local actViewId = simpleViewInfo and simpleViewInfo.id
  log(bWriteLog and "[COLE]PlayAnimOnMatchSuccess " .. tostring(MatchModeMgrSystem.nInGameModeID) .. " view=" .. tostring(actViewId))
  if not actViewId then
    return false
  end
  if not self.viewId then
    log(bWriteLog and "[COLE]PlayAnimOnMatchSuccess no valid viewId")
    return false
  end
  if not DataMgr.roleData.match_success_animation or DataMgr.roleData.match_success_animation ~= 1 then
    log(bWriteLog and "[COLE]PlayAnimOnMatchSuccess no valid switch")
    return false
  end
  local logic_roleInfo_opening = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_opening)
  local equipedOpeningID = logic_roleInfo_opening:GetEquipedOpeningID()
  if equipedOpeningID ~= nil then
    log(bWriteLog and "logic_mode_selection:PlayAnimOnMatchSuccess equipedOpeningID = " .. tostring(equipedOpeningID))
    local openingCfg = CDataTable.GetTableData("PersonalOpeningCfg", equipedOpeningID)
    if openingCfg then
      local BPPath = openingCfg.BPPath
      local SoundID = openingCfg.SoundID
      if BPPath ~= "" then
        if SoundID == 0 then
          SoundID = nil
        end
        UIManager.ShowUI(UIManager.UI_Config.loading_anim_mgr, BPPath, nil, SoundID)
        return true
      else
        log(bWriteLog and "logic_mode_selection:PlayAnimOnMatchSuccess BPPath is empty! equipedOpeningID = " .. tostring(equipedOpeningID))
      end
    else
      log(bWriteLog and "logic_mode_selection:PlayAnimOnMatchSuccess not openingCfg")
    end
  end
  local current_version = Client.GetAppVersion()
  local version_util = require("client.common.version_util")
  local animInfo
  local TimeUtil = require("client.common.time_util")
  local now = TimeUtil.GetServerTimeInSec()
  local uObj_animCfg = CDataTable.GetTable("MatchAnimCfg")
  local StringUtil = require("common.string_util")
  for _, v in pairs(uObj_animCfg) do
    if version_util.HigherVersion(current_version, v.MinVersion) and version_util.LowerVersion(current_version, v.MaxVersion) then
      local nStartTime = TimeUtil.TimeStringToUnixstamp(v.StartTime)
      local nEndTime = TimeUtil.TimeStringToUnixstamp(v.EndTime)
      if now >= nStartTime and now < nEndTime then
        local tAllViewId = StringUtil.Split(v.AllViewID, ";")
        for _, vv in pairs(tAllViewId) do
          if tonumber(vv) == actViewId then
            animInfo = v
            break
          end
        end
      end
    end
    if animInfo then
      break
    end
  end
  if not animInfo then
    log(bWriteLog and "[COLE]PlayAnimOnMatchSuccess no valid animInfo")
    return false
  end
  UIManager.ShowUI(UIManager.UI_Config.loading_anim_mgr, animInfo.MatchAnimPath, animInfo.SoundEffectPath)
  return true
end
function logic_mode_selection:FixedGroupView()
  for _, v in pairs(default) do
    if v.group_view then
      for ii = #v.group_view, 1, -1 do
        local viewInfo = v.group_view[ii]
        if not default[viewInfo.view_id] then
          table.remove(v.group_view, ii)
        end
      end
    end
  end
end
function logic_mode_selection:IsSingleMode()
  local info = self:GetFilterInfo()
  if info and info.teamNum and info.teamNum == 1 then
    return true
  end
  return false
end
local _GetFirstAvailableViewId = function(sub_views, is_rank)
  if not sub_views or not next(sub_views) then
    return nil
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  for k, view_id in pairs(sub_views) do
    local viewData = logic_mode_selection:GetSubviewInfoBySubviewID(view_id)
    if viewData then
      if is_rank then
        if viewData.is_ranked == 1 and logic_mode_selection:IsModeMapAvailable(viewData) then
          return view_id
        end
      elseif viewData.is_ranked ~= 1 and logic_mode_selection:IsModeMapAvailable(viewData) then
        return view_id
      end
    end
  end
  return nil
end
function logic_mode_selection:GetFirstAvailableViewId(is_rank)
  local menu_info = self:GetMenuInfo()
  if not menu_info or not menu_info.sub_menus then
    return nil
  end
  for k, alpha in pairs(menu_info.sub_menus) do
    local view_id
    if alpha.type == 1 then
      view_id = _GetFirstAvailableViewId(alpha.sub_views, is_rank)
    elseif alpha.type == 2 then
      for _, beta in pairs(alpha.sub_menus) do
        view_id = _GetFirstAvailableViewId(beta.sub_views, is_rank)
        if view_id then
          break
        end
      end
    end
    if view_id then
      return view_id
    end
  end
  return nil
end
function logic_mode_selection:GetCacheGuideThemeViewId()
  return self.guideThemeViewId
end
function logic_mode_selection:SetCacheGuideThemeViewId(in_view_id)
  log(bWriteLog and "[GuideThemeView] SetCacheGuideThemeViewId " .. tostring(in_view_id))
  self.guideThemeViewId = in_view_id
end
function logic_mode_selection:GetSubMenuData(subMenuID)
  if menu == nil then
    return nil
  end
  for _, v in ipairs(menu.sub_menus) do
    for _, vv in ipairs(v.sub_menus) do
      if vv.id == subMenuID then
        return vv
      end
    end
  end
  return nil
end
function logic_mode_selection:GetShowExtraInfoViewIDMap()
  if self.extraInfoViewIDs then
    return self.extraInfoViewIDs
  end
  local data = {}
  if menu == nil then
    return data
  end
  for _, v in ipairs(menu.sub_menus) do
    for _, vv in ipairs(v.sub_menus) do
      if vv.name == 29597 then
        for _, vvv in ipairs(vv.sub_views) do
          data[vvv] = true
        end
      end
    end
  end
  self.extraInfoViewIDs = data
  return data
end
function logic_mode_selection:ClearExtraInfoViewIDMap()
  self.extraInfoViewIDs = nil
end
function logic_mode_selection:OnServerError()
  log(bWriteLog and "logic_mode_selection:OnServerError")
  local MatchSystem = require("client.slua.logic.match.logic_match")
  MatchSystem.OnServerError()
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicModeSelection = class(CModuleBase, nil, logic_mode_selection)
return CLogicModeSelection