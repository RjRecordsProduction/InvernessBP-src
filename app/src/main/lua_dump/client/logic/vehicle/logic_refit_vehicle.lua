local RefitVehicle = {}
local GameplayStatics = import("GameplayStatics")
local vehicleTipsActorsMap = {}
local showActor, vehiclePreviewPower3DUI
local curYawRange = -1
local TYPE_MODE = 1
local TYPE_COLOR = 2
local TYPE_PATTERN = 3
local TYPE_PARTICLE = 4
local car_pos_str = "real_part"
local car_type1_str = "type1"
local car_value1_str = "value1"
local car_type2_str = "type2"
local car_value2_str = "value2"
local get_style_cfg = function(id)
  return CDataTable.GetTableData("VehicleRefitStyle", id)
end
local format_battle_style = function(battle_info, style_info)
  if not battle_info or not style_info then
    return
  end
  local car_pos = style_info[car_pos_str]
  local car_type1 = style_info[car_type1_str]
  local car_value1 = style_info[car_value1_str]
  local car_type2 = style_info[car_type2_str]
  local car_value2 = style_info[car_value2_str]
  if car_pos and 0 < car_pos then
    battle_info[car_pos] = battle_info[car_pos] or {}
    if car_type1 and 0 < car_type1 then
      battle_info[car_pos][car_type1] = car_value1
    end
    if car_type2 and 0 < car_type2 then
      battle_info[car_pos][car_type2] = car_value2
    end
  end
  local car_pos2 = style_info.real_part2
  local car_type21 = style_info.type21
  local car_value21 = style_info.value21
  if car_pos2 and 0 < car_pos2 then
    battle_info[car_pos2] = battle_info[car_pos2] or {}
    if car_type21 and 0 < car_type21 then
      battle_info[car_pos2][car_type21] = car_value21
    end
  end
  return true
end
function get_battle_info(style_list)
  local battle_info = {}
  if not style_list then
    log_error("get_battle_info,params nil error!style_list=%s", style_list)
    return
  end
  for _, style_id in pairs(style_list) do
    local cfg = get_style_cfg(style_id)
    format_battle_style(battle_info, cfg)
  end
  return battle_info
end
local array_sub = function(array1, array2)
  local a1_ = {}
  if array1 then
    for _, v in pairs(array1) do
      a1_[v] = true
    end
  end
  local a2_ = {}
  if array2 then
    for _, v in pairs(array2) do
      a2_[v] = true
    end
  end
  if array1 then
    for _, v in pairs(array1) do
      if a2_[v] == true then
        a1_[v] = false
      end
    end
  end
  local ret = {}
  for _, v in pairs(a1_) do
    if v == true then
      table.insert(ret, _)
    end
  end
  return ret
end
local yawTipsRange = {
  {1, 4},
  {
    1,
    3,
    4
  },
  {3},
  {
    3,
    5,
    6,
    9
  },
  {
    5,
    6,
    9,
    10
  },
  {
    5,
    6,
    8,
    9,
    10
  },
  {
    1,
    2,
    8
  },
  {
    1,
    4,
    8
  },
  {1, 4}
}
local YawToTipsRange = function(yaw)
  if -180 <= yaw and yaw < -160 then
    return 1
  elseif -160 <= yaw and yaw < -135 then
    return 2
  elseif -135 <= yaw and yaw < -35 then
    return 3
  elseif -35 <= yaw and yaw < -15 then
    return 4
  elseif -15 <= yaw and yaw < 15 then
    return 5
  elseif 15 <= yaw and yaw < 35 then
    return 6
  elseif 35 <= yaw and yaw < 135 then
    return 7
  elseif 135 <= yaw and yaw < 160 then
    return 8
  elseif 160 <= yaw and yaw < 180 then
    return 9
  end
