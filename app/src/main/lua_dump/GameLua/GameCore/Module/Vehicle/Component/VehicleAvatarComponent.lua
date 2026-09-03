local VehicleAvatarComponent = {}
local ReflectionCubemapReuseMap = {
  [10128] = 10128,
  [10129] = 10128,
  [10130] = 10128,
  [10131] = 10128,
  [10132] = 10128,
  [10133] = 10128
}
local HighTireMatSlotName = "slot1"
function VehicleAvatarComponent:ReceiveBeginPlay()
  print(bWriteLog and "VehicleAvatarComponent ReceiveBeginPlay")
  self.isFppScope = false
  if self.TryAddLightEffect then
    self:AddControlEvent(self, "VehicleAvatarEqiuped", self.TryAddLightEffect, self)
    self:AddControlEvent(self, "VehicleLoadedFPPMesh", self.TryAddLightEffect, self)
  end
  if self.LoadedBrokenMat then
    self:AddControlEvent(self, "VehicleLoadedBrokenMat", self.LoadedBrokenMat, self)
  end
  self.DownDetectLength = -2.0
  local ASTExtraVehicleBase = import("STExtraVehicleBase")
  if self:GetOwner() and Game:IsClassOf(self:GetOwner(), ASTExtraVehicleBase) then
    self:AddControlEvent(self:GetOwner(), "OnClientEnterVehicleEvent", self.ClientHandleEnterVehicle, self)
    self:AddControlEvent(self:GetOwner(), "OnClientExitVehicleEvent", self.ClientHandleExitVehicle, self)
  end
  if not Client then
    self:AddControlEvent(self, "OnVehicleAvatarPreChange", self.OnPreChangeVehicleAvatar, self)
  end
end
function VehicleAvatarComponent:ReceiveEndPlay(EndReason, bClearTable)
  print(bWriteLog and "VehicleAvatarComponent:ReceiveEndPlay")
  if self.uSwitchEffectActor then
    self.uSwitchEffectActor:K2_DestroyActor()
  end
  VehicleAvatarComponent.__super.ReceiveEndPlay(self, EndReason, bClearTable)
end
function VehicleAvatarComponent:GetReflectionCubeName_Lobby()
  local cameraId
  local Lobby_Main_Control = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
  if Lobby_Main_Control.toPage == ENUM_LobbyPageType.Left or Lobby_Main_Control.curPage == ENUM_LobbyPageType.Left then
    cameraId = 10156
  else
    local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
    cameraId = Lobby_camera_manager_module:GetCurrentCameraID()
  end
  if ReflectionCubemapReuseMap[cameraId] then
    cameraId = ReflectionCubemapReuseMap[cameraId]
  end
  local VehicleActor = self:GetOwner()
  if slua.isValid(VehicleActor) and VehicleActor.IsHallVehicle then
    cameraId = 10001
  end
  log(bWriteLog and "VehicleAvatarComponent GetReflectionCubeName_Lobby" .. tostring(cameraId))
  return tostring(cameraId)
end
function VehicleAvatarComponent:TriggerSelectRandomAvatar()
  if CGameMode.VehicleAvatarReplaceCfgList == nil or CGameMode.VehicleAvatarReplaceCfgList:Num() == 0 then
    print(bWriteLog and "TriggerSelectRandomAvatar No VehicleAvatarReplaceCfgList")
    return false
  end
  local VehicleAvatarReplaceCfgList = CGameMode.VehicleAvatarReplaceCfgList
  local VehicleActor = self:GetOwner()
  if not slua.isValid(VehicleActor) then
    print(bWriteLog and "TriggerSelectRandomAvatar Vehicle Not Valid")
    return false
  end
  local DefaultID = VehicleActor.AvatarDefaultCfg
  if DefaultID == nil or DefaultID.TypeSpecificID == 0 then
    print(bWriteLog and "TriggerSelectRandomAvatar DefaultID Not Valid")
    return false
  end
  local SkinToOriginCfg = CDataTable.GetTableData("VehiclePlaneSkinMapping", DefaultID.TypeSpecificID)
  if SkinToOriginCfg == nil then
    print(bWriteLog and "TriggerSelectRandomAvatar SkinMapCfg Not Valid")
    return false
  end
  local OrginalID = SkinToOriginCfg.OrginalID
  for Index, ReplaceCfg in pairs(VehicleAvatarReplaceCfgList) do
    if ReplaceCfg.OriginID == OrginalID then
      if ReplaceCfg.MaxNum <= ReplaceCfg.CurrentNum then
        print(bWriteLog and "TriggerSelectRandomAvatar Reach MaxNum")
        return false
      end
      local IDNum = ReplaceCfg.SkinIDList:Num()
      local ProbabilityNum = ReplaceCfg.ProbabilityDistribute:Num()
      if IDNum ~= ProbabilityNum then
        print(bWriteLog and "TriggerSelectRandomAvatar IDNum ProbabilityNum Not Match")
        return false
      end
      local RandomF = math.random()
      local SelectIndex = 0
      for i = 1, IDNum do
        if RandomF < ReplaceCfg.ProbabilityDistribute:Get(i - 1) then
          SelectIndex = i
          print(bWriteLog and "TriggerSelectRandomAvatar Select Index: " .. SelectIndex)
          break
        end
      end
      if SelectIndex == 0 then
        print(bWriteLog and "TriggerSelectRandomAvatar  Index Valid")
        return false
      end
      local SelectSkinID = ReplaceCfg.SkinIDList:Get(SelectIndex - 1)
      print(bWriteLog and "TriggerSelectRandomAvatar  Success")
      self:ChangeItemAvatar(SelectSkinID, false)
      if self.CanChangeAvatar then
        ReplaceCfg.CurrentNum = ReplaceCfg.CurrentNum + 1
        VehicleAvatarReplaceCfgList:Set(Index, ReplaceCfg)
      end
      return true
    end
  end
  return false
