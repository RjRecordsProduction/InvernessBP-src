local widget_proxy_util = {}
local string_format = string.format
local string_sub = string.sub
local string_find = string.find
local table_unpack = table.unpack
local local local local local local local local local utility = require("common.utility")
local widget_proxy = require("client.common.uibase.widget_proxy")
local GMDebug = false
local function GetControlByFuncCmd(UIWidget, Proxy)
  local Parent = Proxy.Parent
  if GMDebug then
    log(bWriteLog and string_format("widget_proxy_util GetControlByFuncCmd Proxy.Key :%s", tostring(Proxy.Key)))
  end
  if Parent.Parent then
    local Widget = Parent.Widget
    if not Widget then
      Widget = GetControlByFuncCmd(UIWidget, Parent)
      Parent.    end
    local Ret = Widget and Widget[Parent.Key]
    if not Ret then
      log_error(string_format("[%s] can't find [%s]!", Widget, Parent.Key))
    end
    return Ret
  end
  return UIWidget
end
local function GetCommondResult(UIRoot, Command)
  if GMDebug then
    log(bWriteLog and string_format("widget_proxy_util GetCommondResult Exec Widget is nil"))
  end
  local Status, Result
  if Command.Exec then
    local Exec = Command.Exec
    local FuncName = Exec.Key
    local Widget = Exec.Widget
    if not Widget then
      if GMDebug then
        log(bWriteLog and string_format("widget_proxy_util GetCommondResult Command.Exec Widget is nil"))
      end
      Widget = GetControlByFuncCmd(UIRoot, Exec)
      if GMDebug then
        log(bWriteLog and string_format("widget_proxy_util GetCommondResult Command.Exec Find Widget :%s", tostring(Widget)))
      end
      Exec.    end
    if not Widget then
      local GameplayStatics = import("GameplayStatics")
      local UKismetSystemLibrary = import("KismetSystemLibrary")
      utility.ErrorMessageHandler(string_format("widget_proxy_util GetCommondResult Exec Widget is nil UIRoot[%s] function[%s], TraceBack[%s]", UKismetSystemLibrary.GetClassDisplayName(GameplayStatics.GetObjectClass(UIRoot)), tostring(FuncName), tostring(Command.TraceBack)))
    else
      Status, Result = pcall(Widget[FuncName], Widget, table_unpack(Command.Args, 2))
      if not Status then
        for i = 2, Command.Args.n do
          local Arg = Command.Args[i]
          if type(Arg) == "table" then
            if widget_proxy.IsWidgetProxy(Arg) then
              Command.Args[i] = widget_proxy_util.GetControlByPropCmd(UIRoot, Arg)
            elseif widget_proxy.IsCommand(Arg) then
              Command.Args[i] = GetCommondResult(UIRoot, Arg)
            end
          end
        end
        Status, Result = pcall(Widget[FuncName], Widget, table_unpack(Command.Args, 2))
      end
      if not Status then
        local GameplayStatics = import("GameplayStatics")
        local UKismetSystemLibrary = import("KismetSystemLibrary")
        utility.ErrorMessageHandler(string_format("widget_proxy_util GetCommondResult Exec %s, UIRoot[%s] function[%s], TraceBack[%s]", Result, UKismetSystemLibrary.GetClassDisplayName(GameplayStatics.GetObjectClass(UIRoot)), FuncName, tostring(Command.TraceBack)))
        Result = nil
      end
    end
  end
  return Result
end
local SetWidgetProperty = function(Widget, PropertyName, PropertyValue)
  Widget[PropertyName] = PropertyValue
end
function widget_proxy_util.GetControlByPropCmd(UIWidget, Proxy)
  if Proxy.Parent then
    local Widget = Proxy.Widget
    if not Widget then
      Widget = widget_proxy_util.GetControlByPropCmd(UIWidget, Proxy.Parent)
      Proxy.    end
    local Ret = Widget and Widget[Proxy.Key]
    if not Ret then
      log_error(string_format("[%s] can't find [%s]!", Widget, Proxy.Key))
    end
    return Ret
  end
  return UIWidget
