local GameReportUtils = {}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
function GameReportUtils.CheckCanBugglyPostException(ReportName)
  print(bWriteLog and "GameReportUtils:CheckCanBugglyPostException - ReportName:" .. tostring(ReportName))
  if Client and not Client.IsWindowOB() then
    local GameReportSubsystem = SubsystemMgr:Get("GameReportSubsystem")
    if GameReportSubsystem then
      return GameReportSubsystem:CheckCanBugglyPostException(ReportName)
    end
  end
  return false
end
function GameReportUtils.BugglyPostExceptionFull(ReportName, ReportString, bPrintLog, ReportInfo)
  print(bWriteLog and "GameReportUtils:BugglyPostExceptionFull - ReportName:" .. tostring(ReportName))
  if Client and not Client.IsWindowOB() then
    local GameReportSubsystem = SubsystemMgr:Get("GameReportSubsystem")
    if GameReportSubsystem then
      return GameReportSubsystem:BugglyPostExceptionFull(ReportName, ReportString, bPrintLog, ReportInfo)
    end
  end
  return false
end
function GameReportUtils.ReplayReportData(ID, Array)
  print(bWriteLog and "GameReportUtils:ReplayReportData - ID:" .. tostring(ID))
  local GameReportSubsystem = SubsystemMgr:Get("GameReportSubsystem")
  if GameReportSubsystem then
    return GameReportSubsystem:ReplayReportData(ID, Array)
  end
  return false
end
function GameReportUtils.ReportException(ErrorMsg, Category)
  Category = Category or 6
  LogExceptionAndReport(ErrorMsg, Category)
end
function GameReportUtils.GetReplayRecordManager()
  local uGameState = GameplayData:GetGameState()
  if slua.isValid(uGameState) then
    return uGameState.ReplayRecordManager
  end
end
function GameReportUtils.GetReplayRecorderByType(RecorderType)
  local ReplayRecordManager = GameReportUtils.GetReplayRecordManager()
  if slua.isValid(ReplayRecordManager) then
    return ReplayRecordManager:GetReplayRecorderByType(RecorderType)
  end
end
return GameReportUtils