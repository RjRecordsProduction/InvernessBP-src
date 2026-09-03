local STExtraGameplayStatics = import("STExtraGameplayStatics")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local TableUtil = require("common.table_util")
local CombineClass = require("combine_class")
local ForcePrintLog = _G.print
local GameMainConfig = {
  TPlan = {
    Normal = {
      ClientModeLogic = "GameLua.Mod.TPlan.Client.NormalClientLogicEntry"
    },
    HighLv = {
      ClientModeLogic = "GameLua.Mod.TPlan.Client.HighLvClientLogicEntry"
    }
  },
  BRTDM = {
    FourMaps = {
      ClientModeLogic = "GameLua.Mod.BRTDM.Client.ClientLogicEntry",
      SubsystemConfig = "GameLua.Mod.BRTDM.GamePlay.Config.SubsystemConfig"
    },
    Baltic = {
      ClientModeLogic = "GameLua.Mod.BRTDM.Client.ClientLogicEntry",
      SubsystemConfig = "GameLua.Mod.BRTDM.GamePlay.Config.SubsystemConfig"
    },
    TeamDeathMatch = {
      ClientModeLogic = "GameLua.Mod.BRTDM.Client.ClientLogicEntryTeamDeathMatch",
      NewbieGuideConfig = "GameLua.Mod.BRTDM.Client.Config.NewbieGuideConfig_TeamDeathMatch",
      SubsystemConfig = "GameLua.Mod.BRTDM.GamePlay.Config.SubsystemConfig_TeamDeathMatch"
    },
    TeamDeathMatchFourMaps = {
      ClientModeLogic = "GameLua.Mod.BRTDM.Client.ClientLogicEntryTeamDeathMatch",
      NewbieGuideConfig = "GameLua.Mod.BRTDM.Client.Config.NewbieGuideConfig_TeamDeathMatch",
      SubsystemConfig = "GameLua.Mod.BRTDM.GamePlay.Config.SubsystemConfig_TeamDeathMatch"
    }
  }
}
GameMainConfig.DefaultPath = {
  Dev = {
    BattleResultTestDataConfig = {
      Suffix = "Config.BattleResultTestDataConfig",
      bSuperposition = true,
      bFastCopyTable = true
    },
    BattleResultTestTaskDataConfig = {
      Suffix = "Config.BattleResultTestTaskDataConfig",
      bSuperposition = true,
      bFastCopyTable = true
    }
  },
  Client = {
    ClientModeLogic = {
      Suffix = "ClientLogicEntry",
      bSuperposition = false,
      bNotAllowMerge = true
    },
    UIConfig = {
      Suffix = "Config.UIConfig",
      bSuperposition = true,
      bFastCopyTable = true
    },
    SettingCatalog = {
      Suffix = "Config.SettingCatalog",
      bSuperposition = true
    },
    NewbieGuideConfig = {
      Suffix = "Config.NewbieGuideConfig",
      bSuperposition = true,
      bFastCopyTable = true
    },
    ScreenMarkConfig = {
      Suffix = "Config.ScreenMarkConfig",
      bSuperposition = true
    },
    BackpackConfig = {
      Suffix = "Config.BackpackConfig",
      bSuperposition = true
    },
    PickUpConfig = {
      Suffix = "Config.PickUpConfig",
      bSuperposition = true
    },
    BattleResultConfig = {
      Suffix = "Config.BattleResultConfig",
      bSuperposition = true
    },
    ReviveIconConfig = {
      Suffix = "Config.ReviveIconConfig",
      bSuperposition = true
    },
    TeamPanelUIConfig = {
      Suffix = "Config.TeamPanelUIConfig",
      bSuperposition = true
    },
    NewMapMarkConfig = {
      Suffix = "Config.NewMapMarkConfig",
      bSuperposition = true
    },
    ResourceMapMarkConfig = {
      Suffix = "Config.ResourceMapMarkConfig",
      bSuperposition = true
    },
    CanvasVisibleConfig = {
      Suffix = "Config.CanvasVisibleConfig",
      bSuperposition = true,
      bFastCopyTable = true
    },
    CanvasVisibleConfig_OB = {
      Suffix = "Config.CanvasVisibleConfig_OB",
      bSuperposition = true
    },
    EntireMapTaskConfig = {
      Suffix = "Config.EntireMapTaskConfig",
      bSuperposition = true
    },
    CircleChooseCfg = {
      Suffix = "Config.CircleChooseCfg",
      bSuperposition = true
    },
    SoundConfig = {
      Suffix = "Config.SoundConfig",
      bSuperposition = true
    },
    VoiceRecommendationConfig = {
      Suffix = "VoiceRecommendation.VoiceRecommendationConfig",
      bSuperposition = true
    },
    BattlePopTipsConfig = {
      Suffix = "Config.BattlePopTipsConfig",
      bSuperposition = true
    },
    MapItemConfig = {
      Suffix = "Config.MapItemConfig",
      bSuperposition = true
    },
    BattleReportConfig = {
      Suffix = "Config.BattleReportConfig",
      bSuperposition = true
    },
    BugglyReportConfig = {
      Suffix = "Config.BugglyReportConfig",
      bSuperposition = true
    },
    PlayerInfoPanelStateConfig = {
      Suffix = "Config.PlayerInfoPanelStateConfig",
      bSuperposition = true
    },
    GameGuideUIConfig = {
      Suffix = "Config.GameGuideUIConfig",
      bSuperposition = true
    },
    GameGuideUIConfig_BlueHole = {
      Suffix = "Config.GameGuideUIConfig_BlueHole",
      bSuperposition = true
    },
    ChangeMapConfig = {
      Suffix = "Config.ChangeMapConfig",
      bSuperposition = true
    },
    BattleResultSpecialShowConfig = {
      Suffix = "Config.BattleResultSpecialShowConfig",
      bSuperposition = true
    },
    MapRankModeConfig = {
      Suffix = "Config.MapRankModeConfig",
      bSuperposition = true
    },
    OBConfig = {
      Suffix = "Config.OBConfig",
      bSuperposition = true
    },
    ModWeaponConfig = {
      Suffix = "Config.ModWeaponConfig",
      bSuperposition = true
    }
  },
  DS = {
    DSModeLogic = {
      Suffix = "DSLogicEntry",
      bSuperposition = false,
      bNotAllowMerge = true
    },
    PreCalcMapIconConfig = {
      Suffix = "Config.PreCalcMapIconConfig",
      bSuperposition = true
    },
    RadiationActorConfig = {
      Suffix = "Config.RadiationActorConfig",
      bSuperposition = true
    },
    GeneralCountTimeConfig = {
      Suffix = "Config.GeneralCountTimeConfig",
      bSuperposition = true
    },
    PlaneAirlineConfig = {
      Suffix = "Config.PlaneAirlineConfig",
      bSuperposition = true
    },
    BackpackClearAndRecoverConfig = {
      Suffix = "Config.BackpackClearAndRecoverConfig",
      bSuperposition = true
    },
    SecurtyEditorConfig = {
      Suffix = "Config.SecurtyEditorConfig",
      bSuperposition = true
    },
    AIProcessModConfig = {
      Suffix = "Config.AIProcessModConfig",
      bSuperposition = true
    },
    MultiAreaBuffConfig = {
      Suffix = "Config.MultiAreaBuffConfig",
      bSuperposition = true
    }
  },
  GamePlay = {
    DynamicLuaFeatureConfig = {
      Suffix = "Config.DynamicLuaFeatureConfig",
      bSuperposition = true
    },
    EventConfig = {
      Suffix = "Config.EventDefine",
      bSuperposition = true
    },
    SkillConfig = {
      Suffix = "Skill.SkillConfig",
      bSuperposition = true
    },
    VehicleSkillConfig = {
      Suffix = "Config.VehicleSkillConfig",
      bSuperposition = true
    },
    VehicleCommonSkillConfig = {
      Suffix = "Config.VehicleCommonSkillConfig",
      bSuperposition = true
    },
    WeaponConfig = {
      Suffix = "Weapon.WeaponConfig",
      bSuperposition = true
    },
    WeaponUpgradeCfg = {
      Suffix = "Weapon.WeaponUpgradeCfg",
      bSuperposition = true
    },
    SubsystemConfig = {
      Suffix = "Config.SubsystemConfig",
      bSuperposition = true,
      bFastCopyTable = true
    },
    NewYearFireworkConfig = {
      Suffix = "Config.NewYearFireworkConfig",
      bSuperposition = true
    },
    MontageCameraConfig = {
      Suffix = "Config.MontageCameraConfig",
      bSuperposition = true
    },
    ReviveConfig = {
      Suffix = "Config.ReviveConfig",
      bSuperposition = true,
      bFastCopyTable = true
    },
    ReviveTowerConfig = {
      Suffix = "Config.ReviveTowerConfig",
      bSuperposition = true
    },
    StrongholdTowerConfig = {
      Suffix = "Config.StrongholdTowerConfig",
      bSuperposition = true
    },
    SettingReportConfig = {
      Suffix = "Config.SettingReportConfig",
      bSuperposition = true
    },
    HighDropConfig = {
      Suffix = "Config.HighDropConfig",
      bSuperposition = true
    },
    StoreConfig = {
      Suffix = "Config.StoreConfig",
      bSuperposition = true,
      bFastCopyTable = true
    },
    SilentCommunicationConfig = {
      Suffix = "Config.SilentCommunicationConfig",
      bSuperposition = true
    },
    WeatherConfig = {
      Suffix = "Config.WeatherConfig",
      bSuperposition = true
    },
    SkyTransitionConfig = {
      Suffix = "Config.SkyTransitionConfig",
      bSuperposition = true
    },
    FireworkConfig = {
      Suffix = "Config.FireworkConfig",
      bSuperposition = true
    },
    BornIslandTeamShowConfig = {
      Suffix = "Config.BornIslandTeamShowConfig",
      bSuperposition = true
    },
    SkillReplaceConfig = {
      Suffix = "Config.SkillReplaceConfig",
      bSuperposition = true
    },
    OptionalGarageVehicleConfig = {
      Suffix = "Config.OptionalGarageVehicleConfig",
      bSuperposition = true
    },
    HighlightMomentConfig = {
      Suffix = "Config.HighlightMomentConfig",
      bSuperposition = true
    },
    WonderfulPeriodConfig = {
      Suffix = "Config.WonderfulPeriodConfig",
      bSuperposition = true
    },
    QTEConfig = {
      Suffix = "Config.QTEConfig",
      bSuperposition = true
    },
    HeroSpecialConfig = {
      Suffix = "Config.HeroSpecialConfig",
      bSuperposition = true
    },
    SpecialMoveConfig = {
      Suffix = "Config.SpecialMoveConfig",
      bSuperposition = true
    },
    ThemeSkillItemConfig = {
      Suffix = "Config.ThemeSkillItemConfig",
      bSuperposition = true
    },
    CommonFightTransformConfig = {
      Suffix = "Config.CommonFightTransformConfig",
      bSuperposition = true,
      Type = "GamePlay"
    },
    MercenaryConfig = {
      Suffix = "Config.MercenaryConfig",
      bSuperposition = true,
      Type = "GamePlay"
    },
    AttachToOtherConfig = {
      Suffix = "Config.AttachToOtherConfig",
      bSuperposition = true,
      Type = "GamePlay"
    },
    SpecialMoveObjConfig = {
      Suffix = "Config.SpecialMoveObjConfig",
      bSuperposition = true,
      Type = "GamePlay"
    },
    ThemeTaskConfig = {
      Suffix = "Config.ThemeTaskConfig",
      bSuperposition = true
    },
    FootStepSoundConfig = {
      Suffix = "Config.FootStepSoundConfig",
      bSuperposition = true
    },
    PlaneShowConfig = {
      Suffix = "Config.PlaneShowConfig",
      bSuperposition = true,
      bFastCopyTable = true
    },
    DungeonConfig = {
      Suffix = "Config.DungeonConfig",
      bSuperposition = true
    },
    TeleportConfig = {
      Suffix = "Config.TeleportConfig",
      bSuperposition = true
    },
    BaseCameraConfig = {
      Suffix = "Config.BaseCameraConfig",
      bSuperposition = true
    },
    CommonHeroConfig = {
      Suffix = "Config.CommonHeroConfig",
      bSuperposition = true
    },
    PersonalTaskConfig = {
      Suffix = "Config.PersonalTaskConfig",
      bSuperposition = true
    },
    SpeciesCfg_Mob = {
      Suffix = "Config.SpeciesCfg_Mob",
      bSuperposition = true
    },
    SpeciesCfg_HumanoidMob = {
      Suffix = "Config.SpeciesCfg_HumanoidMob",
      bSuperposition = true
    },
    SpeciesCfg_NPC = {
      Suffix = "Config.SpeciesCfg_NPC",
      bSuperposition = true
    },
    SpeciesCfg_Animal = {
      Suffix = "Config.SpeciesCfg_Animal",
      bSuperposition = true
    },
    SpeciesCfg_Vehicle = {
      Suffix = "Config.SpeciesCfg_Vehicle",
      bSuperposition = true
    },
    SpeciesCfg_Decorator = {
      Suffix = "Config.SpeciesCfg_Decorator",
      bSuperposition = true
    },
    TLogConfig = {
      Suffix = "Config.TLogConfig",
      bSuperposition = true
    },
    BornIslandAirDropConfig = {
      Suffix = "Config.BornIslandAirDropConfig",
      bSuperposition = true
    },
    ModActivityAirDropManagerConfig = {
      Suffix = "Config.ModActivityAirDropManagerConfig",
      bSuperposition = true
    },
    StrongestSquadFeatureConfig = {
      Suffix = "Config.StrongestSquadFeatureConfig",
      bSuperposition = true
    },
    BaseCameraConfig = {
      Suffix = "Config.BaseCameraConfig",
      bSuperposition = true
    },
    IslandConfig = {
      Suffix = "Config.IslandConfig",
      bSuperposition = true
    },
    ReplayReportConfig = {
      Suffix = "Config.ReplayReportConfig",
      bSuperposition = true
    },
    AICommandConfig = {
      Suffix = "Config.AICommandConfig",
      bSuperposition = true
    },
    CreativeSubModeOverrideConfig = {
      Suffix = "Config.CreativeSubModeOverrideConfig",
      bSuperposition = true
    },
    BornIslandMusicConfig = {
      Suffix = "Config.BornIslandMusicConfig",
      bSuperposition = true
    }
  }
}
GameMainConfig.FixDefaultPath = {
  Dev = {
    GMConfig = {
      Suffix = "Config.GMConfig"
    },
    GMFuncConfig = {
      Suffix = "Config.GMFuncConfig"
    }
  },
  DS = {},
  GamePlay = {}
}
GameMainConfig.InternalCacheModInfo = nil
local IsLuaFileExists = function(Path)
  if CGame then
    if GameMainConfig.InternalCacheModInfo and GameMainConfig.InternalCacheModInfo.LuaFileExistsCache then
      local Cache = GameMainConfig.InternalCacheModInfo.LuaFileExistsCache
      if Cache[Path] == nil then
        Cache[Path] = GamePlayTools.LuaFileExits(Path)
      end
      return Cache[Path]
    else
      return GamePlayTools.LuaFileExits(Path)
    end
  else
    return STExtraGameplayStatics.IsDSLuaFileExists(Path)
  end
