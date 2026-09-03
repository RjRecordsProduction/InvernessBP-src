local LobbyModelShowActor = {backTime = 2.0}
local DownLoad3DUIPath = "/Game/Arts_PlayerBluePrints/Weapon_Show/ModelDownload_3DUIActorBP.ModelDownload_3DUIActorBP_C"
local PufferSwitch = require("client.slua.logic.download.puffer_switch")
local PufferConst = require("client.slua.logic.download.puffer_const")
local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
local LobbyShowActorConfig = require("client.slua.logic.show_actor.common.LobbyShowActorConfig")
local Lerp = function(A, B, V)
  return A + V * (B - A)
end
function LobbyModelShowActor:ShowModelByResID(ResID, ExtraTable)
  log(bWriteLog and "NewLobbyModelShowActor:ShowModelByResID ResID" .. tostring(ResID))
  log_tree("LobbyModelShowActor:ShowModelByResID ExtraTable", ExtraTable)
  if self:IsSameData(ResID, ExtraTable) then
    log(bWriteLog and "LobbyModelShowActor:ShowModelByResID Is SameData")
    if slua.isValid(self.Download3DUIActor) then
      log(bWriteLog and "LobbyModelShowActor:ShowModelByResID Recache Transform while downloading if samedata")
      self:CacheTransform()
    end
    return
  end
  self.ExtraTable = ExtraTable or {}
  self.spawnTransform = self:MakeSpawnTransform(self.ExtraTable.ActorLocation, self.ExtraTable.ActorRotation, self.ExtraTable.ActorScale)
  self.CurrentItemID = ResID
  local BPID, ItemType, ItemSubType = self:GetBPID(ResID)
  self:UpdateShowType(ResID, ItemType, ItemSubType)
  self:TryShowModel(ResID, BPID)
end
function LobbyModelShowActor:Destroy()
  local LobbyModelShowActorPool = require("client.slua.logic.show_actor.common.LobbyModelShowActorPool")
  LobbyModelShowActorPool.ReleaseModel(self.Object)
end
function LobbyModelShowActor:ctor(selfType)
  log(bWriteLog and "LobbyModelShowActor:ctor")
  self:Init()
end
function LobbyModelShowActor:ReceiveBeginPlay()
  log(bWriteLog and "LobbyModelShowActor:ReceiveBeginPlay")
  self:AddControlEvent(self.Capsule, "OnInputTouchBegin", self.OnInputCapsuleTouchBegin, self)
  self:AddControlEvent(self.Capsule, "OnInputTouchEnd", self.OnInputCapsuleTouchEnd, self)
end
function LobbyModelShowActor:OnRespawn()
  log(bWriteLog and "LobbyModelShowActor:OnRespawn")
  self:Init()
end
function LobbyModelShowActor:Init()
  local ETouchIndex = import("ETouchIndex")
  self.fingerIndex = ETouchIndex.Touch1
  self.bPress = false
  self.LocationX = 0
  self.bCanAutoRotateZ = false
  self.zRotateSpeed = 1
  self.LocationY = 0
  self.isAsyncLoading = false
  self.nextShowActor = nil
  self.RotateBackZ = false
  self.EnableInput_1 = true
  self.ShowActorDataArray = {}
  self.CanRotate = false
  self.xRotateSpeed = 24
  self.CurrentItemID = 0
  self.YRotateMax = 360
  self.YRotateMin = -360
  self.XRotateMax = 360
  self.XRotateMin = -360
  self.DisableRotate = 0
  self.ShowType = 0
  self.CanRotateBack = false
  self.alreadyRotateY = false
  self.alreadyRotate = false
  self.originY = 0
  self.originX = 0
  self.yDisinteractRatio = 0
  self.yIntensity = 0
  self.disinteractDis = 0
  self.curBackTime = 0
  self.backTime = 2
  self.canAutoRotateX = false
  self.spawnTransform = nil
  self.ExtraTable = {}
  self._SubOperator = nil
  self.SubActor = nil
  self.Download3DUIActor = nil
  self.bRegistEvent = nil
  self.NeedDownloadBaseItem = nil
  self.cachedLocation = nil
  self.cachedRotation = nil
  self.cachedScale3D = nil
end
function LobbyModelShowActor:ReceiveEndPlay(EndPlayReason)
  log(bWriteLog and "LobbyModelShowActor:ReceiveEndPlay")
  self:DestroyAllContent()
  LobbyModelShowActor.__super.ReceiveEndPlay(self, EndPlayReason)
end
function LobbyModelShowActor:OnRecycle()
  log(bWriteLog and "LobbyModelShowActor:OnRecycle")
  self:SetActorScale3D(FVector(1.0, 1.0, 1.0))
  self:K2_SetActorRotation(FRotator(0, 0, 0), false)
  self:DestroyAllContent()
end
function LobbyModelShowActor:SetRotateBack(bCanRotateBack)
  self.CanRotateBack = bCanRotateBack
end
function LobbyModelShowActor:SetRotateBackTime(RotateBackTime)
  self.backTime = RotateBackTime / 100
end
function LobbyModelShowActor:SetAutoRotate(CanAutoRotateZ)
  self.bend
function LobbyModelShowActor:SetAutoRotateSpeed(ZSpeed)
  self.zRotateSpeed = ZSpeed / 100
end
function LobbyModelShowActor:SetCanTouchRotate(canRotate)
  self.CanRotate = canRotate
end
function LobbyModelShowActor:SetDisinteractDis(disinteractDis)
  self.disinteractDis = disinteractDis / 100
end
function LobbyModelShowActor:SetYdisRatio(YdisRatio)
  self.yDisinteractRatio = YdisRatio / 100
end
function LobbyModelShowActor:SetYintensity(Yintensity)
  self.yIntensity = Yintensity / 100
end
function LobbyModelShowActor:ShowModel(ItemID, BPID)
  log(bWriteLog and "NewLobbyModelShowActor:ShowModel ItemID" .. tostring(ItemID))
  self:UpdateCapsuleSize(50, 50)
  self._SubOperator:ShowModel(ItemID, BPID)
  if not slua.isValid(self.SubActor) then
    log_error("LobbyModelShowActor:ShowModel SubActor is not Valid , itemId" .. tostring(ItemID))
  end
  local EAttachmentRule = import("EAttachmentRule")
  self.SubActor:K2_AttachToComponent(self.Scene, "None", EAttachmentRule.KeepRelative, EAttachmentRule.KeepRelative, EAttachmentRule.KeepRelative, true)
