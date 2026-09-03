local logic_avatar_capture_system = {
  bufferTexture = setmetatable({}, {__mode = "v"}),
  roleInfoPoseIds = nil
}
local USTExtraUIUtils = import("STExtraUIUtils")
local gunID = 101001
local showPosition = {
  x = -700,
  y = 0,
  z = 89.5
}
local poseIds = {
  50018001,
  50018002,
  50018003,
  50018004
}
local showClassList = {
  [1] = {
    "/Game/Arts_PlayerBluePrints/Character_Show/BP_PlayerLobbyPawn.BP_PlayerLobbyPawn_C",
    "/Game/Arts_PlayerBluePrints/Weapon_Show/BP_LobbyWeapon.BP_LobbyWeapon_C"
  },
  [2] = {
    "/Game/Arts_PlayerBluePrints/Character_Show/BP_PlayerLobbyPawn.BP_PlayerLobbyPawn_C",
    "/Game/Arts_PlayerBluePrints/Weapon_Show/BP_LobbyWeapon.BP_LobbyWeapon_C",
    "/Game/Arts_PlayerBluePrints/Vehicle_Show/BP_LobbyVehicle.BP_LobbyVehicle_C",
    "/Game/Arts_PlayerBluePrints/Common/NewLobbyModelShowActorBP.NewLobbyModelShowActorBP_C",
    "/Game/Arts_PlayerBluePrints/Pet/BP_LobbyPetBase.BP_LobbyPetBase_C"
  }
}
local poseIdsToConfig = {
  [50018001] = {
    cameraPos = FVector(-5.67, 209.046, 29.951),
    cameraFov = 33.134
  },
  [50018002] = {
    cameraPos = FVector(1.744, 162.051, -0.354),
    cameraFov = 42.947
  },
  [50018003] = {
    cameraPos = FVector(0, 188.731, 50.821),
    cameraFov = 29.653
  },
  [50018004] = {
    cameraPos = FVector(6.736, 172.841, 3.809),
    cameraFov = 41.267
  },
  [66810001] = {
    cameraPos = FVector(-5.67, 209.046, 29.951),
    cameraFov = 33.134
  },
  [66810002] = {
    cameraPos = FVector(1.744, 162.051, -0.354),
    cameraFov = 42.947
  }
}
local roleInfoDefaultCameraPos = FVector(0, 188.731, 50.821)
local roleInfoDefaultCameraFov = 29.653
local GetAvatarDireByUID = function()
  local uid = tostring(DataMgr.roleData.uid)
  local dire = Client.ProjectSavedDir() .. "Avatar/" .. uid
  return dire
end
local GetAvatarPathByUID = function(poseId)
  local uid = tostring(DataMgr.roleData.uid)
  local fileName = "Avatar/" .. uid .. "/" .. tostring(poseId) .. ".png"
  local path = Client.ProjectSavedDir() .. fileName
  return fileName, path
end
local GetCardDireByUID = function()
  local uid = tostring(DataMgr.roleData.uid)
  local dire = Client.ProjectSavedDir() .. "Card/" .. uid
  return dire
end
local GetCardPathByUID = function()
  local uid = tostring(DataMgr.roleData.uid)
  local fileName = "Card/" .. uid .. "/" .. "share" .. ".png"
  local path = Client.ProjectSavedDir() .. fileName
  return fileName, path
end
function logic_avatar_capture_system:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_ACTION_PALY_END, self.OnEndActionHandle, self)
end
function logic_avatar_capture_system:OnPreSwitchGameStatus(_, next)
  if next == GameStatus.Fighting then
    log(bWriteLog and "logic_avatar_capture_system:OnPreSwitchGameStatus clear data")
    self:Destroy()
  end
