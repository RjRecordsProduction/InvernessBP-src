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
local HighTireSubMeshTag = "VehiclePartSlot_2"
local HighTireSubMeshMatSlotName = "slot3"
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
  self:InitSunroofState()
end
function VehicleAvatarComponent:ReceiveEndPlay(EndReason, bClearTable)
  print(bWriteLog and "VehicleAvatarComponent:ReceiveEndPlay")
  self:CleanupSunroof()
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
  local bScopeIn = Character.IsLocalActuallyScopeIn and true or false
  self:UpdateIsFppScope(bScopeIn)
  self:SetVehicleAccessoriesHiddenOnScope(bScopeIn)
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
  self:SetVehicleAccessoriesHiddenOnScope(false)
  self:SetClothParticleActive(Character, true)
end
function VehicleAvatarComponent:OnHandleScopeInDelegate(isBegin)
  if isBegin then
    self:UpdateIsFppScope(true)
    self:SetVehicleAccessoriesHiddenOnScope(true)
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
  self:SetVehicleAccessoriesHiddenOnScope(false)
end
function VehicleAvatarComponent:SetVehicleAccessoriesHiddenOnScope(bInScope)
  log(bWriteLog and "VehicleAvatarComponent:SetVehicleAccessoriesHiddenOnScope bInScope:" .. tostring(bInScope))
  local vehicle = self:GetOwner()
  if not slua.isValid(vehicle) or not vehicle.GetLicenseComponent then
    return
  end
  local licenseComp = vehicle:GetLicenseComponent()
  if slua.isValid(licenseComp) and licenseComp.SetAccessoriesHiddenOnScope then
    licenseComp:SetAccessoriesHiddenOnScope(bInScope)
  end
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
  vehicleId = vehicleId or self:GetCurItemAvatarID()
  local CollectCarHighTireCfg = CDataTable.GetTableData("CollectCarHighTire", vehicleId)
  if not CollectCarHighTireCfg then
    log(bWriteLog and "VehicleAvatarComponent EnableHighTireLight CollectCarHighTire Can`t find ItemID" .. tostring(vehicleId))
    return
  end
  local HighLightParam = "HubLight"
  if vehicleId == 1903212 or vehicleId == 1915018 then
    HighLightParam = "HuxiTintInt"
  end
  print(bWriteLog and "[tire]VehicleAvatarComponent EnableHighTireLight", vehicleId, HighLightParam)
  self:ApplyHighTireLightOnMesh(self.ItemBodyMesh, HighTireMatSlotName, bEnable, HighLightParam, "BodyMesh")
  self:ApplyHighTireLightOnSubMesh(bEnable, HighLightParam)
end
function VehicleAvatarComponent:ApplyHighTireLightOnMesh(MeshComp, SlotName, bEnable, HighLightParam, DebugTag)
  if not slua.isValid(MeshComp) then
    log(bWriteLog and "VehicleAvatarComponent ApplyHighTireLightOnMesh " .. (DebugTag or "") .. " MeshComp is not Valid")
    return
  end
  local MatIndex = MeshComp:GetMaterialIndex(SlotName)
  local Material = MeshComp:GetMaterial(MatIndex)
  if not Material then
    log(bWriteLog and "VehicleAvatarComponent ApplyHighTireLightOnMesh " .. (DebugTag or "") .. " Material is not Valid")
    return
  end
  local DynamicMat = MeshComp:CreateDynamicMaterialInstance(MatIndex, Material)
  if not DynamicMat then
    log(bWriteLog and "VehicleAvatarComponent ApplyHighTireLightOnMesh " .. (DebugTag or "") .. " DynamicMat is not Valid")
    return
  end
  if bEnable then
    DynamicMat:SetScalarParameterValue(HighLightParam, 5)
  else
    DynamicMat:SetScalarParameterValue(HighLightParam, 0)
  end