end
function VehicleAvatarComponent:ClientHandleEnterVehicle(Character)
  if not Character then
    log_error("VehicleAvatarComponent ClientHandleEnterVehicle Character is not Valid")
    return
  end
  print(bWriteLog and "[zxq]VehicleAvatarComponent ClientHandleEnterVehicle")
  self:AddControlEvent(Character, "OnScopeInDelegate", self.OnHandleScopeInDelegate, self)
  self:AddControlEvent(Character, "OnScopeOutDelegate", self.OnHandleScopeOutDelegate, self)
  self:UpdateIsFppScope(false)
  self:SetClothParticleActive(Character, false)
end
function VehicleAvatarComponent:SetClothParticleActive(Character, bActive)
  if not slua.isValid(Character) then
    return
  end
  local uComponentClass = import("FXSystemComponent")
  local uTargetArray = Character:GetComponentsByTag(uComponentClass, "HideOnVehicle")
  for i = 0, uTargetArray:Num() - 1 do
    local ParticleComp = uTargetArray:Get(i)
    if slua.isValid(ParticleComp) then
      if bActive then
        ParticleComp:Deactivate()
        ParticleComp:Activate(true)
      else
        ParticleComp:Deactivate()
      end
    end
  end
end
function VehicleAvatarComponent:ClientHandleExitVehicle(Character)
  if not Character then
    log_error("VehicleAvatarComponent ClientHandleEnterVehicle Character is not Valid")
    return
  end
  print(bWriteLog and "[zxq]VehicleAvatarComponent ClientHandleExitVehicle")
  self:RemoveControlEvent(Character, "OnScopeInDelegate")
  self:RemoveControlEvent(Character, "OnScopeOutDelegate")
  self:UpdateIsFppScope(false)
  self:SetClothParticleActive(Character, true)
end
function VehicleAvatarComponent:OnHandleScopeInDelegate(isBegin)
  if isBegin then
    self:UpdateIsFppScope(true)
    return
  end
  if self.VehicleAvatarHandle and self.VehicleAvatarHandle.bNeedHideExhaustWhenScope then
    print(bWriteLog and "VehicleAvatarComponent OnHandleScopeInDelegate DeactiveEffect Exhaust")
    self:GetOwner():DeactiveEffect("Exhaust")
  end
end
function VehicleAvatarComponent:OnHandleScopeOutDelegate(isBegin)
  if isBegin then
    return
  end
  self:UpdateIsFppScope(false)
end
function VehicleAvatarComponent:UpdateIsFppScope(isFppScope)
  log(bWriteLog and "VehicleAvatarComponent UpdateIsFppScope " .. tostring(isFppScope))
  self.  self:UpdateIsFppScopeInternal(self:GetOwner(), isFppScope)
  self:UpdateIsFppScopeInternal(self.uSwitchEffectActor, isFppScope)
end
function VehicleAvatarComponent:UpdateIsFppScopeInternal(VehicleActor, isFppScope)
  if slua.isValid(VehicleActor) and slua.isValid(VehicleActor.Mesh) then
    local AnimInstance = VehicleActor.Mesh:GetAnimInstance()
    if AnimInstance and AnimInstance.UpdateIsFppScope then
      log(bWriteLog and "VehicleAvatarComponent:UpdateIsFppScopeInternal " .. tostring(isFppScope) .. " actor: " .. tostring(VehicleActor))
      if isFppScope == nil then
        isFppScope = false
      end
      AnimInstance:UpdateIsFppScope(isFppScope)
    end
  end
