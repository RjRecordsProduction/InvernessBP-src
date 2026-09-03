local logic_season_util = {}
local LobbyModUtils = require("GameLua.Mod.Lobby.Base.Common.LobbyModUtils")
local ModName_NewSeason = LobbyModUtils.Enum_Mod_Name.EName_NewSeason
function logic_season_util:GetCurrMaxSegmentByZoneId(zoneId, allZoneSegment)
  log(bWriteLog and "logic_season_util:GetCurrMaxSegmentByZoneId zoneId = " .. tostring(zoneId))
  log_tree("logic_season_util:GetCurrMaxSegmentByZoneId allZoneSegment = ", allZoneSegment)
  if not zoneId then
    return nil, nil, nil
  end
  if allZoneSegment == nil or not next(allZoneSegment) then
    return nil, nil, zoneId
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if Client and Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
    zoneId = 3
  else
    local logic_multiple_area = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_multiple_area)
    if logic_multiple_area:IsConnectToRussiaArea() then
      zoneId = 2
    end
  end
  local currZoneSegment = allZoneSegment[zoneId]
  if currZoneSegment == nil or not next(currZoneSegment) then
    return nil, nil, zoneId
  end
  local segmentTabs = {
    [1] = {
      type = enum_SegmentType.team,
      segment = currZoneSegment[enum_SegmentType.team] or 101
    },
    [2] = {
      type = enum_SegmentType.double,
      segment = currZoneSegment[enum_SegmentType.double] or 101
    },
    [3] = {
      type = enum_SegmentType.solo,
      segment = currZoneSegment[enum_SegmentType.solo] or 101
    },
    [4] = {
      type = enum_SegmentType.fpp_team,
      segment = currZoneSegment[enum_SegmentType.fpp_team] or 101
    },
    [5] = {
      type = enum_SegmentType.fpp_double,
      segment = currZoneSegment[enum_SegmentType.fpp_double] or 101
    },
    [6] = {
      type = enum_SegmentType.fpp_solo,
      segment = currZoneSegment[enum_SegmentType.fpp_solo] or 101
    }
  }
  local maxSegment = 101
  local maxMode = enum_SegmentType.team
  for key, value in pairs(segmentTabs) do
    if maxSegment < value.segment then
      maxSegment = value.segment
      maxMode = value.type
    end
  end
  log(bWriteLog and "logic_season_util:GetCurrMaxSegmentByZoneId maxSegment = " .. tostring(maxSegment) .. " maxMode = " .. tostring(maxMode) .. " zoneId = " .. tostring(zoneId))
  return maxSegment, maxMode, zoneId
end
function logic_season_util:GetCurrZoneMaxSegment(allZoneSegment)
  log(bWriteLog and "logic_season_util:GetCurrZoneMaxSegment")
  log_tree("logic_season_util:GetCurrZoneMaxSegment allZoneSegment = ", allZoneSegment)
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  local nChooseZoneID = ZoneSystem.nChooseZoneID
  log(bWriteLog and "logic_season_util:GetCurrZoneMaxSegment nChooseZoneID = " .. tostring(nChooseZoneID))
  if nChooseZoneID == 0 then
    nChooseZoneID = 1
  end
  local maxSegment, maxMode, zoneId = logic_season_util:GetCurrMaxSegmentByZoneId(nChooseZoneID, allZoneSegment)
  log(bWriteLog and "logic_season_util:GetCurrZoneMaxSegment maxSegment = " .. tostring(maxSegment) .. " maxMode = " .. tostring(maxMode) .. " zoneId = " .. tostring(zoneId))
  return maxSegment, maxMode, zoneId
