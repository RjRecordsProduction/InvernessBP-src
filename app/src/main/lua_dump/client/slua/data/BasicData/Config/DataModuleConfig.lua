local ModuleMacro = require("client.module_framework.ModuleMacro")
local DataModuleMacro = require("client.slua.data.BasicData.Config.DataModuleMacro")
local ModuleConfig = {
  BasicDataAvatarWearInfo = {
    KeyName = "BasicDataAvatarWearInfo",
    ModuleName = "client.slua.data.BasicData.BasicDataAvatarWearInfo",
    ModuleLevel = ModuleMacro.ModuleLevel.SceneLevel,
    TimeSensitive = DataModuleMacro.ENUM_Data_TimeSensitiveGap.ENUM_TimeSensitive_1M
  },
  BasicDataServerTable = {
    KeyName = "BasicDataServerTable",
    ModuleName = "client.slua.data.BasicData.BasicDataServerTable",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel,
    BatchProcessingGap = DataModuleMacro.ENUM_Data_BatchProcessingGap.ENUM_Data_BatchProcessingGap_3F,
    BatchProcessingMaxCount = 9
  },
  BasicDataDropTable = {
    KeyName = "BasicDataDropTable",
    ModuleName = "client.slua.data.BasicData.BasicDataDropTable",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel,
    BatchProcessingGap = DataModuleMacro.ENUM_Data_BatchProcessingGap.ENUM_Data_BatchProcessingGap_3F,
    BatchProcessingMaxCount = 50
  },
  BasicDataChestTable = {
    KeyName = "BasicDataChestTable",
    ModuleName = "client.slua.data.BasicData.BasicDataChestTable",
    ModuleLevel = ModuleMacro.ModuleLevel.UserLevel,
    BatchProcessingGap = DataModuleMacro.ENUM_Data_BatchProcessingGap.ENUM_Data_BatchProcessingGap_3F,
    BatchProcessingMaxCount = 50
  },
  BasicDataTLogReport = {
    KeyName = "BasicDataTLogReport",
    ModuleName = "client.slua.data.BasicData.BasicDataTLogReport",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel,
    BatchProcessingGap = DataModuleMacro.ENUM_Data_BatchProcessingGap.ENUM_Data_BatchProcessingGap_3S,
    BatchProcessingMaxCount = 30
  },
  BasicDataClientReport = {
    KeyName = "BasicDataClientReport",
    ModuleName = "client.slua.data.BasicData.BasicDataClientReport",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel,
    BatchProcessingGap = DataModuleMacro.ENUM_Data_BatchProcessingGap.ENUM_Data_BatchProcessingGap_10S,
    BatchProcessingMaxCount = 50
  },
  BasicDataCelebrationRankInfo = {
    KeyName = "BasicDataCelebrationRankInfo",
    ModuleName = "client.slua.data.BasicData.BasicDataCelebrationRankInfo",
    TimeSensitive = DataModuleMacro.ENUM_Data_TimeSensitiveGap.ENUM_TimeSensitive_1S
  },
  UGCTLogReport = {
    KeyName = "UGCTLogReport",
    ModuleName = "client.slua.logic.ugc.UGCTLogReport",
    ModuleLevel = ModuleMacro.ModuleLevel.AppLevel,
    BatchProcessingGap = DataModuleMacro.ENUM_Data_BatchProcessingGap.ENUM_Data_BatchProcessingGap_3S,
    BatchProcessingMaxCount = 30
  },
  BasicDataGiftAskSysStatus = {
    KeyName = "BasicDataGiftAskSysStatus",
    ModuleName = "client.slua.data.BasicData.BasicDataGiftAskSysStatus",
    TimeSensitive = DataModuleMacro.ENUM_Data_TimeSensitiveGap.ENUM_TimeSensitive_1M,
    BatchProcessingGap = DataModuleMacro.ENUM_Data_BatchProcessingGap.ENUM_Data_BatchProcessingGap_3S,
    BatchProcessingMaxCount = 30
  }
}
return ModuleConfig