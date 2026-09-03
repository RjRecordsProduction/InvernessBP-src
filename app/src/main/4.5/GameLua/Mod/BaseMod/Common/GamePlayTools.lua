local GamePlayTools = {
  BRMainModeIds = {
    101,
    102,
    103,
    401,
    402,
    403,
    111,
    112,
    113,
    411,
    412,
    413
  },
  SocialIslandModeList = {
    21001,
    21002,
    21003,
    21004
  },
  TrainingModeList = {
    1007,
    1008,
    1009,
    10071,
    10080
  }
}
function GamePlayTools.IsEditor()
  if IsEditor then
    return true
  elseif Client and Client.IsEditor() then
    return true
  end
  return false
end
function GamePlayTools.GetEditorWorld(bClient)
  return slua.getWorld()
end
function GamePlayTools.GetEditorModeType(bClient)
  local ModType = "Default"
  local ModType2 = ""
  local World = GamePlayTools.GetEditorWorld(bClient)
  if slua.isValid(World) == false then
    if sandbox then
      sandbox.LogError("get editor mode type: world is not valid")
    end
    return ModType, ModType2
  end
  local uPersistentLevel = World.PersistentLevel
  if slua.isValid(uPersistentLevel) == false then
    if sandbox then
      sandbox.LogError("get editor mode type: PersistentLevel is not valid")
    end
    return ModType, ModType2
  end
  local uWorldSettings = uPersistentLevel.WorldSettings
  if slua.isValid(uWorldSettings) == false then
    if sandbox then
      sandbox.LogError("get editor mode type: WorldSettings is not valid")
    end
    return ModType, ModType2
  end
  local USTExtraGameplayStatics = import("STExtraGameplayStatics")
  local uDefaultGameMode = uWorldSettings.DefaultGameMode
  local uGameModeCDO = USTExtraGameplayStatics.GetClassDefaultObject(uDefaultGameMode)
  if slua.isValid(uGameModeCDO) == false then
    if sandbox then
      sandbox.LogError("get editor mode type: uGameModeCDO is not valid")
    end
    return ModType, ModType2
  elseif uGameModeCDO.LuaModPath ~= "" and uGameModeCDO.LuaSubMod then
    ModType = uGameModeCDO.LuaModPath
    ModType2 = uGameModeCDO.LuaSubMod
  else
    local UKismetSystemLibrary = import("KismetSystemLibrary")
    local sPath = UKismetSystemLibrary.GetPathName(uGameModeCDO)
    local sModPath = string.match(sPath, "/Game/Mod/([^/]*)/.*")
    if sModPath then
      ModType = sModPath
    end
  end
  return ModType, ModType2
end
function GamePlayTools.GetTableData(TableName, TableKey)
  return CDataTable.GetTableData(TableName, TableKey)
end
function GamePlayTools.GetTable(TableName)
  return CDataTable.GetTable(TableName)
end
function GamePlayTools.GetServerWorldTimeSeconds(uOptionalWorldContextObject)
  if Client then
    if not slua_GameFrontendHUD then
      return -1
    end
    local uGameState = slua_GameFrontendHUD:GetGameState()
    if not slua.isValid(uGameState) then
      return -1
    end
    if uGameState.ReplicatedWorldTimeSeconds <= 0 then
      return -1
    end
    return uGameState:GetServerWorldTimeSeconds()
  else
    if slua.isValid(CGameState) then
      return CGameState:GetServerWorldTimeSeconds()
    end
    if uOptionalWorldContextObject then
      local UGameplayStatics = import("GameplayStatics")
      local uGameState = UGameplayStatics.GetGameState(uOptionalWorldContextObject)
      if slua.isValid(uGameState) then
        return uGameState:GetServerWorldTimeSeconds()
      end
    end
    return -1
  end
end
function GamePlayTools.StrToTable(Str)
  if not Str or Str == "" then
    return {}
  else
    return load("return " .. Str)()
  end
end
function GamePlayTools.TableToFVector(InTable)
  if not InTable then
    return FVector(0, 0, 0)
  else
    return FVector(InTable[1] or 0, InTable[2] or 0, InTable[3] or 0)
  end