end
function VehicleAvatarComponent:ApplyHighTireLightOnSubMesh(bEnable, HighLightParam)
  local Owner = self:GetOwner()
  if not slua.isValid(Owner) then
    return
  end
  local SkeletalMeshComponentClass = import("SkeletalMeshComponent")
  local model_util = require("client.common.model_util")
  local SubMesh = model_util.GetComponentByTag(Owner, SkeletalMeshComponentClass, HighTireSubMeshTag)
  if not slua.isValid(SubMesh) then
    log(bWriteLog and "VehicleAvatarComponent ApplyHighTireLightOnSubMesh SubMesh(VehiclePartSlot_2) is not Valid")
    return
  end
  self:ApplyHighTireLightOnMesh(SubMesh, HighTireSubMeshMatSlotName, bEnable, HighLightParam, "SubMesh_VehiclePartSlot_2")
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
  self:SetSunroofNetState(ItemID, true)
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
function VehicleAvatarComponent:BP_GetMultiSlotEquipData(InSkinID)
  local data = self.NetMultiSlotData
  if not data then
    return {}
  end
  local slotArray = data.SlotDataArray
  if not slotArray then
    return {}
  end
  local result = {}
  local arrayLen = slotArray:Num()
  for i = 0, arrayLen - 1 do
    local entry = slotArray:Get(i)
    if entry and entry.ItemId and 0 < entry.ItemId then
      result[entry.Slot] = entry.ItemId
    end
  end
  return result
end
function VehicleAvatarComponent:SetLobbyMultiSlotEquipData(slotEquipMap)
  self._lobbySlotEquipMap = slotEquipMap
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
    self._bSunroofOpen = true
    self:TryInitSunroofMaterial(true)
  end
end
function VehicleAvatarComponent:PreChangeHighTireLight(ItemID, bEnableHighTire)
  print(bWriteLog and "VehicleAvatarComponent PreChangeHighTireLight ItemID:" .. tostring(ItemID) .. " bEnableHighTire:" .. tostring(bEnableHighTire))
  self.NetHighTireStruct.  self.NetHighTireStruct.  self:EnableHighTireLight(self.NetHighTireStruct.bEnableHighTire)
end
function VehicleAvatarComponent:BP_ChangeItemAvatar(InItemID)
  if self:GetOwner() and self:GetOwner():HasAuthority() then
    local playerUID
    if self:GetOwner().GetDirverOrOwner then
      local Pawn = self:GetOwner():GetDirverOrOwner()
      if slua.isValid(Pawn) then
        playerUID = Pawn.PlayerUID
        local VehiclePlateLicenseUtil = require("GameLua.Activity.Commercialize.GamePlay.Vehicle.VehiclePlateLicenseUtil")
        self.NetHighTireStruct.bEnableHighTire = VehiclePlateLicenseUtil.NeedOpenHighTire(playerUID, InItemID)
        self.NetHighTireStruct.ItemID = InItemID
      end
    end
    if not playerUID or playerUID == "" then
      playerUID = self.VehicleNetAvatarData and self.VehicleNetAvatarData.SkinOwnerUID
    end
    if playerUID and playerUID ~= "" then
      self:SyncMultiSlotDataOnAvatarChange(playerUID, InItemID)
    end
  end
end
function VehicleAvatarComponent:SyncMultiSlotDataOnAvatarChange(playerUID, vehicleItemId)
  local ExtendAttribute = require("Server.config.ExtendAttribute")
  local PlayerDataMgr = require("Server.Data.ServerPlayerDataMgr")
  local VehicleFeatureTable = PlayerDataMgr.GetPlayerProgressFromServer(tonumber(playerUID), ExtendAttribute.VehicleExtendedFeatures)
  local SLOT_BRAKE_CALIPER = 1
  local SLOT_WHEEL_HUB = 2
  local SLOT_CANOPY = 3
  local slotEquipMap = {}
  if VehicleFeatureTable then
    local brakeInfo = VehicleFeatureTable.brake_caliper_info
    if brakeInfo and type(brakeInfo[vehicleItemId]) == "number" and 0 < brakeInfo[vehicleItemId] then
      slotEquipMap[SLOT_BRAKE_CALIPER] = brakeInfo[vehicleItemId]
    end
    local wheelInfo = VehicleFeatureTable.wheel_hub_info
    if wheelInfo and type(wheelInfo[vehicleItemId]) == "number" and 0 < wheelInfo[vehicleItemId] then
      slotEquipMap[SLOT_WHEEL_HUB] = wheelInfo[vehicleItemId]
    end
    local sunroofInfo = VehicleFeatureTable.sunroof_info
    if sunroofInfo and type(sunroofInfo[vehicleItemId]) == "number" and 0 < sunroofInfo[vehicleItemId] then
      slotEquipMap[SLOT_CANOPY] = sunroofInfo[vehicleItemId]
    end
  end
  local slotCount = 0
  for _ in pairs(slotEquipMap) do
    slotCount = slotCount + 1
  end
  print(bWriteLog and "VehicleAvatarComponent:SyncMultiSlotDataOnAvatarChange UID:" .. tostring(playerUID) .. " vehicleItemId:" .. tostring(vehicleItemId) .. " slotCount:" .. tostring(slotCount))
  self:SetNetMultiSlotData(slotEquipMap)
