local LobbyVehicle = {}
function LobbyVehicle:ctor(selfType)
  self.IsHallVehicle = false
  self.ChangeLightTimer = nil
  self.bIsProhibitOpenDoorAnim = false
  self.InitAnimTimer = nil
  self.VehicleFXMap = {}
  self.VehicleFXTimers = {}
  self.PreviewSwitchEffectData = nil
  self.ClientUsedAvatarID = nil
  self.curPlayingAccSoundId = nil
  self.PreviewSwitchAssetHandleId = nil
  self.VehicleMatData = {}
  self.VehicleMatTickTimer = nil
  self.MatTickTime = 0
  self.MatTickEndTime = 5
  self.bSetOnlyTickPoseWhenRendered = false
end
function LobbyVehicle:ReceiveBeginPlay()
  LobbyVehicle.__super.ReceiveBeginPlay(self)
  print(bWriteLog and "LobbyVehicle:ReceiveBeginPlay")
  if slua.isValid(self.VehicleAvatarComponent_BP) then
    self:AddControlEvent(self.VehicleAvatarComponent_BP, "VehicleAvatarEqiuped", self.OnVehicleAvatarEquiped, self)
    self:AddControlEvent(self.VehicleAvatarComponent_BP, "OnVehicleSwitchEffectEnd", self.OnVehicleSwitchEffectEnd, self)
  end
  self:AddCommonEvent(EVENTTYPE_LOBBY_SCENE, EVENTID_SCENE_LOADED, self.OnSceneLoaded, self)
end
function LobbyVehicle:ReceiveEndPlay(EndReason, bClearTable)
  log(bWriteLog and "LobbyVehicle:ReceiveEndPlay")
  for k, _ in pairs(self.VehicleFXMap) do
    self:StopVehicleEffect(k)
  end
  self.VehicleFXTimers = nil
  self:CancelSwitchAssetLoadHandle()
  LobbyVehicle.__super.ReceiveEndPlay(self, EndReason, bClearTable)
end
function LobbyVehicle:OnVehicleAvatarEquiped()
  log(bWriteLog and "LobbyVehicle OnVehicleAvatarEquiped")
  self:CleanAavatarShowEffects()
  EventSystem:postEvent(EVENTTYPE_STORE_BTNEVENT, EVENTID_STORE_CAR_MODEL_LOADED)
  if not slua.isValid(self.VehicleAvatarComponent_BP) then
    return
  end
  if self.ChangeLightTimer then
    self:RemoveTimer(self.ChangeLightTimer)
    self.ChangeLightTimer = nil
  end
  local CurSkinID = self.VehicleAvatarComponent_BP:GetCurItemAvatarID()
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {CurSkinID})
  if state ~= PufferConst.ENUM_DownloadState.Done then
    log(bWriteLog and "LobbyVehicle:OnVehicleAvatarEquiped not DownLoad Vehicle")
    return
  end
  self.ClientUsedAvatarID = CurSkinID
  log(bWriteLog and "LobbyVehicle:OnVehicleMeshAvatarEquiped CurSkinID:" .. tostring(CurSkinID))
  if CurSkinID == 1908077 and slua.isValid(self.Mesh) and not self.VehicleAvatarComponent_BP.bIsLobbyAvatar then
    log(bWriteLog and "LobbyVehicle OnVehicleAvatarEquiped Custom light")
    local materials = self.Mesh:GetMaterials()
    for k_material, v_material in pairs(materials) do
      if slua.isValid(v_material) then
        local dynamicMaterial = self.Mesh:CreateDynamicMaterialInstance(k_material, v_material)
        if slua.isValid(dynamicMaterial) then
          dynamicMaterial:SetScalarParameterValue("UseCustomLightVec", 1)
          dynamicMaterial:SetVectorParameterValue("CustomLightVec", FLinearColor(0, 0.2, 1.0, 0.0))
        end
      end
    end
  end
  local RacecarCfg = CDataTable.GetTableData("BetterVehicleEffect", CurSkinID)
  if RacecarCfg and RacecarCfg.MiniTVVehiclePhoto == 1 then
    log(bWriteLog and "LobbyVehicle OnVehicleAvatarEquiped ItemDI" .. tostring(CurSkinID))
    self.ChangeLightTimer = self:AddTimer(0.1, function()
      self:TurnOnLights()
      coroutine.yield(2)
      self:TurnOnLights()
    end)
  end
  local uLisenceComp = self.BP_Lobby_VehicleLicenseComponent
  if slua.isValid(uLisenceComp) then
    log(bWriteLog and "LobbyVehicle:OnVehicleMeshAvatarEquiped BP_Lobby_VehicleLicenseComponent")
    uLisenceComp:OnVehicleMeshAvatarEquiped(CurSkinID)
  end
  self:AddTimer(0.1, function()
    if not self.IsHallVehicle then
      return
    end
    self.VehicleAvatarComponent_BP:DestroyWelcomeLight()
  end)
  if self.PreviewSwitchEffectData then
    self:SetPreviewSwitchEffectData(self.PreviewSwitchEffectData.switchEffectId, self.PreviewSwitchEffectData.lastVehicleId, self.PreviewSwitchEffectData.newVehicleId)
  end
  if slua.isValid(self.BP_VehicleDIYComp) then
    self.BP_VehicleDIYComp:OnVehicleAvatarEquiped()
    return
  end
end
function LobbyVehicle:OnVehicleSwitchEffectEnd()
  if slua.isValid(self.BP_VehicleDIYComp) then
    self.BP_VehicleDIYComp:OnVehicleSwitchEffectEnd()
  end
end
function LobbyVehicle:TurnOnLights()
  local FrontLightMat = self:GetFrontLightDIM()
  if slua.isValid(FrontLightMat) then
    FrontLightMat:SetScalarParameterValue("FrontLight", 2.0)
  end
  local TailLightMat = self:GetTailLightDIM()
  if slua.isValid(TailLightMat) then
    TailLightMat:SetScalarParameterValue("BackLight", 2.0)
  end
end
function LobbyVehicle:OnSceneLoaded(_, _, LevelName)
  if not slua.isValid(self.VehicleAvatarComponent_BP) then
    return
  end
  if LevelName == nil or LevelName == "" then
    return
  end
  log(bWriteLog and "LobbyVehicle:OnSceneLoaded" .. LevelName)
  if string.find(LevelName, "light") or string.find(LevelName, "Light") then
    return
  end
  self:AddTimer(0.3, function()
    if not self.IsHallVehicle then
      return
    end
    self.VehicleAvatarComponent_BP:DestroyWelcomeLight()
  end)
