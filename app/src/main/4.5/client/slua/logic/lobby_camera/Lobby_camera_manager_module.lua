local lobby_camera_manager_module = {
  CONST = {
    CAMERA_CLASS_PATH = "/Script/Engine.CameraActor",
    ACTOR_CLASS_PATH = "Actor",
    LONG_SCREEN_THRESHOLD = 2.0,
    WIDE_SCREEN_THRESHOLD = 1.45,
    TABLE_CACHE_SETTINGS = {
      DEFAULT = {MAX_NUM = 2, INIT_WEIGH = 0},
      LobbyCameraInfo = {MAX_NUM = 10, INIT_WEIGH = 0},
      LobbyCameraAnim = {MAX_NUM = 3, INIT_WEIGH = 0},
      EnlargeLensCameraCfg = {MAX_NUM = 7, INIT_WEIGH = 0}
    }
  },
  Enum_SequenceCallbackHandler = {
    onSequenceBeginPlayFunc = "_onSequenceBeginPlayFunc",
    onSequenceEndPlayFunc = "_onSequenceEndPlayFunc"
  },
  Enum_CameraID = {
    Lobby_Default = 10001,
    Lobby_Team = 10002,
    Lobby_Wardrobe = 10002,
    store_weapon = 10114,
    store_vehicle = 10128,
    store_preview = 10114,
    character_system = 10122,
    store_general = 10124,
    store_supply = 10124,
    item_preview = 10127,
    vehicle_screen_normal = 10128,
    vehicle_screen_long = 10129,
    vehicle_screen_rect = 10130,
    vehicle_topView_screen_normal = 10131,
    vehicle_topView_screen_long = 10132,
    vehicle_topView_screen_rect = 10133,
    wardrobe_fashionbag = 10161,
    Pictorial = 10181,
    allStar_shop = 10109,
    arena_weapon = 30001,
    TPlan_Default = 32119,
    TPlan_Team = 32120,
    TPlan_Mid = 32121,
    TPlan_NPC = 32122,
    TPlan_Rank = 32123,
    Return_Chest = 36005,
    WorldCup_Exchange = 36006,
    Golden_Clothes = 36008,
    Super_Airdrop = 36019,
    Dragon_Ball = 10124,
    RpPreview = 10113,
    GlidePreview = 10184,
    XsuitExchange = 36016,
    XsuitPreview = 36017,
    XsuitWorkshop = 32117,
    XsuitWorkshopGlide = 32141,
    XSuitBranchCamera = 36032,
    VehicleWorkshop = 10116,
    Vehicle_Center_Normal = 10163,
    Vehicle_Center_Long = 10164,
    Vehicle_Center_Rect = 10165,
    Vehicle_Center_TopView_Normal = 10166,
    Vehicle_Center_TopView_Long = 10167,
    Vehicle_Center_TopView_Rect = 10168,
    Vehicle_Center_Exchange_SuperCar_Normal = 10169,
    Vehicle_Center_SuperCar_Normal = 10175,
    Vehicle_Center_SuperCar_Long = 10170,
    Vehicle_Center_SuperCar_Rect = 10171,
    Vehicle_Center_SuperCar_TopView_Normal = 10172,
    Vehicle_Center_SuperCar_TopView_Long = 10173,
    Vehicle_Center_SuperCar_TopView_Rect = 10174,
    Lobby_SeasonAward_HonorRoad = 10189,
    SuperCar_2000 = 10180,
    SmallRP300 = 36012,
    SmallRP300_BuyScore = 36013,
    SmallRP300_Exchange = 36014,
    PeakGameRank = 36020,
    MultiplayerAvatarPose = 36022,
    PartnerAvatarPose = 36023,
    WowPassMain = 36025,
    WowPassBuyLevel = 36026,
    WowPassPrivilge = 36027,
    WOWInventory = 36029
  },
  Enum_CameraRatio = {
    LongScreen = 0,
    WideScreen = 1,
    NormalScreen = 2
  },
  Enum_ProjectMode = {Perspective = 0, Orthographic = 1},
  _currentSceneComp = nil,
  _tableCacheData = {},
  currentCameraID = 0,
  lastCameraID = 0,
  _nextLightLevelName = nil,
  _currentSeqPlayer = nil,
  _currentSeqActor = nil,
  _onSequenceBeginPlayFunc = nil,
  _onSequenceEndPlayFunc = nil
}
local UIUtil = require("client.common.ui_util")
local selfTypeRef, selfRef
local _CleanTickTimer = function()
  local time_ticker = require("common.time_ticker")
  if selfRef._tick then
    time_ticker.RemoveTimer(selfRef._tick)
    selfRef._tick = nil
  end
end
local _GetCameraRatioByViewport = function(vViewPortSize)
  local c = lobby_camera_manager_module.CONST
  local e = lobby_camera_manager_module.Enum_CameraRatio
  local ratio = tonumber(vViewPortSize.X) / tonumber(vViewPortSize.Y)
  if ratio >= c.LONG_SCREEN_THRESHOLD then
    return e.LongScreen
  elseif ratio <= c.WIDE_SCREEN_THRESHOLD then
    return e.WideScreen
  else
    return e.NormalScreen
  end
end
local _GetCurrentCameraRatio = function()
  local viewPortSize = UIUtil.GetViewportSize()
  return _GetCameraRatioByViewport(viewPortSize)
end
local _RatioDataToTable = function(nLongScreenData, nWideScreenData, nNormalScreenData)
  local e = lobby_camera_manager_module.Enum_CameraRatio
  return {
    [e.LongScreen] = nLongScreenData,
    [e.WideScreen] = nWideScreenData,
    [e.NormalScreen] = nNormalScreenData
  }
end
local _GetDataBaseOnCurrentRatio = function(nLongScreenData, nWideScreenData, nNormalScreenData)
  local e = lobby_camera_manager_module.Enum_CameraRatio
  local adapt = _GetCurrentCameraRatio()
  local data = _RatioDataToTable(nLongScreenData, nWideScreenData, nNormalScreenData)
  local res = data[adapt]
  if res == nil or type(res) == "string" and res == "" then
    res = data[e.NormalScreen]
  end
  return res
end
local _GetDataBaseOnRatio = function(nLongScreenData, nWideScreenData, nNormalScreenData, priorityRatio)
  local data = _RatioDataToTable(nLongScreenData, nWideScreenData, nNormalScreenData)
  return data[priorityRatio] or nil
end
local _StrToList = function(str)
  if str == nil or type(str) ~= "string" then
    return {}
  end
  local StringUtil = require("common.string_util")
  return StringUtil.SplitToNum(str, ";")
end
local _TransStrToVector3D = function(str)
  local list = _StrToList(str)
  local UKismetMathLibrary = import("KismetMathLibrary")
  return UKismetMathLibrary.MakeVector(list[1] or 0, list[2] or 0, list[3] or 0)
end
local _TransStrToRotation = function(str)
  local list = _StrToList(str)
  local UKismetMathLibrary = import("KismetMathLibrary")
  return UKismetMathLibrary.MakeRotator(list[1] or 0, list[2] or 0, list[3] or 0)
