local EventSystem = {}
local string_format = string.format
local table_remove = table.remove
local table_pack = table.pack
local table_unpack = table.unpack
local local local local local local local local local local local local local MapEvents = {}
local EventHandleIndex = 0
local EventIndexEventInfoMap = {}
local common = require("client.slua_ui_framework.common")
local utility = require("common.utility")
local xpcallHandle = utility.ErrorMessageHandler
local ProcessingEventID = {}
local IsDevelopment = import("STExtraBlueprintFunctionLibrary").IsDevelopment()
local CallEventFunc = function(EventInfo, ...)
  local Func = EventInfo[3]
  local Arg = EventInfo[4]
  if IsDevelopment then
    if Arg then
      return xpcall(Func, xpcallHandle, Arg, ...)
    elseif EventInfo.Args then
      return xpcall(common.CallCombinationArgs, xpcallHandle, Func, EventInfo.Args, ...)
    else
      return xpcall(Func, xpcallHandle, ...)
    end
  elseif Arg then
    return pcall(Func, Arg, ...)
  elseif EventInfo.Args then
    return pcall(common.CallCombinationArgs, Func, EventInfo.Args, ...)
  else
    return pcall(Func, ...)
  end
end
function EventSystem:postEvent(EventType, EventID, ...)
  local ListProcessor, ProcessorMap = EventSystem:_GetEventProcessor(EventType, EventID)
  if not ListProcessor then
    return
  end
  local ListNeedRemove
  ProcessingEventID[EventID] = ProcessingEventID[EventID] and ProcessingEventID[EventID] + 1 or 1
  for _, _EventIndex in ipairs(ListProcessor) do
    local EventInfo = EventIndexEventInfoMap[_EventIndex]
    if EventInfo then
      local bNeedRemove, bSuccess
      bSuccess, bNeedRemove = CallEventFunc(EventInfo, EventType, EventID, ...)
      if bNeedRemove == true then
        ListNeedRemove = ListNeedRemove or {}
        ListNeedRemove[_EventIndex] = true
      elseif bNeedRemove ~= nil then
        sandbox.LogError(string.format("EventSystem:postEvent Error EventType = %d, EventID = %d, bNeedRemove = %s", EventType, EventID, bNeedRemove))
      end
    end
  end
  ProcessingEventID[EventID] = ProcessingEventID[EventID] - 1
  if ProcessingEventID[EventID] <= 0 then
    ProcessingEventID[EventID] = nil
  end
  if ListNeedRemove and next(ListNeedRemove) then
    local ProcessorNum = #ListProcessor
    local StartIndex = 1
    for Index = 1, ProcessorNum do
      if not ListNeedRemove[ListProcessor[Index]] then
        ListProcessor[StartIndex] = ListProcessor[Index]
        StartIndex = StartIndex + 1
      end
    end
    for Index = ProcessorNum, StartIndex, -1 do
      local EventIndex = ListProcessor[Index]
      local Processor = EventIndexEventInfoMap[EventIndex]
      ProcessorMap[Processor] = nil
      EventIndexEventInfoMap[EventIndex] = nil
      ListProcessor[Index] = nil
    end
  end
end
function EventSystem:postEventSafety(EventType, EventID, ...)
  local args = {
    ...
  }
  xpcall(function()
    EventSystem:postEvent(EventType, EventID, table_unpack(args))
  end, utility.ErrorMessageHandler)
