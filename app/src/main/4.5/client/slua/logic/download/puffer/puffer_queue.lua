local puffer_queue = {
  downloadingPaks = {},
  smallPakFirstQueue = {},
  smallPakSecondQueue = {},
  bigPakQueue = {},
  mergeTasks = {},
  waitTasks = {},
  stacks = {
    [11] = {},
    [12] = {},
    [21] = {}
  },
  downloadingSizes = {
    [11] = {curSize = 0, maxSize = 10},
    [12] = {curSize = 0},
    [21] = {curSize = 0, maxSize = 1}
  },
  downloadingCurSize = 0,
  downloadingMaxSize = 11,
  Download11MaxSize = nil
}
local globalTaskIndex = 0
local PufferConst = require("client.slua.logic.download.puffer_const")
function puffer_queue:StartDownload()
  if PufferDownloader.outputDownloadStack then
    return
  end
  while self.downloadingCurSize < self.downloadingMaxSize do
    local task = self:Pop()
    if not task then
      if self.downloadingCurSize == 0 then
        EventSystem:postEvent(EVENTTYPE_PUFFER, EVENTID_PUFFERQUEUE_CLEAR)
      end
      return
    end
    local taskID = PufferDownloader.RequestFile(GameFrontendHUD, task.pakName, task.forceUpdate, task.downloadType)
    if 0 < taskID then
      task.      self.downloadingPaks[task.pakName] = task
      self.downloadingCurSize = self.downloadingCurSize + 1
      self.downloadingSizes[task.stackType].curSize = self.downloadingSizes[task.stackType].curSize + 1
    end
  end
end
function puffer_queue:Push(task, bErased)
  local pakName = task.pakName
  if not pakName or pakName == "" then
    return
  end
  if self.downloadingPaks[pakName] then
    return
  end
  if not bErased and PufferDownloader.outputDownloadStack then
    log_format("puffer_queue:Push. pakName=%s, trace=%s", pakName, debug.traceback())
  end
  local eraseTask = self:Erase(pakName, nil, bErased)
  if eraseTask then
    self:SetTask(eraseTask, task)
    task = eraseTask
  end
  if task.bFirst and not bErased then
    self:PauseTasksBybFirst()
  end
  local stack, stackType
  if task.downloadType == PufferConst.ENUM_DownloadType.MAP or task.downloadType == PufferConst.ENUM_DownloadType.RES then
    stack = self.stacks[21]
    stackType = 21
  elseif task.bFirst then
    stack = self.stacks[11]
    stackType = 11
  else
    stack = self.stacks[12]
    stackType = 12
  end
  globalTaskIndex = globalTaskIndex + 1
  task.index = globalTaskIndex
  task.  table.insert(stack, task)
  self.waitTasks[task.pakName] = task
end
function puffer_queue:Pop()
  local task, stackType
  if #self.stacks[11] > 0 and self.downloadingSizes[11].curSize + self.downloadingSizes[12].curSize < self.downloadingSizes[11].maxSize then
    stackType = 11
  elseif 0 < #self.stacks[21] and self.downloadingSizes[21].curSize < self.downloadingSizes[21].maxSize then
    stackType = 21
  elseif 0 < #self.stacks[12] and self.downloadingSizes[11].curSize + self.downloadingSizes[12].curSize < self.downloadingSizes[11].maxSize then
    stackType = 12
  end
  if stackType then
    local len = #self.stacks[stackType]
    task = self.stacks[stackType][len]
    table.remove(self.stacks[stackType], len)
    self.waitTasks[task.pakName] = nil
  end
  return task
end
function puffer_queue:Clear()
  for pakName, v in pairs(self.downloadingPaks) do
    self:EraseDownloadingTask(pakName)
  end
  self.waitTasks = {}
  self.stacks = {
    [11] = {},
    [12] = {},
    [21] = {}
  }
  self.downloadingSizes = {
    [11] = {curSize = 0, maxSize = 10},
    [12] = {curSize = 0},
    [21] = {curSize = 0, maxSize = 1}
  }
  self.downloadingPaks = {}
  self.smallPakFirstQueue = {}
  self.smallPakSecondQueue = {}
  self.bigPakQueue = {}
  self.downloadingCurSize = 0
end
function puffer_queue:GetTask(pakName)
  return self:GetDownloadingTask(pakName) or self:GetWaitTask(pakName)
end
function puffer_queue:GetMergeTask(pakName)
  local task = self.mergeTasks[pakName]
  if task then
    log(bWriteLog and "puffer_queue:GetMergeTask remove " .. tostring(pakName))
    self.mergeTasks[pakName] = nil
  end
  return task
end
function puffer_queue:GetDownloadingTask(pakName)
  return self.downloadingPaks[pakName]
end
function puffer_queue:CheckAutoDownloadTask(pakName)
  if not pakName then
    return false
  end
  if self.downloadingPaks[pakName] then
    return self.downloadingPaks[pakName].bAutoDownload
  elseif self.waitTasks[pakName] then
    return self.waitTasks[pakName].bAutoDownload
  end
  return false
