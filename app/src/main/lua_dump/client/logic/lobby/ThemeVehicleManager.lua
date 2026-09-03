local ThemeVehicleManager = {}
local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
local GetGarageThemeSystem = function()
  local GarageThemeSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.GarageThemeSystem)
  return GarageThemeSystem
end
local GetVehicleCollectSystem = function()
  local VehicleCollectSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.VehicleCollectSystem)
  return VehicleCollectSystem
end
local GetLobbyThemeManager = function()
  local LobbyThemeManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyThemeManager)
  return LobbyThemeManager
end
function ThemeVehicleManager:DefineAndResetData()
  self.Vehicles = {}
  self.RepeatTags = {}
end
function ThemeVehicleManager:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_LOBBY_THEME, EVENTID_GARAGE_VEHICLE_DATA_CHANGE, self.OnGarageVehicleChange, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY_SKIN, EVENTID_LOBBY_SKIN_LOADED, self.OnHallThemeBeginChange, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY_SCENE, EVENTID_SCENE_LOADED, self.OnThemeLevelLoaded, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_RECEIVE_INHERIT_DATA, self.OnReceiveInheritData, self)
  self:AddCommonEvent(EVENTTYPE_CAMERA, EVENTID_REAL_CAMERA_SWITCHED, self.OnCameraSwitched, self)
end
function ThemeVehicleManager:OnPreSwitchGameStatus(preState, nextState)
  self:DestroyAllThemeVehiclesOnly()
  local logic_lobby_garage_scene = require("client.maps.logic_lobby_garage_scene")
  logic_lobby_garage_scene.SetTAA(false)
end
function ThemeVehicleManager:ShowThemeVehicle()
  log(bWriteLog and "ThemeVehicleManager:ShowThemeVehicle")
  if HallThemeUtils.IsThemePreviewStatus() then
    log(bWriteLog and "ThemeVehicleManager:ShowThemeVehicle IsThemePreviewStatus")
    return
  end
  local bInvalidStatus = not GameStatus.IsInLobbyOrMainCity()
  if bInvalidStatus then
    log(bWriteLog and "ThemeVehicleManager:ShowThemeVehicle GameStatus not lobby or maincity")
    return
  end
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission() then
    log(bWriteLog and "ThemeVehicleManager:ShowThemeVehicle IsInXMission")
    return
  end
  if HallThemeUtils.themeShowMode == 1 then
    return
  end
  if HallThemeUtils.themeShowMode == 0 then
    self:_ShowSelfVehicle()
    return
  end
  if HallThemeUtils.themeShowMode == 2 then
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    local uid = TeamUpNewSystem.nShowVehicleUID
    if GetGarageThemeSystem():IsInGarageTheme() then
      uid = TeamUpNewSystem.teamInfo.leader
    end
    if not uid or uid == 0 or uid == TeamUpNewSystem.GetSelfUID() then
      self:_ShowSelfVehicle()
    else
      self:_ShowTeamVehicle(uid)
    end
  end
end
function ThemeVehicleManager:_ShowSelfVehicle()
  log(bWriteLog and "ThemeVehicleManager:_ShowSelfVehicle")
  if not GetGarageThemeSystem():IsInGarageTheme() and not HallThemeUtils.themeVehicleShow then
    self:DestoryAllThemeVehicles()
    log(bWriteLog and "ThemeVehicleManager:_ShowSelfVehicle not HallThemeUtils.themeVehicleShow")
    return
  end
  local VehicleRefitHandler = require("client.network.Protocol.VehicleRefitHandler")
  local VehicleInfos = self:GetSelfVehicleInfo()
  for Position, Info in pairs(VehicleInfos) do
    if Info then
      local ItemID = Info.ItemID or 0
      local source = Info.Source or EWardrobeDataSource.Wardrobe
      local StyleList = VehicleRefitHandler.GetCarStyleList(ItemID, nil, nil, nil, source)
      local EnableHighTire = GetVehicleCollectSystem():IsOpenHighTire(ItemID, DataMgr.roleData.uid, nil, source)
      local LogicVehicleAccessory = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicVehicleAccessory)
      local accessoryList = LogicVehicleAccessory:GetEquipedAccessoryList(ItemID, source)
      local LogicVehicleExtendedFeature = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicVehicleExtendedFeature)
      local ChassisLight = LogicVehicleExtendedFeature:GetEquipedChassisLightData(ItemID, source)
      self:_TryCreateVehicleModel(ItemID, StyleList, EnableHighTire, Position, accessoryList, ChassisLight, DataMgr.roleData.uid)
    end
  end
  self:OnVehicleChange()