end
function LobbyVehicle:Sleep()
  self:StopMontage()
  self:ClearLightEffect()
  self:CleanAavatarShowEffects()
  if slua.isValid(self.Mesh) then
    self.Mesh:SetCastPhotonShadow(false)
    self.Mesh:SetAnimInstanceClass(nil)
  end
end
function LobbyVehicle:StopMontage()
  if not slua.isValid(self.Mesh) then
    log(bWriteLog and "LobbyVehicle:Sleep self.Mesh is not Valid")
    return
  end
  local AnimIns = self.Mesh:GetAnimInstance()
  self.Mesh:SetSkeletalMesh(nil, true)
  if not slua.isValid(AnimIns) then
    log(bWriteLog and "LobbyVehicle:Sleep AnimIns is not Valid")
    return
  end
  local PlayingMontage = AnimIns:GetCurrentActiveMontage()
  if not slua.isValid(PlayingMontage) then
    log(bWriteLog and "LobbyVehicle:Sleep PlayingMontage is not Valid")
    return
  end
  AnimIns:Montage_Stop(0.0, PlayingMontage)
end
function LobbyVehicle:ClearLightEffect()
  if not slua.isValid(self.VehicleAvatarComponent_BP) then
    log(bWriteLog and "LobbyVehicle ClearLightEffect VehicleAvatarComponent_BP is not Valid")
    return
  end
  if not slua.isValid(self.VehicleAvatarComponent_BP.LightEffect) then
    log(bWriteLog and "LobbyVehicle ClearLightEffect VehicleAvatarComponent_BP.LightEffect is not Valid")
    return
  end
  self.VehicleAvatarComponent_BP.LightEffect:K2_DestroyComponent(self.VehicleAvatarComponent_BP.LightEffect)
  self.VehicleAvatarComponent_BP.LightEffect = nil
  self.VehicleAvatarComponent_BP.CurLightEffect = nil
  self.VehicleAvatarComponent_BP.HasLightEffect = false
end
function LobbyVehicle:CleanAavatarShowEffects()
  local uComponentClass = import("/Script/Engine.ParticleSystemComponent")
  if self.GetComponentsByTag then
    local uComponentArray = self:GetComponentsByTag(uComponentClass, "AvatarShow")
    for _, uComp in pairs(uComponentArray) do
      if slua.isValid(uComp) then
        uComp:K2_DestroyComponent(uComp)
      end
    end
  end
  self:StopAccelerateEffect()
end
function LobbyVehicle:PlayAccelerateEffect()
  log(bWriteLog and "LobbyVehicle:PlayAccelerateEffect ")
  if not self:CheckCanAccelerate() then
    log(bWriteLog and "Lobby_Vehicle:PlayAccelerateEffect Is In CD")
    return
  end
  local AnimIns = self.Mesh:GetAnimInstance()
  if slua.isValid(AnimIns) then
    if AnimIns.PlayAcSound then
      AnimIns:PlayAcSound()
    end
    if AnimIns.LobbyPlayAccelerateCloseDoorAnim then
      AnimIns:LobbyPlayAccelerateCloseDoorAnim()
    end
    self:PlayAccelerateSound()
  end
  local VehicleAccelerateConfig = require("client.logic.vehicle.VehicleAccelerateConfig")
  if self.ClientUsedAvatarID and VehicleAccelerateConfig[self.ClientUsedAvatarID] then
    local config = VehicleAccelerateConfig[self.ClientUsedAvatarID]
    if config.Effect then
      for _, effectCfg in pairs(config.Effect) do
        if not effectCfg.beginTime or effectCfg.beginTime == 0 then
          self:PlayVehicleEffect(effectCfg.Name, effectCfg.endTime)
        else
          self:StopVehicleEffect(effectCfg.Name)
          if self.VehicleFXTimers and self.VehicleFXTimers[effectCfg.Name] then
            self:RemoveTimer(self.VehicleFXTimers[effectCfg.Name])
          end
          self.VehicleFXTimers[effectCfg.Name] = self:AddTimer(effectCfg.beginTime, function()
            self:PlayVehicleEffect(effectCfg.Name, effectCfg.endTime - effectCfg.beginTime)
          end)
        end
      end
    end
    if config.MatConfig then
      self:StopTickVehicleMat()
      self.MatTickEndTime = config.EndTime or 5
      for _, MatConfig in pairs(config.MatConfig) do
        self:BeginTickVehicleMat(MatConfig)
      end
    end
    if slua.isValid(AnimIns) and AnimIns.LobbyPlayAccelerateAnim then
      AnimIns:LobbyPlayAccelerateAnim()
    end
  else
    self:PlayVehicleEffect("Exhaust", 3)
  end
end
function LobbyVehicle:StopAccelerateEffect()
  self:StopVehicleEffect("Exhaust")
  self:StopVehicleEffect("SpoilersTailInLift")
  self:StopTickVehicleMat()
end
function LobbyVehicle:PlayAccelerateSound()
  local AnimIns = self.Mesh:GetAnimInstance()
  if slua.isValid(AnimIns) then
    local AkGameplayStatics = import("AkGameplayStatics")
    if self.curPlayingAccSoundId then
      AkGameplayStatics.StopPlayingID(self.curPlayingAccSoundId)
      self.curPlayingAccSoundId = nil
    end
    if AnimIns.AccelerateSound then
      self.curPlayingAccSoundId = AkGameplayStatics.PostEvent(AnimIns.AccelerateSound, self.Object, true, "")
    end
  end
end
function LobbyVehicle:CheckCanAccelerate()
  local UIUtil = require("client.common.ui_util")
  if not UIUtil.CanClickNow(UIUtil.ModuleFrequencyLimit.LobbyVehicle) then
    return false
  end
  return true
end
function LobbyVehicle:SetLicensePlate(License, LicenseBgId, bEditingLicense)
  if not self.BP_Lobby_VehicleLicenseComponent then
    log(bWriteLog and "[LicensePlate] LobbyVehicle ChangePlate SetLicensePlate Can`t find BP_Lobby_VehicleLicenseComponent")
    return
  end
  local CurSkinID = self.VehicleAvatarComponent_BP:GetCurItemAvatarID()
  self.BP_Lobby_VehicleLicenseComponent:CreatPlate(CurSkinID, License, LicenseBgId, bEditingLicense)
