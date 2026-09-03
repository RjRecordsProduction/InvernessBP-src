local DSGameMain = {CurrentConfig = nil}
local CallServerDSNetTest = function()
  if Server then
    return
  end
  print(bWriteLog and "DSGameMain CallServerDSNetTest")
  local ServerDSNetTest = require("GameLua.ServerDSNetTest")
end
function InitEnv()
  print(bWriteLog and string.format("InitEnv GameWorld = %s, CGameMode = %s, CGameState = %s", CGameWorld, CGameMode, CGameState))
  print(bWriteLog and "---------------------------------------")
  print(bWriteLog and "Hello Gamemode Slua World!")
  print(bWriteLog and "SLua-----InitEnv Success!")
  print(bWriteLog and "---------------------------------------")
  InitPreFile()
  if Server then
    require("GameLua.GameCore.Main.LuaGCStrategy").Init()
    require("client.config.pubgm_package")
    print("DS build info: " .. tostring(global_package_make_time))
  end
end
function InitPreFile()
  local preloadModules = {
    "GameLua.Mod.BaseMod.Common.Global",
    "GameLua.Mod.BaseMod.Common.Core.EnumDefine",
    "GameLua.Mod.BaseMod.GamePlay.Core.GameAPI",
    "GameLua.Mod.BaseMod.DS.Level.LevelManager",
    "GameLua.Mod.Library.DS.Task.TaskManager",
    "GameLua.Mod.Library.DS.AI.TeamAI.TeamAIOrder",
    "GameLua.Mod.Library.DS.AI.TeamAI.TeamAIManager",
    "common.func_util",
    "common.loc_util",
    "GameLua.Mod.BaseMod.GamePlay.Config.EventDefine",
    "client.common.event.EventProxy"
  }
  for _, module in ipairs(preloadModules) do
    require(module)
  end
  _G.SubsystemMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  if Client then
    GameplayData.InitStandAloneEntry()
  else
    GameplayData.InitDSEntry()
  end
end
function ModuleInit()
  print(bWriteLog and "ModuleInit")
  if Client then
    log(bWriteLog and "ModuleInit is Client")
    if GameStatus.IsInLobbyOrMainCity() then
      log(bWriteLog and "ModuleInit GameStatus.IsInLobbyOrMainCity")
      return
    end
  end
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local CurrentConfig = GameMainConfig.GetConfig(false)
  if CurrentConfig then
    sandbox.LogNormal(bWriteLog and "load ds mode logic:" .. CurrentConfig.DSModeLogic)
    if CurrentConfig then
      local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
      if GamePlayTools.LuaFileExits(CurrentConfig.DSModeLogic) then
        require(CurrentConfig.DSModeLogic)
      end
    end
    local ds_net = require("ds_net")
    ds_net.InitRoute(CurrentConfig.EventConfig)
    DSGameMain.  end
  InitBackPackUtil()
  LevelManager.Init()
  if not Client then
    SubsystemMgr:InitDev("DS")
    if SubsystemMgr:Init("DS") then
      SubsystemMgr:CallOnInit()
    end
  end
  CCallWaitFunction("CCallInitMap")
  if LevelManager.nWaitingLevelStreaming == 0 then
    LevelManager.LevelActorsAdapter()
    LevelManager.bInit = true
    if CCallInitGlobals then
      CCallWaitFunction("CCallInitGlobals")
    end
  end
  InitGameNet()
  local AliasManager = require("GameLua.Mod.Library.DS.Alias.AliasManager")
  AliasManager:Init()
  local IngameTeammateLabelCheck = require("GameLua.Mod.BaseMod.DS.Like.IngameTeammateLabelCheck")
  IngameTeammateLabelCheck.Init()
  local PlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
  PlayerDataMgr.Init()
  local WeaponSystem = require("GameLua.GameCore.Module.Weapon.WeaponSystem")
  WeaponSystem:Init()
  local DSCareerFlagLogic = require("GameLua.Mod.Library.DS.Career.DSCareerFlagLogic")
  DSCareerFlagLogic.Init()
  if IsEditor then
    require("blacklist.editor.debugger.logic_hot_update")
  end
