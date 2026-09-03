local PlayerEventSystemEntry = {IsInit = false}
function PlayerEventSystemEntry:GetGameState()
  local uGameState = CGameState
  if uGameState == nil then
    uGameState = slua_GameFrontendHUD:GetGameState()
  end
  return uGameState
end
function PlayerEventSystemEntry:GetBaseConfigIndex(InBaseEventConfig, NewItem)
  if NewItem == nil or type(NewItem) ~= "table" then
    return nil
  end
  for i, item in ipairs(InBaseEventConfig) do
    if item and item.eventType == NewItem.eventType and item.eventID == NewItem.eventID then
      return i
    end
  end
  return nil
end
function PlayerEventSystemEntry:Init(InGameState, bClient)
  if bClient then
    print(bWriteLog and "PlayerEventSystemEntry Init bClient true")
  else
    print(bWriteLog and "PlayerEventSystemEntry Init bClient false")
  end
  require("client.common.event.EventProxy")
  require("GameLua.Mod.BaseMod.Common.Global")
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  local EventConfigPath = "GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEvents.Config.PlayerEventConfig"
  local BaseEventConfig = require(EventConfigPath)
  if FuncUtil == nil then
    FuncUtil = require("common.func_util")
  end
  local TableUtil = require("common.table_util")
  self.EventConfig = TableUtil.CopyTable(BaseEventConfig)
  if self.EventConfig == nil then
    self.EventConfig = {}
  end
  local EventModConfigPath = GamePlayTools.GetModPath(bClient, "PlayerEventSystem.PlayerEvents.Config.PlayerEventConfig", true)
  if EventConfigPath ~= EventModConfigPath then
    local ModEventConfig = require(EventModConfigPath)
    for _, config in pairs(ModEventConfig) do
      local oldIndex = self:GetBaseConfigIndex(BaseEventConfig, config)
      if oldIndex ~= nil then
        self.EventConfig[oldIndex] = config
      else
        self.EventConfig[#self.EventConfig + 1] = config
      end
    end
  end
  BaseEventConfig = nil
  self.EventDataMgr = require(GamePlayTools.GetModPath(bClient, "PlayerEventSystem.PlayerEventData.PlayerEventDataMgr", true))
  self.EventDataMgr:Init(bClient)
  self.EventActionMgr = require(GamePlayTools.GetModPath(bClient, "PlayerEventSystem.PlayerEventAction.PlayerEventActionMgr", true))
  self.EventActionMgr:Init(bClient, InGameState)
  self.ConditionEntry = require("GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEventAction.Condition.ConditionEntry")
  self.EventHandles = {}
  self.  self.EventListnerFuncs = {}
  for _, config in pairs(self.EventConfig) do
    local eventHandle = self.EventHandles[config.moduleName]
    if eventHandle == nil then
      local m = require(config.moduleName)
      eventHandle = m()
      if eventHandle.Init ~= nil then
        eventHandle:Init(self:GetGameState(), self.bClient, self.EventDataMgr, self.EventActionMgr)
      end
      self.EventHandles[config.moduleName] = eventHandle
    end
    local FuncWrap = function(eventType, eventID, ...)
      if self.EventHandles == nil then
        return
      end
      local CurEventHandle = self.EventHandles[config.moduleName]
      if CurEventHandle then
        local CurFunc = CurEventHandle[config.funcName]
        assert(CurFunc ~= nil, "Function not found in module")
        CurFunc(CurEventHandle, eventType, eventID, ...)
      end
    end
    if config.eventType ~= nil and config.eventID ~= nil then
      if self.EventListnerFuncs[config.eventType] == nil then
        self.EventListnerFuncs[config.eventType] = {}
      end
      if self.EventListnerFuncs[config.eventType][config.eventID] == nil then
        self.EventListnerFuncs[config.eventType][config.eventID] = {}
      end
      local ListnerFuncsRef = self.EventListnerFuncs[config.eventType][config.eventID]
      ListnerFuncsRef[#ListnerFuncsRef + 1] = FuncWrap
      EventSystem:registEvent(config.eventType, config.eventID, FuncWrap)
    end
  end
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uSelfCharacter = GameplayData.GetPlayerCharacter()
  if slua.isValid(uSelfCharacter) then
    self:CheckInitDSData(uSelfCharacter.PlayerKey)
  end
  EventSystem:postEvent(EVENTTYPE_PLAYEREVENT_CHARACTER, EVENTTYPE_PLAYEREVENT_CHARACTER_EVENTMGR_INIT)
end
function PlayerEventSystemEntry:ClearPlayer(nPlayerKey)
  local ConditionEntry = require("GameLua.Mod.BaseMod.PlayerEventSystem.PlayerEventAction.Condition.ConditionEntry")
  ConditionEntry.DeactivateEventsByFilterKey(nPlayerKey)
  if self.EventActionMgr then
    self.EventActionMgr:Clear(nPlayerKey)
  end
end
function PlayerEventSystemEntry:Clear()
  if type(self.EventListnerFuncs) == "table" then
    for eType, eventIDFuncs in pairs(self.EventListnerFuncs) do
      if type(eventIDFuncs) == "table" then
        for eventID, FuncTable in pairs(eventIDFuncs) do
          if type(FuncTable) == "table" then
            for _, Func in pairs(FuncTable) do
              EventSystem:unregistEvent(eType, eventID, Func)
            end
          end
        end
      end
    end
  end
  self.EventListnerFuncs = nil
  if self.EventActionMgr then
    self.EventActionMgr:ClearAll()
  end
  if self.EventDataMgr then
    self.EventDataMgr:Clear()
  end
  if self.EventHandles ~= nil then
    for k, v in pairs(self.EventHandles) do
      if v then
        v:Clear()
      end
    end
  end
  self.EventActionMgr = nil
  self.EventDataMgr = nil
  self.EventConfig = nil
  self.EventHandles = nil
  self.ConditionEntry = nil
end
function PlayerEventSystemEntry:ActiveEventByFilterKey(FilterKey, EventTypeStr, EventIDStr, bActive)
  if self.ConditionEntry then
    self.ConditionEntry.ActiveEventByFilterKey(FilterKey, EventTypeStr, EventIDStr, bActive)
  end
end
function PlayerEventSystemEntry:DeactivateEventsByFilterKey(FilterKey)
  if self.ConditionEntry then
    self.ConditionEntry.DeactivateEventsByFilterKey(FilterKey)
  end
end
function PlayerEventSystemEntry:CheckNeedPostEventWithFilterKey(FilterKey, EventTypeStr, EventIDStr, bCheckPostToLua)
  if self.ConditionEntry then
    return self.ConditionEntry.CheckNeedPostEventWithFilterKey(FilterKey, EventTypeStr, EventIDStr, bCheckPostToLua)
  end
  return false
end
function PlayerEventSystemEntry:CheckInitDSData(nPlayerKey)
  print(bWriteLog and "PlayerEventSystemEntry:CheckInitDSData nPlayerKey:" .. tostring(nPlayerKey))
  if self.EventHandles ~= nil then
    print(bWriteLog and "PlayerEventSystemEntry:CheckInitDSData self.EventHandles ~= nil nPlayerKey:" .. tostring(nPlayerKey))
    for k, v in pairs(self.EventHandles) do
      if v then
        v:CheckInitDSData(nPlayerKey)
      end
    end
  end
end
function PlayerEventSystemEntry:OnInit()
  local CurGameState = self:GetGameState()
  if CurGameState == nil then
    print(bWriteLog and "PlayerEventSystemEntry OnInit CurGameState == nil")
    return
  end
  if self.IsInit then
    return
  end
  self.IsInit = true
  print(bWriteLog and "PlayerEventSystemEntry OnInit self.IsInit = true")
  self:Init(self:GetGameState(), Client ~= nil)
end
function PlayerEventSystemEntry:OnRelease()
  self:Clear()
  self.IsInit = false
  print(bWriteLog and "PlayerEventSystemEntry OnRelease self.IsInit = false")
  PlayerEventSystemEntry.__super.OnRelease(self)
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, PlayerEventSystemEntry)