end
function ThemeVehicleManager:_ShowTeamVehicle(UID)
  log(bWriteLog and "ThemeVehicleManager:_ShowTeamVehicle")
  local VehicleIDs = self:GetTeamVehicleIDs(UID)
  for Position, ItemID in pairs(VehicleIDs) do
    local StyleList = GetGarageThemeSystem():GetTeamCarStyleList(UID, ItemID, Position)
    local EnableHighTire = GetVehicleCollectSystem():IsOpenHighTire(ItemID, UID, Position)
    local LogicVehicleAccessory = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicVehicleAccessory)
    local accessoryList = LogicVehicleAccessory:GetVehicleAccessoryList(UID, ItemID, Position)
    local LogicVehicleExtendedFeature = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicVehicleExtendedFeature)
    local ChassisLightData = LogicVehicleExtendedFeature:GetVehicleChassisLightData(UID, ItemID, Position, EWardrobeDataSource.Wardrobe)
    self:_TryCreateVehicleModel(ItemID, StyleList, EnableHighTire, Position, accessoryList, ChassisLightData, UID)
  end
  local LogicVehicleDIY = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicVehicleDIY)
  LogicVehicleDIY:UpdateTeammateData(UID)
  self:OnVehicleChange()
end
function ThemeVehicleManager:PreviewGarageVehicle(VehicleType)
  local VehicleIDs = GetGarageThemeSystem():GetGaragePreviewCarList(VehicleType)
  if not VehicleIDs then
    log(bWriteLog and "ThemeVehicleManager:PreviewGarageVehicle not VehicleIDs VehicleType:" .. tostring(VehicleType))
    return
  end
  for Position, ItemID in pairs(VehicleIDs) do
    self:_TryCreateVehicleModel(ItemID, {}, false, Position)
  end
  self:OnVehicleChange()
end
function ThemeVehicleManager:GetSelfVehicleIDs()
  local List = {}
  if GetGarageThemeSystem():IsInGarageTheme() then
    List = GetGarageThemeSystem():GetSelfGarageVehicleIDs()
  else
    List = {
      HallThemeUtils.GetThemeVehicleItemId()
    }
  end
  local Result = {}
  local MaxNum = GetGarageThemeSystem():GetMaxPositionNum()
  for i = 1, MaxNum do
    table.insert(Result, List[i] or 0)
  end
  return Result
end
function ThemeVehicleManager:GetSelfVehicleInfo()
  local List = {}
  if GetGarageThemeSystem():IsInGarageTheme() then
    List = GetGarageThemeSystem():GetSelfGarageVehicleAndSource()
  else
    local ItemID, Source = HallThemeUtils.GetThemeVehicleItemIdAndSource()
    List = {
      {ItemID = ItemID, Source = Source}
    }
  end
  local Result = {}
  local MaxNum = GetGarageThemeSystem():GetMaxPositionNum()
  for i = 1, MaxNum do
    table.insert(Result, List[i] or {})
  end
  return Result
