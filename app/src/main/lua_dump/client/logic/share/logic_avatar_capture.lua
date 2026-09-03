local showClassList = {
  [1] = "/Game/Arts_PlayerBluePrints/Character_Show/BP_PlayerLobbyPawn.BP_PlayerLobbyPawn_C",
  [2] = "/Game/Arts_PlayerBluePrints/Weapon_Show/BP_LobbyWeapon.BP_LobbyWeapon_C"
}
local minLimit = -10
local maxLimit = 50
local FilterDevice = {}
local Avatar_Capture_SYSTEM = {bufferTexture = nil}
function Avatar_Capture_SYSTEM.OnModePostSwitch(preState, nextState)
  log(bWriteLog and "Avatar_Capture_SYSTEM.OnModePostSwitch " .. tostring(nextState))
  Avatar_Capture_SYSTEM.bufferTexture = nil
end
local GetAvatarPathByUID = function()
  local uid = tostring(DataMgr.roleData.uid)
  local fileName = "Avatar/" .. uid .. "/avatar.png"
  local path = Client.ProjectSavedDir() .. fileName
  return fileName, path
end
local GetTeamAvatarPathByUID = function()
  local uid = tostring(DataMgr.roleData.uid)
  local fileName = "Avatar/" .. uid .. "/teamAvatar.png"
  local path = Client.ProjectSavedDir() .. fileName
  return fileName, path
end
function Avatar_Capture_SYSTEM.CaptureAllAvatar()
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local myAvatar = TeamAvatarManager.GetMainAvatar()
  if myAvatar == nil then
    log(bWriteLog and "[Avatar_Capture_SYSTEM] CaptureAvatar with nil main avatar")
    return
  end
  local avatar = myAvatar:GetModel()
  if avatar == nil then
    log(bWriteLog and "[Avatar_Capture_SYSTEM] CaptureAvatar with nil avatar")
    return
  end
  local oldRotation = avatar:K2_GetActorRotation()
  avatar:K2_SetActorRotation(FRotator(0, 0, 0), false)
  local _, path = GetTeamAvatarPathByUID()
  Client.DeleteFile(path)
  Avatar_Capture_SYSTEM.InitCaptureActor(avatar, true)
  log(bWriteLog and "CaptureAllAvatar1 TextureTarget.SizeX = " .. tostring(Avatar_Capture_SYSTEM.avatarCaptureActor.SceneCaptureComponent2D.TextureTarget.SizeX))
  log(bWriteLog and "CaptureAllAvatar1 TextureTarget.SizeY = " .. tostring(Avatar_Capture_SYSTEM.avatarCaptureActor.SceneCaptureComponent2D.TextureTarget.SizeY))
  Avatar_Capture_SYSTEM.SetShowActorLists()
  if _G.IsEditor then
    Avatar_Capture_SYSTEM.avatarCaptureActor.SceneCaptureComponent2D.TextureTarget.TargetGamma = 2.2
  end
  log(bWriteLog and "CaptureAllAvatar2 TextureTarget.SizeX = " .. tostring(Avatar_Capture_SYSTEM.avatarCaptureActor.SceneCaptureComponent2D.TextureTarget.SizeX))
  log(bWriteLog and "CaptureAllAvatar2 TextureTarget.SizeY = " .. tostring(Avatar_Capture_SYSTEM.avatarCaptureActor.SceneCaptureComponent2D.TextureTarget.SizeY))
  Avatar_Capture_SYSTEM.avatarCaptureActor.SceneCaptureComponent2D:CaptureScene()
  log(bWriteLog and "CaptureAllAvatar3 TextureTarget.SizeX = " .. tostring(Avatar_Capture_SYSTEM.avatarCaptureActor.SceneCaptureComponent2D.TextureTarget.SizeX))
  log(bWriteLog and "CaptureAllAvatar3 TextureTarget.SizeY = " .. tostring(Avatar_Capture_SYSTEM.avatarCaptureActor.SceneCaptureComponent2D.TextureTarget.SizeY))
  local USTExtraUIUtils = import("STExtraUIUtils")
  USTExtraUIUtils.CaptureRT_FileHelper(Avatar_Capture_SYSTEM.avatarCaptureActor.SceneCaptureComponent2D.TextureTarget, path, FLinearColor(0, 0, 0, 0), false)
  Avatar_Capture_SYSTEM.Destroy()
  avatar:K2_SetActorRotation(oldRotation, false)
end
function Avatar_Capture_SYSTEM.GetTeamAvatarPngPath()
  local _, path = GetTeamAvatarPathByUID()
  return path
