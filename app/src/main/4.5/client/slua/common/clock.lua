local clock = {}
local clock_list = {}
local clock_index = 0
local TimeUtil = require("client.common.time_util")
function clock.Init(endTime, updateFunc, endFunc)
  local clock_data = {
    endTime = endTime,
    updateFunc = updateFunc,
    endFunc = endFunc,
    time_handle = nil
  }
  clock_index = clock_index + 1
  clock_data.handleID = clock_index
  clock_list[clock_index] = clock_data
  local time_ticker = require("common.time_ticker")
  clock_data.time_handle = time_ticker.AddTimer(0, function(deltaTime)
    clock._UpdateTime(clock_data)
  end)
  return clock_index
end
function clock.Release(handle)
  local clock_data = clock_list[handle]
  if nil ~= clock_data then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(clock_data.time_handle)
  end
  clock_list[handle] = nil
end
function clock._UpdateTime(clock_data)
  while true do
    local lackOfTime = clock_data.endTime - TimeUtil.GetServerTimeInSec()
    if lackOfTime <= 0 then
      if nil ~= clock_data.endFunc then
        clock_data.endFunc()
        clock.Release(clock_data.handleID)
        return
      end
    elseif nil ~= clock_data.updateFunc then
      clock_data.updateFunc(lackOfTime)
    end
    if 86461 < lackOfTime then
      coroutine.yield(60)
    else
      coroutine.yield(1)
    end
  end
end
return clock