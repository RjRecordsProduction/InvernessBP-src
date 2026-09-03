local logic_team_platform_new = {}
local curSelectFilterOptionInfo, curSelectPublishOptionInfo, savedRecruitCondition, viewIdToSendTabId
local recruitCD = 0
local defaultRecruitCD = 30
local saveCurFilterData, isNeedRefreshFilter, hasShowedBubbleTips, isFilterUnOpenView, isUseNewRecruit, cacheSegmentData, curSelectModeList, isNeedUpdateCurSelectModeList
local C_WOWViewId = 20002
local _GetMatchId = function(viewInfo, perspective, playerNum)
  if not viewInfo then
    return
  end
  local TableUtil = require("common.table_util")
  return TableUtil.GetTableValue(viewInfo, "options", "team_type", perspective, playerNum)
end
local _ResetPublishModeOption = function(option)
  if option.nPlayerNum ~= 1 then
    return option
  end
  option.nPlayerNum = 4
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local viewInfo = logic_mode_selection:GetSubviewInfoBySubviewID(option.nViewID)
  local newMatchID = _GetMatchId(viewInfo, option.nPerspective, option.nPlayerNum)
  if newMatchID then
    option.nMatchID = newMatchID
  else
    log(bWriteLog and "[v_wllwu] _ResetPublishModeOption error")
  end
  return option
end
local C_PlayerNum = {
  4,
  2,
  8
}
local _ResetFilterModeOption = function(option, viewId, matchId)
  if option.nPlayerNum ~= 1 then
    return option, matchId
  end
  log(bWriteLog and "[v_wllwu] _ResetFilterModeOption viewId = " .. tostring(viewId) .. " matchId = " .. tostring(matchId))
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local viewInfo = logic_mode_selection:GetSubviewInfoBySubviewID(viewId)
  if not viewInfo then
    log(bWriteLog and "[v_wllwu] _ResetFilterModeOptio error: not viewInfo !!")
    return option, matchId
  end
  for _, num in ipairs(C_PlayerNum) do
    local newMatchID = _GetMatchId(viewInfo, option.nPerspective, num)
    if newMatchID then
      option.nPlayerNum = num
      matchId = newMatchID
      log(bWriteLog and "[v_wllwu] _ResetFilterModeOptio change playerNum = " .. tostring(num) .. " newMatchID = " .. tostring(newMatchID))
      return option, matchId
    end
  end
  option.nPlayerNum = 4
  log_error(bWriteLog and "[v_wllwu] _ResetFilterModeOption error viewId =" .. tostring(viewId))
  return option, matchId
end
local _FindDefaultViewID = function(tabID, nPlayerNum, nPerspective)
  log_error(bWriteLog and "[v_wllwu] _FindDefaultViewID tabID= " .. tostring(tabID) .. " nPlayerNum= " .. tostring(nPlayerNum) .. " nPerspective= " .. tostring(nPerspective))
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
  local logic_mode_utils = require("client.slua.logic.mode_selection.logic_mode_utils")
  tabID = tabID or logic_mode_utils.GetDefaultTabId()
  nPlayerNum = nPlayerNum or 4
  nPerspective = nPerspective or ENUM_PerspectiveType.TPP
  local menuViewTypeList = logic_mode_selection:GetViewTypeMenuList()
  for i, v in pairs(menuViewTypeList) do
    if v.id == tabID then
      for ii, vv in pairs(v.sub_views) do
        local viewInfo = logic_mode_selection:GetSubviewInfoBySubviewID(vv)
        local matchID = _GetMatchId(viewInfo, nPerspective, nPlayerNum)
        if matchID ~= nil then
          log(bWriteLog and "[v_wllwu] _FindDefaultViewID matchID= " .. tostring(matchID) .. "viewID= " .. tostring(vv))
          return vv, matchID
        end
      end
      break
    end
  end
  log_error(bWriteLog and "[v_wllwu] _FindDefaultViewID error end")
  return nil, nil
end
local _GetInitPublishModeOption = function(option)
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local modeInfo = logic_mode_selection:GetFilterInfo()
  local matchId, viewId, viewIds = logic_mode_selection:GetCurSelectInfo()
  log(bWriteLog and "[v_wllwu] _GetInitPublishModeOption matchId = " .. tostring(matchId) .. "viewId = " .. tostring(viewId))
  local tabList = logic_mode_selection:GetMenuListByViewID(viewId)
  local tabId = tabList[1]
  log(bWriteLog and "[v_wllwu] _GetInitPublishModeOption tabId = " .. tostring(tabId))
  if not tabId then
    local logic_mode_utils = require("client.slua.logic.mode_selection.logic_mode_utils")
    tabId = logic_mode_utils.GetDefaultTabId()
    log(bWriteLog and "[v_wllwu] _GetInitPublishModeOption GetDefaultTabId = " .. tostring(tabId))
  end
  option.nPlayerNum = modeInfo.teamNum
  option.nPerspective = modeInfo.perspective
  option.nTabID = tabId
  option.nMatchID = matchId
  option.nViewID = viewId
  option = _ResetPublishModeOption(option)
  option.bMemberCanInvite = true
