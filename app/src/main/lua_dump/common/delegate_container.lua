local DelegateContainer = {}
local string_format = string.format
local table_pack = table.pack
local local local local local local EventSystem = require("client.common.event.EventSystem")
local local slua_isValid = slua.isValid
local slua_removeDelegate = slua.removeDelegate
local common = require("client.slua_ui_framework.common")
local UIMessageSystem = require("GameLua.GameCore.Main.UIMessageSystem")
local AdvanceEventSystem = require("client.common.event.AdvanceEventSystem")
local time_ticker = require("common.time_ticker")
local asset_util = require("common.asset_util")
local utility = require("common.utility")
local xpcallHandle = utility.ErrorMessageHandler
local EventProxy
local local bUseSingleton = true
local SingletondelegateConfig = {
  "OnPerspectiveChanged",
  "OnPawnRespawnDelegate",
  "OnSwitchCameraModeStart",
  "OnPlayerQuitSpectatingForClient",
  "OnCharacterStatesChangeWithFilterState",
  "OnSpectatorChange",
  "OnPlayerEnterFlying",
  "OnSetViewTarget",
  "OnGameStateChange",
  "OnParachuteResetScreenCullFactor",
  "OnCharacterWeaponUnEquipDelegate",
  "OnCharacterWeaponEquipDelegate",
  "OnPlayerControllerStateChangedDelegate"
}
local SingletondelegateSet = {}
for _, str in ipairs(SingletondelegateConfig) do
  SingletondelegateSet[str] = true
end
function DelegateContainer:ctor()
  self._isDisposed = false
  self._controlEvents = nil
  self._RemoveEvents = nil
  self._ClearEvents = nil
  self._commonEvents = nil
  self._uiMessageEvents = nil
  self._conditionEvents = nil
  self._times = nil
  self._gameTimers = nil
  self._dataListeners = nil
  self._dataNewIndexListeners = nil
  self._leafDataNewIndexListener = nil
  self._attrModifyListeners = nil
  self._luaNetListeners = nil
  self._loadedDelegates = nil
  self._settingOptionListeners = nil
  self._SuperData = nil
end
function DelegateContainer:IsValid()
  return not self._isDisposed
end
function DelegateContainer:Dispose()
  xpcall(self.UnRegistEvents, xpcallHandle, self)
  xpcall(self.RemoveAllTimer, xpcallHandle, self)
  xpcall(self.RemoveAllGameTimer, xpcallHandle, self)
  xpcall(self.CancelAllAsyncLoad, xpcallHandle, self)
  xpcall(self.RemoveAllSettingOptionEvent, xpcallHandle, self)
  self._isDisposed = true
  self._SuperData = nil
end
function DelegateContainer:OnUnRegistEvents()
end
function DelegateContainer:UnRegistEvents()
  self:_UnRegistEvents()
  self:OnUnRegistEvents()
end
function DelegateContainer:_UnRegistEvents()
  self:_UnRegistEventsControl()
  if not EventProxy then
    EventProxy = require("client.common.event.EventProxy")
  end
  self:_UnRegistEventsCommon()
  if self._conditionEvents then
    for eventHandle, _ in pairs(self._conditionEvents) do
      EventSystem:UnregistEventByID(eventHandle)
    end
    self._conditionEvents = nil
  end
  if self._dataListeners then
    for superData, listeners in pairs(self._dataListeners) do
      if superData and type(superData) == "table" and type(superData.RemoveListener) == "function" then
        for fieldName, listenerList in pairs(listeners) do
          for i = 1, #listenerList do
            superData:RemoveListener(fieldName, listenerList[i])
          end
        end
      end
    end
    self._dataListeners = nil
  end
  if self._dataNewIndexListeners then
    for superData, listeners in pairs(self._dataNewIndexListeners) do
      if superData and type(superData) == "table" and type(superData.RemoveNewIndexListener) == "function" then
        for _, listenerList in pairs(listeners) do
          for i = 1, #listenerList do
            superData:RemoveNewIndexListener(listenerList[i])
          end
        end
      end
    end
    self._dataNewIndexListeners = nil
  end
  if self._leafDataNewIndexListener then
    for superDataLeaf, dataListeners in pairs(self._leafDataNewIndexListener) do
      if superDataLeaf and type(superDataLeaf) == "table" and type(superDataLeaf.RemoveNewIndexListener) == "function" then
        for i = 1, #dataListeners do
          superDataLeaf:RemoveNewIndexListener(dataListeners[i])
        end
      end
    end
    self._leafDataNewIndexListener = nil
  end
  if self._uiMessageEvents then
    for MessageName, Func in pairs(self._uiMessageEvents) do
      UIMessageSystem.RemoveUIMessageEvent(MessageName, Func)
    end
    self._uiMessageEvents = nil
  end
  if self._attrModifyListeners then
    for attrModifyComp, listeners in pairs(self._attrModifyListeners) do
      if slua_isValid(attrModifyComp) then
        for name, func in pairs(listeners) do
          attrModifyComp:RemoveAttrListener(name, func)
        end
      end
    end
    self._attrModifyListeners = nil
  end
  if self._luaNetListeners then
    for actor, listeners in pairs(self._luaNetListeners) do
      if slua_isValid(actor) then
        for propName, func in pairs(listeners) do
          actor:RemoveLuaNetListener(propName, func)
        end
      end
    end
    self._luaNetListeners = nil
  end
  if self._nativeLuaDelegate then
    for control, ControlDelegates in pairs(self._nativeLuaDelegate) do
      if type(control) == "table" or slua_isValid(control) then
        for eventName, LuaDelegate in pairs(ControlDelegates) do
          local eventDelegate = control[eventName]
          if slua_isValid(eventDelegate) then
            if eventDelegate.Remove then
              eventDelegate:Remove(LuaDelegate)
            else
              eventDelegate:Clear()
            end
          else
            slua_removeDelegate(LuaDelegate)
          end
        end
      else
        for _, LuaDelegate in pairs(ControlDelegates) do
          slua_removeDelegate(LuaDelegate)
        end
      end
    end
    self._nativeLuaDelegate = nil
    self._nativeLuaEvents = nil
  end
  if self._nativeLuaListener then
    for control, ControlListener in pairs(self._nativeLuaListener) do
      if slua_isValid(control) then
        for eventName, handlefunc in pairs(ControlListener) do
          self:RemoveControlEventSingleton(control, eventName)
          ControlListener[eventName] = nil
        end
      end
    end
  end
  self._LuaObjEventContainer = nil
  if self._LuaObjListener then
    for LuaObjListener, controlListeners in pairs(self._LuaObjListener) do
      for CacheEventName, HandleFunc in pairs(controlListeners) do
        if LuaObjListener and LuaObjListener._LuaObjEvents and LuaObjListener._LuaObjEvents[CacheEventName] then
          local PackLuaEvents = LuaObjListener._LuaObjEvents[CacheEventName]
          if PackLuaEvents then
            PackLuaEvents[self] = nil
          end
        end
      end
      self._LuaObjListener[LuaObjListener] = nil
    end
  end
  self._LuaObjListener = nil