end
function ThemeVehicleManager:GetTeamVehicleIDs(uid)
  local List = {}
  if GetGarageThemeSystem():IsInGarageTheme() then
    List = GetGarageThemeSystem():GetTeamGarageVehicleIDs(uid)
  else
    local ItemId = HallThemeUtils.GetTeamMemberVehicle(uid)
    List = {ItemId}
  end
  local MaxNum = GetGarageThemeSystem():GetMaxPositionNum()
  local Result = {}
  for i = 1, MaxNum do
    table.insert(Result, List[i] or 0)
  end
  return Result
end
function ThemeVehicleManager:DestroyAllThemeVehiclesOnly()
  for key, Vehicle in pairs(self.Vehicles) do
    if slua.isValid(Vehicle) then
      Vehicle:Destroy()
    end
  end
  self.Vehicles = {}
  self.RepeatTags = {}
end
function ThemeVehicleManager:DestoryAllThemeVehicles()
  for key, Vehicle in pairs(self.Vehicles) do
    if slua.isValid(Vehicle) then
      Vehicle:Destroy()
    end
  end
  self.Vehicles = {}
  self.RepeatTags = {}
  self:OnVehicleChange()
end
function ThemeVehicleManager:DestoryThemeVehicle(Position)
  if slua.isValid(self.Vehicles[Position]) then
    self.Vehicles[Position]:Destroy()
  end
  self.Vehicles[Position] = nil
  self.RepeatTags[Position] = nil
  self:OnVehicleChange()
end
local CombineTag = function(ItemId, StyleList, EnableHighTire, vehicleAccssory, ChassisLightId, UID)
  local Tag = tostring(ItemId) .. "_" .. tostring(GetLobbyThemeManager():GetDisplayItemID()) .. "_"
  for _, value in pairs(StyleList) do
    Tag = Tag .. tostring(value) .. "_"
  end
  if vehicleAccssory and next(vehicleAccssory) then
    local accessoryList = {}
    for accitemId, _ in pairs(vehicleAccssory) do
      table.insert(accessoryList, accitemId)
    end
    table.sort(accessoryList)
    for _, accitemId in pairs(accessoryList) do
      Tag = Tag .. tostring(accitemId) .. "_"
    end
  end
  if type(ChassisLightId) == "number" then
    Tag = Tag .. tostring(ChassisLightId) .. "_"
  end
  Tag = Tag .. tostring(EnableHighTire) .. tostring(UID)
  return Tag
end
function ThemeVehicleManager:_TryCreateVehicleModel(ItemId, StyleList, EnableHighTire, Position, vehicleAccssory, ChassisLight, UID)
  log_tree("ThemeVehicleManager:_TryCreateVehicleModel", {
    ItemId,
    StyleList,
    EnableHighTire,
    Position
  })
  if not ItemId or ItemId == 0 then
    log(bWriteLog and "ThemeVehicleManager:_TryCreateVehicleModel not ItemId ")
    self:DestoryThemeVehicle(Position)
    return
  end
  local Tag = CombineTag(ItemId, StyleList, EnableHighTire, vehicleAccssory, ChassisLight, UID)
  if self.RepeatTags[Position] == Tag then
    log(bWriteLog and "ThemeVehicleManager:_TryCreateVehicleModel Is Repate " .. tostring(Tag))
    return
  end
  self.RepeatTags[Position] = Tag
  local TransForm = self:GetVehicleTransform(ItemId, Position)
  if not TransForm then
    self:DestoryThemeVehicle(Position)
    return
  end
  self:_CreateVehicleModel(ItemId, StyleList, EnableHighTire, Position, TransForm, vehicleAccssory, ChassisLight, UID)
