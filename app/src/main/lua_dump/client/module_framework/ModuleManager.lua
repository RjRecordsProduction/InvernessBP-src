ModuleManager = {}
local local local local local local utility = require("common.utility")
local xpcallHandle = utility.ErrorMessageHandler
local local CommonModuleConfig = require("client.module_framework.common.ModuleConfig")
local LobbyModuleConfig = require("client.module_framework.lobby.ModuleConfig")
local JumpModuleConfig = require("client.module_framework.lobby.JumpModuleConfig")
local DataModuleConfig = require("client.slua.data.BasicData.Config.DataModuleConfig")
local ModuleMacro = require("client.module_framework.ModuleMacro")
local ModuleMacro_ModuleLevel = ModuleMacro.ModuleLevel
local Modules = {}
ModuleManager.ModuleManager.ModuleManager.ModuleManager.local ModulesLiteCopy = function()
  local rtnModules = {}
  for ModuleConfig, Module in pairs(Modules) do
    rtnModules[ModuleConfig] = Module
  end
  return rtnModules
end
local SetRegisted = function(moduleInstance, registed)
  moduleInstance._Registed = registed
end
local _IsSceneLevel = function(ModuleConfig)
  return ModuleConfig.ModuleLevel == nil or ModuleConfig.ModuleLevel == ModuleMacro_ModuleLevel.SceneLevel
end
local _IsAppLevel = function(ModuleConfig)
  return ModuleConfig.ModuleLevel == ModuleMacro_ModuleLevel.AppLevel
end
local ShouldSkipLogException = function(originalModule, ModuleConfig)
  local traceback = debug.traceback()
  if string.find(traceback, "time_ticker") then
    return true
  end
  for level = 3, 5 do
    local callerInfo = debug.getinfo(level, "f")
    if callerInfo and callerInfo.func then
      for k, v in pairs(originalModule) do
        if type(v) == "function" and v == callerInfo.func then
          return true
        end
      end
    end
  end
  return false
end
local _CreateModuleProxy = function(Module, ModuleConfig)
  local proxy = {}
  local original  setmetatable(proxy, {
    __index = function(t, key)
      if not originalModule._Registed and not ShouldSkipLogException(originalModule, ModuleConfig) then
        LogExceptionAndReport(string.format("[ModuleManager]Attempting to access destroyed module: %s, please check if any code is holding module references!", tostring(ModuleConfig.KeyName)) .. debug.traceback())
      end
      return originalModule[key]
    end,
    __newindex = function(t, key, value)
      if not originalModule._Registed and not ShouldSkipLogException(originalModule, ModuleConfig) then
        LogExceptionAndReport(string.format("[ModuleManager]Attempting to modify destroyed module: %s, please check if any code is holding module references!", tostring(ModuleConfig.KeyName)) .. debug.traceback())
      end
      originalModule[key] = value
    end,
    __call = function(t, ...)
      if not originalModule._Registed and not ShouldSkipLogException(originalModule, ModuleConfig) then
        LogExceptionAndReport(string.format("[ModuleManager]Attempting to call destroyed module: %s, please check if any code is holding module references!", tostring(ModuleConfig.KeyName)) .. debug.traceback())
      end
      return originalModule(...)
    end
  })
  return proxy
end
local _ModuleInit = function(ControllerMod)
  ControllerMod:DefineAndResetData()
  ControllerMod:OnInitialize()
  ControllerMod:RegistEvents()
end
local _SaveModule = function(ModuleConfig, ModuleClass)
  local ControllerMod = ModuleClass(ModuleConfig)
  SetRegisted(ControllerMod, true)
  xpcall(_ModuleInit, xpcallHandle, ControllerMod)
  Modules[ModuleConfig] = ControllerMod
  return ControllerMod
end
function ModuleManager.GetModule(ModuleConfig)
  local ControllerMod = Modules[ModuleConfig]
  if not ControllerMod then
    local ModuleClass = require(ModuleConfig.ModuleName)
    if type(ModuleClass) ~= "function" and type(ModuleClass) ~= "table" then
      log_error(string.format("[ModuleManager]Failed to load module: %s, require returned: %s", tostring(ModuleConfig.ModuleName), tostring(ModuleClass)))
      return nil
    end
    ControllerMod = _SaveModule(ModuleConfig, ModuleClass)
  elseif _IsSceneLevel(ModuleConfig) and not ControllerMod._Registed then
    xpcall(ControllerMod.RegistEvents, xpcallHandle, ControllerMod)
    SetRegisted(ControllerMod, true)
  end
  if Client and not Client.IsShipping() and ControllerMod then
    return _CreateModuleProxy(ControllerMod, ModuleConfig)
  end
  return ControllerMod
end
function ModuleManager.GetSplitModule(ModuleConfig)
  return ModuleManager.GetModule(ModuleConfig)
end
function ModuleManager.GetSplitModuleDownload(ModuleConfig, CallBack)
  local LobbyModUtils = require("GameLua.Mod.Lobby.Base.Common.LobbyModUtils")
  return LobbyModUtils.GetSplitModuleDownload(ModuleConfig, CallBack)
end
function ModuleManager.OnLogin(bReLogin)
  log(bWriteLog and "[ModuleManager]OnLogin bReLogin = ", tostring(bReLogin))
  local tempModules = ModulesLiteCopy()
  for ModuleConfig, Module in pairs(tempModules) do
    xpcall(Module.OnLogin, xpcallHandle, Module, bReLogin)
  end
end
function ModuleManager.OnPreSwitchGameStatus(_, _, vars)
  log(bWriteLog and "ModuleManager.OnPreSwitchGameStatus pre = " .. tostring(vars.pre) .. " current = " .. tostring(vars.current))
  local tempModules = ModulesLiteCopy()
  for ModuleConfig, Module in pairs(tempModules) do
    xpcall(Module.OnPreSwitchGameStatus, xpcallHandle, Module, vars.pre, vars.current)
    if _IsSceneLevel(ModuleConfig) then
      xpcall(Module.UnRegist, xpcallHandle, Module)
      SetRegisted(Module, false)
    end
  end
end
function ModuleManager.OnPostSwitchGameStatus(_, _, vars)
  log(bWriteLog and "ModuleManager.OnPostSwitchGameStatus pre = " .. tostring(vars.pre) .. " current = " .. tostring(vars.current))
  local StartupConfig = CommonModuleConfig.GetGameStatusStartConfig()
  local ConfigModuleName = StartupConfig[vars.current]
  if ConfigModuleName then
    local Configs = require(ConfigModuleName)
    for _, Config in pairs(Configs) do
      xpcall(ModuleManager.GetModule, xpcallHandle, Config)
    end
  end
  local tempModules = ModulesLiteCopy()
  for ModuleConfig, Module in pairs(tempModules) do
    xpcall(Module.OnPostSwitchGameStatus, xpcallHandle, Module, vars.pre, vars.current)
  end
end
function ModuleManager.OnLogOut(_, _)
  log(bWriteLog and "[ModuleManager]OnLogOut!")
  local tempModules = ModulesLiteCopy()
  for ModuleConfig, Module in pairs(tempModules) do
    xpcall(Module.OnLogOut, xpcallHandle, Module)
    if not _IsAppLevel(ModuleConfig) then
      xpcall(Module.UnRegist, xpcallHandle, Module)
      xpcall(Module.OnDestroy, xpcallHandle, Module)
      SetRegisted(Module, false)
      Modules[ModuleConfig] = nil
    end
  end
end
return ModuleManager