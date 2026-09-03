local HighlightMomentUtility = {}
local USTExtraGameplayStatics = import("STExtraGameplayStatics")
local UKismetSystemLibrary = import("KismetSystemLibrary")
local EDrawDebugTrace = import("EDrawDebugTrace")
local ECollisionChannel = import("ECollisionChannel")
local ObjectTypes = slua.Array(UEnums.EPropertyClass.Int)
ObjectTypes:Add(ECollisionChannel.ECC_Vehicle)
ObjectTypes:Add(ECollisionChannel.ECC_WorldDynamic)
ObjectTypes:Add(ECollisionChannel.ECC_WorldStatic)
ObjectTypes:Add(ECollisionChannel.ECC_Visibility)
local _FindMaxIndexInTable = function(tTable)
  local nMaxIndex = 1
  local nMaxValue = tTable[1]
  for index, nValue in ipairs(tTable) do
    if nValue > nMaxValue then
      nMaxValue = nValue
      nMaxIndex = index
    end
  end
  return nMaxIndex
end
function HighlightMomentUtility.TryFindProperRorationForCamera(uStartLocation, uStartDirection, nTargetLen, nMinLen, tIgnoreActors, nDetectingDirNum)
  if not (uStartLocation and uStartDirection) or nTargetLen <= 0 then
    return nil
  end
  local nDirNum = nDetectingDirNum or 4
  local nAverageAngle = 360 / nDirNum
  local uNormalizedDirection = uStartDirection:GetSafeNormal(1.0E-5)
  local tCheckingTargetLocaton = {
    uStartLocation + uNormalizedDirection * nTargetLen,
    uStartLocation - uNormalizedDirection * nTargetLen
  }
  local tCheckingDirection = {
    uNormalizedDirection,
    uNormalizedDirection * -1
  }
  local nCheckingAngle = nAverageAngle
  local uDirection
  while nCheckingAngle < 360 do
    if nCheckingAngle ~= 180 then
      uDirection = uNormalizedDirection:RotateAngleAxis(nCheckingAngle, FVector.UpVector)
      tCheckingDirection[#tCheckingDirection + 1] = uDirection
      tCheckingTargetLocaton[#tCheckingTargetLocaton + 1] = uStartLocation + uDirection * nTargetLen
    end
    nCheckingAngle = nCheckingAngle + nAverageAngle
  end
  local tDetectingDistance = {}
  for index, uCheckingLocation in ipairs(tCheckingTargetLocaton) do
    local uCheckingDirection = tCheckingDirection[index]
    local bHit, uHitResult = UKismetSystemLibrary.LineTraceSingleForObjects(CGameState, uStartLocation, uCheckingLocation, ObjectTypes, false, tIgnoreActors, 0, nil, true, FLinearColor.Green, FLinearColor.Red, 5)
    if not bHit then
      return tCheckingDirection[index]:Rotation()
    end
    if nMinLen then
      local nDistance = uHitResult.Distance
      tDetectingDistance[#tDetectingDistance + 1] = nMinLen < nDistance and nDistance or -1
    end
  end
  if not nMinLen then
    return nil
  end
  local nMaxIndex = _FindMaxIndexInTable(tDetectingDistance)
  if tDetectingDistance[nMaxIndex] == -1 then
    return nil
  end
  return tCheckingDirection[nMaxIndex]:Rotation()
end
function HighlightMomentUtility.CheckIfObstacleAbove(uStartLocation, nHeight, tIgnoreActors)
  local uTraceEndLocation = FVector(uStartLocation.X, uStartLocation.Y, uStartLocation.Z + nHeight)
  return UKismetSystemLibrary.LineTraceSingleForObjects(CGameState, uStartLocation, uTraceEndLocation, ObjectTypes, false, tIgnoreActors, 0, nil, true, FLinearColor.Green, FLinearColor.Red, 5)
end
function HighlightMomentUtility.CheckIfObstacleAround(uStartLocation, nHeight, uRotation, uBoundingBox2D, tIgnoreActors)
  if not uStartLocation or not uBoundingBox2D then
    return false
  end
  local uBoundingBoxMax = uBoundingBox2D.Max
  local uBoundingBoxMin = uBoundingBox2D.Min
  local nHalfHeight = nHeight * 0.5
  local uHalfSize2D = (uBoundingBoxMax - uBoundingBoxMin) * 0.5
  local uHalfSize = FVector(uHalfSize2D.X, uHalfSize2D.Y, nHalfHeight)
  local uBoxCenter = (uBoundingBoxMax + uBoundingBoxMin) * 0.5
  local nYaw = uRotation and uRotation.Yaw or 0
  local uRotatedCenter = FVector(uBoxCenter.X, uBoxCenter.Y, 0):RotateAngleAxis(nYaw, FVector.UpVector)
  local uTraceStart = uStartLocation + FVector(uRotatedCenter.X, uRotatedCenter.Y, nHalfHeight + 5)
  local uTraceEnd = FVector(uTraceStart.X, uTraceStart.Y, uTraceStart.Z - 5)
  return UKismetSystemLibrary.BoxTraceSingleForObjects(CGameState, uTraceStart, uTraceEnd, uHalfSize, uRotation or FRotator(), ObjectTypes, false, tIgnoreActors, 2, nil, true, FLinearColor.Green, FLinearColor.Red, 5)
end
return HighlightMomentUtility