end
function DelegateContainer:RemoveAllTimer()
  if self._times then
    for handle, _ in pairs(self._times) do
      time_ticker.RemoveTimer(handle)
      self._times[handle] = nil
    end
  end
end
function DelegateContainer:RemoveAllGameTimer()
  if self._gameTimers then
    for nTimerID, _ in pairs(self._gameTimers) do
      Game:ClearTimer(nTimerID)
      self._gameTimers[nTimerID] = nil
    end
  end
end
function DelegateContainer:CancelAllAsyncLoad()
  if not self._loadedDelegates then
    return
  end
  for handle, _ in pairs(self._loadedDelegates) do
    asset_util.CancelAssetAsync(handle)
    self._loadedDelegates[handle] = nil
  end
end
function DelegateContainer:AddUIMessageEvent(MessageName, Func, ...)
  if not self._uiMessageEvents then
    self._uiMessageEvents = {}
  end
  local PreFunc = self._uiMessageEvents[MessageName]
  if PreFunc then
    UIMessageSystem.RemoveUIMessageEvent(MessageName, PreFunc)
  end
  self._uiMessageEvents[MessageName] = function(...)
    return Func(...)
  end
  return UIMessageSystem.AddUIMessageEvent(MessageName, self._uiMessageEvents[MessageName], ...)
end
function DelegateContainer:RemoveUIMessageEvent(MessageName)
  if not self._uiMessageEvents then
    self._uiMessageEvents = {}
  end
  local Func = self._uiMessageEvents[MessageName]
  if nil == Func then
    return
  end
  if UIMessageSystem.RemoveUIMessageEvent(MessageName, Func) then
    self._uiMessageEvents[MessageName] = nil
  end
end
function DelegateContainer:HasControlEventByControl(control, eventName)
  if not self._controlEvents then
    return false
  end
  if not assert(type(control) == "table" or slua_isValid(control), "DelegateContainer:HasControlEventByControl. control is not a valid object") then
    return false
  end
  if not assert(type(eventName) == "string", "DelegateContainer:HasControlEventByControl. eventName is not a string") then
    return false
  end
  local controlEvents = self._controlEvents[control]
  if controlEvents then
    local funcDelegate = controlEvents[eventName]
    if funcDelegate then
      return true
    end
  end
  return false
end
function DelegateContainer:AddControlEventSingleton(control, eventName, handleFunc, ...)
  return self:AddControlEventSingletonWithLuaObj(control, control, eventName, handleFunc, ...)
end
function DelegateContainer:RemoveControlEventSingleton(control, eventName)
  return self:RemoveControlEventSingletonWithLuaObj(control, control, eventName)
