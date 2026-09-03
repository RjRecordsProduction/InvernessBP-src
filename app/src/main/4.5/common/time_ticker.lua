local time_ticker = {}
local STOP_TIME = -1
local NEXT_FRAME = -2
local MINIMUM_STEP_TIME = 0.011111111111111112
time_ticker.time_ticker.TIMER_INFINITE = 0
time_ticker.GFrameCount = 0
local UNINIT = -1
local prealloctable = prealloctable or function(n)
  return {}
end
local preallocNum = 16
local timerPool = prealloctable(preallocNum)
local preallocNumLoop = 128
local timerPoolLoop = prealloctable(preallocNumLoop)
local typeLoop = 1
local typeCoroutine = 2
local timerIndex = 0
local timers = {}
local FTimeTicker = FTimeTicker()
local bDebug = false
local string_format = string.format
local table_remove = table.remove
local table_insert = table.insert
local coroutine_yield = coroutine.yield
local coroutine_create = coroutine.create
local coroutine_resume = coroutine.resume
local local local local local local utility = require("common.utility")
local xpcallHandle = utility.ErrorMessageHandler
local xpcallHandleCo = utility.ErrorMessageHandlerCo
local local debugprint = function(msg)
  if bDebug then
    print(bWriteLog and msg)
  end