end
local _UpdateModeInfoList = function(option)
  local modeInfo = option.modeInfo
  local nPerspective = option.nPerspective
  local nPlayerNum = option.nPlayerNum
  if not (modeInfo and not (#modeInfo <= 0) and nPerspective) or not nPlayerNum then
    return
  end
  log_tree(bWriteLog and "[v_wllwu] _UpdateModeInfoList start ", modeInfo)
  log(bWriteLog and "[v_wllwu] logic_team_platform_new:_UpdateModeInfoList nPerspective=" .. tostring(nPerspective) .. " nPlayerNum=" .. tostring(nPlayerNum))
  local newModeList = {}
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local logic_mode_utils = require("client.slua.logic.mode_selection.logic_mode_utils")
  local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
  for _, v in ipairs(modeInfo) do
    local viewID = v.nViewID
    if logic_mode_utils.IsGroupTypeView(viewID, mode_selection_macro.Enum_Group_Type.Theme) then
      if logic_mode_utils.IsNormalView(viewID) and logic_mode_selection:CheckSubViewIsOpen(viewID, true) then
        table.insert(newModeList, v)
        local newViewData = logic_mode_selection:GetValidThemeData(viewID)
        if newViewData then
          local themeMatchID = _GetMatchId(newViewData, nPerspective, nPlayerNum)
          if themeMatchID then
            local themeInfo = {
              nMatchID = themeMatchID,
              nViewID = newViewData.id
            }
            table.insert(newModeList, themeInfo)
          end
        end
      end
    elseif logic_mode_selection:CheckSubViewIsOpen(viewID, true) then
      table.insert(newModeList, v)
    end
  end
  log_tree(bWriteLog and "[v_wllwu] _UpdateModeInfoList end ", newModeList)
  if #newModeList <= 0 then
    local defaultViewId, defaultMatchId = _FindDefaultViewID(option.nTabID, nPlayerNum, nPerspective)
    log(bWriteLog and string.format("[v_wllwu] _UpdateModeInfoList resetSelectData, defaultViewId = %s, defaultMatchId = %s, nTabID = %s", tostring(defaultViewId), tostring(defaultMatchId), tostring(option.nTabID)))
    if defaultViewId and defaultMatchId then
      table.insert(newModeList, {nMatchID = defaultMatchId, nViewID = defaultViewId})
    end
  end
  return newModeList
end
local _GetMapName = function(titleId, subTitleId)
  local strTitle = ""
  if titleId ~= nil and titleId ~= 0 then
    strTitle = LocUtil.GetLocalizeResStr(titleId)
  end
  if strTitle == "" then
    return LocUtil.GetLocalizeResStr(subTitleId)
  end
  return strTitle
end
local _GetMenuInfo = function(menuInfo)
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  if not menuInfo or logic_mode_selection:IsXMissionMode(menuInfo.id) then
    return
  end
  local isOpen = logic_mode_selection:CheckSubViewIsOpen(menuInfo.id, true)
  if not isOpen then
    return
  end
  local info = {
    nViewID = menuInfo.id,
    nTabSort = menuInfo.sort_score,
    name = _GetMapName(menuInfo.title, menuInfo.subtitle)
  }
  return info
end
local _IsShowAllSubviews = function(menuInfo)
  local logic_mode_utils = require("client.slua.logic.mode_selection.logic_mode_utils")
  if not logic_mode_utils.IsGroupViewInfo(menuInfo) then
    return
  end
  if logic_mode_utils.IsThemeGroupView(menuInfo) then
    return
  end
  if logic_mode_utils.IsRandomView(menuInfo) then
    return
  end
  return true
end
local _InitData = function()
  curSelectFilterOptionInfo = nil
  curSelectPublishOptionInfo = nil
  savedRecruitCondition = nil
  viewIdToSendTabId = nil
  saveCurFilterData = nil
  isNeedRefreshFilter = nil
  hasShowedBubbleTips = nil
  isFilterUnOpenView = nil
  cacheSegmentData = nil
  curSelectModeList = nil
end
function logic_team_platform_new:OnInitialize()
  logic_team_platform_new.__super.OnInitialize(self)
  _InitData()
end
function logic_team_platform_new:OnLogOut()
  log(bWriteLog and "[v_wllwu] logic_team_platform_new:OnLogOut")
  _InitData()
end
function logic_team_platform_new:SetCanNeedRefreshFilter(isNeedRefresh)
  log(bWriteLog and "[v_wllwu] logic_team_platform_new:SetCanNeedRefreshFilter, isNeedRefresh = " .. tostring(isNeedRefresh))
  isNeedRefreshFilter = isNeedRefresh
end
function logic_team_platform_new:SetFilterUnOpenView(bFilter)
  isFilterUnOpenView = bFilter
end
function logic_team_platform_new:GetZoneID()
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  local zoneID = ZoneSystem.GetChooseZone()
  if not zoneID or zoneID <= 0 then
    zoneID = ZoneSystem.GetFirstZone()
    log(bWriteLog and "[v_wllwu] logic_team_platform_new:GetZoneID GetDefaultID is " .. tostring(zoneID))
  end
  return zoneID
end
function logic_team_platform_new:GetInitOption(filterType)
  local option = {nPloy = 1, nMinWorth = -1}
  local saveData = self:GetSendRecruitCondition() or {}
  local TeamPlatform_Macro = require("client.slua.logic.teamup.teamplatform_macro")
  if filterType == TeamPlatform_Macro.Enum_FilterType.Publish then
    _GetInitPublishModeOption(option)
    option.send_to_corps_channel = saveData.send_to_corps_channel
    option.send_to_room_channel = saveData.send_to_room_channel
    option.nMinSegment = saveData.nMinSegment or 0
  else
    local TeamPlatformSystem = require("client.slua.logic.teamup.logic_team_platform")
    if TeamPlatformSystem.nPlatformType == TeamPlatform_Macro.Enum_PlatformType.WoW then
      self:GetInitFilterWOWConditionInfo(option)
    else
      self:GetInitFilterConditionInfo(option)
    end
    option.nMinSegment = 0
  end
  option.nZoneID = self:GetZoneID()
  option.nKD = saveData.nKD or 0
  option.bOpenSameLanguage = saveData.bOpenSameLanguage or false
  option.nSelectMicType = saveData.nSelectMicType or ENUM_RECRUIT_OPENMIC.ARBITRARILY
  option.nSelectCityType = saveData.nSelectCityType or ENUM_RECRUIT_OPENMIC.ARBITRARILY
  option.hunted_rating = saveData.hunted_rating or 0
  if option.nSelectMicType == ENUM_RECRUIT_OPENMIC.HAVETO then
    log(bWriteLog and "[v_wllwu] logic_team_platform_new:GetInitOption" .. tostring(option.nSelectMicType))
    local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
    if not logic_chat_voice:CheckChatPrivacyAcceptStatus() then
      log(bWriteLog and "[v_wllwu] logic_team_platform_new GetInitOption reset SelectMicType because of Privacy ")
      option.nSelectMicType = ENUM_RECRUIT_OPENMIC.ARBITRARILY
    end
  end
  return option
end
function logic_team_platform_new:GetDefaultSelectSegment(option, nID)
  nID = nID or 0
  local segmentList = self:GetSegmentData(option)
  if segmentList and 0 < #segmentList then
    for _, v in ipairs(segmentList) do
      if not nID or v.nID == nID then
        return nID
      end
    end
    return segmentList[1].nID
  end
  return nil
end
function logic_team_platform_new:GetInitFilterConditionInfo(option)
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local curFilterInfo = logic_mode_selection:GetFilterInfo()
  local matchId, viewId, viewIds = logic_mode_selection:GetCurSelectInfo()
  log(bWriteLog and "[v_wllwu] GetInitFilterInfo matchId = " .. tostring(matchId) .. "viewId = " .. tostring(viewId))
  local tabId
  local tabList = logic_mode_selection:GetMenuListByViewID(viewId)
  if tabList and 0 < #tabList then
    tabId = tabList[1]
  end
  local tabInfo = logic_mode_selection:GetTabInfoByTabID(tabId)
  if not tabInfo then
    log_error(bWriteLog and "[v_wllwu] logic_team_platform_new:GetInitFilterInfo not find tabInfo111, tabId = " .. tostring(tabId) .. " viewId = " .. tostring(viewId))
    local viewTabList = logic_mode_selection:GetViewTypeMenuList()
    if viewTabList and 0 < #viewTabList then
      tabId = viewTabList[1].id
      tabInfo = viewTabList[1]
      log_tree(bWriteLog and "[v_wllwu] viewTabList", viewTabList)
    end
    log_error(bWriteLog and "[v_wllwu] logic_team_platform_new:GetInitFilterInfo not find tabInfo222, tabId = " .. tostring(tabId))
  end
  if not tabInfo then
    log_error(bWriteLog and "[v_wllwu] logic_team_platform_new:GetInitFilterInfo not find tabInfo ")
    return
  end
  option.nPlayerNum = curFilterInfo.teamNum
  option.nPerspective = curFilterInfo.perspective
  option.nTabID = tabId
  option, matchId = _ResetFilterModeOption(option, viewId, matchId)
  if not tabList or not next(tabList) then
    log(bWriteLog and "logic_team_platform_new:GetInitFilterInfo not tablist")
    option.nPlayerNum = 4
  end
  log(bWriteLog and "[v_wllwu] GetInitFilterInfo nPlayerNum = " .. tostring(option.nPlayerNum) .. "nPerspective = " .. tostring(option.nPerspective))
  local filterModeList = {}
  for _, id in ipairs(tabInfo.sub_views) do
    if logic_mode_selection:CheckSubViewIsOpen(id, true) and not logic_mode_selection:IsXMissionMode(id) then
      local viewInfo = logic_mode_selection:GetSubviewInfoBySubviewID(id)
      if viewInfo.group_view then
        self:AddGroupView(filterModeList, viewInfo, option, true)
      else
        local singleMatchId = self:GetFilerMatchId(id, option.nPerspective, option.nPlayerNum)
        if singleMatchId then
          table.insert(filterModeList, {nMatchID = singleMatchId, nViewID = id})
        end
      end
    end
  end
  log_tree(bWriteLog and "[v_wllwu]GetInitFilterInfo  modeList = ", filterModeList)
  option.modeInfo = filterModeList
  return option
end
function logic_team_platform_new:GetInitFilterWOWConditionInfo(option)
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local curFilterInfo = logic_mode_selection:GetFilterInfo()
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  local LogicUGCMulti = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMulti)
  local MatchInfo = LogicUGCMatch:GetMatchInfo()
  local ModTeamSize
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if MatchInfo then
    ModTeamSize = TeamUpNewSystem.GetDefaultMaxTeamNum()
    if MatchInfo.setting and MatchInfo.setting.team_size then
      ModTeamSize = MatchInfo.setting.team_size
      if ModTeamSize == -1 then
        ModTeamSize = MatchInfo.setting.max_num or TeamUpNewSystem.GetDefaultMaxTeamNum()
        if 8 < ModTeamSize then
          ModTeamSize = 8
        end
      end
    end
  elseif LogicUGCMulti.bIsBundleMatch then
    ModTeamSize = LogicUGCMulti:GetMaxTeamSize()
  end
  log_tree(bWriteLog and "[v_chenxxue] logic_team_platform_new:GetInitFilterInfo, curFilterInfo = ", curFilterInfo)
  log(bWriteLog and "[v_chenxxue] logic_team_platform_new:GetInitFilterWOWConditionInfo ModTeamSize = " .. tostring(ModTeamSize))
  local tabId = 900
  option.nPlayerNum = ModTeamSize or TeamUpNewSystem.GetDefaultMaxTeamNum()
  option.nPerspective = curFilterInfo.perspective
  option.nTabID = tabId
  log(bWriteLog and "[v_chenxxue] GetInitFilterInfo nPlayerNum = " .. tostring(option.nPlayerNum) .. "nPerspective = " .. tostring(option.nPerspective))
  local LogicUgcFilterTag = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUgcFilterTag)
  local FilterTags, FilterSublabel = LogicUgcFilterTag:GetSearchTagID()
  if FilterTags and next(FilterTags) then
    option.tag = FilterTags
    option.feature_tag_list = FilterSublabel
  else
    option.tag = {}
    option.feature_tag_list = {}
  end
  local filterModeList = {}
  local viewInfo = logic_mode_selection:GetSubviewInfoBySubviewID(C_WOWViewId)
  if not viewInfo then
    return option
  end
  for id, _ in pairs(viewInfo.options.team_type_maps) do
    if id ~= 1010 then
      table.insert(filterModeList, {
        nMatchID = id,
        nViewID = viewInfo.id
      })
    end
  end
  table.sort(filterModeList, function(a, b)
    return a.nMatchID < b.nMatchID
  end)
  log_tree("[v_chenxxue]GetInitFilterInfo  modeList = ", filterModeList)
  option.modeInfo = filterModeList
  return option