end
local EnsureModData = function()
  if GameMainConfig.InternalCacheModInfo and GameMainConfig.InternalCacheModInfo.ModID ~= 0 then
    return
  end
  local GameInstance = slua.getGameInstance()
  if not slua.isValid(GameInstance) then
    ForcePrintLog("GameMainConfig EnsureModData GameInstance is not valid")
    return
  end
  local ModID = GameInstance:GetModeID()
  local ModType = GameInstance:GetModType()
  local ModType2 = GameInstance:GetModType2()
  ForcePrintLog(string.format("GameMainConfig EnsureModData ModID = %s, ModType = %s, ModType2 = %s (%s)", ModID, ModType, ModType2, GameInstance))
  if _G.ModeID == nil or _G.ModeID == 0 then
    _G.ModeID = ModID
    ForcePrintLog(string.format("GameMainConfig EnsureModData Set _G.ModeID = %s", _G.ModeID))
  else
    ForcePrintLog(string.format("GameMainConfig EnsureModData _G.ModeID has been set to %s before", _G.ModeID))
  end
  local GameMainExtraModuleUtil = require("GameLua.GameCore.Main.GameMainExtraModuleUtil")
  local ExtraModules = GameMainExtraModuleUtil.GetExtraModules(ModID, ModType)
  GameInstance:SetExtraModules(ExtraModules)
  GameMainConfig.InternalCacheModInfo = {
    ModID = ModID,
    ModType = ModType,
    ModType2 = ModType2,
    ExtraModules = ExtraModules,
    LuaFileExistsCache = {}
  }
  return GameMainConfig.InternalCacheModInfo
