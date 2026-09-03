local ToolReportUtil = {}
local VersionInfo
local MyOpenID = false
local MyUID = false
function ToolReportUtil:GetReportSwitch(switchKey, reportRate)
  local isReleaseVer = self:IsReleaseVersion()
  if not isReleaseVer then
    return true
  end
  local bSwitch = switchKey and HDmpveRemote.HDmpveRemoteConfigGetBool(switchKey, false)
  if bSwitch then
    reportRate = reportRate or 0
    local rand = math.random(0, reportRate)
    if rand <= 0 then
      return true
    end
  end
  return false
end
function ToolReportUtil:GetPackageInfo()
  if MyUID and MyOpenID and VersionInfo then
    return VersionInfo
  end
  local PackageInfo = require("client.config.PackageInfo")
  if not VersionInfo or VersionInfo == "" then
    VersionInfo = PackageInfo.GetAssistInfoMsg()
  end
  if not MyOpenID then
    local BusinessHelper = import("BusinessHelper")
    local openID = BusinessHelper and BusinessHelper.GetOpenId()
    if openID and tostring(openID) and tostring(openID) ~= "" then
      VersionInfo = PackageInfo.GetAssistInfoMsg()
      MyOpenID = openID
    end
  end
  if not MyUID then
    local uid = DataMgr and DataMgr.roleData and DataMgr.roleData.uid
    if uid and tostring(uid) and tostring(uid) ~= "" then
      VersionInfo = PackageInfo.GetAssistInfoMsg()
      MyUID = uid
    end
  end
  return VersionInfo
end
function ToolReportUtil:ReParseError(error, reportType)
  local ClientToolsReport = require("client.slua.logic.report.ClientToolsReport")
  if reportType == ClientToolsReport.Enum_SvrReport_Type.Enum_Capability and error and error ~= "" then
    local StringUtil = require("common.string_util")
    local list = StringUtil.Split(error, "@")
    if list and 1 < #list then
      error = "CollectName:[" .. list[1] .. "]|CollectTime:[" .. list[2] .. "]"
    end
  end
  return error
end
function ToolReportUtil:IsReleaseVersion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local isCE = PublishRegionMacros.IsCEVersion()
  return Client and NetInterface and Client.IsReleaseVersion(NetInterface) and not isCE
end
function ToolReportUtil:IsWhite(whiteKey)
  return whiteKey and HDmpveRemote.HDmpveRemoteConfigGetBool(whiteKey, false)
end
function ToolReportUtil:IsXPcallOpenInBattle(battleKey)
  return battleKey and HDmpveRemote.HDmpveRemoteConfigGetBool(battleKey, false)
end
function ToolReportUtil:IsClientToolOpen()
  local isWhite = self:IsWhite("ClientReportServerWhite")
  local bSwitch = self:GetReportSwitch("ClientReportServer", 100)
  return isWhite or bSwitch
end
return ToolReportUtil