end
local _AddModeList = function(modeList, viewId, matchId)
  if not matchId then
    return
  end
  table.insert(modeList, {nMatchID = matchId, nViewID = viewId})
end
function logic_team_platform_new:AddGroupView(modeList, viewInfo, option, isContainOrigin)
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  if not (modeList and viewInfo and viewInfo.group_view) or not option then
    log_error(bWriteLog and "[v_wllwu] logic_team_platform_new:AddGroupView return")
    return
  end
  local logic_mode_utils = require("client.slua.logic.mode_selection.logic_mode_utils")
  if logic_mode_utils.IsThemeGroupView(viewInfo) then
    if isContainOrigin then
      local baseMatchId = _GetMatchId(viewInfo, option.nPerspective, option.nPlayerNum)
      _AddModeList(modeList, viewInfo.id, baseMatchId)
    end
    local newViewData = logic_mode_selection:GetValidThemeData(viewInfo.id)
    if newViewData then
      local newMatchID = _GetMatchId(newViewData, option.nPerspective, option.nPlayerNum)
      _AddModeList(modeList, newViewData.id, newMatchID)
    end
  else
    for _, v in ipairs(viewInfo.group_view) do
      if (v.view_id ~= viewInfo.id or isContainOrigin) and logic_mode_selection:CheckSubViewIsOpen(v.view_id, true) then
        local groupMatchId = self:GetFilerMatchId(v.view_id, option.nPerspective, option.nPlayerNum)
        _AddModeList(modeList, v.view_id, groupMatchId)
      end
    end
  end
end
function logic_team_platform_new:GetFilerMatchId(viewId, nPerspective, nPlayerNum)
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local viewInfo = logic_mode_selection:GetSubviewInfoBySubviewID(viewId)
  return _GetMatchId(viewInfo, nPerspective, nPlayerNum)
end
function logic_team_platform_new:GetFilterOption(isReset)
  log(bWriteLog and "[v_wllwu] logic_team_platform_new newMode GetFilterOption")
  local TeamPlatform_Macro = require("client.slua.logic.teamup.teamplatform_macro")
  if not curSelectFilterOptionInfo then
    curSelectFilterOptionInfo = self:GetInitOption(TeamPlatform_Macro.Enum_FilterType.Filter)
    log_tree(bWriteLog and "[v_wllwu] logic_team_platform_new curSelectFilterOptionInfo is ", curSelectFilterOptionInfo)
    self:UpdateSaveFilterData()
    self:SetCanNeedRefreshFilter(false)
  else
    curSelectFilterOptionInfo.nZoneID = self:GetZoneID()
    local isRefresh = false
    if isReset then
      curSelectFilterOptionInfo = self:GetInitOption(TeamPlatform_Macro.Enum_FilterType.Filter)
      curSelectFilterOptionInfo.nSelectMicType = ENUM_RECRUIT_OPENMIC.ARBITRARILY
      curSelectFilterOptionInfo.nSelectCityType = ENUM_RECRUIT_OPENMIC.ARBITRARILY
      curSelectFilterOptionInfo.bOpenSameLanguage = false
      isRefresh = true
      log(bWriteLog and "[v_wllwu] logic_team_platform_new:GetFilterOption refresh 1")
    elseif self:IsNeedResetFilterCondition() then
      local micType = curSelectFilterOptionInfo.nSelectMicType
      local samLang = curSelectFilterOptionInfo.bOpenSameLanguage
      curSelectFilterOptionInfo = self:GetInitOption(TeamPlatform_Macro.Enum_FilterType.Filter)
      curSelectFilterOptionInfo.nSelectMicType = micType
      local city = curSelectFilterOptionInfo.nSelectCityType
      curSelectFilterOptionInfo.bOpenSameLanguage = samLang
      curSelectFilterOptionInfo.nSelectCityType = city
      isRefresh = true
      self:UpdateSaveFilterData()
      log(bWriteLog and "[v_wllwu] logic_team_platform_new:GetFilterOption refresh 2")
    elseif isFilterUnOpenView then
      self:UpdateCurSelectFilterInfo()
      isRefresh = true
      log(bWriteLog and "[v_wllwu] logic_team_platform_new:GetFilterOption refresh 3")
    end
    self:SetCanNeedRefreshFilter(false)
    isFilterUnOpenView = nil
    if isRefresh then
      local TeamPlatformSystem = require("client.slua.logic.teamup.logic_team_platform")
      TeamPlatformSystem.ClearLastSearchTeamList()
      EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAM_PLATFORM_FILTER_CONDITOIN_CHANGED)
    end
  end
  self:ResetKdWithSegmentValue(curSelectFilterOptionInfo)
  return curSelectFilterOptionInfo