end
function LobbyVehicle:PlayDoorAnim()
  self:PlayOpenDoorAnim()
end
function LobbyVehicle:GetNewVehilceMasterPath(VehicleSkinID)
  local VehicleRefitInfo = CDataTable.GetTableData("VehicleRefitInfo", VehicleSkinID)
  if not VehicleRefitInfo then
    return ""
  end
  local VehicleShapeTable = CDataTable.GetTableData("VehicleShapeTable", VehicleRefitInfo.VehicleShapeID)
  if not VehicleShapeTable then
    return ""
  end
  return VehicleShapeTable.MeshBasePath
end
function LobbyVehicle:GetNewVehicleMasterAnimBPPath(VehicleSkinID)
  local VehicleRefitInfo = CDataTable.GetTableData("VehicleRefitInfo", VehicleSkinID)
  if not VehicleRefitInfo then
    return ""
  end
  local VehicleShapeTable = CDataTable.GetTableData("VehicleShapeTable", VehicleRefitInfo.VehicleShapeID)
  if not VehicleShapeTable then
    return ""
  end
  return VehicleShapeTable.AnimBPPath
end
function LobbyVehicle:GetVehicleMasterPath(VehicleSkinID)
  local VehicleBPTable = CDataTable.GetTableData("VehicleBPTable", VehicleSkinID)
  if not VehicleBPTable then
    return ""
  end
  local VehicleShapeTable = CDataTable.GetTableData("VehicleShapeTable", VehicleBPTable.VehicleShapeID)
  if not VehicleShapeTable then
    return ""
  end
  return VehicleShapeTable.MeshBasePath
end
function LobbyVehicle:PreChangeVehicleAvatar(InAvatarID, InAdvanceAvatarID)
  if not InAvatarID or not InAdvanceAvatarID then
    log(bWriteLog and "LobbyVehicle:PreChangeVehicleAvatar AvatarID is nil")
    return
  end
  if 0 < InAdvanceAvatarID and self.VehicleAdvanceAvatarComp_BP then
    local MeshBasePath = self:GetNewVehilceMasterPath(InAdvanceAvatarID)
    self.VehicleAdvanceAvatarComp_BP:SetMasterBaseMeshPath(MeshBasePath)
    return self.Super:PreChangeVehicleAvatar(0, InAdvanceAvatarID)
  else
    local MeshBasePath = self:GetVehicleMasterPath(InAvatarID)
    self.VehicleAvatarComponent_BP:SetMasterSkeletalMeshPath(MeshBasePath, true)
    return self.Super:PreChangeVehicleAvatar(InAvatarID, InAdvanceAvatarID)
  end
end
function LobbyVehicle:PutOnVehicleItem(InModelID, ColorID, PatternID, ParticleID)
  if not self.VehicleAdvanceAvatarComp_BP then
    log(bWriteLog and "LobbyVehicle PutOnVehicleItem no VehicleAdvanceAvatarComp_BP")
    return false
  end
  return self.VehicleAdvanceAvatarComp_BP:PutOnItemIDInLobby(InModelID, ColorID, PatternID, ParticleID)
end
function LobbyVehicle:PutOffVehicleItem(InModelID)
  if not self.VehicleAdvanceAvatarComp_BP then
    log(bWriteLog and "LobbyVehicle PutOffVehicleItem no VehicleAdvanceAvatarComp_BP")
    return false
  end
  return self.VehicleAdvanceAvatarComp_BP:PutOffItemIDInLobby(InModelID)
end
function LobbyVehicle:GetDefaultAvatarID(InAvatarID)
  local VehiclePlaneSkinMapping = CDataTable.GetTableData("VehiclePlaneSkinMapping", InAvatarID)
  if not VehiclePlaneSkinMapping then
    return InAvatarID
  end
  return VehiclePlaneSkinMapping.OrginalID
end
function LobbyVehicle:PreChangeVehicleAvatar_Old(InAvatarID, InAdvanceAvatarID)
  if 0 < InAdvanceAvatarID and self.VehicleAdvanceAvatarComp_BP then
    local MeshBasePath = self:GetNewVehilceMasterPath(InAdvanceAvatarID)
    self.VehicleAdvanceAvatarComp_BP:SetMasterBaseMeshPath(MeshBasePath)
    local AnimBPPath = self:GetNewVehicleMasterAnimBPPath(InAdvanceAvatarID)
    self.VehicleAdvanceAvatarComp_BP:SetMasterBaseMeshAnimBP(AnimBPPath)
    return self.Super:PreChangeVehicleAvatar(0, InAdvanceAvatarID)
  else
    local MeshBasePath = self:GetVehicleMasterPath(InAvatarID)
    self.VehicleAvatarComponent_BP:SetMasterSkeletalMeshPath(MeshBasePath, true)
    return self.Super:PreChangeVehicleAvatar(InAvatarID, InAdvanceAvatarID)
  end
end
function LobbyVehicle:TrySetHighLight(Invincible, Freq, speed)
  local ReTry = function()
    self:AddTimerOnce(0.15, function()
      self.HighlightTryTime = self.HighlightTryTime + 1
      if self.HighlightTryTime > 25 then
        return
      end
      self:TrySetHighLight(Invincible, Freq, speed)
    end)
  end
  if not slua.isValid(self.Mesh) then
    log(bWriteLog and "LobbyVehicle TrySetHighLight not slua.isValid(self.Mesh)")
    ReTry()
    return
  end
  local materials = self.Mesh:GetMaterials()
  if materials:Num() <= 0 then
    log(bWriteLog and "LobbyVehicle TrySetHighLight not slua.isValid(materials)")
    ReTry()
    return
  end
  local ItemCfg = CDataTable.GetTableData("Item", self.vehicleResId)
  if not ItemCfg then
    log(bWriteLog and "LobbyVehicle TrySetHighLight not ItemCfg " .. tostring(self.vehicleResId))
    return
  end
  for Index, material in pairs(materials) do
    local DynamicMaterialInstance = self.Mesh:CreateDynamicMaterialInstance(Index, material)
    if not slua.isValid(DynamicMaterialInstance) then
      log(bWriteLog and "LobbyVehicle TrySetHighLight not DynamicMaterialInstance")
      ReTry()
      return
    end
    DynamicMaterialInstance:SetScalarParameterValue("invincible", Invincible)
    DynamicMaterialInstance:SetScalarParameterValue("FreExp", Freq)
    DynamicMaterialInstance:SetScalarParameterValue("Speed", speed)
  end