end
local keyForSlot = function(slot)
  if slot == nil then
    return ""
  end
  local modleId = slot[TYPE_MODE] or 0
  local color = slot[TYPE_COLOR] or 0
  local pattern = slot[TYPE_PATTERN] or 0
  local particle = slot[TYPE_PARTICLE] or 0
  return tostring(modleId) .. "_" .. tostring(color) .. "_" .. tostring(pattern) .. "_" .. tostring(particle)
end
local iterateSlot = function(newInfos, oldInfos, putOnSlotCallback, putOffSlotCallback)
  for k, v in pairs(oldInfos) do
    local new = newInfos[k]
    if (new == nil or new[TYPE_MODE] == nil) and v[TYPE_MODE] then
      putOffSlotCallback(v[TYPE_MODE])
    end
  end
  for k, v in pairs(newInfos) do
    local old = oldInfos[k]
    local oldKey = keyForSlot(old)
    local newKey = keyForSlot(v)
    if oldKey ~= newKey then
      putOnSlotCallback(k)
    end
  end
end
local vehicleInfos
function RefitVehicle.Display(vehicleId, styles)
  log(bWriteLog and "RefitVehicle.Display " .. tostring(vehicleId))
  local VehicleRefitHandler = require("client.network.Protocol.VehicleRefitHandler")
  local cfg = VehicleRefitHandler.GetCartLevelCfg(vehicleId, 1)
  if not cfg then
    log(bWriteLog and "RefitVehicle.Display with nil cfg" .. tostring(vehicleId))
    return
  end
  local id = cfg.vehicle_id
  local battleInfo = get_battle_info(styles)
  if vehicleInfos == nil then
    RefitVehicle.CreateRefitVehicle(id)
    RefitVehicle._equipStyleInner(showActor:GetrefitVehicleActor(), battleInfo)
  else
    local putOnSlotCallback = function(slot)
      local info = battleInfo[slot]
      local modeID = info[TYPE_MODE] or 0
      local color = info[TYPE_COLOR] or 0
      local pattern = info[TYPE_PATTERN] or 0
      local particle = info[TYPE_PARTICLE] or 0
      log(bWriteLog and "vehicle. append slot:" .. tostring(slot) .. ", mode:" .. tostring(modeID) .. ", color:" .. tostring(color))
      local success = showActor:GetrefitVehicleActor():PutOnVehicleItem(modeID, color, pattern, particle)
    end
    local putOffSlotCallback = function(modelId)
      log(bWriteLog and "vehicle. putoff slot:" .. tostring(modelId))
      showActor:GetrefitVehicleActor():PutOffVehicleItem(modelId)
    end
    iterateSlot(battleInfo, vehicleInfos, putOnSlotCallback, putOffSlotCallback)
  end
  vehicleInfos = battleInfo
  curYawRange = -1
end
function RefitVehicle.EquipStyle(refitVehicle, itemID, source)
  if not refitVehicle or not slua.isValid(refitVehicle) then
    return
  end
  if not refitVehicle:HasRefitVehicleDownloaded() then
    log(bWriteLog and "RefitVehicle.EquipStyle pak not download")
    refitVehicle:CreateDefaultRefitVehicleMesh()
    return
  end
  local VehicleRefitHandler = require("client.network.Protocol.VehicleRefitHandler")
  local styles
  if UIManager.IsUIShow(UIManager.UI_Config.wardrobe) then
    styles = VehicleRefitHandler.GetCarStyleList(itemID, nil, nil, nil, source)
  else
    styles = VehicleRefitHandler.GetCarDefaultStyleList(itemID)
  end
  RefitVehicle.EquipStyleList(refitVehicle, styles)
end
function RefitVehicle.EquipStyleList(refitVehicle, styles)
  log(bWriteLog and string.format("RefitVehicle.EquipStyleList styles:%s", tostring(styles)))
  if not refitVehicle:HasRefitVehicleDownloaded() then
    log(bWriteLog and "RefitVehicle.EquipStyleList pak not download")
    refitVehicle:CreateDefaultRefitVehicleMesh()
    return
  end
  local battleInfo = get_battle_info(styles)
  RefitVehicle._equipStyleInner(refitVehicle, battleInfo)
