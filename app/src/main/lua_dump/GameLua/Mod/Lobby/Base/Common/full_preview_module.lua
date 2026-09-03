local full_preview_module = {}
local isDev = Client and Client.IsDevelopment()
local moveCameraSpeed = 0.1
local maxZ = 0
local minZ = 0
local maxY, minY = 0, 0
local curZ, curY
local zoomSpeed = 400
function full_preview_module:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_ACTION_PLAY_START, self.OnPlayEmote, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_ACTION_PALY_END, self.OnEndEmote, self)
  self.bWeapon = false
end
function full_preview_module:GmShowOrClose()
  if not isDev then
    return
  end
  if UIManager.GetUI(UIManager.UI_Config.GM_Full_Preview_BP) then
    UIManager.CloseUI(UIManager.UI_Config.GM_Full_Preview_BP)
  else
    UIManager.ShowUI(UIManager.UI_Config.GM_Full_Preview_BP)
  end
end
function full_preview_module:GmSwitchCamera(id, fov)
  if not isDev then
    return
  end
  local ui = UIManager.GetUI(UIManager.UI_Config.GM_Full_Preview_BP)
  if ui then
    ui:GmSwitchCamera(id, fov)
  end
end
function full_preview_module:GmRefreshCameraInfo()
  if not isDev then
    return
  end
  local ui = UIManager.GetUI(UIManager.UI_Config.GM_Full_Preview_BP)
  if not ui then
    return
  end
  local frontendUtils = slua_GameFrontendHUD:GetUtils()
  local camera = frontendUtils:GetSceneCamera()
  if camera then
    local position = camera:K2_GetActorLocation()
    ui:GmSetPos(position)
  end
end
function full_preview_module:GmMoveCameraCenter()
  if not isDev then
    return
  end
  self:MoveCameraCenter()
end
function full_preview_module:GmZoomCamera(change)
  local curMove = change * zoomSpeed
  local frontendUtils = slua_GameFrontendHUD:GetUtils()
  local camera = frontendUtils:GetSceneCamera()
  if slua.isValid(camera) then
    camera:K2_AddActorWorldOffset(FVector(0, curMove, 0), false, nil, false)
  end
end
function full_preview_module:OnPlayEmote()
  self.isPlaying = true
end
function full_preview_module:OnEndEmote()
  self.isPlaying = false
end
function full_preview_module:IsWeaponShow()
  if UIManager.IsUIShow(UIManager.UI_Config.Common_FullScreenView_Weapon_UIBP) then
    return true
  end
  return false
end
local NotMoveCameraTb = {
  [10184] = true
}
function full_preview_module:ToFullScreenCamera(avatarData)
  if self.isPlaying then
    log(bWriteLog and "full_preview_module:ToFullScreenCamera.  isPlaying")
    ShowNotice(87081)
    return false
  end
  local cameraId = self.cameraId
  if cameraId and NotMoveCameraTb[cameraId] then
    log(bWriteLog and "full_preview_module:ToFullScreenCamera. cameraId: " .. tostring(cameraId))
    ShowNotice(87081)
    return false
  end
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  local previewAvatar = ModelDisplayer._showingAvatar
  if not previewAvatar then
    log(bWriteLog and "full_preview_module:ToFullScreenCamera.  not previewAvatar")
    ShowNotice(87081)
    return false
  end
  local avatar = previewAvatar:GetModel()
  if not slua.isValid(avatar) then
    log(bWriteLog and "full_preview_module:ToFullScreenCamera.  not avatar")
    ShowNotice(87081)
    return false
  end
  if avatarData.bCheckEquip == false then
    return true
  end
  self:AddTimerOnce(0, function()
    if avatarData.bWeapon ~= nil then
      self:MoveCameraCenterByWeapon(avatarData.bWeapon)
    elseif avatarData.bPet ~= nil then
      self:MoveCameraCenterByPet(avatarData.bPet)
    else
      self:MoveCameraCenter()
    end
  end)
  return true