end
function logic_avatar_capture_system:CaptureAvatar(avatar)
  log(bWriteLog and "[sjt] logic_avatar_capture_system:CaptureAvatar")
  if avatar == nil then
    log(bWriteLog and "logic_avatar_capture_system.CaptureAvatar avatar is nil")
    EventSystem:postEvent(EVENTTYPE_CAPTURE_AVATAR, EVENTID_CAPTURE_FINISH)
    return
  end
  local avatarPawn = avatar:GetModel()
  local avatarCaptureActor = self:SpawnCaptureActor(avatarPawn)
  if not slua.isValid(avatarCaptureActor) then
    log(bWriteLog and "logic_avatar_capture_system.CaptureAvatar create CaptureActor failed")
    EventSystem:postEvent(EVENTTYPE_CAPTURE_AVATAR, EVENTID_CAPTURE_FINISH)
    return
  end
  avatarCaptureActor.SceneCaptureComponent2D.bCaptureEveryFrame = true
  self:SetShowActorLists(avatarCaptureActor, 2)
  local dire = GetCardDireByUID()
  Client.DeleteDirectory(dire)
  local cameraPos = FVector(0, 600, 0)
  local avatarPos = avatarPawn:K2_GetActorLocation()
  local resultPos = FVector(cameraPos.X + avatarPos.X, cameraPos.Y + avatarPos.Y, cameraPos.Z + avatarPos.Z)
  avatarCaptureActor:K2_SetActorLocation(resultPos, false, nil, false)
  local cameraFov = 20
  avatarCaptureActor.SceneCaptureComponent2D.FOVAngle = cameraFov
  if _G.IsEditor then
    avatarCaptureActor.SceneCaptureComponent2D.TextureTarget.TargetGamma = 2.2
  end
  local _, path = GetCardPathByUID()
  avatarPawn:K2_SetActorRotation(FRotator(0, 0, 0), false)
  local pet = avatar:GetPet()
  if pet then
    pet:AdjustAttachLocation("DEFAULT")
  end
  self:AddTimerOnce(0.5, function()
    if not slua.isValid(avatarPawn) then
      log(bWriteLog and "logic_avatar_capture_system.CaptureAvatar avatarPawn is invalid")
      return
    end
    if not slua.isValid(avatarCaptureActor) then
      log(bWriteLog and "logic_avatar_capture_system.CaptureAvatar avatarCaptureActor is failed")
      return
    end
    local bSuccess = USTExtraUIUtils.CaptureRT_FileHelper(avatarCaptureActor.SceneCaptureComponent2D.TextureTarget, path, FLinearColor(0, 0, 0, 0), true)
    log(bWriteLog and "logic_avatar_capture_system.CaptureAvatar bSuccess = " .. tostring(bSuccess))
    avatarCaptureActor:K2_DestroyActor()
    EventSystem:postEvent(EVENTTYPE_CAPTURE_AVATAR, EVENTID_CAPTURE_FINISH)
  end)
end
function logic_avatar_capture_system:GetCaptureAvatar()
  log(bWriteLog and "[sjt] logic_avatar_capture_system:GetCaptureAvatar")
  local fileName, path = GetCardPathByUID()
  if Client.FullPathFileExist(path) then
    local LoadTexture = import("LoadTexture")
    if _G.IsEditor then
      log(bWriteLog and "path = " .. path)
      return LoadTexture.GetTexture2DFromDiskFile(path)
    else
      local BusinessHelper = import("BusinessHelper")
      log(bWriteLog and "path = " .. BusinessHelper.GetMobileBasePath("ShadowTrackerExtra/Saved/" .. fileName))
      return LoadTexture.GetTexture2DFromDiskFile(BusinessHelper.GetMobileBasePath("ShadowTrackerExtra/Saved/" .. fileName))
    end
  else
    log(bWriteLog and "logic_avatar_capture_system:GetCaptureAvatar call GetAvatarTexture")
    return self:GetAvatarTexture()
  end
end
function logic_avatar_capture_system:CaptureAvatarWithHandsomePose(inputPoseIds)
  log(bWriteLog and "[sjt] logic_avatar_capture_system:CaptureAvatarWithHandsomePose")
  self.bufferTexture = {}
  self:Destroy()
  self._currentPoseIds = inputPoseIds or poseIds
  if not self._currentPoseIds or #self._currentPoseIds == 0 then
    log(bWriteLog and "logic_avatar_capture_system.CaptureAvatarWithHandsomePose no poseIds, skip")
    return
  end
  local MultipleAvatarManager = require("client.logic.avatar.MultipleAvatarManager")
  self._avatar = MultipleAvatarManager.CreateMyAvatar(showPosition)
  local avatarPawn = self._avatar:GetModel()
  if not slua.isValid(avatarPawn) then
    log(bWriteLog and "logic_avatar_capture_system.CaptureAvatarWithHandsomePose create avatar failed")
    return
  end
  avatarPawn:SetAvatarLevel(1)
  self:EquipWeapon()
  self.avatarCaptureActor = self:SpawnCaptureActor(avatarPawn)
  if not slua.isValid(self.avatarCaptureActor) then
    log(bWriteLog and "logic_avatar_capture_system.CaptureAvatarWithHandsomePose create CaptureActor failed")
    return
  end
  self.avatarCaptureActor.SceneCaptureComponent2D.bCaptureEveryFrame = true
  self:SetShowActorLists(self.avatarCaptureActor, 1)
  local dire = GetAvatarDireByUID()
  Client.DeleteDirectory(dire)
  self.currPoseIndex = 1
  self:SetCameraPosAndFov(self.currPoseIndex)
  local poseId = self._currentPoseIds[self.currPoseIndex]
  if poseId then
    log(bWriteLog and "[sjt] logic_avatar_capture_system start playAction with poseId = " .. tostring(poseId))
    self._avatar:PlayAction(poseId, nil, nil, {Nonblock = true, DisableModelDisplayerCallback = true})
  end