end
function LobbyModelShowActor:UpdateCapsuleSize(halfHeight, radius)
  self.Capsule:SetCapsuleHalfHeight(halfHeight, true)
  self.Capsule:SetCapsuleRadius(radius, true)
end
function LobbyModelShowActor:IsSameData(ResID, ExtraTable)
  local TableUtil = require("common.table_util")
  if ResID == self.CurrentItemID and TableUtil.IsDataEqual(ExtraTable, self.ExtraTable) then
    return true
  end
  return false
end
function LobbyModelShowActor:_CreatOperator()
  local ModelFactory = require("client.slua.logic.show_actor.common.ModelFactory")
  local Entity = ModelFactory.GetEntity(self.ShowType, self.Object)
  local EntityLoader = require("client.slua.logic.show_actor.EntityLoader.EntityLoader")
  local loaderType = self.ExtraTable and self.ExtraTable.entity_loader_type or EntityLoader.Type.Async
  self._SubOperator = EntityLoader.Create(Entity, loaderType)
end
function LobbyModelShowActor:ArrayFind(string)
  if not self.ExtraTable then
    return false
  end
  return self.ExtraTable[string]
end
function LobbyModelShowActor:MakeSpawnTransform(Location, Rotation, ActorScale)
  log(bWriteLog and "NewLobbyModelShowActor:MakeSpawnTransform")
  local UKismetMathLibrary = import("KismetMathLibrary")
  return UKismetMathLibrary.MakeTransform(Location or FVector(0, 0, 0), Rotation or FRotator(0, 0, 0), ActorScale or FVector(1, 1, 1))
end
function LobbyModelShowActor:GetCurrentItemId()
  return self.CurrentItemID
end
function LobbyModelShowActor:GetBPID(ResId)
  local itemCfg = CDataTable.GetTableData("Item", ResId)
  if not itemCfg then
    log(bWriteLog and "modelshowactor GetBPID Error Not found Item id" .. tostring(ResId))
    return
  end
  return itemCfg.BPID, itemCfg.ItemType, itemCfg.ItemSubType
end
function LobbyModelShowActor:GetItemSubType(ResId)
  local itemCfg = CDataTable.GetTableData("Item", ResId)
  if not itemCfg then
    log(bWriteLog and "modelshowactor GetItemSubType Error Not found Item id" .. tostring(ResId))
    return
  end
  return itemCfg.ItemSubType
end
function LobbyModelShowActor:GetShowTypeByItemType(resId, ItemType, ItemSubType)
  local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
  if ModelDisplayTypeHelper.IsCar(ItemType) then
    if ModelDisplayTypeHelper.IsTank(ItemType, ItemSubType) then
      return LobbyShowActorConfig.Type.Tank
    elseif ModelDisplayTypeHelper.IsMecha(ItemType, ItemSubType) then
      return LobbyShowActorConfig.Type.Mecha
    elseif ModelDisplayTypeHelper.IsMTLB(ItemType, ItemSubType) then
      return LobbyShowActorConfig.Type.MTLB
    elseif self:ArrayFind("is_refit_vehicle") then
      return LobbyShowActorConfig.Type.RefitVehicle
    else
      return LobbyShowActorConfig.Type.Vehicle
    end
  elseif ModelDisplayTypeHelper.IsPlaneType(ItemType) then
    return LobbyShowActorConfig.Type.Plane
  elseif ModelDisplayTypeHelper.Is3DModelType(resId) then
    return LobbyShowActorConfig.Type.Common3DModel
  elseif ModelDisplayTypeHelper.IsGrenade(ItemType, ItemSubType) or ModelDisplayTypeHelper.IsBomb(ItemType, ItemSubType) then
    return LobbyShowActorConfig.Type.Grenade
  elseif ModelDisplayTypeHelper.IsBagWidget(ItemType, ItemSubType) then
    return LobbyShowActorConfig.Type.BagWidget
  elseif ModelDisplayTypeHelper.IsParachute(ItemType, ItemSubType) then
    return LobbyShowActorConfig.Type.Parachute
  elseif ModelDisplayTypeHelper._IsIcon3D(ItemType, ItemSubType, resId) then
    return LobbyShowActorConfig.Type.Icon3D
  elseif ModelDisplayTypeHelper.IsNoLevelBag(ItemType, ItemSubType) then
    return LobbyShowActorConfig.Type.Bag
  elseif ModelDisplayTypeHelper.IsWingMan(ItemType) then
    return LobbyShowActorConfig.Type.Wingman
  elseif ModelDisplayTypeHelper.IsMiniTv(ItemType) then
    if LobbySystem.CheckLobbyMenuOpen(BP_ENUM_LOBBY_MINI_TV_REV, false) then
      return LobbyShowActorConfig.Type.MiniTVNew
    else
      return LobbyShowActorConfig.Type.MiniTv
    end
  elseif ModelDisplayTypeHelper.IsHolography(ItemType) then
    return LobbyShowActorConfig.Type.Holography
  elseif ModelDisplayTypeHelper.IsStatue(ItemType) then
    return LobbyShowActorConfig.Type.Statues
  elseif ModelDisplayTypeHelper.IsHome3DAsset(ItemType, ItemSubType) then
    return LobbyShowActorConfig.Type.Home3DAsset
  elseif ModelDisplayTypeHelper.Is3DEffect(ItemType, ItemSubType) then
    return LobbyShowActorConfig.Type.Common3DModel
  elseif ModelDisplayTypeHelper.IsTwoWeaponModel(resId) then
    return LobbyShowActorConfig.Type.TwoWeapon
  else
    return LobbyShowActorConfig.Type.Weapon
  end
end
function LobbyModelShowActor:SetDIYDecalNumPerFrame(isSync, num)
  if not self.SubActor then
    return
  end
  self.SubActor.WeaponAvatarComponent:EnableSyncLoadDIYDecal(isSync, num)
