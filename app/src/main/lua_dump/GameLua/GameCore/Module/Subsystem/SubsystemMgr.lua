local SubsystemMgr = {
  HasInit = false,
  HasCallOnInit = false,
  HasPostCallOnInit = false,
  CurInitType = "",
  SubsystemMap = {},
  SubsystemOrderNames = {},
  PendingSubsystemMap = {}
}
local utility = require("common.utility")
function SubsystemMgr:InitDev(InitType)
  if not import("STExtraBlueprintFunctionLibrary").IsDevelopment() then
    return
  end
  local SubsystemConfig = require("GameLua.Mod.BaseMod.GamePlay.Config.SubsystemConfig_Dev")
  if not SubsystemConfig then
    sandbox.LogNormal(bWriteLog and "SubsystemMgr:InitDev() DevSubsystemConfig not exist")
    return
  end
  self:_RegisterSubsystems(SubsystemConfig, InitType, "Dev")
end
function SubsystemMgr:Init(InitType)
  if self.HasInit then
    sandbox.LogWarning("SubsystemMgr:Init() SubsystemMgr has init")
    return false
  end
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  local SubsystemConfig = GamePlayTools.GetCurrentConfig("SubsystemConfig")
  if not SubsystemConfig then
    sandbox.LogError("SubsystemMgr:Init() Get SubsystemConfig error")
    return
  end
  self:_RegisterSubsystems(SubsystemConfig, InitType)
  self.HasInit = true
  self.Cur  return true
end
function SubsystemMgr:_RegisterSubsystems(Configs, InitType, Tag)
  for Name, PendingSubsystem in pairs(self.PendingSubsystemMap) do
    print(bWriteLog and "SubsystemMgr:_RegisterSubsystems PendingSubsystem", Name)
    self.SubsystemMap[Name] = PendingSubsystem
  end
  self.PendingSubsystemMap = {}
  local IsInitBoth = InitType == "Both"
  for Name, Config in pairs(Configs) do
    if Config then
      local IsConfigMatch = Config.side == "Both" or Config.side == InitType
      local CanRegisterSubsystem = IsInitBoth or IsConfigMatch
      if CanRegisterSubsystem then
        local Order = Config.order or 0
        table.insert(self.SubsystemOrderNames, {
          Name = Name,
          Order = Order,
                  })
      end
    end
  end
  table.sort(self.SubsystemOrderNames, function(a, b)
    return a.Order < b.Order
  end)
  for _, Info in ipairs(self.SubsystemOrderNames) do
    if not self.SubsystemMap[Info.Name] then
      xpcall(self._Register, utility.ErrorMessageHandler, self, Info.Name, Info.Config, Tag, Info.Order)
    end
  end
end
function SubsystemMgr:_Register(Name, Config, Tag, Order)
  local ModulePath = Config.module
  if self.SubsystemMap[Name] then
    sandbox.LogError(string.format("SubsystemMgr already has the mod logic with name: %s", ModulePath))
    return
  end
  Tag = Tag or "Normal"
  local bDestroyOnReconnect = Config.bDestroyOnReconnect == nil and true or Config.bDestroyOnReconnect
  local SubsystemClass = require(ModulePath)
  local Subsystem = SubsystemClass(bDestroyOnReconnect)
  self.SubsystemMap[Name] = Subsystem
  printf("SubsystemMgr:Register[%s] Name = %s, ModulePath = %s, Order = %s", Tag, Name, ModulePath, Order or 0)
  self:_CallLifeCycleMethod(Subsystem, "OnRegister")
end
function SubsystemMgr:CallOnPreRep()
  if not Client then
    print(bWriteLog and "SubsystemMgr:CallOnPreRep() not client, return")
    return
  end
  self:_CallAllLifeCycleMethod("_PostConstruct")
end
function SubsystemMgr:CallOnInit()
  self.HasCallOnInit = true
  self:_CallAllLifeCycleMethod("OnInit")
  self.HasPostCallOnInit = true
  EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_ENTER_ALL_SUBSYSTEM_INIT)
end
function SubsystemMgr:_CallAllLifeCycleMethod(LifeCycleMethodName)
  printf("SubsystemMgr:CallLifeCycleMethod %s", LifeCycleMethodName)
  self:_IterateSubsystems(function(Name, Subsystem)
    self:_CallLifeCycleMethod(Subsystem, LifeCycleMethodName)
  end)
