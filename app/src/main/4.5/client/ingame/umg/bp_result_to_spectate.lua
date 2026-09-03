ResultToSpectate = ResultToSpectate or {canceled = false, nEnterDeathTime = 0}
function _ENV:bp_result_to_spectate_RegisterUI()
  print(bWriteLog and "bp_result_to_spectate_RegisterUI start")
  LuaClassObj.SubUIWidgetList(bp_result_to_spectate, {
    {
      Path = "/Game/BluePrints/ControlInput/ResultsshareUI/Result_To_Spectate_BP.Result_To_Spectate_BP_C",
      Container = "Default",
      ZOrder = BP_ENUM_UI_RANK_ZORDER
    }
  }, {"Fighting"}, false, true, true)
  print(bWriteLog and "bp_result_to_spectate_RegisterUI")
end
BP_ResultToSpectate_ReviveMode = false
ResultToSpectate.BP_ResultToSpectate_AutoGotoSpectating = false
function ResultToSpectate.OnModePostSwitch(preState, nextState)
  log(bWriteLog and "ResultToSpectate.OnModePostSwitch")
  ResultToSpectate.canceled = false
end
function ResultToSpectate_DynamicCreateUI(isReviveMode, autoGotoSpectating)
  log(bWriteLog and "ResultToSpectate_DynamicCreateUI: isReviveMode: " .. tostring(isReviveMode) .. " autoGotoSpectating: " .. tostring(autoGotoSpectating))
  BP_ResultToSpectate_ReviveMode = isReviveMode
  ResultToSpectate.BP_ResultToSpectate_AutoGotoSpectating = autoGotoSpectating
  LuaClassObj.HandleDynamicCreation(bp_result_to_spectate)
  LuaClassObj.HandleUIMessage(bp_result_to_spectate, "ShowUI")
  EventSystem:registEvent(EVENTTYPE_STATE, EVENTID_GAMESTATE_ON_BATTLE_RESULT, ResultToSpectate.HideUI)
end
function EventResultToSpectateEnterSpectating()
  log(bWriteLog and "EventResultToSpectateEnterSpectating")
  if DeathReplayLuaInterface:OnEventResultToSpectateEnterSpectating() then
    return
  end
  local BattleResultSubSystem = SubsystemMgr:Get("BattleResultSubSystem")
  if BattleResultSubSystem and BattleResultSubSystem:InResultProcess() then
    log(bWriteLog and "EventResultToSpectateEnterSpectating InResultProcess return")
    return
  end
  log(bWriteLog and "EventResultToSpectateEnterSpectating ShowSpectatingUI")
  local bVisible = WatchGameUI:GetVisibility()
  WatchGameUI:ShowSpectatingUI()
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) and bVisible == false and uPlayerController.IsPureSpectator and not uPlayerController:IsPureSpectator() then
    log(bWriteLog and "EventResultToSpectateEnterSpectating HideSpectatingUI")
    WatchGameUI:HideSpectatingUI()
    return
  end
end
function ResultToSpectate.RevivemodeEnterSpectateUI()
  if Game:IsEnableUIStateRefreshFlag() and false then
    return
  end
  log(bWriteLog and "ResultToSpectate.RevivemodeEnterSpectateUI")
  local BattleResultSubSystem = SubsystemMgr:Get("BattleResultSubSystem")
  if BattleResultSubSystem and BattleResultSubSystem:InResultProcess() then
    log(bWriteLog and "ResultToSpectate.RevivemodeEnterSpectateUI InResultProcess return")
    return
  end
  ResultToSpectate_DynamicCreateUI(true, true)
end
function EventResultToSpectateCancelSpectate()
  log(bWriteLog and "EventResultToSpectateCancelSpectate")
  BattleResultUI.SetIsDirectShow(true)
end
function ResultToSpectate.HideUI()
  log(bWriteLog and "ResultToSpectate.HideUI")
  ResultToSpectate.BP_ResultToSpectate_AutoGotoSpectating = false
  LuaClassObj.HandleUIMessage(bp_result_to_spectate, "HideUI")
  EventSystem:unregistEvent(EVENTTYPE_STATE, EVENTID_GAMESTATE_ON_BATTLE_RESULT, ResultToSpectate.HideUI)
end
function ResultToSpectate.WaitSelfRevival()
  log(bWriteLog and "ResultToSpectate.WaitSelfRevival")
  LuaClassObj.HandleUIMessage(bp_result_to_spectate, "WaitSelfRevival")
end
function ResultToSpectate.WaitTeammateRevival()
  log(bWriteLog and "ResultToSpectate.WaitTeammateRevival")
  LuaClassObj.HandleUIMessage(bp_result_to_spectate, "WaitTeammateRevival")
end
function ResultToSpectate.ShowDeathReplay()
  log(bWriteLog and "ResultToSpectate.ShowDeathReplay")
  if slua.isValid(LuaClassObj) and slua.isValid(bp_result_to_spectate) then
    LuaClassObj.HandleUIMessage(bp_result_to_spectate, "ShowDeathReplay")
  end
end