end
function GamePlayTools.TableToFRotator(InTable)
  if not InTable then
    return FRotator(0, 0, 0)
  else
    return FRotator(InTable[1] or 0, InTable[2] or 0, InTable[3] or 0)
  end
end
function GamePlayTools.LuaFileExits(InPath)
  if InPath == nil or InPath == "" then
    return false
  end
  local Path = string.gsub(InPath, "%.", "/")
  if Client then
    local FullPath = Client.GetLuaRootDir() .. Path .. ".lua"
    return Client.IsFileExistsWithPakCheck(FullPath)
  else
    if CGame == nil then
      return false
    end
    local FullPath = CGame:GetLuaRootDir() .. Path .. ".lua"
    return CGame:IsFileExists(FullPath)
  end
end
function GamePlayTools.CanRequireLuaFile(InPath)
  return GamePlayTools.LuaFileExits(InPath) or require("combine_class").HasLuaRequireRedirect(InPath)
end
function GamePlayTools.SplitString(Str, SplitChar)
  local SubStrTab = {}
  while true do
    local Pos = string.find(Str, SplitChar)
    if not Pos then
      local Size = #SubStrTab
      table.insert(SubStrTab, Size + 1, Str)
      break
    end
    local SubStr = string.sub(Str, 1, Pos - 1)
    local Size = #SubStrTab
    table.insert(SubStrTab, Size + 1, SubStr)
    local t = string.len(Str)
    Str = string.sub(Str, Pos + 1, t)
  end
  return SubStrTab
end
function GamePlayTools.InitEvent(bShipping, InEnv)
  local   local   local   local   local _ENV = InEnv
  _G.EventDefineID = _G.EventDefineID or {}
  _G.EventTypeNum = _G.EventTypeNum or 0
  local ingameMap = {}
  if bShipping then
    setmetatable(_ENV, {
      __newindex = function(t, k, v)
        if _G[k] == nil then
          _G.EventTypeNum = _G.EventTypeNum + 1
          _G[k] = _G.EventTypeNum
        end
        _G.EventDefineID[_G.EventTypeNum] = k
      end
    })
  else
    setmetatable(_ENV, {
      __newindex = function(t, k, v)
        _G.EventTypeNum = _G.EventTypeNum + 1
        if _G[k] == nil then
          _G.EventTypeNum = _G.EventTypeNum + 1
          _G[k] = _G.EventTypeNum
        end
        assert(ingameMap[k] == nil, string.format("Duplicate event type/id defined[%s]!", k))
        ingameMap[k] = _G.EventTypeNum
        _G.EventDefineID[_G.EventTypeNum] = k
      end
    })
  end
end
function GamePlayTools.IsBRMode(nGameMode)
  if nGameMode == nil then
    local GameInstance = slua.getGameInstance()
    nGameMode = GameInstance:GetModeID()
  end
  if GamePlayTools.BRModeTable == nil then
    local TeamModeIds = {}
    for _, BRMainModeId in pairs(GamePlayTools.BRMainModeIds) do
      local TableRow = GamePlayTools.GetTableData("MatchModeTable", BRMainModeId)
      if TableRow and TableRow.ModeGroupID then
        local ModeGroupIds = load("return" .. TableRow.ModeGroupID)()
        for _, ModeGroupId in pairs(ModeGroupIds) do
          table.insert(TeamModeIds, ModeGroupId)
        end
      end
    end
    GamePlayTools.BRModeTable = {}
    for _, TeamModeId in pairs(TeamModeIds) do
      local TableRow = GamePlayTools.GetTableData("ModeTeamTable", TeamModeId)
      if TableRow and TableRow.SubModeIds then
        local SubModeIds = load("return" .. TableRow.SubModeIds)()
        for _, SubModeId in pairs(SubModeIds) do
          table.insert(GamePlayTools.BRModeTable, SubModeId)
        end
      end
    end
  end
  local TableUtil = require("common.table_util")
  return TableUtil.Find(GamePlayTools.BRModeTable, nGameMode) ~= -1