end
function LobbyModelShowActor:OnInputCapsuleTouchBegin(FingerIndex, TouchedComponent)
  log(bWriteLog and "NewLobbyModelShowActor OnInputCapsuleTouchBegin FingerIndex" .. tostring(FingerIndex))
  self.fingerIndex = FingerIndex
  local playerController = slua_GameFrontendHUD:GetPlayerController()
  local LocationX, LocationY, isCurrentlyPressed = playerController:GetInputTouchState(self.fingerIndex, nil, nil, nil)
  self.  self.  self.originX = LocationX
  self.originY = LocationY
  self.bPress = true
  self:MakeShowTypeCanRotateBack()
  self.curBackTime = self.backTime
  self.alreadyRotate = false
  self.alreadyRotateY = false
  self:ModelSimulatePhysics()
end
function LobbyModelShowActor:OnInputCapsuleTouchEnd(FingerIndex, TouchedComponent)
  log(bWriteLog and "NewLobbyModelShowActor OnInputCapsuleTouchEnd FingerIndex" .. tostring(FingerIndex))
  self.bPress = false
  self.curBackTime = 0.0
end
function LobbyModelShowActor:MakeShowTypeCanRotateBack()
  if not self._SubOperator then
    return
  end
  self._SubOperator:MakeShowTypeCanRotateBack()
end
function LobbyModelShowActor:ModelSimulatePhysics()
  if not self._SubOperator then
    return
  end
  self._SubOperator:ModelSimulatePhysics()
end
function LobbyModelShowActor:ReceiveTick(delta)
  if not self:IsModelValid() then
    return
  end
  self:ZAutoRotate()
  self:XAutoRotate()
  self:RotateBack(delta)
  self:TryRotate()
end
function LobbyModelShowActor:IsModelValid()
  return slua.isValid(self.SubActor)
end
function LobbyModelShowActor:ZAutoRotate()
  if not self.bCanAutoRotateZ or self.bPress then
    return
  end
  local curRotator = self.DefaultSceneRoot:K2_GetComponentRotation()
  local ZRotater = FRotator(0, self.zRotateSpeed, 0)
  local UKismetMathLibrary = import("KismetMathLibrary")
  local Rotator = UKismetMathLibrary.ComposeRotators(curRotator, ZRotater)
  self.DefaultSceneRoot:K2_SetWorldRotation(Rotator, false, nil, false)
end
function LobbyModelShowActor:XAutoRotate()
  if not self.canAutoRotateX or self.bPress then
    return
  end
  local curRotator = self.DefaultSceneRoot:K2_GetComponentRotation()
  local ZRotater = FRotator(0, 0, self.xRotateSpeed)
  local UKismetMathLibrary = import("KismetMathLibrary")
  local Rotator = UKismetMathLibrary.ComposeRotators(curRotator, ZRotater)
  self.DefaultSceneRoot:K2_SetWorldRotation(Rotator, false, nil, false)
end
function LobbyModelShowActor:RotateBack(delta)
  if not self.CanRotateBack or self.curBackTime >= self.backTime then
    return
  end
  self.curBackTime = self.curBackTime + delta
  if self.backTime == 0 then
    return
  end
  local localAlpha = self.curBackTime / self.backTime
  local curRotator = self.DefaultSceneRoot:K2_GetComponentRotation()
  local PitchLerp = Lerp(curRotator.Pitch, 0, localAlpha)
  local RollLerp = Lerp(curRotator.Roll, 0, localAlpha)
  local TargetRotator = FRotator(0, 0, 0)
  if self.RotateBackZ then
    if 0 < curRotator.Yaw and math.abs(curRotator.Yaw) % 180 > 90 then
      TargetRotator = FRotator(PitchLerp, Lerp(curRotator.Yaw, 180, localAlpha), RollLerp)
    elseif not (0 < curRotator.Yaw) and math.abs(curRotator.Yaw) % 180 > 90 then
      TargetRotator = FRotator(PitchLerp, Lerp(curRotator.Yaw, -180, localAlpha), RollLerp)
    else
      TargetRotator = FRotator(PitchLerp, Lerp(curRotator.Yaw, 0, localAlpha), RollLerp)
    end
  else
    TargetRotator = FRotator(PitchLerp, curRotator.Yaw, RollLerp)
  end
  self.DefaultSceneRoot:K2_SetWorldRotation(TargetRotator, false, nil, false)
end
function LobbyModelShowActor:TryRotate()
  if not self.bPress or not self.EnableInput_1 then
    return
  end
  local playerController = slua_GameFrontendHUD:GetPlayerController()
  local LocationX, LocationY, isCurrentlyPressed = playerController:GetInputTouchState(self.fingerIndex, nil, nil, nil)
  if isCurrentlyPressed then
    local temp    local temp    if self:NeedRotate(tempLocationX, tempLocationY) and self:NeedRotateY(tempLocationX, tempLocationY) then
      local Roll, Pitch, Yaw = self:MakeRotation(tempLocationX, tempLocationY)
      self.DefaultSceneRoot:K2_SetWorldRotation(FRotator(Pitch, Yaw, Roll), false, nil, false)
    end
    self.LocationX = tempLocationX
    self.LocationY = tempLocationY
  else
    self.bPress = false
    self.curBackTime = 0.0
  end
end
function LobbyModelShowActor:NeedRotate(x, y)
  if self.DisableRotate == 1 then
    return false
  end
  if not self.CanRotate then
    return false
  end
  if self.alreadyRotate then
    return true
  end
  local _X = x - self.originX
  local _Y = y - self.originY
  self.alreadyRotate = math.sqrt(_X * _X + _Y * _Y) >= self.disinteractDis
  return self.alreadyRotate
end
function LobbyModelShowActor:NeedRotateY(x, y)
  if self.alreadyRotateY then
    return true
  end
  if math.abs(x - self.originX) == 0 then
    self.alreadyRotateY = true
    return true
  end
  self.alreadyRotateY = math.abs(y - self.originY) / math.abs(x - self.originX) >= self.yDisinteractRatio
  return self.alreadyRotateY
end
function LobbyModelShowActor:GetRotateSpeed(DeltaX, DeltaY)
  local speed = math.sqrt(DeltaX * DeltaX + DeltaY * DeltaY)
  return speed