end
function VehicleAvatarComponent:EnableHighTireLight(bEnable, vehicleId)
  log(bWriteLog and "VehicleAvatarComponent EnableHighTireLight bEnable" .. tostring(bEnable))
  if not slua.isValid(self.ItemBodyMesh) then
    log(bWriteLog and "VehicleAvatarComponent EnableHighTireLight self.ItemBodyMesh is not Valid")
    return
  end
  vehicleId = vehicleId or self:GetCurItemAvatarID()
  local CollectCarHighTireCfg = CDataTable.GetTableData("CollectCarHighTire", vehicleId)
  if not CollectCarHighTireCfg then
    log(bWriteLog and "VehicleAvatarComponent EnableHighTireLight CollectCarHighTire Can`t find ItemID" .. tostring(vehicleId))
    return
  end
  local MatIndex = self.ItemBodyMesh:GetMaterialIndex(HighTireMatSlotName)
  local Material = self.ItemBodyMesh:GetMaterial(MatIndex)
  if not Material then
    log(bWriteLog and "VehicleAvatarComponent EnableHighTireLight Material is not Valid")
    return
  end
  local DynamicMat = self.ItemBodyMesh:CreateDynamicMaterialInstance(MatIndex, Material)
  if not DynamicMat then
    log(bWriteLog and "VehicleAvatarComponent EnableHighTireLight DynamicMat is not Valid")
    return
  end
  local HighLightParam = "HubLight"
  if vehicleId == 1903212 or vehicleId == 1915018 then
    HighLightParam = "HuxiTintInt"
  end
  print(bWriteLog and "[tire]VehicleAvatarComponent EnableHighTireLight", vehicleId, HighLightParam)
  if bEnable then
    DynamicMat:SetScalarParameterValue(HighLightParam, 5)
  else
    DynamicMat:SetScalarParameterValue(HighLightParam, 0)
  end
end
function VehicleAvatarComponent:OnRep_NetHighTireChanged()
  local vehicleItemId = self:GetOwner() and self:GetOwner().ClientUsedAvatarID
  print(bWriteLog and "VehicleAvatarComponent OnRep_bEnableHighTire vehicleItemId:" .. tostring(vehicleItemId))
  if vehicleItemId and vehicleItemId == self.NetHighTireStruct.ItemID then
    self:EnableHighTireLight(self.NetHighTireStruct.bEnableHighTire, vehicleItemId)
  end
end
function VehicleAvatarComponent:OnPreChangeVehicleAvatar(ItemID)
  if not ItemID then
    print(bWriteLog and "VehicleAvatarComponent:OnPreChangeVehicleAvatar ItemID is nil")
    return
  end
  local ItemInfo = CDataTable.GetTableData("Item", ItemID)
  if not ItemInfo or not ItemInfo.ItemSubType then
    print(bWriteLog and "VehicleAvatarComponent:OnPreChangeVehicleAvatar ItemID:" .. tostring(ItemID) .. " ItemInfo or ItemInfo.ItemSubType is nil")
    return
  end
  print(bWriteLog and "VehicleAvatarComponent:OnPreChangeVehicleAvatar  ItemID:" .. tostring(ItemID))
  local vehicleActor = self:GetOwner()
  if slua.isValid(vehicleActor) and vehicleActor:HasAuthority() and vehicleActor.GetDirverOrOwner then
    local nVehicleShapeType = vehicleActor.VehicleShapeType
    local Pawn = vehicleActor:GetDirverOrOwner()
    local nCurAvatarID = self:GetCurItemAvatarID()
    if slua.isValid(Pawn) then
      local nPlayerKey = Pawn.PlayerKey
      if nPlayerKey ~= nil and 0 < nPlayerKey then
        local DSCommonTLogSubsystem = SubsystemMgr:Get("DSCommonTLogSubsystem")
        if DSCommonTLogSubsystem then
          local Param = string.format("%s,%s,%s,%s", tostring(nPlayerKey), tostring(ItemInfo.ItemSubType), tostring(ItemID), tostring(nCurAvatarID))
          print(bWriteLog and "VehicleAvatarComponent:OnPreChangeVehicleAvatar ChangeAvatarInfo: " .. Param)
          DSCommonTLogSubsystem:HandleChangeAvatarTlog(nPlayerKey, ItemInfo.ItemSubType, ItemID, nCurAvatarID)
        end
      end
    end
  end
