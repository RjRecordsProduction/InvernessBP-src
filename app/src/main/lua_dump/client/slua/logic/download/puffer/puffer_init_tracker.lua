local puffer_init_tracker = {
  EStopStage = {NONE = 0, BeforeBattle = 1},
  StopPufferBeforeEnterBattle = false
}
function puffer_init_tracker:OnStopPuffer(stopStage)
  log(bWriteLog and "PufferInitTracker.OnStopPuffer")
  if stopStage == self.EStopStage.BeforeBattle then
    self.StopPufferBeforeEnterBattle = true
  end
end
function puffer_init_tracker:OnInitPufferResult(resultCode)
  log(bWriteLog and "PufferInitTracker.OnInitPufferResult: " .. tostring(resultCode))
  if self.StopPufferBeforeEnterBattle == false then
    log(bWriteLog and "PufferInitTracker.OnInitPufferResult return by NOT StopPufferBeforeEnterBattle")
    return
  end
  self:ReportGemEvent(resultCode)
  self.StopPufferBeforeEnterBattle = false
end
function puffer_init_tracker:ReportGemEvent(resultCode)
  local enableReport = false
  enableReport = HDmpveRemote.HDmpveRemoteConfigGetBool("enablePufferInitBeforeBattleReport", enableReport)
  if enableReport == false then
    log(bWriteLog and "PufferInitTracker.ReportGemEvent return")
    return
  end
  local SubEvent = "PufferInitAfterBattle"
  local ParamTable = {
    tostring(resultCode)
  }
  Client.GEMReportSubEvent(GameFrontendHUD, "GRomeLinkEvent", SubEvent, ParamTable)
end
return puffer_init_tracker