LogUtil = LogUtil or {bLogCrashKitBluePrint = false}
local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local bIsDevelopment = USTExtraBlueprintFunctionLibrary.IsDevelopment()
local bForceLog = false
local bDSErrorReport = true
local local string_format = string.format
local local local local local local local log_filter = require("common.log_filter")
local InitLogPrefix = function()
  local LogPrefix
  if not Client and GameInstanceID == 0 then
    LogPrefix = "[Server]:"
  elseif Client and Client.IsEditorDedicatedServer() and GameInstanceID >= 1 then
    LogPrefix = string_format("[Client %d]:", GameInstanceID)
  end
  if LogPrefix then
    local FastLogInner = sandbox.FastLog
    if FastLogInner then
      function sandbox.FastLog(LogLevel, ...)
        FastLogInner(LogLevel, LogPrefix, ...)
      end
    end
  end
end
InitLogPrefix()
local FastLog2cpp = sandbox.FastLog
function sandbox.LogNormal(...)
  return FastLog2cpp(1, ...)
end
function sandbox.LogWarning(...)
  return FastLog2cpp(2, ...)
end
function sandbox.LogError(...)
  return FastLog2cpp(3, ...)
end
function sandbox.LogShippingClient(...)
  return FastLog2cpp(1, ...)
end
function sandbox.LogShippingDS(...)
  return FastLog2cpp(1, ...)
end
function sandbox.LogException(...)
  if IsEditor == true then
    local msg = table.concat({
      ...
    }) .. "\n"
    slua.OnLuaLogException(msg)
  else
    return FastLog2cpp(4, ...)
  end
end
local LogNormal = sandbox.LogNormal
local clientLogNew = function(...)
  if not bForceLog and not bIsDevelopment then
    return
  end
  return LogNormal(...)
end
local _ClientReport = function(msg, category)
  local utility = require("common.utility")
  if not utility.GetLimitStat(msg) then
    log_error("_ClientReport not report because limit stat msg:" .. msg)
    return
  end
  local func = function()
    if not msg then
      log_error("_ClientReport msg == nil")
      return
    end
    if msg == "" then
      log_error("_ClientReport msg == empty")
      return
    end
    Client.RecordLuaExceptionInfo(msg)
    sandbox.LogException(msg)
    require("client.config.pubgm_package")
    require("client.config.pubgm_patch")
    log(bWriteLog and "global_package_make_time:" .. global_package_make_time)
    log(bWriteLog and "global_patch_make_time:" .. global_patch_make_time)
    local ClientToolsReport = require("client.slua.logic.report.ClientToolsReport")
    ClientToolsReport:SendReport(ClientToolsReport.Enum_SvrReport_Type.Enum_Xpcall, msg, false, {category = category})
  end
  xpcall(func, function(newMsg)
    log_error(newMsg)
  end)
end
local _DSReport = function(msg)
  local func = function()
    if not msg then
      log_error("_DSReport msg == nil")
      return
    end
    if msg == "" then
      log_error("_DSReport msg == empty")
      return
    end
    local _msg = string.gsub(msg, "\\", "/")
    sandbox.LogException(_msg)
    local version = ""
    local PackageInfo = require("client.config.PackageInfo")
    if PackageInfo then
      version = PackageInfo.GetAssistInfoMsg()
    end
    print(bWriteLog and version, _msg)
    if NetUtil and bDSErrorReport then
      NetUtil.SendPacket("ds_err_report", version, _msg)
    end
  end
  xpcall(func, function(msg2)
    log_error(msg2)
  end)
end
function LogExceptionAndReport(msg, category)
  if Client then
    _ClientReport(msg, category)
  else
    _DSReport(msg)
  end
end
slua.AddExceptionCallback(function(msg)
  if Client then
    local ClientToolsReport = require("client.slua.logic.report.ClientToolsReport")
    local category = ClientToolsReport.Enum_CrashKit_Type.Enum_Lua
    _ClientReport(msg, category)
  else
    _DSReport(msg)
  end
end)
function LogUtil.SetDSErrorReportOpened(isOpen)
  bDSErrorReport = isOpen
  log(bWriteLog and string_format("SetDSErrorReportOpened %s", tostring(bDSErrorReport)))
end
function LogUtil.SetForceLog(isFilter)
  bForceLog = isFilter
end
if Client then
  _G.log = clientLogNew
  _G.print = clientLogNew
else
  _G.log = LogNormal
  _G.print = LogNormal
end
_G.log_shipping_client = sandbox.LogShippingClient
_G.log_warning = sandbox.LogWarning
_G.log_error = sandbox.LogError
function _G.assert_format(condition, formatStr, ...)
  if not condition then
    local msg = string_format(formatStr, ...)
    local utility = require("common.utility")
    utility.ErrorMessageHandler(msg)
    return false
  end
  return true
end
function _G.log_format(formatStr, ...)
  if not bWriteLog then
    return
  end
  log(bWriteLog and string_format(formatStr, ...))
end
function _G.log_warning_format(formatStr, ...)
  log_warning(string_format(formatStr, ...))
end
function _G.log_error_format(formatStr, ...)
  log_error(string_format(formatStr, ...))
end
function _G.printf(formatStr, ...)
  if not bWriteLog then
    return
  end
  log(bWriteLog and string_format(formatStr, ...))
end
function _G.logArray(name, array)
  if not bWriteLog then
    return
  end
  if type(array) == "table" then
    local s = table.concat(array, ", ")
    log_warning("  _G.logArray.  " .. s)
  elseif array then
    local s = ""
    for k, v in pairs(array) do
      s = s .. "k: " .. tostring(k) .. "v: " .. tostring(v)
    end
    log_warning("  _G.logArray. " .. tostring(name) .. s)
  end
end
local pcallOk, cpp_log_tree = pcall(require, "cpp_log_tree")
local log_tree_cpp
if pcallOk then
  log_tree_cpp = cpp_log_tree.log_tree
end
local LXLog_log_tree = function(varKey, varValue, extendedParams)
  if not bIsDevelopment then
    return
  end
  if not log_filter.bLogTreeEnable then
    return
  end
  if varValue == nil then
    print(bWriteLog and "log_tree varValue is nil")
    varValue = varKey
    varKey = tostring(varKey)
  end
  if log_tree_cpp then
    log_tree_cpp(varKey, varValue, extendedParams)
  end
end
_G.log_tree = LXLog_log_tree
require("common.traceback_util")