end
function VehicleAvatarComponent:BP_PostChangeItemAvatar()
  local vehicleItemId = self:GetOwner() and self:GetOwner().ClientUsedAvatarID
  print(bWriteLog and "VehicleAvatarComponent BP_PostChangeItemAvatar" .. tostring(vehicleItemId))
  if vehicleItemId and vehicleItemId == self.NetHighTireStruct.ItemID then
    self:EnableHighTireLight(self.NetHighTireStruct.bEnableHighTire, vehicleItemId)
  end
  if Client then
    self:UpdateIsFppScope(self.isFppScope)
    local VehicleActor = self:GetOwner()
    EventSystem:postEvent(EVENTTYPE_INGAME_NORMAL, EVENTID_INGAME_AIRCRAFT_VEHICLE_MESH_APPLIED, VehicleActor)
  end
end
function VehicleAvatarComponent:PreChangeHighTireLight(ItemID, bEnableHighTire)
  print(bWriteLog and "VehicleAvatarComponent PreChangeHighTireLight ItemID:" .. tostring(ItemID) .. " bEnableHighTire:" .. tostring(bEnableHighTire))
  self.NetHighTireStruct.  self.NetHighTireStruct.  self:EnableHighTireLight(self.NetHighTireStruct.bEnableHighTire)
end
function VehicleAvatarComponent:BP_ChangeItemAvatar(InItemID)
  if self:GetOwner() and self:GetOwner():HasAuthority() and self:GetOwner().GetDirverOrOwner then
    local Pawn = self:GetOwner():GetDirverOrOwner()
    if slua.isValid(Pawn) then
      local VehiclePlateLicenseUtil = require("GameLua.Activity.Commercialize.GamePlay.Vehicle.VehiclePlateLicenseUtil")
      self.NetHighTireStruct.bEnableHighTire = VehiclePlateLicenseUtil.NeedOpenHighTire(Pawn.PlayerUID, InItemID)
      self.NetHighTireStruct.ItemID = InItemID
    end
  end
end
function VehicleAvatarComponent:LuaCollectAsyncResWithHandleLoad(InItemID, bIsFpp)
  log(bWriteLog and "VehicleAvatarComponent:LuaCollectAsyncResWithHandleLoad InItemID:" .. tostring(InItemID) .. " bIsFpp:" .. tostring(bIsFpp))
  local SoftObjectPath = import("/Script/CoreUObject.SoftObjectPath")
  local SoftObjectPathArray = slua.Array(UEnums.EPropertyClass.Struct, SoftObjectPath)
  if not bIsFpp then
    local VehiclePlateLicenseUtil = require("GameLua.Activity.Commercialize.GamePlay.Vehicle.VehiclePlateLicenseUtil")
    local VehicleEffectCSVPaths = VehiclePlateLicenseUtil.GetVehicleEffectCSVPaths()
    local UKismetSystemLibrary = import("KismetSystemLibrary")
    for _, csvPath in ipairs(VehicleEffectCSVPaths) do
      SoftObjectPathArray:Add(UKismetSystemLibrary.MakeSoftObjectPath(csvPath))
    end
  end
  return SoftObjectPathArray
end
function VehicleAvatarComponent:LuaCollectAsyncRes(InItemID)
  log(bWriteLog and "VehicleAvatarComponent:LuaCollectAsyncResWithHandleLoad InItemID:" .. tostring(InItemID))
  local SoftObjectPath = import("/Script/CoreUObject.SoftObjectPath")
  local SoftObjectPathArray = slua.Array(UEnums.EPropertyClass.Struct, SoftObjectPath)
  if not InItemID then
    log(bWriteLog and "VehicleAvatarComponent:LuaCollectAsyncResWithHandleLoad SoftObjectPathArray is nil")
    return SoftObjectPathArray
  end
  SoftObjectPathArray = self:GetSwitchEffectLoadSoftPath(SoftObjectPathArray, InItemID, self.lastEquipedAvatarId)
  return SoftObjectPathArray
end
function VehicleAvatarComponent:CheckAndShowVehicleSwitchEffect()
  local ret = self:ShowVehicleSwitchEffect()
  self.uOldVehicleMeshAnimClass = nil
  local vehicleActor = self:GetOwner()
  if slua.isValid(vehicleActor) then
    self:RefreshLastEquipedAvatarId(vehicleActor.ClientUsedAvatarID)
  end
  if not ret then
    self:OnVehicleSwitchEffectFinished()
  end