end
function GameMainConfig.Clear()
  print(bWriteLog and "GameMainConfig.Clear")
  GameMainConfig.InternalCacheModInfo = nil
end
function GameMainConfig.AddModeConfig(EvoBaseConfigPath, ModeConfigPath, DefaultPath, bFastCopyTable)
  local CopyEvoBaseConfig = {}
  if EvoBaseConfigPath ~= "" then
    local EvoBaseConfig = require(EvoBaseConfigPath)
    if EvoBaseConfig then
      local TableUtil = require("common.table_util")
      local TimeUtil = require("client.common.time_util")
      local StartTime = slua.getMicroseconds()
      if bFastCopyTable then
        CopyEvoBaseConfig = TableUtil.FastCopyTable(EvoBaseConfig)
      else
        CopyEvoBaseConfig = TableUtil.CopyTable(EvoBaseConfig)
      end
      local Cost = (slua.getMicroseconds() - StartTime) / 1000
      if 0.1 < Cost then
        print(bWriteLog and string.format("GameMainConfig.AddModeConfig %s cost %s ms SLOW (bFastCopyTable = %s)", EvoBaseConfigPath, Cost, bFastCopyTable))
      end
    end
  end
  ModeConfigPath = ModeConfigPath or DefaultPath
  sandbox.LogNormal(bWriteLog and "ModeConfigPath:" .. ModeConfigPath)
  local ModeConfig
  if GamePlayTools.CanRequireLuaFile(ModeConfigPath) then
    ModeConfig = require(ModeConfigPath)
  end
  ModeConfig = ModeConfig or {}
  if string.find(DefaultPath, "Client%.Config%.UIConfig") then
    for Key, Value in pairs(ModeConfig) do
      for UIKey, UIValue in pairs(Value) do
        CopyEvoBaseConfig[Key][UIKey] = UIValue
      end
    end
  else
    if ModeConfig.bIngoreBase then
      CopyEvoBaseConfig = {}
    end
    for Key, Value in pairs(ModeConfig) do
      if Key ~= "bIngoreBase" then
        if Value == false and CopyEvoBaseConfig[Key] ~= nil then
          printf("Cancel config '%s' in BaseMod", Key)
          CopyEvoBaseConfig[Key] = nil
        elseif type(Value) == "table" and (Value.bDeepOverwrite == true or type(CopyEvoBaseConfig[Key]) == "table" and CopyEvoBaseConfig[Key].bDeepOverwrite == true) then
          GameMainConfig.DeepOverwriteTable(CopyEvoBaseConfig[Key], Value)
          CopyEvoBaseConfig[Key].bDeepOverwrite = nil
        else
          CopyEvoBaseConfig[Key] = Value
        end
      end
    end
  end
  return CopyEvoBaseConfig