end
function DelegateContainer:AddControlEventSingletonWithLuaObj(control, LuaObj, eventName, handleFunc, ...)
  if not assert(type(control) == "table" or slua_isValid(control), "DelegateContainer:AddControlEventSingletonWithLuaObj. control is not a valid object") then
    return false
  end
  local eventDelegate = control[eventName]
  if not slua_isValid(eventDelegate) then
    xpcallHandle(string_format("DelegateContainer:AddControlEventSingletonWithLuaObj. eventDelegate is not a valid object eventName=%s", tostring(eventName)))
    return false
  end
  if not assert(type(handleFunc) == "function", "DelegateContainer:AddControlEventSingletonWithLuaObj. handleFunc is not a function") then
    return false
  end
  local CommonLuaListenerName = eventName .. "LuaListener"
  local eventLuaListener = LuaObj[CommonLuaListenerName]
  if not LuaObj._nativeLuaEvents then
    LuaObj._nativeLuaEvents = {}
  end
  if not LuaObj._nativeLuaDelegate then
    LuaObj._nativeLuaDelegate = {}
  end
  if not eventLuaListener then
    LuaObj[CommonLuaListenerName] = function(control, ...)
      if LuaObj._nativeLuaEvents then
        local DelegateLuaEvents = LuaObj._nativeLuaEvents[CommonLuaListenerName]
        for EventListener, args in pairs(DelegateLuaEvents) do
          if args[1] then
            common.CallCombinationArgs(args[1], args[2], ...)
          end
        end
      end
    end
    local controlEvents = LuaObj._nativeLuaDelegate[control]
    if not controlEvents then
      controlEvents = {}
      LuaObj._nativeLuaDelegate[control] = controlEvents
    end
    if eventDelegate.Add then
      controlEvents[eventName] = eventDelegate:Add(function(...)
        return LuaObj[CommonLuaListenerName](LuaObj, ...)
      end)
    else
      controlEvents[eventName] = eventDelegate:Bind(function(...)
        return LuaObj[CommonLuaListenerName](LuaObj, ...)
      end)
    end
  end
  local args = table_pack(...)
  local PackFunAndArgs = table_pack(handleFunc, args)
  local DelegateLuaEvents = LuaObj._nativeLuaEvents[CommonLuaListenerName]
  if not DelegateLuaEvents then
    DelegateLuaEvents = {}
    LuaObj._nativeLuaEvents[CommonLuaListenerName] = DelegateLuaEvents
  end
  DelegateLuaEvents[self] = PackFunAndArgs
  if not self._nativeLuaListener then
    self._nativeLuaListener = {}
  end
  local controlListeners = self._nativeLuaListener[LuaObj]
  if not controlListeners then
    controlListeners = {}
    self._nativeLuaListener[control] = controlListeners
  end
  controlListeners[eventName] = handleFunc
  return true
end
function DelegateContainer:RemoveControlEventSingletonWithLuaObj(control, LuaObj, eventName)
  if not LuaObj then
    return
  end
  if not LuaObj._nativeLuaDelegate then
    return
  end
  local CommonLuaListenerName = eventName .. "LuaListener"
  local DelegateLuaEvents = LuaObj._nativeLuaEvents[CommonLuaListenerName]
  if not DelegateLuaEvents then
    return
  end
  DelegateLuaEvents[self] = nil
  if not self._nativeLuaListener then
    return
  end
  local controlListeners = self._nativeLuaListener[LuaObj]
  if controlListeners then
    controlListeners[eventName] = nil
  end
end
function DelegateContainer:AddOnClickedEventByControl(control, handleFunc, ...)
  return self:AddControlEvent(control, "OnClicked", handleFunc, ...)
end
function DelegateContainer:AddControlEvent(control, eventName, handleFunc, ...)
  if bUseSingleton and SingletondelegateSet[eventName] then
    return self:AddControlEventSingleton(control, eventName, handleFunc, ...)
  end
  if not assert(type(control) == "table" or slua_isValid(control), "DelegateContainer:AddControlEvent. not control") then
    return false
  end
  if not assert(type(eventName) == "string", "DelegateContainer:AddControlEvent. eventName is not a string") then
    return false
  end
  local eventDelegate = control[eventName]
  if not slua_isValid(eventDelegate) then
    xpcallHandle(string_format("DelegateContainer:AddControlEvent. eventDelegate is not a valid object eventName=%s", tostring(eventName)))
    return false
  end
  if not assert(type(handleFunc) == "function", "DelegateContainer:AddControlEvent. handleFunc is not a function") then
    return false
  end
  if not self._controlEvents then
    self._controlEvents = {}
  end
  local controlEvents = self._controlEvents[control]
  if not controlEvents then
    controlEvents = {}
    self._controlEvents[control] = controlEvents
  end
  local funcDelegate = controlEvents[eventName]
  if funcDelegate then
    if eventDelegate.Remove then
      eventDelegate:Remove(funcDelegate)
    else
      eventDelegate:Clear()
    end
  end
  local args = table_pack(...)
  self:_AddControlEventImp(eventDelegate, eventName, handleFunc, args, controlEvents)
  return true
end
function DelegateContainer:AddControlEventWithCondition(control, eventName, condTable, handleFunc, ...)
  if not assert(type(control) == "table" or slua_isValid(control), "DelegateContainer:AddControlEventWithCondition. control is not a valid object") then
    return false
  end
  if not assert(type(eventName) == "string", "DelegateContainer:AddControlEventWithCondition. eventName is not a string") then
    return false
  end
  local eventDelegate = control[eventName]
  if not slua_isValid(eventDelegate) then
    xpcallHandle(string_format("DelegateContainer:AddControlEventWithCondition. eventDelegate is not a valid object eventName=%s", tostring(eventName)))
    return false
  end
  if not assert(type(handleFunc) == "function", "DelegateContainer:AddControlEventWithCondition. handleFunc is not a function") then
    return false
  end
  if not self._controlEvents then
    self._controlEvents = {}
  end
  local controlEvents = self._controlEvents[control]
  if not controlEvents then
    controlEvents = {}
    self._controlEvents[control] = controlEvents
  end
  local funcDelegate = controlEvents[eventName]
  if funcDelegate then
    if eventDelegate.Remove then
      eventDelegate:Remove(funcDelegate)
    else
      eventDelegate:Clear()
    end
  end
  if not self._RemoveEvents then
    self._RemoveEvents = {}
  end
  if not self._ClearEvents then
    self._ClearEvents = {}
  end
  local args = table_pack(...)
  local delegateNum
  if eventDelegate.Add then
    delegateNum = eventDelegate:Add(function(...)
      return common.CallCombinationArgs(handleFunc, args, ...)
    end, condTable)
    self._RemoveEvents[delegateNum] = eventDelegate
  else
    delegateNum = eventDelegate:Bind(function(...)
      return common.CallCombinationArgs(handleFunc, args, ...)
    end, condTable)
    self._ClearEvents[delegateNum] = eventDelegate
  end
  controlEvents[eventName] = delegateNum
  return true