end
function logic_team_platform_new:ResetKdWithSegmentValue(option)
  local TeamPlatformSystem = require("client.slua.logic.teamup.logic_team_platform")
  if not TeamPlatformSystem.needRefreshData then
    return
  end
  log(bWriteLog and "[v_wllwu] logic_team_platform_new:ResetKdWithSegmentValue enter")
  if not option then
    log(bWriteLog and "[v_wllwu] logic_team_platform_new:ResetKdWithSegmentValue error")
    return
  end
  local curMinSegment = option.nMinSegment or 0
  option.nMinSegment = self:GetDefaultSelectSegment(option, curMinSegment) or 0
  log(bWriteLog and "[v_wllwu] logic_team_platform_new:GetInitOption reset  option.nMinSegment: " .. tostring(option.nMinSegment) .. " curMinSegment = " .. tostring(curMinSegment))
  if option.nKD and TeamPlatformSystem.self_kd <= option.nKD - 1 then
    log(bWriteLog and "[v_wllwu] logic_team_platform_new:GetInitOption reset kd: " .. tostring(TeamPlatformSystem.self_kd) .. " option.nKD = " .. tostring(option.nKD))
    option.nKD = 0
  end
  TeamPlatformSystem.needRefreshData = nil
end
function logic_team_platform_new:UpdateSaveFilterData()
  if not saveCurFilterData then
    saveCurFilterData = {}
  end
  local nTabID, nPlayerNum, nPerspective, viewId = self:GetCurSelectInfo()
  if not (nTabID and nPlayerNum) or not nPerspective then
    log(bWriteLog and "[v_wllwu] logic_team_platform_new:UpdateSaveFilterData error")
    return
  end
  saveCurFilterData.  saveCurFilterData.  saveCurFilterData.  log_tree(bWriteLog and "[v_wllwu] logic_team_platform_new:UpdateSaveFilterData ", saveCurFilterData)
end
function logic_team_platform_new:IsNeedResetFilterCondition()
  if not isNeedRefreshFilter then
    log(bWriteLog and "[v_wllwu] logic_team_platform_new:IsNeedResetFilterCondition dont isNeedRefreshFilter 1")
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.GetTeamNum() > 1 then
    log(bWriteLog and "[v_wllwu] logic_team_platform_new:IsNeedResetFilterCondition in team")
    return
  end
  if not saveCurFilterData then
    log(bWriteLog and "[v_wllwu] logic_team_platform_new:IsNeedResetFilterCondition no saveCurFilterData 2")
    return
  end
  local nTabID, nPlayerNum, nPerspective, viewId = self:GetCurSelectInfo()
  if not (nTabID and nPlayerNum) or not nPerspective then
    log(bWriteLog and "[v_wllwu] logic_team_platform_new:IsNeedResetFilterCondition 3")
    return
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  if not logic_mode_selection:CheckSubViewIsOpen(viewId) then
    log(bWriteLog and "[v_wllwu] logic_team_platform_new:IsNeedResetFilterCondition 4, viewId = " .. tostring(viewId))
    return
  end
  local saveTabID = saveCurFilterData.nTabID or 0
  local savePlayerNum = saveCurFilterData.nPlayerNum or 0
  local savePerspective = saveCurFilterData.nPerspective or 0
  log(bWriteLog and string.format("[v_wllwu] logic_team_platform_new:IsNeedResetFilterCondition YES Before nTabID=%s,num=%s,perspective=%s,viewid=%s, ", saveTabID, savePlayerNum, savePerspective, viewId))
  log(bWriteLog and string.format("[v_wllwu] logic_team_platform_new:IsNeedResetFilterCondition YES After nTabID=%s,num=%s,perspective=%s, ", nTabID, nPlayerNum, nPerspective))
  if saveTabID == nTabID and savePlayerNum == nPlayerNum and savePerspective == nPerspective then
    log(bWriteLog and "[v_wllwu] logic_team_platform_new:IsNeedResetFilterCondition 5")
    return
  end
  log(bWriteLog and "[v_wllwu] logic_team_platform_new:IsNeedResetFilterCondition true")
  return true
end
function logic_team_platform_new:GetCurSelectInfo()
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local curFilterInfo = logic_mode_selection:GetFilterInfo()
  local matchId, viewId, viewIds = logic_mode_selection:GetCurSelectInfo()
  local tabId
  local tabList = logic_mode_selection:GetMenuListByViewID(viewId)
  if tabList and 0 < #tabList then
    tabId = tabList[1]
  end
  log(bWriteLog and "[v_wllwu] [v_wllwu] logic_team_platform_new:GetCurSelectInfo, tabId = " .. tostring(tabId))
  return tabId, curFilterInfo.teamNum, curFilterInfo.perspective, viewId
end
function logic_team_platform_new:UpdateCurSelectFilterInfo()
  log(bWriteLog and "[v_wllwu] logic_team_platform_new UpdateCurSelectFilterInfo")
  if not curSelectFilterOptionInfo or not curSelectFilterOptionInfo.modeInfo then
    return
  end
  curSelectFilterOptionInfo.modeInfo = _UpdateModeInfoList(curSelectFilterOptionInfo)
end
function logic_team_platform_new:GetPublishOption()
  log(bWriteLog and "[v_wllwu] logic_team_platform_new newMode GetPublishOption")
  if not curSelectPublishOptionInfo then
    local TeamPlatform_Macro = require("client.slua.logic.teamup.teamplatform_macro")
    curSelectPublishOptionInfo = self:GetInitOption(TeamPlatform_Macro.Enum_FilterType.Publish)
    if savedRecruitCondition and savedRecruitCondition.nMinSegment and savedRecruitCondition.nMinSegment ~= curSelectPublishOptionInfo.nMinSegment then
      savedRecruitCondition.nMinSegment = curSelectPublishOptionInfo.nMinSegment
      log(bWriteLog and "[v_wllwu] logic_team_platform_new:GetPublishOption, option.nMinSegment = " .. tostring(curSelectPublishOptionInfo.nMinSegment))
    end
  else
    local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
    local modeInfo = logic_mode_selection:GetFilterInfo()
    local matchId, viewId = logic_mode_selection:GetCurSelectInfo()
    local tabList = logic_mode_selection:GetMenuListByViewID(viewId)
    local tabId = tabList[1]
    curSelectPublishOptionInfo.nPlayerNum = modeInfo.teamNum
    curSelectPublishOptionInfo.nPerspective = modeInfo.perspective
    curSelectPublishOptionInfo.nTabID = tabId
    curSelectPublishOptionInfo.nMatchID = matchId
    curSelectPublishOptionInfo.nViewID = viewId
    curSelectPublishOptionInfo.nZoneID = self:GetZoneID()
    curSelectPublishOptionInfo = _ResetPublishModeOption(curSelectPublishOptionInfo)
  end
  self:GetWOWPublishOption()
  self:ResetKdWithSegmentValue(curSelectPublishOptionInfo)
  log_tree(bWriteLog and "[v_wllwu] logic_team_platform_new curSelectPublishOptionInfo is ", curSelectPublishOptionInfo)
  return curSelectPublishOptionInfo