end
function VehicleAvatarComponent:BP_PreChangeItemAvatar(InItemID)
  local LogicVehicleExtendedFeature = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicVehicleExtendedFeature)
  local bEnable = false
  if LogicVehicleExtendedFeature then
    bEnable = LogicVehicleExtendedFeature:CheckVehicleSupportMultiSlot(InItemID)
  end
  self.bEnableMultiSlot = bEnable
  self._bSunroofOpen = true
  print(bWriteLog and "VehicleAvatarComponent:BP_PreChangeItemAvatar InItemID:" .. tostring(InItemID) .. " bEnableMultiSlot:" .. tostring(bEnable))
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
  local cachedSwitchEffectId = self.curSwitchEffectId
  local cachedEquippedAvatarId = self.lastEquipedAvatarId
  local OnFakeVehicleLoaded = function(bNeedResetActorHidden)
    self.uSwitchEffectActor:SetAnimInsAndAnimState(self.uOldVehicleMeshAnimClass, vehicleActor)
    if bNeedResetActorHidden then
      self.ItemBodyMesh:SetVisibility(true, false)
    end
    self.uSwitchEffectActor:StartVehicleSwitchEffect(vehicleActor, cachedSwitchEffectId, cachedEquippedAvatarId, vehicleActor.ClientUsedAvatarID, bIsLobbyActor)
    self.uOldVehicleMeshAnimClass = nil
  end
  if self.uSwitchEffectActor.VehicleAvatarComponent_BP then
    log(bWriteLog and "VehicleAvatarComponent:ShowVehicleSwitchEffect PreChangeVehicleAvatar")
    self:ChangeFakeSwitchVehicleAvatar(self.uSwitchEffectActor.Mesh, self.lastEquipedAvatarId)
    self.ItemBodyMesh:SetVisibility(false, false)
    local lastEquipedAvatarId = self.lastEquipedAvatarId
    self.uSwitchEffectActor.VehicleAvatarComponent_BP:PreChangeVehicleAvatar(lastEquipedAvatarId)
    self:AddControlEvent(self.uSwitchEffectActor.VehicleAvatarComponent_BP, "VehicleAvatarEqiuped", OnFakeVehicleLoaded, true)
  else
    log(bWriteLog and "VehicleAvatarComponent:ShowVehicleSwitchEffect ChangeFakeSwitchVehicleAvatar")
    self:ChangeFakeSwitchVehicleAvatar(self.uSwitchEffectActor.Mesh, self.lastEquipedAvatarId)
    OnFakeVehicleLoaded()
  end
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
local SUNROOF_TICK_INTERVAL = 0.016
local SUNROOF_SLOT_CANOPY = 3
function VehicleAvatarComponent:GetSunroofConfig(ItemID)
  if not ItemID or ItemID <= 0 then
    return nil
  end
  return CDataTable.GetTableData("CanopyParamCfg", ItemID)
end
function VehicleAvatarComponent:IsSunroofSupported(ItemID)
  return self:GetSunroofConfig(ItemID) ~= nil
end
function VehicleAvatarComponent:ParseDependCanopyIDList(strList)
  local set = {}
  if type(strList) ~= "string" or strList == "" then
    return set
  end
  for idStr in string.gmatch(strList, "[^|]+") do
    local id = tonumber(idStr)
    if id then
      set[id] = true
    end
  end
  return set
end
local DefaultCanopyID = {
  [1908117] = 7305012,
  [1908118] = 7305011,
  [1908119] = 7305011
}
function VehicleAvatarComponent:IsDependCanopyEquipped(ItemID)
  local config = self:GetSunroofConfig(ItemID)
  if not config then
    return false
  end
  local dependSet = self:ParseDependCanopyIDList(config.DependCanopyIDList)
  if not next(dependSet) then
    return true
  end
  local slotEquipMap
  if self:IsLobbyActor() then
    slotEquipMap = self._lobbySlotEquipMap or {}
  else
    slotEquipMap = self:BP_GetMultiSlotEquipData(ItemID) or {}
  end
  local equippedCanopyID = slotEquipMap[SUNROOF_SLOT_CANOPY]
  if not equippedCanopyID or equippedCanopyID == 0 then
    equippedCanopyID = DefaultCanopyID[ItemID]
  end
  return equippedCanopyID ~= nil and dependSet[equippedCanopyID] == true
