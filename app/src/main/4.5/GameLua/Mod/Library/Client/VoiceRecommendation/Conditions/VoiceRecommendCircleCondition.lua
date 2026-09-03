local VoiceRecommendCircleCondition = {}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local UGameplayStatics = import("GameplayStatics")
function VoiceRecommendCircleCondition:ctor(SelfType, Params)
  self.BeginCountDownTime = Params.BeginCountDownTime or 0
  self.IncludeBlurCircleRun = Params.IncludeBlurCircleRun or false
  self.ComputeType = Params.ComputeType or "Subtraction"
  self.CompareType = Params.CompareType or UEnums.CompareType.Greater
  self.TagetValue = Params.TagetValue or 0
  self.TargetTeammateNum = Params.TargetTeammateNum or 0
  GameplayData.AddGameStateEvent(self, "OnSafeZoneTips", self.OnSafeZoneAppear, self)
  GameplayData.AddGameStateEvent(self, "OnBlueCirclePreWarning", self.OnSafeZoneAppear, self)
  GameplayData.AddGameStateEvent(self, "OnBlueCircleRun", self.OnBlueCircleMove, self)
end
function VoiceRecommendCircleCondition:DoCheckCondition()
  local uGameState = GameplayData.GetGameState()
  if not slua.isValid(uGameState) then
    return false
  end
  if self.BeginCountDownTime == nil or self.bIsCircleMoving == nil then
    return false
  end
  if self.IncludeBlurCircleRun == false and self.bIsCircleMoving == true then
    return false
  end
  local CurrentTime = UGameplayStatics.GetTimeSeconds(CGameWorld)
  if self.bIsCircleMoving == false and self.BeginCountDownTime < self.SafeZoneEndTime - CurrentTime then
    return false
  end
  local WhiteCircle = uGameState.WhiteCircle
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  local uPlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(uPlayerCharacter) or not slua.isValid(uPlayerState) then
    return false
  end
  local SelfLoc = uPlayerCharacter:K2_GetActorLocation()
  local Distance = FVector.Dist2D(SelfLoc, WhiteCircle)
  local bIsInRange = self:ComputeDistance(Distance, WhiteCircle.Z)
  if self.TargetTeammateNum == 0 or not bIsInRange then
    return bIsInRange
  end
  local TeammateList = uPlayerState:GetTeamMatePlayerStateList({}, true)
  if TeammateList == nil or TeammateList:Num() == 0 then
    return false
  end
  local VoiceRecommendationSubsystem = SubsystemMgr:Get("VoiceRecommendationSubsystem")
  if not VoiceRecommendationSubsystem then
    return false
  end
  local num = 0
  for Index, TeammateState in pairs(TeammateList) do
    if slua.isValid(TeammateState) then
      local TeammateLoc = VoiceRecommendationSubsystem:GetTeammateLocation(Index)
      if TeammateLoc then
        local TeammateDistance = FVector.Dist2D(TeammateLoc, WhiteCircle)
        if self:ComputeDistance(TeammateDistance, WhiteCircle.Z) then
          num = num + 1
          if num >= self.TargetTeammateNum then
            return true
          end
        end
      end
    end
  end
  return false
end
function VoiceRecommendCircleCondition:ComputeDistance(Distance, Radius)
  local ComputeResult = 0
  if self.ComputeType == "Ratio" then
    ComputeResult = math.abs(Distance / Radius)
  elseif self.ComputeType == "Subtraction" then
    ComputeResult = math.abs(Distance - Radius)
  else
    return false
  end
  if self.CompareType == UEnums.CompareType.Greater and ComputeResult > self.TagetValue then
    return true
  elseif self.CompareType == UEnums.CompareType.GreaterEqual and ComputeResult >= self.TagetValue then
    return true
  elseif self.CompareType == UEnums.CompareType.NotEqual and ComputeResult ~= self.TagetValue then
    return true
  elseif self.CompareType == UEnums.CompareType.Equal and ComputeResult == self.TagetValue then
    return true
  elseif self.CompareType == UEnums.CompareType.Less and ComputeResult < self.TagetValue then
    return true
  elseif self.CompareType == UEnums.CompareType.LessEqual and ComputeResult <= self.TagetValue then
    return true
  end
  return false
end
function VoiceRecommendCircleCondition:OnSafeZoneAppear(time)
  local CurrentTime = UGameplayStatics.GetTimeSeconds(CGameWorld)
  self.SafeZoneEndTime = time + CurrentTime
  self.bIsCircleMoving = false
end
function VoiceRecommendCircleCondition:OnBlueCircleMove(time)
  local CurrentTime = UGameplayStatics.GetTimeSeconds(CGameWorld)
  self.CircleMoveEndTime = time + CurrentTime
  self.bIsCircleMoving = true
end
local class = require("class")
local CConditionBase = require("GameLua.Mod.Library.Client.VoiceRecommendation.Conditions.VoiceRecommendConditionBase")
local CVoiceRecommendHasStateCondition = class(CConditionBase, nil, VoiceRecommendCircleCondition)
return CVoiceRecommendHasStateCondition