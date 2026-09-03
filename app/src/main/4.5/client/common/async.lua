local async = {}
local awaitHandle = {}
function async.Run(func, ...)
  local co = coroutine.create(func)
  local res, msg = coroutine.resume(co, co, ...)
  if not res then
    local utility = require("common.utility")
    utility.ErrorMessageHandlerCo(co, msg)
  end
  return co
end
function async.AwaitEvent(co, timeout, eventType, eventID)
  if not assert(type(co) == "thread" and type(eventType) == "number" and type(eventID) == "number", " async.AwaitEvent co should be thread,eventype should be number,eventID should be number") then
    return
  end
  require("client.common.event.EventProxy")
  local timeoutHandler, asyncFunc
  function asyncFunc(eventType, eventID, ...)
    if timeoutHandler then
      local time_ticker = require("common.time_ticker")
      time_ticker.RemoveTimer(timeoutHandler)
      timeoutHandler = nil
    end
    EventSystem:unregistEvent(eventType, eventID, asyncFunc)
    awaitHandle[co] = nil
    local res, msg = coroutine.resume(co, ...)
    if not res then
      local utility = require("common.utility")
      utility.ErrorMessageHandlerCo(co, msg)
    end
    if coroutine.status(co) == "dead" then
      awaitHandle[co] = nil
    end
  end
  EventSystem:registEvent(eventType, eventID, asyncFunc)
  awaitHandle[co] = {
    eventType,
    eventID,
    asyncFunc
  }
  if timeout then
    local time_ticker = require("common.time_ticker")
    timeoutHandler = time_ticker.AddTimer(timeout, function()
      EventSystem:unregistEvent(eventType, eventID, asyncFunc)
      awaitHandle[co] = nil
      local res, msg = coroutine.resume(co)
      if not res then
        local utility = require("common.utility")
        utility.ErrorMessageHandlerCo(co, msg)
      end
    end)
  end
  return coroutine.yield()
end
function async.Cancel(co)
  if awaitHandle[co] then
    local eventType, eventID, asyncFunc = table.unpack(awaitHandle[co])
    EventSystem:unregistEvent(eventType, eventID, asyncFunc)
    awaitHandle[co] = nil
  end
end
return async