end
function GamePlayTools.GetBattleModeFightType(ModeID)
  if ModeID == nil then
    local GameInstance = slua.getGameInstance()
    ModeID = GameInstance:GetModeID()
  end
  local BTMode = CDataTable.GetTableData("BTMode", ModeID)
  if BTMode then
    return BTMode.BattleModeFightType
  end
  return nil
end
function GamePlayTools.IsThemeBRMode(ModeID)
  return GamePlayTools.GetBattleModeFightType(ModeID) == 1
end
function GamePlayTools.IsUGCMode(ModeID)
  return GamePlayTools.GetBattleModeFightType(ModeID) == 8
end
function GamePlayTools.IsTDMode(ModeID)
  return GamePlayTools.GetBattleModeFightType(ModeID) == 2
end
function GamePlayTools.IsForcedFPP(ModeID)
  if ModeID == nil then
    local GameInstance = slua.getGameInstance()
    ModeID = GameInstance:GetModeID()
  end
  local BTMode = CDataTable.GetTableData("BTMode", ModeID)
  if BTMode then
    return BTMode.IsFpp
  end
  return nil
end
function GamePlayTools.EnableKingElimination()
  local EnableKingEliminationFightType = {
    [0] = true,
    [1] = true
  }
  local DisableKingEliminationModeID = {
    [12001] = true,
    [12002] = true,
    [12004] = true,
    [16000] = true,
    [16001] = true,
    [16002] = true,
    [32001] = true,
    [32002] = true,
    [32003] = true,
    [32004] = true,
    [32005] = true,
    [32006] = true,
    [1022] = true,
    [1023] = true,
    [1024] = true,
    [1025] = true,
    [1026] = true,
    [1027] = true,
    [1028] = true,
    [1029] = true,
    [1030] = true,
    [1031] = true,
    [1032] = true,
    [1033] = true,
    [1034] = true,
    [1035] = true,
    [1036] = true,
    [1037] = true,
    [1038] = true,
    [1039] = true,
    [1040] = true,
    [1041] = true,
    [1042] = true,
    [1043] = true,
    [1044] = true,
    [1045] = true,
    [1046] = true,
    [1047] = true,
    [1048] = true,
    [1049] = true,
    [1050] = true,
    [1051] = true,
    [1052] = true,
    [1053] = true,
    [1054] = true,
    [1055] = true,
    [1056] = true,
    [1057] = true,
    [1058] = true,
    [1059] = true,
    [1060] = true,
    [1061] = true,
    [1062] = true,
    [1063] = true,
    [1064] = true,
    [1065] = true,
    [1066] = true,
    [1067] = true,
    [1068] = true,
    [1069] = true,
    [1073] = true,
    [1074] = true,
    [1075] = true,
    [1122] = true,
    [1123] = true,
    [1124] = true,
    [1125] = true,
    [1126] = true,
    [1127] = true,
    [1128] = true,
    [1129] = true,
    [1130] = true,
    [1131] = true,
    [1132] = true,
    [1133] = true,
    [1134] = true,
    [1135] = true,
    [1136] = true
  }
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local ModeID = GameMainConfig.GetModeID()
  if DisableKingEliminationModeID[ModeID] then
    return false
  end
  local BTModeConfig = CDataTable.GetTableData("BTMode", ModeID)
  if not BTModeConfig then
    return false
  end
  if EnableKingEliminationFightType[BTModeConfig.BattleModeFightType] then
    return true
  end
  return false
end
function GamePlayTools.GetCurrentConfig(Key)
  if Client then
    local ClientGameMain = require("GameLua.GameCore.Main.ClientGameMain")
    return ClientGameMain.GetCurrentConfig(Key)
  else
    local DSGameMain = require("GameLua.GameCore.Main.GameMain")
    return DSGameMain.GetCurrentConfig(Key)
  end