end
function puffer_queue:PauseTasksBybFirst()
  if not self.downloadingPaks or not next(self.downloadingPaks) then
    log(bWriteLog and "puffer_queue:PauseTasksBybFirst return downloadingPaks is nil")
    return
  end
  local curSize = self.downloadingSizes[11].curSize + self.downloadingSizes[12].curSize
  local maxSize = self.downloadingSizes[11].maxSize
  if curSize < maxSize then
    log(bWriteLog and string.format("puffer_queue:PauseTasksBybFirst return curSize(%s) < maxSize(%s)", tostring(curSize), tostring(maxSize)))
    return
  end
  local targetTask11, targetTask12
  for pakName, task in pairs(self.downloadingPaks) do
    if task.stackType == 11 then
      if not targetTask11 or task.taskID < targetTask11.taskID then
        targetTask11 = task
      end
    elseif task.stackType == 12 and (not targetTask12 or task.taskID < targetTask12.taskID) then
      targetTask12 = task
    end
  end
  local tmpTask = targetTask12 or targetTask11
  if tmpTask then
    self:EraseDownloadingTask(tmpTask.pakName, true, true)
  else
  end
end
function puffer_queue:_RemoveFromStack(task)
  if not (task and task.stackType) or not task.index then
    return false
  end
  local list = self.stacks[task.stackType]
  if not list then
    return false
  end
  local startIndex = 1
  local endIndex = #list
  while startIndex <= endIndex do
    local searchIndex = (startIndex + endIndex) // 2
    if list[searchIndex].index == task.index then
      table.remove(list, searchIndex)
      return true
    elseif list[searchIndex].index < task.index then
      startIndex = searchIndex + 1
    else
      endIndex = searchIndex - 1
    end
  end
  return false
end
function puffer_queue:ClearFirstTask()
  if #self.stacks[11] <= 0 then
    return
  end
  for i = 1, #self.stacks[11] do
    local task = self.stacks[11][i]
    if task and task.bFirst then
      task.bFirst = nil
      self:Push(task)
    end
  end
end
function puffer_queue:GetWaitTask(pakName)
  return self.waitTasks[pakName]
end
function puffer_queue:GetDownloadingCnt()
  return self.downloadingCurSize
end
function puffer_queue:SetTask(oldTask, newTask)
  if not oldTask or not newTask then
    return
  end
  local preItemID = oldTask.itemID or 0
  if preItemID == 0 and newTask.itemID and newTask.itemID > 0 then
    oldTask.itemID = newTask.itemID
  end
  oldTask.bFirst = oldTask.bFirst or newTask.bFirst
end
function puffer_queue:Erase(pakName, bWait, bErased)
  if not bErased then
    self:EraseDownloadingTask(pakName, bWait)
  end
  if bWait then
    return
  end
  return self:_RemoveWaitStackTask(pakName)
end
function puffer_queue:_RemoveWaitStackTask(pakName)
  local task = self.waitTasks[pakName]
  if not task then
    return nil
  end
  local found = self:_RemoveFromStack(task)
  if not found then
    log_warning("puffer_queue:_RemoveWaitStackTask not found pakName=" .. tostring(pakName))
  end
  self.waitTasks[pakName] = nil
  return task
end
function puffer_queue:EraseByPaks(paks)
  if not paks or not next(paks) then
    return
  end
  for pakName, _ in pairs(paks) do
    self:_RemoveWaitStackTask(pakName)
  end
  for pakName, v in pairs(self.downloadingPaks) do
    if paks[pakName] then
      self:EraseDownloadingTask(pakName)
    end
  end
end
function puffer_queue:GetDownloadingMapOrResTask()
  for _, task in pairs(self.downloadingPaks) do
    local downloadType = task.downloadType
    if downloadType == PufferConst.ENUM_DownloadType.MAP or downloadType == PufferConst.ENUM_DownloadType.RES then
      return task
    end
  end
  return nil
end
function puffer_queue:EraseDownloadingTask(pakName, bWait, bErased)
  local task = self.downloadingPaks[pakName]
  if task then
    if task.taskID > 0 then
      PufferDownloader.StopTask(GameFrontendHUD, task.taskID)
    end
    self.downloadingPaks[pakName] = nil
    self.downloadingSizes[task.stackType].curSize = self.downloadingSizes[task.stackType].curSize - 1
    self.downloadingCurSize = self.downloadingCurSize - 1
    if bWait then
      self:Push(task, bErased)
    elseif task.downloadType == PufferConst.ENUM_DownloadType.MAP then
      local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
      if not PufferMapManager:CanPause(task.mapKey) and PufferMapManager.MapPaks[task.mapKey].state ~= PufferConst.ENUM_DownloadState.Done then
        log(bWriteLog and "puffer_queue:EraseDownloadingTask. add to mergeTasks")
        self.mergeTasks[task.pakName] = task
      end
    end
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CPufferQueue = class(CModuleBase, nil, puffer_queue)
return CPufferQueue