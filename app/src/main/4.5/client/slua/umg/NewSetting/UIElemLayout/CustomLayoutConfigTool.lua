local ConfigTool = {
  CachedModConfig = {},
  ModBlackList = {
    Config = true,
    Livik = true,
    Desert = true,
    Neon = true,
    Baby = true,
    Baby2 = true,
    LootTruck = true
  },
  CachedIndexer = {}
}
local MainConfig = require("client.slua.umg.NewSetting.UIElemLayout.CustomLayoutConfig")
local MainIndexer
local function _DeepCopy(src)
  local result = {}
  for k, v in pairs(src) do
    if type(v) == "table" then
      result[k] = _DeepCopy(v)
    else
      result[k] = v
    end
  end
  return result
end
local _ShallowCopy = function(src)
  local result = {}
  for k, v in pairs(src) do
    result[k] = v
  end
  return result
end
local _CreateWorkingCopy = function(base, modSlotRegistry)
  local copy = _ShallowCopy(base)
  if base.SlotRegistry then
    if modSlotRegistry then
      local filtered = {}
      for k, v in pairs(base.SlotRegistry) do
        if modSlotRegistry[k] ~= nil then
          filtered[k] = v
        end
      end
      copy.SlotRegistry = filtered
    else
      copy.SlotRegistry = _ShallowCopy(base.SlotRegistry)
    end
  end
  return copy
end
local _MergeSlotRegistry = function(target, override, modName)
  for entryKey, entryValue in pairs(override) do
    if target[entryKey] == nil then
      local copy = _ShallowCopy(entryValue)
      copy.__mod = modName
      target[entryKey] = copy
    else
      local merged = _DeepCopy(target[entryKey])
      for field, value in pairs(entryValue) do
        merged[field] = value
      end
      merged.__mod = modName
      target[entryKey] = merged
    end
  end
end
local _MergeConfig = function(target, override, modName)
  if not target.__loadorder then
    target.__loadorder = {}
  end
  table.insert(target.__loadorder, modName)
  for key, value in pairs(override) do
    if key == "SlotRegistry" then
      _MergeSlotRegistry(target.SlotRegistry, value, modName)
    else
      target[key] = value
    end
  end
end
local LuaFileExits = function(InPath)
  local ScriptHelperClient = import("ScriptHelperClient")
  if InPath == nil or InPath == "" then
    return false
  end
  local Path = string.gsub(InPath, "%.", "/")
  local FullPath = ScriptHelperClient.GetLuaRootDir() .. Path .. ".lua"
  return ScriptHelperClient.IsFileExistsWithPakCheck(FullPath)
end
local _GetSourceLayoutConfig = function(ModName)
  local LuaPath = "GameLua.Mod." .. ModName .. ".Client.Config.CustomLayoutConfig"
  return LuaFileExits(LuaPath) and require(LuaPath)
end
local _GetModConfig = function(ModName)
  local LuaPath = "GameLua.Mod." .. ModName .. ".ModConfig"
  return LuaFileExits(LuaPath) and require(LuaPath)
end
local function RecursiveMergeLayoutConfig(InModName)
  local mergedLayoutConfig
  local modLayoutConfig = _GetSourceLayoutConfig(InModName)
  local modManifest = _GetModConfig(InModName)
  local policyFilter = modLayoutConfig and modLayoutConfig.SlotRegistryPolicy == 1 and modLayoutConfig.SlotRegistry or nil
  if modManifest and modManifest.Import then
    local parentModsWithLayoutConfig = {}
    for SuperMod, _ in pairs(modManifest.Import) do
      if not ConfigTool.ModBlackList[SuperMod] and SuperMod ~= InModName then
        if not ConfigTool.CachedModConfig[SuperMod] then
          RecursiveMergeLayoutConfig(SuperMod)
        end
        if ConfigTool.CachedModConfig[SuperMod] then
          table.insert(parentModsWithLayoutConfig, SuperMod)
        end
      end
    end
    local parentModCount = #parentModsWithLayoutConfig
    if parentModCount == 1 then
      if modLayoutConfig then
        mergedLayoutConfig = _CreateWorkingCopy(ConfigTool.CachedModConfig[parentModsWithLayoutConfig[1]], policyFilter)
        _MergeConfig(mergedLayoutConfig, modLayoutConfig, InModName)
      else
        mergedLayoutConfig = ConfigTool.CachedModConfig[parentModsWithLayoutConfig[1]]
      end
    elseif 1 < parentModCount then
      mergedLayoutConfig = _CreateWorkingCopy(ConfigTool.CachedModConfig[parentModsWithLayoutConfig[1]], policyFilter)
      for i = 2, parentModCount do
        local parentLayoutOverride = _GetSourceLayoutConfig(parentModsWithLayoutConfig[i])
        if parentLayoutOverride then
          _MergeConfig(mergedLayoutConfig, parentLayoutOverride, parentModsWithLayoutConfig[i])
        end
      end
      if modLayoutConfig then
        _MergeConfig(mergedLayoutConfig, modLayoutConfig, InModName)
      end
    end
  end
  if not mergedLayoutConfig and modLayoutConfig then
    mergedLayoutConfig = _CreateWorkingCopy(MainConfig, policyFilter)
    _MergeConfig(mergedLayoutConfig, modLayoutConfig, InModName)
  end
  if mergedLayoutConfig then
    ConfigTool.CachedModConfig[InModName] = mergedLayoutConfig
    print(bWriteLog and "CustomLayoutConfigTool " .. InModName .. " GetLayoutConfig")
  else
    ConfigTool.ModBlackList[InModName] = true
    print(bWriteLog and "CustomLayoutConfigTool " .. InModName .. " no layout config")
  end