end
function logic_team_platform_new:GetWOWPublishOption()
  local TeamPlatformSystem = require("client.slua.logic.teamup.logic_team_platform")
  local TeamPlatform_Macro = require("client.slua.logic.teamup.teamplatform_macro")
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  local Util_UGC = require("client.slua.logic.ugc.util_ugc")
  local LogicUGCMulti = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMulti)
  log(bWriteLog and "logic_team_platform_new:GetWOWPublishOption TeamPlatformSystem.nPlatformType " .. TeamPlatformSystem.nPlatformType)
  if TeamPlatformSystem.nPlatformType == TeamPlatform_Macro.Enum_PlatformType.WoW then
    local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
    local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
    local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
    local LogicUGCCollectionList = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCCollectionList)
    curSelectPublishOptionInfo.nTabID = 900
    self.ModID = LogicUGCMatch:GetMatchModID()
    local DataName, CoverImage, mod_icon
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    if self.ModID and self.ModID > 0 then
      local modinfo = LogicUGC:BatchGetModInfo({
        self.ModID
      }, UGCMacros.ENUM_MODE_TYPE.UgcMatch)
      if modinfo and next(modinfo) then
        local pub_mod_meta = modinfo[self.ModID].pub_mod_meta
        curSelectPublishOptionInfo.tag = pub_mod_meta.setting.tag
        curSelectPublishOptionInfo.tag_v2 = pub_mod_meta.setting.tag_v2
        curSelectPublishOptionInfo.subfeature_tag = pub_mod_meta.setting.subfeature_tag
        DataName = pub_mod_meta.setting.name
        local page = Util_UGC.GetAllViewImageUrls(pub_mod_meta, true)
        mod_icon = page[1]
        local ModTeamSize = TeamUpNewSystem.GetDefaultMaxTeamNum()
        if pub_mod_meta.setting and pub_mod_meta.setting.team_size then
          ModTeamSize = pub_mod_meta.setting.team_size
          if ModTeamSize == -1 then
            ModTeamSize = pub_mod_meta.setting.max_num or TeamUpNewSystem.GetDefaultMaxTeamNum()
            if 8 < ModTeamSize then
              ModTeamSize = 8
            end
          end
        end
        curSelectPublishOptionInfo.nPlayerNum = ModTeamSize or TeamUpNewSystem.GetDefaultMaxTeamNum()
      else
        local callback = function(ModInfo, type)
          log(bWriteLog and "logic_team_platform_new:GetPublishOption callback")
          local pub_mod_meta = ModInfo[self.ModID].pub_mod_meta
          curSelectPublishOptionInfo.tag = pub_mod_meta.setting.tag
          curSelectPublishOptionInfo.tag_v2 = pub_mod_meta.setting.tag_v2
          curSelectPublishOptionInfo.subfeature_tag = pub_mod_meta.setting.subfeature_tag
          DataName = pub_mod_meta.setting.name
          local page = Util_UGC.GetAllViewImageUrls(pub_mod_meta, true)
          mod_icon = page[1]
          local ModTeamSize = TeamUpNewSystem.GetDefaultMaxTeamNum()
          if pub_mod_meta.setting and pub_mod_meta.setting.team_size then
            ModTeamSize = pub_mod_meta.setting.team_size
            if ModTeamSize == -1 then
              ModTeamSize = pub_mod_meta.setting.max_num or TeamUpNewSystem.GetDefaultMaxTeamNum()
              if 8 < ModTeamSize then
                ModTeamSize = 8
              end
            end
          end
          curSelectPublishOptionInfo.nPlayerNum = ModTeamSize or TeamUpNewSystem.GetDefaultMaxTeamNum()
        end
        LogicUGC:BatchGetModInfo({
          self.ModID
        }, UGCMacros.ENUM_MODE_TYPE.UgcMatch, callback)
        log(bWriteLog and "logic_team_platform_new:GetPublishOption modinfo is nil")
      end
    else
      self.ModID = nil
    end
    if LogicUGCMulti.bIsBundleMatch then
      CoverImage = "/Game/UMG/Texture/Lobby_NoAtlas/Lobby_Match_SelectMap/ModeSelection_New/MapEntrance/UGC/Lobby_match_MapEntrance_MultipleChoiceMatching.Lobby_match_MapEntrance_MultipleChoiceMatching"
      local BundleType = LogicUGCMulti.BundleType
      self.CollectionID = LogicUGCMulti.BundleSelect and LogicUGCMulti.BundleSelect[1] or 0
      if BundleType == Config_UGC.Enum_Bundle_Type.Bundle then
        self.Collection = LogicUGCCollectionList:GetCollectionInfo(self.CollectionID)
        curSelectPublishOptionInfo.tag = self.Collection.tag
        curSelectPublishOptionInfo.tag_v2 = self.Collection.tag_v2
        DataName = self.Collection.name
      else
        curSelectPublishOptionInfo.tag = {}
        DataName = LogicUGCMulti:GetSelectBundleName()
      end
      local MaxTeamSize = LogicUGCMulti:GetMaxTeamSize()
      curSelectPublishOptionInfo.nPlayerNum = MaxTeamSize or TeamUpNewSystem.GetDefaultMaxTeamNum()
      log(bWriteLog and " curSelectPublishOptionInfo.nPlayerNum MaxTeamSize = " .. tostring(MaxTeamSize))
    else
      self.CollectionID = nil
    end
    local ShowModInfo = {
      mod_id = self.ModID or nil,
      mod_collection_id = self.CollectionID or nil,
      name = DataName or nil,
      mod_icon = mod_icon or nil,
      collection_icon = CoverImage or nil
    }
    curSelectPublishOptionInfo.wow_cli_trans = ShowModInfo
    log_tree("logic_team_platform_new:GetPublishOption curSelectPublishOptionInfo.wow_cli_trans:", curSelectPublishOptionInfo.wow_cli_trans)
  elseif TeamPlatformSystem.nPlatformType == TeamPlatform_Macro.Enum_PlatformType.Normal then
    curSelectPublishOptionInfo.tag = nil
    curSelectPublishOptionInfo.tag_v2 = nil
    curSelectPublishOptionInfo.subfeature_tag = nil
    curSelectPublishOptionInfo.wow_cli_trans = nil
  end
end
function logic_team_platform_new:GeNoThemeViewInfo(option)
  local modeInfoList = {}
  if option.modeInfo then
    local logic_mode_utils = require("client.slua.logic.mode_selection.logic_mode_utils")
    local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
    local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
    for _, v in ipairs(option.modeInfo) do
      if logic_mode_utils.IsGroupTypeView(v.nViewID, mode_selection_macro.Enum_Group_Type.Multi) or logic_mode_utils.IsGroupTypeView(v.nViewID, mode_selection_macro.Enum_Group_Type.Theme) then
        if logic_mode_utils.IsNormalView(v.nViewID) then
          table.insert(modeInfoList, v)
        end
      elseif logic_mode_selection:GetSubviewInfoBySubviewID(v.nViewID, true) then
        table.insert(modeInfoList, v)
      end
    end
  end
  if #modeInfoList <= 0 then
    local defaultViewId, defaultMatchId = _FindDefaultViewID(option.nTabID, option.nPlayerNum, option.nPerspective)
    if defaultViewId and defaultMatchId then
      table.insert(modeInfoList, {nViewID = defaultViewId, nMatchID = defaultMatchId})
    end
    log_error(bWriteLog and "[v_wllwu] logic_team_platform_new GeNoThemeViewInfo error defaultViewId = " .. tostring(defaultViewId) .. " defaultMatchId = " .. tostring(defaultMatchId))
  end
  return modeInfoList
