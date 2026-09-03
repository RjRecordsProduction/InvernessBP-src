local MultipleAvatar = {
  Const = {
    DefaultPawnCapsuleSize = {height = 88, radius = 34}
  }
}
function MultipleAvatar:ctor(_, _sex, _headId, avatarData, showPosition, itemIDList, hidePosition)
  log(bWriteLog and string.format("[LobbyAvatar][MultipleAvatar] MultipleAvatar:ctor(%s, %s, %s, %s)", avatarData, showPosition, itemIDList, hidePosition))
  local MultipleAvatarManager = require("client.logic.avatar.MultipleAvatarManager")
  itemIDList = itemIDList or {}
  self._isShowing = false
  local TableUtil = require("common.table_util")
  self._showPosition = showPosition or TableUtil.CopyTable(MultipleAvatarManager.Const.SHOW_POSITION)
  self._hidePosition = hidePosition or TableUtil.CopyTable(MultipleAvatarManager.Const.HIDE_POSITION)
  self._storedRotation = nil
  self._pet = nil
  self:UpdateLobbyCharacterPetState()
  self._curAvatarData = avatarData
  if avatarData.hairid and type(avatarData.hairid) == "number" and avatarData.hairid ~= 0 then
    self:PutonEquipment(avatarData.hairid)
  end
  if avatarData.beardid and avatarData.beardid ~= 0 and avatarData.beardcolorid then
    local tAvatarCustom = AvatarData.BeardTableToAvatarCustom(avatarData)
    self:PutonEquipment(avatarData.beardid, tAvatarCustom)
  end
  local nItemIdKey = ENUM_AVATAR_DATA_TYPE.ItemID
  if avatarData.attr_info and next(avatarData.attr_info) then
    for key, value in pairs(avatarData.attr_info) do
      local tAvatarCustom = AvatarData.ConvertToAvatarCustom(value)
      self:PutonEquipment(value[nItemIdKey], tAvatarCustom)
    end
  end
  for _, tAvatarCustom in ipairs(itemIDList) do
    self:PutonEquipment(tAvatarCustom.ItemID, tAvatarCustom)
  end
  self:ShowAvatar()
  if not avatarData.bDisableUpdatePos then
    self:UpdatePositionByCamera()
  end
end
function MultipleAvatar:Destroy()
  log(bWriteLog and "[LobbyAvatar][MultipleAvatar] MultipleAvatar:Destroy()")
  self:DestroyMiniTV()
  MultipleAvatar.__super.Destroy(self)
  local MultipleAvatarManager = require("client.logic.avatar.MultipleAvatarManager")
  MultipleAvatarManager._storeEquipments = {}
end
function MultipleAvatar:OnChangeToShow()
  self:EnableCastPhotonShadow(true)
  self:EnableClothAnimation(true)
  self:UpdateGodEffectPosition()
  self:SetCapsuleSize()
  self:ResetSkritParticles()
end
function MultipleAvatar:OnChangeToHide()
  self:EnableCastPhotonShadow(false)
  self:EnableClothAnimation(false)
  self:UpdateGodEffectPosition()
end
function MultipleAvatar:ResetRotation()
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    log(bWriteLog and "LobbyAvatar:ResetRotation operateAvatar is not Valid")
    return
  end
  operateAvatar:K2_SetActorRelativeLocation(FRotator(0, 0, 0), false, nil, false)
end
function MultipleAvatar:ShowAvatar()
  log(bWriteLog and "[LobbyAvatar][MultipleAvatar] MultipleAvatar:ShowAvatar() _avatarID:" .. tostring(self._avatarID))
  if not self._isShowing then
    self._isShowing = true
    self:OnChangeToShow()
  end
  self:SetPosition(self._showPosition.x, self._showPosition.y, self._showPosition.z)
  if self._pet then
    self._pet:HideActor(false)
    self._pet:WaitingForMaster()
  end
end
function MultipleAvatar:HideAvatar()
  log(bWriteLog and "[LobbyAvatar][MultipleAvatar] MultipleAvatar:HideAvatar() _avatarID:" .. tostring(self._avatarID))
  if self._isShowing then
    self._isShowing = false
    self:OnChangeToHide()
  end
  self:SetPosition(self._hidePosition.x, self._hidePosition.y, self._hidePosition.z)
  if self._pet then
    self._pet:HideActor(true)
  end
