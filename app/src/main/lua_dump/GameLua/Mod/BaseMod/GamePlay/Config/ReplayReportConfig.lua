local ReplayReportConfig = {
  [1] = {
    Type = UEnums.EReplayReportRPCType.UInt8ArrayUnReliable,
    ReportInterval = 0.5,
    bOnlyReportLatest = true,
    HandleFunc = "OnReportUIState"
  },
  [2] = {
    Type = UEnums.EReplayReportRPCType.UInt8ArrayReliable,
    ReportInterval = 0,
    bOnlyReportLatest = false,
    HandleFunc = "OnReceiveBattleResult"
  },
  [3] = {
    Type = UEnums.EReplayReportRPCType.UInt8ArrayUnReliable,
    ReportInterval = 0,
    bOnlyReportLatest = false,
    HandleFunc = "OnUpdateBattleResultPeriod"
  },
  [4] = {
    Type = UEnums.EReplayReportRPCType.IntArrayUnReliable,
    ReportInterval = 1,
    bOnlyReportLatest = true,
    HandleFunc = "OnReportAvatarNetData"
  },
  [5] = {
    Type = UEnums.EReplayReportRPCType.IntArrayUnReliable,
    ReportInterval = 0,
    bOnlyReportLatest = false,
    HandleFunc = "OnReportRescueBtnTrace"
  }
}
return ReplayReportConfig