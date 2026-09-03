local VehicleDIYComponent = {}
local EAvatarActionType = import("EAvatarActionType")
function VehicleDIYComponent:ctor()
  self.UID = nil
  self.car_id = nil
  self.patternArray = nil
  self.bIsLobbyVehicle = nil
  self.baseMatData = {
    ID = 0,
    baseMat = {}
  }
  self.usingSlot = 0
  self.MaxSlot = 2
end
function VehicleDIYComponent:ReceiveBeginPlay()
  print(bWriteLog and "VehicleDIYComponent:ReceiveBeginPlay")
  VehicleDIYComponent.__super.ReceiveBeginPlay(self)
  self:InitMasterComponent(self.MaxSlot)
  self:AddCommonEvent(EVENTTYPE_VEHICLE_DIY, EVENTID_VEHICLE_DIY_UPDATE_DATA, self.OnDIYDataUpdate, self)
end
function VehicleDIYComponent:AddDIYPattern(patternArray, sync)
  log(bWriteLog and "VehicleDIYComponent:AddDIYPattern begin")
  self.patternArray = nil
  local VehicleDIYCfg = self:GetVehicleDIYCfg()
  if not VehicleDIYCfg then
    log(bWriteLog and "VehicleDIYComponent:AddDIYPattern not VehicleDIYCfg")
    return
  end
  log(bWriteLog and "VehicleDIYComponent:AddDIYPattern item=" .. tostring(VehicleDIYCfg.ID))
  local Mesh = self:GetVehicleMesh()
  if not Mesh then
    log(bWriteLog and "VehicleDIYComponent:AddDIYPattern not Mesh")
    return
  end
  if not slua.isValid(Mesh.SkeletalMesh) then
    log(bWriteLog and "VehicleDIYComponent:AddDIYPattern SkeletalMesh not loaded")
    self.    return
  end
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {
    VehicleDIYCfg.ID
  })
  if state ~= PufferConst.ENUM_DownloadState.Done then
    log(bWriteLog and "VehicleDIYComponent:AddDIYPattern not download")
    self.    return
  end
  local vehicle = self:GetOwner()
  if not slua.isValid(vehicle) or not vehicle.GetAvatarComponent then
    return
  end
  local avatarComp = vehicle:GetAvatarComponent()
  if not slua.isValid(vehicle) then
    return
  end
  if avatarComp:CheckIsPlayingEffectSwitch() then
    log(bWriteLog and "VehicleDIYComponent:AddDIYPattern IsPlayingEffectSwitch")
    self.    return
  end
  local EDrawStyleMode = import("EDrawStyleMode")
  Mesh:SetDrawStyle(EDrawStyleMode.DrS_Decal)
  local reMaterialList = {}
  local find = false
  if not VehicleDIYCfg.MatSlot or VehicleDIYCfg.MatSlot == "" then
    local MaterialList = Mesh:GetMaterials()
    for Index, Mat in pairs(MaterialList) do
      local DecalUVNum = Mat.K2_GetScalarParameterValue and Mat:K2_GetScalarParameterValue("DecalUVNum")
      if DecalUVNum then
        Mat:SetScalarParameterValue("DecalUVNum", VehicleDIYCfg.UVIndex)
      end
      local value = Mat.K2_GetTextureParameterValue and Mat:K2_GetTextureParameterValue(VehicleDIYCfg.TextureSlot)
      if not value then
        local baseMat = Mat:GetBaseMaterial()
        if slua.isValid(baseMat) then
          reMaterialList[Index] = baseMat
          find = true
        end
      end
    end
  else
    local MaterialIndex = Mesh:GetMaterialIndex(VehicleDIYCfg.MatSlot)
    if MaterialIndex < 0 then
      log(bWriteLog and "VehicleDIYComponent:AddDIYPattern not MaterialIndex")
      return
    end
    local Material = Mesh:GetMaterial(MaterialIndex)
    if not Material then
      log(bWriteLog and "VehicleDIYComponent:AddDIYPattern not Material")
      return
    end
    local DecalUVNum = Material.K2_GetScalarParameterValue and Material:K2_GetScalarParameterValue("DecalUVNum")
    if DecalUVNum then
      Material:SetScalarParameterValue("DecalUVNum", VehicleDIYCfg.UVIndex)
    end
    local value = Material:K2_GetTextureParameterValue(VehicleDIYCfg.TextureSlot)
    if not value then
      local baseMat = Material:GetBaseMaterial()
      if slua.isValid(baseMat) then
        reMaterialList[MaterialIndex] = baseMat
        find = true
      end
    end
  end
  if find then
    if not patternArray or patternArray:Num() == 0 then
      log(bWriteLog and "VehicleDIYComponent:AddDIYPattern empty data")
      self:_RealRemovePattern(sync)
      return
    end
  else
    log(bWriteLog and "VehicleDIYComponent:AddDIYPattern sync")
    self:_RealAddPattern(patternArray, VehicleDIYCfg, sync)
    return
  end
  local matPath = {}
  local index2Path = {}
  local materialNames = Mesh:GetMaterialSlotNames()
  if self.baseMatData.ID ~= VehicleDIYCfg.ID then
    self.baseMatData.baseMat = {}
  end
  self.baseMatData.ID = VehicleDIYCfg.ID
  local VehicleDIYConfig = require("client.logic.vehicle.VehicleDIYConfig")
  local SpecialCfg = VehicleDIYConfig[VehicleDIYCfg.ID]
  for index, BaseMat in pairs(reMaterialList) do
    local matSlotName = string.lower(materialNames:Get(index) or "")
    local UVIndex = VehicleDIYCfg.UVIndex
    if SpecialCfg and SpecialCfg[matSlotName] and SpecialCfg[matSlotName].UVIndex then
      UVIndex = SpecialCfg[matSlotName].UVIndex
    end
    local UKismetSystemLibrary = import("KismetSystemLibrary")
    local baseMatName = UKismetSystemLibrary.GetObjectName(BaseMat) or ""
    local BaseMatPath = self:GetDecalMatPath(VehicleDIYCfg.ID, matSlotName, baseMatName, UVIndex)
    if BaseMatPath ~= "" then
      table.insert(matPath, BaseMatPath)
      index2Path[index] = BaseMatPath
      self.baseMatData.baseMat[matSlotName] = baseMatName
    end
  end
  if #matPath <= 0 then
    log(bWriteLog and "VehicleDIYComponent:AddDIYPattern sync")
    self:_RealAddPattern(patternArray, VehicleDIYCfg, sync)
    return
  end
  local callback = function()
    if not slua.isValid(self.Object) then
      return
    end
    local mesh = self:GetVehicleMesh()
    if not slua.isValid(mesh) then
      return
    end
    local vehicle = self:GetOwner()
    if not slua.isValid(vehicle) or not vehicle.GetAvatarComponent then
      return
    end
    local avatarComp = vehicle:GetAvatarComponent()
    if not slua.isValid(vehicle) then
      return
    end
    if avatarComp:CheckIsPlayingEffectSwitch() then
      log(bWriteLog and "VehicleDIYComponent:AddDIYPattern IsPlayingEffectSwitch")
      self.      return
    end
    for index, path in pairs(index2Path) do
      local BusinessHelper = import("BusinessHelper")
      local newBaseMat = BusinessHelper.LoadAssetFromPath(path)
      local material = mesh:GetMaterial(index)
      if slua.isValid(material) then
        local matIns = mesh:CreateDynamicMaterialInstance(index, newBaseMat)
        matIns:CopyParameterOverrides(material)
      end
    end
    self:ReplaceVehicleLightDIM()
    log(bWriteLog and "VehicleDIYComponent:AddDIYPattern async")
    self:_RealAddPattern(patternArray, VehicleDIYCfg, sync)
  end
  local asset_util = require("common.asset_util")
  asset_util.GetAssetsArrayAsyncParallel(matPath, callback)