end
local _TransVectorToRotator = function(vVector3D)
  local x = vVector3D and vVector3D.X or 0
  local y = vVector3D and vVector3D.Y or 0
  local z = vVector3D and vVector3D.Z or 0
  local UKismetMathLibrary = import("KismetMathLibrary")
  return UKismetMathLibrary.MakeRotator(x, y, z)
end
local _MakeTransform = function(vLocation, rRotation, vScale)
  local UKismetMathLibrary = import("KismetMathLibrary")
  return UKismetMathLibrary.MakeTransform(vLocation, rRotation, vScale)
end
local _TransStrLocStrRotStrScaToTransform = function(sLocation, sRotation, sScale)
  local location = _TransStrToVector3D(sLocation)
  local rotation = _TransStrToRotation(sRotation)
  local scale = _TransStrToVector3D(sScale)
  return _MakeTransform(location, rotation, scale)
end
local _TransLocRotScaToTransform = function(vLocation, rRotation, vScale)
  local UKismetMathLibrary = import("KismetMathLibrary")
  return UKismetMathLibrary.MakeTransform(vLocation, rRotation, vScale)
end
local _ShouldAutoAdjustFOV = function(nCameraID)
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  local switchOn = tonumber(UKismetSystemLibrary.GetConsoleVariableValue("r.AutoFixCameraAspectRatio"))
  if switchOn == nil or switchOn <= 0 then
    return false
  end
  local Lobby_camera_extra_config = require("client.slua.logic.lobby_camera.Lobby_camera_extra_config")
  if Lobby_camera_extra_config.CheckIfDontChangeCameraWhenViewPortRatioChange(nCameraID) then
    return false
  end
  local e = lobby_camera_manager_module.Enum_CameraRatio
  local ratio = _GetCurrentCameraRatio()
  if ratio == e.LongScreen then
    return true
  end
  return false
end
local _GetTransformInfoByCameraID = function(nCameraID)
  local info = selfTypeRef:GetLobbyCameraInfoByCameraID(nCameraID)
  if info == nil then
    return FTransform()
  end
  local e = lobby_camera_manager_module.Enum_CameraRatio
  local ratio = _GetCurrentCameraRatio()
  local locTmp
  if ratio == e.LongScreen then
    locTmp = info.CameraLocationX
  elseif ratio == e.WideScreen then
    locTmp = info.CameraLocationWidth
  end
  local adjustfov = _ShouldAutoAdjustFOV(nCameraID)
  if adjustfov then
    locTmp = info.CameraLocation
  end
  if not locTmp or type(locTmp) ~= "string" or locTmp == "" then
    locTmp = info.CameraLocation
  end
  local trans = _TransStrLocStrRotStrScaToTransform(locTmp, info.CameraRotation, info.CameraScale)
  return trans
end
local _HandleBlendTime = function(nCameraID, nRawBlendTime, nDefaultBlendTime)
  log(bWriteLog and "[cw][camera] _HandleBlendTime(" .. tostring(nCameraID) .. ", " .. tostring(nRawBlendTime) .. ")")
  local blendTime
  if nRawBlendTime and type(nRawBlendTime) == "number" then
    blendTime = nRawBlendTime
  end
  local info = selfTypeRef:GetLobbyCameraInfoByCameraID(nCameraID)
  if blendTime == nil and info and info.BlendTime and type(info.BlendTime) == "string" and info.BlendTime ~= "" then
    blendTime = tonumber(info.BlendTime)
  end
  if blendTime == nil and nDefaultBlendTime then
    blendTime = tonumber(nDefaultBlendTime)
  end
  if blendTime == nil then
    blendTime = 0
  end
  if blendTime ~= 0 then
    local SequenceActor = import("UAELevelSequenceActor")
    if SequenceActor and SequenceActor.HasActiveSequenceActor and SequenceActor:HasActiveSequenceActor() then
      log(bWriteLog and "[cw][camera] _HandleBlendTime HasActiveSequenceActor")
      blendTime = 0
    end
  end
  log(bWriteLog and "[cw][camera] _HandleBlendTime return blendTime: " .. tostring(blendTime))
  return blendTime
end
local _GetCameraManager = function()
  local GameplayStatics = import("GameplayStatics")
  local cameraManager = GameplayStatics.GetPlayerCameraManager(slua_GameFrontendHUD:GetWorld(), 0)
  if cameraManager == nil then
    log("[cw][camera] lobby_camera_manager_module._GetCameraManager() result is nil")
  end
  return cameraManager
end
local _IsLowPerformanceDevice = function()
  local gameInstance = UIUtil.GetGameInstance()
  return gameInstance:GetExactDeviceLevel() <= 0
end
local _MakeAndGetAnAssertByPath = function(sPath)
  log(bWriteLog and "[cw][camera] lobby_camera_manager_module._MakeAndGetAnAssertByPath try to get an asset base on: " .. tostring(sPath))
  if sPath == nil then
    log_error(bWriteLog and "[cw][camera] lobby_camera_manager_module._MakeAndGetAnAssertByPath sPath is nil")
    return nil
  end
  local KismetSystemLibrary = import("KismetSystemLibrary")
  if KismetSystemLibrary == nil then
    log_error(bWriteLog and "[cw][camera] lobby_camera_manager_module._MakeAndGetAnAssertByPath KismetSystemLibrary is nil")
    return nil
  end
  local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
  if STExtraBlueprintFunctionLibrary == nil then
    log_error(bWriteLog and "[cw][camera] lobby_camera_manager_module._MakeAndGetAnAssertByPath STExtraBlueprintFunctionLibrary is nil")
    return nil
  end
  local softObjPath = KismetSystemLibrary.MakeSoftObjectPath(sPath)
  local asset = STExtraBlueprintFunctionLibrary.GetAssetByAssetReference(softObjPath)
  if asset == nil then
    log_error(bWriteLog and "[cw][camera] lobby_camera_manager_module._MakeAndGetAnAssertByPath asset is nil")
  end
  return asset
end
local _GetCsvValueByTabAndKey = function(sCsvName, key)
  if sCsvName == nil or type(sCsvName) ~= "string" then
    return
  end
  if key == nil then
    return nil
  end
  local cfg = CDataTable.GetTableData(sCsvName, key)
  return cfg
end
local _DestroySequenceActor = function()
  if slua.isValid(selfRef._currentSeqActor) then
    selfRef._currentSeqActor:K2_DestroyActor()
    selfRef._currentSeqActor = nil
  end
end
local _ReleaseSequencePlayer = function()
  if slua.isValid(selfRef._currentSeqPlayer) then
    selfRef._currentSeqPlayer:Stop()
    selfRef._currentSeqPlayer = nil
  end
end
local _GetSequenceCameraActor = function()
  local GameplayStatics = import("GameplayStatics")
  local ActorClass = import(lobby_camera_manager_module.CONST.ACTOR_CLASS_PATH)
  local ActorArray = slua.Array(UEnums.EPropertyClass.Object, ActorClass)
  ActorArray = GameplayStatics.GetAllActorsWithTag(UIUtil.GetGameInstance(), "CloseUpCamera", ActorArray)
  local Actor
  if ActorArray then
    for _, actor in pairs(ActorArray) do
      if slua.isValid(actor) then
        Actor = actor
        break
      end
    end
  end
  return Actor
