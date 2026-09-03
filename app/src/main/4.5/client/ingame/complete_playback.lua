CompletePlaybackUI = CompletePlaybackUI or {}
function _ENV:complete_playback_RegisterUI()
  InGameUIManager.SubUIWidgetList(complete_playback, {
    {
      Path = "/Game/BluePrints/ControlInput/ResultsshareUI/CompletePlayback_UIBP.CompletePlayback_UIBP_C",
      Container = "Default",
      ZOrder = BP_ENUM_UI_RANK_ZORDER
    }
  }, {"Fighting"}, false, true, true)
  log(bWriteLog and "complete_playback_RegisterUI")
end
function CompletePlaybackUI:ShowCompletePlaybackUI()
  log(bWriteLog and "CompletePlaybackUI:ShowCompletePlaybackUI")
  InGameUIManager.HandleDynamicCreation(complete_playback)
  InGameUIManager.HandleUIMessage(complete_playback, "ShowCompletePlaybackUI")
  EventSystem:postEvent(EVENTTYPE_INGAME_REPLAY, EVENTID_INIT_COMPLETE_PLAYBACK_UI)
end