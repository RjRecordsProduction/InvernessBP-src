local ActorTools = {}
local UKismetSystemLibrary = import("KismetSystemLibrary")
local UGameplayStatics = import("GameplayStatics")
local UActorClass = import("/Script/Engine.Actor")
function ActorTools.GetOneActor(uWorldObject, sActorBPPath)
  local uWorldActorClass = import(sActorBPPath)
  local uWorldActorArray = UGameplayStatics.GetAllActorsOfClass(uWorldObject, uWorldActorClass, slua.Array(UEnums.EPropertyClass.Object, UActorClass))
  if uWorldActorArray and uWorldActorArray:Num() > 0 then
    return uWorldActorArray:Get(0)
  end
  return nil
end
function ActorTools.GetOneActorByTag(uWorldObject, sActorBPPath, sTag)
  local uWorldActorClass = import(sActorBPPath)
  local uWorldActorArray = UGameplayStatics.GetAllActorsOfClass(uWorldObject, uWorldActorClass, slua.Array(UEnums.EPropertyClass.Object, UActorClass))
  for _, uActor in pairs(uWorldActorArray) do
    if uActor and slua.isValid(uActor) and uActor:ActorHasTag(sTag) then
      return uActor
    end
  end
  return nil
end
function ActorTools.GetOneActorByCondition(uWorldObject, sActorBPPath, func)
  local uWorldActorClass = import(sActorBPPath)
  local uWorldActorArray = UGameplayStatics.GetAllActorsOfClass(uWorldObject, uWorldActorClass, slua.Array(UEnums.EPropertyClass.Object, UActorClass))
  for _, uActor in pairs(uWorldActorArray) do
    if uActor and slua.isValid(uActor) and func ~= nil and func(uActor) then
      return uActor
    end
  end
  return nil
end
function ActorTools.GetAllActors(uWorldObject, sActorBPPath)
  local uWorldActorClass = import(sActorBPPath)
  local uWorldActorArray = UGameplayStatics.GetAllActorsOfClass(uWorldObject, uWorldActorClass, slua.Array(UEnums.EPropertyClass.Object, UActorClass))
  return uWorldActorArray
end
function ActorTools.GetAllActorsByTag(uWorldObject, sActorBPPath, sTag)
  local uWorldActorClass = import(sActorBPPath)
  local uWorldActorArray = UGameplayStatics.GetAllActorsOfClass(uWorldObject, uWorldActorClass, slua.Array(UEnums.EPropertyClass.Object, UActorClass))
  local uOutActorArray = slua.Array(UEnums.EPropertyClass.Object, UActorClass)
  for _, uActor in pairs(uWorldActorArray) do
    if uActor and slua.isValid(uActor) and uActor:ActorHasTag(sTag) then
      uOutActorArray:Add(uActor)
    end
  end
  return uOutActorArray
end
function ActorTools.GetAllActorsByCondition(uWorldObject, sActorBPPath, func)
  local uWorldActorClass = import(sActorBPPath)
  local uWorldActorArray = UGameplayStatics.GetAllActorsOfClass(uWorldObject, uWorldActorClass, slua.Array(UEnums.EPropertyClass.Object, UActorClass))
  local uOutActorArray = slua.Array(UEnums.EPropertyClass.Object, UActorClass)
  for _, uActor in pairs(uWorldActorArray) do
    if uActor and slua.isValid(uActor) and func ~= nil and func(uActor) then
      uOutActorArray:Add(uActor)
    end
  end
  return uOutActorArray
end
function ActorTools.GetAllActorsWithTag(uWorldObject, sTag)
  if not sTag or sTag == "" then
    return nil
  end
  local UGameplayStatics = import("GameplayStatics")
  local Actor = import("/Script/Engine.Actor")
  local ActorArray = slua.Array(UEnums.EPropertyClass.Object, Actor)
  ActorArray = UGameplayStatics.GetAllActorsWithTag(uWorldObject, sTag, ActorArray)
  return ActorArray
