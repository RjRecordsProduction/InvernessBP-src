local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local TableUtil = require("common.table_util")
local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
local HighlightShowFeature = {
  ClientRPC = {},
  LuaEventContainer = {}
}
HighlightShowFeature.ClientRPC.ClientRPC_TriggerHighlightMoment = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.UInt32,
    UEnums.EPropertyClass.UInt32,
    UEnums.EPropertyClass.UInt32
  }
}
function HighlightShowFeature:_PostConstruct()
  HighlightShowFeature.__super._PostConstruct(self)
  self.SceneAvatarListIndexMap = {
    [1] = "SceneAvatarFirst",
    [2] = "SceneAvatarSecond",
    [3] = "SceneAvatarThird"
  }
  self._PendingRPCData = nil
  self._DSSceneShowSeq = 0
  self._SceneShowQueue = {}
  self._PendingShowSnapshots = nil
  self:InitHightlightMomentConfig()
end
function HighlightShowFeature:InitHightlightMomentConfig()
  if self.HighlightMomentConfig then
    return
  end
  self.HighlightMomentConfig = GamePlayTools.GetCurrentConfig("HighlightMomentConfig")
  local Config_Vehicle = GamePlayTools.GetCurrentConfig("HighlightMomentConfig_Vehicle")
  local Config_Scene = GamePlayTools.GetCurrentConfig("HighlightMomentConfig_SceneShow")
  if Config_Vehicle then
    self.HighlightMomentConfig = TableUtil.MergeTable(self.HighlightMomentConfig, Config_Vehicle)
  end
  self.HighlightMomentConfig.SceneShowConfig = Config_Scene
