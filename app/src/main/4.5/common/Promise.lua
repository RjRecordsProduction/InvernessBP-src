local Promise = {}
Promise.__index = Promise
local Helper = {}
Promise.local local local local onreject = function(promise)
  if promise.__is_game_timer then
    Game:ClearTimer(promise.__is_game_timer)
    promise.__is_game_timer = nil
  end
  if promise.__is_lobby_timer then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(promise.__is_lobby_timer)
    promise.__is_lobby_timer = nil
  end
end
local handleFullfilledPromise = function(newPromise, resolveCallback, rejectCallback, ...)
  if type(resolveCallback) == "function" then
    local b, result = pcall(resolveCallback, ...)
    if b then
      if type(result) == "table" and result.__index == Promise then
        newPromise.__yield = result
        result:Then(function(...)
          newPromise:Resolve(...)
        end, function(reason)
          newPromise:Reject(reason)
        end)
      else
        newPromise:Resolve(result)
      end
    else
      newPromise:Reject(result)
    end
  else
    newPromise:Resolve(...)
  end
end
local handleRejectedPromise = function(newPromise, resolveCallback, rejectCallback, value)
  if type(rejectCallback) == "function" then
    local b, result = pcall(rejectCallback, value)
    newPromise:Reject(result)
  else
    newPromise:Reject(value)
  end
end
function Promise.new(resolveCallback, rejectCallback)
  local promise = setmetatable({}, Promise)
  promise.status = "pending"
  promise.value = nil
  promise.resolveCallbacks = nil
  promise.rejectCallbacks = nil
  if resolveCallback then
    promise.resolveCallbacks = {resolveCallback}
  end
  if rejectCallback then
    promise.rejectCallbacks = {rejectCallback}
  end
  return promise
end
function Promise.all(promises)
  local all = Promise.new()
  local results = {}
  local total = 0
  for _, v in pairs(promises) do
    if v then
      total = total + 1
    end
  end
  local count = 0
  for i, promise in pairs(promises) do
    if promise ~= nil then
      if promise.status == "fulfilled" then
        results[i] = promise.value or "nil"
        count = count + 1
      elseif promise.status == "rejected" then
        all:Reject(promise.value)
        break
      else
        promise:Then(function(v)
          count = count + 1
          results[i] = v or "nil"
          if count == total then
            all:Resolve(table.unpack(results))
          end
        end):Catch(function(reason)
          all:Reject(reason)
        end)
      end
    end
  end
  if count == total then
    all:Resolve(results)
  end
  return all
end
function Promise.any(promises)
  local any = Promise.new()
  local count = 0
  local rejectedCount = 0
  for _, promise in ipairs(promises) do
    if promise.status == "fulfilled" then
      print(bWriteLog and "[warning] Promise.any has a fulfilled promise")
    else
      promise:Then(function(...)
        any:Resolve(...)
      end):Catch(function(reason)
        rejectedCount = rejectedCount + 1
        if rejectedCount == #promises then
          any:Reject("All promises rejected")
        end
      end)
    end
  end
  return any
end
function Promise:Resolve(...)
  if self.status == "pending" then
    self.status = "fulfilled"
    self.value = (...)
    if self.resolveCallbacks then
      for _, callback in ipairs(self.resolveCallbacks) do
        callback(...)
      end
    end
    self.__is_game_timer = nil
    self.__is_lobby_timer = nil
  end
end
function Promise:DelayResolve()
  local time_ticker = require("common.time_ticker")
  time_ticker.AddTimerOnce(0, function()
    self:Resolve()
  end)
end
function Promise:Reject(reason)
  if self.status == "pending" then
    self.status = "rejected"
    self.value = reason
    if self.rejectCallbacks then
      for _, callback in ipairs(self.rejectCallbacks) do
        callback(reason)
      end
    end
    onreject(self)
  end
end
function Promise:Then(resolveCallback, rejectCallback)
  local newPromise = Promise.new()
  if self.status == "fulfilled" then
    handleFullfilledPromise(newPromise, resolveCallback, rejectCallback, self.value)
  elseif self.status == "rejected" then
    handleRejectedPromise(newPromise, resolveCallback, rejectCallback, self.value)
  elseif self.status == "pending" then
    self.resolveCallbacks = self.resolveCallbacks or {}
    table.insert(self.resolveCallbacks, function(...)
      handleFullfilledPromise(newPromise, resolveCallback, rejectCallback, ...)
    end)
    self.rejectCallbacks = self.rejectCallbacks or {}
    table.insert(self.rejectCallbacks, function(reason)
      handleRejectedPromise(newPromise, resolveCallback, rejectCallback, reason)
    end)
  end
  self.__next_chain = newPromise
  return newPromise
end
function Promise:Catch(rejectCallback)
  return self:Then(nil, rejectCallback)
end
function Promise:ClearCallbacks()
  self.resolveCallbacks = nil
  self.rejectCallbacks = nil
end
function Helper.IngameDelay(sec)
  local promise = Promise.new()
  local timer
  timer = Game:SetTimer(sec, false, function()
    promise:Resolve()
  end)
  promise.__is_game_  return promise
end
function Helper.IngameAwait(interval, condition)
  local promise = Promise.new()
  local timer
  timer = Game:SetTimer(interval, true, function()
    if condition() then
      promise:Resolve()
      Game:ClearTimer(timer)
    end
  end)
  print(bWriteLog and "IngameAwait __is_game_timer", timer, promise)
  promise.__is_game_  return promise
end
function Helper.LobbyDelay(sec)
  local promise = Promise.new()
  local time_ticker = require("common.time_ticker")
  local timer = time_ticker.AddTimerOnce(sec, function()
    promise:Resolve()
  end)
  promise.__is_lobby_  return promise
end
function Helper.LobbyAwait(interval, condition)
  local promise = Promise.new()
  local time_ticker = require("common.time_ticker")
  local timer
  timer = time_ticker.AddTimerLoop(0, function()
    if condition() then
      promise:Resolve()
      time_ticker.RemoveTimer(timer)
    end
  end, -1, interval)
  promise.__is_lobby_  return promise
end
function Helper.LobbyAwaitWithoutCond(time, callback)
  local promise = Promise.new(callback)
  if time then
    local time_ticker = require("common.time_ticker")
    local timer
    timer = time_ticker.AddTimerOnce(time, function()
      promise:Resolve()
    end)
    promise.__is_lobby_  end
  return promise
end
function Helper.MakeEventPromise(evtType, evtId)
  local promise = Promise.new()
  local func
  function func(...)
    EventSystem:unregistEvent(evtType, evtId, func)
    promise:Resolve(...)
  end
  EventSystem:registEvent(evtType, evtId, func)
  return promise
end
function Helper.MakeEventPromiseWithCondition(evtType, evtId, conditions)
  local promise = Promise.new()
  local func
  function func(...)
    if conditions(...) then
      EventSystem:unregistEvent(evtType, evtId, func)
      promise:Resolve(...)
    end
  end
  EventSystem:registEvent(evtType, evtId, func)
  return promise
end
function Promise:Cancel(reason)
  local p = self
  while p.__next_chain do
    if p.__next_chain.status == "pending" then
      p = p.__next_chain
      break
    end
    p = p.__next_chain
  end
  if p then
    if p.__yield then
      assert(p.__yield.status == "pending", "promise is not pending")
      p.__yield:Reject(reason)
    else
      error("promise should not pending")
    end
  end
end
return Promise