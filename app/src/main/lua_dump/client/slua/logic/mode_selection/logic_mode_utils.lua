local logic_mode_utils = {}
function logic_mode_utils.IsGroupTypeView(viewID, groupType)
  if not viewID then
    return
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local viewInfo = logic_mode_selection:GetSubviewInfoBySubviewID(viewID)
  if not viewInfo then
    return
  end
  if not viewInfo.group_type or viewInfo.group_type == "" then
    return false
  end
  if groupType and viewInfo.group_type ~= groupType then
    return false
  end
  return true
end
function logic_mode_utils.IsGroupViewInfo(viewInfo)
  if not (viewInfo and viewInfo.group_type) or viewInfo.group_type == "" then
    return false
  end
  return true
end
function logic_mode_utils.IsNormalView(viewID)
  if not viewID then
    return
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local viewInfo = logic_mode_selection:GetSubviewInfoBySubviewID(viewID)
  return viewInfo and viewInfo.is_group_base
end
function logic_mode_utils.IsThemeGroupView(viewInfo)
  if not viewInfo or not viewInfo.group_type then
    return
  end
  local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
  return viewInfo.group_type == mode_selection_macro.Enum_Group_Type.Theme
end
function logic_mode_utils.IsRandomView(viewInfo)
  if not viewInfo or not viewInfo.is_random then
    return
  end
  return viewInfo.is_random == 1
end
function logic_mode_utils.IsRandomViewByViewID(viewID)
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local viewInfo = logic_mode_selection:GetSubviewInfoBySubviewID(viewID)
  return logic_mode_utils.IsRandomView(viewInfo)
end
function logic_mode_utils.IsNewModeSelectionOpen()
  if DataMgr and DataMgr.roleData and DataMgr.roleData.mode_views_api_version and DataMgr.roleData.mode_views_api_version == "v1" then
    return false
  end
  return true
end
function logic_mode_utils.GetDefaultMenuAndViewId()
  return 100, 10001
end
function logic_mode_utils.GetDefaultTabId()
  local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
  return mode_selection_macro.Enum_TabID.RankClassic
end
function logic_mode_utils.IsSupportPersprctive(viewInfo, perspectiveType, teamNum)
  local TableUtil = require("common.table_util")
  local mapID = TableUtil.GetTableValue(viewInfo, "options", "team_type", perspectiveType, teamNum)
  if mapID then
    return true
  end
  return false
end
function logic_mode_utils.GetGroupTypeViewName(viewInfo)
  if not viewInfo or not viewInfo.group_view then
    return
  end
  for _, v in ipairs(viewInfo.group_view) do
    if v.view_id == viewInfo.id then
      local title = LocUtil.GetLocalizeResStr(viewInfo.title)
      local suffixStr = LocUtil.GetLocalizeResStr(v.show_name)
      if suffixStr ~= "" then
        return LocUtil.LocalizeResFormat(32498, title, suffixStr)
      end
      return title
    end
  end
end
function logic_mode_utils.GetMapNameByViewID(viewID, isUseRandomMapName)
  if not viewID then
    log(bWriteLog and "[ZH] viewID is nil")
    return
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local viewInfo = logic_mode_selection:GetSubviewInfoBySubviewID(viewID)
  if not viewInfo then
    log(bWriteLog and "[ZH] logic_mode_utils.GetMapNameByViewID viewInfo is nil " .. tostring(viewID))
    return ""
  end
  if not isUseRandomMapName and logic_mode_utils.IsRandomView(viewInfo) then
    return LocUtil.GetLocalizeResStr(viewInfo.title or 33083)
  end
  return LocUtil.GetLocalizeResStr(viewInfo.aux_name)
end
function logic_mode_utils.GetModeNameByModeID(modeID)
  if not modeID then
    log(bWriteLog and "[ZH] modeID is nil")
    return
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local modeIdToViewIdList = logic_mode_selection:GetSimpleViewInfoDictionary() or {}
  local simpleViewInfo = modeIdToViewIdList[tonumber(modeID)] or {}
  return LocUtil.GetLocalizeResStr(simpleViewInfo.aux_name) or ""
end
function logic_mode_utils.GetViewIDByModeID(modeID)
  if not modeID then
    log(bWriteLog and "[v_wllwu] logic_mode_utils.GetViewIDByModeID is nil")
    return
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local modeIdToViewIdList = logic_mode_selection:GetSimpleViewInfoDictionary()
  if modeIdToViewIdList and modeIdToViewIdList[modeID] then
    return modeIdToViewIdList[modeID].id
  end
  return nil
