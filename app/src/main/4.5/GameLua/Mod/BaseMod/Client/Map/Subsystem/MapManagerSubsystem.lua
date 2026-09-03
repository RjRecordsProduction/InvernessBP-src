local MapManagerSubsystem = {
  sDefaultMapDataPath = "/Game/BluePrints/UI/Map/MapDataBase_BP.MapDataBase_BP_C",
  sDefaultMiniMapUIPath = "/Game/BluePrints/UI/Map/MiniMapUI_BP.MiniMapUI_BP_C",
  sDefaultEntireMapUIPath = "/Game/BluePrints/UI/Map/EntireMapUI_BP.EntireMapUI_BP_C"
}
function MapManagerSubsystem:_PostConstruct()
  print(bWriteLog and "MapManagerSubsystem:_PostConstruct")
  self.TeammateCorlor = {
    [0] = FLinearColor(0.645833, 0.550796, 0.029071, 0.9),
    [1] = FLinearColor(0.545724, 0.144128, 0.024158, 0.9),
    [2] = FLinearColor(0.022174, 0.258183, 0.462077, 0.9),
    [3] = FLinearColor(0.104616, 0.371238, 0.028426, 0.9),
    [4] = FLinearColor(0.51, 0.08, 0.48, 1),
    [5] = FLinearColor(0.1, 0.39, 0.38, 1),
    [6] = FLinearColor(0.73, 0.13, 0.16, 1),
    [7] = FLinearColor(0.19, 0.17, 0.71, 1)
  }
  self.StandaradPointParam = {}
  self.DefaultPoint = nil
end
function MapManagerSubsystem:OnInit()
  print(bWriteLog and "MapManagerSubsystem:OnInit")
  self:CheckNeedCloseMiniMap()
end
function MapManagerSubsystem:OnRelease()
  print(bWriteLog and "MapManagerSubsystem:OnRelease")
  if UIManager.UI_Config_InGame.MiniMapWindow then
    UIManager.CloseUI(UIManager.UI_Config_InGame.MiniMapWindow)
  end
  MapManagerSubsystem.__super.OnRelease(self)
end
function MapManagerSubsystem:CheckNeedCloseMiniMap()
  if not self:CheckNeedMiniMap() then
    UIManager.CloseUI(UIManager.UI_Config_InGame.MiniMapWindow)
  end
end
function MapManagerSubsystem:IsNoRenderClient()
  local frontendUtils
  if slua_GameFrontendHUD then
    frontendUtils = slua_GameFrontendHUD:GetUtils()
  end
  if frontendUtils and frontendUtils:GetGlobalUIContainer("Default") == nil then
    return true
  end
  return false
end
function MapManagerSubsystem:GetMapDataPath(bIsMiniMap)
  local ClientGameMain = require("GameLua.GameCore.Main.ClientGameMain")
  if self:IsNoRenderClient() then
    print(bWriteLog and "MapManagerSubsystem:GetMapDataPath no Default GlobalUIContainer")
    return ""
  end
  local Path = ClientGameMain.GetUIOtherSetting("MapDataPath")
  if bIsMiniMap then
    local MiniMapDataPath = ClientGameMain.GetUIOtherSetting("MiniMapDataPath")
    if MiniMapDataPath then
      Path = MiniMapDataPath
    end
  else
    local EntireMapDataPath = ClientGameMain.GetUIOtherSetting("EntireMapDataPath")
    if EntireMapDataPath then
      Path = EntireMapDataPath
    end
  end
  if Path then
    log(bWriteLog and "map data path:" .. Path)
    return Path
  else
    return self.sDefaultMapDataPath
  end