end
function VehicleAvatarComponent:InitSunroofState()
  self._sunroofSlotName = nil
  self._sunroofCurrentValue = 1.0
  self._sunroofTargetValue = 1.0
  self._sunroofLerpSpeed = 0.0
  self._sunroofIsLerping = false
  self._sunroofTimerHandle = nil
  self._sunroofConfig = nil
  self._bSunroofOpen = false
  self._lobbySlotEquipMap = nil
end
function VehicleAvatarComponent:TryInitSunroofMaterial(bImmediately)
  local vehicleItemId = self:GetOwner() and self:GetOwner().ClientUsedAvatarID
  if not vehicleItemId then
    return
  end
  if not self:IsDependCanopyEquipped(vehicleItemId) then
    self:CleanupSunroof()
    return
  end
  local config = self:GetSunroofConfig(vehicleItemId)
  if not config then
    self:CleanupSunroof()
    return
  end
  self._sunroofConfig = config
  local meshComp = self.ItemBodyMesh
  if not slua.isValid(meshComp) then
    log(bWriteLog and "VehicleAvatarComponent:TryInitSunroofMaterial - MeshComp invalid")
    return
  end
  local matIndex = meshComp:GetMaterialIndex(config.SlotName)
  if matIndex < 0 then
    log(bWriteLog and "VehicleAvatarComponent:TryInitSunroofMaterial - SlotName not found: " .. tostring(config.SlotName))
    return
  end
  self._sunroofSlotName = config.SlotName
  local OpenValue = config.OpenValue_f or 0.7
  self._sunroofCurrentValue = OpenValue
  local currentMat = meshComp:GetMaterial(matIndex)
  if slua.isValid(currentMat) then
    if not currentMat.SetScalarParameterValue then
      currentMat = meshComp:CreateDynamicMaterialInstance(matIndex, currentMat)
    end
    currentMat:SetScalarParameterValue(config.ParamName, self._sunroofCurrentValue)
  end
  print(bWriteLog and "VehicleAvatarComponent:TryInitSunroofMaterial - Success, SlotName:" .. config.SlotName .. ", matIndex:" .. tostring(matIndex) .. " _sunroofCurrentValue" .. tostring(self._sunroofCurrentValue))
  if self.NetSunroofStruct and self.NetSunroofStruct.ItemID == vehicleItemId then
    self:ApplySunroofState(self.NetSunroofStruct.bSunroofOpen, self.NetSunroofStruct.ItemID, bImmediately)
  end
end
function VehicleAvatarComponent:ApplySunroofState(bOpen, vehicleItemId, bImmediately)
  local bLobby = self:IsLobbyActor()
  vehicleItemId = vehicleItemId or self:GetOwner() and self:GetOwner().ClientUsedAvatarID
  if bLobby and (not self._sunroofConfig or not self._sunroofSlotName) then
    self:TryInitSunroofMaterial(bImmediately)
  end
  if not self._sunroofConfig or not self._sunroofSlotName then
    return
  end
  if not self:IsDependCanopyEquipped(vehicleItemId) then
    return
  end
  self._bSunroofOpen = bOpen
  self._curSunroofVehicleId = vehicleItemId
  local config = self._sunroofConfig
  local openValue = config.OpenValue_f or 0.7
  local closeValue = config.CloseValue_f or 2.0
  local targetValue = bOpen and openValue or closeValue
  local duration = 0.01
  if not bImmediately then
    duration = config.SwitchDuration or 0.5
  end
  self:LerpSunroofOpacity(targetValue, duration)
end
function VehicleAvatarComponent:IsSunroofOpen()
  if not self._bSunroofOpen then
    return false
  end
  return true