end
function LobbyVehicle:PutOffVehicleSlot(slotType)
  if not self.VehicleAdvanceAvatarComp_BP then
    log(bWriteLog and "LobbyVehicle PutOffVehicleSlot not VehicleAdvanceAvatarComp_BP")
    return false
  end
  local bSuccess = self.VehicleAdvanceAvatarComp_BP:PutOffSlotinLobby(slotType)
  return bSuccess
end
function LobbyVehicle:ClearAllVehicleItems()
  if not self.VehicleAdvanceAvatarComp_BP then
    log(bWriteLog and "LobbyVehicle ClearAllVehicleItems not VehicleAdvanceAvatarComp_BP")
    return false
  end
  self.VehicleAdvanceAvatarComp_BP:RemoveAllEquippedItem()
  return true
end
function LobbyVehicle:SetDMIParam(MaterialInstance, ParamName, ParamValue)
  if not ParamName or not ParamValue then
    log(bWriteLog and "LobbyVehicle SetDMIParam invalid ParamValue or ParamName")
    return
  end
  if not slua.isValid(MaterialInstance) or not MaterialInstance.SetScalarParameterValue then
    log(bWriteLog and "LobbyVehicle SetDMIParam invalid MaterialInstance")
    return
  end
  MaterialInstance:SetScalarParameterValue(ParamName, ParamValue)
end
function LobbyVehicle:SetHighLight(Invincible, Freq, speed)
  self.HighlightTryTime = 0
  self:TrySetHighLight(Invincible, Freq, speed)
end
function LobbyVehicle:SetShowModelOutline(bIsShow, uOutlineColor, nOutlineThickness)
  if not slua.isValid(self.Mesh) then
    return
  end
  local MeshComponentClass = import("/Script/Engine.MeshComponent")
  local uComponentArray = self:GetComponentsByClass(MeshComponentClass)
  for _, uObj_mesh in pairs(uComponentArray) do
    if uObj_mesh and slua.isValid(uObj_mesh) then
      uObj_mesh:SetDrawIdeaOutline(bIsShow)
      uObj_mesh:SetIdeaOutlineNew(bIsShow)
      if bIsShow then
        uObj_mesh:OverrideIdeaOutlineColor(true, uOutlineColor)
        uObj_mesh:OverrideIdeaOutlineThickness(true, nOutlineThickness)
      end
    end
  end
end
function LobbyVehicle:GetVehicleAccessorySlotConfig(nAvatarID, slotName)
  if not nAvatarID or not slotName then
    log(bWriteLog and "[VehicleAccessory] LobbyVehicle:GetVehicleAccessorySlotConfig, param is nil")
    return nil
  end
  log(bWriteLog and "[VehicleAccessory] LobbyVehicle:GetVehicleAccessorySlotConfig, nAvatarID = " .. tostring(nAvatarID) .. " slotName = " .. tostring(slotName))
  local VehicleAvatar = self.VehicleAvatarComponent_BP
  if not slua.isValid(VehicleAvatar) then
    log(bWriteLog and "[VehicleAccessory] LobbyVehicle:GetVehicleAccessorySlotConfig VehicleAvatar is nil")
    return nil
  end
  local AvatarHandle = VehicleAvatar:GetItemAvatarHandle(nAvatarID)
  if not slua.isValid(AvatarHandle) then
    log(bWriteLog and "[VehicleAccessory] LobbyVehicle:GetVehicleAccessorySlotConfig AvatarHandle is nil")
    return nil
  end
  if not AvatarHandle.VehicleAccessorySlotCfgs or AvatarHandle.VehicleAccessorySlotCfgs:Num() == 0 then
    log(bWriteLog and "[VehicleAccessory] LobbyVehicle:GetVehicleAccessorySlotConfig VehicleAccessorySlotCfgs is nil")
    return nil
  end
  for i = 0, AvatarHandle.VehicleAccessorySlotCfgs:Num() - 1 do
    local VehicleAccessorySlotConfig = AvatarHandle.VehicleAccessorySlotCfgs:Get(i)
    if VehicleAccessorySlotConfig and VehicleAccessorySlotConfig.AccessorySlotName == slotName then
      log(bWriteLog and "[VehicleAccessory] LobbyVehicle:GetVehicleAccessorySlotConfig VehicleAccessorySlotCfgs Get")
      return VehicleAccessorySlotConfig
    end
  end
  log(bWriteLog and "[VehicleAccessory] LobbyVehicle:GetVehicleAccessorySlotConfig VehicleAccessorySlotCfgs nil")
  return nil
end
function LobbyVehicle:SetVehicleAccessoryWithPreview(previewItem)
  if not self.BP_Lobby_VehicleLicenseComponent then
    log(bWriteLog and "[LicensePlate] LobbyVehicle SetVehicleAccessoryWithPreview Can`t find BP_Lobby_VehicleLicenseComponent")
    return
  end
  local CurSkinID = self.VehicleAvatarComponent_BP:GetCurItemAvatarID()
  self.BP_Lobby_VehicleLicenseComponent:SetPreviewAccessoryItem(CurSkinID, previewItem)
end
function LobbyVehicle:SetVehicleAccessoryList(AccItemList)
  if not self.BP_Lobby_VehicleLicenseComponent then
    log(bWriteLog and "[LicensePlate] LobbyVehicle SetVehicleAccessoryList Can`t find BP_Lobby_VehicleLicenseComponent")
    return
  end
  local CurSkinID = self.VehicleAvatarComponent_BP:GetCurItemAvatarID()
  self.BP_Lobby_VehicleLicenseComponent:SetAccessoryItemList(CurSkinID, AccItemList)
end
function LobbyVehicle:SetChassisLightShowData(chassisLightData)
  if not self.BP_Lobby_VehicleLicenseComponent then
    log(bWriteLog and "[LicensePlate] LobbyVehicle SetChassisLightShowData Can`t find BP_Lobby_VehicleLicenseComponent")
    return
  end
  local CurSkinID = self.VehicleAvatarComponent_BP:GetCurItemAvatarID()
  self.BP_Lobby_VehicleLicenseComponent:SetChassisLightData(CurSkinID, chassisLightData)