end
function DelegateContainer:_AddControlEventImp(eventDelegate, eventName, handleFunc, args, controlEvents)
  if not self._RemoveEvents then
    self._RemoveEvents = {}
  end
  if not self._ClearEvents then
    self._ClearEvents = {}
  end
  local delegateNum
  if eventDelegate.Add then
    delegateNum = eventDelegate:Add(function(...)
      return common.CallCombinationArgs(handleFunc, args, ...)
    end)
    self._RemoveEvents[delegateNum] = eventDelegate
  else
    delegateNum = eventDelegate:Bind(function(...)
      return common.CallCombinationArgs(handleFunc, args, ...)
    end)
    self._ClearEvents[delegateNum] = eventDelegate
  end
  controlEvents[eventName] = delegateNum
end
function DelegateContainer:AddControlEventConditionOnly(control, eventName, condTable, handleFunc, ...)
  if not assert(type(control) == "table" or slua_isValid(control), "DelegateContainer:AddControlEventConditionOnly. control is not a valid object") then
    return
  end
  if not assert(type(eventName) == "string", "DelegateContainer:AddControlEventConditionOnly. eventName is not a string") then
    return
  end
  local eventDelegate = control[eventName]
  if not slua_isValid(eventDelegate) then
    xpcallHandle(string_format("DelegateContainer:AddControlEventConditionOnly. eventDelegate is not a valid object eventName=%s", tostring(eventName)))
    return
  end
  if not assert(type(handleFunc) == "function", "DelegateContainer:AddControlEventConditionOnly. handleFunc is not a function") then
    return
  end
  if not self._controlEvents then
    self._controlEvents = {}
  end
  local controlEvents = self._controlEvents[control]
  if not controlEvents then
    controlEvents = {}
    self._controlEvents[control] = controlEvents
  end
  local funcDelegate = controlEvents[eventName]
  if funcDelegate and eventDelegate.AddCondition then
    eventDelegate:AddCondition(funcDelegate, condTable)
  end
end
function DelegateContainer:RemoveControlEvent(control, eventName)
  if not assert(type(control) == "table" or slua_isValid(control), "DelegateContainer:RemoveControlEvent. control is not a valid object") then
    return false
  end
  if not assert(type(eventName) == "string", "DelegateContainer:RemoveControlEvent. eventName is not a string") then
    return false
  end
  if bUseSingleton and SingletondelegateSet[eventName] then
    self:RemoveControlEventSingleton(control, eventName)
    return true
  end
  if not self._controlEvents then
    self._controlEvents = {}
  end
  local controlEvents = self._controlEvents[control]
  if controlEvents == nil then
    return false
  end
  local funcDelegate = controlEvents[eventName]
  if funcDelegate then
    if type(control) == "table" or slua_isValid(control) then
      local eventDelegate = control[eventName]
      if slua_isValid(eventDelegate) then
        if eventDelegate.Remove then
          eventDelegate:Remove(funcDelegate)
        else
          eventDelegate:Clear()
        end
        controlEvents[eventName] = nil
      else
        slua_removeDelegate(funcDelegate)
      end
    else
      slua_removeDelegate(funcDelegate)
    end
    return true
  else
    return false
  end
end
function DelegateContainer:AddCommonEventInternal(_eventSystem, eventType, eventID, handleFunc, ...)
  if not assert(type(eventType) == "number" and type(eventID) == "number" and type(handleFunc) == "function", "DelegateContainer:AddCommonEventInternal eventType should be number,eventID should be number,handleFunc should be function") then
    return
  end
  if not self._commonEvents then
    self._commonEvents = {}
  end
  local events = self._commonEvents[eventType]
  if not events then
    events = {}
    self._commonEvents[eventType] = events
  end
  local eventFunc = events[eventID]
  if eventFunc then
    log_error(string.format("DelegateContainer:AddCommonEventInternal already have eventID. eventType, eventID=%s, %s", EventDefineID[eventType], EventDefineID[eventID]))
    return
  end
  local Func = function(...)
    handleFunc(...)
  end
  events[eventID] = Func
  return _eventSystem:registEvent(eventType, eventID, Func, ...)
end
function DelegateContainer:AddCommonEvent(eventType, eventID, handleFunc, ...)
  self:AddCommonEventInternal(EventSystem, eventType, eventID, handleFunc, ...)
end
function DelegateContainer:AddAdvanceCommonEvent(eventType, eventID, handleFunc, ...)
  self:AddCommonEventInternal(AdvanceEventSystem, eventType, eventID, handleFunc, ...)
end
function DelegateContainer:AddCommonEventWithConditions(eventType, eventID, conditions, handleFunc, ...)
  if not assert(type(eventType) == "number" and type(eventID) == "number" and type(handleFunc) == "function", "AddCommonEventWithConditions eventType should be number,eventID should be number,handleFunc should be function") then
    return nil
  end
  local EventHandle = EventSystem:registEventWithConditions(eventType, eventID, conditions, handleFunc, ...)
  if not self._conditionEvents then
    self._conditionEvents = {}
  end
  self._conditionEvents[EventHandle] = true
  return EventHandle
