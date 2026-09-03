local Utility = {
  MinInterval = 1,
  MaxInterval = 2,
  LimitCache = {},
  PreReportTime = 0,
  FirstReportTime = 0
}
local TimeUtil = require("client.common.time_util")
local local local local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local IsDevelopment = USTExtraBlueprintFunctionLibrary.IsDevelopment()
local 
function Utility.GetLimitStat(msg)
  if IsDevelopment then
    return true
  end
  local cur_time
  local success, result = pcall(TimeUtil.GetServerTimeInSec)
  if success then
    cur_time = result
  else
    cur_time = os.time()
    log_error("GetServerTimeInSec failed, using local time: " .. tostring(result))
  end
  if Utility.PreReportTime > 0 and cur_time - Utility.PreReportTime <= Utility.MinInterval then
    return false
  end
  if 0 < Utility.FirstReportTime and cur_time - Utility.FirstReportTime > Utility.MaxInterval then
    Utility.LimitCache = {}
  end
  local pre = Utility.LimitCache[msg]
  if pre and 0 < pre then
    return false
  end
  Utility.PreReportTime = cur_time
  if not next(Utility.LimitCache) then
    Utility.FirstReportTime = cur_time
  end
  Utility.LimitCache[msg] = cur_time
  return true
end
function Utility.IsReleaseVersion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  return IsShipping and globalConfig and globalConfig.IsDirectConnect() and not PublishRegionMacros.IsCEVersion()
end
Utility.ErrorMessageReporting_SampleRate = 40
Utility.ErrorMessageReporting_MinInterval = 1000
Utility.ErrorMessageReporting_LastTime = 0
function Utility.ErrorMessageReporting(sMsg, nXpcallDepth, nScriptReportingTime)
  local bRandomHit = math.random(Utility.ErrorMessageReporting_SampleRate) == 1
  local nNow = TimeUtil.GetMiliseconds()
  local bTimeHit = nNow - Utility.ErrorMessageReporting_LastTime >= Utility.ErrorMessageReporting_MinInterval
  if not bRandomHit and not bTimeHit then
    return
  end
  Utility.ErrorMessageReporting_LastTime = nNow
  local ClientToolsReport = require("client.slua.logic.report.ClientToolsReport")
  local tCustomData = {
    nXpcallDepth = nXpcallDepth or 0,
    nScriptReportingTime = nScriptReportingTime or 0
  }
  log(bWriteLog and "Utility.ErrorMessageReporting sMsg = " .. sMsg)
  Utility.ErrorMessageHandlerWithCustomData(sMsg, ClientToolsReport.Enum_CrashKit_Type.Enum_Lua, tCustomData)
end
function Utility.ErrorMessageHandler(msg, category)
  if not Utility.GetLimitStat(msg) then
    log_error("Utility.ErrorMessageHandler not report because limit stat msg:" .. msg)
    return
  end
  local ReportPlatformCrashKit = require("client.slua.logic.report.ReportPlatformCrashKit")
  if ReportPlatformCrashKit:IsCanReport(true) then
    local traceback_util = require("common.traceback_util")
    msg = traceback_util.OriginalTraceBack(msg)
  end
  local ClientToolsReport = require("client.slua.logic.report.ClientToolsReport")
  category = category or ClientToolsReport.Enum_CrashKit_Type.Enum_Lua
  LogExceptionAndReport(msg, category)
end
function Utility.ErrorMessageHandlerExtra(msg, category, extra)
  if not Utility.GetLimitStat(msg) then
    log_error("Utility.ErrorMessageHandler not report because limit stat msg:" .. msg)
    return
  end
  local ReportPlatformCrashKit = require("client.slua.logic.report.ReportPlatformCrashKit")
  if ReportPlatformCrashKit:IsCanReport(true) then
    local traceback_util = require("common.traceback_util")
    msg = traceback_util.OriginalTraceBack(msg)
  end
  msg = msg .. extra
  local ClientToolsReport = require("client.slua.logic.report.ClientToolsReport")
  category = category or ClientToolsReport.Enum_CrashKit_Type.Enum_Lua
  LogExceptionAndReport(msg, category)