end
function full_preview_module:MoveCameraCenter()
  self.bWeapon = false
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  local previewAvatar = ModelDisplayer._showingAvatar
  if not previewAvatar then
    log(bWriteLog and "full_preview_module:MoveCameraCenter.  not previewAvatar")
    return
  end
  local avatar = previewAvatar:GetModel()
  local frontendUtils = slua_GameFrontendHUD:GetUtils()
  local camera = frontendUtils:GetSceneCamera()
  local aPos = avatar:K2_GetActorLocation()
  local cameraPos = camera:K2_GetActorLocation()
  local location = FVector(aPos.X, cameraPos.Y, cameraPos.Z)
  self:OnCameraChanged(location.Y, location.Z, self.fov)
  local curZ = minZ + (maxZ - minZ) * 0.8
  log(bWriteLog and "full_preview_module:MoveCameraCenter. maxZ: " .. tostring(curZ))
  location = FVector(aPos.X, cameraPos.Y, curZ)
  self:SwitchSceneCameraToTransform(location)
end
function full_preview_module:ResetCamera()
  if not self.trans then
    return
  end
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  Lobby_camera_manager_module:SwitchSceneCameraToTransform(self.trans, 0, self.centerFov, 0.4, false, false)
  local nextPos = self.trans:GetLocation()
  self:OnCameraChanged(nextPos.Y, nextPos.Z, self.centerFov)
end
function full_preview_module:SetCameraBack()
  self.trans = nil
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  local previewAvatar = ModelDisplayer._showingAvatar
  if previewAvatar then
    previewAvatar:StopAction(nil, true)
  end
  if self.cameraId then
    self:AddTimerOnce(0.02, function()
      local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
      Lobby_camera_manager_module:SwitchCamera_Only(self.cameraId)
    end)
  end
end
local local local moveYMaxHead = 220
local moveZMaxNear = 78
local moveZMaxFar = 52
local shopFov = 40
local cameraZoomRange = 322
function full_preview_module:MoveCameraUpDown(z)
  if self.isPlaying then
    log(bWriteLog and "full_preview_module:MoveCameraUpDown.  isPlaying")
    return
  end
  local frontendUtils = slua_GameFrontendHUD:GetUtils()
  local camera = frontendUtils:GetSceneCamera()
  if not slua.isValid(camera) then
    return
  end
  local curMoveZ = z * moveCameraSpeed
  if curZ then
    local lastZ = curZ
    curZ = curZ + curMoveZ
    if curZ > maxZ then
      curZ = maxZ
    elseif curZ < minZ then
      curZ = minZ
    end
    curMoveZ = curZ - lastZ
    if curMoveZ < 0.1 and -0.1 < curMoveZ then
      log(bWriteLog and "full_preview_module:MoveCameraUpDown.  can't move" .. tostring(curZ))
      return
    end
  end
  log(bWriteLog and "full_preview_module:MoveCameraUpDown. curMoveZ: " .. tostring(curMoveZ))
  camera:K2_AddActorWorldOffset(FVector(0, 0, curMoveZ), false, nil, false)
end
local zoomed
function full_preview_module:ZoomCamera(y)
  if self.isPlaying then
    log(bWriteLog and "full_preview_module:ZoomCamera.  isPlaying")
    return
  end
  local frontendUtils = slua_GameFrontendHUD:GetUtils()
  local camera = frontendUtils:GetSceneCamera()
  if not slua.isValid(camera) then
    return
  end
  local curMoveY = y * zoomSpeed
  local lastY = curY
  curY = curY + curMoveY
  if curY > maxY then
    curY = maxY
  elseif curY < minY then
    curY = minY
  end
  curMoveY = curY - lastY
  if curMoveY < 0.1 and -0.1 < curMoveY then
    log(bWriteLog and "full_preview_module:ZoomCamera.  can't move")
    return
  end
  self:OnCameraChanged(curY)
  self:MoveCameraUpDown(0)
  log(bWriteLog and "full_preview_module:ZoomCamera. curMoveY: " .. tostring(curMoveY))
  camera:K2_AddActorWorldOffset(FVector(0, curMoveY, 0), false, nil, false)
  if not zoomed then
    local Common_FullScreenView_UIBP = UIManager.GetUI(UIManager.UI_Config.Common_FullScreenView_UIBP)
    if Common_FullScreenView_UIBP then
      zoomed = true
      Common_FullScreenView_UIBP:HideGuide()
    end
  end