end
function logic_season_util:GetCurrAllZoneMaxSegment(allZoneSegment)
  log(bWriteLog and "logic_season_util:GetCurrAllZoneMaxSegment")
  log_tree("logic_season_util:GetCurrAllZoneMaxSegment allZoneSegment = ", allZoneSegment)
  if allZoneSegment == nil or not next(allZoneSegment) then
    log(bWriteLog and "logic_season_util:GetCurrAllZoneMaxSegment allZoneSegment is invalid 1")
    return nil, nil, nil
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
    allZoneSegment = {
      [3] = allZoneSegment[3]
    }
  else
    local logic_multiple_area = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_multiple_area)
    if logic_multiple_area:IsConnectToRussiaArea() then
      allZoneSegment = {
        [2] = allZoneSegment[2]
      }
    end
  end
  if not allZoneSegment then
    log(bWriteLog and "logic_season_util:GetCurrAllZoneMaxSegment allZoneSegment is invalid 2")
    return nil, nil, nil
  end
  local maxSegment = -1
  local maxSegmentZoneId, maxSegmentModeId
  for zoneId, segInfo in pairs(allZoneSegment) do
    for modeId, segId in pairs(segInfo) do
      if segId > maxSegment then
        maxSegment = segId
        maxSegmentModeId = modeId
        maxSegmentZoneId = zoneId
      end
    end
  end
  log(bWriteLog and "logic_season_util:GetCurrAllZoneMaxSegment maxSegment = " .. tostring(maxSegment) .. " maxSegmentZoneId = " .. tostring(maxSegmentZoneId) .. " maxSegmentModeId = " .. tostring(maxSegmentModeId))
  return maxSegment, maxSegmentZoneId, maxSegmentModeId
end
function logic_season_util:GetSegmentDataByZoneId(zoneId)
  log(bWriteLog and "logic_season_util:GetSegmentDataByZoneId zoneId = " .. tostring(zoneId))
  if not zoneId then
    return nil
  end
  local allzoneSegment = DataMgr.roleData.allzoneSegment
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if not allzoneSegment then
    return nil
  end
  if Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE then
    return allzoneSegment[3]
  else
    local logic_multiple_area = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_multiple_area)
    if logic_multiple_area:IsConnectToRussiaArea() then
      return allzoneSegment[2]
    end
  end
  return allzoneSegment[zoneId]
end
function logic_season_util.IsModReady()
  return LobbyModUtils.IsModDownloaded(ModName_NewSeason)
end
function logic_season_util.CheckModWithFunc(callFun)
  if LobbyModUtils.IsModDownloaded(ModName_NewSeason) then
    if callFun then
      callFun()
    end
  else
    LobbyModUtils.DownloadMod(ModName_NewSeason, function()
      if callFun then
        callFun()
      end
    end)
  end
end
function logic_season_util.ShowUIWithModCheck(uiConfig, ...)
  local args = table.pack(...)
  if LobbyModUtils.IsModDownloaded(LobbyModUtils.Enum_Mod_Name.EName_NewSeason) then
    UIManager.ShowUI(uiConfig, table.unpack(args, 1, args.n))
  else
    LobbyModUtils.DownloadMod(LobbyModUtils.Enum_Mod_Name.EName_NewSeason, function()
      UIManager.ShowUI(uiConfig, table.unpack(args, 1, args.n))
    end)
  end
end
function logic_season_util.OpenClassicSeasonUI()
  local BusinessHelper = import("BusinessHelper")
  BusinessHelper.StartUIStat("\232\181\155\229\173\163")
  local SeasonSystem = require("client.logic.season.logic_season")
  local logic_season_switch_slap = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_season_switch_slap)
  if logic_season_switch_slap:TryShowSeasonSwitchSlapForReturner() then
    log(bWriteLog and "logic_season_util.OpenClassicSeasonUI show season switch slap for returner")
    return true
  end
  local SeasonVerCfg = CDataTable.GetTableData("SeasonVersion", DataMgr.season_id)
  local version_util = require("client.common.version_util")
  local _clientVersion3 = version_util.GetClientFormat(Client.GetAppVersion())
  if not SeasonVerCfg then
    return false
  end
  if SeasonVerCfg and version_util.CompareVersionStandard(_clientVersion3, SeasonVerCfg.MinVersion) < 0 then
    ShowNotice(9409)
    return false
  end
  local ClientVersion = Client.GetAppVersion()
  local season_year_util = require("client.logic.season_year.util.season_year_util")
  local seasonYearOpen = season_year_util.CheckFunctionIsOpen()
  log(bWriteLog and "[COLE]ClientVersion " .. tostring(ClientVersion) .. "  MinVersion " .. tostring(SeasonVerCfg.MinVersion) .. " MaxVersion " .. SeasonVerCfg.MaxVersion .. " DataMgr.season_id " .. DataMgr.season_id)
  if SeasonSystem.CheckShowSeasonGuide() then
    SeasonSystem.ShowSeasonGuide()
  else
    SeasonSystem.ShowSeasonHomepage()
  end
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.ClassicSeasonEntrance)
  BusinessHelper.StopUIStat("\232\181\155\229\173\163", true)
  return true
end
return logic_season_util