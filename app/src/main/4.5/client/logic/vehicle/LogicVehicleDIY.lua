local struct_DIYVehicleParamData = import("DIYVehicleParamData")
local struct_UserVehicleDIYData = {
  applique_id = 0,
  position = {
    x = 0,
    y = 0,
    z = 0
  },
  normal = {
    x = 0,
    y = 0,
    z = 1
  },
  rotation = 0.0,
  scale = 0.0,
  replication = false
}
local struct_CarAppliqueData = {
  version = 0,
  appliques = {}
}
local LogicVehicleDIY = {}
function LogicVehicleDIY:DefineAndResetData()
  self.EditVehicleID = nil
  self.EditVehicle = nil
  self.VehicleWorldPos = nil
  self.EditSlotIndex = 0
  self.EditData = nil
  self.EquipData = {}
  self.tRemoveData = {}
  self.CONST = {
    Default = {
      Location = FVector(18, 100, 50),
      Normal = FVector(0, 1, 0),
      Scale = 40,
      Rotation = 90,
      Version = 0
    },
    MaxSlotCount = 4
  }
  self.PlayerEquipData = {}
  self.bInitPlayerData = false
  self.PendingRequestArray = {}
  self.OtherPlayerData = {}
end
function LogicVehicleDIY:OnInitialize()
end
function LogicVehicleDIY:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_VEHICLE_DIY, EVENTID_VEHICLE_DIY_MOVE_UI, self.HandleEditMove, self)
  self:AddCommonEvent(EVENTTYPE_VEHICLE_DIY, EVENTID_VEHICLE_DIY_RESIZE_UI, self.HandleEditResize, self)
  self:AddCommonEvent(EVENTTYPE_BATTLEPROFILE, EVENTID_BATTLEPROFILE_BATCHGET_RES, self.OnBattleProfileBatchGet, self)
end
function LogicVehicleDIY:OnPostSwitchGameStatus(preState, nextState)
  log(bWriteLog and "LogicVehicleDIY:OnPostSwitchGameStatus")
  self.OtherPlayerData = {}
  if nextState == GameStatus.Fighting and not GameStatus.IsInLobbyOrMainCity() and not self.bInitPlayerData then
    log(bWriteLog and "LogicVehicleDIY:GetDIYData before enter fighting")
    local VehicleDIYHandler = require("client.network.Protocol.VehicleDIYHandler")
    VehicleDIYHandler.send_get_car_applique_data_req()
  end
end
function LogicVehicleDIY:BeginEditDIYVehicle(EditVehicleID, curShowActor, SelectTexID)
  self.  self.EditVehicle = curShowActor:GetVehicleActor()
  self.VehicleWorldPos = curShowActor:K2_GetActorLocation()
  self:ChangeCameraRotation(FRotator(0, -90, 0))
  self:SetVehicleCollision(true)
  self:VehicleCabrioletUpdate(false)
  self:InitEquipData()
  UIManager.ShowUI(UIManager.UI_Config.Vehicle_DetailShow_Applique_UIBP, SelectTexID)
  local mainUI = UIManager.GetUI(UIManager.UI_Config.Vehicle_DetailShow_UIBP)
  mainUI:Collapsed()
end
function LogicVehicleDIY:EndEditDIYVehicle()
  self:SetVehicleCollision(false)
  self:VehicleCabrioletUpdate(true)
  self:InitEquipData()
  self.EditVehicle = nil
end
function LogicVehicleDIY:SetCanTouchRotate(can)
  local logic_SuperCar_200Version = require("client.maps.logic_SuperCar_200Version")
  logic_SuperCar_200Version.SetSpringArmCamCanTouchRotate(can)
end
function LogicVehicleDIY:ChangeCameraRotation(Rotation)
  local logic_SuperCar_200Version = require("client.maps.logic_SuperCar_200Version")
  logic_SuperCar_200Version.ChangeCameraRotation(Rotation)