end
function logic_mode_utils.GetModeIDBySimpleViewID(viewID)
  if not viewID then
    return nil
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local modeIdToViewIdList = logic_mode_selection:GetSimpleViewInfoDictionary()
  if modeIdToViewIdList and next(modeIdToViewIdList) then
    for modId, v in pairs(modeIdToViewIdList) do
      if v and v.id == viewID then
        return modId
      end
    end
  end
  return nil
end
function logic_mode_utils.IsLevelEnough(levelLimit)
  local level_unlock_util = require("client.logic.level_unlock.util.level_unlock_util")
  local bLevelUnlockSwitchOpen = level_unlock_util:IsSwitchOpen()
  log(bWriteLog and "logic_mode_utils.IsLevelEnough bLevelUnlockSwitchOpen = " .. tostring(bLevelUnlockSwitchOpen))
  if not bLevelUnlockSwitchOpen then
    return true
  end
  levelLimit = levelLimit or 0
  local level = DataMgr.roleData.level or 0
  return levelLimit <= level
end
function logic_mode_utils.CheckSubViewIsOpen(viewId)
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local viewData = logic_mode_selection:GetSubviewInfoBySubviewID(viewId)
  if not viewData then
    log(bWriteLog and "[v_wllwu] logic_mode_utils.CheckSubViewIsOpen viewData nil " .. tostring(viewId))
    return false
  end
  local isOpen = logic_mode_selection:GetTimeLimitStr(viewData)
  if not isOpen then
    log(bWriteLog and "[v_wllwu] logic_mode_utils.CheckSubViewIsOpen isOpen false " .. tostring(viewId))
    return false
  end
  if not logic_mode_utils.IsLevelEnough(viewData.level_limit) then
    log(bWriteLog and "[v_wllwu] logic_mode_utils.CheckSubViewIsOpen level_limit false " .. tostring(viewId))
    return false
  end
  return true
end
function logic_mode_utils.IsModeLevelEnough(viewData)
  if not viewData then
    return
  end
  local levelLimit = viewData.level_limit or 0
  if levelLimit > DataMgr.roleData.level then
    return false
  end
  local preLevelLimit = viewData.pre_level_limit or 0
  local selfPreLevel = DataMgr.roleData.pve_level or 0
  if preLevelLimit > selfPreLevel then
    return false
  end
  return true
end
function logic_mode_utils.GetMultiImage(isBig, isClassic, viewList)
  local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local bgCfg = logic_mode_selection:GetBgCfgByViews(viewList)
  if bgCfg then
    return isBig and bgCfg.big_bg or bgCfg.small_bg
  else
    local paths = isBig and mode_selection_macro.C_Multi_BigBg_Path or mode_selection_macro.C_Multi_SmallBg_Path
    return isClassic and paths.Classic or paths.Arena
  end
end
function logic_mode_utils.GetMtchIdByViewData(viewData, perspective, teamNum)
  if not viewData then
    return
  end
  local matchID
  if perspective ~= nil and teamNum ~= nil then
    local TableUtil = require("common.table_util")
    matchID = TableUtil.GetTableValue(viewData, "options", "team_type", perspective, teamNum)
  end
  if not matchID then
    local defaultPerspective = viewData.options.default_person or 10053
    local defaultTeamNum = viewData.options.default_team_size or 1
    local TableUtil = require("common.table_util")
    matchID = TableUtil.GetTableValue(viewData, "options", "team_type", defaultPerspective, defaultTeamNum)
  end
  return matchID
end
local _GetLocalSelectViewIDs = function(groupViewId, groupView)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eModeSelectionMainUI)
  if not (cfg and cfg.multiSelect) or not cfg.multiSelect[groupViewId] then
    return
  end
  local multiSelect = cfg.multiSelect[groupViewId]
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local validMultiSelect = {}
  for i, viewID in ipairs(multiSelect) do
    if logic_mode_selection:GetSubviewInfoBySubviewID(viewID) then
      for _, viewInfo in ipairs(groupView) do
        if viewInfo.view_id == viewID then
          table.insert(validMultiSelect, viewID)
          break
        end
      end
    end
  end
  return validMultiSelect