end
function ActorTools.GetOneActorWithTag(uWorldObject, sTag)
  local ActorArray = ActorTools.GetAllActorsWithTag(uWorldObject, sTag)
  if ActorArray and ActorArray:Num() > 0 then
    return ActorArray:Get(0)
  end
  return nil
end
function ActorTools.GetOneActorByName(uWorldObject, sActorBPPath, sActorName, bExactMatch)
  if not sActorName or sActorName == "" then
    return nil
  end
  local uWorldActorClass = import(sActorBPPath)
  local uWorldActorArray = UGameplayStatics.GetAllActorsOfClass(uWorldObject, uWorldActorClass, slua.Array(UEnums.EPropertyClass.Object, UActorClass))
  bExactMatch = bExactMatch ~= nil and bExactMatch or true
  for _, uActor in pairs(uWorldActorArray) do
    if uActor and slua.isValid(uActor) then
      local sCurrentName = UKismetSystemLibrary.GetObjectName(uActor)
      local bMatch = false
      if bExactMatch then
        bMatch = sCurrentName == sActorName
      else
        bMatch = string.find(sCurrentName, sActorName) ~= nil
      end
      if bMatch then
        return uActor
      end
    end
  end
  return nil
end
function ActorTools.CallOneActorFunc(uWorldObject, sActorBPPath, sFuncName, ...)
  local uWorldActorArray = ActorTools.GetAllActors(uWorldObject, sActorBPPath)
  for _, uActor in pairs(uWorldActorArray) do
    if uActor and slua.isValid(uActor) then
      if uActor[sFuncName] then
        uActor[sFuncName](uActor, ...)
        break
      else
        print(bWriteLog and "CallOneActorFunc Failed", sActorBPPath, sFuncName)
      end
    end
  end
end
function ActorTools.CallOneActorFuncByTag(uWorldObject, sActorBPPath, sTag, sFuncName, ...)
  local uWorldActorArray = ActorTools.GetAllActors(uWorldObject, sActorBPPath)
  for _, uActor in pairs(uWorldActorArray) do
    if uActor and slua.isValid(uActor) and uActor:ActorHasTag(sTag) then
      if uActor[sFuncName] then
        uActor[sFuncName](uActor, ...)
        break
      else
        print(bWriteLog and "CallOneActorFuncByTag Failed", sActorBPPath, sFuncName)
      end
    end
  end
end
function ActorTools.CallOneActorFuncByCondition(uWorldObject, sActorBPPath, func, sFuncName, ...)
  local uWorldActorArray = ActorTools.GetAllActors(uWorldObject, sActorBPPath)
  for _, uActor in pairs(uWorldActorArray) do
    if uActor and slua.isValid(uActor) and func ~= nil and func(uActor) then
      if uActor[sFuncName] then
        uActor[sFuncName](uActor, ...)
        break
      else
        print(bWriteLog and "CallOneActorFuncByCondition Failed", sActorBPPath, sFuncName)
      end
    end
  end
end
function ActorTools.CallAllActorsFunc(uWorldObject, sActorBPPath, sFuncName, ...)
  local uWorldActorArray = ActorTools.GetAllActors(uWorldObject, sActorBPPath)
  for _, uActor in pairs(uWorldActorArray) do
    if uActor and slua.isValid(uActor) then
      if uActor[sFuncName] then
        uActor[sFuncName](uActor, ...)
      else
        print(bWriteLog and "CallAllActorsFunc Failed", sActorBPPath, sFuncName)
      end
    end
  end
end
function ActorTools.CallAllActorsFuncByTag(uWorldObject, sActorBPPath, sTag, sFuncName, ...)
  local uWorldActorArray = ActorTools.GetAllActors(uWorldObject, sActorBPPath)
  for _, uActor in pairs(uWorldActorArray) do
    if uActor and slua.isValid(uActor) and uActor:ActorHasTag(sTag) then
      if uActor[sFuncName] then
        uActor[sFuncName](uActor, ...)
      else
        print(bWriteLog and "CallAllActorsFuncByTag Failed", sActorBPPath, sFuncName)
      end
    end
  end