end
local _ExecuteCallback = function(callbackHandlerName)
  if selfRef[callbackHandlerName] and type(selfRef[callbackHandlerName]) == "function" then
    selfRef[callbackHandlerName]()
  end
  selfRef[callbackHandlerName] = nil
end
local _ChangeToLobbyCamera = function()
  local currentCamera = selfTypeRef:GetCurrentCamera()
  if currentCamera then
    local EViewTargetBlendFunction = import("EViewTargetBlendFunction")
    local PlayController = slua_GameFrontendHUD:GetPlayerController()
    if not PlayController then
      log_error(bWriteLog and "[cw][camera] PlayController is nil")
      return
    end
    PlayController:SetViewTargetWithBlend(currentCamera, 0, EViewTargetBlendFunction.VTBlend_Linear, 0, false)
  end
end
local _LoadLightLevelByLightLevelName = function(sLightLevelName)
  LobbySceneManager.LoadLightLevel(sLightLevelName)
  selfRef._nextLightLevelName = nil
  return true
end
local _GetLightLevelNameByCameraID = function(nCameraID)
  local lightLevelName = ""
  if selfRef:IsMidLobbyCameraID(nCameraID) then
    local LobbyThemeManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyThemeManager)
    local SkinID = LobbyThemeManager:GetDisplayLobbySkin()
    lightLevelName = selfRef:GetLightLevelNameByLobbySkinID(SkinID)
  end
  if not lightLevelName or lightLevelName == "" then
    local info = selfTypeRef:GetLobbyCameraInfoByCameraID(nCameraID)
    if not info then
      return ""
    end
    lightLevelName = info.LightLevelName
    if _IsLowPerformanceDevice() and info.LightLevelNameLow ~= "" then
      lightLevelName = info.LightLevelNameLow
    end
  end
  return lightLevelName
end
local _LoadLightLevelByCameraID = function(nCameraID)
  local lightLevelName = _GetLightLevelNameByCameraID(nCameraID)
  print(bWriteLog and "_LoadLightLevelByCameraID " .. tostring(nCameraID) .. " lightLevelName:" .. tostring(lightLevelName))
  if not lightLevelName or lightLevelName == "" then
    return false
  end
  LobbySceneManager.LoadLightLevel(lightLevelName)
  return true
end
local _PlayCameraAnimation = function(nCameraID)
  local cameraManager = _GetCameraManager()
  if cameraManager == nil then
    return
  end
  cameraManager:StopAllCameraAnims(true)
  local animCfg = selfTypeRef:GetLobbyCameraAnimCfgByKey(nCameraID)
  if animCfg == nil then
    return
  end
  local asset = _MakeAndGetAnAssertByPath(animCfg.CameraAnimAssetPath)
  if asset == nil then
    return
  end
  cameraManager:PlayCameraAnim(asset, 1, 1, 0, 0, true, false, 0, 0, FRotator(0, 0, 0))
end
local _BeforeSwitchCamera = function(beforeCameraID, targetCameraID)
  log(bWriteLog and "[cw][camera] _BeforeSwitchCamera(" .. tostring(beforeCameraID) .. " to " .. tostring(targetCameraID) .. ") ")
end
local _OnSwitchCameraFailed = function(currentCameraID, targetCameraID)
  log(bWriteLog and "[cw][camera] _OnSwitchCameraFailed(" .. tostring(currentCameraID) .. " to " .. tostring(targetCameraID) .. ") ")
  selfRef._nextLightLevelName = nil
end
local _AfterSwitchCamera = function(oldCameraID, newCameraID, bIgnoreLightLevel)
  log(bWriteLog and "[cw][camera] _AfterSwitchCamera(" .. tostring(oldCameraID) .. " to " .. tostring(newCameraID) .. ") " .. " bIgnoreLightLevel:" .. tostring(bIgnoreLightLevel))
  selfRef.lastCameraID = oldCameraID
  selfRef.currentCameraID = newCameraID
  local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
  MallSystemWeaponModelHandler.SetCameraID(newCameraID)
  if not bIgnoreLightLevel then
    local loadLightSuccess
    if selfRef._nextLightLevelName and selfRef._nextLightLevelName ~= "" then
      loadLightSuccess = _LoadLightLevelByLightLevelName(selfRef._nextLightLevelName)
    else
      loadLightSuccess = _LoadLightLevelByCameraID(newCameraID)
    end
  end
  _PlayCameraAnimation(newCameraID)
  EventSystem:postEvent(EVENTTYPE_CAMERA, EVENTID_CAMERA_SWITCHED, newCameraID)
  EventSystem:postEvent(EVENTTYPE_CAMERA, EVENTID_REAL_CAMERA_SWITCHED, newCameraID)
end
function lobby_camera_manager_module:GetTransformInfoByCameraID(nCameraID)
  local info = self:GetLobbyCameraInfoByCameraID(nCameraID)
  if not info then
    return nil
  end
  local e = lobby_camera_manager_module.Enum_CameraRatio
  local ratio = _GetCurrentCameraRatio()
  local locTmp
  if ratio == e.LongScreen then
    locTmp = info.CameraLocationX
  elseif ratio == e.WideScreen then
    locTmp = info.CameraLocationWidth
  end
  local adjustfov = _ShouldAutoAdjustFOV(nCameraID)
  if adjustfov then
    locTmp = info.CameraLocation
  end
  if not locTmp or type(locTmp) ~= "string" or locTmp == "" then
    locTmp = info.CameraLocation
  end
  local location = _TransStrToVector3D(locTmp)
  local rotation = _TransStrToRotation(info.CameraRotation)
  local scale = _TransStrToVector3D(info.CameraScale)
  return location, rotation, scale
end
function lobby_camera_manager_module:_ChangeCamera_ByID(nNewCameraID, nBlendTime)
  if nNewCameraID == nil then
    return false
  end
  nNewCameraID = tonumber(nNewCameraID)
  nBlendTime = nBlendTime and tonumber(nBlendTime) or 0
  local info = selfTypeRef:GetLobbyCameraInfoByCameraID(nNewCameraID)
  if not info then
    return false
  end
  local trans = _GetTransformInfoByCameraID(nNewCameraID)
  local bAdjustfov = _ShouldAutoAdjustFOV(nNewCameraID)
  local e = lobby_camera_manager_module.Enum_ProjectMode
  local fov = tonumber(info.FieldOfView)
  local full_preview_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.full_preview_module)
  full_preview_module:SwitchCamera(nNewCameraID, fov)
  self:SwitchSceneCameraToTransform(trans, e.Perspective, fov, nBlendTime, false, bAdjustfov)
  return true
