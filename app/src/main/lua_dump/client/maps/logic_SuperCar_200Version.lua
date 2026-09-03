local logic_SuperCar_200Version = {
  Const = {
    DefaultSpringArmActorPath = "/Game/Arts_PlayerBluePrints/Tesla_Show/BP_TeslaCar_Camera.BP_TeslaCar_Camera_C",
    DefaultCameraID = 10180,
    DefaultSpringArmPosition = {
      X = 15292.592773,
      Y = 4891.010254,
      Z = -21868.894531
    },
    DefaultVehiclePosition = {
      X = 15292.592773,
      Y = 4891.010254,
      Z = -21920.894531
    },
    DefaultCameraOffset = {
      X = 0,
      Y = 190,
      Z = 0
    },
    DefaultCameraRotation = {
      Roll = 0.0,
      Pitch = -19.34,
      Yaw = -133.669
    },
    DefaultPitch = {
      Top = -40,
      Mid = -20,
      Bot = 0
    },
    DefaultPitchRotateLimit = {Min = -45, Max = 1},
    DefaultAutoPlayDelayTime = 10,
    DefaultCameraFov = 78,
    DefaultSpringArmLen = 850.0,
    DefaultAutoRotateSpeedRate = 1,
    DefaultAutoRotateApproachSpeedRate = 10
  },
  _nextCreateInfoCache = {},
  _SpringArmActor = nil,
  _CarID = 0,
  maxSpringArmLen = 1200,
  minSpringArmLen = 500
}
local _GetVal = function(...)
  local TableUtil = require("common.table_util")
  local dv = TableUtil.GetTableValue(logic_SuperCar_200Version.Const, ...)
  local nv = TableUtil.GetTableValue(logic_SuperCar_200Version._nextCreateInfoCache, ...)
  if nv then
    return nv
  else
    return dv
  end
end
function logic_SuperCar_200Version.SetNextCreateInfo(nextCreateInfo)
  if not nextCreateInfo then
    return
  end
  logic_SuperCar_200Version._nextCreateInfoCache = nextCreateInfo
end
function logic_SuperCar_200Version.CreateSpringArmActor()
  local _possessToSpringArm = function(springArm)
    springArm:TryToStopAutoPlay()
    springArm:SetDefaultAutoPlayDelayTime(_GetVal("DefaultAutoPlayDelayTime"))
    springArm:SetDefaultPitchLimit(_GetVal("DefaultPitchRotateLimit", "Min"), _GetVal("DefaultPitchRotateLimit", "Max"))
    springArm:SetDefaultSpringArmLen(_GetVal("DefaultSpringArmLen"))
    springArm:SetAutoRotateSpeedRate(_GetVal("DefaultAutoRotateSpeedRate"))
    springArm:SetDefaultAutoRotateApproachSpeedRate(_GetVal("DefaultAutoRotateApproachSpeedRate"))
    springArm:SetDefaultTopPitch(_GetVal("DefaultPitch", "Top"))
    springArm:SetDefaultMidPitch(_GetVal("DefaultPitch", "Mid"))
    springArm:SetDefaultBotPitch(_GetVal("DefaultPitch", "Bot"))
    springArm:SetDefaultCamFov(_GetVal("DefaultCameraFov"))
    springArm:SetSpringArmCamOffset(_GetVal("DefaultCameraOffset", "X"), _GetVal("DefaultCameraOffset", "Y"), _GetVal("DefaultCameraOffset", "Z"))
    springArm:SetDefaultInitRotation(_GetVal("DefaultCameraRotation", "Roll"), _GetVal("DefaultCameraRotation", "Pitch"), _GetVal("DefaultCameraRotation", "Yaw"))
    logic_SuperCar_200Version._nextCreateInfoCache = {}
    local LobbyModelPossess = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyModelPossess)
    LobbyModelPossess:Possess(springArm)
  end
  log(bWriteLog and "[cw][scn] logic_SuperCar_200Version.CreateSpringArmActor()")
  if slua.isValid(logic_SuperCar_200Version._SpringArmActor) then
    log(bWriteLog and "[cw][scn] slua.isValid(logic_SuperCar_200Version._SpringArmActor) ")
    _possessToSpringArm(logic_SuperCar_200Version._SpringArmActor)
    return
  end
  local world = slua_GameFrontendHUD:GetWorld()
  if not slua.isValid(world) then
    return
  end
  local actorClass = import(logic_SuperCar_200Version.Const.DefaultSpringArmActorPath)
  if not actorClass then
    log(bWriteLog and "[cw][scn] not actorClass ")
    return
  end
  log(bWriteLog and "[cw][scn]: Create new SprintActor")
  local cp = logic_SuperCar_200Version.Const.DefaultSpringArmPosition
  logic_SuperCar_200Version._SpringArmActor = world:SpawnActor(actorClass, FVector(cp.X, cp.Y, cp.Z), nil, nil)
  if not logic_SuperCar_200Version._SpringArmActor then
    log(bWriteLog and "[cw][scn] not logic_SuperCar_200Version._SpringArmActor")
    return
  end
  _possessToSpringArm(logic_SuperCar_200Version._SpringArmActor)
  if not logic_SuperCar_200Version.IsDownloaded() then
    return
  end
  logic_SuperCar_200Version.OnAvatarAllMeshLoaded:Add(function()
    log(bWriteLog and "[bgp] HandBandMesh OnAvatarAllMeshLoaded")
  end)
  log(bWriteLog and "[bgp]: logic_SuperCar_200Version.Create")
