local VoiceRecommendTeammateHasPropertyCondition = {}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
function VoiceRecommendTeammateHasPropertyCondition:ctor(SelfType, Params)
  if Params.PropertyName then
    self.PropertyName = Params.PropertyName
  elseif Params.PropertyEntry then
    self.PropertyEntry = Params.PropertyEntry
  end
  if Params.DataType == "Character" then
    self.DataType = 1
  elseif Params.DataType == "PlayerState" then
    self.DataType = 2
  end
  self.TargetValue = Params.TargetValue
  self.CompareType = Params.CompareType
end
function VoiceRecommendTeammateHasPropertyCondition:DoCheckCondition()
  local PlayerState = GameplayData.GetPlayerState()
  local TeammatePlayerStateList = PlayerState:GetTeamMatePlayerStateList({}, true)
  if TeammatePlayerStateList then
    for _, TeammatePlayerState in pairs(TeammatePlayerStateList) do
      local DataObj
      if self.DataType == 1 and slua.isValid(TeammatePlayerState) then
        DataObj = TeammatePlayerState:GetPlayerCharacter()
      elseif self.DataType == 2 then
        DataObj = TeammatePlayerState
      end
      if slua.isValid(DataObj) then
        local PropertyValue = self:GetPropertyValue(DataObj)
        if PropertyValue ~= nil and self:Compare(PropertyValue) then
          return true
        end
      end
    end
  end
  return false
end
local class = require("class")
local VoiceRecommendHasPropertyCondition = require("GameLua.Mod.Library.Client.VoiceRecommendation.Conditions.VoiceRecommendHasPropertyCondition")
local CVoiceRecommendTeammateHasPropertyCondition = class(VoiceRecommendHasPropertyCondition, nil, VoiceRecommendTeammateHasPropertyCondition)
return CVoiceRecommendTeammateHasPropertyCondition