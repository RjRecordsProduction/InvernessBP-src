local STExtraGameplayStatics = import("STExtraGameplayStatics")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local GameMainExtraModuleUtil = {}
local ForcePrintLog = _G.print
local ELogLevel = {
  Debug = 1,
  Info = 2,
  Warning = 3,
  Error = 4,
  Exception = 5
}
local IsLuaFileExists = function(Path)
  return STExtraGameplayStatics.IsDSLuaFileExists(Path)
end
local LogAndRecordDebugInfo = function(ExtraModule, Message, LogLevel, DebugInfos)
  ForcePrintLog(Message)
  if DebugInfos then
    table.insert(DebugInfos, {
      Msg = string.format("[%s] %s", ExtraModule, Message),
      LogLevel = LogLevel or ELogLevel.Debug
    })
  end
end
local CanInjectExtraModule = function(Params)
  local ExtraModuleInfo = Params.ExtraModuleInfo
  local IsMod = Params.IsMod
  local ModID = Params.ModID
  local ModType = Params.ModType
  local MapType = Params.MapType
  local DebugInfos = Params.DebugInfos
  local ExtraModule = ExtraModuleInfo.Name
  local DirPrefix = IsMod == true and "Mod" or "ExtraModule"
  local ExtraModulePath = string.format("GameLua.%s.%s.ModConfig", DirPrefix, ExtraModule)
  if not IsLuaFileExists(ExtraModulePath) then
    local DebugMsg = string.format("GameMainExtraModuleUtil %s not exists", ExtraModulePath)
    LogAndRecordDebugInfo(ExtraModule, DebugMsg, ELogLevel.Error, DebugInfos)
    return false
  end
  local Config = require(ExtraModulePath)
  if not (Config and Config.Export) or not Config.Export.Inject then
    local DebugMsg = string.format("GameMainExtraModuleUtil %s Inject config is not valid", ExtraModulePath)
    LogAndRecordDebugInfo(ExtraModule, DebugMsg, ELogLevel.Error, DebugInfos)
    return false
  end
  local InjectConfig = Config.Export.Inject
  if InjectConfig.IsEnabled == false then
    local DebugMsg = string.format("GameMainExtraModuleUtil <%s> CHECK IsEnabled, return false", ExtraModule)
    LogAndRecordDebugInfo(ExtraModule, DebugMsg, ELogLevel.Warning, DebugInfos)
    return false
  end
  if InjectConfig.BlueHoleVersionOnly == true then
    local IsBlueHoleVersion = GamePlayTools.IsBlueHoleVersion()
    local DebugMsg = string.format("GameMainExtraModuleUtil CHECK BlueHoleVersionOnly, Current IsBlueHoleVersion: %s", IsBlueHoleVersion)
    LogAndRecordDebugInfo(ExtraModule, DebugMsg, nil, DebugInfos)
    if not IsBlueHoleVersion then
      local DebugMsg2 = string.format("GameMainExtraModuleUtil <%s> CHECK BlueHoleVersionOnly, return false", ExtraModule)
      LogAndRecordDebugInfo(ExtraModule, DebugMsg2, ELogLevel.Warning, DebugInfos)
      return false
    else
      local Count = 0
      for k, v in pairs(InjectConfig) do
        Count = Count + 1
      end
      if Count == 1 then
        local DebugMsg3 = string.format("GameMainExtraModuleUtil <%s> CHECK BlueHoleVersionOnly, return true", ExtraModule)
        LogAndRecordDebugInfo(ExtraModule, DebugMsg3, ELogLevel.Warning, DebugInfos)
        return true
      end
    end
  end
  if InjectConfig.ExcludeBlueHoleVersion == true then
    local IsBlueHoleVersion = GamePlayTools.IsBlueHoleVersion()
    local DebugMsg = string.format("GameMainExtraModuleUtil CHECK ExcludeBlueHoleVersion, Current IsBlueHoleVersion: %s", IsBlueHoleVersion)
    LogAndRecordDebugInfo(ExtraModule, DebugMsg, nil, DebugInfos)
    if IsBlueHoleVersion then
      local DebugMsg2 = string.format("GameMainExtraModuleUtil <%s> CHECK ExcludeBlueHoleVersion, return false", ExtraModule)
      LogAndRecordDebugInfo(ExtraModule, DebugMsg2, ELogLevel.Warning, DebugInfos)
      return false
    end
  end
  if InjectConfig.ExcludeMatchMode == true then
    local MatchModeIds = require("GameLua.Mod.BaseMod.GamePlay.Config.MatchModeIdsConfig")
    local IsMatchMode = MatchModeIds[ModID] ~= nil
    local DebugMsg = string.format("GameMainExtraModuleUtil CHECK ExcludeMatchMode, Current IsMatchMode = %s (ModID = %s)", IsMatchMode, ModID)
    LogAndRecordDebugInfo(ExtraModule, DebugMsg, nil, DebugInfos)
    if IsMatchMode then
      local DebugMsg2 = string.format("GameMainExtraModuleUtil <%s> CHECK ExcludeMatchMode, return false", ExtraModule)
      LogAndRecordDebugInfo(ExtraModule, DebugMsg2, ELogLevel.Warning, DebugInfos)
      return false
    end
  end
  if InjectConfig.IsThemeBRMode == true then
    local IsThemeBRMode = GamePlayTools.IsThemeBRMode(ModID)
    local DebugMsg = string.format("GameMainExtraModuleUtil CHECK IsThemeBRMode, Current IsThemeBRMode = %s, MapType = %s", IsThemeBRMode, MapType)
    LogAndRecordDebugInfo(ExtraModule, DebugMsg, nil, DebugInfos)
    if IsThemeBRMode then
      local IsMapTypeMatched = false
      if MapType == "Baltic" then
        IsMapTypeMatched = InjectConfig.IsThemeBRModeBaltic ~= false
      elseif MapType == "Livik" then
        IsMapTypeMatched = InjectConfig.IsThemeBRModeLivik ~= false
      else
        IsMapTypeMatched = InjectConfig.IsThemeBRModeOther ~= false
      end
      if IsMapTypeMatched then
        local DebugMsg2 = string.format("GameMainExtraModuleUtil <%s> CHECK IsThemeBRMode, MapType = %s matched, return true", ExtraModule, MapType)
        LogAndRecordDebugInfo(ExtraModule, DebugMsg2, ELogLevel.Info, DebugInfos)
        return true
      else
        local DebugMsg2 = string.format("GameMainExtraModuleUtil <%s> CHECK IsThemeBRMode, MapType = %s not matched", ExtraModule, MapType)
        LogAndRecordDebugInfo(ExtraModule, DebugMsg2, ELogLevel.Warning, DebugInfos)
      end
    end
  end
  if InjectConfig.IsUGCMode == true then
    local IsUGCMode = GamePlayTools.IsUGCMode(ModID)
    local DebugMsg = string.format("GameMainExtraModuleUtil CHECK IsUGCMode, Current IsUGCMode = %s", IsUGCMode)
    LogAndRecordDebugInfo(ExtraModule, DebugMsg, nil, DebugInfos)
    if IsUGCMode then
      local DebugMsg2 = string.format("GameMainExtraModuleUtil <%s> CHECK IsUGCMode, return true", ExtraModule)
      LogAndRecordDebugInfo(ExtraModule, DebugMsg2, ELogLevel.Info, DebugInfos)
      return true
    end
  end
  if InjectConfig.IsClassicBRBaltic == true then
    local IsClassicBRBaltic = 1001 <= ModID and ModID <= 1003 or 1064 <= ModID and ModID <= 1066 or 2001 <= ModID and ModID <= 2003 or 2064 <= ModID and ModID <= 2066
    local DebugMsg = string.format("GameMainExtraModuleUtil CHECK IsClassicBRBaltic, Current ModID = %s, IsClassicBRBaltic = %s", ModID, IsClassicBRBaltic)
    LogAndRecordDebugInfo(ExtraModule, DebugMsg, nil, DebugInfos)
    if IsClassicBRBaltic then
      local DebugMsg2 = string.format("GameMainExtraModuleUtil <%s> CHECK IsClassicBRBaltic, return true", ExtraModule)
      LogAndRecordDebugInfo(ExtraModule, DebugMsg2, ELogLevel.Info, DebugInfos)
      return true
    end
  end
  if InjectConfig.ExcludeModeID then
    for _, ExcludeModeID in ipairs(InjectConfig.ExcludeModeID) do
      if type(ExcludeModeID) == "table" then
        if ModID >= ExcludeModeID[1] and ModID <= ExcludeModeID[2] then
          local DebugMsg = string.format("GameMainExtraModuleUtil <%s> EXCLUDED by ModeID (%s <= %s <= %s)", ExtraModule, ExcludeModeID[1], ModID, ExcludeModeID[2])
          LogAndRecordDebugInfo(ExtraModule, DebugMsg, ELogLevel.Warning, DebugInfos)
          return false
        end
      elseif ExcludeModeID == ModID then
        local DebugMsg = string.format("GameMainExtraModuleUtil <%s> EXCLUDED by ModeID (%s)", ExtraModule, ModID)
        LogAndRecordDebugInfo(ExtraModule, DebugMsg, ELogLevel.Warning, DebugInfos)
        return false
      end
    end
  end
  if InjectConfig.ExcludeMod then
    for _, ExcludeMod in ipairs(InjectConfig.ExcludeMod) do
      if ExcludeMod == ModType then
        local DebugMsg = string.format("GameMainExtraModuleUtil <%s> EXCLUDED by Mod %s", ExtraModule, ModType)
        LogAndRecordDebugInfo(ExtraModule, DebugMsg, ELogLevel.Warning, DebugInfos)
        return false
      end
    end
  end
  if InjectConfig.ExcludeMap then
    for _, ExcludeMap in ipairs(InjectConfig.ExcludeMap) do
      if ExcludeMap == MapType then
        local DebugMsg = string.format("GameMainExtraModuleUtil <%s> EXCLUDED by Map %s", ExtraModule, MapType)
        LogAndRecordDebugInfo(ExtraModule, DebugMsg, ELogLevel.Warning, DebugInfos)
        return false
      end
    end
  end
  if InjectConfig.Custom then
    local CustomResult = InjectConfig.Custom(Params)
    local DebugMsg = string.format("GameMainExtraModuleUtil CHECK Custom, CustomResult = %s", CustomResult)
    LogAndRecordDebugInfo(ExtraModule, DebugMsg, nil, DebugInfos)
    if CustomResult then
      local DebugMsg2 = string.format("GameMainExtraModuleUtil <%s> CHECK Custom, return true", ExtraModule)
      LogAndRecordDebugInfo(ExtraModule, DebugMsg2, ELogLevel.Info, DebugInfos)
      return true
    end
  end
  if InjectConfig.ModeID then
    for _, InjectModeID in ipairs(InjectConfig.ModeID) do
      if type(InjectModeID) == "table" then
        if ModID >= InjectModeID[1] and ModID <= InjectModeID[2] then
          local DebugMsg = string.format("GameMainExtraModuleUtil <%s> INCLUDED by ModeID (%s <= %s <= %s)", ExtraModule, InjectModeID[1], ModID, InjectModeID[2])
          LogAndRecordDebugInfo(ExtraModule, DebugMsg, ELogLevel.Info, DebugInfos)
          return true
        end
      elseif InjectModeID == ModID then
        local DebugMsg = string.format("GameMainExtraModuleUtil <%s> INCLUDED by ModeID (%s)", ExtraModule, ModID)
        LogAndRecordDebugInfo(ExtraModule, DebugMsg, ELogLevel.Info, DebugInfos)
        return true
      end
    end
  end
  if InjectConfig.Mod then
    for _, InjectMod in ipairs(InjectConfig.Mod) do
      if InjectMod == ModType then
        local DebugMsg = string.format("GameMainExtraModuleUtil <%s> INCLUDED by Mod %s", ExtraModule, ModType)
        LogAndRecordDebugInfo(ExtraModule, DebugMsg, ELogLevel.Info, DebugInfos)
        return true
      end
    end
  end
  if InjectConfig.Map then
    for _, InjectMap in ipairs(InjectConfig.Map) do
      if InjectMap == MapType then
        local DebugMsg = string.format("GameMainExtraModuleUtil <%s> INCLUDED by Map %s", ExtraModule, MapType)
        LogAndRecordDebugInfo(ExtraModule, DebugMsg, ELogLevel.Info, DebugInfos)
        return true
      end
    end
  end
  local DebugMsg = string.format("GameMainExtraModuleUtil <%s> not matched any inject condition", ExtraModule)
  LogAndRecordDebugInfo(ExtraModule, DebugMsg, nil, DebugInfos)
  return false
