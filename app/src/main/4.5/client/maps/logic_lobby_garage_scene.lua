local logic_lobby_garage_scene = {
  RegisteredActorContainer = nil,
  bInit = false,
  LoadSystemType = {
    None = 0,
    Wardrobe = 1,
    Store = 2,
    ItemPreview = 3,
    ExchangeAativity = 4,
    Pitorial = 5,
    Collect = 6
  },
  TickLightTimer = nil,
  LightItemID = 0,
  bEnableTAA = false
}
local CameraSwitch = false
local CarSwitch = false
local ModelInfo
local initialized = false
local CurrSystemType
local _NewShowingData = function()
  if ModelInfo ~= nil then
    return
  end
  log(bWriteLog and "[bgp] _NewShowingData")
  local super_data = require("common.super_data")
  ModelInfo = super_data.CreateSuperData({ReadyItem = 0})
end
function logic_lobby_garage_scene.Init()
  log(bWriteLog and "[cw] logic_lobby_garage_scene.Init() ")
  initialized = true
  logic_lobby_garage_scene.IsInLicensePlateLight = false
  logic_lobby_garage_scene.LightItemID = 0
  EventSystem:registEvent(EVENTTYPE_LOBBY_SCENE, EVENTID_SCENE_GARAGE_MODEL_READY, logic_lobby_garage_scene.OnModelReady)
  _NewShowingData()
end
function logic_lobby_garage_scene.OnModelReady(_, _, ID)
  log(bWriteLog and "[cw] logic_lobby_garage_scene.OnModelReady" .. tostring(ID))
  ModelInfo.ReadyItem = 0
  ModelInfo.ReadyItem = ID
  logic_lobby_garage_scene.ProcessLight(ID)
  local LadderCarDetailConfig = require("client.slua.logic.lobby_activity.LadderCarDetailConfig")
  if not LadderCarDetailConfig.IsRareCar(ID) then
    return
  end
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  local nDeviceLevel = GameInstance:GetDeviceLevel()
  if nDeviceLevel <= 0 then
    return
  end
  local WeaponModelLogic = require("client.slua.logic.manager.WeaponModelLogic")
  local actor = WeaponModelLogic.GetProperWeaponShowActor()
  log(bWriteLog and "[cw][test] actor:" .. tostring(actor))
  if slua.isValid(actor) and slua.isValid(actor:GetVehicleActor()) and slua.isValid(actor:GetVehicleActor().Mesh) then
    log(bWriteLog and "[cw][test] slua.isValid(actor) and slua.isValid(actor:GetVehicleActor()) and slua.isValid(actor:GetVehicleActor().Mesh)")
    log(bWriteLog and "[cw][test] IsRareCar, SetCastPhotonShadow")
    log(bWriteLog and "[cw][test] actor:GetVehicleActor():" .. tostring(actor:GetVehicleActor()))
    log(bWriteLog and "[cw][test] actor:GetVehicleActor().Mesh:" .. tostring(actor:GetVehicleActor().Mesh))
    actor:GetVehicleActor().Mesh:SetCastPhotonShadow(true)
  end
end
function logic_lobby_garage_scene.GetModelInfo()
  _NewShowingData()
  return ModelInfo
end
function logic_lobby_garage_scene.OpenCameraSeqSwitch()
  CameraSwitch = true
  CarSwitch = true
end
function logic_lobby_garage_scene.CloseCameraSwitch()
  CameraSwitch = false
end
function logic_lobby_garage_scene.CloseCarSwtich()
  CarSwitch = false
end
function logic_lobby_garage_scene.GetCameraSeqSwitch()
  return CameraSwitch
end
function logic_lobby_garage_scene.GetCarSwitch()
  return CarSwitch
end
function logic_lobby_garage_scene.RegisterContainer(Container)
  logic_lobby_garage_scene.RegisteredActorend