end
function LogicVehicleDIY:SetVehicleCollision(can)
  if not slua.isValid(self.EditVehicle) then
    log(bWriteLog and "LogicVehicleDIY:SetVehicleCollision not EditVehicle")
    return
  end
  if self.EditVehicle.Mesh then
    local ECollisionEnabled = import("ECollisionEnabled")
    local ECollisionResponse = import("ECollisionResponse")
    if can then
      local Path = self:GetStaticMeshPath()
      if Path and Path ~= "" then
        if not slua.isValid(self.StaticMeshActor) then
          local AStaticMeshActor = import("StaticMeshActor")
          local world = slua_GameFrontendHUD:GetWorld()
          self.StaticMeshActor = world:SpawnActor(AStaticMeshActor, self.EditVehicle:K2_GetActorLocation(), self.EditVehicle:K2_GetActorRotation(), nil)
        end
        local Util = require("client.slua_ui_framework.util")
        Util.GetAssetAsync(Path, function(LoadObj)
          if slua.isValid(self.StaticMeshActor) then
            self.StaticMeshActor.StaticMeshComponent:SetVisibility(false, false)
            local CreativeModeBlueprintLibrary = import("CreativeModeBlueprintLibrary")
            local EComponentMobility = import("EComponentMobility")
            CreativeModeBlueprintLibrary.SetStaticMeshMobility(self.StaticMeshActor.StaticMeshComponent, EComponentMobility.Movable)
            self.StaticMeshActor.StaticMeshComponent:SetStaticMesh(LoadObj)
            self.StaticMeshActor.StaticMeshComponent:SetCollisionEnabled(import("ECollisionEnabled").QueryAndPhysics)
          end
        end)
        self.EditVehicle.Mesh:SetCollisionEnabled(ECollisionEnabled.NoCollision)
        self.EditVehicle.Mesh:SetCollisionResponseToAllChannels(ECollisionResponse.ECR_Ignore)
      else
        self.EditVehicle.Mesh:SetCollisionEnabled(ECollisionEnabled.QueryAndPhysics)
        self.EditVehicle.Mesh:SetCollisionResponseToAllChannels(ECollisionResponse.ECR_Block)
      end
    else
      if self.StaticMeshActor then
        self.StaticMeshActor:K2_DestroyActor()
        self.StaticMeshActor = nil
      end
      self.EditVehicle.Mesh:SetCollisionEnabled(ECollisionEnabled.NoCollision)
      self.EditVehicle.Mesh:SetCollisionResponseToAllChannels(ECollisionResponse.ECR_Ignore)
    end
  end
end
function LogicVehicleDIY:VehicleCabrioletUpdate(open)
  log(bWriteLog and "LogicVehicleDIY:VehicleCabrioletUpdate " .. tostring(open))
  if not slua.isValid(self.EditVehicle) then
    return
  end
  if self.EditVehicle.PlayCabrioAnim then
    self.EditVehicle:PlayCabrioAnim(open)
  end
end
function LogicVehicleDIY:GetStaticMeshPath()
  local Cfg = CDataTable.GetTableData("VehicleDIYCfg", self.EditVehicleID)
  if Cfg then
    return Cfg.StaticMeshPath
  end
  return nil
end
function LogicVehicleDIY:InitEquipData()
  self.EquipData = {}
  self.EditData = nil
  self.EditSlotIndex = 0
  local originData = self:GetEditOriginAppliqueData()
  if originData and originData.appliques then
    local TableUtil = require("common.table_util")
    self.EquipData = TableUtil.CopyTable(originData.appliques)
  end
  self:DrawEditDataToVehicle()
end
function LogicVehicleDIY:GenerateEditData(TexID)
  if not self.EditData then
    self.EditData = self:GenerateDefaultData(TexID, self.EditVehicleID)
  else
    self.EditData.applique_id = TexID
  end
  self.EditSlotIndex = 0
end
function LogicVehicleDIY:SelectEditData(index)
  self.EditSlotIndex = index
