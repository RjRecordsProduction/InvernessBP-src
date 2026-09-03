local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local UKismetMathLibrary = import("KismetMathLibrary")
local ActorTools = require("GameLua.Mod.BaseMod.Common.ActorTools")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local TableUtil = require("common.table_util")
local Config = require("GameLua.Mod.Library.GamePlay.Config.SecretArmoryConfig")
local SecretArmory = {
  DoorAnimation = {
    Duration = 1.0,
    StartYaw = 0,
    EndYaw = 120
  }
}
SecretArmory.EState = {Closed = 1, Opened = 2}
SecretArmory.OpenAkEvent = "/Game/WwiseEvent/Scene/Ambience_3D_330/Play_MetalDoor_Open_330.Play_MetalDoor_Open_330"
function SecretArmory:_PostConstruct()
  SecretArmory.__super._PostConstruct(self)
  self.TransitionableStateMachine:Init({
    States = {
      {
        Id = SecretArmory.EState.Closed,
        Name = "Closed"
      },
      {
        Id = SecretArmory.EState.Opened,
        Name = "Opened"
      }
    },
    InitStateId = SecretArmory.EState.Closed
  })
  self.TransitionableStateMachine.StateMachine:OnStateChanged(self.OnStateChanged, self)
  self.MapMarkActions = {}
  self.ScreenMarkActions = {}
end
function SecretArmory:ReceiveBeginPlay()
  SecretArmory.__super.ReceiveBeginPlay(self)
  if not Client then
    local SecretArmorySubsystem = SubsystemMgr:Get("SecretArmorySubsystem")
    if SecretArmorySubsystem then
      SecretArmorySubsystem:Register(self)
      if SecretArmorySubsystem:IsEnable() then
        self:GenerateKey()
      else
        local InteractiveComponent = self:GetInteractiveComponent()
        InteractiveComponent.bEnabled = false
        self.TransitionableStateMachine:SetState(SecretArmory.EState.Opened)
      end
    else
      local InteractiveComponent = self:GetInteractiveComponent()
      InteractiveComponent.bEnabled = false
      self.TransitionableStateMachine:SetState(SecretArmory.EState.Opened)
    end
  end
end
function SecretArmory:ReceiveEndPlay(EndPlayReason)
  self:TryRemoveNamedGameTimer("OpenAnimationTimer")
  SecretArmory.__super.ReceiveEndPlay(self, EndPlayReason)
end
function SecretArmory:MustCheckResultAfterServerClick(uCharacter, Result)
  if Result == false or not self.hasAuthority then
    return
  end
  if self.TransitionableStateMachine:GetState() == SecretArmory.EState.Opened then
    print(bWriteLog and string.format("SecretArmory:MustCheckResultAfterServerClick door has opened"))
    return
  end
  if not self:IsAllowToOpenDoor(uCharacter) then
    print(bWriteLog and string.format("SecretArmory:MustCheckResultAfterServerClick %s not allow to open door", uCharacter:ToString()))
    return
  end
  print(bWriteLog and string.format("SecretArmory:MustCheckResultAfterServerClick open"))
  Game:ConsumeItem(uCharacter, Config.KeyItemId, 1)
  self.TransitionableStateMachine:SetState(SecretArmory.EState.Opened)
  self:GenerateItems()
  EventSystem:postEvent(EVENTTYPE_LIBRARY, EVENTID_LIBRARY_ON_OPEN_SECRETARMORY, uCharacter, self)
  local DSCommonTLogSubsystem = SubsystemMgr:Get("DSCommonTLogGubsystem")
  if DSCommonTLogSubsystem then
    DSCommonTLogSubsystem:AddCommonTLog(Config.TLog.Game.OpenCount, 1, false)
  end
end
function SecretArmory:OnAllowToInteract(character, component)
  return self:IsAllowToOpenDoor(character)
end
function SecretArmory:IsAllowToOpenDoor(uCharacter)
  if not slua.isValid(uCharacter) then
    return false
  end
  local SecretArmorySubsystem = SubsystemMgr:Get("SecretArmorySubsystem")
  if SecretArmorySubsystem and not SecretArmorySubsystem:IsEnable() then
    return false
  end
  local BackpackComp = USTExtraBlueprintFunctionLibrary.GetBackpackComponentFromCharacter(uCharacter)
  if not slua.isValid(BackpackComp) then
    return false
  end
  return BackpackComp:HasItemByDefineID(self:GetSecretArmoryKeyItemDefineID())