end
function lobby_camera_manager_module:_ChangeCamera_ByConfig(cfg)
  local _error = function(nullField)
    log_error(bWriteLog and "[cw][camera] " .. tostring(nullField) .. " can't be nil")
  end
  if cfg == nil or type(cfg) ~= "table" then
    _error("cfg")
    return
  end
  log_tree("[cw][camera] cfg:", cfg)
  local location = cfg.location
  if location == nil then
    _error(location)
    return false
  end
  if type(location) == "string" and location ~= "" then
    location = _TransStrToVector3D(location)
  end
  local rotation = cfg.rotation
  if rotation == nil then
    _error(rotation)
    return false
  end
  if type(rotation) == "string" and rotation ~= "" then
    rotation = _TransStrToRotation(rotation)
  end
  local scale = cfg.scale
  if scale == nil then
    _error("scale")
    return false
  end
  if type(scale) == "string" and scale ~= "" then
    scale = _TransStrToVector3D(scale)
  end
  local trans = _TransLocRotScaToTransform(location, rotation, scale)
  local fov = cfg.fov
  if fov == nil then
    _error("fov")
    return false
  end
  fov = tonumber(fov)
  local full_preview_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.full_preview_module)
  full_preview_module:GmSwitchCamera(nil, fov)
  local e = lobby_camera_manager_module.Enum_ProjectMode
  local projectMode = cfg.projectMode and tonumber(cfg.projectMode) or e.Perspective
  local blendTime = cfg.blendTime and tonumber(cfg.blendTime) or 0
  full_preview_module:OnCameraChanged(location.Y)
  self:SwitchSceneCameraToTransform(trans, projectMode, fov, blendTime, false, false)
  return true
end
function lobby_camera_manager_module:ctor(selfType)
  selfTypeRef = selfType
  selfRef = self
  self.SAActor = nil
end
function lobby_camera_manager_module:OnPreSwitchGameStatus(preState, nextState)
  log(bWriteLog and "[cw][camera] lobby_camera_manager_module:OnPreSwitchGameStatus(" .. tostring(preState) .. ", " .. tostring(nextState) .. ")")
  _DestroySequenceActor()
  _ReleaseSequencePlayer()
  self:LevelSequence_Stop()
  self:UnRegistEvents()
end
function lobby_camera_manager_module:OnPostSwitchGameStatus(preState, nextState)
  log(bWriteLog and "[cw][camera] lobby_camera_manager_module:OnPostSwitchGameStatus(" .. tostring(preState) .. ", " .. tostring(nextState) .. ")")
  _CleanTickTimer()
  if preState == GameStatus.Login and nextState == GameStatus.Lobby then
    local time_ticker = require("common.time_ticker")
    selfRef._tick = time_ticker.AddTimerOnce(0, function()
      local lobbyMainLogic = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
      if lobbyMainLogic.DefaultMainCity then
        lobbyMainLogic.curPage = 0
        lobbyMainLogic.fromPage = 0
        lobbyMainLogic.toPage = 0
        EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_SWITCH_TO_MAIN_CITY)
      else
        self:SwitchCamera(self:GetCurrentCameraID())
      end
      local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
      MallSystemWeaponModelHandler.RefreshWeaponLocation()
    end)
  end
end
function lobby_camera_manager_module:SwitchSceneCameraToTransform(targetTrans, ProjectionMode, Fov, BlendTime, bForce, bAutoFixAspect)
  local Utility = require("common.utility")
  local GameAutotest = Utility.GetGameInstanceSubsystemByName("AutoTestSubsystem")
  if slua.isValid(GameAutotest) then
    log(bWriteLog and "lobby_camera_manager_module:SwitchSceneCameraToTransform GameAutotest valid")
    if GameAutotest:IsAutoRunTestGame() then
      log(bWriteLog and "lobby_camera_manager_module:SwitchSceneCameraToTransform IsAutoRunTestGame true")
      return
    end
  end
  local frontendUtils = slua_GameFrontendHUD:GetUtils()
  frontendUtils:SwitchSceneCameraToTransform(targetTrans, ProjectionMode, Fov, BlendTime, bForce, bAutoFixAspect)
end
function lobby_camera_manager_module:SwitchSceneCameraToTransform_1(targetTrans, Fov, BlendTime)
  local e = lobby_camera_manager_module.Enum_ProjectMode
  self:SwitchSceneCameraToTransform(targetTrans, e.Perspective, Fov, BlendTime, false, false)
end
function lobby_camera_manager_module:SetCurrentCameraID(id)
  log(bWriteLog and "[cw][camera] lobby_camera_manager_module:SetCurrentCameraID(" .. tostring(id) .. ")")
  selfRef.currentCameraID = tonumber(id)
end
function lobby_camera_manager_module:GetCurrentCameraID()
  log(bWriteLog and string.format("[cw][camera] lobby_camera_manager_module:GetCurrentCameraID %s", selfRef.currentCameraID))
  return selfRef.currentCameraID
end
function lobby_camera_manager_module:GetCurrentCamera()
  local c = lobby_camera_manager_module.CONST
  local gameInstance = UIUtil.GetGameInstance()
  local frontendHUD = UIUtil.GetGameFrontendHUD()
  local UGameplayStatics = import("GameplayStatics")
  local cameraArray = UGameplayStatics.GetAllActorsOfClass(gameInstance, import(c.CAMERA_CLASS_PATH), slua.Array(UEnums.EPropertyClass.Object, import(c.ACTOR_CLASS_PATH)))
  local usingCameraName = tostring(frontendHUD:GetUtils().CurrentSceneCameraName)
  local cameraRef
  if cameraArray ~= nil then
    local KismetSystemLibrary = import("KismetSystemLibrary")
    for i = 0, cameraArray:Num() - 1 do
      local element = cameraArray:Get(i)
      local cameraName = KismetSystemLibrary.GetObjectName(element)
      if usingCameraName == tostring(cameraName) then
        cameraRef = element
        break
      end
    end
  else
    log(bWriteLog and "[cw][camera] lobby_camera_manager_module:GetCurrentCamera, can't get cameraRef." .. "gameInstance = " .. tostring(gameInstance) .. ", cameraArray = " .. tostring(cameraArray))
  end
  return cameraRef
end
function lobby_camera_manager_module:GetCurrentCameraRatio()
  return _GetCurrentCameraRatio()
end
function lobby_camera_manager_module:GetCameraCfgTransformByCameraID(nCameraID)
  return _GetTransformInfoByCameraID(nCameraID)
end
function lobby_camera_manager_module:TransWordPosToCameraPos(vObjectWorldPosition, vCameraPosition, vCameraRotation)
  log(bWriteLog and "[cw][camera] lobby_camera_manager_module:TransWordPosToCameraPos(" .. tostring(vObjectWorldPosition) .. ", " .. tostring(vCameraPosition) .. ", " .. tostring(vCameraRotation) .. ")")
  local UKismetMathLibrary = import("KismetMathLibrary")
  local transform = _MakeTransform(vCameraPosition, _TransVectorToRotator(vCameraRotation), FVector(1, 1, 1))
  return UKismetMathLibrary.TransformLocation(transform, vObjectWorldPosition)
