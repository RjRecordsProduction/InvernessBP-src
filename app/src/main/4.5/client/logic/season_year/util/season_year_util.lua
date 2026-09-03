local season_year_util = {}
local DEFAULT_OLD_SEASON_MAX_ID = 46
local DEFAULT_OLD_SEASON_YEAR_MAX_ID = 10
function season_year_util.GetSeasonYearId()
  local season_id = DataMgr.season_id
  local seasonCfg = CDataTable.GetTableData("SeasonInfo", season_id)
  local season_year_id = 0
  if seasonCfg then
    season_year_id = seasonCfg.SeasonYearID
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local isBlueHole = Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE
  if isBlueHole then
    local season_year_config = require("client.logic.season_year.config.season_year_config")
    local specialSeasonYearID = season_year_config.BlueHoleSpecialSeasonYear[season_id]
    season_year_id = specialSeasonYearID or season_year_id
  end
  return season_year_id
end
function season_year_util.GetSeasonConfigListBySeasonYearID(season_year_id)
  local seasonCfgs = CDataTable.GetTableByFilter("SeasonInfo", "SeasonYearID", season_year_id)
  local list = {}
  local existSeasonID = {}
  for k, v in pairs(seasonCfgs) do
    table.insert(list, v)
    existSeasonID[v.SeasonID] = true
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local isBlueHole = Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE
  if isBlueHole then
    local season_year_config = require("client.logic.season_year.config.season_year_config")
    for seasonID, seasonYearID in pairs(season_year_config.BlueHoleSpecialSeasonYear) do
      if seasonYearID == season_year_id and not existSeasonID[seasonID] then
        local config = CDataTable.GetTableData("SeasonInfo", seasonID)
        if config then
          table.insert(list, config)
          existSeasonID[seasonID] = true
        end
      end
    end
  end
  table.sort(list, function(a, b)
    return a.SeasonID < b.SeasonID
  end)
  log_tree("season_year_util.GetSeasonConfigListBySeasonYearID list = ", list)
  return list
end
function season_year_util.GetTaskRankID(pre_cond)
  local rankCondition = pre_cond and pre_cond[1] and pre_cond[1].pre_cond_value
  if rankCondition then
    return rankCondition + 1
  end
  return 0
end
function season_year_util.CheckFunctionIsOpen()
  local isOpen = false
  if LobbySystem.CheckOpen(BP_ENUM_SEASON_YEAR_SWITCH) then
    local config = CDataTable.GetTableData("SeasonYear_Param", "start_season_index")
    if config then
      local startSeasonID = tonumber(config.Value)
      isOpen = startSeasonID <= DataMgr.season_id
    end
  end
  log_format("season_year_util.CheckFunctionOpen: isOpen = %s", isOpen)
  return isOpen
end
function season_year_util.CheckCycleIsOpen()
  local isOpen = false
  local config = CDataTable.GetTableData("SeasonYear_Param", "end_cycleyear_index")
  if config then
    local endSeasonID = tonumber(config.Value)
    isOpen = endSeasonID > DataMgr.season_id
  end
  log_format("season_year_util.CheckCycleIsOpen: isOpen = %s", isOpen)
  return isOpen
end
function season_year_util.GetOldSeasonMaxId()
  local config = CDataTable.GetTableData("SeasonYear_Param", "start_season_index")
  if config then
    local startSeasonID = tonumber(config.Value)
    log(bWriteLog and string.format("season_year_util:GetOldSeasonMaxId - Calculated from startSeasonID: %d", startSeasonID - 1))
    return startSeasonID - 1
  end
  log(bWriteLog and string.format("season_year_util:GetOldSeasonMaxId - Using default value: %d", DEFAULT_OLD_SEASON_MAX_ID))
  return DEFAULT_OLD_SEASON_MAX_ID
end
function season_year_util.GetOldSeasonYearMaxId()
  local oldSeasonMaxId = season_year_util.GetOldSeasonMaxId()
  local currentSeasonCfg = CDataTable.GetTableData("SeasonInfo", oldSeasonMaxId)
  if currentSeasonCfg then
    local seasonYearID = tonumber(currentSeasonCfg.SeasonYearID)
    log(bWriteLog and string.format("season_year_util:GetOldSeasonYearMaxId - Calculated from seasonYearID: %d", seasonYearID))
    return seasonYearID
  end
  log(bWriteLog and string.format("season_year_util:GetOldSeasonYearMaxId - Using default value: %d", DEFAULT_OLD_SEASON_YEAR_MAX_ID))
  return DEFAULT_OLD_SEASON_YEAR_MAX_ID
end
function season_year_util.CreateSeasonBadgeToWidget(widgetUI, widget, season_year_id, badgeData, extraParam)
  local badgeUI
  if not (widget and season_year_id) or not widgetUI then
    log(bWriteLog and "season_year_util.CreateSeasonBadgeToWidget: widget or season_year_id or widgetUI is nil")
    return badgeUI
  end
  local seasonYearCfg = CDataTable.GetTableData("SeasonYear_Resource", season_year_id)
  if not seasonYearCfg then
    log(bWriteLog and "season_year_util.CreateSeasonBadgeToWidget: seasonYearCfg is nil")
    return badgeUI
  end
  local UIComponentModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.UIComponentModule)
  if UIComponentModule then
    log(bWriteLog and "season_year_util.CreateSeasonBadgeToWidget: UIComponentModule")
    badgeUI = widgetUI:CreateChildWindowWithLuaAndBpPath(widget, nil, UIComponentModule.Config.SeasonYear_Badge_Item_UIBP.LuaClassPath, seasonYearCfg.BPPath, badgeData, extraParam)
  end
  return badgeUI
end
return season_year_util