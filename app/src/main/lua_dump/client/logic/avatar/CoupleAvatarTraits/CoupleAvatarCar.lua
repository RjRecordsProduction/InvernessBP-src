local CoupleAvatarCar = {}
local GetBasicDataAvatarWearInfo = function()
  local BasicDataAvatarWearInfo = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataAvatarWearInfo)
  return BasicDataAvatarWearInfo
end
local GetAvatarDataCenter = function()
  local AvatarDataCenter = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.AvatarDataCenter)
  return AvatarDataCenter
end
function CoupleAvatarCar:SetEnableRaceCar(bEnable)
  self.EnableShowCar = bEnable
end
function CoupleAvatarCar:SetCarPosAndRot(Pos, Rot)
  self.CarPosition = Pos
  self.CarRotation = Rot
end
function CoupleAvatarCar:SetRaceCarVisible(bVisible)
  if not slua.isValid(self.Vehicle) then
    return
  end
  local VehicleActor = self.Vehicle:GetVehicleActor() or self.Vehicle:GetrefitVehicleActor()
  if not slua.isValid(VehicleActor) then
    return
  end
  VehicleActor:SetActorHiddenInGame(not bVisible)
end
function CoupleAvatarCar:CheckShowRaceCar(nUId)
  if not self.EnableShowCar then
    log(bWriteLog and "CoupleAvatarCar:CheckShowRaceCar not self.EnableShowCar")
    self:SetRaceCarVisible(false)
    return
  end
  local bShowVehicle = GetBasicDataAvatarWearInfo():GetVehicleShowSetting(nUId)
  if not bShowVehicle then
    log(bWriteLog and "CoupleAvatarCar:CheckShowRaceCar not bShowVehicle")
    self:SetRaceCarVisible(false)
    return
  end
  local logic_couple_avatar_util = require("client.slua.logic.lobby.Left.logic_couple_avatar_util")
  local VehicleSkinID = logic_couple_avatar_util.GetShowVehicleItemId(nUId)
  if not VehicleSkinID then
    log(bWriteLog and "CoupleAvatarCar:CheckShowRaceCar not VehicleSkinID")
    self:SetRaceCarVisible(false)
    return
  end
  self:SetRaceCarVisible(true)