end
function VehicleDIYComponent:_RealAddPattern(patternArray, Cfg, sync)
  self:_RealRemovePattern(sync)
  self:UpdateAvatarEntityVisible()
  local VehicleDIYConfig = require("client.logic.vehicle.VehicleDIYConfig")
  local SpecialCfg = VehicleDIYConfig[Cfg.ID]
  if SpecialCfg then
    self.usingSlot = #SpecialCfg
    for k, v in pairs(SpecialCfg) do
      self.usingSlot = math.max(self.usingSlot, v.SlotIndex)
      if v.SectionIndex then
        self:AddAction_VehicleDIYPattern3(v.SlotIndex, patternArray, v.UVIndex, v.SectionIndex, Cfg.TextureSlot, k)
      else
        self:AddAction_VehicleDIYPattern2(v.SlotIndex, patternArray, v.UVIndex, Cfg.TextureSlot, k)
      end
    end
  else
    self.usingSlot = 1
    self:AddAction_VehicleDIYPattern2(1, patternArray, Cfg.UVIndex, Cfg.TextureSlot, Cfg.MatSlot)
  end
end
function VehicleDIYComponent:_RealRemovePattern(sync)
  if self.usingSlot == 0 then
    return
  end
  for i = 1, self.usingSlot do
    self:RemoveActionByType(i, EAvatarActionType.ApplyDIYPattern, not sync)
  end
  log(bWriteLog and "VehicleDIYComponent:_RealRemovePattern count = " .. tostring(self.usingSlot))
  self.usingSlot = 0