end
function logic_SuperCar_200Version.TryToResetCameraRotate()
  if not slua.isValid(logic_SuperCar_200Version._SpringArmActor) then
    log(bWriteLog and "[cw] spring actor is illegal ")
    return
  end
  logic_SuperCar_200Version._SpringArmActor:ResetCamera()
end
function logic_SuperCar_200Version.TryToTyre()
  if not slua.isValid(logic_SuperCar_200Version._SpringArmActor) then
    log(bWriteLog and "[cw] spring actor is illegal ")
    return
  end
  logic_SuperCar_200Version.curArmLength = logic_SuperCar_200Version.GetSpringArmLength()
  logic_SuperCar_200Version.SetSpringArmLength(600)
  logic_SuperCar_200Version.SetSpringArmCamAutoPlay(false)
  logic_SuperCar_200Version.ChangeCameraRotation(FRotator(0, 270, 0))
end
function logic_SuperCar_200Version.ExitToTure()
  if not slua.isValid(logic_SuperCar_200Version._SpringArmActor) then
    log(bWriteLog and "[cw] spring actor is illegal ")
    return
  end
  logic_SuperCar_200Version.SetSpringArmLength(logic_SuperCar_200Version.curArmLength)
  logic_SuperCar_200Version._SpringArmActor:ResetCamera()
end
function logic_SuperCar_200Version.ResetFov()
  if not slua.isValid(logic_SuperCar_200Version._SpringArmActor) then
    log(bWriteLog and "[cw] spring actor is illegal ")
    return
  end
  logic_SuperCar_200Version._SpringArmActor:ResetFov()
end
function logic_SuperCar_200Version.DestroySpringArmActor()
  log(bWriteLog and "[cw] logic_SuperCar_200Version.DestroySpringArmActor() ")
  if not slua.isValid(logic_SuperCar_200Version._SpringArmActor) then
    return
  end
  logic_SuperCar_200Version._SpringArmActor:K2_DestroyActor()
  logic_SuperCar_200Version._SpringArmActor = nil
  local LobbyModelPossess = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyModelPossess)
  LobbyModelPossess:UnPossess()
end
function logic_SuperCar_200Version.IsDownloaded()
  local ItemCfg = CDataTable.GetTableData("Item", logic_SuperCar_200Version._CarID)
  if not ItemCfg then
    return false
  end
  local UBackpackUtils = import("BackpackUtils")
  local ItemDefineID = FItemDefineID(ItemCfg.ItemType, logic_SuperCar_200Version._CarID)
  return UBackpackUtils.IsBattleItemHandleExist(ItemDefineID, false, true, false)
end
function logic_SuperCar_200Version.SetSpringArmCamCanTouchRotate(CanTouchRotate)
  log(bWriteLog and "logic_SuperCar_200Version.SetSpringArmCamCanTouchRotate " .. tostring(CanTouchRotate))
  if not slua.isValid(logic_SuperCar_200Version._SpringArmActor) then
    return
  end
  logic_SuperCar_200Version._SpringArmActor:SetTouchRotateState(CanTouchRotate)
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if uPlayerController then
    log(bWriteLog and "logic_SuperCar_200Version.SetSpringArmCamCanTouchRotate uPlayerController.bDisableProcessPlayerInput=" .. tostring(CanTouchRotate))
    uPlayerController.bDisableProcessPlayerInput = not CanTouchRotate
  end
end
function logic_SuperCar_200Version.SetSpringArmCamAutoPlay(canAutoPlay)
  log(bWriteLog and "logic_SuperCar_200Version.SetSpringArmCamAutoPlay " .. tostring(canAutoPlay))
  if not slua.isValid(logic_SuperCar_200Version._SpringArmActor) then
    return
  end
  logic_SuperCar_200Version._SpringArmActor.end