end
function SecretArmory:GetSecretArmoryKeyItemDefineID()
  if not self.SecretArmoryKeyItemDefineId then
    local ItemDefineID = FItemDefineID(0, Config.KeyItemId)
    self.SecretArmoryKeyItemDefineId = ItemDefineID
  end
  return self.SecretArmoryKeyItemDefineId
end
function SecretArmory:OnClientShowInteractiveUI(show, component)
  component = component or self:GetInteractiveComponent()
  if show and self.TransitionableStateMachine:GetState() == SecretArmory.EState.Closed then
    self:ShowUI(component)
  else
    self:CloseUI(component)
  end
end
function SecretArmory:IsOpened()
  return self.TransitionableStateMachine:GetState() == SecretArmory.EState.Opened
end
function SecretArmory:GenerateKey()
  local ItemComp = CGameMode.ItemGenerator
  local uCenter = self:K2_GetActorLocation()
  if slua.isValid(ItemComp) then
    local num, uLocAry = ItemComp:GetSpotLocInCircle(uCenter, Config.GenerateKey.Radius, {}, 0)
    local Locs = {}
    if 0 < num then
      for _, uLoc in pairs(uLocAry) do
        if not ItemComp:CheckInCircle(uLoc, uCenter, Config.GenerateKey.CullRadius) then
          Locs[#Locs + 1] = uLoc
        end
      end
      if 0 < #Locs then
        local uLoc = Locs[math.random(1, #Locs)]
        local uActorClass = slua.loadClass(Config.BPClass.SecretArmoryKeyWrapper)
        print(bWriteLog and string.format("SecretArmory:GenerateKey FinalLocation = %s", uLoc:ToString()))
        local Key = CGameWorld:SpawnActor(uActorClass, uLoc, FRotator(0, 0, 0), nil)
        return Key
      end
    else
      print(bWriteLog and "SecretArmory:GenerateKey() no spot loc in range, self.loc=" .. uCenter.X .. "," .. uCenter.Y .. "," .. uCenter.Z)
    end
  else
    print(bWriteLog and "SecretArmory:GenerateKey() invalid ItemComp self.loc=" .. uCenter.X .. "," .. uCenter.Y .. "," .. uCenter.Z)
  end
end
function SecretArmory:GenerateItems()
  local GeneratedItems = {}
  local GenerateFromBindingConfigs = {}
  for SpotId, Config in pairs(Config.GenerateItems) do
    if Config.ItemWeights then
      local ItemId = Game:RandomByWeight(Config.ItemWeights, 1)[1]
      print(bWriteLog and string.format("SecretArmory:GenerateItems (ItemWeights) SpotId = %s, ItemId = %s", SpotId, ItemId))
      local Rotation = self:GetItemRotation(Config, ItemId)
      self:GenerateItemWrapper(ItemId, 1, Config.Location, Rotation)
      GeneratedItems[SpotId] = ItemId
    elseif Config.ItemBinding then
      GenerateFromBindingConfigs[SpotId] = Config
    end
  end
  for SpotId, Config in pairs(GenerateFromBindingConfigs) do
    local ItemBindingConfig = Config.ItemBinding
    local TargetItemId = GeneratedItems[ItemBindingConfig.TargetSpotId]
    local MappingConfig = ItemBindingConfig.Mapping[TargetItemId]
    if MappingConfig then
      local ItemId = MappingConfig.ItemId
      print(bWriteLog and string.format("SecretArmory:GenerateItems (ItemBinding) SpotId = %s, ItemId = %s", SpotId, ItemId))
      local Rotation = self:GetItemRotation(Config, ItemId)
      self:GenerateItemWrapper(ItemId, MappingConfig.Count, Config.Location, Rotation)
    end
  end
end
function SecretArmory:GetItemRotation(Config, ItemId)
  if Config.RotationOverride and Config.RotationOverride[ItemId] then
    return Config.RotationOverride[ItemId]
  else
    return Config.Rotation
  end
end
function SecretArmory:GenerateItemWrapper(ItemId, Count, RelativeLocation, RelativeRotation)
  local WrapperActorClassPath = self:GetWrapperActorClassPath(ItemId)
  if not WrapperActorClassPath then
    return
  end
  local Transform = self:GetTransform()
  local Location = UKismetMathLibrary.TransformLocation(Transform, RelativeLocation)
  local Rotation = UKismetMathLibrary.TransformRotation(Transform, RelativeRotation)
  print(bWriteLog and string.format("SecretArmory:GenerateItemWrapper ItemId = %s, Count = %s, Location = %s, Rotation = %s", ItemId, Count, Location:ToString(), Rotation:ToString()))
  self:SpawnActor(WrapperActorClassPath, Location, Rotation, FVector.OneVector, function(uActor)
    if slua.isValid(uActor) then
      uActor:SetCountOnServerAfterSpawn(Count)
    end
  end)
end
function SecretArmory:GetWrapperActorClassPath(ItemId)
  local ItemDropMgr = CGameMode.BP_ItemDropMgr
  if not slua.isValid(ItemDropMgr) then
    return
  end
  local ItemData = CDataTable.GetTableData("Item", ItemId)
  if not ItemData then
    print(bWriteLog and string.format("SecretArmory:GetWrapperActorClassPath ItemId = %s ItemData is not valid", ItemId))
    return
  end
  local ItemDefineID = FItemDefineID(ItemData.ItemType, ItemId)
  local WrapperActorClassPath = ItemDropMgr:GetWrapperActorPath(ItemDefineID)
  if not WrapperActorClassPath then
    print(bWriteLog and string.format("SecretArmory:GetWrapperActorClassPath ItemId = %s GetWrapperActorPath is not valid", ItemId))
    return
  end
  if string.sub(WrapperActorClassPath, -2) == "_C" then
    return string.sub(WrapperActorClassPath, 1, -3)
  end
end
function SecretArmory:SpawnActor(WrapperActorClassPath, Location, Rotation, Scale, Callback)
  local SpawnStrategy = self:GetSpawnStrategy()
  SpawnStrategy(self, WrapperActorClassPath, Location, Rotation, Scale, Callback)
end
function SecretArmory:GetSpawnStrategy()
  return self.GridSpawnActor
end
function SecretArmory:SyncSpawnActor(WrapperActorClassPath, Location, Rotation, Scale, Callback)
  local uActor = ActorTools.SpawnActor(CGameMode, WrapperActorClassPath, Location, Rotation, Scale)
  if slua.isValid(uActor) and Callback then
    Callback(uActor)
  end
end
function SecretArmory:GridSpawnActor(WrapperActorClassPath, Location, Rotation, Scale, Callback)
  local uActorGridGenerator = Game:GetActorGridGenerator()
  local FNormalGridSpawnData = import("NormalGridSpawnData")
  local SpawnData = FNormalGridSpawnData()
  SpawnData.SpawnLoc = Location
  SpawnData.SpawnRot = Rotation
  SpawnData.ClassPath = WrapperActorClassPath .. "_C"
  uActorGridGenerator:RegisterNormalSpawnDataWithCallBack(SpawnData, Callback)
end
function SecretArmory:OnStateChanged(StateId)
  if StateId ~= SecretArmory.EState.Opened then
    return
  end
  if not slua.isValid(self.Door) then
    return
  end
  self.OpenAnimationStartTime = GamePlayTools.GetServerWorldTimeSeconds()
  print(bWriteLog and string.format("SecretArmory:OnStateChanged start %s", self.OpenAnimationStartTime))
  local TargetRotator = FRotator(0.0, self.DoorAnimation.EndYaw, 0.0)
  if not Client or self.OpenAnimationStartTime > self.TransitionableStateMachine.StateChangedTime + self.DoorAnimation.Duration then
    self.Door:K2_SetRelativeRotation(TargetRotator, false, nil, false)
  else
    local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
    GamePlayTools.PrepareTween(function()
      local TweenRotatorStandardFactory = import("TweenRotatorStandardFactory")
      local ETweenEaseType = import("ETweenEaseType")
      local ETweenLoopType = import("ETweenLoopType")
      TweenRotatorStandardFactory.BP_CreateTweenRotateSceneComponentBy(nil, self.Door, nil, nil, TargetRotator, self.DoorAnimation.Duration, ETweenEaseType.Linear, false, false, 1, ETweenLoopType.Yoyo, 0, 1, -1, true)
    end, function()
      self.Door:K2_SetRelativeRotation(TargetRotator, false, nil, false)
    end, self)
    local audio_util = require("client.common.audio_util")
    audio_util.PlayAudioByActorAsync(SecretArmory.OpenAkEvent, self.Object, nil, true)
  end
end
local class = require("class")
local CInteractiveActorBase = require("GameLua.Mod.BaseMod.GamePlay.Actor.AInteractiveActorBase")
local CSecretArmory = class(CInteractiveActorBase, nil, SecretArmory)
return require("combine_class").DeclareFeature(CSecretArmory, {
  {
    TransitionableStateMachine = "GameLua.Mod.BaseMod.GamePlay.Feature.Common.TransitionableStateMachineFeature"
  }
}, "SecretArmory")