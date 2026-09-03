local LogicPeakGameUtil = {}
function LogicPeakGameUtil.IsOpen()
  log(bWriteLog and "LogicPeakGameUtil.IsOpen")
  local isOpen = LobbySystem.CheckOpen(BP_ENUM_SWITCH_PEAK_GAME)
  log(bWriteLog and "LogicPeakGameUtil.IsOpen isOpen = " .. tostring(isOpen))
  return isOpen
end
function LogicPeakGameUtil.IsPeakGameBattleType(battleTypeId)
  log(bWriteLog and "LogicPeakGameUtil.IsPeakGameBattleType battleTypeId = " .. tostring(battleTypeId))
  if not LogicPeakGameUtil.IsOpen() then
    log(bWriteLog and "LogicPeakGameUtil.IsPeakGameBattleType not open")
    return false
  end
  local isPeakGameBattleType = LogicPeakGameUtil.IsPeakGameBattleTypeIgnoreSwitch(battleTypeId)
  return isPeakGameBattleType
end
function LogicPeakGameUtil.IsPeakGameBattleTypeIgnoreSwitch(battleTypeId)
  log(bWriteLog and "LogicPeakGameUtil.IsPeakGameBattleTypeIgnoreSwitch battleTypeId = " .. tostring(battleTypeId))
  if not battleTypeId then
    log(bWriteLog and "LogicPeakGameUtil.IsPeakGameBattleType no battleTypeId")
    return false
  end
  local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
  local BattleTypeList = PeakGameConfig.BattleType
  for _, typeId in pairs(BattleTypeList) do
    if battleTypeId == typeId then
      log(bWriteLog and "LogicPeakGameUtil.IsPeakGameBattleType true")
      return true
    end
  end
  return false
end
function LogicPeakGameUtil.IsPeakGameMode(modeID)
  log(bWriteLog and string.format("LogicPeakGameUtil.IsPeakGameMode. modeID=%s", tostring(modeID)))
  if not modeID then
    return false
  end
  local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
  return PeakGameConfig.PeakGameModeMap[modeID] == true
end
function LogicPeakGameUtil.IsInOpenTime()
  log(bWriteLog and "LogicPeakGameUtil.IsInOpenTime")
  if not LogicPeakGameUtil.IsOpen() then
    log(bWriteLog and "LogicPeakGameUtil.IsInOpenTime not open")
    return false
  end
  local LogicPeakGame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGame)
  local beginTS, endTS = LogicPeakGame:GetPeakGameCurSeasonTime()
  log(bWriteLog and string.format("LogicPeakGameUtil.IsInOpenTime, beginTS:%s", beginTS))
  log(bWriteLog and string.format("LogicPeakGameUtil.IsInOpenTime, endTS:%s", endTS))
  local TimeUtil = require("client.common.time_util")
  if beginTS and endTS then
    if TimeUtil.UnixTimeBetween(beginTS, endTS) == 0 then
      log(bWriteLog and "LogicPeakGameUtil.IsInOpenTime 1")
      return true
    else
      log(bWriteLog and "LogicPeakGameUtil.IsInOpenTime 2")
      return false
    end
  end
  local seasonConfig = CDataTable.GetTableData("PeakGameSeasonInfo", DataMgr.season_id)
  if seasonConfig then
    local startTime = seasonConfig.StartTime
    local endTime = seasonConfig.EndTime
    log(bWriteLog and "LogicPeakGameUtil.IsInOpenTime startTime= " .. tostring(startTime) .. " endTime = " .. tostring(endTime))
    if startTime and startTime ~= "" and endTime and endTime ~= "" then
      local peakgame_start_time = TimeUtil.TimeStringToUnixstamp(startTime, false)
      local peakgame_end_time = TimeUtil.TimeStringToUnixstamp(endTime, false)
      log(bWriteLog and "LogicPeakGameUtil.IsInOpenTime peakgame_start_time= " .. tostring(peakgame_start_time) .. " peakgame_end_time = " .. tostring(peakgame_end_time))
      if TimeUtil.UnixTimeBetween(peakgame_start_time, peakgame_end_time) == 0 then
        log(bWriteLog and "LogicPeakGameUtil.IsInOpenTime 3")
        return true
      else
        log(bWriteLog and "LogicPeakGameUtil.IsInOpenTime 4")
        return false
      end
    end
  end
  log(bWriteLog and "LogicPeakGameUtil.IsInOpenTime 3")
  return false
end
function LogicPeakGameUtil.IsInRankOpenTime()
  log(bWriteLog and "LogicPeakGameUtil.IsInRankOpenTime")
  if not LogicPeakGameUtil.IsOpen() then
    log(bWriteLog and "LogicPeakGameUtil.IsInRankOpenTime not open")
    return false
  end
  local LogicPeakGame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGame)
  local beginTS, endTS = LogicPeakGame:GetPeakGameCurSeasonTime()
  beginTS = beginTS and beginTS + 86400
  log(bWriteLog and string.format("LogicPeakGameUtil.IsInRankOpenTime, beginTS:%s", beginTS))
  log(bWriteLog and string.format("LogicPeakGameUtil.IsInRankOpenTime, endTS:%s", endTS))
  local TimeUtil = require("client.common.time_util")
  if beginTS and endTS and TimeUtil.UnixTimeBetween(beginTS, endTS) == 0 then
    log(bWriteLog and "LogicPeakGameUtil.IsInRankOpenTime 1")
    return true
  end
  log(bWriteLog and "LogicPeakGameUtil.IsInRankOpenTime 3")
  return false
