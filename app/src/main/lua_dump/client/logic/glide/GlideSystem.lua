local GlideSystem = {}
function GlideSystem:DefineAndResetData()
  self.glideSetting = {}
  self.DefaultCameraSetting = {
    ArmLength = 450,
    CameraZLoc = -40,
    CameraRotation = FRotator(0, -135, 0)
  }
  self.CurSceneType = nil
  self.CameraActor = nil
  self.LastCamera = -1
  self.WindDirectionalSourceActors = {}
  self.CameraActorDefaultPos = FVector(58469.296875, -0.019531, 0.0)
end
function GlideSystem:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_CAMERA, EVENTID_CAMERA_SWITCHED, self.OnCameraChange, self)
end
function GlideSystem:OnLogin(bReLogin)
  log(bWriteLog and "GlideSystem:OnLogin")
  local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
  WardRobeHandler.send_get_xsuit_glide_req()
end
function GlideSystem:OnCameraChange(_, __, newCameraID)
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  if newCameraID ~= self.LastCamera and newCameraID ~= Lobby_camera_manager_module.Enum_CameraID.GlidePreview then
    print(bWriteLog and "GlideSystem:OnCameraChange self.LastCamera" .. tostring(self.LastCamera))
    self.LastCamera = newCameraID
  end
  self:UpdateWindSourceState(newCameraID)
end
function GlideSystem:UpdateGlideSetting(setting)
  log_tree("GlideSystem:OnXSuitGlideSettingRsq setting", setting)
  self.glideSetting = setting
end
function GlideSystem:UpdateGlideSettingData(ItemID, flag)
  self.glideSetting = self.glideSetting or {}
  self.glideSetting[ItemID] = flag
end
function GlideSystem:UseHighLevelGlideSetting(ItemID)
  if self.glideSetting and self.glideSetting[ItemID] == false then
    return false
  end
  return true
end
function GlideSystem:EnterGlideScene(SceneType, LobbyAvatar, bForceUpdate)
  log(bWriteLog and string.format("GlideSystem:EnterGlideScene LobbyAvatar:%s SceneType: %s bForceUpdate : %s", tostring(LobbyAvatar), SceneType, tostring(bForceUpdate)))
  if not LobbyAvatar then
    log(bWriteLog and "GlideSystem:EnterGlideScene not LobbyAvatar")
    return
  end
  self.Cur  if not bForceUpdate and LobbySceneManager.LEVEL_NAME.GLIDE_PREVIEW == LobbySceneManager.LatestScene and self.LobbyAvatar == LobbyAvatar then
    log(bWriteLog and "GlideSystem:IsSameGlide")
    return
  end
  local ConstAvatarDislay = require("client.slua.traits.DetailComponent.AvatarDisplay.ConstAvatarDislay")
  if SceneType == ConstAvatarDislay.ESceneType.RpPreview or SceneType == ConstAvatarDislay.ESceneType.AllStar then
    log(bWriteLog and "GlideSystem:EnterGlideScene Is " .. tostring(SceneType))
    return
  end
  self:SetCurrentAvatar(LobbyAvatar)
  if LobbyAvatar:HasEquipedGlide() then
    self:HandleGildeEquip(true, LobbyAvatar:GetEquipedGlideID(), bForceUpdate)
  end
end
function GlideSystem:SetCurrentAvatar(LobbyAvatar)
  if not LobbyAvatar or not LobbyAvatar:GetModel() then
    return
  end
  if self.LobbyAvatar and slua.isValid(self.LobbyAvatar:GetModel()) then
    self:RemoveControlEvent(self.LobbyAvatar:GetModel(), "OnAvatarComponentAllMeshLoaded")
  end
  self.  self:AddControlEvent(LobbyAvatar:GetModel(), "OnAvatarComponentAllMeshLoaded", self.OnAvatarEquipmentChange, self)
