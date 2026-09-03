local InValidCheckArea = {}
function InValidCheckArea:ctor()
  self.bMultiTriggerCollision = true
  self.IsEnabled = true
  self.InAreaPlayerNum = 0
  self.bIgnoreFlyMode = true
end
function InValidCheckArea:ServerOnPlayerEnterOrLeave(uPlayer, bEnter)
  InValidCheckArea.__super.ServerOnPlayerEnterOrLeave(self, uPlayer, bEnter)
  if not slua.isValid(uPlayer) then
    return
  end
  if bEnter then
    self.InAreaPlayerNum = self.InAreaPlayerNum + 1
  else
    self.InAreaPlayerNum = self.InAreaPlayerNum - 1
  end
  if self.IsEnabled then
    if self.InAreaPlayerNum > 0 then
      self:StartCheck()
    else
      self:StopCheck()
    end
  end
end
function InValidCheckArea:SetEnabled(IsEnabled)
  if not self:HasAuthority() then
    return
  end
  print(bWriteLog and string.format("InValidCheckArea:SetEnabled %s", IsEnabled))
  self.  if IsEnabled then
    if self.InAreaPlayerNum > 0 then
      self:StartCheck()
    else
      self:StopCheck()
    end
  else
    self:StopCheck()
  end
end
function InValidCheckArea:StartCheck()
  if not self:HasAuthority() then
    return
  end
  print(bWriteLog and string.format("InValidCheckArea:StartCheck"))
  if self.CheckTimer == nil then
    self.CheckTimer = self:AddGameTimer(self.CheckInterval, true, function()
      local uCharactersArray = self:GetOverlappingActors(slua.Array(UEnums.EPropertyClass.Object, import("/Script/Engine.Actor")), self.ClassFilter)
      if uCharactersArray:Num() <= 0 then
        return
      end
      for _, uCharacter in pairs(uCharactersArray) do
        if Game:IsPlayer(uCharacter) then
          self:CheckFunction(uCharacter)
        end
      end
    end)
  end
end
function InValidCheckArea:StopCheck()
  if not self:HasAuthority() then
    return
  end
  print(bWriteLog and string.format("InValidCheckArea:StopCheck"))
  self:TryRemoveNamedGameTimer("CheckTimer")
end
function InValidCheckArea:CheckFunction(uPlayer)
  if self.bIgnoreFlyMode then
    local uMovementCompnent = uPlayer.STCharacterMovement
    if slua.isValid(uMovementCompnent) and uMovementCompnent.MovementMode == import("EMovementMode").MOVE_Flying then
      print(bWriteLog and "InValidCheckArea:CheckFunction Ignore MOVE_Flying")
      return
    end
  end
  if self.DamageToApply > 0 then
    self:ApplyDamageLua(uPlayer)
  end
  if 0 < self.TipsID then
    self:ShowTipsLua(uPlayer)
  end
  if self.bDragOnGround then
    self:DragOnGroundLua(uPlayer)
  end
end
function InValidCheckArea:ApplyDamageLua(uPlayer)
  if slua.isValid(uPlayer) then
    Game:DamageTarget(nil, uPlayer, self.DamageToApply, UEnums.DamageType.DotDamage)
    return true
  end
  return false
end
function InValidCheckArea:ShowTipsLua(uPlayer)
  if slua.isValid(uPlayer) and uPlayer.GetPlayerKey ~= nil then
    Game:UIShowImageTips(uPlayer:GetPlayerKey(), self.TipsID)
    return true
  end
  return false
end
function InValidCheckArea:DragOnGroundLua(uPlayer)
  if not slua.isValid(uPlayer) then
    return false
  end
  local CurLoc = uPlayer:K2_GetActorLocation()
  if slua.isValid(uPlayer.STCharacterMovement) then
    local EMovementMode = import("EMovementMode")
    if uPlayer.STCharacterMovement.MovementMode == EMovementMode.MOVE_Walking or uPlayer.STCharacterMovement.MovementMode == EMovementMode.MOVE_Swimming then
      local RayEnd = CurLoc
      local RayStart = RayEnd + FVector(0, 0, 10000)
      local CapsuleRadius = uPlayer.CapsuleComponent:GetScaledCapsuleRadius()
      local CapsuleHalfHeight = uPlayer.CapsuleComponent:GetScaledCapsuleHalfHeight()
      local UKismetSystemLibrary = import("KismetSystemLibrary")
      local Pawn_C = import("/Script/Engine.Pawn")
      local uHitResult = import("/Script/Engine.HitResult")()
      local ECollisionChannel = import("ECollisionChannel")
      local bHit = false
      bHit, uHitResult = UKismetSystemLibrary.CapsuleTraceSingleByProfile(uPlayer, RayStart, RayEnd, CapsuleRadius, CapsuleHalfHeight, "Pawn", true, slua.Array(UEnums.EPropertyClass.Object, Pawn_C), 0, uHitResult, true, FLinearColor.Red, FLinearColor.Green, 1)
      if bHit then
        local DragLocation = FVector(uHitResult.Location.X, uHitResult.Location.Y, uHitResult.Location.Z)
        if uPlayer:GetAttachParentActor() == nil and math.abs(DragLocation.Z - CurLoc.Z) > 50 then
          sandbox.LogNormal(bWriteLog and "InValidCheckArea:DragOnGroundLua", uPlayer:GetPlayerNameSafety(), CurLoc:ToString(), DragLocation:ToString())
          if uPlayer:K2_TeleportTo(DragLocation, uPlayer:K2_GetActorRotation()) then
            sandbox.LogNormal(bWriteLog and "InValidCheckArea:DragOnGroundLua success", uPlayer:GetPlayerNameSafety())
            return true
          else
            sandbox.LogNormal(bWriteLog and "InValidCheckArea:DragOnGroundLua Teleport Faild", uPlayer:GetPlayerNameSafety())
          end
        end
      else
        sandbox.LogNormal(bWriteLog and "InValidCheckArea:DragOnGroundLua Hit Faild", uPlayer:GetPlayerNameSafety())
      end
    end
  end
  return false
end
local class = require("class")
local object = require("GameLua.Mod.Library.GamePlay.Actor.BaseLevelEnterArea")
local CInValidCheckArea = class(object, nil, InValidCheckArea)
return CInValidCheckArea