end
function LogicPeakGameUtil.IsPeakGameFinish()
  log(bWriteLog and "LogicPeakGameUtil.IsPeakGameFinish")
  if not LogicPeakGameUtil.IsOpen() then
    log(bWriteLog and "LogicPeakGameUtil.IsPeakGameFinish not open")
    return true
  end
  local LogicPeakGame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGame)
  local beginTS, endTS = LogicPeakGame:GetPeakGameCurSeasonTime()
  log(bWriteLog and string.format("LogicPeakGameUtil.IsPeakGameFinish, beginTS:%s", beginTS))
  log(bWriteLog and string.format("LogicPeakGameUtil.IsPeakGameFinish, endTS:%s", endTS))
  local TimeUtil = require("client.common.time_util")
  if endTS then
    local nNowTime = TimeUtil.GetServerTimeInSec()
    if endTS <= nNowTime then
      log(bWriteLog and "LogicPeakGameUtil.IsPeakGameFinish 1")
      return true
    else
      log(bWriteLog and "LogicPeakGameUtil.IsPeakGameFinish 2")
      return false
    end
  end
  local seasonConfig = CDataTable.GetTableData("PeakGameSeasonInfo", DataMgr.season_id)
  if seasonConfig then
    local endTime = seasonConfig.EndTime
    log(bWriteLog and "LogicPeakGameUtil.IsPeakGameFinish endTime = " .. tostring(endTime))
    if endTime and endTime ~= "" then
      local peakgame_end_time = TimeUtil.TimeStringToUnixstamp(endTime, false)
      log(bWriteLog and "LogicPeakGameUtil.IsPeakGameFinish peakgame_end_time = " .. tostring(peakgame_end_time))
      local nNowTime = TimeUtil.GetServerTimeInSec()
      if peakgame_end_time <= nNowTime then
        log(bWriteLog and "LogicPeakGameUtil.IsPeakGameFinish 3")
        return true
      else
        log(bWriteLog and "LogicPeakGameUtil.IsPeakGameFinish 4")
        return false
      end
    end
  end
  log(bWriteLog and "LogicPeakGameUtil.IsPeakGameFinish 5")
  return false
end
function LogicPeakGameUtil.IsPeakGameOpen()
  log(bWriteLog and "LogicPeakGameUtil.IsPeakGameOpen")
  if not LogicPeakGameUtil.IsOpen() then
    log(bWriteLog and "LogicPeakGameUtil.IsPeakGameOpen not open")
    return false
  end
  local open = LogicPeakGameUtil.IsPeakGameOpenWithoutSwitch()
  return open
end
function LogicPeakGameUtil.IsPeakGameOpenWithoutSwitch()
  log(bWriteLog and "LogicPeakGameUtil.IsPeakGameOpenWithoutSwitch")
  local peakgame_start_time = DataMgr.roleData.peakgame_start_time
  local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
  if DataMgr.season_id > PeakGameConfig.MinPeakGameSeasonId then
    log(bWriteLog and "LogicPeakGameUtil.IsPeakGameOpenWithoutSwitch 1")
    return true
  end
  local TimeUtil = require("client.common.time_util")
  local nNowTime = TimeUtil.GetServerTimeInSec()
  if DataMgr.season_id == PeakGameConfig.MinPeakGameSeasonId and peakgame_start_time and peakgame_start_time <= nNowTime then
    log(bWriteLog and "LogicPeakGameUtil.IsPeakGameOpenWithoutSwitch 2")
    return true
  end
  log(bWriteLog and "LogicPeakGameUtil.IsPeakGameOpenWithoutSwitch 3")
  return false
end
function LogicPeakGameUtil.GetSwitchBySeasonId()
  log(bWriteLog and "LogicPeakGameUtil.GetSwitchBySeasonId")
  local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
  local minPeakGameSeasonId = PeakGameConfig.MinPeakGameSeasonId + 1
  log(bWriteLog and "LogicPeakGameUtil.GetSwitchBySeasonId minPeakGameSeasonId = " .. tostring(minPeakGameSeasonId))
  if DataMgr.season_id and minPeakGameSeasonId and minPeakGameSeasonId <= DataMgr.season_id then
    return true
  end
  return false
end
function LogicPeakGameUtil.GetPeakSeasonTimeTable(seasonID)
  log(bWriteLog and "LogicPeakGameUtil.GetPeakSeasonTimeTable seasonID = " .. tostring(seasonID))
  if not seasonID then
    log(bWriteLog and "LogicPeakGameUtil.GetPeakSeasonTimeTable seasonID is invalid")
    return
  end
  local seasonConfig = CDataTable.GetTableData("PeakGameSeasonInfo", seasonID)
  if not seasonConfig then
    log(bWriteLog and string.format("LogicPeakGameUtil.GetPeakSeasonTimeTable return of no seasonConfig, seasonID:%s", seasonID))
    return nil
  end
  return seasonConfig