end
function ThemeVehicleManager:_ReinitShowModelActor(VehicleActor, ItemId, StyleList, EnableHighTire, Position, TransForm, vehicleAccssory, ChassisLight, UID)
  if not slua.isValid(VehicleActor) then
    log(bWriteLog and "ThemeVehicleManager:_CreateVehicleModel VehicleActor is not Valid")
    return
  end
  VehicleActor:K2_SetActorLocation(TransForm[1], false, nil, false)
  VehicleActor:K2_SetActorRotation(FRotator(TransForm[2].Y, TransForm[2].Z, TransForm[2].X), false)
  VehicleActor:SetActorScale3D(TransForm[3])
  local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
  local bRefitVehicle = ModelDisplayTypeHelper.IsRefitVehicle(ItemId)
  local ExtraTable = {
    EnableHighTire = EnableHighTire,
    AccessoryList = vehicleAccssory,
    ChassisLight = ChassisLight,
    is_hall_vehicle = true
  }
  if bRefitVehicle then
    ExtraTable.is_refit_vehicle = true
    ExtraTable.refit_vehicle_no_possess = true
    ExtraTable.refit_vehicle_no_autoplay = true
    ExtraTable.refit_vehicle_cast_shadow = true
  else
    ExtraTable.NotOpenDoor = true
  end
  if GetGarageThemeSystem():IsInGarageTheme() then
    ExtraTable.download_3dui = true
  end
  if ItemId == 19106001 then
    ExtraTable.is_hall_vehicle = false
  end
  VehicleActor:ShowModelByResID(ItemId, ExtraTable)
  local RefitVehicle = require("client.logic.vehicle.logic_refit_vehicle")
  if slua.isValid(VehicleActor) and bRefitVehicle and VehicleActor:GetrefitVehicleActor() and slua.isValid(VehicleActor:GetrefitVehicleActor()) then
    VehicleActor:GetrefitVehicleActor():SetActorTickEnabled(false)
    RefitVehicle.EquipStyleList(VehicleActor:GetrefitVehicleActor(), StyleList)
  end
  local Vehicle = VehicleActor:GetVehicleActor()
  if slua.isValid(Vehicle) and Vehicle.BP_VehicleDIYComp then
    Vehicle.BP_VehicleDIYComp:UpdateCarOwnerInLobby(UID, ItemId)
  end
  if GetGarageThemeSystem():IsInGarageTheme() and slua.isValid(Vehicle) and slua.isValid(Vehicle.Mesh) then
    Vehicle.Mesh:SetCastPhotonShadow(Position == 1)
  end
end
function ThemeVehicleManager:_CreateVehicleModel(ItemId, StyleList, EnableHighTire, Position, TransForm, vehicleAccssory, ChassisLight, UID)
  log(bWriteLog and "ThemeVehicleManager:_CreateVehicleModel ItemId" .. tostring(ItemId))
  local ModelFactory = require("client.slua.logic.show_actor.common.ModelFactory")
  if not slua.isValid(self.Vehicles[Position]) then
    local Actor = ModelFactory.CreateShowActor()
    self.Vehicles[Position] = Actor
  end
  local VehicleActor = self.Vehicles[Position]
  self:_ReinitShowModelActor(VehicleActor, ItemId, StyleList, EnableHighTire, Position, TransForm, vehicleAccssory, ChassisLight, UID)
end
function ThemeVehicleManager:GetVehicleTransform(ItemId, Position)
  local TransForm
  local ThemeId = GetLobbyThemeManager():GetDisplayItemID()
  if GetGarageThemeSystem():IsGarageTheme(ThemeId) then
    TransForm = self:GetGarageThemeTransform(ThemeId, ItemId, Position)
  else
    TransForm = HallThemeUtils.GetVehicleCreateParam(ThemeId, ItemId)
  end
  return TransForm