end
function MultipleAvatar:SetShowPosition(x, y, z)
  log(bWriteLog and string.format("[LobbyAvatar][MultipleAvatar] MultipleAvatar:SetShowPosition(%s, %s, %s)", x, y, z))
  self._showPosition = {
    x = x,
    y = y,
      }
  if self._isShowing then
    self:ShowAvatar()
  end
end
function MultipleAvatar:GetShowPosition()
  if self._showPosition then
    return self._showPosition
  end
end
function MultipleAvatar:UpdatePositionByCamera()
  log(bWriteLog and "[LobbyAvatar][MultipleAvatar] MultipleAvatar:UpdatePositionByCamera()")
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  self:UpdatePositionByCameraID(Lobby_camera_manager_module.currentCameraID)
end
function MultipleAvatar:UpdatePositionByCameraID(CameraID)
  log(bWriteLog and "[LobbyAvatar][MultipleAvatar] MultipleAvatar:UpdatePositionByCameraID() CameraID = " .. tostring(CameraID))
  if CameraID then
    local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
    local config = Lobby_camera_manager_module:GetLobbyCameraInfoByCameraID(CameraID)
    if config == nil then
      log("MultipleAvatar camera config is nil.")
      return
    end
    local positionStr = ""
    local adapt = Lobby_camera_manager_module:GetCurrentCameraRatio()
    if adapt == Lobby_camera_manager_module.Enum_CameraRatio.NormalScreen then
      positionStr = config.AvatarPosition
    elseif adapt == Lobby_camera_manager_module.Enum_CameraRatio.LongScreen then
      positionStr = config.AvatarPositionLong
    elseif adapt == Lobby_camera_manager_module.Enum_CameraRatio.WideScreen then
      positionStr = config.AvatarPositionWidth
    end
    if positionStr == "" then
      return
    end
    local StringUtil = require("common.string_util")
    local positionData = StringUtil.Split(positionStr, ";")
    self:SetShowPosition(tonumber(positionData[1]), tonumber(positionData[2]), tonumber(positionData[3]))
    EventSystem:postEvent(EVENTTYPE_CHARACTER, EVENTID_CHARACTER_UPDATE_POSITION, positionData)
  end
end
function MultipleAvatar:GetShowingAvatarId()
  log(bWriteLog and "[LobbyAvatar][MultipleAvatar] MultipleAvatar:GetShowingAvatarId() self._avatarID = " .. tostring(self._avatarID) .. "")
  return self._avatarID
end
function MultipleAvatar:StoreRotation()
  log(bWriteLog and "[LobbyAvatar][MultipleAvatar] MultipleAvatar:StoreRotation()")
  local MultipleAvatarManager = require("client.logic.avatar.MultipleAvatarManager")
  MultipleAvatarManager._showRotation = self:GetRotation()
end
function MultipleAvatar:RestoreRotation()
  log(bWriteLog and "[LobbyAvatar][MultipleAvatar] MultipleAvatar:RestoreRotation()")
  local MultipleAvatarManager = require("client.logic.avatar.MultipleAvatarManager")
  log(bWriteLog and "MultipleAvatar:RestoreRotation.SetRotation")
  self:SetRotation(MultipleAvatarManager._showRotation.Roll, MultipleAvatarManager._showRotation.Pitch, MultipleAvatarManager._showRotation.Yaw)
end
function MultipleAvatar:ResetRotation()
  log(bWriteLog and "[LobbyAvatar][MultipleAvatar] MultipleAvatar:ResetRotation()")
  self:SetRotation(0, 0, 0)
end
function MultipleAvatar:SetCapsuleSize(halfHeight, radius)
  log(bWriteLog and string.format("[LobbyAvatar][MultipleAvatar] MultipleAvatar:SetCapsuleSize(%s, %s)", halfHeight, radius))
  halfHeight = halfHeight or MultipleAvatar.Const.DefaultPawnCapsuleSize.height
  radius = radius or MultipleAvatar.Const.DefaultPawnCapsuleSize.radius
  self:SetCapsuleHalfHeight(halfHeight)
  self:SetCapsuleRadius(radius)
end
function MultipleAvatar:GetShowingAvatarHeadId()
  log(bWriteLog and "[LobbyAvatar][MultipleAvatar] MultipleAvatar:GetShowingAvatarHeadId() self._headId = " .. tostring(self._headId) .. "")
  return self._headId