end
function DelegateContainer:AddCommonEventWithConditionsWithoutCoroutine(eventType, eventID, conditions, handleFunc, ...)
  if not assert(type(eventType) == "number" and type(eventID) == "number" and type(handleFunc) == "function", "AddCommonEventWithConditionsWithoutCoroutine eventType should be number,eventID should be number,handleFunc should be function") then
    return nil
  end
  local EventHandle = AdvanceEventSystem:registEventWithConditionsWithoutCoroutine(eventType, eventID, conditions, handleFunc, ...)
  if not self._conditionEvents then
    self._conditionEvents = {}
  end
  self._conditionEvents[EventHandle] = true
  return EventHandle
end
function DelegateContainer:IsCommonEventExists(eventType, eventID)
  if not assert(type(eventType) == "number" and type(eventID) == "number", "IsCommonEventExists eventType should be number,eventID should be number") then
    return
  end
  if not self._commonEvents then
    self._commonEvents = {}
  end
  local events = self._commonEvents[eventType]
  return events and events[eventID] ~= nil
end
function DelegateContainer:RemoveCommonEvent(eventType, eventID)
  if not assert(type(eventType) == "number" and type(eventID) == "number", "RemoveCommonEvent eventType should be number,eventID should be number") then
    return
  end
  if not self._commonEvents then
    self._commonEvents = {}
  end
  local events = self._commonEvents[eventType]
  if not events then
    log_error(string_format("Can't remove event because eventType's[%s] events not found", eventType))
    return
  end
  local eventFunc = events[eventID]
  if not eventFunc then
    log_error(string_format("Can't remove event because event not found for eventType[%s], eventID[%s]", eventType, eventID))
    return
  end
  if EventSystem:unregistEvent(eventType, eventID, eventFunc) then
    events[eventID] = nil
    return true
  end
  return false
end
function DelegateContainer:RemoveCommonEventWithConditions(EventHandle)
  if not self._conditionEvents then
    self._conditionEvents = {}
  end
  if not EventHandle or self._conditionEvents[EventHandle] then
    return
  end
  EventSystem:UnregistEventByID(EventHandle)
  self._conditionEvents[EventHandle] = nil
end
function DelegateContainer:RemoveCommonEventByUniqueID(EventHandle)
  if not EventProxy then
    EventProxy = require("client.common.event.EventProxy")
  end
  return EventSystem:UnregistEventByID(EventHandle)
end
function DelegateContainer:AddDataListener(superData, fieldName, handleFunc, ...)
  return self:_AddDataListener("_dataListeners", "AddListener", superData, fieldName, handleFunc, ...)
end
function DelegateContainer:AddDataNewIndexListener(superData, handleFunc, ...)
  return self:_AddDataListener("_dataNewIndexListeners", "AddNewIndexListener", superData, nil, handleFunc, ...)