end
function Avatar_Capture_SYSTEM.CaptureAvatar()
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local avatarNum = TeamAvatarManager.GetAvatarCount()
  if 1 < avatarNum then
    log(bWriteLog and "[Avatar_Capture_SYSTEM] Player is teaming up")
    return
  end
  local myAvatar = TeamAvatarManager.GetMainAvatar()
  if myAvatar == nil then
    log(bWriteLog and "[Avatar_Capture_SYSTEM] CaptureAvatar with nil main avatar")
    return
  end
  local avatar = myAvatar:GetModel()
  if avatar == nil then
    log(bWriteLog and "[Avatar_Capture_SYSTEM] CaptureAvatar with nil avatar")
    return
  end
  local bValid = Avatar_Capture_SYSTEM.CheckActorAngle(avatar)
  if not bValid then
    return
  end
  local _, path = GetAvatarPathByUID()
  Client.DeleteFile(path)
  Avatar_Capture_SYSTEM.InitCaptureActor(avatar)
  log(bWriteLog and "CaptureAvatar1 TextureTarget.SizeX = " .. tostring(Avatar_Capture_SYSTEM.avatarCaptureActor.SceneCaptureComponent2D.TextureTarget.SizeX))
  log(bWriteLog and "CaptureAvatar1 TextureTarget.SizeY = " .. tostring(Avatar_Capture_SYSTEM.avatarCaptureActor.SceneCaptureComponent2D.TextureTarget.SizeY))
  Avatar_Capture_SYSTEM.SetShowActorLists()
  if _G.IsEditor then
    Avatar_Capture_SYSTEM.avatarCaptureActor.SceneCaptureComponent2D.TextureTarget.TargetGamma = 2.2
  end
  log(bWriteLog and "CaptureAvatar2 TextureTarget.SizeX = " .. tostring(Avatar_Capture_SYSTEM.avatarCaptureActor.SceneCaptureComponent2D.TextureTarget.SizeX))
  log(bWriteLog and "CaptureAvatar2 TextureTarget.SizeY = " .. tostring(Avatar_Capture_SYSTEM.avatarCaptureActor.SceneCaptureComponent2D.TextureTarget.SizeY))
  Avatar_Capture_SYSTEM.avatarCaptureActor.SceneCaptureComponent2D:CaptureScene()
  log(bWriteLog and "CaptureAvatar3 TextureTarget.SizeX = " .. tostring(Avatar_Capture_SYSTEM.avatarCaptureActor.SceneCaptureComponent2D.TextureTarget.SizeX))
  log(bWriteLog and "CaptureAvatar3 TextureTarget.SizeY = " .. tostring(Avatar_Capture_SYSTEM.avatarCaptureActor.SceneCaptureComponent2D.TextureTarget.SizeY))
  local USTExtraUIUtils = import("STExtraUIUtils")
  USTExtraUIUtils.CaptureRT_FileHelper(Avatar_Capture_SYSTEM.avatarCaptureActor.SceneCaptureComponent2D.TextureTarget, path, FLinearColor(0, 0, 0, 0), false)
  Avatar_Capture_SYSTEM.Destroy()
end
function Avatar_Capture_SYSTEM.CheckActorAngle(avatar)
  local yawRot = avatar:K2_GetActorRotation().Yaw
  if yawRot > minLimit and yawRot < maxLimit then
    log(bWriteLog and "[Avatar_Capture_SYSTEM] the avatar's yaw angle is great:" .. tostring(yawRot))
    return true
  end
  log(bWriteLog and "[Avatar_Capture_SYSTEM] the avatar's yaw angle too large:" .. tostring(yawRot))
  return false
end
function Avatar_Capture_SYSTEM.InitCaptureActor(avatar, isTeam)
  local world = slua_GameFrontendHUD:GetWorld()
  local class = import("/Game/Arts_PlayerBluePrints/Capture/AvatarCaptureActor_BP.AvatarCaptureActor_BP_C")
  local location
  if isTeam then
    location = Avatar_Capture_SYSTEM.GetSpwanLocationByTeam(avatar)
  else
    location = Avatar_Capture_SYSTEM.GetSpwanLocation(avatar)
  end
  Avatar_Capture_SYSTEM.avatarCaptureActor = world:SpawnActor(class, location, nil, nil)
  local rotation = FRotator(0, 0, 0)
  rotation.Yaw = -90 + avatar:K2_GetActorRotation().Yaw
  Avatar_Capture_SYSTEM.avatarCaptureActor:K2_SetActorRotation(rotation, false)