end
function lobby_camera_manager_module:OnViewportSizeChanged(vViewportOld, vViewportNew)
  log(bWriteLog and "lobby_camera_manager_module:OnViewportSizeChanged, Old: " .. tostring(vViewportOld.X) .. "," .. tostring(vViewportOld.Y) .. ", New: " .. tostring(vViewportNew.X) .. "," .. tostring(vViewportNew.Y))
  if selfRef.currentCameraID ~= 0 then
    local ratioOld = _GetCameraRatioByViewport(vViewportOld)
    local ratioNew = _GetCameraRatioByViewport(vViewportNew)
    if ratioOld ~= ratioNew then
      local logic_main_city_camera_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_camera_manager)
      local bCanSwitch = logic_main_city_camera_manager:CanSwitchCameraWhenViewportSizeChanged()
      log(bWriteLog and "lobby_camera_manager_module:OnViewportSizeChanged bCanSwitch = " .. tostring(bCanSwitch))
      if bCanSwitch then
        log(bWriteLog and "lobby_camera_manager_module:OnViewportSizeChanged SwitchCamera due to aspect ratio change!!")
        local Lobby_camera_extra_config = require("client.slua.logic.lobby_camera.Lobby_camera_extra_config")
        if Lobby_camera_extra_config.CheckIfDontChangeCameraWhenViewPortRatioChange(selfRef.currentCameraID) then
          log(bWriteLog and "[cw][camera] camera id " .. tostring(selfRef.currentCameraID) .. " is in the DontChangeCameraWhenViewPortRatioChangeList")
        else
          self:SwitchCamera_Only(selfRef.currentCameraID, 0)
          local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
          MallSystemWeaponModelHandler.RefreshWeaponLocation()
        end
      end
    end
  end
  EventSystem:postEvent(EVENTTYPE_CAMERA, EVENTID_SCREEN_RATIO_CHANGED, vViewportOld, vViewportNew)
end
function lobby_camera_manager_module:TransCameraPosToWordPos(vObjectWorldPosition, vCameraPosition, vCameraRotation)
  log(bWriteLog and "[cw][camera] lobby_camera_manager_module:transCameraPosToWordPos(" .. tostring(vObjectWorldPosition) .. ", " .. tostring(vCameraPosition) .. ", " .. tostring(vCameraRotation) .. ")")
  local UKismetMathLibrary = import("KismetMathLibrary")
  local transform = _MakeTransform(vCameraPosition, _TransVectorToRotator(vCameraRotation), FVector(1, 1, 1))
  return UKismetMathLibrary.InverseTransformLocation(transform, vObjectWorldPosition)
end
function lobby_camera_manager_module:OnDeviceRotationChanged(rotation)
  log(bWriteLog and string.format("lobby_camera_manager_module:OnDeviceRotationChanged, rotation:%s", rotation))
  EventSystem:postEvent(EVENTTYPE_CAMERA, EVENTID_DEVICE_ROTATION_CHANGED, rotation)
end
function lobby_camera_manager_module:GetLobbyCameraInfoByCameraID(nCameraID)
  log(bWriteLog and "[cw][camera] lobby_camera_manager_module:GetLobbyCameraInfoByCameraID(" .. tostring(nCameraID) .. ")")
  if nCameraID == nil then
    nCameraID = selfRef.currentCameraID
  end
  nCameraID = tonumber(nCameraID)
  return _GetCsvValueByTabAndKey("LobbyCameraInfo", nCameraID)
end
function lobby_camera_manager_module:GetLobbyCameraLocationByCameraID(nCameraID, ratioType)
  log(bWriteLog and "[cw][camera] lobby_camera_manager_module:GetLobbyCameraLocationByCameraID(" .. tostring(nCameraID) .. ", " .. tostring(ratioType) .. ")")
  local info = self:GetLobbyCameraInfoByCameraID(nCameraID)
  if not info then
    return nil
  end
  local res
  if ratioType then
    res = _GetDataBaseOnRatio(info.CameraLocationX, info.CameraLocationWidth, info.CameraLocation, ratioType)
  end
  if not res or type(res) ~= "string" or res == "" then
    res = _GetDataBaseOnCurrentRatio(info.CameraLocationX, info.CameraLocationWidth, info.CameraLocation)
  end
  local adjustfov = _ShouldAutoAdjustFOV(nCameraID)
  if adjustfov then
    res = info.CameraLocation
  end
  if not res or type(res) ~= "string" or res == "" then
    log_error(bWriteLog and "[cw][camera] camera location can not be nil")
    return nil
  end
  return _StrToList(res)
end
function lobby_camera_manager_module:GetLobbyCameraRotationByCameraID(nCameraID)
  log(bWriteLog and "[tinghaohu][camera] lobby_camera_manager_module:GetLobbyCameraRotationByCameraID(" .. tostring(nCameraID) .. ")")
  local info = self:GetLobbyCameraInfoByCameraID(nCameraID)
  if not info then
    return nil
  end
  local res = info.CameraRotation
  if not res or type(res) ~= "string" or res == "" then
    log_error(bWriteLog and "[tinghaohu][camera] camera rotation can not be nil")
    return nil
  end
  return _StrToList(res)
end
function lobby_camera_manager_module:GetLobbyLevelSequenceInfoBySeqID(nSeqId)
  log(bWriteLog and "[cw][camera] lobby_camera_manager_module:GetLobbyLevelSequenceInfoBySeqID(" .. tostring(nSeqId) .. ") ")
  if nSeqId == nil then
    log_error(bWriteLog and "[cw][camera] GetLobbyLevelSequenceInfoBySeqID nSeqId is nil")
    return nil
  end
  return _GetCsvValueByTabAndKey("LobbyLevelSequence", nSeqId)
end
function lobby_camera_manager_module:GetLobbyCameraEnlargeLenCfgByID(nId)
  log(bWriteLog and "[cw][camera] lobby_camera_manager_module:GetLobbyCameraEnlargeLenCfgByID(" .. tostring(nId) .. ") ")
  if nId == nil then
    log_error(bWriteLog and "[cw][camera] GetLobbyCameraEnlargeLenCfgByID nId is nil")
    return nil
  end
  return _GetCsvValueByTabAndKey("EnlargeLensCameraCfg", nId)
end
function lobby_camera_manager_module:GetLobbyCameraAnimCfgByKey(nCameraID)
  if nCameraID == nil then
    log_error(bWriteLog and "[cw][camera] GetLobbyCameraAnimCfgByKey nCameraID is nil")
    return nil
  end
  local HallThemeUtils = require("client.logic.lobby.hall_theme_utils")
  local key = tostring(nCameraID) .. "_" .. HallThemeUtils.homeThemeItemId
  log(bWriteLog and "[cw][camera] lobby_camera_manager_module.GetLobbyCameraAnimCfgByKey(" .. tostring(nCameraID) .. ") key = " .. tostring(key))
  return _GetCsvValueByTabAndKey("LobbyCameraAnim", key)
