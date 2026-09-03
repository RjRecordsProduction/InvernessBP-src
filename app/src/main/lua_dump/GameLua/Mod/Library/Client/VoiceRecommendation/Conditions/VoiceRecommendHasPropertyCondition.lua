local VoiceRecommendHasPropertyCondition = {}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
function VoiceRecommendHasPropertyCondition:ctor(SelfType, Params)
  if Params.PropertyName then
    self.PropertyName = Params.PropertyName
  elseif Params.PropertyEntry then
    self.PropertyEntry = Params.PropertyEntry
  end
  if Params.DataType == "Character" then
    self.DataType = 1
  elseif Params.DataType == "PlayerState" then
    self.DataType = 2
  elseif Params.DataType == "Controller" then
    self.DataType = 3
  end
  self.TargetValue = Params.TargetValue
  self.CompareType = Params.CompareType
end
function VoiceRecommendHasPropertyCondition:DoCheckCondition()
  local DataObj
  if self.DataType == 1 then
    DataObj = GameplayData.GetPlayerCharacter()
  elseif self.DataType == 2 then
    DataObj = GameplayData.GetPlayerState()
  elseif self.DataType == 3 then
    DataObj = GameplayData.GetPlayerController()
  else
    return false
  end
  if not slua.isValid(DataObj) then
    return false
  end
  local PropertyValue = self:GetPropertyValue(DataObj)
  if PropertyValue ~= nil then
    return self:Compare(PropertyValue)
  else
    return false
  end
  return self:Compare(PropertyValue)
end
function VoiceRecommendHasPropertyCondition:GetPropertyValue(Object)
  local PropertyValue
  if self.PropertyName then
    PropertyValue = Object[self.PropertyName]
  elseif self.PropertyEntry and next(self.PropertyEntry) then
    local depth = #self.PropertyEntry
    PropertyValue = Object[self.PropertyEntry[1]]
    for i = 2, depth do
      PropertyValue = PropertyValue[self.PropertyEntry[i]]
    end
  end
  return PropertyValue
end
function VoiceRecommendHasPropertyCondition:Compare(PropertyValue)
  if self.CompareType == UEnums.CompareType.Greater and PropertyValue > self.TargetValue then
    return true
  elseif self.CompareType == UEnums.CompareType.GreaterEqual and PropertyValue >= self.TargetValue then
    return true
  elseif self.CompareType == UEnums.CompareType.NotEqual and PropertyValue ~= self.TargetValue then
    return true
  elseif self.CompareType == UEnums.CompareType.Equal and PropertyValue == self.TargetValue then
    return true
  elseif self.CompareType == UEnums.CompareType.Less and PropertyValue < self.TargetValue then
    return true
  elseif self.CompareType == UEnums.CompareType.LessEqual and PropertyValue <= self.TargetValue then
    return true
  end
end
local class = require("class")
local CConditionBase = require("GameLua.Mod.Library.Client.VoiceRecommendation.Conditions.VoiceRecommendConditionBase")
local CVoiceRecommendHasPropertyCondition = class(CConditionBase, nil, VoiceRecommendHasPropertyCondition)
return CVoiceRecommendHasPropertyCondition