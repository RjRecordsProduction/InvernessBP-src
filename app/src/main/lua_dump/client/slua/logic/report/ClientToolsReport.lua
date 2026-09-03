local ClientToolsReport = {}
ClientToolsReport.Enum_SvrReport_Type = {
  Enum_Xpcall = 1,
  Enum_Capability = 2,
  Enum_Vehicle = 3,
  Enum_Memory = 4,
  Enum_SyncLoadAsset = 5,
  Enum_InterfaceConfig = 6
}
ClientToolsReport.Enum_CrashKit_Type = {
  Enum_None = 1,
  Enum_Native = 2,
  Enum_Custom = 3,
  Enum_ANR = 4,
  Enum_JS = 5,
  Enum_Lua = 6
}
local bInited = false
function ClientToolsReport:Init()
  if GameStatus.GetGameStatus() == GameStatus.None then
    return
  end
  if bInited then
    return
  end
  local ReportPlatformCrashKit = require("client.slua.logic.report.ReportPlatformCrashKit")
  ReportPlatformCrashKit:Init()
  local BasicDataClientReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataClientReport)
  BasicDataClientReport:Init()
  bInited = true
  EventSystem:registEvent(EVENTTYPE_LOGIN, EVENTID_LOGIN_SUCCESS, self.ReInit)
end
function ClientToolsReport:ReInit()
  local ReportPlatformCrashKit = require("client.slua.logic.report.ReportPlatformCrashKit")
  ReportPlatformCrashKit:ReInit()
  local BasicDataClientReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataClientReport)
  BasicDataClientReport:ReInit()
end
function ClientToolsReport:SendReport(ReportType, Error_Str, IsImmediateReport, extraData)
  if not Error_Str or Error_Str == "" then
    log(bWriteLog and string.format("ClientToolsReport:SendReport return type[%s], error is nil ", tostring(ReportType)))
    return
  end
  if not Client then
    log(bWriteLog and string.format("ClientToolsReport:SendReport return type[%s], not Client ", tostring(ReportType)))
    return
  end
  self:Init()
  if not bInited then
    log(bWriteLog and string.format("ClientToolsReport:SendReport return type[%s], not bInited ", tostring(ReportType)))
    return
  end
  if ReportType == ClientToolsReport.Enum_SvrReport_Type.Enum_Xpcall then
    local ReportPlatformCrashKit = require("client.slua.logic.report.ReportPlatformCrashKit")
    ReportPlatformCrashKit:Send(Error_Str, extraData and extraData.category)
    return
  end
  local BasicDataClientReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataClientReport)
  if IsImmediateReport then
    BasicDataClientReport:ReportImmediate(ReportType, Error_Str)
  else
    BasicDataClientReport:ReportDelay(ReportType, Error_Str)
  end
end
return ClientToolsReport