end
function SubsystemMgr:_CallLifeCycleMethod(Subsystem, LifeCycleMethodName)
  if Subsystem and Subsystem[LifeCycleMethodName] then
    xpcall(Subsystem[LifeCycleMethodName], utility.ErrorMessageHandler, Subsystem)
  end
end
function SubsystemMgr:_IterateSubsystems(Callback)
  for _, Info in ipairs(self.SubsystemOrderNames) do
    local Name = Info.Name
    local Subsystem = self.SubsystemMap[Name]
    Callback(Name, Subsystem)
  end
end
function SubsystemMgr:Get(Name)
  local Subsystem = self.SubsystemMap[Name]
  if not Subsystem then
    sandbox.LogWarning(string.format("SubsystemMgr can not find subsystem: %s", Name))
    return nil
  end
  return Subsystem
end
function SubsystemMgr:EndPlay(bReconnect)
  sandbox.LogNormal(bWriteLog and "SubsystemMgr:EndPlay")
  self:_IterateSubsystems(function(Name, Subsystem)
    if bReconnect and Subsystem and Subsystem.bDestroyOnReconnect == false then
      self.PendingSubsystemMap[Name] = Subsystem
    end
    if not self.PendingSubsystemMap[Name] and Subsystem then
      if Subsystem.OnRelease then
        xpcall(Subsystem.OnRelease, utility.ErrorMessageHandler, Subsystem)
      end
      if Subsystem.Dispose then
        xpcall(Subsystem.Dispose, utility.ErrorMessageHandler, Subsystem)
      end
    end
  end)
  self.HasCallOnInit = false
  self.HasPostCallOnInit = false
end
function SubsystemMgr:Destroy(bReconnect)
  sandbox.LogNormal(bWriteLog and "SubsystemMgr:Destroy")
  self.HasInit = false
  self.SubsystemMap = {}
  self.SubsystemOrderNames = {}
  if not bReconnect then
    self.PendingSubsystemMap = {}
  end
end
function SubsystemMgr:DynamicAddSubsystem(Name, Config)
  local Subsystem = self:Get(Name)
  if Subsystem then
    sandbox.LogNormal(bWriteLog and string.format("SubsystemMgr:DynamicAddSubsystem Had Register Name:%s", Name))
    return
  end
  sandbox.LogNormal(bWriteLog and string.format("SubsystemMgr:DynamicAddSubsystem Name:%s, Path:%s, Side:%s-%s", Name, Config.module, Config.side, self.CurInitType))
  local IsInitBoth = self.CurInitType == "Both"
  local IsConfigMatch = Config.side == "Both" or Config.side == self.CurInitType
  local CanRegisterSubsystem = IsInitBoth or IsConfigMatch
  if CanRegisterSubsystem then
    xpcall(self._Register, utility.ErrorMessageHandler, self, Name, Config)
    if GameStatus.IsInFightingStatus() then
      local Subsystem = self:Get(Name)
      if Subsystem then
        Subsystem.bDynamic = true
        if self.CurInitType == "DS" then
          self:_CallLifeCycleMethod(Subsystem, "OnInit")
        else
          self:_CallLifeCycleMethod(Subsystem, "_PostConstruct")
          local ClientGameMain = require("GameLua.GameCore.Main.ClientGameMain")
          if ClientGameMain.CurrentModeLogic and ClientGameMain.CurrentModeLogic.bHasInitModeUI then
            self:_CallLifeCycleMethod(Subsystem, "OnInit")
          end
        end
      end
    end
  end
end
function SubsystemMgr:DynamicRemoveSubsystem(Name)
  local Subsystem = self:Get(Name)
  if Subsystem and Subsystem.bDynamic then
    sandbox.LogNormal(bWriteLog and string.format("SubsystemMgr:DynamicRemoveSubsystem Name:%s", Name))
    if Subsystem.OnRelease then
      xpcall(Subsystem.OnRelease, utility.ErrorMessageHandler, Subsystem)
    end
    if Subsystem.Dispose then
      xpcall(Subsystem.Dispose, utility.ErrorMessageHandler, Subsystem)
    end
    self.SubsystemMap[Name] = nil
  else
    sandbox.LogNormal(bWriteLog and string.format("SubsystemMgr:DynamicRemoveSubsystem Has No Subsystem Name:%s, bDynamic:%s", Name, Subsystem and Subsystem.bDynamic or "Subsystem is nil"))
  end
end
return SubsystemMgr