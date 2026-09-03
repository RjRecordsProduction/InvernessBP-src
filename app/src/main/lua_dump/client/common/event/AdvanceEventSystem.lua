local AdvanceEventSystem = {}
function AdvanceEventSystem:registEvent(EventType, EventID, FuncProcessor, ...)
  local EventSystem = require("client.common.event.EventSystem")
  local FuncWrap = function(...)
    local Co = coroutine.create(FuncProcessor)
    local bSuccess, NewWaitTime = coroutine.resume(Co, ...)
    if not bSuccess then
      local utility = require("common.utility")
      utility.ErrorMessageHandlerCo(Co, NewWaitTime)
    elseif NewWaitTime then
      Game:WaitCo(Co, NewWaitTime)
    end
  end
  return EventSystem:registEvent(EventType, EventID, FuncWrap, ...)
end
function AdvanceEventSystem:registEventWithConditions(EventType, EventID, Conditions, FuncProcessor, ...)
  local EventSystem = require("client.common.event.EventSystem")
  local InArgumentNum = select("#", ...)
  local EventIndex
  local FuncWrap = function(...)
    if AdvanceEventSystem:CheckConditions(Conditions, select(InArgumentNum + 3, ...)) then
      local Args = table.pack(...)
      table.insert(Args, InArgumentNum + 3, EventIndex)
      local Co = coroutine.create(FuncProcessor)
      local bSuccess, NewWaitTime = coroutine.resume(Co, table.unpack(Args, 1, Args.n + 1))
      if not bSuccess then
        local utility = require("common.utility")
        utility.ErrorMessageHandlerCo(Co, NewWaitTime)
      elseif NewWaitTime then
        Game:WaitCo(Co, NewWaitTime)
      end
    end
  end
  EventIndex = EventSystem:registEvent(EventType, EventID, FuncWrap, ...)
  return EventIndex
end
function AdvanceEventSystem:registEventWithConditionsWithoutCoroutine(EventType, EventID, Conditions, FuncProcessor, ...)
  local EventSystem = require("client.common.event.EventSystem")
  local InArgumentNum = select("#", ...)
  local EventIndex
  local FuncWrap = function(...)
    if AdvanceEventSystem:CheckConditions(Conditions, select(InArgumentNum + 3, ...)) then
      local Args = table.pack(...)
      table.insert(Args, InArgumentNum + 3, EventIndex)
      FuncProcessor(table.unpack(Args, 1, Args.n + 1))
    end
  end
  EventIndex = EventSystem:registEvent(EventType, EventID, FuncWrap, ...)
  return EventIndex
end
function AdvanceEventSystem:CheckConditions(Conditions, ...)
  if Conditions == nil then
    return true
  end
  for Key, Condition in pairs(Conditions) do
    local InValue = select(Key, ...)
    if type(Condition) == "table" then
      local Operator = Condition.Operator
      local CondValue = Condition.Value
      InValue = InValue or 0
      if Operator == "=" or Operator == "==" then
        if Condition ~= InValue then
          return false
        end
      elseif Operator == "<" then
        if CondValue <= InValue then
          return false
        end
      elseif Operator == ">" then
        if CondValue >= InValue then
          return false
        end
      elseif Operator == "<=" then
        if CondValue < InValue then
          return false
        end
      elseif Operator == ">=" and CondValue > InValue then
        return false
      end
    elseif Condition ~= InValue then
      return false
    end
  end
  return true
end
function AdvanceEventSystem:unregistEvent(EventType, EventID, Processor)
  local EventSystem = require("client.common.event.EventSystem")
  EventSystem:unregistEvent(EventType, EventID, Processor)
end
return AdvanceEventSystem