end
function LobbyModelShowActor:MakeRotation(newLocationX, newLocationY)
  local curRotator = self.DefaultSceneRoot:K2_GetComponentRotation()
  if self:ArrayFind("lock_x_rotation") then
    local rot = FRotator(0, self.LocationX - newLocationX, 0)
    local UKismetMathLibrary = import("KismetMathLibrary")
    local Rotator = UKismetMathLibrary.ComposeRotators(curRotator, rot)
    Rotator.Pitch = FuncUtil.Clamp(Rotator.Pitch, self.YRotateMin, self.YRotateMax)
    return Rotator.Roll, Rotator.Pitch, Rotator.Yaw
  else
    local rot = FRotator(0, self.LocationX - newLocationX, (newLocationY - self.LocationY) * self.yIntensity)
    local UKismetMathLibrary = import("KismetMathLibrary")
    local Rotator = UKismetMathLibrary.ComposeRotators(curRotator, rot)
    Rotator.Roll = FuncUtil.Clamp(Rotator.Roll, self.XRotateMin, self.XRotateMax)
    Rotator.Pitch = FuncUtil.Clamp(Rotator.Pitch, self.YRotateMin, self.YRotateMax)
    return Rotator.Roll, Rotator.Pitch, Rotator.Yaw
  end
end
function LobbyModelShowActor:_DisposeOperator()
  if self._SubOperator then
    self._SubOperator:OnDestroy()
    self._SubOperator:Dispose()
    self._SubOperator = nil
  end
end
function LobbyModelShowActor:UpdateShowType(ResID, ItemType, ItemSubType)
  self.ShowType = self:GetShowTypeByItemType(ResID, ItemType, ItemSubType)
end
function LobbyModelShowActor:DestoryDownLoad3DUI()
  if self.Download3DUIActor then
    self.Download3DUIActor:K2_DestroyActor()
    self.Download3DUIActor = nil
  end
end
function LobbyModelShowActor:RegistDownloadEvent()
  if self.bRegistEvent then
    return
  end
  self:AddCommonEvent(EVENTTYPE_PUFFER, EVENTID_PUFFER_DOWNLOADFINISH, self.OnDownloadDone, self)
  self.bRegistEvent = true
end
function LobbyModelShowActor:UnRegistDownloadEvent()
  if self.bRegistEvent then
    self:RemoveCommonEvent(EVENTTYPE_PUFFER, EVENTID_PUFFER_DOWNLOADFINISH)
    self.bRegistEvent = false
  end
end
function LobbyModelShowActor:TryShowModel(ItemID, BPID)
  self:DestroyAllContent()
  self:_CreatOperator()
  log(bWriteLog and "NewLobbyModelShowActor TryShowModel " .. ItemID)
  local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {ItemID})
  local bIgnoreDownload = self:ArrayFind("ignore_download")
  if not bIgnoreDownload and state ~= PufferConst.ENUM_DownloadState.Done then
    log(bWriteLog and "NewLobbyModelShowActor RegistDownloadEvent ItemID" .. ItemID)
    self:RegistDownloadEvent()
    if self:ArrayFind("download_3dui") then
      self:CreateDownload3DUI(ItemID)
    end
  end
  local itemCfg = CDataTable.GetTableData("Item", ItemID)
  if itemCfg then
    self:UpdateShowType(ItemID, itemCfg.ItemType, itemCfg.ItemSubType)
  end
  local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
  if self:NeedJumpOverShow() then
    log(bWriteLog and "NewLobbyModelShowActor TryShowModel NeedJumpOverShow")
  else
    self:ShowModel(ItemID, BPID)
  end
  self.bPress = false
  if not bIgnoreDownload and not self.ExtraTable.BanAutoDownload then
    self:HandleDownload(ItemID, BPID)
  end
end
function LobbyModelShowActor:HandleDownload(ItemID, BPID)
  if self:HandleModelsWithNoBasePak(ItemID) then
    log(bWriteLog and "NewLobbyModelShowActor HandleDownload HandleModelsWithNoBasePak ItemID" .. tostring(ItemID))
    return
  end
  if self:TriggerDownloadRes(ItemID, BPID) then
    log(bWriteLog and "NewLobbyModelShowActor HandleDownload TriggerDownloadRes ItemID" .. tostring(ItemID))
    if self.ShowType == 1 and self:IsBaseItemBPExist() then
      log(bWriteLog and "NewLobbyModelShowActor HandleDownload ShowType == 1 and self:IsBaseItemBPExist " .. tostring(ItemID))
      return
    end
    self:OnSubActorAsyncReady()
  end
end
local _GetBpID = function(ItemId)
  local itemCfg = CDataTable.GetTableData("Item", ItemId)
  if itemCfg then
    return itemCfg.BPID
  else
    return 0
  end
end
function LobbyModelShowActor:HandleModelsWithNoBasePak(ItemID)
  self.NeedDownloadBaseItem = nil
  if self.ShowType == 0 or self.ShowType == 1 or self.ShowType == 2 then
    local success = self:IsBaseItemBPExist()
    if not success then
      local WeaponModelMgrHelper = require("client.slua.logic.manager.WeaponModelSubLogic.WeaponModelMgrHelper")
      local OriginID = WeaponModelMgrHelper.GetRealResId(ItemID, true)
      self.NeedDownloadBaseItem = OriginID
      PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {OriginID})
      return true
    end
  end
  return false
end
function LobbyModelShowActor:TriggerDownloadRes(ItemID, BPID)
  local state = PufferConst.ENUM_DownloadState.Done
  state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {ItemID})
  local extraData = {bAutoDownload = true}
  PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {ItemID}, nil, nil, extraData)
  if state ~= PufferConst.ENUM_DownloadState.Done then
    return true
  else
    return false
  end
end
function LobbyModelShowActor:NeedJumpOverShow()
  local jumpOverShow = false
  if self.ShowType and (self.ShowType == LobbyShowActorConfig.Type.Weapon or self.ShowType == LobbyShowActorConfig.Type.Vehicle or self.ShowType == LobbyShowActorConfig.Type.Plane or self.ShowType == LobbyShowActorConfig.Type.Tank or self.ShowType == LobbyShowActorConfig.Type.Mecha) then
    log(bWriteLog and "LobbyModelShowActor:NeedJumpOverShow self.ShowType" .. tostring(self.ShowType))
    local success = self:IsBaseItemBPExist()
    if not success then
      log(bWriteLog and "LobbyModelShowActor:NeedJumpOverShow not success")
      jumpOverShow = true
    end
  end
  return jumpOverShow