end
function MultipleAvatar:ShowSex(targetSex)
  log(bWriteLog and string.format("[LobbyAvatar][MultipleAvatar] MultipleAvatar:ShowSex(%s)", targetSex))
  self:StopAction(nil, true)
  self:SwitchSexAndHeadAndHair(targetSex, self._curAvatarData.headid, 0)
  if self._isShowing then
    self:SetPosition(self._showPosition.x, self._showPosition.y, self._showPosition.z)
  else
    self:SetPosition(self._hidePosition.x, self._hidePosition.y, self._hidePosition.z)
  end
  self:EnableClothAnimation(true)
end
function MultipleAvatar:SwitchSex()
  log(bWriteLog and "[LobbyAvatar][MultipleAvatar] MultipleAvatar:SwitchSex()")
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  if self._sex == LobbyAvatarManager.Enum_Sex.Female then
    self:ShowSex(LobbyAvatarManager.Enum_Sex.Male)
  else
    self:ShowSex(LobbyAvatarManager.Enum_Sex.Female)
  end
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  ModelDisplayer.ClearSexCache()
  local itemID = ModelDisplayer.GetShowModelId()
  local itemCfg = CDataTable.GetTableData("Item", itemID)
  if itemCfg == nil then
    return
  end
  if ModelDisplayer.GetHideAvatarBeforeEmote() then
    ModelDisplayer.HideAvatarBeforeEmote(false)
  end
  if itemCfg.ItemSubType ~= ENUM_ITEM_SUBTYPE.Glider_Slot_415 then
    return
  end
  if not self:HasEquiped(itemID) then
    return
  end
  local StoreUtils = require("client.slua.logic.store.utils.store_utils")
  local redEmotionId = StoreUtils.GetEmotionIDByItemID(itemID)
  ModelDisplayer.Display(redEmotionId)
end
function MultipleAvatar:UpdateLobbyCharacterPetState()
  local LobbyCharacter = self:GetModel()
  if not slua.isValid(LobbyCharacter) then
    return
  end
  local PetID = self._pet and self._pet.PetTypeID
  if LobbyCharacter.bExistGroundPet ~= nil then
    LobbyCharacter.bExistGroundPet = PetID ~= nil and PetID ~= 50001
  end
end
function MultipleAvatar:SetPet(value)
  log(bWriteLog and string.format("[LobbyAvatar][MultipleAvatar] MultipleAvatar:SetPet(%s)", value))
  self._pet = value
  self:UpdateLobbyCharacterPetState()
end
function MultipleAvatar:GetPet()
  log(bWriteLog and "[LobbyAvatar][MultipleAvatar] MultipleAvatar:GetPet()")
  if not self._pet then
    return nil
  end
  return self._pet
end
function MultipleAvatar:RefreshOrCreatePet(PetData, shouldDownload, bTeammate, extraData)
  log(bWriteLog and string.format("[LobbyAvatar][MultipleAvatar] MultipleAvatar:RefreshOrCreatePet PetID=%s", tostring(PetData and PetData.ServerInfo and PetData.ServerInfo.id)))
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    log(bWriteLog and "MultipleAvatar:RefreshOrCreatePet.  operateAvatar is nil")
    return
  end
  local oldPet = self._pet
  local TableUtil = require("common.table_util")
  local OldPetData = oldPet and oldPet:GetPetData()
  if TableUtil.IsDataEqual(OldPetData, PetData) then
    log(bWriteLog and "MultipleAvatar:RefreshOrCreatePet.  IsDataEqual")
    return
  end
  local pet_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.pet_manager)
  local pet = pet_manager:RefreshOrCreatePet(PetData, shouldDownload, bTeammate, oldPet, nil, extraData)
  if not pet then
    return
  end
  pet:SetMaster(true, self)
  pet:UpdateTeamPosIndex(self.positionIndex)
  local type = pet:GetPetType()
  if type == ENUM_LOBBYPET_TYPE.TYPE_GYRFALCON then
    self:EnablePetRotation(false)
  else
    self:EnablePetRotation(true)
  end
end
function MultipleAvatar:UpdatePetPos()
  if self._pet then
    self._pet:UpdateTeamPosWithMaster()
  end
end
function MultipleAvatar:DestroyPet()
  log(bWriteLog and "[LobbyAvatar][MultipleAvatar] MultipleAvatar:DestroyPet()")
  if not self._pet then
    return
  end
  self._pet:Destroy()
  self._pet = nil
  self:UpdateLobbyCharacterPetState()
end
function MultipleAvatar:SetPetName(name)
  log(bWriteLog and string.format("[LobbyAvatar][MultipleAvatar] MultipleAvatar:SetPetName(%s)", name))
  if not self._pet then
    return
  end
  self._pet:SetName(name)
