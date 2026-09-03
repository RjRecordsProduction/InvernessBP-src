local LobbyModelBaseEntity = {}
local attachModelVector = FVector(20, 0, 0)
function LobbyModelBaseEntity:ctor(_, Config, OwnerActor)
  self.  self.  self.AsyncLoadHandle = nil
  self._bCastShadow = nil
end
function LobbyModelBaseEntity:_PrepareShowModel(ItemID, BPID)
  log(bWriteLog and "LobbyModelBaseEntity ShowModel" .. tostring(ItemID))
  self.  self.  local SpawnTransform = self:GetSpawnTransform()
  local LobbyModelPool = require("client.slua.logic.show_actor.common.LobbyModelPool")
  self.ModelActor = LobbyModelPool.GetModel(self.Config.ShowType)
  self.ModelActor:K2_SetActorTransform(SpawnTransform, false, nil, false)
  self.ModelActor.ShowType = self.Config.ShowType
  self.OwnerActor.SubActor = self.ModelActor
  if AvatarData.OpenTimeTracer then
    local TimeUtil = require("client.common.time_util")
    self.StartTime = TimeUtil.GetMicroseconds()
  end
  local ErrorMessageHandler = function(msg)
    local string = " ItemID: " .. tostring(ItemID) .. " BPID: " .. tostring(BPID)
    local utility = require("common.utility")
    utility.ErrorMessageHandlerExtra(msg, nil, string)
  end
  xpcall(self.RegistAsyncEvent, ErrorMessageHandler, self)
  xpcall(self.OnShowModel, ErrorMessageHandler, self, ItemID, BPID)
  return ErrorMessageHandler
end
function LobbyModelBaseEntity:ShowModel(ItemID, BPID)
  local ErrorMessageHandler = self:_PrepareShowModel(ItemID, BPID)
  xpcall(self.ChangeAvatar, ErrorMessageHandler, self, ItemID, BPID)
end
function LobbyModelBaseEntity:ShowModelWithResolve(ItemID, BPID, OnComplete)
  log(bWriteLog and "LobbyModelBaseEntity ShowModelWithResolve ItemID" .. tostring(ItemID) .. " BPID " .. tostring(BPID))
  local ErrorMessageHandler = self:_PrepareShowModel(ItemID, BPID)
  self:_ResolveAndChangeAvatar(ItemID, BPID, ErrorMessageHandler, OnComplete)
end
function LobbyModelBaseEntity:OnDownLoadFinish(ItemID, BPID)
  log(bWriteLog and "LobbyModelBaseEntity OnDownLoadFinish ItemID" .. tostring(ItemID) .. " BPID " .. tostring(BPID))
  if ItemID ~= self.ItemID then
    log(bWriteLog and "LobbyModelBaseEntity OnDownLoadFinish self.ItemID" .. tostring(self.ItemID) .. " BPID " .. tostring(self.BPID))
    return
  end
  local ErrorMessageHandler = function(msg)
    local string = " ItemID: " .. tostring(ItemID) .. " BPID: " .. tostring(BPID)
    local utility = require("common.utility")
    utility.ErrorMessageHandlerExtra(msg, nil, string)
  end
  xpcall(self.OnShowModel, ErrorMessageHandler, self, ItemID, BPID)
  self:_ResolveAndChangeAvatar(ItemID, BPID, ErrorMessageHandler)
end
function LobbyModelBaseEntity:_ResolveAndChangeAvatar(ItemID, BPID, ErrorMessageHandler, OnComplete)
  log(bWriteLog and "LobbyModelBaseEntity ResolveAndChangeAvatar ItemID" .. tostring(ItemID) .. " BPID " .. tostring(BPID))
  local HandleClassArray = self:OnResolveItemHandle(ItemID, BPID)
  if ItemID ~= self.ItemID then
    return
  end
  if not HandleClassArray or next(HandleClassArray) == nil then
    log(bWriteLog and "LobbyModelBaseEntity ResolveAndChangeAvatar empty handle list, go sync")
    xpcall(self.ChangeAvatar, ErrorMessageHandler, self, ItemID, BPID)
    if OnComplete then
      OnComplete()
    end
    return
  end
  local OnAsyncLoadComplete = function()
    log(bWriteLog and "LobbyModelBaseEntity ResolveAndChangeAvatar async complete ItemID" .. tostring(ItemID))
    if ItemID ~= self.ItemID then
      return
    end
    self.AsyncLoadHandle = nil
    if not slua.isValid(self.ModelActor) then
      log(bWriteLog and "LobbyModelBaseEntity ResolveAndChangeAvatar ModelActor is not Valid" .. tostring(ItemID) .. " BPID " .. tostring(BPID))
      return
    end
    xpcall(self.ChangeAvatar, ErrorMessageHandler, self, ItemID, BPID)
    if OnComplete then
      OnComplete()
    end
  end
  self:RequestCancelAsyncLoad()
  self.AsyncLoadHandle = self:AsyncLoadAssetArray(HandleClassArray, OnAsyncLoadComplete)
  log(bWriteLog and "LobbyModelBaseEntity ResolveAndChangeAvatar async start handle " .. tostring(self.AsyncLoadHandle))
