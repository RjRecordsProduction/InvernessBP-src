local PetAvatarComponent = {}
local FItemDefineID = import("/Script/Basic.ItemDefineID")
local AvatarCustom = FAvatarCustomDefault()
function PetAvatarComponent:ReceiveBeginPlay()
  log(bWriteLog and "PetAvatarComponent:ReceiveBeginPlay. ")
  PetAvatarComponent.__super.ReceiveBeginPlay(self)
end
function PetAvatarComponent:PetEquipItemById(ID)
  log(bWriteLog and "PetAvatarComponent:PetEquipItemById ID: " .. tostring(ID) .. " " .. tostring(self.ItemType))
  local ItemType = self.ItemType ~= 0 and self.ItemType or 501
  return self:HandleEquipItem(FItemDefineID(ItemType, ID), AvatarCustom)
end
function PetAvatarComponent:GetMappedAssetPath(OriginalAssetPath)
  local PetUtil = require("GameLua.Mod.BaseMod.Actor.Pet.PetUtil")
  local AvatarDefineID = self:GetEquippedItemDefineID(1)
  local DressItemID = AvatarDefineID.TypeSpecificID
  return PetUtil.GetMappedAssetPath(OriginalAssetPath, DressItemID)
end
local class = require("class")
local CActorComponentBase = require("GameLua.Mod.BaseMod.Common.Core.ActorComponentBase")
local CPetAvatarComponent = class(CActorComponentBase, nil, PetAvatarComponent)
return CPetAvatarComponent