function logic_lobby_garage_scene.UnRegisterContainer()
  initialized = false
  logic_lobby_garage_scene.RegisteredActorContainer = nil
  EventSystem:unregistEvent(EVENTTYPE_LOBBY_SCENE, EVENTID_SCENE_GARAGE_MODEL_READY, logic_lobby_garage_scene.OnModelReady)
  if ModelInfo then
    ModelInfo.ReadyItem = 0
  end
end
function logic_lobby_garage_scene.GetGarageSceneScriptContainer()
  return logic_lobby_garage_scene.RegisteredActorContainer
end
function logic_lobby_garage_scene.UpdateCurrSystemType(system_type)
  CurrSystemType = system_type or 0
end
function logic_lobby_garage_scene.ResetCurrSystemType()
  CurrSystemType = logic_lobby_garage_scene.LoadSystemType.None
end
function logic_lobby_garage_scene.GetCurrSystemType()
  return CurrSystemType
end
local GetParsedOneLightParam = function(OneLightParam)
  local ParseLightParam = {
    Location = nil,
    Rotation = nil,
    Intensity = 0,
    InnerConeAngle = nil,
    OuterConeAngle = nil,
    AttenuationRadius = nil,
    ShadowBlendFactor = nil,
    MinRoughness = nil
  }
  local StringUtil = require("common.string_util")
  local Paramlist = StringUtil.Split(tostring(OneLightParam), "|")
  local Count = #Paramlist
  local GetNum = function(idx)
    if idx <= Count then
      return tonumber(Paramlist[idx])
    end
    return nil
  end
  ParseLightParam.Intensity = GetNum(1) or 0
  if 4 <= Count then
    ParseLightParam.Location = FVector(GetNum(2), GetNum(3), GetNum(4))
  end
  if 7 <= Count then
    ParseLightParam.Rotation = FRotator(GetNum(5), GetNum(6), GetNum(7))
  end
  ParseLightParam.InnerConeAngle = GetNum(8)
  ParseLightParam.OuterConeAngle = GetNum(9)
  ParseLightParam.AttenuationRadius = GetNum(10)
  ParseLightParam.ShadowBlendFactor = GetNum(11)
  ParseLightParam.MinRoughness = GetNum(12)
  return ParseLightParam
end
local GetParsedLightsParam = function(LightParams)
  local ParseLightParam = {}
  local KeyPreFix = "RaceCarLight"
  local MaxSuffix = 6
  for i = 1, MaxSuffix do
    local Key = KeyPreFix .. tostring(i)
    if LightParams[Key] ~= nil then
      ParseLightParam[Key] = GetParsedOneLightParam(LightParams[Key])
    end
  end
  return ParseLightParam
end
function logic_lobby_garage_scene.LoadVehicleStoreCamera()
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  local cameraID = Lobby_camera_manager_module:GetStoreVehicleCameraId()
  if Lobby_camera_manager_module.currentCameraID ~= cameraID then
    Lobby_camera_manager_module:SwitchCamera(cameraID)
  end
end
function logic_lobby_garage_scene.LoadVehicleStoreTopCamera()
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  local cameraID = Lobby_camera_manager_module:GetStoreVehicleTopViewCameraId()
  if Lobby_camera_manager_module.currentCameraID ~= cameraID then
    Lobby_camera_manager_module:SwitchCamera(cameraID)
  end
end
function logic_lobby_garage_scene.LoadVehicleCenterTopCamera()
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  local cameraID = Lobby_camera_manager_module:GetCenterVehicleTopViewCameraID()
  if Lobby_camera_manager_module.currentCameraID ~= cameraID then
    Lobby_camera_manager_module:SwitchCamera(cameraID)
  end
end
function logic_lobby_garage_scene.LoadVehicleCenterCamera()
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  local cameraID = Lobby_camera_manager_module:GetCenterVehicleCameraID()
  if Lobby_camera_manager_module.currentCameraID ~= cameraID then
    Lobby_camera_manager_module:SwitchCamera(cameraID)
  end