end
function LogicVehicleDIY:ConvertUserVehicleDIYData(UserVehicleDIYData, bMirror)
  local DIYVehicleParamData = struct_DIYVehicleParamData()
  DIYVehicleParamData.TexPathID = UserVehicleDIYData.applique_id
  DIYVehicleParamData.Scale = UserVehicleDIYData.scale
  if bMirror then
    DIYVehicleParamData.Rotation = 360 - UserVehicleDIYData.rotation
    DIYVehicleParamData.Location = FVector(UserVehicleDIYData.position.x, -UserVehicleDIYData.position.y, UserVehicleDIYData.position.z)
    DIYVehicleParamData.Normal = FVector(UserVehicleDIYData.normal.x, -UserVehicleDIYData.normal.y, UserVehicleDIYData.normal.z)
  else
    DIYVehicleParamData.Rotation = UserVehicleDIYData.rotation
    DIYVehicleParamData.Location = FVector(UserVehicleDIYData.position.x, UserVehicleDIYData.position.y, UserVehicleDIYData.position.z)
    DIYVehicleParamData.Normal = FVector(UserVehicleDIYData.normal.x, UserVehicleDIYData.normal.y, UserVehicleDIYData.normal.z)
    DIYVehicleParamData.Mirror = true
  end
  return DIYVehicleParamData
end
function LogicVehicleDIY:ConvertUserVehicleDIYDataList(UserVehicleDIYDataList)
  local DIYVehicleParamDataArray = slua.Array(UEnums.EPropertyClass.Struct, struct_DIYVehicleParamData)
  if UserVehicleDIYDataList then
    for _, UserVehicleDIYData in ipairs(UserVehicleDIYDataList) do
      DIYVehicleParamDataArray:Add(self:ConvertUserVehicleDIYData(UserVehicleDIYData))
      if UserVehicleDIYData.replication then
        DIYVehicleParamDataArray:Add(self:ConvertUserVehicleDIYData(UserVehicleDIYData, true))
      end
    end
  end
  return DIYVehicleParamDataArray
end
function LogicVehicleDIY:HandleEditMove(_, _, location, normal)
  if not self.EditVehicle then
    return
  end
  local data = self:GetCurrentEditData()
  if data and location and normal then
    data.position.x = location.X - self.VehicleWorldPos.X
    data.position.y = location.Y - self.VehicleWorldPos.Y
    data.position.z = location.Z - self.VehicleWorldPos.Z
    data.normal.x = normal.X
    data.normal.y = normal.Y
    data.normal.z = normal.Z
  end
  self:DrawEditDataToVehicle()
end
function LogicVehicleDIY:HandleEditResize(_, _, scale, angle)
  if not self.EditVehicle then
    return
  end
  local data = self:GetCurrentEditData()
  if data then
    data.scale = self.CONST.Default.Scale * scale
    data.rotation = self.CONST.Default.Rotation + angle
    if data.rotation > 360 then
      data.rotation = data.rotation - 360
    elseif data.rotation < 0 then
      data.rotation = data.rotation + 360
    end
  end
  self:DrawEditDataToVehicle()
end
function LogicVehicleDIY:HandleReplicate()
  log(bWriteLog and "LogicVehicleDIY:HandleReplicate")
  local data = self:GetCurrentEditData()
  if data then
    data.replication = not data.replication
  end
  self:DrawEditDataToVehicle()
  if self.EditSlotIndex ~= 0 then
    EventSystem:postEvent(EVENTTYPE_VEHICLE_DIY, EVENTID_VEHICLE_DIY_UPDATE_EQUIP_LIST)
  end
end
function LogicVehicleDIY:HandleEquip()
  log(bWriteLog and "LogicVehicleDIY:HandleEquip")
  if not self.EditData then
    log(bWriteLog and "LogicVehicleDIY:HandleEquip not EditData")
    return
  end
  table.insert(self.EquipData, self.EditData)
  self.EditData = nil
  EventSystem:postEvent(EVENTTYPE_VEHICLE_DIY, EVENTID_VEHICLE_DIY_UPDATE_EQUIP_LIST)
