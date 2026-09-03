local post_switch_popup_config = {}
post_switch_popup_config.CJumpFormat = "game://?module=%d"
post_switch_popup_config.CEventKeyFormat = "%d_%d"
post_switch_popup_config.CDefaultOrder = 999
post_switch_popup_config.EState = {
  NotStart = 0,
  InProgress = 1,
  EventWaiting = 2,
  Executing = 3,
  Finished = 4
}
post_switch_popup_config.EOneCantExecuteReason = {
  None = 0,
  ConfigNone = 1,
  ExecuteOnce = 2,
  EventNotReady = 3,
  OnlyPostSwitch = 4
}
post_switch_popup_config.SElement = {
  moduleID = 0,
  order = post_switch_popup_config.CDefaultOrder,
  checkFunction = nil,
  eventType = 0,
  eventID = 0,
  executeOnce = false,
  onlyPostSwitch = false
}
return post_switch_popup_config