end
function GameMainConfig.DeepOverwriteTable(OldTable, NewTable)
  for k, v in pairs(NewTable) do
    if type(OldTable[k]) == "table" and type(v) == "table" then
      GameMainConfig.DeepOverwriteTable(OldTable[k], v)
    else
      OldTable[k] = v
    end
  end
end
function GameMainConfig.GetModValue(ModeConfig, ModType2, Key)
  if ModeConfig == nil then
    return nil
  end
  if ModType2 and ModType2 ~= "" then
    if ModeConfig[ModType2] and ModeConfig[ModType2][Key] then
      return ModeConfig[ModType2][Key]
    else
      return ModeConfig[Key]
    end
  else
    return ModeConfig[Key]
  end
end
function GameMainConfig.GetExtraModules()
  EnsureModData()
  local ModInfo = GameMainConfig.InternalCacheModInfo
  return ModInfo.ExtraModules
end
function GameMainConfig.GetTableInheritanceExtraModules()
  EnsureModData()
  local ModInfo = GameMainConfig.InternalCacheModInfo
  local ModData = GamePlayTools.GetTableData("BTMode", ModInfo.ModID)
  print(bWriteLog and "GameMainConfig.GetTableInheritanceExtraModules", ModInfo.ModID)
  if ModData and ModData.EnableTableInheritance == true then
    return ModInfo.ExtraModules
  else
    return {}
  end
end
function GameMainConfig.HasExtraModule(ExtraModule)
  local ExtraModules = GameMainConfig.GetExtraModules()
  return TableUtil.Find(ExtraModules, ExtraModule) ~= -1
end
function GameMainConfig.GetModType()
  EnsureModData()
  local ModData = GameMainConfig.InternalCacheModInfo
  return ModData.ModType, ModData.ModType2
end
local SPECIAL_MAP_TYPE = {FourMaps = "Livik", Summerland_Mian = "Karakin"}
function GameMainConfig.GetMapType(ModeID)
  if ModeID == nil then
    ModeID = slua.getGameInstance():GetModeID()
  end
  local MapPath
  local BTMode = CDataTable.GetTableData("BTMode", ModeID)
  if BTMode then
    local MapData = CDataTable.GetTableData("Map", BTMode.MapID)
    if MapData then
      MapPath = MapData.MapPath
    end
  end
  if MapPath == nil then
    return "UnknownMap"
  end
  local LastSlashIndex = MapPath:find("/[^/]*$")
  if LastSlashIndex then
    local MapType = MapPath:sub(LastSlashIndex + 1):gsub("_Main", ""):gsub("Main_", ""):gsub("PUBG_", "")
    if SPECIAL_MAP_TYPE[MapType] then
      return SPECIAL_MAP_TYPE[MapType]
    end
    return MapType
  end
end
function GameMainConfig.GetModeID()
  EnsureModData()
  return GameMainConfig.InternalCacheModInfo.ModID
end
function GameMainConfig.GetMapNameInternal()
  local ModeID = GameMainConfig.GetModeID()
  local BTMode = CDataTable.GetTableData("BTMode", ModeID)
  if BTMode then
    local MapData = CDataTable.GetTableData("Map", BTMode.MapID)
    if MapData and MapData.MapNameInternal then
      return MapData.MapNameInternal
    end
  end
  return ""
end
function GameMainConfig.GetTableMapValue(Table)
  if type(Table) ~= "table" then
    print(bWriteLog and string.format("GameMainConfig.GetTableMapValue Value = %s (MapType not need)", Table))
    return Table
  end
  local MapType = GameMainConfig.GetMapType()
  if MapType and Table and Table[MapType] then
    local Value = Table[MapType]
    print(bWriteLog and string.format("GameMainConfig.GetTableMapValue Value = %s (MapType = %s)", Value, MapType))
    return Value
  end
  print(bWriteLog and string.format("GameMainConfig.GetTableMapValue Value is not valid (MapType = %s)", MapType))
end
function GameMainConfig.CheckCanAddConfig(Key, bSuperposition, bClient)
  if Key == "NewbieGuideConfig" then
    local ModeID = GameMainConfig.GetModeID()
    return GamePlayTools.IsBRMode(ModeID)
  end
  return bSuperposition
end
function GameMainConfig.GetAnimConfigInfo(Type, Key)
  local TyptTable = GameMainConfig.DefaultPath[Type]
  if not TyptTable then
    return
  end
  local Value = TyptTable[Key]
  if not Value then
    return
  end
  local ModType, ModType2 = GameMainConfig.GetModType()
  if ModType == nil or ModType2 == nil then
    return
  end
  local ModeConfig = GameMainConfig.GetModeConfig(ModType)
  local ModPath = ModType
  if ModeConfig and ModeConfig.ModPath and ModeConfig.ModPath ~= "" then
    ModPath = ModeConfig.ModPath
  end
  local ExtraModules = GameMainConfig.GetExtraModules()
  local ConfigPath = GameMainConfig.GetModValue(ModeConfig, ModType2, Key)
  local DefaultPath = string.format("GameLua.Mod.%s.%s.%s", ModPath, Type, Value.Suffix)
  local EvoBasePath = string.format("GameLua.Mod.BaseMod.%s.%s", Type, Value.Suffix)
  local ExtraPaths = {}
  for _, ExtraPath in ipairs(ExtraModules) do
    local LuaPath = string.format("GameLua.Mod.%s.%s.%s", ExtraPath, Type, Value.Suffix)
    if not IsLuaFileExists(LuaPath) then
      LuaPath = string.format("GameLua.ExtraModule.%s.%s.%s", ExtraPath, Type, Value.Suffix)
    end
    table.insert(ExtraPaths, LuaPath)
  end
  if GameMainConfig.CheckCanAddConfig(Key, Value.bSuperposition, Type == "Client") then
    return GameMainConfig.AddModeConfig(EvoBasePath, ConfigPath, DefaultPath, Value.bFastCopyTable)
  else
    local ModPath = ""
    if ConfigPath then
      ModPath = ConfigPath
    else
      ModPath = DefaultPath
    end
    if GamePlayTools.LuaFileExits(ModPath) then
      return require(ModPath)
    elseif Key ~= "NewbieGuideConfig" then
      return require(EvoBasePath)
    end
  end