end
function LogicVehicleDIY:HandleDelete()
  log(bWriteLog and "LogicVehicleDIY:HandleDelete, " .. tostring(self.EditSlotIndex))
  if self.EditSlotIndex == 0 then
    self.EditData = nil
  else
    table.insert(self.tRemoveData, self.EquipData[self.EditSlotIndex])
    table.remove(self.EquipData, self.EditSlotIndex)
  end
  self:DrawEditDataToVehicle()
  if self.EditSlotIndex ~= 0 then
    EventSystem:postEvent(EVENTTYPE_VEHICLE_DIY, EVENTID_VEHICLE_DIY_UPDATE_EQUIP_LIST)
  end
end
function LogicVehicleDIY:HandleSwitch(from, to)
  log(bWriteLog and "LogicVehicleDIY:HandleDelete, " .. tostring(from) .. tostring(to))
  local fromData = self.EquipData[from]
  local toData = self.EquipData[to]
  self.EquipData[from] = toData
  self.EquipData[to] = fromData
  self:DrawEditDataToVehicle()
  EventSystem:postEvent(EVENTTYPE_VEHICLE_DIY, EVENTID_VEHICLE_DIY_UPDATE_EQUIP_LIST)
end
function LogicVehicleDIY:DrawEditDataToVehicle()
  if not slua.isValid(self.EditVehicle) then
    log(bWriteLog and "LogicVehicleDIY:DrawEditDataToVehicle not EditVehicle")
    return
  end
  local ParamDataArray = self:ConvertUserVehicleDIYDataList(self.EquipData)
  if self.EditData then
    ParamDataArray:Add(self:ConvertUserVehicleDIYData(self.EditData))
    if self.EditData.replication then
      ParamDataArray:Add(self:ConvertUserVehicleDIYData(self.EditData, true))
    end
  end
  self.EditVehicle.BP_VehicleDIYComp:AddDIYPattern(ParamDataArray)
end
function LogicVehicleDIY:PreviewApplique(Vehicle, VehicleID, TexID)
  if not Vehicle or not Vehicle.BP_VehicleDIYComp then
    return
  end
  local DIYData = self:GenerateDefaultData(TexID, VehicleID)
  local PreviewData = {}
  local originData = self:GetAppliqueData(VehicleID)
  if originData and originData.appliques then
    local TableUtil = require("common.table_util")
    PreviewData = TableUtil.CopyTable(originData.appliques)
  end
  table.insert(PreviewData, DIYData)
  local ParamList = self:ConvertUserVehicleDIYDataList(PreviewData)
  Vehicle.BP_VehicleDIYComp:AddDIYPattern(ParamList)
end
function LogicVehicleDIY:ClearPreview(Vehicle, VehicleID)
  if not Vehicle or not Vehicle.BP_VehicleDIYComp then
    return
  end
  local PreviewData = {}
  local originData = self:GetAppliqueData(VehicleID)
  if originData and originData.appliques then
    PreviewData = originData.appliques
  end
  local ParamList = self:ConvertUserVehicleDIYDataList(PreviewData)
  Vehicle.BP_VehicleDIYComp:AddDIYPattern(ParamList, true)
end
function LogicVehicleDIY:GenerateDefaultData(TexID, VehicleID)
  local UserVehicleDIYData = {
    applique_id = TexID,
    position = {
      x = self.CONST.Default.Location.X,
      y = self.CONST.Default.Location.Y,
      z = self.CONST.Default.Location.Z
    },
    normal = {
      x = self.CONST.Default.Normal.X,
      y = self.CONST.Default.Normal.Y,
      z = self.CONST.Default.Normal.Z
    },
    rotation = self.CONST.Default.Rotation,
    scale = self.CONST.Default.Scale,
    replication = false
  }
  local itemCfg = CDataTable.GetTableData("Item", VehicleID)
  if itemCfg and itemCfg.ItemSubType and itemCfg.ItemSubType == 953 then
    UserVehicleDIYData.position.x = 60
    UserVehicleDIYData.position.y = 120
    UserVehicleDIYData.position.z = 180
  end
  return UserVehicleDIYData
