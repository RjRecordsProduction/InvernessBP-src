local logic_home_proto_queue = {
  requestProtoMap = {},
  timeoutTimers = {}
}
function logic_home_proto_queue.sendRequest(reqFunc, msg, timeOut, ...)
  log(bWriteLog and "logic_home_proto_queue.sendRequest msg = " .. tostring(msg) .. " timeOut = " .. tostring(timeOut))
  if not msg then
    return
  end
  local requestProtoMap = logic_home_proto_queue.requestProtoMap
  if not requestProtoMap[msg] then
    requestProtoMap[msg] = {}
  end
  local requestArgs = {
    ...
  }
  local request = {
    reqFunc = reqFunc,
    timeOut = timeOut,
    args = requestArgs
  }
  table.insert(requestProtoMap[msg], request)
  if #requestProtoMap[msg] == 1 then
    logic_home_proto_queue.processRequest(reqFunc, msg, timeOut, ...)
  end
end
function logic_home_proto_queue.processRequest(reqFunc, msg, timeOut, ...)
  log(bWriteLog and "logic_home_proto_queue.processRequest msg = " .. tostring(msg) .. " timeOut = " .. tostring(timeOut))
  local timeoutTimers = logic_home_proto_queue.timeoutTimers
  local timer_tick = require("common.time_ticker")
  if timeoutTimers[msg] then
    timer_tick.RemoveTimer(timeoutTimers[msg])
    timeoutTimers[msg] = nil
  end
  timeoutTimers[msg] = timer_tick.AddTimerOnce(timeOut, function()
    logic_home_proto_queue.onResponseReceived(msg)
  end)
  if reqFunc then
    log(bWriteLog and "logic_home_proto_queue.processRequest sendRequest msg = " .. tostring(msg))
    reqFunc(msg, ...)
  end
end
function logic_home_proto_queue.onResponseReceived(msg)
  log(bWriteLog and "logic_home_proto_queue.onResponseReceived msg = " .. tostring(msg))
  if not msg then
    return
  end
  local requestProtoMap = logic_home_proto_queue.requestProtoMap
  if requestProtoMap[msg] and next(requestProtoMap[msg]) then
    table.remove(requestProtoMap[msg], 1)
    local timer_tick = require("common.time_ticker")
    if logic_home_proto_queue.timeoutTimers[msg] then
      timer_tick.RemoveTimer(logic_home_proto_queue.timeoutTimers[msg])
      logic_home_proto_queue.timeoutTimers[msg] = nil
    end
    local nextRequest = requestProtoMap[msg][1]
    if nextRequest then
      logic_home_proto_queue.processRequest(nextRequest.reqFunc, msg, nextRequest.timeOut, table.unpack(nextRequest.args))
    end
  end
end
return logic_home_proto_queue