end
function GameMainConfig.GetConfig(bClient)
  local ModType, ModType2 = GameMainConfig.GetModType()
  if ModType == nil or ModType2 == nil then
    return
  end
  local ModeConfig = GameMainConfig.GetModeConfig(ModType)
  local ModPath = ModType
  if ModeConfig and ModeConfig.ModPath and ModeConfig.ModPath ~= "" then
    ModPath = ModeConfig.ModPath
  end
  local FinalConfig = {}
  local AppendConfig = function(Type)
    for Key, Value in pairs(GameMainConfig.DefaultPath[Type]) do
      local ConfigPath = GameMainConfig.GetModValue(ModeConfig, ModType2, Key)
      local DefaultPath = string.format("GameLua.Mod.%s.%s.%s", ModPath, Type, Value.Suffix)
      local EvoBasePath = string.format("GameLua.Mod.BaseMod.%s.%s", Type, Value.Suffix)
      if GameMainConfig.CheckCanAddConfig(Key, Value.bSuperposition, Type == "Client") then
        FinalConfig[Key] = GameMainConfig.AddModeConfig(EvoBasePath, ConfigPath, DefaultPath, Value.bFastCopyTable)
      else
        local ModPath = ""
        if ConfigPath then
          ModPath = ConfigPath
        else
          ModPath = DefaultPath
        end
        if GamePlayTools.LuaFileExits(ModPath) then
          FinalConfig[Key] = ModPath
        elseif Key ~= "NewbieGuideConfig" then
          FinalConfig[Key] = EvoBasePath
        end
      end
    end
  end
  if bClient then
    AppendConfig("Client")
  else
    AppendConfig("DS")
  end
  AppendConfig("GamePlay")
  local IsDevelopment = false
  if Client and Client.IsDevelopment then
    IsDevelopment = Client.IsDevelopment()
  else
    local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
    if USTExtraBlueprintFunctionLibrary and USTExtraBlueprintFunctionLibrary.IsDevelopment then
      IsDevelopment = USTExtraBlueprintFunctionLibrary.IsDevelopment()
    end
  end
  print(bWriteLog and string.format("GameMainConfig.GetConfig IsDevelopment = %s", IsDevelopment))
  if IsDevelopment then
    AppendConfig("Dev")
  end
  return FinalConfig
end
function GameMainConfig.IsPeakGame()
  return _G.MainModeID == 11201
end
function GameMainConfig.IsNationEsports()
  return _G.MainModeID == 12103
end
function GameMainConfig.GetModeConfig(ModType)
  local ModeConfigPath = string.format("GameLua.Mod.%s.Gameplay.Config.ModeConfig", ModType)
  print(bWriteLog and "GameMainConfig.GetModeConfig Config Path is", ModeConfigPath)
  local ModeConfig
  if GamePlayTools.LuaFileExits(ModeConfigPath) then
    ModeConfig = require(ModeConfigPath)
  end
  if not ModeConfig and GameMainConfig[ModType] then
    ModeConfig = GameMainConfig[ModType]
    print(bWriteLog and "GameMainConfig.GetModeConfig GetModeConfig from GameMainConfig")
  end
  if not ModeConfig then
    print(bWriteLog and "GameMainConfig.GetModeConfig ModeConfig is nil")
  end
  return ModeConfig
end
local InternalLogFormat = function(formatStr, ...)
  if _G.IsEditor then
    ForcePrintLog(string.format(formatStr, ...))
  else
    print(bWriteLog and string.format(formatStr, ...))
  end