end
function full_preview_module:SwitchCamera(cameraId, fov)
  self.  self.fov = tonumber(fov)
  self:GmSwitchCamera(cameraId, fov)
  local frontendUtils = slua_GameFrontendHUD:GetUtils()
  local camera = frontendUtils:GetSceneCamera()
  if not camera then
    return
  end
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  local StartPos, _, _ = Lobby_camera_manager_module:GetTransformInfoByCameraID(self.cameraId)
  log(bWriteLog and "full_preview_module:SwitchCamera. StartPos.Z: " .. tostring(StartPos.Z) .. ", Y:" .. tostring(StartPos.Y))
  if not StartPos then
    return
  end
  self.  curY = StartPos.Y
  curZ = StartPos.Z
  self:ChangeYRange()
  self:OnCameraChanged(curY, curZ)
  moveCameraSpeed = 0.1
  zoomSpeed = 1
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if Client.GetDevicePlatformName() == DevicePlatformNameMacros.Windows then
    zoomSpeed = 400
  end
end
local ZoomRangeTb = {
  [85] = 100,
  [25] = 50,
  [70] = 160,
  [35] = 140
}
local headFov = 25
function full_preview_module:OnCameraChanged(nextPosY, nextPosZ, nextFov)
  if not nextPosY then
    local frontendUtils = slua_GameFrontendHUD:GetUtils()
    local camera = frontendUtils:GetSceneCamera()
    if not camera then
      return
    end
    nextPosY = camera:K2_GetActorLocation().Y
  end
  if nextPosZ then
    curZ = nextPosZ
  end
  if nextFov then
    self.fov = tonumber(nextFov)
  end
  curY = nextPosY
  local StartPos = self.StartPos
  if not StartPos then
    return
  end
  log(bWriteLog and "full_preview_module:OnCameraChanged. curY: " .. tostring(curY))
  log(bWriteLog and "full_preview_module:OnCameraChanged. StartPos.Y: " .. tostring(StartPos.Y))
  log(bWriteLog and "full_preview_module:OnCameraChanged. StartPos.Z: " .. tostring(StartPos.Z))
  local k = 1
  if self.fov < shopFov then
    k = math.tan(math.rad(shopFov * 0.5)) / math.tan(math.rad(self.fov * 0.5)) * 1.2
  end
  local t = FuncUtil.Clamp((nextPosY - StartPos.Y + moveYMaxHead) / moveYMaxHead, 0, 1)
  log(bWriteLog and "full_preview_module:OnCameraChanged. t: " .. tostring(t))
  local ZLimit = moveZMaxNear - (moveZMaxNear - moveZMaxFar) * t
  if self.bWeapon then
    k = k * 0.3
  end
  log(bWriteLog and "full_preview_module:OnCameraChanged. k: " .. tostring(k))
  ZLimit = ZLimit * k
  log(bWriteLog and "full_preview_module:OnCameraChanged. ZLimit: " .. tostring(ZLimit))
  maxZ = StartPos.Z + ZLimit
  if self.bWeapon then
    maxZ = StartPos.Z + ZLimit * 0.4
    minZ = StartPos.Z - ZLimit * 0.5
  else
    minZ = StartPos.Z - ZLimit * 0.65
    if ZoomRangeTb[self.fov] then
      minZ = StartPos.Z - ZLimit * 0.55
    end
  end
  log(bWriteLog and "full_preview_module:OnCameraChanged. minZ: " .. tostring(minZ))
  log(bWriteLog and "full_preview_module:OnCameraChanged. maxZ: " .. tostring(maxZ))
