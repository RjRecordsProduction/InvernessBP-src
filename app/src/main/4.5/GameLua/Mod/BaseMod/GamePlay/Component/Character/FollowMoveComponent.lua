local ENetRole = import("ENetRole")
local ECharacterFollowType = import("ECharacterFollowType")
local FollowMoveComponent = {}
local FHitResult = import("/Script/Engine.HitResult")
function FollowMoveComponent:ConditionChangeLeaderInputRate(ForwardInputRate, RightInputRate)
  ForwardInputRate = math.max(ForwardInputRate, 0)
  if 0.05 < ForwardInputRate then
    self.bUseAutoMoveSpeed = false
    self.ClientLeaderCacheInputYaw = RightInputRate * self.LeaderTurnSpeedRatio
  end
  return ForwardInputRate, 0
end
function FollowMoveComponent:DSCreateQueue(LeaderMoveType)
  print(bWriteLog and string.format("FollowMoveComponent:DSCreateQueue LUA"))
  local uOwner = self:GetOwner()
  if not slua.isValid(uOwner) or uOwner.IsNetFPP then
    print(bWriteLog and string.format("FollowMoveComponent:DSCreateQueue IsNetFPP"))
    return false
  end
  return self.Super:DSCreateQueue(LeaderMoveType)
end
function FollowMoveComponent:DSEnterQueue(LeaderCom, LeaderMoveType)
  print(bWriteLog and string.format("FollowMoveComponent:DSEnterQueue LUA"))
  local uOwner = self:GetOwner()
  if not slua.isValid(uOwner) or uOwner.IsNetFPP then
    print(bWriteLog and string.format("FollowMoveComponent:DSCreateQueue IsNetFPP"))
    return false
  end
  return self.Super:DSEnterQueue(LeaderCom, LeaderMoveType)
end
function FollowMoveComponent:DSInitFollowerLocation()
  print(bWriteLog and string.format("FollowMoveComponent:DSInitFollowerLocation LUA"))
  local Index = self:GetCurrentPathIndex()
  if Index < self.MAX_FOLLOW_PATH_POINT_NUM and slua.isValid(self.OwnerCharacter) then
    local CacheLocation = self.OwnerCharacter:K2_GetActorLocation()
    local FollowLocation = self:GetLeaderPathPoint(Index)
    local HitResult = FHitResult()
    local Ret, HitResult = self.OwnerCharacter:K2_SetActorLocation(FollowLocation, true, HitResult, true)
    self.OwnerCharacter:K2_SetActorLocation(CacheLocation, false, nil, true)
    if HitResult.bStartPenetrating or HitResult.bBlockingHit then
      print(bWriteLog and string.format("FollowMoveComponent:DSInitFollowerLocation HitResult %s ", tostring(HitResult.Actor)))
      return false
    end
  end
  return self.Super:DSInitFollowerLocation()
end
function FollowMoveComponent:HandleFollowTypeChangeBP(NewType, OldType)
  local uSelfCharacter = self:GetOwner()
  local uController = slua.isValid(uSelfCharacter) and uSelfCharacter:GetPlayerControllerSafety()
  if slua.isValid(uController) then
    if uSelfCharacter.Role == ENetRole.ROLE_AutonomousProxy then
      if NewType == 0 then
        print(bWriteLog and string.format("FollowMoveComponent:HandleFollowTypeChangeBP ExitFreeCamera Name:%s, Role:%d [%s->%s]", tostring(uSelfCharacter:GetPlayerNameSafety()), uSelfCharacter.Role, tostring(OldType), tostring(NewType)))
        uController:ExitFreeCamera(false)
        uController:SetJoystickOperatingMode(1, 0)
      else
        print(bWriteLog and string.format("FollowMoveComponent:HandleFollowTypeChangeBP StartFreeCamera Name:%s Role:%d [%s->%s]", tostring(uSelfCharacter:GetPlayerNameSafety()), uSelfCharacter.Role, tostring(OldType), tostring(NewType)))
        uController:StartFreeCamera(0)
        uController:SetJoystickOperatingMode(0, 0)
      end
      self.ClientLeaderCacheInputYaw = 0
    elseif uController.Role == ENetRole.ROLE_Authority then
      if NewType == 0 then
        self:RemoveControlEvent(uSelfCharacter, "OnServerPerspectiveChanged")
      else
        self:AddControlEvent(uSelfCharacter, "OnServerPerspectiveChanged", self.HandleOnPerspectiveChanged, self, uSelfCharacter)
      end
      EventSystem:postEvent(EVENTTYPE_LIBRARY, EVENTID_LIBRARY_FORWARDEMOTE_QUEUE_CHANGED, uSelfCharacter, NewType)
    end
  end
  print(bWriteLog and string.format("FollowMoveComponent:HandleFollowTypeChangeBP %s [%s->%s]", tostring(uSelfCharacter), tostring(OldType), tostring(NewType)))
end
function FollowMoveComponent:HandleOnPerspectiveChanged(uSelfCharacter, IsNewFPP)
  print(bWriteLog and string.format("FollowMoveComponent:HandleOnPerspectiveChanged %s %s ", tostring(slua.isValid(uSelfCharacter) and uSelfCharacter), tostring(IsNewFPP)))
  if IsNewFPP then
    self:DSExitQueue()
  end
end
local Class = require("class")
local CFollowMoveComponent = require("GameLua.Mod.BaseMod.Common.Core.ActorComponentBase")
return Class(CFollowMoveComponent, nil, FollowMoveComponent)