end
function Avatar_Capture_SYSTEM.SetShowActorLists()
  Avatar_Capture_SYSTEM.avatarCaptureActor.SceneCaptureComponent2D.ShowOnlyActors:Clear()
  local UGameplayStatics = import("GameplayStatics")
  local uActor = import("/Script/Engine.Actor")
  local UIUtil = require("client.common.ui_util")
  local uGameInstance = UIUtil.GetGameInstance()
  for _, uClassPath in pairs(showClassList) do
    local uClass = import(uClassPath)
    local uActorArray = UGameplayStatics.GetAllActorsOfClass(uGameInstance, uClass, slua.Array(UEnums.EPropertyClass.Object, uActor))
    for k, v in pairs(uActorArray) do
      Avatar_Capture_SYSTEM.avatarCaptureActor.SceneCaptureComponent2D.ShowOnlyActors:Add(v)
    end
  end
end
function Avatar_Capture_SYSTEM.GetSpwanLocationByTeam(avatar)
  local result = FVector(0, 0, 0)
  if slua.isValid(avatar) then
    local biasVector = {
      x = 0,
      y = 390,
      z = 0
    }
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    local teamNum = TeamUpNewSystem.GetTeamNum()
    if teamNum == 4 then
      biasVector.x = 94.5
    elseif 1 < teamNum then
      biasVector.x = 63.0
    end
    local avatarLocation = avatar:K2_GetActorLocation()
    result.X = avatarLocation.X + biasVector.x
    result.Y = avatarLocation.Y + biasVector.y
    result.Z = avatarLocation.Z + biasVector.z
    local KismetMathLibrary = import("KismetMathLibrary")
    result = KismetMathLibrary.GreaterGreater_VectorRotator(result - avatarLocation, avatar:K2_GetActorRotation()) + avatar:K2_GetActorLocation()
  end
  return result
end
function Avatar_Capture_SYSTEM.GetSpwanLocation(avatar)
  local result = FVector(0, 0, 0)
  if slua.isValid(avatar) then
    local biasVector = {
      x = 0,
      y = 190,
      z = 0
    }
    local avatarLocation = avatar:K2_GetActorLocation()
    result.X = avatarLocation.X + biasVector.x
    result.Y = avatarLocation.Y + biasVector.y
    result.Z = avatarLocation.Z + biasVector.z
    local KismetMathLibrary = import("KismetMathLibrary")
    result = KismetMathLibrary.GreaterGreater_VectorRotator(result - avatarLocation, avatar:K2_GetActorRotation()) + avatar:K2_GetActorLocation()
    result.Z = result.Z + 40
  end
  return result
end
function Avatar_Capture_SYSTEM.InFilterDevice(profileName)
  local result = false
  for k, v in pairs(FilterDevice) do
    if string.lower(v) == string.lower(profileName) then
      result = true
      break
    end
  end
  log(bWriteLog and "Avatar_Capture_SYSTEM.InFilterDevice, profileName = " .. tostring(profileName) .. ", result = " .. tostring(result))
  return result
end
function Avatar_Capture_SYSTEM.Destroy()
  if Avatar_Capture_SYSTEM.avatarCaptureActor then
    Avatar_Capture_SYSTEM.avatarCaptureActor:K2_DestroyActor()
    Avatar_Capture_SYSTEM.avatarCaptureActor = nil
  end
end
function Avatar_Capture_SYSTEM._GetAvatarTexture()
  if Avatar_Capture_SYSTEM.bufferTexture then
    return Avatar_Capture_SYSTEM.bufferTexture
  end
  local fileName, path = GetAvatarPathByUID()
  if Client.FullPathFileExist(path) then
    local LoadTexture = import("LoadTexture")
    if _G.IsEditor then
      log(bWriteLog and "path = " .. path)
      Avatar_Capture_SYSTEM.bufferTexture = LoadTexture.GetTexture2DFromDiskFile(path)
      return Avatar_Capture_SYSTEM.bufferTexture
    else
      local BusinessHelper = import("BusinessHelper")
      log(bWriteLog and "path = " .. BusinessHelper.GetMobileBasePath("ShadowTrackerExtra/Saved/" .. fileName))
      Avatar_Capture_SYSTEM.bufferTexture = LoadTexture.GetTexture2DFromDiskFile(BusinessHelper.GetMobileBasePath("ShadowTrackerExtra/Saved/" .. fileName))
      return Avatar_Capture_SYSTEM.bufferTexture
    end
  end
  return nil
end
function Avatar_Capture_SYSTEM.GetAvatarTexture()
  local texture = Avatar_Capture_SYSTEM._GetAvatarTexture()
  if not texture then
    local maleDefault = "/Game/Arts/UI/NoAtlas/Share/Battle_Show_MVP_BG06.Battle_Show_MVP_BG06"
    local femaleDefault = "/Game/Arts/UI/NoAtlas/Share/Battle_Show_MVP_BG07.Battle_Show_MVP_BG07"
    local asset_util = require("common.asset_util")
    texture = asset_util.GetAssetSync(DataMgr.roleData.gender == 1 and maleDefault or femaleDefault)
  end
  return texture
end
return Avatar_Capture_SYSTEM