end
function LogicVehicleDIY:GetAppliqueData(car_id)
  return self.PlayerEquipData[car_id]
end
function LogicVehicleDIY:GetEditOriginAppliqueData()
  if not self.EditVehicleID then
    return nil
  end
  if not self.bInitPlayerData then
    log(bWriteLog and "LogicVehicleDIY:GetEditOriginAppliqueData first time to request")
    local VehicleDIYHandler = require("client.network.Protocol.VehicleDIYHandler")
    VehicleDIYHandler.send_get_car_applique_data_req()
    return nil
  end
  return self.PlayerEquipData[self.EditVehicleID]
end
function LogicVehicleDIY:GetCurrentEditData()
  local data
  if self.EditSlotIndex == 0 then
    data = self.EditData
  else
    data = self.EquipData[self.EditSlotIndex]
  end
  return data
end
function LogicVehicleDIY:GetDeleteAppliqueData()
  return self.tRemoveData
end
function LogicVehicleDIY:ClearDeleteAppliqueData()
  self.tRemoveData = {}
end
function LogicVehicleDIY:CheckAppliqueData(AppliqueData)
  if not AppliqueData or type(AppliqueData) ~= "table" then
    return false
  end
  if not (AppliqueData.scale and AppliqueData.rotation and AppliqueData.applique_id) or AppliqueData.applique_id == 0 then
    return false
  end
  if AppliqueData.scale < 20 or AppliqueData.scale > 80 then
    return false
  end
  if AppliqueData.rotation < 0 or AppliqueData.rotation > 360 then
    return false
  end
  if not (AppliqueData.position and AppliqueData.normal) or type(AppliqueData.position) ~= "table" or type(AppliqueData.normal) ~= "table" then
    return false
  end
  if not (AppliqueData.position.x and AppliqueData.position.y) or not AppliqueData.position.z then
    return false
  end
  if not (AppliqueData.normal.x and AppliqueData.normal.y) or not AppliqueData.normal.z then
    return false
  end
  if AppliqueData.position.x < -300 or AppliqueData.position.x > 300 or AppliqueData.position.y < -200 or AppliqueData.position.y > 200 or AppliqueData.position.z < -10 or AppliqueData.position.z > 400 then
    return false
  end
  if AppliqueData.normal.x < -1 or AppliqueData.normal.x > 1 or AppliqueData.normal.y < -1 or AppliqueData.normal.y > 1 or AppliqueData.normal.z < -1 or AppliqueData.normal.z > 1 then
    return false
  end
  return true
end
function LogicVehicleDIY:GetDIYData(UID, car_id)
  UID = tostring(UID)
  if UID == DataMgr.roleData.uid then
    if not self.bInitPlayerData then
      log(bWriteLog and "LogicVehicleDIY:GetDIYData first time to request")
      local VehicleDIYHandler = require("client.network.Protocol.VehicleDIYHandler")
      VehicleDIYHandler.send_get_car_applique_data_req()
      return nil
    end
    if self.PlayerEquipData[car_id] then
      return self.PlayerEquipData[car_id].appliques
    end
  elseif self.OtherPlayerData[UID] and self.OtherPlayerData[UID][car_id] then
    return self.OtherPlayerData[UID][car_id]
  elseif SubsystemMgr then
    self:RequestDataInGame(UID, car_id)
  else
    log_error("LogicVehicleDIY:GetDIYData missing data!")
  end
  return nil
end
function LogicVehicleDIY:SetDIYData(UID, car_id, data)
  if not UID or not car_id then
    return
  end
  log(bWriteLog and "LogicVehicleDIY:SetDIYData UID = " .. tostring(UID) .. "  car_id = " .. tostring(car_id))
  UID = tostring(UID)
  if UID == DataMgr.roleData.uid then
    log(bWriteLog and "LogicVehicleDIY:SetDIYData can not set SelfData")
    return
  end
  if not self.OtherPlayerData[UID] then
    self.OtherPlayerData[UID] = {}
  end
  self.OtherPlayerData[UID][car_id] = data
  EventSystem:postEvent(EVENTTYPE_VEHICLE_DIY, EVENTID_VEHICLE_DIY_UPDATE_DATA, UID, car_id)