end
function CoupleAvatarCar:ShowVehicle(UID)
  log(bWriteLog and "CoupleAvatarCar ShowVehicle UID" .. tostring(UID))
  if not self.EnableShowCar then
    log(bWriteLog and "CoupleAvatarCar:ShowVehicle not self.EnableShowCar")
    return
  end
  local bShowVehicle = GetBasicDataAvatarWearInfo():GetVehicleShowSetting(UID)
  if not bShowVehicle then
    log(bWriteLog and "CoupleAvatarCar:ShowVehicle not bShowVehicle")
    self:SetRaceCarVisible(false)
    return
  end
  local logic_couple_avatar_util = require("client.slua.logic.lobby.Left.logic_couple_avatar_util")
  local VehicleSkinID = logic_couple_avatar_util.GetShowVehicleItemId(UID)
  if not VehicleSkinID then
    log(bWriteLog and "CoupleAvatarCar:ShowVehicle not VehicleSkinID")
    self:SetRaceCarVisible(false)
    return
  end
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {VehicleSkinID})
  if state == PufferConst.ENUM_DownloadState.Not then
    log(bWriteLog and "CoupleAvatarCar:ShowVehicle DownLoad Vehicle")
    local extraData = {bAutoDownload = true}
    PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {VehicleSkinID}, nil, nil, extraData)
  end
  local VehLoc = FVector(-910.0, 663.84, -5718.0)
  local VehRot = FRotator(0, 140, 0)
  local VehScale = FVector(1.0, 1.0, 1.0)
  local WeaponModelMgrHelper = require("client.slua.logic.manager.WeaponModelSubLogic.WeaponModelMgrHelper")
  local OriginID = WeaponModelMgrHelper.GetRealResIdEnhance(VehicleSkinID, true)
  local VehicleTransformCfg = CDataTable.GetTableData("RankVehicleTransform", OriginID)
  if VehicleTransformCfg then
    local Pos = VehicleTransformCfg.Location
    local Rotation = VehicleTransformCfg.Rotation
    local Scale = VehicleTransformCfg.Scale
    Pos = LobbySceneManager.ParseVec3(Pos)
    Rotation = LobbySceneManager.ParseVec3(Rotation)
    Scale = LobbySceneManager.ParseVec3(Scale)
    VehLoc = FVector(Pos.x_f, Pos.y_f, Pos.z_f)
    VehRot = FRotator(Rotation.x_f, Rotation.z_f, Rotation.y_f)
    VehScale = FVector(Scale.x_f, Scale.y_f, Scale.z_f)
  end
  if self.CarPosition then
    VehLoc = self.CarPosition
  end
  if self.CarRotation then
    VehRot = self.CarRotation
  end
  if slua.isValid(self.Vehicle) then
    self:SetRaceCarVisible(true)
    self.Vehicle:K2_SetActorLocation(VehLoc, false, nil, false)
  else
    local world = slua_GameFrontendHUD:GetWorld()
    if not slua.isValid(world) then
      return
    end
    local ModelFactory = require("client.slua.logic.show_actor.common.ModelFactory")
    self.Vehicle = ModelFactory.CreateShowActor()
    self.Vehicle:K2_SetActorLocation(VehLoc, false, nil, false)
    self.Vehicle:K2_SetActorRotation(VehRot, false)
  end
  if not slua.isValid(self.Vehicle) then
    return
  end
  local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
  local IsRefitVehicle = ModelDisplayTypeHelper.IsRefitVehicle(VehicleSkinID)
  local ExtraTable = {
    EnableHighTire = GetBasicDataAvatarWearInfo():GetVehicleShowTireFeature(UID),
    AccessoryList = GetBasicDataAvatarWearInfo():GetVehicleAccessoryList(UID),
    ChassisLight = GetBasicDataAvatarWearInfo():GetVehicleChassisLight(UID),
    AppliqueList = GetBasicDataAvatarWearInfo():GetVehicleAppliqueList(UID)
  }
  if IsRefitVehicle then
    ExtraTable.is_refit_vehicle = true
    ExtraTable.refit_vehicle_no_possess = true
    ExtraTable.refit_vehicle_no_autoplay = true
    ExtraTable.refit_vehicle_cast_shadow = true
    ExtraTable.is_hall_vehicle = true
    ExtraTable.ignore_download = true
  else
    ExtraTable.ignore_download = true
  end
  self.Vehicle:ShowModelByResID(VehicleSkinID, ExtraTable)
  if IsRefitVehicle then
    local vehicleHandle = self.Vehicle:GetrefitVehicleActor():GetRefitVehicleHandle(VehicleSkinID)
    self.Vehicle:GetrefitVehicleActor():InitSlotSocket(vehicleHandle.SlotConfig)
    local RefitVehicle = require("client.logic.vehicle.logic_refit_vehicle")
    local RifitList = GetBasicDataAvatarWearInfo():GetVehicleRifitList(UID)
    local VehicleRefitHandler = require("client.network.Protocol.VehicleRefitHandler")
    local StyleList = VehicleRefitHandler.GetCarStyleList(VehicleSkinID, nil, nil, RifitList)
    local battleInfo = get_battle_info(StyleList)
    RefitVehicle._equipStyleInner(self.Vehicle:GetrefitVehicleActor(), battleInfo)
  end
  self.Vehicle:SetActorScale3D(VehScale * 0.9)
end
function CoupleAvatarCar:CarHandleDown(data)
  local logic_couple_avatar_util = require("client.slua.logic.lobby.Left.logic_couple_avatar_util")
  local VehicleSkinID = logic_couple_avatar_util.GetShowVehicleItemId(self.SelfUID)
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {VehicleSkinID})
  if state ~= PufferConst.ENUM_DownloadState.Done then
    log(bWriteLog and "CoupleAvatar.OnDownloadDone state ~= PufferConst.ENUM_DownloadState.Done")
    return
  end
  if data.itemID ~= VehicleSkinID then
    log(bWriteLog and "CoupleAvatar.OnDownloadDone data.itemID ~= VehicleSkinID")
    return
  end
  if not self.EnableShowCar then
    log(bWriteLog and "CoupleAvatar.OnDownloadDone not self.EnableShowCar")
    return
  end
  local bShowVehicle = GetBasicDataAvatarWearInfo():GetVehicleShowSetting(self.SelfUID)
  if not bShowVehicle then
    log(bWriteLog and "CoupleAvatar.OnDownloadDone not bShowVehicle")
    return
  end
  if slua.isValid(self.Vehicle) then
    self.Vehicle:Destroy()
    self.Vehicle = nil
  end
  self:ShowVehicle(self.SelfUID)
end
local Trait = require("common.trait")
local TCoupleAvatarCar = Trait(Trait.TraitPrototype, nil, CoupleAvatarCar)
return TCoupleAvatarCar