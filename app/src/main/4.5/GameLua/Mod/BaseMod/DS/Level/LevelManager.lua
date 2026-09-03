LevelManager = LevelManager or {}
local LogicLevelStreaming = {}
local LevelName2LuaFile = {}
LevelManager.nWaitingLevelStreaming = 0
function LevelManager.Init()
  local USubsystemBlueprintLibrary = import("SubsystemBlueprintLibrary")
  local UGameLuaEnv = import("GameLuaEnv")
  local uLuaEnv = USubsystemBlueprintLibrary.GetWorldSubsystem(CGameWorld, UGameLuaEnv)
  if not slua.isValid(uLuaEnv) then
    return
  end
  GlobalActors = {}
  local World = CGameMode:GetWorld()
  local StreamingLevelName = {}
  LogicLevelStreaming = {}
  local StreamingLevels = World.StreamingLevels
  if World.StreamingLevels then
    for _, LevelStreaming in pairs(World.StreamingLevels) do
      local sLevelName = LevelStreaming.PackageNameToLoad
      if sLevelName then
        StreamingLevelName[sLevelName] = true
      end
    end
  end
  local LevelTable = CDataTable.GetTable("SubLevelScript")
  for sLogicLevelPath, uRow in pairs(LevelTable) do
    local sLevelScript = uRow.SubLevelScript
    local bIsLoadOnInit = uRow.IsLoadOnInit
    if bIsLoadOnInit and StreamingLevelName[sLogicLevelPath] then
      LogicLevelStreaming[sLogicLevelPath] = true
      LevelManager.nWaitingLevelStreaming = LevelManager.nWaitingLevelStreaming + 1
    end
    if sLevelScript then
      LevelName2LuaFile[sLogicLevelPath] = sLevelScript
    end
  end
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local ModPath = GameMainConfig.GetModType()
  if ModPath == nil or ModPath == "" or ModPath == "Default" then
    ModPath = "BaseMod"
  else
    local StringUtil = require("common.string_util")
    ModPath = StringUtil.Split(ModPath, ";")[1] or ModPath
  end
  local LevelConfigPath = "GameLua.Mod." .. ModPath .. ".GamePlay.Config.LevelConfig"
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  if not GamePlayTools.LuaFileExits(LevelConfigPath) then
    LevelConfigPath = "GameLua.Mod.BaseMod.GamePlay.Config.LevelConfig"
  end
  local Config = require(LevelConfigPath)
  for _, sClassName in pairs(Config.ExportClasses) do
    uLuaEnv.ExportClasses:Add(sClassName, true)
  end
  local MainLevelPath = CGame:GetLevelPath(World.PersistentLevel)
  uLuaEnv:PullLevelActors(World.PersistentLevel)
  LevelManager.LevelActorsAdapter(MainLevelPath)
end
function LevelManager.CreateSandboxEnv(sLevelName)
  LevelEnvs = LevelEnvs or {}
  local tEnv = {}
  for key, value in pairs(_G) do
    tEnv[key] = value
  end
  tEnv._G = nil
  tEnv.LevelActors = nil
  tEnv.GlobalActors = nil
  tEnv.LevelEnvs = nil
  LevelEnvs[sLevelName] = tEnv
  if GlobalActors then
    tEnv.LocalActors = GlobalActors[sLevelName] or {}
  else
    tEnv.LocalActors = {}
  end
  return tEnv
end
function LevelManager.LevelActorsAdapter(sLevelName)
  LevelActors = LevelActors or {}
  if GlobalActors and sLevelName then
    local tLevel = GlobalActors[sLevelName]
    if tLevel then
      for sActorName, uActor in pairs(tLevel) do
        LevelActors[sActorName] = uActor
      end
    end
  end
end
local setfenv = function(fn, env)
  assert(env ~= nil, "setfenv env should not be nil")
  local i = 1
  while true do
    local name = debug.getupvalue(fn, i)
    if name == "_ENV" then
      debug.upvaluejoin(fn, i, function()
        return env
      end, 1)
      break
    elseif not name then
      break
    end
    i = i + 1
  end
  return fn
end
local getfenv = function(fn)
  local i = 1
  while true do
    local name, val = debug.getupvalue(fn, i)
    if name == "_ENV" then
      return val
    elseif not name then
      break
    end
    i = i + 1
  end
end
local FindLoader = function(name)
  local msg = {}
  for _, loader in ipairs(package.searchers) do
    local f, extra = loader(name)
    local t = type(f)
    if t == "function" then
      return f, extra
    elseif t == "string" then
      table.insert(msg, f)
    end
  end
  sandbox.LogError(string.format("module '%s' not found:%s", name, table.concat(msg)))
end
function LevelManager.CCallOnLevelAdded(Level, sPackageName, sLevelName)
  print(bWriteLog and "CCallOnLevelAdded", sPackageName, sLevelName)
  if not GlobalActors then
    return
  end
  local USubsystemBlueprintLibrary = import("SubsystemBlueprintLibrary")
  local UGameLuaEnv = import("GameLuaEnv")
  local uLuaEnv = USubsystemBlueprintLibrary.GetWorldSubsystem(CGameWorld, UGameLuaEnv)
  if not slua.isValid(uLuaEnv) then
    return
  end
  if Level and slua.isValid(Level) and uLuaEnv.PullLevelActors then
    uLuaEnv:PullLevelActors(Level)
  end
  LevelManager.LevelActorsAdapter(sLevelName)
  EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_LEVEL_ADDED, sLevelName)
  if LogicLevelStreaming[sLevelName] then
    GlobalDynamicActors = GlobalDynamicActors or {}
    GlobalDynamicActors[sPackageName] = {}
    uLuaEnv:PullDynamicLevelActors(Level)
    EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_DYNAMICLEVEL_LOADED, sPackageName)
    if LevelManager.nWaitingLevelStreaming > 0 then
      LevelManager.nWaitingLevelStreaming = LevelManager.nWaitingLevelStreaming - 1
    end
  end
  if LevelName2LuaFile[sLevelName] then
    local sModuleName = LevelName2LuaFile[sLevelName]
    if sModuleName ~= "" then
      local tEnv = LevelManager.CreateSandboxEnv(sLevelName)
      local loader, arg = FindLoader(sModuleName)
      if loader then
        setfenv(loader, tEnv)
        loader(sModuleName, arg)
        if tEnv.CCallInitLevel then
          LevelName2LuaFile[sLevelName] = nil
          tEnv.CCallInitLevel()
        end
      end
    end
  end
  if LevelManager.nWaitingLevelStreaming == 0 and CCallInitGlobals and not LevelManager.bInit then
    LevelManager.bInit = true
    CCallWaitFunction("CCallInitGlobals")
  end
end