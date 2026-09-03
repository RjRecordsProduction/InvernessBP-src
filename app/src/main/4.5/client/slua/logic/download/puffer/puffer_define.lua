local puffer_define = {
  PufferSystemParameterKey = {
    PufferHttpCurlSigleDownloadTimeout = 1,
    PufferHttpCurlRecvBufferSize = 2,
    PufferMaxDownloadSpeed = 3
  },
  PufferErrorQuicStatus = {
    RunnableNoRollback = 269879255,
    SpeedBelowExpectationNeedsRollback = 269879253,
    ErrorsAboveLimitRequiresRollback = 269879254,
    RollbackSucess = 269879252
  },
  PufferDownloadStageType = {DownloadStageTypeUnknown = 0, DownloadStageTypeLoading = 1},
  PufferHttpDnsType = {OnLocalDNS = 1, LocalDNSFailedToHttpDNS = 2},
  PufferDownloadEngineType = {Normal = 1, HCDN = 6}
}
return puffer_define