end
function LobbyModelBaseEntity:RegistAsyncEvent()
end
function LobbyModelBaseEntity:OnShowModel()
end
function LobbyModelBaseEntity:OnResolveItemHandle(ItemID, BPID)
  return nil
end
function LobbyModelBaseEntity:ChangeAvatar()
end
function LobbyModelBaseEntity:OnDestroy()
  self._bCastShadow = nil
  self:RequestCancelAsyncLoad()
end
function LobbyModelBaseEntity:RequestCancelAsyncLoad()
  local TargetHandle = self.AsyncLoadHandle
  if TargetHandle then
    log(bWriteLog and "LobbyModelBaseEntity RequestCancelAsyncLoad handle " .. tostring(TargetHandle))
    self:CancelAsyncLoad(TargetHandle)
  end
  self.AsyncLoadHandle = nil
end
function LobbyModelBaseEntity:OnAsyncReady()
  if not slua.isValid(self.OwnerActor) or not slua.isValid(self.ModelActor) then
    log(bWriteLog and "LobbyModelBaseEntity OnAsyncReady Actor is not Valid")
    return
  end
  if AvatarData.OpenTimeTracer then
    local UKismetSystemLibrary = import("KismetSystemLibrary")
    local TimeUtil = require("client.common.time_util")
    local EndTime = TimeUtil.GetMicroseconds()
    log(bWriteLog and string.format("TimeTracer [Avatar][LobbyModel][LobbyModelBaseEntity.OnAsyncReady] ActorName: %s bSync=false Pool=false totalTime: [%.3fms]", UKismetSystemLibrary.GetObjectName(self.ModelActor.Object), (EndTime - self.StartTime) / 1000))
  end
  self.OwnerActor:OnSubActorAsyncReady()
  local utility = require("common.utility")
  xpcall(self.OnAsyncFinish, utility.ErrorMessageHandler, self)
  EventSystem:postEvent(EVENTTYPE_LOBBY_MODEL, EVENTID_LOBBY_MODEL_ON_ASYNC_READY, self.OwnerActor, self.ItemID)
end
function LobbyModelBaseEntity:OnAsyncFinish()
  if self._bCastShadow ~= nil then
    self:SetCastShadow(self._bCastShadow)
  end
end
function LobbyModelBaseEntity:GetSpawnTransform()
  return self.OwnerActor.spawnTransform
end
function LobbyModelBaseEntity:GetClass(BPName, BPID, isLobby, isLowDevice)
  local model_util = require("client.common.model_util")
  local BPHandleClass = model_util.GetClass(BPName, BPID, isLobby, isLowDevice)
  return BPHandleClass
end
function LobbyModelBaseEntity:GetBaseItemHBClass(BPTableName, MapTableName)
  self.OwnerActor.TmpItemID = self.OwnerActor.CurrentItemID
  local MapCfg = CDataTable.GetTableData(MapTableName, self.OwnerActor.CurrentItemID)
  local RetWeaponID = 0
  if MapCfg then
    RetWeaponID = MapCfg.WeaponID
    self.OwnerActor.TmpItemID = MapCfg.WeaponID
  end
  local ItemCfg = CDataTable.GetTableData("Item", self.OwnerActor.TmpItemID)
  if not ItemCfg then
    return
  end
  local model_util = require("client.common.model_util")
  local HandleClass = model_util.GetClass(BPTableName, ItemCfg.BPID, true, false)
  if model_util.IsChildOfBattleItemHandleBase(HandleClass) then
    return HandleClass, true, RetWeaponID
  else
    return HandleClass, false, RetWeaponID
  end
end
function LobbyModelBaseEntity:IsBattleItemHandleExist(ItemDefineID, UseCache, Lobby, ForceLobby)
  local UBackpackUtils = import("BackpackUtils")
  return UBackpackUtils.IsBattleItemHandleExist(ItemDefineID, UseCache, Lobby, ForceLobby)
end
function LobbyModelBaseEntity:CreateBattleItemHandle(ItemDefineID, Outer, bLobby)
  local UBackpackUtils = import("BackpackUtils")
  return UBackpackUtils.CreateBattleItemHandle(ItemDefineID, Outer, bLobby)