end
function LobbyVehicle:PlayCabrioAnim(bOpen)
  if not slua.isValid(self.Mesh) then
    log(bWriteLog and "LobbyVehicle:PlayCabrioAnim self.Mesh is not Valid")
    return false
  end
  local AnimIns = self.Mesh:GetAnimInstance()
  if not slua.isValid(AnimIns) then
    log(bWriteLog and "LobbyVehicle:PlayCabrioAnim AnimIns is not Valid")
    return false
  end
  local ECabrioletState = import("ECabrioletState")
  local curCabriolatState = AnimIns.CabrioletState
  log(bWriteLog and "LobbyVehicle:PlayCabrioAnim curCabriolatState:" .. tostring(curCabriolatState))
  if not curCabriolatState or curCabriolatState == ECabrioletState.Close or curCabriolatState == ECabrioletState.Open then
    log(bWriteLog and "LobbyVehicle:PlayCabrioAnim Cabriolat is changing")
    return false
  end
  log(bWriteLog and "LobbyVehicle:PlayCabrioAnim bOpen:" .. tostring(bOpen))
  local state
  if bOpen then
    state = ECabrioletState.Open
  else
    state = ECabrioletState.Close
  end
  self.VehicleAnimParams.CabrioletState = state
  local cabrioletDelayTime = 1.5
  local avatarID = self.VehicleAvatarComponent_BP and self.VehicleAvatarComponent_BP.lastEquipedAvatarId
  if avatarID then
    local VehicleEffectCfg = CDataTable.GetTableData("BetterVehicleEffect", avatarID)
    if VehicleEffectCfg and VehicleEffectCfg.CabrioletDelayTime and VehicleEffectCfg.CabrioletDelayTime ~= 0 then
      cabrioletDelayTime = VehicleEffectCfg.CabrioletDelayTime
    end
  end
  self:AddTimerOnce(cabrioletDelayTime, function()
    if bOpen then
      self.VehicleAnimParams.CabrioletState = ECabrioletState.BeenOpen
    else
      self.VehicleAnimParams.CabrioletState = ECabrioletState.BeenClose
    end
    log(bWriteLog and "LobbyVehicle:PlayCabrioAnim timer curCabriolatState:" .. tostring(self.VehicleAnimParams.CabrioletState))
  end)
  return true
end
function LobbyVehicle:GetAvatarComponent()
  return self.VehicleAvatarComponent_BP
end
function LobbyVehicle:PlayStartUpEffect()
  log(bWriteLog and "LobbyVehicle:PlayStartUpEffect")
  local UIUtil = require("client.common.ui_util")
  if not UIUtil.CanClickNow(UIUtil.ModuleFrequencyLimit.LobbyVehicle) then
    return
  end
  self:PlayVehicleEffect("StartUpFX", 3)
end
function LobbyVehicle:StopStartUpEffect()
  self:StopVehicleEffect("StartUpFX")
end
function LobbyVehicle:PlaySwiftEffect(animLen)
  log(bWriteLog and "LobbyVehicle:PlaySwiftEffect")
  local UIUtil = require("client.common.ui_util")
  if not UIUtil.CanClickNow(UIUtil.ModuleFrequencyLimit.LobbyVehicle) then
    return
  end
  animLen = animLen or 5
  self:PlayVehicleEffect("SwiftFX", animLen)
end
function LobbyVehicle:StopSwiftEffect()
  self:StopVehicleEffect("SwiftFX")
end
function LobbyVehicle:PlayVehicleEffect(EffectName, destoryTime)
  log(bWriteLog and "LobbyVehicle:PlayVehicleEffect EffectName:" .. tostring(EffectName))
  if not EffectName or EffectName == "" then
    log(bWriteLog and "LobbyVehicle:PlayVehicleEffect EffectName Not Valid")
    return
  end
  if not slua.isValid(self.VehicleAvatarComponent_BP) then
    log(bWriteLog and "LobbyVehicle:PlayVehicleEffect Avatar Comp Not Valid")
    return
  end
  local AvatarHandle = self.VehicleAvatarComponent_BP:GetVehicleAvatarHandle()
  if not slua.isValid(AvatarHandle) then
    log(bWriteLog and "LobbyVehicle:PlayVehicleEffect Avatar Handle Not Valid")
    return
  end
  if self.VehicleFXTimers and self.VehicleFXTimers[EffectName] then
    self:RemoveTimer(self.VehicleFXTimers[EffectName])
    self.VehicleFXTimers[EffectName] = nil
  end
  local ShowFXArray = AvatarHandle.ParticleSfx:Get(EffectName)
  if not ShowFXArray then
    log(bWriteLog and "LobbyVehicle:PlayVehicleEffect ShowFXArray Not Valid")
    return
  end
  local UGameplayStatics = import("GameplayStatics")
  local asset_util = require("common.asset_util")
  self.VehicleFXMap = self.VehicleFXMap or {}
  self.VehicleFXMap[EffectName] = self.VehicleFXMap[EffectName] or {}
  for _, v in pairs(ShowFXArray.WrapperArray) do
    local FXAsset = asset_util.GetAssetSync(v.Template:ToString())
    if slua.isValid(FXAsset) then
      local PSC = UGameplayStatics.SpawnEmitterAttached(FXAsset, self.Mesh, v.AttachSocketName, v.Location, v.Rotation, v.Scale, 0, true)
      if slua.isValid(PSC) then
        table.insert(self.VehicleFXMap[EffectName], PSC)
      end
    end
  end
  self.VehicleFXTimers[EffectName] = self:AddTimer(destoryTime or 0.3, function()
    self.VehicleFXTimers[EffectName] = nil
    self:StopVehicleEffect(EffectName)
  end)
end
function LobbyVehicle:StopVehicleEffect(EffectName)
  log(bWriteLog and "LobbyVehicle:StopVehicleEffect EffectName:" .. tostring(EffectName))
  if not EffectName or EffectName == "" then
    return
  end
  if not self.VehicleFXMap or not self.VehicleFXMap[EffectName] then
    return
  end
  if #self.VehicleFXMap[EffectName] > 0 then
    for _, PSC in ipairs(self.VehicleFXMap[EffectName]) do
      if slua.isValid(PSC) then
        PSC:K2_DestroyComponent()
      end
    end
  end
  self.VehicleFXMap[EffectName] = nil