end
function logic_lobby_garage_scene.LoadVehicleScene(CameraID)
  log(bWriteLog and "logic_lobby_garage_scene.LoadVehicleScene CameraID:" .. tostring(CameraID))
  if not initialized then
    logic_lobby_garage_scene.Init()
  end
  local LobbyModelPossess = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyModelPossess)
  LobbyModelPossess:SetDisableRePossess(true)
  local gameInstance = slua_GameFrontendHUD:GetGameInstance()
  if gameInstance then
    log(bWriteLog and "set CSMSkipSceneCapture to 0")
    gameInstance:ExecuteCMD("r.Shadow.CSMSkipSceneCapture", 0)
  end
  local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
  store_supply_manager:SetCurrVehicleSceneType(StoreConst.VehicleSceneType.Ordinary)
  if LobbySceneManager.GetLastLevelName() ~= LobbySceneManager.LEVEL_NAME.GARAGE then
    local Extra = {
      bAsync = LobbySceneManager.ENUM_ASYNC.NORMAL_VECHILE,
      Callback = function()
        LobbySceneManager.SetMallWeaponParticalVisiable(false)
      end
    }
    LobbySceneManager.LoadStreamLevel(true, LobbySceneManager.LEVEL_NAME.GARAGE, CameraID, nil, Extra)
    return true
  else
    return false
  end
end
function logic_lobby_garage_scene.UnLoadVehicleScene()
  log(bWriteLog and "logic_lobby_garage_scene.UnLoadVehicleScene")
  LobbySceneManager.LoadStreamLevel(false, LobbySceneManager.LEVEL_NAME.GARAGE)
  logic_lobby_garage_scene.UnRegisterContainer()
  logic_lobby_garage_scene.ResetCurrSystemType()
end
function logic_lobby_garage_scene.LoadSuperCarVehicleScene()
  log(bWriteLog and "logic_lobby_garage_scene.LoadSuperCarVehicleScene")
  if not initialized then
    logic_lobby_garage_scene.Init()
  end
  local store_supply_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.store_supply_manager)
  store_supply_manager:SetCurrVehicleSceneType(StoreConst.VehicleSceneType.SuperCar)
  local getTime = slua.getMicroseconds
  local startTime = getTime()
  log(bWriteLog and "[bgp] load SuperCar scene")
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  local cameraID = Lobby_camera_manager_module:GetCenterSuperCarVehicleCameraID()
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  local nDeviceLevel = GameInstance:GetDeviceLevel()
  local LightLevel
  if nDeviceLevel <= 0 then
    LightLevel = "Lobby_Light_Low"
  end
  local Extra = {
    UnloadLevelName = LobbySceneManager.LEVEL_NAME.GARAGE,
    bAsync = LobbySceneManager.ENUM_ASYNC.SUPER_CAR,
    Callback = function()
      local logic_SuperCar_200Version = require("client.maps.logic_SuperCar_200Version")
      logic_SuperCar_200Version.CreateSpringArmActor()
    end
  }
  local LobbySceneModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.lobby_scene_module)
  if not LobbySceneModule:IsLoadingScene(LobbySceneManager.LEVEL_NAME.SUPERCAR, cameraID, LightLevel) then
    LobbySceneManager.LoadStreamLevel(true, LobbySceneManager.LEVEL_NAME.SUPERCAR, cameraID, LightLevel, Extra)
  end
  local gameInstance = slua_GameFrontendHUD:GetGameInstance()
  if gameInstance then
    log(bWriteLog and "set CSMSkipSceneCapture to 1")
    gameInstance:ExecuteCMD("r.Shadow.CSMSkipSceneCapture", 1)
  end
  local endTime = getTime()
  log(bWriteLog and "WardrobeLogic:EnterSupercarScene:" .. tostring((endTime - startTime) / 1000))