end
function logic_team_platform_new:SaveFilterOption(option)
  if not option then
    log(bWriteLog and "[v_wllwu] logic_team_platform_new:SaveFilterOption error")
    return
  end
  log_tree(bWriteLog and "[v_wllwu] logic_team_platform_new:SaveFilterOption start option ", option)
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  option.modeInfo = option.modeInfo or {}
  for i, v in ipairs(option.modeInfo) do
    local viewInfo = logic_mode_selection:GetSubviewInfoBySubviewID(v.nViewID)
    local matchID = _GetMatchId(viewInfo, option.nPerspective, option.nPlayerNum)
    if matchID then
      v.nMatchID = matchID
    else
      log(bWriteLog and "[v_wllwu] logic_team_platform_new:SaveFilterOption nMatchID is nil and nViewID is " .. tostring(v.nViewID))
    end
  end
  local logic_mode_utils = require("client.slua.logic.mode_selection.logic_mode_utils")
  local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
  local TableUtil = require("common.table_util")
  local newModeInfo = TableUtil.CopyTable(option)
  for i, v in ipairs(option.modeInfo) do
    local viewInfo = logic_mode_selection:GetSubviewInfoBySubviewID(v.nViewID)
    if logic_mode_utils.IsGroupTypeView(v.nViewID, mode_selection_macro.Enum_Group_Type.Multi) or logic_mode_utils.IsGroupTypeView(v.nViewID, mode_selection_macro.Enum_Group_Type.Theme) then
      self:AddGroupView(newModeInfo.modeInfo, viewInfo, option)
    end
  end
  local TeamPlatformSystem = require("client.slua.logic.teamup.logic_team_platform")
  TeamPlatformSystem.ClearLastSearchTeamList()
  curSelectFilterOptionInfo = newModeInfo
  log_tree("[v_wllwu] logic_team_platform_new:SaveFilterOption end, curSelectFilterOptionInfo = ", curSelectFilterOptionInfo)
end
function logic_team_platform_new:SavePublishOption(option)
  log_tree(bWriteLog and "[v_wllwu] logic_team_platform_new:SavePublishOption option ", option)
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local viewInfo = logic_mode_selection:GetSubviewInfoBySubviewID(option.nViewID)
  local matchID = _GetMatchId(viewInfo, option.nPerspective, option.nPlayerNum)
  if matchID and option.nViewID ~= C_WOWViewId then
    option.nMatchID = matchID
  else
    log(bWriteLog and "[v_wllwu] logic_team_platform_new:SavePublishOption nMatchID is nil and nViewID is " .. tostring(option.nViewID))
  end
  curSelectPublishOptionInfo = option
end
function logic_team_platform_new:GetPublishCondition()
  local option = self:GetPublishOption()
  local TeamPlatformSystem = require("client.slua.logic.teamup.logic_team_platform")
  local from = TeamPlatformSystem.GetPublishRecruitMsgFrom()
  local condition = {
    mode = option.nMatchID,
    view = option.nViewID,
    lang = option.bOpenSameLanguage and 1 or 0,
    zone = option.nZoneID,
    segment_level = option.nMinSegment,
    mic_open = option.nSelectMicType,
    same_main_city = option.nSelectCityType,
    play_style = option.nPloy,
    member_voice_invite = option.bMemberCanInvite and 1 or 0,
    kd = option.nKD,
    worth = option.nMinWorth,
    send_to_corps_channel = option.send_to_corps_channel,
    send_to_room_channel = option.send_to_room_channel,
    send_to_return_channel = option.send_to_return_channel,
    send_to_mentor_channel = option.send_to_mentor_channel,
    send_to_recruit_channel = true,
    tab_id = option.nTabID,
    from = from,
    perspective = option.nPerspective,
    playerNum = option.nPlayerNum,
    hunted_rating = option.hunted_rating
  }
  local TeamPlatformSystem = require("client.slua.logic.teamup.logic_team_platform")
  local TeamPlatform_Macro = require("client.slua.logic.teamup.teamplatform_macro")
  local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  if TeamPlatformSystem.nPlatformType == TeamPlatform_Macro.Enum_PlatformType.WoW then
    condition.tag_v2 = option.tag_v2
    condition.subfeature_tag = option.subfeature_tag
    condition.wow_cli_trans = option.wow_cli_trans
    if self.ModID and 0 < self.ModID then
      local modinfo = LogicUGC:BatchGetModInfo({
        self.ModID
      }, UGCMacros.ENUM_MODE_TYPE.UgcMatch)
      if modinfo and next(modinfo) then
        local pub_mod_meta = modinfo[self.ModID].pub_mod_meta
        condition.tag_v2 = pub_mod_meta.setting.tag_v2
        condition.subfeature_tag = pub_mod_meta.setting.subfeature_tag
        condition.mod_setting = pub_mod_meta.setting or nil
        condition.mod_game_result = pub_mod_meta.game_result or nil
        condition.mod_comment_data = pub_mod_meta.comment_data or nil
        condition.ml_tag_info = pub_mod_meta.ml_tag_info or nil
      else
        local callback = function(ModInfo, type)
          log(bWriteLog and "logic_team_platform_new:GetPublishOption callback")
          local pub_mod_meta = ModInfo[self.ModID].pub_mod_meta
          condition.tag_v2 = pub_mod_meta.setting.tag_v2
          condition.subfeature_tag = pub_mod_meta.setting.subfeature_tag
          condition.mod_setting = pub_mod_meta.setting or nil
          condition.mod_game_result = pub_mod_meta.game_result or nil
          condition.mod_comment_data = pub_mod_meta.comment_data or nil
          condition.ml_tag_info = pub_mod_meta.ml_tag_info or nil
        end
        LogicUGC:BatchGetModInfo({
          self.ModID
        }, UGCMacros.ENUM_MODE_TYPE.UgcMatch, callback)
        log(bWriteLog and "logic_team_platform_new:GetPublishOption modinfo is nil")
      end
    end
  end
  if not self:IsClassicRank(option.nTabID) then
    log(bWriteLog and "[v_wllwu] logic_team_platform_new:GetPublishCondition reset segment_level")
    condition.segment_level = 0
  end
  log_tree("logic_team_platform_new:GetPublishCondition condition = ", condition)
  return condition
end
function logic_team_platform_new:RecruitTeam()
  local condition = self:GetPublishCondition()
  if condition.mode == 64814 then
    local logic_mode_asymmertric = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_asymmertric)
    if logic_mode_asymmertric:GetIsHunter() then
      printf("logic_team_platform_new:RecruitTeam set camp to 2")
      logic_mode_asymmertric:SetCamp(2)
      ShowNotice(78317)
    end
  end
  local ConscribeHandler = require("client.network.Protocol.ConscribeHandler")
  ConscribeHandler.send_publish_team_conscribe_req(condition)