end
function VehicleAvatarComponent:ShowVehicleSwitchEffect()
  log(bWriteLog and "VehicleAvatarComponent:ShowVehicleSwitchEffect self.curSwitchEffectId:" .. tostring(self.curSwitchEffectId) .. "lastEquipedAvatarId:" .. tostring(self.lastEquipedAvatarId))
  if not self.curSwitchEffectId or self.curSwitchEffectId <= 0 then
    return false
  end
  local vehicleActor = self:GetOwner()
  if not slua.isValid(vehicleActor) then
    return false
  end
  if self.uSwitchEffectActor then
    self:StopSkinSwitchEffect()
    self.uSwitchEffectActor = nil
  end
  log(bWriteLog and "VehicleAvatarComponent:ShowVehicleSwitchEffect curVehicleId:" .. tostring(vehicleActor.ClientUsedAvatarID))
  if not vehicleActor.ClientUsedAvatarID then
    return false
  end
  local bIsLobbyActor = self:IsLobbyActor()
  if bIsLobbyActor then
    local PufferConst = require("client.slua.logic.download.puffer_const")
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {
      vehicleActor.ClientUsedAvatarID
    })
    if state ~= PufferConst.ENUM_DownloadState.Done then
      log(bWriteLog and "VehicleAvatarComponent:ShowVehicleSwitchEffect not DownLoad Vehicle 1")
      return false
    end
  elseif not self:IsAssetsAlreadyAvailable(vehicleActor.ClientUsedAvatarID) then
    log(bWriteLog and "VehicleAvatarComponent:ShowVehicleSwitchEffect not DownLoad Vehicle 2")
    return false
  end
  if not self.lastEquipedAvatarId or self.lastEquipedAvatarId <= 0 then
    log(bWriteLog and "VehicleAvatarComponent:ShowVehicleSwitchEffect lastEquipedAvatarId is invalid")
    return false
  end
  if not self:CheckCanPlaySkinSwitchEffect(vehicleActor.ClientUsedAvatarID, self.lastEquipedAvatarId) then
    log(bWriteLog and "VehicleAvatarComponent:ShowVehicleSwitchEffect CheckCanPlaySkinSwitchEffect false")
    return false
  end
  local world = slua_GameFrontendHUD:GetWorld()
  local VehiclePlateLicenseUtil = require("GameLua.Activity.Commercialize.GamePlay.Vehicle.VehiclePlateLicenseUtil")
  local SkinSwitchEffectActorPath = VehiclePlateLicenseUtil.GetSwitchEffectActorPath()
  local BP_DissolveVehicleClass = import(SkinSwitchEffectActorPath)
  self.uSwitchEffectActor = world:SpawnActor(BP_DissolveVehicleClass, nil, nil, nil)
  if not slua.isValid(self.uSwitchEffectActor) then
    self.uSwitchEffectActor = nil
    log(bWriteLog and "VehicleAvatarComponent:ShowVehicleSwitchEffect uSwitchEffectActor is nil")
    return false
  end
  self.uSwitchEffectActor:K2_AttachToActor(vehicleActor, "None", 1, 1, 1, false)
  self.uSwitchEffectActor:K2_SetActorRelativeLocation(FVector(0, 0, 0), false, nil, false)
  self.uSwitchEffectActor:K2_SetActorRelativeRotation(FRotator(0, 0, 0), false, nil, false)
  self:HideParticles()
  self:ChangeFakeSwitchVehicleAvatar(self.uSwitchEffectActor.Mesh, self.lastEquipedAvatarId)
  self.uSwitchEffectActor:SetAnimInsAndAnimState(self.uOldVehicleMeshAnimClass, vehicleActor)
  self.uSwitchEffectActor:StartVehicleSwitchEffect(vehicleActor, self.curSwitchEffectId, self.lastEquipedAvatarId, vehicleActor.ClientUsedAvatarID, bIsLobbyActor)
  self.uOldVehicleMeshAnimClass = nil
  return true
end
function VehicleAvatarComponent:OnVehicleSwitchEffectFinished(bHasPlayEffect)
  log(bWriteLog and "VehicleAvatarComponent:OnVehicleSwitchEffectFinished bHasPlayEffect:" .. tostring(bHasPlayEffect))
  if bHasPlayEffect then
    self.uSwitchEffectActor = nil
    local vehicleActor = self:GetOwner()
    if slua.isValid(vehicleActor) then
      local vehicleMesh
      if vehicleActor.GetMesh then
        vehicleMesh = vehicleActor:GetMesh()
      else
        vehicleMesh = vehicleActor.Mesh
      end
      if slua.isValid(vehicleMesh) then
        vehicleMesh:SetDrawStyle(0)
      end
    end
  end
  self:RecoverParticles()
  if self.OnVehicleSwitchEffectEnd then
    self.OnVehicleSwitchEffectEnd:BroadCast()
  end
end
function VehicleAvatarComponent:StopSkinSwitchEffect()
  if not slua.isValid(self.uSwitchEffectActor) then
    return
  end
  log(bWriteLog and "VehicleAvatarComponent:StopSkinSwitchEffect")
  self.uSwitchEffectActor:StopSwitchEffect()