end
function HighlightShowFeature:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  local RepTable = {
    {
      "SceneAvatarFirst",
      ELifetimeCondition.COND_OwnerOnly,
      import("NetAvatarSyncData")
    },
    {
      "SceneAvatarSecond",
      ELifetimeCondition.COND_OwnerOnly,
      import("NetAvatarSyncData")
    },
    {
      "SceneAvatarThird",
      ELifetimeCondition.COND_OwnerOnly,
      import("NetAvatarSyncData")
    }
  }
  if HighlightShowFeature.__super.GetLifetimeReplicatedProps then
    local BaseRepTable = HighlightShowFeature.__super.GetLifetimeReplicatedProps(self)
    table.move(BaseRepTable, 1, #BaseRepTable, #RepTable + 1, RepTable)
  end
  return RepTable
end
function HighlightShowFeature:DS_TriggerSceneShow(ParticipantPlayerKeys)
  self._DSSceneShowSeq = (self._DSSceneShowSeq or 0) + 1
  print(bWriteLog and "HighlightShowFeature:DS_TriggerSceneShow Seq:" .. tostring(self._DSSceneShowSeq))
  local SelfPlayerKey = self.Owner and self.Owner.PlayerKey or 0
  local CollectedCount = 0
  for _, PlayerKey in ipairs(ParticipantPlayerKeys) do
    if PlayerKey ~= SelfPlayerKey then
      local uPawn = Game:GetPlayerByPlayerKey(PlayerKey)
      if uPawn and slua.isValid(uPawn) then
        if self:_CollectSinglePawnAvatar(uPawn, CollectedCount) then
          CollectedCount = CollectedCount + 1
        end
      else
        print(bWriteLog and "HighlightShowFeature:DS_TriggerSceneShow invalid pawn PlayerKey:" .. tostring(PlayerKey))
      end
    end
  end
  self:ForceNetUpdate()
  print(bWriteLog and "HighlightShowFeature:DS_TriggerSceneShow CollectedCount:" .. tostring(CollectedCount) .. " Seq:" .. tostring(self._DSSceneShowSeq))
end
function HighlightShowFeature:_CollectSinglePawnAvatar(uPawn, CollectedCount)
  local uCharacterAvatarComponent = uPawn:getAvatarComponent2()
  if not (uCharacterAvatarComponent and slua.isValid(uCharacterAvatarComponent)) or CollectedCount == nil then
    print(bWriteLog and "HighlightShowFeature:_CollectSinglePawnAvatar no avatar comp")
    return false
  end
  local Index = CollectedCount + 1
  if not self.SceneAvatarListIndexMap[Index] or self[self.SceneAvatarListIndexMap[Index]] == nil then
    print(bWriteLog and "HighlightShowFeature:_CollectSinglePawnAvatar no index map Index:" .. tostring(Index))
    return false
  end
  if slua.isValid(uCharacterAvatarComponent) then
    self[self.SceneAvatarListIndexMap[Index]] = Game:CopyNetAvatarDataToLobbyPawn(uCharacterAvatarComponent, {9})
    self[self.SceneAvatarListIndexMap[Index]].UpdateFlag = self._DSSceneShowSeq
    self[self.SceneAvatarListIndexMap[Index]].Gender = uPawn:GetGender()
  end
  print(bWriteLog and "HighlightShowFeature:_CollectSinglePawnAvatar Index:" .. tostring(Index) .. " Gender:" .. tostring(uPawn:GetGender()) .. " UpdateFlag:" .. tostring(self._DSSceneShowSeq))
  return true
end
function HighlightShowFeature:GetPawnSceneAvatarByIndex(Index)
  if Index and self.SceneAvatarListIndexMap[Index] and self[self.SceneAvatarListIndexMap[Index]] then
    return self[self.SceneAvatarListIndexMap[Index]]
  end
end
function HighlightShowFeature:GetPawnSceneAvatarSnapshotByIndex(Index)
  if not Index or not self.SceneAvatarListIndexMap[Index] then
    return nil
  end
  local FieldName = self.SceneAvatarListIndexMap[Index]
  local Src = self[FieldName]
  if not Src then
    return nil
  end
  print(bWriteLog and "HighlightShowFeature:GetPawnSceneAvatarSnapshotByIndex Index:" .. tostring(Index) .. " FieldName:" .. tostring(FieldName))
  local Snapshot = import("NetAvatarSyncData")()
  Snapshot = Src
  return Snapshot
end
function HighlightShowFeature:DSStartTriggerHighlightMoment(Type, Param)
  if Client then
    return
  end
  if not self.HighlightMomentConfig then
    print(bWriteLog and "HighlightShowFeature:DSStartTriggerHighlightMoment no HighlightMomentConfig")
    return
  end
  print(bWriteLog and "HighlightShowFeature:DSStartTriggerHighlightMoment Type:" .. tostring(Type))
  local HighlightConfig = self.HighlightMomentConfig[Type]
  if HighlightConfig == nil then
    print(bWriteLog and "HighlightShowFeature:DSStartTriggerHighlightMoment no HighlightConfig Type:" .. tostring(Type))
    return
  end
  if HighlightConfig.bIsSceneShow then
    if Param == nil or Param.SceneShowID == nil then
      print(bWriteLog and "HighlightShowFeature:DSStartTriggerHighlightMoment no Param")
      return
    end
    local SceneShowDetailConfig = self.HighlightMomentConfig.SceneShowConfig and self.HighlightMomentConfig.SceneShowConfig[Param.SceneShowID] or nil
    if SceneShowDetailConfig and SceneShowDetailConfig.AllowedMap then
      local MapType = GameMainConfig.GetMapType()
      if not SceneShowDetailConfig.AllowedMap[MapType] then
        print(bWriteLog and "HighlightShowFeature:DSStartTriggerHighlightMoment map not allowed, skip scene show Type:" .. tostring(Type) .. " SceneShowID:" .. tostring(Param.SceneShowID) .. " MapType:" .. tostring(MapType))
        return
      end
    end
    local ParticipantPlayerKeys = Param and Param.ParticipantPlayerKeys or nil
    if ParticipantPlayerKeys then
      self:DS_TriggerSceneShow(ParticipantPlayerKeys)
      self:ClientRPC_TriggerHighlightMoment(Type, Param.SceneShowID, self._DSSceneShowSeq)
    else
      print(bWriteLog and "HighlightShowFeature:DSStartTriggerHighlightMoment no ParticipantPlayerKeys Type:" .. tostring(Type) .. " Param:" .. tostring(Param))
      return
    end
  else
    self:ClientRPC_TriggerHighlightMoment(Type, Param, 0)
  end
end
function HighlightShowFeature:ClientRPC_TriggerHighlightMoment(Type, Param, SceneShowSeq)
  print(bWriteLog and "HighlightShowFeature:ClientRPC_TriggerHighlightMoment Type:" .. tostring(Type) .. " Param:" .. tostring(Param) .. " Seq:" .. tostring(SceneShowSeq))
  self:InitHightlightMomentConfig()
  if not self.HighlightMomentConfig then
    print(bWriteLog and "HighlightShowFeature:DSStartTriggerHighlightMoment no HighlightMomentConfig")
    return
  end
  local HighlightConfig = self.HighlightMomentConfig[Type]
  if HighlightConfig == nil then
    print(bWriteLog and "HighlightShowFeature:ClientRPC_TriggerHighlightMoment no HighlightConfig Type:" .. tostring(Type))
    return
  end
  local SceneShowDetailConfig = HighlightConfig and HighlightConfig.bIsSceneShow and self.HighlightMomentConfig.SceneShowConfig and self.HighlightMomentConfig.SceneShowConfig[Param] or nil
  local ClientDataReadyCheckFuncName = SceneShowDetailConfig and SceneShowDetailConfig.ClientDataReadyCheckFunc
  if ClientDataReadyCheckFuncName then
    if self._PendingRPCData then
      print(bWriteLog and "HighlightShowFeature:ClientRPC_TriggerHighlightMoment drop stale pending, OldType:" .. tostring(self._PendingRPCData.Type) .. " OldSeq:" .. tostring(self._PendingRPCData.SceneShowSeq) .. " NewSeq:" .. tostring(SceneShowSeq))
      self._PendingRPCData = nil
    end
    if self:_CheckClientDataReady(ClientDataReadyCheckFuncName, SceneShowDetailConfig, SceneShowSeq) then
      print(bWriteLog and "HighlightShowFeature:ClientRPC_TriggerHighlightMoment data ready, enqueue Type:" .. tostring(Type) .. " Seq:" .. tostring(SceneShowSeq))
      local AvatarSnapshots = self:_BuildAvatarSnapshots(SceneShowDetailConfig)
      self:_EnqueueSceneShow(Type, Param, SceneShowSeq, AvatarSnapshots)
      self:_TryDispatchPendingShow()
    else
      print(bWriteLog and "HighlightShowFeature:ClientRPC_TriggerHighlightMoment data not ready, pending Type:" .. tostring(Type) .. " Seq:" .. tostring(SceneShowSeq))
      self._PendingRPCData = {
        Type = Type,
        Param = Param,
              }
    end
  else
    EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_TRIGGER_HIGHLIGHT_MOMENT, Type, Param)
  end