end
function DelegateContainer:_AddDataListener(listenerSetName, addFuncName, superData, fieldName, handleFunc, ...)
  if not superData or type(superData) ~= "table" then
    log_error_format("DelegateContainer:_AddDataListener. superData is invalid, type:%s", type(superData))
    return
  end
  local fullKey = fieldName
  if not self[listenerSetName] then
    self[listenerSetName] = {}
  end
  local dataListener = self[listenerSetName][superData]
  if not dataListener then
    dataListener = {}
    self[listenerSetName][superData] = dataListener
  end
  if type(superData) ~= "table" then
    log_error_format("DelegateContainer:_AddDataListener. superData is not a table before calling method, type:%s", type(superData))
    return
  end
  local addFunc = superData[addFuncName]
  if type(addFunc) ~= "function" then
    log_error_format("DelegateContainer:_AddDataListener. superData[%s] is not a function, type:%s", addFuncName, type(addFunc))
    return
  end
  local args = table_pack(...)
  local FuncWrap = function(...)
    return common.CallCombinationArgs(handleFunc, args, ...)
  end
  if fullKey then
    addFunc(superData, fullKey, FuncWrap)
  else
    addFunc(superData, FuncWrap)
  end
  local key = fullKey or superData
  local listenerList = dataListener[key]
  if not listenerList then
    listenerList = {}
    dataListener[key] = listenerList
  end
  listenerList[#listenerList + 1] = FuncWrap
end
function DelegateContainer:RemoveDataListener(superData, fieldName)
  self:_RemoveDataListener("_dataListeners", "RemoveListener", superData, fieldName)
end
function DelegateContainer:RemoveDataNewIndexListener(superData)
  self:_RemoveDataListener("_dataNewIndexListeners", "RemoveNewIndexListener", superData)
end
function DelegateContainer:_RemoveDataListener(listenerSetName, removeFuncName, superData, fieldName)
  if not assert(self[listenerSetName][superData], "DelegateContainer:_RemoveDataListener self[listenerSetName][superData]") then
    return
  end
  local fullKey = fieldName
  local listenerList = self[listenerSetName][superData][fullKey]
  if listenerList then
    if fullKey then
      for i = 1, #listenerList do
        superData[removeFuncName](superData, fullKey, listenerList[i])
      end
    else
      for i = 1, #listenerList do
        superData[removeFuncName](superData, listenerList[i])
      end
    end
  end
  self[listenerSetName][superData][fullKey or superData] = nil
end
function DelegateContainer:AddLeafDataNewIndexListener(superDataLeaf, handleFunc, ...)
  if not self._leafDataNewIndexListener then
    self._leafDataNewIndexListener = {}
  end
  local dataListeners = self._leafDataNewIndexListener[superDataLeaf]
  if not dataListeners then
    dataListeners = {}
    self._leafDataNewIndexListener[superDataLeaf] = dataListeners
  end
  local args = table_pack(...)
  local FuncWrap = function(...)
    return common.CallCombinationArgs(handleFunc, args, ...)
  end
  superDataLeaf:AddNewIndexListener(FuncWrap)
  dataListeners[#dataListeners + 1] = FuncWrap
end
function DelegateContainer:RemoveLeafDataNewIndexListener(superDataLeaf)
  if not self._leafDataNewIndexListener then
    self._leafDataNewIndexListener = {}
  end
  local dataListeners = self._leafDataNewIndexListener[superDataLeaf]
  if dataListeners then
    for i = 1, #dataListeners do
      superDataLeaf:RemoveNewIndexListener(dataListeners[i])
    end
  end
  self._leafDataNewIndexListener[superDataLeaf] = nil
end
function DelegateContainer:GetSuperData()
  if self._SuperData then
    return self._SuperData
  end
  local SuperData = require("common.super_data")
  self._SuperData = SuperData.CreateSuperData(self:_DataDefine())
  return self._SuperData
end
function DelegateContainer:SetSuperData(Key, Value)
  local SuperData = self:GetSuperData()
  if SuperData[Key] then
    SuperData[Key] = Value
  end
end
function DelegateContainer:_DataDefine()
  return {}
end
function DelegateContainer:AddAttrModifyListener(attrModifyComp, name, handleFunc, ...)
  if not assert(type(handleFunc) == "function", "DelegateContainer:AddAttrModifyListener. handleFunc is not a function") then
    return
  end
  local args = table_pack(...)
  local funcWrap = function(...)
    return common.CallCombinationArgs(handleFunc, args, ...)
  end
  if not self._attrModifyListeners then
    self._attrModifyListeners = {}
  end
  local componentListeners = self._attrModifyListeners[attrModifyComp]
  if not componentListeners then
    componentListeners = {}
    self._attrModifyListeners[attrModifyComp] = componentListeners
  end
  local oldFunc = componentListeners[name]
  if oldFunc then
    attrModifyComp:RemoveAttrListener(name, oldFunc)
  end
  attrModifyComp:AddAttrListener(name, funcWrap)
  componentListeners[name] = funcWrap
end
function DelegateContainer:RemoveAttrModifyListener(attrModifyComp, name)
  if not self._attrModifyListeners then
    self._attrModifyListeners = {}
  end
  local componentListeners = self._attrModifyListeners[attrModifyComp]
  if not componentListeners then
    return false
  end
  local func = componentListeners[name]
  attrModifyComp:RemoveAttrListener(name, func)
  componentListeners[name] = nil
end
function DelegateContainer:AddLuaNetPropListener(actor, propName, handleFunc, ...)
  if not assert(type(propName) == "string", "DelegateContainer:AddLuaNetPropListener. propName is not a string") then
    return
  end
  if not assert(type(handleFunc) == "function", "DelegateContainer:AddLuaNetPropListener. handleFunc is not a function") then
    return
  end
  local args = table_pack(...)
  local funcWrap = function(...)
    return common.CallCombinationArgs(handleFunc, args, ...)
  end
  if not self._luaNetListeners then
    self._luaNetListeners = {}
  end
  local listeners = self._luaNetListeners[actor]
  if not listeners then
    listeners = {}
    self._luaNetListeners[actor] = listeners
  end
  local oldFunc = listeners[propName]
  if oldFunc then
    actor:RemoveLuaNetListener(propName, oldFunc)
    listeners[propName] = nil
  end
  if actor:AddLuaNetListener(propName, funcWrap) then
    listeners[propName] = funcWrap
    funcWrap(actor[propName])
  end
end
function DelegateContainer:RemoveLuaNetPropListener(actor, propName)
  if not self._luaNetListeners then
    return
  end
  if not assert(slua_isValid(actor), "DelegateContainer:RemoveLuaNetPropListener. not actor") then
    return
  end
  if not assert(type(propName) == "string", "DelegateContainer:RemoveLuaNetPropListener. propName is not a string") then
    return
  end
  local listeners = self._luaNetListeners[actor]
  if not listeners then
    return
  end
  local oldFunc = listeners[propName]
  if oldFunc then
    actor:RemoveLuaNetListener(propName, oldFunc)
    listeners[propName] = nil
  end
end
function DelegateContainer:_UnRegistEventsCommon()
  if self._commonEvents then
    for eventType, events in pairs(self._commonEvents) do
      for eventID, eventFunc in pairs(events) do
        EventSystem:unregistEvent(eventType, eventID, eventFunc)
      end
      self._commonEvents[eventType] = nil
    end
    self._commonEvents = nil
  end
end
function DelegateContainer:_UnRegistEventsControl()
  local _RemoveEvents = self._RemoveEvents
  if _RemoveEvents then
    for num, eventDelegate in pairs(_RemoveEvents) do
      if slua_isValid(eventDelegate) then
        eventDelegate:Remove(num)
      else
        slua_removeDelegate(num)
      end
    end
  end
  local _ClearEvents = self._ClearEvents
  if _ClearEvents then
    for num, eventDelegate in pairs(_ClearEvents) do
      if slua_isValid(eventDelegate) then
        eventDelegate:Clear()
      else
        slua_removeDelegate(num)
      end
    end
  end
  self._RemoveEvents = nil
  self._ClearEvents = nil
  self._controlEvents = nil
end
function DelegateContainer:BindLuaObjEvent(LuaObj, eventName, handleFunc, ...)
  if not (LuaObj and eventName) or not handleFunc then
    return false
  end
  if IsEditor and type(eventName) ~= "string" then
    log_error("Error: BindLuaObjEvent eventName must be a string, got " .. type(eventName))
    return false
  end
  local luaEventContainer = LuaObj.LuaEventContainer
  if luaEventContainer then
    local eventContainerSet = LuaObj._LuaEventContainerSet
    if not eventContainerSet then
      eventContainerSet = {}
      LuaObj._LuaEventContainerSet = eventContainerSet
      local LuaTable = LuaObj._GetRawClass and LuaObj:_GetRawClass() or LuaObj
      self:_UpdateLuaEventContainerSet(LuaObj, LuaTable)
    end
    if not eventContainerSet[eventName] then
      return false
    end
  end
  local objEventContainer = LuaObj._LuaObjEventContainer
  if not objEventContainer then
    objEventContainer = {
      _LuaObjEvents = {}
    }
    LuaObj._LuaObjEventContainer = objEventContainer
  end
  local objEvents = objEventContainer._LuaObjEvents
  local args = table_pack(...)
  local PackFunAndArgs = {handleFunc, args}
  local PackLuaEvents = objEvents[eventName]
  if not PackLuaEvents then
    PackLuaEvents = {}
    objEvents[eventName] = PackLuaEvents
  end
  PackLuaEvents[self] = PackFunAndArgs
  local objListener = self._LuaObjListener
  if not objListener then
    objListener = {}
    self._LuaObjListener = objListener
  end
  local controlListeners = objListener[objEventContainer]
  if not controlListeners then
    controlListeners = {}
    objListener[objEventContainer] = controlListeners
  end
  controlListeners[eventName] = handleFunc
  return true
end
function DelegateContainer:_UpdateLuaEventContainerSet(LuaObj, RawClass)
  if RawClass then
    if RawClass.LuaEventContainer then
      for _, str in ipairs(RawClass.LuaEventContainer) do
        if LuaObj._LuaEventContainerSet[str] then
          log(bWriteLog and string_format("BindLuaObjEvent, Declared duplicate event names %s in %s !!", str, LuaObj))
        end
        LuaObj._LuaEventContainerSet[str] = true
      end
    end
    local superClass = RawClass.__super
    if superClass and superClass.__inner_impl then
      self:_UpdateLuaEventContainerSet(LuaObj, superClass.__inner_impl)
    end
  end
end
function DelegateContainer:_GetRawClass()
  return self
end
function DelegateContainer:UnBindLuaObjEvent(LuaObj, eventName)
  if not LuaObj then
    return
  end
  if not LuaObj._LuaObjEventContainer then
    return
  end
  if not LuaObj._LuaObjEventContainer._LuaObjEvents then
    return
  end
  local PackLuaEvents = LuaObj._LuaObjEventContainer._LuaObjEvents[eventName]
  if not PackLuaEvents then
    return
  end
  PackLuaEvents[self] = nil
  if not self._LuaObjListener then
    return
  end
  local controlListeners = self._LuaObjListener[LuaObj._LuaObjEventContainer]
  if controlListeners then
    controlListeners[eventName] = nil
  end
end
function DelegateContainer:UnBindAllEvent(eventName)
  for LuaObjEventContainer, controlListeners in pairs(self._LuaObjListener) do
    for CacheEventName, HandleFunc in pairs(controlListeners) do
      if eventName == CacheEventName then
        if not LuaObjEventContainer then
          return
        end
        if not LuaObjEventContainer._LuaObjEvents then
          return
        end
        local PackLuaEvents = LuaObjEventContainer._LuaObjEvents[eventName]
        if not PackLuaEvents then
          return
        end
        PackLuaEvents[self] = nil
        controlListeners[eventName] = nil
      end
    end
  end
end
function DelegateContainer:LuaBroadcast(eventName, ...)
  if self._LuaObjEventContainer and self._LuaObjEventContainer._LuaObjEvents then
    local PackLuaEvents = self._LuaObjEventContainer._LuaObjEvents[eventName]
    if not PackLuaEvents then
      return
    end
    for EventListener, args in pairs(PackLuaEvents) do
      common.CallCombinationArgs(args[1], args[2], ...)
    end
  end
end
function DelegateContainer:LuaBroadcastCpp(eventName, ...)
  if self._LuaObjEventContainer and self._LuaObjEventContainer._LuaObjEvents then
    local PackLuaEvents = self._LuaObjEventContainer._LuaObjEvents[eventName]
    if not PackLuaEvents then
      return
    end
    for EventListener, args in pairs(PackLuaEvents) do
      common.CallCombinationArgs(args[1], args[2], ...)
    end
  end
end
function DelegateContainer:LuaBroadcastCommonEventCpp(EventType, EventID, ...)
  if self.LuaEventContainer then
    if not self._LuaEventContainerSet then
      self._LuaEventContainerSet = {}
      local LuaTable = self:_GetRawClass()
      self:_UpdateLuaEventContainerSet(self, LuaTable)
    end
    if self._LuaEventContainerSet[EventID] then
      self:LuaBroadcast(EventID, ...)
    end
  end
  EventSystem:postEvent(_G[EventType], _G[EventID], ...)
end
function DelegateContainer:AddTimer(delay, func)
  if not self._times then
    self._times = {}
  end
  local handle
  handle = time_ticker.AddTimer(delay, function(...)
    func(...)
    self._times[handle] = nil
  end)
  self._times[handle] = true
  return handle
end
function DelegateContainer:AddTimerLoop(delay, func, count, timeInterval)
  if not self._times then
    self._times = {}
  end
  local handle
  handle = time_ticker.AddTimerLoop(delay, func, count, timeInterval)
  self._times[handle] = true
  return handle
end
function DelegateContainer:AddTimerOnce(delay, func)
  if not self._times then
    self._times = {}
  end
  local handle
  handle = time_ticker.AddTimerOnce(delay, function(...)
    func(...)
    self._times[handle] = nil
  end)
  self._times[handle] = true
  return handle
end
function DelegateContainer:RemoveTimer(handle)
  if not self._times then
    self._times = {}
  end
  time_ticker.RemoveTimer(handle)
  self._times[handle] = nil
  return true
end
function DelegateContainer:AddGameTimer(nTime, bLoop, fCallback)
  if not self._gameTimers then
    self._gameTimers = {}
  end
  local gameTimers = self._gameTimers
  local nTimerID
  nTimerID = Game:SetTimer(nTime, bLoop, function(...)
    fCallback(...)
    if not bLoop and gameTimers ~= nil and nTimerID ~= nil then
      gameTimers[nTimerID] = nil
    end
  end)
  if nTimerID ~= nil and gameTimers ~= nil then
    gameTimers[nTimerID] = true
  end
  return nTimerID
end
function DelegateContainer:RemoveGameTimer(nTimerID)
  if not nTimerID then
    return false
  end
  if not self._gameTimers then
    self._gameTimers = {}
  end
  Game:ClearTimer(nTimerID)
  self._gameTimers[nTimerID] = nil
  return true
end
function DelegateContainer:TryRemoveNamedGameTimer(Name, this)
  if this == nil then
    this = self
  end
  if this[Name] then
    self:RemoveGameTimer(this[Name])
    this[Name] = nil
    return true
  end
  return false
end
function DelegateContainer:AddLoopTimerWithLifeTime(nLifeTime, nLoopInterval, fCallback)
  local TempLoopTimer = self:AddGameTimer(nLoopInterval, true, fCallback)
  self:AddGameTimer(nLifeTime, false, function()
    if TempLoopTimer then
      self:RemoveGameTimer(TempLoopTimer)
      TempLoopTimer = nil
    end
  end)
end
function DelegateContainer:AsyncLoadAsset(assetPath, handleFunc, ...)
  if not self._loadedDelegates then
    self._loadedDelegates = {}
  end
  local HandleID = asset_util.GetAssetAsync(assetPath, handleFunc, ...)
  log(bWriteLog and string_format("DelegateContainer:AsyncLoadAsset. AssetPath=%s", tostring(assetPath)))
  if HandleID ~= asset_util.loadFromCacheHandleID then
    self._loadedDelegates[HandleID] = true
  end
  return HandleID
end
function DelegateContainer:AsyncLoadAssetArray(assetPathArray, handleFunc)
  if not self._loadedDelegates then
    self._loadedDelegates = {}
  end
  local HandleID = asset_util.GetAssetsArrayAsyncParallel(assetPathArray, handleFunc, self)
  log(bWriteLog and string_format("DelegateContainer:AsyncLoadAsset. assetPathArray Num=%d", #assetPathArray))
  if HandleID ~= asset_util.loadFromCacheHandleID then
    self._loadedDelegates[HandleID] = true
  end
  return HandleID
end
function DelegateContainer:CancelAsyncLoad(handle)
  if self._loadedDelegates and self._loadedDelegates[handle] then
    asset_util.CancelAssetAsync(handle)
    self._loadedDelegates[handle] = nil
  end
end
function DelegateContainer:AddSettingOptionEvent(OptionName, handleFunc, bInitialCall)
  if not assert(OptionName and handleFunc, "DelegateContainer:AddSettingOptionEvent param invalid") then
    return false
  end
  local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
  if not self._settingOptionListeners then
    self._settingOptionListeners = {}
  end
  local bSuccess = SettingModule:AddOptionValueChangeEvent(OptionName, handleFunc, bInitialCall)
  if bSuccess then
    self._settingOptionListeners[OptionName] = true
  end
  return bSuccess
end
function DelegateContainer:RemoveSettingOptionEvent(OptionName)
  if not assert(OptionName, "DelegateContainer:AddSettingOptionEvent param invalid") then
    return false
  end
  if not self._settingOptionListeners then
    return
  end
  if not self._settingOptionListeners[OptionName] then
    return
  end
  local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
  SettingModule:RemoveOptionValueChangeEvent(OptionName)
  self._settingOptionListeners[OptionName] = nil
end
function DelegateContainer:RemoveAllSettingOptionEvent()
  if not self._settingOptionListeners then
    return
  end
  local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
  for OptionName, _ in pairs(self._settingOptionListeners) do
    SettingModule:RemoveOptionValueChangeEvent(OptionName)
  end
  self._settingOptionListeners = nil
end
local class = require("class")
local object = require("object")
local CDelegateContainer = class(object, nil, DelegateContainer)
return CDelegateContainer