end
function ActorTools.CallAllActorsFuncByCondition(uWorldObject, sActorBPPath, func, sFuncName, ...)
  local uWorldActorArray = ActorTools.GetAllActors(uWorldObject, sActorBPPath)
  for _, uActor in pairs(uWorldActorArray) do
    if uActor and slua.isValid(uActor) and func ~= nil and func(uActor) then
      if uActor[sFuncName] then
        uActor[sFuncName](uActor, ...)
      else
        print(bWriteLog and "CallAllActorsFuncByCondition Failed", sActorBPPath, sFuncName)
      end
    end
  end
end
function ActorTools.SpawnActor(uWorldObject, Class, Location, Rotation, Scale)
  if not slua.isValid(uWorldObject) then
    return nil
  end
  local uWorld = uWorldObject:GetWorld()
  if not slua.isValid(uWorld) then
    return nil
  end
  local uClass = slua.loadClass(Class)
  local uActor = uWorld:SpawnActor(uClass, Location, nil, nil)
  if not slua.isValid(uActor) then
    return nil
  end
  uActor:K2_SetActorRotation(Rotation, false)
  uActor:SetActorScale3D(Scale)
  return uActor
end
function ActorTools.SpawnActorWithInitData(uWorldObject, Class, Location, Rotation, Scale, InitDataCallback)
  if not slua.isValid(uWorldObject) then
    return
  end
  local uWorld = uWorldObject:GetWorld()
  if not slua.isValid(uWorld) then
    return
  end
  local UGameplayStatics = import("GameplayStatics")
  local ESpawnActorCollisionHandlingMethod = import("ESpawnActorCollisionHandlingMethod")
  local u  if type(Class) == "string" then
    uClass = slua.loadClass(Class)
  end
  local uSpawntransform = FTransform(Rotation, Location, Scale)
  local uActor = UGameplayStatics.BeginDeferredActorSpawnFromClass(uWorld, uClass, uSpawntransform, ESpawnActorCollisionHandlingMethod.AdjustIfPossibleButAlwaysSpawn, nil)
  if not slua.isValid(uActor) then
    return
  end
  InitDataCallback(uActor)
  UGameplayStatics.FinishSpawningActor(uActor, uSpawntransform)
  return uActor
end
function ActorTools.SpawnActorAsync(uWorldObject, Class, Location, Rotation, Scale, CallBack)
  if not slua.isValid(uWorldObject) then
    return nil
  end
  local uWorld = uWorldObject:GetWorld()
  if not slua.isValid(uWorld) then
    return nil
  end
  if CallBack then
    local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
    local KismetSystemLibrary = import("KismetSystemLibrary")
    local ObjectPath = KismetSystemLibrary.MakeSoftObjectPath(Class)
    local loadedDelegate = slua.createDelegate(function(LoadObject)
      local uActor = uWorld:SpawnActor(LoadObject, Location, nil, nil)
      if not slua.isValid(uActor) then
        CallBack(nil)
        return
      end
      uActor:K2_SetActorRotation(Rotation, false)
      uActor:SetActorScale3D(Scale)
      CallBack(uActor)
    end)
    STExtraBlueprintFunctionLibrary.GetAssetByAssetReferenceAsync(ObjectPath, loadedDelegate)
  end
end
function ActorTools.GetSignalGunEffectCfgByID(effectId)
  if effectId == 0 then
    return
  end
  local zoneID = CGameState and tostring(CGameState.nServerZoneId) or "0"
  print(bWriteLog and "[edward] ActorTools.GetSignalGunEffectCfgByID, zoneId = ", zoneID)
  local effectCfg
  local effectCfgs = CDataTable.GetTable("FlareGunEffCfg")
  for id, data in pairs(effectCfgs) do
    if data.SignalGunEffectId == effectId then
      local strRegion = Client.GetPublishRegion()
      if string.find(data.ClientVersion, strRegion) ~= nil and (not data.ActiveZoneIDs or data.ActiveZoneIDs == "" or string.find(data.ActiveZoneIDs, zoneID)) then
        effectCfg = data
        break
      end
    end
  end
  return effectCfg
end
return ActorTools