end
function InitMapConfig()
  local ModPath = ""
  local MainMapName = ""
  local SubName = ""
  local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local ModeID = GameMainConfig.GetModeID()
  if ModeID and 0 < ModeID then
    local BTMode = GamePlayTools.GetTableData("BTMode", ModeID)
    if not BTMode then
      return
    end
    local MapID = BTMode.MapID
    if not MapID then
      return
    end
    local MapData = GamePlayTools.GetTableData("Map", MapID)
    if not MapData then
      return
    end
    local MainMapPath = MapData.MapPath
    if not MainMapPath then
      return
    end
    local StringUtil = require("common.string_util")
    local MainMapTable = StringUtil.Split(MainMapPath, "/")
    MainMapName = MainMapTable[#MainMapTable]
    if IsEditor then
      MainMapName = CGame:GetMapName()
    end
    if not MainMapName then
      return
    end
    ModPath = BTMode.ModType
    SubName = BTMode.SubMod
  else
    MainMapName = CGame:GetMapName()
    ModPath = GameMainConfig.GetModType()
    SubName = CGame:GetSubLevel()
  end
  if ModPath == nil or ModPath == "" or ModPath == "Default" then
    ModPath = "BaseMod"
  else
    local StringUtil = require("common.string_util")
    ModPath = StringUtil.Split(ModPath, ";")[1]
  end
  if SubName and SubName ~= "" then
    SubName = "_" .. SubName
  else
    SubName = ""
  end
  local MapConfigPath = "GameLua.Mod." .. ModPath .. ".MapConfig." .. MainMapName .. SubName .. "_Config"
  print(bWriteLog and "MapConfigPath:" .. MapConfigPath)
  if GamePlayTools.LuaFileExits(MapConfigPath) then
    require(MapConfigPath)
  end
end
function CCallDostring(sStr)
  if not sStr then
    return
  end
  local f = loadstring(sStr)
  f()
end
function CCallWaitFunction(sFuncName, ...)
  if not sFuncName then
    return
  end
  local func = _G[sFuncName]
  if func == nil then
    sandbox.LogError("CCallWaitFunction:" .. sFuncName .. " Cannot find Function!")
    return
  end
  local co = coroutine.create(function(...)
    func(...)
  end)
  local bWait, nWaitTime = coroutine.resume(co, ...)
  if bWait and nWaitTime then
    Game:WaitCo(co, nWaitTime)
  elseif not bWait then
    local utility = require("common.utility")
    utility.ErrorMessageHandler(nWaitTime)
  end
end
function CallWithWait(func, ...)
  if not func or type(func) ~= "function" then
    return
  end
  local co = coroutine.create(function(...)
    func(...)
  end)
  local bWait, nWaitTime = coroutine.resume(co, ...)
  if bWait and nWaitTime then
    Game:WaitCo(co, nWaitTime)
  elseif not bWait then
    local utility = require("common.utility")
    utility.ErrorMessageHandler(nWaitTime)
  end
end
function InitGameNet()
  local KismetSystemLibrary = import("KismetSystemLibrary")
  if KismetSystemLibrary.IsDedicatedServer(CGameMode) then
    require("Server.server_entry")
    local RealTimeBan = require("GameLua.Mod.BaseMod.Common.RealTimeBan.RealTimeBan")
    RealTimeBan:Init()
  end
end
function InitBackPackUtil()
  local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local ModeType = STExtraBlueprintFunctionLibrary.GetModString(CGameMode)
  print(bWriteLog and "InitBackPackUtil ModeType:" .. ModeType)
  local firstCap, endCap = string.find(ModeType, "DBZ", 1, true)
  if firstCap and endCap then
    local UBackpackDBZUtils = import("BackpackDBZUtils")
    UBackpackDBZUtils.RegisterInvokeClass()
  else
    firstCap, endCap = string.find(ModeType, "TPlan", 1, true)
    if firstCap and endCap then
      local UBackpackTPlanUtils = import("BackpackTPlanUtils")
      UBackpackTPlanUtils.RegisterInvokeClass()
    else
      local UBackpackUtilsClassical = import("BackpackUtilsClassical")
      UBackpackUtilsClassical.RegisterInvokeClass()
    end
  end
end
function DSGameMain.GetCurrentConfig(Key)
  if DSGameMain.CurrentConfig and DSGameMain.CurrentConfig[Key] then
    return DSGameMain.CurrentConfig[Key]
  end
  return nil
end
return DSGameMain