end
function GlideSystem:ExitGlideScene(TarSceneType)
  log(bWriteLog and "GlideSystem:ExitGlideScene")
  if TarSceneType and TarSceneType ~= self.CurSceneType then
    log(bWriteLog and "GlideSystem:ExitGlideScene TarSceneType  ~= self.CurSceneType")
    return
  end
  self:SetWindSourceEnabled(false)
  if slua.isValid(self.CameraActor) then
    self.CameraActor:K2_DestroyActor()
    local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
    if Lobby_camera_manager_module.currentCameraID == Lobby_camera_manager_module.Enum_CameraID.GlidePreview then
      Lobby_camera_manager_module:SwitchCamera(self.LastCamera)
    else
      Lobby_camera_manager_module:SwitchCamera(Lobby_camera_manager_module.currentCameraID)
    end
  end
  self.CameraActor = nil
  local LobbyModelPossess = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyModelPossess)
  LobbyModelPossess:UnPossess()
  self.CurSceneType = nil
  if self.LobbyAvatar and slua.isValid(self.LobbyAvatar:GetModel()) then
    self.LobbyAvatar:SetCanRotate(true)
    self:RemoveControlEvent(self.LobbyAvatar:GetModel(), "OnAvatarComponentAllMeshLoaded")
  end
  self.LobbyAvatar = nil
  self.WindDirectionalSourceActors = {}
  LobbySceneManager.LoadStreamLevel(false, LobbySceneManager.LEVEL_NAME.GLIDE_PREVIEW)
end
function GlideSystem:SwitchCameraToScene(bForceUpdate)
  log(bWriteLog and string.format("GlideSystem:SwitchCameraToScene bForceUpdate: %s", bForceUpdate))
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  local LoadingCameraID = LobbySceneManager.GetLoadingCameraID()
  if not bForceUpdate and Lobby_camera_manager_module:GetCurrentCameraID() == Lobby_camera_manager_module.Enum_CameraID.GlidePreview and (not LoadingCameraID or LoadingCameraID == Lobby_camera_manager_module.Enum_CameraID.GlidePreview) then
    return
  end
  LobbySceneManager.LoadStreamLevel(true, LobbySceneManager.LEVEL_NAME.GLIDE_PREVIEW, Lobby_camera_manager_module.Enum_CameraID.GlidePreview)
  local world = slua_GameFrontendHUD:GetWorld()
  if not slua.isValid(world) then
    return
  end
  local actorClass = slua.loadClass("/Game/Arts_PlayerBluePrints/Other/BP_Glide_Camera.BP_Glide_Camera")
  if not actorClass then
    log(bWriteLog and "[cw][scn] not actorClass ")
    return
  end
  if slua.isValid(self.CameraActor) then
    self.CameraActor:K2_DestroyActor()
  end
  self.CameraActor = world:SpawnActor(actorClass, self.CameraActorDefaultPos, FRotator(0, -90, 0), nil)
  if not slua.isValid(self.CameraActor) then
    log(bWriteLog and "GlideSystem:SwitchCameraToScene self.CameraActor is not Valid")
    return
  end
  local LobbyModelPossess = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyModelPossess)
  LobbyModelPossess:Possess(self.CameraActor)
  local ConstAvatarDislay = require("client.slua.traits.DetailComponent.AvatarDisplay.ConstAvatarDislay")
  if self.CurSceneType == ConstAvatarDislay.ESceneType.FashionBag then
    self.CameraActor:SetSpringArmCamOffset(0, -100, -40)
  elseif ConstAvatarDislay.IsCenterPreview(self.CurSceneType) then
    self.CameraActor:SetSpringArmCamOffset(0, 0, -40)
  else
    self.CameraActor:SetSpringArmCamOffset(0, 150, -40)
  end
  self:SetWindSourceEnabled(true)