end
function RefitVehicle._equipStyleInner(refitVehicle, battleInfo)
  if not refitVehicle:HasRefitVehicleDownloaded() then
    log(bWriteLog and "RefitVehicle._equipStyleInner pak not download")
    refitVehicle:CreateDefaultRefitVehicleMesh()
    return
  end
  if not battleInfo then
    return
  end
  for part, info in pairs(battleInfo) do
    local modeID = info[TYPE_MODE] or 0
    local color = info[TYPE_COLOR] or 0
    local pattern = info[TYPE_PATTERN] or 0
    local particle = info[TYPE_PARTICLE] or 0
    log(bWriteLog and "vehicle. init part:" .. tostring(part) .. ", mode:" .. tostring(modeID) .. ", color:" .. tostring(color))
    refitVehicle:PutOnVehicleItem(modeID, color, pattern, particle)
  end
end
function RefitVehicle.ShowProperty(props, vehicleName)
  local GetNameVal = function(index)
    if index > #props then
      return "", 0, 0
    end
    return props[index].key, props[index].val, props[index].max
  end
  local name1, percent1, max1 = GetNameVal(1)
  local name2, percent2, max2 = GetNameVal(2)
  local name3, percent3, max3 = GetNameVal(3)
  local name4, percent4, max4 = GetNameVal(4)
  local name5, percent5, max5 = GetNameVal(5)
  local name6, percent6, max6 = GetNameVal(6)
  RefitVehicle.ShowRefitVehicleProperty(vehicleName, name1, percent1, max1, name2, percent2, max2, name3, percent3, max3, name4, percent4, max4, name5, percent5, max5, name6, percent6, max6)
end
local GetMountImagePath = function(vehicleShapeID, slotID)
  local info = CDataTable.GetTableData("VehicleRefitBody3dUI", tostring(vehicleShapeID) .. "_" .. tostring(slotID))
  if info then
    return info.path
  end
  return nil
end
local TipsTimer
function RefitVehicle.ShowRefitTips(vehicleID)
  if vehicleInfos == nil then
    return
  end
  RefitVehicle.UnMountAllVehicleRefitPos()
  local callback = function()
    local actorReady = showActor and showActor:GetrefitVehicleActor()
    if actorReady and showActor:GetrefitVehicleActor().isAllMeshLoaded then
      log(bWriteLog and "vehicle. mount tick tips")
      local info = CDataTable.GetTableData("VehicleRefitInfo", vehicleID)
      if info == nil then
        return
      end
      local mount = function(slot)
        local imagePath = GetMountImagePath(info.VehicleShapeID, slot)
        if imagePath then
          RefitVehicle.MountVehicleRefitPos(slot, imagePath, vehicleID)
        end
      end
      for i = 1, 10 do
        mount(i)
      end
      showActor:GetrefitVehicleActor():CheckRefitTipsFade(true)
    else
      log(bWriteLog and "vehicle. delay mount tick tips")
      RefitVehicle.ShowRefitTips(vehicleID)
    end
  end
  local time_ticker = require("common.time_ticker")
  if TipsTimer ~= nil then
    time_ticker.RemoveTimer(TipsTimer)
    TipsTimer = nil
  end
  TipsTimer = time_ticker.AddTimerOnce(2, callback)
end
function RefitVehicle.Destroy()
  vehicleInfos = nil
  RefitVehicle.UnMountAllVehicleRefitPos()
  if showActor and slua.isValid(showActor) then
    showActor:Destroy()
  end
  showActor = nil
  if vehiclePreviewPower3DUI then
    vehiclePreviewPower3DUI:K2_DestroyActor()
    vehiclePreviewPower3DUI = nil
  end
  if TipsTimer then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(TipsTimer)
    TipsTimer = nil
  end
end
function RefitVehicle.TryResetCloseUp()
  showActor:GetrefitVehicleActor():TryResetCloseUp()