end
function LobbyModelBaseEntity:MakeItemDefineID(Type, TypeSpecificID)
  return FItemDefineID(Type, TypeSpecificID)
end
function LobbyModelBaseEntity:ArrayFind(Input)
  return self.OwnerActor:ArrayFind(Input)
end
function LobbyModelBaseEntity:MakeShowTypeCanRotateBack()
end
function LobbyModelBaseEntity:ModelSimulatePhysics()
end
function LobbyModelBaseEntity:GetComponentPosition(SlotID, asyncCallback)
end
function LobbyModelBaseEntity:GetSocketTransform(showType, socketName, asyncCallback)
end
function LobbyModelBaseEntity:SetWeaponPendantSocketType(type)
end
function LobbyModelBaseEntity:SetHolderBack()
end
function LobbyModelBaseEntity:SetCastShadow(bCastShadow)
  log(bWriteLog and "LobbyModelBaseEntity:SetCastShadow >>> bCastShadow = " .. tostring(bCastShadow))
end
function LobbyModelBaseEntity:PutonEquipmentByResid(resId)
end
function LobbyModelBaseEntity:PutoffEquipmentByResid(resId)
end
function LobbyModelBaseEntity:AttachModelCenter(cameraId)
  local LobbyCameraCfg = CDataTable.GetTableData("LobbyCameraInfo", cameraId)
  if not LobbyCameraCfg then
    return
  end
  local kismet_string_library = require("common.kismet_string_library")
  local Array = kismet_string_library.ParseIntoArray(LobbyCameraCfg.AvatarPosition, ";", true)
  self:K2_SetActorLocation(FVector(Array[1], Array[2], Array[3]), false, nil, false)
  self.OwnerActor:K2_SetActorRelativeLocation(attachModelVector, false, nil, false)
end
function LobbyModelBaseEntity:AttachToAttachPoint()
end
function LobbyModelBaseEntity:_ResetAttachPointRotate()
  if not self.OwnerActor then
    return
  end
  local AttachPoint = self.OwnerActor:GetAttachPoint()
  local targetYaw = 112.973846
  if self.OwnerActor.ExtraTable and self.OwnerActor.ExtraTable.VehicleYawRotate then
    targetYaw = self.OwnerActor.ExtraTable.VehicleYawRotate
  end
  if slua.isValid(AttachPoint) then
    AttachPoint:K2_SetActorRotation(FRotator(0, targetYaw, 0), false)
  end
end
function LobbyModelBaseEntity:RefreshExtraTableDataShow()
end
function LobbyModelBaseEntity:SetModelRelativeLocationRotationScale(uPos, uRot, uScale)
  if not slua.isValid(self.ModelActor) then
    return
  end
  if uPos then
    self.ModelActor:K2_SetActorRelativeLocation(uPos, false, nil, false)
  end
  if uRot then
    self.ModelActor:K2_SetActorRelativeRotation(uRot, false, nil, false)
  end
  if uScale then
    self.ModelActor:SetActorRelativeScale3D(uScale)
  end
end
function LobbyModelBaseEntity:RefreshTextureMipmapImmediately(MeshComp)
  if not slua.isValid(MeshComp) then
    return
  end
  local SkinnedMeshComponentClass = import("SkinnedMeshComponent")
  local StaticMeshComponentClass = import("StaticMeshComponent")
  if Game:IsClassOf(MeshComp, SkinnedMeshComponentClass) and slua.isValid(MeshComp.SkeletalMesh) then
    local UKismetSystemLibrary = import("KismetSystemLibrary")
    log(bWriteLog and "RefreshTextureMipmapImmediately: MeshComp Name = " .. UKismetSystemLibrary.GetObjectName(MeshComp.SkeletalMesh))
  elseif Game:IsClassOf(MeshComp, StaticMeshComponentClass) and slua.isValid(MeshComp.StaticMesh) then
    local UKismetSystemLibrary = import("KismetSystemLibrary")
    log(bWriteLog and "RefreshTextureMipmapImmediately: MeshComp Name = " .. UKismetSystemLibrary.GetObjectName(MeshComp.StaticMesh))
  else
    return
  end
  local Materials = MeshComp:GetMaterials()
  for _, Material in pairs(Materials) do
    if slua.isValid(Material) and Material.RefreshTextureMipmapImmediately then
      Material:RefreshTextureMipmapImmediately()
    end
  end
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
local CLobbyModelBaseEntity = class(CDelegateContainer, nil, LobbyModelBaseEntity)
return CLobbyModelBaseEntity