end
function ThemeVehicleManager:GetGarageThemeTransform(ThemeId, ItemId, Position)
  log(bWriteLog and "HallThemeUtils GetVehicleCreateParam ThemeId:" .. tostring(ThemeId) .. " ItemId:" .. tostring(ItemId) .. " Position:" .. tostring(Position))
  local cfgItem = CDataTable.GetTableData("Item", ItemId)
  if not cfgItem then
    log(bWriteLog and "ThemeVehicleManager:GetGarageThemeTransform Can`t find Item " .. tostring(ItemId))
    return
  end
  local _Key = tostring(ThemeId) .. "_" .. tostring(Position)
  local cfgTheme = CDataTable.GetTableData("GarageThemeTransConfig", _Key)
  if not cfgTheme then
    log(bWriteLog and "ThemeVehicleManager:GetGarageThemeTransform Can`t find _Key " .. tostring(_Key))
    return
  end
  local Transform = {}
  local pos = cfgTheme.vehiclePosition
  local rotation = cfgTheme.vehicleRotation
  local scale = cfgTheme.vehicleScale
  local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
  if ModelDisplayTypeHelper.IsMotor(cfgItem.ItemSubType) then
    scale = cfgTheme.MotoScale
  elseif cfgItem.ItemSubType == ENUM_ITEM_SUBTYPE.Tank then
    scale = cfgTheme.TankScale
  elseif cfgItem.ItemSubType == ENUM_ITEM_SUBTYPE.Bicycle then
    scale = cfgTheme.BicycleScale
  elseif cfgItem.ItemSubType == ENUM_ITEM_SUBTYPE.MonsterTrunk then
    scale = cfgTheme.MonsterTrunkScale
  elseif cfgItem.ItemSubType == ENUM_ITEM_SUBTYPE.MTLB then
    scale = cfgTheme.MTLBScale
  end
  log_tree("ThemeVehicleManager:GetGarageThemeTransform Transform", {
    pos,
    rotation,
    scale
  })
  pos = LobbySceneManager.ParseVec3(pos)
  rotation = LobbySceneManager.ParseVec3(rotation)
  scale = LobbySceneManager.ParseVec3(scale)
  table.insert(Transform, FVector(pos.x_f, pos.y_f, pos.z_f))
  table.insert(Transform, FVector(rotation.x_f, rotation.y_f, rotation.z_f))
  table.insert(Transform, FVector(scale.x_f, scale.y_f, scale.z_f))
  return Transform
end
function ThemeVehicleManager:OnGarageVehicleChange()
  self:ShowThemeVehicle()
end
function ThemeVehicleManager:SetVehicleHighLight(Position, Enable)
  log(bWriteLog and "ThemeVehicleManager:SetVehicleHighLight Position " .. tostring(Position) .. " Enbale " .. tostring(Enable))
  local VehicleActor = self.Vehicles[Position]
  if not slua.isValid(VehicleActor) then
    return
  end
  local HighLightArgs = {}
  if Enable then
    HighLightArgs = {
      Invincible = 0.5,
      FreExp = 10,
      Speed = 0
    }
  else
    HighLightArgs = {
      Invincible = 0,
      FreExp = 3,
      Speed = 1
    }
  end
  VehicleActor:SetHighLight(HighLightArgs.Invincible, HighLightArgs.FreExp, HighLightArgs.Speed)
end
function ThemeVehicleManager:OnHallThemeBeginChange()
  log(bWriteLog and "ThemeVehicleManager:OnHallThemeBeginChange")
  self:ShowThemeVehicle()
end
function ThemeVehicleManager:OnThemeLevelLoaded(_, _, LevelName)
  if LevelName == "Lobby_CarShowRoom_310" or LevelName == "Lobby_CarShowRoom_New" then
    log(bWriteLog and "ThemeVehicleManager:OnThemeLevelLoaded")
    GetLobbyThemeManager():ShowGarageEffect(false, -1, true)
    self:RefreshSpecialEffect()
  end
end
function ThemeVehicleManager:OnCameraSwitched(_, _, CameraID)
  if not self.Vehicles then
    return
  end
  if LobbySceneManager == nil then
    require("client.slua.logic.manager.LobbySceneMgr")
  end
  if LobbySceneManager and LobbySceneManager.IsMainLobbyCameraID(CameraID) then
    for _, VehicleActor in pairs(self.Vehicles) do
      if VehicleActor then
        VehicleActor:UpdateDownload3DUITransform()
      end
    end
  end