end
function RefitVehicle.UpdateLastAutoPlayTime()
  showActor:GetrefitVehicleActor():UpdateLastAutoPlayTime()
end
function RefitVehicle.CanAutoPlay()
  local ui = UIManager.GetUI(UIManager.UI_Config.vehicle_refit_main)
  if ui then
    return false
  end
  ui = UIManager.GetUI(UIManager.UI_Config.Vehicle_UpGrade_Main_UIBP)
  if ui then
    return false
  end
  return true
end
function RefitVehicle.StopAutoPlay()
  showActor:GetrefitVehicleActor():TryStopAutoPlay()
end
function RefitVehicle.RefitTipClickedForUI(slotId)
  log(bWriteLog and "vehicle. click slot:" .. tostring(slotId))
  local vehicle = showActor:GetrefitVehicleActor()
  local playerController = slua_GameFrontendHUD:GetPlayerController()
  local _, _, isCurrentlyPressed = playerController:GetInputTouchState(vehicle.inputFingerIndex, nil, nil, nil)
  if isCurrentlyPressed then
    log(bWriteLog and "vehicle. RefitTipClickedForUI pressed, return")
    return
  end
  RefitVehicle.SwitchRefitVehicleCameraForUI(slotId)
  RefitVehicle.StopAutoPlay()
end
function RefitVehicle.RefitTipClicked(slotId, vehicleID)
  log(bWriteLog and "vehicle. click slot:" .. tostring(slotId))
  local vehicle = showActor:GetrefitVehicleActor()
  local playerController = slua_GameFrontendHUD:GetPlayerController()
  local _, _, isCurrentlyPressed = playerController:GetInputTouchState(vehicle.inputFingerIndex, nil, nil, nil)
  local ui = UIManager.GetUI(UIManager.UI_Config.vehicle_main)
  local VehicleRefitHandler = require("client.network.Protocol.VehicleRefitHandler")
  local tPartGroupList = VehicleRefitHandler.GetCarPartGroupList(vehicleID)
  if ui and tPartGroupList then
    local carInfo = ui:GetCarInfoByIndex(ui.curSelectCarIndex)
    for i = 1, #tPartGroupList do
      if tPartGroupList[i].cfg.real_part == slotId then
        local refitui = UIManager.GetUI(UIManager.UI_Config.vehicle_refit_main)
        if refitui then
          refitui:OnClickItem2(nil, i)
          break
        end
        do
          local UnknowPassUtil = require("client.slua.logic.unknow_pass.logic_unknowpass_util")
          UnknowPassUtil.CheckCloseUI(UIManager.UI_Config.Vehicle_UpGrade_Main_UIBP)
          UIManager.ShowUI(UIManager.UI_Config.vehicle_refit_main, carInfo, i - 1)
        end
        break
      end
    end
  end
end
function RefitVehicle.ResetCloseUp()
  local ui = UIManager.GetUI(UIManager.UI_Config.vehicle_main)
  if ui then
    ui:StopPlayAllStyle()
  end
  showActor:GetrefitVehicleActor():ResetCloseUpCamera()
end
local fadeInRefitTiptoTransparent = function(index)
  log(bWriteLog and "vehicle. fadein to transparent " .. tostring(index))
  RefitVehicle.FadeRefitTip(3, index)
end
local fadeInRefitTip = function(index)
  log(bWriteLog and "vehicle. fadein " .. tostring(index))
  RefitVehicle.FadeRefitTip(1, index)
end
local fadeOutRefitTip = function(index)
  log(bWriteLog and "vehicle. fadeout " .. tostring(index))
  RefitVehicle.FadeRefitTip(2, index)
end
function RefitVehicle.GetCameraRotateType(fromYaw, toYaw)
  if fromYaw < 0 then
    fromYaw = fromYaw + 360
  end
  if toYaw < 0 then
    toYaw = toYaw + 360
  end
  local abs = math.abs(fromYaw - toYaw)
  return abs <= 90