end
function lobby_camera_manager_module:SwitchCamera_Only(nNewCameraID, nBlendTime)
  log(bWriteLog and "[cw][camera] lobby_camera_manager_module:SwitchCamera_Only(" .. tostring(nNewCameraID) .. ", " .. tostring(nBlendTime) .. ")")
  if not nNewCameraID then
    log_error(bWriteLog and "[cw][camera] nNewCameraID cannot be nil ")
    return
  end
  if selfRef._cameraLock then
    log_warning(bWriteLog and "[cw][camera] _cameraLock is on, " .. tostring(nNewCameraID) .. " is stored in _cameraLockCache")
    selfRef._cameraLockCache = nNewCameraID
    return
  end
  local time_util = require("client.common.time_util")
  self.lastSwitchCameraTime = time_util.GetMiliseconds()
  if nNewCameraID and self:_ChangeCamera_ByID(nNewCameraID, nBlendTime or 0.5) then
    selfRef.currentCameraID = nNewCameraID
    selfRef.bSwitchedByCfg = false
    EventSystem:postEvent(EVENTTYPE_CAMERA, EVENTID_REAL_CAMERA_SWITCHED, nNewCameraID)
  end
end
function lobby_camera_manager_module:SwitchCamera_Only_CustomCfg(cfg)
  log(bWriteLog and "[cw][camera] lobby_camera_manager_module:SwitchCamera_Only_CustomCfg")
  if not cfg or type(cfg) ~= "table" then
    log_error(bWriteLog and "[cw][camera] cfg is illegal")
    return
  end
  log_tree("[cw][camera] cfg:", cfg)
  if self:_ChangeCamera_ByConfig(cfg) and cfg.cameraID then
    selfRef.currentCameraID = tonumber(cfg.cameraID)
    selfRef.bSwitchedByCfg = true
  end
end
function lobby_camera_manager_module:SwitchCamera(nCameraID, nBlendTime, bIgnoreLightLevel)
  log(bWriteLog and "[cw][camera] lobby_camera_manager_module:SwitchCamera(" .. tostring(nCameraID) .. ", " .. tostring(nBlendTime) .. ")")
  if not nCameraID then
    log_error(bWriteLog and "[cw][camera] nCameraID cannot be nil ")
    return
  end
  local oldCameraID = selfRef.currentCameraID
  _BeforeSwitchCamera(oldCameraID, nCameraID)
  local blendTime = _HandleBlendTime(nCameraID, nBlendTime, 0)
  if selfRef._cameraLock then
    log_warning(bWriteLog and "[cw][camera] _cameraLock is on, " .. tostring(nCameraID) .. " is stored in _cameraLockCache")
    selfRef._cameraLockCache = nCameraID
  else
    local cameraChangeResult = self:_ChangeCamera_ByID(nCameraID, blendTime)
    if not cameraChangeResult then
      _OnSwitchCameraFailed(oldCameraID, nCameraID)
    else
      selfRef.bSwitchedByCfg = false
    end
  end
  _AfterSwitchCamera(oldCameraID, nCameraID, bIgnoreLightLevel)
end
function lobby_camera_manager_module:SwitchCamera_CustomLight(nCameraID, sLightLevel, nBlendTime)
  log(bWriteLog and "[cw][camera] lobby_camera_manager_module:SwitchCamera_CustomLight(" .. tostring(nCameraID) .. ", " .. tostring(sLightLevel) .. ", nBlendTime)")
  selfRef._nextLightLevelName = sLightLevel
  self:SwitchCamera(nCameraID, nBlendTime)
end
function lobby_camera_manager_module:LoadLightLevelByCameraID(nCameraID)
  log(bWriteLog and "[cw][camera] lobby_camera_manager_module:LoadLightLevelByCameraID(" .. tostring(nCameraID) .. ")")
  if nCameraID == nil then
    log_error(bWriteLog and "[cw][camera] nCameraID can not be nil")
    return
  end
  nCameraID = tonumber(nCameraID)
  self:SetCurrentCameraID(nCameraID)
  if _LoadLightLevelByCameraID(nCameraID) then
    _PlayCameraAnimation(nCameraID)
    EventSystem:postEvent(EVENTTYPE_CAMERA, EVENTID_CAMERA_SWITCHED, nCameraID)
  end
end
function lobby_camera_manager_module:GetLightLevelNameByCameraID(nCameraID)
  return _GetLightLevelNameByCameraID(nCameraID)
end
function lobby_camera_manager_module:GetLightLevelNameByLobbySkinID(nSkinID)
  local SkinCfg = CDataTable.GetTableData("LobbySceneSkinTable", nSkinID)
  if SkinCfg and SkinCfg.LightLevel then
    return SkinCfg.LightLevel
  else
    return ""
  end
end
function lobby_camera_manager_module:IsMidLobbyCameraID(nCameraID)
  if nCameraID == self.Enum_CameraID.Lobby_Default or nCameraID == self.Enum_CameraID.Lobby_Team or nCameraID == 10160 then
    return true
  else
    return false
  end
end
function lobby_camera_manager_module:LockCameraSwitch()
  log(bWriteLog and "[cw][camera] lobby_camera_manager_module:LockCameraSwitch() ")
  selfRef._cameraLock = true
  selfRef._cameraLockCache = nil
end
function lobby_camera_manager_module:UnlockCameraSwitch()
  log(bWriteLog and "[cw][camera] lobby_camera_manager_module:UnlockCameraSwitch()")
  selfRef._cameraLock = false
  if selfRef._cameraLockCache then
    self:SwitchCamera_Only(selfRef._cameraLockCache, 0)
    selfRef._cameraLockCache = nil
  end
end
function lobby_camera_manager_module:GetSAA()
  if slua.isValid(self.SAActor) then
    return self.SAActor
  end
  local World = slua_GameFrontendHUD:GetWorld()
  local PlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(World) or not slua.isValid(PlayerController) then
    return nil
  end
  local showActorClass = import("/Game/Arts_PlayerBluePrints/Common/BP_LobbyScreenAppearanceActor.BP_LobbyScreenAppearanceActor_C")
  local SAActor = World:SpawnActor(showActorClass, FVector(0, 0, 0), FRotator(0, 0, 0), nil)
  if slua.isValid(SAActor) and slua.isValid(PlayerController.PlayerCameraManager) then
    self.    self.SAActor:SetOwner(PlayerController.PlayerCameraManager)
    return self.SAActor
  end
  return nil
end
function lobby_camera_manager_module:LevelSequence_SetCallbacks(onSequenceBeginPlayFunc, onSequenceEndPlayFunc)
  log(bWriteLog and "[cw][camera] lobby_camera_manager_module:LevelSequence_SetCallbacks(" .. tostring(onSequenceBeginPlayFunc) .. ", " .. tostring(onSequenceEndPlayFunc) .. ")")
  selfRef._  selfRef._end
function lobby_camera_manager_module:LevelSequence_Play(nSeqID, bNeedFreezeLastFrame)
  log(bWriteLog and "[cw][camera] lobby_camera_manager_module:LevelSequence_Play(" .. tostring(nSeqID) .. ", " .. tostring(bNeedFreezeLastFrame) .. ")")
  if nSeqID == 0 then
    return
  end
  local info = self:GetLobbyLevelSequenceInfoBySeqID(nSeqID)
  if info == nil then
    return
  end
  local path = info.BluePrintPath
  self:LevelSequence_PlayByPath(path, bNeedFreezeLastFrame)