end
function logic_team_platform_new:ToFilterCondition()
  local TeamPlatformSystem = require("client.slua.logic.teamup.logic_team_platform")
  local TeamPlatform_Macro = require("client.slua.logic.teamup.teamplatform_macro")
  local option = self:GetFilterOption()
  local condition = {
    mode_list = {},
    lang = option.bOpenSameLanguage and 1 or 0,
    zone = option.nZoneID,
    segment_level = option.nMinSegment,
    mic_open = option.nSelectMicType,
    same_main_city = option.nSelectCityType,
    play_style = option.nPloy,
    kd = option.nKD,
    worth = option.nMinWorth,
    hunted_rating = option.hunted_rating
  }
  if TeamPlatformSystem.nPlatformType == TeamPlatform_Macro.Enum_PlatformType.WoW or TeamPlatformSystem.nPlatformType == TeamPlatform_Macro.Enum_PlatformType.WoWHall then
    condition.tag_v2 = option.tag_v2
    condition.subfeature_tag = option.subfeature_tag
  else
    condition.tag_v2 = nil
    condition.subfeature_tag = nil
  end
  if not self:IsClassicRank(option.nTabID) then
    log(bWriteLog and "[v_wllwu] logic_team_platform_new:ToFilterCondition reset segment_level")
    condition.segment_level = 0
  end
  if option.modeInfo then
    local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
    local logic_team_platform_utils = require("client.slua.logic.teamup.logic_team_platform_utils")
    for i, v in ipairs(option.modeInfo) do
      if v.nViewID then
        local matchID = v.nMatchID
        if not matchID then
          local viewInfo = logic_mode_selection:GetSubviewInfoBySubviewID(v.nViewID)
          matchID = _GetMatchId(viewInfo, option.nPerspective, option.nPlayerNum)
          log_error(bWriteLog and string.format("logic_team_platform_new:ToFilterCondition %s-%s-%s-%s", tostring(matchID), tostring(v.nViewID), tostring(option.nPerspective), tostring(option.nPlayerNum)))
        end
        if matchID then
          local info = {
            [1] = matchID,
            [2] = v.nViewID,
            [3] = logic_team_platform_utils.IsCurSelectMode(v.nViewID, matchID) and 1 or 0
          }
          table.insert(condition.mode_list, info)
        end
      end
    end
  end
  if #condition.mode_list <= 0 then
    log_error(bWriteLog and "[v_wllwu] logic_team_platform_new:ToFilterCondition error")
  end
  log_tree("logic_team_platform_new.ToFilterCondition === ", condition)
  return condition
end
function logic_team_platform_new:GetSelectMapNumAndView(selectMaps)
  if not selectMaps or #selectMaps <= 0 then
    return 0
  end
  local num = #selectMaps
  if num <= 1 then
    return num, selectMaps[1].nViewID
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local logic_mode_utils = require("client.slua.logic.mode_selection.logic_mode_utils")
  local mapNum = 0
  local viewId
  for _, v in pairs(selectMaps) do
    local viewInfo = logic_mode_selection:GetSubviewInfoBySubviewID(v.nViewID)
    if viewInfo then
      if logic_mode_utils.IsThemeGroupView(viewInfo) or logic_mode_utils.IsRandomView(viewInfo) then
        if viewInfo.is_group_base then
          mapNum = mapNum + 1
          if not viewId then
            viewId = viewInfo.id
          end
        end
      else
        mapNum = mapNum + 1
        viewId = viewId or viewInfo.id
      end
    end
  end
  return mapNum, viewId
end
function logic_team_platform_new:GetFilterModeName(option)
  local modeNum, viewId = self:GetSelectMapNumAndView(option.modeInfo)
  if modeNum <= 0 then
    log_tree(bWriteLog and "[v_wllwu] logic_team_platform_new newMode GetFilterModeName error, option = ", option)
    return ""
  end
  local mapNameStr = ""
  if modeNum == 1 then
    local logic_mode_utils = require("client.slua.logic.mode_selection.logic_mode_utils")
    mapNameStr = logic_mode_utils.GetMapNameByViewID(viewId) or ""
  elseif 1 < modeNum then
    local logic_recruit_filter_new = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_recruit_filter_new)
    local tabName = logic_recruit_filter_new:GetFilterTabName(option.nTabID) or ""
    mapNameStr = LocUtil.LocalizeResFormat(44381, tabName, modeNum)
  end
  return mapNameStr
end
function logic_team_platform_new:IsClassicRank(tabID)
  if not tabID then
    return
  end
  local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
  return tabID == mode_selection_macro.Enum_TabID.RankClassicMode
end
function logic_team_platform_new:IsNeedShowSegment(tabID)
  return logic_team_platform_new:IsClassicRank(tabID)
end
function logic_team_platform_new:GetModeListData(tabInfo)
  if not tabInfo then
    return
  end
  local list = {}
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  for _, id in ipairs(tabInfo.sub_views) do
    local menuInfo = logic_mode_selection:GetSubviewInfoBySubviewID(id)
    if _IsShowAllSubviews(menuInfo) then
      for _, v in ipairs(menuInfo.group_view) do
        local groupInfo = logic_mode_selection:GetSubviewInfoBySubviewID(v.view_id)
        local viewInfo = _GetMenuInfo(groupInfo)
        if viewInfo then
          if v.show_name and v.show_name ~= 0 then
            local suffixStr = LocUtil.GetLocalizeResStr(v.show_name)
            if suffixStr ~= "" and suffixStr ~= viewInfo.name then
              viewInfo.name = LocUtil.LocalizeResFormat(18962, viewInfo.name, suffixStr)
            end
          end
          table.insert(list, viewInfo)
        end
      end
    else
      local viewInfo = _GetMenuInfo(menuInfo)
      if viewInfo then
        table.insert(list, viewInfo)
      end
    end
  end
  if 1 < #list then
    table.sort(list, function(a, b)
      return a.nTabSort < b.nTabSort
    end)
  end
  log_tree(bWriteLog and "[v_wllwu] GetModeListData, tabID = " .. tostring(tabInfo.id), list)
  return list
end
function logic_team_platform_new:GetSendRecruitCondition()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  savedRecruitCondition = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eTeamPlatFormRecruitCondition)
  return savedRecruitCondition
end
function logic_team_platform_new:SaveSendRecruitCondition(option, isTPlan)
  if not option then
    return
  end
  if not savedRecruitCondition then
    savedRecruitCondition = {}
  end
  if isTPlan then
    savedRecruitCondition.nMinWorth = option.nMinWorth
  else
    savedRecruitCondition.nKD = option.nKD
    savedRecruitCondition.nMinSegment = option.nMinSegment
    savedRecruitCondition.send_to_room_channel = option.send_to_room_channel
    savedRecruitCondition.send_to_corps_channel = option.send_to_corps_channel
    savedRecruitCondition.send_to_return_channel = option.send_to_return_channel
  end
  savedRecruitCondition.bOpenSameLanguage = option.bOpenSameLanguage
  savedRecruitCondition.nSelectMicType = option.nSelectMicType
  savedRecruitCondition.nSelectCityType = option.nSelectCityType
  savedRecruitCondition.hunted_rating = option.hunted_rating
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  PlayerPrefsSystem.SaveTableToFile_N(savedRecruitCondition, PlayerPrefsSystem.ePlayerPrefsType.eTeamPlatFormRecruitCondition)
end
function logic_team_platform_new:GetTabIdByViewID(viewId)
  if viewIdToSendTabId and viewIdToSendTabId[viewId] then
    return viewIdToSendTabId[viewId]
  end
  local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
  local tabList = logic_mode_selection:GetMenuListByViewID(viewId)
  viewIdToSendTabId = viewIdToSendTabId or {}
  if tabList and 0 < #tabList then
    viewIdToSendTabId[viewId] = tabList[#tabList]
  else
    viewIdToSendTabId[viewId] = -1
  end
  log(bWriteLog and "[v_wllwu] logic_team_platform_new:GetTabIdByViewID viewId = " .. tostring(viewId) .. " TabID = " .. tostring(viewIdToSendTabId[viewId]))
  return viewIdToSendTabId[viewId]
end
function logic_team_platform_new:IsTeamPlatFormRecruitOpen()
  return isUseNewRecruit
end
function logic_team_platform_new:UpdateSwitch(isOpen)
  log(bWriteLog and "[v_wllwu] logic_team_platform_new:UpdateSwitch, isOpen = " .. tostring(isOpen))
  isUseNewRecruit = isOpen
end
function logic_team_platform_new:send_broadcast_team_conscribe_req()
  local ConscribeHandler = require("client.network.Protocol.ConscribeHandler")
  ConscribeHandler.send_broadcast_team_conscribe_req()
end
function logic_team_platform_new:IsNeedShowLeaderGuide()
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if not TeamUpNewSystem.IsTeamLeader() then
    return
  end
  if hasShowedBubbleTips then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveLeaderGuideData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eTeamPlatFormEntranceLeaderGuide)
  if saveLeaderGuideData and saveLeaderGuideData.leaderGuide then
    hasShowedBubbleTips = true
    return
  end
  return true