end
function HighlightShowFeature:_CheckClientDataReady(CheckFuncName, SceneShowDetailConfig, SceneShowSeq)
  local FullFuncName = "ClientDataReadyCheck_" .. CheckFuncName
  if type(self[FullFuncName]) == "function" then
    return self[FullFuncName](self, SceneShowDetailConfig, SceneShowSeq)
  end
  print(bWriteLog and "HighlightShowFeature:_CheckClientDataReady func not found:" .. tostring(FullFuncName))
  return true
end
function HighlightShowFeature:_TryProcessPendingRPC(FromSource)
  if not Client then
    return
  end
  if not self._PendingRPCData then
    return
  end
  local PendingData = self._PendingRPCData
  local HighlightConfig = self.HighlightMomentConfig[PendingData.Type]
  local SceneShowDetailConfig = HighlightConfig and HighlightConfig.bIsSceneShow and self.HighlightMomentConfig.SceneShowConfig and self.HighlightMomentConfig.SceneShowConfig[PendingData.Param] or nil
  local ClientDataReadyCheckFuncName = SceneShowDetailConfig and SceneShowDetailConfig.ClientDataReadyCheckFunc
  if SceneShowDetailConfig and PendingData.SceneShowSeq and PendingData.SceneShowSeq > 0 then
    local LatestSeq = self:_GetMaxAvatarUpdateFlag(SceneShowDetailConfig)
    if LatestSeq > PendingData.SceneShowSeq then
      print(bWriteLog and "HighlightShowFeature:_TryProcessPendingRPC pending RPC superseded, drop Type:" .. tostring(PendingData.Type) .. " PendingSeq:" .. tostring(PendingData.SceneShowSeq) .. " LatestSeq:" .. tostring(LatestSeq) .. " From:" .. tostring(FromSource))
      self._PendingRPCData = nil
      return
    end
  end
  if not ClientDataReadyCheckFuncName or self:_CheckClientDataReady(ClientDataReadyCheckFuncName, SceneShowDetailConfig, PendingData.SceneShowSeq) then
    print(bWriteLog and "HighlightShowFeature:_TryProcessPendingRPC pending RPC ready, enqueue Type:" .. tostring(PendingData.Type) .. " Seq:" .. tostring(PendingData.SceneShowSeq) .. " From:" .. tostring(FromSource))
    local Type = PendingData.Type
    local Param = PendingData.Param
    local SceneShowSeq = PendingData.SceneShowSeq
    self._PendingRPCData = nil
    if SceneShowDetailConfig then
      local AvatarSnapshots = self:_BuildAvatarSnapshots(SceneShowDetailConfig)
      self:_EnqueueSceneShow(Type, Param, SceneShowSeq, AvatarSnapshots)
      self:_TryDispatchPendingShow()
    else
      print(bWriteLog and "HighlightShowFeature:_TryProcessPendingRPC SceneShowDetailConfig is nil, Type:" .. tostring(PendingData.Type) .. " Seq:" .. tostring(PendingData.SceneShowSeq) .. " From:" .. tostring(FromSource))
    end
  else
    print(bWriteLog and "HighlightShowFeature:_TryProcessPendingRPC pending RPC still not ready, keep waiting Type:" .. tostring(PendingData.Type) .. " Seq:" .. tostring(PendingData.SceneShowSeq) .. " From:" .. tostring(FromSource))
  end
