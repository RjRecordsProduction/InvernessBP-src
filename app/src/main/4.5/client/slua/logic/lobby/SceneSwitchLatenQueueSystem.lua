local SceneSwitchLatenQueueSystem = {}
function SceneSwitchLatenQueueSystem:DefineAndResetData()
  self.lobbyQueue = {}
  self.ingameQueue = {}
  self.bHasStoreData = false
end
function SceneSwitchLatenQueueSystem:BeginLobbyQueue()
  log(bWriteLog and " SceneSwitchLatenQueueSystem:BeginLobbyQueue")
  if #self.lobbyQueue == 0 then
    return
  end
  local interval = 0.1
  while #self.lobbyQueue > 0 do
    interval = interval + 0.1
    local q = table.remove(self.lobbyQueue, 1)
    self:AddTimerOnce(interval, function()
      q.func()
    end)
  end
end
function SceneSwitchLatenQueueSystem:BeginIngameQueue()
  log(bWriteLog and "SceneSwitchLatenQueueSystem:BeginIngameQueue")
  if #self.ingameQueue == 0 then
    log(bWriteLog and "SceneSwitchLatenQueueSystem:BeginIngameQueue empty")
    return
  end
  local interval = 0.1
  while #self.ingameQueue > 0 do
    interval = interval + 0.1
    local q = table.remove(self.ingameQueue, 1)
    self:AddTimerOnce(interval, function()
      q.func()
    end)
  end
end
function SceneSwitchLatenQueueSystem:EnqueueLobby(func, kwargs)
  log(bWriteLog and "SceneSwitchLatenQueueSystem:EnqueueLobby")
  if self:IsExist(self.lobbyQueue, func) then
    log(bWriteLog and "SceneSwitchLatenQueueSystem:EnqueueLobby Exist")
    return
  end
  table.insert(self.lobbyQueue, {func = func, kwargs = kwargs})
end
function SceneSwitchLatenQueueSystem:EnqueueIngame(func, kwargs)
  log(bWriteLog and "SceneSwitchLatenQueueSystem:EnqueueIngame")
  if self:IsExist(self.ingameQueue, func) then
    log(bWriteLog and "SceneSwitchLatenQueueSystem:EnqueueIngame Exist")
    return
  end
  table.insert(self.ingameQueue, {func = func, kwargs = kwargs})
end
function SceneSwitchLatenQueueSystem:HasLobbyQueueLimitFaceSlap()
  if #self.lobbyQueue == 0 then
    return false
  end
  for _, v in ipairs(self.lobbyQueue) do
    if v.kwargs and v.kwargs.blockSlap then
      return true
    end
  end
  return false
end
function SceneSwitchLatenQueueSystem:IsExist(queue, func)
  if #queue == 0 then
    return false
  end
  for _, v in ipairs(queue) do
    if v.func and v.func == func then
      return true
    end
  end
  return false
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CSceneSwitchLatenQueueSystem = class(CModuleBase, nil, SceneSwitchLatenQueueSystem)
return CSceneSwitchLatenQueueSystem