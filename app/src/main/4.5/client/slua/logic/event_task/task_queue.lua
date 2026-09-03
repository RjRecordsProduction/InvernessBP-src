local task_queue = {}
local utility = require("common.utility")
local local local local getMicroseconds = slua.getMicroseconds
local string_format = string.format
function task_queue:ctor(_, name)
  self.  self.func2Task = {}
  self.pendingTaskFuncs = {}
  self.waitingTime = 2
end
function task_queue:Enqueue(task)
  local pendingTaskFuncs = self.pendingTaskFuncs
  local func2Task = self.func2Task
  local module = task.module
  local funcName = task.funcName
  local func = module[funcName]
  if func2Task[func] then
    local errorInfo = string_format("task_queue:Enqueued same function : module is [%s], function is [%s]", task.debugInfo, funcName)
    if task.protect then
      log_error(errorInfo)
    else
      utility.ErrorMessageHandler(errorInfo)
    end
    return
  end
  task.oFunc = func
  local hooked
  function hooked(...)
    if func2Task[hooked] then
      func2Task[hooked] = nil
      module[funcName] = func
      for i, v in ipairs(pendingTaskFuncs) do
        if v == hooked then
          table.remove(pendingTaskFuncs, i)
          break
        end
      end
      return func(...)
    else
      log_error(bWriteLog and "  task_queue:Enqueue same function : " .. tostring(task.debugInfo) .. funcName)
    end
  end
  func2Task[hooked] = task
  local num = #pendingTaskFuncs
  pendingTaskFuncs[num + 1] = hooked
  module[funcName] = hooked
  if num == 0 then
    self:DoTask()
  end
end
function task_queue:DoTask()
  log(bWriteLog and "task_queue:DoTask")
  local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
  if coroutine.isyieldable() then
    while Lobby_Main_City_Enter.bEnterMainCityLoading do
      log(bWriteLog and "task_queue:DoTask skip by enter maincity loading 1")
      coroutine.yield(self.waitingTime)
    end
  elseif Lobby_Main_City_Enter.bEnterMainCityLoading then
    log(bWriteLog and "task_queue:DoTask skip by enter maincity loading 2")
    self:AddTimer(self.waitingTime, function()
      self:DoTask()
    end)
    return
  end
  local pendingTaskFuncs = self.pendingTaskFuncs
  local func2Task = self.func2Task
  local _beginTime
  self:AddTimer(0, function()
    if Lobby_Main_City_Enter.bEnterMainCityLoading then
      log(bWriteLog and "task_queue:DoTask skip by enter maincity loading 3")
      coroutine.yield(self.waitingTime)
      self:DoTask()
      return
    end
    local _, func = next(pendingTaskFuncs)
    if not func then
      return
    end
    _beginTime = getMicroseconds()
    local task = func2Task[func]
    local Status, errorInfo = pcall(func, task.param)
    if not Status then
      utility.ErrorMessageHandler(string_format("task_queue run error[%s] function[%s] stack[%s]", task.debugInfo, task.funcName, errorInfo))
    end
    local _useTime = (getMicroseconds() - _beginTime) / 1000
    log(bWriteLog and "  task_queue:DoTask useTime:  " .. tostring(_useTime) .. " :  " .. string.format("%s.%s", task.debugInfo, task.funcName))
    coroutine.yield(_useTime * 0.004)
    self:DoTask()
  end)
end
function task_queue:ResetQueue()
  log(bWriteLog and "  task_queue:ResetQueue.  " .. tostring(self.name))
  self:Dispose()
  for _, t in pairs(self.func2Task) do
    t.module[t.funcName] = t.oFunc
  end
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
return class(CDelegateContainer, nil, task_queue)