end
function EventSystem:registEvent(EventType, EventID, FuncProcessor, ...)
  local ListProcessor, ProcessorMap = EventSystem:_CheckRegisterLegal(EventType, EventID, FuncProcessor)
  if not ListProcessor then
    return 0
  end
  local ExistingIndex = ProcessorMap[FuncProcessor]
  if ExistingIndex then
    return ExistingIndex
  end
  EventHandleIndex = EventHandleIndex + 1
  ListProcessor[#ListProcessor + 1] = EventHandleIndex
  ProcessorMap[FuncProcessor] = EventHandleIndex
  local paramCount = select("#", ...)
  local EventInfo
  if paramCount == 1 then
    EventInfo = table_pack(EventType, EventID, FuncProcessor, ...)
  elseif paramCount == 0 then
    EventInfo = table_pack(EventType, EventID, FuncProcessor)
  else
    EventInfo = table_pack(EventType, EventID, FuncProcessor)
    EventInfo.Args = table_pack(...)
  end
  EventIndexEventInfoMap[EventHandleIndex] = EventInfo
  return EventHandleIndex
end
function EventSystem:registEventWithConditions(EventType, EventID, Conditions, FuncProcessor, ...)
  local AdvanceEventSystem = require("client.common.event.AdvanceEventSystem")
  return AdvanceEventSystem:registEventWithConditions(EventType, EventID, Conditions, FuncProcessor, ...)
end
function EventSystem:_CheckRegisterLegal(EventType, EventID, FuncProcessor)
  if EventType == nil or EventID == nil then
    log_error(bWriteLog and string_format("EventSystem:RegistEvent Error: EventType[%s] or EventID[%s] is nil", tostring(EventType), tostring(EventID)))
    return false
  end
  if type(FuncProcessor) ~= "function" then
    log_error(bWriteLog and "EventSystem:RegistEvent Error: FnProcessor is not function")
    return false
  end
  local ListEventID = MapEvents[EventType]
  if not ListEventID then
    MapEvents[EventType] = {}
    ListEventID = MapEvents[EventType]
  end
  local ProcessorInfo = ListEventID[EventID]
  if not ProcessorInfo then
    ListEventID[EventID] = {
      {},
      {}
    }
    ProcessorInfo = ListEventID[EventID]
  end
  return ProcessorInfo[1], ProcessorInfo[2]
end
function EventSystem:_GetEventProcessor(EventType, EventID)
  local ListEventID = MapEvents[EventType]
  if not ListEventID then
    return false
  end
  local ProcessorInfo = ListEventID[EventID]
  if not ProcessorInfo then
    return false
  end
  return ProcessorInfo[1], ProcessorInfo[2]
end
function EventSystem:unregistEvent(EventType, EventID, Processor)
  if IsDevelopment then
    assert(EventID ~= nil, "EventSystem:unregistEvent. EventID is nil")
  end
  local ListProcessor, ProcessorMap = EventSystem:_GetEventProcessor(EventType, EventID)
  if not ListProcessor then
    return false
  end
  local EventIndex = ProcessorMap[Processor]
  for Index, _EventIndex in pairs(ListProcessor) do
    if _EventIndex == EventIndex then
      EventIndexEventInfoMap[EventIndex] = nil
      if ProcessingEventID[EventID] then
        ProcessorMap[Processor] = nil
        ListProcessor[Index] = 0
        return true
      else
        table_remove(ListProcessor, Index)
        ProcessorMap[Processor] = nil
      end
      return true
    end
  end
end
function EventSystem:UnregistEventByID(EventIndex)
  if not EventIndex then
    return false
  end
  local EventInfo = EventIndexEventInfoMap[EventIndex]
  if not EventInfo then
    return false
  end
  local EventType = EventInfo[1]
  local EventID = EventInfo[2]
  local Processor = EventInfo[3]
  local ListProcessor, ProcessorMap = EventSystem:_GetEventProcessor(EventType, EventID)
  if not ListProcessor then
    return false
  end
  for Index, _EventIndex in pairs(ListProcessor) do
    if _EventIndex == EventIndex then
      EventIndexEventInfoMap[EventIndex] = nil
      if ProcessingEventID[EventID] then
        return true
      else
        table_remove(ListProcessor, Index)
        ProcessorMap[Processor] = nil
      end
      return true
    end
  end
  return false
end
_G.return EventSystem