end
function MapManagerSubsystem:GetMapUIPath(bIsMiniMap)
  local ClientGameMain = require("GameLua.GameCore.Main.ClientGameMain")
  if self:IsNoRenderClient() then
    print(bWriteLog and "MapManagerSubsystem:GetMapDataPath no Default GlobalUIContainer")
    return ""
  end
  local Path = ClientGameMain.GetUIOtherSetting("MapUIPath")
  if bIsMiniMap then
    local MiniMapUIPath = ClientGameMain.GetUIOtherSetting("MiniMapUIPath")
    if MiniMapUIPath then
      return MiniMapUIPath
    else
      return self.sDefaultMiniMapUIPath
    end
  else
    local EntireMapUIPath = ClientGameMain.GetUIOtherSetting("EntireMapUIPath")
    if EntireMapUIPath then
      return EntireMapUIPath
    else
      return self.sDefaultEntireMapUIPath
    end
  end
end
function MapManagerSubsystem:CheckNeedMiniMap()
  if self:IsNoRenderClient() then
    print(bWriteLog and "MapManagerSubsystem:CheckNeedMiniMap IsNoRenderClient")
    return false
  end
  local UGameplayStatics = import("GameplayStatics")
  local UIUtil = require("client.common.ui_util")
  local uGameState = UGameplayStatics.GetGameState(UIUtil.GetGameInstance())
  if not slua.isValid(uGameState) then
    print(bWriteLog and "MapManagerSubsystem:CheckNeedMiniMap no GameState")
    return false
  end
  if uGameState.GameModeID ~= "" and tonumber(uGameState.GameModeID) > 0 then
    return true
  else
    print(bWriteLog and "MapManagerSubsystem:CheckNeedMiniMap False")
    return false
  end
end
function MapManagerSubsystem:GetPlayerColorByIndex(index)
  if self.TeammateCorlor[index] then
    return self.TeammateCorlor[index]
  else
    return FLinearColor(1, 1, 1, 1)
  end
end
function MapManagerSubsystem:CacheStandardPointParam(StandardPoint, bForceDefault)
  if not slua.isValid(StandardPoint) then
    return
  end
  local Tags = StandardPoint.Tags
  if Tags:Num() > 0 and not bForceDefault then
    local FirTag = Tags:Get(0)
    if not self.StandaradPointParam[FirTag] then
      local ActorPos = StandardPoint:K2_GetActorLocation()
      local ActorRot = StandardPoint:K2_GetActorRotation()
      local Extent = StandardPoint.LevelBoundExtent
      local MapPath = StandardPoint.MapPath
      self.StandaradPointParam[FirTag] = {
        Loc = ActorPos,
        Rot = ActorRot,
        BoundExtent = Extent,
        Changed      }
      return self.StandaradPointParam[FirTag]
    end
  elseif not self.DefaultPoint then
    local ActorPos = StandardPoint:K2_GetActorLocation()
    local ActorRot = StandardPoint:K2_GetActorRotation()
    local Extent = StandardPoint.LevelBoundExtent
    local uGameFunctionLibrary = import("/Game/BluePrints/Core/BP_GameFunctionLibrary.BP_GameFunctionLibrary_C")
    local DefaultMapPath = uGameFunctionLibrary.GetMinimapPathbyModeID(StandardPoint)
    self.DefaultPoint = {
      Loc = ActorPos,
      Rot = ActorRot,
      BoundExtent = Extent,
      ChangedMapPath = DefaultMapPath and DefaultMapPath ~= "" and DefaultMapPath or StandardPoint.MapPath
    }
    print(bWriteLog and "MapManagerSubsystem:CacheStandardPointParam ", tostring(self.DefaultPoint))
    return self.DefaultPoint
  end