end
function lobby_camera_manager_module:LevelSequence_PlayByPath(path, bNeedFreezeLastFrame)
  if selfRef._currentSeqPlayer then
    selfRef._currentSeqPlayer:Stop()
  end
  local seqAsset = _MakeAndGetAnAssertByPath(path)
  local LevelSequencePlayer_C = import("LevelSequencePlayer")
  local FMovieSceneSequencePlaybackSettings = import("MovieSceneSequencePlaybackSettings")
  local MovieSceneSequencePlaybackSettings = FMovieSceneSequencePlaybackSettings()
  local seqPlayer, seqActor = LevelSequencePlayer_C.CreateLevelSequencePlayer(UIUtil.GetGameInstance(), seqAsset, MovieSceneSequencePlaybackSettings)
  if seqActor == nil or seqPlayer == nil then
    return
  end
  selfRef._currentSeqPlayer = seqPlayer
  selfRef._currentSeqActor = seqActor
  seqPlayer.FreezeEndFrame = bNeedFreezeLastFrame or false
  self:AddControlEvent(seqPlayer, "OnTrackEvent", self._LevelSequence_OnTrackEvent, self)
  self:AddControlEvent(seqPlayer, "OnPlay", self._LevelSequence_OnPlay, self)
  self:AddControlEvent(seqPlayer, "OnStop", self._LevelSequence_OnStop, self)
  seqPlayer:Play()
  return seqPlayer
end
function lobby_camera_manager_module:LevelSequence_Stop()
  log(bWriteLog and "[cw][camera] lobby_camera_manager_module:LevelSequence_Stop()")
  local seqPlayer = selfRef._currentSeqPlayer
  if slua.isValid(seqPlayer) then
    seqPlayer:Stop()
  end
end
function lobby_camera_manager_module:LevelSequence_Pause()
  log(bWriteLog and "[cw][camera] lobby_camera_manager_module:LevelSequence_Pause()")
  local seqPlayer = selfRef._currentSeqPlayer
  if slua.isValid(seqPlayer) then
    seqPlayer:Pause()
  end
end
function lobby_camera_manager_module:LevelSequence_JumpToPosition(newPosition)
  log(bWriteLog and "[cw][camera] lobby_camera_manager_module:LevelSequence_JumpToPosition(" .. tostring(newPosition) .. ")")
  local seqPlayer = selfRef._currentSeqPlayer
  if slua.isValid(seqPlayer) then
    seqPlayer:JumpToPosition(newPosition)
  end
end
function lobby_camera_manager_module:_LevelSequence_OnPlay()
  log(bWriteLog and "[cw][camera] lobby_camera_manager_module:_LevelSequence_OnPlay()")
  local Actor = _GetSequenceCameraActor()
  if not Actor then
    return
  end
  local PlayController = slua_GameFrontendHUD:GetPlayerController()
  if not PlayController then
    log_error(bWriteLog and "[cw][camera] PlayController is nil")
    return
  end
  local EViewTargetBlendFunction = import("EViewTargetBlendFunction")
  PlayController:SetViewTargetWithBlend(Actor, 0, EViewTargetBlendFunction.VTBlend_Linear, 0, false)
  log(bWriteLog and "[cw][camera] _ExecuteCallback(lobby_camera_manager_module._onSequenceBeginPlayFunc)")
  _ExecuteCallback(lobby_camera_manager_module.Enum_SequenceCallbackHandler.onSequenceBeginPlayFunc)
end
function lobby_camera_manager_module:_LevelSequence_OnTrackEvent(first, second, third, fourth, fifth)
  log(bWriteLog and "[cw][camera] lobby_camera_manager_module:_LevelSequence_OnTrackEvent(first: " .. tostring(first) .. ", second: " .. tostring(second) .. ", third: " .. tostring(third) .. ", fourth: " .. tostring(fourth) .. ", fifth: " .. tostring(fifth))
  if tostring(first) == "FADEOUT" or tostring(second) == "FADEOUT" or tostring(third) == "FADEOUT" or tostring(fourth) == "FADEOUT" or tostring(fifth) == "FADEOUT" then
    if UIManager.IsUIShow(UIManager.UI_Config.lobby_sequence_mask) then
      UIManager.CloseUI(UIManager.UI_Config.lobby_sequence_mask)
    end
    UIManager.ShowUI(UIManager.UI_Config.lobby_sequence_mask)
  end
end
function lobby_camera_manager_module:_ExecuteLevelSequenceBeginCallback()
  log(bWriteLog and "[cw][camera] _ExecuteLevelSequenceBeginCallback()")
  _ExecuteCallback(lobby_camera_manager_module.Enum_SequenceCallbackHandler.onSequenceBeginPlayFunc)
end
function lobby_camera_manager_module:_ExecuteLevelSequenceEndCallback()
  log(bWriteLog and "[cw][camera] _ExecuteLevelSequenceEndCallback()")
  _ExecuteCallback(lobby_camera_manager_module.Enum_SequenceCallbackHandler.onSequenceEndPlayFunc)
end
function lobby_camera_manager_module:_LevelSequence_OnStop()
  log(bWriteLog and "[cw][camera] lobby_camera_manager_module:_LevelSequence_OnStop()")
  if UIManager.IsUIShow(UIManager.UI_Config.lobby_sequence_mask) then
    UIManager.CloseUI(UIManager.UI_Config.lobby_sequence_mask)
  end
  _ReleaseSequencePlayer()
  _DestroySequenceActor()
  _ChangeToLobbyCamera()
  self:UnRegistEvents()
  log(bWriteLog and "[cw][camera] _ExecuteCallback(lobby_camera_manager_module:_onSequenceEndPlayFunc)")
  _ExecuteCallback(lobby_camera_manager_module.Enum_SequenceCallbackHandler.onSequenceEndPlayFunc)
end
function lobby_camera_manager_module:ResetLobbyCamera()
  log(bWriteLog and "[cw][camera] lobby_camera_manager_module:ResetLobbyCamera()")
  _ChangeToLobbyCamera()
end
function lobby_camera_manager_module:GetZoomInLobbyCameraCfg(nItemType, nCameraId)
  if not nItemType or not nCameraId then
    return
  end
  local ratio = _GetCurrentCameraRatio()
  local id = tostring(nItemType) .. "_" .. tostring(ratio) .. "_" .. tostring(nCameraId)
  local enlargeLensCfg = self:GetLobbyCameraEnlargeLenCfgByID(id)
  return enlargeLensCfg
