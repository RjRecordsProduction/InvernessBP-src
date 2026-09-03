local store_camera_manager = {SHOW_ENLARGE_LENS_BLENDTIME = 500}
local SHOW_MALL_FULLSCREEN_SPEED = 500
local DATA_DEFAULY_X_OFFSET = 6
local DATE_FOV_ENLARGE_RATE = 0.857
local GetMallFullScreenID = function(itemID, adapt, cameraID)
  local WeaponModelMgrHelper = require("client.slua.logic.manager.WeaponModelSubLogic.WeaponModelMgrHelper")
  local OriginID = WeaponModelMgrHelper.GetRealResIdEnhance(itemID, true)
  if OriginID then
    return OriginID .. "_" .. adapt .. "_" .. cameraID
  end
  log_error(bWriteLog and "cfg is nil, id is = " .. itemID)
  return itemID .. "_" .. adapt .. "_" .. cameraID
end
function store_camera_manager.ShowMallFullScreen(itemID, cameraID, speed)
  speed = speed or SHOW_MALL_FULLSCREEN_SPEED
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  local adapt = Lobby_camera_manager_module:GetCurrentCameraRatio()
  local id = GetMallFullScreenID(itemID, adapt, cameraID)
  local data = CDataTable.GetTableData("MALL_CAMERA_FULL_SCREEN_CONFIG", id)
  if data == nil then
    local reuseCameraID = 10114
    local config = CDataTable.GetTableData("AdaptDataReuse", cameraID)
    if config ~= nil then
      reuseCameraID = config.ReuseCameraID
    end
    local reuseID = GetMallFullScreenID(itemID, adapt, reuseCameraID)
    data = CDataTable.GetTableData("MALL_CAMERA_FULL_SCREEN_CONFIG", reuseID)
  end
  if data == nil then
    log(bWriteLog and "store_camera_manager.MALL_CAMERA_FULL_SCREEN_CONFIG " .. id .. " is nil")
    return
  end
  local info = Lobby_camera_manager_module:GetLobbyCameraInfoByCameraID(cameraID)
  local loc = Lobby_camera_manager_module:GetLobbyCameraLocationByCameraID(cameraID)
  local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
  local weaponActor = MallSystemWeaponModelHandler.GetProperWeaponShowActor()
  if not weaponActor or not slua.isValid(weaponActor) then
    return
  end
  local aPos = weaponActor:K2_GetActorLocation()
  local NeedFastMove = false
  local PlayController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(PlayController) then
    local ViewTarget = PlayController:GetViewTarget()
    local ViewLoc = ViewTarget:K2_GetActorLocation()
    local CameraDist = FVector.DistXY(ViewLoc, aPos) * 0.01
    if 50 < CameraDist then
      log(bWriteLog and "ShowMallFullScreen Too Far")
      NeedFastMove = true
    end
  end
  local curbledTime = speed / 1000
  if NeedFastMove then
    curbledTime = 0
  end
  Lobby_camera_manager_module:SwitchCamera_Only_CustomCfg({
    location = tostring(aPos.X and aPos.X + DATA_DEFAULY_X_OFFSET or data.relateX + loc[1]) .. ";" .. tostring(data.relateY + loc[2]) .. ";" .. tostring(data.relateZ + loc[3]),
    rotation = info.CameraRotation,
    scale = info.CameraScale,
    fov = info.FieldOfView * DATE_FOV_ENLARGE_RATE,
    blendTime = curbledTime
  })
end
return store_camera_manager