end
function VehicleAvatarComponent:CheckCanPlaySkinSwitchEffect(curVehicleId, lastVehicleId)
  log(bWriteLog and "VehicleAvatarComponent:CheckCanPlaySkinSwitchEffect lastVehicleId:" .. tostring(lastVehicleId) .. " curVehicleId:" .. tostring(curVehicleId))
  if not (curVehicleId and curVehicleId ~= 0 and lastVehicleId) or lastVehicleId == 0 then
    return false
  end
  if curVehicleId == lastVehicleId then
    return false
  end
  local VehiclePlateLicenseUtil = require("GameLua.Activity.Commercialize.GamePlay.Vehicle.VehiclePlateLicenseUtil")
  if not VehiclePlateLicenseUtil.CheckIsBetterVehicle(curVehicleId, false) then
    log(bWriteLog and "VehicleAvatarComponent:CheckCanPlaySkinSwitchEffect CheckIsBetterVehicle 2 false")
    return false
  end
  local bIsLobbyActor = self:IsLobbyActor()
  if bIsLobbyActor then
    local ret = VehiclePlateLicenseUtil.CheckIsBetterVehicle(lastVehicleId, true)
    log(bWriteLog and "VehicleAvatarComponent:CheckCanPlaySkinSwitchEffect bIsLobbyActor ret:" .. tostring(ret))
    return ret
  end
  local defaultAvatarId = self:GetDefaultAvatarID()
  if defaultAvatarId and defaultAvatarId == lastVehicleId then
    log(bWriteLog and "VehicleAvatarComponent:CheckCanPlaySkinSwitchEffect bLastVehicleDefault true")
    return true
  end
  if not VehiclePlateLicenseUtil.CheckIsBetterVehicle(lastVehicleId, true) then
    log(bWriteLog and "VehicleAvatarComponent:CheckCanPlaySkinSwitchEffect CheckIsBetterVehicle 1 false")
    return false
  end
  return true
end
function VehicleAvatarComponent:RefreshLastEquipedAvatarId(lastVehicleId)
  log(bWriteLog and "VehicleAvatarComponent:RefreshLastEquipedAvatarId lastVehicleId:" .. tostring(lastVehicleId))
  if not lastVehicleId or lastVehicleId <= 0 then
    self.lastEquipedAvatarId = 0
    return
  end
  if self:IsLobbyActor() then
    self.lastEquipedAvatarId = lastVehicleId
    return
  end
  local nTargetAvatarID = lastVehicleId
  if not self:IsAssetsAlreadyAvailable(nTargetAvatarID) then
    log(bWriteLog and "VehicleAvatarComponent:RefreshLastEquipedAvatarId IsAssetsAlreadyAvailable false")
    nTargetAvatarID = self:GetDefaultAvatarID()
  end
  log(bWriteLog and "VehicleAvatarComponent:RefreshLastEquipedAvatarId lastEquipedAvatarId:" .. tostring(nTargetAvatarID))
  self.lastEquipedAvatarId = nTargetAvatarID or 0
end
function VehicleAvatarComponent:SetSwitchEffectPreviewData(switchEffectId, lastVehicleId)
  log(bWriteLog and "VehicleAvatarComponent:SetSwitchEffectPreviewData switchEffectId:" .. tostring(switchEffectId) .. ", lastVehicleId:" .. tostring(lastVehicleId))
  self.lastEquipedAvatarId = lastVehicleId or 0
  self.curSwitchEffectId = switchEffectId or 0
end
function VehicleAvatarComponent:GetSwitchEffectLoadSoftPath(SoftObjectPathArray, newAvatarId, oldAvatarId)
  log(bWriteLog and "VehicleAvatarComponent:BPGetSwitchEffectLoadSoftPath")
  if not SoftObjectPathArray then
    return nil
  end
  if not self.curSwitchEffectId or self.curSwitchEffectId <= 0 then
    log(bWriteLog and "VehicleAvatarComponent:BPGetSwitchEffectLoadSoftPath curSwitchEffectId is invalid")
    return SoftObjectPathArray
  end
  if not (newAvatarId and not (newAvatarId <= 0) and oldAvatarId) or oldAvatarId <= 0 then
    log(bWriteLog and "VehicleAvatarComponent:BPGetSwitchEffectLoadSoftPath param is invalid")
    return SoftObjectPathArray
  end
  if not self:CheckCanPlaySkinSwitchEffect(newAvatarId, oldAvatarId) then
    return SoftObjectPathArray
  end
  local VehiclePlateLicenseUtil = require("GameLua.Activity.Commercialize.GamePlay.Vehicle.VehiclePlateLicenseUtil")
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  local resList = VehiclePlateLicenseUtil.GetSportsCarDissolveMatPathList(newAvatarId, oldAvatarId)
  if resList and #resList then
    for _, resPath in ipairs(resList) do
      SoftObjectPathArray:Add(UKismetSystemLibrary.MakeSoftObjectPath(resPath))
    end
  end
  local SwitchNoiseTexturePath = VehiclePlateLicenseUtil.GetSwitchEffectNoiseTexturePath()
  local SwitchNoiseTexSoftObjPath = UKismetSystemLibrary.MakeSoftObjectPath(SwitchNoiseTexturePath)
  SoftObjectPathArray:Add(SwitchNoiseTexSoftObjPath)
  return SoftObjectPathArray