end
function GamePlayTools.GetConfigAfterModRedirect(Path, FallBackPathOrContent)
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local ModType = GameMainConfig.GetModType()
  if Path == nil or ModType == nil then
    return nil
  end
  local FinalPath = string.format("GameLua.Mod.%s.%s", ModType, Path)
  local ModeConfig
  if GamePlayTools.LuaFileExits(FinalPath) then
    ModeConfig = require(FinalPath)
  elseif FallBackPathOrContent ~= nil then
    if type(FallBackPathOrContent) == "string" then
      if GamePlayTools.LuaFileExits(FallBackPathOrContent) then
        ModeConfig = require(FallBackPathOrContent)
      end
    elseif type(FallBackPathOrContent) == "table" then
      ModeConfig = FallBackPathOrContent
    end
  end
  return ModeConfig
end
function GamePlayTools.GetPlayerControllerByIndex(Index)
  Index = Index or 0
  local UGameplayStatics = import("GameplayStatics")
  local UIUtil = require("client.common.ui_util")
  return UGameplayStatics.GetPlayerController(UIUtil.GetGameInstance(), 0)
end
function GamePlayTools.GetCharacterByIndex(Index)
  local Controller = GamePlayTools.GetPlayerControllerByIndex(Index)
  if slua.isValid(Controller) and Controller.GetPlayerCharacterSafety then
    local Character = Controller:GetPlayerCharacterSafety()
    if slua.isValid(Character) then
      return Character
    end
  end
end
function GamePlayTools.TraceGround(Actor, TraceDeepDis)
  if not slua.isValid(Actor) or not TraceDeepDis then
    return
  end
  local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local TraceStart = Actor:K2_GetActorLocation()
  if not TraceStart then
    return
  end
  local HitResult = import("/Script/Engine.HitResult")()
  local Success = false
  Success, HitResult = USTExtraBlueprintFunctionLibrary.TraceGround(Actor, TraceStart, TraceDeepDis, HitResult, false)
  if Success then
    return TraceStart.Z - HitResult.Location.Z
  else
    return TraceDeepDis
  end
end
function GamePlayTools.GetModPath(bClient, Suffix, IgnoreSubMode)
  local ModPath = ""
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  local ModType, ModeType2 = GameMainConfig.GetModType()
  if not IgnoreSubMode and ModeType2 ~= nil and ModeType2 ~= "" then
    ModPath = string.format("GameLua.Mod.%s.%s", ModType, ModeType2)
  else
    if ModType == nil or type(ModType) == "boolean" then
      ModType = "BaseMod"
    end
    ModPath = string.format("GameLua.Mod.%s", ModType)
  end
  local LuaConfigPath = string.format("%s.%s", ModPath, Suffix)
  if GamePlayTools.LuaFileExits(LuaConfigPath) then
    return LuaConfigPath
  elseif require("combine_class").HasLuaRequireRedirect(LuaConfigPath) then
    return LuaConfigPath
  else
    local BaseModPath = string.format("GameLua.Mod.BaseMod.%s", Suffix)
    if not GamePlayTools.LuaFileExits(BaseModPath) then
      local BRModPath = string.format("GameLua.Mod.BRMod.%s", Suffix)
      if GamePlayTools.LuaFileExits(BRModPath) then
        print(bWriteLog and string.format("GamePlayTools.GetModPath fallback to BRMod: %s -> %s", BaseModPath, BRModPath))
        return BRModPath
      end
    end
    return BaseModPath
  end
end
function GamePlayTools.IsSocialIslandModeDS()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uGameState = GameplayData.GetGameState()
  if not slua.isValid(uGameState) then
    print(bWriteLog and "[GamePlayTools] invalid game state")
    return false
  end
  local curGameModeID = tonumber(uGameState.GameModeID)
  print(bWriteLog and "[GamePlayTools] curGameModeID: " .. tostring(curGameModeID))
  for _, modeID in ipairs(GamePlayTools.SocialIslandModeList) do
    if curGameModeID == modeID then
      return true
    end
  end
  return false