end
function LobbyModelShowActor:CacheTransform()
  self.cachedLocation = self:K2_GetActorLocation()
  self.cachedRotation = self:K2_GetActorRotation()
  self.cachedScale3D = self:GetActorScale3D()
end
function LobbyModelShowActor:OnDownloadDone(param1, param2, eventData)
  local doneItemID = eventData.itemID
  if not doneItemID or not tonumber(doneItemID) then
    return
  end
  log(bWriteLog and "NewLobbyModelShowActor OnDownloadDone doneItemID = " .. tostring(doneItemID) .. " CurrentItemID = " .. tostring(self.CurrentItemID))
  if PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {
    self.CurrentItemID
  }) ~= PufferConst.ENUM_DownloadState.Done then
    if self.NeedDownloadBaseItem and PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {
      self.NeedDownloadBaseItem
    }) == PufferConst.ENUM_DownloadState.Done then
      self.NeedDownloadBaseItem = nil
      self:UpdateItemDownload(self.CurrentItemID)
    end
    return
  end
  if self.ShowType == 0 or self.ShowType == 1 or self.ShowType == 2 then
    local success = self:IsBaseItemBPExist()
    if not success then
      log(bWriteLog and "OnDownloadDone BaseItem not exist")
      return
    end
  end
  self:UnRegistDownloadEvent()
  if self.Download3DUIActor == nil then
    self:CacheTransform()
  end
  self:DestoryDownLoad3DUI()
  self:UpdateItemDownload(doneItemID)
end
function LobbyModelShowActor:UpdateItemDownload(doneItemID)
  if self.cachedLocation == nil then
    self:CacheTransform()
  end
  local BPID = _GetBpID(self.CurrentItemID)
  log(bWriteLog and "OnDownloadDone ShowModel CurrentItemID = " .. tostring(self.CurrentItemID))
  if self._SubOperator.ItemID and self.ShowType ~= 0 then
    self._SubOperator:OnDownLoadFinish(self.CurrentItemID, BPID)
  else
    self:TryShowModel(self.CurrentItemID, BPID)
  end
  local WeaponModelLogic = require("client.slua.logic.manager.WeaponModelLogic")
  if self.ShowType == 5 then
    local actor = WeaponModelLogic.GetProperWeaponShowActor()
    if slua.isValid(actor) and slua.isValid(actor.SubActor) and actor.SubActor.VehicleAvatarComponent_BP and actor.SubActor.VehicleAvatarComponent_BP.bIsLobbyAvatar == false then
      local RefitVehicle = require("client.logic.vehicle.logic_refit_vehicle")
      local VehicleRefitHandler = require("client.network.Protocol.VehicleRefitHandler")
      actor.SubActor:SetActorTickEnabled(false)
      RefitVehicle.EquipStyleList(actor.SubActor, VehicleRefitHandler.GetCarStyleList(doneItemID))
    end
  end
  WeaponModelLogic.RefreshWeaponLocation(self.CurrentItemID)
end
local DISTANCE_BETWEEN_3DUI_AND_CAMERA_STANDARD = 1000
function LobbyModelShowActor:CalcDownload3DUILocation()
  local Location = self:K2_GetActorLocation()
  local playerController = slua_GameFrontendHUD:GetPlayerController()
  local cameraLocation = playerController:GetViewTarget():K2_GetActorLocation()
  local vec = {
    x = Location.X - cameraLocation.X,
    y = Location.Y - cameraLocation.Y,
    z = Location.Z - cameraLocation.Z
  }
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  local config = Lobby_camera_manager_module:GetLobbyCameraInfoByCameraID(Lobby_camera_manager_module:GetCurrentCameraID())
  local fov = 70.0
  if config then
    fov = tonumber(config.FieldOfView)
  end
  local distance = DISTANCE_BETWEEN_3DUI_AND_CAMERA_STANDARD * math.tan(math.rad(17.5)) / math.tan(math.rad(fov / 2))
  log(bWriteLog and "NewLobbyModelShowActor CreateDownload3DUI distance = " .. distance)
  local length = math.sqrt(vec.x * vec.x + vec.y * vec.y + vec.z * vec.z)
  local SpawnLocation = FVector(cameraLocation.X + vec.x / length * distance, cameraLocation.Y + vec.y / length * distance, cameraLocation.Z + vec.z / length * distance + 10)
  return SpawnLocation
end
function LobbyModelShowActor:CreateDownload3DUI(ItemID)
  log(bWriteLog and "NewLobbyModelShowActor CreateDownload3DUI ItemID = " .. tostring(ItemID))
  local SpawnLocation = self:CalcDownload3DUILocation()
  self:DestoryDownLoad3DUI()
  local World = slua_GameFrontendHUD:GetWorld()
  local ActorClass = import(DownLoad3DUIPath)
  self.Download3DUIActor = World:SpawnActor(ActorClass, SpawnLocation, nil, nil)
  self.Download3DUIActor:K2_SetActorRotation(FRotator(0, 90, 0), false)
  self.Download3DUIActor:SetActorScale3D(FVector(1, 0.07, 0.07))
  if not self.Download3DUIActor or not slua.isValid(self.Download3DUIActor) then
    log(bWriteLog and "LobbyModelShowActor CreateDownload3DUI failed")
    return
  end
  self:CacheTransform()
  local common_download_handler = require("client.slua.common.common_download_handler")
  local params = {}
  params.hideMask = true
  params.size = 110
  params.pos = FVector2D(150, -150)
  params.is3DUI = true
  common_download_handler.CreateDownloadUI(PufferConst.ENUM_DownloadType.ODPAK, {ItemID}, self.Download3DUIActor.Widget.Widget.Panel_Download, params)