end
function VehicleAvatarComponent:CheckIsPlayingEffectSwitch()
  local bIsPlaying = slua.isValid(self.uSwitchEffectActor)
  log(bWriteLog and "VehicleAvatarComponent:CheckIsPlayingEffectSwitch bIsPlaying:" .. tostring(bIsPlaying))
  return bIsPlaying
end
function VehicleAvatarComponent:CollectVehicleMeshMaterials()
  self.Super:CollectVehicleMeshMaterials()
  log(bWriteLog and "VehicleAvatarComponent:CollectVehicleMeshMaterials")
  if self.curSwitchEffectId <= 0 or 0 >= self.lastEquipedAvatarId then
    log(bWriteLog and "VehicleAvatarComponent:CollectVehicleMeshMaterials self.curSwitchEffectId <= 0 or self.lastEquipedAvatarId <= 0")
    return
  end
  if self:IsLobbyActor() then
    log(bWriteLog and "VehicleAvatarComponent:CollectVehicleMeshMaterials IsLobbyActor")
    return
  end
  if not slua.isValid(self.ItemBodyMesh) then
    log(bWriteLog and "VehicleAvatarComponent EnableHighTireLight self.ItemBodyMesh is not Valid")
    return
  end
  local curMeshAnimIns = self.ItemBodyMesh:GetAnimInstance()
  if not slua.isValid(curMeshAnimIns) then
    log(bWriteLog and "VehicleAvatarComponent EnableHighTireLight self.ItemBodyMesh is not Valid")
    return
  end
  self.uOldVehicleMeshAnimClass = curMeshAnimIns:GetClass()
end
function VehicleAvatarComponent:GetCurItemAvatarID()
  return self.VehicleNetAvatarData.ItemDefineID.TypeSpecificID
end
function VehicleAvatarComponent:GetSkinOwnerUID()
  return self.VehicleNetAvatarData.SkinOwnerUID
end
function VehicleAvatarComponent:GetItemAvatarHandlePath(ItemID)
  local model_util = require("client.common.model_util")
  local BPID = model_util.GetBPID(ItemID)
  print(bWriteLog and "VehicleAvatarComponent:GetItemAvatarHandlePath", ItemID, BPID)
  if BPID < 0 then
    return
  end
  local Path = model_util.GetPath("Vehicle", BPID, self:IsLobbyAvatar(), false)
  local UBackpackUtils = import("BackpackUtils")
  local bPathExist = UBackpackUtils.IsBattleItemHandlePathExist(Path)
  print(bWriteLog and "VehicleAvatarComponent:GetItemAvatarHandlePath", Path, bPathExist)
  if not bPathExist then
    Path = model_util.GetPath("Vehicle", BPID, false, false)
  end
  local hardCode_1903218 = ItemID == 1903218 and string.find(tostring(Client.GetCurrentRHILevel(GameFrontendHUD)), "ES2")
  if hardCode_1903218 then
    local LobbyPath = "/Game/Res/IG4100/Arts_Player/Vehicle/VehicleAvatar/SportsCar25_int_13_D_ES2.SportsCar25_int_13_D_ES2_C"
    local BattlePath = "/Game/Res/IG4100/Arts_Player/Vehicle/VehicleAvatar/SportsCar25_int_13_ES2.SportsCar25_int_13_ES2_C"
    if self:IsLobbyAvatar() and UBackpackUtils.IsBattleItemHandlePathExist(LobbyPath) then
      log(bWriteLog and "VehicleAvatarComponent:GetItemAvatarHandlePath hardCode_1903218 lobby")
      return LobbyPath
    elseif UBackpackUtils.IsBattleItemHandlePathExist(BattlePath) then
      log(bWriteLog and "VehicleAvatarComponent:GetItemAvatarHandlePath hardCode_1903218 battle")
      return BattlePath
    else
      log(bWriteLog and "VehicleAvatarComponent:GetItemAvatarHandlePath hardCode_1903218 handle not found")
    end
  end
  return Path
