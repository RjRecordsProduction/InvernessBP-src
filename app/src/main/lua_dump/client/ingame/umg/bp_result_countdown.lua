function _ENV:bp_result_countdown_RegisterUI()
end
BP_ResultCountDown_Time = 0
BP_ResultCountDown_IsTerminator = false
BP_ResultCountDown_IsMVPShowed = false
function ResultCountDown_DynamicCreateUI(delay_time, is_terminator, is_mvp_showed)
  log(bWriteLog and "ResultCountDown_DynamicCreateUI:" .. delay_time)
  BP_ResultCountDown_Time = delay_time
  BP_ResultCountDown_IsTerminator = is_terminator
  BP_ResultCountDown_IsMVPShowed = is_mvp_showed
  LuaClassObj.HandleDynamicCreation(bp_result_countdown)
  LuaClassObj.HandleUIMessage(bp_result_countdown, "ShowCountDownUI")
end
function ResultCountDown_Show()
  ResultCountDown_DynamicCreateUI(30)
end
function EventSkipToShowBattleResult()
  BattleResultUI.OnResultCountDownShowEnd()
end