end
function logic_avatar_capture_system:EquipWeapon()
  log(bWriteLog and "[sjt] logic_avatar_capture_system:EquipWeapon")
  local logic_wardrobe_gun = require("client.slua.logic.wardrobe.logic_wardrobe_gun")
  local skinInsID = logic_wardrobe_gun:GetSkinIdByWeaponID(gunID)
  if skinInsID == 0 then
    log(bWriteLog and "[sjt] logic_avatar_capture_system skinInsID is 0")
    self:PutonEquipment(gunID, true)
  else
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local itemData = wardrobe_data:GetValidHallDepotItemDataByInsID(skinInsID)
    if itemData == nil then
      log(bWriteLog and "[sjt] logic_avatar_capture_system itemData is nil")
      self:PutonEquipment(gunID, true)
    elseif itemData.resID and itemData.resID ~= 0 then
      log(bWriteLog and "logic_avatar_capture_system:EquipWeapon itemData.resID = " .. tostring(itemData.resID))
      self:PutonEquipment(itemData.resID, true)
    else
      log(bWriteLog and "[sjt] logic_avatar_capture_system itemData.resID is invalid")
      self:PutonEquipment(gunID, true)
    end
  end
end
function logic_avatar_capture_system:PutonEquipment(itemID, isUse)
  log(bWriteLog and "[sjt] logic_avatar_capture_system:PutonEquipment")
  local avatarPawn = self._avatar:GetModel()
  if not slua.isValid(avatarPawn) then
    log(bWriteLog and "logic_avatar_capture_system.PutonEquipment avatar is invalid")
    return
  end
  if itemID == nil or itemID == 0 then
    log_error(bWriteLog and "Error: logic_avatar_capture_system PutonEquipment itemID is " .. tostring(itemID) .. " ,skip...")
    return
  end
  local FBI = require("client.slua.logic.fbi.logic_fbi")
  if FBI.IsIllegalTime(itemID) then
    avatarPawn:CharEquipWeaponByResId(gunID, isUse)
    avatarPawn:CharEquipWeaponPendant(gunID, 2)
    log_error(bWriteLog and "logic_avatar_capture_system:PutonEquipment IllegalTime " .. tostring(itemID))
    return
  end
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {itemID})
  log(bWriteLog and "[sjt] logic_avatar_capture_system state = " .. tostring(state))
  if state ~= ENUM_DownloadState.Done then
    avatarPawn:CharEquipWeaponByResId(gunID, isUse)
    avatarPawn:CharEquipWeaponPendant(gunID, 2)
  else
    avatarPawn:CharEquipWeaponByResId(itemID, isUse)
    avatarPawn:CharEquipWeaponPendant(itemID, 2)
  end
end
function logic_avatar_capture_system:SpawnCaptureActor(avatar)
  log(bWriteLog and "[sjt] logic_avatar_capture_system:SpawnCaptureActor")
  local world = slua_GameFrontendHUD:GetWorld()
  local loadClass = import("/Game/Arts_PlayerBluePrints/Capture/AvatarCaptureActor_BP.AvatarCaptureActor_BP_C")
  local avatarCaptureActor = world:SpawnActor(loadClass, avatar:K2_GetActorLocation(), nil, nil)
  local rotation = FRotator(0, -90, 0)
  avatarCaptureActor:K2_SetActorRotation(rotation, false)
  return avatarCaptureActor