end
function lobby_camera_manager_module:ZoomInLobbyCamera(aFocusTarget, nItemType, nCameraId, nBlendTime, ExtraLocation)
  log(bWriteLog and "[cw][camera] lobby_camera_manager_module:ZoomInLobbyCamera(" .. tostring(aFocusTarget) .. ", " .. tostring(nItemType) .. ", " .. tostring(nCameraId) .. ", " .. tostring(nBlendTime) .. ")")
  if not aFocusTarget then
    return
  end
  if not nItemType then
    return
  end
  ExtraLocation = ExtraLocation or {}
  ExtraLocation.x = ExtraLocation.x or 0
  ExtraLocation.y = ExtraLocation.y or 0
  ExtraLocation.z = ExtraLocation.z or 0
  nItemType = tonumber(nItemType)
  if not nCameraId then
    return
  end
  nCameraId = tonumber(nCameraId)
  local store_camera_manager = require("client.slua.logic.store.store_camera_manager")
  nBlendTime = nBlendTime and tonumber(nBlendTime) or store_camera_manager.SHOW_ENLARGE_LENS_BLENDTIME
  local ratio = _GetCurrentCameraRatio()
  local id = tostring(nItemType) .. "_" .. tostring(ratio) .. "_" .. tostring(nCameraId)
  local enlargeLensCfg = self:GetLobbyCameraEnlargeLenCfgByID(id)
  if enlargeLensCfg == nil then
    return
  end
  local config = self:GetLobbyCameraInfoByCameraID(nCameraId)
  if config == nil then
    return
  end
  local locationCfg = self:GetLobbyCameraLocationByCameraID(nCameraId)
  if locationCfg == nil then
    return
  end
  local rotationCfg = self:GetLobbyCameraRotationByCameraID(nCameraId)
  if rotationCfg == nil then
    return
  end
  local finalFOV = enlargeLensCfg.fov
  if not finalFOV or finalFOV == "" then
    finalFOV = tonumber(config.FieldOfView)
  end
  if nItemType ~= ENUM_ITEM_SUBTYPE.MileStoneAction then
    local AvatarComp = aFocusTarget:GetModelAvatarComp()
    if AvatarComp and AvatarComp.GetSpecialIdlePartOffset then
      local SpecialIdlePartOffset = AvatarComp:GetSpecialIdlePartOffset(nItemType)
      if SpecialIdlePartOffset then
        log(bWriteLog and string.format("lobby_camera_manager_module:ZoomInLobbyCamera, GetSpecialIdlePartOffset: (%s, %s, %s)", SpecialIdlePartOffset.X, SpecialIdlePartOffset.Y, SpecialIdlePartOffset.Z))
        ExtraLocation.x = ExtraLocation.x + SpecialIdlePartOffset.X
        ExtraLocation.y = ExtraLocation.y + SpecialIdlePartOffset.Y
        ExtraLocation.z = ExtraLocation.z + SpecialIdlePartOffset.Z
      end
    end
  end
  local locationY = enlargeLensCfg.relateY + locationCfg[2] + ExtraLocation.y
  local locationZ = enlargeLensCfg.relateZ + locationCfg[3] + ExtraLocation.z
  self:SwitchCamera_Only_CustomCfg({
    cameraID = nCameraId,
    location = FVector(enlargeLensCfg.relateX + locationCfg[1] + ExtraLocation.x, locationY, locationZ),
    rotation = FRotator((enlargeLensCfg.relateRotateY or 0) + (rotationCfg[2] or 0), (enlargeLensCfg.relateRotateZ or 0) + (rotationCfg[3] or 0), (enlargeLensCfg.relateRotateX or 0) + (rotationCfg[1] or 0)),
    scale = config.CameraScale,
    fov = finalFOV,
    blendTime = nBlendTime / 1000
  })
  local full_preview_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.full_preview_module)
  full_preview_module:OnCameraChanged(locationY, locationZ, finalFOV)
  full_preview_module:ChangeYRange()
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  LobbyAvatarManager.SetZRotationByStepForEnlarge(aFocusTarget, nBlendTime, nItemType == ENUM_ITEM_SUBTYPE.Backpack or nItemType == ENUM_ITEM_SUBTYPE.Backpack_Pendant_Skin)
end
function lobby_camera_manager_module:ZoomOutLobbyCamera(aFocusTarget, nCameraId, nBlendTime)
  log(bWriteLog and "[cw][camera] lobby_camera_manager_module:ZoomOutLobbyCamera(" .. tostring(aFocusTarget) .. ", " .. tostring(nCameraId) .. ", " .. tostring(nBlendTime) .. ")")
  local store_camera_manager = require("client.slua.logic.store.store_camera_manager")
  nBlendTime = nCameraId and tonumber(nBlendTime) or store_camera_manager.SHOW_ENLARGE_LENS_BLENDTIME
  self:SwitchCamera_Only(nCameraId, nBlendTime / 1000)
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  LobbyAvatarManager.SetZRotationByStepForEnlarge(aFocusTarget, nBlendTime, false)
end
function lobby_camera_manager_module:GetCenterVehicleCameraID()
  local e = lobby_camera_manager_module.Enum_CameraID
  return _GetDataBaseOnCurrentRatio(e.Vehicle_Center_Long, e.Vehicle_Center_Rect, e.Vehicle_Center_Normal)
end
function lobby_camera_manager_module:GetStoreVehicleCameraId()
  local e = lobby_camera_manager_module.Enum_CameraID
  return _GetDataBaseOnCurrentRatio(e.vehicle_screen_long, e.vehicle_screen_rect, e.vehicle_screen_normal)
end
function lobby_camera_manager_module:GetStoreVehicleTopViewCameraId()
  local e = lobby_camera_manager_module.Enum_CameraID
  return _GetDataBaseOnCurrentRatio(e.vehicle_topView_screen_long, e.vehicle_topView_screen_rect, e.vehicle_topView_screen_normal)
end
function lobby_camera_manager_module:GetCenterVehicleTopViewCameraID()
  local e = lobby_camera_manager_module.Enum_CameraID
  return _GetDataBaseOnCurrentRatio(e.Vehicle_Center_TopView_Long, e.Vehicle_Center_TopView_Rect, e.Vehicle_Center_TopView_Normal)
end
function lobby_camera_manager_module:GetCenterSuperCarVehicleCameraID()
  return lobby_camera_manager_module.Enum_CameraID.SuperCar_2000
end
function lobby_camera_manager_module:GetCenterSuperCarVehicleTopViewCameraID()
  local e = lobby_camera_manager_module.Enum_CameraID
  return _GetDataBaseOnCurrentRatio(e.Vehicle_Center_SuperCar_TopView_Long, e.Vehicle_Center_SuperCar_TopView_Rect, e.Vehicle_Center_SuperCar_TopView_Normal)
end
function lobby_camera_manager_module:RegisterSceneComp(tComp)
  selfRef._currentSceneComp = tComp
end
function lobby_camera_manager_module:UnRegisterSceneComp(tComp)
  if selfRef._currentSceneComp and tComp and selfRef._currentSceneComp.Identifier == tComp.Identifier then
    selfRef._currentSceneComp = nil
  end
end
function lobby_camera_manager_module:ResetCameraMoveInfo(fov)
  allMoveY = 0
  curFov = fov
  log(bWriteLog and "lobby_camera_manager_module:ResetCameraMoveInfo. fov: " .. tostring(fov))
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local lLobby_camera_manager_module = class(CModuleBase, nil, lobby_camera_manager_module)
return lLobby_camera_manager_module