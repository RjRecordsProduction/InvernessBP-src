local VoiceRecommendConditionBase = {}
function VoiceRecommendConditionBase:ctor(SelfType, Params)
end
function VoiceRecommendConditionBase:DoCheckCondition()
end
function VoiceRecommendConditionBase:SetCD()
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
local CVoiceRecommendConditionBase = class(CDelegateContainer, nil, VoiceRecommendConditionBase)
return CVoiceRecommendConditionBase