end
function Utility.ErrorMessageHandlerCo(co, msg, category)
  if not Utility.GetLimitStat(msg) then
    log_error("Utility.ErrorMessageHandlerCo not report because limit stat msg:" .. msg)
    return
  end
  local ReportPlatformCrashKit = require("client.slua.logic.report.ReportPlatformCrashKit")
  if ReportPlatformCrashKit:IsCanReport(true) then
    local traceback_util = require("common.traceback_util")
    msg = traceback_util.OriginalTraceBack(co, msg)
  end
  local ClientToolsReport = require("client.slua.logic.report.ClientToolsReport")
  category = category or ClientToolsReport.Enum_CrashKit_Type.Enum_Lua
  LogExceptionAndReport(msg, category)
end
function Utility.ErrorMessageHandlerWithCustomData(msg, category, customData)
  if not Client then
    return false
  end
  msg = tostring(msg or "")
  if msg == "" then
    log_error("Utility.ErrorMessageHandlerWithCustomData msg is empty, skip")
    return false
  end
  if not Utility.GetLimitStat(msg) then
    log_error("Utility.ErrorMessageHandlerWithCustomData not report because limit stat msg:" .. msg)
    return false
  end
  local ReportPlatformCrashKit = require("client.slua.logic.report.ReportPlatformCrashKit")
  if ReportPlatformCrashKit:IsCanReport(true) then
    local traceback_util = require("common.traceback_util")
    msg = traceback_util.OriginalTraceBack(msg)
  end
  local ClientToolsReport = require("client.slua.logic.report.ClientToolsReport")
  category = tonumber(category) or ClientToolsReport.Enum_CrashKit_Type.Enum_Lua
  local nCustomDataKeyCnt = 0
  if customData then
    for _ in pairs(customData) do
      nCustomDataKeyCnt = nCustomDataKeyCnt + 1
    end
  end
  log(bWriteLog and string.format("Utility.ErrorMessageHandlerWithCustomData msg=%s category=%d customDataKeyCnt=%d", msg, category, nCustomDataKeyCnt))
  return ReportPlatformCrashKit:SendWithCustomData(msg, category, customData) ~= false
end
function Utility.CreateDelegateContainer(module)
  local CDelegateContainer = require("common.delegate_container")
  local delegateContainer = CDelegateContainer()
  if module.delegateContainer and module.UnregistControlEvent then
    module.UnregistControlEvent()
  end
  module.  return delegateContainer
end
function Utility._CreateDelegateContainerWithName(module, delegateContainerName)
  local CDelegateContainer = require("common.delegate_container")
  local delegateContainer = CDelegateContainer()
  if module[delegateContainerName] then
    module[delegateContainerName]:Dispose()
  end
  module[delegateContainerName] = delegateContainer
  return delegateContainer
end
function Utility.DisposeDelegateContainer(module)
  if module.delegateContainer then
    module.delegateContainer:Dispose()
    module.delegateContainer = nil
  end
end
function Utility.GetOrCreateDelegateContainerWithName(module, delegateContainerName)
  if module[delegateContainerName] then
    return module[delegateContainerName]
  end
  return Utility._CreateDelegateContainerWithName(module, delegateContainerName)
end
function Utility.DisposeDelegateContainerWithName(module, delegateContainerName)
  if module[delegateContainerName] then
    module[delegateContainerName]:Dispose()
    module[delegateContainerName] = nil
    return true
  end
  return false
end
function Utility.GetGameInstanceSubsystemByName(SubsystemName)
  if Utility._inErrorHandling then
    return nil
  end
  Utility._inErrorHandling = true
  local success, SubsystemClass = pcall(import, SubsystemName)
  if not success then
    Utility._inErrorHandling = false
    return nil
  end
  local success2, SubsystemBlueprintLibrary = pcall(import, "SubsystemBlueprintLibrary")
  if not success2 then
    Utility._inErrorHandling = false
    return nil
  end
  local Subsystem = SubsystemBlueprintLibrary.GetGameInstanceSubsystem(slua.getGameInstance(), SubsystemClass)
  Utility._inErrorHandling = false
  return Subsystem
end
function Utility.GetWorldSubsystemByName(SubsystemName)
  local SubsystemClass = import(SubsystemName)
  local SubsystemBlueprintLibrary = import("SubsystemBlueprintLibrary")
  local Subsystem = SubsystemBlueprintLibrary.GetWorldSubsystem(slua.getWorld(), SubsystemClass)
  return Subsystem
end
return Utility