end
function MultipleAvatar:SetPetLevel(level)
  log(bWriteLog and string.format("[LobbyAvatar][MultipleAvatar] MultipleAvatar:SetPetLevel(%s)", level))
  if not self._pet then
    return
  end
  self._pet:SetLevel(level)
end
function MultipleAvatar:PlayPetAction(actionId)
  log(bWriteLog and string.format("[LobbyAvatar][MultipleAvatar] MultipleAvatar:PlayPetAction(%s)", actionId))
  if not self._pet then
    return
  end
  self._pet:PlayAction(actionId)
end
function MultipleAvatar:StopPetAction()
  log(bWriteLog and "[LobbyAvatar][MultipleAvatar] MultipleAvatar:StopPetAction()")
  if not self._pet then
    return
  end
  self._pet:StopAction()
end
function MultipleAvatar:PlayPetFeature(bSkipSync)
  log(bWriteLog and "[LobbyAvatar][MultipleAvatar] MultipleAvatar:PlayPetFeature")
  if not self._pet then
    return
  end
  self._pet:PlayPetFeature(bSkipSync)
end
function MultipleAvatar:PlayEnlargeAction()
  log(bWriteLog and "[LobbyAvatar][MultipleAvatar] MultipleAvatar:PlayEnlargeAction. ")
  if not self._pet then
    return
  end
  self._pet:PlayEnlargeAction()
end
function MultipleAvatar:EnablePetRotation(isEnable)
  log(bWriteLog and string.format("[LobbyAvatar][MultipleAvatar] MultipleAvatar:EnablePetRotation(%s)", isEnable))
  if not self._pet then
    return
  end
  self._pet:EnableRotation(isEnable)
end
function MultipleAvatar:PutOnOrPutOff(itemID, bForcePutOn)
  log(bWriteLog and string.format("[LobbyAvatar][MultipleAvatar] MultipleAvatar:PutOnOrPutOff(%s, %s)", itemID, bForcePutOn))
  if not self._pet then
    return
  end
  self._pet:PutOnOrPutOff(itemID, bForcePutOn)
end
function MultipleAvatar:EnablePetRandomAction(isEnable)
  log(bWriteLog and string.format("[LobbyAvatar][MultipleAvatar] MultipleAvatar:EnablePetRandomAction(%s)", isEnable))
  if not self._pet then
    return
  end
  self._pet:EnableIdleRandomAction(isEnable)
end
function MultipleAvatar:EnablePetClickRandomAction(isEnable)
  log(bWriteLog and string.format("[LobbyAvatar][MultipleAvatar] MultipleAvatar:EnablePetClickRandomAction(%s)", isEnable))
  if not self._pet then
    return
  end
  self._pet:EnableClickRandomAction(isEnable)
end
function MultipleAvatar:StoreEquipments()
  log(bWriteLog and "[LobbyAvatar][MultipleAvatar] MultipleAvatar:StoreEquipments()")
  local MultipleAvatarManager = require("client.logic.avatar.MultipleAvatarManager")
  MultipleAvatarManager._storeEquipments = self:GetEquipments()
end
function MultipleAvatar:SetStoreEquipments(equipments)
  log(bWriteLog and string.format("[LobbyAvatar][MultipleAvatar] MultipleAvatar:SetStoreEquipments(%s)", equipments))
  local MultipleAvatarManager = require("client.logic.avatar.MultipleAvatarManager")
  MultipleAvatarManager._storeEquipments = equipments
end
function MultipleAvatar:RestoreEquipments()
  log(bWriteLog and "[LobbyAvatar][MultipleAvatar] MultipleAvatar:RestoreEquipments()")
  self:ClearEquipments()
  local MultipleAvatarManager = require("client.logic.avatar.MultipleAvatarManager")
  for _, equipmentInfo in pairs(MultipleAvatarManager._storeEquipments) do
    local tAvatarCustom = equipmentInfo.CustomInfo
    local tExtraData = {}
    if equipmentInfo.isCurUsingWeapon ~= nil then
      tExtraData.bIsUse = equipmentInfo.isCurUsingWeapon
    end
    self:PutonEquipment(equipmentInfo.itemID, tAvatarCustom, tExtraData)
    local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
    if ModelDisplayTypeHelper.IsDIYWeapon(equipmentInfo.itemID) then
      self._ProcessDiyWeapon(equipmentInfo.itemID)
    end
  end
