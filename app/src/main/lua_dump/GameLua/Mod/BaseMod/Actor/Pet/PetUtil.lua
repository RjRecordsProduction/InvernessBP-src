local PetUtil = {
  BirdId = 50001,
  FlyDis = 200,
  FlyTeleDis = 1000,
  FlyStartPosZ = 250,
  FlyTelePos = 200,
  FlyTeleRandom = 100,
  FlyPitch = 30
}
function PetUtil.IsBird(petId)
  return petId == PetUtil.BirdId
end
local FlyBtIdTb = {
  [1601072] = 1,
  [1601071] = 1
}
function PetUtil.GetPetBtId(PetAvatarList)
  for _, id in pairs(PetAvatarList) do
    local value = FlyBtIdTb[id]
    if value then
      return value
    end
  end
  return 0
end
function PetUtil.IsSpecialBird(ownerController)
  if not slua.isValid(ownerController) then
    return false
  end
  if ownerController.UsingAdditionalPetIndex == -1 then
    ownerController.UsingAdditionalPetIndex = 0
    if not IsEditor then
      log_error("GetPetPosZ. ownerController.UsingAdditionalPetIndex: -1")
    end
  end
  if ownerController.AdditionalPetInfo:Num() == 0 then
    return false
  end
  local petInfo = ownerController.AdditionalPetInfo:Get(ownerController.UsingAdditionalPetIndex)
  local PetId = petInfo.PetId
  local PetAvatarList = petInfo.PetAvatarList
  log(bWriteLog and "IsSpecialBird. PetAvatarList:Num(): " .. tostring(PetAvatarList:Num()))
  if PetUtil.IsBird(PetId) and PetUtil.GetPetBtId(PetAvatarList) == 1 then
    return true
  end
  return false
end
function PetUtil.GetFlyBtIdTb()
  return FlyBtIdTb
end
function PetUtil.IsClothesNotAttach(id)
  return FlyBtIdTb[id]
end
function PetUtil.GetMappedAssetPath(OriginalAssetPath, DressItemID)
  if not OriginalAssetPath then
    return ""
  end
  if not DressItemID or DressItemID == 0 then
    return OriginalAssetPath
  end
  local MappedActionCfg = CDataTable.GetTableDataByFilter("PetActionAssetMapTable", "DressItemID", DressItemID, "OriginalAssetPath", OriginalAssetPath)
  if MappedActionCfg then
    log(bWriteLog and string.format("GetMappedAssetPath. Cfg found for DressItemID:%s MappedAssetPath:%s", tostring(DressItemID), MappedActionCfg.MappedAssetPath))
    return MappedActionCfg.MappedAssetPath
  end
  return OriginalAssetPath
end
return PetUtil