end
function logic_lobby_garage_scene.UnLoadSuperCarVehicleScene()
  log(bWriteLog and "[bgp] UnLoadSuperCarVehicleScene")
  if logic_lobby_garage_scene.TickLightTimer then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(logic_lobby_garage_scene.TickLightTimer)
    logic_lobby_garage_scene.TickLightTimer = nil
  end
  LobbySceneManager.LoadStreamLevel(false, LobbySceneManager.LEVEL_NAME.SUPERCAR)
  logic_lobby_garage_scene.UnRegisterContainer()
  local logic_SuperCar_200Version = require("client.maps.logic_SuperCar_200Version")
  logic_SuperCar_200Version.DestroySpringArmActor()
  local gameInstance = slua_GameFrontendHUD:GetGameInstance()
  if gameInstance then
    log(bWriteLog and "set CSMSkipSceneCapture to 0")
    gameInstance:ExecuteCMD("r.Shadow.CSMSkipSceneCapture", 0)
  end
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  if Lobby_camera_manager_module.currentCameraID ~= Lobby_camera_manager_module.Enum_CameraID.SuperCar_2000 then
    Lobby_camera_manager_module:SwitchCamera(Lobby_camera_manager_module.currentCameraID)
  end
  logic_lobby_garage_scene.ResetCurrSystemType()
end
function logic_lobby_garage_scene.SetTAA(bEnabled)
  local STExtraGameInstance = import("STExtraGameInstance")
  local GameInstance = STExtraGameInstance.GetInstance()
  local nDeviceLevel = GameInstance:GetDeviceLevel()
  if nDeviceLevel < 2 then
    return
  end
  if bEnabled == logic_lobby_garage_scene.bEnableTAA then
    return
  end
  logic_lobby_garage_scene.bEnableTAA = bEnabled
  log(bWriteLog and "logic_lobby_garage_scene.SetTAA bEnabled" .. tostring(bEnabled))
  GameInstance:SetEnableTAA(bEnabled)
end
local TickChangeLight = function(CurrentValues, TargetValues)
  local TotalTime = 0.3
  local TimeUtil = require("client.common.time_util")
  local nowSec = TimeUtil.GetServerTimeInSecWithFraction()
  local passedTime = 0
  while 0 < TotalTime - passedTime do
    log(bWriteLog and "TickChangeLight")
    passedTime = TimeUtil.GetServerTimeInSecWithFraction() - nowSec
    local interpRatio = passedTime / TotalTime
    if 1 < interpRatio then
      interpRatio = 1
    end
    for k, v in pairs(TargetValues) do
      local CActor = import("/Script/Engine.Actor")
      local LightActorArray = slua.Array(UEnums.EPropertyClass.Object, CActor)
      local GameplayStatics = import("GameplayStatics")
      local World = slua_GameFrontendHUD:GetWorld()
      LightActorArray = GameplayStatics.GetAllActorsWithTag(World, k, LightActorArray)
      for _, LightActor in pairs(LightActorArray) do
        if not slua.isValid(LightActor) then
          break
        end
        local LightComponentC = import("LightComponentBase")
        local LightComp = LightActor:GetComponentByClass(LightComponentC)
        if slua.isValid(LightComp) and CurrentValues[k] then
          LightComp:SetIntensity((v.Intensity - CurrentValues[k]) * interpRatio + CurrentValues[k])
        end
        break
      end
    end
    coroutine.yield(0)
  end