end
function LobbyModelShowActor:UpdateDownload3DUITransform()
  local SpawnLocation = self:CalcDownload3DUILocation()
  local World = slua_GameFrontendHUD:GetWorld()
  local ActorClass = import(DownLoad3DUIPath)
  if self.Download3DUIActor then
    self.Download3DUIActor:K2_SetActorLocation(SpawnLocation, false, nil, false)
  end
end
function LobbyModelShowActor:IsBaseItemBPExist()
  local WeaponModelMgrHelper = require("client.slua.logic.manager.WeaponModelSubLogic.WeaponModelMgrHelper")
  local OriginID = WeaponModelMgrHelper.GetRealResId(self.CurrentItemID, true)
  local ItemCfg = CDataTable.GetTableData("Item", OriginID)
  if not ItemCfg then
    return false
  end
  local UBackpackUtils = import("BackpackUtils")
  local ItemDefineID = FItemDefineID(ItemCfg.ItemType, OriginID)
  return UBackpackUtils.IsBattleItemHandleExist(ItemDefineID, false, false, false)
end
function LobbyModelShowActor:OnSubActorAsyncReady()
  log(bWriteLog and "NewLobbyModelShowActor OnAsyncReadyLua" .. self.CurrentItemID)
  self:ProcessNextActor()
  EventSystem:postEvent(EVENTTYPE_LOBBY_SCENE, EVENTID_SCENE_GARAGE_MODEL_READY, self.CurrentItemID)
end
function LobbyModelShowActor:ProcessNextActor()
  if self.isAsyncLoading == false then
    return
  end
  self.isAsyncLoading = false
  if slua.isValid(self.nextShowActor) then
    self.nextShowActor:DestroyAllContent()
    self.nextShowActor:SetActorHiddenInGame(true)
    self.nextShowActor:K2_SetActorLocation(FVector(-5.0, -383.0, -24346.0), false, nil, false)
    self.nextShowActor.CurrentItemID = -1
    self.nextShowActor.ExtraTable = {}
  end
end
function LobbyModelShowActor:SetForceForbideWeaponIdleAnim()
  if slua.isValid(self.SubActor) and self.SubActor.SetForceForbideIdleAnim then
    self.SubActor:SetForceForbideIdleAnim()
  end
end
function LobbyModelShowActor:DetachFromAttachPoint()
  log(bWriteLog and "LobbyModelShowActor DetachFromAttachPoint")
  local parent = self.DefaultSceneRoot:GetAttachParent()
  if not slua.isValid(parent) then
    return
  end
  local Owner = parent:GetOwner()
  if not slua.isValid(Owner) then
    return
  end
  local EDetachmentRule = import("EDetachmentRule")
  self:K2_DetachFromActor(EDetachmentRule.KeepWorld, EDetachmentRule.KeepWorld, EDetachmentRule.KeepWorld)
end
function LobbyModelShowActor:StopAkEvent()
  if slua.isValid(self.SubActor) then
    self.SubActor.Ak:Stop()
  end
end
function LobbyModelShowActor:GetWeaponActor()
  if self.ShowType ~= LobbyShowActorConfig.Type.Weapon and self.ShowType ~= LobbyShowActorConfig.Type.TwoWeapon then
    log(bWriteLog and "GetWeaponActor ..Type Name" .. tostring(LobbyShowActorConfig.ModelConfig[self.ShowType].Name))
    return
  end
  return self.SubActor
end
function LobbyModelShowActor:GetPlaneCharacter()
  if self.ShowType ~= LobbyShowActorConfig.Type.Plane then
    log(bWriteLog and "GetPlaneCharacter ..Type Name" .. tostring(LobbyShowActorConfig.ModelConfig[self.ShowType].Name))
    return
  end
  return self.SubActor
end
function LobbyModelShowActor:GetgrenadeActor()
  if self.ShowType ~= LobbyShowActorConfig.Type.Grenade then
    log(bWriteLog and "GetgrenadeActor ..Type Name" .. tostring(LobbyShowActorConfig.ModelConfig[self.ShowType].Name))
    return
  end
  return self.SubActor
end
function LobbyModelShowActor:GetBagWidgetActor()
  if self.ShowType ~= LobbyShowActorConfig.Type.BagWidget then
    log(bWriteLog and "GetBagWidgetActor ..Type Name" .. tostring(LobbyShowActorConfig.ModelConfig[self.ShowType].Name))
    return
  end
  return self.SubActor
end
function LobbyModelShowActor:GetVehicleActor()
  if self.ShowType ~= LobbyShowActorConfig.Type.Vehicle and self.ShowType ~= LobbyShowActorConfig.Type.Tank then
    log(bWriteLog and "GetVehicleActor ..Type Name" .. tostring(LobbyShowActorConfig.ModelConfig[self.ShowType].Name))
    return
  end
  return self.SubActor
end
function LobbyModelShowActor:GetTankActor()
  if self.ShowType ~= LobbyShowActorConfig.Type.Tank then
    log(bWriteLog and "GetVehicleActor ..Type Name" .. tostring(LobbyShowActorConfig.ModelConfig[self.ShowType].Name))
    return
  end
  return self.SubActor
end
function LobbyModelShowActor:GetrefitVehicleActor()
  if self.ShowType ~= LobbyShowActorConfig.Type.RefitVehicle then
    log(bWriteLog and "GetrefitVehicleActor ..Type Name" .. tostring(LobbyShowActorConfig.ModelConfig[self.ShowType].Name))
    return
  end
  return self.SubActor
end
function LobbyModelShowActor:GetparachuteActor()
  if self.ShowType ~= LobbyShowActorConfig.Type.Parachute then
    log(bWriteLog and "GetparachuteActor ..Type Name" .. tostring(LobbyShowActorConfig.ModelConfig[self.ShowType].Name))
    return
  end
  return self.SubActor
end
function LobbyModelShowActor:Geticon3DActor()
  if self.ShowType ~= LobbyShowActorConfig.Type.Icon3D then
    log(bWriteLog and "Geticon3DActor ..Type Name" .. tostring(LobbyShowActorConfig.ModelConfig[self.ShowType].Name))
    return
  end
  return self.SubActor
end
function LobbyModelShowActor:GetbagActor()
  if self.ShowType ~= LobbyShowActorConfig.Type.Bag then
    log(bWriteLog and "GetbagActor ..Type Name" .. tostring(LobbyShowActorConfig.ModelConfig[self.ShowType].Name))
    return
  end
  return self.SubActor