end
function GamePlayTools.IsTrainingModeDS()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uGameState = GameplayData.GetGameState()
  if not slua.isValid(uGameState) then
    print(bWriteLog and "[GamePlayTools] invalid game state")
    return false
  end
  local curGameModeID = tonumber(uGameState.GameModeID)
  print(bWriteLog and "[GamePlayTools] curGameModeID: " .. tostring(curGameModeID))
  for _, modeID in ipairs(GamePlayTools.TrainingModeList) do
    if curGameModeID == modeID then
      return true
    end
  end
  return false
end
function GamePlayTools.PlayEffect(AssetPath, Location, Rotator, Scale)
  if not Client then
    return
  end
  local Util = require("client.slua_ui_framework.util")
  Util.GetAssetAsync(AssetPath, function(uParticle)
    if slua.isValid(uParticle) then
      local UGameplayStatics = import("GameplayStatics")
      UGameplayStatics.SpawnEmitterAtLocation(slua_GameFrontendHUD:GetWorld(), uParticle, Location, Rotator or FRotator.ZeroRotator, Scale or FVector.OneVector, true)
    end
  end)
end
function GamePlayTools.PlayEffectAsync(AssetPath, Location, Rotator, Scale, CallBack)
  if not Client then
    return
  end
  local Util = require("client.slua_ui_framework.util")
  Util.GetAssetAsync(AssetPath, function(uParticle)
    if slua.isValid(uParticle) then
      local UGameplayStatics = import("GameplayStatics")
      local uParticle = UGameplayStatics.SpawnEmitterAtLocation(slua_GameFrontendHUD:GetWorld(), uParticle, Location, Rotator or FRotator.ZeroRotator, Scale or FVector.OneVector, true)
      if CallBack then
        if not slua.isValid(uParticle) then
          CallBack(nil)
          return
        end
        CallBack(uParticle)
      end
    end
  end)
end
function GamePlayTools.PlayAudio(AssetPath, Config)
  if not Config then
    return
  end
  local Location
  if slua.isValid(Config.Actor) and Config.Actor.K2_GetActorLocation then
    Location = Config.Actor:K2_GetActorLocation()
  else
    Location = Config.Location
  end
  if Location then
    local audio_util = require("client.common.audio_util")
    audio_util.PlayAudioAsyncAtLocation(AssetPath, Location, FRotator(0, 0, 0))
  end
end
function GamePlayTools.PrepareTween(SuccessCallback, FallbackCallback, Caller)
  if not Client then
    print(bWriteLog and string.format("GamePlayTools.PrepareTween disable on server, will fallback"))
    if FallbackCallback then
      FallbackCallback(Caller)
    end
    return
  end
  local ActorTools = require("GameLua.Mod.BaseMod.Common.ActorTools")
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local Util = require("client.slua_ui_framework.util")
  local TweenManagerActorClassPath = "/Game/Mod/EvoBase/Arts_Scenes/Weather/BP_TweenManagerActor.BP_TweenManagerActor_C"
  Util.GetAssetAsync(TweenManagerActorClassPath, function(TweenManagerActorClass)
    local PlayerController = GameplayData.GetPlayerController()
    if not slua.isValid(PlayerController) or not slua.isValid(TweenManagerActorClass) then
      if FallbackCallback then
        FallbackCallback(Caller)
      end
      return
    end
    local UGameplayStatics = import("GameplayStatics")
    local uWorldActorArray = UGameplayStatics.GetAllActorsOfClass(PlayerController, TweenManagerActorClass, slua.Array(UEnums.EPropertyClass.Object, import("/Script/Engine.Actor")))
    local TweenManagerActor
    if uWorldActorArray and uWorldActorArray:Num() > 0 then
      TweenManagerActor = uWorldActorArray:Get(0)
    end
    if not TweenManagerActor then
      print(bWriteLog and string.format("GamePlayTools.PrepareTween create BP_TweenManagerActor"))
      ActorTools.SpawnActorAsync(PlayerController, TweenManagerActorClassPath, FVector.ZeroVector, FRotator.ZeroRotator, FVector.OneVector, function(uActor)
        if slua.isValid(uActor) then
          if SuccessCallback then
            SuccessCallback(Caller)
          end
        elseif FallbackCallback then
          FallbackCallback(Caller)
        end
      end)
    elseif SuccessCallback then
      SuccessCallback(Caller)
    end
  end)
