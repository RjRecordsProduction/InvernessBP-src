local VoiceRecommendHasStateCondition = {}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local UGameplayStatics = import("GameplayStatics")
function VoiceRecommendHasStateCondition:ctor(SelfType, Params)
  self.ConditionState = Params.State
  self.CDTime = Params.CDTime
  if Params.bRegistEvent == true then
    GameplayData.AddSelfPlayerControllerEvent(self, "OnLiveStateChanged", self.OnLiveStateChanged, self)
  end
end
function VoiceRecommendHasStateCondition:DoCheckCondition()
  local uPlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(uPlayerState) then
    return false
  end
  local LiveState = uPlayerState.LiveState
  local CurrentTime = UGameplayStatics.GetTimeSeconds(CGameWorld)
  if self.TriggerTime == nil or self.CDTime == nil or CurrentTime <= self.TriggerTime + self.CDTime then
    for _, State in ipairs(self.ConditionState) do
      if LiveState == State then
        return true
      end
    end
  end
  return false
end
function VoiceRecommendHasStateCondition:SetCD()
  local CurrentTime = UGameplayStatics.GetTimeSeconds(CGameWorld)
  if self.TriggerTime == nil then
    self.TriggerTime = CurrentTime
  end
end
function VoiceRecommendHasStateCondition:OnLiveStateChanged(LiveState)
  self.TriggerTime = nil
end
local class = require("class")
local CConditionBase = require("GameLua.Mod.Library.Client.VoiceRecommendation.Conditions.VoiceRecommendConditionBase")
local CVoiceRecommendHasStateCondition = class(CConditionBase, nil, VoiceRecommendHasStateCondition)
return CVoiceRecommendHasStateCondition