end
local _GetDefaultViewList = function(groupView, selectNum)
  if not groupView or #groupView <= 0 then
    return
  end
  selectNum = selectNum or #groupView
  local multiSelect = {}
  for i = 1, selectNum do
    if groupView[i] then
      table.insert(multiSelect, groupView[i].view_id)
    end
  end
  return multiSelect
end
function logic_mode_utils.UpdateLocalSelectViewIDs(groupView, selectViewIDs)
  if not groupView then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eModeSelectionMainUI) or {}
  if not cfg.multiSelect then
    cfg.multiSelect = {}
  end
  for _, viewInfo in ipairs(groupView) do
    cfg.multiSelect[viewInfo.view_id] = selectViewIDs
  end
  PlayerPrefsSystem.SaveTableToFile_N(cfg, PlayerPrefsSystem.ePlayerPrefsType.eModeSelectionMainUI)
end
function logic_mode_utils.GetSelectRandomSubViewList(groupViewId, selectNum)
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local groupViewInfo = logic_mode_selection:GetSubviewInfoBySubviewID(groupViewId)
  if not groupViewInfo or not groupViewInfo.group_view then
    log_error(bWriteLog and "[v_wllwu] logic_mode_utils.GetCurSelectRandomSubViewList error, groupViewId is " .. tostring(groupViewId))
    return
  end
  local _, curViewID, viewIDs = logic_mode_selection:GetCurSelectInfo()
  local groupViewList = groupViewInfo.group_view
  for _, viewInfo in ipairs(groupViewList) do
    if viewInfo.view_id == curViewID then
      return viewIDs
    end
  end
  return logic_mode_utils.GetLocalSaveOrDefaultSelectData(groupViewId, groupViewList, selectNum)
end
function logic_mode_utils.GetLocalSaveOrDefaultSelectData(groupViewId, groupViewList, selectNum)
  local saveViewData = _GetLocalSelectViewIDs(groupViewId, groupViewList)
  if saveViewData and 0 < #saveViewData then
    return saveViewData
  end
  local selectViewList = _GetDefaultViewList(groupViewList, selectNum)
  if selectViewList ~= nil then
    logic_mode_utils.UpdateLocalSelectViewIDs(groupViewList, selectViewList)
  end
  return selectViewList
end
function logic_mode_utils.IsShowSameLanguageMatch()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsBLUEHOLE() then
    return false
  end
  return true
end
function logic_mode_utils.IsCanShowThemeModeChangeGuide(viewData)
  if not logic_mode_utils.IsThemeGroupView(viewData) then
    log(bWriteLog and "[v_wllwu] logic_mode_utils.IsCanShowThemeModeChangeGuide return because not is theme")
    return
  end
  local logic_mode_uilogic = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_uilogic)
  local isForceShow = logic_mode_uilogic:IsForceShowThemeEnterAnim()
  if isForceShow then
    log(bWriteLog and "[v_wllwu] logic_mode_utils.IsCanShowThemeModeChangeGuide return true after use gm command")
    return true
  end
  if not viewData.is_new or viewData.is_new ~= 1 then
    log(bWriteLog and "[v_wllwu] logic_mode_utils.IsCanShowThemeModeChangeGuide return because not is new" .. tostring(viewData.id))
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eNewThemeModeStartNotify)
  local TableUtil = require("common.table_util")
  local isShowed = TableUtil.GetTableValue(cfg, "guideViewIDList", viewData.id)
  if isShowed then
    log(bWriteLog and "[v_wllwu] logic_mode_utils.IsCanShowThemeModeChangeGuide return because isShowed, viewId = " .. tostring(viewData.id))
    return
  end
  log(bWriteLog and "[v_wllwu] logic_mode_utils.IsCanShowThemeModeChangeGuide return true, viewId = " .. tostring(viewData.id))
  return true
end
function logic_mode_utils.UpdateThemeModeChangeGuideCache(viewId)
  if not viewId then
    log(bWriteLog and "[v_wllwu] logic_mode_utils.UpdateThemeModeChangeGuideCache return because viewId is nil")
    return
  end
  log(bWriteLog and "[v_wllwu] logic_mode_utils.UpdateThemeModeChangeGuideCache, viewId = " .. tostring(viewId))
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eNewThemeModeStartNotify) or {}
  cfg.guideViewIDList = cfg.guideViewIDList or {}
  cfg.guideViewIDList[viewId] = 1
  PlayerPrefsSystem.SaveTableToFile_N(cfg, PlayerPrefsSystem.ePlayerPrefsType.eNewThemeModeStartNotify)
  log_tree(bWriteLog and "[v_wllwu] logic_mode_utils.UpdateThemeModeChangeGuideCache, cfg = ", cfg)