end
function LogicPeakGameUtil.GetPeakRankTableData(segment)
  log(bWriteLog and "LogicPeakGameUtil.GetPeakRankTableData segment = " .. tostring(segment))
  if not segment then
    log(bWriteLog and "LogicPeakGameUtil.GetPeakRankTableData segment is invalid")
    return nil
  end
  local rankCfg = CDataTable.GetTableData("PeakGameRankIntegralLevel", segment)
  return rankCfg
end
function LogicPeakGameUtil.GetPeakRankTable()
  return CDataTable.GetTable("PeakGameRankIntegralLevel")
end
function LogicPeakGameUtil.InitLargePeakRankIntegralWidget(base, widget)
  log(bWriteLog and "LogicPeakGameUtil.InitLargePeakRankIntegralWidget")
  if not base or not widget then
    log(bWriteLog and "LogicPeakGameUtil.InitLargePeakRankIntegralWidget no widget")
    return
  end
  local UIComponentModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.UIComponentModule)
  return UIComponentModule:InitWithParentComponent(base, UIComponentModule.Config.PeakGame_RankIntegralLevel_Style_Large_UIBP, widget)
end
function LogicPeakGameUtil.InitSmallPeakRankIntegralWidget(base, widget)
  log(bWriteLog and "LogicPeakGameUtil.InitSmallPeakRankIntegralWidget")
  if not base or not widget then
    log(bWriteLog and "LogicPeakGameUtil.InitSmallPeakRankIntegralWidget no widget")
    return
  end
  local UIComponentModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.UIComponentModule)
  local config = UIComponentModule.Config.PeakGame_RankIntegralLevel_Style_Small_UIBP
  local window = base:GetChildWindow(UIComponentModule.Config.PeakGame_RankIntegralLevel_Style_Small_UIBP)
  if window and widget == window.UIRoot then
    return window
  end
  return UIComponentModule:InitWithParentComponent(base, config, widget)
end
function LogicPeakGameUtil.InitSmallPeakRankIntegralSwitchWidget(base, widget, config)
  log(bWriteLog and "LogicPeakGameUtil.InitSmallPeakRankIntegralSwitchWidget")
  if not base or not widget then
    log(bWriteLog and "LogicPeakGameUtil.InitSmallPeakRankIntegralSwitchWidget no widget")
    return
  end
  local UIComponentModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.UIComponentModule)
  return UIComponentModule:InitWithParentComponent(base, UIComponentModule.Config.PeakGame_RankIntegralLevel_Small_Switch_UIBP, widget, config)
end
function LogicPeakGameUtil.InitLargePeakRankIntegralSwitchWidget(base, widget)
  log(bWriteLog and "LogicPeakGameUtil.InitLargePeakRankIntegralSwitchWidget")
  if not base or not widget then
    log(bWriteLog and "LogicPeakGameUtil.InitLargePeakRankIntegralSwitchWidget no widget")
    return
  end
  local UIComponentModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.UIComponentModule)
  return UIComponentModule:InitWithParentComponent(base, UIComponentModule.Config.PeakGame_RankIntegralLevel_Large_Switch_UIBP, widget)
end
function LogicPeakGameUtil.GetCurSelectZoneId()
  log(bWriteLog and "LogicPeakGameUtil.GetCurSelectZoneId")
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  local zone_id = ZoneSystem.nChooseZoneID
  log(bWriteLog and "LogicPeakGameUtil.GetCurSelectZoneId nChooseZoneID = " .. tostring(ZoneSystem.nChooseZoneID))
  if not zone_id or zone_id <= 0 then
    log(bWriteLog and "LogicPeakGameUtil.GetCurSelectZoneId no zone_id set zone_id = 1")
    zone_id = 1
  end
  log(bWriteLog and "LogicPeakGameUtil.GetCurSelectZoneId zone_id = " .. tostring(zone_id))
  return zone_id
end
function LogicPeakGameUtil.ConvertSegmentToIndex(segment)
  log(bWriteLog and "LogicPeakGameUtil:ConvertSegmentToIndex segment: " .. tostring(segment))
  local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
  for i = 1, #PeakGameConfig.LevelList do
    if PeakGameConfig.LevelList[i + 1] == nil then
      log(bWriteLog and "LogicPeakGameUtil:ConvertSegmentToIndex 1 PeakGameConfig.LevelList[i]: " .. tostring(PeakGameConfig.LevelList[i]))
      return PeakGameConfig.LevelList[i]
    end
    if segment >= PeakGameConfig.LevelList[i] and segment < PeakGameConfig.LevelList[i + 1] then
      log(bWriteLog and "LogicPeakGameUtil:ConvertSegmentToIndex 2 PeakGameConfig.LevelList[i]: " .. tostring(PeakGameConfig.LevelList[i]))
      return PeakGameConfig.LevelList[i]
    end
  end
end
return LogicPeakGameUtil