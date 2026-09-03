local widget_proxy = {}
local WidgetMeta = {}
local bDebugTrace = false
local GMDebug = false
local local local local local string_format = string.format
local local table_insert = table.insert
local CmdMeta = {
  __index = function()
  end
}
function WidgetMeta:__index(Key)
  if WidgetMeta[Key] then
    return WidgetMeta[Key]
  end
  local ChildProxy = self.Child[Key]
  if ChildProxy then
    return ChildProxy
  end
  if Key == "Widget" then
    return self._Widget
  end
  ChildProxy = widget_proxy.Create(self, Key)
  self.Child[Key] = ChildProxy
  return ChildProxy
end
function WidgetMeta:__call(...)
  local CommandQueue = self.CommandQueue
  local Cmd = {
    Exec = self,
    Args = table.pack(...)
  }
  CommandQueue[#CommandQueue + 1] = Cmd
  if bDebugTrace then
    Cmd.TraceBack = debug.traceback("", 2)
  end
  setmetatable(Cmd, CmdMeta)
  return Cmd
end
function WidgetMeta:__newindex(Key, Value)
  if Key == "Widget" then
    self._Widget = Value
    if self._WidgetListener then
      for Idx, Callback in pairs(self._WidgetListener) do
        Callback(Value)
        self._WidgetListener[Idx] = nil
      end
    end
    return
  end
  local CommandQueue = self.CommandQueue
  local Cmd = {
    Prop = self,
    Key = Key,
      }
  CommandQueue[#CommandQueue + 1] = Cmd
  if bDebugTrace then
    Cmd.TraceBack = debug.traceback("", 2)
  end
end
function WidgetMeta:CacheParentWidget(ParentWidget)
  if GMDebug then
    log(bWriteLog and string_format("WidgetMeta:CacheParentWidget ParentWidget:%s", tostring(ParentWidget)))
  end
  self.end
function WidgetMeta:AddWidgetListener(callback)
  if self._Widget then
    callback(self._Widget)
  else
    table_insert(self._WidgetListener, callback)
  end
end
function widget_proxy.Create(Parent, Key)
  local Proxy = setmetatable({
    Parent = Parent or false,
    Child = {},
    ParentWidget = false,
    _Widget = false,
    _WidgetListener = not Parent and {},
    Key = Key,
    CommandQueue = Parent and Parent.CommandQueue or {}
  }, WidgetMeta)
  return Proxy
end
function widget_proxy.IsWidgetProxy(Obj)
  local ret = getmetatable(Obj) == WidgetMeta
  if GMDebug then
    log(bWriteLog and string_format("widget_proxy.IsWidgetProxy ret:%s", tostring(ret)))
  end
  return ret
end
function widget_proxy.IsCommand(InTable)
  local ret = getmetatable(InTable) == CmdMeta
  if GMDebug then
    log(bWriteLog and string_format("widget_proxy.IsCommand ret:%s", tostring(ret)))
  end
  return ret
end
return widget_proxy