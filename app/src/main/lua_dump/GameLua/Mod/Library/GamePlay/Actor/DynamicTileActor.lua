local UKismetSystemLibrary = import("KismetSystemLibrary")
local DynamicTileActor = {}
function DynamicTileActor:ctor()
  self.AreaID = -1
end
function DynamicTileActor:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  return {
    {
      "AreaID",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    },
    {
      "LevelPathToLoadList",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Array,
      UEnums.EPropertyClass.Str
    },
    {
      "LevelPathToLoadList_Client",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Array,
      UEnums.EPropertyClass.Str
    },
    {
      "LevelPathToLoadList_DS",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Array,
      UEnums.EPropertyClass.Str
    }
  }
end
function DynamicTileActor:ReceiveBeginPlay()
  self.bIsDedicatedServer = UKismetSystemLibrary.IsDedicatedServer(self)
  DynamicTileActor.__super.ReceiveBeginPlay(self)
  self:ForceNetUpdate()
  if self:IsPlayingCompletePlayback() or self:IsPlayingWonderfulPlayback() then
    for _, LevelPathToLoad in pairs(self.LevelPathToLoadList) do
      self:RemoveDynamicTile(LevelPathToLoad)
    end
    for _, LevelPathToLoad_DS in pairs(self.LevelPathToLoadList_DS) do
      self:RemoveDynamicTile(LevelPathToLoad_DS)
    end
    for _, LevelPathToLoad_Client in pairs(self.LevelPathToLoadList_Client) do
      self:RemoveDynamicTile(LevelPathToLoad_Client)
    end
    local GameplayStatics = import("GameplayStatics")
    GameplayStatics.FlushLevelStreaming(self)
  end
  local SpawnLoc = self:K2_GetActorLocation()
  for _, LevelPathToLoad in pairs(self.LevelPathToLoadList) do
    self:AddDynamicTile(LevelPathToLoad, math.floor(SpawnLoc.X), math.floor(SpawnLoc.Y), false)
  end
  for _, LevelPathToLoad_DS in pairs(self.LevelPathToLoadList_DS) do
    self:AddDynamicTile(LevelPathToLoad_DS, math.floor(SpawnLoc.X), math.floor(SpawnLoc.Y), not self.bIsDedicatedServer)
  end
  for _, LevelPathToLoad_Client in pairs(self.LevelPathToLoadList_Client) do
    self:AddDynamicTile(LevelPathToLoad_Client, math.floor(SpawnLoc.X), math.floor(SpawnLoc.Y), self.bIsDedicatedServer)
  end
  EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_DYNAMICTILE_CREATE, self.Object)
end
function DynamicTileActor:OnRep_AreaID()
end
function DynamicTileActor:SetLevelPathToLoadListCfg(InConfigList)
  if InConfigList then
    self.    self.LevelPathToLoadList:Clear()
    for _, sLevelPath in pairs(self.InConfigList) do
      self.LevelPathToLoadList:Add(sLevelPath)
    end
  end
end
function DynamicTileActor:SetLevelPathToLoadListClientCfg(InConfigList)
  if InConfigList then
    self.    self.LevelPathToLoadList_Client:Clear()
    for _, sLevelPath in pairs(self.InConfigList) do
      self.LevelPathToLoadList_Client:Add(sLevelPath)
    end
  end
end
function DynamicTileActor:SetLevelPathToLoadListDSCfg(InConfigList)
  if InConfigList then
    self.    self.LevelPathToLoadList_DS:Clear()
    for _, sLevelPath in pairs(self.InConfigList) do
      self.LevelPathToLoadList_DS:Add(sLevelPath)
    end
  end
end
function DynamicTileActor:LoadEditorLevel()
  local uSTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  local uPos = self:K2_GetActorLocation()
  for _, LevelPathToLoad in pairs(self.LevelPathToLoadList) do
    if uPos then
      uSTExtraBlueprintFunctionLibrary.LoadTileInstanceInWorldComposition(self.Object, LevelPathToLoad, uPos, true)
    end
  end
  for _, LevelPathToLoadDS in pairs(self.LevelPathToLoadList_DS) do
    if uPos then
      uSTExtraBlueprintFunctionLibrary.LoadTileInstanceInWorldComposition(self.Object, LevelPathToLoadDS, uPos, true)
    end
  end
  for _, LevelPathToLoadClient in pairs(self.LevelPathToLoadList_Client) do
    if uPos then
      uSTExtraBlueprintFunctionLibrary.LoadTileInstanceInWorldComposition(self.Object, LevelPathToLoadClient, uPos, true)
    end
  end
  local GameplayStatics = import("GameplayStatics")
  GameplayStatics.FlushLevelStreaming(self)
end
function DynamicTileActor:UnLoadEditorLevel()
  local uSTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  for _, LevelPathToLoad in pairs(self.LevelPathToLoadList) do
    uSTExtraBlueprintFunctionLibrary.UnLoadTileInstanceInWorldComposition(self.Object, LevelPathToLoad)
  end
  for _, LevelPathToLoadDS in pairs(self.LevelPathToLoadList_DS) do
    uSTExtraBlueprintFunctionLibrary.UnLoadTileInstanceInWorldComposition(self.Object, LevelPathToLoadDS)
  end
  for _, LevelPathToLoadClient in pairs(self.LevelPathToLoadList_Client) do
    uSTExtraBlueprintFunctionLibrary.UnLoadTileInstanceInWorldComposition(self.Object, LevelPathToLoadClient)
  end
  local GameplayStatics = import("GameplayStatics")
  GameplayStatics.FlushLevelStreaming(self)