end
local UEGameplayClassTag = {
  "GameMode",
  "GameState",
  "PlayerController",
  "PlayerCharacter",
  "PlayerState"
}
local BaseModLuaFeatureAlias = {
  GameMode = "BRGameModeBase",
  GameState = "BRGameStateBase",
  PlayerCharacter = "BRPlayerCharacterBase",
  PlayerController = "BRPlayerControllerBase",
  PlayerState = "BRPlayerStateBase"
}
local GetImportAndExportConfig = function(MainMod, ExtraModules)
  local MainModConfigPath = string.format("GameLua.Mod.%s.ModConfig", MainMod)
  if not IsLuaFileExists(MainModConfigPath) then
    return
  end
  local MainModConfig = require(MainModConfigPath)
  if not MainModConfig then
    InternalLogFormat("GameMainConfig GetImportAndExportConfig %s is not valid, ignore", MainModConfigPath)
    return
  end
  if not MainModConfig.Import then
    MainModConfig.Import = {}
    InternalLogFormat("GameMainConfig GetImportAndExportConfig %s #auto generate: Import#", MainModConfigPath)
  end
  if not MainModConfig.Define then
    MainModConfig.Define = {}
    InternalLogFormat("GameMainConfig GetImportAndExportConfig %s #auto generate: Define#", MainModConfigPath)
  end
  if not MainModConfig.Define.ClassNamePath then
    MainModConfig.Define.ClassNamePath = {}
    InternalLogFormat("GameMainConfig GetImportAndExportConfig %s #auto generate: Define.ClassNamePath#", MainModConfigPath)
  end
  for _, Tag in ipairs(UEGameplayClassTag) do
    local ClassName = string.format("%s%s", MainMod, Tag)
    if MainMod == "BaseMod" and BaseModLuaFeatureAlias[Tag] then
      ClassName = BaseModLuaFeatureAlias[Tag]
    end
    if not MainModConfig.Define.ClassNamePath[ClassName] then
      MainModConfig.Define.ClassNamePath[ClassName] = string.format("GameLua.Mod.%s.Gameplay.Core.%s%s", MainMod, MainMod, Tag)
      InternalLogFormat("GameMainConfig GetImportAndExportConfig %s #auto generate: Define.ClassNamePath.%s = %s#", MainModConfigPath, ClassName, MainModConfig.Define.ClassNamePath[ClassName])
    end
  end
  local ExtraModConfigs = {}
  local BaseModConfigPath = "GameLua.Mod.BaseMod.ModConfig"
  if IsLuaFileExists(BaseModConfigPath) then
    local BaseModConfig = require(BaseModConfigPath)
    if BaseModConfig and BaseModConfig.Export then
      table.insert(ExtraModConfigs, BaseModConfig)
    end
  end
  for _, ExtraModule in ipairs(ExtraModules) do
    local ExtraModuleConfigPath = string.format("GameLua.Mod.%s.ModConfig", ExtraModule)
    if not IsLuaFileExists(ExtraModuleConfigPath) then
      ExtraModuleConfigPath = string.format("GameLua.ExtraModule.%s.ModConfig", ExtraModule)
    end
    local ExtraModuleConfig
    if IsLuaFileExists(ExtraModuleConfigPath) then
      ExtraModuleConfig = require(ExtraModuleConfigPath)
      if ExtraModuleConfig and ExtraModuleConfig.Export then
        table.insert(ExtraModConfigs, ExtraModuleConfig)
      else
        InternalLogFormat("GameMainConfig GetImportAndExportConfig %s has no Export, ignore", ExtraModuleConfigPath)
      end
    end
    if not MainModConfig.Import[ExtraModule] then
      MainModConfig.Import[ExtraModule] = {}
      InternalLogFormat("GameMainConfig GetImportAndExportConfig #auto generate: MainModConfig.Import.%s#", ExtraModule)
    end
    if ExtraModuleConfig and ExtraModuleConfig.Export and ExtraModuleConfig.Export.LuaFeature then
      if not MainModConfig.Import[ExtraModule].LuaFeature then
        MainModConfig.Import[ExtraModule].LuaFeature = {}
        InternalLogFormat("GameMainConfig GetImportAndExportConfig #auto generate: MainModConfig.Import.%s.LuaFeature# (%s has defined Export.LuaFeature)", ExtraModule, ExtraModule)
      end
      for _, Tag in ipairs(UEGameplayClassTag) do
        if not MainModConfig.Import[ExtraModule].LuaFeature[Tag] then
          local ClassName = string.format("%s%s", MainMod, Tag)
          if MainMod == "BaseMod" and BaseModLuaFeatureAlias[Tag] then
            ClassName = BaseModLuaFeatureAlias[Tag]
          end
          MainModConfig.Import[ExtraModule].LuaFeature[Tag] = ClassName
          InternalLogFormat("GameMainConfig GetImportAndExportConfig #auto generate: MainModConfig.Import.%s.LuaFeature.%s = %s#", ExtraModule, Tag, ClassName)
        end
      end
    end
  end
  return MainModConfig, ExtraModConfigs
end
function GameMainConfig.ApplyModFeatures()
  local MainMod = GameMainConfig.GetModType()
  if MainMod == nil then
    return
  end
  local ExtraModules = GameMainConfig.GetExtraModules()
  local MainModConfig, ExtraModConfigs = GetImportAndExportConfig(MainMod, ExtraModules)
  if not MainModConfig or not ExtraModConfigs then
    InternalLogFormat("GameMainConfig ApplyModFeatures MainModConfig or ExtraModExportConfigs is nil (MainMod = %s)", MainMod)
    return
  end
  local ClassName2FeatureDefineList = {}
  for _, ExtraModConfig in ipairs(ExtraModConfigs) do
    local ExtraModExportConfig = ExtraModConfig.Export
    local ExtraModule = ExtraModExportConfig.Name
    if ExtraModExportConfig.LuaFeature then
      InternalLogFormat("GameMainConfig ApplyModFeatures apply LuaFeature (%s -> %s)", ExtraModule, MainMod)
      for Tag, FeatureDefineList in pairs(ExtraModExportConfig.LuaFeature) do
        local MainModImportConfig = MainModConfig.Import
        if MainModImportConfig and MainModImportConfig[ExtraModule] and MainModImportConfig[ExtraModule].LuaFeature then
          local ClassName = MainModImportConfig[ExtraModule].LuaFeature[Tag]
          assert(MainModConfig.Define and MainModConfig.Define.ClassNamePath and MainModConfig.Define.ClassNamePath[ClassName], string.format("%s must have a ClassNamePath mapping in ModConfig", ClassName))
          local MainModClassPath = MainModConfig.Define.ClassNamePath[ClassName]
          local FeatureInfo = ClassName2FeatureDefineList[ClassName]
          if not FeatureInfo then
            FeatureInfo = {
              Tag = Tag,
              ExtraModules = {},
              FeatureDefineList = {}
            }
            ClassName2FeatureDefineList[ClassName] = FeatureInfo
          end
          TableUtil.TableConcat(FeatureInfo.FeatureDefineList, FeatureDefineList)
          table.insert(FeatureInfo.ExtraModules, ExtraModule)
          InternalLogFormat("GameMainConfig ApplyModFeatures redirect %s (ExtraModule = %s, Tag = %s)", MainModClassPath, ExtraModule, Tag)
        end
      end
    end
  end
  for ClassName, FeatureInfo in pairs(ClassName2FeatureDefineList) do
    CombineClass.AddLuaClassExtraFeatures(ClassName, FeatureInfo.FeatureDefineList)
  end
  local AllModConfigs = TableUtil.TableConcat({MainModConfig}, ExtraModConfigs)
  for _, ModConfig in ipairs(AllModConfigs) do
    if ModConfig.Define and ModConfig.Define.LuaFeature then
      InternalLogFormat("GameMainConfig ApplyModFeatures Inject LuaFeature from Mod")
      for ClassName, FeatureDefine in pairs(ModConfig.Define.LuaFeature) do
        CombineClass.AddLuaClassExtraFeatures(ClassName, FeatureDefine)
      end
    end
  end