end
function ConfigTool.GetLayoutConfig(ModName)
  if ModName and ModName ~= "" then
    if ConfigTool.CachedModConfig[ModName] then
      return ConfigTool.CachedModConfig[ModName]
    end
    if ConfigTool.ModBlackList[ModName] then
      return MainConfig
    end
    RecursiveMergeLayoutConfig(ModName)
    return ConfigTool.CachedModConfig[ModName] or MainConfig
  else
    print(bWriteLog and "CustomLayoutConfigTool.GetModConfig empty ModName, get default config")
    return MainConfig
  end
end
function ConfigTool.GetIndexer(ModName)
  if ModName and ModName ~= "" then
    if slua.isValid(ConfigTool.CachedIndexer[ModName]) then
      return ConfigTool.CachedIndexer[ModName]
    end
    ConfigTool.CachedIndexer[ModName] = nil
    local IndexerClass = import("DynamicCustomIndexer")
    local Indexer = IndexerClass.GetIndexer("/Game/Mod/" .. ModName .. "/BluePrints/UI/DynamicCustom/DynamicCustomIndexer.DynamicCustomIndexer")
    if slua.isValid(Indexer) then
      ConfigTool.CachedIndexer[ModName] = Indexer
      return Indexer
    else
      print(bWriteLog and "ConfigTool.LoadDynamicCustom failed to load " .. "/Game/Mod/" .. ModName .. "/BluePrints/UI/DynamicCustom/DynamicCustomIndexer.DynamicCustomIndexer")
    end
  else
    if not slua.isValid(MainIndexer) then
      local IndexerClass = import("DynamicCustomIndexer")
      MainIndexer = IndexerClass.GetIndexer("/Game/UMG/UI_BP/Setting/DynamicCustom/DynamicCustomIndexer.DynamicCustomIndexer")
    end
    if slua.isValid(MainIndexer) then
      return MainIndexer
    else
      print(bWriteLog and "ConfigTool.LoadDynamicCustom failed to load MainIndexer")
    end
  end
end
function ConfigTool.GetDefaultAnchorData(ModName, CustomType)
  local result, Indexer
  if ModName then
    Indexer = ConfigTool.GetIndexer(ModName)
    if slua.isValid(Indexer) then
      result = Indexer.DefaultLayoutData:Get(CustomType)
    end
  end
  if not result then
    Indexer = ConfigTool.GetIndexer()
    if slua.isValid(Indexer) then
      result = Indexer.DefaultLayoutData:Get(CustomType)
    end
  end
  return result, Indexer
end
function ConfigTool.ApplyDefaultLayout(ModName, CustomPanel, Type)
  local _, Indexer = ConfigTool.GetDefaultAnchorData(nil, Type)
  if Indexer then
    CustomPanel:SetDefaultLayoutCode(Indexer:GetDefaultLayoutCode(Type))
    CustomPanel:SetCustomType(Type)
  end
end
function ConfigTool.ReleaseDynamicCustomCache()
  local TableUtil = require("common.table_util")
  TableUtil.Clear(ConfigTool.CachedIndexer)
  MainIndexer = nil
end
return ConfigTool