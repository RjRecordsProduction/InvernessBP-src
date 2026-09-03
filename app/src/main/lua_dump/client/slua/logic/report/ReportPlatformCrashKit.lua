local ReportPlatformCrashKit = {}
local TimeUtil = require("client.common.time_util")
function ReportPlatformCrashKit:Init()
  if self.bHasInit then
    return
  end
  self.bHasInit = true
  self.reportRate = 100
  self.switchKey = "XPCallReportCrashKit"
  self.whiteKey = "XPCallReportCrashKitWhite"
  self.battleKey = "XPCallReportCrashKitBattle"
  self.battleTraceKey = "XPCallReportCrashKitBattleTrace"
  local ToolReportUtil = require("client.slua.logic.report.ToolReportUtil")
  self.isWhite = ToolReportUtil:IsWhite(self.whiteKey)
  self.bSwitch = ToolReportUtil:GetReportSwitch(self.switchKey, self.reportRate)
  self.bOpenBattle = ToolReportUtil:IsXPcallOpenInBattle(self.battleKey)
  self.bOpenBattleTrace = ToolReportUtil:IsXPcallOpenInBattle(self.battleTraceKey)
  self.bReleaseVersion = ToolReportUtil:IsReleaseVersion()
  self.isEditor = Client and IsEditor
  self.isTest = Client and Client.IsTest and Client.IsTest()
  self.ReportCDTimeBattle = 15
  self.ReportCDTime = 3
  self.lastSendTime = 0
  self.bNoLimitTest = false
  self.TestTimer = nil
  local PackageInfo = require("client.config.PackageInfo")
  local GitInfo = PackageInfo.GetGitCommit()
  if GitInfo and GitInfo.GitEngine and GitInfo.GitEngine ~= "" and Client then
    Client.AddCrashContextData(1015, GitInfo.GitEngine, false, 100)
  end
  if GitInfo and GitInfo.GitSurvive and GitInfo.GitSurvive ~= "" and Client then
    Client.AddCrashContextData(1016, GitInfo.GitSurvive, false, 100)
  end
  if GitInfo and GitInfo.GitLua and GitInfo.GitLua ~= "" and Client then
    Client.AddCrashContextData(1017, GitInfo.GitLua, false, 100)
  end
  log(bWriteLog and string.format("ReportPlatformCrashKit.Init isWhite=%s isWhite=%s bOpenBattle=%s bOpenBattleTrace=%s", tostring(self.isWhite), tostring(self.bSwitch), tostring(self.bOpenBattle), tostring(self.bOpenBattleTrace)))
end
function ReportPlatformCrashKit:ReInit()
  self.bHasInit = false
  self:Init()
end
function ReportPlatformCrashKit:IsWhite()
  return self.isWhite
end
function ReportPlatformCrashKit:IsInCD()
  if not self.lastSendTime or self.lastSendTime <= 0 then
    return false
  end
  local CurTime = TimeUtil.GetServerTimeInSec()
  local CDTime = self.ReportCDTime
  if GameStatus.InCombatActiveState() then
    CDTime = self.ReportCDTimeBattle
  end
  local diffTime = CurTime - self.lastSendTime
  if CDTime > diffTime then
    log(bWriteLog and string.format("ReportPlatformCrashKit.IsInCD cd [%s] ", tostring(diffTime)))
    return true
  end
  return false
end
function ReportPlatformCrashKit:IsCanReport(bTrace)
  self:Init()
  if self.bNoLimitTest then
    log(bWriteLog and "ReportPlatformCrashKit:IsCanReport return bNoLimitTest is true ")
    return true
  end
  if self.isWhite then
    log(bWriteLog and "ReportPlatformCrashKit:IsCanReport return isWhite is true ")
    return true
  end
  if not self.bReleaseVersion then
    log(bWriteLog and "ReportPlatformCrashKit:IsCanReport return bReleaseVersion is false ")
    return true
  end
  if GlobalData.IsIOSCheck() then
    log(bWriteLog and "ReportPlatformCrashKit:IsCanReport return IsIOSCheck is true ")
    return true
  end
  if not self.bSwitch then
    log(bWriteLog and "ReportPlatformCrashKit:IsCanReport return bSwitch is false ")
    return false
  end
  if GameStatus.InCombatActiveState() then
    if not self.bOpenBattle then
      log(bWriteLog and "ReportPlatformCrashKit:IsCanReport return InCombatActiveState")
      return false
    end
    if bTrace then
      if self.bOpenBattleTrace then
        log(bWriteLog and "ReportPlatformCrashKit:IsCanTrace return bOpenBattleTrace is true ")
        return true
      end
      return false
    end
  end
  if self:IsInCD() then
    log(bWriteLog and "ReportPlatformCrashKit.IsCanReport return IsInCD is true ")
    return false
  end
  if Client.GetAndroidSOVersion() == 32 then
    log(bWriteLog and "ReportPlatformCrashKit.IsCanReport return Android so version is 32")
    return false
  end
  return true
end
function ReportPlatformCrashKit:Send(error, category)
  if not self:IsCanReport() then
    return false
  end
  self:_ConformSend(error, category)
end
function ReportPlatformCrashKit:SwitchLuaErrorTrace()
  local bCanTrace = self:IsCanReport(true)
  local StackLevel = not bCanTrace and 5 or 10
  slua.SetErrorTracebackLevel(StackLevel)
end
function ReportPlatformCrashKit:ForceSend(error, category)
  category = self:GetReportCategory(category)
  if Client and Client.CrashPostException and not self.isEditor then
    Client.CrashPostException(NetInterface, category, error)
    self:AddServerTimeToCrashContext(TimeUtil.GetServerTimeInSec())
  end
end
function ReportPlatformCrashKit:_ConformSend(error, category)
  category = self:GetReportCategory(category)
  if Client and Client.CrashPostException and not self.isEditor then
    Client.CrashPostException(NetInterface, category, error)
    self.lastSendTime = TimeUtil.GetServerTimeInSec()
    self:AddServerTimeToCrashContext(self.lastSendTime)
  end
end
function ReportPlatformCrashKit:SetXpcallLimit(isOpen)
  self.bNoLimitTest = isOpen
end
function ReportPlatformCrashKit:StartXPCallTest(bNoLimit)
  self.bNoLimitTest = bNoLimit or false
  self:StopXPCallTest()
  local time_ticker = require("common.time_ticker")
  self.TestTimer = time_ticker.AddTimerLoop(0, function()
    local a
    local b = a.b .. " "
  end, TIMER_INFINITE, 1)
end
function ReportPlatformCrashKit:StopXPCallTest()
  if self.TestTimer then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(self.TestTimer)
  end
  self.TestTimer = nil
end
function ReportPlatformCrashKit:GetOpenBattleTrace()
  return self.bOpenBattleTrace
end
function ReportPlatformCrashKit:AddServerTimeToCrashContext(time)
  if Client and time then
    local timeStr = TimeUtil.FormatTime_YMDHMS(time, true, true)
    Client.AddCrashContextData(1018, timeStr, false, 100)
  end
end
function ReportPlatformCrashKit:GetReportCategory(category)
  local ClientToolsReport = require("client.slua.logic.report.ClientToolsReport")
  category = category or ClientToolsReport.Enum_CrashKit_Type.Enum_Custom
  if category ~= ClientToolsReport.Enum_CrashKit_Type.Enum_JS and category ~= ClientToolsReport.Enum_CrashKit_Type.Enum_Lua then
    category = ClientToolsReport.Enum_CrashKit_Type.Enum_Custom
  end
  return category
end
return ReportPlatformCrashKit