end
function GameMainConfig.ApplyModConfigs(bClient)
  local GetConfigPath = function(Mod, Group, Name, bSearchExtraModulePath)
    local DefaultPathConfig = GameMainConfig.DefaultPath[Group][Name]
    if DefaultPathConfig == nil then
      DefaultPathConfig = GameMainConfig.FixDefaultPath[Group][Name]
    end
    local Suffix = DefaultPathConfig ~= nil and DefaultPathConfig.Suffix or Name
    local LuaPath = string.format("GameLua.Mod.%s.%s.%s", Mod, Group, Suffix)
    if not IsLuaFileExists(LuaPath) and bSearchExtraModulePath then
      LuaPath = string.format("GameLua.ExtraModule.%s.%s.%s", Mod, Group, Suffix)
    end
    return LuaPath
  end
  local InternalGetOriginModConfig = function(Context, Mod)
    local Path = GetConfigPath(Mod, Context.Group, Context.ConfigName, true)
    local ModConfig = IsLuaFileExists(Path) and Context.OriginLuaRequireFunc(Path) or {}
    return ModConfig
  end
  local MergeModConfigTable = function(Result, Context, TableKeys)
    local InternalMergeModConfigTable = function(Result, Context, TableKeys)
      for _, Mod in ipairs(Context.ModList) do
        local ModConfig = Context.OriginConfig[Mod]
        if ModConfig then
          local TempDstTable = Result
          local TempSrcTable = ModConfig
          if TableKeys and 0 < #TableKeys then
            local Key
            for i = 1, #TableKeys do
              Key = TableKeys[i]
              InternalLogFormat("GameMainConfig.ApplyModConfigs InternalMergeModConfigTable Key: %s", Key)
              if not TempDstTable[Key] then
                TempDstTable[Key] = {}
              end
              TempDstTable = TempDstTable[Key]
              TempSrcTable = TempSrcTable[Key]
              TempSrcTable = TempSrcTable or {}
            end
          end
          TableUtil.OverrideTable(TempDstTable, TempSrcTable)
        end
      end
    end
    InternalMergeModConfigTable(Result, Context, TableKeys)
  end
  local MergeModConfigTableDeepOverwrite = function(Result, Context, TableKeys)
    for _, Mod in ipairs(Context.ModList) do
      local ModConfig = Context.OriginConfig[Mod]
      if ModConfig then
        local TempDstTable = Result
        local TempSrcTable = ModConfig
        GameMainConfig.DeepOverwriteTable(TempDstTable, TempSrcTable)
      end
    end
  end
  local MergeConfigStrategyMap = {
    Default = function(Context)
      local Result = {}
      MergeModConfigTable(Result, Context)
      return Result
    end,
    CircleChooseCfg = function(Context)
      local Result = {}
      MergeModConfigTableDeepOverwrite(Result, Context)
      return Result
    end,
    SpecialMoveConfig = function(Context)
      local Result = {}
      MergeModConfigTableDeepOverwrite(Result, Context)
      return Result
    end,
    UIConfig = function(Context)
      local Result = {
        UIConfig = {},
        OldUIConfig = {
          Default = DefaultInGameWidget,
          ModAdd = {}
        },
        OtherSetting = {}
      }
      MergeModConfigTable(Result, Context, {"UIConfig"})
      MergeModConfigTable(Result, Context, {
        "OldUIConfig",
        "ModAdd"
      })
      MergeModConfigTable(Result, Context, {
        "OtherSetting"
      })
      return Result
    end,
    EventConfig = function(Context)
      local Result = {}
      for _, Mod in ipairs(Context.ModList) do
        Context.OriginConfig[Mod] = InternalGetOriginModConfig(Context, Mod)
        MergeModConfigTable(Result, Context)
      end
      return Result
    end,
    GMConfig = function(Context)
      local Result = {
        IngameGMTags = {},
        IngameGMMode = {}
      }
      MergeModConfigTable(Result, Context, {
        "IngameGMMode"
      })
      for _, Mod in ipairs(Context.ModList) do
        local ModConfig = Context.OriginConfig[Mod]
        if ModConfig.IngameGMTags then
          Result.IngameGMTags = TableUtil.TableConcat(TableUtil.DeepCloneTable(Result.IngameGMTags), ModConfig.IngameGMTags)
        end
      end
      return Result
    end,
    GMFuncConfig = function(Context)
      local MainModClass = Context.OriginConfig[Context.MainMod]
      if not MainModClass.__inner_impl then
        local class = require("class")
        local objcet = require("object")
        MainModClass = class(objcet, nil, {})
      end
      for CurrentIndex = #Context.ExtraModules, 1, -1 do
        local Mod = Context.ExtraModules[CurrentIndex]
        local ExtraModClass = Context.OriginConfig[Mod]
        TableUtil.OverwriteTable(MainModClass.__inner_impl, ExtraModClass.__inner_impl)
      end
      return MainModClass
    end
  }
  local FillContextOriginConfigs = function(Context)
    Context.OriginConfig = {}
    if Context.ConfigName == "EventConfig" then
      return
    end
    for _, Mod in ipairs(Context.ModList) do
      Context.OriginConfig[Mod] = InternalGetOriginModConfig(Context, Mod)
    end
  end
  local GetLuaRequireRedirectFunc = function(Context)
    local ConfigName = Context.ConfigName
    local StrategyFunc = MergeConfigStrategyMap[ConfigName] ~= nil and MergeConfigStrategyMap[ConfigName] or MergeConfigStrategyMap.Default
    local LuaRequireRedirectFunc = function(Path, OriginLuaRequireFunc)
      Context.      FillContextOriginConfigs(Context)
      local Result = StrategyFunc(Context)
      if Context.OnPostMerge then
        InternalLogFormat("GameMainConfig.ApplyModConfigs %s OnPostMerge", Context.ConfigName)
        Result = Context.OnPostMerge(Result, Context)
      end
      return Result
    end
    return LuaRequireRedirectFunc
  end
  local ApplyExtraModuleConfigs = function(MainMod, CollectConfigs, Group)
    for ConfigName, CollectConfig in pairs(CollectConfigs[Group]) do
      local MainModConfigPath = GetConfigPath(MainMod, Group, ConfigName, false)
      InternalLogFormat("GameMainConfig.ApplyModConfigs redirect %s to strategy func(%s)", MainModConfigPath, ConfigName)
      local Context = {
        MainMod = MainMod,
        ExtraModules = CollectConfig.ExtraModules,
        ModList = TableUtil.TableConcat(TableUtil.DeepCloneTable(CollectConfig.ExtraModules), {MainMod}),
        Group = Group,
        ConfigName = ConfigName,
        OnPostMerge = CollectConfig.OnPostMerge
      }
      CombineClass.AddLuaRequireRedirect(MainModConfigPath, GetLuaRequireRedirectFunc(Context))
    end
  end
  local AutoCollectExtraModuleConfigs = function(ExtraModule, PathsConfig, MainModConfig, OutCollectConfigs)
    for Group, GroupConfig in pairs(PathsConfig) do
      for ConfigName, Config in pairs(GroupConfig) do
        if not Config.bNotAllowMerge then
          local LuaPath = GetConfigPath(ExtraModule, Group, ConfigName, true)
          if IsLuaFileExists(LuaPath) then
            local CollectConfig = OutCollectConfigs[Group][ConfigName]
            if not CollectConfig then
              CollectConfig = {
                ExtraModules = {}
              }
              OutCollectConfigs[Group][ConfigName] = CollectConfig
            end
            table.insert(CollectConfig.ExtraModules, ExtraModule)
            InternalLogFormat("GameMainConfig.ApplyModConfigs AutoCollectExtraModuleConfigs ExtraModule = %s, ConfigName = %s", ExtraModule, ConfigName)
            local MainModImportConfig = MainModConfig.Import
            if MainModImportConfig and MainModImportConfig.Config and MainModImportConfig.Config[Group] and MainModImportConfig.Config[Group][ConfigName] then
              local CustomConfig = MainModImportConfig.Config[Group][ConfigName]
              CollectConfig.OnPostMerge = CustomConfig.OnPostMerge
            end
          end
        end
      end
    end
  end
  local MainMod = GameMainConfig.GetModType()
  if MainMod == nil then
    return
  end
  local ExtraModules = GameMainConfig.GetExtraModules()
  local MainModConfig, ExtraModuleConfigs = GetImportAndExportConfig(MainMod, ExtraModules)
  if not MainModConfig then
    InternalLogFormat("GameMainConfig.ApplyModConfigs MainModConfig is nil (MainMod = %s)", MainMod)
    return
  end
  if not ExtraModuleConfigs then
    InternalLogFormat("GameMainConfig.ApplyModConfigs ExtraModExportConfigs is nil (MainMod = %s)", MainMod)
    return
  end
  local CollectConfigs = {
    Dev = {},
    Client = {},
    DS = {},
    GamePlay = {}
  }
  for _, ExtraModuleConfig in ipairs(ExtraModuleConfigs) do
    local ExtraModExportConfig = ExtraModuleConfig.Export
    local ExtraModule = ExtraModExportConfig.Name
    if ExtraModExportConfig.AutoExportAllConfig == true then
      AutoCollectExtraModuleConfigs(ExtraModule, GameMainConfig.DefaultPath, MainModConfig, CollectConfigs)
      AutoCollectExtraModuleConfigs(ExtraModule, GameMainConfig.FixDefaultPath, MainModConfig, CollectConfigs)
    else
      for Group, GroupCollectConfigs in pairs(CollectConfigs) do
        if ExtraModExportConfig[Group] then
          for _, ConfigName in ipairs(ExtraModExportConfig[Group]) do
            local CollectConfig = GroupCollectConfigs[ConfigName]
            if not CollectConfig then
              CollectConfig = {
                ExtraModules = {}
              }
              GroupCollectConfigs[ConfigName] = CollectConfig
            end
            table.insert(CollectConfig.ExtraModules, ExtraModule)
            InternalLogFormat("GameMainConfig.ApplyModConfigs CollectExtraModuleConfig ExtraModule = %s, ConfigName = %s", ExtraModule, ConfigName)
            local MainModImportConfig = MainModConfig.Import
            if MainModImportConfig and MainModImportConfig.Config and MainModImportConfig.Config[Group] and MainModImportConfig.Config[Group][ConfigName] then
              local CustomConfig = MainModImportConfig.Config[Group][ConfigName]
              CollectConfig.OnPostMerge = CustomConfig.OnPostMerge
            end
          end
        end
      end
    end
  end
  ApplyExtraModuleConfigs(MainMod, CollectConfigs, "Dev")
  if bClient then
    ApplyExtraModuleConfigs(MainMod, CollectConfigs, "Client")
  else
    ApplyExtraModuleConfigs(MainMod, CollectConfigs, "DS")
  end
  ApplyExtraModuleConfigs(MainMod, CollectConfigs, "GamePlay")
