local GameplayStatics = import("GameplayStatics")
local ESTExtraVehicleShapeType = import("ESTExtraVehicleShapeType")
local ConfigUtils = require("GameLua.GameCore.Module.Vehicle.Config.ConfigUtils")
local EAudioType = ConfigUtils.EAudioType
local VehicleConfig = {}
VehicleConfig.ConfigCache = {}
function VehicleConfig.ClearCache()
  VehicleConfig.ConfigCache = {}
end
function VehicleConfig.GenConfig(Vehicle, VehicleShapeType)
  local GameState = CGameState or GameplayStatics.GetGameState(Vehicle)
  local ModID = slua.isValid(GameState) and GameState.GameModeID or nil
  local ModCache = ModID and VehicleConfig.ConfigCache[ModID] or nil
  if ModCache then
    local CachedConfig = ModCache[VehicleShapeType]
    if CachedConfig then
      return CachedConfig
    end
  end
  local TargetConfig = {
    VisitedConfigs = {},
    TargetComponents = {},
    TargetComponentAttributes = {},
    TargetFeatures = {}
  }
  local LibraryConfigPath = "GameLua.Mod.Library.Gameplay.Vehicle.Config.VehicleConfig"
  if not TargetConfig.VisitedConfigs[LibraryConfigPath] and slua.IsLuaModuleExists(LibraryConfigPath) then
    TargetConfig.VisitedConfigs[LibraryConfigPath] = true
    VehicleConfig.MergeVehicleConfig(TargetConfig, require(LibraryConfigPath), Vehicle, VehicleShapeType)
  end
  local ModPath = Game.GetCurrentModPath()
  local ModConfigPath = ModPath .. ".Gameplay.Module.Vehicle.VehicleConfig"
  if not TargetConfig.VisitedConfigs[ModConfigPath] and slua.IsLuaModuleExists(ModConfigPath) then
    TargetConfig.VisitedConfigs[ModConfigPath] = true
    VehicleConfig.MergeVehicleConfig(TargetConfig, require(ModConfigPath), Vehicle, VehicleShapeType)
  end
  TargetConfig.Components, TargetConfig.TargetComponents = TargetConfig.TargetComponents, nil
  TargetConfig.ComponentsAttrModify, TargetConfig.TargetComponentAttributes = TargetConfig.TargetComponentAttributes, nil
  TargetConfig.VehicleFeatures, TargetConfig.TargetFeatures = TargetConfig.TargetFeatures, nil
  if ModID then
    if not VehicleConfig.ConfigCache[ModID] then
      VehicleConfig.ConfigCache[ModID] = {}
    end
    VehicleConfig.ConfigCache[ModID][VehicleShapeType] = TargetConfig
  end
  return TargetConfig
end
function VehicleConfig.MergeVehicleConfig(TargetConfig, NewConfig, Vehicle, VehicleShapeType)
  if not (TargetConfig and slua.isValid(Vehicle)) or not VehicleShapeType then
    return
  end
  if not (NewConfig and NewConfig.ConfigMap) or not next(NewConfig.ConfigMap) then
    return
  end
  local ConfigMap = NewConfig.ConfigMap
  if ConfigMap.default and next(ConfigMap.default) then
    VehicleConfig.MergeDefaultConfig(TargetConfig, Vehicle, ConfigMap.default)
  end
  local SpecificConfigValue = ConfigMap[VehicleShapeType]
  if type(SpecificConfigValue) == "string" and slua.IsLuaModuleExists(SpecificConfigValue) then
    SpecificConfigValue = require(SpecificConfigValue)
  end
  if type(SpecificConfigValue) == "table" then
    VehicleConfig.MergeConfig(TargetConfig, SpecificConfigValue)
  end
  if ConfigMap.Maps then
    if not TargetConfig.MapType then
      local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
      TargetConfig.MapType = GameMainConfig.GetMapType()
    end
    if TargetConfig.MapType and ConfigMap.Maps[TargetConfig.MapType] then
      local MapConfigPath = ConfigMap.Maps[TargetConfig.MapType]
      if not TargetConfig.VisitedConfigs[MapConfigPath] and slua.IsLuaModuleExists(MapConfigPath) then
        TargetConfig.VisitedConfigs[MapConfigPath] = true
        VehicleConfig.MergeVehicleConfig(TargetConfig, require(MapConfigPath), Vehicle, VehicleShapeType)
      end
    end
  end
  if ConfigMap.TeamModes and slua.isValid(CGameState) then
    local TeamMode = CGameState.PlayerNumPerTeam
    if TeamMode and ConfigMap.TeamModes[TeamMode] then
      local TeamModeConfigPath = ConfigMap.TeamModes[TeamMode]
      if not TargetConfig.VisitedConfigs[TeamModeConfigPath] and slua.IsLuaModuleExists(TeamModeConfigPath) then
        TargetConfig.VisitedConfigs[TeamModeConfigPath] = true
        VehicleConfig.MergeVehicleConfig(TargetConfig, require(TeamModeConfigPath), Vehicle, VehicleShapeType)
      end
    end
  end
end
function VehicleConfig.GetClass(InClassName)
  if not VehicleConfig.ClassMap then
    VehicleConfig.ClassMap = {}
  end
  local Cls = VehicleConfig.ClassMap[InClassName]
  if not Cls then
    Cls = import(InClassName)
    VehicleConfig.ClassMap[InClassName] = Cls
  end
  return Cls