end
function logic_team_platform_new:UpdateSendRecruitGuideSaveData()
  if hasShowedBubbleTips then
    return
  end
  hasShowedBubbleTips = true
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveLeaderGuideData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eTeamPlatFormEntranceLeaderGuide)
  if not saveLeaderGuideData then
    PlayerPrefsSystem.SaveTableToFile_N({leaderGuide = true}, PlayerPrefsSystem.ePlayerPrefsType.eTeamPlatFormEntranceLeaderGuide)
  end
end
function logic_team_platform_new:GetRecruitCDTime()
  if recruitCD ~= 0 then
    return recruitCD
  end
  local chat_macro = require("client.slua.logic.lobby_chat.chat_macro")
  local channel = chat_macro.Channel.channelTeamRecruit
  local cfg = CDataTable.GetTableData("ChatChannelConfig", channel)
  if cfg and cfg.CD and 0 < cfg.CD then
    recruitCD = cfg.CD
  else
    recruitCD = defaultRecruitCD
  end
  log(bWriteLog and "[v_wllwu] _GetRecruitCDTime recruitCD = " .. tostring(recruitCD))
  return recruitCD
end
function logic_team_platform_new:FilterFullTeamMember(teamList)
  if not teamList or #teamList <= 0 then
    return teamList
  end
  for i = #teamList, 1, -1 do
    local teamInfo = teamList[i]
    if #teamInfo.members >= teamInfo.team_size then
      table.remove(teamList, i)
    end
  end
  return teamList
end
function logic_team_platform_new:FilterMatchLanguage(teamList)
  if not teamList or #teamList <= 0 then
    return teamList
  end
  local TeamPlatformSystem = require("client.slua.logic.teamup.logic_team_platform")
  local filterOption = TeamPlatformSystem.GetFilterOption()
  if not filterOption.bOpenSameLanguage then
    return teamList
  end
  local LanguageSelectSystem = require("client.logic.language_select.logic__language_select")
  local selfLang = LanguageSelectSystem.GetFirstMatchLanguageName()
  for i = #teamList, 1, -1 do
    local teamInfo = teamList[i]
    if selfLang ~= "" and selfLang ~= teamInfo.lang then
      table.remove(teamList, i)
    end
  end
  return teamList
end
function logic_team_platform_new:GetSegmentData(option)
  if not option then
    return
  end
  local minSegment = 101
  log(bWriteLog and "[v_wllwu] logic_team_platform_new:GetSegmentData, nPerspective = " .. tostring(option.nPerspective) .. " nPlayerNum = " .. tostring(option.nPlayerNum))
  local nPerspective = option.nPerspective or ENUM_PerspectiveType.TPP
  local nPlayerNum = option.nPlayerNum or 4
  local segmentInfo = DataMgr.GetSegmentByZoneId(option.nZoneID)
  if segmentInfo then
    if nPerspective == ENUM_PerspectiveType.TPP then
      minSegment = nPlayerNum == 2 and segmentInfo.double or segmentInfo.team
    else
      minSegment = nPlayerNum == 2 and segmentInfo.fpp_double or segmentInfo.fpp_team
    end
  end
  local minLimitSeg = 0
  local maxLimitSeg = 0
  if LobbySystem.CheckOpen(BP_ENUM_TEAM_UP_LIMIT_SWITCH) then
    local LogicTeamUpLimit = require("client.slua.logic.teamup.logic_team_up_limit")
    minLimitSeg, maxLimitSeg = LogicTeamUpLimit.GetSpecifiedModeSegmentLimit(nPerspective, nPlayerNum)
    if minLimitSeg == -1 or maxLimitSeg == -1 then
      minLimitSeg = minSegment
      maxLimitSeg = minSegment
    end
  end
  local logic_promotion_mode = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_promotion_mode)
  local logic_promotion_homepage = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_promotion_homepage)
  local isOpenPromotion = logic_promotion_mode:IsOpenPromotion()
  if isOpenPromotion then
    local minScore, maxScore = logic_promotion_homepage:GetCurPromotionMinSegmentLevel()
    if minScore and maxScore then
      minLimitSeg = minScore
      if maxLimitSeg < maxScore then
        maxLimitSeg = maxScore
      end
    end
  end
  local segmentList = {}
  local rankIntegralLevel = FuncUtil.GetRankTable()
  for k, v in pairs(rankIntegralLevel or {}) do
    if v.IntegralTypeNew == 7 or v.IntegralTypeNew == 8 then
      log()
    end
    if (maxLimitSeg <= 0 or maxLimitSeg >= tonumber(k)) and minLimitSeg <= tonumber(k) and (isOpenPromotion or minSegment >= tonumber(k)) then
      local has = false
      for i = 1, #segmentList do
        if segmentList[i].nID == tonumber(v.IntegralTypeNew) then
          has = true
          break
        end
      end
      if not has then
        local segment = {
          nID = tonumber(v.IntegralTypeNew),
          sName = v.IntegralTypeName
        }
        table.insert(segmentList, segment)
      end
    end
  end
  return segmentList
end
function logic_team_platform_new:GetCurSelectModeList()
  if not curSelectModeList or isNeedUpdateCurSelectModeList then
    local logic_team_platform_utils = require("client.slua.logic.teamup.logic_team_platform_utils")
    curSelectModeList = logic_team_platform_utils.GetCurSelectModeList()
    self:SetNeedRefreshModeList(false)
  end
  return curSelectModeList
end
function logic_team_platform_new:SetNeedRefreshModeList(bNeedUpdate)
  isNeedUpdateCurSelectModeList = bNeedUpdate
end
function logic_team_platform_new:ChangeFilteringCriteria(option)
  local LogicUgcFilterTag = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUgcFilterTag)
  local FilterTags, FilterSublabel = LogicUgcFilterTag:GetSearchTagID()
  if FilterTags or FilterSublabel then
    option.tag_v2 = FilterTags
    option.subfeature_tag = FilterSublabel
  else
    option.tag = {}
    option.feature_tag_list = {}
  end
  curSelectFilterOptionInfo = option
end
function logic_team_platform_new:CleanCurSelectFilterOptionInfo()
  curSelectFilterOptionInfo = nil
end
function logic_team_platform_new:RecruitOpenMic(callback)
  local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
  local EUChatRestriction, status = logic_chat_voice:CheckEUChatRestriction()
  if EUChatRestriction then
    ShowNotice(46880036)
  else
    logic_chat_voice:RequestPrivacyAndOpenMic(callback, 4074)
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_team_platform_new = class(CModuleBase, nil, logic_team_platform_new)
return Clogic_team_platform_new