end
function logic_mode_utils.IsViewOpen(openLimit, curTime)
  local startTime = openLimit.begin_timestamp
  local endTime = openLimit.close_timestamp
  if curTime < startTime or curTime >= endTime then
    return
  end
  local openType = openLimit.open_type
  local TimeUtil = require("client.common.time_util")
  if openType == 0 then
    local startSecInDay = startTime % 86400
    local endSecInDay = endTime % 86400
    local curSecInDay = curTime % 86400
    if endSecInDay >= curSecInDay and startSecInDay <= curSecInDay then
      return true
    end
  elseif openType == 1 then
    return true
  elseif openType == 2 then
    local startWeekDay = TimeUtil.GetWeekDayByTime(startTime)
    local endWeekDay = TimeUtil.GetWeekDayByTime(endTime)
    local curWeekDay = TimeUtil.GetWeekDayByTime(curTime)
    if startWeekDay <= curWeekDay and endWeekDay >= curWeekDay then
      return true
    end
  end
  return false
end
local _GetRecentlyOpenTime = function(openLimit, curTime)
  local startTime = openLimit.begin_timestamp
  local endTime = openLimit.close_timestamp
  if curTime >= endTime then
    return
  end
  local recentlyOpenTime = 0
  local openType = openLimit.open_type
  if openType == 0 then
    if curTime < startTime then
      recentlyOpenTime = startTime
    else
      local startSecInDay = startTime % 86400
      local endSecInDay = endTime % 86400
      recentlyOpenTime = math.floor(curTime / 86400) * 86400 + startSecInDay
      local tmpEndTime = math.floor(curTime / 86400) * 86400 + endSecInDay
      if curTime > tmpEndTime then
        recentlyOpenTime = recentlyOpenTime + 86400
      end
    end
  elseif openType == 1 and curTime < startTime then
    recentlyOpenTime = startTime
  elseif openType == 2 then
    if curTime < startTime then
      recentlyOpenTime = startTime
    else
      local TimeUtil = require("client.common.time_util")
      local startWeekDay = TimeUtil.GetWeekDayByTime(startTime)
      local endWeekDay = TimeUtil.GetWeekDayByTime(endTime)
      local curWeekDay = TimeUtil.GetWeekDayByTime(curTime)
      local curTimeDayStartSec = math.floor(curTime / 86400) * 86400
      if startWeekDay > curWeekDay then
        recentlyOpenTime = curTimeDayStartSec + (startWeekDay - curWeekDay) * 86400
      elseif endWeekDay < curWeekDay then
        recentlyOpenTime = curTimeDayStartSec + (7 - (curWeekDay - startWeekDay)) * 86400
      elseif endWeekDay >= curWeekDay + 1 then
        recentlyOpenTime = curTimeDayStartSec + 86400
      else
        recentlyOpenTime = 0
      end
    end
  end
  return recentlyOpenTime
end
function logic_mode_utils.IsViewPreOpen(openLimit, curTime)
  local recentlyOpenTime = _GetRecentlyOpenTime(openLimit, curTime) or 0
  local leftSeconds = recentlyOpenTime - curTime
  if leftSeconds <= 0 then
    return
  end
  local noticeHours = openLimit.notice_hours or 0
  log(bWriteLog and "[v_wllwu] logic_mode_utils.IsViewPreOpen, leftSeconds = " .. tostring(leftSeconds) .. " notice_hours= " .. tostring(noticeHours))
  if 0 < noticeHours and leftSeconds <= noticeHours * 3600 then
    return true
  end
  return false
end
function logic_mode_utils.IsViewDisplay(viewData)
  if not viewData then
    return false
  end
  if not viewData.open_limits then
    return true
  end
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  for _, v in pairs(viewData.open_limits) do
    if logic_mode_utils.IsViewOpen(v, curTime) then
      return true
    elseif logic_mode_utils.IsViewPreOpen(v, curTime) then
      return true
    end
  end
  return false
end
return logic_mode_utils