end
function GamePlayTools.TweenMaterialParam(Mesh, Params, FallbackCallback)
  if not slua.isValid(Mesh) then
    if FallbackCallback then
      FallbackCallback()
    end
    return
  end
  local ParameterName = Params.ParameterName
  local From = Params.From or 0
  local To = Params.To or 1
  local Duration = Params.Duration or 1.0
  local MaterialIndex = Params.MaterialIndex or 0
  local EaseType = Params.EaseType
  local NumLoops = Params.NumLoops or 1
  local LoopType = Params.LoopType
  local Delay = Params.Delay or 0
  GamePlayTools.PrepareTween(function()
    if not slua.isValid(Mesh) then
      if FallbackCallback then
        FallbackCallback()
      end
      return
    end
    local MaterialInstance = Mesh:CreateDynamicMaterialInstance(MaterialIndex, Mesh:GetMaterial(MaterialIndex))
    if not slua.isValid(MaterialInstance) then
      if FallbackCallback then
        FallbackCallback()
      end
      return
    end
    local UTweenFloatStandardFactory = import("TweenFloatStandardFactory")
    local ETweenEaseType = import("ETweenEaseType")
    local ETweenLoopType = import("ETweenLoopType")
    UTweenFloatStandardFactory.BP_CreateTweenMaterialFloatFromTo(nil, MaterialInstance, nil, nil, ParameterName, From, To, Duration, EaseType or ETweenEaseType.Linear, NumLoops, LoopType or ETweenLoopType.Yoyo, Delay, 1, -1)
  end, function()
    if FallbackCallback then
      FallbackCallback()
    end
  end, nil)
end
function GamePlayTools.LuaGetModPath(PathSuffix, bClient)
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  if bClient == nil then
    bClient = Client and true or false
  end
  local Res, ModType, ModType2 = pcall(GameMainConfig.GetModType, bClient)
  local sModPath = string.format("GameLua.Mod.%s.%s", ModType, PathSuffix)
  local FinalPath = string.format("GameLua.Mod.BaseMod.%s", PathSuffix)
  if GamePlayTools.LuaFileExits(sModPath) then
    FinalPath = sModPath
  elseif not GamePlayTools.LuaFileExits(FinalPath) then
    local BRModPath = string.format("GameLua.Mod.BRMod.%s", PathSuffix)
    if GamePlayTools.LuaFileExits(BRModPath) then
      print(bWriteLog and string.format("GamePlayTools.LuaGetModPath fallback to BRMod: %s -> %s", FinalPath, BRModPath))
      FinalPath = BRModPath
    end
  end
  print(bWriteLog and string.format("GamePlayTools:LuaGetModPath:Retrun Path %s", FinalPath))
  return FinalPath
end
function GamePlayTools.LuaGetModPathDirectly(PathSuffix, bClient)
  local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
  if bClient == nil then
    bClient = Client and true or false
  end
  local Res, ModType, ModType2 = pcall(GameMainConfig.GetModType, bClient)
  local sModPath = string.format("GameLua.Mod.%s.%s", ModType, PathSuffix)
  print(bWriteLog and string.format("GamePlayTools:LuaGetModPath:Retrun Path %s", sModPath))
  return sModPath
end
function GamePlayTools.IsBlueHoleVersion()
  if GamePlayTools.IsEditor() then
    return false
  end
  if not Client then
    if ServerDataMgr and ServerDataMgr.SyncGameParams and ServerDataMgr.SyncGameParams.battle_region_id then
      return ServerDataMgr.SyncGameParams.battle_region_id == 0
    end
    return false
  else
    local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
    return Client.GetPublishRegion() == PublishRegionMacros.BLUEHOLE
  end
end
function GamePlayTools.GetAttachedActorByTag(ParentActor, Tag)
  local ChildActors = ParentActor:GetAttachedActors(nil)
  for _, v in pairs(ChildActors) do
    if slua.isValid(v) and v:ActorHasTag(Tag) then
      return v
    end
  end
  return nil
end
return GamePlayTools