end
function RefitVehicle.CheckRefitTipsFade(yaw, showAllTips)
  local newRange = YawToTipsRange(yaw)
  if showAllTips or curYawRange == -1 then
    local fadeInToTransparent = {}
    for i = 1, 10 do
      table.insert(fadeInToTransparent, true)
    end
    local fadeIns = yawTipsRange[newRange]
    for k, v in ipairs(fadeIns) do
      fadeInRefitTip(v)
      fadeInToTransparent[v] = false
    end
    for k, v in ipairs(fadeInToTransparent) do
      if v == true then
        fadeInRefitTiptoTransparent(k)
      end
    end
  else
    if curYawRange == newRange then
      return
    end
    local fadeOuts = array_sub(yawTipsRange[curYawRange], yawTipsRange[newRange])
    local fadeIns = array_sub(yawTipsRange[newRange], yawTipsRange[curYawRange])
    for k, v in ipairs(fadeOuts) do
      fadeOutRefitTip(v)
    end
    for k, v in ipairs(fadeIns) do
      fadeInRefitTip(v)
    end
  end
  curYawRange = newRange
end
function RefitVehicle.OnUpgradeSuccess()
  if slua.isValid(showActor) then
    showActor:GetrefitVehicleActor():OnVehicleUpgradeSuccess()
  end
end
function RefitVehicle.CreateRefitVehicle(vehicleId)
  if showActor and slua.isValid(showActor) then
    showActor:Destroy()
    showActor = nil
  end
  local ModelFactory = require("client.slua.logic.show_actor.common.ModelFactory")
  showActor = ModelFactory.CreateShowActor()
  local ExtraTable = {
    is_refit_vehicle = true,
    ignore_download = true,
    refit_vehicle_cast_shadow = true,
    CastPhontonShadow = true
  }
  showActor:ShowModelByResID(vehicleId, ExtraTable)
  showActor:GetrefitVehicleActor():SetActorTickEnabled(true)
  local vehicleHandle = showActor:GetrefitVehicleActor():GetRefitVehicleHandle(vehicleId)
  showActor:K2_SetActorLocation(vehicleHandle.Location, false, nil, false)
  showActor:SetActorScale3D(FVector(vehicleHandle.Scale, vehicleHandle.Scale, vehicleHandle.Scale))
  showActor:GetrefitVehicleActor():InitSlotSocket(vehicleHandle.SlotConfig)
end
function RefitVehicle.ShowRefitVehicleProperty(vehicleName, name1, percent1, max1, name2, percent2, max2, name3, percent3, max3, name4, percent4, max4, name5, percent5, max5, name6, percent6, max6)
  if vehiclePreviewPower3DUI == nil then
    local world = slua_GameFrontendHUD:GetWorld()
    local vehiclePreviewPower3DUIClass = import("/Game/UMG/UI_BP/Vehicle/Vehicle_Preview_Power_3DUI.Vehicle_Preview_Power_3DUI_C")
    local location = FVector(14700, 5550, -21670)
    local rotation = FRotator(0, -43.200001, 0)
    vehiclePreviewPower3DUI = world:SpawnActor(vehiclePreviewPower3DUIClass, location, rotation, nil)
    vehiclePreviewPower3DUI:SetActorScale3D(FVector(1.6, 1.6, 1.6))
  end
  local vehiclePropery3DUIWidget
  if vehiclePreviewPower3DUI then
    vehiclePropery3DUIWidget = vehiclePreviewPower3DUI.Widget
  end
  if not vehiclePropery3DUIWidget then
    log_error("ShowRefitVehicleProperty get widget fail")
    return
  end
  local vehhiclePreviewPowerUIBP = vehiclePropery3DUIWidget:GetUserWidgetObject()
  if not slua.isValid(vehhiclePreviewPowerUIBP) then
    log_error("ShowRefitVehicleProperty get widgetobj fail")
    return
  end
  vehhiclePreviewPowerUIBP:SetProperty(name1, percent1, max1, name2, percent2, max2, name3, percent3, max3, name4, percent4, max4, name5, percent5, max5, name6, percent6, max6)
  local KismetTextLibrary = import("KismetTextLibrary")
  vehhiclePreviewPowerUIBP.TextBlock_vehicle_name:SetText(KismetTextLibrary.Conv_StringToText(vehicleName))
  vehiclePropery3DUIWidget:RequestRedraw()