end
function LobbyModelShowActor:GetWingmanActor()
  if self.ShowType ~= LobbyShowActorConfig.Type.Wingman then
    log(bWriteLog and "GetWingmanActor ..Type Name" .. tostring(LobbyShowActorConfig.ModelConfig[self.ShowType].Name))
    return
  end
  return self.SubActor
end
function LobbyModelShowActor:GetMiniTvShowActor()
  if self.ShowType ~= LobbyShowActorConfig.Type.MiniTVNew then
    log(bWriteLog and "GetMiniTvShowActor ..Type Name" .. tostring(LobbyShowActorConfig.ModelConfig[self.ShowType].Name))
    return
  end
  return self.SubActor
end
function LobbyModelShowActor:GetVehicleOrPlaneActor()
  if self.ShowType ~= LobbyShowActorConfig.Type.Vehicle and self.ShowType ~= LobbyShowActorConfig.Type.Tank and self.ShowType ~= LobbyShowActorConfig.Type.RefitVehicle and self.ShowType ~= LobbyShowActorConfig.Type.Plane and self.ShowType ~= LobbyShowActorConfig.Type.Wingman then
    log(bWriteLog and "GetVehicleOrPlaneActor ..Type Name" .. tostring(LobbyShowActorConfig.ModelConfig[self.ShowType].Name))
    return
  end
  return self.SubActor
end
function LobbyModelShowActor:SetWeaponCollision()
  if not slua.isValid(self.SubActor) then
    return
  end
  self.SubActor:SetActorEnableCollision(true)
end
function LobbyModelShowActor:DestroyAllContent()
  self:DestroySubActor()
  self:DestoryDownLoad3DUI()
  self:_DisposeOperator()
  self:UnRegistDownloadEvent()
  self:DetachFromAttachPoint()
end
function LobbyModelShowActor:DestroySubActor()
  if slua.isValid(self.SubActor) then
    local EAttachmentRule = import("EAttachmentRule")
    self.SubActor:K2_DetachFromActor(EAttachmentRule.KeepRelative, EAttachmentRule.KeepRelative, EAttachmentRule.KeepRelative)
    local LobbyModelPool = require("client.slua.logic.show_actor.common.LobbyModelPool")
    LobbyModelPool.ReleaseModel(self.SubActor.ShowType, self.SubActor)
    self.SubActor = nil
  end
end
function LobbyModelShowActor:SetActorData(resId, xoffset, rotator, needResetAutoRotation, XRotateLimit, YRotateLimit, InitRotate, DisableRotate)
  local ShowActorData = {
    XOffset = xoffset,
    XRotateLimit = XRotateLimit,
    YRotateLimit = YRotateLimit,
    NeedResetRotation = needResetAutoRotation,
    Rotator = rotator,
    InitRotate = InitRotate,
      }
  self.ShowActorDataArray[resId] = ShowActorData
end
function LobbyModelShowActor:SetShowActorLocationRotation(resId)
  local ShowData = self.ShowActorDataArray[resId]
  if not ShowData then
    return
  end
  self.Scene:K2_SetRelativeLocation(FVector(ShowData.XOffset, 0, 0), false, nil, false)
  self:UpdateRotateLimit(ShowData.XRotateLimit, ShowData.YRotateLimit, ShowData.DisableRotate)
  if ShowData.NeedResetRotation then
    self.DefaultSceneRoot:K2_SetWorldRotation(ShowData.InitRotate, false, nil, false)
  end
end
function LobbyModelShowActor:SetWeaponPendantSocketType(type)
  if not self._SubOperator then
    log_error("LobbyModelShowActor SetWeaponPendantSocketType self._SubOperator is nil" .. tostring(self.CurrentItemID))
    return
  end
  self._SubOperator:SetWeaponPendantSocketType(type)
end
function LobbyModelShowActor:GetComponentPosition(SlotID)
  if not self._SubOperator then
    log_error("LobbyModelShowActor GetComponentPosition self._SubOperator is nil" .. tostring(self.CurrentItemID))
    return
  end
  return self._SubOperator:GetComponentPosition(SlotID)
end
function LobbyModelShowActor:GetSocketTransform(showType, socketName)
  if not self._SubOperator then
    log_error("LobbyModelShowActor GetSocketTransform self._SubOperator is nil" .. tostring(self.CurrentItemID))
    return
  end
  return self._SubOperator:GetSocketTransform(showType, socketName)
end
function LobbyModelShowActor:SetRotateBackZ(rotateZ)
  self.RotateBackZ = rotateZ
end
function LobbyModelShowActor:SetHolderBack()
  if not self._SubOperator then
    log_error("LobbyModelShowActor SetHolderBack self._SubOperator is nil" .. tostring(self.CurrentItemID))
    return
  end
  self._SubOperator:SetHolderBack()
end
function LobbyModelShowActor:SetCastShadow(bCastShadow)
  if not self._SubOperator then
    log_error("LobbyModelShowActor SetCastShadow self._SubOperator is nil" .. tostring(self.CurrentItemID))
    return
  end
  self._SubOperator:SetCastShadow(bCastShadow)
end
function LobbyModelShowActor:PutonEquipmentByResid(resId)
  if not self._SubOperator then
    log_error("LobbyModelShowActor PutonEquipmentByResid self._SubOperator is nil" .. tostring(self.CurrentItemID))
    return
  end
  self._SubOperator:PutonEquipmentByResid(resId)
end
function LobbyModelShowActor:PutoffEquipmentByResid(resId)
  if not self._SubOperator then
    log_error("LobbyModelShowActor PutoffEquipmentByResid self._SubOperator is nil" .. tostring(self.CurrentItemID))
    return
  end
  self._SubOperator:PutoffEquipmentByResid(resId)
end
function LobbyModelShowActor:SetTouchStatus(can)
  local ECollisionEnabled = import("ECollisionEnabled")
  if can then
    self.Capsule:SetCollisionEnabled(ECollisionEnabled.QueryAndPhysics)
  else
    self.Capsule:SetCollisionEnabled(ECollisionEnabled.NoCollision)
  end