end
function LobbyVehicle:BeginTickVehicleMat(MatConfig)
  log(bWriteLog and "LobbyVehicle:BeginTickVehicleMat")
  if not MatConfig then
    log(bWriteLog and "LobbyVehicle:BeginTickVehicleMat MatConfig is nil")
    return
  end
  if not slua.isValid(self.Mesh) then
    log(bWriteLog and "LobbyVehicle:BeginTickVehicleMat Mesh is not Valid")
    return
  end
  if not MatConfig.Slot or not MatConfig.MatPath then
    log(bWriteLog and "LobbyVehicle:BeginTickVehicleMat invalid MatConfig Slot or MatPath")
    return
  end
  local slotIndex = self.Mesh:GetMaterialIndex(MatConfig.Slot)
  if slotIndex < 0 then
    log(bWriteLog and "LobbyVehicle:BeginTickVehicleMat Material slot '" .. tostring(MatConfig.Slot) .. "' not found")
    return
  end
  for i, matData in ipairs(self.VehicleMatData) do
    if matData.SlotIndex == slotIndex then
      log(bWriteLog and "LobbyVehicle:BeginTickVehicleMat Material slot already in use, removing old one")
      if slua.isValid(self.Mesh) and slua.isValid(matData.OriginalMaterial) then
        self.Mesh:SetMaterial(slotIndex, matData.OriginalMaterial)
      end
      if slua.isValid(matData.OriginalMaterial) then
        slua.removeRef(matData.OriginalMaterial)
      end
      table.remove(self.VehicleMatData, i)
      break
    end
  end
  local originalMaterial = self.Mesh:GetMaterial(slotIndex)
  if not slua.isValid(originalMaterial) then
    log(bWriteLog and "LobbyVehicle:BeginTickVehicleMat OriginalMaterial at slot " .. tostring(slotIndex) .. " is invalid")
    return
  end
  slua.addRef(originalMaterial)
  local asset_util = require("common.asset_util")
  local newMaterial = asset_util.GetAssetSync(MatConfig.MatPath)
  if not slua.isValid(newMaterial) then
    log(bWriteLog and "LobbyVehicle:BeginTickVehicleMat Failed to load material:" .. tostring(MatConfig.MatPath))
    return
  end
  self.Mesh:SetMaterial(slotIndex, newMaterial)
  local dynamicMat = self.Mesh:CreateDynamicMaterialInstance(slotIndex, newMaterial)
  if not slua.isValid(dynamicMat) then
    log(bWriteLog and "LobbyVehicle:BeginTickVehicleMat Failed to create dynamic material instance")
    self.Mesh:SetMaterial(slotIndex, originalMaterial)
    return
  end
  local curves = {}
  if MatConfig.Param then
    for _, paramCfg in ipairs(MatConfig.Param) do
      if paramCfg.Curve then
        local curveAsset = asset_util.GetAssetSync(paramCfg.Curve)
        if slua.isValid(curveAsset) then
          table.insert(curves, {
            Name = paramCfg.Name,
            Curve = curveAsset,
            CurveMin = paramCfg.CurveMin,
            CurveMax = paramCfg.CurveMax,
            ValueMin = paramCfg.ValueMin,
            ValueMax = paramCfg.ValueMax,
            UseAdditive = paramCfg.UseAdditive or false,
            AdditiveMod = paramCfg.AdditiveMod
          })
        else
          log(bWriteLog and "LobbyVehicle:BeginTickVehicleMat Failed to load curve:" .. tostring(paramCfg.Curve))
        end
      end
    end
  end
  local matData = {
    SlotIndex = slotIndex,
    OriginalMaterial = originalMaterial,
    DynamicMaterialInstance = dynamicMat,
    Config = MatConfig,
    Curves = curves
  }
  table.insert(self.VehicleMatData, matData)
  if not self.VehicleMatTickTimer then
    self.VehicleMatTickTimer = self:AddTimerLoop(0, function(deltaTime)
      self:UpdateVehicleMatTick(deltaTime)
    end, TIMER_INFINITE or 0, -2)
    log(bWriteLog and "LobbyVehicle:BeginTickVehicleMat Started unified tick timer")
  end
  log(bWriteLog and "LobbyVehicle:BeginTickVehicleMat Added material for slot " .. tostring(slotIndex))
end
function LobbyVehicle:UpdateVehicleMatTick(deltaTime)
  if not slua.isValid(self.Mesh) then
    return
  end
  self.MatTickTime = self.MatTickTime + (deltaTime or 0)
  if self.MatTickTime > self.MatTickEndTime then
    log(bWriteLog and "LobbyVehicle:UpdateVehicleMatTick MatTickEnd")
    self:StopTickVehicleMat()
    return
  end
  for _, matData in ipairs(self.VehicleMatData) do
    if slua.isValid(matData.DynamicMaterialInstance) then
      for _, curveData in ipairs(matData.Curves) do
        if slua.isValid(curveData.Curve) and curveData.Curve.GetFloatValue then
          local curveValue = curveData.Curve:GetFloatValue(self.MatTickTime)
          if curveValue then
            if curveData.CurveMin and curveData.CurveMax then
              curveValue = FuncUtil.Clamp(curveValue, curveData.CurveMin, curveData.CurveMax)
              if curveData.ValueMin and curveData.ValueMax then
                curveValue = (curveValue - curveData.CurveMin) / (curveData.CurveMax - curveData.CurveMin) * (curveData.ValueMax - curveData.ValueMin) + curveData.ValueMin
              end
            end
            if curveData.UseAdditive then
              local currentValue = matData.DynamicMaterialInstance:K2_GetScalarParameterValue(curveData.Name)
              if not currentValue then
                goto lbl_109
              end
              curveValue = currentValue + curveValue * deltaTime
              if curveData.AdditiveMod then
                curveValue = curveValue % curveData.AdditiveMod
              end
            end
            matData.DynamicMaterialInstance:SetScalarParameterValue(curveData.Name, curveValue)
          end
        end
        ::lbl_109::
      end
    end
  end