end
function LogicVehicleDIY:UpdateTeammateData(UID)
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  for k, v in pairs(TeamUpNewSystem.teamInfo.members) do
    if tonumber(k) == tonumber(UID) then
      if v and v.vst_info and v.vst_info.car_applique_list then
        self:SetDIYData(UID, v.vst_info.skin_id, v.vst_info.car_applique_list.appliques)
      end
      break
    end
  end
  local CarInfoList = TeamUpNewSystem.GetGarageCarInfo(UID)
  if CarInfoList then
    for _, CarInfo in pairs(CarInfoList) do
      if CarInfo.ext_data and CarInfo.ext_data.car_applique_list then
        self:SetDIYData(UID, CarInfo.res_id, CarInfo.ext_data.car_applique_list.appliques)
      else
        self:SetDIYData(UID, CarInfo.res_id, nil)
      end
    end
  end
end
function LogicVehicleDIY:IsEdit()
  local originData = self:GetEditOriginAppliqueData()
  if not originData or not originData.appliques then
    return #self.EquipData > 0
  end
  local TableUtil = require("common.table_util")
  if TableUtil.IsDataEqual(originData.appliques, self.EquipData) then
    return false
  else
    return true
  end
end
function LogicVehicleDIY:SaveEditDIYVehicleValid()
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local equipCount = {}
  local ownCount = {}
  local ValidEquipData = {}
  for _, v in ipairs(self.EquipData) do
    local itemID = v.applique_id
    if not equipCount[itemID] then
      equipCount[itemID] = 1
    else
      equipCount[itemID] = 1 + equipCount[itemID]
    end
    if not ownCount[itemID] then
      ownCount[itemID] = wardrobe_data:GetHallDepotItemCountByResID(itemID, true)
      local OriginData = self:GetEditOriginAppliqueData()
      if OriginData and OriginData.appliques then
        for _, vv in pairs(OriginData.appliques) do
          if vv.applique_id == itemID then
            ownCount[itemID] = 1 + ownCount[itemID]
          end
        end
      end
    end
    if ownCount[itemID] >= equipCount[itemID] then
      table.insert(ValidEquipData, v)
    else
      log(bWriteLog and "LogicVehicleDIY:SaveEditDIYVehicleValid remove  :" .. tostring(itemID))
    end
  end
  self.EquipData = ValidEquipData
  self:DrawEditDataToVehicle()
  EventSystem:postEvent(EVENTTYPE_VEHICLE_DIY, EVENTID_VEHICLE_DIY_UPDATE_EQUIP_LIST)
  self:SaveEditDIYVehicle()
end
function LogicVehicleDIY:SaveEditDIYVehicle()
  if not self.EditVehicleID then
    log_error("LogicVehicleDIY:SaveEditDIYVehicle not EditVehicleID")
    return
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local carWarDrobeData = wardrobe_data:GetHallDepotItemDataByResIDAndValidExpireTime(self.EditVehicleID)
  if not carWarDrobeData then
    log_error("LogicVehicleDIY:SaveEditDIYVehicle not own car")
    return
  end
  local version = self.CONST.Default.Version
  local originData = self:GetEditOriginAppliqueData()
  if originData and originData.version then
    version = originData.version
  end
  for _, v in pairs(self.EquipData) do
    if not self:CheckAppliqueData(v) then
      log_tree("LogicVehicleDIY:SaveEditDIYVehicle Check Not Pass", v)
      return
    end
  end
  if not self:IsEdit() then
    log(bWriteLog and "LogicVehicleDIY:SaveEditDIYVehicle same data")
    ShowNotice(82026)
    return
  end
  local VehicleDIYHandler = require("client.network.Protocol.VehicleDIYHandler")
  VehicleDIYHandler.send_save_car_applique_data_req(self.EditVehicleID, self.EquipData, version)
