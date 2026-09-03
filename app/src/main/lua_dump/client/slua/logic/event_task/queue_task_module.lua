local queue_task_module = {
  TaskEnum = {
    Login = 1,
    Lobby = 2,
    Room = 3,
    UGC = 4
  }
}
local local 
function queue_task_module:DefineAndResetData()
  self.queueTb = {}
end
function queue_task_module:OnPreSwitchGameStatus(_, next)
  if next == GameStatus.Login then
    for _, ModuleBase in pairs(self.queueTb) do
      ModuleBase:ResetQueue()
    end
    self:DefineAndResetData()
  end
end
function queue_task_module:Enqueue(name, task)
  assert(type(task) == "table", "module must be table type")
  local module = task.module
  assert(type(module) == "table", "module must be table type")
  local funcName = task.funcName
  assert(type(funcName) == "string", "funcName must be string type")
  assert_format(type(module[funcName]) == "function", "%s must be function type", funcName)
  local queue = self.queueTb[name]
  if not queue then
    log(bWriteLog and "  queue_task_module:Enqueue. addQueue name: " .. tostring(name))
    queue = require("client.slua.logic.event_task.task_queue")(name)
    self.queueTb[name] = queue
  end
  queue:Enqueue(task)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Cqueue_task_module = class(CModuleBase, nil, queue_task_module)
return Cqueue_task_module