end
function GlideSystem:AdjustSceneCamera(ItemID)
  log(bWriteLog and "GlideSystem:AdjustSceneCamera ItemID " .. tostring(ItemID))
  local AvatarUtil = require("GameLua.Mod.Library.GamePlay.Avatar.AvatarUtil")
  local GlideCameraSetting = AvatarUtil.GetGlideCameraSetting(ItemID)
  if not GlideCameraSetting then
    self:ResetDefaultCamera()
    return
  end
  if not slua.isValid(self.CameraActor) then
    log(bWriteLog and "GlideSystem:AdjustSceneCamera not slua.isValid(self.CameraActor)")
    return
  end
  if GlideCameraSetting.LobbyArmLength and GlideCameraSetting.LobbyArmLength ~= 0 then
    self.CameraActor:SetArmLength(GlideCameraSetting.LobbyArmLength)
  else
    self.CameraActor:SetArmLength(self.DefaultCameraSetting.ArmLength)
  end
  if GlideCameraSetting.CameraZLoc and GlideCameraSetting.CameraZLoc ~= 0 then
    self.CameraActor:SetCameraZLoc(GlideCameraSetting.CameraZLoc)
  else
    self.CameraActor:SetCameraZLoc(self.DefaultCameraSetting.CameraZLoc)
  end
  local StringUtil = require("common.string_util")
  local Rotation = StringUtil.StringToRotator(GlideCameraSetting.CameraRotation)
  if Rotation then
    self.CameraActor:ChangeCameraRotation(Rotation)
  else
    self.CameraActor:ChangeCameraRotation(self.DefaultCameraSetting.CameraRotation)
  end
  local CamLocOffset = GlideCameraSetting.CameraLocationOffset
  if CamLocOffset and CamLocOffset ~= "" then
    local OffsetVec = StringUtil.StringToVector(CamLocOffset, ";")
    self.CameraActor:K2_SetActorLocation(self.CameraActorDefaultPos + OffsetVec, false, nil, false)
  else
    self.CameraActor:K2_SetActorLocation(self.CameraActorDefaultPos, false, nil, false)
  end
end
function GlideSystem:OnAvatarEquipmentChange()
  log(bWriteLog and string.format("GlideSystem:OnAvatarEquipmentChange"))
  if not self.LobbyAvatar or not slua.isValid(self.LobbyAvatar:GetModel()) then
    log(bWriteLog and "GlideSystem:OnAvatarEquipmentChange not self.LobbyAvatar")
    return
  end
  local wardrobeShow = UIManager.GetUI(UIManager.UI_Config.wardrobe)
  if wardrobeShow then
    log(bWriteLog and string.format("GlideSystem:OnAvatarEquipmentChange wardrobeShow"))
    local WardrobeLogicManager = require("client.slua.logic.wardrobe.logic_wardrobe_new")
    local wardrobe_macro = require("client.slua.umg.Wardrobe.wardrobe_macro")
    if WardrobeLogicManager:GetWardrobeEditMode() == wardrobe_macro.EWardrobeEditMode.None then
      log(bWriteLog and string.format("GlideSystem:OnAvatarEquipmentChange wardrobeShow and WardrobeEditMode is None"))
      EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_EQUIPED_GLIDE_MESHLOADED_HANDLE)
      return
    end
  end
  local bHasEquipedGlide = self.LobbyAvatar:HasEquipedGlide()
  self:HandleGildeEquip(bHasEquipedGlide, self.LobbyAvatar:GetEquipedGlideID())
end
function GlideSystem:HandleGildeEquip(isEquipped, itemID, bForceUpdate)
  itemID = self:ConvertToBattleID(itemID)
  log(bWriteLog and "GlideSystem:HandleGildeEquip isEquipped" .. tostring(isEquipped) .. " itemID " .. tostring(itemID))
  if isEquipped then
    self:SwitchCameraToScene(bForceUpdate)
    self:AdjustSceneCamera(itemID)
  end
  if self.LobbyAvatar then
    self.LobbyAvatar:SetCanRotate(not isEquipped)
  end
end
function GlideSystem:ResetDefaultCamera()
  if not slua.isValid(self.CameraActor) then
    log(bWriteLog and "GlideSystem:ResetDefaultCamera not slua.isValid(self.CameraActor)")
    return
  end
  self.CameraActor:SetArmLength(self.DefaultCameraSetting.ArmLength)
  self.CameraActor:SetCameraZLoc(self.DefaultCameraSetting.CameraZLoc)
  self.CameraActor:ChangeCameraRotation(self.DefaultCameraSetting.CameraRotation)
  self.CameraActor:K2_SetActorLocation(self.CameraActorDefaultPos, false, nil, false)