end
function MapManagerSubsystem:GetTagParam(Tag, bIgnoreModeType)
  if Tag == "" then
    self.DefaultPoint = nil
    local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
    local ChangeMapConfig = GamePlayTools.GetCurrentConfig("ChangeMapConfig")
    bIgnoreModeType = bIgnoreModeType or ChangeMapConfig and ChangeMapConfig.IgnoreCheckMode
    local USTExtraMapFunctionLibrary = import("STExtraMapFunctionLibrary")
    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
    local uGameState = GameplayData.GetGameState()
    if slua.isValid(uGameState) then
      local StandardPoint = USTExtraMapFunctionLibrary.GetMapStandardPoint(uGameState)
      if slua.isValid(StandardPoint) then
        if StandardPoint.GameModeType == uGameState.GameModeType or bIgnoreModeType then
          self:CacheStandardPointParam(StandardPoint, true)
          return self.DefaultPoint
        elseif ChangeMapConfig and ChangeMapConfig.bUseMainModCheck then
          local UIUtil = require("client.common.ui_util")
          local uGameInstance = UIUtil.GetGameInstance()
          if slua.isValid(uGameInstance) then
            local MainModeID = uGameInstance:GetMainModeID()
            if not ChangeMapConfig.CheckMainModeID or not ChangeMapConfig.CheckMainModeID[MainModeID] then
              self:CacheStandardPointParam(StandardPoint, true)
              return self.DefaultPoint
            end
          end
        end
      end
    end
    if ChangeMapConfig and ChangeMapConfig.DefaultPoint then
      return ChangeMapConfig.DefaultPoint
    end
    return nil
  else
    if self.StandaradPointParam[Tag] then
      return self.StandaradPointParam[Tag]
    end
    local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
    local ChangeMapConfig = GamePlayTools.GetCurrentConfig("ChangeMapConfig")
    if ChangeMapConfig and ChangeMapConfig.POIParam then
      local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
      local MapType = GameMainConfig.GetMapType()
      MapType = MapType or "Default"
      local ParamConfig = ChangeMapConfig.POIParam[MapType]
      local DefaultConfig = ChangeMapConfig.POIParam.Default
      if not ParamConfig and DefaultConfig then
        ParamConfig = DefaultConfig
      end
      if ParamConfig then
        local TagNum = tonumber(Tag)
        local TagConfig = ParamConfig[TagNum]
        if TagConfig then
          local ActorPos = TagConfig.Pos or FVector(0, 0, 0)
          local ActorRot = TagConfig.Rot or FRotator(0, 0, -90)
          local Extent = TagConfig.LevelBoundExtent or 806400
          local MapPath = TagConfig.MapPath or ""
          self.StandaradPointParam[Tag] = {
            Loc = ActorPos,
            Rot = ActorRot,
            BoundExtent = Extent,
            Changed          }
          return self.StandaradPointParam[Tag]
        end
      end
    end
    local StandardPoint = self:GetStandardPointByTag(Tag)
    if slua.isValid(StandardPoint) then
      self:CacheStandardPointParam(StandardPoint, false)
      return self.StandaradPointParam[Tag]
    else
      local DefaultParam = self:GetTagParam("", bIgnoreModeType)
      if DefaultParam then
        local Param = {
          Loc = DefaultParam.Loc,
          Rot = DefaultParam.Rot,
          BoundExtent = DefaultParam.BoundExtent,
          ChangedMapPath = ""
        }
        return Param
      end
    end
  end
  return nil
end
function MapManagerSubsystem:GetStandardPointByTag(Tag)
  local BP_MiniMapStandardPoint = import("/Game/BluePrints/Core/BP_MiniMapStandardPoint.BP_MiniMapStandardPoint_C")
  local uActorClass = import("/Script/Engine.Actor")
  local GameplayStatics = import("GameplayStatics")
  local EGameModeType = import("EGameModeType")
  local OutActors = slua.Array(UEnums.EPropertyClass.Object, uActorClass)
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uGameState = GameplayData.GetGameState()
  OutActors = GameplayStatics.GetAllActorsOfClass(uGameState, BP_MiniMapStandardPoint, OutActors)
  if OutActors:Num() > 0 then
    for i = 0, OutActors:Num() - 1 do
      local Actor = OutActors:Get(i)
      if Actor:ActorHasTag(Tag) then
        return Actor
      end
    end
  end
  return nil
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, MapManagerSubsystem)