function logic_SuperCar_200Version.ChangeCameraToTireRotate()
  if not slua.isValid(logic_SuperCar_200Version._SpringArmActor) then
    return
  end
  logic_SuperCar_200Version._SpringArmActor:ChangeCameraToTireRotate()
end
function logic_SuperCar_200Version.ChangeCameraRotation(Rotator)
  if not slua.isValid(logic_SuperCar_200Version._SpringArmActor) then
    return
  end
  logic_SuperCar_200Version._SpringArmActor:ChangeCameraRotation(Rotator)
end
function logic_SuperCar_200Version.SwitchToLicensePlate(CameraConfig)
  if not slua.isValid(logic_SuperCar_200Version._SpringArmActor) then
    return
  end
  logic_SuperCar_200Version._SpringArmActor.bCanTouchRotate = false
  local world = slua_GameFrontendHUD:GetWorld()
  local GameplayStatics = import("GameplayStatics")
  local CameraManager = GameplayStatics.GetPlayerCameraManager(world, 0)
  CameraManager.ViewPitchMax = 5
  if CameraConfig then
    logic_SuperCar_200Version.ChangeCameraRotation(CameraConfig.ControlRotation)
    logic_SuperCar_200Version._SpringArmActor:SetFov(CameraConfig.FOV)
    logic_SuperCar_200Version._SpringArmActor:ChangeRotation(CameraConfig.CameraRotation)
  end
end
function logic_SuperCar_200Version.ExitToLicensePlate()
  if not slua.isValid(logic_SuperCar_200Version._SpringArmActor) then
    return
  end
  logic_SuperCar_200Version.ResetFov()
  logic_SuperCar_200Version._SpringArmActor.bCanTouchRotate = true
  logic_SuperCar_200Version._SpringArmActor:ChangeRotation(FRotator(0, 0, 0))
  local world = slua_GameFrontendHUD:GetWorld()
  local GameplayStatics = import("GameplayStatics")
  local CameraManager = GameplayStatics.GetPlayerCameraManager(world, 0)
  CameraManager.ViewPitchMax = logic_SuperCar_200Version.Const.DefaultPitchRotateLimit.Max
end
function logic_SuperCar_200Version.EnterFullPreview(armLength)
  if not slua.isValid(logic_SuperCar_200Version._SpringArmActor) then
    return
  end
  logic_SuperCar_200Version._SpringArmActor.bCanTouchRotate = true
  logic_SuperCar_200Version._SpringArmActor.canAutoPlay = true
  local lastArmLength = logic_SuperCar_200Version.GetSpringArmLength()
  armLength = armLength or logic_SuperCar_200Version.Const.DefaultSpringArmLen
  logic_SuperCar_200Version.SetSpringArmLength(armLength)
  return lastArmLength
end
function logic_SuperCar_200Version.ExitFullPreview(armLength)
  if not slua.isValid(logic_SuperCar_200Version._SpringArmActor) then
    return
  end
  logic_SuperCar_200Version._SpringArmActor.bCanTouchRotate = true
  logic_SuperCar_200Version._SpringArmActor:TryToStopAutoPlay()
  if armLength then
    logic_SuperCar_200Version.SetSpringArmLength(armLength)
  else
    logic_SuperCar_200Version.ResetSpringArmLength()
  end
end
function logic_SuperCar_200Version.SetSpringArmLength(length)
  if not slua.isValid(logic_SuperCar_200Version._SpringArmActor) then
    return
  end
  logic_SuperCar_200Version._SpringArmActor:SetArmLength(length)
end
function logic_SuperCar_200Version.GetSpringArmLength()
  if not slua.isValid(logic_SuperCar_200Version._SpringArmActor) then
    return
  end
  return logic_SuperCar_200Version._SpringArmActor:GetArmLength() or logic_SuperCar_200Version.Const.DefaultSpringArmLen
end
function logic_SuperCar_200Version.ResetSpringArmLength()
  if not slua.isValid(logic_SuperCar_200Version._SpringArmActor) then
    return
  end
  return logic_SuperCar_200Version._SpringArmActor:ResetToDefaultArmLength()
end
function logic_SuperCar_200Version.PreviewMoveArmLength(delta)
  if not slua.isValid(logic_SuperCar_200Version._SpringArmActor) then
    return
  end
  local max = 900
  local min = 350
  local curArmLength = logic_SuperCar_200Version.GetSpringArmLength()
  local newArmLength = curArmLength + delta
  if max < newArmLength then
    newArmLength = max
  elseif min > newArmLength then
    newArmLength = min
  end
  logic_SuperCar_200Version.SetSpringArmLength(newArmLength)
end
return logic_SuperCar_200Version