end
function MultipleAvatar:PutonOrPutoff(itemID, tAvatarCustom, isForceEquip)
  log(bWriteLog and string.format("[LobbyAvatar][MultipleAvatar] MultipleAvatar:PutonOrPutoff(%s, %s, %s, %s)", itemID, tostring(tAvatarCustom.ColorID), tostring(tAvatarCustom.PatternID), isForceEquip))
  isForceEquip = isForceEquip or false
  if not self:HasEquiped(itemID, tAvatarCustom) then
    self:PutonEquipment(itemID, tAvatarCustom)
    return true
  end
  if isForceEquip then
    return
  end
  self:PutoffEquipment(itemID)
  return false
end
function MultipleAvatar:PutonEquipment(itemID, tAvatarCustom, tExtraData)
  log(bWriteLog and string.format("[MultipleAvatar] MultipleAvatar:PutonEquipment(%s, %s, %s)", itemID, tAvatarCustom, tExtraData))
  if not itemID then
    return
  end
  log(bWriteLog and "MultipleAvatar:PutonEquipment")
  MultipleAvatar.__super.PutonEquipment(self, itemID, tAvatarCustom, tExtraData)
  local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
  if ModelDisplayTypeHelper.IsDIYWeapon(itemID) then
    self:_ProcessDiyWeapon(itemID, tExtraData)
  end
end
function MultipleAvatar:CopyMyEquipments(bUseMyChangeHeadInfo)
  log(bWriteLog and "[LobbyAvatar][MultipleAvatar] MultipleAvatar:CopyMyEquipments() bUseChangeHeadInfo=" .. tostring(bUseMyChangeHeadInfo))
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  self:CopyEquipments(TeamAvatarManager.GetMainAvatar(), bUseMyChangeHeadInfo and {
    uidForChangingHead = DataMgr.roleData.uid
  } or nil)
  self:PutOnMyDiySkin()
end
function MultipleAvatar:PutOnMyDiySkin()
  log(bWriteLog and "[LobbyAvatar][MultipleAvatar] MultipleAvatar:PutOnMyDiySkin()")
  local weaponID, isDiy, isRecommend = DataMgr.GetCurrentWeaponID()
  if not isDiy then
    return
  end
  local WeaponDiySystem = require("client.slua.logic.weapon_diy.logic_weapon_diy")
  local diyConfig = WeaponDiySystem:GetWeaponCfg(weaponID)
  if not diyConfig then
    self:PutonEquipment(weaponID)
    return
  end
  if not isRecommend and DataMgr.Weapon_Diy_PlanID then
    isRecommend = WeaponDiySystem:IsPlanRecommend(DataMgr.Weapon_Diy_PlanID)
  end
  if isRecommend then
    self:PutonEquipment(weaponID)
    local weapon_diy_rec_scheme = require("client.slua.logic.weapon_diy.weapon_diy_rec_scheme")
    local schemeData = weapon_diy_rec_scheme[weaponID]
    if schemeData then
      self:ChangeDiyWeaponScheme(schemeData)
    end
    return
  end
  if not DataMgr.Weapon_Diy_PlanID or DataMgr.Weapon_Diy_PlanID == "" then
    self:PutonEquipment(weaponID)
    return
  end
  local scheme = WeaponDiySystem:GetSchemeData(weaponID, DataMgr.Weapon_Diy_PlanID)
  if not scheme then
    local WeaponDiyHandler = require("client.network.Protocol.WeaponDiyHandler")
    WeaponDiyHandler.send_get_player_ds_data_req(DataMgr.roleData.uid, 1, {
      DataMgr.Weapon_Diy_PlanID
    }, "lobby", nil)
    if WeaponDiyHandler.myCachedDiyScheme[weaponID] then
      self:ChangeDiyWeaponScheme(WeaponDiyHandler.myCachedDiyScheme[weaponID])
    end
    return
  end
  self:PutonEquipment(weaponID)
  self:ChangeDiyWeaponScheme(scheme)
end
function MultipleAvatar:_ProcessDiyWeapon(itemID, extraData)
  log(bWriteLog and string.format("[LobbyAvatar][MultipleAvatar] MultipleAvatar:_ProcessDiyWeapon(%s, %s)", itemID, extraData))
  if extraData and extraData.bUseRec ~= nil and extraData.bUseRec == false and extraData.schemeData == nil then
    return
  end
  local weapon_diy_rec_scheme = require("client.slua.logic.weapon_diy.weapon_diy_rec_scheme")
  local schemeData = weapon_diy_rec_scheme[itemID]
  if extraData == nil or extraData.bUseRec == nil or extraData.bUseRec then
    if schemeData then
      self:ChangeDiyWeaponScheme(schemeData)
    end
  elseif extraData.schemeData then
    self:ChangeDiyWeaponScheme(schemeData)
  end
