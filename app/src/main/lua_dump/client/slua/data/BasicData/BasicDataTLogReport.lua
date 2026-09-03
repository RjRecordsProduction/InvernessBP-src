local BasicDataTLogReport = {}
function BasicDataTLogReport:OnSendBatchReqMsg(ParamsList)
  if not ParamsList or type(ParamsList) ~= "table" or #ParamsList <= 0 then
    log_error("BasicDataTLogReport:OnSendBatchReqMsg ParamsList = nil ")
    return
  end
  local GlobalNetHandler = require("client.network.Protocol.GlobalNetHandler")
  GlobalNetHandler.send_batch_button_click_log(ParamsList)
end
function BasicDataTLogReport:OnImmediateReqMsg(TLogEventID, reason, reason_str)
  local ParamData = self:_GetParamData(TLogEventID, reason, reason_str)
  if ParamData then
    local ParamsList = {}
    table.insert(ParamsList, ParamData)
    self:OnSendBatchReqMsg(ParamsList)
  end
end
function BasicDataTLogReport:OnMergeReqMsg(TLogEventID, reason, reason_str)
  local ParamData = self:_GetParamData(TLogEventID, reason, reason_str)
  if ParamData then
    table.insert(self._batchReqKeyTable, ParamData)
  end
end
function BasicDataTLogReport:send_report_event_duration_log(event_type, duration_time)
  local GlobalNetHandler = require("client.network.Protocol.GlobalNetHandler")
  GlobalNetHandler.send_report_event_duration_log(event_type, duration_time)
end
function BasicDataTLogReport:_GetParamData(TLogEventID, reason, reason_str)
  if not TLogEventID or type(TLogEventID) ~= "number" or TLogEventID == 0 then
    log_error(bWriteLog and "BasicDataTLogReport._GetParamData error TLogEventID == " .. tostring(TLogEventID))
    return nil
  end
  local TimeUtil = require("client.common.time_util")
  local paramData = {
    TLogEventID = TLogEventID,
    reason = reason or 0,
    reason_str = reason_str or "",
    click_timestamp = TimeUtil.GetServerTimeInSec()
  }
  return paramData
end
local class = require("class")
local CModuleBase = require("client.slua.data.BasicData.BaseClass.BasicDataReport")
local CBasicDataTLogReport = class(CModuleBase, nil, BasicDataTLogReport)
return CBasicDataTLogReport