end
function VehicleAvatarComponent:GetItemAvatarHandle(ItemID)
  local model_util = require("client.common.model_util")
  local BPID = model_util.GetBPID(ItemID)
  if BPID < 0 then
    return
  end
  local BackpackUtils = import("BackpackUtils")
  local HandleClass = BackpackUtils.GetBattleItemHandleIfPakExist("Vehicle", BPID, self:IsLobbyAvatar(), false)
  if not model_util.IsChildOfBattleItemHandleBase(HandleClass) and self:IsLobbyAvatar() then
    HandleClass = BackpackUtils.GetBattleItemHandleIfPakExist("Vehicle", BPID, false, false)
  end
  local hardCode_1903218 = ItemID == 1903218 and string.find(tostring(Client.GetCurrentRHILevel(GameFrontendHUD)), "ES2")
  if hardCode_1903218 then
    local LobbyPath = "/Game/Res/IG4100/Arts_Player/Vehicle/VehicleAvatar/SportsCar25_int_13_D_ES2.SportsCar25_int_13_D_ES2_C"
    local BattlePath = "/Game/Res/IG4100/Arts_Player/Vehicle/VehicleAvatar/SportsCar25_int_13_ES2.SportsCar25_int_13_ES2_C"
    if self:IsLobbyAvatar() and BackpackUtils.IsBattleItemHandlePathExist(LobbyPath) then
      local LobbyClass = import(LobbyPath)
      if model_util.IsChildOfBattleItemHandleBase(LobbyClass) then
        log(bWriteLog and "VehicleAvatarComponent:GetItemAvatarHandle hardCode_1903218 lobby")
        HandleClass = LobbyClass
      end
    elseif BackpackUtils.IsBattleItemHandlePathExist(BattlePath) then
      local BattleClass = import(BattlePath)
      if model_util.IsChildOfBattleItemHandleBase(BattleClass) then
        log(bWriteLog and "VehicleAvatarComponent:GetItemAvatarHandle hardCode_1903218 battle")
        HandleClass = BattleClass
      end
    else
      log(bWriteLog and "VehicleAvatarComponent:GetItemAvatarHandle hardCode_1903218 handle not found " .. tostring(self:IsLobbyAvatar()))
    end
  end
  if not HandleClass then
    log_error("VehicleAvatarComponent:GetItemAvatarHandlePath ItemID" .. tostring(ItemID) .. " HandleClass is nil")
    return
  end
  local ItemHandle = HandleClass()
  if not model_util.IsChildOfBackpackCommonAvatarHandle(ItemHandle) then
    log_warning("VehicleAvatarComponent:GetItemAvatarHandlePath ItemID" .. tostring(ItemID) .. " ItemHandle Cast to backpackcommonavatarhandler failed")
    return
  end
  return ItemHandle
end
function VehicleAvatarComponent:LuaIsAssetsAlreadyAvailable(ItemID)
  local PufferOdpakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local bAlreadyDownload = PufferOdpakManager:GetStateByItemID(ItemID) == PufferConst.ENUM_DownloadState.Done
  log(bWriteLog and string.format("VehicleAvatarComponent:LuaIsAssetsAlreadyAvailable, ItemID:%s, bAlreadyDownload:%s", tostring(ItemID), tostring(bAlreadyDownload)))
  return bAlreadyDownload
end
function VehicleAvatarComponent:HideParticles()
  self:AddTimer(0, function()
    local Owner = self:GetOwner()
    if slua.isValid(Owner) then
      local ParticleComponentClass = import("/Script/Engine.ParticleSystemComponent")
      local Comps = Owner:GetComponentsByTag(ParticleComponentClass, "PermanentParticle")
      if Comps then
        for _, uParticleComp in pairs(Comps) do
          if slua.isValid(uParticleComp) then
            uParticleComp:SetVisibility(false, false)
          end
        end
      end
    end
  end)
end
function VehicleAvatarComponent:RecoverParticles()
  local Owner = self:GetOwner()
  if slua.isValid(Owner) then
    local bVisibleOwner = not Owner.bHidden
    local ParticleComponentClass = import("/Script/Engine.ParticleSystemComponent")
    local Comps = Owner:GetComponentsByTag(ParticleComponentClass, "PermanentParticle")
    if Comps then
      for _, uParticleComp in pairs(Comps) do
        if slua.isValid(uParticleComp) then
          uParticleComp:SetVisibility(bVisibleOwner, false)
        end
      end
    end
  end
end
local class = require("class")
local CActorComponentBase = require("GameLua.Mod.BaseMod.Common.Core.ActorComponentBase")
local CVehicleAvatarComponent = class(CActorComponentBase, nil, VehicleAvatarComponent)
return CVehicleAvatarComponent