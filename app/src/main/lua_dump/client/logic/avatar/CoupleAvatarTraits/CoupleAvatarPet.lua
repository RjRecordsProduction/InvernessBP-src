local CoupleAvatarPet = {}
local GetBasicDataAvatarWearInfo = function()
  local BasicDataAvatarWearInfo = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataAvatarWearInfo)
  return BasicDataAvatarWearInfo
end
function CoupleAvatarPet:_CreatePet(avatar, UID)
  log(bWriteLog and "CoupleAvatarPet _CreatePet avatar:" .. tostring(avatar) .. " UID " .. tostring(UID))
  local bTeammate = UID ~= DataMgr.roleData.uid
  local pet_info = GetBasicDataAvatarWearInfo():GetPetInfo(UID)
  if not pet_info or pet_info.id == 0 then
    log(bWriteLog and "CoupleAvatarPet _CreatePet not pet_info")
    avatar:DestroyPet()
    return
  end
  local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
  local pet = avatar:GetPet()
  local bResetPetData = true
  local TableUtil = require("common.table_util")
  local PetDataNew = logic_pet:FormatPetDataByServerInfo(UID, pet_info, self.sceneType)
  if pet then
    local PetData = pet:GetPetData()
    bResetPetData = not TableUtil.IsDataEqual(PetData, PetDataNew)
  end
  if bResetPetData then
    local extraData = {bRefreshImmediately = true}
    pet = avatar:RefreshOrCreatePet(PetDataNew, true, bTeammate, extraData)
  end
  pet = avatar:GetPet()
  if self:IsTwoPerson() and pet and slua.isValid(pet:GetModel()) then
    pet:GetModel().CapsuleComponent:SetAbsolute(false, false, false)
    if pet_info.id == 50001 and LobbySceneManager.IsStreamLevelLoaded("Lobby_CP01") and LobbySceneManager.IsStreamLevelLoaded("Lobby_Light_CP01") and slua.isValid(pet:GetModel().Mesh) then
      pet:GetModel().Mesh:SetCastPhotonShadow(false)
    end
  end
  return pet
end
function CoupleAvatarPet:SetCoupleAvatarPetIsHide(nAvatarType, bIsHide)
  local cObj_avatar = self:GetAvatar(nAvatarType)
  if not cObj_avatar then
    log(bWriteLog and "CoupleAvatarPet:SetCoupleAvatarPetIsHide not cObj_avatar")
    return
  end
  local cObj_pet = cObj_avatar:GetPet()
  if cObj_pet then
    cObj_pet:SetPetModelIsHide(bIsHide)
  end
end
function CoupleAvatarPet:_AdjustPetLocation(AvatarType)
  log(bWriteLog and "CoupleAvatarPet _AdjustPetLocation AvatarType" .. tostring(AvatarType))
  local avatar = self:GetAvatar(AvatarType)
  if not avatar then
    log(bWriteLog and "CoupleAvatarPet _AdjustPetLocation not avatar")
    return
  end
  local pet = avatar:GetPet()
  if pet then
    local Pose = self:GetSelfPoseID()
    local PoseType = self:GetStandType(AvatarType)
    pet:AdjustAttachLocationForCoupleAvatar(self.pawnContainer, Pose, PoseType)
    pet:SetForceDisableRandomAction(true)
  end
end
function CoupleAvatarPet:EnablePetIdleRandomAction(enable)
  for _, avatar in pairs(self.avatars) do
    avatar:EnablePetRandomAction(enable)
  end
end
local Trait = require("common.trait")
local TCoupleAvatarPet = Trait(Trait.TraitPrototype, nil, CoupleAvatarPet)
return TCoupleAvatarPet