end
function HighlightShowFeature:_BuildAvatarSnapshots(SceneShowDetailConfig)
  local Snapshots = {}
  local OtherParticipantCount = SceneShowDetailConfig and SceneShowDetailConfig.OtherParticipantCount or 0
  if OtherParticipantCount <= 0 then
    return Snapshots
  end
  if 3 < OtherParticipantCount then
    OtherParticipantCount = 3
  end
  for Index = 1, OtherParticipantCount do
    Snapshots[Index] = self:GetPawnSceneAvatarSnapshotByIndex(Index)
  end
  return Snapshots
end
function HighlightShowFeature:_EnqueueSceneShow(Type, Param, SceneShowSeq, AvatarSnapshots)
  self._SceneShowQueue = self._SceneShowQueue or {}
  table.insert(self._SceneShowQueue, {
    Type = Type,
    Param = Param,
    SceneShowSeq = SceneShowSeq,
    AvatarSnapshots = AvatarSnapshots or {}
  })
  print(bWriteLog and "HighlightShowFeature:_EnqueueSceneShow Type:" .. tostring(Type) .. " Seq:" .. tostring(SceneShowSeq) .. " QueueLen:" .. tostring(#self._SceneShowQueue))
end
function HighlightShowFeature:IsSubsystemSceneShowIdle()
  if not Client then
    return false
  end
  if not SubsystemMgr then
    return false
  end
  local HighlightMomentSubsystem = SubsystemMgr:Get("HighlightMomentSubsystem")
  if not HighlightMomentSubsystem then
    return false
  end
  return HighlightMomentSubsystem:IsSceneShowIdle()
end
function HighlightShowFeature:_TryDispatchPendingShow()
  if not Client then
    return
  end
  local Queue = self._SceneShowQueue
  if not Queue or #Queue == 0 then
    return
  end
  if not self:IsSubsystemSceneShowIdle() then
    print(bWriteLog and "HighlightShowFeature:_TryDispatchPendingShow subsystem busy, hold queue, QueueLen:" .. tostring(#Queue))
    return
  end
  local Entry = table.remove(Queue, 1)
  self._PendingShowSnapshots = Entry.AvatarSnapshots or {}
  print(bWriteLog and "HighlightShowFeature:_TryDispatchPendingShow dispatch Type:" .. tostring(Entry.Type) .. " Seq:" .. tostring(Entry.SceneShowSeq) .. " QueueLen:" .. tostring(#Queue))
  EventSystem:postEvent(EVENTTYPE_INGAME, EVENTID_INGAME_TRIGGER_HIGHLIGHT_MOMENT, Entry.Type, Entry.Param)
end
function HighlightShowFeature:ConsumePendingShowSnapshots()
  if not Client then
    return nil
  end
  print(bWriteLog and "HighlightShowFeature:ConsumePendingShowSnapshots")
  local Snapshots = self._PendingShowSnapshots
  self._PendingShowSnapshots = nil
  return Snapshots
end
function HighlightShowFeature:CollectScreenParticlePreloadPaths(SceneShowDetailConfig)
  local PathList = {}
  local PathToIndex = {}
  if not SceneShowDetailConfig or not SceneShowDetailConfig.ScreenParticleConfig then
    return PathList, PathToIndex
  end
  for Index, EffectCfg in pairs(SceneShowDetailConfig.ScreenParticleConfig) do
    if EffectCfg and EffectCfg.AssetPath and EffectCfg.AssetPath ~= "" then
      table.insert(PathList, EffectCfg.AssetPath)
      PathToIndex[EffectCfg.AssetPath] = Index
    end
  end
  print(bWriteLog and "HighlightShowFeature:CollectScreenParticlePreloadPaths count:" .. tostring(#PathList))
  return PathList, PathToIndex
end
function HighlightShowFeature:BuildScreenParticleLoadedClassMap(PathToIndex)
  local ClassMap = {}
  if not PathToIndex then
    return ClassMap
  end
  for AssetPath, Index in pairs(PathToIndex) do
    local TAsset = slua.loadClass(AssetPath)
    if Index and TAsset and slua.isValid(TAsset) then
      ClassMap[Index] = TAsset
      print(bWriteLog and "HighlightShowFeature:BuildScreenParticleLoadedClassMap preloaded Index:" .. tostring(Index) .. " path:" .. tostring(AssetPath))
    else
      print(bWriteLog and "HighlightShowFeature:BuildScreenParticleLoadedClassMap load failed Index:" .. tostring(Index) .. " path:" .. tostring(AssetPath))
    end
  end
  return ClassMap
end
function HighlightShowFeature:OnSubsystemSceneShowIdle()
  if not Client then
    return
  end
  print(bWriteLog and "HighlightShowFeature:OnSubsystemSceneShowIdle QueueLen:" .. tostring(self._SceneShowQueue and #self._SceneShowQueue or 0))
  self:_TryDispatchPendingShow()
end
function HighlightShowFeature:_GetMaxAvatarUpdateFlag(SceneShowDetailConfig)
  local OtherParticipantCount = SceneShowDetailConfig and SceneShowDetailConfig.OtherParticipantCount or 0
  if OtherParticipantCount <= 0 then
    return 0
  end
  if 3 < OtherParticipantCount then
    OtherParticipantCount = 3
  end
  local MaxFlag = 0
  for Index = 1, OtherParticipantCount do
    local FieldName = self.SceneAvatarListIndexMap[Index]
    local AvatarData = FieldName and self[FieldName]
    local UpdateFlag = AvatarData and AvatarData.UpdateFlag or 0
    if MaxFlag < UpdateFlag then
      MaxFlag = UpdateFlag
    end
  end
  return MaxFlag
end
function HighlightShowFeature:OnRep_SceneAvatarFirst()
  print(bWriteLog and "HighlightShowFeature:OnRep_SceneAvatarFirst UpdateFlag:" .. tostring(self.SceneAvatarFirst and self.SceneAvatarFirst.UpdateFlag))
  self:_TryProcessPendingRPC("SceneAvatarFirst")
end
function HighlightShowFeature:OnRep_SceneAvatarSecond()
  print(bWriteLog and "HighlightShowFeature:OnRep_SceneAvatarSecond UpdateFlag:" .. tostring(self.SceneAvatarSecond and self.SceneAvatarSecond.UpdateFlag))
  self:_TryProcessPendingRPC("SceneAvatarSecond")
end
function HighlightShowFeature:OnRep_SceneAvatarThird()
  print(bWriteLog and "HighlightShowFeature:OnRep_SceneAvatarThird UpdateFlag:" .. tostring(self.SceneAvatarThird and self.SceneAvatarThird.UpdateFlag))
  self:_TryProcessPendingRPC("SceneAvatarThird")
end
function HighlightShowFeature:ClientDataReadyCheck_SceneShowAvatarData(SceneShowDetailConfig, SceneShowSeq)
  local OtherParticipantCount = SceneShowDetailConfig and SceneShowDetailConfig.OtherParticipantCount or 0
  if OtherParticipantCount <= 0 then
    return true
  end
  if 3 < OtherParticipantCount then
    OtherParticipantCount = 3
  end
  if not SceneShowSeq or SceneShowSeq <= 0 then
    print(bWriteLog and "HighlightShowFeature:ClientDataReadyCheck_SceneShowAvatarData invalid SceneShowSeq:" .. tostring(SceneShowSeq))
    return false
  end
  for Index = 1, OtherParticipantCount do
    local AvatarFieldName = self.SceneAvatarListIndexMap[Index]
    if not AvatarFieldName then
      print(bWriteLog and "HighlightShowFeature:ClientDataReadyCheck_SceneShowAvatarData invalid index:" .. tostring(Index))
      return false
    end
    local AvatarData = self[AvatarFieldName]
    if not (AvatarData and AvatarData.SlotSyncData) or 0 >= AvatarData.SlotSyncData:Num() then
      print(bWriteLog and "HighlightShowFeature:ClientDataReadyCheck_SceneShowAvatarData avatar not ready, Index:" .. tostring(Index) .. " field:" .. tostring(AvatarFieldName))
      return false
    end
    if AvatarData.UpdateFlag ~= SceneShowSeq then
      print(bWriteLog and "HighlightShowFeature:ClientDataReadyCheck_SceneShowAvatarData seq mismatch, Index:" .. tostring(Index) .. " field:" .. tostring(AvatarFieldName) .. " UpdateFlag:" .. tostring(AvatarData.UpdateFlag) .. " ExpectedSeq:" .. tostring(SceneShowSeq))
      return false
    end
  end
  print(bWriteLog and "HighlightShowFeature:ClientDataReadyCheck_SceneShowAvatarData data ready, OtherParticipantCount:" .. tostring(OtherParticipantCount) .. " Seq:" .. tostring(SceneShowSeq))
  return true
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
return class(CFeatureBase, nil, HighlightShowFeature)