end
function LobbyVehicle:StopTickVehicleMat()
  log(bWriteLog and "LobbyVehicle:StopTickVehicleMat")
  if self.VehicleMatTickTimer then
    self:RemoveTimer(self.VehicleMatTickTimer)
    self.VehicleMatTickTimer = nil
  end
  if slua.isValid(self.Mesh) then
    for _, matData in ipairs(self.VehicleMatData) do
      if slua.isValid(matData.OriginalMaterial) then
        self.Mesh:SetMaterial(matData.SlotIndex, matData.OriginalMaterial)
        slua.removeRef(matData.OriginalMaterial)
      else
        log_error("LobbyVehicle:StopTickVehicleMat OriginalMaterial not valid")
      end
    end
  end
  self.VehicleMatData = {}
  self.MatTickTime = 0
end
function LobbyVehicle:OnVehicleAnimInsInitialize()
  log(bWriteLog and "LobbyVehicle:OnVehicleAnimInsInitialize")
  if self.InitAnimTimer then
    self:RemoveTimer(self.InitAnimTimer)
    self.InitAnimTimer = nil
  end
  local AnimIns = self.Mesh and self.Mesh:GetAnimInstance()
  if slua.isValid(AnimIns) then
    log(bWriteLog and "LobbyVehicle:OnVehicleAnimInsInitialize bIsProhibitOpenDoorAnim set true 1")
    AnimIns.isProhibitOpenDoorAnim = true
  end
  self.InitAnimTimer = self:AddTimerOnce(0.1, function()
    local AnimIns = self.Mesh and self.Mesh:GetAnimInstance()
    if not slua.isValid(AnimIns) then
      log(bWriteLog and "LobbyVehicle:OnVehicleAnimInsInitialize AnimIns is not Valid")
      return false
    end
    AnimIns.isProhibitOpenDoorAnim = true
    if self.bIsProhibitOpenDoorAnim then
      log(bWriteLog and "LobbyVehicle:OnVehicleAnimInsInitialize bIsProhibitOpenDoorAnim is true")
      return
    end
    self:PlayOpenDoorAnim()
  end)
end
function LobbyVehicle:PlayOpenDoorAnim()
  if not slua.isValid(self.Mesh) then
    log(bWriteLog and "LobbyVehicle:PlayOpenDoorAnim VehicleActor.Mesh is not Valid")
    return false
  end
  local AnimIns = self.Mesh:GetAnimInstance()
  if not slua.isValid(AnimIns) then
    log(bWriteLog and "LobbyVehicle:PlayOpenDoorAnim AnimIns is not Valid")
    return false
  end
  if AnimIns.PlayDoorAnim then
    AnimIns:PlayDoorAnim()
    log(bWriteLog and "LobbyVehicle:PlayOpenDoorAnim AnimIns PlayDoorAnim is Valid old")
    return true
  end
  return self:PlayVehiclePreviewAnim(AnimIns, "OpenDoor")
end
function LobbyVehicle:PlayCloseDoorAnim()
  if not slua.isValid(self.Mesh) then
    log(bWriteLog and "LobbyVehicle:PlayCloseDoorAnim VehicleActor.Mesh is not Valid")
    return false
  end
  local AnimIns = self.Mesh:GetAnimInstance()
  if not slua.isValid(AnimIns) then
    log(bWriteLog and "LobbyVehicle:PlayCloseDoorAnim AnimIns is not Valid")
    return false
  end
  if AnimIns.CloseDoorAnim then
    AnimIns:CloseDoorAnim()
    log(bWriteLog and "LobbyVehicle:PlayCloseDoorAnim AnimIns CloseDoorAnim is Valid old")
    return true
  end
  return self:PlayVehiclePreviewAnim(AnimIns, "CloseDoor")
end
function LobbyVehicle:PlayVehiclePreviewAnim(AnimIns, AnimName)
  log(bWriteLog and "LobbyVehicle:PlayVehiclePreviewAnim AnimName:" .. tostring(AnimName))
  if not AnimName or AnimName == "" or not slua.isValid(AnimIns) then
    log(bWriteLog and "LobbyVehicle:PlayVehiclePreviewAnim param is not Valid")
    return false
  end
  if not AnimIns.LobbyPreviewAnims then
    log(bWriteLog and "LobbyVehicle:PlayVehiclePreviewAnim AnimIns.LobbyPreviewAnims is not Valid")
    return false
  end
  local OpenDoorAnimSoftPath = AnimIns.LobbyPreviewAnims:Get(AnimName)
  local OpenDoorAnimPath = OpenDoorAnimSoftPath and OpenDoorAnimSoftPath:ToString()
  if not OpenDoorAnimPath or OpenDoorAnimPath == "" then
    log(bWriteLog and "LobbyVehicle:PlayVehiclePreviewAnim OpenDoorAnimPath is not Valid")
    return false
  end
  local Util = require("client.slua_ui_framework.util")
  if self.DoorAminLoadingHandle then
    Util.ClearAssetAsync(self.DoorAminLoadingHandle)
    self.DoorAminLoadingHandle = nil
  end
  self.DoorAminLoadingHandle = Util.GetAssetAsync(OpenDoorAnimPath, function(uMontage)
    self.DoorAminLoadingHandle = nil
    if not slua.isValid(uMontage) then
      log(bWriteLog and "LobbyVehicle:PlayVehiclePreviewAnim Montage is not Valid")
      return
    end
    if not slua.isValid(AnimIns) then
      log(bWriteLog and "LobbyVehicle:PlayVehiclePreviewAnim AnimIns is not Valid")
      return
    end
    if AnimIns:Montage_IsPlaying(uMontage) then
      log(bWriteLog and "LobbyVehicle:PlayVehiclePreviewAnim Montage_IsPlaying")
      return
    end
    AnimIns.ForceUpdateAnimation = true
    local EMontagePlayReturnType = import("EMontagePlayReturnType")
    AnimIns:Montage_Play(uMontage, 1, EMontagePlayReturnType.MontageLength, 0)
  end)
  return true