end
function logic_avatar_capture_system:SetShowActorLists(captureActor, index)
  log(bWriteLog and "[sjt] logic_avatar_capture_system:SetShowActorLists")
  captureActor.SceneCaptureComponent2D.ShowOnlyActors:Clear()
  local UGameplayStatics = import("GameplayStatics")
  local uActor = import("/Script/Engine.Actor")
  local UIUtil = require("client.common.ui_util")
  local uGameInstance = UIUtil.GetGameInstance()
  for _, uClassPath in pairs(showClassList[index]) do
    local uClass = import(uClassPath)
    local uActorArray = UGameplayStatics.GetAllActorsOfClass(uGameInstance, uClass, slua.Array(UEnums.EPropertyClass.Object, uActor))
    for _, actor in pairs(uActorArray) do
      captureActor.SceneCaptureComponent2D.ShowOnlyActors:Add(actor)
    end
  end
end
function logic_avatar_capture_system:SetCameraPosAndFov(index)
  log(bWriteLog and "[sjt] logic_avatar_capture_system:SetCameraPosAndFov with index = " .. tostring(index))
  local currentPoseId = self._currentPoseIds[index]
  local config = poseIdsToConfig[currentPoseId]
  local cameraPos = config and config.cameraPos or roleInfoDefaultCameraPos
  local avatarPos = self._avatar:GetModel():K2_GetActorLocation()
  local resultPos = FVector(cameraPos.X + avatarPos.X, cameraPos.Y + avatarPos.Y, cameraPos.Z + avatarPos.Z)
  self.avatarCaptureActor:K2_SetActorLocation(resultPos, false, nil, false)
  local cameraFov = config and config.cameraFov or roleInfoDefaultCameraFov
  self.avatarCaptureActor.SceneCaptureComponent2D.FOVAngle = cameraFov
end
function logic_avatar_capture_system:Destroy()
  log(bWriteLog and "[sjt] logic_avatar_capture_system:Destroy")
  if self.avatarCaptureActor then
    if slua.isValid(self.avatarCaptureActor) then
      self.avatarCaptureActor:K2_DestroyActor()
    end
    self.avatarCaptureActor = nil
  end
  if self._avatar then
    self._avatar:PauseAnim(false)
    self._avatar:Destroy()
    self._avatar = nil
  end
  self._currentPoseIds = nil
end
function logic_avatar_capture_system:OnEndActionHandle(_, __, poseId)
  log(bWriteLog and "[sjt] logic_avatar_capture_system:OnEndActionHandle with poseId = " .. tostring(poseId))
  if not self:IsPoseIdValid(poseId) then
    log(bWriteLog and "logic_avatar_capture_system.OnEndActionHandle poseId is invalid")
    return
  end
  if not slua.isValid(self.avatarCaptureActor) then
    log(bWriteLog and "logic_avatar_capture_system.OnEndActionHandle avatarCaptureActor is invalid")
    return
  end
  if self._avatar == nil or not slua.isValid(self._avatar:GetModel()) then
    log(bWriteLog and "logic_avatar_capture_system.CaptureAvatarWithHandsomePose avatar is invalid")
    return
  end
  if _G.IsEditor then
    self.avatarCaptureActor.SceneCaptureComponent2D.TextureTarget.TargetGamma = 2.2
  end
  self._avatar:PauseAnim(true)
  self:AddTimerOnce(0, function()
    if not slua.isValid(self.avatarCaptureActor) then
      log(bWriteLog and "logic_avatar_capture_system.OnEndActionHandle timer avatarCaptureActor is invalid")
      return
    end
    if self._avatar == nil or not slua.isValid(self._avatar:GetModel()) then
      log(bWriteLog and "logic_avatar_capture_system.OnEndActionHandle timer avatar is invalid")
      return
    end
    local _, path = GetAvatarPathByUID(poseId)
    USTExtraUIUtils.CaptureRT_FileHelper(self.avatarCaptureActor.SceneCaptureComponent2D.TextureTarget, path, FLinearColor(0, 0, 0, 0), true)
    log(bWriteLog and "[sjt] logic_avatar_capture_system capture avatar and save png with poseId = " .. tostring(poseId))
    self.currPoseIndex = self.currPoseIndex + 1
    local nextPoseId = self._currentPoseIds[self.currPoseIndex]
    if nextPoseId then
      log(bWriteLog and "[sjt] logic_avatar_capture_system start play next action with poseId = " .. tostring(nextPoseId))
      self:SetCameraPosAndFov(self.currPoseIndex)
      self._avatar:PauseAnim(false)
      self._avatar:PlayAction(nextPoseId, nil, nil, {Nonblock = true, DisableModelDisplayerCallback = true})
    else
      log(bWriteLog and "[sjt] logic_avatar_capture_system stop capture avatar")
      self:Destroy()
    end
  end)
