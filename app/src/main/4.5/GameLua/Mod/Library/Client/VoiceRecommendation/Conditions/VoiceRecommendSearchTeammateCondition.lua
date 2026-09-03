local VoiceRecommendSearchTeammateCondition = {}
local ExtraPlayerLiveState = import("ExtraPlayerLiveState")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local UGameplayStatics = import("GameplayStatics")
function VoiceRecommendSearchTeammateCondition:ctor(SelfType, Params)
  self.DistanceSquared = Params.DistanceSquared
  self.CompareType = Params.CompareType
  self.TargetNum = Params.TargetNum
  self.PreSearchFunc = Params.PreSearchFunc or "DefaultPreSearchFunction"
  self.SearchFunc = Params.SearchFunc or "DefaultSearchFunction"
end
function VoiceRecommendSearchTeammateCondition:DoCheckCondition()
  local uPlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(uPlayerState) or not uPlayerState.GetTeamMatePlayerStateList then
    return false
  end
  local TeammateList = uPlayerState:GetTeamMatePlayerStateList({}, true)
  if TeammateList == nil or TeammateList:Num() == 0 then
    return false
  end
  local PreSearchFunc = self[self.PreSearchFunc]
  if PreSearchFunc and type(PreSearchFunc) == "function" then
    PreSearchFunc(self, uPlayerState)
  end
  local SearchFunc = self[self.SearchFunc]
  if SearchFunc == nil or type(SearchFunc) ~= "function" then
    SearchFunc = self.DefaultSearchFunction
  end
  local VoiceRecommendationSubsystem = SubsystemMgr:Get("VoiceRecommendationSubsystem")
  if not VoiceRecommendationSubsystem then
    return false
  end
  local Num = 0
  local SelfLoc = uPlayerState:GetPlayerCurLoc()
  for Index, TeammateState in pairs(TeammateList) do
    if slua.isValid(TeammateState) and SearchFunc(self, uPlayerState, TeammateState) and TeammateState.LiveState ~= ExtraPlayerLiveState.InDied then
      local Dis = VoiceRecommendationSubsystem:GetTeammateDistance(Index)
      if Dis then
        if self.CompareType == UEnums.CompareType.Greater and Dis > self.DistanceSquared then
          Num = Num + 1
        elseif self.CompareType == UEnums.CompareType.GreaterEqual and Dis >= self.DistanceSquared then
          Num = Num + 1
        elseif self.CompareType == UEnums.CompareType.NotEqual and Dis ~= self.DistanceSquared then
          Num = Num + 1
        elseif self.CompareType == UEnums.CompareType.Equal and Dis == self.DistanceSquared then
          Num = Num + 1
        elseif self.CompareType == UEnums.CompareType.Less and Dis < self.DistanceSquared then
          Num = Num + 1
        elseif self.CompareType == UEnums.CompareType.LessEqual and Dis <= self.DistanceSquared then
          Num = Num + 1
        end
        if Num >= self.TargetNum then
          return true
        end
      end
    end
  end
  return false
end
function VoiceRecommendSearchTeammateCondition:DefaultSearchFunction(CurPlayerState, TeammatePlayerState)
  return true
end
function VoiceRecommendSearchTeammateCondition:DefaultPreSearchFunction(CurPlayerState)
  return
end
function VoiceRecommendSearchTeammateCondition:NoVehicleSearchFunction(CurPlayerState, TeammatePlayerState)
  if self.IsSeatAvailable == false then
    return false
  end
  local uTeammateCharacter = TeammatePlayerState:GetPlayerCharacter()
  if not slua.isValid(uTeammateCharacter) then
    return false
  end
  local TeammateVehicle = uTeammateCharacter:GetCurrentVehicle()
  if not slua.isValid(TeammateVehicle) then
    return true
  end
  return false
end
function VoiceRecommendSearchTeammateCondition:NoVehiclePreSearchFunction(CurPlayerState)
  self.IsSeatAvailable = false
  local uPlayerCharacter = GameplayData.GetPlayerCharacter()
  if not slua.isValid(uPlayerCharacter) then
    return
  end
  local uVehicle = uPlayerCharacter:GetCurrentVehicle()
  if not slua.isValid(uVehicle) then
    return
  end
  local uVehicleSeatsComp = uVehicle:GetVehicleSeats()
  if not slua.isValid(uVehicleSeatsComp) then
    return
  end
  self.IsSeatAvailable = uVehicleSeatsComp:IsSeatAvailable(0) or uVehicleSeatsComp:IsSeatAvailable(1)
end
local class = require("class")
local CConditionBase = require("GameLua.Mod.Library.Client.VoiceRecommendation.Conditions.VoiceRecommendConditionBase")
local CVoiceRecommendSearchTeammateCondition = class(CConditionBase, nil, VoiceRecommendSearchTeammateCondition)
return CVoiceRecommendSearchTeammateCondition