end
function LobbyModelShowActor:UpdateRotateLimit(XRotateLimit, YRotateLimit, DisableRotate)
  if XRotateLimit ~= "" then
    local kismet_string_library = require("common.kismet_string_library")
    local Array = kismet_string_library.ParseIntoArray(XRotateLimit, ";", true)
    self.XRotateMin = tonumber(Array[1])
    self.XRotateMax = tonumber(Array[2])
  end
  if YRotateLimit ~= "" then
    local kismet_string_library = require("common.kismet_string_library")
    local Array = kismet_string_library.ParseIntoArray(YRotateLimit, ";", true)
    self.YRotateMin = tonumber(Array[1])
    self.YRotateMax = tonumber(Array[2])
  end
  self.DisableRotate = tonumber(DisableRotate) or 0
end
function LobbyModelShowActor:AttachModelCenter(cameraId)
  if not self._SubOperator then
    log_error("LobbyModelShowActor AttachModelCenter self._SubOperator is nil" .. tostring(self.CurrentItemID))
    return
  end
  self._SubOperator:AttachModelCenter(cameraId)
end
function LobbyModelShowActor:AttachToAttachPoint()
  if not self._SubOperator then
    log_error("LobbyModelShowActor AttachToAttachPoint self._SubOperator is nil" .. tostring(self.CurrentItemID))
    return
  end
  self._SubOperator:AttachToAttachPoint()
end
function LobbyModelShowActor:GetCurSubOperator()
  return self._SubOperator
end
function LobbyModelShowActor:GetVehicleLicense()
  if not self.ExtraTable or not self.ExtraTable.License then
    return
  end
  return self.ExtraTable.License
end
function LobbyModelShowActor:GetVehicleLicenseBgId()
  if not self.ExtraTable or not self.ExtraTable.LicenseBgId then
    return
  end
  return self.ExtraTable.LicenseBgId
end
function LobbyModelShowActor:GetVehicleAccessory()
  if not self.ExtraTable or not self.ExtraTable.AccessoryList then
    log(bWriteLog and "LobbyModelShowActor:GetVehicleAccessory no AccessoryList")
    return
  end
  log_tree(bWriteLog and "LobbyModelShowActor:GetVehicleAccessory self.ExtraTable.AccessoryList", self.ExtraTable.AccessoryList)
  return self.ExtraTable.AccessoryList
end
function LobbyModelShowActor:SetVehicleAccessory(AccessoryList)
  log_tree(bWriteLog and "LobbyModelShowActor:SetVehicleAccessory AccessoryList", AccessoryList)
  self.ExtraTable = self.ExtraTable or {}
  self.ExtraTable.  if self.SubActor and self.SubActor.SetVehicleAccessoryList then
    self.SubActor:SetVehicleAccessoryList(AccessoryList)
  end
end
function LobbyModelShowActor:GetVehicleChassisLight()
  if not self.ExtraTable or not self.ExtraTable.ChassisLight then
    log(bWriteLog and "LobbyModelShowActor:GetVehicleChassisLight no AccessoryList")
    return
  end
  log_tree(bWriteLog and "LobbyModelShowActor:GetVehicleChassisLight ChassisLight", self.ExtraTable.ChassisLight)
  return self.ExtraTable.ChassisLight
end
function LobbyModelShowActor:SetVehicleChassisLight(chassisLightData)
  log_tree(bWriteLog and "LobbyModelShowActor:SetVehicleChassisLight SetChassisLightData", chassisLightData)
  self.ExtraTable = self.ExtraTable or {}
  self.ExtraTable.ChassisLight = chassisLightData
  if self.SubActor and self.SubActor.SetChassisLightShowData then
    self.SubActor:SetChassisLightShowData(chassisLightData)
  end
end
function LobbyModelShowActor:GetVehicleAppliqueList()
  if not self.ExtraTable or not self.ExtraTable.AppliqueList then
    log(bWriteLog and "LobbyModelShowActor:GetVehicleAppliqueList no AppliqueList")
    return
  end
  return self.ExtraTable.AppliqueList
end
function LobbyModelShowActor:IsEnableHighTire()
  if not self.ExtraTable or not self.ExtraTable.EnableHighTire then
    return
  end
  return self.ExtraTable.EnableHighTire
end
function LobbyModelShowActor:SetHighLight(Invincible, FreExp, Speed)
  if self.SubActor and self.SubActor.SetHighLight then
    self.SubActor:SetHighLight(Invincible, FreExp, Speed)
  end
end
function LobbyModelShowActor:SetShowModelOutline(bIsShow, uOutlineColor, nOutlineThickness)
  if self.SubActor and self.SubActor.SetShowModelOutline then
    self.SubActor:SetShowModelOutline(bIsShow, uOutlineColor, nOutlineThickness)
  end
end
function LobbyModelShowActor:SetExtraTable(ExtraTable)
  log_tree(bWriteLog and "LobbyModelShowActor:SetExtraTable old ExtraTable", self.ExtraTable)
  log_tree(bWriteLog and "LobbyModelShowActor:SetExtraTable new ExtraTable", ExtraTable)
  self.  if self._SubOperator and self._SubOperator.RefreshExtraTableDataShow then
    self._SubOperator:RefreshExtraTableDataShow()
  end
end
function LobbyModelShowActor:GetAttachPoint()
  local ActorTools = require("GameLua.Mod.BaseMod.Common.ActorTools")
  local Actor = ActorTools.GetOneActorByTag(CGameWorld, "Actor", "VehicleAttachPoint")
  return Actor
end
function LobbyModelShowActor:SubOperatorSetShowData(uPos, uRot, uScale)
  if not self._SubOperator or not self._SubOperator.SetModelRelativeLocationRotationScale then
    log_error("LobbyModelShowActor SubOperatorSetShow self._SubOperator is nil - self.CurrentItemID = " .. tostring(self.CurrentItemID))
    return
  end
  self._SubOperator:SetModelRelativeLocationRotationScale(uPos, uRot, uScale)
end
local class = require("class")
local CActorBase = require("GameLua.Mod.BaseMod.Common.Core.ActorBase")
local CLobbyModelShowActor = class(CActorBase, nil, LobbyModelShowActor)
return CLobbyModelShowActor