end
local TryInjectExtraModule = function(Params)
  local ExtraModules = Params.ExtraModules
  local ExtraModuleMap = Params.ExtraModuleMap
  local ExtraModuleInfo = Params.ExtraModuleInfo
  if not ExtraModuleMap[ExtraModuleInfo.Name] and CanInjectExtraModule(Params) then
    table.insert(ExtraModules, ExtraModuleInfo.Name)
    ExtraModuleMap[ExtraModuleInfo.Name] = true
  end
end
function GameMainExtraModuleUtil.GetExtraModules(ModID, ModType, MapType, DebugInfos)
  if MapType == nil then
    local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
    MapType = GameMainConfig.GetMapType(ModID)
  end
  local ExtraModuleConfig = require("GameLua.ExtraModule.ExtraModuleConfig")
  local ExtraModules = {}
  local ExtraModuleMap = {}
  local InjectParams = {
    ExtraModules = ExtraModules,
    ExtraModuleMap = ExtraModuleMap,
    ModID = ModID,
    ModType = ModType,
    MapType = MapType,
    DebugInfos = DebugInfos,
      }
  local DebugMsg = string.format("GameMainExtraModuleUtil GetExtraModules ModID: %s, ModType: %s, MapType: %s", ModID, ModType, MapType)
  LogAndRecordDebugInfo(nil, DebugMsg, ELogLevel.Warning, DebugInfos)
  for i = #ExtraModuleConfig.Mod, 1, -1 do
    InjectParams.ExtraModuleInfo = ExtraModuleConfig.Mod[i]
    InjectParams.IsMod = true
    TryInjectExtraModule(InjectParams)
  end
  for i = #ExtraModuleConfig.ExtraModule, 1, -1 do
    InjectParams.ExtraModuleInfo = ExtraModuleConfig.ExtraModule[i]
    InjectParams.IsMod = false
    TryInjectExtraModule(InjectParams)
  end
  ForcePrintLog(string.format("GameMainExtraModuleUtil GetExtraModules {%s}", table.concat(ExtraModules, ",")))
  return ExtraModules
end
return GameMainExtraModuleUtil