end
function MultipleAvatar:ChangeDiyWeaponScheme(scheme)
  log(bWriteLog and string.format("[LobbyAvatar][MultipleAvatar] MultipleAvatar:ChangeDiyWeaponScheme(%s)", scheme))
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) then
    return
  end
  self:ChangeGiveWeaponDIYScheme(operateAvatar.curEquipingWeapon, scheme)
end
function MultipleAvatar:ChangeDiyWeaponSchemeBySocketID(scheme, socketID)
  log(bWriteLog and string.format("[LobbyAvatar][MultipleAvatar] MultipleAvatar:ChangeDiyWeaponSchemeBySocketID(%s, %s)", scheme, socketID))
  local operateAvatar = self:GetModel()
  if not slua.isValid(operateAvatar) or not operateAvatar.BP_LobbyWeaponManager then
    return
  end
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  socketID = socketID or LobbyAvatarManager.Enum_WeaponAttachSlotID.MAIN_WEAPON1
  self:ChangeGiveWeaponDIYScheme(operateAvatar.BP_LobbyWeaponManager:GetWeaponBySocketID(socketID), scheme)
end
function MultipleAvatar:ChangeGiveWeaponDIYScheme(weaponActor, scheme)
  log(bWriteLog and string.format("[LobbyAvatar][MultipleAvatar] MultipleAvatar:ChangeGiveWeaponDIYScheme(%s, %s)", weaponActor, scheme))
  local weapon_id
  if weaponActor and weaponActor.WeaponAvatarComponent then
    local handle = weaponActor.WeaponAvatarComponent:GetEquippedHandle(7)
    if slua.isValid(handle) then
      weapon_id = handle:GetDefineID().TypeSpecificID
    end
  end
  local MallSystemWeaponModelHandler = require("client.slua.logic.manager.WeaponModelLogic")
  MallSystemWeaponModelHandler.ChangeGiveWeaponDIYScheme(weaponActor, scheme, true, weapon_id)
end
function MultipleAvatar:ClearEquipmentsExceptHairAndBeard()
  log(bWriteLog and "[LobbyAvatar][MultipleAvatar] MultipleAvatar:ClearEquipmentsExceptHairAndBeard()")
  self:ClearEquipments({
    ENUM_ITEM_SUBTYPE.Hair_Slot,
    ENUM_ITEM_SUBTYPE.Theme_Play,
    ENUM_ITEM_SUBTYPE.UnderCloth,
    ENUM_ITEM_SUBTYPE.UnderPants
  })
  self:DestroyPet()
  self:DestroyMiniTV()
end
function MultipleAvatar:UpdateOrCreateMiniTV(MiniTVDressID)
  if not self._miniTVActor then
    local LobbyModelPool = require("client.slua.logic.show_actor.common.LobbyModelPool")
    local LobbyShowActorConfig = require("client.slua.logic.show_actor.common.LobbyShowActorConfig")
    self._miniTVActor = LobbyModelPool.GetModel(LobbyShowActorConfig.Type.MiniTVNew)
  end
  if not slua.isValid(self._miniTVActor) then
    return
  end
  self._miniTVActor:SetMaster(self)
  self._miniTVActor:PutOnCloth(MiniTVDressID)
end
function MultipleAvatar:DestroyMiniTV()
  log(bWriteLog and "[LobbyAvatar][MultipleAvatar] MultipleAvatar:DestroyMiniTV()")
  if not self._miniTVActor then
    return
  end
  local LobbyModelPool = require("client.slua.logic.show_actor.common.LobbyModelPool")
  local LobbyShowActorConfig = require("client.slua.logic.show_actor.common.LobbyShowActorConfig")
  self._miniTVActor = LobbyModelPool.ReleaseModel(LobbyShowActorConfig.Type.MiniTVNew, self._miniTVActor)
  self._miniTVActor = nil
end
function MultipleAvatar:GetMiniTVActor()
  log(bWriteLog and "[LobbyAvatar][MultipleAvatar] MultipleAvatar:GetMiniTVActor()")
  return self._miniTVActor
end
local class = require("class")
local base = require("client.logic.avatar.LobbyAvatar")
local C_MultipleAvatar = class(base, nil, MultipleAvatar)
return C_MultipleAvatar