end
function LogicVehicleDIY:on_save_car_applique_data_rsp(car_id, version, applique_list)
  log(bWriteLog and "LogicVehicleDIY:on_save_car_applique_data_rsp")
  ShowNotice(74122)
  local LogicVehicleExtendedFeature = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicVehicleExtendedFeature)
  LogicVehicleExtendedFeature:RefreshReddotData()
  self:UpdateAppliqueData(car_id, version, applique_list)
  EventSystem:postEvent(EVENTTYPE_VEHICLE_DIY, EVENTID_VEHICLE_DIY_SAVE_DATA)
end
function LogicVehicleDIY:UpdateAppliqueData(car_id, version, car_applique_data)
  log(bWriteLog and "LogicVehicleDIY:UpdateAppliqueData")
  if not version or not car_applique_data then
    self.PlayerEquipData[car_id] = nil
  else
    self.PlayerEquipData[car_id] = {version = version, appliques = car_applique_data}
  end
  EventSystem:postEvent(EVENTTYPE_VEHICLE_DIY, EVENTID_VEHICLE_DIY_UPDATE_DATA, DataMgr.roleData.uid, car_id)
end
function LogicVehicleDIY:UpdateAllAppliqueData(applique_data)
  log(bWriteLog and "LogicVehicleDIY:UpdateAllAppliqueData")
  self.PlayerEquipData = applique_data or {}
  self.bInitPlayerData = true
  EventSystem:postEvent(EVENTTYPE_VEHICLE_DIY, EVENTID_VEHICLE_DIY_UPDATE_DATA, DataMgr.roleData.uid, nil)
end
function LogicVehicleDIY:RequestDataInGame(UID, ItemID)
  table.insert(self.PendingRequestArray, {UID = UID, ItemID = ItemID})
  if self.RequestTimer ~= nil then
    return
  end
  self.RequestTimer = self:AddGameTimer(0, false, function()
    if #self.PendingRequestArray == 0 then
      print(bWriteLog and "LogicVehicleDIY:RequestDataInGame Error PendingRequestArray Num == 0")
    else
      self:BattleProfileBatchGet(g_game_id, self.PendingRequestArray)
    end
    self.PendingRequestArray = {}
    self.RequestTimer = nil
  end)
end
function LogicVehicleDIY:BattleProfileBatchGet(game_id, requestList)
  log(bWriteLog and "LogicVehicleDIY BattleProfileBatchGet")
  local LogicBattleProfile = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_battle_profile)
  local moduleID = LogicBattleProfile.MODULE_ENUM.VEHICLE_DIY
  local queryParams = {}
  for _, request in pairs(requestList) do
    if not queryParams[request.UID] then
      queryParams[request.UID] = {
        [moduleID] = {}
      }
    end
    table.insert(queryParams[request.UID][moduleID], request.ItemID)
  end
  LogicBattleProfile:BatchGetBattleProfileReq(game_id, queryParams)
end
function LogicVehicleDIY:OnBattleProfileBatchGet(_, _, game_id, profiles)
  log(bWriteLog and "LogicVehicleDIY:OnBattleProfileBatchGet")
  if game_id ~= g_game_id then
    log(bWriteLog and "LogicVehicleDIY:OnBattleProfileBatchGet not match game_id !")
    return
  end
  local LogicBattleProfile = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_battle_profile)
  local moduleID = LogicBattleProfile.MODULE_ENUM.VEHICLE_DIY
  if profiles then
    for uid, userData in pairs(profiles) do
      if userData and userData[moduleID] then
        for itemID, data in pairs(userData[moduleID]) do
          if data and data.appliques then
            self:SetDIYData(uid, itemID, data.appliques)
          else
            self:SetDIYData(uid, itemID, {})
          end
        end
      end
    end
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicVehicleDIY = class(CModuleBase, nil, LogicVehicleDIY)
return CLogicVehicleDIY