end
function ThemeVehicleManager:OnReceiveInheritData()
  log(bWriteLog and "ThemeVehicleManager:OnReceiveInheritData")
  self:ShowThemeVehicle()
end
function ThemeVehicleManager:RefreshSpecialEffect()
  local bShow = self:NeedShowSpecialThemeEffect()
  GetLobbyThemeManager():ShowGarageEffect(bShow, self:GetVehiclesType())
end
function ThemeVehicleManager:NeedShowSpecialThemeEffect()
  if not self:HaveEnoughVehicleShowSpecial() then
    return false
  end
  local VehicleType = self:GetVehiclesType()
  if VehicleType == -1 then
    return false
  end
  if not self:CheckVehicleTypeHasUnlock(VehicleType) then
    return false
  end
  return true
end
function ThemeVehicleManager:CheckVehicleTypeHasUnlock(vehicleType)
  vehicleType = tonumber(vehicleType)
  if not vehicleType then
    log(bWriteLog and "ThemeVehicleManager:CheckVehicleTypeHasUnlock vehicleType is nil")
    return false
  end
  local VehicleCollectSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.VehicleCollectSystem)
  local carCollectionUnlockTable = VehicleCollectSystem:GetCarCollectionUnlockTable()
  if not carCollectionUnlockTable then
    log(bWriteLog and "ThemeVehicleManager:CheckVehicleTypeHasUnlock carCollectionUnlockTable is nil")
    return false
  end
  local ValidTimeString = carCollectionUnlockTable[vehicleType]
  if not ValidTimeString then
    log(bWriteLog and "ThemeVehicleManager:CheckVehicleTypeHasUnlock ValidTimeString is nil")
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local ValidTime = TimeUtil.TimeStringToUnixstamp(ValidTimeString, false)
  local ServerTime = FuncUtil.GetServerTimeInSec()
  if ValidTime > ServerTime then
    log(bWriteLog and "ThemeVehicleManager:CheckVehicleTypeHasUnlock ValidTime > ServerTime")
    return false
  end
  log(bWriteLog and "ThemeVehicleManager:CheckVehicleTypeHasUnlock true")
  return true
end
function ThemeVehicleManager:GetVehiclesType()
  local VehicleType
  for Position, Vehicle in pairs(self.Vehicles) do
    if slua.isValid(Vehicle) then
      local ItemID = Vehicle:GetCurrentItemId()
      local _VehicleType = GetVehicleCollectSystem():GetVehicleType(ItemID)
      VehicleType = VehicleType or _VehicleType
      if VehicleType ~= _VehicleType then
        return -1
      end
    end
  end
  return VehicleType or -1
end
function ThemeVehicleManager:HaveEnoughVehicleShowSpecial()
  local VehicleNum = self:GetValidVehicleNum()
  if VehicleNum < GetGarageThemeSystem():GetSpecialEffectUnlockNum() then
    return false
  end
  return true
end
function ThemeVehicleManager:GetValidVehicleNum()
  local VehicleNum = 0
  for Position, Vehicle in pairs(self.Vehicles) do
    if slua.isValid(Vehicle) then
      VehicleNum = VehicleNum + 1
    end
  end
  return VehicleNum
end
function ThemeVehicleManager:OnVehicleChange()
  self:RefreshSpecialEffect()
end
function ThemeVehicleManager:SetVehicleTick(bTick)
  log(bWriteLog and "ThemeVehicleManager:SetVehicleTick bTick = " .. tostring(bTick))
  local performance_util = require("client.slua.logic.performance.performance_util")
  performance_util:SetVehicleTick(self.Vehicles, bTick)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CThemeVehicleManager = class(CModuleBase, nil, ThemeVehicleManager)
return CThemeVehicleManager