end
function VehicleAvatarComponent:LerpSunroofOpacity(targetValue, duration)
  if targetValue == 1 then
    targetValue = 1.5
  end
  self._sunroofTargetValue = targetValue
  local distance = math.abs(self._sunroofTargetValue - self._sunroofCurrentValue)
  if distance < 0.001 then
    return
  end
  self._sunroofLerpSpeed = distance / math.max(duration, 0.01)
  self._sunroofIsLerping = true
  if not self._sunroofTimerHandle then
    self._sunroofTimerHandle = self:AddTimerLoop(0, function(deltaTime)
      self:TickSunroofLerp(deltaTime)
    end, TIMER_INFINITE, SUNROOF_TICK_INTERVAL)
  end
end
function VehicleAvatarComponent:TickSunroofLerp(deltaTime)
  if not self._sunroofIsLerping then
    return
  end
  local meshComp = self.ItemBodyMesh
  if not slua.isValid(meshComp) then
    self:StopSunroofLerp()
    return
  end
  local matIndex = meshComp:GetMaterialIndex(self._sunroofSlotName)
  if matIndex < 0 then
    self:StopSunroofLerp()
    return
  end
  local currentMat = meshComp:GetMaterial(matIndex)
  if not slua.isValid(currentMat) or not currentMat.SetScalarParameterValue then
    self:StopSunroofLerp()
    return
  end
  local direction = self._sunroofTargetValue > self._sunroofCurrentValue and 1 or -1
  self._sunroofCurrentValue = self._sunroofCurrentValue + direction * self._sunroofLerpSpeed * deltaTime
  if 0 < direction then
    self._sunroofCurrentValue = math.min(self._sunroofCurrentValue, self._sunroofTargetValue)
  else
    self._sunroofCurrentValue = math.max(self._sunroofCurrentValue, self._sunroofTargetValue)
  end
  log(bWriteLog and "VehicleAvatarComponent:TickSunroofLerp self._sunroofCurrentValue: " .. tostring(self._sunroofCurrentValue))
  currentMat:SetScalarParameterValue(self._sunroofConfig.ParamName, self._sunroofCurrentValue)
  if math.abs(self._sunroofCurrentValue - self._sunroofTargetValue) < 0.001 then
    self._sunroofCurrentValue = self._sunroofTargetValue
    currentMat:SetScalarParameterValue(self._sunroofConfig.ParamName, self._sunroofCurrentValue)
    self:StopSunroofLerp()
  end
end
function VehicleAvatarComponent:StopSunroofLerp()
  self._sunroofIsLerping = false
  if self._sunroofTimerHandle then
    self:RemoveTimer(self._sunroofTimerHandle)
    self._sunroofTimerHandle = nil
  end
end
function VehicleAvatarComponent:CleanupSunroof()
  self:StopSunroofLerp()
  self._sunroofSlotName = nil
  self._sunroofConfig = nil
  self._sunroofCurrentValue = 1.0
  self._sunroofTargetValue = 1.0
  self._bSunroofOpen = true
end
function VehicleAvatarComponent:SetSunroofNetState(vehicleItemId, bSunroofOpen)
  if not self:IsSunroofSupported(vehicleItemId) then
    return
  end
  print(bWriteLog and "VehicleAvatarComponent:SetSunroofNetState ItemID:" .. tostring(vehicleItemId) .. " bOpen:" .. tostring(bSunroofOpen))
  self.NetSunroofStruct.ItemID = vehicleItemId
  self.NetSunroofStruct.end
function VehicleAvatarComponent:OnRep_NetSunroofChanged()
  local vehicleItemId = self:GetOwner() and self:GetOwner().ClientUsedAvatarID
  print(bWriteLog and "VehicleAvatarComponent:OnRep_NetSunroofChanged vehicleItemId:" .. tostring(vehicleItemId))
  if not vehicleItemId or vehicleItemId ~= self.NetSunroofStruct.ItemID then
    return
  end
  if self._bSunroofOpen == self.NetSunroofStruct.bSunroofOpen then
    print(bWriteLog and "VehicleAvatarComponent:OnRep_NetSunroofChanged - already in target state, skip")
    return
  end
  self._bSunroofOpen = self.NetSunroofStruct.bSunroofOpen
  if not self._sunroofSlotName then
    print(bWriteLog and "VehicleAvatarComponent:OnRep_NetSunroofChanged - matIndex not ready, defer to PostChangeItemAvatar")
    return
  end
  self:ApplySunroofState(self.NetSunroofStruct.bSunroofOpen, self.NetSunroofStruct.ItemID)
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