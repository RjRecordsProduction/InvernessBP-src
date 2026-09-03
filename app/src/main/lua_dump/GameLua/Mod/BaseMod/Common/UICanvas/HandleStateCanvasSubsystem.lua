local HandleStateCanvasSubsystem = {}
function HandleStateCanvasSubsystem:ctor(SelfType)
  self.CanvasProxyCache = {}
  self.CollectControlEvents = {}
  self.CollectCommonEvents = {}
end
function HandleStateCanvasSubsystem:OnInit()
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) then
    self:AddControlEvent(uPlayerController, "PlayerControllerRespawnedDelegate", function()
      print(bWriteLog and "HandleStateCanvasSubsystem OnInit: PlayerControllerRespawnedDelegate Callback")
      self:ReRegisterCanvasVisibleEvent()
    end)
    local uPlayerCharacter = uPlayerController:GetPlayerCharacterSafety()
    if slua.isValid(uPlayerCharacter) then
      self:AddControlEvent(uPlayerCharacter, "OnPawnRespawnDelegate", function()
        print(bWriteLog and "HandleStateCanvasSubsystem OnInit: OnPawnRespawnDelegate Callback")
        self:ReRegisterCanvasVisibleEvent()
      end)
    end
  end
end
function HandleStateCanvasSubsystem:OnRelease()
  self:UnCollectEvents()
  if self.CanvasProxyCache then
    for _, CanvasProxy in pairs(self.CanvasProxyCache) do
      if CanvasProxy then
        CanvasProxy:Release()
      end
    end
  end
  self.CanvasProxyCache = nil
  self.CollectControlEvents = {}
  self.CollectCommonEvents = nil
  HandleStateCanvasSubsystem.__super.OnRelease(self)
end
function HandleStateCanvasSubsystem:ReRegisterCanvasVisibleEvent()
  if self.CanvasProxyCache == nil then
    return
  end
  for uCanvasPanel, CanvasProxy in pairs(self.CanvasProxyCache) do
    if CanvasProxy then
      CanvasProxy:ReInit()
    end
  end
end
function HandleStateCanvasSubsystem:RegisterCanvasVisibleEvent(uCanvasPanel, uCanvasUIRoot, tConfig)
  if self.CanvasProxyCache == nil then
    self.CanvasProxyCache = {}
  end
  if slua.isValid(uCanvasPanel) then
    self:UnRegisterCanvasVisibleEvent(uCanvasPanel)
  end
  if slua.isValid(uCanvasPanel) then
    local CanvasProxyClass = require("GameLua.Mod.BaseMod.Common.UICanvas.HandleStateCanvasProxy")
    self.CanvasProxyCache[uCanvasPanel] = CanvasProxyClass(uCanvasPanel, uCanvasUIRoot)
    self.CanvasProxyCache[uCanvasPanel]:Init(tConfig)
  end
end
function HandleStateCanvasSubsystem:UnRegisterCanvasVisibleEvent(uCanvasPanel)
  if self.CanvasProxyCache and slua.isValid(uCanvasPanel) and self.CanvasProxyCache[uCanvasPanel] then
    self.CanvasProxyCache[uCanvasPanel]:Release()
    self.CanvasProxyCache[uCanvasPanel] = nil
  end
end
function HandleStateCanvasSubsystem:CollectControlEvent(canvasProxy, control, eventName, handleFunc, ...)
  if not assert(control ~= nil, "HandleStateCanvasSubsystem:CollectControlEvent control should not be nil") then
    return
  end
  if canvasProxy == nil then
    return
  end
  if self.CollectCommonEvents == nil then
    return
  end
  local eventDelegate = control[eventName]
  local controlEvents = self.CollectControlEvents[control]
  if not controlEvents then
    controlEvents = {}
    self.CollectControlEvents[control] = controlEvents
  end
  local collectCanvas = controlEvents[eventName]
  if collectCanvas == nil then
    collectCanvas = {}
    self.CollectControlEvents[control][eventName] = collectCanvas
  end
  if collectCanvas then
    if collectCanvas.CanvasList == nil then
      collectCanvas.CanvasList = {}
      self.CollectControlEvents[control][eventName].CanvasList = collectCanvas.CanvasList
    end
    collectCanvas.CanvasList[canvasProxy] = {
      handleFunc = handleFunc,
      args = table.pack(...)
    }
    if eventDelegate and collectCanvas.FuncDelegate == nil then
      if eventDelegate.Add then
        collectCanvas.FuncDelegate = eventDelegate:Add(function(...)
          local common = require("client.slua_ui_framework.common")
          for tempCanvasProxy, params in pairs(self.CollectControlEvents[control][eventName].CanvasList) do
            if tempCanvasProxy and tempCanvasProxy:IsValid() then
              common.CallCombinationArgs(params.handleFunc, params.args, ...)
            end
          end
        end)
      else
        collectCanvas.FuncDelegate = eventDelegate:Bind(function(...)
          local common = require("client.slua_ui_framework.common")
          for tempCanvasProxy, params in pairs(self.CollectControlEvents[control][eventName].CanvasList) do
            if tempCanvasProxy and tempCanvasProxy:IsValid() then
              common.CallCombinationArgs(params.handleFunc, params.args, ...)
            end
          end
        end)
      end
    end
  end
  return true