end
function logic_avatar_capture_system:IsPoseIdValid(currPoseId)
  log(bWriteLog and "[sjt] logic_avatar_capture_system:IsPoseIdValid")
  if currPoseId == nil then
    return false
  end
  local currentPoseIds = self._currentPoseIds or poseIds
  local isValid = false
  for _, poseId in pairs(currentPoseIds) do
    if poseId == currPoseId then
      isValid = true
      break
    end
  end
  return isValid
end
function logic_avatar_capture_system:_GetAvatarTexture(poseId)
  log(bWriteLog and "[sjt] logic_avatar_capture_system:_GetAvatarTexture with poseId = " .. tostring(poseId))
  if poseId == nil then
    log(bWriteLog and "logic_avatar_capture_system._GetAvatarTexture poseId is nil")
    return nil
  end
  if self.bufferTexture[poseId] then
    log(bWriteLog and "logic_avatar_capture_system._GetAvatarTexture get buffer")
    return self.bufferTexture[poseId]
  end
  local fileName, path = GetAvatarPathByUID(poseId)
  if Client.FullPathFileExist(path) then
    local LoadTexture = import("LoadTexture")
    if _G.IsEditor then
      log(bWriteLog and "path = " .. path)
      self.bufferTexture[poseId] = LoadTexture.GetTexture2DFromDiskFile(path)
      return self.bufferTexture[poseId]
    else
      local BusinessHelper = import("BusinessHelper")
      log(bWriteLog and "path = " .. BusinessHelper.GetMobileBasePath("ShadowTrackerExtra/Saved/" .. fileName))
      self.bufferTexture[poseId] = LoadTexture.GetTexture2DFromDiskFile(BusinessHelper.GetMobileBasePath("ShadowTrackerExtra/Saved/" .. fileName))
      return self.bufferTexture[poseId]
    end
  end
  return nil
end
function logic_avatar_capture_system:_CheckCaptureTextureExist(poseId)
  log(bWriteLog and "[sjt] logic_avatar_capture_system:_CheckCaptureTextureExist with poseId = " .. tostring(poseId))
  if poseId == nil then
    log(bWriteLog and "logic_avatar_capture_system._CheckCaptureTextureExist poseId is nil")
    return false
  end
  local _, path = GetAvatarPathByUID(poseId)
  return Client.FullPathFileExist(path)
end
function logic_avatar_capture_system:GetBasePoseIds()
  return {
    poseIds[1],
    poseIds[2],
    poseIds[3],
    poseIds[4]
  }
