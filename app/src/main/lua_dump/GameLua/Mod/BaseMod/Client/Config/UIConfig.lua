local EAndroidBackType = require("client.slua.config.ClientMacros.EAndroidBackType")
local EUIConfigPoolType = require("client.slua.config.ClientMacros.EUIConfigPoolType")
local ModulePathList = {
  "GameLua.Mod.BaseMod.Client.Config.UIConfig.UIConfig_TeamPanel",
  "GameLua.Mod.BaseMod.Client.Config.UIConfig.UIConfig_PlayerInfo",
  "GameLua.Mod.BaseMod.Client.Config.UIConfig.UIConfig_GM",
  "GameLua.Mod.BaseMod.Client.Config.UIConfig.UIConfig_Vehicle",
  "GameLua.Mod.BaseMod.Client.Config.UIConfig.UIConfig_Map",
  "GameLua.Mod.BaseMod.Client.Config.UIConfig.UIConfig_BattleResult",
  "GameLua.Mod.BaseMod.Client.Config.UIConfig.UIConfig_Tips",
  "GameLua.Mod.BaseMod.Client.Config.UIConfig.UIConfig_Skill",
  "GameLua.Mod.BaseMod.Client.Config.UIConfig.UIConfig_Backpack",
  "GameLua.Mod.BaseMod.Client.Config.UIConfig.UIConfig_Shooting",
  "GameLua.Mod.BaseMod.Client.Config.UIConfig.UIConfig_OB",
  "GameLua.Mod.BaseMod.Client.Config.UIConfig.UIConfig_Replay",
  "GameLua.Mod.BaseMod.Client.Config.UIConfig.UIConfig_Store",
  "GameLua.Mod.BaseMod.Client.Config.UIConfig.UIConfig_Social",
  "GameLua.Mod.BaseMod.Client.Config.UIConfig.UIConfig_Interactive",
  "GameLua.Mod.BaseMod.Client.Config.UIConfig.UIConfig_Parachute",
  "GameLua.Mod.BaseMod.Client.Config.UIConfig.UIConfig_KillInfo",
  "GameLua.Mod.BaseMod.Client.Config.UIConfig.UIConfig_Buff",
  "GameLua.Mod.BaseMod.Client.Config.UIConfig.UIConfig_ScreenMark",
  "GameLua.Mod.BaseMod.Client.Config.UIConfig.UIConfig_Security",
  "GameLua.Mod.BaseMod.Client.Config.UIConfig.UIConfig_Audio",
  "GameLua.Mod.BaseMod.Client.Config.UIConfig.UIConfig_Photo",
  "GameLua.Mod.BaseMod.Client.Config.UIConfig.UIConfig_UI",
  "GameLua.Mod.BaseMod.Client.Config.UIConfig.UIConfig_Activity",
  "GameLua.Mod.BaseMod.Client.Config.UIConfig.UIConfig_Medicine",
  "GameLua.Mod.BaseMod.Client.Config.UIConfig.UIConfig_StatePanel",
  "GameLua.Mod.BaseMod.Client.Config.UIConfig.UIConfig_Props",
  "GameLua.Mod.BaseMod.Client.Config.UIConfig.UIConfig_MainPanel",
  "GameLua.Mod.BaseMod.Client.Config.UIConfig.UIConfig_OtherConfig",
  "GameLua.Mod.BRMod.Client.Config.UIConfig"
}
local ModuleCache = {}
local ClearModuleCache = function()
  ModuleCache = {}
  for _, modulePath in ipairs(ModulePathList) do
    package.loaded[modulePath] = nil
  end
end
local LoadModule = function(modulePath)
  if ModuleCache[modulePath] then
    return ModuleCache[modulePath]
  end
  local success, moduleConfig = pcall(require, modulePath)
  if not success then
    print(string.format("UIConfig: Failed to load module %s, error: %s", modulePath, tostring(moduleConfig)))
    return {}
  end
  ModuleCache[modulePath] = moduleConfig
  return moduleConfig
end
local MergeAllModules = function(bReleaseAfterMerge)
  local mergedConfig = {}
  for _, modulePath in ipairs(ModulePathList) do
    local moduleConfig = LoadModule(modulePath)
    for key, value in pairs(moduleConfig) do
      if mergedConfig[key] then
        print(string.format("UIConfigNew: Warning - Duplicate key '%s' found in module %s", key, modulePath))
      end
      mergedConfig[key] = value
    end
  end
  if bReleaseAfterMerge then
    print("UIConfigNew: Releasing module cache after merge to optimize memory")
    ClearModuleCache()
  end
  return mergedConfig
end
local ReloadAllModules = function()
  ClearModuleCache()
  return MergeAllModules(true)
end
local Config = {
  UIConfig = MergeAllModules(true),
  OldUIConfig = {
    Default = DefaultInGameWidget,
    ModAdd = {}
  },
  OtherSetting = {
    MapDataPath = "/Game/BluePrints/UI/Map/MapDataBase_BP.MapDataBase_BP_C",
    OBPlayerItemPath = "/Game/BluePrints/UI/OBUI/Item/OB_PlayerHeadHPItem_UIBP.OB_PlayerHeadHPItem_UIBP",
    TeammateStatusIconConfig = {}
  },
  AutoCreateUIConfig = {}
}
return Config