end
function VehicleDIYComponent:GetVehicleOriginBaseMatName(vehicleID, slotName)
  if vehicleID ~= self.baseMatData.ID then
    return nil
  end
  return self.baseMatData.baseMat[slotName]
end
function VehicleDIYComponent:GetVehicleMesh()
  local vehicle = self:GetOwner()
  if not slua.isValid(vehicle) then
    return nil
  end
  if vehicle.GetMesh then
    return vehicle:GetMesh()
  elseif vehicle.Mesh then
    return vehicle.Mesh
  elseif vehicle.SkeletalMesh then
    return vehicle.SkeletalMesh
  end
  return nil
end
function VehicleDIYComponent:GetVehicleDIYCfg()
  log(bWriteLog and "VehicleDIYComponent:GetVehicleDIYCfg " .. tostring(self.car_id))
  local Cfg = CDataTable.GetTableData("VehicleDIYCfg", tonumber(self.car_id))
  if Cfg and Cfg.BanUse == 1 then
    return nil
  end
  return Cfg
end
function VehicleDIYComponent:UpdateCarOwnerInGame()
  local vehicle = self:GetOwner()
  if not slua.isValid(vehicle) then
    log(bWriteLog and "VehicleDIYComponent:UpdateCarOwnerInGame not vehicle")
    return
  end
  local AvatarComponent = vehicle:GetAvatarComponent()
  if not slua.isValid(AvatarComponent) then
    log(bWriteLog and "VehicleDIYComponent:UpdateCarOwnerInGame not AvatarComponent")
    return
  end
  self.UID = AvatarComponent:GetSkinOwnerUID()
  self.car_id = AvatarComponent:GetCurItemAvatarID()
  log(bWriteLog and string.format("VehicleDIYComponent:UpdateCarOwnerInGame UID = %s, car_id = %s", tostring(self.UID), tostring(self.car_id)))
  self:OnDIYDataUpdate(nil, nil, self.UID, self.car_id)
end
function VehicleDIYComponent:UpdateCarOwnerInLobby(UID, car_id)
  self.UID = tostring(UID)
  self.  log(bWriteLog and string.format("VehicleDIYComponent:UpdateCarOwnerInLobby UID = %s, car_id = %s", tostring(self.UID), tostring(self.car_id)))
  self:OnDIYDataUpdate(nil, nil, self.UID, self.car_id)
end
function VehicleDIYComponent:OnDIYDataUpdate(_, _, UID, car_id)
  if not self.UID or not self.car_id then
    return
  end
  if UID ~= self.UID or car_id and car_id ~= self.car_id then
    return
  end
  local LogicVehicleDIY = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicVehicleDIY)
  local data = LogicVehicleDIY:GetDIYData(self.UID, self.car_id)
  if not data then
    self:_RealRemovePattern()
  else
    local patternArray = LogicVehicleDIY:ConvertUserVehicleDIYDataList(data)
    self:AddDIYPattern(patternArray)
  end
end
function VehicleDIYComponent:OnVehicleAvatarEquiped()
  if not self.patternArray then
    return
  end
  log(bWriteLog and "VehicleDIYComponent:OnVehicleAvatarEquiped AddDIYPattern async")
  local patternArray = self.patternArray
  self:AddDIYPattern(patternArray)
end
function VehicleDIYComponent:OnVehicleSwitchEffectEnd()
  log(bWriteLog and "VehicleDIYComponent:OnVehicleSwitchEffectEnd")
  self:OnDIYDataUpdate(nil, nil, self.UID)