end
function HandleStateCanvasSubsystem:UnCollectControlEvent(canvasProxy, control, eventName)
  if not assert(control ~= nil, "HandleStateCanvasSubsystem:UnCollectControlEvent control should not be nil") then
    return false
  end
  if self.CollectCommonEvents == nil then
    return
  end
  local controlEvents = self.CollectControlEvents[control]
  if not controlEvents then
    return false
  end
  local collectCanvas = controlEvents[eventName]
  if not collectCanvas then
    return false
  end
  if type(control) == "table" or slua.isValid(control) then
    local bRemove = true
    collectCanvas.CanvasList[canvasProxy] = nil
    for tempCanvasProxy, params in pairs(collectCanvas.CanvasList) do
      if tempCanvasProxy and tempCanvasProxy:IsValid() then
        bRemove = false
        break
      end
    end
    if bRemove then
      local eventDelegate = control[eventName]
      if eventDelegate then
        if eventDelegate.Remove then
          eventDelegate:Remove(collectCanvas.FuncDelegate)
        else
          eventDelegate:Clear()
        end
        controlEvents[eventName] = nil
        return true
      end
    end
  end
  return false
end
function HandleStateCanvasSubsystem:CollectCommonEvent(canvasProxy, eventType, eventID, handleFunc, ...)
  if not assert(type(eventType) == "number", "CollectCommonEvent eventType should be number ") then
    return
  end
  if not assert(type(eventID) == "number", "CollectCommonEvent eventID should be number ") then
    return
  end
  if not assert(type(handleFunc) == "function", "CollectCommonEvent handleFunc should be function ") then
    return
  end
  if self.CollectCommonEvents == nil then
    return
  end
  local events = self.CollectCommonEvents[eventType]
  if not events then
    events = {}
    self.CollectCommonEvents[eventType] = events
  end
  require("client.common.event.EventProxy")
  local collectCanvas = events[eventID]
  if collectCanvas == nil then
    collectCanvas = {}
    self.CollectCommonEvents[eventType][eventID] = collectCanvas
  end
  if collectCanvas then
    if collectCanvas.CanvasList == nil then
      collectCanvas.CanvasList = {}
      self.CollectCommonEvents[eventType][eventID].CanvasList = collectCanvas.CanvasList
    end
    collectCanvas.CanvasList[canvasProxy] = {
      handleFunc = handleFunc,
      args = table.pack(...)
    }
    if collectCanvas.EventFunc == nil then
      function collectCanvas.EventFunc(...)
        local common = require("client.slua_ui_framework.common")
        for tempCanvasProxy, params in pairs(self.CollectCommonEvents[eventType][eventID].CanvasList) do
          if tempCanvasProxy and tempCanvasProxy:IsValid() then
            common.CallCombinationArgs(params.handleFunc, params.args, ...)
          end
        end
      end
      EventSystem:registEvent(eventType, eventID, collectCanvas.EventFunc)
    end
  end
end
function HandleStateCanvasSubsystem:UnCollectCommonEvent(canvasProxy, eventType, eventID)
  if not assert(type(eventType) == "number" and type(eventID) == "number", "UnCollectCommonEvent eventType should be number and eventID should be number") then
    return
  end
  if self.CollectCommonEvents == nil then
    return
  end
  local events = self.CollectCommonEvents[eventType]
  if not events then
    if _errorLog then
      _errorLog(string.format("HandleStateCanvasSubsystem Can't remove event because eventType's[%s] events not found", eventType))
    end
    return
  end
  local collectCanvas = events[eventID]
  if not collectCanvas then
    if _errorLog then
      _errorLog(string.format("HandleStateCanvasSubsystem Can't remove event because event not found for eventType[%s], eventID[%s] 0", eventType, eventID))
    end
    return
  end
  if not collectCanvas.EventFunc then
    if _errorLog then
      _errorLog(string.format("HandleStateCanvasSubsystem Can't remove event because event not found for eventType[%s], eventID[%s] 1", eventType, eventID))
    end
    return
  end
  local bRemove = true
  collectCanvas.CanvasList[canvasProxy] = nil
  for tempCanvasProxy, params in pairs(collectCanvas.CanvasList) do
    if tempCanvasProxy and tempCanvasProxy:IsValid() then
      bRemove = false
      break
    end
  end
  if bRemove then
    require("client.common.event.EventProxy")
    if EventSystem:unregistEvent(eventType, eventID, collectCanvas.EventFunc) then
      events[eventID] = nil
      return true
    end
  end
  return false
end
function HandleStateCanvasSubsystem:UnCollectEvents()
  if self.CollectControlEvents then
    for control, events in pairs(self.CollectControlEvents) do
      if type(control) == "table" or slua.isValid(control) then
        for eventName, collectCanvas in pairs(events) do
          local eventDelegate = control[eventName]
          if eventDelegate then
            if eventDelegate.Remove then
              pcall(eventDelegate.Remove, eventDelegate, collectCanvas.FuncDelegate)
            else
              pcall(eventDelegate.Clear, eventDelegate)
            end
          end
        end
      else
        if log ~= nil then
          log(bWriteLog and "HandleStateCanvasSubsystem:UnCollectEvent by removeDelegate!")
        end
        for _, collectCanvas in pairs(events) do
          if collectCanvas.FuncDelegate then
            pcall(slua.removeDelegate, collectCanvas.FuncDelegate)
          end
        end
      end
      self.CollectControlEvents[control] = nil
    end
  end
  require("client.common.event.EventProxy")
  if self.CollectCommonEvents then
    for eventType, events in pairs(self.CollectCommonEvents) do
      for eventID, collectCanvas in pairs(events) do
        EventSystem:unregistEvent(eventType, eventID, collectCanvas.EventFunc)
      end
      self.CollectCommonEvents[eventType] = nil
    end
  end
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, HandleStateCanvasSubsystem)