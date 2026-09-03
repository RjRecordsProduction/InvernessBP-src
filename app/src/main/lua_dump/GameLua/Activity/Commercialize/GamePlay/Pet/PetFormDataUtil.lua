local ENUM_PetFormType = {None = 0, ModifyScale = 1}
local PetFormDataUtil = {
  CachePetEnlargeState = {},
  CachePetSwitchEffectItemID = {}
}
function PetFormDataUtil:GeneratePlayerPetFormData(PlayerInfo, uPlayerController)
  if not uPlayerController then
    return
  end
  self:_FillPetFormData(uPlayerController, PlayerInfo)
  self:_FillPetSwitchEffectData(uPlayerController, PlayerInfo)
  self:_ProcessPetBubblePrivilege(uPlayerController, PlayerInfo)
end
function PetFormDataUtil:_FillPetFormData(uPlayerController, PlayerInfo)
  if not uPlayerController or not PlayerInfo then
    return
  end
  local UID = uPlayerController.UID
  local ExtendAttribute = require("Server.config.ExtendAttribute")
  local CommerAvatarDataUtil = require("GameLua.Activity.Commercialize.GamePlay.CommerAvatarDataUtil")
  local ExtAttrAdditionPetInfo = CommerAvatarDataUtil:GetPlayerExtendAttributeAndTest(UID, ExtendAttribute.AdditionPetInfo)
  if PlayerInfo.pet_info and PlayerInfo.pet_info.change == 1 then
    uPlayerController.CommerFeature.ChangeScalePetIDList:AddUnique(PlayerInfo.pet_info.pet_id)
    self:AddPetFormData(UID, PlayerInfo.pet_info.pet_id, true)
  end
  if ExtAttrAdditionPetInfo and next(ExtAttrAdditionPetInfo) then
    for _, v in pairs(ExtAttrAdditionPetInfo) do
      if v.change == 1 then
        uPlayerController.CommerFeature.ChangeScalePetIDList:AddUnique(v.pet_id)
        self:AddPetFormData(UID, v.pet_id, true)
      end
    end
  end
end
function PetFormDataUtil:_FillPetSwitchEffectData(uPlayerController, PlayerInfo)
  if not uPlayerController or not PlayerInfo then
    return
  end
  local UID = uPlayerController.UID
  local ExtendAttribute = require("Server.config.ExtendAttribute")
  local CommerAvatarDataUtil = require("GameLua.Activity.Commercialize.GamePlay.CommerAvatarDataUtil")
  local ExtAttrPetSwitchEffect = CommerAvatarDataUtil:GetPlayerExtendAttributeAndTest(UID, ExtendAttribute.PetSwitchEffect)
  local PetSwitchEffectID = ExtAttrPetSwitchEffect and ExtAttrPetSwitchEffect[1] or 0
  self.CachePetSwitchEffectItemID[UID] = PetSwitchEffectID
  uPlayerController.CommerFeature.end
function PetFormDataUtil:AddPetFormData(UID, PetID, State)
  if not UID or not PetID then
    return
  end
  if not self.CachePetEnlargeState[UID] then
    self.CachePetEnlargeState[UID] = {}
  end
  self.CachePetEnlargeState[UID][PetID] = State
end
function PetFormDataUtil:GetPetFormDataList(UID)
  if not UID then
    return nil
  end
  return self.CachePetEnlargeState[UID]
end
function PetFormDataUtil:GetPetEffectID(UID)
  if not UID then
    return 0
  end
  return self.CachePetSwitchEffectItemID[UID] or 0
end
function PetFormDataUtil:_ProcessPetBubblePrivilege(uPlayerController, PlayerInfo)
  if not uPlayerController or not PlayerInfo then
    return
  end
  local UID = uPlayerController.UID
  local ExtendAttribute = require("Server.config.ExtendAttribute")
  local CommerAvatarDataUtil = require("GameLua.Activity.Commercialize.GamePlay.CommerAvatarDataUtil")
  local ExtAttrPetBubblePrivilege = CommerAvatarDataUtil:GetPlayerExtendAttributeAndTest(UID, ExtendAttribute.PetBubblePrivilege)
  uPlayerController.CommerFeature.bHasPetBubblePrivilege = ExtAttrPetBubblePrivilege ~= nil
  uPlayerController.CommerFeature.PetBubbleIDList = slua.Array(UEnums.EPropertyClass.Int)
  if PlayerInfo.emoji_bubble then
    for _, bubbleID in ipairs(PlayerInfo.emoji_bubble) do
      uPlayerController.CommerFeature.PetBubbleIDList:Add(bubbleID)
    end
  end
end
return PetFormDataUtil