end
function GlideSystem:ConvertToBattleID(LobbyGlideID)
  if LobbyGlideID == nil then
    return nil, false
  end
  local BackpackMapping = CDataTable.GetTableDataByFilter("BackpackMapping", "LobbyShowItemID", LobbyGlideID)
  if BackpackMapping ~= nil then
    return BackpackMapping.SkinID, true
  end
  return LobbyGlideID, false
end
function GlideSystem:ConvertToLobbyID(BattleGlideID)
  if BattleGlideID == nil then
    return nil
  end
  local BackpackMapping = CDataTable.GetTableDataByFilter("BackpackMapping", "SkinID", BattleGlideID)
  if BackpackMapping ~= nil then
    return BackpackMapping.LobbyShowItemID
  end
  return BattleGlideID
end
function GlideSystem:IsGlideBattleID(BattleGlideID)
  if BattleGlideID == nil then
    return false
  end
  local BackpackMapping = CDataTable.GetTableDataByFilter("BackpackMapping", "SkinID", BattleGlideID)
  if BackpackMapping ~= nil then
    return true
  else
    return false
  end
end
function GlideSystem:IsGlideLobbyID(LobbyGlideID)
  if LobbyGlideID == nil then
    return false
  end
  local BackpackMapping = CDataTable.GetTableDataByFilter("BackpackMapping", "LobbyShowItemID", LobbyGlideID)
  if BackpackMapping ~= nil then
    return true
  else
    return false
  end
end
function GlideSystem:GetWindDirectionalSources()
  if #self.WindDirectionalSourceActors > 0 then
    local bAllValid = true
    for _, Actor in ipairs(self.WindDirectionalSourceActors) do
      if not slua.isValid(Actor) then
        bAllValid = false
        break
      end
    end
    if bAllValid then
      return self.WindDirectionalSourceActors
    end
    self.WindDirectionalSourceActors = {}
  end
  local uLevel = LobbySceneManager.GetStreamLevel(LobbySceneManager.LEVEL_NAME.GLIDE_PREVIEW)
  if not slua.isValid(uLevel) then
    print(bWriteLog and "GlideSystem:GetWindDirectionalSources - GLIDE_PREVIEW level not loaded")
    return self.WindDirectionalSourceActors
  end
  local Actors = LobbySceneManager.GetActorsFromLevel(uLevel)
  if not Actors then
    print(bWriteLog and "GlideSystem:GetWindDirectionalSources - No actors in level")
    return self.WindDirectionalSourceActors
  end
  local AWindDirectionalSource = import("/Script/Engine.WindDirectionalSource")
  if not AWindDirectionalSource then
    print(bWriteLog and "GlideSystem:GetWindDirectionalSources - Failed to import AWindDirectionalSource class")
    return self.WindDirectionalSourceActors
  end
  for i = 0, Actors:Num() - 1 do
    local Actor = Actors:Get(i)
    if slua.isValid(Actor) and Game:IsClassOf(Actor, AWindDirectionalSource) then
      table.insert(self.WindDirectionalSourceActors, Actor)
    end
  end
  return self.WindDirectionalSourceActors
end
function GlideSystem:SetWindSourceEnabled(bEnabled)
  local WindActors = self:GetWindDirectionalSources()
  if #WindActors == 0 then
    print(bWriteLog and "GlideSystem:SetWindSourceEnabled - No wind sources found")
    return
  end
  print(bWriteLog and "GlideSystem:SetWindSourceEnabled - " .. tostring(bEnabled) .. " for " .. tostring(#WindActors) .. " wind source(s)")
  for _, WindActor in ipairs(WindActors) do
    if slua.isValid(WindActor) then
      local WindComponent = WindActor.Component
      if slua.isValid(WindComponent) then
        WindComponent:SetActive(bEnabled, false)
      end
    end
  end
end
function GlideSystem:UpdateWindSourceState(CameraID)
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  local bShouldEnable = CameraID == Lobby_camera_manager_module.Enum_CameraID.GlidePreview
  self:SetWindSourceEnabled(bShouldEnable)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CGlideSystem = class(CModuleBase, nil, GlideSystem)
return CGlideSystem