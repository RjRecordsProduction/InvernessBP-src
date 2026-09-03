local logic_season_config = {}
function logic_season_config.SendSeasonConfigReq()
  local SeasonHandler = require("client.network.Protocol.SeasonHandler")
  SeasonHandler.send_get_season_config_req()
end
function logic_season_config.UpdateSeasonConfig(config)
  log_tree(bWriteLog and "UpdateSeasonConfig:", config)
  logic_season_config.SeasonConfig = config
  EventSystem:postEvent(EVENTTYPE_SEASON_CONFIG, EVENTID_GET_SEASON_CONFIG)
end
function logic_season_config.GetSeasonConfig(seasonId)
  if not logic_season_config.SeasonConfig or not logic_season_config.SeasonConfig[seasonId] then
    return nil
  end
  return logic_season_config.SeasonConfig[seasonId]
end
function logic_season_config.GetSeasonYearTime(seasonYearId)
  if not logic_season_config.SeasonConfig then
    return 0, 0
  end
  local seasonIdList = {}
  local SeasonInfo = CDataTable.GetTable("SeasonInfo")
  for _, cfg in pairs(SeasonInfo) do
    if cfg.SeasonYearID == seasonYearId then
      table.insert(seasonIdList, cfg.SeasonID)
    end
  end
  if #seasonIdList < 0 then
    return 0, 0
  end
  table.sort(seasonIdList, function(a, b)
    return a < b
  end)
  local seasonBegin = seasonIdList[1]
  local seasonEnd = seasonIdList[#seasonIdList]
  if not logic_season_config.SeasonConfig[seasonBegin] or not logic_season_config.SeasonConfig[seasonEnd] then
    return 0, 0
  end
  return logic_season_config.SeasonConfig[seasonBegin].begin_time, logic_season_config.SeasonConfig[seasonEnd].end_time
end
function logic_season_config.GetNewSeasonYearTime(seasonYearId)
  if not logic_season_config.SeasonConfig then
    return 0, 0
  end
  local seasonIdList = {}
  local SeasonInfo = CDataTable.GetTable("SeasonInfo")
  local season_year_util = require("client.logic.season_year.util.season_year_util")
  local OldSeasonYearMaxId = season_year_util.GetOldSeasonYearMaxId()
  local existSeasonID = {}
  local IsOldSeasonYear = seasonYearId == OldSeasonYearMaxId
  for _, cfg in pairs(SeasonInfo) do
    if cfg.SeasonYearID == seasonYearId or IsOldSeasonYear and cfg.SeasonYearID > 1 and OldSeasonYearMaxId > cfg.SeasonYearID then
      table.insert(seasonIdList, cfg.SeasonID)
      existSeasonID[cfg.SeasonID] = true
    end
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local isBlueHole = Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE
  if isBlueHole then
    local season_year_config = require("client.logic.season_year.config.season_year_config")
    for seasonID, seasonYearID in pairs(season_year_config.BlueHoleSpecialSeasonYear) do
      if seasonYearID == seasonYearId and not existSeasonID[seasonID] then
        local config = CDataTable.GetTableData("SeasonInfo", seasonID)
        if config then
          table.insert(seasonIdList, seasonID)
          existSeasonID[seasonID] = true
        end
      end
    end
  end
  if #seasonIdList < 0 then
    return 0, 0
  end
  table.sort(seasonIdList, function(a, b)
    return a < b
  end)
  local seasonBegin = seasonIdList[1]
  local seasonEnd = seasonIdList[#seasonIdList]
  if not logic_season_config.SeasonConfig[seasonBegin] or not logic_season_config.SeasonConfig[seasonEnd] then
    return 0, 0
  end
  return logic_season_config.SeasonConfig[seasonBegin].begin_time, logic_season_config.SeasonConfig[seasonEnd].end_time
end
function logic_season_config.GetNewSeasonYearTime(seasonYearId)
  if not logic_season_config.SeasonConfig then
    return 0, 0
  end
  local seasonIdList = {}
  local SeasonInfo = CDataTable.GetTable("SeasonInfo")
  local season_year_util = require("client.logic.season_year.util.season_year_util")
  local OldSeasonYearMaxId = season_year_util.GetOldSeasonYearMaxId()
  local existSeasonID = {}
  local IsOldSeasonYear = seasonYearId == OldSeasonYearMaxId
  for _, cfg in pairs(SeasonInfo) do
    if cfg.SeasonYearID == seasonYearId or IsOldSeasonYear and cfg.SeasonYearID > 1 and OldSeasonYearMaxId > cfg.SeasonYearID then
      table.insert(seasonIdList, cfg.SeasonID)
      existSeasonID[cfg.SeasonID] = true
    end
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local isBlueHole = Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE
  if isBlueHole then
    local season_year_config = require("client.logic.season_year.config.season_year_config")
    for seasonID, seasonYearID in pairs(season_year_config.BlueHoleSpecialSeasonYear) do
      if seasonYearID == seasonYearId and not existSeasonID[seasonID] then
        local config = CDataTable.GetTableData("SeasonInfo", seasonID)
        if config then
          table.insert(seasonIdList, seasonID)
          existSeasonID[seasonID] = true
        end
      end
    end
  end
  if #seasonIdList < 0 then
    return 0, 0
  end
  table.sort(seasonIdList, function(a, b)
    return a < b
  end)
  local seasonBegin = seasonIdList[1]
  local seasonEnd = seasonIdList[#seasonIdList]
  if not logic_season_config.SeasonConfig[seasonBegin] or not logic_season_config.SeasonConfig[seasonEnd] then
    return 0, 0
  end
  return logic_season_config.SeasonConfig[seasonBegin].begin_time, logic_season_config.SeasonConfig[seasonEnd].end_time
end
function logic_season_config.OnGameStateChange(eventType, eventID, gameState)
  if gameState.current == GameStatus.Login or gameState.current == GameStatus.Fighting and not GameStatus.IsInLobbyOrMainCity() then
    logic_season_config.SeasonConfig = nil
  end
end
return logic_season_config