end
function LobbyVehicle:SetPreviewSwitchEffectData(switchEffectId, lastVehicleId, newVehicleId)
  if not (switchEffectId and lastVehicleId) or not newVehicleId then
    log(bWriteLog and "LobbyVehicle:SetPreviewSwitchEffectData param is not Valid")
    return false
  end
  log(bWriteLog and "LobbyVehicle:SetPreviewSwitchEffectData lastVehicleId:" .. tostring(lastVehicleId) .. " newVehicleId:" .. tostring(newVehicleId))
  self.PreviewSwitchEffectData = self.PreviewSwitchEffectData or {}
  self.PreviewSwitchEffectData.  self.PreviewSwitchEffectData.  self.PreviewSwitchEffectData.  self:CancelSwitchAssetLoadHandle()
  if self.ClientUsedAvatarID ~= newVehicleId then
    log(bWriteLog and "LobbyVehicle:SetPreviewSwitchEffectData ClientUsedAvatarID ~= newVehicleId")
    return
  end
  local callback = function()
    self.PreviewSwitchAssetHandleId = nil
    if not slua.isValid(self.Object) then
      log(bWriteLog and "LobbyVehicle:SetPreviewSwitchEffectData  callback invalid slua.isValid(self.Object)")
      return
    end
    if not self.PreviewSwitchEffectData then
      log(bWriteLog and "LobbyVehicle:SetPreviewSwitchEffectData  callback invalid PreviewSwitchEffectData")
      return
    end
    if self.PreviewSwitchEffectData.switchEffectId ~= switchEffectId or self.PreviewSwitchEffectData.lastVehicleId ~= lastVehicleId or self.PreviewSwitchEffectData.newVehicleId ~= newVehicleId then
      log(bWriteLog and "LobbyVehicle:SetPreviewSwitchEffectData  callback switchEffectId change")
      return
    end
    log(bWriteLog and "LobbyVehicle:SetPreviewSwitchEffectData  callback")
    self:StartPreviewSwitchEffect(switchEffectId, lastVehicleId, newVehicleId)
  end
  local model_util = require("client.common.model_util")
  local BPID = model_util.GetBPID(lastVehicleId)
  local handlePath = model_util.GetPath("Vehicle", BPID, true, false)
  if not handlePath or handlePath == "" then
    log(bWriteLog and "LobbyVehicle:SetPreviewSwitchEffectData handlePath is not Valid")
    return false
  end
  local asset_util = require("common.asset_util")
  self.PreviewSwitchAssetHandleId = asset_util.GetAssetAsync(handlePath, function()
    self.PreviewSwitchAssetHandleId = nil
    local VehiclePlateLicenseUtil = require("GameLua.Activity.Commercialize.GamePlay.Vehicle.VehiclePlateLicenseUtil")
    local dissolveMatPaths = VehiclePlateLicenseUtil.GetSportsCarDissolveMatPathList(newVehicleId, lastVehicleId)
    dissolveMatPaths = VehiclePlateLicenseUtil.GetOneVehicleResPaths(dissolveMatPaths, lastVehicleId)
    if dissolveMatPaths and next(dissolveMatPaths) then
      self.PreviewSwitchAssetHandleId = asset_util.GetAssetsArrayAsyncParallel(dissolveMatPaths, callback)
    else
      callback()
    end
  end)
end
function LobbyVehicle:StartPreviewSwitchEffect(switchEffectId, lastVehicleId, newVehicleId)
  if not (switchEffectId and lastVehicleId) or not newVehicleId then
    log(bWriteLog and "LobbyVehicle:StartPreviewSwitchEffect param is not Valid")
    return false
  end
  local avatarComponent = self:GetAvatarComponent()
  if not slua.isValid(avatarComponent) or not avatarComponent.CheckAndShowVehicleSwitchEffect then
    log(bWriteLog and "LobbyVehicle:StartPreviewSwitchEffect avatarComponent is not Valid")
    return false
  end
  if self.ClientUsedAvatarID ~= newVehicleId then
    log(bWriteLog and "LobbyVehicle:StartPreviewSwitchEffect ClientUsedAvatarID ~= newVehicleId")
    return
  end
  avatarComponent:SetSwitchEffectPreviewData(switchEffectId, lastVehicleId)
  avatarComponent:ShowVehicleSwitchEffect()
  avatarComponent:SetSwitchEffectPreviewData(0, 0)
end
function LobbyVehicle:StopPreviewSwitchEffect()
  log(bWriteLog and "LobbyVehicle:StopPreviewSwitchEffect")
  self.PreviewSwitchEffectData = nil
  self:CancelSwitchAssetLoadHandle()
  local avatarComponent = self:GetAvatarComponent()
  if not slua.isValid(avatarComponent) then
    log(bWriteLog and "LobbyVehicle:StopPreviewSwitchEffect avatarComponent is not Valid")
    return false
  end
  avatarComponent:StopSkinSwitchEffect()
end
function LobbyVehicle:CancelSwitchAssetLoadHandle()
  log(bWriteLog and "LobbyVehicle:CancelSwitchAssetLoadHandle")
  if not self.PreviewSwitchAssetHandleId then
    return
  end
  local asset_util = require("common.asset_util")
  asset_util.CancelAssetAsync(self.PreviewSwitchAssetHandleId)
  self.PreviewSwitchAssetHandleId = nil
end
function LobbyVehicle:SetVehicleTick(bTick, bSetForcedLOD)
  log(bWriteLog and "LobbyVehicle:SetVehicleTick bTick = " .. tostring(bTick) .. " bSetForcedLOD = " .. tostring(bSetForcedLOD))
  local performance_util = require("client.slua.logic.performance.performance_util")
  performance_util:SetActorTickRecursively(self.Object, bTick)
  performance_util:SetComponentTickRecursively(self.Mesh, bTick)
  if not bTick and not self.bSetOnlyTickPoseWhenRendered then
    self:SetOnlyTickPoseWhenRendered()
  end
  if bSetForcedLOD then
    local LODLevel = bTick and 1 or 2
    self:SetForcedLOD(LODLevel)
  end
end
function LobbyVehicle:SetOnlyTickPoseWhenRendered()
  log(bWriteLog and "LobbyVehicle:SetOnlyTickPoseWhenRendered ")
  local EMeshComponentUpdateFlag = import("EMeshComponentUpdateFlag")
  if slua.isValid(self.Mesh) and self.Mesh.MeshComponentUpdateFlag then
    self.Mesh.MeshComponentUpdateFlag = EMeshComponentUpdateFlag.OnlyTickPoseWhenRendered
    self.bSetOnlyTickPoseWhenRendered = true
  end
end
function LobbyVehicle:SetForcedLOD(LODLevel)
  if slua.isValid(self.Mesh) and self.Mesh.SetForcedLOD then
    self.Mesh:SetForcedLOD(LODLevel)
  end
end
local class = require("class")
local CActorBase = require("GameLua.Mod.BaseMod.Common.Core.ActorBase")
local CLobbyVehicle = class(CActorBase, nil, LobbyVehicle)
return CLobbyVehicle