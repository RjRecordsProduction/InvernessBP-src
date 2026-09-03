local EventSystem = require("client.common.event.EventSystem")
local EventBridge = {}
local local local local table_unpack = table.unpack
local IsDev = import("STExtraBlueprintFunctionLibrary").IsDevelopment()
local OnRegistEvent = function(EventType, EventID, Callback)
  local EventHandleIndex
  local EventTrigger = function(_, _, ...)
    if IsDev then
      local ErrorMessageHandler = function(Msg)
        local Utility = require("common.utility")
        local LuaEventSubsystem = Utility.GetGameInstanceSubsystemByName("LuaEventSubsystem")
        Msg = string.format([=[
%s
UObject Name[%s], UFunction Name[%s]]=], Msg, LuaEventSubsystem.LastEventTriggerObjectName, LuaEventSubsystem.LastEventTriggerFunctionName)
        Utility.ErrorMessageHandler(Msg)
      end
      local Status, bNeedRemove = xpcall(Callback, ErrorMessageHandler, EventHandleIndex, ...)
      return bNeedRemove
    else
      return Callback(EventHandleIndex, ...)
    end
  end
  EventHandleIndex = EventSystem:registEvent(EventType, EventID, EventTrigger)
  return EventHandleIndex
end
local OnUnRegistEvent = function(EventHandleIndex)
  EventSystem:UnregistEventByID(EventHandleIndex)
end
local OnPostEvent = function(EventTypeName, EventIDName, ...)
  local EventType = _G[EventTypeName]
  local EventID = _G[EventIDName]
  EventSystem:postEvent(EventType, EventID, ...)
end
local OnPostBlueprintEvent = function(EventTypeName, EventIDName, EventSubsystem)
  local EventType = _G[EventTypeName]
  local EventID = _G[EventIDName]
  local ParamArray = EventSubsystem.CurrentParamArray
  local Params = {}
  for Index, ParamInfo in pairs(ParamArray) do
    Params[Index + 1] = ParamInfo.Data
  end
  EventSystem:postEvent(EventType, EventID, table_unpack(Params, 1, ParamArray:Num()))
end
function EventBridge.Init()
  local Utility = require("common.utility")
  local LuaEventSubsystem = Utility.GetGameInstanceSubsystemByName("LuaEventSubsystem")
  LuaEventSubsystem:SetBridgeFunction(OnRegistEvent, OnUnRegistEvent, OnPostEvent, OnPostBlueprintEvent)
end
return EventBridge