end
function widget_proxy_util.ReplayProxy(Proxy, UIRoot)
  if GMDebug then
    log(bWriteLog and string_format("widget_proxy_util.ReplayProxy UIRoot:%s", tostring(UIRoot)))
  end
  if not UIRoot then
    return
  end
  if not slua.isValid(UIRoot) then
    utility.ErrorMessageHandler(string_format("widget_proxy_util.ReplayProxy slua.isValid(UIRoot) is false type(UIRoot):%s ", type(UIRoot)))
    return
  end
  for Index, Command in pairs(Proxy.CommandQueue) do
    if Command.Exec then
      local Exec = Command.Exec
      local FuncName = Exec.Key
      local Widget = Exec.Widget
      if not Widget then
        if GMDebug then
          log(bWriteLog and string_format("widget_proxy_util.ReplayProxy Command.Exec Widget is nil"))
        end
        Widget = GetControlByFuncCmd(UIRoot, Exec)
        if GMDebug then
          log(bWriteLog and string_format("widget_proxy_util.ReplayProxy Command.Exec Find Widget :%s", tostring(Widget)))
        end
        Exec.      end
      if not Widget then
        local GameplayStatics = import("GameplayStatics")
        local UKismetSystemLibrary = import("KismetSystemLibrary")
        utility.ErrorMessageHandler(string_format("widget_proxy_util.ReplayProxy Exec Widget[%s] is nil, UIRoot[%s] function[%s], TraceBack[%s]", Exec and Exec.Parent and Exec.Parent.Key or "", UKismetSystemLibrary.GetClassDisplayName(GameplayStatics.GetObjectClass(UIRoot)), tostring(FuncName), tostring(Command.TraceBack)))
      else
        local status, err
        local Args2 = table_unpack(Command.Args, 2, 2)
        if Args2 and type(Args2) == "string" and string_find(Args2, "__Asy_") ~= nil then
          local SubWidgetName = string_sub(Args2, 7)
          if not Widget[SubWidgetName] or not Widget[SubWidgetName][FuncName] then
            status = true
          else
            status, err = pcall(Widget[SubWidgetName][FuncName], Widget[SubWidgetName], table_unpack(Command.Args, 3))
          end
          if not status then
            local GameplayStatics = import("GameplayStatics")
            local UKismetSystemLibrary = import("KismetSystemLibrary")
            local paramCount = Command.Args.n - 2
            utility.ErrorMessageHandler(string_format("widget_proxy_util.ReplayProxy Exec:%s, UIRoot[%s], SubWidgetName[%s], function[%s], Args3[%s], TraceBack[%s]", err, UKismetSystemLibrary.GetClassDisplayName(GameplayStatics.GetObjectClass(UIRoot)), SubWidgetName, FuncName, paramCount, tostring(Command.TraceBack)))
          end
        else
          status, err = pcall(Widget[FuncName], Widget, table_unpack(Command.Args, 2))
          if not status then
            for i = 2, Command.Args.n do
              local Arg = Command.Args[i]
              if type(Arg) == "table" then
                if widget_proxy.IsWidgetProxy(Arg) then
                  Command.Args[i] = widget_proxy_util.GetControlByPropCmd(UIRoot, Arg)
                elseif widget_proxy.IsCommand(Arg) then
                  Command.Args[i] = GetCommondResult(UIRoot, Arg)
                end
              end
            end
            status, err = pcall(Widget[FuncName], Widget, table_unpack(Command.Args, 2))
          end
          if not status then
            local GameplayStatics = import("GameplayStatics")
            local UKismetSystemLibrary = import("KismetSystemLibrary")
            local paramCount = Command.Args.n - 1
            utility.ErrorMessageHandler(string_format("widget_proxy_util.ReplayProxy Exec %s, UIRoot[%s], Widget[%s], function[%s], Args2[%s], TraceBack[%s]", err, UKismetSystemLibrary.GetClassDisplayName(GameplayStatics.GetObjectClass(UIRoot)), UKismetSystemLibrary.GetDisplayName(Widget), FuncName, paramCount, tostring(Command.TraceBack)))
          end
        end
      end
    elseif Command.Prop then
      local Prop = Command.Prop
      local PropName = Command.Key
      local Widget = Prop.Widget
      if not Widget then
        if GMDebug then
          log(bWriteLog and string_format("widget_proxy_util.ReplayProxy Command.Prop Widget is nil"))
        end
        Widget = widget_proxy_util.GetControlByPropCmd(UIRoot, Prop)
        if GMDebug then
          log(bWriteLog and string_format("widget_proxy_util.ReplayProxy Command.Prop Find Widget :%s", tostring(Widget)))
        end
        Prop.      end
      if not Widget then
        local GameplayStatics = import("GameplayStatics")
        local UKismetSystemLibrary = import("KismetSystemLibrary")
        utility.ErrorMessageHandler(string_format("widget_proxy_util.ReplayProxy Prop Widget is nil, UIRoot[%s] widget[%s] property[%s], TraceBack[%s]", UKismetSystemLibrary.GetClassDisplayName(GameplayStatics.GetObjectClass(UIRoot)), Prop.Key, PropName, tostring(Command.TraceBack)))
      else
        local status, err = pcall(SetWidgetProperty, Widget, PropName, Command.Value)
        if not status then
          local GameplayStatics = import("GameplayStatics")
          local UKismetSystemLibrary = import("KismetSystemLibrary")
          utility.ErrorMessageHandler(string_format("widget_proxy_util.ReplayProxy Prop %s, UIRoot[%s] widget[%s] property[%s], TraceBack[%s]", err, UKismetSystemLibrary.GetClassDisplayName(GameplayStatics.GetObjectClass(UIRoot)), Prop.Key, PropName, tostring(Command.TraceBack)))
        end
      end
    end
    Proxy.CommandQueue[Index] = nil
  end
end
return widget_proxy_util