end
function VehicleDIYComponent:IsLobbyActor()
  if self.bIsLobbyVehicle ~= nil then
    return self.bIsLobbyVehicle
  end
  local vehicle = self:GetOwner()
  if not slua.isValid(vehicle) or not vehicle.GetAvatarComponent then
    return false
  end
  local avatarComp = vehicle:GetAvatarComponent()
  if not slua.isValid(vehicle) then
    return false
  end
  self.bIsLobbyVehicle = avatarComp:IsLobbyAvatar() or false
  return self.bIsLobbyVehicle
end
function VehicleDIYComponent:ReplaceVehicleLightDIM()
  local vehicle = self:GetOwner()
  if not slua.isValid(vehicle) or not vehicle.GetAvatarComponent then
    return
  end
  local avatarComp = vehicle:GetAvatarComponent()
  if not slua.isValid(vehicle) then
    return
  end
  local ItemBodyMesh = avatarComp.ItemBodyMesh
  if not slua.isValid(ItemBodyMesh) then
    return
  end
  if avatarComp.FrontMatSlotName then
    local MaterialIndex = ItemBodyMesh:GetMaterialIndex(avatarComp.FrontMatSlotName)
    avatarComp.FrontLightDIM = ItemBodyMesh:CreateDynamicMaterialInstance(MaterialIndex)
  end
  if avatarComp.TailMatSlotName then
    local MaterialIndex = ItemBodyMesh:GetMaterialIndex(avatarComp.TailMatSlotName)
    avatarComp.TailLightDIM = ItemBodyMesh:CreateDynamicMaterialInstance(MaterialIndex)
    if not avatarComp.TailLightDIM then
      avatarComp.TailLightDIM = avatarComp.FrontLightDIM
    end
  end
  if avatarComp.FPPMatSlotName then
    local MaterialIndex = ItemBodyMesh:GetMaterialIndex(avatarComp.FrontMatSlotName)
    avatarComp.FPPLightDIM = ItemBodyMesh:CreateDynamicMaterialInstance(MaterialIndex)
    if not avatarComp.FPPLightDIM then
      avatarComp.FPPLightDIM = avatarComp.FrontLightDIM
    end
  end
end
function VehicleDIYComponent:GetDecalMatPath(CarID, matSlotName, baseMatName, UVIndex)
  local BaseMatPath = ""
  if self:IsLobbyActor() then
    local lobbyCfgName = tostring(CarID) .. "_" .. matSlotName .. "_lobby"
    BaseMatPath = self:GetDecalMatPathByUV(lobbyCfgName, UVIndex)
  end
  if BaseMatPath == "" then
    local specialMatName = tostring(CarID) .. "_" .. matSlotName
    BaseMatPath = self:GetDecalMatPathByUV(specialMatName, UVIndex)
  end
  if BaseMatPath == "" then
    BaseMatPath = self:GetDecalMatPathByUV(baseMatName, UVIndex)
  end
  return BaseMatPath
end
function VehicleDIYComponent:GetDecalMatPathByUV(Key, UVIndex)
  local BaseMatPath = ""
  local BaseMatCfg = CDataTable.GetTableData("SportsCarMatMappingCfg", Key)
  if BaseMatCfg and BaseMatCfg.DecalMatPath_as and BaseMatCfg.DecalMatPath_as:Num() > 0 then
    if UVIndex < BaseMatCfg.DecalMatPath_as:Num() then
      BaseMatPath = BaseMatCfg.DecalMatPath_as:Get(UVIndex) or ""
    end
    if BaseMatPath == "" then
      BaseMatPath = BaseMatCfg.DecalMatPath_as:Get(0) or ""
    end
  end
  return BaseMatPath
end
function VehicleDIYComponent:UpdateAvatarEntityVisible()
  local vehicle = self:GetOwner()
  if slua.isValid(vehicle) and slua.isValid(vehicle.RootComponent) then
    local visible = vehicle.RootComponent:IsVisible()
    for i = 1, self.MaxSlot do
      local Entity = self:GetAvatarEntity(i, -1)
      if Entity then
        Entity:SetAvatarVisibility(visible, false)
      end
    end
  end
end
local class = require("class")
local object = require("GameLua.Mod.BaseMod.Common.Core.ActorBase")
return class(object, nil, VehicleDIYComponent)