end
function DynamicTileActor:ReceiveEndPlay(_)
  EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_DYNAMICTILE_DESTROY, self.Object)
  local Length = self.LevelPathToLoadList:Num()
  if 0 < Length then
    for i = 0, Length - 1 do
      local LevelPathToLoad = self.LevelPathToLoadList:Get(i)
      self:RemoveDynamicTile(LevelPathToLoad)
    end
  end
  for _, LevelPathToLoad in pairs(self.LevelPathToLoadList) do
    self:RemoveDynamicTile(LevelPathToLoad)
  end
  for _, LevelPathToLoad_DS in pairs(self.LevelPathToLoadList_DS) do
    self:RemoveDynamicTile(LevelPathToLoad_DS)
  end
  for _, LevelPathToLoad_Client in pairs(self.LevelPathToLoadList_Client) do
    self:RemoveDynamicTile(LevelPathToLoad_Client)
  end
  if self:IsPlayingCompletePlayback() then
    local GameplayStatics = import("GameplayStatics")
    GameplayStatics.FlushLevelStreaming(self)
  end
  DynamicTileActor.__super.ReceiveEndPlay(self, _)
end
function DynamicTileActor:AddDynamicTile(TilePackageName, PosX, PosY, bDisableStreaming)
  local uWorld = self:GetWorld()
  if not slua.isValid(uWorld) then
    return false
  end
  local uWorldComposition = uWorld.WorldComposition
  if not slua.isValid(uWorldComposition) then
    return false
  end
  local uLevelStreaming = uWorldComposition:AddDynamicTile(TilePackageName, PosX, PosY, false, bDisableStreaming)
  if slua.isValid(uLevelStreaming) and not bDisableStreaming then
    print(bWriteLog and string.format("DynamicTileActor:AddDynamicTile %s (%s, %s)", TilePackageName, PosX, PosY))
    if uLevelStreaming:IsLevelLoaded() and uLevelStreaming:IsLevelVisible() then
      self:OnLevelShown(uLevelStreaming)
    else
      self:AddControlEvent(uLevelStreaming, "OnLevelShown", function()
        self:RemoveControlEvent(uLevelStreaming, "OnLevelShown")
        self:OnLevelShown(uLevelStreaming)
      end)
    end
  end
  return uLevelStreaming
end
function DynamicTileActor:RemoveDynamicTile(TilePackageName)
  local uWorld = self:GetWorld()
  if not slua.isValid(uWorld) then
    return false
  end
  local uWorldComposition = uWorld.WorldComposition
  if not slua.isValid(uWorldComposition) then
    return false
  end
  local bSuccess = uWorldComposition:RemoveDynamicTile(TilePackageName)
  return bSuccess
end
function DynamicTileActor:GetDynamicTile(TilePackageName)
  local uWorld = self:GetWorld()
  if not slua.isValid(uWorld) then
    return nil
  end
  local uWorldComposition = uWorld.WorldComposition
  if not slua.isValid(uWorldComposition) then
    return nil
  end
  return uWorldComposition:GetDynamicTile(TilePackageName)
end
function DynamicTileActor:OnLevelShown(uLevelStreaming)
  if slua.isValid(uLevelStreaming) then
    print(bWriteLog and "DynamicTileActor:OnLevelShown:", uLevelStreaming.PackageNameToLoad)
    local uLevelScriptActor = uLevelStreaming:GetLevelScriptActor()
    if slua.isValid(uLevelScriptActor) and uLevelScriptActor.SetAreaID ~= nil then
      uLevelScriptActor:SetAreaID(self.AreaID)
    end
  end
end
function DynamicTileActor:IsPlayingWonderfulPlayback()
  if not Client then
    return false
  end
  local GameplayStatics = import("GameplayStatics")
  local uGameInstance = GameplayStatics.GetGameInstance(self)
  if not slua.isValid(uGameInstance) then
    return false
  end
  local uGameReplay = uGameInstance:GetWonderfulPlayback()
  if not slua.isValid(uGameReplay) then
    return false
  end
  return uGameReplay:IsInPlayState()
end
function DynamicTileActor:IsPlayingCompletePlayback()
  if not Client then
    return false
  end
  local GameplayStatics = import("GameplayStatics")
  local uGameInstance = GameplayStatics.GetGameInstance(self)
  if not slua.isValid(uGameInstance) then
    return false
  end
  local uGameReplay = uGameInstance:GetCompletePlayback()
  if not slua.isValid(uGameReplay) then
    return false
  end
  return uGameReplay:IsInPlayState()
end
local class = require("class")
local object = require("GameLua.Mod.BaseMod.Common.Core.ActorBase")
local CDynamicTileActor = class(object, nil, DynamicTileActor)
return CDynamicTileActor