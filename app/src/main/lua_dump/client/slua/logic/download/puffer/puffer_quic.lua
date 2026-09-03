local PufferErrorQuicStatus = require("client.slua.logic.download.puffer.puffer_define").PufferErrorQuicStatus
local puffer_quic = {}
function puffer_quic:OnDownloadReturn(taskId, isSuccess, errorCode)
  log(bWriteLog and "puffer_quic:OnDownloadReturn: " .. tostring(errorCode))
  if errorCode == PufferErrorQuicStatus.RollbackSucess or errorCode == PufferErrorQuicStatus.RunnableNoRollback or errorCode == PufferErrorQuicStatus.ErrorsAboveLimitRequiresRollback or errorCode == PufferErrorQuicStatus.SpeedBelowExpectationNeedsRollback then
    self:ReportQuicError(taskId, errorCode)
  end
end
function puffer_quic:ReportQuicError(taskId, errorCode)
  local IMSDKHelper = import("IMSDKHelper")
  local IMSDKHelperInstance = IMSDKHelper.GetInstance()
  local ParamTable = {}
  table.insert(ParamTable, tostring(taskId))
  table.insert(ParamTable, IMSDKHelperInstance:getOpenID())
  table.insert(ParamTable, tostring(errorCode))
  Client.GEMReportSubEvent(GameFrontendHUD, "GRomeLinkEvent", "PufferQuicStatus", ParamTable)
end
return puffer_quic