end
function VehicleConfig.MergeDefaultConfig(TargetConfig, Vehicle, DefaultConfig)
  if not TargetConfig then
    return
  end
  if not DefaultConfig or not next(DefaultConfig) then
    return
  end
  local ClassNames = {}
  for ClassName, Config in pairs(DefaultConfig) do
    local Cls = VehicleConfig.GetClass(ClassName)
    if Game:IsClassOf(Vehicle, Cls) then
      table.insert(ClassNames, ClassName)
    end
  end
  table.sort(ClassNames, function(ClassName1, ClassName2)
    local Class1 = VehicleConfig.GetClass(ClassName1)
    local Class2 = VehicleConfig.GetClass(ClassName2)
    return Game:IsChildOf(Class2, Class1)
  end)
  for _, ClassName in pairs(ClassNames) do
    local ConfigValue = DefaultConfig[ClassName]
    if type(ConfigValue) == "string" and slua.IsLuaModuleExists(ConfigValue) then
      ConfigValue = require(ConfigValue)
    end
    if type(ConfigValue) == "table" then
      VehicleConfig.MergeConfig(TargetConfig, ConfigValue)
    end
  end
end
function VehicleConfig.MergeConfig(TargetConfig, NewConfig)
  if not TargetConfig then
    return
  end
  if not NewConfig or not next(NewConfig) then
    return
  end
  for Key, Value in pairs(NewConfig) do
    TargetConfig[Key] = Value
  end
  VehicleConfig.MergeComponents(TargetConfig.TargetComponents, NewConfig.Components)
  VehicleConfig.MergeComponentAttributes(TargetConfig.TargetComponentAttributes, NewConfig.ComponentsAttrModify)
  VehicleConfig.MergeFeatures(TargetConfig, TargetConfig.TargetFeatures, NewConfig.VehicleFeatures)
end
function VehicleConfig.MergeFeatures(TargetConfig, TargetFeatures, NewFeatures)
  if not NewFeatures or not next(NewFeatures) then
    return
  end
  if not TargetConfig or not TargetFeatures then
    return
  end
  for FeatureType, Config in pairs(NewFeatures) do
    local FeaturePath, NetSide, Params, Policy = table.unpack(Config)
    if Policy == ConfigUtils.EFeaturePolicy.Addition then
      TargetConfig.FeatureCounter = TargetConfig.FeatureCounter or {}
      TargetConfig.FeatureCounter[FeatureType] = (TargetConfig.FeatureCounter[FeatureType] or 0) + 1
      FeatureType = string.format("%s%s", FeatureType, TargetConfig.FeatureCounter[FeatureType])
    end
    if Client then
      if NetSide == ConfigUtils.ENetSide.Client or NetSide == ConfigUtils.ENetSide.Both then
        TargetFeatures[FeatureType] = Config
      end
    elseif NetSide == ConfigUtils.ENetSide.Server or NetSide == ConfigUtils.ENetSide.Both then
      TargetFeatures[FeatureType] = Config
    end
  end
end
function VehicleConfig.MergeComponents(TargetComponents, NewComponents)
  if not TargetComponents then
    return
  end
  if not NewComponents or not next(NewComponents) then
    return
  end
  for Component, Config in pairs(NewComponents) do
    if TargetComponents[Component] then
      if Config and next(Config) then
        local ComponentPath, NetSide, Enable, GenParams, Params = table.unpack(Config)
        if Enable then
          if Client then
            if NetSide == ConfigUtils.ENetSide.Client or NetSide == ConfigUtils.ENetSide.Both then
              local _, ParamConfig = table.unpack(TargetComponents[Component])
              TargetComponents[Component] = {
                ComponentPath,
                GenParams(ParamConfig, Params)
              }
            end
          elseif NetSide == ConfigUtils.ENetSide.Server or NetSide == ConfigUtils.ENetSide.Both then
            local _, ParamConfig = table.unpack(TargetComponents[Component])
            TargetComponents[Component] = {
              ComponentPath,
              GenParams(ParamConfig, Params)
            }
          end
        end
      else
        TargetComponents[Component] = nil
      end
    elseif Config and next(Config) then
      local ComponentPath, NetSide, Enable, GenParams, Params = table.unpack(Config)
      if Enable then
        if Client then
          if NetSide == ConfigUtils.ENetSide.Client or NetSide == ConfigUtils.ENetSide.Both then
            TargetComponents[Component] = {
              ComponentPath,
              GenParams({}, Params)
            }
          end
        elseif NetSide == ConfigUtils.ENetSide.Server or NetSide == ConfigUtils.ENetSide.Both then
          TargetComponents[Component] = {
            ComponentPath,
            GenParams({}, Params)
          }
        end
      end
    end
  end
end
function VehicleConfig.MergeComponentAttributes(TargetComponentAttributes, NewComponentAttributes)
  if not TargetComponentAttributes then
    return
  end
  if not NewComponentAttributes or not next(NewComponentAttributes) then
    return
  end
  for Component, Entry in pairs(NewComponentAttributes) do
    if Client then
      local NetSide, Attributes = Entry.NetSide, Entry.Attrs
      if NetSide == ConfigUtils.ENetSide.Client or NetSide == ConfigUtils.ENetSide.Both then
        TargetComponentAttributes[Component] = Attributes
      end
    else
      local NetSide, Attributes = Entry.NetSide, Entry.Attrs
      if NetSide == ConfigUtils.ENetSide.Server or NetSide == ConfigUtils.ENetSide.Both then
        TargetComponentAttributes[Component] = Attributes
      end
    end
  end
end
return VehicleConfig