end
function full_preview_module:ChangeYRange()
  local StartPos = self.StartPos
  local k = cameraZoomRange
  local specialK = ZoomRangeTb[self.fov]
  if specialK then
    k = specialK
  end
  if self.bWeapon then
    k = k * 0.7
  end
  maxY = StartPos.Y
  if self.fov == headFov then
    maxY = StartPos.Y + k * 4
  end
  minY = StartPos.Y - k
  if maxY < minY then
    maxY, minY = minY, maxY
  end
  log(bWriteLog and "full_preview_module:ChangeYRange. maxY: " .. tostring(maxY))
  log(bWriteLog and "full_preview_module:ChangeYRange. minY: " .. tostring(minY))
  log(bWriteLog and "full_preview_module:ChangeYRange. curY: " .. tostring(curY))
  if self.bWeapon then
    local WeaponModelLogic = require("client.slua.logic.manager.WeaponModelLogic")
    local weapon = WeaponModelLogic.GetProperWeaponShowActor()
    if weapon then
      local WeaponY = weapon:K2_GetActorLocation().Y
      local nextMinY = WeaponY + (maxY - minY) * 0.3
      if nextMinY > minY then
        minY = nextMinY
        log(bWriteLog and "full_preview_module:ChangeYRange. minY later: " .. tostring(minY))
      end
    end
  end
end
function full_preview_module:SwitchSceneCameraToTransform(location)
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  local _location, rotator, scale = Lobby_camera_manager_module:GetTransformInfoByCameraID(self.cameraId)
  local UKismetMathLibrary = import("KismetMathLibrary")
  self.trans = UKismetMathLibrary.MakeTransform(location or _location, rotator, scale)
  self.centerFov = self.fov
  Lobby_camera_manager_module:SwitchSceneCameraToTransform(self.trans, 0, self.fov, 0.4, false, false)
  local nextPos = self.trans:GetLocation()
  self:ChangeYRange()
  self:OnCameraChanged(nextPos.Y, nextPos.Z, self.centerFov)
end
function full_preview_module:MoveCameraCenterByWeapon(bWeapon)
  self.bWeapon = true
  local WeaponModelLogic = require("client.slua.logic.manager.WeaponModelLogic")
  local avatar = WeaponModelLogic.GetProperWeaponShowActor()
  if not bWeapon then
    self.bWeapon = false
    self:MoveCameraCenter()
    return
  end
  if not avatar then
    log(bWriteLog and "full_preview_module:MoveCameraCenterByWeapon. avatar is nil bWeapon: " .. tostring(bWeapon))
    return
  end
  local frontendUtils = slua_GameFrontendHUD:GetUtils()
  local camera = frontendUtils:GetSceneCamera()
  local aPos = avatar:K2_GetActorLocation()
  local cameraPos = camera:K2_GetActorLocation()
  local location = FVector(aPos.X, cameraPos.Y, cameraPos.Z)
  self:SwitchSceneCameraToTransform(location)
end
function full_preview_module:SetCameraBackByWeapon()
  self:SwitchSceneCameraToTransform(nil)
end
function full_preview_module:MoveCameraCenterByPet(bPet)
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  local previewAvatar = ModelDisplayer.GetPetModel()
  if not bPet then
    previewAvatar = ModelDisplayer.GetShowingAvatar()
  end
  local avatar = previewAvatar:GetModel()
  if not avatar then
    return
  end
  local frontendUtils = slua_GameFrontendHUD:GetUtils()
  local camera = frontendUtils:GetSceneCamera()
  local aPos = avatar:K2_GetActorLocation()
  local cameraPos = camera:K2_GetActorLocation()
  local location = FVector(aPos.X, cameraPos.Y, cameraPos.Z)
  self:SwitchSceneCameraToTransform(location)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local lfull_preview_module = class(CModuleBase, nil, full_preview_module)
return lfull_preview_module