end
local ReleaseTimerToPool = function(timer, pool)
  timer.inUseFunc = nil
  table_insert(pool, timer)
  debugprint(bWriteLog and "time_ticker ReleaseTimerToPool timerIndex:" .. timer.index .. " size:" .. #pool .. " type:" .. timer.type == typeCoroutine and "timerPool" or "timerPoolLoop")
end
local GetNewTimer = function()
  return {
    inUseFunc = UNINIT,
    type = typeCoroutine,
    co = UNINIT,
    index = UNINIT,
    inner_yield = UNINIT
  }
end
local GetNewTimerLoop = function()
  return {
    inUseFunc = UNINIT,
    type = typeLoop,
    index = UNINIT,
    count = UNINIT,
    timeInterval = UNINIT
  }
end
local CreateCoroutineWithTimer = function(timer)
  local func = function(deltaTime)
    while true do
      timer.inner_yield = false
      timer.inUseFunc(deltaTime)
      timer.inner_yield = true
      ReleaseTimerToPool(timer, timerPool)
      deltaTime = coroutine_yield(STOP_TIME)
    end
  end
  local co = coroutine_create(func)
  timer.end
local GetTimer = function()
  if 0 < #timerPool then
    local timer = table_remove(timerPool)
    debugprint(bWriteLog and "time_ticker GetTimer reuse size:" .. #timerPool .. " last timerIndex:" .. timer.index)
    return timer
  end
  local timer = GetNewTimer()
  CreateCoroutineWithTimer(timer)
  debugprint(bWriteLog and "time_ticker GetTimer create")
  return timer
end
local GetTimerLoop = function()
  if 0 < #timerPoolLoop then
    local timer = table_remove(timerPoolLoop)
    debugprint(bWriteLog and "time_ticker GetTimerLoop reuse size:" .. #timerPoolLoop .. " last timerIndex:" .. timer.index)
    return timer
  end
  local timer = GetNewTimerLoop()
  debugprint(bWriteLog and "time_ticker GetTimerLoop create")
  return timer
end
local ResumeCoroutine = function(index, deltaTime)
  local timer = timers[index]
  if not timer then
    return STOP_TIME
  end
  if timer.type == typeCoroutine then
    local res, cycle = coroutine_resume(timer.co, deltaTime)
    if not res or type(cycle) ~= "number" then
      xpcallHandleCo(timer.co, cycle)
      timers[index] = nil
      return STOP_TIME
    end
    if cycle < 0 and cycle ~= NEXT_FRAME then
      debugprint(bWriteLog and "time_ticker ResumeCoroutine timerIndex:" .. timer.index)
      timers[index] = nil
    elseif 0 <= cycle and cycle < MINIMUM_STEP_TIME then
      cycle = MINIMUM_STEP_TIME
    end
    return cycle
  else
    local fun = timer.inUseFunc
    local cycle
    timer.count = timer.count - 1
    if timer.count == -1 then
      timer.count = timer.count + 1
      cycle = timer.timeInterval
    elseif 0 >= timer.count and timer.count ~= -1 then
      ReleaseTimerToPool(timer, timerPoolLoop)
      timers[index] = nil
      cycle = STOP_TIME
    else
      cycle = timer.timeInterval
    end
    xpcall(fun, xpcallHandle, deltaTime)
    return cycle
  end
end
function time_ticker.AddTimer(delay, func)
  if not assert(0 <= delay, "time_ticker.AddTimer delay >= 0") then
    return
  end
  if not assert(type(func) == "function", "time_ticker.AddTimer func must be function") then
    return
  end
  local timer = GetTimer()
  timerIndex = timerIndex + 1
  timer.index = timerIndex
  timer.inUseFunc = func
  FTimeTicker:AddTimer(timerIndex, delay)
  if IsEditor and bDebug then
    timer.stack = debug.traceback()
    debugprint(bWriteLog and "time_ticker AddTimer timerIndex:" .. timerIndex .. " timer.stack:" .. timer.stack)
  end
  timers[timerIndex] = timer
  return timerIndex
end
function time_ticker.AddImmediateTimer(func)
  local timer = GetTimer()
  timerIndex = timerIndex + 1
  timers[timerIndex] = timer
  timer.index = timerIndex
  timer.inUseFunc = func
  local thisTimerIndex = timerIndex
  local delay = ResumeCoroutine(timerIndex, 0)
  if not (delay < 0) or delay == NEXT_FRAME then
    FTimeTicker:AddTimer(thisTimerIndex, delay)
  end
  return thisTimerIndex
end
function time_ticker.AddTimerLoop(delay, func, count, timeInterval)
  if not assert(0 <= delay, "time_ticker.AddTimerLoop delay >= 0") then
    return
  end
  if not assert(type(count) == "number", "time_ticker.AddTimerLoop count must be number") then
    return
  end
  if not assert(type(timeInterval) == "number", "time_ticker.AddTimerLoop timeInterval must be number") then
    return
  end
  if not assert(0 <= timeInterval or timeInterval == NEXT_FRAME, "time_ticker.AddTimerLoop timeInterval must positive integer") then
    return
  end
  if not assert(type(func) == "function", "time_ticker.AddTimerLoop func must be function") then
    return
  end
  local timer = GetTimerLoop()
  timerIndex = timerIndex + 1
  timer.index = timerIndex
  if count < 0 then
    count = TIMER_INFINITE
  end
  timer.count = math.modf(count)
  if count ~= timer.count then
    debugprint(bWriteLog and "time_ticker AddTimerLoop timerIndex:" .. timerIndex .. " count:" .. count .. " timer.count:" .. timer.count)
  end
  if timeInterval == 0 then
    timeInterval = MINIMUM_STEP_TIME
  end
  timer.  timer.inUseFunc = func
  FTimeTicker:AddTimer(timerIndex, delay)
  if IsEditor and bDebug then
    timer.stack = debug.traceback()
    debugprint(bWriteLog and "time_ticker AddTimerLoop timerIndex:" .. timerIndex .. " timer.stack:" .. timer.stack)
  end
  timers[timerIndex] = timer
  return timerIndex
end
function time_ticker.AddTimerOnce(delay, func)
  return time_ticker.AddTimerLoop(delay, func, 1, NEXT_FRAME)
end
function time_ticker.RemoveTimer(timerIndex)
  if not assert(type(timerIndex) == "number", bWriteLog and string_format("RemoveTimer Argument timerIndex expect but got %s!", type(timerIndex))) then
    return
  end
  local timer = timers[timerIndex]
  if timer then
    debugprint(bWriteLog and "time_ticker RemoveTimer timerIndex:" .. timerIndex)
    if timer.type == typeCoroutine then
      if timer.inner_yield then
        ReleaseTimerToPool(timer, timerPool)
      elseif IsEditor and bDebug then
        log_error(bWriteLog and "time_ticker RemoveTimer timerIndex:" .. timerIndex .. " timer.stack:" .. timer.stack)
      end
    else
      ReleaseTimerToPool(timer, timerPoolLoop)
    end
  else
  end
  timers[timerIndex] = nil
end
function time_ticker.IsRunning(timerIndex)
  if not assert(type(timerIndex) == "number", string_format("IsRunning Argument timerIndex expect but got %s!", type(timerIndex))) then
    return false
  end
  return timers[timerIndex] ~= nil
end
local Init = function()
  FTimeTicker:SetTickFunction(ResumeCoroutine)
  function time_ticker.OnTick(deltaTime)
    time_ticker.GFrameCount = time_ticker.GFrameCount + 1
  end
  local game_frontend_hud = require("game_frontend_hud")
  game_frontend_hud.SetSluaTickListener(time_ticker.OnTick)
  local PreCacheCoroutine = function()
    for i = 1, preallocNum do
      local timer = GetNewTimer()
      timerPool[#timerPool + 1] = timer
      CreateCoroutineWithTimer(timer)
    end
    for i = 1, preallocNumLoop do
      local timer = GetNewTimerLoop()
      timerPoolLoop[#timerPoolLoop + 1] = timer
    end
  end
  PreCacheCoroutine()
end
Init()
return time_ticker