end
function logic_avatar_capture_system:GetRoleInfoPoseIds()
  if self.roleInfoPoseIds then
    log(bWriteLog and "[sjt] logic_avatar_capture_system:GetRoleInfoPoseIds use cached, count = " .. tostring(#self.roleInfoPoseIds))
    return self.roleInfoPoseIds
  end
  self.roleInfoPoseIds = {}
  local existSet = {}
  for _, id in ipairs(poseIds) do
    existSet[id] = true
  end
  local ok, tableData = pcall(function()
    return CDataTable and CDataTable.GetTable("RoleInfoShareBGTable")
  end)
  if ok and tableData then
    for _, cfg in pairs(tableData) do
      local bpID = cfg.AvatarposeBPID
      if bpID and bpID ~= 0 and not existSet[bpID] then
        existSet[bpID] = true
        table.insert(self.roleInfoPoseIds, bpID)
      end
    end
  end
  log(bWriteLog and "[sjt] logic_avatar_capture_system:GetRoleInfoPoseIds total count = " .. tostring(#self.roleInfoPoseIds))
  return self.roleInfoPoseIds
end
function logic_avatar_capture_system:MergePoseIds(list1, list2)
  local merged = {}
  local existSet = {}
  if list1 then
    for _, id in ipairs(list1) do
      if not existSet[id] then
        existSet[id] = true
        table.insert(merged, id)
      end
    end
  end
  if list2 then
    for _, id in ipairs(list2) do
      if not existSet[id] then
        existSet[id] = true
        table.insert(merged, id)
      end
    end
  end
  return merged
end
function logic_avatar_capture_system:GetAvatarTexture()
  log(bWriteLog and "[sjt] logic_avatar_capture_system:GetAvatarTexture")
  if LobbySystem.CheckOpen(BP_ENUM_LOBBY_AVATAR_CAPTURE_SWITCH) then
    local TimeUtil = require("client.common.time_util")
    local seed = tostring(TimeUtil.OSTime()):reverse():sub(1, 6)
    math.randomseed(seed)
    log(bWriteLog and "logic_avatar_capture_system.GetAvatarTexture seed = " .. tostring(seed))
    local randomNum = math.random(1, 4)
    log(bWriteLog and "logic_avatar_capture_system.GetAvatarTexture randomNum = " .. tostring(randomNum))
    local poseId = poseIds[randomNum]
    local texture = self:_GetAvatarTexture(poseId)
    if not texture then
      local asset_util = require("common.asset_util")
      local maleDefault = "/Game/Arts/UI/NoAtlas/Share/Battle_Show_MVP_BG06.Battle_Show_MVP_BG06"
      local femaleDefault = "/Game/Arts/UI/NoAtlas/Share/Battle_Show_MVP_BG07.Battle_Show_MVP_BG07"
      texture = asset_util.GetAssetSync(DataMgr.roleData.gender == 1 and maleDefault or femaleDefault)
      poseId = 0
    end
    return texture, poseId
  else
    local Avatar_Capture_Old_SYSTEM = require("client.logic.share.logic_avatar_capture")
    return Avatar_Capture_Old_SYSTEM.GetAvatarTexture()
  end
end
function logic_avatar_capture_system:GetSelectedAvatarTexture(poseId)
  log(bWriteLog and "[sjt] logic_avatar_capture_system:GetSelectedAvatarTexture, poseId = " .. tostring(poseId))
  local texture = self:_GetAvatarTexture(poseId)
  local isDefault = false
  if not texture then
    local asset_util = require("common.asset_util")
    local maleDefault = "/Game/Arts/UI/NoAtlas/Share/Battle_Show_MVP_BG06.Battle_Show_MVP_BG06"
    local femaleDefault = "/Game/Arts/UI/NoAtlas/Share/Battle_Show_MVP_BG07.Battle_Show_MVP_BG07"
    texture = asset_util.GetAssetSync(DataMgr.roleData.gender == 1 and maleDefault or femaleDefault)
    isDefault = true
  end
  return texture, isDefault
end
function logic_avatar_capture_system:GetDefaultAvatarTexture()
  log(bWriteLog and "logic_avatar_capture_system:GetDefaultAvatarTexture DataMgr.roleData.gender = " .. tostring(DataMgr.roleData.gender))
  local asset_util = require("common.asset_util")
  local maleDefault = "/Game/Arts/UI/NoAtlas/Share/Battle_Show_MVP_BG06.Battle_Show_MVP_BG06"
  local femaleDefault = "/Game/Arts/UI/NoAtlas/Share/Battle_Show_MVP_BG07.Battle_Show_MVP_BG07"
  local texture = asset_util.GetAssetSync(DataMgr.roleData.gender == 1 and maleDefault or femaleDefault)
  return texture
end
function logic_avatar_capture_system:GetAllCaptureTexture()
  local captureTextureList = {}
  for _, poseId in pairs(poseIds) do
    local texture = self:_GetAvatarTexture(poseId)
    if texture then
      table.insert(captureTextureList, {poseId = poseId, texture = texture})
    end
  end
  return captureTextureList
end
function logic_avatar_capture_system:GetAllCaptureTextureId()
  local captureTextureIdList = {}
  for _, poseId in pairs(poseIds) do
    local bExist = self:_CheckCaptureTextureExist(poseId)
    log(bWriteLog and "logic_avatar_capture_system:GetAllCaptureTextureId poseId = " .. tostring(poseId) .. " bExist = " .. tostring(bExist))
    if bExist then
      table.insert(captureTextureIdList, poseId)
    end
  end
  return captureTextureIdList
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, logic_avatar_capture_system)
return CModuleTemplate