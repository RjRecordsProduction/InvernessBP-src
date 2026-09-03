local utility = require("common.utility")
local FeatureUtil = {}
function FeatureUtil.printf(formatStr, ...)
  if _G.printf then
    print(bWriteLog and string.format(formatStr, ...))
  else
    print(bWriteLog and string.format(formatStr, ...))
  end
end
function FeatureUtil.ForEachFeatureCall(Instance, Method, ...)
  if not Instance.Features then
    return
  end
  for _, Feature in ipairs(Instance.Features) do
    if Feature[Method] then
      xpcall(Feature[Method], utility.ErrorMessageHandler, Feature, ...)
    end
  end
end
function FeatureUtil.LogTree(varName, varValue)
  if log_tree then
    log_tree(varName, varValue)
  else
    print(bWriteLog and varName, varValue)
  end
end
local LuaDelegateImpl = {}
function LuaDelegateImpl:ctor()
  self.Events = {}
end
function LuaDelegateImpl:Dispose()
  for Event, Processors in pairs(self.Events) do
    self:Remove(Event)
  end
end
function LuaDelegateImpl:Add(Event, Callback, Caller)
  local Processors = self.Events[Event]
  if not Processors then
    Processors = {}
    self.Events[Event] = Processors
  end
  for _, Processor in ipairs(Processors) do
    if Processor.Callback == Callback and Processor.Caller == Caller then
      return
    end
  end
  table.insert(Processors, {Callback = Callback, Caller = Caller})
end
function LuaDelegateImpl:Remove(Event)
  self.Events[Event] = nil
end
function LuaDelegateImpl:RemoveByCaller(Event, Caller)
  local Processors = self.Events[Event]
  if not Processors then
    return
  end
  local IndexToRemove = {}
  for i, Processor in ipairs(Processors) do
    if Processor.Caller == Caller then
      table.insert(IndexToRemove, i)
    end
  end
  for _, i in ipairs(IndexToRemove) do
    table.remove(Processors, i)
  end
end
function LuaDelegateImpl:Broadcast(Event, ...)
  local Processors = self.Events[Event]
  if not Processors then
    return
  end
  local utility = require("common.utility")
  for _, Processor in ipairs(Processors) do
    xpcall(Processor.Callback, utility.ErrorMessageHandler, Processor.Caller, ...)
  end
end
local class = require("class")
FeatureUtil.LuaDelegate = class(require("object"), nil, LuaDelegateImpl)
return FeatureUtil