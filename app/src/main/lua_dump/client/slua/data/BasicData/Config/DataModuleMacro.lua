local DataModuleMacro = {
  ENUM_Data_TimeSensitiveGap = {ENUM_TimeSensitive_1S = 1, ENUM_TimeSensitive_1M = 2},
  ENUM_Data_BatchProcessingGap = {
    ENUM_Data_BatchProcessingGap_NextF = 1,
    ENUM_Data_BatchProcessingGap_3F = 2,
    ENUM_Data_BatchProcessingGap_3S = 3,
    ENUM_Data_BatchProcessingGap_10S = 4
  },
  ENUM_DataState = {
    ENUM_DataState_None = 1,
    ENUM_DataState_Waiting = 2,
    ENUM_DataState_TimeSensitiveExpired = 3,
    ENUM_DataState_Valid = 4
  },
  WaitingTimeout = 15
}
DataModuleMacro.TimeSensitiveGap = {
  [DataModuleMacro.ENUM_Data_TimeSensitiveGap.ENUM_TimeSensitive_1S] = 1,
  [DataModuleMacro.ENUM_Data_TimeSensitiveGap.ENUM_TimeSensitive_1M] = 60
}
DataModuleMacro.BatchProcessingGap = {
  [DataModuleMacro.ENUM_Data_BatchProcessingGap.ENUM_Data_BatchProcessingGap_NextF] = 0,
  [DataModuleMacro.ENUM_Data_BatchProcessingGap.ENUM_Data_BatchProcessingGap_3F] = 0.1,
  [DataModuleMacro.ENUM_Data_BatchProcessingGap.ENUM_Data_BatchProcessingGap_3S] = 3,
  [DataModuleMacro.ENUM_Data_BatchProcessingGap.ENUM_Data_BatchProcessingGap_10S] = 10
}
return DataModuleMacro