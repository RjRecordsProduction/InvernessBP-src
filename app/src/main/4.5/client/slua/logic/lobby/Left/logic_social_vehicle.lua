local SocialVehicleSystem = {}
function SocialVehicleSystem.IsRefitVehicle(vehicleID)
  local RefitInfo = CDataTable.GetTableData("VehicleRefitInfo", vehicleID)
  if RefitInfo and RefitInfo.unlock_part_list ~= "" then
    return true
  end
  return false
end
function SocialVehicleSystem.CreateRefitVehicle(vehicleId, transform, styleList, index, show_tire_feature, force_download, isSocialScene, bForceUseBattleModel, extraTableData)
  local RefitVehicle = require("client.logic.vehicle.logic_refit_vehicle")
  log(bWriteLog and "CreateRefitVehicle vehicleId = " .. vehicleId .. " bForceUseBattleModel = " .. tostring(bForceUseBattleModel))
  local IsRefitVehicle = SocialVehicleSystem.IsRefitVehicle(vehicleId)
  if IsRefitVehicle and styleList == nil then
    styleList = {}
  end
  local ModelFactory = require("client.slua.logic.show_actor.common.ModelFactory")
  local poolSize = extraTableData and extraTableData.poolSize or 1
  local showActor = ModelFactory.CreateShowActor(poolSize)
  local ExtraTable = {
    EnableHighTire = show_tire_feature,
    NotOpenDoor = extraTableData and extraTableData.NotOpenDoor,
    AccessoryList = extraTableData and extraTableData.AccessoryList,
    ChassisLight = extraTableData and extraTableData.ChassisLight,
    AppliqueList = extraTableData and extraTableData.AppliqueList,
    force_lod = extraTableData and extraTableData.force_lod,
    License = extraTableData and extraTableData.License,
    LicenseBgId = extraTableData and extraTableData.LicenseBgId,
    BrakeCaliper = extraTableData and extraTableData.BrakeCaliper,
    WheelHub = extraTableData and extraTableData.WheelHub,
    Canopy = extraTableData and extraTableData.Canopy,
    bSunroofOpen = extraTableData and extraTableData.bSunroofOpen
  }
  if not force_download then
    ExtraTable.ignore_download = true
  end
  if IsRefitVehicle then
    ExtraTable.is_refit_vehicle = true
    ExtraTable.refit_vehicle_no_possess = true
    ExtraTable.refit_vehicle_no_autoplay = true
    ExtraTable.refit_vehicle_cast_shadow = true
    ExtraTable.is_hall_vehicle = true
  end
  if isSocialScene then
    local RacecarCfg = CDataTable.GetTableData("BetterVehicleEffect", vehicleId)
    if RacecarCfg and RacecarCfg.UseBattleModel > 0 then
      log(bWriteLog and "SocialVehicleSystem.CreateRefitVehicle UseBattleModel ID:" .. tostring(vehicleId))
      ExtraTable.is_hall_vehicle = true
    end
  end
  if bForceUseBattleModel then
    ExtraTable.is_hall_vehicle = true
  end
  showActor:ShowModelByResID(vehicleId, ExtraTable)
  if IsRefitVehicle then
    local vehicleHandle = showActor:GetrefitVehicleActor():GetRefitVehicleHandle(vehicleId)
    if vehicleHandle then
      showActor:GetrefitVehicleActor():InitSlotSocket(vehicleHandle.SlotConfig)
      local battleInfo = get_battle_info(styleList)
      RefitVehicle._equipStyleInner(showActor:GetrefitVehicleActor(), battleInfo)
    end
  end
  local baseScale = extraTableData and extraTableData.BaseScale or 1
  local bUsePlanCHTransformConfig = extraTableData and extraTableData.UsePlanCHTransformConfig
  if bUsePlanCHTransformConfig then
    local Logic_SC_ItemShowTools = require("client.slua.logic.lobby.Left.SocialLobby.Logic_SC_ItemShowTools")
    Logic_SC_ItemShowTools.VehicleModelShowOffsetHandle(showActor, vehicleId, baseScale)
  else
    local scaleInfo
    local skinMap = CDataTable.GetTableData("VehiclePlaneSkinMapping", vehicleId)
    if skinMap then
      local VehicleTransform = CDataTable.GetTableData("VehicleTransform", skinMap.OrginalID)
      if VehicleTransform then
        local SlotScale = VehicleTransform["SlotScale" .. index]
        local StringUtil = require("common.string_util")
        scaleInfo = StringUtil.Split(SlotScale, ";")
      end
    end
    scaleInfo = scaleInfo and {
      scaleInfo[1] * baseScale,
      scaleInfo[2] * baseScale,
      scaleInfo[3] * baseScale
    }
    if IsRefitVehicle then
      local vehicleHandle = showActor:GetrefitVehicleActor():GetRefitVehicleHandle(vehicleId)
      if vehicleHandle and scaleInfo then
        showActor:GetrefitVehicleActor():SetActorScale3D(FVector(scaleInfo[1], scaleInfo[2], scaleInfo[3]))
      end
    end
    if showActor:GetVehicleActor() then
      local itemCfg = CDataTable.GetTableData("Item", vehicleId)
      log(bWriteLog and "itemCfg.ItemSubType:" .. tostring(itemCfg and itemCfg.ItemSubType))
      if itemCfg then
        if itemCfg.ItemSubType == 911 then
          showActor:GetVehicleActor():K2_SetActorRelativeLocation(FVector(-200, 0, 30), false, nil, false)
        elseif itemCfg.ItemSubType == 912 then
          showActor:GetVehicleActor():K2_SetActorRelativeLocation(FVector(0, 0, 15), false, nil, false)
        end
      end
      if scaleInfo and (not extraTableData or not extraTableData.bUseForHighLight) then
        showActor:GetVehicleActor():SetActorScale3D(FVector(scaleInfo[1], scaleInfo[2], scaleInfo[3]))
      end
    end
    if showActor:GetWingmanActor() and scaleInfo then
      showActor:GetWingmanActor():SetActorScale3D(FVector(scaleInfo[1], scaleInfo[2], scaleInfo[3]))
      showActor:GetWingmanActor():K2_SetActorRelativeLocation(FVector(0, 0, 15), false, nil, false)
    end
  end
  showActor:K2_SetActorTransform(transform, false, nil, false)
  return showActor
end
return SocialVehicleSystem