end
function GameMainConfig:ApplyModOtherConfigs(bClient)
  local MainMod = GameMainConfig.GetModType()
  if MainMod == nil then
    return
  end
  local ModLogicSwitchConfig = {
    TPlan = "/Game/Mod/TPlan/BluePrints/Core/STExtraModLogicSwitch_TPlan_BP.STExtraModLogicSwitch_TPlan_BP_C",
    TPlanPVE = "/Game/Mod/TPlanPVE/BluePrints/Core/STExtraModLogicSwitch_TPlan_BP.STExtraModLogicSwitch_TPlan_BP_C",
    TPlanEBR = "/Game/Mod/TPlan/BluePrints/Core/STExtraModLogicSwitch_TPlan_BP.STExtraModLogicSwitch_TPlan_BP_C",
    TPlanTDM = "/Game/Mod/TPlanTDM/BluePrints/Core/STExtraModLogicSwitch_TPlanTDM_BP.STExtraModLogicSwitch_TPlanTDM_BP_C",
    Borderland = "/Game/Mod/Borderland/BluePrints/Core/BP_ModLogicSwitchConfig_Borderland.BP_ModLogicSwitchConfig_Borderland_C",
    Sink2 = "/Game/Mod/Sink2/BluePrints/Core/BP_SinkModLogicSwitchConfig.BP_SinkModLogicSwitchConfig_C"
  }
  local ModLogicSwitchTag = ModLogicSwitchConfig[MainMod] or ""
  local USTExtraModLogicSwitchLibrary = import("STExtraModLogicSwitchLibrary")
  USTExtraModLogicSwitchLibrary.InitModLogicSwitch(ModLogicSwitchTag)
end
function GameMainConfig.ShouldShowRecycItemPrice()
  local IgnoreModeIDTable = {
    [90025] = true,
    [90026] = true,
    [90027] = true,
    [90028] = true,
    [14003] = true
  }
  local ModeID = GameMainConfig.GetModeID()
  if IgnoreModeIDTable[ModeID] then
    return false
  end
  return true
end
return GameMainConfig