end
function RefitVehicle.MountVehicleRefitPos(slotId, imagePath, vehicleID)
  local tempRefitTips
  local meshSocketLocation = showActor:GetrefitVehicleActor().Mesh:GetSocketTransform("RefitVehicle3DUISocket_" .. slotId, 0):GetLocation()
  local meshWorldLocation = showActor:GetrefitVehicleActor():K2_GetActorLocation()
  local kismetMathLibrary = import("KismetMathLibrary")
  if kismetMathLibrary.EqualEqual_VectorVector(meshSocketLocation, meshWorldLocation, 1.0E-4) then
    return
  else
    local world = slua_GameFrontendHUD:GetWorld()
    local tempRefitTipsClass = import("/Game/UMG/UI_BP/Vehicle/Scene/VehicleRefitTips.VehicleRefitTips_C")
    tempRefitTips = world:SpawnActor(tempRefitTipsClass, FVector(0, 0, 0), nil, nil)
  end
  tempRefitTips:SetRefitSlot(slotId)
  tempRefitTips:AttachToRefitSocket(showActor:GetrefitVehicleActor(), slotId)
  vehicleTipsActorsMap[slotId] = tempRefitTips
  tempRefitTips:HideTip()
  tempRefitTips:UpdateTipImage(imagePath)
  local widget = tempRefitTips.Widget:GetUserWidgetObject()
  widget.Button_88.OnClicked:Add(function()
    RefitVehicle.RefitTipClicked(slotId, vehicleID)
  end)
end
function RefitVehicle.UnMountAllVehicleRefitPos()
  for _, vehicleTipActor in pairs(vehicleTipsActorsMap) do
    if slua.isValid(vehicleTipActor) then
      vehicleTipActor:K2_DestroyActor()
    end
  end
  vehicleTipsActorsMap = {}
end
function RefitVehicle.SwitchRefitVehicleCameraForUI(slotId)
  local tempCameraCloseUp
  local vehicle = showActor:GetrefitVehicleActor()
  if vehicle.cameraCloseUp then
    tempCameraCloseUp = vehicle.cameraCloseUp
  end
  local vehicleCameraSocketLocation = vehicle.Mesh:GetSocketTransform("RefitVehicleCameraSocket_" .. slotId, 0):GetLocation()
  local cameraWorldLocation
  if tempCameraCloseUp and slua.isValid(tempCameraCloseUp) then
    cameraWorldLocation = tempCameraCloseUp.Camera:K2_GetComponentLocation()
  else
    cameraWorldLocation = vehicle.Camera:K2_GetComponentLocation()
  end
  local targetYaw = vehicle:GetYawtoMesh(vehicleCameraSocketLocation)
  local fromYaw = vehicle:GetYawtoMesh(cameraWorldLocation)
  local switchMethod = RefitVehicle.GetCameraRotateType(fromYaw, targetYaw)
  if switchMethod == true then
    vehicle:SwitchCloseupCameraLinear(slotId)
  else
    vehicle:SwitchCloseupCameraEllipse(slotId)
  end
end
function RefitVehicle.FadeRefitTip(type, index)
  local curRefitTips = vehicleTipsActorsMap[index]
  if curRefitTips then
    if type == 1 then
      curRefitTips:fadeIn()
    elseif type == 2 then
      curRefitTips:fadeOut()
    else
      curRefitTips:FadeInToTransParent()
    end
  end
end
function RefitVehicle.OnResetButtonClicked()
  if showActor and slua.isValid(showActor:GetrefitVehicleActor()) then
    showActor:GetrefitVehicleActor():ResetCameraRotation()
  end
end
return RefitVehicle