end
function logic_lobby_garage_scene.ProcessLight(ItemId)
  log(bWriteLog and "[cw] logic_lobby_garage_scene.ProcessLight Car ID : " .. tostring(ItemId))
  local RacecarCfg = CDataTable.GetTableData("BetterVehicleEffect", ItemId)
  if RacecarCfg == nil or RacecarCfg.MiniTVVehiclePhoto == 0 then
    log(bWriteLog and "[cw] logic_lobby_garage_scene.ProcessLight Not RaceCar")
    return
  end
  local LightParam = CDataTable.GetTableData("RaceCarLightParam", RacecarCfg.LightParamID)
  if not LightParam then
    log(bWriteLog and "[cw] logic_lobby_garage_scene.ProcessLight No LightParam")
    return
  end
  local GameIns = slua_GameFrontendHUD:GetGameInstance()
  local World = slua_GameFrontendHUD:GetWorld()
  if not slua.isValid(GameIns) or not slua.isValid(World) then
    log(bWriteLog and "[cw] logic_lobby_garage_scene.ProcessLight GameInstance or World Not Valid")
    return
  end
  logic_lobby_garage_scene.LightItemID = ItemId
  if logic_lobby_garage_scene.IsInLicensePlateLight then
    log(bWriteLog and "[cw] logic_lobby_garage_scene.ProcessLight IsInLicensePlateLight")
    return
  end
  local GameplayStatics = import("GameplayStatics")
  GameplayStatics.FlushLevelStreaming(GameIns)
  local CActor = import("/Script/Engine.Actor")
  local ParsedParams = GetParsedLightsParam(LightParam)
  local CurrentIntensityValues = {}
  for k, v in pairs(ParsedParams) do
    local LightActorArray = slua.Array(UEnums.EPropertyClass.Object, CActor)
    LightActorArray = GameplayStatics.GetAllActorsWithTag(World, k, LightActorArray)
    for _, LightActor in pairs(LightActorArray) do
      if not slua.isValid(LightActor) then
        break
      end
      if v.Location then
        LightActor:K2_SetActorLocation(v.Location, false, nil, false)
      end
      if v.Rotation then
        LightActor:K2_SetActorRotation(v.Rotation, false)
      end
      local LightComponentC = import("LightComponentBase")
      local LightComp = LightActor:GetComponentByClass(LightComponentC)
      if slua.isValid(LightComp) then
        CurrentIntensityValues[k] = LightComp.Intensity
        if v.MinRoughness then
          LightComp.MinRoughness = v.MinRoughness
        end
        if v.ShadowBlendFactor then
          LightComp.ShadowBlendFactor = v.ShadowBlendFactor
        end
      end
      if v.InnerConeAngle or v.OuterConeAngle or v.AttenuationRadius then
        local SpotLightComponentC = import("SpotLightComponent")
        local SpotLightComp = LightActor:GetComponentByClass(SpotLightComponentC)
        if slua.isValid(SpotLightComp) then
          if v.InnerConeAngle then
            SpotLightComp:SetInnerConeAngle(v.InnerConeAngle)
          end
          if v.OuterConeAngle then
            SpotLightComp:SetOuterConeAngle(v.OuterConeAngle)
          end
          if v.AttenuationRadius then
            SpotLightComp:SetAttenuationRadius(v.AttenuationRadius)
          end
        end
      end
      break
    end
  end
  local time_ticker = require("common.time_ticker")
  if logic_lobby_garage_scene.TickLightTimer then
    time_ticker.RemoveTimer(logic_lobby_garage_scene.TickLightTimer)
  end
  logic_lobby_garage_scene.TickLightTimer = time_ticker.AddTimer(0, function()
    TickChangeLight(CurrentIntensityValues, ParsedParams)
  end)
end
function logic_lobby_garage_scene.SwitchToLicensePlateLight()
  logic_lobby_garage_scene.IsInLicensePlateLight = true
  local World = slua_GameFrontendHUD:GetWorld()
  if not slua.isValid(World) then
    log(bWriteLog and "logic_lobby_garage_scene.SwitchToLicensePlateLight GameInstance or World Not Valid")
    return
  end
  local CActor = import("/Script/Engine.Actor")
  local GameplayStatics = import("GameplayStatics")
  local LightActorArray = slua.Array(UEnums.EPropertyClass.Object, CActor)
  LightActorArray = GameplayStatics.GetAllActorsWithTag(World, "RaceCarLight6", LightActorArray)
  if LightActorArray:Num() < 1 then
    log(bWriteLog and "logic_lobby_garage_scene.SwitchToLicensePlateLight LightActorArray Num is 0")
    return
  end
  local LightActor = LightActorArray:Get(0)
  LightActor:K2_SetActorRotation(FRotator(-45, -0.455708, 0), false)
end
function logic_lobby_garage_scene.ExitToLicensePlateLight()
  logic_lobby_garage_scene.IsInLicensePlateLight = false
  logic_lobby_garage_scene.ProcessLight(logic_lobby_garage_scene.LightItemID)
end
return logic_lobby_garage_scene