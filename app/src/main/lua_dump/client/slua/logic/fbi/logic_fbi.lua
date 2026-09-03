local IsEditor = _G.IsEditor
local IsReleaseVersion = Client.IsReleaseVersion(NetInterface)
local EGMPhaseType = {
  CALL_HANDLE = 1,
  PRE_SEND_CMD = 2,
  SEND_CMD = 3
}
local FBI = {EGMPhaseType = EGMPhaseType}
function FBI.OnGameStateChange(eventType, eventID, vars)
end
function FBI.SendTLog(TLogType, str)
  local strRegion = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if IsReleaseVersion and strRegion ~= PublishRegionMacros.CE and strRegion ~= PublishRegionMacros.FITCE then
    return
  end
  if not LobbySystem.CheckOpen(20182) then
    return
  end
  if not str or str == "" or str == "0" then
    return
  end
  str = str .. "_" .. FBI.GetInfoString()
  local BasicDataTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataTLogReport)
  BasicDataTLogReport:ReportImmediate(TLogType, 0, str)
end
function FBI.SendReleaseVersionTLog(TLogType, str)
  log(bWriteLog and "FBI.SendReleaseVersionTLog TLogType = " .. tostring(TLogType) .. " str = " .. tostring(str))
  if not IsReleaseVersion then
    return
  end
  if not str or str == "" or str == "0" then
    return
  end
  str = str .. "_" .. FBI.GetInfoString()
  local BasicDataTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataTLogReport)
  BasicDataTLogReport:ReportImmediate(TLogType, 0, str)
  local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
  PufferTlog.SendTLog(PufferTlog.Enum_TLog_From.Illegal, PufferTlog.Enum_TLog_Optype.Finish, str)
  local gem_report_utils = require("client.logic.store.gem_report_utils")
  gem_report_utils.ReportEventImmediate(gem_report_utils.EventName_CommonEvent, gem_report_utils.SubEventName_FBI, str)
  gem_report_utils.ReportEventImmediate(gem_report_utils.EventName_LobbyEvent, gem_report_utils.SubEventName_FBI, str)
end
function FBI.GetInfoString()
  local str = ""
  local LobbyWaterMarkSystem = require("client.slua.logic.lobby_watermark.logic_lobby_watermark")
  local white = " NotWhite"
  if LobbyWaterMarkSystem.GetDevCloseWatermarkSwitch() then
    white = " White"
  end
  local curProductID = GCPufferDownloader.GetProductID(Puffer)
  local version = Client.GetApplicationVersion()
  local dev = "Dev"
  if not Client.IsDevelopment() then
    dev = "NotDev"
  end
  str = string.format("%s_%s_%s", white, version, dev)
  if curProductID and next(curProductID) then
    str = str .. "_" .. tostring(curProductID[1]) .. "_" .. tostring(curProductID[2])
  end
  return str
end
function FBI.IsIllegalTime(key)
  local RecommendHandler = require("client.slua.logic.download.recommend.logic_recommend_handler")
  if not key or key == "" then
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local result = false
  if RecommendHandler.PaksDownloadTime and RecommendHandler.PaksDownloadTime[key] and TimeUtil.GetServerTimeInSec() < RecommendHandler.PaksDownloadTime[key] then
    result = true
  end
  if result then
    FBI.ReportIllegalPreviewNew(key)
    if IsEditor then
      return false
    end
    local tLogType = TLogEventDefine.FBI_IllegalTime
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    strRegion = Client.GetPublishRegion()
    if strRegion == PublishRegionMacros.CE or strRegion == PublishRegionMacros.FITCE then
      tLogType = TLogEventDefine.FBI_CE_IllegalTime
    end
    FBI.SendTLog(tLogType, tostring(key))
    FBI.SendReleaseVersionTLog(tLogType, tostring(key))
    log(bWriteLog and "FBI.IsIllegalTime " .. tostring(key))
    if not IsReleaseVersion then
      ShowNotice(25720)
    end
    if IsReleaseVersion then
      local BusinessHelper = import("BusinessHelper")
      local extraInfoStr = FBI.GetExtraInfoForReport()
      gem_report_utils.ReportEventImmediate(gem_report_utils.EventName_CommonEvent, gem_report_utils.SubEventName_IllegalTimeDownload, tostring(key), BusinessHelper.GetOpenId(), Client.GetPhoneDeviceID(), extraInfoStr)
    end
  end
  return result
end
function FBI.GetExtraInfoForReport()
  local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
  local lobbyUrl = login_module:GetLobbyUrl() or "invalid"
  local pufferID = GCPufferDownloader.GetProductID(Puffer)
  local pufferIDStr
  if pufferID then
    pufferIDStr = table.concat(pufferID, ",")
  else
    pufferIDStr = "invalid"
  end
  local device_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.device_module)
  local DeviceName = device_module.sDeviceName
  local BusinessHelper = import("BusinessHelper")
  local extraInfoTable = {
    [1] = DataMgr.roleData.uid,
    [2] = lobbyUrl,
    [3] = pufferIDStr,
    [4] = BusinessHelper.GetOpenId(),
    [5] = FBI.GetDeviceTypeForReport(),
    [6] = Client.GetPhoneDeviceID(),
    [7] = DeviceName
  }
  local extraInfoStr = table.concat(extraInfoTable, "_")
  return extraInfoStr
end
function FBI.ReportGMUsing(Cmd, PhaseType)
  log(bWriteLog and string.format("FBI.ReportGMUsing. Cmd=%s, PhaseType=%s", tostring(Cmd), tostring(PhaseType)))
  if not Cmd or Cmd == "" then
    return false
  end
  local BusinessHelper = import("BusinessHelper")
  local extraInfoStr = FBI.GetExtraInfoForReport()
  local ReportCmd = string.gsub(tostring(Cmd), "%s", "+")
  gem_report_utils.ReportEventImmediate(gem_report_utils.EventName_CommonEvent, gem_report_utils.SubEventName_UseGMCmd, ReportCmd, BusinessHelper.GetOpenId(), Client.GetPhoneDeviceID(), extraInfoStr)
  FBI.ReportGMUsingTLog(Cmd, PhaseType)
end
function FBI.GetDeviceTypeForReport()
  if IsEditor then
    return "Editor"
  elseif Client.IsEmulator() then
    return "Emulator"
  end
  return Client.GetDevicePlatformName()
end
function FBI.ReportGMUsingTLog(Cmd, GMType)
  Cmd = Cmd or ""
  local GlobalNetHandler = require("client.network.Protocol.GlobalNetHandler")
  GlobalNetHandler.send_report_general_illegal_click_req(1, FBI.GetDeviceTypeForReport(), {
    GMType = GMType,
    GMExecuteDetail = string.sub(Cmd, 1, 64)
  })
end
function FBI.ReportIllegalPreviewNew(key)
  log(bWriteLog and string.format("FBI.ReportIllegalPreviewNew. key=%s", tostring(key)))
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  local CameraID = Lobby_camera_manager_module:GetCurrentCameraID() or 0
  local GlobalNetHandler = require("client.network.Protocol.GlobalNetHandler")
  GlobalNetHandler.send_report_general_illegal_click_req(2, FBI.GetDeviceTypeForReport(), {
    SceneType = CameraID,
    ItemIllegalPreview = string.sub(tostring(key), 1, 64)
  })
end
return FBI