local CheckDebugSuggestionType = {MatchTimesInTime = 1}
local CheckDebugSuggestionFunction = {
  [CheckDebugSuggestionType.MatchTimesInTime] = {
    IsSuggest = function(DebugSuggestionData)
      return DebugSuggestionData.CurrentTimes >= DebugSuggestionData.MatchTimes
    end,
    Trigger = function(DebugSuggestionData, TriggerValue)
      if DebugSuggestionData.MatchValue == TriggerValue then
        DebugSuggestionData.CurrentTimes = DebugSuggestionData.CurrentTimes + 1
        if DebugSuggestionData.TimerID > 0 then
          Game:ClearTimer(DebugSuggestionData.TimerID)
          DebugSuggestionData.TimerID = -1
        end
        if DebugSuggestionData.CurrentTimes < DebugSuggestionData.MatchTimes then
          DebugSuggestionData.TimerID = Game:SetTimer(DebugSuggestionData.Duration, false, function()
            DebugSuggestionData.CurrentTimes = 0
            DebugSuggestionData.TimerID = -1
          end)
        end
      end
    end
  }
}
local DebugSuggestionDataMap = {
  Gyroscope = {
    CheckType = CheckDebugSuggestionType.MatchTimesInTime,
    Duration = 180,
    TimerID = -1,
    CurrentTimes = 0,
    MatchTimes = 2,
    MatchValue = 0
  }
}
local DebugSuggestion = {}
function DebugSuggestion.RegistEvents()
  EventSystem:registEvent(EVENTTYPE_SETTING, EVENTID_SETTING_GYROSCOPE_CHANGE, DebugSuggestion.OnGyroscopeChangeHandler)
end
function DebugSuggestion.UnregistEvents()
  EventSystem:unregistEvent(EVENTTYPE_SETTING, EVENTID_SETTING_GYROSCOPE_CHANGE, DebugSuggestion.OnGyroscopeChangeHandler)
end
function DebugSuggestion.ShowSuggest(Key, RootWidget, OriginalWidget, SuggestionWidget, SuggestionText, SuggestionLocalizationID, SuggestionAnimation)
  local DebugSuggestionData = DebugSuggestionDataMap[Key]
  if DebugSuggestionData then
    local Collapsed = UEnums.ESlateVisibility.Collapsed
    local SelfHitTestInvisible = UEnums.ESlateVisibility.SelfHitTestInvisible
    local OriginalWidgetVisibility = OriginalWidget:GetVisibility()
    if CheckDebugSuggestionFunction[DebugSuggestionData.CheckType].IsSuggest(DebugSuggestionData) then
      if slua.isValid(SuggestionText) and SuggestionLocalizationID then
        SuggestionText:SetText(LocUtil.GetLocalizeResStr(SuggestionLocalizationID))
      end
      if OriginalWidgetVisibility ~= Collapsed then
        OriginalWidget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        SuggestionWidget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        if slua.isValid(SuggestionAnimation) then
          RootWidget:PlayUserWidgetAnimation(SuggestionAnimation, 0, 1, 0, 1)
        end
      end
    elseif OriginalWidgetVisibility ~= SelfHitTestInvisible then
      OriginalWidget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      SuggestionWidget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
end
function DebugSuggestion.Trigger(Key, Arg0)
  local DebugSuggestionData = DebugSuggestionDataMap[Key]
  if DebugSuggestionData then
    return CheckDebugSuggestionFunction[DebugSuggestionData.CheckType].Trigger(DebugSuggestionData, Arg0)
  end
  return false
end
function DebugSuggestion.OnGyroscopeChangeHandler(EventType, EventID, Gyroscope)
  DebugSuggestion.Trigger("Gyroscope", Gyroscope)
end
return DebugSuggestion